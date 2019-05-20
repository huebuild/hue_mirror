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

ValueExpression
 : 'NOT' ValueExpression
   {
     // verifyType($2, 'BOOLEAN');
     $$ = { types: [ 'BOOLEAN' ] };
   }
 | '!' ValueExpression
   {
     // verifyType($2, 'BOOLEAN');
     $$ = { types: [ 'BOOLEAN' ] };
   }
 | '~' ValueExpression                                                 -> $2
 | '-' ValueExpression %prec NEGATION
   {
     // verifyType($2, 'NUMBER');
     $$ = $2;
     $2.types = ['NUMBER'];
   }
 | ValueExpression 'IS' OptionalNot 'NULL'                             -> { types: [ 'BOOLEAN' ] }
 | ValueExpression 'IS' OptionalNot 'TRUE'                             -> { types: [ 'BOOLEAN' ] }
 | ValueExpression 'IS' OptionalNot 'FALSE'                            -> { types: [ 'BOOLEAN' ] }
 ;

ValueExpression_EDIT
 : 'NOT' ValueExpression_EDIT                           -> { types: [ 'BOOLEAN' ], suggestFilters: $2.suggestFilters }
 | 'NOT' 'CURSOR'
   {
     parser.suggestFunctions();
     parser.suggestColumns();
     parser.suggestKeywords(['EXISTS']);
     $$ = { types: [ 'BOOLEAN' ] };
   }
 | '!' ValueExpression_EDIT                             -> { types: [ 'BOOLEAN' ], suggestFilters: $2.suggestFilters }
 | '!' AnyCursor
   {
     parser.suggestFunctions({ types: [ 'BOOLEAN' ] });
     parser.suggestColumns({ types: [ 'BOOLEAN' ] });
     $$ = { types: [ 'BOOLEAN' ] };
   }
 | '~' ValueExpression_EDIT                             -> { types: [ 'T' ], suggestFilters: $2.suggestFilters }
 | '~' 'PARTIAL_CURSOR'
   {
     parser.suggestFunctions();
     parser.suggestColumns();
     $$ = { types: [ 'T' ] };
   }
 | '-' ValueExpression_EDIT %prec NEGATION
   {
     if (!$2.typeSet) {
       parser.applyTypeToSuggestions('NUMBER');
     }
     $$ = { types: [ 'NUMBER' ], suggestFilters: $2.suggestFilters };
   }
 | '-' 'PARTIAL_CURSOR' %prec NEGATION
   {
     parser.suggestFunctions({ types: [ 'NUMBER' ] });
     parser.suggestColumns({ types: [ 'NUMBER' ] });
     $$ = { types: [ 'NUMBER' ] };
   }
 | ValueExpression 'IS' 'CURSOR'
   {
     var keywords = ['FALSE', 'NOT NULL', 'NOT TRUE', 'NOT FALSE', 'NULL', 'TRUE'];
     parser.suggestKeywords(keywords);
     $$ = { types: [ 'BOOLEAN' ] };
   }
 | ValueExpression 'IS' 'NOT' 'CURSOR'
   {
     var keywords = ['FALSE', 'NULL', 'TRUE'];
     parser.suggestKeywords(keywords);
     $$ = { types: [ 'BOOLEAN' ] };
   }
 | ValueExpression 'IS' 'CURSOR' 'NULL'
   {
     parser.suggestKeywords(['NOT']);
     $$ = { types: [ 'BOOLEAN' ] };
   }
 | ValueExpression 'IS' 'CURSOR' 'FALSE'
   {
     parser.suggestKeywords(['NOT']);
     $$ = { types: [ 'BOOLEAN' ] };
   }
 | ValueExpression 'IS' 'CURSOR' 'TRUE'
   {
     parser.suggestKeywords(['NOT']);
     $$ = { types: [ 'BOOLEAN' ] };
   }
 ;

ValueExpression
 : '(' ValueExpression ')'                                -> $2
 ;

