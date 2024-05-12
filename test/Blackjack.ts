import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";

describe("Blackjack", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deploy() {
    const CA_BETTING = "0xF724D4A627d683Ee46c70B86d87a9cc0f933f564";

    // Contracts are deployed using the first signer/account by default
    const [owner] = await hre.ethers.getSigners();

    const Blackjack = await hre.ethers.getContractFactory("Blackjack");
    const blackjack = await Blackjack.deploy(CA_BETTING);

    return { blackjack, owner, CA_BETTING };
  }

  describe("Deployment", function () {
    it("Should set the right CA betting", async function () {
      const { blackjack, CA_BETTING } = await loadFixture(deploy);

      expect(await blackjack.bettingContract()).to.equal(CA_BETTING);
    });
  });
});
