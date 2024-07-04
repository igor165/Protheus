#INCLUDE "FIVEWIN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TMSA750.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#DEFINE CRLF Chr(10)

STATIC lTMA750CLI:= ExistBlock('TMA750CLI')

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMSA750   º Autor ³ Fernando Salvatori º Data ³  03/01/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Reajuste de Precos por Cliente.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA750()
Local cFilMbrow := "DVC_FILIAL = '" + xFilial("DVC") + "'"
Local aCampos   := {	{ STR0023,"DVC_CODCLI" },;				//"Cod. Cliente"
						{ STR0024,"DVC_LOJCLI" },;				//"Loja Cliente"
						{ STR0025,'CriaVar("DVC_NOMCLI")' } }	//"Nome Cliente"

Private aLayOut   := {}      //Configuracao das tabelas
Private aFolder   := {}
Private cCadastro := STR0001  //"Reajuste de Preços por Cliente"
Private aRotina   := MenuDef()

aLayOut := TMSLayOutTab('1;A') //Configuracao das Tabelas de Frete

If Empty( aLayOut )
	Return .F.
EndIf

dbSelectArea("DVC")
dbSetOrder(5) //DVC_FILIAL+DVC_SEQTAB+DVC_CODCLI+DVC_LOJCLI+DVC_TABFRE+DVC_CDRORI+DVC_CRDDES
mBrowse(6,1,22,75,"DVC",aCampos,,,,,,,,,,,,,cFilMbrow)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMSA750Manº Autor ³ Fernando Salvatori º Data ³  03/01/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Manutencao de Reajuste de Precos por Cliente.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 -> Alias do sistema                                  º±±
±±º          ³ ExpN1 -> Posicao do Registro                               º±±
±±º          ³ ExpN2 -> Opcao Selecionada                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA750Man(cAlias,nRecno,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis de Calculo de Dimensao da Janela Principal                    ³

Local aInfo     := {}
Local aPosObj   := {}
Local aObjects  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis de Objeto.                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oDlg
Local oPanCabec
Local oPanRodape
Local oChkPerc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis de utilizacao do Processamento do Programa.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cTabela       := ""
Local cTipTab       := ""
Local cTabGet       := If(nOpc == 3,Replicate("*",Len(DVC->DVC_TABFRE)),Space(Len(DVC->DVC_TABFRE)))
Local cTipGet       := If(nOpc == 3,Replicate("*",Len(DVC->DVC_TIPTAB)),Space(Len(DVC->DVC_TIPTAB)))
Local cDescTipo     := ""
Local cDeServico    := Space( TamSX3("DC5_SERVIC")[1] )
Local cDescDeServ   := ""
Local cAteServico   := Replicate("Z",TamSX3("DC5_SERVIC")[1] )
Local cDescAteServ  := ""
Local cDeProduto    := Space( TamSX3("B1_COD")[1] )
Local cDescDeProd   := ""
Local cAteProduto   := Replicate("Z",TamSX3("B1_COD")[1] )
Local cDescAteProd  := ""
Local cDeCliente    := Space( TamSX3("A1_COD")[1] )
Local cDeLoja       := Space( TamSX3("A1_LOJA")[1] )
Local cDescDeClien  := ""
Local cAteCliente   := Replicate("Z",TamSX3("A1_COD")[1] )
Local cAteLoja      := Replicate("Z",TamSX3("A1_LOJA")[1] )
Local cDescAteClien := ""
Local cOriRegiao    := Space( TamSX3("DTC_CDRCAL")[1] )
Local cDescOriReg   := ""
Local cDestRegiao   := Space( TamSX3("DTC_CDRCAL")[1] )
Local cDescDestReg  := ""
Local cDeNegoc      := Space( 6 )
Local cDesDeNeg     := Space( 30 )
Local cAteNegoc     := Replicate("Z", 6 )
Local cDesAteNeg    := Space( 30 )
Local lOk           := .T.
Local aAlter        := {}
Local aSize         := MsAdvSize()
Local nPosPerRea    := 0
Local nPosPerMin    := 0
Local nPosPerExc    := 0
Local cSeekWhile    := ""
Local nCntFor       := 0
Local aTam          := {}
Local nPosLayOut    := ""
Local aAreaDVC      := DVC->(GetArea())
Local cTipFre       := "" 
Local nOpcTipFre    := 1
Local cAliasQry     := GetNextAlias()
Local aArea         := {}

Local oCbx, o1Cbx
Private aHeader     := {}
Private aCols       := {}
Private lChkPerc    := .F.
Private oGetDados

nOpc := aRotina[nOpc][4]

If nOpc == 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para opcao de Inclusao, carregar a Configuracao das Tabelas para selecao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !TMSABrowse( aLayOut, STR0008,,,,.F., { STR0009, STR0010, STR0047 } )//"Escolha a Configuracao desta Tabela de Frete"//"Tabela de Frete"###"Descricao"
		Return .F.
	EndIf

	For nCntFor := 1 To Len( aLayOut )
		If aLayOut[ nCntFor ][1]
			cTabLay := Left( aLayOut[ nCntFor ][2], Len(DVC->DVC_TABFRE) )
			cTipLay := Left( aLayOut[ nCntFor ][3], Len(DVC->DVC_TIPTAB) )
			If !(cTabLay $ cTabela)
				cTabela += "'"+cTabLay+"',"
			EndIf
			If !(cTipLay $ cTipTab)
				cTipTab += "'"+cTipLay+"',"
			EndIf
		EndIf
	Next

	cTabela := Substr(cTabela,1,Len(cTabela) - 1)
	cTipTab := Substr(cTipTab,1,Len(cTipTab) - 1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as posicoes da GetDados e Paineis.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

AAdd( aObjects, {  100, 080, .T., .F., .T. } ) //Painel Cabecalho
AAdd( aObjects, {  100, 100, .T., .T. } )      //MsGetDados
AAdd( aObjects, {  100, 015, .T., .F., .T. } ) //Painel Rodape

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects, .T. , .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as variaveis de Memoria.                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory( "DT0" , (nOpc == 3) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrego as variaveis aHeader e aCols para utilizar na GetDados Principal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aAlter , "DVE_PERREA" )
AAdd( aAlter , "DVO_PERMIN" )
AAdd( aAlter , "DVO_PERAJU" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aHeader.                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := {}
aTam:=TamSX3("DVE_CODPAS")	
Aadd(aHeader,{RetTitle("DVE_CODPAS"),"DVE_CODPAS"	,PesqPict("DVE","DVE_CODPAS",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DVE"," "})
aTam:=TamSX3("DVE_DESPAS")	
Aadd(aHeader,{RetTitle("DVE_DESPAS"),"DVE_DESPAS"	,PesqPict("DVE","DVE_DESPAS",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DVE"," "})
aTam:=TamSX3("DVO_PERMIN")	
Aadd(aHeader,{RetTitle("DVE_PERREA"),"DVE_PERREA"	,PesqPict("DVO","DVO_PERMIN",atam[1]),aTam[1],aTam[2],"",USADO, "N" ,"DVE"," "})
aTam:=TamSX3("DVO_PERMIN")	
Aadd(aHeader,{'% Minimo',"DVO_PERMIN"				,PesqPict("DVO","DVO_PERMIN",atam[1]),aTam[1],aTam[2],"",USADO, "N" ,"DVO"," "})
aTam:=TamSX3("DVO_PERAJU")	
Aadd(aHeader,{'% Excedente',"DVO_PERAJU"			,PesqPict("DVO","DVO_PERAJU",atam[1]),aTam[1],aTam[2],"",USADO, "N" ,"DVO"," "})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aCols.                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpc == 3

	Inclui := .F.
	aArea  := GetArea()

	//-- Busca os componentes da Tabela de Frete selecionada
	cQuery := " SELECT DT3_CODPAS,DT3_DESCRI "
	cQuery += "	  FROM " + RetSqlName("DVE") + " DVE, "
	cQuery += RetSqlName("DT3") + " DT3 "
	cQuery += "	  WHERE DVE_FILIAL = '" + xFilial('DVE') + "' " 
	If At(",",cTabela) > 0
		cQuery += "  AND DVE_TABFRE IN ( "+cTabela+" )"
	Else
		cQuery += "  AND DVE_TABFRE = "+cTabela
	EndIf

	If At(",",cTipTab) > 0
		cQuery += "	 AND DVE_TIPTAB IN ( "+cTipTab+" )"
	Else
		cQuery += "	 AND DVE_TIPTAB = "+cTipTab
	EndIf
	cQuery += "	    AND DVE.D_E_L_E_T_ = ' '"
	cQuery += "	    AND DT3_FILIAL = '" + xFilial('DT3') + "' "
	cQuery += "	    AND DT3_CODPAS = DVE_CODPAS "
	cQuery += "	    AND DT3.D_E_L_E_T_ = ' ' "
	cQuery += "	ORDER BY DT3_FILIAL, DT3_CODPAS "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry ) 

	While (cAliasQry)->(!Eof())
		If Ascan(aCols, {|x| x[1] == (cAliasQry)->DT3_CODPAS }) == 0
			AAdd(aCols,{(cAliasQry)->DT3_CODPAS, (cAliasQry)->DT3_DESCRI, 0, 0, 0, .F.})
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

	Inclui := .T.

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para atualizacao do aCols conforme selecao do Check Box.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosPerRea := aScan( aHeader, {|ExpA1| RTrim( ExpA1[2] ) == "DVE_PERREA" })
nPosPerMin := aScan( aHeader, {|ExpA1| RTrim( ExpA1[2] ) == "DVO_PERMIN" })
nPosPerExc := aScan( aHeader, {|ExpA1| RTrim( ExpA1[2] ) == "DVO_PERAJU" })

If Empty(aHeader[nPosPerRea][6])
	aHeader[nPosPerRea][6] := "TMSA750Reaj(lChkPerc,oGetDados)"
Else
	aHeader[nPosPerRea][6] += ".And. TMSA750Reaj(lChkPerc,oGetDados)"
EndIf

If nPosPerMin > 0
	If Empty(aHeader[nPosPerMin][6])
		aHeader[nPosPerMin][6] := "TMSA750Reaj(lChkPerc,oGetDados)"
	Else
		aHeader[nPosPerMin][6] += ".And. TMSA750Reaj(lChkPerc,oGetDados)"
	EndIf
EndIf

If nPosPerExc > 0
	If Empty(aHeader[nPosPerExc][6])
		aHeader[nPosPerExc][6] := "TMSA750Reaj(lChkPerc,oGetDados)"
	Else
		aHeader[nPosPerExc][6] += ".And. TMSA750Reaj(lChkPerc,oGetDados)"
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicoes da tela de Manutencao de Reajuste de Precos.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpc == 5 .Or. nOpc == 6
	aSize[6] := aPosObj[1][4] * 4
EndIf

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL

oPanCabec := TPanel():New( aPosObj[1][1],aPosObj[1][2], "", oDlg, NIL, .T., .F.,NIL, NIL, aPosObj[1][3], aPosObj[1][4], .T., .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos utilizados pela tela.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

@ 05,001 SAY STR0011          SIZE 30,9  OF oPanCabec PIXEL RIGHT //"Tabela"
@ 05,034 MSGET cTabGet        SIZE 25,9  OF oPanCabec PIXEL PICTURE "@!" F3 "DTL" WHEN IIf( nOpc == 3,.F.,.T.)

@ 05,003 SAY STR0012          SIZE 72,9  OF oPanCabec PIXEL RIGHT //"Tipo"
@ 05,077 MSGET cTipGet        SIZE 25,9  OF oPanCabec PIXEL PICTURE "@!" F3 "M5" VALID Empty(cTipGet) .Or. TMSA750VlTab("M5",cTipGet, @cDescTipo) WHEN IIf( nOpc == 3,.F.,.T.)
@ 05,103 MSGET cDescTipo      SIZE 90,9  OF oPanCabec PIXEL WHEN .F.

@ 20,001 SAY STR0013          SIZE 30,9  OF oPanCabec PIXEL RIGHT //"De Serviço"
@ 20,034 MSGET cDeServico     SIZE 25,9  OF oPanCabec PIXEL PICTURE "@!" F3 "DC5" VALID TMSA750VlTab("L4",cDeServico, @cDescDeServ)
@ 20,061 MSGET cDescDeServ    SIZE 100,9 OF oPanCabec PIXEL WHEN .F.

@ 35,001 SAY STR0014          SIZE 30,9  OF oPanCabec PIXEL RIGHT //"Até Serviço"
@ 35,034 MSGET cAteServico    SIZE 25,9  OF oPanCabec PIXEL PICTURE "@!" F3 "DC5" VALID TMSA750VlTab("L4",cAteServico, @cDescAteServ)
@ 35,061 MSGET cDescAteServ   SIZE 100,9 OF oPanCabec PIXEL WHEN .F.

@ 50,001 SAY STR0015          SIZE 30,9  OF oPanCabec PIXEL RIGHT //"De Produto"
@ 50,034 MSGET cDeProduto     SIZE 50,9  OF oPanCabec PIXEL PICTURE "@!" F3 "SB1" VALID TMSA750VlBase("SB1", 1, xFilial( "SB1" )+cDeProduto, "SB1->B1_DESC", @cDescDeProd)
@ 50,086 MSGET cDescDeProd    SIZE 100,9 OF oPanCabec PIXEL WHEN .F.

@ 65,001 SAY STR0016          SIZE 30,9  OF oPanCabec PIXEL RIGHT //"Até Produto"
@ 65,034 MSGET cAteProduto    SIZE 50,9  OF oPanCabec PIXEL PICTURE "@!" F3 "SB1" VALID TMSA750VlBase("SB1", 1, xFilial( "SB1" )+cAteProduto, "SB1->B1_DESC", @cDescAteProd)
@ 65,086 MSGET cDescAteProd   SIZE 100,9 OF oPanCabec PIXEL WHEN .F.

@ 05,001 SAY STR0017          SIZE 222,9 OF oPanCabec PIXEL RIGHT //"De Cliente"
@ 05,226 MSGET cDeCliente     SIZE 35,9  OF oPanCabec PIXEL PICTURE "@!" F3 "SA1" VALID TMSA750VlBase("SA1", 1, xFilial( "SA1" ) + cDeCliente + AllTrim(cDeLoja), "SA1->A1_NOME", @cDescDeClien)
@ 05,001 SAY STR0018          SIZE 276,9 OF oPanCabec PIXEL RIGHT //"Loja"
@ 05,278 MSGET cDeLoja        SIZE 15,9  OF oPanCabec PIXEL VALID TMSA750VlBase("SA1", 1, xFilial( "SA1" ) + cDeCliente + cDeLoja, "SA1->A1_NOME", @cDescDeClien)
@ 05,295 MSGET cDescDeClien   SIZE 90,9  OF oPanCabec PIXEL WHEN .F.

@ 20,001 SAY STR0019          SIZE 222,9 OF oPanCabec PIXEL RIGHT //"Até Cliente"
@ 20,226 MSGET cAteCliente    SIZE 35,9  OF oPanCabec PIXEL PICTURE "@!" F3 "SA1" VALID TMSA750VlBase("SA1", 1, xFilial( "SA1" ) + cAteCliente + AllTrim(cAteLoja), "SA1->A1_NOME", @cDescAteClien)
@ 20,001 SAY STR0018          SIZE 276,9 OF oPanCabec PIXEL RIGHT
@ 20,278 MSGET cAteLoja       SIZE 15,9  OF oPanCabec PIXEL VALID TMSA750VlBase("SA1", 1, xFilial( "SA1" ) + cAteCliente + cAteLoja, "SA1->A1_NOME", @cDescAteClien)
@ 20,295 MSGET cDescAteClien  SIZE 90,9  OF oPanCabec PIXEL WHEN .F.

@ 35,001 SAY STR0020          SIZE 222,9 OF oPanCabec PIXEL RIGHT //"Região Origem"
@ 35,226 MSGET cOriRegiao     SIZE 35,9  OF oPanCabec PIXEL PICTURE "@!" F3 "DUY" VALID TMSA750VlBase("DUY", 1, xFilial( "DUY" ) + cOriRegiao, "DUY->DUY_DESCRI", @cDescOriReg)
@ 35,264 MSGET cDescOriReg    SIZE 90,9  OF oPanCabec PIXEL WHEN .F.

@ 50,001 SAY STR0021          SIZE 222,9 OF oPanCabec PIXEL RIGHT //"Região Destino"
@ 50,226 MSGET cDestRegiao    SIZE 35,9  OF oPanCabec PIXEL PICTURE "@!" F3 "DUY" VALID TMSA750VlBase("DUY", 1, xFilial( "DUY" ) + cDestRegiao, "DUY->DUY_DESCRI", @cDescDestReg)
@ 50,264 MSGET cDescDestReg   SIZE 90,9  OF oPanCabec PIXEL WHEN .F.

//-- Formata Variaveis Conforme Dicionário De Dados
cDeNegoc      := Space(TamSX3("DDB_CODNEG")[1])
cDesDeNeg     := Space(TamSX3("DDB_DESCRI")[1])
cAteNegoc     := Replicate("Z", TamSX3("DDB_CODNEG")[1])
cDesAteNeg    := Space(TamSX3("DDB_DESCRI")[1])

@ 05,380 SAY STR0048          SIZE 50,9  OF oPanCabec PIXEL RIGHT //"De Negociacao"
@ 05,435 MSGET cDeNegoc       SIZE 25,9  OF oPanCabec PIXEL PICTURE "@!" F3 "DDB" VALID TMSA750VlBase("DDB", 1, xFilial( "DDB" )+cDeNegoc, "DDB->DDB_DESCRI", @cDesDeNeg)
@ 05,470 MSGET cDesDeNeg      SIZE 100,9 OF oPanCabec PIXEL WHEN .F.
	
@ 20,380 SAY STR0049          SIZE 50,9  OF oPanCabec PIXEL RIGHT //"Ate Negociacao"
@ 20,435 MSGET cAteNegoc      SIZE 25,9  OF oPanCabec PIXEL PICTURE "@!" F3 "DDB" VALID TMSA750VlBase("DDB", 1, xFilial( "DDB" )+cAteNegoc, "DDB->DDB_DESCRI", @cDesAteNeg)
@ 20,470 MSGET cDesAteNeg     SIZE 100,9 OF oPanCabec PIXEL WHEN .F.


If nOpc == 3 // Incluir
	@ 65,001 SAY STR0031 SIZE 222,9 OF oPanCabec PIXEL RIGHT //"Tipo Frete ? "
	@ 65,226 COMBOBOX o1Cbx VAR cTipFre ITEMS {STR0032,STR0033,STR0032 + '/' + STR0033,STR0034} SIZE 35,9 OF oPanCabec PIXEL ON CHANGE (nOpcTipFre:=o1Cbx:nAt) //"CIF"###"FOB"###"CIF/FOB"###"Todos"
EndIf

If nOpc != 5 .And. nOpc != 6

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ GetDados Principal.                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oGetDados  := MsGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4],nOpc,"TMSA750LinOk",,,.T.,aAlter,,.F.,Len( aCols ),,,,,oDlg)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Paineis principais.                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	oPanRodape := TPanel():New( aPosObj[3][1],aPosObj[3][2], "", oDlg, NIL, .T., .F.,NIL, NIL, aPosObj[3][3], aPosObj[3][4], .T., .F. )
	oChkPerc   := tCheckBox():New(2,3,STR0022,{|u|IIf(PCount() > 0,TMSA750Reaj(lChkPerc := u,oGetDados),lChkPerc)},oPanRodape,100,10,,,,,,,,.T.)

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Init e Ativacao do Dialog. (Janela Principal)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| IIf( (lOk := TMSA750TudoOk(nOpc)) ,oDlg:End(),NIL)},{|| lOk := .F.,oDlg:End() },,)  )

If lOk .And. nOpc != 2
	If nOpc <> 3
		cTabela := cTabGet
		cTipTab := cTipGet
	EndIf

	Processa({|| TMSA750Grv(cTabela,cTipTab,cDeServico,cAteServico,cDeProduto,cAteProduto,cDeCliente,cDeLoja,cAteCliente,cAteLoja,cOriRegiao,cDestRegiao,nOpc,nOpcTipFre,,,,,,cDeNegoc,cAteNegoc)}, STR0035 ) //"Aguarde, Atualizando Arquivos ..."

	//-- Nao chama novamente a tela, qd for inclusao
	MBRCHGLoop()
EndIf

RestArea(aAreaDVC)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMSA750Linº Autor ³ Fernando Salvatori º Data ³  03/01/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao da linha da MsGetDados Principal.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ True para linha validada / False para inconsistencias      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA750                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA750LinOk()
Local lRet := .T.
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMSA750Tudº Autor ³ Fernando Salvatori º Data ³  03/01/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao de todas as informacoes da tela de Reajuste de   º±±
±±º          ³ precos                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ True para informacoes validadas                            º±±
±±º          ³ False para inconsistencia nas informacoes                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA750                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA750TudoOk(nOpc)
Local lRet       := .T.
Local nPosPerRea := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVE_PERREA"})
Local nPosPerMin := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVO_PERMIN"})
Local nPosPerAju := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVO_PERAJU"})

If nOpc == 3 .And. ( Ascan(aCols, {|x| x[nPosPerRea] <> 0 }) == 0 ) .And.;
	( Ascan(aCols, {|x| x[nPosPerMin] <> 0 }) == 0 ) .And. ;
	( Ascan(aCols, {|x| x[nPosPerAju] <> 0 }) == 0 )
	Help('',1,'TMSA75003') // Informe um Percentual de Reajuste
	Return ( .F. )
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMSA750VlBº Autor ³ Fernando Salvatori º Data ³  03/01/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao do registro na base de dados selecionada         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³  ExpC1 -> Alias Corrente                                   º±±
±±º          ³  ExpC2 -> Ordem selecionada                                º±±
±±º          ³  ExpC3 -> Registro a Pesquisar                             º±±
±±º          ³  ExpC4 -> Campo que deseja retornar                        º±±
±±º          ³  ExpC5 -> Variavel que sera atualizada                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ True para linha validada / False para inconsistencias      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA750                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSA750VlBase(cAlias, nOrdem, cCodigo, cCpoRet, cDescricao)
Local lRet := .T.
Local aArea := GetArea()

Default cAlias  := ""
Default nOrdem  := 1
Default cCodigo := ""
Default cCpoRet := ""

If Empty( cAlias ) .Or. Empty( cCpoRet )
	Return .F.
EndIf

If cAlias != "DUY" .Or. (cAlias == "DUY" .And. !Empty(SubStr(cCodigo,Len(xFilial(cAlias)) + 1)))
	dbSelectArea( cAlias )
	dbSetOrder( nOrdem )
	MsSeek( cCodigo )
	
	cDescricao := ""
	
	If Found()
		cDescricao := &cCpoRet
	EndIf
EndIf

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMSA750VlTº Autor ³ Fernando Salvatori º Data ³  03/01/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao do campo na estrutura de tabelas (SX5)           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³  ExpC1 -> Codigo do Servico                                º±±
±±ºParametros³ @ExpC2 -> Descricao do Servico                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ True para linha validada / False para inconsistencias      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA750                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSA750VlTab(cTabela, cCodigo, cDescricao)
Local lRet := .T.

cDescricao := Tabela(cTabela,cCodigo,.F.)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMSA750Reaº Autor ³ Fernando Salvatori º Data ³  03/01/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Repete o percentual de reajuste para todas as linhas       º±±
±±º          ³ do aCols atual                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpL1 -> Houve a selecao do check box ou nao               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA750                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA750Reaj(lChecked,oGetDados)
Local nPosPerRea := aScan( aHeader, {|ExpA1| RTrim( ExpA1[2] ) == "DVE_PERREA" })
Local nPosPerMin := aScan( aHeader, {|ExpA1| RTrim( ExpA1[2] ) == "DVO_PERMIN" })
Local nPosPerExc := aScan( aHeader, {|ExpA1| RTrim( ExpA1[2] ) == "DVO_PERAJU" })
Local nPosDTKMax := aScan( aHeader, {|ExpA1| RTrim( ExpA1[2] ) == "DTK_VALMAX" })
Local nPosDY1Min := aScan( aHeader, {|ExpA1| RTrim( ExpA1[2] ) == "DY1_VALMIN" })
Local nPosDY1Max := aScan( aHeader, {|ExpA1| RTrim( ExpA1[2] ) == "DY1_VALMAX" })
Local nPercRea   := aCols[n][nPosPerRea]
Local nPercMin   := 0
Local nPercExc   := 0
Local nDtkMax    := 0
Local nDy1Min    := 0
Local nDy1Max    := 0

If lChecked
	//-- Se estiver posicionado no campo '% Reajuste'
	If ReadVar() = 'M->DVE_PERREA'
		nPercRea := IIf(Empty(ReadVar()),aCols[n][nPosPerRea],&(ReadVar()))
		aEval( aCols,{|X,Y| aCols[Y][nPosPerRea] := nPercRea })
		If nPosPerMin > 0
			nPercMin	:= aCols[n][nPosPerMin]
			nPercExc	:= aCols[n][nPosPerExc]
			aEval( aCols,{|X,Y|	aCols[Y][nPosPerMin] := nPercMin ,;
								aCols[Y][nPosPerExc] := nPercExc} )
		EndIf
	//-- Se estiver posicionado no campo '% Minimo'
	ElseIf ReadVar() = 'M->DVO_PERMIN'
		nPercRea := aCols[n][nPosPerRea]
		nPercExc := aCols[n][nPosPerExc]
		aEval( aCols,{|X,Y|	aCols[Y][nPosPerRea] := nPercRea     ,;
							aCols[Y][nPosPerMin] := &(ReadVar()) ,;
							aCols[Y][nPosPerExc] := nPercExc })
	//-- Se estiver posicionado no campo '% Excesso'
	ElseIf ReadVar() = 'M->DVO_PERAJU'
		nPercRea := aCols[n][nPosPerRea]
		nPercMin := aCols[n][nPosPerMin]
		aEval( aCols,{|X,Y|	aCols[Y][nPosPerRea] := nPercRea ,;
							aCols[Y][nPosPerMin] := nPercMin ,;
							aCols[Y][nPosPerExc] := &(ReadVar()) })
	//-- Se estiver posicionado no campo '% Max. Tab. F.'
	ElseIf ReadVar() = 'M->DTK_VALMAX'
		nPercRea := aCols[n][nPosPerRea]
		nDtkMax  := aCols[n][nPosPerMin]
		aEval( aCols,{|X,Y|	aCols[Y][nPosPerRea] := nPercRea ,;
							aCols[Y][nPosPerMin] := nDtkMax ,;
							aCols[Y][nPosDTKMax] := &(ReadVar()) })
	//-- Se estiver posicionado no campo '% Min. Sub. F.'
	ElseIf ReadVar() = 'M->DY1_VALMIN'
		nPercRea := aCols[n][nPosPerRea]
		nDy1Min  := aCols[n][nPosPerMin]
		aEval( aCols,{|X,Y|	aCols[Y][nPosPerRea] := nPercRea ,;
							aCols[Y][nPosPerMin] := nDy1Min ,;
							aCols[Y][nPosDY1Min] := &(ReadVar()) })
	//-- Se estiver posicionado no campo '% Max. Sub. F.'
	ElseIf ReadVar() = 'M->DY1_VALMAX'
		nPercRea := aCols[n][nPosPerRea]
		nDy1Max  := aCols[n][nPosPerMin]
		aEval( aCols,{|X,Y|	aCols[Y][nPosPerRea] := nPercRea ,;
							aCols[Y][nPosPerMin] := nDy1Max ,;
							aCols[Y][nPosDY1Max] := &(ReadVar()) })
	Else
		//-- Se nao estiver posicionado em nenhum dos campos acima
		nPercRea := aCols[n][nPosPerRea]
		nDtkMax  := aCols[n][nPosPerMin]
		aEval( aCols,{|X,Y|	aCols[Y][nPosPerRea] := nPercRea })
		If nPosPerMin > 0
			nPercMin := aCols[n][nPosPerMin]
			nPercExc := aCols[n][nPosPerExc]
			aEval( aCols,{|X,Y|	aCols[Y][nPosPerMin] := nPercMin ,;
								aCols[Y][nPosPerExc] := nPercExc })
		EndIf
		If nDtkMax > 0 .And. nPosDTKMax > 0 
			nDtkMax	 := aCols[n][nPosDTKMax]
			nDy1Min	 := aCols[n][nPosDY1Min]
			nDy1Max	 := aCols[n][nPosDY1Max]
			aEval( aCols,{|X,Y|	aCols[Y][nPosDTKMax] := nDtkMax  ,;
								aCols[Y][nPosDY1Min] := nDy1Min  ,;
								aCols[Y][nPosDY1Max] := nDy1Max  })
		Else
			nPercRea := IIf(Empty(ReadVar()),aCols[n][nPosPerRea],&(ReadVar()))
			aEval( aCols,{|X,Y| aCols[Y][nPosPerRea] := nPercRea })
			If nPosPerMin > 0
				nPercMin	:= aCols[n][nPosPerMin]
				nPercExc	:= aCols[n][nPosPerExc]
				aEval( aCols,{|X,Y|	aCols[Y][nPosPerMin] := nPercMin ,aCols[Y][nPosPerExc] := nPercExc} )
			EndIf								
		EndIf
	EndIf
	oGetDados:oBrowse:Refresh()
EndIf

oGetDados:oBrowse:SetFocus()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMSA750Grvº Autor ³Patricia A.Salomao  º Data ³  12/04/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualizacao dos Arquivos                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 -> Tabela de Frete                                    º±±
±±º          ³ExpC2 -> Tipo de Tabela de Frete                            º±±
±±º          ³ExpC3 -> De Servico                                         º±±
±±º          ³ExpC4 -> Ate Servico                                        º±±
±±º          ³ExpC5 -> De Produto                                         º±±
±±º          ³ExpC6 -> Ate Produto                                        º±±
±±º          ³ExpC7 -> De Cliente                                         º±±
±±º          ³ExpC8 -> De Loja                                            º±±
±±º          ³ExpC9 -> Ate Cliente                                        º±±
±±º          ³ExpCA -> Ate Loja                                           º±±
±±º          ³ExpCB -> Regiao Origem                                      º±±
±±º          ³ExpCC -> Regiao Destino                                     º±±
±±º          ³ExpN1 -> Opcao selecionada                                  º±±
±±º          ³ExpN2 -> Opcao ComboBox (Tipo Frete?)                       º±±
±±º          ³ExpCD -> De Negociacao                                      º±±
±±º          ³ExpCE -> Ate Negociacao                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA750                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA750Grv(cTabela,cTipTab,cDeServico,cAteServico,cDeProduto,;
									cAteProduto,cDeCliente,cDeLoja,cAteCliente,cAteLoja, ;
									cOriRegiao,cDestRegiao,nOpc, nOpcTipFre, ;
									aServic, cNewTabela, cNewTipTab, lMantemPrc, a700VisErr, cDeNegoc, cAteNegoc )
Local cArqInd    := ""
Local nIndDVC    := 0
Local cSeekWhile := ""
Local cCdrOri    := ""
Local cCdrDes    := ""
Local cCodPro    := ""
Local cCliente   := ""
Local cLoja      := ""
Local cOrigem    := ""
Local cDestino   := ""
Local cProduto   := ""
Local cServico   := ""
Local nZ         := 0
Local lGravou    := .F.
Local aAreaDVC   := DVC->(GetArea())
Local cAliasDVC  := ''
Local lQuery     := .F.
Local cSeekDT0   := ''
Local aCampos    := {}
Local aArea      := {}
Local aOrigem    := {}
Local aDestino   := {}
Local nPerNewAju := nValAntAju := nValNewAju := nValor := nPosReaju := nPercAtu := 0
Local nPosCompon := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVE_CODPAS"} )
Local nPerNewExc := nPerNewExc := 0
Local cSqlOri    := ""
Local cSqlDes    := ""
Local aCliente   := {}
Local nCount     := 0
Local nCntFor    := 0
Local nI         := 0
Local nReg       := 0
Local nMin       := 0
Local nCliente   := 0
Local nRegIni    := 0
Local nRegFim    := 0
Local aEstruExp  := {}
Local cQuery     := ""
Local cAlias     := ""
Local aCliSeq    := {}
Local cCliSeq    := ""
Local cLojSeq    := ""
Local cTipFre    := ""
Local cFilCli    := ""
Local aFilCli    := {}
Local lTMALogGrv := ExistBlock("TMALOGGRV")
Local cMsg       := ""
Local cSqlSrv    := ""
Local lSeek      := .F.
Local lGrvAju    := .T.
Local lUmCliente := (cDeCliente == cAteCliente .And. cDeLoja == cAteLoja)
Local lUmProduto := (cDeProduto == cAteProduto)
Local cSeqTab    := Space(Len(DVC->DVC_SEQTAB))
Local lNovaTab   := (!Empty(cNewTabela) .And. !Empty(cNewTipTab))
Local aVisErr    := {}
Local aMsgErr    := {}
Local cGroup     := ""
Local cTabFreVar    := ""
Local cTipTabVar    := ""
Local lSubFaixa     := AliasInDic("DW2")
Local lExcSbF       := AliasInDic("DY2")
Local lDWR          := AliasInDic("DWP") .And. AliasInDic("DWQ")
Local nAlias        := If(lSubFaixa,5,4)
Local lCalcPrc      := .T.
Local cCliAtu       := ''
Local cLojAtu       := ''
Local cAliasTMP
Local lRet          := .T.
Local aClieSav      := {}
Local cCodNeg       := ""
Local cTempOri      := ""
Local cTempDes      := ""
Local aEstruOri     := {}
Local aEstruDes     := {}

Default cDeServico  := Replicate(" ",Len(DVD->DVD_SERVIC))
Default cAteServico := Replicate("Z",Len(DVD->DVD_SERVIC))
Default cDeProduto  := Replicate(" ",Len(DVD->DVD_CODPRO))
Default cAteProduto := Replicate("Z",Len(DVD->DVD_CODPRO))
Default cDeCliente  := Replicate(" ",Len(DVD->DVD_CODCLI))
Default cDeLoja     := Replicate(" ",Len(DVD->DVD_LOJCLI))
Default cAteCliente := Replicate("Z",Len(DVD->DVD_CODCLI))
Default cAteLoja    := Replicate("Z",Len(DVD->DVD_LOJCLI))
Default cOriRegiao  := ""
Default cDestRegiao := ""
Default aServic     := {}
Default cNewTabela  := ""
Default cNewTipTab  := ""
Default lMantemPrc  := .F.
Default nOpcTipFre  := 1
Default cDeNegoc    := Replicate(" ",6)
Default cAteNegoc   := Replicate("Z",6)
Private lTMSA700    := ( a700VisErr <> NIL )
Private cTrab       := CriaTrab(Nil,.F.)

/* Cria tabela Temporária do Alias */
While TCCanOpen( cTrab ) .And. !TCDelFile( cTrab )
	cTrab := CriaTrab(Nil,.F.)
EndDo

If lNovaTab .And. !lMantemPrc
	lCalcPrc := .F.
EndIf

cTipFre  := AllTrim(Str(nOpcTipFre))

If !Empty(cOriRegiao)
	
	//-- Determina Grupo Regiões Origem
	TmsNivInf(cOriRegiao,@aOrigem,,.T.)
	
	If Len(aOrigem) = 0
		aadd(aOrigem, {cOriRegiao})
	EndIf
	
	If ! Empty(aOrigem)
	
		cTempOri	:= CriaTrab(Nil,.F.)
		aEstruOri	:= {}
		
		//-- Determina Características Do Campo Da Tab. Temporária 
		aAdd(aEstruOri,{"TRB_REGORI","C",TamSX3("DUY_GRPVEN")[1],TamSX3("DUY_GRPVEN")[1]})
	
		//-- Cria Tabela Temporária
		While TCCanOpen( cTempOri ) .And. !TCDelFile( cTempOri )
			cTempOri := CriaTrab(Nil,.F.)
		EndDo
	
		CriaTmpDb("",cTempOri,aEstruOri)
		
		//-- Inclui Demais Regiões Do Vetor
		For nCount := 1 To Len(aOrigem)
	
			cInsert := "INSERT INTO " + cTempOri + " (TRB_REGORI, R_E_C_N_O_) "
			cInsert += "VALUES ('" + aOrigem[nCount][1] +"'," + Alltrim(Str(nCount + 1)) + ")"
			
			TcSqlExec(cInsert) 
	
		Next nCount
	EndIf

EndIf

If !Empty(cDestRegiao)
	
	//-- Determina Grupo Regiões Destino
	TmsNivInf(cDestRegiao,@aDestino,,.T.)

	If Len(aDestino) = 0
		aadd(aDestino, {cDestRegiao})
	EndIf

	If ! Empty(aDestino)
	
		cTempDes	:= CriaTrab(Nil,.F.)
		aEstruDes	:= {}
		
		//-- Determina Características Do Campo Da Tab. Temporária 
		aAdd(aEstruDes,{"TRB_REGDES","C",TamSX3("DUY_GRPVEN")[1],TamSX3("DUY_GRPVEN")[1]})
	
		//-- Cria Tabela Temporária
		While TCCanOpen( cTempDes ) .And. !TCDelFile( cTempDes )
			cTempDes := CriaTrab(Nil,.F.)
		EndDo
	
		CriaTmpDb("",cTempDes,aEstruDes)
		
		//-- Inclui Demais Regiões Do Vetor
		For nCount := 1 To Len(aDestino)
	
			cInsert := "INSERT INTO " + cTempDes + " (TRB_REGDES, R_E_C_N_O_) "
			cInsert += "VALUES ('" + aDestino[nCount][1] +"'," + Alltrim(Str(nCount + 1)) + ")"
			
			TcSqlExec(cInsert) 
	
		Next nCount
	EndIf
	
EndIf

//-- Array de Servicos
If Len(aServic) > 0
	For nCount := 1 To Len(aServic)
		cSqlSrv += "'" + aServic[nCount] + "',"
	Next
	cSqlSrv := Substr(cSqlSrv,1,Len(cSqlSrv) - 1)
EndIf
DbSelectArea("DVC")
If nOpc == 3 // Incluir
	//Cria as tabelas temporarias e retorna qual o nome foi usado para cada alias
	aAliasTmp := Tma750GTmp(lSubFaixa)

	If ExistBlock('TMA750FIL')
		aFilCli := ExecBlock('TMA750FIL',.F.,.F.)
		If ValType(aFilCli) == "A"
			For nCount := 1 To Len(aFilCli)
				cFilCli += aFilCli[nCount][1] + aFilCli[nCount][2] + ","
			Next
			cFilCli := Substr(cFilCli,1,Len(cFilCli) - 1)
		EndIf
	EndIf
	//-- Verifica a maior sequência no ajuste da nova tabela de frete
	If lNovaTab
		cQuery := "SELECT MAX(DVC_SEQTAB) SEQTAB FROM "
		cQuery += RetSqlName("DVC") + " DVC "
		cQuery += " WHERE DVC_FILIAL = '"+xFilial("DVC")+"'"
		cQuery += "   AND DVC_CODCLI = '"+cDeCliente+"'"
		cQuery += "   AND DVC_LOJCLI = '"+cDeLoja+"'"
		cQuery += "   AND DVC_TABFRE = '"+cNewTabela+"'"
		cQuery += "   AND DVC_TIPTAB = '"+cNewTipTab+"'"
		cQuery += "   AND DVC.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasNew := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
		If (cAliasNew)->(Eof()) .Or. Empty((cAliasNew)->SEQTAB)
			cSeqTab := StrZero(1,Len(DVC->DVC_SEQTAB))
		Else
			cSeqTab := Soma1((cAliasNew)->SEQTAB)
		EndIf
		(cAliasNew)->(dbCloseArea())
	EndIf
	For nCntFor := 1 To Len(aAliasTmp)
			aCliente := {}
			IncProc()
			cAlias := aAliasTmp[nCntFor,1]

		If !lUmCliente

			cMax   := GetNextAlias()
			cQuery := "SELECT " + cAlias+"_CODCLI CODCLI ," + cAlias+"_LOJCLI LOJCLI" 
			cQuery += "FROM "+RetSqlName(cAlias) + " " + cAlias + " "

			//-- Faz Inner Join Com Tabela Temporária Reg. Origem
			If !Empty(cOriRegiao)

				cQuery += " INNER JOIN " + cTempOri + " "
				cQuery += " ON " + cAlias + "_CDRORI = " + cTempOri + ".TRB_REGORI "
				
			EndIf

			//-- Faz Inner Join Com Tabela Temporária Reg. Destino
			If !Empty(cDestRegiao)

				cQuery += " INNER JOIN " + cTempDes + " "
				cQuery += " ON " + cAlias + "_CDRDES = " + cTempDes + ".TRB_REGDES "
				
			EndIf

			cQuery += "WHERE "+cAlias+"_FILIAL  = '"+xFilial(cAlias)+"'"

			If At(",",cTabela) > 0
				cQuery += "  AND "+cAlias+"_TABFRE IN ( "+cTabela+" )"
			Else
				cQuery += "  AND "+cAlias+"_TABFRE = "+cTabela
			EndIf

			If At(",",cTipTab) > 0
				cQuery += " AND "+cAlias+"_TIPTAB IN ( "+cTipTab+" )"
			Else
				cQuery += " AND "+cAlias+"_TIPTAB = "+cTipTab
			EndIf

			cQuery += " AND "+cAlias+"_CODCLI BETWEEN '"+cDeCliente+"'AND'"+cAteCliente+"'"	
			cQuery += " AND "+cAlias+"_LOJCLI BETWEEN '"+cDeLoja   +"'AND'"+cAteLoja   +"'"
			cQuery += " AND "+cAlias+"_CODPRO BETWEEN '"+cDeProduto+"'AND'"+cAteProduto+"'"

			If !Empty(cSqlSrv)
				cQuery += " AND "+cAlias+"_SERVIC IN ( "+cSqlSrv+" )"
			Else
				cQuery += " AND "+cAlias+"_SERVIC BETWEEN '"+cDeServico+"'AND'"+cAteServico+"'"
			EndIf
			cQuery += " AND "+cAlias+"_CODNEG BETWEEN '"+cDeNegoc+"'AND'"+cAteNegoc+"'"
			cQuery += " AND "+cAlias+"_SEQTAB <> ' '"
			cQuery += " AND " + cAlias + ".D_E_L_E_T_  = ' ' " 
			cQuery += " GROUP BY " + cAlias+"_CODCLI," + cAlias+"_LOJCLI "
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cMax, .F., .T.)

			Do While (cMax)->( !Eof() )
				Aadd(aCliente,{ (cMax)->CODCLI, (cMax)->LOJCLI } )
				(cMax)->( dbSkip() )
			EndDo
			(cMax)->(dbCloseArea())

		Else
			Aadd(aCliente,{ cDeCliente, cDeLoja } )
		EndIf

		If lTMA750CLI
			aClieSav := aClone(aCliente)
			aCliente := ExecBlock("TMA750CLI",.F.,.F.,{aCliente})
			If ValType(aCliente) <> 'A'
				aCliente := aClone(aClieSav)
			EndIf
		Endif

		DbSelectArea("DVC")
		cMsg      := STR0036 + X2Nome()
		aEstruExp := (cAlias)->(dbStruct())
		ProcRegua( Len(aCliente ) )
		For nReg := 1 To Len(aCliente)

			IncProc( cMsg )

			cCliAtu := aCliente[nReg,1]
			cLojAtu := aCliente[nReg,2]

			cGroup := cAlias+"_FILIAL"+","+cAlias+"_CODCLI"+", "+;
                      cAlias+"_LOJCLI"+","+cAlias+"_TABFRE"+","+;
                      cAlias+"_TIPTAB"+","+cAlias+"_CDRORI"+","+;
                      cAlias+"_CDRDES"+","+cAlias+"_CODPRO"+","+cAlias+"_CODNEG,"+cAlias+"_SERVIC "

			If cAlias <> "DVC"
				cGroup += ", "+cAlias+"_CODPAS"
				If cAlias = "DVD"
					cGroup += ", "+cAlias+"_ITEM "
				EndIf
				If cAlias = "DW2"
					cGroup += ", "+cAlias+"_ITEDVD "
					cGroup += ", "+cAlias+"_ITEM "
				EndIf
			EndIf

			cQuery  := "SELECT "

			For nI := 1 To Len( aEstruExp )
				If nI > 1
					cQuery += ", "
				EndIf
				If aEstruExp[ nI , 1 ] $ cGroup  
					cQuery += " " + aEstruExp[ nI, 1 ] + " "
				ElseIf aEstruExp[ nI , 1 ] == cAlias+"_SEQTAB"
					cQuery += " MAX(" + aEstruExp[ nI, 1 ] + ") " + aEstruExp[ nI, 1 ]
				Else
					If aEstruExp [ nI , 2 ] == "C" .Or. aEstruExp [ nI , 2 ] == "D"
						cQuery += " '" + Space( aEstruExp [ nI , 3 ] ) + "' " +aEstruExp[ nI, 1 ]
					ElseIf aEstruExp [ nI , 2 ] == "N"
						cQuery += " 0 " +aEstruExp[ nI, 1 ]
					EndIf
				EndIf
			Next

			cQuery += ", MAX(" + cAlias + ".R_E_C_N_O_) R_E_C_N_O_, MAX(" + cAlias + ".D_E_L_E_T_) D_E_L_E_T_  "

			cQuery += "  FROM "
			cQuery += "  "+RetSqlName(cAlias) + " " + cAlias + " "

			//-- Faz Inner Join Com Tabela Temporária Reg. Origem
			If !Empty(cOriRegiao)

				cQuery += " INNER JOIN " + cTempOri + " "
				cQuery += " ON " + cAlias + "_CDRORI = " + cTempOri + ".TRB_REGORI "
				
			EndIf

			//-- Faz Inner Join Com Tabela Temporária Reg. Destino
			If !Empty(cDestRegiao)

				cQuery += " INNER JOIN " + cTempDes + " "
				cQuery += " ON " + cAlias + "_CDRDES = " + cTempDes + ".TRB_REGDES "
				
			EndIf

			cQuery += "  WHERE "+cAlias+"_FILIAL  = '"+xFilial(cAlias)+"'"

			If At(",",cTabela) > 0
				cQuery += "  AND "+cAlias+"_TABFRE IN ( "+cTabela+" )"
			Else
				cQuery += "  AND "+cAlias+"_TABFRE = "+cTabela
			EndIf

			If At(",",cTipTab) > 0
				cQuery += "  AND "+cAlias+"_TIPTAB IN ( "+cTipTab+" )"
			Else
				cQuery += "  AND "+cAlias+"_TIPTAB = "+cTipTab
			EndIf

			cQuery += " AND "+cAlias+"_CODCLI = '"+cCliAtu+"'"
			cQuery += " AND "+cAlias+"_LOJCLI = '"+cLojAtu+"'"
				
			If lUmProduto
				If !Empty(cDeProduto)
					cQuery += " AND "+cAlias+"_CODPRO = '"+cDeProduto+"'"
				EndIf
			Else
				cQuery += " AND "+cAlias+"_CODPRO BETWEEN '"+cDeProduto+"'AND'"+cAteProduto+"'"
			EndIf

			If !Empty(cSqlSrv)
				cQuery += " AND "+cAlias+"_SERVIC IN ( "+cSqlSrv+" )"
			Else
				cQuery += " AND "+cAlias+"_SERVIC BETWEEN '"+cDeServico+"'AND'"+cAteServico+"'"
			EndIf
			cQuery += " AND "+cAlias+"_CODNEG BETWEEN '"+cDeNegoc+"'AND'"+cAteNegoc+"'"
			cQuery += " AND " + cAlias + ".D_E_L_E_T_  = ' '"

			//-- Tratamento para verificar se ja existe sequencia em branco

			cQuery += " AND NOT EXISTS ( SELECT 1 FROM "
			cQuery += RetSqlName(cAlias) + " " + cAlias + "2 "
			cQuery += " WHERE "+cAlias+"2."+cAlias+"_FILIAL =  "+cAlias+"."+cAlias+"_FILIAL "
			//-- Na geracao de novos contratos, verifica se existe ajuste para a nova tabela
			If !Empty( cNewTabela ) .And. !Empty( cNewTipTab )
				cQuery += "    AND "+cAlias+"2."+cAlias+"_TABFRE =  '"+cNewTabela+"'"
				cQuery += "    AND "+cAlias+"2."+cAlias+"_TIPTAB =  '"+cNewTipTab+"'"
			Else
				cQuery += "    AND "+cAlias+"2."+cAlias+"_TABFRE =  "+cAlias+"."+cAlias+"_TABFRE "
				cQuery += "    AND "+cAlias+"2."+cAlias+"_TIPTAB =  "+cAlias+"."+cAlias+"_TIPTAB "
			EndIf
			cQuery += "    AND "+cAlias+"2."+cAlias+"_CDRORI =  "+cAlias+"."+cAlias+"_CDRORI "
			cQuery += "    AND "+cAlias+"2."+cAlias+"_CDRDES =  "+cAlias+"."+cAlias+"_CDRDES "
			cQuery += "    AND "+cAlias+"2."+cAlias+"_CODCLI =  "+cAlias+"."+cAlias+"_CODCLI "
			cQuery += "    AND "+cAlias+"2."+cAlias+"_LOJCLI =  "+cAlias+"."+cAlias+"_LOJCLI "
			//-- Na geracao de novos contratos, somente permite incluir ajuste se nao existir nenhuma sequencia
			If Empty( cNewTabela ) .And. Empty( cNewTipTab )
				cQuery += "    AND "+cAlias+"2."+cAlias+"_SEQTAB = '"+Space(Len(DVC->DVC_SEQTAB))+"'"
			EndIf
			cQuery += "    AND "+cAlias+"2."+cAlias+"_CODPRO =  "+cAlias+"."+cAlias+"_CODPRO "
			cQuery += "    AND "+cAlias+"2."+cAlias+"_SERVIC =  "+cAlias+"."+cAlias+"_SERVIC "
			cQuery += "    AND "+cAlias+"2."+cAlias+"_CODNEG =  "+cAlias+"."+cAlias+"_CODNEG "
						
			If cAlias <> "DVC"
				cQuery += " AND "+cAlias+"2."+cAlias+"_CODPAS =  "+cAlias+"."+cAlias+"_CODPAS "
				If cAlias == "DVD"
					cQuery += " AND "+cAlias+"2."+cAlias+"_ITEM =  "+cAlias+"."+cAlias+"_ITEM "
				EndIf
				If cAlias == "DW2"
					cQuery += " AND "+cAlias+"2."+cAlias+"_ITEDVD =  "+cAlias+"."+cAlias+"_ITEDVD "
					cQuery += " AND "+cAlias+"2."+cAlias+"_ITEM =  "+cAlias+"."+cAlias+"_ITEM "
				EndIf
			EndIf
			cQuery += "    AND "+cAlias+"2.D_E_L_E_T_ = ' ' )"

			//-- Somente gera ajuste, quando encontrar o componente configurado na tabela mae ou tarifa
			If !Empty( cNewTabela ) .And. !Empty( cNewTipTab )
				cTabFreVar := "'"+cNewTabela+"'"
				cTipTabVar := "'"+cNewTipTab+"'"
			Else
				cTabFreVar := cTabela
				cTipTabVar := cTipTab
			EndIf
			If cAlias <> "DVD" .And. cAlias <> "DW2"
				cQuery += " AND EXISTS ( SELECT 1 "
				cQuery += "  FROM " + RetSqlName("DT0") + " DT0 "
				cQuery += "  WHERE DT0_FILIAL = '" + xFilial("DT0") + "' "
				If At(",",cTabFreVar) > 0
					cQuery += "  AND DT0_TABFRE IN ( "+cTabFreVar+" )"
				Else
					cQuery += "  AND DT0_TABFRE = "+cTabFrevar
				EndIf
				If At(",",cTipTabVar) > 0
					cQuery += " AND DT0_TIPTAB IN ( "+cTipTabVar+" )"
				Else
					cQuery += " AND DT0_TIPTAB = "+cTipTabVar
				EndIf
				cQuery += "    AND DT0_CDRORI = "+cAlias+"."+cAlias+"_CDRORI "
				cQuery += "    AND DT0_CDRDES = "+cAlias+"."+cAlias+"_CDRDES "
				cQuery += "    AND ( DT0_CODPRO = "+cAlias+"."+cAlias+"_CODPRO OR "
				cQuery += "          DT0_CODPRO = ' ' ) "
				cQuery += "    AND DT0.D_E_L_E_T_ = ' ' ) "
			EndIf
			If cAlias == "DVD"
				cQuery += " AND ( EXISTS   ( SELECT 1 "
				cQuery += "  FROM " + RetSqlName("DT1") + " DT1 "
				cQuery += "  WHERE DT1_FILIAL = '" + xFilial("DT1") + "' "
				If At(",",cTabFreVar) > 0
					cQuery += "  AND DT1_TABFRE IN ( "+cTabFreVar+" )"
				Else
					cQuery += "  AND DT1_TABFRE = "+cTabFreVar
				EndIf
				If At(",",cTipTabVar) > 0
					cQuery += "  AND DT1_TIPTAB IN ( "+cTipTabVar+" )"
				Else
					cQuery += "  AND DT1_TIPTAB = "+cTipTabVar
				EndIf
				cQuery += "    AND DT1_CDRORI = DVD.DVD_RGOTAB "
				cQuery += "    AND DT1_CDRDES = DVD.DVD_RGDTAB "
				cQuery += "    AND DT1_CODPRO = DVD.DVD_PRDTAB "
				cQuery += "    AND DT1_CODPAS = DVD.DVD_CODPAS "
				cQuery += "    AND DT1_ITEM   = DVD.DVD_ITEM   "
				cQuery += "    AND DT1.D_E_L_E_T_ = ' ' ) "
				cQuery += " OR EXISTS ( SELECT 1 "
				cQuery += "   FROM " + RetSqlName("DTG") + " DTG , "
				cQuery += "        " + RetSqlName("DT0") + " DT0 "
				cQuery += "   WHERE DT0_FILIAL = '" + xFilial("DT0") + "' "
				If At(",",cTabFreVar) > 0
					cQuery += "  AND DT0_TABFRE IN ( "+cTabFreVar+" )"
				Else
					cQuery += "  AND DT0_TABFRE = "+cTabFreVar
				EndIf
				If At(",",cTipTabVar) > 0
					cQuery += "  AND DT0_TIPTAB IN ( "+cTipTabVar+" )"
				Else
					cQuery += "  AND DT0_TIPTAB = "+cTipTabVar
				EndIf
				cQuery += "     AND DT0_CDRORI = DVD.DVD_RGOTAB "
				cQuery += "     AND DT0_CDRDES = DVD.DVD_RGDTAB "
				cQuery += "     AND DT0_CODPRO = DVD.DVD_PRDTAB "
				cQuery += "     AND DT0.D_E_L_E_T_ = ' ' "
				cQuery += "     AND DTG_FILIAL = '" + xFilial("DTG") + "' "
				cQuery += "     AND DTG_TABFRE = DT0_TABFRE "
				cQuery += "     AND DTG_TIPTAB = DT0_TIPTAB "
				cQuery += "     AND DTG_TABTAR = DT0_TABTAR "
				cQuery += "     AND DTG_CODPAS = DVD.DVD_CODPAS "
				cQuery += "     AND DTG_ITEM   = DVD.DVD_ITEM   "
				cQuery += "     AND DTG.D_E_L_E_T_ = ' ' ) ) "
			EndIf

			If cAlias == "DW2"
				cQuery += " AND EXISTS ( SELECT 1 "
				cQuery += "  FROM " + RetSqlName("DVD") + " DVD "
				cQuery += "  WHERE DVD_FILIAL = '" + xFilial("DVD") + "' "
				If At(",",cTabFreVar) > 0
					cQuery += "  AND DVD_TABFRE IN ( "+cTabFreVar+" )"
				Else
					cQuery += "  AND DVD_TABFRE = "+cTabFreVar
				EndIf
				If At(",",cTipTabVar) > 0
					cQuery += "  AND DVD_TIPTAB IN ( "+cTipTabVar+" )"
				Else
					cQuery += "  AND DVD_TIPTAB = "+cTipTabVar
				EndIf
				cQuery += "    AND DVD_CDRORI = DW2.DW2_CDRORI "
				cQuery += "    AND DVD_CDRDES = DW2.DW2_CDRDES "
				cQuery += "    AND DVD_CODPRO = DW2.DW2_CODPRO "
				cQuery += "    AND DVD_CODPAS = DW2.DW2_CODPAS "
				cQuery += "    AND DVD_ITEM   = DW2.DW2_ITEDVD "
				cQuery += "    AND DVD.D_E_L_E_T_ = ' ' ) "
			EndIf

			//-- Fim da verificacao
			cQuery += "  GROUP BY " + cGroup

			//-- ChangeQuery()
			//-- 1o Parametro : Query
			//-- 2o Parametro : Se .F., nao insere FOR READ ONLY no final das querys para AS/400 e/ou DB2
			cQuery  := ChangeQuery(cQuery, .F.)
			aMsgErr := {}

			If !TMSA750Aju( cAlias, cQuery, cTipFre, cFilCli, cNewTabela, cNewTipTab, lMantemPrc, cSeqTab, @aMsgErr , cGroup, cCliAtu, cLojAtu , , aAliasTmp[nCntFor,2] )
				If Len(aMsgErr) > 0
					AaddMsgErr( aMsgErr, aVisErr )
				EndIf
				Exit
			EndIf
		Next nReg
		If Len(aMsgErr) > 0
			Exit
		EndIf
	Next nCntFor

	If lTMALogGrv
		//-- Ponto de entrada comum entre todas as rotinas que manipulam tabela de frete e ajustes.
		//-- O ponto tem o objetivo de possibilitar a criacao de um LOG informando o  usuario  e  a
		//-- operação que foi realizada em uma tabela de frete ou ajuste de cliente.
		ExecBlock("TMALOGGRV",.F.,.F.,{ "DVC", "3", cUserName, 0 })
	EndIf

	//-- Gravacao do Historico de Reajuste de Clientes
	If lDWR
		If lUmCliente
			If lNovaTab
				TMSGrvDWR(cDeCliente,cDeLoja,cNewTabela,cNewTipTab,cOriRegiao,cDestRegiao,cDeServico,cAteServico,cDeProduto,cAteProduto,cTipFre,lMantemPrc,aCols,cDeNegoc,cAteNegoc)
			Else
				TMSGrvDWR(cDeCliente,cDeLoja,cTabela,cTipTab,cOriRegiao,cDestRegiao,cDeServico,cAteServico,cDeProduto,cAteProduto,cTipFre,lMantemPrc,aCols,cDeNegoc,cAteNegoc)
			EndIf
		EndIf
	EndIf

	If Len(aVisErr) > 0
		If lTMSA700
			For nCntFor := 1 To Len(aVisErr)
				Aadd( a700VisErr, aVisErr[nCntFor] )
			Next nCntFor
		Else
			TmsMsgErr( aVisErr )
		EndIf
	EndIf
	//funcao que concretiva a gravacao das tabelas temporarias nas tabelas oficiais
	lRet := Tma750Tran(aAliasTmp,lCalcPrc,lNovaTab,cTipFre,cNewTabela,cNewTipTab,cSeqTab,lTmsa700,cCliAtu,cLojAtu,cGroup,aMsgErr)	

	//funcao que apaga os temporarios
	Tma750ATmp(aAliasTmp,cTrab,lNovaTab)

ElseIf nOpc == 5  // Excluir

	lQuery := .T.
	cAliasDVC := GetNextAlias()
	cQuery := "  SELECT DVC_FILIAL,DVC_TABFRE,DVC_TIPTAB,DVC_CDRORI,DVC_CDRDES,"
	cQuery += "  DVC_CODCLI,DVC_LOJCLI,DVC_SEQTAB,DVC_CODPRO,DVC_SERVIC,DVC.R_E_C_N_O_ NRECNO "
	cQuery += ",DVC_CODNEG "
	cQuery += "  FROM "
	cQuery += "  "+RetSqlName('DVC') + " DVC "
	
	//-- Faz Inner Join Com Tabela Temporária Reg. Origem
	If !Empty(cOriRegiao)

		cQuery += " INNER JOIN " + cTempOri + " "
		cQuery += " ON DVC.DVC_CDRORI = " + cTempOri + ".TRB_REGORI "
				
	EndIf	
	
	//-- Faz Inner Join Com Tabela Temporária Reg. Destino
	If !Empty(cDestRegiao)

		cQuery += " INNER JOIN " + cTempDes + " "
		cQuery += " ON DVC.DVC_CDRDES = " + cTempDes + ".TRB_REGDES "
				
	EndIf

	cQuery += "  WHERE DVC.DVC_FILIAL  = '"+xFilial("DVC")+"'"
	cQuery += "     AND DVC.DVC_SEQTAB  = '"+Space(Len(DVC->DVC_SEQTAB))+"'"
	cQuery += "     AND DVC.DVC_CODCLI BETWEEN '"+cDeCliente+"'AND'"+cAteCliente+"'"
	cQuery += "     AND DVC.DVC_LOJCLI BETWEEN '"+cDeLoja   +"'AND'"+cAteLoja   +"'"

	If !Empty(cTabela)
		cQuery += "    AND DVC.DVC_TABFRE IN ( '"+cTabela+"' )"
	EndIf

	If !Empty(cTipTab)
		cQuery += "    AND DVC.DVC_TIPTAB IN ( '"+cTipTab+"' )"
	EndIf
		
	cQuery += " AND DVC.DVC_CODPRO BETWEEN '"+cDeProduto+"'AND'"+cAteProduto+"'"
	cQuery += " AND DVC.DVC_CODNEG BETWEEN '"+cDeNegoc+"'AND'"+cAteNegoc+"'"
	cQuery += " AND DVC.DVC_SERVIC BETWEEN '"+cDeServico+"'AND'"+cAteServico+"'"

	cQuery += " AND DVC.D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDVC,.T.,.T.)

	If Eof()
		//Problema: Nao existem registros para serem reajustados.
		//Solucao: Verifique se os parâmetros estão corretamente informados.
		Help("", 1, "TMSA75001") //"Nao existem registros para serem reajustados"
	EndIf

	Begin Transaction

	Do While (cAliasDVC)->(!Eof())
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui os Itens do Ajuste                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "UPDATE " + RetSqlName( 'DVD' ) + " SET D_E_L_E_T_ = '*' "
		cQuery += " WHERE DVD_FILIAL = '"+xFilial("DVD")+"'" 
		cQuery += "   AND DVD_TABFRE = '"+(cAliasDVC)->(DVC_TABFRE)+"'"
		cQuery += "   AND DVD_TIPTAB = '"+(cAliasDVC)->(DVC_TIPTAB)+"'"
		cQuery += "   AND DVD_CDRORI = '"+(cAliasDVC)->(DVC_CDRORI)+"'"
		cQuery += "   AND DVD_CDRDES = '"+(cAliasDVC)->(DVC_CDRDES)+"'"
		cQuery += "   AND DVD_CODCLI = '"+(cAliasDVC)->(DVC_CODCLI)+"'"
		cQuery += "   AND DVD_LOJCLI = '"+(cAliasDVC)->(DVC_LOJCLI)+"'"
		cQuery += "   AND DVD_SEQTAB = '"+(cAliasDVC)->(DVC_SEQTAB)+"'"
		cQuery += "   AND DVD_CODPRO = '"+(cAliasDVC)->(DVC_CODPRO)+"'"
		cQuery += "   AND DVD_SERVIC = '"+(cAliasDVC)->(DVC_SERVIC)+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		TCSqlExec( cQuery )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui o Complemento do Ajuste                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "UPDATE " + RetSqlName( 'DVO' ) + " SET D_E_L_E_T_ = '*' "
		cQuery += " WHERE DVO_FILIAL = '"+xFilial("DVO")+"'"
		cQuery += "   AND DVO_CODCLI = '"+(cAliasDVC)->(DVC_CODCLI)+"'"
		cQuery += "   AND DVO_LOJCLI = '"+(cAliasDVC)->(DVC_LOJCLI)+"'"
		cQuery += "   AND DVO_TABFRE = '"+(cAliasDVC)->(DVC_TABFRE)+"'"
		cQuery += "   AND DVO_TIPTAB = '"+(cAliasDVC)->(DVC_TIPTAB)+"'"
		cQuery += "   AND DVO_CDRORI = '"+(cAliasDVC)->(DVC_CDRORI)+"'"
		cQuery += "   AND DVO_CDRDES = '"+(cAliasDVC)->(DVC_CDRDES)+"'"
		cQuery += "   AND DVO_SEQTAB = '"+(cAliasDVC)->(DVC_SEQTAB)+"'"
		cQuery += "   AND DVO_CODPRO = '"+(cAliasDVC)->(DVC_CODPRO)+"'"
		cQuery += "   AND DVO_SERVIC = '"+(cAliasDVC)->(DVC_SERVIC)+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		TCSqlExec( cQuery )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui o Base do Componente TDA                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "UPDATE " + RetSqlName( 'DWZ' ) + " SET D_E_L_E_T_ = '*' "
		cQuery += " WHERE DWZ_FILIAL = '"+xFilial("DWZ")+"'"
		cQuery += "   AND DWZ_CODCLI = '"+(cAliasDVC)->(DVC_CODCLI)+"'"
		cQuery += "   AND DWZ_LOJCLI = '"+(cAliasDVC)->(DVC_LOJCLI)+"'"
		cQuery += "   AND DWZ_TABFRE = '"+(cAliasDVC)->(DVC_TABFRE)+"'"
		cQuery += "   AND DWZ_TIPTAB = '"+(cAliasDVC)->(DVC_TIPTAB)+"'"
		cQuery += "   AND DWZ_CDRORI = '"+(cAliasDVC)->(DVC_CDRORI)+"'"
		cQuery += "   AND DWZ_CDRDES = '"+(cAliasDVC)->(DVC_CDRDES)+"'"
		cQuery += "   AND DWZ_SEQTAB = '"+(cAliasDVC)->(DVC_SEQTAB)+"'"
		cQuery += "   AND DWZ_CODPRO = '"+(cAliasDVC)->(DVC_CODPRO)+"'"
		cQuery += "   AND DWZ_SERVIC = '"+(cAliasDVC)->(DVC_SERVIC)+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		TCSqlExec( cQuery )

		If AliasInDic("DJT")
			//-- Exclui a base % por componente TRT
			cQuery := "UPDATE " + RetSqlName( 'DJT' ) + " SET D_E_L_E_T_ = '*' "
			cQuery += " WHERE DJT_FILIAL = '"+xFilial("DJT")+"'"
			cQuery += "   AND DJT_CODCLI = '"+(cAliasDVC)->(DVC_CODCLI)+"'"
			cQuery += "   AND DJT_LOJCLI = '"+(cAliasDVC)->(DVC_LOJCLI)+"'"
			cQuery += "   AND DJT_TABFRE = '"+(cAliasDVC)->(DVC_TABFRE)+"'"
			cQuery += "   AND DJT_TIPTAB = '"+(cAliasDVC)->(DVC_TIPTAB)+"'"
			cQuery += "   AND DJT_CDRORI = '"+(cAliasDVC)->(DVC_CDRORI)+"'"
			cQuery += "   AND DJT_CDRDES = '"+(cAliasDVC)->(DVC_CDRDES)+"'"
			cQuery += "   AND DJT_SEQTAB = '"+(cAliasDVC)->(DVC_SEQTAB)+"'"
			cQuery += "   AND DJT_CODPRO = '"+(cAliasDVC)->(DVC_CODPRO)+"'"
			cQuery += "   AND DJT_SERVIC = '"+(cAliasDVC)->(DVC_SERVIC)+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			TCSqlExec( cQuery )
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui as Sub-Faixas do Ajuste                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lSubFaixa
			cQuery := "UPDATE " + RetSqlName( 'DW2' ) + " SET D_E_L_E_T_ = '*' "
			cQuery += " WHERE DW2_FILIAL = '"+xFilial("DW2")+"'"
			cQuery += "   AND DW2_TABFRE = '"+(cAliasDVC)->(DVC_TABFRE)+"'"
			cQuery += "   AND DW2_TIPTAB = '"+(cAliasDVC)->(DVC_TIPTAB)+"'"
			cQuery += "   AND DW2_CDRORI = '"+(cAliasDVC)->(DVC_CDRORI)+"'"
			cQuery += "   AND DW2_CDRDES = '"+(cAliasDVC)->(DVC_CDRDES)+"'"
			cQuery += "   AND DW2_CODCLI = '"+(cAliasDVC)->(DVC_CODCLI)+"'"
			cQuery += "   AND DW2_LOJCLI = '"+(cAliasDVC)->(DVC_LOJCLI)+"'"
			cQuery += "   AND DW2_SEQTAB = '"+(cAliasDVC)->(DVC_SEQTAB)+"'"
			cQuery += "   AND DW2_CODPRO = '"+(cAliasDVC)->(DVC_CODPRO)+"'"
			cQuery += "   AND DW2_SERVIC = '"+(cAliasDVC)->(DVC_SERVIC)+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			TCSqlExec( cQuery )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui as Sub-Faixas do Ajuste                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lExcSbF
			cQuery := "UPDATE " + RetSqlName( 'DY2' ) + " SET D_E_L_E_T_ = '*' "
			cQuery += " WHERE DY2_FILIAL = '"+xFilial("DY2")+"'"
			cQuery += "   AND DY2_TABFRE = '"+(cAliasDVC)->(DVC_TABFRE)+"'"
			cQuery += "   AND DY2_TIPTAB = '"+(cAliasDVC)->(DVC_TIPTAB)+"'"
			cQuery += "   AND DY2_CDRORI = '"+(cAliasDVC)->(DVC_CDRORI)+"'"
			cQuery += "   AND DY2_CDRDES = '"+(cAliasDVC)->(DVC_CDRDES)+"'"
			cQuery += "   AND DY2_CODCLI = '"+(cAliasDVC)->(DVC_CODCLI)+"'"
			cQuery += "   AND DY2_LOJCLI = '"+(cAliasDVC)->(DVC_LOJCLI)+"'"
			cQuery += "   AND DY2_SEQTAB = '"+(cAliasDVC)->(DVC_SEQTAB)+"'"
			cQuery += "   AND DY2_CODPRO = '"+(cAliasDVC)->(DVC_CODPRO)+"'"
			cQuery += "   AND DY2_SERVIC = '"+(cAliasDVC)->(DVC_SERVIC)+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			TCSqlExec( cQuery )
		EndIf

		DVC->(dbGoTo( (cAliasDVC)->NRECNO ))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui o Cabecalho do Ajuste                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock( "DVC", .F. )
		dbDelete()
		MsUnlock()

		(cAliasDVC)->(dbSkip())

	EndDo

	End Transaction

ElseIf nOpc == 6 // Confirmar

	lQuery := .T.
	cAliasDVC := GetNextAlias()
	cQuery := "  SELECT DVC_FILIAL,DVC_TABFRE,DVC_TIPTAB,DVC_CDRORI,DVC_CDRDES,"
	cQuery += "  DVC_CODCLI,DVC_LOJCLI,DVC_SEQTAB,DVC_CODPRO,DVC_SERVIC,DVC.R_E_C_N_O_ NRECNO "
	cQuery += ",DVC_CODNEG "
	cQuery += "  FROM "
	cQuery += "  "+RetSqlName('DVC') + " DVC "

	//-- Faz Inner Join Com Tabela Temporária Reg. Origem
	If !Empty(cOriRegiao)

		cQuery += " INNER JOIN " + cTempOri + " "
		cQuery += " ON DVC.DVC_CDRORI = " + cTempOri + ".TRB_REGORI "
				
	EndIf		
	
	//-- Faz Inner Join Com Tabela Temporária Reg. Destino
	If !Empty(cDestRegiao)

		cQuery += " INNER JOIN " + cTempDes + " "
		cQuery += " ON DVC.DVC_CDRDES = " + cTempDes + ".TRB_REGDES "
				
	EndIf

	cQuery += "  WHERE DVC.DVC_FILIAL  = '"+xFilial("DVC")+"'"
	cQuery += "		AND DVC.DVC_SEQTAB  = '"+Space(Len(DVC->DVC_SEQTAB))+"'"
	cQuery += " 	AND DVC.DVC_CODCLI BETWEEN '"+cDeCliente+"'AND'"+cAteCliente+"'"
	cQuery += " 	AND DVC.DVC_LOJCLI BETWEEN '"+cDeLoja   +"'AND'"+cAteLoja   +"'"

	If !Empty(cTabela)
		cQuery += "	   AND DVC.DVC_TABFRE IN ( '"+cTabela+"' )"
	EndIf

	If !Empty(cTipTab)
		cQuery += "    AND DVC.DVC_TIPTAB IN ( '"+cTipTab+"' )"
	EndIf

	cQuery += " AND DVC.DVC_CODPRO BETWEEN '"+cDeProduto+"'AND'"+cAteProduto+"'"
	cQuery += " AND DVC.DVC_CODNEG BETWEEN '"+cDeNegoc+"'AND'"+cAteNegoc+"'"
	cQuery += " AND DVC.DVC_SERVIC BETWEEN '"+cDeServico+"'AND'"+cAteServico+"'"
	cQuery += " AND DVC.D_E_L_E_T_  = ' ' "
	cQuery += " ORDER BY DVC.DVC_FILIAL, DVC.DVC_CODCLI, DVC.DVC_LOJCLI "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDVC,.T.,.T.)	

	If Eof()
		//Problema: Nao existem registros para serem reajustados.
		//Solucao: Verifique se os parâmetros estão corretamente informados.
		Help("", 1, "TMSA75001") //"Nao existem registros para serem reajustados"
	EndIf

	Begin Transaction

	Do While !(cAliasDVC)->(Eof())
	
		If cCliente <> (cAliasDVC)->DVC_CODCLI .AND. cLoja <> (cAliasDVC)->DVC_LOJCLI
			If !MultLock("DVC",{"INC_AJU"+cCliente+cLoja},1)
				DisarmTransaction()
				Exit
			EndIf
		EndIf

		cTabela  := (cAliasDVC)->DVC_TABFRE
		cTipo    := (cAliasDVC)->DVC_TIPTAB
		cCliente := (cAliasDVC)->DVC_CODCLI
		cLoja    := (cAliasDVC)->DVC_LOJCLI
		cOrigem  := (cAliasDVC)->DVC_CDRORI
		cDestino := (cAliasDVC)->DVC_CDRDES
		cProduto := (cAliasDVC)->DVC_CODPRO
		cCodNeg  := (cAliasDVC)->DVC_CODNEG
		cServico := (cAliasDVC)->DVC_SERVIC
		cSeqTab  := ''

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Obtem a Nova Sequencia do Ajuste                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TM011SeqTab( cTabela, cTipo, cOrigem, cDestino, cCliente, cLoja, cProduto, cServico, @cSeqTab, cCodNeg )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza sequencia dos Itens do Ajuste                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cQuery := "UPDATE " + RetSqlName( 'DVD' ) + " SET DVD_SEQTAB = '"+cSeqTab+"'"
		cQuery += "  WHERE DVD_FILIAL = '"+xFilial("DVD")+"'"
		cQuery += "  AND DVD_TABFRE = '"+(cAliasDVC)->(DVC_TABFRE)+"'"
		cQuery += "  AND DVD_TIPTAB = '"+(cAliasDVC)->(DVC_TIPTAB)+"'"
		cQuery += "  AND DVD_CDRORI = '"+(cAliasDVC)->(DVC_CDRORI)+"'"
		cQuery += "  AND DVD_CDRDES = '"+(cAliasDVC)->(DVC_CDRDES)+"'"
		cQuery += "  AND DVD_CODCLI = '"+(cAliasDVC)->(DVC_CODCLI)+"'"
		cQuery += "  AND DVD_LOJCLI = '"+(cAliasDVC)->(DVC_LOJCLI)+"'"
		cQuery += "  AND DVD_SEQTAB = '"+(cAliasDVC)->(DVC_SEQTAB)+"'"
		cQuery += "  AND DVD_CODPRO = '"+(cAliasDVC)->(DVC_CODPRO)+"'"
		cQuery += "  AND DVD_SERVIC = '"+(cAliasDVC)->(DVC_SERVIC)+"'"
		cQuery += "  AND D_E_L_E_T_ = ' '"
		TCSqlExec( cQuery )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza sequencia do Complemento do Ajuste                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "UPDATE " + RetSqlName( 'DVO' ) + " SET DVO_SEQTAB = '"+cSeqTab+"'"
		cQuery += "  WHERE DVO_FILIAL = '"+xFilial("DVO")+"'"
		cQuery += " 	AND DVO_CODCLI = '"+(cAliasDVC)->(DVC_CODCLI)+"'"
		cQuery += " 	AND DVO_LOJCLI = '"+(cAliasDVC)->(DVC_LOJCLI)+"'"
		cQuery += "		AND DVO_TABFRE = '"+(cAliasDVC)->(DVC_TABFRE)+"'"
		cQuery += " 	AND DVO_TIPTAB = '"+(cAliasDVC)->(DVC_TIPTAB)+"'"
		cQuery += " 	AND DVO_CDRORI = '"+(cAliasDVC)->(DVC_CDRORI)+"'"
		cQuery += " 	AND DVO_CDRDES = '"+(cAliasDVC)->(DVC_CDRDES)+"'"
		cQuery += " 	AND DVO_SEQTAB = '"+(cAliasDVC)->(DVC_SEQTAB)+"'"
		cQuery += " 	AND DVO_CODPRO = '"+(cAliasDVC)->(DVC_CODPRO)+"'"
		cQuery += " 	AND DVO_SERVIC = '"+(cAliasDVC)->(DVC_SERVIC)+"'"
		cQuery += " 	AND D_E_L_E_T_ = ' '"
		TCSqlExec( cQuery )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza sequencia da Base do TDA                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "UPDATE " + RetSqlName( 'DWZ' ) + " SET DWZ_SEQTAB = '"+cSeqTab+"'"
		cQuery += "  WHERE DWZ_FILIAL = '"+xFilial("DWZ")+"'"
		cQuery += " 	AND DWZ_CODCLI = '"+(cAliasDVC)->(DVC_CODCLI)+"'"
		cQuery += " 	AND DWZ_LOJCLI = '"+(cAliasDVC)->(DVC_LOJCLI)+"'"
		cQuery += "		AND DWZ_TABFRE = '"+(cAliasDVC)->(DVC_TABFRE)+"'"
		cQuery += " 	AND DWZ_TIPTAB = '"+(cAliasDVC)->(DVC_TIPTAB)+"'"
		cQuery += " 	AND DWZ_CDRORI = '"+(cAliasDVC)->(DVC_CDRORI)+"'"
		cQuery += " 	AND DWZ_CDRDES = '"+(cAliasDVC)->(DVC_CDRDES)+"'"
		cQuery += " 	AND DWZ_SEQTAB = '"+(cAliasDVC)->(DVC_SEQTAB)+"'"
		cQuery += " 	AND DWZ_CODPRO = '"+(cAliasDVC)->(DVC_CODPRO)+"'"
		cQuery += " 	AND DWZ_SERVIC = '"+(cAliasDVC)->(DVC_SERVIC)+"'"
		cQuery += " 	AND D_E_L_E_T_ = ' '"
		TCSqlExec( cQuery )

		If AliasInDic("DJT")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza sequencia da base % por componente TRT                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery := "UPDATE " + RetSqlName( 'DJT' ) + " SET DJT_SEQTAB = '"+cSeqTab+"'"
			cQuery += "  WHERE DJT_FILIAL = '"+xFilial("DJT")+"'"
			cQuery += " 	AND DJT_CODCLI = '"+(cAliasDVC)->(DVC_CODCLI)+"'"
			cQuery += " 	AND DJT_LOJCLI = '"+(cAliasDVC)->(DVC_LOJCLI)+"'"
			cQuery += "		AND DJT_TABFRE = '"+(cAliasDVC)->(DVC_TABFRE)+"'"
			cQuery += " 	AND DJT_TIPTAB = '"+(cAliasDVC)->(DVC_TIPTAB)+"'"
			cQuery += " 	AND DJT_CDRORI = '"+(cAliasDVC)->(DVC_CDRORI)+"'"
			cQuery += " 	AND DJT_CDRDES = '"+(cAliasDVC)->(DVC_CDRDES)+"'"
			cQuery += " 	AND DJT_SEQTAB = '"+(cAliasDVC)->(DVC_SEQTAB)+"'"
			cQuery += " 	AND DJT_CODPRO = '"+(cAliasDVC)->(DVC_CODPRO)+"'"
			cQuery += " 	AND DJT_SERVIC = '"+(cAliasDVC)->(DVC_SERVIC)+"'"
			cQuery += " 	AND D_E_L_E_T_ = ' '"
			TCSqlExec( cQuery )		
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza sequencia da Base do Excedente por sub-faixa                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "UPDATE " + RetSqlName( 'DY2' ) + " SET DY2_SEQTAB = '"+cSeqTab+"'"
		cQuery += "  WHERE DY2_FILIAL = '"+xFilial("DY2")+"'"
		cQuery += " 	AND DY2_CODCLI = '"+(cAliasDVC)->(DVC_CODCLI)+"'"
		cQuery += " 	AND DY2_LOJCLI = '"+(cAliasDVC)->(DVC_LOJCLI)+"'"
		cQuery += "		AND DY2_TABFRE = '"+(cAliasDVC)->(DVC_TABFRE)+"'"
		cQuery += " 	AND DY2_TIPTAB = '"+(cAliasDVC)->(DVC_TIPTAB)+"'"
		cQuery += " 	AND DY2_CDRORI = '"+(cAliasDVC)->(DVC_CDRORI)+"'"
		cQuery += " 	AND DY2_CDRDES = '"+(cAliasDVC)->(DVC_CDRDES)+"'"
		cQuery += " 	AND DY2_SEQTAB = '"+(cAliasDVC)->(DVC_SEQTAB)+"'"
		cQuery += " 	AND DY2_CODPRO = '"+(cAliasDVC)->(DVC_CODPRO)+"'"
		cQuery += " 	AND DY2_SERVIC = '"+(cAliasDVC)->(DVC_SERVIC)+"'"
		cQuery += " 	AND D_E_L_E_T_ = ' '"
		TCSqlExec( cQuery )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza sequencia das sub-faixas do Ajuste                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lSubFaixa
			cQuery := "UPDATE " + RetSqlName( 'DW2' ) + " SET DW2_SEQTAB = '"+cSeqTab+"'"
			cQuery += "  WHERE DW2_FILIAL = '"+xFilial("DW2")+"'"
			cQuery += "		AND DW2_TABFRE = '"+(cAliasDVC)->(DVC_TABFRE)+"'"
			cQuery += " 	AND DW2_TIPTAB = '"+(cAliasDVC)->(DVC_TIPTAB)+"'"
			cQuery += " 	AND DW2_CDRORI = '"+(cAliasDVC)->(DVC_CDRORI)+"'"
			cQuery += " 	AND DW2_CDRDES = '"+(cAliasDVC)->(DVC_CDRDES)+"'"
			cQuery += " 	AND DW2_CODCLI = '"+(cAliasDVC)->(DVC_CODCLI)+"'"
			cQuery += " 	AND DW2_LOJCLI = '"+(cAliasDVC)->(DVC_LOJCLI)+"'"
			cQuery += " 	AND DW2_SEQTAB = '"+(cAliasDVC)->(DVC_SEQTAB)+"'"
			cQuery += " 	AND DW2_CODPRO = '"+(cAliasDVC)->(DVC_CODPRO)+"'"
			cQuery += " 	AND DW2_SERVIC = '"+(cAliasDVC)->(DVC_SERVIC)+"'"
			cQuery += " 	AND D_E_L_E_T_ = ' '"
			TCSqlExec( cQuery ) 
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza sequencia do cabecalho do Ajuste                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DVC->(dbGoTo( (cAliasDVC)->NRECNO ))
		Reclock( "DVC" , .F. )
		Replace DVC_SEQTAB With cSeqTab
		MsUnlock()
		(cAliasDVC)->(dbSkip())

	EndDo

	End  Transaction

EndIf

If !Empty(cAliasDVC)
	dbSelectarea(cAliasDVC)
	dbCloseArea()
EndIf

//-- Dropa Temporário Do Banco De Dados
If !Empty(cTempOri) .And. TCCanOpen(cTempOri)
	TCDelFile(cTempOri)
EndIf	

//-- Dropa Temporário Do Banco De Dados
If !Empty(cTempDes) .And. TCCanOpen(cTempDes)
	TCDelFile(cTempDes)
EndIf	

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMSA750Newº Autor ³ Fernando Salvatori º Data ³  03/01/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplica o Ajuste informado e calcula o Valor                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Posicao do Componente (Linha do aCols)             º±±
±±º          ³ ExpC1 - Percentual Atual do Componente                     º±±
±±º          ³ ExpC1 - Posicao do Percentual no aCols                     º±±
±±º          ³ ExpC1 - Valor do Componente                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Novo Valor                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA750                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA750NewVal( nPosReaju, nPercAtu, nPosPerc, nValor)
Local nPerNewAju  := 0
Local nValAntAju  := 0
Local nValNewAju  := 0
Default nPosReaju := 0
Default nPercAtu  := 0
Default nPosPerc  := 0
Default nValor    := 0

//-- Novo Ajuste a ser dado
nPerNewAju := aCols[nPosReaju][nPosPerc]

If nPerNewAju <> 0
	//-- Valor do Ajuste Anterior dado a Tabela
	nValAntAju := nValor * ( nPercAtu / 100)

	//-- Valor do Novo Ajuste 
	nValNewAju := nValAntAju + (nValAntAju * (nPerNewAju / 100) )

	//-- Percentual a ser aplicado no valor do componente 
	nPerNewAju := (nValNewAju / nValor) * 100
Else
	nPerNewAju := nPercAtu
EndIf

Return ( nPerNewAju )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMSA750Ajuº Autor ³ Richard Anderson   º Data ³  16/04/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cria ajuste com INSERT INTO                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Alias                                              º±±
±±º          ³ ExpC2 - Query                                              º±±
±±º          ³ ExpC3 - Tipo de Frete  (CIF/FOB/CIF-FOB)                   º±±
±±º          ³ ExpC4 - Clientes preservados                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ NIL                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA750                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA750Aju( cAlias, cQueryAux, cTipFre, cFilCli, cNewTabela, cNewTipTab, lMantemPrc, cSeqTab, aMsgErr , cGroup, cCodCli,cLojCli,lExecProc,cTemp )

Local   lRet       := .T.
Local   aEstruExp  := {}
Local   nI         := 0
Local   nValor     := 0
Local   nPosPerc   := 0
Local   nPercAtu   := 0
Local   nPerNewAju := 0
Local   nPerNewMin := 0
Local   cMax       := ""
Local   nMax       := 0
Local   cAliasNew  := ""
Local   cQuery     := ""
Local   nTamPer    := Iif(cAlias == "DVO",TamSX3("DVO_PERMIN")[1],TamSX3("DVD_PERAJU")[1])
Local   nDecPer    := Iif(cAlias == "DVO",TamSX3("DVO_PERMIN")[2],TamSX3("DVD_PERAJU")[2])
Local   nPosCompon := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVE_CODPAS"} )
Local   nCount     := 0
Local   lEofAlias  := .F.
Local   nPosReaju  := 0
Local   nValTabNova:= 0
Local   lSeek      := .F.
Local   nValTabAnt := 0
Local   nErrQry    := 0
Local   lNovaTab   := (!Empty(cNewTabela) .And. !Empty(cNewTipTab))
Local   lCalcPrc   := .T.

//-- Calculo do complemento da tabela de frete
Local   nValMin    := 0
Local   nValExc    := 0
Local   nMinNov    := 0
Local   nExcNov    := 0
Local   cJoin      := ""
Local   cCampFil   := cAlias+"_FILIAL"
Local   cCampCli   := cAlias+"_CODCLI"
Local   cCampLoj   := cAlias+"_LOJCLI"
Local   cCampTab   := cAlias+"_TABFRE"
Local   cCampTip   := cAlias+"_TIPTAB"
Local   cCampOri   := cAlias+"_CDRORI"
Local   cCampDes   := cAlias+"_CDRDES"
Local   cCampPro   := cAlias+"_CODPRO"
Local   cCampSer   := cAlias+"_SERVIC"
Local   cCampSeq   := cAlias+"_SEQTAB"
Local   cCampPas   := cAlias+"_CODPAS"
Local   cCampIte   := cAlias+"_ITEM"
Local   cCampIteDVD:= cAlias+"_ITEDVD"
Local   cCampNeg   := ""
Local   cMantem    := ""
Local   lGravaDvo  := .F.
Local   cProc01    := ""
Local   lAchoDTK   := .F.
Local   cRGoTAb    := ""
Local   cRGdTab    := ""

Default cTipFre    := "1"
Default cFilCli    := ""
Default cSeqTab    := Space(Len(DVC->DVC_SEQTAB))
Default aMsgErr    := {}
Default cCodCli    := ""
Default cLojCli    := ""
Default lExecProc  := GetMv("MV_TMSPROC",,.T.)
Default cTemp      := ""
If Valtype(lExecProc) <> "L"
	lExecProc := .T.
EndIf

cCampNeg := cAlias+"_CODNEG"
cProc01 := 'XFILIAL_'+cEmpAnt //"XFILIAL"

DbSelectArea("DVC")

//verifica se a procedure XFILIAL existe no banco pois será utilizada pela procedure
If ExistProc( cProc01 ) .And. ( TcSrvType() <> "AS/400" ) .and. (TcGetDb() == "ORACLE") .and. lExecProc

	TMSAjuOra( cAlias, cQueryAux, cTipFre, cFilCli, cNewTabela, cNewTipTab, lMantemPrc, cSeqTab, cGroup ,cTemp, cCodCli, cLojCli )

ElseIf ExistProc( cProc01 ) .And. ( TcSrvType() <> "AS/400" ) .and. (TcGetDb() == "DB2") .and. lExecProc

	TMSAjuDB2(cAlias, cQueryAux, cTipFre, cFilCli, cNewTabela, cNewTipTab, lMantemPrc, cSeqTab, cGroup ,cTemp, cCodCli, cLojCli)

Else
	aEstruExp := (cAlias)->( DbStruct() )
	cQuery := "INSERT INTO " + cTemp + " ( "
	For nI := 1 To Len( aEstruExp )
		cQuery += aEstruExp[ nI, 1 ] + ", "
	Next

	cQuery += "R_E_C_N_O_, D_E_L_E_T_ ) " + cQueryAux

	If TCSqlExec( cQuery ) <> 0
		lRet := .F.
	EndIf

	If lRet
		cQuery := ""

		If lNovaTab .And. !lMantemPrc
			lCalcPrc := .F.
		EndIf
	EndIf

	If lRet .And. lCalcPrc
		cQuery := "SELECT "
		For nI := 1 To Len(aEstruExp)
			If nI > 1
				cQuery += ", "
			EndIf
			If aEstruExp [ nI , 1 ] $ cGroup
				cJoin  := "Temp"
			Else
				cJoin  := cAlias
			EndIf
			cQuery += cJoin + "." + aEstruExp [ nI , 1 ]
		Next nI
		cQuery  +=" , Temp.R_E_C_N_O_ , Temp.D_E_L_E_T_ "
		cQuery  +=" FROM " + cTemp + " Temp JOIN " + RetSqlName(cAlias) + " " + cAlias + " ON "

		cQuery += cAlias + "." + cCampFil + " = Temp." + cCampFil + " AND " //filial
		cQuery += cAlias + "." + cCampCli + " = Temp." + cCampCli + " AND " //cliente
		cQuery += cAlias + "." + cCampLoj + " = Temp." + cCampLoj + " AND " //loja
		cQuery += cAlias + "." + cCampTab + " = Temp." + cCampTab + " AND " //Tabela
		cQuery += cAlias + "." + cCampTip + " = Temp." + cCampTip + " AND " //Tipo da tabela
		cQuery += cAlias + "." + cCampSeq + " = Temp." + cCampSeq + " AND " // Sequencia
		cQuery += cAlias + "." + cCampOri + " = Temp." + cCampOri + " AND " //Origem
		cQuery += cAlias + "." + cCampDes + " = Temp." + cCampDes + " AND "	//Destino
		cQuery += cAlias + "." + cCampPro + " = Temp." + cCampPro + " AND "	//produto
		cQuery += cAlias + "." + cCampNeg + " = Temp." + cCampNeg + " AND " //negociacao
		cQuery += cAlias + "." + cCampSer + " = Temp." + cCampSer + " AND " //servico
		cQuery += cAlias + "." + "D_E_L_E_T_ = ' ' "
		If cAlias == "DVD"
			cQuery += " AND " + cAlias + "." + cCampPas + " = Temp." + cCampPas 	//codigo do componente
			cQuery += " AND " + cAlias + "." + cCampIte + " = Temp." + cCampIte 	//numero do item
		ElseIf cAlias == "DVO"
			cQuery += " AND " + cAlias + "." + cCampPas + " = Temp." + cCampPas //codigo do componente
		ElseIf cAlias == "DW2"
			cQuery += " AND " + cAlias + "." + cCampPas + " = Temp." + cCampPas 	//codigo do componente
			cQuery += " AND " + cAlias + "." + cCampIteDVD + " = Temp." + cCampIteDVD 	//numero do item do ajuste
			cQuery += " AND " + cAlias + "." + cCampIte + " = Temp." + cCampIte 	//numero do item
		EndIf

		If !lNovaTab
			cQuery += " WHERE EXISTS ( "
			cQuery += "  SELECT AAM_FILIAL,AAM_CODCLI FROM "
			cQuery += "  "+RetSqlName('AAM') + " AAM "
			cQuery += "  WHERE AAM.AAM_FILIAL  = '"+xFilial("AAM")+"'"
			cQuery += "    AND AAM.AAM_CODCLI  =  Temp"+"."+cCampCli
			cQuery += "    AND AAM.AAM_LOJA    =  Temp"+"."+cCampLoj
			cQuery += "		AND AAM.AAM_STATUS  = '"+StrZero(1, Len(AAM->AAM_STATUS))+"'"
			cQuery += "    AND ((AAM.AAM_INIVIG <= '"+DTOS(dDataBase)+"'"
			cQuery += " 	AND AAM.AAM_FIMVIG >= '"+DTOS(dDataBase) +"') OR AAM.AAM_FIMVIG = ' ')"
		 	If cTipFre <> "4"
		 		cQuery += "    AND AAM.AAM_TIPFRE  = '"+cTipFre+"'"
		 	EndIf	
			cQuery += " 	AND AAM.D_E_L_E_T_  = ' ' )"
			cQuery += "    AND Temp.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery := ChangeQuery(cQuery)
		If cAlias == "DVC" 
			If !Empty(cFilCli)
				cAliasNew := GetNextAlias()
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
				(cAliasNew)->( DbGotop() )
				If (cAliasNew)->( Eof() )
					lEofAlias := .T.
				EndIf
				Do While lRet .And. (cAliasNew)->( !Eof() )
					cQuery   := ''
					cCliente := (cAliasNew)->DVC_CODCLI
					cLoja    := (cAliasNew)->DVC_LOJCLI
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Despreza clientes preservados                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cCliente+cLoja $ cFilCli
						cQuery  := "UPDATE " + cTemp + " SET D_E_L_E_T_ = '*'"
						cQuery  += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ )
						nErrQry := TCSqlExec( cQuery )
						If nErrQry <> 0
							Aadd(aMsgErr,{STR0037 + cTemp + ': ' + AllTrim(Str(nErrQry)) + If(lTMSA700,' Cliente: '+cCodCli+'/'+cLojCli,''),'01',''}) //"Erro no UPDATE da tabela "
							lRet := .F.
							Exit
						EndIf
					EndIf
					(cAliasNew)->( DbSkip() )
				EndDo
				(cAliasNew)->( dbCloseArea() )
			EndIf
			
		ElseIf cAlias == "DVD"
		
			cAliasNew := GetNextAlias()
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
			(cAliasNew)->( DbGotop() )
			If (cAliasNew)->( Eof() )
				lEofAlias := .T.
			EndIf
			Do While lRet .And. (cAliasNew)->( !Eof() )
				cQuery   := ''
				cCliente := (cAliasNew)->DVD_CODCLI
				cLoja    := (cAliasNew)->DVD_LOJCLI
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Despreza clientes preservados                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cCliente+cLoja $ cFilCli
					cQuery  := "UPDATE " + cTemp + " SET D_E_L_E_T_ = '*'"
					cQuery  += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ )
					nErrQry := TCSqlExec( cQuery )
					If nErrQry <> 0
						Aadd(aMsgErr,{STR0037 + cTemp + ': ' +AllTrim(Str(nErrQry)) + If(lTMSA700,' Cliente: '+cCodCli+'/'+cLojCli,''),'01',''}) //"Erro no UPDATE da tabela "
						lRet := .F.
						Exit
					EndIf
				Else
					If lNovaTab
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Obtem a Nova Sequencia do Ajuste                                        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//-- Posiciona na Tabela Mae da Tabela Anterior
						nValor := 0
						DT0->(dbSetOrder(1))
						DT0->(MsSeek(cSeekDT0 := xFilial('DT0')+(cAliasNew)->(DVD_TABFRE+DVD_TIPTAB+DVD_RGOTAB+DVD_RGDTAB+DVD_PRDTAB)))
						//-- Posiciona no Item da Tabela para pegar o Valor do Componente
						DT1->(dbSetOrder(1))
						If DT1->(!MsSeek(xFilial('DT1')+DT0->(DT0_TABFRE+DT0_TIPTAB+DT0_CDRORI+DT0_CDRDES+DT0_CODPRO)+(cAliasNew)->(DVD_CODPAS+DVD_ITEM) ))
							DTG->(dbSetOrder(1))
							If DTG->(MsSeek(xFilial('DTG')+DT0->(DT0_TABFRE+DT0_TIPTAB+DT0_TABTAR)+(cAliasNew)->(DVD_CODPAS+DVD_ITEM) ))
								nValor := DTG->DTG_VALOR
							EndIf
						Else
							nValor := DT1->DT1_VALOR
						EndIf
						If nValor > 0
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Mantem o Valor do Ajuste da Tabela anterior                   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nValTabNova := 0
							//-- Posiciona na Tabela Mae
							DT0->(dbSetOrder(1)) 
							DT0->(MsSeek(cSeekDT0 := xFilial('DT0')+cNewTabela+cNewTipTab+(cAliasNew)->(DVD_RGOTAB+DVD_RGDTAB+DVD_PRDTAB)))
							DT1->(DbSetOrder(1))
							If DT1->(!MsSeek(xFilial('DT1')+cNewTabela+cNewTipTab+DT0->(DT0_CDRORI+DT0_CDRDES+DT0_CODPRO)+(cAliasNew)->(DVD_CODPAS+DVD_ITEM) ))
								DTG->(dbSetOrder(1))
								If DTG->(MsSeek(xFilial('DTG')+cNewTabela+cNewTipTab+DT0->DT0_TABTAR+(cAliasNew)->(DVD_CODPAS+DVD_ITEM) ))
									nValTabNova := DTG->DTG_VALOR
								EndIf
							Else
								nValTabNova := DT1->DT1_VALOR
							EndIf
							If nValTabNova > 0
								nValTabAnt := nValor * ((cAliasNew)->(DVD_PERAJU) / 100)
								nPerNewAju := ( nValTabAnt / nValTabNova ) * 100
								cQuery  := "UPDATE " + cTemp + " SET "
								cQuery  += " DVD_PERAJU =  " + AllTrim(Str(nPerNewAju,nTamPer,nDecPer))
							EndIf
						EndIf
					Else
						//-- Posiciona na Tabela Mae
						DT0->(dbSetOrder(1)) 
						DT0->(MsSeek(cSeekDT0 := xFilial('DT0')+(cAliasNew)->(DVD_TABFRE+DVD_TIPTAB+DVD_RGOTAB+DVD_RGDTAB+DVD_PRDTAB)))
						//-- Posiciona no Item da Tabela para pegar o Valor do Componente
						DT1->(dbSetOrder(1))
						If DT1->(!MsSeek(xFilial('DT1')+DT0->(DT0_TABFRE+DT0_TIPTAB+DT0_CDRORI+DT0_CDRDES+DT0_CODPRO)+(cAliasNew)->(DVD_CODPAS+DVD_ITEM) ))
							DTG->(dbSetOrder(1))
							If DTG->(MsSeek(xFilial('DTG')+DT0->(DT0_TABFRE+DT0_TIPTAB+DT0_TABTAR)+(cAliasNew)->(DVD_CODPAS+DVD_ITEM) ))
								nValor := DTG->DTG_VALOR
							EndIf
						Else
							nValor := DT1->DT1_VALOR
						EndIf
						If nPosCompon > 0
							nPosReaju := aScan( aCols,{|ExpA1| ExpA1[nPosCompon] == (cAliasNew)->DVD_CODPAS })
						EndIf
						nPosPerc  := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVE_PERREA"} )
						nPercAtu  := (cAliasNew)->DVD_PERAJU
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Aplica o % de Reajuste no Valor do Componente                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nPosReaju > 0 .And. nPercAtu > 0
							nPerNewAju := TMA750NewVal( nPosReaju, nPercAtu, nPosPerc, nValor)
							cQuery  := "UPDATE " + cTemp + " SET "
							cQuery  += " DVD_PERAJU =  " + AllTrim(Str(nPerNewAju,nTamPer,nDecPer))
						EndIf
					EndIf
					If !Empty(cQuery)
						cQuery  += " WHERE R_E_C_N_O_ = " + AllTrim(Str( (cAliasNew)->R_E_C_N_O_ )) 
						nErrQry := TCSqlExec( cQuery )
					EndIf
					If nErrQry <> 0
						Aadd(aMsgErr,{STR0038 + cAlias + STR0030 +AllTrim(Str(nErrQry))+; //"Reajuste Tab.Cliente -> Erro no UPDATE do "###", no. "
						STR0029 + cCliente + '/' + cLoja +; //", Cliente/Loja: "
						STR0028 +(cAliasNew)->DVD_CDRORI +; //", Reg.Origem..: "
						STR0027 +(cAliasNew)->DVD_CDRDES, '01', '' }) //", Reg.Destino.: "
						lRet := .F.
						Exit
					EndIf
				EndIf
				(cAliasNew)->( DbSkip() )
			EndDo

			(cAliasNew)->( dbCloseArea() )

		ElseIf cAlias == "DVO"

			cAliasNew := GetNextAlias()
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
			(cAliasNew)->( DbGotop() )
			If (cAliasNew)->( Eof() )
				lEofAlias := .T.
			EndIf

			Do While lRet .And. (cAliasNew)->( !Eof() )
				lGravaDVO := .F.
				cQuery    := ''
				cCliente  := (cAliasNew)->DVO_CODCLI
				cLoja     := (cAliasNew)->DVO_LOJCLI
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Despreza clientes preservados                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cCliente+cLoja $ cFilCli
					cQuery  := "UPDATE " + cTemp + " SET D_E_L_E_T_ = '*'"
					cQuery  += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ ) 
					nErrQry := TCSqlExec( cQuery )
					If nErrQry <> 0
						Aadd(aMsgErr,{STR0037 + cTemp + ': ' +AllTrim(Str(nErrQry)) + If(lTMSA700,' Cliente: '+cCodCli+'/'+cLojCli,''),'01',''}) //Erro no UPDATE da tabela 
						lRet := .F.
						Exit
					EndIf
				Else
					If lNovaTab
						nValMin := 0
						nValExc := 0
						//-- Obtem mínimo do complemento da tabela de frete anterior
						DTK->(dbSetOrder(1))
						If DTK->(MsSeek(xFilial("DTK")+(cAliasNew)->(DVO_TABFRE+DVO_TIPTAB+DVO_CDRORI+DVO_CDRDES+DVO_CODPRO+DVO_CODPAS)))
							nValMin := DTK->DTK_VALMIN //-- Vlr.Minimo
							nValExc := DTK->DTK_VALOR  //-- Vlr.Excedente
						Else
							DVD->(DbSetOrder(1))
							If DVD->(MsSeek(xFilial("DVD")+(cAliasNew)->(DVO_TABFRE+DVO_TIPTAB+DVO_CDRORI+DVO_CDRDES+DVO_CODCLI+DVO_LOJCLI+DVO_SEQTAB+DVO_CODPRO)+(cAliasNew)->DVO_CODNEG+(cAliasNew)->(DVO_SERVIC+DVO_CODPAS)))
								cRGoTAb := DVD->DVD_RGOTAB
								cRGdTab := DVD->DVD_RGDTAB
								If DTK->(MsSeek(xFilial("DTK")+(cAliasNew)->(DVO_TABFRE+DVO_TIPTAB)+cRGoTAb+cRGdTab+(cAliasNew)->(DVO_CODPRO+DVO_CODPAS)))
									nValMin := DTK->DTK_VALMIN //-- Vlr.Minimo
									nValExc := DTK->DTK_VALOR  //-- Vlr.Excedente 
								EndIf
							EndIf
						EndIf
						If nValMin > 0 .Or. nValExc > 0 .Or. DTK->DTK_EXCMIN > 0
							lAchoDTK := .F.
							If DTK->(MsSeek(xFilial("DTK")+cNewTabela+cNewTipTab+(cAliasNew)->(DVO_CDRORI+DVO_CDRDES+DVO_CODPRO+DVO_CODPAS)))
								nMinNov := DTK->DTK_VALMIN //-- Vlr.Minimo
								nExcNov := DTK->DTK_VALOR  //-- Vlr.Excedente
								lAchoDTK := .T.
							Else
								If DTK->(MsSeek(xFilial("DTK")+cNewTabela+cNewTipTab+cRGoTAb+cRGdTab+(cAliasNew)->(DVO_CODPRO+DVO_CODPAS)))
									nMinNov := DTK->DTK_VALMIN //-- Vlr.Minimo
									nExcNov := DTK->DTK_VALOR  //-- Vlr.Excedente
									lAchoDTK := .T.
								EndIf
							EndIf
							If lAchoDTK
								//-- Vlr.Minimo
								If nValMin > 0 .And. nMinNov > 0
									lGravaDvo  := .T.
									nValTabAnt := nValMin * ((cAliasNew)->(DVO_PERMIN) / 100)
									nPerNewAju := ( nValTabAnt / nMinNov ) * 100
									cQuery  := "UPDATE " + cTemp + " SET "
									cQuery  += " DVO_PERMIN =  " + AllTrim(Str(nPerNewAju,nTamPer,nDecPer))
								EndIf
								//-- Vlr.Excedente
								If nValExc > 0 .And. nExcNov > 0
									lGravaDvo  := .T.
									nValTabAnt := nValExc * ((cAliasNew)->(DVO_PERAJU) / 100)
									nPerNewAju := ( nValTabAnt / nExcNov ) * 100
									If !Empty(cQuery)
										cQuery  += " , DVO_PERAJU =  " + AllTrim(Str(nPerNewAju,nTamPer,nDecPer))
									Else
										cQuery  := "UPDATE " + cTemp + " SET "
										cQuery  += " DVO_PERAJU =  " + AllTrim(Str(nPerNewAju,nTamPer,nDecPer))
									EndIf
								EndIf
								If DTK->DTK_EXCMIN > 0
									lGravaDvo := .T.
								EndIf
							EndIf
						Else
							//-- Caso não tenha DTK, não gera novo ajuste
							If !lGravaDvo
								If !Empty(cQuery)
									cQuery += " , D_E_L_E_T_ = '*' "
								Else
									cQuery  := "UPDATE " + cTemp + " SET "
									cQuery  += " D_E_L_E_T_ = '*' "
								EndIf
							EndIf
						EndIf
					Else
						If nPosCompon > 0
							nPosReaju := aScan( aCols,{|ExpA1| ExpA1[nPosCompon] == (cAliasNew)->DVO_CODPAS })	
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Aplica o % Minimo                                                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nPercAtu   := (cAliasNew)->DVO_PERMIN
						nPosPerc   := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVO_PERMIN"} )
						nValor	  := 0
						DTK->(DbSetOrder(1))
						If DTK->(MsSeek(xFilial("DTK")+(cAliasNew)->(DVO_TABFRE+DVO_TIPTAB+DVO_CDRORI+DVO_CDRDES+DVO_CODPRO+DVO_CODPAS)))
							nValor := DTK->DTK_VALMIN
						Else
							DVD->(DbSetOrder(1))
							If DVD->(MsSeek(xFilial("DVD")+(cAliasNew)->(DVO_TABFRE+DVO_TIPTAB+DVO_CDRORI+DVO_CDRDES+DVO_CODCLI+DVO_LOJCLI+DVO_SEQTAB+DVO_CODPRO)+(cAliasNew)->DVO_CODNEG+(cAliasNew)->(DVO_SERVIC+DVO_CODPAS)))					      
								If DTK->(MsSeek(xFilial("DTK")+(cAliasNew)->(DVO_TABFRE+DVO_TIPTAB)+DVD->DVD_RGOTAB+DVD->DVD_RGDTAB+(cAliasNew)->(DVO_CODPRO+DVO_CODPAS)))					      
									nValor := DTK->DTK_VALMIN
								EndIf
							EndIf
						EndIf
						nPerNewMin := 0
						If nPosReaju > 0 .And. nPercAtu > 0
							nPerNewMin := TMA750NewVal( nPosReaju, nPercAtu, nPosPerc, nValor)
							If !Empty(cQuery)
								cQuery  += ", DVO_PERMIN =  " + AllTrim(Str(nPerNewMin,nTamPer,nDecPer))
							Else
								cQuery  := "UPDATE " + cTemp + " SET "
								cQuery  += " DVO_PERMIN =  " + AllTrim(Str(nPerNewMin,nTamPer,nDecPer))
							EndIf
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Aplica o % Excedente                                                    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ									
						nPercAtu := (cAliasNew)->DVO_PERAJU
						nPosPerc := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVO_PERAJU"} )
						nValor   := 0
						DTK->(DbSetOrder(1))
						If DTK->(MsSeek(xFilial("DTK")+(cAliasNew)->(DVO_TABFRE+DVO_TIPTAB+DVO_CDRORI+DVO_CDRDES+DVO_CODPRO+DVO_CODPAS)))
							nValor := DTK->DTK_VALOR
						Else
							DVD->(DbSetOrder(1))
							If DVD->(MsSeek(xFilial("DVD")+(cAliasNew)->(DVO_TABFRE+DVO_TIPTAB+DVO_CDRORI+DVO_CDRDES+DVO_CODCLI+DVO_LOJCLI+DVO_SEQTAB+DVO_CODPRO)+(cAliasNew)->DVO_CODNEG+(cAliasNew)->(DVO_SERVIC+DVO_CODPAS)))
								If DTK->(MsSeek(xFilial("DTK")+(cAliasNew)->(DVO_TABFRE+DVO_TIPTAB)+DVD->DVD_RGOTAB+DVD->DVD_RGDTAB+(cAliasNew)->(DVO_CODPRO+DVO_CODPAS)))
									nValor := DTK->DTK_VALOR
								EndIf
							EndIf
						EndIf
						nPerNewExc := 0
						If nPosReaju > 0 .And. nPercAtu > 0
							nPerNewExc := TMA750NewVal( nPosReaju, nPercAtu, nPosPerc, nValor)
							If !Empty(cQuery)
								cQuery += ", DVO_PERAJU =  " + AllTrim(Str(nPerNewExc,nTamPer,nDecPer))
							Else
								cQuery := "UPDATE " + cTemp + " SET "
								cQuery += " DVO_PERAJU =  " + AllTrim(Str(nPerNewExc,nTamPer,nDecPer))
							EndIf
						EndIf
					EndIf
					If !Empty(cQuery)
						cQuery  += " WHERE R_E_C_N_O_ = " + AllTrim(Str( (cAliasNew)->R_E_C_N_O_ ))
						nErrQry := TCSqlExec( cQuery )
					EndIf
					If nErrQry <> 0
						Aadd(aMsgErr,{STR0038 + cAlias + STR0030 +AllTrim(Str(nErrQry))+; //"Reajuste Tab.Cliente -> Erro no UPDATE do "###", no. "
						STR0029 + cCliente + '/' + cLoja +; //', Cliente/Loja: '
						STR0028 +(cAliasNew)->DVO_CDRORI +; //', Reg.Origem..: '
						STR0027 +(cAliasNew)->DVO_CDRDES, '01', '' }) //', Reg.Destino.: '
						lRet := .F.
						Exit
					EndIf
				EndIf
				(cAliasNew)->( DbSkip() )
			EndDo
			(cAliasNew)->( dbCloseArea() )

		ElseIf cAlias == "DW2"

			cAliasNew := GetNextAlias()
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)
			(cAliasNew)->( DbGotop() )
			If (cAliasNew)->( Eof() )
				lEofAlias := .T.
			EndIf
			Do While lRet .And. (cAliasNew)->( !Eof() )
				cQuery   := ''
				cCliente := (cAliasNew)->DW2_CODCLI
				cLoja    := (cAliasNew)->DW2_LOJCLI
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Despreza clientes preservados                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cCliente+cLoja $ cFilCli
					cQuery  := "UPDATE " + cTemp + " SET D_E_L_E_T_ = '*'"
					cQuery  += " WHERE R_E_C_N_O_ = " + Str( (cAliasNew)->R_E_C_N_O_ ) 
					nErrQry := TCSqlExec( cQuery )
					If nErrQry <> 0
						Aadd(aMsgErr,{STR0037 + cTemp + ': ' +AllTrim(Str(nErrQry)) + If(lTMSA700,' Cliente: '+cCodCli+'/'+cLojCli,''),'01',''}) //"Erro no UPDATE da tabela "
						lRet := .F.
						Exit
					EndIf
				Else
					If lNovaTab
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Obtem a Nova Sequencia do Ajuste                                        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//-- Posiciona na Tabela Mae da Tabela Anterior
						nValor := 0
						DT0->(dbSetOrder(1)) 
						DT0->(MsSeek(cSeekDT0 := xFilial('DT0')+(cAliasNew)->(DW2_TABFRE+DW2_TIPTAB+DW2_RGOTAB+DW2_RGDTAB+DW2_PRDTAB)))
						//-- Posiciona no Item da Tabela para pegar o Valor do Componente
						DW1->(dbSetOrder(1))
						If DW1->(!MsSeek(xFilial('DW1')+DT0->(DT0_TABFRE+DT0_TIPTAB+DT0_CDRORI+DT0_CDRDES+DT0_CODPRO)+(cAliasNew)->(DW2_CODPAS+DW2_ITEDVD+DW2_ITEM) ))
							DW0->(dbSetOrder(1))
							If DW0->(MsSeek(xFilial('DW0')+DT0->(DT0_TABFRE+DT0_TIPTAB+DT0_TABTAR)+(cAliasNew)->(DW2_CODPAS+DW2_ITEDVD+DW2_ITEM) ))
								nValor := DW0->DW0_VALOR
							EndIf
						Else
							nValor := DW1->DW1_VALOR
						EndIf
						If nValor > 0
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Mantem o Valor do Ajuste da Tabela anterior                   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nValTabNova := 0
							//-- Posiciona na Tabela Mae
							DT0->(dbSetOrder(1)) 
							DT0->(MsSeek(cSeekDT0 := xFilial('DT0')+cNewTabela+cNewTipTab+(cAliasNew)->(DW2_RGOTAB+DW2_RGDTAB+DW2_PRDTAB)))
							DW1->(DbSetOrder(1))
							If DW1->(!MsSeek(xFilial('DW1')+cNewTabela+cNewTipTab+DT0->(DT0_CDRORI+DT0_CDRDES+DT0_CODPRO)+(cAliasNew)->(DW2_CODPAS+DW2_ITEDVD+DW2_ITEM) ))
								DW0->(dbSetOrder(1))
								If DW0->(MsSeek(xFilial('DW0')+cNewTabela+cNewTipTab+DT0->DT0_TABTAR+(cAliasNew)->(DW2_CODPAS+DW2_ITEDVD+DW2_ITEM) ))
									nValTabNova := DW0->DW0_VALOR
								EndIf
							Else
								nValTabNova := DW1->DW1_VALOR
							EndIf
							If nValTabNova > 0
								nValTabAnt := nValor * ((cAliasNew)->(DW2_PERAJU) / 100)
								nPerNewAju := ( nValTabAnt / nValTabNova ) * 100
								cQuery  := "UPDATE " + cTemp + " SET "
								cQuery  += " DW2_PERAJU =  " + AllTrim(Str(nPerNewAju,nTamPer,nDecPer))
							EndIf
						EndIf
					Else
						//-- Posiciona na Tabela Mae
						DT0->(dbSetOrder(1)) 
						DT0->(MsSeek(cSeekDT0 := xFilial('DT0')+(cAliasNew)->(DW2_TABFRE+DW2_TIPTAB+DW2_RGOTAB+DW2_RGDTAB+DW2_PRDTAB)))
						//-- Posiciona no Item da Tabela para pegar o Valor do Componente
						DW1->(dbSetOrder(1))
						If DW1->(!MsSeek(xFilial('DW1')+DT0->(DT0_TABFRE+DT0_TIPTAB+DT0_CDRORI+DT0_CDRDES+DT0_CODPRO)+(cAliasNew)->(DW2_CODPAS+DW2_ITEDVD+DW2_ITEM) ))
							DW0->(dbSetOrder(1))
							If DW0->(MsSeek(xFilial('DW0')+DT0->(DT0_TABFRE+DT0_TIPTAB+DT0_TABTAR)+(cAliasNew)->(DW2_CODPAS+DW2_ITEDVD+DW2_ITEM) ))
								nValor := DW0->DW0_VALOR
							EndIf
						Else
							nValor := DW1->DW1_VALOR
						EndIf
						If nPosCompon > 0
							nPosReaju := aScan( aCols,{|ExpA1| ExpA1[nPosCompon] == (cAliasNew)->DW2_CODPAS })
						EndIf
						nPosPerc  := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVE_PERREA"} )
						nPercAtu  := (cAliasNew)->DW2_PERAJU
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Aplica o % de Reajuste no Valor do Componente                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nPosReaju > 0 .And. nPercAtu > 0
							nPerNewAju := TMA750NewVal( nPosReaju, nPercAtu, nPosPerc, nValor)
							cQuery  := "UPDATE " + cTemp + " SET "
							cQuery  += " DW2_PERAJU =  " + AllTrim(Str(nPerNewAju,nTamPer,nDecPer))
						EndIf
					EndIf
					If !Empty(cQuery)
						cQuery  += " WHERE R_E_C_N_O_ = " + AllTrim(Str( (cAliasNew)->R_E_C_N_O_ )) 
						nErrQry := TCSqlExec( cQuery )
					EndIf
					If nErrQry <> 0
						Aadd(aMsgErr,{STR0038 + cAlias + STR0030 +AllTrim(Str(nErrQry))+; //"Reajuste Tab.Cliente -> Erro no UPDATE do "###", no. "
						STR0029 + cCliente + '/' + cLoja +; //', Cliente/Loja: '
						STR0028 +(cAliasNew)->DW2_CDRORI +; //', Reg.Origem..: '
						STR0027 +(cAliasNew)->DW2_CDRDES, '01', '' }) //', Reg.Destino.: '
						lRet := .F.
						Exit
					EndIf
				EndIf
				(cAliasNew)->( DbSkip() )
			EndDo
			
			(cAliasNew)->( dbCloseArea() )
		EndIf
	EndIf

EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GetStruProcº Autor ³ Ricardo C Pereira  º Data ³  20/06/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gera estrutura da tabela temp de Itens(acols) - Procedure   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ aCampos - Estrutura da Tabela Temporária                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA750                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GetStruProc()
Local aCampos:={}
Local aTam   :={}

aTam:=TamSX3("DVE_CODPAS")
AADD(aCampos,{ "TRB_CODPAS" ,"C", aTam[1], 0} ) 
aTam:=TamSX3("DVE_DESPAS")
AADD(aCampos,{ "TRB_DESPAS" ,"C", aTam[1], 0} ) 
aTam:=TamSX3("DVO_PERMIN")
AADD(aCampos,{ "TRB_PERREA" ,"N", aTam[1], aTam[2]} ) 
aTam:=TamSX3("DVO_PERMIN")
AADD(aCampos,{ "TRB_PERMIN" ,"N", aTam[1], aTam[2]} ) 
aTam:=TamSX3("DVO_PERAJU")
AADD(aCampos,{ "TRB_PERAJU" ,"N", aTam[1], aTam[2]} )
Return (aCampos)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMSAjuOra º Autor ³ Ricardo C Pereira  º Data ³  20/06/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cria ajuste com INSERT INTO com Procedure                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Alias                                              º±±
±±º          ³ ExpC2 - Query                                              º±±
±±º          ³ ExpC3 - Tipo de Frete  (CIF/FOB/CIF-FOB)                   º±±
±±º          ³ ExpC4 - Clientes preservados                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ NIL                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA750                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAjuOra( cAlias, cQueryAux, cTipFre, cFilCli, cNewTabela, cNewTipTab, lMantemPrc, cSeqTab, cGroup ,cTemp, cCliAtu, cLojAtu)

  
Local   lRet        := .T.
Local   lNovaTab    := (!Empty(cNewTabela) .And. !Empty(cNewTipTab))
Local   lCalcPrc    := .T.
Local   cCampFil    := cAlias+"_FILIAL"
Local   cCampCli    := cAlias+"_CODCLI"
Local   cCampLoj    := cAlias+"_LOJCLI"
Local   cCampTab    := cAlias+"_TABFRE"
Local   cCampTip    := cAlias+"_TIPTAB"
Local   cCampOri    := cAlias+"_CDRORI"
Local   cCampDes    := cAlias+"_CDRDES"
Local   cCampPro    := cAlias+"_CODPRO"
Local   cCampSer    := cAlias+"_SERVIC"
Local   cCampSeq    := cAlias+"_SEQTAB"
Local   cCampPas    := cAlias+"_CODPAS"
Local   cCampIte    := cAlias+"_ITEM"
Local   cCampIteDVD := cAlias+"_ITEDVD"
Local   cCampNeg    := ""
Local   cMantem     := ""
Local   cInsert     := ""
Local   cDeclare    := ""
Local   cCorpoIni   := ""
Local   cCorpoDVC   := ""
Local   cCorpoDVD   := ""
Local   cCorpoDVO   := ""
Local   cCorpoDVO1  := ""
Local   cCorpoDVO2  := ""
Local   cCorpoDW2   := ""
Local   cCorpoDW21  := ""
Local   cCorpoDW22  := ""
Local   cCorpoFim   := ""  
Local   cProc01     := ""
Local   cProc02     := ""
Local   cProcedure  := ""  
Local   cProcFim    := "" 
Local   cFetch      := "" 
Local   cFilCliPrc  := ""
Local   nPos01, nPos02, nPos03, nPos04, nPos05
Local   cSelVer1    := ""
Local   cSelVer2    := ""
Local   nTmsProc    := 0
Local   nXFilProc   := 0
Local   aResult     := {}
Local   i, nC, nI
Local   lExecProc  := .F.
Local   aMsgErr    := {}

