const pm2 = require("@buidl3/pm2").default;
const { getModules, appify, env } = pm2;

const modules = getModules();
module.exports = {
  apps: [...modules.map(appify)],
  deploy: {
    env: {
      ...env(),
    },
  },
};
