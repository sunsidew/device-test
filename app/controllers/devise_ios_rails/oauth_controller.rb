module DeviseIosRails
  class OauthController < DeviseController
    skip_before_action :verify_authenticity_token

    respond_to :json

    def all
      puts "1"
      if resource_params[:uid] && resource_params[:oauth_token]
        puts "2"
        record = User.new
        record.uid = resource_params[:uid]
        record.oauth_token = resource_params[:oauth_token]
        puts "3"
        before_check_facebook_token(record)
        record = resource_class.from_oauth(resource_params) if record.errors.blank?
        respond_with record
      else
        puts "4"
        record = User.new
        record.errors.add :uid, 'Uid must be filled in.' unless resource_params[:uid]
        record.errors.add :oauth_token, 'Oauth token must be filled in.' unless resource_params[:oauth_token]
        respond_with record
      end
      puts "5"
    end

    def before_check_facebook_token(record)
      graph = Koala::Facebook::API.new record.oauth_token
      userinfo = graph.get_object 'me'
      if userinfo['id'] != record.uid
        record.errors.add :uid, 'your uid is not identical with uid_from_token'
      end
    rescue Koala::Facebook::AuthenticationError => e
      record.errors.add :oauth_token, e.fb_error_message
    end

    alias_method :facebook, :all
    alias_method :google,   :all

    private

    def resource_params
      params.require(resource_name).permit(:email, :provider, :uid, :oauth_token, :nickname, :gender, :birthyear, :thumbimg, :thumbtype, :device_token, :device_type, :phonenumber)
    end
  end
end
