module DeviseIosRails
  class ChangePasswordService
    attr_reader :params, :current_user
    def initialize(current_user, params)
      @params = Hash(params)
      @current_user = current_user
    end

    def call!
      return if current_user.nil?
      current_user.password = snake_case_params[:password]
      current_user.password_confirmation = snake_case_params[:password_confirmation]
      if current_user.password == current_user.password_confirmation
        current_user.password = cryptN(current_user.password, 10)
        current_user.password_confirmation = current_user.password
        current_user.save
        current_user
      else
        return
      end
    end

    private

    def snake_case_params
      params.deep_transform_keys do |key|
        underscore = key.to_s.underscore
        underscore.to_sym
      end
    end

    def cryptN(target, n)
      tempSave = Digest::SHA256.hexdigest "bookmSaltkey"
      tempSave += target.to_s

      n.times do
        tempSave = Digest::SHA256.hexdigest tempSave
      end
      
      return tempSave
    end
  end
end
