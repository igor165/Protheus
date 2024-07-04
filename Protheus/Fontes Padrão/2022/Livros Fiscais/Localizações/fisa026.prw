#INCLUDE "FISA026.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "fwlibversion.ch"

#DEFINE _SEPARADOR ";"
#DEFINE _POSCGC    5
#DEFINE _POSDATINI 3
#define	_POSDATA   2
#DEFINE _POSDATFIN 4
#DEFINE _POSALQPER 9
#DEFINE _POSALQRET 9
#DEFINE _POSREG    1
#DEFINE _POSTIPO1  6
#DEFINE _POSTIPO2  7
#DEFINE _POSTIPO3  8
#DEFINE _POSPORC  10

#DEFINE _BUFFER 16384

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FISA026  ³ Autor ³ Ivan Haponczuk       ³ Data ³ 01.06.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a partir de um arquivo TXT gerado pela AFIP        ³±±
±±³          ³ atualizando as aliquotas de percepcao/retencao na tabela    ³±±
±±³          ³ SFH (ingressos brutos).                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³  Fiscal - Buenos Aires - Argentina                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³  BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Laura Medina  ³17/06/14³TPVX35 ³La AFIP modifico el archivo TXT (ahora  ³±±
±±³              ³        ³       ³genera: 1Reg para Percepcion y 1reg de  ³±±
±±³              ³        ³       ³para Retencion, se adecuo la funcionali-³±±
±±³              ³        ³       ³dad a este esquema.                     ³±±
±±³Laura Medina  ³30/06/14³TPVZ44 ³Error en Query.                         ³±±
±±³Emanuel V.V.  ³        ³TQNAU0 ³Correccion funcion donde se cicla si    ³±±
±±³              ³        ³       ³el DBMS es diferente de SQLServer.      ³±±
±±³              ³        ³       ³replica del llamado TQAWQ5              ³±±
±±³ Marco A. Glz.³13/02/17³MMI-260³Se realiza Replica para V12.1.14, la    ³±±
±±³              ³        ³       ³cual contiene la validacion para tomar  ³±±
±±³              ³        ³       ³en cuenta la situacion del Prov. (ARG)  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISA026()

	Local cCombo	:= ""
	Local aCombo	:= {}
	Local oDlg		:= Nil
	Local oFld		:= Nil

	Private cMes	:= StrZero(Month(dDataBase),2)
	Private cAno	:= StrZero(Year(dDataBase),4)
	Private lRet	:= .T.
	Private lPer	:= .T.
	Private oTmpTable := Nil
	Private lPadrBA	:= AI0->(ColumnPos("AI0_PADRBA")) > 0 .And. SA2->(ColumnPos("A2_PADRBA")) > 0
	Private aQry := {}

	aAdd( aCombo, STR0002 ) //"1- Fornecedor"
	aAdd( aCombo, STR0003 ) //"2- Cliente"
	aAdd( aCombo, STR0004 ) //"3- Ambos"

	DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 250,450 OF oDlg PIXEL //"Resolucao 70/07 para IIBB - Buenos Aires "

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
±±³Uso       ³ Fiscal - Buenos Aires Argentina                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function ValidChk(cCombo)
		
	If lRet == .T. .and. Subs(cCombo,1,1) $ "2"    // Cliente nao tem retenção
		lRet :=.F.
	EndIf	
	oChk2:Refresh()

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpArq   ³ Autor ³ Ivan Haponczuk      ³ Data ³ 01.06.2011 ³±±
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
	Local	lCrea	 := .F.
	Local	cBuild	 := TCGetBuild()
	Local	lProces  := .F.
	Local	lRetOk   := .F.
	Local	lAtuLib	 := .F. 
	Local	cfinal	 := ""
	Local	cPesq	 := "\"
	Local	nTamArq	 := 0
	Local	cValida  := ""
	Local	dDtVldIni := "" 
	Local	dDtvldFim := ""
		
	Private	cStartPath := GetSrvProfString("StartPath","")
	Private  cFile    := ""
	Private dDataIni := ""
	Private dDataFim := ""
	Private lFor     := .F.
	Private lCli     := .F.
	Private lImp     := .F.
	Private lAutomato := isblind()

	nPos := aScan(aCombo,{|x| AllTrim(x) == AllTrim(cCombo)})
	If nPos == 1 // Fornecedor
		lFor := .T.
	ElseIf nPos == 2 // Cliente
		lCli := .T.
	ElseIf nPos == 3 // Ambos
		lFor := .T.
		lCli := .T.
	EndIf
	
	If cBuild  >= "20181212" .and. FwLibVersion() >= "20201009"	
		lAtuLib := .T.
	EndIf
	
	// Seleciona o arquivo
	IF !lAutomato
		cFile := FGetFile()
		If Empty(cFile)
			MsgStop(STR0047) //"Seleccione un archivo e intente nuevamente."
			Return Nil
		EndIf
	else
		cFile:=cFileAut
	EndIf

	If lAtuLib
		If !lAutomato
			// Seleciona o arquivo
			cStartPath := StrTran(cStartPath,"/","\")
			cStartPath +=If(Right(cStartPath,1)=="\","","\")
			cfinal:= cFile
			If !Empty(cFile) 	
				If ! cFile $ cStartPath
					If ":" $ cFile
						CpyT2S(cFile,cStartPath,.T.)
					Endif
				EndIf
			EndIF
		Endif
		If !File(cFile)
			Return Nil
		EndIf
		If !lAutomato		
			If !Substr(cFile,1,6) $ cStartPath
				While AT( cPesq, cfinal) > 0  		
					Naux:=AT( cPesq, cfinal ) 
					Naux:=Naux+1
					nTamArq:= Len(cfinal)
					cfinal:= SubStr(cfinal,Naux,nTamArq)		
				EndDo
			Endif
		Endif
		
		If !lAutomato
			FT_FUSE(cStartPath + cfinal)
			cValida := FT_FReadLn()
			dDtVldIni := STOD(SubStr(cValida,16,4) + SubStr(cValida,14,2) + SubStr(cValida,12,2))
			dDtvldFim := STOD(SubStr(cValida,25,4) + SubStr(cValida,23,2) + SubStr(cValida,21,2)) 
			    
			If Trim(SubStr(DTOS(dDtVldIni),1,6)) == ""  
				lImp := .F.
				Return Nil	                                               
			ElseIf (cAno+cMes) <> SubStr(DTOS(dDtVldIni),1,6)
				MsgStop(STR0026+(SubStr(cLine,3,2)+"/"+SubStr(cLine,5,4))+")",STR0027) //" Periodo Informado nao corresponde ao periodo do arquivo. ("###"Periodo"
				lImp := .F.
				Return Nil	 
			EndIf
			MsAguarde({|| ImpFWSql(cFile,cStartPath,cfinal,cCombo)} ,STR0024,STR0025 ,.T.) //"Lendo Arquivo, Aguarde..."###"Atualizacao de aliquotas"
		Else
			FT_FUSE(cFile)
			MsAguarde({|| ImpFWSql(cFile,"","",cCombo)} ,STR0024,STR0025 ,.T.) //"Lendo Arquivo, Aguarde..."###"Atualizacao de aliquotas"
		Endif
		If lImp
			If lVBanco
				MsAguarde({|| GeraSFH(cFile)}   ,STR0039,STR0040,.T.) //"Verificando clientes/fornecedores, Aguarde..."###"Criando registros"					
				MsAguarde({|| FilSFHSql()} ,STR0024,STR0025 ,.T.) //"Lendo Arquivo, Aguarde..."###"Atualizacao de aliquotas"
				TCDelFile("PADRONARBA")			
				aSize(aQry,0)
			Else
				If !File(cFile)
					MsgStop(STR0047) //"Seleccione un archivo e intente nuevamente."
					Return Nil
				EndIf
				FT_FUSE(cFile)

				If !(";" $ (FT_FREADLN()))
					MsgStop(STR0045) //"Ha ocurrido un error al procesar el archivo seleccionado. Verifique que el contenido del mismo sea correcto e intente nuevamente."
					Return Nil
				EndIf

				cLine := SubStr(Separa(FT_FREADLN(),_SEPARADOR)[_POSDATINI],3,6)
				If (cMes+cAno) <> cLine  
					MsgStop(STR0026+(SubStr(cLine,1,2)+"/"+SubStr(cLine,3,4))+")",STR0027) //" Periodo Informado nao corresponde ao periodo do arquivo. ("###"Periodo"
					Return Nil
				EndIf
				cLine := Separa(FT_FREADLN(),_SEPARADOR)[_POSDATINI]
				dDataIni := STOD(SubStr(cLine,5,4)+SubStr(cLine,3,2)+SubStr(cLine,1,2))
				cLine := Separa(FT_FREADLN(),_SEPARADOR)[_POSDATFIN]
				dDataFim := STOD(SubStr(cLine,5,4)+SubStr(cLine,3,2)+SubStr(cLine,1,2))
				FT_FUSE()
				MsAguarde({|| Import2()} ,STR0024,STR0025 ,.T.) //"Lendo Arquivo, Aguarde..."###"Atualizacao de aliquotas"
				TCDelFile("PADRONARBA")	
			EndIf
		Else
			TCDelFile("PADRONARBA")
			aSize(aQry,0)
			Return Nil
		EndIf	
	// Faz a importacao normal
	ElseIf !lAtuLib .And. !lVBanco 
		If !File(cFile)
			MsgStop(STR0047) //"Seleccione un archivo e intente nuevamente."
			Return Nil
		EndIf
		FT_FUSE(cFile)

		If !(";" $ (FT_FREADLN()))
			MsgStop(STR0045) //"Ha ocurrido un error al procesar el archivo seleccionado. Verifique que el contenido del mismo sea correcto e intente nuevamente."
			Return Nil
		EndIf

		cLine := SubStr(Separa(FT_FREADLN(),_SEPARADOR)[_POSDATINI],3,6)
		If (cMes+cAno) <> cLine  
			MsgStop(STR0026+(SubStr(cLine,1,2)+"/"+SubStr(cLine,3,4))+")",STR0027) //" Periodo Informado nao corresponde ao periodo do arquivo. ("###"Periodo"
			Return Nil
		EndIf
		cLine := Separa(FT_FREADLN(),_SEPARADOR)[_POSDATINI]
		dDataIni := STOD(SubStr(cLine,5,4)+SubStr(cLine,3,2)+SubStr(cLine,1,2))
		cLine := Separa(FT_FREADLN(),_SEPARADOR)[_POSDATFIN]
		dDataFim := STOD(SubStr(cLine,5,4)+SubStr(cLine,3,2)+SubStr(cLine,1,2))
		FT_FUSE() 
		MsAguarde({|| Import(cFile)} ,STR0024,STR0025 ,.T.) //"Lendo Arquivo, Aguarde..."###"Atualizacao de aliquotas"
		TMP->(dbCloseArea())
		If oTmpTable <> Nil
			oTmpTable:Delete()
			oTmpTable := Nil
		EndIf
	ElseIf !lAtuLib .And. lVBanco
		If !File(cFile)
			Return Nil
		EndIf
		FT_FUSE(cFile)
		//Faz a importacao via banco de dados
		If TcSrvType() <> "AS/400" .and. "MSSQL" $ Upper(TCGetDB())
			MsAguarde({|| ImpASql(cFile,cCombo)} ,STR0024,STR0025 ,.T.) //"Lendo Arquivo, Aguarde..."###"Atualizacao de aliquotas" 
			If lImp
				MsAguarde({|| GeraSFH(cFile)}   ,STR0039,STR0040,.T.) //"Verificando clientes/fornecedores, Aguarde..."###"Criando registros"					
				MsAguarde({|| FilSFHSql()} ,STR0024,STR0025 ,.T.) //"Lendo Arquivo, Aguarde..."###"Atualizacao de aliquotas"
				TCDelFile("PADRONARBA")			
				aSize(aQry,0)
			Else
				TCDelFile("PADRONARBA")
				aSize(aQry,0)
				Return Nil
			EndIf
		Else
			MsgAlert(STR0042,"")//"Este tipo de importação suporta somente banco de dados MSSQL."
			Return Nil
		EndIf
	EndIf
	
	IF !lAutomato
		MsgAlert(STR0041,"") //"Arquivo importado!"
	ENDIF
	aSize(aQry,0)
	
	//Tratamento para deletar o arquivo do disco 
	If lAtuLib		
		FERASE(cStartPath+cfinal)
	Endif
	
Return Nil

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

	oDlg01 := MSDialog():New(000,000,100,500,STR0043,,,,,,,,,.T.)//"Selecionar arquivo"

	oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,,,,,,,.T.,,,,,,,,,,"cRet")
	oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0043,,.T.)//"Selecionar arquivo"

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
	
	cDir := cGetFile(,STR0043,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
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
±±³Funcao    ³ ImpASql  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 01.06.2011 ³±±
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
	Local cCgc  :=SM0->M0_CGC
	If TCCanOpen("PADRONARBA")
		If !TCDelFile("PADRONARBA")
			UserException( "DROP table error PADRONARBA" + CRLF + TCSqlError() )
		EndIf
	EndIf

	cQry := "CREATE TABLE PADRONARBA "
	cQry += "(" 
	cQry += " REGIMEN varchar(1) , "
	cQry += " FECHA1 varchar(8) , "
	cQry += " FECHA2 varchar(8) , "
	cQry += " FECHA3 varchar(8) , "
	cQry += " CUIT varchar(11) , "
	cQry += " TIPO1 varchar(1) , "
	cQry += " TIPO2 varchar(1) , "
	cQry += " TIPO3 varchar(1) , "
	cQry += " ALIQUOTA varchar(6) , "
	cQry += " PORC  varchar(6)  "
	cQry += ")"

	If TCSqlExec(cQry) <> 0
		UserException( "Create table error PADRONARBA" + CRLF + TCSqlError())
	EndIf

	cQry := "BULK INSERT PADRONARBA FROM '" + AllTrim(cFiles) + "' WITH ( BATCHSIZE = 30000 , DATAFILETYPE = 'char', FIELDTERMINATOR = '"+_SEPARADOR+"',ROWTERMINATOR = '\n' )"
	
	If TCSqlExec(cQry) <> 0
		cCodeError := typeErrSQL(TCSqlError())
		
		If cCodeError == "4863"
			MsgStop(STR0045) //"Ha ocurrido un error al procesar el archivo seleccionado. Verifique que el contenido del mismo sea correcto e intente nuevamente."
			lImp := .F.
			Return Nil
		ElseIf cCodeError == "4860"
			MsgStop(STR0044) //"Este archivo no existe o el servidor SQL no puede abrirlo, utilice un archivo que esté en la maquina de su servidor SQL o una dirección de red que pueda accederse por el servidor SQL."
			lImp := .F.
			Return Nil
		Else
			MsgStop(STR0046) //"Ha ocurrido un error al procesar el archivo seleccionado, verifique que el archivo existe en el servidor de SQL así como su contenido e intente nuevamente."
			lImp := .F.
			Return Nil
		EndIf
	Else
		lImp := .T.
		IF  lCli .And. !lFor
			cQry := "DELETE ARBA FROM PADRONARBA ARBA WHERE NOT EXISTS (SELECT * FROM " + RetSqlName("SA1") + " SA1 WHERE RTRIM(lTRIM(SA1.A1_CGC)) = RTRIM(LTRIM(ARBA.CUIT)) AND SA1.D_E_L_E_T_<>'*' )"   
		Endif

		If TCSqlExec( cQry ) <> 0  
			lImp := .F.                                       
			Return Nil
		EndIf
	EndIf
	cQry :=""
	If lImp
		// Busca a data de vigência do arquivo
		If Subs(cCombo,1,1) $"2|3"
			cQry :=  "SELECT DISTINCT CUIT CUIT, FECHA2 FECHA2,FECHA3 FECHA3,TIPO1 TIPO1,REGIMEN REGIMEN,ALIQUOTA ALIQUOTA "
			cQry +=  "FROM PADRONARBA AS PADRON  INNER JOIN " + RetSqlName("SA1") +  " AS CLIENTE ON PADRON.CUIT = CLIENTE.A1_CGC" 
			If lRet  .And. !lPer 
				cQry +=  " WHERE REGIMEN='R' "
			ElseIf !lRet  .And. lPer
				cQry +=  " WHERE REGIMEN='P' "
			EndIf 
		EndIf
		If Subs(cCombo,1,1) $"3"	
			cQry +=  "UNION "
		EndIf
	
		If Subs(cCombo,1,1) $"1|3"
			cQry +=  "SELECT DISTINCT CUIT CUIT, FECHA2 FECHA2,FECHA3 FECHA3,TIPO1 TIPO1,REGIMEN REGIMEN,ALIQUOTA ALIQUOTA "
			cQry +=  "FROM PADRONARBA AS PADRON  INNER JOIN " + RetSqlName("SA2") + " AS PROV ON PADRON.CUIT = PROV.A2_CGC "

			If lRet  .And. !lPer 
				cQry +=  " WHERE REGIMEN='R' "
			ElseIf !lRet  .And. lPer
			 	cQry +=  " WHERE REGIMEN='P' "
			EndIf 
			cQry +=  "UNION SELECT DISTINCT CUIT CUIT, FECHA2 FECHA2,FECHA3 FECHA3,TIPO1 TIPO1,REGIMEN REGIMEN,ALIQUOTA ALIQUOTA 
			cQry +=  "FROM PADRONARBA AS PADRON WHERE REGIMEN='P' AND PADRON.CUIT =" + cCgc  + " "   
		EndIf
		cQry := ChangeQuery(cQry)                     
		TcQuery cQry New Alias "QRY"

		dbSelectAre("QRY")
		cLine := QRY->FECHA2
		dDataIni := STOD(SubStr(cLine,5,4)+SubStr(cLine,3,2)+SubStr(cLine,1,2))
		cLine := QRY->FECHA3
		dDataFim := STOD(SubStr(cLine,5,4)+SubStr(cLine,3,2)+SubStr(cLine,1,2))     

		Do While Qry->(!EOF())
	       Aadd(aQry,{QRY->CUIT,QRY->TIPO1,QRY->REGIMEN,QRY->ALIQUOTA})	       
			Qry->(dbSkip())    
		EndDo	
		QRY->(dbCloseAre())

		If Trim(SubStr(DTOS(dDataIni),1,6)) == ""  
			lImp := .F.
			Return Nil	                                               
		ElseIf (cAno+cMes) <> SubStr(DTOS(dDataIni),1,6)
			MsgStop(STR0026+(SubStr(cLine,3,2)+"/"+SubStr(cLine,5,4))+")",STR0027) //" Periodo Informado nao corresponde ao periodo do arquivo. ("###"Periodo"
			lImp := .F.
			Return Nil	 
		EndIf 

	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpFWSql  ³ Autor ³ Danilo Santos      ³ Data ³ 02.02.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a importacao do arquivo atravez da função FWBulk . ³±±
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
Static Function ImpFWSql(cFile,cStartPath,cfinal,cCombo)

	Local cQry			:= ""
	Local cLine			:= "" 
	Local cCodeError	:= ""
	Local cCgc  :=SM0->M0_CGC
	Local nHandle := 0
	Local nX := 0
	Local oBulk as object
	Local aStruct as array
	Local nX as numeric
	Local lCanUseBulk as logical
	Local nUlt := 0
	Local lProc := .F. 
	Local nPosQry := 0
	Local aEmpresa := {}
	Local nPosEmp := 0
	Local lVBanco		:= "MSSQL" $ Upper(TCGetDB())

	Default cFile := ""	
	Default cStartPath := ""
	Default cfinal := ""
	Default cCombo := ""
	
	If TCCanOpen("PADRONARBA")
		If !TCDelFile("PADRONARBA")
			UserException( "DROP table error PADRONARBA" + CRLF + TCSqlError() )
		EndIf
	EndIf
	If !lAutomato
		FT_FUSE(cStartPath + cfinal)
	Else
		FT_FUSE(cFile)
	Endif	
	nUlt:= FT_FLASTREC()

	aStruct := {}
 
    aAdd( aStruct, { 'REGIMEN' , 'C' , 001,0 } ) //1
    aAdd( aStruct, { 'FECHA1'  , 'C' , 008,0 } ) //2
    aAdd( aStruct, { 'FECHA2'  , 'C' , 008,0 } ) //3
    aAdd( aStruct, { 'FECHA3'  , 'C' , 008,0 } ) //4
    aAdd( aStruct, { 'CUIT'    , 'C' , 011,0 } ) //5
	aAdd( aStruct, { 'TIPO1'   , 'C' , 001,0 } ) //6
	aAdd( aStruct, { 'TIPO2'   , 'C' , 001,0 } ) //7
	aAdd( aStruct, { 'TIPO3'   , 'C' , 001,0 } ) //8
	aAdd( aStruct, { 'ALIQUOTA', 'C' , 006,0 } ) //9
	aAdd( aStruct, { 'PORC'    , 'C' , 006,0 } ) //10
 
    FWDBCreate( 'PADRONARBA', aStruct , 'TOPCONN' , .T.) 

	oBulk := FwBulk():New('PADRONARBA',2000)
    lCanUseBulk := FwBulk():CanBulk() // Este método não depende da classe FWBulk ser inicializada por NEW
    if lCanUseBulk
        oBulk:SetFields(aStruct)
    endif
	if lCanUseBulk 
    	For nX := 1 to nUlt        
			aDatos := SeperaTXT(FT_FReadLn())            
			oBulk:AddData({aDatos[1],aDatos[2],aDatos[3],aDatos[4],aDatos[5],aDatos[6],aDatos[7],aDatos[8],aDatos[9],aDatos[10]})        
		FT_FSKIP()     
    	Next
		lImp  := .T.
	endif 
	FT_FUSE()
    if lCanUseBulk
    	cCodeError:= oBulk:GetError()
        oBulk:Close()
        oBulk:Destroy()
        oBulk := nil
    endif
    
	If cCodeError <> ""
		If cCodeError == "4863"
			MsgStop(STR0045) //"Ha ocurrido un error al procesar el archivo seleccionado. Verifique que el contenido del mismo sea correcto e intente nuevamente."
			lImp := .F.
			Return Nil
		ElseIf cCodeError == "4860"
			MsgStop(STR0044) //"Este archivo no existe o el servidor SQL no puede abrirlo, utilice un archivo que esté en la maquina de su servidor SQL o una dirección de red que pueda accederse por el servidor SQL."
			lImp := .F.
			Return Nil
		Else
			MsgStop(STR0046) //"Ha ocurrido un error al procesar el archivo seleccionado, verifique que el archivo existe en el servidor de SQL así como su contenido e intente nuevamente."
			lImp := .F.
			Return Nil
		EndIf
	Endif
	
	
	If lImp .and. lVBanco
		aEmpresa := FWLoadSM0()
		nPosEmp := aScan( aEmpresa, {|x| x[2] == cFilAnt } )
		cQryEmp := " SELECT CUIT CUIT, FECHA2 FECHA2,FECHA3 FECHA3,TIPO1 TIPO1,REGIMEN REGIMEN,ALIQUOTA ALIQUOTA FROM PADRONARBA PADRON WHERE CUIT = '"+ Alltrim(aEmpresa[nPosEmp][18]) +"' "
			
		cQryEmp := ChangeQuery(cQryEmp)                     
		TcQuery cQryEmp New Alias "QRYEMP"
			
		dbSelectAre("QRYEMP")
		If (Select( "QRYEMP" ) > 0 )
			Aadd(aQry,{QRYEMP->CUIT,QRYEMP->TIPO1,QRYEMP->REGIMEN,QRYEMP->ALIQUOTA})
		Endif
		QRYEMP->(dbCloseAre())
		// Busca a data de vigência do arquivo
		If Subs(cCombo,1,1) $"2|3"
			cQry :=  "SELECT DISTINCT CUIT CUIT, FECHA2 FECHA2,FECHA3 FECHA3,TIPO1 TIPO1,REGIMEN REGIMEN,ALIQUOTA ALIQUOTA "
			cQry +=  "FROM PADRONARBA PADRON  INNER JOIN " + RetSqlName("SA1") +  " CLIENTE ON PADRON.CUIT = CLIENTE.A1_CGC " 
			If lRet  .And. !lPer 
				cQry +=  " WHERE REGIMEN='R' "
			ElseIf !lRet  .And. lPer
				cQry +=  " WHERE REGIMEN='P' "
			EndIf 
		EndIf
		If Subs(cCombo,1,1) $"3"	
			cQry +=  " UNION "
		EndIf
	
		If Subs(cCombo,1,1) $"1|3"
			cQry +=  " SELECT DISTINCT CUIT CUIT, FECHA2 FECHA2,FECHA3 FECHA3,TIPO1 TIPO1,REGIMEN REGIMEN,ALIQUOTA ALIQUOTA "
			cQry +=  " FROM PADRONARBA PADRON  INNER JOIN " + RetSqlName("SA2") + " PROV ON PADRON.CUIT = PROV.A2_CGC "

			If lRet  .And. !lPer 
				cQry +=  " WHERE REGIMEN='R' "
			ElseIf !lRet  .And. lPer
			 	cQry +=  " WHERE REGIMEN='P' "
			EndIf
		EndIf
		
		cQry := ChangeQuery(cQry)                     
		TcQuery cQry New Alias "QRY"
		
		dbSelectAre("QRY")
		cLine := QRY->FECHA2
		dDataIni := STOD(SubStr(cLine,5,4)+SubStr(cLine,3,2)+SubStr(cLine,1,2))
		cLine := QRY->FECHA3
		dDataFim := STOD(SubStr(cLine,5,4)+SubStr(cLine,3,2)+SubStr(cLine,1,2))     
		Do While Qry->(!EOF())
		   nPosQry := aScan(aQry, {|X| aLLTRIM(X[1]) == ALLTrim(QRY->CUIT)})
	       If nPosQry == 0
	       		Aadd(aQry,{QRY->CUIT,QRY->TIPO1,QRY->REGIMEN,QRY->ALIQUOTA})
	       Endif			       
		   Qry->(dbSkip())    
		EndDo	
		QRY->(dbCloseAre())
		
		If Trim(SubStr(DTOS(dDataIni),1,6)) == ""  
			lImp := .F.
			Return Nil	                                               
		ElseIf (cAno+cMes) <> SubStr(DTOS(dDataIni),1,6)
			MsgStop(STR0026+(SubStr(cLine,3,2)+"/"+SubStr(cLine,5,4))+")",STR0027) //" Periodo Informado nao corresponde ao periodo do arquivo. ("###"Periodo"
			lImp := .F.
			Return Nil	 
		EndIf 

	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FilSFHSql³ Autor ³ Ivan Haponczuk      ³ Data ³ 09.06.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a atualizacao da tabela SFH de acordo com os dados ³±±
±±³          ³ da tabela do arquivo importado.                            ³±±
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
Static Function FilSFHSql()

	Local cQry	:= ""
	Local cCGC	:= ALLTRIM(SM0->M0_CGC)
	
	If (lCli .or. lFor) .and. (lPer .or. lRet)
		cQry := "BEGIN " + CRLF
		If lCli .and. lPer
			cQry += " UPDATE "+RetSqlName("SFH")+" SET FH_ALIQ = CAST(REPLACE(ALIQUOTA,',','.') AS float) " + CRLF
			cQry += " , FH_ISENTO = CASE CAST(REPLACE(ALIQUOTA,',','.') AS float) WHEN 0 THEN 'S' ELSE 'N' END " + CRLF
			cQry += " FROM "+RetSqlName("SFH")+" SFH, "+RetSqlName("SA1")+" SA1 INNER JOIN PADRONARBA ARBA ON RTRIM(LTRIM(ARBA.CUIT)) = RTRIM(LTRIM(SA1.A1_CGC))" + CRLF
			cQry +=  "LEFT JOIN " + RetSqlName("AI0") + " AI0 ON AI0_CODCLI = A1_COD AND AI0_LOJA = A1_LOJA" + CRLF
			cQry += " WHERE SFH.D_E_L_E_T_<>'*' AND SFH.FH_FILIAL='"+xFilial("SFH")+"' " + CRLF
			cQry += " AND SFH.FH_CLIENTE<>'' AND SFH.FH_IMPOSTO='IB2' " + CRLF
			cQry += " AND SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_CGC<>'' AND SA1.A1_TIPO<>'E' " + IIf(lPadrBA, "AND AI0.AI0_PADRBA <> 'N'", "") + CRLF
			cQry += " AND SA1.D_E_L_E_T_<>'*' AND SA1.A1_COD=SFH.FH_CLIENTE AND SA1.A1_LOJA=SFH.FH_LOJA " + CRLF
		cQry += " AND ARBA.CUIT=SA1.A1_CGC AND SFH.FH_INIVIGE = '" + DToS(dDataIni) + "' AND SFH.FH_FIMVIGE = '" + DToS(dDataFim) + "'" + CRLF      		
			cQry += " AND UPPER(ARBA.REGIMEN) = 'P' " + CRLF
		EndIf

		If lFor
			If lPer
				cQry += " UPDATE "+RetSqlName("SFH")+" SET FH_ALIQ = CAST(REPLACE(ALIQUOTA,',','.') AS float) " + CRLF
				cQry += " , FH_ISENTO= CASE CAST(REPLACE(ALIQUOTA,',','.') AS float) WHEN 0 THEN 'S' ELSE 'N' END " + CRLF
				cQry += " FROM "+RetSqlName("SFH")+" SFH, "+RetSqlName("SA2")+" SA2 INNER JOIN PADRONARBA ARBA ON RTRIM(LTRIM(ARBA.CUIT)) = '" +  cCGC  + "'   " + CRLF
				cQry += " WHERE SFH.D_E_L_E_T_<>'*' AND SFH.FH_FILIAL='"+xFilial("SFH")+"' " + CRLF
				cQry += " AND SFH.FH_FORNECE<>'' AND SFH.FH_IMPOSTO='IB2' " + CRLF
				cQry += " AND SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_CGC<>'' AND SA2.A2_TIPO<>'E' " + IIf(lPadrBA, "AND SA2.A2_PADRBA <> 'N'", "") + CRLF
				cQry += "	AND SA2.D_E_L_E_T_<>'*' AND SA2.A2_COD=SFH.FH_FORNECE AND SA2.A2_LOJA=SFH.FH_LOJA" + CRLF 
				cQry += " AND ARBA.CUIT='" +  cCGC  + "'  AND SFH.FH_INIVIGE = '" + DToS(dDataIni) + "' AND SFH.FH_FIMVIGE = '" + DToS(dDataFim) + "'" + CRLF      		      		
				cQry += " AND UPPER(ARBA.REGIMEN) = 'P' " + CRLF
			EndIf
			If lRet
				cQry += " UPDATE "+RetSqlName("SFH")+" SET FH_ALIQ = CAST(REPLACE(ALIQUOTA,',','.') AS float) " + CRLF
				cQry += " , FH_ISENTO= CASE CONVERT(float,Replace(ALIQUOTA,',','.')) WHEN 0 THEN 'S' ELSE 'N' END " + CRLF
				cQry += " FROM "+RetSqlName("SFH")+" SFH, "+RetSqlName("SA2")+" SA2, PADRONARBA ARBA " + CRLF
				cQry += " WHERE SFH.D_E_L_E_T_<>'*' AND SFH.FH_FILIAL='"+xFilial("SFH")+"' " + CRLF
				cQry += " AND SFH.FH_FORNECE<>'' AND SFH.FH_IMPOSTO='IBR' AND SFH.FH_ZONFIS='BA' " + CRLF
				cQry += " AND SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_CGC<>'' AND SA2.A2_TIPO<>'E' " + IIf(lPadrBA, "AND SA2.A2_PADRBA <> 'N'", "") + CRLF
				cQry += " AND SA2.D_E_L_E_T_<>'*' AND SA2.A2_COD=SFH.FH_FORNECE AND SA2.A2_LOJA=SFH.FH_LOJA " + CRLF
				cQry += " AND ARBA.CUIT=SA2.A2_CGC AND SFH.FH_INIVIGE = '" + DToS(dDataIni) + "' AND SFH.FH_FIMVIGE = '" + DToS(dDataFim) + "'" + CRLF
				cQry += " AND UPPER(ARBA.REGIMEN) = 'R' " + CRLF
			EndIf
		EndIf
		cQry += "END"
	EndIf

	If TCSqlExec(cQry) <> 0
		UserException("Update table error " + RetSqlName("SFH") + CRLF + TCSqlError())
	EndIf

	If TCCanOpen("PADRONARBA")
		If TCSqlExec("DROP TABLE PADRONARBA") <> 0
			UserException("DROP table error PADRONARBA" + CRLF + TCSqlError())
		EndIf
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraSFH  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 01.06.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera os registros na SFH para todos os cliente/fornec.     ³±±
±±³          ³ cadastrados.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraSFH()

	Local lFnd			:= .F.
	Local cChave		:= ""  
	Local nPos			:= 0
	Local lVBanco		:= "MSSQL" $ Upper(TCGetDB())
	Local lIntSynt 		:= SuperGetMV("MV_LJSYNT", , "0") == "1"	 // Informa se a integracao Synthesis esta ativa
	Local lPosFlag 		:= SA1->(ColumnPos("A1_POSFLAG")) > 0
	Local lPosDtEx 		:= SA1->(ColumnPos("A1_POSDTEX")) > 0
	Local cQuery		:= ""
	Local xFilialSA1	:= xFilial("SA1")
	Local cCGC:= ALLTRIM(SM0->M0_CGC    )
	Local nAliqP := ""
	local nRecnoSFH := 0
	Local lAchouReg := .F.
	Local lAtu := .F.
	Local nAliqAtu := 0
	Local nRecFim:=0
	Local cAliqAux:=''

	If lCli .and. lPer
		cQuery := "SELECT A1_COD, A1_LOJA, A1_CGC, A1_NOME," + IIf(lPosFlag, " A1_POSFLAG, AI0_PADRBA", " AI0_PADRBA")
		cQuery += " FROM " + RetSqlName("SA1") + " SA1 INNER JOIN " + RetSqlName("AI0") + " AI0" + " ON A1_COD = AI0_CODCLI AND A1_LOJA = AI0_LOJA"
		cQuery += " WHERE A1_FILIAL = '" + xFilialSA1 + "' AND AI0_FILIAL = '" + xFilial("AI0") + "' AND"
		cQuery += " SA1.D_E_L_E_T_ <> '*' AND AI0.D_E_L_E_T_ <> '*'"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cTempSA1", .T., .T.)
		
		Do While cTempSA1->(!EOF())
			If (lPadrBA .And. cTempSA1->AI0_PADRBA <> "N") .Or. !lPadrBA
				dbSelectArea("SFH")
				SFH->(dbSetOrder(3))
				SFH->(dbGoTop())
				cAgentAnt:= ""
				lFnd := .F.
				cChave := xFilial("SFH")+cTempSA1->A1_COD+cTempSA1->A1_LOJA+"IB2"+"BA"    

				nPos := aScan(aQry, {|X| aLLTRIM(X[1]) == ALLTrim(cTempSA1->A1_CGC)})

				SFH->(MsSeek(cChave))
				Do While SFH->FH_FILIAL+SFH->FH_CLIENTE+SFH->FH_LOJA+SFH->FH_IMPOSTO+SFH->FH_ZONFIS == cChave .and. SFH->(!EOF())
					If SFH->FH_FILIAL+SFH->FH_CLIENTE+SFH->FH_LOJA+SFH->FH_IMPOSTO+SFH->FH_ZONFIS == cChave
						lFnd := .T.
						nRecnoSFH:= SFH->(Recno())
						cAgentAnt:=SFH->FH_AGENTE
					EndIf
					nRecnoSFH:= SFH->(Recno())
					cAgentAnt:=SFH->FH_AGENTE		
					SFH->(MsUnlock())		
					SFH->(dbSkip())
				EndDo
			
				If lFnd .And. nPos<>0
					SFH->(DbGoto(nRecnoSFH))
					If  Val(StrTran(aQry[nPos][4],",","."))== SFH->FH_ALIQ
						RecLock("SFH",.F.)
						SFH->FH_FIMVIGE := dDataFim
						SFH->(MsUnlock())					
					Else
						lFnd := .F.	
					EndIf
				EndIf				
			
				If !lFnd .And. nPos <> 0
					crearSFH("A1",cTempSA1->A1_COD,cAgentAnt,"BA",aQry[nPos][4],aQry[nPos][2],"IB2",cTempSA1->A1_LOJA,cTempSA1->A1_NOME,"S")
						
					If lIntSynt .AND. lPosFlag .AND. lPosDtEx //Envia o cliente e a SFH para Synthesis quando integracao Synthesis esta ativa				
						If cTempSA1->A1_POSFLAG == "1"
							DBSelectArea("SA1")
							SA1->(dbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA
							SA1->(MsSeek(xFilialSA1+cTempSA1->A1_COD+cTempSA1->A1_LOJA))
							RecLock("SA1",.F.)
							SA1->A1_POSDTEX	:= ""
							SA1->(MsUnlock())
						EndIf
					EndIf		
					
				EndIf
			EndIf
			cTempSA1->(dbSkip())	
			SFH->(dbSkip())	
		EndDo
		
		cTempSA1->(dbCloseArea())
		SFH->(dbCloseArea())
		
	EndIf

	If lFor .and. (lRet .or. lPer)
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1))
		SA2->(dbGoTop())
	  	If lPer
	  		nPosSMO:= aScan(aQry, {|X| aLLTRIM(X[1])+X[3] ==ALLTrim(SM0->M0_CGC)+"P"})
			If nPosSMO>0
				nAliqP:=  Val(strtran((aQry[nPosSMO][4]),",","."))		
			EndIf	   
		   	nPosCgc:= aScan(aQry, {|X| aLLTRIM(X[1]) ==ALLTrim(SM0->M0_CGC)}) 
		EndIf
		Do While SA2->(!EOF())
			If (lPadrBA .And. SA2->A2_PADRBA <> "N") .Or. !lPadrBA
				If lRet
					dbSelectArea("SFH")
					SFH->(dbSetOrder(1))
					SFH->(dbGoTop())
					lFnd := .F.
					cAgentAnt:= ""
					cChave := xFilial("SFH")+SA2->A2_COD+SA2->A2_LOJA+"IBR"+"BA"
					nPos := aScan(aQry, {|X| aLLTRIM(X[1]) ==ALLTrim(SA2->A2_CGC)})
					If SFH->(MsSeek(cChave))
						nRecFim := MayorFech(SA2->A2_COD,SA2->A2_LOJA,"IBR",.F.)
						IF nRecFim>0
							SFH->(DbGoTo(nRecFim))
							If  nPos<>0 .And. aQry[nPos][3] == "R" 
								IF Val(strtran((aQry[nPos][4]),",","."))==SFH->FH_ALIQ
									lFnd := .T.
									RecLock("SFH", .F.)
									SFH->FH_FIMVIGE := dDataFim
									SFH->(MsUnlock())
								Else
									lFnd := .T.
									crearSFH("A2",SA2->A2_COD,SFH->FH_AGENTE,"BA",aQry[nPos][4],aQry[nPos][2],"IBR",SA2->A2_LOJA,SA2->A2_NOME,"N")	
								EndIf
							Else
									lFnd := .T.
									RecLock("SFH", .F.)
									SFH->FH_FIMVIGE := dDataFim
									SFH->(MsUnlock())
							EndIf
						EndIf
						
					EndIf
					If !lFnd .And. nPos<>0 .And. aQry[nPos][3] == "R" //no se encontro en la SFH
						crearSFH("A2",SA2->A2_COD,cAgentAnt,"BA",aQry[nPos][4],aQry[nPos][2],"IBR",SA2->A2_LOJA,SA2->A2_NOME,"N")
					EndIf
				EndIf
				If lPer .And. SA2->A2_TIPROV <> "A"
					dbSelectArea("SFH")
					SFH->(dbSetOrder(1))
					SFH->(dbGoTop())
					lFnd := .F.
					lData:= .F.
					cAgentAnt:= ""
					cChave := xFilial("SFH")+SA2->A2_COD+SA2->A2_LOJA+"IB2"+"BA"
					nPos := aScan(aQry, {|X| aLLTRIM(X[1]) == ALLTrim(SA2->A2_CGC)})
					lAchouReg := SFH->(MsSeek(cChave))
					dDtVig:=SFH->FH_FIMVIGE
					If nPosCGC > 0 
						nAliqAtu := Val(strtran((aQry[nPosSMO][4]),",","."))
					ElseIf nPos > 0
						nAliqAtu := Val(strtran((aQry[nPos][4]),",",".")) 
					EndIf
					lAtu := .F.
					Do While SFH->FH_FILIAL+SFH->FH_FORNECE+SFH->FH_LOJA+SFH->FH_IMPOSTO+SFH->FH_ZONFIS == cChave .and. SFH->(!EOF()) .and. !lAtu
						If SFH->FH_FILIAL+SFH->FH_FORNECE+SFH->FH_LOJA+SFH->FH_IMPOSTO+SFH->FH_ZONFIS == cChave
							If !Empty (SFH->FH_FIMVIGE) .and. SFH->FH_FIMVIGE >= dDtVig 
								lFnd := .T.
								nRecnoSFH:= SFH->(Recno())
								dDtVig:=SFH->FH_FIMVIGE
								cAgentAnt:=SFH->FH_AGENTE
							ElseIf Empty (SFH->FH_FIMVIGE) 
								lFnd := .F.
								nRecnoSFH:= SFH->(Recno())
								cAgentAnt:=SFH->FH_AGENTE
							ElseIf SFH->FH_INIVIGE == dDataIni  .and. SFH->FH_FIMVIGE == dDataFim  .and. SFH->FH_ALIQ == nAliqAtu
								lAtu := .T.
							EndIf
						Endif			
						SFH->(MsUnlock())		
						SFH->(dbSkip())
						
					EndDo

				IF !lAtu	
					If  nPos<>0 .And. aQry[nPos][3] == "P" .and. lAchouReg										

						nALiq1:=Val(strtran((aQry[nPos][4]),",","."))
						cAliqAux:=aQry[nPos][4]
						If nPosCGC > 0 .and. nPos > 0
							nALiq1:=Val(strtran((aQry[nPosSMO][4]),",","."))
							cAliqAux:=aQry[nPosSMO][4]
						EndIf
						If lFnd 
						SFH->(DbGoto(nRecnoSFH))
							If Empty (SFH->FH_FIMVIGE) .or. SFH->FH_FIMVIGE > dDataFim
								RecLock("SFH",.F.)							
								SFH->FH_FIMVIGE := dDataIni-1							
								SFH->(MsUnlock())						
							EndIf	
							If nALiq1 == SFH->FH_ALIQ
								RecLock("SFH",.F.)							
								SFH->FH_FIMVIGE := dDataFim							
								SFH->(MsUnlock())
							Else
								lFnd := .F.	
							EndIf
						EndIf	
						If nPosCGC<>0
							If !lFnd //.And. nALiq1 <> SFH->FH_ALIQ	 .And. nALiq1 <> 0 
								crearSFH("A2",SA2->A2_COD,cAgentAnt,"BA",cAliqAux,aQry[nPos][2],"IB2",SA2->A2_LOJA,SA2->A2_NOME,"S")	 
							EndIf
							If	!lFnd .And. nALiq1 <> SFH->FH_ALIQ	 //.AND.  nALiq1 == 0 
								crearSFH("A2",SA2->A2_COD,cAgentAnt,"BA",cAliqAux,aQry[nPos][2],"IB2",SA2->A2_LOJA,SA2->A2_NOME,"S")	 
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Endif
			SA2->(dbSkip())	
		EndDo
		SA2->(dbCloseArea())
		SFH->(dbCloseArea())
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Import   ³ Autor ³ Ivan Haponczuk      ³ Data ³ 01.06.2011 ³±±
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
Local lIntSynt		:= SuperGetMV("MV_LJSYNT",,"0") == "1"	 // Informa se a integracao Synthesis esta ativa
Local lPosFlag		:= SA1->(ColumnPos("A1_POSFLAG")) > 0
Local lPosDtEx		:= SA1->(ColumnPos("A1_POSDTEX")) > 0
Local lAchou		:= .F.
Local lFnd			:= .F.
Local cQuery		:= ""
Local xFilialSA1	:= xFilial("SA1")
Local lArq			:= .T.
Local nUltRegSFH	:= 0
Local aSFHReg		:= {}


Processa({|| lArq := GeraTemp(cFile)})

If !lArq
	Return Nil
EndIf

If lCli .and. lPer  
	cQuery := "SELECT A1_COD, A1_LOJA, A1_CGC, A1_NOME," + IIf(lPosFlag, " A1_POSFLAG, AI0_PADRBA", " AI0_PADRBA")
	cQuery += " FROM " + RetSqlName("SA1") + " SA1 INNER JOIN " + RetSqlName("AI0") + " AI0" + " ON A1_COD = AI0_CODCLI AND A1_LOJA = AI0_LOJA"
	cQuery += " WHERE A1_FILIAL = '" + xFilialSA1 + "' AND AI0_FILIAL = '" + xFilial("AI0") + "' AND"
	cQuery += " SA1.D_E_L_E_T_ <> '*' AND AI0.D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cTempSA1", .T., .T.)
		
	Do While cTempSA1->(!EOF())
		If !Empty(cTempSA1->A1_CGC)
			If (lPadrBA .And. cTempSA1->AI0_PADRBA <> "N") .Or. !lPadrBA
				// Atualiza o cadastro de percepcao do cliente
				dbSelectArea("SFH")
				SFH->(dbSetOrder(3))
				SFH->(dbGoTop())
				cChave := xFilial("SFH")+cTempSA1->A1_COD+cTempSA1->A1_LOJA+"IB2"+"BA"
				nUltRegSFH := 0
				If SFH->(MsSeek(cChave))
					nUltRegSFH := UltRegSFH("C",cChave)
				EndIf
				
				If TMP->(MsSeek("P"+cTempSA1->A1_CGC))
					
					lAchou := .F.
					nPos := aScan(aQry, {|X| aLLTRIM(X[1]) == ALLTrim(cTempSA1->A1_CGC)})								
					If nUltRegSFH > 0
						SFH->(DbGoto(nUltRegSFH))
						nAliq := Val(StrTran(TMP->ALIQ,",",".")) //***
						If nAliq == SFH->FH_ALIQ
							lAchou := .T.
							If RecLock("SFH", .F.)
								SFH->FH_FIMVIGE := dDataFim
								SFH->(MsUnlock())												
								If lIntSynt .AND. lPosFlag .AND. lPosDtEx //Envia o cliente e a SFH para Synthesis quando integracao Synthesis esta ativa				
									If cTempSA1->A1_POSFLAG == "1"
										RecLock("SA1",.F.)
										SA1->A1_POSDTEX	:= ""
										SA1->(MsUnlock())	
									EndIf
								EndIf																					
							EndIf
						Else
							lAchou := .T.
							crearSFH("A1",cTempSA1->A1_COD,"S","BA",TMP->ALIQ,TMP->TIPO1,"IB2",cTempSA1->A1_LOJA,cTempSA1->A1_NOME,"S")
						EndIf
					EndIf
					If !lAchou
					
						crearSFH("A1",cTempSA1->A1_COD,"S","BA",TMP->ALIQ,TMP->TIPO1,"IB2",cTempSA1->A1_LOJA,cTempSA1->A1_NOME,"S")
						
							If lIntSynt .AND. lPosFlag .AND. lPosDtEx //Envia o cliente e a SFH para Synthesis quando integracao Synthesis esta ativa				
								If cTempSA1->A1_POSFLAG == "1"
									DBSelectArea("SA1")
									SA1->(dbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA
									SA1->(MsSeek(xFilialSA1+cTempSA1->A1_COD+cTempSA1->A1_LOJA))
									RecLock("SA1",.F.)
									SA1->A1_POSDTEX	:= ""
									SA1->(MsUnlock())
								EndIf
							EndIf
						
					EndIf
				Else
					If nUltRegSFH > 0
						SFH->(DbGoto(nUltRegSFH))
						If SFH->FH_FIMVIGE >= dDataIni
							If RecLock("SFH", .F.)
								SFH->FH_FIMVIGE := dDataIni
								SFH->(MsUnlock())
							EndIf
						EndIf
					EndIf
				EndIf
				SFH->(dbCloseArea())
			EndIf
		EndIf
		cTempSA1->(dbSkip())
	EndDo
	cTempSA1->(dbCloseArea())
EndIf

If lFor .and. (lRet .or. lPer)
	nAlqPer	:= 0
	dbSelectArea("SA2")
	SA2->(dbSetOrder(3))
	SA2->(dbGoTop())
	If TMP->(MsSeek("P"+SM0->M0_CGC))
		aLinP := {TMP->REGIMEN,TMP->FECHA,TMP->FCHINI,TMP->FCHFIN,TMP->CUIT,TMP->TIPO1,TMP->TIPO2,TMP->TIPO3,TMP->ALIQ,TMP->PORC}	
	EndIf
	lAchouP := .F.
	If Len(aLinP)>0
		nAlqPer := Val(StrTran(aLinP[_POSALQPER],",","."))
		lAchouP := .T.
	EndiF
	Do While SA2->(!EOF())
		If (lPadrBA .And. SA2->A2_PADRBA <> "N") .Or. !lPadrBA
			// Atualiza cadastro de percepcao do fornecedor
			If lPer
				nAliq := nAlqPer
				dbSelectArea("SFH")
				SFH->(dbSetOrder(1))
				SFH->(dbGoTop())
				cChave := xFilial("SFH")+SA2->A2_COD+SA2->A2_LOJA+"IB2"+"BA"
				nUltRegSFH := 0
				If SFH->(MsSeek(cChave))
					nUltRegSFH := UltRegSFH("P",cChave)
				EndIf
				If Len(aLinP) > 0 .and. UPPER(aLinP[1]) == 'P'  //Solo actualiza si el registro a procesar es P=Percepcion
					lAchou := .F.
					If nUltRegSFH > 0
						SFH->(DbGoto(nUltRegSFH))
						If nAliq == SFH->FH_ALIQ
							lAchou := .T.
							If RecLock("SFH", .F.)
								SFH->FH_FIMVIGE := dDataFim
								SFH->(MsUnlock())
							EndIf
						Else
							lAchou := .T.
							crearSFH("A2",SA2->A2_COD,SFH->FH_AGENTE,"BA",aLinP[_POSALQPER],SFH->FH_TIPO,"IB2",SA2->A2_LOJA,SA2->A2_NOME,SFH->FH_APERIB)
						EndIf
					EndIf
				Else
					If nUltRegSFH > 0
						SFH->(DbGoto(nUltRegSFH))
						If SFH->FH_FIMVIGE >= dDataIni .Or. Empty(SFH->FH_FIMVIGE)
							If RecLock("SFH", .F.)
								SFH->FH_FIMVIGE := dDataIni
								SFH->(MsUnlock())
							EndIf
						EndIf
					EndIf
				Endif
				SFH->(dbCloseArea())
			EndIf
			// Atuliza cadastro de retencao do fornecedor
			If !Empty(SA2->A2_CGC)
				If lRet
					dbSelectArea("SFH")
					SFH->(dbSetOrder(1))
					SFH->(dbGoTop())
					cChave := xFilial("SFH")+SA2->A2_COD+SA2->A2_LOJA+"IBR"+"BA"
					nUltRegSFH := 0
					If SFH->(MsSeek(cChave))
						nUltRegSFH := UltRegSFH("P",cChave)
					EndIf
					If TMP->(MsSeek("R"+SA2->A2_CGC))      
						lAchou := .F.
						If nUltRegSFH > 0
							lAchou := .T.
							SFH->(DbGoto(nUltRegSFH))
							nAliq := Val(StrTran(TMP->ALIQ,",","."))
							If nAliq == SFH->FH_ALIQ
								If RecLock("SFH", .F.)
									SFH->FH_FIMVIGE := dDataFim
									SFH->(MsUnlock())
								EndIf
							Else
								crearSFH("A2",SA2->A2_COD,SFH->FH_AGENTE,"BA",TMP->ALIQ,SFH->FH_TIPO,"IBR",SA2->A2_LOJA,SA2->A2_NOME,SFH->FH_APERIB)
							EndIf
						Else
							    crearSFH("A2",SA2->A2_COD,"N","BA",TMP->ALIQ,TMP->TIPO1,"IBR",SA2->A2_LOJA,SA2->A2_NOME,"N")
						EndIf
					Else
						If nUltRegSFH > 0
							SFH->(DbGoto(nUltRegSFH))
							If SFH->FH_FIMVIGE >= dDataIni .Or. Empty(SFH->FH_FIMVIGE)
								If RecLock("SFH", .F.)
									SFH->FH_FIMVIGE := dDataIni
									SFH->(MsUnlock())
								EndIf
							EndIf
						EndIf
					EndIf
					SFH->(dbCloseArea())
				EndIf
			Endif
		EndIf
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
±±³Funcao    ³ TXTSeek  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 16.06.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a busca do CGC informado no arquivo tambem informado   ³±±
±±³          ³ atraves do metodo de busca binaria, para a utilizacao      ³±±
±±³          ³ desse metodo de busca o arquivo deve estar ordenado por    ³±±
±±³          ³ CGC em ordem crescente.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Local e nome do arquivo a ser feita a busca.      ³±±
±±³          ³ cPar02 - CGC a ser buscado no arquivo.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet - Vetor contendo as informacoes da linha encontrada   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TXTSeek(cFile, cCGC, cRegimen)

Local nPri    := 0
Local nUlt    := 0
Local nMeio   := 0
Local nCGC    := 0
Local aLin    := {}
Local lFnd    := .F.
Local nReg1   := 0
Local nReg2   := 0 
Local aLinIni := 0
Local aLinFin := 0

nCGC := Val(cCGC)
FT_FUSE(cFile)
nPri := 1
nUlt := FT_FLASTREC()

//Excepcion: Que el CUIT no este en el archivo
ft_FSkip(0)   
aLinIni := Separa(FT_FREADLN(),_SEPARADOR)  
ft_FSkip(nUlt-1)
aLinFin := Separa(FT_FREADLN(),_SEPARADOR)   
If nCGC < Val(aLinIni[_POSCGC]) .Or. nCGC > Val(aLinFin[_POSCGC]) 
	Return aLin
Endif
ft_FGoTop()                                

Do While !lFnd

		// Verifica se e o ultimo
	ft_FGoTop()
	ft_FSkip(nUlt-1)
	nReg1:= nUlt-1 
	aLin := Separa(FT_FREADLN(),_SEPARADOR)
	If nCGC == Val(aLin[_POSCGC]) .And. ( cRegimen == Alltrim(aLin[_POSREG]) .oR. Empty(cRegimen))
		lFnd := .T.
	EndIf

	// Verifica se e maior ou menor
	If !lFnd
		nMeio := Round(((nUlt-(nPri-1))/2),0)
		nMeio += (nPri-1)
		ft_FGoTop()
		ft_FSkip(nMeio-1)
		nReg2:= nMeio-1 			
		aLin := Separa(FT_FREADLN(),_SEPARADOR)
		If nCGC == Val(aLin[_POSCGC]) .And. cRegimen == Alltrim(aLin[_POSREG])
			lFnd := .T.
		Else
			If nCGC <= Val(aLin[_POSCGC])
				nUlt := nMeio
			Else
				nPri := nMeio
			EndIf
		EndIf
	EndIf

		// Se nao existir no arquivo
	If !lFnd .And. (nMeio == 1 .Or. ((nCGC > Val(aLin[_POSCGC]) .And. (nReg1-nReg2) == 1) .Or. (nReg1-nReg2) == 0))
		aLin := {}
		Exit
	EndIf
EndDo
FT_FUSE()

Return aLin

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³typeErrSQL³ Autor ³ Marco A. Gonzalez   ³ Data ³ 24/02/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Procesa el tipo de error retornado al utilizar la funcion  ³±±
±±³          ³ TCSqlError().                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ N/A                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cTypeError - Retorna el tipo de error retornado por SQL    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function typeErrSQL(cTypeError)

Local cCodeError	:= ""
	
cCodeError := AllTrim(SubStr(cTypeError, 9, 5))

Return cCodeError



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
Local cMsg		 := STR0024 //"Leyendo archivo. Espere..."  
Local cBuffer    := ""
Local aArea      := ""
Local cTitulo	 := STR0001  //"Problemas en la importación del archivo"
Local lSig       := .T.		// Determina a continuidade do processamento como base nas informacoes da tela de Wizard
Local nTimer 	:= seconds()
Local cQuery	:= "" 
Local cNomeTab	:= ""
Local lOk		:= ""
Local cCGCEmp	:= AllTrim(SM0->M0_CGC)
Local nCGCEmp	:= Val(AllTrim(SM0->M0_CGC))
Local nPosCGC	:= 0
Local lCGC		:= .T.
Local cQueryA1	:= ""
Local cQueryA2	:= ""
Local lPosFlag		:= SA1->(ColumnPos("A1_POSFLAG")) > 0
Local lPosDtEx		:= SA1->(ColumnPos("A1_POSDTEX")) > 0
Local xFilialSA1	:= xFilial("SA1")
Local xFilialSA2	:= xFilial("SA2")
Local nPosCli		:= 0
Local nPosFor		:= 0
Local nCuitCli		:= 0
Local nCuitFor		:= 0
Local nPrimer		:= 0
Local nUltimo		:= 0
Local nTamCgc		:= TAMSX3("A2_CGC")[1]
Local nRegs			:= 0 
Local nTotal		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o arquivo temporario para a importacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//*************Modelo do arquivo*************
//REGIMEN;		FECHA;	Fecha Inicio;	Fecha Fin;			Cuit;	Tipo1;	Tipo2;	Tipo3;	Aliquota;	Porcentaje;
//		P;	25022019;		01032019;	31032019;	30696124422;		C;		N;		N;		6,00;			25;
AADD(aCampos,{"REGIMEN"	  ,"C",1,0})
AADD(aCampos,{"FECHA"	  ,"C",8,0})
AADD(aCampos,{"FCHINI"	  ,"C",8,0})
AADD(aCampos,{"FCHFIN"	  ,"C",8,0})
AADD(aCampos,{"CUIT"	  ,"C",11,0})
AADD(aCampos,{"TIPO1"	  ,"C",1,0})
AADD(aCampos,{"TIPO2"	  ,"C",1,0})
AADD(aCampos,{"TIPO3"	  ,"C",1,0})
AADD(aCampos,{"ALIQ"	  ,"C",6,0})
AADD(aCampos,{"PORC"	  ,"C",6,0})

oTmpTable := FWTemporaryTable():New("TMP")
oTmpTable:SetFields( aCampos )
aOrdem	:=	{"REGIMEN", "CUIT"}

oTmpTable:AddIndex("TMP", aOrdem)
oTmpTable:Create()

	If lCli .and. lPer  
		cQueryA1 := "SELECT A1_COD, A1_LOJA, A1_CGC, A1_NOME," + IIf(lPosFlag, " A1_POSFLAG, AI0_PADRBA", " AI0_PADRBA")
		cQueryA1 += " FROM " + RetSqlName("SA1") + " SA1 INNER JOIN " + RetSqlName("AI0") + " AI0" + " ON A1_COD = AI0_CODCLI AND A1_LOJA = AI0_LOJA"
		cQueryA1 += " WHERE A1_FILIAL = '" + xFilialSA1 + "' AND AI0_FILIAL = '" + xFilial("AI0") + "' AND"
		cQueryA1 += " SA1.D_E_L_E_T_ <> '*' AND AI0.D_E_L_E_T_ <> '*'"
		cQueryA1 += " ORDER BY A1_CGC ASC"
		cQueryA1 := ChangeQuery(cQueryA1)
		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQueryA1), "cSA1", .T., .T.)
		cSA1->(dbGoTop())
		count to nRegs
		cSA1->(dbGoTop())
		nTotal += nRegs
	EndIf
	
	If lFor	.and. lRet
		cQueryA2 := "SELECT A2_COD, A2_LOJA, A2_CGC, A2_NOME"
		cQueryA2 += " FROM " +  RetSqlName("SA2")  + " SA2"
		cQueryA2 += " WHERE"
		cQueryA2 += " A2_CGC <> '' AND"
		If lPadrBA
			cQueryA2 += " A2_PADRBA <> 'N' AND" 
		EndIf 
		cQueryA2 += " D_E_L_E_T_ <> '*' "
		cQueryA2 += " ORDER BY A2_CGC ASC"
		cQueryA2 := ChangeQuery(cQueryA2)
		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQueryA2), "cSA2", .T., .T.)
		cSA2->(dbGoTop())
		count to nRegs
		cSA2->(dbGoTop())
		nTotal += nRegs
	EndIf
	
	If File(cArqProc) .And. lSig
	
		nHandle := FT_FUse(cArqProc)
		
		If  nHandle > 0 
			//Se posiciona en la primera línea
			FT_FGoTop()
			nFor := FT_FLastRec()	
			FT_FUSE()	
		Else
			lArqValido := .F.	
			cErro	   := STR0037 + cArqProc + STR0038	//"El archivo " +cArqProc+ "No puede abrirse"
			cSolucao   := STR0045 			//"Verifique si se informó el archivo correcto para importación"
		EndIf
	
		If lArqValido 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gera arquivo temporario a partir do arquivo XLS ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oFile := ZFWReadTXT():New(cArqProc,,_BUFFER)
			// Se hay error al abrir el archivo
			If !oFile:Open()
				MsgAlert(STR0037 + cArqProc + STR0038)  //"El archivo " +cArqProc+ "No puede abrirse"
				Return .F.
			EndIf
			
			//ProcRegua(nFor)
			ProcRegua(nTotal)
			While oFile:ReadBlock(@aInforma,_SEPARADOR)
			 	//nI := nI + Len(aInforma)
			 	IncProc(cMsg + str(nI))
			 	nPrimer := Val(aInforma[1][5])
			 	nUltimo := Val(aInforma[Len(aInforma)][5])
			 				 	
			 	If lFor .and. lPer .and. lCGC .and. (nPrimer <= nCGCEmp .and. nUltimo >= nCGCEmp)
			 		nPosCGC :=  ascan(aInforma,{|x| x[5] == cCGCEmp })
			 		If nPosCGC > 0
			 			TMP->( DBAppend() )
			  	  		TMP->REGIMEN	:= aInforma[nPosCGC][_POSREG]
			  	  		TMP->FECHA		:= aInforma[nPosCGC][_POSDATA]
			  	  		TMP->FCHINI		:= aInforma[nPosCGC][_POSDATINI]
			  	  		TMP->FCHFIN		:= aInforma[nPosCGC][_POSDATFIN]
			  	  		TMP->CUIT		:= aInforma[nPosCGC][_POSCGC]
			  	  		TMP->TIPO1		:= aInforma[nPosCGC][_POSTIPO1]
			  	  		TMP->TIPO2		:= aInforma[nPosCGC][_POSTIPO2]
			  	  		TMP->TIPO3		:= aInforma[nPosCGC][_POSTIPO3] 
			  	  		TMP->ALIQ		:= aInforma[nPosCGC][_POSALQPER]
			  	  		TMP->PORC		:= aInforma[nPosCGC][_POSPORC]
						TMP->( DBCommit() )	
			 		EndIf
			 		lCGC := .F.
			 	EndIf
				
				If lCli .and. lPer
					While cSA1->(!EOF())
						nCuitCli := Val(AllTrim(cSA1->A1_CGC))
						If (nPrimer <= nCuitCli .and. nUltimo >= nCuitCli)
							nPosCli :=  ascan(aInforma,{|x| x[5] == AllTrim(cSA1->A1_CGC) })
							If nPosCli > 0
								TMP->( DBAppend() )
					  	  		TMP->REGIMEN	:= aInforma[nPosCli][_POSREG]
					  	  		TMP->FECHA		:= aInforma[nPosCli][_POSDATA]
					  	  		TMP->FCHINI		:= aInforma[nPosCli][_POSDATINI]
					  	  		TMP->FCHFIN		:= aInforma[nPosCli][_POSDATFIN]
					  	  		TMP->CUIT		:= aInforma[nPosCli][_POSCGC]
					  	  		TMP->TIPO1		:= aInforma[nPosCli][_POSTIPO1]
					  	  		TMP->TIPO2		:= aInforma[nPosCli][_POSTIPO2]
					  	  		TMP->TIPO3		:= aInforma[nPosCli][_POSTIPO3] 
					  	  		TMP->ALIQ		:= aInforma[nPosCli][_POSALQPER]
					  	  		TMP->PORC		:= aInforma[nPosCli][_POSPORC]
								TMP->( DBCommit() )	
							EndIf
							cSA1->(dbSkip())
							nI ++
						ElseIf nCuitCli >= nUltimo
							Exit
						ElseIf nPrimer >= nCuitCli
							cSA1->(dbSkip())
							nI ++
						EndIf
					Enddo
				EndIf
				
				If lFor .and. lRet
					While cSA2->(!EOF())
						nCuitFor := Val(AllTrim(cSA2->A2_CGC))
						If (nPrimer <= nCuitFor .and. nUltimo >= nCuitFor)
							nPosFor :=  ascan(aInforma,{|x| x[5] == AllTrim(cSA2->A2_CGC) })
							If nPosFor > 0
								TMP->( DBAppend() )
					  	  		TMP->REGIMEN	:= aInforma[nPosFor][_POSREG]
					  	  		TMP->FECHA		:= aInforma[nPosFor][_POSDATA]
					  	  		TMP->FCHINI		:= aInforma[nPosFor][_POSDATINI]
					  	  		TMP->FCHFIN		:= aInforma[nPosFor][_POSDATFIN]
					  	  		TMP->CUIT		:= aInforma[nPosFor][_POSCGC]
					  	  		TMP->TIPO1		:= aInforma[nPosFor][_POSTIPO1]
					  	  		TMP->TIPO2		:= aInforma[nPosFor][_POSTIPO2]
					  	  		TMP->TIPO3		:= aInforma[nPosFor][_POSTIPO3] 
					  	  		TMP->ALIQ		:= aInforma[nPosFor][_POSALQPER]
					  	  		TMP->PORC		:= aInforma[nPosFor][_POSPORC]
								TMP->( DBCommit() )	
							EndIf
							cSA2->(dbSkip())
							nI ++
						ElseIf nCuitFor >= nUltimo
							Exit
						ElseIf nPrimer >= nCuitFor
							cSA2->(dbSkip())
							nI ++
						EndIf
					Enddo
				EndIf
					
				aSize(aInforma,0)	
			Enddo
		Endif	
		
		If lCli .and. lPer
			cSA1->(dbCloseArea())
		EndIf
		
		If lFor .and. lRet
			cSA2->(dbCloseArea())
		EndIf
		
		oFile:Close()	 // Fecha o Arquivo
	
		If Empty(cErro) .and. TMP->(LastRec())==0     
			cErro		:= STR0045	//"La importación no se realizó por no existir información en el archivo informado."
			cSolucao	:= STR0047	//"Verifique se foi informado o arquivo correto para importação"
		Endif	
	Else
		cErro	   := STR0037 + cArqProc + STR0038	//"El archivo " +cArqProc+ "No puede abrirse"
		cSolucao   := STR0045 						//"Verifique se foi informado o arquivo correto para importação"
	EndIf
		 
	If !Empty(cErro)
		xMagHelpFis(cTitulo,cErro,cSolucao)
		lSig := .F.
	Endif

