class FindingAid < ActiveRecord::Base
  require 'csv'
  require 'open-uri'
  belongs_to :owner, class_name: 'User'
  belongs_to :project
  belongs_to :setting
  has_many :components
  has_many :digitizations, through: :components

  serialize :urn_fetch_jobs, Array

  before_create :set_name
  after_create :create_components!

  LIBRARY_NAME_SERVER = 'http://nrs.harvard.edu/'
  EAD_URL_PATTERN = 'http://oasis.lib.harvard.edu/oasis/ead2002/dtd/{name}'
  CSV_URL_PATTERN = 'http://oasis.lib.harvard.edu/oasis/csvcomponents/{name}.csv'
  PERSISTENT_URL_PATTERN =
    Regexp.new(Regexp.escape(LIBRARY_NAME_SERVER) + 'urn-3:(?<authpath>[A-Za-z\.]+):(?<name>[a-z0-9]+)')
  CSV_ID_HEADER   = 'ID'
  CSV_NAME_HEADER = 'Unit Title'
  CSV_URN_HEADER  = 'URN'

  include Settings
  include SidekiqStatuses

  alias_method :parent, :project

  def to_percent(num)
    (num * 100).round(1)
  end

  def job_status_pcts
    total = urn_fetch_jobs.count
    complete = components.joins(:digitizations).uniq.count
    { 'complete' => to_percent(complete.to_f / total), 'waiting' => to_percent((total - complete).to_f / total)}
    #Hash[job_status_counts.map{
    #  |k,count| [k, (count.to_f / [urn_fetch_jobs.count, 1].max * 100).round(1)]
    #}]
  end

  def job_status_counts
    output = job_statuses.each_with_object(Hash.new(0)){ |s, h| h[s] += 1 }
    (JOB_STATUSES - output.keys).each{|k| output[k] = 0}
    output
  end

  def job_statuses
    statuses(urn_fetch_jobs)
  end

  def ead_url
    EAD_URL_PATTERN.sub('{name}', library_id)
  end

  def ead
    Nokogiri::XML(URI.parse(ead_url).read)
  end

  def library_id
    PERSISTENT_URL_PATTERN.match(url)['name']
  end

  def csv_url
    CSV_URL_PATTERN.sub('{name}', library_id)
  end

  def urns_fetched?
    !urn_fetch_jobs.empty?
  end

  def fetch_urns!
    self.urn_fetch_jobs = []
    components.each{|c| c.digitizations.destroy_all }
    components.map(&:cid).each_with_index do |cid, i|
      urn_fetch_jobs << URNFetcher.perform_async(id, cid, i, components.count)
    end
    save!
  end

  def self.update_job_status(id)
    finding_aid = FindingAid.find(id)

    if finding_aid.job_status_pcts['complete'] == 100.0
      # Tell all the clients the current status
      WebsocketRails[:urn_fetch_jobs_progress].trigger :update, finding_aid.job_status_pcts
    end
  end

  def create_components!
    ead.css('c').each do |c|
      if unittitle = c.at('unittitle')
        name = unittitle.content
      elsif container = c.at('container')
        name = container.content
      end
      component = components.create cid: c['id'], name: name
      c.css('> did dao',' > dao').each do |dao|
        component.digitizations.create urn: dao['href'].sub(LIBRARY_NAME_SERVER, '').sub(/\?.*$/,'')
      end
    end
  end

  private

  def set_name
    self.name = ead.at('titleproper').text if self.name.blank?
  end
end
