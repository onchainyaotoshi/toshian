import { ethers, upgrades } from "hardhat";

async function main() {
    const proxyAddress: string = "YOUR_PROXY_ADDRESS_HERE"; // Replace with your deployed proxy address

    const BlackjackV2 = await ethers.getContractFactory("BlackjackV2");
    console.log("Upgrading to BlackjackV2...");
    const upgraded = await upgrades.upgradeProxy(proxyAddress, BlackjackV2);
    console.log("Blackjack upgraded to:", upgraded.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });