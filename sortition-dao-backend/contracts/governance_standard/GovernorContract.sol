

//https://docs.openzeppelin.com/contracts/4.x/wizard

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol"; // Chainlink   
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol"; // // Chainlink

contract GovernorContract is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction, GovernorTimelockControl, VRFConsumerBaseV2 {
    // Chainlink VRF Variables Beginning
    VRFCoordinatorV2Interface public immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint256 public immutable i_interval;

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 2; // retreve 2 random values equivalent to 2 voters

    uint256[] public s_randomWords;
    uint256 public s_requestId;
    uint64 num_members;
    
    //event RequestedPickVoters(uint256 indexed requestId);
    event VotersPicked(uint256[]indexed voters);

    address payable[] private s_members; // all the members in DAO
    address payable[] private s_voters; // all te voters selected 

    // End of Chainlink Variables


    constructor(
        IVotes _token, 
        TimelockController _timelock, 
        uint256 _votingDelay, 
        uint256 _votingPeriod, 
        uint256 _quorumPercentage,
        address vrfCoordinatorV2,// used for VRF constructor line 45-49 are the required args for vrf 
        uint64 subscriptionId, //
        uint256 interval,
        bytes32 gasLane, // keyHash: how much gas spend to call this gasLane
        uint32 callbackGasLimit
        )
        Governor("GovernorContract")
        GovernorSettings(
            _votingDelay, /* Voting Delay 1 block */
            _votingPeriod, /* Voting Period 1 week */
            0 //proposal threshod
            ) 
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(_quorumPercentage)// i.e 4% quorum
        GovernorTimelockControl(_timelock)

        VRFConsumerBaseV2(vrfCoordinatorV2) { // initialize for Chainlink VRF
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        i_interval = interval;
        }

    // The following functions are overrides required by Solidity.

    function votingDelay()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function propose(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description)
        public
        override(Governor, IGovernor)
        returns (uint256)
    {
        return super.propose(targets, values, calldatas, description);
    }

    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }

    function _execute(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
    {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Assumes the subscription is funded sufficiently
    // call Chainlink to request RandomWords
    function requestRandomWords() external onlyOwner {
    // Will revert if subscription is not set and funded.
        s_requestId = i_vrfCoordinator.requestRandomWords(
        i_gasLane,
        i_subscriptionId,
        REQUEST_CONFIRMATIONS,
        i_callbackGasLimit,
        NUM_WORDS
    );
  }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
        ) internal override {
        for (uint i=0; i < s_members.length; i++) {
            s_randomWords = randomWords;
        }
      
        emit VotersPicked(s_randomWords);
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }

    function selectedVoters()
        public
        view
        returns (uint256[] memory)
    {
        return s_randomWords;
    }
}