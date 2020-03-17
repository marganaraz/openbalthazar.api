[{"SourceCode":"pragma solidity ^0.6.2;\r\npragma experimental ABIEncoderV2;\r\n\r\n/**\r\n * @title Roles\r\n * @author Francisco Giordano (@frangio)\r\n * @dev Library for managing addresses assigned to a Role.\r\n *      See RBAC.sol for example usage.\r\n */\r\nlibrary Roles {\r\n  struct Role {\r\n    mapping (address =\u003E bool) bearer;\r\n  }\r\n\r\n  /**\r\n   * @dev give an address access to this role\r\n   */\r\n  function add(Role storage role, address addr)\r\n    internal\r\n  {\r\n    role.bearer[addr] = true;\r\n  }\r\n\r\n  /**\r\n   * @dev remove an address\u0027 access to this role\r\n   */\r\n  function remove(Role storage role, address addr)\r\n    internal\r\n  {\r\n    role.bearer[addr] = false;\r\n  }\r\n\r\n  /**\r\n   * @dev check if an address has this role\r\n   * // reverts\r\n   */\r\n  function check(Role storage role, address addr)\r\n    view\r\n    internal\r\n  {\r\n    require(has(role, addr));\r\n  }\r\n\r\n  /**\r\n   * @dev check if an address has this role\r\n   * @return bool\r\n   */\r\n  function has(Role storage role, address addr)\r\n    view\r\n    internal\r\n    returns (bool)\r\n  {\r\n    return role.bearer[addr];\r\n  }\r\n}\r\n\r\n/**\r\n * @title RBAC (Role-Based Access Control)\r\n * @author Matt Condon (@Shrugs)\r\n * @dev Stores and provides setters and getters for roles and addresses.\r\n * @dev Supports unlimited numbers of roles and addresses.\r\n * @dev See //contracts/mocks/RBACMock.sol for an example of usage.\r\n * This RBAC method uses strings to key roles. It may be beneficial\r\n *  for you to write your own implementation of this interface using Enums or similar.\r\n * It\u0027s also recommended that you define constants in the contract, like ROLE_ADMIN below,\r\n *  to avoid typos.\r\n */\r\ncontract RBAC {\r\n  using Roles for Roles.Role;\r\n\r\n  mapping (string =\u003E Roles.Role) private roles;\r\n\r\n  event RoleAdded(address addr, string roleName);\r\n  event RoleRemoved(address addr, string roleName);\r\n\r\n  /**\r\n   * @dev reverts if addr does not have role\r\n   * @param addr address\r\n   * @param roleName the name of the role\r\n   * // reverts\r\n   */\r\n  function checkRole(address addr, string memory roleName)\r\n    view\r\n    public\r\n  {\r\n    roles[roleName].check(addr);\r\n  }\r\n\r\n  /**\r\n   * @dev determine if addr has role\r\n   * @param addr address\r\n   * @param roleName the name of the role\r\n   * @return bool\r\n   */\r\n  function hasRole(address addr, string memory roleName)\r\n    view\r\n    public\r\n    returns (bool)\r\n  {\r\n    return roles[roleName].has(addr);\r\n  }\r\n\r\n  /**\r\n   * @dev add a role to an address\r\n   * @param addr address\r\n   * @param roleName the name of the role\r\n   */\r\n  function addRole(address addr, string memory roleName)\r\n    internal\r\n  {\r\n    roles[roleName].add(addr);\r\n    emit RoleAdded(addr, roleName);\r\n  }\r\n\r\n  /**\r\n   * @dev remove a role from an address\r\n   * @param addr address\r\n   * @param roleName the name of the role\r\n   */\r\n  function removeRole(address addr, string memory roleName)\r\n    internal\r\n  {\r\n    roles[roleName].remove(addr);\r\n    emit RoleRemoved(addr, roleName);\r\n  }\r\n\r\n  /**\r\n   * @dev modifier to scope access to a single role (uses msg.sender as addr)\r\n   * @param roleName the name of the role\r\n   * // reverts\r\n   */\r\n  modifier onlyRole(string memory roleName)\r\n  {\r\n    checkRole(msg.sender, roleName);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)\r\n   * @param roleNames the names of the roles to scope access to\r\n   * // reverts\r\n   *\r\n   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this\r\n   *  see: https://github.com/ethereum/solidity/issues/2467\r\n   */\r\n  // modifier onlyRoles(string[] roleNames) {\r\n  //     bool hasAnyRole = false;\r\n  //     for (uint8 i = 0; i \u003C roleNames.length; i\u002B\u002B) {\r\n  //         if (hasRole(msg.sender, roleNames[i])) {\r\n  //             hasAnyRole = true;\r\n  //             break;\r\n  //         }\r\n  //     }\r\n\r\n  //     require(hasAnyRole);\r\n\r\n  //     _;\r\n  // }\r\n}\r\n\r\n/**\r\n * @title RBACWithAdmin\r\n * @author Matt Condon (@Shrugs)\r\n * @dev It\u0027s recommended that you define constants in the contract,\r\n * @dev like ROLE_ADMIN below, to avoid typos.\r\n */\r\ncontract RBACWithAdmin is RBAC {\r\n  /**\r\n   * A constant role name for indicating admins.\r\n   */\r\n  string public constant ROLE_ADMIN = \u0022admin\u0022;\r\n  string public constant ROLE_PAUSE_ADMIN = \u0022pauseAdmin\u0022;\r\n\r\n  /**\r\n   * @dev modifier to scope access to admins\r\n   * // reverts\r\n   */\r\n  modifier onlyAdmin()\r\n  {\r\n    checkRole(msg.sender, ROLE_ADMIN);\r\n    _;\r\n  }\r\n  modifier onlyPauseAdmin()\r\n  {\r\n    checkRole(msg.sender, ROLE_PAUSE_ADMIN);\r\n    _;\r\n  }\r\n  /**\r\n   * @dev constructor. Sets msg.sender as admin by default\r\n   */\r\n  constructor()\r\n    public\r\n  {\r\n    addRole(msg.sender, ROLE_ADMIN);\r\n    addRole(msg.sender, ROLE_PAUSE_ADMIN);\r\n  }\r\n\r\n  /**\r\n   * @dev add a role to an address\r\n   * @param addr address\r\n   * @param roleName the name of the role\r\n   */\r\n  function adminAddRole(address addr, string memory roleName)\r\n    onlyAdmin\r\n    public\r\n  {\r\n    addRole(addr, roleName);\r\n  }\r\n\r\n  /**\r\n   * @dev remove a role from an address\r\n   * @param addr address\r\n   * @param roleName the name of the role\r\n   */\r\n  function adminRemoveRole(address addr, string memory roleName)\r\n    onlyAdmin\r\n    public\r\n  {\r\n    removeRole(addr, roleName);\r\n  }\r\n}\r\n\r\nabstract contract DragonsETH {\r\n    struct Dragon {\r\n        uint256 gen1;\r\n        uint8 stage; // 0 - Dead, 1 - Egg, 2 - Young Dragon \r\n        uint8 currentAction; // 0 - free, 1 - fight place, 0xFF - Necropolis,  2 - random fight,\r\n                             // 3 - breed market, 4 - breed auction, 5 - random breed, 6 - market place ...\r\n        uint240 gen2;\r\n        uint256 nextBlock2Action;\r\n    }\r\n\r\n    Dragon[] public dragons;\r\n    mapping(uint256 =\u003E string) public dragonName;\r\n    \r\n    function ownerOf(uint256 _tokenId) virtual public view returns (address);\r\n    function tokensOf(address _owner) virtual external view returns (uint256[] memory);\r\n    //function balanceOf(address _owner) public view returns (uint256);\r\n}\r\n\r\ncontract DragonsStats {\r\n    struct parent {\r\n        uint128 parentOne;\r\n        uint128 parentTwo;\r\n    }\r\n    \r\n    struct lastAction {\r\n        uint8  lastActionID;\r\n        uint248 lastActionDragonID;\r\n    }\r\n    \r\n    struct dragonStat {\r\n        uint32 fightWin;\r\n        uint32 fightLose;\r\n        uint32 children;\r\n        uint32 fightToDeathWin;\r\n        uint32 mutagenFace;\r\n        uint32 mutagenFight;\r\n        uint32 genLabFace;\r\n        uint32 genLabFight;\r\n    }\r\n    mapping(uint256 =\u003E uint256) public birthBlock;\r\n    mapping(uint256 =\u003E uint256) public deathBlock;\r\n    mapping(uint256 =\u003E parent)  public parents;\r\n    mapping(uint256 =\u003E lastAction) public lastActions;\r\n    mapping(uint256 =\u003E dragonStat) public dragonStats;\r\n    \r\n    \r\n}\r\n\r\nabstract contract FixMarketPlace {\r\n    function getOwnedDragonToSale(address _owner) virtual external view returns(uint256[] memory);\r\n}\r\n\r\ncontract Proxy4DAPP is RBACWithAdmin {\r\n    DragonsETH public mainContract;\r\n    DragonsStats public statsContract;\r\n    FixMarketPlace public fmpContractAddress;\r\n    bytes constant firstPartPictureName = \u0022dragon_\u0022;\r\n    \r\n    constructor(address _addressMainContract, address _addressDragonsStats) public {\r\n        mainContract = DragonsETH(_addressMainContract);\r\n        statsContract = DragonsStats(_addressDragonsStats);\r\n    }\r\n    function getDragons(uint256[] calldata _dragonIDs) external view returns(uint256[] memory) {\r\n        if (_dragonIDs.length == 0) {\r\n            return new uint256[](0);\r\n        } else {\r\n            uint256[] memory result = new uint256[](_dragonIDs.length * 17 \u002B 1/*CHAGE IT*/);\r\n            result[0] = block.number;\r\n            for (uint256 dragonIndex = 0; dragonIndex \u003C _dragonIDs.length; dragonIndex\u002B\u002B) {\r\n                uint256 dragonID = _dragonIDs[dragonIndex];\r\n                result[dragonIndex * 17 \u002B 1] = dragonID;\r\n                result[dragonIndex * 17 \u002B 2] = uint256(mainContract.ownerOf(dragonID));\r\n                uint8 tmp;\r\n                uint8 currentAction;\r\n                uint240 gen2;\r\n                (result[dragonIndex * 17 \u002B 3]/*gen1*/,tmp,currentAction,gen2,result[dragonIndex * 17 \u002B 4]/*nextBlock2Action*/) = mainContract.dragons(dragonID);\r\n                result[dragonIndex * 17 \u002B 5] = uint256(tmp); // stage\r\n                result[dragonIndex * 17 \u002B 6] = uint256(currentAction);\r\n                result[dragonIndex * 17 \u002B 7] = uint256(gen2);\r\n                uint248 lastActionDragonID;\r\n                (tmp, lastActionDragonID) = statsContract.lastActions(dragonID);\r\n                result[dragonIndex * 17 \u002B 8] = uint256(tmp); // lastActionID\r\n                result[dragonIndex * 17 \u002B 9] = uint256(lastActionDragonID);\r\n                uint32 fightWin;\r\n                uint32 fightLose;\r\n                uint32 children;\r\n                uint32 fightToDeathWin;\r\n                uint32 mutagenFight;\r\n                uint32 genLabFight;\r\n                uint32 mutagenFace;\r\n                uint32 genLabFace;\r\n                (fightWin,fightLose,children,fightToDeathWin,mutagenFace,mutagenFight,genLabFace,genLabFight) = statsContract.dragonStats(dragonID);\r\n                result[dragonIndex * 17 \u002B 10] = uint256(fightWin);\r\n                result[dragonIndex * 17 \u002B 11] = uint256(fightLose);\r\n                result[dragonIndex * 17 \u002B 12] = uint256(children);\r\n                result[dragonIndex * 17 \u002B 13] = uint256(fightToDeathWin);\r\n                result[dragonIndex * 17 \u002B 14] = uint256(mutagenFace);\r\n                result[dragonIndex * 17 \u002B 15] = uint256(mutagenFight);\r\n                result[dragonIndex * 17 \u002B 16] = uint256(genLabFace);\r\n                result[dragonIndex * 17 \u002B 17] = uint256(genLabFight);\r\n            }\r\n\r\n            return result; \r\n        }\r\n    }\r\n    function getDragonsName(uint256[] calldata _dragonIDs) external view returns(string[] memory) {\r\n        uint256 dragonCount = _dragonIDs.length;\r\n        if (dragonCount == 0) {\r\n            return new string[](0);\r\n        } else {\r\n            string[] memory result = new string[](dragonCount);\r\n            \r\n            for (uint256 dragonIndex = 0; dragonIndex \u003C dragonCount; dragonIndex\u002B\u002B) {\r\n                result[dragonIndex] = mainContract.dragonName(_dragonIDs[dragonIndex]);\r\n            }\r\n            return result;\r\n        }\r\n    }\r\n    function getDragonsNameB32(uint256[] calldata _dragonIDs) external view returns(bytes32[] memory) {\r\n        uint256 dragonCount = _dragonIDs.length;\r\n        if (dragonCount == 0) {\r\n            return new bytes32[](0);\r\n        } else {\r\n            bytes32[] memory result = new bytes32[](dragonCount);\r\n            \r\n            for (uint256 dragonIndex = 0; dragonIndex \u003C dragonCount; dragonIndex\u002B\u002B) {\r\n                bytes memory tempEmptyStringTest = bytes(mainContract.dragonName(_dragonIDs[dragonIndex]));\r\n                bytes32 tmp;\r\n                if (tempEmptyStringTest.length == 0) {\r\n                    result[dragonIndex] = 0x0;\r\n                } else {\r\n\r\n                    assembly {\r\n                        tmp := mload(add(tempEmptyStringTest, 32))\r\n                    }\r\n                    result[dragonIndex] = tmp;\r\n                }\r\n            }\r\n            return result;\r\n        }\r\n    }\r\n    function getDragonsStats(uint256[] calldata _dragonIDs) external view returns(uint256[] memory) {\r\n        uint256 dragonCount = _dragonIDs.length;\r\n        if (dragonCount == 0) {\r\n            return new uint256[](0);\r\n        } else {\r\n            uint256[] memory result = new uint256[](dragonCount * 6);\r\n            uint256 resultIndex = 0;\r\n\r\n            for (uint256 dragonIndex = 0; dragonIndex \u003C dragonCount; dragonIndex\u002B\u002B) {\r\n                uint256 dragonID = _dragonIDs[dragonIndex];\r\n                result[resultIndex\u002B\u002B] = dragonID;\r\n                result[resultIndex\u002B\u002B] = uint256(mainContract.ownerOf(dragonID));\r\n                uint128 parentOne;\r\n                uint128 parentTwo;\r\n                (parentOne, parentTwo) = statsContract.parents(dragonID);\r\n                result[resultIndex\u002B\u002B] = uint256(parentOne);\r\n                result[resultIndex\u002B\u002B] = uint256(parentTwo);\r\n                result[resultIndex\u002B\u002B] = statsContract.birthBlock(dragonID);\r\n                result[resultIndex\u002B\u002B] = statsContract.deathBlock(dragonID);\r\n            }\r\n            return result;\r\n        }\r\n    }\r\n    function tokensOf(address _owner) external view returns (uint256[] memory) {\r\n        uint256[] memory tmpMain = mainContract.tokensOf(_owner);\r\n        uint256[] memory tmpFMP;\r\n        if (address(fmpContractAddress) != address(0)) {\r\n            tmpFMP = fmpContractAddress.getOwnedDragonToSale(_owner);\r\n        } else {\r\n            tmpFMP = new uint256[](0);\r\n        }\r\n        if (tmpFMP.length \u002B tmpMain.length == 0) {\r\n            return new uint256[](0);\r\n        } else {\r\n            uint256[] memory result = new uint256[](tmpFMP.length \u002B tmpMain.length);\r\n            uint256 index = 0;\r\n            for (; index \u003C tmpMain.length; index\u002B\u002B) {\r\n                result[index] = tmpMain[index];\r\n            }\r\n\r\n            uint256 j = 0;\r\n            while (j \u003C tmpFMP.length) {\r\n                result[index\u002B\u002B] = tmpFMP[j\u002B\u002B];\r\n            }\r\n            return result;\r\n        }\r\n    }\r\n    function changeFMPcontractAddress(address _fmpContractAddress) external onlyAdmin {\r\n        fmpContractAddress = FixMarketPlace(_fmpContractAddress);\r\n    }\r\n    function pictureName(uint256  _tokenId) external pure returns (string memory) {\r\n        bytes memory tmpBytes = new bytes(96);\r\n        uint256 i = 0;\r\n        uint256 tokenId = _tokenId;\r\n        // for same use case need \u0022if (tokenId == 0)\u0022 \r\n        while (tokenId != 0) {\r\n            uint256 remainderDiv = tokenId % 10;\r\n            tokenId = tokenId / 10;\r\n            tmpBytes[i\u002B\u002B] = byte(uint8(48 \u002B remainderDiv));\r\n        }\r\n \r\n        bytes memory resaultBytes = new bytes(firstPartPictureName.length \u002B i);\r\n        uint256 j;\r\n        for (j = 0; j \u003C firstPartPictureName.length; j\u002B\u002B) {\r\n            resaultBytes[j] = firstPartPictureName[j];\r\n        }\r\n        \r\n        i--;\r\n        \r\n        for (j = 0; j \u003C= i; j\u002B\u002B) {\r\n            resaultBytes[j \u002B firstPartPictureName.length] = tmpBytes[i - j];\r\n        }\r\n        \r\n        return string(resaultBytes);\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_addressMainContract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_addressDragonsStats\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022roleName\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022RoleAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022roleName\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022RoleRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022inputs\u0022:[],\u0022name\u0022:\u0022ROLE_ADMIN\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022name\u0022:\u0022ROLE_PAUSE_ADMIN\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022roleName\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022adminAddRole\u0022,\u0022outputs\u0022:[],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022roleName\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022adminRemoveRole\u0022,\u0022outputs\u0022:[],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_fmpContractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeFMPcontractAddress\u0022,\u0022outputs\u0022:[],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022roleName\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022checkRole\u0022,\u0022outputs\u0022:[],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022name\u0022:\u0022fmpContractAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract FixMarketPlace\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_dragonIDs\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022getDragons\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_dragonIDs\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022getDragonsName\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string[]\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_dragonIDs\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022getDragonsNameB32\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32[]\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_dragonIDs\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022getDragonsStats\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022roleName\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022hasRole\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022name\u0022:\u0022mainContract\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract DragonsETH\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022pictureName\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022name\u0022:\u0022statsContract\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract DragonsStats\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022tokensOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Proxy4DAPP","CompilerVersion":"v0.6.2\u002Bcommit.bacdbe57","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"00000000000000000000000034887b4e8fe85b20ae9012d071412afe702c94090000000000000000000000003c29ef59bebe160bbc59c02130b8f637fa11a978","Library":"","SwarmSource":"ipfs://1cf9ac585417707131365a5b3313be6f3c43bc8de26a80e09f6cb7fe2acd0304"}]