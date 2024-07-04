#include 'fisa824.ch'
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

#DEFINE _SEPARADOR "|"
#DEFINE	_POSDATA   1
#DEFINE _POSREG    2
#DEFINE _POSCGC    3
#define	_POSRAZAO  4
#DEFINE _POSALQAPL 5
#DEFINE _POSMOTIVO 6
#DEFINE _POSTIPO   7

#DEFINE _BUFFER 16384

Function FISA824()

Local cCombo	:= ""
Local aCombo	:= {}
Local oDlg		:= Nil
Local oFld		:= Nil

Private cMes	:= StrZero(Month(dDataBase),2)
Private cAno	:= StrZero(Year(dDataBase),4)
Private lRet	:= .T.
Private lPer	:= .T.
Private oTmpTable := Nil
Private aQry := {}

aAdd( aCombo, STR0002 ) //"1- Fornecedor"
aAdd( aCombo, STR0003 ) //"2- Cliente"
aAdd( aCombo, STR0004 ) //"3- Ambos"

DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 250,450 OF oDlg PIXEL //"Resolucao 44/18 para IIBB - Misiones "

@ 006,006 TO 040,170 LABEL STR0006 OF oDlg PIXEL //"Info. Preliminar"

@ 011,010 SAY STR0007 SIZE 065,008 PIXEL OF oFld //"Arquivo :"
@ 020,010 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 65,8 PIXEL OF oFld ON CHANGE ValidChk(cCombo)

//+----------------------
//| Campos Check-Up
//+----------------------
@ 10,115 SAY STR0008 SIZE 065,008 PIXEL OF oFld //"Imposto: "

@ 020,115 CHECKBOX oChk1 VAR lPer PROMPT STR0009 SIZE 40,8 PIXEL OF oFld ON CHANGE ValidChk(cCombo)  //"Percepcao"
@ 030,115 CHECKBOX oChk2 VAR lRet PROMPT STR0010 SIZE 40,8 PIXEL OF oFld ON CHANGE ValidChk(cCombo) //"Retencao"

@ 041,006 FOLDER oFld OF oDlg PROMPT STR0011 PIXEL SIZE 165,075 //"&Importação de Arquivo TXT"

//+----------------
//| Campos Folder 2
//+----------------
@ 005,005 SAY STR0012 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta opcao tem como objetivo atualizar o cadstro    "
@ 015,005 SAY STR0013 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Fornecedor / Cliente  x Imposto segundo arquivo TXT  "
@ 025,005 SAY STR0014 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"disponibilizado pelo governo                         "
@ 045,005 SAY STR0015 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Informe o periodo:"
@ 045,055 MSGET cMes PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld:aDialogs[1]	                                          
@ 045,070 SAY "/" SIZE  150, 8 PIXEL OF oFld:aDialogs[1]
@ 045,075 MSGET cAno PICTURE "@E 9999" VALID !Empty(cMes) SIZE 020,008 PIXEL OF oFld:aDialogs[1]

//+-------------------
//| Boton de MSDialog
//+-------------------
@ 055,178 BUTTON STR0016 SIZE 036,016 PIXEL ACTION ImpArq(aCombo,cCombo) //"&Importar"
@ 075,178 BUTTON STR0018 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Sair"

ACTIVATE MSDIALOG oDlg CENTER

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ValidChk ³ Autor ³ Paulo Augusto       ³ Data ³ 30.03.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa que impede o uso do check de retencao para        ³±±
±±³          ³ clientes.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Variavel com o valor escolhido no combo.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet - .T. se validado ou .F. se incorreto                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina/Misiones                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function ValidChk(cCombo)
		
If lRet == .T. .and. Subs(cCombo,1,1) $ "2"    // Cliente nao tem retenção!
	lRet :=.F.
EndIf	
oChk2:Refresh()

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpArq   ³ Autor ³ Hirae               ³ Data ³ 15.04.2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa a importacao do arquivo.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPar01 - Variavel com as opcoes do combo cliente/fornec.   ³±±
±±³          ³ cPar01 - Variavel com a opcao escolhida do combo.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpArq(aCombo,cCombo)

Local   nPos     := 0
Local   cLine    := ""
Local   lVBanco  := "MSSQL" $ Upper(TCGetDB())
Private  cFile    := ""
Private dDataIni := ""
Private dDataFim := ""
Private lFor     := .F.
Private lCli     := .F.
Private lImp     := .F.
Private lRImpEmpt:= .F.
Private lRgEmpt  := .F.
Private lAlterna := .F.


nPos := aScan(aCombo,{|x| AllTrim(x) == AllTrim(cCombo)})
If nPos == 1 // Fornecedor
	lFor := .T.
ElseIf nPos == 2 // Cliente
	lCli := .T.
ElseIf nPos == 3 // Ambos
	lFor := .T.
	lCli := .T.
EndIf


DbSelectArea("SA2")
If !(SA2->(ColumnPos("A2_REGIMP"))>0)//Campo novo, apartir da 12.1.25 pode-se retirar esta parte.
	MsgAlert(STR0032,"")
	Return Nil 
