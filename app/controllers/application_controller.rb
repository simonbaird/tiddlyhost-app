
class ApplicationController < ActionController::Base
  before_action :redirect_www_requests
  before_action :permit_devise_params, if: :devise_controller?

  protected

  def send_favicon(favicon_asset)
    send_file(local_asset_path(favicon_asset),
      type: 'image/vnd.microsoft.icon', disposition: 'inline')
  end

  def download_html_content(html_content, file_name)
    send_data html_content,
      type: 'text/html; charset=utf-8', filename: "#{file_name}.html"
  end

  def main_site_url
    Settings.main_site_url
  end

  def default_url_options
    Rails.application.routes.default_url_options = Settings.url_defaults
  end

  def redirect_www_to
    Settings.url_defaults
  end

  def redirect_www_requests
    redirect_to(redirect_www_to, status: 301) if request.subdomain == 'www'
  end

  def permit_devise_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :username, :use_gravatar])
  end

  def user_is_admin?
    user_signed_in? && current_user.is_admin?
  end
  helper_method :user_is_admin?

  def require_admin_user!
    # Todo: A nicer 403 response
    raise "Unauthorized!" unless user_is_admin?
  end

  # Used for serving custom favicons
  def local_asset_path(asset_name)
    manifest = Rails.application.assets_manifest
    if asset_file = manifest.assets[asset_name]
      # For production with compiled assets
      File.join(manifest.directory, asset_file)
    else
      # For development
      Rails.application.assets[asset_name].filename
    end
  end

  def th_log(msg)
    ThostLogger.thost_logger.info(msg, request)
  end

end
