#Include "Protheus.ch"
#Include "VEICA100.CH"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ VEICA100 ณ Autor ณ  Manoel Filho         ณ Data ณ 19/01/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Cadastro de Perguntas para Pesquisa 						  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEICA100()
Private aRotina := MenuDef()
Private cCadastro := (STR0001) //Perguntas para Pesquisa de Satisfacao
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
mBrowse( 6, 1,22,75,"VCJ")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณVCA100Pesqณ Autor ณ  Manoel Filho         ณ Data ณ 21/01/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Pesquisa com Cliente										  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VCA100PESQ(cTipPesq,cTipAge,cOrig,cTitulo,cAltVis,cCodCli,cLojCli)
Local cRAICUR   := ""
Local cRAICDP   := ""
Local cRAICTR   := ""
Local cRAICCli  := ""
Local cRAICLoj  := ""
Local cRAICOBS  := STR0053
Local aParamBox1:= {}
Local aRet1     := {}
Local aCodPes   := {}
Local cCodPes   := ""
Local cNomPes   := ""
Local cQuery    := ""
Local cQAlias   := "SQLAUX"
Local i         := 0

Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nOpca     := 0
Local lRet      := .f.
Local aAuxPesq  := {}
Local cMsg      := ""
Local lOrigem   := ( VAO->(FieldPos("VAO_ORIGEM")) > 0 )
Local aTipOri   := {"1="+STR0069,"2="+STR0070,"3="+STR0020,"4="+STR0071}
Local cTipOri   := "" // Tipo de Origem
Local cFilOri   := space(FWSizeFilial()) // Filial da Origem
Local cCodOri   := space(TamSX3("VAO_ORIGEM")[1]) // Codigo da Origem
Local cTipTem   := space(TamSX3("VAO_TIPTEM")[1]) // Tipo de Tempo 
Local cCodPro   := space(TamSX3("VAO_CODPRO")[1]) // Codigo do Produtivo
Local aParambox2:= {}
Local aRet2     := {}
Local dDatRec   := dDataBase
Private aNewBot := { {"IMPRESSAO",{|| FS_ImpriX() },STR0002} }    //"Impressao
Private cTitPes := ""
Private cTipPes := cTipPesq
Private cOrigem := cOrig
Private aPesquisa := {}
// 1o Elemento - Descricao da Pergunta
// 2o Elemento - Resposta
// 3o Elemento - Observacao
// 4o Elemento - Resposta que habilita Observacao - se o 5o elemento NAO FOR VAZIO e a
//						 resposta (elemento 2) estiver contida neste 4o elemento o campo Observacao
//						 sera habilitado
// 5o Elemento - Se VAZIO so' habilita a Observacao, senao habilita o Combo e a Observacao
// 6o Elemento - Codigo da Pergunta
// 7o Elemento - Data da Pesquisa
// 8o Elemento - Pergunta Pre-requisito
// 9o Elemento - Resposta da Pergunta Pre-requisito que habilita esta Pergunta
//10o Elemento - Recno do VCK
Default cTitulo := STR0003 //Pesquisa
Default cAltVis := "A" // A-Alterar / V-Visualizar
Default cCodCli := VC1->VC1_CODCLI
Default cLojCli := VC1->VC1_LOJA

DEFINE FONT oTitTela NAME "Arial" SIZE 10,13 BOLD

cTitPes := cTitulo // Titulo da Pesquisa

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox

aPos := MsObjSize( aInfo, aObjects )

If VCJ->(FieldPos("VCJ_NOMPES")) > 0
	cCodPes := "XXXXXXXXXXXX"
	cQuery := "SELECT DISTINCT VCJ.VCJ_CODPES , VCJ.VCJ_NOMPES FROM "+RetSQLName("VCJ")+" VCJ WHERE VCJ.VCJ_FILIAL='"+xFilial("VCJ")+"' AND VCJ.VCJ_TIPPES='"+cTipPes+"' AND VCJ.VCJ_TIPAGE='"+cTipAge+"' AND VCJ.VCJ_ATIVO='1' AND VCJ.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	Do While !( cQAlias )->( Eof() )
		aAdd(aCodPes,( cQAlias )->( VCJ_CODPES )+" - "+( cQAlias )->( VCJ_NOMPES ))
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
	If len(aCodPes) > 1
		aAdd(aParamBox1,{3,STR0050,1,aCodPes,160,"",.F.}) // Codigo da Pesquisa
		If ParamBox(aParamBox1,STR0050,@aRet1,,,,,,,,.f.) // Codigo da Pesquisa
			cCodPes := left(aCodPes[aRet1[1]],6)
			cNomPes := aCodPes[aRet1[1]]
		EndIf
	ElseIf len(aCodPes) == 1
		cCodPes := left(aCodPes[1],6)
		cNomPes := aCodPes[1]
	EndIf
EndIf
cQuery := "SELECT VCJ.* FROM "+RetSQLName("VCJ")+" VCJ WHERE VCJ.VCJ_FILIAL='"+xFilial("VCJ")+"' AND VCJ.VCJ_TIPPES='"+cTipPes+"' AND VCJ.VCJ_TIPAGE='"+cTipAge+"' AND "
If !Empty(cCodPes) // Traz CODPESQ selecionada no Parambox
	cQuery += "VCJ.VCJ_CODPES='"+cCodPes+"' AND "
EndIf
cQuery += "VCJ.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
Do While !( cQAlias )->( Eof() )
	/////// RAIC ///////
	cRAICUR := ( cQAlias )->( VCJ_RAICUR ) // Usuario Responsavel pelo RAIC
	cRAICDP := ( cQAlias )->( VCJ_RAICDP ) // Departamento Responsavel pelo RAIC
	cRAICTR := ( cQAlias )->( VCJ_RAICTR ) // Tipo de Reclamacao do RAIC
	////////////////////
	DbSelectArea("VCK")
	DbSetOrder(1)
	If DbSeek(xFilial("VCK")+cOrigem+( cQAlias )->( VCJ_CODPER ))
		cOpcoes := FORMATIN(Alltrim(( cQAlias )->( VCJ_OPCOES )),';')
		cOpcoes := "{"+Subs(cOpcoes,2,Len(cOpcoes)-2)+"}"
		nPos  := at(VCK->VCK_RESPOS+"=",cOpcoes)
		nPos1 := at("','",Subs(cOpcoes,nPos))
		If nPos1 == 0
			cResp := Subs(cOpcoes,nPos,len(cOpcoes)-(nPos+1))
		Else
			cResp := Subs(cOpcoes,nPos,nPos1-1)
		Endif
		If cResp == "{''"
			cResp := ""
		Endif
		aadd(aPesquisa,{( cQAlias )->( VCJ_PERGUN ),cResp,VCK->VCK_OBSERV+VCK->VCK_OBSER2,( cQAlias )->( VCJ_HABOBS ),cOpcoes,( cQAlias )->( VCJ_CODPER ),VCK->VCK_DATPES,( cQAlias )->( VCJ_PREREQ ),( cQAlias )->( VCJ_RESPRE ),VCK->(Recno()),( cQAlias )->( VCJ_SEQUEN) })
	Else
		If Empty(( cQAlias )->( VCJ_OPCOES ))
			If ( cQAlias )->( VCJ_ATIVO ) == "1"
				aadd(aPesquisa,{( cQAlias )->( VCJ_PERGUN )," ",Space(250),"","",( cQAlias )->( VCJ_CODPER ),dDatabase,( cQAlias )->( VCJ_PREREQ ),( cQAlias )->( VCJ_RESPRE ),0,( cQAlias )->( VCJ_SEQUEN) })
			EndIf
		Else
			cOpcoes := FORMATIN(Alltrim(( cQAlias )->( VCJ_OPCOES )),';')
			cOpcoes := "{"+Subs(cOpcoes,2,Len(cOpcoes)-2)+"}"
			If ( cQAlias )->( VCJ_ATIVO ) == "1"
				aadd(aPesquisa,{( cQAlias )->( VCJ_PERGUN )," ",Space(250),( cQAlias )->( VCJ_HABOBS ),cOpcoes,( cQAlias )->( VCJ_CODPER ),dDatabase,( cQAlias )->( VCJ_PREREQ ),( cQAlias )->( VCJ_RESPRE ),0,( cQAlias )->( VCJ_SEQUEN) })
			EndIf
		EndIf
	EndIf
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
DbselectArea("VCJ")
/////////////////////////////////////////////////////////////
// Ponto de Entrada que possibilita manipular as Perguntas //
/////////////////////////////////////////////////////////////
If ExistBlock("VCA100PS")
	aAuxPesq := ExecBlock("VCA100PS",.f.,.f.,{ aClone(aPesquisa) , cCodCli , cLojCli })
	If ValType(aAuxPesq) == "A"
		aPesquisa := aClone(aAuxPesq)
	EndIf
