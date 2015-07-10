class OauthTokenValidator < ActiveModel::Validator
  def validate(record)
    send "validate_#{record.provider}_token", record
  rescue Faraday::ConnectionFailed, Faraday::TimeoutError
    record.errors.add :oauth_token, 'could not check token authenticity'
  end

  private

  def validate_facebook_token(record)
    graph = Koala::Facebook::API.new record.oauth_token
    userinfo = graph.get_object 'me'
    if userinfo['id'] != record.uid
      record.errors.add :uid, 'your uid is not identical with uid_from_token'
    end
  rescue Koala::Facebook::AuthenticationError => e
    record.errors.add :oauth_token, e.fb_error_message
  end

  def validate_google_token(record)
    conn = Faraday.new url: 'https://www.googleapis.com'
    resp = conn.get "/oauth2/v1/tokeninfo?access_token=#{record.oauth_token}"
    if resp.status == 400
      error_description = JSON.parse(resp.body)['error_description']
      record.errors.add :oauth_token, error_description
    elsif JSON.parse(resp.body)['user_id'] != record.uid
      record.errors.add :uid, 'your uid is not identical with uid_from_token'
    end
  end
end
