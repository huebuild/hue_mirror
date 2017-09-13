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
import oozie.views.api as api
import oozie.views.editor as editor
import oozie.views.editor2 as editor2
import oozie.views.dashboard as dashboard
import oozie.views.common as common


IS_URL_NAMESPACED = True


urlpatterns = [
  url(r'^list_workflows/$', editor.list_workflows, name='list_workflows'),
  url(r'^list_trashed_workflows/$', editor.list_trashed_workflows, name='list_trashed_workflows'),
  url(r'^create_workflow/$', editor.create_workflow, name='create_workflow'),
  url(r'^edit_workflow/(?P<workflow>\d+)$', editor.edit_workflow, name='edit_workflow'),
  url(r'^delete_workflow$', editor.delete_workflow, name='delete_workflow'),
  url(r'^restore_workflow/$', editor.restore_workflow, name='restore_workflow'),
  url(r'^clone_workflow/(?P<workflow>\d+)$', editor.clone_workflow, name='clone_workflow'),
  url(r'^submit_workflow/(?P<workflow>\d+)$', editor.submit_workflow, name='submit_workflow'),
  url(r'^schedule_workflow/(?P<workflow>\d+)$', editor.schedule_workflow, name='schedule_workflow'),
  url(r'^import_workflow/$', editor.import_workflow, name='import_workflow'),
  url(r'^import_coordinator/$', editor.import_coordinator, name='import_coordinator'),
  url(r'^export_workflow/(?P<workflow>\d+)$', editor.export_workflow, name='export_workflow'),

  url(r'^list_coordinators/(?P<workflow_id>[-\w]+)?$', editor.list_coordinators, name='list_coordinators'),
  url(r'^list_trashed_coordinators/$', editor.list_trashed_coordinators, name='list_trashed_coordinators'),
  url(r'^create_coordinator/(?P<workflow>[-\w]+)?$', editor.create_coordinator, name='create_coordinator'),
  url(r'^edit_coordinator/(?P<coordinator>[-\w]+)$', editor.edit_coordinator, name='edit_coordinator'),
  url(r'^delete_coordinator$', editor.delete_coordinator, name='delete_coordinator'),
  url(r'^restore_coordinator$', editor.restore_coordinator, name='restore_coordinator'),
  url(r'^clone_coordinator/(?P<coordinator>\d+)$', editor.clone_coordinator, name='clone_coordinator'),
  url(r'^create_coordinator_dataset/(?P<coordinator>[-\w]+)$', editor.create_coordinator_dataset, name='create_coordinator_dataset'),
  url(r'^edit_coordinator_dataset/(?P<dataset>\d+)$', editor.edit_coordinator_dataset, name='edit_coordinator_dataset'),
  url(r'^create_coordinator_data/(?P<coordinator>[-\w]+)/(?P<data_type>(input|output))$', editor.create_coordinator_data, name='create_coordinator_data'),
  url(r'^submit_coordinator/(?P<coordinator>\d+)$', editor.submit_coordinator, name='submit_coordinator'),

  url(r'^list_bundles$', editor.list_bundles, name='list_bundles'),
  url(r'^list_trashed_bundles$', editor.list_trashed_bundles, name='list_trashed_bundles'),
  url(r'^create_bundle$', editor.create_bundle, name='create_bundle'),
  url(r'^edit_bundle/(?P<bundle>\d+)$', editor.edit_bundle, name='edit_bundle'),
  url(r'^submit_bundle/(?P<bundle>\d+)$', editor.submit_bundle, name='submit_bundle'),
  url(r'^clone_bundle/(?P<bundle>\d+)$', editor.clone_bundle, name='clone_bundle'),
  url(r'^delete_bundle$', editor.delete_bundle, name='delete_bundle'),
  url(r'^restore_bundle$', editor.restore_bundle, name='restore_bundle'),
  url(r'^create_bundled_coordinator/(?P<bundle>\d+)$', editor.create_bundled_coordinator, name='create_bundled_coordinator'),
  url(r'^edit_bundled_coordinator/(?P<bundle>\d+)/(?P<bundled_coordinator>\d+)$', editor.edit_bundled_coordinator, name='edit_bundled_coordinator'),

  url(r'^list_history$', editor.list_history, name='list_history'), # Unused
  url(r'^list_history/(?P<record_id>[-\w]+)$', editor.list_history_record, name='list_history_record'),
  url(r'^install_examples/$', editor.install_examples, name='install_examples'),
]


