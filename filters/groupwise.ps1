
## language thing for tpl param matching ?
filter plural  {
    $word = [string]$_
    switch ($word[-1]) {
        "y" {$word.TrimEnd('y')+'ies'}
        "s" {"${word}es"}
        default {"${word}s"}
    }
}