EndIf
//
If Len(aPesquisa) == 0
	MsgStop(STR0004,STR0047)  // Nao existem Pesquisas cadastradas para este Tipo de Agenda! / Atencao
	Return()
EndIf
///////////////////////////////////////////////////
// Mensagem no momento da Pesquisa de Satisfacao //
///////////////////////////////////////////////////
If !Empty(cCodCli+cLojCli) .and. VCF->(FieldPos("VCF_MSGSAT")) > 0
	cMsg := FM_SQL("SELECT VCF_MSGSAT FROM "+RetSQLName("VCF")+" WHERE VCF_FILIAL='"+xFilial("VCF")+"' AND VCF_CODCLI='"+cCodCli+"' AND VCF_LOJCLI='"+cLojCli+"' AND D_E_L_E_T_=' '")
	If !Empty(cMsg)
		MsgInfo(cMsg)
	EndIf
EndIf
//
aSort(aPesquisa,1,,{|x,y| x[11] < y[11] })
//
DbselectArea("VCJ")
DEFINE MSDIALOG oPesquisa FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (cTitPes+" - "+cNomPes) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
oPesquisa:lEscClose := .F.

@ aPos[1,1],aPos[1,2] LISTBOX oLbPesq FIELDS HEADER (STR0005),;//Pergunta"
(STR0006),;//Resposta"
(STR0007) COLSIZES 260,70,170 SIZE aPos[1,4],aPos[1,3]-aPos[1,1] OF oPesquisa PIXEL ON DBLCLICK ( FS_MNTTEL(cAltVis) )//Observacao"

oLbPesq:SetArray(aPesquisa)
oLbPesq:bLine := { || { aPesquisa[oLbPesq:nAt,11]+") "+aPesquisa[oLbPesq:nAt,1],;
aPesquisa[oLbPesq:nAt,2],;
aPesquisa[oLbPesq:nAt,3] }}

ACTIVATE MSDIALOG oPesquisa CENTER On INIT EnchoiceBar(oPesquisa,{|| nOpca := 1, oPesquisa:End() },{|| oPesquisa:End() },,aNewBot)

