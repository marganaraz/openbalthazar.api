[{"SourceCode":"pragma solidity ^0.5.11;\r\n    \r\n    \r\n    interface ERC20 {\r\n        function totalSupply() external view returns (uint supply);\r\n        function balanceOf(address _owner) external view returns (uint balance);\r\n        function transfer(address _to, uint _value) external returns (bool success);\r\n        function transferFrom(address _from, address _to, uint _value) external returns (bool success);\r\n        function approve(address _spender, uint _value) external returns (bool success);\r\n        function allowance(address _owner, address _spender) external view returns (uint remaining);\r\n        function decimals() external view returns(uint digits);\r\n        event Approval(address indexed _owner, address indexed _spender, uint _value);\r\n    }\r\n    \r\n    \r\n    interface KyberReserveIf {\r\n        function getConversionRate(ERC20 src, ERC20 dest, uint srcQty, uint blockNumber) external view returns(uint);\r\n    }\r\n    \r\n    \r\n    contract KyberNetworkIf { \r\n        mapping(address=\u003Eaddress[]) public reservesPerTokenSrc; //reserves supporting token to eth\r\n        mapping(address=\u003Eaddress[]) public reservesPerTokenDest;//reserves support eth to token\r\n    }\r\n    \r\n    \r\n    contract CheckReserveSplit {\r\n        \r\n        ERC20 constant ETH = ERC20(address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE));\r\n        KyberNetworkIf constant kyber = KyberNetworkIf(0x9ae49C0d7F8F9EF4B864e004FE86Ac8294E20950);\r\n        ERC20 constant dai = ERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);\r\n        ERC20 constant usdc = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);\r\n        \r\n        uint public numSplitRateIteration = 11;\r\n        \r\n        mapping(address=\u003Eaddress[]) reservesPerTokenDest;//reserves supporting eth to token\r\n    \r\n        constructor () public {\r\n        }\r\n        \r\n        function setNumSplitRateCalls (uint num) public {\r\n            numSplitRateIteration = num;\r\n        }\r\n        \r\n        function copyReserves(ERC20 token) public {\r\n            \r\n            KyberReserveIf reserve;\r\n            uint index;\r\n            \r\n            while(true) {\r\n                reserve = KyberReserveIf(getReserveTokenDest(address(token), index));\r\n                if (reserve == KyberReserveIf(address(0x0))) break;\r\n                reservesPerTokenDest[address(token)].push(address(reserve));\r\n                index\u002B\u002B;\r\n            }        \r\n        }\r\n    \r\n        function getres1ReservesEthToToken(ERC20 token, uint tradeSizeEth) internal view \r\n            returns(KyberReserveIf res1, KyberReserveIf res2, uint res1Rate, uint res2Rate, uint index) \r\n        {\r\n            KyberReserveIf reserve;\r\n            uint rate;\r\n            index = 0;\r\n         \r\n            uint querySizeEth;\r\n            \r\n            if (tradeSizeEth \u003C 50) {\r\n                querySizeEth = tradeSizeEth;\r\n            } else {\r\n                querySizeEth = tradeSizeEth * 55 / 100;\r\n            }\r\n            \r\n            // fetch resereves find reserve with res1 rate and with 2nd res1.\r\n            for(index = 0; index \u003C reservesPerTokenDest[address(token)].length; index\u002B\u002B) {\r\n            \r\n                reserve = KyberReserveIf(reservesPerTokenDest[address(token)][index]);\r\n                if (reserve == KyberReserveIf(address(0x0))) continue;\r\n                rate = reserve.getConversionRate(ETH, token, querySizeEth * 10 ** 18, block.number);\r\n                \r\n                if(rate \u003E res1Rate) {\r\n                    \r\n                    if (res1Rate \u003E res2Rate) {\r\n                        res2Rate = res1Rate;\r\n                        res2 = res1;\r\n                    }\r\n                    \r\n                    res1Rate = rate;\r\n                    res1 = reserve;\r\n                } else if (rate \u003E res2Rate) {\r\n                    res2Rate = rate;\r\n                    res2 = reserve;\r\n                }\r\n            }\r\n            \r\n            res2Rate = res2.getConversionRate(ETH, token, (tradeSizeEth - querySizeEth) * 10 ** 18, block.number);\r\n        }\r\n    \r\n        function getReserveTokenDest (address token, uint index) \r\n            internal view returns (address reserve) \r\n        {\r\n    \r\n            (bool success, bytes memory returnData) = \r\n                address(kyber).staticcall(\r\n                    abi.encodePacked( // This encodes the function to call and the parameters to pass to that function\r\n                            kyber.reservesPerTokenDest.selector, \r\n                            abi.encode(token, index) \r\n                        )\r\n                    );\r\n            \r\n            if (success) {\r\n                reserve = abi.decode(returnData, (address));\r\n            } else { // transferFrom reverted. However, the complete tx did not revert and we can handle the case here.\r\n                reserve = address(0x0);\r\n            }\r\n        }\r\n    \r\n        function getres1EthToDaiReserves100Eth() public view \r\n            returns(KyberReserveIf res1, KyberReserveIf res2, uint res1Rate, uint res2Rate, uint index) \r\n        {\r\n            return getres1ReservesEthToToken(dai, 100);\r\n        }\r\n        \r\n        function getres1EthToUsdcReserves100Eth() public view \r\n            returns(KyberReserveIf res1, KyberReserveIf res2, uint res1Rate, uint res2Rate, uint index) \r\n        {\r\n            return getres1ReservesEthToToken(usdc, 100);\r\n        }\r\n        \r\n        function getSplitValueEthToToken(ERC20 token, uint tradeSizeEth) internal view \r\n            returns(uint splitValueEth, KyberReserveIf res1, KyberReserveIf res2) \r\n        {\r\n            uint numSplitCalls = numSplitRateIteration;\r\n            \r\n            (res1, res2, , , ) = getres1ReservesEthToToken(token, tradeSizeEth);\r\n             \r\n            // set step size at trade size / 4\r\n            uint stepSizeWei = (tradeSizeEth * 10 ** 18) / 4;\r\n            // set first split value to trade size / 2\r\n            uint splitValueWei = (tradeSizeEth * 10 ** 18) / 2;\r\n            (uint lastSplitRate, , ) = calcCombinedRate(token, res1, res2, splitValueWei, (tradeSizeEth * 10 ** 18));\r\n            uint newSplitRate;\r\n        \r\n            while (numSplitCalls-- \u003E 0) {\r\n                (newSplitRate, , ) = calcCombinedRate(token, res1, res2, (splitValueWei \u002B stepSizeWei), (tradeSizeEth * 10 ** 18));\r\n                \r\n                if (newSplitRate \u003E lastSplitRate) {\r\n                    lastSplitRate = newSplitRate;\r\n                    splitValueWei \u002B= stepSizeWei;\r\n                }\r\n                stepSizeWei /= 2;\r\n            }\r\n            \r\n            splitValueEth = splitValueWei / 10 ** 18;\r\n         }\r\n        \r\n        function compareSplitTrade(ERC20 token, uint tradeValueEth) internal view \r\n            returns(uint rateReserve1, uint rateReserve1and2, uint amountReserve1, uint amountRes1and2, uint splitValueEth, \r\n                KyberReserveIf res1, KyberReserveIf res2, uint rate1OnSplit, uint rate2OnSplit) \r\n        {\r\n            (splitValueEth, res1, res2) = getSplitValueEthToToken(token, tradeValueEth);\r\n            \r\n            rateReserve1 = res1.getConversionRate(ETH, token, tradeValueEth * 10 ** 18, block.number);\r\n            (rateReserve1and2, rate1OnSplit, rate2OnSplit) = \r\n                calcCombinedRate(token, res1, res2, splitValueEth * 10 ** 18, tradeValueEth * 10 ** 18);\r\n            \r\n            amountReserve1 = rateReserve1 * tradeValueEth / 10 ** 18;\r\n            amountRes1and2 = rateReserve1and2 * tradeValueEth / 10 ** 18;\r\n        }\r\n        \r\n        function getDaiSplitTradeGas() public \r\n            returns(uint rateReserve1, uint rateReserve1and2, uint amountReserve1, uint amountRes1and2, uint splitValueEth, \r\n                KyberReserveIf res1, KyberReserveIf res2, uint rate1OnSplit, uint rate2OnSplit) \r\n        {\r\n            return viewSplitTradeEthToDai(120);\r\n        }\r\n        \r\n        function viewSplitTradeEthToDai(uint tradeValueEth) public view \r\n            returns(uint rateReserve1, uint rateReserve1and2, uint amountReserve1, uint amountRes1and2, uint splitValueEth, \r\n                KyberReserveIf res1, KyberReserveIf res2, uint rate1OnSplit, uint rate2OnSplit) \r\n        {\r\n            return compareSplitTrade(dai, tradeValueEth);\r\n        }\r\n        \r\n        function viewSplitTradeEthToUsdc(uint tradeValueEth) public view \r\n            returns(uint rateReserve1, uint rateReserve1and2, uint amountReserve1, uint amountRes1and2, uint splitValueEth, \r\n                KyberReserveIf res1, KyberReserveIf res2, uint rate1OnSplit, uint rate2OnSplit) \r\n        {\r\n            return compareSplitTrade(usdc, tradeValueEth);\r\n        }\r\n        \r\n        function calcCombinedRate(ERC20 token, KyberReserveIf res1, KyberReserveIf res2, uint splitValueWei, uint tradeValueWei)\r\n            internal view returns(uint combinedRate, uint rate1OnSplit, uint rate2OnSplit)\r\n        {\r\n            rate1OnSplit = res1.getConversionRate(ETH, token, splitValueWei, block.number);\r\n            rate2OnSplit = res2.getConversionRate(ETH, token, (tradeValueWei - splitValueWei), block.number);\r\n            combinedRate = (rate1OnSplit * splitValueWei \u002B rate2OnSplit * (tradeValueWei - splitValueWei)) / tradeValueWei;\r\n        }\r\n    }","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tradeValueEth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022viewSplitTradeEthToDai\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rateReserve1\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rateReserve1and2\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amountReserve1\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amountRes1and2\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022splitValueEth\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022res1\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022res2\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rate1OnSplit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rate2OnSplit\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022num\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setNumSplitRateCalls\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tradeValueEth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022viewSplitTradeEthToUsdc\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rateReserve1\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rateReserve1and2\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amountReserve1\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amountRes1and2\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022splitValueEth\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022res1\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022res2\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rate1OnSplit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rate2OnSplit\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getDaiSplitTradeGas\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rateReserve1\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rateReserve1and2\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amountReserve1\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amountRes1and2\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022splitValueEth\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022res1\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022res2\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rate1OnSplit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rate2OnSplit\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022numSplitRateIteration\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getres1EthToDaiReserves100Eth\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022res1\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022res2\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022res1Rate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022res2Rate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getres1EthToUsdcReserves100Eth\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022res1\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022contract KyberReserveIf\u0022,\u0022name\u0022:\u0022res2\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022res1Rate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022res2Rate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract ERC20\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022copyReserves\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"CheckReserveSplit","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://4f3f08a3b432044ff63e5303ebcb12fe7fa3e6fae33f21ed2db75992c85985a3"}]