
#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'OFINJD37.ch'

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "5"

/*/{Protheus.doc} OFINJD37 "Nível de atendimento por Cliente"

  Pontos de entrada:
		N/A		
	Parametros:
		N/A

    @author Vinicius Gati
    @since  16/10/2015
/*/
Function OFINJD37()
	Private oArrHlp  := DMS_ArrayHelper():New()
	Private oSqlH    := DMS_SqlHelper():New()
	Private oMetas   := DMS_MetasDeInteresseDAO():New()
	Private aMetas   := {}
	Private aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
	Private oVerm    := LoadBitmap( GetResources() , "BR_VERMELHO" )  // Nada atendido
	Private oAmar    := LoadBitmap( GetResources() , "BR_AMARELO"  )  // Parcialmente atendido
	Private oVerd    := LoadBitmap( GetResources() , "BR_VERDE"    )  // Atendido
	Private oBtnImprimir := nil
	Private oCampDAO := DMS_CampanhaDAO():New()
	Private aIntCab := {} // Cabeçalhos da função FGX_VISINT
	Private aIntIte := {} // Itens da função FGX_VISINT
	Private aTipos  := { STR0030 /*"Ambos"*/, STR0029 /*"Oficina"*/, STR0028 /*"Balcao"*/ }
	Private oCombo2
	Private cTipo

	Private lVB8HITSBN := VB8->(FieldPos("VB8_HITSBN")) > 0
	Private lVB8IMEDBN := VB8->(FieldPos("VB8_IMEDBN")) > 0

	AADD(aIntCab, {STR0013  /*Cliente    */ , "C",  030, "@!"          })
	AADD(aIntCab, {STR0014  /*Loja       */ , "C",  020, "@!"          })
	AADD(aIntCab, {STR0022  /*Nome       */ , "C",  055, "@!"          })
	AADD(aIntCab, {STR0024  /*Grupo      */ , "C",  035, "@!"          })
	AADD(aIntCab, {STR0025  /*Código     */ , "C",  030, "@!"          })
	AADD(aIntCab, {STR0023  /*Cod Item   */ , "C",  030, "@!"          })
	AADD(aIntCab, {STR0015  /*Desc. Peça */ , "C",  040, "@!"          })
	AADD(aIntCab, {STR0016  /*Qtd Hits   */ + " " + STR0028, "N", 030, "@E 999"      })
	AADD(aIntCab, {STR0017  /*Imediato   */ + " " + STR0028, "N", 030, "@E 99999999" })
	AADD(aIntCab, {STR0034  /*Qtd Hits   */ + " " + STR0028, "N", 030, "@E 999"      })
	AADD(aIntCab, {STR0018  /*NA         */ + " " + STR0028, "C", 050, "@!"          })
	AADD(aIntCab, {STR0016  /*Qtd Hits   */ + " " + STR0029, "N", 030, "@E 999"      })
	AADD(aIntCab, {STR0017  /*Imediato   */ + " " + STR0029, "N", 030, "@E 99999999" })
	AADD(aIntCab, {STR0034  /*Qtd Hits   */ + " " + STR0029, "N", 030, "@E 999"      })
	AADD(aIntCab, {STR0018  /*NA         */ + " " + STR0029, "C", 050, "@!"          })

	FS_GtParametros()

	FS_UILoad()

	SetKey(VK_F7, nil)
	SetKey(VK_F8, nil)
Return NIL

