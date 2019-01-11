const { send } = require('micro');
const { getVideo } = require('../utils/airtable');
const decorate = require('../utils/decorate');

module.exports = decorate(async (req, res) => {
  const id = req.query.id;
  console.log(req.query);

  try {
    const video = await getVideo(id);

    send(res, 200, video);
  } catch (err) {
    console.log(err);
    send(res, 500, { error: 'shrug emoji' });
  }
});
