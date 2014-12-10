(function(Modules) {
  "use strict";
  Modules.AjaxSave = function() {
    this.start = function(element) {
      var url = element.data('url') || element.attr('action') + '.json',
          message = element.find('.js-status-message');

      element.on('click', '.js-save', save);

      function save(evt) {
        evt.preventDefault();

        message.addClass('workflow-message-saving');
        message.text('Saving…');
        setTimeout(function() {
          message.addClass('workflow-message-saved').removeClass('workflow-message-saving');
          message.text('Saved');

          setTimeout(function() {
            message.removeClass('workflow-message-saved');
          }, 2000);

        }, 2000);

        /*$.ajax({
          url : url,
          type : 'POST',
          data : element.serialize(),
          success : function(response) {
            console.log('success');
            console.log(response);
          }
        });*/
      }
    }
  };
})(window.GOVUKAdmin.Modules);
