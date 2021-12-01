import axios from "axios";
import HttpException from "@faults/exceptions/http-exception";

export interface HttpResponse {
  baseUrl: string;
  url: string;
  status: number;
  method: string;
  data?: unknown;
  headers?: unknown;
}

enum HttpMethod {
  get = "GET",
  post = "POST",
  put = "PUT",
  delete = "DELETE",
}

export interface RequestParams {
  baseUrl: string;
  path: string;
  parameters?: Record<string, string>;
  headers?: Record<string, string>;
  data?: unknown;
}

export interface HttpRequest extends RequestParams {
  method: string;
}

/** Exposes common Http request methods. */
export class HttpClientGateway {
  /** Callback triggered on every request. */
  static onRequest?: (request: HttpRequest) => void;

  /** Callback triggered on every response. */
  static onResponse?: (response: HttpResponse) => void;

  private static readonly DEFAULT_HEADERS = {
    "Accept-Encoding": "gzip, deflate, br",
  };

  get(params: RequestParams): Promise<HttpResponse> {
    return this.request(HttpMethod.get, params);
  }

  post(params: RequestParams): Promise<HttpResponse> {
    return this.request(HttpMethod.post, params);
  }

  put(params: RequestParams): Promise<HttpResponse> {
    return this.request(HttpMethod.get, params);
  }

  protected async request(method: HttpMethod, params: RequestParams): Promise<HttpResponse> {
    const { baseUrl, path, headers, parameters, data } = params;
    const requestConfig = {
      baseURL: baseUrl,
      method: method,
      url: path,
      headers: {
        ...HttpClientGateway.DEFAULT_HEADERS,
        ...headers,
      },
      params: parameters,
      data: data,
    };

    HttpClientGateway.onRequest?.({ ...params, baseUrl: requestConfig.baseURL, method: method });

    return axios
      .request(requestConfig)
      .then((response) => {
        const formattedResponse = {
          baseUrl: baseUrl,
          url: requestConfig.url,
          status: response.status,
          method: method,
          data: response.data,
          headers: response.headers,
        };

        HttpClientGateway.onResponse?.(formattedResponse);

        if (response.status >= 200 && response.status < 400) {
          return formattedResponse;
        } else {
          throw new HttpException({
            message: `Failed to perform ${method} ${baseUrl}${path}. AxiosResponse: ${response}`,
          });
        }
      })
      .catch((error) => {
        throw new HttpException({
          message: `Failed to perform ${method} ${baseUrl}${path}.`,
          origin: error,
        });
      });
  }
}
