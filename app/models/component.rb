class Component < ActiveRecord::Base
  belongs_to :finding_aid
  belongs_to :setting

  has_many :digitizations
  include Settings
  
  alias_method :parent, :finding_aid
end
