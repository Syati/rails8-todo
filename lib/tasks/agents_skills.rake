namespace :agents do
  desc "Sync .agents/skills from .github/agents"
  task sync_skills: :environment do
    sh "bin/sync_agent_skills"
  end

  desc "Check whether .agents/skills are in sync with .github/agents"
  task check_skills_sync: :environment do
    sh "bin/sync_agent_skills --check"
  end
end
