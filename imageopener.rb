Plugin.create(:"mikutter丼") {
  if UserConfig[:don_instance]
    defimageopener(UserConfig[:don_instance], /^#{UserConfig[:don_instance]}\/media\//) { |url|
      open(url)
    }
  end
}
