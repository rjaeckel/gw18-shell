

# create filters matching wadl spec
. (mk_xpathElementFilter resource '@path')
. (mk_xpathElementFilter param style '@name','@type')
. (mk_xpathElementFilter method '@name' '@id')
. (mk_xpathElementFilter response '@status')
. (mk_xpathElementFilter representation '@element' '@mediaType')
. (mk_xpathElementFilter doc '@xml:lang')
. (mk_xpathElementFilter include '@href')



filter generator {$_ | xpath "//@*[local-name()='generatedBy']" value }

filter docText ($scope="",$prefLang="en"){ ### !! vs above , $lang param
    #"& doctext",$scope,$prefLang | Write-Host -BackgroundColor Black
    @(&{
        $_|doc -lang $prefLang -attr innertext
        $_|doc -attr innertext
    })[0]
}

filter path { # wadl resources may be nested, so expect the path to be too 
    ($_|xpath ancestor-or-self::*/@path value) -join '/'
}


# "list/{type}/{base}"
# "list/{type}.csv/{base}"
# "system/customaddresses/{customAddress}"
# "system/directorylinks/publish"
# "domains/{domain}/customaddresses/test"
# "domains/{domain}/gwias/{gwia}/administrators"

filter splitResourcePath ($nameExpr='({\w+})'){
    $_ -split "$nameExpr" |Where-Object {$_ -ne $null}
}