ValueExpression_EDIT
 : '(' ValueExpression_EDIT RightParenthesisOrError
   {
     $$ = $2;
   }
 | '(' 'CURSOR' RightParenthesisOrError
   {
     parser.valueExpressionSuggest();
     $$ = { types: ['T'], typeSet: true };
   }
 ;

// ------------------  COMPARISON ------------------

ValueExpression
 : ValueExpression '=' ValueExpression
   {
     parser.addColRefToVariableIfExists($1, $3);
     $$ = { types: [ 'BOOLEAN' ] };
   }
 | ValueExpression '<' ValueExpression
   {
     parser.addColRefToVariableIfExists($1, $3);
     $$ = { types: [ 'BOOLEAN' ] };
   }
 | ValueExpression '>' ValueExpression
   {
     parser.addColRefToVariableIfExists($1, $3);
     $$ = { types: [ 'BOOLEAN' ] };
   }
 | ValueExpression 'COMPARISON_OPERATOR' ValueExpression
   {
     parser.addColRefToVariableIfExists($1, $3);
     $$ = { types: [ 'BOOLEAN' ] };
   }
 ;

ValueExpression_EDIT
 : 'CURSOR' '=' ValueExpression
   {
     parser.valueExpressionSuggest($3, $2);
     parser.applyTypeToSuggestions($3.types);
     $$ = { types: [ 'BOOLEAN' ], typeSet: true };
   }
 | 'CURSOR' '<' ValueExpression
   {
     parser.valueExpressionSuggest($3, $2);
     parser.applyTypeToSuggestions($3.types);
     $$ = { types: [ 'BOOLEAN' ], typeSet: true  };
   }
 | 'CURSOR' '>' ValueExpression
   {
     parser.valueExpressionSuggest($3, $2);
     parser.applyTypeToSuggestions($3.types);
     $$ = { types: [ 'BOOLEAN' ], typeSet: true  };
   }
 | 'CURSOR' 'COMPARISON_OPERATOR' ValueExpression
   {
     parser.valueExpressionSuggest($3, $2);
     parser.applyTypeToSuggestions($3.types);
     $$ = { types: [ 'BOOLEAN' ], typeSet: true  };
   }
 | ValueExpression_EDIT '=' ValueExpression
   {
     if (!$1.typeSet) {
       parser.applyTypeToSuggestions($3.types);
       parser.addColRefIfExists($3);
     }
     $$ = { types: [ 'BOOLEAN' ], suggestFilters: $1.suggestFilters }
   }
 | ValueExpression_EDIT '<' ValueExpression
   {
     if (!$1.typeSet) {
       parser.applyTypeToSuggestions($3.types);
       parser.addColRefIfExists($3);
     }
     $$ = { types: [ 'BOOLEAN' ], suggestFilters: $1.suggestFilters }
   }
 | ValueExpression_EDIT '>' ValueExpression
   {
     if (!$1.typeSet) {
       parser.applyTypeToSuggestions($3.types);
       parser.addColRefIfExists($3);
     }
     $$ = { types: [ 'BOOLEAN' ], suggestFilters: $1.suggestFilters }
   }
 | ValueExpression_EDIT 'COMPARISON_OPERATOR' ValueExpression
   {
     if (!$1.typeSet) {
       parser.applyTypeToSuggestions($3.types);
       parser.addColRefIfExists($3);
     }
     $$ = { types: [ 'BOOLEAN' ], suggestFilters: $1.suggestFilters }
   }
 | ValueExpression '=' PartialBacktickedOrAnyCursor
   {
     parser.valueExpressionSuggest($1, $2);
     parser.applyTypeToSuggestions($1.types);
     $$ = { types: [ 'BOOLEAN' ], typeSet: true  };
   }
 | ValueExpression '<' PartialBacktickedOrAnyCursor
   {
     parser.valueExpressionSuggest($1, $2);
     parser.applyTypeToSuggestions($1.types);
     $$ = { types: [ 'BOOLEAN' ] , typeSet: true, endsWithLessThanOrEqual: true };
   }
 | ValueExpression '>' PartialBacktickedOrAnyCursor
   {
     parser.valueExpressionSuggest($1, $2);
     parser.applyTypeToSuggestions($1.types);
     $$ = { types: [ 'BOOLEAN' ], typeSet: true  };
   }
 | ValueExpression 'COMPARISON_OPERATOR' PartialBacktickedOrAnyCursor
   {
     parser.valueExpressionSuggest($1, $2);
     parser.applyTypeToSuggestions($1.types);
     $$ = { types: [ 'BOOLEAN' ], typeSet: true, endsWithLessThanOrEqual: $2 === '<='  };
   }
 | ValueExpression '=' ValueExpression_EDIT
   {
     if (!$3.typeSet) {
       parser.applyTypeToSuggestions($1.types);
       parser.addColRefIfExists($1);
     }
     $$ = { types: [ 'BOOLEAN' ], suggestFilters: $3.suggestFilters }
   }
 | ValueExpression '<' ValueExpression_EDIT
   {
     if (!$3.typeSet) {
       parser.applyTypeToSuggestions($1.types);
       parser.addColRefIfExists($1);
     }
     $$ = { types: [ 'BOOLEAN' ], suggestFilters: $3.suggestFilters }
   }
 | ValueExpression '>' ValueExpression_EDIT
   {
     if (!$3.typeSet) {
       parser.applyTypeToSuggestions($1.types);
       parser.addColRefIfExists($1);
     }
     $$ = { types: [ 'BOOLEAN' ], suggestFilters: $3.suggestFilters }
   }
 | ValueExpression 'COMPARISON_OPERATOR' ValueExpression_EDIT
   {
     if (!$3.typeSet) {
       parser.applyTypeToSuggestions($1.types);
       parser.addColRefIfExists($1);
     }
     $$ = { types: [ 'BOOLEAN' ], suggestFilters: $3.suggestFilters }
   }
 ;

