import "@typespec/http";
import "@typespec/openapi";
import "./v1/common.tsp";
import "./v1/products.tsp";
import "./v1/skus.tsp";

using Http;

/**
 * EC 受注管理システムの管理画面（Next.js）が呼ぶ JSON API。
 *
 * 認証は次のどちらか。
 *
 * - **セッション cookie**：管理画面（Next.js）とこのリファレンスの試し実行。`/auth/sign_in` でログインしておく。
 * - **OAuth 2 client credentials**：ほかのシステムから呼ぶとき。super_admin が `/oauth/applications` でクライアントを登録し、
 *   `POST /oauth/token`（`grant_type=client_credentials`）で取ったトークンを `Authorization: Bearer <token>` で送る。
 *   GET には `read`、登録・更新・削除には `write` のスコープが要る。トークンの有効期限は 2 時間。
 *
 * 書き込み系のリクエストは `Content-Type: application/json` で送る。
 */
@service(#{ title: "EC 受注管理 API" })
@OpenAPI.info(#{ version: "1.0.0" })
@server("/", "このサーバー（同一オリジン）")
@useAuth(SessionCookieAuth | ClientCredentialsAuth)
namespace ShopApi;

model SessionCookieAuth is ApiKeyAuth<ApiKeyLocation.cookie, "_rails8_todo_session">;

// OpenAPI requires an absolute tokenUrl. This is the local Traefik host; other environments
// use /oauth/token on their own host.
model ClientCredentialsAuth
  is OAuth2Auth<
    [
      {
        type: OAuth2FlowType.clientCredentials,
        tokenUrl: "https://todo.docker.localhost/oauth/token",
        scopes: ["read", "write"],
      }
    ]
  >;
