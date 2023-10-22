VERSION 5.00
Begin VB.Form frmPrint 
   Caption         =   "Impresión en Background"
   ClientHeight    =   1860
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4740
   BeginProperty Font 
      Name            =   "Tahoma"
      Size            =   8.25
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   Icon            =   "frmPrint.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   1860
   ScaleWidth      =   4740
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command1 
      Caption         =   "Imprimir"
      Height          =   360
      Left            =   1920
      TabIndex        =   0
      Top             =   600
      Width           =   990
   End
   Begin VB.Timer Timer1 
      Interval        =   2000
      Left            =   3600
      Top             =   840
   End
   Begin VB.Menu mnupopup 
      Caption         =   "popup"
      Visible         =   0   'False
      Begin VB.Menu mnurestaurar 
         Caption         =   "Restaurar"
      End
      Begin VB.Menu mnulinea 
         Caption         =   "-"
      End
      Begin VB.Menu mnusalir 
         Caption         =   "Salir"
      End
   End
End
Attribute VB_Name = "frmPrint"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'* --------------------+----------------------------------------------------------------------------------------------------------------------------
'* BITACORA DE CAMBIOS |
'* --------------------+----------------------------------------------------------------------------------------------------------------------------
'* CODIGO       FECHA       RESPONSABLE         MOTIVO
'* -------------------------------------------------------------------------------------------------------------------------------------------------
'* (@#)1-A      21/10/2023  JMENDOZA            ENVIAR PRECUENTA A IMPRESIÓN
'* (@#)2-A      22/10/2023  JMENDOZA            LEER VARIABLE CODCIA DESDE INI Y ESCRIBIR LOG DE ERROR
'* -------------------------------------------------------------------------------------------------------------------------------------------------

Option Explicit

' -- Api SetForegroundWindow Para traer la ventana al frente
Private Declare Function SetForegroundWindow Lib "user32" (ByVal hWnd As Long) As Long
' -- Api para desplegar el cuadro de diálogo Acerca de ...
Private Declare Function ShellAbout Lib "shell32.dll" Alias "ShellAboutA" (ByVal hWnd As Long, ByVal szApp As String, ByVal szOtherStuff As String, ByVal hIcon As Long) As Long

' -- Estructura NOTIFYICONDATA
Private Type NOTIFYICONDATA
    cbSize As Long
    hWnd As Long
    uId As Long
    uFlags As Long
    ucallbackMessage As Long
    hIcon As Long
    szTip As String * 64
End Type

' -- Constantes para las acciones
Private Const NIM_ADD = &H0
Private Const NIM_MODIFY = &H1
Private Const NIM_DELETE = &H2
Private Const NIF_MESSAGE = &H1
Private Const NIF_ICON = &H2
Private Const NIF_TIP = &H4

' -- Constantes para los botones y le mouse (mensajes)
Private Const WM_MOUSEMOVE = &H200
Private Const WM_LBUTTONDOWN = &H201
Private Const WM_LBUTTONUP = &H202
Private Const WM_LBUTTONDBLCLK = &H203
Private Const WM_RBUTTONDOWN = &H204
Private Const WM_RBUTTONUP = &H205
Private Const WM_RBUTTONDBLCLK = &H206

' -- Función Api Shell_NotifyIcon
Private Declare Function Shell_NotifyIcon Lib "shell32" Alias "Shell_NotifyIconA" (ByVal dwMessage As Long, pnid As NOTIFYICONDATA) As Boolean

' -- variables para la estructura NOTIFYICONDATA
Dim systray As NOTIFYICONDATA
'CONEXION
'(@#)1-A inicio
'Const strCnn As String = "dsn=dsn_datos;uid=sa;pwd=accesodenegado$1;database=DBSRVRESTAURANT;"
Private strCnn As String
Private c_Server As String
Private c_DataBase As String
Private c_Usr As String
Private c_Pwd As String
'(@#)1-A fin
Private c_CodCia As String      '(@#)2-A


Private Sub RemoverSystray()
    Shell_NotifyIcon NIM_DELETE, systray
End Sub