// ------------------  BOOLEAN ------------------

ValueExpression
 : ValueExpression 'OR' ValueExpression
   {
     $$ = { types: [ 'BOOLEAN' ] };
   }
 | ValueExpression 'AND' ValueExpression
   {
     $$ = { types: [ 'BOOLEAN' ] };
   }
 ;

ValueExpression_EDIT
 : 'CURSOR' 'OR' ValueExpression
   {
     parser.valueExpressionSuggest(undefined, $2);
     $$ = { types: [ 'BOOLEAN' ], typeSet: true, suggestFilters: true };
   }
 | ValueExpression_EDIT 'OR' ValueExpression
   {
     parser.addColRefIfExists($3);
     $$ = { types: [ 'BOOLEAN' ], suggestFilters: $1.suggestFilters }
   }
 | ValueExpression 'OR' PartialBacktickedOrAnyCursor
   {
     parser.valueExpressionSuggest(undefined, $2);
     $$ = { types: [ 'BOOLEAN' ], typeSet: true, suggestFilters: true };
   }
 | ValueExpression 'OR' ValueExpression_EDIT
   {
     parser.addColRefIfExists($1);
     $$ = { types: [ 'BOOLEAN' ], suggestFilters: $3.suggestFilters }
   }
 | 'CURSOR' 'AND' ValueExpression
   {
     parser.valueExpressionSuggest(undefined, $2);
     $$ = { types: [ 'BOOLEAN' ], typeSet: true, suggestFilters: true };
   }
 | ValueExpression_EDIT 'AND' ValueExpression
   {
     parser.addColRefIfExists($3);
     $$ = { types: [ 'BOOLEAN' ], suggestFilters: $1.suggestFilters }
   }
 | ValueExpression 'AND' PartialBacktickedOrAnyCursor
   {
     parser.valueExpressionSuggest(undefined, $2);
     $$ = { types: [ 'BOOLEAN' ], typeSet: true, suggestFilters: true };
   }
 | ValueExpression 'AND' ValueExpression_EDIT
   {
     parser.addColRefIfExists($1);
     $$ = { types: [ 'BOOLEAN' ], suggestFilters: $3.suggestFilters }
   }
 ;

// ------------------  ARITHMETIC ------------------

