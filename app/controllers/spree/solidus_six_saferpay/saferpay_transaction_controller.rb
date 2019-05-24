module Spree
  module SolidusSixSaferpay
  # TODO: SPEC
    class SaferpayTransactionController < StoreController

      def init
        load_order
        payment_method = PaymentMethod.find(params[:payment_method_id])

        transaction_initialize = ::SolidusSixSaferpay::InitializeSaferpayTransaction.call(@order, payment_method)

        if transaction_initialize.success?
          redirect_url = transaction_initialize.redirect_url
          render json: { redirect_url: redirect_url }
        else
          render json: { errors: "Payment could not be initialized" }, status: 422
        end
      end

      def success
        load_order
        @order.next! if @order.payment?

        @redirect_path = order_checkout_path(@order.state)
        render :iframe_breakout_redirect, layout: false
      end

      # TODO: KISS fail + cancel
      def fail
        require 'pry'; binding.pry
        @redirect_path = order_checkout_path(:delivery)
        if payment_method.preferred_as_iframe
          render :iframe_breakout_redirect, layout: false
        else
          redirect_to @redirect_path
        end
      end

      # TODO: KISS fail + cancel
      def cancel
        @redirect_path = order_checkout_path(:delivery)
        if payment_method.preferred_as_iframe
          render :iframe_breakout_redirect, layout: false
        else
          redirect_to @redirect_path
        end
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
