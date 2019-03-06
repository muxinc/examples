# Mux Example Express API
This is the server-side API portion of a project intended to illustrate the the use of Mux's video API. This project is not intended for production use nor is it intended to dictate how you should use Mux in your production application. The purpose of this project is to show how you _could_ use Mux in a Node Express based CMS web application using signed S3 urls and a React client.

This project uses the following technologies:

* Node
* Express
* Knex
* PostgresSQL
* Google OAuth2
* Passport
* Node AWS-SDK
* Request
* Socket-IO

## Prerequisites

### Mux Account
* You will need a Mux account with video access in order to use Mux to encode your uploaded videos.
* Go to https://dashboard.mux.com/signup?type=video to create an account with video access.
* After creating an account, create an Access Token. https://dashboard.mux.com/settings/access-tokens
* Consult the offical Mux docs for using Mux video. https://docs.mux.com/docs

### PostgresSQL
* Download PostgresSQL if you do not already have it. https://www.postgresql.org/download/
* PostgresSQL must first be installed. https://www.postgresql.org/docs/9.3/static/tutorial-install.html

### AWS S3
We are going to generate AWS S3 signed urls to allow for our React client project to upload user videos.
* You must have an AWS account with S3 access. https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html
* Make sure you have access to S3 and setup a bucket for this project. https://aws.amazon.com/s3/
* Within the `Permissions` section, you will want to add this `CORS Rule` in the `CORS configuration editor`: `<AllowedOrigin>http://localhost:8000</AllowedOrigin>` for your S3 bucket.
An Example CORS configuration might look like this:
```
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<CORSRule>
    <AllowedOrigin>http://localhost:8000</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
    <AllowedMethod>PUT</AllowedMethod>
    <AllowedMethod>POST</AllowedMethod>
    <AllowedMethod>DELETE</AllowedMethod>
    <MaxAgeSeconds>3000</MaxAgeSeconds>
    <ExposeHeader>ETag</ExposeHeader>
    <AllowedHeader>Authorization</AllowedHeader>
    <AllowedHeader>*</AllowedHeader>
</CORSRule>
</CORSConfiguration>
```

### Google OAuth2
This example CMS uses Google OAuth2 to authenticate users.
* First, configure your application with Google. https://support.google.com/cloud/answer/6158849?hl=en
* Use `http://localhost:8000` for the authorized Javascript origin.
* Use `http://localhost:3000/auth/google/callback` for the authorized callback.

### Configuration
We will be using the `dotenv` dependancy to configure our environment variables. https://github.com/motdotla/dotenv
* Go to the root directory and create `.env` file.
* Create environment variables for `GOOLE_CLIENT`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_CALLBACK`, `SESSION_KEY`, `AWS_ACCESS_KEY`, `AWS_SECRET_KEY`, `MUX_ACCESS_TOKEN`, `MUX_SECRET`, and `NODE_ENV`.
* An example `.env` file would look like:
```
GOOGLE_CLIENT_ID=someid
GOOGLE_CLIENT_SECRET=somesecret
GOOGLE_CALLBACK=http://localhost:3000/auth/google/callback
SESSION_KEY=mux_example_project
AWS_ACCESS_KEY=somekey
AWS_SECRET_KEY=somesecretskey
MUX_ACCESS_TOKEN=muxaccesstoken
MUX_SECRET=muxsecret
NODE_ENV=development
DATABASE_URL=someproductiondatabaseurl
```
* Next, open the `config.js` file located in the `config` directory.
* Edit the configuration in this file with your specific configurations for `s3_url`, `client_oauth_redirect`, `client_oauth_failure_redirect`, `aws_region`, and `s3_bucket_name`.

## Installation
* Make sure you have PostgresSQL installed. Type `which psql` in your command line terminal to see if you alreay have it installed.
* Clone this project and use the `yarn install` command in the root directory.
* After all of the dependancies have successfully installed and your configurations have been set, use the `yarn start` command in the root directory.
* Go to `localhost:3000` in your browser to make sure it is successfully running. You should see the text: `/GET video!`.
