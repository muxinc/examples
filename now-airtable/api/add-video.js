const { json, send } = require('micro');
const { createVideo, updateVideo } = require('../utils/airtable');
const decorate = require('../utils/decorate');
const Mux = require('@mux/mux-node');

const { Video } = new Mux();

module.exports = decorate(
  async (req, res) => {
    const params = await json(req);

    const videoParams = {
      title: params.title,
      description: params.description,
    };

    const video = await createVideo(videoParams);

    try {
      const upload = await Video.Uploads.create({
        cors_origin: req.headers.origin,
        new_asset_settings: {
          playback_policies: ['public'],
          passthrough: video.id,
        },
      });

      const updatedVideo = await updateVideo(video.id, {
        status: 'waiting for upload',
        uploadId: upload.id,
        uploadUrl: upload.url,
      });

      send(res, 201, updatedVideo);
    } catch (error) {
      console.error(error);
      send(res, 500, { error });
    }
  },
  { protected: true }
);
