// …ÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕª
// ∫ Versao ∫ 61     ∫
// »ÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕº

#Include "Protheus.ch"
#Include "Folder.ch"
#Include "OFIOC060.CH"
#Include "OFIXDEF.CH"

Static lInconveniente := ( GetNewPar("MV_INCORC","N") == "S" )
Static lCtrlLote   := GetNewPar("MV_RASTRO","N") == "S"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007484_1"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ OFIOC060 ∫ Autor ≥ Andre Luis Almeida ∫ Data ≥  15/05/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Consulta OS - Pecas/Servicos/Requisicoes/Apontamentos      ∫±±
±±∫ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ∫±±
±±∫ Uso      ≥ Oficina                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFIOC060(lNoMBrowse)

Local aCores := {	{ 'VO1->VO1_STATUS == "A"', 'BR_VERDE' } ,;   	// Aberta
					{ 'VO1->VO1_STATUS == "D"', 'BR_AZUL'     } ,; 		// Liberada
					{ 'VO1->VO1_STATUS == "F"', 'BR_VERMELHO' } ,; 		// Fechado
					{ 'VO1->VO1_STATUS == "C"', 'BR_PRETO'    } }  		// Cancelado

Private aRotina := MenuDef()
Private cCadastro := STR0001 // Ordens de ServiÁo
Default lNoMBrowse := .f.

If lNoMBrowse

	dbSelectArea("VO1")
	If ( nOpc <> 0 ) .And. !Deleted()		
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
	EndIf	
	
Else
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Endereca a funcao de BROWSE                                  ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	mBrowse( 6, 1,22,75,"VO1",,,,,,aCores)                                  
	
Endif

Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ OC060    ∫ Autor ≥ Andre Luis Almeida ∫ Data ≥  15/05/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Monta Tela da Consulta                                     ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OC060(cAlias,nReg,nOpc)
//variaveis controle de janela
Local aObjects   := {} , aPosObj := {} , aInfo := {}
Local aSizeAut   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nTamSerie  := FGX_MILSNF("VOO", 6, "VOO_SERNFI")
//
Local aFolder060 := {}
Local aAreaVAI   := VAI->(GetArea())
Local lIncPec    := lInconveniente
Local lIncSrv    := lInconveniente
//
Private oOkTik   := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik   := LoadBitmap( GetResources() , "LBNO" )
//
Private a060TPC  := {} // Todas Pecas
Private a060TSC  := {} // Todos Servicos
//
Private a060Res  := {} // Folder 1 - Resumo
//
Private a060PecaTT      := {} // Folder 2 - ListBox Tipo de Tempo Pecas
Private a060PecaInconv  := {} // Folder 2 - ListBox Inconveniente Pecas
Private a060PecaGrp     := {} // Folder 2 - ListBox Grupo de Pecas
Private a060Peca        := {} // Folder 2 - ListBox de Pecas
//
Private a060SrvcTT      := {} // Folder 3 - ListBox Tipo de Tempo Servicos
Private a060SrvcInconv  := {} // Folder 3 - ListBox Inconveniente Servicos
Private a060SrvcTipoSer := {} // Folder 3 - ListBox Tipo de Servico
Private a060SrvcClasHab := {} // Folder 3 - ListBox ClassificaÁ„o da Habilidade
Private a060Srvc        := {} // Folder 3 - ListBox de Servicos
//
Private a060Psa  := {} // Folder 5 - ListBox de Pausas Servicos
//
Private a060Orc  := {} // Folder 6 - ListBox de Orcamentos
//
Private a060Pen	 := {} // Folder 7 - Pecas Pendentes
//
Private lLbPLTpP := .t. // Tik no ListBox Tipo de Tempo Pecas
Private lLbPLTpS := .t. // Tik no ListBox Tipo de Tempo Servicos
Private lLbPLInP := .t. // Tik no ListBox Inconveniente Pecas
Private lLbPLInS := .t. // Tik no ListBox Inconveniente Servicos
Private lLbPLGp  := .t. // Tik no ListBox Grupo de Pecas
Private lLbPLTS  := .t. // Tik no ListBox Tipo de Servico
Private lLbPLTSCH:= .t. // Tik no ListBox ClassificaÁ„o da Habilidade
//
Private lTemPec  := .t. // Possui FOLDER 3-Pecas
Private lTemSrv  := .t. // Possui FOLDER 4-Servicos
Private lTemPsa  := .t. // Possui FOLDER 5-Pausas Servicos
Private lTemOrc  := .t. // Possui FOLDER 6-Orcamentos
Private lTemPen  := .t. // Possui FOLDER 7-PeÁas Pendentes
//
Private oNada    := LoadBitmap( GetResources() , "NAOEXISTE" ) // DEIXAR SEM IMAGEM
Private oCor     := oNada
Private oAzul    := LoadBitmap( GetResources() , "BR_AZUL" ) 	// Liberado
Private oVerm    := LoadBitmap( GetResources() , "BR_VERMELHO" )	// Faturado
Private oVerd    := LoadBitmap( GetResources() , "BR_VERDE" ) 	// Aberto
Private oPret    := LoadBitmap( GetResources() , "BR_PRETO" ) 	// Cancelado
//
Private aNewBot  := {} // Opcoes -> Acoes Relacionadas
//
Private cCadastro  := STR0001 // Ordens de ServiÁo
Private aTelaOC060 := {} // Vetor utilizado na Enchoice quando a consulta for chamada de outra Enchoice, substitui o vetor default "aTela"
//
Private lVAICLAHAB := (VAI->(FieldPos("VAI_CLAHAB")) <> 0)
//
Private lVS1_DEXPOS := (VS1->(FieldPos("VS1_DEXPOS")) <> 0) // Data de ExportaÁ„o do OrÁamento para a OS
//
Private lVO3_FUNDIS := (VO3->(FieldPos("VO3_FUNDIS")) <> 0)
Private lVO4_FUNDIS := (VO4->(FieldPos("VO4_FUNDIS")) <> 0)
//
OC060_LEV() // Levanta registros: PECAS e SERVICOS
//
aObjects := {}
AAdd( aObjects, { 1, 00 , .T., .F. } )
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)
//
VV1->(DbSetOrder(1))
VV1->(DbSeek( xFilial("VV1") + VO1->VO1_CHAINT ))
//
VE1->(DbSetOrder(1))
VE1->(DbSeek( xFilial("VE1") + VV1->VV1_CODMAR ))
//
SA1->(DbSetOrder(1))
SA1->(DbSeek( xFilial("SA1") + VO1->VO1_PROVEI + VO1->VO1_LOJPRO ))
//PeÁas
nTamLb := ( ( aPosObj[1,4] - 07 ) / 9 )  // Dividir TELA em 9 colunas ( 3 LISTBOX )
//ServiÁos
If (VAI->(FieldPos("VAI_CLAHAB")) <> 0)
	nTamLbS := ( ( aPosObj[1,4] - 07 ) / 12 )  // Dividir TELA em 8 colunas ( 4 LISTBOX )
Else
	nTamLbS := ( ( aPosObj[1,4] - 07 ) / 9 )  // Dividir TELA em 9 colunas ( 3 LISTBOX )
Endif
//
AADD(aNewBot, {"PMSCOLOR",{|| OC060LEG() },( STR0002 )} ) // Legenda

If ( ExistBlock("OC060ABT") )  // Incluir Opcoes no Acoes relacionadas
	aNewBot := ExecBlock("OC060ABT",.f.,.f.,{aNewBot})
EndIf

DEFINE MSDIALOG oDlgOC060 FROM aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] TITLE (STR0003+": "+VO1->VO1_NUMOSV) OF oMainWnd PIXEL // Ordem de ServiÁo

////////////////////////
// Folders            //
////////////////////////
oFolder060 := TFolder():New(1,1,aFolder060,,oDlgOC060,,,,.T.,.F.,100,100)
oFolder060:Align:= CONTROL_ALIGN_ALLCLIENT

////////////////////////
// Enchoice VO1 (TOPO)//
////////////////////////
aCpoEnchoice := {}
VO1->(RegToMemory("VO1",.F.))
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VO1")
While !Eof().and.(x3_arquivo=="VO1")
	If X3USO(x3_usado).and.cNivel>=x3_nivel .And. !( Alltrim(x3_campo) $ [VO1_DATSAI/VO1_HORSAI/VO1_TEMGAR/VO1_TEMLIB/VO1_MECREQ/VO1_TIPSOL/VO1_SITGAR/VO1_OBSMEM/VO1_CODMAR/VO1_EXPGAR/VO1_MOTIVO/VO1_DESMOT/VO1_TEMFEC/VO1_TEMCAN] )
		AADD(aCpoEnchoice,x3_campo)
	Endif
	dbSkip()
EndDo
oFolder060:AddItem( STR0004 , .t. ) // Dados da Ordem de ServiÁo - Folder[1]
oMsMGet := MsMGet():New("VO1",VO1->(RecNo()),2,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,2,,,,oFolder060:aDialogs[1],,,.t.,"aTelaOC060",,.t.)
oMsMGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT

////////////////////////
// Folder[2] Resumo   //
////////////////////////
oFolder060:AddItem( STR0005 , .t. ) // Resumo - Folder[2]

