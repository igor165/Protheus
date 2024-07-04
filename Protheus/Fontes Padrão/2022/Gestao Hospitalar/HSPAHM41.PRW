#INCLUDE "HSPAHM41.ch"
#include "protheus.ch"
#include "TopConn.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM41  บ Autor ณ Marcelo Jose       บ Data ณ  24/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ TRANSFERENCIA DE ENDERECOS POR PRONTUARIOS                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR SAME-SPP                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ   
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ BOPS ณ  Motivo da Alteracao                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ            ณ        ณ      ณ                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function HSPAHM41()
 Private aRotina  := {}, cCadastro := STR0001 //"TRANSFERE ENDERECOS DE PRONTUARIOS"
 Private cGsDCtrl := ""
 Private cGsDTipo := ""
 
 aRotina := MenuDef()
             	
 DbSelectArea("GSB")
 DbSetOrder(1)
 mBrowse(06, 01, 22, 75, "GSB")
Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_TrMM41 บAutor  ณLuiz Pereira S. Jr. บ Data ณ  02/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para transeferencia de Multi-Prontuแrio              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_TrMM41() 
 Local aArea     := GetArea()
 Local cListB    := " "
 Local nOpcA     := 0
 Local aSize     := {}
 Local aObjects  := {}
 Local aItensMar := {}, aSix := {}
 Local cCpoChave := "GSB_REGGER+GSB_CODEND"
 Local cFunAM    := "HS_M41CLK"
 Private oTik     := LoadBitmap(GetResources(), "LBTIK")
 Private oNo      := LoadBitmap(GetResources(), "LBNO")
 Private oEnderA, oDescriA, oEnderP, oDescriP, oEnderI, oDescriI, oVemObj
 Private cCodEndA := CriaVar("GSD_CODEND"), cCodEndP := CriaVar("GSD_CODEND"), cCodEndI := CriaVar("GSD_CODEND")
 Private cDesEndA := SPACE(LEN(GSD->GSD_DESEND)), cDesEndP  := SPACE(LEN(GSD->GSD_DESEND)), cDesEndI  := SPACE(LEN(GSD->GSD_DESEND))
 Private aCodEnd  := HS_CfgSx3("GSB_CODEND")
 Private cEndTip  := "", cEndCod := ""
 Private lSelTudo := .F.
 Private aButtons := {{'PENDENTE',{|| lSelTudo := !lSelTudo, FS_MkTdM41() } ,STR0025}} // "Selecionar Todos" 
 Private aItemGsi := {}
 
 aSize    := MsAdvSize(.T.) 
 AAdd( aObjects, { 100, 021, .T., .T., .T. } ) 
 AAdd( aObjects, { 100, 069, .T., .T. } )	
 AAdd( aObjects, { 100, 010, .T., .T., .T. } )	
 aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs    := MsObjSize( aInfo, aObjects, .T. )

 cGsDTipo := "1" 
 CGsdCtrl := "0" //Filtra apenas enderecos multi-prontuarios na consulta padrao
 
 DEFINE MSDIALOG oDlg FROM 0,0 TO 600,1020 PIXEL TITLE OemToAnsi(STR0016) //"Tranfer๊ncia de Prontuแrios para Endere็os Multi-prontuแrio"
  oPEnd	:=	tPanel():New(aPObjs[1, 1], aPObjs[1, 2],, oDlg,,,,,, aPObjs[1, 3], aPObjs[1, 4])
  oPEnd:Align := CONTROL_ALIGN_TOP
  
  	oSay1        := tSay():New(13,10,{|| STR0017 },oPEnd,,,,,,.T.,,,130,10)  //"Endereco Multi-Prontuario Ambulatorial : "
  @ 020, 110 MsGet oEnderA VAR cCodEndA VALID FS_VldEnd(cCodEndA, @cDesEndA, @oEnderA, "1") F3 aCodEnd[SX3->(FieldPos("X3_F3"))] Picture aCodEnd[SX3->(FieldPos("X3_PICTURE"))] OF oDlg Pixel
   oEnderA:bGotFocus := {||cGsDTipo := "1" } // Filtra enderecos ambulatorio
  @ 020, 190 MsGet oDescriA VAR cDesEndA OF oDlg Pixel
		 oDescriA:Disable()
		
	oSay2        := tSay():New(28,10,{|| STR0018 },oPEnd,,,,,,.T.,,,130,10) //"Endereco Multi-Prontuario Pto. Atend. : "  
  @ 035, 110 MsGet oEnderP VAR cCodEndP VALID FS_VldEnd(cCodEndP, @cDesEndP, @oEnderP, "2") F3 aCodEnd[SX3->(FieldPos("X3_F3"))] Picture aCodEnd[SX3->(FieldPos("X3_PICTURE"))] OF oDlg Pixel
   oEnderP:bGotFocus := {||cGsDTipo := "2" } // Filtra enderecos PA
	 @ 035, 190 MsGet oDescriP VAR cDesEndP OF oDlg Pixel
	 	oDescriP:Disable()
		
	oSay3        := tSay():New(43,10,{|| STR0019 },oPEnd,,,,,,.T.,,,130,10) //"Endereco Multi-Prontuario Internacao : "
  @ 050, 110 MsGet oEnderI VAR cCodEndI VALID FS_VldEnd(cCodEndI, @cDesEndI, @oEnderI, "3") F3 aCodEnd[SX3->(FieldPos("X3_F3"))] Picture aCodEnd[SX3->(FieldPos("X3_PICTURE"))] OF oDlg Pixel
   oEnderI:bGotFocus := {||cGsDTipo := "3" } // Filtra enderecos Internacao
  @ 050, 190 MsGet oDescriI VAR cDesEndI OF oDlg Pixel
 		oDescriI:Disable()
 		
 	oVemObj := HS_MBrow(oDlg, "GSB", {aPObjs[2,1] + 10, aPObjs[2,2], aPObjs[2,3]+175, aPObjs[2,4]-400},,,/*cCpoLeg*/, /*aResLeg*/, "GSB_OK", /*aResMar*/, @aItensMar, cCpoChave, /*bViewReg*/, .T.,,,, cFunAM)
		
		oDlg:aControls[13]:bLostFocus := {|| oVemObj:SetFocus()}
		
  oPPesq	:=	tPanel():New(aPObjs[3, 1], aPObjs[3, 2],, oDlg,,,,,, aPObjs[3, 3], aPObjs[3, 4])
  oPPesq:Align := CONTROL_ALIGN_BOTTOM

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, oDlg:End()  }, {|| nOpcA := 0, oDlg:End() },,aButtons)
 HS_DtvFilt("GSB") 

 If nOpcA == 1
  Begin Transaction 
  Processa( {||  FS_GrvTrM(aItensMar) } )
  End Transaction
 EndIf
 If !Empty(aItemGsi)
  HSPAHR05(aItemGsi)
 Endif
 
  While __lSx8
  ConfirmSx8()
 End
   
 cGsDCtrl := ""
 cGsDTipo := ""
               
 RestArea(aArea)
