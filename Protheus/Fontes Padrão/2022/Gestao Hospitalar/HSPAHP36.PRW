#INCLUDE "HSPAHP36.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP36  º Autor ³ José Orfeu         º Data ³  12/02/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cancelamento de Atendimento                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP36()

HS_MsgInf(STR0023, STR0007, STR0005) //"Funcao obsoleta, utilizar atraves das rotinas de Atendimento !""###"Atenção"  ###"Cancelamento de Atendimento"

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_P36Can  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 21.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao Cancelamento do Atendimento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_P36Can()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSP                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_P36Can()

Local aArea 		:= GetArea()
Local lRet 			:= .F.
Local cString := " ", cSql:=""
Local nCont   := 0
Local oDlgMot, oMotivo,  oDesMot, nOpcA := 0
Local	cCadastro := OemToAnsi(STR0005) //"Cancelamento de Atendimento"
Local cCodMot  := CriaVar("GCY_CODMOT")
Local cDesMot  := SPACE(LEN(GES->GES_DESCRI)) 
Local aCodMot  := HS_CfgSx3("GCY_CODMOT")

If GCY->GCY_STATUS <> "0"
 HS_MsgInf(STR0031, STR0007, STR0005)	//"Atendimento não pode ser cancelado porque possui anamnese digitada"###"Atenção"###"Cancelamento de Atendimento"
	Return(.F.)
EndIf

If GCY->GCY_TPALTA == "99"
 HS_MsgInf(STR0006, STR0007, STR0005)	//"Atendimento ja foi cancelado"###"Atenção"###"Cancelamento de Atendimento"
	Return(.F.)
EndIf

If !Empty(GCY->GCY_TPALTA)
	HS_MsgInf(STR0024, STR0007, STR0005) //"Atendimento não pode ser cancelado porque ja recebeu alta"###"Atenção"###"Cancelamento de Atendimento"
	Return(.F.)
EndIf

If ExistBlock("HSP36CANC")
	lRet := ExecBlock("HSP36CANC", .F., .F., {GCY->GCY_REGATE})
	If !lRet
		Return(.F.)
	EndIf
EndIf

If !LockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GCY->GCY_REGATE,.T.)
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GCY->GCY_REGATE)
EndIf

 cSQL := " SELECT GAI_SOLICI,COUNT(*) AS QTDE FROM " + RetSqlName("GAJ") + " GAJ "
 cSQL += " JOIN " + RetSqlName("GAI") + " GAI ON GAI.GAI_FILIAL = '" + xFilial("GAI") + "' "
 cSQL += " AND GAJ.GAJ_FILIAL = '"+xFilial("GAJ")+"' AND GAI_REGATE='" + GCY->GCY_REGATE + "' AND GAI_FLGATE IN ('2','4') "
 cSQL += " AND GAI.D_E_L_E_T_ <> '*' "
 cSQL += " AND GAJ.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE GAJ_SOLICI = GAI_SOLICI AND GAJ_QTDDEV <> GAJ_QTDATE GROUP BY GAI_SOLICI"

 cSql := ChangeQuery(cSql)
 TcQuery cSql NEW ALIAS "QRYP36"
 DbSelectArea("QRYP36")
 DbGotop()
 IF QRYP36->QTDE > 0 
  	HS_MsgInf(STR0022+ QRYP36->GAI_SOLICI, STR0007, STR0005) //"Atendimento não pode ser cancelado porque ja recebeu alta"###"Atenção"###"Cancelamento de Atendimento"
   QRYP36->(DbCloseArea())
   RestArea(aArea)
	  UnLockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)  
	  HSPDelFiCo("ExecM24",GCY->GCY_REGATE)
	  Return(.F.)
 EndIf
 QRYP36->(DbCloseArea())

cString := ""
DbSelectArea("GCZ")
DbSetOrder(2)      
DbSeek(xFilial("GCZ")+GCY->GCY_REGATE)
Do While !Eof() .And. GCZ->GCZ_FILIAL == xFilial("GCZ") .And. GCZ->GCZ_REGATE == GCY->GCY_REGATE
 If GCZ->GCZ_STATUS <> "0"
  cString += IIF(Empty(cString), GCZ->GCZ_NRSEQG, " - " + GCZ->GCZ_NRSEQG) 	 
	EndIf 
	DbSkip()
Enddo

If !Empty(cString)
	HS_MsgInf(STR0025 + cString, STR0007, STR0005) //"Atendimento nao pode ser cancelado porque existem guias faturadas: "###"Atenção"###"Cancelamento de Atendimento"

	RestArea(aArea)
	UnLockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.) 
	HSPDelFiCo("ExecM24",GCY->GCY_REGATE)
	Return .F.