////////////////////////
// Folder[3] Pecas    //
////////////////////////
If lTemPec

	oFolder060:AddItem( STR0006 , .t. ) // 3 - PeÁas
	
	oFldPeca := TPanel():New( 0, 0, "", oFolder060:aDialogs[Len(oFolder060:aDialogs)] , NIL,,,,,10, 10, .t., .f.)
	oFldPeca:Align := CONTROL_ALIGN_ALLCLIENT
	
	oAjuste := TPanel():New(0,0,"",oFldPeca,NIL,.T.,.F.,NIL,NIL,0,11,.F.,.F.)
	oAjuste:Align := CONTROL_ALIGN_BOTTOM
	
	// Pecas - Painel Filtro
	oPecaFiltroPanel := TPanel():New(0,0,"",oFldPeca,NIL,.T.,.F.,NIL,NIL,0,58,.T.,.F.)
	oPecaFiltroPanel:Align := CONTROL_ALIGN_TOP
	
	If lInconveniente
		// Verificar se existe Inconveniente para Pecas
		lIncPec := ( len(a060PecaInconv) > 1 .or. ( len(a060PecaInconv) == 1 .and. !Empty(a060PecaInconv[1,2]+a060PecaInconv[1,3]) ) )
	EndIf

	// Pecas Filtro - ListBox Tipo de Tempo
	@ 001,(nTamLb*0)+000 LISTBOX oLbPLTpP FIELDS HEADER "",STR0023,STR0012,STR0025 COLSIZES 10,20,80,100 SIZE nTamLb*IIf(lIncPec,4,7),54 OF oPecaFiltroPanel PIXEL ON DBLCLICK OC060_TIK("1","a060PecaTT","oLbPLTpP",) // TpTpo / DescriÁ„o / Faturar para
	oLbPLTpP:SetArray(a060PecaTT)
	oLbPLTpP:bLine := { || { IIf(a060PecaTT[oLbPLTpP:nAt,1],oOkTik,oNoTik) , a060PecaTT[oLbPLTpP:nAt,2] , a060PecaTT[oLbPLTpP:nAt,3] , a060PecaTT[oLbPLTpP:nAt,4] }}
	oLbPLTpP:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , OC060_TIK("0","a060PecaTT","oLbPLTpP","lLbPLTpP") , Nil ) , }
	If lIncPec
		// Pecas Filtro - ListBox Incoveniente
		@ 001,(nTamLb*4)+002 LISTBOX oLbPLInP FIELDS HEADER "",STR0026,STR0012 COLSIZES 10,50,80 SIZE nTamLb*3,54 OF oPecaFiltroPanel PIXEL ON DBLCLICK OC060_TIK("1","a060PecaInconv","oLbPLInP",) // Inconveniente / DescriÁao
		oLbPLInP:SetArray(a060PecaInconv)
		oLbPLInP:bLine := { || { IIf(a060PecaInconv[oLbPLInP:nAt,1],oOkTik,oNoTik) , Alltrim(a060PecaInconv[oLbPLInP:nAt,2]) , a060PecaInconv[oLbPLInP:nAt,3] }}
		oLbPLInP:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , OC060_TIK("0","a060PecaInconv","oLbPLInP","lLbPLInP") , Nil ) , }
	EndIf
	// Pecas Filtro - ListBox Grupo
	@ 001,(nTamLb*7)+004 LISTBOX oLbPLGp FIELDS HEADER "",STR0024,STR0012 COLSIZES 10,20,90 SIZE nTamLb*2+3,54 OF oPecaFiltroPanel PIXEL ON DBLCLICK OC060_TIK("1","a060PecaGrp","oLbPLGp",) // Grupo / Descricao
	oLbPLGp:SetArray(a060PecaGrp)
	oLbPLGp:bLine := { || { IIf(a060PecaGrp[oLbPLGp:nAt,1],oOkTik,oNoTik) , a060PecaGrp[oLbPLGp:nAt,2] , a060PecaGrp[oLbPLGp:nAt,3] }}
	oLbPLGp:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , OC060_TIK("0","a060PecaGrp","oLbPLGp","lLbPLGp") , Nil ) , }

	// Pecas - ListBox Analitico
	oLbPLPc := TWBrowse():New( 01, 01, 10 , 10,,,, oFldPeca,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
	oLbPLPc:addColumn( TCColumn():New( " "            , { || oLbPLPc:aArray[oLbPLPc:nAt,29] }	,,,,"LEFT" ,10,.T.,.F.,,,,.F.,) )
	oLbPLPc:addColumn( TCColumn():New( UPPER(STR0006) , { || IIf(oLbPLPc:aArray[oLbPLPc:nAt,28]=="1",Alltrim(oLbPLPc:aArray[oLbPLPc:nAt,1]),IIf(oLbPLPc:aArray[oLbPLPc:nAt,28]=="2",space(05)+Alltrim(oLbPLPc:aArray[oLbPLPc:nAt,3]),IIf(oLbPLPc:aArray[oLbPLPc:nAt,28]=="3",space(10)+Alltrim(oLbPLPc:aArray[oLbPLPc:nAt,5]),IIf(oLbPLPc:aArray[oLbPLPc:nAt,28]=="4",space(15)+Alltrim(oLbPLPc:aArray[oLbPLPc:nAt,7]),"")))) } ,,,,"LEFT"  ,80,.F.,.F.,,,,.F.,) ) // PECAS
	oLbPLPc:addColumn( TCColumn():New( STR0012        , { || IIf(oLbPLPc:aArray[oLbPLPc:nAt,28]=="1",oLbPLPc:aArray[oLbPLPc:nAt,2],IIf(oLbPLPc:aArray[oLbPLPc:nAt,28]=="2",oLbPLPc:aArray[oLbPLPc:nAt,4],IIf(oLbPLPc:aArray[oLbPLPc:nAt,28]=="3",oLbPLPc:aArray[oLbPLPc:nAt,6],IIf(oLbPLPc:aArray[oLbPLPc:nAt,28]=="4",oLbPLPc:aArray[oLbPLPc:nAt,8],IIf(oLbPLPc:aArray[oLbPLPc:nAt,28]=="5",space(5)+IIf(oLbPLPc:aArray[oLbPLPc:nAt,10]=="1",STR0021,STR0022)+" "+oLbPLPc:aArray[oLbPLPc:nAt,15]+"-"+oLbPLPc:aArray[oLbPLPc:nAt,16],""))))) } ,,,,"LEFT"  ,100,.F.,.F.,,,,.F.,) ) // DescriÁ„o
	oLbPLPc:addColumn( TCColumn():New( STR0013        , { || IIf(!Empty(oLbPLPc:aArray[oLbPLPc:nAt,9]),Transform(oLbPLPc:aArray[oLbPLPc:nAt,9],"@D"),"") } ,,,,"LEFT"  ,40,.F.,.F.,,,,.F.,) ) // Dt.Movimento
	If lCtrlLote
		oLbPLPc:addColumn( TCColumn():New( RetTitle("VO3_LOTECT") , { || oLbPLPc:aArray[oLbPLPc:nAt,33] } ,,,,"LEFT"  ,15,.F.,.F.,,,,.F.,) ) // Lote
		oLbPLPc:addColumn( TCColumn():New( RetTitle("VO3_NUMLOT") , { || oLbPLPc:aArray[oLbPLPc:nAt,34] } ,,,,"LEFT"  ,25,.F.,.F.,,,,.F.,) ) // Sub-Lote
	EndIf
	oLbPLPc:addColumn( TCColumn():New( STR0014        , { || IIf(oLbPLPc:aArray[oLbPLPc:nAt,11]<>0,Transform(oLbPLPc:aArray[oLbPLPc:nAt,11],PesqPict("VO3","VO3_QTDREQ")),"") } ,,,,"RIGHT" ,30,.F.,.F.,,,,.F.,) ) // Qtde
	oLbPLPc:addColumn( TCColumn():New( STR0057        , { || Transform( oLbPLPc:aArray[oLbPLPc:nAt,12] , "@E 9,999,999.99" ) } ,,,,"RIGHT" ,38,.F.,.F.,,,,.F.,) ) // Valor Bruto
	oLbPLPc:addColumn( TCColumn():New( STR0058        , { || Transform( oLbPLPc:aArray[oLbPLPc:nAt,13] , "@E 9,999,999.99" ) } ,,,,"RIGHT" ,38,.F.,.F.,,,,.F.,) ) // Desconto
	oLbPLPc:addColumn( TCColumn():New( STR0059        , { || Transform( oLbPLPc:aArray[oLbPLPc:nAt,14] , "@E 9,999,999.99" ) } ,,,,"RIGHT" ,38,.F.,.F.,,,,.F.,) ) // Valor Liquido
	oLbPLPc:addColumn( TCColumn():New( STR0063        , { || IIf(!Empty(oLbPLPc:aArray[oLbPLPc:nAt,30]),oLbPLPc:aArray[oLbPLPc:nAt,30],"") } ,,,,"LEFT"  ,45,.F.,.F.,,,,.F.,) ) // Num. LiberaÁ„o
	oLbPLPc:addColumn( TCColumn():New( STR0016        , { || IIf(!Empty(oLbPLPc:aArray[oLbPLPc:nAt,20]),Transform(oLbPLPc:aArray[oLbPLPc:nAt,20],"@D"),"") } ,,,,"LEFT"  ,45,.F.,.F.,,,,.F.,) ) // Dt.LiberaÁ„o
	oLbPLPc:addColumn( TCColumn():New( STR0017        , { || IIf(!Empty(oLbPLPc:aArray[oLbPLPc:nAt,21]),Transform(oLbPLPc:aArray[oLbPLPc:nAt,21],"@D"),"") } ,,,,"LEFT"  ,45,.F.,.F.,,,,.F.,) ) // Dt.Fechamento
	oLbPLPc:addColumn( TCColumn():New( STR0018        , { || IIf(!Empty(oLbPLPc:aArray[oLbPLPc:nAt,22]),oLbPLPc:aArray[oLbPLPc:nAt,22]+"-"+oLbPLPc:aArray[oLbPLPc:nAt,23],"") } ,,,,"LEFT"  ,45,.F.,.F.,,,,.F.,) ) // NF/Serie
	oLbPLPc:addColumn( TCColumn():New( STR0019        , { || IIf(!Empty(oLbPLPc:aArray[oLbPLPc:nAt,24]),oLbPLPc:aArray[oLbPLPc:nAt,24]+"-"+oLbPLPc:aArray[oLbPLPc:nAt,25],"") } ,,,,"LEFT"  ,75,.F.,.F.,,,,.F.,) ) // Funcion·rio Fechamento
	If lVO3_FUNDIS
		oLbPLPc:AddColumn( TCColumn():New( STR0069 , { || IIf(!Empty(oLbPLPc:aArray[oLbPLPc:nAt,35]),oLbPLPc:aArray[oLbPLPc:nAt,35]+"-"+oLbPLPc:aArray[oLbPLPc:nAt,36],"") } ,,,,"LEFT"  ,75,.F.,.F.,,,,.F.,) ) // Funcion·rio LiberaÁ„o
	EndIf
	oLbPLPc:addColumn( TCColumn():New( STR0020        , { || IIf(!Empty(oLbPLPc:aArray[oLbPLPc:nAt,26]),oLbPLPc:aArray[oLbPLPc:nAt,26]+"-"+oLbPLPc:aArray[oLbPLPc:nAt,27],"") } ,,,,"LEFT"  ,75,.F.,.F.,,,,.F.,) ) // Funcion·rio RequisiÁ„o
	oLbPLPc:Align:= CONTROL_ALIGN_ALLCLIENT
	oLbPLPc:nAT := 1
	oLbPLPc:SetArray(a060Peca)
	oLbPLPc:Refresh()
EndIf
////////////////////////
// Servicos Folder[4] //
////////////////////////
If lTemSrv
	oFolder060:AddItem( STR0007 , .t. ) // 4 - ServiÁos
	
	oFldSrvc := TPanel():New( 0, 0, "", oFolder060:aDialogs[Len(oFolder060:aDialogs)] , NIL,,,,,10, 10, .t., .f.)
	oFldSrvc:Align := CONTROL_ALIGN_ALLCLIENT
	
	// Servicos - Painel Filtro
	oTPanSrv := TPanel():New(0,0,"",oFldSrvc,NIL,.T.,.F.,NIL,NIL,0,58,.T.,.F.)
	oTPanSrv:Align := CONTROL_ALIGN_TOP
	
	oAjuste := TPanel():New(0,0,"",oFldSrvc,NIL,.T.,.F.,NIL,NIL,0,11,.F.,.F.)
	oAjuste:Align := CONTROL_ALIGN_BOTTOM

	If lInconveniente
		// Verificar se existe Inconveniente para Servicos
		lIncSrv := ( len(a060SrvcInconv) > 1 .or. ( len(a060SrvcInconv) == 1 .and. !Empty(a060SrvcInconv[1,2]+a060SrvcInconv[1,3]) ) )
	EndIf

	// Servicos Filtro - ListBox Tipo de Tempo
	@ 001,(nTamLbS*0)+000 LISTBOX oLbPLTpS FIELDS HEADER "",STR0023,STR0012,STR0025 COLSIZES 10,20,80,100 SIZE nTamLbS*IIf(lIncSrv,4,7),54 OF oTPanSrv PIXEL ON DBLCLICK OC060_TIK("1","a060SrvcTT","oLbPLTpS",) // TpTpo / DescriÁ„o / Faturar para
	oLbPLTpS:SetArray(a060SrvcTT)
	oLbPLTpS:bLine := { || { IIf(a060SrvcTT[oLbPLTpS:nAt,1],oOkTik,oNoTik) , a060SrvcTT[oLbPLTpS:nAt,2] , a060SrvcTT[oLbPLTpS:nAt,3] , a060SrvcTT[oLbPLTpS:nAt,4] }}
	oLbPLTpS:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , OC060_TIK("0","a060SrvcTT","oLbPLTpS","lLbPLTpS") , Nil ) , }
	If lIncSrv
		// Servicos Filtro - ListBox Incoveniente
		@ 001,(nTamLbS*4)+002 LISTBOX oLbPLInS FIELDS HEADER "",STR0026,STR0012 COLSIZES 10,50,80 SIZE nTamLbS*3,54 OF oTPanSrv PIXEL ON DBLCLICK OC060_TIK("1","a060SrvcInconv","oLbPLInS",) // Inconveniente / DescriÁ„o
		oLbPLInS:SetArray(a060SrvcInconv)
		oLbPLInS:bLine := { || { IIf(a060SrvcInconv[oLbPLInS:nAt,1],oOkTik,oNoTik) , Alltrim(a060SrvcInconv[oLbPLInS:nAt,2]) , a060SrvcInconv[oLbPLInS:nAt,3] }}
		oLbPLInS:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , OC060_TIK("0","a060SrvcInconv","oLbPLInS","lLbPLInS") , Nil ) , }
	EndIf
	// Servicos Filtro - ListBox Tipo de Servico
	@ 001,(nTamLbS*7)+004 LISTBOX oLbPLTS FIELDS HEADER "",STR0027,STR0012 COLSIZES 10,30,80 SIZE nTamLbS*2+3,54 OF oTPanSrv PIXEL ON DBLCLICK OC060_TIK("1","a060SrvcTipoSer","oLbPLTS",) // TpServiÁo / DescriÁ„o
	oLbPLTS:SetArray(a060SrvcTipoSer)
	oLbPLTS:bLine := { || { IIf(a060SrvcTipoSer[oLbPLTS:nAt,1],oOkTik,oNoTik) , a060SrvcTipoSer[oLbPLTS:nAt,2] , a060SrvcTipoSer[oLbPLTS:nAt,3] }}
	oLbPLTS:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , OC060_TIK("0","a060SrvcTipoSer","oLbPLTS","lLbPLTS") , Nil ) , }
	If lVAICLAHAB
		// Servicos Filtro - ListBox ClassificaÁ„o da Habilidade
		@ 001,(nTamLbS*9)+007 LISTBOX oLbPLTSCH FIELDS HEADER STR0065,STR0066,STR0067,STR0068 COLSIZES 40,30,30,30 SIZE nTamLbS*3,54 OF oTPanSrv PIXEL ON DBLCLICK OC060_TIK("1","a060SrvcClasHab","oLbPLTSCH",) // Class Hab / Tmp Trab / Tmp Cob / Tmp Vend
		oLbPLTSCH:SetArray(a060SrvcClasHab)
		oLbPLTSCH:bLine := { || { a060SrvcClasHab[oLbPLTSCH:nAt,3] , IIf(!Empty(a060SrvcClasHab[oLbPLTSCH:nAt,4]),Transform(a060SrvcClasHab[oLbPLTSCH:nAt,4],"@R 9999:99"),""), IIf(!Empty(a060SrvcClasHab[oLbPLTSCH:nAt,5]),Transform(a060SrvcClasHab[oLbPLTSCH:nAt,5],"@R 9999:99"),"") , IIf(!Empty(a060SrvcClasHab[oLbPLTSCH:nAt,6]),Transform(a060SrvcClasHab[oLbPLTSCH:nAt,6],"@R 9999:99"),"") }}
	Endif
	// Servicos - ListBox Analitico
	oLbPLSv := TWBrowse():New( 00, 00, 10, 10,,,, oFldSrvc ,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
	oLbPLSv:addColumn( TCColumn():New( ""             , { || a060Srvc[oLbPLSv:nAt,35] }	,,,,"LEFT" ,10,.T.,.F.,,,,.F.,) )
	oLbPLSv:addColumn( TCColumn():New( UPPER(STR0007) , { || IIf(a060Srvc[oLbPLSv:nAt,34]=="1",space(00)+Alltrim(a060Srvc[oLbPLSv:nAt,1]),;
																					IIf(a060Srvc[oLbPLSv:nAt,34]=="2",space(05)+Alltrim(a060Srvc[oLbPLSv:nAt,3]),;
																						IIf(a060Srvc[oLbPLSv:nAt,34]=="3",space(10)+Alltrim(a060Srvc[oLbPLSv:nAt,5]),;
																							IIf(a060Srvc[oLbPLSv:nAt,34]=="4",space(15)+Alltrim(a060Srvc[oLbPLSv:nAt,37])+ "-" + Alltrim(a060Srvc[oLbPLSv:nAt,7]),"")))) } ,,,,"LEFT" ,80,.F.,.F.,,,,.F.,) ) // SERVI«OS
	oLbPLSv:addColumn( TCColumn():New( STR0012 , { || IIf(a060Srvc[oLbPLSv:nAt,34]=="1",a060Srvc[oLbPLSv:nAt,2],;
																		IIf(a060Srvc[oLbPLSv:nAt,34]=="2",a060Srvc[oLbPLSv:nAt,4],;
																			IIf(a060Srvc[oLbPLSv:nAt,34]=="3",a060Srvc[oLbPLSv:nAt,6],;
																				IIf(a060Srvc[oLbPLSv:nAt,34]=="4",a060Srvc[oLbPLSv:nAt,8],;
																					IIf(a060Srvc[oLbPLSv:nAt,34]=="5",space(5)+a060Srvc[oLbPLSv:nAt,21]+"-"+a060Srvc[oLbPLSv:nAt,22],""))))) } ,,,,"LEFT" ,100,.F.,.F.,,,,.F.,) ) // DescricÁ„o
	oLbPLSv:addColumn( TCColumn():New( STR0028        , { || IIf(!Empty(a060Srvc[oLbPLSv:nAt,09]),Transform(a060Srvc[oLbPLSv:nAt,09],"@R 9999:99"),"") } ,,,,"RIGHT" ,40,.F.,.F.,,,,.F.,) ) // Tmp Padr„o
	oLbPLSv:addColumn( TCColumn():New( STR0029        , { || IIf(!Empty(a060Srvc[oLbPLSv:nAt,10]),Transform(a060Srvc[oLbPLSv:nAt,10],"@R 9999:99"),"") } ,,,,"RIGHT" ,40,.F.,.F.,,,,.F.,) ) // Tmp Tabalhado
	oLbPLSv:addColumn( TCColumn():New( STR0030        , { || IIf(!Empty(a060Srvc[oLbPLSv:nAt,11]),Transform(a060Srvc[oLbPLSv:nAt,11],"@R 9999:99"),"") } ,,,,"RIGHT" ,40,.F.,.F.,,,,.F.,) ) // Tmp Cobrado
	oLbPLSv:addColumn( TCColumn():New( STR0031        , { || IIf(!Empty(a060Srvc[oLbPLSv:nAt,12]),Transform(a060Srvc[oLbPLSv:nAt,12],"@R 9999:99"),"") } ,,,,"RIGHT" ,40,.F.,.F.,,,,.F.,) ) // Tmp Vendido 
	oLbPLSv:addColumn( TCColumn():New( STR0015        , { || Transform(a060Srvc[oLbPLSv:nAt,13],"@E 999,999.99") } ,,,,"RIGHT" ,40,.F.,.F.,,,,.F.,) ) // Valor
	oLbPLSv:addColumn( TCColumn():New( STR0032        , { || IIf(!Empty(a060Srvc[oLbPLSv:nAt,17]),Transform(a060Srvc[oLbPLSv:nAt,17],"@D"),"") } ,,,,"LEFT" ,35,.F.,.F.,,,,.F.,) ) // Dt.Inicial
	oLbPLSv:addColumn( TCColumn():New( STR0033        , { || IIf(!Empty(a060Srvc[oLbPLSv:nAt,18]),Transform(a060Srvc[oLbPLSv:nAt,18],"@R 99:99"),"") } ,,,,"RIGHT" ,25,.F.,.F.,,,,.F.,) ) // Hr.Inicial
	oLbPLSv:addColumn( TCColumn():New( STR0034        , { || IIf(!Empty(a060Srvc[oLbPLSv:nAt,19]),Transform(a060Srvc[oLbPLSv:nAt,19],"@D"),"") } ,,,,"LEFT" ,35,.F.,.F.,,,,.F.,) ) // Dt.Final
	oLbPLSv:addColumn( TCColumn():New( STR0035        , { || IIf(!Empty(a060Srvc[oLbPLSv:nAt,20]),Transform(a060Srvc[oLbPLSv:nAt,20],"@R 99:99"),"") } ,,,,"RIGHT" ,25,.F.,.F.,,,,.F.,) ) // Hr.Final
	oLbPLSv:addColumn( TCColumn():New( STR0036        , { || a060Srvc[oLbPLSv:nAt,23] } ,,,,"LEFT" ,45,.F.,.F.,,,,.F.,) ) // SeÁ„o Oficina
	oLbPLSv:addColumn( TCColumn():New( STR0063        , { || IIf(!Empty(a060Srvc[oLbPLSv:nAt,36]),a060Srvc[oLbPLSv:nAt,36],"") } ,,,,"LEFT"  ,45,.F.,.F.,,,,.F.,) ) // Num. LiberaÁ„o
	oLbPLSv:addColumn( TCColumn():New( STR0016        , { || IIf(!Empty(a060Srvc[oLbPLSv:nAt,24]),Transform(a060Srvc[oLbPLSv:nAt,24],"@D"),"") } ,,,,"LEFT" ,45,.F.,.F.,,,,.F.,) ) // Dt.LiberaÁ„o
	oLbPLSv:addColumn( TCColumn():New( STR0017        , { || IIf(!Empty(a060Srvc[oLbPLSv:nAt,25]),Transform(a060Srvc[oLbPLSv:nAt,25],"@D"),"") } ,,,,"LEFT" ,45,.F.,.F.,,,,.F.,) ) // Dt.Fechamento
	oLbPLSv:addColumn( TCColumn():New( STR0018        , { || IIf(!Empty(a060Srvc[oLbPLSv:nAt,26]),a060Srvc[oLbPLSv:nAt,26]+"-"+a060Srvc[oLbPLSv:nAt,27],"") } ,,,,"LEFT" ,45,.F.,.F.,,,,.F.,) ) // NF/Serie
	oLbPLSv:addColumn( TCColumn():New( STR0019        , { || IIf(!Empty(a060Srvc[oLbPLSv:nAt,28]),a060Srvc[oLbPLSv:nAt,28]+"-"+a060Srvc[oLbPLSv:nAt,29],"") } ,,,,"LEFT" ,75,.F.,.F.,,,,.F.,) ) // Funcion·rio Fechamento
	If lVO4_FUNDIS
		oLbPLSv:AddColumn( TCColumn():New( STR0069 , { || IIf(!Empty(a060Srvc[oLbPLSv:nAt,39]),a060Srvc[oLbPLSv:nAt,39]+"-"+a060Srvc[oLbPLSv:nAt,40],"") } ,,,,"LEFT" ,75,.F.,.F.,,,,.F.,) ) // Funcion·rio LiberaÁ„o
	EndIf
	oLbPLSv:addColumn( TCColumn():New( STR0037        , { || a060Srvc[oLbPLSv:nAt,30] } ,,,,"LEFT" ,70,.F.,.F.,,,,.F.,) ) // Fornecedor
	oLbPLSv:addColumn( TCColumn():New( STR0038        , { || Transform(a060Srvc[oLbPLSv:nAt,31],"@E 999,999.99") } ,,,,"RIGHT" ,40,.F.,.F.,,,,.F.,) ) // Custo
	oLbPLSv:addColumn( TCColumn():New( STR0039        , { || IIf(!Empty(a060Srvc[oLbPLSv:nAt,32]),Transform(a060Srvc[oLbPLSv:nAt,32],"@D"),"") } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // Dt.Pagamento
	oLbPLSv:addColumn( TCColumn():New( STR0040        , { || a060Srvc[oLbPLSv:nAt,33] } ,,,,"LEFT" ,50,.F.,.F.,,,,.F.,) ) // Nro Documento
	oLbPLSv:SetArray(a060Srvc)
	oLbPLSv:nAT := 1
	oLbPLSv:Align:= CONTROL_ALIGN_ALLCLIENT
	oLbPLSv:Refresh()
	
EndIf

////////////////////////
// Folder[5] Pausas   //
////////////////////////
If lTemPsa
	oFolder060:AddItem( STR0052 , .t. ) // 5 - Pausas Servicos
	oAjuste := TPanel():New(0,0,"",oFolder060:aDialogs[Len(oFolder060:aDialogs)],NIL,.T.,.F.,NIL,NIL,0,11,.F.,.F.)
	oAjuste:Align := CONTROL_ALIGN_BOTTOM
	@ 000,000 LISTBOX oLb060Psa FIELDS HEADER STR0023,STR0012,STR0056,STR0012,STR0053,STR0042,STR0054,STR0055 COLSIZES 20,70,70,80,90,35,25,200 SIZE 10,10 OF oFolder060:aDialogs[Len(oFolder060:aDialogs)] PIXEL // TpTpo / DescriÁ„o / Cod.ServiÁo / Descricao / Produtivo / Data / Hora / Motivo Pausa
	oLb060Psa:SetArray(a060Psa)
	oLb060Psa:bLine := { || { a060Psa[oLb060Psa:nAt,1] , a060Psa[oLb060Psa:nAt,2] , a060Psa[oLb060Psa:nAt,3] , a060Psa[oLb060Psa:nAt,4] , a060Psa[oLb060Psa:nAt,5]+"-"+a060Psa[oLb060Psa:nAt,6] , Transform(a060Psa[oLb060Psa:nAt,7],"@D") , Transform(a060Psa[oLb060Psa:nAt,8],"@R 99:99") , a060Psa[oLb060Psa:nAt,9]+" - "+a060Psa[oLb060Psa:nAt,10] }}
	oLb060Psa:Align:= CONTROL_ALIGN_ALLCLIENT
EndIf

////////////////////////
// Folder[6] Orcamento//
////////////////////////
If lTemOrc
	oFolder060:AddItem( STR0008 , .t. ) // 6 - OrÁamentos
	oAjuste := TPanel():New(0,0,"",oFolder060:aDialogs[Len(oFolder060:aDialogs)],NIL,.T.,.F.,NIL,NIL,0,11,.F.,.F.)
	oAjuste:Align := CONTROL_ALIGN_BOTTOM
	@ 000,000 LISTBOX oLb060Orc FIELDS HEADER STR0041,STR0042,STR0006,STR0007 COLSIZES 70,50,50,50 SIZE 10,10 OF oFolder060:aDialogs[Len(oFolder060:aDialogs)] PIXEL ON DBLCLICK OC060_ORC() // Nro OrÁamento / Data / PeÁas / ServiÁos
	oLb060Orc:Align:= CONTROL_ALIGN_ALLCLIENT
	oLb060Orc:SetArray(a060Orc)
	oLb060Orc:bLine := { || { a060Orc[oLb060Orc:nAt,1] , Transform(a060Orc[oLb060Orc:nAt,2],"@D") , a060Orc[oLb060Orc:nAt,3] , a060Orc[oLb060Orc:nAt,4] }}
EndIf

///////////////////////////////
// Folder[7] Pecas Pendentes //
///////////////////////////////
If lTemPen
	oFolder060:AddItem( STR0062 , .t. ) // 7 - Pecas Pendentes
	oAjuste := TPanel():New(0,0,"",oFolder060:aDialogs[Len(oFolder060:aDialogs)],NIL,.T.,.F.,NIL,NIL,0,11,.F.,.F.)
	oAjuste:Align := CONTROL_ALIGN_BOTTOM
	oLb060Pen := TWBrowse():New( 000, 000, 10, 10,,,, oFolder060:aDialogs[Len(oFolder060:aDialogs)],,,,,,,,,,,,.F.,,.T.,,.F.,,, )
	oLb060Pen:addColumn( TCColumn():New( RetTitle("VSJ_ORIDAD") , { || oLb060Pen:aArray[oLb060Pen:nAt,7] } ,,,, "LEFT" , 070 , .F. , .F. ,,,, .F. , ) )
	oLb060Pen:addColumn( TCColumn():New( STR0041                , { || oLb060Pen:aArray[oLb060Pen:nAt,1] } ,,,, "LEFT" , 070 , .F. , .F. ,,,, .F. , ) )
	oLb060Pen:addColumn( TCColumn():New( STR0060                , { || oLb060Pen:aArray[oLb060Pen:nAt,2] } ,,,, "LEFT" , 040 , .F. , .F. ,,,, .F. , ) )
	oLb060Pen:addColumn( TCColumn():New( STR0024                , { || oLb060Pen:aArray[oLb060Pen:nAt,3] } ,,,, "LEFT" , 030 , .F. , .F. ,,,, .F. , ) )
	oLb060Pen:addColumn( TCColumn():New( STR0061                , { || oLb060Pen:aArray[oLb060Pen:nAt,4] } ,,,, "LEFT" , 080 , .F. , .F. ,,,, .F. , ) )
	oLb060Pen:addColumn( TCColumn():New( STR0012                , { || oLb060Pen:aArray[oLb060Pen:nAt,5] } ,,,, "LEFT" , 150 , .F. , .F. ,,,, .F. , ) )
	If lCtrlLote
		oLb060Pen:addColumn( TCColumn():New( RetTitle("VSJ_LOTECT") , { || oLb060Pen:aArray[oLb060Pen:nAt,8] } ,,,, "LEFT" , 020 , .F. , .F. ,,,, .F. , ) )
		oLb060Pen:addColumn( TCColumn():New( RetTitle("VSJ_NUMLOT") , { || oLb060Pen:aArray[oLb060Pen:nAt,9] } ,,,, "LEFT" , 030 , .F. , .F. ,,,, .F. , ) )
	EndIf
	If lVS1_DEXPOS // Data de ExportaÁ„o do OrÁamento para a OS
		oLb060Pen:addColumn( TCColumn():New( RetTitle("VS1_DEXPOS") , { || oLb060Pen:aArray[oLb060Pen:nAt,10] } ,,,, "LEFT" , 020 , .F. , .F. ,,,, .F. , ) )
		oLb060Pen:addColumn( TCColumn():New( RetTitle("VS1_HEXPOS") , { || oLb060Pen:aArray[oLb060Pen:nAt,11] } ,,,, "LEFT" , 030 , .F. , .F. ,,,, .F. , ) )
	Endif
	oLb060Pen:addColumn( TCColumn():New( STR0014                , { || oLb060Pen:aArray[oLb060Pen:nAt,6] } ,,,, "LEFT" , 030 , .F. , .F. ,,,, .F. , ) )
	oLb060Pen:Align:= CONTROL_ALIGN_ALLCLIENT
	oLb060Pen:nAt := 1
	oLb060Pen:SetArray(a060Pen)
	oLb060Pen:Refresh()
EndIf

oFldResumo := TPanel():New( 0, 0, "", oFolder060:aDialogs[2] , NIL,,,,,10, 10, .t., .f.) // Resumo Folder[2]
oFldResumo:Align := CONTROL_ALIGN_ALLCLIENT
oAjuste := TPanel():New(0,0,"",oFldResumo,NIL,.T.,.F.,NIL,NIL,0,11,.F.,.F.)
oAjuste:Align := CONTROL_ALIGN_BOTTOM
oLbResumo := TWBrowse():New( 000, 000, 10, 10,,,, oFldResumo,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
oLbResumo:addColumn( TCColumn():New( ""                    , { || a060Res[oLbResumo:nAt,1] } ,,,,"LEFT"  ,10,.T.,.F.,,,,.F.,) )
oLbResumo:addColumn( TCColumn():New( STR0009               , { || a060Res[oLbResumo:nAt,2] +" "+ a060Res[oLbResumo:nAt,3] } ,,,,"LEFT"  ,120,.F.,.F.,,,,.F.,) )
oLbResumo:addColumn( TCColumn():New( STR0010               , { || IIf(!Empty(a060Res[oLbResumo:nAt,4]),a060Res[oLbResumo:nAt,4]+"-"+a060Res[oLbResumo:nAt,5],"")+" "+a060Res[oLbResumo:nAt,6] } ,,,,"LEFT"  ,200,.F.,.F.,,,,.F.,) )
oLbResumo:addColumn( TCColumn():New( STR0006               , { || IIF( a060Res[oLbResumo:nAt,7] <> 0 , Transform(a060Res[oLbResumo:nAt,7],"@E 99,999,999.99") , "" ) } ,,,,"RIGHT" ,050,.F.,.F.,,,,.F.,) )
oLbResumo:addColumn( TCColumn():New( STR0007               , { || IIF( a060Res[oLbResumo:nAt,8] <> 0 , Transform(a060Res[oLbResumo:nAt,8],"@E 99,999,999.99") , "" ) } ,,,,"RIGHT" ,050,.F.,.F.,,,,.F.,) )
oLbResumo:addColumn( TCColumn():New( STR0011               , { || IIF( a060Res[oLbResumo:nAt,9] <> 0 , Transform(a060Res[oLbResumo:nAt,9],"@E 99,999,999.99") , "" ) } ,,,,"RIGHT" ,050,.F.,.F.,,,,.F.,) )
oLbResumo:addColumn( TCColumn():New( STR0018+" - "+STR0017 , { || a060Res[oLbResumo:nAt,11] } ,,,,"LEFT"  ,150,.F.,.F.,,,,.F.,) )
oLbResumo:Align:= CONTROL_ALIGN_ALLCLIENT
oLbResumo:nAt := 1
oLbResumo:SetArray(a060Res)
oLbResumo:Refresh()
///

ACTIVATE MSDIALOG oDlgOC060 ON INIT (EnchoiceBar(oDlgOC060,{|| oDlgOC060:End() },{|| oDlgOC060:End() },, aNewBot ) , ( oFolder060:ShowPage(2), oFolder060:SetOption(2), oLbResumo:SetFocus(),oLbResumo:Refresh()) )

RestArea(aAreaVAI)

Return()


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ OC060_LEV∫ Autor ≥ Andre Luis Almeida ∫ Data ≥  16/05/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Levanta dados para a consulta                              ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OC060_LEV()
Local nPos    := 0 // Posicao
Local nVlrPec := 0 // Valor Bruto de Peca
Local nVlrDes := 0 // Valor Desconto Peca
Local nVlrSrv := 0 // Valor Servico
Local ni      := 0
Local nj      := 0
Local cNFSer  := ""
Local cQAlAux := "SQLAUX" // VS1 / VST
Local cQuery  := ""
Local cNomSA1 := ""
Local cSQLSA1 := RetSqlName("SA1")
Local cSQLSF2 := RetSqlName("SF2")
Local cFilSA1 := xFilial("SA1")
Local cFilSF2 := xFilial("SF2")
Local cSQLSBM := RetSqlName("SBM")
Local cFilSBM := xFilial("SBM")
Local cSQLVOO := RetSqlName("VOO")
Local cFilVOO := xFilial("VOO")
Local cQAlias := "SQLVSJ"
Local cStatusTT := ""
Local aAuxCBox := {}
Local cDatExpOS := ""
Local	cHorExpOS := 0
//
a060TPC := FMX_CALPEC(VO1->VO1_NUMOSV,,,,.t.,.t.,.f.,.t.,.t.,.t.,.t.,,) // Matriz TOTAL de PeÁas/RequisiÁoes da OS
a060TSC := FMX_CALSER(VO1->VO1_NUMOSV,,,,.t.,.t.,.t.,.t.,.t.,.t.,,) // Matriz TOTAL de ServiÁos/Apontamentos da OS
//
a060Res := {} // Resumo
//
a060PecaTT := {} // Tipo de Tempo Pecas
a060PecaInconv := {} // Inconveniente Pecas
a060PecaGrp := {} // Grupo de Peca
//
a060SrvcTT := {} // Tipo de Tempo Servicos
a060SrvcInconv := {} // Inconveniente Servicos
a060SrvcTipoSer := {} // Tipo de Servico
//
a060Psa := {} // Pausas Servicos
//
a060Orc := {} // Orcamentos
//
AADD(a060Res,{oNada,space(00)+STR0043,"","","",Space(100),0,0,0,"     ",""}) // TOTAL GERAL
//
aSort( a060TPC ,,, { |x,y| x[PECA_TIPTEM] + x[PECA_INCONV_SEQ] + x[PECA_STATUS] + x[PECA_GRUITE] + x[PECA_CODITE] < y[PECA_TIPTEM] + y[PECA_INCONV_SEQ] + y[PECA_STATUS] + y[PECA_GRUITE] + y[PECA_CODITE] } )
For ni := 1 to len(a060TPC)
	nVlrPec := a060TPC[ni,PECA_VALBRU] // Valor Bruto Peca
	nVlrDes := a060TPC[ni,PECA_VALDES] // Desconto
	OC060Cor( @nVlrPec , @nVlrDes , @cStatusTT, @oCor , a060TPC[ni,PECA_DATCAN] , a060TPC[ni,PECA_DATFEC] , a060TPC[ni,PECA_DATLIB] )
	///////////////////////////
	// Total Geral           //
	///////////////////////////
	a060Res[1,7] += ( nVlrPec - nVlrDes ) // Total Geral
	a060Res[1,9] += ( nVlrPec - nVlrDes ) // Total Geral
	///////////////////////////
   // Tipo do Tipo de Tempo //
	///////////////////////////
	nPos := OC060RESUMO( a060TPC[ni,PECA_TIPTEM] , .t. , cStatusTT , oNada )
	a060Res[nPos,7] += ( nVlrPec - nVlrDes ) // Tipo do Tipo de Tempo
	a060Res[nPos,9] += ( nVlrPec - nVlrDes ) // Tipo do Tipo de Tempo
	///////////////////////////
	// Tipo de Tempo         //
	///////////////////////////
	nPos := OC060RESUMO( a060TPC[ni,PECA_TIPTEM] , .f. , cStatusTT, oCor , "PECA" , a060TPC[ni] )
	a060Res[nPos,7] += ( nVlrPec - nVlrDes ) // Tipo de Tempo
	a060Res[nPos,9] += ( nVlrPec - nVlrDes ) // Tipo de Tempo
	///////////////////////////
    // Selecao Inconveniente //
	///////////////////////////
	If Ascan( a060PecaInconv , {|x| x[2] == a060TPC[ni,PECA_INCONV_GRUPO]+" "+a060TPC[ni,PECA_INCONV_CODIGO]+" "+a060TPC[ni,PECA_INCONV_SEQ] }) <= 0
		aadd(a060PecaInconv,{.t.,a060TPC[ni,PECA_INCONV_GRUPO]+" "+a060TPC[ni,PECA_INCONV_CODIGO]+" "+a060TPC[ni,PECA_INCONV_SEQ],UPPER(a060TPC[ni,PECA_INCONV_DESCR])})
	EndIf
	///////////////////////////
    // Selecao Grupo Pecas   //
	///////////////////////////
	If Ascan( a060PecaGrp , {|x| x[2] == a060TPC[ni,PECA_GRUITE] }) <= 0
		aadd(a060PecaGrp,{.t.,a060TPC[ni,PECA_GRUITE],UPPER(FM_SQL("SELECT BM_DESC FROM "+cSQLSBM+" WHERE BM_FILIAL='"+cFilSBM+"' AND BM_GRUPO='"+a060TPC[ni,PECA_GRUITE]+"' AND D_E_L_E_T_=' '"))})
	EndIf
Next
//
aSort( a060TSC ,,, { |x,y| x[SRVC_TIPTEM] + x[SRVC_INCONV_SEQ] + x[SRVC_STATUS] + x[SRVC_TIPSER] + x[SRVC_GRUSER] + x[SRVC_CODSER] < y[SRVC_TIPTEM] + y[SRVC_INCONV_SEQ] + y[SRVC_STATUS] + y[SRVC_TIPSER] + y[SRVC_GRUSER] + y[SRVC_CODSER] } )
For ni := 1 to len(a060TSC)
	//
	nVlrSrv := a060TSC[ni,SRVC_VALLIQ] // Valor Servico
	nVlrDes := 0
	OC060Cor( @nVlrSrv , @nVlrDes , @cStatusTT, @oCor , a060TSC[ni,SRVC_DATCAN] , a060TSC[ni,SRVC_DATFEC] , a060TSC[ni,SRVC_DATLIB] )
	///////////////////////////
    // Total Geral           //
	///////////////////////////
	a060Res[1,8] += nVlrSrv // Total Geral
	a060Res[1,9] += nVlrSrv // Total Geral
	///////////////////////////
    // Tipo do Tipo de Tempo //
	///////////////////////////
	nPos := OC060RESUMO( a060TSC[ni,SRVC_TIPTEM] , .t. , cStatusTT , oNada )
	a060Res[nPos,8] += nVlrSrv // Tipo do Tipo de Tempo
	a060Res[nPos,9] += nVlrSrv // Tipo do Tipo de Tempo
	///////////////////////////
    // Tipo de Tempo         //
	///////////////////////////
	nPos := OC060RESUMO( a060TSC[ni,SRVC_TIPTEM] , .f. , cStatusTT , oCor , "SERVICO" , a060TSC[ni])
	a060Res[nPos,8] += nVlrSrv // Tipo de Tempo
	a060Res[nPos,9] += nVlrSrv // Tipo de Tempo
	///////////////////////////
    // Selecao Inconveniente //
	///////////////////////////
	If Ascan( a060SrvcInconv , {|x| x[2] == a060TSC[ni,SRVC_INCONV_GRUPO]+" "+a060TSC[ni,SRVC_INCONV_CODIGO]+" "+a060TSC[ni,SRVC_INCONV_SEQ] }) <= 0
		aadd(a060SrvcInconv,{.t.,a060TSC[ni,SRVC_INCONV_GRUPO]+" "+a060TSC[ni,SRVC_INCONV_CODIGO]+" "+a060TSC[ni,SRVC_INCONV_SEQ],UPPER(a060TSC[ni,SRVC_INCONV_DESCR])})
	EndIf
	///////////////////////////
  // Selecao Tipo Servico  //
	///////////////////////////
	If Ascan( a060SrvcTipoSer , {|x| x[2] == a060TSC[ni,SRVC_TIPSER] }) <= 0
		aadd(a060SrvcTipoSer,{.t.,a060TSC[ni,SRVC_TIPSER],UPPER(a060TSC[ni,SRVC_DESCRTIPSER])})
	EndIf
	///////////////////////////
	// Pausas Servicos       //
	///////////////////////////
	For nj := 1 to len(a060TSC[ni,SRVC_APONT]) // Apontamentos
		If !Empty(a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_MPAUSA])
			VS0->(DbSetOrder(1))
			If VS0->(dbSeek(xFilial("VS0")+"000006"+a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_MPAUSA]))
				aAdd(a060Psa,{ 	VOI->VOI_TIPTEM , UPPER(VOI->VOI_DESTTE) ,;
								a060TSC[ni,SRVC_CODSER] , left(a060TSC[ni,SRVC_DESCRICAO],30) ,;
								a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_CODIGO] , left(a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_NOME],20) ,;
								a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_DATFIN] , a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_HOTFIN] ,;
								a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_MPAUSA] , VS0->VS0_DESMOT })
			EndIf
		EndIf
	Next
