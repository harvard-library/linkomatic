// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .
//= require websocket_rails/main

$(document).on('submit', 'form', function(e) {
    $(e.target).find('input[type=submit], button').attr('disabled', true);
});

$(document).ajaxSuccess(function(e) {
    if (e.target.activeElement.nodeName == 'BODY') {
      var $selector = $('input[type=submit]:disabled, button:disabled');
      var message = 'Saved';
      $('<div class="label label-success pull-right">' + message + '</div>').insertAfter($selector).delay(500).fadeOut(500, function() {
        $(this).remove();
        $selector.attr('disabled', false);
      });
    } else {
      $('<div class="label label-success">Saved</div>').insertAfter(e.target.activeElement).delay(500).fadeOut(500, function() { $(this).remove(); });
    }
});
