[{"SourceCode":"pragma solidity ^0.5.2;\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://eips.ethereum.org/EIPS/eip-20\r\n */\r\ninterface IERC20 {\r\n    function transfer(address to, uint256 value) external returns (bool);\r\n\r\n    function approve(address spender, uint256 value) external returns (bool);\r\n\r\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\r\n\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    function balanceOf(address who) external view returns (uint256);\r\n\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Unsigned math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Multiplies two unsigned integers, reverts on overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Adds two unsigned integers, reverts on overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),\r\n     * reverts when dividing by zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n/**\r\n * @title SafeERC20\r\n * @dev Wrappers around ERC20 operations that throw on failure.\r\n * To use this library you can add a \u0060using SafeERC20 for ERC20;\u0060 statement to your contract,\r\n * which allows you to call the safe operations as \u0060token.safeTransfer(...)\u0060, etc.\r\n */\r\nlibrary SafeERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    function safeTransfer(IERC20 token, address to, uint256 value) internal {\r\n        require(token.transfer(to, value));\r\n    }\r\n\r\n    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {\r\n        require(token.transferFrom(from, to, value));\r\n    }\r\n\r\n    function safeApprove(IERC20 token, address spender, uint256 value) internal {\r\n        // safeApprove should only be called when setting an initial allowance,\r\n        // or when resetting it to zero. To increase and decrease it, use\r\n        // \u0027safeIncreaseAllowance\u0027 and \u0027safeDecreaseAllowance\u0027\r\n        require((value == 0) || (token.allowance(address(this), spender) == 0));\r\n        require(token.approve(spender, value));\r\n    }\r\n\r\n    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {\r\n        uint256 newAllowance = token.allowance(address(this), spender).add(value);\r\n        require(token.approve(spender, newAllowance));\r\n    }\r\n\r\n    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {\r\n        uint256 newAllowance = token.allowance(address(this), spender).sub(value);\r\n        require(token.approve(spender, newAllowance));\r\n    }\r\n}\r\n\r\n/**\r\n * @title TokenTimelock\r\n * @dev TokenTimelock is a token holder contract that will allow a\r\n * beneficiary to extract the tokens after a given release time\r\n */\r\ncontract TokenTimelock {\r\n    using SafeERC20 for IERC20;\r\n\r\n    // ERC20 basic token contract being held\r\n    IERC20 private _token;\r\n\r\n    // beneficiary of tokens after they are released\r\n    address private _beneficiary;\r\n\r\n    // timestamp when token release is enabled\r\n    uint256 private _releaseTime;\r\n\r\n    constructor (IERC20 token, address beneficiary, uint256 releaseTime) public {\r\n        // solhint-disable-next-line not-rely-on-time\r\n        require(releaseTime \u003E block.timestamp);\r\n        _token = token;\r\n        _beneficiary = beneficiary;\r\n        _releaseTime = releaseTime;\r\n    }\r\n\r\n    /**\r\n     * @return the token being held.\r\n     */\r\n    function token() public view returns (IERC20) {\r\n        return _token;\r\n    }\r\n\r\n    /**\r\n     * @return the beneficiary of the tokens.\r\n     */\r\n    function beneficiary() public view returns (address) {\r\n        return _beneficiary;\r\n    }\r\n\r\n    /**\r\n     * @return the time when the tokens are released.\r\n     */\r\n    function releaseTime() public view returns (uint256) {\r\n        return _releaseTime;\r\n    }\r\n\r\n    /**\r\n     * @notice Transfers tokens held by timelock to beneficiary.\r\n     */\r\n    function release() public {\r\n        // solhint-disable-next-line not-rely-on-time\r\n        require(block.timestamp \u003E= _releaseTime);\r\n\r\n        uint256 amount = _token.balanceOf(address(this));\r\n        require(amount \u003E 0);\r\n\r\n        _token.safeTransfer(_beneficiary, amount);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022beneficiary\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022release\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022releaseTime\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022token\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022releaseTime\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"TokenTimelock","CompilerVersion":"v0.5.2\u002Bcommit.1df8f40c","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"00000000000000000000000057b711adeff0d1ecede84b0d16b924e93691dc1a000000000000000000000000e86fb304b20b11d416d618b7162ce2f17547a794000000000000000000000000000000000000000000000000000000005f577ba0","Library":"","SwarmSource":"bzzr://e9b26671283a513fddc3bf91283d0ac11204e46d97890c1829c064f7d5bf476e"}]