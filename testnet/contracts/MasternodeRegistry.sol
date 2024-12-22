// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MasternodeRegistry {
    // Minimum stake required to become a masternode
    uint256 public constant MASTERNODE_STAKE = 10000 ether;
    
    // Minimum lock period for masternode stake
    uint256 public constant MIN_LOCK_PERIOD = 30 days;
    
    struct Masternode {
        address owner;
        uint256 stake;
        uint256 registeredTime;
        uint256 lastActiveTime;
        bool active;
    }
    
    mapping(address => Masternode) public masternodes;
    address[] public masternodeList;
    
    event MasternodeRegistered(address indexed owner, uint256 stake);
    event MasternodeDeactivated(address indexed owner);
    event StakeIncreased(address indexed owner, uint256 newStake);
    
    modifier onlyActiveMasternode() {
        require(masternodes[msg.sender].active, "Not an active masternode");
        _;
    }
    
    function registerMasternode() external payable {
        require(msg.value >= MASTERNODE_STAKE, "Insufficient stake");
        require(!masternodes[msg.sender].active, "Already registered");
        
        masternodes[msg.sender] = Masternode({
            owner: msg.sender,
            stake: msg.value,
            registeredTime: block.timestamp,
            lastActiveTime: block.timestamp,
            active: true
        });
        
        masternodeList.push(msg.sender);
        emit MasternodeRegistered(msg.sender, msg.value);
    }
    
    function deactivateMasternode() external onlyActiveMasternode {
        require(block.timestamp >= masternodes[msg.sender].registeredTime + MIN_LOCK_PERIOD, 
                "Lock period not expired");
        
        Masternode storage mn = masternodes[msg.sender];
        uint256 stake = mn.stake;
        mn.active = false;
        
        payable(msg.sender).transfer(stake);
        emit MasternodeDeactivated(msg.sender);
    }
    
    function updateActivity() external onlyActiveMasternode {
        masternodes[msg.sender].lastActiveTime = block.timestamp;
    }
    
    function getActiveMasternodes() external view returns (address[] memory) {
        uint256 activeCount = 0;
        for (uint i = 0; i < masternodeList.length; i++) {
            if (masternodes[masternodeList[i]].active) {
                activeCount++;
            }
        }
        
        address[] memory activeMNs = new address[](activeCount);
        uint256 j = 0;
        for (uint i = 0; i < masternodeList.length; i++) {
            if (masternodes[masternodeList[i]].active) {
                activeMNs[j] = masternodeList[i];
                j++;
            }
        }
        return activeMNs;
    }
} 