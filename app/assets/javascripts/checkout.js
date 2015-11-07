var citruspg = $.citrus.gateway($.citrus.env.production);
//var citruspg = $.citrus.gateway($.citrus.env.sandbox);
//var citruswallet = $.citrus.wallet($('#options').data("token"), $.citrus.env.sandbox);

$(document).ready(function(){
  var merchantAccessKey = $('#transaction').data('key');
  var id = $('#transaction').data('id');
  var price = $("#transaction").data("price");
  var signature = $("#transaction").data("signature");
  var url = $('#transaction').data('url') + "/transactions/callback";
  
  function createPayment(){
    $('#error').html("");
    var firstName= $("#address_first_name").val();
    var lastName= $("#address_last_name").val();
    var email = $('#address_email').val();
    var mobileNo= $("#address_mobile").val();
    var street1= $("#address_address1").val();
    var street2= $("#address_address2").val();
    var city= $("#address_city").val();
    var zip= $("#address_zip").val();
    var state= $("#address_state").val();

    var cardNumber= $("#card_number").val();
    var cardHolder= $("#card_holder").val();
    var cardExpiry= $("#card_expiry").val();
    var cardCvv= $("#card_cvv").val();

    var bill = {
      merchantAccessKey: merchantAccessKey, //"HONXN1991PP1DDWG6CF2",
      merchantTxnId: id,
      amount: {
        currency: 'INR',
        value: price
      },
      returnUrl: url,
      requestSignature: signature,
      userDetails: {
        firstName: firstName,
        lastName: lastName,
        email: email,
        mobileNo: mobileNo,
        address: {
          street1: street1,
          street2: street2,
          city: city,
          zip: zip,
          state: state,
          country: "INDIA"
        }
      }
    };
    var paymentOptions = {
      mode: "card",
      cardNumber: cardNumber,
      cardHolder: cardHolder,
      cardExpiry: cardExpiry,
      cardCvv: cardCvv
    };
    // var paymentOptions = {
    //   "mode": "token",
    //   "token": token,
    //   "tokenCvv": tokenCvv
    // };
    // console.log(bill);
    // console.log(paymentOptions);
    citruspg.makePayment(
      bill,
      paymentOptions,
      function(error, url) {
        if (error) {
          $('#error').html('<p>' + error.error + ': ' + error.message + '</p>');
        } else {console.log("cc");
          // save successful card in wallet
          // citruswallet.save();

          // redirect to 3D-secure
          $(location).attr({ href: url });
        }
      }
    );
  }

  $("#checkout-form").submit(function(e){
    e.preventDefault();
    $(".agreement-error").hide();
    $('#error').html();
    if(!$(this).find("#agreement").is(":checked")){
      $(".agreement-error").show();
    }else{
      createPayment();
    }
    return false;
  });

});