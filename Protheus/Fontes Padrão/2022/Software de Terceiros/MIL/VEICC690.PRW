////////////////
// Versao 02  //
////////////////

#include "PROTHEUS.CH"
#include "VEICC690.CH"

/*/{Protheus.doc} VEICC690

	@author       Vinicius Gati
	@since        01/11/2014
	@description  Relatório "Andamento das Metas de Venda"

/*/
Function VEICC690()
	Private oHlp     := Mil_ArrayHelper():New()
	Private oSqlH    := Mil_SqlHelper():New()
	Private oMetas   := Mil_MetasDeInteresseDAO():New()
	Private aMetas   := {}
	Private aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
	Private oVerm    := LoadBitmap( GetResources() , "BR_VERMELHO" )  // Nada atendido
	Private oAmar    := LoadBitmap( GetResources() , "BR_AMARELO"  )  // Parcialmente atendido
	Private oVerd    := LoadBitmap( GetResources() , "BR_VERDE"    )  // Atendido
	Private oCampDAO := Mil_CampanhaDAO():New()

	FS_GtParametros()

	FS_UILoad()
	
	SetKey(VK_F7, nil)
	SetKey(VK_F8, nil)
Return


/*/{Protheus.doc} FS_UILoad

	@author       Vinicius Gati
	@since        01/11/2014
	@description  Desenha a interface com usuario

/*/
Static Function FS_UILoad()
	Local aObjects := {} , aPosObj := {} , aInfo := {}
	cCodCamp       := SPACE(TAMSX3("VDY_CAMPOP")[1])
	cCodVendedor   := SPACE(TAMSX3("VDY_CODVEN")[1])
	cCodMarca      := SPACE(TAMSX3("VDY_CODMAR")[1])
	cCodModelo     := SPACE(TAMSX3("VDY_MODVEI")[1])
	cMes           := "  "
	cAno           := "    "
	aAcoesRel      := {;
		{ "PARAMETROS", {|| Pergunte('VCC690'), oLbMetas:Refresh() }, ("<F7> "+ STR0001) },;
		{ "PARAMETROS", {|| FS_MetasLeg() }, ("<F8> "+ STR0020) };
	}
	SetKey(VK_F7, {|| Pergunte('VCC690'), oLbMetas:Refresh() }) // setando a configuracao de parametros no atalho F7
	SetKey(VK_F8, {|| FS_MetasLeg() }) // setando a configuracao de parametros no atalho F7
	AAdd( aObjects, { 01 , 26 , .T. , .F. } ) // Filtro
	AAdd( aObjects, { 01 , 10 , .T. , .T. } ) // ListBox
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)

	//"Relatório 'Andamento das Metas de Venda'"
	DEFINE MSDIALOG oWindow TITLE STR0002 FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	//
	@ aPosObj[1,1] + 002 , aPosObj[1,2] TO aPosObj[1,3] , aPosObj[1,4] LABEL "Filtro" OF oWindow PIXEL // label bloco
	
	M->VDM_CAMPOP := cCodCamp
	// filtro campanha
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 008 SAY (STR0003) OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 040 MSGET oGtCodCamp VAR M->VDM_CAMPOP PICTURE "@!" F3 "VX5" SIZE 15,08 OF oWindow PIXEL HASBUTTON
	// filtro mes
	@ aPosObj[1,1] + 012 , aPosObj[1,2] +  80 SAY (STR0004) OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] +  95 MSGET oGtMes VAR cMes PICTURE "@R 99" SIZE 20,08 OF oWindow PIXEL HASBUTTON
	// filtro ano
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 120 SAY (STR0005) OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 135 MSGET oGtAno VAR cAno PICTURE "@R 9999" SIZE 30,08 OF oWindow PIXEL HASBUTTON
	// filtro vendedor
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 170 SAY (STR0006) OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 200 MSGET oGtVendedor VAR cCodvendedor PICTURE "@!" F3 "SA3" SIZE 35,08 OF oWindow PIXEL HASBUTTON
	// filtro marca
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 235 SAY (STR0007) OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 255 MSGET oGtMarca VAR cCodMarca PICTURE "@!" F3 "VE1" SIZE 35,08 OF oWindow PIXEL HASBUTTON
	// filtro modelo
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 290 SAY (STR0008) OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 310 MSGET oGtModelo VAR cCodModelo PICTURE "@!" F3 "VV2" SIZE 115,08 OF oWindow PIXEL HASBUTTON

	@ aPosObj[1,1] + 011 , aPosObj[1,4] - 060 BUTTON oFiltra PROMPT STR0019 OF oWindow SIZE 50,10 PIXEL ACTION FS_Buscar()
	//
	aLBHeader := {}
	@ aPosObj[2,1] + 000 , aPosObj[2,2] + 000 LISTBOX oLbMetas ;
		FIELDS ;
		HEADER   " ", STR0009, STR0003,  STR0004+"/"+STR0005, STR0006, STR0007,  STR0008, STR0010, STR0011, STR0012, STR0021, STR0022 ;
		COLSIZES  35,      30,      100,                  30,     120,      40,      100,      35,      55,      55,      55,      55 ;
		SIZE aPosObj[2,4]-2,aPosObj[2,3]-aPosObj[2,1] OF oWindow PIXEL ;
		ON DBLCLICK FS_DblClick()
	oLbMetas:SetArray(aMetas)
	oLbMetas:bLine        := FS_Valores()
	oLbMetas:bHeaderClick := FS_HeaderClick()
	//
	ACTIVATE MSDIALOG oWindow ON INIT (EnchoiceBar(oWindow, {|| lOk:=.t., oWindow:End() }, { || oWindow:End() },,aAcoesRel))

