import { ethers, upgrades } from "hardhat";

async function main() {
    const BettingContractAddress: string = "0xF724D4A627d683Ee46c70B86d87a9cc0f933f564";

    const Blackjack = await ethers.getContractFactory("Blackjack");
    console.log("Deploying Blackjack...");
    const blackjack = await upgrades.deployProxy(Blackjack, [BettingContractAddress], { initializer: 'initialize' });
    await blackjack.deployed();
    console.log("Blackjack deployed to:", blackjack.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });