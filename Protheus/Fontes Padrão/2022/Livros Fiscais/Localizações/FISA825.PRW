#include 'fisa825.ch'
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

#DEFINE _SEPARADOR ";"
#DEFINE	_POSREG	   		1
#DEFINE _POSDATAPUB    	2
#DEFINE _POSDATAINI	    3
#DEFINE	_POSDATAFIN	    4
#DEFINE _POSCGC 		5 
#DEFINE _POSTIPO	    6
#DEFINE _POSMARCASU     7
#DEFINE _POSMARCALIQC   8
#DEFINE _POSALIQ        9


#DEFINE _BUFFER 16384

Function FISA825()

Local cCombo	:= ""
Local aCombo	:= {}
Local oDlg		:= Nil
Local oFld		:= Nil

Private cMes	:= StrZero(Month(dDataBase),2)
Private cAno	:= StrZero(Year(dDataBase),4)
Private lRet	:= .F.
Private lPer	:= .T.
Private oTmpTable := Nil

aAdd( aCombo, STR0002 ) //"1- Fornecedor"
aAdd( aCombo, STR0003 ) //"2- Cliente"
aAdd( aCombo, STR0004 ) //"3- Ambos  "

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
Local lAux := .T.
If lRet == .T. .and. Subs(cCombo,1,1) $ "2|3"    // Cliente nao tem retenção!
	lRet :=.F.
	lAux := .F.
EndIf	
If  lRet == .T. .and. lPer == .T. .and. (Subs(cCombo,1,1) $ "1" )
	lRet :=.F.
	lPer :=.F.
	lAux := .F.
EndIf

oChk1:Refresh()
oChk2:Refresh()

Return lAux

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
Private cFile    := ""
Private dDataIni := ""
Private dDataFim := ""
Private lFor     := .F.
Private lCli     := .F.
Private lImp     := .F.


nPos := aScan(aCombo,{|x| AllTrim(x) == AllTrim(cCombo)})
If nPos == 1 // Fornecedor
	lFor := .T.
ElseIf nPos == 2 // Cliente
	lCli := .T.
ElseIf nPos == 3 // Ambos
	lFor := .T.
	lCli := .T.
EndIf

cFile := FGetFile()
If Empty(cFile)
	MsgStop(STR0031) //"Seleccione un archivo e intente nuevamente."
	Return Nil
EndIf


If !File(cFile)
	MsgStop(STR0031) //"Seleccione un archivo e intente nuevamente."
	Return Nil
EndIf
If VldFech()
	MsAguarde({|| Import(cFile)} ,STR0019,STR0020 ,.T.) //"Lendo Arquivo, Aguarde..."###"Atualizacao de aliquotas"
	TMP->(dbCloseArea())
	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf
EndIf


If (lImp )
	MsgAlert(STR0025,"") //"Arquivo importado!"
EndIf
Return Nil


Static Function VldFech()

	Local cErro	:= STR0029	
	Local cSolucao := STR0031
	Local cTitulo	:= STR0001
	FT_FUSE(cFile)
	If !(";" $ (FT_FREADLN()))
		MsgStop(STR0029) //"Ha ocurrido un error al procesar el archivo seleccionado. Verifique que el contenido del mismo sea correcto e intente nuevamente."
		Return Nil
	EndIf
	cLine := Separa(FT_FREADLN(),_SEPARADOR)[_POSDATAINI]
	cReg  := Separa(FT_FREADLN(),_SEPARADOR)[_POSREG]
		
	If (cMes+cAno) <> (SubStr(cLine,3,7))  
		MsgStop(STR0021+(SubStr(cLine,3,2)+"/"+SubStr(cLine,5,4))+")",STR0022) //"no corresponde periodo
		Return Nil
	EndIf
	dDataIni := CTOD("01/"+cMes+"/"+cAno) 
	dDataFim := LastDay(dDataIni) 
	FT_FUSE() 
	
	If (lCli .and. lPer .and. !cReg="P") .or. (lFor .and. lPer .and. !cReg ="P")
		xMagHelpFis(cTitulo,cErro,cSolucao)
		Return Nil
	EndIf
	If lFor .and. lRet .and. !cReg ="R"
		xMagHelpFis(cTitulo,cErro,cSolucao)
		Return Nil
	EndIf
	
Return .T.
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

Static Function Import(cFile, nAliqPer)

