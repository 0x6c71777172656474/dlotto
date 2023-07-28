import { expect } from "chai";
import { ethers } from "hardhat";
import { Lottery, Lottery__factory, MockERC20 } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ContractReceipt, ContractTransaction, BigNumber } from "ethers";
import { ONE_WEEK } from "../scripts/constants";

describe("Lottery contract", async () => {
  let owner: SignerWithAddress;
  let user: SignerWithAddress;
  let lottery: Lottery;

  beforeEach(async () => {
    [, owner, user] = await ethers.getSigners();
    const Lottery: Lottery__factory = await ethers.getContractFactory(
      "Lottery"
    );
    lottery = await Lottery.deploy();
    await lottery.deployed();
  });

  context("📋 Lottery creation", async () => {
    it("Should create new lottery", async () => {
      let tx: ContractTransaction = await lottery.createLottery(
        1,
        100,
        1,
        false,
        ONE_WEEK
      );
      let receipt: ContractReceipt = await tx.wait();
      console.log(await lottery.lotteryInfo(1));
    });
  });
});
