[{"SourceCode":"//example contract address: https://etherscan.io/address/0x1d6cbd79054b89ade7d840d1640a949ea82b7639#code\r\n\r\npragma solidity ^0.4.26;\r\ncontract UniswapExchangeInterface {\r\n    // Address of ERC20 token sold on this exchange\r\n    function tokenAddress() external view returns (address token);\r\n    // Address of Uniswap Factory\r\n    function factoryAddress() external view returns (address factory);\r\n    // Provide Liquidity\r\n    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);\r\n    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);\r\n    // Get Prices\r\n    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);\r\n    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);\r\n    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);\r\n    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);\r\n    // Trade ETH to ERC20\r\n    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);\r\n    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);\r\n    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);\r\n    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);\r\n    // Trade ERC20 to ETH\r\n    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);\r\n    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);\r\n    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);\r\n    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);\r\n    // Trade ERC20 to ERC20\r\n    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);\r\n    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);\r\n    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);\r\n    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);\r\n    // Trade ERC20 to Custom Pool\r\n    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);\r\n    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);\r\n    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);\r\n    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);\r\n    // ERC20 comaptibility for liquidity tokens\r\n    bytes32 public name;\r\n    bytes32 public symbol;\r\n    uint256 public decimals;\r\n    function transfer(address _to, uint256 _value) external returns (bool);\r\n    function transferFrom(address _from, address _to, uint256 value) external returns (bool);\r\n    function approve(address _spender, uint256 _value) external returns (bool);\r\n    function allowance(address _owner, address _spender) external view returns (uint256);\r\n    function balanceOf(address _owner) external view returns (uint256);\r\n    function totalSupply() external view returns (uint256);\r\n    // Never use\r\n    function setup(address token_addr) external;\r\n}\r\n\r\ninterface ERC20 {\r\n    function totalSupply() public view returns (uint supply);\r\n    function balanceOf(address _owner) public view returns (uint balance);\r\n    function transfer(address _to, uint _value) public returns (bool success);\r\n    function transferFrom(address _from, address _to, uint _value) public returns (bool success);\r\n    function approve(address _spender, uint _value) public returns (bool success);\r\n    function allowance(address _owner, address _spender) public view returns (uint remaining);\r\n    function decimals() public view returns(uint digits);\r\n    event Approval(address indexed _owner, address indexed _spender, uint _value);\r\n}\r\n\r\ninterface OrFeedInterface {\r\n  function getExchangeRate ( string fromSymbol, string toSymbol, string venue, uint256 amount ) external view returns ( uint256 );\r\n  function getTokenDecimalCount ( address tokenAddress ) external view returns ( uint256 );\r\n  function getTokenAddress ( string symbol ) external view returns ( address );\r\n  function getSynthBytes32 ( string symbol ) external view returns ( bytes32 );\r\n  function getForexAddress ( string symbol ) external view returns ( address );\r\n}\r\n\r\n\r\n\r\ncontract UniswapTradeExample{\r\n\r\n    function buyDai() payable returns(uint256){\r\n\r\n        //token we are buying contract address... this this case DAI\r\n        address daiAddress = 0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14;\r\n        //Define Uniswap\r\n        UniswapExchangeInterface usi = UniswapExchangeInterface(daiAddress);\r\n\r\n        //amoutn of ether sent to this contract\r\n        uint256 amountEth = msg.value;\r\n\r\n        uint256 amountBack = usi.ethToTokenSwapInput.value(amountEth)(1, block.timestamp);\r\n\r\n        ERC20 daiToken = ERC20(0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359);\r\n        daiToken.transfer(msg.sender, amountBack);\r\n        return amountBack;\r\n\r\n\r\n    }\r\n\r\n    function getDAIPrice() constant returns(uint256){\r\n        OrFeedInterface orfeed= OrFeedInterface(0x8316b082621cfedab95bf4a44a1d4b64a6ffc336);\r\n        uint256 ethPrice = orfeed.getExchangeRate(\u0022ETH\u0022, \u0022USD\u0022, \u0022\u0022, 100000000);\r\n        return ethPrice;\r\n    }\r\n\r\n\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getDAIPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022buyDai\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"UniswapTradeExample","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://7135643384b5233b30be9066e9eeac3c07d404498f7b7e3b37cebb8929af20a5"}]