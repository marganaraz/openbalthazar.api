[{"SourceCode":"pragma solidity ^0.4.26;\r\n\r\n// ----------------------------------------------------------------------------\r\n// \u0027SAMPLE\u0027 token contract\r\n//\r\n// Symbol\t  : SAMPLE\r\n// Name\t\t: model_ohyoungjoo\r\n// Total supply: 100,000,000.000000000000000000\r\n// Decimals\t: 18\r\n//\r\n// Enjoy.\r\n//\r\n// (c) STAR BIT. 2019. The MIT Licence.\r\n// ----------------------------------------------------------------------------\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n// Safe maths\r\n// ----------------------------------------------------------------------------\r\nlibrary SafeMath {\r\n\tfunction add(uint a, uint b) internal pure returns (uint c) {\r\n\t\tc = a \u002B b;\r\n\t\trequire(c \u003E= a);\r\n\t}\r\n\tfunction sub(uint a, uint b) internal pure returns (uint c) {\r\n\t\trequire(b \u003C= a);\r\n\t\tc = a - b;\r\n\t}\r\n\tfunction mul(uint a, uint b) internal pure returns (uint c) {\r\n\t\tc = a * b;\r\n\t\trequire(a == 0 || c / a == b);\r\n\t}\r\n\tfunction div(uint a, uint b) internal pure returns (uint c) {\r\n\t\trequire(b \u003E 0);\r\n\t\tc = a / b;\r\n\t}\r\n}\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n// ERC Token Standard #20 Interface\r\n// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md\r\n// ----------------------------------------------------------------------------\r\ncontract ERC20Interface {\r\n\tfunction totalSupply() public view returns (uint);\r\n\tfunction balanceOf(address tokenOwner) public view returns (uint balance);\r\n\tfunction allowance(address tokenOwner, address spender) public view returns (uint remaining);\r\n\tfunction transfer(address to, uint tokens) public returns (bool success);\r\n\tfunction approve(address spender, uint tokens) public returns (bool success);\r\n\tfunction transferFrom(address from, address to, uint tokens) public returns (bool success);\r\n\r\n\tevent Transfer(address indexed from, address indexed to, uint tokens);\r\n\tevent Approval(address indexed tokenOwner, address indexed spender, uint tokens);\r\n}\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n// Contract function to receive approval and execute function in one call\r\n//\r\n// Borrowed from Foresting (FORE)\r\n// ----------------------------------------------------------------------------\r\ncontract ApproveAndCallFallBack {\r\n\tfunction receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;\r\n}\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n// Owned contract\r\n// ----------------------------------------------------------------------------\r\ncontract Owned {\r\n\taddress public owner;\r\n\r\n\tconstructor(address admin) public {\r\n\t\towner = admin;\r\n\t}\r\n\r\n\tmodifier onlyOwner {\r\n\t\trequire(msg.sender == owner);\r\n\t\t_;\r\n\t}\r\n\t\r\n\tfunction isOwner() public view returns (bool is_owner) {\r\n\t    return msg.sender == owner;\r\n\t}\r\n}\r\n\r\n\r\n// ----------------------------------------------------------------------------\r\n// ERC20 Token, with the addition of symbol, name and decimals and a\r\n// fixed supply\r\n// ----------------------------------------------------------------------------\r\ncontract SAMPLE is ERC20Interface, Owned {\r\n\tusing SafeMath for uint;\r\n\r\n\tstring public symbol;\r\n\tstring public name;\r\n\tuint8 public decimals;\r\n\tuint _totalSupply;\r\n\tbool _stopTrade;\r\n\r\n\tmapping(address =\u003E uint) balances;\r\n\tmapping(address =\u003E mapping(address =\u003E uint)) allowed;\r\n\r\n\tevent Burn(address indexed burner, uint256 value);\r\n\r\n\t// ------------------------------------------------------------------------\r\n\t// Constructor\r\n\t// ------------------------------------------------------------------------\r\n\tconstructor(address admin) Owned(admin) public {\r\n\t\tsymbol = \u0022CHUN\u0022;\r\n\t\tname = \u0022model_chunst\u0022;\r\n\t\tdecimals = 18;\r\n\t\t_totalSupply = 100000000 * 10**uint(decimals);\r\n\t\t_stopTrade = false;\r\n\t\tbalances[owner] = _totalSupply;\r\n\t\temit Transfer(address(0), owner, _totalSupply);\r\n\t}\r\n\r\n\r\n\t// ------------------------------------------------------------------------\r\n\t// Total supply\r\n\t// ------------------------------------------------------------------------\r\n\tfunction totalSupply() public view returns (uint) {\r\n\t\treturn _totalSupply.sub(balances[address(0)]);\r\n\t}\r\n\r\n\r\n\t// ------------------------------------------------------------------------\r\n\t// Stop Trade\r\n\t// ------------------------------------------------------------------------\r\n\tfunction stopTrade() public onlyOwner {\r\n\t\trequire(_stopTrade != true);\r\n\t\t_stopTrade = true;\r\n\t}\r\n\r\n\r\n\t// ------------------------------------------------------------------------\r\n\t// Start Trade\r\n\t// ------------------------------------------------------------------------\r\n\tfunction startTrade() public onlyOwner {\r\n\t\trequire(_stopTrade == true);\r\n\t\t_stopTrade = false;\r\n\t}\r\n\r\n\r\n\t// ------------------------------------------------------------------------\r\n\t// Get the token balance for account \u0060tokenOwner\u0060\r\n\t// ------------------------------------------------------------------------\r\n\tfunction balanceOf(address tokenOwner) public view returns (uint balance) {\r\n\t\treturn balances[tokenOwner];\r\n\t}\r\n\r\n\r\n\t// ------------------------------------------------------------------------\r\n\t// Transfer the balance from token owner\u0027s account to \u0060to\u0060 account\r\n\t// - Owner\u0027s account must have sufficient balance to transfer\r\n\t// - 0 value transfers are allowed\r\n\t// ------------------------------------------------------------------------\r\n\tfunction transfer(address to, uint tokens) public returns (bool success) {\r\n\t\trequire(_stopTrade != true || isOwner());\r\n\t\trequire(to \u003E address(0));\r\n\r\n\t\tbalances[msg.sender] = balances[msg.sender].sub(tokens);\r\n\t\tbalances[to] = balances[to].add(tokens);\r\n\t\temit Transfer(msg.sender, to, tokens);\r\n\t\treturn true;\r\n\t}\r\n\r\n\r\n\t// ------------------------------------------------------------------------\r\n\t// Token owner can approve for \u0060spender\u0060 to transferFrom(...) \u0060tokens\u0060\r\n\t// from the token owner\u0027s account\r\n\t//\r\n\t// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md\r\n\t// recommends that there are no checks for the approval double-spend attack\r\n\t// as this should be implemented in user interfaces\r\n\t// ------------------------------------------------------------------------\r\n\tfunction approve(address spender, uint tokens) public returns (bool success) {\r\n\t\trequire(_stopTrade != true);\r\n\t\trequire(msg.sender != spender);\r\n\r\n\t\tallowed[msg.sender][spender] = tokens;\r\n\t\temit Approval(msg.sender, spender, tokens);\r\n\t\treturn true;\r\n\t}\r\n\r\n\r\n\t// ------------------------------------------------------------------------\r\n\t// Transfer \u0060tokens\u0060 from the \u0060from\u0060 account to the \u0060to\u0060 account\r\n\t//\r\n\t// The calling account must already have sufficient tokens approve(...)-d\r\n\t// for spending from the \u0060from\u0060 account and\r\n\t// - From account must have sufficient balance to transfer\r\n\t// - Spender must have sufficient allowance to transfer\r\n\t// - 0 value transfers are allowed\r\n\t// ------------------------------------------------------------------------\r\n\tfunction transferFrom(address from, address to, uint tokens) public returns (bool success) {\r\n\t\trequire(_stopTrade != true);\r\n\t\trequire(from \u003E address(0));\r\n\t\trequire(to \u003E address(0));\r\n\r\n\t\tbalances[from] = balances[from].sub(tokens);\r\n\t\tif(from != to \u0026\u0026 from != msg.sender) {\r\n\t\t\tallowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);\r\n\t\t}\r\n\t\tbalances[to] = balances[to].add(tokens);\r\n\t\temit Transfer(from, to, tokens);\r\n\t\treturn true;\r\n\t}\r\n\r\n\r\n\t// ------------------------------------------------------------------------\r\n\t// Returns the amount of tokens approved by the owner that can be\r\n\t// transferred to the spender\u0027s account\r\n\t// ------------------------------------------------------------------------\r\n\tfunction allowance(address tokenOwner, address spender) public view returns (uint remaining) {\r\n\t\trequire(_stopTrade != true);\r\n\r\n\t\treturn allowed[tokenOwner][spender];\r\n\t}\r\n\r\n\r\n\t// ------------------------------------------------------------------------\r\n\t// Token owner can approve for \u0060spender\u0060 to transferFrom(...) \u0060tokens\u0060\r\n\t// from the token owner\u0027s account. The \u0060spender\u0060 contract function\r\n\t// \u0060receiveApproval(...)\u0060 is then executed\r\n\t// ------------------------------------------------------------------------\r\n\tfunction approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {\r\n\t\trequire(_stopTrade != true);\r\n\t\trequire(msg.sender != spender);\r\n\r\n\t\tallowed[msg.sender][spender] = tokens;\r\n\t\temit Approval(msg.sender, spender, tokens);\r\n\t\tApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);\r\n\t\treturn true;\r\n\t}\r\n\r\n\r\n\t// ------------------------------------------------------------------------\r\n\t// Don\u0027t accept ETH\r\n\t// ------------------------------------------------------------------------\r\n\tfunction () external payable {\r\n\t\trevert();\r\n\t}\r\n\r\n\r\n\t// ------------------------------------------------------------------------\r\n\t// Owner can transfer out any accidentally sent ERC20 tokens\r\n\t// ------------------------------------------------------------------------\r\n\tfunction transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {\r\n\t\treturn ERC20Interface(tokenAddress).transfer(owner, tokens);\r\n\t}\r\n\r\n\r\n\t// ------------------------------------------------------------------------\r\n\t// Burns a specific amount of tokens.\r\n\t// ------------------------------------------------------------------------\r\n\tfunction burn(uint256 tokens) public {\r\n\t\trequire(tokens \u003C= balances[msg.sender]);\r\n\t\trequire(tokens \u003C= _totalSupply);\r\n\r\n\t\tbalances[msg.sender] = balances[msg.sender].sub(tokens);\r\n\t\t_totalSupply = _totalSupply.sub(tokens);\r\n\t\temit Burn(msg.sender, tokens);\r\n\t}\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022startTrade\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022stopTrade\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022is_owner\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022approveAndCall\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferAnyERC20Token\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022admin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022burner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"SAMPLE","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000004b0be66603999d88b3f22612c989cff85a393a1c","Library":"","SwarmSource":"bzzr://9a2c2668fcd273c50678f3cb6916c4969dad06a6d79bc48e680d7392e4efbaa8"}]