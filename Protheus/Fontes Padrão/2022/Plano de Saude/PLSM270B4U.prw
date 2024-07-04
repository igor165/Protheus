#DEFINE CRLF chr( 13 ) + chr( 10 )
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Lucas Nonato
@version   1.xx
@since     19/08/2016
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oStruB4U		:= FWFormStruct( 1,'B4U',/*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel
	Local aB4UX2UNIC	:= { }
	
	aB4UX2UNIC := strTokArr( allTrim( FWX2Unico("B4U") ),"+" )
	
	//--< DADOS DA GUIA >---
	oModel := MPFormModel():New( 'Monitoramento' )
	oModel:AddFields( 'MODEL_B4U',,oStruB4U )
	oModel:SetDescription( "Monitoramento Pacotes TISS" )
	oModel:GetModel( 'MODEL_B4U' ):SetDescription( ".:: Monitoramento TISS ::." )
	oModel:SetPrimaryKey( aB4UX2UNIC )
return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef - MVC

@author    Lucas Nonato 
@version   1.xx
@since     19/08/2016
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FWLoadModel( 'PLSM270B4U' )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )

return oView
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PL270B4U
Preenchimento e gravacao dos dados do Monitoramento TISS (tabela B4U)

@param		[cAlias], lógico, Alias gerado pela query na função carregaDados
@param		[aPacote], array, Array com os dados do pacote	
@param		[aLote], array, Array com os dados do Lote que está sendo gerado, faz a relação com as tabelas B4U e B4M.
@param		[cSusep], caracter, numero de registro da operadora 
@param		[cNumGui], caracter, numero da guia
@param		[cCodPad], caracter, codigo da tabela de procedimento
@param		[cCodPro], caracter, codigo do procedimento
@param		[nQtdPct], numerico, quantidade do pacote
@author    Lucas Nonato
@since     18/08/2016
/*/
//------------------------------------------------------------------------------------------
Function PL270B4U( cAlias,aPacote,aLote,cSusep,cNumGui,cCodPad,cCodPro,nQtdPct )
	Local aCampos		:= {}
	Local nI				:= 1
	Local lRet			:= .T.
	local cChave		:= ""
	Local aProced		:= {}
	DEFAULT aPacote	:= {}
	DEFAULT aLote		:= {}
	DEFAULT cAlias	:= ""
	DEFAULT cSusep	:= ""
	DEFAULT cNumGui	:= ""
	DEFAULT cCodPad	:= ""
	DEFAULT cCodPro	:= ""
	DEFAULT nQtdPct	:= 1
	
	B4U->( dbSetOrder( 1 ) ) // B4U_FILIAL, B4U_SUSEP, B4U_CMPLOT, B4U_NUMLOT, B4U_NMGOPE, B4U_CDTBPC, B4U_CDPRPC, B4U_CDTBIT, B4U_CDPRIT
	BTQ->( dbSetOrder( 1 ) ) //BTQ_FILIAL, BTQ_CODTAB, BTQ_CDTERM
	for nI := 1 to len( aPacote ) Step 1

		nValFix := nQtdPct * aPacote[nI][3]
		aProced := PLGETPROC(Alltrim(aPacote[nI][1]),Alltrim(aPacote[nI][2]))
		
		If BTQ->(dbSeek(xFilial("BTQ")+'64'+aProced[3])) .And. UPPER(Alltrim(BTQ->BTQ_FENVIO)) == "CONSOLIDADO"
			Loop
		EndIf

		If aProced[1]
			cCDTBIT := aProced[2]
			cCDPRIT := aProced[3]
		Else
			cCDTBIT := aPacote[nI][1]
			cCDPRIT := aPacote[nI][2]
		EndIf
			
		If !(cCDTBIT $ "00,18,19,20,22")
			cCDTBIT := "00"
		EndIf 

		aCampos := {}
		cChave := xFilial( 'B4U' )
		cChave += padR( allTrim( cSusep ),tamSX3( "B4U_SUSEP" )[ 1 ] )
		cChave += padR( allTrim( aLote[ 2 ] ),tamSX3( "B4U_CMPLOT" )[ 1 ] )
		cChave += padR( allTrim( aLote[ 1 ] ),tamSX3( "B4U_NUMLOT" )[ 1 ] )
		cChave += padR( allTrim( cNumGui ),tamSX3( "B4U_NMGOPE" )[ 1 ] )
		cChave += padR( allTrim( cCodPad ),tamSX3( "B4U_CDTBPC" )[ 1 ] )
		cChave += padR( allTrim( cCodPro ),tamSX3( "B4U_CDPRPC" )[ 1 ] )
		cChave += padR( allTrim( cCDTBIT ),tamSX3( "B4U_CDTBIT" )[ 1 ] )
		cChave += padR( allTrim( cCDPRIT ),tamSX3( "B4U_CDPRIT" )[ 1 ] )

		If !B4U->( dbSeek( cChave ) )

			aAdd( aCampos,{ "B4U_FILIAL",	xFilial("B4U")	} ) // Filial
			aAdd( aCampos,{ "B4U_SUSEP" ,	cSusep			} ) // Operadora
			aAdd( aCampos,{ "B4U_NMGOPE",  	cNumGui			} ) // Número da Guia Operadora                                                                                                   
			aAdd( aCampos,{ "B4U_NUMLOT", 	aLote[ 1 ]		} ) // Numero de lote
			aAdd( aCampos,{ "B4U_CMPLOT",	aLote[ 2 ]		} ) // Competencia lote	
			aAdd( aCampos,{ "B4U_CDTBPC", 	cCodPad			} ) // Código da tabela - Pacote 
			aAdd( aCampos,{ "B4U_CDPRPC", 	cCodPro			} ) // Código do procedimento - Pacote
			aAdd( aCampos,{ "B4U_CDTBIT", 	cCDTBIT			} ) // Código da tabela - Item 
			aAdd( aCampos,{ "B4U_CDPRIT", 	cCDPRIT			} ) // Código do procedimento - Item  
			aAdd( aCampos,{ "B4U_QTPRPC", 	nQtdPct			} ) // Quantidade pacote	
			aAdd( aCampos,{ "B4U_VALFIX", 	nValFix			} ) // Valor fixo do item do pacote
			lRet := gravaMonit( 3,aCampos,'MODEL_B4U','PLSM270B4U' )

		else
			aAdd( aCampos,{ "B4U_QTPRPC", 	B4U->B4U_QTPRPC+1	} )	// Quantidade pacote	
			aAdd( aCampos,{ "B4U_VALFIX", 	nValFix			} ) // Valor fixo do item do pacote	
			lRet := gravaMonit( 4,aCampos,'MODEL_B4U','PLSM270B4U' )
		EndIf

	next nI

Return lRet
