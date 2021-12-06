export function newRawResource(props?: { type?: string; url?: string; description?: string }): any {
  return {
    type: props?.type ?? "article",
    url: props?.url ?? "https://validUri.com",
    description: props?.description ?? "description",
  };
}

export function newRawContributor(props?: { name?: string; url?: string; avatarUrl?: string }): any {
  return {
    name: props?.name ?? "name",
    url: props?.url ?? "https://validUri.com",
    avatarUrl: props?.avatarUrl ?? "https://validUri.com",
  };
}

export function newRawStoredCollection(): any {
  return {
    id: "any",
    name: "name",
    tags: ["Tag 1", "Tag 2"],
    category: "Collection Category",
    description: "Collection Description",
    locale: "ptBR",
    contributors: [newRawContributor()],
    resources: [newRawResource()],
    memosAmount: 3,
    memosOrder: ["id1", "id2", "id3"],
  };
}

export function newRawMemo(props?: { id?: string; question?: any[]; answer?: any[] }): any {
  return {
    id: props?.id ?? "any",
    question: props?.question ?? [{ insert: "content" }],
    answer: props?.answer ?? [{ insert: "content" }],
  };
}

export function newRawLocalCollection(): any {
  return {
    id: "any",
    name: "name",
    tags: ["Tag 1", "Tag 2"],
    category: "Collection Category",
    description: "Collection Description",
    locale: "ptBR",
    contributors: [newRawContributor()],
    resources: [newRawResource()],
    memos: [newRawMemo()],
  };
}
