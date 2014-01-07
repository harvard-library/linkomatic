class FindingAid < ActiveRecord::Base
  require 'csv'
  require 'open-uri'
  belongs_to :owner
  belongs_to :project
  belongs_to :settings
  has_many :links

  CSV_URL_PATTERN = 'http://oasis.lib.harvard.edu/oasis/csvcomponents/{name}.csv'
  PERSISTENT_URL_PATTERN =
    /http:\/\/nrs\.harvard\.edu\/urn-3:(?<authpath>[A-Za-z\.]+):(?<name>[a-z0-9]+)/
  CSV_ID_HEADER = 'ID'

  def job_status_pcts
    Hash[job_status_counts.map{ |k,count| [k, (count.to_f / link_creation_jobs.count * 100).round(1)] }]
  end

  def job_status_counts
    job_statuses.each_with_object(Hash.new(0)){ |s, h| h[s] += 1 }
  end

  def job_statuses
    link_creation_jobs.map do |job|
      SidekiqStatus::Container.load(job).status
    end
  end

  def link_creation_jobs
    return @link_creation_jobs unless @link_creation_jobs.nil?
    @link_creation_jobs = []
  end

  def create_links!
    jobs = []
    component_ids.each do |cid|
      jobs << LinkCreator.perform_async(id, cid)
    end
    @link_creation_jobs = jobs
  end

  def component_ids
    return @component_ids unless @component_ids.nil?
    csv = CSV.parse(URI.parse(csv_url).read, headers: true)
    @component_ids = csv[CSV_ID_HEADER]
  end

  def csv_url
      match = PERSISTENT_URL_PATTERN.match(url)
      CSV_URL_PATTERN.sub('{name}', match['name'])
  end
end
