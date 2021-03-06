require 'keycloak'

module Users
  module Sessions
    class ResetPasswordForm < Reform::Form
      property :token, validates: { presence: true }
      property :new_password, validates: { presence: true, length: { minimum: 8, maximum: 128 } }
      property :confirm_password, validates: { presence: true }

      validate :password_should_match
      validate :user_must_exist

      def save
        @user.update!(password: new_password, reset_password_token: nil)
        if keycloak_user?
          set_keycloak_password(new_password)
        end
      end

      def user
        @user ||= User.find_by(reset_password_token: token)
      end

      private

      def user_must_exist
        return if user.present?

        errors[:token] << "doesn't appear to be valid. Please refresh the page and try again."
      end

      def password_should_match
        return if new_password == confirm_password

        errors[:password] << 'does not match confirmation password. Please try again.'
      end

      def keycloak_user?
        Rails.configuration.keycloak_client.fetch_user(@user.email)
        true
      rescue Keycloak::FailedRequestError => e
        Rails.logger.debug("Keycloak user dont exist for email #{@user.email} - #{e.message}")
        false
      end
      # rubocop:disable Naming/AccessorMethodName
      def set_keycloak_password(password)
        Rails.configuration.keycloak_client.set_user_password(@user.email, password)
      end
      # rubocop:enable Naming/AccessorMethodName
    end
  end
end
