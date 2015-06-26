# RClient for the meXBT **DATA API**
* * *
## Introduction
* * *
R Code API for connecting to the **meXBT - The Mexican Exchange of Bitcoins**, *Public* API. This code is a series of functions for building *GET* *Request Queries* in order to pull information from the **meXBT** system, this can be read at their [HomePage](https://mexbt.com/en/api/http/)

- **License:** GNU General Public License
- **Location:** Mexico City

## R Packages/Libraries used
* * *
Some important functions are used to build this API Client/Wrapper. Most of them come from
the following packages/libraries, which official documentation is also included in this repossitory:

- **base**: *Base Statistical and data functions in R.*
- **httr**: *Tools for Working with URLs and HTTP.*
- **jsonlite**: *A Robust, High Performance JSON Parser and Generator for R.*
- **lubridate**: *Make dealing with dates a little easier.*
- **plyr**: *Tools for Splitting, Applying and Combining Data.*
- **RCurl**: *General network (HTTP/FTP/...) client interface for R.*
- **xts**: *eXtensible Time Series.*
- **zoo**: *S3 Infrastructure for Regular and Irregular Time Series.*

You can check and download the official documentation for these packages from this repository [Here](https://github.com/FranciscoME/meXBTRClient/tree/master/LibrariesInfo) or from the **CRAN** site [Here](http://cran.r-project.org/src/contrib/Archive/)

## Data API Info Provided
* * *
- **Order Book** For every market available, currently two: Btc/Usd and Btc/Mxn.
- **Historical Trades** Every trade executed at the exchange, for both markets.
- **Actual Tick (Price)** Present ticker price of Btc/Usd and Btc/Mxn.

## HTTP Character String to fetch data
* * *
#### Order Book

```r
# HTTP Address to fetch from for Btc/Usd
HttpAddress <- "https://data.mexbt.com/order-book/btcusd"
# HTTP Address to fetch from for Btc/Mxn
HttpAddress <- "https://data.mexbt.com/order-book/btcmxn" 
```

#### Historical Trades

```r
# HTTP Address to fetch from for Btc/Usd
HttpAddress <- "https://data.mexbt.com/trades/btcusd?since=0"
# HTTP Address to fetch from for Btc/Mxn
HttpAddress <- "https://data.mexbt.com/trades/btcmxn?since=0"
```

#### Actual Tick (Price)

```r
# HTTP Address to fetch from for Btc/Usd
HttpAddress <- "https://data.mexbt.com/ticker/btcusd"
# HTTP Address to fetch from for Btc/Mxn
HttpAddress <- "https://data.mexbt.com/ticker/btcmxn"
```

## An Easy Example

This code generates a request to fetch Btc/Mxn Exchange Rate, convert the response from *JSON* format to a *data.frame* object, then modify the unix timestamp to a Human readable format to finally re-organize the columns and deliver a tidy *data.frame* ready to use for
any computation.

```r
HmeXBTBtcMxn1 <- "https://data.mexbt.com/trades/btcmxn?since=12205"
HmeXBTBtcMxn2 <- getURL(HmeXBTBtcMxn1,cainfo=system.file("CurlSSL",
                 "cacert.pem",package="RCurl"))
HmeXBTBtcMxn3 <- data.frame(fromJSON(HmeXBTBtcMxn2))

BtcMxn <- data.frame(HmeXBTBtcMxn3$tid,
          as.POSIXct(as.numeric(as.character(HmeXBTBtcMxn3$date)),            # BTC/MXN
          origin = '1970-01-01', tz='America/Mexico_City'),                   # Date
          HmeXBTBtcMxn3$price, HmeXBTBtcMxn3$amount)                          # Formated
colnames(BtcMxn) <- c("TickerID","TimeStamp","Price","Amount")                # Posixct
```

<br>

**FranciscoME**: *Research & Development* - franciscome@mexbt.com