// TODO: use data attribute for passing the path
Spree.routes.saferpay_payment_page_init = Spree.pathFor("solidus_six_saferpay/payment_page/init")

var SaferpayPaymentPage = function() {

  var getRedirectUrl = function(callback) {
    $.ajax({
      url: Spree.routes.saferpay_payment_page_init,
      method: 'GET',
      dataType: 'json',
      success: function(data) {
        console.log(data);
        var redirectUrl = data.redirect_url;
        callback(redirectUrl);
      },

      error: function(xhr) {
        var errors = $.parseJSON(xhr.responseText).errors;
        console.log(errors);
        return false;
      },
    })
  }

  var loadIframe = function(redirectUrl) {
    $('#saferpay-payment-container').attr('src', redirectUrl);

    $(window).bind("message", function (e) {
      if (e.originalEvent.data.height <= 450) {
        return;
      }

      $("#saferpay-payment-container").css("height", e.originalEvent.data.height + "px");
    });
  }

  var redirectExternal = function(redirectUrl) {
    console.log("REDIRECT URL");
    console.log(redirectUrl);
    $(window).attr('location', redirectUrl);
  }


  return {
    loadIframe: function() { 
      getRedirectUrl(loadIframe);
    },
    redirectExternal: function() {
      getRedirectUrl(redirectExternal);
    }
  }
}();
