const express = require('express');
const path = require('path');
const open = require('open');
const compression = require('compression');
const favicon = require('serve-favicon');
const sslRedirect = require('heroku-ssl-redirect');

/*eslint-disable no-console */

const port = process.env.PORT || 8000;
const app = express();

app.use(compression());
app.use(sslRedirect());
app.use(express.static('build'));
app.use(favicon(path.join(__dirname, 'favicon.ico')));

app.get('*', function(req, res) {
  res.sendFile(path.join(__dirname, '../build/index.html'));
});

app.listen(port, function(err) {
  if (err) {
    console.log(err);
  } else {
    open(`http://localhost:${port}`);
  }
});
