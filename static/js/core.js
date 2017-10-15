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

    //$('.items').sortable({ handle: '.move' });
    $('select').material_select();
    $(".button-collapse").sideNav();

    // add new item
    $("#new-item").click(function() {
        if ($("#category-select").val() == null) {
            Materialize.toast('There is no selected item.', 4000)
        } else if ($("#item-input").val() == '') {
            Materialize.toast("Please input a list item.", 4000)
        } else if (parseInt($("#items-count").html(), 10) >= 15) {
            Materialize.toast('There are too many list items!', 3000);
        } else {
            Materialize.toast('Added successfully.', 3000, 'rounded');
            document.getElementById('add-item-form').submit()
        }
    });

    $("#new-category").click(function() {
        if ($("#category-input").val() == '') {
            Materialize.toast('There is no selected category.', 4000)
        } else if (parseInt($("#category-count").html(), 10) >= 12) {
            Materialize.toast('There are too many categories!', 3000);
        } else {
            Materialize.toast('New category added succesfully.', 3000, 'rounded');
            document.getElementById('add-category-form').submit()
        }
    });



    $(".item-done").click(function() {
        $(this).parent().slideUp();
        Materialize.toast('Task completed', 3000, 'rounded')
    });

    $(".categories").hover(function() {
        $(this).find(".delete-category").show();
        }, function() {$(this).find(".delete-category").hide()
    });

    $(".confirm-btn").click(function() {
        Materialize.toast('Confirmed', 3000, 'rounded')
    });

    $(".delete-item").click(function() {
        $(this).parent().slideUp();
        Materialize.toast('Deleted item', 3000, 'rounded')
    });

    $(".delete-category").click(function() {
        $(this).parent().slideUp();
        Materialize.toast('Deleted category', 3000, 'rounded')
    });
})








