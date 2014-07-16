class ProjectsController < ApplicationController
  before_action :load_project, only: [:show, :edit]

  def index
    @projects = current_user.projects
  end

  def show
  end

  def edit
  end

  private
  
  def load_project
    @project = Project.find(params[:id])
  end
end
