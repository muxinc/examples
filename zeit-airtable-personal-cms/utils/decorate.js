const querystring = require('querystring');

const ALLOWED_DOMAINS = [
  'http://localhost:3000',
  'https://airtable-video-cms.now.sh/api/upload',
];

const checkOrigin = origin =>
  ALLOWED_DOMAINS.find(domain => domain === origin) || '';

const decorate = fn => (req, res) => {
  const [_base, query] = req.url.split('?');
  req.query = querystring.parse(query);

  res.setHeader('Access-Control-Allow-Origin', checkOrigin(req.headers.origin));
  fn(req, res);
};

module.exports = decorate;
