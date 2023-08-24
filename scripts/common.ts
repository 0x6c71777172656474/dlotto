import { ethers } from "hardhat";
import { utils } from "ethers";

type ticketArray = string[] | number[];

/**
 * Mines a new block with optional sleep duration.
 *
 * @param {number} [sleepDuration] - Optional sleep duration in seconds before mining the block.
 * @returns {Promise<void>} A promise that resolves when the block is mined.
 */
export const mine = async (sleepDuration?: number): Promise<void> => {
  if (sleepDuration) {
    await ethers.provider.send("evm_increaseTime", [sleepDuration]);
  }

  return ethers.provider.send("evm_mine", []);
};

/**
 * Generates an error message for a missing role in AccessControl.
 *
 * @param {string} address - The account address.
 * @param {string} role - The missing role.
 * @returns {string} The error message.
 */
export const getAccessError = (address: string, role: string): string =>
  `AccessControl: account ${address.toLowerCase()} is missing role ${role}`;

export function onlyUnique(
  value: number,
  index: number,
  array: number[]
): boolean {
  return array.indexOf(value) === index;
}

export function arraysEqualWithDifferentIndexes(
  arr1: ticketArray,
  arr2: ticketArray
) {
  if (arr1.length !== arr2.length) {
    return false;
  }

  const sortedArr1 = arr1.slice().sort();
  const sortedArr2 = arr2.slice().sort();

  return sortedArr1.every((element, index) => element === sortedArr2[index]);
}

export const toWei18 = (value: string) => utils.parseUnits(value, 18);
