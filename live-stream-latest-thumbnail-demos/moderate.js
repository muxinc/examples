import OpenAI from "openai";

if (!process.env.OPENAI_API_KEY) {
  console.error("OPENAI_API_KEY environment variable is not set.");
  process.exit(1);
}

const openaiClient = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

async function moderateLiveStream(playbackId) {

  const imageUrl = `https://image.mux.com/${playbackId}/thumbnail.jpg?latest=true&width=640`;

  console.log(`Analyzing live stream thumbnail at: ${imageUrl}`);

  try {
    const moderation = await openaiClient.moderations.create({
      model: "omni-moderation-latest",
      input: [
        {
          type: "image_url",
          image_url: {
            url: imageUrl,
          },
        },
      ],
    });

    if (moderation.results[0].flagged) {
      console.warn("Image flagged for moderation.");
      console.log(`Sexual: ${moderation.results[0].category_scores.sexual}, Violence: ${moderation.results[0].category_scores.violence}`);
    }

  } catch (error) {
    console.error("Live stream moderation failed:", error);
  }
}

const playbackId = "rYlMNPt02YwWOVcueajlx01WNdqpC58Nqp";

// Run at first startup
await moderateLiveStream(playbackId);

// And every 15 seconds thereafter
setInterval(() => {
  moderateLiveStream(playbackId);
}, 15000);
