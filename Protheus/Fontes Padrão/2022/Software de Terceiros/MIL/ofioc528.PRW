#Include "PROTHEUS.CH"
#Include "FWCOMMAND.CH"
#Include "OFIOC528.CH"


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

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  13/11/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007398_1"

Function OFIOC528(lNoMBrowse)

Local cBkpFilial := cFilAnt
Local aArea := sGetArea(,"SB1")

Local bBlock

Private cCadastro   := STR0001
Private aRotina     := MenuDef()
Private cFaseConfer := Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao 
Private nQtdTot     := 0 // Quantidade Total
Private nVlrTot     := 0 // Valor Total

Default lNoMBrowse  := .f.

//AADD(aRegs,{STR0004,STR0004,STR0004,'MV_CH1','N',3,0,,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})

dbSelectArea("SB1")
If lNoMBrowse
	If ( nOpc <> 0 ) .And. !Deleted()
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
	EndIf
Else
	SetKey(VK_F12,{ || Pergunte( "OFIOC528" , .T. ,,,,.f.)})
	mBrowse( 6, 1,22,75,"SB1")
	SetKey( VK_F12, Nil )
EndIf
//
sRestArea(aArea)
cFilAnt := cBkpFilial

Return


Function OC528Visual(cAlias,nReg,nOpc)

Local aCpoRegistro := {}

Private oSizePrinc
Private oSizeFiltro

Private oDlg528
Private obC528EncFiltro
Private obC528Transf

Private a528FldFiltro

Private oBran     := LoadBitmap( GetResources() , "BR_BRANCO" )
Private oVerd     := LoadBitmap( GetResources() , "BR_VERDE" )
Private oPret     := LoadBitmap( GetResources() , "BR_PRETO" )
Private oVerm     := LoadBitmap( GetResources() , "BR_VERMELHO" )
Private oAzul     := LoadBitmap( GetResources() , "BR_AZUL" )
Private oNada

Static oC528Peca := MIL_PecaDao():New()
oC528Peca:SetGrupo(SB1->B1_GRUPO)
oC528Peca:SetCodigo(SB1->B1_CODITE)

// Calcula Coordenadas dos objetos
OC528CalcSize()

DEFINE MSDIALOG oDlg528 TITLE STR0001 OF oMainWnd PIXEL;
	FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4]

aCampos := { ;
		{ "B1_GRUPO"   , "" , .t. },;
		{ "B1_CODITE"  , "" , .t. },;
		{ "B1_DESC"    , "" , .t. },;
		{ "C528DTINI"  , "" , .f. },;
		{ "C528DTFIM"  , "" , .f. },;
		{ "C528TIPTRA" , "" , .f. },;
		{ "C528ORCVDA" , "" , .f. },;
		{ "C528FILORI" , "" , .f. },;
		{ "C528FILDES" , "" , .f. },;
		{ "C528LOCORI" , "" , .f. },;
		{ "C528LOCDES" , "" , .f. },;
		{ "C528STATUS" , "" , .f. }}

aCpoRegistro := {}
OC520AddField(aCampos, @a528FldFiltro, "OC528Field" )
aEval(a528FldFiltro,{ |x| &("M->" + x[2]) := OC528AtVal(x) , AADD( aCpoRegistro , x[2] ) })

obC528EncFiltro := MsmGet():New(,,2 /* Visualizar */,;
	/*aCRA*/,/*cLetras*/,/*cTexto*/,aClone(aCpoRegistro),;
	oSizeFiltro:GetObjectArea("FILTRO"), ;
	aClone(aCpoRegistro), 3 /*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlg528 , .t. /*lF3*/, .t. /* lMemoria */ , .t. /*lColumn*/,;
	/*caTela*/, .t. /*lNoFolder*/, .F. /*lProperty*/,;
	aClone(a528FldFiltro), /* aFolder */ , .f. /* lCreate */ , .t. /*lNoMDIStretch*/,/*cTela*/)
	
TButton():New( oSizeFiltro:GetDimension("BTN_ATUALIZA","LININI") + 02, oSizeFiltro:GetDimension("BTN_ATUALIZA","COLINI") + 2 ,;
	STR0032, oDlg528 , { || OC528Atu() }, 052, 010,,,.F.,.T.,.F.,,.F.,,,.F. ) // Atualizar

