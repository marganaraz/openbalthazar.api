[{"SourceCode":"pragma solidity ^0.5.1;\r\n\r\nlibrary SafeMath {\r\n  \r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003E 0);\r\n        uint256 c = a / b;\r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a);\r\n        return c;\r\n    }\r\n\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n}\r\n\r\ncontract Ownable {\r\n    \r\n    address public owner = address(0);\r\n    bool public stoped  = false;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n    event Stoped(address setter ,bool newValue);\r\n\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    modifier whenNotStoped() {\r\n        require(!stoped);\r\n        _;\r\n    }\r\n\r\n    function setStoped(bool _needStoped) public onlyOwner {\r\n        require(stoped != _needStoped);\r\n        stoped = _needStoped;\r\n        emit Stoped(msg.sender,_needStoped);\r\n    }\r\n\r\n\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(owner, address(0));\r\n        owner = address(0);\r\n    }\r\n\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(owner, newOwner);\r\n        owner = newOwner;\r\n    }\r\n}\r\n\r\ncontract Cmoable is Ownable {\r\n    address public cmo = address(0);\r\n\r\n    event CmoshipTransferred(address indexed previousCmo, address indexed newCmo);\r\n\r\n    modifier onlyCmo() {\r\n        require(msg.sender == cmo);\r\n        _;\r\n    }\r\n\r\n    function renounceCmoship() public onlyOwner {\r\n        emit CmoshipTransferred(cmo, address(0));\r\n        owner = address(0);\r\n    }\r\n\r\n    function transferCmoship(address newCmo) public onlyOwner {\r\n        _transferCmoship(newCmo);\r\n    }\r\n\r\n    function _transferCmoship(address newCmo) internal {\r\n        require(newCmo != address(0));\r\n        emit CmoshipTransferred(cmo, newCmo);\r\n        cmo = newCmo;\r\n    }\r\n}\r\n\r\n\r\ncontract BaseToken is Ownable, Cmoable {\r\n\r\n    using SafeMath for uint256;\r\n\r\n    string public name;\r\n    string public symbol;\r\n    uint8  public decimals;\r\n    uint256 public totalSupply;\r\n    uint256 public initedSupply = 0;\r\n\r\n    mapping (address =\u003E uint256) public balanceOf;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) public allowance;\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n\r\n    modifier onlyOwnerOrCmo() {\r\n        require(msg.sender == cmo || msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    function _transfer(address _from, address _to, uint256 _value) internal whenNotStoped {\r\n        require(_to != address(0x0));\r\n        require(balanceOf[_from] \u003E= _value);\r\n        require(balanceOf[_to] \u002B _value \u003E balanceOf[_to]);\r\n        uint256 previousBalances = balanceOf[_from].add(balanceOf[_to]);\r\n        balanceOf[_from] = balanceOf[_from].sub(_value);\r\n        balanceOf[_to] = balanceOf[_to].add(_value);\r\n        assert(balanceOf[_from] \u002B balanceOf[_to] == previousBalances);\r\n        emit Transfer(_from, _to, _value);\r\n    }\r\n    \r\n    function _approve(address _spender, uint256 _value) internal whenNotStoped returns (bool success) {\r\n        allowance[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    function transfer(address _to, uint256 _value) public returns (bool success) {\r\n        _transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {\r\n        require(_value \u003C= allowance[_from][msg.sender]);\r\n        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);\r\n        _transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n    \r\n    function approve(address _spender, uint256 _value) public returns (bool success) {\r\n        return _approve(_spender, _value);\r\n    }\r\n}\r\n\r\n\r\ncontract BurnToken is BaseToken {\r\n    uint256 public burnSupply = 0;\r\n    event Burn(address indexed from, uint256 value);\r\n\r\n    function _burn(address _from, uint256 _value) internal whenNotStoped returns(bool success) {\r\n        require(balanceOf[_from] \u003E= _value);\r\n        balanceOf[_from] = balanceOf[_from].sub(_value);\r\n        totalSupply = totalSupply.sub(_value);\r\n        burnSupply  = burnSupply.add(_value);\r\n        emit Burn(_from, _value);\r\n        return true;        \r\n    }\r\n\r\n    function burn(uint256 _value) public returns (bool success) {\r\n        return _burn(msg.sender,_value);\r\n    }\r\n\r\n    function burnFrom(address _from, uint256 _value) public returns (bool success) {\r\n        require(_value \u003C= allowance[_from][msg.sender]);\r\n        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);\r\n        return _burn(_from,_value);\r\n    }\r\n}\r\n\r\n\r\n\r\n\r\n\r\n \r\ncontract LockToken is BaseToken {\r\n    struct LockMeta {\r\n        uint256 amount;\r\n        uint256 endtime;\r\n        bool    deleted;\r\n    }\r\n\r\n    // 0 \u5220\u9664 1 \u9759\u6001 2 \u52A8\u6001\r\n    event Locked(uint32 indexed _type, address indexed _who, uint256 _amounts, uint256 _endtimes);\r\n    event Released(uint32 indexed _type, address indexed _who, uint256 _amounts);\r\n    //  0 \u9759\u6001 1 \u52A8\u6001 2 \u603B\u7684\r\n    mapping (address =\u003E mapping(uint32 =\u003E uint256)) public lockedAmount;\r\n     // 0 \u9759\u6001 1 \u52A8\u6001\r\n    mapping (address =\u003E mapping(uint32 =\u003E LockMeta[])) public lockedDetail;\r\n\r\n    function _transfer(address _from, address _to, uint _value) internal {\r\n        require(balanceOf[_from] \u003E= _value \u002B lockedAmount[_from][2]);\r\n        super._transfer(_from, _to, _value);\r\n    }\r\n\r\n    function lockRelease() public whenNotStoped {\r\n        \r\n        require(lockedAmount[msg.sender][3] != 0);\r\n\r\n        uint256 fronzed_released = 0;\r\n        uint256 dynamic_released = 0;\r\n\r\n        if ( lockedAmount[msg.sender][0] != 0 )\r\n        {\r\n            for (uint256 i = 0; i \u003C lockedDetail[msg.sender][0].length; i\u002B\u002B) {\r\n\r\n                LockMeta storage _meta = lockedDetail[msg.sender][0][i];\r\n                if ( !_meta.deleted \u0026\u0026 _meta.endtime \u003C= now)\r\n                {\r\n                    _meta.deleted = true;\r\n                    fronzed_released = fronzed_released.add(_meta.amount);\r\n                    emit Released(1, msg.sender, _meta.amount);\r\n                }\r\n            }\r\n        }\r\n\r\n        if ( lockedAmount[msg.sender][1] != 0 )\r\n        {\r\n            for (uint256 i = 0; i \u003C lockedDetail[msg.sender][1].length; i\u002B\u002B) {\r\n\r\n                LockMeta storage _meta = lockedDetail[msg.sender][0][i];\r\n                if ( !_meta.deleted \u0026\u0026 _meta.endtime \u003C= now)\r\n                {\r\n                    _meta.deleted = true;\r\n                    dynamic_released = dynamic_released.add(_meta.amount);\r\n                    emit Released(2, msg.sender, _meta.amount);\r\n                    \r\n                }\r\n            }\r\n        }\r\n\r\n        if ( fronzed_released \u003E 0 || dynamic_released \u003E 0 ) {\r\n            lockedAmount[msg.sender][0] = lockedAmount[msg.sender][0].sub(fronzed_released);\r\n            lockedAmount[msg.sender][1] = lockedAmount[msg.sender][1].sub(dynamic_released);\r\n            lockedAmount[msg.sender][2] = lockedAmount[msg.sender][2].sub(dynamic_released).sub(fronzed_released);\r\n        }\r\n    }\r\n\r\n    // type = 0 \u5220\u9664 1 \u9759\u6001  2 \u52A8\u6001\r\n    function lock(uint32 _type, address _who, uint256[] memory _amounts, uint256[] memory _endtimes) public  onlyOwnerOrCmo {\r\n        require(_amounts.length == _endtimes.length);\r\n\r\n        uint256 _total;\r\n\r\n        if ( _type == 2 ) {\r\n            if ( lockedDetail[_who][1].length \u003E 0 )\r\n            {\r\n                emit Locked(0, _who, lockedAmount[_who][1], 0);\r\n                delete lockedDetail[_who][1];\r\n            }\r\n\r\n            for (uint256 i = 0; i \u003C _amounts.length; i\u002B\u002B) {\r\n                _total = _total.add(_amounts[i]);\r\n                lockedDetail[_who][1].push(LockMeta({\r\n                    amount: _amounts[i],\r\n                    endtime: _endtimes[i],\r\n                    deleted:false\r\n                }));\r\n                emit Locked(2, _who, _amounts[i], _endtimes[i]);\r\n            }\r\n            lockedAmount[_who][1] = _total;\r\n            lockedAmount[_who][2] = lockedAmount[_who][0].add(_total);\r\n            return;\r\n        }\r\n\r\n\r\n        if ( _type == 1 ) {\r\n            if ( lockedDetail[_who][0].length \u003E 0 )\r\n            {\r\n                revert();\r\n            }\r\n\r\n            for (uint256 i = 0; i \u003C _amounts.length; i\u002B\u002B) {\r\n                _total = _total.add(_amounts[i]);\r\n                lockedDetail[_who][0].push(LockMeta({\r\n                    amount: _amounts[i],\r\n                    endtime: _endtimes[i],\r\n                    deleted:false\r\n                }));\r\n                emit Locked(1, _who, _amounts[i], _endtimes[i]);\r\n            }\r\n            lockedAmount[_who][0] = _total;\r\n            lockedAmount[_who][2] = lockedAmount[_who][1].add(_total);\r\n            return;\r\n        }\r\n\r\n        if ( _type == 0 ) {\r\n            lockedAmount[_who][2] = lockedAmount[_who][2].sub(lockedAmount[_who][1]);\r\n            emit Locked(0, _who, lockedAmount[_who][1], 0);\r\n            delete lockedDetail[_who][1];\r\n            \r\n        }\r\n    }\r\n}\r\n\r\ncontract Proxyable is BaseToken,BurnToken{\r\n\r\n    mapping (address =\u003E bool) public disabledProxyList;\r\n\r\n    function enableProxy() public whenNotStoped {\r\n\r\n        disabledProxyList[msg.sender] = false;\r\n    }\r\n\r\n    function disableProxy() public whenNotStoped{\r\n        disabledProxyList[msg.sender] = true;\r\n    }\r\n\r\n    function proxyBurnFrom(address _from, uint256 _value) public  onlyOwnerOrCmo returns (bool success) {\r\n        \r\n        require(!disabledProxyList[_from]);\r\n        super._burn(_from, _value);\r\n        return true;\r\n    }\r\n\r\n    function proxyTransferFrom(address _from, address _to, uint256 _value) public onlyOwnerOrCmo returns (bool success) {\r\n        \r\n        require(!disabledProxyList[_from]);\r\n        super._transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n\r\n  \r\n}\r\n\r\n \r\n\r\ncontract CSSToken is BaseToken,BurnToken,LockToken,Proxyable {\r\n\r\n    constructor() public {\r\n        \r\n  \r\n        totalSupply  = 2000000000000000000000000000;\r\n        initedSupply = 2000000000000000000000000000;\r\n        name = \u0027css\u0027;\r\n        symbol = \u0027css\u0027;\r\n        decimals = 18;\r\n        balanceOf[0x108cF041aAb8A65Cdd0A78c1DC703B0dbb0a7659] = 2000000000000000000000000000;\r\n        emit Transfer(address(0), 0x108cF041aAb8A65Cdd0A78c1DC703B0dbb0a7659, 2000000000000000000000000000);\r\n\r\n        // \u7BA1\u7406\u8005\r\n        owner = 0x108cF041aAb8A65Cdd0A78c1DC703B0dbb0a7659;\r\n        cmo   = 0x108cF041aAb8A65Cdd0A78c1DC703B0dbb0a7659;\r\n        \r\n\r\n\r\n\r\n\r\n    }\r\n\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousCmo\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newCmo\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022CmoshipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint32\u0022,\u0022name\u0022:\u0022_type\u0022,\u0022type\u0022:\u0022uint32\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_who\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amounts\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_endtimes\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Locked\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint32\u0022,\u0022name\u0022:\u0022_type\u0022,\u0022type\u0022:\u0022uint32\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_who\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amounts\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Released\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022setter\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022newValue\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022Stoped\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022burnSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022cmo\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022disableProxy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022disabledProxyList\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022enableProxy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022initedSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint32\u0022,\u0022name\u0022:\u0022_type\u0022,\u0022type\u0022:\u0022uint32\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_who\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_amounts\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_endtimes\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022lock\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022lockRelease\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint32\u0022}],\u0022name\u0022:\u0022lockedAmount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint32\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022lockedDetail\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022endtime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022deleted\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022proxyBurnFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022proxyTransferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceCmoship\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_needStoped\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setStoped\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022stoped\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newCmo\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferCmoship\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"CSSToken","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://223139715abf6edfcb6acc3384b218f827a8b137b2790910573631a56223f525"}]