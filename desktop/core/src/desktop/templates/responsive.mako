## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
  from desktop import conf
  from desktop.views import _ko
  from django.utils.translation import ugettext as _
  from desktop.lib.i18n import smart_unicode
  from desktop.views import login_modal
%>

<%namespace name="assist" file="/assist.mako" />
<%namespace name="hueIcons" file="/hue_icons.mako" />

<!DOCTYPE html>
<html lang="en" dir="ltr">
<head>
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta charset="utf-8">
  <title>Hue</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <link rel="icon" type="image/x-icon" href="${ static('desktop/art/favicon.ico') }"/>
  <meta name="description" content="">
  <meta name="author" content="">

  <link href="${ static('desktop/ext/css/bootplus.css') }" rel="stylesheet">
  <link href="${ static('desktop/ext/css/font-awesome.min.css') }" rel="stylesheet">
  <link href="${ static('desktop/css/responsive.css') }" rel="stylesheet">
  <link href="${ static('desktop/css/jquery-ui.css') }" rel="stylesheet">

  <!--[if lt IE 9]>
  <script type="text/javascript">
    if (document.documentMode && document.documentMode < 9) {
      location.href = "${ url('desktop.views.unsupported') }";
    }
  </script>
  <![endif]-->

  <script type="text/javascript" charset="utf-8">
    // check if it's a Firefox < 7
    var _UA = navigator.userAgent.toLowerCase();
    for (var i = 1; i < 7; i++) {
      if (_UA.indexOf("firefox/" + i + ".") > -1) {
        location.href = "${ url('desktop.views.unsupported') }";
      }
    }

    // check for IE document modes
    if (document.documentMode && document.documentMode < 9) {
      location.href = "${ url('desktop.views.unsupported') }";
    }

    var LOGGED_USERNAME = '${ user.username }';
    var IS_S3_ENABLED = '${ is_s3_enabled }' === 'True';

    ApiHelperGlobals = {
      i18n: {
        errorLoadingDatabases: '${ _('There was a problem loading the databases') }',
        errorLoadingTablePreview: '${ _('There was a problem loading the preview') }'
      },
      user: '${ user.username }'
    }
  </script>
</head>

<body>

${ hueIcons.symbols() }

