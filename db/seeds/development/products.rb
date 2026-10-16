# Products and SKUs for trying the product screens locally.
# Each entry is [code prefix, name, status, tax_rate, description, skus]; a SKU is [size, color, price_yen, stock_quantity].
products = [
  [ "TS-ORG", "オーガニックコットン T シャツ", :on_sale, :standard, "厚手の綿 100% の T シャツ。", [
    [ "S", "ホワイト", 3_300, 12 ], [ "M", "ホワイト", 3_300, 30 ], [ "L", "ホワイト", 3_300, 8 ],
    [ "S", "ネイビー", 3_300, 0 ], [ "M", "ネイビー", 3_300, 21 ], [ "L", "ネイビー", 3_300, 5 ]
  ] ],
  [ "SNK-RUN", "ランニングシューズ", :on_sale, :standard, "軽量のクッションソール。", [
    [ "25.0cm", "ブラック", 12_980, 4 ], [ "26.0cm", "ブラック", 12_980, 9 ], [ "27.0cm", "ブラック", 12_980, 2 ]
  ] ],
  [ "TEA-GRN", "有機緑茶 100g", :on_sale, :reduced, "静岡県産の一番茶。", [
    [ nil, nil, 1_080, 120 ]
  ] ],
  [ "CF-BLD", "コーヒー豆 ブレンド", :on_sale, :reduced, "中深煎り。挽き方は豆のまま。", [
    [ "200g", nil, 1_620, 40 ], [ "500g", nil, 3_780, 15 ]
  ] ],
  [ "MUG-STD", "マグカップ", :draft, :standard, "来月から販売予定。", [
    [ nil, "ベージュ", 2_200, 0 ]
  ] ],
  [ "TOTE-OLD", "キャンバストート（旧型）", :discontinued, :standard, nil, [] ]
]

products.each do |prefix, name, status, tax_rate, description, skus|
  product = Product.find_or_create_by!(name: name) do |record|
    record.status = status
    record.tax_rate = tax_rate
    record.description = description
  end

  skus.each_with_index do |(size, color, price_yen, stock_quantity), index|
    product.skus.find_or_create_by!(code: format("%s-%02d", prefix, index + 1)) do |sku|
      sku.assign_attributes(size: size, color: color, price_yen: price_yen, stock_quantity: stock_quantity)
    end
  end
end
