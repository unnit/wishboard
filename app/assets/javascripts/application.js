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
//= require jssocials
//= require intro
//= require sweetalert.min
//= require cable
//= require jquery.event.move
//= require jquery.twentytwenty
//= require jquery.rateyo

$(document).ready(function(){
  if($.fn.cloudinary_fileupload !== undefined) {
    $("input.cloudinary-fileupload[type=file]").cloudinary_fileupload();
  }
  //Custom scrollbar for wish type dropdown with setHeight
    $(".prefix-scrollbar").mCustomScrollbar({setHeight: 298});
  //Post-Showcase functions
    $(document).on("click", "html,body", function(e){
      var container_1 = $(".ps-wrapper, .alert, .sweet-overlay, .sweet-alert, .ps-nav-btn, .pac-input")
      if (!container_1.is(e.target) // if the target of the click isn't the container...
          && container_1.has(e.target).length === 0) // ... nor a descendant of the container
      {
          $("#showcase-modal").removeClass("violet-bg");
          $("#showcase-modal").modal("hide");
          $(".ps-wrapper").css({"z-index": "1"});
      }
      var container_2 = $(".j-n-c-t-wrapper, .j-n-c-t-btn")
      if (!container_2.is(e.target) // if the target of the click isn't the container...
          && container_2.has(e.target).length === 0) // ... nor a descendant of the container
      {
          $(".j-n-c-t-wrapper").hide();
      }
      var container_3 = $(".j-nct-prefix-holder, #j_nct_wish_prefix");
      if (!container_3.is(e.target) // if the target of the click isn't the container...
          && container_3.has(e.target).length === 0) // ... nor a descendant of the container
      {
          container_3.removeClass("open");
      }
    });
    $("html,body").click(function(e){
      var container_1 = $(".type-holder-dropdown")
      if (!container_1.is(e.target) // if the target of the click isn't the container...
          && container_1.has(e.target).length === 0) // ... nor a descendant of the container
      {
          $(".type-holder-dropdown").removeClass("open");
      }
      var container_2 = $(".prefix-holder-dropdown")
      if (!container_2.is(e.target) // if the target of the click isn't the container...
          && container_2.has(e.target).length === 0) // ... nor a descendant of the container
      {
          $(".prefix-holder-dropdown").removeClass("open");
      }
      var container_2 = $(".dt-achievement-dropdown")
      if (!container_2.is(e.target) // if the target of the click isn't the container...
          && container_2.has(e.target).length === 0) // ... nor a descendant of the container
      {
          $(".dt-achievement-dropdown").removeClass("open");
      }
    });
    $(document).on("click", ".ps-nav-btn", function(){
      $(".ps-wrapper").trigger("click");
    })
    $(document).on("click", ".ps-wrapper", function(e){
      $wrap = $(this).closest(".create-showcase");
      $(this).css({"z-index": "1051"});
      $(".wish-success-wrapper").remove();
      $("#showcase-modal").addClass("violet-bg");
      $("#showcase-modal").modal("show");
      if($wrap.find(".type-holder").children().length == 0 && $wrap.find(".prefix-holder").children().length == 0){
        $wrap.find(".ps-initial").attr("placeholder", "Please select your wish type");
        $wrap.find(".type-holder-dropdown").addClass("open");
      }
      else if($wrap.find(".prefix-holder").children().length == 0 && e.target.nodeName != "SPAN"){
        $wrap.find(".ps-initial").attr("placeholder", "Please select your wish category");
        $wrap.find(".prefix-holder-dropdown").addClass("open");
      }
    })
    $(document).on("click", ".ps-initial", function(e){
      $wrap = $(this).closest(".create-showcase");
      if($wrap.find(".type-holder").children().length == 0 && $wrap.find(".prefix-holder").children().length == 0){
        $wrap.find(".ps-initial").attr("placeholder", "Please select your wish type");
        $wrap.find(".type-holder-dropdown").addClass("open");
      }
      else if($wrap.find(".prefix-holder").children().length == 0 && e.target.nodeName != "SPAN"){
        $wrap.find(".ps-initial").attr("placeholder", "Please select your wish category");
        $wrap.find(".prefix-holder-dropdown").addClass("open");
      }
    })
    function showPsSubmit(){
      $wrap.find(".j-more").addClass("j-ps-more");
      $wrap.find(".j-img-wrapper, .j-more").removeClass("opacity-low");
      $wrap.find(".cloudinary-fileupload-new").removeClass("hidden");
      $wrap.find(".ps-btn-wrapper").fadeIn();
    }
    function hidePsSubmit(){
      $wrap.find(".j-more").removeClass("j-ps-more");
      $wrap.find(".j-img-wrapper, .j-more").addClass("opacity-low");
      $wrap.find(".cloudinary-fileupload-new").addClass("hidden");
      $wrap.find(".ps-btn-wrapper").fadeOut();
    }
    $(document).on("click", ".type-holder-dropdown li a", function(){
      $wrap = $(this).closest(".create-showcase");
      $wrap.find(".type-holder").html($(this).data("text"));
      $wrap.find("#showcase_showcase_type").val($(this).data("id"));
      $wrap.find("#showcase_wish_prefix").val("");
      hidePsSubmit()
      $wrap.find(".type-holder").css({"top": "32px", "left": "5px", "font-size": "15px"});
      $wrap.find(".type-holder").animate({top: "5px", fontSize: "11px"}, 200);
      $wrap.find(".type-holder-dropdown").removeClass("open");
      $wrap.find(".prefix-holder-dropdown").addClass("open");
      $wrap.find(".prefix-holder").empty();
      $wrap.find(".ps-initial").css({"width": "100%"});
      $wrap.find(".dt-of-achievement").datetimepicker('remove');
      date_options = {format: 'dd-mm-yyyy', autoclose: true, minView: 2, pickerPosition: "bottom-left", startDate: "", endDate: "" };
      if($wrap.find("#showcase_showcase_type").val() == 0){
        date_options["endDate"] = new Date($(".ps-wrapper").data("pdate"));
        $wrap.find(".dt-of-achievement").datetimepicker(date_options);
      }
      else if($wrap.find("#showcase_showcase_type").val() == 1){
        date_options["startDate"] = new Date($(".ps-wrapper").data("fdate"));
        $wrap.find(".dt-of-achievement").datetimepicker(date_options);
      }
      $wrap.find(".ps-initial").attr("placeholder", "Please select your wish category");
    })
    $(".dt-of-achievement").on('changeDate', function(){
      $(".showcase-submit").focus();
    });
    $(document).on("click", ".dt-achievement-dropdown li a", function(){
      $(".showcase-submit").focus();
    })
    $(document).on("click", ".type-holder", function(){
      $wrap = $(this).closest(".create-showcase");
      $wrap.find(".prefix-holder-dropdown").removeClass("open");
      $wrap.find(".type-holder-dropdown").addClass("open");
    })
    $(document).on("click", ".prefix-holder", function(){
      $wrap = $(this).closest(".create-showcase");
      $wrap.find(".type-holder-dropdown").removeClass("open");
      $wrap.find(".prefix-holder-dropdown").addClass("open");
    })
    $(document).on("click", ".prefix-holder-dropdown li a", function(){
      $wrap = $(this).closest(".create-showcase");
      if($wrap.find("#showcase_showcase_type").val() == 0){
        $wrap.find(".ps-initial").attr("placeholder", $(this).data("pplaceholder"));
        $wrap.find(".prefix-holder").html("<span class='dotted-bt-border mleft5'>"+$(this).data("ptext")+"&nbsp;<i class='fa fa-angle-down font16' aria-hidden='true'></i></span>");
      }
      else{
        $wrap.find(".ps-initial").attr("placeholder", $(this).data("fplaceholder"));
        $wrap.find(".prefix-holder").html("<span class='dotted-bt-border mleft5'>"+$(this).data("ftext")+"&nbsp;<i class='fa fa-angle-down font16' aria-hidden='true'></i></span>");
      }
      $wrap.find(".prefix-holder").css({"display": "inline-block"});
      $wrap.find(".ps-initial").css({"width": $wrap.find(".j-ps-holder").width() - $wrap.find(".prefix-holder").width() - 5});
      $wrap.find("#showcase_wish_prefix").val($(this).data("id"));
      $wrap.find(".prefix-holder-dropdown").removeClass("open");
      if($wrap.find(".ps-initial").val().trim() != ""){showPsSubmit()}
      $(".ps-initial").removeAttr("readonly");
      $wrap.find(".ps-initial").focus();
    })
    $(document).on("keydown", ".ps-initial", function(e){
      $wrap = $(this).closest(".create-showcase");
      if($wrap.find(".ps-initial").val() == ""){
        if(e.keyCode==8){
          $wrap.find(".ps-initial").attr("placeholder", "Please select your wish category");
          $(this).attr("readonly", true);
          $(this).css({"width": "100%"});
          $wrap.find("#showcase_wish_prefix").val("");
          $wrap.find(".prefix-holder").empty();
          $wrap.find(".prefix-holder-dropdown").addClass("open");
        }
      }
    })
    $(document).on("keyup", ".ps-initial", function(e){
      $wrap = $(this).closest(".create-showcase");
      if($wrap.find(".ps-initial").val().trim() != ""){
        if($wrap.find("#showcase_wish_prefix").val() != ""){
          showPsSubmit()
        }
      }else{
        hidePsSubmit()
      }
    })
    $(document).on("click", ".j-ps-more", function(){
      $wrap = $(this).closest(".create-showcase");
      $wrap.find(".ps-sub-wrap-2").fadeIn(50, function(){
        $wrap.find(".ps-sub-wrap-2").animate({"opacity": "1", "margin-left": "10px", "margin-top": "-120px"}, 150);
      });
    })
    $(document).on("click", ".j-ps-holder, .ps-wrap-2-close", function(){
      $wrap = $(this).closest(".create-showcase");
      if($wrap.find(".ps-sub-wrap-2").css("margin-left") == "10px"){
        $wrap.find(".ps-sub-wrap-2").animate({"margin-left": "0px", "margin-top": "-130px"}, 150,
          function(){
            $wrap.find(".ps-sub-wrap-2").fadeOut(50, function(){$(".ps-sub-wrap-2").css({"opacity": 0})})
          });
      }
    });
    $(document).on("click", ".dt-of-achievement", function(){
      $wrap = $(this).closest(".create-showcase");
      if($wrap.find("#showcase_showcase_type").val() == 2){
        $wrap.find(".dt-achievement-dropdown").addClass("open");
      }
    })
    $(document).on("click", ".dt-achievement-dropdown li a", function(){
      $wrap = $(this).closest(".create-showcase");
      $wrap.find("#showcase_year").val($(this).data("id"));
      $wrap.find(".dt-achievement-dropdown").removeClass("open");
    })
    
      //Error notifications after showcase-fullfillment-submit
    $(document).on("click", ".showcase-backstory-submit", function(e){
      e.preventDefault();
      $wrap = $(this).closest(".backstory-showcase");
        if($wrap.find(".preview, .preview-edit").children().length == 0){
          swal({
              title: "Are you sure to submit backstory without a photo?",
              text: "A photo would be nice.",
              type: "warning",
              showCancelButton: true,
              confirmButtonColor: "#ffffff",
              confirmButtonText: "Yes, Proceed",
              cancelButtonText: "Upload Photo",
              allowOutsideClick: true,
              allowEscapeKey: false,
              closeOnConfirm: true,
              closeOnCancel: true,
              animation: "slide-from-top"
            },
            function(isConfirm){
              if (isConfirm){
                $wrap.submit();
                $wrap.find(".loader-button").hide();
                $wrap.find(".loader-effect").show();
              }
              else{
                $wrap.find(".file-upload-trigger").trigger('click');
              }
          });
        }
        else{
          $wrap.find("#showcase_title").val($wrap.find(".ps-initial").val());
          $wrap.submit();
          $wrap.find(".loader-button").hide();
          $wrap.find(".loader-effect").show();
        }
    })


      //Error notifications after showcase-fullfillment-submit
    $(document).on("click", ".showcase-fullfillment-submit", function(e){
      e.preventDefault();
      $wrap = $(this).closest(".fullfill-showcase");
        if($wrap.find(".preview, .preview-edit").children().length == 0){
          swal({
              title: "Are you sure to post your fullfillment/achievement of your wish without a photo?",
              text: "A photo would be nice.",
              type: "warning",
              showCancelButton: true,
              confirmButtonColor: "#ffffff",
              confirmButtonText: "Yes, Proceed",
              cancelButtonText: "Upload Photo",
              allowOutsideClick: true,
              allowEscapeKey: false,
              closeOnConfirm: true,
              closeOnCancel: true,
              animation: "slide-from-top"
            },
            function(isConfirm){
              if (isConfirm){
                $wrap.submit();
                $wrap.find(".loader-button").hide();
                $wrap.find(".loader-effect").show();
              }
              else{
                $wrap.find(".file-upload-trigger").trigger('click');
              }
          });
        }
        else{
          $wrap.find("#showcase_title").val($wrap.find(".ps-initial").val());
          $wrap.submit();
          $wrap.find(".loader-button").hide();
          $wrap.find(".loader-effect").show();
        }
    })
    //Error notifications after showcase-submit
    $(document).on("click", ".showcase-submit", function(e){
      e.preventDefault();
      $wrap = $(this).closest(".create-showcase");
      if($wrap.find(".ps-initial").val().trim().length > 0){
        if($wrap.find(".preview, .preview-edit").children().length == 0){
          swal({
              title: "Are you sure to post your wish without a photo?",
              text: "A photo of your wish would be nice.",
              type: "warning",
              showCancelButton: true,
              confirmButtonColor: "#ffffff",
              confirmButtonText: "Yes, Proceed",
              cancelButtonText: "Upload Photo",
              allowOutsideClick: true,
              allowEscapeKey: false,
              closeOnConfirm: true,
              closeOnCancel: true,
              animation: "slide-from-top"
            },
            function(isConfirm){
              if (isConfirm){
                $wrap.find("#showcase_title").val($wrap.find(".ps-initial").val());
                $wrap.submit();
                $wrap.find(".loader-button").hide();
                $wrap.find(".loader-effect").show();
              }
              else{
                $wrap.find(".file-upload-trigger").trigger('click');
              }
          });
        }
        else{
          $wrap.find("#showcase_title").val($wrap.find(".ps-initial").val());
          $wrap.submit();
          $wrap.find(".loader-button").hide();
          $wrap.find(".loader-effect").show();
        }
      }
      else{
        swal("Sorry", "Please complete your wish", "error");
      }
    })
  //Image loading bar effect
  $('.cloudinary-fileupload-new').on('fileuploadprogress', function(e, data) {
    $(".ps-sub-wrap-2").fadeIn(50, function(){
      $(".ps-sub-wrap-2").animate({"opacity": "1", "margin-left": "10px", "margin-top": "-120px"}, 150);
    });
    $wrap = $(this).closest("form").find(".photo-upload-wrapper")
    $wrap.find('.progress').css("display", "inline-block");
    console.log(data.loaded);
    $wrap.find('.progress-bar').css('width', Math.round((data.loaded * 100.0) / data.total) + '%');
  });
  $('.cloudinary-fileupload-new').on('cloudinarydone', function(e, data) {
    $wrap = $(this).closest("form").find(".photo-upload-wrapper")
    $wrap.find(".file-input-button, .progress").hide();
    $wrap.find(".preview").show();
    $wrap.find('.preview').html(
      $.cloudinary.image(data.result.public_id,
        { format: data.result.format, version: data.result.version,
          crop: 'fill', width: 100, height: 100, class: 'img-responsive inline-display' })
    );
    $wrap.find('.progress-bar').css('width', '0%');
    $wrap.find(".preview-delete").show();
    $wrap.find(".error-ps-photo").fadeOut();
    return true;
  });
  $(".preview-delete").on("click", function(){
    $wrap = $(this).closest("form").find(".photo-upload-wrapper")
    $wrap.find(".preview").empty();
    $wrap.find(".preview-delete, .preview").hide();
    $wrap.find(".file-input-button").show();
  })
  //Image- loading of edit page
  $('.cloudinary-fileupload-edit').on('fileuploadprogress', function(e, data) {
    $wrap = $(this).closest(".photo-edit-wrapper")
    $wrap.find('.progress-edit').css("display", "inline-block");
    $wrap.find('.progress-bar-edit').css('width', Math.round((data.loaded * 100.0) / data.total) + '%');
  });
  $('.cloudinary-fileupload-edit').on('cloudinarydone', function(e, data) {
    $wrap = $(this).closest(".photo-edit-wrapper")
    $wrap.find(".file-input-button-edit, .progress-edit").hide();
    $wrap.find(".preview-edit").show();
    if($wrap.find(".preview-edit").data("source") == "showcase"){
      $wrap.find('.preview-edit').html(
        $.cloudinary.image(data.result.public_id,
          { format: data.result.format, version: data.result.version,
            crop: 'fill', width: 150, height: 100, class: 'img-responsive inline-display' })
      );
    }else{
      $wrap.find('.preview-edit').html(
        $.cloudinary.image(data.result.public_id,
          { format: data.result.format, version: data.result.version,
            crop: 'fill', height: 480, class: 'img-responsive inline-display' })
      );
    }
    $wrap.find('.progress-bar-edit').css('width', '0%');
    $wrap.find(".preview-delete-edit").show();
    return true;
  });
  $(".preview-delete-edit").on("click", function(){
    $wrap = $(this).closest(".photo-edit-wrapper")
    $wrap.find(".preview-edit").empty();
    $wrap.find(".preview-delete-edit, .preview-edit").hide();
    $wrap.find(".file-input-button-edit").show();
  })

  //Coin Wishes - Learn More
  $(document).on("click", ".c-w-lrn-mr", function(){
    $("#cont-wrapper").html("<div class='col-xs-12 col-sm-6 col-sm-offset-3 mtop40 bg-white padding20 border5 font16'><h3 class='full-width mbottom20 text-center txt-underline'>Know more about Coin Wishes</h3><ul><li class='mbottom10'>Coin wishes help you earn for each click you get on your coin wish, simple.</li><li class='mbottom10'>Wherever you see a coin icon above your friend's post, click on it to gift him/her a coin</li><li class='mbottom10'>1 click on a coin icon = ₹ 1 rupee (For your wishes & while gifting)</li><li class='mbottom10'>You can withdraw the coins earned to your bank account any time at the intervals of 10, 20, 50, 100 & in multiples of 200 thereafter</li><li class='mbottom10'>Also, for each friend you invite to Cocociti you get 2 coins.</li><li class='mbottom10'>Remember, 1 coin = ₹ 1 rupee. No coupons or complications, earn WHITE MONEY at your convenience, just by clicking.</li><strong>P.S:</strong> Coins are applicable to coin wishes and your personal wishes (Not if you rewish or select from popular wishes)<br><br><strong>Happy Wishing.</strong></ul></div>")
    $("#cont-wrapper").prepend("<span class='pull-right padding5 mbottom20' style='z-index: 1051;'><button type='button' data-dismiss='modal' class='pull-left btn grey-bg padding10' style='border-radius: 50%;'><span class='close-sprite pull-left'></button></span>");
    $("#cont-wrapper").modal("show");
  })
  //Setting footer proper for mac devices
  if($(document).height() <= $(window).height()){
    setTimeout(function(){$("footer").css({"position": "absolute", "bottom": "0"});}, 3000);
  }
  //Admin Wishes button effect
  $(document).on("click", ".brd-box", function(){
    $(this).removeClass("brd-box").addClass("fild-box");
    $(this).find(".fa-square-o").removeClass("fa-square-o").addClass("fa-check-square-o");
    $(".add-wishlist").show();
    if($("#showcase_ids").val() == ""){
      $("#showcase_ids").val($(this).data("id"));
    }
    else{
      $("#showcase_ids").val($("#showcase_ids").val()+','+$(this).data("id"));
    }
  });
  $(document).on("click", ".fild-box", function(){
    ids = [];
    $(this).removeClass("fild-box").addClass("brd-box");
    $(this).find(".fa-check-square-o").removeClass("fa-check-square-o").addClass("fa-square-o");
    if($(".fild-box").length == 0){
      $(".add-wishlist").hide();
    }
    $(".fild-box").each(function(){
      ids.push($(this).data("id"));
    })
    $("#showcase_ids").val(ids.toString());
  });
  //Coin Wishes selection
  $(document).on("click", ".coin-brd-box", function(){
    $(this).closest(".coin-wish-wrapper").find(".coin-fild-box").removeClass("coin-fild-box").addClass("coin-brd-box");
    $(this).closest(".coin-wish-wrapper").find(".fa-circle").removeClass("fa-circle").addClass("fa-circle-thin");
    $(this).removeClass("coin-brd-box").addClass("coin-fild-box");
    $(this).find(".fa-circle-thin").removeClass("fa-circle-thin").addClass("fa-circle");
    $(".coin-add-wishlist").show();
    $(".coin_wish_id").val($(this).data("id"));
  });
  //Rewish Popup
  $(document).on("click", ".rewish-link", function(){
    $("#cont-wrapper").html("<div class='container padding0 font17' style='max-width:450px;margin-top: 10%;'><div class='col-xs-12 col-sm-12 bg-white padding20 border5 cc-dark-bg white-fg'><span class='full-width pull-left mbottom30'>Awesome! This will appear in your wishlist. You can edit the content after rewishing.</span><div class='col-xs-6 col-sm-3 col-sm-offset-6 padding10'><a href='/showcases/"+$(this).data('id')+"/rewish' class='btn btn-sm bg-white cc-dark-fg full-width' data-method='post'>Rewish</a></div><div class='col-xs-6 col-sm-3 padding10'><a class='btn btn-sm full-width white-fg light-border cancel-rewish'>Not now</a></div></div></div>");
    $("#cont-wrapper").prepend("<span class='pull-right padding5 mbottom20' style='z-index: 1051;'><button type='button' data-dismiss='modal' class='pull-left btn grey-bg padding10' style='border-radius: 50%;'><span class='close-sprite pull-left'></button></span>");
    $("#cont-wrapper").modal('show');
  })
  $(document).on("click", ".cancel-rewish", function(){
    $("#cont-wrapper").modal('hide');
  })
  $(document).on("click", ".done-this", function(){
    $("#cont-wrapper").html("<div class='container padding0 font17' style='max-width:450px;margin-top: 10%;'><div class='col-xs-12 col-sm-12 bg-white padding20 border5 cc-dark-bg white-fg'><span class='full-width pull-left mbottom30'>You are about to mark this wish as fulfilled.</span><div class='col-xs-6 col-sm-3 col-sm-offset-6 padding10'><a href='/showcases/"+$(this).data('id')+"/have_done_this' class='btn btn-sm bg-white cc-dark-fg full-width' data-method='post'>Proceed</a></div><div class='col-xs-6 col-sm-3 padding10'><a class='btn btn-sm full-width white-fg light-border cancel-done-this'>Not now</a></div></div></div>");
    $("#cont-wrapper").prepend("<span class='pull-right padding5 mbottom20' style='z-index: 1051;'><button type='button' data-dismiss='modal' class='pull-left btn grey-bg padding10' style='border-radius: 50%;'><span class='close-sprite pull-left'></button></span>");
    $("#cont-wrapper").modal('show');
  })
  $(document).on("click", ".cancel-done-this", function(){
    $("#cont-wrapper").modal('hide');
  })
  //Flip effect for flash messages
  x = 0;
  var flipInterval = setInterval(function(){
    $(".alert").toggleClass("flipped");
    if(++x == 2){
      window.clearInterval(flipInterval);
    }
  }, 1000);
  //Facebook
  $(document).on("click", ".btnShare", function(){
    elem = $(this);
    postToFeed(elem.data('title'), elem.data('desc'), elem.prop('href'), elem.data('image'));
    return false;
  });
  //Search bar visible in mobile
  $(document).on("click", ".search-mob", function(){
    $(".feed-mob, .notif-mob, .follow-mob").removeClass("cc-med-bg");
    $(".navbar-header").hide();
    $(".search-mob").addClass("cc-med-bg");
    $(".search-wrap").removeClass("hide-display");
    $("#query").focus();
    var x = 0;
    var intervalID = setInterval(function () {
      $("#query").toggleClass("bg-light-grey");
      if (++x === 6) {
        window.clearInterval(intervalID);
      }
    }, 500);
  })
  //Auth Page
  $(".scase-login").hover(function(){
    $(this).html("<i class='fa fa-long-arrow-left' aria-hidden='true'></i>&nbsp;Login/SignUp");
  },function(){
    $(this).text("Showcase")
  })
  $(".scase-login").click(function(){
    $(".login-email").focus();
  })
  //Sign up email space validation
  $(".signup-email").on("keyup", function(){
    $(this).val($(this).val().replace(" ",""));
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
    $(this).closest(".showcase-ps-wrapper").find(".new-comment").show();
    $(this).closest(".showcase-ps-wrapper").find(".comment-description").focus();
  });
  //Comment spinner
  $(document).on("click", ".btn-comment-create", function(){
    $(this).next(".fa-spinner").removeClass("hide-display");
  })
  //Showcase Edit Delete option
  $(document).on("click", ".action-showcase", function(){
    $(".option-showcase").not($(this).next(".option-showcase")).each(function(){
      $(this).hide();
    });
    $(this).next(".option-showcase").fadeToggle(100);
  })
  $("html,body").click(function(e){
    var container = $(".action-showcase")
    if (!container.is(e.target) // if the target of the click isn't the container...
      && container.has(e.target).length === 0) // ... nor a descendant of the container
    {
      $(".option-showcase").hide();
    }
  });
  // Edit photo in profile page
  $(document).on("mouseover", ".main-prof-pic,#edit-prof-pic", function(){
    $("#edit-prof-pic").show();
  });
  $(document).on("mouseleave", ".main-prof-pic,#edit-prof-pic", function(){
    $("#edit-prof-pic").hide();
  });
  //Move-Showcase page add btn
  $(document).on("click", ".add-move-showc", function(){
    $(".move-showc-wrapper").hide();
    $(".move-create-coll-wrapper,.create-collect").show();
  })
  $(document).on("click", ".clos-add-mov", function(){
    $(".move-create-coll-wrapper").hide();
    $(".move-showc-wrapper").show();
  })
  //Showcase description show/hide
  $(document).on("mouseover", ".show-img-wrap", function(){
    $(this).find(".show-details").show();
  });
  $(document).on("mouseleave", ".show-img-wrap", function(){
    $(this).find(".show-details").hide();
  })
  //Giveaway
  $(document).on("mouseover", ".gway-img-wrap", function(){
    $(this).find(".gway-desc").show();
  });
  $(document).on("mouseleave", ".gway-img-wrap", function(){
    $(this).find(".gway-desc").hide();
  })
  $(document).on("click", ".gway-rqst", function(){
    $(this).html("<span>Please Wait...</span><span class='ball-clip-rotate' style='height:22px;'><div style='height:15px;width:15px;'></div></span>")
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
  }).on('typeahead:selected', function (e, d) {
      $(this).closest("#header-search").submit();
  });
  var profiles = new Bloodhound({
    datumTokenizer: function(datum) {
      return Bloodhound.tokenizers.whitespace(datum.value);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      wildcard: '%QUERY',
      url: '/user_autocomplete?q=%QUERY',
      transform: function(response) {
        // Map the remote source JSON array to a JavaScript object array
        return $.map(response, function(profiles) {
          return {
            value: profiles.first_name+" "+profiles.last_name
          };
        });
      }
    }
  });
  $(".profile-query").typeahead(null, {
    display: 'value',
    source: profiles,
  }).on('typeahead:selected', function (e, d) {
      $("#profile-search-form").submit();
  });

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
  //Showcase embed
  $(document).on("click", ".embed-link", function(){
    $("#cont-wrapper").html("<div class='modal-dialog'><div class='modal-content pop-up-mar'><div class='modal-header pop-bac'><button class='close' data-dismiss='modal' type='button'> <i class='fa fa-times'></i></button><h4 class='modal-title'>Embed</h4></div><div class='modal-body'><div class='col-sm-12 col-xs-12'><h5 class='weight600'>Embed this Showcase to your website by copying the code below</h5><textarea rows='4' class='full-width grey-fg' onClick='this.setSelectionRange(0, this.value.length)' readonly=true><a class='embedly-card' href='"+$(this).data('url')+"'>"+$(this).data('title')+"</a><script async src='https://cdn.embedly.com/widgets/platform.js' charset='UTF-8'></script></textarea><br><br></div></div><div class='clearfix'></div></div></div>");
    $("#cont-wrapper").modal('show');
  })
  //Hide success/failure messages after 10 secs.
  if($(".alert-message-div").length){
    $(".alert-message-div").delay(10000).fadeOut();
  }
  //Close
  $(document).on("click", ".alert-close", function(){
    $(".alert-message-div").remove();
  })
  //Infinite Scroll
  if ($('#infinite-scrolling-content').length) {
    $(window).on('scroll', function() {
      var more_posts_url = $('#infinite-scrolling-content .pagination .next a').attr('href');
      if (more_posts_url && $(window).scrollTop() > $(document).height() - $(window).height() - 250) {
        $(window).off("scroll");
        $('.feed-loader').show();
        $.getScript(more_posts_url);
      }
    });
  }
  //Profile page create collection
    $(document).on("click", ".plus-prof", function(){
      $(".plus-prof").hide();
      $(".create-collect").fadeIn();
      $(".cc-field").focus();
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
  }
  //-----Table Sorter
  $("#admin-products, #admin-transactions").tablesorter();
  $("#booking_requests_table, #my_listings_table, #my_orders_table, #upcoming_bookings_table, #non_coco_bookings_table, #delete_non_coco_bookings_table").tablesorter();
  $("table#booking_requests_table, table#my_listings_table, table#my_orders_table, table#upcoming_bookings_table, table#non_coco_bookings_table, table#delete_non_coco_bookings_table").tableSearch({
		searchPlaceHolder:'Please search here...',
	});
  //Import Google Contacts
  var clientId = $("#google_client_id").data("client-id");
  var apiKey = $("#google_api_key").data("api-key");
  var scopes = 'https://www.googleapis.com/auth/contacts.readonly';
  $(document).on("click",".google-contacts-import", function(){
    $(".status-invite").html("<i class='fa fa-spinner fa-spin'>");
    gapi.client.setApiKey(apiKey);
    window.setTimeout(authorize);
  });
  function authorize() {
    gapi.auth.authorize({client_id: clientId, scope: scopes, immediate: false}, handleAuthorization);
  }
  function handleAuthorization(authorizationResult){
    if (authorizationResult && !authorizationResult.error){
      $.get("https://www.google.com/m8/feeds/contacts/default/thin?alt=json&access_token=" + authorizationResult.access_token + "&max-results=300&v=3.0",
        function(response){
          ct = [];
          list = [];
          ct = response.feed.entry;
          for(i=0;i<ct.length;i++){
            var contact = ct[i]
            if(contact.gd$email && contact.gd$email.length > 0){
              if($(".import-emails").val().length == 0){
                $(".import-emails").val(contact.gd$email[0].address)
              }else{
                $(".import-emails").val($(".import-emails").val() + ',' + contact.gd$email[0].address)
              }
              list.push(contact.gd$email[0].address);
            }
          }
          if(list.length > 0){
            $.get("/check_email", {email: list});
          }
          $(".status-invite").empty();
          if($(".import-emails").val().length == 0){
            $(".status-invite").html("<span style='color: red;'>Sorry, No emails found.</span>")
          }
      });
    }
  }
  if('serviceWorker' in navigator) {
  navigator.serviceWorker
           .register('/assets/service-worker/sw.js')
           .then(function() { console.log("Service Worker Registered"); });
  }
  //set animation timing
  var animationDelay = 2000,
    //loading bar effect
    barAnimationDelay = 2500,
    barWaiting = barAnimationDelay - 2000, //3000 is the duration of the transition on the loading bar - set in the scss/css file
    //letters effect
    lettersDelay = 50,
    //type effect
    typeLettersDelay = 150,
    selectionDuration = 500,
    typeAnimationDelay = selectionDuration + 800,
    //clip effect
    revealDuration = 600,
    revealAnimationDelay = 1500;

  initHeadline();


  function initHeadline() {
    //insert <i> element for each letter of a changing word
    singleLetters($('.cd-headline.letters').find('b'));
    //initialise headline animation
    animateHeadline($('.cd-headline'));
  }

  function singleLetters($words) {
    $words.each(function(){
      var word = $(this),
        letters = word.text().split(''),
        selected = word.hasClass('is-visible');
      for (i in letters) {

        letters[i] = (selected) ? '<i class="in">' + letters[i] + '</i>': '<i>' + letters[i] + '</i>';
      }
        var newLetters = letters.join('');
        word.html(newLetters).css('opacity', 1);
    });
  }

  function animateHeadline($headlines) {
    var duration = animationDelay;
    $headlines.each(function(){
      var headline = $(this);

       if (!headline.hasClass('type') ) {
        //assign to .cd-words-wrapper the width of its longest word
        var words = headline.find('.cd-words-wrapper b'),
          width = 0;
        words.each(function(){
          var wordWidth = $(this).width();
            if (wordWidth > width) width = wordWidth;
        });
        headline.find('.cd-words-wrapper').css('width', width);
      };

      //trigger animation
      setTimeout(function(){ hideWord( headline.find('.is-visible').eq(0) ) }, duration);
    });
  }

  function hideWord($word) {
    var nextWord = takeNext($word);

    if($word.parents('.cd-headline').hasClass('type')) {
      var parentSpan = $word.parent('.cd-words-wrapper');
      parentSpan.addClass('selected').removeClass('waiting');
      setTimeout(function(){
        parentSpan.removeClass('selected');
        $word.removeClass('is-visible').addClass('is-hidden').children('i').removeClass('in').addClass('out');
      }, selectionDuration);
      setTimeout(function(){ showWord(nextWord, typeLettersDelay) }, typeAnimationDelay);

    } else if($word.parents('.cd-headline').hasClass('letters')) {
      var bool = ($word.children('i').length >= nextWord.children('i').length) ? true : false;
      hideLetter($word.find('i').eq(0), $word, bool, lettersDelay);
      showLetter(nextWord.find('i').eq(0), nextWord, bool, lettersDelay);

    }  else if($word.parents('.cd-headline').hasClass('clip')) {
      $word.parents('.cd-words-wrapper').animate({ width : '2px' }, revealDuration, function(){
        switchWord($word, nextWord);
        showWord(nextWord);
      });

    } else {
      switchWord($word, nextWord);
      setTimeout(function(){ hideWord(nextWord) }, animationDelay);
    }
  }

  function showWord($word, $duration) {
    if($word.parents('.cd-headline').hasClass('type')) {
      showLetter($word.find('i').eq(0), $word, false, $duration);
      $word.addClass('is-visible').removeClass('is-hidden');

    }  else if($word.parents('.cd-headline').hasClass('clip')) {
      $word.parents('.cd-words-wrapper').animate({ 'width' : $word.width() + 10 }, revealDuration, function(){
        setTimeout(function(){ hideWord($word) }, revealAnimationDelay);
      });
    }
  }

  function hideLetter($letter, $word, $bool, $duration) {
    $letter.removeClass('in').addClass('out');

    if(!$letter.is(':last-child')) {
      setTimeout(function(){ hideLetter($letter.next(), $word, $bool, $duration); }, $duration);
    } else if($bool) {
      setTimeout(function(){ hideWord(takeNext($word)) }, animationDelay);
    }

    if($letter.is(':last-child') && $('html').hasClass('no-csstransitions')) {
      var nextWord = takeNext($word);
      switchWord($word, nextWord);
    }
  }

  function showLetter($letter, $word, $bool, $duration) {
    $letter.addClass('in').removeClass('out');

    if(!$letter.is(':last-child')) {
      setTimeout(function(){ showLetter($letter.next(), $word, $bool, $duration); }, $duration);
    } else {
      if($word.parents('.cd-headline').hasClass('type')) { setTimeout(function(){ $word.parents('.cd-words-wrapper').addClass('waiting'); }, 200);}
      if(!$bool) { setTimeout(function(){ hideWord($word) }, animationDelay) }
    }
  }

  function takeNext($word) {
    return (!$word.is(':last-child')) ? $word.next() : $word.parent().children().eq(0);
  }

  function takePrev($word) {
    return (!$word.is(':first-child')) ? $word.prev() : $word.parent().children().last();
  }

  function switchWord($oldWord, $newWord) {
    $oldWord.removeClass('is-visible').addClass('is-hidden');
    $newWord.removeClass('is-hidden').addClass('is-visible');
  }

  $(".twentytwenty-container").twentytwenty();
  starRating('.star_rating');
});


function starRating(elementselector){
 $rateYo = $(elementselector).rateYo({ numStars: 5, precision: 20, fullStar: true, starWidth: "20px", spacing: "5px",
  onInit: function (rating,rateyo) {$(this).rateYo("option", "ratedFill",customRatingColor(rating)); $($(this).attr('data-display-rating')).html(rating);},
  onSet: function (rating, rateyo) {color = customRatingColor(rating); $(this).rateYo("option", "ratedFill", customRatingColor(rating));
  $(this).closest('form').find($(this).attr('data-input-field')).val(rating);
  $($(this).attr('data-display-rating')).html(rating);
   $(this).closest('form').find($(this).attr('data-display-rating-map')).html(ratingMapWord(rating));
  if ($(this).data('save-rating')){save_rating($(this), rating ); }
},
  onChange: function (rating, rateyo) {color = customRatingColor(rating); $(this).rateYo("option", "ratedFill", customRatingColor(rating)); $($(this).attr('data-input-field')).val(rating); $($(this).attr('data-display-rating')).html(rating);}
})
}

function ratingMapWord(givenrating){
   ratingmap = {"worst": "Worst", "bad": "Bad","average":"Average", "good": "Good", "best": "Best"  }
    if (givenrating <= 1) {
     return ratingmap['worst']
   }else if (givenrating > 1 && givenrating <= 2){
     return  ratingmap['bad']
   } else if (givenrating > 2 && givenrating <= 3 ) {
     return  ratingmap['good']
   } else if (givenrating > 3 && givenrating < 4 ) {
     return  ratingmap['average']
   } else if (givenrating >= 4) {
     return  ratingmap['best']
   }else{
    return  ratingmap['average']
  }
}

function customRatingColor(givenrating){
  colors = {"red":"#ff0000", "light_red": "#ac3636", "green": "#008000", "light_green": "#90EE90", "yellow": "#FFFF00"}
  if (givenrating <= 1) {
   return colors['red']
 }else if (givenrating > 1 && givenrating <= 2){
   return colors['light_red']
 } else if (givenrating > 2 && givenrating <= 3 ) {
   return colors['yellow']
 } else if (givenrating > 3 && givenrating < 4 ) {
   return colors['yellow']
 } else if (givenrating >= 4) {
   return colors['green']
 }else{
  return colors['red']
}
}

function replace_content(element, modal, form){
  form.find("#showcase_date_of_achievement").val(element.attr('data-date_of_acheivement'));
  form.find("#showcase_achieved_description").val(element.attr('data-showcase_achieved_description'))
}

function refresh_twenty_twenty_div(wrapper_div){
var imgs = $(wrapper_div+" .twentytwenty-container img");
images = wrapper_div+" .twentytwenty-container img";
var loadedImgNum = 0;
imgs.on('load', function(){loadedImgNum += 1; if (loadedImgNum == imgs.length){setTimeout(function () {$(wrapper_div+" .twentytwenty-container").twentytwenty(); $(window).trigger("resize.twentytwenty"); }, 500); } }); 
}
function prependModalClose(elementselector){
var close_modal_button = "<span class='pull-right padding5 mbottom20' style='z-index: 1051;'><button type='button' data-dismiss='modal' class='pull-left btn grey-bg padding10' style='border-radius: 50%;'><span class='close-sprite pull-left'></button></span>";
$(elementselector).prepend(close_modal_button);
}
function save_rating(element, rating){
   var data = {showcase: {after_rating: rating, }, };
   $.ajax({
    type: 'POST',
    data: data,
    url: "/showcases/"+(element.data('showcase-id')) + "/update_rating",
    success: function(data) {},
    error: function(data) {},
  });
}

function reatch_cloundinary(elementselector){
  $(elementselector).on('fileuploadprogress', function(e, data) {
    $wrap = $(this).closest('.photo-wrapper');
    $progress =  $wrap.find('.progress');
    $progressBar = $wrap.find('.progress-bar');
    $progress.css("display", "inline-block");
    $progressBar.css('width', Math.round((data.loaded * 100.0) / data.total) + '%');
  });
  $(elementselector).on('cloudinarydone', function(e, data) {
    $wrap = $(this).closest('.photo-wrapper');
    $preview = $wrap.find('.preview');
    $fileinputbutton = $wrap.find('.file-input-button');
    $progress =  $wrap.find('.progress');
    $progressBar = $wrap.find('.progress-bar');
    $previewDeleteButton = $wrap.find('.preview-delete-fullfill');
    $fileinputbutton.hide();
    $progress.hide();
    $preview.show();
    if($preview.data("source") == "showcase"){
      $preview.html(
        $.cloudinary.image(data.result.public_id,
          { format: data.result.format, version: data.result.version,
            crop: 'fill', width: $(this).data('width'), height: $(this).data('height'), class: 'img-responsive inline-display' })
        );
    }else{
      $preview.html(
        $.cloudinary.image(data.result.public_id,
          { format: data.result.format, version: data.result.version,
            crop: 'fill', height: $(this).data('height-non-source'), class: 'img-responsive inline-display' })
        );
    }
    $progressBar.css('width', '0%');
    $previewDeleteButton.show();
    return true;
  });
  $(".preview-delete-fullfill").on("click", function(){
    $wrap = $(this).closest(".photo-wrapper");
    $wrap.find(".preview").empty();
    $wrap.find(".preview-delete-fullfill, .preview").hide();
    $wrap.find(".file-input-button").show();
  })
}