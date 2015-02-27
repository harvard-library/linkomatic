# This background worker, given a component ID and an OwnerCode(authpath),
#   fetches an Oracle ID, then uses that Oracle ID to fetch a URN for that component

class URNFetcher
  require 'net/http'
  include FindingAidsHelper
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  ##################################################
  # Url parts and helpers                          #
  ##################################################
  BASE_OLIVIA = "http://olivia.lib.harvard.edu:9016/olivia/servlet/OliviaServlet?"
  OID_QUERY = "storedProcedure=getOracleID&callingApplication=OASIS&role=NA&purpose=NA&"

  def oid_url(component_id, authpath, quality)
    URI.encode(BASE_OLIVIA + OID_QUERY + "ownerCode=#{authpath}&quality=#{quality}&localName=#{component_id}")
  end

  def urns_url(oid)
    URI.encode(BASE_OLIVIA + "storedProcedure=getURN&oracleID=#{oid}")
  end

  ##################################################
  # OID and URN fetchers                           #
  ##################################################

  # Fetch OID. Returns OID or nil
  def get_oid(component_id, authpath)
    # Attempt 1: PDS(Quality NA)
    oid_html = if (res = Net::HTTP.get_response(oid_url(component_id, authpath, "NA"))).code == "200"
                 res.body
               # Attempt 2: PDS, but malformed(Quality NA, '-mets' suffix)
               elsif (res = Net::HTTP.get_response(oid_url("#{component_id}-mets", authpath, "NA"))).code == "200"
                 res.body
               # Attempt 3: Deliverable(Quality 5)
               elsif (res = Net::HTTP.get_response(oid_url(component_id, authpath, "5"))).code == "200"
                 res.body
               else
                 nil
               end
    if oid_html && (oid_idx = oid_html.index("Oracle ID: "))
      oid_html[(oid_idx + 11)..-1]
    else
      nil
    end
  end

  # Fetches URNs. Returns array of URNs (can be empty)
  def get_urns(oid)
    if (res = Net::HTTP.get_response(oid_url(oid))).code == "200"
      if (urns = res.body.match(/(?<=URN: ).+(?=<br>)/))
        urns.split(',')
      else
        []
      end
    else
      []
    end
  end

  ##################################################
  # Entry point for worker                         #
  ##################################################
  def perform(finding_aid_id, component_id, i, total_components)
    oid = urns = nil
    finding_aid = FindingAid.find(finding_aid_id)
    component = finding_aid.components.find_by_cid(component_id)
    authpath = component.settings['ownerCode']
    logger.info "Fetching: #{component_id}'s OID"
    if (oid = get_oid)
      get_urns(oid).each{|urn| component.digitizations.find_or_create_by urn: urn}
    else
      component.digitizations.create(urn: nil) if component.digitizations.empty?
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
