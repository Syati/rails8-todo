namespace :admins do
  desc "Create or promote a super_admin, e.g. for a new environment. " \
       "Usage: bin/rails admins:bootstrap_super_admin EMAIL=... PASSWORD=..."
  task bootstrap_super_admin: :environment do
    email = ENV.fetch("EMAIL") { abort "EMAIL is required" }
    admin = Admin.find_or_initialize_by(email: email)
    abort "#{email} is deleted" if admin.discarded?

    # PASSWORD is only used when the admin does not exist yet, so a rerun never resets it.
    if admin.new_record?
      admin.password = admin.password_confirmation = ENV.fetch("PASSWORD") { abort "PASSWORD is required" }
      admin.skip_confirmation!
    end
    admin.role = :super_admin
    admin.save!

    puts "#{email} is a super_admin"
  end
end
