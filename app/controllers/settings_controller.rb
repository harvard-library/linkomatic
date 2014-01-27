class SettingsController < ApplicationController
  before_action :load_parent

  def edit
  end

  private

  def load_parent
    if params[:digitization_id]
      @parent = Digitization.find params[:digitization_id]
    elsif params[:component_id]
      @parent = Component.find params[:component_id]
    elsif params[:finding_aid_id]
      @parent = FindingAid.find params[:finding_aid_id]
    elsif params[:project_id]
      @parent = Project.find params[:project_id]
    else
      @parent = current_user
    end
  end
end