Return(lSig) 

Static Function UltRegSFH(cOrig,cChave)
Local nReg := 0
Local dDataFn := CTOD("//")


	Do While IIf(cOrig == "C",SFH->FH_FILIAL+SFH->FH_CLIENTE+SFH->FH_LOJA+SFH->FH_IMPOSTO+SFH->FH_ZONFIS,;
				SFH->FH_FILIAL+SFH->FH_FORNECE+SFH->FH_LOJA+SFH->FH_IMPOSTO+SFH->FH_ZONFIS)  == cChave .and. SFH->(!EOF())
		
		If SFH->FH_FIMVIGE > dDataFn .or. Empty (dDataFn)
			nReg := SFH->(Recno())
			dDataFn := SFH->FH_FIMVIGE
		EndIf
		
		SFH->(DbSkip())
	Enddo
Return nReg

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ SeperaTXT³ Autor ³ Danilo Santos       ³ Data ³ 05/06/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Separa la linea ingresada por las posiciones indicadas     ³±±
±±³Parametros³ cLinea = Indica la linea a separar                         ³±±
±±³Retorno   ³ aDatos - Contiene los datos separados                      ³±±
±±³Uso       ³ Fiscal - Argentina			                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
/*/

Static Function SeperaTXT(cLinea)
Local aPoscio := {1,8,8,8,11,1,1,1,6,6}
Local nI := 0
Local nCont := 1
Local nTxt := 0
Local aDatos := {}

	For nI = 1 To Len(aPoscio)
		If nI == 9 .Or. nI == 10 
			nTxt := AT( ";", Substr(cLinea, nCont, aPoscio[nI] )) -1
		Else
			nTxt :=  aPoscio[nI]
		Endif
		AADD(aDatos,Substr(cLinea, nCont, nTxt))
		If nI == 9 .Or. nI == 10 
			nCont += nTxt + 1
		Else
			nCont += aPoscio[nI] + 1
		Endif	
	Next

Return aDatos
/*/{Protheus.doc} crearSFH
	@author Adrian Perez Hernandez
	@since 30/06/2021

	@param cCOD, string, codigo del campo A1_COD O A2_COD
	@param cLoja, string, valor para el campo FH_LOJA
	@param cImposto, string, valor para el campo FH_IMPOSTO (IBR o IB2)
	@param lTabla, boleano, .T. indica que se use campo FH_CLIENTE, .F. indica que se use campo FH_FORNECE
	@return nil

	/*/
Static Function MayorFech(cCod,cLoja,cImpuesto,lTabla)


	Local nAux :=0
	Local cTabla :=""
	Local cAlias:=  GetNextAlias()
	Local nRegs:=0

	Iif(lTabla,cTabla:="FH_CLIENTE",cTabla:="FH_FORNECE")
	cQuery	:= ""
	cQuery := "SELECT (CASE WHEN FH_FIMVIGE='' THEN '20991231' ELSE  FH_FIMVIGE END) max_fecha,R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("SFH")
	cQuery += " WHERE FH_FILIAL = '" + xFilial("SFH") + "'"
	cQuery += " AND "+cTabla+" = '"+cCod+"'"
	cQuery += " AND FH_LOJA ='"+cLoja+"'"
	cQuery += " AND FH_IMPOSTO ='"+cImpuesto+"'"
	cQuery += " AND FH_ZONFIS ='BA'"
	cQuery += " AND D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY max_fecha DESC"

	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery),cAlias, .T., .T.)

	IF (cAlias)->(!EOF())
		(cAlias)->(dbGoTop())
		nAux:=(cAlias)->R_E_C_N_O_ 
		(cAlias)->(dbCloseArea())
	EndIf

Return nAux

/*/{Protheus.doc} crearSFH
	@author Adrian Perez Hernandez
	@since 30/06/2021
	@param cTable, string, indica que tabla se va usar A1 o A2
	@param cCOD, string, codigo del campo A1_COD O A2_COD
	@param cAgentAnt, string, valor para el campo FH_AGENTE
	@param cAliq, string, alicuota proveniente del padron(txt) sin formato a numero 
	@param cTipo, string, valor para el campo FH_TIPO
	@param cImposto, string, valor para el campo FH_IMPOSTO (IBR o IB2)
	@param cLoja, string, valor para el campo FH_LOJA
	@param cNome, string, valor para el campo FH_NOME
	@return return_var, return_type, return_description

	/*/
Function crearSFH(cTable,cCOD,cAgentAnt,cProv,cAliq,cTipo,cImposto,cLoja,cNome,cAPERIB)

Local lCodSFH := .T.
Local cPrefixo := "->"+cTable+"_"
cTable :="S"+cTable

	If Empty(cCOD)
		lCodSFH := .F.
	EndIf

	If RecLock("SFH", .T.)
		SFH->FH_FILIAL  := xFilial("SFH")
		If cAgentAnt == ""
			SFH->FH_AGENTE  := "N"
		Else 
			SFH->FH_AGENTE  := cAgentAnt
		EndIf
			SFH->FH_ZONFIS  := cProv
		If cTable == "SA2"
			SFH->FH_FORNECE := IIf(lCodSFH, cCOD , &(cTable+cPrefixo+"COD"))
		Else
			SFH->FH_CLIENTE	:= IIf(lCodSFH, cCOD , &(cTable+cPrefixo+"COD"))
		EndIf
		SFH->FH_LOJA	:=  cLoja
		SFH->FH_NOME    :=  cNome
		SFH->FH_IMPOSTO := cImposto	
		SFH->FH_PERCIBI := "S"	
		SFH->FH_ISENTO  := "N"
		SFH->FH_APERIB  := cAPERIB
		SFH->FH_ALIQ    :=Val(strtran((cAliq),",",".")) 
		
		If SFH->FH_ALIQ == 0
			SFH->FH_PERCENT	:= 100
			SFH->FH_ISENTO  := "N"
		Else	
			SFH->FH_PERCENT	:= 0
		EndIF
		SFH->FH_COEFMUL := 0
		SFH->FH_INIVIGE := dDataIni
		SFH->FH_FIMVIGE := dDataFim
		If cTipo=="C"//aQry[nPos][2]=="C"
			SFH->FH_TIPO := "V"
		Else 
			SFH->FH_TIPO := "I"
		EndIf	
		MsUnlock()
	EndIf
	
Return 
/*/{Protheus.doc} FISA026AUT
	funcion utilizada en la automatizacion de la fisa026
	@type  void
	@author Adrian Perez Hernandez
	@since 02/07/2021
	@version version 1
	@param cArchivo,caracter,ruta del padron a cargar.
	@param cCombo,caracter,indica si es cliente proveedor o ambos("1- Proveedor","2- Cliente","3- Ambos" )
	@return nil, nil, no retorna nada
	/*/
Function FIS026AUT(cArchivo,cCombo)
	Private cFileAut:=cArchivo
	Private lPadrBA	:= AI0->(ColumnPos("AI0_PADRBA")) > 0 .And. SA2->(ColumnPos("A2_PADRBA")) > 0
	Private aQry := {}
	Private aCombo:={}

	aAdd( aCombo, "1- Proveedor" ) //"1- Fornecedor"
	aAdd( aCombo, "2- Cliente" ) //"2- Cliente"
	aAdd( aCombo, "3- Ambos" ) //"3- Ambos"

	IF FILE(cArchivo)
		ImpArq(aCombo,cCombo)
	EndIf
Return nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Import2   ³ Autor ³ Alejandro Parrales ³ Data ³ 15.12.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza la creacion y actualizacion de registros de la     ³±±
±±³          ³ tabla SFH para las bases de datos ORACLE-POSTGRES          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                         .          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina - ARBA -POSTGRES/ORACLE    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Import2()

	Local nAliq			:= 0
	Local nAlqPer		:= 0
	Local aLin			:= {}
	Local cChave		:= ""
	Local aLinP			:= {}
	Local lIntSynt		:= SuperGetMV("MV_LJSYNT",,"0") == "1"	 // Informa se a integracao Synthesis esta ativa
	Local lPosFlag		:= SA1->(ColumnPos("A1_POSFLAG")) > 0
	Local lPosDtEx		:= SA1->(ColumnPos("A1_POSDTEX")) > 0
	Local lAchou		:= .F.
	Local cQuery		:= ""
	Local xFilialSA1	:= xFilial("SA1")
	Local nUltRegSFH	:= 0
	Local cIndex 		:= ""
	Local TMP := "PADRONARBA"

	If Select(TMP) == 0
		DbUseArea(.T.,"TOPCONN",TMP,TMP,.T.)
		cIndex := TMP+"1"
		If ( !MsFile(TMP,cIndex, "TOPCONN") )
			DbCreateIndex(cIndex,"REGIMEN+CUIT",{|| "REGIMEN+CUIT" })
		EndIf
		Set Index to (cIndex)
	EndIf
	DbSelectArea(TMP)
	
	If lCli .and. lPer  
		cQuery := "SELECT A1_COD, A1_LOJA, A1_CGC, A1_NOME," + IIf(lPosFlag, " A1_POSFLAG, AI0_PADRBA", " AI0_PADRBA")
		cQuery += " FROM " + RetSqlName("SA1") + " SA1 INNER JOIN " + RetSqlName("AI0") + " AI0" + " ON A1_COD = AI0_CODCLI AND A1_LOJA = AI0_LOJA"
		cQuery += " WHERE A1_FILIAL = '" + xFilialSA1 + "' AND AI0_FILIAL = '" + xFilial("AI0") + "' AND"
		cQuery += " SA1.D_E_L_E_T_ <> '*' AND AI0.D_E_L_E_T_ <> '*'"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cTempSA1", .T., .T.)
			
		Do While cTempSA1->(!EOF())
			If !Empty(cTempSA1->A1_CGC)
				If (lPadrBA .And. cTempSA1->AI0_PADRBA <> "N") .Or. !lPadrBA
					// Atualiza o cadastro de percepcao do cliente
					dbSelectArea("SFH")
					SFH->(dbSetOrder(3))
					SFH->(dbGoTop())
					cChave := xFilial("SFH")+cTempSA1->A1_COD+cTempSA1->A1_LOJA+"IB2"+"BA"
					nUltRegSFH := 0
					If SFH->(MsSeek(cChave))
						nUltRegSFH := UltRegSFH("C",cChave)
					EndIf
					
					If (TMP)->(MsSeek("P"+cTempSA1->A1_CGC))
						
						lAchou := .F.
						nPos := aScan(aQry, {|X| aLLTRIM(X[1]) == ALLTrim(cTempSA1->A1_CGC)})								
						If nUltRegSFH > 0
							SFH->(DbGoto(nUltRegSFH))
							nAliq := Val(StrTran((TMP)->ALIQUOTA,",",".")) //***
							If nAliq == SFH->FH_ALIQ
								lAchou := .T.
								If RecLock("SFH", .F.)
									SFH->FH_FIMVIGE := dDataFim
									SFH->(MsUnlock())												
									If lIntSynt .AND. lPosFlag .AND. lPosDtEx //Envia o cliente e a SFH para Synthesis quando integracao Synthesis esta ativa				
										If cTempSA1->A1_POSFLAG == "1"
											RecLock("SA1",.F.)
											SA1->A1_POSDTEX	:= ""
											SA1->(MsUnlock())	
										EndIf
									EndIf																					
								EndIf
							Else
								lAchou := .T.
								crearSFH("A1",cTempSA1->A1_COD,"S","BA",(TMP)->ALIQUOTA,(TMP)->TIPO1,"IB2",cTempSA1->A1_LOJA,cTempSA1->A1_NOME,"S")
							EndIf
						EndIf
						If !lAchou
						
							crearSFH("A1",cTempSA1->A1_COD,"S","BA",(TMP)->ALIQUOTA,(TMP)->TIPO1,"IB2",cTempSA1->A1_LOJA,cTempSA1->A1_NOME,"S")
							
								If lIntSynt .AND. lPosFlag .AND. lPosDtEx //Envia o cliente e a SFH para Synthesis quando integracao Synthesis esta ativa				
									If cTempSA1->A1_POSFLAG == "1"
										DBSelectArea("SA1")
										SA1->(dbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA
										SA1->(MsSeek(xFilialSA1+cTempSA1->A1_COD+cTempSA1->A1_LOJA))
										RecLock("SA1",.F.)
										SA1->A1_POSDTEX	:= ""
										SA1->(MsUnlock())
									EndIf
								EndIf
							
						EndIf
					Else
						If nUltRegSFH > 0
							SFH->(DbGoto(nUltRegSFH))
							If SFH->FH_FIMVIGE >= dDataIni
								If RecLock("SFH", .F.)
									SFH->FH_FIMVIGE := dDataIni
									SFH->(MsUnlock())
								EndIf
							EndIf
						EndIf
					EndIf
					SFH->(dbCloseArea())
				EndIf
			EndIf
			cTempSA1->(dbSkip())
		EndDo
		cTempSA1->(dbCloseArea())
	EndIf

	If lFor .and. (lRet .or. lPer)
		nAlqPer	:= 0
		dbSelectArea("SA2")
		SA2->(dbSetOrder(3))
		SA2->(dbGoTop())
		If (TMP)->(MsSeek("P"+SM0->M0_CGC))
			aLinP := {(TMP)->REGIMEN,(TMP)->FECHA1,(TMP)->FECHA2,(TMP)->FECHA3,(TMP)->CUIT,(TMP)->TIPO1,(TMP)->TIPO2,(TMP)->TIPO3,(TMP)->ALIQUOTA,(TMP)->PORC}	
		EndIf
		lAchouP := .F.
		If Len(aLinP)>0
			nAlqPer := Val(StrTran(aLinP[_POSALQPER],",","."))
			lAchouP := .T.
		EndiF
		Do While SA2->(!EOF())
			If (lPadrBA .And. SA2->A2_PADRBA <> "N") .Or. !lPadrBA
				// Atualiza cadastro de percepcao do fornecedor
				If lPer
					nAliq := nAlqPer
					dbSelectArea("SFH")
					SFH->(dbSetOrder(1))
					SFH->(dbGoTop())
					cChave := xFilial("SFH")+SA2->A2_COD+SA2->A2_LOJA+"IB2"+"BA"
					nUltRegSFH := 0
					If SFH->(MsSeek(cChave))
						nUltRegSFH := UltRegSFH("P",cChave)
					EndIf
					If Len(aLinP) > 0 .and. UPPER(aLinP[1]) == 'P'  //Solo actualiza si el registro a procesar es P=Percepcion
						lAchou := .F.
						If nUltRegSFH > 0
							SFH->(DbGoto(nUltRegSFH))
							If nAliq == SFH->FH_ALIQ
								lAchou := .T.
								If RecLock("SFH", .F.)
									SFH->FH_FIMVIGE := dDataFim
									SFH->(MsUnlock())
								EndIf
							Else
								lAchou := .T.
								crearSFH("A2",SA2->A2_COD,SFH->FH_AGENTE,"BA",aLinP[_POSALQPER],SFH->FH_TIPO,"IB2",SA2->A2_LOJA,SA2->A2_NOME,SFH->FH_APERIB)
							EndIf
						EndIf
					Else
						If nUltRegSFH > 0
							SFH->(DbGoto(nUltRegSFH))
							If SFH->FH_FIMVIGE >= dDataIni .Or. Empty(SFH->FH_FIMVIGE)
								If RecLock("SFH", .F.)
									SFH->FH_FIMVIGE := dDataIni
									SFH->(MsUnlock())
								EndIf
							EndIf
						EndIf
					Endif
					SFH->(dbCloseArea())
				EndIf
				// Atuliza cadastro de retencao do fornecedor
				If !Empty(SA2->A2_CGC)
					If lRet
						dbSelectArea("SFH")
						SFH->(dbSetOrder(1))
						SFH->(dbGoTop())
						cChave := xFilial("SFH")+SA2->A2_COD+SA2->A2_LOJA+"IBR"+"BA"
						nUltRegSFH := 0
						If SFH->(MsSeek(cChave))
							nUltRegSFH := UltRegSFH("P",cChave)
						EndIf
						If (TMP)->(MsSeek("R"+SA2->A2_CGC))      
							lAchou := .F.
							If nUltRegSFH > 0
								lAchou := .T.
								SFH->(DbGoto(nUltRegSFH))
								nAliq := Val(StrTran((TMP)->ALIQUOTA,",","."))
								If nAliq == SFH->FH_ALIQ
									If RecLock("SFH", .F.)
										SFH->FH_FIMVIGE := dDataFim
										SFH->(MsUnlock())
									EndIf
								Else
									crearSFH("A2",SA2->A2_COD,SFH->FH_AGENTE,"BA",(TMP)->ALIQUOTA,SFH->FH_TIPO,"IBR",SA2->A2_LOJA,SA2->A2_NOME,SFH->FH_APERIB)
								EndIf
							Else
									crearSFH("A2",SA2->A2_COD,"N","BA",(TMP)->ALIQUOTA,(TMP)->TIPO1,"IBR",SA2->A2_LOJA,SA2->A2_NOME,"N")
							EndIf
						Else
							If nUltRegSFH > 0
								SFH->(DbGoto(nUltRegSFH))
								If SFH->FH_FIMVIGE >= dDataIni .Or. Empty(SFH->FH_FIMVIGE)
									If RecLock("SFH", .F.)
										SFH->FH_FIMVIGE := dDataIni
										SFH->(MsUnlock())
									EndIf
								EndIf
							EndIf
						EndIf
						SFH->(dbCloseArea())
					EndIf
				Endif
			EndIf
			SA2->(dbSkip())
		EndDo
		SA2->(dbCloseArea())
	EndIf
	(TMP)->(dbclosearea())
	aSize(aLin,0) 
	aSize(aLinP,0)
Return Nil
