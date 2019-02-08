const { send } = require('micro');
const { listVideos } = require('../utils/airtable');
const decorate = require('../utils/decorate');

module.exports = decorate(async (req, res) => {
  try {
    const videos = await listVideos();
    console.log(videos);

    send(res, 200, videos);
  } catch (err) {
    console.log(err);
    send(res, 500, { error: 'shrug emoji' });
  }
});
