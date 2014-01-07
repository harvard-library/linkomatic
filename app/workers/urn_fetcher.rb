class URNFetcher
  require 'open-uri'

  include SidekiqStatus::Worker
  URL = 'http://oasistest.lib.harvard.edu:9003/oasis/jsp/olivia.jsp?localname={component_id}&authpath=HUL.ARCH'
  NOT_FOUND_MESSAGE = 'No URN found'

  def perform(finding_aid_id, component_id)
    finding_aid = FindingAid.find(finding_aid_id)
    url = URI.parse(URL.sub('{component_id}', component_id))
    urn = url.read
    unless urn == NOT_FOUND_MESSAGE
      finding_aid.links.create(
        component_id: component_id,
        urn: urn,
        order: finding_aid.links.where(component_id: component_id).count
      )
    end
  end
end
