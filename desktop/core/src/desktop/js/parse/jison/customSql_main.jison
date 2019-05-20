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

SqlSyntax
 : NewStatement SqlStatements EOF
 ;

SqlAutocomplete
 : NewStatement SqlStatements EOF
   {
     return parser.yy.result;
   }
 | NewStatement SqlStatements_EDIT EOF
   {
     return parser.yy.result;
   }
 ;

NewStatement
 : /* empty */
   {
     parser.prepareNewStatement();
   }
 ;

SqlStatements
 :
 | SqlStatement
   {
     parser.addStatementLocation(@1);
   }
 | SqlStatements ';' NewStatement SqlStatements
 ;

SqlStatements_EDIT
 : SqlStatement_EDIT
   {
     parser.addStatementLocation(@1);
   }
 | SqlStatement_EDIT ';' NewStatement SqlStatements
   {
     parser.addStatementLocation(@1);
   }
 | SqlStatements ';' NewStatement SqlStatement_EDIT
   {
     parser.addStatementLocation(@4);
   }
 | SqlStatements ';' NewStatement SqlStatement_EDIT ';' NewStatement SqlStatements
   {
     parser.addStatementLocation(@4);
   }
 ;

SqlStatement
 : QuerySpecification
 ;

SqlStatement_EDIT
 : AnyCursor
   {
     parser.suggestKeywords(['SELECT']);
   }
 | QuerySpecification_EDIT
 ;

RegularIdentifier
 : 'REGULAR_IDENTIFIER'
 | NonReservedKeyword
 ;

// This is a work-around for error handling when a statement starts with some token that the parser can understand but
// it's not a valid statement (see ErrorStatement). It contains everything except valid starting tokens ('SELECT', 'USE' etc.)
NonStartingToken
 : '!'
 | '('
 | ')'
 | '*'
 | ','
 | '-'
 | '.'
 | '<'
 | '='
 | '>'
 | '['
 | ']'
 | '~'
 | 'AND'
 | 'ARITHMETIC_OPERATOR'
 | 'OR'
 | 'WHERE'
 ;

// ===================================== Commonly used constructs =====================================

Commas
 : ','
 | Commas ','
 ;

AnyCursor
 : 'CURSOR'
 | 'PARTIAL_CURSOR'
 ;

SingleQuotedValue
 : 'SINGLE_QUOTE' 'VALUE' 'SINGLE_QUOTE'  -> $2
 | 'SINGLE_QUOTE' 'SINGLE_QUOTE'          -> ''
 ;

SingleQuotedValue_EDIT
 : 'SINGLE_QUOTE' 'PARTIAL_VALUE'
 ;

DoubleQuotedValue
 : 'DOUBLE_QUOTE' 'VALUE' 'DOUBLE_QUOTE'  -> $2
 | 'DOUBLE_QUOTE' 'DOUBLE_QUOTE'          -> ''
 ;

DoubleQuotedValue_EDIT
 : 'DOUBLE_QUOTE' 'PARTIAL_VALUE'
 ;

QuotedValue
 : SingleQuotedValue
 | DoubleQuotedValue
 ;

QuotedValue_EDIT
 : SingleQuotedValue_EDIT
 | DoubleQuotedValue_EDIT
 ;

PartialBacktickedOrAnyCursor
 : AnyCursor
 | PartialBacktickedIdentifier
 ;

PartialBacktickedOrCursor
 : 'CURSOR'
 | PartialBacktickedIdentifier
 ;

PartialBacktickedOrPartialCursor
 : 'PARTIAL_CURSOR'
 | PartialBacktickedIdentifier
 ;

PartialBacktickedIdentifier
 : 'BACKTICK' 'PARTIAL_VALUE'
 ;

RightParenthesisOrError
 : ')'
 | error
 ;

OptionalParenthesizedColumnList
 :
 | ParenthesizedColumnList
 ;

OptionalParenthesizedColumnList_EDIT
 : ParenthesizedColumnList_EDIT
 ;

ParenthesizedColumnList
 : '(' ColumnList ')'
 ;

ParenthesizedColumnList_EDIT
 : '(' ColumnList_EDIT RightParenthesisOrError
 | '(' AnyCursor RightParenthesisOrError
   {
     parser.suggestColumns();
   }
 ;

ColumnList
 : ColumnIdentifier
 | ColumnList ',' ColumnIdentifier
 ;

ColumnList_EDIT
 : ColumnIdentifier_EDIT
 | ColumnList ',' AnyCursor
   {
     parser.suggestColumns();
   }
 | ColumnList ',' ColumnIdentifier_EDIT
 | ColumnIdentifier_EDIT ',' ColumnList
 | ColumnList ',' ColumnIdentifier_EDIT ',' ColumnList
 | ColumnList ',' AnyCursor ',' ColumnList
   {
     parser.suggestColumns();
   }
 ;

ParenthesizedSimpleValueList
 : '(' SimpleValueList ')'
 ;

SimpleValueList
 : UnsignedValueSpecification
 | SimpleValueList ',' UnsignedValueSpecification
 ;

