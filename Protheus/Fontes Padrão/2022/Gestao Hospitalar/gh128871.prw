#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ-ÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³GH128871  ³ Autor ³ MICROSIGA             ³ Data ³ 13/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao Principal                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GH128871()

 Local dDatDes := CToD("  /  /  "), oDatDes
 Local cLstCon := Space(100), oLstCon
 Local cLstEmp := Space(100), oLstEmp
 Local oDlgCar := Nil
 
 cArqEmp 					:= "SigaMat.Emp"
 __cInterNet 	:= Nil
 
 PRIVATE cMessage
 PRIVATE aArqUpd	 := {}
 PRIVATE aREOPEN	 := {}
 PRIVATE oMainWnd
 Private nModulo 	:= 51 // modulo SIGAHSP

 Set Dele On

 lEmpenho				:= .F.
 lAtuMnu					:= .F.
 
 SetsDefault()
 
 If MsgYesNo("Deseja executar atualização de dicionário?")
  Processa({|| ProcATU()},"Processando [GH128871]","Aguarde , processando preparação dos arquivos")
 EndIf
	
	If MsgYesNo("Deseja atualizar as tabelas de preço nas despesas?")
	 If Select("SM0") > 0
	  SM0->(DBCLOSEAREA())
	 EndIf
	 nOpcA   := 0	
	 DEFINE MSDIALOG oDlgCar TITLE "Carater" From 09, 00 To 20, 45 Of oMainWnd
  	@ 020, 015 Say "Data Inic:" Of oDlgCar Pixel COLOR CLR_BLUE
	  @ 018, 040 MsGet oDatDes VAR dDatDes Picture "@D"   OF oDlgCar Pixel COLOR CLR_BLACK
	  @ 032, 015 Say "Lst. Conv:" Of oDlgCar Pixel COLOR CLR_BLUE
	  @ 030, 040 MsGet oLstCon VAR cLstCon Picture "@S20" OF oDlgCar Pixel COLOR CLR_BLACK
	  @ 044, 015 Say "Lst. Empr:" Of oDlgCar Pixel COLOR CLR_BLUE
	  @ 042, 040 MsGet oLstEmp VAR cLstEmp Picture "@S20" OF oDlgCar Pixel COLOR CLR_BLACK
	 ACTIVATE MSDIALOG oDlgCar CENTERED ON INIT EnchoiceBar(oDlgCar, 	{|| nOpcA := 1, oDlgCar:End()}, ;
		 																																																																{|| nOpcA := 0, oDlgCar:End()})
		If nOpcA == 1
		 HS_AtTbPre(dDatDes, cLstCon, cLstEmp)
		EndIf
		 
	EndIf

Return()


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcATU   ³ Autor ³                       ³ Data ³  /  /    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao dos arquivos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Baseado na funcao criada por Eduardo Riera em 01/02/2002   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProcATU()
Local cTexto    	:= ""
Local cFile     	:= ""
Local cMask     	:= "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno    	:= 0
Local nI        	:= 0
Local nX        	:= 0
Local aRecnoSM0 	:= {}
Local lOpen     	:= .F.

ProcRegua(1)
IncProc("Verificando integridade dos dicionários....")
If (lOpen := IIF(Alias() <> "SM0", MyOpenSm0Ex(), .T. ))

	dbSelectArea("SM0")
	dbGotop()
	While !Eof()
  		If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
		EndIf			
		dbSkip()
	EndDo	

	If lOpen
		For nI := 1 To Len(aRecnoSM0)
			SM0->(dbGoto(aRecnoSM0[nI,1]))
			RpcSetType(2)
			RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
 		nModulo := 51 // modulo SIGAHSP
			lMsFinalAuto := .F.
			cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)

			ProcRegua(8)

			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Funções descontinuadas pelo SGBD: GeraSX1(), GeraSX2(), GeraSX3() e GeraSIX()" , 0, 0, {})
	
			__SetX31Mode(.F.)
			For nX := 1 To Len(aArqUpd)
				IncProc("Atualizando estruturas. Aguarde... ["+aArqUpd[nx]+"]")
				If Select(aArqUpd[nx])>0
					dbSelecTArea(aArqUpd[nx])
					dbCloseArea()
				EndIf
				X31UpdTable(aArqUpd[nx])
				If __GetX31Error()
					Alert(__GetX31Trace())
					Aviso("Atencao!","Ocorreu um erro desconhecido durante a atualizacao da tabela : "+ aArqUpd[nx] + ". Verifique a integridade do dicionario e da tabela.",{"Continuar"},2)
					cTexto += "Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "+aArqUpd[nx] +CHR(13)+CHR(10)
				EndIf
				dbSelectArea(aArqUpd[nx])
			Next nX		

			RpcClearEnv()
			If !( lOpen := MyOpenSm0Ex() )
				Exit
		 EndIf
		Next nI
		
		If lOpen
			
			cTexto 				:= "Log da atualizacao " + CHR(13) + CHR(10) + cTexto
			__cFileLog := MemoWrite(Criatrab(,.f.) + ".LOG", cTexto)
			
			DEFINE FONT oFont NAME "Mono AS" SIZE 5,12
			DEFINE MSDIALOG oDlg TITLE "Atualizador [GH128871] - Atualizacao concluida." From 3,0 to 340,417 PIXEL
				@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
				oMemo:bRClicked := {||AllwaysTrue()}
				oMemo:oFont:=oFont
				DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
				DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
			ACTIVATE MSDIALOG oDlg CENTER
	
		EndIf
		
	EndIf
		
