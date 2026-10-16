class CreateSkus < ActiveRecord::Migration[8.1]
  def change
    create_table :skus do |t|
      # The unique index on product_id, size and color also serves lookups by product_id.
      t.references :product, null: false, foreign_key: true, index: false
      t.string :code, null: false
      t.string :size
      t.string :color
      t.integer :price_yen, null: false
      t.integer :stock_quantity, null: false, default: 0

      t.timestamps
    end
    add_index :skus, :code, unique: true
    # NULLS NOT DISTINCT so that a product has at most one SKU without size and color.
    add_index :skus, %i[product_id size color], unique: true, nulls_not_distinct: true
    add_check_constraint :skus, "price_yen >= 0", name: "skus_price_yen_non_negative"
    add_check_constraint :skus, "stock_quantity >= 0", name: "skus_stock_quantity_non_negative"
  end
end