SchemaQualifiedTableIdentifier
 : RegularOrBacktickedIdentifier
   {
     parser.addTableLocation(@1, [ { name: $1 } ]);
     $$ = { identifierChain: [ { name: $1 } ] };
   }
 | RegularOrBacktickedIdentifier AnyDot RegularOrBacktickedIdentifier
   {
     parser.addDatabaseLocation(@1, [ { name: $1 } ]);
     parser.addTableLocation(@3, [ { name: $1 }, { name: $3 } ]);
     $$ = { identifierChain: [ { name: $1 }, { name: $3 } ] };
   }
 | RegularOrBacktickedIdentifier AnyDot RegularOrBacktickedIdentifier ImpalaFields
   {
     // This is a special case for Impala expression like "SELECT | FROM db.table.col"
     $$ = { identifierChain: [ { name: $1 }, { name: $3 } ].concat($4) };
   }
 ;

SchemaQualifiedTableIdentifier_EDIT
 : PartialBacktickedIdentifier
   {
     parser.suggestTables();
     parser.suggestDatabases({ appendDot: true });
   }
 | PartialBacktickedIdentifier AnyDot RegularOrBacktickedIdentifier
   {
     parser.suggestDatabases();
     $$ = { identifierChain: [{ name: $1 }] };
   }
 | RegularOrBacktickedIdentifier AnyDot PartialBacktickedOrPartialCursor
   {
     // In Impala you can have statements like 'SELECT ... FROM testTable t, t.|'
     parser.suggestTablesOrColumns($1);
   }
 | RegularOrBacktickedIdentifier AnyDot RegularOrBacktickedIdentifier ImpalaFields_EDIT
   {
     // TODO: switch to suggestColumns, it's currently handled in sqlAutocompleter2.js
     // Issue is that suggestColumns is deleted if no tables are defined and this is
     // Impala only cases like "SELECT | FROM db.table.col"
     parser.suggestTables({ identifierChain: [{ name: $1 }, { name: $3 }].concat($4) });
   }
 ;

SchemaQualifiedIdentifier
 : RegularOrBacktickedIdentifier                                       -> [{ name: $1 }]
 | RegularOrBacktickedIdentifier AnyDot RegularOrBacktickedIdentifier  -> [{ name: $1 }, { name: $2 }]
 ;

SchemaQualifiedIdentifier_EDIT
 : PartialBacktickedIdentifier
   {
     parser.suggestDatabases({ appendDot: true });
   }
 | PartialBacktickedIdentifier AnyDot RegularOrBacktickedIdentifier
   {
     parser.suggestDatabases();
     $$ = { identifierChain: [{ name: $1 }] };
   }
 | RegularOrBacktickedIdentifier AnyDot PartialBacktickedOrPartialCursor
 ;

DatabaseIdentifier
 : RegularOrBacktickedIdentifier
 ;

DatabaseIdentifier_EDIT
 : PartialBacktickedOrCursor
   {
     parser.suggestDatabases();
   }
 ;

RegularOrBacktickedIdentifier
 : RegularIdentifier
 | 'BACKTICK' 'VALUE' 'BACKTICK'  -> $2
 | 'BACKTICK' 'BACKTICK'          -> ''
 ;

// TODO: Same as SchemaQualifiedTableIdentifier?
RegularOrBackTickedSchemaQualifiedName
 : RegularOrBacktickedIdentifier
   {
     parser.addTableLocation(@1, [ { name: $1 } ]);
     $$ = { identifierChain: [ { name: $1 } ] };
   }
 | RegularOrBacktickedIdentifier AnyDot RegularOrBacktickedIdentifier
   {
     parser.addDatabaseLocation(@1, [ { name: $1 } ]);
     parser.addTableLocation(@3, [ { name: $1 }, { name: $3 } ]);
     $$ = { identifierChain: [ { name: $1 }, { name: $3 } ] };
   }
 ;

RegularOrBackTickedSchemaQualifiedName_EDIT
 : PartialBacktickedIdentifier
   {
     parser.suggestTables();
     parser.suggestDatabases({ prependDot: true });
   }
 | RegularOrBacktickedIdentifier AnyDot PartialBacktickedOrPartialCursor
   {
     parser.suggestTablesOrColumns($1);
   }
 ;

LocalOrSchemaQualifiedName
 : RegularOrBackTickedSchemaQualifiedName
 | RegularOrBackTickedSchemaQualifiedName RegularOrBacktickedIdentifier  -> { identifierChain: $1.identifierChain, alias: $2 }
 ;

LocalOrSchemaQualifiedName_EDIT
 : RegularOrBackTickedSchemaQualifiedName_EDIT
 | RegularOrBackTickedSchemaQualifiedName_EDIT RegularOrBacktickedIdentifier
 ;

ColumnReference
 : BasicIdentifierChain
   {
     parser.yy.locations[parser.yy.locations.length - 1].type = 'column';
   }
 | BasicIdentifierChain AnyDot '*'
   {
     parser.addAsteriskLocation(@3, $1.concat({ asterisk: true }));
   }
 ;

ColumnReference_EDIT
 : BasicIdentifierChain_EDIT
 ;

