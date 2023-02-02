// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";



contract UnemetaCommission is Pausable,ReentrancyGuard ,Ownable{
    uint256 public amount =0;
    function deposit() public payable {
        amount +=msg.value;
        _pause();
    }
    function unpauseDistribution() external onlyOwner whenPaused {
        _unpause();
    }
    function getb() public view
    returns(uint){
    return address(this).balance;
    }
      function withdraw(uint256 _amount, address _to) 
        external 
        onlyOwner 
    {
        uint256 contractBalance = address(this).balance;
        require((contractBalance >= _amount)  ,"errir") ;
        amount -= _amount;
        (bool success,) = payable(_to).call{value: _amount}("");
        require(success,"cdsa");
    }
}