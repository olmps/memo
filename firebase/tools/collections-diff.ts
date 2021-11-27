/* eslint-disable @typescript-eslint/no-explicit-any */
import { exec } from "child_process";
import * as https from "https";

interface GithubRelease {
  /** The release associated tag. */
  tagName: string;
  /** `true` if the release is market as a pre-release. */
  prerelease: boolean;
}

interface UpdatedCollections {
  /** Identifiers from all collections that were added since last release. */
  added: string[];
  /** Identifiers from all collections that were updated since last release. */
  updated: string[];
  /** Identifiers from all collections that were removed since last release. */
  removed: string[];
}

/**
 * Compute and log in the console the updated (added, updated and removed) collections ids.
 *
 * This script assumes that the repository has at least two releases to be compared.
 *
 * It compares the updated collections between the current and the previous release tags.
 */
async function getCollectionsStatus(): Promise<UpdatedCollections> {
  const releases = await getReleases();
  const publishedReleases = releases.filter((release) => !release.prerelease);

  const currentRelease = publishedReleases[0];
  const lastPublishedRelease = publishedReleases[1];

  const currentReleaseTagSha = await getTagSha(currentRelease!.tagName);
  const lastPublishedTagSha = await getTagSha(lastPublishedRelease!.tagName);

  // Uses `git diff` to get all updated files between current and the last release and their status (added, modified,
  // deleted and renamed).
  const gitDiff = await runShell(`git diff --name-status ${lastPublishedTagSha} ${currentReleaseTagSha}`);
  const changedFiles: string[] = gitDiff.split("\n");

  // Filter by the files under `firebase/collections` directory.
  const changedCollections = changedFiles.filter((changedFile) => changedFile.includes("firebase/collections"));

  const addedCollections = changedCollections.filter((collectionFile) => collectionFile.startsWith("A"));
  const updatedCollections = changedCollections.filter((collectionFile) => collectionFile.startsWith("M"));
  const removedCollections = changedCollections.filter((collectionFile) => collectionFile.startsWith("D"));
  const renamedFiles = changedCollections.filter((collectionFile) => collectionFile.startsWith("R"));

  const addedCollectionsIds = addedCollections.map((collectionPath) =>
    collectionPath.substring(collectionPath.lastIndexOf("/") + 1, collectionPath.lastIndexOf(".json"))
  );
  const updatedCollectionsIds = updatedCollections.map((collectionPath) =>
    collectionPath.substring(collectionPath.lastIndexOf("/") + 1, collectionPath.lastIndexOf(".json"))
  );
  const removedCollectionsIds = removedCollections.map((collectionPath) =>
    collectionPath.substring(collectionPath.lastIndexOf("/") + 1, collectionPath.lastIndexOf(".json"))
  );

  // Regex that matches a name between `/` and `.json` bounds. Uses `g` global flag to match all occurrences instead
  // just the first one.
  const fileNameRegex = new RegExp(/[a-zA-Z0-9-+]+?(?=.json)/, "g");

  // Iterates through the renamed files adding the old collection file name to `removedCollectionsIds` and the new name
  // to `addedCollectionsIds`.
  for (const renamed of renamedFiles) {
    const removedFile = fileNameRegex.exec(renamed)![0]!;
    const addedFile = fileNameRegex.exec(renamed)![0]!;
    addedCollectionsIds.push(addedFile);
    removedCollectionsIds.push(removedFile);
  }

  return {
    added: addedCollectionsIds,
    updated: updatedCollectionsIds,
    removed: removedCollectionsIds,
  };
}

/** Returns the result of running {@link command} shell command. */
async function runShell(command: string): Promise<string> {
  return new Promise((resolve, reject) => {
    exec(command, (error, stdout, stderr) => {
      if (error) {
        reject(error);
      } else if (stderr) {
        reject(stderr);
      } else {
        resolve(stdout);
      }
    });
  });
}

/** Returns the SHA commit hash from tag {@link tag}. */
async function getTagSha(tag: string): Promise<string> {
  const rawResponse = await gitApiGet("/repos/olmps/memo/git/refs/tags");

  const rawTagsRefs = JSON.parse(rawResponse);
  const filteredTags = rawTagsRefs.filter((tagRef: any) => tagRef.ref === `refs/tags/${tag}`);

  if (filteredTags.length === 0) {
    throw `Couldn't find a tag with name ${tag}`;
  }

  return filteredTags[0].object.sha;
}

/** Get the list of all Github releases. */
async function getReleases(): Promise<GithubRelease[]> {
  const rawResponse = await gitApiGet("/repos/olmps/memo/releases");

  const rawReleaseTags = JSON.parse(rawResponse);
  return rawReleaseTags.map((rawRelease: any) => ({
    tagName: rawRelease.tag_name,
    prerelease: rawRelease.prerelease,
  }));
}

/** Perform an authenticated GET request to Github API. */
async function gitApiGet(path: string): Promise<string> {
  const options = {
    host: "api.github.com",
    path: path,
    // Required by Github API.
    headers: { "User-Agent": "request" },
    // Authorize the request to increase the number of requests per-hour.
    authorization: {
      username: process.env["MEMO_BOT_USERNAME"],
      password: process.env["ADMIN_TOKEN"],
    },
  };

  // Wraps Node.JS native `https` package into a Promise to let it be awaited using `async-await` syntax.
  return new Promise((resolve, reject) => {
    https.get(options, (res) => {
      let responseData = "";
      res.on("data", (chunk) => (responseData += chunk));
      res.on("error", (error) => reject(error));
      res.on("end", () => resolve(responseData));
    });
  });
}

getCollectionsStatus()
  .then((updatedCollections) => {
    console.log(JSON.stringify(updatedCollections));
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
