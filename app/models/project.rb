class Project < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  belongs_to :setting, dependent: :destroy
  accepts_nested_attributes_for :setting
  has_many :finding_aids, dependent: :destroy
  include Settings

  alias_method :parent, :owner
end