Next
///////////////////////////
// Orcamentos            //
///////////////////////////
cQuery := "SELECT VS1.VS1_NUMORC , VS1.VS1_DATORC , COUNT(VS3.VS3_NUMORC) AS PEC , COUNT(VS4.VS4_NUMORC) AS SRV FROM "+RetSqlName("VS1")+" VS1 "
cQuery += "LEFT JOIN "+RetSqlName("VS3")+" VS3 ON ( VS3.VS3_FILIAL = '"+xFilial("VS3")+"' AND VS3.VS3_NUMORC=VS1.VS1_NUMORC AND VS3.D_E_L_E_T_=' ' ) "
cQuery += "LEFT JOIN "+RetSqlName("VS4")+" VS4 ON ( VS4.VS4_FILIAL = '"+xFilial("VS4")+"' AND VS4.VS4_NUMORC=VS1.VS1_NUMORC AND VS4.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VS1.VS1_FILIAL = '"+xFilial("VS1")+"' AND "
if VS1->(FieldPos("VS1_STATUS"))>0
	cQuery += "VS1.VS1_STATUS<>' ' AND VS1.VS1_STATUS<>'C' AND "
endif
cQuery += "VS1.VS1_NUMOSV='"+VO1->VO1_NUMOSV+"' AND VS1.D_E_L_E_T_=' '"
cQuery += "GROUP BY VS1.VS1_NUMORC , VS1.VS1_DATORC"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
While !( cQAlAux )->( Eof() )
	aadd(a060Orc,{( cQAlAux )->VS1_NUMORC,stod(( cQAlAux )->VS1_DATORC),IIf(( cQAlAux )->(PEC)>0,"   x"," "),IIf(( cQAlAux )->(SRV)>0,"   x"," ")})
	( cQAlAux )->(DbSkip())
