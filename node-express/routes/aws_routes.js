const { ensureAuthenticated } = require('../auth/auth');
const { getPreSignedUrlForVideo } = require('../controllers/s3_controller');

module.exports = (app) => {

  // GET /pre-signed-url - returns a signed aws s3 url for users to upload assets to.
  app.get('/pre-signed-url', ensureAuthenticated, getPreSignedUrlForVideo);
};
