const fs = require('fs');

module.exports = (app, io) => {
  app.get('/', (req, res) => res.send('/GET video!'));

  // Route initializations
  fs.readdirSync(__dirname).forEach((file) => {
    if (file === 'index.js') return;
    const name = file.substr(0, file.indexOf('.'));
    require('./' + name)(app, io);
  });
};
