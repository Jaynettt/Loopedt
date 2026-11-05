
class CheckoutFeeCalculator
  SELLER_COMMISSION_RATE =
    BigDecimal(ENV.fetch("LOOPEDT_SELLER_COMMISSION_RATE", "0.05"))

  BUYER_SERVICE_FEE =
    BigDecimal(ENV.fetch("LOOPEDT_BUYER_SERVICE_FEE", "100.00"))

  PAYSTACK_RATE =
    BigDecimal(ENV.fetch("PAYSTACK_LOCAL_RATE", "0.015"))

  PAYSTACK_FIXED_FEE =
    BigDecimal(ENV.fetch("PAYSTACK_LOCAL_FIXED_FEE", "100.00"))

  PAYSTACK_FEE_CAP =
    BigDecimal(ENV.fetch("PAYSTACK_LOCAL_FEE_CAP", "2000.00"))

  PAYSTACK_FIXED_FEE_THRESHOLD =
    BigDecimal(ENV.fetch("PAYSTACK_FIXED_FEE_THRESHOLD", "2500.00"))

  def initialize(cart_items)
    @cart_items =
      if cart_items.respond_to?(:includes)
        cart_items.includes(:listing)
      else
        cart_items
      end
  end

  def calculate
    raise ArgumentError, "Your cart is empty" if @cart_items.empty?

    subtotal = calculate_subtotal
    service_fee = BUYER_SERVICE_FEE
    base_amount = subtotal + service_fee

    total_amount = calculate_gross_amount(base_amount)
    payment_fee = total_amount - base_amount

    {
      subtotal: subtotal,
      service_fee: service_fee,
      payment_fee: payment_fee,
      total_amount: total_amount,
      seller_commissions: calculate_seller_commissions
    }
  end

  private

  def calculate_subtotal
    @cart_items.sum do |item|
      BigDecimal(item.effective_unit_price.to_s) * item.quantity
    end.round(2)
  end

  def calculate_seller_commissions
    @cart_items.group_by { |item| item.listing.user_id }
              .transform_values do |items|
      seller_subtotal = items.sum do |item|
        BigDecimal(item.effective_unit_price.to_s) * item.quantity
      end

      (seller_subtotal * SELLER_COMMISSION_RATE).round(2)
    end
  end

  def calculate_gross_amount(base_amount)
    base_kobo = (base_amount * 100).ceil
    maximum_gross_kobo = base_kobo + (PAYSTACK_FEE_CAP * 100).to_i

    low = base_kobo
    high = maximum_gross_kobo

    while low < high
      middle = (low + high) / 2

      if net_amount(middle) >= base_kobo
        high = middle
      else
        low = middle + 1
      end
    end

    BigDecimal(low) / 100
  end

  def net_amount(gross_kobo)
    gross_kobo - paystack_fee(gross_kobo)
  end

  def paystack_fee(gross_kobo)
    gross_amount = BigDecimal(gross_kobo) / 100

    percentage_fee = (BigDecimal(gross_kobo) * PAYSTACK_RATE).ceil

    fixed_fee =
      if gross_amount < PAYSTACK_FIXED_FEE_THRESHOLD
        0
      else
        (PAYSTACK_FIXED_FEE * 100).to_i
      end

    [
      percentage_fee + fixed_fee,
      (PAYSTACK_FEE_CAP * 100).to_i
    ].min
  end
end
