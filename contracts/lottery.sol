// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract lottery {
    uint lotteryLimit;
    uint timeLimit;
    address owner;
    //bool started;

    event lotteryParticipants( address participant, uint value);

    address[] participants;
    constructor (uint _timeLimit, uint _lotteryLimit) {   
         owner = msg.sender;  
         lotteryLimit = _lotteryLimit;
        timeLimit = _timeLimit + block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function check(address player) private {
        for (uint i; i < participants.length; i++) {
            if (player == participants[i]) {
                revert("Player can only play once");
            }else {
                participants.push(player);
            }
        }
    }

    function participation(address caller) private view returns(bool status) {
        for (uint i; i < participants.length; i++) {
            if (caller == participants[i]) {
               status = true;
            }
        }
    }
    

    function placeLottery () public payable {
        require (msg.value >= lotteryLimit, "You cannot participate in this lottery");
        require (block.timestamp > timeLimit , "You can no longer place a bet");
        check(msg.sender);
        emit lotteryParticipants( msg.sender, msg.value);

    }

    function random () private view returns(uint) {
         return (uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants))) % participants.length) + 1;
     }

     function ownerPercentage () private view returns(uint percent) {
         percent = (address(this).balance * 20) / 100;
     }
     

     function withdrawWins () external onlyOwner returns(bool withdrawn){
        require(msg.sender == address(0), " this address can't withdraw");
        require (block.timestamp > timeLimit, "Lottery time not over");
        bool Status = participation(msg.sender);
        require (Status, "You didn't participatein the lottery");
        uint randomNum = random();
        uint wins = address(this).balance - ownerPercentage();
        payable(participants[randomNum]).transfer(wins);
        withdrawn = true;
     }

     function ownerWithdraws () external onlyOwner {
        require(block.timestamp > timeLimit, "Wait till the end of the lottery");
        uint gain = ownerPercentage();
        payable(msg.sender).transfer(gain);
     }

     receive () external payable {}
     fallback () external payable {} 


}