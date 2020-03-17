[{"SourceCode":"pragma solidity ^0.5.11;\r\n\r\n\r\ninterface ERC20 {\r\n    function totalSupply() external view returns (uint supply);\r\n    function balanceOf(address _owner) external view returns (uint balance);\r\n    function transfer(address _to, uint _value) external returns (bool success);\r\n    function transferFrom(address _from, address _to, uint _value) external returns (bool success);\r\n    function approve(address _spender, uint _value) external returns (bool success);\r\n    function allowance(address _owner, address _spender) external view returns (uint remaining);\r\n    function decimals() external view returns(uint digits);\r\n    event Approval(address indexed _owner, address indexed _spender, uint _value);\r\n}\r\n\r\n\r\ninterface KyberReserveIf {\r\n    function getConversionRate(ERC20 src, ERC20 dest, uint srcQty, uint blockNumber) external view returns(uint);\r\n}\r\n\r\n\r\ncontract KyberNetworkIf { \r\n    mapping(address=\u003Eaddress[]) public reservesPerTokenSrc; //reserves supporting token to eth\r\n    mapping(address=\u003Eaddress[]) public reservesPerTokenDest;//reserves support eth to token\r\n}\r\n\r\n\r\ncontract CheckReserveSplit {\r\n    \r\n    ERC20 constant ETH = ERC20(address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE));\r\n    KyberNetworkIf constant kyber = KyberNetworkIf(0x9ae49C0d7F8F9EF4B864e004FE86Ac8294E20950);\r\n    ERC20 constant dai = ERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);\r\n    ERC20 constant usdc = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);\r\n    \r\n    uint public numSplitRateIteration = 9;\r\n    \r\n    mapping(address=\u003Eaddress[]) reservesPerTokenDest;//reserves supporting eth to token\r\n\r\n    constructor () public {\r\n    }\r\n    \r\n    function setNumSplitRateCalls (uint num) public {\r\n        numSplitRateIteration = num;\r\n    }\r\n    \r\n    function copyReserves(ERC20 token) public {\r\n        \r\n        KyberReserveIf reserve;\r\n        uint index;\r\n        \r\n        while(true) {\r\n            reserve = KyberReserveIf(getReserveTokenDest(address(token), index));\r\n            if (reserve == KyberReserveIf(address(0x0))) break;\r\n            reservesPerTokenDest[address(token)].push(address(reserve));\r\n            index\u002B\u002B;\r\n        }        \r\n    }\r\n\r\n    function getBestReservesEthToToken(ERC20 token, uint tradeSizeEth) internal view \r\n        returns(KyberReserveIf best, KyberReserveIf second, uint bestRate, uint secondRate, uint index) \r\n    {\r\n        KyberReserveIf reserve;\r\n        uint rate;\r\n        index = 0;\r\n     \r\n        uint querySizeEth = tradeSizeEth * 55 / 100;\r\n        \r\n        // fetch resereves find reserve with best rate and with 2nd best.\r\n        for(uint i = 0; i \u003C reservesPerTokenDest[address(token)].length; i\u002B\u002B) {\r\n        \r\n            reserve = KyberReserveIf(reservesPerTokenDest[address(token)][i]);\r\n            if (reserve == KyberReserveIf(address(0x0))) continue;\r\n            rate = reserve.getConversionRate(ETH, token, querySizeEth * 10 ** 18, block.number);\r\n            \r\n            if(rate \u003E bestRate) {\r\n                \r\n                if (bestRate \u003E secondRate) {\r\n                    secondRate = bestRate;\r\n                    second = best;\r\n                }\r\n                \r\n                bestRate = rate;\r\n                best = reserve;\r\n            } else if (rate \u003E secondRate) {\r\n                secondRate = rate;\r\n                second = reserve;\r\n            }\r\n        }\r\n        \r\n        secondRate = second.getConversionRate(ETH, token, (tradeSizeEth - querySizeEth) * 10 ** 18, block.number);\r\n    }\r\n\r\n    function getReserveTokenDest (address token, uint index) \r\n        internal view returns (address reserve) \r\n    {\r\n\r\n        (bool success, bytes memory returnData) = \r\n            address(kyber).staticcall(\r\n                abi.encodePacked( // This encodes the function to call and the parameters to pass to that function\r\n                        kyber.reservesPerTokenDest.selector, \r\n                        abi.encode(token, index) \r\n                    )\r\n                );\r\n        \r\n        if (success) {\r\n            reserve = abi.decode(returnData, (address));\r\n        } else { // transferFrom reverted. However, the complete tx did not revert and we can handle the case here.\r\n            reserve = address(0x0);\r\n        }\r\n    }\r\n\r\n    function getBestEthToDaiReserves10Eth() public view \r\n        returns(KyberReserveIf best, KyberReserveIf second, uint bestRate, uint secondRate, uint index) \r\n    {\r\n        return getBestReservesEthToToken(dai, 10);\r\n    }\r\n    \r\n    function getBestEthToUsdcReserves10Eth() public view \r\n        returns(KyberReserveIf best, KyberReserveIf second, uint bestRate, uint secondRate, uint index) \r\n    {\r\n        return getBestReservesEthToToken(usdc, 10);\r\n    }\r\n    \r\n    // which eth trade value 2nd best reserve has better rate then best reserve\r\n    function getSplitThresholdEthToToken(ERC20 token, uint tradeSizeEth) internal view \r\n        returns(uint splitThresholdEth, KyberReserveIf best, KyberReserveIf second, uint rateBest, uint rate2nd) \r\n    {\r\n        uint splitRate;\r\n        (best, second, rateBest, rate2nd, ) = getBestReservesEthToToken(token, tradeSizeEth);\r\n        (uint stepSizeWei, uint splitThresholdWei) = getBasicStepSizes(token, tradeSizeEth);\r\n        \r\n        uint numSplitCalls = numSplitRateIteration;\r\n\r\n        // get as near as possible to split threshold\r\n        while (numSplitCalls-- \u003E 0) {\r\n            splitRate = best.getConversionRate(ETH, token, splitThresholdWei, block.number);\r\n            stepSizeWei /= 2;\r\n    \r\n            if (splitRate \u003E rate2nd) {\r\n                splitThresholdWei \u002B= stepSizeWei;\r\n            }\r\n        }\r\n        \r\n        splitThresholdEth = splitThresholdWei / 10 ** 18;\r\n    }\r\n    \r\n    function getSplitValueEthToToken(ERC20 token, uint tradeSizeEth) internal view \r\n        returns(uint splitValueEth, uint splitThresholdEth, KyberReserveIf best, KyberReserveIf second) \r\n    {\r\n        \r\n        (splitThresholdEth, best, second, , )  = getSplitThresholdEthToToken(token, tradeSizeEth);\r\n        \r\n        if (tradeSizeEth \u003C splitThresholdEth) return (0, splitThresholdEth, best, second);\r\n        \r\n        uint stepSizeWei = (tradeSizeEth - splitThresholdEth) * 10 ** 18 / 2;\r\n        \r\n        uint numSplitCalls = numSplitRateIteration;\r\n        \r\n        uint lastSplitRate = calcCombinedRate(token, best, second, splitThresholdEth * 10 ** 18, tradeSizeEth * 10 ** 18);\r\n        uint splitValueWei = splitThresholdEth * 10 ** 18 \u002B stepSizeWei;\r\n        uint newSplitRate;\r\n    \r\n        while (numSplitCalls-- \u003E 0) {\r\n            newSplitRate = calcCombinedRate(token, best, second, splitValueWei, tradeSizeEth * 10 ** 18);\r\n            stepSizeWei /= 2;\r\n            \r\n            if (newSplitRate \u003E lastSplitRate) {\r\n                lastSplitRate = newSplitRate;\r\n                splitValueWei \u002B= stepSizeWei;\r\n            }\r\n        }\r\n        \r\n        splitValueEth = splitValueWei / 10 ** 18;\r\n    }\r\n    \r\n    function getBasicStepSizes (ERC20 token, uint tradeSizeEth) internal pure returns(uint stepSizeWei, uint initialSplitValueEthWei) {\r\n        uint minSplitValueEth = 5;\r\n        uint maxSplitValueEth = tradeSizeEth;\r\n        token;\r\n        \r\n        stepSizeWei = (maxSplitValueEth - minSplitValueEth) * 10 ** 18 / 2;\r\n        initialSplitValueEthWei = minSplitValueEth * 10 ** 18 \u002B stepSizeWei;\r\n    }\r\n\r\n    function getDaiSplitThreshold50Eth() public view returns (uint splitThresholdEth) {\r\n        (splitThresholdEth, , , ,) = getSplitThresholdEthToToken(dai, 50);\r\n    }\r\n   \r\n    function getDaiSplitValues(uint tradeSizeEth) public view \r\n        returns (KyberReserveIf bestReserve, uint bestRate, KyberReserveIf secondBest, uint secondRate, uint splitThresholdEth, uint splitValueEth, uint rateBestAfterSplitValue) \r\n    {\r\n        (splitValueEth, splitThresholdEth, bestReserve, secondBest) = getSplitValueEthToToken(dai, tradeSizeEth);\r\n        bestRate = bestReserve.getConversionRate(ETH, dai, 1 ether, block.number);\r\n        secondRate = secondBest.getConversionRate(ETH, dai, 1 ether, block.number);\r\n        rateBestAfterSplitValue = bestReserve.getConversionRate(ETH, dai, (splitValueEth \u002B 1) * 10 ** 18, block.number);\r\n    }\r\n    \r\n    function getUsdcSplitThreshold50Eth() public view returns (uint splitThresholdEth) {\r\n        (splitThresholdEth, , , ,) = getSplitThresholdEthToToken(usdc, 50);\r\n    }\r\n    \r\n    function getUsdcSplitValues(uint tradeSizeEth) public view \r\n        returns (KyberReserveIf bestReserve, uint rate1, KyberReserveIf secondBest, uint rate2, uint splitThresholdEth, uint splitValueEth, uint rateBestAfterSplitValue) \r\n    {\r\n        (splitValueEth, splitThresholdEth, bestReserve, secondBest) = getSplitValueEthToToken(usdc, tradeSizeEth);\r\n        rate1 = bestReserve.getConversionRate(ETH, usdc, 1 ether, block.number);\r\n        rate2 = secondBest.getConversionRate(ETH, usdc, 1 ether, block.number);\r\n        rateBestAfterSplitValue = bestReserve.getConversionRate(ETH, usdc, (splitValueEth \u002B 1) *10 ** 18, block.number);\r\n    }\r\n    \r\n    function compareSplitTrade(ERC20 token, uint tradeValueEth) internal view \r\n        returns(uint rateSingleReserve, uint rateTwoReserves, uint amountSingleReserve, uint amountTwoRes, uint splitValueEth, uint splitThresholdEth) \r\n    {\r\n        KyberReserveIf reserveBest;\r\n        KyberReserveIf reseve2nd;\r\n        \r\n        (splitValueEth, splitThresholdEth, reserveBest, reseve2nd) = getSplitValueEthToToken(token, tradeValueEth);\r\n        if (splitValueEth \u003E tradeValueEth) return(0, 0, 0, 0, splitValueEth, splitThresholdEth);\r\n        \r\n        rateSingleReserve = reserveBest.getConversionRate(ETH, token, splitValueEth * 10 ** 18, block.number);\r\n        rateTwoReserves = calcCombinedRate(token, reserveBest, reseve2nd, splitValueEth, tradeValueEth);\r\n        \r\n        amountSingleReserve = (rateSingleReserve / 10 ** 18) * tradeValueEth;\r\n        amountTwoRes = (rateTwoReserves / 10 ** 18) * tradeValueEth;\r\n    }\r\n    \r\n    function getDaiSplitValueGas() public \r\n        returns (KyberReserveIf bestReserve, uint bestRate, KyberReserveIf secondBest, uint secondRate, uint splitThresholdEth, uint splitValueEth, uint rateBestAfterSplitValue) \r\n    {\r\n        return getDaiSplitValues(120);\r\n    }\r\n    \r\n    function viewSplitTradeEthToDai(uint tradeValueEth)\r\n        public view \r\n        returns(uint rateSingleReserve, uint rateTwoReserves, uint amountSingleReserve, uint amountTwoRes, uint splitValueEth, uint splitThresholdEth) \r\n    {\r\n        return compareSplitTrade(dai, tradeValueEth);\r\n    }\r\n    \r\n    function viewSplitTradeEthToUsdc(uint tradeValueEth)\r\n        public view \r\n        returns(uint rateSingleReserve, uint rateTwoReserves, uint amountSingleReserve, uint amountTwoRes, uint splitValueEth, uint splitThresholdEth) \r\n    {\r\n        return compareSplitTrade(usdc, tradeValueEth);\r\n    }\r\n    \r\n    function calcCombinedRate(ERC20 token, KyberReserveIf best, KyberReserveIf second, uint splitValueWei, uint tradeValueWei)\r\n        internal view returns(uint rate)\r\n    {\r\n        uint rate1 = best.getConversionRate(ETH, token, splitValueWei, block.number);\r\n        uint rate2 = second.getConversionRate(ETH, token, (tradeValueWei - splitValueWei), block.number);\r\n        rate = (rate1 * splitValueWei \u002B rate2 * (tradeValueWei - splitValueWei)) / tradeValueWei;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tradeValueEth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022viewSplitTradeEthToDai\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rateSingleReserve\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rateTwoReserves\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amountSingleReserve\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amountTwoRes\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022splitValueEth\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022splitThresholdEth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022num\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setNumSplitRateCalls\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tradeValueEth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022viewSplitTradeEthToUsdc\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rateSingleReserve\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rateTwoReserves\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amountSingleReserve\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amountTwoRes\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022splitValueEth\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022splitThresholdEth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022numSplitRateIteration\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tradeSizeEth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getUsdcSplitValues\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022bestReserve\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rate1\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022secondBest\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rate2\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022splitThresholdEth\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022splitValueEth\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rateBestAfterSplitValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getUsdcSplitThreshold50Eth\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022splitThresholdEth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getBestEthToUsdcReserves10Eth\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022best\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022second\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022bestRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022secondRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getDaiSplitThreshold50Eth\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022splitThresholdEth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getBestEthToDaiReserves10Eth\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022best\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022second\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022bestRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022secondRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tradeSizeEth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getDaiSplitValues\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022bestReserve\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022bestRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022secondBest\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022secondRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022splitThresholdEth\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022splitValueEth\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rateBestAfterSplitValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getDaiSplitValueGas\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022bestReserve\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022bestRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022secondBest\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022secondRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022splitThresholdEth\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022splitValueEth\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rateBestAfterSplitValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract ERC20\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022copyReserves\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"CheckReserveSplit","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://caf61cfedf74483b7b687d1bff1d1209aa4ccd44b346fca151097f2848aade02"}]