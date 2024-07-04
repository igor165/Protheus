#INCLUDE "HSPFUNCB.ch"
#INCLUDE "MSMGADD.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//Cores
#Define CLR_VERMELHO  RGB(255,048,048)	//Cor Vermelha
#Define CLR_AZUL	  RGB(058,074,119)	//Cor Azul

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_MntGEV บAutor  ณDaniel Peixoto      บ Data ณ  19/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o aCols e aHeader para utilizacao na geracao de tituloบฑฑ
ฑฑบ          ณcom multiplas natureza                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_MntGEV(nValor)
Local aAreaOld := GetArea()
Local nOpcA    := 0, nGDOpc := GD_INSERT + GD_UPDATE + GD_DELETE
Local oDlg
Local aSize    := {}, aObjects := {}, aInfo := {}, aPObjs := {}
Local aCampos	 := {"EV_NATUREZ", ;
							            "EV_VALOR"  , ;
							            "EV_PERC"   , ;
							            "EV_RATEICC"}
Local nX := 0

 dbSelectArea("SX3")
 dbSetOrder(1) //X3_ARQUIVO + X3_ORDEM
 dbSeek("SEV")
 nX := 1
 While ! SX3->(EOF()) .And. (SX3->X3_Arquivo == "SEV")
 	If X3USO(SX3->X3_Usado) .And. cNivel >= SX3->X3_NIVEL
 		If nX == 1
 			nRecnoSx3 := SX3->(Recno())
 			// Adiciona os campos na ordem em que devem aparecer
 			For nX := 1 To Len(aCampos)
 				SX3->(DbSetOrder(2))
 				SX3->(DBSeek(Pad(aCampos[nX],10)))
 				Aadd(aHeaderSev,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,,SX3->X3_CONTEXT,,,,,} )
 				If SX3->X3_TIPO == "C"
 					If Alltrim(SX3->X3_CAMPO) == "EV_NATUREZ" // Natureza
 					 aHeaderSev[nX][9] := SX3->X3_F3
 					ElseIf Alltrim(SX3->X3_CAMPO) == "EV_RATEICC"
 						aHeaderSev[nX][12] := "2"
 						aHeaderSev[nX][14] := "V"
 					EndIf
 				Else
 					If Alltrim(SX3->X3_CAMPO) == "EV_PERC" // Percentual
 						aHeaderSev[nX][6] := "HS_CalcGEV("+STR(nValor)+")"
 						// Inclui em aCols como caracter para ser possivel a visualizacao na
 						// tela, por ser a ultima coluna da getdados
 						aHeaderSev[nX][8]	:= "C"
 						aHeaderSev[nX][5]	:= 2
 					ElseIf Alltrim(SX3->X3_CAMPO) == "EV_VALOR"
 						aHeaderSev[nX][6] := "HS_CalcGEV("+STR(nValor)+")"
 					Endif
 				EndIf
 			Next
 			SX3->(DbSetOrder(1))
 			SX3->(DbGoto(nRecnoSx3))
 			// Adiciona os demais campos
 			If Ascan(aHeaderSev, {|e| AllTrim(e[2]) == AllTrim(SX3->X3_CAMPO) } )  == 0
 				Aadd(aHeaderSev,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,,SX3->X3_CONTEXT,,,,,} )
 			Endif
 		Else
 			// Adiciona os demais campos
 			If Ascan(aHeaderSev, {|e| AllTrim(e[2]) == AllTrim(SX3->X3_CAMPO) } )  == 0
 				Aadd(aHeaderSev,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,,SX3->X3_CONTEXT,,,,,} )
 			Endif
 		Endif
 	Endif
 	SX3->(DbSkip())
 EndDo

 //Monta tela para digitacao das naturezas
 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd( aObjects, { 100, 10, .T., .T. } )
 AAdd( aObjects, { 100, 90, .T., .T. } )

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. , .T.)

 nOpcA := 0
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) From 00,0 to 30,110	of oMainWnd   //"Gera็ใo de Tํtulo no Contas a Pagar - Distribui็ใo por M๚ltiplas Naturezas"

  @ aPObjs[1,1]+20,005 SAY STR0002 + Transform(nValor, "@E 999,999.99") Size 700,009 PIXEL //"Valor Tํtulo: "
  oGEV := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, "HS_DuplAC(oGEV:oBrowse:nAt, oGEV:aCols, {1})",,,,,99999,,,, oDlg, aHeaderSev, aColsSev)
  oGEV:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, 	IIF(HS_TudoOK("", oGEV, 1), oDlg:End(), nOpcA := 0)}, ;
         																																																			{|| nOpcA := 0, oDlg:End()})

 If lRet := nOpcA == 1
 	aColsSEV	:= AClone(oGEV:aCols)
 EndIf

RestArea(aAreaOld)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_CalcGEVบAutor  ณMicrosiga           บ Data ณ  05/22/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula os valores ou as porcentagens distribuidas         บฑฑ
ฑฑบ          ณ de acordo com o valor total do titulo                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_CalcGEV(nValTit)
Local nCont  := 0
Local nValDist := 0, nPerDist := 0
Local lRet     := .T.

 If ReadVar() == "M->EV_PERC"
	 oGEV:aCols[oGEV:oBrowse:nAt , 2] := Round(NoRound((VAL(StrTran(M->EV_PERC,",",".")) / 100) * nValTit, 3), 2)
	ElseIf ReadVar() == "M->EV_VALOR"
	 oGEV:aCols[oGEV:oBrowse:nAt , 3] := Transform((M->EV_VALOR / nValTit) * 100, "@E 999.99")
 EndIf
 For nCont := 1 To Len(oGEV:aCols)
		If !oGEV:aCols[nCont][Len(oGEV:aCols[nCont])]
			nValDist += oGEV:aCols[nCont][2]	//Valor Distribuido
			nPerDist	+= Val(STRTRAN(oGEV:aCols[nCont][3],",","."))	//Percentual Distribuido
		EndIf
	Next
	If nValDist > nValTit .Or. nPerDist > 100
	 lRet := .F.
	 Hs_MsgInf(STR0003, STR0004, STR0005) //"Somat๓rio dos valores ditribuํdos ou das porcentagens invแlidos."###"Aten็ใo"###"Verifique a distribui็ใo."
	EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_ConPlaAบAutor  ณDaniel Peixoto      บ Data ณ  02/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o Convenio e Plano estao ativos                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_ConPlaA(cCodCon, cCodPla)
Local aAreaOld := GetArea()
Local lRet     := .T.

Default cCodPla := ""

 DbSelectArea("GA9")
 DbSetOrder(1) //GA9_FILIAL + GA9_CODCON
 If DbSeek(xFilial("GA9") + cCodCon)
  If lRet := GA9->GA9_STATUS == "1"
   If !EMPTY(cCodPla)
    DbSelectArea("GCM")
    DbSetOrder(1) //GCM_CODCON + GCM_CODPLA
    If DbSeek(xFilial("GCM") + cCodCon + cCodPla)
      If !(lRet := GCM->GCM_STATUS == "1")
       HS_MsgInf(STR0006, STR0004, STR0007)  //"Plano nใo estแ ativo."###"Aten็ใo"###"Verifique o Cadastro de Conv๊nio."
      EndIf
    Else
     HS_MsgInf(STR0008, STR0004, STR0007) //"Plano nใo cadastrado."###"Aten็ใo"###"Verifique o Cadastro de Conv๊nio."
    EndIf
   EndIf
  Else
   HS_MsgInf(STR0009, STR0004, STR0007)  //"Conv๊nio nใo estแ ativo."###"Aten็ใo"###"Verifique o Cadastro de Conv๊nio."
  EndIf
 Else
  HS_MsgInf(STR0010, STR0004, STR0007) //"Conv๊nio nใo cadastrado."###"Aten็ใo"###"Verifique o Cadastro de Conv๊nio."
 EndIf

 RestArea(aAreaOld)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณHS_VldDAnmบAutor  ณAndr้ Cruz          บ Data ณ  06/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o usuแrio tem autoriza็ใo para realizar        บฑฑ
ฑฑบ          ณ Anamenese.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ aRet := HS_VldDAnm(lMensagem)                              บฑฑ
ฑฑบParโmetrosณ lMensagem  - Quando .T. Indica que a fun็ใo deve exibir    บฑฑ
ฑฑบ          ณ              uma mensagem que mostra o motivo da restri็ใo.บฑฑ
ฑฑบ          ณ               O padrใo ้ .T.                               บฑฑ
ฑฑบRetorno   ณ aRet[1] Retorna .T. caso o usuแrio tenha permissใo e .F.   บฑฑ
ฑฑบ          ณ         caso nao tenha permissใo                           บฑฑ
ฑฑบ          ณ aRet[2] CRM do m้dico                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//Function HS_VldDAnm(lMensagem, lAnamnese)
Function HS_VldDAnm(lMensagem, lAnamnese, cCodUsr)

 Local lRet       := .T., cRet := ""
 Local lTipMed    := .F.
 local lTeSenPron := SuperGetMV("MV_PSSCPE", NIL, .F.)

 Default lMensagem := .T.
 Default lAnamnese := .T.
 Default cCodUsr   := ""

 If Type("__cCrmPls") # "U" .AND. !Empty(__cCrmPls)//Integra็ใo PLS E GH
 	cRet := __cCrmPls
 Else
 	if !empty(cCodUsr) .and. lTeSenPron
 		PswOrder(2) // indice por NOME
		PswSeek(cCodUsr, .T.)  // Pesquisa o ID no cadastro de usuario
 	else
 		PswOrder(1) // indice por ID
		PswSeek(__CUSERID, .T.)  // Pesquisa o ID no cadastro de usuario
	endif

 	cRet := HS_IniPadr("SRA", 1, SubStr(PSWRET(1)[1,22], Len(PSWRET(1)[1,22]) - TamSx3("RA_MAT")[1] + 1,TamSx3("RA_MAT")[1]), "RA_CODIGO")

 EndIf

 If     !(lRet := !Empty(cRet)) .And. lMensagem // Usuแrio estแ cadastrado?
 	HS_MsgInf(STR0011, STR0004, STR0014) // "Usuแrio nใo estแ liberado para acesso ao m๓dulo."###"Aten็ใo"###"Valida็ใo de usuแrio."

 ElseIf !(lRet := !Empty(cRet := HS_IniPadr("GBJ", 1, cRet, "GBJ_CRM"))) .And. lMensagem // Usuแrio ้ M้dico?
 	HS_MsgInf(STR0012, STR0004, STR0014) // "Usuแrio nใo estแ cadastrado como m้dico."###"Aten็ใo"###"Valida็ใo de usuแrio."

 ElseIf lAnamnese .And. !(lRet := GBJ->GBJ_IDANAM == "1") .And. lMensagem // M้dico pode fazer anamenese?
 	HS_MsgInf(STR0013, STR0004, STR0014) // "Profissional nใo estแ autorizado a acessar o m๓dulo."###"Aten็ใo"###"Valida็ใo de usuแrio."

 Endif
 If lRet
  lTipMed :=  (GBJ->GBJ_TIPPRO $ "0/1/2")
 EndIf

Return({lRet, IIf(lRet, cRet, ""), lTipMed})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณHS_FEtariaบAutor  ณ Cibele Peria       บ Data ณ  05/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna o codigo da faixa etaria, conforme idade           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cRegAte - Codigo do Atendimento.                           บฑฑ
ฑฑบ          ณ =======Se este parametro vier preenchido vai considerar  a บฑฑ
ฑฑบ          ณ        idade do paciente na data do atendimento. Caso con- บฑฑ
ฑฑบ          ณ        trario, vai considerar a  idade passada no  segundo บฑฑ
ฑฑบ          ณ        parametro.                                          บฑฑ
ฑฑบ          ณ cIdade - Idade (Ex.: 074a05m10d).                          บฑฑ
ฑฑบ          ณ ======                                                     บฑฑ
ฑฑบRetorno   ณ cCDFETA - Parametro do retorno - codigo da faixa etaria    บฑฑ
ฑฑบ          ณ           obtido.                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_FEtaria(cRegAte, cIdade)
 Local aArea   := GetArea()
 Local nIdade  := 0
 Local cCdFeta := ""

 Default cIdade := HS_AgeGer(dDataBase, dDataBase)
 nIdade := Val(IIf(Empty(cRegate), cIdade, HS_IniPadr("GCY", 1, cRegAte, "GCY_IDADE",,.F.)))

 TCQUERY ChangeQuery("SELECT GHA_CDFETA FROM " + RetSqlName("GHA") + " WHERE GHA_FILIAL = '" + xFilial("GHA") +;
                     "' AND D_E_L_E_T_ <> '*' AND " + STR(nIdade) + " >= GHA_IDAINI AND " ;
                     + STR(nIdade)+ " < GHA_IDAFIN" ) NEW ALIAS "FETA"

 cCdFeta := IIf(Eof(), Space(Len(GHA->GHA_CDFETA)), FETA->GHA_CDFETA)
 DbCloseArea()

 RestArea(aArea)

Return(cCdFeta)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_CalcDatบAutor  ณDaniel Peixoto      บ Data ณ  06/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSoma ou Subtrai horas de uma data/hora e retorna a nova     บฑฑ
ฑฑบ          ณData/Hora                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_CalcDat(dDatIni, cHorIni, cModo, cHorPer)
Local dDatFin   := dDatini
Local cHorFin   := ""
Local nHoraIn   :=  VAL(StrTran(cHorIni,":","."))
Local nHorPer   := VAL(StrTran(cHorPer,":","."))
Local nDifHoras := IIF(cModo == "+", SubHoras(24, nHoraIn), SubHoras(nHoraIn, 0))
Local nHoras    := 0, cHoras := "", cMin := ""

 If cModo == "+"
   If nHorPer > nDifHoras
    dDatFin ++
    cHorFin := HS_SomaHor("00:00", AllTrim(STR(SubHoras(nHorPer, nDifHoras))))
   Else
    cHorFin := HS_SomaHor(cHorIni, cHorPer)
   EndIf
 Else // Subtrai
  If nHorPer > nDifHoras
   dDatFin --
   nHoras := SubHoras("24:00", SubHoras(nHorPer, nDifHoras))
  Else
   nHoras := SubHoras(nHoraIn, nHorPer)
  EndIf
  cHoras	:= strzero(int(nHoras),2)
  cMin	  := PADR( STUFF( ALLTRIM(STR(nHoras - Int(nHoras))) ,1,2,"") ,2,"0")
  cHorFin:= cHoras+":"+cMin

 EndIf

Return({dDatFin, cHorFin})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณHS_MontCabe บ Autor ณ Patricia Queiroz   บ Data ณ10/07/2006   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Trata o cabecalho quando tiver datas que sao obtidas a       บฑฑ
ฑฑบ          ณ a partir dos parametros informados pelo usuario.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_MontCabe(cTitulo, dData1, dData2)

 If !Empty(dData1) .and. !Empty(dData2)
 	cTitulo := cTitulo + STR0020 + DTOC(dData1) + STR0021 + DTOC(dData2) //" no Perํodo de "###" a "
 ElseIf !Empty(dData1) .and. Empty(dData2)
 	cTitulo := cTitulo + STR0022 + DTOC(dData1) //" a Partir de "
 ElseIf Empty(dData1) .and. !Empty(dData2)
 	cTitulo := cTitulo + STR0023 + DTOC(dData2) //" At้ "
 EndIf

