// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ICOContract is Ownable(msg.sender) {
    IERC20 public vdoitToken;
    IERC20 public usdtToken;

    uint256 public vdoitPriceInUSDT = 20; // 0.2 USDT
    uint256 public hardCap = 100000 * 10**18; // Hard cap in VDOIT tokens

    uint256 public saleStartTime;
    uint256 public saleEndTime;
    bool public saleActive;

    uint256 public minPurchaseUSDT = 10 * 10**18; // 10 USDT
    uint256 public maxPurchaseUSDT = 200 * 10**18; // 200 USDT

    uint256 public claimedTotal;
    uint256 public totalBought;

    mapping(address => uint256) public purchases;
    mapping(address => bool) public isWhitelisted;

    event TokensPurchased(address indexed buyer, uint256 amount);

    constructor(address _vdoitToken, address _usdtToken) {
        vdoitToken = IERC20(_vdoitToken);
        usdtToken = IERC20(_usdtToken);
        saleActive = false;
    }

    modifier onlyWhileSaleActive() {
        require(saleActive, "ICO is not active");
        _;
    }

    function startICO(uint256 _saleDuration) external onlyOwner {
        require(!saleActive, "ICO is already active");
        saleStartTime = block.timestamp;
        saleEndTime = saleStartTime + _saleDuration;
        saleActive = true;
    }

    function stopICO() external onlyOwner {
        require(saleActive, "ICO is not active");
        saleActive = false;
    }

    function setVDOITPrice(uint256 _price) external onlyOwner {
        vdoitPriceInUSDT = _price;
    }

    function buyTokens(uint256 usdtAmount) external onlyWhileSaleActive {
        require(usdtAmount >= minPurchaseUSDT, "Amount is below the minimum purchase.");
        require(usdtAmount <= maxPurchaseUSDT, "Amount is above the maximum purchase.");

        uint256 vdoitAmount = (usdtAmount * 10**18) / vdoitPriceInUSDT;

        require(totalBought + vdoitAmount <= hardCap, "Purchase exceeds the hard cap.");

        totalBought += vdoitAmount;
        purchases[msg.sender] += vdoitAmount;

        usdtToken.transferFrom(msg.sender, address(this), usdtAmount);
        vdoitToken.transfer(msg.sender, vdoitAmount);

        emit TokensPurchased(msg.sender, vdoitAmount);
    }

    function claimTokens() external {
        uint256 claimableAmount = (purchases[msg.sender] * 10) / 100; // 10% of total purchase
        uint256 availableAmount = claimableAmount - claimedTotal;
        require(availableAmount > 0, "No tokens available for claiming.");
        claimedTotal += availableAmount;
        vdoitToken.transfer(msg.sender, availableAmount);
    }

    // function whitelistAddress(address[] calldata addresses) external onlyOwner {
    //     for (uint256 i = 0; i < addresses.length; i++) {
    //         isWhitelisted[addresses[i]] = true;
    //     }
    // }

    // function unwhitelistAddress(address[] calldata addresses) external onlyOwner {
    //     for (uint256 i = 0; i < addresses.length; i++) {
    //         isWhitelisted[addresses[i]] = false;
    //     }
    // }

    function transferCollectedUSDT(address recipient, uint256 amount) external onlyOwner {
        usdtToken.transfer(recipient, amount);
    }
}
