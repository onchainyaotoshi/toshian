// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Betting is Ownable {
    mapping(address => bool) public allowedTokens;
    address[] private tokenList;

    constructor(address defaultToken) Ownable(msg.sender) {
        allowToken(defaultToken);
    }

    // Allow a new token for betting
    function allowToken(address token) public onlyOwner {
        require(token != address(0), "Invalid token address");
        require(!allowedTokens[token], "Token already allowed");
        allowedTokens[token] = true;
        tokenList.push(token);
    }

    // Disallow a previously allowed token
    function disallowToken(address token) public onlyOwner {
        require(allowedTokens[token], "Token not allowed or already disallowed");
        allowedTokens[token] = false;
        _removeTokenFromList(token);
    }

    // Function to check if a token is allowed for betting
    function isTokenAllowed(address token) public view returns (bool) {
        return allowedTokens[token];
    }

    // Retrieve the list of allowed tokens
    function getAllowedTokens() public view returns (address[] memory) {
        return tokenList;
    }

    // Remove a token from the tokenList helper function
    function _removeTokenFromList(address token) private {
        uint256 length = tokenList.length;
        for (uint256 i = 0; i < length; i++) {
            if (tokenList[i] == token) {
                tokenList[i] = tokenList[length - 1]; // Move the last element here
                tokenList.pop(); // Remove the last element
                break;
            }
        }
    }
}
