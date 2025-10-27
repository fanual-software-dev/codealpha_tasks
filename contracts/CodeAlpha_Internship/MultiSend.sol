// SPDX-License-Identifier:MIT
pragma solidity >0.8.0;

contract MultiSend{
    address[] public receivers;
    uint totalRecievers = receivers.length;

    constructor(address[] memory _receivers) {
        receivers = _receivers;

    }
    
    modifier validAmount(uint _amount) {
        require(_amount > 0, "Amount must be greater than 0");
        _;
    } 

    function recieveEtherAndDistribute(  ) public payable returns (bool)  {
        uint recievedAmount = address(this).balance;
        uint recievableAmount = recievedAmount / totalRecievers;
        for (uint i = 0; i < totalRecievers; i++) {
            payable(receivers[i]).transfer(recievableAmount);
        }

        return true;
    }   
    
}