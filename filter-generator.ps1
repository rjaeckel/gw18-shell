
# regex to create valid param names  from xpath expression
# $param_name = $expr -replace $reg,''
$sanitize_regex = '[^a-z0-9_]'

# creates xpath parameter handler
filter xpArg { # result ist placed in "" 
    $s_param=$_ -replace $sanitize_regex,''
    #"& xpArg: $xp $s_param" | Write-Host -BackgroundColor DarkGray
    'if( {1} ){{ "@{0}{2}" }}' -F $_,"`$$s_param","='`$$s_param'" #| ConvertTo-ScriptBlock
}


filter ConvertTo-ScriptBlock {
    [scriptblock]::Create($_)
}
# New-Alias -Name sb -Value ConvertTo-ScriptBlock

function xpFilterScript ([string[]]$exprs) {
    '$filter=(& {'
        ($exprs|xpArg |% {"`t$_"})
        "`t{0}" -F 'if($having) {"$having"}'
    '}) -join " and "'
    '$filterstr = if($filter -ne "") { "[$filter]" }'
}

# element filter generator by attribute
function mk_xpathElementFilter ($elem) {
    $s_args = $args -replace $sanitize_regex,''
    $args_str = if($args.Count) { ',${0}' -F ($s_args -join ',$')}
    
    $filterScript = (xpFilterScript $args) -join "`n" # |ConvertTo-ScriptBlock 
    ## end filter str 
    
    $sb = ("FILTER $elem ( [string]`$scope,[string]`$having,[string]`$attr$args_Str ){`n"+
        "$filterScript"+
        "`$_|xpath `"`${scope}wadl:${elem}`${filterstr}`" -attr `$attr } ")
    
    # debug filterscript
    #"& mkfilter:<$elem> $args ($s_args)" | Write-Host -BackgroundColor DarkGray
    #"& mkfilter: $sb" | Write-Host -BackgroundColor DarkMagenta
    $sb|ConvertTo-ScriptBlock
    
}


