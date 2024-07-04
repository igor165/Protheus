#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FATA600.CH"
#INCLUDE "DBTREE.CH" 

Static aConfigAlo 	:= {}			//Configuracao da alocacao de recurso.
Static aCamposAbo 	:= {}			//Campos da estrutura ABO.

//-------------------------------------------------------------------
/*/{Protheus.doc} At600VPsLn

Pos-Validação dos itens da Proposta 

@author luiz.jesus

@since 18/03/2014
@version 12
/*/
//-------------------------------------------------------------------
Function At600VPsLn(oModelADZ)

Local aArea		:= GetArea()
Local aAreaSE4	:= SE4->(GetArea())
Local aAreaDA1	:= DA1->(GetArea())
Local lRet		:= .T.
Local nCont		:= 0
Local nTotProd	:= 0
Local oModel	:= FWModelActive()
Local cFolder	:= oModelADZ:GetId()
Local cCondPG	:= oModelADZ:GetValue("ADZ_CONDPG")
Local aTipo09	:= {}
Local cFilSB1	:= ''

SE4->(DbSetOrder(1))	//E4_FILIAL+E4_CODIGO
DA1->(DbSetOrder(1)) //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
//Verifica se a condição de pagamento é do tipo 9
If SE4->(DbSeek(xFilial("SE4")+cCondPG))
	If	SE4->E4_TIPO == "9"
		aTipo09 := Ft600GetTipo09() //Get do valor da variável estática
		If Len(aTipo09) == 0
			If !At600Tipo9(cCondPG,oModel,cFolder,SE4->E4_COND)
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSE4)
RestArea(aAreaDA1)
RestArea(aArea)
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} At600Cancel
Validação para o cancelamento da Proposta Comercial