If nOpca == 1 .and. cAltVis == "A" // Alterar
	lRet := .t.
	cRAICOBS += cCodPes+"-"+cNomPes+CHR(13)+CHR(10)+Repl("_",TamSx3("VAO_RECLAM")[1])+CHR(13)+CHR(10)
	DbSelectArea("VCK")
	nTot := Len(aPesquisa)
	For i := 1 to nTot
		If !Empty(aPesquisa[i,2]+aPesquisa[i,3])
			If aPesquisa[i,10] > 0
				VCK->(DbGoto(aPesquisa[i,10]))
				RecLock("VCK",.f.)
			Else
				RecLock("VCK",.t.)
			Endif
			VCK_FILIAL := xFilial("VCK")
			VCK_ORIGEM := cOrigem
			VCK_CODPER := aPesquisa[i,6]
			VCK_RESPOS := aPesquisa[i,2]
			VCK_OBSERV := Left(aPesquisa[i,3],250)
			VCK_OBSER2 := Right(aPesquisa[i,3],250)
			VCK_DATPES := dDataBase
			MsUnlock()
			cRAICOBS += strzero(i,3)+") "+aPesquisa[i,1]+CHR(13)+CHR(10)
			cRAICOBS += Alltrim(aPesquisa[i,2])+" - "+Alltrim(aPesquisa[i,3])+CHR(13)+CHR(10)
			cRAICOBS += Repl("_",TamSx3("VAO_RECLAM")[1])+CHR(13)+CHR(10)
		Endif
	Next
	If !Empty(cRAICUR)
		//
		cTipOri := right(cTipPes,1)
		cFilOri := ""
		cCodOri := cOrigem
		If cTipPes == "001" // Venda de Veiculos
			VV9->(DbSetOrder(1))
			VV9->(DbSeek(xFilial("VV9")+cOrigem))
			cFilOri  := VV9->VV9_FILIAL
			cRAICCli := VV9->VV9_CODCLI
			cRAICLoj := VV9->VV9_LOJA
		ElseIf cTipPes == "002" // Oficina
			VO1->(DbSetOrder(1))
			VO1->(DbSeek(xFilial("VO1")+cOrigem))
			cFilOri  := VO1->VO1_FILIAL
			cRAICCli := VO1->VO1_PROVEI
			cRAICLoj := VO1->VO1_LOJPRO
			If lOrigem
				//////////////////////////////
	            // Levantar o Tipo de Tempo //
				//////////////////////////////
				cQuery := "SELECT DISTINCT VO4_TIPTEM FROM "+RetSQLName("VO4")+" WHERE VO4_FILIAL='"+xFilial("VO4")+"' AND VO4_NUMOSV='"+VO1->VO1_NUMOSV+"' AND D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
				Do While !( cQAlias )->( Eof() )
					If Empty(cTipTem)
						cTipTem := ( cQAlias )->( VO4_TIPTEM ) // Tipo de Tempo 
					Else
						cTipTem := space(TamSX3("VAO_TIPTEM")[1]) // Tipo de Tempo 
						exit
					EndIf
					( cQAlias )->( DbSkip() )
				EndDo
				( cQAlias )->( dbCloseArea() )
				If !Empty(cTipTem)
					//////////////////////////
	    	        // Levantar o Produtivo //
					//////////////////////////
					cQuery := "SELECT DISTINCT VO4_CODPRO FROM "+RetSQLName("VO4")+" WHERE VO4_FILIAL='"+xFilial("VO4")+"' AND VO4_NUMOSV='"+VO1->VO1_NUMOSV+"' AND VO4_CODPRO<>' ' AND D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
					Do While !( cQAlias )->( Eof() )
						If Empty(cCodPro)
							cCodPro := ( cQAlias )->( VO4_CODPRO ) // Codigo do Produtivo
						Else
							cCodPro := space(TamSX3("VAO_CODPRO")[1]) // Codigo do Produtivo
							exit
						EndIf
						( cQAlias )->( DbSkip() )
					EndDo
					( cQAlias )->( dbCloseArea() )
				EndIf
			EndIf
			//
		ElseIf cTipPes == "003" // Balcao de Pecas
			VS1->(DbSetOrder(1))
			VS1->(DbSeek(xFilial("VS1")+cOrigem))
			cFilOri  := VS1->VS1_FILIAL
			cRAICCli := VS1->VS1_CLIFAT
			cRAICLoj := VS1->VS1_LOJA
		ElseIf cTipPes == "004" // CEV
			VC1->(DbSetOrder(1))
			VC1->(DbGoTo( val(cOrigem) ))
			cFilOri  := VC1->VC1_FILIAL
			cRAICCli := VC1->VC1_CODCLI
			cRAICLoj := VC1->VC1_LOJA
		EndIf
		//
		DbSelectArea("VAO")
		//
		aAdd(aParamBox2,{1,STR0062,dDATREC,"@D","MV_Par01 >= dDataBase","","",60,.t.}) 	// Data da Registro
		aAdd(aParamBox2,{1,STR0063,cRAICUR,"@!","UsrExist(MV_Par02)","USR","",50,.t.}) 	// Usuแrio Responsแvel
		aAdd(aParamBox2,{1,STR0064,cRAICDP,"@!","FG_Seek('VAP','MV_Par03',1,.f.)","VAP","",0,.t.})// Departamento
		aAdd(aParamBox2,{1,STR0065,cRAICTR,"@!","!Empty(MV_PAR04)","VAQ","",0,.t.}) 		// Tipo de Registro
		If lOrigem
			AADD(aParamBox2,{2,STR0066,cTipOri,aTipOri,90,"",.f.})    // Tipo de Origem
			aAdd(aParamBox2,{1,STR0067,cFilOri,"@!","","","",70,.f.}) 	// Filial Origem
			aAdd(aParamBox2,{1,STR0068,cCodOri,"@!","","","",70,.f.}) 	// Codigo Origem
		EndIf
		//
		If ParamBox(aParamBox2,STR0061,@aRet2,,,,,,,,.f.)// Satisfa็ใo/Insatisfa็ใo
			dDATREC := aRet2[1]
			cRAICUR := aRet2[2]
			cRAICDP := aRet2[3]
			cRAICTR := aRet2[4]
			If lOrigem
				cTipOri := aRet2[5]
				cFilOri := aRet2[6]
				cCodOri := aRet2[7]
			EndIf
			//
			DbSelectArea("VAO")
			RecLock("VAO",.t.)
				VAO->VAO_FILIAL := xFilial("VAO")
				VAO->VAO_SEQUEN := GetSXENum("VAO","VAO_SEQUEN") // Sequencia
				VAO->VAO_CODCLI := cRAICCli    // Codigo do Cliente
				VAO->VAO_LOJCLI := cRAICLoj    // Loja do Cliente
				VAO->VAO_DATREC := dDataBase   // Data reclamacao 
				If VAO->(FieldPos("VAO_HORREC")) > 0
					VAO->VAO_HORREC := val(substr(time(),1,2)+substr(time(),4,2))   // Hora
				Endif	
				VAO->VAO_USUREC := __CUSERID   // Usuario que criou a reclamacao
				VAO->VAO_USURES := cRAICUR     // Usuario responsavel
				VAO->VAO_DEPART := cRAICDP     // Departamento
				VAO->VAO_TIPREC := cRAICTR     // Tipo de reclamacao
				VAO->VAO_SITUAC := "0"         // Reclamacao aberta
				If lOrigem
					VAO->VAO_TIPORI := cTipOri // Tipo de Origem
					VAO->VAO_FILORI := cFilOri // Filial da Origem
					VAO->VAO_ORIGEM := cCodOri // Codigo da Origem
					VAO->VAO_TIPTEM := cTipTem // Tipo de Tempo 
					VAO->VAO_CODPRO := cCodPro // Codigo do Produtivo
				EndIf
			MsUnlock()
			ConfirmSX8()
			M->VAO_RECLAM := cRAICOBS
			MSMM(VAO->VAO_RECLAO,TamSx3("VAO_RECLAM")[1],,&("VAO_RECLAM"),1,,,"VAO","VAO_RECLAO")
			
			//Ponto de entrada ap๓s gravar VAO depois que fez a Pesquisa de Satisfa็ใo. 
			if ExistBlock("VCA100VAO")
				ExecBlock("VCA100VAO",.f.,.f.)
			Endif
			
		EndIf
	EndIf
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณ FS_MNTTEL บAutor  ณ Manoel             บ Data ณ  11/11/10   บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricaoณ Preenchimento das respostas                                 บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MNTTEL(cAltVis)

Local nOpca := 0
Local aPerg := {}
Local cResp := ""
Local cObs  := ""
Local lAlt  := ( cAltVis == "A" ) // A-Altera / V-Visualiza
lWhen := .t.
While .t.

	nOpca := 0

	If oLbPesq:nAt > 1
		If !Empty(aPesquisa[oLbPesq:nAt,8])
			nPos := aScan(aPesquisa,{|x| x[6] == aPesquisa[oLbPesq:nAt,8] } )
			If nPos > 0
				If !Left(aPesquisa[nPos,2],1) $ aPesquisa[oLbPesq:nAt,9]
					oLbPesq:nAt++
					oLbPesq:Refresh()
					Loop
				Endif
			Endif
		Endif
		aPerg := &(aPesquisa[oLbPesq:nAt,5])
		cResp := Left(aPesquisa[oLbPesq:nAt,2],1)
		cObs  := aPesquisa[oLbPesq:nAt,3]
	Else
		aPerg := &(aPesquisa[oLbPesq:nAt,5])
		cResp := Left(aPesquisa[oLbPesq:nAt,2],1)
		cObs  := aPesquisa[oLbPesq:nAt,3]
	Endif

	DEFINE MSDIALOG oDlgPerg TITLE (cTitPes+" - "+STR0005+" "+StrZero(oLbPesq:nAt,3)+"/"+StrZero(Len(aPesquisa),3)) FROM  02,04 TO 17,90 OF oMainWnd //Pergunta

	@  08,007 SAY (Alltrim(aPesquisa[oLbPesq:nAt,1])) SIZE 330,20  OF oDlgPerg PIXEL COLOR CLR_BLUE
	@  05,005 TO 35,335 LABEL ("") OF oDlgPerg PIXEL
	@  16,008 MSCOMBOBOX oParPrg VAR cResp SIZE 325,50 COLOR CLR_BLACK ITEMS aPerg OF oDlgPerg PIXEL VALID Fs_When(cResp,@cObs) WHEN lAlt
	@  39,005 SAY oTextObs VAR (STR0007)  OF oDlgPerg PIXEL COLOR CLR_BLUE //Observacao
	@  199,005 BUTTON oWhen PROMPT ("") OF oDlgPerg SIZE 01,01 PIXEL   // Apenas para tratar WHEN do cObs
	@  46,005 GET oObs VAR cObs MULTILINE SIZE 330,48 OF oDlgPerg PIXEL COLOR CLR_BLACK when ( lWhen .and. lAlt ) valid If(Len(Alltrim(cObs))>500,(MsgInfo(STR0008),.f.),.t.) //Maximo de 250 caracteres!
	Fs_When(cResp,@cObs)

	DEFINE SBUTTON FROM 099,265 TYPE 1 ACTION (nOpca:=1,oDlgPerg:End()) ENABLE OF oDlgPerg PIXEL 
	DEFINE SBUTTON FROM 099,300 TYPE 2 ACTION (oDlgPerg:End()) ENABLE OF oDlgPerg PIXEL 
	
	ACTIVATE MSDIALOG oDlgPerg CENTER

	If nOpca == 1
		If lAlt
			nPos  := at(cResp+"=",aPesquisa[oLbPesq:nAt,5])
			nPos1 := at("','",Subs(aPesquisa[oLbPesq:nAt,5],nPos))
			If nPos1 == 0
				aPesquisa[oLbPesq:nAt,2] := Subs(aPesquisa[oLbPesq:nAt,5],nPos,len(aPesquisa[oLbPesq:nAt,5])-(nPos+1))
			Else
				aPesquisa[oLbPesq:nAt,2] := Subs(aPesquisa[oLbPesq:nAt,5],nPos,nPos1-1)
			Endif
			If aPesquisa[oLbPesq:nAt,2] == "{''"
				aPesquisa[oLbPesq:nAt,2] := ""
			Endif
			aPesquisa[oLbPesq:nAt,3] := Alltrim(cObs)
		EndIf
		If oLbPesq:nAt < Len(aPesquisa)
			oLbPesq:nAt++
			oLbPesq:SetArray(aPesquisa)
			oLbPesq:bLine := { || { aPesquisa[oLbPesq:nAt,1],;
			aPesquisa[oLbPesq:nAt,2],;
			aPesquisa[oLbPesq:nAt,3] }}
			oLbPesq:Refresh()
		Else
			Exit
		Endif
	Else
		Exit
	Endif
