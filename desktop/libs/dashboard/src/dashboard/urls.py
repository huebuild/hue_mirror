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
from dashboard import views
from dashboard import api

urlpatterns = [
  url(r'^$', views.index, name='index'),
  url(r'^m$', views.index_m, name='index_m'),
  url(r'^save$', views.save, name='save'),
  url(r'^new_search', views.new_search, name='new_search'),
  url(r'^browse/(?P<name>[^/]+)/?', views.browse, name='browse'),
  url(r'^browse_m/(?P<name>[^/]+)/?', views.browse_m, name='browse_m'),

  # Admin
  url(r'^admin/collections$', views.admin_collections, name='admin_collections'),
  url(r'^admin/collection_delete$', views.admin_collection_delete, name='admin_collection_delete'),
  url(r'^admin/collection_copy$', views.admin_collection_copy, name='admin_collection_copy'),
]


urlpatterns += [
  url(r'^search$', api.search, name='search'),
  url(r'^suggest/$', api.query_suggest, name='query_suggest'),
  url(r'^index/fields/dynamic$', api.index_fields_dynamic, name='index_fields_dynamic'),
  url(r'^index/fields/nested_documents', api.nested_documents, name='nested_documents'),
  url(r'^template/new_facet$', api.new_facet, name='new_facet'),
  url(r'^get_document$', api.get_document, name='get_document'),
  url(r'^update_document$', api.update_document, name='update_document'),
  url(r'^get_range_facet$', api.get_range_facet, name='get_range_facet'),
  url(r'^download$', api.download, name='download'),
  url(r'^get_timeline$', api.get_timeline, name='get_timeline'),
  url(r'^get_collection$', api.get_collection, name='get_collection'),
  url(r'^get_collections$', api.get_collections, name='get_collections'),
  url(r'^get_stats$', api.get_stats, name='get_stats'),
  url(r'^get_terms$', api.get_terms, name='get_terms'),
]
