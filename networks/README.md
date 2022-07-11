# Example network configuration

```js
const { Config } = require("@buidl3/core");
const { Network, Chain, Hardfork, getNetworkEnv } = Config;

const env = getNetworkEnv();
const network = new Network({
  chain: Chain.Mainnet,
  Hardfork: Hardfork.London,

  ethers: {
    nodeUrl: "ETH NODE URL",
  },
  p2p: {},
});

module.exports = network;
```