Return(cTitulo)

Function HS_PosSX1(aChave)
 Local aArea      := GetArea()
 Local nLenChave  := Len(aChave)
 Local nForChave  := 0
 Local nForSX1    := 0
 Local cP_Defs    := ""
 Local cP_DefsTmp := ""
 Local nPFLin     := 0
 Local lProfAlias := Select("PROFALIAS") > 0
 Local nPosGrupo  := 1
 Local nPosOrdem  := 2
 Local nPosCont   := 3

 For nForChave := 1 To nLenChave

  If aChave[nForChave][nPosCont] == Nil
   aChave[nForChave][nPosCont] := Space(SX1->X1_TAMANHO)
  EndIf

  If lProfAlias
   DBSelectArea("PROFALIAS")
   DbSetOrder(1)
   If DbSeek(PadR(AllTrim(cUserName)          , Len(PROFALIAS->P_NAME)) + ;
             PadR(aChave[nForChave][nPosGrupo], Len(PROFALIAS->P_PROG)) + ;
             PadR("PERGUNTE"                  , Len(PROFALIAS->P_TASK)) + ;
             PadR("MV_PAR"                    , Len(PROFALIAS->P_TYPE)))

    cP_DefsTmp := PROFALIAS->P_DEFS

    While !Empty(cP_DefsTmp)

     nPFLin := At(Chr(13) + Chr(10), cP_DefsTmp)

     If  nForSx1 == Val(aChave[nForChave][nPosOrdem])
      cP_Defs += SubStr(cP_DefsTmp, 1, 4) + aChave[nForChave][nPosCont] + Chr(13) + Chr(10)
     Else
      cP_Defs += SubStr(cP_DefsTmp, 1, nPFLin + 1)
     EndIf

     cP_DefsTmp := SubStr(cP_DefsTmp, nPFLin + 2)
     nForSx1++

    End

    RecLock("PROFALIAS", .F.)
    PROFALIAS->P_DEFS := cP_Defs
    MsUnLock()
   EndIf
  EndIf
 Next nForChave

 RestArea(aArea)
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_ConsAgeบAutor  ณDaniel Peixoto      บ Data ณ  04/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que seleciona os agendamentos(Amb. ou Cirur.)       บฑฑ
ฑฑบ          ณ de acordo com os parametros informados                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.    ณ cTipAge - Informa o tipo da agenda A=Ambulatorial          บฑฑ
ฑฑบ          ณ                                    C=Cirurgica             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_ConsAge(cTipAge)
 Local aArea:=GetArea(), aHeadCons:={}, aColsCons:={}, aInfo:={}, aPObjs:={}, aObjects := {}	, aJoin := {}, aCposIni := {}
 Local dDatAgeI := ctod(" "), dDatAgeF := ctod(" "), dDatDigI := ctod(" "), dDatDigF := ctod(" ")
 Local cCodPla  := "", cCodCrm := "", cCodPro  := "", cCodUsr := "", cChave := "", cFiltro := "", cAlias := "", cLstCpo := "/"
 Local cTitulo  := "", cPrefixo := ""
 Local nOpcao, nItCols:=0, nGDOpc:=2, nRegistros := 0, nCpoObserv := 0
 Local oCons    := Nil, oTotReg := Nil
 Local aSize    := {}, aPGDs:={}
 Local cPerg    := IIF(cTipAge == "A", "HSM29C", "HSM39C")
 Local nCposOld := 0, aVCposOld := {} // Guarda variaveis de memoria

 Private Inclui := .F.

 cGcsTipLoc := IIf(cTipAge == "A", "5", "4")
 If !Pergunte(cPerg,.T.)
  cGcsTipLoc := IIf(cTipAge == "A", "5", "6")
  Return()
 EndIf
 cGcsTipLoc := IIf(cTipAge == "A", "5", "6")

 cSetor    := IIF(cTipAge == "A", "", MV_PAR01)
 cDoPac    := IIF(cTipAge == "A", MV_PAR02, MV_PAR02)
 cAtePac   := IIF(cTipAge == "A", MV_PAR03, MV_PAR03)
 nOpcao    := IIF(cTipAge == "A", VAL(MV_PAR01), MV_PAR04)
 dDatAgeI  := IIF(cTipAge == "A", MV_PAR04, MV_PAR05)
 dDatAgeF  := IIF(cTipAge == "A", MV_PAR05, MV_PAR06)
 dDatDigI  := IIF(cTipAge == "A", MV_PAR06, MV_PAR07)
 dDatDigF  := IIF(cTipAge == "A", MV_PAR07, MV_PAR08)
 cCodCrm   := IIF(cTipAge == "A", MV_PAR08, MV_PAR09)
 cCodPro   := IIF(cTipAge == "A", MV_PAR09, MV_PAR10)
 cCodPla   := IIF(cTipAge == "A", MV_PAR10, MV_PAR11)
 cCodUsr   := IIF(cTipAge == "A", MV_PAR11, MV_PAR12)

 If nOpcao == 1  .Or. nOpcao == 4
  If nOpcao == 1
   cTitulo  := IIF(cTipAge == "A", STR0024, STR0025) //"Consulta Horแrios Agendados"###"Consulta Horแrios Reservados"
  Else
   cTitulo  := STR0026 //"Consulta Horแrios Faltosos"
  Endif
  cAlias   := IIF(cTipAge == "A", "GM8", "GMJ")
  aCposIni := IIF(cTipAge == "A", {"GM8_FILAGE","GM8_CODAGE","GM8_DATAGE","GM8_HORAGE","GM8_REGGER","GM8_MATRIC","GM8_NOMPAC", ;
                                   "GM8_DESPRO","GM8_CODCRM","GM8_NOMCRM","GM8_CODSAL","GM8_NOMSAL","GM8_DESPLA","GM8_DATCAD","GM8_HORCAD","GM8_CODUSU", "GM8_OBSERV"}, ;
                                   {"GMJ_FILAGE","GMJ_QUARTO","GMJ_DATAGE","GMJ_HORAGE","GMJ_HORAFI","GMJ_REGGER","GMJ_MATRIC","GMJ_NOMPAC","GMJ_CODPRO", ;
                                   "GMJ_DESPRO","GMJ_CODCRM","GMJ_NOMCRM","GMJ_CODPLA","GMJ_DESPLA","GMJ_DATCAD","GMJ_HORCAD","GMJ_CODUSU"})

   cFiltro  := IIF(cTipAge == "A", "(GM8->GM8_STATUS IN ('1','2','3','4','5')) .AND. ", ;
																																   "GMJ->GMJ_STATUS == '1' .AND. GMJ->GMJ_CODAGE == GMJ->GMJ_SEQAGE .AND. ")
 ElseIf nOpcao == 2
  cTitulo  := STR0027 //"Consulta Horแrios Cancelados"
  cAlias   := IIF(cTipAge == "A", "GM9", "GML")
  aCposIni := IIF(cTipAge == "A", {"GM9_FILAGE","GM9_SEQREG","GM9_DATAGE","GM9_HORAGE","GM9_REGGER","GM9_MATRIC","GM9_NOMPAC", ;
                                   "GM9_DESPRO","GM9_CODCRM","GM9_NOMCRM","GM9_DESPLA","GM9_DATCAN","GM9_HORCAN","GM9_DESCAN","GM9_USUCAN"}, ;
                                   {"GML_FILAGE","GML_DATAGE","GML_HORAGE","GML_HORAFI","GML_REGGER","GML_MATRIC","GML_NOMPAC","GML_CODPRO","GML_DESPRO", ;
                                   "GML_CODCRM","GML_NOMCRM","GML_CODPLAN","GML_DESPLA","GML_DATCAN","GML_HORCAN","GML_CODCAN","GML_DESCAN","GML_USUCAN"})

  If cTipAge == "C"
   aAdd(aJoin,{" LEFT JOIN " + RetSqlName("GM7") + " GM7 ", "GM7.GM7_DESCAN" , "GM7.GM7_FILIAL = '" + xFilial("GM7") + "' AND GM7.D_E_L_E_T_ <> '*' AND GM7.GM7_CODCAN = GML.GML_CODCAN ", "GML_DESCAN"})
   cFiltro  := "GML->GML_CODAGE = GML->GML_SEQAGE .AND. "
  EndIf

 ElseIf nOpcao == 3
  cTitulo  := STR0028 //"Consulta Horแrios Transferidos"
  cAlias   := IIF(cTipAge == "A", "GMA", "GMM")
  aCposIni := IIF(cTipAge == "A", {"GMA_FILAGE","GMA_SEQREG","GMA_NOVDAT","GMA_NOVHOR","GMA_DATAGE","GMA_HORAGE","GMA_REGGER","GMA_MATRIC","GMA_NOMPAC","GMA_DESPRO", ;
                                   "GMA_CODCRM","GMA_NOMCRM","GMA_DESPLA","GMA_DATCAN","GMA_HORCAN","GMA_DESCAN","GMA_USUCAN"}, ;
                                   {"GMM_FILAGE","GMM_DATAGE","GMM_HORAGE","GMM_HORAFI","GMM_REGGER","GMM_MATRIC","GMM_NOMPAC","GMM_CODPRO","GMM_DESPRO", ;
                                   "GMM_CODCRM","GMM_NOMCRM","GMM_DATCAN","GMM_HORCAN","GMM_USUCAN","GMM_CODPLAN","GMM_CODCAN","GMM_DESCAN","GMM_DESPLA"})
  If cTipAge == "C"
   cFiltro  := "GMM->GMM_CODAGE == GMM->GMM_SEQAGE .AND. "
   aAdd(aJoin,{" LEFT JOIN " + RetSqlName("GM7") + " GM7 ", "GM7.GM7_DESCAN" , "GM7.GM7_FILIAL = '" + xFilial("GM7") + "' AND GM7.D_E_L_E_T_ <> '*' AND GM7.GM7_CODCAN = GMM.GMM_CODCAN ", "GMM_DESCAN"})
  EndIf

 ElseIf nOpcao == 5
  cTitulo  := STR0029 //"Consulta Horแrios Livres"

  cAlias   := IIF(cTipAge == "A", "GM8", "GMJ")
  aCposIni := IIF(cTipAge == "A", {"GM8_FILAGE","GM8_CODAGE","GM8_DATAGE","GM8_HORAGE", "GM8_CODCRM","GM8_NOMCRM"}, ;
                                   {"GMJ_FILAGE","GMJ_QUARTO","GMJ_DATAGE","GMJ_HORAGE", "GMJ_DATCAD","GMJ_HORCAD"})


  cFiltro  := IIF(cTipAge == "A", "GM8->GM8_STATUS == '0' .AND. GM8->GM8_TIPAGE = '0' .AND. ", ;
		             																	   "GMJ->GMJ_STATUS == '0' .AND. ")
 Else
  If cTipAge == "A"

   cTitulo  := IIF(nOpcao == 6, STR0057, IIF(nOpcao == 7, STR0058, IIF(nOpcao == 8, STR0059, STR0060))) //"Consulta Horแrios Bloqueados"##"Consulta Horแrios Atendidos"##"Consulta Horแrios Ocupados/Bloqueados"##"Consulta Horแrios Confirmados"
   cAlias   := "GM8"
   aCposIni := {"GM8_FILAGE","GM8_CODAGE","GM8_DATAGE","GM8_HORAGE","GM8_REGGER","GM8_MATRIC","GM8_NOMPAC", ;
                 "GM8_DESPRO","GM8_CODCRM","GM8_NOMCRM","GM8_DESPLA","GM8_DATCAD","GM8_HORCAD","GM8_CODUSU", "GM8_OBSERV"}

   cFiltro  := "GM8->GM8_STATUS == " + IIF(nOpcao == 6, "'2'", IIF(nOpcao == 7, "'3'", IIF(nOpcao == 8, "'4'", "'5'"))) + " .AND. "


  Endif
 EndIf

 DbSelectArea(cAlias)

 cFiltro += cAlias + "->" + cAlias + "_FILIAL == '" + xFilial(cAlias)+"'"

 IIf(!Empty(dDatAgeI), cFiltro += " .AND. " + cAlias + "->" + cAlias + "_DATAGE >= '" + DTOS(dDatAgeI) + "'", Nil)
 IIf(!Empty(dDatAgeF), cFiltro += " .AND. " + cAlias + "->" + cAlias + "_DATAGE <= '" + DTOS(dDatAgeF) + "'", Nil)

 If !Empty(dDATDIGI)
  If cAlias $ "GM8/GMJ"
   cFiltro += " .AND. " + cAlias + "->" + cAlias + "_DATCAD >= '" + DTOS(dDatDigI) + "'"
  Else
   cFiltro += " .AND. " + cAlias + "->" + cAlias + "_DATCAN >= '" + DTOS(dDATDIGI) + "'"
  EndIf
 EndIf

 If !Empty(dDATDIGF)
  If cAlias $ "GM8/GMJ"
   cFiltro += " .AND. " + cAlias + "->" + cAlias + "_DATCAD <= '" + DTOS(dDatDigF) + "'"
  Else
   cFiltro += " .AND. " + cAlias + "->" + cAlias + "_DATCAN <= '" + DTOS(dDATDIGF) + "'"
  EndIf
 EndIf

 IIf(!Empty(cSetor)  ,cFiltro := cFiltro + " .AND. " + cAlias + "->" + cAlias + "_CODLOC = '" +  cSetor   + "'", nil)
 IIf(!Empty(cCodCrm) ,cFiltro := cFiltro + " .AND. " + cAlias + "->" + cAlias + "_CODCRM = '" +  cCodCrm  + "'", nil)
 IIf(!Empty(cDoPac)  ,cFiltro := cFiltro + " .AND. " + cAlias + "->" + cAlias + "_REGGER >= '" + cDoPac   + "'", nil)
 IIf(!Empty(cAtePac) ,cFiltro := cFiltro + " .AND. " + cAlias + "->" + cAlias + "_REGGER <= '" + cAtePac  + "'", nil)
 IIf(!Empty(cCodPro) ,cFiltro := cFiltro + " .AND. " + cAlias + "->" + cAlias + "_CODPRO = '" +  cCodPro  + "'", nil)
 IIf(!Empty(cCodPla) ,cFiltro := cFiltro + " .AND. " + cAlias + "->" + cAlias + "_CODPLA = '" +  cCodPla  + "'", nil)

 If !Empty(cCodUsr)
  If cAlias $ "GM8/GMJ"
   cFiltro := cFiltro + " .AND. UPPER(" + cAlias + "->" + cAlias + "_CODUSU) == '" + UPPER(cCodUsr) + "'"
  Else
   cFiltro := cFiltro + " .AND. UPPER(" + cAlias +"->" + cAlias + "_USUCAN) == '" + UPPER(cCodUsr)  + "'"
  EndIf
 EndIf

	//Salva valor das variaveis de memoria para restaurar no final
	DbSelectArea("SX3")
	DbSetOrder(1) // X3_ARQUIVO + X3_ORDEM
	DbSeek(cAlias)
	While SX3->X3_ARQUIVO == cAlias
 	If Type("M->" + SX3->X3_CAMPO ) <> "U"
  	aAdd(aVCposOld, {"M->" + SX3->X3_CAMPO , &("M->" + SX3->X3_CAMPO) })
 	EndIf
 	SX3->(DbSkip())
	End


 DbSelectArea(cAlias)

 aSize := MsAdvSize(.T.)
 aObjects := {}

 AAdd( aObjects, { 100, 015, .T., .T., .T. } )
 AAdd( aObjects, { 100, 090, .T., .T. } )

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 cPrefixo := cAlias + "." + cAlias

 aAdd(aJoin,{" LEFT JOIN " + RetSqlName("GCM") + " GCM ", "GCM.GCM_DESPLA" , "GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODPLA = " + cPrefixo + "_CODPLA ", cAlias + "_DESPLA"})
 aAdd(aJoin,{" LEFT JOIN " + RetSqlName("GA7") + " GA7 ", "GA7.GA7_DESC"   , "GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = " + cPrefixo + "_CODPRO ", cAlias + "_DESPRO"})
 aAdd(aJoin,{" LEFT JOIN " + RetSqlName("SRA") + " SRA ", "SRA.RA_NOME"    , "SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO  = " + cPrefixo + "_CODCRM ", cAlias + "_NOMCRM"})

 nRegistros := HS_BDados(cAlias, @aHeadCons, @aColsCons, @nItCols, 1,, cFiltro,,,cLstCpo,,,,,,.T.,,,,,, aCposIni, aJoin)

 nCpoObserv := aScan(aHeadCons, {|aVet| AllTrim(aVet[2]) == cAlias+"_OBSERV"})

 DEFINE MSDIALOG oDlgCons TITLE OemToAnsi(cTitulo)  From aSize[7],000 To aSize[6],aSize[5] OF GetWndDefault() PIXEL

  oPPesq	:=	tPanel():New(aPObjs[1, 1], aPObjs[1, 2],, oDlgCons,,,,,,aPObjs[1, 3], aPObjs[1, 4])
  oPPesq:Align := CONTROL_ALIGN_TOP


  oCons := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], 0,,,,,,99999,,,,, aHeadCons, aColsCons)
  oCons:oBrowse:ALign := CONTROL_ALIGN_ALLCLIENT
  oCons:oBrowse:BlDblClick := {|| IIF(nCpoObserv == oCons:oBrowse:nColPos, HS_PRECPME(oCons, nCpoObserv, cAlias, "_OBSERV"), Nil)}

  	oTimer3 := TTimer():New(20000, {|| FS_ATUGRID(aColsCons,nRegistros,cAlias,aHeadCons,nItCols,cFiltro,cLstCpo,aCposIni,aJoin,oCons) }, oDlgCons )   //Atualiza e posiciona grid de pacientes
	oTimer3:Activate()
  HS_GDPesqu( , , oCons, oPPesq, 002)

  @ 017, 250 Say OemToAnsi(STR0030) Size 075, 009 OF oPPesq PIXEL COLOR CLR_BLUE  //"Total de Registros:"
  @ 015, 300 MSGet oTotReg var nRegistros Size 075, 009 OF oPPesq PIXEL COLOR CLR_BLACK When .F.

  oDlgCons:lEscClose := .F.

 ACTIVATE MSDIALOG oDlgCons CENTERED ON INIT EnchoiceBar(oDlgCons, {|| oDlgCons:End()}, {|| oDlgCons:End()},,/*aButtons*/ )

 RestArea(aArea)
	For nCposOld := 1 To Len(aVCposOld)
 	&(aVCposOld[nCposOld, 1]) := aVCposOld[nCposOld, 2]
	Next

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldFaltบAutor  ณMario Arizono       บ Data ณ  08/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que valida a digitacao da data de agendamento       บฑฑ
ฑฑบ          ณ na consulta de horarios quando o agendamento e faltoso.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_VldFalt(cTipAge)
Local lRet := .T.
 If cTipAge == "A"
  If ReadVar() == "MV_PAR01" .And. !(MV_PAR01 $ "123456789")
   HS_MsgInf(STR0055, STR0004, STR0056)  //"Op็ใo escolhida invแlida"##"Atencao"##"Valida็ใo da consulta"
   Return .F.
  Endif
  If VAL(MV_PAR01) == 4
   If MV_PAR04 >= DATE()
    MV_PAR04 := STOD("  /  /  ")
    lRet := .F.
   EndIf
   If MV_PAR05 >= DATE()
    MV_PAR05 := DATE()-1//STOD("  /  /  ")
    lRet := .F.
