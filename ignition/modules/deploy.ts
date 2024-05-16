import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

// TESTER ADDR - 0xeDb04043CA476d3E7A074b4348078CAcfcfF2f90
// TYBG - 0x0d97F261b1e88845184f678e2d1e7a98D9FD38dE
// TOSHI - 0xac1bd2486aaf3b5c0fc3fd868558b082a531b2b4

// amount of 1M toshian token - 1000000000000000000000000
// amount of 1K toshian token - 1000000000000000000000
// BlackjackModule#ToshianToken - 0xe35A7b98Ec49BEA2Fe5218F886b4c5404b3DAaF8
// BlackjackModule#ERC20Betting - 0xF724D4A627d683Ee46c70B86d87a9cc0f933f564
// BlackjackModule#Blackjack proxy - 0xF351b67dDADd806044F9c46feFbEccd1A0d60491
// BlackjackModule#Blackjack impl v1 - 0x5D1376F28A1153101ca705DB0BF8d459359EAA39
// BlackjackModule#Blackjack impl v2 - 0xC73e96ac1ED8070480e85B4ff290Aeea5cAFEE01
// BlackjackModule#Blackjack impl v3 - 0x96aA7F5fD1e7dC26d404E5CaFDe62C506fC329C5

const BlackjackModule = buildModule("BlackjackModule", (m) => {
  // Deploy the ToshianToken contract
  // const toshianToken = m.contract("ToshianToken", []);

  // Deploy the ERC20Betting contract with the ToshianToken address as a parameter
  // const erc20Betting = m.contract("ERC20Betting", ["0xe35A7b98Ec49BEA2Fe5218F886b4c5404b3DAaF8"]);
  
  // Deploy the ERC20Betting contract with the ToshianToken address as a parameter
  // const blackjack = m.contract("Blackjack", ["0xF724D4A627d683Ee46c70B86d87a9cc0f933f564"]);

  // return { blackjack};

  const blackjackFactory = m.contract('Blackjack', ["0xF724D4A627d683Ee46c70B86d87a9cc0f933f564"]);
  const blackjackDeploy = m.call(blackjackFactory,"deploy");
  const blackjackCA = m.readEventArgument(blackjackDeploy,"Deployed","addr");
  const deployWithFactory = m.contractAt("DeployedWithFactory",blackjackCA);

  return {
    blackjackFactory,
    deployWithFactory
  }
});

export default BlackjackModule;
