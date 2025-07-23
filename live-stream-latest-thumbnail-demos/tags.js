import OpenAI from "openai";
import { z } from "zod";
import { zodTextFormat } from "openai/helpers/zod";

if (!process.env.OPENAI_API_KEY) {
  console.error("OPENAI_API_KEY environment variable is not set.");
  process.exit(1);
}

const openaiClient = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

const schema = z.object({
  keywords: z.array(z.string()).max(10),
  summary: z.string().max(500)
});

async function analyzeLiveStream(playbackId) {

  const imageUrl = `https://image.mux.com/${playbackId}/thumbnail.jpg?latest=true&width=640`;

  console.log(`Analyzing live stream thumbnail at: ${imageUrl}`);

  try {
    const response = await openaiClient.responses.parse({
      model: "gpt-4.1-mini",
      input: [
        {
          role: "system",
          content:
            "You are an image analysis tool. You will be given an image, and be expected to return structured data about the contents.",
        },
        {
          role: "user",
          content: [
            {
              type: "input_text",
              text: "What's in this image? Return a list of around 10 single words, and a summary of the image in 500 characters or less. Be sassy in the summary.",
            },
            {
              type: "input_image",
              image_url: imageUrl,
            },
          ],
        },
      ],
      text: {
        format: zodTextFormat(schema, "tags"),
      },
    });

    console.log(response.output_parsed);
  } catch (error) {
    console.error("Live stream analysis failed:", error);
  }
}

const playbackId = "rYlMNPt02YwWOVcueajlx01WNdqpC58Nqp";

// Run at first startup
await analyzeLiveStream(playbackId);

// And every 15 seconds thereafter
setInterval(() => {
  analyzeLiveStream(playbackId);
}, 15000);