Private Sub PonerSystray()
    
    With systray
        ' -- Tamaño de la estructura systray
        .cbSize = Len(systray)
        ' -- Establecemos el Hwnd, en este caso del formulario
        .hWnd = Me.hWnd

        .uId = vbNull
        ' -- Flags
        .uFlags = NIF_ICON Or NIF_TIP Or NIF_MESSAGE
        ' -- Establecemos el mensaje callback
        .ucallbackMessage = WM_MOUSEMOVE
        ' -- establecemos el icono, en este caso el que tiene el form, puede ser otro
        .hIcon = Me.Icon
        ' -- Establecemos el tooltiptext
        .szTip = Me.Caption & vbNullChar
        ' -- Ponemos el icono en el systray
        Shell_NotifyIcon NIM_ADD, systray
    End With

End Sub

Private Sub Command1_Click()
Imprimir
   
End Sub

Private Sub Form_Load()
    '(@#)1-A inicio
    CargarVariablesConexion
    'Cnn.Open strCnn
    '(@#)1-A fin
    Me.Hide
    PonerSystray
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Dim msg As Long

    If (Me.ScaleMode = vbPixels) Then
        msg = X
    Else
        msg = X / Screen.TwipsPerPixelX
    End If

    Select Case msg
        Case WM_LBUTTONDBLCLK
            ' -- Si hacemos doble click con el botón izquierdo restauramos el form
            Me.WindowState = vbNormal
            Call SetForegroundWindow(Me.hWnd)
            Me.Show

        Case WM_RBUTTONUP
            Call SetForegroundWindow(Me.hWnd)
            ' -- Si hacemos Click con el boton derecho mostramos el popup Menu
            Me.PopupMenu Me.mnupopup

        Case WM_LBUTTONUP
    End Select
End Sub

Private Sub Form_Unload(Cancel As Integer)
Cnn.Close
 RemoverSystray
End Sub

Private Sub mnurestaurar_Click()
  Me.WindowState = vbNormal
    Call SetForegroundWindow(Me.hWnd)
    Me.Show
End Sub

Private Sub mnusalir_Click()
  If MsgBox("¿ Salir ?", vbOKCancel + vbQuestion) = vbOK Then Unload Me
End Sub

