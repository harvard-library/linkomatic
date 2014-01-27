class Component < ActiveRecord::Base
  belongs_to :finding_aid
  belongs_to :setting

  has_many :digitizations
  include Settings

  def settings
    self_and_parent_settings(finding_aid)
  end
end
