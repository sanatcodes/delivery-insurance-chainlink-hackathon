const hre = require("hardhat");

async function main() {

  const PARCELSURE = await hre.ethers.getContractFactory("Parcelsure");
  const parcelSure = await Parcelsure.deploy();

  await parcelSure.deployed();

  console.log("Parcelsure deployed to:", parcelSure.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
