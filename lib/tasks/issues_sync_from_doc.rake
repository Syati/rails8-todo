namespace :issues do
  desc "Sync GitHub issues from requirements markdown (create or update)"
  task :sync_from_doc, [:doc, :dry_run, :project] => :environment do |_task, args|
    require Rails.root.join("lib/github/issues_sync_from_doc").to_s

    doc_path = args[:doc].presence
    raise ArgumentError, "doc を渡してください（例: bundle exec rake \"issues:sync_from_doc[docs/requirements/admin-crud.md,true]\"）" if doc_path.blank?

    dry_run = ActiveModel::Type::Boolean.new.cast(args[:dry_run] || false)
    project_name = args[:project].presence || "rails8-todo"

    IssueGenerator.new(doc_path: doc_path, dry_run: dry_run, project_name: project_name).run
  end
end