BasicIdentifierChain
 : ColumnIdentifier
   {
     $$ = [ $1.identifier ];
     parser.yy.firstChainLocation = parser.addUnknownLocation($1.location, [ $1.identifier ]);
   }
 | BasicIdentifierChain AnyDot ColumnIdentifier
   {
     if (parser.yy.firstChainLocation) {
       parser.yy.firstChainLocation.firstInChain = true;
       delete parser.yy.firstChainLocation;
     }
     $1.push($3.identifier);
     parser.addUnknownLocation($3.location, $1.concat());
   }
 ;

// TODO: Merge with DerivedColumnChain_EDIT ( issue is starting with PartialBacktickedOrPartialCursor)
BasicIdentifierChain_EDIT
 : ColumnIdentifier_EDIT
   {
     if ($1.insideKey) {
       parser.suggestKeyValues({ identifierChain: [ $1.identifier ] });
       parser.suggestColumns();
       parser.suggestFunctions();
     }
   }
 | BasicIdentifierChain AnyDot ColumnIdentifier_EDIT
   {
     if ($3.insideKey) {
       parser.suggestKeyValues({ identifierChain: $1.concat([ $3.identifier ]) });
       parser.suggestColumns();
       parser.suggestFunctions();
     }
   }
 | BasicIdentifierChain AnyDot ColumnIdentifier_EDIT AnyDot BasicIdentifierChain
 | ColumnIdentifier_EDIT AnyDot BasicIdentifierChain
 | BasicIdentifierChain AnyDot PartialBacktickedOrPartialCursor
   {
     parser.suggestColumns({
       identifierChain: $1
     });
     $$ = { suggestKeywords: [{ value: '*', weight: 10000 }] };
   }
 | BasicIdentifierChain AnyDot PartialBacktickedOrPartialCursor AnyDot BasicIdentifierChain
   {
     parser.suggestColumns({
       identifierChain: $1
     });
     $$ = { suggestKeywords: [{ value: '*', weight: 10000 }] };
   }
 ;

DerivedColumnChain
 : ColumnIdentifier  -> [ $1.identifier ]
 | DerivedColumnChain AnyDot ColumnIdentifier
   {
     $1.push($3.identifier);
   }
 ;

DerivedColumnChain_EDIT
 : ColumnIdentifier_EDIT
   {
     if ($1.insideKey) {
       parser.suggestKeyValues({ identifierChain: [ $1.identifier ] });
       parser.suggestColumns();
       parser.suggestFunctions();
     }
   }
 | DerivedColumnChain AnyDot ColumnIdentifier_EDIT
   {
     if ($3.insideKey) {
       parser.suggestKeyValues({ identifierChain: $1.concat([ $3.identifier ]) });
       parser.suggestColumns();
       parser.suggestFunctions();
     }
   }
 | DerivedColumnChain AnyDot ColumnIdentifier_EDIT AnyDot DerivedColumnChain
   {
     if ($3.insideKey) {
       parser.suggestKeyValues({ identifierChain: $1.concat([ $3.identifier ]) });
       parser.suggestColumns();
       parser.suggestFunctions();
     }
   }
 | ColumnIdentifier_EDIT AnyDot DerivedColumnChain
   {
     if ($1.insideKey) {
       parser.suggestKeyValues({ identifierChain: [ $1.identifier ] });
       parser.suggestColumns();
       parser.suggestFunctions();
     }
   }
 | PartialBacktickedIdentifierOrPartialCursor
   {
     parser.suggestColumns();
   }
 | DerivedColumnChain AnyDot PartialBacktickedIdentifierOrPartialCursor
   {
     parser.suggestColumns({ identifierChain: $1 });
   }
 | DerivedColumnChain AnyDot PartialBacktickedIdentifierOrPartialCursor AnyDot DerivedColumnChain
   {
     parser.suggestColumns({ identifierChain: $1 });
   }
 | PartialBacktickedIdentifierOrPartialCursor AnyDot DerivedColumnChain
   {
     parser.suggestColumns();
   }
 ;

ColumnIdentifier
 : RegularOrBacktickedIdentifier                                                                               -> { identifier: { name: $1 }, location: @1 };
 | RegularOrBacktickedIdentifier HiveOrImpalaLeftSquareBracket ValueExpression HiveOrImpalaRightSquareBracket  -> { identifier: { name: $1, keySet: true }, location: @1 }
 | RegularOrBacktickedIdentifier HiveOrImpalaLeftSquareBracket HiveOrImpalaRightSquareBracket                  -> { identifier: { name: $1, keySet: true }, location: @1 }
 ;

ColumnIdentifier_EDIT
 : RegularOrBacktickedIdentifier HiveOrImpalaLeftSquareBracket AnyCursor HiveOrImpalaRightSquareBracketOrError             -> { identifier: { name: $1 }, insideKey: true }
 | RegularOrBacktickedIdentifier HiveOrImpalaLeftSquareBracket ValueExpression_EDIT HiveOrImpalaRightSquareBracketOrError  -> { identifier: { name: $1 }};
 ;

