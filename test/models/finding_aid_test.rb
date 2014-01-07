require 'test_helper'

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
end