Local nAliq			:= 0
Local nAlqPer		:= 0
Local cChave		:= ""
Local lAchou		:= .F.
Local cQuery		:= ""
Local nI 			:= 0
Local aPerPrv       := {} 
Local lReturn   	:= .T.
Local nReg 			:= 0
Private cTipo 		:= "" 
Private lFecMen     := .F.
Private lExtVige    := .F.
Private lGenera     := .F.
Private cTable  	:= ""

Processa({|| lReturn := GeraTemp(cFile)}) // cualquier base de datos

If !lReturn
	Return Nil
EndIf

If lCli .and. lPer
	
	cQuery	:= ""
	cQuery := "SELECT A1_COD, A1_LOJA, A1_CGC, A1_NOME"
	cQuery += " FROM " + RetSqlName("SA1") 
	cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery += " AND A1_CGC <> ''"
	cQuery += " AND D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY A1_CGC ASC"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cTempSA1", .T., .T.)
	
	Do While cTempSA1->(!EOF())
		If TMP->(MsSeek("P"+AllTrim(cTempSA1->A1_CGC)))
			cTipo := Tipo(TMP->TIPO)
			nAliq := Val(StrTran(TMP->ALIQ,",","."))	
			dbSelectArea("SFH")
			SFH->(dbSetOrder(3))
			SFH->(dbGoTop())
			lAchou := .F.

			cChave := xFilial("SFH")+cTempSA1->A1_COD+cTempSA1->A1_LOJA+"IB8"+"CO"
			If SFH->(MsSeek(cChave))
				nRecFim :=  MayorFech(cTempSA1->A1_COD,cTempSA1->A1_LOJA,"IB8",.T.)
				SFH->(DbGoTo(nRecFim))
				If (lAchou := .T.)
					If dDataIni <= SFH->FH_FIMVIGE 
						lFecMen  := .T.
					ElseIf ((dDataIni == (SFH->FH_FIMVIGE + 1)) .AND. (SFH->FH_ALIQ == nAliq)) .AND.SFH->FH_TIPO==cTipo
						lExtVige := .T.
					Else
						lGenera  := .T.
					EndIf
				Else
					lGenera := .T.
				EndIf
			EndIf
			If lAchou 
				If !lFecMen  
					If lExtVige
						RecLock("SFH", .F.)
						SFH->FH_FIMVIGE := dDataFim
						SFH->(MsUnlock())	
					ElseIf lGenera			
						ActSFH(SFH->FH_AGENTE,SFH->FH_CLIENTE,cTipo,cTempSA1->A1_LOJA,SFH->FH_PERCIBI,SFH->FH_APERIB,SFH->FH_ZONFIS,SFH->FH_IMPOSTO,nAliq,dDataIni,dDataFim,IIF(nAliq == 0,100,0),"A1",cTempSA1->A1_NOME)
					EndIf
				EndIf
			Else// no esta en SFH
				ActSFH("N",cTempSA1->A1_COD,cTipo,cTempSA1->A1_LOJA,"S","S","CO","IB8",nAliq,dDataIni,dDataFim,IIF(nAliq == 0,100,0),"A1",cTempSA1->A1_NOME)
			EndIf
			SFH->(dbCloseArea())
		Else // no padron
			dbSelectArea("SFH")
			SFH->(dbSetOrder(3))
			SFH->(dbGoTop())
			lAchou := .F.
			cChave := xFilial("SFH")+cTempSA1->A1_COD+cTempSA1->A1_LOJA+"IB8"+"CO"										
			If SFH->(MsSeek(cChave))
				nRecFim := MayorFech(cTempSA1->A1_COD,cTempSA1->A1_LOJA,"IB8",.T.)
				SFH->(DbGoTo(nRecFim))
				If (lAchou := .T.) 
					If dDataIni <= SFH->FH_FIMVIGE 
						lFecMen  := .T.
					ElseIf (dDataIni > SFH->FH_FIMVIGE ).And. (SFH->FH_INIVIGE<>dDataIni) 
						lExtVige := .T.
					EndIf
				EndIf
			EndIf
			If lAchou
				If !lFecMen
					If lExtVige
						nAliq := 0
						ActSFH(SFH->FH_AGENTE,SFH->FH_CLIENTE,SFH->FH_TIPO,cTempSA1->A1_LOJA,SFH->FH_PERCIBI,SFH->FH_APERIB,SFH->FH_ZONFIS,SFH->FH_IMPOSTO,0,dDataIni,CTOD("//"),0,"A1",cTempSA1->A1_NOME)
					EndIf
				EndIf
			EndIf
		EndIf
		lFecMen     := .F.
		lExtVige    := .F.
		lGenera     := .F.	
		cTempSA1->(dbSkip())
		nReg ++
	EndDo
	cTempSA1->(dbCloseArea())
	lImp := .T.
