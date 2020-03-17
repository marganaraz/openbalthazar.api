[{"SourceCode":"pragma solidity ^0.4.23;\r\n\r\n\r\n/**\r\n* @title ERC20Basic\r\n* @dev Simpler version of ERC20 interface\r\n*/\r\ncontract ERC20Basic {\r\nfunction totalSupply() public view returns (uint256);\r\nfunction balanceOf(address who) public view returns (uint256);\r\nfunction transfer(address to, uint256 value) public returns (bool);\r\nevent Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\n\r\n\r\n/**\r\n* @title SafeMath\r\n* @dev Math operations with safety checks that throw on error\r\n*/\r\nlibrary SafeMath {\r\n\r\n/**\r\n* @dev Multiplies two numbers, throws on overflow.\r\n*/\r\nfunction mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n// Gas optimization: this is cheaper than asserting \u0027a\u0027 not being zero, but the\r\n// benefit is lost if \u0027b\u0027 is also tested.\r\n\r\nif (a == 0) {\r\nreturn 0;\r\n}\r\n\r\nc = a * b;\r\nassert(c / a == b);\r\nreturn c;\r\n}\r\n\r\n/**\r\n* @dev Integer division of two numbers, truncating the quotient.\r\n*/\r\nfunction div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n// assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n// uint256 c = a / b;\r\n// assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\nreturn a / b;\r\n}\r\n\r\n/**\r\n* @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n*/\r\nfunction sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\nassert(b \u003C= a);\r\nreturn a - b;\r\n}\r\n\r\n/**\r\n* @dev Adds two numbers, throws on overflow.\r\n*/\r\nfunction add(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\nc = a \u002B b;\r\nassert(c \u003E= a);\r\nreturn c;\r\n}\r\n}\r\n\r\n\r\n\r\n/**\r\n* @title Basic token\r\n* @dev Basic version of StandardToken, with no allowances.\r\n*/\r\ncontract BasicToken is ERC20Basic {\r\nusing SafeMath for uint256;\r\n\r\nmapping(address =\u003E uint256) balances;\r\n\r\nuint256 totalSupply_;\r\n\r\n/**\r\n* @dev total number of tokens in existence\r\n*/\r\nfunction totalSupply() public view returns (uint256) {\r\nreturn totalSupply_;\r\n}\r\n\r\n/**\r\n* @dev transfer token for a specified address\r\n* @param _to The address to transfer to.\r\n* @param _value The amount to be transferred.\r\n*/\r\nfunction transfer(address _to, uint256 _value) public returns (bool) {\r\nrequire(_to != address(0));\r\nrequire(_value \u003C= balances[msg.sender]);\r\n\r\nbalances[msg.sender] = balances[msg.sender].sub(_value);\r\nbalances[_to] = balances[_to].add(_value);\r\nemit Transfer(msg.sender, _to, _value);\r\nreturn true;\r\n}\r\n\r\n/**\r\n* @dev Gets the balance of the specified address.\r\n* @param _owner The address to query the the balance of.\r\n* @return An uint256 representing the amount owned by the passed address.\r\n*/\r\nfunction balanceOf(address _owner) public view returns (uint256) {\r\nreturn balances[_owner];\r\n}\r\n\r\n}\r\n\r\n\r\n/**\r\n* @title ERC20 interface\r\n*/\r\ncontract ERC20 is ERC20Basic {\r\nfunction allowance(address owner, address spender)\r\npublic view returns (uint256);\r\n\r\nfunction transferFrom(address from, address to, uint256 value)\r\npublic returns (bool);\r\n\r\nfunction approve(address spender, uint256 value) public returns (bool);\r\nevent Approval(\r\naddress indexed owner,\r\naddress indexed spender,\r\nuint256 value\r\n);\r\n}\r\n\r\n\r\n/**\r\n* @title Standard ERC20 token\r\n*\r\n* @dev Implementation of the basic standard token.\r\n* @dev https://github.com/ethereum/EIPs/issues/20\r\n* @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\r\n*/\r\ncontract StandardToken is ERC20, BasicToken {\r\n\r\nmapping (address =\u003E mapping (address =\u003E uint256)) internal allowed;\r\n\r\n\r\n/**\r\n* @dev Transfer tokens from one address to another\r\n* @param _from address The address which you want to send tokens from\r\n* @param _to address The address which you want to transfer to\r\n* @param _value uint256 the amount of tokens to be transferred\r\n*/\r\nfunction transferFrom(\r\naddress _from,\r\naddress _to,\r\nuint256 _value\r\n)\r\npublic\r\nreturns (bool)\r\n{\r\nrequire(_to != address(0));\r\nrequire(_value \u003C= balances[_from]);\r\nrequire(_value \u003C= allowed[_from][msg.sender]);\r\n\r\nbalances[_from] = balances[_from].sub(_value);\r\nbalances[_to] = balances[_to].add(_value);\r\nallowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\nemit Transfer(_from, _to, _value);\r\nreturn true;\r\n}\r\n\r\n/**\r\n* @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n* @param _spender The address which will spend the funds.\r\n* @param _value The amount of tokens to be spent.\r\n*/\r\nfunction approve(address _spender, uint256 _value) public returns (bool) {\r\nallowed[msg.sender][_spender] = _value;\r\nemit Approval(msg.sender, _spender, _value);\r\nreturn true;\r\n}\r\n\r\n/**\r\n* @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n* @param _owner address The address which owns the funds.\r\n* @param _spender address The address which will spend the funds.\r\n* @return A uint256 specifying the amount of tokens still available for the spender.\r\n*/\r\nfunction allowance(\r\naddress _owner,\r\naddress _spender\r\n)\r\npublic\r\nview\r\nreturns (uint256)\r\n{\r\nreturn allowed[_owner][_spender];\r\n}\r\n\r\n/**\r\n* @dev Increase the amount of tokens that an owner allowed to a spender.\r\n*\r\n* approve should be called when allowed[_spender] == 0. To increment\r\n* allowed value is better to use this function to avoid 2 calls (and wait until\r\n* the first transaction is mined)\r\n* From MonolithDAO Token.sol\r\n* @param _spender The address which will spend the funds.\r\n* @param _addedValue The amount of tokens to increase the allowance by.\r\n*/\r\nfunction increaseApproval(\r\naddress _spender,\r\nuint _addedValue\r\n)\r\npublic\r\nreturns (bool)\r\n{\r\nallowed[msg.sender][_spender] = (\r\nallowed[msg.sender][_spender].add(_addedValue));\r\nemit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\nreturn true;\r\n}\r\n\r\n/**\r\n* @dev Decrease the amount of tokens that an owner allowed to a spender.\r\n*\r\n* approve should be called when allowed[_spender] == 0. To decrement\r\n* allowed value is better to use this function to avoid 2 calls (and wait until\r\n* the first transaction is mined)\r\n* From MonolithDAO Token.sol\r\n* @param _spender The address which will spend the funds.\r\n* @param _subtractedValue The amount of tokens to decrease the allowance by.\r\n*/\r\nfunction decreaseApproval(\r\naddress _spender,\r\nuint _subtractedValue\r\n)\r\npublic\r\nreturns (bool)\r\n{\r\nuint oldValue = allowed[msg.sender][_spender];\r\nif (_subtractedValue \u003E oldValue) {\r\nallowed[msg.sender][_spender] = 0;\r\n} else {\r\nallowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\r\n}\r\nemit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\nreturn true;\r\n}\r\n\r\n}\r\n\r\n\r\n\r\n/**\r\n* @title Ownable\r\n* @dev The Ownable contract has an owner address, and provides basic authorization control\r\n* functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n*/\r\ncontract Ownable {\r\naddress public owner;\r\n\r\n\r\nevent OwnershipRenounced(address indexed previousOwner);\r\nevent OwnershipTransferred(\r\naddress indexed previousOwner,\r\naddress indexed newOwner\r\n);\r\n\r\n\r\n/**\r\n* @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n* account.\r\n*/\r\nconstructor() public {\r\nowner = msg.sender;\r\n}\r\n\r\n/**\r\n* @dev Throws if called by any account other than the owner.\r\n*/\r\nmodifier onlyOwner() {\r\nrequire(msg.sender == owner);\r\n_;\r\n}\r\n\r\n/**\r\n* @dev Allows the current owner to relinquish control of the contract.\r\n*/\r\nfunction renounceOwnership() public onlyOwner {\r\nemit OwnershipRenounced(owner);\r\nowner = address(0);\r\n}\r\n\r\n/**\r\n* @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n* @param _newOwner The address to transfer ownership to.\r\n*/\r\nfunction transferOwnership(address _newOwner) public onlyOwner {\r\n_transferOwnership(_newOwner);\r\n}\r\n\r\n/**\r\n* @dev Transfers control of the contract to a newOwner.\r\n* @param _newOwner The address to transfer ownership to.\r\n*/\r\nfunction _transferOwnership(address _newOwner) internal {\r\nrequire(_newOwner != address(0));\r\nemit OwnershipTransferred(owner, _newOwner);\r\nowner = _newOwner;\r\n}\r\n}\r\n\r\n\r\n/**\r\n* @title Mintable token\r\n*/\r\ncontract MintableToken is StandardToken, Ownable {\r\nevent Mint(address indexed to, uint256 amount);\r\nevent MintFinished();\r\n\r\nbool public mintingFinished = false;\r\n\r\n\r\nmodifier canMint() {\r\nrequire(!mintingFinished);\r\n_;\r\n}\r\n\r\nmodifier hasMintPermission() {\r\nrequire(msg.sender == owner);\r\n_;\r\n}\r\n\r\n/**\r\n* @dev Function to mint tokens\r\n* @param _to The address that will receive the minted tokens.\r\n* @param _amount The amount of tokens to mint.\r\n* @return A boolean that indicates if the operation was successful.\r\n*/\r\nfunction mint(\r\naddress _to,\r\nuint256 _amount\r\n)\r\nhasMintPermission\r\ncanMint\r\npublic\r\nreturns (bool)\r\n{\r\ntotalSupply_ = totalSupply_.add(_amount);\r\nbalances[_to] = balances[_to].add(_amount);\r\nemit Mint(_to, _amount);\r\nemit Transfer(address(0), _to, _amount);\r\nreturn true;\r\n}\r\n\r\n/**\r\n* @dev Function to stop minting new tokens.\r\n* @return True if the operation was successful.\r\n*/\r\nfunction finishMinting() onlyOwner canMint public returns (bool) {\r\nmintingFinished = true;\r\nemit MintFinished();\r\nreturn true;\r\n}\r\n}\r\n\r\n\r\ncontract FreezableToken is StandardToken {\r\n// freezing chains\r\nmapping (bytes32 =\u003E uint64) internal chains;\r\n// freezing amounts for each chain\r\nmapping (bytes32 =\u003E uint) internal freezings;\r\n// total freezing balance per address\r\nmapping (address =\u003E uint) internal freezingBalance;\r\n\r\nevent Freezed(address indexed to, uint64 release, uint amount);\r\nevent Released(address indexed owner, uint amount);\r\n\r\n/**\r\n* @dev Gets the balance of the specified address include freezing tokens.\r\n* @param _owner The address to query the the balance of.\r\n* @return An uint256 representing the amount owned by the passed address.\r\n*/\r\nfunction balanceOf(address _owner) public view returns (uint256 balance) {\r\nreturn super.balanceOf(_owner) \u002B freezingBalance[_owner];\r\n}\r\n\r\n/**\r\n* @dev Gets the balance of the specified address without freezing tokens.\r\n* @param _owner The address to query the the balance of.\r\n* @return An uint256 representing the amount owned by the passed address.\r\n*/\r\nfunction actualBalanceOf(address _owner) public view returns (uint256 balance) {\r\nreturn super.balanceOf(_owner);\r\n}\r\n\r\nfunction freezingBalanceOf(address _owner) public view returns (uint256 balance) {\r\nreturn freezingBalance[_owner];\r\n}\r\n\r\n/**\r\n* @dev gets freezing count\r\n* @param _addr Address of freeze tokens owner.\r\n*/\r\nfunction freezingCount(address _addr) public view returns (uint count) {\r\nuint64 release = chains[toKey(_addr, 0)];\r\nwhile (release != 0) {\r\ncount\u002B\u002B;\r\nrelease = chains[toKey(_addr, release)];\r\n}\r\n}\r\n\r\n/**\r\n* @dev gets freezing end date and freezing balance for the freezing portion specified by index.\r\n* @param _addr Address of freeze tokens owner.\r\n* @param _index Freezing portion index. It ordered by release date descending.\r\n*/\r\nfunction getFreezing(address _addr, uint _index) public view returns (uint64 _release, uint _balance) {\r\nfor (uint i = 0; i \u003C _index \u002B 1; i\u002B\u002B) {\r\n_release = chains[toKey(_addr, _release)];\r\nif (_release == 0) {\r\nreturn;\r\n}\r\n}\r\n_balance = freezings[toKey(_addr, _release)];\r\n}\r\n\r\n/**\r\n* @dev freeze your tokens to the specified address.\r\n* Be careful, gas usage is not deterministic,\r\n* and depends on how many freezes _to address already has.\r\n* @param _to Address to which token will be freeze.\r\n* @param _amount Amount of token to freeze.\r\n* @param _until Release date, must be in future.\r\n*/\r\nfunction freezeTo(address _to, uint _amount, uint64 _until) public {\r\nrequire(_to != address(0));\r\nrequire(_amount \u003C= balances[msg.sender]);\r\n\r\nbalances[msg.sender] = balances[msg.sender].sub(_amount);\r\n\r\nbytes32 currentKey = toKey(_to, _until);\r\nfreezings[currentKey] = freezings[currentKey].add(_amount);\r\nfreezingBalance[_to] = freezingBalance[_to].add(_amount);\r\n\r\nfreeze(_to, _until);\r\nemit Transfer(msg.sender, _to, _amount);\r\nemit Freezed(_to, _until, _amount);\r\n}\r\n\r\n/**\r\n* @dev release first available freezing tokens.\r\n*/\r\nfunction releaseOnce() public {\r\nbytes32 headKey = toKey(msg.sender, 0);\r\nuint64 head = chains[headKey];\r\nrequire(head != 0);\r\nrequire(uint64(block.timestamp) \u003E head);\r\nbytes32 currentKey = toKey(msg.sender, head);\r\n\r\nuint64 next = chains[currentKey];\r\n\r\nuint amount = freezings[currentKey];\r\ndelete freezings[currentKey];\r\n\r\nbalances[msg.sender] = balances[msg.sender].add(amount);\r\nfreezingBalance[msg.sender] = freezingBalance[msg.sender].sub(amount);\r\n\r\nif (next == 0) {\r\ndelete chains[headKey];\r\n} else {\r\nchains[headKey] = next;\r\ndelete chains[currentKey];\r\n}\r\nemit Released(msg.sender, amount);\r\n}\r\n\r\n/**\r\n* @dev release all available for release freezing tokens. Gas usage is not deterministic!\r\n* @return how many tokens was released\r\n*/\r\nfunction releaseAll() public returns (uint tokens) {\r\nuint release;\r\nuint balance;\r\n(release, balance) = getFreezing(msg.sender, 0);\r\nwhile (release != 0 \u0026\u0026 block.timestamp \u003E release) {\r\nreleaseOnce();\r\ntokens \u002B= balance;\r\n(release, balance) = getFreezing(msg.sender, 0);\r\n}\r\n}\r\n\r\nfunction toKey(address _addr, uint _release) internal pure returns (bytes32 result) {\r\n// WISH masc to increase entropy\r\nresult = 0x5749534800000000000000000000000000000000000000000000000000000000;\r\nassembly {\r\nresult := or(result, mul(_addr, 0x10000000000000000))\r\nresult := or(result, _release)\r\n}\r\n}\r\n\r\nfunction freeze(address _to, uint64 _until) internal {\r\nrequire(_until \u003E block.timestamp);\r\nbytes32 key = toKey(_to, _until);\r\nbytes32 parentKey = toKey(_to, uint64(0));\r\nuint64 next = chains[parentKey];\r\n\r\nif (next == 0) {\r\nchains[parentKey] = _until;\r\nreturn;\r\n}\r\n\r\nbytes32 nextKey = toKey(_to, next);\r\nuint parent;\r\n\r\nwhile (next != 0 \u0026\u0026 _until \u003E next) {\r\nparent = next;\r\nparentKey = nextKey;\r\n\r\nnext = chains[nextKey];\r\nnextKey = toKey(_to, next);\r\n}\r\n\r\nif (_until == next) {\r\nreturn;\r\n}\r\n\r\nif (next != 0) {\r\nchains[key] = next;\r\n}\r\n\r\nchains[parentKey] = _until;\r\n}\r\n}\r\n\r\n\r\n/**\r\n* @title Burnable Token\r\n* @dev Token that can be irreversibly burned (destroyed).\r\n*/\r\ncontract BurnableToken is BasicToken {\r\n\r\nevent Burn(address indexed burner, uint256 value);\r\n\r\n/**\r\n* @dev Burns a specific amount of tokens.\r\n* @param _value The amount of token to be burned.\r\n*/\r\nfunction burn(uint256 _value) public {\r\n_burn(msg.sender, _value);\r\n}\r\n\r\nfunction _burn(address _who, uint256 _value) internal {\r\nrequire(_value \u003C= balances[_who]);\r\n// no need to require value \u003C= totalSupply, since that would imply the\r\n// sender\u0027s balance is greater than the totalSupply, which *should* be an assertion failure\r\n\r\nbalances[_who] = balances[_who].sub(_value);\r\ntotalSupply_ = totalSupply_.sub(_value);\r\nemit Burn(_who, _value);\r\nemit Transfer(_who, address(0), _value);\r\n}\r\n}\r\n\r\n\r\n\r\n/**\r\n* @title Pausable\r\n* @dev Base contract which allows children to implement an emergency stop mechanism.\r\n*/\r\ncontract Pausable is Ownable {\r\nevent Pause();\r\nevent Unpause();\r\n\r\nbool public paused = false;\r\n\r\n\r\n/**\r\n* @dev Modifier to make a function callable only when the contract is not paused.\r\n*/\r\nmodifier whenNotPaused() {\r\nrequire(!paused);\r\n_;\r\n}\r\n\r\n/**\r\n* @dev Modifier to make a function callable only when the contract is paused.\r\n*/\r\nmodifier whenPaused() {\r\nrequire(paused);\r\n_;\r\n}\r\n\r\n/**\r\n* @dev called by the owner to pause, triggers stopped state\r\n*/\r\nfunction pause() onlyOwner whenNotPaused public {\r\npaused = true;\r\nemit Pause();\r\n}\r\n\r\n/**\r\n* @dev called by the owner to unpause, returns to normal state\r\n*/\r\nfunction unpause() onlyOwner whenPaused public {\r\npaused = false;\r\nemit Unpause();\r\n}\r\n}\r\n\r\n\r\ncontract FreezableMintableToken is FreezableToken, MintableToken {\r\n/**\r\n* @dev Mint the specified amount of token to the specified address and freeze it until the specified date.\r\n* Be careful, gas usage is not deterministic,\r\n* and depends on how many freezes _to address already has.\r\n* @param _to Address to which token will be freeze.\r\n* @param _amount Amount of token to mint and freeze.\r\n* @param _until Release date, must be in future.\r\n* @return A boolean that indicates if the operation was successful.\r\n*/\r\nfunction mintAndFreeze(address _to, uint _amount, uint64 _until) public onlyOwner canMint returns (bool) {\r\ntotalSupply_ = totalSupply_.add(_amount);\r\n\r\nbytes32 currentKey = toKey(_to, _until);\r\nfreezings[currentKey] = freezings[currentKey].add(_amount);\r\nfreezingBalance[_to] = freezingBalance[_to].add(_amount);\r\n\r\nfreeze(_to, _until);\r\nemit Mint(_to, _amount);\r\nemit Freezed(_to, _until, _amount);\r\nemit Transfer(msg.sender, _to, _amount);\r\nreturn true;\r\n}\r\n}\r\n\r\n\r\n\r\ncontract Consts {\r\nuint public constant TOKEN_DECIMALS = 18;\r\nuint8 public constant TOKEN_DECIMALS_UINT8 = 18;\r\nuint public constant TOKEN_DECIMAL_MULTIPLIER = 10 ** TOKEN_DECIMALS;\r\n\r\nstring public constant TOKEN_NAME = \u0027EduCoin\u0027;\r\nstring public constant TOKEN_SYMBOL = \u0022EDC\u0022;\r\nbool public constant PAUSED = false;\r\naddress public constant TARGET_USER = 0x0f53f511fBbC795f4e8F7b1516159638fb2D409B;\r\n\r\nbool public constant CONTINUE_MINTING = true;\r\n}\r\n\r\n\r\n\r\n\r\ncontract EduCoin is Consts, FreezableMintableToken, BurnableToken, Pausable\r\n\r\n{\r\n\r\nevent Initialized();\r\nbool public initialized = false;\r\n\r\nconstructor() public {\r\ninit();\r\ntransferOwnership(TARGET_USER);\r\n}\r\n\r\n\r\nfunction name() public pure returns (string _name) {\r\nreturn TOKEN_NAME;\r\n}\r\n\r\nfunction symbol() public pure returns (string _symbol) {\r\nreturn TOKEN_SYMBOL;\r\n}\r\n\r\nfunction decimals() public pure returns (uint8 _decimals) {\r\nreturn TOKEN_DECIMALS_UINT8;\r\n}\r\n\r\nfunction transferFrom(address _from, address _to, uint256 _value) public returns (bool _success) {\r\nrequire(!paused);\r\nreturn super.transferFrom(_from, _to, _value);\r\n}\r\n\r\nfunction transfer(address _to, uint256 _value) public returns (bool _success) {\r\nrequire(!paused);\r\nreturn super.transfer(_to, _value);\r\n}\r\n\r\n\r\nfunction init() private {\r\nrequire(!initialized);\r\ninitialized = true;\r\n\r\nif (PAUSED) {\r\npause();\r\n}\r\n\r\n\r\naddress[1] memory addresses = [address(0x0f53f511fBbC795f4e8F7b1516159638fb2D409B)];\r\nuint[1] memory amounts = [uint(2000000000000000000000000000)];\r\nuint64[1] memory freezes = [uint64(0)];\r\n\r\nfor (uint i = 0; i \u003C addresses.length; i\u002B\u002B) {\r\nif (freezes[i] == 0) {\r\nmint(addresses[i], amounts[i]);\r\n} else {\r\nmintAndFreeze(addresses[i], amounts[i], freezes[i]);\r\n}\r\n}\r\n\r\n\r\nif (!CONTINUE_MINTING) {\r\nfinishMinting();\r\n}\r\n\r\nemit Initialized();\r\n}\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022CONTINUE_MINTING\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getFreezing\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_release\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022_balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022mintingFinished\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_until\u0022,\u0022type\u0022:\u0022uint64\u0022}],\u0022name\u0022:\u0022mintAndFreeze\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022initialized\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022actualBalanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_NAME\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_SYMBOL\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_decimals\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_until\u0022,\u0022type\u0022:\u0022uint64\u0022}],\u0022name\u0022:\u0022freezeTo\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_DECIMAL_MULTIPLIER\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_DECIMALS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022releaseAll\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022releaseOnce\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TARGET_USER\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022finishMinting\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022PAUSED\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022freezingCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022count\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_DECIMALS_UINT8\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022freezingBalanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Initialized\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Pause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Unpause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022burner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Mint\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MintFinished\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipRenounced\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022release\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Freezed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Released\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"EduCoin","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://ba6cc0c3cf222fba49ba4a698570db165aa989e557fb23ea5e3adf58b75c81db"}]