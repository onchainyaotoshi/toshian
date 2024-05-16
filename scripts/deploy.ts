import { ethers, upgrades, run } from "hardhat";

async function main() {
    const BettingContractAddress: string = "0xF724D4A627d683Ee46c70B86d87a9cc0f933f564";

    const Blackjack = await ethers.getContractFactory("Blackjack");
    console.log("Deploying Blackjack...");
    const blackjack = await upgrades.deployProxy(Blackjack, [BettingContractAddress], { initializer: 'initialize' });
    console.log("Blackjack proxy deployed to:", await blackjack.getAddress());

    const implementationAddress = await upgrades.erc1967.getImplementationAddress(await blackjack.getAddress());
    console.log("Blackjack implementation deployed to:", implementationAddress);

    console.log("Verifying Blackjack proxy on Etherscan...");
    await run("verify:verify", {
        address: await blackjack.getAddress(),
        constructorArguments: [],
    });

    console.log("Verifying Blackjack implementation on Etherscan...");
    await run("verify:verify", {
        address: implementationAddress,
        constructorArguments: [],  // No constructor arguments for implementation contract
    });

    console.log("Verification complete.");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
