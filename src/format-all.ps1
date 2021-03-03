$vfiles = Get-ChildItem -Path ./*.v
foreach ($vfile in $vfiles) {
    (iStyle --style=kr -p $vfile)
    Remove-Item -Path ($vfile.ToString() + ".orig")
}