<div class="main-page">
  <div class="top-nav">
    <div class="top-nav-left">
      <a class="hamburger hamburger--squeeze pull-left" type="button">
      <span class="hamburger-box">
        <span class="hamburger-inner"></span>
      </span>
      </a>
      <a class="brand nav-tooltip pull-left" title="${_('Homepage')}" rel="navigator-tooltip" href="/home"><img src="${ static('desktop/art/hue-logo-mini-white.png') }" data-orig="${ static('desktop/art/hue-logo-mini-white.png') }" data-hover="${ static('desktop/art/hue-logo-mini-white-hover.png') }"/></a>
    </div>
    <div class="top-nav-middle">
      <div class="search-container">
        <input placeholder="${ _('Search all data and saved documents...') }" type="text"
          data-bind="autocomplete: {
              source: searchAutocompleteSource,
              itemTemplate: 'nav-search-autocomp-item',
              noMatchTemplate: 'nav-search-autocomp-no-match',
              classPrefix: 'nav-',
              showOnFocus: true,
              onEnter: performSearch,
              reopenPattern: /.*:$/
            },
            hasFocus: searchHasFocus,
            clearable: { value: searchInput, onClear: function () { searchActive(false); huePubSub.publish('autocomplete.close'); } },
            textInput: searchInput,
            valueUpdate: 'afterkeydown'"
        >
        <a class="inactive-action" data-bind="click: performSearch"><i class="fa fa-search" data-bind="css: { 'blue': searchHasFocus() || searchActive() }"></i></a>
      </div>
    </div>
    <div class="top-nav-right">
    </div>
  </div>

  <div class="content-wrapper">
    <div class="left-nav">
      <a href="javascript:void(0);" data-bind="click: function () { huePubSub.publish('switch.app', 'editor'); }">Query</a><br/>
      <br/>
      [Hive, Impala, Pig, PySpark, Solr, MapReduce...]<br/>

      <br/>

      Search Dashboards<br/>

      <br/>

      <a href="javascript:void(0);" data-bind="click: function () { huePubSub.publish('switch.app', 'metastore'); }">Browse</a><br/>
      [Tables]<br/>
      [Files]<br/>
      [Indexes]<br/>
      [HBase]<br/>

      <br/>

      Jobs<br/>
      [YARN, MR, Hive, Impala, Spark, Sqoop, Pig]<br/>
      Batch<br/>
      Schedules<br/>
      <br/>

      Oozie<br/>
      Workflows<br/>
      Coordinators<br/>
      Bundles<br/>
      <br/>

      Security<br/>
      Hive Tables<br/>
      Solr Collections<br/>
      HDFS Acls<br/>
      <br/>

      [Custom App 1]<br/>
      [Custom App 2]<br/>
    </div>

    <div style="position: fixed; bottom: 0; left: 0">
      Create Table<br/>
      Import File<br/>
      Import Queries<br/>
      [+]
    </div>

    <div class="left-panel" data-bind="css: { 'side-panel-closed': !leftAssistVisible() }">
      <a href="javascript:void(0);" style="z-index: 1000;" title="${_('Show Assist')}" class="pointer side-panel-toggle show-left-side-panel" data-bind="visible: ! leftAssistVisible(), toggle: leftAssistVisible"><i class="fa fa-chevron-right"></i></a>
      <a href="javascript:void(0);" title="${_('Hide Assist')}" class="pointer side-panel-toggle hide-left-side-panel" data-bind="visible: leftAssistVisible, toggle: leftAssistVisible"><i class="fa fa-chevron-left"></i></a>
      <!-- ko if: leftAssistVisible -->
      <div class="assist" data-bind="component: {
          name: 'assist-panel',
          params: {
            user: '${user.username}',
            sql: {
              sourceTypes: [{
                name: 'hive',
                type: 'hive'
              }],
              navigationSettings: {
                openItem: false,
                showStats: true
              }
            },
            visibleAssistPanels: ['sql']
          }
        }"></div>
      <!-- /ko -->
    </div>

    <div id="leftResizer" class="resizer" data-bind="visible: leftAssistVisible(), splitFlexDraggable : {
      containerSelector: '.content-wrapper',
      sidePanelSelector: '.left-panel',
      sidePanelVisible: leftAssistVisible,
      orientation: 'left',
      onPosition: function() { huePubSub.publish('split.draggable.position') }
    }"><div class="resize-bar">&nbsp;</div></div>


    <div class="page-content">
      Load
      <a href="#" data-bind="click: function(){ currentApp('editor') }">editor</a> |
      <a href="#" data-bind="click: function(){ currentApp('metastore') }">metastore</a> |
      <a href="#" data-bind="click: function(){ currentApp('search') }">search</a>

      <!-- ko if: isLoadingEmbeddable -->
      <i class="fa fa-spinner fa-spin"></i>
      <!-- /ko -->
      <div id="embeddable"></div>
    </div>

    <div id="rightResizer" class="resizer" data-bind="visible: rightAssistVisible(), splitFlexDraggable : {
      containerSelector: '.content-wrapper',
      sidePanelSelector: '.right-panel',
      sidePanelVisible: rightAssistVisible,
      orientation: 'right',
      onPosition: function() { huePubSub.publish('split.draggable.position') }
    }"><div class="resize-bar">&nbsp;</div></div>

    <div class="right-panel" data-bind="css: { 'side-panel-closed': !rightAssistVisible() }">
      <a href="javascript:void(0);" style="z-index: 1000;" title="${_('Show Assist')}" class="pointer side-panel-toggle show-right-side-panel" data-bind="visible: ! rightAssistVisible(), toggle: rightAssistVisible"><i class="fa fa-chevron-left"></i></a>
      <a href="javascript:void(0);" title="${_('Hide Assist')}" class="pointer side-panel-toggle hide-right-side-panel" data-bind="visible: rightAssistVisible, toggle: rightAssistVisible"><i class="fa fa-chevron-right"></i></a>
    </div>
  </div>
