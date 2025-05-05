Agner
-----

A suite of tools, drivers and scripts for investigating the performance of x86 CPUs.

Based very heavily on [Agner Fog](http://www.agner.org)'s [test programs](http://www.agner.org/optimize/#testp).

# developer's notes

* if `make` fails to build module, ensure you have `linux-headers-amd64`, or
  its equivalent for your system, installed.
* python3.11 and before used the `imp` package for `load_source`. python3.12
  and up use `importlib` from the `python3-importlib-resources` package, but
  this project needs to be edited to work with it.
