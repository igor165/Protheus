#INCLUDE "HSPAHP31.ch"
#include "protheus.CH"
#INCLUDE "MSOLE.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP31  º Autor ³ José Orfeu                ³  29/08/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Digitação de Resultados                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP31()
	Local lTPLAUDO
	Local lRet := .T.

 Private bCampo := {|nCPO| Field(nCPO)}
 Define  FONT oFont NAME "Arial" BOLD
 Private oTik := LoadBitmap(GetResources(), "LBTIK")
 Private oNo  := LoadBitmap(GetResources(), "LBNO" )
 Private aVetVar := {}
 nReg := 0
 aGets := {} // matriz que contem os campos que vao receber digitacao na enchoice
 aTela := {} // matriz que contem os campos que vao aparecer na enchoice
 SetPrvt("wVar")
 Private aTELA[0][0], aGETS[0], oCodBar
 Private M->GBX_FLGATE := "1"
 cSavI := 0
 SetPrvt("AROTINA, CCADASTRO, CALIAS")
 SetPrvt("NOPCE, NOPCG, NUSADO")
 SetPrvt("CTITULO, CALIASENCHOICE, CLINOK, CTUDOK, CFIELDOK")
 SetPrvt("NREG, NOPC")

	lTPLAUDO := (GetMV("MV_TPLAUDO") == "1")

 nOpc   := 3
 nOpcE  := 4
 nOpcG  := 4
 Inclui := .f.
 Altera := .t.

 aRotina := {{"", '', 0, 1}, ;    && Pesquisar
             {"", '', 0, 2}, ;    && Visualizar
             {"", '', 0, 3}, ;    && Incluir
             {"", '', 0, 4, 2}, ; && Alterar
             {"", '', 0, 5, 1}}   && Excluir

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cria variaveis M->????? da Enchoice                          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 aCpoEnchoice := {}
 aVoltaCpo    := {}
 Inclui       := .t.
 Altera       := .t.
 DbSelectArea("SX3")
 DbSetOrder(1)
 DbSeek("GBX")
 While !Eof() .And. (x3_arquivo == "GBX")
  If X3USO(x3_usado) .And. x3_nivel > 0
   AADD(aCpoEnchoice, x3_campo)
  Endif

  wVar  := "M->" + x3_campo
  &wVar := CriaVar(x3_campo) // executa x3_relacao
   
  dbSkip()
 End

 Inclui := .F.
 Altera := .T.

 nUsado := 0
 DbSelectArea("SX3")
 DbSeek("GBY")
 While !Eof() .And. (x3_arquivo == "GBY")
  If X3USO(x3_usado) .And. x3_nivel > 0
   wVar  := "M->" + x3_campo
   &wVar := CriaVar(x3_campo) // executa x3_relacao
  Endif

  DbSkip()
 EndDo

 Inclui := .T.
 Altera := .F.

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Executa a Modelo 3                                           ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 cTitulo        := OemToAnsi(STR0001) //"Digitacao de Resultados"
 cAliasEnchoice := "GBX"
 cAliasGetd     := "GBY"
 cAlias         := "GBY"
 cLinOk         := "AllwaysTrue()"
 cTudOk         := "AllwaysTrue()"
 cFieldOk       := "AllwaysTrue()"  
 aAtendi        := {STR0002, STR0003, STR0004} //"Total"###"Parcial"###"Nao Atendida"
 M->GBX_SOLICI  := SPACE(06)
 M->GBX_DATSOL  := CTOD("")
 M->GBX_REGATE  := Space(06)
 M->GBX_NOMPAC  := Space(35)
 cAtendi        := SPACE(01)
 aLbx           := {{.F., "", "", 0, "", ""}}
 nOpcaP         := 0

 DEFINE MSDIALOG oDlg TITLE cTitulo From 09, 00 to 42, 80 of oMainWnd FONT oFont
 @ 015, 008 Say OemToAnsi(STR0005) Size 60, 00 PIXEL COLOR CLR_BLUE OF oDlg FONT oFont //"Nro Solicitacao"
 @ 015, 065 MSGet o01 var M->GBX_SOLICI F3 "GBX" Picture "@!" Valid HS_Valid(1) Size 29, 09 PIXEL COLOR CLR_BLACK FONT oFont OF oDlg
 @ 029, 008 Say OemToAnsi(STR0006) Size 60, 00 PIXEL COLOR CLR_BLUE FONT oFont OF oDlg //"Nro Atendimento"
 @ 029, 065 MSGet o02 var M->GBX_REGATE Picture "@!" Size  029, 009 PIXEL COLOR CLR_BLACK FONT oFont OF oDlg when .F.
 @ 029, 106 MSGet o03 var M->GBX_NOMPAC Picture "@!" Size  155, 009 PIXEL COLOR CLR_BLACK FONT oFont OF oDlg when .F.
 @ 043, 008 Say OemToAnsi(STR0007) Size 060, 000 PIXEL COLOR CLR_BLUE FONT oFont OF oDlg //"Data da Solicitacao"
 @ 043, 065 MSGet o04 var M->GBX_DATSOL Picture "@D" Size  038, 009 PIXEL COLOR CLR_BLACK FONT oFont OF oDlg when .F.
 @ 074, 008 BUTTON oBtn PROMPT STR0008 SIZE 030, 010 FONT oFont OF oDlg PIXEL ACTION FS_Filtro() //"Filtrar"
 @ 089, 008 LISTBOX oLbx VAR cLbx FIELDS HEADER " ", ;
							                    OemtoAnsi(STR0009), ; //"Codigo"
							                    OemtoAnsi(STR0010), ; //"Descricao"
							                    OemtoAnsi(STR0011)  ;  //"Qtd Lancada"
							      COLSIZES 010, 029, 182, 029, 029 ;
                                  SIZE 306, 155 FONT oFont OF oDlg PIXEL ON DBLCLICK (nPos := oLbx:nAt, Iif(lTPLAUDO, HS_LAUDO(M->GBX_SOLICI,aLbx[oLbx:nAt,2]),FS_Result()), oLbx:Refresh(), oLbx:nAt := nPos)
 
 oLbx:SetArray(aLbx)
 oLbx:bLine:={|| {if(aLbx[oLbx:nAt,1] == .F., oNo, oTik), ;
			         aLbx[oLbx:nAt,2], ;
			         aLbx[oLbx:nAt,3], ;				
			         aLbx[oLbx:nAt,4]}}

 ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg, {|| oDlg:End(), nOpcaP := 1}, {|| oDlg:End()}))

 If nOpcaP == 1

		If ExistBlock("HSCFGP31")
			lRet := Execblock("HSCFGP31", .F., .F.,Nil)
		Endif
		
		If lRet
  	GrvHSP31()
  Endif

		If ExistBlock("HSGCFP31")
			Execblock("HSGCFP31", .F., .F.,Nil)
		Endif

 EndIf

