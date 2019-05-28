// var SaferpayPaymentMethod = function(payment_method_json) {
//   var paymentMethodRadioButtonSelector = 'input[type="radio"][name="order[payments_attributes][][payment_method_id]"]'

//   var paymentMethod = JSON.parse(payment_method_json);
//   var id = paymentMethod.id;
//   var asIframe = paymentMethod.preferred_as_iframe;

//   var prepareOnSelect = function() {
//     $(document).off('change', paymentMethodRadioButtonSelector, prepareIfSelected)
//     $(document).on('change', paymentMethodRadioButtonSelector, prepareIfSelected)
//   }

//   return {
//     prepareForPayment: prepareOnSelect;
//   }

// }

// var Test = function(string) {
//     this.string = string;
    
//     var say = function() {
//         console.info(string);
//     }
    
//     return {
//         say : say
//     }
// }



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

  var prepareForIframePaymentMethod = function(paymentMethodId, initUrl, containerId) {
    if (correctPaymentMethodSelected(paymentMethodId)) {
      // disableSubmitButton();
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

  // var disableSubmitButton = function() {

  // }

  return {
    loadIframe: function(paymentMethodId, initUrl, containerId) { 
      prepareForIframePaymentMethod(paymentMethodId, initUrl, containerId);

      // ensure that changing payment method also inits
      $(document).on('change', paymentMethodRadioButtonSelector, function() {
        prepareForIframePaymentMethod(paymentMethodId, initUrl, containerId)
      });
    },
    redirectExternal: function(paymentMethodId, initUrl) {
      $(document).on("submit", "#checkout_form_payment", function() {
        getRedirectUrl(paymentMethodId, initUrl, {}, redirectExternal);
      });
    },
  }
}();
