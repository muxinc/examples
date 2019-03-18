// next.config.js
module.exports = {
  target: 'serverless',
  serverRuntimeConfig: {
    airtableKey: process.env.AIRTABLE_API_KEY,
    airtableBase: process.env.AIRTABLE_BASE,
  },
  env: {
    baseUrl: process.env.BASE_URL,
    dev: process.env.NODE_ENV !== 'production',
  },
};
