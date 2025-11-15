// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CryptoLocker {
    struct LockInfo {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => LockInfo) public locks;

    event Deposited(address indexed user, uint256 amount, uint256 unlockTime);
    event Withdrawn(address indexed user, uint256 amount);

    // User deposits Ether and sets a timelock
    function deposit(uint256 _lockTimeInSeconds) external payable {
        require(msg.value > 0, "Must deposit some ETH");
        require(locks[msg.sender].amount == 0, "Existing lock active");

        uint256 unlockTime = block.timestamp + _lockTimeInSeconds;

        locks[msg.sender] = LockInfo({
            amount: msg.value,
            unlockTime: unlockTime
        });

        emit Deposited(msg.sender, msg.value, unlockTime);
    }

    // Withdraw only after unlock time
    function withdraw() external {
        LockInfo storage lock = locks[msg.sender];

        require(lock.amount > 0, "No active lock");
        require(block.timestamp >= lock.unlockTime, "Funds are still locked");

        uint256 amount = lock.amount;
        lock.amount = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdraw failed");

        emit Withdrawn(msg.sender, amount);
    }
}
