import { HttpClientGateway } from "@data/gateways/http-client-gateway";
import { Env } from "@data/gateways/env";

class _Endpoints {
  static tags = "/git/refs/tags";
  static releases = "/releases";
}

export class GitRepository {
  readonly #httpGateway: HttpClientGateway;
  readonly #env: Env;
  readonly #GITHUB_API_URL = "https://api.github.com/repos/olmps/memo";
  readonly #DEFAULT_HEADERS = { "User-Agent": "GitRepository" };

  constructor(httpGateway: HttpClientGateway, env: Env) {
    this.#httpGateway = httpGateway;
    this.#env = env;
  }

  async getTagSha(tag: string): Promise<string> {
    const rawResponse = await this.#httpGateway.get({
      baseUrl: this.#GITHUB_API_URL,
      path: _Endpoints.tags,
      headers: this.#authenticatedHeaders(this.#DEFAULT_HEADERS),
    });

    const rawTagsRefs = rawResponse.data as GitTags[];
    const filteredTags = rawTagsRefs.filter((tagRef) => tagRef.ref === `refs/tags/${tag}`);

    return filteredTags[0]!.object.sha;
  }

  async getReleases(): Promise<GithubRelease[]> {
    const rawResponse = await this.#httpGateway.get({
      baseUrl: this.#GITHUB_API_URL,
      path: _Endpoints.releases,
      headers: this.#authenticatedHeaders(this.#DEFAULT_HEADERS),
    });

    const rawReleaseTags = rawResponse.data as GitRelease[];
    return rawReleaseTags.map((release) => ({
      tagName: release.tag_name,
      prerelease: release.prerelease,
    }));
  }

  #authenticatedHeaders(headers?: Record<string, string>): Record<string, string> {
    const encodedAuth = Buffer.from(`${this.#env.gitUsername}:${this.#env.gitPassword}`, "binary").toString("base64");
    return { ...headers, Authorization: encodedAuth };
  }
}

interface GitTags {
  ref: string;
  object: {
    sha: string;
  };
}

interface GitRelease {
  tag_name: string;
  prerelease: boolean;
}

interface GithubRelease {
  /** The release associated tag. */
  tagName: string;
  /** `true` if the release is market as a pre-release. */
  prerelease: boolean;
}
