[{"SourceCode":"/**\r\n *Submitted for verification at Etherscan.io on 2019-07-21\r\n*/\r\n\r\n// File: contracts/commons/Ownable.sol\r\n\r\npragma solidity ^0.5.10;\r\n\r\n\r\ncontract Ownable {\r\n    address public owner;\r\n\r\n    event TransferOwnership(address _from, address _to);\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n        emit TransferOwnership(address(0), msg.sender);\r\n    }\r\n\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner, \u0022only owner\u0022);\r\n        _;\r\n    }\r\n\r\n    function setOwner(address _owner) external onlyOwner {\r\n        emit TransferOwnership(owner, _owner);\r\n        owner = _owner;\r\n    }\r\n}\r\n\r\n// File: contracts/commons/AddressMinHeap.sol\r\n\r\npragma solidity ^0.5.10;\r\n\r\n/*\r\n    @author Agustin Aguilar \u003Cagusxrun@gmail.com\u003E\r\n*/\r\n\r\n\r\nlibrary AddressMinHeap {\r\n    using AddressMinHeap for AddressMinHeap.Heap;\r\n\r\n    struct Heap {\r\n        uint256[] entries;\r\n        mapping(address =\u003E uint256) index;\r\n    }\r\n\r\n    function initialize(Heap storage _heap) internal {\r\n        require(_heap.entries.length == 0, \u0022already initialized\u0022);\r\n        _heap.entries.push(0);\r\n    }\r\n\r\n    function encode(address _addr, uint256 _value) internal pure returns (uint256 _entry) {\r\n        /* solium-disable-next-line */\r\n        assembly {\r\n            _entry := not(or(and(0xffffffffffffffffffffffffffffffffffffffff, _addr), shl(160, _value)))\r\n        }\r\n    }\r\n\r\n    function decode(uint256 _entry) internal pure returns (address _addr, uint256 _value) {\r\n        /* solium-disable-next-line */\r\n        assembly {\r\n            let entry := not(_entry)\r\n            _addr := and(entry, 0xffffffffffffffffffffffffffffffffffffffff)\r\n            _value := shr(160, entry)\r\n        }\r\n    }\r\n\r\n    function decodeAddress(uint256 _entry) internal pure returns (address _addr) {\r\n        /* solium-disable-next-line */\r\n        assembly {\r\n            _addr := and(not(_entry), 0xffffffffffffffffffffffffffffffffffffffff)\r\n        }\r\n    }\r\n\r\n    function top(Heap storage _heap) internal view returns(address, uint256) {\r\n        if (_heap.entries.length \u003C 2) {\r\n            return (address(0), 0);\r\n        }\r\n\r\n        return decode(_heap.entries[1]);\r\n    }\r\n\r\n    function has(Heap storage _heap, address _addr) internal view returns (bool) {\r\n        return _heap.index[_addr] != 0;\r\n    }\r\n\r\n    function size(Heap storage _heap) internal view returns (uint256) {\r\n        return _heap.entries.length - 1;\r\n    }\r\n\r\n    function entry(Heap storage _heap, uint256 _i) internal view returns (address, uint256) {\r\n        return decode(_heap.entries[_i \u002B 1]);\r\n    }\r\n\r\n    // RemoveMax pops off the root element of the heap (the highest value here) and rebalances the heap\r\n    function popTop(Heap storage _heap) internal returns(address _addr, uint256 _value) {\r\n        // Ensure the heap exists\r\n        uint256 heapLength = _heap.entries.length;\r\n        require(heapLength \u003E 1, \u0022The heap does not exists\u0022);\r\n\r\n        // take the root value of the heap\r\n        (_addr, _value) = decode(_heap.entries[1]);\r\n        _heap.index[_addr] = 0;\r\n\r\n        if (heapLength == 2) {\r\n            _heap.entries.length = 1;\r\n        } else {\r\n            // Takes the last element of the array and put it at the root\r\n            uint256 val = _heap.entries[heapLength - 1];\r\n            _heap.entries[1] = val;\r\n\r\n            // Delete the last element from the array\r\n            _heap.entries.length = heapLength - 1;\r\n\r\n            // Start at the top\r\n            uint256 ind = 1;\r\n\r\n            // Bubble down\r\n            ind = _heap.bubbleDown(ind, val);\r\n\r\n            // Update index\r\n            _heap.index[decodeAddress(val)] = ind;\r\n        }\r\n    }\r\n\r\n    // Inserts adds in a value to our heap.\r\n    function insert(Heap storage _heap, address _addr, uint256 _value) internal {\r\n        require(_heap.index[_addr] == 0, \u0022The entry already exists\u0022);\r\n\r\n        // Add the value to the end of our array\r\n        uint256 encoded = encode(_addr, _value);\r\n        _heap.entries.push(encoded);\r\n\r\n        // Start at the end of the array\r\n        uint256 currentIndex = _heap.entries.length - 1;\r\n\r\n        // Bubble Up\r\n        currentIndex = _heap.bubbleUp(currentIndex, encoded);\r\n\r\n        // Update index\r\n        _heap.index[_addr] = currentIndex;\r\n    }\r\n\r\n    function update(Heap storage _heap, address _addr, uint256 _value) internal {\r\n        uint256 ind = _heap.index[_addr];\r\n        require(ind != 0, \u0022The entry does not exists\u0022);\r\n\r\n        uint256 can = encode(_addr, _value);\r\n        uint256 val = _heap.entries[ind];\r\n        uint256 newInd;\r\n\r\n        if (can \u003C val) {\r\n            // Bubble down\r\n            newInd = _heap.bubbleDown(ind, can);\r\n        } else if (can \u003E val) {\r\n            // Bubble up\r\n            newInd = _heap.bubbleUp(ind, can);\r\n        } else {\r\n            // no changes needed\r\n            return;\r\n        }\r\n\r\n        // Update entry\r\n        _heap.entries[newInd] = can;\r\n\r\n        // Update index\r\n        if (newInd != ind) {\r\n            _heap.index[_addr] = newInd;\r\n        }\r\n    }\r\n\r\n    function bubbleUp(Heap storage _heap, uint256 _ind, uint256 _val) internal returns (uint256 ind) {\r\n        // Bubble up\r\n        ind = _ind;\r\n        if (ind != 1) {\r\n            uint256 parent = _heap.entries[ind / 2];\r\n            while (parent \u003C _val) {\r\n                // If the parent value is lower than our current value, we swap them\r\n                (_heap.entries[ind / 2], _heap.entries[ind]) = (_val, parent);\r\n\r\n                // Update moved Index\r\n                _heap.index[decodeAddress(parent)] = ind;\r\n\r\n                // change our current Index to go up to the parent\r\n                ind = ind / 2;\r\n                if (ind == 1) {\r\n                    break;\r\n                }\r\n\r\n                // Update parent\r\n                parent = _heap.entries[ind / 2];\r\n            }\r\n        }\r\n    }\r\n\r\n    function bubbleDown(Heap storage _heap, uint256 _ind, uint256 _val) internal returns (uint256 ind) {\r\n        // Bubble down\r\n        ind = _ind;\r\n\r\n        uint256 lenght = _heap.entries.length;\r\n        uint256 target = lenght - 1;\r\n\r\n        while (ind * 2 \u003C lenght) {\r\n            // get the current index of the children\r\n            uint256 j = ind * 2;\r\n\r\n            // left child value\r\n            uint256 leftChild = _heap.entries[j];\r\n\r\n            // Store the value of the child\r\n            uint256 childValue;\r\n\r\n            if (target \u003E j) {\r\n                // The parent has two childs \uD83D\uDC68\u200D\uD83D\uDC67\u200D\uD83D\uDC66\r\n\r\n                // Load right child value\r\n                uint256 rightChild = _heap.entries[j \u002B 1];\r\n\r\n                // Compare the left and right child.\r\n                // if the rightChild is greater, then point j to it\u0027s index\r\n                // and save the value\r\n                if (leftChild \u003C rightChild) {\r\n                    childValue = rightChild;\r\n                    j = j \u002B 1;\r\n                } else {\r\n                    // The left child is greater\r\n                    childValue = leftChild;\r\n                }\r\n            } else {\r\n                // The parent has a single child \uD83D\uDC68\u200D\uD83D\uDC66\r\n                childValue = leftChild;\r\n            }\r\n\r\n            // Check if the child has a lower value\r\n            if (_val \u003E childValue) {\r\n                break;\r\n            }\r\n\r\n            // else swap the value\r\n            (_heap.entries[ind], _heap.entries[j]) = (childValue, _val);\r\n\r\n            // Update moved Index\r\n            _heap.index[decodeAddress(childValue)] = ind;\r\n\r\n            // and let\u0027s keep going down the heap\r\n            ind = j;\r\n        }\r\n    }\r\n}\r\n\r\n// File: contracts/commons/StorageUnit.sol\r\n\r\npragma solidity ^0.5.10;\r\n\r\n\r\ncontract StorageUnit {\r\n    address private owner;\r\n    mapping(bytes32 =\u003E bytes32) private store;\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    function write(bytes32 _key, bytes32 _value) external {\r\n        /* solium-disable-next-line */\r\n        require(msg.sender == owner);\r\n        store[_key] = _value;\r\n    }\r\n\r\n    function read(bytes32 _key) external view returns (bytes32) {\r\n        return store[_key];\r\n    }\r\n}\r\n\r\n// File: contracts/utils/IsContract.sol\r\n\r\npragma solidity ^0.5.10;\r\n\r\n\r\nlibrary IsContract {\r\n    function isContract(address _addr) internal view returns (bool) {\r\n        bytes32 codehash;\r\n        /* solium-disable-next-line */\r\n        assembly { codehash := extcodehash(_addr) }\r\n        return codehash != bytes32(0) \u0026\u0026 codehash != bytes32(0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);\r\n    }\r\n}\r\n\r\n// File: contracts/utils/DistributedStorage.sol\r\n\r\npragma solidity ^0.5.10;\r\n\r\n\r\n\r\n\r\nlibrary DistributedStorage {\r\n    function contractSlot(bytes32 _key) private view returns (address) {\r\n        return address(\r\n            uint256(\r\n                keccak256(\r\n                    abi.encodePacked(\r\n                        byte(0xff),\r\n                        address(this),\r\n                        _key,\r\n                        keccak256(type(StorageUnit).creationCode)\r\n                    )\r\n                )\r\n            )\r\n        );\r\n    }\r\n\r\n    function deploy(bytes32 _key) private {\r\n        bytes memory slotcode = type(StorageUnit).creationCode;\r\n        /* solium-disable-next-line */\r\n        assembly{ pop(create2(0, add(slotcode, 0x20), mload(slotcode), _key)) }\r\n    }\r\n\r\n    function write(\r\n        bytes32 _struct,\r\n        bytes32 _key,\r\n        bytes32 _value\r\n    ) internal {\r\n        StorageUnit store = StorageUnit(contractSlot(_struct));\r\n        if (!IsContract.isContract(address(store))) {\r\n            deploy(_struct);\r\n        }\r\n\r\n        /* solium-disable-next-line */\r\n        (bool success, ) = address(store).call(\r\n            abi.encodeWithSelector(\r\n                store.write.selector,\r\n                _key,\r\n                _value\r\n            )\r\n        );\r\n\r\n        require(success, \u0022error writing storage\u0022);\r\n    }\r\n\r\n    function read(\r\n        bytes32 _struct,\r\n        bytes32 _key\r\n    ) internal view returns (bytes32) {\r\n        StorageUnit store = StorageUnit(contractSlot(_struct));\r\n        if (!IsContract.isContract(address(store))) {\r\n            return bytes32(0);\r\n        }\r\n\r\n        /* solium-disable-next-line */\r\n        (bool success, bytes memory data) = address(store).staticcall(\r\n            abi.encodeWithSelector(\r\n                store.read.selector,\r\n                _key\r\n            )\r\n        );\r\n\r\n        require(success, \u0022error reading storage\u0022);\r\n        return abi.decode(data, (bytes32));\r\n    }\r\n}\r\n\r\n// File: contracts/utils/SafeMath.sol\r\n\r\npragma solidity ^0.5.10;\r\n\r\n\r\nlibrary SafeMath {\r\n    function add(uint256 x, uint256 y) internal pure returns (uint256) {\r\n        uint256 z = x \u002B y;\r\n        require(z \u003E= x, \u0022Add overflow\u0022);\r\n        return z;\r\n    }\r\n\r\n    function sub(uint256 x, uint256 y) internal pure returns (uint256) {\r\n        require(x \u003E= y, \u0022Sub underflow\u0022);\r\n        return x - y;\r\n    }\r\n\r\n    function mult(uint256 x, uint256 y) internal pure returns (uint256) {\r\n        if (x == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 z = x * y;\r\n        require(z / x == y, \u0022Mult overflow\u0022);\r\n        return z;\r\n    }\r\n\r\n    function div(uint256 x, uint256 y) internal pure returns (uint256) {\r\n        require(y != 0, \u0022Div by zero\u0022);\r\n        return x / y;\r\n    }\r\n\r\n    function divRound(uint256 x, uint256 y) internal pure returns (uint256) {\r\n        require(y != 0, \u0022Div by zero\u0022);\r\n        uint256 r = x / y;\r\n        if (x % y != 0) {\r\n            r = r \u002B 1;\r\n        }\r\n\r\n        return r;\r\n    }\r\n}\r\n\r\n// File: contracts/utils/Math.sol\r\n\r\npragma solidity ^0.5.10;\r\n\r\n\r\nlibrary Math {\r\n    function orderOfMagnitude(uint256 input) internal pure returns (uint256){\r\n        uint256 counter = uint(-1);\r\n        uint256 temp = input;\r\n\r\n        do {\r\n            temp /= 10;\r\n            counter\u002B\u002B;\r\n        } while (temp != 0);\r\n\r\n        return counter;\r\n    }\r\n\r\n    function min(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n        if (_a \u003C _b) {\r\n            return _a;\r\n        } else {\r\n            return _b;\r\n        }\r\n    }\r\n}\r\n\r\n// File: contracts/utils/GasPump.sol\r\n\r\npragma solidity ^0.5.10;\r\n\r\n\r\ncontract GasPump {\r\n    bytes32 private stub;\r\n\r\n    modifier requestGas(uint256 _factor) {\r\n        if (tx.gasprice == 0) {\r\n            uint256 startgas = gasleft();\r\n            _;\r\n            uint256 delta = startgas - gasleft();\r\n            uint256 target = (delta * _factor) / 100;\r\n            startgas = gasleft();\r\n            while (startgas - gasleft() \u003C target) {\r\n                // Burn gas\r\n                stub = keccak256(abi.encodePacked(stub));\r\n            }\r\n        } else {\r\n            _;\r\n        }\r\n    }\r\n}\r\n\r\n// File: contracts/interfaces/IERC20.sol\r\n\r\npragma solidity ^0.5.10;\r\n\r\n\r\ninterface IERC20 {\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n    function transfer(address _to, uint _value) external returns (bool success);\r\n    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);\r\n    function allowance(address _owner, address _spender) external view returns (uint256 remaining);\r\n    function approve(address _spender, uint256 _value) external returns (bool success);\r\n    function balanceOf(address _owner) external view returns (uint256 balance);\r\n}\r\n\r\n// File: contracts/ShuffleToken.sol\r\n\r\npragma solidity ^0.5.10;\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\ncontract ShuffleToken is Ownable, GasPump, IERC20 {\r\n    using AddressMinHeap for AddressMinHeap.Heap;\r\n    using DistributedStorage for bytes32;\r\n    using SafeMath for uint256;\r\n\r\n    // Shuffle events\r\n    event Winner(address indexed _addr, uint256 _value);\r\n\r\n    // Heap events\r\n    event JoinHeap(address indexed _address, uint256 _balance, uint256 _prevSize);\r\n    event LeaveHeap(address indexed _address, uint256 _balance, uint256 _prevSize);\r\n\r\n    // Managment events\r\n    event SetName(string _prev, string _new);\r\n    event SetExtraGas(uint256 _prev, uint256 _new);\r\n    event WhitelistFrom(address _addr, bool _whitelisted);\r\n    event WhitelistTo(address _addr, bool _whitelisted);\r\n\r\n    uint256 public totalSupply;\r\n\r\n    bytes32 private constant BALANCE_KEY = keccak256(\u0022balance\u0022);\r\n    bytes32 private constant NONCE_KEY = keccak256(\u0022nonce\u0022);\r\n\r\n    // game\r\n    uint256 public constant FEE = 100;\r\n    uint256 public constant TOP_SIZE = 512;\r\n\r\n    // heap\r\n    AddressMinHeap.Heap private heap;\r\n\r\n    // metadata\r\n    string public name = \u0022shuffle.monster token V2\u0022;\r\n    string public constant symbol = \u0022SHUF\u0022;\r\n    uint8 public constant decimals = 18;\r\n\r\n    // fee whitelist\r\n    mapping(address =\u003E bool) public whitelistFrom;\r\n    mapping(address =\u003E bool) public whitelistTo;\r\n\r\n    // internal\r\n    uint256 public extraGas;\r\n    bool inited;\r\n\r\n    function init(\r\n        address _to,\r\n        uint256 _amount\r\n    ) external {\r\n        require(!inited);\r\n        inited = true;\r\n        heap.initialize();\r\n        extraGas = 15;\r\n        emit SetExtraGas(0, extraGas);\r\n        emit Transfer(address(0), _to, _amount);\r\n        _setBalance(_to, _amount);\r\n        totalSupply = _amount;\r\n    }\r\n\r\n    ///\r\n    // Storage access functions\r\n    ///\r\n\r\n    function _toKey(address a) internal pure returns (bytes32) {\r\n        return bytes32(uint256(a));\r\n    }\r\n\r\n    function _balanceOf(address _addr) internal view returns (uint256) {\r\n        return uint256(_toKey(_addr).read(BALANCE_KEY));\r\n    }\r\n\r\n    function _allowance(address _addr, address _spender) internal view returns (uint256) {\r\n        return uint256(_toKey(_addr).read(keccak256(abi.encodePacked(\u0022allowance\u0022, _spender))));\r\n    }\r\n\r\n    function _nonce(address _addr, uint256 _cat) internal view returns (uint256) {\r\n        return uint256(_toKey(_addr).read(keccak256(abi.encodePacked(\u0022nonce\u0022, _cat))));\r\n    }\r\n\r\n    function _setAllowance(address _addr, address _spender, uint256 _value) internal {\r\n        _toKey(_addr).write(keccak256(abi.encodePacked(\u0022allowance\u0022, _spender)), bytes32(_value));\r\n    }\r\n\r\n    function _setNonce(address _addr, uint256 _cat, uint256 _value) internal {\r\n        _toKey(_addr).write(keccak256(abi.encodePacked(\u0022nonce\u0022, _cat)), bytes32(_value));\r\n    }\r\n\r\n    function _setBalance(address _addr, uint256 _balance) internal {\r\n        _toKey(_addr).write(BALANCE_KEY, bytes32(_balance));\r\n        _computeHeap(_addr, _balance);\r\n    }\r\n\r\n    function getNonce(address _addr, uint256 _cat) external view returns (uint256) {\r\n        return _nonce(_addr, _cat);\r\n    }\r\n\r\n    ///\r\n    // Internal methods\r\n    ///\r\n\r\n    function _isWhitelisted(address _from, address _to) internal view returns (bool) {\r\n        return whitelistFrom[_from]||whitelistTo[_to];\r\n    }\r\n\r\n    function _random(address _s1, uint256 _s2, uint256 _s3, uint256 _max) internal pure returns (uint256) {\r\n        uint256 rand = uint256(keccak256(abi.encodePacked(_s1, _s2, _s3)));\r\n        return rand % (_max \u002B 1);\r\n    }\r\n\r\n    function _pickWinner(address _from, uint256 _value) internal returns (address winner) {\r\n        // Get order of magnitude of the tx\r\n        uint256 magnitude = Math.orderOfMagnitude(_value);\r\n        // Pull nonce for a given order of magnitude\r\n        uint256 nonce = _nonce(_from, magnitude);\r\n        _setNonce(_from, magnitude, nonce \u002B 1);\r\n        // pick entry from heap\r\n        (winner,) = heap.entry(_random(_from, nonce, magnitude, heap.size() - 1));\r\n    }\r\n\r\n    function _transferFrom(address _operator, address _from, address _to, uint256 _value) internal {\r\n        if (_value == 0) {\r\n            emit Transfer(_from, _to, 0);\r\n            return;\r\n        }\r\n\r\n        uint256 balanceFrom = _balanceOf(_from);\r\n        require(balanceFrom \u003E= _value, \u0022balance not enough\u0022);\r\n\r\n        if (_from != _operator) {\r\n            uint256 allowanceFrom = _allowance(_from, _operator);\r\n            if (allowanceFrom != uint(-1)) {\r\n                require(allowanceFrom \u003E= _value, \u0022allowance not enough\u0022);\r\n                _setAllowance(_from, _operator, allowanceFrom.sub(_value));\r\n            }\r\n        }\r\n\r\n        uint256 receive = _value;\r\n        _setBalance(_from, balanceFrom.sub(_value));\r\n\r\n        if (!_isWhitelisted(_from, _to)) {\r\n            uint256 burn = _value.divRound(FEE);\r\n            uint256 shuf = _value == 1 ? 0 : burn;\r\n            receive = receive.sub(burn.add(shuf));\r\n\r\n            // Burn tokens\r\n            totalSupply = totalSupply.sub(burn);\r\n            emit Transfer(_from, address(0), burn);\r\n\r\n            // Shuffle tokens\r\n            // Pick winner pseudo-randomly\r\n            address winner = _pickWinner(_from, _value);\r\n            // Transfer balance to winner\r\n            _setBalance(winner, _balanceOf(winner).add(shuf));\r\n            emit Winner(winner, shuf);\r\n            emit Transfer(_from, winner, shuf);\r\n        }\r\n\r\n        // Transfer tokens\r\n        _setBalance(_to, _balanceOf(_to).add(receive));\r\n        emit Transfer(_from, _to, receive);\r\n    }\r\n\r\n    function _computeHeap(address _addr, uint256 _new) internal {\r\n        uint256 size = heap.size();\r\n        if (size == 0) {\r\n            emit JoinHeap(_addr, _new, 0);\r\n            heap.insert(_addr, _new);\r\n            return;\r\n        }\r\n\r\n        (, uint256 lastBal) = heap.top();\r\n\r\n        if (heap.has(_addr)) {\r\n            heap.update(_addr, _new);\r\n            if (_new == 0) {\r\n                heap.popTop();\r\n                emit LeaveHeap(_addr, 0, size);\r\n            }\r\n        } else {\r\n            // IF heap is full or new bal is better than pop heap\r\n            if (_new != 0 \u0026\u0026 (size \u003C TOP_SIZE || lastBal \u003C _new)) {\r\n                // If heap is full pop heap\r\n                if (size \u003E= TOP_SIZE) {\r\n                    (address _poped, uint256 _balance) = heap.popTop();\r\n                    emit LeaveHeap(_poped, _balance, size);\r\n                }\r\n\r\n                // Insert new value\r\n                heap.insert(_addr, _new);\r\n                emit JoinHeap(_addr, _new, size);\r\n            }\r\n        }\r\n    }\r\n\r\n    ///\r\n    // Managment\r\n    ///\r\n\r\n    function setWhitelistedTo(address _addr, bool _whitelisted) external onlyOwner {\r\n        emit WhitelistTo(_addr, _whitelisted);\r\n        whitelistTo[_addr] = _whitelisted;\r\n    }\r\n\r\n    function setWhitelistedFrom(address _addr, bool _whitelisted) external onlyOwner {\r\n        emit WhitelistFrom(_addr, _whitelisted);\r\n        whitelistFrom[_addr] = _whitelisted;\r\n    }\r\n\r\n    function setName(string calldata _name) external onlyOwner {\r\n        emit SetName(name, _name);\r\n        name = _name;\r\n    }\r\n\r\n    function setExtraGas(uint256 _gas) external onlyOwner {\r\n        emit SetExtraGas(extraGas, _gas);\r\n        extraGas = _gas;\r\n    }\r\n\r\n    /////\r\n    // Heap methods\r\n    /////\r\n\r\n    function heapSize() external view returns (uint256) {\r\n        return heap.size();\r\n    }\r\n\r\n    function heapEntry(uint256 _i) external view returns (address, uint256) {\r\n        return heap.entry(_i);\r\n    }\r\n\r\n    function heapTop() external view returns (address, uint256) {\r\n        return heap.top();\r\n    }\r\n\r\n    function heapIndex(address _addr) external view returns (uint256) {\r\n        return heap.index[_addr];\r\n    }\r\n\r\n    /////\r\n    // ERC20\r\n    /////\r\n\r\n    function balanceOf(address _addr) external view returns (uint256) {\r\n        return _balanceOf(_addr);\r\n    }\r\n\r\n    function allowance(address _addr, address _spender) external view returns (uint256) {\r\n        return _allowance(_addr, _spender);\r\n    }\r\n\r\n    function approve(address _spender, uint256 _value) external returns (bool) {\r\n        emit Approval(msg.sender, _spender, _value);\r\n        _setAllowance(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    function transfer(address _to, uint256 _value) external requestGas(extraGas) returns (bool) {\r\n        _transferFrom(msg.sender, msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function transferWithFee(address _to, uint256 _value) external requestGas(extraGas) returns (bool) {\r\n        _transferFrom(msg.sender, msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) external requestGas(extraGas) returns (bool) {\r\n        _transferFrom(msg.sender, _from, _to, _value);\r\n        return true;\r\n    }\r\n}\r\n\r\nlibrary SigUtils {\r\n    /**\r\n      @dev Recovers address who signed the message\r\n      @param _hash operation ethereum signed message hash\r\n      @param _signature message \u0060hash\u0060 signature\r\n    */\r\n    function ecrecover2(\r\n        bytes32 _hash,\r\n        bytes memory _signature\r\n    ) internal pure returns (address) {\r\n        bytes32 r;\r\n        bytes32 s;\r\n        uint8 v;\r\n\r\n        /* solium-disable-next-line */\r\n        assembly {\r\n            r := mload(add(_signature, 32))\r\n            s := mload(add(_signature, 64))\r\n            v := and(mload(add(_signature, 65)), 255)\r\n        }\r\n\r\n        if (v \u003C 27) {\r\n            v \u002B= 27;\r\n        }\r\n\r\n        return ecrecover(\r\n            _hash,\r\n            v,\r\n            r,\r\n            s\r\n        );\r\n    }\r\n}\r\n\r\n\r\npragma solidity ^0.5.10;\r\n\r\n\r\n\r\n\r\n\r\n\r\ncontract Airdrop is Ownable {\r\n    using IsContract for address payable;\r\n\r\n    ShuffleToken public shuffleToken;\r\n\r\n    // Managment\r\n    uint64 public maxClaimedBy = 100;\r\n\r\n    event SetMaxClaimedBy(uint256 _max);\r\n    event SetSigner(address _signer, bool _active);\r\n    event Claimed(address _by, address _to, address _signer, uint256 _value, uint256 _claimed);\r\n    event ClaimedOwner(address _owner, uint256 _tokens);\r\n\r\n    uint256 public constant MINT_AMOUNT = 1010101010101010101010101;\r\n    uint256 public constant CREATOR_AMOUNT = (MINT_AMOUNT * 6) / 100;\r\n    uint256 public constant SHUFLE_BY_ETH = 150;\r\n    uint256 public constant MAX_CLAIM_ETH = 10 ether;\r\n\r\n    mapping(address =\u003E bool) public isSigner;\r\n\r\n    mapping(address =\u003E uint256) public claimed;\r\n    mapping(address =\u003E uint256) public numberClaimedBy;\r\n    bool public creatorClaimed;\r\n    Airdrop public prevAirdrop;\r\n\r\n    constructor(ShuffleToken _token, Airdrop _prev) public {\r\n        shuffleToken = _token;\r\n        shuffleToken.init(address(this), MINT_AMOUNT);\r\n        emit SetMaxClaimedBy(maxClaimedBy);\r\n        prevAirdrop = _prev;\r\n    }\r\n\r\n    // ///\r\n    // Managment\r\n    // ///\r\n\r\n    function setMaxClaimedBy(uint64 _max) external onlyOwner {\r\n        maxClaimedBy = _max;\r\n        emit SetMaxClaimedBy(_max);\r\n    }\r\n\r\n    function setSigner(address _signer, bool _active) external onlyOwner {\r\n        isSigner[_signer] = _active;\r\n        emit SetSigner(_signer, _active);\r\n    }\r\n\r\n    function setSigners(address[] calldata _signers, bool _active) external onlyOwner {\r\n        for (uint256 i = 0; i \u003C _signers.length; i\u002B\u002B) {\r\n            address signer = _signers[i];\r\n            isSigner[signer] = _active;\r\n            emit SetSigner(signer, _active);\r\n        }\r\n    }\r\n\r\n    // ///\r\n    // View\r\n    // ///\r\n\r\n    mapping(address =\u003E bool) private cvf;\r\n\r\n    event CallCVF(address _from, address _to);\r\n\r\n    function supportsFallback(address _to) external returns (bool) {\r\n        emit CallCVF(msg.sender, _to);\r\n        require(!cvf[msg.sender], \u0022cfv\u0022);\r\n        cvf[msg.sender] = true;\r\n        return checkFallback(_to);\r\n    }\r\n\r\n    // ///\r\n    // Airdrop\r\n    // ///\r\n\r\n    function _selfBalance() internal view returns (uint256) {\r\n        return shuffleToken.balanceOf(address(this));\r\n    }\r\n\r\n    function checkFallback(address _to) private returns (bool success) {\r\n        /* solium-disable-next-line */\r\n        (success, ) = _to.call.value(1)(\u0022\u0022);\r\n    }\r\n\r\n    function claim(\r\n        address _to,\r\n        uint256 _val,\r\n        bytes calldata _sig\r\n    ) external {\r\n        bytes32 _hash = keccak256(abi.encodePacked(_to, uint96(_val)));\r\n        address signer = SigUtils.ecrecover2(_hash, _sig);\r\n\r\n        require(isSigner[signer], \u0022signature not valid\u0022);\r\n        require(prevAirdrop.claimed(_to) == 0, \u0022already claimed in prev airdrop\u0022);\r\n\r\n        uint256 balance = _selfBalance();\r\n        uint256 claimVal = Math.min(\r\n            balance,\r\n            Math.min(\r\n                _val,\r\n                MAX_CLAIM_ETH\r\n            ) * SHUFLE_BY_ETH\r\n        );\r\n\r\n        require(claimed[_to] == 0, \u0022already claimed\u0022);\r\n        claimed[_to] = claimVal;\r\n\r\n        if (msg.sender != _to) {\r\n            uint256 _numberClaimedBy = numberClaimedBy[msg.sender];\r\n            require(_numberClaimedBy \u003C= maxClaimedBy, \u0022max claim reached\u0022);\r\n            numberClaimedBy[msg.sender] = _numberClaimedBy \u002B 1;\r\n            require(checkFallback(_to), \u0022_to address can\u0027t receive tokens\u0022);\r\n        }\r\n\r\n        shuffleToken.transferWithFee(_to, claimVal);\r\n\r\n        emit Claimed(msg.sender, _to, signer, _val, claimVal);\r\n\r\n        if (balance == claimVal \u0026\u0026 _selfBalance() == 0) {\r\n            selfdestruct(address(uint256(owner)));\r\n        }\r\n    }\r\n    \r\n    event Migrated(address _addr, uint256 _balance);\r\n    mapping(address =\u003E uint256) public migrated;\r\n    \r\n    function migrate(address _addr, uint256 _balance, uint256 _require) external {\r\n        require(isSigner[msg.sender]);\r\n        require(migrated[_addr] == _require);\r\n        migrated[_addr] = migrated[_addr] \u002B _balance;\r\n        shuffleToken.transfer(_addr, _balance);\r\n        emit Migrated(_addr, _balance);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022shuffleToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_signers\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_active\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setSigners\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022supportsFallback\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_max\u0022,\u0022type\u0022:\u0022uint64\u0022}],\u0022name\u0022:\u0022setMaxClaimedBy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_signer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_active\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setSigner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022maxClaimedBy\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint64\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022migrated\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MINT_AMOUNT\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MAX_CLAIM_ETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022CREATOR_AMOUNT\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isSigner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022numberClaimedBy\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_val\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_sig\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022claim\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022prevAirdrop\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SHUFLE_BY_ETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022claimed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022creatorClaimed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_balance\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_require\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022migrate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_prev\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_max\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022SetMaxClaimedBy\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_signer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_active\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022SetSigner\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_by\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_signer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_claimed\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Claimed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ClaimedOwner\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022CallCVF\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Migrated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022TransferOwnership\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Airdrop","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000e557091b7cc2b0bf5cdb9d1e7de1ffde0ef0e59e0000000000000000000000002c54036c505b762b6ca2873dfcfecb632f83fe27","Library":"","SwarmSource":"bzzr://e589fd44ee8048637e6f0269b3c7986c32e429b82b8ea5838c34e6ee0d6e4485"}]