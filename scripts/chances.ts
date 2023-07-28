async function main() {
  console.log(combinationsAndChances(5, 40, 100));
}

function combinationsAndChances(
  selection: number,
  total: number,
  ticketCount: number
): object {
  let n: number = 1;
  let factorial: number = 1;
  for (let i = 1; i <= selection; i++) {
    n *= total;
    total--;
    factorial *= i;
  }
  const tC = ticketCount;
  let combinations: number = n / factorial;
  return {
    tickets: ticketCount,
    combinations: combinations,
    chances: Number((tC / combinations).toFixed(6)),
  };
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
