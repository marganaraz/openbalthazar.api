[{"SourceCode":"pragma solidity 0.5.8;\r\n\r\ninterface IERC20 {\r\n    function totalSupply() external view returns (uint256);\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function transfer(address recipient, uint256 amount)\r\n        external\r\n        returns (bool);\r\n    function allowance(address owner, address spender)\r\n        external\r\n        view\r\n        returns (uint256);\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n    function transferFrom(address sender, address recipient, uint256 amount)\r\n        external\r\n        returns (bool);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    event Approval(\r\n        address indexed owner,\r\n        address indexed spender,\r\n        uint256 value\r\n    );\r\n}\r\n\r\nlibrary SafeMath {\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b, string memory errorMessage)\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n\r\n    function div(uint256 a, uint256 b, string memory errorMessage)\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n\r\n        return c;\r\n    }\r\n\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n\r\n    function mod(uint256 a, uint256 b, string memory errorMessage)\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\ncontract ERC20 is IERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    mapping(address =\u003E uint256) internal _balances;\r\n    mapping(address =\u003E mapping(address =\u003E uint256)) internal _allowances;\r\n    uint256 internal _totalSupply;\r\n\r\n    function totalSupply() public view returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    function balanceOf(address account) public view returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n\r\n    function transfer(address recipient, uint256 amount) public returns (bool) {\r\n        _transfer(msg.sender, recipient, amount);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address owner, address spender)\r\n        public\r\n        view\r\n        returns (uint256)\r\n    {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    function approve(address spender, uint256 value) public returns (bool) {\r\n        _approve(msg.sender, spender, value);\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(address sender, address recipient, uint256 amount)\r\n        public\r\n        returns (bool)\r\n    {\r\n        _transfer(sender, recipient, amount);\r\n        _approve(\r\n            sender,\r\n            msg.sender,\r\n            _allowances[sender][msg.sender].sub(\r\n                amount,\r\n                \u0022ERC20: transfer amount exceeds allowance\u0022\r\n            )\r\n        );\r\n        return true;\r\n    }\r\n\r\n    function increaseAllowance(address spender, uint256 addedValue)\r\n        public\r\n        returns (bool)\r\n    {\r\n        _approve(\r\n            msg.sender,\r\n            spender,\r\n            _allowances[msg.sender][spender].add(addedValue)\r\n        );\r\n        return true;\r\n    }\r\n\r\n    function decreaseAllowance(address spender, uint256 subtractedValue)\r\n        public\r\n        returns (bool)\r\n    {\r\n        _approve(\r\n            msg.sender,\r\n            spender,\r\n            _allowances[msg.sender][spender].sub(\r\n                subtractedValue,\r\n                \u0022ERC20: decreased allowance below zero\u0022\r\n            )\r\n        );\r\n        return true;\r\n    }\r\n\r\n    function _transfer(address sender, address recipient, uint256 amount)\r\n        internal\r\n    {\r\n        require(sender != address(0), \u0022ERC20: transfer from the zero address\u0022);\r\n        require(recipient != address(0), \u0022ERC20: transfer to the zero address\u0022);\r\n\r\n        _balances[sender] = _balances[sender].sub(\r\n            amount,\r\n            \u0022ERC20: transfer amount exceeds balance\u0022\r\n        );\r\n        _balances[recipient] = _balances[recipient].add(amount);\r\n        emit Transfer(sender, recipient, amount);\r\n    }\r\n\r\n    function _mint(address account, uint256 amount) internal {\r\n        require(account != address(0), \u0022ERC20: mint to the zero address\u0022);\r\n\r\n        _totalSupply = _totalSupply.add(amount);\r\n        _balances[account] = _balances[account].add(amount);\r\n        emit Transfer(address(0), account, amount);\r\n    }\r\n\r\n    function _burn(address account, uint256 value) internal {\r\n        require(account != address(0), \u0022ERC20: burn from the zero address\u0022);\r\n\r\n        _balances[account] = _balances[account].sub(\r\n            value,\r\n            \u0022ERC20: burn amount exceeds balance\u0022\r\n        );\r\n        _totalSupply = _totalSupply.sub(value);\r\n        emit Transfer(account, address(0), value);\r\n    }\r\n\r\n    function _approve(address owner, address spender, uint256 value) internal {\r\n        require(owner != address(0), \u0022ERC20: approve from the zero address\u0022);\r\n        require(spender != address(0), \u0022ERC20: approve to the zero address\u0022);\r\n\r\n        _allowances[owner][spender] = value;\r\n        emit Approval(owner, spender, value);\r\n    }\r\n\r\n    function _burnFrom(address account, uint256 amount) internal {\r\n        _burn(account, amount);\r\n        _approve(\r\n            account,\r\n            msg.sender,\r\n            _allowances[account][msg.sender].sub(\r\n                amount,\r\n                \u0022ERC20: burn amount exceeds allowance\u0022\r\n            )\r\n        );\r\n    }\r\n}\r\n\r\ncontract Alice is ERC20 {\r\n    string public constant name = \u0022Alice\u0022;\r\n    string public constant symbol = \u0022ALICE\u0022;\r\n    uint8 public constant decimals = 18;\r\n\r\n    uint256 public constant INITIAL_SUPPLY = 25000000000; // 25,000,000,000 ALICE\r\n\r\n    constructor(address initialWallet) public {\r\n        _totalSupply = INITIAL_SUPPLY * (10 ** uint256(decimals));\r\n        _balances[initialWallet] = _totalSupply;\r\n        emit Transfer(address(0), initialWallet, _totalSupply);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022INITIAL_SUPPLY\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022initialWallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Alice","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"00000000000000000000000063a7b186819f6e0e1579a5c3b79526e9c6677533","Library":"","SwarmSource":"bzzr://3db1fb580b651f1b94e52be92fe50939558967d13857373f6ba8ca51c07f2ce4"}]