EndIf
SA2->(DbCloseArea())

// Seleciona o arquivo
cFile := FGetFile()
If Empty(cFile)
	MsgStop(STR0031) //"Seleccione un archivo e intente nuevamente."
	Return Nil
EndIf

If !lVBanco // Faz a importacao normal
	If !File(cFile)
		MsgStop(STR0031) //"Seleccione un archivo e intente nuevamente."
		Return Nil
	EndIf
	VldYFec()
	MsAguarde({|| Import(cFile)} ,STR0019,STR0020 ,.T.) //"Lendo Arquivo, Aguarde..."###"Atualizacao de aliquotas"
	TMP->(dbCloseArea())
	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf
Else
	If !File(cFile)
		Return Nil
	EndIf
	FT_FUSE(cFile)
	//Faz a importacao via banco de dados
	If TcSrvType() <> "AS/400" .and. "MSSQL" $ Upper(TCGetDB())
		MsAguarde({|| ImpASql(cFile,cCombo)} ,STR0019,STR0020 ,.T.) //"Lendo Arquivo, Aguarde..."###"Atualizacao de aliquotas"		
		If lImp
			TMP->(dbCloseArea())
		Else
			lAlterna := .T.
			VldYFec()
			MsAguarde({|| Import(cFile)} ,STR0019,STR0020 ,.T.) //"Lendo Arquivo, Aguarde..."###"Atualizacao de aliquotas"
			TMP->(dbCloseArea())
		EndIf
		If oTmpTable <> Nil
			oTmpTable:Delete()
			oTmpTable := Nil
		EndIf
		TCDelFile("PADRONMI4418")
		aSize(aQry,0)
	Else
		MsgAlert(STR0026,"")//"Este tipo de importação suporta somente banco de dados MSSQL."
		Return Nil
	EndIf
EndIf
	
If lRImpEmpt
	MsgAlert(STR0033,"")
	aSize(aQry,0)
ElseIf lRgEmpt
	MsgAlert(STR0034,"")
	aSize(aQry,0)
ElseIf (lImp .Or. lRet)
	MsgAlert(STR0025,"") //"Arquivo importado!"
	aSize(aQry,0)
EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VldYFec ³ Autor ³ Hirae                ³ Data ³ 25.04.2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida la estructura del archivo y rellena las fechas.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VldYFec()
	FT_FUSE(cFile)

	If !("|" $ (FT_FREADLN()))
		MsgStop(STR0029) //"Ha ocurrido un error al procesar el archivo seleccionado. Verifique que el contenido del mismo sea correcto e intente nuevamente."
		Return Nil
	EndIf

	cLine := Separa(FT_FREADLN(),_SEPARADOR)[_POSDATA]
	If (cAno+cMes) <> cLine  
		MsgStop(STR0021+(SubStr(cLine,5,2)+"/"+SubStr(cLine,1,4))+")",STR0022) //" Periodo Informado nao corresponde ao periodo do arquivo. ("###"Periodo"
		Return Nil
	EndIf
	dDataIni := STOD(SubStr(cLine,1,4)+SubStr(cLine,5,2)+"01")
	dDataFim := STOD(SubStr(cLine,1,4)+SubStr(cLine,5,2)+Alltrim(STR(f_UltDia(dDataIni))))
	FT_FUSE() 
Return 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGetFile ³ Autor ³ Ivan Haponczuk      ³ Data ³ 09.06.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de seleção do arquivo txt a ser importado.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet - Diretori e arquivo selecionado.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGetFile()

Local cRet := Space(50)

oDlg01 := MSDialog():New(000,000,100,500,STR0027,,,,,,,,,.T.)//"Selecionar arquivo"

oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,,,,,,,.T.,,,,,,,,,,"cRet")
oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0027,,.T.)//"Selecionar arquivo"

oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)

oDlg01:Activate(,,,.T.,,,)

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGetDir  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 09.06.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para procurar e selecionar o arquivo nos diretorios   ³±±
±±³          ³ locais/servidor/unidades mapeadas.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oPar1 - Objeto TGet que ira receber o local e o arquivo    ³±±
±±³          ³         selecionado.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGetDir(oTGet)

Local cDir := ""

