[{"SourceCode":"/**\r\n *Submitted for verification at Etherscan.io on 2019-06-20\r\n*/\r\n\r\npragma solidity ^0.5.7;\r\n\r\n// File: node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Unsigned math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Multiplies two unsigned integers, reverts on overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Adds two unsigned integers, reverts on overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),\r\n     * reverts when dividing by zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n     * account.\r\n     */\r\n    constructor () internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @return the address of the owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner());\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @return true if \u0060msg.sender\u0060 is the owner of the contract.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to relinquish control of the contract.\r\n     * It will not be possible to call the functions with the \u0060onlyOwner\u0060\r\n     * modifier anymore.\r\n     * @notice Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\n// File: node_modules/openzeppelin-solidity/contracts/access/Roles.sol\r\n\r\n/**\r\n * @title Roles\r\n * @dev Library for managing addresses assigned to a Role.\r\n */\r\nlibrary Roles {\r\n    struct Role {\r\n        mapping (address =\u003E bool) bearer;\r\n    }\r\n\r\n    /**\r\n     * @dev give an account access to this role\r\n     */\r\n    function add(Role storage role, address account) internal {\r\n        require(account != address(0));\r\n        require(!has(role, account));\r\n\r\n        role.bearer[account] = true;\r\n    }\r\n\r\n    /**\r\n     * @dev remove an account\u0027s access to this role\r\n     */\r\n    function remove(Role storage role, address account) internal {\r\n        require(account != address(0));\r\n        require(has(role, account));\r\n\r\n        role.bearer[account] = false;\r\n    }\r\n\r\n    /**\r\n     * @dev check if an account has this role\r\n     * @return bool\r\n     */\r\n    function has(Role storage role, address account) internal view returns (bool) {\r\n        require(account != address(0));\r\n        return role.bearer[account];\r\n    }\r\n}\r\n\r\n// File: node_modules/openzeppelin-solidity/contracts/access/roles/PauserRole.sol\r\n\r\ncontract PauserRole {\r\n    using Roles for Roles.Role;\r\n\r\n    event PauserAdded(address indexed account);\r\n    event PauserRemoved(address indexed account);\r\n\r\n    Roles.Role private _pausers;\r\n\r\n    constructor () internal {\r\n        _addPauser(msg.sender);\r\n    }\r\n\r\n    modifier onlyPauser() {\r\n        require(isPauser(msg.sender));\r\n        _;\r\n    }\r\n\r\n    function isPauser(address account) public view returns (bool) {\r\n        return _pausers.has(account);\r\n    }\r\n\r\n    function addPauser(address account) public onlyPauser {\r\n        _addPauser(account);\r\n    }\r\n\r\n    function renouncePauser() public {\r\n        _removePauser(msg.sender);\r\n    }\r\n\r\n    function _addPauser(address account) internal {\r\n        _pausers.add(account);\r\n        emit PauserAdded(account);\r\n    }\r\n\r\n    function _removePauser(address account) internal {\r\n        _pausers.remove(account);\r\n        emit PauserRemoved(account);\r\n    }\r\n}\r\n\r\n// File: contracts/Pausable.sol\r\n\r\n/**\r\n * @title Pausable\r\n * @dev Base contract which allows children to implement an emergency stop mechanism.\r\n */\r\ncontract Pausable is PauserRole {\r\n\r\n    uint256 public selfDestructAt;\r\n    event Paused(address account);\r\n    event Unpaused(address account);\r\n\r\n    bool private _paused;\r\n\r\n    constructor () internal {\r\n        _paused = false;\r\n    }\r\n\r\n    /**\r\n     * @return true if the contract is paused, false otherwise.\r\n     */\r\n    function paused() public view returns (bool) {\r\n        return _paused;\r\n    }\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is not paused.\r\n     */\r\n    modifier whenNotPaused() {\r\n        require(!_paused);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is paused.\r\n     */\r\n    modifier whenPaused() {\r\n        require(_paused);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev called by the owner to pause, triggers stopped state\r\n     */\r\n    function pause(uint256 selfDestructPeriod) public onlyPauser whenNotPaused {\r\n        _paused = true;\r\n        selfDestructAt = now \u002B selfDestructPeriod;\r\n        emit Paused(msg.sender);\r\n    }\r\n\r\n    /**\r\n     * @dev called by the owner to unpause, returns to normal state\r\n     */\r\n    function unpause() public onlyPauser whenPaused {\r\n        _paused = false;\r\n        emit Unpaused(msg.sender);\r\n    }\r\n}\r\n\r\n// File: contracts/PausableDestroyable.sol\r\n\r\ncontract PausableDestroyable is Pausable {\r\n\r\n    function destroy() public whenPaused {\r\n        require(selfDestructAt \u003C= now);\r\n        // send remaining funds to address 0, to prevent the owner from taking the funds himself (and steal the funds from the vault)\r\n        selfdestruct(address(0));\r\n    }\r\n}\r\n\r\n// File: contracts/ubivault.sol\r\n\r\n///@title UBIVault, version 0.2\r\n///@author AXVECO B.V., commisioned by THINSIA\r\n/**\r\n * The UBIVault smart contract allows parties to fund the fault with money (Ether) and citizens to register and claim an UBI.\r\n * The vault makes a payout maximally once per weeks when AE/AC \u003E= AB, where\r\n *  AE is 95% of the total deposited money (5% is for the maintenancePool)\r\n *  AC is the amountOfCitizens\r\n *  AB is Amount of AmountOfBasicIncome\r\n*/\r\ncontract UBIVault is Ownable, PausableDestroyable {\r\n\r\n    using SafeMath for uint256;\r\n\r\n    mapping(address =\u003E uint256) public rightFromPaymentCycle;\r\n    mapping(bytes32 =\u003E bool) public useablePasswordHashes;\r\n    mapping(bytes32 =\u003E bool) public usedPasswordHashes;\r\n    uint8 public amountOfBasicIncomeCanBeIncreased;\r\n    uint256 public amountOfBasicIncome;\r\n    uint256 public amountOfCitizens;\r\n    uint256 public euroCentInWei;\r\n    uint256 public availableEther;\r\n    address payable public maintenancePool;\r\n    uint256 public minimumPeriod;\r\n    uint256 public promisedEther;\r\n    uint256 lastPayout;\r\n    uint256[] public paymentsCycle;\r\n\r\n    event LogUseablePasswordCreated(bytes32 passwordHash);\r\n    event LogUBICreated(uint256 adjustedEuroCentInWei, uint256 totalamountOfBasicIncomeInWei, uint256 amountOfCitizens, uint8 amountOfBasicIncomeCanBeIncreased, uint256 paymentsCycle);\r\n    event LogCitizenRegistered(address newCitizen);\r\n    event LogPasswordUsed(bytes32 password, bytes32 passwordHash);\r\n    event LogVaultSponsored(address payee, bytes32 message, uint256 amount);\r\n    event LogUBIClaimed(address indexed caller, uint256 income, address indexed citizen);\r\n\r\n    ///@dev we set the first value in the paymentsCycle array, because 0 is the default value for the rightFromPaymentCycle for all addresses.\r\n    constructor(\r\n        uint256 initialAB,\r\n        uint256 initialMinimumPeriod,\r\n        uint256 initialEuroCentInWei,\r\n        address payable _maintenancePool\r\n    ) public {\r\n        minimumPeriod = initialMinimumPeriod;\r\n        euroCentInWei = initialEuroCentInWei;\r\n        amountOfBasicIncome = initialAB;\r\n        maintenancePool = _maintenancePool;\r\n        paymentsCycle.push(0);\r\n    }\r\n\r\n    function claimUBIOwner(address payable[] memory citizens, bool onlyOne) public onlyOwner returns(bool) {\r\n        bool allRequestedCitizensGotPayout = true;\r\n        for(uint256 i = 0; i \u003C citizens.length; i\u002B\u002B) {\r\n            if(!claimUBI(citizens[i], onlyOne)) {\r\n              allRequestedCitizensGotPayout = false;\r\n            }\r\n        }\r\n        return allRequestedCitizensGotPayout;\r\n    }\r\n\r\n    function claimUBIPublic(bool onlyOne) public {\r\n        require(claimUBI(msg.sender, onlyOne), \u0022There is no claimable UBI available for your account\u0022);\r\n    }\r\n\r\n    function createUseablePasswords(bytes32[] memory _useablePasswordHashes) public onlyOwner {\r\n        for(uint256 i = 0; i \u003C _useablePasswordHashes.length; i\u002B\u002B) {\r\n            bytes32 usablePasswordHash = _useablePasswordHashes[i];\r\n            require(!useablePasswordHashes[usablePasswordHash], \u0022One of your useablePasswords was already registered\u0022);\r\n            useablePasswordHashes[usablePasswordHash] = true;\r\n            emit LogUseablePasswordCreated(usablePasswordHash);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * Allows anybody to request making an UBI available for the citizens when the lastPayout is more than one week ago and\r\n     * AE / AC \u003E= AB\r\n    */\r\n    /**\r\n     * decreases the variable availableEther (which is increased in the function sponsorVault)\r\n     * increases the variable promisedEther (which is decreased in the function claimUBI)\r\n     * increases the lastPayout variable to the current time\r\n     * sets the ether promised during this cycle as a new value in the paymentsCycle array (which is also set in the constructor)\r\n    */\r\n    function createUBI(uint256 adjustedEuroCentInWei) public onlyOwner {\r\n//        uint256 adjustedDollarInWei = adjustedEuroCentInWei.mul(100);\r\n        uint256 totalamountOfBasicIncomeInWei = adjustedEuroCentInWei.mul(amountOfBasicIncome).mul(amountOfCitizens);\r\n        // We only allow a fluctuation of 5% per UBI creation\r\n//        require(adjustedDollarInWei \u003E= euroCentInWei.mul(95) \u0026\u0026 adjustedDollarInWei \u003C= euroCentInWei.mul(105), \u0022The exchange rate can only fluctuate \u002B- 5% per createUBI call\u0022);\r\n        require(lastPayout \u003C= now - minimumPeriod, \u0022You should wait the required time in between createUBI calls\u0022);\r\n        require(availableEther.div(adjustedEuroCentInWei).div(amountOfCitizens) \u003E= amountOfBasicIncome, \u0022There are not enough funds in the UBI contract to sustain another UBI\u0022);\r\n        euroCentInWei = adjustedEuroCentInWei;\r\n        availableEther = availableEther.sub(totalamountOfBasicIncomeInWei);\r\n        promisedEther = promisedEther.add(totalamountOfBasicIncomeInWei);\r\n\r\n        paymentsCycle.push(adjustedEuroCentInWei.mul(amountOfBasicIncome));\r\n        lastPayout = now;\r\n\r\n        // if there is enough income available (7$)\r\n        if(availableEther \u003E= adjustedEuroCentInWei.mul(700).mul(amountOfCitizens)) {\r\n            // and we increased it twice before,\r\n            if(amountOfBasicIncomeCanBeIncreased == 2) {\r\n                amountOfBasicIncomeCanBeIncreased = 0;\r\n                amountOfBasicIncome = amountOfBasicIncome.add(700);\r\n            // and we did not increase it twice before\r\n            } else {\r\n                amountOfBasicIncomeCanBeIncreased\u002B\u002B;\r\n            }\r\n        // if there is not enough income available and we increased the counter prior to this function call\r\n        } else if(amountOfBasicIncomeCanBeIncreased != 0) {\r\n            amountOfBasicIncomeCanBeIncreased == 0;\r\n        }\r\n        emit LogUBICreated(adjustedEuroCentInWei, totalamountOfBasicIncomeInWei, amountOfCitizens, amountOfBasicIncomeCanBeIncreased, paymentsCycle.length - 1);\r\n    }\r\n\r\n    function registerCitizenOwner(address newCitizen) public onlyOwner {\r\n        require(newCitizen != address(0) , \u0022NewCitizen cannot be the 0 address\u0022);\r\n        registerCitizen(newCitizen);\r\n    }\r\n\r\n    function registerCitizenPublic(bytes32 password) public {\r\n        bytes32 passwordHash = keccak256(abi.encodePacked(password));\r\n        require(useablePasswordHashes[passwordHash] \u0026\u0026 !usedPasswordHashes[passwordHash], \u0022Password is not known or already used\u0022);\r\n        usedPasswordHashes[passwordHash] = true;\r\n        registerCitizen(msg.sender);\r\n        emit LogPasswordUsed(password, passwordHash);\r\n    }\r\n\r\n    /**\r\n     * Increases the availableEther with 95% of the transfered value, the remainder is available for maintenancePool.\r\n     * AE becomes available for the citizens in the next paymentsCycle\r\n    */\r\n    ///@dev availableEther is truncated (rounded down), the remainder becomes available for maintenancePool\r\n    function sponsorVault(bytes32 message) public payable whenNotPaused {\r\n        moneyReceived(message);\r\n    }\r\n\r\n    // Allows citizens to claim their UBI which was made available since the last time they claimed it (or have registered, whichever is bigger)\r\n    /**\r\n     * \r\n     * increases the rightFromPaymentCycle for the caller (also increased in the function registerCitizen)\r\n     * decreases the promisedEther (which is increased in the function createUBI)\r\n    */\r\n    function claimUBI(address payable citizen, bool onlyOne) internal returns(bool) {\r\n        require(rightFromPaymentCycle[citizen] != 0, \u0022Citizen not registered\u0022);\r\n        uint256 incomeClaims = paymentsCycle.length - rightFromPaymentCycle[citizen];\r\n        uint256 income;\r\n        uint256 paymentsCycleLength = paymentsCycle.length;\r\n        if(onlyOne \u0026\u0026 incomeClaims \u003E 0) {\r\n          income = paymentsCycle[paymentsCycleLength - incomeClaims];\r\n        } else if(incomeClaims == 1) {\r\n            income = paymentsCycle[paymentsCycleLength - 1];\r\n        } else if(incomeClaims \u003E 1) {\r\n            for(uint256 index; index \u003C incomeClaims; index\u002B\u002B) {\r\n                income = income.add(paymentsCycle[paymentsCycleLength - incomeClaims \u002B index]);\r\n            }\r\n        } else {\r\n            return false;\r\n        }\r\n        rightFromPaymentCycle[citizen] = paymentsCycleLength;\r\n        promisedEther = promisedEther.sub(income);\r\n        citizen.transfer(income);\r\n        emit LogUBIClaimed(msg.sender, income, citizen);\r\n        return true;\r\n\r\n    }\r\n\r\n    function moneyReceived(bytes32 message) internal {\r\n      uint256 increaseInAvailableEther = msg.value.mul(95) / 100;\r\n      availableEther = availableEther.add(increaseInAvailableEther);\r\n      maintenancePool.transfer(msg.value - increaseInAvailableEther);\r\n      emit LogVaultSponsored(msg.sender, message, msg.value);\r\n    }\r\n\r\n     /**\r\n     * Allows a person to register as a citizen in the UBIVault.\r\n     * The citizen will have a claim on the AE from the next paymentsCycle onwards.\r\n    */\r\n    //Increases the variable rightFromPaymentCycle for a citizen (also increased in the function claimUBI)\r\n    function registerCitizen(address newCitizen) internal {\r\n        require(rightFromPaymentCycle[newCitizen] == 0, \u0022Citizen already registered\u0022);\r\n        rightFromPaymentCycle[newCitizen] = paymentsCycle.length;\r\n        amountOfCitizens\u002B\u002B;\r\n        emit LogCitizenRegistered(newCitizen);\r\n    }\r\n\r\n    function () external payable whenNotPaused {\r\n        moneyReceived(bytes32(0));\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022availableEther\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022selfDestructPeriod\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_useablePasswordHashes\u0022,\u0022type\u0022:\u0022bytes32[]\u0022}],\u0022name\u0022:\u0022createUseablePasswords\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022citizens\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022onlyOne\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022claimUBIOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022maintenancePool\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022onlyOne\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022claimUBIPublic\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022usedPasswordHashes\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022sponsorVault\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022minimumPeriod\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isPauser\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022amountOfCitizens\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022euroCentInWei\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022amountOfBasicIncomeCanBeIncreased\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022adjustedEuroCentInWei\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022createUBI\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022selfDestructAt\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renouncePauser\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022amountOfBasicIncome\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022paymentsCycle\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addPauser\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022destroy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022password\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022registerCitizenPublic\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022useablePasswordHashes\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022promisedEther\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newCitizen\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022registerCitizenOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022rightFromPaymentCycle\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022initialAB\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022initialMinimumPeriod\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022initialEuroCentInWei\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_maintenancePool\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022passwordHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022LogUseablePasswordCreated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022adjustedEuroCentInWei\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022totalamountOfBasicIncomeInWei\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amountOfCitizens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amountOfBasicIncomeCanBeIncreased\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022paymentsCycle\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogUBICreated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newCitizen\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogCitizenRegistered\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022password\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022passwordHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022LogPasswordUsed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022payee\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogVaultSponsored\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022caller\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022income\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022citizen\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogUBIClaimed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Paused\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Unpaused\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022PauserAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022PauserRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"UBIVault","CompilerVersion":"v0.5.7\u002Bcommit.6da8b019","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"00000000000000000000000000000000000000000000000000000000000002bc0000000000000000000000000000000000000000000000000000000000093a80000000000000000000000000000000000000000000000000000033fe7a34d5820000000000000000000000003f23ffc871f38323e888e0b3bb1a20b8b38374b0","Library":"","SwarmSource":"bzzr://8cdde279374ff82feebb8cdb285183a5ac5ba62daa1df7cd0cb018423c2e9cf1"}]