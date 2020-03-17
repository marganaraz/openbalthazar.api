[{"SourceCode":"pragma solidity ^0.4.18;\r\n// ----------------------------------------------------------------------------\r\n//\r\n// Symbol      : ECOB\r\n// Name        : Ecobit\r\n// Total supply: 888,888,888\r\n// Decimals    : 3\r\n//\r\n// (c) Doops International 2019. The MIT Licence.\r\n// ----------------------------------------------------------------------------\r\n/**\r\n * Math operations with safety checks\r\n */\r\nlibrary SafeMath {\r\n  function mul(uint a, uint b) internal pure returns (uint) {\r\n    uint c = a * b;\r\n    assert(a == 0 || c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint a, uint b) internal pure returns (uint) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    uint c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n\r\n  function sub(uint a, uint b) internal pure returns (uint) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function add(uint a, uint b) internal pure returns (uint) {\r\n    uint c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n\r\n  function max64(uint64 a, uint64 b) internal pure returns (uint64) {\r\n    return a \u003E= b ? a : b;\r\n  }\r\n\r\n  function min64(uint64 a, uint64 b) internal pure returns (uint64) {\r\n    return a \u003C b ? a : b;\r\n  }\r\n\r\n  function max256(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    return a \u003E= b ? a : b;\r\n  }\r\n\r\n  function min256(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    return a \u003C b ? a : b;\r\n  }\r\n}\r\n\r\ncontract MultiOwner {\r\n    /* Constructor */\r\n    event OwnerAdded(address newOwner);\r\n    event OwnerRemoved(address oldOwner);\r\n\tevent RequirementChanged(uint256 newRequirement);\r\n\t\r\n    uint256 public ownerRequired;\r\n    mapping (address =\u003E bool) public isOwner;\r\n\tmapping (address =\u003E bool) public RequireDispose;\r\n\taddress[] owners;\r\n\t\r\n\tfunction MultiOwner(address[] _owners, uint256 _required) public {\r\n        ownerRequired = _required;\r\n        isOwner[msg.sender] = true;\r\n        owners.push(msg.sender);\r\n        \r\n        for (uint256 i = 0; i \u003C _owners.length; \u002B\u002Bi){\r\n\t\t\trequire(!isOwner[_owners[i]]);\r\n\t\t\tisOwner[_owners[i]] = true;\r\n\t\t\towners.push(_owners[i]);\r\n        }\r\n    }\r\n    \r\n\tmodifier onlyOwner {\r\n\t    require(isOwner[msg.sender]);\r\n        _;\r\n    }\r\n    \r\n\tmodifier ownerDoesNotExist(address owner) {\r\n\t\trequire(!isOwner[owner]);\r\n        _;\r\n    }\r\n\r\n    modifier ownerExists(address owner) {\r\n\t\trequire(isOwner[owner]);\r\n        _;\r\n    }\r\n    \r\n    function addOwner(address owner) onlyOwner ownerDoesNotExist(owner) external{\r\n        isOwner[owner] = true;\r\n        owners.push(owner);\r\n        OwnerAdded(owner);\r\n    }\r\n    \r\n\tfunction numberOwners() public constant returns (uint256 NumberOwners){\r\n\t    NumberOwners = owners.length;\r\n\t}\r\n\t\r\n    function removeOwner(address owner) onlyOwner ownerExists(owner) external{\r\n\t\trequire(owners.length \u003E 2);\r\n        isOwner[owner] = false;\r\n\t\tRequireDispose[owner] = false;\r\n        for (uint256 i=0; i\u003Cowners.length - 1; i\u002B\u002B){\r\n            if (owners[i] == owner) {\r\n\t\t\t\towners[i] = owners[owners.length - 1];\r\n                break;\r\n            }\r\n\t\t}\r\n\t\towners.length -= 1;\r\n        OwnerRemoved(owner);\r\n    }\r\n    \r\n\tfunction changeRequirement(uint _newRequired) onlyOwner external {\r\n\t\trequire(_newRequired \u003E= owners.length);\r\n        ownerRequired = _newRequired;\r\n        RequirementChanged(_newRequired);\r\n    }\r\n\t\r\n\tfunction ConfirmDispose() onlyOwner() public view returns (bool){\r\n\t\tuint count = 0;\r\n\t\tfor (uint i=0; i\u003Cowners.length - 1; i\u002B\u002B)\r\n            if (RequireDispose[owners[i]])\r\n                count \u002B= 1;\r\n            if (count == ownerRequired)\r\n                return true;\r\n\t}\r\n\t\r\n\tfunction kill() onlyOwner() public{\r\n\t\tRequireDispose[msg.sender] = true;\r\n\t\tif(ConfirmDispose()){\r\n\t\t\tselfdestruct(msg.sender);\r\n\t\t}\r\n    }\r\n}\r\n\r\ninterface ERC20{\r\n    function transfer(address _to, uint _value, bytes _data) public;\r\n    function transfer(address _to, uint256 _value) public;\r\n    function transferFrom(address _from, address _to, uint256 _value, bool _feed, uint256 _fees) public returns (bool success);\r\n    function setPrices(uint256 newValue) public;\r\n    function freezeAccount(address target, bool freeze) public;\r\n    function() payable public;\r\n\tfunction remainBalanced() public constant returns (uint256);\r\n\tfunction execute(address _to, uint _value, bytes _data) external returns (bytes32 _r);\r\n\tfunction isConfirmed(bytes32 TransHash) public constant returns (bool);\r\n\tfunction confirmationCount(bytes32 TransHash) external constant returns (uint count);\r\n    function confirmTransaction(bytes32 TransHash) public;\r\n    function executeTransaction(bytes32 TransHash) public;\r\n\tfunction AccountVoid(address _from) public;\r\n\tfunction burn(uint amount) public;\r\n\tfunction bonus(uint amount) public;\r\n    \r\n    event SubmitTransaction(bytes32 transactionHash);\r\n\tevent Confirmation(address sender, bytes32 transactionHash);\r\n\tevent Execution(bytes32 transactionHash);\r\n\tevent FrozenFunds(address target, bool frozen);\r\n    event Transfer(address indexed from, address indexed to, uint value);\r\n\tevent FeePaid(address indexed from, address indexed to, uint256 value);\r\n\tevent VoidAccount(address indexed from, address indexed to, uint256 value);\r\n\tevent Bonus(uint256 value);\r\n\tevent Burn(uint256 value);\r\n}\r\n\r\ninterface ERC223 {\r\n    function transfer(address to, uint value, bytes data) public;\r\n    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);\r\n}\r\n\r\ncontract Token is MultiOwner, ERC20, ERC223{\r\n\tusing SafeMath for uint256;\r\n\t\r\n\tstring public name = \u0022Ecobit\u0022;\r\n\tstring public symbol = \u0022ECOB\u0022;\r\n\tuint8 public decimals = 3;\r\n\tuint256 public totalSupply = 888888888 * 10 ** uint256(decimals);\r\n\tuint256 public EthPerToken = 800000;\r\n\t\r\n\tmapping(address =\u003E uint256) public balanceOf;\r\n\tmapping(address =\u003E bool) public frozenAccount;\r\n\tmapping (bytes32 =\u003E mapping (address =\u003E bool)) public Confirmations;\r\n\tmapping (bytes32 =\u003E Transaction) public Transactions;\r\n\t\r\n\tstruct Transaction {\r\n\t\taddress destination;\r\n\t\tuint value;\r\n\t\tbytes data;\r\n\t\tbool executed;\r\n    }\r\n\t\r\n\tmodifier notNull(address destination) {\r\n\t\trequire (destination != 0x0);\r\n        _;\r\n    }\r\n\t\r\n\tmodifier confirmed(bytes32 transactionHash) {\r\n\t\trequire (Confirmations[transactionHash][msg.sender]);\r\n        _;\r\n    }\r\n\r\n    modifier notConfirmed(bytes32 transactionHash) {\r\n\t\trequire (!Confirmations[transactionHash][msg.sender]);\r\n        _;\r\n    }\r\n\t\r\n\tmodifier notExecuted(bytes32 TransHash) {\r\n\t\trequire (!Transactions[TransHash].executed);\r\n        _;\r\n    }\r\n    \r\n\tfunction Token(address[] _owners, uint256 _required) MultiOwner(_owners, _required) public {\r\n\t\tbalanceOf[msg.sender] = totalSupply;\r\n    }\r\n\t\r\n\t/* Internal transfer, only can be called by this contract */\r\n    function _transfer(address _from, address _to, uint256 _value) internal {\r\n        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead\r\n        require (balanceOf[_from] \u003E= _value);                // Check if the sender has enough\r\n        require (balanceOf[_to].add(_value) \u003E= balanceOf[_to]); // Check for overflows\r\n        require(!frozenAccount[_from]);                     // Check if sender is frozen\r\n\t\tuint256 previousBalances = balanceOf[_from].add(balanceOf[_to]);\r\n        balanceOf[_from] = balanceOf[_from].sub(_value);                         // Subtract from the sender\r\n        balanceOf[_to] = balanceOf[_to].add(_value);                           // Add the same to the recipient\r\n        Transfer(_from, _to, _value);\r\n\t\tassert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);\r\n    }\r\n    \r\n    function transfer(address _to, uint _value, bytes _data) public {\r\n        require(_value \u003E 0 );\r\n        if(isContract(_to)) {\r\n            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);\r\n            receiver.tokenFallback(msg.sender, _value, _data);\r\n        }\r\n        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);\r\n        balanceOf[_to] = balanceOf[_to].add(_value);\r\n        Transfer(msg.sender, _to, _value, _data);\r\n    }\r\n    \r\n    function isContract(address _addr) private view returns (bool is_contract) {\r\n        uint length;\r\n        assembly {\r\n            //retrieve the size of the code on target address, this needs assembly\r\n            length := extcodesize(_addr)\r\n        }\r\n        return (length\u003E0);\r\n    }\r\n\t\r\n\t/* Internal transfer, only can be called by this contract */\r\n    function _collect_fee(address _from, address _to, uint256 _value) internal {\r\n        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead\r\n        require (balanceOf[_from] \u003E= _value);                // Check if the sender has enough\r\n        require (balanceOf[_to].add(_value) \u003E= balanceOf[_to]); // Check for overflows\r\n        require(!frozenAccount[_from]);                     // Check if sender is frozen\r\n\t\tuint256 previousBalances = balanceOf[_from].add(balanceOf[_to]);\r\n        balanceOf[_from] = balanceOf[_from].sub(_value);                         // Subtract from the sender\r\n        balanceOf[_to] = balanceOf[_to].add(_value);                           // Add the same to the recipient\r\n\t\tFeePaid(_from, _to, _value);\r\n\t\tassert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);\r\n    }\r\n\t\r\n\tfunction transfer(address _to, uint256 _value) public {\r\n\t\t_transfer(msg.sender, _to, _value);\r\n\t}\r\n\t\t\r\n\tfunction transferFrom(address _from, address _to, uint256 _value, bool _feed, uint256 _fees) onlyOwner public returns (bool success) {\r\n\t\tuint256 charge = 0 ;\r\n\t\tuint256 t_value = _value;\r\n\t\tif(_feed){\r\n\t\t\tcharge = _value * _fees / 100;\r\n\t\t}else{\r\n\t\t\tcharge = _value - (_value / (_fees \u002B 100) * 100);\r\n\t\t}\r\n\t\tt_value = _value.sub(charge);\r\n\t\trequire(t_value.add(charge) == _value);\r\n        _transfer(_from, _to, t_value);\r\n\t\t_collect_fee(_from, this, charge);\r\n        return true;\r\n    }\r\n\t\r\n\tfunction setPrices(uint256 newValue) onlyOwner public {\r\n        EthPerToken = newValue;\r\n    }\r\n\t\r\n    function freezeAccount(address target, bool freeze) onlyOwner public {\r\n        frozenAccount[target] = freeze;\r\n        FrozenFunds(target, freeze);\r\n    }\r\n\t\r\n\tfunction() payable public{\r\n\t\trequire(msg.value \u003E 0);\r\n\t\tuint amount = msg.value * 10 ** uint256(decimals) * EthPerToken / 1 ether;\r\n        _transfer(this, msg.sender, amount);\r\n    }\r\n\t\r\n\tfunction remainBalanced() public constant returns (uint256){\r\n        return balanceOf[this];\r\n    }\r\n\t\r\n\t/*Transfer Eth */\r\n\tfunction execute(address _to, uint _value, bytes _data) notNull(_to) onlyOwner external returns (bytes32 _r) {\r\n\t\t_r = addTransaction(_to, _value, _data);\r\n\t\tconfirmTransaction(_r);\r\n    }\r\n\t\r\n\tfunction addTransaction(address destination, uint value, bytes data) private notNull(destination) returns (bytes32 TransHash){\r\n        TransHash = keccak256(destination, value, data);\r\n        if (Transactions[TransHash].destination == 0) {\r\n            Transactions[TransHash] = Transaction({\r\n                destination: destination,\r\n                value: value,\r\n                data: data,\r\n                executed: false\r\n            });\r\n            SubmitTransaction(TransHash);\r\n        }\r\n    }\r\n\t\r\n\tfunction addConfirmation(bytes32 TransHash) private onlyOwner notConfirmed(TransHash){\r\n        Confirmations[TransHash][msg.sender] = true;\r\n        Confirmation(msg.sender, TransHash);\r\n    }\r\n\t\r\n\tfunction isConfirmed(bytes32 TransHash) public constant returns (bool){\r\n        uint count = 0;\r\n        for (uint i=0; i\u003Cowners.length; i\u002B\u002B)\r\n            if (Confirmations[TransHash][owners[i]])\r\n                count \u002B= 1;\r\n            if (count == ownerRequired)\r\n                return true;\r\n    }\r\n\t\r\n\tfunction confirmationCount(bytes32 TransHash) external constant returns (uint count){\r\n        for (uint i=0; i\u003Cowners.length; i\u002B\u002B)\r\n            if (Confirmations[TransHash][owners[i]])\r\n                count \u002B= 1;\r\n    }\r\n    \r\n    function confirmTransaction(bytes32 TransHash) public onlyOwner(){\r\n        addConfirmation(TransHash);\r\n        executeTransaction(TransHash);\r\n    }\r\n    \r\n    function executeTransaction(bytes32 TransHash) public notExecuted(TransHash){\r\n        if (isConfirmed(TransHash)) {\r\n\t\t\tTransactions[TransHash].executed = true;\r\n            require(Transactions[TransHash].destination.call.value(Transactions[TransHash].value)(Transactions[TransHash].data));\r\n            Execution(TransHash);\r\n        }\r\n    }\r\n\t\r\n\tfunction AccountVoid(address _from) onlyOwner public{\r\n\t\trequire (balanceOf[_from] \u003E 0); \r\n\t\tuint256 CurrentBalances = balanceOf[_from];\r\n\t\tuint256 previousBalances = balanceOf[_from] \u002B balanceOf[msg.sender];\r\n        balanceOf[_from] -= CurrentBalances;                         \r\n        balanceOf[msg.sender] \u002B= CurrentBalances;\r\n\t\tVoidAccount(_from, msg.sender, CurrentBalances);\r\n\t\tassert(balanceOf[_from] \u002B balanceOf[msg.sender] == previousBalances);\t\r\n\t}\r\n\t\r\n\tfunction burn(uint amount) onlyOwner public{\r\n\t\tuint BurnValue = amount * 10 ** uint256(decimals);\r\n\t\trequire(balanceOf[this] \u003E= BurnValue);\r\n\t\tbalanceOf[this] -= BurnValue;\r\n\t\ttotalSupply -= BurnValue;\r\n\t\tBurn(BurnValue);\r\n\t}\r\n\t\r\n\tfunction bonus(uint amount) onlyOwner public{\r\n\t\tuint BonusValue = amount * 10 ** uint256(decimals);\r\n\t\trequire(balanceOf[this] \u002B BonusValue \u003E balanceOf[this]);\r\n\t\tbalanceOf[this] \u002B= BonusValue;\r\n\t\ttotalSupply \u002B= BonusValue;\r\n\t\tBonus(BonusValue);\r\n\t}\r\n}\r\n\r\ncontract ERC223ReceivingContract { \r\n/**\r\n * @dev Standard ERC223 function that will handle incoming token transfers.\r\n *\r\n * @param _from  Token sender address.\r\n * @param _value Amount of tokens.\r\n * @param _data  Transaction metadata.\r\n */\r\n    function tokenFallback(address _from, uint _value, bytes _data) public;\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022AccountVoid\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ConfirmDispose\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022bonus\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022kill\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022Transactions\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022destination\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022executed\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022TransHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022confirmationCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022count\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022TransHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022isConfirmed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022numberOwners\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022NumberOwners\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022TransHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022confirmTransaction\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022remainBalanced\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setPrices\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ownerRequired\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022RequireDispose\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022frozenAccount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022execute\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_r\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newRequired\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022changeRequirement\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022TransHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022executeTransaction\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Confirmations\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022freeze\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022freezeAccount\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_feed\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022_fees\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022EthPerToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owners\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_required\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022transactionHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022SubmitTransaction\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022transactionHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022Confirmation\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022transactionHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022Execution\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022frozen\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022FrozenFunds\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022FeePaid\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022VoidAccount\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Bonus\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnerAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022oldOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnerRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newRequirement\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022RequirementChanged\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Token","CompilerVersion":"v0.4.18\u002Bcommit.9cf6e910","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://440638054db98119f0e6c86da86b5222cb4122b2da4f81365d33f7964d051621"}]