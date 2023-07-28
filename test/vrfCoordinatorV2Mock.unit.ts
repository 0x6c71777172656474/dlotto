import { expect } from "chai";
import { ContractReceipt, ContractTransaction, BigNumber } from "ethers";
import { onlyUnique } from "../scripts/common";
import { ethers } from "hardhat";
import "dotenv/config";
import {
  Randomizer,
  Randomizer__factory,
  VRFCoordinatorV2Mock,
  VRFCoordinatorV2Mock__factory,
} from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("vrfCoordinatorV2Mock unit test", async () => {
  let owner: SignerWithAddress;
  let vrfCoordinatorV2Mock: VRFCoordinatorV2Mock;
  let randomizer: Randomizer;
  let subscriptionId: BigNumber;

  beforeEach(async () => {
    const BASE_FEE: string = "100000000000000000";
    const GAS_PRICE_LINK: string = "1000000000";

    [owner] = await ethers.getSigners();
    let coordinatorMock: VRFCoordinatorV2Mock__factory =
      await ethers.getContractFactory("VRFCoordinatorV2Mock");

    let Randomizer: Randomizer__factory = await ethers.getContractFactory(
      "Randomizer"
    );

    vrfCoordinatorV2Mock = await coordinatorMock.deploy(
      BASE_FEE,
      GAS_PRICE_LINK
    );

    let tx: ContractTransaction =
      await vrfCoordinatorV2Mock.createSubscription();
    const transactionReceipt: ContractReceipt = await tx.wait(1);
    if (transactionReceipt.events) {
      subscriptionId = ethers.BigNumber.from(
        transactionReceipt.events[0].topics[1]
      );
    }

    await vrfCoordinatorV2Mock.fundSubscription(
      subscriptionId,
      ethers.utils.parseEther("7")
    );

    randomizer = await Randomizer.deploy(
      subscriptionId,
      vrfCoordinatorV2Mock.address
    );
    await vrfCoordinatorV2Mock.addConsumer(subscriptionId, randomizer.address);
  });

  it("Should get random numbers and print it in console", async () => {
    let ticket: number[] = [];
    let ticketPot: number[][] = [];
    let numberOfDigits = 5;

    await expect(randomizer.connect(owner).requestRandomWords(numberOfDigits*100)).to.emit(
      vrfCoordinatorV2Mock,
      "RandomWordsRequested"
    );

    await expect(
      vrfCoordinatorV2Mock.fulfillRandomWords(
        await randomizer.lastRequestId(),
        randomizer.address
      )
    ).to.emit(vrfCoordinatorV2Mock, "RandomWordsFulfilled");

    let getNumbers: BigNumber[] = (
      await randomizer.getRequestStatus(await randomizer.lastRequestId())
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