</div>

<script src="${ static('desktop/ext/js/jquery/jquery-2.2.3.min.js') }"></script>
<script src="${ static('desktop/js/hue.utils.js') }"></script>
<script src="${ static('desktop/ext/js/bootstrap.min.js') }"></script>
<script src="${ static('desktop/ext/js/moment-with-locales.min.js') }"></script>
<script src="${ static('desktop/ext/js/jquery/plugins/jquery.total-storage.min.js') }"></script>
<script src="${ static('desktop/ext/js/jquery/plugins/jquery.cookie.js') }"></script>

<script src="${ static('desktop/ext/js/jquery/plugins/jquery.basictable.min.js') }"></script>
<script src="${ static('desktop/ext/js/jquery/plugins/jquery-ui-1.10.4.custom.min.js') }"></script>

<script src="${ static('desktop/js/jquery.nicescroll.js') }"></script>

<script src="${ static('desktop/js/jquery.hdfsautocomplete.js') }" type="text/javascript" charset="utf-8"></script>
<script src="${ static('desktop/js/jquery.filechooser.js') }"></script>
<script src="${ static('desktop/js/jquery.selector.js') }"></script>
<script src="${ static('desktop/js/jquery.delayedinput.js') }"></script>
<script src="${ static('desktop/js/jquery.rowselector.js') }"></script>
<script src="${ static('desktop/js/jquery.notify.js') }"></script>
<script src="${ static('desktop/js/jquery.titleupdater.js') }"></script>
<script src="${ static('desktop/js/jquery.horizontalscrollbar.js') }"></script>
<script src="${ static('desktop/js/jquery.tablescroller.js') }"></script>
<script src="${ static('desktop/js/jquery.tableextender.js') }"></script>
<script src="${ static('desktop/js/jquery.tableextender2.js') }"></script>

<script src="${ static('desktop/ext/js/knockout.min.js') }"></script>
<script src="${ static('desktop/js/apiHelper.js') }"></script>
<script src="${ static('desktop/js/ko.charts.js') }"></script>
<script src="${ static('desktop/ext/js/knockout-mapping.min.js') }"></script>
<script src="${ static('desktop/ext/js/knockout-sortable.min.js') }"></script>
<script src="${ static('desktop/js/ko.editable.js') }"></script>
<script src="${ static('desktop/js/ko.hue-bindings.js') }"></script>
<script src="${ static('desktop/js/jquery.scrollup.js') }"></script>

${ assist.assistJSModels() }

${ assist.assistPanel() }

