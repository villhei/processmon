#!/bin/bash

ps -aux | jq -sR '[sub("\n$";"") | splits("\n") | sub("^ +";"") | [splits(" +")]] | .[0] as $header | .[1:] | [.[] | [. as $x | range($header | length) | {"key": $header[.], "value": $x[.]}] | from_entries]'
