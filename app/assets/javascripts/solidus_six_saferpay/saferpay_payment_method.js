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
        console.log("DANI");
        debugger;
        console.log("RADI");
        // var errors = $.parseJSON(xhr.responseText).errors;
        // alert(errors);
        // console.log(errors);
        return false;
      },
    })
  }

  var prepareForIframePaymentMethod = function(paymentMethodId, initUrl, containerId) {
    if (correctPaymentMethodSelected(paymentMethodId)) {
      disableFormSubmit();
      getRedirectUrl(paymentMethodId, initUrl, {containerId: containerId}, loadIframe);
    } else {
      console.log("incorrect payment method selected for ID: " + paymentMethodId);
    }
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

  var disableFormSubmit = function() {
    var form = $("#checkout_form_payment");
    form.on("submit", function(e) { alert("Submitting this form has been disabled because you are trying to pay with the SIX payment interface.\nIf you see this message, please contact support."); e.stopPropagation(); return false });
    form.find('input[type="submit"]').toggle(false);
  }

  var enableFormSubmit = function() {
    var form = $("#checkout_form_payment");
    form.off("submit");
    form.find('input[type="submit"]').toggle(true);
  }

  return {
    loadIframe: function(paymentMethodId, initUrl, containerId) { 
      $(document).ready(function() {
        prepareForIframePaymentMethod(paymentMethodId, initUrl, containerId);
      });

      // ensure that changing payment method also inits
      $(document).off('change', paymentMethodRadioButtonSelector);
      $(document).on('change', paymentMethodRadioButtonSelector, function() {
        debugger;
        enableFormSubmit();
        prepareForIframePaymentMethod(paymentMethodId, initUrl, containerId)
      });
    },
    redirectExternal: function(paymentMethodId, initUrl) {
      $(document).off("submit", "#checkout_form_payment");
      $(document).on("submit", "#checkout_form_payment", function() {
        debugger;
        getRedirectUrl(paymentMethodId, initUrl, {}, redirectExternal);
      });
    },
  }
}();
