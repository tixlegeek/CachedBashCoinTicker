# CachedBashCoinTicker
A simple script allowing to get crypto coins and precious metal prices without flooding free **APIs**

This is more a helper than a tool. The code is commented so you can reuse it inside your own code.

You need `jq` and `curl` to use this.

## Functions

### ```cacheRequest``` caches a request.

```bash
cacheRequest $PREFIX $URL
```

**PREFIX** is a string allowing to swiftly identifying cache files.



### ```cryptoRequest``` makes a request to cryptocompare.

```bash
cryptoRequest $CRYPTO
```
**CRYPTO** is the name of the crypto for which you wish to request the price.



### ```MetalRequest``` makes a request to metalpriceapi.

```bash
MetalRequest $PREFIX
```

**PREFIX** is passed to the cacheRequest function

## Example 

```
₿;	50126,210 €;	 54745.65$
Ɱ;	139,750 €;	 153.05$
Ð;	0,088 €;	 0.09651$
Ξ;	2271,370 €;	 2483.36$
🜚;	26,153 €;	 -$
🜛g;	71,916 €;	 -$