Private Sub Imprimir()

    On Error GoTo xImprimir '(@#)2-A

    Dim orsMain  As ADODB.Recordset

    Dim orsFam   As ADODB.Recordset

    Dim orsDet   As ADODB.Recordset

    Dim orsFINAL As ADODB.Recordset

    'TRAER LOS DATOS A IMPRIMIR
    oCmdEjec.CommandText = "WEB_COMANDA_DATOSIMPRESION"
    LimpiaParametros oCmdEjec
    
    Set orsMain = oCmdEjec.Execute(, "01")
    Set orsFam = orsMain.NextRecordset
    Set orsDet = orsMain.NextRecordset
    
    Dim crParamDefs As CRAXDRT.ParameterFieldDefinitions

    Dim crParamDef  As CRAXDRT.ParameterFieldDefinition

    Dim objCrystal  As New CRAXDRT.APPLICATION

    Dim RutaReporte As String

    RutaReporte = "C:\Admin\Nordi\Comanda1.rpt"

    Dim orsTMP As ADODB.Recordset

    Set orsTMP = New ADODB.Recordset
    orsTMP.CursorType = adOpenDynamic ' setting cursor type
    orsTMP.Fields.Append "FAMILIA", adVarChar, 100
    'oRSfp.Fields.Append "formapago", adVarChar, 120
    
    orsTMP.Fields.Refresh
    orsTMP.Open

    Dim sFiltro    As String

    Dim i          As Integer

    Dim MyMatriz() As String

    Do While Not orsMain.EOF 'recorriendo los datos principales
        'orsFam.Filter = "IDPRINT=" & orsMain!IDPRINT
            
        Do While Not orsFam.EOF
            MyMatriz = Split(orsFam!Familia, "|")

            For i = LBound(MyMatriz) To UBound(MyMatriz)

                'Le asignamos unos elementos de prueba
                If MyMatriz(i) <> "" Then
                    orsTMP.AddNew
                    orsTMP!Familia = MyMatriz(i)
                    orsTMP.Update

                End If

            Next

            sFiltro = ""
            
            Dim IC As Integer

            If orsTMP.RecordCount <> 0 Then orsTMP.MoveFirst
            IC = 1
            
            Do While Not orsTMP.EOF

                If IC = orsTMP.RecordCount Then
                    sFiltro = sFiltro & "IDFAMILIA=" & orsTMP!Familia
                Else
                    sFiltro = sFiltro & "IDFAMILIA=" & orsTMP!Familia & " OR "

                End If

                IC = IC + 1
                orsTMP.MoveNext
            Loop
            
            orsDet.Filter = "IDPRINT=" & orsMain!IDPRINT & " AND " & sFiltro
            
            Set VReporte = objCrystal.OpenReport(RutaReporte, 1)
            Set crParamDefs = VReporte.ParameterFields

            For Each crParamDef In crParamDefs

                Select Case crParamDef.ParameterFieldName

                    Case "mesa"
                        crParamDef.AddCurrentValue Str(1)

                    Case "Mensaje"
                        crParamDef.AddCurrentValue CStr(orsMain!Mensaje)

                End Select

            Next
                
            LimpiaParametros oCmdEjec
            oCmdEjec.CommandType = adCmdStoredProc
            oCmdEjec.CommandText = "SpPrintComanda2"
            'oCmdEjec.CommandText = "SpPrintComanda"

            Dim vdata As String

            vdata = ""

            Dim vnumsec As String

            vnumsec = ""
                
            Do While Not orsDet.EOF 'RECORRIENDO LOS PLATOS A IMPRIMIR
                vdata = vdata & orsDet!IDPRODUCTO & ","  'IDEPLATO
                vnumsec = vnumsec & orsDet!NUMSEC & "," 'NROSEC
                orsDet.MoveNext
            Loop
            
            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@CodCia", adChar, adParamInput, 2, "01")
            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@NumSer", adChar, adParamInput, 3, orsMain!numser)
            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@NumFac", adDouble, adParamInput, , orsMain!numfac)
            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@xdet", adVarChar, adParamInput, 4000, vdata)
            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@xnumsec", adVarChar, adParamInput, 4000, vnumsec)

            Set orsFINAL = oCmdEjec.Execute

            'Do While Not orsFam.EOF
            ' orsFINAL.Filter = "PED_FAMILIA=" & orsFam!IDFAMILIA
    
            If Not orsFINAL.EOF Then
                VReporte.Database.SetDataSource orsFINAL, 3, 1
                VReporte.SelectPrinter Printer.DriverName, CStr(orsFam!IMPRESORA), Printer.Port
                'VReporte.SelectPrinter Printer.DriverName, "", Printer.Port
                VReporte.PrintOut False, 1, , 1, 1
                
                Set VReporte = Nothing
                Set VReporte = objCrystal.OpenReport(RutaReporte, 1)

                Set crParamDefs = VReporte.ParameterFields

                For Each crParamDef In crParamDefs

                    Select Case crParamDef.ParameterFieldName

                        Case "mesa"
                            crParamDef.AddCurrentValue Str(1)

                        Case "Mensaje"
                            crParamDef.AddCurrentValue CStr(orsMain!Mensaje)

                    End Select

                Next

            End If
            
            If Len(Trim(orsFam!IMPRESORA2)) <> 0 Then
                VReporte.Database.SetDataSource orsFINAL, 3, 1
                VReporte.SelectPrinter Printer.DriverName, CStr(orsFam!IMPRESORA2), Printer.Port
                'VReporte.SelectPrinter Printer.DriverName, "", Printer.Port
                VReporte.PrintOut False, 1, , 1, 1
                
                Set VReporte = Nothing
                Set VReporte = objCrystal.OpenReport(RutaReporte, 1)

                Set crParamDefs = VReporte.ParameterFields

                For Each crParamDef In crParamDefs

                    Select Case crParamDef.ParameterFieldName

                        Case "mesa"
                            crParamDef.AddCurrentValue Str(1)

                        Case "Mensaje"
                            crParamDef.AddCurrentValue CStr(orsMain!Mensaje)

                    End Select

                Next

            End If

            ' orsFam.MoveNext
            ' Loop
            If Not orsTMP Is Nothing Then

                'If Not oRSfp.EOF Then oRSfp.Delete
                If orsTMP.RecordCount <> 0 Then
                    orsTMP.MoveFirst

                    Do While Not orsTMP.EOF
                        orsTMP.Delete adAffectCurrent
                        orsTMP.MoveNext
                    Loop

                End If

            End If

            orsFam.MoveNext
        Loop

        orsMain.MoveNext
    Loop
    
    'LIMPIANDO LA TABLA W_PEDIDO
    If orsMain.RecordCount <> 0 Then
        orsMain.Filter = ""
        orsMain.MoveFirst

        Do While Not orsMain.EOF
            LimpiaParametros oCmdEjec
            oCmdEjec.CommandText = "SP_COMANDA_DELETEPRINT"

            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@IDPRINT", adBigInt, adParamInput, , orsMain!IDPRINT)
            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@CodCia", adChar, adParamInput, 2, "01")

            oCmdEjec.Execute

            orsMain.MoveNext

        Loop

    End If

    '(@#)2-A inicio
    Exit Sub
