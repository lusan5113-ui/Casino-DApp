// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Casino {
    address public owner;
    uint256 public minimumBet;
    uint256 public totalBets;
    uint256 public numberOfBets;
    uint256 public maxAmountOfBets = 10; 
    address[] public players;
    
    struct Player {
        uint256 amountBet;
        uint256 numberSelected;
    }
    
    mapping(address => Player) public playerInfo;
    
    constructor(uint256 _minimumBet) {
        owner = msg.sender;
        if(_minimumBet != 0) minimumBet = _minimumBet;
        else minimumBet = 100000000000000; // 0.0001 ETH
    }
    
    function bet(uint256 numberSelected) public payable {
        require(!checkPlayerExists(msg.sender), "You have already bet.");
        require(numberSelected >= 1 && numberSelected <= 10, "Choose a number between 1 and 10.");
        require(msg.value >= minimumBet, "Bet amount too low.");
        
        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].numberSelected = numberSelected;
        players.push(msg.sender);
        totalBets += msg.value;
        numberOfBets++;
        
        if(numberOfBets >= maxAmountOfBets) {
            generateNumberWinner();
        }
    }
    
    function checkPlayerExists(address player) public view returns(bool){
        for(uint256 i = 0; i < players.length; i++){
            if(players[i] == player) return true;
        }
        return false;
    }
    
    function generateNumberWinner() public {
        // Simple pseudo-random for assignment purpose
        uint256 numberGenerated = block.number % 10 + 1; 
        distributePrizes(numberGenerated);
    }
    
    function distributePrizes(uint256 numberWinner) public {
        address[100] memory winners;
        uint256 count = 0; 
        
        for(uint256 i = 0; i < players.length; i++){
            address playerAddress = players[i];
            if(playerInfo[playerAddress].numberSelected == numberWinner){
                winners[count] = playerAddress;
                count++;
            }
            delete playerInfo[playerAddress];
        }
        
        players = new address[](0);
        uint256 winnerEtherAmount = totalBets / (count > 0 ? count : 1);
        
        for(uint256 j = 0; j < count; j++){
            if(winners[j] != address(0)) {
                payable(winners[j]).transfer(winnerEtherAmount);
            }
        }
        resetData();
    }
    
    function resetData() internal {
        players = new address[](0);
        totalBets = 0;
        numberOfBets = 0;
    }
}