//novas
Local   aTmpCampos := {} 
Default cTipFre    := "1"
Default cFilCli    := ""

cCampNeg := cAlias+"_CODNEG"

If !lNovaTab

	/* Cria Tabela e Indice Temporário para armazenar aCols - Itens */
	If TcCanOpen(cTrab)
		TcDelFile(cTrab)
	Endif

	aTmpCampos:= GetStruProc()
	CriaTmpDb("",cTrab,aTmpCampos) 
	TcSqlExec("Create index "+cTrab+"+IDX on  "+cTrab+" ( TRB_CODPAS )") 

	nPos01  := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVE_CODPAS"} )
	nPos02  := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVE_DESPAS"} )
	nPos03  := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVE_PERREA"} )
	nPos04  := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVO_PERMIN"} )
	nPos05  := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVO_PERAJU"} )

	For i:= 1 to len(aCols)

		cInsert := "INSERT INTO "+cTrab+" (TRB_CODPAS,TRB_DESPAS,TRB_PERREA,TRB_PERMIN,TRB_PERAJU, R_E_C_N_O_) "
		cInsert += "values ('"+alltrim(aCols[i][nPos01])+"','"+alltrim(aCols[i][nPos02])+"',"+alltrim(str(aCols[i][nPos03]))
		cInsert += ","+alltrim(str(aCols[i][nPos04]))+","+alltrim(str(aCols[i][nPos05]))+","+alltrim(str(i))+")"
		TcSqlExec(cInsert) 

	Next