//    HS_MsgInf(STR0015, STR0004, STR0016) //"Para pacientes faltosos as datas de agendamento devem ser menores que a data atual."###"Aten็ใo"###"Verifique a sele็ใo"
   Endif
  Endif
 Else
  If MV_PAR04 == 4
   If MV_PAR05 >= DATE()
    MV_PAR05 := STOD("  /  /  ")
    lRet := .F.
   EndIf
   If MV_PAR06 >= DATE()
    MV_PAR06 := DATE()-1//STOD("  /  /  ")
    lRet := .F.
//    HS_MsgInf(STR0015, STR0004, STR0016) //"Para pacientes faltosos as datas de agendamento devem ser menores que a data atual"###"Aten็ใo"###"Verifique a sele็ใo"
   Endif
  EndIf
 Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_PRECPMEบAutor  ณMario Arizono       บ Data ณ  10/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para preenchimento do campo memo.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Apresentacao de campo MEMO.                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_PRECPME(oObj, nPosCpo, cAlias, cCampo)
 Local aArea := GetArea()

 If nPosCpo == oObj:oBrowse:nColPos .And. ValType( oObj:aCols[oObj:oBrowse:nAt, oObj:oBrowse:nColPos]) == "N"
  &(cAlias + "->(DbGoTo("+ ALLTRIM(STR( oObj:aCols[oObj:oBrowse:nAt, oObj:oBrowse:nColPos])) + "))")

  oObj:aCols[oObj:oBrowse:nAt, oObj:oBrowse:nColPos] := &(cAlias + "->" + cAlias + cCampo)

 Endif

 oObj:EditCell(oObj:oBrowse, oObj:oBrowse:nAt, oObj:oBrowse:nColPos)


 RestArea(aArea)
Return(Nil)

Function HS_ResMemo(cReadVar, aField, aCoord)
 Local nPos := aScan(aField, {|x| x[2] == PadR(Subs(cReadVar,4), 10)})
 Local __OldReadVar := cReadVar
 Local oDlg, cMemo  := &(cReadVar)
	Local oBtnCanc,  oBtnOk
	Local nLF := 300
 Local nCF    := 500
 Local nLMemo := 250
 Local nCMemo := 130
	Local nLinBt := 135

	Default aCoord := {}

 If Len(aCoord) > 0
  aSize := MsAdvSize(.T.)
  aObjects := {}
  AAdd( aObjects, { 100, 080, .T., .T. } )
  AAdd( aObjects, { 100, 020, .T., .T. } )

  aInfo  := { aCoord[ 1 ], aCoord[ 2 ], aCoord[ 3 ], aCoord[ 4 ], 0, 0 }
  aPObjs := MsObjSize( aInfo, aObjects, .T. )

  nLF       := 580
  nCF       := aSize[5]
  nLMemo    := aPObjs[2, 3]
  nCMemo    := aPObjs[1, 4] + 110
  nLinBt    := aPObjs[2, 4] + 113
 EndIf

  DEFINE MSDIALOG oDlg FROM	0, 0 To nLF, nCF TITLE OemToAnsi(aField[nPos, 1]) PIXEL of oMainWnd

   @ 002, 002 GET oTexto VAR cMemo MEMO /*NO VSCROLL*/ SIZE nLMemo, nCMemo OF oDlg PIXEL

   oBtnOk   := tButton():New(nLinBt, 002, STR0064, oDlg, {|| &(cReadVar) := cMemo, oDlg:End()},30,15,,,,.T.)
   oBtnCanc := tButton():New(nLinBt, 034, STR0065, oDlg, {|| oDlg:End()}                       ,30,15,,,,.T.)

  ACTIVATE MSDIALOG oDlg

 __ReadVar := __OldReadVar
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณHS_MntPergบAutor  ณJos้ Orfeu          บ Data ณ  06/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tela de entrada de dados utilizando o cadastro de    บฑฑ
ฑฑบ          ณ questionario, grupo de perguntas e perguntas               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ                                                            บฑฑ
ฑฑบParโmetrosณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบRetorno   ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_MntPerg(cCDQues, oDlgOwner, cTitulo, aCoord, lReadOnly, cIniCpo, cEncObj, lCriaEnc, cSvaTela, nAlign, lShowHint, cModo, lLargMax,lVldObrOwn,lMetTela)

Local aCampos := {{"C", "GFS_TAHINT"}}
Local nOpcOwner := 0, oEncOwner, __oPHint, cTxtMemo := "", nPDel := 0
Local lActvDlg := .F., lShowOwner := .F.
Local aSize := MsAdvSize(.T.)
Local aObjects := {}, aInfo:= {}
Local aField := {}, nField := 1
Local nFolder := 1, aFolder := {}
Local bKeyF4		//:=	SetKey(VK_F4, {|| PHISPERANM(PadR(SubStr(ReadVar(), 4), 10), GCY->GCY_REGGER, .T.)  })
Local bKeyF6		:=	SetKey(VK_F6, {|| IIf(PadR(SubStr(ReadVar(), 4), 10) $ __cCpoMemo, HS_SeleMne(PadR(SubStr(ReadVar(), 4), 10), __aField), Nil)})
Local bKeyF7		:=	SetKey(VK_F7, {|| HS_HelpPer(ReadVar(), __aField)})
Local bKeyF8
Local bKeyF9

Local lHint   := .F.

Default cTitulo   := STR0031 //"Questionแrio"
Default aCoord    := {0, 0, 100, 200}
Default lReadOnly := .F.
Default cIniCpo   := "PER"
Default lCriaEnc  := .T.
Default lShowHint := .T.
Default cModo     := "G" // E-Elabora็ใo, C-Conclusใo ou G-Geral
Default lLargMax  := .F.
Default lMetTela  := .F.
Default lVldObrOwn := .F.

If GETNEWPAR("MV_PROSAUD",.F.)
	bKeyF4		:=	SetKey(VK_F4, {|| PHISPERANM(PadR(SubStr(ReadVar(), 4), 10), GCY->GCY_REGGER, .T.)  }) // exibe o grafico de evolu็ใo das respostas
	bKeyF9		:=	SetKey(VK_F9, {|| PLSRPRO03( GCY->GCY_REGGER,PadR(SubStr(ReadVar(), 4), 10),.T.,GCY->GCY_REGATE)  }) // exibe o Relatorio grafico de evolu็ใo das respostas	
EndIf
Private aRotina :=	{{"",	"", 0, 1}, ;
{"",	"",	0,	2}, ;
{"", "",	0,	3}, ;
{"", "",	0,	4}, ;
{"", "",	0,	5}}

If Type("__cCpoMemo") == "U"
	_SetOwnerPrvt("__cCpoMemo", "")
EndIf

If Type("__aField") == "U"
	_SetOwnerPrvt("__aField", {})
Else
	While (nPDel := aScan(__aField, {|aVet| SubStr(aVet[2], 1, Len(cIniCpo)) == cIniCpo})) > 0
		aDel(__aField, nPDel)
		aSize(__aField, Len(__aField) - 1)
	End
EndIf

DbSelectArea("GFS")
DbSetOrder(1) //GFS_FILIAL + GFS_CDQUES
DbSeek(xFilial("GFS") + cCDQues)
lHint := lShowHint .And. GFS->GFS_SWHINT == "1" // 1-Show Hint On ou 0-Show Hint Off

If !HS_VldQues(cCDQues, cModo, @nFolder, @aField, @aFolder, @nField, cIniCpo, cEncObj)
	HS_MsgInf(STR0032 + cCDQues + "]", STR0004, "HS_MntPerg") //"Nใo foi encontrada nenhuma pergunta para o questionแrio ["###"Aten็ใo"
	Return(.F.)
EndIf

For nField := 1 To Len(aField)
	If Type(aField[nField][2]) == "U" // Caso os campo nao existam na memoria serใo criados com os valores padr๕es

		If !Empty(aField[nField][10])
			_SetOwnerPrvt(AllTrim(aField[nField][2]), InitPad(aField[nField][10]))
		Else
			If aField[nField][3] == "D"
				_SetOwnerPrvt(AllTrim(aField[nField][2]), Ctod("  /  /  "))
			ElseIf aField[nField][3] == "N"
				_SetOwnerPrvt(AllTrim(aField[nField][2]), 0)
			Else
				_SetOwnerPrvt(AllTrim(aField[nField][2]), Space(aField[nField][4]))
			Endif
		Endif

	EndIf

	If aField[nField][3] == "M"
		__cCpoMemo += "|" + aField[nField][2]
	Endif

	aAdd(__aField, aField[nField])
Next

If lActvDlg := (oDlgOwner == Nil)
	aAdd(aObjects, {100, 100, .T., .T. })

	aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
	aCoord := MsObjSize(aInfo, aObjects, .T.)[1]

	DEFINE MSDIALOG oDlgOwner TITLE OemToAnsi(cTitulo) From aSize[7]-IIf(lMetTela,(aSize[7]/3),0), 000 To aSize[6]-IIf(lMetTela,(aSize[6]/3),0), aSize[5]-IIf(lMetTela,(aSize[5]/3),0) Of oMainWnd Pixel
EndIf

If lCriaEnc
	If cSvaTela <> Nil .And. !Empty(cSvaTela)
		&(cSvaTela) := {}
	Else
		cSvaTela := Nil
	EndIf

	If (lShowOwner := Type(cEncObj) <> "U")
		oDlgOwner:Hide()
		oDlgOwner:FreeChildren()
	Else
		_SetOwnerPrvt(cEncObj, oEncOwner)
	EndIf

	bKeyF8		:=	SetKey(VK_F8, {|| IIf(PadR(SubStr(ReadVar(), 4), 10) $ __cCpoMemo, HS_ResMemo(ReadVar(), __aField, IIF(lLargMax, aCoord, Nil)), Nil)})
	oEncOwner := MsMget():New("GCH", GCH->(RecNo()), IIf(lReadOnly, 2, 4),,,,, aCoord,,,,,, oDlgOwner,,, .T., cSvaTela, /*lSemPasta*/, .T., aField, aFolder)
	oEncOwner:oBox:Align := nAlign

	If lHint
		oEncOwner:oBox:bWhen := {|| cTxtMemo := HS_HintPer(ReadVar(), __aField, cIniCpo), __oPHint:Refresh()}

		@ aCoord[3] * (100 - (IIF(!Empty(GFS->GFS_TAHINT), GFS->GFS_TAHINT, 5) / 100)), aCoord[2] GET __oPHint VAR cTxtMemo MEMO READONLY SIZE aCoord[3], aCoord[3] * (IIF(!Empty(GFS->GFS_TAHINT), GFS->GFS_TAHINT, 5) / 100) OF oDlgOwner PIXEL
		__oPHint:Align := CONTROL_ALIGN_BOTTOM
	EndIf

	&(cEncObj) := oEncOwner

	If lShowOwner
		oDlgOwner:Show()
	EndIf