Return()


Static Function FS_MkTdM41()
 Local aArea   := GetArea()
 Local cSql    := ""
 Local cNotIn  := ""
 Local cInTipo := ""
 
 If !Empty(cCodEndA)
  cNotIn  := "'" + cCodEndA + "'"
  cInTipo := "'1'"  
 EndIf 
 If !Empty(cCodEndP)
  If !Empty(cNotIn)
   cNotIn  += ",'" + cCodEndP + "'"
   cInTipo += ",'2'"
  Else
   cNotIn  += "'" + cCodEndP + "'"
   cInTipo += "'2'"
  EndIf
 EndIf 
 If !Empty(cCodEndI)
  If !Empty(cNotIn)
   cNotIn  += ",'" + cCodEndI + "'"
   cInTipo += ",'3'"
  Else
   cNotIn  += "'" + cCodEndI + "'"
   cInTipo += "'3'"
  EndIf
 EndIf
 
 cSql := "UPDATE " + RetSqlName("GSB") 
 cSql += "  SET GSB_OK = '" + Iif(lSelTudo, __cHS_Marca, Space(Len(GSB->GSB_OK))) + "' "
 cSql += "WHERE GSB_FILIAL = '" + xFilial("GSB") + "' AND D_E_L_E_T_ <> '*' AND GSB_CODEND NOT IN ("  + cNotIn + ") AND "
 cSql += "EXISTS (SELECT GSD.GSD_CODEND "
 cSql +=         "FROM " + RetSqlName("GSD") + " GSD "
 cSql +=         "WHERE GSD.GSD_FILIAL = '" + xFilial("GSD") + "' AND GSD.D_E_L_E_T_ <> '*'  AND GSD.GSD_CODEND = GSB_CODEND AND GSD.GSD_TIPEND IN (" + cInTipo + "))"
 
 TcSqlExec(cSql)
 
 oVemObj:Refresh() 
 RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvTrM บAutor  ณLuiz Pereira S. Jr. บ Data ณ  05/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que grava a transferencia de endere็os.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_GrvTrM(aItensMar)

 Local aArea := GetArea()
 Local nFor, cLogCodEnd :="", cLogDesEnd := ""