Endif

DbSelectArea("GD5")
DbSetOrder(3)
DbSeek(xFilial("GD5") + GCY->GCY_REGATE, .T.)
If !Eof() .And. GD5->GD5_FILIAL == xFilial("GD5") .And. GD5->GD5_REGATE == GCY->GCY_REGATE
 HS_MsgInf(STR0030, STR0007, STR0005)  //"Este atendimento possui guias com despesas lancadas e nao pode ser cancelado"###"Atenção"###"Cancelamento de Atendimento"
 UnLockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)    
 HSPDelFiCo("ExecM24",GCY->GCY_REGATE)
 Return(.F.)
Endif 

DbSelectArea("GD6")
DbSetOrder(3)
DbSeek(xFilial("GD6") + GCY->GCY_REGATE, .T.)
If !Eof() .And. GD6->GD6_FILIAL == xFilial("GD6") .And. GD6->GD6_REGATE == GCY->GCY_REGATE
 HS_MsgInf(STR0030, STR0007, STR0005)  //"Este atendimento possui guias com despesas lancadas e nao pode ser cancelado"###"Atenção"###"Cancelamento de Atendimento"
 UnLockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)  
 HSPDelFiCo("ExecM24",GCY->GCY_REGATE)
 Return(.F.)
Endif 

DbSelectArea("GD7")
DbSetOrder(3)
DbSeek(xFilial("GD7") + GCY->GCY_REGATE, .T.)
If !Eof() .And. GD7->GD7_FILIAL == xFilial("GD7") .And. GD7->GD7_REGATE == GCY->GCY_REGATE
 HS_MsgInf(STR0030, STR0007, STR0005)  //"Este atendimento possui guias com despesas lancadas e nao pode ser cancelado"###"Atenção"###"Cancelamento de Atendimento"
 UnLockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)      
 HSPDelFiCo("ExecM24",GCY->GCY_REGATE)
 Return(.F.)
Endif      

