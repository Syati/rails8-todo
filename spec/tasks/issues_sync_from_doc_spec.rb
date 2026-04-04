require "rails_helper"
require "rake"
require Rails.root.join("lib/github/issues_sync_from_doc").to_s

RSpec.describe "issues:sync_from_doc", type: :task do
  before(:all) do
    Rails.application.load_tasks unless Rake::Task.task_defined?("issues:sync_from_doc")
  end

  let(:task) { Rake::Task["issues:sync_from_doc"] }
  let(:generator) { instance_double(IssueGenerator, run: true) }

  before do
    allow(IssueGenerator).to receive(:new).and_return(generator)
    task.reenable
  end

  it "raises error when doc arg is omitted" do
    expect { task.invoke }.to raise_error(
      ArgumentError,
      /doc を渡してください/
    )

    expect(IssueGenerator).not_to have_received(:new)
  end

  it "passes custom doc path and dry_run=true" do
    task.invoke("docs/requirements/custom-feature.md", "true", "my-project")

    expect(IssueGenerator).to have_received(:new).with(
      doc_path: "docs/requirements/custom-feature.md",
      dry_run: true,
      project_name: "my-project"
    )
    expect(generator).to have_received(:run)
  end

  it "uses default project when project arg is omitted" do
    task.invoke("docs/requirements/custom-feature.md", "false")

    expect(IssueGenerator).to have_received(:new).with(
      doc_path: "docs/requirements/custom-feature.md",
      dry_run: false,
      project_name: "rails8-todo"
    )
    expect(generator).to have_received(:run)
  end
end
