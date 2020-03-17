[{"SourceCode":"pragma solidity ^0.4.21;\r\n\r\n// smart contract for KOK coin \r\n\r\n// ownership contract\r\ncontract Owned {\r\n    address public owner;\r\n\r\n    event TransferOwnership(address oldaddr, address newaddr);\r\n\r\n    modifier onlyOwner() { if (msg.sender != owner) return; _; }\r\n\r\n    function Owned() public {\r\n        owner = msg.sender;\r\n    }\r\n    \r\n    function transferOwnership(address _new) onlyOwner public {\r\n        address oldaddr = owner;\r\n        owner = _new;\r\n        emit TransferOwnership(oldaddr, owner);\r\n    }\r\n}\r\n\r\n// erc20\r\ncontract ERC20Interface {\r\n\tuint256 public totalSupply;\r\n\tfunction balanceOf(address _owner) public constant returns (uint256 balance);\r\n\tfunction transfer(address _to, uint256 _value) public returns (bool success);\r\n\tfunction transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\r\n\tfunction approve(address _spender, uint256 _value) public returns (bool success);\r\n\tfunction allowance(address _owner, address _spender) public constant returns (uint256 remaining);\r\n\tevent Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n\tevent Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n}\r\n\r\ncontract KOK_Contract is ERC20Interface, Owned {\r\n\tstring public constant symbol = \u0022KOK\u0022;\r\n\tstring public constant name = \u0022KOK Coin\u0022;\r\n\tuint8 public constant decimals = 18;\r\n\tuint256 public constant totalSupply = 5000000000000000000000000000;\r\n\r\n\tbool public stopped;\r\n\r\n\tmapping (address =\u003E int8) public blackList;\r\n\r\n\tmapping (address =\u003E uint256) public balances;\r\n\tmapping (address =\u003E mapping (address =\u003E uint256)) public allowed;\r\n\r\n\r\n    event Blacklisted(address indexed target);\r\n    event DeleteFromBlacklist(address indexed target);\r\n    event RejectedPaymentToBlacklistedAddr(address indexed from, address indexed to, uint256 value);\r\n    event RejectedPaymentFromBlacklistedAddr(address indexed from, address indexed to, uint256 value);\r\n\r\n\r\n\tmodifier notStopped {\r\n        require(!stopped);\r\n        _;\r\n    }\r\n\r\n// constructor\r\n\tfunction KOKContract() public {\r\n\t\tbalances[msg.sender] = totalSupply;\r\n\t}\r\n\t\r\n// function made for airdrop\r\n\tfunction airdrop(address[] _to, uint256[] _value) onlyOwner notStopped public {\r\n\t    for(uint256 i = 0; i \u003C _to.length; i\u002B\u002B){\r\n\t        if(balances[_to[i]] \u003E 0){\r\n\t            continue;\r\n\t        }\r\n\t        transfer(_to[i], _value[i]);\r\n\t    }\r\n\t}\r\n\r\n// blacklist management\r\n    function blacklisting(address _addr) onlyOwner public {\r\n        blackList[_addr] = 1;\r\n        emit Blacklisted(_addr);\r\n    }\r\n    function deleteFromBlacklist(address _addr) onlyOwner public {\r\n        blackList[_addr] = -1;\r\n        emit DeleteFromBlacklist(_addr);\r\n    }\r\n\r\n// stop the contract\r\n\tfunction stop() onlyOwner {\r\n        stopped = true;\r\n    }\r\n    function start() onlyOwner {\r\n        stopped = false;\r\n    }\r\n\t\r\n// ERC20 functions\r\n\tfunction balanceOf(address _owner) public constant returns (uint256 balance){\r\n\t\treturn balances[_owner];\r\n\t}\r\n\tfunction transfer(address _to, uint256 _value) notStopped public returns (bool success){\r\n\t\trequire(balances[msg.sender] \u003E= _value);\r\n\r\n\t\tif(blackList[msg.sender] \u003E 0){\r\n\t\t\temit RejectedPaymentFromBlacklistedAddr(msg.sender, _to, _value);\r\n\t\t\treturn false;\r\n\t\t}\r\n\t\tif(blackList[_to] \u003E 0){\r\n\t\t\temit RejectedPaymentToBlacklistedAddr(msg.sender, _to, _value);\r\n\t\t\treturn false;\r\n\t\t}\r\n\r\n\t\tbalances[msg.sender] -= _value;\r\n\t\tbalances[_to] \u002B= _value;\r\n\t\temit Transfer(msg.sender, _to, _value);\r\n\t\treturn true;\r\n\t}\r\n\tfunction transferFrom(address _from, address _to, uint256 _value) notStopped public returns (bool success){\r\n\t\trequire(balances[_from] \u003E= _value\r\n\t\t\t\u0026\u0026 allowed[_from][msg.sender] \u003E= _value);\r\n\r\n\t\tif(blackList[_from] \u003E 0){\r\n\t\t\temit RejectedPaymentFromBlacklistedAddr(_from, _to, _value);\r\n\t\t\treturn false;\r\n\t\t}\r\n\t\tif(blackList[_to] \u003E 0){\r\n\t\t\temit RejectedPaymentToBlacklistedAddr(_from, _to, _value);\r\n\t\t\treturn false;\r\n\t\t}\r\n\r\n\t\tbalances[_from] -= _value;\r\n\t\tallowed[_from][msg.sender] -= _value;\r\n\t\tbalances[_to] \u002B= _value;\r\n\t\temit Transfer(_from, _to, _value);\r\n\t\treturn true;\r\n\t}\r\n\tfunction approve(address _spender, uint256 _value) notStopped public returns (bool success){\r\n\t\tallowed[msg.sender][_spender] = _value;\r\n\t\temit Approval(msg.sender, _spender, _value);\r\n\t\treturn true;\r\n\t}\r\n\tfunction allowance(address _owner, address _spender) public constant returns (uint256 remaining){\r\n\t\treturn allowed[_owner][_spender];\r\n\t}\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022stop\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balances\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022KOKContract\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022blackList\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022int8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022airdrop\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022stopped\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022blacklisting\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022deleteFromBlacklist\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022start\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_new\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Blacklisted\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022DeleteFromBlacklist\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022RejectedPaymentToBlacklistedAddr\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022RejectedPaymentFromBlacklistedAddr\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022oldaddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newaddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022TransferOwnership\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"KOK_Contract","CompilerVersion":"v0.4.21\u002Bcommit.dfe3193c","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://2b57f1e7e2962a905cfdb0917586f42c16da9a2e9ca2d6db5e96d1437ba1d580"}]