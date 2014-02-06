class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :setting
  has_many :projects
  has_many :finding_aids, foreign_key: 'owner_id'
  before_create :set_default_setting
  include Settings

  def parent
  end

  def set_default_setting
    self.setting = Setting.create(
      link_text: 'Click here for digital copy',
      thumbnails: false
    )
  end
end
