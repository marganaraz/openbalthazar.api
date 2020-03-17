[{"SourceCode":"pragma solidity ^0.5.16;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n\r\n  /**\r\n  * @dev Multiplies two numbers, throws on overflow.\r\n  */\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Integer division of two numbers, truncating the quotient.\r\n  */\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    // uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return a / b;\r\n  }\r\n\r\n  /**\r\n  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n  */\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  /**\r\n  * @dev Adds two numbers, throws on overflow.\r\n  */\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\n/**\r\n * @title Roles\r\n * @author Francisco Giordano (@frangio)\r\n * @dev Library for managing addresses assigned to a Role.\r\n *      See RBAC.sol for example usage.\r\n */\r\nlibrary Roles {\r\n  struct Role {\r\n    mapping (address =\u003E bool) bearer;\r\n  }\r\n\r\n  /**\r\n   * @dev give an address access to this role\r\n   */\r\n  function add(Role storage role, address addr)\r\n    internal\r\n  {\r\n    role.bearer[addr] = true;\r\n  }\r\n\r\n  /**\r\n   * @dev remove an address\u0027 access to this role\r\n   */\r\n  function remove(Role storage role, address addr)\r\n    internal\r\n  {\r\n    role.bearer[addr] = false;\r\n  }\r\n\r\n  /**\r\n   * @dev check if an address has this role\r\n   * // reverts\r\n   */\r\n  function check(Role storage role, address addr)\r\n    view\r\n    internal\r\n  {\r\n    require(has(role, addr));\r\n  }\r\n\r\n  /**\r\n   * @dev check if an address has this role\r\n   * @return bool\r\n   */\r\n  function has(Role storage role, address addr)\r\n    view\r\n    internal\r\n    returns (bool)\r\n  {\r\n    return role.bearer[addr];\r\n  }\r\n}\r\n\r\n/**\r\n * @title RBAC (Role-Based Access Control)\r\n * @author Matt Condon (@Shrugs)\r\n * @dev Stores and provides setters and getters for roles and addresses.\r\n * @dev Supports unlimited numbers of roles and addresses.\r\n * @dev See //contracts/mocks/RBACMock.sol for an example of usage.\r\n * This RBAC method uses strings to key roles. It may be beneficial\r\n *  for you to write your own implementation of this interface using Enums or similar.\r\n * It\u0027s also recommended that you define constants in the contract, like ROLE_ADMIN below,\r\n *  to avoid typos.\r\n */\r\ncontract RBAC {\r\n  using Roles for Roles.Role;\r\n\r\n  mapping (string =\u003E Roles.Role) private roles;\r\n\r\n  event RoleAdded(address addr, string roleName);\r\n  event RoleRemoved(address addr, string roleName);\r\n\r\n  /**\r\n   * @dev reverts if addr does not have role\r\n   * @param addr address\r\n   * @param roleName the name of the role\r\n   * // reverts\r\n   */\r\n  function checkRole(address addr, string memory roleName)\r\n    view\r\n    public\r\n  {\r\n    roles[roleName].check(addr);\r\n  }\r\n\r\n  /**\r\n   * @dev determine if addr has role\r\n   * @param addr address\r\n   * @param roleName the name of the role\r\n   * @return bool\r\n   */\r\n  function hasRole(address addr, string memory roleName)\r\n    view\r\n    public\r\n    returns (bool)\r\n  {\r\n    return roles[roleName].has(addr);\r\n  }\r\n\r\n  /**\r\n   * @dev add a role to an address\r\n   * @param addr address\r\n   * @param roleName the name of the role\r\n   */\r\n  function addRole(address addr, string memory roleName)\r\n    internal\r\n  {\r\n    roles[roleName].add(addr);\r\n    emit RoleAdded(addr, roleName);\r\n  }\r\n\r\n  /**\r\n   * @dev remove a role from an address\r\n   * @param addr address\r\n   * @param roleName the name of the role\r\n   */\r\n  function removeRole(address addr, string memory roleName)\r\n    internal\r\n  {\r\n    roles[roleName].remove(addr);\r\n    emit RoleRemoved(addr, roleName);\r\n  }\r\n\r\n  /**\r\n   * @dev modifier to scope access to a single role (uses msg.sender as addr)\r\n   * @param roleName the name of the role\r\n   * // reverts\r\n   */\r\n  modifier onlyRole(string memory roleName)\r\n  {\r\n    checkRole(msg.sender, roleName);\r\n    _;\r\n  }\r\n\r\n}\r\n\r\n/**\r\n * @title RBACWithAdmin\r\n * @author Matt Condon (@Shrugs)\r\n * @dev It\u0027s recommended that you define constants in the contract,\r\n * @dev like ROLE_ADMIN below, to avoid typos.\r\n */\r\ncontract RBACWithAdmin is RBAC { // , DESTROYER {\r\n  /**\r\n   * A constant role name for indicating admins.\r\n   */\r\n  string public constant ROLE_ADMIN = \u0022admin\u0022;\r\n  string public constant ROLE_PAUSE_ADMIN = \u0022pauseAdmin\u0022;\r\n\r\n  /**\r\n   * @dev modifier to scope access to admins\r\n   * // reverts\r\n   */\r\n  modifier onlyAdmin()\r\n  {\r\n    checkRole(msg.sender, ROLE_ADMIN);\r\n    _;\r\n  }\r\n  modifier onlyPauseAdmin()\r\n  {\r\n    checkRole(msg.sender, ROLE_PAUSE_ADMIN);\r\n    _;\r\n  }\r\n  /**\r\n   * @dev constructor. Sets msg.sender as admin by default\r\n   */\r\n  constructor()\r\n    public\r\n  {\r\n    addRole(msg.sender, ROLE_ADMIN);\r\n    addRole(msg.sender, ROLE_PAUSE_ADMIN);\r\n  }\r\n\r\n  /**\r\n   * @dev add a role to an address\r\n   * @param addr address\r\n   * @param roleName the name of the role\r\n   */\r\n  function adminAddRole(address addr, string memory roleName)\r\n    onlyAdmin\r\n    public\r\n  {\r\n    addRole(addr, roleName);\r\n  }\r\n\r\n  /**\r\n   * @dev remove a role from an address\r\n   * @param addr address\r\n   * @param roleName the name of the role\r\n   */\r\n  function adminRemoveRole(address addr, string memory roleName)\r\n    onlyAdmin\r\n    public\r\n  {\r\n    removeRole(addr, roleName);\r\n  }\r\n}\r\n\r\n/**\r\n * @title Helps contracts guard agains reentrancy attacks.\r\n * @author Remco Bloemen \u003Cremco@2\u03C0.com\u003E\r\n * @notice If you mark a function \u0060nonReentrant\u0060, you should also\r\n * mark it \u0060external\u0060.\r\n */\r\ncontract ReentrancyGuard {\r\n\r\n  /**\r\n   * @dev We use a single lock for the whole contract.\r\n   */\r\n  bool private reentrancyLock = false;\r\n\r\n  /**\r\n   * @dev Prevents a contract from calling itself, directly or indirectly.\r\n   * @notice If you mark a function \u0060nonReentrant\u0060, you should also\r\n   * mark it \u0060external\u0060. Calling one nonReentrant function from\r\n   * another is not supported. Instead, you can implement a\r\n   * \u0060private\u0060 function doing the actual work, and a \u0060external\u0060\r\n   * wrapper marked as \u0060nonReentrant\u0060.\r\n   */\r\n  modifier nonReentrant() {\r\n    require(!reentrancyLock);\r\n    reentrancyLock = true;\r\n    _;\r\n    reentrancyLock = false;\r\n  }\r\n\r\n}\r\n\r\n\r\n\r\n/**\r\n * @title Pausable\r\n * @dev Base contract which allows children to implement an emergency stop mechanism.\r\n */\r\ncontract Pausable is RBACWithAdmin {\r\n  event Pause();\r\n  event Unpause();\r\n\r\n  bool public paused = false;\r\n\r\n\r\n  /**\r\n   * @dev Modifier to make a function callable only when the contract is not paused.\r\n   */\r\n  modifier whenNotPaused() {\r\n    require(!paused);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Modifier to make a function callable only when the contract is paused.\r\n   */\r\n  modifier whenPaused() {\r\n    require(paused);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev called by the owner to pause, triggers stopped state\r\n   */\r\n  function pause() onlyPauseAdmin whenNotPaused public {\r\n    paused = true;\r\n    emit Pause();\r\n  }\r\n\r\n  /**\r\n   * @dev called by the owner to unpause, returns to normal state\r\n   */\r\n  function unpause() onlyPauseAdmin whenPaused public {\r\n    paused = false;\r\n    emit Unpause();\r\n  }\r\n}\r\n\r\ncontract DragonsETH {\r\n    struct Dragon {\r\n        uint256 gen1;\r\n        uint8 stage; // 0 - Dead, 1 - Egg, 2 - Young Dragon \r\n        uint8 currentAction; // 0 - free, 1 - fight place, 0xFF - Necropolis,  2 - random fight,\r\n                             // 3 - breed market, 4 - breed auction, 5 - random breed, 6 - market place ...\r\n        uint240 gen2;\r\n        uint256 nextBlock2Action;\r\n    }\r\n\r\n    Dragon[] public dragons;\r\n    \r\n    function transferFrom(address _from, address _to, uint256 _tokenId) public;\r\n    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;\r\n    function setCurrentAction(uint256 _dragonID, uint8 _currentAction) external;\r\n}\r\n\r\ncontract FixMarketPlace is Pausable, ReentrancyGuard {\r\n    using SafeMath for uint256;\r\n    DragonsETH public mainContract;\r\n    address payable wallet;\r\n    uint256 public ownersPercent = 50; // eq 5%\r\n    mapping(uint256 =\u003E address payable) public dragonsOwner;\r\n    mapping(uint256 =\u003E uint256) public dragonPrices;\r\n    mapping(uint256 =\u003E uint256) public dragonsListIndex;\r\n    mapping(address =\u003E uint256) public ownerDragonsCount;\r\n    mapping(uint256 =\u003E uint256) public dragonsLikes;\r\n    uint256[] public dragonsList;\r\n    \r\n    event SoldOut(address indexed _from, address indexed _to, uint256 _tokenId, uint256 _price);\r\n    event ForSale(address indexed _from, uint256 _tokenId, uint256 _price);\r\n    event SaleCancel(address indexed _from, uint256 _tokenId, uint256 _price);\r\n    \r\n    constructor(address payable _wallet, address _mainContract) public {\r\n        wallet = _wallet;\r\n        mainContract = DragonsETH(_mainContract);\r\n    }\r\n    function add2MarketPlace(address payable _dragonOwner, uint256 _dragonID, uint256 _dragonPrice, uint256 /*_endBlockNumber*/) \r\n        external\r\n        whenNotPaused\r\n        returns (bool) \r\n    {\r\n        require(msg.sender == address(mainContract), \u0022Only the main contract can add dragons!\u0022);\r\n        dragonsOwner[_dragonID] = _dragonOwner;\r\n        ownerDragonsCount[_dragonOwner]\u002B\u002B;\r\n        dragonPrices[_dragonID] = _dragonPrice;\r\n        dragonsListIndex[_dragonID] = dragonsList.length;\r\n        dragonsList.push(_dragonID);\r\n        mainContract.setCurrentAction(_dragonID, 6);\r\n        emit ForSale(_dragonOwner, _dragonID, _dragonPrice);\r\n        return true;\r\n    }\r\n    \r\n    function delFromFixMarketPlace(uint256 _dragonID) external {\r\n        require(msg.sender == dragonsOwner[_dragonID], \u0022Only owners can do it!\u0022);\r\n        mainContract.transferFrom(address(this), dragonsOwner[_dragonID], _dragonID);\r\n        emit SaleCancel(dragonsOwner[_dragonID], _dragonID, dragonPrices[_dragonID]);\r\n        _delItem(_dragonID);\r\n    }\r\n    function buyDragon(uint256 _dragonID) external payable nonReentrant whenNotPaused {\r\n        uint256 _dragonCommisions = dragonPrices[_dragonID].mul(ownersPercent).div(1000);\r\n        require(msg.value \u003E= dragonPrices[_dragonID].add(_dragonCommisions), \u0022Not enough Ether!\u0022);\r\n        uint256 valueToReturn = msg.value.sub(dragonPrices[_dragonID]).sub(_dragonCommisions);\r\n        if (valueToReturn != 0) {\r\n            msg.sender.transfer(valueToReturn);\r\n        }\r\n    \r\n        mainContract.safeTransferFrom(address(this), msg.sender, _dragonID);\r\n        wallet.transfer(_dragonCommisions);\r\n        dragonsOwner[_dragonID].transfer(msg.value - valueToReturn - _dragonCommisions);\r\n        emit SoldOut(dragonsOwner[_dragonID], msg.sender, _dragonID, msg.value - valueToReturn - _dragonCommisions);\r\n        _delItem(_dragonID);\r\n    }\r\n    function likeDragon(uint256 _dragonID) external whenNotPaused {\r\n        dragonsLikes[_dragonID]\u002B\u002B;\r\n    }\r\n    function totalDragonsToSale() external view returns(uint256) {\r\n        return dragonsList.length;\r\n    }\r\n    function getAllDragonsSale() external view returns(uint256[] memory) {\r\n        return dragonsList;\r\n    }\r\n    function getSlicedDragonsSale(uint256 _firstIndex, uint256 _aboveLastIndex) external view returns(uint256[] memory) {\r\n        require(_firstIndex \u003C dragonsList.length, \u0022The first index greater than totalDragonsToSale!\u0022);\r\n        uint256 lastIndex = _aboveLastIndex;\r\n        if (_aboveLastIndex \u003E dragonsList.length) lastIndex = dragonsList.length;\r\n        require(_firstIndex \u003C= lastIndex, \u0022The first index greater than last!\u0022);\r\n        uint256 resultCount = lastIndex - _firstIndex;\r\n        if (resultCount == 0) {\r\n            return new uint256[](0);\r\n        } else {\r\n            uint256[] memory result = new uint256[](resultCount);\r\n            uint256 _dragonIndex;\r\n            uint256 _resultIndex = 0;\r\n\r\n            for (_dragonIndex = _firstIndex; _dragonIndex \u003C lastIndex; _dragonIndex\u002B\u002B) {\r\n                result[_resultIndex] = dragonsList[_dragonIndex];\r\n                _resultIndex\u002B\u002B;\r\n            }\r\n\r\n            return result;\r\n        }\r\n    }\r\n    function getOwnedDragonToSale(address _owner) external view returns(uint256[] memory) {\r\n        uint256 countResaultDragons = ownerDragonsCount[_owner];\r\n        if (countResaultDragons == 0) {\r\n            return new uint256[](0);\r\n        } else {\r\n            uint256[] memory result = new uint256[](countResaultDragons);\r\n            uint256 _dragonIndex;\r\n            uint256 _resultIndex = 0;\r\n\r\n            for (_dragonIndex = 0; _dragonIndex \u003C dragonsList.length; _dragonIndex\u002B\u002B) {\r\n                uint256 _dragonID = dragonsList[_dragonIndex];\r\n                if (dragonsOwner[_dragonID] == _owner) {\r\n                    result[_resultIndex] = _dragonID;\r\n                    _resultIndex\u002B\u002B;\r\n                    if (_resultIndex == countResaultDragons) break;\r\n                }\r\n            }\r\n\r\n            return result;\r\n        }\r\n    }\r\n    function getFewDragons(uint256[] calldata _dragonIDs) external view returns(uint256[] memory) {\r\n        uint256 dragonCount = _dragonIDs.length;\r\n        if (dragonCount == 0) {\r\n            return new uint256[](0);\r\n        } else {\r\n            uint256[] memory result = new uint256[](dragonCount * 4);\r\n            uint256 resultIndex = 0;\r\n\r\n            for (uint256 dragonIndex = 0; dragonIndex \u003C dragonCount; dragonIndex\u002B\u002B) {\r\n                uint256 dragonID = _dragonIDs[dragonIndex];\r\n                result[resultIndex\u002B\u002B] = dragonID;\r\n                uint8 tmp;\r\n                (,tmp,,,) = mainContract.dragons(dragonID);\r\n                result[resultIndex\u002B\u002B] = uint256(tmp);\r\n                result[resultIndex\u002B\u002B] = uint256(dragonsOwner[dragonID]);\r\n                result[resultIndex\u002B\u002B] = dragonPrices[dragonID];\r\n                \r\n            }\r\n\r\n            return result; \r\n        }\r\n    }\r\n     function _delItem(uint256 _dragonID) private {\r\n        require(dragonsOwner[_dragonID] != address(0), \u0022An attempt to remove an unregistered dragon!\u0022);\r\n        mainContract.setCurrentAction(_dragonID, 0);\r\n        ownerDragonsCount[dragonsOwner[_dragonID]]--;\r\n        delete(dragonsOwner[_dragonID]);\r\n        delete(dragonPrices[_dragonID]);\r\n        delete(dragonsLikes[_dragonID]);\r\n        if (dragonsList.length - 1 != dragonsListIndex[_dragonID]) {\r\n            dragonsList[dragonsListIndex[_dragonID]] = dragonsList[dragonsList.length - 1];\r\n            dragonsListIndex[dragonsList[dragonsList.length - 1]] = dragonsListIndex[_dragonID];\r\n        }\r\n        dragonsList.length--;\r\n        delete(dragonsListIndex[_dragonID]);\r\n    }\r\n    function clearMarket(uint256[] calldata _dragonIDs) external onlyAdmin whenPaused {\r\n        uint256 dragonCount = _dragonIDs.length;\r\n        if (dragonCount \u003E 0) {\r\n            for (uint256 dragonIndex = 0; dragonIndex \u003C dragonCount; dragonIndex\u002B\u002B) {\r\n                uint256 dragonID = _dragonIDs[dragonIndex];\r\n                mainContract.transferFrom(address(this), dragonsOwner[dragonID], dragonID);\r\n                _delItem(dragonID);\r\n            }\r\n        }\r\n    }\r\n    function changeWallet(address payable _wallet) external onlyAdmin {\r\n        wallet = _wallet;\r\n    }\r\n    function changeOwnersPercent(uint256 _ownersPercent) external onlyAdmin {\r\n        ownersPercent = _ownersPercent;\r\n    }\r\n    function withdrawAllEther() external onlyAdmin {\r\n        require(wallet != address(0), \u0022Withdraw address can\u0027t be zero!\u0022);\r\n        wallet.transfer(address(this).balance);\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_mainContract\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ForSale\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Pause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022roleName\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022RoleAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022roleName\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022RoleRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022SaleCancel\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022SoldOut\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Unpause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ROLE_ADMIN\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ROLE_PAUSE_ADMIN\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_dragonOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_dragonID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_dragonPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022add2MarketPlace\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022roleName\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022adminAddRole\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022roleName\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022adminRemoveRole\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_dragonID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022buyDragon\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_ownersPercent\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022changeOwnersPercent\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeWallet\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022roleName\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022checkRole\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_dragonIDs\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022clearMarket\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_dragonID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022delFromFixMarketPlace\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022dragonPrices\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022dragonsLikes\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022dragonsList\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022dragonsListIndex\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022dragonsOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAllDragonsSale\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_dragonIDs\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022getFewDragons\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getOwnedDragonToSale\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_firstIndex\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_aboveLastIndex\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getSlicedDragonsSale\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022roleName\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022hasRole\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_dragonID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022likeDragon\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022mainContract\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract DragonsETH\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022ownerDragonsCount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ownersPercent\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalDragonsToSale\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawAllEther\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"FixMarketPlace","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000d0d50ae97443aa9615d87129feb9681417e92f4100000000000000000000000034887b4e8fe85b20ae9012d071412afe702c9409","Library":"","SwarmSource":"bzzr://3eed54ddc375209f1c7480227d06dac0122e5e77408ea2f55b1bce974206be69"}]