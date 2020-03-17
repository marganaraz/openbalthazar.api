[{"SourceCode":"/**\r\n *Submitted for verification at Etherscan.io on 2019-10-30\r\n*/\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\ninterface ERC20 {\r\n    function totalSupply() external view returns (uint supply);\r\n    function balanceOf(address _owner) external view returns (uint balance);\r\n    function transfer(address _to, uint _value) external returns (bool success);\r\n    function transferFrom(address _from, address _to, uint _value) external returns (bool success);\r\n    function approve(address _spender, uint _value) external returns (bool success);\r\n    function allowance(address _owner, address _spender) external view returns (uint remaining);\r\n    function decimals() external view returns(uint digits);\r\n    event Approval(address indexed _owner, address indexed _spender, uint _value);\r\n}\r\n\r\ninterface ExchangeInterface {\r\n    function swapEtherToToken (uint _ethAmount, address _tokenAddress, uint _maxAmount) payable external returns(uint, uint);\r\n    function swapTokenToEther (address _tokenAddress, uint _amount, uint _maxAmount) external returns(uint);\r\n    function swapTokenToToken(address _src, address _dest, uint _amount) external payable returns(uint);\r\n\r\n    function getExpectedRate(address src, address dest, uint srcQty) external view\r\n        returns (uint expectedRate);\r\n}\r\n\r\ncontract DSMath {\r\n    function add(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x \u002B y) \u003E= x);\r\n    }\r\n    function sub(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x - y) \u003C= x);\r\n    }\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x);\r\n    }\r\n\r\n    function min(uint x, uint y) internal pure returns (uint z) {\r\n        return x \u003C= y ? x : y;\r\n    }\r\n    function max(uint x, uint y) internal pure returns (uint z) {\r\n        return x \u003E= y ? x : y;\r\n    }\r\n    function imin(int x, int y) internal pure returns (int z) {\r\n        return x \u003C= y ? x : y;\r\n    }\r\n    function imax(int x, int y) internal pure returns (int z) {\r\n        return x \u003E= y ? x : y;\r\n    }\r\n\r\n    uint constant WAD = 10 ** 18;\r\n    uint constant RAY = 10 ** 27;\r\n\r\n    function wmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), WAD / 2) / WAD;\r\n    }\r\n    function rmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), RAY / 2) / RAY;\r\n    }\r\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, WAD), y / 2) / y;\r\n    }\r\n    function rdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, RAY), y / 2) / y;\r\n    }\r\n\r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n    function rpow(uint x, uint n) internal pure returns (uint z) {\r\n        z = n % 2 != 0 ? x : RAY;\r\n\r\n        for (n /= 2; n != 0; n /= 2) {\r\n            x = rmul(x, x);\r\n\r\n            if (n % 2 != 0) {\r\n                z = rmul(z, x);\r\n            }\r\n        }\r\n    }\r\n}\r\n\r\ncontract ConstantAddressesMainnet {\r\n    address public constant MAKER_DAI_ADDRESS = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;\r\n    address public constant IDAI_ADDRESS = 0x14094949152EDDBFcd073717200DA82fEd8dC960;\r\n    address public constant SOLO_MARGIN_ADDRESS = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;\r\n    address public constant CDAI_ADDRESS = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;\r\n    address public constant KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\r\n    address public constant MKR_ADDRESS = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;\r\n    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;\r\n    address public constant VOX_ADDRESS = 0x9B0F70Df76165442ca6092939132bBAEA77f2d7A;\r\n    address public constant PETH_ADDRESS = 0xf53AD2c6851052A81B42133467480961B2321C09;\r\n    address public constant TUB_ADDRESS = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;\r\n    address payable public constant WALLET_ID = 0x322d58b9E75a6918f7e7849AEe0fF09369977e08;\r\n    address public constant LOGGER_ADDRESS = 0xeCf88e1ceC2D2894A0295DB3D86Fe7CE4991E6dF;\r\n    address public constant OTC_ADDRESS = 0x794e6e91555438aFc3ccF1c5076A74F42133d08D;\r\n    address public constant DISCOUNT_ADDRESS = 0x1b14E8D511c9A4395425314f849bD737BAF8208F;\r\n\r\n    address public constant KYBER_WRAPPER = 0x8F337bD3b7F2b05d9A8dC8Ac518584e833424893;\r\n    address public constant UNISWAP_WRAPPER = 0x1e30124FDE14533231216D95F7798cD0061e5cf8;\r\n    address public constant OASIS_WRAPPER = 0x82FF91671Baa663CdC724E6769b0751DAa88B18b;\r\n\r\n    address public constant KYBER_INTERFACE = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;\r\n    address public constant UNISWAP_FACTORY = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;\r\n    address public constant FACTORY_ADDRESS = 0x5a15566417e6C1c9546523066500bDDBc53F88C7;\r\n    address public constant PIP_INTERFACE_ADDRESS = 0x729D19f657BD0614b4985Cf1D82531c67569197B;\r\n\r\n    address public constant PROXY_REGISTRY_INTERFACE_ADDRESS = 0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4;\r\n    address public constant GAS_TOKEN_INTERFACE_ADDRESS = 0x0000000000b3F879cb30FE243b4Dfee438691c04;\r\n\r\n    address public constant SAVINGS_LOGGER_ADDRESS = 0x89b3635BD2bAD145C6f92E82C9e83f06D5654984;\r\n\r\n    \r\n    address public constant COMPOUND_DAI_ADDRESS = 0x25a01a05C188DaCBCf1D61Af55D4a5B4021F7eeD;\r\n    address public constant STUPID_EXCHANGE = 0x863E41FE88288ebf3fcd91d8Dbb679fb83fdfE17;\r\n}\r\n\r\ncontract ConstantAddressesKovan {\r\n    address public constant KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\r\n    address public constant WETH_ADDRESS = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;\r\n    address public constant MAKER_DAI_ADDRESS = 0xC4375B7De8af5a38a93548eb8453a498222C4fF2;\r\n    address public constant MKR_ADDRESS = 0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD;\r\n    address public constant VOX_ADDRESS = 0xBb4339c0aB5B1d9f14Bd6e3426444A1e9d86A1d9;\r\n    address public constant PETH_ADDRESS = 0xf4d791139cE033Ad35DB2B2201435fAd668B1b64;\r\n    address public constant TUB_ADDRESS = 0xa71937147b55Deb8a530C7229C442Fd3F31b7db2;\r\n    address public constant LOGGER_ADDRESS = 0x32d0e18f988F952Eb3524aCE762042381a2c39E5;\r\n    address payable public  constant WALLET_ID = 0x54b44C6B18fc0b4A1010B21d524c338D1f8065F6;\r\n    address public constant OTC_ADDRESS = 0x4A6bC4e803c62081ffEbCc8d227B5a87a58f1F8F;\r\n    address public constant COMPOUND_DAI_ADDRESS = 0x25a01a05C188DaCBCf1D61Af55D4a5B4021F7eeD;\r\n    address public constant SOLO_MARGIN_ADDRESS = 0x4EC3570cADaAEE08Ae384779B0f3A45EF85289DE;\r\n    address public constant IDAI_ADDRESS = 0xA1e58F3B1927743393b25f261471E1f2D3D9f0F6;\r\n    address public constant CDAI_ADDRESS = 0xb6b09fBffBa6A5C4631e5F7B2e3Ee183aC259c0d;\r\n    address public constant STUPID_EXCHANGE = 0x863E41FE88288ebf3fcd91d8Dbb679fb83fdfE17;\r\n    address public constant DISCOUNT_ADDRESS = 0x1297c1105FEDf45E0CF6C102934f32C4EB780929;\r\n\r\n    address public constant KYBER_WRAPPER = 0x0eED9d768BBed73A66201ab1441fa6a039e65228;\r\n    address public constant UNISWAP_WRAPPER = 0xb07a1Cb9661957E6949362bce42BD6930f861673;\r\n    address public constant OASIS_WRAPPER = 0x6Ab7e1d38B16731cdd0540d2494FeE6d000D451C;\r\n\r\n    address public constant FACTORY_ADDRESS = 0xc72E74E474682680a414b506699bBcA44ab9a930;\r\n    \r\n    address public constant PIP_INTERFACE_ADDRESS = 0xA944bd4b25C9F186A846fd5668941AA3d3B8425F;\r\n    address public constant PROXY_REGISTRY_INTERFACE_ADDRESS = 0x64A436ae831C1672AE81F674CAb8B6775df3475C;\r\n    address public constant GAS_TOKEN_INTERFACE_ADDRESS = 0x0000000000170CcC93903185bE5A2094C870Df62;\r\n    address public constant KYBER_INTERFACE = 0x692f391bCc85cefCe8C237C01e1f636BbD70EA4D;\r\n\r\n    address public constant SAVINGS_LOGGER_ADDRESS = 0xA6E5d5F489b1c00d9C11E1caF45BAb6e6e26443d;\r\n\r\n    \r\n    address public constant UNISWAP_FACTORY = 0xf5D915570BC477f9B8D6C0E980aA81757A3AaC36;\r\n}\r\n\r\ncontract ConstantAddresses is ConstantAddressesMainnet {\r\n}\r\n\r\ncontract Discount {\r\n\r\n    address public owner;\r\n    mapping (address =\u003E CustomServiceFee) public serviceFees;\r\n\r\n    uint constant MAX_SERVICE_FEE = 400;\r\n\r\n    struct CustomServiceFee {\r\n        bool active;\r\n        uint amount;\r\n    }\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    function isCustomFeeSet(address _user) public view returns (bool) {\r\n        return serviceFees[_user].active;\r\n    }\r\n\r\n    function getCustomServiceFee(address _user) public view returns (uint) {\r\n        return serviceFees[_user].amount;\r\n    }\r\n\r\n    function setServiceFee(address _user, uint _fee) public {\r\n        require(msg.sender == owner, \u0022Only owner\u0022);\r\n        require(_fee \u003E= MAX_SERVICE_FEE || _fee == 0);\r\n\r\n        serviceFees[_user] = CustomServiceFee({\r\n            active: true,\r\n            amount: _fee\r\n        });\r\n    }\r\n\r\n    function disableServiceFee(address _user) public {\r\n        require(msg.sender == owner, \u0022Only owner\u0022);\r\n\r\n        serviceFees[_user] = CustomServiceFee({\r\n            active: false,\r\n            amount: 0\r\n        });\r\n    }\r\n}\r\n\r\ncontract SaverExchange is DSMath, ConstantAddresses {\r\n\r\n    uint public constant SERVICE_FEE = 800; \r\n\r\n    event Swap(address src, address dest, uint amountSold, uint amountBought);\r\n\r\n    function swapTokenToToken(address _src, address _dest, uint _amount, uint _minPrice, uint _exchangeType) public payable {\r\n        if (_src == KYBER_ETH_ADDRESS) {\r\n            require(msg.value \u003E= _amount);\r\n            \r\n            msg.sender.transfer(sub(msg.value, _amount));\r\n        } else {\r\n            require(ERC20(_src).transferFrom(msg.sender, address(this), _amount));\r\n        }\r\n\r\n        uint fee = takeFee(_amount, _src);\r\n        _amount = sub(_amount, fee);\r\n\r\n        address wrapper;\r\n        uint price;\r\n        (wrapper, price) = getBestPrice(_amount, _src, _dest, _exchangeType);\r\n\r\n        require(price \u003E _minPrice, \u0022Slippage hit\u0022);\r\n\r\n        uint tokensReturned;\r\n        if (_src == KYBER_ETH_ADDRESS) {\r\n            (tokensReturned,) = ExchangeInterface(wrapper).swapEtherToToken.value(_amount)(_amount, _dest, uint(-1));\r\n        } else {\r\n            ERC20(_src).transfer(wrapper, _amount);\r\n\r\n            if (_dest == KYBER_ETH_ADDRESS) {\r\n                tokensReturned = ExchangeInterface(wrapper).swapTokenToEther(_src, _amount, uint(-1));\r\n            } else {\r\n                tokensReturned = ExchangeInterface(wrapper).swapTokenToToken(_src, _dest, _amount);\r\n            }\r\n        }\r\n\r\n        if (_dest == KYBER_ETH_ADDRESS) {\r\n            msg.sender.transfer(tokensReturned);\r\n        } else {\r\n            ERC20(_dest).transfer(msg.sender, tokensReturned);\r\n        }\r\n\r\n        emit Swap(_src, _dest, _amount, tokensReturned);\r\n    }\r\n\r\n\r\n    \r\n\r\n    function swapDaiToEth(uint _amount, uint _minPrice, uint _exchangeType) public {\r\n        require(ERC20(MAKER_DAI_ADDRESS).transferFrom(msg.sender, address(this), _amount));\r\n\r\n        uint fee = takeFee(_amount, MAKER_DAI_ADDRESS);\r\n        _amount = sub(_amount, fee);\r\n\r\n        address exchangeWrapper;\r\n        uint daiEthPrice;\r\n        (exchangeWrapper, daiEthPrice) = getBestPrice(_amount, MAKER_DAI_ADDRESS, KYBER_ETH_ADDRESS, _exchangeType);\r\n\r\n        require(daiEthPrice \u003E _minPrice, \u0022Slippage hit\u0022);\r\n\r\n        ERC20(MAKER_DAI_ADDRESS).transfer(exchangeWrapper, _amount);\r\n        ExchangeInterface(exchangeWrapper).swapTokenToEther(MAKER_DAI_ADDRESS, _amount, uint(-1));\r\n\r\n        uint daiBalance = ERC20(MAKER_DAI_ADDRESS).balanceOf(address(this));\r\n        if (daiBalance \u003E 0) {\r\n            ERC20(MAKER_DAI_ADDRESS).transfer(msg.sender, daiBalance);\r\n        }\r\n\r\n        msg.sender.transfer(address(this).balance);\r\n    }\r\n\r\n    function swapEthToDai(uint _amount, uint _minPrice, uint _exchangeType) public payable {\r\n        require(msg.value \u003E= _amount);\r\n\r\n        address exchangeWrapper;\r\n        uint ethDaiPrice;\r\n        (exchangeWrapper, ethDaiPrice) = getBestPrice(_amount, KYBER_ETH_ADDRESS, MAKER_DAI_ADDRESS, _exchangeType);\r\n\r\n        require(ethDaiPrice \u003E _minPrice, \u0022Slippage hit\u0022);\r\n\r\n        uint ethReturned;\r\n        uint daiReturned;\r\n        (daiReturned, ethReturned) = ExchangeInterface(exchangeWrapper).swapEtherToToken.value(_amount)(_amount, MAKER_DAI_ADDRESS, uint(-1));\r\n\r\n        uint fee = takeFee(daiReturned, MAKER_DAI_ADDRESS);\r\n        daiReturned = sub(daiReturned, fee);\r\n\r\n        ERC20(MAKER_DAI_ADDRESS).transfer(msg.sender, daiReturned);\r\n\r\n        if (ethReturned \u003E 0) {\r\n            msg.sender.transfer(ethReturned);\r\n        }\r\n    }\r\n\r\n\r\n    \r\n    \r\n    \r\n    \r\n    \r\n    function getBestPrice(uint _amount, address _srcToken, address _destToken, uint _exchangeType) public returns (address, uint) {\r\n        uint expectedRateKyber;\r\n        uint expectedRateUniswap;\r\n        uint expectedRateOasis;\r\n\r\n\r\n        if (_exchangeType == 1) {\r\n            return (OASIS_WRAPPER, getExpectedRate(OASIS_WRAPPER, _srcToken, _destToken, _amount));\r\n        }\r\n\r\n        if (_exchangeType == 2) {\r\n            return (KYBER_WRAPPER, getExpectedRate(KYBER_WRAPPER, _srcToken, _destToken, _amount));\r\n        }\r\n\r\n        if (_exchangeType == 3) {\r\n            expectedRateUniswap = getExpectedRate(UNISWAP_WRAPPER, _srcToken, _destToken, _amount);\r\n            expectedRateUniswap = expectedRateUniswap * (10 ** (18 - getDecimals(_destToken)));\r\n            return (UNISWAP_WRAPPER, expectedRateUniswap);\r\n        }\r\n\r\n        expectedRateKyber = getExpectedRate(KYBER_WRAPPER, _srcToken, _destToken, _amount);\r\n        expectedRateUniswap = getExpectedRate(UNISWAP_WRAPPER, _srcToken, _destToken, _amount);\r\n        expectedRateUniswap = expectedRateUniswap * (10 ** (18 - getDecimals(_destToken)));\r\n        expectedRateOasis = getExpectedRate(OASIS_WRAPPER, _srcToken, _destToken, _amount);\r\n\r\n        if ((expectedRateKyber \u003E= expectedRateUniswap) \u0026\u0026 (expectedRateKyber \u003E= expectedRateOasis)) {\r\n            return (KYBER_WRAPPER, expectedRateKyber);\r\n        }\r\n\r\n        if ((expectedRateOasis \u003E= expectedRateKyber) \u0026\u0026 (expectedRateOasis \u003E= expectedRateUniswap)) {\r\n            return (OASIS_WRAPPER, expectedRateOasis);\r\n        }\r\n\r\n        if ((expectedRateUniswap \u003E= expectedRateKyber) \u0026\u0026 (expectedRateUniswap \u003E= expectedRateOasis)) {\r\n            return (UNISWAP_WRAPPER, expectedRateUniswap);\r\n        }\r\n    }\r\n\r\n    function getExpectedRate(address _wrapper, address _srcToken, address _destToken, uint _amount) public returns(uint) {\r\n        bool success;\r\n        bytes memory result;\r\n\r\n        (success, result) = _wrapper.call(abi.encodeWithSignature(\u0022getExpectedRate(address,address,uint256)\u0022, _srcToken, _destToken, _amount));\r\n\r\n        if (success) {\r\n            return sliceUint(result, 0);\r\n        } else {\r\n            return 0;\r\n        }\r\n    }\r\n\r\n    \r\n    \r\n    \r\n    function takeFee(uint _amount, address _token) internal returns (uint feeAmount) {\r\n        uint fee = SERVICE_FEE;\r\n\r\n        if (Discount(DISCOUNT_ADDRESS).isCustomFeeSet(msg.sender)) {\r\n            fee = Discount(DISCOUNT_ADDRESS).getCustomServiceFee(msg.sender);\r\n        }\r\n\r\n        if (fee == 0) {\r\n            feeAmount = 0;\r\n        } else {\r\n            feeAmount = _amount / SERVICE_FEE;\r\n            if (_token == KYBER_ETH_ADDRESS) {\r\n                WALLET_ID.transfer(feeAmount);\r\n            } else {\r\n                ERC20(_token).transfer(WALLET_ID, feeAmount);\r\n            }\r\n        }\r\n    }\r\n\r\n\r\n    function getDecimals(address _token) internal view returns(uint) {\r\n        \r\n        if (_token == address(0xE0B7927c4aF23765Cb51314A0E0521A9645F0E2A)) {\r\n            return 9;\r\n        }\r\n        \r\n        if (_token == address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)) {\r\n            return 6;\r\n        }\r\n        \r\n        if (_token == address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599)) {\r\n            return 8;\r\n        }\r\n\r\n        return 18;\r\n    }\r\n\r\n    function sliceUint(bytes memory bs, uint start) internal pure returns (uint) {\r\n        require(bs.length \u003E= start \u002B 32, \u0022slicing out of range\u0022);\r\n\r\n        uint x;\r\n        assembly {\r\n            x := mload(add(bs, add(0x20, start)))\r\n        }\r\n\r\n        return x;\r\n    }\r\n\r\n    \r\n    function() external payable {}\r\n}","ABI":"[{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dest\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amountSold\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amountBought\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Swap\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022CDAI_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022COMPOUND_DAI_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DISCOUNT_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022FACTORY_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022GAS_TOKEN_INTERFACE_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022IDAI_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022KYBER_ETH_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022KYBER_INTERFACE\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022KYBER_WRAPPER\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022LOGGER_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MAKER_DAI_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MKR_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022OASIS_WRAPPER\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022OTC_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022PETH_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022PIP_INTERFACE_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022PROXY_REGISTRY_INTERFACE_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SAVINGS_LOGGER_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SERVICE_FEE\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SOLO_MARGIN_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022STUPID_EXCHANGE\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TUB_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022UNISWAP_FACTORY\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022UNISWAP_WRAPPER\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022VOX_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022WALLET_ID\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022WETH_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_srcToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_destToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_exchangeType\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getBestPrice\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_wrapper\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_srcToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_destToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getExpectedRate\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_minPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_exchangeType\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022swapDaiToEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_minPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_exchangeType\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022swapEthToDai\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_dest\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_minPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_exchangeType\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022swapTokenToToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"SaverExchange","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://f296e2f4e5203e1b93713100698a3ae5dfcbb4a188537a8380512eb06a8799c0"}]