#INCLUDE "HSPAHABX.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"  
                      

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHABX  บ Autor ณ Patricia Queiroz   บ Data ณ  13/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Regras de Identificacao da Filial de Faturamen_บฑฑ
ฑฑบ          ณ to.                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHABX()

 Private cGcmCodCon := ""
 Private aRotina := {{OemtoAnsi(STR0001)	, "axPesqui"  , 0, 1}, ;  //"Pesquisar"
                     {OemtoAnsi(STR0002),  "HS_ABX"		  , 0, 2}, ;  //"Visualizar"
                     {OemtoAnsi(STR0003),  "HS_ABX"		  , 0, 3}, ;  //"Incluir"
                     {OemtoAnsi(STR0004),  "HS_ABX"		  , 0, 4}, ;  //"Alterar"
                     {OemtoAnsi(STR0005),  "HS_ABX"		  , 0, 5}, ;  //"Excluir"
                     {OemtoAnsi(STR0006),  "HS_RefReg", 0, 2}}     //"Refazer"
                     

 mBrowse(06, 01, 22, 75, "GHY") 
 
Return(Nil) 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_ABX    บ Autor ณ Patricia Queiroz   บ Data ณ  13/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Tratamento das funcoes                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
                                                                            */
Function HS_ABX(cAlias, nReg, nOpc) 

 Local nOpcA := 0
 Local aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local aCposAlt := {}
 
 Private nOpcE := aRotina[nOpc, 4]
 Private aTela := {}
 Private aGets := {}
 Private oGHY                     
 Private aChave := {}
 
 If nOpcE == 4
  aAdd(aCposAlt, "GHY_FILFAT")
 Else
  DbSelectArea("SX3")
  DbSetOrder(1) 
  DbSeek("GHY")
  While !Eof() .And. SX3->X3_ARQUIVO == "GHY"
   aAdd(aCposAlt, SX3->X3_CAMPO)
   DbSkip()
  End 
 EndIf 
 
 RegToMemory("GHY", (nOpcE == 3)) 

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 100, .T., .T.})

 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd   //"Regras de Identifica็ใo da Filial de Faturamento"

 oGHY := MsMGet():New("GHY", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}, aCposAlt,,,,, oDlg)
 oGHY:oBox:Align   := CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(FS_GrvABX(nOpcE), oDlg:End(), nOpcA := 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 1 .And. nOpcE <> 2
  While __lSx8
   ConfirmSx8()
  EndDo  
 Else
  While __lSx8
   RollBackSx8()
  EndDo   
 EndIf  

Return(Nil)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvABX บAutor  ณPatricia Queiroz    บ Data ณ  13/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGravacao das informacoes.                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                      
Static Function FS_GrvABX(nOpcE)

 Local lRet   := .T.
 Local aArea  := GetArea()
 Local aChave := {}

 If (lRet := Obrigatorio(aGets, aTela) .And. FS_VldFil(M->GHY_CODCON, M->GHY_CODPLA, M->GHY_CODLOC, M->GHY_CODTPG, M->GHY_VIGENC, nOpcE))
  Begin Transaction

  If nOpcE == 3 .Or. nOpcE == 4 
   RecLock("GHY", nOpcE == 3)
    HS_GrvCpo("GHY")  
   MsUnLock()                  
   
   If nOpcE == 3
    FS_GrRegra(M->GHY_CODCON, M->GHY_CODPLA, M->GHY_CODLOC, M->GHY_CODTPG, nOpcE)
   EndIf   
  ElseIf nOpcE == 5
   RecLock("GHY", .F.) 
    DbDelete()
   MsUnLock()
   
   aChave := FS_EncChav(M->GHY_CODPLA, M->GHY_CODLOC, M->GHY_CODTPG)
   
   DbSelectArea("GHZ")
   DbSetOrder(2) //GHZ_FILIAL + GHZ_CODCON + GHZ_CODPLA + GHZ_CODLOC + GHZ_CODTPG 
   If DbSeek(xFilial("GHZ") + GHY->GHY_CODCON + aChave[1] + aChave[2] + aChave[3])
    If GHZ->GHZ_QTDREG == 1
     RecLock("GHZ", .F.)
      DbDelete()
     MsUnlock()
     HS_MsgInf(STR0008, STR0009, STR0010) //"As guias que possuirem a regra excluํda nใo serใo atualizadas."###"Aten็ใo"###"Exclusใo da regra"
    Else
     RecLock("GHZ", .F.)
      GHZ->GHZ_QTDREG := GHZ->GHZ_QTDREG - 1
     MsUnLock()      
    EndIf 
   EndIf 
  EndIf
  End Transaction
 EndIf 
 
 RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldABX บAutor  ณPatricia Queiroz    บ Data ณ  13/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValidacoes do cadastro.                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                      
Function HS_VldABX()

 Local lRet  := .T.
 Local aArea := GetArea()
  
 If ReadVar() == "M->GHY_CODCON"
  If !(lRet := HS_SeekRet("GA9", "M->GHY_CODCON", 1, .F., "GHY_NOMCON", "GA9_NOME"))
   HS_MsgInf(STR0011, STR0009, STR0012) //"O conv๊nio informado nใo existe."###"Aten็ใo"###"Valida็ใo do conv๊nio"
  Else
   cGcmCodCon  := M->GHY_CODCON
  EndIf 
 ElseIf ReadVar() == "M->GHY_CODPLA" 
  If !(lRet := HS_SeekRet("GCM","M->GHY_CODCON+M->GHY_CODPLA", 1, .F., "GHY_DESPLA", "GCM_DESPLA"))
   HS_MsgInf(STR0013, STR0009, STR0014) //"O plano informado nใo existe."###"Aten็ใo"###"Valida็ใo do plano"
    M->GHY_DESPLA:=" "
  Else
    M->GHY_DESPLA:=GCM->GCM_DESPLA
  EndIf 
 ElseIf ReadVar() == "M->GHY_CODLOC" 
  If !(lRet := HS_SeekRet("GCS", "M->GHY_CODLOC", 1, .F., "GHY_NOMLOC", "GCS_NOMLOC"))
   HS_MsgInf(STR0015, STR0009, STR0016) //"O setor informado nใo existe."###"Aten็ใo"###"Valida็ใo do setor"
  EndIf 
 ElseIf ReadVar() == "M->GHY_CODTPG" 
  If !(lRet := HS_SeekRet("GCU", "M->GHY_CODTPG", 1, .F., "GHY_DESTPG", "GCU_DESTPG"))
   HS_MsgInf(STR0017, STR0009, STR0018) //"O tipo de guia informado nใo existe."###"Aten็ใo"###"Valida็ใo do tipo de guia"
  EndIf 
 EndIf
      
 RestArea(aArea)

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldFil บAutor  ณPatricia Queiroz    บ Data ณ  13/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida se ja existe registro com o mesmo: filial, convenio บฑฑ
ฑฑบ          ณ plano, setor, tipo de guia e vigencia.                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                      
Static Function FS_VldFil(cCodCon, cCodPla, cCodLoc, cCodTpg, cVigenc, nOpcE)

 Local lRet  := .T.
 Local aArea := GetArea()
 Local aSM0  := SM0->(GetArea())
 Local cSql  := ""
 
 DbSelectArea("SM0")
 DbSetOrder(1) // M0_CODIGO + M0_FILIAL
 If !(lRet := DbSeek(IIF(FindFunction("FWGRPCompany"), FWGRPCompany(),SM0->M0_CODIGO)  + 	M->GHY_FILFAT))
  HS_MsgInf(STR0019, STR0009, STR0020) //"A filial informada nใo existe."###"Aten็ใo"###"Valida็ใo da filial"
 EndIf 
 
 If lRet
  If !(lRet := !(M->GHY_FILFAT == xFilial("GHY")))
   HS_MsgInf(STR0021, STR0009, STR0020) //"A filial informada nใo pode ser a mesma filial corrente."###"Aten็ใo"###"Valida็ใo da filial"
  EndIf
 EndIf
 
 If nOpcE == 3 .And. lRet
  
  If !(lRet := Empty(xFilial("GA9")) .And. Empty(xFilial("GCM")))
   HS_MsgInf(STR0025, STR0009, STR0026) //"Nใo ้ possํvel cadastrar uma regra sem que as tabelas de Conv๊nio e Plano sejam compartilhadas"###"Aten็ใo"###"Valida็ใo da filial"
  Else 
   DbSelectArea("GHY")
   
   cSql := "SELECT COUNT(*) NTOTAL "
   cSql += "FROM " + RetSqlName("GHY") + " GHY "
   cSql += "WHERE GHY.GHY_FILIAL = '" + xFilial("GHY") + "' AND GHY.D_E_L_E_T_ <> '*' "
   cSql += "AND GHY.GHY_CODCON = '" + cCodCon + "' "
   cSql += "AND GHY.GHY_CODPLA = '" + cCodPla + "' "
   cSql += "AND GHY.GHY_CODLOC = '" + cCodLoc + "' "
   cSql += "AND GHY.GHY_CODTPG = '" + cCodTpg + "' "
   cSql += "AND GHY.GHY_VIGENC = '" + DTOS(cVigenc) + "'"
 
   cSql := ChangeQuery(cSql)
   DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), "TMPGHY",.T.,.T.) 
  
   If !(lRet := !(TMPGHY->NTOTAL > 0))
    HS_MsgInf(STR0022, STR0009, STR0023) //"Jแ existe uma regra com esses dados."###"Aten็ใo"###"Valida็ใo de regra"
   EndIf   
   DbCloseArea()
  EndIf
 EndIf
 
 RestArea(aSM0) 
 RestArea(aArea) 

