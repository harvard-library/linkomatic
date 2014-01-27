class ProjectsController < ApplicationController
  before_action :load_project, only: [:show]

  def index
    @projects = Project.all
  end

  def show
  end

  private
  
  def load_project
    @project = Project.find(params[:id])
  end
end