<script type="text/javascript" charset="utf-8">

  $(document).ready(function () {
    var options = {
      user: '${ user.username }',
      i18n: {
        errorLoadingDatabases: "${ _('There was a problem loading the databases') }"
      }
    };

    (function () {
      var OnePageViewModel = function () {
        var self = this;

        self.EMBEDDABLE_PAGE_URLS = {
          editor: '/notebook/editor_embeddable',
          metastore: '/metastore/tables/?is_embeddable=true',
          search: '/search/embeddable?collection=4'
        };

        self.embeddable_cache = {};

        self.currentApp = ko.observable('');
        self.isLoadingEmbeddable = ko.observable(false);

        self.currentApp.subscribe(function(newVal){
          self.isLoadingEmbeddable(true);
          if (typeof self.embeddable_cache[newVal] === 'undefined'){
            $.ajax({
              url: self.EMBEDDABLE_PAGE_URLS[newVal],
              beforeSend:function (xhr) {
                xhr.setRequestHeader('X-Requested-With', 'Hue');
              },
              dataType:'html',
              success:function (response) {
                // TODO: remove the next lines
                // hack to avoid css caching for development
                var r = $(response);
                r.find('link').each(function(){ $(this).attr('href', $(this).attr('href') + '?' + Math.random()) });
                self.embeddable_cache[newVal] = r;
                $('#embeddable').html(r);
                self.isLoadingEmbeddable(false);
              }
            });
          }
          else {
            $('#embeddable').html(self.embeddable_cache[newVal]);
            self.isLoadingEmbeddable(false);
          }
        });

        huePubSub.subscribe('switch.app', function (name) {
          console.log(name);
          self.currentApp(name);
        });
      };

      ko.applyBindings(new OnePageViewModel(), $('.page-content')[0]);
    })();


    (function () {
      function SidePanelViewModel () {
        var self = this;
        self.apiHelper = ApiHelper.getInstance();
        self.leftAssistVisible = ko.observable();
        self.rightAssistVisible = ko.observable();
        self.apiHelper.withTotalStorage('assist', 'left_assist_panel_visible', self.leftAssistVisible, true);
        self.apiHelper.withTotalStorage('assist', 'right_assist_panel_visible', self.rightAssistVisible, true);
      }

      var sidePanelViewModel = new SidePanelViewModel();
      ko.applyBindings(sidePanelViewModel, $('.left-panel')[0]);
      ko.applyBindings(sidePanelViewModel, $('#leftResizer')[0]);
      ko.applyBindings(sidePanelViewModel, $('#rightResizer')[0]);
      ko.applyBindings(sidePanelViewModel, $('.right-panel')[0]);
    })();

    (function () {
      function TopNavViewModel () {
        var self = this;
        self.searchActive = ko.observable(false);
        self.searchHasFocus = ko.observable(false);
        self.searchInput = ko.observable();
      }

      TopNavViewModel.prototype.performSearch = function () {
      };

      TopNavViewModel.prototype.searchAutocompleteSource = function () {
      };

      ko.applyBindings(new TopNavViewModel(), $('.top-nav')[0]);
    })();

    window.hueDebug = {
      viewModel: function () {
        return window.hueDebug.onePageViewModel();
      },
      onePageViewModel: function () {
        return ko.dataFor($('.page-content')[0]);
      },
      sidePanelViewModel: function () {
        return ko.dataFor($('.left-panel')[0]);
      },
      topNavViewModel: function () {
        return ko.dataFor($('.top-nav')[0]);
      }
    };

    if (window.location.getParameter('editor') !== '' || window.location.getParameter('type') !== ''){
      opvm.currentApp('editor');
    }
  });

  $(".hamburger").click(function () {
    $(this).toggleClass("is-active");
    $(".left-nav").toggleClass("left-nav-visible");
  });

  moment.locale(window.navigator.userLanguage || window.navigator.language);
  localeFormat = function (time) {
    var mTime = time;
    if (typeof ko !== 'undefined' && ko.isObservable(time)) {
      mTime = time();
    }
    try {
      mTime = new Date(mTime);
      if (moment(mTime).isValid()) {
        return moment.utc(mTime).format("L LT");
      }
    }
    catch (e) {
      return mTime;
    }
    return mTime;
  };

  // Add CSRF Token to all XHR Requests
  var xrhsend = XMLHttpRequest.prototype.send;
  XMLHttpRequest.prototype.send = function (data) {
    % if request and request.COOKIES and request.COOKIES.get('csrftoken'):
      this.setRequestHeader('X-CSRFToken', "${ request.COOKIES.get('csrftoken') }");
    % else:
      this.setRequestHeader('X-CSRFToken', "");
    % endif

    return xrhsend.apply(this, arguments);
  };

  // Set global assistHelper TTL
  $.totalStorage('hue.cacheable.ttl', ${conf.CUSTOM.CACHEABLE_TTL.get()});

  $(document).ready(function () {
##       // forces IE's ajax calls not to cache
##       if ($.browser.msie) {
##         $.ajaxSetup({ cache: false });
##       }

    // prevents framebusting and clickjacking
    if (self == top) {
      $("body").css({
        'display': 'block',
        'visibility': 'visible'
      });
    } else {
      top.location = self.location;
    }

    %if conf.AUTH.IDLE_SESSION_TIMEOUT.get() > -1 and not skip_idle_timeout:
      var idleTimer;

      function resetIdleTimer() {
        clearTimeout(idleTimer);
        idleTimer = setTimeout(function () {
          // Check if logged out
          $.get('/desktop/debug/is_idle');
        }, ${conf.AUTH.IDLE_SESSION_TIMEOUT.get()} * 1000 + 1000
        );
      }

      $(document).on('mousemove', resetIdleTimer);
      $(document).on('keydown', resetIdleTimer);
      $(document).on('click', resetIdleTimer);
      resetIdleTimer();
    %endif

    % if 'jobbrowser' in apps:
      var JB_CHECK_INTERVAL_IN_MILLIS = 30000;
      var checkJobBrowserStatusIdx = window.setTimeout(checkJobBrowserStatus, 10);

      function checkJobBrowserStatus(){
        $.post("/jobbrowser/jobs/", {
            "format": "json",
            "state": "running",
            "user": "${user.username}"
          },
          function(data) {
            if (data != null && data.jobs != null) {
              huePubSub.publish('jobbrowser.data', data.jobs);
              if (data.jobs.length > 0){
                $("#jobBrowserCount").removeClass("hide").text(data.jobs.length);
              }
              else {
                $("#jobBrowserCount").addClass("hide");
              }
            }
          checkJobBrowserStatusIdx = window.setTimeout(checkJobBrowserStatus, JB_CHECK_INTERVAL_IN_MILLIS);
        }).fail(function () {
          window.clearTimeout(checkJobBrowserStatusIdx);
        });
      }
      huePubSub.subscribe('check.job.browser', checkJobBrowserStatus);
    % endif
  });

