#!/bin/bash

free -m | jq -sR '[sub("\n$";"") 
| splits("\n") 
| sub("^ +";"") 
| [splits(" +")]] 
| .[0] as $header 
| .[1:] | [.[] 
  | [. as $x | range($header | length-1) | {"key": $header[.], "value": $x[.+1]}] | from_entries]'
