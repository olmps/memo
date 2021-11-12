import * as firebase from "firebase-admin";
import FirebaseFirestoreError from "@faults/errors/firebase-firestore-error";
import { FirestorePaths } from "./firestore-collection-name";

type Firestore = firebase.firestore.Firestore;
type Transaction = firebase.firestore.Transaction;
type CollectionReferece = firebase.firestore.CollectionReference;
type CollectionGroup = firebase.firestore.CollectionGroup;
type Query = firebase.firestore.Query;
type DocumentSnapshot = firebase.firestore.DocumentSnapshot;
type DocumentData = firebase.firestore.DocumentData;

type QueryComparison = FirebaseFirestore.WhereFilterOp;

/**
 * Represent a `Firestore` where filter, used in read operations.
 *
 * @param field Object's field name to be compared
 * @param comparison Filter operation
 * @param value Expected field value
 */
export interface QueryFilter {
  field: string;
  comparison: QueryComparison;
  value: unknown;
}

/** Maximum operations for a single transaction or batch of writes, inclusive. */
export const firestoreOperationsLimit = 499;

/** Wraps {@link Firestore} operations, allowing transactions and typed collections. */
export class FirestoreGateway {
  readonly #firestore: Firestore;

  constructor(firestore: Firestore) {
    this.#firestore = firestore;
  }

  /** Current transaction, if there is an ongoing {@link FirestoreGateway.runTransaction}. */
  #transaction: Transaction | null = null;

  /** `true` if there is an ongoing {@link FirestoreGateway.runTransaction}. */
  get hasOngoingTransaction(): boolean {
    return this.#transaction != null;
  }

