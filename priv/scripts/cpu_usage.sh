#!/bin/sh

count=$(nproc)
take_lines=$(echo $count + 4 | bc)

mpstat 1 1 -P ALL | head -$take_lines| {
  jq -sR '[sub("\n$";"") 
            | splits("\n") 
            | sub("^ +";"") 
            | [splits(" +")]
            ] 
              | .[2] as $header 
              | .[3:]
              | [.[] 
                | [. as $x 
                  | range(1; $header | length ) 
                  | {"key": $header[.], "value": $x[.]}] | from_entries]'
}