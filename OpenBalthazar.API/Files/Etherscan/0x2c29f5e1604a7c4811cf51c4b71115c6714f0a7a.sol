[{"SourceCode":"pragma solidity ^0.5.12;\r\n\r\n/*\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with GSN meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\ncontract Context {\r\n    // Empty internal constructor, to prevent people from mistakenly deploying\r\n    // an instance of this contract, which should be used via inheritance.\r\n    constructor () internal { }\r\n    // solhint-disable-previous-line no-empty-blocks\r\n\r\n    function _msgSender() internal view returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * \u0060onlyOwner\u0060, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\ncontract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () internal {\r\n        address msgSender = _msgSender();\r\n        _owner = msgSender;\r\n        emit OwnershipTransferred(address(0), msgSender);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the caller is the current owner.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return _msgSender() == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * \u0060onlyOwner\u0060 functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\ncontract UniswapExchangeInterface {\r\n    // Address of ERC20 token sold on this exchange\r\n    function tokenAddress() external view returns (address token);\r\n    // Address of Uniswap Factory\r\n    function factoryAddress() external view returns (address factory);\r\n    // Provide Liquidity\r\n    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);\r\n    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);\r\n    // Get Prices\r\n    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);\r\n    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);\r\n    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);\r\n    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);\r\n    // Trade ETH to ERC20\r\n    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);\r\n    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);\r\n    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);\r\n    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);\r\n    // Trade ERC20 to ETH\r\n    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);\r\n    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);\r\n    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);\r\n    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);\r\n    // Trade ERC20 to ERC20\r\n    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);\r\n    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);\r\n    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);\r\n    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);\r\n    // Trade ERC20 to Custom Pool\r\n    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);\r\n    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);\r\n    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);\r\n    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);\r\n    // ERC20 comaptibility for liquidity tokens\r\n    bytes32 public name;\r\n    bytes32 public symbol;\r\n    uint256 public decimals;\r\n    function transfer(address _to, uint256 _value) external returns (bool);\r\n    function transferFrom(address _from, address _to, uint256 value) external returns (bool);\r\n    function approve(address _spender, uint256 _value) external returns (bool);\r\n    function allowance(address _owner, address _spender) external view returns (uint256);\r\n    function balanceOf(address _owner) external view returns (uint256);\r\n    function totalSupply() external view returns (uint256);\r\n    // Never use\r\n    function setup(address token_addr) external;\r\n}\r\n\r\ncontract ERC20Interface {\r\n    function totalSupply() public view returns (uint);\r\n    function balanceOf(address tokenOwner) public view returns (uint balance);\r\n    function allowance(address tokenOwner, address spender) public view returns (uint remaining);\r\n    function transfer(address to, uint tokens) public returns (bool success);\r\n    function approve(address spender, uint tokens) public returns (bool success);\r\n    function transferFrom(address from, address to, uint tokens) public returns (bool success);\r\n    // optional\r\n    function name() external view returns (string memory);\r\n    function symbol() external view returns (string memory);\r\n    function decimals() external view returns (string memory);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint tokens);\r\n    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);\r\n}\r\n\r\ncontract PaymentStore is Ownable {\r\n    //ETC \u003C-\u003E USDC Uniswap Contract\r\n    UniswapExchangeInterface public constant uniswap = UniswapExchangeInterface(0x97deC872013f6B5fB443861090ad931542878126);\r\n    \r\n    //USDC Token\r\n    ERC20Interface public constant token = ERC20Interface(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);\r\n    \r\n    function() external payable { }\r\n    \r\n    function withdraw(uint256 amount) public onlyOwner returns (uint256) {\r\n        uint256 currentBalance = address(this).balance;\r\n        \r\n        require(amount \u003C= currentBalance);\r\n        \r\n        address _owner = owner();\r\n        \r\n        uint256 deadline = block.timestamp \u002B (60 * 60 * 24); \r\n        \r\n        uint256 tokenToBuy = uniswap.getEthToTokenInputPrice(amount);\r\n        \r\n        uint256 tokensBought = uniswap.ethToTokenSwapInput.value(amount)(tokenToBuy, deadline);\r\n        \r\n        token.transfer(_owner, tokensBought);\r\n        \r\n        return tokensBought;\r\n    }\r\n}","ABI":"[{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022token\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract ERC20Interface\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022uniswap\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract UniswapExchangeInterface\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"PaymentStore","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://50b2ee6636b101f13d9d326ea873d4005a5d8d4b098d41fe13cb11da07b3fbe4"}]