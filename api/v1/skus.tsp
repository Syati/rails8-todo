import "@typespec/http";
import "./common.tsp";

using Http;

namespace ShopApi.V1.Skus;

/** SKU（在庫を管理する単位）。商品のサイズと色の組み合わせごとに 1 つ。 */
model Sku {
  id: int64;

  /** SKU コード。大文字の英数字とハイフン。 */
  code: string;

  size: string | null;
  color: string | null;

  /** 税込みの販売価格（円）。 */
  price_yen: int32;

  /** 在庫数。 */
  stock_quantity: int32;
}

/** SKU の登録。商品の登録時に `skus` の要素としても使う。 */
model CreateRequest {
  /** SKU コード。英数字とハイフンで、小文字は大文字に直して保存する。 */
  @minLength(1)
  @maxLength(50)
  @pattern("^[A-Za-z0-9][A-Za-z0-9-]*$")
  code: string;

  /** サイズ。サイズがない商品は省略する。 */
  @maxLength(30)
  size?: string | null;

  /** 色。色がない商品は省略する。 */
  @maxLength(30)
  color?: string | null;

  /** 税込みの販売価格（円）。 */
  @minValue(0)
  @maxValue(10000000)
  price_yen: int32;

  /** 在庫数。省略すると 0。 */
  @minValue(0)
  stock_quantity?: int32;
}

/** SKU の更新。送った項目だけを変える。 */
model UpdateRequest {
  @minLength(1)
  @maxLength(50)
  @pattern("^[A-Za-z0-9][A-Za-z0-9-]*$")
  code?: string;

  @maxLength(30)
  size?: string | null;

  @maxLength(30)
  color?: string | null;

  @minValue(0)
  @maxValue(10000000)
  price_yen?: int32;

  @minValue(0)
  stock_quantity?: int32;
}

@tag("SKU")
interface Skus {
  /** 商品に SKU を追加する。 */
  @post
  @route("/api/v1/products/{product_id}/skus")
  @summary("SKU の追加")
  create(
    @path product_id: int64,
    @header contentType: "application/json",
    @body body: CreateRequest,
  ): {
    @statusCode _: 201;
    @body body: Sku;
  } | UnauthorizedError | ForbiddenError | NotFoundError | UnsupportedMediaTypeError | ValidationError;

  /** SKU を更新する。 */
  @patch(#{ implicitOptionality: false })
  @route("/api/v1/skus/{id}")
  @summary("SKU の更新")
  update(
    @path id: int64,
    @header contentType: "application/json",
    @body body: UpdateRequest,
  ): Sku | UnauthorizedError | ForbiddenError | NotFoundError | UnsupportedMediaTypeError | ValidationError;

  /** SKU を削除する。 */
  @delete
  @route("/api/v1/skus/{id}")
  @summary("SKU の削除")
  delete(@path id: int64): NoContentResponse | UnauthorizedError | ForbiddenError | NotFoundError;
}
