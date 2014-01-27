class Project < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  belongs_to :setting
  has_many :finding_aids
  include Settings

  def settings
    self_and_parent_settings(owner)
  end
end
