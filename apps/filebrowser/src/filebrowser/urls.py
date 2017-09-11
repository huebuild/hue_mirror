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
from filebrowser import views
from filebrowser import api

urlpatterns = [
  # Base view
  url(r'^$', views.index, name='index'),

  # Catch-all for viewing a file (display) or a directory (listdir)
  url(r'^view=(?P<path>.*)$', views.view, name='view'),

  url(r'^listdir=(?P<path>.*)$', views.listdir, name='listdir'),
  url(r'^display=(?P<path>.*)$', views.display, name='display'),
  url(r'^stat=(?P<path>.*)$', views.stat, name='stat'),
  url(r'^content_summary=(?P<path>.*)$', views.content_summary, name='content_summary'),
  url(r'^download=(?P<path>.*)$', views.download, name='download'),
  url(r'^status$', views.status, name='status'),
  url(r'^home_relative_view=(?P<path>.*)$', views.home_relative_view, name='home_relative_view'),
  url(r'^edit=(?P<path>.*)$', views.edit, name='edit'),

  # POST operations
  url(r'^save$', views.save_file),
  url(r'^upload/file$', views.upload_file, name='upload_file'),
  url(r'^upload/archive$', views.upload_archive, name='upload_archive'),
  url(r'^extract_archive', views.extract_archive_using_batch_job, name='extract_archive_using_batch_job'),
  url(r'^compress_files', views.compress_files_using_batch_job, name='compress_files_using_batch_job'),
  url(r'^trash/restore$', views.trash_restore, name='trash_restore'),
  url(r'^trash/purge$', views.trash_purge, name='trash_purge'),
  url(r'^rename$', views.rename, name='rename'),
  url(r'^mkdir$', views.mkdir, name='mkdir'),
  url(r'^touch$', views.touch, name='touch'),
  url(r'^move$', views.move, name='move'),
  url(r'^copy$', views.copy, name='copy'),
  url(r'^set_replication$', views.set_replication, name='set_replication'),
  url(r'^rmtree$', views.rmtree, name='rmtree'),
  url(r'^chmod$', views.chmod, name='chmod'),
  url(r'^chown$', views.chown, name='chown'),
]

# API
urlpatterns += [
  url(r'^api/get_filesystems/?', api.get_filesystems, name='get_filesystems'),
]
