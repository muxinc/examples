// next.config.js
module.exports = {
  target: "serverless",
  env: {
    BASE_URL: process.env.BASE_URL,
    NODE_ENV: process.env.NODE_ENV,
  }
};
