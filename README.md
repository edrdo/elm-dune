# Elm interface with DUNE

This repository illustrates the use of Elm to interface with DUNE to get IMC messages encoded in JSON format.

It relies on a modified version of DUNE's `Transports.HTTP` task.

## Compiling the Elm code

```
elm make src/Main.elm
```

This will generate an `index.html` file that you can open in a browser.

## DUNE

Get the code (note that the branch is `http_transport_changes`)

``` 
git clone -b http_transport_changes git@github.com:edrdo/dune.git
```

Then compile it as usual, e.g.:

```
cd dune
mkdir build; cd build
cmake ..; make -j8
``` 

There is a `lauv-xplore-1-alt` configuration that you can use;
others will work too but this one will send more interesting messages to the Elm module. 

```
./dune -c lauv-xplore-1-alt -p Simulation
``` 