If MsgYesNo(STR0008 + GCY->GCY_REGATE + "-" + AllTrim(GCY->GCY_NOME), STR0007) //"Confirma o cancelamento da conta "###"Atenção"###"Cancelamento de Atendimento"
	If !Empty(GCY->GCY_QUAINT)
		If !MsgYesNo(STR0009, STR0007) //"Todas as movimentações de leito do paciente serão apaGCYas, Confirma"###"Atenção"
			UnLockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)   
			HSPDelFiCo("ExecM24",GCY->GCY_REGATE)
			Return .T. 
		Endif
	Endif
	
	nOpcA   := 0
	
	DEFINE MSDIALOG oDlgMot TITLE cCadastro From 09, 00 to 17, 80 of oMainWnd
 	 @ 043, 015 Say aCodMot[SX3->(FieldPos("X3_TITULO"))] Of oDlgMot Pixel COLOR CLR_BLUE
	 @ 041, 032 MsGet oMotivo VAR cCodMot VALID FS_VldMot(cCodMot, @cDesMot) F3 aCodMot[SX3->(FieldPos("X3_F3"))] Picture aCodMot[SX3->(FieldPos("X3_PICTURE"))] OF oDlgMot Pixel
	 @ 041, 072 MsGet oDescri VAR cDesMot OF oDlgMot Pixel
	 oDescri:lReadOnly := .T.
	ACTIVATE MSDIALOG oDlgMot CENTERED ON INIT EnchoiceBar(oDlgMot, 	{|| nOpcA := 1, oDlgMot:End()}, ;
																																																																		{|| nOpcA := 0, oDlgMot:End()})
	
	If nOpcA == 0
		UnLockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.) 
		HSPDelFiCo("ExecM24",GCY->GCY_REGATE)
		Return .T.
	EndIf
	
	Begin Transaction
	
	 //VERIFICAR SE O PACIENTE TEM OUTROS ATENDIMENTOS SE NAO TEM
	 
  cSql:= "SELECT COUNT(*) TOTAL "
  cSql+= "FROM " + RetSqlName("GCY") + " GCY "
  cSql+= "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY")  + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_TPALTA <> '99' AND "
  cSql+=       "GCY.GCY_REGGER = '" + GCY->GCY_REGGER + "' AND GCY.GCY_REGATE <> '" + GCY->GCY_REGATE + "' "
  cSql+= "GROUP BY GCY.GCY_REGGER"
  
  TCQuery cSql New Alias "TMPCNT"
  
  // Cancela primeiro atendimento do paciente
  DbSelectArea("TMPCNT")
  DbGotop()
  If TMPCNT->TOTAL == 0 .Or. Eof() // NÃO EXISTEM MAIS ATENDIMENTOS PARA ESTE PRONTUÁRIO....
   DbSelectArea("GBH")
   DbSetOrder(1) //GBH_FILIAL+GBH_CODPAC
   If DbSeek(xFilial("GBH") + GCY->GCY_REGGER)
    RecLock("GBH", .F.)
     GBH->GBH_IDPATE := "0"
    MsUnlock()
   EndIf	 
	 EndIf
	 TMPCNT->(DbCloseArea())
     
	 DbSelectArea("GCY")
  RecLock("GCY", .F.)
  	GCY->GCY_DATALT := Date()
	  GCY->GCY_TPALTA := "99" // Alta por cancenlamento
	  GCY->GCY_HORALT := Time()
	  GCY->GCY_LOGCAN := HS_LogArq()
	  GCY->GCY_CODMOT := cCodMot 
	 MsUnLock()             
	    
	 // Cancela guia 
	 DbSelectArea("GCZ")
	 DbSetOrder(2)
	 DbSeek(xFilial("GCZ") + GCY->GCY_REGATE)
	 While !Eof() .And. GCZ->GCZ_FILIAL == xFilial("GCZ") .And. GCZ->GCZ_REGATE == GCY->GCY_REGATE
	  RecLock("GCZ", .F.)
	   GCZ->GCZ_CANCEL := "1"	  
	  MsUnLock()
	 
	  DbSkip()
	 End 
	 
	 // Libera leito e exclui movimentações do leito
	 If !Empty(GCY->GCY_QUAINT)
 		DbSelectArea("GAV")
 		DbSetOrder(2)
 		DbSeek(xFilial("GAV") + GCY->GCY_REGATE)
 		Do While !Eof() .And. GAV->GAV_REGATE == GCY->GCY_REGATE
 			RecLock("GAV", .F.)
 			 GAV->GAV_REGATE := SPACE(Len(GAV->GAV_REGATE))
 			 GAV->GAV_REGGER := SPACE(Len(GAV->GAV_REGGER))
 			 GAV->GAV_NOME   := SPACE(Len(GAV->GAV_NOME  ))
 			 GAV->GAV_DATATE := CToD("")
     GAV->GAV_HORATE := SPACE(Len(GAV->GAV_HORATE))
     GAV->GAV_CODCRM := SPACE(Len(GAV->GAV_CODCRM))
     GAV->GAV_MEDICO := SPACE(Len(GAV->GAV_MEDICO))
 			 GAV->GAV_OBSERV := SPACE(Len(GAV->GAV_OBSERV))
 			 GAV->GAV_RESERV := SPACE(Len(GAV->GAV_RESERV))
 			 GAV->GAV_STATUS := "0"
 			MsUnLock()
 			
 			DbSeek(xFilial("GAV") + GCY->GCY_REGATE)
 		Enddo
		
		 DbSelectArea("GB1")
		 DbSetOrder(1)
		 DbSeek(xFilial("GB1") + GCY->GCY_REGATE)
		 Do While !Eof() .And. GB1->GB1_REGATE == GCY->GCY_REGATE
		 	RecLock("GB1", .F., .T.)
		 	DbDelete()
		 	MsUnLock()
		 	
		 	WriteSx2("GB1")
			 DbSkip()
		 Enddo
		 
		 DbSelectArea("GB2")
		 DbSetOrder(1)
		 DbSeek(xFilial("GB2") + GCY->GCY_REGATE)
		 Do While !Eof() .And. GB2->GB2_REGATE == GCY->GCY_REGATE
		 	RecLock("GB2", .F., .T.)
		 	DbDelete()
		 	MsUnLock()
		 	
		 	WriteSx2("GB2")
			 DbSkip()
		 Enddo
	 Endif                                                                           
	 
	 // Cancela coleta
	 DbSelectArea("GGO")
  DbSetOrder(3)
  DbSeek(xFilial("GGO") + GCY->GCY_REGATE)
  While !Eof() .And. GCY->GCY_REGATE == GCY->GCY_REGATE
   RecLock("GGO", .F.)
    GGO->GGO_SITCOL := "4"
   MsUnLock()
    
   DbSkip()
  End
	
	End Transaction	
EndIf

UnLockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GCY->GCY_REGATE)

RestArea(aArea)

Return(Nil)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_P36Ret  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 21.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao Cancelamento do Atendimento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_P36Ret()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSP                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_P36Ret(cAliasM24, nRegM24, nOpcM24)
Local aArea := GetArea(), lOk := .F., oEncGcy, nBottom := 0, nRight := 0

Private cOldCodLoc := "", cOldQuaInt := "", cOldLeiInt := ""