cDir := cGetFile(,STR0027,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
If !Empty(cDir)
	oTGet:cText := cDir
	oTGet:Refresh()
Endif
oTGet:SetFocus()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpASql  ³ Autor ³ Hirae               ³ Data ³ 15.04.2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a importacao do arquivo atravez de comandos MSSQL. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Local e nome do arquivo a ser importado.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpASql(cFiles,cCombo)

Local cQry			:= ""
Local cLine			:= "" 
Local cCodeError	:= ""
Local cCgc          := SM0->M0_CGC
Local aCampos    := {}	// Array auxiliar para criacao do arquivo temporario
If TCCanOpen("PADRONMI4418")
	If !TCDelFile("PADRONMI4418")
		UserException( "DROP table error PADRONMI4418" + CRLF + TCSqlError() )
	EndIf
EndIf

cQry := "CREATE TABLE PADRONMI4418"
cQry += "(" 
cQry += " FECHA varchar(6) , "
cQry += " REGIMEN varchar(3) , "
cQry += " CUIT varchar(11) , "
cQry += " RAZONSOC varchar(25) , "
cQry += " ALQAPLI varchar(6) , "
cQry += " MOTIVO varchar(1) , "
cQry += " TIPO varchar(2) "
cQry += ")"

If TCSqlExec(cQry) <> 0
	UserException( "Create table error PADRONMI4418" + CRLF + TCSqlError())
EndIf

cQry := "BULK INSERT PADRONMI4418 FROM '" + AllTrim(cFiles) + "' WITH ( BATCHSIZE = 30000 , DATAFILETYPE = 'char', FIELDTERMINATOR = '"+_SEPARADOR+"',ROWTERMINATOR = '\n' )"

If TCSqlExec(cQry) <> 0
	lImp := .F.
	Return Nil
Else
	lImp := .T.
EndIf
cQry :=""
If lImp
	// Busca a data de vigência do arquivo
	If Subs(cCombo,1,1) $"2|3"
		cQry :=  "SELECT DISTINCT FECHA FECHA, REGIMEN REGIMEN, CUIT CUIT,ALQAPLI ALQAPLI, MOTIVO MOTIVO, TIPO TIPO "
		cQry +=  "FROM PADRONMI4418 AS PADRON  INNER JOIN " + RetSqlName("SA1") +  " AS CLIENTE ON PADRON.CUIT = CLIENTE.A1_CGC" 
		If lRet  .And. !lPer 
			cQry +=  " WHERE REGIMEN LIKE '2%' "
		ElseIf !lRet  .And. lPer
			cQry +=  " WHERE REGIMEN LIKE '1%' "
		EndIf 
	EndIf
	If Subs(cCombo,1,1) $"3"	
		cQry +=  "UNION "
	EndIf

	If Subs(cCombo,1,1) $"1|3"
		cQry +=  "SELECT DISTINCT FECHA FECHA, REGIMEN REGIMEN, CUIT CUIT,ALQAPLI ALQAPLI, MOTIVO MOTIVO, TIPO TIPO "
		cQry +=  "FROM PADRONMI4418 AS PADRON  INNER JOIN " + RetSqlName("SA2") + " AS PROV ON PADRON.CUIT = PROV.A2_CGC "

		If lRet  .And. !lPer 
			cQry +=  " WHERE REGIMEN LIKE '2%' "
		ElseIf !lRet  .And. lPer
		 	cQry +=  " WHERE REGIMEN LIKE '1%' "
		EndIf 
		cQry +=  "UNION SELECT DISTINCT FECHA FECHA, REGIMEN REGIMEN, CUIT CUIT,ALQAPLI ALQAPLI, MOTIVO MOTIVO, TIPO TIPO "
		cQry +=  "FROM PADRONMI4418 AS PADRON WHERE REGIMEN LIKE '1%' AND PADRON.CUIT =" + cCgc  + " "   
	EndIf
	cQry += "ORDER BY PADRON.CUIT, PADRON.REGIMEN "
	cQry := ChangeQuery(cQry)                     
	TcQuery cQry New Alias "QRY"
	dbSelectArea("QRY")
	//TRB - Modelo
	//Periodo|Régimen|Cuit       |Razón Social    |Alq. Aplicable| Motivo|Tipo de Contribuyente  
	//201902 |101    |20252544500|Pedron Gonzalez |0.00          |2      |CM
	AADD(aCampos,{"FECHA"	  ,"C",6,0})
	AADD(aCampos,{"REGIMEN"	  ,"C",3,0})
	AADD(aCampos,{"CUIT"	  ,"C",11,0})
	AADD(aCampos,{"RAZONSOC"  ,"C",25,0})
	AADD(aCampos,{"ALQAPLI"	  ,"C",6,0})
	AADD(aCampos,{"MOTIVO"	  ,"C",1,0})
	AADD(aCampos,{"TIPO"	  ,"C",2,0})
	
	oTmpTable := FWTemporaryTable():New("TMP")
	oTmpTable:SetFields( aCampos )
	aOrdem	:=	{"CUIT","REGIMEN"}
	
	oTmpTable:AddIndex("TMP", aOrdem)
	oTmpTable:Create()
	Do While Qry->(!EOF())
    	TMP->( DBAppend() )
    	TMP->FECHA		:= QRY->FECHA
  		TMP->REGIMEN	:= QRY->REGIMEN
  		TMP->CUIT		:= QRY->CUIT
  		TMP->RAZONSOC	:= ""
  		TMP->ALQAPLI	:= QRY->ALQAPLI
  		TMP->MOTIVO		:= QRY->MOTIVO
  		TMP->TIPO		:= QRY->TIPO
		TMP->( DBCommit() )	
		QRY->(DbSkip())
	Enddo
	QRY->(dbCloseArea())
	TMP->(DbGoTop())
	If !Empty(TMP->FECHA)
		cLine := TMP->FECHA   
		dDataIni := STOD(SubStr(cLine,1,4)+SubStr(cLine,5,2)+"01")
		dDataFim := STOD(SubStr(cLine,1,4)+SubStr(cLine,5,2)+Alltrim(STR(f_UltDia(dDataIni)))) 
	Else
		MsgStop(STR0021+(SubStr(cLine,4,2)+"/"+SubStr(cLine,5,4))+")",STR0022) //" Periodo Informado nao corresponde ao periodo do arquivo. ("###"Periodo"
		lImp := .F.
		Return Nil			
	EndIf	
	
	If Trim(SubStr(DTOS(dDataIni),1,6)) == ""  
		lImp := .F.
		Return Nil	                                               
	ElseIf (cAno+cMes) <> SubStr(DTOS(dDataIni),1,6)
		MsgStop(STR0021+(SubStr(cLine,5,2)+"/"+SubStr(cLine,1,4))+")",STR0022)//" Periodo Informado nao corresponde ao periodo do arquivo. ("###"Periodo"
		lImp := .F.
		Return Nil	 
	EndIf 
	
	Import()


EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Import   ³ Autor ³ Hirae                ³ Data ³ 15.04.2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a importacao do arquivo e a atualizacao das        ³±±
±±³          ³ tabelas.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Local e nome do arquivo a ser importado.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Import(cFile, nAliqPer)

Local nAliq			:= 0
Local nAlqPer		:= 0
Local aLin			:= {}
Local cChave		:= ""
Local aLinP			:= {}
Local lAchou		:= .F.
Local lFnd			:= .F.
Local cQuery		:= ""
Local xFilialSA1	:= xFilial("SA1")
Local nI 			:= 0
Local aPerPrv       := {} //Array utilizado para percepção de proveedores
Local nPosSel       := 0
Local lReturn   	:= .T.
Private cRegImp		:= "" //CCO_REGIMP
Private cRegime		:= "" //CCO_REGIME
Private cA2RImp   	:= "" //A2_REGIMP
Private cCliFor     := ""
Private cTipoMis    := "" //Tipo de contribuyente Misiones
Private lFecMen     := .F.
Private lExtVige    := .F.
Private lGenera     := .F.
Private cTable  	:= ""

If (!("MSSQL" $ Upper(TCGetDB())) .Or. lAlterna)
	Processa({|| lReturn := GeraTemp(cFile)}) // pra oracle
EndIf

If !lReturn
	Return Nil
EndIf

DBSelectArea("CCO")
CCO->(dbSetOrder(1)) //CCO_FILIAL+CCO_CODPRO
CCO->(MsSeek(xFilial("CCO")+"MI"))
If lCli .And. lPer 
	If !Empty(CCO->CCO_REGIMP) 
		cRegImp := CCO->CCO_REGIMP
	Else
		lRImpEmpt := .T.
		Return Nil
	EndIf
EndIf
If lFor .And. lRet
	If !Empty(CCO->CCO_REGIME) 
		cRegime := CCO->CCO_REGIME
	Else
		lRgEmpt := .T.
		Return Nil
	EndIf
EndIf
CCO->(dbCloseArea())

If lCli .and. lPer  
	cQuery := "SELECT A1_COD, A1_LOJA, A1_CGC, A1_NOME"
	cQuery += " FROM " + RetSqlName("SA1") 
	cQuery += " WHERE A1_FILIAL = '" + xFilialSA1 + "'"
	cQuery += " AND A1_CGC <> ''"
	cQuery += " AND D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cTempSA1", .T., .T.)
	 		
	Do While cTempSA1->(!EOF())
		cTable := "cTempSA1"
		// Atualiza o cadastro de percepcao do cliente
		If TMP->(MsSeek(AllTrim(cTempSA1->A1_CGC) + cRegImp))
			If TMP->TIPO = "D"		
				cTipoMis := "I"
			ElseIf  TMP->TIPO == "CM"
				cTipoMis := "V"
			Else
				cTipoMis := "N"
			EndIf
			nAliq := Val(StrTran(TMP->ALQAPLI,",","."))	
			dbSelectArea("SFH")
			SFH->(dbSetOrder(3))
			SFH->(dbGoTop())
			lAchou := .F.
			cChave := xFilial("SFH")+cTempSA1->A1_COD+cTempSA1->A1_LOJA+"IBG"+"MI"											
			If SFH->(MsSeek(cChave))
				nRecFim := MajorSFH(cChave)
				SFH->(DbGoTo(nRecFim))
				If (lAchou := .T.) .And. (SFH->FH_TIPO == cTipoMis)
					If dDataIni <= SFH->FH_FIMVIGE 
						lFecMen  := .T. //Fecha Menor que Txt
					ElseIf (dDataIni == (SFH->FH_FIMVIGE + 1)) .AND. (SFH->FH_ALIQ == nAliq) 
						lExtVige := .T.
					Else
						lGenera  := .T.
					EndIf
				Else
					lGenera := .T. //Encontrou, porém como é de  outro tipo deve gerar um novo registro
				EndIf
			EndIf
			If lAchou 
				If !lFecMen  
					If lExtVige
						RecLock("SFH", .F.)
						SFH->FH_FIMVIGE := dDataFim
						SFH->(MsUnlock())	
					ElseIf lGenera			
						ActSFH(SFH->FH_AGENTE,SFH->FH_ZONFIS,SFH->FH_CLIENTE,"",SFH->FH_IMPOSTO,SFH->FH_PERCIBI,SFH->FH_APERIB,cTipoMis,nAliq,IIF(TMP->MOTIVO<>"1",100,0),dDataIni,dDataFim)
					EndIf
				EndIf
			Else
				ActSFH("N","MI","","","IBG","S","S",cTipoMis,nAliq,IIF(TMP->MOTIVO<>"1",100,0),dDataIni,dDataFim)
			EndIf
			SFH->(dbCloseArea())
		Else //cib_marca=N
			dbSelectArea("SFH")
			SFH->(dbSetOrder(3))
			SFH->(dbGoTop())
			lAchou := .F.
			cChave := xFilial("SFH")+cTempSA1->A1_COD+cTempSA1->A1_LOJA+"IBG"+"MI"											
			If SFH->(MsSeek(cChave))
				nRecFim := MajorSFH(cChave)
				SFH->(DbGoTo(nRecFim))
				If (lAchou := .T.)
					If dDataIni <= SFH->FH_FIMVIGE 
						lFecMen  := .T. //Fecha Menor que Txt
					ElseIf (dDataIni == (SFH->FH_FIMVIGE + 1)) 
						lExtVige := .T.
					EndIf
				EndIf
			EndIf
			If lAchou
				If !lFecMen
					If lExtVige
						nAliq := 0
						ActSFH(SFH->FH_AGENTE,SFH->FH_ZONFIS,SFH->FH_CLIENTE,"",SFH->FH_IMPOSTO,SFH->FH_PERCIBI, SFH->FH_APERIB,SFH->FH_TIPO,0,100,dDataIni)
					EndIf
				EndIf
			EndIf
		EndIf
		lFecMen     := .F.
		lExtVige    := .F.
		lGenera     := .F.
		cTempSA1->(dbSkip())
	EndDo
	cTempSA1->(dbCloseArea())
