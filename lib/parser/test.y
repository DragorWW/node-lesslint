%{
    var chalk = require('chalk');
    var safeStringify = require('json-stringify-safe');

    var variables = [];
    var resultAst = {
        variables: [],
        nodes: [],
        selectors: []
    };

    function debug(ruleStr, actionStr) {
        console.log(chalk.yellow(ruleStr + ': ') + chalk.cyan(actionStr));
        console.warn();
    }

%}

/* operator associations and precedence */


// %nonassoc nodes
// %nonassoc node
// %nonassoc selector block
// %nonassoc kvs
// %nonassoc kv
// %nonassoc k v
// %nonassoc IDENT
// %nonassoc n_or_empty
// %nonassoc N

// %nonassoc space_or_empty
// %nonassoc at_least_one_space
// %nonassoc S
// %nonassoc empty


// %nonassoc nodes
// %nonassoc node
// %nonassoc block
// %nonassoc kvs
// %nonassoc kv
// %nonassoc IDENT

%nonassoc selector
%nonassoc IDENT
%nonassoc S N BRACE_BEGIN


%start root
%%

root
    : lines EOF
        {
            return {
                root: resultAst
            };
        }
    | EOF
        {
            return {
                root: resultAst
            };
        }
    ;

lines
    : line N
        {
            debug('lines', 'line N');
        }
    | lines line N
        {
            debug('lines', 'lines line N');
        }
    ;

selector
    : IDENT BRACE_BEGIN
        {
            debug('selector', 'IDENT BRACE_BEGIN');
        }
    | IDENT S BRACE_BEGIN
        {
            debug('selector', 'IDENT S BRACE_BEGIN');
        }
    ;

prop_value
    : PROPERTY COLON S VALUE SEMICOLON
        {
            $$ = $1 + '_' + $4;
            debug('prop_value', 'PROPERTY COLON S VALUE SEMICOLON');
        }
    ;

line
    : selector
        {
            $$ = $1;
            console.warn($$);
            console.warn('选择器');
            debug('line', 'selector');
        }
    | line selector
        {
            debug('line', 'line selector');
        }

    | S selector
        {
            $$ = $2;
            console.warn($$);
            console.warn('子选择器');
            debug('line', 'S selector');
        }
    | line S selector
        {
            debug('line', 'line S selector');
        }

    | S prop_value
        {
            $$ = $2;
            console.warn($$);
            console.warn('属性');
            debug('line', 'S prop_value');
        }
    | line S prop_value
        {
            $$ = $3;
            console.warn($$);
            console.warn('属性');
            debug('line', 'line S prop_value');
        }

    | BRACE_END
        {
            debug('line', 'BRACE_END');
        }
    | line BRACE_END
        {
            debug('line', 'line BRACE_END');
        }

    | S BRACE_END
        {
            debug('line', 'S BRACE_END');
        }
    | line S BRACE_END
        {
            debug('line', 'line S BRACE_END');
        }
    ;

// N*
// n_or_empty
//     : N
//         {
//             debug('n_or_empty', 'N');
//         }
//     | empty
//         {
//             debug('n_or_empty', 'empty');
//         }
//     ;

// // S*
// s_or_empty
//     : S
//         {
//             debug('s_or_empty', 'S');
//         }
//     | empty
//         {
//             debug('s_or_empty', 'empty');
//         }
//     ;

// empty
//     : -> ''
//     ;
