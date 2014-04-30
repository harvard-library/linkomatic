class Digitization < ActiveRecord::Base
  belongs_to :component
  belongs_to :setting
  acts_as_list scope: :component
  include Settings

  default_scope {order(:position)}

  NRS_SERVER = 'http://nrs.harvard.edu/'

  alias_method :parent, :component

  def url
    NRS_SERVER + urn if urn
  end
end
