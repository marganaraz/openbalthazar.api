using System;
using System.Collections.Generic;
using System.Text;

namespace Etherscan.Models
{
    public class EtherscanTransaction
    {
        public int TimeStamp { get; set; }

        public static DateTime UnixTimeStampToDateTime(int unixTimeStamp)
        {
            // Unix timestamp is seconds past epoch
            System.DateTime dtDateTime = new DateTime(1970, 1, 1, 0, 0, 0, 0, System.DateTimeKind.Utc);
            dtDateTime = dtDateTime.AddSeconds(unixTimeStamp).ToLocalTime();
            return dtDateTime;
        }

        /// <summary>
        /// Convert unix TimeStamp to DateTime
        /// </summary>
        public DateTime DateTime
        {
            get
            {
                return UnixTimeStampToDateTime(TimeStamp);
            }
        }

        // TxHash
        public String Hash { get; set; }

        public String From { get; set; }

        public String To { get; set; }

        public Decimal Value { get; set; }

        /// <summary>
        /// Convert Value to 1 ETH
        /// </summary>
        public Decimal Amount
        {
            get
            {
                return Value / 1000000000000000000;
            }
        }

        public Decimal GasPrice { get; set; }

        public Decimal GasUsed { get; set; }

        /// <summary>
        /// Fee in ETH amount
        /// </summary>
        public Decimal Fee
        {
            get
            {
                return GasPrice * GasUsed / 1000000000000000000;
            }
        }

        /// <summary>
        /// 0 - No error
        /// </summary>
        public int IsError { get; set; }

        /// <summary>
        /// 1 = Success
        /// </summary>
        public int? TxreceiptStatus { get; set; }
    }
}
