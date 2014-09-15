class Component < ActiveRecord::Base
  belongs_to :finding_aid
  belongs_to :setting, dependent: :destroy

  has_many :digitizations, dependent: :destroy
  include Settings
  
  alias_method :parent, :finding_aid
end