TButton():New( oSizeFiltro:GetDimension("BTN_ATUALIZA","LININI") + 15, oSizeFiltro:GetDimension("BTN_ATUALIZA","COLINI") + 2 ,;
	STR0033, oDlg528 , { || OM430LEG() }, 052, 010,,,.F.,.T.,.F.,,.F.,,,.F. ) // Legenda

@ oSizeFiltro:GetDimension("BTN_ATUALIZA","LININI") + 51 , oSizeFiltro:GetDimension("BTN_ATUALIZA","COLINI") + 1 ;
	SAY STR0034 SIZE 50,8 OF oDlg528 PIXEL COLOR CLR_BLUE // Qtd.Total
@ oSizeFiltro:GetDimension("BTN_ATUALIZA","LININI") + 60 , oSizeFiltro:GetDimension("BTN_ATUALIZA","COLINI") + 1 ;
	MSGET oQtdTot VAR nQtdTot PICTURE PesqPict("VS3","VS3_QTDITE") SIZE 55,10 OF oDlg528 PIXEL COLOR CLR_BLUE WHEN .f.

@ oSizeFiltro:GetDimension("BTN_ATUALIZA","LININI") + 86 , oSizeFiltro:GetDimension("BTN_ATUALIZA","COLINI") + 1 ;
	SAY STR0035 SIZE 50,8 OF oDlg528 PIXEL COLOR CLR_BLUE // Total Geral
@ oSizeFiltro:GetDimension("BTN_ATUALIZA","LININI") + 95 , oSizeFiltro:GetDimension("BTN_ATUALIZA","COLINI") + 1 ;
	MSGET oVlrTot VAR nVlrTot PICTURE PesqPict("VS3","VS3_VALTOT") SIZE 55,10 OF oDlg528 PIXEL COLOR CLR_BLUE WHEN .f.