Return .T.

/*/{Protheus.doc} FS_DblClick

	@author       Vinicius Gati
	@since        01/11/2014
	@description  Evento double click do grid

/*/
Static Function FS_DblClick()
Return .T.

/*/{Protheus.doc} FS_HeaderClick

	@author       Vinicius Gati
	@since        01/11/2014
	@description  Evento header click do grid

/*/
Static Function FS_HeaderClick()  
Return { |oObj,nCol| IIf( nCol == 1, FS_MetasLeg(), Nil) }

/*/{Protheus.doc} FS_Valores

	@author       Vinicius Gati
	@since        01/11/2014
	@description  Indica os valores mostrados em cada coluna do listbox

/*/
Static Function FS_Valores()
Return { || IIF(LEN(oLbMetas:aArray) < oLbMetas:nAt, {oVerd,"","","","","","","","","", "", ""},;
	{ ;
		FS_ShowStatus(oLbMetas:aArray[oLbMetas:nAt])              ,;
		oLbMetas:aArray[oLbMetas:nAt]:cCodigo                     ,;
		FS_GTCampanha(oLbMetas:aArray[oLbMetas:nAt]:cCodCampanha) ,;
		oLbMetas:aArray[oLbMetas:nAt]:cMesCampanha + "/" + oLbMetas:aArray[oLbMetas:nAt]:cAnoCampanha,;
		FS_GTSeller(oLbMetas:aArray[oLbMetas:nAt]:cCodVendedor)   ,;
		oLbMetas:aArray[oLbMetas:nAt]:cCodMarca                   ,;
		FS_GTModelo(oLbMetas:aArray[oLbMetas:nAt]:cCodModelo)     ,;
		FG_AlinVlrs(Transform(oLbMetas:aArray[oLbMetas:nAt]:nQtd, "@E 9999"))  ,;
		FS_IntFmtCol(oLbMetas:aArray[oLbMetas:nAt])               ,;
		FS_ValidFmtCol(oLbMetas:aArray[oLbMetas:nAt])             ,;
		FS_CancFmtCol(oLbMetas:aArray[oLbMetas:nAt])              ,;
		FS_FatFmtCol(oLbMetas:aArray[oLbMetas:nAt])                ;
	})}

