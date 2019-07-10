let SaferpayPayment = {
  paymentFormId: "#checkout_form_payment",
  paymentMethodRadioButtonSelector: 'input[type="radio"][name="order[payments_attributes][][payment_method_id]"]',

  paymentMethods: {},

  getRedirectUrl: function(paymentMethodId, initUrl, callbackParams, callback) {
    $.ajax({
      url: Spree.pathFor(initUrl),
      data: {
        payment_method_id: paymentMethodId,
      },
      method: 'GET',
      dataType: 'json',
      success: function(data) {
        console.info(data);
        var redirectUrl = data.redirect_url;
        callback(callbackParams, redirectUrl);
      },

      error: function(xhr) {
        var errors = $.parseJSON(xhr.responseText).errors;
        alert(errors);
        console.info(errors);
        return false;
      },
    })
  },

  loadIframe: function(callbackParams, redirectUrl) {
    containerId = callbackParams.containerId;
    $(containerId).attr('src', redirectUrl);

    $(window).bind("message", function (e) {
      if (e.originalEvent.data.height <= 450) {
        return;
      }

      $(containerId).css("height", e.originalEvent.data.height + "px");
    });
  },

  redirectExternal: function(callbackParams, redirectUrl) {
    $(window).attr('location', redirectUrl);
  },

  disableFormSubmit: function() {
    var form = $(this.paymentFormId);
    form.on("submit", function(e) { alert("Submitting this form has been disabled because you are trying to pay with the SIX payment interface.\nIf you see this message, please contact support."); e.stopPropagation(); return false });
    form.find('input[type="submit"]').toggle(false);
  },

  enableFormSubmit: function() {
    var form = $(this.paymentFormId);
    form.off("submit");
    form.find('input[type="submit"]').toggle(true);
  },


  prepareForIframePayment: function(paymentMethod) {
    console.info("PREPARE FOR IFRAME:");
    console.log(paymentMethod);
    this.disableFormSubmit();
    this.getRedirectUrl(paymentMethod.id, paymentMethod.initUrl, { containerId: paymentMethod.containerId }, this.loadIframe);
  },

  prepareForRedirectPayment: function(paymentMethod) {
    console.info("PREPARE FOR REDIRECT:");
    console.info(paymentMethod);
    $(document).off('submit', this.paymentFormId);
    $(document).on('submit', this.paymentFormId, function(e) {
      SaferpayPayment.getRedirectUrl(paymentMethod.id, paymentMethod.initUrl, {}, SaferpayPayment.redirectExternal);
    });
  },

  handleSelectedPaymentMethod: function() {
    var selectedPaymentMethodId = $(this.paymentMethodRadioButtonSelector+":checked").val()

    if (!this.isSaferpayPayment(selectedPaymentMethodId)) { return false; }

    paymentMethod = this.paymentMethods[selectedPaymentMethodId];

    switch (paymentMethod.paymentInterface) {
      case 'iframe':
        this.prepareForIframePayment(paymentMethod);
        break;
      case 'redirect':
        this.prepareForRedirectPayment(paymentMethod);
        break;
      default:
        console.info("Payment Interface not supported, choose either 'iframe' or 'redirect'");
        return false;
    }
  },

  isSaferpayPayment: function(paymentMethodId) {
    return !!(this.paymentMethods[paymentMethodId])
  },

  registerIframePaymentMethod: function(paymentMethod) {
    console.info("registering iframe method:");
    console.info(paymentMethod);
    paymentMethod.paymentInterface = "iframe";
    this.paymentMethods[paymentMethod.id] = paymentMethod;
  },

  registerExternalRedirectPaymentMethod: function(paymentMethod) {
    console.info("registering external method:");
    console.info(paymentMethod);
    paymentMethod.paymentInterface = "redirect";
    this.paymentMethods[paymentMethod.id] = paymentMethod;
  },
};

$(document).ready(function() {
  var form = $(SaferpayPayment.paymentFormId);
  if (form.length == 0) {
    return false;
  }
  console.info("INIT SAFERPAY JS");
  SaferpayPayment.handleSelectedPaymentMethod();
});

$(document).on('change', SaferpayPayment.paymentMethodRadioButtonSelector, function() {
  SaferpayPayment.enableFormSubmit();
  SaferpayPayment.handleSelectedPaymentMethod();
});
