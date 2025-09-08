import { defineAction } from 'astro:actions';
import { z } from 'astro/zod';
import mux from '../lib/mux';

export const server = {
  getAssetForUpload: defineAction({
    accept: 'form',
    input: z.object({
      uploadId: z.string(),
    }),
    handler: async ({ uploadId }) => {
      // when the upload is complete,
      // the upload will have an assetId associated with it
      // we'll use that assetId to view the video status
      const upload = await mux.video.uploads.retrieve(uploadId);
      console.log({ uploadId, upload });
      if (upload.asset_id) {
        return { assetId: upload.asset_id };
      }

      // while onSuccess is a strong indicator that Mux has received the file
      // and created the asset, this isn't a guarantee.
      // In production, you might write an api route
      // to listen for the`video.upload.asset_created` webhook
      // https://docs.mux.com/guides/listen-for-webhooks
      // However, to keep things simple here,
      // we'll just ask the user to push the button again.
      // This should rarely happen.
      return { message: 'Upload has no asset yet. Try again.' };
    },
  }),
};
