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

%options case-insensitive flex
%x doubleQuotedValue singleQuotedValue backtickedValue
%%

\s                                         { /* skip whitespace */ }
'--'.*                                     { /* skip comments */ }
[/][*][^*]*[*]+([^/*][^*]*[*]+)*[/]        { /* skip comments */ }

'\u2020'                                   { parser.yy.partialCursor = false; parser.yy.cursorFound = yylloc; return 'CURSOR'; }
'\u2021'                                   { parser.yy.partialCursor = true; parser.yy.cursorFound = yylloc; return 'PARTIAL_CURSOR'; }

// Reserved Keywords
'AND'                                      { return 'AND'; }
'AS'                                       { return 'AS'; }
'FALSE'                                    { return 'FALSE'; }
'FROM'                                     { parser.determineCase(yytext); return 'FROM'; }
'IS'                                       { return 'IS'; }
'NOT'                                      { return 'NOT'; }
'NULL'                                     { return 'NULL'; }
'OR'                                       { return 'OR'; }
'SELECT'                                   { parser.determineCase(yytext); parser.addStatementTypeLocation('SELECT', yylloc); return 'SELECT'; }
'TRUE'                                     { return 'TRUE'; }
'WHERE'                                    { return 'WHERE'; }

[0-9]+                                     { return 'UNSIGNED_INTEGER'; }
[0-9]+(?:[YSL]|BD)?                        { return 'UNSIGNED_INTEGER'; }
[0-9]+E                                    { return 'UNSIGNED_INTEGER_E'; }
[A-Za-z0-9_]+                              { return 'REGULAR_IDENTIFIER'; }

'&&'                                       { return 'AND'; }
'||'                                       { return 'OR'; }

'='                                        { return '='; }
'<'                                        { return '<'; }
'>'                                        { return '>'; }
'!='                                       { return 'COMPARISON_OPERATOR'; }
'<='                                       { return 'COMPARISON_OPERATOR'; }
'>='                                       { return 'COMPARISON_OPERATOR'; }
'<>'                                       { return 'COMPARISON_OPERATOR'; }
'<=>'                                      { return 'COMPARISON_OPERATOR'; }

'-'                                        { return '-'; }
'*'                                        { return '*'; }
'+'                                        { return 'ARITHMETIC_OPERATOR'; }
'/'                                        { return 'ARITHMETIC_OPERATOR'; }
'%'                                        { return 'ARITHMETIC_OPERATOR'; }
'|'                                        { return 'ARITHMETIC_OPERATOR'; }
'^'                                        { return 'ARITHMETIC_OPERATOR'; }
'&'                                        { return 'ARITHMETIC_OPERATOR'; }

','                                        { return ','; }
'.'                                        { return '.'; }
':'                                        { return ':'; }
';'                                        { return ';'; }
'~'                                        { return '~'; }
'!'                                        { return '!'; }

'('                                        { return '('; }
')'                                        { return ')'; }
'['                                        { return '['; }
']'                                        { return ']'; }

\`                                         { this.begin('backtickedValue'); return 'BACKTICK'; }
<backtickedValue>[^`]+                     {
                                             if (parser.handleQuotedValueWithCursor(this, yytext, yylloc, '`')) {
                                               return 'PARTIAL_VALUE';
                                             }
                                             return 'VALUE';
                                           }
<backtickedValue>\`                        { this.popState(); return 'BACKTICK'; }

\'                                         { this.begin('singleQuotedValue'); return 'SINGLE_QUOTE'; }
<singleQuotedValue>(?:\\\\|\\[']|[^'])+         {
                                             if (parser.handleQuotedValueWithCursor(this, yytext, yylloc, '\'')) {
                                               return 'PARTIAL_VALUE';
                                             }
                                             return 'VALUE';
                                           }
<singleQuotedValue>\'                      { this.popState(); return 'SINGLE_QUOTE'; }

\"                                         { this.begin('doubleQuotedValue'); return 'DOUBLE_QUOTE'; }
<doubleQuotedValue>(?:\\\\|\\["]|[^"])+         {
                                             if (parser.handleQuotedValueWithCursor(this, yytext, yylloc, '"')) {
                                               return 'PARTIAL_VALUE';
                                             }
                                             return 'VALUE';
                                           }
<doubleQuotedValue>\"                      { this.popState(); return 'DOUBLE_QUOTE'; }

<<EOF>>                                    { return 'EOF'; }

.                                          { /* To prevent console logging of unknown chars */ }
<backtickedValue>.                         { }
<singleQuotedValue>.                       { }
<doubleQuotedValue>.                       { }
