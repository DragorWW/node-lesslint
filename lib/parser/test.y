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

// %nonassoc selector
// %nonassoc IDENT
// %nonassoc S N BRACE_BEGIN BRACE_END


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

    | prop_value
        {
            $$ = $1;
            console.warn($$);
            console.warn('属性');
            debug('line', 'prop_value');
        }
    | line prop_value
        {
            $$ = $2;
            console.warn($$);
            console.warn('属性');
            debug('line', 'line prop_value');
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
    : S PROPERTY COLON S VALUE semicolon_or_empty
        {
            $$ = $2 + '_' + $5;
            debug('prop_value', 'S PROPERTY COLON S VALUE semicolon_or_empty');
        }
    | PROPERTY COLON S VALUE semicolon_or_empty
        {
            $$ = $1 + '_' + $4;
            debug('prop_value', 'PROPERTY COLON S VALUE semicolon_or_empty');
        }
    | S PROPERTY COLON VALUE semicolon_or_empty
        {
            $$ = $2 + '_' + $4;
            debug('prop_value', 'S PROPERTY COLON VALUE semicolon_or_empty');
        }
    | PROPERTY COLON VALUE semicolon_or_empty
        {
            console.warn($4, 'sds');
            $$ = $1 + '_' + $3;
            debug('prop_value', 'PROPERTY COLON VALUE semicolon_or_empty');
        }
    ;


// SEMICOLON*
semicolon_or_empty
    : SEMICOLON
        {
            debug('semicolon_or_empty', 'SEMICOLON');
        }
    | empty
        {
            debug('semicolon_or_empty', 'empty');
        }
    ;

empty
    : -> ''
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
