[{"SourceCode":"pragma solidity ^0.5.10;\r\n\r\n\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n\r\n    /**\r\n     * @dev Multiplies two numbers, throws on overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            \r\n            return 0;\r\n        }\r\n        uint256 c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Integer division of two numbers, truncating the quotient.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    /**\r\n     * @dev Adds two numbers, throws on overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}\r\ncontract Ownable {\r\n   address payable public owner;\r\n\r\n   event OwnershipTransferred(address indexed _from, address indexed _to);\r\n\r\n   constructor() public {\r\n       owner = msg.sender;\r\n   }\r\n\r\n   modifier onlyOwner {\r\n       require(msg.sender == owner);\r\n       _;\r\n   }\r\n\r\n   function transferOwnership(address payable _newOwner) public onlyOwner {\r\n       owner = _newOwner;\r\n   }\r\n}\r\n\r\n\r\ncontract Pausable is Ownable{\r\n \r\n    bool private _paused = false;\r\n\r\n  \r\n  \r\n\r\n    /**\r\n     * @dev Returns true if the contract is paused, and false otherwise.\r\n     */\r\n    function paused() public view returns (bool) {\r\n        return _paused;\r\n    }\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is not paused.\r\n     */\r\n    modifier whenNotPaused() {\r\n        require(!_paused, \u0022Pausable: paused\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is paused.\r\n     */\r\n    modifier whenPaused() {\r\n        require(_paused, \u0022Pausable: not paused\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Called by a pauser to pause, triggers stopped state.\r\n     */\r\n    function pause() public onlyOwner whenNotPaused {\r\n        _paused = true;\r\n    }\r\n\r\n    /**\r\n     * @dev Called by a pauser to unpause, returns to normal state.\r\n     */\r\n    function unpause() public onlyOwner whenPaused {\r\n        _paused = false;\r\n    }\r\n}\r\n\r\ncontract ERC20 {\r\n    function totalSupply() public view returns (uint256);\r\n    function balanceOf(address who) public view returns (uint256);\r\n    function transfer(address to, uint256 value) public returns (bool);\r\n    function allowance(address owner, address spender) public view returns (uint256);\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool);\r\n    function approve(address spender, uint256 value) public returns (bool);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n    \r\ncontract TokenSwap is Ownable ,Pausable  {\r\n    \r\n    using SafeMath for uint256;\r\n    ERC20 public oldToken;\r\n    ERC20 public newToken;\r\n\r\n    constructor (address _oldToken , address _newToken ) public {\r\n        oldToken = ERC20(_oldToken);\r\n        newToken = ERC20(_newToken);\r\n    \r\n    }\r\n    \r\n\r\n    \r\n    function swapTokens() public whenNotPaused{\r\n        uint tokenAllowance = oldToken.allowance(msg.sender, address(this));\r\n        require(tokenAllowance\u003E0 , \u0022token allowence is\u0022);\r\n        require(newToken.balanceOf(address(this)) \u003E tokenAllowance , \u0022not enough balance\u0022);\r\n        oldToken.transferFrom(msg.sender, address(0), tokenAllowance);\r\n        newToken.transfer(msg.sender, tokenAllowance);\r\n\r\n    }\r\n    \r\n\r\n    function kill() public onlyOwner {\r\n    selfdestruct(msg.sender);\r\n  }\r\n  \r\n      /**\r\n     * @dev Return all tokens back to owner, in case any were accidentally\r\n     *   transferred to this contract.\r\n     */\r\n    function returnNewTokens() public onlyOwner whenNotPaused {\r\n        newToken.transfer(owner, newToken.balanceOf(address(this)));\r\n    }\r\n    \r\n       \r\n    \r\n      /**\r\n     * @dev Return all tokens back to owner, in case any were accidentally\r\n     *   transferred to this contract.\r\n     */\r\n    function returnOldTokens() public onlyOwner whenNotPaused {\r\n        oldToken.transfer(owner, oldToken.balanceOf(address(this)));\r\n    }\r\n    \r\n    \r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022returnOldTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022kill\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022swapTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022oldToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022newToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022returnNewTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_oldToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_newToken\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"TokenSwap","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000003f06b5d78406cd97bdf10f5c420b241d32759c8000000000000000000000000032b87fb81674aa79214e51ae42d571136e29d385","Library":"","SwarmSource":"bzzr://d68fe7cced5aeed1acb2e76a743025ce6d3635dc0c88dbce7ae7122b20b56e33"}]