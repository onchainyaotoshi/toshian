import { ethers, upgrades, run } from "hardhat";

async function main() {
    const proxyAddress: string = "0xF351b67dDADd806044F9c46feFbEccd1A0d60491"; // Replace with your deployed proxy address

    const BlackjackV2 = await ethers.getContractFactory("BlackjackV3");
    console.log("Upgrading to BlackjackV3...");
    const upgraded = await upgrades.upgradeProxy(proxyAddress, BlackjackV2);
    console.log("Blackjack upgraded to:", await upgraded.getAddress());

    const newImplementationAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
    console.log("New implementation address:", newImplementationAddress);

    console.log("Verifying new implementation on Etherscan...");
    await run("verify:verify", {
        address: newImplementationAddress,
        constructorArguments: [],
    });

    console.log("Verification complete.");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });