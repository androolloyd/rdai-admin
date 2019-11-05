pragma solidity ^0.4.24;
import "@aragon/apps-agent/contracts/Agent.sol";
import "@aragon/apps-voting/contracts/Voting.sol";
import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/os/contracts/common/IForwarder.sol";

contract RDaiAdmin is IForwarder, AragonApp {

    /// Events
    event NewAgentSet(address agent);
    event NewVotingSet(address voting);
    event AddToken(bytes32 identifier, address rToken);
    event HatChanged(address sender, address target, uint256 hatId);
    /// State
    Agent public agent;
    Voting public voting;

    mapping(bytes32 => address) public rTokens;

    /// ACL
    bytes32 public constant SET_AGENT_ROLE = keccak256("SET_AGENT_ROLE");
    bytes32 public constant SET_CONTRACT_ROLE = keccak256("SET_CONTRACT_ROLE");
    bytes32 public constant CHANGE_ALLOC = keccak256("CHANGE_ALLOC");
    bytes32 public constant CHANGE_HAT = keccak256("CHANGE_HAT");
    bytes32 public constant EXECUTE_VOTE = keccak256("EXECUTE_VOTE");
    bytes32 public constant CREATE_VOTE = keccak256("CREATE_VOTE");


    function forward(
        bytes _evmScript
    )
    public
    {
        require(canForward(msg.sender, _evmScript));
        uint256 voteId = voting.newVote(
            _executionScript,
            "",
            true,
            false
        );
        require(voteId > 0, "forward::FAILED_ON_VOTE_CREATE");
    }

    function canForward(
        address _sender,
        bytes _evmCallScript
    )
    public
    view
    returns
    (bool)
    {
        return canPerform(
            _sender,
            CREATE_VOTE,
            arr()
        );
    }

    function isForwarder()
    public
    pure
    returns (bool)
    {
        return true;
    }

    // do we need to setup the agent before hand or should the dao own the creation of these?
    /// @dev rToken contract address
    function initialize(
        address _agent,
        address _voting,
        string [] _rTokenType,
        address[] _rTokenAddress
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
        for(uint i = 0; i < _rTokenType.length; i++)
        {
            _addToken(keccak256(_rTokenType[i]), _rTokenAddress[i]);
        }
    }

    function addToken(
        bytes32 _tokenType,
        address _tokenAddress
    )
        external
        authP(ADD_TOKEN, arr(_tokenType, _tokenAddress))
    {
        rTokens[_tokenType] = _tokenAddress;
        emit AddToken(_tokenType, _tokenAddress);
    }


    //lets an agent change the hat of any target
    function changeContractHat(
        bytes32 _rToken,
        address _target,
        uint256 _hatId
    )
        external
        authP(CHANGE_HAT, arr(_rToken, _target, _hatId))
    {
        //verify there is contract data at the target
        string memory functionSignature = "changeHatFor(address, uint256)";
        bytes memory changeHatData = abi.encodeWithSignature(functionSignature, _target, _hatId);

        agent.execute(rTokens[_rToken], 0, changeHatData); // target, value, data

        emit HatChanged(msg.sender, _target, _hatId);
    }
}
