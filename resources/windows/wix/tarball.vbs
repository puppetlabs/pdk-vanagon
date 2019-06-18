On Error Resume Next

' This VBScript file is imported into the Binary table

' Example INSTALLDIR property. Its value is 'C:\Program Files\Puppet Labs\DevelopmentKit\'.
' As this is deferred, use the CustomActionData property instead
Dim InstallDir : InstallDir = Session.Property("CustomActionData")

' https://docs.microsoft.com/en-us/windows/desktop/msi/session-message
Const msiMessageTypeError   = &H01000000
Const msiMessageTypeWarning = &H02000000
Const msiMessageTypeInfo    = &H04000000

' https://docs.microsoft.com/en-us/windows/desktop/msi/return-values-of-jscript-and-vbscript-custom-actions
Const IDOK = 1
Const IDABORT = 3

Dim wshShell : Set wshShell = CreateObject("WScript.Shell")
Dim fso : Set fso = CreateObject("Scripting.FileSystemObject")

Sub Log (Message, IsError)
  ' Logs through cscript
  If IsObject(WScript) Then
    If IsObject(WScript.StdErr) And IsError = True Then
      WScript.StdErr.WriteLine(Message)
    ElseIf IsObject(WScript.StdOut) Then
      WScript.StdOut.WriteLine(Message)
    End If
  End If
  ' Logs through MSI
  If IsObject(Session) Then
    ' https://docs.microsoft.com/en-us/windows/desktop/msi/installer-createrecord
    Dim logRecord : Set logRecord = Installer.CreateRecord(1) ' 1 entry
    logRecord.StringData(1) = Message ' Set Index 1
    Dim kind : kind = msiMessageTypeInfo
    If IsError = True Then kind = msiMessageTypeError
    Session.Message kind, logRecord
  End If
End Sub

' Executes command, sending its stdout / stderr to the WScript host
Function ExecuteCommand (Command)
  Dim output: output = ""
  Log "Executing Command : " & Command, False

  Dim tempFilePath : tempFilePath = wshShell.ExpandEnvironmentStrings("%TEMP%\" + fso.GetTempName())
  ' https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/d5fk67ky%28v%3dvs.84%29
  ' intWindows Style - 0 - Hides the window and activates another window.
  ' bWaitOnReturn - True - waits for program termination
  Dim exitCode : exitCode = wshShell.Run(Command & " > """ & tempFilePath & """ 2>&1", 0, True)
  Dim outFile : Set outFile = fso.OpenTextFile(tempFilePath)
  Do While Not outFile.AtEndOfStream
   Log outFile.ReadLine(), false
  Loop
  outFile.Close()
  fso.DeleteFile(tempFilePath)

  If exitCode <> 0 Then
    Log "Execution Failed With Code: " & exitCode, True
    ExecuteCommand = False
  else
    ExecuteCommand = True
  End If
End Function

Function GetRubyDirectory(RootDirectory)
  GetRubyDirectory = ""
  ' Find a ruby environment with the PDK gem
  Dim RubyFolder : Set RubyFolder = fso.GetFolder(RootDirectory)
  For Each RubyVerSubfolder in RubyFolder.SubFolders
    Dim RubyFullVersion : RubyFullVersion = RubyVerSubfolder.Name
    Dim arrRubyVersion : arrRubyVersion = Split(RubyFullVersion, ".")
    Dim RubyMinorVersion : RubyMinorVersion = arrRubyVersion(0) + "." + arrRubyVersion(1) + ".0"
    Dim GemFolderPath : GemFolderPath = RubyVerSubfolder.Path + "\lib\ruby\gems\" + RubyMinorVersion + "\gems"

    if fso.FolderExists(GemFolderPath) Then
      Dim FoundPDK : FoundPDK = false
      For Each GemFolder in fso.GetFolder(GemFolderPath).SubFolders
        FoundPDK = FoundPDK OR Left(GemFolder.Name,4) = "pdk-"
      Next
      If FoundPDK Then
        GetRubyDirectory = RubyFullVersion
      End If
    End If
  Next
End Function

' Mainline
Function ExtractTarballs()
  Log "InstallDir is " + InstallDir, false

  ' Based on equivalent PowerShell script at;
  ' https://github.com/puppetlabs/pdk-vanagon/blob/07a4ee7c29ba630ffbec6d87388688b6de90fbfd/resources/files/windows/PuppetDevelopmentKit/PuppetDevelopmentKit.psm1
  Dim DEVKIT_BASEDIR
  Dim RUBY_DIR
  Dim SSL_CERT_FILE
  Dim SSL_CERT_DIR

  DEVKIT_BASEDIR = fso.GetFolder(InstallDir).ShortPath

  Log "DEVKIT_BASEDIR is " + DEVKIT_BASEDIR, false

  Dim RubyVersion : RubyVersion = GetRubyDirectory(DEVKIT_BASEDIR + "\private\ruby")
  If RubyVersion = "" Then
    Log "Could not find a suitable ruby environment", true
    ExtractTarballs = IDABORT
    Exit Function
  Else
    Log "Ruby " + RubyVersion + " has the PDK gem", false
  End If
  RUBY_DIR = DEVKIT_BASEDIR + "\private\ruby\" + RubyVersion

  SSL_CERT_FILE = DEVKIT_BASEDIR + "\ssl\cert.pem"

  SSL_CERT_DIR = DEVKIT_BASEDIR + "\ssl\certs"

  Log "DEVKIT_BASEDIR is " + DEVKIT_BASEDIR, false
  Log "RUBY_DIR is " + RUBY_DIR, false
  Log "SSL_CERT_FILE is " + SSL_CERT_FILE, false
  Log "SSL_CERT_DIR is " + SSL_CERT_DIR, false

  Dim RubyPath : RubyPath = RUBY_DIR + "\bin\ruby.exe"
  Dim comspec : comspec = wshShell.ExpandEnvironmentStrings("%comspec%")
  Dim ProcessEnv : Set ProcessEnv = wshShell.Environment( "PROCESS" )

  Log "Creating process level environment variables...", false
  ProcessEnv("DEVKIT_BASEDIR") = DEVKIT_BASEDIR
  ProcessEnv("RUBY_DIR") = RUBY_DIR
  ProcessEnv("SSL_CERT_FILE") = SSL_CERT_FILE
  ProcessEnv("SSL_CERT_DIR") = SSL_CERT_DIR
  ProcessEnv("PDK_DEBUG") = "True"

  Dim ExtractScript : ExtractScript = DEVKIT_BASEDIR + "\share\install-tarballs\extract_all.rb"
  If Not(fso.FileExists(ExtractScript)) Then
    Log "Extract script " & ExtractScript & " could not be found", true
    ExtractTarballs = IDABORT
    Exit Function
  End If

  ' Note Returning values back to the MSI Engine only works with Binary type Custom Actions
  if ExecuteCommand(comspec & " /C " & RubyPath & " -S -- " & ExtractScript) Then
    Log "Completed with success", false
    ExtractTarballs = IDOK
  Else
    Log "Completed with error", true
    ExtractTarballs = IDABORT
  End If
End Function
