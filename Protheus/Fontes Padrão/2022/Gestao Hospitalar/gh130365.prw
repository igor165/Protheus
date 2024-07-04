#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ-ÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³GH130365  ³ Autor ³ MICROSIGA             ³ Data ³ 08/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao Principal                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GH130365()

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
 
	If MsgYesNo("Deseja atualizar os campos referentes ao Sequencial do Pacote das Tabelas GGs?")
	 If Select("SM0") > 0
	  SM0->(DBCLOSEAREA())
	 EndIf

	 HS_AtuGGs()
		 
	EndIf

Return()

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

Function HS_AtuGGs()
 Local aRecnoSM0 	:= {}
 Local lOpen     	:= .F.
 Local nI
 
 ProcRegua(1)
 IncProc("Verificando integridade dos dicionários....")
 If (lOpen := MyOpenSm0Ex(.T.) )
       
 	dbSelectArea("SM0")
 	dbGotop()
 	While !Eof()
   Aadd(aRecnoSM0,{Recno(),SM0->M0_CODIGO, SM0->M0_CODFIL})
 		DbSkip()
 	EndDo	
 	
 	For nI := 1 To Len(aRecnoSM0)
			SM0->(dbGoto(aRecnoSM0[nI,1]))
			RpcSetType(2)
			RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
 		nModulo := 51 // modulo SIGAHSP
			lMsFinalAuto := .F.
		
   Processa({|| FS_AtuGGs(1), FS_AtuGGs(2), FS_AtuGGs(3)},"Processando Despesas GGs","Aguarde , atualizando Sequencial do Pacote")
  
   RpcClearEnv()
			If !( lOpen := MyOpenSm0Ex(.T.) )
				Exit
		 EndIf
		Next nI
 EndIf
 
 HS_MsgInf("Atualização dos campos referentes ao Sequencial do Pacote das Tabelas GGs concluída com sucesso.", "Atenção", "Atualizador GH130365")
 
Return()

Static Function FS_AtuGGs(nVez)

 Local cSql     := "", cSeqDes := ""
 Local cAlias   := IIf(nVez == 1, "GG5", IIf(nVez == 2, "GG6", "GG7"))
 Local cPref    := IIf(nVez == 1, "GG5.GG5", IIf(nVez == 2, "GG6.GG6", "GG7.GG7"))
 Local cPrefCpo := IIf(nVez == 1, "GG5->GG5", IIf(nVez == 2, "GG6->GG6", "GG7->GG7"))
 
 ProcRegua(200)
 
 cSql := "SELECT " + cPref + "_SEQDES SEQDES, " + cPref + "_CODPCO CODPCO, " + cPref + "_NRSEQG NRSEQG, " + cAlias + ".R_E_C_N_O_ RECNO "
 cSql += " FROM " + RetSqlName(cAlias) + " " + cAlias + " "
 cSql += " WHERE " + cPref + "_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias + ".D_E_L_E_T_ <> '*' AND " + cPref + "_SEQGE7 = '" + SPACE(Len(GG5->GG5_SEQGE7)) + "' "
 cSql += " ORDER BY NRSEQG, CODPCO"

 cSql := ChangeQuery(cSql)
 TcQuery cSql NEW ALIAS "TMPGG"
 
 DbSelectArea("TMPGG")
 DbGotop()
 
 While !TMPGG->(Eof())
  //Verificar se tem apenas um pacote na guia com mesmo codigo
  cSql := "SELECT COUNT(*) NCOUNT "
  cSql += " FROM " + RetSqlName("GE7") + " GE7 "
  cSql += " WHERE GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' AND GE7.GE7_NRSEQG = '" + TMPGG->NRSEQG + "' "
  cSql += " AND GE7.GE7_CODDES = '" + TMPGG->CODPCO + "'	"

  cSql := ChangeQuery(cSql)
  TcQuery cSql NEW ALIAS "QTDREG"
 
  DbSelectArea("QTDREG")
  DbGoTop()
   
  If QTDREG->NCOUNT <> 1 
   QTDREG->(DbCloseArea())
   DbSelectArea("TMPGG")
   DbSkip()
   Loop    
  EndIf                   
  QTDREG->(DbCloseArea())

  //Trazer SEQDES do Pacote - GE7  
  cSql := "SELECT GE7.GE7_SEQDES SEQDES"
  cSql += " FROM " + RetSqlName("GE7") + " GE7 "
  cSql += " WHERE GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' AND GE7.GE7_NRSEQG = '" + TMPGG->NRSEQG + "' "
  cSql += " AND GE7.GE7_CODDES = '" + TMPGG->CODPCO + "' "
  
  cSql := ChangeQuery(cSql)
  TcQuery cSql NEW ALIAS "TMPGE"
 
  DbSelectArea("TMPGE")
  DbGoTop()
  cSeqDes := TMPGE->SEQDES
  TMPGE->(DbCloseArea())

  DbSelectArea(cAlias)
  DbGoto(TMPGG->RECNO)
  IncProc("Atualizando despesas..[" + cAlias + "] SEQDES - " + TMPGG->SEQDES)
  FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Atualizando despesas..[" + cAlias + "] SEQDES - " + TMPGG->SEQDES , 0, 0, {})
  
  RecLock(cAlias, .F.)
   &(cPrefCpo + "_SEQGE7") := cSeqDes
  MsUnlock()
  
  DbSelectArea("TMPGG")
  TMPGG->(DbSkip())
 End
 
 TMPGG->(DbCloseArea())
 
Return()