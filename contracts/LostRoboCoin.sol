// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./lib/Recoverable.sol";

contract LostRoboCoin is
    ERC20,
    ERC20Burnable,
    ERC20Permit,
    Ownable,
    Recoverable
{
    constructor() ERC20("LostRoboCoin", "LRC") ERC20Permit("LostRoboCoin") {
        _mint(_msgSender(), 100_000_000 * 10**decimals());
    }
}
