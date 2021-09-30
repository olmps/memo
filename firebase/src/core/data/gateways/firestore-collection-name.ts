/** Typed firestore collections. */
export type FirestoreCollectionName =
  | PublicCollectionName
  | PublicSubCollectionName
  | UserCollectionName
  | UserSubCollectionName;

/** Public collections available to all authenticated users. */
type PublicCollectionName = "public_collections" | "public_collection_categories" | "public_memos";

/** Public subcollections available to all authenticated users. */
type PublicSubCollectionName = `public_collections/${string}/public_memos`;

type UserCollectionName = "users";

/** User-owned subcollections available to all respective authenticated users. */
type UserSubCollectionName =
  | `${UserCollectionName}/${string}/collections`
  | `${UserCollectionName}/${string}/collections/${string}/memos`
  | `${UserCollectionName}/${string}/collection_categories`
  | `${UserCollectionName}/${string}/collection_executions`
  | `${UserCollectionName}/${string}/collection_executions/${string}/memo_executions`;
