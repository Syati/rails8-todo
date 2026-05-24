# == Schema Information
#
# Table name: admins
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           not null
#  encrypted_password     :string           not null
#  failed_attempts        :integer          default(0), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  uid                    :string
#  unconfirmed_email      :string
#  unlock_token           :string
#
# Indexes
#
#  index_admins_on_confirmation_token    (confirmation_token) UNIQUE
#  index_admins_on_email                 (email) UNIQUE
#  index_admins_on_reset_password_token  (reset_password_token) UNIQUE
#  index_admins_on_unlock_token          (unlock_token) UNIQUE
#
require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe ".from_omniauth" do
    let(:provider) { "developer" }
    let(:uid) { "dev-uid-001" }
    let(:email) { "oauth-admin@example.com" }
    let(:auth) { OpenStruct.new(provider:, uid:, info: OpenStruct.new(email:)) }

    it "provider と uid が一致する既存管理者を返す" do
      admin = create(:admin, provider:, uid:, email: "existing@example.com")

      expect(described_class.from_omniauth(auth)).to eq(admin)
      expect(admin.reload.email).to eq("existing@example.com")
    end

    it "一致する管理者がなければ新規作成する" do
      created = nil

      expect do
        created = described_class.from_omniauth(auth)
      end.to change(described_class, :count).by(1)

      expect(created.provider).to eq(provider)
      expect(created.uid).to eq(uid)
      expect(created.email).to eq(email)
      expect(created.encrypted_password).to be_present
    end
  end

  describe ".ransackable_attributes" do
    it "id と email のみ検索許可する" do
      expect(described_class.ransackable_attributes).to eq(%w[id email])
    end
  end

  describe ".ransackable_associations" do
    it "関連検索を許可しない" do
      expect(described_class.ransackable_associations).to eq([])
    end
  end
end
