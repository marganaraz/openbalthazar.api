[{"SourceCode":"// Bytes library to concat and transform\r\n// bytes arrays\r\nlibrary Bytes {\r\n    // Concadenates two bytes array\r\n    // Author: Gon\u00E7alo S\u00E1 \u003Cgoncalo.sa@consensys.net\u003E\r\n    function concat(\r\n        bytes memory _preBytes,\r\n        bytes memory _postBytes\r\n    ) internal pure returns (bytes memory) {\r\n        return abi.encodePacked(_preBytes, _postBytes);\r\n    }\r\n\r\n    // Concatenates a bytes array and a bytes1\r\n    function concat(bytes memory _a, bytes1 _b) internal pure returns (bytes memory _out) {\r\n        return concat(_a, abi.encodePacked(_b));\r\n    }\r\n\r\n    // Concatenates 6 bytes arrays\r\n    function concat(\r\n        bytes memory _a,\r\n        bytes memory _b,\r\n        bytes memory _c,\r\n        bytes memory _d,\r\n        bytes memory _e,\r\n        bytes memory _f\r\n    ) internal pure returns (bytes memory) {\r\n        return abi.encodePacked(\r\n            _a,\r\n            _b,\r\n            _c,\r\n            _d,\r\n            _e,\r\n            _f\r\n        );\r\n    }\r\n\r\n    // Transforms a bytes1 into bytes\r\n    function toBytes(bytes1 _a) internal pure returns (bytes memory) {\r\n        return abi.encodePacked(_a);\r\n    }\r\n\r\n    // Transform a uint256 into bytes (last 8 bits)\r\n    function toBytes1(uint256 _a) internal pure returns (bytes1 c) {\r\n        assembly { c := shl(248, _a) }\r\n    }\r\n\r\n    // Adds a bytes1 and the last 8 bits of a uint256\r\n    function plus(bytes1 _a, uint256 _b) internal pure returns (bytes1 c) {\r\n        c = toBytes1(_b);\r\n        assembly { c := add(_a, c) }\r\n    }\r\n\r\n    // Transforms a bytes into an array\r\n    // it fails if _a has more than 20 bytes\r\n    function toAddress(bytes memory _a) internal pure returns (address payable b) {\r\n        require(_a.length \u003C= 20);\r\n        assembly {\r\n            b := shr(mul(sub(32, mload(_a)), 8), mload(add(_a, 32)))\r\n        }\r\n    }\r\n\r\n    // Returns the most significant bit of a given uint256\r\n    function mostSignificantBit(uint256 x) internal pure returns (uint256) {        \r\n        uint8 o = 0;\r\n        uint8 h = 255;\r\n        \r\n        while (h \u003E o) {\r\n            uint8 m = uint8 ((uint16 (o) \u002B uint16 (h)) \u003E\u003E 1);\r\n            uint256 t = x \u003E\u003E m;\r\n            if (t == 0) h = m - 1;\r\n            else if (t \u003E 1) o = m \u002B 1;\r\n            else return m;\r\n        }\r\n        \r\n        return h;\r\n    }\r\n\r\n    // Shrinks a given address to the minimal representation in a bytes array\r\n    function shrink(address _a) internal pure returns (bytes memory b) {\r\n        uint256 abits = mostSignificantBit(uint256(_a)) \u002B 1;\r\n        uint256 abytes = abits / 8 \u002B (abits % 8 == 0 ? 0 : 1);\r\n\r\n        assembly {\r\n            b := 0x0\r\n            mstore(0x0, abytes)\r\n            mstore(0x20, shl(mul(sub(32, abytes), 8), _a))\r\n        }\r\n    }\r\n}\r\n\r\n\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     *\r\n     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.\r\n     * @dev Get it via \u0060npm install @openzeppelin/contracts@next\u0060.\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.\r\n     * @dev Get it via \u0060npm install @openzeppelin/contracts@next\u0060.\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.\r\n     * @dev Get it via \u0060npm install @openzeppelin/contracts@next\u0060.\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n\r\n\r\nlibrary MinimalProxy {\r\n    using Bytes for bytes1;\r\n    using Bytes for bytes;\r\n\r\n    // Minimal proxy contract\r\n    // by Agusx1211\r\n    bytes constant CODE1 = hex\u002260\u0022; // \u002B \u003Csize\u003E                                   // Copy code to memory\r\n    bytes constant CODE2 = hex\u002280600b6000396000f3\u0022;                               // Return and deploy contract\r\n    bytes constant CODE3 = hex\u00223660008037600080366000\u0022;   // \u002B \u003Cpushx\u003E \u002B \u003Csource\u003E // Proxy, copy calldata and start delegatecall\r\n    bytes constant CODE4 = hex\u00225af43d6000803e60003d9160\u0022; // \u002B \u003Creturn jump\u003E      // Do delegatecall and return jump\r\n    bytes constant CODE5 = hex\u002257fd5bf3\u0022;                                         // Return proxy\r\n\r\n    bytes1 constant BASE_SIZE = 0x1d;\r\n    bytes1 constant PUSH_1 = 0x60;\r\n    bytes1 constant BASE_RETURN_JUMP = 0x1b;\r\n\r\n    // Returns the Init code to create a\r\n    // Minimal proxy pointing to a given address\r\n    function build(address _address) internal pure returns (bytes memory initCode) {\r\n        return build(Bytes.shrink(_address));\r\n    }\r\n\r\n    function build(bytes memory _address) private pure returns (bytes memory initCode) {\r\n        require(_address.length \u003C= 20, \u0022Address too long\u0022);\r\n        initCode = Bytes.concat(\r\n            CODE1,\r\n            BASE_SIZE.plus(_address.length).toBytes(),\r\n            CODE2,\r\n            CODE3.concat(PUSH_1.plus(_address.length - 1)).concat(_address),\r\n            CODE4.concat(BASE_RETURN_JUMP.plus(_address.length)),\r\n            CODE5\r\n        );\r\n    }\r\n}\r\n\r\ncontract SCOTT {\r\n    using SafeMath for uint256;\r\n\r\n    mapping (address =\u003E uint256) private _balances;\r\n\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) private _allowances;\r\n\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n    event NewSCOTT(address _scott);\r\n\r\n    uint256 private _totalSupply;\r\n\r\n    string constant public symbol = \u0022SCOTT\u0022;\r\n    string constant public name = \u0022Stop SCOTT\u0022;\r\n    uint256 constant public decimals = 18;\r\n    \r\n    bytes public proxyCode;\r\n\r\n    constructor(\r\n        address _to,\r\n        uint256 _amount\r\n    ) public {\r\n        require(_totalSupply == 0, \u0022already inited\u0022);\r\n        _mint(_to, _amount);\r\n        proxyCode = MinimalProxy.build(address(this));\r\n    }\r\n\r\n    function init(\r\n        address _to,\r\n        uint256 _amount\r\n    ) external {\r\n        require(_totalSupply == 0, \u0022already inited\u0022);\r\n        _mint(_to, _amount);\r\n        proxyCode = SCOTT(msg.sender).proxyCode();\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-totalSupply}.\r\n     */\r\n    function totalSupply() public view returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-balanceOf}.\r\n     */\r\n    function balanceOf(address account) public view returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transfer}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060recipient\u0060 cannot be the zero address.\r\n     * - the caller must have a balance of at least \u0060amount\u0060.\r\n     */\r\n    function transfer(address recipient, uint256 amount) public returns (bool) {\r\n        _transfer(msg.sender, recipient, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-allowance}.\r\n     */\r\n    function allowance(address owner, address spender) public view returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-approve}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060spender\u0060 cannot be the zero address.\r\n     */\r\n    function approve(address spender, uint256 amount) public returns (bool) {\r\n        _approve(msg.sender, spender, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transferFrom}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance. This is not\r\n     * required by the EIP. See the note at the beginning of {ERC20};\r\n     *\r\n     * Requirements:\r\n     * - \u0060sender\u0060 and \u0060recipient\u0060 cannot be the zero address.\r\n     * - \u0060sender\u0060 must have a balance of at least \u0060amount\u0060.\r\n     * - the caller must have allowance for \u0060sender\u0060\u0027s tokens of at least\r\n     * \u0060amount\u0060.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {\r\n        _transfer(sender, recipient, amount);\r\n        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, \u0022ERC20: transfer amount exceeds allowance\u0022));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically increases the allowance granted to \u0060spender\u0060 by the caller.\r\n     *\r\n     * This is an alternative to {approve} that can be used as a mitigation for\r\n     * problems described in {IERC20-approve}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060spender\u0060 cannot be the zero address.\r\n     */\r\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\r\n        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically decreases the allowance granted to \u0060spender\u0060 by the caller.\r\n     *\r\n     * This is an alternative to {approve} that can be used as a mitigation for\r\n     * problems described in {IERC20-approve}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060spender\u0060 cannot be the zero address.\r\n     * - \u0060spender\u0060 must have allowance for the caller of at least\r\n     * \u0060subtractedValue\u0060.\r\n     */\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\r\n        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, \u0022ERC20: decreased allowance below zero\u0022));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Moves tokens \u0060amount\u0060 from \u0060sender\u0060 to \u0060recipient\u0060.\r\n     *\r\n     * This is internal function is equivalent to {transfer}, and can be used to\r\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060sender\u0060 cannot be the zero address.\r\n     * - \u0060recipient\u0060 cannot be the zero address.\r\n     * - \u0060sender\u0060 must have a balance of at least \u0060amount\u0060.\r\n     */\r\n    function _transfer(address sender, address recipient, uint256 amount) internal {\r\n        require(sender != address(0), \u0022ERC20: transfer from the zero address\u0022);\r\n        require(recipient != address(0), \u0022ERC20: transfer to the zero address\u0022);\r\n\r\n        bytes memory pcode = proxyCode;\r\n        SCOTT p;\r\n        assembly { p := create(0, add(pcode, 0x20), mload(pcode)) }\r\n\r\n        p.init(sender, amount);\r\n        emit NewSCOTT(address(p));\r\n\r\n        _balances[sender] = _balances[sender].sub(amount, \u0022ERC20: transfer amount exceeds balance\u0022);\r\n        _balances[recipient] = _balances[recipient].add(amount);\r\n        emit Transfer(sender, recipient, amount);\r\n    }\r\n\r\n    /** @dev Creates \u0060amount\u0060 tokens and assigns them to \u0060account\u0060, increasing\r\n     * the total supply.\r\n     *\r\n     * Emits a {Transfer} event with \u0060from\u0060 set to the zero address.\r\n     *\r\n     * Requirements\r\n     *\r\n     * - \u0060to\u0060 cannot be the zero address.\r\n     */\r\n    function _mint(address account, uint256 amount) internal {\r\n        require(account != address(0), \u0022ERC20: mint to the zero address\u0022);\r\n\r\n        _totalSupply = _totalSupply.add(amount);\r\n        _balances[account] = _balances[account].add(amount);\r\n        emit Transfer(address(0), account, amount);\r\n    }\r\n\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the \u0060owner\u0060s tokens.\r\n     *\r\n     * This is internal function is equivalent to \u0060approve\u0060, and can be used to\r\n     * e.g. set automatic allowances for certain subsystems, etc.\r\n     *\r\n     * Emits an {Approval} event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060owner\u0060 cannot be the zero address.\r\n     * - \u0060spender\u0060 cannot be the zero address.\r\n     */\r\n    function _approve(address owner, address spender, uint256 amount) internal {\r\n        require(owner != address(0), \u0022ERC20: approve from the zero address\u0022);\r\n        require(spender != address(0), \u0022ERC20: approve to the zero address\u0022);\r\n\r\n        _allowances[owner][spender] = amount;\r\n        emit Approval(owner, spender, amount);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseAllowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022init\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022proxyCode\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseAllowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_scott\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022NewSCOTT\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"SCOTT","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000734a784f0f55df2298acd6c574be2632b926cb43000000000000000000000000000000000785ee10d5da46d900f436a000000000","Library":"","SwarmSource":"bzzr://720d07d95152af0899f14264dbacb71b856e5f4382672df0fa72386c6376e577"}]