// Licensed to Cloudera, Inc. under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  Cloudera, Inc. licenses this file
// to you under the Apache License, Version 2.0 (the
// 'License'); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SqlTestUtils from './sqlTestUtils';
import customSqlAutocompleteParser from '../customSqlAutocompleteParser';

describe('customSqlAutocompleteParser.js SELECT statements', () => {
  beforeAll(() => {
    customSqlAutocompleteParser.yy.parseError = function(msg) {
      throw Error(msg);
    };
    jasmine.addMatchers(SqlTestUtils.testDefinitionMatcher);
  });

  const assertAutoComplete = SqlTestUtils.assertAutocomplete;

  it('should suggest keywords for "|"', () => {
    assertAutoComplete({
      beforeCursor: '',
      afterCursor: '',
      containsKeywords: ['SELECT'],
      expectedResult: {
        lowerCase: false
      }
    });
  });

  it('should suggest tables and databases for "SELECT * |"', () => {
    assertAutoComplete({
      beforeCursor: 'SELECT * ',
      afterCursor: '',
      containsKeywords: ['FROM'],
      expectedResult: {
        lowerCase: false,
        suggestTables: {
          prependFrom: true
        },
        suggestDatabases: {
          prependFrom: true,
          appendDot: true
        }
      }
    });
  });

  it('should suggest tables and databases for "SELECT *\\r\\n |"', () => {
    assertAutoComplete({
      beforeCursor: 'SELECT *\r\n',
      afterCursor: '',
      containsKeywords: ['FROM'],
      expectedResult: {
        lowerCase: false,
        suggestTables: {
          prependFrom: true
        },
        suggestDatabases: {
          prependFrom: true,
          appendDot: true
        }
      }
    });
  });

  it('should suggest keywords for "SELECT foo, bar |"', () => {
    assertAutoComplete({
      beforeCursor: 'SELECT foo, bar ',
      afterCursor: '',
      containsKeywords: ['FROM'],
      expectedResult: {
        lowerCase: false,
        suggestTables: {
          prependFrom: true
        },
        suggestDatabases: {
          prependFrom: true,
          appendDot: true
        }
      }
    });
  });

  it('should suggest databases or tables for "SELECT * fr|"', () => {
    assertAutoComplete({
      beforeCursor: 'SELECT * fr',
      afterCursor: '',
      containsKeywords: ['FROM'],
      expectedResult: {
        lowerCase: false,
        suggestTables: {
          prependFrom: true
        },
        suggestDatabases: {
          prependFrom: true,
          appendDot: true
        }
      }
    });
  });

  it('should suggest databases or tables for "SELECT * FROM |"', () => {
    assertAutoComplete({
      beforeCursor: 'SELECT * FROM ',
      afterCursor: '',
      expectedResult: {
        lowerCase: false,
        suggestTables: {},
        suggestDatabases: {
          appendDot: true
        }
      }
    });
  });

  it('should suggest databases or tables for "SELECT * FROM tes|"', () => {
    assertAutoComplete({
      beforeCursor: 'SELECT * FROM tes',
      afterCursor: '',
      expectedResult: {
        lowerCase: false,
        suggestTables: {},
        suggestDatabases: {
          appendDot: true
        }
      }
    });
  });

  it('should suggest databases or tables for "SELECT * FROM `tes|"', () => {
    assertAutoComplete({
      beforeCursor: 'SELECT * FROM `tes',
      afterCursor: '',
      expectedResult: {
        lowerCase: false,
        suggestTables: {},
        suggestDatabases: {
          appendDot: true
        }
      }
    });
  });

  it('should suggest tables for "SELECT * FROM database_two.|"', () => {
    assertAutoComplete({
      beforeCursor: 'SELECT * FROM database_two.',
      afterCursor: '',
      expectedResult: {
        lowerCase: false,
        suggestTables: { identifierChain: [{ name: 'database_two' }] }
      }
    });
  });

  it('should suggest tables for "SELECT * FROM `database_two`.|"', () => {
    assertAutoComplete({
      beforeCursor: 'SELECT * FROM `database_two`.',
      afterCursor: '',
      expectedResult: {
        lowerCase: false,
        suggestTables: { identifierChain: [{ name: 'database_two' }] }
      }
    });
  });

  it('should suggest tables for "SELECT * FROM 33abc.|"', () => {
    assertAutoComplete({
      beforeCursor: 'SELECT * FROM 33abc.',
      afterCursor: '',
      expectedResult: {
        lowerCase: false,
        suggestTables: { identifierChain: [{ name: '33abc' }] }
      }
    });
  });

  it('should suggest tables for "SELECT * FROM `database_two`.`bla |"', () => {
    assertAutoComplete({
      beforeCursor: 'SELECT * FROM `database_two`.`bla ',
      afterCursor: '',
      expectedResult: {
        lowerCase: false,
        suggestTables: { identifierChain: [{ name: 'database_two' }] }
      }
    });
  });

  it('should handle "SELECT 4 / 2; |"', () => {
    assertAutoComplete({
      beforeCursor: 'SELECT 4 / 2; ',
      afterCursor: '',
      noErrors: true,
      containsKeywords: ['SELECT'],
      expectedResult: {
        lowerCase: false
      }
    });
  });
});
