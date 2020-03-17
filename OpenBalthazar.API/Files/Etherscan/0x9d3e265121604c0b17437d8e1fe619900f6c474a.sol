[{"SourceCode":"pragma solidity 0.4.26;\r\n\r\n/*\r\n*\r\n*\r\n*  ___   ___ _  _ ___    _____    _            \r\n* |   \\ / __| \\| |   \\  |_   _|__| |_____ _ _  \r\n* | |) | (__| .\u0060 | |) |   | |/ _ \\ / / -_) \u0027 \\ \r\n* |___/ \\___|_|\\_|___/    |_|\\___/_\\_\\___|_||_|\r\n*                                              \r\n*\r\n*\r\n*/\r\n\r\n// SafeMath methods\r\nlibrary SafeMath {\r\n    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n        uint256 c = _a \u002B _b;\r\n        assert(c \u003E= _a);\r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n        assert(_a \u003E= _b);\r\n        return _a - _b;\r\n    }\r\n\r\n    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n        uint256 c = _a * _b;\r\n        assert(_a == 0 || c / _a == _b);\r\n        return c;\r\n    }\r\n}\r\n\r\n// Contract must have an owner\r\ncontract Owned {\r\n    address public owner;\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    function setOwner(address _owner) onlyOwner public {\r\n        owner = _owner;\r\n    }\r\n}\r\n\r\n// Standard ERC20 Token Interface\r\ninterface ERC20Token {\r\n    function name() external view returns (string name_);\r\n    function symbol() external view returns (string symbol_);\r\n    function decimals() external view returns (uint8 decimals_);\r\n    function totalSupply() external view returns (uint256 totalSupply_);\r\n    function balanceOf(address _owner) external view returns (uint256 _balance);\r\n    function transfer(address _to, uint256 _value) external returns (bool _success);\r\n    function transferFrom(address _from, address _to, uint256 _value) external returns (bool _success);\r\n    function approve(address _spender, uint256 _value) external returns (bool _success);\r\n    function allowance(address _owner, address _spender) external view returns (uint256 _remaining);\r\n\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n}\r\n\r\n// the main ERC20-compliant multi-timelock enabled contract\r\ncontract DCND is Owned, ERC20Token {\r\n    using SafeMath for uint256;\r\n\r\n    string private constant standard = \u0022201910261616\u0022;\r\n    string private constant version = \u0022v1.0\u0022;\r\n    string private name_ = \u0022DCND\u0022;\r\n    string private symbol_ = \u0022DCND\u0022;\r\n    uint8 private decimals_ = 18;\r\n    uint256 private totalSupply_ = 0;\r\n    mapping (address =\u003E uint256) private balanceP;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) private allowed;\r\n\r\n    mapping (address =\u003E uint256[]) private lockTime;\r\n    mapping (address =\u003E uint256[]) private lockValue;\r\n    mapping (address =\u003E uint256) private lockNum;\r\n    uint256 private later = 0;\r\n    uint256 private earlier = 0;\r\n    bool private mintable_ = true;\r\n\r\n    // burn token event\r\n    event Burn(address indexed _from, uint256 _value);\r\n\r\n    // mint token event\r\n    event Mint(address indexed _to, uint256 _value);\r\n\r\n    // timelock-related events\r\n    event TransferLocked(address indexed _from, address indexed _to, uint256 _time, uint256 _value);\r\n    event TokenUnlocked(address indexed _address, uint256 _value);\r\n\r\n    // safety method-related events\r\n    event WrongTokenEmptied(address indexed _token, address indexed _addr, uint256 _amount);\r\n    event WrongEtherEmptied(address indexed _addr, uint256 _amount);\r\n\r\n    // constructor for the ERC20 Token\r\n    constructor() public {\r\n        balanceP[msg.sender] = totalSupply_;\r\n    }\r\n\r\n    modifier validAddress(address _address) {\r\n        require(_address != 0x0);\r\n        _;\r\n    }\r\n\r\n    modifier isMintable() {\r\n        require(mintable_);\r\n        _;\r\n    }\r\n\r\n    // fast-forward the timelocks for all accounts\r\n    function setUnlockEarlier(uint256 _earlier) public onlyOwner {\r\n        earlier = earlier.add(_earlier);\r\n    }\r\n\r\n    // delay the timelocks for all accounts\r\n    function setUnlockLater(uint256 _later) public onlyOwner {\r\n        later = later.add(_later);\r\n    }\r\n\r\n    // owner may permanently disable minting\r\n    function disableMint() public onlyOwner isMintable {\r\n        mintable_ = false;\r\n    }\r\n\r\n    // show if the token is still mintable\r\n    function mintable() public view returns (bool) {\r\n        return mintable_;\r\n    }\r\n\r\n    // standard ERC20 name function\r\n    function name() public view returns (string) {\r\n        return name_;\r\n    }\r\n\r\n    // standard ERC20 symbol function\r\n    function symbol() public view returns (string) {\r\n        return symbol_;\r\n    }\r\n\r\n    // standard ERC20 decimals function\r\n    function decimals() public view returns (uint8) {\r\n        return decimals_;\r\n    }\r\n\r\n    // standard ERC20 totalSupply function\r\n    function totalSupply() public view returns (uint256) {\r\n        return totalSupply_;\r\n    }\r\n\r\n    // standard ERC20 allowance function\r\n    function allowance(address _owner, address _spender) external view returns (uint256) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n\r\n    // show unlocked balance of an account\r\n    function balanceUnlocked(address _address) public view returns (uint256 _balance) {\r\n        _balance = balanceP[_address];\r\n        uint256 i = 0;\r\n        while (i \u003C lockNum[_address]) {\r\n            if (now.add(earlier) \u003E= lockTime[_address][i].add(later)) _balance = _balance.add(lockValue[_address][i]);\r\n            i\u002B\u002B;\r\n        }\r\n        return _balance;\r\n    }\r\n\r\n    // show timelocked balance of an account\r\n    function balanceLocked(address _address) public view returns (uint256 _balance) {\r\n        _balance = 0;\r\n        uint256 i = 0;\r\n        while (i \u003C lockNum[_address]) {\r\n            if (now.add(earlier) \u003C lockTime[_address][i].add(later)) _balance = _balance.add(lockValue[_address][i]);\r\n            i\u002B\u002B;\r\n        }\r\n        return  _balance;\r\n    }\r\n\r\n    // standard ERC20 balanceOf with timelock added\r\n    function balanceOf(address _address) public view returns (uint256 _balance) {\r\n        _balance = balanceP[_address];\r\n        uint256 i = 0;\r\n        while (i \u003C lockNum[_address]) {\r\n            _balance = _balance.add(lockValue[_address][i]);\r\n            i\u002B\u002B;\r\n        }\r\n        return _balance;\r\n    }\r\n\r\n    // show timelocks in an account\r\n    function showLockTimes(address _address) public view validAddress(_address) returns (uint256[] _times) {\r\n        uint i = 0;\r\n        uint256[] memory tempLockTime = new uint256[](lockNum[_address]);\r\n        while (i \u003C lockNum[_address]) {\r\n            tempLockTime[i] = lockTime[_address][i].add(later).sub(earlier);\r\n            i\u002B\u002B;\r\n        }\r\n        return tempLockTime;\r\n    }\r\n\r\n    // show values locked in an account\u0027s timelocks\r\n    function showLockValues(address _address) public view validAddress(_address) returns (uint256[] _values) {\r\n        return lockValue[_address];\r\n    }\r\n\r\n    function showLockNum(address _address) public view validAddress(_address) returns (uint256 _lockNum) {\r\n        return lockNum[_address];\r\n    }\r\n\r\n    // Calculate and process the timelock states of an account\r\n    function calcUnlock(address _address) private {\r\n        uint256 i = 0;\r\n        uint256 j = 0;\r\n        uint256[] memory currentLockTime;\r\n        uint256[] memory currentLockValue;\r\n        uint256[] memory newLockTime = new uint256[](lockNum[_address]);\r\n        uint256[] memory newLockValue = new uint256[](lockNum[_address]);\r\n        currentLockTime = lockTime[_address];\r\n        currentLockValue = lockValue[_address];\r\n        while (i \u003C lockNum[_address]) {\r\n            if (now.add(earlier) \u003E= currentLockTime[i].add(later)) {\r\n                balanceP[_address] = balanceP[_address].add(currentLockValue[i]);\r\n                emit TokenUnlocked(_address, currentLockValue[i]);\r\n            } else {\r\n                newLockTime[j] = currentLockTime[i];\r\n                newLockValue[j] = currentLockValue[i];\r\n                j\u002B\u002B;\r\n            }\r\n            i\u002B\u002B;\r\n        }\r\n        uint256[] memory trimLockTime = new uint256[](j);\r\n        uint256[] memory trimLockValue = new uint256[](j);\r\n        i = 0;\r\n        while (i \u003C j) {\r\n            trimLockTime[i] = newLockTime[i];\r\n            trimLockValue[i] = newLockValue[i];\r\n            i\u002B\u002B;\r\n        }\r\n        lockTime[_address] = trimLockTime;\r\n        lockValue[_address] = trimLockValue;\r\n        lockNum[_address] = j;\r\n    }\r\n\r\n    // standard ERC20 transfer\r\n    function transfer(address _to, uint256 _value) public validAddress(_to) returns (bool _success) {\r\n        if (lockNum[msg.sender] \u003E 0) calcUnlock(msg.sender);\r\n        require(balanceP[msg.sender] \u003E= _value \u0026\u0026 _value \u003E= 0);\r\n        balanceP[msg.sender] = balanceP[msg.sender].sub(_value);\r\n        balanceP[_to] = balanceP[_to].add(_value);\r\n        emit Transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    // transfer Token with timelocks\r\n    function transferLocked(address _to, uint256[] _time, uint256[] _value) public validAddress(_to) returns (bool _success) {\r\n        require(_value.length == _time.length);\r\n\r\n        if (lockNum[msg.sender] \u003E 0) calcUnlock(msg.sender);\r\n        uint256 i = 0;\r\n        uint256 totalValue = 0;\r\n        while (i \u003C _value.length) {\r\n            totalValue = totalValue.add(_value[i]);\r\n            i\u002B\u002B;\r\n        }\r\n        require(balanceP[msg.sender] \u003E= totalValue \u0026\u0026 totalValue \u003E= 0);\r\n        require(lockNum[_to].add(_time.length) \u003C= 42);\r\n        i = 0;\r\n        while (i \u003C _time.length) {\r\n            if (_value[i] \u003E 0) {\r\n                balanceP[msg.sender] = balanceP[msg.sender].sub(_value[i]);\r\n                lockTime[_to].length = lockNum[_to]\u002B1;\r\n                lockValue[_to].length = lockNum[_to]\u002B1;\r\n                lockTime[_to][lockNum[_to]] = now.add(_time[i]).add(earlier).sub(later);\r\n                lockValue[_to][lockNum[_to]] = _value[i];\r\n                lockNum[_to]\u002B\u002B;\r\n            }\r\n\r\n            // emit custom TransferLocked event\r\n            emit TransferLocked(msg.sender, _to, _time[i], _value[i]);\r\n\r\n            // emit standard Transfer event for wallets\r\n            emit Transfer(msg.sender, _to, _value[i]);\r\n\r\n            i\u002B\u002B;\r\n        }\r\n        return true;\r\n    }\r\n\r\n    // TransferFrom Token with timelocks\r\n    function transferLockedFrom(address _from, address _to, uint256[] _time, uint256[] _value) public\r\n\t    validAddress(_from) validAddress(_to) returns (bool success) {\r\n        require(_value.length == _time.length);\r\n\r\n        if (lockNum[_from] \u003E 0) calcUnlock(_from);\r\n        uint256 i = 0;\r\n        uint256 totalValue = 0;\r\n        while (i \u003C _value.length) {\r\n            totalValue = totalValue.add(_value[i]);\r\n            i\u002B\u002B;\r\n        }\r\n        require(balanceP[_from] \u003E= totalValue \u0026\u0026 totalValue \u003E= 0 \u0026\u0026 allowed[_from][msg.sender] \u003E= totalValue);\r\n        require(lockNum[_to].add(_time.length) \u003C= 42);\r\n        i = 0;\r\n        while (i \u003C _time.length) {\r\n            if (_value[i] \u003E 0) {\r\n                balanceP[_from] = balanceP[_from].sub(_value[i]);\r\n                allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value[i]);\r\n                lockTime[_to].length = lockNum[_to]\u002B1;\r\n                lockValue[_to].length = lockNum[_to]\u002B1;\r\n                lockTime[_to][lockNum[_to]] = now.add(_time[i]).add(earlier).sub(later);\r\n                lockValue[_to][lockNum[_to]] = _value[i];\r\n                lockNum[_to]\u002B\u002B;\r\n            }\r\n\r\n            // emit custom TransferLocked event\r\n            emit TransferLocked(_from, _to, _time[i], _value[i]);\r\n\r\n            // emit standard Transfer event for wallets\r\n            emit Transfer(_from, _to, _value[i]);\r\n\r\n            i\u002B\u002B;\r\n        }\r\n        return true;\r\n    }\r\n\r\n    // standard ERC20 transferFrom\r\n    function transferFrom(address _from, address _to, uint256 _value) public validAddress(_from) validAddress(_to) returns (bool _success) {\r\n        if (lockNum[_from] \u003E 0) calcUnlock(_from);\r\n        require(balanceP[_from] \u003E= _value \u0026\u0026 _value \u003E= 0 \u0026\u0026 allowed[_from][msg.sender] \u003E= _value);\r\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n        balanceP[_from] = balanceP[_from].sub(_value);\r\n        balanceP[_to] = balanceP[_to].add(_value);\r\n        emit Transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    // should only be called when first setting an allowed\r\n    function approve(address _spender, uint256 _value) public validAddress(_spender) returns (bool _success) {\r\n        if (lockNum[msg.sender] \u003E 0) calcUnlock(msg.sender);\r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    // increase or decrease allowed\r\n    function increaseApproval(address _spender, uint _value) public validAddress(_spender) returns (bool _success) {\r\n        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_value);\r\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n        return true;\r\n    }\r\n\r\n    function decreaseApproval(address _spender, uint _value) public validAddress(_spender) returns (bool _success) {\r\n        if(_value \u003E= allowed[msg.sender][_spender]) {\r\n            allowed[msg.sender][_spender] = 0;\r\n        } else {\r\n            allowed[msg.sender][_spender] = allowed[msg.sender][_spender].sub(_value);\r\n        }\r\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n        return true;\r\n    }\r\n\r\n    // owner may burn own token\r\n    function burn(uint256 _value) public onlyOwner returns (bool _success) {\r\n        if (lockNum[msg.sender] \u003E 0) calcUnlock(msg.sender);\r\n        require(balanceP[msg.sender] \u003E= _value \u0026\u0026 _value \u003E= 0);\r\n        balanceP[msg.sender] = balanceP[msg.sender].sub(_value);\r\n        totalSupply_ = totalSupply_.sub(_value);\r\n        emit Burn(msg.sender, _value);\r\n        return true;\r\n    }\r\n\r\n    // owner may mint new token and increase total supply\r\n    function mint(uint256 _value) public onlyOwner isMintable returns (bool _success) {\r\n        balanceP[msg.sender] = balanceP[msg.sender].add(_value);\r\n        totalSupply_ = totalSupply_.add(_value);\r\n        emit Mint(msg.sender, _value);\r\n        return true;\r\n    }\r\n\r\n    // safety methods\r\n    function () public payable {\r\n        revert();\r\n    }\r\n\r\n    function emptyWrongToken(address _addr) onlyOwner public {\r\n        ERC20Token wrongToken = ERC20Token(_addr);\r\n        uint256 amount = wrongToken.balanceOf(address(this));\r\n        require(amount \u003E 0);\r\n        require(wrongToken.transfer(msg.sender, amount));\r\n\r\n        emit WrongTokenEmptied(_addr, msg.sender, amount);\r\n    }\r\n\r\n    // shouldn\u0027t happen, just in case\r\n    function emptyWrongEther() onlyOwner public {\r\n        uint256 amount = address(this).balance;\r\n        require(amount \u003E 0);\r\n        msg.sender.transfer(amount);\r\n\r\n        emit WrongEtherEmptied(msg.sender, amount);\r\n    }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceUnlocked\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_time\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022transferLockedFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022disableMint\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022mintable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceLocked\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_time\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022transferLocked\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022showLockTimes\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_times\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022showLockValues\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_values\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_later\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setUnlockLater\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022emptyWrongToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022emptyWrongEther\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_earlier\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setUnlockEarlier\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022showLockNum\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_lockNum\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Mint\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_time\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022TransferLocked\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022TokenUnlocked\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022WrongTokenEmptied\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022WrongEtherEmptied\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"DCND","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://641611650d69603a462141842301a914ca27fa0a08c13c87095c77b15eb11cf3"}]