EndIf

aEstruExp := (cAlias)->( dbStruct() )
/*Inicio do Codigo da Procedure */ 
cCreate := ""
cCreate := "create or replace procedure "+cTrab+"_"+cEmpAnt+" ("+CRLF
cCreate += "   IN_FILIALCOR    in  CHAR,"+CRLF
cCreate += "   IN_NEWTABELA    in  CHAR,"+CRLF      //cNewTabela
cCreate += "   IN_NEWTIPTAB    in  CHAR,"+CRLF      //cNewTipTab
cCreate += "   IN_DATABASE     in  CHAR,"+CRLF      //Dtos(dDatabase)
cCreate += "   IN_TIPFRE       in  CHAR,"+CRLF //cTipFre
cCreate += "   OUT_RESULTADO   out CHAR ) IS"+CRLF 
cCreate += CRLF
cCreate += " -- Declaracoes de Variaveis"+CRLF

cDeclare := ""
cDeclare := "   vcAux            Char(03) ;"+CRLF
If (cAlias == "DVD")
	cDeclare += "   vcFil_DT0        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) ;"+CRLF
	cDeclare += "   vcFil_DT1        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) ;"+CRLF
	cDeclare += "   vcFil_DTG        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) ;"+CRLF
EndIf
If (cAlias == "DVO")
	cDeclare += "   vcFil_DTK        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) ;"+CRLF
	cDeclare += "   vcFil_DVD        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) ;"+CRLF
	aTam     :=TamSX3("DVD_RGOTAB")
	cDeclare += "   vcRgOtab         Char( "+alltrim(str(aTam[1]))+" ) ;"+CRLF
	aTam     :=TamSX3("DVD_RGDTAB")
	cDeclare += "   vcRgDtab         Char( "+alltrim(str(aTam[1]))+" ) ;"+CRLF
EndIf
If (cAlias == "DW2")
	cDeclare += "   vcFil_DW0        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) ;"+CRLF
	cDeclare += "   vcFil_DW1        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) ;"+CRLF
	cDeclare += "   vcFil_DT0        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) ;"+CRLF
EndIf
cDeclare += "   vcFil_AAM        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) ;"+CRLF
cDeclare += "   viRecno          Integer ;"+CRLF 
cDeclare += "   viMaxRecno       Integer ;"+CRLF 

aTam     :=TamSX3("DVC_CODCLI")
cDeclare += "   vcCliente        Char( "+alltrim(str(aTam[1]))+" ) ;"+CRLF
aTam     :=TamSX3("DVC_LOJCLI")
cDeclare += "   vcLoja           Char( "+alltrim(str(aTam[1]))+" ) ;"+CRLF
cDeclare += "   vcConcat         Varchar( 200 ) ;"+CRLF

/* Verifica qual o maior campo @nValor */
If (cAlias == "DW2")
	cCmpValor := "DW1_VALOR;DW0_VALOR;DW2_PERAJU"
ElseIf (cAlias == "DVO")
	cCmpValor := "DTK_VALMIN;DTK_VALOR;DVO_PERMIN" 
ElseIf (cAlias == "DVD")
	cCmpValor := "DT1_VALOR;DTG_VALOR;DVD_PERAJU"+CRLF
EndIf

If (cAlias == "DW2") .or. (cAlias == "DVO") .or. (cAlias == "DVD")
	cCampo   := MaiorCampo(cCmpValor)
	aTam     := TamSX3(cCampo)
	cDeclare += "   vnGravaAju       Float ;"+CRLF
	cDeclare += "   vnValor          Float ;"+CRLF
	cDeclare += "   vnValTabAnt      Float ;"+CRLF
	cDeclare += "   vnPerNewAju      Float ;"+CRLF 

	If (cAlias == "DVO") .or. (cAlias == "DVD")
		cDeclare += "   vnPerNewMin      Float ;"+CRLF 
	EndIf 
	If (cAlias == "DVO")
		cDeclare += "   vnPerNewExc      Float ;"+CRLF 
	EndIf
EndIf

/* Verifica qual o campo @nValorTabNova */
If (cAlias == "DW2")
	cDeclare += "   vnValTabNova     Float ;"+CRLF
ElseIf (cAlias == "DVD")
	cDeclare += "   vnValTabNova     Float ;"+CRLF
EndIf

If (cAlias == "DVO")
	cDeclare += "   vnValMin         Float ;"+CRLF
	cDeclare += "   vnMinNov         Float ;"+CRLF
	cDeclare += "   vnValExc         Float ;"+CRLF
	cDeclare += "   vnExcNov         Float ;"+CRLF
	cDeclare += "   vnExcMin         Float ;"+CRLF
EndIf

If (cAlias == "DVO")
	cDeclare += "   vnPercAtu        Float ;"+CRLF
	cDeclare += "   vnValNewAju      Float ;"+CRLF
	cDeclare += "   vnValAntAju      Float ;"+CRLF
ElseIf (cAlias == "DW2")
	cDeclare += "   vnPercAtu        Float ;"+CRLF
	cDeclare += "   vnValNewAju      Float ;"+CRLF
	cDeclare += "   vnValAntAju      Float ;"+CRLF
ElseIf (cAlias == "DVD")
	cDeclare += "   vnPercAtu        Float ;"+CRLF
	cDeclare += "   vnValNewAju      Float ;"+CRLF
	cDeclare += "   vnValAntAju      Float ;"+CRLF
EndIf

//Monta Declaração do Cursor
For nC := 1 to len(aEstruExp)
	If Trim(aEstruExp[nC][1]) == cAlias+"_FILIAL" .or. Trim(aEstruExp[nC][1]) == "D_E_L_E_T_" .or. Trim(aEstruExp[nC][1]) == "R_E_C_N_O_" 
		loop
	EndIf
	If aEstruExp[nC][2] = "C" .or. aEstruExp[nC][2] = "D"
		cDeclare += "   vc"+Trim(aEstruExp[nC][1])+ "  Char( "+alltrim(str(aEstruExp[nC][3]))+" ) ;"+CRLF
	ElseIf aEstruExp[nC][2] = "N"
		If aEstruExp[nC][4] = 0
			cDeclare += "   vi"+Trim(aEstruExp[nC][1])+"   Integer ;"+CRLF 
		Else
			cDeclare += "   vn"+Trim(aEstruExp[nC][1])+"   Decimal( "+alltrim(str(aEstruExp[nC][3]))
			cDeclare += ","+alltrim(str(aEstruExp[nC][4]))+" ) ;"+CRLF
		EndIf
	EndIf
Next nC

If lNovaTab .And. !lMantemPrc
	lCalcPrc := .F.
EndIf

If lCalcPrc

	cCorpoIni := ""
	cCorpoIni += "   CURSOR CUR001 IS"+CRLF
	cCorpoIni += "   select "
	For nI := 1 To Len(aEstruExp)

		If Trim(aEstruExp[nI][1]) == cAlias+"_FILIAL"
			loop
		EndIf
		If aEstruExp [ nI , 1 ] $ cGroup
			cJoin  := "TMP"
		Else
			cJoin  := cAlias
		EndIf
		cCorpoIni += cJoin + "." + aEstruExp [ nI , 1 ] + ","
	Next nI

	cCorpoIni += "TMP" + ".R_E_C_N_O_"+CRLF

	/* Verificar como Montar o select que pode ser com o Alias ou Temp*/


	cCorpoIni +="     from " +cTemp+ " TMP, " +RetSqlName(cAlias)+ " " + cAlias +CRLF
	cCorpoIni += "   where " + cAlias + "." + cCampFil + " = TMP." + cCampFil +CRLF //filial 
	cCorpoIni += "     and " + cAlias + "." + cCampCli + " = TMP." + cCampCli +CRLF //cliente
	cCorpoIni += "     and " + cAlias + "." + cCampLoj + " = TMP." + cCampLoj +CRLF //loja
	cCorpoIni += "     and " + cAlias + "." + cCampTab + " = TMP." + cCampTab +CRLF //Tabela
	cCorpoIni += "     and " + cAlias + "." + cCampTip + " = TMP." + cCampTip +CRLF //Tipo da tabela
	cCorpoIni += "     and " + cAlias + "." + cCampSeq + " = TMP." + cCampSeq +CRLF // Sequencia
	cCorpoIni += "     and " + cAlias + "." + cCampOri + " = TMP." + cCampOri +CRLF //Origem
	cCorpoIni += "     and " + cAlias + "." + cCampDes + " = TMP." + cCampDes +CRLF //Destino
	cCorpoIni += "     and " + cAlias + "." + cCampPro + " = TMP." + cCampPro +CRLF //produto
	cCorpoIni += "     and " + cAlias + "." + cCampNeg + " = TMP." + cCampNeg +CRLF //negociacao
	cCorpoIni += "     and " + cAlias + "." + cCampSer + " = TMP." + cCampSer +CRLF //servico
	cCorpoIni += "     and " + cAlias + "." + "D_E_L_E_T_ = ' ' " 

	If cAlias == "DVD"
		cCorpoIni += CRLF + "      and " + cAlias + "." + cCampPas + " = TMP." + cCampPas  	//codigo do componente
		cCorpoIni += CRLF + "      and " + cAlias + "." + cCampIte + " = TMP." + cCampIte	//numero do item
	ElseIf cAlias == "DVO"
		cCorpoIni += CRLF + "      and " + cAlias + "." + cCampPas + " = TMP." + cCampPas    //codigo do componente
	ElseIf cAlias == "DW2"
		cCorpoIni += CRLF + "      and " + cAlias + "." + cCampPas + " = TMP." + cCampPas 	//codigo do componente
		cCorpoIni += CRLF + "      and " + cAlias + "." + cCampIteDVD + " = TMP." + cCampIteDVD //numero do item do ajuste
		cCorpoIni += CRLF + "      and " + cAlias + "." + cCampIte + " = TMP." + cCampIte 	//numero do item
	EndIf

	If !lNovaTab
		cCorpoIni += CRLF
		cCorpoIni += "    and exists ( "  +CRLF
		cCorpoIni += "          select AAM_FILIAL,AAM_CODCLI "  +CRLF
		cCorpoIni += "            from "+RetSqlName('AAM') + " AAM "  +CRLF
		cCorpoIni += "           where AAM.AAM_FILIAL  = vcFil_AAM" +CRLF
		cCorpoIni += "             and AAM.AAM_CODCLI  =  TMP"+"."+cCampCli  +CRLF
		cCorpoIni += "             and AAM.AAM_LOJA    =  TMP"+"."+cCampLoj  +CRLF
		cCorpoIni += "             and AAM.AAM_STATUS  = '1'"  +CRLF
		cCorpoIni += "             and ((AAM.AAM_INIVIG <= IN_DATABASE"  +CRLF
		cCorpoIni += "             and AAM.AAM_FIMVIG >= IN_DATABASE) or AAM.AAM_FIMVIG = ' ')"  +CRLF
		If cTipFre <> "4"
			cCorpoIni += "             and AAM.AAM_TIPFRE  = IN_TIPFRE"  +CRLF
		EndIf	
		cCorpoIni += "             and AAM.D_E_L_E_T_  = ' ' )"  +CRLF
		cCorpoIni += "             and TMP.D_E_L_E_T_ = ' ' "
	EndIf
	cCorpoIni += " ;" +CRLF
	cCorpoIni += CRLF

EndIf //If lCalcPrc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta corpo da procedure                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCorpoIni +="BEGIN"+CRLF

cCorpoIni +="   OUT_RESULTADO := '0' ;" +CRLF

If (cAlias == "DVD") 
	cCorpoIni +="   vcAux := 'DT0' ;"+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_DT0) ;" +CRLF
	cCorpoIni +="   vcAux := 'DT1' ;"+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_DT1) ;" +CRLF
	cCorpoIni +="   vcAux := 'DTG' ;"+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_DTG) ;" +CRLF 
EndIf

If (cAlias == "DVO")
	cCorpoIni +="   vcAux := 'DTK' ;"+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_DTK) ;" +CRLF
	cCorpoIni +="   vcAux := 'DVD' ;"+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_DVD) ;" +CRLF
EndIf

If (cAlias == "DW2")
	cCorpoIni +="   vcAux := 'DW0' ;"+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_DW0) ;" +CRLF
	cCorpoIni +="   vcAux := 'DW1' ;"+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_DW1) ;" +CRLF
	cCorpoIni +="   vcAux := 'DT0' ;"+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_DT0) ;" +CRLF
EndIf

If !lNovaTab
	cCorpoIni +="   vcAux := 'AAM' ;"+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_AAM) ;" +CRLF
Endif


cCorpoIni +=CRLF
cCorpoIni +="   INSERT INTO " +cTemp+ " ( "

For nI := 1 To Len( aEstruExp )
	cCorpoIni += aEstruExp[ nI, 1 ] + ", "
Next

cCorpoIni += "   R_E_C_N_O_, D_E_L_E_T_ ) " + cQueryAux + ";" + CRLF
cCorpoIni += "   commit;"+CRLF
cCorpoIni += CRLF

/*cCorpoIni += "   UPDATE " +cTemp+ " SET R_E_C_N_O_ = 1 + ROWNUM ;" + CRLF
cCorpoIni += "   commit;"+CRLF*/

