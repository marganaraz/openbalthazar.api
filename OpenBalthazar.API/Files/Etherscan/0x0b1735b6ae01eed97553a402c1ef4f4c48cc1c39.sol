[{"SourceCode":"pragma solidity ^0.4.8;\r\n\r\n/**\r\n * Math operations with safety checks\r\n */\r\ncontract SafeMath {\r\n  function safeMul(uint256 a, uint256 b) internal returns (uint256) {\r\n    uint256 c = a * b;\r\n    assert(a == 0 || c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function safeDiv(uint256 a, uint256 b) internal returns (uint256) {\r\n    assert(b \u003E 0);\r\n    uint256 c = a / b;\r\n    assert(a == b * c \u002B a % b);\r\n    return c;\r\n  }\r\n\r\n  function safeSub(uint256 a, uint256 b) internal returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function safeAdd(uint256 a, uint256 b) internal returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c\u003E=a \u0026\u0026 c\u003E=b);\r\n    return c;\r\n  }\r\n\r\n  function assert(bool assertion) internal {\r\n    if (!assertion) {\r\n      throw;\r\n    }\r\n  }\r\n}\r\ncontract GameChain is SafeMath{\r\n    string public name;\r\n    string public symbol;\r\n    uint8 public decimals;\r\n    uint256 public totalSupply;\r\n\taddress public owner;\r\n\r\n    /* This creates an array with all balances */\r\n    mapping (address =\u003E uint256) public balanceOf;\r\n\tmapping (address =\u003E uint256) public freezeOf;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) public allowance;\r\n\r\n    /* This generates a public event on the blockchain that will notify clients */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /* This notifies clients about the amount burnt */\r\n    event Burn(address indexed from, uint256 value);\r\n\t\r\n\t/* This notifies clients about the amount frozen */\r\n    event Freeze(address indexed from, uint256 value);\r\n\t\r\n\t/* This notifies clients about the amount unfrozen */\r\n    event Unfreeze(address indexed from, uint256 value);\r\n\r\n    /* Initializes contract with initial supply tokens to the creator of the contract */\r\n    function GameChain(\r\n        uint256 initialSupply,\r\n        string tokenName,\r\n        uint8 decimalUnits,\r\n        string tokenSymbol\r\n        ) {\r\n        name = tokenName; // Set the name for display purposes\r\n        symbol = tokenSymbol; // Set the symbol for display purposes\r\n        decimals = decimalUnits;  \r\n        totalSupply = initialSupply * 10 ** uint256(decimals);\r\n        balanceOf[msg.sender] = totalSupply;  // Amount of decimals for display purposes\r\n\t\towner = msg.sender;\r\n    }\r\n\r\n    /* Send coins */\r\n    function transfer(address _to, uint256 _value) {\r\n        if (_to == 0x0) throw;                               // Prevent transfer to 0x0 address. Use burn() instead\r\n\t\tif (_value \u003C= 0) throw; \r\n        if (balanceOf[msg.sender] \u003C _value) throw;           // Check if the sender has enough\r\n        if (balanceOf[_to] \u002B _value \u003C balanceOf[_to]) throw; // Check for overflows\r\n        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                     // Subtract from the sender\r\n        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                            // Add the same to the recipient\r\n        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place\r\n    }\r\n\r\n    /* Allow another contract to spend some tokens in your behalf */\r\n    function approve(address _spender, uint256 _value)\r\n        returns (bool success) {\r\n\t\tif (_value \u003C= 0) throw; \r\n        allowance[msg.sender][_spender] = _value;\r\n        return true;\r\n    }\r\n       \r\n\r\n    /* A contract attempts to get the coins */\r\n    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {\r\n        if (_to == 0x0) throw;                                // Prevent transfer to 0x0 address. Use burn() instead\r\n\t\tif (_value \u003C= 0) throw; \r\n        if (balanceOf[_from] \u003C _value) throw;                 // Check if the sender has enough\r\n        if (balanceOf[_to] \u002B _value \u003C balanceOf[_to]) throw;  // Check for overflows\r\n        if (_value \u003E allowance[_from][msg.sender]) throw;     // Check allowance\r\n        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                           // Subtract from the sender\r\n        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                             // Add the same to the recipient\r\n        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);\r\n        Transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function burn(uint256 _value) returns (bool success) {\r\n        if (balanceOf[msg.sender] \u003C _value) throw;            // Check if the sender has enough\r\n\t\tif (_value \u003C= 0) throw; \r\n        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender\r\n        totalSupply = SafeMath.safeSub(totalSupply,_value);                                // Updates totalSupply\r\n        Burn(msg.sender, _value);\r\n        return true;\r\n    }\r\n\t\r\n\tfunction freeze(uint256 _value) returns (bool success) {\r\n        if (balanceOf[msg.sender] \u003C _value) throw;            // Check if the sender has enough\r\n\t\tif (_value \u003C= 0) throw; \r\n        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender\r\n        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value);                                // Updates totalSupply\r\n        Freeze(msg.sender, _value);\r\n        return true;\r\n    }\r\n\t\r\n\tfunction unfreeze(uint256 _value) returns (bool success) {\r\n        if (freezeOf[msg.sender] \u003C _value) throw;            // Check if the sender has enough\r\n\t\tif (_value \u003C= 0) throw; \r\n        freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value);                      // Subtract from the sender\r\n\t\tbalanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _value);\r\n        Unfreeze(msg.sender, _value);\r\n        return true;\r\n    }\r\n\t\r\n\t// transfer balance to owner\r\n\tfunction withdrawEther(uint256 amount) {\r\n\t\tif(msg.sender != owner)throw;\r\n\t\towner.transfer(amount);\r\n\t}\r\n\t\r\n\t// can accept ether\r\n\tfunction() payable {\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawEther\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022unfreeze\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022freezeOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022freeze\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022initialSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tokenName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022decimalUnits\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022tokenSymbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Freeze\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Unfreeze\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"GameChain","CompilerVersion":"v0.4.11\u002Bcommit.68ef5810","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000000000000000000000000005f5e1000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000a47616d6520636861696e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000034745430000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://fa4e4ef7ac57e5c538048251938da558ca1936c4b8e13cd22a6210991b14e816"}]