EndIf

If lFor .and. (lRet .or. lPer)
	nAlqPer	:= 0
	dbSelectArea("SA2")
	SA2->(dbSetOrder(3))
	SA2->(dbGoTop())
	cTable := "SA2"
	TMP->(MsSeek(Alltrim(SM0->M0_CGC)))
	Do While TMP->CUIT == Alltrim(SM0->M0_CGC) .And. TMP->(!EOF())
	    Aadd(aPerPrv,{TMP->FECHA,TMP->REGIMEN,TMP->CUIT,TMP->RAZONSOC,TMP->ALQAPLI,TMP->MOTIVO,TMP->TIPO})	       
		TMP->(dbSkip())    
	EndDo
	Do While SA2->(!EOF())
		If lPer 
			If !Empty(SA2->A2_REGIMP)
				cA2RImp := SA2->A2_REGIMP
				If Len(aPerPrv)>0 .And. !Empty(cA2RImp)
					For nI := 1 to Len(aPerPrv)
						If aPerPrv[nI][_POSREG] == cA2RImp
							nPosSel := nI
							lAchouP := .T.
							nI := Len(aPerPrv)
						EndIf
					Next
				EndIf
				If lAchouP  //Solo actualiza si el registro a procesar es P=Percepcion
					TMP->(MsSeek(Alltrim(SM0->M0_CGC) + aPerPrv[nPosSel][_POSREG]))
					If aPerPrv[nPosSel][_POSTIPO] = "D"		
						cTipoMis := "I"
					ElseIf aPerPrv[nPosSel][_POSTIPO] == "CM"
						cTipoMis := "V"
					Else
						cTipoMis := "N"
					EndIf
					nAliq := Val(StrTran(aPerPrv[nPosSel][_POSALQAPL],",","."))
					dbSelectArea("SFH")
					SFH->(dbSetOrder(1))
					SFH->(dbGoTop())
					cChave := xFilial("SFH")+SA2->A2_COD+SA2->A2_LOJA+"IBG"+"MI"
					lAchou := .F.
					If SFH->(MsSeek(cChave))
						nRecFim := MajorSFH(cChave)
						SFH->(DbGoTo(nRecFim))
						If (lAchou := .T.) .And. (SFH->FH_TIPO == cTipoMis)
							If dDataIni <= SFH->FH_FIMVIGE 
								lFecMen  := .T. //Fecha Menor que Txt
							ElseIf (dDataIni == (SFH->FH_FIMVIGE + 1)) .AND. (SFH->FH_ALIQ == nAliq) 
								lExtVige := .T.
							Else
								lGenera  := .T.
							EndIf
						Else
							lAchou := .F. //Encontrou, porém como é de outro tipo. Ou seja, para o tipo do txt não é agente percp.
						EndIf
					EndIf
					If lAchou
						If !lFecMen
							If lExtVige
								RecLock("SFH", .F.)
								SFH->FH_FIMVIGE := dDataFim
								SFH->(MsUnlock())			
							ElseIf lGenera
								ActSFH(SFH->FH_AGENTE,SFH->FH_ZONFIS,SFH->FH_FORNECE,"",SFH->FH_IMPOSTO,SFH->FH_PERCIBI, SFH->FH_APERIB,SFH->FH_TIPO,nAliq,IIF(TMP->MOTIVO<>"1",100,0),dDataIni,dDataFim)
							EndIf
						EndIf
					EndIf		
				Else	
					dbSelectArea("SFH")
					SFH->(dbSetOrder(1))
					SFH->(dbGoTop())
					lAchou := .F.
					cChave := xFilial("SFH")+SA2->A2_COD+SA2->A2_LOJA+"IBG"+"MI"										
					If SFH->(MsSeek(cChave))
						nRecFim := MajorSFH(cChave)
						SFH->(DbGoTo(nRecFim))
						If (lAchou := .T.)
							If dDataIni <= SFH->FH_FIMVIGE 
								lFecMen  := .T. //Fecha Menor que Txt
							ElseIf (dDataIni > SFH->FH_FIMVIGE) 
								lGenera := .T.
							EndIf
						EndIf
					EndIf
					If lAchou
						If !lFecMen
							If lGenera
								ActSFH(SFH->FH_AGENTE,SFH->FH_ZONFIS,SFH->FH_FORNECE,SFH->FH_LOJA,SFH->FH_IMPOSTO,SFH->FH_PERCIBI, SFH->FH_APERIB,SFH->FH_TIPO,0,100,dDataIni)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If lRet
			If TMP->(MsSeek(Iif(Empty(SA2->A2_CGC),SA2->A2_CGC, Alltrim(SA2->A2_CGC)) + cRegime))
				If TMP->TIPO = "D"		
					cTipoMis := "I"
				ElseIf  TMP->TIPO == "CM"
					cTipoMis := "V"
				Else
					cTipoMis := "N"
				EndIf	
				nAliq := Val(StrTran(TMP->ALQAPLI,",","."))
				dbSelectArea("SFH")
				SFH->(dbSetOrder(1))
				SFH->(dbGoTop())
				lAchou := .F.
				cChave := xFilial("SFH")+SA2->A2_COD+SA2->A2_LOJA+"IBR"+"MI"											
				If SFH->(MsSeek(cChave))
					nRecFim := MajorSFH(cChave)
					SFH->(DbGoTo(nRecFim))
					If (lAchou := .T.) .And. (SFH->FH_TIPO == cTipoMis)
						If dDataIni <= SFH->FH_FIMVIGE 
							lFecMen  := .T. //Fecha Menor que Txt
						ElseIf (dDataIni == (SFH->FH_FIMVIGE + 1)) .AND. (SFH->FH_ALIQ == nAliq) 
							lExtVige := .T.
						Else
							lGenera  := .T.
						EndIf
					Else
						lGenera := .T. //Encontrou, porém como é de  outro tipo deve gerar um novo registro
					EndIf
				EndIf
				If lAchou 
					If !lFecMen  
						If lExtVige
							RecLock("SFH", .F.)
							SFH->FH_FIMVIGE := dDataFim
							SFH->(MsUnlock())			
						ElseIf lGenera
							ActSFH(SFH->FH_AGENTE,SFH->FH_ZONFIS,SFH->FH_FORNECE,SFH->FH_LOJA,SFH->FH_IMPOSTO,SFH->FH_PERCIBI, SFH->FH_APERIB,cTipoMis,nAliq,IIF(TMP->MOTIVO<>"1",100,0),dDataIni,dDataFim)
						EndIf
					EndIf
				Else
					ActSFH("N","MI","","","IBR","N","N",cTipoMis,nAliq,IIf(TMP->MOTIVO<>"1",100,0),dDataIni,dDataFim)
				EndIf
				SFH->(dbCloseArea())
			Else //cib_marca=N
				dbSelectArea("SFH")
				SFH->(dbSetOrder(1))
				SFH->(dbGoTop())
				lAchou := .F.
				cChave := xFilial("SFH")+SA2->A2_COD+SA2->A2_LOJA+"IBR"+"MI"											
				If SFH->(MsSeek(cChave))
					nRecFim := MajorSFH(cChave)
					SFH->(DbGoTo(nRecFim))
					If (lAchou := .T.) 
						If dDataIni <= SFH->FH_FIMVIGE 
							lFecMen  := .T. //Fecha Menor que Txt
						ElseIf (dDataIni == (SFH->FH_FIMVIGE + 1)) 
							lExtVige := .T.
						EndIf
					EndIf
				EndIf
				If lAchou
					If !lFecMen
						If lExtVige
							ActSFH(SFH->FH_AGENTE,SFH->FH_ZONFIS,SFH->FH_FORNECE,SFH->FH_LOJA,SFH->FH_IMPOSTO,SFH->FH_PERCIBI, SFH->FH_APERIB,SFH->FH_TIPO,0,100,dDataIni)						
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		lFecMen     := .F.
		lExtVige    := .F.
		lGenera     := .F.
		lAchouP 	:= .F.
		SA2->(dbSkip())
	EndDo
	SA2->(dbCloseArea())
