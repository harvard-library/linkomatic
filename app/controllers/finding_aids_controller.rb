class FindingAidsController < ApplicationController
  before_action :load_finding_aid, only: [:destroy, :edit, :show, :status, :fetch_urns, :validate]
  before_action :load_project, only: [:create, :new]

  def index
    @finding_aids = current_user.finding_aids
  end

  def show
    respond_to do |format|
      format.html
      format.xml
    end
  end

  def edit
  end

  def new
    @finding_aid = FindingAid.new
  end

  def create
    if @project
      @finding_aid = @project.finding_aids.build(finding_aid_params)
    else
      @finding_aid = current_user.projects.first.finding_aids.build(finding_aid_params)
    end
    if @finding_aid.save
      redirect_to edit_finding_aid_path(@finding_aid), notice: 'Finding aid successfully created'
    end
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

  def validate
    begin
      @errors = @finding_aid.validation_errors
    rescue
      redirect_to edit_finding_aid_path(@finding_aid), alert: "Sorry, we could not attempt validation. Probably couldn't fetch the schema."
    end
  end

  private
  
  def load_finding_aid
    @finding_aid = FindingAid.find(params[:id])
  end

  def load_project
    if params[:project_id]
      @project = Project.find(params[:project_id])
    end
  end

  def finding_aid_params
    params.require(:finding_aid).permit(:name, :url, :uploaded_ead)
  end
end
