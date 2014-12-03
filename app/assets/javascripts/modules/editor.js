(function(Modules) {
  "use strict";
  Modules.Editor = function() {
    this.start = function(element) {

      element.find('.js-markdown').each(createEditor);

      function createEditor() {
        var editor = CodeMirror.fromTextArea(this, {
          mode:  'markdown',
          theme: 'govuk',
          lineWrapping: true,
          viewportMargin: Infinity,
          cursorHeight: 0.85
        })
      }
    }
  };
})(window.GOVUKAdmin.Modules);
