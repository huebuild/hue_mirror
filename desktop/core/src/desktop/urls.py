#!/usr/bin/env python
# Licensed to Cloudera, Inc. under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  Cloudera, Inc. licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import absolute_import

import logging
import re

# FIXME: This could be replaced with hooking into the `AppConfig.ready()`
# signal in Django 1.7:
#
# https://docs.djangoproject.com/en/1.7/ref/applications/#django.apps.AppConfig.ready
#
# For now though we have to load in the monkey patches here because we know
# this file has been loaded after `desktop.settings` has been loaded.
import desktop.monkey_patches

import desktop.lib.metrics.file_reporter
desktop.lib.metrics.file_reporter.start_file_reporter()

from django.conf import settings
from django.conf.urls import include
from django.contrib import admin

from desktop import appmanager
from desktop.conf import METRICS, USE_NEW_EDITOR

from useradmin import views as useradmin_views
from desktop.auth import views as auth_views
from desktop import api
from desktop import api2
from desktop import views
from desktop.configuration import api as desktop_configuration_api
from desktop.lib.vcs import api as desktop_lib_vcs_api
from notebook import views as notebook_views


# Django expects handler404 and handler500 to be defined.
# django.conf.urls provides them. But we want to override them.
# Also see http://code.djangoproject.com/ticket/5350
handler403 = 'desktop.views.serve_403_error'
handler404 = 'desktop.views.serve_404_error'
handler500 = 'desktop.views.serve_500_error'


admin.autodiscover()

# Some django-wide URLs
dynamic_patterns = [
  (r'^accounts/login/$', auth_views.dt_login),
  (r'^accounts/logout/$', auth_views.dt_logout, {'next_page': '/'}),
  (r'^profile$', auth_views.profile),
  (r'^login/oauth/?$', auth_views.oauth_login),
  (r'^login/oauth_authenticated/?$', auth_views.oauth_authenticated),
]


if USE_NEW_EDITOR.get():
  dynamic_patterns += [
    (r'^home/?$',views.home2),
    (r'^home2$',views.home),
    (r'^home_embeddable$',views.home_embeddable),
  ]
else:
  dynamic_patterns += [
    (r'^home$', views.home),
    (r'^home2$', views.home2)
  ]

dynamic_patterns += [
  (r'^logs$', views.log_view),
  (r'^desktop/log_analytics$', views.log_analytics),
  (r'^desktop/log_js_error$', views.log_js_error),
  (r'^desktop/dump_config$', views.dump_config),
  (r'^desktop/download_logs$', views.download_log_view),
  (r'^desktop/get_debug_level', views.get_debug_level),
  (r'^desktop/set_all_debug', views.set_all_debug),
  (r'^desktop/reset_all_debug', views.reset_all_debug),
  (r'^bootstrap.js$', views.bootstrap), # unused

  (r'^desktop/status_bar/?$', views.status_bar),
  (r'^desktop/debug/is_alive$',views.is_alive),
  (r'^desktop/debug/is_idle$',views.is_idle),
  (r'^desktop/debug/threads$', views.threads),
  (r'^desktop/debug/memory$', views.memory),
  (r'^desktop/debug/check_config$', views.check_config),
  (r'^desktop/debug/check_config_ajax$', views.check_config_ajax),
  (r'^desktop/log_frontend_event$', views.log_frontend_event),

  # Mobile
  (r'^assist_m', views.assist_m),
  # Hue 4
  (r'^hue.*/$', views.hue),
  (r'^403$', views.path_forbidden),
  (r'^404$', views.not_found),
  (r'^500$', views.server_error),

  # KO components, change to doc?name=ko_editor or similar
  (r'^ko_editor', views.ko_editor),
  (r'^ko_metastore', views.ko_metastore),

  # Jasmine
  (r'^jasmine', views.jasmine),

  # Web workers
  (r'^desktop/workers/aceSqlLocationWorker.js', views.ace_sql_location_worker),
  (r'^desktop/workers/aceSqlSyntaxWorker.js', views.ace_sql_syntax_worker),

  # Unsupported browsers
  (r'^boohoo$',views.unsupported),

  # Top level web page!
  (r'^$', views.index),
]

