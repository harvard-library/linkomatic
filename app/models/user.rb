class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :setting
  has_many :projects, foreign_key: 'owner_id'
  has_many :finding_aids, foreign_key: 'owner_id'
  before_create :set_defaults
  after_create :add_example_finding_aid
  accepts_nested_attributes_for :setting

  include Settings

  def parent
  end

  def set_defaults
    self.projects.build(name: 'Default Project')
    self.create_setting(
      link_text: 'Click here for digital copy',
      thumbnails: false
    )
  end

  def add_example_finding_aid
    self.projects.first.finding_aids.create(
      name: 'Example finding aid',
      url: 'http://nrs.harvard.edu/urn-3:HUL.ARCH:hua19013'
    )
  end
end