Enddo
( cQAlAux )->( DbCloseArea() )
///////////////////////////
// Inconv nao utilizados //
///////////////////////////
cQuery := "SELECT DISTINCT VST.VST_GRUINC , VST.VST_CODINC , VST.VST_DESINC , VST.VST_SEQINC FROM "+RetSQLName("VST")+" VST "
cQuery += "WHERE VST.VST_FILIAL='"+xFilial("VST")+"' AND VST.VST_TIPO='2' AND VST.VST_CODIGO='"+VO1->VO1_NUMOSV+"' AND "
cQuery += "NOT EXISTS (SELECT DISTINCT VO3_SEQINC FROM "+RetSQLName("VO3")+" VO3 WHERE VO3.VO3_FILIAL='"+xFilial("VO3")+"' AND VO3.VO3_NUMOSV='"+VO1->VO1_NUMOSV+"' AND VO3.VO3_SEQINC=VST.VST_SEQINC AND VO3.D_E_L_E_T_=' ') AND "
cQuery += "NOT EXISTS (SELECT DISTINCT VO4_SEQINC FROM "+RetSQLName("VO4")+" VO4 WHERE VO4.VO4_FILIAL='"+xFilial("VO4")+"' AND VO4.VO4_NUMOSV='"+VO1->VO1_NUMOSV+"' AND VO4.VO4_SEQINC=VST.VST_SEQINC AND VO4.D_E_L_E_T_=' ') AND "
cQuery += "VST.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
While !( cQAlAux )->( Eof() )
	aadd(a060PecaInconv,{.t.,( cQAlAux )->VST_GRUINC+" "+( cQAlAux )->VST_CODINC+" "+( cQAlAux )->VST_SEQINC,UPPER(( cQAlAux )->VST_DESINC)})
	aadd(a060SrvcInconv,{.t.,( cQAlAux )->VST_GRUINC+" "+( cQAlAux )->VST_CODINC+" "+( cQAlAux )->VST_SEQINC,UPPER(( cQAlAux )->VST_DESINC)})
	( cQAlAux )->(DbSkip())