EndIf

If lActvDlg
	ACTIVATE MSDIALOG oDlgOwner CENTERED ON INIT EnchoiceBar(oDlgOwner, {||  IIf(lVldObrOwn, IIf(HS_ObrgPer(aFolder, aField),{ nOpcOwner := 1, oDlgOwner:End()},.F.),{ nOpcOwner := 1, oDlgOwner:End()})}, {|| nOpcOwner := 0, oDlgOwner:End()})
	//ACTIVATE MSDIALOG oDlgOwner ON INIT EnchoiceBar(oDlgOwner, {|| nOpcOwner := 1, oDlgOwner:End()}, {|| nOpcOwner := 0, oDlgOwner:End()})
EndIf


Return({nOpcOwner, aField, aFolder})

Static Function FS_AField(cGrpPer, nFolder, aField, nField, cIniCpo, cEncObj)
 Local aArea 	:= GetArea()
 Local lExDicLab:= .T.	

 Default aField  := {}
 Default nField  := 1
 Default cIniCpo := "PER"

 DbSelectArea("GCG")
 DbSetOrder(3) // GCG_FILIAL + GCG_GRPPER + GCG_ORDPER
 DbSeek(xFilial("GCG") + cGrpPer)

 While !Eof() .and. xFilial("GCG") == GCG->GCG_FILIAL .And. cGrpPer == GCG->GCG_GRPPER

 	GCH->(DbSetOrder(1))
 	GCH->(DbSeek(xFilial("GCH") + GCG->GCG_CODPER))

 	If GCH->GCH_STATUS <> "1" .Or. GCG->GCG_STATUS <> "1" .OR. (IIf(lExDicLab,GCH->GCH_SRELAT == "1",.F.))
 		DbSkip()
 		Loop
 	Endif

  //              1        2       3        4        5          6          7           8          9        10       11      12          13
 	// aField = {<cTitle>,<cField>,<cType>,<nSize>,<nDecimal>,<cPicture>,<{uValid}>,<.lObrigat.>,<nLevel>,<cInitPad>,<cF3>,<{uWhen}>,<.lVisual.>,;
 	//               14       15      16          17          18
  //           <.lChave.>,<cBox>,<nFolder>,<.lNAltera.>,<cPictVar>})
  ADD FIELD aField TITULO		GCH->GCH_DESPER ;
 	               CAMPO		cIniCpo + "_" + GCH->GCH_CODPER ;
                   TIPO			GCH->GCH_TIPPER	;
                   TAMANHO		GCH->GCH_TAMRES	;
	               DECIMAL		GCH->GCH_DECRES	;
	               PICTURE		GCH->GCH_PICRES	;
	               NIVEL		0	;
	               INITPAD		GCH->GCH_RELRES	;
	               F3			GCH->GCH_F3RES	;
	               BOX			GCH->GCH_CBOX	;
	               FOLDER		nFolder

  If !Empty(GCH->GCH_VALRES) // Validacao de saida do campo
   aField[nField][7] := &("{|| " + AllTrim(GCH->GCH_VALRES) + "}")
  EndIf

  aField[nField][8] := GCH->GCH_OBRIGA == "1" // Campo Obrigatorio

  If !Empty(GCH->GCH_WHEN) // Validacao do X3_WHEN
   aField[nField][12] := &("{|| " + AllTrim(GCH->GCH_WHEN) + "}")
  EndIf

  aField[nField][13] := GCH->GCH_VISRES	== "0" // Campo visual

  aSize(aField[nField], Len(aField[nField]) + 1)
  If lExDicLab
 	aField[nField][Len(aField[nField])] :=  Alltrim(GCH->GCH_DESEXT) + IIf(!Empty(GCH->GCH_TXTREF), " - " + Alltrim(GCH->GCH_TXTREF), "")
  Else
   aField[nField][Len(aField[nField])] :=  Alltrim(GCH->GCH_DESEXT)
  EndIf

  aSize(aField[nField], Len(aField[nField]) + 1)
 	aField[nField][Len(aField[nField])] := cEncObj + ":aEntryCtrls[" + AllTrim(Str(nField)) + "]"

 	aSize(aField[nField], Len(aField[nField]) + 1)
 	aField[nField][Len(aField[nField])] := GCH->GCH_HELPER

 	aSize(aField[nField], Len(aField[nField]) + 1)
 	aField[nField][Len(aField[nField])] := GCG->GCG_GRPPER

 	aSize(aField[nField], Len(aField[nField]) + 1)
 	aField[nField][Len(aField[nField])] := GCG->GCG_CODPER

 	nField++

 	DbSkip()
 End

 RestArea(aArea)
Return(aField)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao	   ณHS_SeleMne ณ Autor ณ                        ณ Data ณ 02.09.04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Somente retorno da consulta padrao do SXB                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	  ณ HS_SeleMne(cCpoMem, oMemo)		                         			     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                     						                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		    ณ HSP                                         													    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_SeleMne(cCpoMem, aField)
 Local aHGcq := {}, aCGcq := {}, nForGcq := 0, lRetGcq := .F.
 Local oDlgGcq, oGDGcq, oPMemo, oPPesq, oTxtMemo, cTxtMemo := "", aAreaOld := GetArea()
 Local aObjects := {}, aInfo := {}, aPObjs := {}
 Local nLenTxt := Len(&(cCpoMem)), cTextoIns := ""
 Local nPosMemo := aScan(aField, {| aVet | aVet[2] == cCpoMem})
 Local oMemo := &(aField[nPosMemo][Len(aField[nPosMemo])-3])
 Local nGcqCodigo := 0, nGcqMMarca := 0, nGcqMneumo := 0

 If HS_BDados("GCQ", @aHGcq, @aCGcq,, 1,, "GCQ_MNEUMO IN (SELECT GNI_CODRES FROM " + RetSqlName("GNI") + " WHERE GNI_FILIAL = '" + XFILIAL("GNI") + "' AND D_E_L_E_T_ <> '*' AND GNI_CODPER = '"+AFIELD[NPOSMEMO, 23]+"')",,,,,,, "GCQ_MMARCA") == 0		// !HS_ExisDic({{"T", "GNI"}}, .F.) .Or. 
  aHGcq := {}
  aCGcq := {}
 	HS_BDados("GCQ", @aHGcq, @aCGcq,, 1,, "1=1",,,,,,, "GCQ_MMARCA")
 EndIf

 nGcqCodigo := aScan(aHGcq, {| aVet | aVet[2] == "GCQ_CODIGO"})
 nGcqMMarca := aScan(aHGcq, {| aVet | aVet[2] == "GCQ_MMARCA"})
 nGcqMneumo := aScan(aHGcq, {| aVet | aVet[2] == "GCQ_MNEUMO"})

	aObjects := {}
 AAdd( aObjects, { 100, 010, .T., .T., .T. } )
 AAdd( aObjects, { 100, 080, .T., .T. } )
 AAdd( aObjects, { 100, 010, .T., .T., .T. } )

 aInfo  := { 0, 0, 500, 400, 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 Define MsDialog oDlgGcq Title OemToAnsi(STR0033) From 000, 000 To 400, 500 Of oMainWnd PIXEL //"Mnem๔nico"
  oPPesq	:=	tPanel():New(aPObjs[1, 1], aPObjs[1, 2],, oDlgGcq,,,,,, aPObjs[1, 3], aPObjs[1, 4])
  oPPesq:Align := CONTROL_ALIGN_TOP

  oGDGcq := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0,,,,,, Len(aCGcq),,,, oDlgGcq, aHGcq, aCGcq)
  oGDGcq:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
  oGDGcq:bChange := {|| cTxtMemo := HS_IniPadr("GCQ", 1, oGDGcq:aCols[oGDGcq:nAt, nGcqCodigo], "GCQ_TXTMNE",, .F.), oTxtMemo:Refresh()}
  oGDGcq:oBrowse:BlDblClick := {|| FS_MntTexto(oGDGcq, nGcqMMarca, nGcqCodigo, @cTextoIns, aField, cCpoMem)}

  oPMemo	:=	tPanel():New(aPObjs[3, 1], aPObjs[3, 2],, oDlgGcq,,,,,, aPObjs[3, 3], aPObjs[3, 4])
  oPMemo:Align := CONTROL_ALIGN_BOTTOM

  @ 000, 000 GET oTxtMemo VAR OemToAnsi(cTxtMemo) MEMO READONLY /*NO VSCROLL*/ SIZE aPObjs[3, 3], aPObjs[3, 4] OF oPMemo PIXEL

  HS_GDPesqu(oGDGcq:aHeader, oGDGcq:aCols, oGDGcq, oPPesq, 002,, 1)
 Activate MsDialog oDlgGcq CENTERED On Init EnchoiceBar(oDlgGcq, {|| lRetGcq := .T., oDlgGcq:End()}, {|| lRetGcq := .F., oDlgGcq:End()})

 If lRetGcq

	 If oMemo:nPos > 0
	 	&(cCpoMem) := SubStr(&(cCpoMem), 1, oMemo:nPos) + cTextoIns + SubStr(&(cCpoMem), oMemo:nPos + 1, nLenTxt)
	 Else
	 	&(cCpoMem) := cTextoIns + &(cCpoMem)
	 EndIf

	 oMemo:Refresh()
 EndIf

 RestArea(aAreaOld)
Return(.T.)

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao	 		ณHS_HintPerณ Autor ณ Jos้ orfeu             ณ Data ณ 31.10.04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Exibi็ใo do help do campo no dialogo do questionแrio (Hint) ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	  ณ HS_HintPer(cReadVar, aField)         																							ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cReadVar = Campo posicionado                                ณฑฑ
ฑฑณ          ณ aField   = Matriz contendo os campos e seus objetos         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso							ณ HSP                                                 						  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_HintPer(cReadVar, aField, cIniCpo)
 Local cCpo := PadR(Subs(cReadVar, At("->", cReadVar)+2), 10), aRetSx3 := {}
 Local nPos := IIf(!Empty(cCpo), aScan(aField, {|x| x[2] == cCpo}), 0), cRetTxt := ""

 If nPos > 0
  cRetTxt := aField[nPos][Len(aField[nPos])-4]
 ElseIf Len(aRetSx3 := HS_CfgSx3(cCpo, {"X3_DESCRIC"})) > 0 .And. !Empty(aRetSx3[1])
  cRetTxt := aRetSx3[1]
 EndIf


Return(cRetTxt)

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao	 		ณHS_HelpPerณ Autor ณ Jos้ orfeu             ณ Data ณ 31.10.04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Mostra Help para das perguntas dos laudos, Prontuแrios Ele- ณฑฑ
ฑฑณ          ณ tr๔nicos e Triagens                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	  ณ HS_HelpPer(cReadVar, aField)																																ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cReadVar = Campo posicionado no momento em que ้ pressionadoณฑฑ
ฑฑณ          ณ            a tecla de fun็ใo associada                      ณฑฑ
ฑฑณ          ณ aField   = Matriz contendo os campos e seus objetos         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso							ณ HSP                                                 						  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_HelpPer(cReadVar, aField)

 Local nPos := aScan(aField, {|x| x[2] == PadR(Subs(cReadVar,4), 10)})
 Local __OldReadVar := cReadVar

 HS_MsgInf(aField[nPos][Len(aField[nPos])-2], STR0004, STR0034 + aField[nPos][2] + "][" + aField[nPos][1] + "]") // "Aten็ใo"###"Campo ["

 __ReadVar := __OldReadVar

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao	   ณHS_ObrgPer  ณ Autor ณ Jos้ Orfeu            ณ Data ณ 30.10.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Valida conteudo do questionario                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	  ณ HS_ObrgPer    	   				                                					  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ aField = Array com Campos            						                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		    ณ HSP                                         		  											  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_ObrgPer(aFolder, aField)

 Local lRet    := .T.
 Local nField  := 0
 Local cField  := ""
 Local cMsgObr := ""
 Local __OldReadVar := ReadVar()
 Local cObrgCond := ""

 For nField := 1 To Len(aField)

 	cField := "M->" + aField[nField][2]


 	 cObrgCond := HS_IniPadr("GCH", 1, aField[nField][23], "GCH_CNDOBR")

 	If Empty(cObrgCond) .Or. GCH->GCH_OBRIGA # "2"
 	 cObrgCond := ".F."
 	EndIf

 	If ((aField[nField][8] .Or. &(cObrgCond)) .And. (Empty(&(cField)) .Or. (aField[nField][3] == "C"	.And. "@E" $ aField[nField][18] .And. Val(&(cField)) == 0)))

 		cMsgObr += STR0034 + aField[nField][2] + "][" + AllTrim(aField[nField][1]) + STR0035 + AllTrim(aFolder[aField[nField][16]]) + "]" //"Campo ["###"] Pasta ["
 		cMsgObr += IIf(nField < Len(aField), Chr(10) + Chr(13), "")

 	Endif

 Next nField

 If !(lRet := Empty(cMsgObr))
  cMsgObr := STR0036 + Chr(10) + Chr(13) + cMsgObr //"Preencha o(s) campo(s) abaixo : "
  HS_MsgInf(cMsgObr, STR0004, STR0037) // "Aten็ใo"###"Campo Obrigat๓rio"
 EndIf

 __ReadVar := __OldReadVar

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao	   ณ HS_GrvResp ณ Autor ณ Jos้ Orfeu            ณ Data ณ 30.10.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Grava conteudo do questionario                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	  ณ HS_GrvResp(cAlias, aChave, aField)                     					 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cAlias = "GCP" para Laudo, "GFK" para Prontuแrio Eletronico eณฑฑ
ฑฑณ          ณ          "GFW" para triagem         						                   ณฑฑ
ฑฑณ          ณ aChave = Array que contem os campos que formam a chave de    ณฑฑ
ฑฑณ          ณ          identifica็ใo do cadastro  						                   ณฑฑ
ฑฑณ          ณ aField = Respostas a serem gravadas no repositorio           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		    ณ HSP                                         		  											  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
// Alias GFK Composi็ใo da chave do laudo                 GCP_FILIAL+GCP_SOLICI+GCP_CODPRO+GCP_GRPPER+GCP_CODPER
// Alias GCP Composi็ใo da chave do prontuแrio eletronico GFK_FILIAL+GFK_CDANAM+GFK_CDQUES+GFK_GRPPER+GFK_CODPER
// Alias ??? Composi็ใo da chave da triagem

