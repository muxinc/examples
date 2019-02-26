const getBaseUrl = (req) => {
  const proto = req.connection.encrypted ? 'https' : 'http';
  let url = proto + '://' + req.headers.host;

  if (process.env.NODE_ENV !== 'production') {
    url = process.env.BASE_URL ? process.env.BASE_URL : url;

    if (!url) {
      throw new Error(
        'When running the UI locally, a deployment URL is required. Did you add it to the .env file after deploying?'
      );
    }
  }

  if (url.endsWith('/')) {
    return url.slice(0, -1);
  }

  return url;
};

const path = (req, path) => getBaseUrl(req) + path

module.exports = {
  path
};
