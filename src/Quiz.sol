// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }
    
    address public owner;
    mapping(uint => mapping(address => uint256)) public bets;
    mapping(address => uint256) public balaces;
    uint public vault_balance;

    mapping(uint => Quiz_item) quizList;
    uint num = 0;

    constructor () {
        owner = msg.sender;

        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public {
        if (msg.sender == address(1))
            revert();

        quizList[q.id] = q;
        num += 1;
    }

    function getAnswer(uint quizId) public view returns (string memory){
        if (msg.sender == owner)
            return quizList[quizId].answer;
        else
            return "";
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        Quiz_item memory q = quizList[quizId];
        q.answer = "";
        return q;
    }

    function getQuizNum() public view returns (uint){
        return num;
    }
    
    function betToPlay(uint quizId) public payable {
        Quiz_item memory q = quizList[quizId];
        uint val = msg.value;

        require(q.min_bet <= val);
        require(q.max_bet >= val);

        bets[quizId - 1][msg.sender] += val;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        Quiz_item memory q = quizList[quizId];

        if (keccak256(bytes(q.answer)) == keccak256(bytes(ans))) {
            balaces[msg.sender] += bets[quizId - 1][msg.sender] * 2;
            return true;

        } else {
            vault_balance += bets[quizId - 1][msg.sender];
            bets[quizId - 1][msg.sender] = 0;   
            return false;
        }


    }

    function claim() public {
        uint amount = balaces[msg.sender];
        balaces[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    receive() external payable {
        vault_balance += msg.value;
    }

}
