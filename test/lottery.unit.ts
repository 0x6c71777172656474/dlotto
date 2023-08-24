import { expect } from "chai";
import { ethers } from "hardhat";
import {
  Lottery,
  Lottery__factory,
  MockERC20,
  RandomNumbersGenerator,
  RandomNumbersGenerator__factory,
  VRFCoordinatorV2Mock,
} from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ContractReceipt, ContractTransaction, BigNumber } from "ethers";
import { ONE_WEEK, ROLES } from "../scripts/constants";
import { COORDINATOR_ADDRESS } from "../scripts/constants";
import { toWei18 } from "../scripts/common";
import { deployTest } from "../scripts/deploy/deployTest";

describe("Lottery contract", async () => {
  let owner: SignerWithAddress;
  let user: SignerWithAddress;
  let lottery: Lottery;
  let randomizer: RandomNumbersGenerator;
  let erc20: MockERC20;
  let testDeploy: any;

  beforeEach(async () => {
    [owner, user] = await ethers.getSigners();

    testDeploy = await deployTest();
    randomizer = testDeploy.randomizer;

    const ERC20 = await ethers.getContractFactory("MockERC20");
    erc20 = await ERC20.deploy("KOIN", "KN", 18);
    await erc20.deployed();

    const Lottery: Lottery__factory = await ethers.getContractFactory(
      "Lottery"
    );
    lottery = await Lottery.deploy(randomizer.address);
    await lottery.deployed();
  });

  context("📋 Lottery creation", async () => {
    it("Should create new lottery", async () => {
      await erc20.connect(owner).mint(user.address, toWei18("1000"));
      await erc20.connect(user).approve(lottery.address, toWei18("1000"));
      await lottery.connect(user).grantLotteryCreatorRole(erc20.address);

      let tx: ContractTransaction = await lottery
        .connect(user)
        .createLottery(1, 100, false, ONE_WEEK);
      console.log(await lottery.lotteryInfo(1));
    });
  });
});
