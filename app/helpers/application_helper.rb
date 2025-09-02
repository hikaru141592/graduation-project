module ApplicationHelper
  def default_meta_tags
    {
      site:         t("app.title"),
      reverse:      false,
      charset:      "utf-8",
      description:  t("meta.description"),
      keywords:     t("meta.keywords"),
      canonical:    request.original_url,
      separator:    "|",
      og: {
        site_name: :site,
        type:   "website",
        url:    request.original_url,
        image:  image_url("og/og_image.png"),
        description: :description,
        locale: "ja_JP"
      }
    }
  end

  def page_meta_tags
    tags = default_meta_tags.dup
    if content_for?(:title)
      tags[:title] = content_for(:title)
      tags[:reverse] = true
    end
    tags
  end

  def effective_image_path(path)
    original = path.to_s
    return original unless current_user.image_change?

    changed = original.gsub(/temp-/, "")
    asset_path = Rails.root.join("app", "assets", "images", changed)
    File.exist?(asset_path) ? changed : original
  end
end
