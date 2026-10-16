module ProductsHelper
  def yen(amount)
    number_to_currency(amount, unit: "¥", precision: 0, format: "%u%n")
  end

  # "¥1,980" for one price, "¥1,980〜¥2,480" when SKUs differ, "-" without SKUs.
  def price_range(skus)
    prices = skus.map(&:price_yen)
    return "-" if prices.empty?

    min, max = prices.minmax
    min == max ? yen(min) : "#{yen(min)}〜#{yen(max)}"
  end
end
