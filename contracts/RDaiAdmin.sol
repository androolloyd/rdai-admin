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
    event ContractHatChanged(address target, uint256 hatId);
    /// State
    Agent public agent;
    Voting public voting;

    mapping(uint256 => address) public rTokens;

    /// ACL
    bytes32 public constant SET_AGENT_ROLE = keccak256("SET_AGENT_ROLE");
    bytes32 public constant SET_CONTRACT_ROLE = keccak256("SET_CONTRACT_ROLE");
    bytes32 public constant CHANGE_ALLOC = keccak256("CHANGE_ALLOC");
    bytes32 public constant CHANGE_HAT = keccak256("CHANGE_HAT");
    bytes32 public constant EXECUTE_VOTE = keccak256("EXECUTE_VOTE");
    bytes32 public constant CREATE_VOTE = keccak256("CREATE_VOTE");
    bytes32 public constant ADD_TOKEN = keccak256("ADD_TOKEN");
    bytes32 public constant REMOVE_TOKEN = keccak256("REMOVE_TOKEN"); // #TODO


    function forward(
        bytes _evmScript
    )
        public
    {
        require(canForward(msg.sender, _evmScript));
        uint256 voteId = voting.newVote(
            _evmScript,
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
        returns (bool)
    {
        return canPerform(
            _sender,
            voting.CREATE_VOTES_ROLE,
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

    function _setToken(
        uint256 _tokenType,
        address _tokenAddress
    )
        internal
    {
        rTokens[_tokenType] = _tokenAddress;
        emit AddToken(_tokenType, _tokenAddress);
    }
    // do we need to setup the agent before hand or should the dao own the creation of these?
    /// @dev rToken contract address
    function initialize(
        address _agent,
        address _voting,
        uint256 _rTokenType,
        address _rTokenAddress
    )
        public
        onlyInit
    {

        initialized();
        // setup agents
        agent = Agent(_agent);
        emit NewAgentSet(address(_agent));
        voting = Voting(_voting);
        emit NewVotingSet((address(voting)));
        //setup rTokens
        _setToken(
            _rTokenType,
            _rTokenAddress
        );
    }


    function addToken(
        uint256 _tokenType,
        address _tokenAddress
    )
        public
        authP(ADD_TOKEN, arr(_tokenAddress, _tokenType))
    {
        _setToken(_tokenType, _tokenAddress);
    }

    function removeToken(
        uint256 _tokenType
    )
    public
    authP(REMOVE_TOKEN, arr(_tokenType))
    {
        _setToken(_tokenType, address(0));
    }


    //lets an agent change the hat of any target
    function changeContractHat(
        bytes32 _rToken,
        address _target,
        uint256 _hatId
    )
        public
        authP(CHANGE_HAT, arr(_target, _hatId, uint256(_rToken)))
    {
        //verify there is contract data at the target
        string memory functionSignature = "changeHatFor(address, uint256)";
        bytes memory changeHatData = abi.encodeWithSignature(functionSignature, _target, _hatId);

        agent.execute(rTokens[_rToken], 0, changeHatData); // target, value, data

        emit ContractHatChanged(_target, _hatId);
    }
}
