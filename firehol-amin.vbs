Set objXMLhttp = CreateObject("MSXML2.XMLhttp")
set WshShell = WScript.CreateObject("WScript.Shell")
strDesktop = WshShell.SpecialFolders("Desktop")
With objXMLhttp

'If file already exists, delete the file

Set oFSO = CreateObject("Scripting.FileSystemObject")
If oFSO.FileExists(strDesktop & "\firehol\firehol.rsc") Then oFSO.DeleteFile(strDesktop & "\firehol\firehol.rsc")

'This block gets the malicious ip list from Firehol and translates it to routerOs

 .open "GET", "https://raw.githubusercontent.com/ktsaou/blocklist-ipsets/master/firehol_level1.netset", False
  On Error Resume Next
  .send
  If Err.Number <> 0 Then
    Msgbox "XMLhttp error " & Hex(Err.Number) & " " & Err.Description
  ElseIf .status <> 200 Then
    MsgBox "http error " & CStr(.status) & " " & .statusText
  Else
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set objTS = objFSO.CreateTextFile(strDesktop & "\firehol\firehol.rsc", FSO_OVERWRITE)
    objTS.Write Replace("/ip firewall address-list", vblf, vbNewLine)
    objTS.Write Replace(vblf&.responseText, vblf, vbNewLine&" add list=firehol comment=firehol address=")
    objTS.Close
    Set objTS = Nothing
    Set objFSO = Nothing
  End If

'End of GET block. Remove all comments

Const ForReading = 1
Const ForWriting = 2

set WshShell = WScript.CreateObject("WScript.Shell")
strDesktop = WshShell.SpecialFolders("Desktop")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objTextFile = objFSO.OpenTextFile(strDesktop & "\firehol\firehol.rsc", ForReading)

Do Until objTextFile.AtEndOfStream
    strLine = objTextFile.ReadLine
    intFailure = InStr(strLine, "#")
    If intFailure > 0 Then
        strNewText = strNewText & strLine & vbCrLf
    Else
        strOtherNewText = strOtherNewText & strLine & vbCrLf
    End If
Loop

objTextFile.Close
Set objTextFile = objFSO.OpenTextFile(strDesktop & "\firehol\firehol.rsc", ForWriting, True)
objTextFile.Write(strOtherNewText)
objTextFile.Close

'Delete Last Line

Set objFile = objFSO.OpenTextFile(strDesktop & "\firehol\firehol.rsc", ForReading)


strContents = objFile.ReadAll

objFile.Close


arrLines = Split(strContents, vbCrLf)


Set objFile = objFSO.OpenTextFile(strDesktop & "\firehol\firehol.rsc", ForWriting)

For i = 0 to UBound(arrLines) -2

    objFile.WriteLine arrLines(i)

Next


objFile.Close
End With
Set objXMLhttp = Nothing
WScript.Quit()