EndIf

If lFor .and. (lRet .or. lPer)
	cQuery	:= ""
	cQuery := "SELECT A2_COD, A2_LOJA, A2_CGC,A2_NOME"
	cQuery += " FROM " + RetSqlName("SA2") 
	cQuery += " WHERE A2_FILIAL = '" + xFilial("SA2") + "'"
	cQuery += " AND A2_CGC <> ''"
	cQuery += " AND D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY A2_CGC ASC"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cTempSA2", .T., .T.)
	
	nAlqPer	:= 0
	If lPer
		If TMP->(MsSeek("P"+Alltrim(SM0->M0_CGC)))
			If lPer
				aPerPrv	:={TMP->REG,TMP->FINI,TMP->FFIN,TMP->CUIT,TMP->TIPO,TMP->ALIQ}
			EndIf
		EndIf	
		If Len(aPerPrv)>0
			nAlqPer := Val(StrTran(aPerPrv[6],",","."))
		EndIf
	EndIf
	
	Do While cTempSA2->(!EOF())
		If lPer
			If Len(aPerPrv) > 0 .and. UPPER(aPerPrv[1]) == 'P' 
				cTipo := Tipo(aPerPrv[5])
				dbSelectArea("SFH")
				SFH->(dbSetOrder(1))
				SFH->(dbGoTop())
				lAchou := .F.
				cChave := xFilial("SFH")+cTempSA2->A2_COD+cTempSA2->A2_LOJA+"IB8"+"CO"
				
				If SFH->(MsSeek(cChave))
					nRecFim := MayorFech(cTempSA2->A2_COD,cTempSA2->A2_LOJA,"IB8",.F.)
					SFH->(DbGoTo(nRecFim))
					If (lAchou := .T.) 
						If dDataIni <= SFH->FH_FIMVIGE 
							lFecMen  := .T.
						ElseIf ((dDataIni == (SFH->FH_FIMVIGE + 1)) .AND. (SFH->FH_ALIQ == nAlqPer)) .AND. SFH->FH_TIPO==cTipo
							lExtVige := .T.
						Else
							lGenera  := .T.
						EndIf
					Else
						lAchou := .F.
					EndIf
				EndIf
				If lAchou
					If !lFecMen
						If lExtVige
							RecLock("SFH", .F.)
							SFH->FH_FIMVIGE := dDataFim
							SFH->(MsUnlock())			
						ElseIf lGenera
							ActSFH(SFH->FH_AGENTE,SFH->FH_FORNECE,cTipo,cTempSA2->A2_LOJA,SFH->FH_PERCIBI,SFH->FH_APERIB,SFH->FH_ZONFIS,SFH->FH_IMPOSTO,nAlqPer,dDataIni,dDataFim,IIF(nAlqPer==0,100,0),"A2",cTempSA2->A2_NOME)
						EndIf
					EndIf
				EndIf
			Else // no padron	
				dbSelectArea("SFH")
					SFH->(dbSetOrder(1))
					SFH->(dbGoTop())
					lAchou := .F.
					cChave := xFilial("SFH")+cTempSA2->A2_COD+cTempSA2->A2_LOJA+"IB8"+"CO"	
					If SFH->(MsSeek(cChave))
						nRecFim := MayorFech(cTempSA2->A2_COD,cTempSA2->A2_LOJA,"IB8",.F.)
						SFH->(DbGoTo(nRecFim))
						If (lAchou := .T.)
							If dDataIni <= SFH->FH_FIMVIGE 
								lFecMen  := .T.
							ElseIf (dDataIni > SFH->FH_FIMVIGE) .And. (SFH->FH_INIVIGE<>dDataIni)
								lGenera := .T.
							EndIf
						EndIf
					EndIf
					If lAchou
						If !lFecMen
							If lGenera
								ActSFH(SFH->FH_AGENTE,SFH->FH_FORNECE,SFH->FH_TIPO,SFH->FH_LOJA,SFH->FH_PERCIBI,SFH->FH_APERIB,SFH->FH_ZONFIS,SFH->FH_IMPOSTO,0,dDataIni,CTOD("//"),0,"A2",cTempSA2->A2_NOME)
							EndIf
						EndIf
					EndIf
			EndIf // fin cuit empresa
		EndIf// fin per prove
		If lRet
			If TMP->(MsSeek("R"+AllTrim(cTempSA2->A2_CGC)))
				cTipo := Tipo(TMP->Tipo)
				nAliq := Val(StrTran(TMP->ALIQ,",","."))
				dbSelectArea("SFH")
				SFH->(dbSetOrder(1))
				SFH->(dbGoTop())
				lAchou := .F.
				cChave := xFilial("SFH")+cTempSA2->A2_COD+cTempSA2->A2_LOJA+"IBR"+"CO"
				If SFH->(MsSeek(cChave))
					nRecFim := MayorFech(cTempSA2->A2_COD,cTempSA2->A2_LOJA,"IBR",.F.)
					SFH->(DbGoTo(nRecFim))
					If (lAchou := .T.)  
						If dDataIni <= SFH->FH_FIMVIGE 
							lFecMen  := .T. 
						ElseIf (dDataIni == (SFH->FH_FIMVIGE + 1)) .AND. (SFH->FH_ALIQ == nAliq) .AND.SFH->FH_TIPO==cTipo
							lExtVige := .T.
						Else
							lGenera  := .T.
						EndIf
					Else
						lGenera := .T. 
					EndIf
				EndIf// fin sfh busq
				If lAchou 
					If !lFecMen  
						If lExtVige
							RecLock("SFH", .F.)
							SFH->FH_FIMVIGE := dDataFim
							SFH->(MsUnlock())	
						ElseIf lGenera			
							ActSFH(SFH->FH_AGENTE,SFH->FH_FORNECE,cTipo,SFH->FH_LOJA,SFH->FH_PERCIBI,SFH->FH_APERIB,SFH->FH_ZONFIS,SFH->FH_IMPOSTO,nAliq,dDataIni,dDataFim,IIF(nAliq==0,100,0),"A2",cTempSA2->A2_NOME)
						EndIf
					EndIf
				Else // no SFH
					ActSFH("N",cTempSA2->A2_COD,cTipo,cTempSA2->A2_LOJA,"N","N","CO","IBR",nAliq,dDataIni,dDataFim,IIF(nAliq==0,100,0),"A2",cTempSA2->A2_NOME)
				EndIf
				SFH->(dbCloseArea())
			
			Else//  no padron
				dbSelectArea("SFH")
				SFH->(dbSetOrder(1))
				SFH->(dbGoTop())
				lAchou := .F.
				cChave := xFilial("SFH")+cTempSA2->A2_COD+cTempSA2->A2_LOJA+"IBR"+"CO"											
				If SFH->(MsSeek(cChave))
					nRecFim := MayorFech(cTempSA2->A2_COD,cTempSA2->A2_LOJA,"IBR",.F.)
					SFH->(DbGoTo(nRecFim))
					If (lAchou := .T.) 
						If dDataIni <= SFH->FH_FIMVIGE 
							lFecMen  := .T. 
						ElseIf (dDataIni > SFH->FH_FIMVIGE ) .And. (SFH->FH_INIVIGE<>dDataIni)
							lGenera := .T.
						EndIf
					EndIf
				EndIf
				If lAchou
					If !lFecMen
						If lGenera
							ActSFH(SFH->FH_AGENTE,SFH->FH_FORNECE,SFH->FH_TIPO,SFH->FH_LOJA,SFH->FH_PERCIBI,SFH->FH_APERIB,SFH->FH_ZONFIS,SFH->FH_IMPOSTO,0,dDataIni,CTOD("//"),0,"A2",cTempSA2->A2_NOME)
						EndIf
					EndIf
				EndIf
			EndIf// fin padron
		EndIf// fin ret prove
		lFecMen     := .F.
		lExtVige    := .F.
		lGenera     := .F.
		cTempSA2->(dbSkip())
		
	EndDo
	cTempSA2->(dbCloseArea())
	lImp := .T.
