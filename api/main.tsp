import "@typespec/http";
import "@typespec/openapi";
import "./v1/common.tsp";
import "./v1/products.tsp";
import "./v1/skus.tsp";

using Http;

/**
 * EC 受注管理システムの管理画面（Next.js）が呼ぶ JSON API。
 *
 * 認証は Rails の管理画面と同じ Devise のセッション cookie を使う。先に `/auth/sign_in` でログインしておくこと。
 * 書き込み系のリクエストは `Content-Type: application/json` で送る。
 */
@service(#{ title: "EC 受注管理 API" })
@OpenAPI.info(#{ version: "1.0.0" })
@server("/", "このサーバー（同一オリジン）")
@useAuth(SessionCookieAuth)
namespace ShopApi;

model SessionCookieAuth is ApiKeyAuth<ApiKeyLocation.cookie, "_rails8_todo_session">;