ValueExpression
 : ValueExpression '-' ValueExpression
   {
     // verifyType($1, 'NUMBER');
     // verifyType($3, 'NUMBER');
     $$ = { types: [ 'NUMBER' ] };
   }
 | ValueExpression '*' ValueExpression
   {
     // verifyType($1, 'NUMBER');
     // verifyType($3, 'NUMBER');
     $$ = { types: [ 'NUMBER' ] };
   }
 | ValueExpression 'ARITHMETIC_OPERATOR' ValueExpression
   {
     // verifyType($1, 'NUMBER');
     // verifyType($3, 'NUMBER');
     $$ = { types: [ 'NUMBER' ] };
   }
 ;

ValueExpression_EDIT
 : 'CURSOR' '*' ValueExpression
   {
     parser.valueExpressionSuggest(undefined, $2);
     parser.applyTypeToSuggestions([ 'NUMBER' ]);
     $$ = { types: [ 'NUMBER' ], typeSet: true };
   }
 | 'CURSOR' 'ARITHMETIC_OPERATOR' ValueExpression
   {
     parser.valueExpressionSuggest(undefined, $2);
     parser.applyTypeToSuggestions([ 'NUMBER' ]);
     $$ = { types: [ 'NUMBER' ], typeSet: true };
   }
 | ValueExpression_EDIT '-' ValueExpression
   {
     if (!$1.typeSet) {
       parser.applyTypeToSuggestions(['NUMBER']);
       parser.addColRefIfExists($3);
     }
     $$ = { types: [ 'NUMBER' ], suggestFilters: $1.suggestFilters }
   }
 | ValueExpression_EDIT '*' ValueExpression
   {
     if (!$1.typeSet) {
       parser.applyTypeToSuggestions(['NUMBER']);
       parser.addColRefIfExists($3);
     }
     $$ = { types: [ 'NUMBER' ], suggestFilters: $1.suggestFilters }
   }
 | ValueExpression_EDIT 'ARITHMETIC_OPERATOR' ValueExpression
   {
     if (!$1.typeSet) {
       parser.applyTypeToSuggestions(['NUMBER']);
       parser.addColRefIfExists($3);
     }
     $$ = { types: [ 'NUMBER' ], suggestFilters: $1.suggestFilters }
   }
 | ValueExpression '-' PartialBacktickedOrAnyCursor
   {
     parser.valueExpressionSuggest(undefined, $2);
     parser.applyTypeToSuggestions(['NUMBER']);
     $$ = { types: [ 'NUMBER' ], typeSet: true };
   }
 | ValueExpression '*' PartialBacktickedOrAnyCursor
   {
     parser.valueExpressionSuggest(undefined, $2);
     parser.applyTypeToSuggestions(['NUMBER']);
     $$ = { types: [ 'NUMBER' ], typeSet: true };
   }
 | ValueExpression 'ARITHMETIC_OPERATOR' PartialBacktickedOrAnyCursor
   {
     parser.valueExpressionSuggest(undefined, $2);
     parser.applyTypeToSuggestions(['NUMBER']);
     $$ = { types: [ 'NUMBER' ], typeSet: true };
   }
 | ValueExpression '-' ValueExpression_EDIT
   {
     if (!$3.typeSet) {
       parser.applyTypeToSuggestions(['NUMBER']);
       parser.addColRefIfExists($1);
     }
     $$ = { types: [ 'NUMBER' ], suggestFilters: $3.suggestFilters };
   }
 | ValueExpression '*' ValueExpression_EDIT
   {
     if (!$3.typeSet) {
       parser.applyTypeToSuggestions(['NUMBER']);
       parser.addColRefIfExists($1);
     }
     $$ = { types: [ 'NUMBER' ], suggestFilters: $3.suggestFilters };
   }
 | ValueExpression 'ARITHMETIC_OPERATOR' ValueExpression_EDIT
   {
     if (!$3.typeSet) {
       parser.applyTypeToSuggestions(['NUMBER']);
       parser.addColRefIfExists($1);
     }
     $$ = { types: [ 'NUMBER' ], suggestFilters: $3.suggestFilters };
   }
 ;
