// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IERC20Betting {
    function isTokenAllowed(address token) external view returns (bool);
}

contract BlackjackV4 is Initializable{
    using SafeERC20 for IERC20;

    struct Card {
        string suit;
        string value;
    }

    struct Player {
        uint betAmount;
        bool isPlaying;
        bool hasBlackjack;
        bool hasBusted;
        address betToken;
    }

    struct Session {
        Player player;
        Card[] playerHand;
        Card[] dealerHand;
        bool revealDealerHand;  // Indicates whether the dealer's entire hand should be revealed
        Card[] deck;
    }

    mapping(address => Session) public sessions;
    IERC20Betting public bettingContract;

    event EventNewGame(address player, uint betAmount, address token, string state);
    event EventInteraction(string action, string message, string state);

    function initialize(address _bettingContract) public initializer {
        bettingContract = IERC20Betting(_bettingContract);
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function startGame(address token, uint betAmount) public {
        require(bettingContract.isTokenAllowed(token), "Token not allowed for betting");
        uint256 allowedAmount = IERC20(token).allowance(msg.sender, address(this));
        require(allowedAmount >= betAmount, "Bet amount exceeds allowance");
        IERC20(token).safeTransferFrom(msg.sender, address(this), betAmount);

        require(!sessions[msg.sender].player.isPlaying, "Player already in game");

        Session storage session = sessions[msg.sender];
        session.player.betAmount = betAmount;
        session.player.betToken = token;
        session.player.isPlaying = true;
        session.revealDealerHand = false;
        delete session.playerHand;
        delete session.dealerHand;
        delete session.deck;
        initializeDeck(msg.sender);

        addCardToHand(msg.sender, true); // true for player's hand
        addCardToHand(msg.sender, true);
        addCardToHand(msg.sender, false); // false for dealer's hand
        addCardToHand(msg.sender, false);

        emit EventNewGame(msg.sender, betAmount, token, getGameState(msg.sender));

        if (getHandValue(msg.sender, true) == 21) {
            session.player.hasBlackjack = true;
            endGame(msg.sender);
        }
    }

    function initializeDeck(address player) private {
        Session storage session = sessions[player];
        string[4] memory suits = ["Hearts", "Diamonds", "Clubs", "Spades"];
        string[13] memory values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace"];
        
        for (uint i = 0; i < suits.length; i++) {
            for (uint j = 0; j < values.length; j++) {
                session.deck.push(Card(suits[i], values[j]));
            }
        }
        shuffleDeck(player);
    }

    function shuffleDeck(address player) private {
        Session storage session = sessions[player];
        for (uint i = 0; i < session.deck.length - 1; i++) {
            uint j = uint(keccak256(abi.encodePacked(block.timestamp, player, i))) % (session.deck.length - i);
            Card memory temp = session.deck[i];
            session.deck[i] = session.deck[j];
            session.deck[j] = temp;
        }
    }

    function addCardToHand(address player, bool isPlayerHand) private {
        Session storage session = sessions[player];
        Card[] storage hand = isPlayerHand ? session.playerHand : session.dealerHand;
        hand.push(drawOne(player));
    }

    function drawOne(address player) private returns (Card memory) {
        Session storage session = sessions[player];
        require(session.deck.length > 0, "No more cards in the deck");
        Card memory drawnCard = session.deck[session.deck.length - 1];
        session.deck.pop();
        return drawnCard;
    }

    function getHandValue(address player, bool isPlayerHand) private view returns (uint) {
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

    function getPlayerHandValue(address player) private view returns (uint) {
        require(sessions[player].player.isPlaying, "Player is not currently playing a game");
        return getHandValue(player, true);
    }

    function getPlayerHandCards(address player) private view returns (Card[] memory) {
        require(sessions[player].player.isPlaying, "Player is not currently playing a game");
        return sessions[player].playerHand;
    }
    
    function getDealerHandValue(address player) private view returns (uint) {
        require(sessions[player].player.isPlaying, "Player is not currently playing a game");
        return getHandValue(player, false);
    }

    function getDealerHandCards(address player) private view returns (Card[] memory) {
        require(sessions[player].player.isPlaying, "Player is not currently playing a game");
        Session memory session = sessions[player];

        if(session.revealDealerHand){
            return getDealerHandCards(player);
        }

        Card[] memory onlyFirstCard = new Card[](1);
        onlyFirstCard[0] = session.dealerHand[0];

        return onlyFirstCard;
    }

    function getGameState(address player) public view returns (string memory) {
        require(sessions[player].player.isPlaying, "Player is not currently playing a game");

        uint playerValue = getPlayerHandValue(player);
        Card[] memory playerHand = getPlayerHandCards(player);
        string memory playerHandStr = "";
        for (uint i = 0; i < playerHand.length; i++) {
            playerHandStr = string(abi.encodePacked(playerHandStr, playerHand[i].value, ",", playerHand[i].suit));
            if (i < playerHand.length - 1) {
                playerHandStr = string(abi.encodePacked(playerHandStr, "+"));
            }
        }

        uint dealerValue = getDealerHandValue(player);
        Card[] memory dealerHand = getDealerHandCards(player);
        string memory dealerHandStr = "";
        for (uint i = 0; i < dealerHand.length; i++) {
            dealerHandStr = string(abi.encodePacked(dealerHandStr, dealerHand[i].value, ",", dealerHand[i].suit));
            if (i < dealerHand.length - 1) {
                dealerHandStr = string(abi.encodePacked(dealerHandStr, "+"));
            }
        }

       // Format the game state string to clearly indicate the separation
        string memory gameState = string(abi.encodePacked(
            playerHandStr,"=", uint2str(playerValue),
            "|",
            dealerHandStr,"=", uint2str(dealerValue)
        ));

        return gameState;
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function endGame(address player) private {
        dealerPlay(player);

        Session storage session = sessions[player];
        
        uint playerValue = getHandValue(player, true);
        uint dealerValue = getHandValue(player, false);
        string memory result;

        if (session.player.hasBlackjack) {
            result = "Player wins with Blackjack!";
            payOut(player, session.player.betAmount * 3 / 2); // Blackjack pays 3:2
        } else if (session.player.hasBusted) {
            result = "Player busts!";
        } else if (dealerValue > 21 || playerValue > dealerValue) {
            result = "Player wins!";
            payOut(player, session.player.betAmount * 2);
        } else if (dealerValue == playerValue) {
            result = "Push!";
            payOut(player, session.player.betAmount); // Return the bet
        } else {
            result = "Dealer wins!";
        }

        session.player.isPlaying = false;

        emit EventInteraction("end", result, getGameState(player));
    }

    function dealerPlay(address player) private {
        Session storage session = sessions[player];
        session.revealDealerHand = true;
        
        emit EventInteraction("reveal", "Reveal Dealer Hand", getGameState(player));

        uint dealerValue = getHandValue(player, false);
        while (dealerValue < 17) {
            addCardToHand(player, false);
            
            emit EventInteraction("draw", "Dealer draws a card", getGameState(player));
        }
    }

    function payOut(address player, uint amount) private {
        IERC20(sessions[player].player.betToken).safeTransfer(player, amount);
    }

    function playerHit() public {
        require(sessions[msg.sender].player.isPlaying, "Player must be in game to hit");
        require(!sessions[msg.sender].player.hasBusted, "Cannot hit if already busted");

        addCardToHand(msg.sender, true);
        uint playerValue = getHandValue(msg.sender, true);

        emit EventInteraction("hit", "Player Hit", getGameState(msg.sender));

        if (playerValue > 21) {
            sessions[msg.sender].player.hasBusted = true;
            endGame(msg.sender);
        }
    }

    function playerStand() public {
        require(sessions[msg.sender].player.isPlaying, "Player must be in game to stand");
        
        emit EventInteraction("stand", "Player Stand", getGameState(msg.sender));

        endGame(msg.sender);
    }

    function doubleDown() public {
        Session storage session = sessions[msg.sender];
        require(session.player.isPlaying, "Player must be in game to double down");
        require(session.playerHand.length == 2, "Can only double down on the initial two cards");

        uint256 additionalAllowedAmount = IERC20(session.player.betToken).allowance(msg.sender, address(this));
        require(additionalAllowedAmount >= session.player.betAmount, "Bet amount exceeds allowance");

        IERC20(session.player.betToken).safeTransferFrom(msg.sender, address(this), session.player.betAmount);
        session.player.betAmount *= 2; // Double the bet amount

        addCardToHand(msg.sender, true);

        emit EventInteraction("double_down", "Player Double Down", getGameState(msg.sender));
        
        endGame(msg.sender);
    }

    function offerInsurance(address player) private view returns (bool) {
        return bytes(sessions[player].dealerHand[0].value)[0] == 'A';
    }

    function buyInsurance() public {
        require(sessions[msg.sender].player.isPlaying, "Player must be in game");
        require(offerInsurance(msg.sender), "Insurance not available");

        uint insuranceCost = sessions[msg.sender].player.betAmount / 2;
        uint256 allowedAmount = IERC20(sessions[msg.sender].player.betToken).allowance(msg.sender, address(this));
        require(allowedAmount >= insuranceCost, "Insurance cost exceeds allowance");

        IERC20(sessions[msg.sender].player.betToken).safeTransferFrom(msg.sender, address(this), insuranceCost);
        if (getHandValue(msg.sender, false) == 21) {
            payOut(msg.sender, insuranceCost * 3); // 2:1 payout on insurance bet
        }

        emit EventInteraction("buy_insurance", "Player Buy Insurance", getGameState(msg.sender));
    }
}