Local cMsgRev:=""
Local lRet:=.T. 
 If lSelTudo
 
  cSql := "SELECT * " 
  cSql += "FROM " + RetSqlName("GSB") + " GSB "
  cSql += "WHERE GSB.GSB_FILIAL = '" + xFilial("GSB") + "' AND GSB.D_E_L_E_T_ <> '*' AND "
  cSql +=      " GSB.GSB_OK = '" + __cHS_Marca + "' " 
  
  cSql := ChangeQuery(cSql)
  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TMPTRM",.T.,.T.)
  
  DbSelectArea("TMPTRM")
  DbGotop()
  
	While TMPTRM->(!Eof())
   DbSelectArea("GSD")
   DbSetOrder(1) // GSD_FILIAL+GSD_CODEND+GSD_TIPEND+GSD_ESPMED
   If DbSeek(xFilial("GSD") + TMPTRM->GSB_CODEND)  
    DbSelectArea("GSB")
    DbSetOrder(1) // GSB_FILIAL+GSB_REGGER+GSB_CODEND
    If DbSeek(xFilial("GSB") + TMPTRM->GSB_REGGER + TMPTRM->GSB_CODEND)
     cLogCodEnd := GSB->GSB_CODEND
     cLogDesEnd := GSB->GSB_DESEND
				lRet:=FS_VLDTEN()
				If lRet  .and. GSD->GSD_ENDTIP <> "1" 
     RecLock("GSB", .F.)
						If GSD->GSD_TIPEND == "1"  // 1=Ambulatorial;2=Pronto Atendimento;3=Hospitalar
      GSB->GSB_CODEND := cCodEndA          
      GSB->GSB_DESEND := cDesEndA
						ElseIf GSD->GSD_TIPEND == "2" 
      GSB->GSB_CODEND := cCodEndP
      GSB->GSB_DESEND := cDesEndP
						ElseIf GSD->GSD_TIPEND == "3" 
      GSB->GSB_CODEND := cCodEndI
      GSB->GSB_DESEND := cDesEndI
     EndIf
     GSB->GSB_TIPEND 	:= GSD->GSD_TIPEND
     MsUnlock()
					FS_GrvLgM41(cLogCodEnd, cLogDesEnd)
				Elseif	GSD->GSD_ENDTIP <> "1" 
				cMsgRev += STR0004 +" "+TMPTRM->GSB_REGGER +"  "+ Iif(GSB->(FieldPos("GSB_REGATE")) > 0,TMPTRM->GSB_REGATE," ") +"  "+STR0035 +iif(GSD->GSD_TIPEND == "1",cCodEndA,iif(GSD->GSD_TIPEND == "2" ,cCodEndP,cCodEndI)  ) + CHR(10)				
				Endif
			Endif
 
		EndIf
   
	TMPTRM->(DbSkip())
	Enddo  
	TMPTRM->(dbclosearea())
 Else
  For nFor := 1 To Len(aItensMar)
   DbSelectArea("GSD")
   DbSetOrder(1) // GSD_FILIAL+GSD_CODEND+GSD_TIPEND+GSD_ESPMED
   cChave := Substr(aItensMar[nFor,1], Len(GSB->GSB_REGGER)+1, Len(GSD->GSD_CODEND) )
   If DbSeek(xFilial("GSD") + cChave)  
    DbSelectArea("GSB")
			DbSetOrder(1) // GSB_FILIAL+GSB_REGGER+GSB_CODEND +GSB_REGATE
    If DbSeek(xFilial("GSB") + aItensMar[nFor,1])
     cLogCodEnd := GSB->GSB_CODEND
     cLogDesEnd := GSB->GSB_DESEND
				lRet:=FS_VLDTEN()																
				If lRet .and. GSD->GSD_ENDTIP <> "1" 
     RecLock("GSB", .F.)
					If GSD->GSD_TIPEND == "1"   // 1=Ambulatorial;2=Pronto Atendimento;3=Hospitalar
      GSB->GSB_CODEND := cCodEndA          
      GSB->GSB_DESEND := cDesEndA
					ElseIf GSD->GSD_TIPEND == "2"  
      GSB->GSB_CODEND := cCodEndP
      GSB->GSB_DESEND := cDesEndP
					ElseIf GSD->GSD_TIPEND == "3" 
      GSB->GSB_CODEND := cCodEndI
      GSB->GSB_DESEND := cDesEndI
     EndIf
					GSB->GSB_TIPEND 	:= GSD->GSD_TIPEND
     MsUnlock()
    
    While __lSx8
     ConfirmSx8()
    End  
    
					FS_GrvLgM41(cLogCodEnd, cLogDesEnd)
				ElseIf GSD->GSD_ENDTIP <> "1"
					cMsgRev += STR0004 +" "+GSB->GSB_REGGER +"  "+Iif(GSB->(FieldPos("GSB_REGATE")) > 0,"Reg."+ GSB->GSB_REGATE," ") +"  "+STR0035 +iif(GSD->GSD_TIPEND == "1",cCodEndA,iif(GSD->GSD_TIPEND == "2" ,cCodEndP,cCodEndI)  ) + CHR(10)				
                 
                Endif
			Endif
	
		Endif