EndIf // fin prove
	
Return Nil

Static Function ActSFH(cAgente,cCOD,cTipo,cLoja,cPercIBI,cAPERIB,cZonaFis,cImpost,nAliq,dDataIni,dDataFim,nPercent,cTable,cNome)
Default cLoja	:= ""
Private lLojaSFH:= .T.
Private lCodSFH := .T.
Private cPrefixo := "->"+cTable+"_" 
cTable :="S"+cTable

If Empty(cLoja)
	lLojaSFH := .F.
EndIf
If Empty(cCOD)
	lCodSFH := .F.
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
	SFH->FH_NOME	:= cNome
	SFH->FH_IMPOSTO	:= cImpost
	SFH->FH_PERCIBI	:= cPercIBI	
	SFH->FH_ISENTO	:= "N"
	SFH->FH_APERIB	:= cAPERIB
	SFH->FH_ALIQ	:= nAliq
	SFH->FH_PERCENT	:= nPercent
	SFH->FH_TIPO    := cTipo
	SFH->FH_INIVIGE := dDataIni
	SFH->FH_FIMVIGE := dDataFim 	
	SFH->(MsUnlock())
EndIf

Return Nil


Static Function Tipo(cTipo)
	If	cTipo == "C"		
		cTipo	:= "V"
	ElseIf	((cTipo == "L") .Or. (cTipo == "N"))
		cTipo	:= "I"
	Else
		cTipo	:= "N"
	EndIf
