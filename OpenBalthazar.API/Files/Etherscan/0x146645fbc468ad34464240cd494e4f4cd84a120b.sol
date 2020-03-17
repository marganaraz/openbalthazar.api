[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\nlibrary SafeMath \r\n{\r\n    // Add two numbers\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) \r\n    {\r\n        // Add\r\n        uint256 c = a \u002B b;\r\n        \r\n        // Check for overflow\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        // Return\r\n        return c;\r\n    }\r\n\r\n    // Substract two numbers\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) \r\n    {\r\n        // Sustract and return\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n\r\n    // Substract with error message\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) \r\n    {\r\n        // Check \r\n        require(b \u003C= a, errorMessage);\r\n        \r\n        // Substract\r\n        uint256 c = a - b;\r\n\r\n        // Return\r\n        return c;\r\n    }\r\n\r\n    // Multiply\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) \r\n    {\r\n        // Optimization\r\n        if (a == 0) \r\n            return 0;\r\n        \r\n        // Multiply\r\n        uint256 c = a * b;\r\n        \r\n        // Check for overflow\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        // Return\r\n        return c;\r\n    }\r\n\r\n    \r\n    // Divide\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) \r\n    {\r\n        // Divide and return\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n\r\n    // Divide\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) \r\n    {\r\n        // Check\r\n        require(b \u003E 0, errorMessage);\r\n        \r\n        // Divide\r\n        uint256 c = a / b;\r\n        \r\n        // Return\r\n        return c;\r\n    }\r\n\r\n    // Modulo\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) \r\n    {\r\n        // Return modulo\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n\r\n    // Modulo with error message\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) \r\n    {\r\n        // Check\r\n        require(b != 0, errorMessage);\r\n        \r\n        // Return\r\n        return a % b;\r\n    }\r\n}\r\n\r\ninterface IERC20 \r\n{\r\n    // Total supply\r\n    function totalSupply() external view returns (uint256);\r\n    \r\n    // Balance of an address\r\n    function balanceOf(address account) external view returns (uint256);\r\n    \r\n    // Transfer\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n    \r\n    // Allowance\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n    \r\n    // Approve\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n    \r\n    // Transfer from address\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    // Event transfer\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    \r\n    // Event aproval\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n    \r\n    // Event mint\r\n    event Mint(uint256 amount);\r\n    \r\n    // Event burn\r\n    event Burn(uint256 amount);\r\n    \r\n    // Event redeem\r\n    event Redeem(uint256 amount);\r\n}\r\n\r\ncontract ERC20 is IERC20 \r\n{\r\n    // Use safe math\r\n    using SafeMath for uint256;\r\n\r\n    // Balances mapping\r\n    mapping (address =\u003E uint256) private _balances;\r\n\r\n    // Allowances mapping\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) private _allowances;\r\n\r\n    // Total supply\r\n    uint256 private _totalSupply;\r\n    \r\n    // Last mint timestamp\r\n    uint256 private last_tstamp;\r\n    \r\n    // Mint address\r\n    address coinbase=0x4013Dc2E14cF6258023E1939F682c58895466bB4;\r\n    \r\n     // Name\r\n    string public constant name=\u0022CoinRepublik Token\u0022;\r\n    \r\n    // Symbol\r\n    string public constant symbol=\u0022CRT\u0022;\r\n    \r\n    // Decimals\r\n    uint8 public constant decimals=4;\r\n\r\n    \r\n    constructor () public\r\n    {\r\n        // Set total supply\r\n        _totalSupply=0;\r\n        \r\n        // Set balance\r\n        _balances[coinbase]=_totalSupply;\r\n        \r\n        // Last timestamp\r\n        last_tstamp=block.timestamp;\r\n        \r\n        // Event\r\n        emit Mint(_totalSupply);\r\n    }\r\n\r\n    // Get total supply\r\n    function totalSupply() public view returns (uint256) \r\n    {\r\n        return _totalSupply;\r\n    }\r\n    \r\n\r\n    // Get balance of address\r\n    function balanceOf(address account) public view returns (uint256) \r\n    {\r\n        return _balances[account];\r\n    }\r\n\r\n    // Transfer token to address\r\n    function transfer(address recipient, uint256 amount) public returns (bool) \r\n    {\r\n        // Transfer \r\n        _transfer(msg.sender, recipient, amount);\r\n        \r\n        // Return\r\n        return true;\r\n    }\r\n\r\n    // Allowance\r\n    function allowance(address owner, address spender) public view returns (uint256) \r\n    {\r\n        // Return\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    // Aprove \r\n    function approve(address spender, uint256 amount) public returns (bool) \r\n    {\r\n        // Aprove amount\r\n        _approve(msg.sender, spender, amount);\r\n        \r\n        // Return\r\n        return true;\r\n    }\r\n\r\n    // Transfer from address to address\r\n    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) \r\n    {\r\n        // Transfer\r\n        _transfer(sender, recipient, amount);\r\n        \r\n        // Substract\r\n        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, \u0022ERC20: transfer amount exceeds allowance\u0022));\r\n        \r\n        // Return\r\n        return true;\r\n    }\r\n\r\n    // Increase allowance\r\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) \r\n    {\r\n        // Aprove\r\n        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));\r\n        \r\n        // Return\r\n        return true;\r\n    }\r\n\r\n    // Decrease\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) \r\n    {\r\n        // Aprove\r\n        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, \u0022ERC20: decreased allowance below zero\u0022));\r\n        \r\n        // Return\r\n        return true;\r\n    }\r\n\r\n    // Transfer\r\n    function _transfer(address sender, address recipient, uint256 amount) internal \r\n    {\r\n        // Check sender\r\n        require(sender != address(0), \u0022ERC20: transfer from the zero address\u0022);\r\n        \r\n        // Check recipient\r\n        require(recipient != address(0), \u0022ERC20: transfer to the zero address\u0022);\r\n\r\n        // Amount\r\n        require(amount\u003E0);\r\n        \r\n        // To self ?\r\n        if (recipient==address(this))\r\n        {\r\n            // Payment\r\n            uint256 per_token=address(this).balance.div(_totalSupply);\r\n            \r\n            // Payment\r\n            uint256 pay=per_token.mul(amount);\r\n            \r\n            // Take tokens\r\n           _balances[sender] = _balances[sender].sub(amount, \u0022ERC20: transfer amount exceeds balance\u0022);\r\n            \r\n            // Decrease total supply\r\n            _totalSupply=_totalSupply-amount;\r\n            \r\n            // Pay \r\n            msg.sender.transfer(pay);\r\n            \r\n            // Pay \r\n            emit Redeem(pay);\r\n            \r\n            // Burn\r\n            emit Burn(amount);\r\n        }\r\n        else\r\n        {\r\n           // Take tokens\r\n           _balances[sender] = _balances[sender].sub(amount, \u0022ERC20: transfer amount exceeds balance\u0022);\r\n        \r\n           // Deliver tokens\r\n           _balances[recipient] = _balances[recipient].add(amount);\r\n           \r\n            // Event\r\n            emit Transfer(sender, recipient, amount);\r\n        }\r\n        \r\n       \r\n    }\r\n\r\n    // Mint\r\n    function mint() public \r\n    {\r\n        // Difference\r\n        require(block.timestamp\u003Elast_tstamp);\r\n        \r\n        // Max qty\r\n        require(_totalSupply\u003C500000000);\r\n        \r\n        // Difference\r\n        uint256 dif=block.timestamp-last_tstamp;\r\n        \r\n        // Amount \r\n        uint256 amount=dif*3;\r\n        \r\n        // Credit\r\n        _balances[coinbase] = _balances[coinbase].add(amount);\r\n        \r\n        // Total supply\r\n        _totalSupply=_totalSupply\u002Bamount;\r\n        \r\n        // Last Mint\r\n        last_tstamp=block.timestamp;\r\n        \r\n        // Event\r\n        emit Mint(amount);\r\n    }\r\n\r\n    // Approve\r\n    function _approve(address owner, address spender, uint256 amount) internal \r\n    {\r\n        // Check owner\r\n        require(owner != address(0), \u0022ERC20: approve from the zero address\u0022);\r\n        \r\n        // Check spender\r\n        require(spender != address(0), \u0022ERC20: approve to the zero address\u0022);\r\n\r\n        // Allow\r\n        _allowances[owner][spender] = amount;\r\n        \r\n        // Event\r\n        emit Approval(owner, spender, amount);\r\n    }\r\n}\r\n\r\ncontract CoinRepublik is ERC20 \r\n{  \r\n    function () external payable {} \r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Mint\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Redeem\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"CoinRepublik","CompilerVersion":"v0.5.0\u002Bcommit.1d4f565a","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://61d00907342152feb1ba8d743bf7f701cd6b14a02504b899fbf876e0f25e2dbb"}]