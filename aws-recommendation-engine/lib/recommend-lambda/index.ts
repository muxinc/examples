import { PersonalizeRuntimeClient, GetRecommendationsCommand, PredictedItem } from "@aws-sdk/client-personalize-runtime";

import { APIGatewayEvent, Context } from "aws-lambda";
const personalizeClient = new PersonalizeRuntimeClient({ region: process.env.AWS_REGION });

const MOST_POPULAR_RECOMMENDER = "arn:aws:personalize:::recipe/aws-vod-most-popular";
const BECAUSE_YOU_WATCHED_X_RECOMMENDER = "arn:aws:personalize:::recipe/aws-vod-because-you-watched-x";
const TOP_PICKS_FOR_YOU_RECOMMENDER = "arn:aws:personalize:::recipe/aws-vod-top-picks";

exports.handler = async function (event: APIGatewayEvent, context: Context): Promise<PredictedItem[]> {
  try {

    const userId = event.queryStringParameters?.viewerUserId || "anonymous"
    const assetId = event.queryStringParameters?.assetId || "anonymous"

    const response = await personalizeClient.send(
      new GetRecommendationsCommand({
        userId,
        itemId: assetId,
        recommenderArn: MOST_POPULAR_RECOMMENDER, // change this out with the ARN representing your desired recommendation strategy
        context: {}
      })
    );

    return response.itemList || [];

    // process data.
  } catch (error) {
    console.log(JSON.stringify(error, null, 2));
    // error handling.
  }

  return [];
}
