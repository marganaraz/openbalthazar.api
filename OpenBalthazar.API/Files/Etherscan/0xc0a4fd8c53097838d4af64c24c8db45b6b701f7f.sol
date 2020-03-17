[{"SourceCode":"//\r\n//dapp: https://etherscan.io/dapp/0x1603557c3f7197df2ecded659ad04fa72b1e1114#readContract\r\n//\r\n\r\npragma solidity \u003E=0.4.26;\r\n\r\ncontract UniswapExchangeInterface {\r\n    // Address of ERC20 token sold on this exchange\r\n    function tokenAddress() external view returns (address token);\r\n    // Address of Uniswap Factory\r\n    function factoryAddress() external view returns (address factory);\r\n    // Provide Liquidity\r\n    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);\r\n    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);\r\n    // Get Prices\r\n    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);\r\n    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);\r\n    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);\r\n    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);\r\n    // Trade ETH to ERC20\r\n    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);\r\n    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);\r\n    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);\r\n    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);\r\n    // Trade ERC20 to ETH\r\n    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);\r\n    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);\r\n    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);\r\n    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);\r\n    // Trade ERC20 to ERC20\r\n    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);\r\n    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);\r\n    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);\r\n    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);\r\n    // Trade ERC20 to Custom Pool\r\n    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);\r\n    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);\r\n    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);\r\n    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);\r\n    // ERC20 comaptibility for liquidity tokens\r\n    bytes32 public name;\r\n    bytes32 public symbol;\r\n    uint256 public decimals;\r\n    function transfer(address _to, uint256 _value) external returns (bool);\r\n    function transferFrom(address _from, address _to, uint256 value) external returns (bool);\r\n    function approve(address _spender, uint256 _value) external returns (bool);\r\n    function allowance(address _owner, address _spender) external view returns (uint256);\r\n    function balanceOf(address _owner) external view returns (uint256);\r\n    function totalSupply() external view returns (uint256);\r\n    // Never use\r\n    function setup(address token_addr) external;\r\n}\r\n\r\ninterface ERC20 {\r\n    function totalSupply() public view returns (uint supply);\r\n    function balanceOf(address _owner) public view returns (uint balance);\r\n    function transfer(address _to, uint _value) public returns (bool success);\r\n    function transferFrom(address _from, address _to, uint _value) public returns (bool success);\r\n    function approve(address _spender, uint _value) public returns (bool success);\r\n    function allowance(address _owner, address _spender) public view returns (uint remaining);\r\n    function decimals() public view returns(uint digits);\r\n    event Approval(address indexed _owner, address indexed _spender, uint _value);\r\n}\r\n\r\n\r\n/// @title Kyber Network interface\r\ninterface KyberNetworkProxyInterface {\r\n\r\n    function maxGasPrice() public view returns(uint);\r\n    function getUserCapInWei(address user) public view returns(uint);\r\n    function getUserCapInTokenWei(address user, ERC20 token) public view returns(uint);\r\n    function enabled() public view returns(bool);\r\n    function info(bytes32 id) public view returns(uint);\r\n\r\n    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) public view\r\n        returns (uint expectedRate, uint slippageRate);\r\n\r\n    function tradeWithHint(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount,\r\n        uint minConversionRate, address walletId, bytes hint) public payable returns(uint);\r\n\r\n    function swapEtherToToken(ERC20 token, uint minRate) public payable returns (uint);\r\n\r\n    function swapTokenToEther(ERC20 token, uint tokenQty, uint minRate) public returns (uint);\r\n\r\n}\r\n\r\ninterface OrFeedInterface {\r\n  function getExchangeRate ( string fromSymbol, string toSymbol, string venue, uint256 amount ) external view returns ( uint256 );\r\n  function getTokenDecimalCount ( address tokenAddress ) external view returns ( uint256 );\r\n  function getTokenAddress ( string symbol ) external view returns ( address );\r\n  function getSynthBytes32 ( string symbol ) external view returns ( bytes32 );\r\n  function getForexAddress ( string symbol ) external view returns ( address );\r\n}\r\n\r\n\r\ncontract Trader{\r\n\r\n    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);\r\n    KyberNetworkProxyInterface public proxy = KyberNetworkProxyInterface(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);\r\n    OrFeedInterface orfeed= OrFeedInterface(0x8316b082621cfedab95bf4a44a1d4b64a6ffc336);\r\n    address daiAddress = 0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359;\r\n    bytes  PERM_HINT = \u0022PERM\u0022;\r\n    address owner;\r\n\r\n\r\n    modifier onlyOwner() {\r\n        if (msg.sender != owner) {\r\n            throw;\r\n        }\r\n        _;\r\n    }\r\n\r\n\r\n    constructor(){\r\n     owner = msg.sender;\r\n    }\r\n\r\n   function swapEtherToToken (KyberNetworkProxyInterface _kyberNetworkProxy, ERC20 token, address destAddress) internal{\r\n\r\n      uint minRate;\r\n      (, minRate) = _kyberNetworkProxy.getExpectedRate(ETH_TOKEN_ADDRESS, token, msg.value);\r\n\r\n    //will send back tokens to this contract\u0027s address\r\n      uint destAmount = _kyberNetworkProxy.swapEtherToToken.value(msg.value)(token, minRate);\r\n\r\n    //send received tokens to destination address\r\n      require(token.transfer(destAddress, destAmount));\r\n\r\n    }\r\n\r\n    function swapTokenToEther1 (KyberNetworkProxyInterface _kyberNetworkProxy, ERC20 token, uint tokenQty, address destAddress) internal returns (uint) {\r\n\r\n        uint minRate =1;\r\n        //(, minRate) = _kyberNetworkProxy.getExpectedRate(token, ETH_TOKEN_ADDRESS, tokenQty);\r\n\r\n        // Check that the token transferFrom has succeeded\r\n        token.transferFrom(msg.sender, this, tokenQty);\r\n\r\n        // Mitigate ERC20 Approve front-running attack, by initially setting\r\n        // allowance to 0\r\n\r\n       token.approve(proxy, 0);\r\n\r\n        // Approve tokens so network can take them during the swap\r\n       token.approve(address(proxy), tokenQty);\r\n\r\n       uint destAmount = proxy.tradeWithHint(ERC20(daiAddress), tokenQty, ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee), this, 8000000000000000000000000000000000000000000000000000000000000000, 0, 0x0000000000000000000000000000000000000004, PERM_HINT);\r\n\r\n       return destAmount;\r\n       //uint destAmount = proxy.swapTokenToEther(token, tokenQty, minRate);\r\n\r\n      // Send received ethers to destination address\r\n     //  destAddress.transfer(destAmount);\r\n    }\r\n\r\n     function kyberToUniSwapArb(address fromAddress, address uniSwapContract, uint theAmount) public payable onlyOwner returns (bool){\r\n\r\n        address theAddress = uniSwapContract;\r\n        UniswapExchangeInterface usi = UniswapExchangeInterface(theAddress);\r\n\r\n        ERC20 address1 = ERC20(fromAddress);\r\n\r\n        uint ethBack = swapTokenToEther1(proxy, address1 , theAmount, msg.sender);\r\n\r\n        usi.ethToTokenSwapInput.value(ethBack)(1, block.timestamp);\r\n\r\n        return true;\r\n    }\r\n\r\n\r\n    function () external payable  {\r\n\r\n    }\r\n\r\n\r\n\r\n    function withdrawETHAndTokens() onlyOwner{\r\n\r\n        msg.sender.send(address(this).balance);\r\n         ERC20 daiToken = ERC20(daiAddress);\r\n        uint256 currentTokenBalance = daiToken.balanceOf(this);\r\n        daiToken.transfer(msg.sender, currentTokenBalance);\r\n\r\n    }\r\n\r\n\r\n    function getKyberSellPrice() constant returns (uint256){\r\n        uint256 currentPrice =  orfeed.getExchangeRate(\u0022ETH\u0022, \u0022DAI\u0022, \u0022SELL-KYBER-EXCHANGE\u0022, 1000000000000000000);\r\n        return currentPrice;\r\n    }\r\n\r\n    // \u003E\u003E\u003E\r\n    function getKyberBuyPrice() constant returns (uint256){\r\n        uint256 currentPrice =  orfeed.getExchangeRate(\u0022ETH\u0022, \u0022DAI\u0022, \u0022BUY-KYBER-EXCHANGE\u0022, 1000000000000000000);\r\n        return currentPrice;\r\n    }\r\n\r\n     function getUniswapBuyPrice() constant returns (uint256){\r\n        uint256 currentPrice =  orfeed.getExchangeRate(\u0022ETH\u0022, \u0022DAI\u0022, \u0022BUY-UNISWAP-EXCHANGE\u0022, 1000000000000000000);\r\n        return currentPrice;\r\n    }\r\n\r\n    // \u003E\u003E\u003E\r\n    function getUniswapSellPrice() constant returns (uint256){\r\n       uint256 currentPrice =  orfeed.getExchangeRate(\u0022ETH\u0022, \u0022DAI\u0022, \u0022SELL-UNISWAP-EXCHANGE\u0022, 1000000000000000000);\r\n       return currentPrice;\r\n   }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getUniswapBuyPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getUniswapSellPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getKyberBuyPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getKyberSellPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawETHAndTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022fromAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022uniSwapContract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022theAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022kyberToUniSwapArb\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022proxy\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022}]","ContractName":"Trader","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://bfdf7d38f570d0f16bb66f180d30772502683762795c63649f8334eeb28ab60a"}]