class FindingAidsController < ApplicationController
  before_action :load_finding_aid, only: [:destroy, :edit, :show, :status, :fetch_urns]
  before_action :load_project, only: [:create]

  def index
    @finding_aids = current_user.finding_aids
  end

  def show
    @doc = @finding_aid.ead
    @doc.css('dao').map(&:remove)
    @doc.css('daogrp').map(&:remove)
    @finding_aid.components.each do |c|
      component_node = @doc.at('#' + c.cid)
      c.digitizations.each do |d|
        component_node << render_to_string(partial: 'digitizations/show.ead.erb', locals: { digitization: d })
      end
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
      @finding_aid = current_user.finding_aids.build(finding_aid_params)
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
    params.require(:finding_aid).permit(:name, :url)
  end
end
