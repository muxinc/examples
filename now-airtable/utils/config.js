const getBaseUrl = req => {
  if (process.env.dev && !process.env.baseUrl) {
    throw new Error(
      'When running the UI locally, a deployment URL is required. Did you add it to the .env file after deploying?'
    );
  }

  if (process.env.dev) {
    return process.env.baseUrl;
  }

  if (req) {
    return `https://${req.headers.host}`;
  }

  return '';
};

const path = (req, path) => getBaseUrl(req) + path;

module.exports = {
  path,
};
