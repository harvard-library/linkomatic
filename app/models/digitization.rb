class Digitization < ActiveRecord::Base
  belongs_to :component
  belongs_to :setting
  acts_as_list scope: :component
  include Settings

  NRS_SERVER = 'http://nrs.harvard.edu/'

  def settings
    self_and_parent_settings(component)
  end

  def url
    NRS_SERVER + urn if urn
  end
end