// ------------------------------------- //
// Criacao do Listbox das NF's de Compra //
// ------------------------------------- //
obC528Transf := TWBrowse():New( ;
	oSizePrinc:GetDimension("TRANSFS","LININI"),;
	oSizePrinc:GetDimension("TRANSFS","COLINI"),;
	oSizePrinc:GetDimension("TRANSFS","XSIZE"), ;
	oSizePrinc:GetDimension("TRANSFS","YSIZE") ,,,,oDlg528,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

obC528Transf:addColumn( TCColumn():New( "", { || IIf(obC528Transf:aArray[obC528Transf:nAT,1]=="0",oBran,IIf(obC528Transf:aArray[obC528Transf:nAT,1]==cFaseConfer,oVerd,IIf(obC528Transf:aArray[obC528Transf:nAT,1]=="F",oPret,IIf(obC528Transf:aArray[obC528Transf:nAT,1]=="X",oVerm,IIf(obC528Transf:aArray[obC528Transf:nAT,1]=="C",oAzul,oNada))))) } ,,,,"LEFT" ,08,.T.,.F.,,,,.F.,) ) // Cor 1
obC528Transf:AddColumn( TCColumn():New( STR0005 , { || Transform(obC528Transf:aArray[obC528Transf:nAT,02],"@D") } ,,,,"LEFT"   ,040,.F.,.F.,,,,.F.,) ) // Data
obC528Transf:AddColumn( TCColumn():New( STR0006 , { || obC528Transf:aArray[obC528Transf:nAT,03] }                 ,,,,"LEFT"   ,040,.F.,.F.,,,,.F.,) ) // Orç.Transf.
obC528Transf:AddColumn( TCColumn():New( STR0007 , { || obC528Transf:aArray[obC528Transf:nAT,04] }                 ,,,,"LEFT"   ,040,.F.,.F.,,,,.F.,) ) // Orç.Venda
obC528Transf:AddColumn( TCColumn():New( STR0008 , { || obC528Transf:aArray[obC528Transf:nAT,05] }                 ,,,,"LEFT"   ,050,.F.,.F.,,,,.F.,) ) // Filial Origem
obC528Transf:AddColumn( TCColumn():New( STR0009 , { || obC528Transf:aArray[obC528Transf:nAT,06] }                 ,,,,"LEFT"   ,050,.F.,.F.,,,,.F.,) ) // Filial Destino
obC528Transf:AddColumn( TCColumn():New( STR0010 , { || obC528Transf:aArray[obC528Transf:nAT,07] }                 ,,,,"LEFT"   ,050,.F.,.F.,,,,.F.,) ) // Local Origem
obC528Transf:AddColumn( TCColumn():New( STR0011 , { || obC528Transf:aArray[obC528Transf:nAT,08] }                 ,,,,"LEFT"   ,050,.F.,.F.,,,,.F.,) ) // Local Destino
obC528Transf:AddColumn( TCColumn():New( STR0012 , { || Transform(obC528Transf:aArray[obC528Transf:nAT,09], PesqPict("VS3","VS3_QTDITE")) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // Quantidade
obC528Transf:AddColumn( TCColumn():New( STR0013 , { || Transform(obC528Transf:aArray[obC528Transf:nAT,10], PesqPict("VS3","VS3_VALPEC")) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // Vlr.Unitario
obC528Transf:AddColumn( TCColumn():New( STR0014 , { || Transform(obC528Transf:aArray[obC528Transf:nAT,11], PesqPict("VS3","VS3_VALTOT")) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // Vlr.Total
obC528Transf:AddColumn( TCColumn():New( STR0015 , { || obC528Transf:aArray[obC528Transf:nAT,12] }                 ,,,,"LEFT"   ,050,.F.,.F.,,,,.F.,) ) // NF Saida/Entrada
obC528Transf:AddColumn( TCColumn():New( STR0016 , { || Transform(obC528Transf:aArray[obC528Transf:nAT,13],"@D") } ,,,,"LEFT"   ,040,.F.,.F.,,,,.F.,) ) // Data NF
obC528Transf:AddColumn( TCColumn():New( STR0017 , { || obC528Transf:aArray[obC528Transf:nAT,14] }                 ,,,,"LEFT"   ,080,.F.,.F.,,,,.F.,) ) // Status NF
//
obC528Transf:nAt := 1
obC528Transf:SetArray({})

// Atualiza Controles ...
OC528Atu()
//

ACTIVATE MSDIALOG oDlg528 ON INIT EnchoiceBar(oDlg528,{||oDlg528:End()},{||oDlg528:End()})

Return


Function OC528Field(cField)

Local aRetorno := Array(16)

aRetorno[MVC_STRUCT_ID       ] := cField
aRetorno[MVC_STRUCT_DEC      ] := 0
aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
aRetorno[MVC_STRUCT_VIRTUAL  ] := .T.
aRetorno[MVC_STRUCT_ALTER    ] := .F.

Do Case

Case cField == "C528DTINI"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0018 // Dt.Inicial
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0018 // Dt.Inicial
	aRetorno[MVC_STRUCT_TIPO     ] := "D"
	aRetorno[MVC_STRUCT_TAM      ] := 08
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C528DTFIM"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0019 // Dt.Final
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0019 // Dt.Final
	aRetorno[MVC_STRUCT_TIPO     ] := "D"
	aRetorno[MVC_STRUCT_TAM      ] := 08
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C528TIPTRA"
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("VS3_TIPTRA")
	aRetorno[MVC_STRUCT_TITULO   ] := STR0020 // Transferencia
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0020 // Transferencia
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := 1
	aRetorno[MVC_STRUCT_CBOX     ] := SX3->X3_CBOX
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C528ORCVDA"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0021 // Orçamento de Venda
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0021 // Orçamento de Venda
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := 1
	aRetorno[MVC_STRUCT_CBOX     ] := "0="+STR0022+";1="+STR0023 // SEM vinculo / COM vinculo
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C528FILORI"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0008 // Filial Origem
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0008 // Filial Origem
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := FWSizeFilial()
	aRetorno[MVC_STRUCT_CBOX     ] := OC520RetFil()
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C528FILDES"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0009 // Filial Destino
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0009 // Filial Destino
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := FWSizeFilial()
	aRetorno[MVC_STRUCT_CBOX     ] := OC520RetFil()
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C528LOCORI"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0010 // Local Origem
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0010 // Local Origem
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := 120
	aRetorno[MVC_STRUCT_CBOX     ] := OC528RetLoc()
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C528LOCDES"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0011 // Local Destino
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0011 // Local Destino
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := 120
	aRetorno[MVC_STRUCT_CBOX     ] := OC528RetLoc()
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C528STATUS"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0024 // Status
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0024 // Status
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := 120
	aRetorno[MVC_STRUCT_CBOX     ] := "0="+STR0025+";"+cFaseConfer+"="+STR0026+";F="+STR0027+";X="+STR0028+";C="+STR0029 // Orçamento Digitado / Aguardando conferencia / Conferido / Transferido / Cancelado
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

EndCase

Return aRetorno


Static Function OC528AtVal(aAuxField)
Local xValue
Do Case
	Case aAuxField[2] == "C528DTINI"
		Pergunte( "OFIOC528",.F.,,,,.f.)
		xValue := dDataBase - MV_PAR01
	Case aAuxField[2] == "C528DTFIM"
		xValue := dDataBase
	Case aAuxField[2] == "C528TIPTRA"
		xValue := " "
	Case aAuxField[2] == "C528ORCVDA"
		xValue := " "
	Case aAuxField[2] == "C528FILORI"
		xValue := space(FWSizeFilial())
	Case aAuxField[2] == "C528FILDES"
		xValue := FWArrFilAtu()[SM0_CODFIL]
	Case aAuxField[2] == "C528LOCORI"
		xValue := space(2)
	Case aAuxField[2] == "C528LOCDES"
		xValue := space(2)
	Case aAuxField[2] == "C528STATUS"
		xValue := " "
	Case Left(aAuxField[2],3) == "B1_"
		xValue := &("SB1->" + AllTrim(aAuxField[2]))	
EndCase
If xValue <> NIL
	&("M->"+aAuxField[2]) := xValue
EndIf
Return xValue

Static Function OC528Atu()
Local lOk       := .t.
Local nPos      := 0
Local cSQL      := ""
Local cAuxAlias := "TOC528"
Local aTransfs  := {}
Local oSqlHlp   := DMS_SqlHelper():New()
Local aFilAtu   := FWArrFilAtu()
Local aFilVS1   := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local aSM0      := {}
Local cNFStatus := ""

nQtdTot     := 0 // Quantidade Total
nVlrTot     := 0 // Valor Total

For nPos := 1 to len(aFilVS1)
	lOk := .t.
	If !Empty(M->C528FILORI) .and. M->C528FILORI <> aFilVS1[nPos]
		lOk := .f.
	EndIf
	If lOk
		cFilAnt := aFilVS1[nPos]
		aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt)
		//
		cSQL := "SELECT DISTINCT VS3.R_E_C_N_O_ RECVS3 , "
		cSQL += "VS1.VS1_STATUS , VS1.VS1_DATORC , VS1.VS1_NUMORC , VDD.VDD_NUMORC , "
		cSQL += "VS1.VS1_FILIAL , VS1.VS1_FILDES , VS3.VS3_ARMORI , VS1.VS1_ARMDES , "
		cSQL += "VS3.VS3_QTDITE , VS3.VS3_QTDINI , VS3.VS3_VALPEC , "
		cSQL += "VS1.VS1_NUMNFI , VS1.VS1_SERNFI , SF1.F1_EMISSAO , SF1.F1_STATUS "
		cSQL += "  FROM " + oSqlHlp:NoLock("VS1") + " "
		cSQL += "  JOIN " + oSqlHlp:NoLock("VS3") + " ON ( VS3.VS3_FILIAL=VS1.VS1_FILIAL AND VS3.VS3_NUMORC=VS1.VS1_NUMORC AND VS3.VS3_GRUITE='"+M->B1_GRUPO+"' AND VS3.VS3_CODITE='"+M->B1_CODITE+"' AND VS3.D_E_L_E_T_=' ' ) "
		cSQL += " LEFT JOIN " + oSqlHlp:NoLock("VDD") + " ON ( VDD.VDD_FILIAL='"+xFilial("VDD")+"' AND VDD.VDD_FILPED=VS1.VS1_FILIAL AND VDD.VDD_ORCFOR=VS1.VS1_NUMORC AND VDD.VDD_GRUPO='"+M->B1_GRUPO+"' AND VDD.VDD_CODITE='"+M->B1_CODITE+"' AND VDD.D_E_L_E_T_=' ' ) "
		cSQL += " LEFT JOIN " + oSqlHlp:NoLock("SA2") + " ON ( SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_CGC='"+aSM0[18]+"' AND SA2.D_E_L_E_T_=' ' ) "
		cSQL += " LEFT JOIN " + oSqlHlp:NoLock("SF1") + " ON ( SF1.F1_FILIAL=VS1.VS1_FILDES AND SF1.F1_DOC=VS1.VS1_NUMNFI AND SF1.F1_SERIE=VS1.VS1_SERNFI AND SF1.F1_FORNECE=SA2.A2_COD AND SF1.F1_LOJA=SA2.A2_LOJA ) "
		cSQL += " WHERE VS1.VS1_FILIAL = '" + xFilial("VS1") + "'"
		cSQL += "   AND VS1.VS1_TIPORC = '3'"
		cSQL += "   AND VS1.VS1_DATORC >= '"+dtos(M->C528DTINI)+"' AND VS1.VS1_DATORC <= '"+dtos(M->C528DTFIM)+"'"
		If !Empty(M->C528STATUS)
			cSQL += " AND VS1.VS1_STATUS = '"+M->C528STATUS+"'"
		Else
			cSQL += " AND VS1.VS1_STATUS IN ('0','"+cFaseConfer+"','F','X','C')"
		EndIf
		If !Empty(M->C528FILDES)
			cSQL += " AND VS1.VS1_FILDES = '"+M->C528FILDES+"'"
		EndIf
		If !Empty(M->C528LOCDES)
			cSQL += " AND VS1.VS1_ARMDES = '"+M->C528LOCDES+"'"
		EndIf
		If !Empty(M->C528TIPTRA)
			cSQL += " AND VS3.VS3_TIPTRA = '"+M->C528TIPTRA+"'"
		EndIf
		If !Empty(M->C528LOCORI)
			cSQL += " AND VS3.VS3_ARMORI = '"+M->C528LOCORI+"'"
		EndIf
		cSQL += " AND VS1.D_E_L_E_T_ = ' '"
		cSQL += " ORDER BY VS1.VS1_DATORC , VS1.VS1_NUMORC"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAuxAlias , .F., .T. )
		While !(cAuxAlias)->(Eof())
			lOk := .t.
			If !Empty(M->C528ORCVDA)
				lOk := .f.
				If M->C528ORCVDA == "0" // SEM vinculo ao Orcamento de Venda
					If Empty((cAuxAlias)->( VDD_NUMORC )) .or. left((cAuxAlias)->( VDD_NUMORC ),1) == "P"
						lOk := .t.
					EndIf
				ElseIf M->C528ORCVDA == "1" // COM vinculo ao Orcamento de Venda
					If !Empty((cAuxAlias)->( VDD_NUMORC )) .and. left((cAuxAlias)->( VDD_NUMORC ),1) <> "P"
						lOk := .t.
					EndIf
				EndIf			
			EndIf
			If lOk
				cNFStatus := ""
				If !Empty((cAuxAlias)->( F1_EMISSAO))
					If (cAuxAlias)->( F1_STATUS ) $ "N.A"
						cNFStatus := STR0030 // NF classificada
					Else
						cNFStatus := STR0031 // NF não classificada
					EndIf
				EndIf
				nQtd := (cAuxAlias)->( VS3_QTDITE )
				If (cAuxAlias)->( VS3_QTDINI ) < nQtd .and. (cAuxAlias)->( VS3_QTDINI ) > 0
					nQtd := (cAuxAlias)->( VS3_QTDINI ) // Alguns casos tem que pegar o QTDINI pq foi alterado na tela de divergencia dentro da transferencia
				EndIf
				AADD(aTransfs, {;
					(cAuxAlias)->( VS1_STATUS ) ,;
					stod((cAuxAlias)->( VS1_DATORC )) ,;
					(cAuxAlias)->( VS1_NUMORC ) ,;
					(cAuxAlias)->( VDD_NUMORC ) ,;
					(cAuxAlias)->( VS1_FILIAL ) ,;
					(cAuxAlias)->( VS1_FILDES ) ,;
					(cAuxAlias)->( VS3_ARMORI ) ,;
					(cAuxAlias)->( VS1_ARMDES ) ,;
					nQtd ,;
					(cAuxAlias)->( VS3_VALPEC ) ,;
					( nQtd * (cAuxAlias)->( VS3_VALPEC ) ) ,;
					IIf(!Empty((cAuxAlias)->( VS1_NUMNFI )),(cAuxAlias)->( VS1_NUMNFI )+"-"+(cAuxAlias)->( VS1_SERNFI ),"") ,;
					IIf(!Empty((cAuxAlias)->( F1_EMISSAO )),stod((cAuxAlias)->( F1_EMISSAO )),"") ,;
					cNFStatus })
				//
				nQtdTot += nQtd
				nVlrTot += ( nQtd * (cAuxAlias)->( VS3_VALPEC ) )
				//
			EndIf
			(cAuxAlias)->(dbSkip())
		End
		(cAuxAlias)->(dbCloseArea())
	EndIf
Next
If Len(aTransfs) <= 0
	AADD(aTransfs, { "" , ctod("") , "" , "" , "" , "" , "" , "" , 0 , 0 , 0 , "" , ctod("") , "" })
EndIf
dbSelectArea("VS3")
obC528Transf:nAt := 1
obC528Transf:SetArray(aTransfs)
obC528Transf:Refresh()
//
oQtdTot:Refresh()
oVlrTot:Refresh()
//
Return


Static Function OC528CalcSize()

oSizePrinc := FwDefSize():New(.t.)
oSizePrinc:aMargins := { 0 , 2 , 0 , 0 }
oSizePrinc:AddObject("SUP" , 100 , 113 , .T. , .F. )
oSizePrinc:AddObject("TRANSFS" , 100 , 100 , .T. , .T. )
oSizePrinc:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
oSizePrinc:Process()	// Calcula Coordenadas

oSizeFiltro := FWDefSize():New(.f.)
oSizeFiltro:aWorkArea := oSizePrinc:GetNextCallArea("SUP")
oSizeFiltro:aMargins := { 2 , 2 , 2 , 2 }
oSizeFiltro:AddObject("FILTRO"      ,100,100,.t.,.t.)
oSizeFiltro:AddObject("BTN_ATUALIZA",055,100,.f.,.t.)
oSizeFiltro:lLateral := .t.	// Calcula em colunas
oSizeFiltro:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
oSizeFiltro:Process()

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC528RetLoc| Autor | Andre Luis Almeida    | Data | 22/02/17 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Retorna o Local                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OC528RetLoc()
Local cRet      := ""
Local cQuery    := ""
Local cAuxAlias := "SQLNNR"
Local oSqlHlp   := DMS_SqlHelper():New()
cQuery := "SELECT DISTINCT NNR_CODIGO , NNR_DESCRI "
cQuery +=  " FROM " + oSqlHlp:NoLock("NNR") + " "
cQuery += " WHERE NNR_FILIAL = '" + xFilial("NNR") + "'"
cQuery +=   " AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
While !(cAuxAlias)->(Eof())
	cRet += (cAuxAlias)->( NNR_CODIGO )+"="+Alltrim((cAuxAlias)->( NNR_DESCRI ))+";"
	(cAuxAlias)->(dbSkip())
End
(cAuxAlias)->(dbCloseArea())
If !Empty(cRet)
	cRet := left(cRet,len(cRet)-1)
EndIf
Return cRet

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
	{ STR0002 , "PesqBrw"      , 0 , 1},; // Pesquisar
	{ STR0003 , "OC528Visual"  , 0 , 2} } // Visualizar
Return aRotina