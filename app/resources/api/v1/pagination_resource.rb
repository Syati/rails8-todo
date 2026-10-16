# V1.Pagination in api/openapi.yaml, built from a Pagy object.
class Api::V1::PaginationResource
  include Alba::Resource

  attributes :page, :count, :pages
  attribute(:per_page, &:limit)
end
