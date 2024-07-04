#include 'Protheus.ch'
#include 'FWMVCDEF.ch'
#include 'FINA010.CH'
#include 'Totvs.Ch'

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA010EVBRA
Classe de evento do MVC somente aplicada no Brasil, os eventos gerais devem ser feitos no 
fonte FINA010EVDEF

@author  jose.aribeiro
@since   25/05/2017
@type    Class
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
CLASS FINA010EVBRA From FWModelEvent

	DATA nOpc			As Numeric
	DATA lHistFiscal	As Logical
	DATA lNatSint		As Logical
	DATA lF010Auto		As Logical
	DATA oModel			As Object

	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()
	METHOD F010FISC()
	METHOD VALIDPISCOFIN()
	METHOD InTTS()
	METHOD A010NATFC()
	METHOD ATUALFILHA()
	METHOD F010Trigger()
	
ENDCLASS

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da Classe

@author  jose.aribeiro
@since   25/05/2017
@version 12.1.17
@type	 Method
/*/
//-------------------------------------------------------------------------------------------------------------
METHOD New() CLASS FINA010EVBRA

	::lHistFiscal 	:= HistFiscal()
	::lNatSint 		:= FNatSAIsOn()
	::lF010Auto		:= IsAuto() 
	
Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Metodo de validação do modelo antes de realizar a gravação dos dados.

@author  jose.aribeiro
@since   25/05/2017
@version 12.1.17
@param	 oModel , Objeto, Objeto do Modelo
@return	 lRet	, Logico, Variavel que vai retorna .T. para validado e .F. para nao validado
@type	 Method
/*/
//-------------------------------------------------------------------------------------------------------------
METHOD ModelPosVld() CLASS FINA010EVBRA
	Local lRet 		As Logical
	Local oModelSED	As Object
	Local cLcdpr	As Character
	Local lEdLcdpr	As Logical

	lEdLcdpr	:= SED->(ColumnPos("ED_LCDPR")) > 0

	lRet 			:= .T.
	::oModel		:= FwModelActive()
	::nOpc			:= ::oModel:GetOperation()
	oModelSED		:= ::oModel:GetModel("SEDMASTER")
	If lEdLcdpr
		If SED->ED_CODIGO == FWFldGet( "ED_PAI")
			cLcdpr	:= SED->ED_LCDPR // Aqui recebe o valor LCDPR da natureza sintética cadastrada
		Else
			cLcdpr	:= ::F010Trigger() 
		EndIf
	EndIf
	If(::nOpc == MODEL_OPERATION_UPDATE)
		If(::lHistFiscal)
			//Metodo de Gravação do Historico Fiscal
			::F010FISC()

		EndIf
		If ::lNatSint 
			If lEdLcdpr .And. oModelSED:GetValue("ED_TIPO") == "1" .And. !Empty(oModelSED:GetValue("ED_LCDPR"))
				::ATUALFILHA( oModelSED:GetValue("ED_LCDPR") )
			EndIf 
		EndIf
	ElseIf(::nOpc == MODEL_OPERATION_DELETE)
			If(::A010NATFC(oModelSED:GetValue("ED_CODIGO")))

				HELP(' ',1,"A010NATFC")
				lRet := .F.

			EndIf
	ElseIf(::nOpc == MODEL_OPERATION_INSERT)
		If(oModelSED:GetValue("ED_APURPIS") != " " .And. oModelSED:GetValue("ED_PCAPPIS") <= 0)

			lRet := ::VALIDPISCOFIN()
			
		EndIf
		If ::lNatSint
			If lEdLcdpr .And. !Empty(AllTrim(cLcdpr)) .And. (oModelSED:GetValue("ED_TIPO") == "2" .And. Empty(oModelSED:GetValue("ED_LCDPR") ) )
			
				If !::lF010Auto
					MsgInfo( STR0085 + Chr(10) + Chr(13) + STR0086, STR0087) // "Uma vez que não foi definido o campo LCDPR, " ## "a natureza herdará da natureza pai automaticamente." ## "Cópia LCDPR"
				EndIf
				oModelSED:SetValue("ED_LCDPR", cLcdpr)
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F010FISC
Metodo para gravar o Historico fiscal

