// SPDX-License-Identifier: SMIT
pragma solidity ^0.8.20;
import "../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
contract Merkle {
    bytes32 public merkleRoot;
    bool public paused;

    mapping(address => bool) public claimed;
    mapping(bytes32 => bool) public usedHashes;

    event MerkleRootSet(bytes32 indexed newRoot);
    event Claim(address indexed claimant, uint256 amount);

    function setMerkleRoot(bytes32 root) public {
        merkleRoot = root;
        emit MerkleRootSet(root);
    }

    function verifySignature(
        address signer,
        bytes32 messageHash,
        bytes memory signature
    ) external pure returns (bool) {
        return ECDSA.recover(messageHash, signature) == signer;
    }

    function claim(bytes32[] calldata proof, uint256 amount) external {
        require(!paused);
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        bytes32 computed = MerkleProof.processProof(proof, leaf);
        require(computed == merkleRoot);
        require(!claimed[msg.sender]);

        
        emit Claim(msg.sender, amount);
    }
}
