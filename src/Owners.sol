// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Owners {
    address[] public owners;
    uint256 public threshold;
    bytes32 public merkleRoot;
    uint256 public txCount;
    bool public paused;
    uint256 public constant TIMELOCK_DURATION = 1 hours;


    error transaction_failed();
    error already_confirmed();
    error already_executed();
    error no_owners();
    error already_a_owner();
    error pausedd();
    error address_zero_detected();
    error not_owner();

    mapping(address => bool) public isOwner;
    mapping(uint256 => mapping(address => bool)) public confirmed;
    mapping(uint256 => Transaction) public transactions;

    event Submission(uint256 indexed txId);
    event Confirmation(uint256 indexed txId, address indexed owner);
    event Execution(uint256 indexed txId);

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
        uint256 submissionTime;
        uint256 executionTime;
    }

    constructor(address[] memory _owners, uint256 _threshold) payable {
        require(_owners.length > 0, no_owners());
        threshold = _threshold;
        owners = _owners;

        for (uint i = 0; i < owners.length; i++) {
            address o = owners[i];
            require(isOwner[owners[i]] == false, already_a_owner());
            require(o != address(0), address_zero_detected());
            isOwner[o] = true;
            owners.push(o);
        }

        // totalVaultValue = msg.value;
    }

    function submitTransaction(
        address to,
        uint256 value,
        bytes calldata data
    ) external {
        require(!paused, pausedd());
        require(isOwner[msg.sender], not_owner());
        uint256 id = txCount++;
        transactions[id] = Transaction({
            to: to,
            value: value,
            data: data,
            executed: false,
            confirmations: 1,
            submissionTime: block.timestamp,
            executionTime: 0
        });
    }

    function confirmTransaction(uint256 txId) external {
        require(!paused, pausedd());
        require(isOwner[msg.sender], not_owner());
        Transaction storage txn = transactions[txId];
        require(!txn.executed, already_executed());
        require(!confirmed[txId][msg.sender], already_confirmed());
        confirmed[txId][msg.sender] = true;
        txn.confirmations++;
        if (txn.confirmations == threshold) {
            txn.executionTime = block.timestamp + TIMELOCK_DURATION;
        }

        require(txn.executionTime != 0, "timelock not set");

        emit Confirmation(txId, msg.sender);
    }

    function executeTransaction(uint256 txId) external {
        Transaction storage txn = transactions[txId];
        require(txn.confirmations >= threshold);
        require(!txn.executed, already_executed());
        require(block.timestamp >= txn.executionTime);
        txn.executed = true;
        (bool s, ) = txn.to.call{value: txn.value}(txn.data);
        require(s, transaction_failed());

        emit Execution(txId);
    }
}
