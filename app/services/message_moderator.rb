
class MessageModerator
  CONTACT_PATTERNS = [
    /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i,
    /(?:https?:\/\/|www\.)\S+/i,
    /\b(?:instagram|insta|whatsapp|telegram|snapchat|facebook|tiktok)\b/i,
    /\b(?:call|text|whatsapp|dm|message me|contact me)\b.{0,40}\b(?:on|at|me|my)\b/i,
    /(?:\+?\d[\d\s().-]{7,}\d)/
  ].freeze

  def self.moderate(body)
    return :blocked if body.blank?

    if CONTACT_PATTERNS.any? { |pattern| body.match?(pattern) }
      :blocked
    else
      :approved
    end
  end
end
