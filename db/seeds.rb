# Seeds are split per environment under db/seeds/<Rails.env>/.
# Each file must be idempotent so that bin/rails db:seed can run any number of times.
Rails.root.glob("db/seeds/#{Rails.env}/*.rb").each do |file|
  Rails.logger.debug { "Seeding #{Pathname(file).relative_path_from(Rails.root)}" }
  load file
end