@type  METHOD
@author jose.aribeiro
@since 25/05/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
METHOD F010FISC() CLASS FINA010EVBRA
	Local bCampoSED		As Block	
	Local nX			As Numeric
	local nY 			As Numeric 
	Local oModelSED		As Object
	Local aArea			As Array
	
	Private aCpoAltSED	As Array

	bCampoSED	:= {|x| Field(x) }
	nX			:= 0
	nY 			:= 1 
	oModelSED	:= ::oModel:GetModel("SEDMASTER")
	aCpoAltSED	:= {}

	If(::lHistFiscal)
		aArea		:= GetArea()
		dbSelectArea("SED")

		For nX:= 1 to SED->(Fcount())
			If SED->(eVal( bCampoSED, nY)) <> ""
				While !oModelSED:HasField(SED->(eVal( bCampoSED, nY))) 
					nY += 1 
				EndDo
				
				If!(oModelSED:GetValue( eVal( bCampoSED, nY) ) == SED->&((eVal( bCampoSED, nY))))
	
					aAdd( aCpoAltSED, { eVal( bCampoSED, nY), SED->&(( eVal( bCampoSED, nY) )) } )
	
				EndIf
				
				nY += 1 
			EndIf
		Next
		
		If oModelSED:HasField("ED_IDHIST") 
			oModelSED:SetValue('ED_IDHIST',IdHistFis())
		Else
			RecLock("SED", .F.)
				SED->ED_IDHIST := IdHistFis()
			SED->(MsUnlock())
		EndIf	

		RestArea(aArea)
	EndIf

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ATUALFILHA
Metodo para alterar o ED_LCDPR das naturezas analíticas

@type  METHOD
@author rodrigo.oliveira
@since 15/10/2019
@version 12.1.27
/*/
//-------------------------------------------------------------------------------------------------------------
METHOD ATUALFILHA(cLcdpr) CLASS FINA010EVBRA
	Local aArea		As Array
	Local oModel 	As Object
	Local cCodigo	As Character
	Local lCopSED	As Logical
	
	Default	cLcdpr	:= ""
	
	aArea		:= SED->(GetArea())
	oModel		:= FWLoadModel("FINA010")
	oModel:Activate()
	cCodigo		:= oModel:GetValue("SEDMASTER", "ED_CODIGO")
	lCopSED		:= .F.
	
	DbSelectArea('SED')
	DbSetOrder(2)
	DbGoTop()
		
	DbSeek(xFilial("SED") + cCodigo)
		
	While !lCopSED .And. cCodigo == SED->ED_PAI
		If Empty(SED->ED_LCDPR)
			lCopSED := .T.
		EndIf
		SED->(DbSkip())
	EndDo
	
	If !::lF010Auto .And. lCopSED
	
		MsgAlert( STR0081 +; // "Na (re)definição do Gera LCDPR ? da natureza sintética, TODAS as naturezas "
				STR0082 , STR0062 ) // "terão essa informação atualizada (sobrescrita)." ## "Atenção"
		If MSGYESNO( STR0083 , STR0084 )  // "Deseja realmente replicar o LCDPR definido para TODAS as naturezas analíticas?" ## "Cópia"
		
			If lCopSED
				DbGoTop()
				DbSeek(xFilial("SED") + cCodigo)
				
				While !Eof() .And. cCodigo == SED->ED_PAI
					RecLock("SED", .F.)
					SED->ED_LCDPR := cLcdpr
					SED->(MsUnlock())
					SED->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
Return
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F010Trigger
Metodo para alterar o ED_LCDPR das naturezas analíticas

@type  METHOD
@author rodrigo.oliveira
@since 06/11/2019
@version 12.1.27
/*/
//-------------------------------------------------------------------------------------------------------------
METHOD F010Trigger() CLASS FINA010EVBRA As Character
	Local cEdPai 	As Character
	Local cCodPai 	As Character
	Local aArea		As Array
	Local oModel 	As Object
	
	cEdPai	:= ""
	
	oModel 	:= FWModelActive()
	nOper 	:= oModel:GetOperation()
	
	If nOper == MODEL_OPERATION_INSERT
		aArea	:= SED->(GetArea())
	
		cCodPai	:= FWFldGet( "ED_PAI" )
		
		DbSelectArea("SED")
		DbSetOrder(1)
		If !Empty(cCodPai)
			If DbSeek(xFilial("SED") + cCodPai)
				cEdPai	:= SED->ED_LCDPR 
			EndIf
		EndIf
		
		RestArea(aArea)
	EndIf
	
Return cEdPai
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VALIDPISCOFIN
Metodo para validar PIS e Cofins

