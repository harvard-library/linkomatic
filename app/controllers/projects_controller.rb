class ProjectsController < ApplicationController
  before_action :load_project, only: [:show, :edit, :update]

  def index
    @projects = current_user.projects
  end

  def new
    @project = Project.new
    @project.build_setting
  end

  def create
    @project = current_user.projects.build(project_params)
    if @project.save
      redirect_to projects_path, notice: 'Project successfully created'
    end
  end

  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to projects_path, notice: 'The project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def edit
  end

  private
  
  def load_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, setting_attributes: [ :link_text, :thumbnails, :thumbnail_url ])
  end
end
