class FedenaAutoUpdaterController < ApplicationController
  before_filter :login_required
  before_filter :load_updater
  before_filter :load_last_update
  before_filter :verify_build_trigger_token ,:only  => :build_trigger
  skip_before_filter :login_required ,:verify_authenticity_token, :only => :build_trigger

  def index
  end

  def pull_changes
    resp = @updater.pull_remote_changes_and_restart
    load_last_update
    render :partial=>"updates",:locals=>{:message=>resp}
  end

  def check_updates
    @update_available = @updater.check_for_remote_updates
    render :partial=>"updates"
  end

  def setup_git
    resp =  @updater.create_local_git_repo
    render :partial=>"updates",:locals=>{:message=>resp}
  end

  def build_trigger
    resp = @updater.pull_remote_changes_and_restart
    render :text =>  resp
  end

  private

  def load_updater
    @updater = FedenaAutoUpdater.new
  end

  def load_last_update
    @last_update  = Configuration.find(:first,:conditions=>{:config_key=>'LastSuccessfulUpdate'})
  end

  def verify_build_trigger_token
    if params[:build_trigger_token].blank? || params[:build_trigger_token] != @updater.build_trigger_key
      render :text => 'Invalid build token',:status  => :forbidden
    end
  end

end
