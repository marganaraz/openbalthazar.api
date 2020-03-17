[{"SourceCode":"/*\r\nCrackCoin Initial Coin Offering\r\n\r\nDaniel Iwo, 2019, Triple Advanced Information Systems, released under MIT License\r\n*/\r\n\r\n\r\npragma solidity ^0.5.8;\r\n\r\nlibrary SafeMath{\r\n\t function add(uint a, uint b) internal pure returns(uint c)\r\n\t {\r\n\t \tc=a\u002Bb;\r\n\t\trequire(c\u003E=a);\r\n\t }\r\n\t function sub(uint a, uint b) internal pure returns(uint c)\r\n\t {\r\n\t\tc=a-b;\r\n\t\trequire(c\u003C=a);\t \r\n\t }\r\n\t function mul(uint a, uint b) internal pure returns(uint c)\r\n\t {\r\n\t\tc=a*b;\t \r\n\t\trequire(a==0||c/a==b);\r\n\t }\r\n\t function div(uint a,uint b) internal pure returns(uint c)\r\n\t {\r\n\t\trequire(b\u003E0);\r\n\t\tc = a/b;\t \r\n\t }\r\n}\r\n\r\ncontract Owned{\r\n\taddress public owner;\r\n\taddress public newOwner;\r\n\t\r\n\tevent OwnershipTransferred(address indexed _from, address indexed _to);\r\n\t\r\n\tconstructor() public{\r\n\t\towner=msg.sender;\t\r\n\t}\r\n\tmodifier onlyOwner{\r\n\t\trequire(msg.sender==owner);\r\n\t\t_;\t\r\n\t}\r\n\tfunction transferOwnership(address _newOwner) public onlyOwner\r\n\t{\r\n\t\tnewOwner=_newOwner;\t\r\n\t}\r\n\tfunction acceptOwnership() public{\r\n\t\trequire(msg.sender==newOwner);\r\n\t\temit OwnershipTransferred(owner,newOwner);\r\n\t\towner=newOwner;\r\n\t\tnewOwner=address(0);\t\r\n\t}\r\n\r\n}\r\n\r\ncontract GroupOwned is Owned{\r\n    \r\n    event GroupTransferred(address indexed from,address indexed to);\r\n    \r\n    //0 for not in , integers count the increasing priority in the group \r\n    mapping(bytes =\u003E mapping(address =\u003E int8)) public groups;\r\n  //  mapping(bytes32 =\u003E uint32) _group_count;\r\n    \r\n\r\n    modifier onlySuperior(bytes memory gname,address subject){\r\n        require((groups[gname][msg.sender]\u003Egroups[gname][subject])||(msg.sender==owner));\r\n        _;\r\n    }\r\n    \r\n    modifier onlyGroup(bytes memory gname,int8 level)\r\n    {\r\n        require(groups[gname][msg.sender]\u003E=level);\r\n        _;\r\n    }\r\n   \r\n    function groupmod(bytes memory gname,address user,int8 priority) internal returns(bool)\r\n    {\r\n        groups[gname][user]=priority;\r\n        return true;\r\n    }\r\n\r\n    function CGroupMod(bytes memory gname, address user,int8 priority) public onlySuperior(gname,user) returns(bool)\r\n    {\t\t  \r\n\t\t  require((groups[gname][msg.sender]\u003Epriority)||(msg.sender==owner));\r\n        if(groupmod(gname,user,priority))\r\n        {\r\n            return true;\r\n        }\r\n        return false;\r\n    }  \r\n }\r\n\r\ncontract Child is Owned,GroupOwned\r\n{\r\n\taddress public root;\r\n\taddress public token;\r\n\t\r\n\tfunction setRoot(address newroot) public onlyGroup(\u0027child_manage\u0027,2) returns(bool)\r\n\t{\r\n\t\troot=newroot;\r\n\t\treturn true;\t\r\n\t}\r\n\t\r\n\tfunction setToken(address newToken) public onlyGroup(\u0027child_manage\u0027,2) returns (bool)\r\n\t{\r\n\t\ttoken=newToken;\r\n\t\treturn true;\t\r\n\t}\r\n}\r\n\r\n\r\ncontract ERC20Interface\r\n{\r\n    function balanceOf(address tokenOwner) public view returns(uint balance);\r\n    function transfer(address to,uint tokens) public returns(bool success);\r\n    \r\n}\r\n\r\ncontract CC_ICO is Owned,GroupOwned,Child{\r\n\t using SafeMath for uint;\r\n    string public name;\r\n    string public symbol;\r\n    \r\n    uint256 public sellcap;\r\n    uint256 public qEC;\r\n    uint256 public decimals;\r\n    \r\n\t event SellCapSet(uint256 indexed sc);    \r\n    \r\n    constructor() public \r\n    {\r\n        name=\u0022*** CrackCoin Token Sale #1 ***\u0022;\r\n        symbol=\u0022CRK ICO #1\u0022;\r\n        qEC=100;\r\n        decimals=18;\r\n    }\r\n    \r\n    function setqEC(uint256 _qec) public onlyOwner returns(bool)\r\n    {\r\n        qEC=_qec;\r\n        return true;\r\n    }\r\n    \r\n    /*function setBuyCap(uint256 amount) public view returns(uint256)\r\n    {\r\n    \trequire(msg.sender==owner);\r\n    \trequire(amount \u003C address(this).balance);\r\n\t\t_buycap = amount;    \t\r\n    \treturn amount;\r\n    }*/\r\n    /*\r\n    function setSellCap(uint256 amount) public view returns(uint256)\r\n    {\r\n    \trequire(msg.sender==_owner);\r\n    \tethCap = amount/CCvsEth;\r\n    \tif(address(this).balance\u003CethCap)\r\n    \t{\r\n\t\t\t    return 0;\t\r\n    \t}\r\n    \tsellcap = amount;\r\n    \treturn amount;\r\n    }*/\r\n    \r\n    function setSellCap(uint256 amount) public onlyOwner returns(bool)\r\n    {\r\n\t\tERC20Interface coin=ERC20Interface(token);\r\n\t\trequire(coin.balanceOf(address(this))\u003E=amount);    \t\r\n    \tsellcap=amount;\r\n    \temit SellCapSet(sellcap);\r\n\t   return true;    \r\n    }\r\n\r\n\t function () payable external\r\n\t {\r\n\t \tuint256 amCC=qEC.mul(msg.value);\t\r\n\t \tERC20Interface coin=ERC20Interface(token);\r\n\t \tif(amCC\u003Ecoin.balanceOf(address(this))||amCC\u003Esellcap)\r\n\t \t{\r\n\t\t\tmsg.sender.transfer(msg.value);\r\n\t \t}\r\n\t \telse{\r\n\t \t\tcoin.transfer(msg.sender,amCC);\r\n\t\t\tuint256 newBal=coin.balanceOf(address(this)); \r\n\t\t\tif(sellcap\u003EnewBal)\r\n\t\t\t{\r\n\t\t\t\tsellcap=newBal;\r\n\t\t\t}\t \r\n\t\t}\r\n\t }\r\n\t \r\n\t function wdCRCK(address wdloc,uint256 amount) public payable onlyOwner returns(bool)\r\n\t {\r\n\t\trequire(msg.sender==owner);\r\n\t\tERC20Interface coin=ERC20Interface(token);\r\n\t\tuint256 bal=coin.balanceOf(address(this));\r\n\t\trequire(bal\u003E=amount);\t \r\n\t\tcoin.transfer(wdloc,amount);\t\r\n\t\tuint256 newBal=coin.balanceOf(address(this)); \r\n\t\tif(sellcap\u003EnewBal)\r\n\t\t{\r\n\t\t\tsellcap=newBal;\r\n\t\t}\r\n\t \treturn true;\t \r\n\t }\r\n\t \r\n\t function wdEther(address wdloc,uint256 amount)\tpublic onlyOwner returns(bool)\r\n\t {\r\n\t\t require(msg.sender==owner);\t \t\r\n\t\t require(address(this).balance\u003E=amount);\r\n\t\t address payable wd=address(uint160(wdloc));\r\n\t\t wd.send(amount);\r\n\t\t return true;\t \r\n\t } \r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newroot\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setRoot\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newToken\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022wdloc\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022wdEther\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_qec\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setqEC\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sellcap\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setSellCap\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022qEC\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022groups\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022int8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022gname\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022priority\u0022,\u0022type\u0022:\u0022int8\u0022}],\u0022name\u0022:\u0022CGroupMod\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022wdloc\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022wdCRCK\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022newOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022root\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022token\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022sc\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022SellCapSet\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022GroupTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"CC_ICO","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://d3bc3c0d7a861159ab86c5116ab32a67c58b4ab09fcb2c177c4459bf17be88a2"}]