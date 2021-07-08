const { client_oauth_redirect } = require('../config/config');

const getSession = (req, res, next) => {
  res.header('Content-Type', 'application/json');
  return res.status(200).send({ session: req.session });
};

const userLogout = (req, res, next) => {
  req.logout();
  req.session.destroy((err) => {
    if (err) {
      return next(err);
    }
    return res.status(200).send({ session: req.session });
  });
};

const googleAuthCallback = (req, res, next) => {
  // Authenticated successfully
  req.session.user = req.user;
  return res.redirect(client_oauth_redirect);
};

module.exports = {
  getSession,
  userLogout,
  googleAuthCallback,
};