Next    

EndIf

If !Empty(cMsgRev)
  HS_MsgInf(cMsgRev, STR0022, STR0023) 

 EndIf
            
 RestArea(aArea)
Return()

Static Function FS_GrvLgM41(cLogCodEnd, cLogDesEnd)

 // Log de Transferencia
 DbSelectAreA("GSI")
 RecLock("GSI", .T.)
  GSI->GSI_FILIAL := xFilial("GSI")
  GSI->GSI_SEQTRA := GetSx8Num("GSI", "GSI_SEQTRA" )
  GSI->GSI_DATTRA := dDataBase
  GSI->GSI_HORTRA := Subs(Time(),1,5)
  GSI->GSI_CODEND := GSB->GSB_CODEND
  GSI->GSI_DESEND := GSB->GSB_DESEND
  GSI->GSI_TIPEND := GSD->GSD_TIPEND
  GSI->GSI_ENDTIP := "0" // Sempre e Multi-prontuario
  GSI->GSI_CODENO := cLogCodEnd
  GSI->GSI_DESENO := cLogDesEnd
  GSI->GSI_TPENDO := GSD->GSD_TIPEND
  GSI->GSI_ENDTPO := GSD->GSD_ENDTIP
  GSI->GSI_REGGER := GSB->GSB_REGGER
  If GSI->(FieldPos("GSI_REGATE")) > 0
 	 GSI->GSI_REGATE := GSB->GSB_REGATE
  Endif
 MsUnlock()
 
 aAdd(aItemGsi, {GSI->GSI_CODEND, GSI->GSI_DESEND, GSI->GSI_HORTRA, GSI->GSI_DATTRA, GSI->GSI_CODENO,;
 																GSI->GSI_DESENO, GSI->GSI_REGGER,HS_IniPadr("GBH", 1, GSI->GSI_REGGER, "GBH_NOME",, .F.),GSI->GSI_SEQTRA,IIf(GSI->(FieldPos("GSI_REGATE")) > 0 ,GSI->GSI_REGATE ,"" ) })
  
 If GSD->GSD_ENDTIP == "1" // Pasta
  //Libera Pasta
  RecLock("GSD", .F.)
   GSD->GSD_STATUS := "0"
   GSD->GSD_TIPEND := Space(Len(GSD->GSD_TIPEND))
  MsUnlock()
 EndIf
 