PartialBacktickedIdentifierOrPartialCursor
 : PartialBacktickedIdentifier
 | 'PARTIAL_CURSOR'
 ;

OptionalTypeLength
 :
 | '(' 'UNSIGNED_INTEGER' ')'
 ;

OptionalTypePrecision
 :
 | '(' 'UNSIGNED_INTEGER' ')'
 | '(' 'UNSIGNED_INTEGER' ',' 'UNSIGNED_INTEGER' ')'
 ;

// ===================================== SELECT statement =====================================

QuerySpecification
 : SelectStatement
 ;

QuerySpecification_EDIT
 : SelectStatement_EDIT
 ;

SelectStatement
 : 'SELECT' SelectList
   {
     parser.addClauseLocation('selectList', parser.firstDefined($1, @1), @2);
     $$ = { selectList: $2 };
   }
 | 'SELECT' SelectList TableExpression
   {
     parser.addClauseLocation('selectList', parser.firstDefined($1, @1), @2);
     $$ = { selectList: $2, tableExpression: $3 }
   }
 ;

SelectStatement_EDIT
 : 'SELECT' SelectList_EDIT
   {
     parser.addClauseLocation('selectList', parser.firstDefined($1, @1), @4);
     if ($2.cursorAtStart) {
       var keywords = parser.getSelectListKeywords();
       parser.suggestKeywords(keywords);
     } else {
       parser.checkForSelectListKeywords($2);
     }
     if ($2.suggestFunctions) {
       parser.suggestFunctions();
     }
     if ($2.suggestColumns) {
       parser.suggestColumns({ identifierChain: [], source: 'select' });
     }
     if ($2.suggestTables) {
       parser.suggestTables({ prependQuestionMark: true, prependFrom: true });
     }
     if ($2.suggestDatabases) {
       parser.suggestDatabases({ prependQuestionMark: true, prependFrom: true, appendDot: true });
     }
     if ($2.suggestAggregateFunctions) {
       parser.suggestAggregateFunctions();
       parser.suggestAnalyticFunctions();
     }
   }
 | 'SELECT' 'CURSOR'
   {
     parser.addClauseLocation('selectList', parser.firstDefined($1, @1), @2, true);
     var keywords = parser.getSelectListKeywords();
     parser.suggestKeywords(keywords);
     parser.suggestFunctions();
     parser.suggestColumns({ identifierChain: [], source: 'select' });
     parser.suggestTables({ prependQuestionMark: true, prependFrom: true });
     parser.suggestDatabases({ prependQuestionMark: true, prependFrom: true, appendDot: true });
   }
 | 'SELECT' SelectList TableExpression_EDIT
   {
     parser.addClauseLocation('selectList', parser.firstDefined($1, @1), @2);
   }
 | 'SELECT' SelectList_EDIT TableExpression
   {
     parser.addClauseLocation('selectList', parser.firstDefined($1, @1), @2);
     if (parser.yy.result.suggestColumns) {
       parser.yy.result.suggestColumns.source = 'select';
     }
   }
 | 'SELECT' 'CURSOR' TableExpression
   {
     parser.addClauseLocation('selectList', parser.firstDefined($1, @1), @2, true);
     var keywords = parser.getSelectListKeywords();
     parser.suggestKeywords(keywords);
     parser.suggestFunctions();
     parser.suggestColumns({ identifierChain: [], source: 'select' });
     parser.suggestTables({ prependQuestionMark: true, prependFrom: true });
     parser.suggestDatabases({ prependQuestionMark: true, prependFrom: true, appendDot: true });
   }
 | 'SELECT' SelectList 'CURSOR' TableExpression
   {
     parser.addClauseLocation('selectList', parser.firstDefined($1, @1), @2);
     parser.checkForSelectListKeywords($2);
   }
 | 'SELECT' SelectList 'CURSOR' ',' TableExpression
   {
     parser.addClauseLocation('selectList', parser.firstDefined($1, @1), @22);
     parser.checkForSelectListKeywords($2);
   }
 | 'SELECT' SelectList 'CURSOR'
   {
     parser.addClauseLocation('selectList', parser.firstDefined($1, @1), @2);
     parser.checkForSelectListKeywords($2);
     var keywords = ['FROM'];
     if (parser.yy.result.suggestKeywords) {
       keywords = parser.yy.result.suggestKeywords.concat(keywords);
     }
     parser.suggestKeywords(keywords);
     parser.suggestTables({ prependFrom: true });
     parser.suggestDatabases({ prependFrom: true, appendDot: true });
   }
 ;

TableExpression
 : FromClause OptionalSelectConditions
   {
     parser.addClauseLocation('whereClause', @1, $2.whereClauseLocation);
     parser.addClauseLocation('limitClause', $2.limitClausePreceding || @1, $2.limitClauseLocation);
   }
 ;

