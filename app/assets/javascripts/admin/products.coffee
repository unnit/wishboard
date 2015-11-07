$ ->
  $(".featured-toggle").click ->
    featured = $(this).is(":checked")
    $closest = $(this).closest('.closest')
    $closest.find('.update-error').html("")
    $closest.find('.update-msg').html("")
    $.post("/admin/products/#{$(this).data('id')}/set_featured", {}, (result) ->
      if result["error"]
        $closest.find('.update-msg').html("")
        $closest.find('.update-error').html(result["error"])
      else
        $closest.find('.update-error').html("")
        $closest.find('.update-msg').html('saved!')
    )
