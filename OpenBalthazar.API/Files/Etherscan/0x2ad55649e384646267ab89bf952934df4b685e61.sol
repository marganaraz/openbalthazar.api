[{"SourceCode":"// File: contracts/FrozenToken.sol\r\n\r\n/**\r\n * Source Code first verified at https://etherscan.io on Wednesday, October 11, 2017\r\n (UTC) */\r\n\r\n//! FrozenToken ECR20-compliant token contract\r\n//! By Parity Technologies, 2017.\r\n//! Released under the Apache Licence 2.\r\n\r\npragma solidity ^0.5.0;\r\n\r\n// Owned contract.\r\ncontract Owned {\r\n\tmodifier only_owner { require (msg.sender == owner, \u0022Only owner\u0022); _; }\r\n\r\n\tevent NewOwner(address indexed old, address indexed current);\r\n\r\n\tfunction setOwner(address _new) public only_owner { emit NewOwner(owner, _new); owner = _new; }\r\n\r\n\taddress public owner;\r\n}\r\n\r\n// FrozenToken, a bit like an ECR20 token (though not - as it doesn\u0027t\r\n// implement most of the API).\r\n// All token balances are generally non-transferable.\r\n// All \u0022tokens\u0022 belong to the owner (who is uniquely liquid) at construction.\r\n// Liquid accounts can make other accounts liquid and send their tokens\r\n// to other axccounts.\r\ncontract FrozenToken is Owned {\r\n\tevent Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n\t// this is as basic as can be, only the associated balance \u0026 allowances\r\n\tstruct Account {\r\n\t\tuint balance;\r\n\t\tbool liquid;\r\n\t}\r\n\r\n\t// constructor sets the parameters of execution, _totalSupply is all units\r\n\tconstructor(uint _totalSupply, address _owner)\r\n        public\r\n\t\twhen_non_zero(_totalSupply)\r\n\t{\r\n\t\ttotalSupply = _totalSupply;\r\n\t\towner = _owner;\r\n\t\taccounts[_owner].balance = totalSupply;\r\n\t\taccounts[_owner].liquid = true;\r\n\t}\r\n\r\n\t// balance of a specific address\r\n\tfunction balanceOf(address _who) public view returns (uint256) {\r\n\t\treturn accounts[_who].balance;\r\n\t}\r\n\r\n\t// make an account liquid: only liquid accounts can do this.\r\n\tfunction makeLiquid(address _to)\r\n\t\tpublic\r\n\t\twhen_liquid(msg.sender)\r\n\t\treturns(bool)\r\n\t{\r\n\t\taccounts[_to].liquid = true;\r\n\t\treturn true;\r\n\t}\r\n\r\n\t// transfer\r\n\tfunction transfer(address _to, uint256 _value)\r\n\t\tpublic\r\n\t\twhen_owns(msg.sender, _value)\r\n\t\twhen_liquid(msg.sender)\r\n\t\treturns(bool)\r\n\t{\r\n\t\temit Transfer(msg.sender, _to, _value);\r\n\t\taccounts[msg.sender].balance -= _value;\r\n\t\taccounts[_to].balance \u002B= _value;\r\n\r\n\t\treturn true;\r\n\t}\r\n\r\n\t// no default function, simple contract only, entry-level users\r\n\tfunction() external {\r\n\t\tassert(false);\r\n\t}\r\n\r\n\t// the balance should be available\r\n\tmodifier when_owns(address _owner, uint _amount) {\r\n\t\trequire (accounts[_owner].balance \u003E= _amount);\r\n\t\t_;\r\n\t}\r\n\r\n\tmodifier when_liquid(address who) {\r\n\t\trequire (accounts[who].liquid);\r\n\t\t_;\r\n\t}\r\n\r\n\t// a value should be \u003E 0\r\n\tmodifier when_non_zero(uint _value) {\r\n\t\trequire (_value \u003E 0);\r\n\t\t_;\r\n\t}\r\n\r\n\t// Available token supply\r\n\tuint public totalSupply;\r\n\r\n\t// Storage and mapping of all balances \u0026 allowances\r\n\tmapping (address =\u003E Account) accounts;\r\n\r\n\t// Conventional metadata.\r\n\tstring public constant name = \u0022DOT Allocation Indicator\u0022;\r\n\tstring public constant symbol = \u0022DOT\u0022;\r\n\tuint8 public constant decimals = 3;\r\n}\r\n\r\n// File: contracts/Claims.sol\r\n\r\npragma solidity 0.5.13;\r\n\r\n\r\n/// @author Web3 Foundation\r\n/// @title  Claims\r\n///         Allows allocations to be claimed to Polkadot public keys.\r\ncontract Claims is Owned {\r\n\r\n    // The maximum number contained by the type \u0060uint\u0060. Used to freeze the contract from claims.\r\n    uint constant public UINT_MAX =  115792089237316195423570985008687907853269984665640564039457584007913129639935;\r\n\r\n    struct Claim {\r\n        uint    index;          // Index for short address.\r\n        bytes32 pubKey;         // x25519 public key.\r\n        bool    hasIndex;       // Has the index been set?\r\n        uint    vested;         // Amount of allocation that is vested.\r\n    }\r\n\r\n    // The address of the allocation indicator contract.\r\n    FrozenToken public allocationIndicator; // 0xb59f67A8BfF5d8Cd03f6AC17265c550Ed8F33907\r\n\r\n    // The next index to be assigned.\r\n    uint public nextIndex;\r\n\r\n    // Maps allocations to \u0060Claim\u0060 data.\r\n    mapping (address =\u003E Claim) public claims;\r\n\r\n    // A mapping from pubkey to the sale amount from second sale.\r\n    mapping (bytes32 =\u003E uint) public saleAmounts;\r\n\r\n    // A mapping of pubkeys =\u003E an array of ethereum addresses that have made a claim for this pubkey.\r\n    // - Used for getting the balance. \r\n    mapping (bytes32 =\u003E address[]) public claimsForPubkey;\r\n\r\n    // Addresses that already claimed so we can easily grab them from state.\r\n    address[] public claimed;\r\n\r\n    // Amended keys, old address =\u003E new address. New address is allowed to claim for old address.\r\n    mapping (address =\u003E address) public amended;\r\n\r\n    // Block number that the set up delay ends.\r\n    uint public endSetUpDelay;\r\n\r\n    // Event for when an allocation address amendment is made.\r\n    event Amended(address indexed original, address indexed amendedTo);\r\n    // Event for when an allocation is claimed to a Polkadot address.\r\n    event Claimed(address indexed eth, bytes32 indexed dot, uint indexed idx);\r\n    // Event for when an index is assigned to an allocation.\r\n    event IndexAssigned(address indexed eth, uint indexed idx);\r\n    // Event for when vesting is set on an allocation.\r\n    event Vested(address indexed eth, uint amount);\r\n    // Event for when vesting is increased on an account.\r\n    event VestedIncreased(address indexed eth, uint newTotal);\r\n    // Event that triggers when a new sale injection is made.\r\n    event InjectedSaleAmount(bytes32 indexed pubkey, uint newTotal);\r\n\r\n    constructor(address _owner, address _allocations, uint _setUpDelay) public {\r\n        require(_owner != address(0x0), \u0022Must provide an owner address.\u0022);\r\n        require(_allocations != address(0x0), \u0022Must provide an allocations address.\u0022);\r\n        require(_setUpDelay \u003E 0, \u0022Must provide a non-zero argument to _setUpDelay.\u0022);\r\n\r\n        owner = _owner;\r\n        allocationIndicator = FrozenToken(_allocations);\r\n        \r\n        endSetUpDelay = block.number \u002B _setUpDelay;\r\n    }\r\n\r\n    /// Allows owner to manually amend allocations to a new address that can claim.\r\n    /// @dev The given arrays must be same length and index must map directly.\r\n    /// @param _origs An array of original (allocation) addresses.\r\n    /// @param _amends An array of the new addresses which can claim those allocations.\r\n    function amend(address[] calldata _origs, address[] calldata _amends)\r\n        external\r\n        only_owner\r\n    {\r\n        require(\r\n            _origs.length == _amends.length,\r\n            \u0022Must submit arrays of equal length.\u0022\r\n        );\r\n\r\n        for (uint i = 0; i \u003C _amends.length; i\u002B\u002B) {\r\n            require(!hasClaimed(_origs[i]), \u0022Address has already claimed.\u0022);\r\n            require(hasAllocation(_origs[i]), \u0022Ethereum address has no DOT allocation.\u0022);\r\n            amended[_origs[i]] = _amends[i];\r\n            emit Amended(_origs[i], _amends[i]);\r\n        }\r\n    }\r\n\r\n    /// Allows owner to manually toggle vesting onto allocations.\r\n    /// @param _eths The addresses for which to set vesting.\r\n    /// @param _vestingAmts The amounts that the accounts are vested.\r\n    function setVesting(address[] calldata _eths, uint[] calldata _vestingAmts)\r\n        external\r\n        only_owner\r\n    {\r\n        require(_eths.length == _vestingAmts.length, \u0022Must submit arrays of equal length.\u0022);\r\n\r\n        for (uint i = 0; i \u003C _eths.length; i\u002B\u002B) {\r\n            Claim storage claimData = claims[_eths[i]];\r\n            require(!hasClaimed(_eths[i]), \u0022Account must not be claimed.\u0022);\r\n            require(claimData.vested == 0, \u0022Account must not be vested already.\u0022);\r\n            require(_vestingAmts[i] != 0, \u0022Vesting amount must be greater than zero.\u0022);\r\n            claimData.vested = _vestingAmts[i];\r\n            emit Vested(_eths[i], _vestingAmts[i]);\r\n        }\r\n    }\r\n\r\n    /// Allows owner to increase the vesting on an allocation, whether it is claimed or not.\r\n    /// @param _eths The addresses for which to increase vesting.\r\n    /// @param _vestingAmts The amounts to increase the vesting for each account.\r\n    function increaseVesting(address[] calldata _eths, uint[] calldata _vestingAmts)\r\n        external\r\n        only_owner\r\n    {\r\n        require(_eths.length == _vestingAmts.length, \u0022Must submit arrays of equal length.\u0022);\r\n\r\n        for (uint i = 0; i \u003C _eths.length; i\u002B\u002B) {\r\n            Claim storage claimData = claims[_eths[i]];\r\n            // Does not require that the allocation is unclaimed.\r\n            // Does not require that vesting has already been set or not.\r\n            require(_vestingAmts[i] \u003E 0, \u0022Vesting amount must be greater than zero.\u0022);\r\n            uint oldVesting = claimData.vested;\r\n            uint newVesting = oldVesting \u002B _vestingAmts[i];\r\n            // Check for overflow.\r\n            require(newVesting \u003E oldVesting, \u0022Overflow in addition.\u0022);\r\n            claimData.vested = newVesting;\r\n            emit VestedIncreased(_eths[i], newVesting);\r\n        }\r\n    }\r\n\r\n    /// Allows owner to increase the \u0060saleAmount\u0060 for a pubkey by the injected amount.\r\n    /// @param _pubkeys The public keys that will have their balances increased.\r\n    /// @param _amounts The amounts to increase the balance of pubkeys.\r\n    function injectSaleAmount(bytes32[] calldata _pubkeys, uint[] calldata _amounts)\r\n        external\r\n        only_owner\r\n    {\r\n        require(_pubkeys.length == _amounts.length);\r\n\r\n        for (uint i = 0; i \u003C _pubkeys.length; i\u002B\u002B) {\r\n            bytes32 pubkey = _pubkeys[i];\r\n            uint amount = _amounts[i];\r\n\r\n            // Checks that input is not zero.\r\n            require(amount \u003E 0, \u0022Must inject a sale amount greater than zero.\u0022);\r\n\r\n            uint oldValue = saleAmounts[pubkey];\r\n            uint newValue = oldValue \u002B amount;\r\n            // Check for overflow.\r\n            require(newValue \u003E oldValue, \u0022Overflow in addition\u0022);\r\n            saleAmounts[pubkey] = newValue;\r\n\r\n            emit InjectedSaleAmount(pubkey, newValue);\r\n        }\r\n    }\r\n\r\n    /// A helper function that allows anyone to check the balances of public keys.\r\n    /// @param _who The public key to check the balance of.\r\n    function balanceOfPubkey(bytes32 _who) public view returns (uint) {\r\n        address[] storage frozenTokenHolders = claimsForPubkey[_who];\r\n        if (frozenTokenHolders.length \u003E 0) {\r\n            uint total;\r\n            for (uint i = 0; i \u003C frozenTokenHolders.length; i\u002B\u002B) {\r\n                total \u002B= allocationIndicator.balanceOf(frozenTokenHolders[i]);\r\n            }\r\n            return total \u002B saleAmounts[_who];\r\n        }\r\n        return saleAmounts[_who];\r\n    }\r\n\r\n    /// Freezes the contract from any further claims.\r\n    /// @dev Protected by the \u0060only_owner\u0060 modifier.\r\n    function freeze() external only_owner {\r\n        endSetUpDelay = UINT_MAX;\r\n    }\r\n\r\n    /// Allows anyone to assign a batch of indices onto unassigned and unclaimed allocations.\r\n    /// @dev This function is safe because all the necessary checks are made on \u0060assignNextIndex\u0060.\r\n    /// @param _eths An array of allocation addresses to assign indices for.\r\n    /// @return bool True is successful.\r\n    function assignIndices(address[] calldata _eths)\r\n        external\r\n        protected_during_delay\r\n    {\r\n        for (uint i = 0; i \u003C _eths.length; i\u002B\u002B) {\r\n            require(assignNextIndex(_eths[i]), \u0022Assigning the next index failed.\u0022);\r\n        }\r\n    }\r\n\r\n    /// Claims an allocation associated with an \u0060_eth\u0060 address to a \u0060_pubKey\u0060 public key.\r\n    /// @dev Can only be called by the \u0060_eth\u0060 address or the amended address for the allocation.\r\n    /// @param _eth The allocation address to claim.\r\n    /// @param _pubKey The Polkadot public key to claim.\r\n    /// @return True if successful.\r\n    function claim(address _eth, bytes32 _pubKey)\r\n        external\r\n        after_set_up_delay\r\n        has_allocation(_eth)\r\n        not_claimed(_eth)\r\n    {\r\n        require(_pubKey != bytes32(0), \u0022Failed to provide an Ed25519 or SR25519 public key.\u0022);\r\n        \r\n        if (amended[_eth] != address(0x0)) {\r\n            require(amended[_eth] == msg.sender, \u0022Address is amended and sender is not the amendment.\u0022);\r\n        } else {\r\n            require(_eth == msg.sender, \u0022Sender is not the allocation address.\u0022);\r\n        }\r\n\r\n        if (claims[_eth].index == 0 \u0026\u0026 !claims[_eth].hasIndex) {\r\n            require(assignNextIndex(_eth), \u0022Assigning the next index failed.\u0022);\r\n        }\r\n\r\n        claims[_eth].pubKey = _pubKey;\r\n        claimed.push(_eth);\r\n        claimsForPubkey[_pubKey].push(_eth);\r\n\r\n        emit Claimed(_eth, _pubKey, claims[_eth].index);\r\n    }\r\n\r\n    /// Get the length of \u0060claimed\u0060.\r\n    /// @return uint The number of accounts that have claimed.\r\n    function claimedLength()\r\n        external view returns (uint)\r\n    {   \r\n        return claimed.length;\r\n    }\r\n\r\n    /// Get whether an allocation has been claimed.\r\n    /// @return bool True if claimed.\r\n    function hasClaimed(address _eth)\r\n        public view returns (bool)\r\n    {\r\n        return claims[_eth].pubKey != bytes32(0);\r\n    }\r\n\r\n    /// Get whether an address has an allocation.\r\n    /// @return bool True if has a balance of FrozenToken.\r\n    function hasAllocation(address _eth)\r\n        public view returns (bool)\r\n    {\r\n        uint bal = allocationIndicator.balanceOf(_eth);\r\n        return bal \u003E 0;\r\n    }\r\n\r\n    /// Assings an index to an allocation address.\r\n    /// @dev Public function.\r\n    /// @param _eth The allocation address.\r\n    function assignNextIndex(address _eth)\r\n        has_allocation(_eth)\r\n        not_claimed(_eth)\r\n        internal returns (bool)\r\n    {\r\n        require(claims[_eth].index == 0, \u0022Cannot reassign an index.\u0022);\r\n        require(!claims[_eth].hasIndex, \u0022Address has already been assigned an index.\u0022);\r\n        uint idx = nextIndex;\r\n        nextIndex\u002B\u002B;\r\n        claims[_eth].index = idx;\r\n        claims[_eth].hasIndex = true;\r\n        emit IndexAssigned(_eth, idx);\r\n        return true;\r\n    }\r\n\r\n    /// @dev Requires that \u0060_eth\u0060 address has DOT allocation.\r\n    modifier has_allocation(address _eth) {\r\n        require(hasAllocation(_eth), \u0022Ethereum address has no DOT allocation.\u0022);\r\n        _;\r\n    }\r\n\r\n    /// @dev Requires that \u0060_eth\u0060 address has not claimed.\r\n    modifier not_claimed(address _eth) {\r\n        require(\r\n            claims[_eth].pubKey == bytes32(0),\r\n            \u0022Account has already claimed.\u0022\r\n        );\r\n        _;\r\n    }\r\n\r\n    /// @dev Requires that the function with this modifier is evoked after \u0060endSetUpDelay\u0060.\r\n    modifier after_set_up_delay {\r\n        require(\r\n            block.number \u003E= endSetUpDelay,\r\n            \u0022This function is only evocable after the setUpDelay has elapsed.\u0022\r\n        );\r\n        _;\r\n    }\r\n\r\n    /// @dev Requires that the function with this modifier is evoked only by owner before \u0060endSetUpDelay\u0060.\r\n    modifier protected_during_delay {\r\n        if (block.number \u003C endSetUpDelay) {\r\n            require(\r\n                msg.sender == owner,\r\n                \u0022Only owner is allowed to call this function before the end of the set up delay.\u0022\r\n            );\r\n        }\r\n        _;\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_allocations\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_setUpDelay\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022original\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022amendedTo\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Amended\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022eth\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022dot\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022idx\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Claimed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022eth\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022idx\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022IndexAssigned\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022pubkey\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022newTotal\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022InjectedSaleAmount\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022old\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022current\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022NewOwner\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022eth\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Vested\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022eth\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022newTotal\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022VestedIncreased\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022UINT_MAX\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022allocationIndicator\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract FrozenToken\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_origs\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_amends\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022amend\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022amended\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_eths\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022assignIndices\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_who\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022balanceOfPubkey\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_eth\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_pubKey\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022claim\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022claimed\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022claimedLength\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022claims\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022index\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022pubKey\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022hasIndex\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022vested\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022claimsForPubkey\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022endSetUpDelay\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022freeze\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_eth\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022hasAllocation\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_eth\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022hasClaimed\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_eths\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_vestingAmts\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022increaseVesting\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32[]\u0022,\u0022name\u0022:\u0022_pubkeys\u0022,\u0022type\u0022:\u0022bytes32[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_amounts\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022injectSaleAmount\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022nextIndex\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022saleAmounts\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_new\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_eths\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_vestingAmts\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022setVesting\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Claims","CompilerVersion":"v0.5.13\u002Bcommit.5b0b510c","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"00000000000000000000000000444c3281dadacb6e7c55357e5a7bbd92c2dc34000000000000000000000000b59f67a8bff5d8cd03f6ac17265c550ed8f339070000000000000000000000000000000000000000000000000000000000001388","Library":"","SwarmSource":"bzzr://72cbcb50af5e806a11520e2c2f7d0302bc15314188150761b1620e7c713c2f9f"}]