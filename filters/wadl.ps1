

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
