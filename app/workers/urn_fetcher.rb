class URNFetcher
  require 'open-uri'

  include SidekiqStatus::Worker
  include FindingAidsHelper
  URL = 'http://oasistest.lib.harvard.edu:9003/oasis/jsp/olivia.jsp?localname={component_id}&authpath=HUL.ARCH'
  NOT_FOUND_MESSAGE = 'No URN found'

  def perform(finding_aid_id, component_id, i, total_components)
    finding_aid = FindingAid.find(finding_aid_id)
    component = finding_aid.components.find_by_cid(component_id)
    urns = URI.parse(URL.sub('{component_id}', component_id)).read
    ds = []

    if finding_aid.urn_fetch_jobs.count == total_components
      WebsocketRails[:urn_fetch_jobs_progress].trigger :update, finding_aid.job_status_pcts
    end

    unless urns == NOT_FOUND_MESSAGE
      ds << urns.split(',').each{|urn| component.digitizations.find_or_create_by urn: urn}
    end

    # Tell all the clients a job has finished
    WebsocketRails[:urn_fetch_job].trigger :complete, {
      component_id: component.cid,
      found: component.digitizations.exists?,
      urns: component.digitizations.map(&:urn),
      urls: component.digitizations.map(&:url)
    }

    if finding_aid.job_status_pcts['waiting'] == 0.0
      FindingAid.delay.update_job_status(finding_aid.id)
    end
  end
end
