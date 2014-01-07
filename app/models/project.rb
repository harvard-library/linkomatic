class Project < ActiveRecord::Base
  belongs_to :owner
  belongs_to :settings
  has_many :finding_aids
end