Return cTipo

Static Function MayorFech(cCod,cLoja,cImpuesto,lTabla)

	Private dFecAnt := ""
	Private nAux :=0
	Private cTabla :=""
	Private nAuxIni :=0
		
	Iif(lTabla,cTabla:="FH_CLIENTE",cTabla:="FH_FORNECE")
	cQuery	:= ""
	cQuery := "SELECT  FH_FIMVIGE AS FECHA,R_E_C_N_O_ AS NUM,FH_INIVIGE AS INI"
	cQuery += " FROM " + RetSqlName("SFH") 
	cQuery += " WHERE FH_FILIAL = '" + xFilial("SFH") + "'"
	cQuery += " AND "+cTabla+" = '"+cCod+"'"
	cQuery += " AND FH_LOJA ='"+cLoja+"'"
	cQuery += " AND FH_IMPOSTO ='"+cImpuesto+"'"
	cQuery += " AND FH_ZONFIS ='CO'"
	cQuery += " AND D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cTMayor", .T., .T.)

	cTMayor->(dbGoTop())
	Do While cTMayor->(!EOF()) 
		If cTMayor->FECHA > dFecAnt
			nAux := cTMayor->NUM
			dFecAnt := cTMayor->FECHA
		EndIf
		
		If(DTOS(dDataIni) == cTMayor->INI)
			nAuxIni :=cTMayor->NUM
		EndIf
		cTMayor->(dbSkip())
	EndDo
	If(nAuxIni<>0)
		nAux :=nAuxIni
	EndIf
	cTMayor->(dbCloseArea())
Return nAux


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
Local cTitulo	 := STR0001  //"Problemas en la importación del archivo"
Local cQuery	:= "" 
Local cCGCEmp	:= AllTrim(SM0->M0_CGC)
Local nCGCEmp	:= Val(AllTrim(SM0->M0_CGC))
Local nPosCGC	:= 0
Local lCGC		:= .T.
Local nPosCli		:= 0
Local nPosFor		:= 0
Local nCuitCli		:= 0
Local nCuitFor		:= 0
Local nPrimer		:= 0
Local nUltimo		:= 0
Local nRegs			:= 0 
Local nTotal		:= 0			
Local cFdesde	:= "01"+cMes+cAno
Local lReturn    := .T.
Local lPerForn	:=  .T.
//*************Modelo do arquivo*************
//
AADD(aCampos,{"CUIT"		,"C",11,0})
AADD(aCampos,{"REG"			,"C",1,0})
AADD(aCampos,{"ALIQ"		,"C",5,0})
AADD(aCampos,{"FINI"		,"C",8,0})
AADD(aCampos,{"FFIN"		,"C",8,0})
AADD(aCampos,{"TIPO"		,"C",1,0})

oTmpTable := FWTemporaryTable():New("TMP")
oTmpTable:SetFields( aCampos )
aOrdem	:=	{"REG","CUIT"}

oTmpTable:AddIndex("TMP", aOrdem)
oTmpTable:Create() 

If lCli .and. lPer
	cQuery	:= ""
	cQuery := "SELECT A1_COD, A1_LOJA, A1_CGC, A1_NOME"
	cQuery += " FROM " + RetSqlName("SA1") 
	cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery += " AND A1_CGC <> ''"
	cQuery += " AND D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY A1_CGC ASC"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cSA1", .T., .T.)
	cSA1->(dbGoTop())
	count to nRegs
	cSA1->(dbGoTop())
	nTotal += nRegs
EndIf


