%{
    var chalk = require('chalk');
    var safeStringify = require('json-stringify-safe');

    var variables = [];
    var ast = {
        variables: [],
        imports: [],
        selectors: [],
        charsets: []
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

// %nonassoc SPACE

%start root
%%

root
    : blocks EOF
        {
            ast.imports = yy.imports;
            // ast.charsets = yy.charsets;
            ast.sComments = yy.sComments;
            return {
                root: ast
            };
        }
    | EOF
        {
            ast.imports = yy.imports || [];
            // ast.charsets = yy.charsets || [];
            ast.sComments = yy.sComments || [];
            return {
                root: ast
            };
        }
    ;

blocks
    // : variable_definition
    // | import_stmt
    : charset_stmt
    | blocks charset_stmt
    // | block
    ;


variable_definition
    :
    ;

import_stmt
    :
    ;

/*charset_stmt
    : CHARSET SPACE STRING SEMICOLON space_or_empty
        {
            ast.charsets.push({
                type: 'charset',
                content: $3,
                quote: $3.slice(0, 1),
                before: '',
                after: $5,
                loc: {
                    firstLine: @1.first_line,
                    lastLine: @3.last_line,
                    firstCol: @1.first_column + 1,
                    lastCol: @4.last_column + 1,
                    originContent: $1 + $2 + $3 + $4 + $5
                }
            })
        }
    | SPACE CHARSET SPACE STRING SEMICOLON space_or_empty
        {
            ast.charsets.push({
                type: 'charset',
                content: $4,
                quote: $4.slice(0, 1),
                before: $1,
                after: $6,
                loc: {
                    firstLine: @2.first_line,
                    lastLine: @4.last_line,
                    firstCol: @2.first_column + 1,
                    lastCol: @5.last_column + 1,
                    originContent: $1 + $2 + $3 + $4 + $5 + $6
                }
            })
        }
    ;
*/

charset_stmt
    : charset_stmt_start STRING SEMICOLON charset_stmt_end
        {
            console.warn($1, $4);
            ast.charsets.push({
                type: 'charset',
                content: $2,
                quote: $2.slice(0, 1),
                before: $1.before,
                after: $4,
                loc: {
                    firstLine: @1.first_line,
                    lastLine: @2.last_line,
                    firstCol: @1.first_column + 1,
                    lastCol: @3.last_column + 1,
                    originContent: $1.content + $2 + $3
                }
            })
        }
    // | SPACE charset_stmt_start STRING SEMICOLON
    //     {
    //         // console.warn($5 + "---");
    //         ast.charsets.push({
    //             type: 'charset',
    //             content: $3,
    //             quote: $3.slice(0, 1),
    //             before: $1,
    //             // after: $5,
    //             loc: {
    //                 firstLine: @2.first_line,
    //                 lastLine: @4.last_line,
    //                 firstCol: @2.first_column + 1,
    //                 lastCol: @4.last_column + 1,
    //                 originContent: $1 + $2 + $3 + $4
    //             }
    //         })
    //     }
    ;

charset_stmt_start
    : CHARSET
        {
            $$ = {
                before: '',
                content: $1
            };
        }
    | CHARSET SPACE
        {
            $$ = {
                before: '',
                content: $1 + $2
            };
        }
    | SPACE CHARSET
        {
            $$ = {
                before: $1,
                content: $1 + $2
            };
        }
    | SPACE CHARSET SPACE
        {
            $$ = {
                before: $1,
                content: $1 + $2 + $3
            };
        }
    ;

charset_stmt_end
    // : N
    //     {
    //         $$ = $1;
    //     }
    : SPACE
        {
            $$ = $1;
        }
    | N
        {
            $$ = $1;
        }
    ;


block
    :
    ;

// S*
space_or_empty
    : SPACE
        {
            debug('s_or_empty', 'SPACE');
        }
    | N
        {
            debug('semicolon_or_empty', 'N');
        }
    | ''
        {
            debug('semicolon_or_empty', 'empty');
        }
    ;


// lines
//     : line N
//         {
//             debug('lines', 'line N');
//         }
//     | lines line N
//         {
//             debug('lines', 'lines line N');
//         }
//     ;

// line
//     : selector
//         {
//             $$ = $1;

//             if (!curSelector) {
//                 ast.selectors.push($$);
//             }
//             else {
//                 if (!curSelector.isEnd) {
//                     $$.parent = curSelector;
//                     curSelector.blocks.push($$);
//                 }
//             }
//             curSelector = $$;

//             debug('line', 'selector');
//         }
//     | line selector
//         {
//             $$ = $2;

//             if (!curSelector) {
//                 ast.selectors.push($$);
//             }
//             else {
//                 if (!curSelector.isEnd) {
//                     $$.parent = curSelector;
//                     curSelector.blocks.push($$);
//                 }
//             }
//             curSelector = $$;
//             debug('line', 'line selector');
//         }

//     | S selector
//         {
//             $2.before = $1;
//             $$ = $2;

//             if (!curSelector) {
//                 ast.selectors.push($$);
//             }
//             else {
//                 if (!curSelector.isEnd) {
//                     $$.parent = curSelector;
//                     curSelector.blocks.push($$);
//                 }
//             }
//             curSelector = $$;
//             debug('line', 'S selector');
//         }
//     | line S selector
//         {
//             debug('line', 'line S selector');
//         }

//     | prop_value
//         {
//             $$ = $1;
//             debug('line', 'prop_value');
//         }
//     | line prop_value
//         {
//             $$ = $2;
//             debug('line', 'line prop_value');
//         }

//     | BRACE_END
//         {
//             if (curSelector) {
//                 curSelector.isEnd = true;
//                 // curSelector.parent 如果是 null，那么 curSelector 就是 null
//                 curSelector = curSelector.parent;
//             }
//             debug('line', 'BRACE_END');
//         }
//     | line BRACE_END
//         {
//             if (curSelector) {
//                 curSelector.isEnd = true;
//                 // curSelector.parent 如果是 null，那么 curSelector 就是 null
//                 curSelector = curSelector.parent;
//             }
//             debug('line', 'line BRACE_END');
//         }

//     | S BRACE_END
//         {
//             if (curSelector) {
//                 curSelector.isEnd = true;
//                 // curSelector.parent 如果是 null，那么 curSelector 就是 null
//                 curSelector = curSelector.parent;
//             }
//             debug('line', 'S BRACE_END');
//         }
//     | line S BRACE_END
//         {
//             if (curSelector) {
//                 curSelector.isEnd = true;
//                 // curSelector.parent 如果是 null，那么 curSelector 就是 null
//                 curSelector = curSelector.parent;
//             }
//             debug('line', 'line S BRACE_END');
//         }
//     ;

// // 标签选择器
// tag_selector
//     : IDENT
//         {
//             $$ = {
//                 type: 'selector',
//                 value: $1,
//                 before: '',
//                 after: '',
//                 parent: null,
//                 isEnd: false,   // 选择器是否结束即是否遇到了 BRACE_END 符号，用于确定下一个选择器是子选择器还是兄弟选择器
//                 loc: {
//                     firstLine: @1.first_line,
//                     lastLine: @1.last_line,
//                     firstCol: @1.first_column + 1,
//                     lastCol: @1.last_column + 1
//                 },
//                 props: [],
//                 blocks: []
//             };
//             debug('tag_selector', 'IDENT');
//         }
//     | IDENT S
//         {
//             $$ = {
//                 type: 'selector',
//                 value: $1,
//                 before: '',
//                 after: $2,
//                 parent: null,
//                 isEnd: false,   // 选择器是否结束即是否遇到了 BRACE_END 符号，用于确定下一个选择器是子选择器还是兄弟选择器
//                 loc: {
//                     firstLine: @1.first_line,
//                     lastLine: @1.last_line,
//                     firstCol: @1.first_column + 1,
//                     lastCol: @1.last_column + 1
//                 },
//                 props: [],
//                 blocks: []
//             };
//             debug('tag_selector', 'IDENT S');
//         }
//     ;

// // 类选择器
// class_selector
//     : DOT IDENT
//         {
//             $$ = {
//                 type: 'selector',
//                 value: $1 + $2,
//                 before: '',
//                 after: '',
//                 parent: null,
//                 isEnd: false,   // 选择器是否结束即是否遇到了 BRACE_END 符号，用于确定下一个选择器是子选择器还是兄弟选择器
//                 loc: {
//                     firstLine: @1.first_line,
//                     lastLine: @1.last_line,
//                     firstCol: @1.first_column + 1,
//                     lastCol: @1.last_column + 1
//                 },
//                 props: [],
//                 blocks: []
//             };
//             debug('class_selector', 'DOT IDENT');
//         }
//     | DOT IDENT S
//         {
//             $$ = {
//                 type: 'selector',
//                 value: $1 + $2,
//                 before: '',
//                 after: $3,
//                 parent: null,
//                 isEnd: false,   // 选择器是否结束即是否遇到了 BRACE_END 符号，用于确定下一个选择器是子选择器还是兄弟选择器
//                 loc: {
//                     firstLine: @1.first_line,
//                     lastLine: @1.last_line,
//                     firstCol: @1.first_column + 1,
//                     lastCol: @1.last_column + 1
//                 },
//                 props: [],
//                 blocks: []
//             };
//             debug('class_selector', 'DOT IDENT S');
//         }
//     ;

// selector_item
//     : tag_selector
//         {
//             debug('selector_item', 'tag_selector');
//         }
//     | class_selector
//         {
//             debug('selector_item', 'class_selector');
//         }
//     | selector_item class_selector
//         {
//             if (!$1.after) {
//                 $1.value += $2.value;
//                 $$ = $1;
//             }
//             else {
//                 $2.parent = $1;
//                 $1.blocks.push($2);
//                 $$ = $1;
//             }
//             // curSelector = $$;
//             // ast.selectors.push($$);
//             debug('selector_item', 'selector_item class_selector');
//         }
//     // | selector_item class_selector S
//     //     {
//     //         // console.warn(curSelector);
//     //         console.warn($1);
//     //         console.warn($2);
//     //         $2.after = $3;
//     //         if (!$1.after) {
//     //             $1.value += $2.value;
//     //             $$ = $1;
//     //         }
//     //         else {
//     //             $2.parent = $1;
//     //             $1.blocks.push($2);
//     //             $$ = $1;
//     //         }
//     //         // curSelector = $$;
//     //         // ast.selectors.push($$);
//     //         debug('selector_item', 'selector_item class_selector S');
//     //     }
//     ;

// selector
//     : selector_item BRACE_BEGIN
//         {
//             debug('selector', 'selector BRACE_BEGIN');
//         }
//     ;

// prop
//     : PROPERTY
//         {
//             $$ = {
//                 val: $1,
//                 before: '',
//                 after: ''
//             };
//             debug('prop', 'PROPERTY');
//         }
//     | S PROPERTY
//         {
//             $$ = {
//                 val: $2,
//                 before: $1,
//                 after: ''
//             };
//             debug('prop', 'S PROPERTY');
//         }
//     | prop S
//         {
//             $1.after = $2;
//             $$ = $1;
//             debug('prop', 'prop S');
//         }
//     ;

// value
//     : VALUE
//         {
//             $$ = {
//                 val: $1,
//                 before: '',
//                 after: ''
//             };
//             debug('value', 'VALUE');
//         }
//     | S VALUE
//         {
//             $$ = {
//                 val: $2,
//                 before: $1,
//                 after: ''
//             };
//             debug('value', 'S VALUE');
//         }
//     | value S
//         {
//             $1.after = $2;
//             $$ = $1;
//             debug('value', 'value S');
//         }
//     ;

// prop_value
//     : prop COLON value semicolon_or_empty
//         {
//             curSelector.props.push({
//                 type: 'prop',
//                 prop: $1.val,
//                 beforeProp: $1.before,
//                 afterProp: $1.after,
//                 value: $3.val,
//                 beforeValue: $3.before,
//                 afterValue: $3.after,
//                 loc: {
//                     firstLine: @1.first_line,
//                     lastLine: @1.last_line,
//                     firstCol: @1.first_column + 1,
//                     lastCol: @1.last_column + 1
//                 }
//             });

//             debug('prop_value', 'prop COLON value semicolon_or_empty');
//         }
//     | prop COLON value BRACE_END
//         {
//             curSelector.props.push({
//                 type: 'prop',
//                 prop: $1.val,
//                 beforeProp: $1.before,
//                 afterProp: $1.after,
//                 value: $3.val,
//                 beforeValue: $3.before,
//                 afterValue: $3.after,
//                 loc: {
//                     firstLine: @1.first_line,
//                     lastLine: @1.last_line,
//                     firstCol: @1.first_column + 1,
//                     lastCol: @1.last_column + 1
//                 }
//             });
//             curSelector.isEnd = true;
//             curSelector = curSelector.parent;
//             debug('prop_value', 'prop COLON value BRACE_END');
//         }
//     ;

// // SEMICOLON*
// semicolon_or_empty
//     : SEMICOLON
//         {
//             debug('semicolon_or_empty', 'SEMICOLON');
//         }
//     | N
//         {
//             debug('semicolon_or_empty', 'N');
//         }
//     | ''
//         {
//             debug('semicolon_or_empty', 'empty');
//         }
//     // | S
//     //     {
//     //         debug('semicolon_or_empty', 'empty');
//     //     }
//     ;

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
