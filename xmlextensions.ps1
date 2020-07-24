
$Error.clear()


"filter-generator","xpath","wadl","injections" |ForEach-Object {
    . "$PSScriptRoot/filters/$_.ps1"
} -End {
    . "$PSScriptRoot/Expand-WadlDocument.ps1"
}

<# primitive for testing wadl-generator
& {
    "WADL-GENERATOR: {0}" -F ($wadl | generator ) 
    "UNIQUE representation elements: {0}" -F ($wadl |xpath //@element value |Sort -Unique ).count
} | Write-Host -BackgroundColor DarkGreen
#>



$compare = "14","18" |
ForEach-Object -Parallel { # parallel param is pscore
    $prefix="gw{0}" -F $_
    "filter-generator","xpath","wadl","injections" |
    ForEach-Object {
        . "./filters/$_.ps1"
    } -End {
        . "./Expand-WadlDocument.ps1"
    }
    if(-not ${Function:Expand-WadlDocument}) {throw "Initialize Failed."}
    $app = Expand-WadlDocument "wadl/$prefix"
    @(
        "Analyzing $prefix/application.wadl"
        "WADL-GENERATOR: {0}" -F ($app | Generator)
        "UNIQUE Representation elements: {0}" -F ( $app |xpath //@element value |Sort-Object -Unique ).count
        "TOTAL Methods: {0}" -F ($app |method // ).count
        ""
    ) | Write-Host -BackgroundColor DarkGreen
    ($app |ForEach-Object wadlMethods |
        <# this is where the actual expansion happens #>
        #Where-Object path -eq "domains/{domain}" |
        #Where-Object RequestParams |
        #Where-Object Path -Notmatch '^(messengers|system|list|install)' |
        Sort-Object Path,httpMethod |
        Select-Object `
            Path,
            # httpIdent,
            httpMethod,
            id,
            RequestType,ResponseTypes,
            auto_*|
            #DocText,
            #RequestParams |
            #ResourceParams | 
            #Params |
        Where-Object Path -ne '' |
        ConvertTo-Xml -NoTypeInformation -as String -Depth 2
    ) -replace "  ",'' > "out/$prefix.out.xml"
    "out/$prefix.out.xml"
} # | Receive-Job -Wait
diff -diw ($compare) > out/out.xml.diff
    #diff -diwy --suppress-common-lines --width=180 out/*.out.xml | less


