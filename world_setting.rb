Plugin.create(:"mikutter丼") {
  world_setting(:mastodon, _("Mastodon")) {
    input(_("インスタンス"), :instance)
    label(_("（https://pawoo.netの様に指定してください）"))
    input(_("ユーザー名"), :user)
    input(_("パスワード"), :password)

    result = await_input

    puts "-----------------------------"
    puts result

    world = DonWorld.build("mikutter丼", result[:instance], result[:user], result[:password])

    label "#{world[:instance]}に#{world[:user]}としてログインします。"

    world
  }
}