TableExpression_EDIT
 : FromClause_EDIT OptionalSelectConditions
   {
     parser.addClauseLocation('whereClause', @1, $2.whereClauseLocation);
   }
 | FromClause 'CURSOR' OptionalSelectConditions
   {
     var keywords = [];

     parser.addClauseLocation('whereClause', @1, $3.whereClauseLocation);

     if ($1) {
       if ($1.suggestKeywords) {
         keywords = parser.createWeightedKeywords($1.suggestKeywords, 3);
       }

       if ($1.tableReferenceList.types) {
         var veKeywords = parser.getValueExpressionKeywords($1.tableReferenceList);
         keywords = keywords.concat(veKeywords.suggestKeywords);
         if (veKeywords.suggestColRefKeywords) {
           parser.suggestColRefKeywords(veKeywords.suggestColRefKeywords);
           parser.addColRefIfExists($1.tableReferenceList);
         }
       }
     }

     if ($3.suggestKeywords) {
       keywords = keywords.concat(parser.createWeightedKeywords($3.suggestKeywords, 2));
     }

     if ($3.suggestFilters) {
       parser.suggestFilters($3.suggestFilters);
     }

     parser.suggestKeywords(keywords);
  }
 | FromClause OptionalSelectConditions_EDIT
   {
     if (!$2) {
       parser.addClauseLocation('whereClause', @1);
       return;
     }
     parser.addClauseLocation('whereClause', @1, $2.whereClauseLocation);
     var keywords = [];

     if ($2.suggestColRefKeywords) {
       parser.suggestColRefKeywords($2.suggestColRefKeywords);
       parser.addColRefIfExists($2);
     }

     if ($2.suggestKeywords && $2.suggestKeywords.length) {
       keywords = keywords.concat(parser.createWeightedKeywords($2.suggestKeywords, 2));
     }

     parser.suggestKeywords(keywords);
   }
 ;


FromClause
 : 'FROM' TableReferenceList
   {
     $$ = { tableReferenceList : $2 }
   }
 ;

FromClause_EDIT
 : 'FROM' 'CURSOR'
   {
     parser.suggestTables();
     parser.suggestDatabases({ appendDot: true });
   }
 | 'FROM' TableReferenceList_EDIT
 ;

OptionalSelectConditions
 : OptionalWhereClause
   {
     var keywords = parser.getKeywordsForOptionalsLR(
       [$1],
       [{ value: 'WHERE', weight: 1 }],
       [true]);

     if (keywords.length > 0) {
       $$ = { suggestKeywords: keywords, empty: !$1 };
     } else {
       $$ = {};
     }

     $$.whereClauseLocation = $1 ? @1 : undefined;

     if (!$1) {
       $$.suggestFilters = { prefix: 'WHERE', tablePrimaries: parser.yy.latestTablePrimaries.concat() };
     }
   }
 ;

OptionalSelectConditions_EDIT
 : WhereClause_EDIT
   {
     if (parser.yy.result.suggestColumns) {
       parser.yy.result.suggestColumns.source = 'where';
     }
   }
 | WhereClause 'CURSOR'
   {
     var keywords = [];
     if ($1.suggestKeywords) {
       keywords = keywords.concat(parser.createWeightedKeywords($1.suggestKeywords, 1));
     }
     $$ = parser.getValueExpressionKeywords($1, keywords);
     $$.cursorAtEnd = true;
     if ($1.columnReference) {
       $$.columnReference = $1.columnReference;
     }
     $$.whereClauseLocation = $1 ? @1 : undefined;
   }
 ;

OptionalWhereClause
 :
 | WhereClause
 ;

WhereClause
 : 'WHERE' SearchCondition  -> $2
 ;

WhereClause_EDIT
 : 'WHERE' SearchCondition_EDIT
   {
     if ($2.suggestFilters) {
       parser.suggestFilters({ tablePrimaries: parser.yy.latestTablePrimaries.concat() });
     }
   }
 | 'WHERE' 'CURSOR'
   {
     parser.suggestFunctions();
     parser.suggestColumns();
     parser.suggestKeywords(['EXISTS', 'NOT EXISTS']);
     parser.suggestFilters({ tablePrimaries: parser.yy.latestTablePrimaries.concat() });
   }
 ;

SearchCondition
 : ValueExpression
 ;

SearchCondition_EDIT
 : ValueExpression_EDIT
 ;

ValueExpression
 : NonParenthesizedValueExpressionPrimary
 ;

ValueExpression_EDIT
 : NonParenthesizedValueExpressionPrimary_EDIT
 ;

ValueExpression_EDIT
 : ValueExpression 'NOT' 'CURSOR'
   {
     if (parser.isImpala()) {
       parser.suggestKeywords(['BETWEEN', 'EXISTS', 'IN', 'ILIKE', 'IREGEXP', 'LIKE', 'REGEXP', 'RLIKE']);
     } else {
       parser.suggestKeywords(['BETWEEN', 'EXISTS', 'IN', 'LIKE', 'REGEXP', 'RLIKE']);
     }
     $$ = { types: [ 'BOOLEAN' ] };
   }
 ;

ValueExpressionList
 : ValueExpression
   {
     $1.position = 1;
   }
 | ValueExpressionList ',' ValueExpression
   {
     $3.position = $1.position + 1;
     $$ = $3;
   }
 ;

