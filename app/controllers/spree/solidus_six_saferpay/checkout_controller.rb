module Spree
  module SolidusSixSaferpay
    class CheckoutController < StoreController

      before_action :load_order

      def init
        payment_method = Spree::PaymentMethod.find(params[:payment_method_id])
        initialized_payment = initialize_payment(@order, payment_method)

        if initialized_payment.success?
          redirect_url = initialized_payment.redirect_url
          render json: { redirect_url: redirect_url }
        else
          render json: { errors: t('.checkout_not_initialized') }, status: 422
        end
      end

      def success
        saferpay_payment = Spree::SixSaferpayPayment.where(order_id: @order.id).order(:created_at).last

        if saferpay_payment.nil?
          raise Spree::Core::GatewayError, t('.saferpay_payment_not_found')
        end

        # NOTE: PaymentPage payments are authorized directly. Instead, we
        # perform an ASSERT here to gather the necessary details.
        # This might be confusing at first, but doing it this way makes sense
        # (and the code a LOT more readable) IMO. Feel free to disagree and PR
        # a better solution.
        # NOTE: Transaction payments are authorized here so that the money is
        # already allocated when the user is on the confirm page. If the user
        # then chooses another payment, the authorized payment is voided
        # (cancelled).
        payment_authorization = authorize_payment(saferpay_payment)

        if payment_authorization.success?

          processed_authorization = process_authorization(saferpay_payment)
          if processed_authorization.success?
            @order.next! if @order.payment?
          else
            flash[:error] = processed_authorization.user_message
          end

        else
          payment_inquiry = inquire_payment(saferpay_payment)
          flash[:error] = payment_inquiry.user_message
        end

        @redirect_path = order_checkout_path(@order.state)
        render :iframe_breakout_redirect, layout: false
      end

      def fail
        saferpay_payment = Spree::SixSaferpayPayment.where(order_id: @order.id).order(:created_at).last

        if saferpay_payment
          payment_inquiry = inquire_payment(saferpay_payment)
          flash[:error] = payment_inquiry.user_message
        else
          flash[:error] = I18n.t(:general_error, scope: [:solidus_six_saferpay, :errors])
        end

        @redirect_path = order_checkout_path(:payment)
        render :iframe_breakout_redirect, layout: false
      end

      private

      def initialize_payment(order, payment_method)
        raise NotImplementedError, "Must be implemented in PaymentPageCheckoutController or TransactionCheckoutController"
      end

      def authorize_payment(saferpay_payment)
        raise NotImplementedError, "Must be implemented in PaymentPageCheckoutController or TransactionCheckoutController"
      end

      def process_authorization(saferpay_payment)
        raise NotImplementedError, "Must be implemented in PaymentPageCheckoutController or TransactionCheckoutController"
      end

      def inquire_payment(saferpay_payment)
        raise NotImplementedError, "Must be implemented in PaymentPageCheckoutController or TransactionCheckoutController"
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
