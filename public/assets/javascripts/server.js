$(document).ready(function(){
  $('.ui.dimmer').dimmer('show');

  $('audio').audioPlayer();
  $('audio').on('play', function(){
    setTimeout(function(){
      $('.ui.dimmer').dimmer('hide');
    }, 2000);
  });
});
