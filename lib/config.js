/**
 * @file lesslint 默认配置
 * @author ielgnaw(wuji0223@gmail.com)
 */

module.exports = {
    /* eslint-disable fecs-camelcase */

    // @import 语句引用的文件必须（MUST）写在一对引号内，.less 后缀不得（MUST NOT）省略（与引入 CSS 文件时的路径格式一致）。
    // 引号使用 ' 和 " 均可，但在同一项目内必须（MUST）统一。
    'import': true,

    // `{` : 选择器和 { 之间必须（MUST）保留一个空格。
    'require-before-space': ['{'],

    // `:` : 1. 属性名后的冒号（:）与属性值之间必须（MUST）保留一个空格，冒号前不得（MUST NOT）保留空格。
    //       2. 定义变量时冒号（:）与变量值之间必须（MUST）保留一个空格，冒号前不得（MUST NOT）保留空格。
    // `,` : 1. 在用逗号（,）分隔的列表（Less 函数参数列表、以 , 分隔的属性值等）中，逗号后必须（MUST）保留一个空格，
    //       逗号前不得（MUST NOT）保留空格。
    //       2. 在给 mixin 传递参数时，在参数分隔符（, / ;）后必须（MUST）保留一个空格
    'require-after-space': [':', ','],

    // + / - / * / / 四个运算符两侧必须（MUST）保留一个空格。
    'require-around-space': ['+', '-', '*', '/'],

    // + / - 两侧的操作数必须（MUST）有相同的单位，如果其中一个是变量，另一个数值必须（MUST）书写单位。
    'operate-unit': ['+', '-'],

    // Mixin 和后面的括号之间不得（MUST NOT）包含空格。
    'disallow-mixin-name-space': true,

    // `selector` : 当多个选择器共享一个声明块时，每个选择器声明必须（MUST）独占一行。
    'require-newline': ['selector'],

    // 对于处于 (0, 1) 范围内的数值，小数点前的 0 可以（MAY）省略，同一项目中必须（MUST）保持一致。
    'leading-zero': true,

    // 当属性值为 0 时，必须（MUST）省略可省的单位（长度单位如 px、em，不包括时间、角度等如 s、deg）。
    'zero-unit': true,

    // 颜色定义必须（MUST）使用 #rrggbb 格式定义，并在可能时尽量（SHOULD）缩写为 #rgb 形式，且避免直接使用颜色名称与 rgb() 表达式。
    'hex-color': true,

    // `color` 颜色值可以缩写时，必须使用缩写形式。
    'shorthand': ['color'],

    // 同一属性有不同私有前缀的，尽量（SHOULD）按前缀长度降序书写，标准形式必须（MUST）写在最后。
    // 且这一组属性以第一条的位置为准，尽量（SHOULD）按冒号的位置对齐。
    'vendor-prefixes-sort': true,

    // 必须（MUST）采用 4 个空格为一次缩进， 不得（MUST NOT）采用 TAB 作为缩进。
    'block-indent': true,

    // 变量命名必须采用 @foo-bar 形式，不得使用 @fooBar 形式
    'variable-name': true,

    // 使用继承时，如果在声明块内书写 :extend 语句，必须（MUST）写在开头：
    'extend-must-firstline': true,

    // 单行注释尽量使用 // 方式
    'single-comment': true

    /* eslint-enable fecs-camelcase */

};
