require "mastodon"
require "oauth2"

require_relative "monkey_patches"
require_relative "datasource"
require_relative "models"

Plugin.create(:"mikutter-don") {
  def poll_timelines
    loop {
begin
      messages = @client.public_timeline.map { |_|
        user = DonUser.new(
          name: _.attributes["account"]["username"],
          idname: _.attributes["account"]["acct"],
          uri: _.attributes["account"]["url"],
          profile_image_url: _.attributes["account"]["avatar"]
        )

        p _.attributes["url"]
        p _.attributes["created_at"]
        p _.attributes["content"]
        p user

        message = DonMessage.new(
          uri: _.attributes["url"],
          created: _.attributes["created_at"],
          description: _.attributes["content"],
          user: user
        )
      
        message
      }

      Delayer.new {
        Plugin.call(:extract_receive_message, :mikutter_don, messages)
      }

      break
rescue => e
puts e
puts e.backtrace
end

      sleep(10)
    }
  end

  on_boot { |service|
    if service == Service.primary
      Thread.new {
        tmp_client = Mastodon::REST::Client.new(base_url:"https://pawoo.net")
        app = tmp_client.create_app("mikutter-don", "urn:ietf:wg:oauth:2.0:oob", "read write follow")

        oauth = OAuth2::Client.new(app.client_id, app.client_secret, site: "https://pawoo.net")
        token = oauth.password.get_token("shopping@0kn.sakura.ne.jp", "12345678", scope: "read write follow")

        @client = Mastodon::REST::Client.new(base_url:"https://pawoo.net", bearer_token: token.token)
      }.next {
        Mastodon::REST::Request.new(@client, "get", "/api/v1/streaming/public", {}).perform { |buf|
        p buf
      }
        

        #poll_timelines
      }
    end
  }
}
