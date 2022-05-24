import tourl from (require "mmm.mmmfs.util") require "mmm.dom"

=>
  link_font = (name) ->
    "url('#{tourl @path, "#{name}: font/woff2"}') format('woff2'), url('#{tourl @path, "#{name}: font/woff"}') format('woff')"

  "
    /* source-sans-pro-200 - latin-ext_latin */
    @font-face {
      font-family: 'Source Sans Pro';
      font-style: normal;
      font-weight: 200;
      src: local(''), #{link_font "sans_200"};
    }

    /* source-sans-pro-regular - latin-ext_latin */
    @font-face {
      font-family: 'Source Sans Pro';
      font-style: normal;
      font-weight: 400;
      src: local(''), #{link_font "sans_400"};
    }

    /* source-sans-pro-italic - latin-ext_latin */
    @font-face {
      font-family: 'Source Sans Pro';
      font-style: italic;
      font-weight: 400;
      src: local(''), #{link_font "sans_400i"};
    }

    /* source-sans-pro-600 - latin-ext_latin */
    @font-face {
      font-family: 'Source Sans Pro';
      font-style: normal;
      font-weight: 600;
      src: local(''), #{link_font "sans_600"};
    }

    /* source-code-pro-regular - latin */
    @font-face {
      font-family: 'Source Code Pro';
      font-style: normal;
      font-weight: 400;
      src: local(''), #{link_font "code_400"};
    }
  "
