# == Schema Information
#
# Table name: catalog_products
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string           not null
#  status      :integer          default(0), not null
#  tax_rate    :integer          default(10), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_catalog_products_on_status  (status)
#
class Catalog::Product < ApplicationRecord
  has_many :skus, -> { order(:id) }, dependent: :destroy, inverse_of: :product, autosave: true, index_errors: true

  enum :status, { draft: 0, on_sale: 1, discontinued: 2 }, default: :draft, validate: true
  # Stored as the percentage itself. Food and drink use the 8% reduced rate.
  enum :tax_rate, { standard: 10, reduced: 8 }, default: :standard, validate: true

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 2000 }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name status]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
