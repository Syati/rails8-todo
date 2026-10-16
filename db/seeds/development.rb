# List seeds in load order: a seed must come after the seeds it depends on.
%w[
  admins
  products
  oauth_applications
].each do |name|
  load Rails.root.join("db/seeds/development/#{name}.rb")
end
