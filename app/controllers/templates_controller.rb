class TemplatesController < ApplicationController
  before_action :load_template, only: [:edit]

  def new
    @template = Template.new
  end

  def edit
  end

  def update
  end

  private

  def load_template
    @template = Template.find(params[:id])
  end
end
