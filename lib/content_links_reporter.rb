require 'csv'

# eg
# ContentLinksReporter.new("/var/govuk", Regexp.new("\(http[^:]*:\/\/[^\.]*\.hmrc\.gov\.uk[^\) \n]*\)")).report
#
class ContentLinksReporter
  attr_reader :report_dir, :link_regex

  def initialize(report_dir, link_regex)
    @report_dir = report_dir
    @link_regex = link_regex
  end

  def report
    matching_editions = []
    CSV.open(csv_file_path, "wb") do |csv|
      csv << ["Slug", "Format", "Links"]
      editions = Edition.published.order([[:_type, :asc],[:slug, :asc]]).each do |edition|
        if body_content = whole_body(edition)
          links = whole_body(edition).scan(link_regex)
          unless links.empty?
            links = links.flatten.join(",")
            links.gsub!("(","").gsub!(")","")
            csv << [edition.slug, edition._type, links]
            matching_editions << edition.slug
          end
        end
      end
    end
    if matching_editions.any?
      puts "#{matching_editions.size} Editions found matching #{link_regex}."
      puts matching_editions.join(",")
    else
      puts "No matches for #{link_regex}"
      FileUtils.rm(csv_file_path)
    end
  end

  def whole_body(edition)
    if edition.respond_to? :whole_body
      edition.whole_body
    elsif edition.respond_to? :parts
      edition.parts.map(&:body).join("\n\n")
    else
      edition.body
    end
  end

  def csv_file_path
    File.join(report_dir, "content-links-#{Time.zone.now.strftime('%d%m%y-%H%M')}.csv")
  end
end
