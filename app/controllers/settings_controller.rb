class SettingsController < ApplicationController
  before_action :load_parent, :load_setting

  def update
    respond_to do |format|
      if @setting.update(setting_params)
        format.html { redirect_to @setting, notice: 'Settings were successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
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

  def load_setting
    @setting = Setting.find params[:id]
  end

  def setting_params
    params.require(:setting).permit(:link_text, :thumbnails, :thumbnail_url)
  end
end
