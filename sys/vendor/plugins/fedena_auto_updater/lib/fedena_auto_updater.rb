require 'translator'

class FedenaAutoUpdater
  DIR = RAILS_ROOT unless defined?(DIR)
  AUTO_UPDATE_SETTINGS_FILE = "#{File.dirname(__FILE__)}/../config/auto_update_settings.yml" unless defined?(AUTO_UPDATE_SETTINGS_FILE)
  GIT_PATH = "/usr/bin/git" unless defined?(GIT_PATH)

  def initialize
    @logger = Logger.new("#{RAILS_ROOT}/log/fedena_update.log")
    @logger.info "Intialization Successful"
  end

  def local_git_repo_status
    execute_command("#{GIT_PATH} status")
  end

  def check_local_git_repo_exists?
    if local_git_repo_status.include?("Not a git repo") or check_git_remote_origin?
      false
    else
      true
    end
  end

  def local_git_log
    execute_command("#{GIT_PATH} log --pretty=oneline")
  end

  def update_revision
    resp = compare_remote_and_local_logs
    resp.split(" ").first unless resp.blank?
  end

  def current_revision
    local_git_log.split("\n").first.split(" ").first unless local_git_log.include?('fatal')
  end


  def check_git_remote_origin?
    git_remote_show = execute_command("#{GIT_PATH} remote show")
    git_remote_show.blank?
  end

  def check_auto_update_settings
    if File.exists?(AUTO_UPDATE_SETTINGS_FILE)
      settings = auto_update_settings
      if settings.present? and settings[:settings].present?
        if settings[:settings][:fetch_url].present?
          [:success]
        else
          [:error,"Invalid Fetch URL"]
        end
      else
        [:error,"Invalid Settings"]
      end
    else
      [:error,"File does not exist"]
    end
  end

  def check_valid_local_git_repo
    unless check_local_git_repo_exists?
      return true
    else
    end
  end


  def create_local_git_repo
    initialize_local_git_repo
    if auto_update_settings["fetch_url"].present?
      add_origin = add_origin_to_local_git_repo(get_fetch_url)
      if add_origin.include?("remote origin already exists")
        overwrite_local_repo_if_git_origin_changed
      else
        [:success,"#{I18n.t('local_git_repo_created_successfully')}"]
      end
    else
      [:error,"#{I18n.t('invalid_fetch_url')}"]
    end
  end


  def local_git_repo_origin_url_changed?
    current_fetch_url = execute_command("#{GIT_PATH} remote show origin").gsub("Fetch URL:","").strip!
    !(current_fetch_url==get_fetch_url)
  end

  def overwrite_local_git_repo
    execute_command("#{GIT_PATH} remote rm origin")
    add_origin_to_local_git_repo(get_fetch_url)
    [:success,"#{I18n.t('local_git_repo_created_successfully')}"]
  end

  def overwrite_local_repo_if_git_origin_changed
    if local_git_repo_origin_url_changed?
      overwrite_local_git_repo
    end
  end

  def initialize_local_git_repo
    @logger.info execute_command("#{GIT_PATH} init")
  end

  def add_origin_to_local_git_repo(fetch_url)
    execute_command("#{GIT_PATH} remote add origin #{fetch_url}")
  end

  def auto_update_settings
    settings = YAML::load_file(FedenaAutoUpdater::AUTO_UPDATE_SETTINGS_FILE)
    settings["settings"]
  end

  def get_fetch_url
    if auto_update_settings["use_basic_auth"] == true
      "http://#{auto_update_settings['basic_auth_user']}:#{auto_update_settings['basic_auth_pass']}@#{auto_update_settings['fetch_url']}"
    else
      "http://#{auto_update_settings["fetch_url"]}"
    end
  end

  def fetch_remote_changes
    execute_command("#{GIT_PATH} fetch origin")
  end

  def compare_remote_and_local_logs
    if check_local_git_repo_exists?
      local_changes_log = local_git_log
      if local_changes_log.include?("fatal")
        execute_command("#{GIT_PATH} log origin/master --pretty=oneline ")
      else
        last_local_commit_hash = local_changes_log.split("\n").first.split(" ").first
        execute_command("#{GIT_PATH} log origin/master --pretty=oneline ..#{last_local_commit_hash} ")
      end
    end    
  end

  def check_for_remote_updates
    if check_local_git_repo_exists?
      fetch_resp = fetch_remote_changes
      if fetch_resp.include?('returned error')
        [:error,"#{I18n.t('error_while_fetch')}"]
      else
        remote_changes = compare_remote_and_local_logs
        [remote_changes.present?]
      end
    else
      [:error,"#{I18n.t('local_git_repo_not_found')}"]
    end
  end

  def pull_remote_changes
    @logger.debug "Git pull starting.."
    @logger.info execute_command("#{GIT_PATH} reset --hard origin/master")
    @logger.debug "Git pull complete"
  end
  
  def install_fedena_plugins_and_migrate
    @logger.debug "Installing updates and doing db:migrate"
    resp = execute_command("rake fedena:plugins:install_all RAILS_ENV=#{RAILS_ENV}")
    if defined? DelayedSeedSchool and defined? Delayed::Job
      @logger.debug "Scheduling delayed job for seeding existing schools"
      job = Delayed::Job.enqueue(DelayedSeedSchool.new)
      @logger.debug "Queued job id:#{job.id} at #{job.created_at}"
    end
    @logger.info resp
    if resp.include?('aborted')
      [:error,"#{I18n.t('fedena_update_failed')} - #{resp}"]
    else
      @logger.debug "Fedena updates complete"
      [:success]
    end    
  end

  def restart_passenger
    execute_command("touch tmp/restart.txt")
  end

  def mark_successful_update
    config  = Configuration.find(:first,:conditions=>{:config_key=>'LastSuccessfulUpdate'})
    if config
      config.update_attributes(:config_value=>DateTime.now)
    else
      Configuration.create(:config_key=>"LastSuccessfulUpdate",:config_value=>DateTime.now)
    end
  end

  def pull_remote_changes_and_restart
    pull_remote_changes
    resp = install_fedena_plugins_and_migrate
    if resp[0] == :error
      resp
    else
      restart_passenger
      mark_successful_update
      [:success,"#{I18n.t('fedena_updated_successfully')}"]
    end
  end

  def build_trigger_key
    salt = ActionController::Base.session_options[:secret]
    creds = auto_update_settings['basic_auth_user'] + auto_update_settings['basic_auth_pass']
    Digest::SHA1.hexdigest(salt + creds)
  end 

  def execute_command(cmd)
    begin
      Rush::Box.new[DIR].bash cmd
    rescue Rush::BashFailed => error_msg
      "#{error_msg}"
    end
  end

end
