[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\n/* This is the Revolution smart contract from the culottes project.\r\nIts copyrights (2019) belong to its authors including Jean Millerat (siggg at akasig dot org).\r\nIt is distributed under the GNU Affero General Public License version 3 or later (AGPL v.3 or later). You can find a copy of this license with the full source code of this project at\r\nhttps://github.com/siggg/culottes\r\n*/\r\n\r\ncontract Revolution {\r\n\r\n  address public owner = msg.sender;\r\n  \r\n  // Criteria the citizen should match to win votes\r\n  // e.g. : \u0022a sans-culotte\u0022\r\n  string public criteria;\r\n  \r\n  // Hashtag to be used for discussing this contract\r\n  // e.g. : \u0022#SansCulottesRevolution\u0022\r\n  string public hashtag;\r\n\r\n  // Minimum number of blocks before next cake distribution from the Revolution\r\n  uint public distributionBlockPeriod;\r\n\r\n  // Amount of WEI to be distributed to each citizen matching criteria\r\n  uint public distributionAmount;\r\n\r\n  // Number of the block at last distribution\r\n  uint lastDistributionBlockNumber;\r\n\r\n  // Are we running in testing mode ?\r\n  bool public testingMode;\r\n  \r\n  // Is this Revolution irreversibly locked (end of life) ?\r\n  \r\n  bool public locked;\r\n\r\n  // For a given citizen, let\u0027s put all positive (or negative) votes\r\n  // received into a positive (or negative) justice scale.\r\n  struct JusticeScale {\r\n    address payable [] voters;\r\n    mapping (address =\u003E uint) votes;\r\n    uint amount;\r\n  }\r\n\r\n  // This the revolutionary trial for a given citizen\r\n  struct Trial {\r\n    address payable citizen;\r\n    JusticeScale sansculotteScale;\r\n    JusticeScale privilegedScale;\r\n    uint lastClosingAttemptBlock;\r\n    bool opened;\r\n    bool matchesCriteria;\r\n  }\r\n\r\n  // Citizens known at this Revolution\r\n  address payable [] public citizens;\r\n  // Trials known at this Revolution\r\n  mapping (address =\u003E Trial) private trials;\r\n\r\n  // This is the amount of cakes in the Bastille\r\n  uint public bastilleBalance;\r\n\r\n  // Start of new trial for a given citizen\r\n  event TrialOpened(string indexed _eventName, address indexed _citizen);\r\n  // End of trial for a given citizen\r\n  event TrialClosed(string indexed _eventName, address indexed _citizen);\r\n  // New cake-vote received for a given citizen\r\n  event VoteReceived(string indexed _eventName, address _from, address indexed _citizen, bool _vote, uint indexed _amount);\r\n  // \r\n  event Distribution(string indexed _eventName, address indexed _citizen, uint _distributionAmount);\r\n\r\n\r\n  constructor(string memory _criteria, string memory _hashtag, uint _distributionBlockPeriod, uint _distributionAmount, bool _testingMode) public{\r\n    criteria = _criteria;\r\n    hashtag = _hashtag;\r\n    distributionBlockPeriod = _distributionBlockPeriod;\r\n    distributionAmount = _distributionAmount;\r\n    lastDistributionBlockNumber = block.number;\r\n    testingMode = _testingMode;\r\n    locked = false;\r\n  }\r\n\r\n  function lock() public {\r\n    // will irreversibly lock this Revolution\r\n    // only contract owner can lock\r\n    require(msg.sender == owner);\r\n    locked = true;\r\n  }\r\n\r\n  function vote(bool _vote, address payable _citizen) public payable {\r\n    require(locked == false || bastilleBalance \u003E 0);\r\n    Trial storage trial = trials[_citizen];\r\n    trial.opened = true;\r\n    if (trial.citizen == address(0x0) ) {\r\n      // this is a new trial, emit an event\r\n      emit TrialOpened(\u0027TrialOpened\u0027, _citizen);\r\n      citizens.push(_citizen);\r\n      trial.citizen = _citizen;\r\n    }\r\n\r\n    JusticeScale storage scale = trial.sansculotteScale;\r\n    if (_vote == false) {\r\n      scale = trial.privilegedScale;\r\n    }\r\n    scale.voters.push(msg.sender);\r\n    scale.votes[msg.sender] \u002B= msg.value;\r\n    scale.amount\u002B= msg.value;\r\n\r\n    emit VoteReceived(\u0027VoteReceived\u0027, msg.sender, _citizen, _vote, msg.value);\r\n\r\n    if(testingMode == false) {\r\n      closeTrial(_citizen);\r\n      distribute();\r\n    }\r\n  }\r\n\r\n  function closeTrial(address payable _citizen) public {\r\n    \r\n    // check the closing  lottery\r\n    bool shouldClose = closingLottery(_citizen);\r\n    // update attempt block number\r\n    Trial storage trial = trials[_citizen];\r\n    trial.lastClosingAttemptBlock = block.number;\r\n    if(shouldClose == false) {\r\n      // no luck this time, won\u0027t close yet, retry later\r\n      return;\r\n    }\r\n  \r\n    // let\u0027s close the trial now\r\n    emit TrialClosed(\u0027TrialClosed\u0027, _citizen);\r\n\r\n    // Mark the trial as closed\r\n    trial.opened = false;\r\n    // Issue a verdict : is this citizen a sans-culotte or a privileged ?\r\n    // By default, citizens are seen as privileged...\r\n    JusticeScale storage winnerScale = trial.privilegedScale;\r\n    JusticeScale storage loserScale = trial.sansculotteScale;\r\n    trial.matchesCriteria = false;\r\n    // .. unless they get more votes on their sans-culotte scale than on their privileged scale.\r\n    if (trial.sansculotteScale.amount \u003E trial.privilegedScale.amount) {\r\n      winnerScale = trial.sansculotteScale;\r\n      loserScale = trial.privilegedScale;\r\n      trial.matchesCriteria = true;\r\n    }\r\n\r\n    // Compute Bastille virtual vote\r\n    uint bastilleVote = winnerScale.amount - loserScale.amount;\r\n\r\n    // Distribute cakes to winners as rewards\r\n    // Side note : the reward scheme slightly differs from the culottes board game rules\r\n    // regarding the way decimal fractions of cakes to be given as rewards to winners are managed.\r\n    // The board game stipulates that fractions are rounded to the nearest integer and reward cakes\r\n    // are given in the descending order of winners (bigger winners first). But the code below\r\n    // states that only the integer part of reward cakes is taken into account. And the remaining\r\n    // reward cakes are put back into the Bastille. This slightly lessens the number of cakes\r\n    // rewarded to winners and slightly increases the number of cakes given to the Bastille.\r\n    // The main advantage is that it simplifies the algorithm a bit.\r\n    // But this rounding difference should not matter when dealing with Weis instead of real cakes.\r\n    uint remainingRewardCakes = loserScale.amount;\r\n    for (uint i = 0; i \u003C winnerScale.voters.length; i\u002B\u002B) {\r\n      address payable voter = winnerScale.voters[i];\r\n      // First distribute cakes from the winner scale, also known as winning cakes\r\n      // How many cakes did this voter put on the winnerScale ?\r\n      uint winningCakes = winnerScale.votes[voter];\r\n      // Send them back\r\n      winnerScale.votes[voter]=0;\r\n      // FIXME : handle the case of failure to send winningCakes\r\n      voter.send(winningCakes);\r\n      // How many cakes from the loser scale are to be rewarded to this winner citizen ?\r\n      // Rewards should be a share of the lost cakes that is proportionate to the fraction of\r\n      // winning cakes that were voted by this voting citizen, pretending that the Bastille\r\n      // itself took part in the vote.\r\n      uint rewardCakes = loserScale.amount * winningCakes / ( winnerScale.amount \u002B bastilleVote );\r\n      // Send their fair share of lost cakes as reward.\r\n      // FIXME : handle the failure of sending rewardCakes\r\n      voter.send(rewardCakes);\r\n      remainingRewardCakes -= rewardCakes;\r\n    }\r\n   \r\n    // distribute cakes to the Bastille\r\n    bastilleBalance \u002B= remainingRewardCakes;\r\n\r\n    // Empty the winner scale\r\n    winnerScale.amount = 0;\r\n\r\n    // Empty the loser scale\r\n    for (uint i = 0; i \u003C loserScale.voters.length; i\u002B\u002B) {\r\n      address payable voter = loserScale.voters[i];\r\n      loserScale.votes[voter]=0;\r\n    }\r\n    loserScale.amount = 0;\r\n\r\n  }\r\n\r\n  function closingLottery(address payable _citizen) private view returns (bool) {\r\n    if (testingMode == true) {\r\n      // always close when testing\r\n      return true;\r\n    }\r\n    // returns true with a 30% probability\r\n    // weighted by the time spent during that this distribution period since the last closing attempt\r\n    // returns false otherwise\r\n    uint randomHash = uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp)));\r\n    uint million = 1000000;\r\n    // random inteeger between 0 and 999999\r\n    uint randomInt = randomHash % million;\r\n    Trial storage trial = trials[_citizen];\r\n    uint blocksSince = block.number - trial.lastClosingAttemptBlock;\r\n    if (blocksSince \u003C distributionBlockPeriod) {\r\n      randomInt *= blocksSince / distributionBlockPeriod;\r\n    }\r\n    if(randomInt \u003C million * 30 / 100) {\r\n      return true;\r\n    }\r\n    return false;\r\n  }\r\n  \r\n  function distribute() public {\r\n    // Did the last distribution happen long enough ago ?\r\n    if  (block.number - lastDistributionBlockNumber \u003C distributionBlockPeriod) {\r\n      return;\r\n    }\r\n    // For each citizen trial\r\n    for (uint i = 0; i \u003C citizens.length; i\u002B\u002B) {\r\n      address payable citizen = citizens[i];\r\n      Trial memory trial = trials[citizen];\r\n      // Is the trial closed ?\r\n      // and Was the verdict \u0022sans-culotte\u0022 (citizen does match criteria according to winners) ?\r\n      // and Does the Bastille have more cakes left than the amount to be distributed ?\r\n      if (trial.opened == false \u0026\u0026\r\n          trial.matchesCriteria == true ) {\r\n        uint distributed = 0;\r\n        if (bastilleBalance \u003E= distributionAmount) {\r\n          distributed = distributionAmount;\r\n        } else {\r\n          if (locked == true) {\r\n            distributed = bastilleBalance;\r\n          }\r\n        }\r\n        // Then send this sans-culotte its fair share of Bastille cakes.\r\n        if (distributed \u003E 0) {\r\n          if (citizen.send(distributed)) {\r\n            bastilleBalance -= distributed;\r\n            emit Distribution(\u0027Distribution\u0027, citizen, distributed);\r\n          } else {\r\n            // sending failed, maybe citizen is a smart contract with an expensive fallback function ?\r\n            emit Distribution(\u0027Distribution\u0027, citizen, 0);\r\n          }\r\n        }\r\n      }\r\n    }\r\n    // Remember when this distribution happened.\r\n    lastDistributionBlockNumber = block.number;\r\n  }\r\n\r\n  function getScaleAmount(bool _vote, address _citizen) public view returns (uint){\r\n    Trial storage trial = trials[_citizen]; \r\n    if (_vote == true)\r\n      return trial.sansculotteScale.amount;\r\n    else\r\n      return trial.privilegedScale.amount;\r\n  }\r\n\r\n  function trialStatus(address _citizen) public view returns(bool opened, bool matchesCriteria, uint sansculotteScale, uint privilegedScale) {\r\n    Trial memory trial = trials[_citizen];\r\n    return (trial.opened, trial.matchesCriteria, trial.sansculotteScale.amount, trial.privilegedScale.amount);\r\n  }\r\n\r\n  function() payable external {\r\n    require(locked == false);\r\n    bastilleBalance \u002B= msg.value;\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022citizens\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_citizen\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022trialStatus\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022opened\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022matchesCriteria\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022sansculotteScale\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022privilegedScale\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022distributionBlockPeriod\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_vote\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022_citizen\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022vote\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_citizen\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022closeTrial\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022criteria\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022distributionAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022bastilleBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_vote\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022_citizen\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getScaleAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022testingMode\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022locked\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022distribute\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022hashtag\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022lock\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_criteria\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_hashtag\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_distributionBlockPeriod\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_distributionAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_testingMode\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_eventName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_citizen\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022TrialOpened\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_eventName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_citizen\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022TrialClosed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_eventName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_citizen\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_vote\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022VoteReceived\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_eventName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_citizen\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_distributionAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Distribution\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Revolution","CompilerVersion":"v0.5.0\u002Bcommit.1d4f565a","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"00000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000001680000000000000000000000000000000000000000000000000016345785d8a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000646120706572736f6e2077686f20686173206265656e206f6e65206f662074686520746f702033206d6f737420646573657276696e6720636f6e7472696275746f727320746f20746869732064617070206f76657220746865206c6173742037206461797300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001123546f7033436f6e7472696275746f7273000000000000000000000000000000","Library":"","SwarmSource":"bzzr://4b613f05bbb78419d9ae74c2bdbf438b3bf2cb3b749e5b94d4a1bfac7cfb9319"}]