Return(Nil)                                    
                                    
Static Function GrvHSP31()
 Local i:= 0
 DBSelectArea("GBX")
 DBSetOrder(1)
 DBSeek(xfilial("GBX") + M->GBX_SOLICI)
 For i := 1 to len(aLbx)
  DbSelectArea("GBY")                      
  DbSetOrder(1)
  DbSeek(xFilial("GBY") + M->GBX_SOLICI + aLbx[i, 02])
  IF FOUND()
   RecLock("GBY",.F.)
   GBY->GBY_LAUDO  := IIF(aLbx[i, 1], '1', '0')
   MsUnlock()
  ENDIF
 Next  
 
 If GAD->GAD_ATERPD == "1" // 1=Sim para Atendimento rapido
  If GAD->GAD_ATENDI $ "2" // 2=Exame
   // QUANDO EXAME FECHA CONTA AUTOMATICAMENTO
   DbSelectArea("GAD")
   RecLock("GAD", .F.)
   GAD->GAD_DATFEC := dDataBase
   MsUnlock()             
   DbSelectArea("GBX")
  EndIf                                          
 EndIf
Return(.T.)

Static Function HS_Valid(cVar)
 cSavAlias := alias()
 If cVar == 1 // Número da Solicitação...
  M->GBX_SOLICI := STRZERO(VAL(M->GBX_SOLICI),6)
 
  DBSelectArea("GBX")
  DBSetOrder(1)
  DBGoTop()
  DBSeek(xfilial("GBX") + M->GBX_SOLICI)
  IF !FOUND()
   HS_MsgInf(STR0012, STR0013, STR0001) //"Número da Solicitação não encontrado !"###"Atenção","Digitacao de Resultados"
   Return(.F.)
  Endif
  M->GBX_DATSOL  := GBX->GBX_DATSOL
  M->GBX_REGATE  := GBX->GBX_REGATE
   
  DbSelectArea("GAD")
  DBSetOrder(1)
  DBGoTop()
  DbSeek(xFilial("GAD") + M->GBX_REGATE)
  IF !FOUND()
   HS_MsgInf(STR0014, STR0013, STR0001) //"Registro de Atendimento não Encontrado!"###"Atenção","Digitacao de Resultados"
   Return(.F.)
  Endif

  M->GBX_NOMPAC := GAD->GAD_NOME
   
  DbSelectArea("SA1")     
  DBSetOrder(1)
  DbSeek(xFilial("SA1") + GAD->GAD_REGGER)

  DbSelectArea("GBH")     
  DBSetOrder(1)
  DbSeek(xFilial("GBH") + GAD->GAD_REGGER)

  DbSelectArea("SRA")
  DbSetOrder(11)
  DbSeek(xFilial("SRA") + GBX->GBX_CODCRM)

  DbSelectArea("GA9")
  DBSetOrder(1)
  DbSeek(xFilial("GA9") + GAD->GAD_CODCON)
  
  aVetVar := HS_PrivVar(GAD->GAD_REGATE, .F.)
  aAdd(aVetVar, {"cExame"    , GBX->GBX_SOLICI})
  aAdd(aVetVar, {"cData"     , Dtoc(GBX->GBX_DATSOL)})
  aAdd(aVetVar, {"cHora"     , GBX->GBX_HORSOL})
  aAdd(aVetVar, {"cPaciente" , GAD->GAD_REGATE + '-' + SUBSTR(GAD->GAD_NOME, 01, 28)})
  aAdd(aVetVar, {"cIdade"    , FS_Idade(GBH->GBH_DTNASC, GAD->GAD_DATATE)})
  aAdd(aVetVar, {"cSexo"     , IF(GBH->GBH_SEXO == '1', 'FEMININO ', 'MASCULINO')})
  aAdd(aVetVar, {"cConvenio" , GAD->GAD_CODCON + '-' + ALLTRIM(GA9->GA9_NREDUZ) + '-' + PadR(AllTrim(HS_DesPla(GAD->GAD_CODCON, GAD->GAD_CODPLA)), 09)})
  aAdd(aVetVar, {"cMedico"   , ALLTRIM(GBX->GBX_CODCRM) + '-' + SRA->RA_NOME})
  aAdd(aVetVar, {"cMedSol"   , ALLTRIM(GBX->GBX_CODCRM) + '-' + SRA->RA_NOME})
  aAdd(aVetVar, {"cCCusto"   , GAD->GAD_CCUINT + "-" + AllTrim(HS_RDescCC(GAD->GAD_CCUINT))})
  aAdd(aVetVar, {"cQuarto"   , GAD->GAD_QUAINT})
  aAdd(aVetVar, {"cLeito"    , GAD->GAD_LEIINT})
  aAdd(aVetVar, {"cDescricao", space(01)})
 Endif
