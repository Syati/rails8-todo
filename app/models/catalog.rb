# Products and SKUs: what the shop sells, at what price, and how many are in stock.
module Catalog
  def self.table_name_prefix
    "catalog_"
  end

  # Routes, form params and dom ids use "product" rather than "catalog_product".
  def self.use_relative_model_naming?
    true
  end
end
