[{"SourceCode":"pragma solidity ^0.4.26;\r\n\r\n// ----------------------------------------------------------------------------\r\n// OxUST Smart Contract\r\n//\r\n// Deployed to : 0x4734972cef6824B7C13C174Fd31108BFa47f6dF3\r\n// Symbol      : OxUST\r\n// Total Supply: 1,963,993,042,780.251\r\n// Decimals    : 3\r\n//\r\n// Whitepaper:\r\n// https://0xdealer.com/project/OXUST/whitepaper.pdf\r\n//\r\n// MMMMMMMMMMMMMWNX0kxdoooooooooodxOKXWWMMMMMMMMMMMMM\r\n// MMMMMMMMMMWXOdollloodxxkkkkxxdoolllox0XWMMMMMMMMMM\r\n// MMMMMMMWNOollodkO0OOOOO0O0OOO0000Okdllld0NWMMMMMMM\r\n// MMMMMWXklcoxOOO0OkxkOOOO000O0OxxkOO00OxlclONWMMMMM\r\n// MMMMNOlcokO000Odc:lk0OO0000O0Okl;cxOOO0Oko:l0NMMMM\r\n// MMWXd:lkOO00Od;.\u0027oO0OO00O00000OOl..:xOOO0Okl:xXWMM\r\n// MWKo:dOO00OOl. .dO00O00OOOO00O0OOo. .oOOOOOOo:dXWM\r\n// WKl:xO00OO0x\u0027  .dOOkoc:::;::cokOOo.  ,k0OOO0Od:dXW\r\n// Xd:dOOO0OO0k,   .\u0027,,;cloodol:,,,..   :k0OOOO0Oo:xN\r\n// O:cO0OO00O00x:.   ,dO00OO00OOOo\u0027   .:kO00OO000kccK\r\n// d:d00OOkoc::::,. \u0027x0OO0OOOOOO00d. .;:::clokOOOOo:k\r\n// l:x00Ox,         \u0027xOO0OOO00OO0Od.         ;k0O0d:d\r\n// l:k0OOkc\u0027.\u0027\u0027,,:\u0027.\u0027lodOOO00OOOdlc..,:,,\u0027.\u0027,lO000x:o\r\n// o:x000OOOOOOOO0x,\u0027;..cO0OO0k:..;\u0027;k0OOOOOOOO000d:d\r\n// k:oO0OOOOO0OOOOOc.   .d0O00o.   .lOOOOO000OOOOOl:O\r\n// Kl:k0OO0OOO0OOO0d.   .lOO0Oc    \u0027x0OOOOO00OOO0x:oX\r\n// WO:lO0O0OOOOOOO0k,   .lOO0Oc    ;O0OOOO0OOO00kcc0W\r\n// MNx:lOOOOOOOOOO0O:  .cdddddo:.  cOOO0OO0OOO0kc:kNM\r\n// MMNk:ckOOOOOOOOOOc.\u0027lo:.  .coc..lOO00OOOOOOxccONMM\r\n// MMMN0l:oO0OOOOOOOd,\u0027cl:....cl:\u0027,x0O0OO000ko:oKWMMM\r\n// MMMMWXkccokOOOOO0Oxl:c:;;;;:c:lkOOO0OOOkoclkNWMMMM\r\n// MMMMMMWXklcldkO000OOOkkxxxxkOO0O0OOOkdlcoOXWMMMMMM\r\n// MMMMMMMMWN0xlllodkOOOO00OOO000OOxdolllxKNWMMMMMMMM\r\n// MMMMMMMMMMMWNKOdolllllllooolllllloxOXNWMMMMMMMMMMM\r\n// MMMMMMMMMMMMMMMWNX0OxdollllodxOKXNWMMMMMMMMMMMMMMM\r\n// \r\n// ----------------------------------------------------------------------------\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n// Safe maths\r\n// ----------------------------------------------------------------------------\r\ncontract SafeMath {\r\n    function safeAdd(uint a, uint b) public pure returns (uint c) {\r\n        c = a \u002B b;\r\n        require(c \u003E= a);\r\n    }\r\n    function safeSub(uint a, uint b) public pure returns (uint c) {\r\n        require(b \u003C= a);\r\n        c = a - b;\r\n    }\r\n    function safeMul(uint a, uint b) public pure returns (uint c) {\r\n        c = a * b;\r\n        require(a == 0 || c / a == b);\r\n    }\r\n    function safeDiv(uint a, uint b) public pure returns (uint c) {\r\n        require(b \u003E 0);\r\n        c = a / b;\r\n    }\r\n}\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n// ERC Token Standard #20 Interface\r\n// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md\r\n// ----------------------------------------------------------------------------\r\ncontract ERC20Interface {\r\n    function totalSupply() public constant returns (uint);\r\n    function balanceOf(address tokenOwner) public constant returns (uint balance);\r\n    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);\r\n    function transfer(address to, uint tokens) public returns (bool success);\r\n    function approve(address spender, uint tokens) public returns (bool success);\r\n    function transferFrom(address from, address to, uint tokens) public returns (bool success);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint tokens);\r\n    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);\r\n}\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n// Contract function to receive approval and execute function in one call\r\n// ----------------------------------------------------------------------------\r\ncontract ApproveAndCallFallBack {\r\n    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;\r\n}\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n// Owned contract\r\n// ----------------------------------------------------------------------------\r\ncontract Owned {\r\n    address public owner;\r\n    address public newOwner;\r\n\r\n    event OwnershipTransferred(address indexed _from, address indexed _to);\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    function transferOwnership(address _newOwner) public onlyOwner {\r\n        newOwner = _newOwner;\r\n    }\r\n    function acceptOwnership() public {\r\n        require(msg.sender == newOwner);\r\n        emit OwnershipTransferred(owner, newOwner);\r\n        owner = newOwner;\r\n        newOwner = address(0);\r\n    }\r\n}\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n// ERC20 Token, with the addition of symbol, name and decimals and assisted\r\n// token transfers\r\n// ----------------------------------------------------------------------------\r\ncontract OxUST is ERC20Interface, Owned, SafeMath {\r\n    string public symbol;\r\n    string public  name;\r\n    uint8 public decimals;\r\n    uint public _totalSupply;\r\n\r\n    mapping(address =\u003E uint) balances;\r\n    mapping(address =\u003E mapping(address =\u003E uint)) allowed;\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n    // Constructor\r\n    // ------------------------------------------------------------------------\r\n    constructor() public {\r\n        symbol = \u0022OxUST\u0022;\r\n        name = \u0022OxUST\u0022;\r\n        decimals = 3;\r\n        _totalSupply = 1963993042780251;\r\n        balances[0x4734972cef6824B7C13C174Fd31108BFa47f6dF3] = _totalSupply;\r\n        emit Transfer(0x4734972cef6824B7C13C174Fd31108BFa47f6dF3, 0x4734972cef6824B7C13C174Fd31108BFa47f6dF3, _totalSupply);\r\n    }\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n    // Total supply\r\n    // ------------------------------------------------------------------------\r\n    function totalSupply() public constant returns (uint) {\r\n        return _totalSupply  - balances[address(0)];\r\n    }\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n    // Get the token balance for account tokenOwner\r\n    // ------------------------------------------------------------------------\r\n    function balanceOf(address tokenOwner) public constant returns (uint balance) {\r\n        return balances[tokenOwner];\r\n    }\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n    // Transfer the balance from token owner\u0027s account to to account\r\n    // - Owner\u0027s account must have sufficient balance to transfer\r\n    // - 0 value transfers are allowed\r\n    // ------------------------------------------------------------------------\r\n    function transfer(address to, uint tokens) public returns (bool success) {\r\n        balances[msg.sender] = safeSub(balances[msg.sender], tokens);\r\n        balances[to] = safeAdd(balances[to], tokens);\r\n        emit Transfer(msg.sender, to, tokens);\r\n        return true;\r\n    }\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n    // Token owner can approve for spender to transferFrom(...) tokens\r\n    // from the token owner\u0027s account\r\n    //\r\n    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md\r\n    // recommends that there are no checks for the approval double-spend attack\r\n    // as this should be implemented in user interfaces \r\n    // ------------------------------------------------------------------------\r\n    function approve(address spender, uint tokens) public returns (bool success) {\r\n        allowed[msg.sender][spender] = tokens;\r\n        emit Approval(msg.sender, spender, tokens);\r\n        return true;\r\n    }\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n    // Transfer tokens from the from account to the to account\r\n    // \r\n    // The calling account must already have sufficient tokens approve(...)-d\r\n    // for spending from the from account and\r\n    // - From account must have sufficient balance to transfer\r\n    // - Spender must have sufficient allowance to transfer\r\n    // - 0 value transfers are allowed\r\n    // ------------------------------------------------------------------------\r\n    function transferFrom(address from, address to, uint tokens) public returns (bool success) {\r\n        balances[from] = safeSub(balances[from], tokens);\r\n        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);\r\n        balances[to] = safeAdd(balances[to], tokens);\r\n        emit Transfer(from, to, tokens);\r\n        return true;\r\n    }\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n    // Returns the amount of tokens approved by the owner that can be\r\n    // transferred to the spender\u0027s account\r\n    // ------------------------------------------------------------------------\r\n    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {\r\n        return allowed[tokenOwner][spender];\r\n    }\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n    // Token owner can approve for spender to transferFrom(...) tokens\r\n    // from the token owner\u0027s account. The spender contract function\r\n    // receiveApproval(...) is then executed\r\n    // ------------------------------------------------------------------------\r\n    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {\r\n        allowed[msg.sender][spender] = tokens;\r\n        emit Approval(msg.sender, spender, tokens);\r\n        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);\r\n        return true;\r\n    }\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n    // Don\u0027t accept ETH\r\n    // ------------------------------------------------------------------------\r\n    function () public payable {\r\n        revert();\r\n    }\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n    // Owner can transfer out any accidentally sent ERC20 tokens\r\n    // ------------------------------------------------------------------------\r\n    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {\r\n        return ERC20Interface(tokenAddress).transfer(owner, tokens);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022safeSub\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022c\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022safeDiv\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022c\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022approveAndCall\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022safeMul\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022c\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022newOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferAnyERC20Token\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022safeAdd\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022c\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"OxUST","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://8c2829a80329e74b34941c38b034fe9549e282c2c8565ae647120b870e43ed25"}]