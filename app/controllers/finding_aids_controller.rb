class FindingAidsController < ApplicationController
  before_action :load_finding_aid, only: [:destroy, :edit, :show, :status, :fetch_urns, :validate]
  before_action :load_project, only: [:create, :new]

  def index
    @finding_aids = current_user.finding_aids
  end

  def show
    respond_to do |format|
      format.html
      format.xml do
        response.headers['Content-Disposition'] = "attachment; filename=#{@finding_aid.uploaded_ead_file_name}"
      end
    end
  end

  def edit
  end

  def new
    @finding_aid = FindingAid.new
    if @project.settings['owner_code']
      @finding_aid.build_setting(owner_code: @project.settings['owner_code'])
    end
  end

  def create
    if @project
      @finding_aid = @project.finding_aids.build(finding_aid_params)
    else
      @finding_aid = current_user.projects.first.finding_aids.build(finding_aid_params)
    end
    if @finding_aid.save
      redirect_to edit_finding_aid_path(@finding_aid), notice: 'Finding aid successfully loaded'
    else
      render 'finding_aids/new'
    end
  end

  def destroy
    @finding_aid.destroy
    redirect_to root_path, notice: 'Finding aid removed.'
  end

  def fetch_urns
    @finding_aid.fetch_urns!
    statuses = @finding_aid.job_status_percentages
    WebsocketRails[:urn_fetch_jobs_progress].trigger :update, statuses

    if request.xhr?
      render text: 'true'
    else
      redirect_to finding_aid_path(@finding_aid)
    end
  end

  def status
    render json: @finding_aid.job_status_percentages
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
    params.require(:finding_aid).permit(:name, :url, :uploaded_ead, setting_attributes: [ :link_text, :template_id, :owner_code, :thumbnail_url ])
  end
end