Return()


Function HS_M41CLK()
 Local lRet := .T.
 
 DbSelectArea("GSD")
 DbSetOrder(1) // GSD_FILIAL+GSD_CODEND+GSD_TIPEND+GSD_ESPMED
 If DbSeek(xFilial("GSD") + GSB->GSB_CODEND)
  If GSD->GSD_TIPEND == "1" .And. Empty(cCodEndA) //1=Ambulatorial;2=Pronto Atendimento;3=Hospitalar
   lRet := .F.
   HS_MsgInf( STR0020 + HS_RDescrB("GSD_TIPEND", GSD->GSD_TIPEND) + STR0021 , STR0022, STR0023) // "O endere็o de destino do tipo "###" nใo estแ preenchido."###"Atencao..."###"Selecao"
  ElseIf GSD->GSD_TIPEND == "2" .And. Empty(cCodEndP)
   lRet := .F.
   HS_MsgInf( STR0020 + HS_RDescrB("GSD_TIPEND", GSD->GSD_TIPEND) + STR0021 , STR0022, STR0023) // "O endere็o de destino do tipo "###" nใo estแ preenchido."###"Atencao..."###"Selecao"
  ElseIf GSD->GSD_TIPEND == "3" .And. Empty(cCodEndI)
   lRet := .F.
   HS_MsgInf( STR0020 + HS_RDescrB("GSD_TIPEND", GSD->GSD_TIPEND) + STR0021 , STR0022, STR0023) // "O endere็o de destino do tipo "###" nใo estแ preenchido."###"Atencao..."###"Selecao"
  EndIf
 EndIf

Return(lRet)

Static Function FS_VldEnd(cCodigo, cDescEnd, oEnd, cTipo)
Local lRet := .T.
Local aArea := GetArea()
Local cTmp

 If !Empty(cCodigo)
  cTmp     := POSICIONE("GSD", 1, XFilial("GSD") + cCodigo, "GSD_DESEND")
  If GSD->GSD_TIPEND == cTipo .And. GSD->GSD_ENDTIP = "0"
 	 cDescEnd := cTmp
   cEndTip  := GSD->GSD_ENDTIP
  Else
   HS_MsgInf( STR0026, STR0022, STR0023) //"Endere็o nใo permitido."###"Atencao"###"Selecao"
   lRet := .F. 
  EndIf

  If Empty(cDescEnd) .And. lRet
   HS_MsgInf( STR0024, STR0022, STR0023) //"Codigo do endereco nใo encontrado"###"Atencao"###"Selecao"
   lRet := .F. 
  EndIf

  If lRet
   oEnd:Disable()
   FS_MonList()
  EndIf  
 EndIf            
 
