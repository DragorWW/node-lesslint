%{
    yy.a = 'aaa';
%}

// 状态：
// %s 指包容性的状态，%x 指非包容性的状态
// 如果是包容性的状态，那么没有状态的规则也会被激活；如果是非包容的，那么只有声明了相应状态的规则才会被激活。

// b 开始状态
// c 注释的状态
%x b c

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
<b>{comment}                   { this.begin('c');}
<b>{n}                         { /*console.log(this, '11');*/ return 'N'; }
<b>{s}                         { /*console.log(this, '11');*/ return 'S'; }
<b>{colon}                     { return 'COLON'; }
<b>{semicolon}                 { return 'SEMICOLON'; }
<b>'{'                         { return 'BRACE_BEGIN'; }
<b>'}'                         { return 'BRACE_END'; }

// <b>{selector}                     { /*console.log(yytext);*/ return 'SELECTOR';}
<b>{ident}                     { /*console.log(yytext);*/ return 'IDENT';}

<INITIAL><<EOF>>            { return 'EOF'; }
<b,c><<EOF>>                  { this.popState(); return 'EOF'; }
<INITIAL>                   { this.begin('b');}

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

