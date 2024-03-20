
// Bison variant of [Lucene syntax](https://github.com/apache/lucene/blob/main/lucene/queryparser/src/java/org/apache/lucene/queryparser/flexible/standard/parser/StandardSyntaxParser.jj)

%language "c++"
%skeleton "lalr1.cc"
%require "3.8"
%debug
%defines
%define api.namespace {infinity}
%define api.parser.class {SearchParser}
%define api.value.type variant
%define api.token.raw
%define parse.assert
%define parse.error verbose

/* code snippet copied to generated search_parser.tab.hh */
%code requires{
    // unique_ptr<QueryNode> requires sizeof(QueryNode)
    #ifndef QUERY_NODE_H
    #include "query_node.h"
    #endif

    namespace infinity {
        class SearchDriver;
        class SearchScanner;
    }
}

%parse-param {SearchScanner &scanner} {const SearchDriver &driver} {const std::string &default_field} {std::unique_ptr<QueryNode> &parse_result}

/* code snippet copied to generated search_parser.tab.cc */
%code{
    #include "search_driver.h"
    #include "search_scanner.h"

    #undef yylex
    #define yylex scanner.yylex

    #include <iostream>
    #include <sstream>
    #include <string>
    #include <vector>
    #include "query_node.h"

    // Avoid warnings with the error counter.
    #if defined(__GNUC__) || defined(__clang__)
    #pragma GCC diagnostic ignored "-Wunused-but-set-variable"
    #endif
}

/* terminal symbol */
%token                 END    0     "end of file"
%token                 AND
%token                 OR
%token                 NOT
%token                 LPAREN
%token                 RPAREN
%token                 OP_COLON
%token <float>         CARAT
%token <std::string>   STRING

/* nonterminal symbol */
%type <std::unique_ptr<QueryNode>>  topLevelQuery query clause term basic_filter_boost basic_filter

%locations

%%

// TopLevelQuery ::= Query <EOF>
// Query ::= DisjQuery ( DisjQuery )*
// DisjQuery ::= ConjQuery ( OR ConjQuery )*
// ConjQuery ::= Clause ( AND Clause )*
topLevelQuery
: query END {
    parse_result = std::move($1);
};

query
: clause { $$ = std::move($1); }
| query clause {
    auto query = std::make_unique<OrQueryNode>();
    query->Add(std::move($1));
    query->Add(std::move($2));
    $$ = std::move(query);
}
| query OR clause {
    auto query = std::make_unique<OrQueryNode>();
    query->Add(std::move($1));
    query->Add(std::move($3));
    $$ = std::move(query);
};

clause
: term { $$ = std::move($1); }
| clause AND term {
    auto query = std::make_unique<AndQueryNode>();
    query->Add(std::move($1));
    query->Add(std::move($3));
    $$ = std::move(query);
};

term
: basic_filter_boost { $$ = std::move($1); }
| NOT term {
    auto query = std::make_unique<NotQueryNode>();
    query->Add(std::move($2));
    $$ = std::move(query);
}
| LPAREN query RPAREN { $$ = std::move($2); }
| LPAREN query RPAREN CARAT {
    $$ = std::move($2);
    $$->MultiplyWeight($4);
};

basic_filter_boost
: basic_filter {
    $$ = std::move($1);
}
| basic_filter CARAT {
    $$ = std::move($1);
    $$->MultiplyWeight($2);
};

basic_filter
: STRING {
    const std::string &field = default_field;
    if(field.empty()){
        error(@1, "default_field is empty");
        YYERROR;
    }
    $$ = driver.AnalyzeAndBuildQueryNode(field, std::move($1));
}
| STRING OP_COLON STRING {
    $$ = driver.AnalyzeAndBuildQueryNode($1, std::move($3));
};

%%

namespace infinity{
void SearchParser::error(const location_type &l, const std::string &err_message) {
    std::cerr << "Error: " << err_message << " at " << l << "\n";
}
} //namespace infinity