EndIf

aSize(aLin,0) 
aSize(aLinP,0)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ActSFH   ³ Autor ³ Hirae               ³ Data ³ 15.04.2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Genera archivo en SFH.    			                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAgente  - Variavel com Agente (S/N).                      ³±±
±±³          ³ cZonaFis - Variavel com a Zona Fiscal.                     ³±±
±±³          ³ cCOD     - Variavel com código do Cli/For.                 ³±±
±±³          ³ cLoja    - Variavel com loja do Cli/For.                   ³±±
±±³          ³ cImpost  - Variavel com o imposto.                         ³±±
±±³          ³ cPercIBI - Variavel com percepção do IB.                   ³±± 
±±³          ³ cAPERIB  - Variavel com a opcao escolhida do combo.        ³±±
±±³          ³ cTipo    - Variavel com o tipo de contribuinte.            ³±±
±±³          ³ nAliq    - Variavel com a aliquota.                        ³±±
±±³          ³ nPercent - Variavel com a porcentagem de isenção.          ³±±
±±³          ³ dDataIni - Variavel com data do inicio de vigencia.        ³±±
±±³          ³ dDataFim - Variavel com data do fim de vigencia.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ActSFH(cAgente,cZonaFis,cCOD,cLoja,cImpost,cPercIBI,cAPERIB,cTipo,nAliq,nPercent,dDataIni,dDataFim)
Private lLojaSFH:= .T.
Private lCodSFH := .T.
Default cAgente := ""
Default cZonaFis:= ""
Default cCOD 	:= ""
Default cLoja	:= ""
Default cImpost := ""
Default cPercIBI:= ""
Default cAPERIb := ""
Default cTipo 	:= ""
Default nPercent:= 0
Default dDataIni:= CTOD("//")
Default dDataFim:= CTOD("//")
Default nAliq   := 0


