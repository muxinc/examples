const { json, send } = require('micro');
const { getVideo, updateVideo } = require('../utils/airtable');

module.exports = async (req, res) => {
  // We'll grab the request body again, this time grabbing the event
  // type and event data so we can easily use it.
  const { type: eventType, data: eventData } = await json(req);

  switch (eventType) {
    case 'video.asset.created': {
      // This means an Asset was successfully created! We'll get
      // the existing item from the DB first, then update it with the
      // new Asset details
      const item = await getVideo(eventData.passthrough);
      // Just in case the events got here out of order, make sure the
      // asset isn't already set to ready before blindly updating it!
      if (item.status !== 'ready') {
        await updateVideo(item.id, {
          status: 'processing',
        });
      }
      break;
    }
    case 'video.asset.ready': {
      // This means an Asset was successfully created! This is the final
      // state of an Asset in this stage of its lifecycle, so we don't need
      // to check anything first.
      await updateVideo(eventData.passthrough, {
        status: 'ready',
        assetId: eventData.id,
        playbackId: eventData.playback_ids[0].id,
      });
      break;
    }
    case 'video.upload.cancelled': {
      // This fires when you decide you want to cancel an upload, so you
      // may want to update your internal state to reflect that it's no longer
      // active.
      await updateVideo(eventData.passthrough, { status: 'cancelled' });
      break;
    }
    default:
      // Mux sends webhooks for *lots* of things, but we'll ignore those for now
      console.log('some other event!', eventType, eventData);
  }

  console.log('Mux Event Handled');
  // Now send back that ID and the upload URL so the client can use it!
  send(res, 200, 'Thanks for the webhook, Mux!');
};