//FG_AlinVlrs(Transform(aDia[oLbDia:nAt,3],"@E 9999,999"))

/*/{Protheus.doc} FS_Buscar

	@author       Vinicius Gati
	@since        01/11/2014
	@description  Busca os dados de Interesses

/*/
Static Function FS_Buscar()
	Local aFiltro := {;
		{'mes'             , cMes          },;
		{'ano'             , cAno          },;
		{'codigo_campanha' , M->VDM_CAMPOP },;
		{'codigo_vendedor' , cCodVendedor  },;
		{'codigo_marca'    , cCodMarca     },;
		{'codigo_modelo'   , cCodModelo    } ;
	}
	oLbMetas:SetArray( oMetas:Buscar(aFiltro, .T.) )
	oLbMetas:bLine := FS_Valores()
	oLbMetas:Refresh()
Return .T.

/*/{Protheus.doc} FS_GTSeller

	@author       Vinicius Gati
	@since        01/11/2014
	@description  Buscar o nome do vendedor para mostrar no GRID

/*/
Static Function FS_GTSeller(cCodigo)
	If !Empty(cCodigo)
		SA3->(dbSeek( xFilial("SA3") + cCodigo ))
		Return cCodigo + " - " + SA3->A3_NOME
	EndIf
Return cCodigo

/*/{Protheus.doc} FS_GTModelo

	@author       Vinicius Gati
	@since        01/11/2014
	@description  Buscar o nome descritivo do modelo para mostrar no GRID

/*/
Static Function FS_GTModelo(cCodigo)
	If !Empty(cCodigo)
		VV2->(dbSetOrder(4))
		VV2->(dbSeek( xFilial("VV2") + cCodigo ))
		VV2->(dbSetOrder(1))
		Return ALLTRIM(VV2->VV2_MODVEI) + " - " + VV2->VV2_DESMOD
	EndIf
Return cCodigo

/*/{Protheus.doc} FS_GTCampanha

	@author       Vinicius Gati
	@since        01/11/2014
	@description  Buscar o nome descritivo da campanha para mostrar no GRID

/*/
Static Function FS_GTCampanha(cCodigo)
	If ! Empty(cCodigo)
		Return ALLTRIM(OFIOA560DS( oCampDAO:TableCode(), cCodigo ))
	EndIf
Return cCodigo

/*/{Protheus.doc} FS_ShowStatus

	@author       Vinicius Gati
	@since        01/11/2014
	@description  Buscar o nome descritivo da campanha para mostrar no GRID

/*/
Static Function FS_ShowStatus(oMeta)
	oMeta:Andamento()

	// Conforme X1 MV_PAR03 = 1 (interesses) = 2 (Validos) = 3 (Cancelados) = 4 (Faturados)
	If MV_PAR03 == 1
		nPerc := (oMeta:nQtdAtendida * 100) / oMeta:nQtd
	ElseIf MV_PAR03 == 2
		nPerc := (oMeta:nQtdValidas * 100) / oMeta:nQtd
	ElseIf MV_PAR03 == 3
		nPerc := (oMeta:nQtdCanceladas * 100) / oMeta:nQtd
	Else
		nPerc := (oMeta:nQtdFaturadas * 100) / oMeta:nQtd
	EndIf	
	
	If nPerc <= MV_PAR02 // porcentagem do vermelho
		Return oVerm
	ElseIf nPerc >= MV_PAR01 // porcentagem do verde
		Return oVerd
	Else
		Return oAmar
	EndIf
Return oVerm

/*/{Protheus.doc} FS_MetasLeg

	@author       Vinicius Gati
	@since        01/04/2014
	@description  Mostra a legenda dos status dos movimentos de estoque

/*/
Static Function FS_MetasLeg()
	Local aLegenda := {          ;
		{'BR_VERDE'    , STR0013 },; //Atendido
		{'BR_VERMELHO' , STR0014 },; //Não atendido
		{'BR_AMARELO'  , STR0015 } ; //Parcialmente Atendido
	}

	BrwLegenda( STR0016, STR0016, aLegenda ) // Legenda
