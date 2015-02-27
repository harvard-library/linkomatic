class URNFetcher
  require 'net/http'
  include FindingAidsHelper
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  BASE_OLIVIA = "http://olivia.lib.harvard.edu:9016/olivia/servlet/OliviaServlet?"
  GET_OID = "storedProcedure=getOracleID&callingApplication=OASIS&role=NA&purpose=NA&"
  def oid_url(component_id, authpath, quality)
    URI.encode(BASE_OLIVIA + GET_OID + "ownerCode=#{authpath}&quality=#{quality}&localName=#{component_id}")
  end

  def urns_url(oid)
    URI.encode(BASE_OLIVIA + "storedProcedure=getURN&oracleID=#{oid}")
  end

  def perform(finding_aid_id, component_id, i, total_components)
    oid = urns = nil
    finding_aid = FindingAid.find(finding_aid_id)
    component = finding_aid.components.find_by_cid(component_id)
    logger.info "Fetching: #{component_id}'s OID"
    # Attempt 1: PDS(Quality NA)
    if (res = Net::HTTP.get_response(oid_url(component_id, authpath, "NA"))).code == "200"
      oid = res.body
    # Attempt 2: PDS, but malformed(Quality NA, '-mets' suffix)
    elsif (res = Net::HTTP.get_response(oid_url("#{component_id}-mets", authpath, "NA"))).code == "200"
      oid = res.body
    # Attempt 3: Deliverable(Quality 5)
    elsif (res = Net::HTTP.get_response(oid_url(component_id, authpath, "5"))).code == "200"
      oid = res.body
    else
      component.digitizations.create(urn: nil) if component.digitizations.empty?
    end

    if oid
      oid = oid[(oid.index(": ") + 2)..-1]
      res = Net::HTTP.get_response(oid_url(oid))
      if res.code == "200"
        urns.match(/(?<=URN: ).+(?=<br>)/)
        urns.split(',').each{|urn| component.digitizations.find_or_create_by urn: urn}
      else
        component.digitizations.create(urn: nil) if component.digitizations.empty?
      end
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
