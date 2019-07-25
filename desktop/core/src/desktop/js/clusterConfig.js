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

import $ from 'jquery';

import apiHelper from 'api/apiHelper';
import huePubSub from 'utils/huePubSub';

const publishConfig = newConfig => {
  huePubSub.publish('cluster.config.set.config', newConfig);
};

class ClusterConfig {
  constructor() {
    this.lastClusterConfigPromise = undefined;

    huePubSub.subscribe('cluster.config.refresh.config', this.refreshConfig);

    huePubSub.subscribe('cluster.config.get.config', callback => {
      if (!this.lastClusterConfigPromise) {
        this.refreshConfig(callback);
      } else {
        this.lastClusterConfigPromise.then(callback || publishConfig);
      }
    });
  }

  async getConfig() {
    if (!this.lastClusterConfigPromise) {
      return this.refreshConfig(() => {});
    }
    return this.lastClusterConfigPromise;
  }

  async refreshConfig(callback) {
    this.lastClusterConfigPromise = new Promise((resolve, reject) => {
      apiHelper
        .getClusterConfig()
        .done(data => {
          if (data.status === 0) {
            resolve(data);
          } else {
            reject(data);
          }
        })
        .fail(reject);
    });

    this.lastClusterConfigPromise.then(callback || publishConfig).catch(error => {
      if (error && error.message) {
        $(document).trigger('error', error.message);
      } else {
        $(document).trigger('error', 'Could not load cluster config. See log for details.');
      }
    });

    return this.lastClusterConfigPromise;
  }
}

const instance = new ClusterConfig();

export default instance;