If lFor .and. (lRet .or. lPer)
	cQuery	:= ""
	cQuery := "SELECT A2_COD, A2_LOJA, A2_CGC,A2_NOME"
	cQuery += " FROM " + RetSqlName("SA2") 
	cQuery += " WHERE A2_FILIAL = '" + xFilial("SA2") + "'"
	cQuery += " AND A2_CGC <> ''"
	cQuery += " AND D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY A2_CGC ASC"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cSA2", .T., .T.)
	cSA2->(dbGoTop())
	count to nRegs
	cSA2->(dbGoTop())
	nTotal += nRegs
EndIf

If File(cArqProc)

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
		//
		//³Gera arquivo temporario a partir do arquivo TXT ³
		//
		oFile := ZFWReadTXT():New(cArqProc,,_BUFFER)
		
		If !oFile:Open()
			MsgAlert(STR0023 + cArqProc + STR0024)  //"El archivo " +cArqProc+ "No puede abrirse"
			Return .F.
		EndIf
	
		ProcRegua(nTotal)
			While oFile:ReadBlock(@aInforma,_SEPARADOR)
			 	IncProc(cMsg + str(nI))
			 	nPrimer := Val(aInforma[1][5])
			 	nUltimo := Val(aInforma[Len(aInforma)][5])
			 				 	
			 	If lFor .and. lPer .and. lCGC .and. (nPrimer <= nCGCEmp .and. nUltimo >= nCGCEmp)
			 		nPosCGC :=  ascan(aInforma,{|x| x[5] == cCGCEmp .and. x[1]=="P" })
			 		If nPosCGC > 0 
			 			TMP->( DBAppend() )
			  	  		TMP->REG		:= aInforma[nPosCGC][_POSREG]
	  	  				TMP->FINI		:= cFdesde
	  	  				TMP->FFIN		:= aInforma[nPosCGC][_POSDATAFIN]
	  	  				TMP->CUIT		:= aInforma[nPosCGC][_POSCGC]
	  	  				TMP->TIPO		:= aInforma[nPosCGC][_POSTIPO] 
	  	  				TMP->ALIQ		:= aInforma[nPosCGC][_POSALIQ]
						TMP->( DBCommit() )	
			 		EndIf
			 		lCGC := .F.
			 	EndIf
				
				If lCli .and. lPer
					If aInforma[1][1]="P"
						While cSA1->(!EOF())
							nCuitCli := Val(AllTrim(cSA1->A1_CGC))					
							If (nPrimer <= nCuitCli .and. nUltimo >= nCuitCli)
								nPosCli :=  ascan(aInforma,{|x| x[5] == AllTrim(cSA1->A1_CGC) .and. x[1]=="P" })
								If nPosCli > 0
									TMP->( DBAppend() )
						  	  		TMP->REG		:= aInforma[nPosCli][_POSREG]
		  	  						TMP->FINI		:= cFdesde
		  	  						TMP->FFIN		:= aInforma[nPosCli][_POSDATAFIN]
		  	  						TMP->CUIT		:= aInforma[nPosCli][_POSCGC]
		  	  						TMP->TIPO		:= aInforma[nPosCli][_POSTIPO] 
		  	  						TMP->ALIQ		:= aInforma[nPosCli][_POSALIQ]
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
				EndIf
				
				If lFor .and. lRet
					While cSA2->(!EOF())
						nCuitFor := Val(AllTrim(cSA2->A2_CGC))
						If (nPrimer <= nCuitFor .and. nUltimo >= nCuitFor)
							nPosFor :=  ascan(aInforma,{|x| x[5] == AllTrim(cSA2->A2_CGC) .and. x[1]=="R" })
							If nPosFor > 0
								TMP->( DBAppend() )
						  	  	TMP->REG		:= aInforma[nPosFor][_POSREG]
		  	  					TMP->FINI		:= cFdesde
		  	  					TMP->FFIN		:= aInforma[nPosFor][_POSDATAFIN]
		  	  					TMP->CUIT		:= aInforma[nPosFor][_POSCGC]
		  	  					TMP->TIPO		:= aInforma[nPosFor][_POSTIPO] 
		  	  					TMP->ALIQ		:= aInforma[nPosFor][_POSALIQ]
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
		
		If lFor .and. (lRet .or. lPer)
			cSA2->(dbCloseArea())
		EndIf
		If lFor .and. lPer .and. (TMP->(LastRec())== 0)
			lPerForn := .F.
		EndIf
	oFile:Close()	 // Fecha o Arquivo

	If Empty(cErro) .and. (TMP->(LastRec())== 0) .and. lPerForn   
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




