
function Expand-WadlDocument {[CmdletBinding()]
    param($prefix='.')

$wadl = ([xml](
    Get-Content "$prefix/application.wadl" -Raw -ea Stop
    )).DocumentElement

$wadl | add-prop PathPrefix { $prefix }

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
    $this | method // |ForEach-Object {
        $_ | Add-Member -TypeName wadlMethod
        #$_ | add-prop Path { $this|path } 
        $_ | Add-Member Path -NotePropertyValue ($_|path)
        $_ | add-prop httpMethod { $this.name }
        $_ | add-prop DocText { $this | docText }
        
        $_ | add-prop RequestType {@(
            $this| representation -scope wadl:request/ -attr element |
                Sort-Object -Unique )}
        $_ | add-prop ResponseTypes {@(
            $this| representation -scope wadl:response/ -attr element |
                Sort-Object -Unique )}

        $_ | add-prop RequestParams {@(
            $this|param -scope wadl:request/ |
                Sort-Object name |
                add-prop -Passthru placeholder { '?{0}' -F $this.name } |
                Select-Object placeholder,name,style  # ,@{N='DocText';E={$_|docText}}
            )}
        $_ | add-prop ResourceParams {@(
            $this|param -scope ../ |ForEach-Object {
                $_ | add-prop placeholder { "{{{0}}}" -F $this.name }
                $_ | add-prop pathOffset { ($this | path).indexOf("{0}" -F $this.placeholder ) }
                $_ } |
                    Sort-Object pathOffset |
                    Select-Object name, style, placeholder  #,@{N='DocText';E={$_|docText}}
                )}
        $_ | add-prop Params {@(
                $this.ResourceParams
                $this.RequestParams
            )|ForEach-Object placeholder}
        $_ | add-prop StatusCodes {@(
            $this | response -having '@status' |
                Select-Object status ,@{N='DocText';E={$_|docText}}
            )}

        # anylysis
        $_ | add-prop idName { $this |xpath '@id' -attr value }
        $_ | add-prop httpIdent { "$($this.path) ::$($this.httpMethod)" }
        $_ | add-prop auto_verb {
            if($this.httpMethod -eq 'put' -and $this.path -like '*}' ) {"update"} ## update
            if($this.httpMethod -eq 'put' -and $this.path -notlike '*}' ) {"set"} ## update
            if($this.httpMethod -eq 'post' -and $this.path -notlike '*}' ) {"create" } ## create
            if($this.httpMethod -eq 'delete') {"delete"} ## delete|remove
            if($this.httpMethod -eq 'get' -and $this.path -like '*}' ) { 'object' } # object > get
            if($this.httpMethod -eq 'get' -and $this.path -notlike '*}' ) { 'list' } 
        }
        $_ | add-prop auto_noun {
            
            #".. auto_noun: {0}" -F $p | Write-Host

            $this.path|splitResourcePath|Where-Object {"$_" -ne '' } | Select-Object -last 1| xpArgName
        }
        ## add method signature prop conatining elements, httpmethod, uri (and request params)
        #>
        $_
    }
} # end wadlMethods


#$wadl|Add-Member -TypeName wadlApplication

$wadl  #<<< return!! 

} 
