const users = 'users';

const collections = 'collections';
String collectionsMemos({required String collectionId}) => '$collections/$collectionId/memos';

const collectionCategories = 'collection_categories';

String userCollections({required String userId}) => '$users/$userId/collections';
String userCollectionMemos({required String userId, required String collectionId}) =>
    '${userCollections(userId: userId)}/$collectionId/memos';

String userCollectionsExecutions({required String userId}) => '$users/$userId/collections_executions';
String userMemosExecutions({required String userId, required String collectionId}) =>
    '${userCollectionsExecutions(userId: userId)}/$collectionId/memos_executions';
