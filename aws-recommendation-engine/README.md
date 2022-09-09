# Welcome to your CDK TypeScript project

This is a blank project for CDK development with TypeScript.

The `cdk.json` file tells the CDK Toolkit how to execute your app.

## Useful commands

* `npm run build`   compile typescript to js
* `npm run watch`   watch for changes and compile
* `npm run test`    perform the jest unit tests
* `cdk deploy`      deploy this stack to your default AWS account/region
* `cdk diff`        compare deployed stack with current state
* `cdk synth`       emits the synthesized CloudFormation template


## Importing incremental items to AWS Personalize
List of endpoints: https://docs.aws.amazon.com/general/latest/gr/personalize.html

Can use the Node SDK: https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/clients/client-personalize-events/classes/putitemscommand.html


https://docs.aws.amazon.com/personalize/latest/dg/API_UBS_PutItems.html

```js
  // https://personalize-events.us-east-1.amazonaws.com/items
  POST /items HTTP/1.1
  Content-type: application/json

  {
    "datasetArn": "string",
    "items": [ 
        { 
          "itemId": "string",
          "properties": "string"
        }
    ]
  }
```

## Personalization ingest example pipeline w/ kinesis

https://github.com/aws-samples/amazon-personalize-ingestion-pipeline

## References

https://github.com/aws-samples/amazon-personalize-ingestion-pipeline
https://github.com/CloudedThings/100-Days-in-Cloud/blob/main/Labs/80-Amazon-Rekognition-CDK-deployed/index.py
https://github.com/aws-samples/amazon-rekognition-large-scale-processing
https://docs.aws.amazon.com/personalize/latest/dg/recording-events.html#event-record-api