ValueExpressionList_EDIT
 : ValueExpression_EDIT
   {
     $1.position = 1;
   }
 | ValueExpressionList ',' ValueExpression_EDIT
   {
     $1.position += 1;
   }
 | ValueExpression_EDIT ',' ValueExpressionList
   {
     $1.position = 1;
   }
 | ValueExpressionList ',' ValueExpression_EDIT ',' ValueExpressionList
   {
     $1.position += 1;
   }
 | ValueExpressionList ',' AnyCursor
   {
     parser.valueExpressionSuggest();
     $1.position += 1;
   }
 | ValueExpressionList ',' AnyCursor ',' ValueExpressionList
   {
     parser.valueExpressionSuggest();
     $1.position += 1;
   }
 | ValueExpressionList 'CURSOR' ',' ValueExpressionList
   {
     parser.suggestValueExpressionKeywords($1);
   }
 | AnyCursor ',' ValueExpressionList
   {
     parser.valueExpressionSuggest();
     $$ = { cursorAtStart : true, position: 1 };
   }
 | AnyCursor ','
   {
     parser.valueExpressionSuggest();
     $$ = { cursorAtStart : true, position: 1 };
   }
 | ',' AnyCursor
   {
     parser.valueExpressionSuggest();
     $$ = { position: 2 };
   }
 | ',' AnyCursor ',' ValueExpressionList
   {
     parser.valueExpressionSuggest();
     $$ = { position: 2 };
   }
 ;

NonParenthesizedValueExpressionPrimary
 : UnsignedValueSpecification
 | ColumnOrArbitraryFunctionRef             -> { types: ['COLREF'], columnReference: $1.chain }
 | ColumnOrArbitraryFunctionRef ArbitraryFunctionRightPart
   {
     // We need to handle arbitrary UDFs here instead of inside UserDefinedFunction or there will be a conflict
     // with columnReference for functions like: db.udf(foo)
     var fn = $1.chain[$1.chain.length - 1].name.toLowerCase();
     $1.lastLoc.type = 'function';
     $1.lastLoc.function = fn;
     $1.lastLoc.location = {
       first_line: $1.lastLoc.location.first_line,
       last_line: $1.lastLoc.location.last_line,
       first_column: $1.lastLoc.location.first_column,
       last_column: $1.lastLoc.location.last_column - 1
     }
     if ($1.lastLoc !== $1.firstLoc) {
        $1.firstLoc.type = 'database';
     } else {
       delete $1.lastLoc.identifierChain;
     }
     if ($2.expression) {
       $$ = { function: fn, expression: $2.expression, types: parser.findReturnTypes(fn) }
     } else {
       $$ = { function: fn, types: parser.findReturnTypes(fn) }
     }
   }
 | ArbitraryFunctionName ArbitraryFunctionRightPart
  {
    parser.addFunctionLocation(@1, $1);
    if ($2.expression) {
      $$ = { function: $1, expression: $2.expression, types: parser.findReturnTypes($1) }
    } else {
      $$ = { function: $1, types: parser.findReturnTypes($1) }
    }
  }
 | UserDefinedFunction
 | 'NULL'                      -> { types: [ 'NULL' ] }
 ;

NonParenthesizedValueExpressionPrimary_EDIT
 : UnsignedValueSpecification_EDIT
 | ColumnOrArbitraryFunctionRef_EDIT
   {
     if ($1.suggestKeywords) {
       $$ = { types: ['COLREF'], columnReference: $1, suggestKeywords: $1.suggestKeywords };
     } else {
       $$ = { types: ['COLREF'], columnReference: $1 };
     }
   }
 | ColumnOrArbitraryFunctionRef ArbitraryFunctionRightPart_EDIT
   {
     var fn = $1.chain[$1.chain.length - 1].name.toLowerCase();
     $1.lastLoc.type = 'function';
     $1.lastLoc.function = fn;
     $1.lastLoc.location = {
       first_line: $1.lastLoc.location.first_line,
       last_line: $1.lastLoc.location.last_line,
       first_column: $1.lastLoc.location.first_column,
       last_column: $1.lastLoc.location.last_column - 1
     }
     if ($1.lastLoc !== $1.firstLoc) {
        $1.firstLoc.type = 'database';
     } else {
       delete $1.lastLoc.identifierChain;
     }
     if ($2.position) {
       parser.applyArgumentTypesToSuggestions(fn, $2.position);
     }
     $$ = { types: parser.findReturnTypes(fn) };
   }
 | ArbitraryFunctionName ArbitraryFunctionRightPart_EDIT
   {
     parser.addFunctionLocation(@1, $1);
     if ($2.position) {
       parser.applyArgumentTypesToSuggestions($1, $2.position);
     }
     $$ = { types: parser.findReturnTypes($1) };
   }
 | UserDefinedFunction_EDIT
 ;

