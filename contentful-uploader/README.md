![Contentful + Mux](https://banner-generator-cj08cfagy.now.sh/?text=Contentful)

# Contentful Video Streaming Plugin

A Contentful UI extension that makes it simple to add beautiful streaming via [Mux](https://https://mux.com) to your [Contentful](https://contentful.com) project. Just install the extension, add the component to your content model, and you're good to go! 🙌🏾

## Install via the CLI

Make sure you have the Contentful CLI installed:

```
npm install contentful-cli -g
```

You are logged in:

```
contentful login
```

And have a space selected:

```
contentful space use
```

To install the UI Extension:

```
contentful extension create
```

To update the UI Extension:

```
contentful extension update --force
```

Note: by default this installs the hosted version of our extension. If you'd like to self-host this extension, you may update `extension.json` to use your own `src`, but keep in mind you'll need to have your own solution for handling CORS requests.
