
## Overview

Tablo is a port of [Matt Harvey's
Tabulo](https://github.com/matt-harvey/tabulo) Ruby gem to the Crystal
Language.

The first version of Tablo (v0.10.1) was released on November 30, 2021,
in the context of learning the Crystal language, which explains its
relative limitations compared to Tabulo v2.7, the current Ruby version
at that time, subject of the software port.

So this version of Tablo (v1.0) is a complete overhaul of the library.

Compared to the first version, it offers extended capabilities,
sometimes at the cost of a modified syntax. It also offers new features,
such as the ability to add a Summary table, powered by user-defined
functions (such as sum, mean, etc.), the ability to process any
Enumerable data, as well as elaborate layout possibilities: grouped
columns, different types of headers (title, subtitle, footer), linked or
detached border lines, etc.

While overall, Tablo remains, in terms of its functionalities, broadly
comparable, with a few exceptions, to the Tabulo v3.0 version of Matt
Harvey, the source code, meanwhile, has been deeply redesigned.

![image](https://github.com/hutou/Test/assets/5678331/9a9e0242-353c-4a98-8b89-b6c416fbedd6)
