import { expect } from "chai";
import { ContractReceipt, ContractTransaction, BigNumber } from "ethers";
import { arraysEqualWithDifferentIndexes } from "../scripts/common";
import { ethers } from "hardhat";
import "dotenv/config";
import {
  RandomNumbersGenerator,
  VRFCoordinatorV2Mock,
} from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { deployTest } from "../scripts/deploy/deployTest";

describe("vrfCoordinatorV2Mock unit test", async () => {
  let owner: SignerWithAddress;
  let user: SignerWithAddress;
  let vrfCoordinatorV2Mock: VRFCoordinatorV2Mock;
  let randomizer: RandomNumbersGenerator;

  let testDeploy: any;

  beforeEach(async () => {
    testDeploy = await deployTest();
    randomizer = testDeploy.randomizer;
    vrfCoordinatorV2Mock = testDeploy.vrfCoordinatorV2Mock;
    [owner, user] = await ethers.getSigners();
  });

  it("Should get random numbers and print it in console", async () => {
    let ticket: number[] = [];
    let ticketPot: number[][] = [];
    let numberOfDigits = 5;

    console.log(await randomizer.deployed());

    await randomizer.connect(owner).requestRandomWords(numberOfDigits * 100);

    await expect(
      vrfCoordinatorV2Mock.fulfillRandomWords(
        await randomizer.getLastRequestId(),
        randomizer.address
      )
    ).to.emit(vrfCoordinatorV2Mock, "RandomWordsFulfilled");

    let getNumbers: BigNumber[] = (
      await randomizer.getRequestStatus(await randomizer.getLastRequestId())
    ).randomWords;

    for (let j = 0; j < getNumbers.length; j++) {
      let remainder: BigNumber = getNumbers[j].mod(BigNumber.from(40));
      if (remainder.toNumber() > 0) {
        ticket.push(parseInt(remainder.toString()));
        if (ticket.length == 5) {
          ticketPot.push(ticket);
          ticket = [];
        }
      }
    }

    for (let k = 0; k < ticketPot.length; k++) {
      const t = ticketPot[k];
      let newArray: number[] = t.filter(
        (value, index, array) => array.indexOf(value) === index
      );
      if (JSON.stringify(t) !== JSON.stringify(newArray)) {
        ticketPot = ticketPot.filter((item) => {
          return item !== t;
        });
      }
    }

    console.log(ticketPot.length);
    console.log(ticketPot);
  });
});