aArea := GetArea()
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MonListบAutor  ณLuiz Pereira S. Jr. บ Data ณ  02/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o vetor com os dados que aparecerao no listbox para   บฑฑ
ฑฑบ          ณserem transferidos para o endereco multi prontuario.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_MonList()       
 Local cNotIn := ""
 
 If !Empty(cCodEndA)
  cNotIn := cCodEndA
 EndIf 
 If !Empty(cCodEndP)
  If !Empty(cNotIn)
   cNotIn += "/" + cCodEndP
  Else
   cNotIn += cCodEndP
  EndIf
 EndIf 
 If !Empty(cCodEndI)
  If !Empty(cNotIn)
   cNotIn += "/" + cCodEndI
  Else
   cNotIn += cCodEndI
  EndIf
 EndIf             
 
 HS_DtvFilt("GSB") 
 HS_AtvFilt("GSB", "!(GSB->GSB_CODEND $ '" + cNotIn + "')")  
 oVemObj:Refresh()
 
Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ     TELA DE APRESENTACAO   AUTOR: MARCELO JOSE      DATA: 20/01/2005    ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
FUNCTION HS_TraM41(cAliasCEP, nRegCEP, nOpcCEP)
 Local oDlg        
 Local nOpcA  := 0 
 Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {} 
                
 Private aTela := {}, aGets := {}
 Private oGSB
 	
 DbSelectArea("GSD")
 DbSetOrder(1)
 If !DbSeek(xFilial("GSD") + GSB->GSB_CODEND )
  HS_MsgInf( STR0024, STR0022, STR0023) //"Codigo do endereco nใo encontrado"###"Atencao"###"Selecao"
  DbSelectArea("GSB")
  DbSetOrder(1)
  Return(Nil)          
 EndIf
 
 If GSD->GSD_ENDTIP <> "1"
  HS_MsgInf( STR0034, STR0022, STR0023) //"Esta rotina s๓ permite transfer๊ncia de endere็os do tipo Pasta"###"Codigo do endereco nใo encontrado"###"Atencao"###"Selecao"
  DbSelectArea("GSB")
  DbSetOrder(1)
  Return(Nil)        
 EndIf
 
 //cGsDCtrl := GSD->GSD_ENDTIP
 cGsDTipo := GSD->GSD_TIPEND + " "
 
 RegToMemory("GSB", aRotina[nOpcCEP,4]==3)
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 030, .T., .T. } )	
 AAdd( aObjects, { 100, 070, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 nOpcA := 0
 
 aCposAlt := {"GSB_CODEND"}
 
 DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel
  oGSB := MsMGet():New("GSB", nRegCEP, nOpcCEP	,,,,, aPObjs[1],aCposAlt, 3,,,oDlg)
  oGSB:oBox:Align := CONTROL_ALIGN_ALLCLIENT
    
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(Obrigatorio(aGets, aTela) .AND. HS_ValM41() , oDlg:End(), nOpcA := 0)}, ;
                                                  {|| nOpcA := 0, oDlg:End()} )
 
 If nOpcA == 1
  Begin Transaction
   FS_GrvM41()
  End Transaction 
 EndIf
 While __lSx8
  ConfirmSx8()
 End  
 
 DbSelectArea("GSB")
 DbSetOrder(1)
