Plugin.create(:"mikutter-don") {
  UserConfig[:don_instance] ||= "https://pawoo.net"
  UserConfig[:don_user] ||= ""
  UserConfig[:don_password] ||= ""

  # 設定画面
  settings(_("丼")) {
    input(_("インスタンスのURL"), :don_instance)
    input(_("ユーザ名"), :don_user)
    input(_("パスワード"), :don_password)
  }
}
