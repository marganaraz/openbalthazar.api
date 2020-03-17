[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\ninterface ERC20 {\r\n    function totalSupply() external view returns (uint supply);\r\n    function balanceOf(address _owner) external view returns (uint balance);\r\n    function transfer(address _to, uint _value) external returns (bool success);\r\n    function transferFrom(address _from, address _to, uint _value) external returns (bool success);\r\n    function approve(address _spender, uint _value) external returns (bool success);\r\n    function allowance(address _owner, address _spender) external view returns (uint remaining);\r\n    function decimals() external view returns(uint digits);\r\n    event Approval(address indexed _owner, address indexed _spender, uint _value);\r\n}\r\n\r\n//TODO: currenlty only adjusted to kyber, but should be genric interfaces for more dec. exchanges\r\ninterface ExchangeInterface {\r\n    function swapEtherToToken (uint _ethAmount, address _tokenAddress, uint _maxAmount) payable external returns(uint, uint);\r\n    function swapTokenToEther (address _tokenAddress, uint _amount, uint _maxAmount) external returns(uint);\r\n\r\n    function getExpectedRate(address src, address dest, uint srcQty) external view\r\n        returns (uint expectedRate, uint slippageRate);\r\n}\r\n\r\ncontract DSMath {\r\n    function add(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x \u002B y) \u003E= x);\r\n    }\r\n    function sub(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x - y) \u003C= x);\r\n    }\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x);\r\n    }\r\n\r\n    function min(uint x, uint y) internal pure returns (uint z) {\r\n        return x \u003C= y ? x : y;\r\n    }\r\n    function max(uint x, uint y) internal pure returns (uint z) {\r\n        return x \u003E= y ? x : y;\r\n    }\r\n    function imin(int x, int y) internal pure returns (int z) {\r\n        return x \u003C= y ? x : y;\r\n    }\r\n    function imax(int x, int y) internal pure returns (int z) {\r\n        return x \u003E= y ? x : y;\r\n    }\r\n\r\n    uint constant WAD = 10 ** 18;\r\n    uint constant RAY = 10 ** 27;\r\n\r\n    function wmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), WAD / 2) / WAD;\r\n    }\r\n    function rmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), RAY / 2) / RAY;\r\n    }\r\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, WAD), y / 2) / y;\r\n    }\r\n    function rdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, RAY), y / 2) / y;\r\n    }\r\n\r\n    // This famous algorithm is called \u0022exponentiation by squaring\u0022\r\n    // and calculates x^n with x as fixed-point and n as regular unsigned.\r\n    //\r\n    // It\u0027s O(log n), instead of O(n) for naive repeated multiplication.\r\n    //\r\n    // These facts are why it works:\r\n    //\r\n    //  If n is even, then x^n = (x^2)^(n/2).\r\n    //  If n is odd,  then x^n = x * x^(n-1),\r\n    //   and applying the equation for even x gives\r\n    //    x^n = x * (x^2)^((n-1) / 2).\r\n    //\r\n    //  Also, EVM division is flooring and\r\n    //    floor[(n-1) / 2] = floor[n / 2].\r\n    //\r\n    function rpow(uint x, uint n) internal pure returns (uint z) {\r\n        z = n % 2 != 0 ? x : RAY;\r\n\r\n        for (n /= 2; n != 0; n /= 2) {\r\n            x = rmul(x, x);\r\n\r\n            if (n % 2 != 0) {\r\n                z = rmul(z, x);\r\n            }\r\n        }\r\n    }\r\n}\r\n\r\ncontract ConstantAddressesMainnet {\r\n    address public constant MAKER_DAI_ADDRESS = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;\r\n    address public constant IDAI_ADDRESS = 0x14094949152EDDBFcd073717200DA82fEd8dC960;\r\n    address public constant SOLO_MARGIN_ADDRESS = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;\r\n    address public constant CDAI_ADDRESS = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;\r\n    address public constant KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\r\n    address public constant MKR_ADDRESS = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;\r\n    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;\r\n    address public constant VOX_ADDRESS = 0x9B0F70Df76165442ca6092939132bBAEA77f2d7A;\r\n    address public constant PETH_ADDRESS = 0xf53AD2c6851052A81B42133467480961B2321C09;\r\n    address public constant TUB_ADDRESS = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;\r\n    address public constant WALLET_ID = 0x322d58b9E75a6918f7e7849AEe0fF09369977e08;\r\n    address public constant LOGGER_ADDRESS = 0xeCf88e1ceC2D2894A0295DB3D86Fe7CE4991E6dF;\r\n    address public constant OTC_ADDRESS = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e;\r\n\r\n    address public constant KYBER_WRAPPER = 0xAae7ba823679889b12f71D1f18BEeCBc69E62237;\r\n    address public constant UNISWAP_WRAPPER = 0x0aa70981311D60a9521C99cecFDD68C3E5a83B83;\r\n    address public constant ETH2DAI_WRAPPER = 0xd7BBB1777E13b6F535Dec414f575b858ed300baF;\r\n\r\n    address public constant KYBER_INTERFACE = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;\r\n    address public constant UNISWAP_FACTORY = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;\r\n\r\n    // Kovan addresses, don\u0027t have mainnet\r\n    address public constant FACTORY_ADDRESS = 0xc72E74E474682680a414b506699bBcA44ab9a930;\r\n\r\n    address public constant PIP_INTERFACE_ADDRESS = 0xA944bd4b25C9F186A846fd5668941AA3d3B8425F;\r\n    address public constant PROXY_REGISTRY_INTERFACE_ADDRESS = 0x64A436ae831C1672AE81F674CAb8B6775df3475C;\r\n    address public constant GAS_TOKEN_INTERFACE_ADDRESS = 0x0000000000170CcC93903185bE5A2094C870Df62;\r\n    address public constant CTOKEN_INTERFACE = 0xb6b09fBffBa6A5C4631e5F7B2e3Ee183aC259c0d;\r\n\r\n    // Kovan addresses, not used on mainnet\r\n    // address public constant COMPOUND_DAI_ADDRESS = 0x25a01a05C188DaCBCf1D61Af55D4a5B4021F7eeD;\r\n    // address public constant STUPID_EXCHANGE = 0x863E41FE88288ebf3fcd91d8Dbb679fb83fdfE17;\r\n}\r\n\r\ncontract ConstantAddressesKovan {\r\n    address public constant KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\r\n    address public constant WETH_ADDRESS = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;\r\n    address public constant MAKER_DAI_ADDRESS = 0xC4375B7De8af5a38a93548eb8453a498222C4fF2;\r\n    address public constant MKR_ADDRESS = 0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD;\r\n    address public constant VOX_ADDRESS = 0xBb4339c0aB5B1d9f14Bd6e3426444A1e9d86A1d9;\r\n    address public constant PETH_ADDRESS = 0xf4d791139cE033Ad35DB2B2201435fAd668B1b64;\r\n    address public constant TUB_ADDRESS = 0xa71937147b55Deb8a530C7229C442Fd3F31b7db2;\r\n    address public constant LOGGER_ADDRESS = 0x32d0e18f988F952Eb3524aCE762042381a2c39E5;\r\n    address public constant WALLET_ID = 0x54b44C6B18fc0b4A1010B21d524c338D1f8065F6;\r\n    address public constant OTC_ADDRESS = 0x4A6bC4e803c62081ffEbCc8d227B5a87a58f1F8F;\r\n    address public constant COMPOUND_DAI_ADDRESS = 0x25a01a05C188DaCBCf1D61Af55D4a5B4021F7eeD;\r\n    address public constant IDAI_ADDRESS = 0xb6b09fBffBa6A5C4631e5F7B2e3Ee183aC259c0d;\r\n    address public constant SOLO_MARGIN_ADDRESS = 0x4EC3570cADaAEE08Ae384779B0f3A45EF85289DE;\r\n    address public constant CDAI_ADDRESS = 0xb6b09fBffBa6A5C4631e5F7B2e3Ee183aC259c0d;\r\n    address public constant STUPID_EXCHANGE = 0x863E41FE88288ebf3fcd91d8Dbb679fb83fdfE17;\r\n\r\n    address public constant KYBER_WRAPPER = 0x5595930d576Aedf13945C83cE5aaD827529A1310;\r\n    address public constant UNISWAP_WRAPPER = 0x5595930d576Aedf13945C83cE5aaD827529A1310;\r\n    address public constant ETH2DAI_WRAPPER = 0x823cde416973a19f98Bb9C96d97F4FE6C9A7238B;\r\n\r\n    address public constant FACTORY_ADDRESS = 0xc72E74E474682680a414b506699bBcA44ab9a930;\r\n    //\r\n    address public constant PIP_INTERFACE_ADDRESS = 0xA944bd4b25C9F186A846fd5668941AA3d3B8425F;\r\n    address public constant PROXY_REGISTRY_INTERFACE_ADDRESS = 0x64A436ae831C1672AE81F674CAb8B6775df3475C;\r\n    address public constant GAS_TOKEN_INTERFACE_ADDRESS = 0x0000000000170CcC93903185bE5A2094C870Df62;\r\n    address public constant KYBER_INTERFACE = 0x692f391bCc85cefCe8C237C01e1f636BbD70EA4D;\r\n    address public constant CTOKEN_INTERFACE = 0xb6b09fBffBa6A5C4631e5F7B2e3Ee183aC259c0d;\r\n\r\n    // Rinkeby, when no Kovan\r\n    address public constant UNISWAP_FACTORY = 0xf5D915570BC477f9B8D6C0E980aA81757A3AaC36;\r\n}\r\n\r\ncontract ConstantAddresses is ConstantAddressesKovan {\r\n}\r\n\r\ncontract SaverExchange is DSMath, ConstantAddresses {\r\n\r\n    uint public constant SERVICE_FEE = 800; // 0.125% Fee\r\n\r\n    function swapDaiToEth(uint _amount, uint _minPrice, uint _exchangeType) public {\r\n        require(ERC20(MAKER_DAI_ADDRESS).transferFrom(msg.sender, address(this), _amount));\r\n\r\n        uint fee = takeFee(_amount);\r\n        _amount = sub(_amount, fee);\r\n\r\n        address exchangeWrapper;\r\n        uint daiEthPrice;\r\n        (exchangeWrapper, daiEthPrice) = getBestPrice(_amount, MAKER_DAI_ADDRESS, KYBER_ETH_ADDRESS, _exchangeType);\r\n\r\n        require(daiEthPrice \u003E _minPrice, \u0022Slippage hit\u0022);\r\n\r\n        ERC20(MAKER_DAI_ADDRESS).transfer(exchangeWrapper, _amount);\r\n        ExchangeInterface(exchangeWrapper).swapTokenToEther(MAKER_DAI_ADDRESS, _amount, uint(-1));\r\n\r\n        uint daiBalance = ERC20(MAKER_DAI_ADDRESS).balanceOf(address(this));\r\n        if (daiBalance \u003E 0) {\r\n            ERC20(MAKER_DAI_ADDRESS).transfer(msg.sender, daiBalance);\r\n        }\r\n\r\n        msg.sender.transfer(address(this).balance);\r\n    }\r\n\r\n    function swapEthToDai(uint _amount, uint _minPrice, uint _exchangeType) public payable {\r\n        require(msg.value \u003E= _amount);\r\n\r\n        address exchangeWrapper;\r\n        uint ethDaiPrice;\r\n        (exchangeWrapper, ethDaiPrice) = getBestPrice(_amount, KYBER_ETH_ADDRESS, MAKER_DAI_ADDRESS, _exchangeType);\r\n\r\n        require(ethDaiPrice \u003E _minPrice, \u0022Slippage hit\u0022);\r\n\r\n        uint ethReturned;\r\n        uint daiReturned;\r\n        (daiReturned, ethReturned) = ExchangeInterface(exchangeWrapper).swapEtherToToken.value(_amount)(_amount, MAKER_DAI_ADDRESS, uint(-1));\r\n\r\n        uint fee = takeFee(daiReturned);\r\n        daiReturned = sub(daiReturned, fee);\r\n\r\n        ERC20(MAKER_DAI_ADDRESS).transfer(msg.sender, daiReturned);\r\n\r\n        if (ethReturned \u003E 0) {\r\n            msg.sender.transfer(ethReturned);\r\n        }\r\n    }\r\n\r\n\r\n    /// @notice Returns the best estimated price from 2 exchanges\r\n    /// @param _amount Amount of source tokens you want to exchange\r\n    /// @param _srcToken Address of the source token\r\n    /// @param _destToken Address of the destination token\r\n    /// @return (address, uint) The address of the best exchange and the exchange price\r\n    function getBestPrice(uint _amount, address _srcToken, address _destToken, uint _exchangeType) public view returns (address, uint) {\r\n        uint expectedRateKyber;\r\n        uint expectedRateUniswap;\r\n        uint expectedRateEth2Dai;\r\n\r\n        (expectedRateKyber, ) = ExchangeInterface(KYBER_WRAPPER).getExpectedRate(_srcToken, _destToken, _amount);\r\n        // no deployment on kovan\r\n        (expectedRateUniswap, ) = ExchangeInterface(UNISWAP_WRAPPER).getExpectedRate(_srcToken, _destToken, _amount);\r\n        // reverts on kovan\r\n        (expectedRateEth2Dai, ) = ExchangeInterface(ETH2DAI_WRAPPER).getExpectedRate(_srcToken, _destToken, _amount);\r\n\r\n        if (_exchangeType == 1) {\r\n            return (ETH2DAI_WRAPPER, expectedRateEth2Dai);\r\n        }\r\n\r\n        if (_exchangeType == 2) {\r\n            return (KYBER_WRAPPER, expectedRateKyber);\r\n        }\r\n\r\n        if (_exchangeType == 3) {\r\n            return (UNISWAP_WRAPPER, expectedRateUniswap);\r\n        }\r\n\r\n        if ((expectedRateEth2Dai \u003E= expectedRateKyber) \u0026\u0026 (expectedRateEth2Dai \u003E= expectedRateUniswap)) {\r\n            return (ETH2DAI_WRAPPER, expectedRateEth2Dai);\r\n        }\r\n\r\n        if ((expectedRateKyber \u003E= expectedRateUniswap) \u0026\u0026 (expectedRateKyber \u003E= expectedRateEth2Dai)) {\r\n            return (KYBER_WRAPPER, expectedRateKyber);\r\n        }\r\n\r\n        if ((expectedRateUniswap \u003E= expectedRateKyber) \u0026\u0026 (expectedRateUniswap \u003E= expectedRateEth2Dai)) {\r\n            return (UNISWAP_WRAPPER, expectedRateUniswap);\r\n        }\r\n    }\r\n\r\n    /// @notice Takes a feePercentage and sends it to wallet\r\n    /// @param _amount Dai amount of the whole trade\r\n    /// @return feeAmount Amount in Dai owner earned on the fee\r\n    function takeFee(uint _amount) internal returns (uint feeAmount) {\r\n        feeAmount = _amount / SERVICE_FEE;\r\n        if (feeAmount \u003E 0) {\r\n            ERC20(MAKER_DAI_ADDRESS).transfer(WALLET_ID, feeAmount);\r\n        }\r\n    }\r\n\r\n    // receive eth from wrappers\r\n    function() external payable {}\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_minPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_exchangeType\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022swapEthToDai\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022WETH_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022CDAI_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022PIP_INTERFACE_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022KYBER_ETH_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022OTC_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022IDAI_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_srcToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_destToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_exchangeType\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getBestPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022GAS_TOKEN_INTERFACE_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022VOX_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ETH2DAI_WRAPPER\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022STUPID_EXCHANGE\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SERVICE_FEE\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022PROXY_REGISTRY_INTERFACE_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MKR_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022FACTORY_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022LOGGER_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MAKER_DAI_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022KYBER_WRAPPER\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022COMPOUND_DAI_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_minPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_exchangeType\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022swapDaiToEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022UNISWAP_FACTORY\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022PETH_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022KYBER_INTERFACE\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022WALLET_ID\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SOLO_MARGIN_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022UNISWAP_WRAPPER\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TUB_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022CTOKEN_INTERFACE\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022}]","ContractName":"SaverExchange","CompilerVersion":"v0.5.7\u002Bcommit.6da8b019","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://50b4fd31f1594a8041f95e36f63423f20fe6529522b770298b44cc29c2227494"}]