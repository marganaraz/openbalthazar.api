[{"SourceCode":"pragma solidity ^0.5.9;\r\n\r\n\r\ninterface ERC20 {\r\n    function totalSupply() external view returns (uint supply);\r\n    function balanceOf(address _owner) external view returns (uint balance);\r\n    function transfer(address _to, uint _value) external returns (bool success);\r\n    function transferFrom(address _from, address _to, uint _value) external returns (bool success);\r\n    function approve(address _spender, uint _value) external returns (bool success);\r\n    function allowance(address _owner, address _spender) external view returns (uint remaining);\r\n    function decimals() external view returns(uint digits);\r\n    event Approval(address indexed _owner, address indexed _spender, uint _value);\r\n}\r\n\r\n\r\ncontract OtcInterface {\r\n    function getOffer(uint id) external view returns (uint, ERC20, uint, ERC20);\r\n    function getBestOffer(ERC20 sellGem, ERC20 buyGem) external view returns(uint);\r\n    function getWorseOffer(uint id) external view returns(uint);\r\n    function take(bytes32 id, uint128 maxTakeAmount) external;\r\n}\r\n\r\n\r\ncontract WethInterface is ERC20 {\r\n    function deposit() public payable;\r\n    function withdraw(uint) public;\r\n}\r\n\r\n\r\ncontract ShowEth2DAI {\r\n     // constants\r\n    uint constant BASE_TAKE_OFFERS = 2;\r\n    uint constant BASE_TRAVERSE_OFFERS = 6;\r\n    uint constant MIN_TAKE_AMOUNT_DAI = 30;\r\n    uint constant TAKE_DAI_INCREASE = 5;\r\n    uint  constant internal MAX_QTY   = (10**28); // 10B tokens\r\n    uint constant MAX_TAKE_ORDERS = 8;\r\n    uint constant MAX_TRAVERSE_ORDERS = 20;\r\n    uint constant MIN_TAKE_SIZE_DAI = 35; // ~ $35 = 100000; //according to off chain checks.\r\n    uint constant BIGGEST_MIN_TAKE_AMOUNT_DAI = 80;\r\n    \r\n    // values\r\n    uint public offerDAIFactor = 700; // $700 \r\n    address public admin;\r\n    uint constant INVALID_ID = uint(-1);\r\n    uint constant internal COMMON_DECIMALS = 18;\r\n    OtcInterface public otc = OtcInterface(0x39755357759cE0d7f32dC8dC45414CCa409AE24e);\r\n    WethInterface public wethToken = WethInterface(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);\r\n    ERC20 public DAIToken = ERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);\r\n    \r\n    constructor() public {\r\n        require(wethToken.decimals() == COMMON_DECIMALS);\r\n    \r\n        require(DAIToken.approve(address(otc), 2**255));\r\n        require(wethToken.approve(address(otc), 2**255));\r\n    }\r\n\r\n    function() external payable {\r\n        \r\n    }\r\n    \r\n    function calcDaiTokenAmount (bool isEthToDai, uint payAmount, uint buyAmount, uint srcAmount) public pure returns (uint daiAmount, uint daiTokens) {\r\n        daiAmount = isEthToDai ? srcAmount * buyAmount / payAmount : srcAmount;\r\n        daiTokens = daiAmount / 10 ** 18;\r\n    }\r\n\r\n    struct OfferData {\r\n        uint payAmount;\r\n        uint buyAmount;\r\n        uint id;\r\n    }\r\n    \r\n    function showBestOffers(bool isEthToDai, uint srcAmountToken) public view\r\n        returns(uint destAmount, uint destAmountToken, uint [] memory offerIds) \r\n    {\r\n        OfferData [] memory offers;\r\n        ERC20 dstToken = isEthToDai ? DAIToken : wethToken;\r\n        ERC20 srcToken = isEthToDai ? wethToken : DAIToken;\r\n\r\n        (destAmount, offers) = findBestOffers(dstToken, srcToken, (srcAmountToken * 10 ** 18));\r\n        \r\n        destAmountToken = destAmount / 10 ** 18;\r\n        \r\n        uint i;\r\n        for (i; i \u003C offers.length; i\u002B\u002B) {\r\n            if(offers[i].id == 0) {\r\n                break;\r\n            }\r\n        }\r\n    \r\n        offerIds = new uint[](i);\r\n        for (i = 0; i \u003C offerIds.length; i\u002B\u002B) {\r\n            offerIds[i] = offers[i].id;\r\n        }\r\n    }    \r\n    \r\n    function findBestOffers(ERC20 dstToken, ERC20 srcToken, uint srcAmount) internal view\r\n       returns(uint totalDestAmount, OfferData [] memory offers)\r\n    {\r\n        uint remainingSrcAmount = srcAmount;\r\n        uint maxOrdersToTake;\r\n        uint maxTraversedOrders;\r\n        uint minTakeAmount;\r\n        uint numTakenOffer;\r\n\r\n        offers = new OfferData[](MAX_TRAVERSE_ORDERS);\r\n\r\n        // otc\u0027s terminology is of offer maker, so their sellGem is our (the taker\u0027s) dest token.\r\n        offers[0].id = otc.getBestOffer(dstToken, srcToken);\r\n        // assuming pay amount is taker pay amount. (in otc it is used differently)\r\n        (offers[0].buyAmount, , offers[0].payAmount, ) = otc.getOffer(offers[0].id);\r\n\r\n        (maxOrdersToTake, maxTraversedOrders, minTakeAmount) = calcOfferLimits(\r\n            (srcToken == wethToken),\r\n            offers[0].payAmount,\r\n            offers[0].buyAmount,\r\n            srcAmount);\r\n\r\n        uint thisOffer;\r\n\r\n        OfferData memory biggestSkippedOffer;\r\n\r\n        for ( ;maxTraversedOrders \u003E 0 ; --maxTraversedOrders) {\r\n            thisOffer = numTakenOffer;\r\n\r\n            if (offers[numTakenOffer].payAmount \u003E remainingSrcAmount) {\r\n                offers[numTakenOffer].buyAmount = remainingSrcAmount * offers[numTakenOffer].buyAmount / offers[numTakenOffer].payAmount;\r\n                offers[numTakenOffer].payAmount = remainingSrcAmount;\r\n                totalDestAmount \u002B= offers[numTakenOffer].buyAmount;\r\n                \u002B\u002BnumTakenOffer;\r\n                remainingSrcAmount = 0;\r\n                break;\r\n            } else if ((maxOrdersToTake - numTakenOffer) \u003E 1 \u0026\u0026 \r\n                        offers[numTakenOffer].payAmount \u003E remainingSrcAmount / (maxOrdersToTake - numTakenOffer \u002B 1)) {\r\n                totalDestAmount \u002B= offers[numTakenOffer].buyAmount;\r\n                remainingSrcAmount -= offers[numTakenOffer].payAmount;\r\n                \u002B\u002BnumTakenOffer;\r\n            } else if (offers[numTakenOffer].payAmount \u003E biggestSkippedOffer.payAmount) {\r\n                biggestSkippedOffer.payAmount = offers[numTakenOffer].payAmount;\r\n                biggestSkippedOffer.buyAmount = offers[numTakenOffer].buyAmount;\r\n                biggestSkippedOffer.id = offers[numTakenOffer].id;\r\n            } else if (biggestSkippedOffer.payAmount \u003E remainingSrcAmount) {\r\n                offers[numTakenOffer].id = biggestSkippedOffer.id;\r\n                offers[numTakenOffer].buyAmount = remainingSrcAmount * biggestSkippedOffer.buyAmount / biggestSkippedOffer.payAmount;\r\n                offers[numTakenOffer].payAmount = remainingSrcAmount;\r\n                totalDestAmount \u002B= offers[numTakenOffer].buyAmount;\r\n                \u002B\u002BnumTakenOffer ;\r\n                remainingSrcAmount = 0;\r\n                break;\r\n            }\r\n\r\n            offers[numTakenOffer].id = otc.getWorseOffer(offers[thisOffer].id);\r\n            (offers[numTakenOffer].buyAmount, , offers[numTakenOffer].payAmount, ) = otc.getOffer(offers[numTakenOffer].id);\r\n        }\r\n\r\n        if (remainingSrcAmount \u003E 0) totalDestAmount = 0;\r\n        if (totalDestAmount == 0) numTakenOffer = 0;\r\n    }\r\n\r\n    function takeBestOffers(ERC20 dstToken, ERC20 srcToken, uint srcAmount) internal returns(uint actualDestAmount) {\r\n        OfferData [] memory offers;\r\n\r\n        (actualDestAmount, offers) = findBestOffers(dstToken, srcToken, srcAmount);\r\n\r\n        for (uint i = 0; i \u003C offers.length; \u002B\u002Bi) {\r\n\r\n            if (offers[i].payAmount == 0) break;\r\n            require(offers[i].payAmount \u003C= MAX_QTY);\r\n            otc.take(bytes32(offers[i].id), uint128(offers[i].payAmount));  // Take the portion of the offer that we need\r\n        }\r\n\r\n        return actualDestAmount;\r\n    }\r\n\r\n    function calcOfferLimits(bool isEthToDai, uint order0Pay, uint order0Buy, uint srcAmount) public view\r\n        returns(uint maxTakes, uint maxTraverse, uint minAmountPayToken)\r\n    {\r\n        uint daiOrderSize = isEthToDai ? srcAmount * order0Buy / order0Pay : srcAmount;\r\n        uint offerLevel = daiOrderSize / 10 ** 18 / offerDAIFactor;\r\n        uint minAmountDai;\r\n        \r\n        maxTakes = BASE_TAKE_OFFERS \u002B offerLevel;\r\n        maxTakes = maxTakes \u003E MAX_TAKE_ORDERS ? MAX_TAKE_ORDERS : maxTakes;\r\n        maxTraverse = BASE_TRAVERSE_OFFERS \u002B 2 * offerLevel;\r\n        maxTraverse = maxTraverse \u003E MAX_TRAVERSE_ORDERS ? MAX_TRAVERSE_ORDERS : maxTraverse;\r\n        minAmountDai = MIN_TAKE_SIZE_DAI \u002B offerLevel * TAKE_DAI_INCREASE;\r\n        minAmountDai = minAmountDai \u003E BIGGEST_MIN_TAKE_AMOUNT_DAI ? BIGGEST_MIN_TAKE_AMOUNT_DAI : minAmountDai;\r\n\r\n        // translate min amount to pay token\r\n        minAmountPayToken = isEthToDai ? minAmountDai * order0Pay / order0Buy : minAmountDai;\r\n    }\r\n\r\n    function getNextBestOffer(\r\n        ERC20 offerSellGem,\r\n        ERC20 offerBuyGem,\r\n        uint payAmount,\r\n        uint prevOfferId\r\n    )\r\n        internal\r\n        view\r\n        returns(\r\n            uint offerId,\r\n            uint offerPayAmount,\r\n            uint offerBuyAmount\r\n        )\r\n    {\r\n        if (prevOfferId == INVALID_ID) {\r\n            offerId = otc.getBestOffer(offerSellGem, offerBuyGem);\r\n        } else {\r\n            offerId = otc.getWorseOffer(prevOfferId);\r\n        }\r\n\r\n        (offerBuyAmount, ,offerPayAmount, ) = otc.getOffer(offerId);\r\n\r\n        while (payAmount \u003E offerPayAmount) {\r\n            offerId = otc.getWorseOffer(offerId); // next best offer\r\n            if (offerId == 0) {\r\n                offerId = 0;\r\n                offerPayAmount = 0;\r\n                offerBuyAmount = 0;\r\n                break;\r\n            }\r\n            (offerBuyAmount, ,offerPayAmount, ) = otc.getOffer(offerId);\r\n        }\r\n    }\r\n    \r\n    function getEthToDaiOrders(uint numOrders) public view\r\n        returns(uint [] memory ethPayAmtTokens, uint [] memory daiBuyAmtTokens, uint [] memory rateDaiDivEthx10, uint [] memory Ids) \r\n    {\r\n        uint offerId = INVALID_ID;\r\n        ethPayAmtTokens = new uint[](numOrders);\r\n        daiBuyAmtTokens = new uint[](numOrders);    \r\n        rateDaiDivEthx10 = new uint[](numOrders);\r\n        Ids = new uint[](numOrders);\r\n        \r\n        uint offerBuyAmt;\r\n        uint offerPayAmt;\r\n        \r\n        for (uint i = 0; i \u003C numOrders; i\u002B\u002B) {\r\n            \r\n            (offerId, offerPayAmt, offerBuyAmt) = getNextBestOffer(DAIToken, wethToken, 1, offerId);\r\n            \r\n            ethPayAmtTokens[i] = offerPayAmt / 10 ** 18;\r\n            daiBuyAmtTokens[i] = offerBuyAmt / 10 ** 18;\r\n            rateDaiDivEthx10[i] = (offerBuyAmt * 10) / offerPayAmt;\r\n            Ids[i] = offerId;\r\n            \r\n            if(offerId == 0) break;\r\n        }\r\n    }\r\n    \r\n    function getDaiToEthOrders(uint numOrders) public view\r\n        returns(uint [] memory daiPayAmtTokens, uint [] memory ethBuyAmtTokens, uint [] memory rateDaiDivEthx10, uint [] memory Ids)\r\n    {\r\n        uint offerId = INVALID_ID;\r\n        daiPayAmtTokens = new uint[](numOrders);\r\n        ethBuyAmtTokens = new uint[](numOrders);\r\n        rateDaiDivEthx10 = new uint[](numOrders);\r\n        Ids = new uint[](numOrders);\r\n        \r\n        uint offerBuyAmt;\r\n        uint offerPayAmt;\r\n\r\n        for (uint i = 0; i \u003C numOrders; i\u002B\u002B) {\r\n\r\n            (offerId, offerPayAmt, offerBuyAmt) = getNextBestOffer(wethToken, DAIToken, 1, offerId);\r\n\r\n            daiPayAmtTokens[i] = offerPayAmt / 10 ** 18;\r\n            ethBuyAmtTokens[i] = offerBuyAmt / 10 ** 18;\r\n            rateDaiDivEthx10[i] = (offerPayAmt * 10) / offerBuyAmt;\r\n            Ids[i] = offerId;\r\n            \r\n            if(offerId == 0) break;\r\n        }\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022numOrders\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getEthToDaiOrders\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022ethPayAmtTokens\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022daiBuyAmtTokens\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022rateDaiDivEthx10\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022Ids\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DAIToken\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract ERC20\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022otc\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract OtcInterface\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022wethToken\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract WethInterface\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022isEthToDai\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022order0Pay\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022order0Buy\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022srcAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022calcOfferLimits\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022maxTakes\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022maxTraverse\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022minAmountPayToken\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022offerDAIFactor\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022isEthToDai\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022srcAmountToken\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022showBestOffers\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022destAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022destAmountToken\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022offerIds\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022isEthToDai\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022payAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022buyAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022srcAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022calcDaiTokenAmount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022daiAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022daiTokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022numOrders\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getDaiToEthOrders\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022daiPayAmtTokens\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022ethBuyAmtTokens\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022rateDaiDivEthx10\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022Ids\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022admin\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022}]","ContractName":"ShowEth2DAI","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://0a1fde61e38be5f91425f9c78272b7fc51fd51c72feca4e4101db25d2cd21e4f"}]