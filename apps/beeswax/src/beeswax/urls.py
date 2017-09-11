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

from beeswax import views
from beeswax import create_database
from beeswax import create_table
from beeswax import api


urlpatterns = [
  url(r'^$', views.index, name='index'),

  url(r'^execute/?$', views.execute_query, name='execute_query'),
  url(r'^execute/design/(?P<design_id>\d+)$', views.execute_query, name='execute_design'),
  url(r'^execute/query/(?P<query_history_id>\d+)$', views.execute_query, name='watch_query_history'),
  url(r'^results/(?P<id>\d+)/(?P<first_row>\d+)$', views.view_results, name='view_results'),
  url(r'^download/(?P<id>\d+)/(?P<format>\w+)$', views.download, name='download'),

  url(r'^my_queries$', views.my_queries, name='my_queries'),
  url(r'^list_designs$', views.list_designs, name='list_designs'),
  url(r'^list_trashed_designs$', views.list_trashed_designs, name='list_trashed_designs'),
  url(r'^delete_designs$', views.delete_design, name='delete_design'),
  url(r'^restore_designs$', views.restore_design, name='restore_design'),
  url(r'^clone_design/(?P<design_id>\d+)$', views.clone_design, name='clone_design'),
  url(r'^query_history$', views.list_query_history, name='list_query_history'),

  url(r'^configuration/?$', views.configuration, name='configuration'),
  url(r'^install_examples$', views.install_examples, name='install_examples'),
  url(r'^query_cb/done/(?P<server_id>\S+)$', views.query_done_cb, name='query_done_cb'),
]

urlpatterns += [
  url(r'^create/database$', create_database.create_database, name='create_database'),
]

urlpatterns += [
  url(r'^create/create_table/(?P<database>\w+)$', create_table.create_table, name='create_table'),
  url(r'^create/import_wizard/(?P<database>\w+)$', create_table.import_wizard, name='import_wizard'),
  url(r'^create/auto_load/(?P<database>\w+)$', create_table.load_after_create, name='load_after_create'),
]

urlpatterns += [
  url(r'^api/session/?$', api.get_session, name='api_get_session'),
  url(r'^api/session/(?P<session_id>\d+)/?$', api.get_session, name='api_get_session'),
  url(r'^api/session/(?P<session_id>\d+)/close/?$', api.close_session, name='api_close_session'),
  url(r'^api/settings/?$', api.get_settings, name='get_settings'),
  url(r'^api/functions/?$', api.get_functions, name='get_functions'),

  # Deprecated by Notebook API
  url(r'^api/autocomplete/?$', api.autocomplete, name='api_autocomplete_databases'),
  url(r'^api/autocomplete/(?P<database>\w+)/?$', api.autocomplete, name='api_autocomplete_tables'),
  url(r'^api/autocomplete/(?P<database>\w+)/(?P<table>\w+)/?$', api.autocomplete, name='api_autocomplete_columns'),
  url(r'^api/autocomplete/(?P<database>\w+)/(?P<table>\w+)/(?P<column>\w+)/?$', api.autocomplete, name='api_autocomplete_column'),
  url(r'^api/autocomplete/(?P<database>\w+)/(?P<table>\w+)/(?P<column>\w+)/(?P<nested>.+)/?$', api.autocomplete, name='api_autocomplete_nested'),

  url(r'^api/design/(?P<design_id>\d+)?$', api.save_query_design, name='api_save_design'),
  url(r'^api/design/(?P<design_id>\d+)/get$', api.fetch_saved_design, name='api_fetch_saved_design'),

  url(r'^api/query/(?P<query_history_id>\d+)/get$', api.fetch_query_history, name='api_fetch_query_history'),
  url(r'^api/query/parameters$', api.parameters, name='api_parameters'),
  url(r'^api/query/execute/(?P<design_id>\d+)?$', api.execute, name='api_execute'),
  url(r'^api/query/(?P<query_history_id>\d+)/cancel/?$', api.cancel_query, name='api_cancel_query'),
  url(r'^api/query/(?P<query_history_id>\d+)/close/?$', api.close_operation, name='api_close_operation'),
  url(r'^api/query/(?P<query_history_id>\d+)/results/save/hive/table/?$', api.save_results_hive_table, name='api_save_results_hive_table'),
  url(r'^api/query/(?P<query_history_id>\d+)/results/save/hdfs/file/?$', api.save_results_hdfs_file, name='api_save_results_hdfs_file'),
  url(r'^api/query/(?P<query_history_id>\d+)/results/save/hdfs/directory/?$', api.save_results_hdfs_directory, name='api_save_results_hdfs_directory'),
  url(r'^api/watch/json/(?P<id>\d+)/?$', api.watch_query_refresh_json, name='api_watch_query_refresh_json'),

  url(r'^api/query/clear_history/?$', api.clear_history, name='clear_history'),

  url(r'^api/table/(?P<database>\w+)/(?P<table>\w+)/?$', api.describe_table, name='describe_table'),
  url(r'^api/table/(?P<database>\w+)/(?P<table>\w+)/indexes/?$', api.get_indexes, name='get_indexes'),
  url(r'^api/table/(?P<database>\w+)/(?P<table>\w+)/sample/?$', api.get_sample_data, name='get_sample_data'),
  url(r'^api/table/(?P<database>\w+)/(?P<table>\w+)/(?P<column>\w+)/sample/?$', api.get_sample_data, name='get_sample_data_column'),
  url(r'^api/table/(?P<database>\w+)/(?P<table>\w+)/stats/(?P<column>\w+)?$', api.get_table_stats, name='get_table_stats'),
  url(r'^api/table/(?P<database>\w+)/(?P<table>\w+)/terms/(?P<column>\w+)/(?P<prefix>\w+)?$', api.get_top_terms, name='get_top_terms'),

  url(r'^api/analyze/(?P<database>\w+)/(?P<table>\w+)/(?P<columns>\w+)?$', api.analyze_table, name='analyze_table'),
]
