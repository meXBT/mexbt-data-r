# -- -------------------------------------------------------------------------------------------- #
# -- meXBT API CONNECTOR ------------------------------------------------------------------------ #
# -- License: GNU License V3 -------------------------------------------------------------------- #
# -- -------------------------------------------------------------------------------------------- #

# ----------------------------------------------------------------------------------------------- #
# -- Get Tick Historical Prices from meXBT PUBLIC API ------------------------------------------- #
# ----------------------------------------------------------------------------------------------- #

# "since" parameter is the tick/trade number from which you want to fetch data, 0 is from the
# very begining of our data and that is "2014-05-12 21:16:34 CDT" for both Btc/Usd and and Btc/Mxn

HistoricPrices <- function(Instrument,TimeZonePar,InfoSince)
{
  HmeXBTBtcUsd1a <- paste("https://data.mexbt.com/trades/",Instrument,sep="")
  HmeXBTBtcUsd1b <- paste(HmeXBTBtcUsd1a,"?since=",sep="")
  HmeXBTBtcUsd1c <- paste(HmeXBTBtcUsd1b,InfoSince,sep="")
  HmeXBTBtcUsd2  <- getURL(HmeXBTBtcUsd1c,cainfo=system.file("CurlSSL","cacert.pem",package="RCurl"))
  HmeXBTBtcUsd3  <- data.frame(fromJSON(HmeXBTBtcUsd2))
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

Ticker <- function(Instrument)
{
  meXBTQuery1  <- paste("https://data.mexbt.com/ticker/",Instrument,sep="")
  meXBTQuery1G <- getURL(meXBTQuery1,cainfo=system.file("CurlSSL","cacert.pem",package="RCurl"))
  TickermeXBT  <- data.frame(fromJSON(meXBTQuery1G))
  TickermeXBT  <- data.frame(Sys.time(),TickermeXBT$last,TickermeXBT$bid,TickermeXBT$ask,
                  TickermeXBT$askCount, TickermeXBT$bidCount)
  colnames(TickermeXBT) <- c("Date","Value","Bid","Ask","AskCount","BidCount")
return(TickermeXBT)
}

# ----------------------------------------------------------------------------------------------- #
# -- Get Current Order Book from meXBT PUBLIC API ----------------------------------------------- #
# ----------------------------------------------------------------------------------------------- #

OrderBook <- function(Instrument)
{
  meXBTts <- Sys.time()
  meXBTOBQuery  <- paste("https://data.mexbt.com/order-book/",Instrument,sep="")
  meXBTOBQuery1 <- getURL(meXBTOBQuery,cainfo=system.file("CurlSSL","cacert.pem",package="RCurl"))
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

OHLC <- function(BtcPair,since,interval)
{
  HmeXBTBtc1a <- paste("https://data.mexbt.com/trades/",BtcPair,sep="")
  HmeXBTBtc1b <- paste(HmeXBTBtc1a,"?since=",sep="")
  HmeXBTBtc1c <- paste(HmeXBTBtc1b,since,sep="")
  HmeXBTBtc2  <- getURL(HmeXBTBtc1c,cainfo=system.file("CurlSSL","cacert.pem",package="RCurl"))
  HmeXBTBtc3  <- fromJSON(HmeXBTBtc2, simplifyDataFrame = TRUE)
  BtcPrice <- data.frame(HmeXBTBtc3$date,HmeXBTBtc3$price,HmeXBTBtc3$amount)
  BtcPrice[,1] <- as.POSIXct(as.numeric(BtcPrice[,1]),origin='1970-01-01',tz='America/Mexico_City')
  colnames(BtcPrice) <- c("TimeStamp","Price","Amount")

  xtsBtcPrice  <- xts(BtcPrice$Price, order.by = BtcPrice$TimeStamp)
  xtsBtcAmount <- xts(BtcPrice$Amount, order.by = BtcPrice$TimeStamp)
  xtsBtcPrice  <- to.period(xtsBtcPrice, period = interval,k=1, indexAt="endof")
  xtsBtcAmount <- to.period(xtsBtcAmount, period = interval,k=1, indexAt="endof")
  Final <- cbind(xtsBtcPrice,xtsBtcAmount)
  Final <- fortify.zoo(Final)

  colnames(Final) <- c("TimeStamp","Open.Price","High.Price","Low.Price","Close.Price",
  "Open.Volume","High.Volume","Low.Volume","Close.Volume")
return(Final)
}

# ----------------------------------------------------------------------------------------------- #
# -- Create a Market/Limit Order --------------------------------------------------------------T- #
# ----------------------------------------------------------------------------------------------- #

CreateOrder <- function(Side,Qty,Instrument,UserID,PrivateKey,APIKey,OrderType)
{
  APInonce    <- trunc(as.numeric(Sys.time()), "miliseconds")
  APIMessage  <-paste(paste(get("APInonce"),UserID,sep=""),APIKey,sep="")
  APISig <- toupper(hmac(object = APIMessage, key=PrivateKey,algo="sha256",serialize=FALSE))
  CreateOrder <-  content(POST(url = "https://private-api.mexbt.com/v1/orders/create", 
  body = list( apiKey = APIKey, apiSig = APISig, side = Side, qty  = Qty, apiNonce  = APInonce,
  ins  = Instrument, orderType = OrderType), encode = "json"), "parsed")
return(CreateOrder)
}

# ----------------------------------------------------------------------------------------------- #
# -- Modify An Order ---------------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------- #

ModifyOrder <- function(UserID,PrivateKey,APIKey,OrderID,Action)
{
  APInonce    <- trunc(as.numeric(Sys.time()), "miliseconds")
  APIMessage  <-paste(paste(get("APInonce"),UserID,sep=""),APIKey,sep="")
  APISig <- toupper(hmac(object = APIMessage, key=PrivateKey,algo="sha256",serialize=FALSE))
  ModifyOrder <-  content(POST(url = "https://private-api.mexbt.com/v1/orders/modify", 
  body = list( apiKey = APIKey, apiSig = APISig, apiNonce  = APInonce, serverOrderId = OrderID,
  ins  = Instrument, modifyAction = Action), encode = "json"), "parsed")
return(ModifyOrder) 
}

# ----------------------------------------------------------------------------------------------- #
# -- Cancel An Order ---------------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------- #

CancelOrder <- function(UserID,PrivateKey,APIKey,OrderID,Action)
{
  APInonce   <- trunc(as.numeric(Sys.time()), "miliseconds")
  APIMessage <-paste(paste(get("APInonce"),UserID,sep=""),APIKey,sep="")
  APISig <- toupper(hmac(object = APIMessage, key=PrivateKey,algo="sha256",serialize=FALSE))
  Post   <-  content(POST(url = "https://private-api.mexbt.com/v1/orders/modify", 
  body = list( apiKey = APIKey, apiSig = APISig, apiNonce  = APInonce, serverOrderId = OrderID,
  ins  = Instrument, modifyAction = Action), encode = "json"), "parsed")
return(Post) 
}

# ----------------------------------------------------------------------------------------------- #
# -- Cancel All Orders -------------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------- #

CancelAll <- function(UserID,PrivateKey,APIKey,Instrument)
{
  APInonce   <- trunc(as.numeric(Sys.time()), "miliseconds")
  APIMessage <-paste(paste(get("APInonce"),UserID,sep=""),APIKey,sep="")
  APISig <- toupper(hmac(object = APIMessage, key=PrivateKey,algo="sha256",serialize=FALSE))
  Post   <-  content(POST(url = "https://private-api.mexbt.com/v1/orders/cancel-all", 
  body = list(apiKey=APIKey, apiSig=APISig, apiNonce=APInonce, ins=Instrument),
  encode="json"),"parsed")
return(Post)
}

# ----------------------------------------------------------------------------------------------- #
# -- User Information --------------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------- #

UserInfo <- function(UserID,PrivateKey,APIKey)
{
  APInonce   <- trunc(as.numeric(Sys.time()), "miliseconds")
  APIMessage <-paste(paste(get("APInonce"),UserID,sep=""),APIKey,sep="")
  APISig <- toupper(hmac(object = APIMessage, key=PrivateKey,algo="sha256",serialize=FALSE))
  Post   <-  content(POST(url = "https://private-api.mexbt.com/v1/me", 
  body = list(apiKey=APIKey, apiSig=APISig, apiNonce=APInonce), encode="json"), "parsed")
return(Post)
}

# ----------------------------------------------------------------------------------------------- #
# -- Account Balance ---------------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------- #

AccountBalance <- function(UserID,PrivateKey,APIKey)
{
  APInonce   <- trunc(as.numeric(Sys.time()), "miliseconds")
  APIMessage <-paste(paste(get("APInonce"),UserID,sep=""),APIKey,sep="")
  APISig <- toupper(hmac(object = APIMessage, key=PrivateKey,algo="sha256",serialize=FALSE))
  Post   <-  content(POST(url = "https://private-api.mexbt.com/v1/balance", 
  body = list(apiKey=APIKey, apiSig=APISig, apiNonce=APInonce), encode="json"),"parsed")
return(Post)
}

# ----------------------------------------------------------------------------------------------- #
# -- Account Trades ----------------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------- #

AccountTrades <- function(UserID,PrivateKey,APIKey,Instrument,StartIndex,Count)
{
  APInonce   <- trunc(as.numeric(Sys.time()), "miliseconds")
  APIMessage <-paste(paste(get("APInonce"),UserID,sep=""),APIKey,sep="")
  APISig <- toupper(hmac(object = APIMessage, key=PrivateKey,algo="sha256",serialize=FALSE))
  Post   <-  content(POST(url = "https://private-api.mexbt.com/v1/trades", 
  body = list(apiKey=APIKey, apiSig=APISig, apiNonce=APInonce, ins=Instrument,
  startIndex = StartIndex, count = Count), encode="json"), "parsed")
return(Post)
}

# ----------------------------------------------------------------------------------------------- #
# -- Account Orders ----------------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------- #

AccountOrders <- function(UserID,PrivateKey,APIKey)
{
  APInonce   <- trunc(as.numeric(Sys.time()), "miliseconds")
  APIMessage <-paste(paste(get("APInonce"),UserID,sep=""),APIKey,sep="")
  APISig <- toupper(hmac(object = APIMessage, key=PrivateKey,algo="sha256",serialize=FALSE))
  Post   <-  content(POST(url = "https://private-api.mexbt.com/v1/orders", 
  body = list(apiKey=APIKey, apiSig=APISig, apiNonce=APInonce), encode="json"), "parsed")
return(Post)
}

# ----------------------------------------------------------------------------------------------- #
# -- Deposit Addresses -------------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------- #

DepositAddresses <- function(UserID,PrivateKey,APIKey)
{
  APInonce   <- trunc(as.numeric(Sys.time()), "miliseconds")
  APIMessage <-paste(paste(APInonce,UserID,sep=""),APIKey,sep="")
  APISig <- toupper(hmac(object = APIMessage, key=PrivateKey,algo="sha256",serialize=FALSE))
  Post   <-  content(POST(url = "https://private-api.mexbt.com/v1/deposit-addresses", 
  body = list(apiKey=APIKey, apiSig=APISig, apiNonce=APInonce), encode="json"), "parsed")
return(Post)
}

# ----------------------------------------------------------------------------------------------- #
# -- Withdraw Cryptocurrency -------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------- #

Withdraw <- function(UserID,PrivateKey,APIKey,Instrument,Amount,Address)
{
  APInonce   <- trunc(as.numeric(Sys.time()), "miliseconds")
  APIMessage <-paste(paste(get("APInonce"),UserID,sep=""),APIKey,sep="")
  APISig <- toupper(hmac(object = APIMessage, key=PrivateKey,algo="sha256",serialize=FALSE))
  Post <-  content(POST(url = "https://private-api.mexbt.com/v1/withdraw", 
  body = list(apiKey=APIKey, apiSig=APISig, apiNonce=APInonce, ins=Instrument, amount=Amount,
  sendToAddress = Address), encode="json"), "parsed")
return(Post)
}
