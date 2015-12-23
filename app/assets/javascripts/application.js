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
//= require bootstrap-datetimepicker
//= require jquery.mCustomScrollbar.concat.min


$(document).ready(function(){
  //Help links in home page
  var root = $('html, body');
  $('.help-links a').click(function() {
      root.animate({
          scrollTop: $( $.attr(this, 'href') ).offset().top
          }, 500);
      return false;
  });

  //Slider in product page
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


  //Map
  if($("#gmap").length){
    values = [];
    zoom = 6;
    bounds = new google.maps.LatLngBounds();
    //search page map
    $(".marker").map(function(){
      lat = $(this).data('lat');
      lng = $(this).data('lng');
      if($(this).data('lat') && $(this).data('lng')){
        html = "<h4><i class='fa fa-rupee'>" + $(this).data("price") + "</i></h4>";
        html = html + "<img style='max-width: 200px;' src='https://res.cloudinary.com/cocociti/image/upload/c_fill,h_190,w_253/" + $(this).data('image') + "'></img>";
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
          zoom: 6
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
  $(".search-form").submit(function(){
    $(this).find("#start_date_time").val($('#start_date_time_header').val());
    $(this).find("#end_date_time").val($('#end_date_time_header').val());
  });

  if($("#adv-search").length){
    $.get("/products/sub_categories", {category: $("#category").val(), selected: $("#filter-sub-cat").data("selected")});
  }

  $("#category").change(function(){
    $.get("/products/sub_categories", {category: $(this).val(), selected: ""});
  });

  if($('.slider').length){
    $('.slider').slider({});
  }
// Value for Price Range
  $('.slider').on("slideStop", function(slideEvt) {
    $($(this).data('target')).val(slideEvt.value);
    //$(".search-form").submit();
  });
//Value for product cond and owner type
  $(".filter").change(function(){
    e = $($(this).data("target"));
    e.val($(this).val());
  });

  $("#search_term").on("keyup", function(e){
    if(e.keyCode==13){
      $("#start_date_time").val($('#start_date_time_header').val());
      $("#end_date_time").val($('#end_date_time_header').val());
      $(".search-form").submit();
    }
  });

  $("button#search, a#filter").click(function(){
    $("#start_date_time").val($('#start_date_time_header').val());
    $("#end_date_time").val($('#end_date_time_header').val());
    $(".search-form").submit();
  });

  $(".product-tab").click(function(){
    $("#tab").val($(this).data('tab'));
    $(".search-form").submit();
  });
  //End Searching


  // Update available in user profile page
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

  //MASTER SEARCH DATE PICKER
  search_start_date = $("#start_date_and_time_for_search_datepicker").data('id');
  search_end_date = $("#end_date_and_time_for_search_datepicker").data('id');
  dob_end_date = $("#end_date_and_time_for_dob_datepicker").data('id');
  dob_start_date = $("#start_date_and_time_for_dob_datepicker").data('id');
  $(".from_date_time,.header_from_date_time").datetimepicker({
    format: 'dd-mm-yyyy hh:ii',
    autoclose: true,
    todayBtn: true,
    startDate: new Date(search_start_date),
    endDate: new Date(search_end_date),
    minuteStep: 30,
    pickerPosition: "bottom-right"
  });
  $(".end_date_time,.header_end_date_time").datetimepicker({
    format: 'dd-mm-yyyy hh:ii',
    autoclose: true,
    todayBtn: true,
    startDate: new Date(search_start_date),
    endDate: new Date(search_end_date),
    minuteStep: 30,
    pickerPosition: "bottom-right"
  });
  $(".non_coco_start_date").datetimepicker({
    format: 'dd-mm-yyyy hh:ii',
    autoclose: true,
    todayBtn: true,
    minuteStep: 30,
    pickerPosition: "bottom-right"
  });
  $(".non_coco_end_date").datetimepicker({
    format: 'dd-mm-yyyy hh:ii',
    autoclose: true,
    todayBtn: true,
    minuteStep: 30,
    pickerPosition: "bottom-right"
  });
  $(".from_date_time").datetimepicker().on('changeDate', function(){
    var date_arr = $(".home_start_date").val().split(" ");
    var date_of_arr = date_arr[0].split("-").reverse().join("-")
    var date = new Date(date_of_arr);
    var hrs = parseInt(date_arr[1].split(":")) + 2
    if(parseInt(date_arr[1].split(":")[1]) == 30){
      var mins = 30
    }
    else{
      var mins = 0
    }
    date.setHours(hrs)
    date.setMinutes(mins)
    $('.end_date_time').datetimepicker('setStartDate', date);
    $(".end_date_time").datetimepicker('show');
  });
  $(".end_date_time").datetimepicker().on('changeDate', function(){
    //var length = $('#category> option').length;
    //$('.home_search_box').attr('size',length/2);
  });
  $(".header_from_date_time").datetimepicker().on('changeDate', function(){
    var date_arr = $("#start_date_time_header").val().split(" ");
    var date_of_arr = date_arr[0].split("-").reverse().join("-")
    var date = new Date(date_of_arr);
    var hrs = parseInt(date_arr[1].split(":")) + 2
    if(parseInt(date_arr[1].split(":")[1]) == 30){
      var mins = 30
    }
    else{
      var mins = 0
    }
    date.setHours(hrs)
    date.setMinutes(mins)
    $('.header_end_date_time').datetimepicker('setStartDate', date);
    $(".header_end_date_time").datetimepicker('show');
  });
  $(".non_coco_start_date").datetimepicker().on('changeDate', function(){
    $('.non_coco_end_date').datetimepicker('setStartDate', $("#non_coco_start_date").val());
    $(".non_coco_end_date").datetimepicker('show');
  });
  $(".date_of_birth").datetimepicker({
    format: 'dd-mm-yyyy',
    autoclose: true,
    pickerPosition: "bottom-right",
    startView: 4,
    minView: 2,
    endDate: new Date(dob_end_date),
    startDate: new Date(dob_start_date)
  });

  $("#myTab .tab-pane").mCustomScrollbar({
					setHeight:380,
					theme:"inset-2-dark"
				});

  // Featured button toggle
  $(".featured-toggle").click(function() {
    var $closest, featured;
    featured = $(this).is(":checked");
    $closest = $(this).closest('.closest');
    $closest.find('.update-error').html("");
    $closest.find('.update-msg').html("");
    $.post("/admin/products/" + ($(this).data('id')) + "/set_featured", {}, function(result) {
      if (result["error"]) {
        $closest.find('.update-msg').html("");
        $closest.find('.update-error').html(result["error"]);
      } else {
        $closest.find('.update-error').html("");
        $closest.find('.update-msg').html('saved!');
      }
    });
  });

  $(".check_zip").on("focusout", function() {
    $.get("/home/get_state_and_city", {
      zip: $(this).val()
    }, function(result) {
      $('.city').val(result.city);
      $('.state').val(result.state);
    }, "json");
  });

});
