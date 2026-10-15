# Each environment has an entry file, db/seeds/<Rails.env>.rb, that loads its seeds in order.
# Seeds must be idempotent so that bin/rails db:seed can run any number of times.
entry = Rails.root.join("db/seeds/#{Rails.env}.rb")
load entry if entry.exist?
