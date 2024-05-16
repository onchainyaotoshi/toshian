// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Blackjack.sol";

contract BlackjackV2 is Blackjack {
    function getHandValue(address player, bool isPlayerHand) private view override returns (uint) {
        Session storage session = sessions[player];
        Card[] storage hand = isPlayerHand ? session.playerHand : session.dealerHand;
        uint value = 0;
        uint aces = 0;

        // Determine the length of the hand to evaluate
        uint handLength = hand.length;
        if (!isPlayerHand && !session.revealDealerHand && handLength > 1) {
            handLength = 1;  // Only evaluate the first card of the dealer's hand
        }

        for (uint i = 0; i < handLength; i++) {
            string memory cardValue = hand[i].value;
            bytes memory valueBytes = bytes(cardValue);
            if (keccak256(valueBytes) == keccak256("Ace")) {
                value += 11;
                aces++;
            } else if (keccak256(valueBytes) == keccak256("Jack") || keccak256(valueBytes) == keccak256("Queen") || keccak256(valueBytes) == keccak256("King") || keccak256(valueBytes) == keccak256("10")) {
                value += 10;
            } else {
                value += uint8(valueBytes[0]) - 48;  // ASCII to uint conversion (for '2' to '9')
            }
        }

        while (value > 21 && aces > 0) {
            value -= 10;
            aces--;
        }
        return value;
    }
}