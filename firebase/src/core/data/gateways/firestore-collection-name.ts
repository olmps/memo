/** Typed firestore collections paths. */
export type FirestorePaths = PublicPaths | UsersPaths;

/** Raw string that represent any collection's document id. */
type Id = string;

/** Public collections available to all authenticated users. */
type PublicPaths = PublicCollectionsPaths | "collection_categories";

/** Collection-related paths (the entity, not the Firestore one) paths, available to all authenticated users. */
type PublicCollectionsPaths = "collections" | `collections/${Id}/memos`;

/** User-related collection paths, which are available to the respective authenticated users. */
type UsersPaths =
  | `users/${Id}/collections`
  | `users/${Id}/collections/${Id}/memos`
  | `users/${Id}/collection_categories`
  | `users/${Id}/collection_executions`
  | `users/${Id}/collection_executions/${Id}/memo_executions`;