If lCalcPrc

	cCorpoIni += CRLF
	cCorpoIni += "   OPEN CUR001;"+CRLF
	cCorpoIni += CRLF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta as variaveis do fetch                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	For nC := 1 to len(aEstruExp)   //colocar tratamento para recno e delete 
		If Trim(aEstruExp[nC][1]) == cAlias+"_FILIAL"
			loop
		EndIf
		If aEstruExp[nC][2] = "C" .or. aEstruExp[nC][2] = "D"
			cFetch += " vc"+Trim(aEstruExp[nC][1])+","
		ElseIf aEstruExp[nC][2] = "N"
			If aEstruExp[nC][4] = 0
				cFetch += " vi"+Trim(aEstruExp[nC][1])+","
			Else
				cFetch += " vn"+Trim(aEstruExp[nC][1])+","
			EndIf
		EndIf
	Next nC
	
	cCorpoIni += "   FETCH CUR001"+CRLF
	cCorpoIni += "    INTO " +cFetch +" viRecno ;" +CRLF
	
	cCorpoIni += CRLF
	cCorpoIni += "   WHILE ( (CUR001%FOUND) ) LOOP " +CRLF
	If cAlias == "DVC"
		cCorpoDVC :=""
		If !Empty(cFilCli)
			cCorpoDVC += "      vcCliente := vcDVC_CODCLI ;" +CRLF
			cCorpoDVC += "      vcLoja := vcDVC_LOJCLI ;" +CRLF
			cCorpoDVC +=CRLF
		EndIf
	ElseIf cAlias == "DVD"
		cCorpoDVD := ""
		cCorpoDVD += "      vcCliente := vcDVD_CODCLI ;" +CRLF
		cCorpoDVD += "      vcLoja := vcDVD_LOJCLI ;" +CRLF
		cCorpoDVD +=CRLF
		If lNovaTab
			cCorpoDVD += TMSA750O1(cTemp)
		Else
			cCorpoDVD += TMSA750O2(cTemp,cTrab)
		EndIf

	ElseIf cAlias == "DVO"
		cCorpoDVO := ""
		cCorpoDVO += "      vcCliente := vcDVO_CODCLI ;" +CRLF
		cCorpoDVO += "      vcLoja := vcDVO_LOJCLI ;" +CRLF
		cCorpoDVO +=CRLF
		cCorpoDVO1 := ""
		cCorpoDVO2 := ""
		If lNovaTab
			cCorpoDVO1 += "         vnValMin := null ;"+CRLF
			cCorpoDVO1 += "         vnValExc := null ;"+CRLF
			cCorpoDVO1 += "         vnExcMin := null ;"+CRLF
			cCorpoDVO1 +=CRLF
			cCorpoDVO1 += "         BEGIN"+CRLF
			cCorpoDVO1 += "            SELECT DTK_VALMIN, DTK_VALOR, DTK_EXCMIN "+CRLF
			cCorpoDVO1 += "              INTO vnValMin , vnValExc, vnExcMin "+CRLF
			cCorpoDVO1 += "              FROM "+RetSqlName("DTK")+CRLF
			cCorpoDVO1 += "             WHERE DTK_FILIAL = vcFil_DTK"+CRLF
			cCorpoDVO1 += "               AND DTK_TABFRE = vcDVO_TABFRE "+CRLF
			cCorpoDVO1 += "               AND DTK_TIPTAB = vcDVO_TIPTAB "+CRLF
			cCorpoDVO1 += "               AND DTK_CDRORI = vcDVO_CDRORI "+CRLF
			cCorpoDVO1 += "               AND DTK_CDRDES = vcDVO_CDRDES "+CRLF
			cCorpoDVO1 += "               AND DTK_CODPRO = vcDVO_CODPRO "+CRLF
			cCorpoDVO1 += "               AND DTK_CODPAS = vcDVO_CODPAS "+CRLF
			cCorpoDVO1 += "               AND D_E_L_E_T_ = ' ' ;"+CRLF
			cCorpoDVO1 += CRLF
			cCorpoDVO1 += "            EXCEPTION"+CRLF
			cCorpoDVO1 += "               WHEN NO_DATA_FOUND THEN NULL ;"+CRLF
			cCorpoDVO1 += "         END;"+CRLF
			cCorpoDVO1 += CRLF
			cCorpoDVO1 += "         IF ((vnValMin is null) or (vnValExc is null) or (vnExcMin is null)) THEN"+CRLF
			cCorpoDVO1 += "         	BEGIN"+CRLF
			cCorpoDVO1 += "            SELECT NVL( DTK_VALMIN, 0 ), NVL(DTK_VALOR, 0 ), NVL( DTK_EXCMIN, 0 ), DVD_RGOTAB, DVD_RGDTAB "+CRLF
			cCorpoDVO1 += "              INTO vnValMin , vnValExc, vnExcMin, vcRgOtab, vcRgDtab "+CRLF
			cCorpoDVO1 += "            		FROM "+RetSqlName("DTK")+' DTK,'+RetSqlName("DVD")+' DVD '+CRLF
			cCorpoDVO1 += "            	 WHERE DVD_FILIAL = vcFil_DVD"+CRLF
			cCorpoDVO1 += "                	AND DVD_TABFRE = vcDVO_TABFRE "+CRLF
			cCorpoDVO1 += "            		AND DVD_TIPTAB = vcDVO_TIPTAB "+CRLF
			cCorpoDVO1 += "            		AND DVD_CDRORI = vcDVO_CDRORI "+CRLF
			cCorpoDVO1 += "            		AND DVD_CDRDES = vcDVO_CDRDES "+CRLF
			cCorpoDVO1 += "              		AND DVD_CODCLI = vcCliente "+CRLF
			cCorpoDVO1 += "              		AND DVD_LOJCLI = vcLoja "+CRLF
			cCorpoDVO1 += "              		AND DVD_SEQTAB = vcDVO_SEQTAB "+CRLF
			cCorpoDVO1 += "              		AND DVD_CODPRO = vcDVO_CODPRO "+CRLF
			cCorpoDVO1 += "              		AND DVD_CODNEG = vcDVO_CODNEG "+CRLF
			cCorpoDVO1 += "              		AND DVD_SERVIC = vcDVO_SERVIC "+CRLF
			cCorpoDVO1 += "              		AND DVD_CODPAS = vcDVO_CODPAS "+CRLF
			cCorpoDVO1 += "               	AND DVD.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDVO1 += "             	   AND DTK_FILIAL = vcFil_DTK "+CRLF
			cCorpoDVO1 += "               	AND DTK_TABFRE = DVD_TABFRE "+CRLF
			cCorpoDVO1 += "               	AND DTK_TIPTAB = DVD_TIPTAB "+CRLF
			cCorpoDVO1 += "               	AND DTK_CDRORI = DVD_RGOTAB "+CRLF
			cCorpoDVO1 += "               	AND DTK_CDRDES = DVD_RGDTAB "+CRLF
			cCorpoDVO1 += "               	AND DTK_CODPRO = DVD_CODPRO "+CRLF
			cCorpoDVO1 += "  		           	AND DTK_CODPAS = DVD_CODPAS "+CRLF
			cCorpoDVO1 += "	              	AND DTK.D_E_L_E_T_ = ' ' ;"+CRLF
			cCorpoDVO1 +=CRLF
			cCorpoDVO1 += "	            EXCEPTION"+CRLF
			cCorpoDVO1 += "               	WHEN NO_DATA_FOUND THEN NULL ;"+CRLF
			cCorpoDVO1 += " 		   	END;"+CRLF
			cCorpoDVO1 += "         END IF; "+CRLF
			cCorpoDVO1 +=CRLF
			cCorpoDVO1 += "         IF ((vnValMin > 0) or (vnValExc > 0) or (vnExcMin > 0)) THEN"+CRLF 
			cCorpoDVO1 += "            BEGIN "+CRLF 
			cCorpoDVO1 += "         		vnMinNov := null ;"+CRLF
			cCorpoDVO1 += "         		vnExcNov := null ;"+CRLF
			cCorpoDVO1 +=CRLF
			cCorpoDVO1 += "               SELECT DTK_VALMIN ,DTK_VALOR "+CRLF
			cCorpoDVO1 += "                 INTO vnMinNov, vnExcNov"+CRLF  
			cCorpoDVO1 += "                 FROM "+RetSqlName("DTK")+CRLF 
			cCorpoDVO1 += "                WHERE DTK_FILIAL = vcFil_DTK"+CRLF 
			cCorpoDVO1 += "                  AND DTK_TABFRE = IN_NEWTABELA"+CRLF 
			cCorpoDVO1 += "                  AND DTK_TIPTAB = IN_NEWTIPTAB"+CRLF 
			cCorpoDVO1 += "                  AND DTK_CDRORI = vcDVO_CDRORI "+CRLF 
			cCorpoDVO1 += "                  AND DTK_CDRDES = vcDVO_CDRDES "+CRLF 
			cCorpoDVO1 += "                  AND DTK_CODPRO = vcDVO_CODPRO "+CRLF 
			cCorpoDVO1 += "                  AND DTK_CODPAS = vcDVO_CODPAS "+CRLF 
			cCorpoDVO1 += "                  AND D_E_L_E_T_ = ' ' ;"+CRLF
			cCorpoDVO1 += CRLF
			cCorpoDVO1 += "               EXCEPTION"+CRLF
			cCorpoDVO1 += "                  WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
			cCorpoDVO1 += "            END;"+CRLF 
			cCorpoDVO1 +=CRLF 
			cCorpoDVO1 += "            IF ((vnMinNov is null) or (vnExcNov is null)) THEN"+CRLF
			cCorpoDVO1 += "         		BEGIN"+CRLF
			cCorpoDVO1 += "               	SELECT NVL( DTK_VALMIN, 0 ) ,NVL( DTK_VALOR, 0 ) "+CRLF
			cCorpoDVO1 += "                 		INTO vnMinNov, vnExcNov"+CRLF
			cCorpoDVO1 += "            			FROM "+RetSqlName("DTK")+CRLF
			cCorpoDVO1 += "             	 	WHERE DTK_FILIAL = vcFil_DTK"+CRLF
			cCorpoDVO1 += "               		AND DTK_TABFRE = IN_NEWTABELA"+CRLF 
			cCorpoDVO1 += "               		AND DTK_TIPTAB = IN_NEWTIPTAB"+CRLF 
			cCorpoDVO1 += "               		AND DTK_CDRORI = vcRgOtab "+CRLF 
			cCorpoDVO1 += "               		AND DTK_CDRDES = vcRgDtab "+CRLF 
			cCorpoDVO1 += "               		AND DTK_CODPRO = vcDVO_CODPRO "+CRLF 
			cCorpoDVO1 += "  		           		AND DTK_CODPAS = vcDVO_CODPAS "+CRLF  
			cCorpoDVO1 += "	              		AND D_E_L_E_T_ = ' ' ;"+CRLF
			cCorpoDVO1 +=CRLF
			cCorpoDVO1 += "	            	EXCEPTION"+CRLF
			cCorpoDVO1 += "               		WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
			cCorpoDVO1 += " 		   		END;"+CRLF				
			cCorpoDVO1 += "         	END IF; "+CRLF 		 	
			cCorpoDVO1 +=CRLF
			cCorpoDVO1 += "            IF (vnValMin > 0 and vnMinNov > 0) THEN"+CRLF   
			cCorpoDVO1 += "               vnValTabAnt := vnValMin * (vnDVO_PERMIN / 100) ;"+CRLF
			cCorpoDVO1 += "               vnPerNewAju := (vnValTabAnt / vnMinNov) * 100 ;"+CRLF	       
			cCorpoDVO1 += "               UPDATE " + cTemp + " SET"+CRLF
			cCorpoDVO1 += "                       DVO_PERMIN = vnPerNewAju "+CRLF 
			cCorpoDVO1 += "                WHERE R_E_C_N_O_ = viRecno ;"+CRLF
			cCorpoDVO1 += "               commit ;"+CRLF
			cCorpoDVO1 += "            END IF ;"+CRLF
			cCorpoDVO1 +=CRLF
			cCorpoDVO1 += "            IF (vnValExc > 0 and vnExcNov > 0) THEN"+CRLF
			cCorpoDVO1 += "               vnValTabAnt := vnValExc * (vnDVO_PERAJU) / 100 ;"+CRLF
			cCorpoDVO1 += "               vnPerNewAju := (vnValTabAnt / vnExcNov) * 100 ;"+CRLF   
			cCorpoDVO1 += "               UPDATE " + cTemp + " SET"+CRLF
			cCorpoDVO1 += "                      DVO_PERAJU = vnPerNewAju "+CRLF	
			cCorpoDVO1 += "                WHERE R_E_C_N_O_ = viRecno ;"+CRLF
			cCorpoDVO1 += "               commit ;"+CRLF
			cCorpoDVO1 += "            END IF ;"+CRLF
			cCorpoDVO1 += "         ELSE"+CRLF 
			cCorpoDVO1 += "            UPDATE " + cTemp + " SET D_E_L_E_T_ = '*'"+CRLF
			cCorpoDVO1 += "             WHERE R_E_C_N_O_ = viRecno ;"+CRLF
			cCorpoDVO1 += "            commit ;"+CRLF
			cCorpoDVO1 += "         END IF;"+CRLF
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % Minimo                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "         vnPercAtu := vnDVO_PERMIN ;"+CRLF 
			cCorpoDVO2 += "         vnValor   := null ;"+CRLF 
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "         BEGIN"+CRLF
			cCorpoDVO2 += "            SELECT DTK_VALMIN "+CRLF
			cCorpoDVO2 += "              INTO vnValor"+CRLF
			cCorpoDVO2 += "              FROM "+RetSqlName("DTK")+CRLF 
			cCorpoDVO2 += "             WHERE DTK_FILIAL = vcFil_DTK"+CRLF
			cCorpoDVO2 += "               AND DTK_TABFRE = vcDVO_TABFRE"+CRLF 
			cCorpoDVO2 += "               AND DTK_TIPTAB = vcDVO_TIPTAB"+CRLF 
			cCorpoDVO2 += "               AND DTK_CDRORI = vcDVO_CDRORI "+CRLF 
			cCorpoDVO2 += "               AND DTK_CDRDES = vcDVO_CDRDES "+CRLF 
			cCorpoDVO2 += "               AND DTK_CODPRO = vcDVO_CODPRO "+CRLF 
			cCorpoDVO2 += "               AND DTK_CODPAS = vcDVO_CODPAS "+CRLF  
			cCorpoDVO2 += "               AND D_E_L_E_T_ = ' ' ;"+CRLF
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "            EXCEPTION"+CRLF
			cCorpoDVO2 += "               WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
			cCorpoDVO2 += "         END;"+CRLF
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "         IF ( vnValor is null ) THEN"+CRLF	 		
			cCorpoDVO2 += "         	BEGIN"+CRLF			
			cCorpoDVO2 += "            	SELECT NVL( DTK_VALMIN , 0 )"+CRLF
			cCorpoDVO2 += "            		INTO vnValor"+CRLF
			cCorpoDVO2 += "            		FROM "+RetSqlName("DTK")+' DTK,'+RetSqlName("DVD")+' DVD '+CRLF 	    	
			cCorpoDVO2 += "            	 WHERE DVD_FILIAL = vcFil_DVD"+CRLF
			cCorpoDVO2 += "                	AND DVD_TABFRE = vcDVO_TABFRE "+CRLF 	    	
			cCorpoDVO2 += "            		AND DVD_TIPTAB = vcDVO_TIPTAB "+CRLF 	    		    	
			cCorpoDVO2 += "            		AND DVD_CDRORI = vcDVO_CDRORI "+CRLF 	    		    	
			cCorpoDVO2 += "            		AND DVD_CDRDES = vcDVO_CDRDES "+CRLF 	    		    		    	
			cCorpoDVO2 += "              		AND DVD_CODCLI = vcCliente "+CRLF 	    	
			cCorpoDVO2 += "              		AND DVD_LOJCLI = vcLoja "+CRLF 	    				 
			cCorpoDVO2 += "              		AND DVD_SEQTAB = vcDVO_SEQTAB "+CRLF 	    				 			
			cCorpoDVO2 += "              		AND DVD_CODPRO = vcDVO_CODPRO "+CRLF 	    				 			
			cCorpoDVO2 += "              		AND DVD_CODNEG = vcDVO_CODNEG "+CRLF 	    				 			
			cCorpoDVO2 += "              		AND DVD_SERVIC = vcDVO_SERVIC "+CRLF 	    				 			
			cCorpoDVO2 += "              		AND DVD_CODPAS = vcDVO_CODPAS "+CRLF 	    				 			
			cCorpoDVO2 += "               	AND DVD.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDVO2 += "             	   AND DTK_FILIAL = vcFil_DTK "+CRLF
			cCorpoDVO2 += "               	AND DTK_TABFRE = DVD_TABFRE "+CRLF 
			cCorpoDVO2 += "               	AND DTK_TIPTAB = DVD_TIPTAB "+CRLF 
			cCorpoDVO2 += "               	AND DTK_CDRORI = DVD_RGOTAB "+CRLF 
			cCorpoDVO2 += "               	AND DTK_CDRDES = DVD_RGDTAB "+CRLF 
			cCorpoDVO2 += "               	AND DTK_CODPRO = DVD_CODPRO "+CRLF 
			cCorpoDVO2 += "  		           	AND DTK_CODPAS = DVD_CODPAS "+CRLF  
			cCorpoDVO2 += "	              	AND DTK.D_E_L_E_T_ = ' ' ;"+CRLF
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "	            EXCEPTION"+CRLF
			cCorpoDVO2 += "               	WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
			cCorpoDVO2 += " 		   	END;"+CRLF				
			cCorpoDVO2 += "         END IF; "+CRLF
			cCorpoDVO2 +=CRLF       
			cCorpoDVO2 += "         IF ( vnValor > 0 ) THEN"+CRLF
			cCorpoDVO2 += "            BEGIN"+CRLF         
			cCorpoDVO2 += "               SELECT NVL( TRB_PERMIN , 0 )"+CRLF
			cCorpoDVO2 += "                 INTO vnPerNewAju"+CRLF 
			cCorpoDVO2 += "                 FROM "+ cTrab +CRLF
			cCorpoDVO2 += "                WHERE TRB_CODPAS = vcDVO_CODPAS ;"+CRLF 
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "               EXCEPTION"+CRLF
			cCorpoDVO2 += "                  WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
			cCorpoDVO2 += "            END;"+CRLF 
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "            vnPerNewMin := 0 ;"+CRLF
			cCorpoDVO2 += "            IF (vnPercAtu > 0) THEN"+CRLF 
			cCorpoDVO2 += "               IF (vnPerNewAju > 0) THEN"+CRLF 
			                              //-- Valor do Ajuste Anterior dado a Tabela
			cCorpoDVO2 += "                  vnValAntAju := vnValor * ( vnPercAtu / 100) ;"+CRLF  			
			                              //-- Valor do Novo Ajuste 
			cCorpoDVO2 += "      	         vnValNewAju := vnValAntAju + (vnValAntAju * (vnPerNewAju / 100) ) ;"+CRLF
                                          //-- Percentual a ser aplicado no valor do componente 
			cCorpoDVO2 += "                  vnPerNewMin := (vnValNewAju / vnValor) * 100 ;"+CRLF
			cCorpoDVO2 += "               ELSE"+CRLF  
			cCorpoDVO2 += "                  vnPerNewMin := vnPercAtu ;"+CRLF        						
			cCorpoDVO2 += "               END IF;"+CRLF
			cCorpoDVO2 += "               vnGravaAju := vnPerNewMin ;"+CRLF 
			cCorpoDVO2 += "               UPDATE "+cTemp+" SET DVO_PERMIN = vnGravaAju"+CRLF
			cCorpoDVO2 += "                where R_E_C_N_O_ = viRecno ;"+CRLF
			cCorpoDVO2 += "               commit ;"+CRLF
			cCorpoDVO2 += "            END IF;"+CRLF               						
			cCorpoDVO2 += "         END IF; "+CRLF 
			cCorpoDVO2 +=CRLF
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % Excedente                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			cCorpoDVO2 += "         vnPercAtu := vnDVO_PERAJU ;"+CRLF 
	    	cCorpoDVO2 += "         vnValor   := null ;"+CRLF 
	    	cCorpoDVO2 +=CRLF
	    	cCorpoDVO2 += "         BEGIN"+CRLF
	    	cCorpoDVO2 += "            SELECT DTK_VALOR "+CRLF
	    	cCorpoDVO2 += "              INTO vnValor"+CRLF
	    	cCorpoDVO2 += "              FROM "+RetSqlName("DTK")+CRLF 
	    	cCorpoDVO2 += "             WHERE DTK_FILIAL = vcFil_DTK"+CRLF
	    	cCorpoDVO2 += "               AND DTK_TABFRE = vcDVO_TABFRE"+CRLF 
	 		cCorpoDVO2 += "               AND DTK_TIPTAB = vcDVO_TIPTAB"+CRLF 
	 		cCorpoDVO2 += "               AND DTK_CDRORI = vcDVO_CDRORI"+CRLF 
	 		cCorpoDVO2 += "               AND DTK_CDRDES = vcDVO_CDRDES"+CRLF 
	 		cCorpoDVO2 += "               AND DTK_CODPRO = vcDVO_CODPRO"+CRLF 
	 		cCorpoDVO2 += "               AND DTK_CODPAS = vcDVO_CODPAS "+CRLF
			cCorpoDVO2 += "               AND D_E_L_E_T_ = ' ' ;"+CRLF
	    	cCorpoDVO2 +=CRLF
	 		cCorpoDVO2 += "            EXCEPTION"+CRLF
	 		cCorpoDVO2 += "               WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
	 		cCorpoDVO2 += "         END;"+CRLF 
	    	cCorpoDVO2 +=CRLF                  
	    	cCorpoDVO2 += "         IF ( vnValor is null ) THEN"+CRLF	 		
	 		cCorpoDVO2 += "         	BEGIN"+CRLF			
	    	cCorpoDVO2 += "            	SELECT NVL( DTK_VALMIN , 0 )"+CRLF
	    	cCorpoDVO2 += "            		INTO vnValor"+CRLF
	    	cCorpoDVO2 += "            		FROM "+RetSqlName("DTK")+' DTK,'+RetSqlName("DVD")+' DVD '+CRLF 	    	
	    	cCorpoDVO2 += "            		WHERE DVD_FILIAL = vcFil_DVD"+CRLF
	    	cCorpoDVO2 += "                	AND DVD_TABFRE = vcDVO_TABFRE "+CRLF 	    	
	    	cCorpoDVO2 += "            		AND DVD_TIPTAB = vcDVO_TIPTAB "+CRLF 	    		    	
	    	cCorpoDVO2 += "            		AND DVD_CDRORI = vcDVO_CDRORI "+CRLF 	    		    	
	    	cCorpoDVO2 += "            		AND DVD_CDRDES = vcDVO_CDRDES "+CRLF 	    		    		    	
			cCorpoDVO2 += "              		AND DVD_CODCLI = vcCliente "+CRLF 	    	
			cCorpoDVO2 += "              		AND DVD_LOJCLI = vcLoja "+CRLF 	    				 
			cCorpoDVO2 += "              		AND DVD_SEQTAB = vcDVO_SEQTAB "+CRLF 	    				 			
			cCorpoDVO2 += "              		AND DVD_CODPRO = vcDVO_CODPRO "+CRLF 	    				 			
			cCorpoDVO2 += "              		AND DVD_CODNEG = vcDVO_CODNEG "+CRLF 	    				 			
			cCorpoDVO2 += "              		AND DVD_SERVIC = vcDVO_SERVIC "+CRLF 	    				 			
			cCorpoDVO2 += "              		AND DVD_CODPAS = vcDVO_CODPAS "+CRLF 	    				 			
			cCorpoDVO2 += "               	AND DVD.D_E_L_E_T_ = ' ' "+CRLF
	    	cCorpoDVO2 += "             	   AND DTK_FILIAL = vcFil_DTK  "+CRLF
	    	cCorpoDVO2 += "               	AND DTK_TABFRE = DVD_TABFRE "+CRLF 
	 		cCorpoDVO2 += "               	AND DTK_TIPTAB = DVD_TIPTAB "+CRLF 
			cCorpoDVO2 += "               	AND DTK_CDRORI = DVD_RGOTAB "+CRLF 
	 		cCorpoDVO2 += "               	AND DTK_CDRDES = DVD_RGDTAB "+CRLF 
	 		cCorpoDVO2 += "               	AND DTK_CODPRO = DVD_CODPRO "+CRLF 
		 	cCorpoDVO2 += "  		           	AND DTK_CODPAS = DVD_CODPAS "+CRLF  
			cCorpoDVO2 += "	              	AND DTK.D_E_L_E_T_ = ' ' ;"+CRLF
	    	cCorpoDVO2 +=CRLF
		 	cCorpoDVO2 += "	            EXCEPTION"+CRLF
		 	cCorpoDVO2 += "               	WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
		 	cCorpoDVO2 += " 		   	END;"+CRLF				
			cCorpoDVO2 += "         END IF; "+CRLF 		 	
	    	cCorpoDVO2 +=CRLF
	    	cCorpoDVO2 += "         IF ( vnValor > 0 ) THEN"+CRLF  
	    	cCorpoDVO2 += "            BEGIN"+CRLF
	    	cCorpoDVO2 += "               SELECT NVL( TRB_PERAJU , 0 )"+CRLF
	    	cCorpoDVO2 += "                 INTO vnPerNewAju"+CRLF 
	    	cCorpoDVO2 += "                 FROM "+ cTrab +CRLF
	    	cCorpoDVO2 += "                WHERE TRB_CODPAS = vcDVO_CODPAS ;"+CRLF
	    	cCorpoDVO2 += CRLF 
	 		cCorpoDVO2 += "               EXCEPTION"+CRLF
	 		cCorpoDVO2 += "                  WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
	 		cCorpoDVO2 += "            END;"+CRLF 
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "            vnPerNewExc := 0 ;"+CRLF
			cCorpoDVO2 +=CRLF
	    	cCorpoDVO2 += "            IF ( vnPercAtu > 0 ) THEN"+CRLF 
 			cCorpoDVO2 += "               IF ( vnPerNewAju > 0 ) THEN"+CRLF 
 											 //-- Valor do Ajuste Anterior dado a Tabela
			cCorpoDVO2 += "                  vnValAntAju := vnValor * ( vnPercAtu / 100) ;"+CRLF  			
 			                                 //-- Valor do Novo Ajuste 
			cCorpoDVO2 += "      	         vnValNewAju := vnValAntAju + (vnValAntAju * (vnPerNewAju / 100) ) ;"+CRLF
                                             //-- Percentual a ser aplicado no valor do componente 
			cCorpoDVO2 += "                  vnPerNewExc := (vnValNewAju / vnValor) * 100 ;"+CRLF  
 			cCorpoDVO2 += "               ELSE"+CRLF						
 			cCorpoDVO2 += "                  vnPerNewExc := vnPercAtu ;"+CRLF        						
 			cCorpoDVO2 += "               END IF ;"+CRLF   
 			cCorpoDVO2 += CRLF						
 			cCorpoDVO2 += "               vnGravaAju := vnPerNewExc ;"+CRLF 
 			cCorpoDVO2 += "               UPDATE "+cTemp+" SET DVO_PERAJU = vnGravaAju"+CRLF
 			cCorpoDVO2 += "                WHERE R_E_C_N_O_ = viRecno ;"+CRLF
 			cCorpoDVO2 += "               commit ;"+CRLF
 			cCorpoDVO2 += "            END IF ; "+CRLF
 			cCorpoDVO2 += "         END IF ;"+CRLF
 	    EndIf                    
 	ElseIf cAlias == "DW2"
 		cCorpoDW2 := ""
 		cCorpoDW2 += "      vcCliente := vcDW2_CODCLI ;"+CRLF
 		cCorpoDW2 += "      vcLoja := vcDW2_LOJCLI ;"+CRLF
     	cCorpoDW2 += "      vcConcat := vcCliente || vcLoja ;"+CRLF 	                   
		cCorpoDW2 +=CRLF       
		cCorpoDW21 := ""
		cCorpoDW22 := ""
 		If lNovaTab
 			cCorpoDW21 += "         vnValor := 0 ;" +CRLF
			cCorpoDW21 +=CRLF  
			cCorpoDW21 += "         BEGIN"+CRLF
			//-- Posiciona na Tabela Mae da Tabela Anterior
  			cCorpoDW21 += "            SELECT NVL( DW1_VALOR , 0 ) "+CRLF
  			cCorpoDW21 += "              INTO vnValor"+CRLF 
			cCorpoDW21 += "              FROM "+RetSqlName("DW1")+" DW1 ,"+RetSqlName("DT0")+" DT0 " +CRLF
			cCorpoDW21 += "             WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
			cCorpoDW21 += "               AND DT0_TABFRE = vcDW2_TABFRE "+CRLF
			cCorpoDW21 += "               AND DT0_TIPTAB = vcDW2_TIPTAB "+CRLF
			cCorpoDW21 += "               AND DT0_CDRORI = vcDW2_RGOTAB "+CRLF
			cCorpoDW21 += "      	      AND DT0_CDRDES = vcDW2_RGDTAB "+CRLF
			cCorpoDW21 += "               AND DT0_CODPRO = vcDW2_PRDTAB "+CRLF 
			cCorpoDW21 += "               AND DW1_FILIAL = vcFil_DW1 "+CRLF
			cCorpoDW21 += "               AND DW1_TABFRE = DT0_TABFRE "+CRLF
			cCorpoDW21 += "               AND DW1_TIPTAB = DT0_TIPTAB "+CRLF
			cCorpoDW21 += "               AND DW1_CDRORI = DT0_CDRORI "+CRLF
 			cCorpoDW21 += "               AND DW1_CDRDES = DT0_CDRDES "+CRLF
			cCorpoDW21 += "               AND DW1_CODPRO = DT0_CODPRO "+CRLF
			cCorpoDW21 += "               AND DW1_CODPAS = vcDW2_CODPAS "+CRLF  		
			cCorpoDW21 += "               AND DW1_ITEDT1 = vcDW2_ITEDVD "+CRLF
			cCorpoDW21 += "               AND DW1_ITEM   = vcDW2_ITEM "+CRLF
			cCorpoDW21 += "               AND DT0.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW21 += "               AND DW1.D_E_L_E_T_ = ' ' ;"+CRLF
			cCorpoDW21 += CRLF              
	 		cCorpoDW21 += "            EXCEPTION"+CRLF
	 		cCorpoDW21 += "               WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
	 		cCorpoDW21 += "         END ;"+CRLF 
			cCorpoDW21 += CRLF
			cCorpoDW21 += "         IF ( vnValor = 0 ) THEN" +CRLF
			cCorpoDW21 += "            BEGIN"+CRLF   
  			cCorpoDW21 += "               SELECT NVL( DW0_VALOR , 0 )"+CRLF
  			cCorpoDW21 += "                 INTO vnValor"+CRLF 
			cCorpoDW21 += "                 FROM "+RetSqlName("DW0")+" DW0 ,"+RetSqlName("DT0")+" DT0 "+CRLF
			cCorpoDW21 += "                WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
			cCorpoDW21 += "                  AND DT0_TABFRE = vcDW2_TABFRE "+CRLF
			cCorpoDW21 += "                  AND DT0_TIPTAB = vcDW2_TIPTAB "+CRLF
			cCorpoDW21 += "                  AND DT0_CDRORI = vcDW2_RGOTAB "+CRLF
			cCorpoDW21 += "      	         AND DT0_CDRDES = vcDW2_RGDTAB "+CRLF
			cCorpoDW21 += "                  AND DT0_CODPRO = vcDW2_PRDTAB "+CRLF   
			cCorpoDW21 += "                  AND DW0_FILIAL = vcFil_DW0 "+CRLF
			cCorpoDW21 += "                  AND DW0_TABFRE = DT0_TABFRE "+CRLF
			cCorpoDW21 += "                  AND DW0_TIPTAB = DT0_TIPTAB "+CRLF
			cCorpoDW21 += "                  AND DW0_TABTAR = DT0_TABTAR "+CRLF
 			cCorpoDW21 += "                  AND DW0_CODPAS = vcDW2_CODPAS "+CRLF
			cCorpoDW21 += "                  AND DW0_ITEDTG = vcDW2_ITEDVD "+CRLF
			cCorpoDW21 += "                  AND DW0_ITEM   = vcDW2_ITEM "+CRLF  
			cCorpoDW21 += "                  AND DT0.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW21 += "                  AND DW0.D_E_L_E_T_ = ' ' ;"+CRLF
			cCorpoDW21 += CRLF
	 		cCorpoDW21 += "               EXCEPTION"+CRLF
	 		cCorpoDW21 += "                  WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
	
			cCorpoDW21 += "            END ;"+CRLF
			cCorpoDW21 += "         END IF ;"+CRLF 
			cCorpoDW21 += CRLF  
			cCorpoDW21 += "         IF ( vnValor > 0 ) THEN"+CRLF
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Mantem o Valor do Ajuste da Tabela anterior                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCorpoDW21 += "            vnValTabNova := 0 ;"+CRLF
			cCorpoDW21 += "            BEGIN"+CRLF
			cCorpoDW21 += "               SELECT NVL( DW1_VALOR , 0 )"+CRLF
			cCorpoDW21 += "                 INTO vnValTabNova"+CRLF 
			cCorpoDW21 += "                 FROM "+RetSqlName("DW1")+" DW1 ,"+RetSqlName("DT0")+" DT0 "+CRLF
			cCorpoDW21 += "                WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
			cCorpoDW21 += "                  AND DT0_TABFRE = IN_NEWTABELA "+CRLF
			cCorpoDW21 += "                  AND DT0_TIPTAB = IN_NEWTIPTAB "+CRLF
			cCorpoDW21 += "                  AND DT0_CDRORI = vcDW2_RGOTAB "+CRLF
			cCorpoDW21 += "      	         AND DT0_CDRDES = vcDW2_RGDTAB "+CRLF
			cCorpoDW21 += "                  AND DT0_CODPRO = vcDW2_PRDTAB "+CRLF 
			cCorpoDW21 += "                  AND DW1_FILIAL = vcFil_DW1 "+CRLF
			cCorpoDW21 += "                  AND DW1_TABFRE = IN_NEWTABELA "+CRLF
			cCorpoDW21 += "                  AND DW1_TIPTAB = IN_NEWTIPTAB "+CRLF
			cCorpoDW21 += "                  AND DW1_CDRORI = DT0_CDRORI "+CRLF
 			cCorpoDW21 += "                  AND DW1_CDRDES = DT0_CDRDES "+CRLF
			cCorpoDW21 += "                  AND DW1_CODPRO = DT0_CODPRO "+CRLF
			cCorpoDW21 += "                  AND DW1_CODPAS = vcDW2_CODPAS "+CRLF
			cCorpoDW21 += "                  AND DW1_ITEDT1 = vcDW2_ITEDVD "+CRLF
			cCorpoDW21 += "                  AND DW1_ITEM   = vcDW2_ITEM "+CRLF
			cCorpoDW21 += "                  AND DT0.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW21 += "                  AND DW1.D_E_L_E_T_ = ' ' ;"+CRLF
			cCorpoDW21 += CRLF
	 		cCorpoDW21 += "               EXCEPTION"+CRLF
	 		cCorpoDW21 += "                  WHEN NO_DATA_FOUND THEN NULL ;"+CRLF
	 		cCorpoDW21 += "            END ;"+CRLF

			cCorpoDW21 += CRLF
			cCorpoDW21 += "            IF ( vnValTabNova = 0 ) THEN"+CRLF
			cCorpoDW21 += "               BEGIN"+CRLF
			cCorpoDW21 += "                  SELECT NVL( DW0_VALOR , 0 )"+CRLF
			cCorpoDW21 += "                    INTO vnValTabNova"+CRLF 
			cCorpoDW21 += "                    FROM "+RetSqlName("DW0")+" DW0 ,"+RetSqlName("DT0")+" DT0 "+CRLF
			cCorpoDW21 += "                   WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
			cCorpoDW21 += "                     AND DT0_TABFRE = IN_NEWTABELA "+CRLF
			cCorpoDW21 += "                     AND DT0_TIPTAB = IN_NEWTIPTAB "+CRLF
			cCorpoDW21 += "                     AND DT0_CDRORI = vcDW2_RGOTAB "+CRLF
			cCorpoDW21 += "                     AND DT0_CDRDES = vcDW2_RGDTAB "+CRLF
			cCorpoDW21 += "                     AND DT0_CODPRO = vcDW2_PRDTAB "+CRLF
			cCorpoDW21 += "                     AND DW0_FILIAL = vcFil_DW0 "+CRLF
			cCorpoDW21 += "                     AND DW0_TABFRE = IN_NEWTABELA "+CRLF
			cCorpoDW21 += "                     AND DW0_TIPTAB = IN_NEWTIPTAB "+CRLF
			cCorpoDW21 += "                     AND DW0_TABTAR = DT0_TABTAR "+CRLF
 			cCorpoDW21 += "                     AND DW0_CODPAS = vcDW2_CODPAS "+CRLF
			cCorpoDW21 += "                     AND DW0_ITEDTG = vcDW2_ITEDVD "+CRLF
			cCorpoDW21 += "                     AND DW0_ITEM   = vcDW2_ITEM "+CRLF
			cCorpoDW21 += "                     AND DT0.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW21 += "                     AND DW0.D_E_L_E_T_ = ' ' ;"+CRLF
			cCorpoDW21 += CRLF
	 		cCorpoDW21 += "                  EXCEPTION"+CRLF
	 		cCorpoDW21 += "                     WHEN NO_DATA_FOUND THEN NULL ;"+CRLF
	 		cCorpoDW21 += "               END;"+CRLF
	 		cCorpoDW21 += "            END IF;"+CRLF
	 		cCorpoDW21 += CRLF
			cCorpoDW21 += "            IF ( vnValTabNova > 0 ) THEN"+CRLF
			cCorpoDW21 += "               vnValTabAnt := vnValor * (vnDW2_PERAJU / 100) ;"+CRLF
			cCorpoDW21 += "               vnPerNewAju := (vnValTabAnt / vnValTabNova) * 100 ;"+CRLF
			cCorpoDW21 += CRLF
			cCorpoDW21 += "               UPDATE " +cTemp+ " SET DW2_PERAJU = vnPerNewAju"+CRLF
			cCorpoDW21 += "                WHERE R_E_C_N_O_ = viRecno ;"+CRLF
			cCorpoDW21 += "               commit ;"+CRLF
			cCorpoDW21 += "            END IF ;"+CRLF
			cCorpoDW21 += "         END IF ;"+CRLF
		Else
			cCorpoDW22 += ""
 			cCorpoDW22 += "         vnValor := 0 ;" +CRLF
			cCorpoDW22+=CRLF
			//-- Posiciona na Tabela Mae da Tabela Anterior
			cCorpoDW22 += "         BEGIN"+CRLF
  			cCorpoDW22 += "            SELECT NVL( DW1_VALOR , 0 )"+CRLF
  			cCorpoDW22 += "              INTO vnValor"+CRLF
			cCorpoDW22 += "              FROM "+RetSqlName("DW1")+" DW1 ,"+RetSqlName("DT0")+" DT0 " +CRLF
			cCorpoDW22 += "             WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
			cCorpoDW22 += "               AND DT0_TABFRE = vcDW2_TABFRE "+CRLF
			cCorpoDW22 += "               AND DT0_TIPTAB = vcDW2_TIPTAB "+CRLF
			cCorpoDW22 += "               AND DT0_CDRORI = vcDW2_RGOTAB "+CRLF
			cCorpoDW22 += "      	      AND DT0_CDRDES = vcDW2_RGDTAB "+CRLF
			cCorpoDW22 += "               AND DT0_CODPRO = vcDW2_PRDTAB "+CRLF 
			cCorpoDW22 += "               AND DW1_FILIAL = vcFil_DW1 "   +CRLF
			cCorpoDW22 += "               AND DW1_TABFRE = DT0_TABFRE "+CRLF
			cCorpoDW22 += "               AND DW1_TIPTAB = DT0_TIPTAB "+CRLF
			cCorpoDW22 += "               AND DW1_CDRORI = DT0_CDRORI "+CRLF
 			cCorpoDW22 += "               AND DW1_CDRDES = DT0_CDRDES "+CRLF
			cCorpoDW22 += "               AND DW1_CODPRO = DT0_CODPRO "+CRLF
			cCorpoDW22 += "               AND DW1_CODPAS = vcDW2_CODPAS "+CRLF  		
			cCorpoDW22 += "               AND DW1_ITEDT1 = vcDW2_ITEDVD "+CRLF
			cCorpoDW22 += "               AND DW1_ITEM   = vcDW2_ITEM "+CRLF
			cCorpoDW22 += "               AND DT0.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW22 += "               AND DW1.D_E_L_E_T_ = ' ' ;"+CRLF
			cCorpoDW22 += CRLF            
	 		cCorpoDW22 += "            EXCEPTION"+CRLF
	 		cCorpoDW22 += "               WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
	 		cCorpoDW22 += "         END;"+CRLF
			cCorpoDW22 += CRLF
			cCorpoDW22 += "         IF ( vnValor = 0 ) THEN" +CRLF
			cCorpoDW22 += "            BEGIN"+CRLF   
  			cCorpoDW22 += "               SELECT NVL( DW0_VALOR , 0 ) "+CRLF
  			cCorpoDW22 += "                 INTO vnValor"+CRLF
			cCorpoDW22 += "                 FROM "+RetSqlName("DW0")+" DW0 ,"+RetSqlName("DT0")+" DT0 " +CRLF
			cCorpoDW22 += "                WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
			cCorpoDW22 += "                  AND DT0_TABFRE = vcDW2_TABFRE "+CRLF
			cCorpoDW22 += "                  AND DT0_TIPTAB = vcDW2_TIPTAB "+CRLF
			cCorpoDW22 += "                  AND DT0_CDRORI = vcDW2_RGOTAB "+CRLF
			cCorpoDW22 += "      	         AND DT0_CDRDES = vcDW2_RGDTAB "+CRLF
			cCorpoDW22 += "                  AND DT0_CODPRO = vcDW2_PRDTAB "+CRLF   
			cCorpoDW22 += "                  AND DW0_FILIAL = vcFil_DW0 "+CRLF
			cCorpoDW22 += "                  AND DW0_TABFRE = DT0_TABFRE "+CRLF
			cCorpoDW22 += "                  AND DW0_TIPTAB = DT0_TIPTAB "+CRLF
			cCorpoDW22 += "                  AND DW0_TABTAR = DT0_TABTAR "+CRLF
 			cCorpoDW22 += "                  AND DW0_CODPAS = vcDW2_CODPAS "+CRLF
			cCorpoDW22 += "                  AND DW0_ITEDTG = vcDW2_ITEDVD "+CRLF
			cCorpoDW22 += "                  AND DW0_ITEM   = vcDW2_ITEM "+CRLF  
			cCorpoDW22 += "                  AND DT0.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW22 += "                  AND DW0.D_E_L_E_T_ = ' ' ;"+CRLF 
			cCorpoDW22 += CRLF            
	 		cCorpoDW22 += "               EXCEPTION"+CRLF
	 		cCorpoDW22 += "                  WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
	 		cCorpoDW22 += "            END;"+CRLF
	 		cCorpoDW22 += "         END IF;"+CRLF
			cCorpoDW22 += CRLF
			cCorpoDW22 += "         IF ( vnValor > 0 ) THEN"+CRLF
			cCorpoDW22 += "            vnPercAtu := vnDW2_PERAJU ;"+CRLF 
			cCorpoDW22 += "            BEGIN"+CRLF
	    	cCorpoDW22 += "               SELECT NVL( TRB_PERREA , 0 )"+CRLF
	    	cCorpoDW22 += "                 INTO vnPerNewAju"+CRLF 
	    	cCorpoDW22 += "                 FROM "+ cTrab +CRLF
	    	cCorpoDW22 += "                WHERE TRB_CODPAS = vcDW2_CODPAS ;"+CRLF
	    	cCorpoDW22 += CRLF    
	    	cCorpoDW22 += "               EXCEPTION"+CRLF
	 		cCorpoDW22 += "                  WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
	 		cCorpoDW22 += "            END;"+CRLF
			cCorpoDW22 += CRLF
	    	cCorpoDW22 += "            IF ( vnPercAtu > 0 ) THEN"+CRLF 
 			cCorpoDW22 += "               IF ( vnPerNewAju > 0 ) THEN"+CRLF 
 											//-- Valor do Ajuste Anterior dado a Tabela
			cCorpoDW22 += "                  vnValAntAju := vnValor * ( vnPercAtu / 100) ;"+CRLF  			
 			                              	//-- Valor do Novo Ajuste 
			cCorpoDW22 += "      	         vnValNewAju := vnValAntAju + (vnValAntAju * (vnPerNewAju / 100) ) ;"+CRLF
                                          	//-- Percentual a ser aplicado no valor do componente 
			cCorpoDW22 += "                  vnPerNewAju := (vnValNewAju / vnValor) * 100 ;"+CRLF  
 			cCorpoDW22 += "               ELSE"+CRLF						
 			cCorpoDW22 += "                  vnPerNewAju := vnPercAtu ;"+CRLF        						
 			cCorpoDW22 += "               END IF ;"+CRLF
 			cCorpoDW22 += CRLF      
 			cCorpoDW22 += "               vnGravaAju := vnPerNewAju ;"+CRLF  
 			cCorpoDW22 += "               UPDATE " +cTemp+ " SET DW2_PERAJU = vnGravaAju"+CRLF      
			cCorpoDW22 += "                WHERE R_E_C_N_O_ = viRecno ;"+CRLF
			cCorpoDW22 += "               commit ;"+CRLF						
			cCorpoDW22 += "            END IF ;"+CRLF 
			cCorpoDW22 += "         END IF ;"+CRLF
		EndIf
	EndIf 
 	
	cCorpoFim :=""
	cCorpoFim += CRLF
	cCorpoFim += "      FETCH CUR001"+CRLF
	cCorpoFim += "       INTO " +cFetch +" viRecno ;" +CRLF  
	cCorpoFim += "   END LOOP; "+CRLF
	cCorpoFim +=CRLF
	cCorpoFim += "   CLOSE CUR001 ;"+CRLF
	cCorpoFim +=CRLF
	cCorpoFim += "   BEGIN"+CRLF 
	cCorpoFim += "      SELECT NVL( max(R_E_C_N_O_) , 0 )"+CRLF 
	cCorpoFim += "        INTO viMaxRecno"+CRLF
	cCorpoFim += "        FROM "+ RetSqlName( cAlias ) +" ;" +CRLF   //verficar IsNull | MAX
	cCorpoFim += CRLF    
	cCorpoFim += "      EXCEPTION"+CRLF
	cCorpoFim += "         WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
	cCorpoFim += "   END ;"+CRLF
	cCorpoFim += CRLF
	cCorpoFim += "   commit ;"+CRLF
		
