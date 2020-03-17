[{"SourceCode":"from vyper.interfaces import ERC721\r\n\r\nimplements: ERC721\r\n\r\ncontract ERC721Receiver:\r\n\tdef onERC721Received(_operator: address, _from: address, _tokenId: uint256, _data: bytes[1024]) -\u003E bytes32: modifying\r\n\r\ncontract ERC20:\r\n\tdef transfer(_to: address, _value: uint256) -\u003E bool: modifying\r\n\tdef burn(_value: uint256): modifying\r\n\r\nTransfer: event({_from: indexed(address), _to: indexed(address), _tokenId: indexed(uint256)})\r\nApproval: event({_owner: indexed(address), _approved: indexed(address), _tokenId: indexed(uint256)})\r\nApprovalForAll: event({_owner: indexed(address), _operator: indexed(address), _approved: bool})\r\nImmutable_IPFS_SHA3_256: event({_from: indexed(address), _hash: bytes[64], _tokenId: indexed(uint256)})\r\nMutable_IPFS_SHA3_256: event({_from: indexed(address), _hash: bytes[64], _tokenId: indexed(uint256)})\r\n\r\nname: public(string[64])\r\nsymbol: public(string[32])\r\ntokenURI: public(string[64])\r\nidToOwner: map(uint256, address)\r\nidToApprovals: map(uint256, address)\r\nidToImmutableIPFS_SHA3_256: map(uint256, bytes[64])\r\nidToMutableIPFS_SHA3_256: map(uint256, bytes[64])\r\nidToValuation: map(uint256, uint256)\r\nimmutableHashToId: map(bytes[64], uint256)\r\nownerIdxToTokenId: map(address, map(uint256, uint256))\r\nownerToNFTokenCount: map(address, uint256)\r\nownerToOperators: map(address, map(address, bool))\r\nsupportedInterfaces: map(bytes32, bool)\r\nERC165_INTERFACE_ID: constant(bytes32) = 0x0000000000000000000000000000000000000000000000000000000001ffc9a7\r\nERC721_INTERFACE_ID: constant(bytes32) = 0x0000000000000000000000000000000000000000000000000000000080ac58cd\r\nERC20_ADDRESS: constant(address) = 0x64D56f087d87CdaeaC8119C69c48D0d440D560a7\r\npayment_address: address\r\nnonce: uint256\r\ntotal_supply: uint256\r\n\r\n@public\r\ndef __init__(_name: string[64], _symbol: string[32], _tokenURI: string[64]):\r\n\tself.supportedInterfaces[ERC165_INTERFACE_ID] = True\r\n\tself.supportedInterfaces[ERC721_INTERFACE_ID] = True\r\n\tself.payment_address = msg.sender\r\n\tself.name = _name\r\n\tself.symbol = _symbol\r\n\tself.tokenURI = _tokenURI\r\n\r\n@public\r\n@constant\r\ndef totalSupply() -\u003E uint256:\r\n\treturn self.total_supply\r\n\r\n@public\r\n@constant\r\ndef supportsInterface(_interfaceID: bytes32) -\u003E bool:\r\n\treturn self.supportedInterfaces[_interfaceID]\r\n\r\n@public\r\n@constant\r\ndef balanceOf(_owner: address) -\u003E uint256:\r\n\tassert _owner != ZERO_ADDRESS\r\n\treturn self.ownerToNFTokenCount[_owner]\r\n\r\n@public\r\n@constant\r\ndef ownerOf(_tokenId: uint256) -\u003E address:\r\n\towner: address = self.idToOwner[_tokenId]\r\n\tassert owner != ZERO_ADDRESS\r\n\treturn owner\r\n\r\n@public\r\n@constant\r\ndef tokenByIndex(_index: uint256) -\u003E uint256:\r\n\tassert _index \u003C self.total_supply\r\n\treturn _index\r\n\r\n@public\r\n@constant\r\ndef tokenOfOwnerByIndex(_owner: address, _index: uint256) -\u003E uint256:\r\n\tassert _owner != ZERO_ADDRESS\r\n\tassert _index \u003C self.ownerToNFTokenCount[_owner]\r\n\treturn self.ownerIdxToTokenId[_owner][_index]\r\n\r\n@public\r\n@constant\r\ndef getApproved(_tokenId: uint256) -\u003E address:\r\n\tassert self.idToOwner[_tokenId] != ZERO_ADDRESS\r\n\treturn self.idToApprovals[_tokenId]\r\n\r\n@public\r\n@constant\r\ndef getValuation(_tokenId: uint256) -\u003E uint256:\r\n\tassert self.idToOwner[_tokenId] != ZERO_ADDRESS\r\n\treturn self.idToValuation[_tokenId]\r\n\r\n@public\r\n@constant\r\ndef getImmutableHashOf(_tokenId: uint256) -\u003E bytes[64]:\r\n\towner: address = self.idToOwner[_tokenId]\r\n\tassert owner != ZERO_ADDRESS\r\n\treturn self.idToImmutableIPFS_SHA3_256[_tokenId]\r\n\r\n@public\r\n@constant\r\ndef getMutableHashOf(_tokenId: uint256) -\u003E bytes[64]:\r\n\towner: address = self.idToOwner[_tokenId]\r\n\tassert owner != ZERO_ADDRESS\r\n\treturn self.idToMutableIPFS_SHA3_256[_tokenId]\r\n\r\n@public\r\n@constant\r\ndef isApprovedForAll(_owner: address, _operator: address) -\u003E bool:\r\n\treturn (self.ownerToOperators[_owner])[_operator]\r\n\r\n@private\r\n@constant\r\ndef _isApprovedOrOwner(_spender: address, _tokenId: uint256) -\u003E bool:\r\n\towner: address = self.idToOwner[_tokenId]\r\n\tspenderIsOwner: bool = owner == _spender\r\n\tspenderIsApproved: bool = _spender == self.idToApprovals[_tokenId]\r\n\tspenderIsApprovedForAll: bool = (self.ownerToOperators[owner])[_spender]\r\n\treturn (spenderIsOwner or spenderIsApproved) or spenderIsApprovedForAll\r\n\r\n@private\r\ndef _addTokenTo(_to: address, _tokenId: uint256):\r\n\tassert self.idToOwner[_tokenId] == ZERO_ADDRESS\r\n\tself.idToOwner[_tokenId] = _to\r\n\tself.ownerIdxToTokenId[_to][self.ownerToNFTokenCount[_to]] = _tokenId\r\n\tself.ownerToNFTokenCount[_to] \u002B= 1\r\n\r\n@private\r\ndef _removeTokenFrom(_from: address, _tokenId: uint256):\r\n\tassert self.idToOwner[_tokenId] == _from\r\n\tself.idToOwner[_tokenId] = ZERO_ADDRESS\r\n\tself.ownerToNFTokenCount[_from] -= 1\r\n\r\n@private\r\ndef _clearApproval(_owner: address, _tokenId: uint256):\r\n\tassert self.idToOwner[_tokenId] == _owner\r\n\tif self.idToApprovals[_tokenId] != ZERO_ADDRESS:\r\n\t\tself.idToApprovals[_tokenId] = ZERO_ADDRESS\r\n\r\n@private\r\ndef _transferFrom(_from: address, _to: address, _tokenId: uint256, _sender: address):\r\n\tassert self._isApprovedOrOwner(_sender, _tokenId)\r\n\tassert _to != ZERO_ADDRESS\r\n\tself._clearApproval(_from, _tokenId)\r\n\tself._removeTokenFrom(_from, _tokenId)\r\n\tself._addTokenTo(_to, _tokenId)\r\n\tlog.Transfer(_from, _to, _tokenId)\r\n\r\n@public\r\ndef transferFrom(_from: address, _to: address, _tokenId: uint256):\r\n\tself._transferFrom(_from, _to, _tokenId, msg.sender)\r\n\r\n@public\r\ndef safeTransferFrom(_from: address, _to: address, _tokenId: uint256, _data: bytes[1024]=\u0022\u0022):\r\n\tself._transferFrom(_from, _to, _tokenId, msg.sender)\r\n\tif _to.is_contract:\r\n\t\treturnValue: bytes32 = ERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data)\r\n\t\tassert returnValue == method_id(\u0022onERC721Received(address,address,uint256,bytes)\u0022, bytes32)\r\n\r\n@public\r\ndef approve(_approved: address, _tokenId: uint256):\r\n\towner: address = self.idToOwner[_tokenId]\r\n\tassert owner != ZERO_ADDRESS\r\n\tassert _approved != owner\r\n\tsenderIsOwner: bool = self.idToOwner[_tokenId] == msg.sender\r\n\tsenderIsApprovedForAll: bool = (self.ownerToOperators[owner])[msg.sender]\r\n\tassert (senderIsOwner or senderIsApprovedForAll)\r\n\tself.idToApprovals[_tokenId] = _approved\r\n\tlog.Approval(owner, _approved, _tokenId)\r\n\r\n@public\r\ndef setApprovalForAll(_operator: address, _approved: bool):\r\n\tassert _operator != msg.sender\r\n\tself.ownerToOperators[msg.sender][_operator] = _approved\r\n\tlog.ApprovalForAll(msg.sender, _operator, _approved)\r\n\r\n@public\r\ndef setImmutableHash(_hash: bytes[64], _tokenId: uint256):\r\n\tassert self.idToOwner[_tokenId] == msg.sender\r\n\tassert _hash != \u0027\u0027\r\n\tassert self.idToMutableIPFS_SHA3_256[_tokenId] == \u0027\u0027\r\n\tassert self.immutableHashToId[_hash] == 0\r\n\tself.idToMutableIPFS_SHA3_256[_tokenId] = _hash\r\n\tlog.Mutable_IPFS_SHA3_256(msg.sender, _hash, _tokenId)\r\n\r\n@public\r\ndef setMutableHash(_hash: bytes[64], _tokenId: uint256):\r\n\tassert self.idToOwner[_tokenId] == msg.sender\r\n\tassert _hash != \u0027\u0027\r\n\tself.idToMutableIPFS_SHA3_256[_tokenId] = _hash\r\n\tlog.Mutable_IPFS_SHA3_256(msg.sender, _hash, _tokenId)\r\n\r\n@public\r\ndef updateTokenURI(_tokenURI: string[64]):\r\n\tassert msg.sender == self.payment_address\r\n\tself.tokenURI = _tokenURI\r\n\r\n@public\r\ndef onERC20Received(_from: address, _value: uint256) -\u003E bytes32:\r\n\tassert msg.sender == ERC20_ADDRESS\r\n\tassert _value \u003E= 20\r\n\r\n\tfee: uint256 = _value / 20\r\n\tvaluation: uint256 = _value - fee\r\n\tdidPayFee: bool = ERC20(ERC20_ADDRESS).transfer(self.payment_address, fee)\r\n\tERC20(ERC20_ADDRESS).burn(fee)\r\n\tassert didPayFee\r\n\r\n\tself.idToValuation[self.nonce] = valuation\r\n\tself._addTokenTo(_from, self.nonce)\r\n\tself.nonce \u002B= 1\r\n\tself.total_supply \u002B= 1\r\n\r\n\treturn method_id(\u0022onERC20Received(address,uint256)\u0022, bytes32)","ABI":"[{\u0022name\u0022:\u0022Transfer\u0022,\u0022inputs\u0022:[{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022indexed\u0022:true},{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022indexed\u0022:true},{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022indexed\u0022:true}],\u0022anonymous\u0022:false,\u0022type\u0022:\u0022event\u0022},{\u0022name\u0022:\u0022Approval\u0022,\u0022inputs\u0022:[{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022indexed\u0022:true},{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_approved\u0022,\u0022indexed\u0022:true},{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022indexed\u0022:true}],\u0022anonymous\u0022:false,\u0022type\u0022:\u0022event\u0022},{\u0022name\u0022:\u0022ApprovalForAll\u0022,\u0022inputs\u0022:[{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022indexed\u0022:true},{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_operator\u0022,\u0022indexed\u0022:true},{\u0022type\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_approved\u0022,\u0022indexed\u0022:false}],\u0022anonymous\u0022:false,\u0022type\u0022:\u0022event\u0022},{\u0022name\u0022:\u0022Immutable_IPFS_SHA3_256\u0022,\u0022inputs\u0022:[{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022indexed\u0022:true},{\u0022type\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_hash\u0022,\u0022indexed\u0022:false},{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022indexed\u0022:true}],\u0022anonymous\u0022:false,\u0022type\u0022:\u0022event\u0022},{\u0022name\u0022:\u0022Mutable_IPFS_SHA3_256\u0022,\u0022inputs\u0022:[{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022indexed\u0022:true},{\u0022type\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_hash\u0022,\u0022indexed\u0022:false},{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022indexed\u0022:true}],\u0022anonymous\u0022:false,\u0022type\u0022:\u0022event\u0022},{\u0022outputs\u0022:[],\u0022inputs\u0022:[{\u0022type\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022},{\u0022type\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_symbol\u0022},{\u0022type\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_tokenURI\u0022}],\u0022constant\u0022:false,\u0022payable\u0022:false,\u0022type\u0022:\u0022constructor\u0022},{\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022out\u0022}],\u0022inputs\u0022:[],\u0022constant\u0022:true,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:1151},{\u0022name\u0022:\u0022supportsInterface\u0022,\u0022outputs\u0022:[{\u0022type\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022out\u0022}],\u0022inputs\u0022:[{\u0022type\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_interfaceID\u0022}],\u0022constant\u0022:true,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:1296},{\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022out\u0022}],\u0022inputs\u0022:[{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022}],\u0022constant\u0022:true,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:1462},{\u0022name\u0022:\u0022ownerOf\u0022,\u0022outputs\u0022:[{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022out\u0022}],\u0022inputs\u0022:[{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022}],\u0022constant\u0022:true,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:1468},{\u0022name\u0022:\u0022tokenByIndex\u0022,\u0022outputs\u0022:[{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022out\u0022}],\u0022inputs\u0022:[{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_index\u0022}],\u0022constant\u0022:true,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:1371},{\u0022name\u0022:\u0022tokenOfOwnerByIndex\u0022,\u0022outputs\u0022:[{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022out\u0022}],\u0022inputs\u0022:[{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022},{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_index\u0022}],\u0022constant\u0022:true,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:2679},{\u0022name\u0022:\u0022getApproved\u0022,\u0022outputs\u0022:[{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022out\u0022}],\u0022inputs\u0022:[{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022}],\u0022constant\u0022:true,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:2455},{\u0022name\u0022:\u0022getValuation\u0022,\u0022outputs\u0022:[{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022out\u0022}],\u0022inputs\u0022:[{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022}],\u0022constant\u0022:true,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:2485},{\u0022name\u0022:\u0022getImmutableHashOf\u0022,\u0022outputs\u0022:[{\u0022type\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022out\u0022}],\u0022inputs\u0022:[{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022}],\u0022constant\u0022:true,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:8932},{\u0022name\u0022:\u0022getMutableHashOf\u0022,\u0022outputs\u0022:[{\u0022type\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022out\u0022}],\u0022inputs\u0022:[{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022}],\u0022constant\u0022:true,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:8962},{\u0022name\u0022:\u0022isApprovedForAll\u0022,\u0022outputs\u0022:[{\u0022type\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022out\u0022}],\u0022inputs\u0022:[{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022},{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_operator\u0022}],\u0022constant\u0022:true,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:1759},{\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[],\u0022inputs\u0022:[{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022},{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022},{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022}],\u0022constant\u0022:false,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:392014},{\u0022name\u0022:\u0022safeTransferFrom\u0022,\u0022outputs\u0022:[],\u0022inputs\u0022:[{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022},{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022},{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022}],\u0022constant\u0022:false,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022name\u0022:\u0022safeTransferFrom\u0022,\u0022outputs\u0022:[],\u0022inputs\u0022:[{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022},{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022},{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022},{\u0022type\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_data\u0022}],\u0022constant\u0022:false,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[],\u0022inputs\u0022:[{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_approved\u0022},{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022}],\u0022constant\u0022:false,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:41105},{\u0022name\u0022:\u0022setApprovalForAll\u0022,\u0022outputs\u0022:[],\u0022inputs\u0022:[{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_operator\u0022},{\u0022type\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_approved\u0022}],\u0022constant\u0022:false,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:38390},{\u0022name\u0022:\u0022setImmutableHash\u0022,\u0022outputs\u0022:[],\u0022inputs\u0022:[{\u0022type\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_hash\u0022},{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022}],\u0022constant\u0022:false,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:121394},{\u0022name\u0022:\u0022setMutableHash\u0022,\u0022outputs\u0022:[],\u0022inputs\u0022:[{\u0022type\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_hash\u0022},{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022}],\u0022constant\u0022:false,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:115215},{\u0022name\u0022:\u0022updateTokenURI\u0022,\u0022outputs\u0022:[],\u0022inputs\u0022:[{\u0022type\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_tokenURI\u0022}],\u0022constant\u0022:false,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:107707},{\u0022name\u0022:\u0022onERC20Received\u0022,\u0022outputs\u0022:[{\u0022type\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022out\u0022}],\u0022inputs\u0022:[{\u0022type\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022},{\u0022type\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022}],\u0022constant\u0022:false,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:224109},{\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022type\u0022:\u0022string\u0022,\u0022name\u0022:\u0022out\u0022}],\u0022inputs\u0022:[],\u0022constant\u0022:true,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:8273},{\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022type\u0022:\u0022string\u0022,\u0022name\u0022:\u0022out\u0022}],\u0022inputs\u0022:[],\u0022constant\u0022:true,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:7326},{\u0022name\u0022:\u0022tokenURI\u0022,\u0022outputs\u0022:[{\u0022type\u0022:\u0022string\u0022,\u0022name\u0022:\u0022out\u0022}],\u0022inputs\u0022:[],\u0022constant\u0022:true,\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022,\u0022gas\u0022:8333}]","ContractName":"Vyper_contract","CompilerVersion":"vyper:0.1.0b16","OptimizationUsed":"0","Runs":"0","ConstructorArguments":"000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000064255524e494e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000064255524e494e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e68747470733a2f2f6275726e692e636f2f746f6b656e5552492e6a736f6e0000","Library":"","SwarmSource":""}]