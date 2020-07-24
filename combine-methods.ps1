

$compare = "14","18" |
ForEach-Object <#-Parallel#> { # parallel param is pscore
    . ./init.ps1    
    $prefix="gw{0}" -F $_
    Expand-WadlDocument "wadl/$prefix"
}

#$compare | Group-Object {$_.httpIdent}
# @($compare|doctext)


Function Find-Property {
    [cmdletbinding()]
    param($ReferenceObject,$DifferenceObject,$Property)
        (Compare-Object @PSBoundParameters -IncludeEqual).$Property
    }
    
    


$compare.wadlMethods|
Select-Object path,name,@{N='wadlMethod';E={$_}}|
Group-Object {$_.path,$_.name -join ' :: '}|
Where-Object Count -eq 2 |% {
    $variants = $_.group.wadlMethod|
        Select-Object idName,
            RequestType,
            ResponseTypes,
            docText,
            @{N='RequestParams';E={$_.RequestParams.Placeholder|? {$_-ne $null}}}
    #Compare-Object @variants -Property id
    #Compare-Object @variants -Property RequestType
    #(Compare-Object @variants -Property RequestType).RequestType
    $_|Select-Object `
    @{N='httpID';E={$_.Name}}, # group name
    @{N='path';E={$_.group[0].path}}, # resource path
    @{N='method';E={$_.group[0].Name}}, # method name
    @{N='RequestType';E={
        (Find-Property @variants -Property RequestType)
    }},
    @{N='ResponseType';E={
        (Find-Property @variants -Property ResponseTypes)
    }},
    @{N='IDName';E={
        (Find-Property @variants -Property idName)
    }},
    @{N='Query';E={
        (Find-Property @variants -Property RequestParams)
    }} # ,   # <<<< COMMMA!
    <#
    @{N='Doc';E={ ## some bad line feeds in gw14 wadl
        (Find-Property @variants -Property docText)
    }}
    #>
} | Format-List > out/convergence.txt