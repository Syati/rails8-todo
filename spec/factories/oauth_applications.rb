FactoryBot.define do
  factory :oauth_application, class: "Doorkeeper::Application" do
    sequence(:name) { |n| "倉庫システム #{n}" }
    scopes { "read write" }
  end
end
