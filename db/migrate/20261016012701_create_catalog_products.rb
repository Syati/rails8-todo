class CreateCatalogProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :catalog_products do |t|
      t.string :name, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.integer :tax_rate, null: false, default: 10

      t.timestamps
    end
    add_index :catalog_products, :status
  end
end
