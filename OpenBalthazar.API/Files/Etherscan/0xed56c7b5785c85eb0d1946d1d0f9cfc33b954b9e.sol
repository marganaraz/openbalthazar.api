[{"SourceCode":"pragma solidity ^0.4.26;\r\ncontract UniswapExchangeInterface {\r\n    // Address of ERC20 token sold on this exchange\r\n    function tokenAddress() external view returns (address token);\r\n    // Address of Uniswap Factory\r\n    function factoryAddress() external view returns (address factory);\r\n    // Provide Liquidity\r\n    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);\r\n    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);\r\n    // Get Prices\r\n    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);\r\n    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);\r\n    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);\r\n    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);\r\n    // Trade ETH to ERC20\r\n    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);\r\n    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);\r\n    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);\r\n    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);\r\n    // Trade ERC20 to ETH\r\n    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);\r\n    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);\r\n    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);\r\n    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);\r\n    // Trade ERC20 to ERC20\r\n    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);\r\n    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);\r\n    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);\r\n    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);\r\n    // Trade ERC20 to Custom Pool\r\n    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);\r\n    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);\r\n    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);\r\n    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);\r\n    // ERC20 comaptibility for liquidity tokens\r\n    bytes32 public name;\r\n    bytes32 public symbol;\r\n    uint256 public decimals;\r\n    function transfer(address _to, uint256 _value) external returns (bool);\r\n    function transferFrom(address _from, address _to, uint256 value) external returns (bool);\r\n    function approve(address _spender, uint256 _value) external returns (bool);\r\n    function allowance(address _owner, address _spender) external view returns (uint256);\r\n    function balanceOf(address _owner) external view returns (uint256);\r\n    function totalSupply() external view returns (uint256);\r\n    // Never use\r\n    function setup(address token_addr) external;\r\n}\r\n\r\ninterface ERC20 {\r\n    function totalSupply() public view returns (uint supply);\r\n    function balanceOf(address _owner) public view returns (uint balance);\r\n    function transfer(address _to, uint _value) public returns (bool success);\r\n    function transferFrom(address _from, address _to, uint _value) public returns (bool success);\r\n    function approve(address _spender, uint _value) public returns (bool success);\r\n    function allowance(address _owner, address _spender) public view returns (uint remaining);\r\n    function decimals() public view returns(uint digits);\r\n    event Approval(address indexed _owner, address indexed _spender, uint _value);\r\n}\r\n\r\ninterface OrFeedInterface {\r\n  function getExchangeRate ( string fromSymbol, string toSymbol, string venue, uint256 amount ) external view returns ( uint256 );\r\n  function getTokenDecimalCount ( address tokenAddress ) external view returns ( uint256 );\r\n  function getTokenAddress ( string symbol ) external view returns ( address );\r\n  function getSynthBytes32 ( string symbol ) external view returns ( bytes32 );\r\n  function getForexAddress ( string symbol ) external view returns ( address );\r\n}\r\n\r\ninterface Kyber {\r\n    function getOutputAmount(ERC20 from, ERC20 to, uint256 amount) external view returns(uint256);\r\n\r\n    function getInputAmount(ERC20 from, ERC20 to, uint256 amount) external view returns(uint256);\r\n}\r\n\r\n\r\nlibrary SafeMath {\r\n    function mul(uint256 a, uint256 b) internal constant returns(uint256) {\r\n        uint256 c = a * b;\r\n        assert(a == 0 || c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal constant returns(uint256) {\r\n        assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n        uint256 c = a / b;\r\n        assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal constant returns(uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal constant returns(uint256) {\r\n        uint256 c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}\r\n\r\n\r\n\r\n\r\n\r\n\r\ncontract PremiumFeedPrices{\r\n    \r\n    mapping (address=\u003Eaddress) uniswapAddresses;\r\n    mapping (string=\u003Eaddress) tokenAddress;\r\n    \r\n    \r\n     constructor() public  {\r\n         \r\n         //DAI\r\n         uniswapAddresses[0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359] = 0x09cabec1ead1c0ba254b09efb3ee13841712be14;\r\n         \r\n         //usdc\r\n         uniswapAddresses[0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48] = 0x97dec872013f6b5fb443861090ad931542878126;\r\n         \r\n         //MKR\r\n         \r\n         uniswapAddresses[0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2] = 0x2c4bd064b998838076fa341a83d007fc2fa50957;\r\n         \r\n         //BAT\r\n         uniswapAddresses[0x0d8775f648430679a709e98d2b0cb6250d2887ef] = 0x2e642b8d59b45a1d8c5aef716a84ff44ea665914;\r\n         \r\n         //LINK\r\n         uniswapAddresses[0x514910771af9ca656af840dff83e8264ecf986ca] = 0xf173214c720f58e03e194085b1db28b50acdeead;\r\n         \r\n         //ZRX\r\n         uniswapAddresses[0xe41d2489571d322189246dafa5ebde1f4699f498] = 0xae76c84c9262cdb9abc0c2c8888e62db8e22a0bf;\r\n     \r\n         \r\n         \r\n         \r\n         \r\n         \r\n         tokenAddress[\u0027DAI\u0027] = 0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359;\r\n        tokenAddress[\u0027USDC\u0027] = 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48;\r\n        tokenAddress[\u0027MKR\u0027] = 0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2;\r\n        tokenAddress[\u0027LINK\u0027] = 0x514910771af9ca656af840dff83e8264ecf986ca;\r\n        tokenAddress[\u0027BAT\u0027] = 0x0d8775f648430679a709e98d2b0cb6250d2887ef;\r\n        tokenAddress[\u0027WBTC\u0027] = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599;\r\n        tokenAddress[\u0027BTC\u0027] = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599;\r\n        tokenAddress[\u0027OMG\u0027] = 0xd26114cd6EE289AccF82350c8d8487fedB8A0C07;\r\n        tokenAddress[\u0027ZRX\u0027] = 0xe41d2489571d322189246dafa5ebde1f4699f498;\r\n        tokenAddress[\u0027TUSD\u0027] = 0x0000000000085d4780B73119b644AE5ecd22b376;\r\n        tokenAddress[\u0027ETH\u0027] = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\r\n        tokenAddress[\u0027WETH\u0027] = 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2;\r\n        \r\n     }\r\n     \r\n     function getExchangeRate(string fromSymbol, string toSymbol, string venue, uint256 amount, address requestAddress) public constant returns(uint256){\r\n         \r\n         address toA1 = tokenAddress[fromSymbol];\r\n         address toA2 = tokenAddress[toSymbol];\r\n         \r\n         \r\n         \r\n         string memory theSide = determineSide(venue);\r\n         string memory theExchange = determineExchange(venue);\r\n         \r\n         uint256 price = 0;\r\n         \r\n         if(equal(theExchange,\u0022UNISWAP\u0022)){\r\n            price= uniswapPrice(toA1, toA2, theSide, amount);\r\n         }\r\n         \r\n         if(equal(theExchange,\u0022KYBER\u0022)){\r\n            price= kyberPrice(toA1, toA2, theSide, amount);\r\n         }\r\n         \r\n         \r\n         return price;\r\n     }\r\n    \r\n    function uniswapPrice(address token1, address token2, string  side, uint256 amount) public constant returns (uint256){\r\n    \r\n            address fromExchange = getUniswapContract(token1);\r\n            address toExchange = getUniswapContract(token2);\r\n            UniswapExchangeInterface usi1 = UniswapExchangeInterface(fromExchange);\r\n            UniswapExchangeInterface usi2 = UniswapExchangeInterface(toExchange);    \r\n        \r\n            uint256  ethPrice1;\r\n            uint256 ethPrice2;\r\n            uint256 resultingTokens;\r\n            \r\n        if(equal(side,\u0022BUY\u0022)){\r\n            //startingEth = usi1.getTokenToEthInputPrice(amount);\r\n        \r\n            if(token2 == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE){\r\n                resultingTokens = usi1.getEthToTokenOutputPrice(amount);\r\n                return resultingTokens;\r\n            }\r\n            if(token1 == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE){\r\n                resultingTokens = usi2.getTokenToEthOutputPrice(amount);\r\n                return resultingTokens;\r\n            }\r\n            \r\n            ethPrice1= usi2.getTokenToEthOutputPrice(amount);\r\n            \r\n            \r\n            ethPrice2 = usi1.getTokenToEthOutputPrice(amount);\r\n\r\n            resultingTokens = ethPrice1/ethPrice2;\r\n            \r\n            return resultingTokens;\r\n        }\r\n        \r\n        else{\r\n            \r\n             if(token2 == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE){\r\n                resultingTokens = usi1.getEthToTokenOutputPrice(amount);\r\n                return resultingTokens;\r\n            }\r\n            if(token1 == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE){\r\n                resultingTokens = usi2.getEthToTokenInputPrice(amount);\r\n                return resultingTokens;\r\n            }\r\n            \r\n            \r\n             ethPrice1= usi2.getTokenToEthInputPrice(amount);\r\n            ethPrice2 = usi1.getTokenToEthInputPrice(amount);\r\n\r\n            resultingTokens = ethPrice1/ethPrice2;\r\n            \r\n            return resultingTokens;\r\n        }\r\n    \r\n    }\r\n    \r\n    \r\n    \r\n     function kyberPrice(address token1, address token2, string  side, uint256 amount) public constant returns (uint256){\r\n         \r\n         Kyber kyber = Kyber(0xFd9304Db24009694c680885e6aa0166C639727D6);\r\n         uint256 price;\r\n           if(equal(side,\u0022BUY\u0022)){\r\n               price = kyber.getOutputAmount(ERC20(token1), ERC20(token2), amount);\r\n           }\r\n           else{\r\n                price = kyber.getInputAmount(ERC20(token1), ERC20(token2), amount);\r\n           }\r\n         \r\n         return price;\r\n     }\r\n    \r\n    \r\n    \r\n    function getUniswapContract(address tokenAddress) public constant returns (address){\r\n        return uniswapAddresses[tokenAddress];\r\n    }\r\n    \r\n    function determineSide(string sideString) public constant returns (string){\r\n            \r\n        if(contains(\u0022SELL\u0022, sideString ) == false){\r\n            return \u0022BUY\u0022;\r\n        }\r\n        \r\n        else{\r\n            return \u0022SELL\u0022;\r\n        }\r\n    }\r\n    \r\n    \r\n    \r\n    function determineExchange(string exString) constant returns (string){\r\n            \r\n        if(contains(\u0022UNISWA\u0022, exString ) == true){\r\n            return \u0022UNISWAP\u0022;\r\n        }\r\n        \r\n        else if(contains(\u0022KYBE\u0022, exString ) == true){\r\n            return \u0022KYBER\u0022;\r\n        }\r\n        else{\r\n            return \u0022NONE\u0022;\r\n        }\r\n    }\r\n    \r\n    \r\n    function contains (string memory what, string memory where)  constant returns(bool){\r\n    bytes memory whatBytes = bytes (what);\r\n    bytes memory whereBytes = bytes (where);\r\n\r\n    bool found = false;\r\n    for (uint i = 0; i \u003C whereBytes.length - whatBytes.length; i\u002B\u002B) {\r\n        bool flag = true;\r\n        for (uint j = 0; j \u003C whatBytes.length; j\u002B\u002B)\r\n            if (whereBytes [i \u002B j] != whatBytes [j]) {\r\n                flag = false;\r\n                break;\r\n            }\r\n        if (flag) {\r\n            found = true;\r\n            break;\r\n        }\r\n    }\r\n  \r\n    return found;\r\n    \r\n}\r\n\r\n\r\n   function compare(string _a, string _b) returns (int) {\r\n        bytes memory a = bytes(_a);\r\n        bytes memory b = bytes(_b);\r\n        uint minLength = a.length;\r\n        if (b.length \u003C minLength) minLength = b.length;\r\n        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons\r\n        for (uint i = 0; i \u003C minLength; i \u002B\u002B)\r\n            if (a[i] \u003C b[i])\r\n                return -1;\r\n            else if (a[i] \u003E b[i])\r\n                return 1;\r\n        if (a.length \u003C b.length)\r\n            return -1;\r\n        else if (a.length \u003E b.length)\r\n            return 1;\r\n        else\r\n            return 0;\r\n    }\r\n    /// @dev Compares two strings and returns true iff they are equal.\r\n    function equal(string _a, string _b) returns (bool) {\r\n        return compare(_a, _b) == 0;\r\n    }\r\n    /// @dev Finds the index of the first occurrence of _needle in _haystack\r\n    function indexOf(string _haystack, string _needle) returns (int)\r\n    {\r\n    \tbytes memory h = bytes(_haystack);\r\n    \tbytes memory n = bytes(_needle);\r\n    \tif(h.length \u003C 1 || n.length \u003C 1 || (n.length \u003E h.length)) \r\n    \t\treturn -1;\r\n    \telse if(h.length \u003E (2**128 -1)) // since we have to be able to return -1 (if the char isn\u0027t found or input error), this function must return an \u0022int\u0022 type with a max length of (2^128 - 1)\r\n    \t\treturn -1;\t\t\t\t\t\t\t\t\t\r\n    \telse\r\n    \t{\r\n    \t\tuint subindex = 0;\r\n    \t\tfor (uint i = 0; i \u003C h.length; i \u002B\u002B)\r\n    \t\t{\r\n    \t\t\tif (h[i] == n[0]) // found the first char of b\r\n    \t\t\t{\r\n    \t\t\t\tsubindex = 1;\r\n    \t\t\t\twhile(subindex \u003C n.length \u0026\u0026 (i \u002B subindex) \u003C h.length \u0026\u0026 h[i \u002B subindex] == n[subindex]) // search until the chars don\u0027t match or until we reach the end of a or b\r\n    \t\t\t\t{\r\n    \t\t\t\t\tsubindex\u002B\u002B;\r\n    \t\t\t\t}\t\r\n    \t\t\t\tif(subindex == n.length)\r\n    \t\t\t\t\treturn int(i);\r\n    \t\t\t}\r\n    \t\t}\r\n    \t\treturn -1;\r\n    \t}\t\r\n    }\r\n    \r\n\r\n    \r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022fromSymbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022toSymbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022venue\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022requestAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getExchangeRate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022sideString\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022determineSide\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_a\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_b\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022compare\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022int256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022what\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022where\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022contains\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022exString\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022determineExchange\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_a\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_b\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022equal\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022token1\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022token2\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022side\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022uniswapPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022token1\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022token2\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022side\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022kyberPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_haystack\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_needle\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022indexOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022int256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getUniswapContract\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"PremiumFeedPrices","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://fb4959c9cf7bf5c296a3611b9c34821e10ba7f09d39fec2905fca9aaea0a7cdd"}]