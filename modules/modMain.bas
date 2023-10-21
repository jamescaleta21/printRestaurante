Attribute VB_Name = "modMain"

Public Cnn      As New ADODB.Connection
Public VReporte As New CRAXDRT.Report
Public oCmdEjec As New ADODB.Command

Public Sub LimpiaParametros(oCmd As ADODB.Command)
    oCmd.ActiveConnection = Cnn
    oCmd.CommandType = adCmdStoredProc
    Cnn.CursorLocation = adUseClient

    For i = oCmd.Parameters.Count - 1 To 0 Step -1
        oCmd.Parameters.Delete i
    Next

End Sub
