class FindingAidsController < ApplicationController
  before_action :load_finding_aid, only: [:destroy, :show, :status, :fetch_urns]

  def index
    @finding_aids = FindingAid.all
  end

  def show
  end

  def new
    @finding_aid = FindingAid.new
  end

  def destroy
    @finding_aid.destroy
    redirect_to finding_aids_path, notice: 'Finding aid deleted.'
  end

  def fetch_urns
    @finding_aid.fetch_urns!
    WebsocketRails[:urn_fetch_jobs_progress].trigger :update, @finding_aid.job_status_pcts
    if request.xhr?
      render text: 'true'
    else
      redirect_to finding_aid_path(@finding_aid)
    end
  end

  def status
    render json: @finding_aid.job_status_pcts
  end

  private
  
  def load_finding_aid
    @finding_aid = FindingAid.find(params[:id])
  end
end