ColumnOrArbitraryFunctionRef
 : BasicIdentifierChain
   {
     var lastLoc = parser.yy.locations[parser.yy.locations.length - 1];
     if (lastLoc.type !== 'variable') {
       lastLoc.type = 'column';
     }
     // used for function references with db prefix
     var firstLoc = parser.yy.locations[parser.yy.locations.length - $1.length];
     $$ = { chain: $1, firstLoc: firstLoc, lastLoc: lastLoc }
   }
 | BasicIdentifierChain AnyDot '*'
   {
     parser.addAsteriskLocation(@3, $1.concat({ asterisk: true }));
   }
 ;

ColumnOrArbitraryFunctionRef_EDIT
 : BasicIdentifierChain_EDIT
 ;

SignedInteger
 : UnsignedNumericLiteral
 | '-' UnsignedNumericLiteral
 | '+' UnsignedNumericLiteral
 ;

UnsignedValueSpecification
 : UnsignedLiteral
 ;

UnsignedValueSpecification_EDIT
 : UnsignedLiteral_EDIT
   {
     parser.suggestValues($1);
   }
 ;

UnsignedLiteral
 : UnsignedNumericLiteral  -> { types: [ 'NUMBER' ] }
 | GeneralLiteral
 ;

UnsignedLiteral_EDIT
 : GeneralLiteral_EDIT
 ;

UnsignedNumericLiteral
 : ExactNumericLiteral
 | ApproximateNumericLiteral
 ;

ExactNumericLiteral
 : 'UNSIGNED_INTEGER'
 | 'UNSIGNED_INTEGER' AnyDot                     -> $1 + $2
 | 'UNSIGNED_INTEGER' AnyDot 'UNSIGNED_INTEGER'  -> $1 + $2 + $3
 | AnyDot 'UNSIGNED_INTEGER'                     -> $1 + $2
 ;

ApproximateNumericLiteral
 : UNSIGNED_INTEGER_E 'UNSIGNED_INTEGER'
 | AnyDot UNSIGNED_INTEGER_E 'UNSIGNED_INTEGER'
 | 'UNSIGNED_INTEGER' AnyDot UNSIGNED_INTEGER_E 'UNSIGNED_INTEGER'
 ;

GeneralLiteral
 : SingleQuotedValue
   {
     $$ = { types: [ 'STRING' ] }
   }
 | DoubleQuotedValue
   {
     $$ = { types: [ 'STRING' ] }
   }
 | TruthValue         -> { types: [ 'BOOLEAN' ] }
 ;

GeneralLiteral_EDIT
 : SingleQuotedValue_EDIT
  {
    $$ = { partialQuote: '\'', missingEndQuote: parser.yy.missingEndQuote };
  }
 | DoubleQuotedValue_EDIT
  {
    $$ = { partialQuote: '"', missingEndQuote: parser.yy.missingEndQuote };
  }
 ;

TruthValue
 : 'TRUE'
 | 'FALSE'
 ;

OptionalNot
 :
 | 'NOT'
 ;

SelectSpecification
 : ValueExpression OptionalCorrelationName
   {
     if ($2) {
       parser.addColumnAliasLocation($2.location, $2.alias, @1);
       $$ = { valueExpression: $1, alias: $2.alias };
       if (!parser.yy.selectListAliases) {
         parser.yy.selectListAliases = [];
       }
       parser.yy.selectListAliases.push({ name: $2.alias, types: $1.types || ['T'] });
     } else {
       $$ = { valueExpression: $1 }
     }
   }
 | '*'
   {
     parser.addAsteriskLocation(@1, [{ asterisk: true }]);
     $$ = { asterisk: true }
   }
 ;

SelectSpecification_EDIT
 : ValueExpression_EDIT OptionalCorrelationName
   {
     if ($2) {
       parser.addColumnAliasLocation($2.location, $2.alias, @1);
     }
   }

 | AnyCursor AnyAs RegularOrBacktickedIdentifier
   {
     parser.suggestFunctions();
     parser.suggestColumns();
     parser.addColumnAliasLocation(@3, $3, @1);
     $$ = { suggestAggregateFunctions: true };
   }
 | ValueExpression OptionalCorrelationName_EDIT  -> $2
 ;

SelectList
 : SelectSpecification                 -> [ $1 ]
 | SelectList ',' SelectSpecification
   {
     $1.push($3);
   }
 ;

SelectList_EDIT
 : SelectSpecification_EDIT
 | 'CURSOR' SelectList
   {
     $$ = { cursorAtStart : true, suggestFunctions: true, suggestColumns: true, suggestAggregateFunctions: true };
   }
 | 'CURSOR' ',' SelectList
   {
     $$ = { cursorAtStart : true, suggestFunctions: true, suggestColumns: true, suggestAggregateFunctions: true };
   }
 | SelectSpecification_EDIT ',' SelectList
 | SelectList 'CURSOR' SelectList
   {
     parser.checkForSelectListKeywords($1);
   }
 | SelectList 'CURSOR' ',' SelectList
   {
     parser.checkForSelectListKeywords($1);
   }
 | SelectList ',' AnyCursor
   {
     $$ = { suggestKeywords: parser.getSelectListKeywords(), suggestTables: true, suggestDatabases: true, suggestFunctions: true, suggestColumns: true, suggestAggregateFunctions: true };
   }
 | SelectList ',' SelectSpecification_EDIT                 -> $3
 | SelectList ',' AnyCursor SelectList
   {
     $$ = { suggestKeywords: parser.getSelectListKeywords(), suggestFunctions: true, suggestColumns: true, suggestAggregateFunctions: true,  };
   }
 | SelectList ',' AnyCursor ','
   {
     $$ = { suggestKeywords: parser.getSelectListKeywords(), suggestFunctions: true, suggestColumns: true, suggestAggregateFunctions: true,  };
   }
 | SelectList ',' SelectSpecification_EDIT ','             -> $3
 | SelectList ',' AnyCursor ',' SelectList
   {
     $$ = { suggestKeywords: parser.getSelectListKeywords(), suggestFunctions: true, suggestColumns: true, suggestAggregateFunctions: true,  };
   }
 | SelectList ',' SelectSpecification_EDIT ',' SelectList  -> $3
 ;

