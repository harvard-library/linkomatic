class URNFetcher
  require 'open-uri'
  include FindingAidsHelper
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  URL = 'http://oasistest.lib.harvard.edu:9003/oasis/jsp/olivia.jsp?localname={component_id}&authpath={authpath}'
  NOT_FOUND_MESSAGE = 'No URN found'

  def perform(finding_aid_id, component_id, i, total_components)
    finding_aid = FindingAid.find(finding_aid_id)
    component = finding_aid.components.find_by_cid(component_id)
    url = URI.encode(URL.sub('{component_id}', component_id).sub('{authpath}', finding_aid.authpath))
    urns = URI.parse(url).read

    if urns == NOT_FOUND_MESSAGE
      component.digitizations.create(urn: nil) if component.digitizations.empty?
    else
      urns.split(',').each{|urn| component.digitizations.find_or_create_by urn: urn}
    end

    # Tell all the clients a job has finished
    WebsocketRails[:urn_fetch_job].trigger :complete, {
      jid: jid,
      component_id: component.cid,
      found: component.digitizations.exists?,
      urns: component.digitizations.map(&:urn),
      urls: component.digitizations.map(&:url)
    }
  end
end