Return(lRet)  



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_EncChavบAutor  ณPatricia Queiroz    บ Data ณ  14/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณEncontra a regra.                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                      
Static Function FS_EncChav(cCodPla, cCodLoc, cCodTpg)

 Local aArea := GetArea()
 Local cCdPlano := "", cCdSetor := "", cCdTipoG := ""

 If Empty(cCodPla)
  cCdPlano := "1"
 Else
  cCdPlano := "0" 
 EndIf 
 
 If Empty(cCodLoc)
  cCdSetor := "1" 
 Else
  cCdSetor := "0" 
 EndIf  
 
 If Empty(cCodTpg)
  cCdTipoG := "1"
 Else           
  cCdTipoG := "0"
 EndIf

 RestArea(aArea)

Return({cCdPlano, cCdSetor, cCdTipoG})    



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrRegraบAutor  ณPatricia Queiroz    บ Data ณ  13/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGrava a regra no controle de regras.                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                      
Static Function FS_GrRegra(cCodCon, cCodPla, cCodLoc, cCodTpg, nOpcE)

 Local aArea  := GetArea()
 Local cSql   := ""   
 Local aChave := {}
 
 aChave := FS_EncChav(cCodPla, cCodLoc, cCodTpg) 
 
 cSql := "SELECT COUNT(*) NRTOT "
 cSql += "FROM " + RetSqlName("GHZ") + " GHZ "
 cSql += "WHERE GHZ.GHZ_FILIAL = '" + xFilial("GHZ") + "' AND GHZ.D_E_L_E_T_ <> '*	' "
 cSql += "AND GHZ.GHZ_CODCON = '" + cCodCon + "' "
 cSql += "AND GHZ.GHZ_CODPLA = '" + aChave[1] + "' "
 cSql += "AND GHZ.GHZ_CODLOC = '" + aChave[2] + "' "
 cSql += "AND GHZ.GHZ_CODTPG = '" + aChave[3] + "' "
 
 cSql := ChangeQuery(cSql)
 DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), "TMPGHZ",.T.,.T.) 
 
 DbSelectArea("TMPGHZ")
 DbGoTop()
 
 If TMPGHZ->NRTOT > 0
  DbSelectArea("GHZ")
  DbSetOrder(2)//GHZ_FILIAL + GHZ_CODCON + GHZ_PRIORI + GHZ_CODPLA + GHZ_CODLOC + GHZ_CODTPG
  DbSeek(xFilial("GHZ") + cCodCon + aChave[1] + aChave[2] + aChave[3]) 
  RecLock("GHZ", .F.)
   GHZ->GHZ_QTDREG := GHZ->GHZ_QTDREG + 1
  MsUnLock()
 Else
  RecLock("GHZ", .T.)
   GHZ->GHZ_FILIAL := xFilial("GHZ")
   GHZ->GHZ_CODCON := cCodCon
   GHZ->GHZ_CODPLA := aChave[1]
   GHZ->GHZ_CODLOC := aChave[2]
   GHZ->GHZ_CODTPG := aChave[3]
   GHZ->GHZ_PRIORI := "9999"
   GHZ->GHZ_QTDREG := GHZ->GHZ_QTDREG + 1
  MsUnLock()   
 EndIf
 
 DbSelectArea("TMPGHZ")
 DbCloseArea() 
 RestArea(aArea)

Return(Nil)   



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_RefReg บAutor  ณPatricia Queiroz    บ Data ณ  14/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para informar a prioridade 9999 para todas as regras.บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                      
Function HS_RefReg()

 Local aArea := GetArea()
 
 DbSelectArea("GHZ")
 DbSetOrder(2) //GHZ_FILIAL + GHZ_CODCON + GHZ_CODPLA + GHZ_CODLOC + GHZ_CODTPG
 
 If MsgYesNo(STR0024)  //"Para todas as regras serแ atribuํda prioridade 9999. Deseja continuar?"
  While !Eof() .And. GHZ->GHZ_FILIAL == xFilial("GHZ")
   RecLock("GHZ", .F.)
    GHZ->GHZ_PRIORI := "9999"
   MsUnLock()
   DbSkip()
  End
 EndIf 
 
 RestArea(aArea)

Return(Nil)          
