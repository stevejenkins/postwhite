This testdata directory contains the following files:

* **unsorted.txt** - an example of "raw" output from Postwhite that has not been sorted or uniqued

* **sort-n.txt** - original data sorted using ```sort -n```

* **sort-V.txt** - original data sorted using ```sort -V```

* **sort-u.txt** - original data sorted using ```sort -u```

* **sort-uV.txt** - original data sorted using ```sort -u -V```

* **sort-un.txt** - original data sorted using ```sort -u -n```

* **sort-untk.txt** - original data sorted using ```sort -u -n -t. -k 1,1 -k 2,2 -k 3,3 -k 4,4```

* **sort-tkn.txt** - original data sorted using ```sort -t. -k1,1n -k2,2n -k3,3n -k4,4n```

* **sort-tkn-uniq.txt** - output of ```uniq sort-tkn.txt```. This is Postwhite's current approach to sorting and unique-ing as of v1.16.

Note that only the data sorted with ```-u``` and ```-u -V``` resulted in unique rules without any data loss. All other unique sorts combining ```-u``` with ```-n-```  resulted in valid whitelist rules being removed from the unsorted data.

Using ```sort -V``` would be ideal, but the ```-V``` sort option is not available on all platforms, so I did not include it as the default option in Postwhite.

Please feel free to experiment with this data, and if you have a suggestion for a better sort option, I'm all ears! :)
