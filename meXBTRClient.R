# -- -------------------------------------------------------------------------------------------- #
# -- meXBT API CONNECTOR ------------------------------------------------------------------------ #
# -- License: GNU License V3 -------------------------------------------------------------------- #
# -- -------------------------------------------------------------------------------------------- #

# -- Install if required or Load necessary packages suppressing messages at console ------------- #

if (!require(base)) install.packages('base', quiet = TRUE)              # basic R functions
suppressMessages(library (base))
if (!require(httr)) install.packages('httr', quiet = TRUE)              # URL read functions
suppressMessages(library (httr))
if (!require(jsonlite)) install.packages('jsonlite', quiet = TRUE)      # JSON parser/converter
suppressMessages(library (jsonlite))
if (!require(lubridate)) install.packages('lubridate', quiet = TRUE)    # Date Objects Utilities
suppressMessages(library (lubridate))
if (!require(plyr)) install.packages('plyr', quiet = TRUE)              # General data treatment
suppressMessages(library (plyr))
if (!require(quantmod)) install.packages('quantmod', quiet = TRUE)
suppressMessages(library (quantmod))   # Stock Prices and Dividends from YAHOO
if (!require(RCurl)) install.packages('RCurl', quiet = TRUE)            # Read URL's and get data
suppressMessages(library (RCurl))
if (!require(xts)) install.packages('xts', quiet = TRUE)                # Extesible Time Series
suppressMessages(library (xts))
if (!require(zoo)) install.packages('zoo', quiet = TRUE)                # Time series utilities
suppressMessages(library (zoo))

options("scipen"=100)        # No scientific Notation when too big or too small numbers displayed

# ----------------------------------------------------------------------------------------------- #
# -- Get Tick Historical Prices from meXBT PUBLIC API ------------------------------------------- #
# ----------------------------------------------------------------------------------------------- #

# "since" parameter is the tick/trade number from which you want to fetch data, 0 is from the
# very begining of our data and that is "2014-05-12 21:16:34 CDT" for both Btc/Usd and and Btc/Mxn

meXBTHistoricPrices <- function(BtcPair,TimeZonePar,InfoSince)
{
HmeXBTBtcUsd1a <- paste("https://data.mexbt.com/trades/",BtcPair,sep="")
HmeXBTBtcUsd1b <- paste(HmeXBTBtcUsd1a,"?since=",sep="")
HmeXBTBtcUsd1c <- paste(HmeXBTBtcUsd1b,InfoSince,sep="")
HmeXBTBtcUsd2  <- getURL(HmeXBTBtcUsd1c,cainfo=system.file("CurlSSL",
                 "cacert.pem",package="RCurl"))
HmeXBTBtcUsd3 <- data.frame(fromJSON(HmeXBTBtcUsd2))

BtcUsd <- data.frame(HmeXBTBtcUsd3$tid,
as.POSIXct(as.numeric(as.character(HmeXBTBtcUsd3$date)),
origin = '1970-01-01', tz='America/Mexico_City'),
HmeXBTBtcUsd3$price, HmeXBTBtcUsd3$amount)
colnames(BtcUsd) <- c("TickerID","TimeStamp","Price","Amount")
return(BtcUsd)
}

# ----------------------------------------------------------------------------------------------- #
# -- Get Current Price Ticker of BitCoin from meXBT PUBLIC API ---------------------------------- #
# ----------------------------------------------------------------------------------------------- #

meXBTTicker <- function(BtcPair)
{
meXBTQuery1  <- paste("https://data.mexbt.com/ticker/",BtcPair,sep="")
meXBTQuery1G <- getURL(meXBTQuery1,cainfo=system.file("CurlSSL",
                "cacert.pem",package="RCurl"))
TickermeXBT  <- data.frame(fromJSON(meXBTQuery1G))
TickermeXBT  <- data.frame(Sys.time(),TickermeXBT$last,TickermeXBT$bid,TickermeXBT$ask,
                TickermeXBT$askCount, TickermeXBT$bidCount)
colnames(TickermeXBT) <- c("Date","Value","Bid","Ask","AskCount","BidCount")
return(TickermeXBT)
}