EndIf //lCalcPrc

cCorpoFim  += CRLF
cCorpoFim  += "	  OUT_RESULTADO := '1' ;"+CRLF
cCorpoFim  += "END;" 

cProcedure := ""
If (cAlias == "DVC")
	cProcedure := cCreate + cDeclare + cCorpoIni + cCorpoDVC + cCorpoFim
ElseIf (cAlias == "DVD")
	cProcedure := cCreate + cDeclare + cCorpoIni + cCorpoDVD + cCorpoFim
ElseIf (cAlias == "DVO") 
	If lNovaTab
		cProcedure := cCreate + cDeclare + cCorpoIni + cCorpoDVO +cCorpoDVO1 + cCorpoFim
	Else
		cProcedure := cCreate + cDeclare + cCorpoIni + cCorpoDVO +cCorpoDVO2 + cCorpoFim
	EndIf
ElseIf (cAlias == "DW2")
	If lNovaTab
		cProcedure := cCreate + cDeclare + cCorpoIni + cCorpoDW2 +cCorpoDW21 + cCorpoFim
	Else
		cProcedure := cCreate + cDeclare + cCorpoIni + cCorpoDW2 +cCorpoDW22 + cCorpoFim
	EndIf
EndIf

TcSqlExec(cProcedure)

cProc01 := "XFILIAL"
cProc02 := cTrab

cSelVer1 := "SELECT 1 AS COUNT FROM DUAL WHERE EXISTS (SELECT 1 FROM USER_OBJECTS WHERE OBJECT_NAME = '"+cTrab+"_"+cEmpAnt+"'  AND STATUS='VALID')"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSelVer1),"TMSPROC",.F.,.T.)

nTmsProc := 0

While !TMSPROC->(Eof()) 
	nTmsProc := TMSPROC->COUNT
	TMSPROC->(dbSkip())
EndDo 

TMSPROC->( DbCloseArea() )

cSelVer2 := "SELECT 1 AS COUNT FROM DUAL WHERE EXISTS (SELECT 1 FROM USER_OBJECTS WHERE OBJECT_NAME =  'XFILIAL_"+cEmpAnt+"'  AND STATUS='VALID')"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSelVer2),"XFILPROC",.F.,.T.)

nXFilProc := 0

While !XFILPROC->(Eof()) 
	nXFilProc := XFILPROC->COUNT
	XFILPROC->(dbSkip())
EndDo

XFILPROC->( DbCloseArea() )

If (nXFilProc > 0) .And. (nTmsProc > 0) .And. ( TcSrvType() <> "AS/400" )

	cFilCliPrc := Iif(Empty(cFilCli), " ", cFilCli)
	cNewTabelaPrc := Iif(Empty(cNewTabela), " ", cNewTabela)
	cNewTipTabPrc := Iif(Empty(cNewTipTab)," ", cNewTipTab)

	MsgRun(STR0039,;
			STR0040,{|| 	aResult := TCSPExec(xProcedures(cProc02),FWGETCODFILIAL,;
			cNewTabelaPrc,  cNewTipTabPrc, dtos(dDataBase),  cTipFre) } )		    //processo sendo escutado 


	If Empty(aResult) .or. aResult[1] = "0"

		MsgRun(STR0041,;
				STR0040,{|| TmsA750Aju( cAlias, cQueryAux, cTipFre,;
				cFilCli, cNewTabela, cNewTipTab, lMantemPrc, cSeqTab, aMsgErr , cGroup, cCliAtu, cLojAtu ,.F. , cTemp ) } )		    
	Endif
Else 

		MsgRun(STR0041,;
			STR0040,{|| TmsA750Aju( cAlias, cQueryAux, cTipFre,;
			cFilCli, cNewTabela, cNewTipTab, lMantemPrc, cSeqTab, aMsgErr , cGroup, cCliAtu,cLojAtu, .F. ,cTemp ) } )		        
EndIf

Return.T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMSA750O1 º Autor ³ Ricardo C Pereira  º Data ³  20/06/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta corpo da Procedure para Alias DVD (Reaj Tab Frete)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cTemp - Alias Temporário                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ cCorpo - Corpo da Procedure                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA750                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMSA750O1(cTemp)

Local cCorpo := ""

cCorpo += "         vnValor := 0 ;" +CRLF

//-- Posiciona na Tabela Mae da Tabela Anterior
cCorpo += "         BEGIN"+CRLF
cCorpo += "            SELECT NVL( DT1_VALOR , 0 )"+CRLF
cCorpo += "              INTO vnValor"+CRLF
cCorpo += "              FROM "+RetSqlName("DT1")+" DT1 ,"+RetSqlName("DT0")+" DT0 " +CRLF
cCorpo += "             WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
cCorpo += "               AND DT0_TABFRE = vcDVD_TABFRE "+CRLF
cCorpo += "               AND DT0_TIPTAB = vcDVD_TIPTAB "+CRLF
cCorpo += "               AND DT0_CDRORI = vcDVD_RGOTAB "+CRLF
cCorpo += "      	      AND DT0_CDRDES = vcDVD_RGDTAB "+CRLF
cCorpo += "               AND DT0_CODPRO = vcDVD_PRDTAB "+CRLF
cCorpo += "               AND DT1_FILIAL = vcFil_DT1 "+CRLF
cCorpo += "               AND DT1_TABFRE = DT0_TABFRE "+CRLF
cCorpo += "               AND DT1_TIPTAB = DT0_TIPTAB "+CRLF
cCorpo += "               AND DT1_CDRORI = DT0_CDRORI "+CRLF
cCorpo += "               AND DT1_CDRDES = DT0_CDRDES "+CRLF
cCorpo += "               AND DT1_CODPRO = DT0_CODPRO "+CRLF
cCorpo += "               AND DT1_CODPAS = vcDVD_CODPAS "+CRLF
cCorpo += "               AND DT1_ITEM   = vcDVD_ITEM "+CRLF
cCorpo += "               AND DT0.D_E_L_E_T_ = ' ' "+CRLF
cCorpo += "               AND DT1.D_E_L_E_T_ = ' ' ;"+CRLF 
cCorpo += CRLF 
cCorpo += "            EXCEPTION"+CRLF
cCorpo += "               WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
cCorpo += "         END;"+CRLF 
cCorpo +=CRLF
cCorpo += "         IF ( vnValor = 0 ) THEN" +CRLF
cCorpo += "            BEGIN"+CRLF
cCorpo += "      	      SELECT NVL( DTG_VALOR , 0 )"+CRLF  
cCorpo += "                 INTO vnValor"+CRLF
cCorpo += "                 FROM "+RetSqlName("DTG")+" DTG ,"+RetSqlName("DT0")+" DT0 " +CRLF
cCorpo += "                WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
cCorpo += "                  AND DT0_TABFRE = vcDVD_TABFRE "+CRLF
cCorpo += "                  AND DT0_TIPTAB = vcDVD_TIPTAB "+CRLF
cCorpo += "                  AND DT0_CDRORI = vcDVD_RGOTAB "+CRLF
cCorpo += "                  AND DT0_CDRDES = vcDVD_RGDTAB "+CRLF
cCorpo += "                  AND DT0_CODPRO = vcDVD_PRDTAB "+CRLF
cCorpo += "                  AND DTG_FILIAL = vcFil_DTG "   +CRLF	
cCorpo += "                  AND DTG_TABFRE = DT0_TABFRE "  +CRLF
cCorpo += "                  AND DTG_TIPTAB = DT0_TIPTAB "  +CRLF
cCorpo += "                  AND DTG_TABTAR = DT0_TABTAR "  +CRLF
cCorpo += "                  AND DTG_CODPAS = vcDVD_CODPAS "+CRLF
cCorpo += "                  AND DTG_ITEM   = vcDVD_ITEM "+CRLF
cCorpo += "                  AND DT0.D_E_L_E_T_ = ' ' "+CRLF
cCorpo += "                  AND DTG.D_E_L_E_T_ = ' ' ;"+CRLF
cCorpo += CRLF 
cCorpo += "               EXCEPTION"+CRLF
cCorpo += "                  WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
cCorpo += "            END;"+CRLF 
cCorpo += "         END IF;"+CRLF
cCorpo += CRLF
cCorpo += "         IF ( vnValor > 0 ) THEN" +CRLF
cCorpo += CRLF
cCorpo += "            vnValTabNova := 0 ;"+CRLF 
cCorpo += CRLF
cCorpo += "            BEGIN"+CRLF
cCorpo += "               SELECT NVL( DT1_VALOR , 0 )"+CRLF
cCorpo += "                 INTO vnValTabNova"+CRLF
cCorpo += "                 FROM "+RetSqlName("DT1")+" DT1 ,"+RetSqlName("DT0")+" DT0 " +CRLF		
cCorpo += "                WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
cCorpo += "                  AND DT0_TABFRE = IN_NEWTABELA"+CRLF
cCorpo += "                  AND DT0_TIPTAB = IN_NEWTIPTAB"+CRLF
cCorpo += "                  AND DT0_CDRORI = vcDVD_RGOTAB "+CRLF
cCorpo += "                  AND DT0_CDRDES = vcDVD_RGDTAB "+CRLF
cCorpo += "                  AND DT0_CODPRO = vcDVD_PRDTAB "+CRLF
cCorpo += "                  AND DT1_FILIAL = vcFil_DT1 "+CRLF
cCorpo += "                  AND DT1_TABFRE = IN_NEWTABELA"+CRLF
cCorpo += "                  AND DT1_TIPTAB = IN_NEWTIPTAB"+CRLF
cCorpo += "                  AND DT1_CDRORI = DT0_CDRORI "+CRLF
cCorpo += "                  AND DT1_CDRDES = DT0_CDRDES "+CRLF
cCorpo += "                  AND DT1_CODPRO = DT0_CODPRO "+CRLF
cCorpo += "                  AND DT1_CODPAS = vcDVD_CODPAS "+CRLF
cCorpo += "                  AND DT1_ITEM   = vcDVD_ITEM "+CRLF
cCorpo += "                  AND DT1.D_E_L_E_T_ = ' ' "+CRLF
cCorpo += "                  AND DT0.D_E_L_E_T_ = ' ' ;"+CRLF
cCorpo += CRLF 
cCorpo += "               EXCEPTION"+CRLF
cCorpo += "                  WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
cCorpo += "            END;"+CRLF
cCorpo += CRLF
cCorpo += "            IF ( vnValTabNova = 0 ) THEN"+CRLF 
cCorpo += "               BEGIN "+CRLF
cCorpo += "                  SELECT NVL( DTG_VALOR , 0 )"+CRLF
cCorpo += "                    INTO vnValTabNova"+CRLF
cCorpo += "                    FROM "+RetSqlName("DTG")+" DTG ,"+RetSqlName("DT0")+" DT0 " +CRLF		
cCorpo += "                   WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
cCorpo += "                     AND DT0_TABFRE = IN_NEWTABELA"+CRLF
cCorpo += "                     AND DT0_TIPTAB = IN_NEWTIPTAB"+CRLF
cCorpo += "                     AND DT0_CDRORI = vcDVD_RGOTAB "+CRLF
cCorpo += "                     AND DT0_CDRDES = vcDVD_RGDTAB "+CRLF
cCorpo += "                     AND DT0_CODPRO = vcDVD_PRDTAB "+CRLF
cCorpo += "                     AND DTG_FILIAL = vcFil_DTG "+CRLF
cCorpo += "                     AND DTG_TABFRE = IN_NEWTABELA"+CRLF
cCorpo += "                     AND DTG_TIPTAB = IN_NEWTIPTAB"+CRLF
cCorpo += "                     AND DTG_TABTAR = DT0_TABTAR"+CRLF
cCorpo += "                     AND DTG_CODPAS = vcDVD_CODPAS "+CRLF
cCorpo += "                     AND DTG_ITEM   = vcDVD_ITEM "+CRLF
cCorpo += "                     AND DTG.D_E_L_E_T_ = ' ' "+CRLF
cCorpo += "                     AND DT0.D_E_L_E_T_ = ' ' ;"+CRLF      
cCorpo += CRLF 
cCorpo += "                  EXCEPTION"+CRLF
cCorpo += "                     WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
cCorpo += "               END;"+CRLF
cCorpo += "            END IF ;"+CRLF
cCorpo += "            IF ( vnValTabNova > 0 ) THEN "+CRLF 
cCorpo += "               vnValTabAnt := vnValor * (vnDVD_PERAJU / 100) ;"+CRLF
cCorpo += "               vnPerNewAju := ( vnValTabAnt / vnValTabNova) * 100 ;"+CRLF   
cCorpo += CRLF
cCorpo += "               UPDATE " + cTemp + " SET "+CRLF
cCorpo += "                      DVD_PERAJU = vnPerNewAju"+CRLF 
cCorpo += "                WHERE R_E_C_N_O_ = viRecno ;"+CRLF
//cCorpo += "               commit;"+CRLF   
cCorpo += CRLF
cCorpo += "               
cCorpo += "            END IF ; "+CRLF	
cCorpo += "         END IF ;"+CRLF 
Return cCorpo


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMSA750O1 º Autor ³ Ricardo C Pereira  º Data ³  20/06/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta corpo da Procedure para Alias DVD (Gera Contrato)    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cTemp - Alias Temporário                                   º±±  
±±             cTrab - Alias da Tabela de Itens                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ NIL                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA750                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMSA750O2(cTemp,cTrab)

Local cCorpo := ""

cCorpo += "         vnValor := 0 ;" +CRLF
//-- Posiciona na Tabela Mae da Tabela Anterior
cCorpo += "         BEGIN"+CRLF		
cCorpo += "            SELECT NVL( DT1_VALOR , 0 )"+CRLF
cCorpo += "              INTO vnValor"+CRLF
cCorpo += "              FROM "+RetSqlName("DT1")+" DT1 ,"+RetSqlName("DT0")+" DT0 " +CRLF
cCorpo += "             WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
cCorpo += "               AND DT0_TABFRE = vcDVD_TABFRE "+CRLF
cCorpo += "               AND DT0_TIPTAB = vcDVD_TIPTAB "+CRLF
cCorpo += "               AND DT0_CDRORI = vcDVD_RGOTAB "+CRLF
cCorpo += "      	      AND DT0_CDRDES = vcDVD_RGDTAB "+CRLF
cCorpo += "               AND DT0_CODPRO = vcDVD_PRDTAB "+CRLF
cCorpo += "               AND DT1_FILIAL = vcFil_DT1 "   +CRLF
cCorpo += "               AND DT1_TABFRE = DT0_TABFRE "+CRLF
cCorpo += "               AND DT1_TIPTAB = DT0_TIPTAB "+CRLF
cCorpo += "               AND DT1_CDRORI = DT0_CDRORI "+CRLF
cCorpo += "               AND DT1_CDRDES = DT0_CDRDES "+CRLF
cCorpo += "               AND DT1_CODPRO = DT0_CODPRO "+CRLF
cCorpo += "               AND DT1_CODPAS = vcDVD_CODPAS "+CRLF
cCorpo += "               AND DT1_ITEM   = vcDVD_ITEM "+CRLF
cCorpo += "               AND DT0.D_E_L_E_T_ = ' ' "+CRLF
cCorpo += "               AND DT1.D_E_L_E_T_ = ' ' ;"+CRLF 
cCorpo += CRLF 
cCorpo += "            EXCEPTION"+CRLF
cCorpo += "               WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
cCorpo += "         END;"+CRLF 
cCorpo += CRLF
cCorpo += "         IF ( vnValor = 0 ) THEN " +CRLF    
cCorpo += "            BEGIN"+CRLF 
cCorpo += "      	      SELECT NVL( DTG_VALOR , 0 )"+CRLF 
cCorpo += "                 INTO vnValor"+CRLF
cCorpo += "                 FROM "+RetSqlName("DTG")+" DTG ,"+RetSqlName("DT0")+" DT0 " +CRLF
cCorpo += "                WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
cCorpo += "                  AND DT0_TABFRE = vcDVD_TABFRE "+CRLF
cCorpo += "         	     AND DT0_TIPTAB = vcDVD_TIPTAB "+CRLF
cCorpo += "         	     AND DT0_CDRORI = vcDVD_RGOTAB "+CRLF
cCorpo += "         	     AND DT0_CDRDES = vcDVD_RGDTAB "+CRLF
cCorpo += "         	     AND DT0_CODPRO = vcDVD_PRDTAB "+CRLF
cCorpo += "                  AND DTG_FILIAL = vcFil_DTG "+CRLF	
cCorpo += "                  AND DTG_TABFRE = DT0_TABFRE "+CRLF
cCorpo += "                  AND DTG_TIPTAB = DT0_TIPTAB "+CRLF
cCorpo += "                  AND DTG_TABTAR = DT0_TABTAR "+CRLF
cCorpo += "                  AND DTG_CODPAS = vcDVD_CODPAS "+CRLF
cCorpo += "                  AND DTG_ITEM   = vcDVD_ITEM "+CRLF
cCorpo += "                  AND DT0.D_E_L_E_T_ = ' ' "+CRLF
cCorpo += "                  AND DTG.D_E_L_E_T_ = ' ' ;"+CRLF 
cCorpo += CRLF 
cCorpo += "               EXCEPTION"+CRLF
cCorpo += "                  WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
cCorpo += "            END;"+CRLF 
cCorpo += "         END IF;"+CRLF
cCorpo += CRLF
//cCorpo += "         IF ( vnValor > 0 ) THEN"+CRLF
cCorpo += CRLF
cCorpo += "         vnPercAtu := vnDVD_PERAJU ;"+CRLF 
cCorpo += CRLF 
cCorpo += "         BEGIN"+CRLF
cCorpo += "            SELECT NVL( TRB_PERREA , 0 )"+CRLF
cCorpo += "              INTO vnPerNewAju"+CRLF
cCorpo += "              FROM "+ cTrab +CRLF
cCorpo += "             WHERE TRB_CODPAS = vcDVD_CODPAS ;"+CRLF
cCorpo += CRLF 
cCorpo += "            EXCEPTION"+CRLF
cCorpo += "               WHEN NO_DATA_FOUND THEN NULL ;"+CRLF  
cCorpo += "         END;"+CRLF 
cCorpo +=CRLF
cCorpo += "         IF ( vnPercAtu > 0 ) THEN"+CRLF
cCorpo += "            IF ( vnPerNewAju = 0 ) THEN"+CRLF
cCorpo += "               vnPerNewAju := vnPercAtu ;"+CRLF 
cCorpo += "            ELSE"+CRLF  
cCorpo += "               IF ( vnValor = 0 ) THEN"+CRLF
cCorpo += "                  vnPerNewAju := 0;"+CRLF
cCorpo += "               ELSE"+CRLF    
                              //-- Valor do Ajuste Anterior dado a Tabela
cCorpo += "                  vnValAntAju := vnValor * ( vnPercAtu / 100) ;"+CRLF  			
                              //-- Valor do Novo Ajuste 
cCorpo += "                  vnValNewAju := vnValAntAju + (vnValAntAju * (vnPerNewAju / 100) ) ;"+CRLF
                              //-- Percentual a ser aplicado no valor do componente 
cCorpo += "                  vnPerNewAju := (vnValNewAju / vnValor) * 100 ;"+CRLF     						
cCorpo += "               END IF ;"+CRLF
cCorpo += CRLF
cCorpo += "           END IF ;"+CRLF
cCorpo += "         END IF ;"+CRLF
cCorpo += "         vnGravaAju := vnPerNewAju ;"+CRLF 
cCorpo += "         IF ( vnGravaAju > 0 ) THEN"+CRLF
cCorpo += "            UPDATE " + cTemp + " SET DVD_PERAJU = vnGravaAju"+CRLF 
cCorpo += "            WHERE R_E_C_N_O_ = viRecno ;"+CRLF 
cCorpo += "         END IF ;"+CRLF
cCorpo += "         vnGravaAju := 0 ;"+CRLF 

Return cCorpo

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSGrvDWR ³ Autor ³Eduardo de Souza       ³ Data ³ 09/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera historico do reajuste de clientes                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ TMSGrvDWR()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA700 / TMSA750                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSGrvDWR(cCodCli,cLojCli,cTabFre,cTipTab,cCdrOri,cCdrDes,cSrvDe,cSrvAte,cPrdDe,cPrdAte,cTipFre,lMantem,aCols,cDeNegoc,cAteNegoc)

Local nCnt    := 0
Local cMay    := ""
Local cNumIde := CriaVar("DWR_NUMIDE",.T.)
Default lMantem := .F.
Default cDeNegoc  := ""
Default cAteNegoc := ""

cMay := AllTrim(xFilial('DWR'))+cNumIde
FreeUsedCode()
DWR->(DbSetOrder(3))
While DWR->(MsSeek(xFilial("DWR")+cNumIde)) .Or. !MayIUseCode(cMay)
	ConfirmSx8()
	cNumIde := CriaVar("DWR_NUMIDE",.T.)
	FreeUsedCode()
	cMay := AllTrim(xFilial('DWR'))+cNumIde
EndDo

RecLock("DWR",.T.)
DWR->DWR_FILIAL := xFilial("DWR")
DWR->DWR_NUMIDE := cNumIde
DWR->DWR_CODCLI := cCodCli
DWR->DWR_LOJCLI := cLojCli
DWR->DWR_TABFRE := StrTran(cTabFre,"'","")
DWR->DWR_TIPTAB := StrTran(cTipTab,"'","")
DWR->DWR_CDRORI := cCdrOri
DWR->DWR_CDRDES := cCdrDes
DWR->DWR_SRVDE  := cSrvDe
DWR->DWR_SRVATE := cSrvAte
DWR->DWR_PRDDE  := cPrdDe
DWR->DWR_PRDATE := cPrdAte
DWR->DWR_TIPFRE := cTipFre
DWR->DWR_DATREA := dDataBase
DWR->DWR_HORREA := StrTran(Left(Time(),5),":","")
DWR->DWR_MANTEM := If(lMantem,'1','2')
DWR->DWR_USER   := RetCodUsr()
DWR->DWR_NEGDE  := cDeNegoc
DWR->DWR_NEGATE := cAteNegoc

MsUnlock()

If Left(FunName(),7) <> "TMSA700"
	For nCnt:= 1 To Len(aCols)
		If !GDDeleted(nCnt) .And. ( aCols[nCnt,GDFieldPos("DVE_PERREA")] <> 0 .Or. ;
			aCols[nCnt,GDFieldPos("DVO_PERMIN")] <> 0 .Or. aCols[nCnt,GDFieldPos("DVO_PERAJU")] <> 0 )
			RecLock("DWS",.T.)
			DWS->DWS_FILIAL := xFilial("DWS")
			DWS->DWS_NUMIDE := DWR->DWR_NUMIDE
			DWS->DWS_CODPAS := aCols[nCnt,GDFieldPos("DVE_CODPAS")]
			DWS->DWS_PERREA := aCols[nCnt,GDFieldPos("DVE_PERREA")]
			DWS->DWS_PERMIN := aCols[nCnt,GDFieldPos("DVO_PERMIN")]
			DWS->DWS_PERAJU := aCols[nCnt,GDFieldPos("DVO_PERAJU")]
			MsUnlock()
		EndIf
	Next nCnt
EndIf

If __lSx8
	ConfirmSx8()
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA750GTMP³ Autor ³Wellington A Santos    ³ Data ³ 31/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os arquivos temporarios usados para processamento    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ Tma750GTmp()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA700 / TMSA750                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tma750GTmp(lSubFaixa)
Local aRet      := {}
Local aAlias    := {}
Local cAlias    := ''
Local cTemp
Local nCount
Local nAlias
Aadd(aAlias,"DVO")
Aadd(aAlias,"DVD")
Aadd(aAlias,"DVC")

If lSubFaixa
	Aadd(aAlias,"DW2")
	IF AliasInDic("DY2")
		Aadd(aAlias,"DY2")
	EndIf
EndIf

If AliasInDic("DWZ")
	Aadd(aAlias,"DWZ")
EndIf

If AliasInDic("DJT")
	Aadd(aAlias,"DJT")
EndIf

nAlias := Len(aAlias)
For nCount := 1 To nAlias
	cAlias:= aAlias[nCount]
	cTemp := CriaTrab(Nil,.F.)
	/* Cria tabela Temporária do Alias */
	While TCCanOpen( cTemp ) .And. !TCDelFile( cTemp )
		cTemp := CriaTrab(Nil,.F.)
	EndDo
	Aadd(aRet,{aAlias[nCount],cTemp})
	aEstruExp := (cAlias)->( dbStruct() )

	CriaTmpDb("",cTemp,aEstruExp)
Next nCount
Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA750ATMP³ Autor ³Wellington A Santos    ³ Data ³ 31/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apaga os arquivos temporarios usados para processamento    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ Tma750ATmp()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA700 / TMSA750                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tma750ATmp(aAlias,cTrab,lNovaTab)
Local cTemp
Local nCount
Local cQuery
Local lExecProc  := GetMv("MV_TMSPROC",,.T.)

For nCount := 1 To Len(aAlias)
	cTemp := aAlias[nCount,2]
	TCDelFile( cTemp )
Next nCount
If !lNovaTab
	TCDelFile( cTrab )
EndIf

If ( TcSrvType() <> "AS/400" ) .and. (TcGetDb() == "ORACLE") .and. lExecProc
	cQuery := "Drop Procedure " + cTrab+"_"+cEmpAnt
	TCSqlExec( cQuery )
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA750Tran³ Autor ³Wellington A Santos    ³ Data ³ 31/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava as tabelas temporarias nas tabelas oficiais          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ Tma750Tran()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA700 / TMSA750                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tma750Tran(aAliasTmp,lCalcPrc,lNovaTab,cTipFre,cNewTabela,cNewTipTab,cSeqTab,lTmsa700,cCodCli,cLojCli,cGroup,aMsgErr)
Local cQuery
Local nMax
Local cMax
Local nCount := 0
Local cAlias
Local aEstruExp
Local cMantem
Local nI
Local cJoin
Local cCampFil
Local cCampCli
Local cCampLoj
Local cCampTab
Local cCampTip
Local cCampOri
Local cCampDes
Local cCampPro
Local cCampSer
Local cCampSeq
Local cCampPas
Local cCampIte
Local cCampIteDVD
Local nErrQry
Local lRet := .T.
Local cTemp
Local cTempDvd
Local cTempDvc
Local cQtdTmp   := ''
Local nQtdTmp   := 0
Local cAliasQry := CriaTrab(NIL,.F.)
Local lLock     := .F.
Local aTemp     := {}
Local cAliasNew
Local aMults         
Local aQtdTmp   := {}
Local cQuery1   := ''
Local cQuery2   := ''
Local nPos      := 0
Local aExtrTemp := {}
Local nPosQ     := 0

//renumerar o recno fora de transacao
If "ORACLE" $ Upper(TcGetDb()) 
	For nCount := 1 To Len(aAliasTmp)
		cTemp  := aAliasTmp[nCount,2]
		//-- Renumera o RECNO do temporario
		cQuery := "UPDATE " + cTemp + " SET R_E_C_N_O_ = 1 + ROWNUM "
		nErrQry := TCSqlExec( cQuery )
		If nErrQry <> 0 
			Aadd(aMsgErr,{STR0038 + cTemp + ': ' +AllTrim(Str(nErrQry)) + If(lTMSA700,' Cliente: '+cCodCli+'/'+cLojCli,''),'01',''}) //"Reajuste Tab.Cliente -> Erro no INSERT do "
			lRet := .F.	
		EndIf
	Next nCount
Else
	For nCount := 1 To Len(aAliasTmp)
		cTemp   := aAliasTmp[nCount,2]
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
	Next nCount
EndIf
//caso na geracao de novos contratos a configuracao de tabela de frete esteja diferente entre as tabelas
//transferidas e possivel que o processamento tenha levado apenas um registro do dvc por nao ter encontrado
//configuracao de componentes de frete semelhante na tabela de destino, por isso, limpamos todos os registros do dvc sem dvd

cTempDvd := aAliasTmp[ aScan( aAliasTmp, {|ExpA1| RTrim( ExpA1[1] ) == "DVD" }) , 2 ]
cTempDvc := aAliasTmp[ aScan( aAliasTmp, {|ExpA1| RTrim( ExpA1[1] ) == "DVC" }) , 2 ]
cQuery := " UPDATE " + cTempDvc + " SET D_E_L_E_T_ = '*' "
cQuery += " WHERE NOT EXISTS( SELECT 1 FROM " + cTempDvd + " DVD "
cQuery += " 						WHERE DVD_FILIAL = DVC_FILIAL "
cQuery += "                   AND DVD_TABFRE = DVC_TABFRE "
cQuery += "                   AND DVD_TIPTAB = DVC_TIPTAB "
cQuery += "                   AND DVD_CDRORI = DVC_CDRORI "
cQuery += "                   AND DVD_CDRDES = DVC_CDRDES "
cQuery += "                   AND DVD_CODPRO = DVC_CODPRO "
cQuery += "                   AND DVD_CODNEG = DVC_CODNEG "
cQuery += "                   AND DVD_SERVIC = DVC_SERVIC "
cQuery += "                   AND DVD_SEQTAB = DVC_SEQTAB "
cQuery += "                   AND DVD.D_E_L_E_T_ = ' ' )"
cQuery += " AND D_E_L_E_T_ = ' ' "
nErrQry := TCSqlExec( cQuery )
If nErrQry <> 0 
	Aadd(aMsgErr,{STR0038 + cTempDvc + ': ' +AllTrim(Str(nErrQry)) + If(lTMSA700,' Cliente: '+cCodCli+'/'+cLojCli,''),'01',''}) //"Reajuste Tab.Cliente -> Erro no INSERT do "
	lRet := .F.	
EndIf
DbSelectArea("DVC")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ja' existe algum usuario executando esta rotina                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lLock := MultLock("DVC",{"GERAJU"},1)

If !lLock
	lRet := .F.
Else

	For nCount := 1 To Len(aAliasTmp)
		cAlias   := aAliasTmp[nCount,1]
		cTemp    := aAliasTmp[nCount,2]
		
		cCampCli := cAlias+"_CODCLI"
		cCampLoj := cAlias+"_LOJCLI"
		
		//-- Descobre o registro maximo da tabela
		cMax   := CriaTrab(NIL,.F.)
		cQuery := "SELECT MAX(R_E_C_N_O_) MAX_RECNO FROM " + RetSqlName( cAlias )
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cMax, .F., .T.)
		nMax   := Iif((cMax)->( Eof() ), 0, (cMax)->MAX_RECNO )
		(cMax)->( dbCloseArea() )
		
		//-- Descobre a quantidade do temporario
		cQtdTmp:= CriaTrab(NIL,.F.)
		cQuery := "SELECT COUNT(*) QTD_TMP FROM " + cTemp
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQtdTmp, .F., .T.)
		nQtdTmp:= Iif((cQtdTmp)->( Eof() ), 0, (cQtdTmp)->QTD_TMP )
		(cQtdTmp)->( dbCloseArea() )

		If nQtdTmp > 0
			//-- Prepara o ultimo registro para nao perder o insert que esta deletado na tabela
			cQuery := "UPDATE " + cTemp + " SET D_E_L_E_T_ = '*' WHERE R_E_C_N_O_ = "+Alltrim(Str(nQtdTmp + 1))
			TCSqlExec( cQuery )
			TCRefresh(cTemp)

			nQtdTmp += nMax + 1
			
			//-- Inclui UM Registro em branco + a quantidade de registros do temporario.
			cQuery :="INSERT INTO "+RetSqlName( cAlias )+" (R_E_C_N_O_, D_E_L_E_T_ ) "
			cQuery +=" VALUES ("+Alltrim(Str(nQtdTmp))+", '*') "
			nErrQry := TCSqlExec( cQuery )
			If nErrQry <> 0
				Aadd(aMsgErr,{STR0026 + cAlias + ': ' +AllTrim(Str(nErrQry)) + If(lTMSA700,' Cliente: '+&cCampCli+'/'+&cCampLoj,''),'01',''}) //"Reajuste Tab.Cliente -> Erro no INSERT do "
				lRet := .F.
			EndIf
			
			If !lRet
				Exit
			EndIf
			Aadd(aQtdTmp,{cAlias,nMax,nQtdTmp})
			
			TCRefresh(cAlias)
			
		EndIf

	Next nCount

	MsUnlockAll()

	For nCount := 1 To Len(aAliasTmp)	
		cAlias   := aAliasTmp[nCount,1]
		cTemp    := aAliasTmp[nCount,2]

		cCampCli := cAlias+"_CODCLI"
		cCampLoj := cAlias+"_LOJCLI"

		If cAlias == "DVC" .AND. !lNovaTab
			aMults :={}
			cQtdTmp:= CriaTrab(NIL,.F.)
			cQuery := "SELECT DISTINCT "+cCampCli+"||"+cCampLoj+" CHAVE FROM " + cTemp
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQtdTmp, .F., .T.)
			While (cQtdTmp)->( !Eof() )
				aAdd(aMults,"INC_AJU"+(cQtdTmp)->CHAVE)
				(cQtdTmp)->( dbSkip() )
			EndDo
			(cQtdTmp)->( dbCloseArea() )
			
			lRet := MultLock("DVC",aMults,1)
			If !lRet
				//se o top teve problemas para gravar alguma tabela desfaz transacao
				Aadd(aMsgErr,{STR0026 + cAlias + ': ' +AllTrim(Str(nErrQry)) + If(lTMSA700,' Cliente: '+&cCampCli+'/'+&cCampLoj,''),'01',''}) //"Reajuste Tab.Cliente -> Erro no INSERT do "
				Exit
			EndIf
		EndIf
	Next nCount

EndIf
	
