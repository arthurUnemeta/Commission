// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

error InvalidMerkleProof();

contract UnemetaCommission is Pausable,ReentrancyGuard ,Ownable{
    struct Claimed{
        uint256 id;
        bool clamed;
    }

    uint256 public amount =0;
    bytes32 private _trees;
    mapping(address =>mapping(uint256=>bool))private _claimed;
    
 
    event SetNewMerkleRoot(
        uint256 indexed treeid
    );

    event Claim(
        uint256 indexed _id,
        uint256 indexed _amount,
        address indexed _address
    );

    function deposit() public payable {
        _pause();
        amount +=msg.value;
    }

    function unpauseDistribution() external onlyOwner whenPaused {
        _unpause();
    }

    function getb() public view
    returns(uint){
    return address(this).balance;
    }

    function claim(uint256 _id,uint256 _amounts,bytes32[] calldata _proof)
    external
    whenNotPaused
    {
        //makesure treeis is true
        require((_trees.length>0),"tree is not used");
        require(!(_claimed[msg.sender][_id]),"id has used");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender,_amounts,_id));
        if (!MerkleProof.verifyCalldata(_proof, _trees, leaf)) revert InvalidMerkleProof();
        uint256 _amount;
        if (getb()>=_amounts){
            _amount = _amounts;
        }else{
            _amount = getb();
        }
        require(_amount<_amounts,"too many amount error");
        require(_amount!=0,"error amount");
        _claimed[msg.sender][_id] = true;
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        require(success,"error payable");
        emit Claim(_id,_amounts,msg.sender);
    }
    
    //only owner function
    function withdraw(uint256 _amount, address _to) 
    external 
    onlyOwner 
    {   
        uint256 contractBalance = address(this).balance;
        require((contractBalance >= _amount)  ,"error") ;
        _pause();
        amount -= _amount;
        (bool success,) = payable(_to).call{value: _amount}("");
        require(success,"cdsa");
    }

    // set new merkle root
    function setMerkleRoot(uint256 treeid,bytes32 newRoot_) 
    external 
    onlyOwner 
    {
        _pause();
        _trees = newRoot_;
        emit SetNewMerkleRoot(treeid);
    }
}
