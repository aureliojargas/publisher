desc "Update a mainstream slug

Changes are necessary in several apps when changing slugs,
so this is usually run by a fabric task.  See
https://github.com/alphagov/wiki/wiki/Changing-GOV.UK-URLs#making-the-change
for details.

This task performs the following:
- Changes the slug on all matching editions
- Changes the slug of the artefact
- Re-registers the published edition with panopticon,
  which re-registers with search
"
task :update_mainstream_slug, [:old_slug, :new_slug, :user_name] => :environment do |_task, args|
  users = User.where(:name => args[:user_name])
  unless users.size == 1
    raise "Failed to find unique user with name #{args[:user_name]}"
  end
  MainstreamSlugUpdater.new(args[:old_slug], args[:new_slug], users.first, Logger.new(STDOUT)).update
end
