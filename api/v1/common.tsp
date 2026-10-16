import "@typespec/http";

using Http;

namespace ShopApi.V1;

/** ページ分割の情報。 */
model Pagination {
  /** 現在のページ（1 始まり）。 */
  page: int32;

  /** 1 ページの件数。 */
  per_page: int32;

  /** 全体の件数。 */
  count: int32;

  /** 全体のページ数。 */
  pages: int32;
}

/** ログインしていない、またはトークンが無効か期限切れ。 */
@error
model UnauthorizedError {
  @statusCode _: 401;
  error: string;
}

/** トークンのスコープが足りない（書き込みに `write` がない）。 */
@error
model ForbiddenError {
  @statusCode _: 403;
  error: string;
}

/** 対象のリソースがない。 */
@error
model NotFoundError {
  @statusCode _: 404;
  error: string;
}

/** `Content-Type: application/json` 以外で送った。 */
@error
model UnsupportedMediaTypeError {
  @statusCode _: 415;
  error: string;
}

/**
 * 入力が正しくない。`errors` は項目ごとのエラーメッセージで、ネストした項目と配列の要素は
 * object でたどる（例：`{"skus": {"0": {"code": ["を入力してください"]}}}`）。
 */
@error
model ValidationError {
  @statusCode _: 422;
  errors: Record<unknown>;
}

/** 削除に成功した。 */
model NoContentResponse {
  @statusCode _: 204;
}