Enddo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFS_ImpriX ณ Autor ณ  Manoel Filho         ณ Data ณ 19/01/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Impressao de Perguntas para Pesquisa 	  				  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ImpriX()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lA1_IBGE:= (SA1->(FieldPos("A1_IBGE"))#0)
Local cDesc1  := STR0051 // Este programa tem como objetivo imprimir relat๓rio
Local cDesc2  := STR0052 // de acordo com os parametros informados pelo usuario.
Local cDesc3  := STR0053 // Pesquisa Satisfacao

Local titulo  := cTitPes
Local cCabec1 := ""
Local cCabec2 := ""
Local aOrd    := {}
Local nLin    := 80
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := STR0016
Private nTipo       := 15
Private aReturn     := { STR0014, 1,STR0015, 1, 2, 1, "",1 }//Zebrado ## Administracao
Private nLastKey    := 0
Private cPerg       := "XX"
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := ""
Private cString     := "VCK"

If !MsgYesNo(STR0009)//Tem certeza que deseja Imprimir a Pesquisa?
	Return
Endif
If Len(aPesquisa) == 0
	MsgStop(STR0017) //Nao existem dados a serem impressos!
	Return
Endif

If cTipPes == "001" // Venda de Veiculos
	DbSelectArea("VV9")
	DbSetOrder(1)
	DbSeek(xFilial("VV9")+cOrigem)
	DbSelectArea("VV0")
	DbSetOrder(1)
	DbSeek(xFilial("VV0")+cOrigem)
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + VV9->VV9_CODCLI + VV9->VV9_LOJA )
	If lA1_IBGE
		DbSelectArea("VAM")
		DbSetOrder(1)
		DbSeek( xFilial("VAM") + SA1->A1_IBGE )
	EndIf
	cFone   := If(lA1_IBGE,"("+VAM->VAM_DDD+") ","")+Alltrim(SA1->A1_TEL)
	cCidade := Alltrim(left(If(lA1_IBGE,VAM->VAM_DESCID,SA1->A1_MUN),17))+"-"+If(lA1_IBGE,VAM->VAM_ESTADO,SA1->A1_EST)
	cCabec1 := STR0010+" "+VV9->VV9_NUMATE+"    "+STR0011+" "+Dtoc(VV0->VV0_DATMOV) + "    " + STR0018+" " + Dtoc(aPesquisa[1,7])//Numero do Atendimento ### Data  ### Data da Pesquisa
	cCabec2 := STR0012+" "+SA1->A1_COD+"-"+SA1->A1_LOJA+" - "+left(SA1->A1_NOME,25)+" - "+STR0013+" " + cFone + "  -  " + cCidade ////Cliente ## Fone
ElseIf cTipPes == "002" // Oficina
	DbSelectArea("VO1")
	DbSetOrder(1)
	DbSeek(xFilial("VO1")+cOrigem)
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + VO1->VO1_PROVEI + VO1->VO1_LOJPRO )
	If lA1_IBGE
		DbSelectArea("VAM")
		DbSetOrder(1)
		DbSeek( xFilial("VAM") + SA1->A1_IBGE )
	EndIf
	cFone   := If(lA1_IBGE,"("+VAM->VAM_DDD+") ","")+Alltrim(SA1->A1_TEL)
	cCidade := Alltrim(left(If(lA1_IBGE,VAM->VAM_DESCID,SA1->A1_MUN),17))+"-"+If(lA1_IBGE,VAM->VAM_ESTADO,SA1->A1_EST)
	cCabec1 := STR0019+":"+" "+VO1->VO1_NUMOSV+"    "+STR0011+" "+Dtoc(VO1->VO1_DATABE) + "    " + STR0018+" " + Dtoc(aPesquisa[1,7])//OS ### Data ## Ordem de Servi็o ### Data da Pesquisa
	cCabec2 := STR0012+" "+SA1->A1_COD+"-"+SA1->A1_LOJA+" - "+left(SA1->A1_NOME,25)+" - "+STR0013+" " + cFone + "  -  " + cCidade ////Cliente ## Fone
ElseIf cTipPes == "003" // Balcao de Pecas
	DbSelectArea("VS1")
	DbSetOrder(1)
	DbSeek(xFilial("VS1")+cOrigem)
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + VS1->VS1_CLIFAT + VS1->VS1_LOJA )
	If lA1_IBGE
		DbSelectArea("VAM")
		DbSetOrder(1)
		DbSeek( xFilial("VAM") + SA1->A1_IBGE )
	EndIf
	cFone   := If(lA1_IBGE,"("+VAM->VAM_DDD+") ","")+Alltrim(SA1->A1_TEL)
	cCidade := Alltrim(left(If(lA1_IBGE,VAM->VAM_DESCID,SA1->A1_MUN),17))+"-"+If(lA1_IBGE,VAM->VAM_ESTADO,SA1->A1_EST)
	cCabec1 := STR0020+":"+" "+VS1->VS1_NUMORC+"    "+STR0011+" "+Dtoc(VS1->VS1_DATORC) + Space(56) + STR0018+" " + Dtoc(aPesquisa[1,7])//OS ### Data ### Orcamento ### Data da Pesquisa
	cCabec2 := STR0012+" "+SA1->A1_COD+"-"+SA1->A1_LOJA+" - "+left(SA1->A1_NOME,25)+" - "+STR0013+" " + cFone + "  -  " + cCidade ////Cliente ## Fone
