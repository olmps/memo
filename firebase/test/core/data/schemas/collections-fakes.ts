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

export function newRawMemoContent(props?: { insert?: string }): any {
  return {
    insert: props?.insert ?? "content",
  };
}

export function newRawMemo(props?: { id?: string; question?: any[]; answer?: any[] }): any {
  return {
    id: props?.id ?? "any",
    question: props?.question ?? [newRawMemoContent()],
    answer: props?.answer ?? [newRawMemoContent()],
  };
}

export function newRawPublicCollection(): any {
  return {
    id: "any",
    name: "name",
    tags: ["Tag 1", "Tag 2"],
    category: "Collection Category",
    description: "Collection Description",
    locale: "ptBR",
    contributors: [newRawContributor()],
    resources: [newRawResource()],
  };
}

export function newRawLocalCollection(): any {
  return {
    ...newRawPublicCollection(),
    memos: [newRawMemo()],
  };
}

export function newRawStoredCollection(): any {
  return {
    ...newRawPublicCollection(),
    memosAmount: 3,
    memosOrder: ["id1", "id2", "id3"],
  };
}