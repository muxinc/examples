# Mux AWS recommendation engine example

This repository contains an example implementation of how you can set up Mux streaming exports and Amazon Personalize to build your own content recommendation engine.

For a detailed walkthrough on how you can use this repository, check out the [corollary blog post](https://mux.com/blog/amazon-personalize-video-recommendation-engine) over on the Mux blog.
## Useful commands

* `npm run build`   compile typescript to js
* `npm run watch`   watch for changes and compile
* `npm run test`    perform the jest unit tests
* `cdk deploy`      deploy this stack to your default AWS account/region
* `cdk diff`        compare deployed stack with current state
* `cdk synth`       emits the synthesized CloudFormation template
## References and resources
* https://docs.aws.amazon.com/general/latest/gr/personalize.html
* https://github.com/aws-samples/amazon-personalize-ingestion-pipeline
* https://github.com/CloudedThings/100-Days-in-Cloud/blob/main/Labs/80-Amazon-Rekognition-CDK-deployed/index.py
* https://github.com/aws-samples/amazon-rekognition-large-scale-processing
* https://docs.aws.amazon.com/personalize/latest/dg/recording-events.html#event-record-api
* https://docs.aws.amazon.com/personalize/latest/dg/API_UBS_PutItems.html
* https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/clients/client-personalize-events/classes/putitemscommand.html
