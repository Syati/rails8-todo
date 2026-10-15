# Admins for trying the admin screens locally. Every account uses the password below.
password = "password123"

seed_admin = lambda do |email, **attributes|
  Admin.find_or_create_by!(email: email) do |admin|
    admin.password = password
    admin.password_confirmation = password
    admin.assign_attributes(attributes)
    admin.skip_confirmation!
  end
end

seed_admin.call("admin@example.com", role: :super_admin)

# More than one page (30 per page) so pagination and sorting can be checked.
1.upto(40) do |n|
  seed_admin.call(format("operator%02d@example.com", n))
end

seed_admin.call("locked@example.com", locked_at: Time.current, failed_attempts: Devise.maximum_attempts)
seed_admin.call("deleted@example.com", deleted_at: Time.current)
