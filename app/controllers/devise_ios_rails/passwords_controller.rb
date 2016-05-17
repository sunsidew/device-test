require 'simple_token_authentication/entity'

module DeviseIosRails
  class PasswordsController < Devise::PasswordsController
    include SimpleTokenAuthentication::TokenAuthenticationHandler

    def update
      super# and return if authenticate_entity_from_token!(entity).nil?
      user = DeviseIosRails::ChangePasswordService.new(
        send("current_#{resource_name}"),
        params[resource_name]
      ).call!

      session[:current_user] = nil
      
      # respond_to do |format|
      #   format.html {
      #     super# and return if authenticate_entity_from_token!(entity).nil?
      #     user = DeviseIosRails::ChangePasswordService.new(
      #       send("current_#{resource_name}"),
      #       params[resource_name]
      #     ).call!

      #     sign_out(current_user)
      #     redirect_to "/msg", notice: "이메일을 확인해주세요." and return
      #     # respond_with user
      #     # @user = User.find_by_reset_password_token(params[:user][:reset_password_token])

      #     # unless @user.nil?
      #     #   puts "update_test"
      #     #   @user.password = params[:user][:password]
      #     #   @user.save
      #     # else
      #     #   resource.errors.messages.last.first = '비밀번호 변경 실패'
      #     #   respond_with resource
      #     # end
      #   }
      #   format.json do
      #     super and return if authenticate_entity_from_token!(entity).nil?
      #     user = DeviseIosRails::ChangePasswordService.new(
      #       send("current_#{resource_name}"),
      #       params[resource_name]
      #     ).call!

      #     respond_with user
      #   end
      # end
    end

    private

    def entity
      SimpleTokenAuthentication::Entity.new(resource_class)
    end

    def after_sending_reset_password_instructions_path_for(resource_name)
      #return your path
      "/msg"
    end
  end
end