If Empty(cLoja)
	lLojaSFH := .F.
EndIf
If Empty(cCOD)
	lCodSFH := .F.
EndIf
If cTable == "SA2"
	cPrefixo := "->A2_"
Else
	cPrefixo := "->A1_"
EndIf

If RecLock("SFH", .T.)
	SFH->FH_FILIAL	:=  xFilial("SFH")
	SFH->FH_AGENTE	:= cAgente
	SFH->FH_ZONFIS	:= cZonaFis
	If cTable == "SA2"
		SFH->FH_FORNECE := IIf(lCodSFH, cCOD , &(cTable+cPrefixo+"COD"))
	Else
		SFH->FH_CLIENTE	:= IIf(lCodSFH, cCOD , &(cTable+cPrefixo+"COD"))
	EndIf
	SFH->FH_LOJA	:= IIf(lLojaSFH, cLoja, &(cTable+cPrefixo+"LOJA"))
	SFH->FH_NOME	:= &(cTable+cPrefixo+"NOME")
	SFH->FH_IMPOSTO	:= cImpost
	SFH->FH_PERCIBI	:= cPercIBI	
	SFH->FH_ISENTO	:= "N"
	SFH->FH_APERIB	:= cAPERIb
	SFH->FH_ALIQ	:= nAliq
	SFH->FH_PERCENT	:= nPercent
	SFH->FH_TIPO    := cTipo
	SFH->FH_INIVIGE := dDataIni	
	SFH->FH_FIMVIGE := dDataFim		
	SFH->(MsUnlock())
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MajorSFH  ³ Autor ³ Hirae              ³ Data ³ 10/04/2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Encontra a SFH com Maior FH_FIMVIGE                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cClave - Chave de busca.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nRecAnt - Recno do registro com maior data de fim de vige  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MajorSFH(cClave)
Private nRecAnt := 0
Private dFecAnt := ""
If !Empty(SFH->FH_CLIENTE)
	cCliFor := SFH->FH_CLIENTE
