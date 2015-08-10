%{
    var chalk = require('chalk');
    var safeStringify = require('json-stringify-safe');

    var variables = [];
    var ast = {
        variables: [],
        nodes: [],
        selectors: []
    };

    var curSelector = null;

    var isDebug = true;
    function debug() {
        if (isDebug) {
            var args = [].slice.call(arguments);
            var len = args.length;
            if (len === 1) {
                console.warn(args[0]);
            }
            else {
                var msg = [];
                while (len) {
                    msg.push(args[args.length - len--]);
                }

                var first = msg.splice(0, 1);
                console.warn(chalk.yellow(first) + ': ' + chalk.cyan(msg.join(' ')));
                console.warn();
            }
        }
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
                root: ast
            };
        }
    | EOF
        {
            console.warn(2222);
            return {
                root: ast
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

            if (!curSelector) {
                ast.selectors.push($$);
                console.warn('选择器');
            }
            else {
                $$.parent = curSelector;
                curSelector.children.push($$);
                console.warn('子选择器');
            }
            curSelector = $$;

            debug('line', 'selector');
        }
    | line selector
        {
            // $$ = $2;
            // curSelector = $$;
            debug('line', 'line selector');
        }

    | S selector
        {
            $2.before = $1;
            $$ = $2;

            if (!curSelector) {
                ast.selectors.push($$);
                console.warn('选择器');
            }
            else {
                $$.parent = curSelector;
                curSelector.children.push($$);
                console.warn('子选择器');
            }
            curSelector = $$;
            debug('line', 'S selector');
        }
    | line S selector
        {
            // $3.before = $2;
            // $$ = $3;
            // curSelector = $$;
            debug('line', 'line S selector');
        }

    | prop_value
        {
            $$ = $1;
            // curSelector.props.push({

            // });
            // console.warn($$);
            console.warn('属性');
            debug('line', 'prop_value');
        }
    | line prop_value
        {
            $$ = $2;
            // console.warn($$);
            console.warn('属性 line');
            debug('line', 'line prop_value');
        }

    | BRACE_END
        {
            curSelector.isEnd = true;

            // curSelector.parent 如果是 null，那么 curSelector 就是 null
            curSelector = curSelector.parent;
            debug('line', 'BRACE_END');
        }
    | line BRACE_END
        {
            curSelector.isEnd = true;

            // curSelector.parent 如果是 null，那么 curSelector 就是 null
            curSelector = curSelector.parent;
            debug('line', 'line BRACE_END');
        }

    | S BRACE_END
        {
            curSelector.isEnd = true;

            // curSelector.parent 如果是 null，那么 curSelector 就是 null
            curSelector = curSelector.parent;
            debug('line', 'S BRACE_END');
        }
    | line S BRACE_END
        {
            curSelector.isEnd = true;

            // curSelector.parent 如果是 null，那么 curSelector 就是 null
            curSelector = curSelector.parent;
            debug('line', 'line S BRACE_END');
        }
    ;

selector
    : IDENT BRACE_BEGIN
        {
            $$ = {
                type: 'selector',
                value: $1,
                before: '',
                after: '',
                parent: null,
                isEnd: false,    // 选择器是否结束即是否遇到了 BRACE_END 符号，用于确定下一个选择器是子选择器还是兄弟选择器
                loc: {
                    firstLine: @1.first_line,
                    lastLine: @1.last_line,
                    firstCol: @1.first_column + 1,
                    lastCol: @1.last_column + 1
                },
                props: [],
                children: []
            };
            debug('selector', 'IDENT BRACE_BEGIN');
        }
    | IDENT S BRACE_BEGIN
        {
            $$ = {
                type: 'selector',
                value: $1,
                before: '',
                after: $2,
                parent: null,
                isEnd: false,    // 选择器是否结束即是否遇到了 BRACE_END 符号，用于确定下一个选择器是子选择器还是兄弟选择器
                loc: {
                    firstLine: @1.first_line,
                    lastLine: @1.last_line,
                    firstCol: @1.first_column + 1,
                    lastCol: @1.last_column + 1
                },
                props: [],
                children: []
            };
            debug('selector', 'IDENT S BRACE_BEGIN');
        }
    ;

prop_value
    : S PROPERTY COLON S VALUE semicolon_or_empty
        {
            $$ = $2 + '_' + $5;
            // console.warn(curSelector);
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
