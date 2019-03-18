// next.config.js
module.exports = {
  target: 'serverless',
  env: {
    baseUrl: process.env.BASE_URL,
    dev: process.env.NODE_ENV !== 'production',
  },
};