Function HS_GrvResp(cAlias, aChave, aCposGrv)
 Local aArea := GetArea()
 Local nRegistro  := 0
 Local nGrpPer    := Len(aCposGrv[1]) - 1
 Local nCodPer    := nGrpPer + 1
 Local cAliasPref := cAlias + "->" + cAlias
 Local cCpoGrResp := ""
 Local nCpoChv    := 0
 Local cChave     := ""

 For nCpoChv := 1 To Len(aChave)
  cChave += aChave[nCpoChv, 2]
 Next

 DbSelectArea(cAlias)
 DbSetOrder(1)

 For nRegistro := 1 To Len(aCposGrv)

 	If DbSeek(xFilial(cAlias) + cChave + aCposGrv[nRegistro, nGrpPer] + aCposGrv[nRegistro, nCodPer])
 		RecLock(cAlias, .F.)
 	Else
 		RecLock(cAlias, .T.)
 	Endif

 	If     aCposGrv[nRegistro, 3] == "C"	//.And. !("@E" $ aCposGrv[nRegistro, 18])
 		cCpoGrResp := cAliasPref + "_RESCAR"
 	Elseif aCposGrv[nRegistro, 3] == "N" //"C"	.And.  ("@E" $ aCposGrv[nRegistro, 18])
 		cCpoGrResp := cAliasPref + "_RESNUM"
 	Elseif aCposGrv[nRegistro, 3] == "D"
 		cCpoGrResp := cAliasPref + "_RESDAT"
 	Elseif aCposGrv[nRegistro, 3] == "M"
 		cCpoGrResp := cAliasPref + "_RESMEM"
 	Endif

 	&(cAliasPref + "_FILIAL")	:=	xFilial(cAlias)
 	&(cCpoGrResp)             :=	IIF(aCposGrv[nRegistro, 3] == "N", ALLTRIM(STR(&("M->" + aCposGrv[nRegistro, 2]))), &("M->" + aCposGrv[nRegistro, 2]))

 	For nCpoChv := 1 To Len(aChave)
   &(aChave[nCpoChv, 1]) := aChave[nCpoChv, 2]
  Next

  &(cAliasPref + "_GRPPER") := aCposGrv[nRegistro, nGrpPer]
  &(cAliasPref + "_CODPER") := aCposGrv[nRegistro, nCodPer]

 Next nRegistro

 RestArea(aArea)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณHS_BusRespณ Autor ณ Jos้ Orfeu            ณ Data ณ 16.11.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณMonta array com as informacoes do repositorio de respostas eณฑฑ
ฑฑณ          ณe cria variaveis Privates com as repostas.                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	  ณ HS_BusResp(cAlias, aChave, cIniCpo)                    			 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cAlias = "GCP" para Laudo, "GFK" para Prontuแrio Eletronicoณฑฑ
ฑฑณ          ณ          e "GFW" para triagem         						               ณฑฑ
ฑฑณ          ณ aChave = Array que contem os campos que formam a chave de  ณฑฑ
ฑฑณ          ณ          identifica็ใo do cadastro  						                 ณฑฑ
ฑฑณ          ณ cIniCpo= Prefixo das variaveis Private que irใo conter as  ณฑฑ
ฑฑณ          ณ          respostas                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Retorno  ณ aRetRes= Array contendo as perguntas e respostas           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ HSP                                                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_BusResp(cAlias, aChave, cIniCpo)
Local aArea := GetArea()
Local nCpoChv := 0, cCpoChv := "", cCpoRes := ""
Local cPrvVar := "", cValRes := ""
Local aRetRes := {}
Local lTChr10 := GetMV("MV_TPIMPLA") == "0" // Para imprimir via Word retira CHR(10) do campo memo

For nCpoChv := 1 To Len(aChave)
	cCpoRes += IIf(nCpoChv == 1, "", " + ") + aChave[nCpoChv, 1]
	cCpoChv += aChave[nCpoChv, 2]
Next

DbSelectArea(cAlias)
DbSetOrder(1)
DbSeek(xFilial(cAlias) + cCpoChv)

While !Eof() .And. cCpoChv == &(cCpoRes)

	If !Empty(HS_IniPadr("GCH", 1, &(cAlias + "->" + cAlias + "_CODPER"), "GCH_CODPER",, .F.))
		cPrvVar := AllTrim(cIniCpo + "_" + GCH->GCH_CODPER)

		If     GCH->GCH_TIPPER == "C" // C=Caracter
			cValRes := &(cAlias + "->" + cAlias + "_RESCAR")
		ElseIf GCH->GCH_TIPPER == "N" // N=Numerico
			cValRes := VAL(&(cAlias + "->" + cAlias + "_RESNUM"))
		ElseIf GCH->GCH_TIPPER == "D" // D=Data
			cValRes := &(cAlias + "->" + cAlias + "_RESDAT")
		ElseIf GCH->GCH_TIPPER == "M" // M=Memo
			cValRes := &(cAlias + "->" + cAlias + "_RESMEM")
			If lTChr10
				cValRes := StrTran(cValRes, Chr(13) + Chr(10), Chr(13))
			EndIf
		EndIf

		If Type(cPrvVar) <> "U"
			&(cPrvVar) := cValRes
		Else
			_SetOwnerPrvt(cPrvVar, cValRes)
		EndIf
		aAdd(aRetRes, {"__" + GCH->GCH_TIPPER + cPrvVar, cValRes, GCH->GCH_DESPER, GCH->GCH_DESEXT})
	EndIf

	DbSkip()
End

RestArea(aArea)
Return(aRetRes)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณHS_TmpR4    บ Autor ณ Antonio Carlos     บ Data ณ29/09/2006   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Excluir tabela temporaria nos relatorios personalizaveis     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR / RELATORIOS PERSONALIZAVEIS               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_TmpR4()
 If lTmpR4==.T.
  DbSelectArea("TMPR4")
  DbCloseArea()
  fErase("TMPR4")
 EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณHS_CapFotoบAutor  ณJos้ Orfeu          บ Data ณ  02/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Captura de imagens integrado com cameras fotograficas ou deบฑฑ
ฑฑบ          ณ um diretorio informado                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ HS_CapFoto(cIdFile, oEnchoice, cCpoFoto)                   บฑฑ
ฑฑบParโmetrosณ cIDFile - Identificador para definir o nome do arquivo da  บฑฑ
ฑฑบ          ณ           foto                                             บฑฑ
ฑฑบ          ณ oEnchoice - Objeto da enchoice que recebera a foto         บฑฑ
ฑฑบ          ณ cCpoFoto  - Variavel de mem๓ria que recebera a foto        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Retora .T. caso consiga carregar a foto, caso contrario .F.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo Hospitalar                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
function HS_CapFoto(cIdFile, oEnchoice,cCpoFoto, aFotos)
                                    
Local lRet			:= .F.
Local cFileJpg		:= '' 
Local cPathSrv		:= ''
Local cDestFile 	:= ''
Local nHDImgDll		:= 0  
Local nRet			:= 0 
Local nx			:= 0 
Local lPls			:= Iif(Substr(cCpoFoto,4,3) == "BTS",.T.,.F.) 
Local lMVUDrFoto 	:= (GetMV("MV_UDRFOTO",, "0") == "1") // Define se vai ser via WebCam ou via diretorio
Local lIncluiu	  	:= .F.
Local nComboSel 	:= 1 						//Item selecionado do combo
Local cTam      	:= ""						//Tamanho da tela apresentada
Local aItens    	:= {}						//Cont้m todos os dispositivos
Local oFontNeg  	:= TFont():New("Tahoma")	//Fonte Negrita
Local oFont	  		:= TFont():New("Tahoma")	//Fonte Normal
Local oDlgWeb									//Dialog
Local oGrpWeb, oGrpPre							//Grupos da Dialog
Local oSayEsc, oSayCam, oSayF2					//Labels da Dialog
Local oCmbCams									//Combo da Dialog
Local oGetCam, cGetCam := ""					//Gets da Dialog
Local oBtnConf, oBtnCanc, oBtnAbre				//Bot๕es da Dialog
Default  aFotos :={}
Private  cPathFile	:= ''                              

cPathSrv	:= IIF(GetMV("MV_DIRFOTO") <> "",GetMV("MV_DIRFOTO"),Upper(GetTempPath())) //Upper(GetPvProfString( GetEnvServer() , "SourcePath" , "" , GetADV97() ) )
cFileJpg	:=	Alltrim(cIdFile)+'.BMP'
cPathFile	:= UPPER(cPathSrv+cFileJpg)

Begin Sequence    //<--Inicia Sequencia

If lMVUDrFoto .or. lPls // Usa drive da maquina fotografica ou vindo do PLS
  	
	nHandle := ExecInDLLOpen("imageload2.DLL")  
	If nHandle == -1
	    HS_MsgInf(STR0038, STR0004, STR0039) //"Falha ao carregar a DLL 'IMAGELOAD2.DLL'."###"Aten็ใo"###"Foto"
	    Return
	EndIf     
	
	// Obtem lista de cameras
	lstDisp := ""
	nRet:=ExeDLLRun2( nHandle, 1, @lstDisp) 
	
	// Define dimen็ใo de captura
	cTam:= "0400|0400"
  	nRet:=ExeDLLRun2( nHandle, 3, @cTam) // Largura|Altura (com 4 caracteres)
	
	//Tํtulo da Janela que serแ aberta com a imagem
	cTitle := "Totvs (F2=Tira Foto)"
	nRet:=ExeDLLRun2( nHandle, 4, @cTitle) 
	
			//Criando a janela
			DEFINE MSDIALOG oDlgWeb TITLE "Selecione" FROM 000, 000  TO 545, 420 COLORS 0, 16777215 PIXEL
				//Grupo WebCam
				@ 000, 001 GROUP oGrpWeb TO 052, 208 PROMPT "Selecione" OF oDlgWeb COLOR 0, 16777215 PIXEL
				
				//Defini็ใo das variaveis da WebCam
				cComboBo1 	:= 1
				lstDisp 	:= alltrim(lstDisp)+alltrim(lstDisp)
				aItens 		:= StrTokArr(lstDisp, "|")
				
				//Combo de escolha da webcam
			    @ 008, 008 SAY 			oSayEsc 	PROMPT 	"Escolha:" 						SIZE 025, 007 OF oDlgWeb COLORS   	CLR_AZUL   FONT oFont 			PIXEL
			    @ 007, 051 MSCOMBOBOX 	oCmbCams 	VAR 	cComboBo1 ITEMS aItens 			SIZE 145, 010 OF oDlgWeb COLORS 	0, 16777215 							PIXEL
			    @ 044, 003 SAY 			oSayF2 		PROMPT 	"Tecla para salvar imagem F2" 	SIZE 101, 007 OF oDlgWeb COLORS 	CLR_VERMELHO FONT oFontNeg 			PIXEL
			    //Bot๕es
			    @ 038, 169 BUTTON 		oBtnConf 	PROMPT 	"Confirmar" 					SIZE 037, 012 OF oDlgWeb ACTION {|| lRet:= hs_fDlgIncFoto(cIdFile,lPls),oDlgWeb:End()} 	PIXEL
			    @ 038, 130 BUTTON 		oBtnCanc 	PROMPT 	"Cancelar" 						SIZE 037, 012 OF oDlgWeb ACTION {|| lRet:=.F.,oDlgWeb:End() } 	PIXEL
			    @ 038, 091 BUTTON 		oBtnAbre 	PROMPT 	"Abrir" 						SIZE 037, 012 OF oDlgWeb ACTION {|| Captura(oCmbCams:nAt) } 		PIXEL
			    //Grupo Preview
				@ 057, 001 GROUP oGrpPre TO 270, 210 PROMPT "Preview: " OF oDlgWeb COLOR 0, 16777215 PIXEL
				@ 067, 006 BITMAP oBitmap1 SIZE 200, 200 OF oDlgWeb NOBORDER PIXEL
				//Ativando a janela
    		ACTIVATE MSDIALOG oDlgWeb CENTERED
	  
    If !lRet
    	Break
    Endif
 
	If  !Valtype (oEnchoice) =="U" .And. !lPls 
	          
		For nx:= 1 to len(oEnchoice:aEntryCtrls)
			If  oEnchoice:aEntryCtrls[nx]:ClassName() == 'FWIMAGEFIELD'
				oEnchoice:aEntryCtrls[nx]:oImagem:ReLoad(cIdFile)
			Endif
		Next
		
		oEnchoice:Refresh()
	    
	    //-- Armazena Fotos para Posterior Eliminacao
	    If valtype(aFotos)="A"
	    	aadd(aFotos,{cPathFile, cDestFile } )
	    Endif
	Endif
    
   
    //-- Verifica se Gravou em um dos Locais
    lRet:= ( File(cPathFile) .OR. File(cDestFile) )
    
    ExecInDLLClose(nHandle)
Else
	
	lRet := HS_SelFoto(@cPathFile, cIdFile)
	
	If lRet 
		For nx:= 1 to len(oEnchoice:aEntryCtrls)
			If  oEnchoice:aEntryCtrls[nx]:ClassName() == 'FWIMAGEFIELD'
				 oEnchoice:aEntryCtrls[nx]:oImagem:ReLoad(cIdFile)
			Endif
		Next
	Else
		HS_MsgInf(STR0041 + cPathFile, STR0004, STR0039) //"Falha ao incluir a imagem no reposit๓rio"###"Aten็ใo"###"Foto"
		lRet := .F.
		Break
	Endif
	
EndIf

End  //<--Finaliza Sequencia

If !lRet
 	cFileJpg	:= Iif(lPls,Alltrim(xFilial("BTS") + Alltrim(oEnchoice:GetValue('BTSMASTER','BTS_NOMUSR')) +'.BMP'),(xFilial("GBH")+M->GBH_CODPAC)+'.BMP') 
	cPathFile	:= UPPER(cPathSrv+cFileJpg)
	lRet		:= File(cPathFile)
