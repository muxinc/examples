const { send } = require('micro');
const { getVideo } = require('../utils/airtable');
const decorate = require('../utils/decorate');

module.exports = decorate(async (req, res) => {
  const id = req.query.id;

  try {
    const video = await getVideo(id);

    send(res, 200, video);
  } catch (err) {
    console.error(err);
    send(res, 500, { error: 'shrug emoji' });
  }
});
