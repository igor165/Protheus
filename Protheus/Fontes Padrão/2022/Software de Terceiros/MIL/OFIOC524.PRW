// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 10     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "FWCOMMAND.CH"
#Include "OFIOC524.CH"

#DEFINE MVC_STRUCT_ID        01 // Id do Field
#DEFINE MVC_STRUCT_ORDEM     02 // Ordem
#DEFINE MVC_STRUCT_TITULO    03 // Titulo do campo
#DEFINE MVC_STRUCT_DESCRICAO 04 // Descricao do campo
#DEFINE MVC_STRUCT_TIPO      05 // Tipo do campo
#DEFINE MVC_STRUCT_TAM       06 // Tamanho do campo
#DEFINE MVC_STRUCT_DEC       07 // Decimal do campo
#DEFINE MVC_STRUCT_CBOX      08 // Array	Lista de valores permitido do campo	{}		
#DEFINE MVC_STRUCT_OBRIGAT   09 // Indica se o campo tem preenchimento obrigatório
#DEFINE MVC_STRUCT_VIRTUAL   10 // Indica se o campo é virtual
#DEFINE MVC_STRUCT_PICTURE   11 // Picture
#DEFINE MVC_STRUCT_F3        12 // Consulta F3
#DEFINE MVC_STRUCT_ALTER     13 // Indica se o campo é alteravel
#DEFINE MVC_STRUCT_PASTA     14 // Pasta do campo
#DEFINE MVC_STRUCT_AGRP      15 // Agrupamento do campo

Function OFIOC524(lNoMBrowse)

Local cBkpFilial := cFilAnt
Local aArea := sGetArea(,"SB1")
Local aRegs := {}
Local bBlock

Default lNoMBrowse := .f.

Private cCadastro := STR0001
Private aRotina := MenuDef()

dbSelectArea("SB1")
If lNoMBrowse
	If ( nOpc <> 0 ) .And. !Deleted()
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
	EndIf
Else
	mBrowse( 6, 1,22,75,"SB1")
EndIf
//

sRestArea(aArea)
cFilAnt := cBkpFilial

//MsgInfo("OFIOC523 - " + cFilAnt)

Return


Function OC524Visual(cAlias,nReg,nOpc)

Local aCpoRegistro := {}
Local nAno := Year(dDataBase)
Local cPictQtd := PesqPict("SB2","B2_QATU")

Private oSizePrinc
Private oSizeFiltro
Private oSizeDet
Private oDlg524
Private obC524EncFiltro
Private obC524Demand
Private a524FldFiltro
Private aImpDemanda := {}
Private aNewBot     := {{"", {|| OC5240016_ChamadaImpressaoDemandas()}, STR0017}} // Imprimir Demandas
Private nPedPen := nFVda := nFVdaPer := nQVda := nQVdaPer := 0

// Calcula Coordenadas dos objetos
OC524CalcSize()

DEFINE MSDIALOG oDlg524 TITLE STR0001 OF oMainWnd PIXEL;
	FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4]

aCampos := { ;
		{ "B1_GRUPO"   , "" , .t. },;
		{ "B1_CODITE"  , "" , .t. },;
		{ "B1_DESC"    , "" , .t. },;
		{ "C524PARFIL" , "" , .f. }}

aCpoRegistro := {}
OC520AddField(aCampos, @a524FldFiltro, "OC524Field" )
aEval(a524FldFiltro,{ |x| &("M->" + x[2]) := OC524AtVal(x) , AADD( aCpoRegistro , x[2] ) })

obC524EncFiltro := MsmGet():New(,,2 /* Visualizar */,;
	/*aCRA*/,/*cLetras*/,/*cTexto*/,aClone(aCpoRegistro),;
	oSizeFiltro:GetObjectArea("FILTRO"), ;
	aClone(aCpoRegistro), 3 /*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlg524 , .t. /*lF3*/, .t. /* lMemoria */ , .t. /*lColumn*/,;
	/*caTela*/, .t. /*lNoFolder*/, .F. /*lProperty*/,;
	aClone(a524FldFiltro), /* aFolder */ , .f. /* lCreate */ , .t. /*lNoMDIStretch*/,/*cTela*/)
	
TButton():New( oSizeFiltro:GetDimension("BTN_ATUALIZA","LININI") + 2, oSizeFiltro:GetDimension("BTN_ATUALIZA","COLINI") + 2 ,;
	STR0007, oDlg524 , { || OC524Atu() }, 040, 010,,,.F.,.T.,.F.,,.F.,,,.F. ) // Atualizar

