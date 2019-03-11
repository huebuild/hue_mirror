// Licensed to Cloudera, Inc. under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  Cloudera, Inc. licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import EditorViewModel from '../editorViewModel';

fdescribe('snippet.js', () => {
  beforeEach(() => {
    jasmine.Ajax.install();
  });

  afterEach(() => {
    jasmine.Ajax.uninstall();
  });

  it('should construct a snippet', done => {
    const editor_id = 0;
    const notebooks = undefined;
    const options = {
      huePubSubId: 'editorTest',
      mode: 'editor'
    };

    const notebookName = 'Test Notebook';

    const stubbedRequests = [
      {
        url: '/notebook/api/create_notebook',
        responseText:
          '{"status": 0, "notebook": {"uuid": "045572f7-2d7f-4a45-9557-f9f503ecf227", "sessions": [], "name": "' +
          notebookName +
          '", "isManaged": false, "isSaved": false, "skipHistorify": false, "type": "notebook", "directoryUuid": "", "snippets": [], "description": ""}}'
      },
      {
        url: /notebook\/api\/get_history.*/,
        responseText: '{"status": 0, "count": 0, "message": "History fetched", "history": []}'
      }
    ];

    stubbedRequests.forEach(stubbedRequest => {
      jasmine.Ajax.stubRequest(stubbedRequest.url).andReturn(stubbedRequest);
    });

    const editorViewModel = new EditorViewModel(editor_id, notebooks, options);
    editorViewModel.newNotebook('impala');

    window.setTimeout(() => {
      expect(editorViewModel.selectedNotebook().name()).toEqual(notebookName);
      // console.log(jasmine.Ajax.requests.mostRecent());
      expect(jasmine.Ajax.requests.count()).toEqual(stubbedRequests.length);
      expect(editorViewModel.selectedNotebook().snippets().length).toEqual(1);
      done();
    }, 4000);
  });
});
