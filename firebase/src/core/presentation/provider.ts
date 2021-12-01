import Ajv2020 from "ajv/dist/2020";
import { FirestoreGateway } from "@data/gateways/firestore-gateway";
import { FileSystemGateway } from "@data/gateways/filesystem-gateway";
import { StoredCollectionsRepository } from "@data/repositories/stored-collections-repository";
import { SchemaValidator } from "@data/schemas/schema-validator";
import { LocalCollectionsRepository } from "@data/repositories/local-collections-repository";
import { MemosRepository } from "@data/repositories/memos-repository";
import { app } from "@data/gateways/firebase-app";
import { ShellGateway } from "@data/gateways/shell-gateway";
import { GitRepository } from "@data/repositories/git-repository";

/**
 * Singleton that provides all injectable dependencies, which should be used as a pseudo-DI container.
 *
 * All dependencies are lazily initialized - subsequent calls to the same dependency will return a cached instance.
 */
export default class Provider {
  static #instance?: Provider;

  /** Exposed instance of this Singleton. */
  static get instance(): Provider {
    this.#instance ??= new Provider();
    return this.#instance;
  }

  // eslint-disable-next-line @typescript-eslint/no-empty-function
  private constructor() {}

  //
  // Third Parties
  //
  #firestore?: FirebaseFirestore.Firestore;

  get firestore(): FirebaseFirestore.Firestore {
    this.#firestore ??= app.firestore();
    return this.#firestore;
  }

  //
  // Gateways
  //
  #firestoreGateway?: FirestoreGateway;
  #fileSystemGateway?: FileSystemGateway;
  #schemaValidator?: SchemaValidator;
  #shellGateway?: ShellGateway;

  get firestoreGateway(): FirestoreGateway {
    this.#firestoreGateway ??= new FirestoreGateway(this.firestore);
    return this.#firestoreGateway;
  }

  get fileSystemGateway(): FileSystemGateway {
    this.#fileSystemGateway ??= new FileSystemGateway();
    return this.#fileSystemGateway;
  }

  get schemaValidator(): SchemaValidator {
    this.#schemaValidator ??= new SchemaValidator(new Ajv2020());
    return this.#schemaValidator;
  }

  get shellGateway(): ShellGateway {
    this.#shellGateway ??= new ShellGateway();
    return this.#shellGateway;
  }

  //
  // Repositories
  //
  #localCollectionsRepository?: LocalCollectionsRepository;
  #storedCollectionsRepository?: StoredCollectionsRepository;
  #memosRepository?: MemosRepository;
  #gitRepository?: GitRepository;

  localCollectionsRepository(collectionsDir: string): LocalCollectionsRepository {
    this.#localCollectionsRepository ??= new LocalCollectionsRepository(
      this.fileSystemGateway,
      this.schemaValidator,
      collectionsDir
    );
    return this.#localCollectionsRepository;
  }

  get storedCollectionsRepository(): StoredCollectionsRepository {
    this.#storedCollectionsRepository ??= new StoredCollectionsRepository(this.firestoreGateway, this.schemaValidator);
    return this.#storedCollectionsRepository;
  }

  get memosRepository(): MemosRepository {
    this.#memosRepository ??= new MemosRepository(this.firestoreGateway, this.schemaValidator);
    return this.#memosRepository;
  }

  get gitRepository(): GitRepository {
    this.#gitRepository ??= new GitRepository(this.shellGateway);
    return this.#gitRepository;
  }
}