Enddo
( cQAlAux )->( DbCloseArea() )
/////////////////////
// PeÁas Pendentes //
/////////////////////
aAuxCBox := X3CboxToArray("VSJ_ORIDAD")
cQuery := "SELECT VSJ.VSJ_ORIDAD , VSJ.VSJ_NUMORC , VSJ.VSJ_GRUITE , VSJ.VSJ_CODITE , VSJ.VSJ_QTDITE , VSJ.VSJ_LOTECT , VSJ.VSJ_NUMLOT, "  + IIF( VSJ->(FieldPos("VSJ_TIPTEM")) <> 0 , " VSJ.VSJ_TIPTEM " , " '        ' " ) + " AS VSJ_TIPTEM "
cQuery += 	" , SB1.B1_DESC , VS1.VS1_TIPTEM "
If lVS1_DEXPOS // Data de ExportaÁ„o do OrÁamento para a OS
	cQuery += ",  VS1.VS1_DEXPOS, VS1.VS1_HEXPOS "
Endif
cQuery += "  FROM " + RetSqlName("VSJ") + " VSJ "
cQuery += "  JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_GRUPO = VSJ.VSJ_GRUITE AND SB1.B1_CODITE = VSJ.VSJ_CODITE AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "  LEFT JOIN " + RetSqlName("VS1") + " VS1 ON VS1.VS1_FILIAL = '" + xFilial("VS1") + "' AND VS1.VS1_NUMORC=VSJ.VSJ_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE VSJ.VSJ_FILIAL = '" + xFilial("VSJ") + "'"
cQuery += "   AND VSJ.VSJ_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
cQuery += "   AND VSJ.VSJ_QTDITE > 0 "
cQuery += "   AND VSJ.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY VSJ.VSJ_NUMORC , VSJ.VSJ_GRUITE , VSJ.VSJ_CODITE "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
Do While !( cQAlias )->( Eof() )
	If (nPos := aScan(aAuxCBox[2], (cQAlias)->VSJ_ORIDAD ) ) > 0
		cAuxOrig := AllTrim(aAuxCBox[1,nPos])
	Else
		cAuxOrig := "                    "
	EndIf 

	cDatExpOS := ""
	cHorExpOS := ""
	If lVS1_DEXPOS // Data de ExportaÁ„o do OrÁamento para a OS
		cDatExpOS := Dtoc(Stod( ( cQAlias )->VS1_DEXPOS ))
		cHorExpOS := Transform(( cQAlias )->VS1_HEXPOS,"@R 99:99")
	Endif


	aadd(a060Pen,{ ( cQAlias )->( VSJ_NUMORC ) , ;
				IIF( !Empty( (cQAlias)->VSJ_TIPTEM ) , (cQAlias)->VSJ_TIPTEM , ( cQAlias )->( VS1_TIPTEM ) ), ;
				( cQAlias )->( VSJ_GRUITE ) , ;
				left(( cQAlias )->( VSJ_CODITE ),22) , ;
				left(( cQAlias )->( B1_DESC ),60) , ;
				( cQAlias )->( VSJ_QTDITE ) , ;
				cAuxOrig , ; 
				( cQAlias )->VSJ_LOTECT , ;
				( cQAlias )->VSJ_NUMLOT , ;
				cDatExpOS , ;
				cHorExpOS })
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
//
DbSelectArea("VO1")
//
If len(a060PecaTT) <= 0
	aadd(a060PecaTT,{.t.,space(4),"",""}) // Tipo de Tempo Pecas
	lTemPec := .f.
EndIf
If len(a060PecaInconv) <= 0
	aadd(a060PecaInconv,{.t.,space(16),""}) // Inconveniente Pecas
	lTemPec := .f.
EndIf
If len(a060PecaGrp) <= 0
	aadd(a060PecaGrp,{.t.,space(4),""}) // Grupo de Peca
	lTemPec := .f.
EndIf
//
If len(a060SrvcTT) <= 0
	aadd(a060SrvcTT,{.t.,space(4),"",""}) // Tipo de Tempo Servicos
	lTemSrv := .f.
EndIf
If len(a060SrvcInconv) <= 0
	aadd(a060SrvcInconv,{.t.,space(16),""}) // Inconveniente Servicos
	lTemSrv := .f.
EndIf
If len(a060SrvcTipoSer) <= 0
	aadd(a060SrvcTipoSer,{.t.,space(4),""}) // Tipo de Servico
	lTemSrv := .f.
EndIf
If len(a060SrvcClasHab) <= 0
	aadd(a060SrvcClasHab,{.t.,Space(1),Space(15),0,0,0}) // ClassificaÁ„o da Habilidade
EndIf
//
If len(a060Psa) <= 0
	aAdd(a060Psa,{ 	"" , "" , "" , "" , "" , "" , ctod("") , 0 , "" , "" }) // Pausas Servicos
	lTemPsa := .f.
EndIf
//
If len(a060Orc) <= 0
	aadd(a060Orc,{"",Ctod(""),"",""}) // Orcamentos
	lTemOrc := .f.
EndIf
//
If len(a060Pen) <= 0
	aadd(a060Pen,{"","","","","","","","","","",""}) // PeÁas Pendentes
	lTemPen := .f.
EndIf
//
aSort(a060Res,,,{|x,y| x[10]+x[4]+x[5] < y[10]+y[4]+y[5] })
//
OC060_ALB(.f.) // Atualizar ListBox de Pecas e Servicos
//
Return()


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ OC060_TIK∫ Autor ≥ Andre Luis Almeida ∫ Data ≥  16/05/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Tik na Linha ou no vetor total do Listbox                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OC060_TIK(cTp,cVetLb,cObjLb,cTik)
Local ni   := 0
Local lTik := .t.
Default cTik      := ".t."
If cTp == "1" // Tik na linha
	&(cVetLb+"["+cObjLb+":nAt,1]") := &("!"+cVetLb+"["+cObjLb+":nAt,1]") // Alterar linha do vetor do listbox
Else // Tik TOTAL
	lTik := &(cTik) // Pegar se a variavel do listbox esta .t. ou .f.
	lTik := !lTik   // Inverter .t. ou .f.
	For ni := 1 to len(&(cVetLb))
		&(cVetLb+"["+Alltrim(str(ni))+",1]") := lTik // Alterar linha do vetor do listbox
	Next
	&(cTik) := lTik    // Atribuir .t. ou .f. para a variavel do listbox
EndIf
&(cObjLb+":Refresh()") // Refresh no ListBox de Pecas ou Servicos
//
OC060_ALB(.t.) // Atualizar ListBox de Pecas e Servicos
//
Return()


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ OC060_ALB∫ Autor ≥ Andre Luis Almeida ∫ Data ≥  16/05/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Atualiza na TELA os ListBox de Pecas e Servicos            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OC060_ALB(lRefresh) // Atualizar ListBox de Pecas e Servicos
Local nVlrPec := 0 // Valor Bruto de Peca
Local nVlrDes := 0 // Valor Desconto Peca
Local nVlrSrv := 0 // Valor Servico
Local nPos    := 0
Local nPosTT   := 0
Local nPosInconv   := 0
Local nPosGrupo   := 0
Local ni      := 0
Local nj      := 0
Local cTXT1   := ""
Local cTXT2   := ""
Local cTXT3   := ""
Local cTXT4   := ""
Local cTXT5   := ""
Local cTXT6   := ""
Local cCompara:= ""
Local oAux
Local cStatusTT := ""
Local lIncPec := lInconveniente
Local lIncSrv := lInconveniente
Local cAuxCod  := ""
Local cAuxNome := ""
//
If lInconveniente
	// Verificar se existe Inconveniente para Pecas
	lIncPec := ( len(a060PecaInconv) > 1 .or. ( len(a060PecaInconv) == 1 .and. !Empty(a060PecaInconv[1,2]+a060PecaInconv[1,3]) ) )
	// Verificar se existe Inconveniente para Servicos
	lIncSrv := ( len(a060SrvcInconv) > 1 .or. ( len(a060SrvcInconv) == 1 .and. !Empty(a060SrvcInconv[1,2]+a060SrvcInconv[1,3]) ) )
