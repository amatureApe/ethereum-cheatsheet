/*
This function calculates impermanent loss of a
liquidity pair, given a price movement of d, in a constant
sum LP.

For a given price of two tokens, the price
of token A being given in token B, this formula will
state the percentage of value lost in the pair due to
impermanent loss as opposed to simply hodling both tokens.

That is to say:
  at d = 1, the impermanent loss will be 0.
  at d = 0, impermanent loss would be a total 100%, or -1.
  at d > 1, the impermanent loss will grow infinitely along the
    x-axis to eventually reach a total loss of 100%, or -1.

Some examples of percentage loss due to IL:
  d = 1 -> 0%
  d = 0 -> -100%

  d = 0.9 -> -0.1386002052090718%
  d = 0.8 -> -0.6192010000093506%
  d = 0.5 -> -5.719095841793653%
  d = 0.1 -> -42.50404254239311%
  d = 0.005 -> -57.408229000004006%
  d = 0.0001 -> -93.6817629167465%

  d = 1.1 -> -0.11344303141413992%
  d = 1.3 -> -0.8543108609445071%
  d = 2 -> -5.719095841793653%
  d = 5 -> -25.46440075000701%
  d = 50 -> -72.27032230640991%
  d = 1000 -> -93.6817629167465%
*/


const IL = d => {
  return (((2 * (d ** 0.5)) / (1 + d)) - 1) * 100
}

console.log(IL(1))
