$(document).ready(function() {

    $('#tabs-swipe-demo').tabs({
        swipeable : true,
        responsiveThreshold : 1920
    });

    // edit item
    $(".edit-btn").on('click', function () {
      var itemId = this.id;
      $("#item" + itemId).hide();
      $("#form" + itemId).show();
      $(".cancel-btn").click(function() {
          $("#form" + itemId).hide();
          $("#item" + itemId).show();
      });
    });

    $('select').material_select();
    $(".button-collapse").sideNav();

    // add new item
    $("#new-item").click(function() {

        if ($("#item-input").val() == '') {
            Materialize.toast("Please input a list item.", 4000)
        } else if (parseInt($("#items-count").html(), 10) >= 15) {
            Materialize.toast('There are too many list items!', 3000);
        } else {
            Materialize.toast('Item added to list', 5000, 'rounded');
            document.getElementById('add-item-form').submit()
        }
    });

    $(".item-done").click(function() {
        $(this).parent().slideUp();
        Materialize.toast('Item checked', 5000, 'rounded')
    });

    $(".confirm-btn").click(function() {
        Materialize.toast('Confirmed', 3000, 'rounded')
    });

    $(".delete-item").click(function() {
        $(this).parent().slideUp();
        Materialize.toast('Item deleted', 5000, 'rounded')
    });
})








