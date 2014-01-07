class FindingAid < ActiveRecord::Base
  belongs_to :owner
  belongs_to :project
  belongs_to :settings
  has_many :links
end