</script>

<script type="text/javascript">

  $(document).ready(function () {
    // global catch for ajax calls after the user has logged out
    var isLoginRequired = false;
    $(document).ajaxComplete(function (event, xhr, settings) {
      if (xhr.responseText === '/* login required */' && !isLoginRequired) {
        isLoginRequired = true;
        $('body').children(':not(#login-modal)').addClass('blurred');
        if ($('#login-modal').length > 0) {
          $('#login-modal').modal('show');
          window.setTimeout(function () {
            $('.jHueNotify').remove();
          }, 200);
        }
        else {
          location.reload();
        }
      }
    });

    $('#login-modal').on('hidden', function () {
      isLoginRequired = false;
      $('.blurred').removeClass('blurred');
    });

    huePubSub.subscribe('hue.login.result', function (response) {
      if (response.auth) {
        $('#login-modal').modal('hide');
        $.jHueNotify.info('${ _('You have signed in successfully!') }');
        $('#login-modal .login-error').addClass('hide');
      } else {
        $('#login-modal .login-error').removeClass('hide');
      }
    });
  });

  $(".modal").on("shown", function () {
    // safe ux enhancement: focus on the first editable input
    $(".modal:visible").find("input:not(.disable-autofocus):visible:first").focus();
  });

    %if collect_usage:
      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', 'UA-40351920-1']);

      // We collect only 2 path levels: not hostname, no IDs, no anchors...
      var _pathName = location.pathname;
      var _splits = _pathName.substr(1).split("/");
      _pathName = _splits[0] + (_splits.length > 1 && $.trim(_splits[1]) != "" ? "/" + _splits[1] : "");

      _gaq.push(['_trackPageview', '/remote/${ version }/' + _pathName]);

      (function () {
        var ga = document.createElement('script');
        ga.type = 'text/javascript';
        ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0];
        s.parentNode.insertBefore(ga, s);
      })();

      function trackOnGA(path) {
        if (typeof _gaq != "undefined" && _gaq != null) {
          _gaq.push(['_trackPageview', '/remote/${ version }/' + path]);
        }
      }
    %endif
</script>
</body>
</html>