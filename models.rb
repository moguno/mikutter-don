# ユーザーモデル
class DonUser < Retriever::Model
  include Retriever::Model::UserMixin

  register(:don_user, name: Plugin[:"mikutter丼"]._("Mastodon"))

  field.string(:idname, required: true)
  field.string(:name, required: true)
  field.string(:uri, required: true)
  field.string(:profile_image_url, required: true)
end

# メッセージモデル
class DonMessage < Retriever::Model
  include Retriever::Model::MessageMixin

  register(:don_message, name: Plugin[:"mikutter丼"]._("Mastodon"))

  field.string(:description, required: false)
  field.time(:created, required: false)
  field.string(:uri, required: true)
  field.has(:user, DonUser, required: true)

  entity_class Retriever::Entity::ExtendedTwitterEntity
end