If lRet
	
	Begin Transaction
	
	For nCount := 1 To Len(aAliasTmp)
		cAlias      := aAliasTmp[nCount,1]
		cTemp       := aAliasTmp[nCount,2]
		
		cCampFil    := cAlias+"_FILIAL"
		cCampCli    := cAlias+"_CODCLI"
		cCampLoj    := cAlias+"_LOJCLI"
		cCampTab    := cAlias+"_TABFRE"
		cCampTip    := cAlias+"_TIPTAB"
		cCampOri    := cAlias+"_CDRORI"
		cCampDes    := cAlias+"_CDRDES"
		cCampPro    := cAlias+"_CODPRO"
		cCampSer    := cAlias+"_SERVIC"
		cCampSeq    := cAlias+"_SEQTAB"
		cCampPas    := cAlias+"_CODPAS"
		cCampIte    := cAlias+"_ITEM"
		cCampIteDVD := cAlias+"_ITEDVD"
		cCampNeg    := cAlias+"_CODNEG"
		
		If (nPosQ := Ascan(aQtdTmp,{|x| x[1] == cAlias })) > 0
			nMax := aQtdTmp[nPosQ,2]
		Else
			//-- Descobre o registro maximo da tabela
			cMax   := CriaTrab(NIL,.F.)
			cQuery := "SELECT MAX(R_E_C_N_O_) MAX_RECNO FROM " + RetSqlName( cAlias )
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cMax, .F., .T.)
			nMax   := Iif((cMax)->( Eof() ), 0, (cMax)->MAX_RECNO )
			(cMax)->( dbCloseArea() )
		EndIf
		
		aEstruExp := (cAlias)->( dbStruct() )
		
		cQuery1 := "INSERT INTO " + RetSqlName( cAlias ) + " ( "
		
		For nI := 1 To Len( aEstruExp )
			cQuery1 += aEstruExp[ nI, 1 ] + ", "
		Next
		
		cQuery1 += "R_E_C_N_O_) "
		
		cQuery :=" SELECT DISTINCT "
		
		//Temp e o alias da tabela temporaria
		If lCalcPrc
			If cAlias == "DVD"
				cMantem := "DVD_PERAJU"
			ElseIf cAlias == "DVO"
				cMantem := "DVO_PERMIN,DVO_PERAJU"
			ElseIf cAlias == "DW2"
				cMantem := "DW2_PERAJU"
			EndIf
		EndIf
		For nI := 1 To Len(aEstruExp)
			If nI > 1
				cQuery += ", "
			EndIf
			If aEstruExp [ nI , 1 ] $ cGroup //aqui comeca a selecao da origem do dado, se vai ser gravado o que esta
				cJoin  := "Temp"              // na tabela temporaria ou o que esta na tabela original
			Else
				If lCalcPrc .And. aEstruExp [ nI , 1 ] $ cMantem
					//De acorco com o mantem preco ou nao utiliza-se pra gravar no valor da tabela temporaria
					cJoin := "Temp"
				Else
					cJoin  := cAlias
				EndIf
			EndIf
			If lNovaTab .And. aEstruExp [ nI , 1 ] == cCampTab //caso seja tabela nova gravar a tabela nova
				cQuery += "'" + cNewTabela + "'"
			ElseIf lNovaTab .And. aEstruExp [ nI , 1 ] == cCampTip//caso seja tabela nova gravar o tipo da tabela nova
				cQuery += "'" + cNewTipTab + "'"
			ElseIf aEstruExp [ nI , 1 ] == cCampSeq//utiliza a nova sequencia para gravar
				cQuery += "'" + cSeqTab + "'"
			Else
				cQuery += cJoin + "." + aEstruExp [ nI , 1 ]
			EndIf
		Next nI
		cQuery += ", (Temp.R_E_C_N_O_ + " + Str( nMax ) +") TMPRECNO "
		
		cQuery  +=" FROM " + cTemp + " Temp JOIN " + RetSqlName(cAlias) + " " + cAlias + " ON "
		
		cQuery += cAlias + "." + cCampFil + " = Temp." + cCampFil + " AND " //filial
		cQuery += cAlias + "." + cCampCli + " = Temp." + cCampCli + " AND " //cliente
		cQuery += cAlias + "." + cCampLoj + " = Temp." + cCampLoj + " AND " //loja
		cQuery += cAlias + "." + cCampTab + " = Temp." + cCampTab + " AND " //Tabela
		cQuery += cAlias + "." + cCampTip + " = Temp." + cCampTip + " AND " //Tipo da tabela
		cQuery += cAlias + "." + cCampSeq + " = Temp." + cCampSeq + " AND " // Sequencia
		cQuery += cAlias + "." + cCampOri + " = Temp." + cCampOri + " AND " //Origem
		cQuery += cAlias + "." + cCampDes + " = Temp." + cCampDes + " AND "	//Destino
		cQuery += cAlias + "." + cCampPro + " = Temp." + cCampPro + " AND "	//produto
		cQuery += cAlias + "." + cCampNeg + " = Temp." + cCampNeg + " AND "	//negociacao
		cQuery += cAlias + "." + cCampSer + " = Temp." + cCampSer           //servico
		If cAlias == "DVD"
			cQuery += " AND " + cAlias + "." + cCampPas + " = Temp." + cCampPas + " AND "	//codigo do componente
			cQuery += cAlias + "." + cCampIte + " = Temp." + cCampIte 	//numero do item
		ElseIf cAlias == "DVO"
			cQuery += " AND " + cAlias + "." + cCampPas + " = Temp." + cCampPas //codigo do componente
		ElseIf cAlias == "DW2"
			cQuery += " AND " + cAlias + "." + cCampPas + " = Temp." + cCampPas + " AND "	//codigo do componente
			cQuery += cAlias + "." + cCampIteDVD + " = Temp." + cCampIteDVD + " AND " 	//numero do item do ajuste
			cQuery += cAlias + "." + cCampIte + " = Temp." + cCampIte 	//numero do item
		EndIf
		cQuery += " WHERE Temp.D_E_L_E_T_ = ' ' "
		cQuery += " AND " + cAlias + "." + "D_E_L_E_T_ = ' ' "
		
		If !lNovaTab
			cQuery += "   AND EXISTS ( "
			cQuery += "  SELECT AAM_FILIAL,AAM_CODCLI FROM "
			cQuery += "  "+RetSqlName('AAM') + " AAM "
			cQuery += "  WHERE AAM.AAM_FILIAL = '"+xFilial("AAM")+"'"
			cQuery += "   AND AAM.AAM_CODCLI  =  Temp"+"."+cAlias+"_CODCLI"
			cQuery += "   AND AAM.AAM_LOJA    =  Temp"+"."+cAlias+"_LOJCLI"
			cQuery += "   AND AAM.AAM_STATUS  = '"+StrZero(1, Len(AAM->AAM_STATUS))+"'"
			cQuery += "   AND ((AAM.AAM_INIVIG <= '"+DTOS(dDataBase)+"'"
			cQuery += "   AND AAM.AAM_FIMVIG >= '"+DTOS(dDataBase) +"') OR AAM.AAM_FIMVIG = ' ')"
			If cTipFre <> "4"
				cQuery += "   AND AAM.AAM_TIPFRE  = '"+cTipFre+"'"
			EndIf	
			cQuery += "   AND AAM.D_E_L_E_T_  = ' ' )"
		EndIf
		
		aTemp   :={}
		If (nPosQ := Ascan(aQtdTmp,{|x| x[1] == cAlias })) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Recupera o ultimo registro para nao perder o insert EM BRANCO que esta deletado na tabela ³
			//³Rodando a mesma query sem o Insert into buscando apenas o DELETADO                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQtdTmp := CriaTrab(NIL,.F.)
			cQuery2 := STUFF(cQuery,AT("Temp.D_E_L_E_T_ = ' '",cQuery),Len("Temp.D_E_L_E_T_ = ' '"),"Temp.D_E_L_E_T_ = '*'")
			cQuery2 := ChangeQuery(cQuery2)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery2), cQtdTmp, .F., .T.)
			While (cQtdTmp)->( !Eof() )
				If (cQtdTmp)->TMPRECNO == aQtdTmp[nPosQ,3]  //-- ultimo registro
				   aExtrTemp := (cQtdTmp)->( dbStruct() )
					For nI := 1 To Len(aEstruExp)
						If lNovaTab .And. aEstruExp [ nI ,1 ] == cCampTab //caso seja tabela nova gravar a tabela nova
					 		AAdd(aTemp,{aEstruExp[nI ,1],cNewTabela})
						ElseIf lNovaTab .And. aEstruExp [ nI ,1 ] == cCampTip//caso seja tabela nova gravar o tipo da tabela nova
							AAdd(aTemp,{aEstruExp[nI ,1],cNewTipTab})
						ElseIf aEstruExp[nI,1] == cCampSeq
							AAdd(aTemp,{aEstruExp[ nI ,1],cSeqTab})						
						Else
							nPos := Ascan(aExtrTemp,{|x| x[1] == aEstruExp[ nI ,1]})
							If nPos != 0
								AAdd(aTemp,{aEstruExp[ nI ,1],(cQtdTmp)->(FieldGet(nPos))})
							EndIf
						EndIf
					Next
				EndIf
				(cQtdTmp)->( dbSkip() )
			EndDo
			(cQtdTmp)->( dbCloseArea() )
		EndIf
		
		cQuery1 += cQuery
		nErrQry := TCSqlExec( (cQuery1) )
		If nErrQry <> 0
			Aadd(aMsgErr,{STR0026 + cAlias + ': ' +AllTrim(Str(nErrQry)) + If(lTMSA700,' Cliente: '+cCodCli+'/'+cLojCli,''),'01',''}) //"Reajuste Tab.Cliente -> Erro no INSERT do "
			lRet := .F.
		EndIf
		
		If !lRet
			//se o top teve problemas para gravar alguma tabela desfaz transacao
			DisarmTransaction()
			Exit
		EndIf
		
		//-- Atualiza no TOP o ultimo R_E_C_N_O_ da tabela
		TCRefresh(RetFileName(cAlias))
		
		//-- Recupera o ultimo registro para nao perder o insert EM BRANCO que esta deletado na tabela
		If (nPosQ := Ascan(aQtdTmp,{|x| x[1] == cAlias })) > 0 .And. Len(aTemp) > 0
			DbSelectArea(cAlias)
			DbGoto(aQtdTmp[nPosQ,3])
			RecLock(cAlias,.F.)
			DBRECALL()
			For nI := 1 TO Len(aTemp)
				nPos := Ascan(aTemp,{|x| x[1]==FieldName(nI) }) 
				If nPos != 0
					FieldPut(nI,aTemp[nPos,2])
				EndIf
			Next nI
			MsUnlock()
		EndIf
		
	Next nCount
	//se der erro em alguma das tabelas por algum erro de top nao faz nada
	
	DbSelectArea("DVC")
	End Transaction

EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³    6 - Confirma Reajuste dos Precos                        ³±±
±±³          ³    7 - Exibe estrutura com os Reajustes pendentes          ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Private aRotina   := {	{STR0002 ,"TMSXPesqui"		,0,1,0,.F.} ,;//"Pesquisar"
						{STR0003 ,"TMSA011Mnt"		,0,2,0,NIL} ,;//"Visualizar"
						{STR0004 ,"TMSA750Man"		,0,3,0,NIL} ,;//"Incluir"
						{STR0005 ,"TMSA750Man"		,0,5,0,NIL} ,;//"Excluir"
						{STR0006 ,"TMSA750Man"		,0,6,0,NIL} ,;//"Confirmar"
						{STR0007 ,"TMSA011Est(.T.)" ,0,4,0,NIL}  }//"Estrutura"


If ExistBlock("TMA750MNU")
	ExecBlock("TMA750MNU",.F.,.F.)
EndIf

Return(aRotina)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMSAjuDB2 º Autor ³ Andre Sperandio 	 º Data ³  17/09/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cria ajuste com INSERT INTO com Procedure                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Alias                                              º±±
±±º          ³ ExpC2 - Query                                              º±±
±±º          ³ ExpC3 - Tipo de Frete  (CIF/FOB/CIF-FOB)                   º±±
±±º          ³ ExpC4 - Clientes preservados                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ NIL                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA750                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAjuDB2(cAlias, cQueryAux, cTipFre, cFilCli, cNewTabela, cNewTipTab, lMantemPrc, cSeqTab, cGroup ,cTemp, cCliAtu, cLojAtu)

Local   lRet        := .T.
Local   lNovaTab    := (!Empty(cNewTabela) .And. !Empty(cNewTipTab))
Local   lCalcPrc    := .T.
Local   cCampFil    := cAlias+"_FILIAL"
Local   cCampCli    := cAlias+"_CODCLI"
Local   cCampLoj    := cAlias+"_LOJCLI"
Local   cCampTab    := cAlias+"_TABFRE"
Local   cCampTip    := cAlias+"_TIPTAB"
Local   cCampOri    := cAlias+"_CDRORI"
Local   cCampDes    := cAlias+"_CDRDES"
Local   cCampPro    := cAlias+"_CODPRO"
Local   cCampSer    := cAlias+"_SERVIC"
Local   cCampSeq    := cAlias+"_SEQTAB"
Local   cCampPas    := cAlias+"_CODPAS"
Local   cCampIte    := cAlias+"_ITEM"
Local   cCampIteDVD := cAlias+"_ITEDVD"
Local   cCampNeg    := ""
Local   cMantem     := ""
Local   cInsert     := ""
Local   cDeclare    := ""
Local   cCorpoIni   := ""
Local   cCorpoDVC   := ""
Local   cCorpoDVD   := ""
Local   cCorpoDVO   := ""
Local   cCorpoDVO1  := ""
Local   cCorpoDVO2  := ""
Local   cCorpoDW2   := ""
Local   cCorpoDW21  := ""
Local   cCorpoDW22  := ""
Local   cCorpoFim   := ""  
Local   cProc01     := ""
Local   cProc02     := ""
Local   cProcedure  := ""  
Local   cProcFim    := "" 
Local   cFetch      := "" 
Local   cFilCliPrc  := ""
Local   nPos01, nPos02, nPos03, nPos04, nPos05
Local   cSelVer1    := ""
Local   cSelVer2    := ""
Local   nTmsProc    := 0
Local   nXFilProc   := 0
Local   aResult     := {}
Local   i, nC, nI
Local   lExecProc   := .F.
Local   aMsgErr     := {}

//novas
Local   aTmpCampos  := {} 
Default cTipFre     := "1"
Default cFilCli     := ""

cCampNeg := cAlias+"_CODNEG"

If !lNovaTab

	/* Cria Tabela e Indice Temporário para armazenar aCols - Itens */
	If TcCanOpen(cTrab)
		TcDelFile(cTrab)
	Endif

	aTmpCampos:= GetStruProc()
	CriaTmpDb("",cTrab,aTmpCampos) 
	TcSqlExec("Create index "+cTrab+"+IDX on  "+cTrab+" ( TRB_CODPAS )") 

	nPos01  := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVE_CODPAS"} )
	nPos02  := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVE_DESPAS"} )
	nPos03  := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVE_PERREA"} )
	nPos04  := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVO_PERMIN"} )
	nPos05  := aScan( aHeader,{|ExpA1| ExpA1[2] == "DVO_PERAJU"} )

	For i:= 1 to len(aCols)

		cInsert := "INSERT INTO "+cTrab+" (TRB_CODPAS,TRB_DESPAS,TRB_PERREA,TRB_PERMIN,TRB_PERAJU, R_E_C_N_O_) "
		cInsert += "values ('"+alltrim(aCols[i][nPos01])+"','"+alltrim(aCols[i][nPos02])+"',"+alltrim(str(aCols[i][nPos03]))
		cInsert += ","+alltrim(str(aCols[i][nPos04]))+","+alltrim(str(aCols[i][nPos05]))+","+alltrim(str(i))+")"
		TcSqlExec(cInsert) 

	Next

EndIf

aEstruExp := (cAlias)->( dbStruct() )
/*Inicio do Codigo da Procedure */
cCreate := ""
cCreate := "create or replace procedure "+cTrab+"_"+cEmpAnt+" ("+CRLF
cCreate += "   IN_FILIALCOR    in  CHAR,"+CRLF
cCreate += "   IN_NEWTABELA    in  CHAR,"+CRLF		//cNewTabela
cCreate += "   IN_NEWTIPTAB    in  CHAR,"+CRLF		//cNewTipTab
cCreate += "   IN_DATABASE     in  CHAR,"+CRLF		//Dtos(dDatabase)
cCreate += "   IN_TIPFRE       in  CHAR,"+CRLF 		//cTipFre
cCreate += "   OUT_RESULTADO   out CHAR ) IS"+CRLF 
cCreate += CRLF
cCreate += " -- Declaracoes de Variaveis"+CRLF

cDeclare := ""
cDeclare := "   vcAux            Char(03) "+CRLF
If (cAlias == "DVD")
	cDeclare += "   vcFil_DT0        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) "+CRLF
	cDeclare += "   vcFil_DT1        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) "+CRLF
	cDeclare += "   vcFil_DTG        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) "+CRLF
EndIf
If (cAlias == "DVO")
	cDeclare += "   vcFil_DTK        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) "+CRLF
	cDeclare += "   vcFil_DVD        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) "+CRLF
	aTam     :=TamSX3("DVD_RGOTAB")
	cDeclare += "   vcRgOtab         Char( "+alltrim(str(aTam[1]))+" ) "+CRLF
	aTam     :=TamSX3("DVD_RGDTAB")
	cDeclare += "   vcRgDtab         Char( "+alltrim(str(aTam[1]))+" ) "+CRLF
EndIf
If (cAlias == "DW2")
	cDeclare += "   vcFil_DW0        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) "+CRLF
	cDeclare += "   vcFil_DW1        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) "+CRLF
	cDeclare += "   vcFil_DT0        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) "+CRLF
EndIf
cDeclare += "   vcFil_AAM        Char( "+alltrim(str(FWGETTAMFILIAL))+" ) "+CRLF
cDeclare += "   viRecno          Integer "+CRLF 
cDeclare += "   viMaxRecno       Integer "+CRLF 

aTam     :=TamSX3("DVC_CODCLI")
cDeclare += "   vcCliente        Char( "+alltrim(str(aTam[1]))+" )"+CRLF
aTam     :=TamSX3("DVC_LOJCLI")
cDeclare += "   vcLoja           Char( "+alltrim(str(aTam[1]))+" )"+CRLF
cDeclare += "   vcConcat         Varchar( 200 ) "+CRLF

/* Verifica qual o maior campo @nValor */
If (cAlias == "DW2")
	cCmpValor := "DW1_VALOR DW0_VALOR DW2_PERAJU"
ElseIf (cAlias == "DVO")
	cCmpValor := "DTK_VALMIN DTK_VALOR DVO_PERMIN" 
ElseIf (cAlias == "DVD")
	cCmpValor := "DT1_VALOR DTG_VALOR DVD_PERAJU"+CRLF
EndIf

If (cAlias == "DW2") .or. (cAlias == "DVO") .or. (cAlias == "DVD")
	cCampo   := MaiorCampo(cCmpValor)
	aTam     := TamSX3(cCampo)
	cDeclare += "   vnGravaAju       Float "+CRLF
	cDeclare += "   vnValor          Float "+CRLF
	cDeclare += "   vnValTabAnt      Float "+CRLF
	cDeclare += "   vnPerNewAju      Float "+CRLF

	If (cAlias == "DVO") .or. (cAlias == "DVD")
		cDeclare += "   vnPerNewMin      Float "+CRLF 
	EndIf 
	If (cAlias == "DVO")
		cDeclare += "   vnPerNewExc      Float "+CRLF 
	EndIf
EndIf

/* Verifica qual o campo @nValorTabNova */
If (cAlias == "DW2")
	cDeclare += "   vnValTabNova     Float "+CRLF
ElseIf (cAlias == "DVD")
	cDeclare += "   vnValTabNova     Float "+CRLF
EndIf

If (cAlias == "DVO")
	cDeclare += "   vnValMin         Float "+CRLF
	cDeclare += "   vnMinNov         Float "+CRLF
	cDeclare += "   vnValExc         Float "+CRLF
	cDeclare += "   vnExcNov         Float "+CRLF
	cDeclare += "   vnExcMin         Float "+CRLF
EndIf

If (cAlias == "DVO")
	cDeclare += "   vnPercAtu        Float "+CRLF
	cDeclare += "   vnValNewAju      Float "+CRLF
	cDeclare += "   vnValAntAju      Float "+CRLF
ElseIf (cAlias == "DW2")
	cDeclare += "   vnPercAtu        Float "+CRLF
	cDeclare += "   vnValNewAju      Float "+CRLF
	cDeclare += "   vnValAntAju      Float "+CRLF
ElseIf (cAlias == "DVD")
	cDeclare += "   vnPercAtu        Float "+CRLF
	cDeclare += "   vnValNewAju      Float "+CRLF
	cDeclare += "   vnValAntAju      Float "+CRLF
EndIf

//Monta Declaração do Cursor
For nC := 1 to len(aEstruExp)
	If Trim(aEstruExp[nC][1]) == cAlias+"_FILIAL" .or. Trim(aEstruExp[nC][1]) == "D_E_L_E_T_" .or. Trim(aEstruExp[nC][1]) == "R_E_C_N_O_" 
		loop
	EndIf
	If aEstruExp[nC][2] = "C" .or. aEstruExp[nC][2] = "D"
		cDeclare += "   vc"+Trim(aEstruExp[nC][1])+ "  Char( "+alltrim(str(aEstruExp[nC][3]))+" ) "+CRLF
	ElseIf aEstruExp[nC][2] = "N"
		If aEstruExp[nC][4] = 0
			cDeclare += "   vi"+Trim(aEstruExp[nC][1])+"   Integer "+CRLF 
		Else
			cDeclare += "   vn"+Trim(aEstruExp[nC][1])+"   Decimal( "+alltrim(str(aEstruExp[nC][3]))
			cDeclare += ","+alltrim(str(aEstruExp[nC][4]))+" ) "+CRLF
		EndIf
	EndIf
Next nC

If lNovaTab .And. !lMantemPrc
	lCalcPrc := .F.
EndIf

If lCalcPrc

	cCorpoIni := ""
	cCorpoIni += "   CURSOR CUR001 IS"+CRLF
	cCorpoIni += "   select "
	For nI := 1 To Len(aEstruExp)
	
		If Trim(aEstruExp[nI][1]) == cAlias+"_FILIAL" 
			loop
		EndIf
		If aEstruExp [ nI , 1 ] $ cGroup
			cJoin  := "TMP"
		Else
			cJoin  := cAlias
		EndIf
		cCorpoIni += cJoin + "." + aEstruExp [ nI , 1 ] + ","
	Next nI 
	
	cCorpoIni += "TMP" + ".R_E_C_N_O_"+CRLF	 
	
	/* Verificar como Montar o select que pode ser com o Alias ou Temp*/
	
	
	cCorpoIni += "    from " +cTemp+ " TMP, " +RetSqlName(cAlias)+ " " + cAlias +CRLF
	cCorpoIni += "   where " + cAlias + "." + cCampFil + " = TMP." + cCampFil +CRLF //filial 
	cCorpoIni += "     and " + cAlias + "." + cCampCli + " = TMP." + cCampCli +CRLF //cliente
	cCorpoIni += "     and " + cAlias + "." + cCampLoj + " = TMP." + cCampLoj +CRLF //loja
	cCorpoIni += "     and " + cAlias + "." + cCampTab + " = TMP." + cCampTab +CRLF //Tabela
	cCorpoIni += "     and " + cAlias + "." + cCampTip + " = TMP." + cCampTip +CRLF //Tipo da tabela
	cCorpoIni += "     and " + cAlias + "." + cCampSeq + " = TMP." + cCampSeq +CRLF // Sequencia
	cCorpoIni += "     and " + cAlias + "." + cCampOri + " = TMP." + cCampOri +CRLF //Origem
	cCorpoIni += "     and " + cAlias + "." + cCampDes + " = TMP." + cCampDes +CRLF //Destino
	cCorpoIni += "     and " + cAlias + "." + cCampPro + " = TMP." + cCampPro +CRLF //produto
	cCorpoIni += "     and " + cAlias + "." + cCampNeg + " = TMP." + cCampNeg +CRLF //negociacao
	cCorpoIni += "     and " + cAlias + "." + cCampSer + " = TMP." + cCampSer +CRLF //servico
	cCorpoIni += "     and " + cAlias + "." + "D_E_L_E_T_ = ' ' " 

	If cAlias == "DVD"
		cCorpoIni += CRLF + "      and " + cAlias + "." + cCampPas + " = TMP." + cCampPas  		//codigo do componente
		cCorpoIni += CRLF + "      and " + cAlias + "." + cCampIte + " = TMP." + cCampIte			//numero do item
	ElseIf cAlias == "DVO"
		cCorpoIni += CRLF + "      and " + cAlias + "." + cCampPas + " = TMP." + cCampPas			//codigo do componente
	ElseIf cAlias == "DW2"
		cCorpoIni += CRLF + "      and " + cAlias + "." + cCampPas + " = TMP." + cCampPas	 		//codigo do componente
		cCorpoIni += CRLF + "      and " + cAlias + "." + cCampIteDVD + " = TMP." + cCampIteDVD	//numero do item do ajuste
		cCorpoIni += CRLF + "      and " + cAlias + "." + cCampIte + " = TMP." + cCampIte		 	//numero do item
	EndIf
		
	If !lNovaTab
		cCorpoIni += CRLF
		cCorpoIni += "    and exists ( "  +CRLF
		cCorpoIni += "          select AAM_FILIAL,AAM_CODCLI "  +CRLF
		cCorpoIni += "            from "+RetSqlName('AAM') + " AAM "  +CRLF
		cCorpoIni += "           where AAM.AAM_FILIAL  = vcFil_AAM" +CRLF
		cCorpoIni += "						 and AAM.AAM_CODCLI  =  TMP"+"."+cCampCli  +CRLF
		cCorpoIni += "						 and AAM.AAM_LOJA    =  TMP"+"."+cCampLoj  +CRLF
		cCorpoIni += "		         and AAM.AAM_STATUS  = '1'"  +CRLF		
		cCorpoIni += "						 and ((AAM.AAM_INIVIG <= IN_DATABASE"  +CRLF
		cCorpoIni += " 						 and AAM.AAM_FIMVIG >= IN_DATABASE) or AAM.AAM_FIMVIG = ' ')"  +CRLF
		If cTipFre <> "4" 
			cCorpoIni += "					 and AAM.AAM_TIPFRE  = IN_TIPFRE"  +CRLF
		EndIf	
		cCorpoIni += " 	           and AAM.D_E_L_E_T_  = ' ' )"  +CRLF
		cCorpoIni += "						 and TMP.D_E_L_E_T_  = ' ' "
	EndIf
	cCorpoIni += CRLF
	cCorpoIni += CRLF

EndIf //If lCalcPrc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta corpo da procedure                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCorpoIni +="BEGIN"+CRLF

cCorpoIni +="   OUT_RESULTADO := '0' " +CRLF

If (cAlias == "DVD")
	cCorpoIni +="   vcAux := 'DT0' "+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_DT0) " +CRLF
	cCorpoIni +="   vcAux := 'DT1' "+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_DT1) " +CRLF
	cCorpoIni +="   vcAux := 'DTG' "+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_DTG) " +CRLF 
EndIf

If (cAlias == "DVO")
	cCorpoIni +="   vcAux := 'DTK' "+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_DTK) " +CRLF
	cCorpoIni +="   vcAux := 'DVD' "+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_DVD) " +CRLF
EndIf

If (cAlias == "DW2")
	cCorpoIni +="   vcAux := 'DW0' "+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_DW0) " +CRLF
	cCorpoIni +="   vcAux := 'DW1' "+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_DW1) " +CRLF
	cCorpoIni +="   vcAux := 'DT0' "+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_DT0) " +CRLF
EndIf

If !lNovaTab
	cCorpoIni +="   vcAux := 'AAM' "+CRLF
	cCorpoIni +="   XFILIAL_"+cEmpAnt+" (vcAux, IN_FILIALCOR, vcFil_AAM) " +CRLF
Endif


cCorpoIni +=CRLF
cCorpoIni +="   INSERT INTO " +cTemp+ " ( "

For nI := 1 To Len( aEstruExp )
	cCorpoIni += aEstruExp[ nI, 1 ] + ", "
Next

cCorpoIni += "   R_E_C_N_O_, D_E_L_E_T_ ) " + cQueryAux + CRLF  
cCorpoIni += "   commit"+CRLF 
cCorpoIni += CRLF