Return(Nil)                       

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VALTSPPบ Autor ณ MARCELO JOSE       บ Data ณ  02/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida OCORRENCIAS NA GETDADOS                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
FUNCTION HS_ValM41()
 Local lRet := .T., aArea := GetArea()
 Local cDestTip := "", cDesEndTip := ""
 
 If M->GSB_CODEND == GSB->GSB_CODEND
 	HS_MsgInf(STR0011, STR0022, STR0027) //"O endere็o destino deve ser diferente do endere็o destino"###"Atencao"###"Valida็ใo"
  lRet := .F.
  RETURN( lRet )         
 EndIf
  
 DbSelectArea("GSD")
 DbSetOrder(1)
 If !(lRet := DbSeek(xFilial("GSD") + M->GSB_CODEND ) )
  HS_MsgInf(STR0024, STR0022, STR0027) //"Codigo do endereco nใo encontrado"###"Atencao"###"Valida็ใo"
 Else
  
  // Verifica se a pasta de destino nao esta ocupada e ativa //
  If lRet := ((GSD->GSD_ENDTIP == "1") .And. (GSD->GSD_STATUS == "0") .And. (GSD->GSD_EATIVO == "0"))
	  cDestTip 		:= GSD->GSD_TIPEND
	  cDesEndTip := GSD->GSD_ENDTIP
	  DbSelectArea("GSD")
	  DbSetOrder(1)
	  If DbSeek(xFilial("GSD") + GSB->GSB_CODEND ) // ORIGEM
	   If (cDesEndTip == "1" .And. GSD->GSD_TIPEND <> cDestTip) .And. !Empty(cDestTip)
	    HS_MsgInf(STR0028, STR0022, STR0027) //"O endere็o destino do tipo pasta deve ter mesmo tipo de atendimento da origem"###"Atencao"###"Valida็ใo"
	    lRet := .F.
	   End
	  EndIf
	 Else
	 	HS_MsgInf(STR0029 + GSD->GSD_DESEND + STR0030, STR0022, STR0031)//"A pasta de destino ["###"] esta ocupada ou esta inativa."###"Aten็ใo"###"Valida็ใo dos Campos"
  EndIf
  
  If lRet 
   M->GSB_DESEND := GSD->GSD_DESEND
  EndIf
 EndIf
 
 // Verifica se o registro esta bloqueado (pasta), caso nao esteja, entao bloqueia //
 If (lRet .And. (cDesEndTip == "1"))
 	If !(lRet := LockByName("A95GSD" + M->GSB_CODEND, .T., .T., .F.))
			HS_MsgInf(STR0032, STR0022, STR0033)//"Este endere็o esta reservado por outro usuแrio"###"Aten็ใo"###"Registro Bloqueado"
 	EndIf
	EndIf
 
 RestArea(aArea) 

RETURN( lRet )         
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvM41 บ Autor ณ MARCELO JOSE       บ Data ณ  02/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ GRAVA AS MUDANCAS DE ENDERECOS                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
STATIC FUNCTION FS_GrvM41()
 Local aArea := GetArea()
 Local cTipOri := "", cCodOri := "", cDesOri := "", cConOri := ""
 
 DbSelectArea("GSD")
 DbSetOrder(1)
 If DbSeek(xFilial("GSD") + GSB->GSB_CODEND )  /* END ORIGEM */

  If GSD->GSD_ENDTIP == "1" /* TIPO PASTA */
   cTipOri := GSD->GSD_TIPEND
   cCodOri := GSB->GSB_CODEND
   cDesOri := GSD->GSD_DESEND 
   cConOri := GSD->GSD_ENDTIP
   RecLock("GSD", .F.)
    GSD->GSD_STATUS := "0" /* COLOCA STATUS = LIVRE PARA ENDERECO TIPO PASTA*/
    GSD->GSD_TIPEND := Space(Len(GSD->GSD_TIPEND))
   MsUnLock()
   
  EndIf  
  If DbSeek(xFilial("GSD") + M->GSB_CODEND )  /* END DESTINO */
   If GSD->GSD_ENDTIP == "1" /* TIPO PASTA */
    RecLock("GSD", .F.)
     GSD->GSD_STATUS := "1" /* COLOCA STATUS = ocupado PARA ENDERECO TIPO PASTA */
     GSD->GSD_TIPEND := cTipOri
    MsUnLock()    
    UnLockByName("A95GSD" + M->GSB_CODEND, .T., .T., .F.)
   EndIf      
  ENDIF
   
  RecLock("GSB", .F.)
   GSB->GSB_FILIAL := xFILIAL("GSB")
   GSB->GSB_CODEND := M->GSB_CODEND
   GSB->GSB_DESEND := GSD->GSD_DESEND
			GSB->GSB_TIPEND := GSD->GSD_TIPEND   
   GSB->GSB_LOGARQ := HS_LogArq()
  MsUnLock() 
  
  DbSelectAreA("GSI")  
  RecLock("GSI", .T.)
   GSI->GSI_FILIAL := xFilial("GSI")
   GSI->GSI_SEQTRA := GetSx8Num("GSI", "GSI_SEQTRA" )
   GSI->GSI_DATTRA := dDataBase
   GSI->GSI_HORTRA := Subs(Time(),1,5)
   GSI->GSI_CODEND := M->GSB_CODEND
   GSI->GSI_DESEND := GSD->GSD_DESEND
   GSI->GSI_TIPEND := GSD->GSD_TIPEND
   GSI->GSI_ENDTIP := "1" // Sempre e PASTA
   GSI->GSI_CODENO := cCodOri
   GSI->GSI_DESENO := cDesOri
   GSI->GSI_TPENDO := cTipOri
   GSI->GSI_ENDTPO := cConOri
   GSI->GSI_REGGER := GSB->GSB_REGGER
   If GSI->(FieldPos("GSI_REGATE")) > 0
   	GSI->GSI_REGATE := GSB->GSB_REGATE 
   Endif
  MsUnlock()
         
 EndIf  

 RestArea(aArea) 

