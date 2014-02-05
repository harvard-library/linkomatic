module Settings
  extend ActiveSupport::Concern

  included do
    before_create :create_settings
  end

  def settings
    self_and_parent_settings(parent)
  end

  def create_settings
    self.setting = Setting.create(settings)
    puts self.inspect
  end

  def self_and_parent_settings(parent = nil)
    return setting.to_h unless parent
    parent.settings.merge(self.setting.to_h)
  end
end
