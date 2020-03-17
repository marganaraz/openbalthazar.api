[{"SourceCode":"pragma solidity ^0.4.25;\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n        uint256 c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n    address public owner;\r\n\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n\r\n    /**\r\n    * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n    * account.\r\n    */\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    /**\r\n    * @dev Throws if called by any account other than the owner.\r\n    */\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    /**\r\n    * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n    * @param newOwner The address to transfer ownership to.\r\n    */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(owner, newOwner);\r\n        owner = newOwner;\r\n    }\r\n}\r\n\r\n/**\r\n * @title ERC20Basic\r\n */\r\ncontract ERC20Basic {\r\n    uint256 public totalSupply;\r\n    function balanceOf(address who) public view returns (uint256);\r\n    function transfer(address to, uint256 value) public returns (bool);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ncontract ERC20 is ERC20Basic {\r\n    function allowance(address owner, address spender) public view returns (uint256);\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool);\r\n    function approve(address spender, uint256 value) public returns (bool);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n/**\r\n * @title Basic token\r\n * @dev Basic version of StandardToken, with no allowances. \r\n */\r\ncontract BasicToken is ERC20Basic, Ownable {\r\n\r\n    using SafeMath for uint256;\r\n\r\n    mapping(address =\u003E uint256) balances;\r\n\r\n    /**\r\n    * @dev transfer token for a specified address\r\n    * @param _to The address to transfer to.\r\n    * @param _value The amount to be transferred.\r\n    */\r\n    function transfer(address _to, uint256 _value) public returns (bool) {\r\n        require(_to != address(0));\r\n        require(_value \u003C= balances[msg.sender]);\r\n\r\n        // SafeMath.sub will throw if there is not enough balance.\r\n        balances[msg.sender] = balances[msg.sender].sub(_value);\r\n        balances[_to] = balances[_to].add(_value);\r\n        emit Transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Gets the balance of the specified address.\r\n    * @param _owner The address to query the the balance of. \r\n    * @return An uint256 representing the amount owned by the passed address.\r\n    */\r\n    function balanceOf(address _owner) public view returns (uint256 balance) {\r\n        return balances[_owner];\r\n    }\r\n    \r\n}\r\n\r\n\r\n/** Smart contract for controlling of where and when tokens are distributed duting crowdsale\r\n * Stores addresses of wallets which will receive tokens according to different parts of crowdsale for furthet distribution\r\n * Also it controls when certain number of tokens is unfrozen\r\n * */\r\ncontract PromTokenVault is Ownable{\r\n    \r\n    using SafeMath for uint256;\r\n\r\n    // amount of seconds in 1 month\r\n    // uint256 MONTH = 3;\r\n    uint256 MONTH = 2592000;\r\n    // address of token smart contract\r\n    address token_;\r\n\r\n    bytes4 publicKey = \u00220x1\u0022;\r\n    bytes4 liquidityKey = \u00220x2\u0022;\r\n    bytes4 teamKey = \u00220x3\u0022;\r\n    bytes4 companyKey = \u00220x4\u0022;\r\n    bytes4 privateKey = \u00220x5\u0022;\r\n    bytes4 communityKey = \u00220x6\u0022;\r\n    bytes4 ecosystemKey = \u00220x7\u0022;\r\n    \r\n    // these are addresses which will receive tokens according to respective parts of crowdsale    \r\n    address liquidity_;\r\n    address team_;\r\n    address company_;\r\n    address private_; \r\n    address community_;\r\n    address ecosystem_;\r\n\r\n    // stores data on the amount of tokens released according to different parts of crowdsale\r\n    mapping (bytes4=\u003Euint256) alreadyWithdrawn;\r\n\r\n    // time when Token Generation Event occurs\r\n    uint256 TGE_timestamp;\r\n    ERC20 token;\r\n    constructor(\r\n                address _token, \r\n                address _private, \r\n                address _ecosystem,\r\n                address _liquidity, \r\n                address _team, \r\n                address _company, \r\n                address _community\r\n                ) public {\r\n        token = ERC20(_token);\r\n        private_ = _private;\r\n        ecosystem_ = _ecosystem;\r\n        liquidity_ = _liquidity;\r\n        team_ = _team;\r\n        company_ = _company; \r\n        community_ = _community;\r\n        TGE_timestamp = block.timestamp;\r\n    }\r\n    \r\n    /**\r\n     * @dev Get the addresses to which tokens intended for respective part tokensale can be transferred;\r\n    */\r\n    function getLiqudityAddress() public view returns(address){\r\n        return liquidity_;\r\n    }\r\n    \r\n    function getTeamAddress() public view returns(address){\r\n        return team_;\r\n    }\r\n\r\n    function getCompanyAddress() public view returns(address){\r\n        return company_;\r\n    }\r\n    \r\n    function getPrivateAddress() public view returns(address){\r\n        return private_;\r\n    }\r\n    \r\n    function getCommunityAddress() public view returns(address){\r\n        return community_;\r\n    }\r\n\r\n    function getEcosystemAddress() public view returns(address){\r\n        return ecosystem_;\r\n    }\r\n\r\n    /**\r\n     * @dev Set the address to which tokens intended for part of tokensale can be transferred; Usable only by owner of smart contract;\r\n    */\r\n    function setLiqudityAddress(address _liquidity) public onlyOwner{\r\n        liquidity_ = _liquidity;\r\n    }\r\n\r\n    function setTeamAddress(address _team) public onlyOwner{\r\n        team_ = _team;\r\n    }\r\n\r\n    function setCompanyAddress(address _company) public onlyOwner{\r\n        company_ = _company;\r\n    }\r\n\r\n    function setPrivateAddress(address _private) public onlyOwner{\r\n        private_ = _private;\r\n    }\r\n\r\n    function setCommunityAddress(address _community) public onlyOwner{\r\n        community_ = _community;\r\n    }\r\n    function setEcosystemAddress(address _ecosystem) public onlyOwner{\r\n        ecosystem_ = _ecosystem;\r\n    }\r\n\r\n\r\n    /**\r\n     * @dev Get how many tokens are still available for releaseal according to emmision rules of public part of tokensale\r\n    */   \r\n    function getLiquidityAvailable() public view returns(uint256){\r\n        return getLiquidityReleasable().sub(alreadyWithdrawn[liquidityKey]);\r\n    }    \r\n    function getTeamAvailable() public view returns(uint256){\r\n        return getTeamReleasable().sub(alreadyWithdrawn[teamKey]);\r\n    }    \r\n    function getCompanyAvailable() public view returns(uint256){\r\n        return getCompanyReleasable().sub(alreadyWithdrawn[companyKey]);\r\n    }    \r\n    function getPrivateAvailable() public view returns(uint256){\r\n        return getPrivateReleasable().sub(alreadyWithdrawn[privateKey]);\r\n    }    \r\n    function getCommunityAvailable() public view returns(uint256){\r\n        return getCommunityReleasable().sub(alreadyWithdrawn[communityKey]);\r\n    }    \r\n    function getEcosystemAvailable() public view returns(uint256){\r\n        return getEcosystemReleasable().sub(alreadyWithdrawn[ecosystemKey]);\r\n    }    \r\n\r\n    /**\r\n     * @dev Get the total amount of tokens emitted which are intended for respective part of crowdsale \r\n    */\r\n\r\n    function getPercentReleasable(uint256 _part, uint256 _full) internal pure returns(uint256){\r\n        if(_part \u003E= _full){\r\n            _part = _full;\r\n        }\r\n        return _part;\r\n    }\r\n    \r\n    function getMonthsPassed(uint256 _since) internal view returns(uint256){\r\n        return (block.timestamp.sub(_since)).div(MONTH);\r\n    }\r\n\r\n    // LIQUIDITY TOKENSALE; 5.75% for liquidity sale; available after TGE\r\n    function getLiquidityReleasable() public view returns(uint256){\r\n        if(block.timestamp \u003E= TGE_timestamp){\r\n            return token.totalSupply().div(10000).mul(575) - (85000 \u002B 3) * 10 ** uint256(18);\r\n        }else{\r\n            return 0;\r\n        }\r\n    }\r\n    \r\n    // TEAM \u0026 ADVISORS; 5% for team \u0026 advisors; 100% are locked for 12 month, then vesting 3% per month\r\n    function getTeamReleasable() public view returns(uint256){\r\n        uint256 unlockDate = TGE_timestamp.add(MONTH.mul(12));\r\n        if(block.timestamp \u003E= unlockDate){\r\n            uint256 totalReleasable = token.totalSupply().div(100).mul(5);\r\n            uint256 monthPassed = getMonthsPassed(unlockDate)\u002B1;\r\n            return totalReleasable.div(100).mul(getPercentReleasable((monthPassed.mul(3)),100));\r\n        }else{\r\n            return 0;\r\n        }\r\n    }\r\n\r\n    // TODO: unlocks after 13 month, not 12\r\n    // COMPANY; 15% for company reserve; 100% are locked for 12 month, then vesting 3% per month\r\n    function getCompanyReleasable() public view returns(uint256){\r\n        uint256 unlockDate = TGE_timestamp.add(MONTH.mul(12));\r\n        if(now \u003E= unlockDate){\r\n            uint256 totalReleasable = token.totalSupply().div(100).mul(15);\r\n            uint256 monthPassed = getMonthsPassed(unlockDate)\u002B1;\r\n            return totalReleasable.div(100).mul(getPercentReleasable(monthPassed.mul(3),100));\r\n        }else{\r\n            return 0;\r\n        }\r\n    }\r\n\r\n    //PRIVATE SALE; 20% for private sale; 40% at listing, 60% of tokens are locked for 6 month, then vested by 10% per month\r\n    function getPrivateReleasable() public view returns(uint256){\r\n        uint256 totalReleasable = token.totalSupply().div(100).mul(20);\r\n        uint256 firstPart = totalReleasable.div(100).mul(40);\r\n        uint256 currentlyReleasable = firstPart;\r\n        uint256 unlockDate = TGE_timestamp.add(MONTH.mul(6));\r\n\r\n        if(now \u003E= unlockDate){\r\n            uint256 monthPassed = getMonthsPassed(unlockDate)\u002B1;\r\n            uint256 secondPart = totalReleasable.div(100).mul(getPercentReleasable(monthPassed.mul(10),60));\r\n            currentlyReleasable = firstPart.add(secondPart);\r\n        }\r\n        return currentlyReleasable;\r\n    }\r\n\r\n    // COMMUNITY; 45% for community minting; frozen for 6 month\r\n    function getCommunityReleasable() public view returns(uint256){\r\n        uint256 unfreezeTimestamp = TGE_timestamp.add(MONTH.mul(6));\r\n        if(now \u003E= unfreezeTimestamp){\r\n            return token.totalSupply().div(100).mul(45);\r\n        }else{\r\n            return 0;\r\n        }\r\n    }\r\n\r\n    // ECOSYSTEM; 5% for ecosystem; 25% after TGE, then 25% per 6 month\r\n    function getEcosystemReleasable() public view returns(uint256){\r\n        uint256 currentlyReleasable = 0;\r\n        if(block.timestamp \u003E= TGE_timestamp){\r\n            uint256 totalReleasable = token.totalSupply().div(100).mul(5);\r\n            uint256 firstPart = totalReleasable.div(100).mul(25);\r\n            uint256 monthPassed = getMonthsPassed(TGE_timestamp);\r\n            uint256 releases = monthPassed.div(6); \r\n            uint256 secondPart = totalReleasable.div(100).mul(getPercentReleasable(releases.mul(25),75));\r\n            currentlyReleasable = firstPart.add(secondPart);\r\n        }\r\n        return currentlyReleasable;\r\n    }\r\n    function incrementReleased(bytes4 _key, uint256 _amount) internal{\r\n        alreadyWithdrawn[_key]=alreadyWithdrawn[_key].add(_amount);\r\n    }\r\n    /**\r\n     * @dev Transfer all tokens intended for respective part of crowdsale to the wallet which will be distribute these tokens\r\n     */ \r\n    function releaseLiqudity() public{\r\n        require(token.balanceOf(address(this))\u003E=getLiquidityAvailable(),\u0027Vault does not have enough tokens\u0027);\r\n        uint256 toSend = getLiquidityAvailable();\r\n        incrementReleased(liquidityKey,toSend);\r\n        require(token.transfer(liquidity_, toSend),\u0027Token Transfer returned false\u0027);\r\n    }\r\n    function releaseTeam() public{\r\n        require(token.balanceOf(address(this))\u003E=getTeamAvailable(),\u0027Vault does not have enough tokens\u0027);\r\n        uint256 toSend = getTeamAvailable();\r\n        incrementReleased(teamKey,toSend);\r\n        require(token.transfer(team_, toSend),\u0027Token Transfer returned false\u0027);\r\n    }\r\n    function releaseCompany() public{\r\n        require(token.balanceOf(address(this))\u003E=getCompanyAvailable(),\u0027Vault does not have enough tokens\u0027);\r\n        uint256 toSend = getCompanyAvailable();\r\n        incrementReleased(companyKey,toSend);\r\n        require(token.transfer(company_, toSend),\u0027Token Transfer returned false\u0027);\r\n    }\r\n    function releasePrivate() public{\r\n        require(token.balanceOf(address(this))\u003E=getPrivateAvailable(),\u0027Vault does not have enough tokens\u0027);\r\n        uint256 toSend = getPrivateAvailable();\r\n        incrementReleased(privateKey,toSend);\r\n        require(token.transfer(private_, toSend),\u0027Token Transfer returned false\u0027);\r\n    }\r\n    function releaseCommunity() public{\r\n        require(token.balanceOf(address(this))\u003E=getCommunityAvailable(),\u0027Vault does not have enough tokens\u0027);\r\n        uint256 toSend = getCommunityAvailable();\r\n        incrementReleased(communityKey,toSend);\r\n        require(token.transfer(community_, toSend),\u0027Token Transfer returned false\u0027);\r\n    }\r\n    function releaseEcosystem() public{\r\n        require(token.balanceOf(address(this))\u003E=getEcosystemAvailable(),\u0027Vault does not have enough tokens\u0027);\r\n        uint256 toSend = getEcosystemAvailable();\r\n        incrementReleased(ecosystemKey,toSend);\r\n        require(token.transfer(ecosystem_, toSend),\u0027Token Transfer returned false\u0027);\r\n    }\r\n    function getAlreadyWithdrawn(bytes4 _key) public view returns(uint256){\r\n        return alreadyWithdrawn[_key];\r\n    }\r\n    // function testReduceTGEByMonth() public{\r\n    //     TGE_timestamp=TGE_timestamp-MONTH;\r\n    // }\r\n    // function testIncreaseTGEByMonth() public{\r\n    //     TGE_timestamp=TGE_timestamp\u002BMONTH;\r\n    // }\r\n\r\n    // function testGetTGE() public view returns(uint256){\r\n    //     return TGE_timestamp;\r\n    // }\r\n    // function testGetTimespan() public view returns(uint256){\r\n    //     return getMonthsPassed(TGE_timestamp);\r\n    // }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_liquidity\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setLiqudityAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getTeamAvailable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getTeamAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022releaseCommunity\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCompanyAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getLiqudityAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getLiquidityAvailable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022releaseTeam\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_company\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setCompanyAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getEcosystemAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCommunityReleasable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCommunityAvailable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_team\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setTeamAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getTeamReleasable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022releaseCompany\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_key\u0022,\u0022type\u0022:\u0022bytes4\u0022}],\u0022name\u0022:\u0022getAlreadyWithdrawn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getEcosystemReleasable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_private\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setPrivateAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getPrivateAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getLiquidityReleasable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022releaseLiqudity\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_ecosystem\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setEcosystemAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCompanyReleasable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getPrivateAvailable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getEcosystemAvailable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022releaseEcosystem\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCommunityAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022releasePrivate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCompanyAvailable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getPrivateReleasable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_community\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setCommunityAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_private\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_ecosystem\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_liquidity\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_team\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_company\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_community\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"PromTokenVault","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000fc82bb4ba86045af6f327323a46e80412b91b27d0000000000000000000000005661c46379e366cd241b5d1c69268eb319fd11c7000000000000000000000000608c82d7fd404b192eb547be9c6b7feb88b1bf00000000000000000000000000821695435f6c401e9502306b9214ae3b3ed0653b000000000000000000000000a49ad748c78f6da248ca49e5833ca759396320d900000000000000000000000054729f8c472dee27366532a4636e30ec6465fc09000000000000000000000000a82f790a4d4776e60a20c09ac6911db149be8ce8","Library":"","SwarmSource":"bzzr://d39bbd3f6b4cacc0174af6dfe3476d0c2653e37714679462532b01fcf3d87bcf"}]