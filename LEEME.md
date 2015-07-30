# Cliente de R para API de meXBT

## Introducción

Código en R para conexión con la API de **meXBT - Exchange Mexicano de Bitcoins**. Éste código es una serie de funciones para construir peticiones ó *queries* del tipo *GET*, de tal manera que sea posible comunicarse con el servidor de **meXBT** y obtener cierto tipo de información útil para construir algorítmos de trading, aplicaciones web, modelos financieros en general que hagan uso de información respecto al precio del BitCoin.

- **Licencia:** GNU General Public License
- **Locasión:** Mexico City

<br>

## Librerías/Paquetes de R utilizados

Algunas funciones importantes utilizadas en éste código son provenientes de algunos paquetes adicionales a los de la instalación básica de *R*, éstos son enlistados a continuación y su documentación oficial también está incluida en éste repositorio:

- **base**: *Funciones básicas para R.*
- **httr**: *Herramientas para trabajar con URLs y direcciones HTTP.*
- **jsonlite**: *Analizador y constructor robusto para datos tipo JSON.*
- **lubridate**: *Trabajar más fácilmente con fechas.*
- **plyr**: *Herramientas para separar y combinar datos.*
- **RCurl**: *Marco general para páginas tipo (HTTP/FTP/...).*
- **xts**: *Base extensa de herramientas para Series de Tiempo.*
- **zoo**: *Herramientas para Series de Tiempo regulares e irregulares.*

