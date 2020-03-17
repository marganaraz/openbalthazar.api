[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\ncontract Multiownable {\r\n\r\n    bool public paused = false;\r\n    uint256 public howManyOwnersDecide;\r\n    address[] public owners;\r\n    bytes32[] public allOperations;\r\n    address internal insideCallSender;\r\n    uint256 internal insideCallCount;\r\n\r\n    mapping(address =\u003E uint) public ownersIndices;\r\n    mapping(bytes32 =\u003E uint) public allOperationsIndicies;\r\n\r\n    mapping(bytes32 =\u003E uint256) public votesMaskByOperation;\r\n    mapping(bytes32 =\u003E uint256) public votesCountByOperation;\r\n\r\n    event OperationCreated(bytes32 operation, uint howMany, uint ownersCount, address proposer);\r\n    event OperationUpvoted(bytes32 operation, uint votes, uint howMany, uint ownersCount, address upvoter);\r\n    event OperationPerformed(bytes32 operation, uint howMany, uint ownersCount, address performer);\r\n    event OperationDownvoted(bytes32 operation, uint votes, uint ownersCount,  address downvoter);\r\n    event OperationCancelled(bytes32 operation, address lastCanceller);\r\n    event OwnershipRenounced(address indexed previousOwner);\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n    event Pause();\r\n    event Unpause();\r\n\r\n    function isOwner(address wallet) public constant returns(bool) {\r\n        return ownersIndices[wallet] \u003E 0;\r\n    }\r\n\r\n    function ownersCount() public view returns(uint) {\r\n        return owners.length;\r\n    }\r\n\r\n    function allOperationsCount() public  view returns(uint) {\r\n        return allOperations.length;\r\n    }\r\n\r\n    modifier onlyAnyOwner {\r\n        if (checkHowManyOwners(1)) {\r\n            bool update = (insideCallSender == address(0));\r\n            if (update) {\r\n                insideCallSender = msg.sender;\r\n                insideCallCount = 1;\r\n            }\r\n            _;\r\n            if (update) {\r\n                insideCallSender = address(0);\r\n                insideCallCount = 0;\r\n            }\r\n        }\r\n    }\r\n\r\n    modifier onlyManyOwners {\r\n        if (checkHowManyOwners(howManyOwnersDecide)) {\r\n            bool update = (insideCallSender == address(0));\r\n            if (update) {\r\n                insideCallSender = msg.sender;\r\n                insideCallCount = howManyOwnersDecide;\r\n            }\r\n            _;\r\n            if (update) {\r\n                insideCallSender = address(0);\r\n                insideCallCount = 0;\r\n            }\r\n        }\r\n    }\r\n\r\n    constructor() public {  }\r\n\r\n    function checkHowManyOwners(uint howMany) internal returns(bool) {\r\n        if (insideCallSender == msg.sender) {\r\n            require(howMany \u003C= insideCallCount, \u0022checkHowManyOwners: nested owners modifier check require more owners\u0022);\r\n            return true;\r\n        }\r\n\r\n        uint ownerIndex = ownersIndices[msg.sender] - 1;\r\n        require(ownerIndex \u003C owners.length, \u0022checkHowManyOwners: msg.sender is not an owner\u0022);\r\n        bytes32 operation = keccak256(abi.encodePacked(msg.data));\r\n\r\n        require((votesMaskByOperation[operation] \u0026 (2 ** ownerIndex)) == 0, \u0022checkHowManyOwners: owner already voted for the operation\u0022);\r\n        votesMaskByOperation[operation] |= (2 ** ownerIndex);\r\n        uint operationVotesCount = votesCountByOperation[operation] \u002B 1;\r\n        votesCountByOperation[operation] = operationVotesCount;\r\n        if (operationVotesCount == 1) {\r\n            allOperationsIndicies[operation] = allOperations.length;\r\n            allOperations.push(operation);\r\n            emit OperationCreated(operation, howMany, owners.length, msg.sender);\r\n        }\r\n        emit OperationUpvoted(operation, operationVotesCount, howMany, owners.length, msg.sender);\r\n\r\n\r\n        if (votesCountByOperation[operation] == howMany) {\r\n            deleteOperation(operation);\r\n            emit OperationPerformed(operation, howMany, owners.length, msg.sender);\r\n            return true;\r\n        }\r\n\r\n        return false;\r\n    }\r\n\r\n    function deleteOperation(bytes32 operation) internal {\r\n        uint index = allOperationsIndicies[operation];\r\n        if (index \u003C allOperations.length - 1) {\r\n            allOperations[index] = allOperations[allOperations.length - 1];\r\n            allOperationsIndicies[allOperations[index]] = index;\r\n        }\r\n        allOperations.length--;\r\n\r\n        delete votesMaskByOperation[operation];\r\n        delete votesCountByOperation[operation];\r\n        delete allOperationsIndicies[operation];\r\n    }\r\n\r\n    function cancelPending(bytes32 operation) public onlyAnyOwner {\r\n        uint ownerIndex = ownersIndices[msg.sender] - 1;\r\n        require((votesMaskByOperation[operation] \u0026 (2 ** ownerIndex)) != 0, \u0022cancelPending: operation not found for this user\u0022);\r\n        votesMaskByOperation[operation] \u0026= ~(2 ** ownerIndex);\r\n        uint operationVotesCount = votesCountByOperation[operation] - 1;\r\n        votesCountByOperation[operation] = operationVotesCount;\r\n        emit OperationDownvoted(operation, operationVotesCount, owners.length, msg.sender);\r\n        if (operationVotesCount == 0) {\r\n            deleteOperation(operation);\r\n            emit OperationCancelled(operation, msg.sender);\r\n        }\r\n    }\r\n\r\n\r\n    function transferOwnership(address _newOwner, address _oldOwner) public onlyManyOwners {\r\n        _transferOwnership(_newOwner, _oldOwner);\r\n    }\r\n\r\n    function _transferOwnership(address _newOwner, address _oldOwner) internal {\r\n        require(_newOwner != address(0));\r\n\r\n        for(uint256 i = 0; i \u003C owners.length; i\u002B\u002B) {\r\n            if (_oldOwner == owners[i]) {\r\n                owners[i] = _newOwner;\r\n                ownersIndices[_newOwner] = ownersIndices[_oldOwner];\r\n                ownersIndices[_oldOwner] = 0;\r\n                break;\r\n            }\r\n        }\r\n        emit OwnershipTransferred(_oldOwner, _newOwner);\r\n    }\r\n\r\n    modifier whenNotPaused() {\r\n        require(!paused);\r\n        _;\r\n    }\r\n\r\n    modifier whenPaused() {\r\n        require(paused);\r\n        _;\r\n    }\r\n\r\n    function pause() public onlyManyOwners whenNotPaused {\r\n\r\n        paused = true;\r\n        emit Pause();\r\n    }\r\n\r\n    function unpause() public onlyManyOwners whenPaused {\r\n        paused = false;\r\n        emit Unpause();\r\n    }\r\n}\r\n\r\ncontract GovernanceMigratable is Multiownable {\r\n    mapping(address =\u003E bool) public governanceContracts;\r\n\r\n    event GovernanceContractAdded(address addr);\r\n    event GovernanceContractRemoved(address addr);\r\n\r\n    modifier onlyGovernanceContracts() {\r\n        require(governanceContracts[msg.sender]);\r\n        _;\r\n    }\r\n\r\n    function addAddressToGovernanceContract(address addr) onlyManyOwners public returns(bool success) {\r\n        if (!governanceContracts[addr]) {\r\n            governanceContracts[addr] = true;\r\n            emit GovernanceContractAdded(addr);\r\n            success = true;\r\n        }\r\n    }\r\n\r\n    function removeAddressFromGovernanceContract(address addr) onlyManyOwners public returns(bool success) {\r\n        if (governanceContracts[addr]) {\r\n            governanceContracts[addr] = false;\r\n            emit GovernanceContractRemoved(addr);\r\n            success = true;\r\n        }\r\n    }\r\n}\r\n\r\ncontract BlacklistMigratable is GovernanceMigratable {\r\n    mapping(address =\u003E bool) public blacklist;\r\n\r\n    event BlacklistedAddressAdded(address addr);\r\n    event BlacklistedAddressRemoved(address addr);\r\n\r\n    function addAddressToBlacklist(address addr) onlyGovernanceContracts() public returns(bool success) {\r\n        if (!blacklist[addr]) {\r\n            blacklist[addr] = true;\r\n            emit BlacklistedAddressAdded(addr);\r\n            success = true;\r\n        }\r\n    }\r\n\r\n    function removeAddressFromBlacklist(address addr) onlyGovernanceContracts() public returns(bool success) {\r\n        if (blacklist[addr]) {\r\n            blacklist[addr] = false;\r\n            emit BlacklistedAddressRemoved(addr);\r\n            success = true;\r\n        }\r\n    }\r\n}\r\n\r\nlibrary SafeMath {\r\n\r\n    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {\r\n\r\n        if (_a == 0) {\r\n            return 0;\r\n        }\r\n        c = _a * _b;\r\n        assert(c / _a == _b);\r\n        return c;\r\n    }\r\n    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n        return _a / _b;\r\n    }\r\n\r\n    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n        assert(_b \u003C= _a);\r\n        return _a - _b;\r\n    }\r\n\r\n    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {\r\n        c = _a \u002B _b;\r\n        assert(c \u003E= _a);\r\n        return c;\r\n    }\r\n}\r\n\r\ncontract ERC20Basic {\r\n    function totalSupply() public view returns (uint256);\r\n    function balanceOf(address _who) public view returns (uint256);\r\n    function transfer(address _to, uint256 _value) public returns (bool);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\ncontract ERC20 is ERC20Basic {\r\n    function allowance(address _owner, address _spender)\r\n    public view returns (uint256);\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value)\r\n    public returns (bool);\r\n\r\n    function approve(address _spender, uint256 _value) public returns (bool);\r\n    event Approval(\r\n        address indexed owner,\r\n        address indexed spender,\r\n        uint256 value\r\n    );\r\n}\r\n\r\ncontract BasicToken is ERC20Basic {\r\n    using SafeMath for uint256;\r\n\r\n    mapping(address =\u003E uint256) internal balances;\r\n\r\n    uint256 internal totalSupply_;\r\n\r\n    function totalSupply() public view returns (uint256) {\r\n        return totalSupply_;\r\n    }\r\n\r\n    function transfer(address _to, uint256 _value) public returns (bool) {\r\n        require(_value \u003C= balances[msg.sender]);\r\n        require(_to != address(0));\r\n\r\n        balances[msg.sender] = balances[msg.sender].sub(_value);\r\n        balances[_to] = balances[_to].add(_value);\r\n        emit Transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function balanceOf(address _owner) public view returns (uint256) {\r\n        return balances[_owner];\r\n    }\r\n}\r\n\r\ncontract StandardToken is ERC20, BasicToken {\r\n\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) internal allowed;\r\n\r\n    function transferFrom(\r\n        address _from,\r\n        address _to,\r\n        uint256 _value\r\n    )\r\n    public\r\n    returns (bool)\r\n    {\r\n        require(_value \u003C= balances[_from]);\r\n        require(_value \u003C= allowed[_from][msg.sender]);\r\n        require(_to != address(0));\r\n\r\n        balances[_from] = balances[_from].sub(_value);\r\n        balances[_to] = balances[_to].add(_value);\r\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n        emit Transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n\r\n\r\n    function approve(address _spender, uint256 _value) public returns (bool) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n\r\n    function allowance(\r\n        address _owner,\r\n        address _spender\r\n    )\r\n    public\r\n    view\r\n    returns (uint256)\r\n    {\r\n        return allowed[_owner][_spender];\r\n    }\r\n\r\n\r\n    function increaseApproval(\r\n        address _spender,\r\n        uint256 _addedValue\r\n    )\r\n    public\r\n    returns (bool)\r\n    {\r\n        allowed[msg.sender][_spender] = (\r\n        allowed[msg.sender][_spender].add(_addedValue));\r\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n        return true;\r\n    }\r\n\r\n    function decreaseApproval(\r\n        address _spender,\r\n        uint256 _subtractedValue\r\n    )\r\n    public\r\n    returns (bool)\r\n    {\r\n        uint256 oldValue = allowed[msg.sender][_spender];\r\n        if (_subtractedValue \u003E= oldValue) {\r\n            allowed[msg.sender][_spender] = 0;\r\n        } else {\r\n            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\r\n        }\r\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n        return true;\r\n    }\r\n}\r\n\r\ncontract TruePausableToken is StandardToken, BlacklistMigratable {\r\n\r\n    function transfer(\r\n        address _to,\r\n        uint256 _value\r\n    )\r\n    public\r\n    whenNotPaused\r\n    returns (bool)\r\n    {\r\n        require(!blacklist[msg.sender]);\r\n        return super.transfer(_to, _value);\r\n    }\r\n\r\n    function transferFrom(\r\n        address _from,\r\n        address _to,\r\n        uint256 _value\r\n    )\r\n    public\r\n    whenNotPaused\r\n    returns (bool)\r\n    {\r\n        require(!blacklist[_from]);\r\n        return super.transferFrom(_from, _to, _value);\r\n    }\r\n\r\n    function approve(\r\n        address _spender,\r\n        uint256 _value\r\n    )\r\n    public\r\n    whenNotPaused\r\n    returns (bool)\r\n    {\r\n        return super.approve(_spender, _value);\r\n    }\r\n\r\n    function increaseApproval(\r\n        address _spender,\r\n        uint _addedValue\r\n    )\r\n    public\r\n    whenNotPaused\r\n    returns (bool success)\r\n    {\r\n        return super.increaseApproval(_spender, _addedValue);\r\n    }\r\n\r\n    function decreaseApproval(\r\n        address _spender,\r\n        uint _subtractedValue\r\n    )\r\n    public\r\n    whenNotPaused\r\n    returns (bool success)\r\n    {\r\n        return super.decreaseApproval(_spender, _subtractedValue);\r\n    }\r\n}\r\n\r\ncontract DetailedERC20 is ERC20 {\r\n    string public name;\r\n    string public symbol;\r\n    uint8 public decimals;\r\n\r\n    constructor(string _name, string _symbol, uint8 _decimals) public {\r\n        name = _name;\r\n        symbol = _symbol;\r\n        decimals = _decimals;\r\n    }\r\n}\r\n\r\ncontract TrueBurnableToken is BasicToken {\r\n\r\n    event Burn(address indexed burner, uint256 value);\r\n\r\n    function _burn(address _who, uint256 _value) internal {\r\n        require(_value \u003C= balances[_who]);\r\n\r\n        balances[_who] = balances[_who].sub(_value);\r\n        totalSupply_ = totalSupply_.sub(_value);\r\n        emit Burn(_who, _value);\r\n        emit Transfer(_who, address(0), _value);\r\n    }\r\n}\r\n\r\ncontract USDQToken is StandardToken, TrueBurnableToken, DetailedERC20, TruePausableToken {\r\n\r\n    event Mint(address indexed to, uint256 amount);\r\n\r\n    uint8 constant DECIMALS = 18;\r\n\r\n    constructor(address _firstOwner,\r\n                address _secondOwner,\r\n                address _thirdOwner,\r\n                address _fourthOwner,\r\n                address _fifthOwner) DetailedERC20(\u0022USDGO Stablecoin v1.0\u0022, \u0022USDGO\u0022, DECIMALS)  public {\r\n\r\n        owners.push(_firstOwner);\r\n        owners.push(_secondOwner);\r\n        owners.push(_thirdOwner);\r\n        owners.push(_fourthOwner);\r\n        owners.push(_fifthOwner);\r\n        owners.push(msg.sender);\r\n\r\n        ownersIndices[_firstOwner] = 1;\r\n        ownersIndices[_secondOwner] = 2;\r\n        ownersIndices[_thirdOwner] = 3;\r\n        ownersIndices[_fourthOwner] = 4;\r\n        ownersIndices[_fifthOwner] = 5;\r\n        ownersIndices[msg.sender] = 6;\r\n\r\n        howManyOwnersDecide = 4;\r\n    }\r\n\r\n    function mint(address _to, uint256 _amount) external onlyGovernanceContracts() returns (bool){\r\n        totalSupply_ = totalSupply_.add(_amount);\r\n        balances[_to] = balances[_to].add(_amount);\r\n        emit Mint(_to, _amount);\r\n        emit Transfer(address(0), _to, _amount);\r\n        return true;\r\n    }\r\n\r\n    function approveForOtherContracts(address _sender, address _spender, uint256 _value) external onlyGovernanceContracts() {\r\n        allowed[_sender][_spender] = _value;\r\n        emit Approval(_sender, _spender, _value);\r\n    }\r\n\r\n    function burnFrom(address _to, uint256 _amount) external onlyGovernanceContracts() returns (bool) {\r\n        allowed[_to][msg.sender] = _amount;\r\n        transferFrom(_to, msg.sender, _amount);\r\n        _burn(msg.sender, _amount);\r\n        return true;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022owners\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022allOperationsCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022howManyOwnersDecide\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022allOperations\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022votesMaskByOperation\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_oldOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022operation\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022cancelPending\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022votesCountByOperation\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ownersCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022ownersIndices\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022allOperationsIndicies\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022operation\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022howMany\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ownersCount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022proposer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OperationCreated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022operation\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022votes\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022howMany\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ownersCount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022upvoter\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OperationUpvoted\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022operation\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022howMany\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ownersCount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022performer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OperationPerformed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022operation\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022votes\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ownersCount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022downvoter\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OperationDownvoted\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022operation\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022lastCanceller\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OperationCancelled\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipRenounced\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Pause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Unpause\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Multiownable","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://26db361e417acd93dab09ad157e3b30e6d8facd41e01345948a48695daefb1f1"}]