#INCLUDE "TMSA690.ch"
#INCLUDE "Protheus.ch"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

Static lTMA010His := ExistBlock("TMA010HIS")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA690   ºAutor  ³Rafael Quadrotti    º Data ³  06/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao de novas tabelas.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Function Tmsa690(cCatTab)

//-- Variaveis da tabela de origem
Local cTabOri   := Criavar("DT0_TABFRE",.F.)
Local cTipOri   := Criavar("DT0_TIPTAB",.F.)
Local cTipDOri  := Criavar("DT0_DESTIP",.F.)
Local cProdOri  := Criavar("B1_COD",.F.)
Local cProdDOri := Criavar("B1_DESC",.F.)
Local cProdAte  := Criavar("B1_COD",.F.)
Local cProdDAte := Criavar("B1_DESC",.F.)
Local cCdrOri   := Criavar("DT0_CDRORI",.F.)
Local cCdrDes   := Criavar("DT0_CDRDES",.F.)

//-- Variaveis da tabela de destino
Local cTabDest   := Criavar("DT0_TABFRE",.F.)
Local cTipDest   := Criavar("DT0_TIPTAB",.F.)
Local cTipDDest  := Criavar("DT0_DESTIP",.F.)
Local cProdDest  := Criavar("B1_COD",.F.)
Local cProdDDest := Criavar("B1_DESC",.F.)

//-- Variaveis de Objeto
Local oPanRodape
Local oChkPerc
Local oDlg

//-- Variaveis da tabela DY9
Local lExistDY9  := AliasInDic("DY9")

//-- Objetos para controle do tamanho de tela.
Local oSize
Local oSize2 
Local aScreenRes := getScreenRes()


Local nPosPerRea := 0
Local nPosPerMin := 0
Local nPosPerExc := 0
Local nPosDTKMax := 0
Local nPosDY1Min := 0
Local nPosDY1Max := 0

Local cF3Tab     := "DTL"
//-- lInfProd igual a .T. determina que a tabela destino sera gerada com o produto informado na variavel cProdDest
//-- lInfProd igual a .F. determina que a tabela destino sera gerada com os produtos da tabela origem
Local lInfProd	  := .T.
Local oPanelCabec

//-- Arrays para GetDados
Private aRotina  := {}
Private aHeader  := {}
Private aCols    := {}

//-- Objeto para Getdados
Private oGet

//-- Configuracao de tabelas utilizado pela funcao TMSLayOutTab()
Private aLayOut  := {}

//-- Flag do Percentual de Reajuste
Private lChkPerc    := .F.

Default cCatTab := StrZero(1, Len(DTL->DTL_CATTAB))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para Funcionar ExistChav !³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Inclui := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se algum usuario estiver incluindo Tabela de Frete, esta rotina nao podera   ³
//³ ser executada                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !LockByName("TABMAN",.T.,.F.)
	//-- Se Ja estiver reservado retorna .F. pois nao pode executar a Rotina
	Help("  ",1,"TMSA69004") //"Esta rotina nao podera ser executada, pois existe outro usuario incluindo Tabela de Frete"
	Return( .F. )
EndIf
UnLockByName("TABMAN",.T.,.F.) // Libera Lock

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ja' existe algum usuario executando esta rotina                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !LockByName("GERTAB",.T.,.F.)
	//-- Se Ja estiver reservado retorna .F. pois nao pode executar a Rotina
	Help("  ",1,"TMSA69006") //"Esta Rotina Nao podera ser executada, pois existe outro usuario gerando Tabelas de Frete"
	Return( .F. )
EndIf

//-- Carrega as Configuracoes das tabelas para selecao.
aLayOut := TMSLayOutTab(cCatTab,,,)
If Len(aLayOut)==0
	UnLockByName("GERTAB",.T.,.F.) // Libera Lock
	Return .F.
EndIf

//-- Tela para selecao das Configuracoes das Tabelas
IF !TMSABrowse( aLayOut, STR0001,,,,.T., { STR0002, STR0003, STR0024 } ) //"Escolha o Configuracao da Tabela para a nova tabela."###"Tabela de Frete"###"Tipo"###"Descricao"
	UnLockByName("GERTAB",.T.,.F.) // Libera Lock
	Return .F.
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preenche os dados da tabela selecionada.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCont := Ascan( aLayOut, { |aItem| aItem[1] == .T. } )
	cTabOri  := Left( aLayOut[ nCont ][2], 4 )
	cTipOri  := Left( aLayOut[ nCont ][3], 2 )
	dbSelectArea("DT0") // Tabela de Frete
	dbSetOrder(1)
	
	If lExistDY9
		dbSelectArea("DY9") // Tabela de Frete por Destinatário
		dbSetOrder(1)
	EndIf
	
	If !DT0->( MsSeek(xFilial("DT0")+cTabOri+cTipOri) ) .And.;
	    ( Iif( !lExistDY9, .F., !DY9->( MsSeek(xFilial("DY9")+cTabOri+cTipOri))))

		Help("  ",1,"TMSA69001") //-- "Nao existem tabelas relacionadas a Configuracao da Tabela definido. Por favor, selecione outra Configuracao de Tabela. "
		UnLockByName("GERTAB",.T.,.F.) // Libera Lock
		Return .F.
	EndIf
	cTipDOri := Tabela("M5", cTipOri,.F.)
EndIf

If cCatTab == StrZero(2, Len(DTL->DTL_CATTAB)) //-- Tabela a Pagar
	cF3Tab := "DVH"
EndIf

