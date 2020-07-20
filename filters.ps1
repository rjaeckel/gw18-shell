
# xpath helpers


#     $x| value
# vs. $x| % value
# vs. $x| Foreach-Object value
#
# not used currently

#filter value { $_.Value } 

# injects an XmlNamespaceManager in the Document of an xml node
filter namespaceManager ([hashtable]$ns){
    $doc = $_.OwnerDocument
    #"update mgr: $($ns.Keys)"|Write-Host 
    $mgr = [System.Xml.XmlNamespaceManager]::new($doc.NameTable)
    # we cound inspect the doc for ns prefixes here...

    $ns.Keys|% { "$_" -ne "" -and $mgr.AddNamespace( $_,$ns.$_ ) } -ea Continue >$null
    $doc|Add-Member -NotePropertyName NsMgr $mgr
    #return $mgr -as [System.Xml.XmlNamespaceManager]
}

# 
filter xpath ($expr,[string]$attr) {
    ($_ -is [System.Xml.XPath.IXPathNavigable]) -or (&{throw "Invalid Input"}) >$null
    #"& $($MyInvocation.MyCommand) '$expr' '$attr'" | Write-Host -BackgroundColor DarkGray
    $mgr = [System.Xml.XmlNamespaceManager]$_.OwnerDocument.NsMgr
    try {
        if($attr) {
            $_|% SelectNodes $expr $mgr -ea stop |% $attr
        } else {
            $_|% SelectNodes $expr $mgr -ea Stop
        }
    } catch {
        $_.Exception.Message,$expr,$mgr|Write-Host -BackgroundColor Red

    }
}


. "$PSScriptRoot/filter-generator.ps1"
# create filters matching wadl spec
. (mk_xpathElementFilter resource path)
. (mk_xpathElementFilter param style name)
. (mk_xpathElementFilter method name id)
. (mk_xpathElementFilter response status)
. (mk_xpathElementFilter representation element mediaType)
. (mk_xpathElementFilter doc xml:Lang)
. (mk_xpathElementFilter include href )



filter generator {$_ | xpath "//@*[local-name()='generatedBy']" value }


filter docText ($scope="",$prefLang="en"){ ### !! vs above , $lang param
    #"& doctext",$scope,$prefLang | Write-Host -BackgroundColor Black
    @(&{
        $_|doc -xmllang $prefLang -attr innertext
        $_|doc -attr innertext
    })[0]
}

filter path { # as wadl resources may be nested expect the path to be too 
    ($_|xpath ancestor-or-self::*/@path value) -join '/'
}


# added for method naming analysis

filter add-prop { $_ | Add-Member -MemberType ScriptProperty @args }
#filter add-method { $_ | Add-Member -MemberType ScriptMethod @args }


## language thing for tpl param matching ?
filter plural  {
    $word = [string]$_
    switch ($word[-1]) {
        "y" {$word.TrimEnd('y')+'ies'}
        "s" {"${word}es"}
        default {"${word}s"}
    }
}

