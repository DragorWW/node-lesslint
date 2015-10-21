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

semicolon                   \;+
import                      ^\s*'@import '
charset                     ^\s*'@charset '

quote                       ['"]


/*"'*/ // 这个注释是为了把 quote 的正则所带来的高亮影响给去掉


// %options flex case-insensitive
%options backtrack_lexer

%%

<s>{import}
    {
        this.begin('im');
    }
;

<im>[^;]+
    {
        // 移除左边空格后的 yytext
        var removeSpaceBeforeYYtext = yytext.replace(/^(\s*)/, '');
        var beforeSpace = RegExp.$1 || '';

        // 移除右边空格后的 yytext
        var removeSpaceAfterYYtext = yytext.replace(/(\s*)$/, '');
        var afterSpace = RegExp.$1;

        // 移除左右空格后的 yytext
        var removeSpaceAroundYYtext = yytext.replace(/^(\s*)/, '').replace(/(\s*)$/, '');

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

<im>{semicolon}\n*
    {
        this.popState();
    }
;

<s>{charset}
    {
        this.begin('ch');
    }
;

<ch>[^;]+
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

<ch>{semicolon}\n*
    {
        this.popState();
    }
;


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

