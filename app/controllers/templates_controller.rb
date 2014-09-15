class TemplatesController < ApplicationController
  before_action :authorize_user
  before_action :load_template, only: [:edit, :update]

  def index
    @templates = Template.all
  end

  def new
    @template = Template.new
  end

  def create
    respond_to do |format|
      if Template.create(template_params)
        format.html { redirect_to templates_path, notice: 'Template was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @template.update(template_params)
        format.html { redirect_to templates_path, notice: 'Template was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  private

  def template_params
    params.require(:template).permit(:name, :body)
  end

  def load_template
    @template = Template.find(params[:id])
  end

  def authorize_user
    unless current_user.admin
      redirect_to root_url, { alert: 'You are not authorized to modify templates.' }
    end
  end
end
