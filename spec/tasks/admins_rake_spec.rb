require "rails_helper"
require "rake"

RSpec.describe "admins:bootstrap_super_admin", type: :task do
  subject(:run_task) { task.invoke }

  let(:task) { Rake::Task["admins:bootstrap_super_admin"] }

  before { Rails.application.load_tasks unless Rake::Task.task_defined?("admins:bootstrap_super_admin") }

  around do |example|
    original = ENV.to_h.slice("EMAIL", "PASSWORD")
    ENV.update("EMAIL" => "first-admin@example.com", "PASSWORD" => "password123")
    example.run
  ensure
    ENV.delete("EMAIL")
    ENV.delete("PASSWORD")
    ENV.update(original)
    task.reenable
  end

  it "存在しない管理者を確認済みの super_admin として作成する", :aggregate_failures do
    expect { run_task }.to output(/is a super_admin/).to_stdout

    admin = Admin.find_by!(email: "first-admin@example.com")
    expect(admin).to be_super_admin
    expect(admin).to be_confirmed
    expect(admin.valid_password?("password123")).to be(true)
  end

  it "既存の operator を super_admin に昇格し、パスワードは変えない", :aggregate_failures do
    admin = create(:admin, email: "first-admin@example.com", password: "original123", password_confirmation: "original123")

    expect { run_task }.to output.to_stdout

    expect(admin.reload).to be_super_admin
    expect(admin.valid_password?("original123")).to be(true)
  end

  it "削除済みの管理者は昇格しない" do
    admin = create(:admin, email: "first-admin@example.com", deleted_at: Time.current)

    expect { run_task }.to raise_error(SystemExit).and output(/is deleted/).to_stderr
    expect(admin.reload).to be_operator
  end
end
