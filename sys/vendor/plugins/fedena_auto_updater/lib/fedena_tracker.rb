class FedenaTracker
  require 'socket'
  require 'net/http'

  TRACKBACK_URL = "http://clients.foradian.org/track"
  AUTO_UPDATE_SETTINGS_FILE = "#{File.dirname(__FILE__)}/../config/auto_update_settings.yml" 

  def initialize
    @hostname = Socket.gethostname
    @username = fetch_username_from_settings
    @path = Rails.root
  end

  def track_installation
    params = {:u => @username,:p => @path,:h => @hostname}
    Net::HTTP.post_form(URI(TRACKBACK_URL),params)
  end

  private 

  def fetch_username_from_settings
    return YAML.load_file(AUTO_UPDATE_SETTINGS_FILE)["settings"]["basic_auth_user"]
  end

end