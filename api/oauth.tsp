import "@typespec/http";

using Http;

/** Doorkeeper のトークンエンドポイント。API のバージョンとは別に `/oauth` にある。 */
namespace ShopApi.OAuth;

/** トークンの発行（client credentials）。 */
model TokenRequest {
  grant_type: "client_credentials";

  /** `/oauth/applications` で発行したクライアント ID。 */
  client_id: string;

  /** 登録直後に一度だけ表示した secret。 */
  client_secret: string;

  /** スペース区切りのスコープ。省略すると `read`。クライアントに登録したスコープの範囲で指定する。 */
  scope?: string;
}

/** 発行したトークン。 */
model TokenResponse {
  access_token: string;
  token_type: "Bearer";

  /** 有効期限（秒）。 */
  expires_in: int32;

  /** スペース区切りのスコープ。 */
  scope: string;

  /** 発行日時（UNIX 秒）。 */
  created_at: int64;
}

/** RFC 6749 のエラー。 */
model TokenErrorBody {
  /** `invalid_request`、`unsupported_grant_type`、`invalid_scope` など。 */
  error: string;

  error_description?: string;
}

/** リクエストの形やスコープが正しくない。 */
@error
model BadRequestError {
  @statusCode _: 400;
  ...TokenErrorBody;
}

/** クライアント ID か secret が正しくない（`invalid_client`）。 */
@error
model InvalidClientError {
  @statusCode _: 401;
  ...TokenErrorBody;
}

@route("/oauth/token")
@tag("認証")
interface Tokens {
  /** client credentials でアクセストークンを発行する。 */
  @post
  @summary("トークンの発行")
  @useAuth(NoAuth)
  create(
    @header contentType: "application/x-www-form-urlencoded",
    @body body: TokenRequest,
  ): TokenResponse | BadRequestError | InvalidClientError;
}
