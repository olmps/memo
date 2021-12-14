import * as faker from "faker";
import { CollectionResourceType, StoredPublicCollection } from "#domain/models/collection";
import Provider from "#presentation/provider";
import { Memo } from "#domain/models/memo";
import { CollectionExecution, User } from "#domain/models/user";

const firestoreGateway = Provider.instance.firestoreGateway;

async function runScript(): Promise<void> {
  try {
    await createFakeCollections("");
    const fakeUsers = await createUsers();

    for (const fakeUser of fakeUsers) {
      const fakeUserCollections = await createFakeCollections(`users/${fakeUser.id}/`);
      const fakeUserCollectionsIds = fakeUserCollections.map((collection) => collection.id);
      await createExecutions(fakeUser.id, fakeUserCollectionsIds);
    }
  } catch (error) {
    console.dir(error, { depth: null, colors: true });
  }
}

async function createFakeCollections(basePath: string): Promise<StoredPublicCollection[]> {
  const createdCollections: StoredPublicCollection[] = [];

  for (const _ of Array.from(Array(20).keys())) {
    const collectionId = faker.datatype.uuid();

    const fakeMemos: Memo[] = Array.from(Array(20).keys()).map(() => ({
      id: faker.datatype.uuid(),
      // TODO(ggirotto)
      question: [],
      // TODO(ggirotto)
      answer: [],
    }));
    const fakeMemosPromises = fakeMemos.map((memo) =>
      firestoreGateway.createDoc({
        id: memo.id,
        path: <any>`${basePath}collections/${collectionId}/memos`,
        data: <any>memo,
      })
    );

    const fakeCollection: StoredPublicCollection = {
      id: collectionId,
      name: faker.name.findName(),
      category: faker.company.companyName(),
      description: faker.lorem.word(2000),
      tags: Array.from(Array(3).keys()).map(() => faker.vehicle.model()),
      contributors: Array.from(Array(5).keys()).map(() => ({
        name: faker.name.findName(),
        avatarUrl: faker.image.cats(),
        url: "www.google.com",
      })),
      memosAmount: fakeMemos.length,
      memosOrder: fakeMemos.map((memo) => memo.id),
      resources: Array.from(Array(5).keys()).map(() => ({
        description: faker.lorem.word(500),
        url: "www.google.com",
        type: faker.random.arrayElement([
          CollectionResourceType.article,
          CollectionResourceType.book,
          CollectionResourceType.video,
          CollectionResourceType.game,
          CollectionResourceType.other,
        ]),
      })),
    };

    const fakeCategory = {
      id: faker.datatype.uuid(),
      name: fakeCollection.category,
    };

    await Promise.all([
      firestoreGateway.createDoc({
        id: fakeCollection.id,
        path: <any>`${basePath}collections`,
        data: <any>fakeCollection,
      }),
      ...fakeMemosPromises,
      firestoreGateway.createDoc({
        id: fakeCategory.id,
        path: <any>`${basePath}collection_categories`,
        data: <any>fakeCategory,
      }),
    ]);

    createdCollections.push(fakeCollection);
  }

  return createdCollections;
}

async function createUsers(): Promise<User[]> {
  const createdUsers: User[] = [];

  for (const _ of Array.from(Array(20).keys())) {
    const fakeUser: User = {
      id: faker.datatype.uuid(),
      executionChunk: faker.datatype.number(),
      timeSpentInMillis: faker.datatype.number({ min: 50000000, max: 50000000000 }),
      executionsDifficulty: new Map<string, number>([
        ["easy", faker.datatype.number({ min: 3, max: 150 })],
        ["medium", faker.datatype.number({ min: 3, max: 150 })],
        ["hard", faker.datatype.number({ min: 3, max: 150 })],
      ]),
    };

    await firestoreGateway.createDoc({ id: fakeUser.id, path: "users", data: <any>fakeUser });

    createdUsers.push(fakeUser);
  }

  return createdUsers;
}

async function createExecutions(userId: string, collectionsIds: string[]): Promise<CollectionExecution[]> {
  const createdExecutions: CollectionExecution[] = [];

  for (const collectionId of collectionsIds) {
    const executionsAmount = faker.datatype.number({ min: 0, max: 20 });
    const executions = Array.from(Array(executionsAmount).keys()).map(() => ({
      id: faker.datatype.uuid(),
      totalExecutions: executionsAmount,
      lastExecution: faker.datatype.datetime(),
      lastMarkedDifficulty: faker.random.arrayElement(["easy", "medium", "hard"]),
    }));

    const fakeExecution: CollectionExecution = {
      id: collectionId,
      executionsAmount: executionsAmount,
      uniqueExecutionsAmount: faker.datatype.number({ min: 0, max: 20 }),
      executions: new Map<string, any>(executions.map((execution) => [execution.id, execution])),
      timeSpentInMillis: faker.datatype.number({ min: 50000000, max: 50000000000 }),
      executionsDifficulty: new Map<string, number>([
        ["easy", Math.round(executionsAmount / 3)],
        ["medium", Math.round(executionsAmount / 3)],
        ["hard", executionsAmount - Math.round(executionsAmount / 3) * 2],
      ]),
      memoExecutions: [], // TODO(ggirotto)
    };

    await firestoreGateway.createDoc({
      id: collectionId,
      path: `users/${userId}/collection_executions`,
      data: <any>fakeExecution,
    });

    createdExecutions.push(fakeExecution);
  }

  return createdExecutions;
}

runScript().finally(() => {
  process.exit(0);
});
