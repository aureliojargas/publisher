(function(Modules) {
  "use strict";
  Modules.AjaxSave = function() {
    this.start = function(element) {
      var url = element.data('url') || element.attr('action') + '.json';

      element.on('click', '.js-save', save);

      function save(evt) {
        evt.preventDefault();

        $.ajax({
          url : url,
          type : 'POST',
          data : element.serialize(),
          success : function(response) {
            console.log('success');
            console.log(response);
          }
        });
      }
    }
  };
})(window.GOVUKAdmin.Modules);