If GCY->GCY_TPALTA <> "99"
	HS_MsgInf(STR0010, STR0007, STR0005) //"Atendimento ja foi retornado"###"Atenção"###"Cancelamento de Atendimento"
	Return(.T.)
EndIf

If !LockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GCY->GCY_REGATE,.T.)
	Return(Nil)
Else
	HSPGerFiCo("ExecM24",GCY->GCY_REGATE)
EndIf

If MsgYesNo(STR0011 + GCY->GCY_REGATE + "-" + AllTrim(GCY->GCY_NOME), STR0007) //"Confirma o retorno da conta "###"Atenção"
 If !(lOk := Empty(GCY->GCY_QUAINT))
  DbSelectArea("GAV")
  DbSetOrder(1)
  If !(lOk := !(!DbSeek(xFilial("GAV") + GCY->GCY_CODLOC + GCY->GCY_QUAINT + GCY->GCY_LEIINT) .Or. GAV->GAV_STATUS <> "0"))
   RegToMemory("GCY", .F.)
   HS_DefVar("GCS", 1, M->GCY_CODLOC, aVarDef)
   M->GCY_QUAINT := Space(Len(M->GCY_QUAINT))
   M->GCY_LEIINT := Space(Len(M->GCY_LEIINT))
   If MsgYesNo(STR0027, STR0007) //"Atenção" //"Leito não disponivel, deseja escolher outro?"
    DEFINE MSDIALOG oDlgRet TITLE OemToAnsi(cCadastro) FROM 000, 000 TO 150, 650 PIXEL
     nBottom := __DlgHeight(oDlgRet)
     nRight 	:= __DlgWidth(oDlgRet)

     oEncGcy := MsMGet():New("GCY", nRegM24, nOpcM24,,,, {"GCY_CODLOC", "GCY_NOMLOC", "GCY_QUAINT", "GCY_LEIINT"}, {013, 001, nBottom, nRight}, {"GCY_QUAINT"}, 2,,,, oDlgRet)
     oEncGcy:oBox:Align := CONTROL_ALIGN_ALLCLIENT
    ACTIVATE MSDIALOG oDlgRet CENTERED ON INIT EnchoiceBar(oDlgRet, {|| lOk := .T., oDlgRet:End()}, {|| lOk := .F., oDlgRet:End()})
   EndIf
  EndIf      
 EndIf
           
 If lOk
  DbSelectArea("GCY")
  RecLock("GCY", .F.)
  GCY->GCY_TPALTA := Space(Len(GCY->GCY_TPALTA))
  GCY->GCY_DATALT := CToD("")
  GCY->GCY_HORALT := Space(Len(GCY->GCY_HORALT))
  GCY->GCY_CODMOT := Space(Len(GCY->GCY_CODMOT))
  GCY->GCY_LOGCAN := HS_LogArq()
  MsUnLock()
  
  DbSelectArea("GCZ")
	 DbSetOrder(2)
	 DbSeek(xFilial("GCZ") + GCY->GCY_REGATE)
	 While !Eof() .And. GCZ->GCZ_FILIAL == xFilial("GCZ") .And. GCZ->GCZ_REGATE == GCY->GCY_REGATE
	  RecLock("GCZ", .F.)
	   GCZ->GCZ_CANCEL := "0"	  
	  MsUnLock()
	 
	  DbSkip()
	 End 
	 
  If !Empty(GCY->GCY_QUAINT)
   HS_GrvMovH(GCY->GCY_REGATE, GCY->GCY_CODLOC, GCY->GCY_QUAINT, GCY->GCY_LEIINT, "0", GCY->GCY_DATATE, GCY->GCY_HORATE,,,,, .T.)
  Endif 
 EndIf 
EndIf

UnLockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GCY->GCY_REGATE)

RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VldMot º Autor ³ Gilson dA sILVA    º Data ³ 23/05/05    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida Motivo de Cancelamento                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_VldMot(cCodigo, cDescricao)
Local lRet := .T.
Local aArea := GetArea()

If Empty(cCodigo)
	HS_MsgInf(STR0028, STR0007, STR0005) //"Codigo do Motivo de Cancelamento Invalido."###"Atenção"###"Cancelamento de Atendimento"
	RestArea(aArea)
	Return(.F.)
EndIf 	

DbSelectArea("GES")
DbSetOrder(1)
If !(DbSeek(xFilial("GES") + cCodigo))
	HS_MsgInf(STR0029, STR0007, STR0005) //"Motivo de Cancelamento não encontrado"###"Atenção"###"Cancelamento de Atendimento"
	lRet := .F.                       
Else
 cDescricao := GES->GES_DESCRI
Endif
RestArea(aArea)
Return lRet
