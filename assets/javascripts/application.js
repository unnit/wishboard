// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery/dist/jquery
//= require jquery_ujs
//= require bootstrap-sass-official/assets/javascripts/bootstrap.min
//= require gmap3
//= require bxslider/jquery.bxslider.min
//= require bootstrap-slider.min
//= require bootstrap-select
//= require jquery.remotipart
//= require moment
//= require bootstrap-datetimepicker
//= require admin/products
//= require jquery-fileupload/basic
// require jquery-upload/jquery.ui.widget
// require jquery-upload/jquery.iframe-transport
// require jquery-upload/jquery.fileupload
//= require general

$(document).ready(function(){
  var slider = $('.bxslider').bxSlider({
    pagerCustom: '#bx-pager', 
    keyboardEnabled: true
  });

  $(document).keydown(function(e){
    if (e.keyCode == 39){ // Right arrow 
      slider.goToNextSlide();
      return false;
    }
    else if (e.keyCode == 37){// left arrow
      slider.goToPrevSlide();
      return false;
    }
  });

  $(".product-tab").click(function(){
    $("#tab").val($(this).data('tab'));
    $(".search-form").submit();
  });

  first_avail_date = new Date();
  $('.datepicker').each(function(){
    min_h = parseInt($(this).data("min-h"));
    min_m = parseInt($(this).data("min-m"));
    if(min_m==30){
      min_m = 29;
    }else{
      min_m = 59;
      min_h = min_h-1;
    }
    mo = moment().hour(min_h).minutes(min_m);

    var first_avail = $(this).data('first-avail');
    if(first_avail.length){
      first_avail_date = new Date(first_avail);
    }

    $(this).datetimepicker({
      format: "YYYY-MM-DD HH:mm",
      stepping: 30,
      ignoreReadonly: true,
      sideBySide: true,
      disabledTimeIntervals: [[moment().hour(0).minutes(0), mo]],
      minDate: first_avail
    });
  });
  
  //Map
  if($("#gmap").length){
    values = [];
    zoom = 10;
    bounds = new google.maps.LatLngBounds();
    //search page map
    $(".marker").map(function(){
      lat = $(this).data('lat');
      lng = $(this).data('lng');
      if($(this).data('lat') && $(this).data('lng')){
        html = "<h4><i class='fa fa-rupee'>" + $(this).data("price") + "</i></h4>";
        html = html + "<img style='max-width: 200px;' src='" + $(this).data('image') + "'></img>";
        html = html + "<a href='" + $(this).data("path") + "'><h6 class='mtop10'>" + $(this).data("title") + "</h6></a>"
        values.push({
          latLng: [lat, lng],
          data: html
        });
        latLng = new google.maps.LatLng(lat, lng)
        bounds.extend(latLng);
      }
      
    });
    
    if(values.length < 1){
      values = [{address:  "Begaluru"}];
    }
 
    $("#gmap").gmap3({
      map:{
        options:{
          zoom: 10
        }
      },
      marker:{
        values: values,
        options:{
          draggable: false
        },
        events:{
          click: function(marker, event, context){
            if(context.data.length){
              var map = $(this).gmap3("get"),
                infowindow = $(this).gmap3({get:{name:"infowindow"}});
              if (infowindow){
                infowindow.open(map, marker);
                infowindow.setContent(context.data);
              } else {
                $(this).gmap3({
                  infowindow:{
                    anchor:marker, 
                    options:{content: context.data}
                  }
                });
              }
            }
          }
        },
        callback: function(m){ //m will be the array of markers
          var map=$(this).gmap3('get');
          map.fitBounds(bounds);
          map.setCenter(bounds.getCenter());
        }
      }
    });
  
    //post product map
    $(".map-location").focusout(function() {
      address = $(this).val();
      $lat = $(this).closest('.closest').find(".lat");
      $lng = $(this).closest('.closest').find(".lng");
      $("#gmap").gmap3({
        clear: {
          name:["marker"],
          last: true
        },
        getlatlng:{
          address: address,
          callback: function(results){
            if ( !results ) return;
            $(this).gmap3({
              action: "addMaker",
              marker: {
                address: address,
                options:{
                  draggable:true
                },
                events:{
                  dragend: function(marker){
                    $(this).gmap3({
                      getaddress:{
                        latLng:marker.getPosition(),
                        callback:function(results){
                          var map = $(this).gmap3("get"),
                            infowindow = $(this).gmap3({get:"infowindow"}),
                            content = results && results[1] ? results && results[1].formatted_address : "no address";
                          $(".map-location").val(content);
                        }
                      }
                    });
                  }
                }
              }
            });
            $(this).gmap3('get').panTo(results[0].geometry.location);
            lat = results[0].geometry.location.lat();
            lng = results[0].geometry.location.lng();
            $lat.val(lat);
            $lng.val(lng);
          }
        }
      });
    });
  }//END MAP

  //panels toggle
  $(document).on('click', '.panel-heading span.clickable', function (e) {
    var $this = $(this);
    if (!$this.hasClass('panel-collapsed')) {
      $this.parents('.panel').find('.panel-body').slideUp();
      $this.addClass('panel-collapsed');
      $this.find('i').removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down');
    } else {
      $this.parents('.panel').find('.panel-body').slideDown();
      $this.removeClass('panel-collapsed');
      $this.find('i').removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up');
    }
  });

  //Dropdown
  $(".dropdown-menu li a").click(function () {
    $(this).parents(".btn-group").find('.selection').text($(this).text());
    $(this).parents(".btn-group").find('.selection').val($(this).text());
  });


  //Searching
  if($("#adv-search").length){
    $.get("/products/sub_categories", {category: $("#category").val(), selected: $("#filter-sub-cat").data("selected")});
  }

  $("#category").change(function(){
    $.get("/products/sub_categories", {category: $(this).val(), selected: $("#filter-sub-cat").data("selected")});
  });

  if($('.slider').length){
    $('.slider').slider({});
  }

  $('.slider').on("slideStop", function(slideEvt) {
    $($(this).data('target')).val(slideEvt.value);
    //$(".search-form").submit();
  });

  $(".filter").change(function(){
    e = $($(this).data("target"));
    e.val($(this).val());
  });

  $("#search_term").on("keyup", function(e){
    if(e.keyCode==13){
      $("#term").val($('#search_term').val());
      $(".search-form").submit();
    }
  });

  $("button#search, a#filter").click(function(){
    $("#term").val($('#search_term').val());
    $(".search-form").submit();
  });

  $(".search-form").submit(function(){
    $(this).find("#term").val($('#search_term').val());
  });
  //End Searching

  //Calculate price
  if($(".price-trigger").length){
    getPrice();
  }
  $(".price-trigger").on("dp.hide", function (e) {
    getPrice();
  });

  $(".operator_type").click(function(){
    getPrice();
  });

  $(".available-switch").click(function(){
    available = $(this).is(":checked");
    status = available ? "Available" : "Unavailable";
    $closest = $(this).closest('.closest');
    $('.update-error').html("");
    $('.update-msg').html("");
    $.post("/products/update_available", {id: $(this).data('id'), available: available}, function(result){
      if(result["error"]){
        $closest.find('.update-error').html(result["error"]);
      }else{
        $closest.find('.avail').html(status);
      }
    });
  });
  //end price

  //general
  $(".agreement-require").on('submit', function(e){
    $(".agreement-error").hide();
    if(!$(this).find("#agreement").is(":checked")){
      $(".agreement-error").show();
      e.preventDefault();
      return false;
    }else{
      return true;
    }
  });

});

function getPrice(){
  $(".date-error").html("");
  var startdate = $(".startdate").val();
  var enddate = $(".enddate").val();
  operator_type = $("#operator_1").is(":checked") ? 1 : 0;
  if(startdate.length && enddate.length){
    data = {startdate: startdate, enddate: enddate, product_id: $("#product_id").val(), operator_type: operator_type}
    $.get("/transactions/get_price", data)
    .done(function(result){
      if(result.error){
        $(".date-error").html(result.error);
        $("#rent-btn").attr("disabled", "disabled")
      }else{
        $(".days").text(result.days);
        $(".tax-amount").text(result.tax);
        $(".total-price").text(result.total_price);
        $(".total-amount").text(result.pay_amount);
        $(".discount").text(result.discount);
        $(".min-sign").text(result.sign);
        $("#operator_type").val(operator_type);
        $("#rent-btn").removeAttr("disabled");
      }
    });
  }
}