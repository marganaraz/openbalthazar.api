[{"SourceCode":"// File: browser/flattened.sol\r\n\r\n\r\n// File: browser/DateTime.sol\r\n\r\npragma solidity \u003E=0.4.21 \u003C0.6.0;\r\n\r\ncontract DateTime {\r\n        /*\r\n         *  Date and Time utilities for ethereum contracts\r\n         *\r\n         */\r\n        struct _DateTime {\r\n                uint16 year;\r\n                uint8 month;\r\n                uint8 day;\r\n                uint8 hour;\r\n                uint8 minute;\r\n                uint8 second;\r\n                uint8 weekday;\r\n        }\r\n\r\n        uint constant DAY_IN_SECONDS = 86400;\r\n        uint constant YEAR_IN_SECONDS = 31536000;\r\n        uint constant LEAP_YEAR_IN_SECONDS = 31622400;\r\n\r\n        uint constant HOUR_IN_SECONDS = 3600;\r\n        uint constant MINUTE_IN_SECONDS = 60;\r\n\r\n        uint16 constant ORIGIN_YEAR = 1970;\r\n\r\n        function isLeapYear(uint16 year) internal pure returns (bool) {\r\n                if (year % 4 != 0) {\r\n                        return false;\r\n                }\r\n                if (year % 100 != 0) {\r\n                        return true;\r\n                }\r\n                if (year % 400 != 0) {\r\n                        return false;\r\n                }\r\n                return true;\r\n        }\r\n\r\n        function leapYearsBefore(uint year) internal pure returns (uint) {\r\n                year -= 1;\r\n                return year / 4 - year / 100 \u002B year / 400;\r\n        }\r\n\r\n        function getDaysInMonth(uint8 month, uint16 year) internal pure returns (uint8) {\r\n                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {\r\n                        return 31;\r\n                }\r\n                else if (month == 4 || month == 6 || month == 9 || month == 11) {\r\n                        return 30;\r\n                }\r\n                else if (isLeapYear(year)) {\r\n                        return 29;\r\n                }\r\n                else {\r\n                        return 28;\r\n                }\r\n        }\r\n\r\n        function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {\r\n                uint secondsAccountedFor = 0;\r\n                uint buf;\r\n                uint8 i;\r\n\r\n                // Year\r\n                dt.year = getYear(timestamp);\r\n                buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);\r\n\r\n                secondsAccountedFor \u002B= LEAP_YEAR_IN_SECONDS * buf;\r\n                secondsAccountedFor \u002B= YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);\r\n\r\n                // Month\r\n                uint secondsInMonth;\r\n                for (i = 1; i \u003C= 12; i\u002B\u002B) {\r\n                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);\r\n                        if (secondsInMonth \u002B secondsAccountedFor \u003E timestamp) {\r\n                                dt.month = i;\r\n                                break;\r\n                        }\r\n                        secondsAccountedFor \u002B= secondsInMonth;\r\n                }\r\n\r\n                // Day\r\n                for (i = 1; i \u003C= getDaysInMonth(dt.month, dt.year); i\u002B\u002B) {\r\n                        if (DAY_IN_SECONDS \u002B secondsAccountedFor \u003E timestamp) {\r\n                                dt.day = i;\r\n                                break;\r\n                        }\r\n                        secondsAccountedFor \u002B= DAY_IN_SECONDS;\r\n                }\r\n\r\n                // Hour\r\n                dt.hour = getHour(timestamp);\r\n\r\n                // Minute\r\n                dt.minute = getMinute(timestamp);\r\n\r\n                // Second\r\n                dt.second = getSecond(timestamp);\r\n\r\n                // Day of week.\r\n                dt.weekday = getWeekday(timestamp);\r\n        }\r\n\r\n        function getYear(uint timestamp) internal pure returns (uint16) {\r\n                uint secondsAccountedFor = 0;\r\n                uint16 year;\r\n                uint numLeapYears;\r\n\r\n                // Year\r\n                year = uint16(ORIGIN_YEAR \u002B timestamp / YEAR_IN_SECONDS);\r\n                numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);\r\n\r\n                secondsAccountedFor \u002B= LEAP_YEAR_IN_SECONDS * numLeapYears;\r\n                secondsAccountedFor \u002B= YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);\r\n\r\n                while (secondsAccountedFor \u003E timestamp) {\r\n                        if (isLeapYear(uint16(year - 1))) {\r\n                                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;\r\n                        }\r\n                        else {\r\n                                secondsAccountedFor -= YEAR_IN_SECONDS;\r\n                        }\r\n                        year -= 1;\r\n                }\r\n                return year;\r\n        }\r\n\r\n        function getMonth(uint timestamp) internal pure returns (uint8) {\r\n                return parseTimestamp(timestamp).month;\r\n        }\r\n\r\n        function getDay(uint timestamp) internal pure returns (uint8) {\r\n                return parseTimestamp(timestamp).day;\r\n        }\r\n\r\n        function getHour(uint timestamp) internal pure returns (uint8) {\r\n                return uint8((timestamp / 60 / 60) % 24);\r\n        }\r\n\r\n        function getMinute(uint timestamp) internal pure returns (uint8) {\r\n                return uint8((timestamp / 60) % 60);\r\n        }\r\n\r\n        function getSecond(uint timestamp) internal pure returns (uint8) {\r\n                return uint8(timestamp % 60);\r\n        }\r\n\r\n        function getWeekday(uint timestamp) internal pure returns (uint8) {\r\n                return uint8((timestamp / DAY_IN_SECONDS \u002B 4) % 7);\r\n        }\r\n\r\n        function toTimestamp(uint16 year, uint8 month, uint8 day) internal pure returns (uint timestamp) {\r\n                return toTimestamp(year, month, day, 0, 0, 0);\r\n        }\r\n\r\n        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) internal pure returns (uint timestamp) {\r\n                return toTimestamp(year, month, day, hour, 0, 0);\r\n        }\r\n\r\n        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) internal pure returns (uint timestamp) {\r\n                return toTimestamp(year, month, day, hour, minute, 0);\r\n        }\r\n\r\n        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) internal pure returns (uint timestamp) {\r\n                uint16 i;\r\n\r\n                // Year\r\n                for (i = ORIGIN_YEAR; i \u003C year; i\u002B\u002B) {\r\n                        if (isLeapYear(i)) {\r\n                                timestamp \u002B= LEAP_YEAR_IN_SECONDS;\r\n                        }\r\n                        else {\r\n                                timestamp \u002B= YEAR_IN_SECONDS;\r\n                        }\r\n                }\r\n\r\n                // Month\r\n                uint8[12] memory monthDayCounts;\r\n                monthDayCounts[0] = 31;\r\n                if (isLeapYear(year)) {\r\n                        monthDayCounts[1] = 29;\r\n                }\r\n                else {\r\n                        monthDayCounts[1] = 28;\r\n                }\r\n                monthDayCounts[2] = 31;\r\n                monthDayCounts[3] = 30;\r\n                monthDayCounts[4] = 31;\r\n                monthDayCounts[5] = 30;\r\n                monthDayCounts[6] = 31;\r\n                monthDayCounts[7] = 31;\r\n                monthDayCounts[8] = 30;\r\n                monthDayCounts[9] = 31;\r\n                monthDayCounts[10] = 30;\r\n                monthDayCounts[11] = 31;\r\n\r\n                for (i = 1; i \u003C month; i\u002B\u002B) {\r\n                        timestamp \u002B= DAY_IN_SECONDS * monthDayCounts[i - 1];\r\n                }\r\n\r\n                // Day\r\n                timestamp \u002B= DAY_IN_SECONDS * (day - 1);\r\n\r\n                // Hour\r\n                timestamp \u002B= HOUR_IN_SECONDS * (hour);\r\n\r\n                // Minute\r\n                timestamp \u002B= MINUTE_IN_SECONDS * (minute);\r\n\r\n                // Second\r\n                timestamp \u002B= second;\r\n\r\n                return timestamp;\r\n        }\r\n}\r\n\r\n// File: browser/Dependency.sol\r\n\r\npragma solidity \u003E=0.4.21 \u003C0.6.0;\r\n\r\n\r\ncontract Dependency is DateTime \r\n{ \r\n  /**\r\n   * @dev struture to store File transfer related information\r\n   */\r\n    struct FileProof\r\n    {\r\n        address sender;\r\n        address receiver;\r\n        bytes32 fileHash;\r\n        uint256 timestamp;\r\n        bytes32 QR;\r\n        bytes32 QRTime;\r\n    }\r\n  /**\r\n   * @dev structure to store Folder transfer related information\r\n   */\r\n    struct FolderProof\r\n    {\r\n        address sender;\r\n        address receiver;\r\n        address folderAddress;\r\n        bytes32 folderHash;\r\n        uint256 timestamp;\r\n        bytes32 QR;\r\n        bytes32 QRTime;\r\n    }\r\n\r\n    struct FileQRWithIndex\r\n    {\r\n        bytes32 hashFile;\r\n        uint256 index;\r\n    }\r\n\r\n    struct FolderQRWithIndex\r\n    {\r\n        address folderAddress;\r\n        uint256 index;\r\n    }\r\n\r\n  /**\r\n   * @dev mapping to map the proof and QR codes(both with and Without time)\r\n   * @mapping fileProofs , map the struct of file proof with file hash as its key\r\n   * @mapoing folderProofs , map the struct of folder proof with folder hash as its key\r\n   * @mapping fileQrCodeWithoutTime , map the QR code with file  hash as key . It helps in searching proof via QR\r\n   * @mapping fileQrCodeWithTime , map the QR code with Time with file hash as key   \r\n   * @mapping folderQrCodeWithoutTime , map the QR code with folder address as key . It helps in searching proof via QR\r\n   * @mapping folderQrCodeWithTime , map the QR code with Time with folder address as key   \r\n   */\r\n    mapping (bytes32 =\u003E FileProof[]) fileProofs; // this allows to look up proof of transfer by the hashfile\r\n    mapping (address =\u003E FolderProof[]) folderProofs;\r\n    mapping (bytes32 =\u003E FileQRWithIndex[]) fileQrCodeWithoutTime; //  QrCode =\u003E hashFile\r\n    mapping (bytes32 =\u003E FileQRWithIndex[]) fileQrCodeWithTime;\r\n    mapping (bytes32 =\u003E FolderQRWithIndex[]) folderQrCodeWithoutTime; //  QrCode =\u003E hashFile\r\n    mapping (bytes32 =\u003E FolderQRWithIndex[]) folderQrCodeWithTime;\r\n\r\n    mapping(bytes32 =\u003E bool)  usedFileHashes;\r\n    mapping(address =\u003E bool)  usedFolderAddresses;\r\n\r\n\r\n    /**\r\n     * @dev supporting function for creating and storing Transfer proof \r\n     */\r\n\r\n    function _inCreateFileTransferProof(address _sender, address _receiver, bytes32 _fileHash,uint256 time, bytes32 QRWithNoTime ,bytes32 QRWithTime) internal returns (bool)\r\n    {\r\n        FileProof memory currentInfo;\r\n        currentInfo.sender = _sender;\r\n        currentInfo.receiver = _receiver;\r\n        currentInfo.fileHash = _fileHash;\r\n        currentInfo.timestamp = time;\r\n        currentInfo.QR = QRWithNoTime;\r\n        currentInfo.QRTime = QRWithTime;\r\n        // if the entry is already present in mapping with same File Proof then it add the info in the array of struct \u0022FileProof\u0022 mapped to the specific file hash,\r\n        // And if not present then creates the new entry\r\n        fileProofs[_fileHash].push(currentInfo);\r\n        uint256 index = fileProofs[_fileHash].length - 1;\r\n        FileQRWithIndex memory indexInfo;\r\n        indexInfo.hashFile = _fileHash;\r\n        indexInfo.index = index;\r\n        fileQrCodeWithoutTime[QRWithNoTime].push(indexInfo);\r\n        fileQrCodeWithTime[QRWithTime].push(indexInfo);\r\n        usedFileHashes[_fileHash] = true;\r\n        return true;\r\n    }\r\n\r\n\r\n    /**\r\n     * @dev supporting function for creating and storing Folder transfer proof\r\n     */\r\n    function _inCreateFolderTransferProof(address _sender,address _receiver,address _folderAddress,bytes32 _folderHash,uint256 time,bytes32 QRWithNoTime,bytes32 QRWithTime) internal returns(bool)\r\n    {\r\n        FolderProof memory currentInfo;\r\n        currentInfo.sender = _sender;\r\n        currentInfo.receiver = _receiver;\r\n        currentInfo.folderAddress = _folderAddress;\r\n        currentInfo.folderHash = _folderHash;\r\n        currentInfo.timestamp = time;\r\n        currentInfo.QR = QRWithNoTime;\r\n        currentInfo.QRTime = QRWithTime;\r\n        // if the entry is already present in mapping with same folder address then it add the info in the array of struct \u0022FolderProof\u0022 mapped to the specific address,\r\n        // And if not present then creates the new entry\r\n        folderProofs[_folderAddress].push(currentInfo); \r\n        uint256 index = folderProofs[_folderAddress].length - 1;\r\n        FolderQRWithIndex memory indexInfo;\r\n        indexInfo.folderAddress = _folderAddress;\r\n        indexInfo.index = index;\r\n        folderQrCodeWithoutTime[QRWithNoTime].push(indexInfo);\r\n        folderQrCodeWithTime[QRWithTime].push(indexInfo);\r\n        usedFolderAddresses[_folderAddress] = true;\r\n        return true;\r\n    }\r\n\r\n\r\n    /**\r\n     * @dev returns array of all senders and receivers related to supplied file hash\r\n     */\r\n    function _inGetFileTransferProofs(bytes32 fileHash, uint256 index) internal view returns (address[] memory, bytes32, bool)\r\n    {   \r\n        address[] memory senderAndReceiver = new address[](2);\r\n        senderAndReceiver[0] = fileProofs[fileHash][index].sender;\r\n        senderAndReceiver[1] = fileProofs[fileHash][index].receiver;\r\n        bytes32 QR = fileProofs[fileHash][index].QR;\r\n        if(fileProofs[fileHash].length - 1 \u003E index)\r\n        {\r\n            return(senderAndReceiver, QR, true);\r\n        }\r\n        else\r\n        {\r\n            return(senderAndReceiver, QR, false);\r\n        }\r\n    }\r\n\r\n\r\n    /**\r\n   * @dev calculates the day , month , year using the timestamp\r\n   * @param time , timestamp whose day,month,year is to be calculated \r\n   */\r\n    function getDateTime (uint256 time) internal pure returns(uint256,uint256,uint256)\r\n      {\r\n        uint256 year = getYear(time);\r\n        uint256 month = getMonth(time);\r\n        uint256 day = getDay(time);\r\n        return (year, month, day );\r\n    }\r\n\r\n\r\n    /**\r\n     * @dev returns array of all day , month , year related to supplied file hash  \r\n     */\r\n    function _inGetFileTransferProofsDateTime(bytes32 fileHash,uint256 index ,uint256 len) internal view returns (address[] memory, bytes32, uint256[] memory,bool)\r\n    {     \r\n        uint256 time = fileProofs[fileHash][index].timestamp; \r\n        (uint256 year, uint256 month, uint256 day) = getDateTime(time);\r\n        address[] memory senderAndReceiver = new address[](2);\r\n        senderAndReceiver[0] = fileProofs[fileHash][index].sender;\r\n        senderAndReceiver[1] = fileProofs[fileHash][index].receiver;\r\n        bytes32 QR = fileProofs[fileHash][index].QRTime;\r\n        uint256[] memory Date = new uint256[](3);\r\n        Date[0] = day;\r\n        Date[1] = month;\r\n        Date[2] = year;\r\n        if(len - 1 \u003E index)\r\n        {\r\n            return(senderAndReceiver, QR, Date, true);\r\n        }\r\n        else\r\n        {\r\n            return(senderAndReceiver, QR, Date, false);\r\n        }\r\n    }\r\n\r\n\r\n    /**\r\n     * @dev returns array of all senders and receivers related to supplied folder Address  \r\n     */\r\n\r\n\r\n    function _inGetFolderTransferProofs(address folderAddress,uint256 index) internal view returns(address[] memory,bytes32 , bytes32, bool)\r\n    {   \r\n        address[] memory senderAndReceiver = new address[](2);\r\n        senderAndReceiver[0] = folderProofs[folderAddress][index].sender;\r\n        senderAndReceiver[1] = folderProofs[folderAddress][index].receiver;\r\n        bytes32 QR = folderProofs[folderAddress][index].QR;\r\n        bytes32 folderHash = folderProofs[folderAddress][index].folderHash;\r\n        if(folderProofs[folderAddress].length - 1 \u003E index)\r\n        {\r\n            return(senderAndReceiver,folderHash, QR, true);\r\n        }\r\n        else\r\n        {\r\n            return(senderAndReceiver,folderHash,QR, false);\r\n        }\r\n    }\r\n\r\n\r\n    /**\r\n     * @dev returns array of all day , month , year related to supplied folder address \r\n     */\r\n    function _inGetFolderTransferProofsWithDateTime(address folderAddress,uint256 index, uint256 len) internal view returns (address[] memory,bytes32,bytes32, uint256[] memory,bool)\r\n    {   \r\n        uint256 time = folderProofs[folderAddress][index].timestamp; \r\n       // (uint256 year, uint256 month, uint256 day) = getDateTime(time);\r\n        address[] memory senderAndReceiver = new address[](2);\r\n        senderAndReceiver[0] = folderProofs[folderAddress][index].sender;\r\n        senderAndReceiver[1] = folderProofs[folderAddress][index].receiver;\r\n        bytes32 folderHash = folderProofs[folderAddress][index].folderHash;\r\n        bytes32 QR = folderProofs[folderAddress][index].QRTime;\r\n        uint256[] memory Date = new uint256[](3);\r\n        (Date[2],Date[1],Date[0])= getDateTime(time);\r\n        if(len - 1 \u003E index)\r\n        {\r\n            return(senderAndReceiver,folderHash ,QR,Date, true);\r\n        }\r\n        else\r\n        {\r\n            return(senderAndReceiver,folderHash, QR,Date, false);\r\n        }\r\n    }\r\n    \r\n\r\n    /**\r\n     * @dev supporting function for searching file information via QR code \r\n     */\r\n    function _InSearchFileTransferProof(bytes32 QRCode) internal view returns(address , address , bytes32)\r\n      {\r\n        bytes32 Hash;\r\n        Hash = fileQrCodeWithoutTime[QRCode][0].hashFile;\r\n        require(fileExists(Hash),\u0022file does not exists\u0022);\r\n        uint256 index = fileQrCodeWithoutTime[QRCode][0].index;\r\n        address sender = fileProofs[Hash][index].sender;\r\n        address receiver = fileProofs[Hash][index].receiver;\r\n        return (sender, receiver, Hash);\r\n    }\r\n\r\n\r\n    /**\r\n     * @dev supporting function for searching file information with day , month , year via QR code \r\n     */\r\n    function _InSearchFileTransferProofWithTime(bytes32 QRCode) internal view returns(address , address , uint256 , uint256 , uint256 ,bytes32)\r\n    {\r\n        bytes32 Hash;\r\n        Hash = fileQrCodeWithTime[QRCode][0].hashFile;\r\n        require(fileExists(Hash),\u0022file does not exists\u0022);\r\n        uint256 index = fileQrCodeWithTime[QRCode][0].index;\r\n        address sender = fileProofs[Hash][index].sender;\r\n        address receiver = fileProofs[Hash][index].receiver;\r\n        (uint256 year, uint256 month, uint256 day) = getDateTime(fileProofs[Hash][index].timestamp);\r\n        return (sender, receiver, day, month, year, Hash);\r\n    }\r\n\r\n\r\n    /**\r\n     * @dev supporting function for searching folder information  via QR code \r\n     */\r\n    function _InSearchFolderTransferProof(bytes32 QRCode) internal view returns(address , address , address , bytes32)\r\n    {\r\n        address folderAddress;\r\n        folderAddress = folderQrCodeWithoutTime[QRCode][0].folderAddress;\r\n        require(folderExists(folderAddress), \u0022folder does not exist\u0022);\r\n        uint256 index = folderQrCodeWithoutTime[QRCode][0].index;\r\n        address sender = folderProofs[folderAddress][index].sender;\r\n        address receiver = folderProofs[folderAddress][index].receiver;\r\n        bytes32 folderHash = folderProofs[folderAddress][index].folderHash;\r\n        return (sender, receiver, folderAddress , folderHash);\r\n    }\r\n\r\n\r\n    /**\r\n     * @dev supporting function for searching folder information with day , month , year via QR code    \r\n     */\r\n    function _InSearchFolderTransferProofWithTime(bytes32 QRCode) internal view returns(address ,address , address , bytes32,uint256 , uint256 , uint256)\r\n    {\r\n        address folderAddress;\r\n        folderAddress = folderQrCodeWithTime[QRCode][0].folderAddress;\r\n        require(folderExists(folderAddress), \u0022folder does not exist\u0022);\r\n        uint256 index = folderQrCodeWithTime[QRCode][0].index;\r\n        address sender = folderProofs[folderAddress][index].sender;\r\n        address receiver = folderProofs[folderAddress][index].receiver;\r\n        bytes32 folderHash = folderProofs[folderAddress][index].folderHash;\r\n        (uint256 year, uint256 month, uint256 day) = getDateTime(folderProofs[folderAddress][index].timestamp);\r\n        return (sender, receiver, folderAddress,folderHash, day, month, year);\r\n    }\r\n\r\n\r\n    /**\r\n     * @dev checks file exists or not , using File Hash\r\n     */\r\n    function fileExists(bytes32 fileHash)internal view  returns (bool)\r\n    {\r\n        bool exists = false;\r\n        if (usedFileHashes[fileHash])\r\n        {\r\n            exists = true;\r\n        }\r\n        return exists;\r\n    }\r\n  \r\n\r\n    /**\r\n     * @dev checks folder exists or not , using folder addressn\r\n     */\r\n    function folderExists(address folderAddress) internal view  returns (bool)\r\n    {\r\n        bool exists = false;\r\n        if (usedFolderAddresses[folderAddress])\r\n        {\r\n            exists = true;\r\n        }\r\n  \r\n        return exists;\r\n    }\r\n    \r\n}\r\n\r\n// File: browser/ProofOfTransfer.sol\r\n\r\npragma solidity \u003E=0.4.21 \u003C0.6.0;\r\n\r\n\r\ncontract ProofOfTransfer is Dependency\r\n{ \r\n\r\n  /**\r\n   * @dev Creates and stores the File transfer proof at the block timestamp\r\n   * timestamp in stored as no minor change in time shall be there at time of storing and creting QR hash\r\n   * @param _sender , represents the entity who is sending the file\r\n   * @param _receiver , represents the entity who is receiving the file \r\n   * @param _fileHash , hash of file being transferred\r\n   * @return bool , true if creates the file transfer proof entry successfully\r\n   */\r\n    function createFileTransferProof(address _sender, address _receiver, bytes32 _fileHash) public returns (bool)\r\n    {\r\n        uint256 time = block.timestamp;\r\n        bytes32 QRWithNoTime = getQRCodeForFile(_sender, _receiver, _fileHash, 0);\r\n        bytes32 QRWithTime = getQRCodeForFile(_sender, _receiver,_fileHash, time);\r\n        return _inCreateFileTransferProof(_sender,_receiver,_fileHash,time,QRWithNoTime,QRWithTime);\r\n    }\r\n\r\n\r\n      /**\r\n   * @dev Creates and stores the Folder transfer proof at the block timestamp\r\n   * @param _sender , represents the entity who is sending folder\r\n   * @param _receiver , represents the entity who is receiving folder\r\n   * @param _folderAddress , address of folder which is being send\r\n   * @return bool , true if creates the fiolder transfer proof entry successfully\r\n   */\r\n    function createFolderTransferProof(address _sender, address _receiver, address _folderAddress , bytes32 folderHash ) public returns(bool)\r\n    { \r\n        uint256 time = block.timestamp;\r\n        bytes32 QRWithNoTime = getQRCodeForFolder(_sender, _receiver, _folderAddress,folderHash, 0);\r\n        bytes32 QRWithTime = getQRCodeForFolder(_sender, _receiver, _folderAddress,folderHash, time);\r\n        return _inCreateFolderTransferProof(_sender,_receiver,_folderAddress,folderHash,time,QRWithNoTime,QRWithTime);        \r\n    }\r\n\r\n\r\n /**\r\n   * @dev get file transfer proof by using filehash\r\n   * @param fileHash , hash of file , whose information is to be fetched\r\n   * @return , address of sender , reciever and QR code \r\n   */\r\n    function getFileTransferProofs(bytes32 fileHash, uint256 Index) public view returns(address[] memory,bytes32,bool)\r\n    {   \r\n        require(fileExists(fileHash),\u0022No file found\u0022);\r\n        (address[] memory senderAndReceiver,bytes32 QR,bool nextIndexPresent) = _inGetFileTransferProofs(fileHash, Index);\r\n        return (senderAndReceiver,QR,nextIndexPresent);\r\n    }\r\n\r\n\r\n  /**\r\n    * @dev get file transfer proof with time detail by using filehash\r\n    * @param fileHash , hash of file , whose information is to be fetched\r\n    * @return , address of sender , reciever and QR code with day ,month and year information also\r\n    */\r\n    function getFileTransferProofWithTDateTime(bytes32 fileHash, uint256 Index) public view returns(address[] memory,bytes32, uint256[] memory,bool)\r\n    {\r\n        require(fileExists(fileHash),\u0022No file found\u0022);\r\n        //sending length in this function to remove \u0022STACK TOO DEEEP ERROR\u0022 \r\n        uint256 len = fileProofs[fileHash].length;\r\n        (address[] memory senderAndReceiver,bytes32 QR,uint256[] memory Date,bool nextIndexPresent) = _inGetFileTransferProofsDateTime(fileHash, Index ,len);\r\n        return (senderAndReceiver,QR,Date,nextIndexPresent);\r\n    }\r\n    \r\n\r\n    /**\r\n   * @dev get folder transfer proof by using folder address\r\n   * @param folderAddress , address of folder , whose information is to be fetched\r\n   * @return , address of sender , reciever and QR code \r\n   */\r\n    function getFolderTransferProofs(address folderAddress, uint256 Index) public view returns (address[] memory, bytes32,bytes32,bool)\r\n    {   \r\n        require(folderExists(folderAddress),\u0022No folder found\u0022);\r\n        (address[] memory senderAndReceiver ,bytes32 folderHash,bytes32 QR,bool nextIndexPresent) = _inGetFolderTransferProofs(folderAddress, Index); \r\n        return (senderAndReceiver,folderHash,QR,nextIndexPresent);\r\n    }\r\n\r\n\r\n  /**\r\n   * @dev get folder transfer proof by using folder address with date time details\r\n   * @param folderAddress , address of folder , whose information is to be fetched\r\n   * @return , address of sender , reciever and QR code with day ,month and year information also\r\n   */\r\n    function getFolderTransferProofsWithDateTime(address folderAddress , uint256 Index) public view returns(address[] memory, bytes32,bytes32, uint256[] memory,bool)\r\n    {\r\n        require(folderExists(folderAddress),\u0022No folder found\u0022);\r\n        //sending length in this function to remove \u0022STACK TOO DEEEP ERROR\u0022 \r\n        uint256 len = folderProofs[folderAddress].length;\r\n        (address[] memory senderAndReceiver, bytes32 folderHash,bytes32 QR,uint256[] memory Date,bool nextIndexPresent) = _inGetFolderTransferProofsWithDateTime(folderAddress, Index, len);\r\n        return (senderAndReceiver,folderHash,QR,Date,nextIndexPresent);\r\n    }\r\n\r\n  /**\r\n   * @dev search file transfer proof using QR code\r\n   * @param QRCode , whose information is to be fetched\r\n   * @return , address of sender, reciever and fileHash\r\n   */\r\n    function SearchFileTransferProof(bytes32 QRCode) public view returns(address , address ,bytes32)\r\n    {\r\n        return _InSearchFileTransferProof(QRCode);\r\n    }\r\n\r\n\r\n  /**\r\n   * @dev search file transfer proof using QR code with time details\r\n   * @param QRCodeTime , whose information is to be fetched\r\n   * @return , address of sender, reciever and fileHash with day ,month and year information also\r\n   */\r\n    function SearchFileTransferProofWithTime(bytes32 QRCodeTime) public view returns(address , address , uint256 , uint256 , uint256 ,bytes32)\r\n    {\r\n        return _InSearchFileTransferProofWithTime(QRCodeTime);\r\n    }\r\n\r\n\r\n   /**\r\n   * @dev search folder transfer proof using QR code \r\n   * @param QRCode , whose information is to be fetched\r\n   * @return , address of sender, reciever and address of the folder\r\n   */\r\n    function SearchFolderTransferProof(bytes32 QRCode) public view returns(address , address , address , bytes32)\r\n    {\r\n        return _InSearchFolderTransferProof(QRCode);\r\n    }\r\n\r\n   /**\r\n   * @dev search folder transfer proof using QR code with time details\r\n   * @param QRCodeTime , whose information is to be fetched\r\n   * @return , address of sender, reciever and address of the folder with day ,month and year information also\r\n   */\r\n    function SearchFolderTransferProofWithTime(bytes32 QRCodeTime) public view returns(address ,address , address, bytes32 , uint256 , uint256 , uint256)\r\n    {\r\n        return _InSearchFolderTransferProofWithTime(QRCodeTime);\r\n    }     \r\n\r\n\r\n  /**\r\n   * @dev generates the QR code using filehash ,etc\r\n   * Can generate QR code with time and without time\r\n   */\r\n    function getQRCodeForFile (address _sender, address _receiver,bytes32 fileHash, uint256 timestamp) internal pure returns (bytes32)\r\n    {\r\n        bytes32 QRCodeHash;\r\n\r\n        if(timestamp == 0)  //generate QR code without dateTime\r\n        {\r\n            QRCodeHash = keccak256(abi.encodePacked(_sender, _receiver,fileHash));\r\n        }\r\n        else \r\n        {\r\n            (uint256 year, uint256 month, uint256 day) = getDateTime(timestamp);\r\n            QRCodeHash = keccak256(abi.encodePacked(_sender, _receiver, fileHash, day, month, year));\r\n        }\r\n\r\n        return QRCodeHash;\r\n    }\r\n\r\n\r\n  /**\r\n   * @dev generates the QR code using Folder address , etc \r\n   * Can generate QR code with time and without time\r\n   */\r\n    function getQRCodeForFolder (address _sender, address _receiver,address folderAddress,bytes32 folderHash, uint256 timestamp) internal pure returns (bytes32)\r\n    {\r\n        bytes32 QRCodeHash;\r\n\r\n        if(timestamp == 0)  //generate QR code without dateTime\r\n        {\r\n            QRCodeHash = keccak256(abi.encodePacked(_sender, _receiver,folderAddress , folderHash));\r\n        }\r\n        else \r\n        {\r\n            (uint256 year, uint256 month, uint256 day) = getDateTime(timestamp);\r\n            QRCodeHash = keccak256(abi.encodePacked(_sender, _receiver,folderAddress,folderHash,day,month, year));\r\n        }\r\n\r\n        return QRCodeHash;\r\n    }\r\n\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_folderAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022folderHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022createFolderTransferProof\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022fileHash\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022Index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getFileTransferProofWithTDateTime\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022QRCode\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022SearchFolderTransferProof\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022fileHash\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022Index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getFileTransferProofs\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022QRCodeTime\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022SearchFolderTransferProofWithTime\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022folderAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022Index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getFolderTransferProofsWithDateTime\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022QRCode\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022SearchFileTransferProof\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022folderAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022Index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getFolderTransferProofs\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022QRCodeTime\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022SearchFileTransferProofWithTime\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_fileHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022createFileTransferProof\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"ProofOfTransfer","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://d2ad2d55bddbe443133323f01bf50b66ecf941fdee80bfc97febea9ee017acf3"}]