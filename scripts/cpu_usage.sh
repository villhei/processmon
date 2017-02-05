#!/bin/sh

mpstat -P ALL | {
  jq -sR '[sub("\n$";"") 
            | splits("\n") 
            | sub("^ +";"") 
            | [splits(" +")]
            ] 
              | .[2] as $header 
              | .[3:]
              | [.[] 
                | [. as $x 
                  | range(1; $header | length - 1) 
                  | {"key": $header[.], "value": $x[.]}] | from_entries]'
}