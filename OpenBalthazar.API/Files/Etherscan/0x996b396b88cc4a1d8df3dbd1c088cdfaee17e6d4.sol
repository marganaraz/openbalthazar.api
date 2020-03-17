[{"SourceCode":"pragma solidity ^0.5.12;\r\n\r\ncontract SafeMath {\r\n    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint c = a \u002B b;\r\n        assert(c \u003E= a \u0026\u0026 c \u003E= b);\r\n        return c;\r\n    }\r\n}\r\n\r\n// ERC Token Standard #20 Interface\r\n// https://github.com/ethereum/EIPs/issues/20\r\ncontract ERC20Interface is SafeMath {\r\n\r\n    function totalSupply() public view returns (uint256);\r\n    function balanceOf(address tokenOwner) public view returns (uint balance);\r\n    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);\r\n    function transfer(address to, uint256 tokens) public returns (bool success);\r\n    function approve(address spender, uint256 tokens) public returns (bool success);\r\n    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 tokens);\r\n    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);\r\n}\r\n\r\ncontract PegnetToken is ERC20Interface {\r\n    string public symbol;\r\n    string public name;\r\n    uint8 public decimals = 8;\r\n    uint256 _totalSupply = 0;\r\n    // Owner of this contract\r\n    address public owner;\r\n\r\n    // Balances for each account\r\n    mapping(address =\u003E uint256) balances;\r\n\r\n    // Owner of account approves the transfer of an amount to another account\r\n    mapping(address =\u003E mapping (address =\u003E uint256)) allowed;\r\n\r\n    // Constructor\r\n    constructor(string memory _symbol,string memory _name) public {\r\n        owner = msg.sender;\r\n        symbol = _symbol;\r\n        name = _name;\r\n    }\r\n\r\n    function totalSupply() view public returns (uint256 ts) {\r\n        ts = _totalSupply;\r\n    }\r\n\r\n    // What is the balance of a particular account?\r\n    function balanceOf(address _owner) view public returns (uint256 balance) {\r\n        return balances[_owner];\r\n    }\r\n\r\n    // Transfer the balance from sender\u0027s account to another account\r\n    function transfer(address _to, uint256 _amount) public returns (bool success) {\r\n        if (balances[msg.sender] \u003E= _amount\r\n            \u0026\u0026 _amount \u003E 0\r\n            \u0026\u0026 balances[_to] \u002B _amount \u003E balances[_to]) {\r\n            balances[msg.sender] = safeSub(balances[msg.sender], _amount);\r\n            balances[_to] = safeAdd(balances[_to], _amount);\r\n            emit Transfer(msg.sender, _to, _amount);\r\n            return true;\r\n        } else {\r\n            return false;\r\n        }\r\n    }\r\n\r\n    // Send _value amount of tokens from address _from to address _to\r\n    // The transferFrom method is used for a withdraw workflow, allowing contracts to send\r\n    // tokens on your behalf, for example to \u0022deposit\u0022 to a contract address and/or to charge\r\n    // fees in sub-currencies; the command should fail unless the _from account has\r\n    // deliberately authorized the sender of the message via some mechanism; we propose\r\n    // these standardized APIs for approval:\r\n    function transferFrom(\r\n        address _from,\r\n        address _to,\r\n        uint256 _amount\r\n    ) public returns (bool success) {\r\n        if (balances[_from] \u003E= _amount\r\n            \u0026\u0026 allowed[_from][msg.sender] \u003E= _amount\r\n            \u0026\u0026 _amount \u003E 0\r\n            \u0026\u0026 balances[_to] \u002B _amount \u003E balances[_to]) {\r\n            balances[_from] = safeSub(balances[_from], _amount);\r\n            allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _amount);\r\n            balances[_to] = safeAdd(balances[_to], _amount);\r\n            emit Transfer(_from, _to, _amount);\r\n            return true;\r\n        } else {\r\n            return false;\r\n        }\r\n    }\r\n    // change the owner of this smart contract\r\n    function changeOwner(address new_owner) public {\r\n        require (msg.sender == owner, \u0022only the owner can change ownership\u0022);\r\n        owner = new_owner;\r\n    }\r\n    // create token and send to user\r\n    function issue(address _receiver, uint256 _amount) public {\r\n        require (msg.sender == owner, \u0022only contract owner can issue.\u0022);\r\n        _totalSupply = safeAdd(_totalSupply, _amount);\r\n        balances[_receiver] = safeAdd(balances[_receiver], _amount);\r\n        emit Transfer(owner, _receiver, _amount);\r\n    }\r\n\r\n    // destroy token when the user claims their tokens\r\n    function burn(uint256 _amount) public {\r\n        require (msg.sender == owner, \u0022only contract owner can burn.\u0022);\r\n        require (balances[owner] \u003E= _amount \u0026\u0026 _totalSupply \u003E= _amount, \u0022the consumer must have at least the amount of tokens to be burned, and there must be at least that much in the total supply\u0022);\r\n        _totalSupply = safeSub(_totalSupply, _amount);\r\n        balances[owner] = safeSub(balances[owner], _amount);\r\n    }\r\n\r\n    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.\r\n    // If this function is called again it overwrites the current allowance with _value.\r\n    function approve(address _spender, uint256 _amount) public returns (bool success) {\r\n        allowed[msg.sender][_spender] = _amount;\r\n        emit Approval(msg.sender, _spender, _amount);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022new_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022issue\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022ts\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"PegnetToken","CompilerVersion":"v0.5.13\u002Bcommit.5b0b510c","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000035045470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c5065674e657420546f6b656e0000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://6545418da71f8e0046c89f61b3b250da4f5c3f6b5dd5c2eb202ff9dad29e3850"}]