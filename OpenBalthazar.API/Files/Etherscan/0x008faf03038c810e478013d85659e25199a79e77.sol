[{"SourceCode":"pragma solidity ^0.4.26;\r\n\r\n// Simple Options is a binary option smart contract. This is version 3 of the contract. There are a few improvements.\r\n\r\n// Users are given a 1 hour window to determine whether the price of ETH will increase or decrease.\r\n// Winners will divide a percentage of the house pot. That percentage is based on odds of winning. \r\n// The lower the odds of winning, the higher the percentage the winners will receive.\r\n// Odds of winning is equal to Winners Tickets / Total Tickets.\r\n// Payout percent: 10% \u002B 80% x (1 - Odds of Winning)\r\n// Max payout is 90% of the pot but it is capped to total user contribution from each side (not combined)\r\n// Only during the first 30 minutes of each round can users buy tickets.\r\n// Once the time has expired, users can force the round to end which will trigger\r\n// a payout from the house pot to the winning side and start a new round with the current price set as the starting price; however,\r\n// if they don\u0027t, a cron job ran externally will automatically close the round.\r\n// The user that closes the round will get the gasCost reimbursement from the house pot, upto 15 Gwei for gas price\r\n\r\n// The price per ticket is fixed at 1/100th of the house pot but the minimum price is 0.0001 ETH and max is 1 ETH. Users can buy more than 1 ticket.\r\n\r\n// The price Oracle for this contract is the Compound PriceOracle (0x2c9e6bdaa0ef0284eecef0e0cc102dcdeae4887e), which updates\r\n// frequently when ETH price changes \u003E 1%. cToken used is USDC (0x39aa39c021dfbae8fac545936693ac917d5e7563)\r\n\r\n// The contract charges a fee that goes to the contract feeAddress upon winning. It is 5%. This fee is taken from the winners\u0027 payout\r\n// If there is no contest, there are no fees.\r\n\r\n// If at the end of the round, the price stays the same, there are no winners or losers. Everyone can withdraw their balance.\r\n// If the round is not ended within 3 minutes after the deadline, the price is considered stale and there are no winners or\r\n// losers. Everyone can withdraw their balance.\r\n// If at the end of the round, there is no competition, the winners will receive at most 10% of the house pot split evenly between them.\r\n\r\ncontract Compound_ETHUSDC {\r\n  function getUnderlyingPrice(address cToken) external view returns (uint256);\r\n}\r\n\r\ncontract Simple_Options_v3 {\r\n\r\n  // Administrator information\r\n  address public feeAddress; // This is the address of the person that collects the fees, nothing more, nothing less. It can be changed.\r\n  uint256 public feePercent = 5000; // This is the percent of the fee (5000 = 5.0%, 1 = 0.001%)\r\n  uint256 constant roundCutoff = 1800; // The cut-off time (in seconds) to submit a bet before the round ends. Currently 12 hours\r\n  uint256 constant roundLength = 3600; // The length of the round (in seconds)\r\n  address constant compoundOracleProxy = 0x2C9e6BDAA0EF0284eECef0e0Cc102dcDEaE4887e; // Contract address for the Compound price oracle proxy\r\n  address constant cUSDCAddress = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;\r\n\r\n  // Different types of round Status\r\n  enum RoundStatus {\r\n    OPEN,\r\n    CLOSED,\r\n    STALEPRICE, // No winners due to price being too late\r\n    NOCONTEST // No winners\r\n  }\r\n\r\n  struct Round {\r\n    uint256 roundNum; // The round number\r\n    RoundStatus roundStatus; // The round status\r\n    uint256 startPriceWei; // ETH price at start of round\r\n    uint256 endPriceWei; // ETH price at end\r\n    uint256 startTime; // Unix seconds at start of round\r\n    uint256 endTime; // Unix seconds at end\r\n    uint256 endPotSize; // The contract pot size at the end of the round\r\n    uint256 totalCallTickets; // Tickets for expected price increase\r\n    uint256 totalCallPotWei; // Pot size for the users who believe in call\r\n    uint256 totalPutTickets; // Tickets for expected price decrease\r\n    uint256 totalPutPotWei; // Pot size for the users who believe in put\r\n\r\n    uint256 totalUsers; // Total users in this round\r\n    mapping (uint256 =\u003E address) userList;\r\n    mapping (address =\u003E User) users;\r\n  }\r\n\r\n  struct User {\r\n    uint256 numCallTickets;\r\n    uint256 numPutTickets;\r\n    uint256 callBalanceWei;\r\n    uint256 putBalanceWei;\r\n  }\r\n\r\n  mapping (uint256 =\u003E Round) roundList; // A mapping of all the rounds based on an integer\r\n  uint256 public currentRound = 0; // The current round\r\n  uint256 public currentPotSize = 0; // This is the size of the house pot, used to incentivise activity\r\n\r\n  event ChangedFeeAddress(address _newFeeAddress);\r\n  event FailedFeeSend(address _user, uint256 _amount);\r\n  event FeeSent(address _user, uint256 _amount);\r\n  event BoughtCallTickets(address _user, uint256 _ticketNum, uint256 _roundNum);\r\n  event BoughtPutTickets(address _user, uint256 _ticketNum, uint256 _roundNum);\r\n  event FailedPriceOracle();\r\n  event StartedNewRound(uint256 _roundNum);\r\n\r\n  constructor() public {\r\n    feeAddress = msg.sender; // Set the contract creator to the first feeAddress\r\n  }\r\n\r\n  // View function\r\n  // View round information\r\n  function viewRoundInfo(uint256 _numRound) public view returns (\r\n    uint256 _startPriceWei,\r\n    uint256 _endPriceWei,\r\n    uint256 _startTime,\r\n    uint256 _endTime,\r\n    uint256 _totalCallPotWei,\r\n    uint256 _totalPutPotWei,\r\n    uint256 _totalCallTickets, \r\n    uint256 _totalPutTickets,\r\n    RoundStatus _status,\r\n    uint256 _endPotSize\r\n  ) {\r\n    assert(_numRound \u003C= currentRound);\r\n    assert(_numRound \u003E= 1);\r\n    Round memory _round = roundList[_numRound];\r\n    if(_numRound == currentRound) { _round.endPotSize = currentPotSize; } // For the current Round, current pot is its size\r\n    return (_round.startPriceWei, _round.endPriceWei, _round.startTime, _round.endTime, _round.totalCallPotWei, _round.totalPutPotWei, _round.totalCallTickets, _round.totalPutTickets, _round.roundStatus, _round.endPotSize);\r\n  }\r\n\r\n  // View user information that is round specific\r\n  function viewUserInfo(uint256 _numRound, address _userAddress) public view returns (\r\n    uint256 _numCallTickets,\r\n    uint256 _numPutTickets,\r\n    uint256 _balanceWei\r\n  ) {\r\n    assert(_numRound \u003C= currentRound);\r\n    assert(_numRound \u003E= 1);\r\n    Round storage _round = roundList[_numRound];\r\n    User memory _user = _round.users[_userAddress];\r\n    uint256 balance = _user.callBalanceWei \u002B _user.putBalanceWei;\r\n    return (_user.numCallTickets, _user.numPutTickets, balance);\r\n  }\r\n\r\n  // View the current round\u0027s ticket cost\r\n  function viewCurrentCost() public view returns (\r\n    uint256 _cost\r\n  ) {\r\n    uint256 cost = calculateCost();\r\n    return (cost);\r\n  }\r\n\r\n  // Action functions\r\n  // Change contract fee address\r\n  function changeContractFeeAddress(address _newFeeAddress) public {\r\n    require (msg.sender == feeAddress); // Only the current feeAddress can change the feeAddress of the contract\r\n    \r\n    feeAddress = _newFeeAddress; // Update the fee address\r\n\r\n     // Trigger event.\r\n    emit ChangedFeeAddress(_newFeeAddress);\r\n  }\r\n\r\n  // Add to the contract pot in case it becomes too small to incentivise\r\n  function addToHousePot() public payable {\r\n    require(msg.value \u003E 0);\r\n    currentPotSize = currentPotSize \u002B msg.value;\r\n  }\r\n\r\n  // This function creates a new round if the time is right (only after the endTime of the previous round) or if no rounds exist\r\n  // Anyone can request to start a new round, it is not priviledged\r\n  function startNewRound() public {\r\n    uint256 gasUsed = gasleft();\r\n    if(currentRound == 0){\r\n      // This is the first round of the contract\r\n      Round memory _newRound;\r\n      currentRound = currentRound \u002B 1;\r\n      _newRound.roundNum = currentRound;\r\n      \r\n      // Obtain the current price from the Maker Oracle\r\n      _newRound.startPriceWei = getOraclePrice(); // This function must return a price\r\n\r\n      // Set the timers up\r\n      _newRound.startTime = now;\r\n      _newRound.endTime = _newRound.startTime \u002B roundLength; // 24 Hour rounds\r\n      roundList[currentRound] = _newRound;\r\n\r\n      emit StartedNewRound(currentRound);\r\n    }else if(currentRound \u003E 0){\r\n      // The user wants to close the current round and start a new one\r\n      uint256 cTime = now;\r\n      uint256 feeAmount = 0;\r\n      Round storage _round = roundList[currentRound];\r\n      require( cTime \u003E= _round.endTime ); // Cannot close a round unless the endTime is reached\r\n\r\n      // Obtain the current price from the Maker Oracle\r\n      _round.endPriceWei = getOraclePrice();\r\n      _round.endPotSize = currentPotSize; // The pot size will now be distributed\r\n\r\n      bool no_contest = false; \r\n\r\n      // If the price is stale, the current round has no losers or winners   \r\n      if( cTime - 180 \u003E _round.endTime){ // More than 3 minutes after round has ended, price is stale\r\n        no_contest = true;\r\n        _round.endTime = cTime;\r\n        _round.roundStatus = RoundStatus.STALEPRICE;\r\n      }\r\n\r\n      if(no_contest == false \u0026\u0026 _round.endPriceWei == _round.startPriceWei){\r\n        no_contest = true; // The price hasn\u0027t changed, so no one wins\r\n        _round.roundStatus = RoundStatus.NOCONTEST;\r\n      }\r\n\r\n      if(no_contest == false \u0026\u0026 _round.totalCallTickets == 0 \u0026\u0026 _round.totalPutTickets == 0){\r\n        no_contest = true; // There are no players in this round\r\n        _round.roundStatus = RoundStatus.NOCONTEST;\r\n      }\r\n\r\n      if(no_contest == false){\r\n        // Distribute winnings\r\n        feeAmount = distributeWinnings(_round);\r\n\r\n        // Close out the round completely which allows users to withdraw balance\r\n        _round.roundStatus = RoundStatus.CLOSED;\r\n      }\r\n\r\n      // Open up a new round using the endTime for the last round as the startTime\r\n      // and the endprice of the last round as the startprice\r\n      Round memory _nextRound;\r\n      currentRound = currentRound \u002B 1;\r\n      _nextRound.roundNum = currentRound;\r\n      \r\n      // The current price will be the previous round\u0027s end price\r\n      _nextRound.startPriceWei = _round.endPriceWei;\r\n\r\n      // Set the timers up\r\n      _nextRound.startTime = _round.endTime; // Set the start time to the previous round endTime\r\n      _nextRound.endTime = _nextRound.startTime \u002B roundLength;\r\n      roundList[currentRound] = _nextRound;\r\n\r\n      // Send the fee if present\r\n      if(feeAmount \u003E 0){\r\n        bool sentfee = feeAddress.send(feeAmount);\r\n        if(sentfee == false){\r\n          emit FailedFeeSend(feeAddress, feeAmount); // Create an event in case of fee sending failed, but don\u0027t stop ending the round\r\n        }else{\r\n          emit FeeSent(feeAddress, feeAmount); // Record that the fee was sent\r\n        }\r\n      }\r\n      emit StartedNewRound(currentRound);\r\n    }\r\n\r\n    // Pay back the caller of this function the gas fees from the house pot\r\n    // This is an expensive method so payback caller\r\n    gasUsed = gasUsed - gasleft() \u002B 21000; // Cover the gas for the future send\r\n    uint256 gasCost = tx.gasprice; // This is the price of the gas in wei\r\n    if(gasCost \u003E 15000000000) { gasCost = 15000000000; } // Gas price cannot be greater than 15 Gwei\r\n    gasCost = gasCost * gasUsed;\r\n    if(gasCost \u003E currentPotSize) { gasCost = currentPotSize; } // Cannot be greater than the pot\r\n    currentPotSize = currentPotSize - gasCost;\r\n    if(gasCost \u003E 0){\r\n      msg.sender.transfer(gasCost); // If this fails, revert the entire transaction, they will lose a lot of gas\r\n    }\r\n  }\r\n\r\n  // Buy some call tickets\r\n  function buyCallTickets() public payable {\r\n    buyTickets(0);\r\n  }\r\n\r\n  // Buy some put tickets\r\n  function buyPutTickets() public payable {\r\n    buyTickets(1);\r\n  }\r\n\r\n  // Withdraw from a previous round\r\n  // Cannot withdraw partial funds, all funds are withdrawn\r\n  function withdrawFunds(uint256 roundNum) public {\r\n    require( roundNum \u003E 0 \u0026\u0026 roundNum \u003C currentRound); // Can only withdraw from previous rounds\r\n    Round storage _round = roundList[roundNum];\r\n    require( _round.roundStatus != RoundStatus.OPEN ); // Round must be closed\r\n    User storage _user = _round.users[msg.sender];\r\n    uint256 balance = _user.callBalanceWei \u002B _user.putBalanceWei;\r\n    require( _user.callBalanceWei \u002B _user.putBalanceWei \u003E 0); // Must have a balance to send out\r\n    _user.callBalanceWei = 0;\r\n    _user.putBalanceWei = 0;\r\n    msg.sender.transfer(balance); // Protected from re-entrancy\r\n  }\r\n\r\n  // Private functions\r\n  function calculateCost() private view returns (uint256 _weiCost){\r\n    uint256 cost = currentPotSize / 100;\r\n    cost = ceil(cost,100000000000000);\r\n    if(cost \u003C 100000000000000) { cost = 100000000000000; } // Minimum cost of 0.0001 ETH\r\n    if(cost \u003E 10000000000000000000) { cost = 10000000000000000000; } // Maximum cost of 1 ETH \r\n    return cost;\r\n  }\r\n\r\n  function calculateWinAmount(uint256 _fundSize, uint256 _winTickets, uint256 _totalTickets) private pure returns (uint256 _amount){\r\n    uint256 percent = 10000 \u002B (80000 * (100000 - ((_winTickets * 100000) / _totalTickets))) / 100000; // 100% = 100 000, 1% = 1000\r\n    return (_fundSize * percent) / 100000;\r\n  }\r\n\r\n  function ceil(uint a, uint m) private pure returns (uint256 _ceil) {\r\n    return ((a \u002B m - 1) / m) * m;\r\n  }\r\n\r\n  // Grabs the price from the Compound price oracle\r\n  function getOraclePrice() private view returns (uint256 _price){\r\n    Compound_ETHUSDC oracle = Compound_ETHUSDC(compoundOracleProxy);\r\n    uint256 usdcPrice = oracle.getUnderlyingPrice(cUSDCAddress); // This returns the price in relation to 1 ether\r\n    usdcPrice = usdcPrice / 1000000000000; // Normalize the price value\r\n    usdcPrice = 1000000000000000000000 / usdcPrice; // The precision level will be 3 decimal places\r\n    return (usdcPrice * 1000000000000000); // Now back to Wei units\r\n  }\r\n\r\n  // Distributes the players winnings from the house pot and returns the fee\r\n  // This function is needed to get around Ethereum\u0027s variable max\r\n  // Losers funds go to house pot for the next round\r\n  function distributeWinnings(Round storage _round) private returns (uint256 _fee){\r\n    // There are winners and losers\r\n    uint256 feeAmount = 0;\r\n    uint256 addAmount = 0;\r\n    uint256 it = 0;\r\n    uint256 rewardPerTicket = 0;\r\n    uint256 roundTotal = 0;\r\n    uint256 remainBalance = 0;\r\n    if(_round.endPriceWei \u003E _round.startPriceWei){\r\n      // The calls have won the game\r\n\r\n      // Divide the house funds appropriately based on odds\r\n      roundTotal = calculateWinAmount(currentPotSize, _round.totalCallTickets, _round.totalCallTickets\u002B_round.totalPutTickets);\r\n      // Cap the roundTotal is either the total contribution from the PutPotWei or CallPotWei, whichever is greater\r\n      if(roundTotal \u003E _round.totalCallPotWei \u0026\u0026 roundTotal \u003E _round.totalPutPotWei){\r\n        if(_round.totalCallPotWei \u003E _round.totalPutPotWei){\r\n          roundTotal = _round.totalCallPotWei;\r\n        }else{\r\n          roundTotal = _round.totalPutPotWei;\r\n        }\r\n      }\r\n\r\n      if(_round.totalCallTickets \u003E 0){\r\n        // There may not be call tickets, but still subtract the losers fee\r\n        currentPotSize = currentPotSize - roundTotal; // Take this balance from the pot\r\n        feeAmount = (roundTotal * feePercent) / 100000; // Fee is deducted from the winners amount\r\n        roundTotal = roundTotal - feeAmount;\r\n        rewardPerTicket = roundTotal / _round.totalCallTickets; // Split the pot among the winners\r\n      }\r\n      remainBalance = roundTotal;\r\n      \r\n      for(it = 0; it \u003C _round.totalUsers; it\u002B\u002B){ // Go through each user in the round\r\n        User storage _user = _round.users[_round.userList[it]];\r\n        if(_user.numPutTickets \u003E 0){\r\n          // We have some losing tickets, set our put balance to zero\r\n          _user.putBalanceWei = 0;\r\n        }\r\n        if(_user.numCallTickets \u003E 0){\r\n          // We have some winning tickets, add to our call balance\r\n          addAmount = _user.numCallTickets * rewardPerTicket;\r\n          if(addAmount \u003E remainBalance){addAmount = remainBalance;} // Cannot be greater than what is left\r\n          _user.callBalanceWei = _user.callBalanceWei \u002B addAmount;\r\n          remainBalance = remainBalance - addAmount;\r\n        }\r\n      }\r\n\r\n      // Now add the losers funds to the remaining pot for the next round\r\n      currentPotSize = currentPotSize \u002B _round.totalPutPotWei;\r\n    }else{\r\n      // The puts have won the game, price has decreased\r\n\r\n      // Divide the house funds appropriately based on odds\r\n      roundTotal = calculateWinAmount(currentPotSize, _round.totalPutTickets, _round.totalCallTickets\u002B_round.totalPutTickets);     \r\n      // Cap the roundTotal is either the total contribution from the PutPotWei or CallPotWei, whichever is greater\r\n      if(roundTotal \u003E _round.totalCallPotWei \u0026\u0026 roundTotal \u003E _round.totalPutPotWei){\r\n        if(_round.totalCallPotWei \u003E _round.totalPutPotWei){\r\n          roundTotal = _round.totalCallPotWei;\r\n        }else{\r\n          roundTotal = _round.totalPutPotWei;\r\n        }\r\n      }\r\n      \r\n      if(_round.totalPutTickets \u003E 0){\r\n        // There may not be put tickets, but still subtract the losers fee\r\n        currentPotSize = currentPotSize - roundTotal; // Take this balance from the pot\r\n        feeAmount = (roundTotal * feePercent) / 100000; // Fee is deducted from the winners amount\r\n        roundTotal = roundTotal - feeAmount;\r\n        rewardPerTicket = roundTotal / _round.totalPutTickets; // Split the pot among the winners\r\n      }\r\n      remainBalance = roundTotal;\r\n\r\n      for(it = 0; it \u003C _round.totalUsers; it\u002B\u002B){ // Go through each user in the round\r\n        User storage _user2 = _round.users[_round.userList[it]];\r\n        if(_user2.numCallTickets \u003E 0){\r\n          // We have some losing tickets, set our call balance to zero\r\n          _user2.callBalanceWei = 0;\r\n        }\r\n        if(_user2.numPutTickets \u003E 0){\r\n          // We have some winning tickets, add to our put balance\r\n          addAmount = _user2.numPutTickets * rewardPerTicket;\r\n          if(addAmount \u003E remainBalance){addAmount = remainBalance;} // Cannot be greater than what is left\r\n          _user2.putBalanceWei = _user2.putBalanceWei \u002B addAmount;\r\n          remainBalance = remainBalance - addAmount;\r\n        }\r\n      }\r\n\r\n      // Now add the losers funds to the remaining pot for the next round\r\n      currentPotSize = currentPotSize \u002B _round.totalCallPotWei;\r\n    }\r\n    return feeAmount;\r\n  } \r\n\r\n  function buyTickets(uint256 ticketType) private {\r\n    require( currentRound \u003E 0 ); // There must be an active round ongoing\r\n    Round storage _round = roundList[currentRound];\r\n    uint256 endTime = _round.endTime;\r\n    uint256 currentTime = now;\r\n    require( currentTime \u003C= endTime - roundCutoff); // Cannot buy a ticket after the cutoff time\r\n    uint256 currentCost = calculateCost(); // Calculate the price\r\n    require(msg.value % currentCost == 0); // The value must be a multiple of the cost\r\n    require(msg.value \u003E= currentCost); // Must have some value\r\n    require(_round.totalUsers \u003C= 1000); // Cannot have more than 1000 users per round\r\n    require(_round.roundStatus == RoundStatus.OPEN); // Round is still open, it should be\r\n    \r\n    uint256 numTickets = msg.value / currentCost; // The user can buy multple tickets\r\n\r\n    // Check if user is in the mapping\r\n    User memory _user = _round.users[msg.sender];\r\n    if(_user.numCallTickets \u002B _user.numPutTickets == 0){\r\n      // No tickets yet for user, new user\r\n      _round.userList[_round.totalUsers] = msg.sender;\r\n      _round.totalUsers = _round.totalUsers \u002B 1;\r\n    }\r\n\r\n    if(ticketType == 0){\r\n      // Call ticket\r\n      _user.numCallTickets = _user.numCallTickets \u002B numTickets;\r\n      _user.callBalanceWei = _user.callBalanceWei \u002B msg.value;\r\n      _round.totalCallTickets = _round.totalCallTickets \u002B numTickets;\r\n      _round.totalCallPotWei = _round.totalCallPotWei \u002B msg.value;\r\n\r\n      emit BoughtCallTickets(msg.sender, numTickets, currentRound);\r\n    }else{\r\n      // Put ticket\r\n      _user.numPutTickets = _user.numPutTickets \u002B numTickets;\r\n      _user.putBalanceWei = _user.putBalanceWei \u002B msg.value;\r\n      _round.totalPutTickets = _round.totalPutTickets \u002B numTickets;\r\n      _round.totalPutPotWei = _round.totalPutPotWei \u002B msg.value;\r\n\r\n      emit BoughtPutTickets(msg.sender, numTickets, currentRound);\r\n    }\r\n\r\n    _round.users[msg.sender] = _user; // Add the user information to the game\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022roundNum\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawFunds\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newFeeAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeContractFeeAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022feeAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022viewCurrentCost\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_cost\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022feePercent\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022currentRound\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022buyCallTickets\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022currentPotSize\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_numRound\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_userAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022viewUserInfo\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_numCallTickets\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_numPutTickets\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_balanceWei\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022startNewRound\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022addToHousePot\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_numRound\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022viewRoundInfo\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_startPriceWei\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_endPriceWei\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_startTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_endTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_totalCallPotWei\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_totalPutPotWei\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_totalCallTickets\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_totalPutTickets\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_status\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022_endPotSize\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022buyPutTickets\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_newFeeAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022ChangedFeeAddress\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022FailedFeeSend\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022FeeSent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_ticketNum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_roundNum\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022BoughtCallTickets\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_ticketNum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_roundNum\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022BoughtPutTickets\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022FailedPriceOracle\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_roundNum\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022StartedNewRound\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Simple_Options_v3","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://105214ed14ff3ef29a7f200d529a53db6a989256c1d63db250381bc694e4ebc0"}]