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
from desktop.lib.django_util import get_username_re_rule, get_groupname_re_rule
from useradmin import views
from useradmin import api

username_re = get_username_re_rule()
groupname_re = get_groupname_re_rule()


urlpatterns = [
  url(r'^$', views.list_users),
  url(r'^users/?$', views.list_users),
  url(r'^groups/?$', views.list_groups),
  url(r'^permissions/?$', views.list_permissions),
  url(r'^configurations/?$', views.list_configurations),
  url(r'^users/edit/(?P<username>%s)$' % (username_re,), views.edit_user),
  url(r'^users/add_ldap_users$', views.add_ldap_users),
  url(r'^users/add_ldap_groups$', views.add_ldap_groups),
  url(r'^users/sync_ldap_users_groups$', views.sync_ldap_users_groups),
  url(r'^groups/edit/(?P<name>%s)$' % (groupname_re,), views.edit_group),
  url(r'^permissions/edit/(?P<app>.+?)/(?P<priv>.+?)/?$', views.edit_permission),
  url(r'^users/new$', views.edit_user, name="useradmin.new"),
  url(r'^groups/new$', views.edit_group, name="useradmin.new_group"),
  url(r'^users/delete', views.delete_user),
  url(r'^groups/delete$', views.delete_group),
]

urlpatterns += [
  url(r'^api/get_users/?', api.get_users, name='api_get_users'),
]