@author luiz.jesus
@since 18/03/2014
@version 12
/*/
//-------------------------------------------------------------------
Function At600Cancel(oModel)

Local aArea			:= GetArea()
Local aAreaAF1		:= AF1->(GetArea())
Local oMdl 			:= FwModelActive()
Local nOperation	:= oMdl:GetOperation()
Local nTmTFFCod		:= GetSX3Cache("TFF_COD","X3_TAMANHO")
Local cTipo			:= "2"   					// Tipo de modelo a ser utilizado no simulador 2=Proposta
Local lOrcPrc	  	:= SuperGetMv("MV_ORCPRC",,.F.)
Local lRetorno 		:= .T.

// Variaveis auxiliares para o beneficio
Local nI			:= 0
Local cQuerySLY		:= ""
Local cAliasSLY		:= ""
Local aTFFCOD		:= {}
Local lOkSLY 		:= AliasInDic('SLY')
Local oModelADY 	:= oModel:GetModel( "ADYMASTER")

Local cFilSLY		:= ""
Local cFilTFF		:= ""

DbSelectArea('AF1')
AF1->(DbSetOrder(4)) //AF1_FILIAL+AF1_CODORC+AF1_TIPO

If nOperation == MODEL_OPERATION_INSERT
	//Verifica se foi feita alguma simulação de horas na proposta.
	//Se sim, essa simulação deve ser excluída para evitar que o 
	//próximo a usar a simulação inicie com uma já preenchida.
	If AF1->(DbSeek(xFilial("AF1") + FwFldGet("ADY_PROPOS") + cTipo ))
		FTAExcAF1(Nil, AF1->(Recno()))
	EndIf

	RollBackSX8()

	DbSelectArea("TFJ")
	TFJ->( DbSetOrder( 2 ) ) // TFJ_FILIAL+TFJ_PROPOS+TFJ_PREVIS
	If TFJ->( DbSeek( xFilial("TFJ")+oModelADY:GetValue("ADY_PROPOS")+oModelADY:GetValue("ADY_PREVIS") ) )
		At740Del( TFJ->(Recno()) )
	EndIf
Else
	aTFFCOD := Ft600GetBen()
	// Efetua a exclusao dos benecificios
	IF lOkSLY .And. Len(aTFFCOD) > 0
		cFilSLY	:= xFilial("SLY")
		cFilTFF	:= xFilial("TFF")
		DbSelectArea("SLY")
		SLY->(DbSetOrder(1))//LY_FILIAL, LY_TIPO, LY_AGRUP, LY_ALIAS, LY_FILENT, LY_CHVENT, LY_CODIGO, LY_DTINI

		FOR nI := 1 TO Len(aTFFCOD)
			// Verifica se existe beneficio vinculado
			cAliasSLY := GetNextAlias()
			
			cQuerySLY := "SELECT *"
			cQuerySLY += "  FROM " + RetSqlName("SLY")+" SLY"
			cQuerySLY += " WHERE LY_FILIAL = '" + cFilSLY + "'"
			cQuerySLY += "   AND SUBSTRING(LY_CHVENT,1," + STR(nTmTFFCod) + ") = '" + aTFFCOD[nI][2] + "'"
			cQuerySLY += "   AND LY_FILENT = '" + cFilTFF + "'"
			cQuerySLY += "   AND LY_ALIAS = 'TDX'"
			cQuerySLY += "   AND SLY.D_E_L_E_T_ = ' '"
			cQuerySLY += " ORDER BY LY_FILIAL, LY_TIPO, LY_AGRUP, LY_ALIAS, LY_FILENT, LY_CHVENT, LY_CODIGO, LY_DTINI"
			
			cQuerySLY := ChangeQuery(cQuerySLY)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySLY),cAliasSLY,.T.,.T.)
			
			While (cAliasSLY)->(!Eof())

				IF SLY->(DbSeek((cAliasSLY)->LY_FILIAL+(cAliasSLY)->LY_TIPO+(cAliasSLY)->LY_AGRUP+(cAliasSLY)->LY_ALIAS+(cAliasSLY)->LY_FILENT+(cAliasSLY)->LY_CHVENT+(cAliasSLY)->LY_CODIGO+(cAliasSLY)->LY_DTINI))
					RecLock("SLY", .F.)
					SLY->(DbDelete())
					SLY->(MsUnLock())
				ENDIF
				
				dbSelectArea(cAliasSLY)
				(cAliasSLY)->(dbSkip())
			END

			DbSelectArea(cAliasSLY)
			(cAliasSLY)->(DbCloseArea())			
						
		NEXT nI
		FT600SETBEN({}) // Limpa o Array
	ENDIF
EndIf

aConfigAlo	:= {}
aCamposAbo	:= {}

If lOrcPrc
	At600STabPrc( "", "" )
	AT740FGXML(nil,nil,.T.) 
EndIf

//Chama as funcoes padroes do MVC para cancelar o formulario corretamente.
lRetorno := FwFormCancel(oModel)

RestArea(aAreaAF1)
RestArea(aArea)

Return(lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} A600VOrc
	 Valida se existe orçamento de serviços na importação 

@sample	A600VOrc()

@since		26/03/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function A600VOrc()

Local lRet := .T.
Local aArea := GetArea()

TFJ->( DbSetOrder( 2 ) ) //TFJ_FILIAL + TFJ_PROPOS + TFJ_REVIS

If TFJ->( DbSeek( xFilial('TFJ') + FwFldGet("ADY_PROPOS") + FwFldGet("ADY_PREVIS") ) )
	lRet := MsgYesNo(STR0227) // "Deseja substituir o orçamento de serviços existente ?"
EndIf

RestArea(aArea)

Return(lRet)

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} Ft600ROk

Validacao do array das revisoes para comparacão.

@sample  Ft600ROk

@author  Serviços/CRM
@since   29/04/2014
@version P12
/*/
//-----------------------------------------------------------------------------------------
Function Ft600ROk(aRevisoes,aCmp)

Local lRetorno   := .T.

Default aCmp     := {}

