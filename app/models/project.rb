class Project < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  belongs_to :setting
  accepts_nested_attributes_for :setting
  has_many :finding_aids
  include Settings

  alias_method :parent, :owner
end
