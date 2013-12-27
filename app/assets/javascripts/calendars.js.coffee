reload = ->
  page_width = parseFloat $('#page_width').val()
  page_height = parseFloat $('#page_height').val()
  cell_height = parseFloat $('#cell_height').val()
  console.log page_width, page_height, cell_height
  for m in [1..12]
    console.log m
    lines = parseInt $("#month-"+m+" .lines").val()
    top_grid_y = lines * cell_height
    height = page_height - top_grid_y - 80
    console.log page_width + "x" + height
    original_width = parseInt $("#month-"+m+" .width").val()
    original_height = parseInt $("#month-"+m+" .height").val()
    new_height = height*original_width/page_width
    new_width = page_width*original_height/height
    console.log "Orezat zospodu " + original_height + new_height
    if original_height and original_width
      if new_height < original_height
        $("#month-"+m+" .result").html "Odrezat zospodu " + parseInt(original_height - new_height)
      else
        $("#month-"+m+" .result").html "Odrezat zprava " + parseInt(original_width - new_width)

$ ->
  reload()
  $("input").keyup ->
    reload()