module ApplicationHelper
  def default_meta_tags
    {
      site: "ニワトリとタマゴのワクワク生活",
      reverse: false,
      charset: "utf-8",
      description: "タマゴの面倒を見てあげよう！",
      keywords: "たまご,タマゴ,卵,egg,Egg,鶏,ニワトリ,にわとり,雛,ヒヨコ,ひよこ,ワクワク,育成,ゲーム,Rails,Webアプリ,Webゲーム,Ruby,かわいい,キャラクター",
      canonical: request.original_url,
      separator: "|",
      og: {
        site_name: :site,
        type: "website",
        url: request.original_url,
        image: image_url("og/og_image.png"),
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
