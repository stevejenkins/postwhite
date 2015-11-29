This testdata directory contains the following files:

* **unsorted.txt** - an example of "raw" output from Postwhite that has not been sorted or uniqued

* **sort-n.txt** - original data sorted using ```sort -n```

* **sort-V.txt** - original data sorted using ```sort -V```

* **sort-u.txt** - original data sorted using ```sort -u```

* **sort-uV.txt** - original data sorted using ```sort -u -V```

* **sort-un.txt** - original data sorted using ```sort -u -n```

* **sort-untk.txt** - original data sorted using ```sort -u -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4```

Note that only the data sorted with ```-u``` and ```-u -V``` resulted in unique rules without any data loss. All other unique sorts resulted in valid whitelist rules being removed from the unsorted data.

However, because the ```-V``` sort option is not available on all platforms, I did not include it as the default option in Postwhite.

Please feel free to experiment with this data, and if you have a suggestion for a better sort option than simply ```sort -u```, please let me know.
