require('regenerator-runtime/runtime');
const querystring = require('querystring');
const { default: basicAuth } = require('micro-basic-auth');

const authOptions = {
  realm: 'MeTube',
  validate: async (username, password, options) => {
    return (
      username === process.env.MANAGEMENT_PASSWORD ||
      password === process.env.MANAGEMENT_PASSWORD
    );
  },
};

const ALLOWED_DOMAINS = [
  'http://localhost:3000',
  'https://airtable-video-cms.now.sh/api/upload',
];

const checkOrigin = origin =>
  ALLOWED_DOMAINS.find(domain => domain === origin) || '';

const decorate = (fn, options = {}) => (req, res) => {
  const [_base, query] = req.url.split('?');
  req.query = querystring.parse(query);

  res.setHeader('Access-Control-Allow-Origin', checkOrigin(req.headers.origin));

  if (options.protected) {
    return basicAuth(authOptions)(fn)(req, res);
  }

  fn(req, res);
};

module.exports = decorate;
