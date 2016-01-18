module DeviseIosRails
  class OauthController < DeviseController
    skip_before_action :verify_authenticity_token

    respond_to :json

    def all
      if resource_params[:uid] && resource_params[:oauth_token]
        respond_with resource_class.from_oauth(resource_params)
      else
        record.errors.add :uid, 'Uid must be filled in.' unless resource_params[:uid]
        record.errors.add :oauth_token, 'Oauth token must be filled in.' unless resource_params[:oauth_token]
      end
    end

    alias_method :facebook, :all
    alias_method :google,   :all

    private

    def resource_params
      params.require(resource_name).permit(:email, :provider, :uid, :oauth_token, :nickname, :gender, :birthyear, :thumbimg, :thumbtype, :device_token, :device_type, :actualname, :phonenumber)
    end
  end
end
