module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    class CheckoutController < StoreController

      def init
        load_order
        payment_method = Spree::PaymentMethod.find(params[:payment_method_id])
        initialized_payment = initialize_checkout(@order, payment_method)

        if initialized_payment.success?
          redirect_url = initialized_payment.redirect_url
          render json: { redirect_url: redirect_url }
        else
          render json: { errors: "Payment could not be initialized" }, status: 422
        end
      end

      def success
        load_order
        @order.next! if @order.payment?

        create_payment

        @redirect_path = order_checkout_path(@order.state)
        render :iframe_breakout_redirect, layout: false
      end

      # TODO: KISS fail + cancel
      def fail
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

      def initialize_checkout
        raise "Must be implemented in PaymentPageCheckoutController or TransactionCheckoutController"
      end

      def create_payment
        payment = @order.payments.valid.last
        source = payment.source
        source.create_payment!
      end

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
