[{"SourceCode":"pragma solidity \u003E= 0.5 .0 \u003C 0.7 .0;\r\n\r\n/*\r\n\u002B-----------------------------------\u002B\r\n|HZHZHZHZHZHZHZHZ/ /HZHZHZHZHZHZHZHZ|\r\n|HZHZHZHZHZHZHZH\u0060   \u0060HZHZHZHZHZHZHZH|\r\n|HZHZHZHZHZHZH-       -HZHZHZHZHZHZH|\r\n|HZHZHZHZHZH/           /HZHZHZHZHZH|\r\n|HZHZHZHZHZHZHZHZH\u002B:     \u0060HZHZHZHZHZ|\r\n|HZHZHZHZHZHZHZHZHZHZ-     -HZHZHZHZ|\r\n|HZHZHZHZHZHZHZHZHZHZHZ\u0060     /HZHZHZ|\r\n|HZHZHZHZHZHZHZHZHZHZHZH/\u0060    .HZHZH|\r\n|HZH-------/HZHZHZHZHZHZH\u002B      -HZH|\r\n|H/\u0060         /HZHZHZ-            \u0060/H|\r\n||            \u0060HZHZHZH\u0060            ||\r\n|H/\u0060            -HZHZHZ:         \u0060/H|\r\n|HZH-      \u002BHZHZHZHZHZHZH/-------HZH|\r\n|HZHZH.     /HZHZHZHZHZHZHZHZHZHZHZH|\r\n|HZHZHZ/     \u0060HZHZHZHZHZHZHZHZHZHZHZ|\r\n|HZHZHZHZ-     -HZHZHZHZHZHZHZHZHZHZ|\r\n|HZHZHZHZHZ\u0060     :\u002BHZHZHZHZHZHZHZHZH|\r\n|HZHZHZHZHZH/           /HZHZHZHZHZH|\r\n|HZHZHZHZHZHZH-       -HZHZHZHZHZHZH|\r\n|HZHZHZHZHZHZHZH\u0060   \u0060HZHZHZHZHZHZHZH|\r\n|HZHZHZHZHZHZHZHZ/ /HZHZHZHZHZHZHZHZ|\r\n\u002B-----------------------------------\u002B\r\n\r\n _    ____________________________\r\n| |  |   ____   __  __   ______  /\r\n| |__|  |__  | |__) | | |     / / \r\n|  __    __| |  _  /  | |    / /  \r\n| |  |  |____| | \\ \\  | |   / /__ \r\n|_|  |_________|  \\_\\ |_|  /_____| V1.0\r\n     \r\nA deflationary stable-coin, with a constantly increasing price.\r\n\r\n Symbol        :  HZ\r\n Name          :  Hertz Token \r\n Total supply  :  21,000.0 (or 21 thousand tokens)\r\n Decimals      :  18\r\n Transfer Fees :  2% deducted from each transfer (a burning fee).\r\n Exchange Fees :  no fees deducted while purchasing, \r\n                  2% fee while converting back to Ethereum\r\n \r\n*/\r\n\r\n// ----------------------------------------------------------------------------\r\n// Safe maths\r\n// ----------------------------------------------------------------------------\r\n\r\nlibrary SafeMath {\r\n\r\n    function add(uint a, uint b) internal pure returns(uint c) {\r\n        c = a \u002B b;\r\n        require(c \u003E= a);\r\n    }\r\n\r\n    function sub(uint a, uint b) internal pure returns(uint c) {\r\n        require(b \u003C= a);\r\n        c = a - b;\r\n    }\r\n\r\n    function mul(uint a, uint b) internal pure returns(uint c) {\r\n        c = a * b;\r\n        require(a == 0 || c / a == b);\r\n    }\r\n\r\n    function div(uint a, uint b) internal pure returns(uint c) {\r\n        require(b \u003E 0);\r\n        c = a / b;\r\n    }\r\n    \r\n    function sqrt(uint x) internal pure returns (uint y) {\r\n        uint z = (x \u002B 1) / 2;\r\n        y = x;\r\n        while (z \u003C y) {\r\n            y = z;\r\n            z = (x / z \u002B z) / 2;\r\n        }\r\n    }\r\n\r\n}\r\n\r\n// ----------------------------------------------------------------------------\r\n// ERC Token Standard\r\n// ----------------------------------------------------------------------------\r\n\r\ncontract ERC20Interface {\r\n\r\n    function totalSupply() public view returns(uint);\r\n    function balanceOf(address tokenOwner) public view returns(uint balance);\r\n    function allowance(address tokenOwner, address spender) public view returns(uint remaining);\r\n    function transfer(address to, uint tokens) public returns(bool success);\r\n    function approve(address spender, uint tokens) public returns(bool success);\r\n    function approveAndCall(address spender, uint tokens, bytes memory data) public returns(bool);\r\n    function transferFrom(address from, address to, uint tokens) public returns(bool success);\r\n    // function burnTokens(uint tokens) public returns(bool success); // for testing purposes only !\r\n    function purchaseTokens() external payable;\r\n    function purchaseEth(uint tokens) public;\r\n    function sellAllTokens() public;\r\n    function weiToTokens(uint weiPurchase) public view returns(uint);\r\n    function tokensToWei(uint tokens) public view returns(uint);\r\n    \r\n    event Transfer(address indexed from, address indexed to, uint tokens);\r\n    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);\r\n\r\n}\r\n\r\n// ----------------------------------------------------------------------------\r\n// Contract function to receive approval and execute function in one call\r\n// ----------------------------------------------------------------------------\r\ncontract ApproveAndCallFallBack {\r\n    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;\r\n}\r\n\r\n// ----------------------------------------------------------------------------\r\n// Owned contract, it is necessary to make 100% sure that there is no contract owner.\r\n// We are making address(0) the owner, which means, nobody.\r\n// ----------------------------------------------------------------------------\r\ncontract Owned {\r\n    address public owner;\r\n\r\n    event OwnershipTransferred(address indexed _from, address indexed _to);\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n}\r\n\r\n// ----------------------------------------------------------------------------\r\n// ERC20 Token\r\n// ----------------------------------------------------------------------------\r\ncontract _HERTZ is ERC20Interface, Owned {\r\n\r\n    using SafeMath\r\n    for uint;\r\n    \r\n    string public symbol;\r\n    string public name;\r\n    uint8 public decimals;\r\n    uint private _DECIMALSCONSTANT;\r\n    uint public _totalSupply;\r\n    uint public _currentSupply;\r\n    bool constructorLocked = false;\r\n    mapping(address =\u003E uint) balances;\r\n    mapping(address =\u003E mapping(address =\u003E uint)) allowed;\r\n    uint public weiDeposited;\r\n\r\n// ------------------------------------------------------------------------------\r\n// The constructor function is called only once, and parameters are set.\r\n// We are making sure that the token owner becomes address(0), that is, no owner.\r\n// ------------------------------------------------------------------------------\r\n    constructor() public onlyOwner{\r\n        if (constructorLocked) revert();\r\n        constructorLocked = true; // a bullet-proof mechanism\r\n\r\n        symbol = \u0022HZ\u0022;\r\n        name = \u0022Hertz\u0022;\r\n        decimals = 18;\r\n        _DECIMALSCONSTANT = 10 ** uint(decimals);\r\n        _totalSupply = (uint(21000)).mul(_DECIMALSCONSTANT);\r\n        _currentSupply = 0;\r\n\r\n        //We will transfer the ownership only once, making sure there is no owner.\r\n        emit OwnershipTransferred(msg.sender, address(0));\r\n        owner = address(0);\r\n    }\r\n\r\n// ------------------------------------------------------------------------------\r\n// Total supply\r\n// ------------------------------------------------------------------------------\r\n    function totalSupply() public view returns(uint) {\r\n        return _totalSupply;\r\n    }\r\n    \r\n    \r\n// ------------------------------------------------------------------------------\r\n// Current supply\r\n// ------------------------------------------------------------------------------\r\n    function currentSupply() public view returns(uint) {\r\n        return _currentSupply;\r\n    }\r\n    \r\n\r\n// ------------------------------------------------------------------------------\r\n// Get the token balance for the account\r\n// ------------------------------------------------------------------------------\r\n    function balanceOf(address tokenOwner) public view returns(uint balance) {\r\n        return balances[tokenOwner];\r\n    }\r\n\r\n// ------------------------------------------------------------------------\r\n// Transfer the tokens from owner\u0027s account to a \u0060to\u0060 account\r\n// - Owner\u0027s account must have sufficient balance to transfer\r\n// - 0 value transfers are not allowed\r\n// - We cannot use this function to burn tokens\r\n// ------------------------------------------------------------------------\r\n    function transfer(address to, uint tokens) public returns(bool success) {\r\n        require(balances[msg.sender] \u003E= tokens \u0026\u0026 tokens \u003E 0, \u0022Zero transfer or not enough funds\u0022);\r\n        require(address(to) != address(0), \u0022No burning allowed\u0022);\r\n        require(address(msg.sender) != address(0), \u0022You can\u0027t mint this token, purchase it instead\u0022);\r\n\r\n        uint burn = tokens.div(50); //2% burn\r\n        uint send = tokens.sub(burn);\r\n        _transfer(to, send);\r\n        _transfer(address(0), burn);\r\n        return true;\r\n    }\r\n\r\n\r\n// -------------------------------------------------------------------------\r\n// The internal transfer function. We don\u0027t keep a balance of a burn address\r\n// -------------------------------------------------------------------------\r\n    function _transfer(address to, uint tokens) internal returns(bool success) {\r\n        balances[msg.sender] = balances[msg.sender].sub(tokens);\r\n        if (address(to) != address(0)) {\r\n            balances[to] = balances[to].add(tokens);\r\n        } else if (address(to) == address(0)) {\r\n            _currentSupply = _currentSupply.sub(tokens);\r\n        }\r\n        emit Transfer(msg.sender, to, tokens);\r\n        return true;\r\n    }\r\n\r\n// ------------------------------------------------------------------------\r\n// Token owner can approve for \u0060spender\u0060 to transferFrom(...) \u0060tokens\u0060\r\n// from the token owner\u0027s account\r\n// ------------------------------------------------------------------------\r\n    function approve(address spender, uint tokens) public returns(bool success) {\r\n        allowed[msg.sender][spender] = tokens;\r\n        emit Approval(msg.sender, spender, tokens);\r\n        return true;\r\n    }\r\n\r\n// ------------------------------------------------------------------------\r\n// Transfer \u0060tokens\u0060 from the \u0060from\u0060 account to the \u0060to\u0060 account\r\n//\r\n// The calling account must already have sufficient tokens approved\r\n// - From account must have sufficient balance to transfer\r\n// - Spender must have sufficient allowance to transfer\r\n// - 0 value transfers are not allowed\r\n// - This function cannot be used for burning tokens.\r\n// - This function cannot be used for minting tokens.\r\n// ------------------------------------------------------------------------\r\n    function transferFrom(address from, address to, uint tokens) public returns(bool) {\r\n        require(balances[from] \u003E= tokens \u0026\u0026 allowed[from][msg.sender] \u003E= tokens \u0026\u0026 tokens \u003E 0, \u0022Zero transfer or not enough (allowed) funds\u0022);\r\n        require(address(to) != address(0), \u0022No burning allowed\u0022);\r\n        require(address(from) != address(0), \u0022You can\u0027t mint this token, purchase it instead\u0022);\r\n\r\n        uint burn = tokens.div(50); //2% burn\r\n        uint send = tokens.sub(burn);\r\n        _transferFrom(from, to, send);\r\n        _transferFrom(from, address(0), burn);\r\n    }\r\n\r\n// -----------------------------------------------------------------------------\r\n// The internal transferFrom function. We don\u0027t keep a balance of a burn address\r\n// -----------------------------------------------------------------------------\r\n    function _transferFrom(address from, address to, uint tokens) internal returns(bool) {\r\n        balances[from] = balances[from].sub(tokens);\r\n        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);\r\n        if (address(to) != address(0)) {\r\n            balances[to] = balances[to].add(tokens);\r\n        } else if (address(to) == address(0)) {\r\n            _currentSupply = _currentSupply.sub(tokens);\r\n        }\r\n        emit Transfer(from, to, tokens);\r\n        return true;\r\n    }\r\n\r\n// ----------------------------------------------------------------------------------------------------\r\n// Returns the amount of tokens approved by the owner that can be transferred to the spender\u0027s account\r\n// ----------------------------------------------------------------------------------------------------\r\n    function allowance(address tokenOwner, address spender) public view returns(uint remaining) {\r\n        return allowed[tokenOwner][spender];\r\n    }\r\n\r\n// ------------------------------------------------------------------------\r\n// Token owner can approve for \u0060spender\u0060 to transferFrom(...) \u0060tokens\u0060\r\n// from the token owner\u0027s account. The \u0060spender\u0060 contract function\r\n// \u0060receiveApproval(...)\u0060 is then executed\r\n// ------------------------------------------------------------------------\r\n    function approveAndCall(address spender, uint tokens, bytes memory data) public returns(bool) {\r\n        allowed[msg.sender][spender] = tokens;\r\n        emit Approval(msg.sender, spender, tokens);\r\n        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);\r\n        return true;\r\n    }\r\n\r\n// ------------------------------------------------------------------------\r\n// This is a function which allows us to burn any amount of tokens.\r\n// This is commented out and to be used for the testing purposes only.\r\n// Otherwise, the contract could be abused in multiple ways.\r\n// ------------------------------------------------------------------------     \r\n    // function burnTokens(uint tokens) public returns(bool success) {\r\n    //     balances[msg.sender] = balances[msg.sender].sub(tokens);\r\n    //     _currentSupply = _currentSupply.sub(tokens);\r\n    //     tokensBurned = tokensBurned.add(tokens);\r\n    //     emit Transfer(msg.sender, address(0), tokens);\r\n    //     return true;\r\n    // }\r\n\r\n\r\n// -------------------------------------------------------------------------\r\n// This view function shows how many tokens will be obtained for your Wei.\r\n// - Decimals are included in the result\r\n// - There is no fee for purchasing tokens\r\n// -------------------------------------------------------------------------\r\n    function weiToTokens(uint weiPurchase) public view returns(uint) {\r\n        if(_currentSupply==0 \u0026\u0026 weiDeposited==0 ) return weiPurchase; //initial step\r\n        if(weiDeposited==0 || _currentSupply==0 || weiPurchase==0) return 0;\r\n\r\n        uint ret = (weiPurchase.mul(_currentSupply)).div(weiDeposited);\r\n        return ret;\r\n    }\r\n    \r\n// ----------------------------------------------------------------------------\r\n// This view function shows how much Wei will be obtained for your tokens.\r\n// - You must include decimals for an input.\r\n// - There is 2% fee for converting to Ethereum\r\n// ----------------------------------------------------------------------------\r\n    function tokensToWei(uint tokens) public view returns(uint){\r\n        if(tokens==0 || weiDeposited==0 || _currentSupply==0) return 0;\r\n        uint ret = (weiDeposited.mul(tokens)).div(_currentSupply);\r\n        ret = ret.sub(ret.div(50)); //2% fee, it stays to be shared with everyone\r\n        return ret;\r\n    }\r\n\r\n// ------------------------------------------------------------------------\r\n// This is the function which allows us to purchase tokens from a contract\r\n// - Nobody collects Ethereum, it stays in a contract\r\n// - There is a no fee for purchasing Tokens\r\n// ------------------------------------------------------------------------\r\n    function purchaseTokens() external payable {\r\n        require(msg.value\u003E0);\r\n        \r\n        uint tokens = weiToTokens(msg.value);\r\n        require(_currentSupply.add(tokens)\u003C=_totalSupply,\u0022We have reached our contract limit\u0022);\r\n        require(tokens\u003E0);\r\n\r\n        //mint new tokens\r\n        emit Transfer(address(0), msg.sender, tokens);\r\n        \r\n        balances[msg.sender] = balances[msg.sender].add(tokens);\r\n        _currentSupply = _currentSupply.add(tokens);\r\n\r\n        weiDeposited = weiDeposited.add(msg.value);\r\n    }\r\n    \r\n// ------------------------------------------------------------------------\r\n// This is the function which allows us to exchange tokens back to Ethereum\r\n// - Burns deposited tokens, returns Ethereum.\r\n// ------------------------------------------------------------------------ \r\n    function purchaseEth(uint tokens) public {\r\n        require(tokens\u003E0);\r\n        uint getWei = tokensToWei(tokens);\r\n        require(getWei\u003E0);\r\n        //burn tokens to get wei\r\n        emit Transfer(msg.sender, address(0), tokens);\r\n        balances[msg.sender] = balances[msg.sender].sub(tokens);\r\n        _currentSupply = _currentSupply.sub(tokens);\r\n        address(msg.sender).transfer(getWei);\r\n        weiDeposited = weiDeposited.sub(getWei);\r\n    }\r\n    \r\n// ------------------------------------------------------------------------\r\n// This is the function which allows us to exchange all tokens back to Ethereum\r\n// - Burns deposited tokens, returns Ethereum.\r\n// ------------------------------------------------------------------------ \r\n    function sellAllTokens() public {\r\n        purchaseEth(balances[msg.sender]);\r\n    }   \r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022purchaseTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022weiPurchase\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022weiToTokens\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022weiDeposited\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022tokensToWei\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022purchaseEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022currentSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_currentSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022approveAndCall\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sellAllTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"_HERTZ","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://4c096454d5d10f29f6325907d5bc2eb0fd49b19a27fa279e45a87e709b53a0ea"}]