[CmdletBinding()]param()

$Error.Clear()

"filter-generator","xpath","wadl","injections" |ForEach-Object {
    . "$PSScriptRoot/filters/$_.ps1"
} -End {
    . "$PSScriptRoot/Expand-WadlDocument.ps1"
}

if(-not ${Function:Expand-WadlDocument}) {throw "Initialize Failed."}
