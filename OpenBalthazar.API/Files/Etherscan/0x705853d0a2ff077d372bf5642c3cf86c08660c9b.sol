[{"SourceCode":"//generated by www.structuredeth.com/gift\r\n\r\npragma solidity ^0.4.26;\r\n\r\ninterface CompoundERC20 {\r\n  function approve ( address spender, uint256 amount ) external returns ( bool );\r\n  function mint ( uint256 mintAmount ) external returns ( uint256 );\r\n  function totalSupply() public view returns (uint supply);\r\n    function balanceOf(address _owner) public view returns (uint256 balance);\r\n    function transfer(address _to, uint _value) public returns (bool success);\r\n    function transferFrom(address _from, address _to, uint _value) public returns (bool success);\r\n    function exchangeRateStored() public view returns (uint256 exchangeRate);\r\n}\r\ninterface IKyberNetworkProxy {\r\n    function maxGasPrice() external view returns(uint);\r\n    \r\n    function getUserCapInWei(address user) external view returns(uint);\r\n    function getUserCapInTokenWei(address user, ERC20 token) external view returns(uint);\r\n    function enabled() external view returns(bool);\r\n    function info(bytes32 id) external view returns(uint);\r\n    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) external view returns (uint expectedRate, uint slippageRate);\r\n    function tradeWithHint(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount, uint minConversionRate, address walletId, bytes hint) external payable returns(uint);\r\n    function swapEtherToToken(ERC20 token, uint minRate) external payable returns (uint);\r\n    function swapTokenToEther(ERC20 token, uint tokenQty, uint minRate) external returns (uint);\r\n}\r\n\r\n\r\nlibrary SafeMath {\r\n  function mul(uint256 a, uint256 b) internal constant returns (uint256) {\r\n    uint256 c = a * b;\r\n    assert(a == 0 || c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint256 a, uint256 b) internal constant returns (uint256) {\r\n    assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = a / b;\r\n    assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal constant returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function add(uint256 a, uint256 b) internal constant returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\n\r\n\r\n\r\ninterface ERC20 {\r\n    function totalSupply() public view returns(uint supply);\r\n\r\n    function balanceOf(address _owner) public view returns(uint balance);\r\n\r\n    function transfer(address _to, uint _value) public returns(bool success);\r\n\r\n    function transferFrom(address _from, address _to, uint _value) public returns(bool success);\r\n\r\n    function approve(address _spender, uint _value) public returns(bool success);\r\n\r\n    function allowance(address _owner, address _spender) public view returns(uint remaining);\r\n\r\n    function decimals() public view returns(uint digits);\r\n    event Approval(address indexed _owner, address indexed _spender, uint _value);\r\n}\r\n\r\n\r\ncontract GiftOfCompound {\r\n    \r\n    using SafeMath for uint256;\r\n    address theRecipient;\r\n    address theSender;\r\n    bytes PERM_HINT;\r\n    uint256 initialCDaiAmount;\r\n    uint256 theInterestRecipient;\r\n    uint256 theInterestSender;\r\n\r\n    uint256 initialDaiAmount;\r\n    uint256 initialcDaiDaiRate;\r\n    \r\n    uint256 startedWithGiftAmount;\r\n    uint256 internal PRECISION;\r\n    \r\n    uint256 valueChange2Result;\r\n     \r\n    CompoundERC20 cdai;\r\n    \r\n     modifier onlyGiftGroup() {\r\n        if (msg.sender != theSender \u0026\u0026 msg.sender != theRecipient) {\r\n            throw;\r\n        }\r\n        _;\r\n    }\r\n    \r\n    //if smeone sends eth to this contract, throw it because it will just end up getting locked forever\r\n    function() payable {\r\n        throw;\r\n    }\r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n\r\n    constructor(address recipient, uint256 interestRecipient, uint256 interestSender) public payable {\r\n        \r\n        if(msg.value \u003C= 0){\r\n            throw;\r\n        }\r\n        \r\n        theSender = msg.sender;\r\n        theRecipient = recipient;\r\n        \r\n        PRECISION = 10 ** 27;\r\n        theInterestSender = interestSender;\r\n        theInterestRecipient = interestRecipient;\r\n        \r\n        //sum of the interest percentage must be 100 so everyone can get their funds\r\n        if(theInterestRecipient.add(theInterestSender) != 100){\r\n            throw;\r\n        }\r\n        \r\n        startedWithGiftAmount = 0;\r\n        \r\n        initialCDaiAmount = giftWrap();\r\n      \r\n        \r\n        \r\n    }\r\n    \r\n    function transfer(address _to, uint256 _value) onlyGiftGroup  returns(bool)  {\r\n        \r\n           uint256  userHasAccessTo = amountEntitledTo(msg.sender);\r\n           \r\n             //you do not enough entitlement to the interest\r\n            if(_value \u003E userHasAccessTo){\r\n                \r\n                throw;\r\n            }\r\n            \r\n            else if(_value \u003C= initialCDaiAmount){\r\n                require(cdai.transfer(_to, _value));\r\n            }\r\n            \r\n          \r\n            else{\r\n                 require(cdai.transfer(_to, _value));\r\n            }\r\n            \r\n            //set initial amount to current amount so that people can keep withdrawing and we can know if they are entiteld to the interest amount\r\n            initialCDaiAmount = cdai.balanceOf(this);\r\n            \r\n        \r\n            return true;\r\n    }\r\n        \r\n    \r\n    function giftWrap() internal returns (uint256){\r\n      \r\n        ERC20 dai = ERC20(0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359);\r\n        address kyberProxyAddress = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;\r\n        IKyberNetworkProxy kyberProxy = IKyberNetworkProxy(kyberProxyAddress);\r\n        cdai = CompoundERC20(0xf5dce57282a584d2746faf1593d3121fcac444dc);\r\n        \r\n        theRecipient.send(1500000000000000);\r\n        \r\n        uint256 ethAmount1 = msg.value.sub(1500000000000000);\r\n        \r\n        PERM_HINT = \u0022PERM\u0022;\r\n        ERC20 eth = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);\r\n        uint daiAmount = kyberProxy.tradeWithHint.value(ethAmount1)(eth, ethAmount1, dai, this, 8000000000000000000000000000000000000000000000000000000000000000, 0, 0x0000000000000000000000000000000000000004, PERM_HINT);\r\n        dai.approve(address(cdai), 8000000000000000000000000000000000000000000000000000000);\r\n        cdai.mint(daiAmount);\r\n        \r\n        uint256 cdaiAmount = cdai.balanceOf(this);\r\n        startedWithGiftAmount = cdaiAmount;\r\n        initialDaiAmount = daiAmount;\r\n        initialcDaiDaiRate = cdai.exchangeRateStored();\r\n        return cdaiAmount;\r\n    }\r\n    \r\n    function amountEntitledTo(address qAddress) constant  returns (uint256){\r\n          //uint256 perDaiGrowth = cdai.exchangeRateStored().sub(initialcDaiDaiRate);\r\n          //uint256 currentCDAIInContract= cdai.balanceof(this);\r\n          //uint256 totalInterestEarned = cdai.exchangeRateStored().mul(cdai.balanceOf(address(this))).div(PRECISION).sub(initialCDaiAmount);\r\n          \r\n          //interest earned = \r\n          //where 22 was initial rate, 27 is the current rate, 10000 is the multiplier and 100 is the balance\r\n          //((100 * ((27 *10000)/22) ) /10000) - 100\r\n          \r\n          \r\n          uint256 initialExchangeRate  =  initialcDaiDaiRate;\r\n          uint multiplier = 10000000;\r\n          uint256 currentExchangeRate  = cdai.exchangeRateStored().mul(multiplier); \r\n          \r\n          uint256 valueChange = currentExchangeRate.div(initialExchangeRate);\r\n          uint256 valueChange2 = initialCDaiAmount.mul(valueChange).div(multiplier);\r\n          \r\n          valueChange2Result = valueChange2;\r\n          \r\n          uint256 totalInterestEarned = valueChange2.sub(initialCDaiAmount);\r\n          \r\n           uint256 usersPercentage;\r\n            if(qAddress== theRecipient){\r\n                usersPercentage = theInterestSender;\r\n            }\r\n            else if (qAddress == theSender){\r\n                usersPercentage = theInterestSender;\r\n                \r\n            }\r\n            else{\r\n                return 0;\r\n            }\r\n            \r\n            uint256 tInterestEntitledTo = totalInterestEarned.mul(usersPercentage).div(100);\r\n            \r\n            uint256 amountITo;\r\n            \r\n            if(qAddress== theRecipient){\r\n                amountITo = initialCDaiAmount.sub(tInterestEntitledTo);\r\n            }\r\n            if(qAddress== theSender){\r\n                if(initialCDaiAmount == startedWithGiftAmount){\r\n                    //nothing has been redeemed, so sender can refund\r\n                    amountITo = initialCDaiAmount;\r\n                }\r\n                else{\r\n                    amountITo = tInterestEntitledTo;\r\n                }\r\n              \r\n            }\r\n            \r\n           uint256 responseAmount = tInterestEntitledTo;\r\n            \r\n            return responseAmount;\r\n          \r\n    }\r\n    \r\n    function getStartedWithGiftAmount() constant external returns (uint256){\r\n        return startedWithGiftAmount;\r\n    }\r\n    \r\n    function getStartedWithDaiValueAmount() constant external returns (uint256){\r\n        return initialDaiAmount;\r\n    }\r\n    function getStartedWithCDaiDaiRate() constant external returns (uint256){\r\n        return initialcDaiDaiRate;\r\n    }\r\n    \r\n    \r\n    \r\n    function getRecipient() constant external returns (address){\r\n        return theRecipient;\r\n    }\r\n    \r\n    function getSender() constant external returns (address){\r\n        return theSender;\r\n    }\r\n    \r\n    function percentageInterestEntitledTo(address qAddress) constant external returns (uint256){\r\n            uint256 usersPercentage;\r\n            if(qAddress== theRecipient){\r\n                usersPercentage = theInterestRecipient;\r\n            }\r\n            else if (qAddress == theSender){\r\n                usersPercentage = theInterestSender;\r\n                \r\n            }\r\n            else{\r\n                return 0;\r\n            }\r\n            \r\n           return usersPercentage;\r\n    }\r\n    \r\n    function valueChangeVal() constant external returns (uint256){\r\n      \r\n        uint256 initialExchangeRate  =  initialcDaiDaiRate;\r\n          uint multiplier = 10000000;\r\n          uint256 currentExchangeRate  = cdai.exchangeRateStored().mul(multiplier); \r\n          \r\n          uint256 valueChange = currentExchangeRate.div(initialExchangeRate);\r\n          uint256 valueChange2 = initialCDaiAmount.mul(valueChange).div(multiplier);\r\n          uint256 totalInterestEarned = valueChange2.sub(initialCDaiAmount);\r\n          \r\n          return totalInterestEarned;\r\n    }\r\n    \r\n   \r\n    \r\n    function currentGiftAmount() constant external returns (uint256){\r\n        uint256 cDaiMinted = cdai.balanceOf(this);\r\n        return cDaiMinted;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getRecipient\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getStartedWithCDaiDaiRate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getStartedWithGiftAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022currentGiftAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getSender\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022valueChangeVal\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getStartedWithDaiValueAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022qAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022amountEntitledTo\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022qAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022percentageInterestEntitledTo\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022interestRecipient\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022interestSender\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022}]","ContractName":"GiftOfCompound","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000761e688ab19111911e0e35671dade258b6e86993000000000000000000000000000000000000000000000000000000000000005a000000000000000000000000000000000000000000000000000000000000000a","Library":"","SwarmSource":"bzzr://4b577ca8a989861ac849c369688172bac99ea744c2c23392105784fa85883563"}]