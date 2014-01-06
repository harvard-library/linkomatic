class Link < ActiveRecord::Base
  belongs_to :finding_aid
  belongs_to :settings
end