@type  METHOD
@author jose.aribeiro
@since 25/05/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
METHOD VALIDPISCOFIN() CLASS FINA010EVBRA 
	Local lRet		AS Logical
	Local oModelSED As Object 

	lRet		:= .T.
	oModelSED	:= ::oModel:GetModel("SEDMASTER")
	//Validação do PIS
	If(oModelSED:GetValue("ED_APURPIS") != " " .And. oModelSED:GetValue("ED_PCAPPIS") <= 0)

		Help("",1,"A010PORAPU")
		lReturn := .F.
	
	ElseIf(oModelSED:GetValue("ED_APURPIS") == " " .And. oModelSED:GetValue("ED_PCAPPIS")> 0)

		Help("",1,"A010TIPAPU")
		lReturn := .F.
	//Validacao do COFINS
	ElseIf(oModelSED:GetValue("ED_APURCOF") == " " .And. oModelSED:GetValue("ED_PCAPCOF")<= 0)

		Help("",1,"A010PORAPU")
		lReturn := .F.

	ElseIf(oModelSED:GetValue("ED_APURCOF") == " " .And. oModelSED:GetValue("ED_PCAPCOF")> 0)

		Help("",1,"A010TIPAPU")
		lReturn := .F.

	EndIf

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Metodo executado apos a gravação dos dados, dentro da transação.

@type  METHOD
@author jose.aribeiro
@since 25/05/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
METHOD InTTS() CLASS FINA010EVBRA
	Local aCmps 	As Array
	Local bCampoSED As Block 

	aCmps		:= {}
	bCampoSED	:= { |x| SED->(Field(x)) }
	If(::nOpc == MODEL_OPERATION_DELETE)

		//Grava historico fiscal
		If ::lHistFiscal 
			aCmps :=  RetCmps("SED",bCampoSED)	
			GrvHistFis("SED", "SS7", aCmps)
			aCmps := {} 
		EndIf

	ElseIf(::nOpc == MODEL_OPERATION_UPDATE)

		//Grava historico fiscal
		If ::lHistFiscal 
			GrvHistFis("SED", "SS7", aCmps) 
			aCpoAltSED := {}
			aCmps      := {}
		EndIf	

	EndIf
Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A010NATFC
metodo de validação da exclusão da natureza

@type  METHOD
@author jose.aribeiro
@since 26/05/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
METHOD A010NATFC(cNat) CLASS FINA010EVBRA
	Local lRet			As Logical
	Local aArea			As Array
	Local cAliasTMP		As Character 
	Local cAliasTMP2	As Character 
	Local cQuerySA1		As Character 
	Local cQuerySA2		As Character 
	//--- Tratamento Gestao Corporativa
	Local lGestao		As Logical
	Local cFilSA1		As Character 
	Local cFilSA2		As Character 

	lRet		:= .F.
	lGestao		:= FWSizeFilial() > 2 // Indica se usa Gestao Corporativa
	cAliasTMP	:= GetNextAlias()
	cAliasTMP2	:= GetNextAlias()
	cQuerySA1	:= ""
	cQuerySA2	:= ""
	cFilSA1		:= Iif( lGestao , FWxFilial("SA1",cFilAnt), xFilial("SA1",cFilAnt) )	
	cFilSA2		:= Iif( lGestao , FWxFilial("SA2",cFilAnt), xFilial("SA2",cFilAnt) )
	aArea		:= GetArea()

	cQuerySA1 += "SELECT SA1.A1_FILIAL,SA1.A1_COD,SA1.A1_LOJA,SA1.A1_NOME,SA1.A1_NATUREZ"
	cQuerySA1 += "FROM " + RetSqlName("SA1") + " SA1"
	cQuerySA1 += "WHERE "

	cQuerySA2 += "SELECT SA2.A2_FILIAL,SA2.A2_COD,SA2.A2_LOJA,SA2.A2_NATUREZ"
	cQuerySA2 += "FROM " + RetSqlName("SA2") + " SA2 "
	cQuerySA2 += "WHERE "

	If !Empty(cNat)
		cQuerySA1 +=  "(SA1.A1_NATUREZ = '"+cNat+"') AND"
		cQuerySA1 +=  "(SA1.A1_FILIAL = '"+cFilSA1+"') "

		cQuerySA2 +=  "(SA2.A2_NATUREZ = '"+cNat+"' ) AND"
		cQuerySA2 +=  "(SA2.A2_FILIAL = '"+cFilSA2+"' ) "
	EndIf

	cQuerySA1 := ChangeQuery(cQuerySA1)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuerySA1), cAliasTMP, .F., .T.)
	If((cAliasTMP)->(EOF()))
		
		cQuerySA2 := ChangeQuery(cQuerySA2)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuerySA2), cAliasTMP2 , .F., .T.)	
		If((cAliasTMP2)->(!EOF()))

			lRet := .T.

		EndIf
	EndIf
	RestArea(aArea)
Return lRet