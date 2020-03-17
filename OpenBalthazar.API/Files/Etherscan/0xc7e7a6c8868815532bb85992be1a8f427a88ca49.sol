[{"SourceCode":"pragma solidity ^0.5.11;\r\n\r\n/**\r\n * Math operations with safety checks\r\n */\r\ncontract SafeMath {\r\n    function mul(uint256 a, uint256 b)pure internal returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n        uint256 c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b)pure internal returns (uint256) {\r\n        // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b)pure internal returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b)pure internal returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n\r\n}\r\n\r\ncontract ERC20 {\r\n\r\n    function transfer( address to, uint value) public returns (bool ok);\r\n    function transferFrom( address from, address to, uint value) public returns (bool ok);\r\n    function approve( address spender, uint value ) public returns (bool ok);\r\n\r\n    event Transfer( address indexed from, address indexed to, uint value);\r\n    event Approval( address indexed owner, address indexed spender, uint value);\r\n}\r\n\r\ncontract GXP is ERC20, SafeMath{\r\n    string public name;\r\n    string public symbol;\r\n    uint8 public decimals;\r\n    address payable public owner;\r\n    address public _freeze;\r\n    bool public paused = false;\r\n    uint256 public totalSupply;\r\n\r\n    /* This creates an array with all balances */\r\n    mapping (address =\u003E uint256) public balanceOf;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) public allowance;\r\n    mapping (address =\u003E uint256) public freezeOf;\r\n\r\n\r\n\r\n    /* This notifies clients about the amount burnt */\r\n    event Burn(address indexed from, uint256 value);\r\n\r\n    /* This notifies clients about the amount frozen */\r\n    event Freeze(address indexed from, uint256 value);\r\n\r\n    /* This notifies clients about the amount unfrozen */\r\n    event Unfreeze(address indexed from, uint256 value);\r\n\r\n    /* This notifies clients about the contract pause */\r\n    event Pause(address indexed from);\r\n\r\n    /* This notifies clients about the contract pause */\r\n    event Unpause(address indexed from);\r\n\r\n    /* Initializes contract with initial supply tokens to the creator of the contract */\r\n    constructor(\r\n        uint256 initialSupply,\r\n        string memory tokenName,\r\n        uint8 decimalUnits,\r\n        string memory tokenSymbol,\r\n        address freezeAddr\r\n    ) public {\r\n        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens\r\n        totalSupply = initialSupply;                        // Update total supply\r\n        name = tokenName;                                   // Set the name for display purposes\r\n        symbol = tokenSymbol;                               // Set the symbol for display purposes\r\n        decimals = decimalUnits;                            // Amount of decimals for display purposes\r\n        owner = msg.sender;\r\n        _freeze = freezeAddr;\r\n    }\r\n\r\n\r\n    /* Send coins */\r\n    function transfer(address _to, uint256 _value) public returns (bool success)  {\r\n        require(!paused,\u0022contract is paused\u0022);\r\n        require(_to != address(0), \u0022ERC20: transfer from the zero address\u0022);                             // Prevent transfer to 0x0 address. Use burn() instead\r\n        require(_value \u003E0);\r\n        require(balanceOf[msg.sender] \u003E= _value,\u0022balance not enouth\u0022);           // Check if the sender has enough\r\n        require(balanceOf[_to] \u002B _value \u003E= balanceOf[_to]);  // Check for overflows\r\n        balanceOf[msg.sender] = sub(balanceOf[msg.sender], _value);                     // Subtract from the sender\r\n        balanceOf[_to] = add(balanceOf[_to], _value);                            // Add the same to the recipient\r\n        emit Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place\r\n        return true;\r\n    }\r\n\r\n    /* Allow another contract to spend some tokens in your behalf */\r\n    function approve(address _spender, uint256 _value) public\r\n    returns (bool success) {\r\n        require(!paused,\u0022contract is paused\u0022);\r\n        require(_value \u003E 0);\r\n        allowance[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender,_spender,_value);\r\n        return true;\r\n    }\r\n\r\n\r\n    /* A contract attempts to get the coins */\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {\r\n        require(!paused,\u0022contract is paused\u0022);\r\n        require(_to != address(0), \u0022ERC20: transfer from the zero address\u0022);                            // Prevent transfer to 0x0 address. Use burn() instead\r\n        require(_to == msg.sender);\r\n        require(_value \u003E0);\r\n        require(balanceOf[_from] \u003E= _value,\u0022the balance of from address not enough\u0022);                 // Check if the sender has enough\r\n        require(balanceOf[_to] \u002B _value \u003E= balanceOf[_to]);  // Check for overflows\r\n        require(_value \u003C= allowance[_from][msg.sender], \u0022from allowance not enough\u0022);     // Check allowance\r\n        balanceOf[_from] = sub(balanceOf[_from], _value);                           // Subtract from the sender\r\n        balanceOf[_to] = add(balanceOf[_to], _value);                             // Add the same to the recipient\r\n        allowance[_from][msg.sender] = sub(allowance[_from][msg.sender], _value);\r\n        emit Transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function burn(uint256 _value) public returns (bool success) {\r\n        require(!paused,\u0022contract is paused\u0022);\r\n        require(balanceOf[msg.sender] \u003E= _value,\u0022balance not enough\u0022);            // Check if the sender has enough\r\n        require(_value \u003E0);\r\n        balanceOf[msg.sender] = sub(balanceOf[msg.sender], _value);                      // Subtract from the sender\r\n        totalSupply = sub(totalSupply,_value);                                // Updates totalSupply\r\n        emit Burn(msg.sender, _value);\r\n        return true;\r\n    }\r\n\r\n    function freeze(address _address, uint256 _value) public returns (bool success) {\r\n        require(!paused,\u0022contract is paused\u0022);\r\n        require(msg.sender == owner|| msg.sender == _freeze,\u0022no permission\u0022);\r\n        require(balanceOf[_address] \u003E= _value,\u0022address balance not enough\u0022);            // Check if the sender has enough\r\n        require(_value \u003E0);\r\n        balanceOf[_address] = sub(balanceOf[_address], _value);                      // Subtract from the sender\r\n        freezeOf[_address] = add(freezeOf[_address], _value);                                // Updates totalSupply\r\n        emit Freeze(_address, _value);\r\n        return true;\r\n    }\r\n\r\n    function unfreeze(address _address, uint256 _value) public returns (bool success) {\r\n        require(!paused,\u0022contract is paused\u0022);\r\n        require(msg.sender == owner|| msg.sender == _freeze,\u0022no permission\u0022);\r\n        require(freezeOf[_address] \u003E= _value,\u0022freeze balance not enough\u0022);            // Check if the sender has enough\r\n        require(_value \u003E0);\r\n        freezeOf[_address] = sub(freezeOf[_address], _value);                      // Subtract from the sender\r\n        balanceOf[_address] = add(balanceOf[_address], _value);\r\n        emit Unfreeze(_address, _value);\r\n        return true;\r\n    }\r\n\r\n    // transfer balance to owner\r\n    function withdrawEther(uint256 amount) public {\r\n        require(msg.sender == owner,\u0022no permission\u0022);\r\n        owner.transfer(amount);\r\n    }\r\n\r\n    // can accept ether\r\n    function() external payable {\r\n    }\r\n\r\n    function pause() public{\r\n        require(msg.sender == owner|| msg.sender == _freeze,\u0022no permission\u0022);\r\n        paused = true;\r\n        emit Pause(msg.sender);\r\n    }\r\n    function unpause() public{\r\n        require(msg.sender == owner|| msg.sender == _freeze,\u0022no permission\u0022);\r\n        paused = false;\r\n        emit Unpause(msg.sender);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022freeze\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawEther\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_freeze\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022unfreeze\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022freezeOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022initialSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022tokenName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022decimalUnits\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022tokenSymbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022freezeAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Freeze\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Unfreeze\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Pause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Unpause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"GXP","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"00000000000000000000000000000000000000000110f837d8942a518a00000000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000e00000000000000000000000009459cc6a7edb408bd0eb21b0bb4d75cf30ee2c50000000000000000000000000000000000000000000000000000000000000001547636f78696e20506c6174666f726d20546f6b656e000000000000000000000000000000000000000000000000000000000000000000000000000000000000034758500000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://e8880a7412e51ee166d3828edfdaecec2a2625bbd0758dd8a216942a569a505b"}]