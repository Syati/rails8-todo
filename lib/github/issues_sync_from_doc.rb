# frozen_string_literal: true

require 'json'

# スコープから Issue を自動同期する
class IssueGenerator
  attr_reader :doc_path, :dry_run, :project_name

  def initialize(doc_path:, dry_run: false, project_name: nil)
    @doc_path = doc_path
    @dry_run = dry_run
    @project_name = project_name
  end

  def run
    puts "📋 スコープ抽出開始: #{doc_path}"

    scopes = extract_scopes
    puts "✅ 抽出されたスコープ: #{scopes.count} 件\n"

    # 親スコープ（1, 2, 3 等）を先に作成
    parent_scopes = scopes.select { |s| s[:id].match?(/^\d+$/) }
    parent_scopes.each do |scope|
      sync_issue(scope)
      puts ""
    end

    # サブスコープ（1-1, 1-2 等）を作成
    sub_scopes = scopes.select { |s| s[:id].match?(/^\d+-\d+$/) }
    sub_scopes.each do |scope|
      sync_issue(scope)
      puts ""
    end

    puts "✨ Issue 生成完了！"
  end

  private

  def extract_scopes
    content = File.read(doc_path)
    scopes = []

    # スコープセクションを抽出
    scope_section = content.match?(/## スコープ/i) ? content.split(/## シナリオ仕様/i).first : content
    return scopes if scope_section.nil?

    lines = scope_section.split("\n")
    current_parent = nil

    lines.each do |line|
      # 親スコープ: `- [ ] 1. タイトル`
      if (match = line.match(/^- \[\s*\] (\d+)\.\s+(.+)$/))
        id = match[1]
        title = match[2].strip
        scopes << { id: id, title: title, parent: nil }
        current_parent = id
      # サブスコープ: `  - [ ] 1-1. タイトル`
      elsif (match = line.match(/^  - \[\s*x?\s*\] (\d+-\d+)\.\s+(.+)$/))
        id = match[1]
        title = match[2].strip
        scopes << { id: id, title: title, parent: current_parent }
      end
    end

    scopes
  end

  def sync_issue(scope)
    title = "[#{scope[:id]}] #{scope[:title]}"
    body = build_body(scope)
    issue_number = find_existing_issue_number(scope[:id])

    if issue_number
      command = build_edit_command(issue_number, title, body)
      puts "♻️ 更新中: ##{issue_number} #{title}"
    else
      command = build_create_command(title, body)
      puts "🔨 作成中: #{title}"
    end

    puts "   Command: #{command}" if dry_run

    return 'DRY-RUN' if dry_run

    output = `#{command} 2>&1`

    if $?.success?
      if issue_number
        puts "✓ Issue ##{issue_number} 更新完了"
        issue_number
      elsif (match = output.match(/#(\d+)/))
        issue_number = match[1]
        puts "✓ Issue ##{issue_number} 作成完了"
        issue_number
      else
        puts '✓ Issue 作成完了'
        nil
      end
    else
      puts "✗ エラー: #{output}"
      nil
    end
  end

  def find_existing_issue_number(scope_id)
    query = "[#{scope_id}] in:title"
    command = "gh issue list --state all --limit 200 --search \"#{query}\" --json number,title"
    output = `#{command} 2>&1`
    return nil unless $?.success?

    issues = JSON.parse(output)
    matched = issues.select do |issue|
      issue['title'].start_with?("[#{scope_id}] ")
    end

    warn "⚠️ scope_id=#{scope_id} に一致するIssueが複数あります。先頭を使用します。" if matched.size > 1
    matched.first && matched.first['number']
  rescue JSON::ParserError
    nil
  end

  def build_body(scope)
    body_parts = []

    # 親スコープリンク
    if scope[:parent]
      body_parts << "## 親スコープ\n"
      body_parts << "スコープ [#{scope[:parent]}] 参照\n"
    end

    # 参考
    body_parts << "\n## 参考\n"
    body_parts << "- [#{File.basename(doc_path)}](../../../#{doc_path})\n"

    body_parts.join('')
  end

  def build_create_command(title, body)
    escaped_body = body.gsub('"', '\\"').gsub('$', '\\$')

    cmd = 'gh issue create'
    cmd += " --title \"#{title}\""
    cmd += " --body \"#{escaped_body}\""
    cmd += " --project \"#{project_name}\"" if project_name.to_s.strip != ''

    cmd
  end

  def build_edit_command(issue_number, title, body)
    escaped_body = body.gsub('"', '\\"').gsub('$', '\\$')

    cmd = "gh issue edit #{issue_number}"
    cmd += " --title \"#{title}\""
    cmd += " --body \"#{escaped_body}\""

    cmd
  end
end
