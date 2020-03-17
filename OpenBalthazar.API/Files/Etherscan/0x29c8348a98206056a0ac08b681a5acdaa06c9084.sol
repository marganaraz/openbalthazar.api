[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\ncontract IMigrationContract {\r\n    function migrate(address addr, uint256 nas) public returns (bool success);\r\n}\r\n\r\n/* \u7075\u611F\u6765\u81EA\u4E8ENAS  coin*/\r\ncontract SafeMath {\r\n    function safeAdd(uint256 x, uint256 y) internal pure returns(uint256) {\r\n        uint256 z = x \u002B y;\r\n        assert((z \u003E= x) \u0026\u0026 (z \u003E= y));\r\n        return z;\r\n    }\r\n\r\n    function safeSubtract(uint256 x, uint256 y) internal pure returns(uint256) {\r\n        assert(x \u003E= y);\r\n        uint256 z = x - y;\r\n        return z;\r\n    }\r\n\r\n    function safeMult(uint256 x, uint256 y) internal pure returns(uint256) {\r\n        uint256 z = x * y;\r\n        assert((x == 0)||(z/x == y));\r\n        return z;\r\n    }\r\n\r\n}\r\n\r\ncontract Token {\r\n    uint256 public totalSupply;\r\n    function balanceOf(address _owner) public constant returns (uint256 balance);\r\n    function transfer(address _to, uint256 _value) public returns (bool success);\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\r\n    function approve(address _spender, uint256 _value) public returns (bool success);\r\n    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n}\r\n\r\n\r\n/*  ERC 20 token */\r\ncontract StandardToken is Token {\r\n\r\n    function transfer(address _to, uint256 _value) public returns (bool success) {\r\n        if (balances[msg.sender] \u003E= _value \u0026\u0026 _value \u003E 0) {\r\n            balances[msg.sender] -= _value;\r\n            balances[_to] \u002B= _value;\r\n            emit Transfer(msg.sender, _to, _value);\r\n            return true;\r\n        } else {\r\n            return false;\r\n        }\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {\r\n        if (balances[_from] \u003E= _value \u0026\u0026 allowed[_from][msg.sender] \u003E= _value \u0026\u0026 _value \u003E 0) {\r\n            balances[_to] \u002B= _value;\r\n            balances[_from] -= _value;\r\n            allowed[_from][msg.sender] -= _value;\r\n            emit Transfer(_from, _to, _value);\r\n            return true;\r\n        } else {\r\n            return false;\r\n        }\r\n    }\r\n\r\n    function balanceOf(address _owner) public constant returns (uint256 balance) {\r\n        return balances[_owner];\r\n    }\r\n\r\n    function approve(address _spender, uint256 _value) public returns (bool success) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n\r\n    mapping (address =\u003E uint256) balances;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) allowed;\r\n}\r\n\r\ncontract  BGGToken is StandardToken, SafeMath {\r\n    \r\n    // metadata\r\n    string  public constant name = \u0022BGG\u5168\u7403\u4E2D\u5C0F\u4F01\u4E1A\u80A1\u6743\u533A\u5757\u94FE\u6570\u5B57\u8D44\u4EA7\u7BA1\u7406\u57FA\u91D1\u4F1A\u0022;\r\n    string  public constant symbol = \u0022BGG\u0022;\r\n    uint256 public constant decimals = 18;\r\n    string  public version = \u00221.0\u0022;\r\n\r\n    // contracts\r\n    address public ethFundDeposit;          // ETH\u5B58\u653E\u5730\u5740\r\n    address public newContractAddr;         // token\u66F4\u65B0\u5730\u5740\r\n\r\n    // crowdsale parameters\r\n    bool    public isFunding;                // \u72B6\u6001\u5207\u6362\u5230true\r\n    uint256 public fundingStartBlock;\r\n    uint256 public fundingStopBlock;\r\n\r\n    uint256 public currentSupply;           // \u6B63\u5728\u552E\u5356\u4E2D\u7684tokens\u6570\u91CF\r\n    uint256 public tokenRaised = 0;         // \u603B\u7684\u552E\u5356\u6570\u91CFtoken\r\n    uint256 public tokenMigrated = 0;     // \u603B\u7684\u5DF2\u7ECF\u4EA4\u6613\u7684 token\r\n    uint256 public tokenExchangeRate = 300;             // \u4EE3\u5E01\u5151\u6362\u6BD4\u4F8B N\u4EE3\u5E01 \u5151\u6362 1 ETH\r\n\r\n    // events\r\n    event AllocateToken(address indexed _to, uint256 _value);   // allocate token for private sale;\r\n    event IssueToken(address indexed _to, uint256 _value);      // issue token for public sale;\r\n    event IncreaseSupply(uint256 _value);\r\n    event DecreaseSupply(uint256 _value);\r\n    event Migrate(address indexed _to, uint256 _value);\r\n\r\n    // \u8F6C\u6362\r\n    function formatDecimals(uint256 _value) internal pure returns (uint256 ) {\r\n        return _value * 10 ** decimals;\r\n    }\r\n\r\n    // constructor\r\n    constructor(\r\n        address _ethFundDeposit,\r\n        uint256 _currentSupply) public\r\n    {\r\n        ethFundDeposit = _ethFundDeposit;\r\n\r\n        isFunding = false;                           //\u901A\u8FC7\u63A7\u5236\u9884CrowdS ale\u72B6\u6001\r\n        fundingStartBlock = 0;\r\n        fundingStopBlock = 0;\r\n\r\n        currentSupply = formatDecimals(_currentSupply);\r\n        totalSupply = formatDecimals(33300000);\r\n        balances[msg.sender] = totalSupply;\r\n        require(currentSupply \u003C= totalSupply);\r\n    }\r\n\r\n    modifier isOwner()  { require(msg.sender == ethFundDeposit); _; }\r\n\r\n    ///  \u8BBE\u7F6Etoken\u6C47\u7387\r\n    function setTokenExchangeRate(uint256 _tokenExchangeRate) isOwner external {\r\n        require(_tokenExchangeRate != 0);\r\n        require(_tokenExchangeRate != tokenExchangeRate);\r\n\r\n        tokenExchangeRate = _tokenExchangeRate;\r\n    }\r\n\r\n    ///\u589E\u53D1\u4EE3\u5E01\r\n    function increaseSupply (uint256 _value) isOwner external {\r\n        uint256 value = formatDecimals(_value);\r\n        require(value \u002B currentSupply \u003C= totalSupply);\r\n        currentSupply = safeAdd(currentSupply, value);\r\n        emit IncreaseSupply(value);\r\n    }\r\n\r\n    ///\u51CF\u5C11\u4EE3\u5E01\r\n    function decreaseSupply (uint256 _value) isOwner external {\r\n        uint256 value = formatDecimals(_value);\r\n        require(value \u002B tokenRaised \u003C= currentSupply);\r\n\r\n        currentSupply = safeSubtract(currentSupply, value);\r\n        emit DecreaseSupply(value);\r\n    }\r\n\r\n    ///\u5F00\u542F\r\n    function startFunding (uint256 _fundingStartBlock, uint256 _fundingStopBlock) isOwner external {\r\n        require(!isFunding);\r\n        require(_fundingStartBlock \u003C _fundingStopBlock);\r\n        require(block.number \u003C _fundingStartBlock);\r\n\r\n        fundingStartBlock = _fundingStartBlock;\r\n        fundingStopBlock = _fundingStopBlock;\r\n        isFunding = true;\r\n    }\r\n\r\n    ///\u5173\u95ED\r\n    function stopFunding() isOwner external {\r\n        require(isFunding);\r\n        isFunding = false;\r\n    }\r\n\r\n    ///set a new contract for recieve the tokens (for update contract)\r\n    function setMigrateContract(address _newContractAddr) isOwner external {\r\n        require(_newContractAddr != newContractAddr);\r\n        newContractAddr = _newContractAddr;\r\n    }\r\n\r\n    ///set a new owner.\r\n    function changeOwner(address _newFundDeposit) isOwner() external {\r\n        require(_newFundDeposit != address(0x0));\r\n        ethFundDeposit = _newFundDeposit;\r\n    }\r\n\r\n    ///sends the tokens to new contract\r\n    function migrate() external {\r\n        require(!isFunding);\r\n        require(newContractAddr != address(0x0));\r\n\r\n        uint256 tokens = balances[msg.sender];\r\n        require(tokens != 0);\r\n\r\n        balances[msg.sender] = 0;\r\n        tokenMigrated = safeAdd(tokenMigrated, tokens);\r\n\r\n        IMigrationContract newContract = IMigrationContract(newContractAddr);\r\n        require(newContract.migrate(msg.sender, tokens));\r\n\r\n        emit Migrate(msg.sender, tokens);               // log it\r\n    }\r\n\r\n    /// \u8F6C\u8D26ETH \u5230\u56E2\u961F\r\n    function transferETH() isOwner external {\r\n        require(address(this).balance != 0);\r\n        require(ethFundDeposit.send(address(this).balance));\r\n    }\r\n\r\n    ///  \u5C06token\u5206\u914D\u5230\u9884\u5904\u7406\u5730\u5740\u3002\r\n    function allocateToken (address _addr, uint256 _eth) isOwner external {\r\n        require(_eth != 0);\r\n        require(_addr != address(0x0));\r\n\r\n        uint256 tokens = safeMult(formatDecimals(_eth), tokenExchangeRate);\r\n        require(tokens \u002B tokenRaised \u003C= currentSupply);\r\n\r\n        tokenRaised = safeAdd(tokenRaised, tokens);\r\n        balances[_addr] \u002B= tokens;\r\n\r\n        emit AllocateToken(_addr, tokens);  // \u8BB0\u5F55token\u65E5\u5FD7\r\n    }\r\n\r\n    /// \u8D2D\u4E70token\r\n    function () public payable {\r\n        require(isFunding);\r\n        require(msg.value != 0);\r\n\r\n        require(block.number \u003E= fundingStartBlock);\r\n        require(block.number \u003C= fundingStopBlock);\r\n\r\n        uint256 tokens = safeMult(msg.value, tokenExchangeRate);\r\n        require(tokens \u002B tokenRaised \u003C= currentSupply);\r\n\r\n        tokenRaised = safeAdd(tokenRaised, tokens);\r\n        balances[msg.sender] \u002B= tokens;\r\n\r\n        emit IssueToken(msg.sender, tokens);  //\u8BB0\u5F55\u65E5\u5FD7\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_eth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022allocateToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isFunding\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokenRaised\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022newContractAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokenExchangeRate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022stopFunding\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newContractAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setMigrateContract\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022version\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokenMigrated\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022currentSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_fundingStartBlock\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_fundingStopBlock\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022startFunding\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022migrate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseSupply\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newFundDeposit\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ethFundDeposit\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseSupply\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenExchangeRate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setTokenExchangeRate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022fundingStartBlock\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022transferETH\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022fundingStopBlock\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_ethFundDeposit\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_currentSupply\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022AllocateToken\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022IssueToken\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022IncreaseSupply\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022DecreaseSupply\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Migrate\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"BGGToken","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"00000000000000000000000013d15860c02742903356ba991b1edfbfc6f65b710000000000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://baef8cdb28de44e5abd12ae94fdb99614a4907f969d3203b96cf15aaa8b5ca5b"}]