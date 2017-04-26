Plugin.create(:"mikutter丼") {
  # データソース
  filter_extract_datasources { |datasources|
    datasources[:"mikutter丼"] = _("Mastodon")

    [datasources]
  }
}
