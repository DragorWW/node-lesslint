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
// %nonassoc SELECTOR


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
    : IDENT S BRACE_BEGIN
        {
            debug('line', 'IDENT S BRACE_BEGIN');
        }
    | S IDENT S BRACE_BEGIN
        {
            debug('line', 'S IDENT S BRACE_BEGIN');
        }

    | S PROPERTY COLON S VALUE SEMICOLON
        {
            debug('line', 'S PROPERTY COLON S VALUE SEMICOLON');
        }
    | BRACE_END
        {
            debug('line', 'BRACE_END');
        }
    | S BRACE_END
        {
            debug('line', 'S BRACE_END');
        }

    | line IDENT S BRACE_BEGIN
        {
            debug('line', 'line IDENT S BRACE_BEGIN');
        }
    | line S IDENT S BRACE_BEGIN
        {
            debug('line', 'line S IDENT S BRACE_BEGIN');
        }
    | line S PROPERTY COLON S VALUE SEMICOLON
        {
            debug('line', 'line S PROPERTY COLON S VALUE SEMICOLON');
        }
    | line BRACE_END
        {
            debug('line', 'line BRACE_END');
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