TableReferenceList
 : TableReference
 | TableReferenceList ',' TableReference  -> $3
 ;

TableReferenceList_EDIT
 : TableReference_EDIT
 | TableReference_EDIT ',' TableReference
 | TableReferenceList ',' TableReference_EDIT
 | TableReferenceList ',' TableReference_EDIT ',' TableReferenceList
 | TableReferenceList ',' AnyCursor
   {
       parser.suggestTables();
       parser.suggestDatabases({ appendDot: true });
   }
 ;

TableReference
 : TablePrimary
   {
     $$ = $1;

     if (parser.yy.latestTablePrimaries.length > 0) {
       var idx = parser.yy.latestTablePrimaries.length - 1;
       var tables = [];
       do {
         var tablePrimary = parser.yy.latestTablePrimaries[idx];
         if (!tablePrimary.subQueryAlias) {
           tables.unshift(tablePrimary.alias ? { identifierChain: tablePrimary.identifierChain, alias: tablePrimary.alias } : { identifierChain: tablePrimary.identifierChain })
         }
         idx--;
       } while (idx >= 0 && tablePrimary.join && !tablePrimary.subQueryAlias)
     }
   }
 ;

TableReference_EDIT
 : TablePrimary_EDIT
 ;

TablePrimary
 : TableOrQueryName OptionalCorrelationName
   {
     $$ = {
       primary: $1
     }
     if ($1.identifierChain) {
       if ($2) {
         $1.alias = $2.alias
         parser.addTableAliasLocation($3.location, $2.alias, $1.identifierChain);
       }
       parser.addTablePrimary($1);
     }
     var keywords = [];

     keywords = parser.getKeywordsForOptionalsLR([$2], [{ value: 'AS', weight: 1 }], [true]);
     if (keywords.length > 0) {
       $$.suggestKeywords = keywords;
     }
   }
 ;

TablePrimary_EDIT
 : TableOrQueryName_EDIT OptionalCorrelationName
   {
     if ($2) {
       parser.addTableAliasLocation($3.location, $3.alias, $1.identifierChain);
     }
   }
 ;

TableOrQueryName
 : SchemaQualifiedTableIdentifier
 ;

TableOrQueryName_EDIT
 : SchemaQualifiedTableIdentifier_EDIT
 ;

OptionalCorrelationName
 :
 | RegularOrBacktickedIdentifier        -> { alias: $1, location: @1 }
 | QuotedValue                          -> { alias: $1, location: @1 }
 | 'AS' RegularOrBacktickedIdentifier   -> { alias: $2, location: @2 }
 | 'AS'  QuotedValue                    -> { alias: $2, location: @2 }
 ;

OptionalCorrelationName_EDIT
 : PartialBacktickedIdentifier
 | QuotedValue_EDIT
 | 'AS' PartialBacktickedIdentifier
 | 'AS' QuotedValue_EDIT
 | 'AS' 'CURSOR'
 ;

ArbitraryFunction
 : RegularIdentifier ArbitraryFunctionRightPart
   {
     parser.addFunctionLocation(@1, $1);
     if ($2.expression) {
       $$ = { function: $1, expression: $2.expression, types: parser.findReturnTypes($1) }
     } else {
       $$ = { function: $1, types: parser.findReturnTypes($1) }
     }
   }
 ;

ArbitraryFunction_EDIT
 : RegularIdentifier ArbitraryFunctionRightPart_EDIT
   {
     parser.addFunctionLocation(@1, $1);
     if ($2.position) {
       parser.applyArgumentTypesToSuggestions($1, $2.position);
     }
     $$ = { types: parser.findReturnTypes($1) };
   }
 ;

ArbitraryFunctionRightPart
 : '(' ')'
 | '(' ValueExpressionList ')'  -> { expression: $2 }
 ;

ArbitraryFunctionRightPart_EDIT
 : '(' AnyCursor RightParenthesisOrError
   {
     parser.valueExpressionSuggest();
     $$ = { position: 1 }
   }
 | '(' ValueExpressionList 'CURSOR' RightParenthesisOrError
   {
     parser.suggestValueExpressionKeywords($3);
   }
 | '(' ValueExpressionList_EDIT RightParenthesisOrError      -> $2
 ;
