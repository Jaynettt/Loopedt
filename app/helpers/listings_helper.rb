module ListingsHelper
  def description_with_hashtags(description)
    parts = description.to_s.split(/(#[[:alnum:]_]+)/)

    safe_join(
      parts.map do |part|
        if part.match?(/\A#[[:alnum:]_]+\z/)
          link_to part,
                  listings_path(search: part),
                  class: "listing-hashtag"
        else
          part
        end
      end
    )
  end
end
