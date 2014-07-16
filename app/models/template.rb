class Template < ActiveRecord::Base
  belongs_to :owner
  REPLACEMENTS = {
    'url' => 'digitization.url',
    'link_text' => 'digitization.settings["link_text"]',
    'thumbnail_url' => 'digitization.settings["thumbnail_url"]',
  }

  def subbed_template
    REPLACEMENTS.each do |pattern, replacement|
      body.gsub!(Regexp.new('{{\s.' + pattern + '\s.}}'), "<%= #{replacement} %>")
    end
    body
  end

  #render_to_string :inline
end