ElseIf cTipPes == "004" // CEV
	DbSelectArea("VC1")
	DbSetOrder(1)
	DbGoTo( val(cOrigem) )
	If !Empty(VC1->VC1_CODCLI+VC1->VC1_LOJA)
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + VC1->VC1_CODCLI + VC1->VC1_LOJA )
		If lA1_IBGE
			DbSelectArea("VAM")
			DbSetOrder(1)
			DbSeek( xFilial("VAM") + SA1->A1_IBGE )
		EndIf
		cFone   := If(lA1_IBGE,"("+VAM->VAM_DDD+") ","")+Alltrim(SA1->A1_TEL)
		cCidade := Alltrim(left(If(lA1_IBGE,VAM->VAM_DESCID,SA1->A1_MUN),17))+"-"+If(lA1_IBGE,VAM->VAM_ESTADO,SA1->A1_EST)
		cCabec1 := STR0021+" "+Dtoc(VC1->VC1_DATAGE) + "    " + STR0022+" "+Dtoc(VC1->VC1_DATVIS) + "    " + STR0018+" " + Dtoc(aPesquisa[1,7])//Data Agenda ## Data Abordagem ## Data da Pesquisa
		cCabec2 := STR0012+" "+SA1->A1_COD+"-"+SA1->A1_LOJA+" - "+left(SA1->A1_NOME,25)+" - "+STR0013+" " + cFone + "  -  " + cCidade ////Cliente ## Fone
	ElseIf !Empty(VC1->VC1_CDPROS+VC1->VC1_LJPROS)
		DbSelectArea("SUS")
		DbSetOrder(1)
		DbSeek( xFilial("SUS") + VC1->VC1_CDPROS + VC1->VC1_LJPROS )
		cFone   := Alltrim(SUS->US_TEL)
		cCidade := Alltrim(left(SUS->US_MUN,17))+"-"+SUS->US_EST
		cCabec1 := STR0021+" "+Dtoc(VC1->VC1_DATAGE) + "    " + STR0022+" "+Dtoc(VC1->VC1_DATVIS) + "    " + STR0018+" " + Dtoc(aPesquisa[1,7])//Data Agenda ## Data Abordagem ## Data da Pesquisa
		cCabec2 := STR0012+" "+SUS->US_COD+"-"+SUS->US_LOJA+" - "+left(SUS->US_NOME,25)+" - "+STR0013+" " + cFone + "  -  " + cCidade ////Cliente ## Fone
	EndIf
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

pergunte(cPerg,.F.)

SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif
nTipo := If(aReturn[4]==1,15,18)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|| RunReport(cCabec1,cCabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  17/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(cCabec1,cCabec2,Titulo,nLin)

Local nI_ := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SetRegua(RecCount())

For nI_ := 1 to Len(aPesquisa)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica o cancelamento pelo usuario...                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Impressao do cabecalho do relatorio. . .                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	@ nLin++,00 PSAY StrZero(nI_,3)+") "+aPesquisa[nI_,1]
	If !Empty(aPesquisa[nI_,2])
		@ nLin++,00 PSAY Subs(aPesquisa[nI_,2],3)
	eNDIF
	If !Empty(aPesquisa[nI_,3])
		@ nLin++,00 PSAY aPesquisa[nI_,3]
	Endif

	nLin++

Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณ  Fs_When  บAutor  ณ Manoel             บ Data ณ  11/11/10   บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricaoณ Validacao (se existe Observacao ) -> WHEN da Observacao     บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fs_When(cResp,cObs)

// 1o Elemento - Descricao da Pergunta
// 2o Elemento - Resposta
// 3o Elemento - Observacao
// 4o Elemento - Resposta que habilita Observacao - se o 5o elemento NAO FOR VAZIO e a
//						 resposta (elemento 2) estiver contida neste 4o elemento o campo Observacao
//						 sera habilitado
// 5o Elemento - Se VAZIO so' habilita a Observacao, senao habilita o Combo e a Observacao
// 6o Elemento - Codigo da Pergunta

oTextObs:lVisible := .f.
oObs:lVisible 		:= .f.
If Empty(aPesquisa[oLbPesq:nAt,5]) .or. aPesquisa[oLbPesq:nAt,5] == "{''}"
	oObs:lVisible 		:= .t.
Else
	if	Left(cResp,1) $ aPesquisa[oLbPesq:nAt,4]
		oTextObs:lVisible := .t.
		oObs:lVisible 		:= .t.
	Else
		cObs := Space(500)
	Endif
Endif

oTextObs:Refresh()
oObs:Refresh()
oObs:SetFocus()

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณVCA100IMP บ Autor ณ Rafael Goncalves   บ Data ณ  19/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao imprime a pergunt selecionada                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function VCA100IMP()
Local oPrint
Local i 	:= 1
Local lin 	:= 0

Private aImpCpo := {}
Private oFont16, oFont08, oFont10,oFont07, oFont12 , oFont06,oFont11

oFont16	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
oFont06	:= TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
oFont08	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
oFont07	:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
oFont10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont11	:= TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
oFont12	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Pergunte para Configuracao da Rotina ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
// AADD(aRegs,{STR0023  , "", "", "mv_ch1", "C", 99, 0, 0, "G", "", "mv_par01", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" ,{STR0024},{},{}})//Titulo# Informe o titulo do Relatorio.
// AADD(aRegs,{STR0025  , "", "", "mv_ch2", "C", 99, 0, 0, "G", "", "mv_par02", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" ,{STR0026},{},{}})//Enunciado 1 # Informe o Enunciado do Relatorio.
// AADD(aRegs,{STR0027  , "", "", "mv_ch3", "C", 99, 0, 0, "G", "", "mv_par03", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" ,{STR0028},{},{}})//Enunciado 2 # Informe a Continua็ใo do Enunciado
// AADD(aRegs,{STR0029  , "", "", "mv_ch4", "C", 99, 0, 0, "G", "", "mv_par04", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" ,{STR0028},{},{}})//Enunciado 3 # Informe a Continua็ใo do Enunciado
// AADD(aRegs,{STR0030  , "", "", "mv_ch5", "C", 99, 0, 0, "G", "", "mv_par05", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" ,{STR0028},{},{}})//Enunciado 4 # Informe a Continua็ใo do Enunciado
// AADD(aRegs,{STR0033  , "", "", "mv_ch6", "C", 03, 0, 0, "G", 'ExistCpo("SX5","PS"+mv_par06)', "mv_par06", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "PS" , "" , "" , "" ,{STR0034},{},{}})//Tipo Pesquisa # /Informe o tipo de pesquisa.
// AADD(aRegs,{STR0046  , "", "", "mv_ch7", "C", 06, 0, 0, "G", 'NaoVazio()', "mv_par07", "", "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" ,{STR0034},{},{}})//Tipo Impressao#Grafica#Caracter#Informe o tipo de Impressao.0","Grafica para Laser","Caracter para Matricial
// AADD(aRegs,{STR0035  , "", "", "mv_ch8", "N", 01, 0, 2, "C", '', "mv_par08", STR0036, STR0036 , STR0036 , "" , "" , STR0037 , STR0037 , STR0037 , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" ,{STR0038,STR0039,STR0032},{},{}})//Tipo Impressao#Grafica#Caracter#Informe o tipo de Impressao.0","Grafica para Laser","Caracter para Matricial

Pergunte("VCA100")

oPrint	:= TMSPrinter():New( (STR0031) ) //Cadastro de Pesquisa de Satisfa็ใo
oPrint:Setup()

MontaRel(oPrint,@i,@lin)


return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMONTAREL  บAutor  ณRicardo Farinelli   บ Data ณ  11/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao principal para confeccao do relatorio                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaRel(oPrint,i,lin)

Cabecalho(oPrint,@i)  			// Funcao que monta o cabecalho
lin := Detail(oPrint,@i)  		// Funcao que monta o cabecalho

If Mv_par08 <=1 				//impresaso grafica
	lRodape := lin > 3100 		// Espaco minimo para colocacao do rodape
Else 							//impressao caractere
	lRodape := lin > 2800 		// Espaco minimo para colocacao do rodape
EndIF

If lRodape
	i++
	oPrint:EndPage() 		// Finaliza a pagina
	oPrint:Say(040,2200,STRZERO(i,2),oFont10)
	lin := 140
Endif
rodape(oPrint,@i,@lin) // imprime o rodape da avaliacao

oPrint:Preview()  				// Visualiza antes de imprimir

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ Cabecalhoณ Autor ณ Ricardo Farinelli     ณ Data ณ 31/10/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณCabecalho do relatorio                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Cabecalho(ExpO1,ExpN1)                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpO1 = Objeto oPrint                                      ณฑฑ
ฑฑณ          ณ ExpN1 = Contador de paginas                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Cabecalho(oPrint,i)
Local nLin := 250
Local aSM0     := {}

oPrint:StartPage() 		// Inicia uma nova pagina

oPrint:Box( 010, 010, 430, 2300 )

aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)

