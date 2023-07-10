// SPDX-License-Identifier: MIT
// Made by: Abheek Tripathy
// Zed Engine is the core of the Zed Protocol. It is responsible for minting and burning Zed tokens, and also for depositing and redeeming collateral.

pragma solidity ^0.8.18;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Zed} from "./Zed.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ZedEngine is ReentrancyGuard {
    ////////////////////////////// ERRORS //////////////////////////////
    error ZedEngine_AmountZero();
    error ZedEngine_TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
    error ZedEngine_TokenNotSupported();
    error ZedEngine_CollateralTransferFailed();
    error ZedEngine_HealthCheckFailed(uint256 healthRatio);
    error ZedEngine_MintFailed();

    ////////////////////////////// STATE VARIABLES //////////////////////////////
    uint256 private constant ZED_LIQUIDATION_THRESHOLD = 50;
    uint256 private constant ZED_MIN_HEALTH_FACTOR = 1;
    mapping(address token => address priceFeed) private priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private collateralDeposits;
    mapping(address user => uint256 ZedAmount) private zedMinted;
    address[] private collateralTokens;
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
            collateralTokens.push(tokenAddresses[i]);
            //so whenever a new token that we have price feed for is added, its added to the accepted collateral token array as well.
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

    function mintZed(uint256 _amountToMint) external morethanZero(_amountToMint) nonReentrant {
        zedMinted[msg.sender] += _amountToMint;
        //to check if this breaks health ratio
        _revertIfHealthCheckFails(msg.sender);
        bool mintSuccess= ZedToken.mint(_amountToMint, msg.sender);
        if(!mintSuccess){
            revert ZedEngine_MintFailed();
        }
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

    function getPriceFeed(address _tokenAddress, uint256 _amount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeeds[_tokenAddress]);
        (, int256 price,,,) = priceFeed.latestRoundData();
        return ((uint256(price) * 1e10) * _amount) / 1e18;
    }

    ////////////////////////////// INTERNAL FUNCTIONS //////////////////////////////

    function _getAccountInfo(address _userAddress) private view returns (uint256 totalZedMinted, uint256 totalCollateralDepositedInUSD) {
        totalZedMinted = zedMinted[_userAddress];
        totalCollateralDepositedInUSD = _getAccountCollateralValueInUSD(_userAddress);
    }

    function _healthCheck(address _user) internal view returns (uint256 healthRatio) {
        (uint256 totalZedMinted, uint256 collateralValueInUSD) = _getAccountInfo(_user);
        uint256 adjustedCollateral = (collateralValueInUSD * ZED_LIQUIDATION_THRESHOLD) / 100;
        healthRatio = adjustedCollateral / totalZedMinted;
        return healthRatio;
       
    }

    function _getAccountCollateralValueInUSD(address _userAddress)
        internal
        view
        returns (uint256 totalCollateralDepositedInUSD)
    {
        for (uint256 i = 0; i < collateralTokens.length; i++) {
            address tokenAddress = collateralTokens[i];
            uint256 collateralAmount = collateralDeposits[_userAddress][tokenAddress];
            totalCollateralDepositedInUSD += getPriceFeed(tokenAddress, collateralAmount);
        }
        //loops through all the collateral tokens and returns the total collateral value in USD.
        return totalCollateralDepositedInUSD;
    }

    function _revertIfHealthCheckFails(address _user) internal view {
        uint256 userhealthRatio = _healthCheck(_user);
        if (userhealthRatio < ZED_MIN_HEALTH_FACTOR) {
            revert ZedEngine_HealthCheckFailed(userhealthRatio);
        }

        // if health check fails, revert the transaction.
    }
}
