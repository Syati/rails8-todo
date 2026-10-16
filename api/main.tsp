import "@typespec/http";
import "@typespec/openapi";
import "./oauth.tsp";
import "./v1/common.tsp";
import "./v1/products.tsp";
import "./v1/skus.tsp";

using Http;

/**
 * EC 受注管理システムの JSON API。
 *
 * 認証は OAuth 2 の client credentials。super_admin が `/oauth/applications` でクライアントを登録し、
 * `POST /oauth/token` で取ったトークンを `Authorization: Bearer <token>` で送る。トークンの有効期限は 2 時間。
 *
 * スコープ（トークンを取るときの `scope`）：
 *
 * | スコープ | できること |
 * | --- | --- |
 * | `read` | GET（省略したときはこれだけ） |
 * | `write` | 登録・更新・削除 |
 *
 * トークンがなければ 401 `unauthorized`、無効・失効・期限切れは 401 `invalid_token`、スコープ不足は 403 `insufficient_scope`。
 *
 * 書き込み系のリクエストは `Content-Type: application/json` で送る。
 */
@service(#{ title: "EC 受注管理 API" })
@OpenAPI.info(#{ version: "1.0.0" })
@server("/", "このサーバー（同一オリジン）")
@useAuth(BearerAuth)
namespace ShopApi;