oPrint:Say(040,025,Alltrim(aSM0[7]),oFont10)
oPrint:Say(040,2200,STRZERO(i,2),oFont10)
oPrint:Say( 140,080,MV_PAR01,oFont16 )

oPrint:Say(nlin,040,Mv_Par02+" "+Mv_Par03,oFont11)
oPrint:Say(nlin+40,040,Mv_Par04+" "+Mv_Par05,oFont11)

DbSelectArea("SX5")
DbSetOrder(1)
DbSeek( xFilial("SX5") + "PS" + Mv_Par06 )
oPrint:Say(nlin+135,040,STR0040+Mv_Par06+"-"+SX5->X5_DESCRI,oFont11) //Tipo de Pesquisa:

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ Detail   ณ Autor ณ Ricardo Farinelli     ณ Data ณ 31/10/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณItens do relatorio                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Detail(ExpO1,ExpN1)                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpO1 = Objeto oPrint                                      ณฑฑ
ฑฑณ          ณ ExpN1 = Contador de paginas                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Detail(oPrint,i)
Local lin  := 460
Local nNumPer := 0
Local cRespst := ""
Local nPos := 0
Local lExit := .f.
If i>1 //pular linhas para cabecalho
	lin  := 140
EndIF

DbSelectArea("VCJ")
DbSetORder(1)
if DbSeek(xFilial("VCJ")+MV_PAR06)
	while !eof() .and. VCJ->VCJ_FILIAL+VCJ->VCJ_TIPPES == xFilial("VCJ")+MV_PAR06

		if mv_par07 != VCJ->VCJ_CODPES
			DBSkip()
			loop
		endif
		If lin > 2700				// Espaco minimo para salto pagina
			i++
			//oPrint:Line(lin,0030,lin,2300)
			oPrint:EndPage() 		// Finaliza a pagina
			oPrint:Say(040,2200,STRZERO(i,2),oFont10)
			lin := 140
		Endif

		nNumPer ++
		oPrint:Say(lin+=80,0040,strzero(nNumPer,3)+" ) "+VCJ->VCJ_PERGUN,oFont10)

		cRespst := VCJ->VCJ_OPCOES
		lExit := .f.
		If !Empty(cRespst)
			while !lExit
				nPos := at(";",cRespst)
				oPrint:Box( lin+50, 150, lin+90, 190 )
				If nPos <= 0
					nPos := Len(cRespst)+1
					lExit := .t.
				Endif

				oPrint:Say(lin+=50,0200,Substr(cRespst,1,nPos-1),oFont10)
				If Substr(cRespst,1,1) $ VCJ->VCJ_HABOBS//se tiver descricao
					oPrint:Line(lin+35,200,lin+35,2300)
				EndIF
				cRespst := Substr(cRespst,nPos+1)

			Enddo
		Else
			oPrint:Line(lin+=60,0150,lin+=60,2300)
		Endif

		//oPrint:Line(lin+=40,0030,lin+=40,2300)
		DbSelectArea("VCJ")
		DbSkip()
	Enddo

EndIF

Return lin

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณrodape    บAutor  ณRicardo Farinelli   บ Data ณ  10/31/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime o Resumo da Avaliacao                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function rodape(oPrint,i,lin)
If Mv_par08 <=1 				//impresaso grafica
	lin := 3100 		// Espaco minimo para colocacao do rodape
Else 							//impressao caractere
	lin := 2800 		// Espaco minimo para colocacao do rodape
EndIF

oPrint:Box(lin,020,lin+210,2300)

lin+=20

oPrint:Say(lin,030,STR0041,oFont12)  //Responsavel pela Pesquisa:
oPrint:Line(lin+40,600,lin+40,1500)
oPrint:Say(lin,1550,STR0042,oFont12)//Data: _____/_____/_________

lin+=60

oPrint:Say(lin,030,STR0043,oFont12) //Empresa:
oPrint:Line(lin+40,220,lin+40,2280)

lin+=60

oPrint:Say(lin,030,STR0044,oFont12) //Nome:
oPrint:Line(lin+40,160,lin+40,1500)

oPrint:Say(lin,1550,STR0045,oFont12) //Fun็ใo
oPrint:Line(lin+40,1700,lin+40,2280)

Return lin

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณ  MenuDef  บAutor  ณ Manoel             บ Data ณ  11/11/10   บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricaoณ Monta aRotina (MENUDEF)                                     บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {{ STR0054  ,"FG_axPesqui"  , 0 , 1},; // Pesquisar
{ STR0055 , "VEICA100M" , 0 , 2},; // Visualizar
{ STR0056 , "VEICA100M" , 0 , 3},; // Incluir
{ STR0057 , "VEICA100M" , 0 , 4},; // Alterar
{ STR0058 , "VCA100IMP" , 0 , 2}} // Imprimir Ficha
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVEICA100M บ Autor ณ Andre Luis Almeida บ Data ณ  11/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณMonta Tela                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEICA100M(cAlias,nReg,nOpc)
Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor,_ni := 0
Private aTELA[0][0],aGETS[0]
Private aCpoEnchoice := {} , aCpoEditEnch , nControlAba := 1
Private aCols := {} , aHeader := {}, aAlter:={}
Private cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk , nLinhas := 0, nOpcc := nOpc
Private oAuxEnchoice
Private oAuxGetDados
Private oAuxDlg
Private nUsado := 0
Private aNewBot := { {"BMPINCLUIR",{|| FS_ATIVA(nOpc,"1") },(STR0059)} ,; // Ativar Perguntas
{"EXCLUIR",{|| FS_ATIVA(nOpc,"0") },(STR0060)} } // Desativar Perguntas

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da Enchoice                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("VCJ",.t.)
If nOpc == 4 // Se for alteracao, edita alguns campos no VCJ
	aCpoEditEnch := {}
EndIf

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VCJ")
While !Eof().And.(x3_arquivo=="VCJ")

	If X3USO(x3_usado) .And. cNivel>=x3_nivel .And. Alltrim(x3_campo) $ "VCJ_CODPES,VCJ_NOMPES,VCJ_TIPPES,VCJ_TIPAGE,VCJ_RAICUR,VCJ_RAICDP,VCJ_RAICTR"
		AADD(aCpoEnchoice,x3_campo)
		If nOpc == 4 .and. Alltrim(x3_campo) $ "VCJ_RAICUR,VCJ_RAICDP,VCJ_RAICTR"
			AADD(aCpoEditEnch,x3_campo)
		EndIf
	Endif

	&("M->"+x3_campo):= CriaVar(x3_campo)

	dbSkip()

End

If nOpc == 3
	nOpcE := 3
	nOpcG := 3
Elseif nOpc == 4
	nOpcE := 4
	nOpcG := 4
Else
	nOpcE := 2
	nOpcG := 2
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria aHeader e aCols da GetDados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VCJ")
While !Eof().And.(x3_arquivo=="VCJ")
	If X3USO(x3_usado) .And. cNivel>=x3_nivel .And. !Alltrim(x3_campo) $ "VCJ_CODPES,VCJ_NOMPES,VCJ_TIPPES,VCJ_TIPAGE,VCJ_RAICUR,VCJ_RAICDP,VCJ_RAICTR"
		nUsado:=nUsado+1
		aAdd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_f3, x3_context, x3cbox(), x3_relacao } )
		&("M->"+x3_campo) := CriaVar(x3_campo)
		IF SX3->X3_VISUAL <> "V"
			Aadd(aAlter,SX3->X3_CAMPO)
		ENDIF
	Endif
	dbSkip()
