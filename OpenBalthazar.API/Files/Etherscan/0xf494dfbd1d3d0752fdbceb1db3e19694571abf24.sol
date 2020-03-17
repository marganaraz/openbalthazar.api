[{"SourceCode":"pragma solidity ^0.5.8;\r\n\r\ninterface TokenInterface {\r\n    function allowance(address, address) external view returns (uint);\r\n    function balanceOf(address) external view returns (uint);\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external returns (bool);\r\n    function transferFrom(address, address, uint) external returns (bool);\r\n    function deposit() external payable;\r\n    function withdraw(uint) external;\r\n}\r\n\r\ninterface UniswapExchange {\r\n    function getEthToTokenInputPrice(uint ethSold) external view returns (uint tokenBought);\r\n    function getTokenToEthInputPrice(uint tokenSold) external view returns (uint ethBought);\r\n    function ethToTokenSwapInput(uint minTokens, uint deadline) external payable returns (uint tokenBought);\r\n    function tokenToEthSwapInput(uint tokenSold, uint minEth, uint deadline) external returns (uint ethBought);\r\n}\r\n\r\ninterface KyberInterface {\r\n    function trade(\r\n        address src,\r\n        uint srcAmount,\r\n        address dest,\r\n        address destAddress,\r\n        uint maxDestAmount,\r\n        uint minConversionRate,\r\n        address walletId\r\n        ) external payable returns (uint);\r\n\r\n    function getExpectedRate(\r\n        address src,\r\n        address dest,\r\n        uint srcQty\r\n        ) external view returns (uint, uint);\r\n}\r\n\r\ninterface Eth2DaiInterface {\r\n    function getBuyAmount(address dest, address src, uint srcAmt) external view returns(uint);\r\n\tfunction getPayAmount(address src, address dest, uint destAmt) external view returns (uint);\r\n\tfunction sellAllAmount(\r\n        address src,\r\n        uint srcAmt,\r\n        address dest,\r\n        uint minDest\r\n    ) external returns (uint destAmt);\r\n\tfunction buyAllAmount(\r\n        address dest,\r\n        uint destAmt,\r\n        address src,\r\n        uint maxSrc\r\n    ) external returns (uint srcAmt);\r\n}\r\n\r\n\r\ncontract DSMath {\r\n\r\n    function add(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x \u002B y) \u003E= x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    function sub(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x - y) \u003C= x, \u0022ds-math-sub-underflow\u0022);\r\n    }\r\n\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    uint constant WAD = 10 ** 18;\r\n    uint constant RAY = 10 ** 27;\r\n\r\n    function rmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), RAY / 2) / RAY;\r\n    }\r\n\r\n    function rdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, RAY), y / 2) / y;\r\n    }\r\n\r\n    function wmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), WAD / 2) / WAD;\r\n    }\r\n\r\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, WAD), y / 2) / y;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract Helper is DSMath {\r\n\r\n    address public eth2daiAddr = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e;\r\n    address public uniswapAddr = 0x2a1530C4C41db0B0b2bB646CB5Eb1A67b7158667; // Uniswap DAI exchange\r\n    address public kyberAddr = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;\r\n    address public ethAddr = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\r\n    address public wethAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;\r\n    address public daiAddr = 0x6B175474E89094C44Da98b954EedeAC495271d0F;\r\n    address public adminOne = 0xa7615CD307F323172331865181DC8b80a2834324;\r\n    // address public adminTwo = 0x7284a8451d9a0e7Dc62B3a71C0593eA2eC5c5638;\r\n    address public adminTwo = 0xe866ecE4bbD0Ac75577225Ee2C464ef16DC8b1F3;\r\n    uint public maxSplitAmtEth = 60000000000000000000;\r\n    uint public maxSplitAmtDai = 20000000000000000000000;\r\n    uint public cut = 1000000000000000000; // 0% charge\r\n    uint public minDai = 200000000000000000000; // DAI \u003C 200 swap with Kyber or Uniswap\r\n    uint public minEth = 1000000000000000000; // ETH \u003C 1 swap with Kyber or Uniswap\r\n\r\n    function setAllowance(TokenInterface _token, address _spender) internal {\r\n        if (_token.allowance(address(this), _spender) != uint(-1)) {\r\n            _token.approve(_spender, uint(-1));\r\n        }\r\n    }\r\n\r\n    modifier isAdmin {\r\n        require(msg.sender == adminOne || msg.sender == adminTwo, \u0022Not an Admin\u0022);\r\n        _;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract AdminStuffs is Helper {\r\n\r\n    function setSplitEth(uint amt) public isAdmin {\r\n        maxSplitAmtEth = amt;\r\n    }\r\n\r\n    function setSplitDai(uint amt) public isAdmin {\r\n        maxSplitAmtDai = amt;\r\n    }\r\n\r\n    function withdrawToken(address token) public isAdmin {\r\n        uint daiBal = TokenInterface(token).balanceOf(address(this));\r\n        TokenInterface(token).transfer(msg.sender, daiBal);\r\n    }\r\n\r\n    function withdrawEth() public payable isAdmin {\r\n        msg.sender.transfer(address(this).balance);\r\n    }\r\n\r\n    function changeFee(uint amt) public isAdmin {\r\n        if (amt \u003C 997000000000000000) {\r\n            cut = 997000000000000000; // maximum fees can be 0.3%. Minimum 0%\r\n        } else {\r\n            cut = amt;\r\n        }\r\n    }\r\n\r\n    function changeMinEth(uint amt) public isAdmin {\r\n        minEth = amt;\r\n    }\r\n\r\n    function changeMinDai(uint amt) public isAdmin {\r\n        minDai = amt;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract SplitHelper is AdminStuffs {\r\n\r\n    function getBest(address src, address dest, uint srcAmt) public view returns (uint bestExchange, uint destAmt) {\r\n        uint finalSrcAmt = srcAmt;\r\n        if (src == daiAddr) {\r\n            finalSrcAmt = wmul(srcAmt, cut);\r\n        }\r\n        uint eth2DaiPrice = getRateEth2Dai(src, dest, finalSrcAmt);\r\n        uint kyberPrice = getRateKyber(src, dest, finalSrcAmt);\r\n        uint uniswapPrice = getRateUniswap(src, dest, finalSrcAmt);\r\n        if (eth2DaiPrice \u003E kyberPrice \u0026\u0026 eth2DaiPrice \u003E uniswapPrice) {\r\n            destAmt = eth2DaiPrice;\r\n            bestExchange = 0;\r\n        } else if (kyberPrice \u003E eth2DaiPrice \u0026\u0026 kyberPrice \u003E uniswapPrice) {\r\n            destAmt = kyberPrice;\r\n            bestExchange = 1;\r\n        } else {\r\n            destAmt = uniswapPrice;\r\n            bestExchange = 2;\r\n        }\r\n        if (dest == daiAddr) {\r\n            destAmt = wmul(destAmt, cut);\r\n        }\r\n        require(destAmt != 0, \u0022Dest Amt = 0\u0022);\r\n    }\r\n\r\n    function getBestUniswapKyber(address src, address dest, uint srcAmt) public view returns (uint bestExchange, uint destAmt) {\r\n        uint finalSrcAmt = srcAmt;\r\n        if (src == daiAddr) {\r\n            finalSrcAmt = wmul(srcAmt, cut);\r\n        }\r\n        uint kyberPrice = getRateKyber(src, dest, finalSrcAmt);\r\n        uint uniswapPrice = getRateUniswap(src, dest, finalSrcAmt);\r\n        if (kyberPrice \u003E= uniswapPrice) {\r\n            destAmt = kyberPrice;\r\n            bestExchange = 1;\r\n        } else {\r\n            destAmt = uniswapPrice;\r\n            bestExchange = 2;\r\n        }\r\n        if (dest == daiAddr) {\r\n            destAmt = wmul(destAmt, cut);\r\n        }\r\n        require(destAmt != 0, \u0022Dest Amt = 0\u0022);\r\n    }\r\n\r\n    function getRateEth2Dai(address src, address dest, uint srcAmt) internal view returns (uint destAmt) {\r\n        if (src == ethAddr) {\r\n            destAmt = Eth2DaiInterface(eth2daiAddr).getBuyAmount(dest, wethAddr, srcAmt);\r\n        } else if (dest == ethAddr) {\r\n            destAmt = Eth2DaiInterface(eth2daiAddr).getBuyAmount(wethAddr, src, srcAmt);\r\n        }\r\n    }\r\n\r\n    function getRateKyber(address src, address dest, uint srcAmt) internal view returns (uint destAmt) {\r\n        (uint kyberPrice,) = KyberInterface(kyberAddr).getExpectedRate(src, dest, srcAmt);\r\n        destAmt = wmul(srcAmt, kyberPrice);\r\n    }\r\n\r\n    function getRateUniswap(address src, address dest, uint srcAmt) internal view returns (uint destAmt) {\r\n        if (src == ethAddr) {\r\n            destAmt = UniswapExchange(uniswapAddr).getEthToTokenInputPrice(srcAmt);\r\n        } else if (dest == ethAddr) {\r\n            destAmt = UniswapExchange(uniswapAddr).getTokenToEthInputPrice(srcAmt);\r\n        }\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract SplitResolver is SplitHelper {\r\n\r\n    event LogEthToDai(address user, uint srcAmt, uint destAmt);\r\n    event LogDaiToEth(address user, uint srcAmt, uint destAmt);\r\n\r\n    function swapEth2Dai(address src, address dest, uint srcAmt) internal returns (uint destAmt) {\r\n        if (src == wethAddr) {\r\n            TokenInterface(wethAddr).deposit.value(srcAmt)();\r\n        }\r\n        destAmt = Eth2DaiInterface(eth2daiAddr).sellAllAmount(\r\n                src,\r\n                srcAmt,\r\n                dest,\r\n                0\r\n            );\r\n    }\r\n\r\n    function swapKyber(address src, address dest, uint srcAmt) internal returns (uint destAmt) {\r\n        uint ethAmt = src == ethAddr ? srcAmt : 0;\r\n        destAmt = KyberInterface(kyberAddr).trade.value(ethAmt)(\r\n                src,\r\n                srcAmt,\r\n                dest,\r\n                address(this),\r\n                2**255,\r\n                0,\r\n                adminOne\r\n            );\r\n    }\r\n\r\n    function swapUniswap(address src, address dest, uint srcAmt) internal returns (uint destAmt) {\r\n        if (src == ethAddr) {\r\n            destAmt = UniswapExchange(uniswapAddr).ethToTokenSwapInput.value(srcAmt)(1, block.timestamp \u002B 1);\r\n        } else if (dest == ethAddr) {\r\n            destAmt = UniswapExchange(uniswapAddr).tokenToEthSwapInput(srcAmt, 1, block.timestamp \u002B 1);\r\n        }\r\n    }\r\n\r\n    function ethToDaiBestSwap(uint bestExchange, uint amtToSwap) internal returns (uint destAmt) {\r\n        if (bestExchange == 0) {\r\n            destAmt \u002B= swapEth2Dai(wethAddr, daiAddr, amtToSwap);\r\n        } else if (bestExchange == 1) {\r\n            destAmt \u002B= swapKyber(ethAddr, daiAddr, amtToSwap);\r\n        } else {\r\n            destAmt \u002B= swapUniswap(ethAddr, daiAddr, amtToSwap);\r\n        }\r\n    }\r\n\r\n    function ethToDaiLoop(uint srcAmt, uint splitAmt, uint finalAmt) internal returns (uint destAmt) {\r\n        if (srcAmt \u003E splitAmt) {\r\n            uint amtToSwap = splitAmt;\r\n            uint nextSrcAmt = srcAmt - splitAmt;\r\n            (uint bestExchange,) = getBest(ethAddr, daiAddr, amtToSwap);\r\n            uint daiBought = finalAmt;\r\n            daiBought \u002B= ethToDaiBestSwap(bestExchange, amtToSwap);\r\n            destAmt = ethToDaiLoop(nextSrcAmt, splitAmt, daiBought);\r\n        } else if (srcAmt \u003E minEth) {\r\n            (uint bestExchange,) = getBest(ethAddr, daiAddr, srcAmt);\r\n            destAmt = finalAmt;\r\n            destAmt \u002B= ethToDaiBestSwap(bestExchange, srcAmt);\r\n        } else if (srcAmt \u003E 0) {\r\n            (uint bestExchange,) = getBestUniswapKyber(ethAddr, daiAddr, srcAmt);\r\n            destAmt = finalAmt;\r\n            destAmt \u002B= ethToDaiBestSwap(bestExchange, srcAmt);\r\n        } else {\r\n            destAmt = finalAmt;\r\n        }\r\n    }\r\n\r\n    function daiToEthBestSwap(uint bestExchange, uint amtToSwap) internal returns (uint destAmt) {\r\n        if (bestExchange == 0) {\r\n            destAmt \u002B= swapEth2Dai(daiAddr, wethAddr, amtToSwap);\r\n        } else if (bestExchange == 1) {\r\n            destAmt \u002B= swapKyber(daiAddr, ethAddr, amtToSwap);\r\n        } else {\r\n            destAmt \u002B= swapUniswap(daiAddr, ethAddr, amtToSwap);\r\n        }\r\n    }\r\n\r\n    function daiToEthLoop(uint srcAmt, uint splitAmt, uint finalAmt) internal returns (uint destAmt) {\r\n        if (srcAmt \u003E splitAmt) {\r\n            uint amtToSwap = splitAmt;\r\n            uint nextSrcAmt = srcAmt - splitAmt;\r\n            (uint bestExchange,) = getBest(daiAddr, ethAddr, amtToSwap);\r\n            uint ethBought = finalAmt;\r\n            ethBought \u002B= daiToEthBestSwap(bestExchange, amtToSwap);\r\n            destAmt = daiToEthLoop(nextSrcAmt, splitAmt, ethBought);\r\n        } else if (srcAmt \u003E minDai) {\r\n            (uint bestExchange,) = getBest(daiAddr, ethAddr, srcAmt);\r\n            destAmt = finalAmt;\r\n            destAmt \u002B= daiToEthBestSwap(bestExchange, srcAmt);\r\n        } else if (srcAmt \u003E 0) {\r\n            (uint bestExchange,) = getBestUniswapKyber(daiAddr, ethAddr, srcAmt);\r\n            destAmt = finalAmt;\r\n            destAmt \u002B= daiToEthBestSwap(bestExchange, srcAmt);\r\n        } else {\r\n            destAmt = finalAmt;\r\n        }\r\n    }\r\n\r\n    function wethToEth() internal {\r\n        TokenInterface wethContract = TokenInterface(wethAddr);\r\n        uint balanceWeth = wethContract.balanceOf(address(this));\r\n        if (balanceWeth \u003E 0) {\r\n            wethContract.withdraw(balanceWeth);\r\n        }\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract Swap is SplitResolver {\r\n\r\n    function ethToDaiSwap(uint splitAmt, uint slippageAmt) public payable returns (uint destAmt) { // srcAmt = msg.value\r\n        require(maxSplitAmtEth \u003E= splitAmt, \u0022split amt \u003E max\u0022);\r\n        destAmt = ethToDaiLoop(msg.value, splitAmt, 0);\r\n        destAmt = wmul(destAmt, cut);\r\n        require(destAmt \u003E slippageAmt, \u0022Dest Amt \u003C slippage\u0022);\r\n        require(TokenInterface(daiAddr).transfer(msg.sender, destAmt), \u0022Not enough DAI to transfer\u0022);\r\n        emit LogEthToDai(msg.sender, msg.value, destAmt);\r\n    }\r\n\r\n    function daiToEthSwap(uint srcAmt, uint splitAmt, uint slippageAmt) public returns (uint destAmt) {\r\n        require(maxSplitAmtDai \u003E= splitAmt, \u0022split amt \u003E max\u0022);\r\n        require(TokenInterface(daiAddr).transferFrom(msg.sender, address(this), srcAmt), \u0022Token Approved?\u0022);\r\n        uint finalSrcAmt = wmul(srcAmt, cut);\r\n        destAmt = daiToEthLoop(finalSrcAmt, splitAmt, 0);\r\n        wethToEth();\r\n        require(destAmt \u003E slippageAmt, \u0022Dest Amt \u003C slippage\u0022);\r\n        msg.sender.transfer(destAmt);\r\n        emit LogDaiToEth(msg.sender, finalSrcAmt, destAmt);\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract SplitSwap is Swap {\r\n\r\n    constructor() public {\r\n        setAllowance(TokenInterface(daiAddr), eth2daiAddr);\r\n        setAllowance(TokenInterface(daiAddr), kyberAddr);\r\n        setAllowance(TokenInterface(daiAddr), uniswapAddr);\r\n        setAllowance(TokenInterface(wethAddr), eth2daiAddr);\r\n        setAllowance(TokenInterface(wethAddr), wethAddr);\r\n    }\r\n\r\n    function() external payable {}\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022uniswapAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022eth2daiAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022adminTwo\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022splitAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022slippageAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ethToDaiSwap\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022destAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setSplitDai\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022changeMinEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022minDai\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022changeFee\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022dest\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022srcAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getBest\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022bestExchange\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022destAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022daiAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022maxSplitAmtEth\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022wethAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022withdrawToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022srcAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022splitAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022slippageAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022daiToEthSwap\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022destAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022kyberAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setSplitEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022dest\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022srcAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getBestUniswapKyber\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022bestExchange\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022destAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ethAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022adminOne\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022cut\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022minEth\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022maxSplitAmtDai\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022changeMinDai\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022srcAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022destAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogEthToDai\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022srcAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022destAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogDaiToEth\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"SplitSwap","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://251c6acc6e29af9cef0a19f21ac3d61bf8b663e6135e60ac858c2b6085a79239"}]