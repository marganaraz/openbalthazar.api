[{"SourceCode":"pragma solidity ^0.4.26;\r\n\r\n// This is the smart contract for FiatDex protocol version 1\r\n// Anyone can use this smart contract to exchange Fiat for ETH or vice-versa without trusting the counterparty\r\n// The goal of the FiatDex protocol is to remove the dependence on fiat to crypto gatekeepers for those who want to trade cryptocurrency\r\n// There are no arbitrators or third party custodians. Collateral is used as leverage on the traders.\r\n\r\ncontract FiatDex_protocol_v1 {\r\n\r\n  address public owner; // This is the address of the current owner of the contract, this address collects fees, nothing more, nothing less\r\n  uint256 public feeDelay = 7; // This is the amount of days to wait before start charging the fee\r\n  uint256 public dailyFeeIncrease = 1000; // This is the percent the fee increases per day (1000 = 1%, 1 = 0.001%)\r\n  uint256 public version = 1; // This is the version of the protocol running\r\n\r\n  constructor() public {\r\n    owner = msg.sender; // Set the contract creator to the first owner\r\n  }\r\n\r\n  enum States {\r\n    NOTOPEN,\r\n    INITIALIZED,\r\n    ACTIVE,\r\n    CLOSED\r\n  }\r\n\r\n  struct Swap {\r\n    States swapState;\r\n    uint256 sendAmount;\r\n    address fiatTrader;\r\n    address ethTrader;\r\n    uint256 openTime;\r\n    uint256 ethTraderCollateral;\r\n    uint256 fiatTraderCollateral;\r\n    uint256 feeAmount;\r\n  }\r\n\r\n  mapping (bytes32 =\u003E Swap) private swaps; // Create the swaps map\r\n\r\n  event Open(bytes32 _tradeID, address _fiatTrader, uint256 _sendAmount); // Auxillary events\r\n  event Close(bytes32 _tradeID, uint256 _fee);\r\n  event ChangedOwnership(address _newOwner);\r\n\r\n  // ethTrader can only open swap positions from tradeIDs that haven\u0027t already been used\r\n  modifier onlyNotOpenSwaps(bytes32 _tradeID) {\r\n    require (swaps[_tradeID].swapState == States.NOTOPEN);\r\n    _;\r\n  }\r\n\r\n  // fiatTrader can only add collateral to swap positions that have just been opened\r\n  modifier onlyInitializedSwaps(bytes32 _tradeID) {\r\n    require (swaps[_tradeID].swapState == States.INITIALIZED);\r\n    _;\r\n  }\r\n\r\n  // ethTrader is trying to close the swap position, check this first\r\n  modifier onlyActiveSwaps(bytes32 _tradeID) {\r\n    require (swaps[_tradeID].swapState == States.ACTIVE);\r\n    _;\r\n  }\r\n\r\n  // View functions\r\n  function viewSwap(bytes32 _tradeID) public view returns (\r\n    States swapState, \r\n    uint256 sendAmount,\r\n    address ethTrader, \r\n    address fiatTrader, \r\n    uint256 openTime, \r\n    uint256 ethTraderCollateral, \r\n    uint256 fiatTraderCollateral,\r\n    uint256 feeAmount\r\n  ) {\r\n    Swap memory swap = swaps[_tradeID];\r\n    return (swap.swapState, swap.sendAmount, swap.ethTrader, swap.fiatTrader, swap.openTime, swap.ethTraderCollateral, swap.fiatTraderCollateral, swap.feeAmount);\r\n  }\r\n\r\n  function viewFiatDexSpecs() public view returns (\r\n    uint256 _version, \r\n    address _owner, \r\n    uint256 _feeDelay, \r\n    uint256 _dailyFeeIncrease\r\n  ) {\r\n    return (version, owner, feeDelay, dailyFeeIncrease);\r\n  }\r\n\r\n  // Action functions\r\n  function changeContractOwner(address _newOwner) public {\r\n    require (msg.sender == owner); // Only the current owner can change the ownership of the contract\r\n    \r\n    owner = _newOwner; // Update the owner\r\n\r\n     // Trigger ownership change event.\r\n    emit ChangedOwnership(_newOwner);\r\n  }\r\n\r\n  // ethTrader opens the swap position\r\n  function openSwap(bytes32 _tradeID, address _fiatTrader) public onlyNotOpenSwaps(_tradeID) payable {\r\n    require (msg.value \u003E 0); // Cannot open a swap position with a zero amount of ETH\r\n    // Calculate some values\r\n    uint256 _sendAmount = (msg.value * 2) / 5; // Essentially the same as dividing by 2.5 (or multiplying by 2/5)\r\n    require (_sendAmount \u003E 0); // Fail if the amount is so small that the sendAmount will be non-existant\r\n    uint256 _ethTraderCollateral = msg.value - _sendAmount; // Collateral will be whatever is not being sent to fiatTrader\r\n\r\n    // Store the details of the swap.\r\n    Swap memory swap = Swap({\r\n      swapState: States.INITIALIZED,\r\n      sendAmount: _sendAmount,\r\n      ethTrader: msg.sender,\r\n      fiatTrader: _fiatTrader,\r\n      openTime: now,\r\n      ethTraderCollateral: _ethTraderCollateral,\r\n      fiatTraderCollateral: 0,\r\n      feeAmount: 0\r\n    });\r\n    swaps[_tradeID] = swap;\r\n\r\n    // Trigger open event.\r\n    emit Open(_tradeID, _fiatTrader, _sendAmount);\r\n  }\r\n\r\n  // fiatTrader adds collateral to the open swap\r\n  function addFiatTraderCollateral(bytes32 _tradeID) public onlyInitializedSwaps(_tradeID) payable {\r\n    Swap storage swap = swaps[_tradeID]; // Get information about the swap position\r\n    require (msg.value \u003E= swap.ethTraderCollateral); // Cannot send less than what the ethTrader has in collateral\r\n    require (msg.sender == swap.fiatTrader); // Only the fiatTrader can add to the swap position\r\n    swap.fiatTraderCollateral = msg.value;   \r\n    swap.swapState = States.ACTIVE; // Now fiatTrader needs to send fiat\r\n  }\r\n\r\n  // ethTrader is refunding as fiatTrader never sent the collateral\r\n  function refundSwap(bytes32 _tradeID) public onlyInitializedSwaps(_tradeID) {\r\n    // Refund the swap.\r\n    Swap storage swap = swaps[_tradeID];\r\n    require (msg.sender == swap.ethTrader); // Only the ethTrader can call this function to refund\r\n    swap.swapState = States.CLOSED; // Swap is now closed, sending all ETH back\r\n\r\n    // Transfer the ETH value from this contract back to the ETH trader.\r\n    swap.ethTrader.transfer(swap.sendAmount \u002B swap.ethTraderCollateral);\r\n\r\n     // Trigger expire event.\r\n    emit Close(_tradeID, 0);\r\n  }\r\n\r\n  // ethTrader is completing the swap position as fiatTrader has sent the fiat\r\n  function closeSwap(bytes32 _tradeID) public onlyActiveSwaps(_tradeID) {\r\n    // Complete the swap.\r\n    Swap storage swap = swaps[_tradeID];\r\n    require (msg.sender == swap.ethTrader); // Only the ethTrader can call this function to close\r\n    swap.swapState = States.CLOSED; // Swap is now closed, sending all ETH, prevent re-entry\r\n\r\n    // Calculate the fee \r\n    uint256 feeAmount = 0; // This is the amount of fee in Wei\r\n    uint256 currentTime = now;\r\n    if(swap.openTime \u002B 86400 * feeDelay \u003C currentTime){\r\n      // The swap has been open for a duration longer than the feeDelay window, so calculate fee\r\n      uint256 seconds_over = currentTime - (swap.openTime \u002B 86400 * feeDelay); // This is guaranteed to be a positive number\r\n      uint256 feePercent = (dailyFeeIncrease * seconds_over) / 86400; // This will show us the percentage fee to charge\r\n      // For feePercent, 1 = 0.001% of collateral, 1000 = 1% of collateral     \r\n      if(feePercent \u003E 0){\r\n        if(feePercent \u003E 99000) {feePercent = 99000;} // feePercent can never be greater than 99%\r\n        // Calculate the feeAmount in Wei\r\n        // This feeAmount will be subtracted equally from the ethTrader and fiatTrader\r\n        feeAmount = (swap.ethTraderCollateral * feePercent) / 100000;\r\n      }\r\n    }\r\n\r\n    // Transfer all the ETH to the appropriate parties, the owner will get some ETH if a fee is calculated\r\n    if(feeAmount \u003E 0){\r\n      swap.feeAmount = feeAmount;\r\n      owner.transfer(feeAmount * 2);\r\n    }\r\n\r\n    // Transfer the ETH collateral from this contract back to the ETH trader.\r\n    swap.ethTrader.transfer(swap.ethTraderCollateral - feeAmount);\r\n\r\n    // Transfer the ETH collateral back to fiatTrader and the sendAmount from ethTrader\r\n    swap.fiatTrader.transfer(swap.sendAmount \u002B swap.fiatTraderCollateral - feeAmount);\r\n\r\n     // Trigger close event showing the fee.\r\n    emit Close(_tradeID, feeAmount);\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tradeID\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022viewSwap\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022swapState\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022sendAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022ethTrader\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022fiatTrader\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022openTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022ethTraderCollateral\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022fiatTraderCollateral\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022feeAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tradeID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_fiatTrader\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022openSwap\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeContractOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022version\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tradeID\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022closeSwap\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022dailyFeeIncrease\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022feeDelay\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tradeID\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022addFiatTraderCollateral\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022viewFiatDexSpecs\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_version\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_feeDelay\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_dailyFeeIncrease\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tradeID\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022refundSwap\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_tradeID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_fiatTrader\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_sendAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Open\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_tradeID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_fee\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Close\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022ChangedOwnership\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"FiatDex_protocol_v1","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://88a5a801419f33d0226999d5cbff3a08c8d8fa5c6a84d80609e92eb27c8e1d4a"}]