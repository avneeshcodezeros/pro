// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract usdt is ERC20 {
    constructor() ERC20("usdt", "USDT") {
        _mint(msg.sender, 1000000e18);
    }
}