dynamic_patterns += [
  # Tags
  (r'^desktop/api/tag/add_tag$', api.add_tag),
  (r'^desktop/api/tag/remove_tag$', api.remove_tag),
  (r'^desktop/api/doc/tag$', api.tag),
  (r'^desktop/api/doc/update_tags$', api.update_tags),
  (r'^desktop/api/doc/get$', api.get_document),

  # Permissions
  (r'^desktop/api/doc/update_permissions', api.update_permissions),
]

dynamic_patterns += [
  (r'^desktop/api2/doc/open?$', api2.open_document),  # To keep before get_document
  (r'^desktop/api2/docs/?$', api2.search_documents),  # search documents for current user
  (r'^desktop/api2/doc/?$', api2.get_document),  # get doc/dir by path or UUID

  (r'^desktop/api2/doc/move/?$', api2.move_document),
  (r'^desktop/api2/doc/mkdir/?$', api2.create_directory),
  (r'^desktop/api2/doc/update/?$', api2.update_document),
  (r'^desktop/api2/doc/delete/?$', api2.delete_document),
  (r'^desktop/api2/doc/restore/?$', api2.restore_document),
  (r'^desktop/api2/doc/share/?$', api2.share_document),

  (r'^desktop/api2/get_config/?$', api2.get_config),
  (r'^desktop/api2/user_preferences/(?P<key>\w+)?$', api2.user_preferences),

  (r'^desktop/api2/doc/export/?$', api2.export_documents),
  (r'^desktop/api2/doc/import/?$', api2.import_documents),

  (r'^desktop/api/search/entities/?$', api2.search_entities),
  (r'^desktop/api/search/entities_interactive/?$', api2.search_entities_interactive),
]

dynamic_patterns += [
  (r'^editor', notebook_views.editor),
]

# Default Configurations
dynamic_patterns += [
  (r'^desktop/api/configurations/?$', desktop_configuration_api.default_configurations),
  (r'^desktop/api/configurations/user/?$', desktop_configuration_api.app_configuration_for_user),
  (r'^desktop/api/configurations/delete/?$', desktop_configuration_api.delete_default_configuration),
]

dynamic_patterns += [
  (r'^desktop/api/users/autocomplete', useradmin_views.list_for_autocomplete),
]

dynamic_patterns += [
  (r'^desktop/api/vcs/contents/?$', desktop_lib_vcs_api.contents),
  (r'^desktop/api/vcs/authorize/?$', desktop_lib_vcs_api.authorize),
]

# Metrics specific
if METRICS.ENABLE_WEB_METRICS.get():
  dynamic_patterns += [
    (r'^desktop/metrics/', include('desktop.lib.metrics.urls')),
  ]

dynamic_patterns += [
  (r'^admin/', include(admin.site.urls))
]

static_patterns = []

# SAML specific
if settings.SAML_AUTHENTICATION:
  static_patterns.append((r'^saml2/', include('libsaml.urls')))

# OpenId specific
if settings.OPENID_AUTHENTICATION:
    static_patterns.append((r'^openid/', include('libopenid.urls')))

if settings.OAUTH_AUTHENTICATION:
  static_patterns.append((r'^oauth/', include('liboauth.urls')))

# Root each app at /appname if they have a "urls" module
for app in appmanager.DESKTOP_MODULES:
  if app.urls:
    if app.is_url_namespaced:
      namespace = {'namespace': app.name, 'app_name': app.name}
    else:
      namespace = {}
    if namespace or app in appmanager.DESKTOP_APPS:
      dynamic_patterns.extend( ('^' + re.escape(app.name) + '/', include(app.urls, **namespace)) )
      app.urls_imported = True

static_patterns.append(
    (r'^%s(?P<path>.*)$' % re.escape(settings.STATIC_URL.lstrip('/')),
      'django.views.static.serve',
      { 'document_root': settings.STATIC_ROOT })
)

urlpatterns = static_patterns + dynamic_patterns

for x in dynamic_patterns:
  logging.debug("Dynamic pattern: %s" % (x,))
for x in static_patterns:
  logging.debug("Static pattern: %s" % (x,))
