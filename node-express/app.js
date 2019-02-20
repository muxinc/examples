require('dotenv').config();
const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');
const bodyParser = require('body-parser');
const logger = require('morgan');
const mustacheExpress = require('mustache-express');
const session = require('express-session');
const fs = require('fs');
const debug = require('debug')('nabber-express-server:server');
const cors = require('cors');
const auth = require('./auth/auth');
const { createServer } = require('http');
const io = require('socket.io');
const compression = require('compression');

const port = '3000';

// Private functions
function onError(error) {
  if (error.syscall !== 'listen') {
    throw error;
  }

  const bind = typeof port === 'string'
    ? 'Pipe ' + port
    : 'Port ' + port;

  // handle specific listen errors with friendly messages
  switch (error.code) {
    case 'EACCES':
      console.error(bind + ' requires elevated privileges');
      process.exit(1);
      break;
    case 'EADDRINUSE':
      console.error(bind + ' is already in use');
      process.exit(1);
      break;
    default:
      throw error;
  }
}

/**
 * Event listener for HTTP server "listening" event.
 */

function onListening() {
  const addr = this.server.address();
  const bind = typeof addr === 'string'
    ? 'pipe ' + addr
    : 'port ' + addr.port;
  debug('Listening on ' + bind);
}

class App {
  constructor() {
    this.PORT = 3000;
    this.userRooms = [];

    this.createApp();
    this.setCors();
    this.config();
    this.createServer();
    this.sockets();
    this.routes();
    this.errorHandlers();
    this.listen();
  }

  setCors() {
    const corsOptions = {
      origin: true,
      credentials: true
    };
    this.app.use(cors(corsOptions));
  }

  createApp() {
    this.app = express();
    this.app.use(session({
      secret: process.env.SESSION_KEY,
      resave: true,
      saveUninitialized: true,
    }));
    this.app.use(cookieParser());
    this.app.use(bodyParser.json());
    this.app.use(bodyParser.urlencoded({ extended: true }));

    // Logging - @TODO:// comment this out before it goes to production
    const accessLogStream = fs.createWriteStream(path.join(__dirname, 'access.log'), { flags: 'a' });
    this.app.use(logger('combined', { stream: accessLogStream }));

    // Passport/session initialization
    this.app.use(auth.passport.initialize());
    this.app.use(auth.passport.session());

    // view engine setup
    this.app.engine('mustache', mustacheExpress());
    this.app.set('views', path.join(__dirname, 'views'));
    this.app.set('view engine', 'mustache');
  }

  createServer() {
    this.server = createServer(this.app);
  }

  config() {
    this.port = process.env.PORT || this.PORT;
    this.app.use(compression());
  }

  errorHandlers() {
    // development error handler
    // will print stacktrace
    if (this.app.get('env') === 'development') {
      this.app.use((err, req, res, next) => {
        res.status(err.status || 500);
        res.send({message: err});
      });
    }

    // production error handler
    // no stacktraces leaked to user
    this.app.use((err, req, res, next) => {
      res.status(err.status || 500);
      res.send({message: err});
    });

    // catch 404 and forward to error handler
    this.app.use((req, res, next) => {
      const err = new Error('Not Found');
      err.status = 404;
      next(err);
    });
  }

  sockets() {
    this.io = io(this.server);
  }

  routes() {
    require('./routes')(this.app, this.io);
  }

  listen() {
    this.server.on('error', onError);
    this.server.on('listening', onListening.bind(this));
    this.server.listen(this.port, () => {
      console.log('Running server on port %s', this.port);
    });

    // Web Sockets
    this.io.on('connect', (socket) => {
      console.log('Connected client on port %s.', this.port);
      socket.on('message', (m) => {
        console.log('[server](message): %s', JSON.stringify(m));
        this.io.emit('message', m);
      });

      socket.on('user_join', (userId) => {
        console.log('user joined', userId);
        socket.join(userId);
      });

      socket.on('disconnect', () => {
        console.log('Client disconnected');
      });
    });
  }
}

module.exports = new App();
