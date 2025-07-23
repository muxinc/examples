# Live stream latest thumbnail demos

A couple of small demos, which use the OpenAI APIs to poll the latest thumbnail of a live stream, and analyse its contents, or moderate the content.

## Dependencies

* You'll need an OpenAI API key set in your environment as `OPENAI_API_KEY`
* Dependencies are managed via npm, so don't forget to run `npm install`
* You'll want to edit `tags.js` and `moderate.js` to set your live stream playback ID

## Running

### Generate tags and summarise

```
npm run tags
```

### Moderate

```
npm run moderate
```

## License

[MIT](LICENSE.md)
