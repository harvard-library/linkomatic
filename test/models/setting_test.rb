require 'test_helper'

class SettingTest < ActiveSupport::TestCase
  test "more specific settings overwrite less specific" do
    assert users(:user).settings['link_text'] == 'Click here'
    assert projects(:one).settings['link_text'] == 'View image'
    assert finding_aids(:two).settings['link_text'] == 'Show photo'
    assert finding_aids(:two).settings['thumbnail_url'] == 'http://lorempixel.com/g/50/50'
    assert components(:one).settings['link_text'] == 'Open'
    assert components(:one).settings['thumbnail_url'] == 'http://lorempixel.com/g/50/50'
    assert digitizations(:one).settings['thumbnail_url'] ==
      'http://www.iconshock.com/img_jpg/CLEAN/business/jpg/128/trophy_icon.jpg'
    assert digitizations(:one).settings['link_text'] == 'Open'
    assert digitizations(:one).settings['thumbnails'] == true
  end
end
