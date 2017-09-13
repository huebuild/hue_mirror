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

from django.conf.urls import url

# FIXME: This could be replaced with hooking into the `AppConfig.ready()`
# signal in Django 1.7:
#
# https://docs.djangoproject.com/en/1.7/ref/applications/#django.apps.AppConfig.ready
#
# For now though we have to load in the monkey patches here because we know
# this file has been loaded after `desktop.settings` has been loaded.

# Start DBProxy server
import notebook.monkey_patches

from notebook import views
from notebook import api

# Views
urlpatterns = [
  url(r'^$', views.notebook, name='index'),
  url(r'^notebook/?$', views.notebook, name='notebook'),
  url(r'^notebook_embeddable/?$', views.notebook_embeddable, name='notebook_embeddable'),
  url(r'^notebooks/?$', views.notebooks, name='notebooks'),
  url(r'^new/?$', views.new, name='new'),
  url(r'^download/?$', views.download, name='download'),
  url(r'^install_examples/?$', views.install_examples, name='install_examples'),
  url(r'^delete/?$', views.delete, name='delete'),
  url(r'^copy/?$', views.copy, name='copy'),

  url(r'^editor/?$', views.editor, name='editor'),
  url(r'^editor_m/?$', views.editor_m, name='editor_m'),
  url(r'^browse/(?P<database>\w+)/(?P<table>\w+)/(?P<partition_spec>.+?)?$', views.browse, name='browse'),
  url(r'^execute_and_watch/?$', views.execute_and_watch, name='execute_and_watch'),
]

# APIs
urlpatterns += [
  url(r'^api/create_notebook/?$', api.create_notebook, name='create_notebook'),
  url(r'^api/create_session/?$', api.create_session, name='create_session'),
  url(r'^api/close_session/?$', api.close_session, name='close_session'),
  url(r'^api/execute/?(?P<engine>.+)?$', api.execute, name='execute'),
  url(r'^api/check_status/?$', api.check_status, name='check_status'),
  url(r'^api/fetch_result_data/?$', api.fetch_result_data, name='fetch_result_data'),
  url(r'^api/fetch_result_metadata/?$', api.fetch_result_metadata, name='fetch_result_metadata'),
  url(r'^api/fetch_result_size/?$', api.fetch_result_size, name='fetch_result_size'),
  url(r'^api/cancel_statement/?$', api.cancel_statement, name='cancel_statement'),
  url(r'^api/close_statement/?$', api.close_statement, name='close_statement'),
  url(r'^api/get_logs/?$', api.get_logs, name='get_logs'),

  url(r'^api/explain/?$', api.explain, name='explain'),
  url(r'^api/format/?$', api.format, name='format'),
  url(r'^api/get_external_statement/?$', api.get_external_statement, name='get_external_statement'),

  url(r'^api/get_history/?', api.get_history, name='get_history'),
  url(r'^api/clear_history/?', api.clear_history, name='clear_history'),

  url(r'^api/notebook/save/?$', api.save_notebook, name='save_notebook'),
  url(r'^api/notebook/open/?$', api.open_notebook, name='open_notebook'),
  url(r'^api/notebook/close/?$', api.close_notebook, name='close_notebook'),

  url(r'^api/notebook/export_result/?$', api.export_result, name='export_result'),

  url(r'^api/optimizer/statement/risk/?$', api.statement_risk, name='statement_risk'),
  url(r'^api/optimizer/statement/compatibility/?$', api.statement_compatibility, name='statement_compatibility'),
  url(r'^api/optimizer/statement/similarity/?$', api.statement_similarity, name='statement_similarity'),
]

# Assist API
urlpatterns += [
  # HS2, RDBMS, JDBC
  url(r'^api/autocomplete/?$', api.autocomplete, name='api_autocomplete_databases'),
  url(r'^api/autocomplete/(?P<database>\w+)/?$', api.autocomplete, name='api_autocomplete_tables'),
  url(r'^api/autocomplete/(?P<database>\w+)/(?P<table>\w+)/?$', api.autocomplete, name='api_autocomplete_columns'),
  url(r'^api/autocomplete/(?P<database>\w+)/(?P<table>\w+)/(?P<column>\w+)/?$', api.autocomplete, name='api_autocomplete_column'),
  url(r'^api/autocomplete/(?P<database>\w+)/(?P<table>\w+)/(?P<column>\w+)/(?P<nested>.+)/?$', api.autocomplete, name='api_autocomplete_nested'),
  url(r'^api/sample/(?P<database>\w+)/(?P<table>\w+)/?$', api.get_sample_data, name='api_sample_data'),
  url(r'^api/sample/(?P<database>\w+)/(?P<table>\w+)/(?P<column>\w+)/?$', api.get_sample_data, name='api_sample_data_column'),

  # SQLite
  url(r'^api/autocomplete//?(?P<server>[\w_\-/]+)/(?P<database>[\w._\-0-9]+)/?$', api.autocomplete, name='api_autocomplete_tables'),
  url(r'^api/autocomplete//?(?P<server>[\w_\-/]+)/(?P<database>[\w._\-0-9]+)/(?P<table>\w+)/?$', api.autocomplete, name='api_autocomplete_columns'),
  url(r'^api/autocomplete//?(?P<server>[\w_\-/]+)/(?P<database>[\w._\-0-9]+)/(?P<table>\w+)/(?P<column>\w+)/?$', api.autocomplete, name='api_autocomplete_column'),
  url(r'^api/sample/(?P<server>[\w_\-/]+)/(?P<database>[\w._\-0-9]+)/(?P<table>\w+)/?$', api.get_sample_data, name='api_sample_data'),
  url(r'^api/sample/(?P<server>[\w_\-/]+)/(?P<database>[\w._\-0-9]+)/(?P<table>\w+)/(?P<column>\w+)/?$', api.get_sample_data, name='api_sample_data_column'),
]
