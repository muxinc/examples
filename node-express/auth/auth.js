require('dotenv').config();
const db = require('../db/api');
const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;

passport.serializeUser(function(user, done) {
  done(null, user);
});

passport.deserializeUser(function(obj, done) {
  done(null, obj);
});

passport.use(new GoogleStrategy({
    clientID: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    callbackURL: process.env.GOOGLE_CALLBACK,
  },
  function(accessToken, refreshToken, profile, done) {
    // Query the database to find user record associated with this
    // google profile, then pass that object to done callback
    db.findUserById(profile.id).then(function(id) {
      if (id) {
        return done(null, profile);
      } else {
        db.createUser(profile.id).then(function(id) {
          return done(null, profile);
        });
      }
    });
  }
));

// Route middleware to ensure user is authenticated.
function ensureAuthenticated(req, res, next) {
  if (req.isAuthenticated()) {
    return next();
  }
  res.header('Content-Type', 'application/json');
  return res.status(401).send({ status: 401 });
}

module.exports = {
  passport,
  ensureAuthenticated,
};
