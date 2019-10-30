pragma solidity ^0.4.24;
import "@aragon/apps-agent/contracts/Agent.sol";
import "@aragon/apps-voting/contracts/Voting.sol";
import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/os/contracts/common/SafeERC20.sol";
import "@aragon/os/contracts/lib/token/ERC20.sol";

contract RDaiAdmin is AragonApp {

    using SafeERC20 for ERC20;

    /// Events
    event NewAgentSet(address agent);
    event NewVotingSet(address voting);
    event AddToken(address identifier, address rToken);
    event HatChanged(address sender, address target, uint256 hatId);
    /// State
    Agent public agent;
    Voting public voting;

    mapping(bytes32 => address) public rTokens;

    mapping(bytes32 => uint256) openVotes;

    /// ACL
    bytes32 public constant SET_AGENT_ROLE = keccak256("SET_AGENT_ROLE");
    bytes32 public constant SET_CONTRACT_ROLE = keccak256("SET_CONTRACT_ROLE");
    bytes32 public constant CHANGE_ALLOC = keccak256("CHANGE_ALLOC");
    bytes32 public constant CHANGE_HAT = keccak256("CHANGE_HAT");
    bytes32 public constant EXECUTE_VOTE = keccak256("EXECUTE_VOTE");
    bytes32 public constant CREATE_VOTE = keccak256("CREATE_VOTE");


    // do we need to setup the agent before hand or should the dao own the creation of these?
    /// @dev rToken contract address
    function initialize(
        address _agent,
        address _voting,
        address _rToken
    )
        public
        onlyInit
    {

        initialized();
        // setup agents
        agent = Agent(_agent);
        voting = Voting(_voting);
        emit NewAgentSet(_agent);
        //setup rTokens
        addToken(keccak256("rDAI"), _rToken);
        emit AddToken(keccak256("rDAI"), _rToken);
    }

    function _addToken(
        bytes32 _tokenType,
        address _tokenAddress
    )
        internal
    {
        rTokens[_tokenType] = IRTokenAdmin(_tokenAddress);
    }

    function _newVote(
        bytes _executionScript,
        string _metadata,
        bool _castVote,
        bool _executeIfDecided
    )
        internal
    {
        voteId = voting.newVote(_executionScript, _metadata, _castVote, _executeIfDecided);
    }


    function newVote(
        bytes _executionScript,
        string _voteQuestion
    )
        auth(CREATE_VOTE)
        external
        returns (uint256 voteId)
    {
        bytes32 scriptHash = keccak256(_executionScript);
        if(openVotes[scriptHash] != 0) {
            (,
            bool executed,
            ,
            ,
            ,
            ,
            ,
            ,
            ,) = voting.getVote(openVotes[scriptHash]);
            require(executed, "newVote::INVALID_VOTE_STATUS");
        }
        voteId = _newVote(_executionScript, _voteQuestion, true, false);
        openVotes[scriptHash] = voteId;
    }

    function executeVote(
        uint256 _voteId
    )
        external
    {
        require(canExecute(_voteId), "executeVote::NO_EXECUTE_VOTE_ID");
        string memory functionSignature = "executeVote(uint256)";
        bytes memory executeVoteData = abi.encodeWithSignature(functionSignature, _voteId);
        agent.execute(address(voting), 0, executeVoteData);
    }

    //lets an agent change the hat of any target
    function changeHat(
        bytes32 _rToken,
        address _target,
        uint256 _hatId
    )
        external
        auth(CHANGE_HAT)
    {
        string memory functionSignature = "changeHatFor(address, uint256)";
        bytes memory changeHatData = abi.encodeWithSignature(functionSignature, _target, _hatId);
        emit HatChanged(msg.sender, _target, _hatId);
        agent.execute(rTokens[_rToken], 0, changeHatData); // target, value, data
    }
}