If lCalcPrc
	cCorpoIni += CRLF
	cCorpoIni += "   OPEN CUR001"+CRLF
	cCorpoIni += CRLF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta as variaveis do fetch                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nC := 1 to len(aEstruExp)   //colocar tratamento para recno e delete 
		If Trim(aEstruExp[nC][1]) == cAlias+"_FILIAL"
			loop
		EndIf
		If aEstruExp[nC][2] = "C" .or. aEstruExp[nC][2] = "D"
			cFetch += " vc"+Trim(aEstruExp[nC][1])+","
		ElseIf aEstruExp[nC][2] = "N"
			If aEstruExp[nC][4] = 0
				cFetch += " vi"+Trim(aEstruExp[nC][1])+","
			Else
			cFetch += " vn"+Trim(aEstruExp[nC][1])+","
			EndIf
		EndIf
	Next nC

	cCorpoIni += "   FETCH CUR001"+CRLF
	cCorpoIni += "    INTO " +cFetch +" viRecno " +CRLF

	cCorpoIni += CRLF
	cCorpoIni += "   WHILE ( (CUR001%FOUND) ) LOOP " +CRLF
	If cAlias == "DVC"
		cCorpoDVC :=""
		If !Empty(cFilCli)
			cCorpoDVC += "      vcCliente := vcDVC_CODCLI " +CRLF
			cCorpoDVC += "      vcLoja := vcDVC_LOJCLI " +CRLF
			cCorpoDVC +=CRLF
		EndIf
	ElseIf cAlias == "DVD"
		cCorpoDVD := ""
		cCorpoDVD += "      vcCliente := vcDVD_CODCLI " +CRLF
		cCorpoDVD += "      vcLoja := vcDVD_LOJCLI " +CRLF
		cCorpoDVD +=CRLF
		If lNovaTab
			cCorpoDVD += TMSA750O1(cTemp)
		Else
			cCorpoDVD += TMSA750O2(cTemp,cTrab)
		EndIf

	ElseIf cAlias == "DVO"
		cCorpoDVO := ""
		cCorpoDVO += "      vcCliente := vcDVO_CODCLI " +CRLF
		cCorpoDVO += "      vcLoja := vcDVO_LOJCLI " +CRLF
		cCorpoDVO +=CRLF
		cCorpoDVO1 := ""
		cCorpoDVO2 := ""
		If lNovaTab
			cCorpoDVO1 += "         vnValMin := null "+CRLF
			cCorpoDVO1 += "         vnValExc := null "+CRLF
			cCorpoDVO1 += "         vnExcMin := null "+CRLF
			cCorpoDVO1 +=CRLF
			cCorpoDVO1 += "         BEGIN"+CRLF
			cCorpoDVO1 += "            SELECT DTK_VALMIN, DTK_VALOR, DTK_EXCMIN "+CRLF
			cCorpoDVO1 += "              INTO vnValMin , vnValExc, vnExcMin "+CRLF   
			cCorpoDVO1 += "              FROM "+RetSqlName("DTK")+CRLF     
			cCorpoDVO1 += "             WHERE DTK_FILIAL = vcFil_DTK"+CRLF 
			cCorpoDVO1 += "               AND DTK_TABFRE = vcDVO_TABFRE "+CRLF 
			cCorpoDVO1 += "               AND DTK_TIPTAB = vcDVO_TIPTAB "+CRLF 
			cCorpoDVO1 += "               AND DTK_CDRORI = vcDVO_CDRORI "+CRLF 
			cCorpoDVO1 += "               AND DTK_CDRDES = vcDVO_CDRDES "+CRLF 
			cCorpoDVO1 += "               AND DTK_CODPRO = vcDVO_CODPRO "+CRLF 
			cCorpoDVO1 += "               AND DTK_CODPAS = vcDVO_CODPAS "+CRLF
			cCorpoDVO1 += "               AND D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDVO1 += CRLF
			cCorpoDVO1 += "            EXCEPTION"+CRLF
			cCorpoDVO1 += "               WHEN NO_DATA_FOUND THEN NULL "+CRLF  
			cCorpoDVO1 += "         END"+CRLF     	 		
			cCorpoDVO1 += CRLF
			cCorpoDVO1 += "         IF ((vnValMin is null) or (vnValExc is null) or (vnExcMin is null)) THEN"+CRLF	 		
			cCorpoDVO1 += "         	BEGIN"+CRLF			
			cCorpoDVO1 += "							SELECT NVL( DTK_VALMIN, 0 ), NVL(DTK_VALOR, 0 ), NVL( DTK_EXCMIN, 0 ), DVD_RGOTAB, DVD_RGDTAB "+CRLF
			cCorpoDVO1 += "								INTO vnValMin , vnValExc, vnExcMin, vcRgOtab, vcRgDtab "+CRLF   
			cCorpoDVO1 += "								FROM "+RetSqlName("DTK")+' DTK,'+RetSqlName("DVD")+' DVD '+CRLF 	    	
			cCorpoDVO1 += "              WHERE DVD_FILIAL = vcFil_DVD"+CRLF
			cCorpoDVO1 += "             	 AND DVD_TABFRE = vcDVO_TABFRE "+CRLF 	    	
			cCorpoDVO1 += "            		 AND DVD_TIPTAB = vcDVO_TIPTAB "+CRLF 	    		    	
			cCorpoDVO1 += "            		 AND DVD_CDRORI = vcDVO_CDRORI "+CRLF 	    		    	
			cCorpoDVO1 += "            		 AND DVD_CDRDES = vcDVO_CDRDES "+CRLF 	    		    		    	
			cCorpoDVO1 += "              	 	 AND DVD_CODCLI = vcCliente "+CRLF 	    	
			cCorpoDVO1 += "              	 	 AND DVD_LOJCLI = vcLoja "+CRLF 	    				 
			cCorpoDVO1 += "              	 	 AND DVD_SEQTAB = vcDVO_SEQTAB "+CRLF 	    				 			
			cCorpoDVO1 += "              	 	 AND DVD_CODPRO = vcDVO_CODPRO "+CRLF 	    				 			
			cCorpoDVO1 += "              	 	 AND DVD_CODNEG = vcDVO_CODNEG "+CRLF 	    				 			
			cCorpoDVO1 += "              	 	 AND DVD_SERVIC = vcDVO_SERVIC "+CRLF 	    				 			
			cCorpoDVO1 += "              	 	 AND DVD_CODPAS = vcDVO_CODPAS "+CRLF 	    				 			
			cCorpoDVO1 += "						 AND DVD.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDVO1 += "             	 	 AND DTK_FILIAL = vcFil_DTK  "+CRLF
			cCorpoDVO1 += "						 AND DTK_TABFRE = DVD_TABFRE "+CRLF 
			cCorpoDVO1 += "						 AND DTK_TIPTAB = DVD_TIPTAB "+CRLF 
			cCorpoDVO1 += "						 AND DTK_CDRORI = DVD_RGOTAB "+CRLF 
			cCorpoDVO1 += "						 AND DTK_CDRDES = DVD_RGDTAB "+CRLF 
			cCorpoDVO1 += "						 AND DTK_CODPRO = DVD_CODPRO "+CRLF 
			cCorpoDVO1 += "						 AND DTK_CODPAS = DVD_CODPAS "+CRLF  
			cCorpoDVO1 += "						 AND DTK.D_E_L_E_T_ = ' '"+CRLF
			cCorpoDVO1 +=CRLF
			cCorpoDVO1 += "	            EXCEPTION"+CRLF
			cCorpoDVO1 += "               	WHEN NO_DATA_FOUND THEN NULL "+CRLF  
			cCorpoDVO1 += " 		   	END"+CRLF
			cCorpoDVO1 += "         END IF "+CRLF
			cCorpoDVO1 +=CRLF
			cCorpoDVO1 += "         IF ((vnValMin > 0) or (vnValExc > 0) or (vnExcMin > 0)) THEN"+CRLF 
			cCorpoDVO1 += "            BEGIN "+CRLF 
			cCorpoDVO1 += "         		vnMinNov := null "+CRLF
			cCorpoDVO1 += "         		vnExcNov := null "+CRLF
			cCorpoDVO1 +=CRLF
			cCorpoDVO1 += "               SELECT DTK_VALMIN ,DTK_VALOR "+CRLF
			cCorpoDVO1 += "                 INTO vnMinNov, vnExcNov"+CRLF  
			cCorpoDVO1 += "                 FROM "+RetSqlName("DTK")+CRLF 
			cCorpoDVO1 += "                WHERE DTK_FILIAL = vcFil_DTK"+CRLF 
			cCorpoDVO1 += "                  AND DTK_TABFRE = IN_NEWTABELA"+CRLF 
			cCorpoDVO1 += "                  AND DTK_TIPTAB = IN_NEWTIPTAB"+CRLF 
			cCorpoDVO1 += "                  AND DTK_CDRORI = vcDVO_CDRORI "+CRLF 
			cCorpoDVO1 += "                  AND DTK_CDRDES = vcDVO_CDRDES "+CRLF 
			cCorpoDVO1 += "                  AND DTK_CODPRO = vcDVO_CODPRO "+CRLF 
			cCorpoDVO1 += "                  AND DTK_CODPAS = vcDVO_CODPAS "+CRLF 
			cCorpoDVO1 += "                  AND D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDVO1 += CRLF
			cCorpoDVO1 += "               EXCEPTION"+CRLF
			cCorpoDVO1 += "                  WHEN NO_DATA_FOUND THEN NULL "+CRLF  
			cCorpoDVO1 += "            END"+CRLF 
			cCorpoDVO1 +=CRLF 
			cCorpoDVO1 += "            IF ((vnMinNov is null) or (vnExcNov is null)) THEN"+CRLF
			cCorpoDVO1 += "         		BEGIN"+CRLF
			cCorpoDVO1 += "               	SELECT NVL( DTK_VALMIN, 0 ) ,NVL( DTK_VALOR, 0 ) "+CRLF
			cCorpoDVO1 += "                 		INTO vnMinNov, vnExcNov"+CRLF  
			cCorpoDVO1 += "            			FROM "+RetSqlName("DTK")+CRLF 
			cCorpoDVO1 += "             	 	WHERE DTK_FILIAL = vcFil_DTK"+CRLF
			cCorpoDVO1 += "               		AND DTK_TABFRE = IN_NEWTABELA"+CRLF 
			cCorpoDVO1 += "               		AND DTK_TIPTAB = IN_NEWTIPTAB"+CRLF 
			cCorpoDVO1 += "               		AND DTK_CDRORI = vcRgOtab "+CRLF 
			cCorpoDVO1 += "               		AND DTK_CDRDES = vcRgDtab "+CRLF 
			cCorpoDVO1 += "               		AND DTK_CODPRO = vcDVO_CODPRO "+CRLF
			cCorpoDVO1 += "  		           		AND DTK_CODPAS = vcDVO_CODPAS "+CRLF
			cCorpoDVO1 += "	              		AND D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDVO1 +=CRLF
			cCorpoDVO1 += "	            	EXCEPTION"+CRLF
			cCorpoDVO1 += "               		WHEN NO_DATA_FOUND THEN NULL "+CRLF
			cCorpoDVO1 += " 		   		END"+CRLF
			cCorpoDVO1 += "         	END IF "+CRLF
			cCorpoDVO1 +=CRLF
			cCorpoDVO1 += "            IF (vnValMin > 0 and vnMinNov > 0) THEN"+CRLF
			cCorpoDVO1 += "               vnValTabAnt := vnValMin * (vnDVO_PERMIN / 100)"+CRLF
			cCorpoDVO1 += "               vnPerNewAju := (vnValTabAnt / vnMinNov) * 100 "+CRLF
			cCorpoDVO1 += "               UPDATE " + cTemp + " SET"+CRLF
			cCorpoDVO1 += "                       DVO_PERMIN = vnPerNewAju "+CRLF
			cCorpoDVO1 += "               WHERE R_E_C_N_O_ = viRecno "+CRLF
			cCorpoDVO1 += "               commit "+CRLF
			cCorpoDVO1 += "            END IF "+CRLF
			cCorpoDVO1 +=CRLF
			cCorpoDVO1 += "            IF (vnValExc > 0 and vnExcNov > 0) THEN"+CRLF
			cCorpoDVO1 += "               vnValTabAnt := vnValExc * (vnDVO_PERAJU) / 100"+CRLF
			cCorpoDVO1 += "               vnPerNewAju := (vnValTabAnt / vnExcNov) * 100 "+CRLF
			cCorpoDVO1 += "               UPDATE " + cTemp + " SET"+CRLF
			cCorpoDVO1 += "                      DVO_PERAJU = vnPerNewAju "+CRLF
			cCorpoDVO1 += "               WHERE R_E_C_N_O_ = viRecno "+CRLF
			cCorpoDVO1 += "               commit "+CRLF
			cCorpoDVO1 += "            END IF "+CRLF
			cCorpoDVO1 += "         ELSE"+CRLF 
			cCorpoDVO1 += "            UPDATE " + cTemp + " SET D_E_L_E_T_ = '*'"+CRLF
			cCorpoDVO1 += "             WHERE R_E_C_N_O_ = viRecno "+CRLF
			cCorpoDVO1 += "            commit "+CRLF
			cCorpoDVO1 += "         END IF"+CRLF
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % Minimo                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "         vnPercAtu := vnDVO_PERMIN "+CRLF 
			cCorpoDVO2 += "         vnValor   := null "+CRLF 
			cCorpoDVO2 +=CRLF 
			cCorpoDVO2 += "         BEGIN"+CRLF
			cCorpoDVO2 += "            SELECT DTK_VALMIN "+CRLF
			cCorpoDVO2 += "              INTO vnValor"+CRLF
			cCorpoDVO2 += "              FROM "+RetSqlName("DTK")+CRLF 
			cCorpoDVO2 += "             WHERE DTK_FILIAL = vcFil_DTK"+CRLF
			cCorpoDVO2 += "               AND DTK_TABFRE = vcDVO_TABFRE"+CRLF 
			cCorpoDVO2 += "               AND DTK_TIPTAB = vcDVO_TIPTAB"+CRLF 
			cCorpoDVO2 += "               AND DTK_CDRORI = vcDVO_CDRORI "+CRLF 
			cCorpoDVO2 += "               AND DTK_CDRDES = vcDVO_CDRDES "+CRLF 
			cCorpoDVO2 += "               AND DTK_CODPRO = vcDVO_CODPRO "+CRLF 
			cCorpoDVO2 += "               AND DTK_CODPAS = vcDVO_CODPAS "+CRLF  
			cCorpoDVO2 += "               AND D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "            EXCEPTION"+CRLF
			cCorpoDVO2 += "                  WHEN NO_DATA_FOUND THEN NULL "+CRLF  
			cCorpoDVO2 += "            END"+CRLF
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "         IF ( vnValor is null ) THEN"+CRLF	 		
			cCorpoDVO2 += "         	BEGIN"+CRLF			
			cCorpoDVO2 += "            	SELECT NVL( DTK_VALMIN , 0 )"+CRLF
			cCorpoDVO2 += "            		INTO vnValor"+CRLF
			cCorpoDVO2 += "            		FROM "+RetSqlName("DTK")+' DTK,'+RetSqlName("DVD")+' DVD '+CRLF 	    	
			cCorpoDVO2 += "            	 WHERE DVD_FILIAL = vcFil_DVD"+CRLF
			cCorpoDVO2 += "								 AND DVD_TABFRE = vcDVO_TABFRE "+CRLF 	    	
			cCorpoDVO2 += "								 AND DVD_TIPTAB = vcDVO_TIPTAB "+CRLF 	    		    	
			cCorpoDVO2 += "            		 AND DVD_CDRORI = vcDVO_CDRORI "+CRLF 	    		    	
			cCorpoDVO2 += "            		 AND DVD_CDRDES = vcDVO_CDRDES "+CRLF 	    		    		    	
			cCorpoDVO2 += "              	 AND DVD_CODCLI = vcCliente "+CRLF 	    	
			cCorpoDVO2 += "              	 AND DVD_LOJCLI = vcLoja "+CRLF 	    				 
			cCorpoDVO2 += "              	 AND DVD_SEQTAB = vcDVO_SEQTAB "+CRLF 	    				 			
			cCorpoDVO2 += "              	 AND DVD_CODPRO = vcDVO_CODPRO "+CRLF 	    				 			
			cCorpoDVO2 += "              	 AND DVD_CODNEG = vcDVO_CODNEG "+CRLF 	    				 			
			cCorpoDVO2 += "              	 AND DVD_SERVIC = vcDVO_SERVIC "+CRLF 	    				 			
			cCorpoDVO2 += "              	 AND DVD_CODPAS = vcDVO_CODPAS "+CRLF 	    				 			
			cCorpoDVO2 += "								 AND DVD.D_E_L_E_T_ = ' '    "+CRLF
			cCorpoDVO2 += "             	 AND DTK_FILIAL = vcFil_DTK  "+CRLF
			cCorpoDVO2 += "								 AND DTK_TABFRE = DVD_TABFRE "+CRLF 
			cCorpoDVO2 += "								 AND DTK_TIPTAB = DVD_TIPTAB "+CRLF 
			cCorpoDVO2 += "								 AND DTK_CDRORI = DVD_RGOTAB "+CRLF 
			cCorpoDVO2 += "								 AND DTK_CDRDES = DVD_RGDTAB "+CRLF 
			cCorpoDVO2 += "								 AND DTK_CODPRO = DVD_CODPRO "+CRLF 
			cCorpoDVO2 += "								 AND DTK_CODPAS = DVD_CODPAS "+CRLF  
			cCorpoDVO2 += "								 AND DTK.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "	            EXCEPTION"+CRLF
			cCorpoDVO2 += "               	WHEN NO_DATA_FOUND THEN NULL "+CRLF  
			cCorpoDVO2 += " 		   	END"+CRLF
			cCorpoDVO2 += "				  END IF "+CRLF
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "         IF ( vnValor > 0 ) THEN"+CRLF
			cCorpoDVO2 += "            BEGIN"+CRLF         
			cCorpoDVO2 += "               SELECT NVL( TRB_PERMIN , 0 )"+CRLF
			cCorpoDVO2 += "                 INTO vnPerNewAju"+CRLF 
			cCorpoDVO2 += "                 FROM "+ cTrab +CRLF
			cCorpoDVO2 += "                WHERE TRB_CODPAS = vcDVO_CODPAS "+CRLF 
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "               EXCEPTION"+CRLF
			cCorpoDVO2 += "                  WHEN NO_DATA_FOUND THEN NULL "+CRLF  
			cCorpoDVO2 += "            END"+CRLF 
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "            vnPerNewMin := 0 "+CRLF
			cCorpoDVO2 += "            IF (vnPercAtu > 0) THEN"+CRLF 
			cCorpoDVO2 += "               IF (vnPerNewAju > 0) THEN"+CRLF 
				                              //-- Valor do Ajuste Anterior dado a Tabela
			cCorpoDVO2 += "                  vnValAntAju := vnValor * ( vnPercAtu / 100) "+CRLF
				                              //-- Valor do Novo Ajuste 
			cCorpoDVO2 += "      	         vnValNewAju := vnValAntAju + (vnValAntAju * (vnPerNewAju / 100) ) "+CRLF
                                          //-- Percentual a ser aplicado no valor do componente 
			cCorpoDVO2 += "                  vnPerNewMin := (vnValNewAju / vnValor) * 100 "+CRLF
			cCorpoDVO2 += "               ELSE"+CRLF
			cCorpoDVO2 += "                  vnPerNewMin := vnPercAtu "+CRLF
			cCorpoDVO2 += "               END IF"+CRLF
			cCorpoDVO2 += "               vnGravaAju := vnPerNewMin "+CRLF 
			cCorpoDVO2 += "               UPDATE "+cTemp+" SET DVO_PERMIN = vnGravaAju"+CRLF
			cCorpoDVO2 += "                where R_E_C_N_O_ = viRecno "+CRLF
			cCorpoDVO2 += "               commit "+CRLF
			cCorpoDVO2 += "            END IF"+CRLF
			cCorpoDVO2 += "         END IF "+CRLF
			cCorpoDVO2 +=CRLF
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o % Excedente                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			cCorpoDVO2 += "         vnPercAtu := vnDVO_PERAJU "+CRLF 
			cCorpoDVO2 += "         vnValor   := null "+CRLF 
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "         BEGIN"+CRLF
			cCorpoDVO2 += "            SELECT DTK_VALOR "+CRLF
			cCorpoDVO2 += "              INTO vnValor"+CRLF
			cCorpoDVO2 += "              FROM "+RetSqlName("DTK")+CRLF 
			cCorpoDVO2 += "             WHERE DTK_FILIAL = vcFil_DTK"+CRLF
			cCorpoDVO2 += "               AND DTK_TABFRE = vcDVO_TABFRE"+CRLF 
			cCorpoDVO2 += "               AND DTK_TIPTAB = vcDVO_TIPTAB"+CRLF 
			cCorpoDVO2 += "               AND DTK_CDRORI = vcDVO_CDRORI"+CRLF 
			cCorpoDVO2 += "               AND DTK_CDRDES = vcDVO_CDRDES"+CRLF 
			cCorpoDVO2 += "               AND DTK_CODPRO = vcDVO_CODPRO"+CRLF 
			cCorpoDVO2 += "               AND DTK_CODPAS = vcDVO_CODPAS"+CRLF
			cCorpoDVO2 += "               AND D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "            EXCEPTION"+CRLF
			cCorpoDVO2 += "               WHEN NO_DATA_FOUND THEN NULL "+CRLF  
			cCorpoDVO2 += "         END"+CRLF 
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "         IF ( vnValor is null ) THEN"+CRLF
			cCorpoDVO2 += "         	BEGIN"+CRLF			
			cCorpoDVO2 += "            	SELECT NVL( DTK_VALMIN , 0 )"+CRLF
			cCorpoDVO2 += "            		INTO vnValor"+CRLF
			cCorpoDVO2 += "            		FROM "+RetSqlName("DTK")+' DTK,'+RetSqlName("DVD")+' DVD '+CRLF 	    	
			cCorpoDVO2 += "            		WHERE DVD_FILIAL = vcFil_DVD"+CRLF
			cCorpoDVO2 += "                	AND DVD_TABFRE = vcDVO_TABFRE "+CRLF 	    	
			cCorpoDVO2 += "            		AND DVD_TIPTAB = vcDVO_TIPTAB "+CRLF 	    		    	
			cCorpoDVO2 += "            		AND DVD_CDRORI = vcDVO_CDRORI "+CRLF 	    		    	
			cCorpoDVO2 += "            		AND DVD_CDRDES = vcDVO_CDRDES "+CRLF 	    		    		    	
			cCorpoDVO2 += "              		AND DVD_CODCLI = vcCliente "+CRLF 	    	
			cCorpoDVO2 += "              		AND DVD_LOJCLI = vcLoja "+CRLF 	    				 
			cCorpoDVO2 += "              		AND DVD_SEQTAB = vcDVO_SEQTAB "+CRLF 	    				 			
			cCorpoDVO2 += "              		AND DVD_CODPRO = vcDVO_CODPRO "+CRLF 	    				 			
			cCorpoDVO2 += "              		AND DVD_CODNEG = vcDVO_CODNEG "+CRLF 	    				 			
			cCorpoDVO2 += "              		AND DVD_SERVIC = vcDVO_SERVIC "+CRLF 	    				 			
			cCorpoDVO2 += "              		AND DVD_CODPAS = vcDVO_CODPAS "+CRLF 	    				 			
			cCorpoDVO2 += "               	AND DVD.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDVO2 += "             	   AND DTK_FILIAL = vcFil_DTK  "+CRLF
			cCorpoDVO2 += "               	AND DTK_TABFRE = DVD_TABFRE "+CRLF 
			cCorpoDVO2 += "               	AND DTK_TIPTAB = DVD_TIPTAB "+CRLF 
			cCorpoDVO2 += "               	AND DTK_CDRORI = DVD_RGOTAB "+CRLF 
			cCorpoDVO2 += "               	AND DTK_CDRDES = DVD_RGDTAB "+CRLF 
			cCorpoDVO2 += "               	AND DTK_CODPRO = DVD_CODPRO "+CRLF 
			cCorpoDVO2 += "  		           	AND DTK_CODPAS = DVD_CODPAS "+CRLF  
			cCorpoDVO2 += "	              	AND DTK.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "	            EXCEPTION"+CRLF
			cCorpoDVO2 += "               	WHEN NO_DATA_FOUND THEN NULL "+CRLF  
			cCorpoDVO2 += " 		   	END"+CRLF
			cCorpoDVO2 += "         END IF "+CRLF
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "         IF ( vnValor > 0 ) THEN"+CRLF  
			cCorpoDVO2 += "            BEGIN"+CRLF
			cCorpoDVO2 += "               SELECT NVL( TRB_PERAJU , 0 )"+CRLF
			cCorpoDVO2 += "                 INTO vnPerNewAju"+CRLF 
			cCorpoDVO2 += "                 FROM "+ cTrab +CRLF
			cCorpoDVO2 += "                WHERE TRB_CODPAS = vcDVO_CODPAS "+CRLF
			cCorpoDVO2 += CRLF
			cCorpoDVO2 += "               EXCEPTION"+CRLF
			cCorpoDVO2 += "                  WHEN NO_DATA_FOUND THEN NULL "+CRLF  
			cCorpoDVO2 += "            END"+CRLF 
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "            vnPerNewExc := 0 "+CRLF
			cCorpoDVO2 +=CRLF
			cCorpoDVO2 += "            IF ( vnPercAtu > 0 ) THEN"+CRLF 
			cCorpoDVO2 += "               IF ( vnPerNewAju > 0 ) THEN"+CRLF 
			 											//-- Valor do Ajuste Anterior dado a Tabela
			cCorpoDVO2 += "         	      vnValAntAju := vnValor * ( vnPercAtu / 100) "+CRLF  			
			                                 //-- Valor do Novo Ajuste 
			cCorpoDVO2 += "      	   	   vnValNewAju := vnValAntAju + (vnValAntAju * (vnPerNewAju / 100) ) "+CRLF
                                          //-- Percentual a ser aplicado no valor do componente 
			cCorpoDVO2 += "               	vnPerNewExc := (vnValNewAju / vnValor) * 100 "+CRLF  
			cCorpoDVO2 += "            ELSE"+CRLF
			cCorpoDVO2 += "               	vnPerNewExc := vnPercAtu "+CRLF
			cCorpoDVO2 += "            END IF "+CRLF
			cCorpoDVO2 += CRLF
			cCorpoDVO2 += "               vnGravaAju := vnPerNewExc "+CRLF
			cCorpoDVO2 += "               UPDATE "+cTemp+" SET DVO_PERAJU = vnGravaAju"+CRLF
			cCorpoDVO2 += "                WHERE R_E_C_N_O_ = viRecno "+CRLF
			cCorpoDVO2 += "               commit "+CRLF
			cCorpoDVO2 += "            END IF  "+CRLF
			cCorpoDVO2 += "         END IF "+CRLF
		EndIf
	ElseIf cAlias == "DW2"
		cCorpoDW2 := ""
		cCorpoDW2 += "      vcCliente := vcDW2_CODCLI "+CRLF
		cCorpoDW2 += "      vcLoja := vcDW2_LOJCLI "+CRLF
		cCorpoDW2 += "      vcConcat := vcCliente || vcLoja "+CRLF
		cCorpoDW2 +=CRLF
		cCorpoDW21 := ""
		cCorpoDW22 := ""
		If lNovaTab
			cCorpoDW21 += "         vnValor := 0 " +CRLF
			cCorpoDW21 +=CRLF
			cCorpoDW21 += "         BEGIN"+CRLF
			//-- Posiciona na Tabela Mae da Tabela Anterior
			cCorpoDW21 += "            SELECT NVL( DW1_VALOR , 0 ) "+CRLF
			cCorpoDW21 += "              INTO vnValor"+CRLF 
			cCorpoDW21 += "              FROM "+RetSqlName("DW1")+" DW1 ,"+RetSqlName("DT0")+" DT0 " +CRLF
			cCorpoDW21 += "             WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
			cCorpoDW21 += "               AND DT0_TABFRE = vcDW2_TABFRE "+CRLF
			cCorpoDW21 += "               AND DT0_TIPTAB = vcDW2_TIPTAB "+CRLF
			cCorpoDW21 += "               AND DT0_CDRORI = vcDW2_RGOTAB "+CRLF
			cCorpoDW21 += "               AND DT0_CDRDES = vcDW2_RGDTAB "+CRLF
			cCorpoDW21 += "               AND DT0_CODPRO = vcDW2_PRDTAB "+CRLF 
			cCorpoDW21 += "               AND DW1_FILIAL = vcFil_DW1 "+CRLF
			cCorpoDW21 += "               AND DW1_TABFRE = DT0_TABFRE "+CRLF
			cCorpoDW21 += "               AND DW1_TIPTAB = DT0_TIPTAB "+CRLF
			cCorpoDW21 += "               AND DW1_CDRORI = DT0_CDRORI "+CRLF
			cCorpoDW21 += "               AND DW1_CDRDES = DT0_CDRDES "+CRLF
			cCorpoDW21 += "               AND DW1_CODPRO = DT0_CODPRO "+CRLF
			cCorpoDW21 += "               AND DW1_CODPAS = vcDW2_CODPAS "+CRLF
			cCorpoDW21 += "               AND DW1_ITEDT1 = vcDW2_ITEDVD "+CRLF
			cCorpoDW21 += "               AND DW1_ITEM   = vcDW2_ITEM "+CRLF
			cCorpoDW21 += "               AND DT0.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW21 += "               AND DW1.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW21 += CRLF
			cCorpoDW21 += "            EXCEPTION"+CRLF
			cCorpoDW21 += "               WHEN NO_DATA_FOUND THEN NULL "+CRLF
			cCorpoDW21 += "         END "+CRLF
			cCorpoDW21 += CRLF
			cCorpoDW21 += "         IF ( vnValor = 0 ) THEN" +CRLF
			cCorpoDW21 += "            BEGIN"+CRLF
			cCorpoDW21 += "               SELECT NVL( DW0_VALOR , 0 )"+CRLF
			cCorpoDW21 += "                 INTO vnValor"+CRLF
			cCorpoDW21 += "                 FROM "+RetSqlName("DW0")+" DW0 ,"+RetSqlName("DT0")+" DT0 "+CRLF
			cCorpoDW21 += "                WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
			cCorpoDW21 += "                  AND DT0_TABFRE = vcDW2_TABFRE "+CRLF
			cCorpoDW21 += "                  AND DT0_TIPTAB = vcDW2_TIPTAB "+CRLF
			cCorpoDW21 += "                  AND DT0_CDRORI = vcDW2_RGOTAB "+CRLF
			cCorpoDW21 += "                  AND DT0_CDRDES = vcDW2_RGDTAB "+CRLF
			cCorpoDW21 += "                  AND DT0_CODPRO = vcDW2_PRDTAB "+CRLF
			cCorpoDW21 += "                  AND DW0_FILIAL = vcFil_DW0 "+CRLF
			cCorpoDW21 += "                  AND DW0_TABFRE = DT0_TABFRE "+CRLF
			cCorpoDW21 += "                  AND DW0_TIPTAB = DT0_TIPTAB "+CRLF
			cCorpoDW21 += "                  AND DW0_TABTAR = DT0_TABTAR "+CRLF
			cCorpoDW21 += "                  AND DW0_CODPAS = vcDW2_CODPAS "+CRLF
			cCorpoDW21 += "                  AND DW0_ITEDTG = vcDW2_ITEDVD "+CRLF
			cCorpoDW21 += "                  AND DW0_ITEM   = vcDW2_ITEM "+CRLF  
			cCorpoDW21 += "                  AND DT0.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW21 += "                  AND DW0.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW21 += CRLF
			cCorpoDW21 += "               EXCEPTION"+CRLF
			cCorpoDW21 += "                  WHEN NO_DATA_FOUND THEN NULL "+CRLF  

			cCorpoDW21 += "            END "+CRLF
			cCorpoDW21 += "         END IF "+CRLF 
			cCorpoDW21 += CRLF  
			cCorpoDW21 += "         IF ( vnValor > 0 ) THEN"+CRLF
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Mantem o Valor do Ajuste da Tabela anterior                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCorpoDW21 += "            vnValTabNova := 0 "+CRLF
			cCorpoDW21 += "            BEGIN"+CRLF
			cCorpoDW21 += "               SELECT NVL( DW1_VALOR , 0 )"+CRLF
			cCorpoDW21 += "                 INTO vnValTabNova"+CRLF 
			cCorpoDW21 += "                 FROM "+RetSqlName("DW1")+" DW1 ,"+RetSqlName("DT0")+" DT0 "+CRLF
			cCorpoDW21 += "                WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
			cCorpoDW21 += "                  AND DT0_TABFRE = IN_NEWTABELA "+CRLF
			cCorpoDW21 += "                  AND DT0_TIPTAB = IN_NEWTIPTAB "+CRLF
			cCorpoDW21 += "                  AND DT0_CDRORI = vcDW2_RGOTAB "+CRLF
			cCorpoDW21 += "                  AND DT0_CDRDES = vcDW2_RGDTAB "+CRLF
			cCorpoDW21 += "                  AND DT0_CODPRO = vcDW2_PRDTAB "+CRLF 
			cCorpoDW21 += "                  AND DW1_FILIAL = vcFil_DW1 "+CRLF
			cCorpoDW21 += "                  AND DW1_TABFRE = IN_NEWTABELA "+CRLF
			cCorpoDW21 += "                  AND DW1_TIPTAB = IN_NEWTIPTAB "+CRLF
			cCorpoDW21 += "                  AND DW1_CDRORI = DT0_CDRORI "+CRLF
			cCorpoDW21 += "                  AND DW1_CDRDES = DT0_CDRDES "+CRLF
			cCorpoDW21 += "                  AND DW1_CODPRO = DT0_CODPRO "+CRLF
			cCorpoDW21 += "                  AND DW1_CODPAS = vcDW2_CODPAS "+CRLF
			cCorpoDW21 += "                  AND DW1_ITEDT1 = vcDW2_ITEDVD "+CRLF
			cCorpoDW21 += "                  AND DW1_ITEM   = vcDW2_ITEM "+CRLF
			cCorpoDW21 += "                  AND DT0.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW21 += "                  AND DW1.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW21 += CRLF
			cCorpoDW21 += "               EXCEPTION"+CRLF
			cCorpoDW21 += "                  WHEN NO_DATA_FOUND THEN NULL "+CRLF  
			cCorpoDW21 += "            END "+CRLF 

			cCorpoDW21 += CRLF
			cCorpoDW21 += "            IF ( vnValTabNova = 0 ) THEN"+CRLF
			cCorpoDW21 += "               BEGIN"+CRLF
			cCorpoDW21 += "                  SELECT NVL( DW0_VALOR , 0 )"+CRLF
			cCorpoDW21 += "                    INTO vnValTabNova"+CRLF 
			cCorpoDW21 += "                    FROM "+RetSqlName("DW0")+" DW0 ,"+RetSqlName("DT0")+" DT0 "+CRLF
			cCorpoDW21 += "                   WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
			cCorpoDW21 += "                     AND DT0_TABFRE = IN_NEWTABELA "+CRLF
			cCorpoDW21 += "                     AND DT0_TIPTAB = IN_NEWTIPTAB "+CRLF
			cCorpoDW21 += "                     AND DT0_CDRORI = vcDW2_RGOTAB "+CRLF
			cCorpoDW21 += "                     AND DT0_CDRDES = vcDW2_RGDTAB "+CRLF
			cCorpoDW21 += "                     AND DT0_CODPRO = vcDW2_PRDTAB "+CRLF   
			cCorpoDW21 += "                     AND DW0_FILIAL = vcFil_DW0 "+CRLF
			cCorpoDW21 += "                     AND DW0_TABFRE = IN_NEWTABELA "+CRLF
			cCorpoDW21 += "                     AND DW0_TIPTAB = IN_NEWTIPTAB "+CRLF
			cCorpoDW21 += "                     AND DW0_TABTAR = DT0_TABTAR "+CRLF
			cCorpoDW21 += "                     AND DW0_CODPAS = vcDW2_CODPAS "+CRLF
			cCorpoDW21 += "                     AND DW0_ITEDTG = vcDW2_ITEDVD "+CRLF
			cCorpoDW21 += "                     AND DW0_ITEM   = vcDW2_ITEM "+CRLF  
			cCorpoDW21 += "                     AND DT0.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW21 += "                     AND DW0.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW21 += CRLF
			cCorpoDW21 += "                  EXCEPTION"+CRLF
			cCorpoDW21 += "                     WHEN NO_DATA_FOUND THEN NULL "+CRLF  
			cCorpoDW21 += "               END"+CRLF
			cCorpoDW21 += "            END IF"+CRLF
			cCorpoDW21 += CRLF 
			cCorpoDW21 += "            IF ( vnValTabNova > 0 ) THEN"+CRLF
			cCorpoDW21 += "               vnValTabAnt := vnValor * (vnDW2_PERAJU / 100) "+CRLF
			cCorpoDW21 += "               vnPerNewAju := (vnValTabAnt / vnValTabNova) * 100 "+CRLF
			cCorpoDW21 += CRLF
			cCorpoDW21 += "               UPDATE " +cTemp+ " SET DW2_PERAJU = vnPerNewAju"+CRLF    
			cCorpoDW21 += "                WHERE R_E_C_N_O_ = viRecno "+CRLF
			cCorpoDW21 += "               commit "+CRLF
			cCorpoDW21 += "            END IF "+CRLF
			cCorpoDW21 += "         END IF "+CRLF
		Else
			cCorpoDW22 += ""
			cCorpoDW22 += "         vnValor := 0 " +CRLF
			cCorpoDW22+=CRLF
			//-- Posiciona na Tabela Mae da Tabela Anterior
			cCorpoDW22 += "         BEGIN"+CRLF
			cCorpoDW22 += "            SELECT NVL( DW1_VALOR , 0 )"+CRLF
			cCorpoDW22 += "              INTO vnValor"+CRLF
			cCorpoDW22 += "              FROM "+RetSqlName("DW1")+" DW1 ,"+RetSqlName("DT0")+" DT0 " +CRLF
			cCorpoDW22 += "             WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
			cCorpoDW22 += "               AND DT0_TABFRE = vcDW2_TABFRE "+CRLF
			cCorpoDW22 += "               AND DT0_TIPTAB = vcDW2_TIPTAB "+CRLF
			cCorpoDW22 += "               AND DT0_CDRORI = vcDW2_RGOTAB "+CRLF
			cCorpoDW22 += "               AND DT0_CDRDES = vcDW2_RGDTAB "+CRLF
			cCorpoDW22 += "               AND DT0_CODPRO = vcDW2_PRDTAB "+CRLF 
			cCorpoDW22 += "               AND DW1_FILIAL = vcFil_DW1 "   +CRLF
			cCorpoDW22 += "               AND DW1_TABFRE = DT0_TABFRE "+CRLF
			cCorpoDW22 += "               AND DW1_TIPTAB = DT0_TIPTAB "+CRLF
			cCorpoDW22 += "               AND DW1_CDRORI = DT0_CDRORI "+CRLF
			cCorpoDW22 += "               AND DW1_CDRDES = DT0_CDRDES "+CRLF
			cCorpoDW22 += "               AND DW1_CODPRO = DT0_CODPRO "+CRLF
			cCorpoDW22 += "               AND DW1_CODPAS = vcDW2_CODPAS "+CRLF
			cCorpoDW22 += "               AND DW1_ITEDT1 = vcDW2_ITEDVD "+CRLF
			cCorpoDW22 += "               AND DW1_ITEM   = vcDW2_ITEM "+CRLF
			cCorpoDW22 += "               AND DT0.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW22 += "               AND DW1.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW22 += CRLF            
			cCorpoDW22 += "            EXCEPTION"+CRLF
			cCorpoDW22 += "               WHEN NO_DATA_FOUND THEN NULL "+CRLF  
			cCorpoDW22 += "         END"+CRLF
			cCorpoDW22 += CRLF
			cCorpoDW22 += "         IF ( vnValor = 0 ) THEN" +CRLF
			cCorpoDW22 += "            BEGIN"+CRLF   
			cCorpoDW22 += "               SELECT NVL( DW0_VALOR , 0 ) "+CRLF
			cCorpoDW22 += "                 INTO vnValor"+CRLF
			cCorpoDW22 += "                 FROM "+RetSqlName("DW0")+" DW0 ,"+RetSqlName("DT0")+" DT0 " +CRLF
			cCorpoDW22 += "                WHERE DT0_FILIAL = vcFil_DT0 "+CRLF
			cCorpoDW22 += "                  AND DT0_TABFRE = vcDW2_TABFRE "+CRLF
			cCorpoDW22 += "                  AND DT0_TIPTAB = vcDW2_TIPTAB "+CRLF
			cCorpoDW22 += "                  AND DT0_CDRORI = vcDW2_RGOTAB "+CRLF
			cCorpoDW22 += "                  AND DT0_CDRDES = vcDW2_RGDTAB "+CRLF
			cCorpoDW22 += "                  AND DT0_CODPRO = vcDW2_PRDTAB "+CRLF
			cCorpoDW22 += "                  AND DW0_FILIAL = vcFil_DW0 "+CRLF
			cCorpoDW22 += "                  AND DW0_TABFRE = DT0_TABFRE "+CRLF
			cCorpoDW22 += "                  AND DW0_TIPTAB = DT0_TIPTAB "+CRLF
			cCorpoDW22 += "                  AND DW0_TABTAR = DT0_TABTAR "+CRLF
			cCorpoDW22 += "                  AND DW0_CODPAS = vcDW2_CODPAS "+CRLF
			cCorpoDW22 += "                  AND DW0_ITEDTG = vcDW2_ITEDVD "+CRLF
			cCorpoDW22 += "                  AND DW0_ITEM   = vcDW2_ITEM "+CRLF  
			cCorpoDW22 += "                  AND DT0.D_E_L_E_T_ = ' ' "+CRLF
			cCorpoDW22 += "                  AND DW0.D_E_L_E_T_ = ' ' "+CRLF 
			cCorpoDW22 += CRLF            
			cCorpoDW22 += "               EXCEPTION"+CRLF
			cCorpoDW22 += "                  WHEN NO_DATA_FOUND THEN NULL "+CRLF  
			cCorpoDW22 += "            END"+CRLF
			cCorpoDW22 += "         END IF"+CRLF
			cCorpoDW22 += CRLF
			cCorpoDW22 += "         IF ( vnValor > 0 ) THEN"+CRLF
			cCorpoDW22 += "            vnPercAtu := vnDW2_PERAJU "+CRLF 
			cCorpoDW22 += "            BEGIN"+CRLF
			cCorpoDW22 += "               SELECT NVL( TRB_PERREA , 0 )"+CRLF
			cCorpoDW22 += "                 INTO vnPerNewAju"+CRLF 
			cCorpoDW22 += "                 FROM "+ cTrab +CRLF
			cCorpoDW22 += "                WHERE TRB_CODPAS = vcDW2_CODPAS "+CRLF
			cCorpoDW22 += CRLF    
			cCorpoDW22 += "               EXCEPTION"+CRLF
			cCorpoDW22 += "                  WHEN NO_DATA_FOUND THEN NULL "+CRLF  
			cCorpoDW22 += "            END"+CRLF
			cCorpoDW22 += CRLF
			cCorpoDW22 += "            IF ( vnPercAtu > 0 ) THEN"+CRLF 
			cCorpoDW22 += "               IF ( vnPerNewAju > 0 ) THEN"+CRLF 
														//-- Valor do Ajuste Anterior dado a Tabela
			cCorpoDW22 += "                  vnValAntAju := vnValor * ( vnPercAtu / 100) "+CRLF
			                              	//-- Valor do Novo Ajuste 
			cCorpoDW22 += "      	         vnValNewAju := vnValAntAju + (vnValAntAju * (vnPerNewAju / 100) ) "+CRLF
                                         	//-- Percentual a ser aplicado no valor do componente 
			cCorpoDW22 += "                  vnPerNewAju := (vnValNewAju / vnValor) * 100 "+CRLF  
			cCorpoDW22 += "               ELSE"+CRLF
			cCorpoDW22 += "                  vnPerNewAju := vnPercAtu "+CRLF
			cCorpoDW22 += "               END IF "+CRLF
			cCorpoDW22 += CRLF
			cCorpoDW22 += "               vnGravaAju := vnPerNewAju "+CRLF  
			cCorpoDW22 += "               UPDATE " +cTemp+ " SET DW2_PERAJU = vnGravaAju"+CRLF      
			cCorpoDW22 += "                WHERE R_E_C_N_O_ = viRecno "+CRLF
			cCorpoDW22 += "               commit "+CRLF
			cCorpoDW22 += "            END IF "+CRLF 
			cCorpoDW22 += "         END IF "+CRLF
		EndIf
	EndIf

	cCorpoFim :=""
	cCorpoFim += CRLF
	cCorpoFim += "      FETCH CUR001"+CRLF
	cCorpoFim += "       INTO " +cFetch +" viRecno " +CRLF  
	cCorpoFim += "   END LOOP "+CRLF
	cCorpoFim +=CRLF
	cCorpoFim += "   CLOSE CUR001 "+CRLF
	cCorpoFim +=CRLF
	cCorpoFim += "   BEGIN"+CRLF 
	cCorpoFim += "      SELECT NVL( max(R_E_C_N_O_) , 0 )"+CRLF 
	cCorpoFim += "        INTO viMaxRecno"+CRLF
	cCorpoFim += "        FROM "+ RetSqlName( cAlias ) +" " +CRLF   //verficar IsNull | MAX
	cCorpoFim += CRLF    
	cCorpoFim += "      EXCEPTION"+CRLF
	cCorpoFim += "         WHEN NO_DATA_FOUND THEN NULL "+CRLF  
	cCorpoFim += "   END "+CRLF
	cCorpoFim += CRLF
	cCorpoFim += "   commit "+CRLF

EndIf //lCalcPrc

cCorpoFim  += CRLF
cCorpoFim  += "	  OUT_RESULTADO := '1' "+CRLF
cCorpoFim  += "END" 

cProcedure := ""
If (cAlias == "DVC")
	cProcedure := cCreate + cDeclare + cCorpoIni + cCorpoDVC + cCorpoFim
ElseIf (cAlias == "DVD")
	cProcedure := cCreate + cDeclare + cCorpoIni + cCorpoDVD + cCorpoFim
ElseIf (cAlias == "DVO") 
	If lNovaTab
		cProcedure := cCreate + cDeclare + cCorpoIni + cCorpoDVO +cCorpoDVO1 + cCorpoFim
	Else
		cProcedure := cCreate + cDeclare + cCorpoIni + cCorpoDVO +cCorpoDVO2 + cCorpoFim
	EndIf
ElseIf (cAlias == "DW2")
	If lNovaTab
		cProcedure := cCreate + cDeclare + cCorpoIni + cCorpoDW2 +cCorpoDW21 + cCorpoFim
	Else
		cProcedure := cCreate + cDeclare + cCorpoIni + cCorpoDW2 +cCorpoDW22 + cCorpoFim
	EndIf
EndIf

TcSqlExec(cProcedure)

cProc01 := "XFILIAL"
cProc02 := cTrab

If ExistProc('XFILIAL_'+cEmpAnt).And. ( TcSrvType() <> "AS/400" )

	cFilCliPrc := Iif(Empty(cFilCli), " ", cFilCli)
	cNewTabelaPrc := Iif(Empty(cNewTabela)," ", cNewTabela)
	cNewTipTabPrc := Iif(Empty(cNewTipTab)," ", cNewTipTab)

	MsgRun(STR0039,;
			STR0040,{|| 	aResult := TCSPExec(xProcedures(cProc02),FWGETCODFILIAL,;
			cNewTabelaPrc,  cNewTipTabPrc, dtos(dDataBase),  cTipFre) } ) //processo sendo escutado 


	If Empty(aResult) .or. aResult[1] = "0"

		MsgRun(STR0041,;
				STR0040,{|| TmsA750Aju( cAlias, cQueryAux, cTipFre,;
				cFilCli, cNewTabela, cNewTipTab, lMantemPrc, cSeqTab, aMsgErr , cGroup, cCliAtu, cLojAtu ,.F. , cTemp ) } )
	Endif
Else

		MsgRun(STR0041,;
				STR0040,{|| TmsA750Aju( cAlias, cQueryAux, cTipFre,;
				cFilCli, cNewTabela, cNewTipTab, lMantemPrc, cSeqTab, aMsgErr , cGroup, cCliAtu,cLojAtu, .F. ,cTemp ) } )
EndIf

Return.T.