Else
	cCliFor := SFH->FH_FORNECE
EndIf
Do While SFH->FH_FILIAL+cCliFor+SFH->FH_LOJA+SFH->FH_IMPOSTO+SFH->FH_ZONFIS == cClave .and. SFH->(!EOF())
	If Empty(SFH->FH_FIMVIGE).And. !Empty(SFH->FH_INIVIGE) 
		cDataAux := DTOS(SFH->FH_INIVIGE)
		RecLock("SFH",.F.)
		SFH->FH_FIMVIGE := STOD(SubStr(cDataAux,1,4)+SubStr(cDataAux,5,2)+Alltrim(STR(f_UltDia(SFH->FH_INIVIGE))))
		MsUnlock()
	EndIf
	If nRecAnt # 0
		If SFH->FH_FIMVIGE > dFecAnt
			nRecAnt := SFH->(Recno())
			dFecAnt := SFH->FH_FIMVIGE
		EndIf
	Else
		nRecAnt := SFH->(Recno())
		dFecAnt := SFH->FH_FIMVIGE
	EndIf
	SFH->(DbSkip())
EndDo

Return nRecAnt

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraTemp  ³ Autor ³ Hirae              ³ Data ³ 15.04.2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera temporario para importação. 	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFile  - Variavel com txt para importação.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTemp(cFile)
Local aInforma   := {} 		// Array auxiliar com as informacoes da linha lida no arquivo XLS
Local aCampos    := {}		// Array auxiliar para criacao do arquivo temporario
Local cArqProc   := cFile	// Arquivo a ser importado selecionado na tela de Wizard
Local cErro	     := ""		// Texto de mensagem de erro ocorrido na validacao do arquivo a ser importado
Local cSolucao   := ""		// Texto de solucao proposta em relacao a algum erro ocorrido na validacao do arquivo a ser importado
Local lArqValido := .T.		// Determina se o arquivo XLS esta ok para importacao
Local nHandle    := 0		// Numero de referencia atribuido na abertura do arquivo XLS
Local nI 		 := 0
Local oFile
Local nFor		 := 0
Local cMsg		 := STR0019 //"Leyendo archivo. Espere..."  
Local cBuffer    := ""
Local aArea      := ""
Local cTitulo	 := STR0001  //"Problemas en la importación del archivo"
Local lReturn    := .T.		// Determina a continuidade do processamento como base nas informacoes da tela de Wizard
Local nTimer 	:= seconds()
Local cQuery	:= "" 
Local cNomeTab	:= ""
Local lOk		:= ""				