Return(.T.)                                     

Static Function FS_Idade(dDataI, dDataF)
 Local aIdade := HS_DifData(dDataI, dDataF)
Return(StrZero(aIdade[1], 2) + STR0015 + StrZero(aIdade[2], 2) + STR0016 + StrZero(aIdade[3], 2) + STR0017) //" ano(s) "###" mes(es) "###" dia(s) "

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_Result        ³ Autor ³  José Orfeu     ³ Data 29/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Digitação do Resultado do Exame                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_Result(nLaudAP)
 Local cDirLaud := AllTrim(GetMV("MV_DIRLAUD"))
 Local cDirMode := AllTrim(GetMV("MV_DIRMODE"))
	Local cVarPerg	:= "" 
	Local aVetTMP		:= {}
	Local nCont				:= 0

 Private oWord
 Private oleWdVisible   := .T.
 Private oleWdPrintBack := .F.
 Private cArqLaud := ""
 Private cArqMode := ""
 Private cArqPadr := ""

	Default nLaudAP := 0
	 
 If SubStr(cDirLaud, Len(cDirLaud), 1) == "\"
  cDirLaud := SubStr(cDirLaud, 1, Len(cDirLaud) - 1)
 EndIf
 
 If SubStr(cDirMode, Len(cDirMode), 1) == "\"
  cDirMode := SubStr(cDirMode, 1, Len(cDirMode) - 1)
 EndIf
 
 Define FONT oFont NAME "Arial" BOLD
 
 cType  := "LAUDOS	     | *.DOT"
 cTexto := ""
 cArqLaud := cDirLaud + "\" + M->GBX_SOLICI + STRZERO(oLbx:nAt, 02) + ".DOC"
 cArqMode := cDirMode + "\" + AllTrim(aLbx[oLbx:nAt, 02]) + ".DOC"
 cArqPadr := cDirMode + "\ExamPadr.Doc"

	If nLaudAP == 1

		aVetTMP := HS_MontLau(M->GBX_SOLICI, aLbx[oLbx:nAt,2],.T.)	

		For nCont := 1 To Len(aVetTMP)
		
			cVarPerg := "__" + aVetTMP[nCont,1] + "GCP_" + AllTrim(aVetTMP[nCont,4])
			aAdd(aVetVar, {cVarPerg, aVetTMP[nCont,3]})

		Next nCont
	 
	Endif

 AbreR1()

 //CloseWord(@oWord)

 If aLbx[oLbx:nAt, 01] == .F.
  If !Empty(cArqLaud)
   aLbx[oLbx:nAt, 01] := .T.
  Else
   aLbx[oLbx:nAt, 01] := .F. 
  EndIf   
 Else
  If !Empty(cArqLaud)
   aLbx[oLbx:nAt, 01] := .T.
  Else
   aLbx[oLbx:nAt, 01] := .F.
  EndIf
 EndIf

 oLbx:refresh()
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ ABRER1    º Autor ³ José Orfeu             Data  29/08/2002º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Rotina para a abertura do arquivo texto na FunMEMO         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso		 ³ Espec¡fico para clientes Microsiga						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AbreR1   
 //cAux := cArqLaud
 IF !FILE(cArqLaud)
  If !File(cArqMode)            
   _CopyFile(cArqPadr, cArqLaud)
  Else
   _CopyFile(cArqMode, cArqLaud)
  EndIf 
 ENDIF
 //cArquivo := cArqLaud
 OpenWord(@oWord, cArqLaud)
