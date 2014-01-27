module Settings
  def self_and_parent_settings(parent = nil)
    return setting.to_h unless parent
    parent.settings.merge(self.setting.to_h)
  end
end
