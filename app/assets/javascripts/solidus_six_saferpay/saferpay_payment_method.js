var SaferpayPaymentMethod = function() {

  var paymentMethodRadioButtonSelector = 'input[type="radio"][name="order[payments_attributes][][payment_method_id]"]'

  var getRedirectUrl = function(paymentMethodId, initUrl, callbackParams, callback) {
    $.ajax({
      url: Spree.pathFor(initUrl),
      data: {
        payment_method_id: paymentMethodId,
      },
      method: 'GET',
      dataType: 'json',
      success: function(data) {
        console.log(data);
        var redirectUrl = data.redirect_url;
        callback(callbackParams, redirectUrl);
      },

      error: function(xhr) {
        var errors = $.parseJSON(xhr.responseText).errors;
        console.log(errors);
        return false;
      },
    })
  }

  var loadIframe = function(callbackParams, redirectUrl) {
    containerId = callbackParams.containerId;
    $(containerId).attr('src', redirectUrl);

    $(window).bind("message", function (e) {
      if (e.originalEvent.data.height <= 450) {
        return;
      }

      $(containerId).css("height", e.originalEvent.data.height + "px");
    });
  }

  var redirectExternal = function(callbackParams, redirectUrl) {
    $(window).attr('location', redirectUrl);
  }

  var correctPaymentMethodSelected = function(paymentMethodId) {
    var selectedPaymentMethodId = $(paymentMethodRadioButtonSelector+":checked").val()
    return paymentMethodId === selectedPaymentMethodId;
  }

  return {
    loadIframe: function(paymentMethodId, initUrl, containerId) { 
      if (correctPaymentMethodSelected(paymentMethodId)) {
        getRedirectUrl(paymentMethodId, initUrl, {containerId: containerId}, loadIframe);
      } else {
        console.log("incorrect payment method selected for ID: " + paymentMethodId);
      }

      // ensure that changing payment method also inits
      $(document).on('change', paymentMethodRadioButtonSelector, function() {
        if (correctPaymentMethodSelected(paymentMethodId)) {
          getRedirectUrl(paymentMethodId, initUrl, {containerId: containerId}, loadIframe);
        } else {
          console.log("incorrect payment method selected for ID: " + paymentMethodId);
        }
      });
    },
    redirectExternal: function(paymentMethodId, initUrl) {
      $(document).on("submit", "#checkout_form_payment", function() {
        getRedirectUrl(paymentMethodId, initUrl, {}, redirectExternal);
      });
    },
  }
}();
