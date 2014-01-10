class Setting < ActiveRecord::Base

  HARDCODED_ATTRIBUTES = ['id', 'updated_at', 'created_at']

  def to_h
    attributes.delete_if{ |k, v| v.nil? || HARDCODED_ATTRIBUTES.include?(k) }
  end
end