//*************Modelo do arquivo*************
//Periodo|Régimen|Cuit       |Razón Social    |Alq. Aplicable| Motivo|Tipo de Contribuyente  
//201902 |101    |20252544500|Pedron Gonzalez |0.00          |2      |CM
AADD(aCampos,{"FECHA"	  ,"C",6,0})
AADD(aCampos,{"REGIMEN"	  ,"C",3,0})
AADD(aCampos,{"CUIT"	  ,"C",11,0})
AADD(aCampos,{"RAZONSOC"  ,"C",25,0})
AADD(aCampos,{"ALQAPLI"	  ,"C",6,0})
AADD(aCampos,{"MOTIVO"	  ,"C",1,0})
AADD(aCampos,{"TIPO"	  ,"C",2,0})

oTmpTable := FWTemporaryTable():New("TMP")
oTmpTable:SetFields( aCampos )
aOrdem	:=	{"CUIT","REGIMEN"}

oTmpTable:AddIndex("TMP", aOrdem)
oTmpTable:Create() 

If File(cArqProc) .And. lReturn

	nHandle := FT_FUse(cArqProc)
	
	If  nHandle > 0 
		//Se posiciona en la primera línea
		FT_FGoTop()
		nFor := FT_FLastRec()	
		FT_FUSE()	
	Else
		lArqValido := .F.	
		cErro	   := STR0023 + cArqProc + STR0024	//"El archivo " +cArqProc+ "No puede abrirse"
		cSolucao   := STR0029 			//"Verifique si se informó el archivo correcto para importación"
	EndIf

	If lArqValido 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera arquivo temporario a partir do arquivo TXT ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oFile := ZFWReadTXT():New(cArqProc,,_BUFFER)
		// Se hay error al abrir el archivo
		If !oFile:Open()
			MsgAlert(STR0023 + cArqProc + STR0024)  //"El archivo " +cArqProc+ "No puede abrirse"
			Return .F.
		EndIf
		
		ProcRegua(nFor)
		While oFile:ReadArray(@aInforma,_SEPARADOR)
		 	nI++
		 	IncProc(cMsg + str(nI))	        
				
        	TMP->( DBAppend() )
        	TMP->FECHA		:= aInforma[_POSDATA]
  	  		TMP->REGIMEN	:= aInforma[_POSREG]
  	  		TMP->CUIT		:= aInforma[_POSCGC]
  	  		TMP->RAZONSOC	:= aInforma[_POSRAZAO]
  	  		TMP->ALQAPLI	:= aInforma[_POSALQAPL]
  	  		TMP->MOTIVO		:= aInforma[_POSMOTIVO] 
  	  		TMP->TIPO		:= aInforma[_POSTIPO]
			TMP->( DBCommit() )	
		Enddo
	Endif
	TMP->(dbGoTop())	
	
	oFile:Close()	 // Fecha o Arquivo

	If Empty(cErro) .and. TMP->(LastRec())== 0     
		cErro		:= STR0029	//"La importación no se realizó por no existir información en el archivo informado."
		cSolucao	:= STR0031	//"Verifique se foi informado o arquivo correto para importação"
	Endif	
Else
	cErro	   := STR0023 + cArqProc + STR0024	//"El archivo " +cArqProc+ "No puede abrirse"
	cSolucao   := STR0029 						//"Verifique se foi informado o arquivo correto para importação"
EndIf
	 
If !Empty(cErro)
	xMagHelpFis(cTitulo,cErro,cSolucao)
	lReturn := .F.
Endif

Return(lReturn)
