module DeviseIosRails
  module OAuth
    def self.included receiver
      receiver.extend ClassMethods
      receiver.validates_with OauthTokenValidator, unless: 'provider.blank?'
      receiver.validates :uid, uniqueness: { scope: :provider },
                               allow_nil: true, allow_blank: true
    end

    def email_required?
      super && password_required?
    end

    def password_required?
      super && provider.blank?
    end

    module ClassMethods
      def from_oauth attributes
        where(attributes.slice(:uid, :provider)).first_or_create do |user|
          user.uid         = attributes[:uid]
          user.provider    = attributes[:provider]
          user.oauth_token = attributes[:oauth_token]

          user.email = attributes[:email]
          user.oauth_email = attributes[:email]

          user.nickname = attributes[:nickname]
          user.phonenumber = attributes[:phonenumber]
          user.device_type = attributes[:device_type]
          user.device_token = attributes[:device_token]
          user.thumbimg = attributes[:thumbimg]
          user.thumbtype = attributes[:thumbtype]
        end
      end
    end
  end
end
