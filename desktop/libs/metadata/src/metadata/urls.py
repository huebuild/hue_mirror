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
from metadata import navigator_api
from metadata import optimizer_api
from metadata import workload_analytics_api



# Navigator API
urlpatterns = [
  url(r'^api/navigator/search_entities/?$', navigator_api.search_entities, name='search_entities'),
  url(r'^api/navigator/search_entities_interactive/?$', navigator_api.search_entities_interactive, name='search_entities_interactive'),
  url(r'^api/navigator/find_entity/?$', navigator_api.find_entity, name='find_entity'),
  url(r'^api/navigator/get_entity/?$', navigator_api.get_entity, name='get_entity'),
  url(r'^api/navigator/add_tags/?$', navigator_api.add_tags, name='add_tags'),
  url(r'^api/navigator/delete_tags/?$', navigator_api.delete_tags, name='delete_tags'),
  url(r'^api/navigator/list_tags/?$', navigator_api.list_tags, name='list_tags'),
  url(r'^api/navigator/suggest/?$', navigator_api.suggest, name='suggest'),
  url(r'^api/navigator/update_properties/?$', navigator_api.update_properties, name='update_properties'),
  url(r'^api/navigator/delete_properties/?$', navigator_api.delete_properties, name='delete_properties'),
  url(r'^api/navigator/lineage/?$', navigator_api.get_lineage, name='get_lineage'),
]


# Optimizer API
urlpatterns += [
  url(r'^api/optimizer/upload/history/?$', optimizer_api.upload_history, name='upload_history'),
  url(r'^api/optimizer/upload/query/?$', optimizer_api.upload_query, name='upload_query'),
  url(r'^api/optimizer/upload/table_stats/?$', optimizer_api.upload_table_stats, name='upload_table_stats'),
  url(r'^api/optimizer/upload/status/?$', optimizer_api.upload_status, name='upload_status'),

  #v2
  url(r'^api/optimizer/get_tenant/?$', optimizer_api.get_tenant, name='get_tenant'),

  url(r'^api/optimizer/top_databases/?$', optimizer_api.top_databases, name='top_databases'),
  url(r'^api/optimizer/top_tables/?$', optimizer_api.top_tables, name='top_tables'),
  url(r'^api/optimizer/top_columns/?$', optimizer_api.top_columns, name='top_columns'),
  url(r'^api/optimizer/top_joins/?$', optimizer_api.top_joins, name='top_joins'),
  url(r'^api/optimizer/top_filters/?$', optimizer_api.top_filters, name='top_filters'),
  url(r'^api/optimizer/top_aggs/?$', optimizer_api.top_aggs, name='top_aggs'),

  url(r'^api/optimizer/table_details/?$', optimizer_api.table_details, name='table_details'),

  url(r'^api/optimizer/query_risk/?$', optimizer_api.query_risk, name='query_risk'),
  url(r'^api/optimizer/query_compatibility/?$', optimizer_api.query_compatibility, name='query_compatibility'),
  url(r'^api/optimizer/similar_queries/?$', optimizer_api.similar_queries, name='similar_queries'),
]


# Workload Analytics API
urlpatterns += [
  url(r'^api/workload_analytics/get_operation_execution_details/?$', workload_analytics_api.get_operation_execution_details, name='get_operation_execution_details'),
]