RETURN( NIL )                                                    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 10/06/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transao a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ณ    3 - Gera arquivo TXT para exportacao                      ณ
//ณ    4 - Recebe arquivo TXT                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aRotina :=	{{OemToAnsi(STR0002)  ,	"axPesqui"   	, 0, 1, 0, nil},;  //"Pesquisar"
	             	 {OemToAnsi(STR0003)  ,"HS_TraM41"		, 0, 4, 0, nil},;  //"Trasnferir"
	             	 {OemToAnsi(STR0015)  ,"HS_TrMM41()"	, 0, 4, 0, nil}}   //"Transf. Multi"
Return(aRotina)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLDTIP บAutor  ณSAUDE               บ Data ณ  10/30/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVALIDA ENDEREวO Jม CADASTRADO PARA O PRONTUARIO             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/



Static Function FS_VLDTEN()
 Local   lRet:= .T.
 Local aArea := GetArea()
 Local cQry := "", cEndTip := "", cTipEnd := ""

 DbSelectArea("GSD")
 DbSetOrder(1)
 If Dbseek(xFilial("GSD") + GSB->GSB_CODEND)
    cEndTip := GSD->GSD_ENDTIP
   	cTipEnd := IIf(GSD->GSD_ENDTIP == "1", GSB->GSB_TIPEND, GSD->GSD_TIPEND)
 
		cQry := " SELECT COUNT(*) nTotReg"
		cQry += " FROM " + RetSqlName("GSB") + " GSB		JOIN " + RetSqlName("GSD") + " GSD" 
		cQry += "		ON GSB.GSB_CODEND = GSD.GSD_CODEND	AND GSD.GSD_FILIAL = '" + xFilial("GSD") + "'"
		cQry += "		AND GSD.D_E_L_E_T_ <> '*'" 
		cQry += "		AND GSD.GSD_TIPEND = '" + cTipEnd + "'" 
		cQry += "		AND GSD.GSD_ENDTIP = '" + cEndTip + "'" 
		cQry += "		AND GSD.GSD_EATIVO = '0'" 
		cQry += " WHERE GSB.GSB_FILIAL = '" + xFilial("GSB") + "'	AND GSB.D_E_L_E_T_ <> '*'"
		cQry += "		AND GSB.GSB_REGGER = '" + GSB->GSB_REGGER + "'"
		If GSB->(FieldPos("GSB_REGATE")) > 0
		cQry += "		AND GSB.GSB_REGATE = '" + GSB->GSB_REGATE + "'"
		Endif
		cQry += "		AND (GSB.GSB_CODEND = '" + cCodEndA + "'"
		cQry += "		OR GSB.GSB_CODEND = '" + cCodEndP + "'"
		cQry += "		OR GSB.GSB_CODEND = '" + cCodEndI + "')"

							
		cQry := ChangeQuery(cQry)
		dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQry), 'QRYTOT', .F., .T.)
		dbSelectArea("QRYTOT")
		DbGoTop()
		If (QRYTOT->nTotReg > 0)
			lRet := .F. 
		EndIf
  QRYTOT->(dbCloseArea())
 EndIf

 RestArea(aArea) 
Return(lRet)
