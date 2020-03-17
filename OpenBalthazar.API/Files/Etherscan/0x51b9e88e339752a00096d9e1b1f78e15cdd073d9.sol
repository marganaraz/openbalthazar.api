[{"SourceCode":"//diversified currency basket generation\r\n\r\ncontract synthMainInterface{\r\n    function minimumDepositAmount (  ) external view returns ( uint256 );\r\n  function exchangeEtherForSynthsAtRate ( uint256 guaranteedRate ) external payable returns ( uint256 );\r\n  function synthsReceivedForEther ( uint256 amount ) external view returns ( uint256 );\r\n  function synth (  ) external view returns ( address );\r\n  function exchangeSynthsForSynthetix ( uint256 synthAmount ) external returns ( uint256 );\r\n  function nominateNewOwner ( address _owner ) external;\r\n  function setPaused ( bool _paused ) external;\r\n  function initiationTime (  ) external view returns ( uint256 );\r\n  function exchangeEtherForSynths (  ) external payable returns ( uint256 );\r\n  function setSelfDestructBeneficiary ( address _beneficiary ) external;\r\n  function fundsWallet (  ) external view returns ( address );\r\n  function priceStalePeriod (  ) external view returns ( uint256 );\r\n  function setPriceStalePeriod ( uint256 _time ) external;\r\n  function terminateSelfDestruct (  ) external;\r\n  function setSynth ( address _synth ) external;\r\n  function pricesAreStale (  ) external view returns ( bool );\r\n  function updatePrices ( uint256 newEthPrice, uint256 newSynthetixPrice, uint256 timeSent ) external;\r\n  function lastPriceUpdateTime (  ) external view returns ( uint256 );\r\n  function totalSellableDeposits (  ) external view returns ( uint256 );\r\n  function nominatedOwner (  ) external view returns ( address );\r\n  function exchangeSynthsForSynthetixAtRate ( uint256 synthAmount, uint256 guaranteedRate ) external returns ( uint256 );\r\n  function paused (  ) external view returns ( bool );\r\n  function setFundsWallet ( address _fundsWallet ) external;\r\n  function depositStartIndex (  ) external view returns ( uint256 );\r\n  function synthetix (  ) external view returns ( address );\r\n  function acceptOwnership (  ) external;\r\n  function exchangeEtherForSynthetix (  ) external payable returns ( uint256 );\r\n  function setOracle ( address _oracle ) external;\r\n  function exchangeEtherForSynthetixAtRate ( uint256 guaranteedEtherRate, uint256 guaranteedSynthetixRate ) external payable returns ( uint256 );\r\n  function oracle (  ) external view returns ( address );\r\n  function withdrawMyDepositedSynths (  ) external;\r\n  function owner (  ) external view returns ( address );\r\n  function lastPauseTime (  ) external view returns ( uint256 );\r\n  function selfDestruct (  ) external;\r\n  function synthetixReceivedForSynths ( uint256 amount ) external view returns ( uint256 );\r\n  function SELFDESTRUCT_DELAY (  ) external view returns ( uint256 );\r\n  function setMinimumDepositAmount ( uint256 _amount ) external;\r\n  function feePool (  ) external view returns ( address );\r\n  function deposits ( uint256 ) external view returns ( address user, uint256 amount );\r\n  function selfDestructInitiated (  ) external view returns ( bool );\r\n  function usdToEthPrice (  ) external view returns ( uint256 );\r\n  function initiateSelfDestruct (  ) external;\r\n  function tokenFallback ( address from, uint256 amount, bytes data ) external returns ( bool );\r\n  function selfDestructBeneficiary (  ) external view returns ( address );\r\n  function smallDeposits ( address ) external view returns ( uint256 );\r\n  function synthetixReceivedForEther ( uint256 amount ) external view returns ( uint256 );\r\n  function depositSynths ( uint256 amount ) external;\r\n  function withdrawSynthetix ( uint256 amount ) external;\r\n  function usdToSnxPrice (  ) external view returns ( uint256 );\r\n  function ORACLE_FUTURE_LIMIT (  ) external view returns ( uint256 );\r\n  function depositEndIndex (  ) external view returns ( uint256 );\r\n  function setSynthetix ( address _synthetix ) external;\r\n}\r\n\r\ncontract synthConvertInterface{\r\n    function name (  ) external view returns ( string );\r\n  function setGasPriceLimit ( uint256 _gasPriceLimit ) external;\r\n  function approve ( address spender, uint256 value ) external returns ( bool );\r\n  function removeSynth ( bytes32 currencyKey ) external;\r\n  function issueSynths ( bytes32 currencyKey, uint256 amount ) external;\r\n  function mint (  ) external returns ( bool );\r\n  function setIntegrationProxy ( address _integrationProxy ) external;\r\n  function nominateNewOwner ( address _owner ) external;\r\n  function initiationTime (  ) external view returns ( uint256 );\r\n  function totalSupply (  ) external view returns ( uint256 );\r\n  function setFeePool ( address _feePool ) external;\r\n  function exchange ( bytes32 sourceCurrencyKey, uint256 sourceAmount, bytes32 destinationCurrencyKey, address destinationAddress ) external returns ( bool );\r\n  function setSelfDestructBeneficiary ( address _beneficiary ) external;\r\n  function transferFrom ( address from, address to, uint256 value ) external returns ( bool );\r\n  function decimals (  ) external view returns ( uint8 );\r\n  function synths ( bytes32 ) external view returns ( address );\r\n  function terminateSelfDestruct (  ) external;\r\n  function rewardsDistribution (  ) external view returns ( address );\r\n  function exchangeRates (  ) external view returns ( address );\r\n  function nominatedOwner (  ) external view returns ( address );\r\n  function setExchangeRates ( address _exchangeRates ) external;\r\n  function effectiveValue ( bytes32 sourceCurrencyKey, uint256 sourceAmount, bytes32 destinationCurrencyKey ) external view returns ( uint256 );\r\n  function transferableSynthetix ( address account ) external view returns ( uint256 );\r\n  function validateGasPrice ( uint256 _givenGasPrice ) external view;\r\n  function balanceOf ( address account ) external view returns ( uint256 );\r\n  function availableCurrencyKeys (  ) external view returns ( bytes32[] );\r\n  function acceptOwnership (  ) external;\r\n  function remainingIssuableSynths ( address issuer, bytes32 currencyKey ) external view returns ( uint256 );\r\n  function availableSynths ( uint256 ) external view returns ( address );\r\n  function totalIssuedSynths ( bytes32 currencyKey ) external view returns ( uint256 );\r\n  function addSynth ( address synth ) external;\r\n  function owner (  ) external view returns ( address );\r\n  function setExchangeEnabled ( bool _exchangeEnabled ) external;\r\n  function symbol (  ) external view returns ( string );\r\n  function gasPriceLimit (  ) external view returns ( uint256 );\r\n  function setProxy ( address _proxy ) external;\r\n  function selfDestruct (  ) external;\r\n  function integrationProxy (  ) external view returns ( address );\r\n  function setTokenState ( address _tokenState ) external;\r\n  function collateralisationRatio ( address issuer ) external view returns ( uint256 );\r\n  function rewardEscrow (  ) external view returns ( address );\r\n  function SELFDESTRUCT_DELAY (  ) external view returns ( uint256 );\r\n  function collateral ( address account ) external view returns ( uint256 );\r\n  function maxIssuableSynths ( address issuer, bytes32 currencyKey ) external view returns ( uint256 );\r\n  function transfer ( address to, uint256 value ) external returns ( bool );\r\n  function synthInitiatedExchange ( address from, bytes32 sourceCurrencyKey, uint256 sourceAmount, bytes32 destinationCurrencyKey, address destinationAddress ) external returns ( bool );\r\n  function transferFrom ( address from, address to, uint256 value, bytes data ) external returns ( bool );\r\n  function feePool (  ) external view returns ( address );\r\n  function selfDestructInitiated (  ) external view returns ( bool );\r\n  function setMessageSender ( address sender ) external;\r\n  function initiateSelfDestruct (  ) external;\r\n  function transfer ( address to, uint256 value, bytes data ) external returns ( bool );\r\n  function supplySchedule (  ) external view returns ( address );\r\n  function selfDestructBeneficiary (  ) external view returns ( address );\r\n  function setProtectionCircuit ( bool _protectionCircuitIsActivated ) external;\r\n  function debtBalanceOf ( address issuer, bytes32 currencyKey ) external view returns ( uint256 );\r\n  function synthetixState (  ) external view returns ( address );\r\n  function availableSynthCount (  ) external view returns ( uint256 );\r\n  function allowance ( address owner, address spender ) external view returns ( uint256 );\r\n  function escrow (  ) external view returns ( address );\r\n  function tokenState (  ) external view returns ( address );\r\n  function burnSynths ( bytes32 currencyKey, uint256 amount ) external;\r\n  function proxy (  ) external view returns ( address );\r\n  function issueMaxSynths ( bytes32 currencyKey ) external;\r\n  function exchangeEnabled (  ) external view returns ( bool );\r\n}\r\n\r\n\r\n\r\n\r\n\r\nlibrary SafeMath {\r\n  function mul(uint256 a, uint256 b) internal constant returns (uint256) {\r\n    uint256 c = a * b;\r\n    assert(a == 0 || c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint256 a, uint256 b) internal constant returns (uint256) {\r\n    assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = a / b;\r\n    assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal constant returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function add(uint256 a, uint256 b) internal constant returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\n   \r\n    contract Portfolio1 {\r\n\r\n       \r\n       synthMainInterface sInt = synthMainInterface(0x172e09691dfbbc035e37c73b62095caa16ee2388);\r\n       synthConvertInterface sInt2 = synthConvertInterface(0x42d03f506c2308ecd06ae81d8fa22352bc7a8f2b);\r\n\r\n      \r\n        //sUSD code\r\n        bytes32 sourceKey= 0x7355534400000000000000000000000000000000000000000000000000000000;\r\n\r\n        //sJPY code\r\n        bytes32 destKey = 0x734a505900000000000000000000000000000000000000000000000000000000;\r\n    \r\n        uint256 sUSDBack = 0;\r\n\r\n        using SafeMath for uint256;\r\n        \r\n       \r\n    \r\n\r\n       \r\n        function () payable{\r\n\r\n          // buyPackage();\r\n        }\r\n        \r\n        \r\n        function getLastUSDBack() constant returns (uint256){\r\n            return sUSDBack;\r\n        }\r\n\r\n       \r\n\r\n\r\n        function buyPackage() payable returns(bool){\r\n\r\n         \r\n\r\n\r\n            //100 percent for now\r\n            uint256 amountEthUsing = msg.value;\r\n            // = sInt.synthsReceivedForEther(amountEthUsing).mul(100).div(95);\r\n            sUSDBack= sInt.exchangeEtherForSynths.value(amountEthUsing)();\r\n            sInt2.exchange(sourceKey, sUSDBack, destKey ,msg.sender);\r\n\r\n            //sInt.transferFrom ( this, msg.sender, sUSDBack); \r\n\r\n\r\n         \r\n\r\n            return true;\r\n\r\n        }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getLastUSDBack\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022buyPackage\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022}]","ContractName":"Portfolio1","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://e3c7be33c95e750232fc6969c321b3b2978cf0b5033c84c20e3e47dd2525f965"}]