xImprimir:
    EscribirLog Err.Description & " => Private Sub Imprimir()"

    '(@#)2-A fin
End Sub

Private Sub Timer1_Timer()
Conectar '(@#)1-A
Imprimir
Precuenta
Desconectar '(@#)1-A
End Sub

'(@#)1-A inicio
Private Sub Precuenta()

    On Error GoTo printe
    
    Dim orsPendientes As ADODB.Recordset

    'obteniendo datos de tabla de impresion
    LimpiaParametros oCmdEjec
    oCmdEjec.CommandText = "USP_PEDIDOS_POR_IMPRIMIR"
    oCmdEjec.CommandType = adCmdStoredProc
    
    oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@CodCia", adChar, adParamInput, 2, "01")

    Set orsPendientes = oCmdEjec.Execute
    
    Do While Not orsPendientes.EOF

        Dim ORSSepara As ADODB.Recordset

        LimpiaParametros oCmdEjec
        oCmdEjec.CommandType = adCmdStoredProc
        oCmdEjec.CommandText = "SpSeparaCuentas"

        oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@CodCia", adChar, adParamInput, 2, "01")
        oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@CODCLIE", adVarChar, adParamInput, 15, orsPendientes!codmesa)
        oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@FECHA", adChar, adParamInput, 8, orsPendientes!FECHA)
        oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@NumSer", adChar, adParamInput, 3, orsPendientes!numser)
        oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@NumFac", adBigInt, adParamInput, , orsPendientes!numfac)

        Set ORSSepara = oCmdEjec.Execute

        Do While Not ORSSepara.EOF

            Dim crParamDefs As CRAXDRT.ParameterFieldDefinitions

            Dim crParamDef  As CRAXDRT.ParameterFieldDefinition

            Dim objCrystal  As New CRAXDRT.APPLICATION

            Dim RutaReporte As String

            RutaReporte = "C:\Admin\Nordi\Comanda2.rpt"

            Set VReporte = objCrystal.OpenReport(RutaReporte, 1)
            Set crParamDefs = VReporte.ParameterFields

            For Each crParamDef In crParamDefs

                Select Case crParamDef.ParameterFieldName

                    Case "mesa"
                        crParamDef.AddCurrentValue Str(orsPendientes!codmesa)

                End Select

            Next

            LimpiaParametros oCmdEjec
            oCmdEjec.CommandType = adCmdStoredProc
            oCmdEjec.CommandText = "SpPrintComanda2"

            Dim rsd As ADODB.Recordset
        
            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@CodCia", adChar, adParamInput, 2, "01")
            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@NumSer", adChar, adParamInput, 3, orsPendientes!numser)
            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@NumFac", adDouble, adParamInput, , orsPendientes!numfac)
            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@xdet", adVarChar, adParamInput, 4000, "")
            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@xnumsec", adVarChar, adParamInput, 4000, "")
            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@precuenta", adBoolean, adParamInput, , 1)
            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@CTA", adChar, adParamInput, 1, ORSSepara!cuenta)

            Set rsd = oCmdEjec.Execute

            LimpiaParametros oCmdEjec
            oCmdEjec.CommandText = "SpMesaEnCuenta"
            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@CodCia", adChar, adParamInput, 2, "01")
            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@CodMesa", adVarChar, adParamInput, 10, orsPendientes!codmesa)
            oCmdEjec.Execute

            'IMPRESION
            VReporte.Database.SetDataSource rsd, 3, 1
            VReporte.SelectPrinter Printer.DriverName, CStr(orsPendientes!Print), Printer.Port
            VReporte.PrintOut False, 1, , 1, 1
            Set objCrystal = Nothing
            Set VReporte = Nothing
            'IMPRESION

            ORSSepara.MoveNext
        Loop

        'NUEVO GRABANDO EN LOG
        '        LimpiaParametros oCmdEjec
        '        oCmdEjec.CommandText = "SP_COMANDA_PRINT_LOG_INSERT"
        '        oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@CODCIA", adChar, adParamInput, 2, LK_CODCIA)
        '        oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@FECHA", adDBTimeStamp, adParamInput, , LK_FECHA_DIA)
        '        oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@NUMFAC", adBigInt, adParamInput, , lblNumero.Caption)
        '        oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@USUARIO", adVarChar, adParamInput, 20, LK_CODUSU)
        '        oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@MOZO", adVarChar, adParamInput, 40, Me.lblMozo.Caption)
        '        oCmdEjec.Execute
    
        orsPendientes.MoveNext
    
    Loop

    'LIMPIANDO LA TABLA W_PEDIDO
    If orsPendientes.RecordCount <> 0 Then
        orsPendientes.Filter = ""
        orsPendientes.MoveFirst

        Do While Not orsPendientes.EOF
            LimpiaParametros oCmdEjec
            oCmdEjec.CommandText = "SP_COMANDA_DELETEPRINT"

            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@IDPRINT", adBigInt, adParamInput, , orsPendientes!IDPRINT)
            oCmdEjec.Parameters.Append oCmdEjec.CreateParameter("@CodCia", adChar, adParamInput, 2, "01")

            oCmdEjec.Execute

            orsPendientes.MoveNext

        Loop

    End If

    Exit Sub