/*/{Protheus.doc} FS_UILoad

	@author       Vinicius Gati
	@since        01/11/2016
	@description  Desenha a interface com usuario

/*/
Static Function FS_UILoad()
	Local aObjects := {} , aPosObj := {} , aInfo := {}
	cSizeCli       := SPACE(TAMSX3("A1_COD")[1])
	cSizeLoja      := SPACE(TAMSX3("A1_LOJA")[1])
	dDtIni         := dDatabase-30
	dDtFin         := dDatabase
	cProdut        := SPACE(TAMSX3("B1_COD")[1])
	aAcoesRel      := {;
		{ "PARAMETROS", {|| Pergunte('OFJD37'), oLbMetas:Refresh() }, ("<F7> "+ STR0021 /*"Configuração"*/) },;
		{ "PARAMETROS", {|| FS_MetasLeg() }, ("<F8> "+ STR0007 /*"Legenda"*/) };
	}
	SetKey(VK_F7, {|| Pergunte('OFJD37'), oLbMetas:Refresh() }) // setando a configuracao de parametros no atalho F7
	SetKey(VK_F8, {|| FS_MetasLeg() }) // setando a configuracao de parametros no atalho F7
	AAdd( aObjects, { 01 , 26 , .T. , .F. } ) // Filtro
	AAdd( aObjects, { 01 , 10 , .T. , .T. } ) // ListBox
	aInfo   := { aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)

	//"Relatório 'Nível de atendimento por cliente'"
	DEFINE MSDIALOG oWindow TITLE STR0003 FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	//
	@ aPosObj[1,1] + 002 , aPosObj[1,2] TO aPosObj[1,3] , aPosObj[1,4] LABEL STR0019 /*"Filtro"*/ OF oWindow PIXEL // label bloco
	
	// Filtro Cliente
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 008 SAY STR0011 OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 040 MSGET oGtCli  VAR cSizeCli PICTURE "@!" F3 "SA1" SIZE 15,08 OF oWindow PIXEL HASBUTTON
	// Filtro Loja Cli
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 080 SAY STR0012 OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 095 MSGET oGtLoja VAR cSizeLoja PICTURE "@R NN" SIZE 20,08 OF oWindow PIXEL HASBUTTON

	// Data Inicial
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 120 SAY STR0009 /*Data I*/ OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 150 MSGET oGtDtI VAR dDtIni PICTURE "@D" SIZE 45,08 OF oWindow PIXEL HASBUTTON
	// Data Final
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 195 SAY STR0010 /*Data F*/ OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 225 MSGET oGtDtF VAR dDtFin PICTURE "@D" SIZE 45,08 OF oWindow PIXEL HASBUTTON

	// filtro na
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 0285 SAY STR0032 /*Tipo*/ OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 0300 MSCOMBOBOX oCombo2 VAR cTipo ITEMS aTipos SIZE 040,10 OF oWindow PIXEL

	@ aPosObj[1,1] + 011 , aPosObj[1,4] - 060 BUTTON oFiltra PROMPT STR0008 /*Filtrar*/ OF oWindow SIZE 50,10 PIXEL ACTION FS_Buscar()
	//
	aLBHeader := {}
	@ aPosObj[2,1] + 000 , aPosObj[2,2] + 000 LISTBOX oLbMetas ;
		FIELDS ;
		HEADER   "",; 
			STR0013 /*Cliente*/,;
			STR0014 /*Loja*/,;
			STR0022 /*Nome*/,;
			STR0024 /*Grupo*/,;
			STR0025 /*Código*/,;
			STR0023 /*Cód Item*/,;
			STR0015 /*Desc. Peça*/,;
			STR0016 /*Qtd Hits*/ + " " + STR0028,;
			STR0017 /*Imediato*/ + " " + STR0028,;
			STR0034 /*Qtd Hits*/ + " " + STR0028,;
			STR0018 /*NA*/       + " " + STR0028,;
			STR0016 /*QtdHits'*/ + " " + STR0029,;
			STR0017 /*Imediato*/ + " " + STR0029,;
			STR0034 /*Qtd Hits*/ + " " + STR0029,;
			STR0018 /*NA*/       + " " + STR0029,;
			" " ;
		COLSIZES 35,40,40,100,40,40,40,50,55,55,65,55,55,65,10 ;
		SIZE aPosObj[2,4] - 2,aPosObj[2,3] - aPosObj[2,1] - 15 OF oWindow PIXEL ;
		ON DBLCLICK FS_DblClick()
	oLbMetas:SetArray(aMetas)
	oLbMetas:bLine        := FS_Valores()
	oLbMetas:bHeaderClick := FS_HeaderClick()
	//
	// Nível de atendimento geral
	cTotNa := "                      "
	@ aPosObj[2,3] - 011 , 010 SAY STR0020 /*"NA balcão do período:"*/ OF oWindow PIXEL
	@ aPosObj[2,3] - 012 , 065 MSGET oGtTotNa VAR cTotNa SIZE 40,08 OF oWindow PIXEL WHEN .F.

	cTNaOf := "                      "
	@ aPosObj[2,3] - 011 , 160 SAY STR0031 /*"NA oficina do período:"*/ OF oWindow PIXEL
	@ aPosObj[2,3] - 012 , 215 MSGET oGtTNaOf VAR cTNaOf SIZE 40,08 OF oWindow PIXEL WHEN .F.

	cMedNA := "                      "
	@ aPosObj[2,3] - 011 , 300 SAY STR0033 /*"NA Médio:"*/ OF oWindow PIXEL
	@ aPosObj[2,3] - 012 , 327 MSGET oGt3 VAR cMedNA SIZE 40,08 OF oWindow PIXEL WHEN .F.

	@ aPosObj[2,3] - 010 , 400 BUTTON oBtnImprimir PROMPT STR0026 /*"Imprimir"*/ OF oWindow SIZE 60,08 PIXEL ACTION FS_Imprimir()

	FS_Buscar()

	ACTIVATE MSDIALOG oWindow ON INIT (EnchoiceBar(oWindow, {|| lOk:=.t., oWindow:End() }, { || oWindow:End() },,aAcoesRel))

