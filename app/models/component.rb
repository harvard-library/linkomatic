class Component < ActiveRecord::Base
  belongs_to :finding_aid
  belongs_to :setting

  has_many :digitizations
end
