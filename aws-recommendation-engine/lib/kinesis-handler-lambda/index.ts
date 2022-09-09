import * as path from "path";
import { PersonalizeEventsClient, PutItemsCommand, PutEventsCommand, PutUsersCommand } from "@aws-sdk/client-personalize-events";
import { loadSync } from "protobufjs";

// import Mux from "@mux/mux-node";
import { KinesisStreamEvent, Context } from "aws-lambda";
import IVideoView from "./VideoView";

const personalizeClient = new PersonalizeEventsClient({ region: "us-east-1" });
const protoFile = path.resolve(process.env.LAMBDA_TASK_ROOT as string, "video_view.proto")
const root = loadSync(protoFile)
const VideoView = root.lookupType("video_view.v1.VideoView");

exports.handler = async function (event: KinesisStreamEvent, context: Context): Promise<void> {
  await Promise.all(event.Records.map(async record => {
    try {
      const data = VideoView.decode(Buffer.from(record.kinesis.data, 'base64'));
      const view = VideoView.toObject(data);
      const { browser, country, latitude, longitude, assetId, viewerDeviceCategory, viewerUserId, sessionId, region } = view;

      const ts = Math.round(Date.now() / 1000)
      const userId = viewerUserId || "anonymous"

      /**
       * 1. Store the User
       */
      const userCommandResponse = await personalizeClient.send(
        new PutUsersCommand({
          datasetArn: process.env.USERS_DATASET_ARN,
          users: [{
            userId,
            properties: JSON.stringify({ subscriptionModel: "FREE" })
          }]
        })
      );

      console.log(userCommandResponse);

      /**
       * 2. Store the asset
       */
      const itemsResponse = await personalizeClient.send(
        new PutItemsCommand({
          datasetArn: process.env.ITEMS_DATASET_ARN,
          items: [{
            itemId: assetId,
            properties: JSON.stringify({ genres: "Mux", creationTimestamp: ts })
          }]
        })
      );

      console.log(itemsResponse);

      /**
       * 3. Store the interaction
       */
      const interactionResponse = await personalizeClient.send(
        new PutEventsCommand({
          sessionId,
          trackingId: "5c627ed6-9114-46ab-a5c2-2b362b8044c7", // Replace this with your own event tracking ID
          userId,
          eventList: [{
            eventType: "Watch",
            sentAt: new Date(),
            itemId: assetId,
            properties: JSON.stringify({ browser, country, latitude, longitude, viewerDeviceCategory, region })
          }]
        })
      );

      console.log(interactionResponse);

      // process data.
    } catch (error) {
      console.log(JSON.stringify(error, null, 2));
      // error handling.
    } finally {
      console.log('finally...')
    }
  }));
}
