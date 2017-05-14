require "mastodon"
require "oauth2"
require "sanitize"
require "thread"

require_relative "monkey_patches"
require_relative "datasource"
require_relative "models"
require_relative "settings"
require_relative "imageopener"
require_relative "command"

Plugin.create(:"mikutter丼") {
  @timelines = [
    [ :streaming_local_timeline, "ローカルタイムライン" ],
    [ :streaming_public_timeline, "連邦タイムライン" ],
    [ :streaming_user_timeline, "ユーザタイムライン" ],
  ]

  def message_factory_start(&xproc)
    queue = Queue.new

    Thread.new {
      loop {
        status = []

        10.times {
          status << queue.deq

          if queue.empty?
            break
          end
        }

        if status.length != 0
          xproc.(status)
        end

        sleep(1.0)
      }
    }

    return queue
  end

  def get_client(instance, user, password)
    tmp_client = Mastodon::REST::Client.new(base_url: instance)
    app = tmp_client.create_app("mikutter丼", "urn:ietf:wg:oauth:2.0:oob", "read write follow")

    oauth = OAuth2::Client.new(app.client_id, app.client_secret, site: instance)
    token = oauth.password.get_token(user, password, scope: "read write follow")

    client = Mastodon::REST::Client.new(base_url: instance, bearer_token: token.token)

    return client
  end

  def to_message(mastodon_status)
    target = if mastodon_status.attributes["reblog"]
      mastodon_status.attributes["reblog"]
    else
      mastodon_status.attributes
    end

    modified_time = mastodon_status.attributes["created_at"]

    avatar_url = if target["account"]["avatar"] =~ /^\//
      UserConfig[:don_instance] + "/" + target["account"]["avatar"]
    else
      target["account"]["avatar"]
    end

    display_name = if target["account"]["display_name"] != ""
      target["account"]["display_name"]
    else
      target["account"]["username"]
    end

    user = DonUser.new_ifnecessary(
      id:  target["account"]["id"],
      name: display_name,
      idname: target["account"]["acct"],
      uri: target["account"]["url"],
      profile_image_url: avatar_url
    )

    message = DonMessage.new_ifnecessary(
      id:  target["id"],
      uri: target["url"],
      created: Time.parse(target["created_at"]).localtime,
      modified: Time.parse(modified_time).localtime,
      description: Sanitize.clean(target["content"]),
      favorite_count: target["favourites_count"],
      retweet_count: target["reblogs_count"],
      user: user
    )

    return message
  end

  on_period { |service|
    if service == Service.primary
      Thread.new {
        begin
          if !@client
            @client = get_client(UserConfig[:don_instance], UserConfig[:don_user], UserConfig[:don_password])
          end

          @timelines.each { |method, name|
            Thread.new {
              tmp = message_factory_start { |status|
                messages = status.map { |_| to_message(_) }

                Plugin.call(:extract_receive_message, :"mikutter丼/#{name}", messages)
              }

              Thread.current[:queue] = tmp

              @client.send(method) { |event, data|
                if event == "update"
                  Thread.current[:queue].enq(data)
                end
              }
            }
          }
        rescue => e
          puts e
          puts e.backtrace
        end
      }
    end
  }
}
