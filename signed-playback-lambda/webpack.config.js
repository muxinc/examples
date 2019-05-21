const path = require('path');

module.exports = {
    target: 'node',
    entry: './lambda.js',
    output: {
        filename: 'lambda.js',
        path: path.resolve(__dirname, 'dist'),
        libraryTarget: 'commonjs2',
    }
};
