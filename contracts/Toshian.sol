// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ToshianToken is ERC20, Ownable {
    constructor() ERC20("Toshian", "TOSHIAN") Ownable(msg.sender) {
        uint256 totalSupply = 420690000000 * (10 ** uint256(decimals()));
        _mint(msg.sender, totalSupply); // Mint total supply to the owner for initial distribution

        // uint256 teamShare = totalSupply * 10 / 100;
        // uint256 reserveShare = totalSupply * 10 / 100;
        // uint256 dealersShare = totalSupply * 50 / 100;
        // uint256 communityAirdropShare = totalSupply * 10 / 100;
        // uint256 liquidityPoolShare = totalSupply * 20 / 100;

        // _transfer(msg.sender, teamAddress, teamShare);
        // _transfer(msg.sender, reserveAddress, reserveShare);
        // _transfer(msg.sender, dealerAddress, dealersShare);
        // _transfer(msg.sender, communityAirdropAddress, communityAirdropShare);
        // _transfer(msg.sender, liquidityPoolAddress, liquidityPoolShare);
    }

    // Function to mint new tokens, only accessible by the owner of the contract
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Function to burn tokens from owner's account, reducing the total supply
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}