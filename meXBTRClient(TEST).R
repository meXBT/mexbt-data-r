# -- -------------------------------------------------------------------------------------------- #
# -- meXBT API CONNECTOR ------------------------------------------------------------------------ #
# -- License: GNU License V3 -------------------------------------------------------------------- #
# -- -------------------------------------------------------------------------------------------- #

Side <- "buy"
Qty  <- "0.0010"
TimeZonePar  <- 'America/Mexico_City'
InfoSince    <- 1
TimeInterval <- "hours"
StartIndex <- -1
OrderType  <- 1
Instrument <- "BTCUSD"
PrivateKey <- "123abc"
APIKey  <- "1234abcd"
UserID  <- "franciscome@mexbt.com"
Action  <- 1
Count   <- 20
Amount  <- 10
Address <- "fr"

HPR <- HistoricPrices(BtcPair,TimeZonePar,InfoSince)
TCK <- Ticker(BtcPair)
OBO <- OrderBook(BtcPair)
OHL <- OHLC(BtcPair,InfoSince,TimeInterval)
CRO <- CreateOrder(Side,Qty,Instrument,UserID,PrivateKey,APIKey, OrderType)
MOR <- ModifyOrder(UserID,PrivateKey,APIKey,OrderID,Action)
COR <- CancelOrder(UserID,PrivateKey,APIKey,OrderID,Action)
CAL <- CancelAll(UserID,PrivateKey,APIKey,Instrument)
UIN <- UserInfo(UserID,PrivateKey,APIKey)
ABA <- AccountBalance(UserID,PrivateKey,APIKey)
ATR <- AccountTrades(UserID,PrivateKey,APIKey,Instrument,StartIndex,Count)
AOR <- AccountOrders(UserID,PrivateKey,APIKey)
DAD <- DepositAddresses(UserID,PrivateKey,APIKey)
WDR <- Withdraw(UserID,PrivateKey,APIKey,Instrument,Amount,Address)
