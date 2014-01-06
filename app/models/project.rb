class Project < ActiveRecord::Base
  belongs_to :owner
  belongs_to :settings
end