  /** Creates a {@link CollectionReferece} to the collection at {@link collectionPath}. */
  #collection(collectionPath: FirestorePaths): CollectionReferece {
    return this.#firestore.collection(collectionPath);
  }

  /** Creates a {@link CollectionGroup} of all collections named {@link collectionName}. */
  #collectionGroup(collectionName: FirestorePaths): CollectionGroup {
    return this.#firestore.collectionGroup(collectionName);
  }

  /**
   * Get all documents stored in the collection named {@link name}.
   *
   * A collection subgroup fetches all `Firestore` collections that use the same {@link name}.
   *
   * The return can be empty if there were no documents found for such collection {@link name} using the passed
   * {@link filters}.
   */
  getCollectionGroup(name: FirestorePaths, filters: QueryFilter[] = []): Promise<DocumentData[]> {
    return this.#getQuery(this.#collectionGroup(name), filters);
  }

  /**
   * Get all documents stored in collection {@link path}.
   *
   * The return can be empty if there were no documents found for such collection {@link path} using the passed
   * {@link filters}.
   */
  getCollection(path: FirestorePaths, filters: QueryFilter[] = []): Promise<DocumentData[]> {
    return this.#getQuery(this.#collection(path), filters);
  }

  /**
   * Get a document of {@link id} stored in {@link path}.
   *
   * Runs the operation on the current `#transaction`, if not null.
   *
   * @reject {FirebaseFirestoreError} Something went wrong with the request to `Firestore`.
   * @returns `null` if no such document was found.
   */
  async getDoc({ id, path }: { id: string; path: FirestorePaths }): Promise<DocumentData | null> {
    const documentPath = this.#collection(path).doc(id);

    try {
      const doc = await (this.#transaction?.get(documentPath) ?? documentPath.get());
      return doc.data() ?? null;
    } catch (error) {
      return Promise.reject(
        new FirebaseFirestoreError({
          message: `Failed to fetch document with id "${id}" from path "${path}"`,
          origin: error,
        })
      );
    }
  }

  /**
   * Create a document in {@link path}, using a raw {@link data}.
   *
   * If the passed {@link id} is `null`, generate a unique id for this document.
   *
   * The operation will fail if a document already exists at the specified location.
   *
   * Runs the operation on the current `#transaction`, if not null.
   *
   * @reject {FirebaseFirestoreError} Something went wrong with the request to `Firestore`.
   */
  async createDoc({
    id,
    path,
    data,
  }: {
    id?: string;
    path: FirestorePaths;
    data: Record<string, unknown>;
  }): Promise<void> {
    const formattedObject = JSON.parse(JSON.stringify(data));
    const documentRef = id !== undefined ? this.#collection(path).doc(id) : this.#collection(path).doc();

    try {
      await (this.#transaction?.create(documentRef, formattedObject) ?? documentRef.create(formattedObject));
    } catch (error) {
      return Promise.reject(
        new FirebaseFirestoreError({
          message: `Failed to create document with id "${id}" in path "${path}"`,
          origin: error,
        })
      );
    }
  }

  /**
   * Set a document in {@link path}, using a raw {@link data}.
   *
   * If the document doesn't yet exist, it will be created. Existing properties will be replaced.
   *
   * Runs the operation on the current `#transaction`, if not null.
   *
   * @reject {FirebaseFirestoreError} Something went wrong with the request to `Firestore`.
   */
  async setDoc({ id, path, data }: { id: string; path: FirestorePaths; data: Record<string, unknown> }): Promise<void> {
    const formattedObject = JSON.parse(JSON.stringify(data));
    const documentRef = this.#collection(path).doc(id);

    try {
      await (this.#transaction?.set(documentRef, formattedObject) ?? documentRef.set(formattedObject));
    } catch (error) {
      return Promise.reject(
        new FirebaseFirestoreError({
          message: `Failed to set document with id "${id}" in path "${path}"`,
          origin: error,
        })
      );
    }
  }

  /**
   * Update a document of {@link id} in {@link path}, using a raw {@link data}.
   *
   * The operation will fail if a document doesn't exist at the specified location.
   *
   * Runs the operation on the current `#transaction`, if not null.
   *
   * @reject {FirebaseFirestoreError} Something went wrong with the request to `Firestore`.
   */
  async updateDoc({
    id,
    path,
    data,
  }: {
    id: string;
    path: FirestorePaths;
    data: Record<string, unknown>;
  }): Promise<void> {
    try {
      const formattedObject = JSON.parse(JSON.stringify(data));
      const documentRef = this.#collection(path).doc(id);
      await (this.#transaction?.update(documentRef, formattedObject) ?? documentRef.update(formattedObject));
    } catch (error) {
      return Promise.reject(
        new FirebaseFirestoreError({
          message: `Failed to update the document with id "${id}" in path "${path}"`,
          origin: error,
        })
      );
    }
  }

  /**
   * Delete a document of {@link id} in {@link path}.
   *
   * The operation will succeed even if there was no document to be deleted.
   *
   * Runs the operation on the current `#transaction`, if not null.
   *
   * @reject {FirebaseFirestoreError} Something went wrong with the request to `Firestore`.
   */
  async deleteDoc({ id, path }: { id: string; path: FirestorePaths }): Promise<void> {
    const documentRef = this.#collection(path).doc(id);

    try {
      await (this.#transaction?.delete(documentRef) ?? documentRef.delete());
    } catch (error) {
      return Promise.reject(
        new FirebaseFirestoreError({
          message: `Failed to delete the document with id "${id}" in path "${path}"`,
          origin: error,
        })
      );
    }
  }

  /**
   * Delete a document of {@link id} in {@link path}, as well as all of subcollections.
   *
   * The operation will succeed even if there was no document to be deleted.
   *
   * Recursive deletes can't be ran on transactions.
   *
   * @reject {FirebaseFirestoreError} Something went wrong with the request to `Firestore`.
   */
  async deleteDocRecursively({ id, path }: { id: string; path: FirestorePaths }): Promise<void> {
    const documentRef = this.#collection(path).doc(id);

    try {
      await this.#firestore.recursiveDelete(documentRef);
    } catch (error) {
      return Promise.reject(
        new FirebaseFirestoreError({
          message: `Failed to recursively delete the document with id "${id}" in path "${path}"`,
          origin: error,
        })
      );
    }
  }

  /**
   * Create a transaction {@link context} where all read/write operations are executed atomically.
   *
   * All operations executed in {@link context} will run on the same transaction.
   *
   * The transaction has some limitations, such as operation support at most {@link firestoreOperationsLimit} operations
   * (counting both read and write).
   *
   * @see {@link https://firebase.google.com/docs/firestore/manage-data/transactions#transaction_failure}
   *
   * @reject {FirebaseFirestoreError} Something went wrong with the request to `Firestore`.
   */
  async runTransaction<T>(context: () => Promise<T>): Promise<T> {
    const run = async (transaction: Transaction): Promise<T> => {
      this.#transaction = transaction;
      const result = await context();
      this.#transaction = null;
      return result;
    };

    try {
      const result = await this.#firestore.runTransaction(run);
      return result;
    } catch (error) {
      this.#transaction = null;

      return Promise.reject(
        new FirebaseFirestoreError({
          message: "Failed to run a transaction",
          origin: error,
        })
      );
    }
  }

  /**
   * Runs a get operation on top of a {@link query}, applying {@link filters} if available.
   *
   * Runs the operation on the current `#transaction`, if not null.
   *
   * @reject {FirebaseFirestoreError} Something went wrong with the request to `Firestore`.
   */
  async #getQuery(query: Query, filters: QueryFilter[] = []): Promise<DocumentData[]> {
    let filteredQuery = query;
    filters.forEach((filter) => (filteredQuery = filteredQuery.where(filter.field, filter.comparison, filter.value)));

    try {
      const result = await (this.#transaction?.get(filteredQuery) ?? filteredQuery.get());
      return result.docs.map((doc: DocumentSnapshot) => doc.data()!);
    } catch (error) {
      return Promise.reject(
        new FirebaseFirestoreError({
          message: `Failed to get documents from collection (or subcollection) of reference "${filteredQuery}"`,
          origin: error,
        })
      );
    }
  }
}
