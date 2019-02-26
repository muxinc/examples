const { send } = require('micro');
const { listVideos } = require('../utils/airtable');
const decorate = require('../utils/decorate');

module.exports = decorate(async (req, res) => {
  try {
    const videos = await listVideos();

    send(res, 200, videos);
  } catch (err) {
    console.error(err);
    send(res, 500, { error: 'shrug emoji' });
  }
});
