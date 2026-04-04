require "rails_helper"
require "tempfile"
require Rails.root.join("lib/github/issues_sync_from_doc").to_s

RSpec.describe IssueGenerator do
  describe "#extract_scopes" do
    def write_doc(content)
      file = Tempfile.new(["issues-sync", ".md"])
      file.write(content)
      file.flush
      file
    end

    it "skips checked sub scopes and keeps unchecked ones" do
      file = write_doc(<<~MD)
        # Feature

        ## スコープ（ID付きチェックリスト）
        - [ ] 1. 一覧（Read）
          - [x] 1-1. 完了済み
          - [ ] 1-2. 未完了

        ## シナリオ仕様
      MD

      scopes = described_class.new(doc_path: file.path).send(:extract_scopes)

      expect(scopes).to include({ id: "1", title: "一覧（Read）", parent: nil })
      expect(scopes).to include({ id: "1-2", title: "未完了", parent: "1" })
      expect(scopes).not_to include(hash_including(id: "1-1"))
    ensure
      file&.close!
    end

    it "keeps parent context even when parent is checked" do
      file = write_doc(<<~MD)
        # Feature

        ## スコープ（ID付きチェックリスト）
        - [x] 1. 一覧（Read）
          - [ ] 1-2. 未完了

        ## シナリオ仕様
      MD

      scopes = described_class.new(doc_path: file.path).send(:extract_scopes)

      expect(scopes).to include({ id: "1-2", title: "未完了", parent: "1" })
      expect(scopes).not_to include(hash_including(id: "1"))
    ensure
      file&.close!
    end
  end
end
