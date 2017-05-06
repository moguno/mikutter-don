require "fnv"

module IdentityUtils

  # URIからIDを作る
  def id
    # 軽いと噂のFNV1ハッシュ関数
    @fnv ||= FNV.new
    @fnv.fnv1a_64(self.uri)
  end
end

# ユーザーモデル
class DonUser < Retriever::Model
  include Retriever::Model::UserMixin
  include Retriever::Model::Identity
  include IdentityUtils

  register(:don_user, name: Plugin[:"mikutter丼"]._("Mastodon"))

  field.string(:idname, required: true)
  field.string(:name, required: true)
  field.string(:uri, required: true)
  field.string(:profile_image_url, required: true)
end

# メッセージモデル
class DonMessage < Retriever::Model
  include Retriever::Model::MessageMixin
  include Retriever::Model::Identity
  include IdentityUtils

  register(:don_message, name: Plugin[:"mikutter丼"]._("Mastodon"))

  field.string(:description, required: false)
  field.time(:created, required: false)
  field.string(:uri, required: true)
  field.has(:user, DonUser, required: true)

  entity_class Retriever::Entity::ExtendedTwitterEntity
end

# ワールドモデル
class DonWorld < Retriever::Model
  register(:mastodon, name: "Mastodon")

  field.string(:id, required: true)
  field.string(:slug, required: true)
  alias_method(:name, :slug)
  field.string(:instance, required: true)
  field.string(:token, required: true)

  def self.build(app_name, instance, user, password)
    tmp_client = Mastodon::REST::Client.new(base_url: instance)
    app = tmp_client.create_app(app_name, "urn:ietf:wg:oauth:2.0:oob", "read write follow")

    oauth = OAuth2::Client.new(app.client_id, app.client_secret, site: instance)
    token = oauth.password.get_token(user, password, scope: "read write follow")

    client = Mastodon::REST::Client.new(base_url: instance, bearer_token: token.token)

    me = client.verify_credentials

    self.new(
      id: "mastodon#{me.id}",
      slug: "mastodon#{me.id}",
      instance: instance,
      token: token.token,
      user: me.username
    )
  end

  def inspect
    "#{self[:user]}@#{self[:instance]}"
  end
end
