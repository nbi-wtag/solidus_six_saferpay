module Spree
  module SolidusSixSaferpay
  # TODO: SPEC
    class SaferpayPaymentPageController < StoreController

      def init
        load_order
        payment_page_initialize = ::SolidusSixSaferpay::InitializeSaferpayPaymentPage.call(@order)


        if payment_page_initialize.success?
          redirect_url = payment_page_initialize.redirect_url
          render json: { redirect_url: redirect_url }
        else
          render json: { errors: "Payment could not be initialized" }, status: 422
        end
      end

      def success
        load_order

        saferpay_payment = ::SolidusSixSaferpay::SaferpayPayment.where(order: @order).order(:created_at).last

        unless saferpay_payment
          raise "No Saferpay Token found for order #{@order}"
        end

        payment_page_assert = ::SolidusSixSaferpay::AssertSaferpayPaymentPage.call(saferpay_payment)

        if payment_page_assert.success?
          @order.next! if @order.payment?

          payment_method = payment_page_assert.payment.payment_method

          @redirect_path = order_checkout_path(@order.state)
          if payment_method.preferred_as_iframe
            render :iframe_breakout_redirect, layout: false
          else
            redirect_to @redirect_path
          end
        else
          # TODO: Handle error case with flash message
          raise "Payment Assert not successful."
          redirect_to order_checkout_path(@order.state)
        end

      end

      def fail
        redirect_to order_checkout_path(:delivery)
      end

      def cancel
        raise "USER CANCELLED PAYMENT"
        redirect_to order_checkout_path(:delivery)
      end

      private

      def load_order
        @order = current_order
        redirect_to(spree.cart_path) && return unless @order
      end

      def order_checkout_path(state)
        Spree::Core::Engine.routes.url_helpers.checkout_state_path(state)
      end
    end
  end
end
