class Setting < ActiveRecord::Base

  HARDCODED_ATTRIBUTES = ['id', 'updated_at', 'created_at']

  def to_h
    attributes.delete_if do |k, v|
      HARDCODED_ATTRIBUTES.include?(k) ||
        v.nil? ||
        (v.respond_to?('empty?') && v.empty?)
    end
  end
end
