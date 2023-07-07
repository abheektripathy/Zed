// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Zed is ERC20Burnable, Ownable{
    error Zed_BurnAmountExceedsBalance();
    error Zed_AmountZero();
    error Zed_ZeroAddress();
    
    constructor() ERC20("Zed", "Zed") {}

    function burn(uint256 amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if(amount <= 0){
            revert Zed_AmountZero();
        }
        if (balance < amount) {
           revert Zed_BurnAmountExceedsBalance();
        }
        require(balance >= amount, "ERC20: burn amount exceeds balance");
        super.burn(amount);

    }

    function mint(uint256 amount, address _to) external onlyOwner returns (bool) {
        if(amount <= 0){
            revert Zed_AmountZero();
        }
        if(_to == address(0)){
            revert Zed_ZeroAddress();
        }
        _mint(msg.sender, amount);
        return true;
    }


}