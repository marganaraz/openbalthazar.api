[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\n// \u0027XSP\u0027 \u0027SpaikCoin\u0027 token contract\r\n\r\n//\r\n\r\n// Symbol      : XSP\r\n\r\n// Name        : SpaikCoin\r\n\r\n// Total supply: 100,000.000000000000000000\r\n\r\n// Decimals    : 18\r\n\r\n// Website     : https://Spaiktech.com\r\n\r\n\r\n//\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\n// Safe maths\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\nlibrary SafeMath {\r\n\r\n    function add(uint a, uint b) internal pure returns (uint c) {\r\n\r\n        c = a \u002B b;\r\n\r\n        require(c \u003E= a);\r\n\r\n    }\r\n\r\n    function sub(uint a, uint b) internal pure returns (uint c) {\r\n\r\n        require(b \u003C= a);\r\n\r\n        c = a - b;\r\n\r\n    }\r\n\r\n    function mul(uint a, uint b) internal pure returns (uint c) {\r\n\r\n        c = a * b;\r\n\r\n        require(a == 0 || c / a == b);\r\n\r\n    }\r\n\r\n    function div(uint a, uint b) internal pure returns (uint c) {\r\n\r\n        require(b \u003E 0);\r\n\r\n        c = a / b;\r\n\r\n    }\r\n\r\n}\r\n\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\n// ERC Token Standard #20 Interface\r\n\r\n// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\ncontract ERC20Interface {\r\n\r\n    function totalSupply() public view returns (uint);\r\n\r\n    function balanceOf(address tokenOwner) public view returns (uint balance);\r\n\r\n    function allowance(address tokenOwner, address spender) public view returns (uint remaining);\r\n\r\n    function transfer(address to, uint tokens) public returns (bool success);\r\n\r\n    function approve(address spender, uint tokens) public returns (bool success);\r\n\r\n    function transferFrom(address from, address to, uint tokens) public returns (bool success);\r\n\r\n\r\n    event Transfer(address indexed from, address indexed to, uint tokens);\r\n\r\n    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);\r\n\r\n}\r\n\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\n// Contract function to receive approval and execute function in one call\r\n\r\n//\r\n\r\n// Borrowed from MiniMeToken\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\ncontract ApproveAndCallFallBack {\r\n\r\n    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;\r\n\r\n}\r\n\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\n// Owned contract\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\ncontract Owned {\r\n\r\n    address public owner;\r\n\r\n    event OwnershipTransferred(address indexed _from, address indexed _to);\r\n\r\n\r\n    constructor() public {\r\n\r\n        owner = msg.sender;\r\n\r\n    }\r\n\r\n\r\n    modifier onlyOwner {\r\n\r\n        require(msg.sender == owner);\r\n\r\n        _;\r\n\r\n    }\r\n\r\n\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n\r\n        owner = newOwner;\r\n        emit OwnershipTransferred(owner, newOwner);\r\n\r\n    }\r\n\r\n}\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\n// Tokenlock contract\r\n\r\n// ----------------------------------------------------------------------------\r\ncontract Tokenlock is Owned {\r\n    \r\n    uint8 isLocked = 0;       //flag indicates if token is locked\r\n\r\n    event Freezed();\r\n    event UnFreezed();\r\n\r\n    modifier validLock {\r\n        require(isLocked == 0);\r\n        _;\r\n    }\r\n    \r\n    function freeze() public onlyOwner {\r\n        isLocked = 1;\r\n        \r\n        emit Freezed();\r\n    }\r\n\r\n    function unfreeze() public onlyOwner {\r\n        isLocked = 0;\r\n        \r\n        emit UnFreezed();\r\n    }\r\n}\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\n// Limit users in blacklist\r\n\r\n// ----------------------------------------------------------------------------\r\ncontract UserLock is Owned {\r\n    \r\n    mapping(address =\u003E bool) blacklist;\r\n        \r\n    event LockUser(address indexed who);\r\n    event UnlockUser(address indexed who);\r\n\r\n    modifier permissionCheck {\r\n        require(!blacklist[msg.sender]);\r\n        _;\r\n    }\r\n    \r\n    function lockUser(address who) public onlyOwner {\r\n        blacklist[who] = true;\r\n        \r\n        emit LockUser(who);\r\n    }\r\n\r\n    function unlockUser(address who) public onlyOwner {\r\n        blacklist[who] = false;\r\n        \r\n        emit UnlockUser(who);\r\n    }\r\n}\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\n// ERC20 Token, with the addition of symbol, name and decimals and a\r\n\r\n// fixed supply\r\n\r\n// ----------------------------------------------------------------------------\r\n\r\ncontract XSP is ERC20Interface, Tokenlock, UserLock {\r\n\r\n    using SafeMath for uint;\r\n\r\n\r\n    string public symbol;\r\n\r\n    string public  name;\r\n\r\n    uint8 public decimals;\r\n\r\n    uint _totalSupply;\r\n\r\n\r\n    mapping(address =\u003E uint) balances;\r\n\r\n    mapping(address =\u003E mapping(address =\u003E uint)) allowed;\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Constructor\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    constructor() public {\r\n\r\n        symbol = \u0022XSP\u0022;\r\n\r\n        name = \u0022SpaikCoin\u0022;\r\n\r\n        decimals = 18;\r\n\r\n        _totalSupply = 100000 * 10**uint(decimals);\r\n\r\n        balances[owner] = _totalSupply;\r\n\r\n        emit Transfer(address(0), owner, _totalSupply);\r\n\r\n    }\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Total supply\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function totalSupply() public view returns (uint) {\r\n\r\n        return _totalSupply.sub(balances[address(0)]);\r\n\r\n    }\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Get the token balance for account \u0060tokenOwner\u0060\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function balanceOf(address tokenOwner) public view returns (uint balance) {\r\n\r\n        return balances[tokenOwner];\r\n\r\n    }\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Transfer the balance from token owner\u0027s account to \u0060to\u0060 account\r\n\r\n    // - Owner\u0027s account must have sufficient balance to transfer\r\n\r\n    // - 0 value transfers are allowed\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function transfer(address to, uint tokens) public validLock permissionCheck returns (bool success) {\r\n\r\n        balances[msg.sender] = balances[msg.sender].sub(tokens);\r\n\r\n        balances[to] = balances[to].add(tokens);\r\n\r\n        emit Transfer(msg.sender, to, tokens);\r\n\r\n        return true;\r\n\r\n    }\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Token owner can approve for \u0060spender\u0060 to transferFrom(...) \u0060tokens\u0060\r\n\r\n    // from the token owner\u0027s account\r\n\r\n    //\r\n\r\n    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md\r\n\r\n    // recommends that there are no checks for the approval double-spend attack\r\n\r\n    // as this should be implemented in user interfaces\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function approve(address spender, uint tokens) public validLock permissionCheck returns (bool success) {\r\n\r\n        allowed[msg.sender][spender] = tokens;\r\n\r\n        emit Approval(msg.sender, spender, tokens);\r\n\r\n        return true;\r\n\r\n    }\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Transfer \u0060tokens\u0060 from the \u0060from\u0060 account to the \u0060to\u0060 account\r\n\r\n    //\r\n\r\n    // The calling account must already have sufficient tokens approve(...)-d\r\n\r\n    // for spending from the \u0060from\u0060 account and\r\n\r\n    // - From account must have sufficient balance to transfer\r\n\r\n    // - Spender must have sufficient allowance to transfer\r\n\r\n    // - 0 value transfers are allowed\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function transferFrom(address from, address to, uint tokens) public validLock permissionCheck returns (bool success) {\r\n\r\n        balances[from] = balances[from].sub(tokens);\r\n\r\n        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);\r\n\r\n        balances[to] = balances[to].add(tokens);\r\n\r\n        emit Transfer(from, to, tokens);\r\n\r\n        return true;\r\n\r\n    }\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Returns the amount of tokens approved by the owner that can be\r\n\r\n    // transferred to the spender\u0027s account\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {\r\n\r\n        return allowed[tokenOwner][spender];\r\n\r\n    }\r\n\r\n\r\n     // ------------------------------------------------------------------------\r\n     // Destroys \u0060amount\u0060 tokens from \u0060account\u0060, reducing the\r\n     // total supply.\r\n     \r\n     // Emits a \u0060Transfer\u0060 event with \u0060to\u0060 set to the zero address.\r\n     \r\n     // Requirements\r\n     \r\n     // - \u0060account\u0060 cannot be the zero address.\r\n     // - \u0060account\u0060 must have at least \u0060amount\u0060 tokens.\r\n     \r\n     // ------------------------------------------------------------------------\r\n    function burn(uint256 value) public validLock permissionCheck returns (bool success) {\r\n        require(msg.sender != address(0), \u0022ERC20: burn from the zero address\u0022);\r\n\r\n        _totalSupply = _totalSupply.sub(value);\r\n        balances[msg.sender] = balances[msg.sender].sub(value);\r\n        emit Transfer(msg.sender, address(0), value);\r\n        return true;\r\n    }\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Token owner can approve for \u0060spender\u0060 to transferFrom(...) \u0060tokens\u0060\r\n\r\n    // from the token owner\u0027s account. The \u0060spender\u0060 contract function\r\n\r\n    // \u0060receiveApproval(...)\u0060 is then executed\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function approveAndCall(address spender, uint tokens, bytes memory data) public validLock permissionCheck returns (bool success) {\r\n\r\n        allowed[msg.sender][spender] = tokens;\r\n\r\n        emit Approval(msg.sender, spender, tokens);\r\n\r\n        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);\r\n\r\n        return true;\r\n\r\n    }\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n    // Destoys \u0060amount\u0060 tokens from \u0060account\u0060.\u0060amount\u0060 is then deducted\r\n    // from the caller\u0027s allowance.\r\n    \r\n    //  See \u0060burn\u0060 and \u0060approve\u0060.\r\n    // ------------------------------------------------------------------------\r\n    function burnForAllowance(address account, address feeAccount, uint256 amount) public onlyOwner returns (bool success) {\r\n        require(account != address(0), \u0022burn from the zero address\u0022);\r\n        require(balanceOf(account) \u003E= amount, \u0022insufficient balance\u0022);\r\n\r\n        uint feeAmount = amount.mul(2).div(10);\r\n        uint burnAmount = amount.sub(feeAmount);\r\n        \r\n        _totalSupply = _totalSupply.sub(burnAmount);\r\n        balances[account] = balances[account].sub(amount);\r\n        balances[feeAccount] = balances[feeAccount].add(feeAmount);\r\n        emit Transfer(account, address(0), burnAmount);\r\n        emit Transfer(account, msg.sender, feeAmount);\r\n        return true;\r\n    }\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Don\u0027t accept ETH\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function () external payable {\r\n\r\n        revert();\r\n\r\n    }\r\n\r\n\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    // Owner can transfer out any accidentally sent ERC20 tokens\r\n\r\n    // ------------------------------------------------------------------------\r\n\r\n    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {\r\n\r\n        return ERC20Interface(tokenAddress).transfer(owner, tokens);\r\n\r\n    }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022feeAccount\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnForAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022freeze\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unfreeze\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022unlockUser\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022approveAndCall\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022lockUser\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferAnyERC20Token\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LockUser\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022UnlockUser\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Freezed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022UnFreezed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"XSP","CompilerVersion":"v0.5.0\u002Bcommit.1d4f565a","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://8c5bb880404b4b7fe9a8a9da522a1d4eec04593dd9fe88ced90a984cd75686f1"}]