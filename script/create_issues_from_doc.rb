#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

# スコープから Issue を自動生成するスクリプト
class IssueGenerator
  attr_reader :doc_path, :dry_run, :parent_issue_number

  def initialize(doc_path:, dry_run: false, parent_issue: nil)
    @doc_path = doc_path
    @dry_run = dry_run
    @parent_issue_number = parent_issue
  end

  def run
    puts "📋 スコープ抽出開始: #{doc_path}"

    scopes = extract_scopes
    puts "✅ 抽出されたスコープ: #{scopes.count} 件\n"

    created_issues = {}

    # 親スコープ（1, 2, 3 等）を先に作成
    parent_scopes = scopes.select { |s| s[:id].match?(/^\d+$/) }
    parent_scopes.each do |scope|
      issue_number = create_issue(scope)
      created_issues[scope[:id]] = issue_number
      puts ""
    end

    # サブスコープ（1-1, 1-2 等）を作成
    sub_scopes = scopes.select { |s| s[:id].match?(/^\d+-\d+$/) }
    sub_scopes.each do |scope|
      create_issue(scope, created_issues)
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
      if match = line.match(/^- \[\s*\] (\d+)\.\s+(.+)$/)
        id = match[1]
        title = match[2].strip
        scopes << { id: id, title: title, parent: nil }
        current_parent = id
      # サブスコープ: `  - [ ] 1-1. タイトル`
      elsif match = line.match(/^  - \[\s*x?\s*\] (\d+-\d+)\.\s+(.+)$/)
        id = match[1]
        title = match[2].strip
        scopes << { id: id, title: title, parent: current_parent }
      end
    end

    scopes
  end

  def create_issue(scope, created_issues = {})
    title = "[#{scope[:id]}] #{scope[:title]}"
    body = build_body(scope)

    command = build_command(title, body)

    puts "🔨 作成中: #{title}"
    puts "   Command: #{command}" if dry_run

    return "DRY-RUN" if dry_run

    output = `#{command} 2>&1`

    if $?.success?
      # Issue 番号を抽出（出力から）
      if match = output.match(/Opened.*#(\d+)/)
        issue_number = match[1]
        puts "✓ Issue ##{issue_number} 作成完了"
        return issue_number
      else
        puts "✓ Issue 作成完了"
        return nil
      end
    else
      puts "✗ エラー: #{output}"
      return nil
    end
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

    body_parts.join("")
  end

  def build_command(title, body)
    escaped_body = body.gsub('"', '\"').gsub('$', '\$')

    cmd = 'gh issue create'
    cmd += " --title \"#{title}\""
    cmd += " --body \"#{escaped_body}\""
    cmd += " --project \"rails8-todo\""

    cmd
  end
end

# メイン実行
if __FILE__ == $PROGRAM_NAME
  options = { dry_run: false }

  OptionParser.new do |opts|
    opts.banner = "使用方法: script/create_issues_from_doc.rb [options]"

    opts.on('--doc PATH', '要件ドキュメントパス (デフォルト: docs/requirements/admin-crud.md)') do |v|
      options[:doc] = v
    end

    opts.on('--dry-run', 'ドライラン（実際には作成しない）') do |v|
      options[:dry_run] = v
    end

    opts.on('--parent ISSUE_NUM', '親 Feature Issue 番号') do |v|
      options[:parent_issue] = v
    end

    opts.on('-h', '--help', 'ヘルプを表示') do
      puts opts
      exit
    end
  end.parse!

  doc_path = options[:doc] || 'docs/requirements/admin-crud.md'

  unless File.exist?(doc_path)
    puts "❌ ファイルが見つかりません: #{doc_path}"
    exit 1
  end

  generator = IssueGenerator.new(
    doc_path: doc_path,
    dry_run: options[:dry_run],
    parent_issue: options[:parent_issue]
  )

  generator.run
end
