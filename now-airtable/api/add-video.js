const { json, send } = require('micro');
const { createVideo, updateVideo } = require('../utils/airtable');
const decorate = require('../utils/decorate');
const Mux = require('@mux/mux-node');

const { Video } = new Mux();

// `decorate` is a higher level function that wraps our callback to add
// things like basic auth.
module.exports = decorate(
  async (req, res) => {
    const params = await json(req);

    // Here we create our new video using our Airtable wrapper module.
    const videoParams = {
      title: params.title,
      description: params.description,
    };
    const video = await createVideo(videoParams);

    try {
      // Now that we have our video created internally, we can use that ID in
      // the `passthrough` field when we create a new asset.
      const upload = await Video.Uploads.create({
        cors_origin: req.headers.origin,
        new_asset_settings: {
          playback_policies: ['public'],
          passthrough: video.id, // <-- Hooray! This will come back in webhooks.
        },
      });

      // Now that we've successfully created our new direct upload on the Mux side
      // of things, let's update our internal asset to include details.
      const updatedVideo = await updateVideo(video.id, {
        status: 'waiting for upload',
        uploadId: upload.id,
        uploadUrl: upload.url,
      });

      // All that's left is to respond saying how successful we were.
      send(res, 201, updatedVideo);
    } catch (error) {
      console.error(error);
      send(res, 500, { error });
    }
  },
  { protected: true } // This just tells our `decorate` wrapper to use basic auth for this endpoint.
);
