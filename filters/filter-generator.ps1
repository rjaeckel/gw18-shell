#[CmdletBinding()]param() # by this current script's status ist pushed inside, $DEBUGpreference,$ErrorAction ...


filter xpArgName {
    # regex to create valid param names  from xpath expression
    $sanitize_regex = '[{0}]+:|[^{0}_]'-F 'a-z0-9_'
    ($_ -split $sanitize_regex|ForEach-Object {(Get-Culture).TextInfo.ToTitleCase($_)}) -join ''
}

# creates xpath parameter handler
filter xpArg ([char]$compare='='){ # result ist placed in "" 
    $s_param=$_ | xpArgName
    #"& xpArg: $xp $s_param" | Write-Host -BackgroundColor DarkGray
    'if( {1} ){{ "{0}{2}" }}' -F $_,"`$$s_param","$compare'`$$s_param'" #| ConvertTo-ScriptBlock
}


filter ConvertTo-ScriptBlock {
    [scriptblock]::Create($_)
}
# New-Alias -Name sb -Value ConvertTo-ScriptBlock

function xpFilterScript ([string[]]$exprs) {
    '$filter=(& {'
        ($exprs|xpArg |ForEach-Object {"`t$_"})
        "`t{0}" -F 'if($having) {"$having"}'
    '}) -join " and "'
    '$filterstr = if($filter -ne "") { "[$filter]" }'
}

# element filter generator by attribute
function mk_xpathElementFilter ($elem) {
    $s_args = $args | xpArgName
    $args_str = if($args.Count) { ',${0}' -F ($s_args -join ',$')}
    
    $filterScript = (xpFilterScript $args) -join "`n" # |ConvertTo-ScriptBlock 
    ## end filter str 
    
    $sb = ("FILTER $elem ( [string]`$scope,[string]`$having,`$attr$args_Str ){`n"+
        "$filterScript`n"+
        "`$_|xpath `"`${scope}wadl:${elem}`${filterstr}`" -attr `$attr`n} ")
    
    # debug filterscript
    #"& mkfilter:<$elem> $args ($s_args)" | Write-Host -BackgroundColor DarkGray
    #"& mkfilter: $sb" | Write-Host -BackgroundColor DarkMagenta
    $sb|ConvertTo-ScriptBlock # | Tee-Object -FilePath "$PSScriptRoot/../out/filter.$elem.out.ps1"
    
}

# mk_xpathElementFilter method './/wadl:response/@element'  './/wadl:request/@element' | Write-Debug
