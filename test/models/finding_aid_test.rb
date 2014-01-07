require 'test_helper'
require 'sidekiq/testing'

class FindingAidTest < ActiveSupport::TestCase
  test "guesses correct CSV URL from NRS URL" do
    assert finding_aids(:one).csv_url == 'http://oasis.lib.harvard.edu/oasis/csvcomponents/hua19013.csv'
    assert finding_aids(:two).csv_url == 'http://oasis.lib.harvard.edu/oasis/csvcomponents/med00055.csv'
    assert finding_aids(:three).csv_url == 'http://oasis.lib.harvard.edu/oasis/csvcomponents/sch00411.csv'
  end

  test "fetches component ids from CSV" do
    assert finding_aids(:one).component_ids.last == 'hua19013c00024'
    assert finding_aids(:one).component_ids.count == 24
    assert finding_aids(:two).component_ids.last == 'med00055c00151'
    assert finding_aids(:two).component_ids.count == 168
  end

  test "creates links for found URNs" do
    Sidekiq::Testing.fake!
    finding_aids(:one).create_links!
    assert LinkCreator.jobs.size == finding_aids(:one).component_ids.count
    LinkCreator.drain
    assert finding_aids(:one).links.count == 3
    assert finding_aids(:one).links.map(&:urn).sort == [
      'urn-3:HUL.ARCH:11111650',
      'urn-3:HUL.ARCH:11111651',
      'urn-3:HUL.ARCH:11111652'
    ]
  end
end
