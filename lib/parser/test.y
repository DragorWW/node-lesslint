%{
    var chalk = require('chalk');
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
%nonassoc IDENT
%nonassoc SELECTOR


%start root
%%

root
    : nodes EOF
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

nodes
    : node
        {
            debug('nodes', 'node');
        }
    | nodes node
        {
            debug('nodes', 'nodes node');
        }
    ;

node
    : selector block BRACE_END n_or_empty
        {
            debug('node', 'selector block BRACE_END n_or_empty');
        }
    ;

selector
    : IDENT space_or_empty BRACE_BEGIN n_or_empty
        {
            console.warn('选择器');
            debug('selector', 'IDENT space_or_empty BRACE_BEGIN n_or_empty');
        }
    ;

block
    : kvs
        {
            debug('block', 'kvs');
        }
    // | block kvs
    //     {
    //         debug('block', 'block kvs');
    //     }
    ;

kvs
    : kv n_or_empty
        {
            debug('kvs', 'kv');
        }
    | kvs kv n_or_empty
        {
            debug('kvs', 'kvs kv n_or_empty');
        }
    ;

kv
    : k COLON v
        {
            console.warn('属性');
            debug('kv', 'k COLON v');
        }
    ;

k
    : space_or_empty IDENT
        {
            debug('k', 'space_or_empty IDENT');
        }
    ;

v
    : space_or_empty IDENT SEMICOLON
        {
            debug('v', 'space_or_empty IDENT semicolon_or_empty');
        }
    ;

n_or_empty
    : N
        {
            debug('n_or_empty', 'N');
        }
    | empty
        {
            debug('n_or_empty', 'empty');
        }
    ;

space_or_empty
    : S
        {
            debug('space_or_empty', 'S');
        }
    | empty
        {
            debug('space_or_empty', 'empty');
        }
    ;

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

// node
//     : selector S BRACE_BEGIN N kvs N BRACE_END N
//         {
//             debug('node', 'selector S BRACE_BEGIN N block N BRACE_END N');
//         }
//     // | selector S BRACE_BEGIN N block N BRACE_END N
//     //     {
//     //         debug('node', 'selector S BRACE_BEGIN N block N BRACE_END N');
//     //     }
//     // | node selector N block N
//         // {
//             // debug('node', 'node selector N block');
//         // }
//     ;

// selector
//     : IDENT
//         {
//             debug('selector', 'IDENT');
//         }
//     ;

// // block
// //     : kvs
// //         {
// //             debug('block', 'kvs');
// //         }
// //     ;

// kvs
//     : kv
//         {
//             debug('kvs', 'kv');
//         }
//     // | kv k COLON v
//     //     {
//     //         debug('kv', 'kv k COLON v');
//     //     }
//     ;

// kv
//     : k COLON v
//         {
//             debug('kv', 'k COLON v');
//         }
//     // | kv k COLON v
//     //     {
//     //         console.warn(111);
//     //     }
//     // | kv k COLON v
//     //     {
//     //         debug('kv', 'kv k COLON v');
//     //     }
//     ;

// k
//     : S IDENT
//         {
//             debug('k', 'S IDENT S');
//         }
//     ;

// v
//     : S IDENT SEMICOLON
//         {
//             debug('v', 'S IDENT S semicolon_or_empty');
//         }
//     ;


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

// space_or_empty
//     : S
//         {
//             debug('space_or_empty', 'S');
//         }
//     | empty
//         {
//             debug('space_or_empty', 'empty');
//         }
//     ;

// semicolon_or_empty
//     : SEMICOLON
//         {
//             debug('semicolon_or_empty', 'SEMICOLON');
//         }
//     | empty
//         {
//             debug('semicolon_or_empty', 'empty');
//         }
//     ;

// empty
//     : -> ''
//     ;


// root
//     : TEST1 space_or_empty TEST2 N
//         {
//             console.warn($2);
//             console.warn($1, $3);
//         }
//     ;

// space_or_empty
//     : S
//         {
//             debug('space_or_empty', 'S');
//         }
//     | empty
//         {
//             debug('space_or_empty', 'empty');
//         }
//     ;

// empty
//     : -> ''
//     ;


/* S+ */
// at_least_one_space
//     : S
//         {
//             console.warn($1.length);
//             debug('at_least_one_space', 'S');
//         }
//     | at_least_one_space S
//         {
//             debug('at_least_one_space', 'at_least_one_space S');
//         }
//     ;

// /* S* */
// space_or_empty
//     : at_least_one_space
//         {
//             debug('space_or_empty', 'at_least_one_space');
//         }
//     | empty
//         {
//             debug('space_or_empty', 'empty');
//         }
//     ;
