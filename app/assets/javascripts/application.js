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
//= require html-table-search
//= require bootstrap-slider.min
//= require bootstrap-select
//= require jquery.remotipart
//= require bootstrap-datetimepicker
//= require jquery.mCustomScrollbar.concat.min
//= require jquery.tablesorter
//= require cloudinary
//= require jquery.tooltipster
//= require tagmanager
//= require typeahead.bundle

$(document).ready(function(){
  $(document).on("click", ".btnShare", function(){
    elem = $(this);
    postToFeed(elem.data('title'), elem.data('desc'), elem.prop('href'), elem.data('image'));
    return false;
  });
  //Auth Page
  $(".scase-login").hover(function(){
    $(this).html("<i class='fa fa-long-arrow-left' aria-hidden='true'></i>&nbsp;Login/SignUp");
  },function(){
    $(this).text("Showcase")
  })
  $(".scase-login").click(function(){
    $(".login-email").focus();
  })
  //Username
  $(".username-url").text($(".username").val());
  $(".username").on("keyup", function(){
    var return_text = $(this).val().replace(/[^a-zA-Z0-9_-]/g,'');
    $(this).val(return_text);
    $(".username-url").text(return_text);
    if($(this).val().length > 5){
      $(".uname-avail").text("Checking...");
      $.get("/profiles/username_available", {uname: $(this).val()}, function(data){
        $(".uname-avail").text(data.result);
        if(data.result == "Available"){
          $(".uname-avail").append("&nbsp;<i class='fa fa-check-circle green-fg font17'></i>")
        }
      })
    }else{
      $(".uname-avail").text("Username is too short");
    }
  })
  // Notification Icon
  $(document).on("click", ".notif-icon", function(){
    $(".notif-toggle").toggle();
    if($(".notif-content").is(":empty")){
      $.get("/unchecked_notifications")
    }
  })
  $("html,body").click(function(e){
    var container = $(".notif-icon")
    if (!container.is(e.target) // if the target of the click isn't the container...
        && container.has(e.target).length === 0) // ... nor a descendant of the container
    {
        $(".notif-toggle").hide();
    }
  });
  //Bulk Bookings
  $("#bulk-bookings").click(function(){
    $("#bulk-bookings-pop-up").modal("show");
  });
  //Loader Icon
  $("form.bulk-bookings-form, form.user_form, form.login-form, form.signup-form, form.form-wiki-wrap").submit(function(){
    $(this).find(".loader-button").hide();
    $(this).find(".loader-effect").show();
  })
  //Follow button loader effect
  $(document).on("click", ".loader-out-follow-button", function(){
    $(this).find(".loader-button").hide();
    $(this).find(".loader-effect").show();
  });
  //Focus on comments
  $(document).on("click", ".comment-link", function(){
    $(this).closest(".showcase-ps-wrapper").find(".comment-description").focus();
  });
  //Showcase Edit Delete option
  $(document).on("click", ".action-showcase", function(){
    $(".option-showcase").not($(this).next(".option-showcase")).each(function(){
      $(this).hide();
    });
    $(this).next(".option-showcase").fadeToggle(100);
  })
  //Edit comment of showcase
  $(document).on("click", ".edit-comment-showcase", function(){
    $(this).closest(".option-showcase").hide(100);
    $(this).closest(".media-body").find(".view-comment-showcase").hide();
    $(this).closest(".media-body").find(".form-comment-showcase").fadeIn();
    $(this).closest(".media-body").find(".comment-description").delay(1000).focus();
  })
  //See more in showcase description
  $(document).on("click", ".see-more", function(){
    $(this).siblings(".excerpt-desc").hide();
    $(this).siblings(".full-desc").show();
    $(this).text("See Less")
    $(this).removeClass("see-more").addClass("see-less")
  });
  $(document).on("click", ".see-less", function(){
    $(this).siblings(".full-desc").hide();
    $(this).siblings(".excerpt-desc").show();
    $(this).text("See More")
    $(this).removeClass("see-less").addClass("see-more")
  });
  //See more in comment description
  $(document).on("click", ".see-more-comment", function(){
    $(this).siblings(".excerpt-comment-desc").hide();
    $(this).siblings(".full-comment-desc").show();
    $(this).text("See Less")
    $(this).removeClass("see-more-comment").addClass("see-less-comment")
  });
  $(document).on("click", ".see-less-comment", function(){
    $(this).siblings(".full-comment-desc").hide();
    $(this).siblings(".excerpt-comment-desc").show();
    $(this).text("See More")
    $(this).removeClass("see-less-comment").addClass("see-more-comment")
  });
  //Hovercard
  function hoverCard(){
    $(".hovercard").tooltipster({
      interactive: true,
      content: 'Loading...',
      contentCloning: false,
      contentAsHTML: true,
      maxWidth: 292,
      animation: 'fade',
      functionBefore: function(origin, continueTooltip) {
          // we'll make this function asynchronous and allow the tooltip to go ahead and show the loading notification while fetching our data.
          continueTooltip();
          if (origin.data('ajax') !== 'cached') {
          $.ajax({
              type: 'GET',
              url: "/user_card/"+($(this).data('id')),
              success: function(data) {
                  // update our tooltip content with our returned data and cache it
                  origin.tooltipster('content', data.user).data('ajax', 'cached');
              }
          });
        }
      }
    });
  }
  hoverCard();
  $(document).on("mouseover", ".hovercard", hoverCard);
  // POST SHOWCASE JQUERY -------- 1.slide actions in post showcase
  if($(".tm-edit-input").val() != null){
    var prefilled_tags = $(".tm-edit-input").val().split(",");
  }
  else{
    var prefilled_tags = [];
  }
  var tags = new Bloodhound({
    datumTokenizer: function(datum) {
      return Bloodhound.tokenizers.whitespace(datum.value);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      wildcard: '%QUERY',
      url: '/showcases/gettags?q=%QUERY',
      transform: function(response) {
        // Map the remote source JSON array to a JavaScript object array
        return $.map(response, function(tags) {
          return {
            value: tags
          };
        });
      }
    }
  });
  blank_array = []
  var tagApi = $(".tm-input").tagsManager({
    hiddenTagListName: "showcase[all_tags]",
    maxTags: 15,
    prefilled: blank_array
  });
  var tagEditApi = $(".tm-edit-input").tagsManager({
    hiddenTagListName: "showcase[all_tags]",
    maxTags: 15,
    prefilled: prefilled_tags
  });
  $(".tm-input").typeahead(null, {
    display: 'value',
    source: tags,
  }).on('typeahead:selected', function (e, d) {
      tagApi.tagsManager("pushTag", d.value);
      $('.tm-input').typeahead('val', "");
  });
  $(".tm-edit-input").typeahead(null, {
    display: 'value',
    source: tags,
  }).on('typeahead:selected', function (e, d) {
      tagEditApi.tagsManager("pushTag", d.value);
      $('.tm-edit-input').typeahead('val', "");
  });
  $(".tm-input").on('tm:hide', function() {
    $(".tm-input.tt-hint").hide();
  });
  $(".tm-edit-input").on('tm:hide', function() {
    $(".tm-edit-input.tt-hint").hide();
  });
  $(".tm-input").on('tm:show', function() {
    $(".tm-input.tt-hint").show();
  });
  $(".tm-edit-input").on('tm:show', function() {
    $(".tm-edit-input.tt-hint").show();
  });
  var showcases = new Bloodhound({
    datumTokenizer: function(datum) {
      return Bloodhound.tokenizers.whitespace(datum.value);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      wildcard: '%QUERY',
      url: '/showcases/autocomplete?q=%QUERY',
      transform: function(response) {
        // Map the remote source JSON array to a JavaScript object array
        return $.map(response, function(showcases) {
          return {
            value: showcases
          };
        });
      }
    }
  });
  $(".search-query").typeahead(null, {
    display: 'value',
    source: showcases,
  })
  $(".arrow-right").click(function(){
    if($(".set-2-ps").hasClass("active")){
      if($(".file-input-button").css("display") == "none"){
        $(".set-2-ps, .set-1-ps").removeClass("active block-display").addClass("hide-display");
        $(".set-3-ps").addClass("active block-display");
        $(".arrow-right").fadeOut();
        $(".arrow-wrapper").animate({left: "83.5%"});
      }
      else{
        $(".error-ps-photo").css("display", "inline-block");
      }
    }
    if($(".set-1-ps").hasClass("active")){
      if($(this).closest(".ps-wrapper").find("input[name='showcase[showcase_type]']").is(':checked'))
      {
        $(".set-1-ps, .set-3-ps").removeClass("active block-display").addClass("hide-display");
        $(".set-2-ps").addClass("active block-display");
        $(".arrow-left").fadeIn();
        $(".arrow-wrapper").animate({left: "50%"});
      }
      else{
        $(".error-ps-radio").css("display", "inline-block");
      }
    }
  });
  $(".arrow-left").click(function(){
    if($(".set-2-ps").hasClass("active")){
      $(".set-2-ps, .set-3-ps").removeClass("active block-display").addClass("hide-display");
      $(".set-1-ps").addClass("active block-display");
      $(".arrow-left").fadeOut();
      $(".arrow-wrapper").animate({left: "16.5%"});
    }
    if($(".set-3-ps").hasClass("active")){
      $(".set-3-ps, .set-1-ps").removeClass("active block-display").addClass("hide-display");
      $(".set-2-ps").addClass("active block-display");
      $(".arrow-right").fadeIn();
      $(".arrow-wrapper").animate({left: "50%"});
    }
  });
  //Select showpiece/wish in post showcase
  $(".ps-showpiece").click(function(){
    $(".ps-wish").removeClass("header-with-grad white-fg");
    $(this).addClass("header-with-grad white-fg");
    $(".showcase_type_0").prop("checked", "checked");
    $(".year-gnrl, .loc-gnrl").show();
    //$(".year-gnrl, .loc-gnrl").attr("required", true);
    $(".showcase-submit").val("Showcase");
  });
  $(".ps-wish").click(function(){
    $(".ps-showpiece").removeClass("header-with-grad white-fg");
    $(this).addClass("header-with-grad white-fg");
    $(".showcase_type_1").prop("checked", "checked");
    $(".year-gnrl, .loc-gnrl").hide();
    //$(".year-gnrl, .loc-gnrl").removeAttr("required");
    $(".year-gnrl, .loc-gnrl").val("");
    $(".showcase-submit").val("Wishlist");
  })
  $(".ps-showpiece, .ps-wish").click(function(){
    $(".error-ps-radio").fadeOut();
    $(".set-1-ps, .set-3-ps").removeClass("active block-display").addClass("hide-display");
    $(".set-2-ps").addClass("active block-display");
    $(".arrow-left").fadeIn();
    $(".arrow-wrapper").animate({left: "50%"});
  })
  $(".ps-edit-showpiece").click(function(){
    $(this).prop("checked", "checked");
    $(".year-edit, .loc-edit").show();
    //$(".year-edit, .loc-edit").attr("required", true);
    $(".showcase-edit-submit").val("Showcase");
  });
  $(".ps-edit-wish").click(function(){
    $(this).prop("checked", "checked");
    $(".year-edit, .loc-edit").hide();
    //$(".year-edit, .loc-edit").removeAttr("required");
    $(".year-edit, .loc-edit").val("");
    $(".showcase-edit-submit").val("Wishlist");
  })
  //Error notifications for title,desc,year,location
  $(".showcase-submit").click(function(e){
    e.preventDefault();
    var currentTime = new Date();
    $.trim($("#showcase_title").val()).length == 0?($("#showcase_title").css("border-bottom", "1px solid #F25F5C"),a = 0):(a = 1)
    //$.trim($("#showcase_description").val()).length == 0?($("#showcase_description").css("border-bottom", "1px solid #F25F5C"),b = 0):(b = 1)
    b=1;c=1;d=1;
    if($("input[name='showcase[showcase_type]']:checked").val() == 0){
      //$.trim($("#showcase_year").val()).length < 4?($("#showcase_year").css("border-bottom", "1px solid #F25F5C"),c = 0):(c = 1)
      //$.trim($("#showcase_location_attributes_name").val()).length == 0?($("#showcase_location_attributes_name").css("border-bottom", "1px solid #F25F5C"),d = 0):(d = 1)
      if($.trim($("#showcase_year").val()).length > 0 && ($.trim($("#showcase_year").val()) < 1700 || $.trim($("#showcase_year").val()) > currentTime.getFullYear())){
        c = 0;
        $("#showcase_year").css("border-bottom", "1px solid #F25F5C");
      }
    }
    if(a == 1 && b == 1 && c == 1 && d == 1){
      $("#new_showcase").submit();
      $("#new_showcase .loader-button").hide();
      $("#new_showcase .loader-effect").show();
      tagApi.tagsManager("empty");
    }
  })
  //Remove error notifications for title,desc,year,location
  $(".title-gnrl").on("keyup", function(){
    $.trim($(this).val()).length > 0?($(this).css("border-bottom", "1px solid #CCCCCC")):($(this).css("border-bottom", "1px solid #F25F5C"))
  })
  //$(".des-gnrl").on("keyup", function(){
  //  $.trim($(this).val()).length > 0?($(this).css("border-bottom", "1px solid #CCCCCC")):($(this).css("border-bottom", "1px solid #F25F5C"))
  //})
  $(".year-gnrl, .year-edit").on("keyup", function(e){
    //$.trim($(this).val()).length > 3?($(this).css("border-bottom", "1px solid #CCCCCC")):($(this).css("border-bottom", "1px solid #F25F5C"))
    if($.trim($(this).val()).length == 0){
      $(this).css("border-bottom", "1px solid #CCCCCC");
    }
    else{
      var currentDateTime = new Date();
      if($.trim($(this).val()) < 1700 || $.trim($(this).val()) > currentDateTime.getFullYear()){
        $(this).css("border-bottom", "1px solid #F25F5C");
      }
      else{
        $(this).css("border-bottom", "1px solid #CCCCCC");
      }
    }
  })
  $(".year-gnrl, .year-edit").on("keypress", function(e){
    if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
      return false;
    }
  })
  //$(".loc-gnrl, .loc-edit").on("keyup", function(){
  //  $.trim($(this).val()).length > 0?($(this).css("border-bottom", "1px solid #CCCCCC")):($(this).css("border-bottom", "1px solid #F25F5C"))
  //})
  //phone in profile-settings page
  $("#profile_phone").on("keypress", function(e){
    if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
      return false;
    }
  })
  $("#address_zip").on("keypress", function(){
    if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
      return false;
    }
  })
  //POST SHOWCASE -----end
  //Hide success/failure messages after 30 secs.
  if($(".alert-message-div").length){
    $(".alert-message-div").delay(30000).fadeOut();
  }
  //Infinite Scroll
  if ($('#infinite-scrolling-content').length) {
    $(window).on('scroll', function() {
      var more_posts_url = $('#infinite-scrolling-content .pagination .next a').attr('href');
      if (more_posts_url && $(window).scrollTop() > $(document).height() - $(window).height() - 60) {
        $('.feed-loader').show();
        $.getScript(more_posts_url);
      }
    });
  }
  //Profile page create collection
    $(document).on("click", ".plus-prof", function(){
      $(".plus-prof").hide();
      $(".create-collect").fadeIn();
    })
    $(document).on("click", ".clos-c-collect", function(){
      $(".create-collect")[0].reset();
      $(".create-collect").hide();
      $(".plus-prof").fadeIn();
    })
    $(document).on("click", ".clos-e-collect", function(){
      $(this).closest(".edit-coll-wrapper").hide();
      $(this).closest(".collection-wrapper").find(".view-coll-wrapper").fadeIn();
    })
    $(document).on("click", ".edit-coll-icon", function(){
      $(this).closest(".view-coll-wrapper").hide();
      $(this).closest(".view-coll-wrapper").next(".edit-coll-wrapper").fadeIn();
    })
    $(document).on( "mouseover", ".collection-wrapper", function(){
      $(this).find(".close-sprite, .edit-coll-icon").fadeIn();
    });
    $(document).on( "mouseleave", ".collection-wrapper", function(){
      $(this).find(".close-sprite, .edit-coll-icon").fadeOut();
    });
  // Profile page wiki
  $(document).on( "mouseover", ".wiki-wrapper", function(){
    $(this).find(".close-sprite, .edit-wiki-icon").fadeIn();
  });
  $(document).on( "mouseleave", ".wiki-wrapper", function(){
    $(this).find(".close-sprite, .edit-wiki-icon").fadeOut();
  });
  $(document).on("click", ".clos-e-wiki", function(){
    $(this).closest(".edit-wiki-wrapper").hide();
    $(this).closest(".wiki-wrapper").find(".view-wiki-wrapper").fadeIn();
  })
  $(document).on("click", ".edit-wiki-icon", function(){
    $(this).closest(".view-wiki-wrapper").hide();
    $(this).closest(".view-wiki-wrapper").next(".edit-wiki-wrapper").fadeIn();
  })
  //Image loading bar effect
  $('.cloudinary-fileupload-new').bind('fileuploadprogress', function(e, data) {
    $('.progress').css("display", "inline-block");
    $('.progress-bar').css('width', Math.round((data.loaded * 100.0) / data.total) + '%');
  });
  $('.cloudinary-fileupload-new').bind('cloudinarydone', function(e, data) {
    $(".file-input-button, .progress").hide();
    $(".preview, .preview-edit").show();
    $('.preview').html(
      $.cloudinary.image(data.result.public_id,
        { format: data.result.format, version: data.result.version,
          crop: 'fill', width: 150, height: 100 })
    );
    $('.progress-bar').css('width', '0%');
    $(".preview-delete").show();
    $(".error-ps-photo").fadeOut();
    return true;
  });
  $(".preview-delete").click(function(){
    $(".preview-delete, .preview, .preview-edit").hide();
    $(".file-input-button").show();
  })
  //Image- loading of edit page
  $('.cloudinary-fileupload-edit').bind('fileuploadprogress', function(e, data) {
    $('.progress-edit').css("display", "inline-block");
    $('.progress-bar-edit').css('width', Math.round((data.loaded * 100.0) / data.total) + '%');
  });
  $('.cloudinary-fileupload-edit').bind('cloudinarydone', function(e, data) {
    $(".file-input-button-edit, .progress-edit").hide();
    $(".preview-edit").show();
    $('.preview-edit').html(
      $.cloudinary.image(data.result.public_id,
        { format: data.result.format, version: data.result.version,
          crop: 'fill', width: 637 })
    );
    $('.progress-bar-edit').css('width', '0%');
    $(".preview-delete-edit").show();
    return true;
  });
  $(".preview-delete-edit").click(function(){
    $(".preview-delete-edit, .preview-edit").hide();
    $(".file-input-button-edit").show();
  })

  //Home page - Rent, Lend pages
  n=!0,t=!0;
  $(".rent-hover").hover(function(){
    n&&(n=!1,setTimeout(function(){n=!0},800),
    $("#rent-lend-wrapper").toggleClass("show-rent"));
    $("#rent-lend-wrapper").hasClass("show-rent")?($(".arrow-rent").addClass("clockwise180"),$(".home-rent-icon span").addClass("opacity"),setTimeout(function(){$(".rent-lend-content").addClass("mtop60")}, 400)):($(".arrow-rent").removeClass("clockwise180"),$(".home-rent-icon span").removeClass("opacity"),$(".rent-lend-content").removeClass("mtop60"))
  });
  $(".lend-hover").hover(function(){
    t&&(t=!1,setTimeout(function(){t=!0},800),
    $("#rent-lend-wrapper").toggleClass("show-lend"));
    $("#rent-lend-wrapper").hasClass("show-lend")?($(".arrow-lend").addClass("clockwise180"),$(".home-lend-icon span").addClass("opacity"),setTimeout(function(){$(".rent-lend-content").addClass("mtop55")}, 400)):($(".arrow-lend").removeClass("clockwise180"),$(".home-lend-icon span").removeClass("opacity"),$(".rent-lend-content").removeClass("mtop55"))
  });
  $(".intro-message").click(function(){
    if($("#rent-lend-wrapper").hasClass("show-rent"))
    {
      $("#rent-lend-wrapper").toggleClass("show-rent");
      $(".arrow-rent").removeClass("clockwise180");
      $(".home-rent-icon span").removeClass("opacity");
      $(".rent-lend-content").removeClass("mtop55");
    }
    if($("#rent-lend-wrapper").hasClass("show-lend"))
    {
      $("#rent-lend-wrapper").toggleClass("show-lend");
      $(".arrow-lend").removeClass("clockwise180");
      $(".home-lend-icon span").removeClass("opacity");
      $(".rent-lend-content").removeClass("mtop55");
    }
  })
  //Help links in home page
  var root = $('html, body');
  $('.help-links a').click(function() {
      root.animate({
          scrollTop: $( $.attr(this, 'href') ).offset().top
          }, 500);
      return false;
  });
  //Tooltip
  $('[data-toggle="tooltip"]').tooltip();
  //Featured list toggle
  $(".featured-button-1").click(function(){
    $(".featured-button").removeClass("featured-active");
    $(this).find('.featured-button').addClass("featured-active");
    $(".featured-list-2,.featured-list-3,.featured-list-4").hide();
    $(".featured-list-1").fadeIn(300);
  })
  $(".featured-button-2").click(function(){
    $(".featured-button").removeClass("featured-active");
    $(this).find('.featured-button').addClass("featured-active");
    $(".featured-list-1,.featured-list-3,.featured-list-4").hide();
    $(".featured-list-2").fadeIn(300);
  })
  $(".featured-button-3").click(function(){
    $(".featured-button").removeClass("featured-active");
    $(this).find('.featured-button').addClass("featured-active");
    $(".featured-list-1,.featured-list-2,.featured-list-4").hide();
    $(".featured-list-3").fadeIn(300);
  })
  $(".featured-button-4").click(function(){
    $(".featured-button").removeClass("featured-active");
    $(this).find('.featured-button').addClass("featured-active");
    $(".featured-list-1,.featured-list-2,.featured-list-3").hide();
    $(".featured-list-4").fadeIn(300);
  })
  //Focus Search fields in dhow page
  $(".search-in-show").click(function(){
    $("#start_date_time_header").focus();
  })

  // Menu Drop Down on hover
  //$('.dropdown').hover(function() {
  //    $(this).addClass('open');
  //},
  //function() {
  //    $(this).removeClass('open');
  //});

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

  //MASTER SEARCH DATE PICKER, HEADER DATE PICKER, DATE OF BIRTH
  search_start_date = $("#start_date_and_time_for_search_datepicker").data('id');
  search_end_date = $("#end_date_and_time_for_search_datepicker").data('id');
  dob_end_date = $("#end_date_and_time_for_dob_datepicker").data('id');
  dob_start_date = $("#start_date_and_time_for_dob_datepicker").data('id');
  $(".from_date_time").datetimepicker({
    format: 'dd-mm-yyyy hh:ii',
    autoclose: true,
    startDate: new Date(search_start_date),
    endDate: new Date(search_end_date),
    minuteStep: 30,
    pickerPosition: "top-right"
  });
  $(".header_from_date_time").datetimepicker({
    format: 'dd-mm-yyyy hh:ii',
    autoclose: true,
    startDate: new Date(search_start_date),
    endDate: new Date(search_end_date),
    minuteStep: 30,
    pickerPosition: "bottom-right"
  });
  $(".end_date_time").datetimepicker({
    format: 'dd-mm-yyyy hh:ii',
    autoclose: true,
    startDate: new Date(search_start_date),
    endDate: new Date(search_end_date),
    minuteStep: 30,
    pickerPosition: "top-right"
  });
  $(".header_end_date_time").datetimepicker({
    format: 'dd-mm-yyyy hh:ii',
    autoclose: true,
    startDate: new Date(search_start_date),
    endDate: new Date(search_end_date),
    minuteStep: 30,
    pickerPosition: "bottom-right"
  });
  $(".non_coco_start_date").datetimepicker({
    format: 'dd-mm-yyyy hh:ii',
    autoclose: true,
    minuteStep: 30,
    pickerPosition: "bottom-right"
  });
  $(".non_coco_end_date").datetimepicker({
    format: 'dd-mm-yyyy hh:ii',
    autoclose: true,
    minuteStep: 30,
    pickerPosition: "bottom-right"
  });
  $(".from_date_time").datetimepicker().on('changeDate', function(){
    var date_arr = $(".home_start_date").val().split(" ");
    var date_of_arr = date_arr[0].split("-").reverse().join("-")
    var date = new Date(date_of_arr);
    var hrs = parseInt(date_arr[1].split(":")) + 4
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
    $('.home_search_box').addClass("dropup");
    $('.home_search_box').addClass("open");
  });
  $(".header_from_date_time").datetimepicker().on('changeDate', function(){
    var date_arr = $("#start_date_time_header").val().split(" ");
    var date_of_arr = date_arr[0].split("-").reverse().join("-")
    var date = new Date(date_of_arr);
    var hrs = parseInt(date_arr[1].split(":")) + 4
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
  $(".header_end_date_time").datetimepicker().on('changeDate', function(){
    $(".dropdown-lg").addClass("open");
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

  $(".land-src-button").click(function(){
      $(".home_start_date").removeAttr("readonly");
      $(".home_end_date").removeAttr("readonly");
      setTimeout(function(){$(".home_start_date").attr("readonly", true);}, 1000);
      setTimeout(function(){$(".home_end_date").attr("readonly", true);}, 1000);
  });
  $("#myTab .tab-pane,.notif-inner-strip").mCustomScrollbar({
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
  // ---Get State and City by entering Zip Code
  $(".check_zip").on("focusout", function() {
    $.get("/home/get_state_and_city", {
      zip: $(this).val()
    }, function(result) {
      $('.city').val(result.city);
      $('.state').val(result.state);
      $('.country').val(result.country);
    }, "json");
  });
  //-----Show search Bar in header when search in home scrolls up
  if($(".main-search-bar").length){
    var topOfOthDiv = $(".main-search-bar").offset().top;
      $(window).scroll(function() {
          if($(window).scrollTop() > topOfOthDiv) { //scrolled past the other div?
              $("#adv-search").fadeIn(); //reached the desired point -- show div
          }
          else{
            $("#adv-search").fadeOut();
          }
      });
  }
  //Google Places
  if($('.pac-input').length){
    var places_input= $('.pac-input')[0];
    google.maps.event.addDomListener(window, 'load', function () {
        var autocomplete = new google.maps.places.Autocomplete(places_input);
        google.maps.event.addDomListener(places_input, 'keydown', function(e) {
          if (e.keyCode == 13 && $('.pac-container:visible').length) {
            e.preventDefault();
          }
        });
    });
    var places_input_1= $('.pac-input')[1];
    google.maps.event.addDomListener(window, 'load', function () {
        var autocomplete = new google.maps.places.Autocomplete(places_input_1);
        google.maps.event.addDomListener(places_input_1, 'keydown', function(e) {
          if (e.keyCode == 13 && $('.pac-container:visible').length) {
            e.preventDefault();
          }
        });
    });
  }
  //-----Table Sorter
  $("#admin-products, #admin-transactions").tablesorter();
  $("#booking_requests_table, #my_listings_table, #my_orders_table, #upcoming_bookings_table, #non_coco_bookings_table, #delete_non_coco_bookings_table").tablesorter();
  $("table#booking_requests_table, table#my_listings_table, table#my_orders_table, table#upcoming_bookings_table, table#non_coco_bookings_table, table#delete_non_coco_bookings_table").tableSearch({
		searchPlaceHolder:'Please search here...',
	});
});
