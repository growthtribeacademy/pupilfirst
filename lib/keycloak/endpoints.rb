module Keycloak
  class Endpoints
    attr_reader :domain, :realm, :client_id, :client_secret
    def initialize
      @domain = CONFIG[:domain]
      @realm = CONFIG[:realm]
      @client_id = CONFIG[:client_id]
      @client_id = CONFIG[:client_id]
    end

    def openid_config_uri
      openid_config_uri = URI(domain)
      openid_config_uri.path = "/realms/#{realm}/.well-known/openid-configuration"
      openid_config_uri
    end

    def openid_config
      return @openid_config if @openid_config

      res = Faraday.get(openid_config_uri.to_s)
      if res.status == 200
        @openid_config = MultiJson.load(res.body)
      else
        raise FailedRequestError.new 'Failed to fetch Keycloak\'s openid config'
      end
    end

    def token
      openid_config['token_endpoint']
    end

    def token_introspection
      openid_config['introspection_endpoint']
    end

    def end_session
      openid_config['end_session_endpoint']
    end

    def admin_users
      uri = URI(domain)
      uri.path = admin_users_path
      uri
    end

    def fetch_user(id)
      uri = URI(domain)
      uri.path = "#{admin_users_path}/#{id}"
      uri
    end

    def reset_password(id)
      uri = URI(domain)
      uri.path = "#{admin_users_path}/#{id}/reset-password"
      uri
    end

    private

    def admin_users_path
      "/admin/realms/#{realm}/users"
    end
  end
end
