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
  OLIVIA = URI("http://olivia.lib.harvard.edu:9016/olivia/servlet/OliviaServlet")
  OID_Q_BASE = {"storedProcedure" => "getOracleID",
               "callingApplication" => "OASIS",
               "role" => "NA",
               "purpose" => "NA"}

  def oid_path(component_id, authpath, quality = "NA")
    OLIVIA.request_uri + '?' + URI.encode_www_form(OID_Q_BASE.merge("ownerCode" => "#{authpath}",
                                                                    "quality" => "#{quality}",
                                                                    "localName" => "#{component_id}"))
  end

  def urns_url(oid)
    URI(OLIVIA + URI.encode("storedProcedure=getURN&oracleID=#{oid}"))
  end

  ##################################################
  # OID and URN fetchers                           #
  ##################################################

  # Fetch OID. Returns OID or nil
  def get_oid(component_id, authpath)
    http = Net::HTTP.new(OLIVIA.host, OLIVIA.port)
    http.read_timeout = 120

    # Attempt 1: PDS(Quality NA)
    oid_html = if (res = http.request(Net::HTTP::Get.new(oid_path(component_id, authpath)))).code == "200"
                 logger.info "Attempt 1: #{oid_path(component_id, authpath, "NA")}"
                 res.body
               # Attempt 2: PDS, but malformed(Quality NA, '-METS' suffix)
               elsif (res = http.request(Net::HTTP::Get.new(oid_path("#{component_id}-METS", authpath)))).code == "200"
                 logger.info "Attempt 2: #{oid_path(component_id + '-METS', authpath, "NA")}"
                 res.body
               # Attempt 3: Deliverable(Quality 5)
               elsif (res = http.request(Net::HTTP::Get.new(oid_path(component_id, authpath, "5")))).code == "200"
                 logger.info "Attempt 3: #{oid_path(component_id, authpath, "5")}"
                 res.body
               else
                 logger.info "Failure: NO URN FOR C_ID: #{component_id} and ownerCode: #{authpath}"
                 ""
               end
    oid_html.match(/(?<=Oracle ID: ).+?(?=<br>)/)
  rescue Timeout::Error
    logger.info "Timeout error in get_oid"
    nil
  end

  # Fetches URNs. Returns array of URNs (can be empty)
  def get_urns(oid)
    logger.info "Fetch URNs for #{oid} at #{urns_url(oid)}"
    if (res = Net::HTTP.get_response(urns_url(oid))).code == "200"
      if (urns = res.body.match(/(?<=URN: ).+?(?=<br>)/))
        logger.info "URNs returned: #{urns}"
        urns.to_s.split(',')
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
    authpath = component.settings['owner_code']
    logger.info "Fetching: #{authpath} : #{component_id}'s OID"
    if (oid = get_oid(component_id, authpath))
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
