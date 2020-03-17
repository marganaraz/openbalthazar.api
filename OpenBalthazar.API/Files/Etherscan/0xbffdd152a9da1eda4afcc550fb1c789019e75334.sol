[{"SourceCode":"pragma solidity ^0.4.16;\r\n\r\n\r\ncontract Ownable {\r\n    \r\n    address public owner;\r\n\r\n    function Ownable() public {\r\n        owner = msg.sender;\r\n    }\r\n    \r\n\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract AceWins is Ownable {\r\n    \r\n    uint256 public totalSupply;\r\n    mapping(address =\u003E uint256) startBalances;\r\n    mapping(address =\u003E mapping(address =\u003E uint256)) allowed;\r\n    mapping(address =\u003E uint256) startBlocks;\r\n    \r\n    string public constant name = \u0022Ace Wins\u0022;\r\n    string public constant symbol = \u0022ACE\u0022;\r\n    uint32 public constant decimals = 10;\r\n    uint256 public calc = 951839;\r\n\r\n    function AceWins() public {\r\n        totalSupply = 9000000 * 10**uint256(decimals);\r\n        startBalances[owner] = totalSupply;\r\n        startBlocks[owner] = block.number;\r\n        Transfer(address(0), owner, totalSupply);\r\n    }\r\n\r\n\r\n    function fracExp(uint256 k, uint256 q, uint256 n, uint256 p) pure public returns (uint256) {\r\n        uint256 s = 0;\r\n        uint256 N = 1;\r\n        uint256 B = 1;\r\n        for (uint256 i = 0; i \u003C p; \u002B\u002Bi) {\r\n            s \u002B= k * N / B / (q**i);\r\n            N = N * (n-i);\r\n            B = B * (i\u002B1);\r\n        }\r\n        return s;\r\n    }\r\n\r\n\r\n    function compoundInterest(address tokenOwner) view public returns (uint256) {\r\n        require(startBlocks[tokenOwner] \u003E 0);\r\n        uint256 start = startBlocks[tokenOwner];\r\n        uint256 current = block.number;\r\n        uint256 blockCount = current - start;\r\n        uint256 balance = startBalances[tokenOwner];\r\n        return fracExp(balance, calc, blockCount, 8) - balance;\r\n    }\r\n\r\n\r\n    function balanceOf(address tokenOwner) public constant returns (uint256 balance) {\r\n        return startBalances[tokenOwner] \u002B compoundInterest(tokenOwner);\r\n    }\r\n\r\n    \r\n\r\n    function updateBalance(address tokenOwner) private {\r\n        if (startBlocks[tokenOwner] == 0) {\r\n            startBlocks[tokenOwner] = block.number;\r\n        }\r\n        uint256 ci = compoundInterest(tokenOwner);\r\n        startBalances[tokenOwner] = startBalances[tokenOwner] \u002B ci;\r\n        totalSupply = totalSupply \u002B ci;\r\n        startBlocks[tokenOwner] = block.number;\r\n    }\r\n    \r\n\r\n \r\n    function transfer(address to, uint256 tokens) public returns (bool) {\r\n        updateBalance(msg.sender);\r\n        updateBalance(to);\r\n        require(tokens \u003C= startBalances[msg.sender]);\r\n\r\n        startBalances[msg.sender] = startBalances[msg.sender] - tokens;\r\n        startBalances[to] = startBalances[to] \u002B tokens;\r\n        Transfer(msg.sender, to, tokens);\r\n        return true;\r\n    }\r\n\r\n\r\n    function transferFrom(address from, address to, uint256 tokens) public returns (bool) {\r\n        updateBalance(from);\r\n        updateBalance(to);\r\n        require(tokens \u003C= startBalances[from]);\r\n\r\n        startBalances[from] = startBalances[from] - tokens;\r\n        allowed[from][msg.sender] = allowed[from][msg.sender] - tokens;\r\n        startBalances[to] = startBalances[to] \u002B tokens;\r\n        Transfer(from, to, tokens);\r\n        return true;\r\n    }\r\n\r\n   \r\n     function setCalc(uint256 _Calc) public {\r\n      require(msg.sender==owner);\r\n      calc = _Calc;\r\n    } \r\n     \r\n    function approve(address spender, uint256 tokens) public returns (bool) {\r\n        allowed[msg.sender][spender] = tokens;\r\n        Approval(msg.sender, spender, tokens);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining) {\r\n        return allowed[tokenOwner][spender];\r\n    }\r\n   \r\n    event Transfer(address indexed from, address indexed to, uint256 tokens);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 tokens);\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_Calc\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setCalc\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022calc\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022compoundInterest\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022k\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022q\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022n\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022p\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022fracExp\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"AceWins","CompilerVersion":"v0.4.16\u002Bcommit.d7661dd9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://43f066ef777bba2fff9ce1e2e5b935f3982f18fa1564bbb3a2e1d930c4218c8d"}]