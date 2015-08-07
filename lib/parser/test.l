%{
    yy.a = 'aaa';
%}

// 状态：
// %s 指包容性的状态，%x 指非包容性的状态
// 如果是包容性的状态，那么没有状态的规则也会被激活；如果是非包容的，那么只有声明了相应状态的规则才会被激活。

// b 开始状态
// c 注释的状态
// block 选择器内部的状态
// sub_block 选择器内部子选择器内部的状态
%x b c block sub_block property

// 不需要 \r 了，解析前已经做了替换
n                           \n+
s                           [ \t\s]+
nonascii                    [\240-\377]
unicode                     \\{h}{1,6}(\r\n|[ \t\r\n\f])?
escape                      {unicode}|\\[^\r\n\f0-9a-fA-F]
nmstart                     [_a-zA-Z]|{nonascii}|{escape}
nmchar                      [_a-zA-Z0-9\-]|{nonascii}|{escape}
ident                       [\-]?{nmstart}{nmchar}*
colon                       \:+
semicolon                   \;+

selector                    {ident}[ \t\s]*\{\n*

comment                     ^(\/\*(?:[^*]|\*+[^\/*])*\*+\/\n?|\/\/[\s\S]*)


// %options flex case-insensitive
%options backtrack_lexer

%%

/* lexical grammar */

// <b>\-*[_a-zA-Z$]+       {return 'TEST1'}
// <b>([0-9]+(\.[0-9]+)?)|(\.[0-9]+) {return 'TEST2'}

// 注释先忽略
<b>{comment}
    {
        this.begin('c');
    }
;

<b,block,sub_block,property>{n}
    {
        // console.log(this, '11');
        return 'N';
    }
;

<b,block,sub_block,property>{s}
    {
        // console.log(this, '11');
        return 'S';
    }
;

<b,block,sub_block,property>{colon}
    {
        return 'COLON';
    }
;

<b,block,sub_block,property>{semicolon}
    {
        return 'SEMICOLON';
    }
;

<b,block,sub_block>'{'
    {
        if (this.topState() === 'block') {
            this.begin('sub_block');
        }
        else {
            this.begin('block');
        }
        // console.warn(this.topState(), 'rrr');
        return 'BRACE_BEGIN';
    }
;

<block,sub_block>'}'
    {
        // if (this.topState() === 'sub_block') {
        //     this.begin('block');
        // }
        // else {
            this.popState();
        // }
        return 'BRACE_END';
    }
;

<block,sub_block>{ident}\s*/{colon}
    {
        this.begin('property');
        // console.log(yytext, this.topState(), 'property');
        return 'PROPERTY';
    }
;

<property>{ident}
    {
        this.popState();
        // console.log(yytext, this.topState(), 'ssss');
        return 'VALUE';
    }
;

<b,block,sub_block>{ident}
    {
        return 'IDENT';
    }
;

<INITIAL><<EOF>>
    {
        return 'EOF';
    }
;

<b,c><<EOF>>
    {
        this.popState();
        return 'EOF';
    }
;

<INITIAL>
    {
        this.begin('b');
    }
;

// {number}                    { return 'NUMBER'; }
// {string}                    { return 'STRING'; }
// {ident}                     {/*console.warn(lexer.reject(), 1);*/ return 'IDENT'; }
// {nl}                        { /*console.log(this, '11');*/ return 'NL'; }
// <semi>{nl}                  { return 'NL1'; }
// {semicolonAndNL}            { return 'SEMICOLONANDNL'; }
// {space}                     {return 'SPACE'; }
// {tab}                     { return 'TAB'; }
// {dot}                       { return 'DOT'; }
// {colon}                     { return 'COLON'; }
// {semicolon}                 { return 'SEMICOLON'; }

// // // {space}/{comment}           ; // {console.warn(yytext, yytext.length); console.warn(111);}
// // // {nl}/{comment}              ; // {console.warn(yytext, yytext.length); console.warn(111);}
// // {nlAndComment}                   {console.log(this, 'sdsds');return 'COMMENT'};
// {comment}                   ;//{console.log(yy.lexer.next()); console.warn(yy);};

// // {indent}                    { return 'INDENT'; }
// // .                           { return yytext; }
// <INITIAL><<EOF>>            { return 'EOF'; }

%%

