const { client_oauth_failure_redirect } = require('../config/config');
const { passport, ensureAuthenticated } = require('../auth/auth');

const {
  getSession,
  userLogout,
  googleAuthCallback} = require('../controllers/auth_controller');

module.exports = (app) => {

  // GET /login - user authentication and session initiation
  app.get('/login', passport.authenticate('google', { scope: ['openid email profile'] }));

  // GET /logout - clears user session
  app.get('/logout', userLogout);

  // GET /auth/google - google oauth2 authentication
  app.get('/auth/google', passport.authenticate('google', { scope: ['openid email profile'] }));

  // GET /auth/google/callback - google oauth2 authentication callback
  app.get('/auth/google/callback',
    passport.authenticate('google', { failureRedirect: client_oauth_failure_redirect }), googleAuthCallback);

  // GET /session - returns a user's session
  app.get('/session', ensureAuthenticated, getSession);
};