End
If !Inclui
	DbSelectArea("VCJ")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
EndIf

dbSelectArea("VCJ")
dbSetOrder(1)
dbgotop()
dbSeek(xFilial("VCJ")+M->VCJ_TIPPES+M->VCJ_TIPAGE+M->VCJ_SEQUEN+M->VCJ_CODPER)

nSavRec := recno()

While !eof() .and. xFilial("VCJ")==VCJ->VCJ_FILIAL .and. VCJ->VCJ_TIPPES+VCJ->VCJ_TIPAGE+VCJ->VCJ_SEQUEN+VCJ->VCJ_CODPER == M->VCJ_TIPPES+M->VCJ_TIPAGE+M->VCJ_SEQUEN+M->VCJ_CODPER
	If VCJ->VCJ_CODPES == M->VCJ_CODPES
		AADD(aCols,Array(Len(aHeader)+1))
		For _ni:=1 to Len(aHeader)
			aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
		Next
		If VCJ->VCJ_ATIVO == "1"
			aCols[Len(aCols),Len(aHeader)+1]:=.f.
		Else
			aCols[Len(aCols),Len(aHeader)+1]:=.t.
		EndIf
	EndIf
	DbSelectArea("VCJ")
	DbSkip()
EndDo

dbSelectArea("VCJ")
dbgoto(nSavRec)

If Len(aCols) == 0

	aCols:={Array(Len(aHeader)+1)}
	aCols[1,Len(aHeader)+1]:=.F.

	For _ni:=1 to Len(aHeader)
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next

EndIf

If Len( aCols ) > 0

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Executa a Modelo 3                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cTitulo       :=STR0001
	cAliasEnchoice:="VCJ"
	cAliasGetD    :="VCJ"
	cFieldOk      :="FG_MEMVAR().and.VCA100FIELD()"
	nLinhas       := 999

	FM_Mod3(cTitulo,cAliasEnchoice,cAliasGetD,@aCpoEnchoice,@aCpoEditEnch,@aHeader,@aCols,cFieldOk,,,,nOpcE,nOpcG,,oMainWnd,@oAuxDlg,@oAuxEnchoice,@oAuxGetDados,,,,,,,,25,aAlter)
	oAuxGetDados:oBrowse:bDelete := {|| VCA100DEL() }

	ACTIVATE MSDIALOG oAuxDlg ON INIT EnchoiceBar(oAuxDlg,{|| IIf(FS_Grava(nOpc),oAuxDlg:End(),.f.) },{|| oAuxDlg:End() },,aNewBot)

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Grava  บAutor  ณ Andre Luis Almeida บ Data ณ  11/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao / Gravacao do VCJ                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GRAVA(nOpc)
Local cQuery  := ""
Local nRecNo  := 0
Local nReg    := 0
Local lPos    := .f.
Local aDelVCJ := {}
Local lExc    := .f.
If nOpc == 2
	Return(.t.)
EndIf
If Empty(M->VCJ_TIPPES)
	Help(1," ","OBRIGAT",,"VCJ_TIPPES",4,1)
	Return(.f.)
EndIf
If Empty(M->VCJ_TIPAGE)
	Help(1," ","OBRIGAT",,"VCJ_TIPAGE",4,1)
	Return(.f.)
EndIf
If Empty(M->VCJ_CODPES)
	Help(1," ","OBRIGAT",,"VCJ_CODPES",4,1)
	Return(.f.)
EndIf
If Empty(M->VCJ_NOMPES)
	Help(1," ","OBRIGAT",,"VCJ_NOMPES",4,1)
	Return(.f.)
EndIf
// VALIDAR CAMPOS OBRIGATORIOS DAS PERGUNTAS //
For nReg := 1 to Len(oAuxGetDados:aCols)
	If !oAuxGetDados:aCols[nReg,Len(oAuxGetDados:aHeader)+1] // Pergunta Ativa
		If Empty(oAuxGetDados:aCols[nReg,FG_POSVAR("VCJ_SEQUEN","oAuxGetDados:aHeader")])
			Help(1," ","OBRIGAT",,"VCJ_SEQUEN",4,1)
			Return(.f.)
		EndIf
		If Empty(oAuxGetDados:aCols[nReg,FG_POSVAR("VCJ_PERGUN","oAuxGetDados:aHeader")])
			Help(1," ","OBRIGAT",,"VCJ_PERGUN",4,1)
			Return(.f.)
		EndIf
		aAdd(aDelVCJ,.f.) // Nao Deletar Perguntas Ativas
	Else // Pergunta Desativada
		nRecNo := 0
		If !Empty(oAuxGetDados:aCols[nReg,FG_POSVAR("VCJ_CODPER","oAuxGetDados:aHeader")])
			cQuery := "SELECT VCK.R_E_C_N_O_ AS RECVCK FROM "+RetSQLName("VCK")+" VCK WHERE VCK.VCK_FILIAL='"+xFilial("VCK")+"' AND VCK.VCK_CODPER='"+oAuxGetDados:aCols[nReg,FG_POSVAR("VCJ_CODPER","oAuxGetDados:aHeader")]+"' AND VCK.D_E_L_E_T_=' '"
			nRecNo := FM_SQL(cQuery)
		EndIf
		If nRecNo == 0
			aAdd(aDelVCJ,.t.) // Deletar Perguntas Desativadas
			lExc := .t.
		Else
			aAdd(aDelVCJ,.f.) // Nao Deletar Perguntas Desativadas
		EndIf
	EndIf
Next
If lExc // Existem Perguntas Desativadas
	lExc := .f.
	If MsgYesNo(STR0049,STR0047) // Existem Perguntas Desativadas. Deseja exclui-las? / Atencao
		lExc := .t.
	EndIf
EndIf
Begin Transaction
For nReg := 1 to Len(oAuxGetDados:aCols)
	nRecNo := 0
	If !Empty(oAuxGetDados:aCols[nReg,FG_POSVAR("VCJ_CODPER","oAuxGetDados:aHeader")])
		cQuery := "SELECT VCJ.R_E_C_N_O_ AS RECVCJ FROM "+RetSQLName("VCJ")+" VCJ WHERE VCJ.VCJ_FILIAL='"+xFilial("VCJ")+"' AND VCJ.VCJ_CODPER='"+oAuxGetDados:aCols[nReg,FG_POSVAR("VCJ_CODPER","oAuxGetDados:aHeader")]+"' AND VCJ.D_E_L_E_T_=' '"
		nRecNo := FM_SQL(cQuery)
	EndIf
	DbSelectArea("VCJ")
	If nRecNo > 0
		lPos := .f.
		DbGoTo(nRecNo)
	Else
		lPos := .t.
	EndIf
	RecLock("VCJ",lPos)
	FG_GRAVAR("VCJ",oAuxGetDados:aCols,oAuxGetDados:aHeader,nReg)
	If lPos
		VCJ->VCJ_CODPER := GetSXENum("VCJ","VCJ_CODPER")
		ConfirmSx8()
	EndIf
	VCJ->VCJ_TIPPES := M->VCJ_TIPPES
	VCJ->VCJ_TIPAGE := M->VCJ_TIPAGE
	VCJ->VCJ_CODPES := M->VCJ_CODPES
	VCJ->VCJ_NOMPES := M->VCJ_NOMPES
	VCJ->VCJ_RAICUR := M->VCJ_RAICUR
	VCJ->VCJ_RAICDP := M->VCJ_RAICDP
	VCJ->VCJ_RAICTR := M->VCJ_RAICTR
	MsUnLock()
	If lExc
		If aDelVCJ[nReg] // Excluir Perguntas Desativadas
			RecLock("VCJ",.f.,.t.)
			dbdelete()
			MsUnlock()
			WriteSx2("VCJ")
		EndIf
	EndIf
