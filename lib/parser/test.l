%{
    yy.a = 'aaa';
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
%x s sc mc b sb p im

// 不需要 \r 了，解析前已经做了替换
n                           \n+
s                           [ \t\s]+
nonascii                    [\240-\377]
unicode                     \\{h}{1,6}(\r\n|[ \t\r\n\f])?
escape                      {unicode}|\\[^\r\n\f0-9a-fA-F]
nmstart                     [_a-zA-Z]|{nonascii}|{escape}
nmchar                      [_a-zA-Z0-9\-]|{nonascii}|{escape}

ident                       [\-]?{nmstart}{nmchar}*
// ident                    \-*[_a-zA-Z$][-\w\d$]+
// ident                    \-*[_a-zA-Z0-9$]+

colon                       \:+
semicolon                   \;+

all                         [\s\S]

selector                    {ident}[ \t\s]*\{\n*

/*comment                     ^(\/\*(?:[^*]|\*+[^\])*\*+\/\n?|\/\/[\s\S]*)*/
// singlecomment               ^(\/\/.*[^\n])
singlecomment               ^(\/\/.*)
// multicomment                ^\/\*[^*]*\*+([^\][^*]*\*+)*\/
// multicommentstart           ^(\/\*[\s\S]+)
multicommentstart           ^(\/\*)
multicommentend             ([^\][^*]*\*+)*\/\n*

// import                      ^'@'import
import                      ^\s*'@import'

quote                       ['"]


/*"'*/ // 这个注释是为了把 quote 的正则所带来的高亮影响给去掉


// %options flex case-insensitive
%options backtrack_lexer

%%

/* lexical grammar */

// <s>\-*[_a-zA-Z$]+       {return 'TEST1'}
// <s>([0-9]+(\.[0-9]+)?)|(\.[0-9]+) {return 'TEST2'}

<s>{singlecomment}
    {
        // console.warn(yytext, 123123);
        this.begin('sc');
    }
;

<s>{multicommentstart}
    {
        // console.warn(yytext, 'mc-start');
        this.begin('mc');
    }
;

<mc>{multicommentend}
    {
        // console.warn(yytext, 'mc-end');
        this.popState();
    }
;

<sc>{n}
    {
        // console.warn(112312321);
        this.popState();
    }
;

<s>{import}
    {
        // console.warn(yytext, 'sss');
        // console.warn('enter im');
        this.begin('im');
    }
;

<im>[^;]+
    {
        /(['"])([\s\S]*)\1/.test(yytext);
        var content = RegExp.$2;
        var quote = RegExp.$1;

        /^(\s*)/.test(yytext);
        var before = RegExp.$1;

        /(\s*)$/.test(yytext);
        var after = RegExp.$1;

        if (!yy.imports) {
            yy.imports = [];
        }

        // 这里把 @import (less) 'aaa'; 里面的 (less) 暂时省略了
        yy.imports.push({
            type: 'import',
            content: content,
            quote: quote,
            before: before,
            after: after,
            loc: {
                firstLine: yylloc.first_line,
                lastLine: yylloc.last_line,
                firstCol: yylloc.first_column + 1,
                lastCol: yylloc.last_column + 1
            }
        });

        // yy.imports.push({
            // content:
        // });
        // yy.imports.push(Date.now());
        // return 'IMPORT_CONTENT';
        // console.warn(lexer);
    }
;

<im>{semicolon}\n*
    {
        // console.warn(2);
        this.popState();
        // console.warn(this.topState());
    }
;


// // <im>{all}*(quote)?{all}*\1?[^;]
// <im>[^;]+(quote)+[^;]+\1[^;]*
//     {
//         console.warn(yytext);
//         console.warn(1);
//     }
// ;

<s,b,sb,p>{n}
    {
        // console.log(this, '11');
        return 'N';
    }
;

<s,b,sb,p>{s}
    {
        // console.log(this, '11');
        return 'S';
    }
;

<s,b,sb,p>{colon}
    {
        return 'COLON';
    }
;

<s,b,sb,p>{semicolon}
    {
        return 'SEMICOLON';
    }
;

<s,b,sb>'{'
    {
        if (this.topState() === 'b') {
            this.begin('sb');
        }
        else {
            this.begin('b');
        }
        // console.warn(this.topState(), 'rrr');
        return 'BRACE_BEGIN';
    }
;

<b,sb>'}'
    {
        // if (this.topState() === 'sb') {
        //     this.begin('b');
        // }
        // else {
            this.popState();
        // }
        return 'BRACE_END';
    }
;

// <b,sb>{ident}\s*/{colon}
<b,sb>{ident}/(\s*{colon})
    {
        // console.log(yytext, this.topState(), 'p');
        this.begin('p');
        // console.log(yytext, this.topState(), 'p');
        return 'PROPERTY';
    }
;

// 匹配属性值中带有空格的情况
<p>{ident}\s+{ident}
    {
        // console.warn(yytext);
        this.popState();
        // console.log(yytext + '--', this.topState(), 'sss');
        return 'VALUE';
    }
;

<p>{ident}
    {
        // console.warn(yytext);
        this.popState();
        // console.log(yytext + '--', this.topState(), 'sss');
        return 'VALUE';
    }
;

<s,b,sb>{ident}
    {
        return 'IDENT';
    }
;

<INITIAL><<EOF>>
    {
        return 'EOF';
    }
;

<s,sc,mc><<EOF>>
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

