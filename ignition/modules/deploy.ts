import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

// TESTER ADDR - 0xbE0615500729761430Fc430aD6313025d7b059bc
// TYBG - 0x0d97F261b1e88845184f678e2d1e7a98D9FD38dE
// TOSHI - 0xac1bd2486aaf3b5c0fc3fd868558b082a531b2b4

// BlackjackModule#ToshianToken - 0xe35A7b98Ec49BEA2Fe5218F886b4c5404b3DAaF8
// BlackjackModule#ERC20Betting - 0xF724D4A627d683Ee46c70B86d87a9cc0f933f564
// BlackjackModule#Blackjack - 0x6cC84CD47501d3338e594831e1d81f640CD873cc

const BlackjackModule = buildModule("BlackjackModule", (m) => {
  // Deploy the ToshianToken contract
  // const toshianToken = m.contract("ToshianToken", []);

  // Deploy the ERC20Betting contract with the ToshianToken address as a parameter
  // const erc20Betting = m.contract("ERC20Betting", ["0xe35A7b98Ec49BEA2Fe5218F886b4c5404b3DAaF8"]);
  
  // Deploy the ERC20Betting contract with the ToshianToken address as a parameter
  const blackjack = m.contract("Blackjack", ["0xF724D4A627d683Ee46c70B86d87a9cc0f933f564"]);

  return { blackjack};
});

export default BlackjackModule;
