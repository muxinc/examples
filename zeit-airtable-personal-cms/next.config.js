// next.config.js
module.exports = {
  exportPathMap: async function(defaultPathMap) {
    console.log(defaultPathMap);
    return {
      '/': { page: '/' },
      '/foo': { page: '/show.js' },
    };
  },
};
