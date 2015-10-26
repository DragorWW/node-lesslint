%{
    yy.a = 'aaa';
    var s, s2, s3;
    var rv, rv2, e_offset, col, row, len, value;
    var match, match2;

    // console.log("lexer action: ", yy, yy_, this, yytext, YY_START, $avoiding_name_collisions);
    var parser = yy.parser;
    // console.warn(YY_START);
%}

// 状态：
// %s 指包容性的状态，%x 指非包容性的状态
// 如果是包容性的状态，那么没有状态的规则也会被激活；如果是非包容的，那么只有声明了相应状态的规则才会被激活。

// s 开始状态
// sc 进入单行注释的状态
// mc 进入多行注释的状态
// b 进入选择器内部即块的状态
// sb 进入选择器内部子选择器内部即子块的状态
// p 进入属性的状态，这个状态用来帮助找到属性的值
// im 进入 @import 语句后的状态
// ch 进入 @charset 语句后的状态
%x s sc mc b sb p im ch

n                           \n+
space                       [ \t\s]+

semicolon                   \;+
import                      \s*'@import'
charset                     '@charset'
singlecomment               \/\/.*
// singlecomment               (['"]).*\1.*(\/\/.*)

string1                     \"([^\n\r\f\\"])*\"
string2                     \'([^\n\r\f\\'])*\'
string                      {string1}|{string2}

quote                       ['"]



/*"'*/ // 这个注释是为了把 quote 的正则所带来的高亮影响给去掉


// %options flex case-insensitive
%options backtrack_lexer
// %options flex

%%

<s,ch>{string}
    {
        return 'STRING';
    }
;

<s,ch>{space}
    {
        return 'SPACE';
    }
;

<s,ch>{n}
    {
        return 'N';
    }
;


<s>{charset}
    {
        this.begin('ch');
        return 'CHARSET';
    }
;

<ch>\n+
    {
        this.popState();
    }
;

<ch>{semicolon}
    {
        this.popState();
        return 'SEMICOLON';
    }
;


// 任何状态中，非字符串内的 `//` 后面都是注释
// <INITIAL,s>{singlecomment}
//     {
//         this.begin('sc');
//         if (!yy.sComments) {
//             yy.sComments = [];
//         }

//         /(['"]).*\1.*(\/\/.*)/.test(yytext);

//         yy.sComments.push({
//             type: 'sComment',
//             content: RegExp.$2,
//             loc: {
//                 firstLine: yylloc.first_line,
//                 lastLine: yylloc.last_line,
//                 firstCol: yylloc.first_column + 1,
//                 lastCol: yylloc.last_column + 1,
//                 originContent: yytext
//             }
//         });
//     }
// ;

// <sc>{n}
//     {
//         this.popState();
//     }
// ;

/*<s,b,sb,p,im,ch>{singlecomment}
    {
        if (!yy.sComments) {
            yy.sComments = [];
        }

        yy.sComments.push({
            type: 'sComment',
            content: yytext,
            loc: {
                firstLine: yylloc.first_line,
                lastLine: yylloc.last_line,
                firstCol: yylloc.first_column + 1,
                lastCol: yylloc.last_column + 1,
                originContent: yytext
            }
        });

        this.begin('sc');
    }
;

<sc>{n}
    {
        this.popState();
    }
;

<s>{import}
    {
        this.begin('im');
    }
;

<im>[^\n]+
    {
        // console.warn(this.matches);
        // 移除左右空格后的 yytext
        var removeSpaceAroundYYtext = yytext.replace(/^(\s*)/, '').replace(/(\s*)$/, '');

        // 去掉字符串即引号内的内容
        var removeQuoteContentYYtext = removeSpaceAroundYYtext.replace(/(['"])([\s\S]*)\1/, '');

        if (/(\/{2,}.*)/.test(removeQuoteContentYYtext)) {
            // this.begin('sc');
            // var scContent = RegExp.$1;
            // if (!yy.sComments) {
            //     yy.sComments = [];
            // }

            // yy.sComments.push({
            //     type: 'sComment',
            //     content: scContent,
            //     loc: {
            //         firstLine: yylloc.first_line,
            //         lastLine: yylloc.last_line,
            //         firstCol: yylloc.first_column + 1,
            //         lastCol: yylloc.last_column + 1,
            //         originContent: scContent
            //     }
            // });
        }


        var content = '';
        var quote = '';

        if (/url\((.*)\)/.test(removeSpaceAroundYYtext)) {
            content = 'url(' + RegExp.$1 + ')';
            if (/(['"])([\s\S]*)\1/.test(content)) {
                quote = RegExp.$1;
            }
        }
        else {
            /(['"])([\s\S]*)\1/.test(yytext);
            content = RegExp.$2;
            quote = RegExp.$1;
        }

        if (!content) {
            content = removeSpaceAroundYYtext;
        }

        // 移除左边空格后的 yytext
        var removeSpaceBeforeYYtext = yytext.replace(/^(\s*)/, '');
        var beforeSpace = RegExp.$1 || '';

        // 移除右边空格后的 yytext
        var removeSpaceAfterYYtext = yytext.replace(/(\s*)$/, '');
        var afterSpace = RegExp.$1;

        if (!yy.imports) {
            yy.imports = [];
        }

        yy.imports.push({
            type: 'import',
            content: content,
            quote: quote,
            before: beforeSpace,
            after: afterSpace,
            loc: {
                firstLine: yylloc.first_line,
                lastLine: yylloc.last_line,
                firstCol: yylloc.first_column + 1 + beforeSpace.length,
                lastCol: yylloc.last_column + 1,
                originContent: yytext
            }
        });
    }
;

<im>\n+
    {
        this.popState();
    }
;

<s>{charset}
    {
        this.begin('ch');
    }
;

<ch>[^\n]+
    {
        /(['"])([\s\S]*)\1/.test(yytext);
        var content = RegExp.$2;
        var quote = RegExp.$1;

        /^(\s*)/.test(yytext);
        var before = RegExp.$1 || '';

        /(\s*)$/.test(yytext);
        var after = RegExp.$1;

        if (!yy.charsets) {
            yy.charsets = [];
        }

        yy.charsets.push({
            type: 'charset',
            content: content,
            quote: quote,
            before: before,
            after: after,
            loc: {
                firstLine: yylloc.first_line,
                lastLine: yylloc.last_line,
                firstCol: yylloc.first_column + 1 + before.length,
                lastCol: yylloc.last_column + 1,
                originContent: yytext
            }
        });
    }
;

<ch>\n+
    {
        this.popState();
    }
;*/

<INITIAL><<EOF>>
    {
        return 'EOF';
    }
;

<s><<EOF>>
    {
        this.popState();
        return 'EOF';
    }
;

<INITIAL>
    {
        this.begin('s');
    }
;

%%