EndIf
//
a060SrvcClasHab := {} // ClassificaÁ„o da Habilidade
a060Peca := {}
//
nI := OC060AddPeca()
a060Peca[ nI , 01 ] := STR0044 // TOTAL - 1 - Tipo de Tempo 
a060Peca[ nI , 29 ] := oNada
//
For ni := 1 to len(a060TPC)
	/////////////////////////////
    // Verificar Tipo de Tempo //
	/////////////////////////////
	nPosTT := Ascan( a060PecaTT , {|x| x[2] == a060TPC[ni,PECA_TIPTEM] })
	If nPosTT <= 0 .or. !a060PecaTT[nPosTT,1]
		Loop
	EndIf
	/////////////////////////////
    // Verificar Inconveniente //
	/////////////////////////////
	nPosInconv := Ascan( a060PecaInconv , {|x| x[2] == a060TPC[ni,PECA_INCONV_GRUPO]+" "+a060TPC[ni,PECA_INCONV_CODIGO]+" "+a060TPC[ni,PECA_INCONV_SEQ] })
	If nPosInconv <= 0 .or. !a060PecaInconv[nPosInconv,1]
		Loop
	EndIf
	/////////////////////////////
    // Verificar Grupo Pecas   //
	/////////////////////////////
	nPosGrupo := Ascan( a060PecaGrp , {|x| x[2] == a060TPC[ni,PECA_GRUITE] })
	If nPosGrupo <= 0 .or. !a060PecaGrp[nPosGrupo,1]
		Loop
	EndIf
	//
	nVlrPec := a060TPC[ni,PECA_VALBRU] // Valor Bruto Peca
	nVlrDes := a060TPC[ni,PECA_VALDES] // Desconto
	OC060Cor( @nVlrPec , @nVlrDes , @cStatusTT, @oCor , a060TPC[ni,PECA_DATCAN] , a060TPC[ni,PECA_DATFEC] , a060TPC[ni,PECA_DATLIB] )
	//
	a060Peca[1,12] += nVlrPec // TOTAL GERAL - Valor Bruto
	a060Peca[1,13] += nVlrDes // TOTAL GERAL - Desconto
	a060Peca[1,14] += ( nVlrPec - nVlrDes ) // TOTAL GERAL - Valor Liquido
	//
	// Executa 3 vezes, sendo:
	// 1™ - Verifica se existe uma linha com o Tipo de Tempo
	// 2™ - Verifica se existe uma linha com o Inconveniente
	// 3™ - Verifica se existe a linha com o grupo de produto 
	For nj := 1 to 3
		nPos  := 0
		cTXT1 := a060PecaTT[nPosTT,2]	// 1 - Tipo de Tempo 
		cTXT2 := a060PecaTT[nPosTT,3]	// 2 - Descricao Tipo de Tempo
		cTXT3 := space(16)			// 3 - Inconveniente
		cTXT4 := ""					// 4 - Descricao Inconveniente
		cTXT5 := space(4)			// 5 - Grupo 
		cTXT6 := ""		 			// 6 - Descricao Grupo
		If nj == 1
			nPos  := Ascan(a060Peca,{|x| x[28]+x[1]+x[32] == "1"+a060PecaTT[nPosTT,2]+a060TPC[ni,PECA_STATUS] })
			oAux := oCor
		ElseIf nj == 2
			If !lIncPec
				Loop
			EndIf
			nPos  := Ascan(a060Peca,{|x| x[28]+x[1]+x[32]+x[3] == "2"+a060PecaTT[nPosTT,2]+a060TPC[ni,PECA_STATUS]+a060PecaInconv[nPosInconv,2] })
			cTXT3 := a060PecaInconv[nPosInconv,2] // 3 - Inconveniente
			cTXT4 := a060PecaInconv[nPosInconv,3] // 4 - Descricao Inconveniente
			oAux := oNada
		Else // nj == 3
			nPos  := Ascan(a060Peca,{|x| x[28]+x[1]+x[32]+x[3]+x[5] == "3"+a060PecaTT[nPosTT,2]+a060TPC[ni,PECA_STATUS]+a060PecaInconv[nPosInconv,2]+a060PecaGrp[nPosGrupo,2] })
			cTXT3 := a060PecaInconv[nPosInconv,2] // 3 - Inconveniente
			cTXT4 := a060PecaInconv[nPosInconv,3] // 4 - Descricao Inconveniente
			cTXT5 := a060PecaGrp[nPosGrupo,2] // 5 - Grupo 
			cTXT6 := a060PecaGrp[nPosGrupo,3] // 6 - Descricao Grupo
			oAux := oNada
		EndIf
		If nPos <= 0
			nPos := OC060AddPeca()
			a060Peca[ nPos , 01 ] := cTXT1 // 1 - Tipo de Tempo 
			a060Peca[ nPos , 02 ] := cTXT2 // 2 - Descricao Tipo de Tempo
			a060Peca[ nPos , 03 ] := cTXT3 // 3 - Inconveniente
			a060Peca[ nPos , 04 ] := cTXT4 // 4 - Descricao Inconveniente
			a060Peca[ nPos , 05 ] := cTXT5 // 5 - Grupo 
			a060Peca[ nPos , 06 ] := cTXT6 // 6 - Descricao Grupo
			a060Peca[ nPos , 28 ] := strzero(nj,1) // 28 - 1 = 1o.Agrupador / 2 = 2o.Agrupador / 3 = 3o.Agrupador / 4 = 4o.Agrupador / 5 = Analitico
			a060Peca[ nPos , 29 ] := oAux // 29
			a060Peca[ nPos , 32 ] := a060TPC[nI,PECA_STATUS]
		EndIf
		a060Peca[nPos,12] += nVlrPec // Valor Bruto
		a060Peca[nPos,13] += nVlrDes // Desconto
		a060Peca[nPos,14] += ( nVlrPec - nVlrDes ) // Valor Liquido
	Next
	//
	// Pesquisa por 
	// 28 - 1 = 1o.Agrupador / 2 = 2o.Agrupador / 3 = 3o.Agrupador / 4 = 4o.Agrupador / 5 = Analitico
	// 1 - Tipo de Tempo 
	// 3 - Inconveniente
	// 5 - Grupo 
	// 7 - CodIte da Peca
	nPos := Ascan(a060Peca,{|x| x[28]+x[1]+x[3]+x[5]+x[7]+StrZero(x[31],10) == "4"+a060PecaTT[nPosTT,2]+a060PecaInconv[nPosInconv,2]+a060PecaGrp[nPosGrupo,2]+a060TPC[ni,PECA_CODITE]+strzero(ni,10) })
	If nPos <= 0
		If lVO3_FUNDIS
			If cAuxCod <> a060TPC[ni, 47]
				cAuxCod  := a060TPC[ni, 47]
				cAuxNome := Left(OC060NomTec(a060TPC[ni, 47] ), 15)
			EndIf
		EndIf

		nPos := OC060AddPeca()
		a060Peca[ nPos , 01 ] := a060PecaTT[nPosTT,2]         // 01 - Tipo de Tempo 
		a060Peca[ nPos , 02 ] := a060PecaTT[nPosTT,3]         // 02 - Descricao Tipo de Tempo
		a060Peca[ nPos , 03 ] := a060PecaInconv[nPosInconv,2] // 03 - Inconveniente
		a060Peca[ nPos , 04 ] := a060PecaInconv[nPosInconv,3] // 04 - Descricao Inconveniente
		a060Peca[ nPos , 05 ] := a060PecaGrp[nPosGrupo,2]     // 05 - Grupo 
		a060Peca[ nPos , 06 ] := a060PecaGrp[nPosGrupo,3]     // 06 - Descricao Grupo
		a060Peca[ nPos , 07 ] := a060TPC[ni,PECA_CODITE]      // 07 - CodIte da Peca
		a060Peca[ nPos , 08 ] := a060TPC[ni,PECA_DESCRICAO]   // 08 - Descricao Peca
		a060Peca[ nPos , 11 ] := a060TPC[ni,PECA_QTDREQ]      // 11 - Qtde 
		a060Peca[ nPos , 20 ] := a060TPC[ni,PECA_DATLIB]      // 20 - Data Liberacao
		a060Peca[ nPos , 21 ] := a060TPC[ni,PECA_DATFEC]      // 21 - Data Fechamento
		a060Peca[ nPos , 22 ] := a060TPC[ni,PECA_NUMNFI]      // 22 - NF
		a060Peca[ nPos , 23 ] := a060TPC[ni,PECA_SERNFI]      // 23 - Serie
		a060Peca[ nPos , 24 ] := a060TPC[ni,PECA_FUNFEC]      // 24 - Funcionario Fechamento
		a060Peca[ nPos , 25 ] := Left(OC060NomTec( a060TPC[ni,PECA_FUNFEC] ),15) // 25 - Nome Funcionario Fechamento
		a060Peca[ nPos , 28 ] := "4"                          // 28 - 1 = 1o.Agrupador / 2 = 2o.Agrupador / 3 = 3o.Agrupador / 4 = 4o.Agrupador / 5 = Analitico
		a060Peca[ nPos , 30 ] := a060TPC[ni,PECA_LIBVOO]      // 30 - Numero da liberacao do tipo de tempo 
		a060Peca[ nPos , 31 ] := ni                           // 31 - Posicao da matriz de retorno da FMX_CALPEC
		a060Peca[ nPos , 33 ] := a060TPC[ni,PECA_LOTECT]      // 33 - Lote
		a060Peca[ nPos , 34 ] := a060TPC[ni,PECA_NUMLOT]      // 33 - Sub-Lote
		a060Peca[ nPos , 35 ] := cAuxCod		              // 35 - Funcionario Liberacao
		a060Peca[ nPos , 36 ] := cAuxNome                     // 36 - Nome Funcionario Liberacao
	EndIf
	a060Peca[nPos,12] += nVlrPec // Valor Bruto
	a060Peca[nPos,13] += nVlrDes // Desconto
	a060Peca[nPos,14] += ( nVlrPec - nVlrDes ) // Valor Liquido
	//
	For nj := 1 to len(a060TPC[ni,PECA_MOV]) // Requisicoes / Devolucoes
		nPos := OC060AddPeca()
		a060Peca[ nPos , 01 ] := a060PecaTT[nPosTT,2] // 1 - Tipo de Tempo 
		a060Peca[ nPos , 02 ] := a060PecaTT[nPosTT,3] // 2 - Descricao Tipo de Tempo
		a060Peca[ nPos , 03 ] := a060PecaInconv[nPosInconv,2] // 3 - Inconveniente
		a060Peca[ nPos , 04 ] := a060PecaInconv[nPosInconv,3] // 4 - Descricao Inconveniente
		a060Peca[ nPos , 05 ] := a060PecaGrp[nPosGrupo,2] // 5 - Grupo 
		a060Peca[ nPos , 06 ] := a060PecaGrp[nPosGrupo,3] // 6 - Descricao Grupo
		a060Peca[ nPos , 09 ] := a060TPC[ni,PECA_MOV,nj,PECA_MOV_DATREQ] // 9 - Data Movimento
		a060Peca[ nPos , 10 ] := a060TPC[ni,PECA_MOV,nj,PECA_MOV_REQDEV] // 10 - Req/Dev
		a060Peca[ nPos , 11 ] := IIf(a060TPC[ni,PECA_MOV,nj,PECA_MOV_REQDEV]=="1",1,-1)*a060TPC[ni,PECA_MOV,nj,PECA_MOV_QTDREQ] // 11 - Qtde 
		a060Peca[ nPos , 12 ] := IIf(a060TPC[ni,PECA_MOV,nj,PECA_MOV_REQDEV]=="1",1,-1)*(a060TPC[ni,PECA_MOV,nj,PECA_MOV_VALPEC]*a060TPC[ni,PECA_MOV,nj,PECA_MOV_QTDREQ]) // 12 - Valor Bruto
		a060Peca[ nPos , 15 ] := a060TPC[ni,PECA_MOV,nj,PECA_MOV_PROREQ] // 15 - Produtivo
		a060Peca[ nPos , 16 ] := left( OC060NomTec(a060TPC[ni,PECA_MOV,nj,PECA_MOV_PROREQ]),15) // 16 - Nome Produtivo
		a060Peca[ nPos , 26 ] := a060TPC[ni,PECA_MOV,nj,PECA_MOV_FUNREQ] // 26 - Funcionario Requisicao
		a060Peca[ nPos , 27 ] := left( OC060NomTec(a060TPC[ni,PECA_MOV,nj,PECA_MOV_FUNREQ]),15) // 27 - Nome Funcionario Requisicao
		a060Peca[ nPos , 28 ] := "5" // 28 - 1 = 1o.Agrupador / 2 = 2o.Agrupador / 3 = 3o.Agrupador / 4 = 4o.Agrupador / 5 = Analitico
		a060Peca[ nPos , 31 ] := ni  // 31 - Posicao da matriz de retorno da FMX_CALPEC
	Next