La información oficial de todos y cada uno de las librerías/paquetes puede ser descargada en una sub-carpeta de éste repositorio [Aquí](https://github.com/FranciscoME/meXBTRClient/tree/master/LibrariesInfo) o desde la página del repositorio **CRAN** [Aquí](http://cran.r-project.org/src/contrib/Archive/)

<br>

## Información que provee la API de meXBT

- **Libro de Ordenes** Existente para cada mercado disponible en **meXBT**, actualmente son dos: Btc/Usd and Btc/Mxn.
- **Transacciones Históricas** Todas y cada una de las transacciones ejecutadas en meXBT, para todos los mercados disponibles. Están disponibles desde la primera transacción hasta la más actual.
- **Precio Actual** Precio actual de Btc/Usd y Btc/Mxn.

<br>

## ¿Cómo se utiliza este Cliente de R?

Todo lo que hay que hacer es localizar la función que provee de la información que se necesita, así como de conocer los parámetros de entrada y del tipo de dato que éstos deben de ser, las funciones se presentan a continuación:

- **Libro de Ordenes** Es pedido con la función: **meXBTOrderBook***(BtcPair)*
- **Transacciones Históricas** Se solicitan con: **meXBTHistoricPrices***(BtcPair,TimeZonePar,InfoSince)*
- **Precio Actual** Se utiliza: **meXBTTicker***(BtcPair)*

<br>

## Parámetros de entrada comunes

- **BtcPair** : Cualquiera de los siguientes **btcusd** (BitCoin Vs Dóllar Americano) Ó **btcmxn** (BitCoin Vs Peso Mexicano)
- **InfoSince**: Para especificar a partir de cuál transacción se desea consultar el histórico de transacciones, iniciando desde 0 para recibir absolutamente todas las transacciones realizadas en **meXBT**, lo cual sucedió en "2014-05-12 21:16:34 CDT" para los mercados *btcusd* y *btcmxn*
- **TimeZonePar**: Zona Horaria en formáto según la **IANA** (Internet Assigned Numbers Authority) time zone database, se puede consultar la lista completa de zonas horarios en el mundo **[Aquí](http://developer.oanda.com/docs/timezones.txt)**, y para mas información respecto **TZ DataBse** se puede recurrir **[Aquí](https://en.wikipedia.org/wiki/Tz_database)**

## Funciones que éste Cliente de R soporta

```r
Eg1 <- meXBTTicker("btcmxn")                                    # meXBTTicker(BtcPair)
Eg2 <- meXBTOrderBook("btcmxn")                                 # meXBTOrderBook(BtcPair)
Eg3 <- meXBTHistoricPrices("btcusd","America/Mexico_City",650)  # meXBTHistoricPrices(BtcPair,TimeZonePar,InfoSince)
```

<br>

## Peticiones manuales con cadena de caractéres específica en HTTP

Ó si deseas/necesitas construir tu propio código en éste lenguaje o en cualquier otro lo único que necesitas hacer es construir tus propias peticiones *http* GET - POST. Todo lo que hay que hacer es generar cadenas de caracteres como las que se muestras a continuación y se obtendrá una respuesta en formáto **JSON**.

#### Libro de ordenes

```r
# Dirección HTTP a la cual hacer la petición
HttpAddress <- "https://data.mexbt.com/order-book/btcusd"
# HTTP Address to fetch from for Btc/Mxn
HttpAddress <- "https://data.mexbt.com/order-book/btcmxn" 
```

#### Transacciones históricas

```r
# Dirección HTTP para Btc/Usd
HttpAddress <- "https://data.mexbt.com/trades/btcusd?since=0"
# Dirección HTTP para Btc/Mxn
HttpAddress <- "https://data.mexbt.com/trades/btcmxn?since=0"
```

#### Precio Actual

```r
# Dirección HTTP para Btc/Usd
HttpAddress <- "https://data.mexbt.com/ticker/btcusd"
# Dirección HTTP para Btc/Mxn
HttpAddress <- "https://data.mexbt.com/ticker/btcmxn"
```

<br>

## Un ejemplo simple

El siguiente código genera la petición para obtener los datos de respuesta del mercado *Btc/Mxn*, poteriormente se convierte la respuesta en formáto *JSON* a un formáto tipo *data.frame* para su fácil tratamiento dentro de *R*, después se modifica la impresión de tiempo tipo *unix* y reexpresarla en formáto para lectura de personas para finalmente organizar las columnas y entregar un objeto "data.frame" en el ambiente en *R*.

```r
HmeXBTBtcMxn1 <- "https://data.mexbt.com/trades/btcmxn?since=12205"           # 12205 es
HmeXBTBtcMxn2 <- getURL(HmeXBTBtcMxn1,cainfo=system.file("CurlSSL",           # como ejemplo
                 "cacert.pem",package="RCurl"))                               # Ejemplo
HmeXBTBtcMxn3 <- data.frame(fromJSON(HmeXBTBtcMxn2))

BtcMxn <- data.frame(HmeXBTBtcMxn3$tid,
          as.POSIXct(as.numeric(as.character(HmeXBTBtcMxn3$date)),            # BTC/MXN
          origin = '1970-01-01', tz='America/Mexico_City'),                   # Formáto
          HmeXBTBtcMxn3$price, HmeXBTBtcMxn3$amount)                          # Fecha
colnames(BtcMxn) <- c("TickerID","TimeStamp","Price","Amount")                # Posixct
```

Lo anterior debe de arrojar dos objetos *data.frame*, el primero **HmeXBTBtcMxn3** que está en formáto crudo, de manera que se pueda cambiar el factor *TimeStamp* con el uso horario elegido en la parte *Time Zone*. El objeto **BtcMxn** y particularmente su impresión de tiempo con el uso horario de *'America/Mexico_City'* *Time Zone*. El resultado debe de tener una estructura como la siguiente:


| TickerID | TimeStamp           | Price   | Amount     |
|----------|---------------------|---------|------------|
| 12205    | 2015-06-25 17:02:21 | 3736.33 | 0.99375858 |
| 12206    | 2015-06-25 17:06:07 | 3739.43 | 0.38670599 |
| 12207    | 2015-06-25 18:51:46 | 3744.02 | 0.20790000 |

<br>

## ¿Cómo cargar éste código desde R y/o RStudio?

Para cargar éste código remotamente solo es necesario compilar el archivo .R desde la web, esto puede ser efectuado de distintas maneras, una es utilizando la librería de R *downloader*. 

```r
if (!require(downloader)) install.packages('downloader', quiet = TRUE)
suppressMessages(library (downloader)) # basic functions

downloader::source_url("https://raw.githubusercontent.com/FranciscoME/mexbt-data-r/master/meXBTRClient.R",prompt=FALSE,quiet=TRUE)
```
Lo que se está haciendo es dirigirse directamente al código fuente [Aquí](https://raw.githubusercontent.com/FranciscoME/mexbt-data-r/master/meXBTRClient.R) y ejecutar esas líneas dentro de *R*. La ventaja de utilizar *downloader* es que se ejecuta en memoria las funciones y se almacenan en el *Environment* quedando listas para utilizarse. Si todo funciona bien lo siguiente debe de aparecer en la parte de *Environment* en *RStudio*.

![Environment](https://github.com/FranciscoME/mexbt-data-r/blob/master/Functions.png "Loaded Functions ready to use")

<br>
<br>

**FranciscoME**: *Research & Development* - franciscome@mexbt.com
