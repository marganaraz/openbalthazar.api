[{"SourceCode":"pragma solidity ^0.4.23;\r\n\r\ncontract ERC20Basic {\r\n  function totalSupply() public view returns (uint256);\r\n  function balanceOf(address who) public view returns (uint256);\r\n  function transfer(address to, uint256 value) public returns (bool);\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\nlibrary SafeMath {\r\n\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n\r\n    c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    return a / b;\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n    c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\ncontract BasicToken is ERC20Basic {\r\n  using SafeMath for uint256;\r\n\r\n  mapping(address =\u003E uint256) balances;\r\n\r\n  uint256 totalSupply_;\r\n\r\n  function totalSupply() public view returns (uint256) {\r\n    return totalSupply_;\r\n  }\r\n\r\n  function transfer(address _to, uint256 _value) public returns (bool) {\r\n    require(_to != address(0));\r\n    require(_value \u003C= balances[msg.sender]);\r\n\r\n    balances[msg.sender] = balances[msg.sender].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n    emit Transfer(msg.sender, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  function balanceOf(address _owner) public view returns (uint256) {\r\n    return balances[_owner];\r\n  }\r\n\r\n}\r\n\r\ncontract ERC20 is ERC20Basic {\r\n  function allowance(address owner, address spender)\r\n    public view returns (uint256);\r\n\r\n  function transferFrom(address from, address to, uint256 value)\r\n    public returns (bool);\r\n\r\n  function approve(address spender, uint256 value) public returns (bool);\r\n  event Approval(\r\n    address indexed owner,\r\n    address indexed spender,\r\n    uint256 value\r\n  );\r\n}\r\n\r\ncontract StandardToken is ERC20, BasicToken {\r\n  mapping (address =\u003E mapping (address =\u003E uint256)) internal allowed;\r\n\r\n  function transferFrom(\r\n    address _from,\r\n    address _to,\r\n    uint256 _value\r\n  )\r\n    public\r\n    returns (bool)\r\n  {\r\n    require(_to != address(0));\r\n    require(_value \u003C= balances[_from]);\r\n    require(_value \u003C= allowed[_from][msg.sender]);\r\n\r\n    balances[_from] = balances[_from].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n    emit Transfer(_from, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  function approve(address _spender, uint256 _value) public returns (bool) {\r\n    allowed[msg.sender][_spender] = _value;\r\n    emit Approval(msg.sender, _spender, _value);\r\n    return true;\r\n  }\r\n\r\n  function allowance(\r\n    address _owner,\r\n    address _spender\r\n   )\r\n    public\r\n    view\r\n    returns (uint256)\r\n  {\r\n    return allowed[_owner][_spender];\r\n  }\r\n\r\n  function increaseApproval(\r\n    address _spender,\r\n    uint _addedValue\r\n  )\r\n    public\r\n    returns (bool)\r\n  {\r\n    allowed[msg.sender][_spender] = (\r\n      allowed[msg.sender][_spender].add(_addedValue));\r\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n    return true;\r\n  }\r\n\r\n  function decreaseApproval(\r\n    address _spender,\r\n    uint _subtractedValue\r\n  )\r\n    public\r\n    returns (bool)\r\n  {\r\n    uint oldValue = allowed[msg.sender][_spender];\r\n    if (_subtractedValue \u003E oldValue) {\r\n      allowed[msg.sender][_spender] = 0;\r\n    } else {\r\n      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\r\n    }\r\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n    return true;\r\n  }\r\n\r\n}\r\n\r\ncontract Ownable {\r\n  address public owner;\r\n  event OwnershipRenounced(address indexed previousOwner);\r\n  event OwnershipTransferred(\r\n    address indexed previousOwner,\r\n    address indexed newOwner\r\n  );\r\n\r\n\r\n  constructor() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  function renounceOwnership() public onlyOwner {\r\n    emit OwnershipRenounced(owner);\r\n    owner = address(0);\r\n  }\r\n\r\n  function transferOwnership(address _newOwner) public onlyOwner {\r\n    _transferOwnership(_newOwner);\r\n  }\r\n\r\n  function _transferOwnership(address _newOwner) internal {\r\n    require(_newOwner != address(0));\r\n    emit OwnershipTransferred(owner, _newOwner);\r\n    owner = _newOwner;\r\n  }\r\n}\r\n\r\ncontract MintableToken is StandardToken, Ownable {\r\n  event Mint(address indexed to, uint256 amount);\r\n  event MintFinished();\r\n\r\n  bool public mintingFinished = false;\r\n\r\n  modifier canMint() {\r\n    require(!mintingFinished);\r\n    _;\r\n  }\r\n\r\n  modifier hasMintPermission() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  function mint(\r\n    address _to,\r\n    uint256 _amount\r\n  )\r\n    hasMintPermission\r\n    canMint\r\n    public\r\n    returns (bool)\r\n  {\r\n    totalSupply_ = totalSupply_.add(_amount);\r\n    balances[_to] = balances[_to].add(_amount);\r\n    emit Mint(_to, _amount);\r\n    emit Transfer(address(0), _to, _amount);\r\n    return true;\r\n  }\r\n\r\n  function finishMinting() onlyOwner canMint public returns (bool) {\r\n    mintingFinished = true;\r\n    emit MintFinished();\r\n    return true;\r\n  }\r\n}\r\n\r\ncontract FreezableToken is StandardToken {\r\n    mapping (bytes32 =\u003E uint64) internal chains;\r\n    mapping (bytes32 =\u003E uint) internal freezings;\r\n    mapping (address =\u003E uint) internal freezingBalance;\r\n    event Freezed(address indexed to, uint64 release, uint amount);\r\n    event Released(address indexed owner, uint amount);\r\n\r\n    function balanceOf(address _owner) public view returns (uint256 balance) {\r\n        return super.balanceOf(_owner) \u002B freezingBalance[_owner];\r\n    }\r\n\r\n    function actualBalanceOf(address _owner) public view returns (uint256 balance) {\r\n        return super.balanceOf(_owner);\r\n    }\r\n\r\n    function freezingBalanceOf(address _owner) public view returns (uint256 balance) {\r\n        return freezingBalance[_owner];\r\n    }\r\n\r\n    function freezingCount(address _addr) public view returns (uint count) {\r\n        uint64 release = chains[toKey(_addr, 0)];\r\n        while (release != 0) {\r\n            count\u002B\u002B;\r\n            release = chains[toKey(_addr, release)];\r\n        }\r\n    }\r\n\r\n    function getFreezing(address _addr, uint _index) public view returns (uint64 _release, uint _balance) {\r\n        for (uint i = 0; i \u003C _index \u002B 1; i\u002B\u002B) {\r\n            _release = chains[toKey(_addr, _release)];\r\n            if (_release == 0) {\r\n                return;\r\n            }\r\n        }\r\n        _balance = freezings[toKey(_addr, _release)];\r\n    }\r\n\r\n    function freezeTo(address _to, uint _amount, uint64 _until) public {\r\n        require(_to != address(0));\r\n        require(_amount \u003C= balances[msg.sender]);\r\n\r\n        balances[msg.sender] = balances[msg.sender].sub(_amount);\r\n\r\n        bytes32 currentKey = toKey(_to, _until);\r\n        freezings[currentKey] = freezings[currentKey].add(_amount);\r\n        freezingBalance[_to] = freezingBalance[_to].add(_amount);\r\n\r\n        freeze(_to, _until);\r\n        emit Transfer(msg.sender, _to, _amount);\r\n        emit Freezed(_to, _until, _amount);\r\n    }\r\n\r\n    function releaseOnce() public {\r\n        bytes32 headKey = toKey(msg.sender, 0);\r\n        uint64 head = chains[headKey];\r\n        require(head != 0);\r\n        require(uint64(block.timestamp) \u003E head);\r\n        bytes32 currentKey = toKey(msg.sender, head);\r\n\r\n        uint64 next = chains[currentKey];\r\n\r\n        uint amount = freezings[currentKey];\r\n        delete freezings[currentKey];\r\n\r\n        balances[msg.sender] = balances[msg.sender].add(amount);\r\n        freezingBalance[msg.sender] = freezingBalance[msg.sender].sub(amount);\r\n\r\n        if (next == 0) {\r\n            delete chains[headKey];\r\n        } else {\r\n            chains[headKey] = next;\r\n            delete chains[currentKey];\r\n        }\r\n        emit Released(msg.sender, amount);\r\n    }\r\n\r\n    function releaseAll() public returns (uint tokens) {\r\n        uint release;\r\n        uint balance;\r\n        (release, balance) = getFreezing(msg.sender, 0);\r\n        while (release != 0 \u0026\u0026 block.timestamp \u003E release) {\r\n            releaseOnce();\r\n            tokens \u002B= balance;\r\n            (release, balance) = getFreezing(msg.sender, 0);\r\n        }\r\n    }\r\n\r\n    function toKey(address _addr, uint _release) internal pure returns (bytes32 result) {\r\n        result = 0x5749534800000000000000000000000000000000000000000000000000000000;\r\n        assembly {\r\n            result := or(result, mul(_addr, 0x10000000000000000))\r\n            result := or(result, _release)\r\n        }\r\n    }\r\n\r\n    function freeze(address _to, uint64 _until) internal {\r\n        require(_until \u003E block.timestamp);\r\n        bytes32 key = toKey(_to, _until);\r\n        bytes32 parentKey = toKey(_to, uint64(0));\r\n        uint64 next = chains[parentKey];\r\n\r\n        if (next == 0) {\r\n            chains[parentKey] = _until;\r\n            return;\r\n        }\r\n\r\n        bytes32 nextKey = toKey(_to, next);\r\n        uint parent;\r\n\r\n        while (next != 0 \u0026\u0026 _until \u003E next) {\r\n            parent = next;\r\n            parentKey = nextKey;\r\n\r\n            next = chains[nextKey];\r\n            nextKey = toKey(_to, next);\r\n        }\r\n\r\n        if (_until == next) {\r\n            return;\r\n        }\r\n\r\n        if (next != 0) {\r\n            chains[key] = next;\r\n        }\r\n\r\n        chains[parentKey] = _until;\r\n    }\r\n}\r\n\r\ncontract BurnableToken is BasicToken {\r\n\r\n  event Burn(address indexed burner, uint256 value);\r\n  function burn(uint256 _value) public {\r\n    _burn(msg.sender, _value);\r\n  }\r\n\r\n  function _burn(address _who, uint256 _value) internal {\r\n    require(_value \u003C= balances[_who]);\r\n    balances[_who] = balances[_who].sub(_value);\r\n    totalSupply_ = totalSupply_.sub(_value);\r\n    emit Burn(_who, _value);\r\n    emit Transfer(_who, address(0), _value);\r\n  }\r\n}\r\n\r\ncontract Pausable is Ownable {\r\n  event Pause();\r\n  event Unpause();\r\n\r\n  bool public paused = false;\r\n\r\n  modifier whenNotPaused() {\r\n    require(!paused);\r\n    _;\r\n  }\r\n\r\n  modifier whenPaused() {\r\n    require(paused);\r\n    _;\r\n  }\r\n\r\n  function pause() onlyOwner whenNotPaused public {\r\n    paused = true;\r\n    emit Pause();\r\n  }\r\n\r\n  function unpause() onlyOwner whenPaused public {\r\n    paused = false;\r\n    emit Unpause();\r\n  }\r\n}\r\n\r\ncontract FreezableMintableToken is FreezableToken, MintableToken {\r\n    function mintAndFreeze(address _to, uint _amount, uint64 _until) public onlyOwner canMint returns (bool) {\r\n        totalSupply_ = totalSupply_.add(_amount);\r\n\r\n        bytes32 currentKey = toKey(_to, _until);\r\n        freezings[currentKey] = freezings[currentKey].add(_amount);\r\n        freezingBalance[_to] = freezingBalance[_to].add(_amount);\r\n\r\n        freeze(_to, _until);\r\n        emit Mint(_to, _amount);\r\n        emit Freezed(_to, _until, _amount);\r\n        emit Transfer(msg.sender, _to, _amount);\r\n        return true;\r\n    }\r\n}\r\n\r\ncontract Consts {\r\n    uint public constant TOKEN_DECIMALS = 18;\r\n    uint8 public constant TOKEN_DECIMALS_UINT8 = 18;\r\n    uint public constant TOKEN_DECIMAL_MULTIPLIER = 10 ** TOKEN_DECIMALS;\r\n    string public constant TOKEN_NAME = \u0022Mindsync\u0022;\r\n    string public constant TOKEN_SYMBOL = \u0022MAI\u0022;\r\n    bool public constant PAUSED = false;\r\n    address public constant TARGET_USER = 0x108fd0EF043b56adfD0C80A9A453a0c5ad299117;\r\n    bool public constant CONTINUE_MINTING = true;\r\n}\r\n\r\ncontract MainToken is Consts, FreezableMintableToken, BurnableToken, Pausable\r\n{\r\n    event Initialized();\r\n    bool public initialized = false;\r\n\r\n    constructor() public {\r\n        init();\r\n        transferOwnership(TARGET_USER);\r\n    }\r\n\r\n    function name() public pure returns (string _name) {\r\n        return TOKEN_NAME;\r\n    }\r\n\r\n    function symbol() public pure returns (string _symbol) {\r\n        return TOKEN_SYMBOL;\r\n    }\r\n\r\n    function decimals() public pure returns (uint8 _decimals) {\r\n        return TOKEN_DECIMALS_UINT8;\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool _success) {\r\n        require(!paused);\r\n        return super.transferFrom(_from, _to, _value);\r\n    }\r\n\r\n    function transfer(address _to, uint256 _value) public returns (bool _success) {\r\n        require(!paused);\r\n        return super.transfer(_to, _value);\r\n    }\r\n    \r\n    function init() private {\r\n        require(!initialized);\r\n        initialized = true;\r\n\r\n        if (PAUSED) {\r\n            pause();\r\n        }\r\n        \r\n        address[5] memory addresses = [address(0x56652B3Af157535dA3F6a5601F9C0C0Dfa788024),address(0x091Db50Dd49CB0Bec67BFF3CEf52724A57e7955C),address(0xdCf85aa5A932c4F9252c308929fC933B1cA321F8),address(0x68991C51518BEa730493891F45d64CBcCb72e2dF),address(0xF847B03799170FBD8981cc0913072e3a1F78ae49)];\r\n        uint[5] memory amounts = [uint(200000000000000000000000000),uint(37500000000000000000000000),uint(80000000000000000000000000),uint(50000000000000000000000000),uint(20000000000000000000000000)];\r\n        uint64[5] memory freezes = [uint64(1561928401),uint64(1585688401),uint64(1551387601),uint64(0),uint64(0)];\r\n\r\n        for (uint i = 0; i \u003C addresses.length; i\u002B\u002B) {\r\n            if (freezes[i] == 0) {\r\n                mint(addresses[i], amounts[i]);\r\n            } else {\r\n                mintAndFreeze(addresses[i], amounts[i], freezes[i]);\r\n            }\r\n        }\r\n\r\n        if (!CONTINUE_MINTING) {\r\n            finishMinting();\r\n        }\r\n\r\n        emit Initialized();\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022CONTINUE_MINTING\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getFreezing\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_release\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022_balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022mintingFinished\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_until\u0022,\u0022type\u0022:\u0022uint64\u0022}],\u0022name\u0022:\u0022mintAndFreeze\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022initialized\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022actualBalanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_NAME\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_SYMBOL\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_decimals\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_until\u0022,\u0022type\u0022:\u0022uint64\u0022}],\u0022name\u0022:\u0022freezeTo\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_DECIMAL_MULTIPLIER\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_DECIMALS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022releaseAll\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022releaseOnce\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TARGET_USER\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022finishMinting\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022PAUSED\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022freezingCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022count\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_DECIMALS_UINT8\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022freezingBalanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Initialized\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Pause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Unpause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022burner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Mint\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MintFinished\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipRenounced\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022release\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Freezed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Released\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"MainToken","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://70d17c5f430c51a2ca699834a91b9ef64b02625a393e185f147ebb9ead9553d6"}]