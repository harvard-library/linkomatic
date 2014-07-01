class ComponentsController < ApplicationController
  before_action :load_component, only: [:edit]
  def edit
  end

  def load_component
    @component = Component.find(params[:id])
  end
end
