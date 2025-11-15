// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title EqualDistributor
/// @notice Distributes received ETH equally among a list of recipients.
/// @dev Emits events for distribution and payments. Owner can withdraw leftover funds.
contract EqualDistributor {
    address public owner;

    /// @notice Emitted when funds are distributed.
    /// @param sender who called distribute()
    /// @param totalAmount total wei sent to distribute()
    /// @param recipientsCount number of recipients
    /// @param amountPerRecipient wei sent to each recipient
    event FundsDistributed(
        address indexed sender,
        uint256 totalAmount,
        uint256 recipientsCount,
        uint256 amountPerRecipient
    );

    /// @notice Emitted after each successful payment to a recipient.
    event PaymentSent(address indexed recipient, uint256 amount);

    /// @notice Emitted when owner withdraws contract balance.
    event FundsWithdrawn(address indexed owner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Distribute msg.value equally to recipients.
    /// @param recipients array of addresses to receive equal shares.
    function distribute(address[] calldata recipients) external payable {
        uint256 count = recipients.length;
        require(count > 0, "No recipients provided");
        require(msg.value > 0, "No Ether sent");

        // integer division: floor(msg.value / count)
        uint256 share = msg.value / count;
        require(share > 0, "Insufficient Ether to distribute");

        emit FundsDistributed(msg.sender, msg.value, count, share);

        // send equal shares to each recipient
        for (uint256 i = 0; i < count; i++) {
            // Using call to forward gas and avoid hard gas-limits of transfer
            (bool sent, ) = payable(recipients[i]).call{value: share}("");
            require(sent, "Failed to send Ether");
            emit PaymentSent(recipients[i], share);
        }

        // refund any remainder due to division (msg.value % count) back to sender
        uint256 remainder = msg.value - (share * count);
        if (remainder > 0) {
            (bool refunded, ) = payable(msg.sender).call{value: remainder}("");
            require(refunded, "Refund failed");
        }
    }

    /// @notice Owner can withdraw any leftover funds from contract
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");

        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Withdraw failed");

        emit FundsWithdrawn(owner, balance);
    }

    // Allow contract to receive Ether directly
    receive() external payable {}

    fallback() external payable {}
}
