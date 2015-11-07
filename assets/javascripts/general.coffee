$ ->
  $(".check_zip").on "change", ()->
    $.get("/home/get_state_and_city", {zip: $(@).val()}, (result) ->
      $('.city').val(result.city)
      $('.state').val(result.state)
    , "json")



  $('.upload-image').click ->
    $("#image-uploader").click()
    $("#progress").show()

  image_ids = []
  $('.fileupload').fileupload({
    dataType: 'json',
    done: (e, data) =>
      image_tag = ""
      $.each data.result, (index, file) =>
        image_ids.push(file.image_id)
        image_tag = image_tag + "<div class='col-sm-2'><img src='" + file.thumbnail_url + "'></div>"
      $("#image_ids").val(image_ids.join())
      $("#preview").append(image_tag)
      $("#preview").find('.loading').remove()

    progressall: (e, data) =>
      progress = parseInt(data.loaded / data.total * 100, 10)
      $('#progress .bar').css('width', progress + '%')
      $('.progress-count').text(progress + '%')
      if progress == 100
        $("#preview").append("<div class='col-sm-2 loading'>Loading Images</div>")
      
  }).prop('disabled', !$.support.fileInput)
  .parent().addClass($.support.fileInput ? undefined : 'disabled')