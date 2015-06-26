# -- ----------------------------------------------------------------------------------- #
# -- meXBT API CONNECTOR --------------------------------------------------------------- #
# -- License: GNU License V3 ----------------------------------------------------------- #
# -- Initial Developer: FranciscoME ---------------------------------------------------- #
# -- ----------------------------------------------------------------------------------- #

# -- Install if required or Load necessary packages suppressing messages at console ---- #

if (!require(base)) install.packages('base', quiet = TRUE)
suppressMessages(library (base))       # basic R functions
if (!require(httr)) install.packages('httr', quiet = TRUE)
suppressMessages(library (httr))       # url reader
if (!require(jsonlite)) install.packages('jsonlite', quiet = TRUE)
suppressMessages(library (jsonlite))   # JSON parser
if (!require(lubridate)) install.packages('lubridate', quiet = TRUE)
suppressMessages(library (lubridate))  # treatment and modification for dates
if (!require(plyr)) install.packages('plyr', quiet = TRUE)
suppressMessages(library (plyr))       # General data treatment
if (!require(RCurl)) install.packages('RCurl', quiet = TRUE)
suppressMessages(library (RCurl))      # leer url's
if (!require(xts)) install.packages('xts', quiet = TRUE)
suppressMessages(library (xts))        # Time series utilities
if (!require(zoo)) install.packages('zoo', quiet = TRUE)
suppressMessages(library (zoo))        # Time series utilities

setwd("~/Documents/ComputationalFinance/GitHub/meXBTRClient")        # Change with yours
options("scipen"=100)       # No scientific Notation when big or small numbers displayed

# ------------------------------------------------------------------------------------- #
# -- Get Tick Historical Prices from meXBT PUBLIC API --------------------------------- #
# ------------------------------------------------------------------------------------- #

HmeXBTBtcUsd1 <- "https://data.mexbt.com/trades/btcusd?since=1"               # BTC/USD
HmeXBTBtcUsd2 <- getURL(HmeXBTBtcUsd1,cainfo=system.file("CurlSSL",
                 "cacert.pem",package="RCurl"))
HmeXBTBtcUsd3 <- data.frame(fromJSON(HmeXBTBtcUsd2))

BtcUsd <- data.frame(HmeXBTBtcUsd3$tid,
          as.POSIXct(as.numeric(as.character(HmeXBTBtcUsd3$date)),            # BTC/USD
          origin = '1970-01-01', tz='America/Mexico_City'),                   # Date
          HmeXBTBtcUsd3$price, HmeXBTBtcUsd3$amount)                          # Formated
colnames(BtcUsd) <- c("TickerID","TimeStamp","Price","Amount")                # Posixct

HmeXBTBtcMxn1 <- "https://data.mexbt.com/trades/btcmxn?since=12205"
HmeXBTBtcMxn2 <- getURL(HmeXBTBtcMxn1,cainfo=system.file("CurlSSL",
                 "cacert.pem",package="RCurl"))
HmeXBTBtcMxn3 <- data.frame(fromJSON(HmeXBTBtcMxn2))

BtcMxn <- data.frame(HmeXBTBtcMxn3$tid,
          as.POSIXct(as.numeric(as.character(HmeXBTBtcMxn3$date)),            # BTC/MXN
          origin = '1970-01-01', tz='America/Mexico_City'),                   # Date
          HmeXBTBtcMxn3$price, HmeXBTBtcMxn3$amount)                          # Formated
colnames(BtcMxn) <- c("TickerID","TimeStamp","Price","Amount")                # Posixct

# ------------------------------------------------------------------------------------- #
# -- Get Actual Ticker of BitCoin from meXBT PUBLIC API ------------------------------- #
# ------------------------------------------------------------------------------------- #

meXBTQuery1  <- "https://data.mexbt.com/ticker/btcmxn"            # HTTP Query Address    
meXBTQuery1G <- getURL(meXBTQuery1,cainfo=system.file("CurlSSL",
                "cacert.pem",package="RCurl"))
meXBTBtcMxn  <- data.frame(fromJSON(meXBTQuery1G))
TmeXBTBtcMxn <- data.frame(Sys.time(),meXBTBtcMxn$last,meXBTBtcMxn$bid,meXBTBtcMxn$ask)
colnames(TmeXBTBtcMxn) <- c("Date","Value","Bid","Ask")

meXBTQuery1  <- "https://data.mexbt.com/ticker/btcusd"            # HTTP Query Address
meXBTQuery1G <- getURL(meXBTQuery1,cainfo=system.file("CurlSSL",
                "cacert.pem",package="RCurl"))
meXBTBtcUsd  <- data.frame(fromJSON(meXBTQuery1G))
TmeXBTBtcUsd <- data.frame(Sys.time(),meXBTBtcUsd$last,meXBTBtcUsd$bid,meXBTBtcUsd$ask)
colnames(TmeXBTBtcUsd) <- c("Date","Value","Bid","Ask")

# ------------------------------------------------------------------------------------- #
# -- Order Book from meXBT PUBLIC API ------------------------------------------------- #
# ------------------------------------------------------------------------------------- #

meXBTOBQuery  <- "https://data.mexbt.com/order-book/btcusd"       # HTTP Query Address
meXBTOBQuery1 <- getURL(meXBTOBQuery,cainfo=system.file("CurlSSL",
                 "cacert.pem",package="RCurl"))

meXBTOBBids   <- data.frame(fromJSON(meXBTOBQuery1)[1])           # JSON to Data Frame
meXBTOBBids$Side      <- "Long(Bid)"
colnames(meXBTOBBids) <- c("Price","Amount","Side")

meXBTOBAsks   <- data.frame(fromJSON(meXBTOBQuery1)[2])           # JSON to Data Frame
meXBTOBAsks$Side      <- "Short(Ask)"
colnames(meXBTOBAsks) <- c("Price","Amount","Side")
meXBTBtcUsdOB <- rbind(meXBTOBBids,meXBTOBAsks)                   # Join Bids/Ask orders

meXBTOBQuery  <- "https://data.mexbt.com/order-book/btcmxn"       # HTTP Query Address
meXBTOBQuery1 <- getURL(meXBTOBQuery,cainfo=
                 system.file("CurlSSL","cacert.pem",package="RCurl"))

meXBTOBBids   <- data.frame(fromJSON(meXBTOBQuery1)[1])           # JSON to Data Frame
meXBTOBBids$Side      <- "Long(Bid)"
colnames(meXBTOBBids) <- c("Price","Amount","Side")

meXBTOBAsks   <- data.frame(fromJSON(meXBTOBQuery1)[2])           # JSON to Data Frame
meXBTOBAsks$Side      <- "Short(Ask)"
colnames(meXBTOBAsks) <- c("Price","Amount","Side")
meXBTBtcMxnOB <- rbind(meXBTOBBids,meXBTOBAsks)                   # Join Bids/Ask orders
