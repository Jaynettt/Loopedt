
require "net/http"
require "json"
require "uri"
require "securerandom"

class PaystackService
  BASE_URL = "https://api.paystack.co"

  class Error < StandardError; end

  def initialize
    @secret_key =
      Rails.application.credentials.dig(:paystack, :secret_key)

    raise Error, "Paystack secret key is missing" if @secret_key.blank?
  end

  def initialize_transaction(checkout:, email:, callback_url:)
    reference = "loopedt_#{checkout.id}_#{SecureRandom.hex(8)}"

    checkout.update!(payment_reference: reference)

    amount_kobo = (BigDecimal(checkout.total_amount.to_s) * 100).round.to_i

    response = post_request(
      "/transaction/initialize",
      {
        email: email,
        amount: amount_kobo,
        currency: "NGN",
        reference: reference,
        callback_url: callback_url,
        metadata: {
          checkout_id: checkout.id,
          buyer_id: checkout.buyer_id
        }
      }
    )

    response.fetch("data")
  end

  def verify_transaction(reference:)
    response = get_request(
      "/transaction/verify/#{URI.encode_www_form_component(reference)}"
    )

    response.fetch("data")
  end

  private

  def post_request(path, body)
    uri = URI("#{BASE_URL}#{path}")

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{@secret_key}"
    request["Content-Type"] = "application/json"
    request.body = body.to_json

    send_request(uri, request)
  end

  def get_request(path)
    uri = URI("#{BASE_URL}#{path}")

    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{@secret_key}"

    send_request(uri, request)
  end

  def send_request(uri, request)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 30

    response = http.request(request)
    result = JSON.parse(response.body)

    unless response.is_a?(Net::HTTPSuccess) && result["status"] == true
      raise Error, result["message"] || "Paystack request failed"
    end

    result
  rescue JSON::ParserError
    raise Error, "Paystack returned an invalid response"
  rescue Net::OpenTimeout, Net::ReadTimeout, SocketError,
         Errno::ECONNREFUSED, OpenSSL::SSL::SSLError => e
    raise Error, "Could not connect to Paystack: #{e.message}"
  end
end