# ----------------------------------------------------------------------------------------------- #
# -- Get Current Order Book from meXBT PUBLIC API ----------------------------------------------- #
# ----------------------------------------------------------------------------------------------- #

meXBTOrderBook <- function(BtcPair)
{
meXBTts <- Sys.time()
meXBTOBQuery  <- paste("https://data.mexbt.com/order-book/",BtcPair,sep="")
meXBTOBQuery1 <- getURL(meXBTOBQuery,cainfo=system.file("CurlSSL",
                 "cacert.pem",package="RCurl"))
meXBTOBBids <- data.frame(fromJSON(meXBTOBQuery1)[1])
meXBTOBBids$Side <- "Long(Bid)"
meXBTOBBids <- meXBTOBBids[-length(meXBTOBBids[,1]),]
colnames(meXBTOBBids) <- c("Price","Amount","Side")

meXBTOBAsks <- data.frame(fromJSON(meXBTOBQuery1)[2])
meXBTOBAsks$Side <- "Short(Ask)"
colnames(meXBTOBAsks) <- c("Price","Amount","Side")
meXBTBtcUsdOB <- rbind(meXBTOBBids,meXBTOBAsks)

meXBTBtcUsdOB <- data.frame(meXBTts,meXBTBtcUsdOB[,])
colnames(meXBTBtcUsdOB) <- c("TimeStamp","Price","Amount","Side")
return(meXBTBtcUsdOB)
}

# ----------------------------------------------------------------------------------------------- #
# -- OHLC Historic Prices ----------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------- #

meXBTOHLC <- function(BtcPair,InfoSince,TimeInterval)
{
HmeXBTBtc1a <- paste("https://data.mexbt.com/trades/",BtcPair,sep="")
HmeXBTBtc1b <- paste(HmeXBTBtc1a,"?since=",sep="")
HmeXBTBtc1c <- paste(HmeXBTBtc1b,InfoSince,sep="")
HmeXBTBtc2  <- getURL(HmeXBTBtc1c,cainfo=system.file("CurlSSL",
                 "cacert.pem",package="RCurl"))
HmeXBTBtc3 <- data.frame(fromJSON(HmeXBTBtc2))

BtcPrice  <- data.frame(as.POSIXct(as.numeric(as.character(HmeXBTBtc3$date)),
origin = '1970-01-01', tz='America/Mexico_City'),HmeXBTBtc3$price)
colnames(BtcPrice) <- c("TimeStamp","Price")

BtcAmount <- data.frame(as.POSIXct(as.numeric(as.character(HmeXBTBtc3$date)),
origin = '1970-01-01', tz='America/Mexico_City'),HmeXBTBtc3$amount)
colnames(BtcAmount) <- c("TimeStamp","Amount")

xtsBtcPrice  <- xts(BtcPrice$Price, order.by = BtcPrice$TimeStamp)
xtsBtcAmount <- xts(BtcAmount$Amount, order.by = BtcAmount$TimeStamp)
xtsBtcPrice  <- to.period(xtsBtcPrice, period = TimeInterval,k=1, indexAt="startof")
xtsBtcAmount <- to.period(xtsBtcAmount, period = TimeInterval,k=1, indexAt="startof")
Final <- cbind(xtsBtcPrice,xtsBtcAmount)
Final <- fortify.zoo(Final)
colnames(Final) <- c("TimeStamp","Open(Price)","High(Price)","Low(Price)","Close(Price)",
"Open(Volume)","High(Volume)","Low(Volume)","Close(Volume)")
return(Final)
}

meXBTOHLCTest <- meXBTOHLC("btcmxn",12700,"hours")
