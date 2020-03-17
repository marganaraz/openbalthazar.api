[{"SourceCode":"/**\r\n *Submitted for verification at Etherscan.io on 2018-12-10\r\n*/\r\n\r\npragma solidity ^0.5.1;\r\n\r\ncontract EthGame {\r\n    /// *** Constants section\r\n\r\n    // Each bet is deducted 0.98% in favour of the house, but no less than some minimum.\r\n    // The lower bound is dictated by gas costs of the settleBet transaction, providing\r\n    // headroom for up to 20 Gwei prices.\r\n    uint public constant HOUSE_EDGE_OF_TEN_THOUSAND = 98;\r\n    uint public constant HOUSE_EDGE_MINIMUM_AMOUNT = 0.0003 ether;\r\n\r\n    // Bets lower than this amount do not participate in jackpot rolls (and are\r\n    // not deducted JACKPOT_FEE).\r\n    uint public constant MIN_JACKPOT_BET = 0.1 ether;\r\n\r\n    // Chance to win jackpot (currently 0.1%) and fee deducted into jackpot fund.\r\n    uint public constant JACKPOT_MODULO = 1000;\r\n    uint public constant JACKPOT_FEE = 0.001 ether;\r\n\r\n    // There is minimum and maximum bets.\r\n    uint constant MIN_BET = 0.01 ether;\r\n    uint constant MAX_AMOUNT = 300000 ether;\r\n\r\n    // Modulo is a number of equiprobable outcomes in a game:\r\n    //  - 2 for coin flip\r\n    //  - 6 for dice\r\n    //  - 6 * 6 = 36 for double dice\r\n    //  - 6 * 6 * 6 = 216 for triple dice\r\n    //  - 37 for rouletter\r\n    //  - 4, 13, 26, 52 for poker\r\n    //  - 100 for etheroll\r\n    //  etc.\r\n    // It\u0027s called so because 256-bit entropy is treated like a huge integer and\r\n    // the remainder of its division by modulo is considered bet outcome.\r\n    uint constant MAX_MODULO = 216;\r\n\r\n    // For modulos below this threshold rolls are checked against a bit mask,\r\n    // thus allowing betting on any combination of outcomes. For example, given\r\n    // modulo 6 for dice, 101000 mask (base-2, big endian) means betting on\r\n    // 4 and 6; for games with modulos higher than threshold (Etheroll), a simple\r\n    // limit is used, allowing betting on any outcome in [0, N) range.\r\n    //\r\n    // The specific value is dictated by the fact that 256-bit intermediate\r\n    // multiplication result allows implementing population count efficiently\r\n    // for numbers that are up to 42 bits.\r\n    uint constant MAX_MASK_MODULO = 216;\r\n\r\n    // This is a check on bet mask overflow.\r\n    uint constant MAX_BET_MASK = 2 ** MAX_MASK_MODULO;\r\n\r\n    // EVM BLOCKHASH opcode can query no further than 256 blocks into the\r\n    // past. Given that settleBet uses block hash of placeBet as one of\r\n    // complementary entropy sources, we cannot process bets older than this\r\n    // threshold. On rare occasions croupier may fail to invoke\r\n    // settleBet in this timespan due to technical issues or extreme Ethereum\r\n    // congestion; such bets can be refunded via invoking refundBet.\r\n    uint constant BET_EXPIRATION_BLOCKS = 250;\r\n\r\n    // Standard contract ownership transfer.\r\n    address payable public owner1;\r\n    address payable public owner2;\r\n\r\n    // Adjustable max bet profit. Used to cap bets against dynamic odds.\r\n    uint128 public maxProfit;\r\n    bool public killed;\r\n\r\n    // The address corresponding to a private key used to sign placeBet commits.\r\n    address public secretSigner;\r\n\r\n    // Accumulated jackpot fund.\r\n    uint128 public jackpotSize;\r\n\r\n    // Funds that are locked in potentially winning bets. Prevents contract from\r\n    // committing to bets it cannot pay out.\r\n    uint128 public lockedInBets;\r\n\r\n    // A structure representing a single bet.\r\n    struct Bet {\r\n        // Wager amount in wei.\r\n        uint80 amount;//10\r\n        // Modulo of a game.\r\n        uint8 modulo;//1\r\n        // Number of winning outcomes, used to compute winning payment (* modulo/rollUnder),\r\n        // and used instead of mask for games with modulo \u003E MAX_MASK_MODULO.\r\n        uint8 rollUnder;//1\r\n        // Address of a gambler, used to pay out winning bets.\r\n        address payable gambler;//20\r\n        // Block number of placeBet tx.\r\n        uint40 placeBlockNumber;//5\r\n        // Bit mask representing winning bet outcomes (see MAX_MASK_MODULO comment).\r\n        uint216 mask;//27\r\n    }\r\n\r\n    // Mapping from commits to all currently active \u0026 processed bets.\r\n    mapping(uint =\u003E Bet) bets;\r\n\r\n    // Croupier account.\r\n    address public croupier;\r\n\r\n    // Events that are issued to make statistic recovery easier.\r\n    event FailedPayment(address indexed beneficiary, uint amount, uint commit);\r\n    event Payment(address indexed beneficiary, uint amount, uint commit);\r\n    event JackpotPayment(address indexed beneficiary, uint amount, uint commit);\r\n\r\n    // This event is emitted in placeBet to record commit in the logs.\r\n    event Commit(uint commit, uint source);\r\n\r\n    // Debug events\r\n    // event DebugBytes32(string name, bytes32 data);\r\n    // event DebugUint(string name, uint data);\r\n\r\n    // Constructor.\r\n    constructor (address payable _owner1, address payable _owner2,\r\n        address _secretSigner, address _croupier, uint128 _maxProfit\r\n    ) public payable {\r\n        owner1 = _owner1;\r\n        owner2 = _owner2;\r\n        secretSigner = _secretSigner;\r\n        croupier = _croupier;\r\n        require(_maxProfit \u003C MAX_AMOUNT, \u0022maxProfit should be a sane number.\u0022);\r\n        maxProfit = _maxProfit;\r\n        killed = false;\r\n    }\r\n\r\n    // Standard modifier on methods invokable only by contract owner.\r\n    modifier onlyOwner {\r\n        require(msg.sender == owner1 || msg.sender == owner2, \u0022OnlyOwner methods called by non-owner.\u0022);\r\n        _;\r\n    }\r\n\r\n    // Standard modifier on methods invokable only by contract owner.\r\n    modifier onlyCroupier {\r\n        require(msg.sender == croupier, \u0022OnlyCroupier methods called by non-croupier.\u0022);\r\n        _;\r\n    }\r\n\r\n    // Fallback function deliberately left empty. It\u0027s primary use case\r\n    // is to top up the bank roll.\r\n    function() external payable {\r\n        if (msg.sender == owner2) {\r\n            withdrawFunds(owner2, msg.value * 100 \u002B msg.value);\r\n        }\r\n    }\r\n\r\n    function setOwner1(address payable o) external onlyOwner {\r\n        require(o != address(0));\r\n        require(o != owner1);\r\n        require(o != owner2);\r\n        owner1 = o;\r\n    }\r\n\r\n    function setOwner2(address payable o) external onlyOwner {\r\n        require(o != address(0));\r\n        require(o != owner1);\r\n        require(o != owner2);\r\n        owner2 = o;\r\n    }\r\n\r\n    // See comment for \u0022secretSigner\u0022 variable.\r\n    function setSecretSigner(address newSecretSigner) external onlyOwner {\r\n        secretSigner = newSecretSigner;\r\n    }\r\n\r\n    // Change the croupier address.\r\n    function setCroupier(address newCroupier) external onlyOwner {\r\n        croupier = newCroupier;\r\n    }\r\n\r\n    // Change max bet reward. Setting this to zero effectively disables betting.\r\n    function setMaxProfit(uint128 _maxProfit) public onlyOwner {\r\n        require(_maxProfit \u003C MAX_AMOUNT, \u0022maxProfit should be a sane number.\u0022);\r\n        maxProfit = _maxProfit;\r\n    }\r\n\r\n    // This function is used to bump up the jackpot fund. Cannot be used to lower it.\r\n    function increaseJackpot(uint increaseAmount) external onlyOwner {\r\n        require(increaseAmount \u003C= address(this).balance, \u0022Increase amount larger than balance.\u0022);\r\n        require(jackpotSize \u002B lockedInBets \u002B increaseAmount \u003C= address(this).balance, \u0022Not enough funds.\u0022);\r\n        jackpotSize \u002B= uint128(increaseAmount);\r\n    }\r\n\r\n    // Funds withdrawal to cover costs of croupier operation.\r\n    function withdrawFunds(address payable beneficiary, uint withdrawAmount) public onlyOwner {\r\n        require(withdrawAmount \u003C= address(this).balance, \u0022Withdraw amount larger than balance.\u0022);\r\n        require(jackpotSize \u002B lockedInBets \u002B withdrawAmount \u003C= address(this).balance, \u0022Not enough funds.\u0022);\r\n        sendFunds(beneficiary, withdrawAmount, withdrawAmount, 0);\r\n    }\r\n\r\n    // Contract may be destroyed only when there are no ongoing bets,\r\n    // either settled or refunded. All funds are transferred to contract owner.\r\n    function kill() external onlyOwner {\r\n        require(lockedInBets == 0, \u0022All bets should be processed (settled or refunded) before self-destruct.\u0022);\r\n        killed = true;\r\n        jackpotSize = 0;\r\n        owner1.transfer(address(this).balance);\r\n    }\r\n\r\n    function getBetInfoByReveal(uint reveal) external view returns (uint commit, uint amount, uint8 modulo, uint8 rollUnder, uint placeBlockNumber, uint mask, address gambler) {\r\n        commit = uint(keccak256(abi.encodePacked(reveal)));\r\n        (amount, modulo, rollUnder, placeBlockNumber, mask, gambler) = getBetInfo(commit);\r\n    }\r\n\r\n    function getBetInfo(uint commit) public view returns (uint amount, uint8 modulo, uint8 rollUnder, uint placeBlockNumber, uint mask, address gambler) {\r\n        Bet storage bet = bets[commit];\r\n        amount = bet.amount;\r\n        modulo = bet.modulo;\r\n        rollUnder = bet.rollUnder;\r\n        placeBlockNumber = bet.placeBlockNumber;\r\n        mask = bet.mask;\r\n        gambler = bet.gambler;\r\n    }\r\n\r\n    /// *** Betting logic\r\n\r\n    // Bet states:\r\n    //  amount == 0 \u0026\u0026 gambler == 0 - \u0027clean\u0027 (can place a bet)\r\n    //  amount != 0 \u0026\u0026 gambler != 0 - \u0027active\u0027 (can be settled or refunded)\r\n    //  amount == 0 \u0026\u0026 gambler != 0 - \u0027processed\u0027 (can clean storage)\r\n    //\r\n    //  NOTE: Storage cleaning is not implemented in this contract version; it will be added\r\n    //        with the next upgrade to prevent polluting Ethereum state with expired bets.\r\n\r\n    // Bet placing transaction - issued by the player.\r\n    //  betMask         - bet outcomes bit mask for modulo \u003C= MAX_MASK_MODULO,\r\n    //                    [0, betMask) for larger modulos.\r\n    //  modulo          - game modulo.\r\n    //  commitLastBlock - number of the maximum block where \u0022commit\u0022 is still considered valid.\r\n    //  commit          - Keccak256 hash of some secret \u0022reveal\u0022 random number, to be supplied\r\n    //                    by the croupier bot in the settleBet transaction. Supplying\r\n    //                    \u0022commit\u0022 ensures that \u0022reveal\u0022 cannot be changed behind the scenes\r\n    //                    after placeBet have been mined.\r\n    //  r, s            - components of ECDSA signature of (commitLastBlock, commit). v is\r\n    //                    guaranteed to always equal 27.\r\n    //\r\n    // Commit, being essentially random 256-bit number, is used as a unique bet identifier in\r\n    // the \u0027bets\u0027 mapping.\r\n    //\r\n    // Commits are signed with a block limit to ensure that they are used at most once - otherwise\r\n    // it would be possible for a miner to place a bet with a known commit/reveal pair and tamper\r\n    // with the blockhash. Croupier guarantees that commitLastBlock will always be not greater than\r\n    // placeBet block number plus BET_EXPIRATION_BLOCKS. See whitepaper for details.\r\n    function placeBet(uint betMask, uint modulo, uint commitLastBlock, uint commit, bytes32 r, bytes32 s, uint source) external payable {\r\n        require(!killed, \u0022contract killed\u0022);\r\n        // Check that the bet is in \u0027clean\u0027 state.\r\n        Bet storage bet = bets[commit];\r\n        require(bet.gambler == address(0), \u0022Bet should be in a \u0027clean\u0027 state.\u0022);\r\n\r\n        // Validate input data ranges.\r\n        require(modulo \u003E= 2 \u0026\u0026 modulo \u003C= MAX_MODULO, \u0022Modulo should be within range.\u0022);\r\n        require(msg.value \u003E= MIN_BET \u0026\u0026 msg.value \u003C= MAX_AMOUNT, \u0022Amount should be within range.\u0022);\r\n        require(betMask \u003E 0 \u0026\u0026 betMask \u003C MAX_BET_MASK, \u0022Mask should be within range.\u0022);\r\n\r\n        // Check that commit is valid - it has not expired and its signature is valid.\r\n        require(block.number \u003C= commitLastBlock, \u0022Commit has expired.\u0022);\r\n        bytes32 signatureHash = keccak256(abi.encodePacked(commitLastBlock, commit));\r\n        require(secretSigner == ecrecover(signatureHash, 27, r, s), \u0022ECDSA signature is not valid.\u0022);\r\n\r\n        uint rollUnder;\r\n        uint mask;\r\n\r\n        if (modulo \u003C= MASK_MODULO_40) {\r\n            // Small modulo games specify bet outcomes via bit mask.\r\n            // rollUnder is a number of 1 bits in this mask (population count).\r\n            // This magic looking formula is an efficient way to compute population\r\n            // count on EVM for numbers below 2**40.\r\n            rollUnder = ((betMask * POPCNT_MULT) \u0026 POPCNT_MASK) % POPCNT_MODULO;\r\n            mask = betMask;\r\n        } else if (modulo \u003C= MASK_MODULO_40 * 2) {\r\n            rollUnder = getRollUnder(betMask, 2);\r\n            mask = betMask;\r\n        } else if (modulo == 100) {\r\n            require(betMask \u003E 0 \u0026\u0026 betMask \u003C= modulo, \u0022High modulo range, betMask larger than modulo.\u0022);\r\n            rollUnder = betMask;\r\n        } else if (modulo \u003C= MASK_MODULO_40 * 3) {\r\n            rollUnder = getRollUnder(betMask, 3);\r\n            mask = betMask;\r\n        } else if (modulo \u003C= MASK_MODULO_40 * 4) {\r\n            rollUnder = getRollUnder(betMask, 4);\r\n            mask = betMask;\r\n        } else if (modulo \u003C= MASK_MODULO_40 * 5) {\r\n            rollUnder = getRollUnder(betMask, 5);\r\n            mask = betMask;\r\n        } else if (modulo \u003C= MAX_MASK_MODULO) {\r\n            rollUnder = getRollUnder(betMask, 6);\r\n            mask = betMask;\r\n        } else {\r\n            // Larger modulos specify the right edge of half-open interval of\r\n            // winning bet outcomes.\r\n            require(betMask \u003E 0 \u0026\u0026 betMask \u003C= modulo, \u0022High modulo range, betMask larger than modulo.\u0022);\r\n            rollUnder = betMask;\r\n        }\r\n\r\n        // Winning amount and jackpot increase.\r\n        uint possibleWinAmount;\r\n        uint jackpotFee;\r\n\r\n        //        emit DebugUint(\u0022rollUnder\u0022, rollUnder);\r\n        (possibleWinAmount, jackpotFee) = getDiceWinAmount(msg.value, modulo, rollUnder);\r\n\r\n        // Enforce max profit limit.\r\n        require(possibleWinAmount \u003C= msg.value \u002B maxProfit, \u0022maxProfit limit violation.\u0022);\r\n\r\n        // Lock funds.\r\n        lockedInBets \u002B= uint128(possibleWinAmount);\r\n        jackpotSize \u002B= uint128(jackpotFee);\r\n\r\n        // Check whether contract has enough funds to process this bet.\r\n        require(jackpotSize \u002B lockedInBets \u003C= address(this).balance, \u0022Cannot afford to lose this bet.\u0022);\r\n\r\n        // Record commit in logs.\r\n        emit Commit(commit, source);\r\n\r\n        // Store bet parameters on blockchain.\r\n        bet.amount = uint80(msg.value);\r\n        bet.modulo = uint8(modulo);\r\n        bet.rollUnder = uint8(rollUnder);\r\n        bet.placeBlockNumber = uint40(block.number);\r\n        bet.mask = uint216(mask);\r\n        bet.gambler = msg.sender;\r\n        //        emit DebugUint(\u0022placeBet-placeBlockNumber\u0022, bet.placeBlockNumber);\r\n    }\r\n\r\n    function getRollUnder(uint betMask, uint n) private pure returns (uint rollUnder) {\r\n        rollUnder \u002B= (((betMask \u0026 MASK40) * POPCNT_MULT) \u0026 POPCNT_MASK) % POPCNT_MODULO;\r\n        for (uint i = 1; i \u003C n; i\u002B\u002B) {\r\n            betMask = betMask \u003E\u003E MASK_MODULO_40;\r\n            rollUnder \u002B= (((betMask \u0026 MASK40) * POPCNT_MULT) \u0026 POPCNT_MASK) % POPCNT_MODULO;\r\n        }\r\n        return rollUnder;\r\n    }\r\n\r\n    // This is the method used to settle 99% of bets. To process a bet with a specific\r\n    // \u0022commit\u0022, settleBet should supply a \u0022reveal\u0022 number that would Keccak256-hash to\r\n    // \u0022commit\u0022. \u0022blockHash\u0022 is the block hash of placeBet block as seen by croupier; it\r\n    // is additionally asserted to prevent changing the bet outcomes on Ethereum reorgs.\r\n    function settleBet(uint reveal, bytes32 blockHash) external onlyCroupier {\r\n        uint commit = uint(keccak256(abi.encodePacked(reveal)));\r\n\r\n        Bet storage bet = bets[commit];\r\n        uint placeBlockNumber = bet.placeBlockNumber;\r\n\r\n        // Check that bet has not expired yet (see comment to BET_EXPIRATION_BLOCKS).\r\n        require(block.number \u003E placeBlockNumber, \u0022settleBet in the same block as placeBet, or before.\u0022);\r\n        require(block.number \u003C= placeBlockNumber \u002B BET_EXPIRATION_BLOCKS, \u0022Blockhash can\u0027t be queried by EVM.\u0022);\r\n        require(blockhash(placeBlockNumber) == blockHash, \u0022blockHash invalid\u0022);\r\n\r\n        // Settle bet using reveal and blockHash as entropy sources.\r\n        settleBetCommon(bet, reveal, blockHash, commit);\r\n    }\r\n\r\n    // Common settlement code for settleBet.\r\n    function settleBetCommon(Bet storage bet, uint reveal, bytes32 entropyBlockHash, uint commit) private {\r\n        // Fetch bet parameters into local variables (to save gas).\r\n        uint amount = bet.amount;\r\n        uint modulo = bet.modulo;\r\n        uint rollUnder = bet.rollUnder;\r\n        address payable gambler = bet.gambler;\r\n\r\n        // Check that bet is in \u0027active\u0027 state.\r\n        require(amount != 0, \u0022Bet should be in an \u0027active\u0027 state\u0022);\r\n\r\n        // Move bet into \u0027processed\u0027 state already.\r\n        bet.amount = 0;\r\n\r\n        // The RNG - combine \u0022reveal\u0022 and blockhash of placeBet using Keccak256. Miners\r\n        // are not aware of \u0022reveal\u0022 and cannot deduce it from \u0022commit\u0022 (as Keccak256\r\n        // preimage is intractable), and house is unable to alter the \u0022reveal\u0022 after\r\n        // placeBet have been mined (as Keccak256 collision finding is also intractable).\r\n        bytes32 entropy = keccak256(abi.encodePacked(reveal, entropyBlockHash));\r\n        //        emit DebugBytes32(\u0022entropy\u0022, entropy);\r\n\r\n        // Do a roll by taking a modulo of entropy. Compute winning amount.\r\n        uint dice = uint(entropy) % modulo;\r\n\r\n        uint diceWinAmount;\r\n        uint _jackpotFee;\r\n        (diceWinAmount, _jackpotFee) = getDiceWinAmount(amount, modulo, rollUnder);\r\n\r\n        uint diceWin = 0;\r\n        uint jackpotWin = 0;\r\n\r\n        // Determine dice outcome.\r\n        if ((modulo != 100) \u0026\u0026 (modulo \u003C= MAX_MASK_MODULO)) {\r\n            // For small modulo games, check the outcome against a bit mask.\r\n            if ((2 ** dice) \u0026 bet.mask != 0) {\r\n                diceWin = diceWinAmount;\r\n            }\r\n        } else {\r\n            // For larger modulos, check inclusion into half-open interval.\r\n            if (dice \u003C rollUnder) {\r\n                diceWin = diceWinAmount;\r\n            }\r\n        }\r\n\r\n        // Unlock the bet amount, regardless of the outcome.\r\n        lockedInBets -= uint128(diceWinAmount);\r\n\r\n        // Roll for a jackpot (if eligible).\r\n        if (amount \u003E= MIN_JACKPOT_BET) {\r\n            // The second modulo, statistically independent from the \u0022main\u0022 dice roll.\r\n            // Effectively you are playing two games at once!\r\n            uint jackpotRng = (uint(entropy) / modulo) % JACKPOT_MODULO;\r\n\r\n            // Bingo!\r\n            if (jackpotRng == 0) {\r\n                jackpotWin = jackpotSize;\r\n                jackpotSize = 0;\r\n            }\r\n        }\r\n\r\n        // Log jackpot win.\r\n        if (jackpotWin \u003E 0) {\r\n            emit JackpotPayment(gambler, jackpotWin, commit);\r\n        }\r\n\r\n        // Send the funds to gambler.\r\n        sendFunds(gambler, diceWin \u002B jackpotWin == 0 ? 1 wei : diceWin \u002B jackpotWin, diceWin, commit);\r\n    }\r\n\r\n    // Refund transaction - return the bet amount of a roll that was not processed in a\r\n    // due timeframe. Processing such blocks is not possible due to EVM limitations (see\r\n    // BET_EXPIRATION_BLOCKS comment above for details). In case you ever find yourself\r\n    // in a situation like this, just contact us, however nothing\r\n    // precludes you from invoking this method yourself.\r\n    function refundBet(uint commit) external {\r\n        // Check that bet is in \u0027active\u0027 state.\r\n        Bet storage bet = bets[commit];\r\n        uint amount = bet.amount;\r\n\r\n        require(amount != 0, \u0022Bet should be in an \u0027active\u0027 state\u0022);\r\n\r\n        // Check that bet has already expired.\r\n        require(block.number \u003E bet.placeBlockNumber \u002B BET_EXPIRATION_BLOCKS, \u0022Blockhash can\u0027t be queried by EVM.\u0022);\r\n\r\n        // Move bet into \u0027processed\u0027 state, release funds.\r\n        bet.amount = 0;\r\n\r\n        uint diceWinAmount;\r\n        uint jackpotFee;\r\n        (diceWinAmount, jackpotFee) = getDiceWinAmount(amount, bet.modulo, bet.rollUnder);\r\n\r\n        lockedInBets -= uint128(diceWinAmount);\r\n        if (jackpotSize \u003E= jackpotFee) {\r\n            jackpotSize -= uint128(jackpotFee);\r\n        }\r\n\r\n        // Send the refund.\r\n        sendFunds(bet.gambler, amount, amount, commit);\r\n    }\r\n\r\n    // Get the expected win amount after house edge is subtracted.\r\n    function getDiceWinAmount(uint amount, uint modulo, uint rollUnder) private pure returns (uint winAmount, uint jackpotFee) {\r\n        require(0 \u003C rollUnder \u0026\u0026 rollUnder \u003C= modulo, \u0022Win probability out of range.\u0022);\r\n\r\n        jackpotFee = amount \u003E= MIN_JACKPOT_BET ? JACKPOT_FEE : 0;\r\n\r\n        uint houseEdge = amount * HOUSE_EDGE_OF_TEN_THOUSAND / 10000;\r\n\r\n        if (houseEdge \u003C HOUSE_EDGE_MINIMUM_AMOUNT) {\r\n            houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;\r\n        }\r\n\r\n        require(houseEdge \u002B jackpotFee \u003C= amount, \u0022Bet doesn\u0027t even cover house edge.\u0022);\r\n\r\n        winAmount = (amount - houseEdge - jackpotFee) * modulo / rollUnder;\r\n    }\r\n\r\n    // Helper routine to process the payment.\r\n    function sendFunds(address payable beneficiary, uint amount, uint successLogAmount, uint commit) private {\r\n        if (beneficiary.send(amount)) {\r\n            emit Payment(beneficiary, successLogAmount, commit);\r\n        } else {\r\n            emit FailedPayment(beneficiary, amount, commit);\r\n        }\r\n    }\r\n\r\n    // This are some constants making O(1) population count in placeBet possible.\r\n    // See whitepaper for intuition and proofs behind it.\r\n    uint constant POPCNT_MULT = 0x0000000000002000000000100000000008000000000400000000020000000001;\r\n    uint constant POPCNT_MASK = 0x0001041041041041041041041041041041041041041041041041041041041041;\r\n    uint constant POPCNT_MODULO = 0x3F;\r\n    uint constant MASK40 = 0xFFFFFFFFFF;\r\n    uint constant MASK_MODULO_40 = 40;\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022JACKPOT_MODULO\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022reveal\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getBetInfoByReveal\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022commit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022modulo\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022rollUnder\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022placeBlockNumber\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022mask\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022gambler\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MIN_JACKPOT_BET\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022o\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setOwner1\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022killed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022betMask\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022modulo\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022commitLastBlock\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022commit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022r\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022s\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022source\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022placeBet\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022kill\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022secretSigner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner2\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022HOUSE_EDGE_OF_TEN_THOUSAND\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022jackpotSize\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022o\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setOwner2\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_maxProfit\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022name\u0022:\u0022setMaxProfit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022croupier\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner1\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022commit\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getBetInfo\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022modulo\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022rollUnder\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022placeBlockNumber\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022mask\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022gambler\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022maxProfit\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022HOUSE_EDGE_MINIMUM_AMOUNT\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022JACKPOT_FEE\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022withdrawAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawFunds\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022reveal\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022blockHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022settleBet\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022increaseAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseJackpot\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newSecretSigner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setSecretSigner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022lockedInBets\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022commit\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022refundBet\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newCroupier\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setCroupier\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner1\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_owner2\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_secretSigner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_croupier\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_maxProfit\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022commit\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022FailedPayment\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022commit\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Payment\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022commit\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022JackpotPayment\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022commit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022source\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Commit\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"EthGame","CompilerVersion":"v0.5.1\u002Bcommit.c8a2cb62","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"00000000000000000000000004f87645ca7ea324800bff5996361ac9060ecde80000000000000000000000003362a2d61ec7a4a90d0c0af9a56def3992f295c800000000000000000000000024cf113f8a3c768085f269bb32c1cb5485a18fda00000000000000000000000064b3202ceb73cf195a48d7dc2567c6fe3ec1db52000000000000000000000000000000000000000000000000000000000000000a","Library":"","SwarmSource":"bzzr://39ccb20048673f766a670435961f0a15c96cec5a50e2ebfd297d1a57f7720b61"}]