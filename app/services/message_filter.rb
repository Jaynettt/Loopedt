
class MessageFilter
  Result = Struct.new(:blocked, :reason, keyword_init: true)

  NUMBER_WORDS = {
    "zero" => "0",
    "oh" => "0",
    "o" => "0",
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9"
  }.freeze

  SOCIAL_PLATFORMS = %w[
    instagram facebook tiktok snapchat twitter x
    telegram whatsapp discord
  ].freeze

  CONTACT_PATTERNS = {
    email: /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i,

    url: %r{
      (https?://|www\.|bit\.ly/|tinyurl\.com/|t\.me/|
      instagram\.com/|facebook\.com/|tiktok\.com/|
      snapchat\.com/|wa\.me/|telegram\.me/)
    }ix,

    phone: /(?<!\w)(?:\+?\d[\d\s().-]{6,}\d)(?!\w)/,

    social_handle: /(?<!\w)@[a-zA-Z0-9._]{2,}/,

    contact_request: /\b(dm me|message me privately|text me|call me|whatsapp me|contact me privately|reach me outside|add me on)\b/i
  }.freeze

  def initialize(body)
    @body = body.to_s
  end

  def call
    CONTACT_PATTERNS.each do |reason, pattern|
      return Result.new(blocked: true, reason: reason) if @body.match?(pattern)
    end

    return Result.new(blocked: true, reason: :phone_in_words) if phone_number_in_words?

    return Result.new(blocked: true, reason: :contact_request) if contact_information_request?

    return Result.new(blocked: true, reason: :social_username) if social_username?

    Result.new(blocked: false, reason: nil)
  end

  private

  def phone_number_in_words?
    words = @body.downcase.scan(/[a-z]+|\d+/)

    number_sequences = []
    current_sequence = +""

    words.each do |word|
      if NUMBER_WORDS.key?(word)
        current_sequence << NUMBER_WORDS[word]
      elsif word.match?(/\A\d+\z/)
        current_sequence << word
      else
        number_sequences << current_sequence
        current_sequence = +""
      end
    end

    number_sequences << current_sequence

    number_sequences.any? do |sequence|
      sequence.length >= 7
    end
  end

  def contact_information_request?
    patterns = [
      /\b(?:what(?:'s| is)|give me|send me|share|drop|provide|can i have|may i have|do you have)\b.{0,45}\b(?:phone|number|digits|contact|whatsapp|email|e-mail|instagram|facebook|tiktok|snapchat|telegram|discord|socials|handle|username|address|location|where you live)\b/i,

      /\b(?:your|seller'?s?|buyer'?s?)\s+(?:phone|number|digits|contact|whatsapp|email|socials|handle|username|address|location)\b/i,

      /\b(?:where do you live|where are you based|what is your address|what's your address|where can i find you|talk outside this app|contact you outside|message you privately|meet outside the app)\b/i,

      /\b(?:drop|share|send|give)\s+(?:your\s+)?(?:digits|socials|contact|location|address)\b/i,

      /\b(?:send|share|drop)\s+(?:me\s+)?(?:your\s+)?(?:pin|live location|home address)\b/i,

      /\b(?:can we|let's|lets)\s+(?:chat|talk|communicate)\s+(?:on|via|through|outside)\s+(?:whatsapp|instagram|telegram|facebook|snapchat|tiktok|discord|another app)\b/i,

      /\b(?:move|take)\s+(?:this|our conversation|the conversation)\s+(?:to|onto)\s+(?:whatsapp|instagram|telegram|another app)\b/i
    ]

    patterns.any? { |pattern| @body.match?(pattern) }
  end
    def social_username?
      platforms = SOCIAL_PLATFORMS.join("|")

      patterns = [
        /\b(?:find me|follow me|add me)\s+on\s+(?:#{platforms})\s+[\w.]{3,30}\b/i,

        /\bmy\s+(?:#{platforms})\s+(?:is|handle|username|account)\s+[\w.]{3,30}\b/i,

        /\b(?:#{platforms})\s+(?:username|handle|account)\s+(?:is\s+)?[\w.]{3,30}\b/i
      ]

      patterns.any? { |pattern| @body.match?(pattern) }
    end

end
