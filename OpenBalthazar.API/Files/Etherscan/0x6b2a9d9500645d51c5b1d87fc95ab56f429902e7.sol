[{"SourceCode":"pragma solidity 0.5.13;\r\nlibrary SafeMath{\r\n\tfunction div(uint256 a,uint256 b)internal pure returns(uint256){require(b\u003E0);uint256 c=a/b;return c;}\r\n\tfunction mul(uint256 a,uint256 b)internal pure returns(uint256){if(a==0){return 0;}uint256 c=a*b;require(c/a==b);return c;}\r\n    function sub(uint256 a,uint256 b)internal pure returns(uint256){require(b\u003C=a);uint256 c=a-b;return c;}}\r\ninterface Out{\r\n\tfunction mint(address w,uint256 a)external returns(bool);\r\n    function burn(address w,uint256 a)external returns(bool);\r\n    function await(address w,uint256 a)external returns(bool);\r\n    function apull(address w,uint256 a)external returns(bool);\r\n    function adrop(address w,uint256 a)external returns(bool);\r\n    function adirr(address w,uint256 a)external returns(bool);\r\n    function ipull(address w)external view returns(uint256);\r\n    function idrop(address w)external view returns(uint256);\r\n    function idirr(address w)external view returns(uint256);\r\n    function idd(address a)external view returns(uint256);\r\n    function subsu(uint256 a)external returns(bool);\r\n\tfunction ref(address a)external view returns(address);\r\n    function sef(address a)external view returns(address);\r\n\tfunction register(address a,address b)external returns(bool);\r\n\tfunction bct()external view returns(uint256);\r\n    function act()external view returns(uint256);\r\n\tfunction amem(uint256 i)external view returns(address);\r\n\tfunction bmem(uint256 i)external view returns(address);\r\n\tfunction deal(address w,address g,address q,address x,uint256 a,uint256 e,uint256 s,uint256 z)external returns(bool);}\r\ncontract POOL{using SafeMath for uint256;\r\n    modifier onlyOwn{require(own==msg.sender);_;}\r\n    address private own;address private rot;address private reg;\r\n    address private del;address private uni;address private rvs;\r\n\tfunction setair(uint256 a,uint256 l,uint256 c)external returns(bool){\r\n\t    require(a\u003E999999\u0026\u0026l\u003E999999\u0026\u0026Out(del).ipull(msg.sender)==0\u0026\u0026Out(del).apull(msg.sender,a)\u0026\u0026\r\n\t    Out(del).adrop(msg.sender,l)\u0026\u0026Out(del).adirr(msg.sender,c)\u0026\u0026Out(rot).burn(msg.sender,a));return true;}\r\n    function delair()external returns(bool){uint256 a=Out(del).ipull(msg.sender);\r\n        require(a\u003E0\u0026\u0026Out(del).apull(msg.sender,0)\u0026\u0026Out(del).adrop(msg.sender,0)\u0026\u0026\r\n\t\tOut(rot).mint(msg.sender,a));return true;}\r\n    function getair(address g)external returns(bool){\r\n\t\tuint256 a=Out(del).idrop(g);uint256 b=Out(del).ipull(g);uint256 c=Out(del).idirr(g);\r\n\t\trequire(b\u003E0\u0026\u0026b\u003Ea\u0026\u0026Out(del).apull(g,b.sub(a))\u0026\u0026Out(reg).idd(msg.sender)==0\u0026\u0026\r\n\t\tOut(reg).register(msg.sender,g)\u0026\u0026Out(rot).mint(g,a.div(100).mul(64)));\r\n\t\tuint256 aaa=a.div(100).mul(36);\r\n\t\tif(c==1){require(Out(rot).mint(rvs,aaa));}else if(c==2){require(Out(rot).subsu(aaa));}else{\r\n\t\taddress _awn;address _bwn;uint256 an=Out(uni).act();\r\n\t\tuint256 bn=Out(uni).bct();uint256 mm=aaa.div(5);uint256 am=mm.div(an).mul(4);uint256 bm=mm.div(bn);\r\n\t\tfor(uint256 j=0;j\u003Can;j\u002B\u002B){_awn=Out(uni).amem(j);require(Out(rot).mint(_awn,am));}\r\n\t\tfor(uint256 j=0;j\u003Cbn;j\u002B\u002B){_bwn=Out(uni).bmem(j);require(Out(rot).mint(_bwn,bm));}}\r\n\t\trequire(Out(del).deal(g,msg.sender,Out(reg).ref(g),Out(reg).sef(g),a,0,1,0)\u0026\u0026\r\n\t\tOut(del).await(g,(a.div(100)).mul(172))\u0026\u0026Out(del).await(msg.sender,(a.div(5)).mul(8))\u0026\u0026\r\n\t\tOut(del).await(Out(reg).ref(g),a.div(100).mul(18))\u0026\u0026Out(del).await(Out(reg).sef(g),a.div(10)));return true;}\r\n\tfunction setreg(address a)external onlyOwn returns(bool){reg=a;return true;}\r\n\tfunction setrot(address a)external onlyOwn returns(bool){rot=a;return true;}\t\r\n\tfunction setdel(address a)external onlyOwn returns(bool){del=a;return true;}\r\n\tfunction setuni(address a)external onlyOwn returns(bool){uni=a;return true;}\r\n    function()external{revert();}\r\n    constructor()public{own=msg.sender;rvs=0xd8E399398839201C464cda7109b27302CFF0CEaE;}}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022delair\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022g\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getair\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022l\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022c\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setair\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setdel\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setreg\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setrot\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setuni\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"POOL","CompilerVersion":"v0.5.13\u002Bcommit.5b0b510c","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://7e8d7fafd8698d50bd1f11bc3f4b0e7547e1d7cac236d5032e3f0f2f5763df9a"}]