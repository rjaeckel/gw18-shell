


. "$PSScriptRoot\filters.ps1"


<# primitive for testing wadl-generator
& {
    "WADL-GENERATOR: {0}" -F ($wadl | generator ) 
    "UNIQUE representation elements: {0}" -F ($wadl |xpath //@element value |Sort -Unique ).count
} | Write-Host -BackgroundColor DarkGreen
#>



function Expand-WadlApplication($prefix) {

$wadl = ([xml](Get-Content "$PSScriptroot/$prefix.wadl" -Raw -ea Stop)).DocumentElement # | xpath 

$wadl | namespaceManager -ns @{
    'wadl'='http://wadl.dev.java.net/2009/02'
    'xs'='http://www.w3.org/2001/XMLSchema'
} > $null


$wadl | add-prop Generator { $this | generator }
$wadl | add-prop Params {@(
    $this | param -scope // |
        Select-Object name,style,@{N='DocText';E={$_|docText}} |
        Sort-Object -Unique -Property style,name,doc
    )}
$wadl | add-prop IncludedGrammars {
    @($this | include -scope wadl:grammars/ -attr href)
}#> 


$wadl | add-prop wadlMethods {
    $this | method // |% {

        $_ | add-prop Path {$this|path}
        $_ | add-prop httpMethod {$this.name}
        #$_ | add-prop id {$this.id}
        $_ | add-prop DocText { $this | docText }
        
        $_ | add-prop RequestType {@(
            $this| representation -scope wadl:request/ -attr element |
                Sort-Object -Unique )}
        $_ | add-prop ResponseTypes {@(
            $this| representation -scope wadl:response/ -attr element |
                Sort-Object -Unique )}
        $_ | add-prop RequestParams {@(
            $this|param -scope wadl:request/ |
                Select-Object name, style # ,@{N='DocText';E={$_|docText}}
            )}
        $_ | add-prop ResourceParams {@(
            $this|param -scope ../ |% {
                $_ | add-prop placeholder { "{{{0}}}" -F $_.Name }
                $_ | add-prop pathOffset { ($this | path).indexOf("{0}" -F $_.placeholder ) }
                $_ }|
                Sort-Object pathOffset |
                Select-Object name, style #,@{N='DocText';E={$_|docText}}
            )}
        $_ | add-prop Params {@(
                $this.ResourceParams
                $this.RequestParams
            )}
        $_ | add-prop StatusCodes {
            $this | response -having '@status' |
                Select-Object status ,@{N='DocText';E={$_|docText}}
        }
        $_ | add-prop httpIdent { "$($this.path) ::$($this.httpMethod)"
        }
        $_|add-prop auto_verb {
            if($this.httpMethod -eq 'put' -and $this.path -like '*}' ) {"update"} ## update
            if($this.httpMethod -eq 'put' -and $this.path -notlike '*}' ) {"set"} ## update
            if($this.httpMethod -eq 'post' -and $this.path -notlike '*}' ) {"create" } ## create
            if($this.httpMethod -eq 'delete') {"delete"} ## delete
            if($this.httpMethod -eq 'get' -and $this.path -like '*}' ) { 'object' } # object > get
            if($this.httpMethod -eq 'get' -and $this.path -notlike '*}' ) { 'list' } 
        }
        #>
        $_
    }
} # end wadlMethods
$wadl

} # end expand

"18","14" |% {

    $prefix="gw{0}.application" -F $_

(Expand-WadlApplication "xml/$prefix" |% wadlMethods  |
    #Where-Object path -eq "domains/{domain}" |
    #Where-Object RequestParams |
    Where-Object path -Notmatch '^(messengers|system|list|install)' |
    Sort-Object Path,httpMethod |
    Select-Object `
        httpIdent,
        #httpMethod,Path
        id,
        #DocText,
        RequestType,ResponseTypes ,
        #RequestParams,ResourceParams | 
        Params |
    ConvertTo-Xml -NoTypeInformation -as String -Depth 2
) -replace "  ",'' > "$PSScriptRoot/out/$prefix.out.xml"
    "out/$prefix.out.xml"
} -End {
    diff -diw out/*application.out.xml > out/out.xml.diff
    diff -diwy --suppress-common-lines --width=180 out/*.out.xml | less
}