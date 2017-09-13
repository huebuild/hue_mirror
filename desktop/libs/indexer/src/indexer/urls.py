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

from indexer import views
from indexer import solr_api
from indexer import api3
from indexer.indexers import rdbms
from indexer import api

from indexer.conf import ENABLE_NEW_INDEXER


urlpatterns = [
  url(r'^install_examples$', views.install_examples, name='install_examples'),

  url(r'^importer/$', views.importer, name='importer'),
  url(r'^importer/prefill/(?P<source_type>[^/]+)/(?P<target_type>[^/]+)/(?P<target_path>[^/]+)?$', views.importer_prefill, name='importer_prefill'),
]

if ENABLE_NEW_INDEXER.get():
  urlpatterns += [
    url(r'^$', views.indexes, name='indexes'),
    url(r'^indexes/$', views.indexes, name='indexes'),
    url(r'^indexes/(?P<index>[^/]+)/?$', views.indexes, name='indexes'),
    url(r'^collections$', views.collections, name='collections'), # Old page
  ]
else:
  urlpatterns += [
    url(r'^$', views.collections, name='collections'),
    url(r'^indexes/$', views.indexes, name='indexes'),
  ]

urlpatterns += [
  # V2
  url(r'^api/aliases/create/$', solr_api.create_alias, name='create_alias'),
  url(r'^api/configs/list/$', solr_api.list_configs, name='list_configs'),
  url(r'^api/index/list/$', solr_api.list_index, name='list_index'),
  url(r'^api/indexes/list/$', solr_api.list_indexes, name='list_indexes'),
  url(r'^api/indexes/create/$', solr_api.create_index, name='create_index'),
  url(r'^api/indexes/sample/$', solr_api.sample_index, name='sample_index'),
  url(r'^api/indexes/delete/$', solr_api.delete_indexes, name='delete_indexes'),
]

urlpatterns += [
  # Importer
  url(r'^api/indexer/guess_format/$', api3.guess_format, name='guess_format'),
  url(r'^api/indexer/guess_field_types/$', api3.guess_field_types, name='guess_field_types'),

  url(r'^api/importer/submit', api3.importer_submit, name='importer_submit')
]

urlpatterns += [
  url(r'^api/indexer/indexers/get_db_component/$', rdbms.get_db_component, name='get_db_component'),
  url(r'^api/indexer/indexers/get_drivers/$', rdbms.get_drivers, name='get_drivers'),
  url(r'^api/indexer/indexers/jdbc_db_list/$', rdbms.jdbc_db_list, name='jdbc_db_list')
]


# Deprecated
urlpatterns += [
  url(r'^api/fields/parse/$', api.parse_fields, name='api_parse_fields'),
  url(r'^api/autocomplete/$', api.autocomplete, name='api_autocomplete'),
  url(r'^api/collections/$', api.collections, name='api_collections'),
  url(r'^api/collections/create/$', api.collections_create, name='api_collections_create'),
  url(r'^api/collections/import/$', api.collections_import, name='api_collections_import'),
  url(r'^api/collections/remove/$', api.collections_remove, name='api_collections_remove'),
  url(r'^api/collections/(?P<collection>[^/]+)/fields/$', api.collections_fields, name='api_collections_fields'),
  url(r'^api/collections/(?P<collection>[^/]+)/update/$', api.collections_update, name='api_collections_update'),
  url(r'^api/collections/(?P<collection>[^/]+)/data/$', api.collections_data, name='api_collections_data'),
]
