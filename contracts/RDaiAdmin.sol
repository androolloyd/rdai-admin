pragma solidity ^0.4.24;
import "@aragon/apps-agent/contracts/Agent.sol";
import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/os/contracts/common/IForwarder.sol";

contract RDaiAdmin is IForwarder, AragonApp {

    /// Events
    event NewAgentSet(address agent);
    event AddToken(uint256 identifier, address rToken);
    event ContractHatChanged(address target, uint256 hatId);
    /// State
    Agent public agent;

    mapping(uint256 => address) public rTokens;

    /// ACL
    bytes32 public constant SET_AGENT_ROLE = keccak256("SET_AGENT_ROLE");
    bytes32 public constant CHANGE_ALLOC = keccak256("CHANGE_ALLOC");
    bytes32 public constant CHANGE_HAT = keccak256("CHANGE_HAT");
    bytes32 public constant CREATE_VOTE = keccak256("CREATE_VOTE");
    bytes32 public constant ADD_TOKEN = keccak256("ADD_TOKEN");
    bytes32 public constant REMOVE_TOKEN = keccak256("REMOVE_TOKEN"); // #TODO
    bytes32 public constant PROXY_UPGRADE = keccak256("PROXY_UPGRADE"); // #TODO



    function _setToken(
        string memory _tokenType,
        address _tokenAddress
    )
        internal
    {
        uint256 tokenType = uint256(keccak256(_tokenType));
        rTokens[tokenType] = _tokenAddress;
        emit AddToken(tokenType, _tokenAddress);
    }

    function forward(
        bytes _evmScript
    )
        public
    {
        require(canForward(msg.sender, _evmScript), "UNABLE TO FORWARD");
        //blacklist?
        runScript(_evmScript, new bytes(0), new address[](0));
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
            CREATE_VOTE,
            arr(_sender)
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
        address _agent
    )
        public
        onlyInit
    {

        initialized();
        // setup agents
        agent = Agent(_agent);
        emit NewAgentSet(address(_agent));
    }


    function addToken(
        string memory _tokenType,
        address _tokenAddress
    )
        public
        auth(ADD_TOKEN)
    {
        _setToken(_tokenType, _tokenAddress);
    }


    //lets an agent change the hat of any target
    function changeContractHat(
        address _target,
        uint256 _hatId
    )
        public
        auth(CHANGE_HAT)
    {
        // string memory functionSignature = "changeHatFor(address, uint256)";
        // bytes memory changeHatData = abi.encodeWithSignature(functionSignature, _target, _hatId);
        // agent.execute()
        emit ContractHatChanged(_target, _hatId);
    }
    
}
