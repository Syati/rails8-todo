import "@typespec/http";
import "./common.tsp";
import "./skus.tsp";

using Http;

namespace ShopApi.V1.Products;

/** 販売状態。`draft`：下書き、`on_sale`：販売中、`discontinued`：販売終了。 */
enum Status {
  draft,
  on_sale,
  discontinued,
}

/** 消費税率。`standard`：標準税率 10%、`reduced`：軽減税率 8%（飲食料品）。 */
enum TaxRate {
  standard,
  reduced,
}

/** 商品。サイズや色の違いは SKU として持つ。 */
model Product {
  id: int64;

  /** 商品名。 */
  name: string;

  /** 商品説明。 */
  description: string | null;

  status: Status;
  tax_rate: TaxRate;

  /** SKU（id 順）。 */
  skus: Skus.Sku[];

  created_at: utcDateTime;
  updated_at: utcDateTime;
}

/** 商品の一覧。 */
model ListResponse {
  products: Product[];
  pagination: Pagination;
}

/** 商品の登録。SKU も同時に登録できる。 */
model CreateRequest {
  /** 商品名。 */
  @minLength(1)
  @maxLength(100)
  name: string;

  /** 商品説明。 */
  @maxLength(2000)
  description?: string | null;

  /** 省略すると `draft`。 */
  status?: Status;

  /** 省略すると `standard`。 */
  tax_rate?: TaxRate;

  /** 同時に登録する SKU。コードと、サイズと色の組み合わせは重複できない。 */
  @maxItems(50)
  skus?: Skus.CreateRequest[];
}

/** 商品の更新。送った項目だけを変える。 */
model UpdateRequest {
  /** 商品名。 */
  @minLength(1)
  @maxLength(100)
  name?: string;

  /** 商品説明。`null` で消す。 */
  @maxLength(2000)
  description?: string | null;

  status?: Status;
  tax_rate?: TaxRate;
}

@route("/api/v1/products")
@tag("商品")
interface Products {
  /** 商品の一覧を id の降順で返す。 */
  @get
  @summary("商品の一覧")
  list(
    /** 商品名の部分一致。 */
    @query q?: string,

    /** 販売状態（複数指定できる）。 */
    @query(#{ name: "status[]", explode: true }) status?: Status[],

    /** ページ（1 始まり）。 */
    @query @minValue(1) page?: int32 = 1,

    /** 1 ページの件数。 */
    @query @minValue(1) @maxValue(100) per_page?: int32 = 30,
  ): ListResponse | UnauthorizedError | ForbiddenError | ValidationError;

  /** 商品と SKU を返す。 */
  @get
  @summary("商品の詳細")
  read(@path id: int64): Product | UnauthorizedError | ForbiddenError | NotFoundError;

  /** 商品を登録する。`skus` を送ると SKU も同時に登録し、どれか 1 つでも不正なら何も登録しない。 */
  @post
  @summary("商品の登録")
  create(
    @header contentType: "application/json",
    @body body: CreateRequest,
  ): {
    @statusCode _: 201;
    @body body: Product;
  } | UnauthorizedError | ForbiddenError | UnsupportedMediaTypeError | ValidationError;

  /** 商品を更新する。SKU は SKU の API で変える。 */
  @patch(#{ implicitOptionality: false })
  @summary("商品の更新")
  update(
    @path id: int64,
    @header contentType: "application/json",
    @body body: UpdateRequest,
  ): Product | UnauthorizedError | ForbiddenError | NotFoundError | UnsupportedMediaTypeError | ValidationError;

  /** 商品を SKU ごと削除する。 */
  @delete
  @summary("商品の削除")
  delete(@path id: int64): NoContentResponse | UnauthorizedError | ForbiddenError | NotFoundError;
}