Next
End Transaction
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณVCA100FIELDบAutor  ณ Andre Luis Almeida บ Data ณ  11/11/10   บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricaoณ FIELDOK                                                     บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VCA100FIELD()

If ReadVar() == "M->VCJ_SEQUEN"
	M->VCJ_SEQUEN := strzero(val(M->VCJ_SEQUEN),3)
	//verficar dupicidade na sequencia do acols.
	If Ascan(aCols,{|x| x[FG_POSVAR("VCJ_SEQUEN")] == M->VCJ_SEQUEN }) # 0
		Help("  ",1,"EXISTCHAV")
		M->VCJ_SEQUEN:="   "
		Return(.f.)
	EndIf
EndIf
If ReadVar() == "M->VCJ_ATIVO"
	If M->VCJ_ATIVO == "0" // Ativo := 0=Nao
		oAuxGetDados:aCols[oAuxGetDados:nAt,Len(oAuxGetDados:aHeader)+1] := .t. // Deletar Linha
	Else
		oAuxGetDados:aCols[oAuxGetDados:nAt,Len(oAuxGetDados:aHeader)+1] := .f. // Voltar Linha
	EndIf
EndIf
oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR(substr(ReadVar(),4),"oAuxGetDados:aHeader")] := &(ReadVar())
oAuxGetDados:oBrowse:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณ VCA100DEL บAutor  ณ Andre Luis Almeida บ Data ณ  11/11/10   บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricaoณ Delete aCols                                                บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VCA100DEL()
If M->VCJ_ATIVO == "0" // Ativo (NAO)
	M->VCJ_ATIVO := "1" // Ativo := 1=Sim
	oAuxGetDados:aCols[oAuxGetDados:nAt,Len(oAuxGetDados:aHeader)+1] := .f. // Voltar Linha
Else // Ativo (SIM)
	M->VCJ_ATIVO := "0" // Ativo := 0=Nao
	oAuxGetDados:aCols[oAuxGetDados:nAt,Len(oAuxGetDados:aHeader)+1] := .t. // Deletar Linha
EndIf
oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VCJ_ATIVO","oAuxGetDados:aHeader")] := M->VCJ_ATIVO // Ativo (1=Sim/0=Nao)
oAuxGetDados:oBrowse:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณ FS_ATIVA  บAutor  ณ Andre Luis Almeida บ Data ณ  11/11/10   บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricaoณ Ativar / Desativar todas Perguntas                          บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ATIVA(nOpc,cAtivo)
Local nReg := 0
If nOpc <> 2
	For nReg := 1 to Len(oAuxGetDados:aCols)
		M->VCJ_ATIVO := cAtivo // Ativo (1=Sim/0=Nao)
		oAuxGetDados:aCols[nReg,FG_POSVAR("VCJ_ATIVO","oAuxGetDados:aHeader")] := cAtivo
		If cAtivo == "0" // Ativo (NAO)
			oAuxGetDados:aCols[nReg,Len(oAuxGetDados:aHeader)+1] := .t. // Deletar Linha
		Else // Ativo (SIM)
			oAuxGetDados:aCols[nReg,Len(oAuxGetDados:aHeader)+1] := .f. // Voltar Linha
		EndIf
	Next
	oAuxGetDados:oBrowse:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณVCA100VPES บAutor  ณ Andre Luis Almeida บ Data ณ  16/11/10   บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricaoณ Valida Pesquisa ( 1=Codigo da Pesquisa 2=Nome da Pesquisa ) บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VCA100VPES(nTp)
Local cQuery := ""
If nTp == 1 // Codigo da Pesquisa
	cQuery := "SELECT VCJ.R_E_C_N_O_ AS RECVCJ FROM "+RetSQLName("VCJ")+" VCJ WHERE VCJ.VCJ_FILIAL='"+xFilial("VCJ")+"' AND VCJ.VCJ_CODPES='"+M->VCJ_CODPES+"' AND VCJ.D_E_L_E_T_=' '"
Else // nTp == 2 // Nome da Pesquisa
	cQuery := "SELECT VCJ.R_E_C_N_O_ AS RECVCJ FROM "+RetSQLName("VCJ")+" VCJ WHERE VCJ.VCJ_FILIAL='"+xFilial("VCJ")+"' AND VCJ.VCJ_NOMPES='"+M->VCJ_NOMPES+"' AND VCJ.D_E_L_E_T_=' '"
EndIf
If FM_SQL(cQuery) > 0
	MsgStop(STR0048,STR0047) // Pesquisa ja cadastrada! / Atencao
	Return(.f.)
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณVCA100EXIS บAutor  ณ Andre Luis Almeida บ Data ณ  19/07/11   บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricaoณ Verifica se existe a Pesquisa de Satisfacao                 บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametroณ cTipPesq = Tipo de Pesquisa                                 บฑฑ
ฑฑบ         ณ cTipAge  = Tipo de Agenda                                   บฑฑ
ฑฑบ         ณ cOrig    = Origem                                           บฑฑ
ฑฑบ         ณ cCodCli  = Codigo do Cliente                                บฑฑ
ฑฑบ         ณ cLojCli  = Loja do Cliente                                  บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno  ณ nRet = 0 ( nao existe Pesquisa )                            บฑฑ
ฑฑบ         ณ nRet = 1 ( existe Pesquisa nao relaizada )                  บฑฑ
ฑฑบ         ณ nRet = 2 ( existe Pesquisa ja relaizada )                   บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VCA100EXIS(cTipPesq,cTipAge,cOrig,cCodCli,cLojCli)
Local nRet    := 0 // Nao existe Pesquisa
Local cQuery  := ""
Local cQAlias := "SQLVCJ"
Local nRecVE4 := 0
Default cCodCli := " "
Default cLojCli := " "
nRecVE4 := FM_SQL("SELECT R_E_C_N_O_ FROM "+RetSQLName("VE4")+" WHERE VE4_FILIAL='"+xFilial("VE4")+"' AND VE4_CODFAB='"+cCodCli+"' AND VE4_LOJA='"+cLojCli+"' AND D_E_L_E_T_=' '")
If nRecVE4 <= 0 // verificar se existe pesquisa somente quando o CLIENTE/LOJA nao for encontrado no VE4
	cQuery := "SELECT VCJ.VCJ_CODPER , VCJ.VCJ_ATIVO FROM "+RetSQLName("VCJ")+" VCJ WHERE VCJ.VCJ_FILIAL='"+xFilial("VCJ")+"' AND VCJ.VCJ_TIPPES='"+cTipPesq+"' AND VCJ.VCJ_TIPAGE='"+cTipAge+"' AND VCJ.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	Do While !( cQAlias )->( Eof() )
		DbSelectArea("VCK")
		DbSetOrder(1)
		If DbSeek(xFilial("VCK")+cOrig+( cQAlias )->( VCJ_CODPER ))
			nRet := 2 // Pesquisa ja realizada
			Exit
		Else
			If ( cQAlias )->( VCJ_ATIVO ) == "1"
				nRet := 1 // Pesquisa nao realizada
			EndIf
		EndIf
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
EndIf
DbselectArea("VCJ")
Return(nRet)