Return

/*/{Protheus.doc} FS_GtParametros

	@author       Vinicius Gati
	@since        04/04/2014
	@description  Criação do SX1 para legenda
	@equivalent   ValidPerg
/*/
Static Function FS_GtParametros()
	Local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	aRegs := {}

	AADD(aRegs,{"VCC690","01",STR0017,"","","MV_CH1","N", 3,0,0,"G","!VAZIO()","MV_PAR01","","","","85","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{"VCC690","02",STR0018,"","","MV_CH2","N", 3,0,0,"G","!VAZIO()","MV_PAR02","","","","25","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{"VCC690","03",STR0023,"","","MV_CH3","N", 3,0,0,"C","!VAZIO()","MV_PAR03",STR0024,STR0024,STR0024,"1","",STR0025,STR0025,STR0025,"","",STR0026,STR0026,STR0026,"","",STR0027,STR0027,STR0027,"","","","","","","","","","","",""})

	For i:=1 to Len(aRegs)
		If !DbSeek(PADR("VCC690", LEN(X1_GRUPO)) + aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				FieldPut(j,aRegs[i,j])
			Next
			MsUnlock()
			dbCommit()
		EndIf
	Next
	DbSelectArea(_sAlias)

	Pergunte('VCC690', .F.)
Return

/*/{Protheus.doc} FS_IntFmtCol

	@author       Vinicius Gati
	@since        04/04/2014
	@description  Formata a coluna da quantidade de interesses

/*/
Static Function FS_IntFmtCol(oMeta)
	// Deve ser chamadas qtds(atendidas, canceladas, validas, etc) após Andamento() 
	//   caso contrario não trarão os resultados corretos
	// A mesma é feita no metodo FS_SHOWSTATUS
	Local nPercInt := (oMeta:nQtdAtendida * 100) / oMeta:nQtd
Return FG_AlinVlrs(Transform(oMeta:nQtdAtendida, "@E 9999")) + "(" + FG_AlinVlrs(Transform(nPercInt, "@E 9999.9")) + ")%" 

/*/{Protheus.doc} FS_ValidFmtCol

	@author       Vinicius Gati
	@since        04/04/2014
	@description  Formata a coluna da quantidade de interesses validos

/*/
Static Function FS_ValidFmtCol(oMeta)
	Local nPercValid := (oMeta:nQtdValidas * 100) / oMeta:nQtd
Return FG_AlinVlrs(Transform(oMeta:nQtdValidas  , "@E 9999")) + "(" + FG_AlinVlrs(Transform(nPercValid, "@E 9999.9")) + ")%" 

/*/{Protheus.doc} FS_CancFmtCol

	@author       Vinicius Gati
	@since        04/04/2014
	@description  Formata a coluna da quantidade de interesses cancelados

/*/
Static Function FS_CancFmtCol(oMeta)
	Local nPercCanc := (oMeta:nQtdCanceladas * 100) / oMeta:nQtd
Return FG_AlinVlrs(Transform(oMeta:nQtdCanceladas  , "@E 9999")) + "(" + FG_AlinVlrs(Transform(nPercCanc, "@E 9999.9")) + ")%" 


/*/{Protheus.doc} FS_FatFmtCol

	@author       Vinicius Gati
	@since        04/04/2014
	@description  Formata a coluna da quantidade de interesses faturados

/*/
Static Function FS_FatFmtCol(oMeta)
	Local nPercFat := (oMeta:nQtdFaturadas * 100) / oMeta:nQtd
Return FG_AlinVlrs(Transform(oMeta:nQtdFaturadas  , "@E 9999")) + "(" + FG_AlinVlrs(Transform(nPercFat, "@E 9999.9")) + ")%" 

