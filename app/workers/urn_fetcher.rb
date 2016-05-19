# coding: utf-8
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

  OLIVIA = URI("#{ENV.fetch('OLIVIA_URL', 'http://oliviatest.lib.harvard.edu:10016')}/olivia/servlet/OliviaServlet")
  OID_Q_BASE = {storedProcedure: "getOracleID",
                callingApplication: "OASIS"}
  OID_Q_OPTS = {quality: "NA",
                role: "NA",
                purpose: "NA"}

  def oid_path(component_id, authpath, opts = {})
    query = OID_Q_BASE.merge(OID_Q_OPTS).merge(ownerCode: "#{authpath}",
                                               localName: "#{component_id}").merge(opts)

    OLIVIA.request_uri + '?' + URI.encode_www_form(query)
  end

  def urns_path(oid)
    OLIVIA.request_uri + '?' + URI.encode("storedProcedure=getURN&oracleID=#{oid}")
  end

  # URN for component with URN pointing at PDS object
  def urns2_path(component_id, authpath)
    query = OID_Q_BASE.merge(storedProcedure: "getDrs2ObjectUrn",
                             ownerCode: "#{authpath}",
                             localName: "#{component_id}")

    OLIVIA.request_uri + '?' + URI.encode_www_form(query)
  end

  # Helper method which returns {response, false}
  def try_request(component_id, authpath, opts = {})
    @attempts += 1
    path = oid_path(component_id, authpath, opts)
    logger.info("Attempt #{@attempts}: #{path}")
    (res = @http.request(Net::HTTP::Get.new(path))).code == "200" ? res : false
  end

  ##################################################
  # OID and URN fetchers                           #
  ##################################################

  # Fetch OID. Returns OID or nil
  def get_oid(component_id, authpath)
    @http = Net::HTTP.new(OLIVIA.host, OLIVIA.port)
    @http.read_timeout = 120

    # The first two attempts represent current correct practice
    # DRS2 objects look like these, DRS1 SHOULD going forward
    oid_html = if res = try_request(component_id, authpath,    role: "DELIVERABLE", quality: "NA")
                 res.body
               elsif res = try_request(component_id, authpath, role: "DELIVERABLE", quality: "5")
                 res.body
               # The next three attempts represent common legacy practice in DRS1
               elsif res = try_request(component_id, authpath)
                 res.body
               # A number of PDS records have malformed component IDs with a '-METS' suffix. ಠ_ಠ
               elsif res = try_request("#{component_id}-METS", authpath)
                 res.body
               elsif res = try_request(component_id, authpath, quality: "5")
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
    http = Net::HTTP.new(OLIVIA.host, OLIVIA.port)
    http.read_timeout = 120

    logger.info "Fetch URNs via OLIVIA for #{oid} at #{urns_path(oid)}"
    if (res = http.request(Net::HTTP::Get.new(urns_path(oid)))).code == "200"
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

  # Fetches URNs for objects whose URNs point at PDS objects rather than files
  def get_drs2_pds_urns(component_id, authpath)
    http = Net::HTTP.new(OLIVIA.host, OLIVIA.port)
    http.read_timeout = 120

    logger.info "Fetch URNs from DRS2 for #{authpath}: #{component_id}"
    if (res = http.request(Net::HTTP::Get.new(urns2_path(component_id, authpath)))).code == "200"
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
    @attempts = 0 # tracking variable used for logging in #try_request
    oid = urns = nil
    finding_aid = FindingAid.find(finding_aid_id)
    component = finding_aid.components.find_by_cid(component_id)
    authpath = component.settings['owner_code']
    logger.info "Fetching: #{authpath} : #{component_id}'s OID"
    if (oid = get_oid(component_id, authpath))
      get_urns(oid).each{|urn| component.digitizations.find_or_create_by(urn: urn) }
    elsif not (urns = get_drs2_pds_urns(component_id, authpath)).empty?
      urns.each{|urn| component.digitizations.find_or_create_by(urn: urn) }
    elsif not (urns = get_drs2_pds_urns("#{component_id}-METS", authpath)).empty?
      urns.each{|urn| component.digitizations.find_or_create_by(urn: urn) }  
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
