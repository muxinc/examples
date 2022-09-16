import { Duration, Stack, StackProps, RemovalPolicy } from 'aws-cdk-lib';
import { Construct } from 'constructs';

import * as path from 'path';
import * as personalize from 'aws-cdk-lib/aws-personalize';

import * as s3 from 'aws-cdk-lib/aws-s3';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as nodelambda from 'aws-cdk-lib/aws-lambda-nodejs';
import * as lambdaEventSource from 'aws-cdk-lib/aws-lambda-event-sources'
import * as kinesis from 'aws-cdk-lib/aws-kinesis';

const MUX_AWS_ACCOUNT_ID = "910609115197";

export class MuxExampleAwsRecommendationsStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    /**
     * Upload historical data CSVs to this S3 Bucket
     */
    const bucket = new s3.Bucket(this, "mux-historical-data-bucket", {
      bucketName: "mux-historical-data-bucket",
      removalPolicy: RemovalPolicy.DESTROY,
    })

    /**
     * AWS Personalize resources
     */
    const datasetGroup = new personalize.CfnDatasetGroup(this, 'recommendation-dataset-group', {
      name: "MuxRecommendations",
      domain: "VIDEO_ON_DEMAND"
    });

    const usersSchema = new personalize.CfnSchema(this, 'users-schema', {
      name: "MuxUsers",
      domain: "VIDEO_ON_DEMAND",
      schema: JSON.stringify({
        "type": "record",
        "name": "Users",
        "namespace": "com.amazonaws.personalize.schema",
        "fields": [
          {
            "name": "USER_ID",
            "type": "string"
          },
          {
            "name": "SUBSCRIPTION_MODEL",
            "type": "string",
            "categorical": true
          },
        ],
        "version": "1.0"
      })
    })

    const interactionsSchema = new personalize.CfnSchema(this, 'interactions-schema', {
      name: "MuxInteractionsV3",
      domain: "VIDEO_ON_DEMAND",
      schema: JSON.stringify({
        "type": "record",
        "name": "Interactions",
        "namespace": "com.amazonaws.personalize.schema",
        "fields": [
          {
            "name": "USER_ID",
            "type": "string"
          },
          {
            "name": "ITEM_ID",
            "type": "string"
          },
          {
            "name": "BROWSER",
            "type": "string"
          },
          {
            "name": "COUNTRY",
            "type": "string"
          },
          {
            "name": "REGION",
            "type": "string"
          },
          {
            "name": "VIEWER_DEVICE_CATEGORY",
            "type": "string"
          },
          {
            "name": "LATITUDE",
            "type": "float"
          },
          {
            "name": "LONGITUDE",
            "type": "float"
          },
          {
            "name": "TIMESTAMP",
            "type": "long"
          },
          {
            "name": "EVENT_TYPE",
            "type": "string"
          }
        ],
        "version": "1.0"
      })
    })

    // https://docs.aws.amazon.com/personalize/latest/dg/item-dataset-requirements.html
    const itemsSchema = new personalize.CfnSchema(this, 'recommendation-schema', {
      name: "MuxItems",
      domain: "VIDEO_ON_DEMAND",
      schema: JSON.stringify({
        "type": "record",
        "name": "Items",
        "namespace": "com.amazonaws.personalize.schema",
        "fields": [
          {
            "name": "ITEM_ID",
            "type": "string"
          },
          {
            "name": "GENRES",
            "type": "string",
            "categorical": true
          },
          {
            "name": "CREATION_TIMESTAMP",
            "type": "long"
          }
        ],
        "version": "1.0"
      })
    });

    const interactionsDataset = new personalize.CfnDataset(this, 'recommendation-dataset', {
      datasetGroupArn: datasetGroup.ref,
      datasetType: "Interactions",
      name: "MuxInteractions",
      schemaArn: interactionsSchema.ref
    })

    const itemsDataset = new personalize.CfnDataset(this, 'recommendation-items-dataset', {
      datasetGroupArn: datasetGroup.ref,
      datasetType: "Items",
      name: "MuxItems",
      schemaArn: itemsSchema.ref
    })

    const usersDataset = new personalize.CfnDataset(this, 'recommendation-users-dataset', {
      datasetGroupArn: datasetGroup.ref,
      datasetType: "Users",
      name: "MuxUsers",
      schemaArn: usersSchema.ref
    })

    /**
     * Note: Recommenders aren't currently supported by cloudformation.
     * https://docs.aws.amazon.com/personalize/latest/dg/VIDEO_ON_DEMAND-use-cases.html
     */

    /**
     * Kinesis stream for Mux Data
     */
    const muxDataStream = new kinesis.Stream(this, 'MuxDataStream', {
      streamName: 'mux-data-stream',
      streamMode: kinesis.StreamMode.ON_DEMAND
    });

    /**
     * Kinesis role. Get the external ID value from your Mux dashboard.
     */
    const kinesisRole = new iam.Role(this, "mux-kinesis-role", {
      assumedBy: new iam.AccountPrincipal(MUX_AWS_ACCOUNT_ID),
      externalIds: [process.env.MUX_STREAMING_EXPORTS_EXTERNAL_ID as string],
      description: `This role provides the Mux external AWS account access to our AWS account in order to write view data to our Kinesis stream`
    });

    kinesisRole.addToPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          "kinesis:ListShards",
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ],
        resources: [muxDataStream.streamArn],
      })
    );

    /**
     * Role for AWS Kinesis Handler Lambda
     */
    const kinesisHandlerRole = new iam.Role(this, "mux-kinesis-lambdarole", {
      assumedBy: new iam.ServicePrincipal("lambda.amazonaws.com"),
    });

    kinesisHandlerRole.addToPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          "iam:PassRole",
          "personalize:*",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        resources: ["*"],
      })
    );

    /**
     * Kinesis Stream handler function
     */

    const kinesisHandler = new nodelambda.NodejsFunction(this, 'mux-kinesis-function', {
      entry: path.join(__dirname, 'kinesis-handler-lambda/index.ts'),
      bundling: {
        preCompilation: true,
        commandHooks: {
          beforeBundling(inputDir: string, outputDir: string): string[] {
            return [`cp ${inputDir}/lib/kinesis-handler-lambda/video_view.proto ${outputDir}/video_view.proto`];
          },
          beforeInstall(inputDir: string, outputDir: string): string[] {
            return [`cp ${inputDir}/lib/kinesis-handler-lambda/video_view.proto ${outputDir}/video_view.proto`];
          },
          afterBundling(inputDir: string, outputDir: string): string[] {
            return [];
          },
        }
      },
      timeout: Duration.seconds(300),
      role: kinesisHandlerRole,
      environment: {
        ITEMS_DATASET_ARN: itemsDataset.attrDatasetArn,
        USERS_DATASET_ARN: usersDataset.ref,
        PERSONALIZE_TRACKING_ID: process.env.PERSONALIZE_TRACKING_ID as string // Replace this with your own event tracking ID
      },
    });

    /**
     * Attach the Kinesis stream to the lambda handler
     */
    kinesisHandler.addEventSource(
      new lambdaEventSource.KinesisEventSource(muxDataStream, {
        startingPosition: lambda.StartingPosition.TRIM_HORIZON
      })
    )

    /**
     * Recommendation lambda - we'll add an unprotected function URL endpoint for demonstration purposes, but
     * it's possible and perhaps ideal to set up an authorizer that verifies the logged-in user's
     * identity before invoking the function via an HTTP request.
     */
    const recommendLambda = new nodelambda.NodejsFunction(this, 'mux-recommend-function', {
      entry: path.join(__dirname, 'recommend-lambda/index.ts'),
      bundling: {
        preCompilation: true,
      },
      timeout: Duration.seconds(10),
      role: kinesisHandlerRole,
      environment: {
        ITEMS_DATASET_ARN: itemsDataset.attrDatasetArn,
        USERS_DATASET_ARN: usersDataset.ref
      }
    });

    recommendLambda.addFunctionUrl({
      authType: lambda.FunctionUrlAuthType.NONE,
      cors: {
        // Allow this to be called from websites on https://example.com.
        // Can also be ['*'] to allow all domain.
        allowedOrigins: ['https://example.com'],
        // More options are possible here, see the documentation for FunctionUrlCorsOptions
      },
    });
  }
}