Next
//
a060Srvc := {}
nI := OC060AddSrvc()
a060Srvc[ nI, 1 ] := STR0044 // TOTAL - 1 - Tipo de Tempo
For ni := 1 to len(a060TSC)
	/////////////////////////////
    // Verificar Tipo de Tempo //
	/////////////////////////////
	nPosTT := Ascan( a060SrvcTT , {|x| x[2] == a060TSC[ni,SRVC_TIPTEM] })
	If nPosTT <= 0 .or. !a060SrvcTT[nPosTT,1]
		Loop
	EndIf
	/////////////////////////////
    // Verificar Inconveniente //
	/////////////////////////////
	nPosInconv := Ascan( a060SrvcInconv , {|x| x[2] == a060TSC[ni,SRVC_INCONV_GRUPO]+" "+a060TSC[ni,SRVC_INCONV_CODIGO]+" "+a060TSC[ni,SRVC_INCONV_SEQ] })
	If nPosInconv <= 0 .or. !a060SrvcInconv[nPosInconv,1]
		Loop
	EndIf
	/////////////////////////////
	// Verificar Tipo Servico  //
	/////////////////////////////
	nPosGrupo := Ascan( a060SrvcTipoSer , {|x| x[2] == a060TSC[ni,SRVC_TIPSER] })
	If nPosGrupo <= 0 .or. !a060SrvcTipoSer[nPosGrupo,1]
		Loop
	EndIf
	//
	nVlrSrv := a060TSC[ni,SRVC_VALLIQ] // Valor Servico
	nVlrDes := 0
	OC060Cor( @nVlrSrv , @nVlrDes , @cStatusTT, @oCor , a060TSC[ni,SRVC_DATCAN] , a060TSC[ni,SRVC_DATFEC] , a060TSC[ni,SRVC_DATLIB] )
	//
	a060Srvc[1,13] += nVlrSrv // TOTAL GERAL
	a060Srvc[1,09] += a060TSC[ni,SRVC_TEMPAD] // 9 - Tempo Padrao
	a060Srvc[1,10] += a060TSC[ni,SRVC_TEMTRA] // 10 - Tempo Trabalhado
	a060Srvc[1,11] += a060TSC[ni,SRVC_TEMCOB] // 11 - Tempo Cobrado
	a060Srvc[1,12] += a060TSC[ni,SRVC_TEMVEN] // 12 - Tempo Vendido
	a060Srvc[1,31] += a060TSC[ni,SRVC_VALCUS] // 31 - Valor do Custo (quanto ServiÁo de Terceiros)
	//
	For nj := 1 to 3
		nPos  := 0
		cTXT1 := a060SrvcTT[nPosTT,2]	// 1 - Tipo de Tempo 
		cTXT2 := a060SrvcTT[nPosTT,3]	// 2 - Descricao Tipo de Tempo
		cTXT3 := space(16)			// 3 - Inconveniente
		cTXT4 := ""					// 4 - Descricao Inconveniente
		cTXT5 := space(4)			// 5 - Tipo de Servico
		cTXT6 := ""		 			// 6 - Descricao Tipo de Servico
		If nj == 1
			nPos := Ascan(a060Srvc,{|x| x[34]+x[1]+x[38] == "1"+a060SrvcTT[nPosTT,2]+a060TSC[ni,SRVC_STATUS] })
			oAux := oCor
		ElseIf nj == 2
			If !lIncSrv
				Loop
			EndIf
			nPos  := Ascan(a060Srvc,{|x| x[34]+x[1]+x[3] == "2"+a060SrvcTT[nPosTT,2]+a060SrvcInconv[nPosInconv,2] })
			cTXT3 := a060SrvcInconv[nPosInconv,2] // 3 - Inconveniente
			cTXT4 := a060SrvcInconv[nPosInconv,3] // 4 - Descricao Inconveniente
			oAux := oNada
		Else // nj == 3
			nPos := Ascan(a060Srvc,{|x| x[34]+x[1]+x[3]+x[5] == "3"+a060SrvcTT[nPosTT,2]+a060SrvcInconv[nPosInconv,2]+a060SrvcTipoSer[nPosGrupo,2] })
			cTXT3 := a060SrvcInconv[nPosInconv,2] // 3 - Inconveniente
			cTXT4 := a060SrvcInconv[nPosInconv,3] // 4 - Descricao Inconveniente
			cTXT5 := a060SrvcTipoSer[nPosGrupo,2] // 5 - Tipo de Servico
			cTXT6 := a060SrvcTipoSer[nPosGrupo,3] // 6 - Descricao Tipo de Servico
			oAux := oNada
		EndIf
		If nPos <= 0
			nPos := OC060AddSrvc()
			a060Srvc[ nPos , 01 ] := cTXT1 // 1 - Tipo de Tempo 
			a060Srvc[ nPos , 02 ] := cTXT2 // 2 - Descricao Tipo de Tempo
			a060Srvc[ nPos , 03 ] := cTXT3 // 3 - Inconveniente
			a060Srvc[ nPos , 04 ] := cTXT4 // 4 - Descricao Inconveniente
			a060Srvc[ nPos , 05 ] := cTXT5 // 5 - Tipo de Servico
			a060Srvc[ nPos , 06 ] := cTXT6 // 6 - Descricao Tipo de Servico
			a060Srvc[ nPos , 34 ] := strzero(nj,1) // 34 - 1 = 1o.Agrupador / 2 = 2o.Agrupador / 3 = 3o.Agrupador / 4 = 4o.Agrupador / 5 = Analitico
			a060Srvc[ nPos , 35 ] := oAux
			a060Srvc[ nPos , 38 ] := a060TSC[ni,SRVC_STATUS]
		EndIf
		a060Srvc[nPos,13] += nVlrSrv
		a060Srvc[nPos,09] += a060TSC[ni,SRVC_TEMPAD] // 9 - Tempo Padrao
		a060Srvc[nPos,10] += a060TSC[ni,SRVC_TEMTRA] // 10 - Tempo Trabalhado
		a060Srvc[nPos,11] += a060TSC[ni,SRVC_TEMCOB] // 11 - Tempo Cobrado
		a060Srvc[nPos,12] += a060TSC[ni,SRVC_TEMVEN] // 12 - Tempo Vendido
		a060Srvc[nPos,31] += a060TSC[ni,SRVC_VALCUS] // 31 - Valor do Custo do serviÁo de Terceiros
	Next
	//
	nPos := Ascan(a060Srvc,{|x| x[34]+x[1]+x[3]+x[5]+x[7] == "4"+a060SrvcTT[nPosTT,2]+a060SrvcInconv[nPosInconv,2]+a060SrvcTipoSer[nPosGrupo,2]+a060TSC[ni,SRVC_CODSER] })
	If nPos <= 0
		If lVO4_FUNDIS
			If cAuxCod <> a060TSC[ni, 54]
				cAuxCod  := a060TSC[ni, 54]
				cAuxNome := Left(OC060NomTec(a060TSC[ni, 54]), 15)
			EndIf
		EndIf

		nPos := OC060AddSrvc()
		a060Srvc[ nPos , 01 ] := a060SrvcTT[nPosTT,2]  // 1 - Tipo de Tempo 
		a060Srvc[ nPos , 02 ] := a060SrvcTT[nPosTT,3]  // 2 - Descricao Tipo de Tempo
		a060Srvc[ nPos , 03 ] := a060SrvcInconv[nPosInconv,2]  // 3 - Inconveniente
		a060Srvc[ nPos , 04 ] := a060SrvcInconv[nPosInconv,3]  // 4 - Descricao Inconveniente
		a060Srvc[ nPos , 05 ] := a060SrvcTipoSer[nPosGrupo,2]  // 5 - Tipo de Servico
		a060Srvc[ nPos , 06 ] := a060SrvcTipoSer[nPosGrupo,3]  // 6 - Descricao Tipo de Servico
		a060Srvc[ nPos , 07 ] := a060TSC[ni,SRVC_CODSER]  // 7 - Codigo Servico
		a060Srvc[ nPos , 08 ] := a060TSC[ni,SRVC_DESCRICAO]  // 8 - Descricao Servico
		a060Srvc[ nPos , 09 ] := a060TSC[ni,SRVC_TEMPAD]  // 9 - Tempo Padrao
		a060Srvc[ nPos , 12 ] := a060TSC[ni,SRVC_TEMVEN]  // 12 - Tempo Vendido
		a060Srvc[ nPos , 23 ] := a060TSC[ni,SRVC_CODSEC]+" "+left(FM_SQL("SELECT VOD_DESSEC FROM "+RetSqlName("VOD")+" WHERE VOD_FILIAL='"+xFilial("VOD")+"' AND VOD_CODSEC='"+a060TSC[ni,SRVC_CODSEC]+"' AND D_E_L_E_T_=' '"),15)  // 23 - Secao Oficina
		a060Srvc[ nPos , 24 ] := a060TSC[ni,SRVC_DATLIB]  // 24 - Data Liberacao
		a060Srvc[ nPos , 25 ] := a060TSC[ni,SRVC_DATFEC]  // 25 - Data Fechamento
		a060Srvc[ nPos , 26 ] := a060TSC[ni,SRVC_NUMNFI]  // 26 - NF
		a060Srvc[ nPos , 27 ] := a060TSC[ni,SRVC_SERNFI]  // 27 - Serie
		a060Srvc[ nPos , 28 ] := a060TSC[ni,SRVC_FUNFEC]  // 28 - Funcionario Fechamento
		a060Srvc[ nPos , 29 ] := Left(OC060NomTec(a060TSC[ni,SRVC_FUNFEC]),15)  // 29 - Nome Funcionario Fechamento
		a060Srvc[ nPos , 31 ] := a060TSC[ni,SRVC_VALCUS]  // 31 - Valor do Custo
		a060Srvc[ nPos , 32 ] := a060TSC[ni,SRVC_DATPAG]  // 32 - Data Pagamento
		a060Srvc[ nPos , 33 ] := a060TSC[ni,SRVC_NUMTIT]+" "+a060TSC[ni,SRVC_TIPTIT]  // 33 - Nro Docto
		a060Srvc[ nPos , 34 ] := "4" // 34 - 1 = 1o.Agrupador / 2 = 2o.Agrupador / 3 = 3o.Agrupador / 4 = 4o.Agrupador / 5 = Analitico
		a060Srvc[ nPos , 35 ] := oNada
		a060Srvc[ nPos , 36 ] := a060TSC[ni,SRVC_LIBVOO]  // 36 - Numero da Liberacao
		a060Srvc[ nPos , 37 ] := a060TSC[ni,SRVC_GRUSER]  // 37 - Grupo de Servico
		a060Srvc[ nPos , 39 ] := cAuxCod				  // 39 - Codigo Funcionario Liberacao
		a060Srvc[ nPos , 40 ] := cAuxNome				  // 40 - Nome Funcionario Liberacao
	EndIf
	a060Srvc[nPos,13] += nVlrSrv
	a060Srvc[nPos,10] += a060TSC[ni,SRVC_TEMTRA] // 10 - Tempo Trabalhado
	a060Srvc[nPos,11] += a060TSC[ni,SRVC_TEMCOB] // 11 - Tempo Cobrado
	//
	For nj := 1 to len(a060TSC[ni,SRVC_APONT]) // Apontamentos
		nPos := OC060AddSrvc()
		a060Srvc[ nPos , 01 ] := a060SrvcTT[nPosTT,2]  // 1 - Tipo de Tempo 
		a060Srvc[ nPos , 02 ] := a060SrvcTT[nPosTT,3]  // 2 - Descricao Tipo de Tempo
		a060Srvc[ nPos , 03 ] := a060SrvcInconv[nPosInconv,2]  // 3 - Inconveniente
		a060Srvc[ nPos , 04 ] := a060SrvcInconv[nPosInconv,3]  // 4 - Descricao Inconveniente
		a060Srvc[ nPos , 05 ] := a060SrvcTipoSer[nPosGrupo,2]  // 5 - Tipo de Servico
		a060Srvc[ nPos , 06 ] := a060SrvcTipoSer[nPosGrupo,3]  // 6 - Descricao Tipo de Servico
		a060Srvc[ nPos , 10 ] := a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_TEMTRA]  // 10 - Tempo Trabalhado
		a060Srvc[ nPos , 11 ] := a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_TEMCOB]  // 11 - Tempo Cobrado
		a060Srvc[ nPos , 12 ] := a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_TEMVEN]  // 12 - Tempo Vendido
		a060Srvc[ nPos , 13 ] := a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_VALLIQ]  // 13 - Valor
		a060Srvc[ nPos , 17 ] := a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_DATINI]  // 17 - Data Inicial
		a060Srvc[ nPos , 18 ] := a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_HORINI]  // 18 - Hora Inicial
		a060Srvc[ nPos , 19 ] := a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_DATFIN]  // 19 - Data Final
		a060Srvc[ nPos , 20 ] := a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_HOTFIN]  // 20 - Hora Final
		a060Srvc[ nPos , 21 ] := a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_CODIGO]  // 21 - Produtivo
		a060Srvc[ nPos , 22 ] := a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_NOME]    // 22 - Nome Produtivo
		a060Srvc[ nPos , 30 ] := IIf(!Empty(a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_CODFOR]),a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_CODFOR]+"-"+a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_FOLOJA]+" "+FM_SQL("SELECT A2_NOME FROM "+RetSqlName("SA2")+" WHERE A2_FILIAL='"+xFilial("SA2")+"' AND A2_COD='"+a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_CODFOR]+"' AND A2_LOJA='"+a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_FOLOJA]+"' AND D_E_L_E_T_=' '"),"")  // 30 - Fornecedor
		a060Srvc[ nPos , 31 ] := a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_VALCUS]   // 31 - Valor do Custo
		a060Srvc[ nPos , 32 ] := a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_DATPAG]  // 32 - Data Pagamento
		a060Srvc[ nPos , 33 ] := a060TSC[ni,SRVC_APONT,nj,SRVC_APONT_NUMTIT]  // 33 - Nro Docto
		a060Srvc[ nPos , 34 ] := "5" // 34 - 1 = 1o.Agrupador / 2 = 2o.Agrupador / 3 = 3o.Agrupador / 4 = 4o.Agrupador / 5 = Analitico

		//
		OC060_ClaHab( a060TSC[ni,SRVC_APONT,nj] )
		//

	Next
Next
//
If lRefresh
	If lTemPec
		oLbPLPc:nAT := 1
		oLbPLPc:SetArray(a060Peca)
		oLbPLPc:Refresh()
	EndIf
	//
	If lTemSrv
		oLbPLSv:nAt := 1
		oLbPLSv:SetArray(a060Srvc)
		oLbPLSv:Refresh()
		If lVAICLAHAB
			oLbPLTSCH:SetArray(a060SrvcClasHab)
			oLbPLTSCH:bLine := { || { a060SrvcClasHab[oLbPLTSCH:nAt,3] , IIf(!Empty(a060SrvcClasHab[oLbPLTSCH:nAt,4]),Transform(a060SrvcClasHab[oLbPLTSCH:nAt,4],"@R 9999:99"),""), IIf(!Empty(a060SrvcClasHab[oLbPLTSCH:nAt,5]),Transform(a060SrvcClasHab[oLbPLTSCH:nAt,5],"@R 9999:99"),"") , IIf(!Empty(a060SrvcClasHab[oLbPLTSCH:nAt,6]),Transform(a060SrvcClasHab[oLbPLTSCH:nAt,6],"@R 9999:99"),"") }}
			oLbPLTSCH:Refresh()
		EndIf
	EndIf