aEval(aRevisoes,{|x| If(x[1],aAdd(aCmp,{x[Len(x)-1],x[Len(x)]}),)})
If Len(aCmp) < 2
	Aviso(STR0019,STR0404,{STR0243}, 2) //"Atenção!"###"É necessária a escolha de 2 revisões para comparação."###"Ok"
	lRetorno := .F.
	aCmp := {}
EndIf

Return lRetorno

//-----------------------------------------------------------------------
/*/{Protheus.doc} A600PrpSrv(oMdlADZ)
Verifica se os produtos estão vinculados ao Orçamento de Serviço no PMS

@sample A600PrpSrv(oMdlADZ)

@param	oMdlADZ		, Objeto	, Modelo de dados dos Produtos da Proposta Comercial

@author Squad CRM & Faturamento
@since  02/03/2020

@version 12.1.27
/*/
//-----------------------------------------------------------------------
Function A600PrpSrv(oMdlADZ)

	Local aArea		:= GetArea()
	Local nTamGrid	:= 0
	Local nItem		:= 0
	Local lRet		:= .T.

	Default oMdlADZ		:= Nil

	If SuperGetMV('MV_ORCSPMS',.F.,.F.) .AND. !oMdlADZ:IsEmpty()
		nTamGrid := oMdlADZ:Length()
		For nItem := 1 to nTamGrid
			If !oMdlADZ:IsDeleted(nItem) .AND. !Empty(oMdlADZ:GetValue('ADZ_PMS',nItem))
				lRet := .F.
				Exit
			EndIf
		Next nItem
	EndIf

	RestArea(aArea)
	aSize(aArea, 0)

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} A600TemPrSr(aGridPrSer)
Verifica se deve adotar o processo de geração da Grid de Produtos com base na nova integração via Proposta de Serviço no PMS

@sample A600TemPrSr(aGridPrSer)

@param	aGridPrSer		, Array		, Produtos a serem gravados na grid

@author Squad CRM & Faturamento
@since  02/03/2020

@version 12.1.27
/*/
//-----------------------------------------------------------------------
Function A600TemPrSr(aGridPrSer)

	Local aArea		:= GetArea()
	Local nTamGrid	:= 0
	Local nItem		:= 0
	Local nPosPMS	:= aScan(aGridPrSer[1][1],{|x| AllTrim(x[1]) == "ADZ_PMS"})
	Local lRet		:= .F.

	Default aGridPrSer		:= {}

	If SuperGetMV('MV_ORCSPMS',.F.,.F.)
		nTamGrid := Len(aGridPrSer)
		For nItem := 1 to nTamGrid
			If !Empty(aGridPrSer[nItem][1][nPosPMS][2])
				lRet := .T.
				Exit
			EndIf
		Next nItem
	EndIf

	RestArea(aArea)
	aSize(aArea, 0)

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} A600OrcSrv(oMdlADZ)
Verifica se os produtos não estão vinculados a Orçamento de Serviço no PMS

@sample A600OrcSrv(oMdlADZ)

@param	oMdlADZ		, Objeto	, Modelo de dados dos Produtos da Proposta Comercial

@author Squad CRM & Faturamento
@since  02/03/2020

@version 12.1.27
/*/
//-----------------------------------------------------------------------
Function A600OrcSrv(oMdlADZ)

	Local aArea		:= GetArea()
	Local nTamGrid	:= 0
	Local nItem		:= 0
	Local lRet		:= .F.

	Default oMdlADZ		:= Nil

	If SuperGetMV('MV_ORCSPMS',.F.,.F.) .AND. !oMdlADZ:IsEmpty()
		nTamGrid := oMdlADZ:Length()
		For nItem := 1 to nTamGrid
			If !oMdlADZ:IsDeleted(nItem) .AND. Empty(oMdlADZ:GetValue('ADZ_PMS',nItem))
				lRet := .T.
				Exit
			EndIf
		Next nItem
	EndIf

	RestArea(aArea)
	aSize(aArea, 0)

Return lRet