urlpatterns += [
  url(r'^editor/workflow/list/$', editor2.list_editor_workflows, name='list_editor_workflows'),
  url(r'^editor/workflow/edit/$', editor2.edit_workflow, name='edit_workflow'),
  url(r'^editor/workflow/new/$', editor2.new_workflow, name='new_workflow'),
  url(r'^editor/workflow/delete/$', editor2.delete_job, name='delete_editor_workflow'),
  url(r'^editor/workflow/copy/$', editor2.copy_workflow, name='copy_workflow'),
  url(r'^editor/workflow/save/$', editor2.save_workflow, name='save_workflow'),
  url(r'^editor/workflow/submit/(?P<doc_id>\d+)$', editor2.submit_workflow, name='editor_submit_workflow'),
  url(r'^editor/workflow/submit_single_action/(?P<doc_id>\d+)/(?P<node_id>.+)$', editor2.submit_single_action, name='submit_single_action'),
  url(r'^editor/workflow/new_node/$', editor2.new_node, name='new_node'),
  url(r'^editor/workflow/add_node/$', editor2.add_node, name='add_node'),
  url(r'^editor/workflow/parameters/$', editor2.workflow_parameters, name='workflow_parameters'),
  url(r'^editor/workflow/action/parameters/$', editor2.action_parameters, name='action_parameters'),
  url(r'^editor/workflow/gen_xml/$', editor2.gen_xml_workflow, name='gen_xml_workflow'),
  url(r'^editor/workflow/open_v1/$', editor2.open_old_workflow, name='open_old_workflow'),

  url(r'^editor/coordinator/list/$', editor2.list_editor_coordinators, name='list_editor_coordinators'),
  url(r'^editor/coordinator/edit/$', editor2.edit_coordinator, name='edit_coordinator'),
  url(r'^editor/coordinator/new/$', editor2.new_coordinator, name='new_coordinator'),
  url(r'^editor/coordinator/delete/$', editor2.delete_job, name='delete_editor_coordinator'),
  url(r'^editor/coordinator/copy/$', editor2.copy_coordinator, name='copy_coordinator'),
  url(r'^editor/coordinator/save/$', editor2.save_coordinator, name='save_coordinator'),
  url(r'^editor/coordinator/submit/(?P<doc_id>[-\w]+)$', editor2.submit_coordinator, name='editor_submit_coordinator'),
  url(r'^editor/coordinator/gen_xml/$', editor2.gen_xml_coordinator, name='gen_xml_coordinator'),
  url(r'^editor/coordinator/open_v1/$', editor2.open_old_coordinator, name='open_old_coordinator'),
  url(r'^editor/coordinator/parameters/$', editor2.coordinator_parameters, name='coordinator_parameters'),

  url(r'^editor/bundle/list/$', editor2.list_editor_bundles, name='list_editor_bundles'),
  url(r'^editor/bundle/edit/$', editor2.edit_bundle, name='edit_bundle'),
  url(r'^editor/bundle/new/$', editor2.new_bundle, name='new_bundle'),
  url(r'^editor/bundle/delete/$', editor2.delete_job, name='delete_editor_bundle'),
  url(r'^editor/bundle/copy/$', editor2.copy_bundle, name='copy_bundle'),
  url(r'^editor/bundle/save/$', editor2.save_bundle, name='save_bundle'),
  url(r'^editor/bundle/submit/(?P<doc_id>\d+)$', editor2.submit_bundle, name='editor_submit_bundle'),
  url(r'^editor/bundle/open_v1/$', editor2.open_old_bundle, name='open_old_bundle'),
]

urlpatterns += [
  url(r'^workflows$', api.workflows, name='workflows'),
  url(r'^workflows/(?P<workflow>\d+)$', api.workflow, name='workflow'),
  url(r'^workflows/(?P<workflow>\d+)/save$', api.workflow_save, name='workflow_save'),
  url(r'^workflows/(?P<workflow>\d+)/actions$', api.workflow_actions, name='workflow_actions'),
  url(r'^workflows/(?P<workflow>\d+)/nodes/(?P<node_type>\w+)/validate$', api.workflow_validate_node, name='workflow_validate_node'),
  url(r'^workflows/autocomplete_properties/$', api.autocomplete_properties, name='autocomplete_properties'),
]


urlpatterns += [
  url(r'^$', dashboard.list_oozie_workflows, name='index'),

  url(r'^list_oozie_workflows/$', dashboard.list_oozie_workflows, name='list_oozie_workflows'),
  url(r'^list_oozie_coordinators/$', dashboard.list_oozie_coordinators, name='list_oozie_coordinators'),
  url(r'^list_oozie_bundles/$', dashboard.list_oozie_bundles, name='list_oozie_bundles'),
  url(r'^list_oozie_workflow/(?P<job_id>[-\w]+)/$', dashboard.list_oozie_workflow, name='list_oozie_workflow'),
  url(r'^list_oozie_coordinator/(?P<job_id>[-\w]+)/$', dashboard.list_oozie_coordinator, name='list_oozie_coordinator'),
  url(r'^list_oozie_workflow_action/(?P<action>[-\w@]+)/$', dashboard.list_oozie_workflow_action, name='list_oozie_workflow_action'),
  url(r'^list_oozie_bundle/(?P<job_id>[-\w]+)$', dashboard.list_oozie_bundle, name='list_oozie_bundle'),

  url(r'^rerun_oozie_job/(?P<job_id>[-\w]+)/(?P<app_path>.+?)?$', dashboard.rerun_oozie_job, name='rerun_oozie_job'),
  url(r'^rerun_oozie_coord/(?P<job_id>[-\w]+)/(?P<app_path>.+?)?$', dashboard.rerun_oozie_coordinator, name='rerun_oozie_coord'),
  url(r'^rerun_oozie_bundle/(?P<job_id>[-\w]+)/(?P<app_path>.+?)$', dashboard.rerun_oozie_bundle, name='rerun_oozie_bundle'),
  url(r'^sync_coord_workflow/(?P<job_id>[-\w]+)$', dashboard.sync_coord_workflow, name='sync_coord_workflow'),
  url(r'^manage_oozie_jobs/(?P<job_id>[-\w]+)/(?P<action>(start|suspend|resume|kill|rerun|change|ignore))$', dashboard.manage_oozie_jobs, name='manage_oozie_jobs'),
  url(r'^bulk_manage_oozie_jobs/$', dashboard.bulk_manage_oozie_jobs, name='bulk_manage_oozie_jobs'),

  url(r'^submit_external_job/(?P<application_path>.+?)$', dashboard.submit_external_job, name='submit_external_job'),
  url(r'^get_oozie_job_log/(?P<job_id>[-\w]+)$', dashboard.get_oozie_job_log, name='get_oozie_job_log'),

  url(r'^list_oozie_info/$', dashboard.list_oozie_info, name='list_oozie_info'),

  url(r'^list_oozie_sla/$', dashboard.list_oozie_sla, name='list_oozie_sla'),
]

urlpatterns += [
  url(r'^jasmine', common.jasmine, name='jasmine'),
]
