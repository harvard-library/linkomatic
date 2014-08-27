class JobsController < WebsocketRails::BaseController
  def register
    controller_store[:finding_aid_id] = message[:finding_aid_id]
    status
  end

  def new
    @finding_aid = FindingAid.find(controller_store[:finding_aid_id])
    @finding_aid.fetch_urns!
    statuses = @finding_aid.job_status_percentages
    trigger_success statuses
  end

  def complete
    @finding_aid = FindingAid.find(controller_store[:finding_aid_id])
    @finding_aid.urn_fetch_jobs[message[:jid]] = 'complete'
    @finding_aid.save!
    status
  end

  def status
    @finding_aid = FindingAid.find(controller_store[:finding_aid_id])
    statuses = @finding_aid.job_status_percentages
    send_message :status, statuses, namespace: :fetch_job
  end
end
