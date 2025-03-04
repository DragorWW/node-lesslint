/**
 * @file 常用方法
 * @author ielgnaw(wuji0223@gmail.com)
 */

var fs = require('fs');
var edp = require('edp-core');

var WHITESPACE = /^[\s\xa0\u3000]+|[\u3000\xa0\s]+$/g;


/**
 * 转换正则表达式特殊字符
 *
 * @param {string} key 待转换字符串
 *
 * @return {string} 结果
 */
exports.escapeRegExp = function (key) {
    return (key + '').replace(/([-.*+?^${}()|[\]\/\\])/g, '\\$1');
};

/**
 * 去掉 error.messages 里面重复的信息
 *
 * @param {Array} msg error.messages
 *
 * @return {Array} 结果数组，是一个新数组
 */
exports.uniqueMsg = function (msg) {
    var ret = [];
    var tmp = [];
    for (var i = 0, j = 1, len = msg.length; i < len; i++, j++) {
        var cur = msg[i];
        if (!cur.uniqueFlag) {
            ret.push(cur);
        }
        else {
            if (tmp.indexOf(cur.uniqueFlag) === -1) {
                tmp.push(cur.uniqueFlag);
                ret.push(cur);
            }
        }
    }
    return ret;
};

/**
 * 调用给定的迭代函数 n 次,每一次传递 index 参数，调用迭代函数。
 * from underscore
 *
 * @param {number} n 迭代次数
 * @param {Function} iterator 处理函数
 * @param {Object} context 上下文
 *
 * @return {Array} 结果
 */
exports.times = function (n, iterator, context) {
    var accum = new Array(Math.max(0, n));
    for (var i = 0; i < n; i++) {
        accum[i] = iterator.call(context, i);
    }
    return accum;
};

/**
 * 格式化信息
 *
 * @param {string} msg 输出的信息
 * @param {number} spaceCount 信息前面空格的个数即缩进的长度
 *
 * @return {string} 格式化后的信息
 */
exports.formatMsg = function (msg, spaceCount) {
    var space = '';
    spaceCount = spaceCount || 0;
    exports.times(
        spaceCount,
        function () {
            space += ' ';
        }
    );
    return space + msg;
};

/**
 * 获取行号
 *
 * @param {number} index 索引
 * @param {string} data 文件内容
 *
 * @return {number} 行号
 */
exports.getLine = function (index, data) {
    var str = data.slice(0, index);
    return (str.match(/\n/g) || '').length + 1;
};

/**
 * 根据行号获取当前行的内容
 *
 * @param {number} line 行号
 * @param {string} fileData 文件内容
 * @param {boolean} notRemoveSpace 不去掉前面的空格，为 true，则不去掉，为 false 则去掉
 *                                 这是后加的参数，为了兼容之前的代码
 *
 * @return {string} 当前行内容
 */
exports.getLineContent = function (line, fileData, notRemoveSpace) {
    if (notRemoveSpace) {
        return fileData.split('\n')[line - 1];
    }
    // 去掉前面的缩进
    return fileData.split('\n')[line - 1].replace(/^\s*/, '');
};

/**
 * 删除目标字符串两端的空白字符
 *
 * @param {string} source 目标字符串
 * @return {string} 删除两端空白字符后的字符串
 */
exports.trim = function (source) {
    if (!source) {
        return '';
    }

    return String(source).replace(WHITESPACE, '');
};

/**
 * 根据参数以及模式匹配相应的文件
 *
 * @param {Array} args 文件
 * @param {Array} patterns minimatch 模式
 *
 * @return {Array.<string>} 匹配的文件集合
 */
exports.getCandidates = function (args, patterns) {
    var candidates = [];

    args = args.filter(function (item) {
        return item !== '.';
    });

    if (!args.length) {
        candidates = edp.glob.sync(patterns);
    }
    else {
        for (var i = 0; i < args.length; i++) {
            var target = args[i];
            if (!fs.existsSync(target)) {
                edp.log.warn('No such file or directory %s', target);
                continue;
            }

            var stat = fs.statSync(target);
            if (stat.isDirectory()) {
                target = target.replace(/[\/|\\]+$/, '');
                candidates.push.apply(
                    candidates,
                    edp.glob.sync(target + '/' + patterns[0])
                );
            }
            else if (stat.isFile()) {
                candidates.push(target);
            }
        }
    }

    return candidates;
};


/**
 * 获取忽略的 pattern
 *
 * @param {string} file 文件路径
 *
 * @return {Array.<string>} 结果
 */
exports.getIgnorePatterns = function (file) {
    if (!fs.existsSync(file)) {
        return [];
    }

    var patterns = fs.readFileSync(file, 'utf-8').split(/\r?\n/g);
    return patterns.filter(function (item) {
        return item.trim().length > 0 && item[0] !== '#';
    });
};

var _IGNORE_CACHE = {};

/**
 * 判断一下是否应该忽略这个文件.
 *
 * @param {string} file 需要检查的文件路径.
 * @param {string=} name ignore文件的名称.
 * @return {boolean}
 */
exports.isIgnored = function (file, name) {
    var ignorePatterns = null;

    name = name || '.jshintignore';
    file = edp.path.resolve(file);

    var key = name + '@'  + edp.path.dirname(file);
    if (_IGNORE_CACHE[key]) {
        ignorePatterns = _IGNORE_CACHE[key];
    }
    else {
        var options = {
            name: name,
            factory: function (item) {
                var config = {};
                exports.getIgnorePatterns(item).forEach(function (line) {
                    config[line] = true;
                });
                return config;
            }
        };
        ignorePatterns = edp.util.getConfig(
            edp.path.dirname(file),
            options
        );

        _IGNORE_CACHE[key] = ignorePatterns;
    }

    var bizOrPkgRoot = process.cwd();

    try {
        bizOrPkgRoot = edp.path.getRootDirectory();
    }
    catch (ex) {
    }

    var dirname = edp.path.relative(bizOrPkgRoot, file);
    var isMatch = edp.glob.match(dirname, Object.keys(ignorePatterns));

    return isMatch;
};


/**
 * 目录配置信息的缓存数据
 * @ignore
 */
var _CONFIG_CACHE = {};

/**
 * 读取默认的配置信息，可以缓存一下.
 *
 * @param {string} configName 配置文件的名称.
 * @param {string} file 文件名称.
 * @param {Object=} defaultConfig 默认的配置信息.
 *
 * @return {Object} 配置信息
 */
exports.getConfig = function (configName, file, defaultConfig) {
    var dir = edp.path.dirname(edp.path.resolve(file));
    var key = configName + '@' + dir;

    if (_CONFIG_CACHE[key]) {
        return _CONFIG_CACHE[key];
    }

    var options = {
        name: configName,
        defaultConfig: defaultConfig,
        factory: function (item) {
            /* istanbul ignore if */
            if (!fs.existsSync(item)) {
                return null;
            }

            return JSON.parse(fs.readFileSync(item, 'utf-8'));
        }
    };

    var value = edp.util.getConfig(dir, options);

    _CONFIG_CACHE[key] = value;

    return value;
};