printe:
    '(@#)2-A inicio
    EscribirLog Err.Description & " => Private Sub Precuenta()"
    'MsgBox Err
    '(@#)2-A fin
End Sub

Private Sub CargarVariablesConexion()
c_Server = Leer_Ini(App.Path & "\config.ini", "SERVER", "localhost")
c_DataBase = Leer_Ini(App.Path & "\config.ini", "DATABASE", "BDATOS")
c_Usr = Leer_Ini(App.Path & "\config.ini", "USR", "sa")
c_Pwd = Leer_Ini(App.Path & "\config.ini", "PWD", "anteromariano")
'(@#)2-A inicio
'strCnn = "PROVIDER=MSDASQL;driver={SQL Server};server=" + c_Server + ";database=" + c_DataBase + ";uid=" + c_Usr + ";pwd=" + c_Pwd + ";"
strCnn = "Provider=SQLOLEDB;Data Source=" + c_Server + ";Initial Catalog=" + c_DataBase + ";User ID=" + c_Usr + ";Password=" + c_Pwd + ";Connection Timeout=5;"
c_CodCia = Leer_Ini(App.Path & "\config.ini", "CODCIA", "01")
'(@#)2-A fin
End Sub

Private Sub Conectar()

    '(@#)2-A inicio
    On Error GoTo xConectar

    Cnn.Open strCnn
    Exit Sub
xConectar:
    EscribirLog Err.Description & " => Private Sub Conectar()"

    '(@#)2-A fin
End Sub

Private Sub Desconectar()

    '(@#)2-A inicio
    On Error GoTo xDesconectar

    Cnn.Close
    Exit Sub
xDesconectar:
    EscribirLog Err.Description & " => Private Sub Desconectar()"

    '(@#)2-A fin
End Sub

'(@#)1-A fin
'(@#)2-A inicio
Private Sub EscribirLog(xMensaje As String)

    Dim fso         As Object

    Dim txtFile     As Object

    Dim logFilePath As String

    Dim logMessage  As String

    ' Especifica la ubicación y nombre del archivo de registro
    logFilePath = App.Path & "\error_" & Replace(CStr(Date), "/", "-") & ".log" ' "C:\Ruta\al\Archivo\Log.txt"

    ' Mensaje que deseas registrar
    logMessage = "[ERROR]: " & Now & " => " & xMensaje

    ' Crear una instancia del objeto FileSystemObject
    Set fso = CreateObject("Scripting.FileSystemObject")

    ' Verificar si el archivo de registro existe
    If Not fso.FileExists(logFilePath) Then
        ' Si el archivo no existe, créalo
        Set txtFile = fso.CreateTextFile(logFilePath)
        txtFile.WriteLine "Log File Created: " & Now
        txtFile.Close

    End If

    ' Abre el archivo de registro en modo adición (para agregar registros)
    Set txtFile = fso.OpenTextFile(logFilePath, 8)

    ' Escribe el mensaje de registro en el archivo
    txtFile.WriteLine logMessage

    ' Cierra el archivo de registro
    txtFile.Close

    ' Limpia las referencias a los objetos
    Set txtFile = Nothing
    Set fso = Nothing

End Sub

'(@#)2-A fin
