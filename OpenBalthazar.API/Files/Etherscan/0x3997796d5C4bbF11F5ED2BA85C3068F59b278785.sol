[{"SourceCode":"/**\r\n *Submitted for verification at Etherscan.io on 2019-11-11\r\n*/\r\n\r\npragma solidity 0.5.12;\r\nlibrary SafeMath {\r\n    function mul(uint256 a, uint256 b) internal pure returns(uint256) {\r\n        uint256 result = a * b;\r\n        assert(a == 0 || result / a == b);\r\n        return result;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns(uint256) {\r\n        uint256 result = a / b;\r\n        return result;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns(uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal pure returns(uint256) {\r\n        uint256 result = a \u002B b;\r\n        assert(result \u003E= a);\r\n        return result;\r\n    }\r\n}\r\n\r\ncontract ERC20Basic {\r\n    uint256 public totalSupply;\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    function balanceOf(address who) public view returns(uint256);\r\n    function transfer(address to, uint256 value) public returns(bool);\r\n}\r\n\r\ncontract ERC20 is ERC20Basic {\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n    function allowance(address owner, address spender) public view returns(uint256);\r\n    function approve(address spender, uint256 value) public returns(bool);\r\n    function transferFrom(address from, address to, uint256 value) public returns(bool);\r\n}\r\n\r\ncontract BasicToken is ERC20Basic {\r\n    using SafeMath for uint256;\r\n\r\n    struct WalletData {\r\n        uint256 tokensAmount; //Tokens amount on wallet\r\n        uint256 freezedAmount; //Freezed tokens amount on wallet.\r\n        bool canFreezeTokens; //Is wallet can freeze tokens or not.\r\n        uint unfreezeDate; // Date when we can unfreeze tokens on wallet.\r\n    }\r\n\r\n    mapping(address =\u003E WalletData) wallets;\r\n\r\n    function transfer(address _to, uint256 _value) public notSender(_to) returns(bool) {\r\n        require(_to != address(0) \u0026\u0026 _value \u003E 0 \u0026\u0026\r\n            wallets[msg.sender].tokensAmount \u003E= _value \u0026\u0026\r\n            checkIfCanUseTokens(msg.sender, _value));\r\n\r\n        uint256 amount = wallets[msg.sender].tokensAmount.sub(_value);\r\n        wallets[msg.sender].tokensAmount = amount;\r\n        wallets[_to].tokensAmount = wallets[_to].tokensAmount.add(_value);\r\n        emit Transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function balanceOf(address _owner) public view returns(uint256 balance) {\r\n        return wallets[_owner].tokensAmount;\r\n    }\r\n    // Check wallet on unfreeze tokens amount\r\n    function checkIfCanUseTokens(address _owner, uint256 _amount) internal view returns(bool) {\r\n        uint256 unfreezedAmount = wallets[_owner].tokensAmount.sub(wallets[_owner].freezedAmount);\r\n        return _amount \u003C= unfreezedAmount;\r\n    }\r\n\r\n    // Prevents user to send transaction on his own address\r\n    modifier notSender(address _owner) {\r\n        require(msg.sender != _owner);\r\n        _;\r\n    }\r\n}\r\n\r\ncontract StandartToken is ERC20, BasicToken {\r\n    mapping(address =\u003E mapping(address =\u003E uint256)) allowed;\r\n\r\n    function approve(address _spender, uint256 _value) public returns(bool) {\r\n        require((_value == 0) || (allowed[msg.sender][_spender] == 0));\r\n        if (allowed[msg.sender][_spender] == 0) {\r\n            require(_value \u003E 0);\r\n            allowed[msg.sender][_spender] = _value;\r\n            emit Approval(msg.sender, _spender, _value);\r\n            return true;\r\n        } else {\r\n            allowed[msg.sender][_spender] = _value;\r\n            emit Approval(msg.sender, _spender, _value);\r\n            return true;\r\n        }\r\n    }\r\n\r\n    function allowance(address _owner, address _spender) public view returns(uint256 remaining) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {\r\n        require(_to != address(0) \u0026\u0026 _value \u003E 0 \u0026\u0026\r\n            checkIfCanUseTokens(_from, _value) \u0026\u0026\r\n            _value \u003C= wallets[_from].tokensAmount \u0026\u0026\r\n            _value \u003C= allowed[_from][msg.sender]);\r\n        wallets[_from].tokensAmount = wallets[_from].tokensAmount.sub(_value);\r\n        wallets[_to].tokensAmount = wallets[_to].tokensAmount.add(_value);\r\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n        emit Transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n}\r\n\r\ncontract Ownable {\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n    event TransferOwnership(address indexed _previousOwner, address indexed _newOwner);\r\n    address public owner;\r\n    function transferOwnership(address _newOwner) public returns(bool);\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n}\r\n\r\ncontract FreezableToken is StandartToken, Ownable {\r\n    event ChangeFreezePermission(address indexed _owner, bool _permission);\r\n    event FreezeTokens(address indexed _owner, uint256 _freezeAmount);\r\n    event UnfreezeTokens(address indexed _owner, uint256 _unfreezeAmount);\r\n\r\n    // Give\\deprive permission to a wallet for freeze tokens.\r\n    function giveFreezePermission(address[] memory _owners, bool _permission) public onlyOwner returns(bool) {\r\n        for (uint i = 0; i \u003C _owners.length; i\u002B\u002B) {\r\n            wallets[_owners[i]].canFreezeTokens = _permission;\r\n            emit ChangeFreezePermission(_owners[i], _permission);\r\n        }\r\n        return true;\r\n    }\r\n\r\n    function freezeAllowance(address _owner) public view returns(bool) {\r\n        return wallets[_owner].canFreezeTokens;\r\n    }\r\n    // Freeze tokens on sender wallet if have permission.\r\n    function freezeTokens(uint256 _amount, uint _unfreezeDate) public isFreezeAllowed returns(bool) {\r\n        //We can freeze tokens only if there are no frozen tokens on the wallet.\r\n        require(wallets[msg.sender].freezedAmount == 0 \u0026\u0026\r\n            wallets[msg.sender].tokensAmount \u003E= _amount \u0026\u0026 _amount \u003E 0);\r\n        wallets[msg.sender].freezedAmount = _amount;\r\n        wallets[msg.sender].unfreezeDate = _unfreezeDate;\r\n        emit FreezeTokens(msg.sender, _amount);\r\n        return true;\r\n    }\r\n\r\n    function showFreezedTokensAmount(address _owner) public view returns(uint256) {\r\n        return wallets[_owner].freezedAmount;\r\n    }\r\n\r\n    function unfreezeTokens() public returns(bool) {\r\n        require(wallets[msg.sender].freezedAmount \u003E 0 \u0026\u0026\r\n            now \u003E= wallets[msg.sender].unfreezeDate);\r\n        emit UnfreezeTokens(msg.sender, wallets[msg.sender].freezedAmount);\r\n        wallets[msg.sender].freezedAmount = 0; // Unfreeze all tokens.\r\n        wallets[msg.sender].unfreezeDate = 0;\r\n        return true;\r\n    }\r\n    //Show date in UNIX time format.\r\n    function showTokensUnfreezeDate(address _owner) public view returns(uint) {\r\n        //If wallet don\u0027t have freezed tokens - function will return 0.\r\n        return wallets[_owner].unfreezeDate;\r\n    }\r\n\r\n    function getUnfreezedTokens(address _owner) internal view returns(uint256) {\r\n        return wallets[_owner].tokensAmount.sub(wallets[_owner].freezedAmount);\r\n    }\r\n\r\n    modifier isFreezeAllowed() {\r\n        require(freezeAllowance(msg.sender));\r\n        _;\r\n    }\r\n}\r\n\r\n\r\ncontract FlamengoDigitalCryptoCurrency is FreezableToken {\r\n   \r\n    event Burn(address indexed _from, uint256 _value);\r\n    string constant public name = \u0022(FDCC) Flamengo Digital Crypto Currency\u0022;\r\n    string constant public symbol = \u0022(FDCC)\u0022;\r\n    uint constant public decimals = 18;\r\n    uint256 constant public START_TOKENS = 70000000000 * 10 ** decimals; //65Mi start\r\n\r\n    constructor() public {\r\n        wallets[owner].tokensAmount = START_TOKENS;\r\n        wallets[owner].canFreezeTokens = true;\r\n        totalSupply = START_TOKENS;\r\n    }\r\n\r\n    function burn(uint256 value) public onlyOwner returns(bool) {\r\n        require(checkIfCanUseTokens(owner, value) \u0026\u0026\r\n            wallets[owner].tokensAmount \u003E= value);\r\n        wallets[owner].tokensAmount = wallets[owner].\r\n        tokensAmount.sub(value);\r\n        totalSupply = totalSupply.sub(value);\r\n        emit Burn(owner, value);\r\n        return true;\r\n    }\r\n\r\n    function transferOwnership(address _newOwner) public notSender(_newOwner) onlyOwner returns(bool) {\r\n        require(_newOwner != address(0));\r\n        emit TransferOwnership(owner, _newOwner);\r\n        owner = _newOwner;\r\n        return true;\r\n    }\r\n\r\n    function() payable external {\r\n        revert();\r\n    }\r\n\r\n\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_permission\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022ChangeFreezePermission\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_freezeAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022FreezeTokens\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022TransferOwnership\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_unfreezeAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022UnfreezeTokens\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022START_TOKENS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022freezeAllowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_unfreezeDate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022freezeTokens\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_owners\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_permission\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022giveFreezePermission\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022showFreezedTokensAmount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022showTokensUnfreezeDate\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unfreezeTokens\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"FlamengoDigitalCryptoCurrency","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://8b52baea5b57764b8f141ffbf10f4b0073528f8391cd30fe23a43be3bad59e4a"}]