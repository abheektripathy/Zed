// SPDX-License-Identifier: MIT
// Made by: Abheek Tripathy
// Zed Engine is the core of the Zed Protocol. It is responsible for minting and burning Zed tokens, and also for depositing and redeeming collateral.
//basically jo bhi token im accepting shall have a price feed, so if user deposits collateral on dai which is erc for polygon chain, that address must have a price feed address from chainlinl

pragma solidity ^0.8.18;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Zed} from "./Zed.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ZedEngine is ReentrancyGuard {

    ////////////////////////////// ERRORS //////////////////////////////
    error ZedEngine_AmountZero();
    error ZedEngine_TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
    error ZedEngine_TokenNotSupported();
    error ZedEngine_CollateralTransferFailed();

    ////////////////////////////// STATE VARIABLES //////////////////////////////
    mapping(address token => address priceFeed) private priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private collateralDeposits;
    mapping(address user => uint256 ZedAmount) private zedMinted;
    Zed private immutable ZedToken;

    ////////////////////////////// EVENTS //////////////////////////////
    event e_collateralDeposits(address indexed user, address indexed token, uint256 amount);



    ////////////////////////////// MODIFIERS //////////////////////////////

    modifier morethanZero(uint256 _amount) {
        if (_amount <= 0) {
            revert ZedEngine_AmountZero();
        }
        _;
    }

    modifier isAllowedToken(address _tokenAddress) {
        if (priceFeeds[_tokenAddress] == address(0)) {
            revert ZedEngine_TokenNotSupported();
        }
        _;
    }













    ////////////////////////////// FUNCTIONS //////////////////////////////

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address _ZedAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert ZedEngine_TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }
        ZedToken = Zed(_ZedAddress);
    }

    function depositCollateralAndMint() external {
        // deposit collateral
        // mint
    }

    function redeemCollateralAndBurn() external {
        // redeem collateral
        // burn
    }

    function depositCollateral(uint256 _collateralAmount, address _collateralAddress)
        external
        morethanZero(_collateralAmount)
        isAllowedToken(_collateralAddress)
        nonReentrant
    {
        collateralDeposits[msg.sender][_collateralAddress] += _collateralAmount;
        emit e_collateralDeposits(msg.sender, _collateralAddress, _collateralAmount);
        bool success = IERC20(_collateralAddress).transferFrom(msg.sender, address(this), _collateralAmount);
        if (!success) {
            revert ZedEngine_CollateralTransferFailed();
        }
    }

    function redeemCollateral() external nonReentrant {
        // redeem collateral
    }

    //TODO: check collateral amount, check amount, mint while keeping overcollaterization ratio in check.
    function mintZed(uint256 _amountToMint) external morethanZero(_amountToMint) nonReentrant {
        zedMinted[msg.sender] += _amountToMint;


    }

    function burn() external nonReentrant {
        // burning more Zed
    }

    function liquidate() external {
        // liquidate a user whose health check is below 150%
    }

    function autoLiquidate() external {
        // liquidate a user whose health check is below 120% automatically, and keep the extra collateral by the contract.
        // and if no one liquidates, then the contract will liquidate the user automatically.
    }






    ////////////////////////////// INTERNAL FUNCTIONS //////////////////////////////

    function _getAccountInfo(address _userAddress) private view returns (uint256, uint256) {

        uint256 totalZedMinted = zedMinted[_userAddress];
        uint256 totalCollateralDepositedInUSD = _getCollateralDepositedInUSD(_userAddress);
        // returns the collateral value and the Zed value of the user.
        //user ka collateral value and zed minted value return karna hai
    }

    function _healthCheck() internal view returns (uint256) {

        (uint256 collateralValueInUSD, uint256 ZedValue) = _getAccountInfo(msg.sender);

        // basically checking the overcollateralization ratio of the user. Shall return a percentange.
    }

    function _getCollateralDepositedInUSD(address _userAddress) internal pure returns (uint256) {

        uint256 totalCollateralDeposited = 0;
        return totalCollateralDeposited;
    }

    function _revertIfHealthCheckFails() internal {

        // if health check fails, revert the transaction.

    }
}