EndIf 	

Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MyOpenSM0Ex³ Autor ³Sergio Silveira       ³ Data ³07/01/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a abertura do SM0 exclusivo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao FIS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MyOpenSM0Ex(lOpenExc)

Local lOpen := .F.
Local nLoop := 0
Default lOpenExc := .F.

For nLoop := 1 To 20
	openSM0( cNumEmp,.F. )
	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex("SIGAMAT.IND")
		Exit	
	EndIf
	Sleep( 500 )
Next nLoop

If !lOpen
	Aviso( "Atencao !", "Nao foi possivel a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 )
EndIf

Return( lOpen )


Function HS_AtTbPre(dDatDes, cLstCon, cLstEmp)
 Local aRecnoSM0 	:= {}
 Local lOpen     	:= .F.
 Local nI
 
 ProcRegua(1)
 IncProc("Verificando integridade dos dicionários....")
 If (lOpen := MyOpenSm0Ex(.T.) )
       
 	dbSelectArea("SM0")
 	dbGotop()
 	While !Eof()
 	 If SM0->M0_CODIGO $ AllTrim(cLstEmp)
    Aadd(aRecnoSM0,{Recno(),SM0->M0_CODIGO, SM0->M0_CODFIL})
   EndIf
    
 		DbSkip()
 	EndDo	
 	
 	For nI := 1 To Len(aRecnoSM0)
			SM0->(dbGoto(aRecnoSM0[nI,1]))
			RpcSetType(2)
			RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
 		nModulo := 51 // modulo SIGAHSP
			lMsFinalAuto := .F.
			__cInternet := ""
		
   Processa({|| FS_TbPre(1, dDatDes, cLstCon), FS_TbPre(2, dDatDes, cLstCon), FS_TbPre(3, dDatDes, cLstCon)},"Processando tabelas de preco","Aguarde , atualizando tabelas de preco")
  
   RpcClearEnv()
			If !( lOpen := MyOpenSm0Ex(.T.) )
				Exit
		 EndIf
		Next nI
 EndIf
 
 HS_MsgInf("Atualização de tabelas de preços concluída com sucesso.", "Atenção", "Atualizador GH128871")
 
Return()


Static Function FS_TbPre(nVez, dDatDes, cLstCon)

 Local cSql    := ""
 Local aTabPre := {}
 Local cTabPre := ""
 Local lAteUrg := .F.
 Local cAlias  := IIf(nVez == 1, "GD7", IIf(nVez == 2, "GE7", "GG7"))
 Local cPref   := IIf(nVez == 1, "GD7.GD7", IIf(nVez == 2, "GE7.GE7", "GG7.GG7"))
 Local cPrefCpo := IIf(nVez == 1, "GD7->GD7", IIf(nVez == 2, "GE7->GE7", "GG7->GG7"))
 Local nCountReg := 0, nTotalReg := 0, nAtualReg := 0
 Local cTabUpd := ""
 Local cInSql := HS_InSql(AllTrim(cLstCon), 3)
 
 FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "INICIO -- FS_TBPRE Data : [" + DToC(Date()) + "] Hora : [" + Time() + "]" , 0, 0, {})
 
 DbSelectArea("GCY")
 DbSelectArea("GCZ")
 DbSelectArea(cAlias)
 
 cSql := "SELECT COUNT(*) NTOTREC " 
 cSql += "FROM " + RetSqlName(cAlias) + " " + cAlias + " "
 If !Empty(cInSql)
  cSql +=  "JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = " + cPref + "_NRSEQG AND GCZ.GCZ_CODCON IN (" + cInSql + ") "
 EndIf 
 cSql += "WHERE " + cPref + "_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias + ".D_E_L_E_T_ <> '*' AND " + cPref + "_DATDES >= '" + DTOS(dDatDes) + "' "
 
 cSql := ChangeQuery(cSql)
 TcQuery cSql NEW ALIAS "TMPDES"
 
 ProcRegua(TMPDES->NTOTREC)
 
 nTotalReg := TMPDES->NTOTREC
              
 DbSelectArea("TMPDES")
 DbCloseArea()
 
 cSql := "SELECT " + cPref + "_CODDES CODDES, " + cPref + "_CODLOC CODLOC, " + cPref + "_HORDES HORDES, " + cPref + "_CODCRM CODCRM, "
 cSql +=             cPref + "_CODATO CODATO, " + cPref + "_DATDES DATDES, " + cPref + "_SEQDES SEQDES, " + cAlias + ".R_E_C_N_O_ RECNO, "
 cSql +=             cPref + "_CODESP CODESP, " + cPref + "_DATDES URGDES, "
 cSql +=              "GCY.GCY_ATORIG ATORIG, GCY.GCY_IDADE IDADE, GCY.GCY_SEXO SEXO, GCY.GCY_ATENDI ATENDI, GCZ.GCZ_CODCON CODCON, GCZ.GCZ_CODPLA CODPLA " 
 cSql += "FROM " + RetSqlName(cAlias) + " " + cAlias + " "
 cSql +=  "JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = " + cPref + "_NRSEQG "
 
 If !Empty(cInSql)
  cSql +=  "AND GCZ.GCZ_CODCON IN (" + cInSql + ") "
 EndIf  
 
 cSql +=  "JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GCZ.GCZ_REGATE "
 cSql += "WHERE " + cPref + "_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias + ".D_E_L_E_T_ <> '*' AND " + cPref + "_DATDES >= '" + DTOS(dDatDes) + "' "
 
 cSql := ChangeQuery(cSql)
 TcQuery cSql NEW ALIAS "TMPDES"
 
 DbSelectArea("TMPDES")
 DbGotop()
 
 cTabUpd := RetSqlName(cAlias)
 
 While !TMPDES->(Eof())
  Begin Transaction
   
   nCountReg := 0
   While !TMPDES->(Eof()) .And. nCountReg <= 1024
    cTabPre := ""
    If !HS_ValDif(TMPDES->CODCON, TMPDES->CODPLA, "1", TMPDES->CODDES, STOD(TMPDES->DATDES))[1]                                                                                 
     If Len((aTabPre := HS_RTabPre("GC6", TMPDES->CODPLA, TMPDES->CODDES, STOD(TMPDES->DATDES)))) > 0
    
      cTabPre := aTabPre[1]
    
      lAteUrg := HS_FUrgDes(0, TMPDES->ATENDI, TMPDES->CODLOC, TMPDES->CODPLA, TMPDES->CODDES, STOD(TMPDES->DATDES), TMPDES->HORDES, TMPDES->URGDES)
    
      If HS_CPDifCon(TMPDES->ATENDI, TMPDES->CODCON, TMPDES->CODPLA, cTabPre, TMPDES->CODESP, TMPDES->CODDES, STOD(TMPDES->DATDES), TMPDES->HORDES, IIf(lAteUrg, "1", "0"), TMPDES->CODLOC)[3] > 0
       cTabPre := ""
      EndIf 
      
     EndIf
    EndIf 
    
    nAtualReg++
    IncProc("[" + cAlias + "] Atualizando despesas [" + AllTrim(Str(nAtualReg)) + "/" + AllTrim(Str(nTotalReg)) + "]")
    
    cSql := "UPDATE " + cTabUpd + " SET " + cAlias + "_TABELA = '" + PadR(cTabPre, 6) + "' WHERE R_E_C_N_O_ = " + AllTrim(Str(TMPDES->RECNO))
    TCSqlExec(cSql)
    
    nCountReg++
    
    TMPDES->(DbSkip())
   End
  
  End Transaction
  
  FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cAlias + " -- FS_TBPRE Data : [" + DToC(Date()) + "] Hora : [" + Time() + "]" , 0, 0, {})
 End 
 
 TMPDES->(DbCloseArea())
 
 DbSelectArea(cAlias)
  
 cAlias  := IIf(nVez == 1, "GD6", IIf(nVez == 2, "GE6", "GG6"))
 cPref   := IIf(nVez == 1, "GD6.GD6", IIf(nVez == 2, "GE6.GE6", "GG6.GG6"))
 cPrefCpo := IIf(nVez == 1, "GD6->GD6", IIf(nVez == 2, "GE6->GE6", "GG6->GG6"))
 
 cSql := "SELECT COUNT(*) NTOTREC "
 cSql += "FROM " + RetSqlName(cAlias) + " " + cAlias + " "
 
 If !Empty(cInSql)
  cSql +=  "JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = " + cPref + "_NRSEQG AND GCZ.GCZ_CODCON IN (" + cInSql + ") "
 EndIf 
  
 cSql += "WHERE " + cPref + "_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias + ".D_E_L_E_T_ <> '*' AND " + cPref + "_DATDES >= '" + DTOS(dDatDes) + "' "
 
 cSql := ChangeQuery(cSql)
 TcQuery cSql NEW ALIAS "TMPDES"
 
 ProcRegua(TMPDES->NTOTREC)
 
 nTotalReg := TMPDES->NTOTREC
 nAtualReg := 0
              
 DbSelectArea("TMPDES")
 DbCloseArea()
 
 cSql := "SELECT " + cPref + "_CODDES CODDES, " + cPref + "_CODLOC CODLOC, " + cPref + "_DATDES DATDES, " + cPref + "_SEQDES SEQDES, " 
 cSql +=           cAlias + ".R_E_C_N_O_ RECNO, GCZ.GCZ_CODCON CODCON, GCZ.GCZ_CODPLA CODPLA "
 cSql += "FROM " + RetSqlName(cAlias) + " " + cAlias + " "
 cSql +=  "JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = " + cPref + "_NRSEQG "
 
 If !Empty(cInSql)
  cSql +=  "AND GCZ.GCZ_CODCON IN (" + cInSql + ") "
 EndIf
 
 cSql += "WHERE " + cPref + "_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias + ".D_E_L_E_T_ <> '*' AND " + cPref + "_DATDES >= '" + DTOS(dDatDes) + "' "
 
 cSql := ChangeQuery(cSql)
 TcQuery cSql NEW ALIAS "TMPDES"
 
 DbSelectArea("TMPDES")
 DbGotop()
 
 cTabUpd := RetSqlName(cAlias)
 
 While !TMPDES->(Eof())
  Begin Transaction
   
   nCountReg := 0
   While !TMPDES->(Eof()) .And. nCountReg <= 1024
    cTabPre := ""
    If !HS_ValDif(TMPDES->CODCON, TMPDES->CODPLA, "3", TMPDES->CODDES, STOD(TMPDES->DATDES))[1]
     If Len((aTabPre := HS_RTabPre("GD8", TMPDES->CODPLA, TMPDES->CODDES, STOD(TMPDES->DATDES)))) > 0
      cTabPre := aTabPre[1]
     EndIf
    EndIf 
    
    nAtualReg++
    IncProc("[" + cAlias + "] Atualizando despesas [" + AllTrim(Str(nAtualReg)) + "/" + AllTrim(Str(nTotalReg)) + "]")
    
    cSql := "UPDATE " + cTabUpd + " SET " + cAlias + "_TABELA = '" + PadR(cTabPre, 6) + "' WHERE R_E_C_N_O_ = " + AllTrim(Str(TMPDES->RECNO))
    TCSqlExec(cSql)
    
    nCountReg++
    
    TMPDES->(DbSkip())
   End
   
  End Transaction 
  
  FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cAlias + " -- FS_TBPRE Data : [" + DToC(Date()) + "] Hora : [" + Time() + "]" , 0, 0, {})
 End
 
 TMPDES->(DbCloseArea())
 
 DbSelectArea(cAlias)
 DbSelectArea("GCS")
 
 cAlias  := IIf(nVez == 1, "GD5", IIf(nVez == 2, "GE5", "GG5"))
 cPref   := IIf(nVez == 1, "GD5.GD5", IIf(nVez == 2, "GE5.GE5", "GG5.GG5"))
 cPrefCpo := IIf(nVez == 1, "GD5->GD5", IIf(nVez == 2, "GE5->GE5", "GG5->GG5"))
 
 cSql := "SELECT COUNT(*) NTOTREC "
 cSql += "FROM " + RetSqlName(cAlias) + " " + cAlias + " "
 
 If !Empty(cInSql)
  cSql +=  "JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = " + cPref + "_NRSEQG AND GCZ.GCZ_CODCON IN (" + cInSql + ") "
 EndIf
  
 cSql += "WHERE " + cPref + "_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias + ".D_E_L_E_T_ <> '*' AND " + cPref + "_DATDES >= '" + DTOS(dDatDes) + "' "
 
 cSql := ChangeQuery(cSql)
 TcQuery cSql NEW ALIAS "TMPDES"
 
 ProcRegua(TMPDES->NTOTREC)
 
 nTotalReg := TMPDES->NTOTREC
 nAtualReg := 0
              
 DbSelectArea("TMPDES")
 DbCloseArea()
 
 cSql := "SELECT " + cPref + "_CODDES CODDES, " + cPref + "_CODLOC CODLOC, " + cPref + "_DATDES DATDES, " + cPref + "_SEQDES SEQDES, " 
 cSql +=            cAlias + ".R_E_C_N_O_ RECNO, GBI.GBI_TIPO TIPO, GBI.GBI_TIPKIT TIPKIT, GCZ.GCZ_CODCON CODCON, GCZ.GCZ_CODPLA CODPLA "
 cSql += "FROM " + RetSqlName(cAlias) + " " + cAlias + " "
 cSql +=  "JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND " + cPref + "_NRSEQG = GCZ.GCZ_NRSEQG "
 
 If !Empty(cInSql)
  cSql +=  "AND GCZ.GCZ_CODCON IN (" + cInSql + ") "
 EndIf 
 
 cSql +=  "JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND " + cPref + "_CODDES = GBI.GBI_PRODUT "
 cSql += "WHERE " + cPref + "_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias + ".D_E_L_E_T_ <> '*' AND " + cPref + "_DATDES >= '" + DTOS(dDatDes) + "' "
 
 cSql := ChangeQuery(cSql)
 TcQuery cSql NEW ALIAS "TMPDES"
 
 DbSelectArea("TMPDES")
 DbGotop()
 
 cTabUpd := RetSqlName(cAlias)
 
 While !TMPDES->(Eof())
  Begin Transaction
                   
   nCountReg := 0
   While !TMPDES->(Eof()) .And. nCountReg <= 1024
    cTabPre := ""
   
    If !HS_ValDif(TMPDES->CODCON, TMPDES->CODPLA, "0", TMPDES->CODDES, STOD(TMPDES->DATDES))[1]
     
     aTabPre := {}
   
     If     TMPDES->TIPO == "0" .Or. (TMPDES->TIPO == "4" .And. TMPDES->TIPKIT == "0") // 0-Materiais
 	    aTabPre := HS_RTabPre("GD9", TMPDES->CODPLA, TMPDES->CODDES, STOD(TMPDES->DATDES))
     ElseIf TMPDES->TIPO == "1" .Or. (TMPDES->TIPO == "4" .And. TMPDES->TIPKIT == "1") // 1-Medicamentos
    	 aTabPre := HS_RTabPre("GDA", TMPDES->CODPLA, TMPDES->CODDES, STOD(TMPDES->DATDES))
     ElseIf TMPDES->TIPO == "2" // 2-Rest./Frig.
     	aTabPre := HS_RTabPre("GDF", TMPDES->CODPLA, TMPDES->CODDES, STOD(TMPDES->DATDES))
     EndIf
     
     If Len(aTabPre) > 0
      cTabPre := aTabPre[1]
     EndIf
    
    EndIf
    
    nAtualReg++
    IncProc("[" + cAlias + "] Atualizando despesas [" + AllTrim(Str(nAtualReg)) + "/" + AllTrim(Str(nTotalReg)) + "]")
    
    cSql := "UPDATE " + cTabUpd + " SET " + cAlias + "_TABELA = '" + PadR(cTabPre, 6) + "' WHERE R_E_C_N_O_ = " + AllTrim(Str(TMPDES->RECNO))
    TCSqlExec(cSql)
    
    nCountReg++
   
    TMPDES->(DbSkip())
   End
  
  End Transaction 
  
  FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cAlias + " -- FS_TBPRE Data : [" + DToC(Date()) + "] Hora : [" + Time() + "]" , 0, 0, {})
 End
 
 TMPDES->(DbCloseArea())
 
 FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "FIM -- FS_TBPRE Data : [" + DToC(Date()) + "] Hora : [" + Time() + "]" , 0, 0, {})
Return()