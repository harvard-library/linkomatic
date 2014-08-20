class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_user!
  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  def with_format(format, &block)
    old_formats = formats
    begin
      self.formats = [format]
      return block.call
    ensure
      self.formats = old_formats
    end
  end

  protected

  def configure_devise_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(
        :password,
        :current_password,
        :password_confirmation,
        setting_attributes: [ :link_text, :thumbnails, :thumbnail_url ]
      )
    end
  end
end