// -------------------------------- //
// Criacao do Listbox das Demandas  //
// -------------------------------- //
obC524Demand := TWBrowse():New( ;
	oSizeDet:GetDimension("LISTBOX","LININI"),;
	oSizeDet:GetDimension("LISTBOX","COLINI"),;
	oSizeDet:GetDimension("LISTBOX","XSIZE"), ;
	oSizeDet:GetDimension("LISTBOX","YSIZE") -20 ,,,,oDlg524,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

nSize := oSizeDet:GetDimension("LISTBOX","XSIZE")*0.08

obC524Demand:AddColumn( TCColumn():New( STR0008          , { || obC524Demand:aArray[obC524Demand:nAT,2] } ,,,,"LEFT"   , (oSizeDet:GetDimension("LISTBOX","XSIZE")*0.08),.F.,.F.,,,,.F.,) ) // Mês

obC524Demand:AddColumn( TCColumn():New( Str(nAno,4)    , { || IIF(obC524Demand:nAT==1, obC524Demand:aArray[obC524Demand:nAT,3], OC524FtVl( obC524Demand:aArray[obC524Demand:nAT,3, 1 /*vendas*/ ] ) + " (-"+ OC524FtVl(obC524Demand:aArray[obC524Demand:nAT,3, 2 /*devs*/])+")" ) } ,,,,"RIGHT",nSize,.F.,.F.,,,,.F.,) )
obC524Demand:AddColumn( TCColumn():New( ""             , { || IIF(obC524Demand:nAT==1, obC524Demand:aArray[obC524Demand:nAT,4], obC524Demand:aArray[obC524Demand:nAT,3, 3 /*compras*/ ]) } ,,,,"RIGHT",nSize,.F.,.F.,,,,.F.,) )
obC524Demand:AddColumn( TCColumn():New( ""             , { || IIF(obC524Demand:nAT==1, obC524Demand:aArray[obC524Demand:nAT,5], obC524Demand:aArray[obC524Demand:nAT,3, 4 /*Vda Perd*/ ]) } ,,,,"RIGHT",nSize,.F.,.F.,,,,.F.,) )

obC524Demand:AddColumn( TCColumn():New( Str(nAno-1,4)  , { || IIF(obC524Demand:nAT==1, obC524Demand:aArray[obC524Demand:nAT,3], OC524FtVl( obC524Demand:aArray[obC524Demand:nAT,4, 1 /*vendas*/ ] ) + " (-"+ OC524FtVl(obC524Demand:aArray[obC524Demand:nAT,4, 2 /*devs*/])+")" ) } ,,,,"RIGHT",nSize,.F.,.F.,,,,.F.,) )
obC524Demand:AddColumn( TCColumn():New( ""             , { || IIF(obC524Demand:nAT==1, obC524Demand:aArray[obC524Demand:nAT,4], obC524Demand:aArray[obC524Demand:nAT,4, 3 /*compras*/ ]) } ,,,,"RIGHT",nSize,.F.,.F.,,,,.F.,) )
obC524Demand:AddColumn( TCColumn():New( ""             , { || IIF(obC524Demand:nAT==1, obC524Demand:aArray[obC524Demand:nAT,5], obC524Demand:aArray[obC524Demand:nAT,4, 4 /*Vda Perd*/ ]) } ,,,,"RIGHT",nSize,.F.,.F.,,,,.F.,) )

obC524Demand:AddColumn( TCColumn():New( Str(nAno-2,4)  , { || IIF(obC524Demand:nAT==1, obC524Demand:aArray[obC524Demand:nAT,3], OC524FtVl( obC524Demand:aArray[obC524Demand:nAT,5, 1 /*vendas*/ ] ) + " (-"+ OC524FtVl(obC524Demand:aArray[obC524Demand:nAT,5, 2 /*devs*/])+")" ) } ,,,,"RIGHT",nSize,.F.,.F.,,,,.F.,) )
obC524Demand:AddColumn( TCColumn():New( ""             , { || IIF(obC524Demand:nAT==1, obC524Demand:aArray[obC524Demand:nAT,4], obC524Demand:aArray[obC524Demand:nAT,5, 3 /*compras*/ ]) } ,,,,"RIGHT",nSize,.F.,.F.,,,,.F.,) )
obC524Demand:AddColumn( TCColumn():New( ""             , { || IIF(obC524Demand:nAT==1, obC524Demand:aArray[obC524Demand:nAT,5], obC524Demand:aArray[obC524Demand:nAT,5, 4 /*Vda Perd*/ ]) } ,,,,"RIGHT",nSize,.F.,.F.,,,,.F.,) )

obC524Demand:AddColumn( TCColumn():New( Str(nAno-3,4)  , { || IIF(obC524Demand:nAT==1, obC524Demand:aArray[obC524Demand:nAT,3], OC524FtVl( obC524Demand:aArray[obC524Demand:nAT,6, 1 /*vendas*/ ] ) + " (-"+ OC524FtVl(obC524Demand:aArray[obC524Demand:nAT,6, 2 /*devs*/])+")" ) } ,,,,"RIGHT",nSize,.F.,.F.,,,,.F.,) )
obC524Demand:AddColumn( TCColumn():New( ""             , { || IIF(obC524Demand:nAT==1, obC524Demand:aArray[obC524Demand:nAT,4], obC524Demand:aArray[obC524Demand:nAT,6, 3 /*compras*/ ]) } ,,,,"RIGHT",nSize,.F.,.F.,,,,.F.,) )
obC524Demand:AddColumn( TCColumn():New( ""             , { || IIF(obC524Demand:nAT==1, obC524Demand:aArray[obC524Demand:nAT,5], obC524Demand:aArray[obC524Demand:nAT,6, 4 /*Vda Perd*/ ]) } ,,,,"RIGHT",nSize,.F.,.F.,,,,.F.,) )

obC524Demand:AddColumn( TCColumn():New( Str(nAno-4,4)  , { || IIF(obC524Demand:nAT==1, obC524Demand:aArray[obC524Demand:nAT,3], OC524FtVl( obC524Demand:aArray[obC524Demand:nAT,7, 1 /*vendas*/ ] ) + " (-"+ OC524FtVl(obC524Demand:aArray[obC524Demand:nAT,7, 2 /*devs*/])+")" ) } ,,,,"RIGHT",nSize,.F.,.F.,,,,.F.,) )
obC524Demand:AddColumn( TCColumn():New( ""             , { || IIF(obC524Demand:nAT==1, obC524Demand:aArray[obC524Demand:nAT,4], obC524Demand:aArray[obC524Demand:nAT,7, 3 /*compras*/ ]) } ,,,,"RIGHT",nSize,.F.,.F.,,,,.F.,) )
obC524Demand:AddColumn( TCColumn():New( ""             , { || IIF(obC524Demand:nAT==1, obC524Demand:aArray[obC524Demand:nAT,5], obC524Demand:aArray[obC524Demand:nAT,7, 4 /*Vda Perd*/ ]) } ,,,,"RIGHT",nSize,.F.,.F.,,,,.F.,) )

//obC524Demand:AddColumn( TCColumn():New( ""             , { || "" },,,, "RIGHT", nSize, .F., .F.,,,, .F.,) )

obC524Demand:nAt := 1
obC524Demand:SetArray({})

@ oSizeDet:GetDimension("LISTBOX","LININI")+oSizeDet:GetDimension("LISTBOX","YSIZE")-10,1 ;
	SAY STR0006 /*"O valor da venda já contempla o abatimento da devolução"*/ OF oDlg524 PIXEL SIZE 600,20

// ------------------------------------------- //
// CRIA QUADROS INFORMACOES DO PRODUTO         //
// ------------------------------------------- //
obC524Quadro := TScrollBox():New( oDlg524 ,;  
	oSizeDet:GetDimension("QUADROS","LININI"),;
	oSizeDet:GetDimension("QUADROS","COLINI"),;
	oSizeDet:GetDimension("QUADROS","LINEND")-oSizeDet:GetDimension("QUADROS","LININI"),;
	oSizeDet:GetDimension("QUADROS","COLEND")-oSizeDet:GetDimension("QUADROS","COLINI"),;
	.t. /* lVertical */ , .f. /* lHorizontal */ , .f. /* lBorder */ )

//
nLin    := 03
nAlt    := 12
nLar    := oSizeDet:GetDimension("QUADROS","COLEND")-oSizeDet:GetDimension("QUADROS","COLINI")-10
nColCpo := 58
nLarCpo := nLar-60
//
If ( SB1->(FieldPos("B1_CRICOD")) <> 0 )
	nAltBox := nLin+1+nAlt*4
	@ nLin-03,01 TO nAltBox,nLar LABEL "" OF obC524Quadro PIXEL
	@ nLin+01 , 05 SAY "Critical Code" OF obC524Quadro PIXEL SIZE 200,20
	TGet():New( nLin, nColCpo, { || SB1->B1_CRICOD },obC524Quadro, nLarCpo, 1, PesqPict("SB1","B1_CRICOD") ,,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"cB1CriCod",,,,.T. )
	nLin += nAlt
Else
	nAltBox := nLin+1+nAlt*3
	@ nLin-03,01 TO nAltBox,nLar LABEL "" OF obC524Quadro PIXEL
EndIf
@ nLin+01 , 05 SAY STR0009 OF obC524Quadro PIXEL SIZE 200,20 // Estoque Máximo
TGet():New( nLin, nColCpo, { || FM_PRODSBZ(SB1->B1_COD,"SB1->B1_EMAX") },obC524Quadro, nLarCpo, 1, PesqPict("SB1","B1_EMAX") ,,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"nB1EMax",,,,.T. )
nLin += nAlt
@ nLin+01 , 05 SAY STR0010 OF obC524Quadro PIXEL SIZE 200,20 // Estoque Mínimo
TGet():New( nLin, nColCpo, { || FM_PRODSBZ(SB1->B1_COD,"SB1->B1_EMIN") },obC524Quadro, nLarCpo, 1, PesqPict("SB1","B1_EMIN") ,,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"nB1EMin",,,,.T. )
nLin += nAlt
@ nLin+01 , 05 SAY STR0011 OF obC524Quadro PIXEL SIZE 200,20 // Pedido Pendente
TGet():New( nLin, nColCpo, { || nPedPen },obC524Quadro, nLarCpo, 1, cPictQtd ,,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"nPedPen",,,,.T. )
nLin += nAlt
//
nLin += 15 // Espaco entre as caixas
//
nAltBox := nLin+1+nAlt*2
@ nLin-06,01 TO nAltBox,nLar LABEL STR0012 OF obC524Quadro PIXEL // Frequência
@ nLin+01 , 05 SAY STR0013 OF obC524Quadro PIXEL SIZE 200,20 // Venda
TGet():New( nLin, nColCpo, { || nFVda },obC524Quadro, nLarCpo, 1, cPictQtd ,,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"nFVda",,,,.T. )
nLin += nAlt
@ nLin+01 , 05 SAY STR0014 OF obC524Quadro PIXEL SIZE 200,20 // Venda Perdida
TGet():New( nLin, nColCpo, { || nFVdaPer },obC524Quadro, nLarCpo, 1, cPictQtd ,,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"nFVdaPer",,,,.T. )
nLin += nAlt
//
nLin += 15 // Espaco entre as caixas
//
nAltBox := nLin+1+nAlt*2
@ nLin-06,01 TO nAltBox,nLar LABEL STR0015 OF obC524Quadro PIXEL // Quantidade
@ nLin+01 , 05 SAY STR0013 OF obC524Quadro PIXEL SIZE 200,20 // Venda
TGet():New( nLin, nColCpo, { || nQVda },obC524Quadro, nLarCpo, 1, cPictQtd ,,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"nQVda",,,,.T. )
nLin += nAlt
@ nLin+01 , 05 SAY STR0014 OF obC524Quadro PIXEL SIZE 200,20 // Venda Perdida
TGet():New( nLin, nColCpo, { || nQVdaPer },obC524Quadro, nLarCpo, 1, cPictQtd ,,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"nQVdaPer",,,,.T. )
nLin += nAlt
//

// nLin += 15 // Espaco entre as caixas

/*
nAltBox := nLin+1+nAlt*2
@ nLin-06,01 TO nAltBox,nLar LABEL "Demanda" OF obC524Quadro PIXEL
@ nLin+01 , 05 SAY "Peças" OF obC524Quadro PIXEL SIZE 200,20
TGet():New( nLin, nColCpo, { || OFC524QTD("6") },obC524Quadro, nLarCpo, 1, cPictQtd ,,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"nDemPec",,,,.T. )
nLin += nAlt
@ nLin+01 , 05 SAY "Assistência Técnica" OF obC524Quadro PIXEL SIZE 200,20
TGet():New( nLin, nColCpo, { || OFC524QTD("7") },obC524Quadro, nLarCpo, 1, cPictQtd ,,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"nDemATc",,,,.T. )
nLin += nAlt
*/


// Atualiza Controles ...
OC524Atu()
//

ACTIVATE MSDIALOG oDlg524 ON INIT EnchoiceBar(oDlg524,{||oDlg524:End()},{||oDlg524:End()},, aNewBot)

Return


Function OC524Field(cField)

Local aRetorno := Array(16)

aRetorno[MVC_STRUCT_ID       ] := cField
aRetorno[MVC_STRUCT_DEC      ] := 0
aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
aRetorno[MVC_STRUCT_VIRTUAL  ] := .T.
aRetorno[MVC_STRUCT_ALTER    ] := .F.

Do Case
Case cField == "C524PARFIL"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0018 // Filial
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0018 // Filial
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := FWSizeFilial()
	aRetorno[MVC_STRUCT_CBOX     ] := OC520RetFil(.t.)
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

EndCase

Return aRetorno


Static Function OC524AtVal(aAuxField)

Local xValue

Do Case
Case aAuxField[2] == "C524PARFIL"
	xValue := FWArrFilAtu()[SM0_CODFIL]
Case Left(aAuxField[2],3) == "B1_"
	xValue := &("SB1->" + AllTrim(aAuxField[2]))
EndCase

If xValue <> NIL
	&("M->"+aAuxField[2]) := xValue
EndIf

Return xValue

Static Function OC524Atu()
Local cBkpFilial := cFilAnt
Local aDemanda := {}
Local nCont
Local nContAux1 := 2
Local nContAux2 := 3
Local nContAux3 := 4
Local nContAux4 := 5
Local nPosAno
Local nAno := Year(dDataBase)
Local oC524Peca := DMS_Peca():New(M->B1_GRUPO,M->B1_CODITE)
Local cOrigem   := "SBL"
Local oSqlHlp := DMS_SqlHelper():New()
If TCCANOPEN(oSqlHlp:NoLock("VB8"))
	If VB8->(!Eof())
		cOrigem := "VQG"
	EndIf
EndIf

// Ajusta a cFilAnt
If Empty(M->C524PARFIL)
	// Filial vazia
	MsgAlert(STR0023, STR0024) // Favor selecionar uma Filial! / Atenção

	Return
ElseIf M->C524PARFIL <> STR0019 // TODAS
	// Filtrar por uma filial
	cFilAnt := M->C524PARFIL
EndIf

// Listbox
AADD(aDemanda, {"", "", STR0004 /* Vendas(-Dev)*/, STR0005 /*Compras*/ , STR0014 /*"Venda Perdida"*/})

// Limpando o array de Impressão das Demandas
OC5240036_LimparArrayImpressaoDemandas()

For nPosAno := 1 to 12
	AADD( aDemanda , { strzero(nPosAno,2) , UPPER(FG_CMONTH(stod("2000"+strzero(nPosAno,2)+"01"))) , {0, 0, 0, 0} , {0, 0, 0, 0} , {0, 0, 0, 0} , {0, 0, 0, 0} , {0, 0, 0, 0} } )
Next

AADD( aDemanda , {"", STR0016, {0, 0, 0, 0} , {0, 0, 0, 0} , {0, 0, 0, 0} , {0, 0, 0, 0} , {0, 0, 0, 0} } ) // TOTAL

For nPosAno := 0 to 4
	aAuxAtu := oC524Peca:GetDemanda( Iif(M->C524PARFIL == STR0019, .T., .F.), Str(nAno-nPosAno,4) ) // Uma única filial (.f.) ou todas (.t.)

	// Variáveis auxiliares
	If nPosAno > 0
		nContAux1 += 4
		nContAux2 += 4
		nContAux3 += 4
		nContAux4 += 4
	EndIf

	// Totais
	nTotV  := 0
	nTotD  := 0
	nTotC  := 0
	nTotVP := 0

	For nCont := 1 to Len(aAuxAtu)
		nPos := aScan(aDemanda,{ |x| val(x[1]) == val(aAuxAtu[nCont,4]) })
		If nPos > 1
			// Listbox
			aDemanda[nPos, 3 + nPosAno, 1] += aAuxAtu[nCont,5] - aAuxAtu[nCont,6]               // Vendas
			aDemanda[nPos, 3 + nPosAno, 2] += aAuxAtu[nCont,6]                                  // Devolucao
			aDemanda[nPos, 3 + nPosAno, 3] += IIF(LEN(aAuxAtu[nCont]) > 6, aAuxAtu[nCont,7], 0) // Compras , se conter compras mostra
			aDemanda[nPos, 3 + nPosAno, 4] += aAuxAtu[nCont,8]                                  // Venda Perdida

			// Impressão
			aImpDemanda[nPos + 1, nContAux1] += aAuxAtu[nCont,5] - aAuxAtu[nCont,6]               // Vendas
			aImpDemanda[nPos + 1, nContAux2] += aAuxAtu[nCont,6]                                  // Devolucao
			aImpDemanda[nPos + 1, nContAux3] += IIF(LEN(aAuxAtu[nCont]) > 6, aAuxAtu[nCont,7], 0) // Compras, se conter compras mostra
			aImpDemanda[nPos + 1, nContAux4] += aAuxAtu[nCont,8]                                  // Venda Perdida

			// Totais
			nTotV  += aAuxAtu[nCont,5] - aAuxAtu[nCont,6]               // Vendas
			nTotD  += aAuxAtu[nCont,6]                                  // Devolucao
			nTotC  += IIF(LEN(aAuxAtu[nCont]) > 6, aAuxAtu[nCont,7], 0) // Compras
			nTotVP += aAuxAtu[nCont,8]                                  // Venda Perdida
		else
			loop
		EndIf
	Next nCont

	// Totais por Ano
	// Listbox
	aDemanda[Len(aDemanda), 3 + nPosAno, 1] := nTotV  // Vendas
	aDemanda[Len(aDemanda), 3 + nPosAno, 2] := nTotD  // Devolucao
	aDemanda[Len(aDemanda), 3 + nPosAno, 3] := nTotC  // Compras
	aDemanda[Len(aDemanda), 3 + nPosAno, 4] := nTotVP // Venda Perdida

	// Impressão
	aImpDemanda[Len(aImpDemanda), nContAux1] := nTotV  // Vendas
	aImpDemanda[Len(aImpDemanda), nContAux2] := nTotD  // Devolucao
	aImpDemanda[Len(aImpDemanda), nContAux3] := nTotC  // Compras
	aImpDemanda[Len(aImpDemanda), nContAux4] := nTotVP // Venda Perdida
Next nPosAno

obC524Demand:nAt := 1
obC524Demand:SetArray(aDemanda)
obC524Demand:Refresh()

// Levantamento das Qtdes da Peça
nPedPen  := OC5240046_InformacoesdaPeca("1") // Pedido Pendente
nFVda    := OC5240046_InformacoesdaPeca("2") // Venda (Frequência)
nFVdaPer := OC5240046_InformacoesdaPeca("2") // Venda Perdida (Frequência)
nQVda    := OC5240046_InformacoesdaPeca("4") // Venda (Quantidade)
nQVdaPer := OC5240046_InformacoesdaPeca("5") // Venda Perdida (Quantidade)

cFilAnt := cBkpFilial
Return


Static Function OC524CalcSize()

oSizePrinc := FwDefSize():New(.t.)
oSizePrinc:aMargins := { 0 , 2 , 0 , 0 }
oSizePrinc:AddObject("SUP" , 100 , 080 , .T. , .F. )
oSizePrinc:AddObject("DETALHE" , 100 , 100 , .T. , .T. )
oSizePrinc:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
oSizePrinc:Process()	// Calcula Coordenadas

oSizeFiltro := FWDefSize():New(.f.)
oSizeFiltro:aWorkArea := oSizePrinc:GetNextCallArea("SUP")
oSizeFiltro:aMargins := { 2 , 2 , 2 , 2 }
oSizeFiltro:AddObject("FILTRO"      ,100,100,.t.,.t.)
oSizeFiltro:AddObject("BTN_ATUALIZA",045,100,.f.,.t.)
oSizeFiltro:lLateral := .t.	// Calcula em colunas
oSizeFiltro:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
oSizeFiltro:Process()

oSizeDet := FWDefSize():New(.f.)
oSizeDet:aWorkArea := oSizePrinc:GetNextCallArea("DETALHE")
oSizeDet:aMargins := { 2 , 2 , 2 , 2 }
oSizeDet:AddObject("LISTBOX" ,100,100,.t.,.t.)
oSizeDet:AddObject("QUADROS" ,150,100,.f.,.t.)
oSizeDet:lLateral := .t.	// Calcula em colunas
oSizeDet:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
oSizeDet:Process()

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFC524QTD  | Autor | Takahashi             | Data | 21/01/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Levantamento das Qtdes                                       |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFC524QTD(cTp)
Local nQtd    := 0
Local cQuery  := ""
Local cAnoSQL := strzero(year(dDataBase),4)
Local cMesSQL := strzero(month(dDataBase),2)
Local cOrigem := "SBL"
Local oSqlHlp := DMS_SqlHelper():New()
Local lNewGrpDPM := (SBM->(FieldPos('BM_VAIDPM')) > 0)
Local lVB8 := .F.

if lNewGrpDPM
	SBM->(dbSetOrder(1) )
	SBM->(dbSeek( xFilial('SBM') + SB1->B1_GRUPO ))
	lVB8 := (SBM->BM_VAIDPM == '1')
else
	if oSqlHlp:ExistTable(retsqlname('VB8'))
		if FM_SQL(' SELECT COUNT(*) FROM ' + RetSqlName('VB8') + " WHERE VB8_FILIAL = '"+xFilial('VB8')+"' AND  VB8_PRODUT = '" + SB1->B1_COD + "' AND (VB8_VDAB + VB8_VDAO) > 0  AND D_E_L_E_T_ = ' ' ") > 0
			lVB8 := .t.
		EndIf
	EndIf
EndIf

Do Case
	Case cTp == "1" // Pedido Pendente
		
		cQuery  := "SELECT COALESCE( SUM(C7_QUANT-C7_QUJE), 0) FROM " + oSqlHlp:NoLock('SC7')
		cQuery  += " WHERE C7_FILIAL = '"+xFilial('SC7')+"' AND C7_PRODUTO = '" + SB1->B1_COD + "' AND D_E_L_E_T_ = ' ' AND C7_ENCER = ' ' AND C7_RESIDUO = ' ' "
		cQuery  += " 	AND C7_QUANT > C7_QUJE "
		// Aqui jogo qualquer coisa na comparação só para ser diferentede '' e entrar todos os c7 de direct shipment
		// cQuery  += "  AND (CASE WHEN B5_ISDSHIP = '1' THEN 'DSHIP' ELSE C7_PEDFAB END) <> ' ' ) QTD_ESTENC "
		nQtd := FM_SQL(cQuery)

	Case cTp $ "2/3/4/5"
		If lVB8
			If cTp == "2" // Frequencia Venda
				cQuery := "SELECT SUM( VB8_HITSB+VB8_HITSO+VB8_HITSI )"
			ElseIf cTp == "3" // Frequencia Venda Perdida
				cQuery := "SELECT SUM( VB8_HIPERB+VB8_HIPERO+VB8_HIPERI )"
			ElseIf cTp == "4" // Quantidade Venda
				cQuery := "SELECT SUM( VB8_VDAB+VB8_VDAO+VB8_VDAI )"
			ElseIf cTp == "5" // Quantidade Venda Perdida
				cQuery := "SELECT SUM( VB8_VDPERB+VB8_VDPERO+VB8_VDPERI )"
			EndIf
			cQuery += " FROM " + oSqlHlp:NoLock("VB8")
			cQuery += " WHERE VB8_FILIAL='" + xFilial("VB8") + "' AND"
			cQuery += " VB8_PRODUT='" + SB1->B1_COD + "' AND"
			cQuery += " VB8_ANO='" + cAnoSQL + "' AND"
			cQuery += " VB8_MES='" + cMesSQL + "' AND"
			cQuery += " VB8.D_E_L_E_T_=' '"
		Else
			If cTp == "2" // Frequencia Venda
				cQuery := "SELECT BL_FREQUEN "
			ElseIf cTp == "3" // Frequencia Venda Perdida
				cQuery := "SELECT 0 "
			ElseIf cTp == "4" // Quantidade Venda
				cQuery := "SELECT BL_DEMANDA "
			ElseIf cTp == "5" // Quantidade Venda Perdida
				cQuery := "SELECT BL_VENDPER "
			EndIf
			cQuery += " FROM " + oSqlHlp:NoLock("SBL")
			cQuery += " WHERE BL_FILIAL='" + xFilial("SBL") + "' AND"
			cQuery += " BL_PRODUTO='" + SB1->B1_COD + "' AND"
			cQuery += " BL_ANO='" + cAnoSQL + "' AND"
			cQuery += " BL_MES='" + cMesSQL + "' AND"
			cQuery += " SBL.D_E_L_E_T_=' '"
		EndIf
		nQtd := FM_SQL(cQuery)
	Case cTp == "6" // Demanda Pecas

	Case cTp == "7" // Demanda Assistencia Tecnica
	
End Case
Return(nQtd)


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC524FtVl  | Autor | Vinicius Gati         | Data | 20/07/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Definicao de Menu                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OC524FtVl(nValor)
Return Transform( nValor, '@N 99999')


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | MenuDef    | Autor | Takahashi             | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Definicao de Menu                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function MenuDef()

Local aRotina:= {;
	{ STR0002 , "PesqBrw"   , 0 , 1},; // Pesquisar
	{ STR0003 , "OC524Visual"  , 0 , 2} } // Visualizar
Return aRotina

/*/{Protheus.doc} OC5240016_ChamadaImpressao
Chamada para impressão das Demandas

@author Fernando Vitor Cavani
@since 08/08/2018
@version undefined

@type function
/*/
Static Function OC5240016_ChamadaImpressaoDemandas()
Local oReport

oReport := ReportDef() // Nesta função nós definimos a estrutura do relatório, por exemplo as seções, campos, totalizadores e etc.
oReport:SetLandscape() // Define orientação de página do relatório como paisagem.
oReport:PrintDialog()  // Essa função serve para disparar a impressão do TReport, ela que faz com que seja exibida a tela de configuração de impressora e os botões de parâmetros.
Return

/*/{Protheus.doc} ReportDef
Criando o padrão para impressão das Demandas

@author Fernando Vitor Cavani
@since 08/08/2018
@version undefined

@type function
/*/
Static Function ReportDef()
Local nAno := Year(dDataBase)
Local oSection1
Local oSection2
Local oSection3

cGrupo := cCodItem := cDescricao := cFilNome := cMeses := ""

nVend1 := nVend2 := nVend3 := nVend4 := nVend5 := 0
cDev1  := cDev2  := cDev3  := cDev4  := cDev5  := ""
nComp1 := nComp2 := nComp3 := nComp4 := nComp5 := 0
nVPer1 := nVPer2 := nVPer3 := nVPer4 := nVPer5 := 0

cObservacao := ""

oReport := TReport():New("OC524R", STR0001,, {|oReport| OC5240026_ImpressaoDemandas(oReport)}) // Demandas

// Peça
oSection1 := TRSection():New(oReport ,"Peca")

// Dados da Peça e Filial selecionada
TRCell():New(oSection1, "GRUPO"    , "", RetTitle("B1_GRUPO") , "@!", 10,, {|| cGrupo }    ,,, "LEFT", .t.) // Grupo
TRCell():New(oSection1, "CODITEM"  , "", RetTitle("B1_CODITE"), "@!", 30,, {|| cCodItem }  ,,, "LEFT", .t.) // Cod Item
TRCell():New(oSection1, "DESCRICAO", "", RetTitle("B1_DESC")  , "@!", 40,, {|| cDescricao },,, "LEFT", .t.) // Descricao
TRCell():New(oSection1, "FILIAL"   , "", STR0018              , "@!", 20,, {|| cFilNome }  ,,, "LEFT", .t.) // Filial

// Demandas
oSection2 := TRSection():New(oReport, "Demandas")

// Meses do Ano
TRCell():New(oSection2, "MESES"       , "", STR0008        , "@!", 30,, {|| cMeses },,, "LEFT" , .t.) // Mês

// Ano Atual
TRCell():New(oSection2, "VENDAS1"     , "", Str(nAno,4)    , "@!",  9,, {|| nVend1 },,, "RIGHT", .t.) // Vendas
TRCell():New(oSection2, "DEVOLUCOES1" , "", ""             , "@!", 10,, {|| cDev1 } ,,, "RIGHT", .t.) // Devoluções
TRCell():New(oSection2, "COMNPRAS1"   , "", ""             , "@!",  9,, {|| nComp1 },,, "RIGHT", .t.) // Compras
TRCell():New(oSection2, "VENPERDIDAS1", "", ""             , "@!", 14,, {|| nVPer1 },,, "RIGHT", .t.) // Vendas Perdidas

// Ano Atual - 1
TRCell():New(oSection2, "VENDAS2"     , "", Str(nAno - 1,4), "@!",  9,, {|| nVend2 },,, "RIGHT", .t.) // Vendas
TRCell():New(oSection2, "DEVOLUCOES2" , "", ""             , "@!", 10,, {|| cDev2 } ,,, "RIGHT", .t.) // Devoluções
TRCell():New(oSection2, "COMNPRAS2"   , "", ""             , "@!",  9,, {|| nComp2 },,, "RIGHT", .t.) // Compras
TRCell():New(oSection2, "VENPERDIDAS2", "", ""             , "@!", 14,, {|| nVPer2 },,, "RIGHT", .t.) // Vendas Perdidas

// Ano Atual - 2
TRCell():New(oSection2, "VENDAS3"     , "", Str(nAno - 2,4), "@!",  9,, {|| nVend3 },,, "RIGHT", .t.) // Vendas
TRCell():New(oSection2, "DEVOLUCOES3" , "", ""             , "@!", 10,, {|| cDev3 } ,,, "RIGHT", .t.) // Devoluções
TRCell():New(oSection2, "COMNPRAS3"   , "", ""             , "@!",  9,, {|| nComp3 },,, "RIGHT", .t.) // Compras
TRCell():New(oSection2, "VENPERDIDAS3", "", ""             , "@!", 14,, {|| nVPer3 },,, "RIGHT", .t.) // Vendas Perdidas

// Ano Atual - 3
TRCell():New(oSection2, "VENDAS4"     , "", Str(nAno - 3,4), "@!",  9,, {|| nVend4 },,, "RIGHT", .t.) // Vendas
TRCell():New(oSection2, "DEVOLUCOES4" , "", ""             , "@!", 10,, {|| cDev4 } ,,, "RIGHT", .t.) // Devoluções
TRCell():New(oSection2, "COMNPRAS4"   , "", ""             , "@!",  9,, {|| nComp4 },,, "RIGHT", .t.) // Compras
TRCell():New(oSection2, "VENPERDIDAS4", "", ""             , "@!", 14,, {|| nVPer4 },,, "RIGHT", .t.) // Vendas Perdidas

// Ano Atual - 4
TRCell():New(oSection2, "VENDAS5"     , "", Str(nAno - 4,4), "@!",  9,, {|| nVend5 },,, "RIGHT", .t.) // Vendas
TRCell():New(oSection2, "DEVOLUCOES5" , "", ""             , "@!", 10,, {|| cDev5 } ,,, "RIGHT", .t.) // Devoluções
TRCell():New(oSection2, "COMNPRAS5"   , "", ""             , "@!",  9,, {|| nComp5 },,, "RIGHT", .t.) // Compras
TRCell():New(oSection2, "VENPERDIDAS5", "", ""             , "@!", 14,, {|| nVPer5 },,, "RIGHT", .t.) // Vendas Perdidas

// Observação
oSection3 := TRSection():New(oReport, "Observacao")

TRCell():New(oSection3, "OBSERVACAO", "", "", "@!", 100,, {|| cObservacao },,, "LEFT", .t.) // Observação
Return oReport

/*/{Protheus.doc} OC5240026_ImpressaoDemandas
Impressão das Demandas

@author Fernando Vitor Cavani
@since 08/08/2018
@version undefined

@type function
/*/
Static Function OC5240026_ImpressaoDemandas(oReport)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local oSection3 := oReport:Section(3)
Local nImp      := 0

// Impressão
// Peças
oSection1:Init()

cGrupo     := aImpDemanda[1, 1]
cCodItem   := aImpDemanda[1, 2]
cDescricao := aImpDemanda[1, 3]
cFilNome   := aImpDemanda[1, 4]

oSection1:PrintLine()
oSection1:Finish()

// Demandas
oSection2:Init()

For nImp := 2 to Len(aImpDemanda)
	// Meses do Ano
	cMeses := aImpDemanda[nImp, 1]

	// Ano Atual
	nVend1 := aImpDemanda[nImp, 2]
	cDev1  := " (-" + CValToChar(aImpDemanda[nImp, 3]) + ")"
	nComp1 := aImpDemanda[nImp, 4]
	nVPer1 := aImpDemanda[nImp, 5]

	// Ano Atual - 1
	nVend2 := aImpDemanda[nImp, 6]
	cDev2  := " (-" + CValToChar(aImpDemanda[nImp, 7]) + ")"
	nComp2 := aImpDemanda[nImp, 8]
	nVPer2 := aImpDemanda[nImp, 9]

	// Ano Atual - 2
	nVend3 := aImpDemanda[nImp, 10]
	cDev3  := " (-" + CValToChar(aImpDemanda[nImp, 11]) + ")"
	nComp3 := aImpDemanda[nImp, 12]
	nVPer3 := aImpDemanda[nImp, 13]

	// Ano Atual - 3
	nVend4 := aImpDemanda[nImp, 14]
	cDev4  := " (-" + CValToChar(aImpDemanda[nImp, 15]) + ")"
	nComp4 := aImpDemanda[nImp, 16]
	nVPer4 := aImpDemanda[nImp, 17]

	// Ano Atual - 4
	nVend5 := aImpDemanda[nImp, 18]
	cDev5  := " (-" + CValToChar(aImpDemanda[nImp, 19]) + ")"
	nComp5 := aImpDemanda[nImp, 20]
	nVPer5 := aImpDemanda[nImp, 21]

	oSection2:PrintLine()
Next

oSection2:Finish()

// Observação
oSection3:Init()

cObservacao := STR0006 // O número de vendas já contempla o abatimento da devolução

oSection3:PrintLine()
oSection3:Finish()
Return

/*/{Protheus.doc} OC5240036_LimparArrayImpressaoDemandas
Limpeza do array de Impressão das Demandas

@author Fernando Vitor Cavani
@since 09/08/2018
@version undefined

@type function
/*/
Static Function OC5240036_LimparArrayImpressaoDemandas()
Local aFilAtu  := FWArrFilAtu()
Local aSM0     := FWAllFilial(aFilAtu[3], aFilAtu[4], aFilAtu[1], .f.)
Local cFilNome := ""
Local nPosMes  := 0

// Impressão
aImpDemanda := {}

// Peças (Filtrar por uma filial ou todas)
cFilNome := Iif(M->C524PARFIL <> STR0019, FWFilialName(), STR0019) // TODAS

AADD(aImpDemanda, {   ;
	SB1->B1_GRUPO,    ; // Grupo
	SB1->B1_CODITE,   ; // Cod Item
	SB1->B1_DESC,     ; // Descricao
	cFilNome,         ; // Filial
	"", "", "", "",   ;
	"", "", "", "",   ;
	"", "", "", "",   ;
	"", "", "", "", "";
})

// Cabeçalho Demandas
AADD(aImpDemanda, {                    ;
	"",                                ;
	STR0020, STR0021, STR0025, STR0022,; // Vda. / Dev / Cpa. / Vda.Per
	STR0020, STR0021, STR0025, STR0022,; // Vda. / Dev / Cpa. / Vda.Per
	STR0020, STR0021, STR0025, STR0022,; // Vda. / Dev / Cpa. / Vda.Per
	STR0020, STR0021, STR0025, STR0022,; // Vda. / Dev / Cpa. / Vda.Per
	STR0020, STR0021, STR0025, STR0022 ; // Vda. / Dev / Cpa. / Vda.Per
})

// Meses do Ano e Total
For nPosMes := 1 to 13
	AADD(aImpDemanda, {                                                                         ;
		Iif(nPosMes == 13, STR0016, UPPER(FG_CMONTH(stod("2000" + strzero(nPosMes,2) + "01")))),; // TOTAL
		0, 0, 0, 0,                                                                             ;
		0, 0, 0, 0,                                                                             ;
		0, 0, 0, 0,                                                                             ;
		0, 0, 0, 0,                                                                             ;
		0, 0, 0, 0                                                                              ;
	})
Next
Return

/*/{Protheus.doc} OC5240046_InformacoesdaPeca
Chamada para a função de Levantamento das Qtdes da Peça

@author Fernando Vitor Cavani
@since 09/08/2018
@version undefined
@param  cTipo, numerico, Tipo do Levantamento das Qtdes
@return nQtd , numerico, Qtde total levantado da Peça
@type function
/*/
Static Function OC5240046_InformacoesdaPeca(cTipo)
Local aFilAtu    := FWArrFilAtu()
Local aSM0       := FWAllFilial(aFilAtu[3], aFilAtu[4], aFilAtu[1], .f.)
Local cBkpFilial := cFilAnt
Local ni         := 0
Local nQtd       := 0

Default cTipo := ""

If cTipo <> ""
	If M->C524PARFIL <> STR0019 // TODAS
		// Filtrar por uma filial
		nQtd := OFC524QTD(cTipo)
	Else
		// TODAS
		For ni := 1 to Len(aSM0)
			cFilAnt := aSM0[ni]

			nQtd += OFC524QTD(cTipo)
		Next
	EndIf
EndIf

cFilAnt := cBkpFilial
Return(nQtd)
