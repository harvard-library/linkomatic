require 'test_helper'
require 'sidekiq/testing'

class FindingAidTest < ActiveSupport::TestCase
  test "guesses correct CSV URL from NRS URL" do
    assert finding_aids(:one).csv_url == 'http://oasistest.lib.harvard.edu:9003/oasis/csvcomponents/hua19013.csv'
    assert finding_aids(:two).csv_url == 'http://oasistest.lib.harvard.edu:9003/oasis/csvcomponents/med00055.csv'
    assert finding_aids(:three).csv_url == 'http://oasistest.lib.harvard.edu:9003/oasis/csvcomponents/sch00411.csv'
  end

  test "fetches component ids from CSV" do
    finding_aids(:one).create_components!
    finding_aids(:two).create_components!
    assert finding_aids(:one).components.last.cid == 'hua19013c00024'
    assert finding_aids(:one).components.count == 24
    assert finding_aids(:two).components.last.cid == 'med00055c00151'
    assert finding_aids(:two).components.count == 169
  end

  test "creates links for found URNs" do
    Sidekiq::Testing.fake!
    finding_aids(:one).create_components!
    finding_aids(:one).fetch_urns!
    assert URNFetcher.jobs.size == finding_aids(:one).components.count
    URNFetcher.drain
    digitizations = finding_aids(:one).components.map{|c| c.digitizations}.flatten
    assert digitizations.count == 3
    assert digitizations.map(&:urn).sort == [
      'urn-3:HUL.ARCH:11111650',
      'urn-3:HUL.ARCH:11111651',
      'urn-3:HUL.ARCH:11111652'
    ]
  end
end
