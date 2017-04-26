require "mastodon"
require "oauth2"
require "sanitize"

require_relative "monkey_patches"
require_relative "datasource"
require_relative "models"
require_relative "settings"

Plugin.create(:"mikutter丼") {

  def get_client(instance, user, password)
    tmp_client = Mastodon::REST::Client.new(base_url: instance)
    app = tmp_client.create_app("mikutter丼", "urn:ietf:wg:oauth:2.0:oob", "read write follow")

    oauth = OAuth2::Client.new(app.client_id, app.client_secret, site: instance)
    token = oauth.password.get_token(user, password, scope: "read write follow")

    client = Mastodon::REST::Client.new(base_url: instance, bearer_token: token.token)

    return client
  end

  on_period { |service|
    if service == Service.primary
      Thread.new {
        begin
          if !@client
            @client = get_client(UserConfig[:don_instance], UserConfig[:don_user], UserConfig[:don_password])
          end

          @client.streaming_public_timeline { |event, data|
            if event == "update"
              avatar_url = if data.attributes["account"]["avatar"] =~ /^\//
                UserConfig[:don_instance] + "/" + data.attributes["account"]["avatar"]
              else
                data.attributes["account"]["avatar"]
              end

              user = DonUser.new(
                name: data.attributes["account"]["username"],
                idname: data.attributes["account"]["acct"],
                uri: data.attributes["account"]["url"],
                profile_image_url: avatar_url
              )

              message = DonMessage.new(
                uri: data.attributes["url"],
                created: Time.parse(data.attributes["created_at"]).localtime,
                description: Sanitize.clean(data.attributes["content"]),
                user: user
              )
      
              Delayer.new {
                Plugin.call(:extract_receive_message, :"mikutter丼", [message])
              }
            end
          }
        rescue => e
          puts e
          puts e.backtrace
        end
      }
    end
  }
}