Return .T.

/*/{Protheus.doc} FS_DblClick

	@author       Vinicius Gati
	@since        01/11/2016
	@description  Evento double click do grid

/*/
Static Function FS_DblClick()
Return .T.

/*/{Protheus.doc} FS_HeaderClick

	@author       Vinicius Gati
	@since        01/11/2016
	@description  Evento header click do grid

/*/
Static Function FS_HeaderClick()
Return { |oObj,nCol| IIf( nCol == 1, FS_MetasLeg(), Nil) }

/*/{Protheus.doc} FS_Valores

	@author       Vinicius Gati
	@since        01/11/2016
	@description  Indica os valores mostrados em cada coluna do listbox

/*/
Static Function FS_Valores()
Return { || IIF(LEN(oLbMetas:aArray) < oLbMetas:nAt, {oVerd,"","","","","","","","","","","","","","",""},;
	{ ;
		FS_ShowStatus( (100*oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_IMEDB'))/(oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_HITSB')+oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_HIPERB')) ;
					+ (100*oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_IMEDO'))/(oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_HITSO')+oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_HIPERO')) ) ,;
		oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_CODCLI'),;
		oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_LOJCLI'),;
		oLbMetas:aArray[oLbMetas:nAt]:GetValue('A1_NOME'),;
		oLbMetas:aArray[oLbMetas:nAt]:GetValue('B1_GRUPO'),;
		oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_PRODUT'),;
		oLbMetas:aArray[oLbMetas:nAt]:GetValue('B1_CODITE'),;
		oLbMetas:aArray[oLbMetas:nAt]:GetValue('B1_DESC'),;
		oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_HITSB'),;
		oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_IMEDB'),;
		oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_HIPERB'),;
		FS_IntFmtCol((100*oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_IMEDB'))/(oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_HITSB')+oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_HIPERB'))),;
		oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_HITSO'),;
		oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_IMEDO'),;
		oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_HIPERO'),;
		FS_IntFmtCol((100*oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_IMEDO'))/(oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_HITSO')+oLbMetas:aArray[oLbMetas:nAt]:GetValue('VB8_HIPERO'))),;
		"";
	})}

/*/{Protheus.doc} FS_Buscar

	@author       Vinicius Gati
	@since        01/11/2016
	@description  Busca os dados de Interesses

/*/
Static Function FS_Buscar()
	Local cQuery   := ""
	Local oSqlHlp  := DMS_SqlHelper():New()
	Local aValues  := {}
	Local nIdx     := 0
	Local nSum     := 0.0
	Local cMedia   := ""
	Local cMediaOf := ""
	Local nMedia   := 0.0

	cQuery += " SELECT VB8_CODCLI, VB8_LOJCLI, A1_NOME, VB8_PRODUT, B1_CODITE, B1_GRUPO, B1_DESC,  "
	If cTipo == STR0028 // bal
		cQuery += "        coalesce(SUM(VB8_HITSB),0) VB8_HITSB, coalesce(SUM(VB8_IMEDB),0) VB8_IMEDB, " 
		cQuery += "        coalesce(SUM(VB8_HIPERB),0) VB8_HIPERB, "
		cQuery += "        0 VB8_HITSO, 0 VB8_IMEDO, 0 VB8_HIPERO  "
		If lVB8HITSBN
			cQuery += ",   coalesce(SUM(VB8_HITSB),0) VB8_HITSBN "
		EndIf
		If lVB8IMEDBN
			cQuery += ",   coalesce(SUM(VB8_IMEDB),0) VB8_IMEDBN "
		EndIf
	elseif cTipo == STR0029 // ofi
		cQuery += "        0 VB8_HITSB, 0 VB8_IMEDB, 0 VB8_HIPERB, " 
		cQuery += "        coalesce(SUM(VB8_HITSO),0) VB8_HITSO, coalesce(SUM(VB8_IMEDO),0) VB8_IMEDO, "
		cQuery += "        coalesce(SUM(VB8_HIPERO),0) VB8_HIPERO "
		If lVB8HITSBN
			cQuery += ",   0 VB8_HITSBN "
		EndIf
		If lVB8IMEDBN
			cQuery += ",   0 VB8_IMEDBN "
		EndIf
	else
		cQuery += "        coalesce(SUM(VB8_HITSB),0) VB8_HITSB, coalesce(SUM(VB8_IMEDB),0) VB8_IMEDB, " 
		cQuery += "        coalesce(SUM(VB8_HITSO),0) VB8_HITSO, coalesce(SUM(VB8_IMEDO),0) VB8_IMEDO, " 
		cQuery += "        coalesce(SUM(VB8_HIPERB),0) VB8_HIPERB, coalesce(SUM(VB8_HIPERO),0) VB8_HIPERO "
		If lVB8HITSBN
			cQuery += ",   coalesce(SUM(VB8_HITSBN),0) VB8_HITSBN "
		EndIf
		If lVB8IMEDBN
			cQuery += ",   coalesce(SUM(VB8_IMEDBN),0) VB8_IMEDBN "
		EndIf
	EndIf
	cQuery += "       FROM " + RetSqlName('VB8') + " VB8 "
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = VB8_CODCLI AND A1_LOJA = VB8_LOJCLI AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD    =  VB8_PRODUT AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VB8_FILIAL = '"+xFilial('VB8')+"' "
	cQuery += "   AND VB8.D_E_L_E_T_ = ' ' "
	if ! Empty(cSizeCli) .AND. ! Empty(cSizeLoja)
		cQuery += " AND VB8_CODCLI = '"+cSizeCli+"' AND VB8_LOJCLI = '"+cSizeLoja+"' "
	ElseIf ! Empty(cSizeCli)
		cQuery += " AND VB8_CODCLI = '"+cSizeCli+"' "
	EndIf
	If ! Empty(dDtIni ) .AND. ! Empty(dDtFin)
		cQuery += " AND (VB8_ANO+VB8_MES+VB8_DIA) >= '" + DTOS(dDtIni) + "' AND (VB8_ANO+VB8_MES+VB8_DIA) <= '" + DTOS(dDtFin) + "' "
	EndIf
	If ! Empty(cProdut)
		cQuery += " AND VB8_PRODUT = '"+cProdut+"' "
	EndIf
	
	cQuery += " AND ( VB8_HITSB > 0 OR VB8_HITSO > 0 OR VB8_HIPERB > 0 OR VB8_HIPERO > 0 "
	If lVB8HITSBN
		cQuery += " OR VB8_HITSBN > 0"
	EndIf
	cQuery += " ) "
	
	If cTipo == STR0028 // bal
		cQuery += " AND ( VB8_HITSB > 0 OR VB8_HIPERB > 0"
		If lVB8HITSBN
			cQuery += " OR VB8_HITSBN > 0"
		EndIf
		cQuery += " ) "
	elseif cTipo == STR0029 // ofi
		cQuery += " AND (VB8_HITSO > 0 OR VB8_HIPERO > 0) " 
	EndIf
	cQuery += " GROUP BY VB8_CODCLI, VB8_LOJCLI, A1_NOME, VB8_PRODUT, B1_CODITE, B1_GRUPO, B1_DESC "

	aRegs := oSqlHlp:GetSelect({;
		{'campos', {"VB8_CODCLI", "VB8_LOJCLI", "A1_NOME", "VB8_PRODUT", "B1_DESC", "VB8_HITSB", "VB8_IMEDB", "VB8_HITSO", "VB8_IMEDO", "B1_CODITE", "B1_GRUPO","VB8_HIPERB","VB8_HIPERO","VB8_HITSBN","VB8_IMEDBN"}},;
		{'query' , cQuery};
	})

	nSumHB := oArrHlp:SumBlk(aRegs, {|reg| reg:GetValue('VB8_HITSB') + reg:GetValue('VB8_HIPERB') + reg:GetValue('VB8_HITSBN') })
	nSumIB := oArrHlp:SumBlk(aRegs, {|reg| reg:GetValue('VB8_IMEDB') + reg:GetValue('VB8_IMEDBN')})
	nNatB  := (nSumIB / nSumHB) * 100
	cTotNa := FG_AlinVlrs(Transform(round(nNatB,1), "@E 9999.99"))
	cTotNa := cTotNa

	nSumHO := oArrHlp:SumBlk(aRegs, {|reg| reg:GetValue('VB8_HITSO') + reg:GetValue('VB8_HIPERO') })
	nSumIO := oArrHlp:SumBlk(aRegs, {|reg| reg:GetValue('VB8_IMEDO') })
	nNatO  := (nSumIO / nSumHO ) * 100
	cTNaOf := FG_AlinVlrs(Transform(round(nNatO, 1), "@E 9999.99"))

	If cTipo == STR0028 .or. cTipo == STR0029 // selecionou somente balcao ou oficina
		cMedNA := FG_AlinVlrs(Transform(round(nNatO+nNatB, 1), "@E 9999.99"))
	else
		cMedNA := FG_AlinVlrs(Transform(round(((nNatO+nNatB)/2), 1), "@E 9999.99"))
	endif

	oLbMetas:SetArray( aRegs )
	oLbMetas:bLine := FS_Valores()
	oLbMetas:Refresh()
Return .T.

/*/{Protheus.doc} FS_MetasLeg

	@author       Vinicius Gati
	@since        01/04/2016
	@description  Mostra a legenda dos status dos movimentos de estoque

/*/
Static Function FS_MetasLeg()
	Local aLegenda := {          ;
		{'BR_VERDE'    , STR0004 /*'Alto' */  },; //Atendido
		{'BR_AMARELO'  , STR0005 /*'Médio' */ },; //Parcialmente Atendido
		{'BR_VERMELHO' , STR0006 /*'Baixo' */ } ; //Não atendido
	}

	BrwLegenda( STR0007, STR0007, aLegenda ) // Legenda
Return

/*/{Protheus.doc} FS_Imprimir

	@author       Vinicius Gati
	@since        29/08/2016
	@description  Mostra a legenda dos status dos movimentos de estoque

/*/
Static Function FS_Imprimir()
	if LEN(oLbMetas:aArray) > 0
		aRel := {}
		AEVAL( oLbMetas:aArray, {|el| AADD(aRel , {;
			el:GetValue('VB8_CODCLI'),;
			el:GetValue('VB8_LOJCLI'),;
			el:GetValue('A1_NOME'   ),;
			el:GetValue('B1_GRUPO'  ),;
			el:GetValue('VB8_PRODUT'),;
			el:GetValue('B1_CODITE' ),;
			el:GetValue('B1_DESC'   ),;
			el:GetValue('VB8_HITSB' ),;
			el:GetValue('VB8_IMEDB' ),;
			el:GetValue('VB8_HIPERB' ),;
			FS_IntFmtCol((100*el:GetValue('VB8_IMEDB'))/el:GetValue('VB8_HITSB')+el:GetValue('VB8_HIPERB')),;
			el:GetValue('VB8_HITSO' ),;
			el:GetValue('VB8_IMEDO' ),;
			el:GetValue('VB8_HIPERO' ),;
			FS_IntFmtCol((100*el:GetValue('VB8_IMEDO'))/el:GetValue('VB8_HITSO')+el:GetValue('VB8_HIPERO'));
		}) })

		FGX_VISINT("OFINJD37" , STR0003 /*"Relatório de ..."*/ , aIntCab , aRel , .F. )
	Else
		MsgInfo(STR0027 /*"Nenhum registro encontrar para impressão"*/)
	EndIf
Return

/*/{Protheus.doc} FS_GtParametros

	@author       Vinicius Gati
	@since        04/04/2016
	@description  Criação do SX1 para legenda
	@equivalent   ValidPerg
/*/
Static Function FS_GtParametros()
	Local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	aRegs := {}

	AADD(aRegs,{"OFJD37","01",STR0001 /* Verde '>= que %'?    */,"","","MV_CH1","N", 3,0,0,"G","!VAZIO()","MV_PAR01","","","","85","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{"OFJD37","02",STR0002 /* Vermelho '<= que %'? */,"","","MV_CH2","N", 3,0,0,"G","!VAZIO()","MV_PAR02","","","","25","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	For i:=1 to Len(aRegs)
		If !DbSeek(PADR("OFJD37", LEN(X1_GRUPO)) + aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				FieldPut(j,aRegs[i,j])
			Next
			MsUnlock()
			dbCommit()
		EndIf
	Next
	DbSelectArea(_sAlias)

	Pergunte('OFJD37', .F.)
Return Nil

/*/{Protheus.doc} FS_IntFmtCol

	@author       Vinicius Gati
	@since        04/04/2016
	@description  Formata a coluna da quantidade de interesses

/*/
Static Function FS_IntFmtCol(nPercInt)
Return FG_AlinVlrs(Transform(nPercInt, "@E 999999.9")) + "%" 

/*/{Protheus.doc} FS_ShowStatus

	@author       Vinicius Gati
	@since        01/11/2016
	@description  Buscar o nome descritivo da campanha para mostrar no GRID

/*/
Static Function FS_ShowStatus(nPerc)
	If nPerc <= MV_PAR02 // porcentagem do vermelho
		Return oVerm
	ElseIf nPerc >= MV_PAR01 // porcentagem do verde
		Return oVerd
	Else
		Return oAmar
	EndIf
Return oVerm
