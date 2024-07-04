#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#include 'PLSMVCDESP.CH'
#include 'COLORS.CH'
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCB3W

Manutencao de Eventos X Despesas no nucleo de informacoes e obrigacoes

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCB3W(lAuto)

	Local oBrowse	:= Nil

	Default lAuto := .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B3W')
	oBrowse:SetDescription("Espelho ANS") //Eventos X Despesas 

	If !lAuto
		oBrowse:Activate()		
	EndIf

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Private aRotina	:= {}

	aAdd( aRotina, { "Visualizar"	, 'VIEWDEF.PLSMVCB3W(.F.)'	, 0 , 2 , 0 , Nil } ) //Visualizar
	aAdd( aRotina, { "Imprimir"	, 'VIEWDEF.PLSMVCB3W(.F.)'	, 0 , 8 , 0 , Nil } ) //Imprimir

Return aRotina
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B3W

@return oModel	objeto model criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oStruB3W := FWFormStruct( 1, 'B3W', , )

	oModel := MPFormModel():New( "Espelho ANS", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ ) 
	oModel:AddFields( 'B3WMASTER', Nil, oStruB3W )
	oModel:GetModel( 'B3WMASTER' ):SetDescription( "Espelho ANS" ) 
	oModel:SetDescription( "Espelho ANS" )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B3W

@return oView	objeto view criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()  

	Local oModel   := FWLoadModel( 'PLSMVCB3W' )
	Local oStruB3W := FWFormStruct( 2, 'B3W' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B3W' , oStruB3W, 'B3WMASTER' )     
	oView:CreateHorizontalBox( 'GERAL', 100 )
	oView:SetOwnerView( 'VIEW_B3W' , 'GERAL'  )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCENTOBR

Tela principal da Central de Obrigacoes

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSB3KB3W(nRecno, cCampo, lAuto) 

	Local aCritSib := {}
	Local aAreaB3K := B3K->(GetArea()) 
	Local aAreaB3W := B3W->(GetArea()) 

	Default nRecno := 0 
	Default lAuto  := .F.

	If nRecno > 0

		If CritBenef("TRBCRI",nRecno)
			If BenefCntANS("TRBBEN",nRecno)
			
				While !TRBCRI->(Eof())
						
					cCampo := Alltrim(TRBCRI->B3F_CAMPOS)
				
					If cCampo == "B3K_MATRIC" .AND. GetNewPar("MV_PLMATAN",.F.)
						If Empty(TRBBEN->B3K_MATANT)
							cVlrCentral := AllTrim(TRBBEN->B3K_MATRIC)
						Else
							cVlrCentral := AllTrim(TRBBEN->B3K_MATANT)
						EndIf
					Else
						cVlrCentral := Alltrim(&("TRBBEN"+ "->" + cCampo ))
					EndIf
					
					cVlrAns := Alltrim(&("TRBBEN" + "->B3W" + Substr(cCampo,4,len(cCampo) ) ))
					If !(cVlrCentral == cVlrAns)
						aAdd(aCritSib,{cCampo,cVlrCentral,cVlrAns})
					EndIf
					TRBCRI->(dbSkip())		
					
				EndDo //!(cAlias)->(Eof())
		
			Else
				If !lAuto
					Alert("Beneficiário nao encontrado no CNX")					
				EndIf
			EndIf //If BenefCntANS("TRBBEN",nRecno)
		Else
			If !lAuto
				Alert("Não foram encontradas criticas de comparação com o CNX. Execute a validação 'Benef x CNX' e tente novamente.")				
			EndIf
		EndIf //If CritBenef("TRBCRI",nRecno)
		
		If len(aCritSib) > 0
			If !lAuto
				PLSCRIGEN(aCritSib,{ {"Campo   ","@C",20} , {"Valor Central","@C",120 } , {"Valor ANS","@C",120 } }, "  Críticas de Beneficiários  ")
			EndIf		
		EndIf

	Else
		If !lAuto
			Alert("Não existem dados para serem exibidos")		
		EndIf	
	EndIf

	B3K->(RestArea(aAreaB3K)) 
	B3W->(RestArea(aAreaB3W)) 

Return aCritSib

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CritBenef

Funcao cria a area de trabalho TRBBEN com as informacoes de beneficiarios a validarem

@param cAlias		Area de trabalho corrente
@param cDataRef	Data de referencia
@param cRegANS		Numero de registro da operadora na ANS


@return lRetorno	retorno logico indicando se foi .T. ou nao .F. encontrado registros

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function CritBenef(cAlias,nRecno)

	Local cSql			:= ""
	Local lRetorno		:= .F.
	Default cAlias		:= ""

	cSql := " SELECT DISTINCT B3F_CAMPOS FROM " + RetSqlName("B3F") + " B3F " 
	cSql += " WHERE B3F.B3F_CHVORI = " + Alltrim(Str(nRecno))
	cSql += " AND B3F.B3F_TIPO = '2' "

	cSql := ChangeQuery(cSql)

	If select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)


	If Empty(cAlias) .Or. (cAlias)->(Eof())
		lRetorno := .F.
	Else
		lRetorno := .T.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BenefCntANS

Funcao cria a area de trabalho TRBBEN com as informacoes de beneficiarios a validarem

@param cAlias		Area de trabalho corrente
@param cDataRef	Data de referencia
@param cRegANS		Numero de registro da operadora na ANS


@return lRetorno	retorno logico indicando se foi .T. ou nao .F. encontrado registros

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function BenefCntANS(cAlias,nRecno)

	Local cSql			:= ""
	Local lRetorno		:= .F.
	Default cAlias		:= ""

	cSql := " SELECT B3K.*,B3W.* FROM " + RetSqlName("B3K") + " B3K " 
	cSql += " FULL OUTER JOIN " 
	cSql += " " + RetSqlName("B3W") + " B3W " 
	cSql += " ON B3K_FILIAL = B3W_FILIAL " 
	cSql += " AND B3K_CODCCO = B3W_CODCCO " 
	cSql += " WHERE B3K.R_E_C_N_O_ = " + Alltrim(Str(nRecno))

	cSql := ChangeQuery(cSql)

	If select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

	If Empty(cAlias) .Or. (cAlias)->(Eof())
		lRetorno := .F.
	Else
		lRetorno := .T.
	EndIf

Return lRetorno
