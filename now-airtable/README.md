# Personal Video CMS

Minimal personal video CMS using your own Airtable as the backend. From the user's perspective, this app allows you to:

- Upload videos via a password-protected route.
- Share a public list of all assets via their title and a thumbnail.
- View individual videos.

There are no management routes for deleting or editing assets, but you should just be going straight to your Airtable base for that!

## What you'll need to deploy this:

- A copy of the [Airtable template](https://airtable.com/universe/expKKXTgmWJ76BmVL/airtable-personal-video-cms).
- Your Airtable API key and base ID from above.
- A Zeit account and their command line tool.
- Mux Access Token.

## Deploying your own

1. Go copy the [Airtable template](https://airtable.com/universe/expKKXTgmWJ76BmVL/airtable-personal-video-cms).
2. Rename the `.env.example` `.env`
   ```shell
   $ mv .env.example .env
   ```
3. Update the `MANAGEMENT_PASSWORD` to be something random. You'll need to provide this password to upload new videos.
4. Get your Airtable API key and base ID. I personally like to go to the docs and get them from the example.
   ![airtable API values.](https://mmcc-screenshots.s3.amazonaws.com/Airtable_API_-_Zeit_Personal_CMS_2019-02-12_22-09-48.png)

   Update values in `.env` for `AIRTABLE_API_KEY` and `AIRTABLE_BASE` to match.

5. Go generate a new [Mux Asset Token](https://dashboard.mux.com/settings/access-tokens) and update the `MUX_TOKEN_ID` and `MUX_TOKEN_SECRET` values in `.env` to match.
6. Deploy!

   ```shell
   $ yarn deploy
   ```

7. **Optional**: If you want to run the UI locally, add the URL provided from the step above to your `.env` file as `BASE_URL`.

## Mux features used

- [Direct Uploads](https://docs.mux.com/v1/docs/direct-upload)
- [Thumbnails](https://docs.mux.com/docs/thumbnail-guide)
- [Webhooks](https://docs.mux.com/docs/webhooks)
- [Playback](https://docs.mux.com/docs/playback)

## Tools

- [Airtable](https://airtable.com)
- [Zeit Now](https://zeit.co/now)
- [Next.js](https://nextjs.org)
