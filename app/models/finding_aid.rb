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

  def component_ids
    return @component_ids unless @component_ids.nil?
    csv = CSV.parse(URI.parse(csv_url).read, headers: true)
    @component_ids = csv[CSV_ID_HEADER]
    @component_ids
  end

  def csv_url
      match = PERSISTENT_URL_PATTERN.match(url)
      CSV_URL_PATTERN.sub('{name}', match['name'])
  end
end
