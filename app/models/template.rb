class Template < ActiveRecord::Base
  belongs_to :owner
  KEYWORDS = {
    'url' => {
      replacement: 'digitization.url',
      desc: 'URL to the resource'
    },
    'link_text' => {
        replacement: 'digitization.settings["link_text"]',
        desc: 'The text of the anchor tag that points to the URL'
    },
    'thumbnail_url' => {
        replacement: 'digitization.settings["thumbnail_url"]',
        desc: 'The URL to the thumbnail of the component'
    }
  }

  def subbed_template
    KEYWORDS.each do |keyword, data|
      body.gsub!(Regexp.new('{{\s*' + keyword + '\s*}}'), "<%= #{data[:replacement]} %>")
    end
    body
  end

  #render_to_string :inline
end