EndIf
//
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ OC060AddPeca ∫ Autor ≥ Rubens Takahashi∫ Data ≥  10/04/15  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Adiciona uma linha na matriz de peca                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OC060AddPeca()

Aadd(a060Peca,{ ;
	"" ,; // TOTAL - 1 - Tipo de Tempo 
	"" ,; // 2 - Descricao Tipo de Tempo
	space(16) ,; // 3 - Inconveniente
	"" ,; // 4 - Descricao Inconveniente
	space(4) ,; // 5 - Grupo 
	"" ,; // 6 - Descricao Grupo
	"" ,; // 7 - CodIte da Peca
	"" ,; // 8 - Descricao Peca
	ctod("") ,; // 9 - Data Movimento
	"" ,; // 10 - Req/Dev
	0  ,; // 11 - Qtde 
	0  ,; // 12 - Valor Bruto
	0  ,; // 13 - Desconto
	0  ,; // 14 - Valor Liquido
	"" ,; // 15 - Produtivo
	"" ,; // 16 - Nome Produtivo
	"" ,; // 17 - Codigo Faturar para
	"" ,; // 18 - Loja Faturar para
	"" ,; // 19 - Nome Faturar para
	ctod("") ,; // 20 - Data Liberacao
	ctod("") ,; // 21 - Data Fechamento
	"" ,; // 22 - NF
	"" ,; // 23 - Serie
	"" ,; // 24 - Funcionario Fechamento
	"" ,; // 25 - Nome Funcionario Fechamento
	"" ,; // 26 - Funcionario Requisicao
	"" ,; // 27 - Nome Funcionario Requisicao
	"1",; // 28 - 1 = 1o.Agrupador / 2 = 2o.Agrupador / 3 = 3o.Agrupador / 4 = 4o.Agrupador / 5 = Analitico
	oNada,;
	"",;  // 30 - Numero da liberacao do tipo de tempo 
	0,;  // 31 - Posicao da matriz de retorno da FMX_CALPEC
	"",;  // 32 - Status do Tipo de Tempo
	"",;  // 33 - Lote
	"",;  // 34 - Sub-Lote
	"",;  // 35 - Codigo Funcionario Liberacao
	""})  // 36 - Nome Funcionario Liberacao

Return Len(a060Peca)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ OC060AddSrvc ∫ Autor ≥ Rubens Takahashi∫ Data ≥  10/04/15  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Adiciona uma linha na matriz de Servicos                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OC060AddSrvc()

Aadd(a060Srvc,{;
	"" ,; // TOTAL - 1 - Tipo de Tempo
	"" ,; // 2 - Descricao Tipo de Tempo
	space(16) ,; // 3 - Inconveniente
	"" ,; // 4 - Descricao Inconveniente
	space(4) ,; // 5 - Tipo de Servico
	"" ,; // 6 - Descricao Tipo de Servico
	"" ,; // 7 - Codigo Servico
	"" ,; // 8 - Descricao Servico
	0  ,; // 9 - Tempo Padrao
	0  ,; // 10 - Tempo Trabalhado
	0  ,; // 11 - Tempo Cobrado
	0  ,; // 12 - Tempo Vendido
	0  ,; // 13 - Valor
	"" ,; // 14 - Codigo Faturar para
	"" ,; // 15 - Loja Faturar para
	"" ,; // 16 - Nome Faturar para
	ctod("") ,; // 17 - Data Inicial
	0  ,; // 18 - Hora Inicial
	ctod("") ,; // 19 - Data Final
	0  ,; // 20 - Hora Final
	"" ,; // 21 - Produtivo
	"" ,; // 22 - Nome Produtivo
	"" ,; // 23 - Secao Oficina
	ctod("") ,; // 24 - Data Liberacao
	ctod("") ,; // 25 - Data Fechamento
	"" ,; // 26 - NF
	"" ,; // 27 - Serie
	"" ,; // 28 - Funcionario Fechamento
	"" ,; // 29 - Nome Funcionario Fechamento
	"" ,; // 30 - Fornecedor
	0  ,; // 31 - Valor do Custo
	ctod("") ,; // 32 - Data Pagamento
	"" ,; // 33 - Nro Docto
	"1",; // 34 - 1 = 1o.Agrupador / 2 = 2o.Agrupador / 3 = 3o.Agrupador / 4 = 4o.Agrupador / 5 = Analitico
	oNada,;
	"" ,; // 36 - Numero da Liberacao
	"" ,; // 37 - Grupo de Servico
	"" ,; // 38 - Status do tipo de tempo
	"" ,; // 39 - Codigo Funcionario Liberacao
	"" }) // 40 - Nome Funcionario Liberacao

Return Len(a060Srvc)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ OC060_ORC∫ Autor ≥ Manoel             ∫ Data ≥  10/01/11   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Visualiza Orcamento                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OC060_ORC()
If !Empty(a060Orc[oLb060Orc:nAt,01])
	dbSelectArea("VS1")
	dbSetOrder(1)
	if dbSeek(xFilial("VS1")+a060Orc[oLb060Orc:nAt,01])
		OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
	Endif
Endif
DbSelectArea("VO1")
Return(.t.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ OC060LEG ∫ Autor ≥ Fabio              ∫ Data ≥  12/17/01   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Legenda da Mbrowse / Tela                                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OC060LEG()

Local aLegenda := {	{ 'BR_VERDE'   , STR0045 } ,;  // Aberta
					{ 'BR_AZUL'    , STR0046 } ,;  // Liberada
					{ 'BR_VERMELHO', STR0047 } ,;  // Fechada
					{ 'BR_PRETO'   , STR0048 } }   // Cancelada
BrwLegenda(cCadastro,STR0002,aLegenda)
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ MenuDef  ∫ Autor ≥ Fabio              ∫ Data ≥  08/03/00   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Monta aRotina ( MenuDef )                                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function MenuDef()
Local aRotina := { 	{ STR0049 , "axPesqui" , 0 , 1},;			// Pesquisar
					{ STR0050 , "OC060"    , 0 , 2},;			// Visualizar
					{ STR0051 , "OFIOC450" , 0 , 1},;			// Pesq.Avancada
					{ STR0002 , "OC060LEG" , 0 , 2,0,.f.} }	// Legenda
Return aRotina

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ OC060_NF ∫ Autor ≥ Andre Luis Almeida ∫ Data ≥  21/05/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Chama a Consulta de MATC090 (Notas Fiscais de Saida)       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OC060_NF(nPosClk,nPosCol,cParNF,cParSer)
If !("/" $ cParNF )
	If nPosClk == nPosCol .and. !Empty(cParNF+cParSer)
		DbSelectArea("SF2")
		DbSetOrder(1)
		If DbSeek(xFilial("SF2")+cParNF+cParSer)
			cAlias := "SF2"
			nReg   := SF2->(Recno())
			nOpc   := 2
			Mc090Visual(cAlias,nReg,nOpc)
		EndIf
		DbSelectArea("VO1")
	EndIf
EndIf
Return .t.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ OC060RESUMO ∫ Autor ≥ Rubens Takahashi∫ Data ≥  10/04/15   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Adiciona linha na matriz de resumo por Tipo de Tempo       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OC060RESUMO( cTipTem , lResumo , cStatusTT, oParamCor , cProcessa , aDadosPecaSrvc )

Local cChavePesq
Local cNota := ""

Local cCliente := ""
Local cLoja := ""

VOI->(DbSetOrder(1))
VOI->(MsSeek( xFilial("VOI") + cTipTem ))

If lResumo 
	cChavePesq := VOI->VOI_SITTPO + Space(TamSX3("VOI_TIPTEM")[1]) + Space(15)
Else
	cChavePesq := VOI->VOI_SITTPO + VOI->VOI_TIPTEM + PadR(cStatusTT,15," ")
EndIf

nPos := Ascan( a060Res , {|x| x[10] == cChavePesq })
If nPos <= 0
	If !lResumo
	
		cCliente := IIF( cProcessa == "PECA" , aDadosPecaSrvc[ PECA_CLIENTE ] , aDadosPecaSrvc[ SRVC_CLIENTE ] )
		cLoja    := IIF( cProcessa == "PECA" , aDadosPecaSrvc[ PECA_LOJA ]    , aDadosPecaSrvc[ SRVC_LOJA ] )
		
		SA1->(dbSetOrder(1))
		SA1->(MsSeek( xFilial("SA1") + cCliente + cLoja ))
		
		///////////////////////////
		// Selecao Tipo de Tempo //
		///////////////////////////
		If cProcessa == "PECA"
			If Ascan( a060PecaTT , {|x| x[2] == VOI->VOI_TIPTEM }) <= 0
				AADD(a060PecaTT,{.t.,VOI->VOI_TIPTEM,UPPER(VOI->VOI_DESTTE), cCliente + "-" + cLoja + " " + Left( SA1->A1_NOME , 30 )})
			EndIf
		Else
			If Ascan( a060SrvcTT , {|x| x[2] == VOI->VOI_TIPTEM }) <= 0
				AADD(a060SrvcTT,{.t.,VOI->VOI_TIPTEM,UPPER(VOI->VOI_DESTTE), cCliente + "-" + cLoja + " " + Left( SA1->A1_NOME , 30 )})
			EndIf
		EndIf
		//
	
	EndIf

	AADD(a060Res,{;
		oParamCor,;
		IIf( lResumo , Space(05)+UPPER(X3CBOXDESC("VOI_SITTPO",VOI->VOI_SITTPO)) , Space(10) + VOI->VOI_TIPTEM ) ,;
		IIf( lResumo , "" , VOI->VOI_DESTTE ) ,; // 03  -  Descricao do Tipo de Tempo
		IIf( lResumo , Space(TamSX3("A1_COD" )[1]) , cCliente ),; // 04 - Cliente
		IIf( lResumo , Space(TamSX3("A1_LOJA")[1]) , cLoja    ),; // 05 - Loja
		IIf( lResumo , Space(30) , Left( SA1->A1_NOME , 30 )),;
		0,;
		0,;
		0,;
		cChavePesq,;
		""}) // Numero da Nota Fiscal 
	nPos := len(a060Res)
EndIf

If !lResumo .and. cStatusTT == "FECHADO"
	If cProcessa == "PECA"
		cNota := aDadosPecaSrvc[ PECA_NUMNFI ] + "-" + aDadosPecaSrvc[ PECA_SERNFI ] + " - " + DtoC(aDadosPecaSrvc[ PECA_DATFEC ])
	Else
		cNota := aDadosPecaSrvc[ SRVC_NUMNFI ] + "-" + aDadosPecaSrvc[ SRVC_SERNFI ] + " - " + DtoC(aDadosPecaSrvc[ SRVC_DATFEC ])
	EndIf
	If At( cNota , a060Res[nPos,11] ) == 0
		a060Res[nPos,11] += cNota + " / " 
	EndIf
EndIf

Return nPos

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ OC060Cor     ∫ Autor ≥ Rubens Takahashi∫ Data ≥  10/04/15  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Verifica qual cor e valor sera exibido na tela             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OC060Cor( nVlrPec , nVlrDes , cStatusTT, oCor , dDatCan , dDatFec , dDatLib )
cStatusTT := "ABERTO"
oCor    := oVerd // Aberto
If !Empty(dDatCan)
	cStatusTT := "CANCELADO"
	nVlrPec := 0
	nVlrDes := 0
	oCor    := oPret // Cancelado
ElseIf !Empty(dDatFec)
	cStatusTT := "FECHADO"
	oCor    := oVerm // Fechado
ElseIf !Empty(dDatLib)
	cStatusTT := "LIBERADO"
	oCor    := oAzul // Liberado
EndIf

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ OC060NomTec  ∫ Autor ≥ Rubens Takahashi∫ Data ≥  10/04/15  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Retorna o Nome do Tecnico                                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OC060NomTec( cCodTec )
Local cRetorno := ""
VAI->(dbSetOrder(1))
If VAI->(MsSeek( xFilial("VAI") + cCodTec ))
	cRetorno := VAI->VAI_NOMTEC 
EndIf
Return cRetorno

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ OC060_ClaHab  ∫ Autor ≥ Manoel Filho   ∫ Data ≥  18/11/17  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ CriaÁ„o do Array com as ClassificaÁıes das Habilidades     ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function OC060_ClaHab( aParApont )
Local nPosCh
Local cDescClaHab
Local cClaHab
If !lVAICLAHAB
	Return
EndIf
cClaHab := Alltrim(aParApont[SRVC_APONT_CLAHAB])
nPosCh := Ascan( a060SrvcClasHab , {|x| x[2] == cClaHab })
If nPosCh == 0
		cDescClaHab := Left(OFIOA560DS('052',cClaHab),20)
		aadd(a060SrvcClasHab,{.t.,cClaHab ,;
				cDescClaHab ,;
				aParApont[SRVC_APONT_TEMTRA] ,;
				aParApont[SRVC_APONT_TEMCOB] ,;
				aParApont[SRVC_APONT_TEMVEN] })
Else
		a060SrvcClasHab[nPosCh,4] += aParApont[SRVC_APONT_TEMTRA]
		a060SrvcClasHab[nPosCh,5] += aParApont[SRVC_APONT_TEMCOB]
		a060SrvcClasHab[nPosCh,6] += aParApont[SRVC_APONT_TEMVEN]
EndIf

Return