Return

//////////////////////////////////////////////////////////
// Seleciona registros a partir dos parametros informados
//////////////////////////////////////////////////////////
Static Function FS_Filtro()
 cSavAlias := alias()
 DbSelectArea("GBX")                      
 DbSetOrder(1)
 DBGoTop()
 DbSeek(xFilial("GBX") + M->GBX_SOLICI)
 IF !FOUND()
  HS_MsgInf(STR0012, STR0013, STR0018) //"Número da Solicitação não encontrado !"###"Atenção" //"Abertura do arquivo texto"
  Return .f.
 Endif   

 aLbx := {}
 DbSelectArea("GBY")                      
 DbSetOrder(1)
 DBGoTop()
 DbSeek(xFilial("GBY")+M->GBX_SOLICI)
 IF FOUND()
  While !Eof() .And. GBY->GBY_FILIAL + GBY->GBY_SOLICI == xFilial("GBY") + M->GBX_SOLICI
   DbSelectArea("GA7")
   DbSeek(xFilial("GA7") + GBY->GBY_PROSOL)
   aAdd(aLbx, {IF(GBY->GBY_ENTREG == '1', .T., .F.), GBY->GBY_PROSOL, GA7->GA7_DESC, GBY->GBY_QTDSOL, GBY->GBY_SEQDES, GBY->GBY_ENTREG})
   DbSelectArea("GBY")
   DbSkip()
  EndDo
	   
  oLbx:SetArray(aLbx)
  oLbx:bLine:={||{ If(aLbx[oLbx:nAt, 01] == .F., oNo, oTik), ;
		              aLbx[oLbx:nAt, 02], ;
		              aLbx[oLbx:nAt, 03], ;
		              aLbx[oLbx:nAt, 04]}}
  oLbx:Refresh()
 EndIf
 DbSelectArea(cSavAlias)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OpenWord    ³ Autor ³ Cristina Ogura      ³ Data ³ 19.04.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Trata as variaveis de abertura quando utiliza o Word     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Especifico                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
*/
Static Function OpenWord(oWord,cFile)
 Local nVarWord := 0, cAliasOld := Alias()
 
 // Inicializa o Ole com o MS-Word 97 ( 8.0 )
 oWord := OLE_CreateLink('TMsOleWord97')
 
 //OLE_OpenFile(oWord, cDirSrv + cFile)
 OLE_OpenFile(oWord, cFile)
	
 For nVarWord := 1 To Len(aVetVar)
  If aVetVar[nVarWord, 1] == "cMedico"
   DbSelectArea("GAO")
   DbSetOrder(5)
   DbSeek(xFilial("GAO") + PadR(AllTrim(aLbx[oLbx:nAt, 5]), Len(GAO->GAO_SEQDES)) + ;
                           PadR(AllTrim(GBX->GBX_REGATE  ), Len(GAO->GAO_REGATE)) + ;
                           PadR(AllTrim(aLbx[oLbx:nAt, 2]), Len(GAO->GAO_CODPRO)))
                           
   DbSelectArea("SRA")
   DbSetOrder(11)
   DbSeek(xFilial("SRA") + GAO->GAO_CODCRM)                           
   
   DbSelectArea(cAliasOld)
                                                                        
   OLE_SetDocumentVar(oWord, "cMedico", GAO->GAO_CODCRM + "-" + SRA->RA_NOME)
  Else
   OLE_SetDocumentVar(oWord, aVetVar[nVarWord, 1], aVetVar[nVarWord, 2])
  EndIf 
 Next
  
 //--Atualiza Variaveis
 OLE_UpDateFields(oWord)

 //-- Imprime as variaveis				
 //OLE_PrintFile( oWord, "ALL",,, 1 ) 
				
 //CloseWord(@oWord)
Return .T.