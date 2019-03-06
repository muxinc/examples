const { ensureAuthenticated } = require('../auth/auth');

const {
  postVideo,
  getUserAssets,
  processMuxAsset } = require('../controllers/mux_controller');

module.exports = (app, io) => {

  // POST /video - posts a video url for Mux to ingest
  app.post('/video', ensureAuthenticated, postVideo);

  // GET /mux-assets - returns asset details for a user's session
  app.get('/mux-assets', ensureAuthenticated, getUserAssets);

  // POST /get-assets - Mux webhook asset response route
  app.post('/get-assets', (req, res, next) => processMuxAsset(req, res, next, io));
};
