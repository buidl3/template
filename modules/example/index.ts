import { Buidl3, Contract } from "@buidl3/core";

const contract = Contract.create("WETH")
  .setAddress("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
  .build();

async function run() {
  const web3 = await Buidl3.create();
  const { db, provider } = web3;

  try {
    await db.attach(contract);
  } catch (error) {
    console.log(error);
  }

  console.log(contract);
}

run();
