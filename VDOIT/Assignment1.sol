// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VDOITToken is ERC20("VDOIT TOKEN", "VDOIT"), Ownable(msg.sender) {
    uint public constant initialSupply = 100000 * 10 ** 18; 
    uint public constant lockedAmount = 24000 * 10 ** 18; 
    uint public constant releaseAmount = 100 * 10 ** 18;
    uint public constant releaseInterval = 30 days;

    uint public startTime;
    uint public lastReleaseTime;
    uint public releasedTotal;

    constructor() {
        _mint(msg.sender, initialSupply);
        startTime = block.timestamp;
        lastReleaseTime = startTime;
        releasedTotal = 0;
    }

    function minting(address account, uint amount) public onlyOwner {
        require(amount > 0, "Minted amount must be greater than 0");
        require(totalSupply() + amount <= initialSupply, "Mint would exceed the initial supply");
        _mint(account, amount);
    }

    function burning(uint amount) public {
        require(amount > 0, "Burned amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance to burn");
        _burn(msg.sender, amount);
    }
    function releaseTokens() public onlyOwner {
        require(block.timestamp >= startTime, "Tokens cannot be released before the start time");
        require(releasedTotal <= lockedAmount, "All locked coins have been released");

        uint timePassed = block.timestamp - lastReleaseTime;
        uint intervalsPassed = timePassed / releaseInterval;
        uint coinsToRelease = intervalsPassed * releaseAmount;

        if (coinsToRelease > 0) {
            lastReleaseTime += intervalsPassed * releaseInterval;
            if (releasedTotal + coinsToRelease > lockedAmount) {
                coinsToRelease = lockedAmount - releasedTotal;
            }

            releasedTotal += coinsToRelease;
            _transfer(address(this), msg.sender, coinsToRelease);
        }
    }

   
}
