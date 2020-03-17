[{"SourceCode":"pragma solidity ^0.5.9;\r\n\r\n\r\ninterface ERC20 {\r\n    function totalSupply() external view returns (uint supply);\r\n    function balanceOf(address _owner) external view returns (uint balance);\r\n    function transfer(address _to, uint _value) external returns (bool success);\r\n    function transferFrom(address _from, address _to, uint _value) external returns (bool success);\r\n    function approve(address _spender, uint _value) external returns (bool success);\r\n    function allowance(address _owner, address _spender) external view returns (uint remaining);\r\n    function decimals() external view returns(uint digits);\r\n    event Approval(address indexed _owner, address indexed _spender, uint _value);\r\n}\r\n\r\n\r\ncontract OtcInterface {\r\n    function getOffer(uint id) external view returns (uint, ERC20, uint, ERC20);\r\n    function getBestOffer(ERC20 sellGem, ERC20 buyGem) external view returns(uint);\r\n    function getWorseOffer(uint id) external view returns(uint);\r\n    function take(bytes32 id, uint128 maxTakeAmount) external;\r\n}\r\n\r\n\r\ncontract WethInterface is ERC20 {\r\n    function deposit() public payable;\r\n    function withdraw(uint) public;\r\n}\r\n\r\n\r\ncontract TradeEth2DAI {\r\n    \r\n    address public admin;\r\n    uint constant INVALID_ID = uint(-1);\r\n    uint constant internal COMMON_DECIMALS = 18;\r\n    OtcInterface public otc = OtcInterface(0x39755357759cE0d7f32dC8dC45414CCa409AE24e);\r\n    WethInterface public wethToken = WethInterface(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);\r\n    ERC20 DAIToken = ERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);\r\n    \r\n    constructor() public {\r\n        require(wethToken.decimals() == COMMON_DECIMALS);\r\n    \r\n        admin = msg.sender;\r\n\r\n        require(DAIToken.approve(address(otc), 2**255));\r\n        require(wethToken.approve(address(otc), 2**255));\r\n    }\r\n\r\n    function() external payable {\r\n        \r\n    }\r\n    \r\n    event TradeExecute(\r\n        address indexed sender,\r\n        bool isEthToDai,\r\n        uint srcAmount,\r\n        uint destAmount,\r\n        address destAddress\r\n    );\r\n\r\n    function tradeEthVsDAI(\r\n        uint numTakeOrders,\r\n        bool isEthToDai,\r\n        uint srcAmount\r\n    )\r\n        public\r\n        payable\r\n    {\r\n        address payable dstAddress = msg.sender;\r\n        uint userTotalDestAmount;\r\n        \r\n        if (isEthToDai) {\r\n            require(msg.value == srcAmount);\r\n            wethToken.deposit.value(msg.value)();\r\n            userTotalDestAmount = takeOrders(wethToken, DAIToken, srcAmount, numTakeOrders);\r\n            require(DAIToken.transfer(dstAddress, userTotalDestAmount));\r\n        } else {\r\n            //Dai To Eth\r\n            require(DAIToken.transferFrom(msg.sender, address(this), srcAmount));\r\n            userTotalDestAmount = takeOrders(DAIToken, wethToken, srcAmount, numTakeOrders);\r\n            wethToken.withdraw(userTotalDestAmount);    \r\n            dstAddress.transfer(userTotalDestAmount);\r\n        }\r\n\r\n        emit TradeExecute(msg.sender, isEthToDai, srcAmount, userTotalDestAmount, dstAddress);\r\n    }\r\n\r\n    function getNextOffer(uint prevOfferId, bool isEthToDai) public view\r\n        returns(uint offerId, uint offerPayAmount, uint offerBuyAmount) \r\n    {\r\n        uint prevId = prevOfferId == 0 ? INVALID_ID : prevOfferId;       \r\n        \r\n        if(isEthToDai) {\r\n            // otc\u0027s terminology is of offer maker, so their sellGem is our (the taker\u0027s) dest token.\r\n            return(getNextBestOffer(DAIToken, wethToken, 1, prevId));\r\n        }\r\n        \r\n        // otc\u0027s terminology is of offer maker, so their sellGem is our (the taker\u0027s) dest token.\r\n        return(getNextBestOffer(wethToken, DAIToken, 1, prevId));\r\n    }\r\n    \r\n    function getNextBestOffer(\r\n        ERC20 offerSellGem,\r\n        ERC20 offerBuyGem,\r\n        uint payAmount,\r\n        uint prevOfferId\r\n    )\r\n        internal\r\n        view\r\n        returns(\r\n            uint offerId,\r\n            uint offerPayAmount,\r\n            uint offerBuyAmount\r\n        )\r\n    {\r\n        if (prevOfferId == INVALID_ID) {\r\n            offerId = otc.getBestOffer(offerSellGem, offerBuyGem);\r\n        } else {\r\n            offerId = otc.getWorseOffer(prevOfferId);\r\n        }\r\n\r\n        (offerPayAmount, , offerBuyAmount, ) = otc.getOffer(offerId);\r\n\r\n        while (payAmount \u003E offerBuyAmount) {\r\n            offerId = otc.getWorseOffer(offerId); // next best offer\r\n            if (offerId == 0) {\r\n                offerId = 0;\r\n                offerPayAmount = 0;\r\n                offerBuyAmount = 0;\r\n                break;\r\n            }\r\n            (offerPayAmount, , offerBuyAmount, ) = otc.getOffer(offerId);\r\n        }\r\n    }\r\n    \r\n    function takeOrders(ERC20 srcToken, ERC20 dstToken, uint srcAmount, uint numTakeOrders) internal \r\n        returns(uint userTotalDestAmount)\r\n    {\r\n        uint remainingAmount = srcAmount;\r\n        uint destAmount;\r\n        uint offerId = INVALID_ID;\r\n        \r\n        for (uint i = numTakeOrders; i \u003E 0; i--) {\r\n            \r\n            // otc\u0027s terminology is of offer maker, so their sellGem is our (the taker\u0027s) dest token.\r\n            (offerId, , ) = getNextBestOffer(dstToken, srcToken, remainingAmount / i, offerId);\r\n            \r\n            require(offerId \u003E 0);\r\n            \r\n            destAmount = takeMatchingOffer(remainingAmount / i, offerId);\r\n            userTotalDestAmount \u002B= destAmount;\r\n            remainingAmount -= (remainingAmount / i);\r\n        }\r\n    }\r\n    \r\n    function takeMatchingOffer(\r\n        uint srcAmount, \r\n        uint offerId\r\n    )\r\n        internal\r\n        returns(uint actualDestAmount)\r\n    {\r\n        uint offerPayAmt;\r\n        uint offerBuyAmt;\r\n\r\n        // otc\u0027s terminology is of offer maker, so their sellGem is our (the taker\u0027s) dest token.\r\n        (offerPayAmt, , offerBuyAmt, ) = otc.getOffer(offerId);\r\n        \r\n        actualDestAmount = srcAmount * offerPayAmt / offerBuyAmt;\r\n\r\n        require(uint128(actualDestAmount) == actualDestAmount);\r\n        otc.take(bytes32(offerId), uint128(actualDestAmount));  // Take the portion of the offer that we need\r\n        return(actualDestAmount);\r\n    }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022otc\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022wethToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022prevOfferId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022isEthToDai\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022getNextOffer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022offerId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022offerPayAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022offerBuyAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022numTakeOrders\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022isEthToDai\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022srcAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022tradeEthVsDAI\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022admin\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022isEthToDai\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022srcAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022destAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022destAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022TradeExecute\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"TradeEth2DAI","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://db5473a5f6c49102eb13fb9fe539c0323fe96c8e696a53a82a7aac3cb4691a9a"}]