Endif	

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณCaptura		 ณ Autor ณ Gustavo M.            ณ Data ณ03.04.2014ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao p/ Captura de Foto								       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ 			                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ						   		  								   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿/*/   
Static Function Captura(nAt)
//------------------------------	 

	// Define dispositivo
	nRet:=ExeDLLRun2( nHandle, 2, @cValToChar(nAt-1)) 
    
   	FERASE(cPathFile)
	// Abre tela de captura e define arquivo de imagem de saida
	tmpImgPadrao := cPathFile
	nRet := ExeDLLRun2( nHandle, 5, @tmpImgPadrao )
	
	// A aplica็ao continuara ao fechar a janela de captura
	// agora exibimos a imagem capturada
   
	// Necessario para "troca de imagem"
	oBitmap1:Load(,"ok.png")
  	ProcessMessages()
	
	// Exibe imagem capturada
	oBitmap1:Load(,cPathFile)
	ProcessMessages()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณfDlgIncFoto  ณ Autor ณ Mauricio MR           ณ Data ณ 06/04/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Coloca a Foto no Repositorio        						  	 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณfDlgIncFoto(cIdFile)										     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cIdFile - Identificador da Foto (M->PW_VISITA) 			     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ lFile - Logico de Retorno de Sucesso da Inclusao da Foto      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Pona330                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
static Function hs_fDlgIncFoto(cIdFile,lPls)

Local cDirAtu	:= ""

Local lFile		:= .T.
Local oDlg8
Local oBmp

// Inclui a Foto              								   ณ
DEFINE MSDIALOG oDlg8   FROM -1000,400 TO 1600,800  PIXEL 

@ 000, 000 REPOSITORY oBmp SIZE 60, 73 OF oDlg8    

lFile	:= fPutFoto(@oBmp, cIdFile,lPls )

ACTIVATE MSDIALOG oDlg8 ON INIT (oBmp:lStretch := .T.,oDlg8:End()) 

Return lFile
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณfPutFoto  ณ Autor ณ Mauricio MR           ณ Data ณ 06/08/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Insere  a Foto no Repositorio          					  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณfPutFoto(oBmp,cIdFile)									  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cIdFile 	- Caminho do \RootPath							  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ lFile - Logico representado que Incluiu a Foto             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Pona330                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fPutFoto(oBmp,cIdFile,lPls)
Local lFile 	:= .T. 
Local cFileJpg	:= '' 

cFileJpg		:=	Alltrim(cIdFile)+'.BMP'
cPathPict   	:= IIF(GetMV("MV_DIRFOTO") <> "",GetMV("MV_DIRFOTO"),Upper(GetTempPath()))+cFileJpg  //Upper(GetTempPath()+cFileJpg) 

IF !Empty( cPathPict)
	IF ( lFile	:= File	( cPathPict) )
   		oBmp:DeleteBmp 	(Alltrim(cIdFile))
		oBmp:InsertBmp	(cPathPict,,.T.)
		oBmp:LoadBmp		("ok.png")
		oBmp:Refresh		()
	    oBmp:LoadBmp		(cPathPict)
		oBmp:Refresh		()
	EndIF
EndIF

If lPls
	M->BTS_BITMAP:= cIdFile
Else
	M->GBH_BITMAP:= cFileJpg
Endif

Return (.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณHS_SelFotoบAutor  ณJos้ Orfeu          บ Data ณ  02/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta estrutura de diretorio para localiza็ใo da foto para บฑฑ
ฑฑบ          ณ cameras nใo homologadas com o Protheus                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ HS_SelFoto(cPathFile, cIdFile)                             บฑฑ
ฑฑบParโmetrosณ cPatchFile - Caminho e nome do arquivo da foto             บฑฑ
ฑฑบ          ณ cIdFile - nome do arquivo da foto                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Retora .T. caso consiga carregar a foto, caso contrario .F.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo Hospitalar                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_SelFoto(cPathFile, cIdFile)
 Local oDlgTree
 Local oArqTree
 Local oFotoImg
 Local nOpcTree := 0
 Local oScrollBox
 Local cMVDirFoto := Upper(GetMV("MV_DIRFOTO",, "\FOTOS\"))
 Local cMVTipFoto := Upper(GetMV("MV_TIPFOTO",, "BMP/JPG/IMG"))
 Local aButtons	  := {{"MAQFOTO", {|| FS_AjustaFoto(oFotoImg)}, OemToAnsi(STR0042), OemToAnsi(STR0043)}} //"Ajusta Foto <F4>"###"Ajusta"
 Local bKeyf4     :=	SetKey(VK_F4, {|| FS_AjustaFoto(oFotoImg)})

 cMVDirFoto += IIf(SubStr(cMVDirFoto, Len(cMVDirFoto), 1) <> "\", "\", "")

 If     Empty(cMVDirFoto)
  HS_MsgInf(STR0044, STR0004, STR0039) //"Defina o parโmetro [MV_DIRFOTO] com o diret๓rio onde estใo localizados o arquivos das fotos."###"Aten็ใo"###"Foto"

 ElseIf !lIsDir(cMVDirFoto)
  HS_MsgInf(STR0045 + cMVDirFoto + STR0046, STR0004, STR0039) //"Diret๓rio ["###"Aten็ใo"###"] definido no parโmetro [MV_DIRFOTO] nใo existe."###"Foto"

 ElseIf Empty(cMVTipFoto)
  HS_MsgInf(STR0047, STR0004, STR0039) //"Defina o parโmetro [MV_TIPFOTO] com as extens๕es vแlidas para arquivos de imagens."###"Aten็ใo"###"Foto"

 Else

  DEFINE DIALOG oDlgTree TITLE STR0048 FROM 10,10 TO 400,700 PIXEL  //"Selecione o arquivo"

   oArqTree	:= DbTree():New(000, 000, 100, 200, oDlgTree, NIL, NIL, .T.)
   oArqTree:bLDblClick := {|| FS_LoadImg(oFotoImg, AllTrim(oArqTree:GetCargo()), cMVTipFoto, @cPathFile, cIdFile)}

   oArqTree:Hide()

	  If FS_LstArq(oArqTree, cMVDirFoto, "D", cMVTipFoto)
	   oArqTree:EndTree()
	  EndIf

   oArqTree:Show()
   oArqTree:Align := CONTROL_ALIGN_LEFT

   oScrollBox := TScrollBox():New(oDlgTree, 000, 000, 200, 200, .T., .T., .T.)
   oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

   @ 000, 000 BITMAP oFotoImg SIZE 200, 200 OF oScrollBox WHEN .F. PIXEL
   oFotoImg:Align := CONTROL_ALIGN_ALLCLIENT

  ACTIVATE DIALOG oDlgTree ON INIT EnChoiceBar(oDlgTree, {|| IIf(FS_GrvImg(@nOpcTree, AllTrim(oArqTree:GetCargo()), cPathFile), oDlgTree:End(), .F.)}, ;
                                                         {|| nOpcTree := 0, oDlgTree:End()},, aButtons)

 EndIf

 SetKey(VK_F4, bKeyf4)
Return(nOpcTree == 1)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณFS_GrvImg บAutor  ณJos้ Orfeu          บ Data ณ  02/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta estrutura de diretorio para localiza็ใo da foto para บฑฑ
ฑฑบ          ณ cameras nใo homologadas com o Protheus                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ HS_SelFoto(cPathFile, cIdFile)                             บฑฑ
ฑฑบParโmetrosณ cPatchFile - Caminho e nome do arquivo da foto             บฑฑ
ฑฑบ          ณ cIdFile - nome do arquivo da foto                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Retora .T. caso consiga carregar a foto, caso contrario .F.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo Hospitalar                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvImg(nOpcTree, cFoto, cPathFile)
 Local lRet := .F.

 If !File(cPathFile) .Or. (lRet := (FErase(cPathFile) == 0))

  __CopyFile(cFoto, cPathFile)

  If lRet := File(cPathFile)
   nOpcTree := 1
  Else
   nOpcTree := 0
   HS_MsgInf(STR0052 + cFoto + STR0053 + cPathFile + "]", STR0004, STR0039) //"Falha na c๓pia do arquivo ["###"Aten็ใo"###"] para o arquivo ["###"Foto"
  EndIf
 EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณFS_GrvImg บAutor  ณJos้ Orfeu          บ Data ณ  02/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta estrutura de diretorio para localiza็ใo da foto para บฑฑ
ฑฑบ          ณ cameras nใo homologadas com o Protheus                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ HS_SelFoto(cPathFile, cIdFile)                             บฑฑ
ฑฑบParโmetrosณ cPatchFile - Caminho e nome do arquivo da foto             บฑฑ
ฑฑบ          ณ cIdFile - nome do arquivo da foto                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Retora .T. caso consiga carregar a foto, caso contrario .F.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo Hospitalar                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_LstArq(oArqTree, cDiretorio, cAtributos, cMVTipFoto)
 Local aDirArq    := {}, nDirArq := 0, nQtdFor := 0, lRet := .F.
 Local cCargo     := AllTrim(IIf(oArqTree:GetCargo() # Nil, oArqTree:GetCargo(), ""))
 Local nDigCargo  := 0
 Local cDirAnteri := ""
 Local cExtImg    := ""

 Default cDiretorio := "C:\"
 Default cAtributos := "D"

 aDirArq   := Directory(AllTrim(cDiretorio) + "*.*", cAtributos)
 nQtdFor   := Len(aDirArq)
 nDigCargo := Len(AllTrim(Str(nQtdFor)))

 aSort(aDirArq,,, {|X, Y| X[5]+Y[1] > Y[5]+X[1]})

 For nDirArq := 1 To nQtdFor

	 If aDirArq[nDirArq][5] == "D"

	  If SubStr(aDirArq[nDirArq][1], 1, 1) <> "."
	   cDirAnteri := cDiretorio
	   cDiretorio += aDirArq[nDirArq][1] + "\"
	   oArqTree:AddTree(PadR(aDirArq[nDirArq][1], 50), .T., "FOLDER5", "FOLDER6",,, PadR(AllTrim(cDiretorio), 100))
	   FS_LstArq(oArqTree, cDiretorio, "D", cMVTipFoto)
	   cDiretorio := cDirAnteri
	   oArqTree:EndTree()
	   lRet := .T.
	  EndIf

	 Else

	  SplitPath(AllTrim(aDirArq[nDirArq][1]),,,, @cExtImg)
	  If SubStr(cExtImg, 2) $ cMVTipFoto
	   oArqTree:AddTreeItem(Padr(aDirArq[nDirArq][1], 50), "MAQFOTO", "MAQFOTO", PadR(AllTrim(cDiretorio) + AllTrim(aDirArq[nDirArq][1]), 100))
	   lRet := .T.
	  EndIf
	 EndIf

	Next nDirArq

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณFS_GrvImg บAutor  ณJos้ Orfeu          บ Data ณ  02/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta estrutura de diretorio para localiza็ใo da foto para บฑฑ
ฑฑบ          ณ cameras nใo homologadas com o Protheus                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ HS_SelFoto(cPathFile, cIdFile)                             บฑฑ
ฑฑบParโmetrosณ cPatchFile - Caminho e nome do arquivo da foto             บฑฑ
ฑฑบ          ณ cIdFile - nome do arquivo da foto                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Retora .T. caso consiga carregar a foto, caso contrario .F.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo Hospitalar                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_LoadImg(oFotoImg, cFoto, cMVTipFoto, cPathFile, cIdFile)
 Local cExtImg := "", cDisco := "", cDiretorio := "", cArquivo := "", lRetLoad := .F.

 SplitPath(cFoto, @cDisco, @cDiretorio, @cArquivo, @cExtImg)

 If SubStr(cExtImg, 2) $ cMVTipFoto

  oFotoImg:lAutoSize := .T. // Para mostrar a foto inteira
  oFotoImg:SetEmpty()
  If lRetLoad := oFotoImg:Load(, cFoto)
   oFotoImg:Refresh()
   cPathFile := cDisco + cDiretorio + cIdFile + cExtImg
  EndIf

 EndIf

Return(lRetLoad)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณFS_GrvImg บAutor  ณJos้ Orfeu          บ Data ณ  02/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta estrutura de diretorio para localiza็ใo da foto para บฑฑ
ฑฑบ          ณ cameras nใo homologadas com o Protheus                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ HS_SelFoto(cPathFile, cIdFile)                             บฑฑ
ฑฑบParโmetrosณ cPatchFile - Caminho e nome do arquivo da foto             บฑฑ
ฑฑบ          ณ cIdFile - nome do arquivo da foto                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Retora .T. caso consiga carregar a foto, caso contrario .F.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo Hospitalar                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_AjustaFoto(oFotoImg)
 oFotoImg:lAutoSize := .F. // Para permitir stretch
 oFotoImg:Align     := CONTROL_ALIGN_ALLCLIENT
 oFotoImg:lStretch  := !oFotoImg:lStretch
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_ExisDic บAutor  ณPatricia Queiroz  บ Data ณ  26/01/07    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica se os campos, tabelas e indices informados        บฑฑ
ฑฑบ            existem na base de dados.                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบParametrosณ aCampos : array com os dados a serem verificados           บฑฑ
ฑฑบ            lMsg    : flag para imprimir mensagem                      บฑฑ
ฑฑบ            cPrefixo: nome da tabela                                   บฑฑ
ฑฑบ            cCampo  : nome do campo                                    บฑฑ
ฑฑบ            cBops   : Mensagem para informar o BOPS a ser executado    บฑฑ
ฑฑบ            cCPos   : array que recebe campos/indices/tabelas inexist  บฑฑ
ฑฑบ            cMsg(C,T,I): armazena os registros nใo encontrados         บฑฑ
ฑฑบ                                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_ExisDic(aCampos, lMsg)

 Local aArea      := GetArea()
 Local nFor       := 0
 Local nForCpo    := 0
 Local aCpos      := {}
 Local cMsgCDic   := ""
 Local cMsgTDic   := ""
 Local cMsgIDic   := ""
 Local cMsgCBco   := ""
 Local cMsgTBco   := ""
 Local cMsgIBco   := ""
 Local cMsgBops   := ""
 Local lRet       := .T.
 Local cBops      := ""

 Private cPrefixo := ""
 Private cCampo   := ""

 Default lMsg     := .T.

 For nFor := 1 To Len(aCampos)

  cPrefixo := aCampos[nFor, 2]
  If aCampos[nFor, 1] == "C"
   cPrefixo := PADL(SubStr(aCampos[nFor, 2], 1, aT("_",aCampos[nFor, 2])-1), 3, "S")
  EndIf
  cCampo   := aCampos[nFor, 2]
  cBops    := IIf(len(aCampos[nFor]) == 3,aCampos[nFor,3],"") // Pega o Bops se existir ou em branco se for sistema antigo

  If aCampos[nFor, 1] == "T"
   DbSelectArea("SX2")
   DbSetOrder(1) //X2_CHAVE
   If !DbSeek(cCampo) //verifica exist๊ncia da tabela no dicionแrio de dados
    aAdd(aCpos, {"T", cCampo, 1,cBops})
   EndIf
  ElseIf aCampos[nFor, 1] == "C"
  DbSelectArea("SX3")
  DbSetOrder(2) // X3_CAMPO
   If !DbSeek(cCampo) //verifica exist๊ncia do campo no dicionแrio de dados
     aAdd(aCpos, {"C", cCampo, 1, cBops})
   ElseIf &(cPrefixo + "->(FieldPos(cCampo))") == 0 .AND. SX3->X3_CONTEXT <> "V"//verifica exist๊ncia do campo no banco de dados
     aAdd(aCpos, {"C", cCampo, 2, cBops})
   EndIf
  ElseIf aCampos[nFor, 1] == "I"
   DbSelectArea("SIX")
   DbSetOrder(1) //INDICE+ORDEM
   If !DbSeek(cPrefixo + HS_CIND(aCampos[nFor, 3])) //verifica exist๊ncia do ํndice no dicionแrio de dados
     aAdd(aCpos, {"I", RetSqlName(cPrefixo) + HS_CIND(aCampos[nFor, 3]), 1, cBops})
   ElseIf !(TCCANOPEN(RetSqlName(cPrefixo), RetSqlName(cPrefixo) + HS_CIND(aCampos[nFor, 3])))//verifica exist๊ncia do ํndice no banco de dados
	    aAdd(aCpos, {"I", RetSqlName(cPrefixo) + HS_CIND(aCampos[nFor, 3]), 2, cBops})
   EndIf
  EndIf
 Next

 aSort(aCampos,,, {|x, y| x[1] < y[1]})

  If !(lRet := Empty(aCpos)) .And. lMsg
   For nForCpo := 1 To Len(aCpos)
    If aCpos[nForCpo, 1] == "C"
   	 If aCpos[nForCpo, 3] == 1 //verifica se o campo nใo foi encontrado no dicionแrio
      If !Empty(cMsgCDic)
       cMsgCDic += ", "
       cMsgCDic += aCpos[nForCpo, 2]
      Else
       cMsgCDic += aCpos[nForCpo, 2]
      EndIf
     ElseIf aCpos[nForCpo, 3] == 2 //verifica se o campo nใo foi encontrado no banco
      If !Empty(cMsgCBco)
       cMsgCBco += ", "
       cMsgCBco += aCpos[nForCpo, 2]
      Else
       cMsgCBco += aCpos[nForCpo, 2]
      EndIf
     EndIf
    ElseIf aCpos[nForCpo, 1] == "T"
     If aCpos[nForCpo, 3] == 1 //verifica se a tabela nใo foi encontrada no dicionแrio
      If !Empty(cMsgTDic)
       cMsgTDic += ", "
       cMsgTDic += aCpos[nForCpo, 2]
      Else
       cMsgTDic += aCpos[nForCpo, 2]
      EndIf
     ElseIf aCpos[nForCpo, 3] == 2 //verifica se a tabela nใo foi encontrada no banco
      If !Empty(cMsgTBco)
       cMsgTBco += ", "
       cMsgTBco += aCpos[nForCpo, 2]
      Else
       cMsgTBco := aCpos[nForCpo, 2]
      EndIf
     EndIf
    ElseIf aCpos[nForCpo, 1] == "I"
     If aCpos[nForCpo, 3] == 1 //verifica se o ํndice nใo foi encontrado no dicionแrio
      If !Empty(cMsgIDic)
       cMsgIDic += ", "
       cMsgIDic += aCpos[nForCpo, 2]
      Else
       cMsgIDic += aCpos[nForCpo, 2]
      EndIf
     ElseIf aCpos[nForCpo, 3] == 2 //verifica se o ํndice nใo foi encontrado no banco
      If !Empty(cMsgIBco)
       cMsgIBco += ", "
       cMsgIBco += aCpos[nForCpo, 2]
      Else
       cMsgIBco += aCpos[nForCpo, 2]
      EndIf
     EndIf
    EndIf

				// Guarda mensagens informando o BOPS
    If !Empty(cMsgBops)
     If at(aCpos[nForCpo, 4], cMsgBops) == 0
	     cMsgBops += ", "
	     cMsgBops += aCpos[nForCpo, 4]
	    Endif
    Else
     cMsgBops = aCpos[nForCpo, 4]
    EndIf
   Next


			IF len(aCampos[1]) == 3 // Se for no sitema novo informa o bops a ser executado
	    If cMsgBops <> ""
	     HS_MsgInf(STR0063 + cMsgBops + ".", STR0004, STR0017) //"Por favor, para a atualiza็ใo desta rotina, execute o(s) atualizador(es):"###"Aten็ใo"###"Valida็ใo de Dicionแrios"
					Endif
			Else // Sistema antigo
	   If aScan(aCpos, {| aVet | aVet[1] == "T"}) <> 0
	    If cMsgTDic <> ""
	     HS_MsgInf(STR0015 + cMsgTDic + STR0016 + ".", STR0004, STR0017) //Por favor, para executar esta rotina, verifique a exist๊ncia da(s) tabela(s) "###" no dicionแrio de dados. "Aten็ใo"###"Valida็ใo de Dicionแrios"
	    ElseIf cMsgTBco <> ""
	     HS_MsgInf(STR0015 + cMsgTBco + STR0061 + ".", STR0004, STR0062) //Por favor, para executar esta rotina, verifique a exist๊ncia da(s) tabela(s) "###" no banco de dados. "Aten็ใo"###"Valida็ใo de Bancos"
	    EndIf
	   ElseIf aScan(aCpos, {| aVet | aVet[1] == "C"}) <> 0
	    If cMsgCDic <> ""
	     HS_MsgInf(STR0018 + cMsgCDic + STR0016 + ".", STR0004, STR0017) //Por favor, para executar esta rotina, verifique a exist๊ncia do(s) campo(s) "###" no dicionแrio de dados. "Aten็ใo"###"Valida็ใo de Dicionแrios"
	    ElseIf cMsgCBco <> ""
	     HS_MsgInf(STR0018 + cMsgCBco + STR0061 + ".", STR0004, STR0062) //Por favor, para executar esta rotina, verifique a exist๊ncia do(s) campo(s) "###" no banco de dados. "Aten็ใo"###"Valida็ใo de Bancos"
	    EndIf
	   ElseIf aScan(aCpos, {| aVet | aVet[1] == "I"}) <> 0
	    If cMsgIDic <> ""
	     HS_MsgInf(STR0019 + cMsgIDic + STR0016 + ".", STR0004, STR0017) //Por favor, para executar esta rotina, verifique a exist๊ncia do(s) ํndice(s) "###" no dicionแrio de dados. "Aten็ใo"###"Valida็ใo de Dicionแrios"
	    ElseIf cMsgIBco <> ""
	     HS_MsgInf(STR0019 + cMsgIBco + STR0061 + ".", STR0004, STR0062) //Por favor, para executar esta rotina, verifique a exist๊ncia do(s) ํndice(s) "###" no banco de dados. "Aten็ใo"###"Valida็ใo de Bancos"
	    EndIf
	   EndIf
	  Endif

  EndIf

 RestArea(aArea)

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldQues บAutor  ณPatricia Queiroz    บ Data ณ 21/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para marcar e desmarcar o item.                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ                                                                          บฑฑ
ฑฑบ           cModo = G - Mostra todos os grupos                          บฑฑ
ฑฑบ                   E - Somente 1-Elaboracao                            บฑฑ
ฑฑบ                   C - Somente 2-Conclusao                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldQues(cCDQues, cModo, nFolder, aField, aFolder, nField, cIniCpo, cEncObj)

Local aArea := GetArea()
Local cSql  := ""
Local lRet  := .F.

cSql := "SELECT GFT_GRPPER, GFT_NMPAST, GFT_ORDAPR FROM " + RetSqlName("GFT") + " "
cSql += "WHERE GFT_FILIAL = '" + xFilial("GFT") + "' AND GFT_CDQUES = '" + cCDQues + "' AND D_E_L_E_T_ <> '*'"

If cModo <> "G" // Mostra todos os grupos

	cSql += "AND GFT_TPPERM IN ('0'"

	If     (cModo == "E") // 1-Elabora็ใo
		cSql += ", '1'"
	ElseIf (cModo == "C") // 2-Conclusao
		cSql += ", '2'"
	EndIf

	cSql += ")"

EndIf

cSql += " ORDER BY GFT_ORDAPR"
TCQUERY ChangeQuery(cSql) NEW ALIAS "TMPGFT"

DbSelectArea("TMPGFT")
//DbGoTop()

lRet := !Eof()

If aField <> Nil
	While !Eof()
		FS_AField(TMPGFT->GFT_GRPPER, nFolder, @aField, @nField, cIniCpo, cEncObj)

		aAdd(aFolder, TMPGFT->GFT_NMPAST)

		nFolder++

		DbSkip()
	EndDo
EndIf

DbCloseArea()
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_PICPES บAutor  ณBruno Santos        บ Data ณ  24/07/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que verifica qual mascara deverแ ser retornada para บฑฑ
ฑฑบ          ณ o campo CNPJ/CPF dependendo do tipo da variavel __cTpPic   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cTipo:Tipo F(Fisico) ou J(Juridico)                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ cPic:Mascarแ que serแ utilizada pelo campo                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo Hospitalar                                          บฑฑ
ฑฑบ          ณ Importante a variavel __cTpPic tem que ser declarada como  บฑฑ
ฑฑบ          ณ Private                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_PICPES(cTipo)
 Local cPict := ""

 If (Type("__cTpPic") # "U") .And. (!Empty(__cTpPic))
  If cTipo == "F"
   cPict := "@R 999.999.999-99"
  Else
   cPict := "@R 99.999.999/9999-99"
  EndIf
  cPict += "%C"
 EndIf

Return(cPict)

Static Function FS_MntTexto(oObj, nColMark, nColCod, cTextoIns, aField, cCpoMem)
Local nPos     := 0
Local aAreaOld := GetArea()
Local cTxtMne  := ""
Local nPosMemo := aScan(aField, {| aVet | aVet[2] == cCpoMem})

 DBSelectArea("GCQ")
 DbSetOrder(1)
 If DbSeek(xFilial("GCQ") + oObj:aCols[oObj:nAt, nColCod])
  cTxtMne := GCQ->GCQ_TXTMNE

  If oObj:aCols[oObj:nAt, nColMark] == "LBNO"
   oObj:aCols[oObj:nAt, nColMark] := "LBTIK"
   cTextoIns += cTxtMne + Chr(10) + Chr(13)

   If Type("aMneSele") == "A" .And. aScan(aMneSele, {|aVet| aVet[1] == aField[nPosMemo, 23] .And. aVet[2] == oObj:aCols[oObj:nAt, nColCod]}) == 0
  	 aAdd(aMneSele, {aField[nPosMemo, 23], oObj:aCols[oObj:nAt, nColCod]})
   EndIf

  Else //desmarca
   oObj:aCols[oObj:nAt, nColMark] := "LBNO"
   If (nPos := AT(cTxtMne, cTextoIns)) > 0
    cTextoIns := SUBSTR(cTextoIns, 1, nPos - 1) + SUBSTR(cTextoIns, nPos + Len(cTxtMne) + 2)
   EndIf
   If Type("aMneSele") == "A" .And. (nPos := aScan(aMneSele, {|aVet| aVet[1] == aField[nPosMemo, 23] .And. aVet[2] == oObj:aCols[oObj:nAt, nColCod]})) > 0
    aDel(aMneSele, nPos)
    aSize(aMneSele, Len(aMneSele) - 1)
   EndIf
  EndIf

 EndIf

 RestArea(aAreaOld)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_ATXBGCSบAutor  ณDarcio Ribeiro Sporlบ Data ณ  03/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para atualizar a consulta padrao GCS, para    บฑฑ
ฑฑบ          ณimplementar o botao de visualizar.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_ATXBGCS()
Local aRegs := {}
Local i		:= 0

AADD(aRegs,{"GCS   ","3","01","01","Cadastra Novo       ","Registra Nuevo      ","Add New             ","01##HS_A12('GCS',Recno(),2)                                                                                                                                                                                                                               ","                                                                                                                                                                                                                                                          "})

dbSelectArea("SXB")
dbSetOrder(1)

For i := 1 to Len(aRegs)
	If !DbSeek(aRegs[i,1] + aRegs[i,2] + aRegs[i,3] + aRegs[i,4])
		RecLock("SXB", .T.)
			SXB->XB_ALIAS	:= aRegs[i,1]
			SXB->XB_TIPO	:= aRegs[i,2]
			SXB->XB_SEQ		:= aRegs[i,3]
			SXB->XB_COLUNA	:= aRegs[i,4]
			SXB->XB_DESCRI	:= aRegs[i,5]
			SXB->XB_DESCSPA	:= aRegs[i,5]
			SXB->XB_DESCENG	:= aRegs[i,7]
			SXB->XB_CONTEM	:= aRegs[i,8]
		MsUnlock()
	EndIf
Next i

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GERDMEDบAutor  ณDarcio R. Sporl     บ Data ณ  01/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para geracao das informacoes, para a exporta- บฑฑ
ฑฑบ          ณcao da Dmed.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_GERDMED()
LOCAL cCamArq	:= GetNewPar("MV_CAMDMED", "")
LOCAL cCamDat	:= GetSrvProfString("RootPath", "")
LOCAL dDatIni	:= ""
LOCAL dDatFin	:= ""
LOCAL cQryTit	:= ""
LOCAL cQryDep	:= ""
LOCAL cNome		:= ""
LOCAL cNome1	:= ""
LOCAL cNomArq	:= ""
LOCAL cArqDemd	:= ""
LOCAL cDmed		:= ""
LOCAL cRESPO	:= ""
LOCAL cDECPJ	:= ""
LOCAL cPSS		:= ""
LOCAL cRPPSS	:= ""
LOCAL cBRPPSS	:= ""
LOCAL cFimDmed	:= ""

If !Pergunte("HSPDMED", .T.)
	Return
EndIf

ProcRegua(1)

cNome	:= Iif(MV_PAR03 == 2, "ORIG", "RETI")

cNome1	:= Iif(MV_PAR03 == 2,"N","S")

cCamArq := Iif(Empty(cCamArq), cCamDat, cCamArq)

cNomArq := Alltrim(SM0->M0_CGC) + "-Dmed-" + AllTrim(MV_PAR01) + "-" + AllTrim(MV_PAR02) + "-" + cNome + "-" + cNome1 + ".TXT"

cArqDemd := fCreate(cCamArq + "\" + cNomArq)  // Carrega o caminho e o nome do arquivo gerado

HS_MsgInf("Em instantes o arquivo " + cNomArq + " serแ gerado no endere็o " + cCamArq + ".", "Aten็ใo", "Exporta็ใo Dmed")

ProcRegua(8)

IncProc("Gerando o arquivo DMED " + cNomArq + "no caminho " + cCamArq)

cDmed := "Dmed|"							//Dmed
If Empty(MV_PAR01)
	HS_MsgInf("ษ obrigat๓rio o preenchimento do ano de refer๊ncia.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
	FClose(cArqDemd)
	Return
Else
	cDmed += AllTrim(MV_PAR01)	+ "|"	//Ano referencia
EndIf

If Empty(MV_PAR02)
	HS_MsgInf("ษ obrigat๓rio o preenchimento do ano do calendแrio.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
	FClose(cArqDemd)
	Return
Else
	cDmed += AllTrim(MV_PAR02)	+ "|"	//Ano calendario
EndIf

If Empty(cNome1)
	HS_MsgInf("ษ obrigat๓rio o preenchimento do indicador de retificadora, preencher com S ou N.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
	FClose(cArqDemd)
	Return
Else
	cDmed += AllTrim(cNome1)			+ "|"	//Indicador de retificadora
EndIf

If cNome1 == "S"
	If Empty(MV_PAR04)
		HS_MsgInf("A declara็ao ้ retificadora, favor preencher o n๚mero do recibo.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
		FClose(cArqDemd)
		Return
	Else
		cDmed += AllTrim(MV_PAR04)		//Numero recibo
	EndIf
EndIf
cDmed += "|"

cLayEstru := &("X1DEF0"+AllTrim(Str(MV_PAR17))+"()")

//A partir de 2019 nใo precisa mais enviar o identificador de estrutura
//Na aus๊ncia de informa็ใo, o campo vazio (campo sem conte๚do; nulo e com valor zero)
//deverแ ser iniciado com caractere “|” e imediatamente encerrado com o mesmo caractere “|”
//delimitador de campo.
cDmed += iif(AllTrim(MV_PAR02) == "2019", "", AllTrim(cLayEstru)) + "|" //Identificador de estrutura do layout
FWrite(cArqDemd, cDmed + chr(13) + chr(10))

IncProc("Gerando os dados do responsแvel pelo preenchimento.")
//Registro do responsavel pelo preenchimento
cRESPO := "RESPO|"
If Empty(MV_PAR05)
	HS_MsgInf("ษ obrigat๓rio o preenchimento do CPF do Responsแvel.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
	FClose(cArqDemd)
	Return
Else
	cRESPO += AllTrim(MV_PAR05)	+ "|"	//CPF
EndIf

If Empty(AllTrim(MV_PAR06))
	HS_MsgInf("ษ obrigat๓rio o preenchimento do nome do responsแvel.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
	FClose(cArqDemd)
	Return
Else
	cRESPO += AllTrim(AllTrim(MV_PAR06))			+ "|"	//Nome
EndIf

If Empty(MV_PAR07)
	HS_MsgInf("ษ obrigat๓rio o preenchimento do DDD do responsแvel.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
	FClose(cArqDemd)
	Return
Else
	cRESPO += AllTrim(MV_PAR07)	+ "|"	//DDD
EndIf

If Empty(MV_PAR08)
	HS_MsgInf("ษ obrigat๓rio o preenchimento do telefone do responsแvel.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
	FClose(cArqDemd)
	Return
Else
	cRESPO += AllTrim(MV_PAR08)	+ "|"	//Telefone
EndIf

cRESPO += AllTrim(MV_PAR09)		+ "|"	//Ramal
cRESPO += AllTrim(MV_PAR10)		+ "|"	//Fax
cRESPO += AllTrim(MV_PAR11)		+ "|"	//E-mail
FWrite(cArqDemd, cRESPO + chr(13) + chr(10))

IncProc("Gerando os dados do declarante pessoa jurํdica.")
//Registro de informacao do declarante pessoa juridica
cDECPJ := "DECPJ|"
If Empty(SM0->M0_CGC)
	HS_MsgInf("ษ obrigat๓rio o preenchimento do CNPJ do declarante pessoa jurํdica.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
	FClose(cArqDemd)
	Return
Else
	cDECPJ += AllTrim(SM0->M0_CGC)	+ "|"	//CNPJ
EndIf

If Empty(SM0->M0_NOMECOM)
	HS_MsgInf("ษ obrigat๓rio o preenchimento do nome empresarial.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
	FClose(cArqDemd)
	Return
Else
	cDECPJ += AllTrim(SM0->M0_NOMECOM)			+ "|"	//Nome Empresarial
EndIf

If Empty(MV_PAR12)
	HS_MsgInf("ษ obrigat๓rio o preenchimento do tipo do declarante.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
	FClose(cArqDemd)
	Return
Else
	cDECPJ += AllTrim(Str(MV_PAR12))	+ "|"	//Tipo do Declarante
EndIf

If AllTrim(Str(MV_PAR12)) $ ('23') .And. Empty(MV_PAR13)
	HS_MsgInf("ษ obrigat๓rio o preenchimento do Registro ANS.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
	FClose(cArqDemd)
	Return
Else
	cDECPJ += AllTrim(MV_PAR13)	+ "|"	//Registro ANS
EndIf

If !Empty(SM0->M0_CNES)
	cDECPJ += AllTrim(SM0->M0_CNES)		//CNES
EndIf

cDECPJ += "|"

If Empty(MV_PAR14)
	HS_MsgInf("ษ obrigat๓rio o preenchimento do CPF Responsแvel perante o CNPJ.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
	FClose(cArqDemd)
	Return
Else
	cDECPJ += AllTrim(MV_PAR14)	+ "|"	//CPF Responsavel perante o CNPJ
EndIf

If Empty(MV_PAR15)
	HS_MsgInf("ษ obrigat๓rio o preenchimento do Indicador de situa็ใo da declara็ใo.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
	FClose(cArqDemd)
	Return
Else
	cDECPJ += AllTrim(Iif(MV_PAR15 == 1,"S","N"))			+ "|"	//Indicador Situacao da Declaracao
EndIf

If MV_PAR15 == 1 .And. Empty(MV_PAR16)
	HS_MsgInf("ษ obrigat๓rio o preenchimento da data do evento.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
	FClose(cArqDemd)
	Return
Else
	cDECPJ += Iif(Empty(MV_PAR16),"",DtoS(MV_PAR16))		//Data do Evento
EndIf

cDECPJ += "|"
FWrite(cArqDemd, cDECPJ + chr(13) + chr(10))

IncProc("Gerando os dados de faturamento.")

Processa({||FS_GerDados(cArqDemd, @cNomArq, @cCamArq)},"Processando","Aguarde, gerando arquivo DMED",.F.)

HS_MsgInf("Gerado o arquivo " + cNomArq + ", no endere็o " + cCamArq + " com sucesso.", "Aten็ใo", "Exporta็ใo Dmed")

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GerInf บAutor  ณDarcio Ribeiro Sporlบ Data ณ  01/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para geracao das informacoes de titulares e   บฑฑ
ฑฑบ          ณdependentes da DMED.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GerDados(cArqDemd, cNomArq, cCamArq)
LOCAL cStaGui	:= GetNewPar("MV_STAGUIA", "")
LOCAL lLoja		:= GetNewPar("MV_LOJAHSP", .F.)
LOCAL dDatIni	:= ""
LOCAL dDatFin	:= ""
LOCAL cQryTit	:= ""
LOCAL cPSS		:= ""
LOCAL cRPPSS	:= ""
LOCAL cFimDmed	:= ""
LOCAL aRet		:= {}
LOCAL cAlias	:= "TMPDMED"
LOCAL aStru		:= {}
LOCAL nI		:= 0
Local oTempTable
Local lHsdMTit  := ExistBlock("HSDMTIT")

IF Select( cAlias ) > 0
	DbSelectArea( cAlias )
	DbCloseArea()
Endif

//-------------------
//Cria็ใo do objeto
//-------------------
oTempTable := FWTemporaryTable():New(cAlias)


//Cria arquivo temporario
AADD(aStru,{"REGTIT"	,"C",006,0})
AADD(aStru,{"CPF"		,"C",011,0})
AADD(aStru,{"NOME"		,"C",060,0})
AADD(aStru,{"VALOR"		,"C",012,0})

oTemptable:SetFields(aStru)
oTempTable:AddIndex("1", {"CPF"} )
//------------------
//Cria็ใo da tabela
//------------------
oTempTable:Create()

If Empty(cStaGui)
	cStaGui := "'4'"
EndIf

dDatIni := MV_PAR02 + "0101"
dDatFin := MV_PAR02 + "1231"

//Seleciona todos os faturamentos
If lLoja //Com integracao com o Loja
	cQryTit := "SELECT (CASE GD4_REGTIT WHEN '' THEN GCZ_REGGER ELSE GD4_REGTIT END) REGTIT, SUM(GCZ_VLGUIA) VLGUIA "
	cQryTit += "FROM " + RetSqlName("GCZ") + " GCZ "
	cQryTit += "LEFT JOIN " + RetSqlName("GBH") + " GBH ON GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.GBH_CODPAC = GCZ.GCZ_REGGER AND GBH.D_E_L_E_T_ = ' ' "
	cQryTit += "JOIN " + RetSqlName("GD4") + " GD4 ON GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.GD4_REGGER = GCZ.GCZ_REGGER AND GD4.GD4_IDPADR = '1' AND GD4.D_E_L_E_T_ = ' ' "
	cQryTit += "JOIN " + RetSqlName("GA9") + " GA9 ON GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.D_E_L_E_T_ = ' ' AND GA9.GA9_TIPCON = '1' "
	cQryTit += "JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = GBH.GBH_CODCLI AND SA1.A1_PESSOA = 'F' AND SA1.D_E_L_E_T_ = ' ' "
	cQryTit += "JOIN " + RetSqlName("SL1") + " SL1 ON SL1.L1_FILIAL = '" + xFilial("SL1") + "' AND SL1.L1_CLIENTE = SA1.A1_COD AND SL1.L1_DOC <> ' ' AND SL1.L1_SERIE <> ' ' AND SL1.L1_STATUS <> 'D' AND SL1.L1_STATUS <> 'F' AND SL1.D_E_L_E_T_ = ' ' "
	cQryTit += "WHERE GCZ.GCZ_FILFAT = '" + xFilial("GCZ") + "' "
	cQryTit += "  AND GCZ.GCZ_STATUS IN (" + cStaGui + ") "
	cQryTit += "  AND GCZ.D_E_L_E_T_ = ' ' "
	cQryTit += "  AND GCZ.GCZ_DATFAT BETWEEN '" + dDatIni + "' AND '" + dDatFin + "' "
	cQryTit += "  AND GCZ.GCZ_VLGUIA > 0 "
	cQryTit += "GROUP BY (CASE GD4_REGTIT WHEN '' THEN GCZ_REGGER ELSE GD4_REGTIT END), GBH_CPF " 
	cQryTit += "ORDER BY GBH_CPF"
Else
	cQryTit := "SELECT (CASE GD4_REGTIT WHEN '' THEN GCZ_REGGER ELSE GD4_REGTIT END) REGTIT, SUM(GCZ_VLGUIA) VLGUIA "
	cQryTit += "FROM " + RetSqlName("GCZ") + " GCZ "
	cQryTit += "LEFT JOIN " + RetSqlName("GBH") + " GBH ON GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.GBH_CODPAC = GCZ.GCZ_REGGER AND GBH.D_E_L_E_T_ = ' ' "
	cQryTit += "JOIN " + RetSqlName("GD4") + " GD4 ON GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.GD4_REGGER = GCZ.GCZ_REGGER AND GD4.GD4_IDPADR = '1' AND GD4.D_E_L_E_T_ = ' ' "
	cQryTit += "JOIN " + RetSqlName("GA9") + " GA9 ON GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.D_E_L_E_T_ = ' ' AND GA9.GA9_TIPCON = '1' "
	cQryTit += "JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = GBH.GBH_CODCLI AND SA1.A1_PESSOA = 'F' AND SA1.D_E_L_E_T_ = ' ' "
	cQryTit += "WHERE GCZ.GCZ_FILFAT = '" + xFilial("GCZ") + "' "
	cQryTit += "  AND GCZ.GCZ_STATUS IN (" + cStaGui + ") "
	cQryTit += "  AND GCZ.D_E_L_E_T_ = ' ' "
	cQryTit += "  AND GCZ.GCZ_DCPARF BETWEEN '" + dDatIni + "' AND '" + dDatFin + "' "
	cQryTit += "  AND GCZ.GCZ_VLGUIA > 0 "
	cQryTit += "GROUP BY (CASE GD4_REGTIT WHEN '' THEN GCZ_REGGER ELSE GD4_REGTIT END), GBH_CPF "
	cQryTit += "ORDER BY GBH_CPF"
EndIf

cQryTit := ChangeQuery(cQryTit)

TCQUERY cQryTit NEW ALIAS "TRBTIT"

DbSelectArea("TRBTIT")
TRBTIT->(DbGotop())

For nI := 1 To Len(aStru)
	If aStru[nI][2] <> "C" .and. FieldPos(aStru[nI][1]) > 0
		TcSetField("TRBTIT",aStru[nI][1],aStru[nI][2],aStru[nI][3],aStru[nI][4])
	EndIf
Next nI

cPSS := "PSS|"
FWrite(cArqDemd, cPSS + chr(13) + chr(10))

//Grava os dados na tabela temporaria
While TRBTIT->(!Eof())

	RecLock(cAlias, .T.)
		(cAlias)->REGTIT	:= TRBTIT->REGTIT
		DbSelectArea("GBH")
		DbSetOrder(1)
		DbSeek(xFilial("GBH") + TRBTIT->REGTIT)
		(cAlias)->CPF		:= GBH->GBH_CPF
		(cAlias)->NOME		:= AllTrim(GBH->GBH_NOME)
		(cAlias)->VALOR		:= AllTrim(Transform(TRBTIT->VLGUIA, "@E 999999999.99"))
	(cAlias)->(MsUnLock())

	TRBTIT->(DbSkip())
End

DbSelectArea(cAlias)
DbGoTop()

//Exporta para o arquivo texto os dados do arquivo temporario
While TMPDMED->(!Eof())
	IncProc("Gerando Titular do plano " + TMPDMED->NOME)
	cRPPSS := "RPPSS|"

	//Ponto de Entrada, para verificar se o usuario ira ser includo ou nao no arquivo da DMED
	If lHsdMTit
		aRet := ExecBlock("HSDMTIT", .F., .F., {TMPDMED->REGTIT, TMPDMED->NOME, TMPDMED->CPF})
		If aRet[1]
			cRPPSS += AllTrim(aRet[2]) + "|"	//CPF Responsavel
		Else
			TMPDMED->(DbSkip())
			Loop
		EndIf
	Else
		If Empty(TMPDMED->CPF)
			HS_MsgInf("ษ obrigat๓rio o preenchimento do CPF do responsแvel pelo pagamento.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
			If Select("TRBTIT") > 0
				DbSelectArea("TRBTIT")
				DbCloseArea()
			EndIf
			FClose(cArqDemd)
			Return
		Else
			cRPPSS += AllTrim(TMPDMED->CPF) + "|"	//CPF Responsavel
		EndIf
	EndIf

	If Empty(TMPDMED->NOME)
		HS_MsgInf("ษ obrigat๓rio o preenchimento do nome do responsแvel pelo pagamento.", "Aten็ใo", "Exporta็ใo Dmed Cancelada")
		If Select("TRBTIT") > 0
			DbSelectArea("TRBTIT")
			DbCloseArea()
		EndIf
		FClose(cArqDemd)
		Return
	Else
		cRPPSS += AllTrim(TMPDMED->NOME) + "|"	//Nome
	EndIf

	cRPPSS += StrTran(AllTrim(TMPDMED->VALOR),",","") + "|"	//Valor Pagto
	FWrite(cArqDemd, cRPPSS + chr(13) + chr(10))

	TMPDMED->(DbSkip())
End


If Select("TRBTIT") > 0
	DbSelectArea("TRBTIT")
	DbCloseArea()
EndIf

IncProc("Finalizando o arquivo.")
cFimDmed := "FIMDmed|"
FWrite(cArqDemd, cFimDmed)

FClose(cArqDemd)
//---------------------------------
//Exclui a tabela 
//---------------------------------
oTempTable:Delete()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ATUGRID  บAutor  ณMicrosiga           บ Data ณ  11/30/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Atualiza a grid de Consultas 		                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_ATUGRID(aColsCons,nRegistros,cAlias,aHeadCons,nItCols,cFiltro,cLstCpo,aCposIni,aJoin,oCons)
Local aArea 	:= GetArea()

aColsCons := {}

nRegistros := HS_BDados(cAlias, @aHeadCons, @aColsCons, @nItCols, 1,, cFiltro,,,cLstCpo,,,,,,.T.,,,,,, aCposIni, aJoin)
oCons:setArray(aColsCons)
oCons:oBrowse:Refresh()
RestArea(aArea)
Return
