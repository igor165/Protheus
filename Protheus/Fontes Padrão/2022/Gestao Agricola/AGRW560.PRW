#INCLUDE "AGRW560.CH"
#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)

/*/{Protheus.doc} AGRW560
//Integracao da Situacao do Local de Producao
@author carlos.augusto/brunosilva
@since 24/05/2018
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Function AGRW560( cXML, nTypeTrans, cTypeMessage )
	Local aArea		:= GetArea()			//Salva contexto do alias atual  
	Local aSaveLine	:= FWSaveRows()		//Salva contexto do model ativo

	Local aRet 		  := {}				//Array de retorno da função
	Local lRet 		  := .T.			//Indica o resultado da execução da função
	Local cXMLRet	  := ''				//Xml que será enviado pela função
	Local cError	  := ''				//Mensagem de erro do parse no xml recebido como parâmetro
	Local cWarning	  := ''				//Mensagem de alerta do parse no xml recebido como parâmetro
	Local cEntity	  := 'PRODUCTIONSITESSITUATION'

	//--- Variaveis do Retorno - Função CFGA070Mnt [http://tdn.totvs.com/pages/viewpage.action?pageId=173083053]
	Local cReferen    := ''				//Referencia. Normalmente a "marca" da mensagem: PROTHEUS / LOGIX / RM / DATASUL, etc.
	Local cAlias	  := 'N9F'			//Alias do de/para (SA1, SA2, etc.)
	Local cField      := "N9F_CODANO"	//É o campo de referencia do De/para (A1_COD, B1_COD, etc. )
	Local cValExt	  := ''				//Código externo para gravacao - Código InternalId do PIMS
	Local cValInt	  := ''				//Código interno para gravação
	Local oXML 		  := Nil				//Objeto com o conteúdo do arquivo Xml
	Local oAgw560Ev	  := Nil				//Objeto com o conteúdo da BusinessEvent apenas
	Local oAgw560ct	  := Nil				//Objeto com o conteúdo da BusinessContent apenas
	Local cInternalId	:= ''
	Local cCompIntId	:= ''
	Local cCompId		:= ''
	Local cBranchInt    := ''
	Local cBranch       := ''
	Local cIntSafra     := ''
	Local cSafra        := ''
	Local cSafraDesc    := ''
	Local cProdPerIntId := ''
	Local cProdPer      := ''
	Local cClosDate     := ''
	Local cProdPerDesc  := ''
	Local cClassValIntId:= ''
	Local cClassValue   := ''
	Local cFarmIntId    := ''
	Local cFarmCode     := ''
	Local cCultIntId    := ''
	Local cCultCode     := ''
	Local cCultDesc     := ''
	Local cPltStartFor  := ''
	Local cClosPltFor   := ''
	Local cPlanStart    := ''
	Local cClosPlant    := ''
	Local cStHarvFor    := ''
	Local cClosHarvFor  := ''
	Local cStartHarv    := ''
	Local cClosHarv     := ''
	Local cStCotGinFor  := ''
	Local cClosCotGinFor:= ''
	Local cStCotGin     := ''
	Local cClosCotGin   := ''
	Local cPlPlTotAr    := ''
	Local cPlAreaHa     := ''
	Local cPlAreaPerc   := ''
	Local cHarvAreaHa   := ''
	Local cHarvAreaPer  := ''
	Local cPrPrvty      := ''
	Local cPrPrvtyKg    := ''
	Local cEstPrvty     := ''
	Local cEstPrvtyKg   := ''
	Local cObtPrvty     := ''
	Local cObtPrvtyKg   := ''
	Local cPrdNextMes   := ''
	Local cPrdNextQuin  := ''
	Local cPrdNextSem   := ''
	Local cPrdvNextMes  := ''
	Local cPrdvNextQuin := ''
	Local cPrdvNextSem  := ''
	Local cAPrvCNextSem := ''
	Local cAPrvCNextQui := ''
	Local cAPrvCNextMes := ''
	Local cCultAcmPrec  := ''
	Local cHarvAcmPrec  := ''
	Local cMonAcmPrec   := ''
	Local cWkAcmPrec    := ''
	Local cObtImpYldInd := ''
	Local cPrjImpYldInd := ''
	Local cObtRndYldInd := ''
	Local cPrjRndYldInd := ''
	Local cObtFbrYldInd := ''
	Local cPrjFbrYldInd := ''
	Local cObtSedYldInd := ''
	Local cPrjSedYldInd := ''
	Local cObtPlmYldInd := ''
	Local cPrjPlmYldInd := ''
	Local cObtPrdTon    := ''
	Local cObtPrdKg     := ''
	Local cObtPrdSc     := ''
	Local cEstPrdTon    := ''
	Local cEstPrdKg     := ''
	Local cEstPrdSc     := ''
	Local cPrjPrdTn     := ''
	Local cPrjPrdKg     := ''
	Local cPrjPrd       := ''
	Local cOP			:= ''
	Local aCampos		:= {}
	Local cQtdOp		:= ''

	Private lMSErroAuto := .F.
	Private lMSHelpAuto := .T.
	Private oAgw560Ev
	Private oAgw560ct

	dbSelectArea("N9F")
	N9F->(dbCloseArea())
	//*************************************
	// Trata o recebimento de mensagem                              
	//*************************************
	If ( nTypeTrans == TRANS_RECEIVE )

		//*********************************
		// Recebimento da Business Message
		//*********************************
		If ( cTypeMessage == EAI_MESSAGE_BUSINESS )
			oXML := tXmlManager():New()
			oXML := XmlParser( cXML, '_', @cError, @cWarning )	

			If ( ( oXML <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) )

				//-- Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") = "U" .And. !Empty(oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
					cReferen := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet := .F.
					cXmlRet := STR0003 //'Erro no retorno. A Referencia/Marca é obrigatória!'
					//Carrega array de retorno
					aRet := {lRet, cXmlRet,  "PRODUCTIONSITESSITUATION" } 
					Return aRet
				EndIf

				oAgw560Ev 	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent
				oAgw560ct 	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent

				Begin Transaction
					If ( XmlChildEx( oAgw560ct, '_MAINORDERCODE' ) != Nil) .And. .Not. Empty(oAgw560ct:_MainOrderCode:Text)
						cOP := oAgw560ct:_MainOrderCode:Text
						cOP := PADR(cOP,TamSx3("N9F_OP")[1] ," ")
						dbSelectArea("SC2")	//1C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD       
						SC2->(dbSetOrder(1)) //9C2_FILIAL+C2_NUM+C2_ITEM+C2_PRODUTO 
						lRet := DbSeek(fwxFilial("SC2")+ cOP + StrZero( 1 , TamSX3('C2_ITEM')[1]) + StrZero( 1 , TamSX3('C2_SEQUEN')[1]))
						If lRet
							If ( XmlChildEx( oAgw560ct, '_ESTIMATEDPRODUCTIONKG' ) != Nil) .And. .Not. Empty(oAgw560ct:_EstimatedProductionKg:Text)
								cQtdOp := oAgw560ct:_EstimatedProductionKg:Text
							ElseIf ( XmlChildEx( oAgw560ct, '_PROJECTEDPRODUCTIONKG' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProjectedProductionKg:Text)
								cQtdOp := oAgw560ct:_ProjectedProductionKg:Text
							EndIf

							If .Not. Empty(cQtdOp)

								//-- Campos para enviar ao MSExecAuto
								AADD(aCampos, {"C2_NUM"		, SC2->C2_NUM			,Nil})
								AADD(aCampos, {"C2_ITEM"	, SC2->C2_ITEM		   	,Nil})
								AADD(aCampos, {"C2_SEQUEN" 	, SC2->C2_SEQUEN		,Nil})
								AADD(aCampos, {"C2_PRODUTO"	, SC2->C2_PRODUTO		,Nil})
								AADD(aCampos, {"C2_QUANT"  	, AgrStrToNm(cQtdOp)	,Nil})	//-- Peso Liquido
								AADD(aCampos, {"C2_LOCAL"  	, SC2->C2_LOCAL			,Nil})		
								AADD(aCampos, {"C2_DATPRI" 	, SC2->C2_DATPRI		,Nil})
								AADD(aCampos, {"C2_DATPRF" 	, SC2->C2_DATPRF		,Nil})
								AADD(aCampos, {"C2_EMISSAO"	, SC2->C2_EMISSAO     	,Nil})
								AADD(aCampos, {"C2_TPOP"  	, 'F'		            ,Nil})	//-- F-Firme
								AADD(aCampos, {'AUTEXPLODE'	, 'S'					,Nil})

								//-- O parâmetro AUTEXPLODE, é preenchido na execução da rotina automática para definir se as OPs intermediárias
								//-- e as solicitações de compras, que ainda não foram geradas, devem ser geradas automaticamente ou não.

								//-- Executa a rotina automatica - Ordem de Produção
								MSExecAuto({|x,y| mata650(x,y)},aCampos,4) // 3=Inclusao, 5=Exclusão
								
								//Recupera as referencias
								oXML := tXmlManager():New()
								oXML := XmlParser( cXML, '_', @cError, @cWarning )
								oAgw560Ev	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent
								oAgw560ct 	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent
								
								If lMSErroAuto
									cXMLRet	:= MostraErro() 
									lRet	:= .F.
								EndIf
								
								
							EndIf
						Else 
							//"Ordem de produção não encontrada no Protheus: "
							cXMLRet	:= STR0006 + cOP + StrZero( 1 , TamSX3('C2_ITEM')[1]) + StrZero( 1 , TamSX3('C2_SEQUEN')[1])
							DisarmTransaction()
						EndIf
					EndIf

					If lRet

						//Código da Empresa
						If ( XmlChildEx( oAgw560ct, '_COMPANYID' ) != Nil ) .And. .Not. Empty(oAgw560ct:_CompanyId:Text)
							cCompId := PADR(oAgw560ct:_CompanyId:Text,TamSx3("N9F_CODEMP")[1] ," ")
						EndIf

						//Codigo da Filial
						If ( XmlChildEx( oAgw560ct, '_BRANCHID' ) != Nil ) .And. .Not. Empty(oAgw560ct:_BranchId:Text)
							cBranch := PADR(oAgw560ct:_BranchId:Text,TamSx3("N9F_FILIAL")[1] ," ")
						EndIf

						//Codigo do Ano Agrícola
						If ( XmlChildEx( oAgw560ct, '_AGRICULTURALYEARCODE' ) != Nil ) .And. .Not. Empty(oAgw560ct:_AgriculturalYearCode:Text)
							cSafra := PADR(oAgw560ct:_AgriculturalYearCode:Text,TamSx3("N9F_CODANO")[1] ," ")
						EndIf

						//Codigo de Producao
						If ( XmlChildEx( oAgw560ct, '_PRODUCTIONPERIODCODE' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProductionPeriodCode:Text)
							cProdPer := PADR(oAgw560ct:_ProductionPeriodCode:Text,TamSx3("N9F_CODPER")[1] ," ")
						EndIf

						//Data do fechamento da Situacao da Lavoura
						If ( XmlChildEx( oAgw560ct, '_CLOSINGDATE' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ClosingDate:Text)
							cClosDate := oAgw560ct:_ClosingDate:Text
							cClosDate := StrTran(cClosDate, "-", "")
						EndIf

						//N9F_CODEMP+N9F_FILIAL+N9F_CODANO+N9F_CODPER+DTOS(N9F_DTSITL)
						//N9F_FILIAL+N9F_CODEMP+N9F_CODANO+N9F_CODPER+DTOS(N9F_DTSITL) 
						dbSelectArea("N9F")
						N9F->(dbSetOrder(1)) 
						If DbSeek(cBranch + cCompId + cSafra + cProdPer + cClosDate) //aaaammdd
							Reclock("N9F",.F.)
						Else
							Reclock("N9F",.T.)
						EndIf

						//Ordem de Producao
						If ( XmlChildEx( oAgw560ct, '_MAINORDERCODE' ) != Nil ) .And. .Not. Empty(oAgw560ct:_MainOrderCode:Text)
							cOP := oAgw560ct:_MainOrderCode:Text
							N9F->N9F_OP := cOP
						EndIf

						//InternalId de Integração
						If ( XmlChildEx( oAgw560ct, '_INTERNALID' ) != Nil ) .And. .Not. Empty(oAgw560ct:_InternalID:Text)
							cInternalId := oAgw560ct:_InternalID:Text
						EndIf

						//InternalId da chave completa de empresa
						If ( XmlChildEx( oAgw560ct, '_COMPANYINTERNALID' ) != Nil ) .And. .Not. Empty(oAgw560ct:_CompanyInternalId:Text)
							cCompIntId := oAgw560ct:_CompanyInternalId:Text
						EndIf

						//InternalId da Filial
						If ( XmlChildEx( oAgw560ct, '_BRANCHINTERNALID' ) != Nil ) .And. .Not. Empty(oAgw560ct:_BranchInternalId:Text)
							cBranchInt := oAgw560ct:_BranchInternalId:Text
						EndIf

						//Internal Id do Ano Agrícola
						If ( XmlChildEx( oAgw560ct, '_AGRICULTURALYEARINTERNALID' ) != Nil ) .And. .Not. Empty(oAgw560ct:_AgriculturalYearInternalId:Text)
							cIntSafra := oAgw560ct:_AgriculturalYearInternalId:Text
						EndIf


						//InternalId do Periodo de Producao
						If ( XmlChildEx( oAgw560ct, '_PRODUCTIONPERIODINTERNALID' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProductionPeriodInternalId:Text)
							cProdPerIntId := oAgw560ct:_ProductionPeriodInternalId:Text
						EndIf


						//InternalId da Classe de Valor
						If ( XmlChildEx( oAgw560ct, '_CLASSVALUEINTERNALID' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ClassValueInternalId:Text)
							cClassValIntId := oAgw560ct:_ClassValueInternalId:Text
						EndIf


						//InternalId da Fazenda / Unidade Administrativa
						If ( XmlChildEx( oAgw560ct, '_FARMINTERNALID' ) != Nil ) .And. .Not. Empty(oAgw560ct:_FarmInternalId:Text)
							cFarmIntId := oAgw560ct:_FarmInternalId:Text
						EndIf

						//InternalId da Cultura
						If ( XmlChildEx( oAgw560ct, '_CULTUREINTERNALID' ) != Nil ) .And. .Not. Empty(oAgw560ct:_CultureInternalId:Text)
							cCultIntId := oAgw560ct:_CultureInternalId:Text
						EndIf

						//Código da Empresa
						If .Not. Empty(cCompId)
							N9F->N9F_CODEMP := cCompId
						EndIf

						//Codigo da Filial
						If  .Not. Empty(cBranch)
							N9F->N9F_FILIAL := cBranch
						EndIf

						//Codigo do Ano Agrícola
						If .Not. Empty(cSafra)
							N9F->N9F_CODANO := cSafra
						EndIf

						//Descricao do Ano Agrícola
						If ( XmlChildEx( oAgw560ct, '_AGRICULTURALYEARDESCRIPTION' ) != Nil ) .And. .Not. Empty(oAgw560ct:_AgriculturalYearDescription:Text)
							cSafraDesc := oAgw560ct:_AgriculturalYearDescription:Text
							N9F->N9F_DESANO := cSafraDesc
						EndIf

						//Codigo de Producao
						If .Not. Empty(cProdPer)
							N9F->N9F_CODPER := cProdPer
						EndIf

						//Descricao do Periodo de Producao
						If ( XmlChildEx( oAgw560ct, '_PRODUCTIONPERIODDESCRIPTION' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProductionPeriodDescription:Text)
							cProdPerDesc := oAgw560ct:_ProductionPeriodDescription:Text
							N9F->N9F_DESPER := cProdPerDesc
						EndIf			

						//Codigo da Classe de Valor
						If ( XmlChildEx( oAgw560ct, '_CLASSVALUECODE' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ClassValueCode:Text)
							cClassValue := oAgw560ct:_ClassValueCode:Text
							N9F->N9F_CLAVLR := cClassValue
						EndIf

						//Codigo da Fazenda / Unidade Administrativa
						If ( XmlChildEx( oAgw560ct, '_FARMCODE' ) != Nil ) .And. .Not. Empty(oAgw560ct:_FarmCode:Text)
							cFarmCode := oAgw560ct:_FarmCode:Text
							N9F->N9F_DESFAZ := cFarmCode
						EndIf

						//Codigo da Cultura
						If ( XmlChildEx( oAgw560ct, '_CULTURECODE' ) != Nil ) .And. .Not. Empty(oAgw560ct:_CultureCode:Text)
							cCultCode := oAgw560ct:_CultureCode:Text
							N9F->N9F_CODCUL := cCultCode
						EndIf

						//Descricao da Cultura
						If ( XmlChildEx( oAgw560ct, '_CULTUREDESCRIPTION' ) != Nil ) .And. .Not. Empty(oAgw560ct:_CultureDescription:Text)
							cCultDesc := oAgw560ct:_CultureDescription:Text
							N9F->N9F_DESCUL := cCultDesc
						EndIf

						//Data do fechamento da Situacao da Lavoura
						If .Not. Empty(cClosDate)
							N9F->N9F_DTSITL := STOD(cClosDate)
						EndIf

						//Data prevista para o início do plantio
						If ( XmlChildEx( oAgw560ct, '_PLANTATIONSTARTFORECAST' ) != Nil ) .And. .Not. Empty(oAgw560ct:_PlantationStartForecast:Text)
							cPltStartFor := oAgw560ct:_PlantationStartForecast:Text
							cPltStartFor := StrTran(cPltStartFor, "-", "")
							N9F->N9F_DTPRIN := STOD(cPltStartFor)
						EndIf		

						//Data prevista para o final do plantio
						If ( XmlChildEx( oAgw560ct, '_CLOSINGPLANTATIONFORECAST' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ClosingPlantationForecast:Text)
							cClosPltFor := oAgw560ct:_ClosingPlantationForecast:Text
							cClosPltFor := StrTran(cClosPltFor, "-", "")
							N9F->N9F_DTPRFM := STOD(cClosPltFor)
						EndIf		

						//Data de início do plantio
						If ( XmlChildEx( oAgw560ct, '_PLANTATIONSTART' ) != Nil ) .And. .Not. Empty(oAgw560ct:_PlantationStart:Text)
							cPlanStart := oAgw560ct:_PlantationStart:Text
							cPlanStart := StrTran(cPlanStart, "-", "")
							N9F->N9F_DTPLIN := STOD(cPlanStart)
						EndIf

						//Data prevista para o início da colheita
						If ( XmlChildEx( oAgw560ct, '_CLOSINGPLANTATION' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ClosingPlantation:Text)
							cClosPlant := oAgw560ct:_ClosingPlantation:Text
							cClosPlant := StrTran(cClosPlant, "-", "")
							N9F->N9F_DTPLFM := STOD(cClosPlant)
						EndIf

						//Data prevista para o início da colheita
						If ( XmlChildEx( oAgw560ct, '_STARTHARVESTFORECAST' ) != Nil ) .And. .Not. Empty(oAgw560ct:_StartHarvestForecast:Text)
							cStHarvFor := oAgw560ct:_StartHarvestForecast:Text
							cStHarvFor := StrTran(cStHarvFor, "-", "")
							N9F->N9F_DTPCOI := STOD(cStHarvFor)
						EndIf

						//Data prevista para o final da colheita
						If ( XmlChildEx( oAgw560ct, '_CLOSINGHARVESTFORECAST' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ClosingHarvestForecast:Text)
							cClosHarvFor := oAgw560ct:_ClosingHarvestForecast:Text
							cClosHarvFor := StrTran(cClosHarvFor, "-", "")
							N9F->N9F_DTPCOF := STOD(cClosHarvFor)
						EndIf

						//Data de início da colheita
						If ( XmlChildEx( oAgw560ct, '_STARTHARVEST' ) != Nil ) .And. .Not. Empty(oAgw560ct:_StartHarvest:Text)
							cStartHarv := oAgw560ct:_StartHarvest:Text
							cStartHarv := StrTran(cStartHarv, "-", "")
							N9F->N9F_DTCOIN := STOD(cStartHarv)
						EndIf

						//Data do final da colheita
						If ( XmlChildEx( oAgw560ct, '_CLOSINGHARVEST' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ClosingHarvest:Text)
							cClosHarv := oAgw560ct:_ClosingHarvest:Text
							cClosHarv := StrTran(cClosHarv, "-", "")
							N9F->N9F_DTCOFM := STOD(cClosHarv)
						EndIf

						//Data do final da colheita
						If ( XmlChildEx( oAgw560ct, '_STARTCOTTONGINFORECAST' ) != Nil ) .And. .Not. Empty(oAgw560ct:_StartCottonGinForecast:Text)
							cStCotGinFor := oAgw560ct:_StartCottonGinForecast:Text
							cStCotGinFor := StrTran(cStCotGinFor, "-", "")
							N9F->N9F_DPRBEI := STOD(cStCotGinFor)
						EndIf

						//Data prevista para o final do beneficiamento do algodao
						If ( XmlChildEx( oAgw560ct, '_CLOSINGCOTTONGINFORECAST' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ClosingCottonGinForecast:Text)
							cClosCotGinFor := oAgw560ct:_ClosingCottonGinForecast:Text
							cClosCotGinFor := StrTran(cClosCotGinFor, "-", "")
							N9F->N9F_DPRBEF := STOD(cClosCotGinFor)
						EndIf

						//Data de início do beneficiamento do algodao
						If ( XmlChildEx( oAgw560ct, '_STARTCOTTONGIN' ) != Nil ) .And. .Not. Empty(oAgw560ct:_StartCottonGin:Text)
							cStCotGin := oAgw560ct:_StartCottonGin:Text
							cStCotGin := StrTran(cStCotGin, "-", "")
							N9F->N9F_DTBEIN := STOD(cStCotGin)
						EndIf

						//Data de início do beneficiamento do algodao
						If ( XmlChildEx( oAgw560ct, '_CLOSINGCOTTONGIN' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ClosingCottonGin:Text)
							cClosCotGin := oAgw560ct:_ClosingCottonGin:Text
							cClosCotGin := StrTran(cClosCotGin, "-", "")
							N9F->N9F_DTBEFM := STOD(cClosCotGin)
						EndIf

						//Área total planejada para o plantio (ha)
						If ( XmlChildEx( oAgw560ct, '_PLANTATIONPLANNEDTOTALAREA' ) != Nil ) .And. .Not. Empty(oAgw560ct:_PlantationPlannedTotalArea:Text)
							cPlPlTotAr := oAgw560ct:_PlantationPlannedTotalArea:Text
							N9F->N9F_TOTPLA := AgrStrToNm(cPlPlTotAr)
						EndIf			

						//Área total plantada (ha)
						If ( XmlChildEx( oAgw560ct, '_PLANTEDAREAHA' ) != Nil ) .And. .Not. Empty(oAgw560ct:_PlantedAreaHa:Text)
							cPlAreaHa := oAgw560ct:_PlantedAreaHa:Text
							N9F->N9F_APLANT := AgrStrToNm(cPlAreaHa)
						EndIf			

						//Percentual de área plantada
						If ( XmlChildEx( oAgw560ct, '_PLANTEDAREAPERCENTAGE' ) != Nil ) .And. .Not. Empty(oAgw560ct:_PlantedAreaPercentage:Text)
							cPlAreaPerc := oAgw560ct:_PlantedAreaPercentage:Text
							N9F->N9F_PERPLA := AgrStrToNm(cPlAreaPerc)
						EndIf	

						//Total de área colhida (ha)
						If ( XmlChildEx( oAgw560ct, '_HARVESTEDAREAHA' ) != Nil ) .And. .Not. Empty(oAgw560ct:_HarvestedAreaHa:Text)
							cHarvAreaHa := oAgw560ct:_HarvestedAreaHa:Text
							N9F->N9F_ACOLHI := AgrStrToNm(cHarvAreaHa)
						EndIf	

						//Percentual de área colhida
						If ( XmlChildEx( oAgw560ct, '_HARVESTEDAREAPERCENTAGE' ) != Nil ) .And. .Not. Empty(oAgw560ct:_HarvestedAreaPercentage:Text)
							cHarvAreaPer := oAgw560ct:_HarvestedAreaPercentage:Text
							N9F->N9F_PERCOL := AgrStrToNm(cHarvAreaPer)
						EndIf					

						//Produtividade Projetada (sc ou @/ha)
						If ( XmlChildEx( oAgw560ct, '_PROJECTEDPRODUCTIVITY' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProjectedProductivity:Text)
							cPrPrvty := oAgw560ct:_ProjectedProductivity:Text
							N9F->N9F_PJSCHA := AgrStrToNm(cPrPrvty)
						EndIf

						//Produtividade Projetada (kg/ha)
						If ( XmlChildEx( oAgw560ct, '_PROJECTEDPRODUCTIVITYKG' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProjectedProductivityKg:Text)
							cPrPrvtyKg := oAgw560ct:_ProjectedProductivityKg:Text
							N9F->N9F_PJKGHA := AgrStrToNm(cPrPrvtyKg)
						EndIf
						
						
						//Produtividade Estimada (sc ou @/ha)
						If ( XmlChildEx( oAgw560ct, '_ESTIMATEDPRODUCTIVITY' ) != Nil ) .And. .Not. Empty(oAgw560ct:_EstimatedProductivity:Text)
							cEstPrvty := oAgw560ct:_EstimatedProductivity:Text
							N9F->N9F_PESCHA := AgrStrToNm(cEstPrvty)
						EndIf

						//Produtividade Estimada (kg/ha)
						If ( XmlChildEx( oAgw560ct, '_ESTIMATEDPRODUCTIVITYKG' ) != Nil ) .And. .Not. Empty(oAgw560ct:_EstimatedProductivityKg:Text)
							cEstPrvtyKg := oAgw560ct:_EstimatedProductivityKg:Text
							N9F->N9F_PEKGHA := AgrStrToNm(cEstPrvtyKg)
						EndIf

						//Produtividade Obtida (sc ou @/ha)
						If ( XmlChildEx( oAgw560ct, '_OBTAINEDPRODUCTIVITY' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ObtainedProductivity:Text)
							cObtPrvty := oAgw560ct:_ObtainedProductivity:Text
							N9F->N9F_POSCHA := AgrStrToNm(cObtPrvty)
						EndIf

						//Produtividade Obtida (sc ou @/ha) kg
						If ( XmlChildEx( oAgw560ct, '_OBTAINEDPRODUCTIVITYKG' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ObtainedProductivityKg:Text)
							cObtPrvtyKg := oAgw560ct:_ObtainedProductivityKg:Text
							N9F->N9F_POKGHA := AgrStrToNm(cObtPrvtyKg)
						EndIf

						//Codigo da produção prevista próximo mes
						If ( XmlChildEx( oAgw560ct, '_PRODUCTIONFORECASTNEXTMONTH' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProductionForecastNextMonth:Text)
							cPrdNextMes := oAgw560ct:_ProductionForecastNextMonth:Text
							N9F->N9F_PRPXME := AgrStrToNm(cPrdNextMes)
						EndIf

						//Codigo da produção prevista próxima quinzena
						If ( XmlChildEx( oAgw560ct, '_PRODUCTIONFORECASTNEXTFORTNIGHT' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProductionForecastNextFortnight:Text)
							cPrdNextQuin := oAgw560ct:_ProductionForecastNextFortnight:Text
							N9F->N9F_PRPXQN := AgrStrToNm(cPrdNextQuin)
						EndIf

						//Codigo da produção prevista próxima semana
						If ( XmlChildEx( oAgw560ct, '_PRODUCTIONFORECASTNEXTWEEK' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProductionForecastNextWeek:Text)
							cPrdNextSem := oAgw560ct:_ProductionForecastNextWeek:Text
							N9F->N9F_PRPXSM := AgrStrToNm(cPrdNextSem)
						EndIf

						//Codigo da produtividade prevista próximo mês
						If ( XmlChildEx( oAgw560ct, '_PRODUCTIVITYFORECASTNEXTMONTH' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProductivityForecastNextMonth:Text)
							cPrdvNextMes := oAgw560ct:_ProductivityForecastNextMonth:Text
							N9F->N9F_PDPXME := AgrStrToNm(cPrdvNextMes)
						EndIf

						//Codigo da produtividade prevista próxima quinzena
						If ( XmlChildEx( oAgw560ct, '_PRODUCTIVITYFORECASTNEXTFORTNIGHT' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProductivityForecastNextFortnight:Text)
							cPrdvNextQuin := oAgw560ct:_ProductivityForecastNextFortnight:Text
							N9F->N9F_PDPXQN := AgrStrToNm(cPrdvNextQuin)
						EndIf

						//Codigo da produtividade prevista próxima semana
						If ( XmlChildEx( oAgw560ct, '_PRODUCTIVITYFORECASTNEXTWEEK' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProductivityForecastNextWeek:Text)
							cPrdvNextSem := oAgw560ct:_ProductivityForecastNextWeek:Text
							N9F->N9F_PDPXSM := AgrStrToNm(cPrdvNextSem)
						EndIf

						//Codigo da area prevista colhida próxim mes
						If ( XmlChildEx( oAgw560ct, '_AREAFORECASTHARVESTEDNEXTMONTH' ) != Nil ) .And. .Not. Empty(oAgw560ct:_AreaForecastHarvestedNextMonth:Text)
							cAPrvCNextMes := oAgw560ct:_AreaForecastHarvestedNextMonth:Text
							N9F->N9F_CLPXSM := AgrStrToNm(cAPrvCNextMes)
						EndIf

						//Codigo da area prevista colhida próxima quinzena
						If ( XmlChildEx( oAgw560ct, '_AREAFORECASTHARVESTEDNEXTFORTNIGHT' ) != Nil ) .And. .Not. Empty(oAgw560ct:_AreaForecastHarvestedNextFortnight:Text)
							cAPrvCNextQui := oAgw560ct:_AreaForecastHarvestedNextFortnight:Text
							N9F->N9F_CLPXQN := AgrStrToNm(cAPrvCNextQui)
						EndIf

						//Codigo da area prevista colhida próxima quinzena
						If ( XmlChildEx( oAgw560ct, '_AREAFORECASTHARVESTEDNEXTWEEK' ) != Nil ) .And. .Not. Empty(oAgw560ct:_AreaForecastHarvestedNextWeek:Text)
							cAPrvCNextSem := oAgw560ct:_AreaForecastHarvestedNextWeek:Text
							N9F->N9F_CLPXME := AgrStrToNm(cAPrvCNextSem)
						EndIf

						//Precipitação acumulada da cultura (mm)
						If ( XmlChildEx( oAgw560ct, '_CULTUREACCUMULATEDPRECIPITATION' ) != Nil ) .And. .Not. Empty(oAgw560ct:_CultureAccumulatedPrecipitation:Text)
							cCultAcmPrec := oAgw560ct:_CultureAccumulatedPrecipitation:Text
							N9F->N9F_PACCLT := AgrStrToNm(cCultAcmPrec)
						EndIf

						//Precipitação acumulada da safra (mm)
						If ( XmlChildEx( oAgw560ct, '_HARVESTACCUMULATEDPRECIPITATION' ) != Nil ) .And. .Not. Empty(oAgw560ct:_HarvestAccumulatedPrecipitation:Text)
							cHarvAcmPrec := oAgw560ct:_HarvestAccumulatedPrecipitation:Text
							N9F->N9F_PACSAF := AgrStrToNm(cHarvAcmPrec)
						EndIf

						//Precipítação acumulada mensal (mm)
						If ( XmlChildEx( oAgw560ct, '_MONTHACCUMULATEDPRECIPITATION' ) != Nil ) .And. .Not. Empty(oAgw560ct:_MonthAccumulatedPrecipitation:Text)
							cMonAcmPrec := oAgw560ct:_MonthAccumulatedPrecipitation:Text
							N9F->N9F_PACMES := AgrStrToNm(cMonAcmPrec)
						EndIf

						//Precipitação acumulada semanal (mm)
						If ( XmlChildEx( oAgw560ct, '_WEEKACCUMULATEDPRECIPITATION' ) != Nil ) .And. .Not. Empty(oAgw560ct:_WeekAccumulatedPrecipitation:Text)
							cWkAcmPrec := oAgw560ct:_WeekAccumulatedPrecipitation:Text
							N9F->N9F_PACSEM := AgrStrToNm(cWkAcmPrec)
						EndIf

						//Índice percentual de rendimento de impurezas obtida
						If ( XmlChildEx( oAgw560ct, '_OBTAINEDIMPURITIESYIELDINDEX' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ObtainedImpuritiesYieldIndex:Text)
							cObtImpYldInd := oAgw560ct:_ObtainedImpuritiesYieldIndex:Text
							N9F->N9F_RNIMOB := AgrStrToNm(cObtImpYldInd)
						EndIf

						//Índice percentual de rendimento de impurezas projeto
						If ( XmlChildEx( oAgw560ct, '_PROJECTIMPURITIESYIELDINDEX' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProjectImpuritiesYieldIndex:Text)
							cPrjImpYldInd := oAgw560ct:_ProjectImpuritiesYieldIndex:Text
							N9F->N9F_RNIMPR := AgrStrToNm(cPrjImpYldInd)
						EndIf

						//Índice Percentual de rendimento de casquinha obtida
						If ( XmlChildEx( oAgw560ct, '_OBTAINEDRINDYIELDINDEX' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ObtainedRindYieldIndex:Text)
							cObtRndYldInd := oAgw560ct:_ObtainedRindYieldIndex:Text
							N9F->N9F_RNCAOB := AgrStrToNm(cObtRndYldInd)
						EndIf

						//Índice percentual de rendimento de casquinha projeto
						If ( XmlChildEx( oAgw560ct, '_PROJECTRINDYIELDINDEX' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProjectRindYieldIndex:Text)
							cPrjRndYldInd := oAgw560ct:_ProjectRindYieldIndex:Text
							N9F->N9F_RNCAPR := AgrStrToNm(cPrjRndYldInd)
						EndIf

						//Índice percentual de rendimento de fibrilha obtida
						If ( XmlChildEx( oAgw560ct, '_OBTAINEDFIBERYIELDINDEX' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ObtainedFiberYieldIndex:Text)
							cObtFbrYldInd := oAgw560ct:_ObtainedFiberYieldIndex:Text
							N9F->N9F_RNFBOB := AgrStrToNm(cObtFbrYldInd)
						EndIf

						//Índice percentual de rendimento de fibrilha projeto
						If ( XmlChildEx( oAgw560ct, '_PROJECTFIBERYIELDINDEX' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProjectFiberYieldIndex:Text)
							cPrjFbrYldInd := oAgw560ct:_ProjectFiberYieldIndex:Text
							N9F->N9F_RNFBPR := AgrStrToNm(cPrjFbrYldInd)
						EndIf

						//Índice percentual de rendimento de caroço obtida
						If ( XmlChildEx( oAgw560ct, '_OBTAINEDSEEDYIELDINDEX' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ObtainedSeedYieldIndex:Text)
							cObtSedYldInd := oAgw560ct:_ObtainedSeedYieldIndex:Text
							N9F->N9F_RNCROB := AgrStrToNm(cObtSedYldInd)
						EndIf

						//Índice percentual de rendimento de caroço projeto
						If ( XmlChildEx( oAgw560ct, '_PROJECTSEEDYIELDINDEX' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProjectSeedYieldIndex:Text)
							cPrjSedYldInd := oAgw560ct:_ProjectSeedYieldIndex:Text
							N9F->N9F_RNCRPR := AgrStrToNm(cPrjSedYldInd)
						EndIf

						//Índice percentual de rendimento pluma obtida
						If ( XmlChildEx( oAgw560ct, '_OBTAINEDPLUMEYIELDINDEX' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ObtainedPlumeYieldIndex:Text)
							cObtPlmYldInd := oAgw560ct:_ObtainedPlumeYieldIndex:Text
							N9F->N9F_RNPLOB := AgrStrToNm(cObtPlmYldInd)
						EndIf

						//Índice percentual de rendimento de pluma projeto
						If ( XmlChildEx( oAgw560ct, '_PROJECTPLUMEYIELDINDEX' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProjectPlumeYieldIndex:Text)
							cPrjPlmYldInd := oAgw560ct:_ProjectPlumeYieldIndex:Text
							N9F->N9F_RNPLPR := AgrStrToNm(cPrjPlmYldInd)
						EndIf

						//Produção Obtida (t)
						If ( XmlChildEx( oAgw560ct, '_OBTAINEDPRODUCTIONTON' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ObtainedProductionTon:Text)
							cObtPrdTon := oAgw560ct:_ObtainedProductionTon:Text
							N9F->N9F_PROBTN := AgrStrToNm(cObtPrdTon)
						EndIf

						//Produção Obtida (kg)
						If ( XmlChildEx( oAgw560ct, '_OBTAINEDPRODUCTIONKG' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ObtainedProductionKg:Text)
							cObtPrdKg := oAgw560ct:_ObtainedProductionKg:Text
							N9F->N9F_PROBKG := AgrStrToNm(cObtPrdKg)
						EndIf

						//Produção Obtida (sc ou @)
						If ( XmlChildEx( oAgw560ct, '_OBTAINEDPRODUCTION' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ObtainedProduction:Text)
							cObtPrdSc := oAgw560ct:_ObtainedProduction:Text
							N9F->N9F_PROBSA := AgrStrToNm(cObtPrdSc)
						EndIf

						//Produção Estimada (t)
						If ( XmlChildEx( oAgw560ct, '_ESTIMATEDPRODUCTIONTON' ) != Nil ) .And. .Not. Empty(oAgw560ct:_EstimatedProductionTon:Text)
							cEstPrdTon := oAgw560ct:_EstimatedProductionTon:Text
							N9F->N9F_PRETTN := AgrStrToNm(cEstPrdTon)
						EndIf

						//Produção Estimada (kg)
						If ( XmlChildEx( oAgw560ct, '_ESTIMATEDPRODUCTIONKG' ) != Nil ) .And. .Not. Empty(oAgw560ct:_EstimatedProductionKg:Text)
							cEstPrdKg := oAgw560ct:_EstimatedProductionKg:Text
							N9F->N9F_PRETKG := AgrStrToNm(cEstPrdKg)
						EndIf

						//Produção Estimada (Sc ou @)
						If ( XmlChildEx( oAgw560ct, '_ESTIMATEDPRODUCTION' ) != Nil ) .And. .Not. Empty(oAgw560ct:_EstimatedProduction:Text)
							cEstPrdSc := oAgw560ct:_EstimatedProduction:Text
							N9F->N9F_PRETSA := AgrStrToNm(cEstPrdSc)
						EndIf

						//Produção Projetada (t)
						If ( XmlChildEx( oAgw560ct, '_PROJECTEDPRODUCTIONTON' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProjectedProductionTon:Text)
							cPrjPrdTn := oAgw560ct:_ProjectedProductionTon:Text
							N9F->N9F_PRPJTN := AgrStrToNm(cPrjPrdTn)
						EndIf

						//Produção Projetada (kg
						If ( XmlChildEx( oAgw560ct, '_PROJECTEDPRODUCTIONKG' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProjectedProductionKg:Text)
							cPrjPrdKg := oAgw560ct:_ProjectedProductionKg:Text
							N9F->N9F_PRPJKG := AgrStrToNm(cPrjPrdKg)
							
							//Bruna
							//Atualiza Previsão de Venda de Pluma 
							UpdateSalesPrev(cOp, AgrStrToNm(cPrjPrdKg), cSafra) //Função responsável pela previsão de venda
						EndIf
												
						//Produção Projetada (Sc ou @)
						If ( XmlChildEx( oAgw560ct, '_PROJECTEDPRODUCTION' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ProjectedProduction:Text)
							cPrjPrd := oAgw560ct:_ProjectedProduction:Text
							N9F->N9F_PRPJSA := AgrStrToNm(cPrjPrd)
						EndIf
						
						//ENTIDADES CONTABEIS EXTRAS
						//Item Contábil
						If ( XmlChildEx( oAgw560ct, '_ACCOUNTINGITEMCODE' ) != Nil ) .And. .Not. Empty(oAgw560ct:_AccountingItemCode:Text)
							N9F->N9F_CDITEM := oAgw560ct:_AccountingItemCode:Text
						EndIf
						
						//Internal Id do Item Contábil
						If ( XmlChildEx( oAgw560ct, '_ACCOUNTINGITEMINTERNALID' ) != Nil ) .And. .Not. Empty(oAgw560ct:_AccountingItemInternalId:Text)
							N9F->N9F_IDITEM := oAgw560ct:_AccountingItemInternalId:Text
						EndIf
						
						//Entidade Contábil Gerencial 05
						If ( XmlChildEx( oAgw560ct, '_MANAGERIALACCOUNTINGENTITY05CODE' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ManagerialAccountingEntity05Code:Text)
							N9F->N9F_CDENT5 := oAgw560ct:_ManagerialAccountingEntity05Code:Text
						EndIf
						
						//Internal Id da Entidade Contabil Gerencial 05
						If ( XmlChildEx( oAgw560ct, '_MANAGERIALACCOUNTINGENTITY05INTERNALID' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ManagerialAccountingEntity05InternalId:Text)
							N9F->N9F_IDENT5 := oAgw560ct:_ManagerialAccountingEntity05InternalId:Text
						EndIf
						
						//Entidade Contábil Gerencial 06
						If ( XmlChildEx( oAgw560ct, '_MANAGERIALACCOUNTINGENTITY06CODE' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ManagerialAccountingEntity06Code:Text)
							N9F->N9F_CDENT6 := oAgw560ct:_ManagerialAccountingEntity06Code:Text
						EndIf
						
						//Internal Id da Entidade Contabil Gerencial 06
						If ( XmlChildEx( oAgw560ct, '_MANAGERIALACCOUNTINGENTITY06INTERNALID' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ManagerialAccountingEntity06InternalId:Text)
							N9F->N9F_IDENT6 := oAgw560ct:_ManagerialAccountingEntity06InternalId:Text
						EndIf
						
						//Entidade Contábil Gerencial 07
						If ( XmlChildEx( oAgw560ct, '_MANAGERIALACCOUNTINGENTITY07CODE' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ManagerialAccountingEntity07Code:Text)
							N9F->N9F_CDENT7 := oAgw560ct:_ManagerialAccountingEntity07Code:Text
						EndIf
						
						//Internal Id da Entidade Contabil Gerencial 07
						If ( XmlChildEx( oAgw560ct, '_MANAGERIALACCOUNTINGENTITY07INTERNALID' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ManagerialAccountingEntity07InternalId:Text)
							N9F->N9F_IDENT7 := oAgw560ct:_ManagerialAccountingEntity07InternalId:Text
						EndIf
						
						//Entidade Contábil Gerencial 08
						If ( XmlChildEx( oAgw560ct, '_MANAGERIALACCOUNTINGENTITY08CODE' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ManagerialAccountingEntity08Code:Text)
							N9F->N9F_CDENT8 := oAgw560ct:_ManagerialAccountingEntity08Code:Text
						EndIf
						
						//Internal Id da Entidade Contabil Gerencial 08
						If ( XmlChildEx( oAgw560ct, '_MANAGERIALACCOUNTINGENTITY08INTERNALID' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ManagerialAccountingEntity08InternalId:Text)
							N9F->N9F_IDENT8 := oAgw560ct:_ManagerialAccountingEntity08InternalId:Text
						EndIf
						
						//Entidade Contábil Gerencial 09
						If ( XmlChildEx( oAgw560ct, '_MANAGERIALACCOUNTINGENTITY09CODE' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ManagerialAccountingEntity09Code:Text)
							N9F->N9F_CDENT9 := oAgw560ct:_ManagerialAccountingEntity09Code:Text
						EndIf
						
						//Internal Id da Entidade Contabil Gerencial 09
						If ( XmlChildEx( oAgw560ct, '_MANAGERIALACCOUNTINGENTITY09INTERNALID' ) != Nil ) .And. .Not. Empty(oAgw560ct:_ManagerialAccountingEntity09InternalId:Text)
							N9F->N9F_IDENT9 := oAgw560ct:_ManagerialAccountingEntity09InternalId:Text
						EndIf


						N9F->(MsUnLock()) 
					EndIf

				End Transaction	
				If .Not. Empty(cXmlRet)
					cXMLRet := EncodeUTF8(cXmlRet)
					lRet := .F.
				Else

					cValExt := cInternalId
					cValInt := FWCodEmp() + "|" + FWCodFil() + "|" + cInternalId
					If ( Upper( oAgw560Ev:_Event:Text ) == 'UPSERT' )
						//--EMPRESA - FILIAL - CODIGO
						CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt , .T.,,, cEntity) 
						CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt , .F.,,, cEntity)
					Else
						CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt , .T.,,, cEntity)
					EndIf

					//-- Monta o XML de Retorno
					cXmlRet := "<ListOfInternalId>"
					cXmlRet +=    "<InternalId>"
					cXmlRet +=       "<Name>" + cEntity + "</Name>"
					cXmlRet +=       "<Origin>" + cValExt + "</Origin>"
					cXmlRet += 		 "<Destination>" + cValInt + "</Destination>"
					cXmlRet +=    "</InternalId>"
					cXmlRet += "</ListOfInternalId>"

				EndIf
			Else
				//Tratamento no erro do parse Xml
				lRet := .F.
				cXMLRet := STR0002 //'Erro na manipulação do Xml recebido. '
				cXMLRet += IIf ( !Empty(cError), cError, cWarning )

				cXMLRet := EncodeUTF8(cXMLRet)
			EndIf

			//----------------------------------------------------------------------
			//--- RECEBIMENTO DA RESPONSEMESSAGE 
			//-- QUEM RECEBE É O PIMS - O MESMO É TRATADO PELA EQUIPE DO PIMS
			//-- REALIZADO NO FONTE É PARA TESTE COM INTEGRAÇÃO PROTHEUS X PROTHEUS
			//----------------------------------------------------------------------
		ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )

			//--Faz o parser do XML de retorno em um objeto
			oXML := xmlParser(cXML, "_", @cError, @cWarning)

			//            lRet := .F.
			//	         cXmlRet := 'Mandar o erro aqui'
			//--------------------------------------------
			//--- RECEBIMENTO DA WHOIS   
			//--------------------------------------------			
		ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )
			cXMLRet := "1.000|1.001|1.002"
		EndIf

	ElseIf ( nTypeTrans == TRANS_SEND )

		//Monta Business Event
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=     '<Entity>'+ cEntity +'</Entity>'
		cXMLRet +=     '<Event>' + 'Upsert' + '</Event>'
		cXMLRet += '</BusinessEvent>'

		cXMLRet += '<BusinessContent>'
		cXMLRet +=    '<Code>001</Code>'
		cXMLRet +=    '<InternalID>0001</InternalID>' 
		cXMLRet +=    '<CompanyId>' + FWGrpCompany() + '</CompanyId>'
		cXMLRet +=    '<BranchInternalId>EMPMG01</BranchInternalId>'
		cXMLRet +=    '<BranchId>'  + FWCodFil() + '</BranchId>'
		cXMLRet +=    '<MainOrderCode>000180</MainOrderCode>'
		cXMLRet +=    '<AgriculturalYearInternalId>007</AgriculturalYearInternalId>'
		cXMLRet +=    '<AgriculturalYearCode>2018</AgriculturalYearCode>'
		cXMLRet +=    '<AgriculturalYearDescription>ANO 2018</AgriculturalYearDescription>'
		cXMLRet +=    '<ProductionPeriodInternalId>00120</ProductionPeriodInternalId>'
		cXMLRet +=    '<ProductionPeriodCode>002200</ProductionPeriodCode>'
		cXMLRet +=    '<ProductionPeriodDescription>PRODUCAO 2018</ProductionPeriodDescription>'
		cXMLRet +=    '<ClosingDate>2018-10-19</ClosingDate>'
		cXMLRet +=    '<ClassValueInternalId>0001</ClassValueInternalId>'
		cXMLRet +=    '<ClassValueCode>C0001</ClassValueCode>'
		cXMLRet +=    '<FarmInternalId>00001</FarmInternalId>'
		cXMLRet +=    '<FarmCode>F00001</FarmCode>'
		cXMLRet +=    '<CultureInternalId>00001</CultureInternalId>'
		cXMLRet +=    '<CultureCode>CT00001</CultureCode>'
		cXMLRet +=    '<CultureDescription>CULTURA001</CultureDescription>'
		cXMLRet +=    '<PlantationStartForecast>2018-06-01</PlantationStartForecast>'
		cXMLRet +=    '<ClosingPlantationForecast>2018-12-31</ClosingPlantationForecast>'
		cXMLRet +=    '<PlantationStart>2018-06-15</PlantationStart>'
		cXMLRet +=    '<ClosingPlantation>2018-12-25</ClosingPlantation>'
		cXMLRet +=    '<StartHarvestForecast>2018-06-20</StartHarvestForecast>'
		cXMLRet +=    '<ClosingHarvestForecast>2018-12-24</ClosingHarvestForecast>'
		cXMLRet +=    '<StartHarvest>2018-06-20</StartHarvest>'
		cXMLRet +=    '<ClosingHarvest>2018-12-24</ClosingHarvest>'
		cXMLRet +=    '<StartCottonGinForecast>2018-06-19</StartCottonGinForecast>'
		cXMLRet +=    '<ClosingCottonGinForecast>2018-12-26</ClosingCottonGinForecast>'
		cXMLRet +=    '<StartCottonGin>2018-06-19</StartCottonGin>'
		cXMLRet +=    '<ClosingCottonGin>2018-12-26</ClosingCottonGin>'
		cXMLRet +=    '<PlantationPlannedTotalArea>1300000</PlantationPlannedTotalArea>'
		cXMLRet +=    '<PlantedAreaHa>900</PlantedAreaHa>'
		cXMLRet +=    '<PlantedAreaPercentage>93</PlantedAreaPercentage>'
		cXMLRet +=    '<HarvestedAreaHa>869</HarvestedAreaHa>'
		cXMLRet +=    '<HarvestedAreaPercentage>90</HarvestedAreaPercentage>'
		cXMLRet +=    '<ProjectedProductivity>10000</ProjectedProductivity>'
		cXMLRet +=    '<ProjectedProductivityKg>60000</ProjectedProductivityKg>'
		cXMLRet +=    '<EstimatedProductivity>100000</EstimatedProductivity>'
		cXMLRet +=    '<EstimatedProductivityKg>600000</EstimatedProductivityKg>'
		cXMLRet +=    '<ObtainedProductivity>99900</ObtainedProductivity>'
		cXMLRet +=    '<ObtainedProductivityKg>578000</ObtainedProductivityKg>'
		cXMLRet +=    '<ProjectedProduction>15000</ProjectedProduction>'
		cXMLRet +=    '<ProjectedProductionKg>90000</ProjectedProductionKg>'
		cXMLRet +=    '<ProjectedProductionTon>90000</ProjectedProductionTon>'
		cXMLRet +=    '<EstimatedProduction>165000</EstimatedProduction>'
		cXMLRet +=    '<EstimatedProductionKg>1070.000</EstimatedProductionKg>'
		cXMLRet +=    '<EstimatedProductionTon>10700</EstimatedProductionTon>'
		cXMLRet +=    '<ObtainedProduction>14000</ObtainedProduction>'
		cXMLRet +=    '<ObtainedProductionKg>89500</ObtainedProductionKg>'
		cXMLRet +=    '<ObtainedProductionTon>8950</ObtainedProductionTon>'
		cXMLRet +=    '<ProjectPlumeYieldIndex>0.45</ProjectPlumeYieldIndex>'
		cXMLRet +=    '<ObtainedPlumeYieldIndex>0.4</ObtainedPlumeYieldIndex>'
		cXMLRet +=    '<ProjectSeedYieldIndex>0.5</ProjectSeedYieldIndex>'
		cXMLRet +=    '<ObtainedSeedYieldIndex>0.45</ObtainedSeedYieldIndex>'
		cXMLRet +=    '<ProjectFiberYieldIndex>0.65</ProjectFiberYieldIndex>'
		cXMLRet +=    '<ObtainedFiberYieldIndex>0.5</ObtainedFiberYieldIndex>'
		cXMLRet +=    '<ProjectRindYieldIndex>0.4</ProjectRindYieldIndex>'
		cXMLRet +=    '<ObtainedRindYieldIndex>0.5</ObtainedRindYieldIndex>'
		cXMLRet +=    '<ProjectImpuritiesYieldIndex>0.1</ProjectImpuritiesYieldIndex>'
		cXMLRet +=    '<ObtainedImpuritiesYieldIndex>0.15</ObtainedImpuritiesYieldIndex>'
		cXMLRet +=    '<WeekAccumulatedPrecipitation>100</WeekAccumulatedPrecipitation>'
		cXMLRet +=    '<MonthAccumulatedPrecipitation>500</MonthAccumulatedPrecipitation>'
		cXMLRet +=    '<HarvestAccumulatedPrecipitation>1500</HarvestAccumulatedPrecipitation>'
		cXMLRet +=    '<CultureAccumulatedPrecipitation>15600</CultureAccumulatedPrecipitation>'
		cXMLRet +=    '<AreaForecastHarvestedNextWeek>2000</AreaForecastHarvestedNextWeek>'
		cXMLRet +=    '<AreaForecastHarvestedNextFortnight>2500</AreaForecastHarvestedNextFortnight>'
		cXMLRet +=    '<AreaForecastHarvestedNextMonth>2.500</AreaForecastHarvestedNextMonth>'
		cXMLRet +=    '<ProductivityForecastNextWeek>15</ProductivityForecastNextWeek>'
		cXMLRet +=    '<ProductivityForecastNextFortnight>35</ProductivityForecastNextFortnight>'
		cXMLRet +=    '<ProductivityForecastNextMonth>59</ProductivityForecastNextMonth>'
		cXMLRet +=    '<ProductionForecastNextWeek>78</ProductionForecastNextWeek>'
		cXMLRet +=    '<ProductionForecastNextFortnight>67</ProductionForecastNextFortnight>'
		cXMLRet +=    '<ProductionForecastNextMonth>98</ProductionForecastNextMonth>'
		cXMLRet += '</BusinessContent>'
	EndIf

	//Carrega array de retorno
	aRet := {lRet, cXmlRet, "PRODUCTIONSITESSITUATION"}

	//Restaura ambiente
	FWRestRows( aSaveLine )     
	RestArea(aArea)

Return aRet


/*/{Protheus.doc} UpdateSalesPrev
//TODO Descrição auto-gerada.
@author bruna.rocio
@since 16/02/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function UpdateSalesPrev(cOp, nQtdOp, cSafra)
	Local aArea := GetArea()

	dbSelectArea("SC2")	//1C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD       
	SC2->(dbSetOrder(1)) //9C2_FILIAL+C2_NUM+C2_ITEM+C2_PRODUTO 
	lRet := DbSeek(fwxFilial("SC2")+ cOP + StrZero( 1 , TamSX3('C2_ITEM')[1]) + StrZero( 1 , TamSX3('C2_SEQUEN')[1]))

	If lRet

		dbSelectArea('DXE')
		dbSetOrder(1)
		If dbSeek(fwxFilial('DXE'))

			dbSelectArea('DXC')
			dbSetOrder(4)
			If dbSeek(fwxFilial('DXC')+DXE->DXE_CODIGO+SC2->C2_PRODUTO)
			
				If DXC->DXC_PLUMA = '1'
	
					dbSelectArea('SC4')
					dbSetOrder(1)
					If dbSeek(fwxFilial('SC4')+DXC->DXC_PRDPRO+DXE->DXE_DTFINB)
						If RecLock('SC4',.F.)
							SC4->C4_QUANT   := (nQtdOp * DXE->DXE_RDMED) / 100 //Rendimento médio esperado de pluma
						Endif
						SC4->(dbUnlock())
					Else	
						If RecLock('SC4',.T.)
							SC4->C4_FILIAL  := fwxFilial('SC4') 
							SC4->C4_PRODUTO := DXC->DXC_PRDPRO
							SC4->C4_LOCAL   := DXC->DXC_LOCPRD
							SC4->C4_QUANT   := (nQtdOp * DXE->DXE_RDMED) / 100 //Rendimento médio esperado de pluma
							SC4->C4_DATA    := DXE->DXE_DTFINB
							SC4->C4_OBS     := "SAFRA " + cSafra
						Endif
						SC4->(dbUnlock())
					Endif
				Endif
			Endif		
		Endif
	Endif
	RestArea(aArea)	
Return .T.
