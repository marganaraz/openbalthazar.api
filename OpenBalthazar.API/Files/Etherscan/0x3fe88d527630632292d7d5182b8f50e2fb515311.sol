[{"SourceCode":"pragma solidity ^0.4.21;\r\n\r\ncontract Token{\r\n    uint256 public totalSupply;\r\n\r\n    function balanceOf(address _owner) public constant returns (uint256 balance);\r\n    function transfer(address _to, uint256 _value) public returns (bool success);\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns   \r\n    (bool success);\r\n\r\n    function approve(address _spender, uint256 _value) public returns (bool success);\r\n\r\n    function allowance(address _owner, address _spender) public constant returns \r\n    (uint256 remaining);\r\n\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 \r\n    _value);\r\n}\r\n\r\ncontract owned {\r\n    address public owner;\r\n\r\n    function owned() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    function upgradeOwner(address newOwner) onlyOwner public {\r\n        owner = newOwner;\r\n    }\r\n}\r\n\r\ncontract SimpleToken is Token,owned {\r\n\r\n    string public name;                 //\u540D\u79F0\uFF0C\u4F8B\u5982\u0022My test token\u0022\r\n    uint8 public decimals;              //\u8FD4\u56DEtoken\u4F7F\u7528\u7684\u5C0F\u6570\u70B9\u540E\u51E0\u4F4D\u3002\u6BD4\u5982\u5982\u679C\u8BBE\u7F6E\u4E3A3\uFF0C\u5C31\u662F\u652F\u63010.001\u8868\u793A.\r\n    string public symbol;               //token\u7B80\u79F0,like MTT\r\n\r\n    function SimpleToken(uint256 _initialAmount, string _tokenName, uint8 _decimalUnits, string _tokenSymbol) public {\r\n        totalSupply = _initialAmount * 10 ** uint256(_decimalUnits);         // \u8BBE\u7F6E\u521D\u59CB\u603B\u91CF\r\n        balances[msg.sender] = totalSupply; // \u521D\u59CBtoken\u6570\u91CF\u7ED9\u4E88\u6D88\u606F\u53D1\u9001\u8005\uFF0C\u56E0\u4E3A\u662F\u6784\u9020\u51FD\u6570\uFF0C\u6240\u4EE5\u8FD9\u91CC\u4E5F\u662F\u5408\u7EA6\u7684\u521B\u5EFA\u8005\r\n\r\n        name = _tokenName;                   \r\n        decimals = _decimalUnits;          \r\n        symbol = _tokenSymbol;\r\n    }\r\n\r\n    function transfer(address _to, uint256 _value) public returns (bool success) {\r\n        _transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns \r\n    (bool success) {\r\n        require(_value \u003C= allowed[_from][msg.sender]);     // Check allowed\r\n        allowed[_from][msg.sender] -= _value;\r\n        _transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n    function balanceOf(address _owner) public constant returns (uint256 balance) {\r\n        return balances[_owner];\r\n    }\r\n\r\n\r\n    function approve(address _spender, uint256 _value) public returns (bool success)   \r\n    { \r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {\r\n        return allowed[_owner][_spender];//\u5141\u8BB8_spender\u4ECE_owner\u4E2D\u8F6C\u51FA\u7684token\u6570\r\n    }\r\n    mapping (address =\u003E uint256) balances;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) allowed;\r\n\r\n\t\r\n\t/**\r\n     * Internal transfer, only can be called by this contract\r\n     */\r\n    function _transfer(address _from, address _to, uint _value) internal {\r\n        // Prevent transfer to 0x0 address. Use burn() instead\r\n        require(_to != 0x0);\r\n        // Check if the sender has enough\r\n        require(balances[_from] \u003E= _value);\r\n        // Check for overflows\r\n        require(balances[_to] \u002B _value \u003E balances[_to]);\r\n        // Save this for an assertion in the future\r\n        uint previousBalances = balances[_from] \u002B balances[_to];\r\n        // Subtract from the sender\r\n        balances[_from] -= _value;\r\n        // Add the same to the recipient\r\n        balances[_to] \u002B= _value;\r\n        emit Transfer(_from, _to, _value);\r\n        // Asserts are used to use static analysis to find bugs in your code. They should never fail\r\n        assert(balances[_from] \u002B balances[_to] == previousBalances);\r\n    }\r\n\t\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022upgradeOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_initialAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_tokenName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_decimalUnits\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022_tokenSymbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"SimpleToken","CompilerVersion":"v0.4.21\u002Bcommit.dfe3193c","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"00000000000000000000000000000000000000000000000000000002540be4000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000008424b4920436f696e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003424b490000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://089451d1191ac6b38b8070643db5e45298fde83b2f60dfd14d7b73ea3a50f87b"}]