

New-Alias -Force namespaceManager -Value Add-Namespacemanager
New-Alias -Force xpath -Value Invoke-XPathExpression
# injects an XmlNamespaceManager in the Document of an xml node
filter Add-NamespaceManager ([hashtable]$ns){
    $doc = $_.OwnerDocument
    #"update mgr: $($ns.Keys)"|Write-Host 
    $mgr = [System.Xml.XmlNamespaceManager]::new($doc.NameTable)
    # we cound inspect the doc for ns prefixes here...

    $ns.Keys|% { "$_" -ne "" -and $mgr.AddNamespace( $_,$ns.$_ ) } -ea Continue >$null
    $doc|Add-Member -NotePropertyName NsMgr $mgr
    #return $mgr -as [System.Xml.XmlNamespaceManager]
}
# 
filter Invoke-XPathExpression ($expr,[string]$attr) {
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