TmsAtuSXB()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aHeader.                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := {}
aTam:=TamSX3("DVE_CODPAS")
Aadd(aHeader,{RetTitle("DVE_CODPAS"),	"DVE_CODPAS",	PesqPict("DVE","DVE_CODPAS",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DVE"," "})
aTam:=TamSX3("DVE_DESPAS")
Aadd(aHeader,{RetTitle("DVE_DESPAS"),	"DVE_DESPAS",	PesqPict("DVE","DVE_DESPAS",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DVE"," "})
aTam:=TamSX3("DVE_COPPAS")
Aadd(aHeader,{RetTitle("DVE_COPPAS"),	"DVE_COPPAS",	PesqPict("DVE","DVE_COPPAS",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DVE"," "})
aTam:=TamSX3("DVO_PERMIN")
Aadd(aHeader,{RetTitle("DVE_PERREA"),	"DVE_PERREA",	PesqPict("DVO","DVO_PERMIN",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DVE"," "})
aTam:=TamSX3("DVO_PERMIN")
Aadd(aHeader,{'% Minimo',				"DVO_PERMIN",	PesqPict("DVO","DVO_PERMIN",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DVO"," "})
aTam:=TamSX3("DVO_PERAJU")
Aadd(aHeader,{'% Excedente',			"DVO_PERAJU",	PesqPict("DVO","DVO_PERAJU",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DVO"," "})
aTam:=TamSX3("DTK_VALMAX")
Aadd(aHeader,{"% Max. Tab. F.",			"DTK_VALMAX",	PesqPict("DTK","DTK_VALMAX",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTK"," "})
aTam:=TamSX3("DY1_VALMIN")
Aadd(aHeader,{"% Min. Sub. F.",			"DY1_VALMIN",	PesqPict("DY1","DY1_VALMIN",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DY1"," "})
aTam:=TamSX3("DY1_VALMAX")
Aadd(aHeader,{"% Max. Sub. F.",			"DY1_VALMAX",	PesqPict("DY1","DY1_VALMAX",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DY1"," "})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aCols.                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("DT3")
dbSelectArea("DVE")
DVE->(dbSetorder(1))
If dbSeek(xFilial("DVE")+cTabOri+cTipOri)
	While !Eof() .And. (xFilial("DVE")+cTabOri+cTipOri==DVE_FILIAL+DVE_TABFRE+DVE_TIPTAB)
		DT3->(DbSetOrder( 1 ))
		If DT3->(MsSeek( xFilial('DT3') + DVE->DVE_CODPAS )) .And. DT3->DT3_TIPFAI <> StrZero(16,Len(DT3->DT3_TIPFAI))  //Herda Valor
			AAdd(aCols,{DVE_CODPAS, DT3->DT3_DESCRI, "1", 0, 0, 0, 0, 0, 0, .F.})
		EndIf	
		dbSkip()
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualizacao do aCols conforme selecao do Check Box.                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosPerRea := aScan( aHeader, {|ExpA1| RTrim( ExpA1[2] ) == "DVE_PERREA" })
nPosPerMin := aScan( aHeader, {|ExpA1| RTrim( ExpA1[2] ) == "DVO_PERMIN" })
nPosPerExc := aScan( aHeader, {|ExpA1| RTrim( ExpA1[2] ) == "DVO_PERAJU" })
nPosDTKMax := aScan( aHeader, {|ExpA1| RTrim( ExpA1[2] ) == "DTK_VALMAX" })
nPosDY1Min := aScan( aHeader, {|ExpA1| RTrim( ExpA1[2] ) == "DY1_VALMIN" })
nPosDY1Max := aScan( aHeader, {|ExpA1| RTrim( ExpA1[2] ) == "DY1_VALMAX" })

If Empty(aHeader[nPosPerRea][6])
	aHeader[nPosPerRea][6] := "TMSA750Reaj(lChkPerc,oGet)"
Else
	aHeader[nPosPerRea][6] += ".And. TMSA750Reaj(lChkPerc,oGet)"
EndIf

If nPosPerMin > 0
	If Empty(aHeader[nPosPerMin][6])
		aHeader[nPosPerMin][6] := "TMSA750Reaj(lChkPerc,oGet)"
	Else
		aHeader[nPosPerMin][6] += ".And. TMSA750Reaj(lChkPerc,oGet)"
	EndIf
EndIf

If nPosPerExc > 0
	If Empty(aHeader[nPosPerExc][6])
		aHeader[nPosPerExc][6] := "TMSA750Reaj(lChkPerc,oGet)"
	Else
		aHeader[nPosPerExc][6] += ".And. TMSA750Reaj(lChkPerc,oGet)"
	EndIf
EndIf

If nPosDTKMax > 0
	If Empty(aHeader[nPosDTKMax][6])
		aHeader[nPosDTKMax][6] := "TMSA750Reaj(lChkPerc,oGet)"
	Else
		aHeader[nPosDTKMax][6] += ".And. TMSA750Reaj(lChkPerc,oGet)"
	EndIf
EndIf

If nPosDY1Min > 0
	If Empty(aHeader[nPosDY1Min][6])
		aHeader[nPosDY1Min][6] := "TMSA750Reaj(lChkPerc,oGet)"
	Else
		aHeader[nPosDY1Min][6] += ".And. TMSA750Reaj(lChkPerc,oGet)"
	EndIf
EndIf

If nPosDY1Max > 0
	If Empty(aHeader[nPosDY1Max][6])
		aHeader[nPosDY1Max][6] := "TMSA750Reaj(lChkPerc,oGet)"
	Else
		aHeader[nPosDY1Max][6] += ".And. TMSA750Reaj(lChkPerc,oGet)"
	EndIf
EndIf

//-- aRotina Ficticio para criacao da GetDados.
aRotina	:= {	{ STR0016 ,"" ,0,1 },; 	//"Pesquisar"
				{ STR0017 ,"" ,0,2 },; 	//"Visualizar"
				{ STR0018 ,"" ,0,3 },;	//"Incluir"
				{ STR0019 ,"" ,0,4 },; 	//"Alterar"
				{ STR0020 ,"" ,0,5 }} 	//"Excluir"

//-- Calcula as dimensoes dos objetos
oSize := FwDefSize():New( .T. )

oSize:lLateral     := .F.  // Calculo vertical

oSize:AddObject( "TELA", 100, 100, .T., .T. ) // Adiciona Enchoice

// Dispara o calculo
oSize:Process()
If aScreenRes[1] < 1280 .And. aScreenRes[2] < 1024 //Resolução inferior a 1280x1024
	DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] TITLE STR0004 PIXEL //"Geração de novas Tabelas"
	
		oSize2 := FwDefSize():New(.F.,,,oDlg)
		
		oSize2:lLateral     := .F.  // Calculo vertical
		
		oSize2:AddObject( "Enchoice", 100, 15, .T., .T. ) // Adiciona Enchoice
		
		oSize2:AddObject( "Grid", 100, 83, .T., .T. ) // Adiciona Grid
		
		oSize2:AddObject( "Rodape", 100, 2, .T., .T. ) // Adiciona Rodape
		
		// Dispara o calculo
		oSize2:Process()
	
		@ oSize2:GetDimension("Enchoice","LININI")-3,oSize2:GetDimension("Enchoice","COLINI")-3 MSPANEL oPanelCabec SIZE 0,095 OF oDlg
		oPanelCabec:Align := CONTROL_ALIGN_ALLCLIENT
	
		//Da Tabela
		@ oSize2:GetDimension("Enchoice","LININI"), oSize2:GetDimension("Enchoice","COLINI") TO oSize2:GetDimension("Enchoice","LINEND")-15, (oSize2:GetDimension("Enchoice","COLEND")/2)-2 LABEL STR0010 OF oPanelCabec PIXEL //'Da Tabela'
		@ oSize2:GetDimension("Enchoice","LININI")+15,oSize2:GetDimension("Enchoice","COLINI")+7 SAY STR0005 SIZE 21,8 OF oPanelCabec PIXEL  	//"Tabela : "
		@ oSize2:GetDimension("Enchoice","LININI")+14,oSize2:GetDimension("Enchoice","COLINI")+53 MSGet cTabOri    Picture "@!" F3 cF3Tab SIZE 21,8 OF oPanelCabec PIXEL WHEN .F.
		@ oSize2:GetDimension("Enchoice","LININI")+15,oSize2:GetDimension("Enchoice","COLINI")+115 SAY STR0006 SIZE 16,8 OF oPanelCabec PIXEL 	//"Tipo : "
		@ oSize2:GetDimension("Enchoice","LININI")+14,oSize2:GetDimension("Enchoice","COLINI")+130 MSGet cTipOri    Picture "@!"  SIZE  05,8 OF oPanelCabec PIXEL WHEN .F.
		@ oSize2:GetDimension("Enchoice","LININI")+14,oSize2:GetDimension("Enchoice","COLINI")+160 MSGet cTipDOri   Picture "@!"  SIZE  59,8 OF oPanelCabec PIXEL WHEN .F.
		@ oSize2:GetDimension("Enchoice","LININI")+28,oSize2:GetDimension("Enchoice","COLINI")+7 SAY STR0014 SIZE 40,8 OF oPanelCabec PIXEL 	//'Produto De  :'
		@ oSize2:GetDimension("Enchoice","LININI")+27,oSize2:GetDimension("Enchoice","COLINI")+53 MSGet cProdOri   Picture "@!" VALID A690Limpa(@cProdDOri) .And. A690Limpa(@cProdDDest,@cProdDest) .And. Tms690Field(cProdOri,@cProdDOri) F3 "SB1" SIZE 50,8 OF oPanelCabec PIXEL
		@ oSize2:GetDimension("Enchoice","LININI")+27,oSize2:GetDimension("Enchoice","COLINI")+115 MSGet cProdDOri  Picture "@!" SIZE 90,7 OF oPanelCabec PIXEL WHEN .F.
		@ oSize2:GetDimension("Enchoice","LININI")+41,oSize2:GetDimension("Enchoice","COLINI")+7 SAY STR0015 SIZE 40,8 OF oPanelCabec PIXEL	//'Produto Ate :'
		@ oSize2:GetDimension("Enchoice","LININI")+41,oSize2:GetDimension("Enchoice","COLINI")+53 MSGET cProdAte   Picture '@!' VALID A690Limpa(@cProdDAte) .And. Tms690Field(cProdAte,@cProdDAte) F3 'SB1' SIZE 50,8 OF oPanelCabec PIXEL
		@ oSize2:GetDimension("Enchoice","LININI")+41,oSize2:GetDimension("Enchoice","COLINI")+115 MSGET cProdDAte  Picture '@!' SIZE 90,7 OF oPanelCabec PIXEL WHEN .F.
		@ oSize2:GetDimension("Enchoice","LININI")+55,oSize2:GetDimension("Enchoice","COLINI")+7 SAY STR0021 SIZE 40,8 OF oPanelCabec PIXEL 	//Regiao Origem :
		@ oSize2:GetDimension("Enchoice","LININI")+55,oSize2:GetDimension("Enchoice","COLINI")+53 MsGet cCdrOri VALID Vazio(cCdrOri) .Or. ExistCpo("DUY",cCdrOri) PICTURE "@!" F3 "DUY" SIZE 50,8 OF oPanelCabec PIXEL
		@ oSize2:GetDimension("Enchoice","LININI")+55,oSize2:GetDimension("Enchoice","COLINI")+115 MsGet Posicione("DUY",1,xFilial("DUY")+cCdrOri,"DUY_DESCRI") When .F. SIZE 090,7 OF oPanelCabec PIXEL
		@ oSize2:GetDimension("Enchoice","LININI")+69,oSize2:GetDimension("Enchoice","COLINI")+7 SAY STR0022 SIZE 40,8 OF oPanelCabec PIXEL 	//Regiao Destino :
		@ oSize2:GetDimension("Enchoice","LININI")+69,oSize2:GetDimension("Enchoice","COLINI")+53 MsGet cCdrDes VALID (Vazio(cCdrDes) .Or. ExistCpo("DUY",cCdrDes)) PICTURE "@!" F3 "DUY" SIZE 50,8 OF oPanelCabec PIXEL
		@ oSize2:GetDimension("Enchoice","LININI")+69,oSize2:GetDimension("Enchoice","COLINI")+115 MsGet Posicione("DUY",1,xFilial("DUY")+cCdrDes,"DUY_DESCRI") When .F. SIZE 090,7 OF oPanelCabec PIXEL
	
		//Para Tabela
		@ oSize2:GetDimension("Enchoice","LININI"), (oSize2:GetDimension("Enchoice","COLEND")/2)+2 TO oSize2:GetDimension("Enchoice","LINEND")-15, oSize2:GetDimension("Enchoice","COLEND")-5 LABEL STR0011 OF oPanelCabec PIXEL //'Para a Tabela'
		@ oSize2:GetDimension("Enchoice","LININI")+15,oSize2:GetDimension("Enchoice","COLEND")-248 SAY STR0005 SIZE 21,8 OF oPanelCabec PIXEL //"Tabela : "
		@ oSize2:GetDimension("Enchoice","LININI")+14,oSize2:GetDimension("Enchoice","COLEND")-220 MSGet cTabDest Picture "@!" F3 cF3Tab SIZE  21,8 OF oPanelCabec PIXEL
		@ oSize2:GetDimension("Enchoice","LININI")+15,oSize2:GetDimension("Enchoice","COLEND")-165 SAY STR0006 SIZE 16,8 OF oPanelCabec PIXEL //"Tipo : "
		@ oSize2:GetDimension("Enchoice","LININI")+14,oSize2:GetDimension("Enchoice","COLEND")-150 MSGet cTipDest    Picture "@!" VALID A690NewTab(cTabDest,cTipDest) .And. A690Tipo(cTipDest,@cTipDDest) F3 "M5" SIZE  5,8 OF oPanelCabec PIXEL
		@ oSize2:GetDimension("Enchoice","LININI")+14,oSize2:GetDimension("Enchoice","COLEND")-110 MSGet cTipDDest   Picture "@!" SIZE  59,8 OF oPanelCabec PIXEL WHEN .F.
		@ oSize2:GetDimension("Enchoice","LININI")+28,oSize2:GetDimension("Enchoice","COLEND")-248 SAY STR0008 SIZE 22,8 OF oPanelCabec PIXEL //"Produto :"
		@ oSize2:GetDimension("Enchoice","LININI")+27,oSize2:GetDimension("Enchoice","COLEND")-220 MSGet cProdDest   Picture "@!" VALID A690Limpa(@cProdDDest) .And. Tms690Field(cProdDest,@cProdDDest,.T.) F3 "SB1" SIZE 50,8 OF oPanelCabec PIXEL WHEN (lInfProd := (cProdOri==cProdAte))
		@ oSize2:GetDimension("Enchoice","LININI")+27,oSize2:GetDimension("Enchoice","COLEND")-165 MSGet cProdDDest  Picture "@!" SIZE 90,7 OF oPanelCabec PIXEL WHEN .F.
	
		//GetDados
		oGet:= MSGetDados():New(oSize2:GetDimension("Enchoice","LINEND")+22,oSize2:GetDimension("Grid","COLINI"),oSize2:GetDimension("Grid","LINEND")+50,oSize2:GetDimension("Grid","COLEND")-10,3,"AlwaysTrue","AlwaysTrue","",.T.,{"DVE_COPPAS","DVE_PERREA","DVO_PERMIN","DVO_PERAJU","DTK_VALMAX","DY1_VALMIN","DY1_VALMAX"},,.F.,Len(aCols),,,,,oDlg)
		oGet:oBrowse:Refresh(.T.)
	
		//Flag do Percentual de Reajuste
		oPanRodape := TPanel():New(oSize2:GetDimension("Grid","LINEND")+55,oSize2:GetDimension("Rodape","COLINI"), "", oDlg, NIL, .T., .F.,NIL, NIL, oSize2:GetDimension("Rodape","XSIZE")-5, oSize2:GetDimension("Rodape","YSIZE"), .T., .F. )
		tCheckBox():New(3,3,STR0009,{|u|IIf(PCount() > 0,TMSA750Reaj(lChkPerc := u,oGet),lChkPerc)},oPanRodape,100,10,,,,,,,,.T.)
		
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If( Tms690Dest(cTabOri,cTipOri,cProdOri,cTabDest,cTipDest,cProdDest,cCatTab,lInfProd),(Processa({|lEnd| Tmsa690Grv(cTabOri,cTipOri,cProdOri,cCdrOri,cCdrDes,cTabDest,cTipDest,cProdDest,cProdAte,lInfProd)}),oDlg:End()),)},{|| oDlg:End()})
Else
	DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] TITLE STR0004 PIXEL //"Geração de novas Tabelas"

		oSize2 := FwDefSize():New(.F.,,,oDlg)
		
		oSize2:lLateral     := .F.  // Calculo vertical
		
		oSize2:AddObject( "Enchoice", 100, 15, .T., .T. ) // Adiciona Enchoice
		
		oSize2:AddObject( "Grid", 100, 83, .T., .T. ) // Adiciona Grid
		
		oSize2:AddObject( "Rodape", 100, 2, .T., .T. ) // Adiciona Rodape
		
		// Dispara o calculo
 		oSize2:Process()
	
		@ oSize2:GetDimension("Enchoice","LININI")-3,oSize2:GetDimension("Enchoice","COLINI")-3 MSPANEL oPanelCabec SIZE 0,095 OF oDlg
		oPanelCabec:Align := CONTROL_ALIGN_ALLCLIENT
	
		//Da Tabela
		@ oSize2:GetDimension("Enchoice","LININI"), oSize2:GetDimension("Enchoice","COLINI") TO oSize2:GetDimension("Enchoice","LINEND")-20, (oSize2:GetDimension("Enchoice","COLEND")/2)-2 LABEL STR0010 OF oPanelCabec PIXEL //'Da Tabela'
		@ oSize2:GetDimension("Enchoice","LININI")+15,oSize2:GetDimension("Enchoice","COLINI")+7 SAY STR0005 SIZE 21,8 OF oPanelCabec PIXEL  	//"Tabela : "
		@ oSize2:GetDimension("Enchoice","LININI")+14,oSize2:GetDimension("Enchoice","COLINI")+68 MSGet cTabOri    Picture "@!" F3 cF3Tab SIZE 21,8 OF oPanelCabec PIXEL WHEN .F.
		@ oSize2:GetDimension("Enchoice","LININI")+15,oSize2:GetDimension("Enchoice","COLINI")+115 SAY STR0006 SIZE 16,8 OF oPanelCabec PIXEL 	//"Tipo : "
		@ oSize2:GetDimension("Enchoice","LININI")+14,oSize2:GetDimension("Enchoice","COLINI")+147 MSGet cTipOri    Picture "@!"  SIZE  05,8 OF oPanelCabec PIXEL WHEN .F.
		@ oSize2:GetDimension("Enchoice","LININI")+14,oSize2:GetDimension("Enchoice","COLINI")+190 MSGet cTipDOri   Picture "@!"  SIZE  59,8 OF oPanelCabec PIXEL WHEN .F.
		@ oSize2:GetDimension("Enchoice","LININI")+28,oSize2:GetDimension("Enchoice","COLINI")+7 SAY STR0014 SIZE 40,8 OF oPanelCabec PIXEL 	//'Produto De  :'
		@ oSize2:GetDimension("Enchoice","LININI")+27,oSize2:GetDimension("Enchoice","COLINI")+68 MSGet cProdOri   Picture "@!" VALID A690Limpa(@cProdDOri) .And. A690Limpa(@cProdDDest,@cProdDest) .And. Tms690Field(cProdOri,@cProdDOri) F3 "SB1" SIZE 50,8 OF oPanelCabec PIXEL
		@ oSize2:GetDimension("Enchoice","LININI")+27,oSize2:GetDimension("Enchoice","COLINI")+120 MSGet cProdDOri  Picture "@!" SIZE 90,7 OF oPanelCabec PIXEL WHEN .F.
		@ oSize2:GetDimension("Enchoice","LININI")+41,oSize2:GetDimension("Enchoice","COLINI")+7 SAY STR0015 SIZE 40,8 OF oPanelCabec PIXEL	//'Produto Ate :'
		@ oSize2:GetDimension("Enchoice","LININI")+41,oSize2:GetDimension("Enchoice","COLINI")+68 MSGET cProdAte   Picture '@!' VALID A690Limpa(@cProdDAte) .And. Tms690Field(cProdAte,@cProdDAte) F3 'SB1' SIZE 50,8 OF oPanelCabec PIXEL
		@ oSize2:GetDimension("Enchoice","LININI")+41,oSize2:GetDimension("Enchoice","COLINI")+120 MSGET cProdDAte  Picture '@!' SIZE 90,7 OF oPanelCabec PIXEL WHEN .F.
		@ oSize2:GetDimension("Enchoice","LININI")+55,oSize2:GetDimension("Enchoice","COLINI")+7 SAY STR0021 SIZE 40,8 OF oPanelCabec PIXEL 	//Regiao Origem :
		@ oSize2:GetDimension("Enchoice","LININI")+55,oSize2:GetDimension("Enchoice","COLINI")+68 MsGet cCdrOri VALID Vazio(cCdrOri) .Or. ExistCpo("DUY",cCdrOri) PICTURE "@!" F3 "DUY" SIZE 50,8 OF oPanelCabec PIXEL
		@ oSize2:GetDimension("Enchoice","LININI")+55,oSize2:GetDimension("Enchoice","COLINI")+120 MsGet Posicione("DUY",1,xFilial("DUY")+cCdrOri,"DUY_DESCRI") When .F. SIZE 090,7 OF oPanelCabec PIXEL
		@ oSize2:GetDimension("Enchoice","LININI")+69,oSize2:GetDimension("Enchoice","COLINI")+7 SAY STR0022 SIZE 40,8 OF oPanelCabec PIXEL 	//Regiao Destino :
		@ oSize2:GetDimension("Enchoice","LININI")+69,oSize2:GetDimension("Enchoice","COLINI")+68 MsGet cCdrDes VALID (Vazio(cCdrDes) .Or. ExistCpo("DUY",cCdrDes)) PICTURE "@!" F3 "DUY" SIZE 50,8 OF oPanelCabec PIXEL
		@ oSize2:GetDimension("Enchoice","LININI")+69,oSize2:GetDimension("Enchoice","COLINI")+120 MsGet Posicione("DUY",1,xFilial("DUY")+cCdrDes,"DUY_DESCRI") When .F. SIZE 090,7 OF oPanelCabec PIXEL
	
		//Para Tabela
		@ oSize2:GetDimension("Enchoice","LININI"), (oSize2:GetDimension("Enchoice","COLEND")/2)+2 TO oSize2:GetDimension("Enchoice","LINEND")-20, oSize2:GetDimension("Enchoice","COLEND")-5 LABEL STR0011 OF oPanelCabec PIXEL //'Para a Tabela'
		@ oSize2:GetDimension("Enchoice","LININI")+15,oSize2:GetDimension("Enchoice","COLEND")-310 SAY STR0005 SIZE 21,8 OF oPanelCabec PIXEL //"Tabela : "
		@ oSize2:GetDimension("Enchoice","LININI")+14,oSize2:GetDimension("Enchoice","COLEND")-257 MSGet cTabDest Picture "@!" F3 cF3Tab SIZE  21,8 OF oPanelCabec PIXEL
		@ oSize2:GetDimension("Enchoice","LININI")+15,oSize2:GetDimension("Enchoice","COLEND")-202 SAY STR0006 SIZE 16,8 OF oPanelCabec PIXEL //"Tipo : "
		@ oSize2:GetDimension("Enchoice","LININI")+14,oSize2:GetDimension("Enchoice","COLEND")-170 MSGet cTipDest    Picture "@!" VALID A690NewTab(cTabDest,cTipDest) .And. A690Tipo(cTipDest,@cTipDDest) F3 "M5" SIZE  5,8 OF oPanelCabec PIXEL
		@ oSize2:GetDimension("Enchoice","LININI")+14,oSize2:GetDimension("Enchoice","COLEND")-127 MSGet cTipDDest   Picture "@!" SIZE  59,8 OF oPanelCabec PIXEL WHEN .F.
		@ oSize2:GetDimension("Enchoice","LININI")+28,oSize2:GetDimension("Enchoice","COLEND")-310 SAY STR0008 SIZE 22,8 OF oPanelCabec PIXEL //"Produto :"
		@ oSize2:GetDimension("Enchoice","LININI")+27,oSize2:GetDimension("Enchoice","COLEND")-257 MSGet cProdDest   Picture "@!" VALID A690Limpa(@cProdDDest) .And. Tms690Field(cProdDest,@cProdDDest,.T.) F3 "SB1" SIZE 50,8 OF oPanelCabec PIXEL WHEN (lInfProd := (cProdOri==cProdAte))
		@ oSize2:GetDimension("Enchoice","LININI")+27,oSize2:GetDimension("Enchoice","COLEND")-202 MSGet cProdDDest  Picture "@!" SIZE 90,7 OF oPanelCabec PIXEL WHEN .F.
	
		//GetDados
		oGet:= MSGetDados():New(oSize2:GetDimension("Enchoice","LINEND")+20,oSize2:GetDimension("Grid","COLINI"),oSize2:GetDimension("Grid","LINEND")+50/*100*/,oSize2:GetDimension("Grid","COLEND")-10,3,"AlwaysTrue","AlwaysTrue","",.T.,{"DVE_COPPAS","DVE_PERREA","DVO_PERMIN","DVO_PERAJU","DTK_VALMAX","DY1_VALMIN","DY1_VALMAX"},,.F.,Len(aCols),,,,,oDlg)
		oGet:oBrowse:Refresh(.T.)
	
		//Flag do Percentual de Reajuste
		oPanRodape := TPanel():New(oSize2:GetDimension("Grid","LINEND")+55/*+105*/,oSize2:GetDimension("Rodape","COLINI"), "", oDlg, NIL, .T., .F.,NIL, NIL, oSize2:GetDimension("Rodape","XSIZE")-5, oSize2:GetDimension("Rodape","YSIZE"), .T., .F. )
		tCheckBox():New(3,3,STR0009,{|u|IIf(PCount() > 0,TMSA750Reaj(lChkPerc := u,oGet),lChkPerc)},oPanRodape,100,10,,,,,,,,.T.) 
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If( Tms690Dest(cTabOri,cTipOri,cProdOri,cTabDest,cTipDest,cProdDest,cCatTab,lInfProd),(Processa({|lEnd| Tmsa690Grv(cTabOri,cTipOri,cProdOri,cCdrOri,cCdrDes,cTabDest,cTipDest,cProdDest,cProdAte,lInfProd)}),oDlg:End()),)},{|| oDlg:End()})
	
EndIf	
UnLockByName("GERTAB",.T.,.F.) // Libera Lock

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMS690Field³Autor  ³Patricia A. Salomao ³ Data ³ 22/04/04   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida o Produto Informado e Retorna a Descricao do Produto ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo do Produto                                   ³±±
±±³          ³ExpC2 - Descricao do Produto (@)                            ³±±
±±³          ³ExpL1 - Indica se valida ou nao a existencia do produto     ³±±
±±³          ³        no cadastro                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA690                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tms690Field(cCpoCod,cCpoDesc,lValida)

Local   lRet    := .T.
Default lValida := .F.

If !Empty(cCpoCod)
	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+cCpoCod))
		cCpoDesc := SB1->B1_DESC
	ElseIf lValida 
		Help("",,"REGNOIS") //"Nao existe registro relacionado a este codigo"
		lRet := .F.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMS690Dest³ Autor ³Patricia A. Salomao    ³ Data ³ 22/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a Tabela Destino Informada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Tabela Original                                     ³±±
±±³          ³ExpC2 = Tipo da Tabela Original                             ³±±
±±³          ³ExpC3 = Produto Origem                                      ³±±
±±³          ³ExpC4 = Tabela Destino                                      ³±±
±±³          ³ExpC5 = Tipo da Tabela Destino                              ³±±
±±³          ³ExpC6 = Produto Destino                                     ³±±
±±³          ³ExpC7 = Categ. da Tabela :1-Frete a Receber/2-Frete a Pagar ³±±
±±³          ³ExpL1 = .T. determina que a tabela destino sera gerada com  ³±±
±±³          ³        o produto informado na variavel cProdDest.          ³±±
±±³          ³        .F. determina que a tabela destino sera gerada com  ³±±
±±³          ³        os produtos da tabela origem.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA690                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tms690Dest(cTabOri,cTipOri,cProdOri,cTabDest,cTipDest,cProdDest,cCatTab,lInfProd)

Local lRet       := .T.
Local nPosCopia  := Ascan( aHeader, {|x| AllTrim(x[2]) == 'DVE_COPPAS' } )
Local lContHis   := GetMv("MV_CONTHIS",.F.,.T.) //-- Controla Historico da Tabela de Frete

Default cCatTab  := StrZero(1,Len(DTL->DTL_CATTAB) ) //-- Frete a Receber

If Empty(cTabDest) .Or. Empty(cTipDest)
	Help('',1,"TMSA69002") //"A tabela de Destino nao foi selecionada. Por favor,selecione uma tabela de Destino."
	Return(.F.)
Else
	If cTabOri+cTipOri+Iif(lInfProd,cProdOri,'') == cTabDest+cTipDest+Iif(lInfProd,cProdDest,'')
		If lTMA010His
			lContHis := ExecBlock("TMA010HIS",.F.,.F.,{4,DT0->DT0_TABFRE,DT0->DT0_TIPTAB})
			If ValType(lContHis) <> "L"
				lContHis:=.T.
			EndIf
		EndIf
		//-- Verifica se a tabela de frete a Pagar esta sendo utilizada em AWB ou Complemento de Viagem
		If lContHis .And.	TmsTabUso(cTabDest,cTipDest,CriaVar('DT0_CDRORI',.F.),CriaVar('DT0_CDRDES',.F.),.T.,cCatTab)
			Return(.F.)
		EndIf
		If !TMSA750TudoOk( 3 )
			Return(.F.)
		EndIf
	EndIf
	//-- Pelo menos um item deve estar com o campo COPIA habilitado
	If Ascan(aCols, {|x| x[nPosCopia] == "1" }) == 0
		Help("  ",1,"TMSA69003") //"Nao ha itens selecionados. Ao menos um item deve ser selecionado para a geracao de uma nova tabela. "
		Return(.F.)
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A690Tipo  ³ Autor ³Rodrigo de A. Sartorio ³ Data ³ 17/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o tipo da tabela de frete                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Tipo da Tabela                                      ³±±
±±³          ³ExpC2 = Descricao do tipo de tabela                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA690                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A690Tipo(cTipDest,cTipDDest)

Local lRet:=ExistCpo("SX5","M5"+cTipDest)
If lRet
	cTipDDest:=Tabela("M5",cTipDest)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA690Grv³ Autor ³Patricia A. Salomao    ³ Data ³ 22/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera as Novas Tabelas                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Tabela Origem                                       ³±±
±±³          ³ExpC2 - Tipo da Tabela Origem                               ³±±
±±³          ³ExpC3 - Produto Inicial da Tabela Origem                    ³±±
±±³          ³ExpC4 - Regiao Origem  da Tabela Origem                     ³±±
±±³          ³ExpC5 - Regiao Destino da Tabela Origem                     ³±±
±±³          ³ExpC6 - Tabela Destino                                      ³±±
±±³          ³ExpC7 - Tipo da Tabela Destino                              ³±±
±±³          ³ExpC8 - Produto da Tabela Destino                           ³±±
±±³          ³ExpC9 - Produto Final da Tabela Origem                      ³±±
±±³          ³ExpL1 = .T. determina que a tabela destino sera gerada com  ³±±
±±³          ³        o produto informado na variavel cProdDest.          ³±±
±±³          ³        .F. determina que a tabela destino sera gerada com  ³±±
±±³          ³        os produtos da tabela origem.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA690                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA690Grv(cTabOri,cTipOri,cProdOri,cCdrOri,cCdrDes,cTabDest,cTipDest,cProdDest,cProdAte,lInfProd)

Local nCntFor    := 0
Local cAlias     := ""
Local cRecno     := ""
Local cQuery     := ""
Local cCompCop   := ""
Local cSqlOri    := ""
Local cSqlDes    := ""
Local nMin       := 0
Local nMax       := 0
Local nReg       := 0
Local nCount     := 0
Local aEstruExp  := {}
Local aCampos    := {}
Local aOrigem    := {}
Local aDestino   := {}
Local cAliasDT0  := ""
Local cDescAlias := ""
Local aArea      := {}
Local nPosCodPas := Ascan( aHeader, {|x| AllTrim(x[2]) == 'DVE_CODPAS' } )
Local nPosCopia  := Ascan( aHeader, {|x| AllTrim(x[2]) == 'DVE_COPPAS' } )
Local nPasso     := Max(GetNewPar("MV_PASSTAB",100000),100000)
Local lGerNewTab := A690GerNTab(cTabOri,cTipOri,cProdOri,cTabDest,cTipDest,cProdDest,lInfProd)
Local lTMALogGrv := ExistBlock("TMALOGGRV")
Local ni
Local lSubFaixa  := AliasInDic("DW0") .And. AliasInDic("DW1")
Local lSubExced  := lSubFaixa .and. AliasInDic("DY0") .And. AliasInDic("DY1")
Local lDWP       := AliasInDic("DWP") .And. AliasInDic("DWQ")
Local lExistDY9  := AliasInDic("DY9")
Local lExistDYA  := AliasInDic("DYA")
Local lExistDYG  := AliasIndic("DYG")
Local lExistDVY  := AliasInDic("DVY")
Local lExistDJS	 := AliasInDic("DJS")
Local nAlias     := 14
Local aAlias     := {}
Local i          := 0
Local cTempOri   := GetNextAlias()
Local cTempDes   := GetNextAlias()
Local oTrabOri   := FWTemporaryTable():New( cTempOri )
Local oTrabDes   := FWTemporaryTable():New( cTempDes )
Local aTrbCampos := {}
Local cInsert    := ""

Local nQtd := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena os componentes a serem copiados   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCntFor :=1 To Len(aCols)
	If aCols[nCntFor][nPosCopia] = "1"
		cCompCop += "'" +  aCols[nCntFor][nPosCodPas] + "'," 
	EndIf
Next

cCompCop := Substr(cCompCop,1,Len(cCompCop) - 1)

/* Cria tabela Temporária do Alias */
AADD(aTrbCampos,{ "TRB_GRPVEN" ,"C", TamSX3("DUY_GRPVEN")[1], 0} ) 
oTrabOri:SetFields( aTrbCampos )
oTrabDes:SetFields( aTrbCampos )

oTrabOri:AddIndex("indice1", {"TRB_GRPVEN"} )
oTrabDes:AddIndex("indice1", {"TRB_GRPVEN"} )

oTrabOri:Create()
oTrabDes:Create()

If !Empty(cCdrOri)
	TmsNivInf(cCdrOri,aOrigem,,.T.)		
	If Len(aOrigem) > 0
		For nCount := 1 To Len(aOrigem)
			cInsert := "INSERT INTO " + oTrabOri:GetRealName() + " (TRB_GRPVEN) "
			cInsert += " Values ('" + aOrigem[nCount][1] + "' ) "		
			TcSqlExec(cInsert)								
		Next
	EndIf
	cInsert := "INSERT INTO "+oTrabOri:GetRealName() +" (TRB_GRPVEN) "
	cInsert += "values ('"+cCdrOri+"')"		
	TcSqlExec(cInsert)	
EndIf

If !Empty(cCdrDes)
	TmsNivInf(cCdrDes,aDestino,,.T.)
	If Len(aDestino) > 0 
		For nCount := 1 To Len(aDestino)
			cInsert := "INSERT INTO " + oTrabDes:GetRealName() + " (TRB_GRPVEN) "
			cInsert += " Values ('" + aDestino[nCount][1] + "' ) "			
			TcSqlExec(cInsert)
		Next
	EndIf
	
	cInsert := "INSERT INTO " + oTrabDes:GetRealName() + " (TRB_GRPVEN) "
	cInsert += "values ('" + cCdrDes + "') "			
	TcSqlExec(cInsert)	
EndIf
aArea := GetArea()


//Criando as Tabelas Antes para nao dar erro devido a Build a partir de 22/12/07
For nCntFor := 1 To nAlias
	If nCntFor == 1
		cAlias := "DTK"	// Complemento da Tabela de Frete
	ElseIf nCntFor == 2
		cAlias := "DT1"	// Itens da Tabela de Frete
	ElseIf nCntFor == 3
		cAlias := "DTG"	// Itens da Tabela de Tarifa
	ElseIf nCntFor == 4
		cAlias := "DT0"	// Cabecalho da Tabela de Frete
	ElseIf nCntFor == 5
		cAlias := "DTF"	// Cabecalho da Tabela de Tarifa
	ElseIf nCntFor == 6 .And. lSubFaixa
		cAlias := "DW0"	// Subfaixa da Tabela de Tarifa
	ElseIf nCntFor == 7 .And. lSubFaixa
		cAlias := "DW1"	// Subfaixa da Tabela de Frete
	ElseIf nCntFor == 8 .And. lSubExced
		cAlias := "DY0"	// Excedente da Tabela de Tarifa
	ElseIf nCntFor == 9 .And. lSubExced
		cAlias := "DY1"	// Excedente da Tabela de Frete
	ElseIf nCntFor == 10 .And. lExistDY9
		cAlias := "DY9"	// Tabela de Frete por Destinatário
	ElseIf nCntFor == 11 .And. lExistDYA
		cAlias := "DYA"	//Itens da Tabela de Frete por Destinatário
	ElseIf nCntFor == 12 .And. lExistDYG
		cAlias := "DYG"	//SubFaixa Tabela de Frete por Destinatário
	ElseIf nCntFor == 13 .And. lExistDVY
		cAlias := "DVY"	//Base Componente TDA
	ElseIf nCntFor == 14 .And. lExistDJS
		cAlias	:= "DJS"//-- Base % por componente TRT
	EndIf

	cTemp     := GetNextAlias()
	oTempTable := FWTemporaryTable():New( cTemp )

	aAdd(aAlias,oTempTable)
	aEstruExp := (cAlias)->( dbStruct() )
	oTemptable:SetFields( aEstruExp )
	oTempTable:Create()
Next nCntFor

Begin Transaction
	For nCntFor := 1 To nAlias
		If nCntFor == 1
			cAlias := "DTK"	// Complemento da Tabela de Frete
		ElseIf nCntFor == 2
			cAlias := "DT1"	// Itens da Tabela de Frete
		ElseIf nCntFor == 3
			cAlias := "DTG"	// Itens da Tabela de Tarifa
		ElseIf nCntFor == 4
			cAlias := "DT0"	// Cabecalho da Tabela de Frete
		ElseIf nCntFor == 5
			cAlias := "DTF"	// Cabecalho da Tabela de Tarifa
		ElseIf nCntFor == 6 .And. lSubFaixa
			cAlias := "DW0"	// Subfaixa da Tabela de Tarifa
		ElseIf nCntFor == 7 .And. lSubFaixa
			cAlias := "DW1"	// Subfaixa da Tabela de Frete
		ElseIf nCntFor == 8 .And. lSubExced
			cAlias := "DY0"	// Excedente da Tabela de Tarifa
		ElseIf nCntFor == 9 .And. lSubExced
			cAlias := "DY1"	// Excedente da Tabela de Frete
		ElseIf nCntFor == 10 .And. lExistDY9
			cAlias := "DY9"	// Tabela de Frete por Destinatário
		ElseIf nCntFor == 11 .And. lExistDYA
			cAlias := "DYA"	// Itens da Tabela de Frete por Destinatário
		ElseIf nCntFor == 12 .And. lExistDYG
			cAlias := "DYG"	// Subfaixa Tabela de Frete por Destinatário
		ElseIf nCntFor == 13 .And. lExistDVY
			cAlias := "DVY"	//Base Componente TDA
		ElseIf nCntFor == 14 .And. lExistDJS
			cAlias	:= "DJS"//-- Base % por componente TRT
		EndIf

		//-- Paginação inicial
		cRecno := GetNextAlias()
		TMS690Pag(cRecno,cAlias,cTabOri,cTipOri,oTrabOri,oTrabDes,cProdOri,cProdAte,cCdrOri,cCdrDes,1)
		If (cRecno)->( !Eof() )
			nMin := (cRecno)->MIN_RECNO
			nMax := (cRecno)->MAX_RECNO
			nQtd := (cRecno)->QTD_RECNO
			aEstruExp  := (cAlias)->( dbStruct() )
			cDescAlias := X2Nome()
			ProcRegua(Int((nMax - nMin) / nPasso))
			(cRecno)->( dbCloseArea() )

			nReg := nMin
					
			While nQtd > 0 .And. nReg <= nMax

				nRegIni := nReg
				nRegFim := Iif(nQtd <= nPasso,nMax,nReg + nPasso)

				IncProc(STR0023 + cDescAlias) //"Atualizando "

				cQuery  := "SELECT "
				For nI := 1 To Len( aEstruExp )
					If nI > 1
						cQuery += ", "
					EndIf
					cQuery += aEstruExp[ nI, 1 ]
				Next
				If !lGerNewTab
					cQuery += "   , "+cAlias+".R_E_C_N_O_ "
				EndIf
				cQuery += "   FROM "+RetSqlName(cAlias) + " " + cAlias
				cQuery += "  WHERE "+cAlias+"_FILIAL = '"+xFilial(cAlias)+"'"
				cQuery += "    AND "+cAlias+"_TABFRE = '"+cTabOri +"'"
				cQuery += "    AND "+cAlias+"_TIPTAB = '"+cTipOri +"'"
				//-- A Tabela de Tarifa nao tem codigo de produto
				If cAlias <> 'DTF' .And. cAlias <> 'DTG' .And. cAlias <> 'DW0' .And. cAlias <> 'DY0' .And. cAlias <> 'DY9' .And. cAlias <> 'DYA' .And. cAlias <> 'DYG'
					If !Empty(cCdrOri)
						cQuery += "	AND "+cAlias+"_CDRORI IN ( SELECT TRB_GRPVEN FROM " + oTrabOri:GetRealName() + " )"
					Else
						cQuery += " AND "+cAlias+"_CDRORI BETWEEN '"+Space(Len(DT0->DT0_CDRORI)) +"'AND'"+Replicate("Z",Len(DT0->DT0_CDRORI))+"'"
					EndIf
					If !Empty(cCdrDes)
						cQuery += " AND "+cAlias+"_CDRDES IN ( SELECT TRB_GRPVEN FROM " + oTrabDes:GetRealName() + " )"
					Else
						cQuery += " AND "+cAlias+"_CDRDES BETWEEN '"+Space(Len(DT0->DT0_CDRDES)) +"'AND'"+Replicate("Z",Len(DT0->DT0_CDRDES))+"'"
					EndIf
					cQuery += " AND "+cAlias+"_CODPRO BETWEEN '"+cProdOri+"' AND '"+cProdAte+"'"
				EndIf
				//-- Verifica se o componente deve ser copiado 
				If cAlias <> 'DT0' .And. cAlias <> 'DTF' .And. cAlias <> 'DY9' 
					cQuery += " AND " + cAlias+"_CODPAS  IN "+ " ( " +cCompCop+" ) "
				EndIf
				cQuery += "   AND "+cAlias+".R_E_C_N_O_  BETWEEN " + AllTrim(Str(nRegIni)) + " AND " + AllTrim(Str(nRegFim))
				cQuery += "   AND "+cAlias+".D_E_L_E_T_  = ' '"
				//-- Se for gerar Nova Tabela
				If lGerNewTab
					//-- Verifica se a Nova Tabela de Frete ja' existe
					cQuery += "    AND NOT EXISTS ( SELECT * FROM "
					cQuery += RetSqlName(cAlias) + " " + cAlias + "2 "
					cQuery += "  WHERE "+cAlias+"2."+cAlias+"_FILIAL = " +cAlias+"."+cAlias+"_FILIAL "
					cQuery += "    AND "+cAlias+"2."+cAlias+"_TABFRE = '"+cTabDest+"'"
					cQuery += "    AND "+cAlias+"2."+cAlias+"_TIPTAB = '"+cTipDest+"'"
					If cAlias <> 'DTF' .And. cAlias <> 'DTG' .And. cAlias <> 'DW0' .and. cAlias <> 'DY0' .And. cAlias <> 'DY9' .And. cAlias <> 'DYA' .And. cAlias <> 'DYG'
						cQuery += " AND "+cAlias+"2."+cAlias+"_CDRORI =  " +cAlias+"."+cAlias+"_CDRORI "
						cQuery += " AND "+cAlias+"2."+cAlias+"_CDRDES =  " +cAlias+"."+cAlias+"_CDRDES "
						If	lInfProd
							cQuery += " AND "+cAlias+"2."+cAlias+"_CODPRO = '"+cProdDest+"'"
						Else
							cQuery += " AND "+cAlias+"2."+cAlias+"_CODPRO = " +cAlias+"."+cAlias+"_CODPRO "
						EndIf
					Else
						If cAlias <> 'DY9' .And. cAlias <> 'DYA' .And. cAlias <> 'DYG'
							cQuery += " AND "+cAlias+"2."+cAlias+"_TABTAR =  " +cAlias+"."+cAlias+"_TABTAR "
						EndIf
					EndIf
					If cAlias $ "DTK,DT1,DTG,DW0,DW1,DY0,DY1,DYA,DYG,DVY,DJS"
						cQuery += " AND "+cAlias+"2."+cAlias+"_CODPAS =  " +cAlias+"."+cAlias+"_CODPAS "
					EndIf
					If cAlias $ "DT1,DTG,DW0,DW1,DY0,DY1,DYA,DYG"
						cQuery += " AND "+cAlias+"2."+cAlias+"_ITEM =  " +cAlias+"."+cAlias+"_ITEM "
					EndIf
					If cAlias $ "DW0,DY0"
						cQuery += " AND "+cAlias+"2."+cAlias+"_ITEDTG =  " +cAlias+"."+cAlias+"_ITEDTG "
					EndIf
					If cAlias $ "DW1,DY1"
						cQuery += " AND "+cAlias+"2."+cAlias+"_ITEDT1 =  " +cAlias+"."+cAlias+"_ITEDT1 "
					EndIf
					cQuery += "    AND "+cAlias+"2.D_E_L_E_T_ = ' ' )"
					//-- Verifica se o componente a ser copiado esta' cadastrado no LayOut
					//-- da Tabela Destino. Se nao estiver, o componente nao devera' ser copiado.
					If cAlias <> 'DT0' .And. cAlias <> 'DTF' .And. cAlias <> 'DY9'  .And. cAlias <> 'DYA' .And. cAlias <> 'DYG'
						cQuery += "    AND EXISTS ( "
						cQuery += " SELECT DVE_CODPAS FROM "
						cQuery += "  "+RetSqlName('DVE') + " DVE "
						cQuery += "  WHERE DVE.DVE_FILIAL  = '"+xFilial("DVE")+"'"
						cQuery += "    AND DVE.DVE_TABFRE  = '"+cTabDest+"'"
						cQuery += "    AND DVE.DVE_TIPTAB  = '"+cTipDest+"'"
						cQuery += "    AND DVE.DVE_CODPAS  =  "+cAlias +"."+cAlias+"_CODPAS"
						cQuery += "    AND DVE.D_E_L_E_T_  = ' ' )"
					EndIf
					//-- So' copiar o cabecalho da Tabela de Frete, se tiver gravado os itens (DT1 / DTG) 
					//-- da nova Tabela. Se nao fizer esta verificacao, a tabela poderia ficar com
					//-- cabecalho (DT0), porem sem Itens (DT1/DTG)
					If cAlias = 'DT0'  // Tabela de Frete
						cQuery += "    AND ( EXISTS ( "
						cQuery += " SELECT DT1_CODPAS FROM "
						cQuery += "  "+RetSqlName('DT1') + " DT1 "
						cQuery += "  WHERE DT1.DT1_FILIAL  = '"+xFilial("DT1")+"'"
						cQuery += "    AND DT1.DT1_TABFRE  = '"+cTabDest+"'"
						cQuery += "    AND DT1.DT1_TIPTAB  = '"+cTipDest+"'"
						cQuery += "    AND DT1.DT1_CDRORI  = " +cAlias+"."+cAlias+"_CDRORI"	
						cQuery += "    AND DT1.DT1_CDRDES  = " +cAlias+"."+cAlias+"_CDRDES"
						If	lInfProd
							cQuery += " AND DT1.DT1_CODPRO  = '"+cProdDest+"'"
						Else
							cQuery += " AND DT1.DT1_CODPRO = " +cAlias+"."+cAlias+"_CODPRO "
						EndIf
						cQuery += "    AND DT1.D_E_L_E_T_  = ' ' )"
						cQuery += "    OR  EXISTS ( "
					EndIf
					//-- So' copiar o cabecalho da Tabela de Tarifa, se tiver gravado os itens (DTG)
					//-- da nova Tabela. Se nao fizer esta verificacao, a tabela poderia ficar com
					//-- cabecalho (DTF), porem sem Itens (DTG)
					If cAlias= 'DT0' .Or. cAlias = 'DTF'
						If cAlias = 'DTF'
							cQuery += "    AND EXISTS ( "
						EndIf
						cQuery += " SELECT DTG_CODPAS FROM "
						cQuery += "  "+RetSqlName('DTG') + " DTG "
						cQuery += "  WHERE DTG.DTG_FILIAL  = '"+xFilial("DTG")+"'"
						cQuery += "    AND DTG.DTG_TABFRE  = '"+cTabDest+"'"
						cQuery += "    AND DTG.DTG_TIPTAB  = '"+cTipDest+"'"
						cQuery += "    AND DTG.DTG_TABTAR  = " +cAlias+"."+cAlias+"_TABTAR"
						cQuery += "    AND DTG.D_E_L_E_T_  = ' ' )"
						If cAlias = 'DT0'
							cQuery += " ) "
						EndIf
					EndIf
					//-- Só copiar o cabeçalho da Tabela de Frete por Destinatário, se tiver gravado os itens (DYA)
					//-- da nova Tabela. Se não fizer essa verificação, a tabela poderia ficar com
					//-- cabeçalho (DY9), porem sem itens (DYA) 
					If cAlias == 'DY9' .Or. cAlias == 'DYA' // Tabela de Frete por Destinatário
						cQuery += "	AND NOT EXISTS ( "
						cQuery += " SELECT DYA_CODPAS FROM "
						cQuery += " "+RetSqlName('DYA') + " DYA "
						cQuery += " WHERE DYA.DYA_FILIAL = '"+xFilial("DYA")+"' "
						cQuery += " 	AND DYA.DYA_TABFRE = '"+cTabDest+"' "
						cQuery += " 	AND DYA.DYA_TIPTAB = '"+cTipDest+"' "	
						cQuery += "	AND DYA.D_E_L_E_T_ = ' ' ) "
					EndIf
					//-- Só copiar o cabeçalho da Tabela de Frete por Destinatário, se tiver gravado os itens (DYA)
					//-- da nova Tabela. Se não fizer essa verificação, a tabela poderia ficar com
					//-- cabeçalho (DY9), porem sem subfaixa (DYG) 					
					If cAlias == 'DYG'
						cQuery += "	AND NOT EXISTS ( "
						cQuery += " SELECT DYG_CODPAS FROM "
						cQuery += " "+RetSqlName('DYG') + " DYG "
						cQuery += " WHERE DYG.DYG_FILIAL = '"+xFilial("DYG")+"' "
						cQuery += " 	AND DYG.DYG_TABFRE = '"+cTabDest+"' "
						cQuery += " 	AND DYG.DYG_TIPTAB = '"+cTipDest+"' "	
						cQuery += "	AND DYG.D_E_L_E_T_ = ' ' ) "
					EndIf
				EndIf
				//-- ChangeQuery()
				//-- 1o Parametro : Query 
				//-- 2o Parametro : Se .F., nao insere FOR READ ONLY no final das querys para AS/400 e/ou DB2			            				                        							   
				cQuery := ChangeQuery(cQuery, .F.)
				If !TMSA690Trb( cAlias, cQuery, cTabOri, cTipOri, cProdOri, cTabDest, cTipDest, cProdDest, cProdAte, lInfProd, aAlias[nCntFor]:GetRealName() )
					DisarmTransaction()
					Help("  ",1,"TMSA69007",,TcSqlError(),1) //--"O processo foi interrompido inesperadamente, e os dados não foram gravados. "
					Break
					Exit
				EndIf

				//-- Pagina novamente
				cRecno := GetNextAlias()
				TMS690Pag(cRecno,cAlias,cTabOri,cTipOri,oTrabOri,oTrabDes,cProdOri,cProdAte,cCdrOri,cCdrDes,(nRegFim + 1))
				If (cRecno)->( !Eof() )
					nMin := (cRecno)->MIN_RECNO
					nMax := (cRecno)->MAX_RECNO
					nQtd := (cRecno)->QTD_RECNO
					nReg := nMin
				EndIf
				(cRecno)->( dbCloseArea() )
				
			EndDo

		EndIf

	Next
	//-- Gravacao do Historico de Reajuste Tab. Frete
	If lDWP .And. ( cTabOri+cTipOri == cTabDest+cTipDest )
		TMSGrvDWP(cTabOri,cTipOri,cCdrOri,cCdrDes,cProdOri,cProdAte,aCols)
	EndIf

oTrabOri:Delete() 
oTrabDes:Delete() 
 
RestArea(aArea)
End Transaction

If lTMALogGrv
	//-- Ponto de entrada comum entre todas as rotinas que manipulam tabela de frete e ajustes.
	//-- O ponto tem o objetivo de possibilitar a criacao de um LOG informando o  usuario  e  a
	//-- operação que foi realizada em uma tabela de frete ou ajuste de cliente.
	ExecBlock("TMALOGGRV",.F.,.F.,{ "DT0", "3", Substr(cUsuario,7,15), 0 })
EndIf

If Len(aAlias) > 0
	//-- Apaga Arquivo Temporario
	For i:=1 to Len(aAlias)
		aAlias[i]:Delete() 
	Next i
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A690NewTab³ Autor ³Patricia A. Salomao    ³ Data ³ 22/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a existencia do LayOut da Nova Tabela/Tipo informados³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Tabela Destino                                      ³±±
±±³          ³ExpC2 = Tipo da Tabela Destino                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA690                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A690NewTab(cTabDest,cTipDest)
Local lRet  := .T.
Local aArea := GetArea()

DTL->(dbSetOrder(1))
If !DTL->(MsSeek(xFilial('DTL')+cTabDest+cTipDest))
	Help("",1,"TMA69005") // Configuracao da Tabela Nao Cadastrada !!!
	lRet := .F.
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA690Trb³ Autor ³ Patricia A. Salomao   ³ Data ³ 22/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria Tabela com INSERT INTO                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Alias                                               ³±±
±±³          ³ExpC2 - Query                                               ³±±
±±³          ³ExpC3 - Tabela Origem                                       ³±±
±±³          ³ExpC4 - Tipo da Tabela Origem                               ³±±
±±³          ³ExpC5 - Produto da Tabela Origem                            ³±±
±±³          ³ExpC6 - Tabela Destino                                      ³±±
±±³          ³ExpC7 - Tipo da Tabela Destino                              ³±±
±±³          ³ExpC8 - Produto da Tabela Destino                           ³±±
±±³          ³ExpL1 = .T. determina que a tabela destino sera gerada com  ³±±
±±³          ³        o produto informado na variavel cProdDest.          ³±±
±±³          ³        .F. determina que a tabela destino sera gerada com  ³±±
±±³          ³        os produtos da tabela origem.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA690                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA690Trb( cAlias, cQueryAux, cTabOri, cTipOri, cProdOri, cTabDest, cTipDest, cProdDest, cProdAte, lInfProd, cTemp )

Local lRet       := .T.
Local aEstruExp  := {}
Local nI         := 0
Local nValor     := 0
Local cCodPas    := ""
Local cRecno     := ""
Local nMaxArq    := 0
Local cAliasNew  := ""
Local cQuery     := ""
Local nPosCompon := Ascan( aHeader, {|ExpA1| ExpA1[2] == "DVE_CODPAS"} )
Local nPosPerRea := Ascan( aHeader, {|ExpA1| RTrim( ExpA1[2] ) == "DVE_PERREA" })
Local nTamVal    := TamSX3("DT1_VALOR")[1]
Local nDecVal    := TamSX3("DT1_VALOR")[2]
Local nNewVal    := 0
Local nNewValMin := 0
Local nNewValExc := 0
Local nNewValMax := 0
Local nPosReaju  := 0
Local lGerNewTab := A690GerNTab(cTabOri,cTipOri,cProdOri,cTabDest,cTipDest,cProdDest,lInfProd)
Local lTM690GRC  := ExistBlock('TM690GRC')
Local lTM690GRI  := ExistBlock('TM690GRI')
Local cCodTRT	 := ""
Local cAliasQry := GetNextAlias()
//-- Se for gerar novas Tabelas, criar arquivo temporario 
If lGerNewTab

	//-- Apagando registros anteriores
	cQuery   := "DELETE FROM " + cTemp
	If TCSqlExec( cQuery ) <> 0
		lRet := .F.
	EndIf

	aEstruExp := (cAlias)->( dbStruct() )

	cQuery := "INSERT INTO " + cTemp + " ( "
	For nI := 1 To Len( aEstruExp )
		If !("R_E_C_N_O_" $ aEstruExp[ nI, 1 ])
			cQuery += aEstruExp[ nI, 1 ] + ","
		EndIf
	Next
	cQuery := Substr(cQuery,1,Len(cQuery)-1) + ") " + cQueryAux

	If TCSqlExec( cQuery ) <> 0
		lRet := .F.
	EndIf

Else
	cTemp  := RetSqlName(cAlias)
	cQuery := cQueryAux
EndIf


If lRet

	//-- Renumera o RECNO do temporario
	If lGerNewTab 
		If "ORACLE" $ Upper(TcGetDb())
			cQuery := "UPDATE " + cTemp + " SET R_E_C_N_O_ = 1 + ROWNUM "
			TCSqlExec( cQuery )
		Else
			cQuery := "SELECT R_E_C_N_O_ FROM "+cTemp+" ORDER BY R_E_C_N_O_ "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
			nI := 2
			While (cAliasQry)->(!Eof())
				cQuery := "UPDATE " + cTemp + " SET R_E_C_N_O_ = ("+Str(nI)+") WHERE R_E_C_N_O_ ="+Str((cAliasQry)->R_E_C_N_O_)
				TCSqlExec( cQuery )
				nI++
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
		EndIf
	EndIf

	If lGerNewTab .And. cAlias == "DT0"  // Cabecalho da Tabela de Frete
		cAliasNew := GetNextAlias()
		cQuery    := "SELECT * FROM " + cTemp
		dbUseArea(.T., "TOPCONN" , TCGenQry(,,cQuery), cAliasNew, .F., .T.)
		(cAliasNew)->(dbGotop())
		Do While (cAliasNew)->(!Eof())
			cQuery  := "UPDATE " + cTemp + " SET "
			cQuery  +=  cAlias + "_TABFRE = '" +  cTabDest  + "',"
			cQuery  +=  cAlias + "_TIPTAB = '" +  cTipDest  + "',"
			If	lInfProd
				cQuery  +=  cAlias + "_CODPRO = '" +  cProdDest + "'"
			Else
				cQuery  +=  cAlias + "_CODPRO = '" +  (cAliasNew)->DT0_CODPRO + "'"
			EndIf
			cQuery  += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ )
			If TCSqlExec( cQuery ) <> 0
				lRet := .F.
				Exit
			EndIf
			If lTM690GRC
				ExecBlock('TM690GRC',.F.,.F.,{cAlias, cAliasNew})
			EndIf
			(cAliasNew)->(dbSkip())
		EndDo
		(cAliasNew)->(dbCloseArea())

	ElseIf cAlias == "DT1"	// Itens da Tabela de Frete
		cAliasNew := GetNextAlias()
		If lGerNewTab
			cQuery    := "SELECT * FROM " + cTemp
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
		(cAliasNew)->(dbGotop())
		Do While (cAliasNew)->(!Eof())
			nPosReaju  := Ascan( aCols,  {|ExpA1| ExpA1[nPosCompon] == (cAliasNew)->DT1_CODPAS })
			nPosPerc   := Ascan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DVE_PERREA" })
			nValor     := (cAliasNew)->DT1_VALOR
			nNewVal    := 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % de Reajuste no Valor do Componente                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPosReaju > 0
				nNewVal := TMA690NewVal(nValor,nPosReaju,nPosPerc,cTabDest,cTipDest)
			EndIf
			cQuery := "UPDATE " + cTemp + " SET "
			cQuery +=  cAlias + "_TABFRE = '" +  cTabDest  + "',"
			cQuery +=  cAlias + "_TIPTAB = '" +  cTipDest  + "',"
			If	lInfProd
				cQuery +=  cAlias + "_CODPRO = '" +  cProdDest + "',"
			Else
				cQuery +=  cAlias + "_CODPRO = '" +  (cAliasNew)->DT1_CODPRO + "',"
			EndIf
			cQuery +=  cAlias + "_VALOR  = " + AllTrim(Str(nNewVal,nTamVal,nDecVal))
			cQuery += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ )
			If TCSqlExec( cQuery ) <> 0
				lRet := .F.
				Exit
			EndIf
			If lTM690GRI
				ExecBlock('TM690GRI',.F.,.F.,{cAlias, cAliasNew, nValor})
			EndIf
			(cAliasNew)->(dbSkip())
		EndDo
		(cAliasNew)->(dbCloseArea())

	ElseIf cAlias == "DTK" // Complemento da Tabela de Frete
		cAliasNew := GetNextAlias()
		If lGerNewTab
			cQuery    := "SELECT * FROM " + cTemp
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
		(cAliasNew)->(dbGotop())
		Do While (cAliasNew)->(!Eof())
			nPosReaju := aScan( aCols,{|ExpA1| ExpA1[nPosCompon] == (cAliasNew)->DTK_CODPAS })
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % Minimo                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValor     := (cAliasNew)->DTK_VALMIN
			nPosPerc   := Ascan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DVO_PERMIN" })
			nNewValMin := 0
			If nPosReaju > 0
				nNewValMin = TMA690NewVal(nValor,nPosReaju,nPosPerc,cTabDest,cTipDest)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % Excedente                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValor     := (cAliasNew)->DTK_VALOR
			nPosPerc   := Ascan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DVO_PERAJU" })
			nNewValExc := 0
			If nPosReaju > 0
				nNewValExc = TMA690NewVal(nValor,nPosReaju,nPosPerc,cTabDest,cTipDest)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % Maximo                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValor     := (cAliasNew)->DTK_VALMAX
			nPosPerc   := Ascan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DTK_VALMAX" })
			nNewValMax := 0
			If nPosReaju > 0
				nNewValMax = TMA690NewVal(nValor,nPosReaju,nPosPerc,cTabDest,cTipDest)
			EndIf
			cQuery  := "UPDATE " + cTemp + " SET " 
			cQuery  +=  cAlias + "_TABFRE = '" +  cTabDest  + "',"
			cQuery  +=  cAlias + "_TIPTAB = '" +  cTipDest  + "',"
			If	lInfProd
				cQuery  +=  cAlias + "_CODPRO = '" +  cProdDest + "',"
			Else
				cQuery +=  cAlias + "_CODPRO = '" +  (cAliasNew)->DTK_CODPRO + "',"
			EndIf
			cQuery  +=  cAlias + "_VALMIN = " +  AllTrim(Str(nNewValMin,nTamVal,nDecVal)) + ","
			cQuery  +=  cAlias + "_VALOR  = " +  AllTrim(Str(nNewValExc,nTamVal,nDecVal)) + ","
			cQuery  +=  cAlias + "_VALMAX = " +  AllTrim(Str(nNewValMax,nTamVal,nDecVal))
			cQuery  += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ )
			If TCSqlExec( cQuery ) <> 0
				lRet := .F.
				Exit
			EndIf
			If lTM690GRI
				ExecBlock('TM690GRI',.F.,.F.,{cAlias, cAliasNew, nValor})
			EndIf
			(cAliasNew)->(dbSkip())
		EndDo
		(cAliasNew)->(dbCloseArea())

	ElseIf lGerNewTab .And. cAlias == "DTF" // Cabecalho da Tabela de Tarifa
		cAliasNew := GetNextAlias()
		cQuery    := "SELECT * FROM " + cTemp
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
		(cAliasNew)->(dbGotop())
		Do While (cAliasNew)->(!Eof())
			cQuery  := "UPDATE " + cTemp + " SET "
			cQuery  +=  cAlias + "_TABFRE = '" +  cTabDest  + "',"
			cQuery  +=  cAlias + "_TIPTAB = '" +  cTipDest  + "'"
			cQuery  += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ )
			If TCSqlExec( cQuery ) <> 0
				lRet := .F.
				Exit
			EndIf
			If lTM690GRC
				ExecBlock('TM690GRC',.F.,.F.,{cAlias, cAliasNew})
			EndIf
			(cAliasNew)->(dbSkip())
		EndDo
		(cAliasNew)->(dbCloseArea())

	ElseIf cAlias == "DTG" // Itens da Tabela de Tarifa
		cAliasNew := GetNextAlias()
		If lGerNewTab
			cQuery    := "SELECT * FROM " + cTemp
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
		(cAliasNew)->(dbGotop())
		Do While (cAliasNew)->(!Eof())
			nPosReaju  := Ascan( aCols,  {|ExpA1| ExpA1[nPosCompon] == (cAliasNew)->DTG_CODPAS })
			nPosPerc   := Ascan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DVE_PERREA" })
			nValor     := (cAliasNew)->DTG_VALOR
			nNewVal    := 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % de Reajuste no Valor do Componente                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPosReaju > 0
				nNewVal := TMA690NewVal(nValor,nPosReaju,nPosPerc,cTabDest,cTipDest)
			EndIf
			cQuery := "UPDATE " + cTemp + " SET "
			cQuery +=  cAlias + "_TABFRE = '" +  cTabDest  + "',"
			cQuery +=  cAlias + "_TIPTAB = '" +  cTipDest  + "',"
			cQuery +=  cAlias + "_VALOR  = " +  AllTrim(Str(nNewVal,nTamVal,nDecVal))
			cQuery += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ )
			If TCSqlExec( cQuery ) <> 0
				lRet := .F.
				Exit
			EndIf
			If lTM690GRI
				ExecBlock('TM690GRI',.F.,.F.,{cAlias, cAliasNew, nValor})
			EndIf
			(cAliasNew)->(dbSkip())
		EndDo
		(cAliasNew)->(dbCloseArea())

	ElseIf cAlias == "DW0" // Sub Faixa da Tabela de Tarifa 
		cAliasNew := GetNextAlias()
		If lGerNewTab
			cQuery    := "SELECT * FROM " + cTemp
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
		(cAliasNew)->(dbGotop())
		Do While (cAliasNew)->(!Eof())
			nPosReaju  := Ascan( aCols,  {|ExpA1| ExpA1[nPosCompon] == (cAliasNew)->DW0_CODPAS })
			nPosPerc   := Ascan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DVE_PERREA" })
			nValor     := (cAliasNew)->DW0_VALOR
			nNewVal    := 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % de Reajuste no Valor do Componente                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPosReaju > 0
				nNewVal := TMA690NewVal(nValor,nPosReaju,nPosPerc,cTabDest,cTipDest)
			EndIf
			cQuery := "UPDATE " + cTemp + " SET "
			cQuery +=  cAlias + "_TABFRE = '" +  cTabDest  + "',"
			cQuery +=  cAlias + "_TIPTAB = '" +  cTipDest  + "',"
			cQuery +=  cAlias + "_VALOR  = " +  AllTrim(Str(nNewVal,nTamVal,nDecVal))
			cQuery += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ )
			If TCSqlExec( cQuery ) <> 0
				lRet := .F.
				Exit
			EndIf
			If lTM690GRI
				ExecBlock('TM690GRI',.F.,.F.,{cAlias, cAliasNew, nValor})
			EndIf
			(cAliasNew)->(dbSkip())
		EndDo
		(cAliasNew)->(dbCloseArea())

	ElseIf cAlias == "DW1"	// Subfaixa da Tabela de Frete
		cAliasNew := GetNextAlias()
		If lGerNewTab
			cQuery    := "SELECT * FROM " + cTemp
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
		(cAliasNew)->(dbGotop())
		Do While (cAliasNew)->(!Eof())
			nPosReaju  := Ascan( aCols,  {|ExpA1| ExpA1[nPosCompon] == (cAliasNew)->DW1_CODPAS })
			nPosPerc   := Ascan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DVE_PERREA" })
			nValor     := (cAliasNew)->DW1_VALOR
			nNewVal    := 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % de Reajuste no Valor do Componente                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPosReaju > 0 
				nNewVal := TMA690NewVal(nValor,nPosReaju,nPosPerc,cTabDest,cTipDest)
			EndIf
			cQuery := "UPDATE " + cTemp + " SET "
			cQuery +=  cAlias + "_TABFRE = '" +  cTabDest  + "',"
			cQuery +=  cAlias + "_TIPTAB = '" +  cTipDest  + "',"
			If	lInfProd
				cQuery +=  cAlias + "_CODPRO = '" +  cProdDest + "',"
			Else
				cQuery +=  cAlias + "_CODPRO = '" +  (cAliasNew)->DW1_CODPRO + "',"
			EndIf
			cQuery +=  cAlias + "_VALOR  = " +  AllTrim(Str(nNewVal,nTamVal,nDecVal))
			cQuery += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ )
			If TCSqlExec( cQuery ) <> 0
				lRet := .F.
				Exit
			EndIf
			If lTM690GRI
				ExecBlock('TM690GRI',.F.,.F.,{cAlias, cAliasNew, nValor})
			EndIf
			(cAliasNew)->(dbSkip())
		EndDo
		(cAliasNew)->(dbCloseArea())

	// Excedente por subfaixa
	ElseIf cAlias == "DY0" // Excedente na SubFaixa da Tabela de Tarifa 
		cAliasNew := GetNextAlias()
		If lGerNewTab
			cQuery    := "SELECT * FROM " + cTemp
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
		(cAliasNew)->(dbGotop())
		Do While (cAliasNew)->(!Eof())
			nPosReaju  := Ascan( aCols,  {|ExpA1| ExpA1[nPosCompon] == (cAliasNew)->DY0_CODPAS })
			nPosPerc   := Ascan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DVE_PERREA" })
			nValor     := (cAliasNew)->DY0_VALOR
			nNewVal    := 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % de Reajuste no Valor do Componente                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPosReaju > 0
				nNewVal := TMA690NewVal(nValor,nPosReaju,nPosPerc,cTabDest,cTipDest)
			EndIf
			cQuery := "UPDATE " + cTemp + " SET "
			cQuery +=  cAlias + "_TABFRE = '" +  cTabDest  + "',"
			cQuery +=  cAlias + "_TIPTAB = '" +  cTipDest  + "',"
			cQuery +=  cAlias + "_VALOR  = " +  AllTrim(Str(nNewVal,nTamVal,nDecVal))
			cQuery += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ )
			If TCSqlExec( cQuery ) <> 0
				lRet := .F.
				Exit
			EndIf
			If lTM690GRI
				ExecBlock('TM690GRI',.F.,.F.,{cAlias, cAliasNew, nValor})
			EndIf
			(cAliasNew)->(dbSkip())
		EndDo
		(cAliasNew)->(dbCloseArea())

	// Excedente por subfaixa
	ElseIf cAlias == "DY1"	// Excedente na Subfaixa da Tabela de Frete
		cAliasNew := GetNextAlias()
		If lGerNewTab
			cQuery    := "SELECT * FROM " + cTemp
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
		(cAliasNew)->(dbGotop())
		Do While (cAliasNew)->(!Eof())
			nPosReaju  := Ascan( aCols,  {|ExpA1| ExpA1[nPosCompon] == (cAliasNew)->DY1_CODPAS })
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % de Reajuste no Valor do Componente                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValor     := (cAliasNew)->DY1_VALOR
			nPosPerc   := Ascan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DVE_PERREA" })
			nNewVal    := 0
			If nPosReaju > 0
				nNewVal := TMA690NewVal(nValor,nPosReaju,nPosPerc,cTabDest,cTipDest)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % Minimo                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValor     := (cAliasNew)->DY1_VALMIN
			nPosPerc   := Ascan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DY1_VALMIN" })
			nNewValMin := 0
			If nPosReaju > 0
				nNewValMin = TMA690NewVal(nValor,nPosReaju,nPosPerc,cTabDest,cTipDest)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % Maximo                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValor     := (cAliasNew)->DY1_VALMAX
			nPosPerc   := Ascan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DY1_VALMAX" })
			nNewValMax := 0
			If nPosReaju > 0
				nNewValMax = TMA690NewVal(nValor,nPosReaju,nPosPerc,cTabDest,cTipDest)
			EndIf
			cQuery := "UPDATE " + cTemp + " SET "
			cQuery +=  cAlias + "_TABFRE = '" +  cTabDest  + "',"
			cQuery +=  cAlias + "_TIPTAB = '" +  cTipDest  + "',"
			If	lInfProd
				cQuery +=  cAlias + "_CODPRO = '" +  cProdDest + "',"
			Else
				cQuery +=  cAlias + "_CODPRO = '" +  (cAliasNew)->DY1_CODPRO + "',"
			EndIf
			cQuery +=  cAlias + "_VALOR  = " +  AllTrim(Str(nNewVal,nTamVal,nDecVal))    + ", "
			cQuery +=  cAlias + "_VALMIN = " +  AllTrim(Str(nNewValMin,nTamVal,nDecVal)) + ", "
			cQuery +=  cAlias + "_VALMAX = " +  AllTrim(Str(nNewValMax,nTamVal,nDecVal))
			cQuery += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ )
			If TCSqlExec( cQuery ) <> 0
				lRet := .F.
				Exit
			EndIf
			If lTM690GRI
				ExecBlock('TM690GRI',.F.,.F.,{cAlias, cAliasNew, nValor})
			EndIf
			(cAliasNew)->(dbSkip())
		EndDo
		(cAliasNew)->(dbCloseArea())

	ElseIf lGerNewTab .And. cAlias == "DY9" //Cabeçalho da Tabela de Frete por Destinatário
		cAliasNew := GetNextAlias()
		cQuery    := "SELECT * FROM " + cTemp
		dbUseArea(.T., "TOPCONN" , TCGenQry(,,cQuery), cAliasNew, .F., .T.)
		(cAliasNew)->(dbGotop())
		Do While (cAliasNew)->(!Eof())
			dDatDe  := (cAliasNew)->DY9_DATDE
			dDatAte := (cAliasNew)->DY9_DATATE
			nMoeda  := (cAliasNew)->DY9_MOEDA
			cQuery  := "UPDATE " + cTemp + " SET "
			cQuery  +=  cAlias + "_TABFRE = '" + cTabDest + "',"
			cQuery  +=  cAlias + "_TIPTAB = '" + cTipDest + "',"
			cQuery  +=  cAlias + "_DATDE  = '" + dDatDe   + "',"
			cQuery  +=  cAlias + "_DATATE = '" + dDatAte  + "',"
			cQuery  +=  cAlias + "_MOEDA  = "  + Str( nMoeda, TamSX3("DY9_MOEDA")[1] ) 			
			cQuery  += " WHERE R_E_C_N_O_ = "  + Str( (cAliasNew)->R_E_C_N_O_ )
			If TCSqlExec( cQuery ) <> 0
				lRet := .F.
				Exit
			EndIf
			If lTM690GRC
				ExecBlock('TM690GRC',.F.,.F.,{cAlias, cAliasNew})
			EndIf
			(cAliasNew)->(dbSkip())			
		EndDo
		(cAliasNew)->(dbCloseArea())

	ElseIf cAlias == "DYA"	// Itens da Tabela de Frete por Destinatário
		
		cAliasNew := GetNextAlias()
		If lGerNewTab
			cQuery := "SELECT * FROM " + cTemp
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
		(cAliasNew)->(dbGotop())
		Do While (cAliasNew)->(!Eof())
			nPosReaju  := Ascan( aCols,  {|ExpA1| ExpA1[nPosCompon] == (cAliasNew)->DYA_CODPAS })
			nPosPerc   := Ascan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DVE_PERREA" })
			nValor     := (cAliasNew)->DYA_VALOR
			nNewVal    := 0
			cCodPas    := (cAliasNew)->DYA_CODPAS
			cCliDes    := (cAliasNew)->DYA_CLIDES
			cLojDes    := (cAliasNew)->DYA_LOJDES
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % de Reajuste no Valor do Componente                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPosReaju > 0
				nNewVal := TMA690NewVal(nValor,nPosReaju,nPosPerc,cTabDest,cTipDest)
			EndIf
			cQuery := "UPDATE " + cTemp + " SET "
			cQuery +=  cAlias + "_TABFRE = '" +  cTabDest  + "',"
			cQuery +=  cAlias + "_TIPTAB = '" +  cTipDest  + "',"
			cQuery +=  cAlias + "_CODPAS = '" +  cCodPas   + "',"
			cQuery +=  cAlias + "_CLIDES = '" +  cCliDes   + "',"
			cQuery +=  cAlias + "_LOJDES = '" +  cLojDes   + "',"
			cQuery +=  cAlias + "_VALOR  = " + AllTrim(Str(nNewVal,nTamVal,nDecVal))
			cQuery += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ )
			If TCSqlExec( cQuery ) <> 0
				lRet := .F.
				Exit
			EndIf
			If lTM690GRI
				ExecBlock('TM690GRI',.F.,.F.,{cAlias, cAliasNew, nValor})
			EndIf
			(cAliasNew)->(dbSkip())
		EndDo
		(cAliasNew)->(dbCloseArea())

	ElseIf cAlias == "DYG"	// Subfaixa da Tabela de Frete por Destinatário  
		cAliasNew := GetNextAlias()
		If lGerNewTab
			cQuery    := "SELECT * FROM " + cTemp
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
		(cAliasNew)->(dbGotop())
		Do While (cAliasNew)->(!Eof())
			nPosReaju  := Ascan( aCols,  {|ExpA1| ExpA1[nPosCompon] == (cAliasNew)->DYG_CODPAS })
			nPosPerc   := Ascan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DVE_PERREA" })
			nValor     := (cAliasNew)->DYG_VALOR
			nNewVal    := 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % de Reajuste no Valor do Componente                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPosReaju > 0 
				nNewVal := TMA690NewVal(nValor,nPosReaju,nPosPerc,cTabDest,cTipDest)
			EndIf
			cQuery := "UPDATE " + cTemp + " SET "
			cQuery += cAlias + "_TABFRE = '" + cTabDest  + "',"
			cQuery += cAlias + "_TIPTAB = '" + cTipDest  + "',"
			cQuery += cAlias + "_VALOR  =  " + AllTrim(Str(nNewVal,nTamVal,nDecVal))
			cQuery += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ )
			If TCSqlExec( cQuery ) <> 0
				lRet := .F.
				Exit
			EndIf
			If lTM690GRI
				ExecBlock('TM690GRI',.F.,.F.,{cAlias, cAliasNew, nValor})
			EndIf
			(cAliasNew)->(dbSkip())
		EndDo
		(cAliasNew)->(dbCloseArea())

	ElseIf cAlias == "DVY"	// Base Componente TDA
		cAliasNew := GetNextAlias()
		If lGerNewTab
			cQuery := "SELECT * FROM " + cTemp
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
		(cAliasNew)->(dbGotop())
		Do While (cAliasNew)->(!Eof())
			cCodPas := (cAliasNew)->DVY_CODPAS
			nValor  := (cAliasNew)->DVY_VLBASE
			cQuery := "UPDATE " + cTemp + " SET "
			cQuery += cAlias + "_TABFRE = '" + cTabDest + "',"
			cQuery += cAlias + "_TIPTAB = '" + cTipDest + "',"
			cQuery += cAlias + "_CODPAS = '" + cCodPas  + "',"
			cQuery += cAlias + "_VLBASE  = " + AllTrim(Str(nValor,nTamVal,nDecVal))
			cQuery += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ )
			If TCSqlExec( cQuery ) <> 0
				lRet := .F.
				Exit
			EndIf
			If lTM690GRI
				ExecBlock('TM690GRI',.F.,.F.,{cAlias, cAliasNew, nValor})
			EndIf
			(cAliasNew)->(dbSkip())
		EndDo
		(cAliasNew)->(dbCloseArea())
		
	ElseIf cAlias == "DJS"	// Base % por Componente TRT
		cAliasNew := GetNextAlias()
		If lGerNewTab
			cQuery := "SELECT * FROM " + cTemp
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
		(cAliasNew)->(dbGotop())
		Do While (cAliasNew)->(!Eof())
			cCodPas := (cAliasNew)->DJS_CODPAS
			nValor  := (cAliasNew)->DJS_PERCEN
			cCodTRT	:= (cAliasNew)->DJS_CODTRT
			cQuery := "UPDATE " + cTemp + " SET "
			cQuery += cAlias + "_TABFRE = '" + cTabDest + "',"
			cQuery += cAlias + "_TIPTAB = '" + cTipDest + "',"
			cQuery += cAlias + "_CODPAS = '" + cCodPas  + "',"
			cQuery += cAlias + "_CODTRT = '" + cCodTRT  + "', "
			cQuery += cAlias + "_PERCEN  = " + AllTrim(Str(nValor,nTamVal,nDecVal))
			cQuery += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ )
			If TCSqlExec( cQuery ) <> 0
				lRet := .F.
				Exit
			EndIf
			If lTM690GRI
				ExecBlock('TM690GRI',.F.,.F.,{cAlias, cAliasNew, nValor})
			EndIf
			(cAliasNew)->(dbSkip())
		EndDo
		(cAliasNew)->(dbCloseArea())
	EndIf
EndIf

If lRet .And. lGerNewTab

	//-- Registro Maximo do Arquivo
	cRecno   := GetNextAlias()
	cQuery   := "SELECT MAX(R_E_C_N_O_) MAX_RECNO  FROM " + RetSqlName( cAlias )
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cRecno, .F., .T.)
	nMaxArq  :=  (cRecno)->MAX_RECNO 

	cQuery := "INSERT INTO " + RetSqlName( cAlias ) + " ( "
	For nI := 1 To Len( aEstruExp )
		cQuery += aEstruExp[ nI, 1 ] + ", "
	Next
	cQuery += "R_E_C_N_O_) SELECT  "
	For nI := 1 To Len( aEstruExp )
	 	cQuery += aEstruExp[ nI, 1 ] + ", "
	Next
	cQuery += "R_E_C_N_O_ + " + Str( nMaxArq )
	cQuery += "  FROM " + cTemp
	cQuery += " WHERE D_E_L_E_T_ = ' '"

	If TCSqlExec( cQuery ) <> 0
		lRet := .F.
	EndIf

	//-- Fecha maior recno apos transacao, para iniciar a transacao em um area valida
	(cRecno)->(dbCloseArea())
	TCRefresh(RetSqlName(cAlias))

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa ³TMA690NewVal³Autor  ³Patricia A. Salomao ³ Data ³ 22/04/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³Calcula o Novo Valor com base no percentual de reajuste     ³±±
±±³         ³informado                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro³ExpN1 : Valor Atual do componente                           ³±±
±±³         ³ExpN2 : Posicao do Componente no aCols   (Linha)            ³±±
±±³         ³ExpN3 : Posicao do Percentual no aHeader (Coluna)           ³±±
±±³         ³ExpC1 : Tabela Destino                                      ³±±
±±³         ³ExpC1 : Tipo da Tabela Destino                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno  ³Novo Valor                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³TMSA690                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA690NewVal(nValor, nPosReaju, nPosPerc, cTabDest,cTipDest)

Local nNewVal := 0
Local nTamDec := 0
Default cTabDest := ''
Default cTipDest := ''

//-- Verifica o No. de Decimais especificado na Configuracao da Tabela Destino
DTL->(dbSetOrder(1))
If DTL->(MsSeek(xFilial('DTL')+cTabDest+cTipDest)) .And. DTL->(FieldPos('DTL_NUMDEC')) > 0
	nTamDec := DTL->DTL_NUMDEC
EndIf

If Empty(nTamDec)
	nNewVal := nValor+(nValor*(aCols[nPosReaju][nPosPerc]/100))
Else
	nNewVal := NoRound(nValor+(nValor*(aCols[nPosReaju][nPosPerc]/100)), nTamDec)
EndIf

Return nNewVal

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa ³A690ValCopy ³Autor  ³Rafael M. Quadrotti ³ Data ³ 17/02/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³Avalia a Copia do DT0                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro³ExpC1 : Alias do Arquivo de Trabalho                        ³±±
±±³         ³ExpL1 : Verifica se Valida Tabela de Tarifa ou Tab. de Frete³±±
±±³         ³ExpC2 : Tabela Destino                                      ³±±
±±³         ³ExpC3 : Tipo da Tabela Destino                              ³±±
±±³         ³ExpC4 : Componentes selecionados para Copia                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno  ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³TMSA690 (CodeBase)                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A690ValCopy(cAliasDT0, lTabTar, cTabDest, cTipDest, cCompCop)

Local lRet  := .F.
Local aArea := GetArea()

Default cAliasDT0 := "TRB"
Default lTabTar   := .F.
Default cTabDest  := ''
Default cTipDest  := ''
Default cCompCop  := ''

If !lTabTar
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se encontrar no dt1 um componente valido para esta tabela, copia. caso contrario nao copia. E se o TABTAR estiver ³
	//³preenchido ignora esta validacao.                                                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("DT1")
	dbSetOrder(1)
	If MsSeek(xFilial("DT1")+ (cAliasDT0)->(DT0_TABFRE+DT0_TIPTAB+DT0_CDRORI+DT0_CDRDES+DT0_CODPRO) )
		While (!Eof() .AND. DT1_FILIAL == xFilial("DT1") .AND.;
			DT1->DT1_TABFRE==(cAliasDT0)->DT0_TABFRE .AND.;
			DT1->DT1_TIPTAB==(cAliasDT0)->DT0_TIPTAB .AND.;
			DT1->DT1_CDRORI==(cAliasDT0)->DT0_CDRORI .AND.;
			DT1->DT1_CDRDES==(cAliasDT0)->DT0_CDRDES .And.;
			DT1->DT1_CODPRO==(cAliasDT0)->DT0_CODPRO  )
			//-- Verifica se o Componente informado na Tabela de Frete Origem, existe na Configuracao da 
			//-- Tabela de Frete Destino
			DVE->(dbSetOrder(2))
			If (DT1_CODPAS $ cCompCop) .And. DVE->(MsSeek(xFilial('DVE')+DT1->DT1_CODPAS+cTabDest+cTipDest))
				lRet:= .T.
				Exit
			EndIf
			DT1->(dbSkip())
		End
	EndIf
Else
	dbSelectArea("DTG")
	dbSetOrder(1)
	If MsSeek(xFilial("DTG")+ (cAliasDT0)->(DT0_TABFRE+DT0_TIPTAB+DT0_TABTAR) )
		While (!Eof() .AND. xFilial("DTG")==DTG_FILIAL .AND.;
			DTG->DTG_TABFRE==(cAliasDT0)->DT0_TABFRE .AND.;
			DTG->DTG_TIPTAB==(cAliasDT0)->DT0_TIPTAB .AND.;
			DTG->DTG_TABTAR==(cAliasDT0)->DT0_TABTAR )
			//-- Verifica se o Componente informado na Tabela de Tarifa, existe na Configuracao da 
			//-- Nova Tabela
			DVE->(dbSetOrder(2))
			If (DTG_CODPAS $ cCompCop) .And. DVE->(MsSeek(xFilial('DVE')+DTG->DTG_CODPAS+cTabDest+cTipDest))
				lRet:= .T.
				Exit
			EndIf
			DTG->(dbSkip())
		End
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa ³A690GerNTab ³Autor  ³ Richard Anderson   ³ Data ³ 14/09/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³Verifica se gera nova tabela                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro³ExpC1 : Tabela de Origem                                    ³±±
±±³         ³ExpC2 : Tipo da Tabela de Origem                            ³±±
±±³         ³ExpC3 : Produto de Origem (De)                              ³±±
±±³         ³ExpC4 : Tabela de Destino                                   ³±±
±±³         ³ExpC5 : Tipo Tabela de Destino                              ³±±
±±³         ³ExpC6 : Produto de Destino                                  ³±±
±±³         ³ExpL1 = .T. determina que a tabela destino sera gerada com  ³±±
±±³         ³        o produto informado na variavel cProdDest.          ³±±
±±³         ³        .F. determina que a tabela destino sera gerada com  ³±±
±±³         ³        os produtos da tabela origem.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno  ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³TMSA690                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A690GerNTab(cTabOri,cTipOri,cProdOri,cTabDest,cTipDest,cProdDest,lInfProd)

Local lRet := .T.

If	lInfProd
	//-- lInfProd igual a .T. indica que o produto da tabela destino foi digitado
	lRet := ( cTabOri+cTipOri+cProdOri != cTabDest+cTipDest+cProdDest )
Else
	//-- lInfProd igual a .F. indica que foi estabelecido uma faixa de produtos para pesquisa da tabela origem
	lRet := ( cTabOri+cTipOri != cTabDest+cTipDest )
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa ³A690Limpa   ³Autor  ³ Richard Anderson   ³ Data ³ 14/09/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³Limpar variaveis de produto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro³ExpC1 : Descricao                                           ³±±
±±³         ³ExpC2 : Codigo                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno  ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³TMSA690                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A690Limpa(cDesPro,cCodPro)

If cDesPro != NIL
	cDesPro := Space(Len(SB1->B1_DESC))
EndIf

If cCodPro != NIL
	cCodPro := Space(Len(SB1->B1_COD))
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSGrvDWP ³ Autor ³Eduardo de Souza       ³ Data ³ 09/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera historico do reajuste da tabela de frete              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ TMSGrvDWP()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA690                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSGrvDWP(cTabFre,cTipTab,cCdrOri,cCdrDes,cPrdDe,cPrdAte,aCols)

Local nCnt    := 0
Local cMay    := ""
Local cNumIde := CriaVar("DWP_NUMIDE",.T.)

cMay := AllTrim(xFilial('DWP'))+cNumIde
FreeUsedCode()
DWP->(DbSetOrder(3))
While DWP->(MsSeek(xFilial("DWP")+cNumIde)) .Or. !MayIUseCode(cMay)
	ConfirmSx8()
	cNumIde := CriaVar("DWP_NUMIDE",.T.)
	FreeUsedCode()
	cMay := AllTrim(xFilial('DWP'))+cNumIde
EndDo

RecLock("DWP",.T.)
DWP->DWP_FILIAL := xFilial("DWP")
DWP->DWP_NUMIDE := cNumIde
DWP->DWP_TABFRE := cTabFre
DWP->DWP_TIPTAB := cTipTab
DWP->DWP_CDRORI := cCdrOri
DWP->DWP_CDRDES := cCdrDes
DWP->DWP_PRDDE  := cPrdDe
DWP->DWP_PRDATE := cPrdAte
DWP->DWP_DATREA := dDataBase
DWP->DWP_HORREA := StrTran(Left(Time(),5),":","")
DWP->DWP_USER   := RetCodUsr()
MsUnlock()

For nCnt:= 1 To Len(aCols)
	If !GDDeleted(nCnt) .And. ( aCols[nCnt,GDFieldPos("DVE_PERREA")] <> 0 .Or. ;
		aCols[nCnt,GDFieldPos("DVO_PERMIN")] <> 0 .Or. aCols[nCnt,GDFieldPos("DVO_PERAJU")] <> 0 )
		RecLock("DWQ",.T.)
		DWQ->DWQ_FILIAL := xFilial("DWQ")
		DWQ->DWQ_NUMIDE := DWP->DWP_NUMIDE
		DWQ->DWQ_CODPAS := aCols[nCnt,GDFieldPos("DVE_CODPAS")]
		DWQ->DWQ_PERREA := aCols[nCnt,GDFieldPos("DVE_PERREA")]
		DWQ->DWQ_PERMIN := aCols[nCnt,GDFieldPos("DVO_PERMIN")]
		DWQ->DWQ_PERAJU := aCols[nCnt,GDFieldPos("DVO_PERAJU")]
		MsUnlock()
	EndIf
Next nCnt

If __lSx8
	ConfirmSx8()
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsAtuSXB ³ Autor ³TOTVS S/A              ³ Data ³ 09/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza SXB.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsAtuSXB()
Local aAreaAnt := GetArea()
Local aSXB     := {}
Local aEstrut  := {}
Local cAlias   := ""
Local i        := 0
Local j        := 0
Local lSXB     := .F.

aEstrut:= {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM"}

dbSelectArea("SXB")
dbSetOrder(1)

If	SXB->( ! DbSeek("DTL") )

	AAdd(aSXB,{	Padr('DTL',Len(SXB->XB_ALIAS)),;	//Alias
			'1',;									//Tipo
			'01',;									//Sequencia
			'DB',;									//Coluna
			'Tab Frete a Receber',;					//Descricao
			'Tab Flete por Cobrar',;				//Descricao - Espanhol
			'Freight Receiv.Table',;				//Descricao - Ingles
			'DTL'} )								//Contem

	AAdd(aSXB,{	Padr('DTL',Len(SXB->XB_ALIAS)),;	//Alias
			'2',;									//Tipo
			'01',;									//Sequencia
			'01',;									//Coluna
			'Tab.Frete Tipo',;						//Descricao
			'Tab.Flete Tipo',;						//Descricao - Espanhol
			'Tp.Freight Table',;					//Descricao - Ingles
			'   '} )								//Contem

	AAdd(aSXB,{	Padr('DTL',Len(SXB->XB_ALIAS)),;	//Alias
			'4',;									//Tipo
			'01',;									//Sequencia
			'01',;									//Coluna
			'Tabela de Frete',;						//Descricao
			'Tabla de Flete',;						//Descricao - Espanhol
			'Freight Table',;						//Descricao - Ingles
			'DTL_TABFRE'} )							//Contem

	AAdd(aSXB,{	Padr('DTL',Len(SXB->XB_ALIAS)),;	//Alias
			'4',;									//Tipo
			'01',;									//Sequencia
			'02',;									//Coluna
			'Tipo da Tabela',;						//Descricao
			'Tipo de Tabla',;						//Descricao - Espanhol
			'Table Type',;							//Descricao - Ingles
			'DTL_TIPTAB'} )							//Contem

	AAdd(aSXB,{	Padr('DTL',Len(SXB->XB_ALIAS)),;	//Alias
			'4',;									//Tipo
			'01',;									//Sequencia
			'03',;									//Coluna
			'Desc. Tipo da Tabela',;				//Descricao
			'Desc. Tipo de Tabla',;					//Descricao - Espanhol
			'table Type Desc.',;					//Descricao - Ingles
			'Tabela("M5",DTL->DTL_TIPTAB,.F.)'} )	//Contem
			
	AAdd(aSXB,{	Padr('DTL',Len(SXB->XB_ALIAS)),;	//Alias
			'4',;									//Tipo
			'01',;									//Sequencia
			'04',;									//Coluna
			'Ini.Vigencia',;						//Descricao
			'Ini.Vigencia',;						//Descricao - Espanhol
			'Begn.of Validity',;					//Descricao - Ingles
			'DTL_DATDE'} )							//Contem

	AAdd(aSXB,{	Padr('DTL',Len(SXB->XB_ALIAS)),;	//Alias
			'4',;									//Tipo
			'01',;									//Sequencia
			'05',;									//Coluna
			'Fim Vigencia',;						//Descricao
			'Fin Vigencia',;						//Descricao - Espanhol
			'End of Validity',;						//Descricao - Ingles
			'DTL_DATATE'} )							//Contem

	AAdd(aSXB,{	Padr('DTL',Len(SXB->XB_ALIAS)),;	//Alias
			'5',;									//Tipo
			'01',;									//Sequencia
			'',;									//Coluna
			'',;									//Descricao
			'',;									//Descricao - Espanhol
			'',;									//Descricao - Ingles
			'DTL->DTL_TABFRE'} )					//Contem

	AAdd(aSXB,{	Padr('DTL',Len(SXB->XB_ALIAS)),;	//Alias
			'5',;									//Tipo
			'02',;									//Sequencia
			'',;									//Coluna
			'',;		 							//Descricao
			'',;									//Descricao - Espanhol
			'',;									//Descricao - Ingles
			'DTL->DTL_TIPTAB'} )					//Contem

	AAdd(aSXB,{	Padr('DTL',Len(SXB->XB_ALIAS)),;	//Alias
			'6',;									//Tipo
			'01',;									//Sequencia
			'',;									//Coluna
			'',;									//Descricao
			'',;									//Descricao - Espanhol
			'',;									//Descricao - Ingles
			'DTL->DTL_CATTAB == "1"'} )				//Contem

EndIf

//--- DVH
If	SXB->( !DbSeek("DVH") )


	AAdd(aSXB,{	Padr('DVH',Len(SXB->XB_ALIAS)),;	//Alias
			'1',;									//Tipo
			'01',;									//Sequencia
			'DB',;									//Coluna
			'Tab Frete a Pagar',;					//Descricao
			'Tab Flete por Pagar',;					//Descricao - Espanhol
			'Freight Payab.Table',;					//Descricao - Ingles
			'DTL'} )								//Contem

	AAdd(aSXB,{	Padr('DVH',Len(SXB->XB_ALIAS)),;	//Alias
			'2',;									//Tipo
			'01',;									//Sequencia
			'01',;									//Coluna
			'Tab.Frete Tipo',;						//Descricao
			'Tab.Flete Tipo',;						//Descricao - Espanhol
			'Tp.Freight Table',;					//Descricao - Ingles
			'   '} )								//Contem

	AAdd(aSXB,{	Padr('DVH',Len(SXB->XB_ALIAS)),;	//Alias
			'4',;									//Tipo
			'01',;									//Sequencia
			'01',;									//Coluna
			'Tabela de Frete',;						//Descricao
			'Tabla de Flete',;						//Descricao - Espanhol
			'Freight Table',;						//Descricao - Ingles
			'DTL_TABFRE'} )							//Contem

	AAdd(aSXB,{	Padr('DVH',Len(SXB->XB_ALIAS)),;	//Alias
			'4',;									//Tipo
			'01',;									//Sequencia
			'02',;									//Coluna
			'Tipo da Tabela',;						//Descricao
			'Tipo de Tabla',;						//Descricao - Espanhol
			'Table Type',;							//Descricao - Ingles
			'DTL_TIPTAB'} )							//Contem

	AAdd(aSXB,{	Padr('DVH',Len(SXB->XB_ALIAS)),;	//Alias
			'4',;									//Tipo
			'01',;									//Sequencia
			'03',;									//Coluna
			'Desc. Tipo da Tabela',;				//Descricao
			'Desc. Tipo de Tabla',;					//Descricao - Espanhol
			'table Type Desc.',;					//Descricao - Ingles
			'Tabela("M5",DTL->DTL_TIPTAB,.F.)'} )	//Contem
			
	AAdd(aSXB,{	Padr('DVH',Len(SXB->XB_ALIAS)),;	//Alias
			'4',;									//Tipo
			'01',;									//Sequencia
			'04',;									//Coluna
			'Ini.Vigencia',;						//Descricao
			'Ini.Vigencia',;						//Descricao - Espanhol
			'Begn.of Validity',;					//Descricao - Ingles
			'DTL_DATDE'} )							//Contem

	AAdd(aSXB,{	Padr('DVH',Len(SXB->XB_ALIAS)),;	//Alias
			'4',;									//Tipo
			'01',;									//Sequencia
			'05',;									//Coluna
			'Fim Vigencia',;						//Descricao
			'Fin Vigencia',;						//Descricao - Espanhol
			'End of Validity',;						//Descricao - Ingles
			'DTL_DATATE'} )							//Contem

	AAdd(aSXB,{	Padr('DVH',Len(SXB->XB_ALIAS)),;	//Alias
			'5',;									//Tipo
			'01',;									//Sequencia
			'',;									//Coluna
			'',;									//Descricao
			'',;									//Descricao - Espanhol
			'',;									//Descricao - Ingles
			'DTL->DTL_TABFRE'} )					//Contem

	AAdd(aSXB,{	Padr('DVH',Len(SXB->XB_ALIAS)),;	//Alias
			'5',;									//Tipo
			'02',;									//Sequencia
			'',;									//Coluna
			'',;		 							//Descricao
			'',;									//Descricao - Espanhol
			'',;									//Descricao - Ingles
			'DTL->DTL_TIPTAB'} )					//Contem

	AAdd(aSXB,{	Padr('DVH',Len(SXB->XB_ALIAS)),;	//Alias
			'6',;									//Tipo
			'01',;									//Sequencia
			'',;									//Coluna
			'',;									//Descricao
			'',;									//Descricao - Espanhol
			'',;									//Descricao - Ingles
			'DTL->DTL_CATTAB == "2"'} )				//Contem

EndIf

ProcRegua(Len(aSXB))
dbSelectArea("SXB")
dbSetOrder(1)
For i:= 1 To Len(aSXB)
	If !Empty(aSXB[i][1])
		If !dbSeek(aSXB[i,1]+aSXB[i,2]+aSXB[i,3]+aSXB[i,4])
			lSXB := .T.
			RecLock("SXB",.T.)
			If !(aSXB[i,1]$cAlias)
				cAlias += aSXB[i,1]+"/"
			Endif
			For j:=1 To Len(aSXB[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSXB[i,j])
				EndIf
			Next j
			dbCommit()
			MsUnLock()
			IncProc("Atualizando Consultas Padroes...")
		EndIf
	EndIf
Next i

RestArea(aAreaAnt)
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMS690Pag ³ Autor ³Valdemar Roberto Mognon³ Data ³ 31/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define quebra de paginação da query                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³TMS690Pag()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA690                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TMS690Pag(cRecno,cAlias,cTabOri,cTipOri,oTrabOri,oTrabDes,cProdOri,cProdAte,cCdrOri,cCdrDes,nRegIni)
Local cQuery := ""

Default cRecno   := ""
Default cAlias   := ""
Default cTabOri  := ""
Default cTipOri  := ""
Default oTrabOri := Nil
Default oTrabDes := Nil
Default cProdOri := ""
Default cProdAte := ""
Default cCdrOri  := ""
Default cCdrDes  := ""
Default nRegIni  := 0

cQuery := "SELECT MIN(R_E_C_N_O_) MIN_RECNO, MAX(R_E_C_N_O_) MAX_RECNO, COUNT(R_E_C_N_O_) QTD_RECNO " 
cQuery += "  FROM "+RetSqlName(cAlias) + " " + cAlias + " "
cQuery += " WHERE "+cAlias+"_FILIAL  = '"+xFilial(cAlias)+"'"
cQuery += "   AND "+cAlias+"_TABFRE  = '" +cTabOri + "'"
cQuery += "   AND "+cAlias+"_TIPTAB  = '" +cTipOri + "'"
cQuery += "   AND R_E_C_N_O_ >= "+Str(nRegIni)
If cAlias <> 'DTF' .And. cAlias <> 'DTG' .And. cAlias <> 'DW0' .And. cAlias <> 'DY0' .And. cAlias <> 'DY9' .And. cAlias <> 'DYA' .And. cAlias <> 'DYG'
	If !Empty(cCdrOri)
		cQuery += "	AND "+cAlias+"_CDRORI IN ( SELECT TRB_GRPVEN FROM " + oTrabOri:GetRealName() + " )"
	Else
		cQuery += " AND "+cAlias+"_CDRORI BETWEEN '"+Space(Len(DT0->DT0_CDRORI)) +"'AND'"+Replicate("Z",Len(DT0->DT0_CDRORI))+"'"
	EndIf

	If !Empty(cCdrDes)
		cQuery += " AND "+cAlias+"_CDRDES IN ( SELECT TRB_GRPVEN FROM " + oTrabDes:GetRealName() + " )"
	Else
		cQuery += " AND "+cAlias+"_CDRDES BETWEEN '"+Space(Len(DT0->DT0_CDRDES)) +"'AND'"+Replicate("Z",Len(DT0->DT0_CDRDES))+"'"
	EndIf
	cQuery += " AND "+cAlias+"_CODPRO BETWEEN '"+cProdOri+"' AND '"+cProdAte+"'"
EndIf
cQuery += "  AND D_E_L_E_T_  = ' '"
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cRecno, .F., .T.)

Return
