#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'TECA800.CH'
#INCLUDE 'LOCACAO.CH'

#Define DF_HORIMETRO_FASE_SEPARACAO "SEP"
#Define DF_HORIMETRO_FASE_RETORNO   "RET"

Static cUsaLocEqp := '0'
//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA800
	Visualizar dos registros de movimentação dos equipamentos
@sample 	TECA800()
@since		06/09/2013
@version	P11.90 
@param  	cFilter, caracter, conteúdo padrão para filtro dos dados no browse
/*/
//------------------------------------------------------------------------------
Function TECA800( cFilter )

Local oBrwLocacao := FwMBrowse():New()
Local cFilObrigat := "TEW->TEW_TIPO == '1' .Or. TEW->TEW_TIPO == ' ' "
Local oTableAtt   := TableAttDef()
Local lHasReserva := ( FindFunction('TECA825') .And. TEW->( FieldPos('TEW_TIPO') ) > 0 )

DEFAULT cFilter := ""

oBrwLocacao:SetAlias( 'TEW' )
oBrwLocacao:SetMenudef( "TECA800" )
oBrwLocacao:SetDescription( OEmToAnsi( STR0001 ) ) // "Movimentos dos Equipamentos de Locação"
oBrwLocacao:SetViewsDefault(oTableAtt:aViews)
oBrwLocacao:SetChartsDefault(oTableAtt:aCharts)
oBrwLocacao:SetAttach(.T.)
oBrwLocacao:SetOpenChart(.F.)

If !Empty( cFilter )
	If lHasReserva
		cFilter := cFilObrigat + ".And." + cFilter
	EndIf
	oBrwLocacao:SetFilterDefault( cFilter )
ElseIf lHasReserva
	oBrwLocacao:SetFilterDefault( cFilObrigat )
EndIf

//----------------------------------------
//	Adicionando filtros padrões

oBrwLocacao:AddFilter( STR0002, "TEW->TEW_DTSEPA == CTOD('')")											// 'Equipamentos não separados'
oBrwLocacao:AddFilter( STR0003, "TEW->TEW_DTSEPA <> CTOD('') .And. TEW->TEW_DTRINI == CTOD('')")	// 'Equipamentos separados'
oBrwLocacao:AddFilter( STR0004, "TEW->TEW_DTRINI <> CTOD('') .And. TEW->TEW_DTRFIM == CTOD('')")	// 'Equipamentos alocados'
oBrwLocacao:AddFilter( STR0005, "TEW->TEW_DTRFIM <> CTOD('')")											// 'Equipamentos devolvidos'
oBrwLocacao:AddFilter( STR0006, "!Empty(TEW->TEW_NUMOS) .And. TEW->TEW_FECHOS == CTOD('')")		// 'Equipamentos em manutenção'
oBrwLocacao:AddFilter( STR0007, "TEW->TEW_MOTIVO <> ' '")												// 'Locações com intervenção'
oBrwLocacao:AddFilter( STR0008, "TEW->TEW_DTRFIM == CTOD('') .And. TEW->TEW_MOTIVO <> ' '")		// 'Locações com intervenção e não devolvidas'
oBrwLocacao:AddFilter( STR0009, "TEW->TEW_DTRFIM <> CTOD('') .And. TEW->TEW_MOTIVO <> ' '")		// 'Locações com intervenção e devolvidas '
oBrwLocacao:AddFilter( STR0010, "!Empty(TEW->TEW_CODKIT)")												// 'Kits locados'
oBrwLocacao:AddFilter( STR0011, "TEW->TEW_MOTIVO == '1'")												// 'Locações substituídas'
oBrwLocacao:AddFilter( STR0012, "TEW->TEW_MOTIVO == '2'")												// 'Locações canceladas'

//----------------------------------------
oBrwLocacao:AddLegend( "TEW->TEW_DTSEPA == CTOD('')",                                                                       "RED",    STR0036)  // "Equipamento não separado"
oBrwLocacao:AddLegend( "TEW->TEW_DTSEPA <> CTOD('') .And. TEW->TEW_DTRINI == CTOD('')",                                     "PINK",   STR0037)  // "Separado"
oBrwLocacao:AddLegend( "TEW->TEW_MOTIVO <> '1' .And. TEW->TEW_MOTIVO <>'2' .And. TEW->TEW_QTDRET == 0 .And. "+;
                       "TEW->TEW_DTRINI <> CTOD('') .And. TEW->TEW_DTRFIM == CTOD('')",                                     "GREEN",  STR0038)  // "Alocado"

oBrwLocacao:AddLegend( "TEW->TEW_MOTIVO==' ' .And. TEW->TEW_QTDVEN > TEW->TEW_QTDRET .And. ( ( Empty(TEW->TEW_NUMOS) ) .Or. ";
		+ " ( !Empty(TEW->TEW_NUMOS) .And. TEW->TEW_FECHOS <> CTOD('')) )",;
	"BR_VIOLETA", "Parcialmente Devolvido"  )  // "Parcialmente Devolvido"
	
oBrwLocacao:AddLegend( "TEW->TEW_MOTIVO == ' ' .And. ( ( TEW->TEW_DTRFIM <> CTOD('') .And. Empty(TEW->TEW_NUMOS) ) .Or. "+;
                       "( TEW->TEW_DTRFIM <> CTOD('') .And. !Empty(TEW->TEW_NUMOS) .And. TEW->TEW_FECHOS <> CTOD('')) )",   "BLACK",  STR0039)  // "Devolvido"
oBrwLocacao:AddLegend( "TEW->TEW_DTRFIM <> CTOD('') .And. !Empty(TEW->TEW_NUMOS) .And. TEW->TEW_FECHOS == CTOD('')",        "ORANGE", STR0040)  // "Devolvido e Em manutenção"
oBrwLocacao:AddLegend( "TEW->TEW_MOTIVO == '1' .And. TEW->TEW_DTRFIM == CTOD('')",                                          "WHITE",  STR0041)  // "Substituído e Não devolvido"
oBrwLocacao:AddLegend( "TEW->TEW_MOTIVO == '2' .And. TEW->TEW_DTRFIM == CTOD('')",                                          "BROWN",  STR0042)  // "Cancelado e Não devolvido"
oBrwLocacao:AddLegend( "TEW->TEW_MOTIVO == '1' .And. TEW->TEW_DTRFIM <> CTOD('')",                                          "BLUE",   STR0043)  // "Substituído e Devolvido"
oBrwLocacao:AddLegend( "TEW->TEW_MOTIVO == '2' .And. TEW->TEW_DTRFIM <> CTOD('')",                                          "YELLOW", STR0044)  // "Cancelado e Devolvido"

oBrwLocacao:DisableDetails()
oBrwLocacao:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
	Rotina para construção do menu
@sample 	Menudef()
@since		06/09/2013
@version 	P11.90
@return 	aMenu, ARRAY, lista de opções disponíveis para usuário x rotina
/*/
//------------------------------------------------------------------------------
Static Function Menudef()

Local aMenu := {}

Local aInterv  := {	{ STR0013, "At801Subs", 0, 4, 0, Nil} ,; // 'Substituição'
						{ STR0014, "At802Canc", 0, 4, 0, Nil} }  // 'Cancelamento'

Local aChkList := { 	{ STR0082, "At806Saida", 0 , MODEL_OPERATION_UPDATE, 0, NIL} ,; // 'Saida'
						{ STR0083, "At806Retor", 0 , MODEL_OPERATION_UPDATE, 0, NIL} }  // 'Retorno

aAdd(aMenu,{ STR0015, "PesqBrw",         0, 1, 0, .T. } ) // 'Pesquisar'
aAdd(aMenu,{ STR0092, "At800SepCan",     0, 1, 0, .T. } ) // "Desfazer Separação"
aAdd(aMenu,{ STR0054, "At800LibLoc",     0, 1, 0, .T. } ) // "Liberação de Locação"
aAdd(aMenu,{ STR0055, "At800CancLib",    0, 1, 0, .T. } ) // "Cancelamento de Liberação"
aAdd(aMenu,{ STR0056, "At800RetLib",     0, 1, 0, .T. } ) // "Retorno de Locação"
aAdd(aMenu,{ STR0057, "At800CancRet",    0, 1, 0, .T. } ) // "Cancelamento do Retorno"
aAdd(aMenu,{ STR0016, "VIEWDEF.TECA800", 0, 2, 0, .T. } ) // 'Visualizar'
aAdd(aMenu,{ STR0017, aInterv,           0, 4, 0, .F. } ) // 'Intervenção'
aAdd(aMenu,{ STR0069, "TECR070()",       0, 2, 0, .T. } ) // 'Relatório de Picking'
aAdd(aMenu,{ STR0081, aChkList,          0, MODEL_OPERATION_UPDATE, 0, .T. } ) // 'Checklist'
aAdd(aMenu,{ STR0088, "A800ConfEC",      0, MODEL_OPERATION_UPDATE, 0, .T. } ) // "Confirmação de entrega e coleta"

Return aMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@since 06/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStr1 := FWFormStruct(1,'TEW')
Local oStr2 := FWFormStruct(1,'TWR')
Local oStr3 := FWFormStruct(1,'TWI')
Local oStr4 := FWFormStruct(1,'TWP')

oStr2:SetProperty("TWR_CODTFI",MODEL_FIELD_INIT,{|| Posicione("TEW",1,xFilial("TEW")+TWR->TWR_CODMOV,"TEW_CODEQU") })
oStr2:SetProperty("TWR_NUMSER",MODEL_FIELD_INIT,{|| Posicione("TEW",1,xFilial("TEW")+TWR->TWR_CODMOV,"TEW_BAATD") })
oStr2:SetProperty("TWR_CLIENT",MODEL_FIELD_INIT,{|| Posicione("SC5",1,TWR->(TWR_FILPED+TWR_NUMPED),"C5_CLIENTE") })
oStr2:SetProperty("TWR_LOJACL",MODEL_FIELD_INIT,{|| Posicione("SC5",1,TWR->(TWR_FILPED+TWR_NUMPED),"C5_LOJACLI") })
oStr2:SetProperty("TWR_CNPJ",MODEL_FIELD_INIT,{|| At800InfByPV( "SA1", "A1_CGC", TWR->(TWR_FILPED+TWR_NUMPED), .T. ) })
oStr2:SetProperty("TWR_NOME",MODEL_FIELD_INIT,{|| At800InfByPV( "SA1", "A1_NOME", TWR->(TWR_FILPED+TWR_NUMPED), .T. ) })
oStr2:SetProperty("TWR_CONDPG",MODEL_FIELD_INIT,{|| Posicione("SC5",1,TWR->(TWR_FILPED+TWR_NUMPED),"C5_CONDPAG") })
oStr2:SetProperty("TWR_CLENTR",MODEL_FIELD_INIT,{|| Posicione("SC5",1,TWR->(TWR_FILPED+TWR_NUMPED),"C5_CLIENT") })
oStr2:SetProperty("TWR_LOJENT",MODEL_FIELD_INIT,{|| Posicione("SC5",1,TWR->(TWR_FILPED+TWR_NUMPED),"C5_LOJAENT") })
oStr2:SetProperty("TWR_CNPJEN",MODEL_FIELD_INIT,{|| At800InfByPV( "SA1", "A1_CGC", TWR->(TWR_FILPED+TWR_NUMPED), .F. ) })
oStr2:SetProperty("TWR_NOMENT",MODEL_FIELD_INIT,{|| At800InfByPV( "SA1", "A1_NOME", TWR->(TWR_FILPED+TWR_NUMPED), .F. ) })
oStr2:SetProperty("TWR_TES",MODEL_FIELD_INIT,{|| Posicione("SC6",1,TWR->(TWR_FILPED+TWR_NUMPED+TWR_PEDIT),"C6_TES") })
oStr2:SetProperty("TWR_PRODUT",MODEL_FIELD_INIT,{|| Posicione("SC6",1,TWR->(TWR_FILPED+TWR_NUMPED+TWR_PEDIT),"C6_PRODUTO") })

oModel := MPFormModel():New('TECA800')
oModel:AddFields('MOVIM',,oStr1)
oModel:AddGrid('PEDADIC','MOVIM',oStr2)
oModel:AddGrid('MOVQTSAIDA','MOVIM',oStr3)
oModel:AddGrid('MOVQTRETORNO','MOVIM',oStr4)

oModel:SetRelation('PEDADIC', {{"TWR_FILIAL","xFilial('TWR')"},{"TWR_CODMOV","TEW_CODMV"}}, TWR->(IndexKey(1)))
oModel:SetRelation('MOVQTSAIDA', {{"TWI_FILIAL","xFilial('TWI')"},{"TWI_IDREG","TEW_CODMV"}}, TWI->(IndexKey(1)))
oModel:SetRelation('MOVQTRETORNO', {{"TWP_FILIAL","xFilial('TWP')"},{"TWP_IDREG","TEW_CODMV"}}, TWP->(IndexKey(1)))

oModel:GetModel('PEDADIC'):SetOptional(.T.)
oModel:GetModel('PEDADIC'):SetOnlyQuery(.T.)

oModel:GetModel('MOVQTSAIDA'):SetOptional(.T.)
oModel:GetModel('MOVQTSAIDA'):SetOnlyQuery(.T.)

oModel:GetModel('MOVQTRETORNO'):SetOptional(.T.)
oModel:GetModel('MOVQTRETORNO'):SetOnlyQuery(.T.)

oModel:SetDescription(STR0018) // 'Movimentação Equipamentos'
oModel:GetModel('MOVIM'):SetDescription(STR0018) // 'Movimentação Equipamentos'
oModel:GetModel('PEDADIC'):SetDescription(STR0093) // "Pedidos adicionais de remessa"
oModel:GetModel('MOVQTSAIDA'):SetDescription(STR0094) // "Informações do movimento de saída"
oModel:GetModel('MOVQTRETORNO'):SetDescription(STR0095) // "Informações do movimento de retorno"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@since 06/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView  := Nil
Local oModel := ModelDef()
Local oStr1  := FWFormStruct(2, 'TEW')
Local oStr2  := FWFormStruct(2, 'TWR')
Local oStr3  := FWFormStruct(2, 'TWI')
Local oStr4  := FWFormStruct(2, 'TWP')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('view_movi' , oStr1,'MOVIM' )
oView:AddGrid('view_pedadc' , oStr2,'PEDADIC' )
oView:AddGrid('view_movsai' , oStr3,'MOVQTSAIDA' )
oView:AddGrid('view_movret' , oStr4,'MOVQTRETORNO' )

oView:CreateHorizontalBox( 'VIEW', 100)
oView:CreateFolder( "ABASSUP", "VIEW" )
oView:AddSheet("ABASSUP", "ABASUP01", STR0096)	//"Dados da movimentação"
oView:AddSheet("ABASSUP", "ABASUP02", STR0097)	//"Informações adicionais"

oView:CreateHorizontalBox('VIEW_FIELD', 100,,, "ABASSUP", "ABASUP01")
oView:CreateHorizontalBox('VIEW_GRID1', 50,,, "ABASSUP", "ABASUP02")

oView:CreateHorizontalBox('VIEW_GRIDS', 50,,, "ABASSUP", "ABASUP02")

oView:CreateFolder( "GRIDS_INF", 'VIEW_GRIDS' )
oView:AddSheet("GRIDS_INF", "ABAINF01", STR0098)	//"Saída - Não ID único"
oView:AddSheet("GRIDS_INF", "ABAINF02", STR0099)	//"Retorno - Não ID único"

oView:CreateHorizontalBox('GRID_ESQ', 100,,, "GRIDS_INF", "ABAINF01")
oView:CreateHorizontalBox('GRID_DIR', 100,,, "GRIDS_INF", "ABAINF02")

oView:SetOwnerView('view_movi','VIEW_FIELD')
oView:SetOwnerView('view_pedadc','VIEW_GRID1')
oView:SetOwnerView('view_movsai','GRID_ESQ')
oView:SetOwnerView('view_movret','GRID_DIR')

oView:EnableTitleView('view_movi', STR0018 )  // 'Movimentação Equipamentos'

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} At800Start
	Gera o movimento inicial com os dados de proposta e produto para
a quantidade daquele item de locação

@sample 	At800Start()

@since  	06/09/2013
@version 	P11.90
@param  	ExpC, CHAR, conteúdo do erro identificado (par. Referência)
@param  	ExpC, CHAR, Codigo da prosposta para pesquisa na tabela TFI
@param		ExpC, CHAR, Codigo da requisicao de equipamentos para atendentes da tabela TGQ quando for referente a esse tipo de movimento
/*/
//-------------------------------------------------------------------
Function At800Start( cMsgErro, cCodOrcSer, cRequisicao, cCodSep )

Local lRet        := .T.
Local oMdlLocacao := Nil
Local nX          := 1

Local lProdKit     := .F.
Local nContKit     := 1
Local cSeqKit      := ""
Local cCodTEW	   := ""
Local cCodTFI	   := ""
Local cCodSqKit	   := ""
Local cCodProd	   := ""
Local cProdKit	   := ""

Local cTabQry      := GetNextAlias()
Local aSave        := GetArea()
Local aSaveTFJ     := TFJ->( GetArea() )
Local aSaveTFL     := TFL->( GetArea() )
Local aSaveTFI     := TFI->( GetArea() )
Local lTecAtf	   := SuperGetMv('MV_TECATF', .F.,'N') == 'S'
Local lNoId		   := .F. //Não controla ID único. .T. = Sim / .F. = Nâo

Local nTamSX8      := GetSx8Len()

DEFAULT cMsgErro   := ""
DEFAULT cCodOrcSer := ""
DEFAULT cRequisicao:= ""
DEFAULT cCodSep    := ""

Begin Transaction

// Possibilidade de evitar antes de chamar a rotina para criação dos movimentos
If !Empty(cRequisicao) .Or. !Empty(cCodOrcSer)
	If !Empty(cCodOrcSer)
		If !Empty( cCodOrcSer )
			TFJ->( DbSetOrder( 1 ) ) // TFJ_FILIAL+TFJ_CODIGO
			lRet := TFJ->( DbSeek( xFilial("TFJ")+cCodOrcSer ) )
		Else
			lRet := .F.
			cMsgErro := STR0019 // 'Orçamento de Serviços não encontrado'
		EndIf


		// ---------------------------------------------------------------------------------
		//   Faz a iteração pelos registros da TFI considerando a quantidade inserida para
		// cada item e verificando se o produto corresponde a Kit para Locação
		// Caso seja kit, irá iterar na tabela TEZ e gerar os movimentos conforme a quantidade
		// informada para a composição do kit... ficando assim
		// Exemplo.:
		//      Supondo o kit 1 = 1 qtd do Prod 10, 3 qtd do Prod 11
		//      TFI - PROD 1 - qtd. 3 ::
		//          3 movimentos do PROD 1
		//      TFI - KIT 1 - qtd. 2 ::
		//          1 movimento  do PROD 10 - KIT 1 - SEQ 001 >> Representa o primeiro item do KIT 1 elemento
		//          3 movimentos do PROD 11 - KIT 1 - SEQ 001
		//          1 movimento  do PROD 10 - KIT 1 - SEQ 002 >> Representa o segundo item do KIT 1 elemento
		//          3 movimentos do PROD 11 - KIT 1 - SEQ 002
		If lRet

			BeginSql Alias cTabQry

			SELECT
				TFJ.TFJ_CODIGO, TFI.TFI_COD, TFI.TFI_PRODUT, TFI.TFI_QTDVEN
			FROM
				%Table:TFJ% TFJ

				INNER JOIN %Table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL% AND TFL.TFL_CODPAI = %exp:cCodOrcSer% AND TFL.%NotDel%
				INNER JOIN %Table:TFI% TFI ON TFI.TFI_FILIAL = %xFilial:TFI% AND TFI.TFI_CODPAI = TFL.TFL_CODIGO AND TFI.%NotDel%
			WHERE
				TFJ.%NotDel% AND TFJ.TFJ_FILIAL = %xFilial:TFJ%
			 	AND TFJ.TFJ_CODIGO = %exp:cCodOrcSer% AND
			 		NOT EXISTS ( SELECT TEW_EX.TEW_CODEQU
			 			FROM %Table:TEW% TEW_EX
			 			WHERE TEW_EX.TEW_FILIAL = %xFilial:TEW% AND TEW_EX.%NotDel% AND TEW_EX.TEW_ORCSER = %exp:cCodOrcSer% AND TEW_EX.TEW_CODEQU = TFI.TFI_COD )

			EndSql

			If (cTabQry)->(! Eof())

				oMdlLocacao := FwLoadModel("TECA800")

				DbSelectArea("TEZ")
				DbSelectArea("TFI")
				DbSelectArea("TFJ")
				DbSelectArea("SB5")
				TEZ->(DbSetOrder(1) )
				TFI->(DbSetOrder(1) )
				TFJ->(DbSetOrder(1) )
				SB5->(DbSetOrder(1) )

				// Avalia se ainda é a proposta para geração do início dos movimentos de equipamentos
				While lRet .And. (cTabQry)->(! Eof())
					lNoId	 := .F.
					lProdKit := .F.
					nX := 1
					nContKit := 0

					If TEZ->( DbSeek( xFilial("TEZ")+(cTabQry)->TFI_PRODUT ) )
						lProdKit := .T.
						cSeqKit := GeraSeqKit() // usa índice da sequência de kit
					EndIf

					// Gera o número de movimentos conforme a quantidade de itens da proposta
					While lRet .And. nX <= (cTabQry)->TFI_QTDVEN

						lNoId := .F.

						If lTecAtf
							If SB5->( DbSeek( xFilial("SB5")+(cTabQry)->TFI_PRODUT ) )
								If SB5->B5_ISIDUNI == "2"
									lNoId := .T.
								Endif
							Endif
						Endif
						oMdlLocacao:SetOperation( MODEL_OPERATION_INSERT )
						lRet := oMdlLocacao:Activate()
						cCodTEW := oMdlLocacao:GetValue( "MOVIM", "TEW_CODMV" )
						cCodTFI := (cTabQry)->TFI_COD

						lRet := lRet .And. oMdlLocacao:SetValue( "MOVIM", "TEW_CODEQU", (cTabQry)->TFI_COD )
						lRet := lRet .And. oMdlLocacao:SetValue( "MOVIM", "TEW_ORCSER", (cTabQry)->TFJ_CODIGO )

						// usa os dados do KIT para realizar a geração dos movimentos
						If lProdKit
						
							lNoId := .F.
							
							If lTecAtf
								If SB5->( DbSeek( xFilial("SB5")+TEZ->TEZ_ITPROD ) )
									If SB5->B5_ISIDUNI == "2"
										lNoId := .T.
									Endif
								Endif
							Endif
													
							lRet := lRet .And. oMdlLocacao:SetValue( "MOVIM", "TEW_PRODUT", TEZ->TEZ_ITPROD )
							lRet := lRet .And. oMdlLocacao:SetValue( "MOVIM", "TEW_CODKIT", TEZ->TEZ_PRODUT )
							lRet := lRet .And. oMdlLocacao:SetValue( "MOVIM", "TEW_KITSEQ", cSeqKit )

							If lNoId
								// passa para o próximo item do KIT
								nContKit := TEZ->TEZ_ITQTDE
							Else
								// passa para o próximo item do KIT
								nContKit++
							Endif

							cCodSqKit := cSeqKit
							cCodProd  := TEZ->TEZ_ITPROD
							cProdKit  := TEZ->TEZ_PRODUT

							If nContKit >= TEZ->TEZ_ITQTDE
								TEZ->( DbSkip() )
								nContKit := 0   //zera a contagem de itens do Kit
							
								If !lProdkit
									// verifica se acabou os itens que compõem o kit
									If !( TEZ->TEZ_PRODUT == (cTabQry)->TFI_PRODUT )
										nX++
									EndIf
								EndIf
							EndIf
						Else
							// adiciona o produto normalmente quando nao é KIT
							lRet := lRet .And. oMdlLocacao:SetValue( "MOVIM", "TEW_PRODUT", (cTabQry)->TFI_PRODUT )
							cCodProd := (cTabQry)->TFI_PRODUT
							//Quando não controla ID unico, realiza o preenchimento da quantidade de venda da TFI.
							If lNoId
								nX := (cTabQry)->TFI_QTDVEN
								nX++
							Else
								nX++
							Endif
						EndIf

						lRet := lRet .And. oMdlLocacao:VldData() .And. oMdlLocacao:CommitData()

						If !lRet

							cMsgErro += IdErrorMvc( oMdlLocacao )

						Else
						
						
							//Se gravou o movimento, gera a execução de CheckList
							At806Inc(cCodTEW,cCodTFI,cCodSqKit,cCodProd,cProdKit)
						EndIf

						oMdlLocacao:DeActivate()
						
						If lProdkit
							// verifica se acabou os itens que compõem o kit
							If !( TEZ->TEZ_PRODUT == (cTabQry)->TFI_PRODUT )
								nX++
								//   reposiciona no primeiro item do kit de locação quando tiver mais
								// que 1 equipamento locado
								TEZ->( DbSeek( xFilial("TEZ")+(cTabQry)->TFI_PRODUT ) )
								cSeqKit := GeraSeqKit()  // gera outro código para a sequência
							EndIf
						EndIf
					EndDo

					(cTabQry)->( DbSkip() )

				EndDo

				oMdlLocacao:Destroy()

			EndIf

			(cTabQry)->( DbCloseArea() )

		EndIf

	//Atraves de requisicao de equipamentos para o atendente
	Else
		dbSelectArea("TGQ")
		TGQ->(dbSetOrder(1))
		If !TGQ->(dbSeek(xFilial("TGQ")+cRequisicao ))
			lRet := .F.
			cMsgErro := STR0061 // 'Requisição de equipamentos ao atendente não localizada.'
		EndIf

		If lRet

			BeginSql Alias cTabQry

				SELECT
					TGR.TGR_CODTGQ, TFI.TFI_COD, TFI.TFI_PRODUT, TFI.TFI_QTDVEN, TGQ.TGQ_CODATE
				FROM
					%Table:TGR% TGR
					INNER JOIN %Table:TFI% TFI ON TFI.TFI_FILIAL = %xFilial:TFI% AND TFI.TFI_CODTGQ = TGR.TGR_CODTGQ AND TFI.TFI_COD = %exp:cCodSep% AND TFI.%NotDel%
					INNER JOIN %Table:TGQ% TGQ ON TGQ.TGQ_FILIAL = %xFilial:TGQ% AND TGQ.TGQ_CODIGO = TGR.TGR_CODTGQ AND TGQ.%NotDel%
				WHERE
					TGR.%NotDel% AND TGR.TGR_FILIAL = %xFilial:TGR%
					 AND TGR.TGR_CODTGQ = %exp:cRequisicao%
			EndSql

			If (cTabQry)->(! Eof())

				oMdlLocacao := FwLoadModel("TECA800")

				DbSelectArea("TEZ")
				DbSelectArea("TFI")
				DbSelectArea("TFJ")
				TEZ->( DbSetOrder( 1 ) )
				TFI->(DbSetOrder(1) )
				TFJ->(DbSetOrder(1) )

				// Avalia se ainda é a proposta para geração do início dos movimentos de equipamentos
				While lRet .And. (cTabQry)->(! Eof())

					lProdKit := .F.
					nX := 1
					nContKit := 0

					If TEZ->( DbSeek( xFilial("TEZ")+(cTabQry)->TFI_PRODUT ) )
						lProdKit := .T.
						cSeqKit := GeraSeqKit() // usa índice da sequência de kit
					EndIf

					// Gera o número de movimentos conforme a quantidade de itens da proposta
					While lRet .And. nX <= (cTabQry)->TFI_QTDVEN

						oMdlLocacao:SetOperation( MODEL_OPERATION_INSERT )
						lRet := oMdlLocacao:Activate()

						cCodTEW := oMdlLocacao:GetValue( "MOVIM", "TEW_CODMV" )
						cCodTFI := (cTabQry)->TFI_COD
						lRet := lRet .And. oMdlLocacao:SetValue( "MOVIM", "TEW_CODEQU", (cTabQry)->TFI_COD )

						// usa os dados do KIT para realizar a geração dos movimentos
						If lProdKit
							lRet := lRet .And. oMdlLocacao:SetValue( "MOVIM", "TEW_PRODUT", TEZ->TEZ_ITPROD )
							lRet := lRet .And. oMdlLocacao:SetValue( "MOVIM", "TEW_CODKIT", TEZ->TEZ_PRODUT )
							lRet := lRet .And. oMdlLocacao:SetValue( "MOVIM", "TEW_KITSEQ", cSeqKit )
							cCodSqKit := cSeqKit
							cCodProd  := TEZ->TEZ_ITPROD
							cProdKit  := TEZ->TEZ_PRODUT

							// passa para o próximo item do KIT
							nContKit++
							If nContKit >= TEZ->TEZ_ITQTDE
								TEZ->( DbSkip() )
								nContKit := 0   //zera a contagem de itens do Kit

								// verifica se acabou os itens que compõem o kit
								If !( TEZ->TEZ_PRODUT == (cTabQry)->TFI_PRODUT )
									nX++

									//   reposiciona no primeiro item do kit de locação quando tiver mais
									// que 1 equipamento locado
									If lProdKit
										TEZ->( DbSeek( xFilial("TEZ")+(cTabQry)->TFI_PRODUT ) )
										cSeqKit := GeraSeqKit()  // gera outro código para a sequência
									EndIf

								EndIf

							EndIf
						Else
							// adiciona o produto normalmente quando nao é KIT
							lRet := lRet .And. oMdlLocacao:SetValue( "MOVIM", "TEW_PRODUT", (cTabQry)->TFI_PRODUT )
							cCodProd := (cTabQry)->TFI_PRODUT
							nX++
						EndIf

						lRet := lRet .And. oMdlLocacao:VldData() .And. oMdlLocacao:CommitData()

						If !lRet

							cMsgErro += IdErrorMvc( oMdlLocacao )
						Else
							//Se gravou o movimento, gera a execução de CheckList
							At806Inc(cCodTEW,cCodTFI,cCodSqKit,cCodProd,cProdKit)
						EndIf

						oMdlLocacao:DeActivate()

					EndDo

					(cTabQry)->( DbSkip() )

				EndDo

				oMdlLocacao:Destroy()

			EndIf

			(cTabQry)->( DbCloseArea() )

		EndIf
	EndIf

	If lRet

		While GetSx8Len() > nTamSX8
			ConfirmSX8()
		EndDo

	Else
		DisarmTransaction()

		While GetSx8Len() > nTamSX8
			RollbackSx8()
		EndDo

	EndIf

EndIf

End Transaction

RestArea( aSaveTFI )
RestArea( aSaveTFL )
RestArea( aSaveTFJ )
RestArea( aSave )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At800AtuMov
	Realiza a atualização dos dados conforme os campos e conteúdos
passados no array.

@sample 	At800AtuMov()

@since  	21/10/2013
@version 	P11.90
@param  	ExpC, CHAR, conteúdo do erro identificado (Referência)
@param  	ExpA, ARRAY, lista com os campos e conteúdos a serem inseridos no movimento POSICAO 1 = Id dos Campos POSICAO 2 = Conteúdo dos Campos
@param  	ExpC, CHAR, conteúdo para seek na tabela TEW
/*/
//-------------------------------------------------------------------
Function At800AtuMov( cCaptErro, aDadosIns, cChaveSeek, cNumOs )
Local lRet    	:= .T.
Local aArea		:= GetArea()
Local oObjMov  	:= Nil
Local nPos     	:= 0
Local aAreaAA3 	:= AA3->( GetArea() )
Local aAreaTEW 	:= TEW->( GetArea() )
Local nRec		:= 0

DEFAULT cCaptErro	:= ''
DEFAULT aDadosIns  	:= {}
DEFAULT cChaveSeek 	:= ''
DEFAULT cNumOs := ""

If ! Empty(cChaveSeek) .And. ValType(cChaveSeek)=='C'
	lRet := TEW->( DbSeek( cChaveSeek ) )
	
	If isInCallStack("At450AtuEqloc") .AND. isInCallStack("At800FechOs")
		If !EMPTY(cNumOs) .AND. TEW->TEW_NUMOS != cNumOs 
			nRec := TEW->(RECNO())
			While TEW->(!EOF()) .AND. TEW->TEW_BAATD == AA3->AA3_NUMSER .AND. TEW->TEW_FILIAL == xFilial("TEW")
				If TEW->TEW_NUMOS == cNumOs
					Exit
				EndIf
				TEW->(dbSkip())
				If TEW->(EOF()) .OR. TEW->TEW_BAATD != AA3->AA3_NUMSER .OR. TEW->TEW_FILIAL != xFilial("TEW")
					TEW->(DbGoTop())
					TEW->(DbGoTo(nRec))
					Exit
				EndIf
			End
		EndIf
	EndIf
	cCaptErro := STR0021 + cChaveSeek // 'Registro não encontrado com a chave informada: '
EndIf

If lRet .AND. ( (! Empty(cChaveSeek) .And. ValType(cChaveSeek)=='C') .OR. !EMPTY(aDadosIns) )

	oObjMov := FwLoadModel('TECA800')
	oObjMov:SetOperation( MODEL_OPERATION_UPDATE )

	lRet := oObjMov:Activate()

	If lRet

		For nPos := 1 To Len( aDadosIns )

			lRet := lRet .And. oObjMov:SetValue('MOVIM', aDadosIns[nPos,1], aDadosIns[nPos,2] )

			If !lRet
				cCaptErro := IdErrorMvc( oObjMov )
				Exit
			EndIf

		Next nPos

		If lRet .AND. !( oObjMov:VldData() .And. oObjMov:CommitData() )
			lRet     := .F.
			cCaptErro := IdErrorMvc( oObjMov )
		EndIf

	Else
		cCaptErro := IdErrorMvc( oObjMov )
	EndIf

EndIf

RestArea(aAreaTEW)
RestArea(aAreaAA3)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IdErrorMvc
	Função para captura do erro gerado dentro do MVC

@sample 	IdErrorMvc()

@since  	21/10/2013
@version 	P11.90
@param  	ExpO, OBJECT, Objeto principal do MVC em que o erro aconteceu
/*/
//-------------------------------------------------------------------
Static Function IdErrorMvc( oObj )

Local xAux := oObj:GetErrorMessage()

Local cMsgErro := ;
			STR0022 + '[' + ConvAllToChar( xAux[MODEL_MSGERR_IDFIELDERR] ) + ']' + ; // " Id do campo de erro: "
			STR0023 + '[' + ConvAllToChar( xAux[MODEL_MSGERR_MESSAGE] ) + ']' + ;  // " Mensagem do erro:    "
			STR0024 + '[' + ConvAllToChar( xAux[MODEL_MSGERR_SOLUCTION] ) + ']' + ;  // " Mensagem da solução: "
			STR0025 + '[' + ConvAllToChar( xAux[MODEL_MSGERR_VALUE]  ) + ']'  // " Valor atribuido:     "

Return cMsgErro

//-------------------------------------------------------------------
/*/{Protheus.doc} ConvAllToChar
	Converte um dado em String

@sample 	ConvAllToChar()

@since  	25/10/2013
@version 	P11.90
@param  	ExpX, SEM TIPO DEFINIDO, Valor a ser convertido
@return  	ExpC, Char, valor convertido em string
/*/
//-------------------------------------------------------------------
Static Function ConvAllToChar( xValue )

If ValType(xValue) == 'U'
	xValue := 'Nil'
ElseIf ValType(xValue) == 'D'
	xValue := DtoC( xValue )
ElseIf ValType(xValue) == 'L' .Or. ValType(xValue) == 'N'
	xValue := cValToChar( xValue )
EndIf

Return xValue

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraSeqKit
	Função para captura do erro gerado dentro do MVC

@sample 	GeraSeqKit()

@since  	22/10/2013
@version 	P11.90

@return 	ExpC, Char, Código sequencial para os kits
/*/
//-------------------------------------------------------------------
Static Function GeraSeqKit()

Local cCod := ''

Local aSave := GetArea()
Local aSaveTEW := TEW->( GetArea() )

Local cAliasQry := GetNextAlias()

BeginSql Alias cAliasQry

	SELECT
		MAX( TEW.TEW_KITSEQ ) TEW_KITSEQ
	FROM
		%Table:TEW% TEW
	WHERE
		TEW.TEW_FILIAL = %xFilial:TEW% AND TEW.%NotDel%

EndSql

If (cAliasQry)->(! Eof()) .And. !Empty((cAliasQry)->TEW_KITSEQ)
	cCod := Soma1((cAliasQry)->TEW_KITSEQ )
Else
	cCod := StrZero( 1, TamSx3('TEW_KITSEQ')[1] )
EndIf

(cAliasQry)->( DbCloseArea() )

RestArea( aSaveTEW )
RestArea( aSave )

Return cCod

//-------------------------------------------------------------------
/*/{Protheus.doc} At800AtNFSai
	Atualiza os dados da nota de saída

@sample 	At800AtNFSai()

@since  	28/10/2013
@version 	P11.90
/*/
//-------------------------------------------------------------------
Function At800AtNFSai(  )

Local aDados := {}
Local aSave  := GetArea()
Local aSaveF2  := SF2->( GetArea() )
Local aSaveD2  := SD2->( GetArea() )
Local cCodOrc  := ""
Local cTxt	   := ""
Local cTxtNf   := ""
Local cTabTmp		:= ""
Local aPlEtp   := {}
Local oTecProvider	:= Nil
Local lTecAtf	:= SuperGetMv('MV_TECATF', .F.,'N') == 'S'
Local lGSOpTri		:= SuperGetMv('MV_GSOPTRI',.F.,.F.) //Parametro para ativar a operação triangular
Local lUnic		:= .T.
Local lRet			:= .F.
Local lSeek			:= .F.
Local cAddQry 		:= "% "

If AA3->( ColumnPos("AA3_MSBLQL")) > 0
	cAddQry += " AND AA3_MSBLQL <> '1'  "
Else
	cAddQry += " AND 1 = 1   "
EndIf 

cAddQry += "%"
If At800UsaEq()
	DbSelectArea('TEW')
	TEW->( DbSetOrder( 4 ) ) //TEW_FILIAL+TEW_NUMPED+TEW_ITEMPV

	DbSelectArea('TFI')
	TFI->( DbSetOrder( 1 ) ) //TFI_FILIAL+TFI_COD

	SD2->( DbSetOrder( 3 ) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_ITEM
	lSeek := SD2->( DbSeek( SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) ) )

	//----------------------------------------------
	// Itera sobre os itens gerados para a NF
	While lSeek .And. SD2->(! Eof()) .And. SD2->D2_FILIAL == SF2->F2_FILIAL .And. SD2->D2_DOC==SF2->F2_DOC .And. SD2->D2_SERIE == SF2->F2_SERIE .And. ;
			SD2->D2_CLIENTE == SF2->F2_CLIENTE .And. SD2->D2_LOJA == SF2->F2_LOJA

		lUnic := .T.
		If TEW->( DbSeek( xFilial('TEW')+SD2->D2_PEDIDO+SD2->D2_ITEMPV ) )

			aAdd( aDados, { 'TEW_NFSAI' , SD2->D2_DOC } )
			aAdd( aDados, { 'TEW_SERSAI', SD2->D2_SERIE } )
			aAdd( aDados, { 'TEW_ITSAI' , SD2->D2_ITEM } )
			aAdd( aDados, { 'TEW_CODCLI', SD2->D2_CLIENTE } )
			aAdd( aDados, { 'TEW_LOJCLI', SD2->D2_LOJA  } )
			// só atualiza quando o equipamento é da mesma filial que o contrato
			If TEW->TEW_FILIAL == TEW->TEW_FILBAT .Or. !lGSOpTri 
				aAdd( aDados, { 'TEW_DTRINI', SD2->D2_EMISSAO } )
			EndIf
			
			//Atualiza campo _SDOC dos documentos fiscais, caso habilitado
			If SerieNFId("TEW", 3, "TEW_SERSAI") != "TEW_SERSAI"
				aAdd( aDados, { SerieNFId("TEW", 3, "TEW_SERSAI"), SerieNFId("SD2", 2, "D2_SERIE") } )
			EndIf

			If ( lRet := At800AtuMov( , aDados ) )
				//Verifica se existe inegração TEC x ATF.
				If lTecAtf .And. TEW->TEW_FILIAL == TEW->TEW_FILBAT .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)

					oTecProvider := TECProvider():New(TEW->TEW_BAATD)

					//Altera a movimentação da saldo da integração.
					oTecProvider:UpdateTWI(TEW->TEW_CODMV,; //Codigo da Movimentação.
										SD2->D2_DOC,;    //Documento
										SD2->D2_SERIE,;  //Serie
										SD2->D2_ITEM,;   //Item da nota
										.T.,;			//Liberado?
											SD2->D2_FILIAL )  // Filial da NF

					lUnic := oTecProvider:lIdUnico 
					
					TecDestroy(oTecProvider)
				Endif
				
				If lUnic
					aSize( aDados, 0 )
					
					TFI->( DbSeek( xFilial("TFI")+TEW->TEW_CODEQU ) )
					// atualiza os dados relacionados com a alocação do equipamento na Base de Atendimento
					aAdd( aDados, { 'AA3_STATUS', AA3_CLIENTE } )  // atualiza o status da base de atendimento :: "Equipamento em Cliente"
					aAdd( aDados, { 'AA3_CODLOC', TFI->TFI_LOCAL  } )
					aAdd( aDados, { 'AA3_INALOC', TFI->TFI_PERINI } )
					aAdd( aDados, { 'AA3_FIALOC', TFI->TFI_PERFIM } )
					aAdd( aDados, { 'AA3_ENTEQP', TFI->TFI_ENTEQP } )
					aAdd( aDados, { 'AA3_COLEQP', TFI->TFI_COLEQP } )
					// só atualiza quando o equipamento é da mesma filial que o contrato
					If TEW->TEW_FILIAL == TEW->TEW_FILBAT .Or. !lGSOpTri
						aAdd( aDados, { 'AA3_CODCLI', SD2->D2_CLIENTE } )
						aAdd( aDados, { 'AA3_LOJA'  , SD2->D2_LOJA } )
						aAdd( aDados, { 'AA3_FILLOC', TEW->TEW_FILIAL } )
					EndIf
					
					lRet := At800Status( , aDados )

				Endif

				If lRet

					cTxt += "<b> "+STR0072+"</b> "+At800DsInf("TFI", "TFI_CONTRT", xFilial("TFI")+TEW->TEW_CODEQU ) //"Nr. Contrato: "
					cTxt += "<b> "+STR0070+"</b> "+TEW->TEW_PRODUT //"Cod. Produto: "
					cTxt += "<b> "+STR0071+"</b> "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+"<br>" //"Descrição: "

					cTxtNf += "<b> "+STR0072+"</b> "+At800DsInf("TFI", "TFI_CONTRT", xFilial("TFI")+TEW->TEW_CODEQU ) //"Nr. Contrato: "
					cTxtNf += "<b> "+STR0070+"</b> "+TEW->TEW_PRODUT //"Cod. Produto: "
					cTxtNf += "<b> "+STR0071+"</b> "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+"<br>" //"Descrição: "
					cTxtNf += "<b> "+STR0074+"</b> "+TEW->TEW_NFSAI  //"Cod Doc Said: "
					cTxtNf += "<b> "+STR0075+"</b> "+TEW->TEW_SERSAI //"Ser Doc Said: "
					cTxtNf += "<b> "+STR0076+"</b> "+TEW->TEW_ITSAI+"<br>" //"It NF Saida: "

					cCodOrc := TEW->TEW_ORCSER

					If Empty(aPlEtp)
						aPlEtp := At774PlEtp("TEW",xFilial("TFI")+TEW->TEW_CODEQU)
					Endif

				Endif
			EndIf

			aSize( aDados, 0 )
			aDados := {}
		Else
			//--------------------------------------------------
			//    Pesquisa nos pedidos adicionais de remessa
			//  Ele só será pesquisa quando não for encontrado na remessa principal, pois ele é registrado em tabela diferente
			//  com uma filial "padrão" diferente
			cTabTmp := GetNextAlias()
			BeginSql Alias cTabTmp
				SELECT 
					TWR.R_E_C_N_O_ TWRRECNO
					, TEW.R_E_C_N_O_ TEWRECNO
					, AA3.R_E_C_N_O_ AA3RECNO
				FROM %Table:SD2% SD2
					INNER JOIN %Table:TWR% TWR ON
									TWR_FILPED = D2_FILIAL
									AND TWR_NUMPED = D2_PEDIDO
									AND TWR_PEDIT = D2_ITEMPV
									AND TWR.%NotDel%
					INNER JOIN %Table:TEW% TEW ON
									TEW_FILIAL = TWR_FILIAL
									AND TEW_CODMV = TWR_CODMOV
									AND TEW.%NotDel%
					INNER JOIN %Table:AA3% AA3 ON
									AA3_CODPRO = D2_COD
									AND AA3_NUMSER = TEW_BAATD
									AND AA3_FILORI = TEW_FILBAT
									%Exp:cAddQry%
									AND AA3.%NotDel%
				WHERE
					SD2.R_E_C_N_O_ = %Exp:(SD2->(Recno()))%
			EndSql

			DbSelectArea("AA3")
			AA3->( DbSetOrder(6) ) // AA3_FILIAL+AA3_NUMSER+AA3_FILORI

			DbSelectArea("TEW")
			TEW->( DbSetOrder(1) ) // TEW_FILIAL+TEW_CODMV

			DbSelectArea("TWR")
			TWR->( DbSetOrder(1) ) // TWR_FILIAL+TWR_CODMOV

			// quando encontra realiza as atualizações necessárias na movimentação e equipamento
			While (cTabTmp)->( !EOF() )
				
				AA3->( DbGoTo((cTabTmp)->AA3RECNO) )
				TEW->( DbGoTo((cTabTmp)->TEWRECNO) )
				TWR->( DbGoTo((cTabTmp)->TWRRECNO) )
				
				Reclock("TWR", .F.)
					TWR->TWR_SAIDOC := SD2->D2_DOC
					TWR->TWR_SAISER := SD2->D2_SERIE
					TWR->TWR_SAIITE := SD2->D2_ITEM
					TWR->TWR_QTDSAI += SD2->D2_QUANT
					
					If SerieNFId("TWR", 3, "TWR_SAISER") != "TWR_SAISER"
						aAdd( aDados, { SerieNFId("TWR", 3, "TWR_SAISER"), SerieNFId("SD2", 2, "D2_SERIE") } )
					EndIf
				TWR->( MsUnlock() )
				
				If TWR->TWR_ATUFIL == '1'
					// AA3_FILLOC = TEW_FILIAL
					aAdd( aDados, { 'AA3_FILLOC', TEW->TEW_FILIAL } )
					aAdd( aDados, { 'AA3_STATUS', AA3_CLIENTE } )
					aAdd( aDados, { 'AA3_CODCLI', SD2->D2_CLIENTE } )
					aAdd( aDados, { 'AA3_LOJA'  , SD2->D2_LOJA } )
					
					TFI->( DbSeek( xFilial("TFI",TEW->TEW_FILIAL)+TEW->TEW_CODEQU ) )
					
					aAdd( aDados, { 'AA3_CODLOC', TFI->TFI_LOCAL  } )
					aAdd( aDados, { 'AA3_INALOC', TFI->TFI_PERINI } )
					aAdd( aDados, { 'AA3_FIALOC', TFI->TFI_PERFIM } )
					aAdd( aDados, { 'AA3_ENTEQP', TFI->TFI_ENTEQP } )
					aAdd( aDados, { 'AA3_COLEQP', TFI->TFI_COLEQP } )
					
					At800Status( , aDados, /*cKeyAA3*/,.F. )
					
					aDados := {}
					aAdd( aDados, { 'TEW_DTRINI', SD2->D2_EMISSAO } )
					At800AtuMov( , aDados )
					
					//Verifica se existe a integração do TEC x ATF.	
					If lTecAtf .And. TEW->TEW_FILIAL <> TEW->TEW_FILBAT .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
						oTecProvider := TECProvider():New( TEW->TEW_BAATD, TEW->TEW_FILBAT )
						oTecProvider:UpdateTWI( TEW->TEW_CODMV,; //Codigo da Movimentação.
												SD2->D2_DOC,;    //Documento
												SD2->D2_SERIE,;  //Serie
												SD2->D2_ITEM,;   //Item da nota
												.T.,;			//Liberado?
												SD2->D2_FILIAL,;  // Filial da NF
												xFilial("TWI",TEW->TEW_FILIAL) )
						TecDestroy(oTecProvider)
					EndIf
				EndIf
				
				(cTabTmp)->( DbSkip() )
			End
			
			(cTabTmp)->(DbCloseArea())
		EndIf

		SD2->( DbSkip() )
	EndDo

	If !Empty(cTxt) .AND. !Empty(cCodOrc) .AND. !Empty(cTxtNf)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³SIGATEC WorkFlow # LI - Liberação de Locação			   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		At774Mail("TEW",cCodOrc,"LI",cTxt,,,aPlEtp)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³SIGATEC WorkFlow # EN - Emissão da NF de Remessa        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		At774Mail("TEW",cCodOrc,"EN",cTxtNf,,,aPlEtp)

	Endif

	//Destroi o objeto da integração TEC x ATF
	TecDestroy(oTecProvider)
EndIf

RestArea( aSaveD2 )
RestArea( aSaveF2 )
RestArea( aSave )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At800ExNFSai
	Atualiza os dados da nota de saída quando é realizada a exclusão
dela no sistema

@sample 	At800ExNFSai()

@since  	28/10/2013
@version 	P11.90
/*/
//-------------------------------------------------------------------
Function At800ExNFSai(nCont, nReg)

Local aAreaSC5 := SC5->( GetArea() )
Local aAreaSC6 := SC6->( GetArea() )
Local aDados := {}
Local aSave  := GetArea()
Local aSaveD2  := SD2->( GetArea() )
Local lRet	:= .F.
Local cTabTmp := ""
Local oTecProvider := Nil
Local lTecAtf	:= SuperGetMv('MV_TECATF', .F.,'N') == 'S'
Local lGSOpTri		:= SuperGetMv('MV_GSOPTRI',.F.,.F.) //Parametro para ativar a operação triangular
Local lUnic		:= .T.
Local cAddQry 		:= "% "
Static aPlEtp  := {}
Static cTxt	  := ""
Static cTxtNf := ""
Default nCont := 0
Default nReg := 0


If AA3->( ColumnPos("AA3_MSBLQL")) > 0
	cAddQry += " AND AA3_MSBLQL <> '1'  "
Else
	cAddQry += " AND 1 = 1   "
EndIf

cAddQry += "%"

DbSelectArea('TEW')
TEW->( DbSetOrder( 5 ) ) //TEW_FILIAL+TEW_NFSAI+TEW_SERSAI_TEW_ITSAI

//----------------------------------------------
// Itera sobre os itens gerados para a NF
If TEW->( DbSeek( xFilial('TEW')+SD2->(D2_DOC+D2_SERIE+D2_ITEM) ) )

	aAdd( aDados, { 'TEW_NFSAI' , Space( Len( SD2->D2_DOC ) ) } )
	aAdd( aDados, { 'TEW_SERSAI', Space( Len( SD2->D2_SERIE ) ) } )
	aAdd( aDados, { 'TEW_ITSAI' , Space( Len( SD2->D2_ITEM ) ) } )
	aAdd( aDados, { 'TEW_CODCLI', Space( Len( SD2->D2_CLIENTE ) ) } )
	aAdd( aDados, { 'TEW_LOJCLI', Space( Len( SD2->D2_LOJA  ) ) } )
	// só atualiza quando o equipamento é da mesma filial que o contrato
	If TEW->TEW_FILIAL == TEW->TEW_FILBAT .Or. !lGSOpTri
		aAdd( aDados, { 'TEW_DTRINI', CtoD('') } )
	EndIf

	//Atualiza campo _SDOC dos documentos fiscais, caso habilitado
	If SerieNFId("TEW", 3, "TEW_SERSAI") != "TEW_SERSAI"
		aAdd( aDados, { SerieNFId("TEW", 3, "TEW_SERSAI"), Space( Len( SerieNFId("SD2", 2, "D2_SERIE") ) ) } )
	EndIf

	If ( lRet := At800AtuMov( , aDados ) )
		//Verifica se existe integração do TEC x ATF.
		If lTecAtf .And. (TEW->TEW_FILIAL == TEW->TEW_FILBAT .Or. !lGSOpTri) .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
			oTecProvider := TECProvider():New(TEW->TEW_BAATD)

			oTecProvider:UpdateTWI(TEW->TEW_CODMV,; //Cod. Movimentação
								   "",;				//Nota
								   "",;				//Serie
								   "",;				//Item
								   .F.,;			//Liberado?
								   "",; 			// Filial do documento de saída
								   xFilial("TWI", TEW->TEW_FILIAL) )

			lUnic := oTecProvider:lIdUnico
			//Destroi o objeto da integração TEC x ATF
			TecDestroy(oTecProvider)
		Endif

		If lUnic
			// limpa as informações atualizadas no momento da movimentação/alocação do equipamento
			aAdd( aDados, { 'AA3_STATUS', AA3_SEPARADO } )  // atualiza o status da base de atendimento :: "Equipamento em Cliente"
			aAdd( aDados, { 'AA3_FILLOC', "" } )
			aAdd( aDados, { 'AA3_CODCLI', "" } )
			aAdd( aDados, { 'AA3_LOJA'  , "" } )
			aAdd( aDados, { 'AA3_CODLOC', "" } )
			aAdd( aDados, { 'AA3_INALOC', CTOD('') } )
			aAdd( aDados, { 'AA3_FIALOC', CTOD('') } )
			aAdd( aDados, { 'AA3_ENTEQP', CTOD('') } )
			aAdd( aDados, { 'AA3_COLEQP', CTOD('') } )
		
			lRet := At800Status( , aDados )
		Endif
	EndIf
	If lRet

		cTxt += "<b> "+STR0072+"</b> "+At800DsInf("TFI", "TFI_CONTRT", xFilial("TFI")+TEW->TEW_CODEQU ) //"Nr. Contrato: "
		cTxt += "<b> "+STR0070+"</b> "+TEW->TEW_PRODUT //"Cod. Produto: "
		cTxt += "<b> "+STR0071+"</b> "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+"<br>" //"Descrição: "

		cTxtNf += "<b> "+STR0072+"</b> "+At800DsInf("TFI", "TFI_CONTRT", xFilial("TFI")+TEW->TEW_CODEQU ) //"Nr. Contrato: "
		cTxtNf += "<b> "+STR0070+"</b> "+TEW->TEW_PRODUT //"Cod. Produto: "
		cTxtNf += "<b> "+STR0071+"</b> "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+"<br>" //"Descrição: "
		cTxtNf += "<b> "+STR0074+"</b> "+SD2->D2_DOC  //"Cod Doc Said: "
		cTxtNf += "<b> "+STR0075+"</b> "+SD2->D2_SERIE //"Ser Doc Said: "
		cTxtNf += "<b> "+STR0076+"</b> "+SD2->D2_ITEM+"<br>" //"It NF Saida: "

		If Empty(aPlEtp)
			aPlEtp := At774PlEtp("TEW",xFilial("TFI")+TEW->TEW_CODEQU)
		Endif

		If nCont == nReg .AND. !Empty(cTxt) .AND. !Empty(cTxtNf)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SIGATEC WorkFlow # EN - Cancelamento da NF de Remessa  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			At774Mail("TEW",TEW->TEW_ORCSER,"EN",cTxtNf,"RED",STR0080,aPlEtp) //"Exclusão"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SIGATEC WorkFlow # LI - Cancelamento Liberação de Locação  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			At774Mail("TEW",TEW->TEW_ORCSER,"LI",cTxt,"RED",STR0073,aPlEtp) //"Cancelamento"

			cTxtNf 	:= ""
			cTxt 	:= ""
			aPlEtp  := {}
		Endif
	EndIf
Else
	//--------------------------------------------------
	//    Pesquisa nos pedidos adicionais de remessa
	//  Ele só será pesquisa quando não for encontrado na remessa principal, pois ele é registrado em tabela diferente
	//  com uma filial "padrão" diferente
	cTabTmp := GetNextAlias()
	BeginSql Alias cTabTmp
		SELECT 
			D2_FILIAL
			, D2_COD
			, D2_EMISSAO
			, TWR_CODMOV
			, TWR_ATUFIL
			, TEW.R_E_C_N_O_ TEWRECNO
			, AA3.R_E_C_N_O_ AA3RECNO
			, TWR.R_E_C_N_O_ TWRRECNO
			, D2_QUANT
		FROM %Table:SD2% SD2
			INNER JOIN %Table:TWR% TWR ON
							TWR_FILPED = D2_FILIAL
							AND TWR_SAIDOC = D2_DOC
							AND TWR_SAISER = D2_SERIE
							AND TWR_SAIITE = D2_ITEM
							AND TWR.%NotDel%
			INNER JOIN %Table:TEW% TEW ON
							TEW_FILIAL = TWR_FILIAL
							AND TEW_CODMV = TWR_CODMOV
							AND TEW.%NotDel%
			INNER JOIN %Table:AA3% AA3 ON
							AA3_NUMSER = TEW_BAATD
							AND AA3_FILORI = TEW_FILBAT
							%Exp:cAddQry%
							AND AA3.%NotDel%
		WHERE
			SD2.R_E_C_N_O_ = %Exp:(SD2->(Recno()))%
	EndSql

	DbSelectArea("AA3")
	AA3->( DbSetOrder(6) ) // AA3_FILIAL+AA3_NUMSER+AA3_FILORI

	DbSelectArea("TEW")
	TEW->( DbSetOrder(1) ) // TEW_FILIAL+TEW_CODMV

	DbSelectArea("TWR")
	TWR->( DbSetOrder(1) ) // TWR_FILIAL+TWR_CODMOV

	// quando encontra realiza as atualizações necessárias na movimentação e equipamento
	While (cTabTmp)->( !EOF() )
		
		AA3->( DbGoTo((cTabTmp)->AA3RECNO) )
		TEW->( DbGoTo((cTabTmp)->TEWRECNO) )
		TWR->( DbGoTo((cTabTmp)->TWRRECNO) )
		
		Reclock("TWR", .F.)
			TWR->TWR_SAIDOC := ""
			TWR->TWR_SAISER := ""
			TWR->TWR_SAIITE := ""
			TWR->TWR_QTDSAI -= (cTabTmp)->D2_QUANT
			
			If SerieNFId("TWR", 3, "TWR_SAISER") != "TWR_SAISER"
				TWR->&(SerieNFId("TWR", 3, "TWR_SAISER")) := Space( Len( SerieNFId("SD2", 2, "D2_SERIE") ) )
			EndIf
		TWR->( MsUnlock() )
		
		If (cTabTmp)->TWR_ATUFIL == '1'
			// AA3_STATUS = STATUS ANTERIOR
			// AA3_FILLOC = "" (em branco)
			aAdd( aDados, { 'AA3_STATUS', AA3->AA3_STAANT } )
			aAdd( aDados, { 'AA3_FILLOC', '' } )
			At800Status( , aDados, /*cChaveAA3*/, .F. )
			
			TEW->(DbSeek( xFilial("TEW",TWR->TWR_FILIAL)+TWR->TWR_CODMOV ))

			aDados := {}
			aAdd( aDados, { 'TEW_DTRINI', CtoD('') } )
			At800AtuMov( , aDados )
			
			If lTecAtf .And. TEW->TEW_FILIAL <> TEW->TEW_FILBAT .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
				oTecProvider := TECProvider():New(TEW->TEW_BAATD,TEW->TEW_FILBAT)
	
				oTecProvider:UpdateTWI(TEW->TEW_CODMV,; //Cod. Movimentação
									   "",;				//Nota
									   "",;				//Serie
									   "",;				//Item
									   .F.,;			//Liberado?
									   "",; 			// Filial do documento de saída
									   xFilial("TWI",TEW->TEW_FILIAL)) // filial para pesquisar a TWI
	
				lUnic := oTecProvider:lIdUnico
				//Destroi o objeto da integração TEC x ATF
				TecDestroy(oTecProvider)
			Endif
			
		EndIf
		(cTabTmp)->( DbSkip() )
	End
	(cTabTmp)->(DbCloseArea())
EndIf

RestArea( aSaveD2 )
If VALTYPE(aAreaSC5) == 'A'
	RestArea( aAreaSC5 )
EndIf
If VALTYPE(aAreaSC6) == 'A'
	RestArea( aAreaSC6 )
EndIf
RestArea( aSave )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At800ItNf
	validação dos campos de Item das Notas Fiscais

@sample 	At800ItNf()

@since  	28/10/2013
@version 	P11.90
@param  	lSaida, Logico, indica se é a validação de nf de saida ou entrada
@return 	lRet, Logico, define se permite ou não a inclusão/alteração de conteúdo no campo
/*/
//-------------------------------------------------------------------
Function At800ItNf( lSaida )

Local lRet       := .T.
Local cCodCliente := ''
Local cCodLoja    := ''

Local aArea       := GetArea()
Local aAreaTmp    := {}

If lSaida
	aAreaTmp := SD2->( GetArea() )

	If !Empty( FWFLDGET("TEW_ITSAI") )

		If At820CliLoj( @cCodCliente, @cCodLoja, FwFldGet('TEW_CODEQU') )
		// ORDEM 3 = D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			lRet := ExistCpo('SD2', FwFldGet('TEW_NFSAI')+FwFldGet('TEW_SERSAI')+cCodCliente+cCodLoja+FwFldGet('TEW_PRODUT')+FwFldGet('TEW_ITSAI'),3)
		Else
			lRet := .F.
			Help(,,'AT800Item',,STR0026,1,0) // 'Cliente e loja não identificados no orçamento dde serviços'
		EndIf

	EndIf

	RestArea( aAreaTmp )
Else
	aAreaTmp := SD1->( GetArea() )

	If !Empty( FWFLDGET("TEW_ITENT") )

		If At820CliLoj( @cCodCliente, @cCodLoja, FwFldGet('TEW_CODEQU') )
			If IsInCallStack("A103NFiscal") .And. cCodCliente != SF1->F1_FORNECE
				// ORDEM 1 = D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
				lRet := ExistCpo('SD1', FwFldGet('TEW_NFENT')+FwFldGet('TEW_SERENT')+SF1->F1_FORNECE+SF1->F1_LOJA+FwFldGet('TEW_PRODUT')+FwFldGet('TEW_ITENT'),1)
			Else
				// ORDEM 1 = D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
				lRet := ExistCpo('SD1', FwFldGet('TEW_NFENT')+FwFldGet('TEW_SERENT')+cCodCliente+cCodLoja+FwFldGet('TEW_PRODUT')+FwFldGet('TEW_ITENT'),1)
			EndIf
		Else
			lRet := .F.
			Help(,,'AT800Item',,STR0027,1,0)  // 'Cliente e loja não identificados no orçamento dde serviços'
		EndIf

	EndIf

	RestArea( aAreaTmp )
EndIf


RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At800AtNFEnt
	Realiza a atualizaçao dos movimentos vinculado à NF de devolução

@since  	29/10/2013
@version  	P11.90
/*/
//-------------------------------------------------------------------
Function At800AtNFEnt( lExclusao )

Local lSeek			:= .F.
Local aDados			:= {}
Local cNotaDoc		:= ''
Local cNotaSer		:= ''
Local cNotaIte		:= ''
Local xAux				:= {}
Local aTEWRecnos		:= {}
Local aTWPRecnos		:= {}
Local nX				:= 0
Local aSave			:= GetArea()
Local aSaveSF1		:= SF1->( GetArea() )
Local aSaveSD1		:= SD1->( GetArea() )
Local lOk				:= .T.
Local cDetErro		:= ''
Local cCodClient		:= ''
Local cLojClient		:= ''
Local lIntTecMnt		:= ExistFunc('At040ImpST9') .And. ExistFunc('At800OsxTec') .And. (TEW->( ColumnPos('TEW_TPOS')) > 0 ) .And. (AA3->(ColumnPos('AA3_CODBEM')) > 0)
Local cTxt				:= ""
Local cTxtNf			:= ""
Local cCodOrc			:= ""
Local aPlEtp			:= {}
Local cFilTEW			:= xFilial("TEW")
Local cAliasQry		:= ""
Local oTecProvider	:= Nil
Local lTecATF			:= SuperGetMv('MV_TECATF', .F.,'N') == 'S'
Local lGSOpTri		:= SuperGetMv('MV_GSOPTRI',.F.,.F.) //Parametro para ativar a operação triangular
Local aDadosOS		:= {"","",""}
Local cSttAnt			:= ""
Local cFilBkp 		:= cFilAnt
Local lUnic			:= .T.
Local nQtRet 		:= 0
Local cPrdAA3 		:= ""
Local cSelect		:= ""
Local cDB 			:= TcGetDB()
Local cChvAA3		:= "" //Chave do AA3
Local lAtvAA3	:= .F. // Registro ativo no AA3
Local cAddQry 		:= "% "
Local lCpoAA3Blq	:= AA3->( ColumnPos("AA3_MSBLQL")) > 0

If lCpoAA3Blq
	cAddQry += " AND AA3_MSBLQL <> '1'  "
Else
	cAddQry += " AND 1 = 1   "
EndIf
 

cAddQry += "%"

DbSelectArea('TEW')

DbSelectArea('AA3')
AA3->(DbSetOrder(6)) // AA3_FILIAL+AA3_NUMSER

If !lExclusao

	TEW->(DbSetOrder(5)) //TEW_FILIAL+TEW_NFSAI+TEW_SERSAI+TEW_ITSAI
	SD1->(DbSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM

	lSeek := SD1->(DbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

	While lSeek .And. SD1->(! Eof()) .And. SF1->F1_FILIAL == SD1->D1_FILIAL .And. ;
			SF1->F1_DOC == SD1->D1_DOC .And. SF1->F1_SERIE == SD1->D1_SERIE .And. ;
			SF1->F1_FORNECE == SD1->D1_FORNECE .And. SF1->F1_LOJA == SD1->D1_LOJA

		cNotaDoc := SD1->D1_NFORI
		cNotaSer := SD1->D1_SERIORI
		cNotaIte := SD1->D1_ITEMORI

		If TEW->(DbSeek(cFilTEW+cNotaDoc+cNotaSer+cNotaIte))

			cTxt += "<b> "+STR0072+"</b> "+At800DsInf("TFI", "TFI_CONTRT", xFilial("TFI")+TEW->TEW_CODEQU ) //"Nr. Contrato: "
			cTxt += "<b> "+STR0070+"</b> "+TEW->TEW_PRODUT //"Cod. Produto: "
			cTxt += "<b> "+STR0071+"</b> "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+"<br>" //"Descrição: "
			cTxt += "<b> "+STR0077+"</b> "+cNotaDoc  //"Cod.Doc.Entrada: "
			cTxt += "<b> "+STR0078+"</b> "+cNotaSer  //"Sér.Doc.Entrada: "
			cTxt += "<b> "+STR0079+"</b> "+cNotaIte+"<br>" //"It.Doc.Entrada: "

			If Empty(aPlEtp)
				aPlEtp := At774PlEtp("TEW",xFilial("TFI")+TEW->TEW_CODEQU)
			Endif

			cCodOrc := TEW->TEW_ORCSER
			cPrdAA3 := At820FilPd( TEW->TEW_PRODUT, TEW->TEW_FILIAL, TEW->TEW_FILBAT )
			
			// posiciona no equipamento da alocação
			If lGSOpTri
				AtPosAA3( TEW->TEW_FILBAT+TEW->TEW_BAATD, cPrdAA3 )
			Else
				DbSelectArea('AA3')
				AA3->( DbSetOrder( 6 ) ) // AA3_FILIAL+AA3_NUMSER
				cChvAA3		:=  xFilial('AA3')+TEW->TEW_BAATD  //Chave do AA3
				AA3->( DbSeek(cChvAA3) )
				Do While AA3->(!Eof() .AND. AA3_FILIAL+AA3_NUMSER == cChvAA3)
					//Posiciona na base de atendimento ativa
					If !lCpoAA3Blq .OR. AA3->AA3_MSBLQL <> '1'
						lAtvAA3 := .T.
						Exit
					EndIf
					AA3->(DbSkip(1))
				EndDo
				If !lAtvAA3
					AA3->( DbSeek(cChvAA3) )
				EndIf
			EndIf
			
			//  criada função para atualizar os dados e poder ser chamada a partir de dois pontos diferentes
			// na atualização dos dados que vem 
			AtuLocRetNF( @lOk, oTecProvider, lTecATF, lIntTecMnt, "1" )
			
		ElseIf SF1->F1_TIPO == 'D'
			// quando não encontra dentro do movimento de locação, procura nos pedidos adicionais de remessa dos equipamentos
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT SD1.R_E_C_N_O_ SD1RECNO, SC6.R_E_C_N_O_ SC6RECNO, TWR.R_E_C_N_O_ TWRRECNO,
				       TEW.R_E_C_N_O_ TEWRECNO, AA3.R_E_C_N_O_ AA3RECNO
				  FROM %Table:SD1% SD1
				       INNER JOIN %Table:SD2% SD2 ON D2_FILIAL = D1_FILIAL
				                                 AND D2_DOC = D1_NFORI
				                                 AND D2_SERIE = D1_SERIORI
				                                 AND D2_ITEM = D1_ITEMORI
				                                 AND SD2.%NotDel%
				       INNER JOIN %Table:TWR% TWR ON TWR_FILPED = D1_FILIAL
				                                 AND TWR_SAIDOC = D1_NFORI
				                                 AND TWR_SAISER = D1_SERIORI
				                                 AND TWR_SAIITE = D1_ITEMORI
				                                 AND TWR.%NotDel%
				       INNER JOIN %Table:SC6% SC6 ON C6_FILIAL = D2_FILIAL
				                                 AND C6_NUM = D2_PEDIDO
				                                 AND C6_ITEM = D2_ITEMPV
				                                 AND SC6.%NotDel%
				       INNER JOIN %Table:TEW% TEW ON TEW_FILIAL = TWR_FILIAL
				                                 AND TEW_CODMV = TWR_CODMOV
				                                 AND TEW.%NotDel%
				       INNER JOIN %Table:AA3% AA3 ON AA3_FILORI = TEW_FILBAT
				                                 AND AA3_NUMSER = TEW_BAATD
												 AND AA3_CODPRO = D2_COD
												%Exp:cAddQry%
				                                 AND AA3.%NotDel%
				 WHERE SD1.R_E_C_N_O_ = %Exp:SD1->(Recno())%
			EndSql
			
			While (cAliasQry)->(! Eof())
				//----------------------------
				// eliminar a atualização dos campos da base
				DbSelectArea("TWR")
				
				AA3->(DbGoTo((cAliasQry)->AA3RECNO))
				TEW->(DbGoTo((cAliasQry)->TEWRECNO))
				TWR->(DbGoTo((cAliasQry)->TWRRECNO))
				
				Reclock("TWR",.F.)
				TWR->TWR_ENTDOC := SD1->D1_DOC
				TWR->TWR_ENTSER := SD1->D1_SERIE
				TWR->TWR_ENTITE := SD1->D1_ITEM
				TWR->TWR_QTDRET += SD1->D1_QUANT
				
				//Atualiza campo _SDOC dos documentos fiscais, caso habilitado
				If SerieNFId("TWR", 3, "TWR_ENTSER") != "TWR_ENTSER"
					TWR->&(SerieNFId("TWR", 3, "TWR_ENTSER")) := SerieNFId("SD1", 2, "D1_SERIE")
				EndIf
				TWR->(MsUnlock())
				
				If TWR->TWR_ATUFIL == '1'
					xAux := {}
					aAdd(xAux, {'AA3_FILLOC', ""})
					lOk := At800Status(@cDetErro, xAux)
					
					//  criada função para atualizar os dados e poder ser chamada a partir da atualização
					// quando o pedido é de uma filial
					AtuLocRetNF( @lOk, oTecProvider, lTecATF, lIntTecMnt, "2" )
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			
			(cAliasQry)->(DbCloseArea())
		EndIf
		SD1->(DbSkip())
	EndDo

	If lOk .AND. !Empty(cCodOrc) .AND. !Empty(cTxt)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³SIGATEC WorkFlow # ER - Retorno de Equipamentos     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		At774Mail("TEW",cCodOrc,"ER",cTxt,,,aPlEtp)
	Endif

Else

	TEW->(DbSetOrder(6)) //TEW_FILIAL+TEW_NFENT+TEW_SERENT+TEW_ITENT

	cNotaDoc := SF1->F1_DOC
	cNotaSer := SF1->F1_SERIE

	lSeek := TEW->(DbSeek(cFilTEW+cNotaDoc+cNotaSer))

	While lSeek .And. TEW->(! Eof()) .And. TEW->TEW_FILIAL == cFilTEW .And. TEW->TEW_NFENT == cNotaDoc .And. TEW->TEW_SERENT == cNotaSer
		aAdd(aTEWRecnos, TEW->(Recno()))
		TEW->(DbSkip())
	EndDo

	If lSeek
		For nX := 1 To Len(aTEWRecnos)
	
			TEW->(DbGoTo(aTEWRecnos[nX]))
			
			cTxt += "<b> "+STR0072+"</b> "+At800DsInf("TFI", "TFI_CONTRT", xFilial("TFI")+TEW->TEW_CODEQU ) //"Nr. Contrato: "
			cTxt += "<b> "+STR0070+"</b> "+TEW->TEW_PRODUT //"Cod. Produto: "
			cTxt += "<b> "+STR0071+"</b> "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+"<br>" //"Descrição: "
			cTxt += "<b> "+STR0077+"</b> "+cNotaDoc //"Cod.Doc.Entrada: "
			cTxt += "<b> "+STR0078+"</b> "+cNotaSer //"Sér.Doc.Entrada: "
			cTxt += "<b> "+STR0079+"</b> "+TEW->TEW_ITENT+"<br>" //"It.Doc.Entrada: "
		
			If Empty(aPlEtp)
				aPlEtp := At774PlEtp("TEW",xFilial("TFI")+TEW->TEW_CODEQU)
			Endif
		
			cCodOrc := TEW->TEW_ORCSER

			// chama função para atualizar as demais informações da movimentação de equipamentos
			AtuLocExcNF( "1", @lOk, cNotaDoc, cNotaSer, oTecProvider, lTecATF, lIntTecMnt )
			
			If !lOk
				Exit
			EndIf
		Next nX
	Endif
	//Verifica se faz parte da intregação TEC x ATF.
	TWP->(DbSetOrder(2)) //TWP_FILIAL+TWP_NUMNF+TWP_SERNF+TWP_ITEMNF

	cNotaDoc := SF1->F1_DOC
	cNotaSer := SF1->F1_SERIE

	lSeek := TWP->( DbSeek( xFilial('TWP')+cNotaDoc+cNotaSer ) )
	If lSeek
		While lSeek .And. TWP->(! Eof()) .And. TWP->TWP_NUMNF == cNotaDoc .And. TWP->TWP_SERNF == cNotaSer
			aAdd(aTWPRecnos, TWP->(Recno()))
			TWP->(DbSkip())
		EndDo

		TEW->(DbSetOrder(1)) //TEW_FILIAL+TEW_CODMV
		
		For nX := 1 To Len(aTWPRecnos)
	
			TWP->(DbGoTo(aTWPRecnos[nX]))
			
			If TEW->(DbSeek(xFilial("TEW")+TWP->TWP_IDREG))
				
				cTxt += "<b> "+STR0072+"</b> "+At800DsInf("TFI", "TFI_CONTRT", xFilial("TFI")+TEW->TEW_CODEQU ) //"Nr. Contrato: "
				cTxt += "<b> "+STR0070+"</b> "+TEW->TEW_PRODUT //"Cod. Produto: "
				cTxt += "<b> "+STR0071+"</b> "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+"<br>" //"Descrição: "
				cTxt += "<b> "+STR0077+"</b> "+cNotaDoc //"Cod.Doc.Entrada: "
				cTxt += "<b> "+STR0078+"</b> "+cNotaSer //"Sér.Doc.Entrada: "
				cTxt += "<b> "+STR0079+"</b> "+TWP->TWP_ITEMNF+"<br>" //"It.Doc.Entrada: "
			
				If Empty(aPlEtp)
					aPlEtp := At774PlEtp("TEW",xFilial("TFI")+TEW->TEW_CODEQU)
				Endif
			
				cCodOrc := TEW->TEW_ORCSER
				
				// chama a função para atualizar as demais informações da movimentação dos equipamentos
				AtuLocExcNF( "2", @lOk, cNotaDoc, cNotaSer, oTecProvider, lTecATF, lIntTecMnt, TWP->TWP_QTDRET )
				
				If !lOk
					Exit
				EndIf
			Endif
		Next nX
	Endif
	//------------------------------------------------
	// só procura nos pedidos adicionais da remessa por operação triangular 
	//quando não encontra na TEW, pois ela possui o pedido principal da movimentação
	If !lSeek .And. lOk .And. SF1->F1_TIPO == 'D'
		
		cSelect:="TWR.R_E_C_N_O_ TWRRECNO	, SC6.R_E_C_N_O_ SC6RECNO, TEW.R_E_C_N_O_ TEWRECNO, AA3.R_E_C_N_O_ AA3RECNO"	
		IF cDB == "INFORMIX"
			cSelect+=", NVL( TWP_QTDRET, 0) TWP_QTDRET"
		Else
			cSelect+=", COALESCE( TWP_QTDRET, 0) TWP_QTDRET"
		EndIf
		
		cAliasQry := GetNextAlias()
		BeginSQl Alias cAliasQry
			SELECT %Exp:cSelect%
			  FROM %Table:TWR% TWR
			       INNER JOIN %Table:SC6% SC6 ON C6_FILIAL = TWR_FILPED
			                                 AND C6_NUM = TWR_NUMPED
			                                 AND C6_ITEM = TWR_PEDIT
			                                 AND SC6.%NotDel%
			       INNER JOIN %Table:TEW% TEW ON TEW_FILIAL = TWR_FILIAL
			                                 AND TEW_CODMV = TWR_CODMOV
			                                 AND TEW.%NotDel%
			       INNER JOIN %Table:AA3% AA3 ON AA3_FILORI = TEW_FILBAT
			                                 AND AA3_NUMSER = TEW_BAATD
			                                 AND AA3.%NotDel%
			       LEFT JOIN %Table:TWP% TWP ON TWP_FILIAL = TEW_FILIAL
			       							 AND TWP_IDREG = TEW_CODMV
			       							 AND TWP.%NotDel%
			 WHERE TWR_FILPED = %Exp:SF1->F1_FILIAL%
			   AND TWR_ENTDOC = %Exp:SF1->F1_DOC%
			   AND TWR_ENTSER = %Exp:SF1->F1_SERIE%
			   AND TWR.%NotDel%
			   AND TWR_CLIENT = %Exp:SF1->F1_FORNECE%
			   AND TWR_LOJACL = %Exp:SF1->F1_LOJA%
		EndSql
		
		//----------------------------
		// eliminar a atualização dos campos da base
		DbSelectArea("TWR")
		
		While (cAliasQry)->(! Eof())
			
			//----------------------------
			// eliminar a atualização dos campos da base
			DbSelectArea("TWR")
			
			AA3->(DbGoTo((cAliasQry)->AA3RECNO))
			TEW->(DbGoTo((cAliasQry)->TEWRECNO))
			TWR->(DbGoTo((cAliasQry)->TWRRECNO))
			// lê assim pois os registros da SD1 já foram excluídos e não podem ter a informação recuperada
			nQtRet := If( (cAliasQry)->TWP_QTDRET == 0, 1, (cAliasQry)->TWP_QTDRET )

			Reclock("TWR",.F.)
			TWR->TWR_ENTDOC := ""
			TWR->TWR_ENTSER := ""
			TWR->TWR_ENTITE := ""
			TWR->TWR_QTDRET -= nQtRet
				
			//Atualiza campo _SDOC dos documentos fiscais, caso habilitado
			If SerieNFId("TWR", 3, "TWR_ENTSER") != "TWR_ENTSER"
				TWR->&(SerieNFId("TWR", 3, "TWR_ENTSER")) := ""
			EndIf
			TWR->(MsUnlock())
				
			If TWR->TWR_ATUFIL == '1'
				xAux := {}
				aAdd(xAux, {'AA3_FILLOC', TEW->TEW_FILIAL})
				lOk := At800Status(@cDetErro, xAux)
				
				// chama a função para atualizar as demais informações da movimentação dos equipamentos
				AtuLocExcNF( "3", @lOk, cNotaDoc, cNotaSer, oTecProvider, lTecATF, lIntTecMnt, nQtRet )
				
				If !lOk
					Exit
				EndIf
			EndIf

			(cAliasQry)->(DbSkip())
		EndDo
		
		(cAliasQry)->(DbCloseArea())
	EndIf
	
	If lOk .AND. !Empty(cCodOrc) .AND. !Empty(cTxt)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³SIGATEC WorkFlow # ER - Cancelamento Retorno de Equipamentos  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		At774Mail("TEW",cCodOrc,"ER",cTxt,"RED",STR0073,aPlEtp) //"Cancelamento"
	Endif
EndIf

//Destroi o objeto da integração TEC x ATF
TecDestroy(oTecProvider)
If !lOk
	Help(,,'AT800NFE',, STR0028 + CRLF + ;	// 'Não foi possível realizar a atualização completa dos itens de locação inserção da nota será cancelada'
	                    STR0029 + CRLF + ;	// 'Detalhes: '
	                    cDetErro, 1,0)
	DisarmTransaction()
EndIf

RestArea(aSaveSD1)
RestArea(aSaveSF1)
RestArea(aSave)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At800Status
	Atualiza os dados da base de atendimento conforme os dados recebidos
por parâmetro

@sample 	At800Status()
@since  	29/10/2013
@version  	P11.90
/*/
//-------------------------------------------------------------------
Function At800Status( cErro, aInfsGrv, cSeekAA3, lPesq, cPrdAA3 )

Local lStatus 		:= .F.
Local nZ 			:= 0
Local lContinua 	:= .F.
Local cCliAA4 		:= ""
Local cLojAA4 		:= ""
Local cProAA4 		:= ""
Local cNSAA4 		:= ""
Local nPosCodCli 	:= aScan( aInfsGrv, {|x| x[1]=="AA3_CODCLI" } )
Local nPosLoja 		:= aScan( aInfsGrv, {|x| x[1]=="AA3_LOJA" } )
Local cFilAA4 		:= ""
Local lGSOpTri		:= SuperGetMv('MV_GSOPTRI',.F.,.F.) //Parametro para ativar a operação triangular
Local lRegAtv		:= .F. //Registro ativo encontrado?
Local cKeyAAA3		:= ""
Local lChaveCmp		:= .F. //Chave Completa?
Local lCpoAA3Blq	:= AA3->( ColumnPos("AA3_MSBLQL")) > 0

Default cErro    	:= ''
Default aInfsGrv 	:= {}
Default lPesq 		:= .T.
Default cPrdAA3 	:= At820FilPd( TEW->TEW_PRODUT, TEW->TEW_FILIAL, TEW->TEW_FILBAT )

If Empty(cSeekAA3) 
	If lGSOpTri
		cSeekAA3 := TEW->(TEW_FILBAT+TEW_BAATD)
		cKeyAAA3 := "AA3_FILIAL+AA3_NUMSER"
	Else
		cSeekAA3 := xFilial('AA3')+TEW->TEW_BAATD
		cKeyAAA3 := "AA3_FILIAL+AA3_NUMSER"
	Endif
EndIf

If lPesq
	If lGSOpTri
		lContinua := AtPosAA3( cSeekAA3, cPrdAA3 )
	Else
		DbSelectArea('AA3')
		AA3->( DbSetOrder( 6 ) ) // AA3_FILIAL+AA3_NUMSER+AA3_FILORI
		If Empty(cKeyAAA3) //Valida o tamanho da chave de busca pois pode vir completa ou não
			cKeyAAA3 := "AA3_FILIAL+AA3_NUMSER"
			lChaveCmp := Len(AA3->(&cKeyAAA3)) < Len(cSeekAA3)
		EndIf	

		lContinua := AA3->( DbSeek( cSeekAA3 ) )
		If lContinua
		 	Do While AA3->(!Eof() .AND.  (  (!lChaveCmp .AND. AA3_FILIAL+AA3_NUMSER == cSeekAA3) .OR. ;
		 	                                (lChaveCmp .AND. AA3_FILIAL+AA3_NUMSER+AA3_FILORI == cSeekAA3) ) )
		 		//Verifica se o registro está ativo
		 		If !lCpoAA3Blq .OR. AA3->AA3_MSBLQL <> "1"
		 			lRegAtv := .T.
		 			Exit
		 		EndIf
		 		AA3->(DbSkip(1))
		 	EndDo
		 	
		 	lContinua := lRegAtv
		 	
		EndIf
	EndIf
Else
	lContinua := .T.
EndIf

If lContinua
	// utiliza função específica para atualizar o status do equipamento
	// ela vai manter o último valor no campo de status anterior
	If ( nZ := aScan( aInfsGrv, {|x| x[1] == "AA3_STATUS" } ) ) > 0 
		AtEqStatus("",.F.,aInfsGrv[nZ,2])
		aDel( aInfsGrv, nZ)
		aSize( aInfsGrv, Len(aInfsGrv)-1 )
	EndIf
	
	If nPosCodCli > 0 .And. nPosLoja > 0
		cFilAA4 := xFilial("AA4")
		cCliAA4 := AA3->AA3_CODCLI
		cLojAA4 := AA3->AA3_LOJA
		cProAA4 := AA3->AA3_CODPRO
		cNSAA4 := AA3->AA3_NUMSER
		
		DbSelectArea("AA4")
		AA4->(dbSetOrder(1))
		If AA4->(dbSeek(cFilAA4 + cCliAA4 + cLojAA4 + cProAA4 + cNSAA4 ))
			// altera os itens da base quando encontra a relação e o cliente está sendo alterado
			While !(EOF()) .And. (AA4->AA4_FILIAL == cFilAA4 .And. ;
									AA4->AA4_CODCLI == cCliAA4 .And. ;
									AA4->AA4_LOJA == cLojAA4 .And. ;
									AA4->AA4_CODPRO == cProAA4 .And. ;
									AA4->AA4_NUMSER == cNSAA4  )
				
				RecLock("AA4", .F.)
				AA4->AA4_CODCLI	:= cCliAA4		
				AA4->AA4_LOJA	:= cLojAA4
				AA4->(MsUnLock())
				
				AA4->(DbSkip())
			EndDo
		EndIf
		
	EndIf
	
	Reclock('AA3', .F. )
		For nZ := 1 To Len( aInfsGrv )
			AA3->&(aInfsGrv[nZ,1]) := aInfsGrv[nZ,2]
		Next nZ
	AA3->( MsUnlock() )

	lStatus := .T.

Else
	cErro := STR0030 // 'Número de Série não encontrado'
EndIf

Return lStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} At800AtuOs
	Realiza a criação/exclusão da Os de Manutenção preventiva para os equipamentos
que precisam

@sample 	At800AtuOs( @cErro )
@since  	29/10/2013
@version  	P11.90
/*/
//-------------------------------------------------------------------
Static Function At800AtuOs( cErro, lExclui, nQtdItens, aDdOs, lIdUni)

Local lStatus		:= .T.
Local aCabOs		:= {}
Local aItensOs	:= {}
Local xAux			:= {}
Local cCliOS		:= ''
Local cLojOS		:= ''
Local cOcorPad	:= SuperGetMv('MV_GSLOCOC', , '')
Local cServPad	:= SuperGetMv('MV_GSSVMNT', , '')
Local nOper		:= 3
Local cCodOs		:= ''
Local lOsTec		:= .F.
Local lOkOrdemMNT	:= .F.
Local lIntTecMnt	:= ExistFunc('At040ImpST9') .And. ExistFunc('At800OsxTec') .And. (TEW->( ColumnPos('TEW_TPOS')) > 0 ) .And. (AA3->(ColumnPos('AA3_CODBEM')) > 0)
Local cFilAB6		:= xFilial("AB6")
Local cFilAB7		:= xFilial("AB7")
Local lTecAtf	   := SuperGetMv('MV_TECATF', .F.,'N') == 'S'
Local lGSOpTri		:= SuperGetMv('MV_GSOPTRI',.F.,.F.) //Parametro para ativar a operação triangular
Local lExclOS		:= .T.
Local cCodMov		:= ""
Local cNumNf		:= ""
Local cSerNf		:= ""
Local cIniStatusOS  := ""
Local cDetErro		:= ''
Local aDados			:= {}
Local cFilBkp 		:= cFilAnt
Local cCondPg 		:= ""
Local oTecProv		:= Nil
Local cPrdAA3 		:= ""
Local lSeekSB7		:= .F.
Local cFilOS		:= ""

Default cErro 		:= ''
Default lExclui 	:= .F.
Default nQtdItens	:=  1 //Quantidade de itens retornados.
Default aDdOs		:= {"","",""}
Default lIdUni		:= .T.

Private lMsHelpAuto	:= .T.
Private lMsErroAuto	:= .F.

lOsTec := !lIntTecMnt .Or. (lIntTecMnt .And. Empty(AA3->AA3_CODBEM) .And. TEW->TEW_TPOS <> "2")

If lOsTec .And. Empty(cOcorPad)
	cErro		:= STR0089	//"Parâmetro 'MV_GSLOCOC' não configurado."
	lStatus	:= .F.
ElseIf !lOsTec .And. lIntTecMnt .AND. Empty( cServPad )
	cErro		:= STR0090	//"Parâmetro 'MV_GSSVMNT' não configurado."
	lStatus	:= .F.
ElseIf	!( At820CliLoj(@cCliOS, @cLojOS, TEW->TEW_CODEQU,,TEW->TEW_FILIAL) )  // preenche cliente/loja e posiciona dados da TFJ e TFL
	cErro		:= STR0091	//"Não foi possível localizar as informações do cliente/loja do orçamento de serviços referente ao equipamento."
	lStatus	:= .F.
EndIf

If lStatus .AND. (lOsTec .OR. lIntTecMnt)

	If lExclui
		If lOsTec
			nOper := 5

			DbSelectArea('AB6')
			AB6->( DbSetOrder( 1 ) ) // AB6_FILIAL+AB6_NUMOS

			DbSelectArea('AB7')
			AB7->( DbSetOrder( 1 ) )  // AB7_FILIAL+AB7_NUMOS+AB7_ITEM

			If AB6->( DbSeek( cFilAB6+TEW->TEW_NUMOS ) ) .And. AB7->( DbSeek( cFilAB7+TEW->TEW_NUMOS+TEW->TEW_ITEMOS ) )

				aAdd( aCabOs, {'AB6_FILIAL', AB6->AB6_FILIAL, Nil } )
				aAdd( aCabOs, {'AB6_NUMOS' , AB6->AB6_NUMOS , Nil } )
				aAdd( aCabOs, {'AB6_CODCLI', AB6->AB6_CODCLI, Nil } )
				aAdd( aCabOs, {'AB6_LOJA'  , AB6->AB6_LOJA  , Nil } )
				aAdd( aCabOs, {'AB6_EMISSA', AB6->AB6_EMISSA, Nil } )
				aAdd( aCabOs, {'AB6_CONPAG', AB6->AB6_CONPAG, Nil } )

				While AB7->(! Eof()) .And. AB7->AB7_FILIAL == cFilAB7 .AND. AB7->AB7_NUMOS == AB6->AB6_NUMOS
					
					aAdd( xAux, {'AB7_FILIAL' , AB7->AB7_FILIAL , Nil } )
					aAdd( xAux, {'AB7_NUMOS'  , AB7->AB7_NUMOS  , Nil } )
					aAdd( xAux, {'AB7_ITEM'   , AB7->AB7_ITEM   , Nil } )
					aAdd( xAux, {'AB7_TIPO'   , AB7->AB7_TIPO   , Nil } )
					aAdd( xAux, {'AB7_CODPRO' , AB7->AB7_CODPRO , Nil } )
					aAdd( xAux, {'AB7_NUMSER' , AB7->AB7_NUMSER , Nil } )
					aAdd( xAux, {'AB7_CODPRB' , AB7->AB7_CODPRB , Nil } )

					aAdd( aItensOs, aClone( xAux ) )
					aSize( xAux, 0 )
					xAux := {}

					lExclOS := .T.
					AB7->( DbSkip() )
				End
			Else
				//Quando for Granel.
				DbSelectArea('TWP')
				TWP->( DbSetOrder( 1 ) )  // TWP_FILIAL+TWP_IDREG+TWP_NUMNF+TWP_SERNF+TWP_ITEMNF

				If TWP->( DbSeek( xFilial('TWP')+TEW->TEW_CODMV ) )

					cCodMov := TWP->TWP_IDREG
					cNumNf  := TWP->TWP_NUMNF
					cSerNf	:= TWP->TWP_SERNF
					
					While TWP->( !EOF() ) .And. ( TWP->TWP_IDREG == cCodMov .And.;
												  TWP->TWP_NUMNF == cNumNf  .And.;
												  TWP->TWP_SERNF == cSerNf )

						If AB6->( DbSeek( xFilial('AB6')+TWP->TWP_OSNUM ) ) .And. AB7->( DbSeek( xFilial('AB7')+TWP->TWP_OSNUM+TWP->TWP_OSITEM ) )
			
							aAdd( aCabOs, {'AB6_FILIAL', AB6->AB6_FILIAL, Nil } )
							aAdd( aCabOs, {'AB6_NUMOS' , AB6->AB6_NUMOS , Nil } )
							aAdd( aCabOs, {'AB6_CODCLI', AB6->AB6_CODCLI, Nil } )
							aAdd( aCabOs, {'AB6_LOJA'  , AB6->AB6_LOJA  , Nil } )
							aAdd( aCabOs, {'AB6_EMISSA', AB6->AB6_EMISSA, Nil } )
							aAdd( aCabOs, {'AB6_CONPAG', AB6->AB6_CONPAG, Nil } )
			
							While AB7->( !EOF() ) .And. AB7->AB7_NUMOS == AB6->AB6_NUMOS
								
								aAdd( xAux, {'AB7_FILIAL' , AB7->AB7_FILIAL , Nil } )
								aAdd( xAux, {'AB7_NUMOS'  , AB7->AB7_NUMOS  , Nil } )
								aAdd( xAux, {'AB7_ITEM'   , AB7->AB7_ITEM   , Nil } )
								aAdd( xAux, {'AB7_TIPO'   , AB7->AB7_TIPO   , Nil } )
								aAdd( xAux, {'AB7_CODPRO' , AB7->AB7_CODPRO , Nil } )
								aAdd( xAux, {'AB7_NUMSER' , AB7->AB7_NUMSER , Nil } )
								aAdd( xAux, {'AB7_CODPRB' , AB7->AB7_CODPRB , Nil } )
			
								aAdd( aItensOs, aClone( xAux ) )
								aSize( xAux, 0 )
								xAux := {}
			
								AB7->( DbSkip() )
							EndDo

						Endif
						
						If Len(aCabOs) > 0 .And. Len(aItensOs) > 0
							
							// troca a filial para o TEW_FILBAT
							If TEW->TEW_FILIAL <> TEW->TEW_FILBAT .And. cFilAnt <> TEW->TEW_FILBAT
								cFilAnt := TEW->TEW_FILBAT
							EndIf
							
							// chama a rotina automática para excluir a OS
							TECA450( NIL, aCabOs, aItensOs, NIL, nOper, @cCodOs )
							
							// retorna a filial para o cFilAnt
							If TEW->TEW_FILIAL <> TEW->TEW_FILBAT .And. cFilAnt <> cFilBkp
								cFilAnt := cFilBkp
							EndIf
							
							If lMsErroAuto			
								lStatus := .F.
								aEval( GetAutoGrLog(), {|x| cErro+= ConvAllToChar( x ) + CRLF } )
								Exit
							Else
								lExclOS := .F.
							Endif

							aSize( aCabOs, 0)
							aSize( aItensOs, 0)
							aSize( xAux, 0)

						Endif

						TWP->( DbSkip() )

					EndDo
				Endif
			EndIf
		Else
			DbSelectArea("STJ")
			STJ->(DbSetOrder(1)) //TJ_FILIAL+TJ_ORDEM+TJ_PLANO

			If STJ->(DbSeek(AA3->AA3_CDBMFL+TEW->TEW_NUMOS+"000000"))  // FILIAL DO BEM + ORDEM DE SERVICO + PLANO DE MANUTENCAO CORRETIVA
				lOkOrdemMNT := .T.
			EndIf
		EndIf
	Else

		If lOsTec
			// verifica se o equipamento e contrato/orçamento são da mesma filial
			// para capturar qual condição de pagamento a ser utilizada
			cCondPg := IIF( (TEW->TEW_FILIAL == TEW->TEW_FILBAT .Or. !lGSOpTri), ; 
								TFJ->TFJ_CONDPG,; // utiliza a condição de pagamento do orçamento de serviços
								Posicione("SC5",1, TWR->(TWR_FILPED+TWR_NUMPED), "C5_CONDPAG" ) )  // utiliza a condição do pedido adicional de remessa

			aAdd( aCabOs, {'AB6_CODCLI', cCliOS, Nil})
			aAdd( aCabOs, {'AB6_LOJA'  , cLojOS, Nil})
			aAdd( aCabOs, {'AB6_EMISSA', dDataBase, Nil})
			aAdd( aCabOs, {'AB6_CONPAG', cCondPg, Nil})
			aAdd( aCabOs, {'AB6_FILORC', TFJ->TFJ_FILIAL, Nil})
			aAdd( aCabOs, {'AB6_ORCAME', TFJ->TFJ_CODIGO, Nil})
			
			aAdd( xAux, {'AB7_ITEM'   , StrZero(1,2), Nil } )
			aAdd( xAux, {'AB7_TIPO'   , '1', Nil } ) // Tipo = O.S.
			aAdd( xAux, {'AB7_CODPRO' , AA3->AA3_CODPRO, Nil } )
			aAdd( xAux, {'AB7_NUMSER' , AA3->AA3_NUMSER, Nil } )
			aAdd( xAux, {'AB7_CODPRB' , cOcorPad, Nil } )
			aAdd( xAux, {'AB7_QTDSEP' , nQtdItens , Nil } )

			aAdd( aItensOs, aClone( xAux ) )
			aSize( xAux, 0 )
			xAux := {}
		Else
			// não precisa de preparativos para a chamada da função que gera a OS no MNT
			lOkOrdemMNT := .T.
		EndIf
	EndIf

	// dispara a execauto e captura o código da Os
	If lOsTec .And. Len(aCabOs) == 0 .And. Len(aItensOs) == 0 .And. lExclOS
		lStatus := .F.
		cErro   := STR0035 // 'Dados para exclusão da OS não identificados'
	EndIf

	If lStatus .And. lExclOS

		If lOsTec
			
			// troca a filial para o TEW_FILBAT
			If lGSOpTri .And. (TEW->TEW_FILIAL <> TEW->TEW_FILBAT .And. cFilAnt <> TEW->TEW_FILBAT)
				cFilAnt := TEW->TEW_FILBAT
			EndIf
			
			TECA450( NIL, aCabOs, aItensOs, NIL, nOper, @cCodOs )
			
			// retorna a filial para o cFilAnt
			If lGSOpTri .And. (TEW->TEW_FILIAL <> TEW->TEW_FILBAT .And. cFilAnt <> cFilBkp)
				cFilAnt := cFilBkp
			EndIf
			
			If lMsErroAuto
				lStatus := .F.
				aEval( GetAutoGrLog(), {|x| cErro+= ConvAllToChar( x ) + CRLF } )
				If Empty( cErro ) .And. nOper == 5
					cErro := STR0146  // "Problemas ao excluir a OS de inspeção do equipamento."
				EndIf
			Else
				If nOper == 5
					//-------------------------------------------------
					//  Remove a OS do registro de movimentação do Equipamento
					aAdd( xAux, { 'TEW_NUMOS'  , Space( TamSX3('AB6_NUMOS')[1] ) } )
					aAdd( xAux, { 'TEW_ITEMOS' , Space( TamSX3('AB7_ITEM')[1] ) } )
				Else
					//-------------------------------------------------
					//  Inclui a OS no registro de movimentação do Equipamento
					DbSelectArea("AB7")
					AB7->(DbSetOrder(1)) //AB7_FILIAL+AB7_NUMOS+AB7_ITEM
					
					If lGSOpTri
						lSeekSB7 := AB7->(DbSeek(xFilial("AB7", TEW->TEW_FILBAT )+cCodOs))
					Else
						lSeekSB7 := AB7->(DbSeek(xFilial("AB7", TEW->TEW_FILIAL )+cCodOs))
					EndIf
					
					If lSeekSB7
						If lIdUni //Verifica se é ID unico.
							If TEW->( ColumnPos('TEW_TPOS')) > 0
								aAdd( xAux, { 'TEW_TPOS' , "1" } )  //1=SIGATEC;2=SIGAMNT
							EndIf
						
							aAdd( xAux, { 'TEW_NUMOS'  , AB7->AB7_NUMOS } )
							aAdd( xAux, { 'TEW_ITEMOS' , AB7->AB7_ITEM } )
							aAdd( xAux,	{ 'TEW_FECHOS' , CTOD('')  } )
						Endif
						//Armazena os dados da OS quando for integração
						aDdOs := { "1",;  //Tipo da OS  // 1=SIGATEC;2=SIGAMNT
							       AB7->AB7_NUMOS,; //Num. OS
								   AB7->AB7_ITEM }  //Item. OS
					Endif
				EndIf
			EndIf
		ElseIf lOkOrdemMNT

			If lExclui
				// troca a filial para o TEW_FILBAT
				If lGSOpTri .And. (TEW->TEW_FILIAL <> TEW->TEW_FILBAT .And. cFilAnt <> TEW->TEW_FILBAT)
					cFilAnt := TEW->TEW_FILBAT
				EndIf
				
				NGDELETOS(TEW->TEW_NUMOS,"000000",STR0066)  // "Cancelamento de retorno do equipamento locado, por isso OS deve ser cancelada/excluída!"
				
				//Desbloqueia a base da tabela TWU
				oTecProv := TECProvider():New(AA3->AA3_NUMSER)
				if oTecProv:lValido
					oTecProv:UpdateTWU(TEW->TEW_CODMV,nQtdItens,cCodOs)
				EndIf
				TecDestroy(oTecProv)
				
				
				// retorna a filial para o cFilAnt
				If lGSOpTri.And. (TEW->TEW_FILIAL <> TEW->TEW_FILBAT .And. cFilAnt <> cFilBkp)
					cFilAnt := cFilBkp
				EndIf
				
				xAux := {}
				aAdd( xAux, { 'TEW_NUMOS'  , ' ' } )
			Else
				// cria a OS direto no módulo
				cIniStatusOS := CriaVar("TJ_SITUACA")
				If cIniStatusOS == "C" .Or. Empty(cIniStatusOS)
					cIniStatusOS := "P"
				EndIf
				
				// Desvio para considerar geração de O.S de manutenção, no retorno, para a filial Exclusiva
				If FWModeAccess("STJ",3) == "E" .AND. FWModeAccess("AA3",3) == "C"
					cFilOS := xFilial("STJ") 
				Else
					cFilOS := AA3->AA3_CDBMFL
				EndIf
				
				xAux := NGGERAOS("C"/*Corretiva*/, dDatabase, AA3->AA3_CODBEM, cServPad, '0'/*Sequência*/,'N','N','N',cFilOS,cIniStatusOS)

				If xAux[1,1]=='S'
					//Bloqueia o Saldo na TWU como Manutenção do SIGAMNT
					oTecProv := TecProvider():New(AA3->AA3_NUMSER)
					if oTecProv:lValido 
						oTecProv:InsertTWU(TEW->TEW_CODMV,AA3->AA3_NUMSER,nQtdItens,'2','2',cCodOs,'',.F.)
					Endif
					TecDestroy(oTecProv)
					
					cCodOs := xAux[1,3]
					aSize( xAux, 0)
					xAux := {}
					aAdd( xAux, { 'TEW_TPOS' , '2' } )
					aAdd( xAux, { 'TEW_NUMOS'  , cCodOs } )
					aAdd( xAux, { 'TEW_ITEMOS' , '  ' } )
					
					//Armazena os dados da OS quando for integração
					aDdOs := { "2",;  //Tipo da OS  // 1=SIGATEC;2=SIGAMNT
						       cCodOs,; //Num. OS
							   "" }  //Item. OS
				Else
					lStatus := .F.
					AtShowLog(xAux[1,2],STR0067,.T.,.T.,.T.)  // "Erro criação Ordem de Serviço MNT"
				EndIf
			EndIf
			
			//Atualiza o status da base de atendimento
			If lExclui
				aAdd(aDados, {'AA3_STATUS', AA3_CLIENTE})  // Status = "Equipamento em Cliente"				
			Else
				aAdd(aDados, {'AA3_STATUS', AA3_MANUTENCAO})  // Status = "Equipamento em Estoque"						
				aAdd(aDados, {'AA3_CODCLI', ''})
				aAdd(aDados, {'AA3_LOJA',   ''})
				aAdd(aDados, {'AA3_INALOC', CTOD('')})
				aAdd(aDados, {'AA3_FIALOC', CTOD('')})
				aAdd(aDados, {'AA3_CODLOC', ''})
				aAdd(aDados, {'AA3_ENTEQP', CTOD('')})
				aAdd(aDados, {'AA3_COLEQP', CTOD('')})
			EndIf
			cPrdAA3 := At820FilPd( TEW->TEW_PRODUT, TEW->TEW_FILIAL, TEW->TEW_FILBAT )
			lStatus := lStatus .And. At800Status(@cDetErro, aDados, (xFilial("AA3") + TEW->(TEW_BAATD + TEW_FILBAT)), .T.,cPrdAA3)

		EndIf

		//---------------------------------
		// Atualiza o movimento de locação, se existir atualização.
		If Len(xAux) > 0
			lStatus := lStatus .And. At800AtuMov( @cErro, xAux )
		Endif
		aSize( xAux, 0 )
		xAux := {}
	EndIf

	aSize( aCabOs, 0)
	aSize( aItensOs, 0)
	aSize( xAux, 0)
	aCabOs   := Nil
	aItensOs := Nil
	xAux     := Nil
EndIf

Return lStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} At800FechOs
	Atualiza as informações do Equipamento de Locação

@sample 	At800FechOs()
@since  	01/11/2013
@version  	P11.90
@param  	lExclusao, Logico, indica se é a operação de inclusão ou exclusão
@param 		dDiaFim, Data, define o dia de fechamento da OS { default: dDatabase}
@return 	lRet, Logico, Atualizou ou não os dados da Base e Movimentação
/*/
//-------------------------------------------------------------------
Function At800FechOs( lExclusao, dDiaFim, cNumOs )

Local lAtualizou		:= .F.
Local cMsgErro		:= STR0031 // 'Atualização não realizada'
Local aAux			:= { {},{} }
Local cCliOS 		:= ""
Local cCliBase		:= ""
Local lOrcame 		:= Empty(AB6->AB6_ORCAME)
Local lGSOpTri		:= SuperGetMv('MV_GSOPTRI',.F.,.F.) //Parametro para ativar a operação triangular
Local cAA3Ret 		:= ""
Local cTewBase		:= ''
Local lTEW := .F.
Local nRec := 0
Local lCllTC450 := IsInCallStack("At450AtuEqloc")
Local cItemOS	 := ""

Default dDiaFim := dDataBase
Default cNumOs := ""

If lCllTC450

	AA3->(DbSetorder(6))
	AA3->(DbSeek(xFilial('AA3')+AB7->AB7_NUMSER))
	cItemOS := AB7->AB7_ITEM 

	If !EMPTY(cNumOs) .AND. (TEW->(Eof()) .OR. !TEW->(TEW_NUMOS =  cNumOs .AND. TEW_ITEMOS = cItemOS ) ) 
		
		TEW->(DbSetOrder(9))
		
		If !(lTEW := TEW->( DbSeek( xFilial('TEW')+cNumOs+ cItemOs) ))
			TEW->(DbSetOrder(3))
			TEW->( DbSeek(xFilial('TEW')+AA3->AA3_NUMSER))
		EndIf
			
    Else
    	If !EMPTY(cNumOs)
    		lTEW := .T.
    	EndIf
	EndIf

Else	
	TEW->(DbSetOrder(3))
	lTEW := TEW->(DbSeek(xFilial('TEW')+AA3->AA3_NUMSER))
	
EndIf

If !EMPTY(AA3->AA3_CONTRT)
	DbSelectArea("AAH")
	DbSetOrder(1)
	
	If DbSeek(xFilial("AAH")+AA3->AA3_CONTRT) .AND.  AAH->AAH_ABRANG == '2' 
		cCliOS := AB6->AB6_CODCLI	
		cCliBase := AA3->AA3_CODCLI	
	Else
		cCliOS := AB6->AB6_CODCLI+AB6->AB6_LOJA
		cCliBase := AA3->AA3_CODCLI+AA3->AA3_LOJA
	EndIf
Else
	cCliOS := AB6->AB6_CODCLI+AB6->AB6_LOJA
	cCliBase := AA3->AA3_CODCLI+AA3->AA3_LOJA
EndIf

If lGSOpTri
	cAA3Ret := AA3->(AA3_FILORI+AA3_NUMSER)
Else
	cAA3Ret := AA3->(AA3_FILIAL+AA3_NUMSER)
EndIf

	
If !lExclusao
	
	//--Retorno do cliente (automatico)
	If !lOrcame .AND. Empty(TEW->TEW_FECHOS)
		aAdd( aAux[1], { 'TEW_FECHOS', dDiaFim } )

		aAdd( aAux[2], { 'AA3_STATUS', AA3_ESTOQUE } )  // Status = 'Equipamento em Estoque'
		aAdd( aAux[2], { 'AA3_CODCLI', '  '    } )
		aAdd( aAux[2], { 'AA3_LOJA'  , '  '    } )
		aAdd( aAux[2], { 'AA3_CODLOC', '  '    } )
		aAdd( aAux[2], { 'AA3_INALOC', CTOD('') } )
		aAdd( aAux[2], { 'AA3_FIALOC', CTOD('') } )
		aAdd( aAux[2], { 'AA3_ENTEQP', CTOD('') } )
		aAdd( aAux[2], { 'AA3_COLEQP', CTOD('') } )

		If ( (lTEW .AND. At800AtuMov( @cMsgErro, aAux[1], cTewBase, cNumOs)) .OR. !lTEW ) .AND. At800Status( @cMsgErro, aAux[2])  
		 	 lAtualizou := .T.
		EndIf			 
	
	//-- Encerra Os Manual Equip em cliente		
	ElseIf cCliOS == cCliBase .And. lOrcame .AND. lTEW 
	
		If  Empty(TEW->TEW_FECHOS)
			aAdd( aAux[1], { 'TEW_FECHOS', dDiaFim /*CTOD('')*/ } )
			aAdd( aAux[2], { 'AA3_STATUS', AA3->AA3_STAANT } )
		Else
			aAdd( aAux[1], { 'TEW_FECHOS', CTOD('') } )
			aAdd( aAux[2], { 'AA3_STATUS', AA3->AA3_STAANT } )		
		EndIf						 
		
		If ( (lTEW .AND. At800AtuMov( @cMsgErro, aAux[1], cTewBase, cNumOs)) .OR. !lTEW) .AND. At800Status( @cMsgErro, aAux[2],cAA3Ret, ,AA3->AA3_CODPRO )
		 	 lAtualizou := .T.
		 EndIf			 
		
	//--Os manual Equip. em estoque	
	ElseIf (Empty(cCliBase) .OR. (isInCallStack("AT450Alter") .AND. cCliOS == cCliBase .AND. (AA3->AA3_STATUS == '03'))) .And. lOrcame 
	

		If Empty(cCliBase)
			aAdd( aAux[2], { 'AA3_STATUS', AA3_ESTOQUE } )
		Else
			aAdd( aAux[2], { 'AA3_STATUS', AA3_CLIENTE } )
		EndIf
		
		If At800Status( @cMsgErro, aAux[2],cAA3Ret, ,AA3->AA3_CODPRO)
		 	 lAtualizou := .T.
		EndIf
			

	//-- Encerra O.S., quando retorna de cliente sem NF	
	ElseIf !lOrcame	
		
		If Empty(TEW->TEW_FECHOS)			
			aAdd( aAux[1], { 'TEW_FECHOS', dDiaFim } )
			aAdd( aAux[2], { 'AA3_STATUS', AA3->AA3_STAANT } )
		Else
			aAdd( aAux[1], { 'TEW_FECHOS', CTOD('') } )
			aAdd( aAux[2], { 'AA3_STATUS', AA3->AA3_STAANT } )		
		EndIf	 
		
		If ( (lTEW .AND. At800AtuMov( @cMsgErro, aAux[1], cTewBase, cNumOs )) .OR. !lTEW) .AND. At800Status( @cMsgErro, aAux[2],cAA3Ret, ,AA3->AA3_CODPRO ) 
		 	 lAtualizou := .T.
		EndIf			 
		
	//--Caso seja somente alteração da AB6 e não necessite alterar status de AA3 e TEW.
	Else	
		lAtualizou := .T.
	EndIf
	
Else

	DbSelectArea('TFI')
	TFI->( DbSetOrder( 1 ) ) // TFI_FILIAL+TFI_CODIGO
		
	
	If !lOrcame .And. TFI->( DbSeek( xFilial('TFI')+TEW->TEW_CODEQU ) )

		DbSelectArea('TFL')
		TFL->( DbSetOrder( 1 ) ) //TFL_FILIAL+TFL_CODIGO

		DbSelectArea('TFJ')
		TFJ->( DbSetOrder( 1 ) ) //TFJ_FILIAL+TFJ_CODIGO

		TFL->( DbSeek( xFilial('TFL')+TFI->TFI_CODPAI ))
		TFJ->( DbSeek( xFilial('TFJ')+TFL->TFL_CODPAI ))

		aAdd( aAux[1], { 'TEW_FECHOS', CTOD('') } )

		aAdd( aAux[2], { 'AA3_STATUS', AA3_MANUTENCAO  } )  // Status = 'Equipamento em Manutenção'
		aAdd( aAux[2], { 'AA3_CODCLI', TFJ->TFJ_CODENT } )
		aAdd( aAux[2], { 'AA3_LOJA'  , TFJ->TFJ_LOJA   } )
		aAdd( aAux[2], { 'AA3_CODLOC', TFI->TFI_LOCAL  } )
		aAdd( aAux[2], { 'AA3_INALOC', TFI->TFI_PERINI } )
		aAdd( aAux[2], { 'AA3_FIALOC', TFI->TFI_PERFIM } )
		aAdd( aAux[2], { 'AA3_ENTEQP', TFI->TFI_ENTEQP } )
		aAdd( aAux[2], { 'AA3_COLEQP', TFI->TFI_COLEQP } )
				
		If ( ( lTEW .AND. At800AtuMov( @cMsgErro, aAux[1], cTewBase, cNumOs)) .OR. !lTEW) .AND. At800Status( @cMsgErro, aAux[2])
		 	 lAtualizou := .T.
		EndIf	

	Else
		aAdd( aAux[2], { 'AA3_STATUS', AA3_MANUTENCAO } )
		
		If At800Status( @cMsgErro, aAux[2],cAA3Ret, ,AA3->AA3_CODPRO )
			lAtualizou := .T.
		EndIf
		
	EndIf
EndIf

If lAtualizou
	At800MntCli()
EndIf

If !lAtualizou
	Help(" ",1,'AT450ATULOC',, ;
			STR0032 + CRLF + ; // 'Não foi possível atualizar o movimento de locação de equipamentos.'
			STR0033 + cMsgErro, 1, 0) // 'Detalhes: '
EndIf

aSize( aAux, 0)

Return lAtualizou

//-------------------------------------------------------------------
/*/{Protheus.doc} At800HasMov
	Verifica se há movimentos mais recentes

@sample 	At800HasMov()
@since  	01/11/2013
@version  	P11.90
@param  	ExpN, Numerico, numero do recno da AB7 a ser validada
@return 	ExpL, Logico, se tem registro ou não vinculados a OS informada
/*/
//-------------------------------------------------------------------
Function At800HasMov( lOs, nRecnoAval, lMNT )

Local lRet          := .F.
Local cAliasVld      := GetNextAlias()
Local oTecPvd 		:= Nil
Local nQtDisp 		:= 0

Default lOs         := .T.
Default lMNT 		:= .F.
Default nRecnoAval    := If( lOs, If(lMNT, TEW->(Recno()), AB7->(Recno())), SD1->(Recno()) )

If Posicione( "SB5", 1, xFilial("SB5",SD1->D1_FILIAL)+SD1->D1_COD, "B5_ISIDUNI" ) <> "2"
	If lOs
	
		If !lMNT
			BeginSql Alias cAliasVld
	
				SELECT 1 FIND
				FROM %Table:AB7% AB7
					INNER JOIN %Table:TEW% TEW ON TEW.TEW_FILIAL = %xFilial:TEW% AND TEW.TEW_NUMOS = AB7.AB7_NUMOS 
											AND TEW.TEW_ITEMOS = AB7.AB7_ITEM
				WHERE AB7.R_E_C_N_O_ = %Exp:nRecnoAval%
					AND EXISTS (
						SELECT TEW_BAATD
						FROM %Table:TEW% TEWEX
						WHERE TEWEX.%NotDel% AND TEWEX.TEW_BAATD = AB7.AB7_NUMSER AND
							NOT TEWEX.R_E_C_N_O_ = TEW.R_E_C_N_O_ AND TEWEX.TEW_DTSEPA > TEW.TEW_DTSEPA )
	
			EndSql
		Else
	
			BeginSql Alias cAliasVld
				SELECT 1 FIND
				FROM %Table:TEW% TEW
				WHERE TEW.%NotDel%
					AND TEW.R_E_C_N_O_=%Exp:nRecnoAval%
					AND EXISTS(
						SELECT TEW_BAATD
						FROM %Table:TEW% TEWEX
						WHERE TEWEX.%NotDel%
							AND TEWEX.TEW_FILIAL=%xFilial:TEW%
							AND NOT TEWEX.R_E_C_N_O_ = TEW.R_E_C_N_O_
							AND TEWEX.TEW_FILIAL = TEW.TEW_FILIAL
							AND TEWEX.TEW_BAATD = TEW.TEW_BAATD
							AND TEWEX.TEW_DTSEPA > TEW.TEW_DTSEPA
					)
			EndSql
		EndIf
	Else
		BeginSql Alias cAliasVld
	
			SELECT 1 FIND
			FROM %Table:SD1% SD1
				INNER JOIN %Table:TEW% TEW ON TEW.TEW_FILIAL = %xFilial:TEW% AND
					TEW.TEW_NFENT = SD1.D1_DOC AND TEW.TEW_SERENT = SD1.D1_SERIE AND TEW.TEW_ITENT = SD1.D1_ITEM AND TEW.TEW_PRODUT = SD1.D1_COD AND
					TEW.TEW_NFSAI = SD1.D1_NFORI AND TEW.TEW_SERSAI = SD1.D1_SERIORI AND TEW.TEW_ITSAI = SD1.D1_ITEMORI
			WHERE SD1.R_E_C_N_O_ = %Exp:nRecnoAval%
				AND EXISTS (
					SELECT TEW_BAATD
					FROM %Table:TEW% TEWEX
					WHERE TEWEX.%NotDel% AND TEWEX.TEW_FILBAT = TEW.TEW_FILBAT 
						AND TEWEX.TEW_BAATD = TEW.TEW_BAATD AND TEWEX.TEW_PRODUT = TEW.TEW_PRODUT 
						AND NOT TEWEX.R_E_C_N_O_ = TEW.R_E_C_N_O_ AND TEWEX.TEW_DTSEPA > TEW.TEW_DTSEPA )
	
		EndSql
	EndIf
	
	If (cAliasVld)->(! Eof())
		lRet := .T.
	EndIf
	
Else
	
	BeginSQL Alias cAliasVld
	
		SELECT TEW.R_E_C_N_O_ TEWRECNO
		FROM %Table:SD1% SD1
			INNER JOIN %Table:TWP% TWP ON TWP_FILNF = D1_FILIAL
									AND TWP_NUMNF = D1_DOC
									AND TWP_SERNF = D1_SERIE
									AND TWP_ITEMNF = D1_ITEM
									AND TWP.%NotDel%
			INNER JOIN %Table:TEW% TEW ON TEW_FILIAL = TWP_FILIAL
									AND TEW_CODMV = TWP_IDREG
									AND TEW.%NotDel%
		WHERE SD1.%NotDel%
			AND SD1.R_E_C_N_O_ = %Exp:nRecnoAval%
	EndSQL
	
	If (cAliasVld)->(!EOF())
		
		TEW->( DbGoTo( (cAliasVld)->TEWRECNO ) )
		
		oTecPvd := TECProvider():New(TEW->TEW_BAATD,TEW->TEW_FILBAT)
		nQtDisp := oTecPvd:SaldoDisponivel()
		lRet := ( SD1->D1_QUANT > nQtDisp )
		
		TecDestroy(oTecPvd)
	EndIf 
EndIf

(cAliasVld)->( DbCloseArea() )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At800ExcD1
	Valida a exclusão da nota de entrada (doc. devolução do equipamento de locação)

@sample 	At800ExcD1()
@since  	01/11/2013
@version  	P11.90
@param  	ExpN, Numerico, numero do recno da AB7 a ser validada
@return 	ExpL, Logico, se tem registro ou não vinculados a OS informada
/*/
//-------------------------------------------------------------------
Function At800ExcD1( nPosSF1 )

Local lRet       := .T.

Local aSave      := GetArea()
Local aSaveSF1   := SF1->( GetArea() )
Local aSaveSD1   := SD1->( GetArea() )

SF1->( DbGoTo( nPosSF1 ) )

SD1->( DbSetOrder( 1 ) ) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM

lRet := SD1->( DbSeek( SF1->( F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA ) ) )

While lRet .And. SD1->(! Eof()) .And. SF1->F1_FILIAL == SD1->D1_FILIAL .And. ;
		SF1->F1_DOC == SD1->D1_DOC .And. SF1->F1_SERIE == SD1->D1_SERIE .And. ;
		SF1->F1_FORNECE == SD1->D1_FORNECE .And. SF1->F1_LOJA == SD1->D1_LOJA

	lRet := !At800HasMov( .F., SD1->( Recno() ) )

	SD1->( DbSkip() )
EndDo

If !lRet
	Help(,,'AT800DelNF',,STR0034,1,0) // 'Não é possível excluir a NF de devolução pois já houve novos movimentos no equipamento devolvido'
EndIf

RestArea( aSaveSD1 )
RestArea( aSaveSF1 )
RestArea( aSave )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At800LibLoc
	Valida a exclusão da nota de entrada (doc. devolução do equipamento de locação)

@sample 	At800CancRet()
@since  	10/02/2014
@version  	P12
@return 	lRet
/*/
//-------------------------------------------------------------------
Function At800LibLoc(cTab, nOpc, nRecno)

Local aArea		:= GetArea()
Local cAgrup		:= TEW->TEW_KITSEQ
Local cCodOrc		:= TEW->TEW_ORCSER
Local cExgNf		:= "2"
Local cTxt			:= ""
Local aPlEtp		:= {}
Local lChkHrm		:= .T.
Local lRet			:= .F.
Local lExibeMsg	:= .T.
Local aDados := {}
Local cCodClient := ""
Local clojClient := ""
Local cFilTEW		:= xFilial("TEW")
Local lTEC800LL		:= ExistBlock("TEC800LL")
Local lTecAtf		:= SuperGetMv('MV_TECATF', .F.,'N') == 'S'
Local lUnic			:= .T.
Local oTecProvider	:= Nil
Local lContinua 	:= .T.
Local cCliBase 		:= ""
Local cLojBase 		:= ""
Local cPrdAA3 		:= At820FilPd( TEW->TEW_PRODUT, TEW->TEW_FILIAL, TEW->TEW_FILBAT )
Local lGSOpTri		:= SuperGetMv('MV_GSOPTRI',.F.,.F.) //Parametro para ativar a operação triangular
Local lExgNf		:= .F.

If lGSOpTri
	lContinua := AtPosAA3( TEW->(TEW_FILBAT+TEW_BAATD), cPrdAA3 )
Else
	DbSelectArea('AA3')
	AA3->( DbSetOrder( 6 ) ) // AA3_FILIAL+AA3_NUMSER
	lContinua := AA3->( DbSeek( xFilial('AA3')+TEW->TEW_BAATD ) )
EndIf

cExgNf := AA3->AA3_EXIGNF
lExgNf := cExgNf == "1"

If lContinua .And. cExgNf == "2"	// A separação do equipamento não exige a emissão de uma NF de saída...

	If TEW->TEW_DTSEPA <> CTOD("") .AND. TEW->TEW_BAATD <> "" .AND. TEW->TEW_DTRINI == CTOD("")

		// Verifica se a cobrança da locação do equipamento está configurada com o uso de 'horimetro'.
		// Caso afirmativo, analisará se a informação do valor de saída desse horimetro está atualizada
		// para que a liberação de sua locação ocorra. Caso a cobrança da locação do equipamento não
		// esteja configurada com o uso de 'horimetro', então, o retorno dessa função assumirá como 
		// possível a liberação da locação de tal equipamento.
		// Observação: Como a separação dos equipamentos que passarem por este ponto NÃO necessitam da
		// emissão de uma NF de saída, consequentemente, os campos de número e item do pedido de venda
		// estarão com conteúdo igual a VAZIO.
		lChkHrm := At970ChkHr("SEP" /*cFase*/,;
	                          TEW->TEW_NUMPED /*cNumPV*/,;
	                          TEW->TEW_ITEMPV /*cItemPV*/,;
	                          TEW->TEW_ORCSER /*cOrcSer*/,;
	                          TEW->TEW_CODMV /*cCodMV*/,;
	                          TEW->TEW_CODEQU /*cCodEqu*/,;
	                          TEW->TEW_PRODUT /*cProdut*/,;
	                          TEW->TEW_BAATD /*cBaAtd*/,;
	                          .T. /*lExibeMsg*/)
		
		If lChkHrm

			// busca o cliente e loja e deixa a estrutura posicionada (TFJ, TFL e TFI)
			At820CliLoj( @cCodClient, @clojClient, TEW->TEW_CODEQU )
				
			Begin Transaction
				
				If lTEC800LL 
					Execblock("TEC800LL", .F., .F.) 
				EndIf

				If !Empty(cAgrup)
					DbSelectArea("TEW")
					DbSetOrder(12) // TEW->TEW_FILIAL+TEW_KITSEQ
					If TEW->(DbSeek(xFilial("TEW")+ cAgrup))
						While TEW->(!Eof()) .And. cFilTEW == TEW->TEW_FILIAL .And. TEW->TEW_KITSEQ == cAgrup

							lUnic := .T.
							
							TEW->(RecLock("TEW", .F.))
							TEW->TEW_DTRINI := dDataBase
							TEW->(MsUnLock())
							
							cTxt += "<b> "+STR0072+"</b> "+At800DsInf("TFI", "TFI_CONTRT", xFilial("TFI")+TEW->TEW_CODEQU ) //"Nr. Contrato: "
							cTxt += "<b> "+STR0070+"</b> "+TEW->TEW_PRODUT //"Cod. Produto: "
							cTxt += "<b> "+STR0071+"</b> "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+"<br>" //"Descrição: "

							If Empty(aPlEtp)
								aPlEtp := At774PlEtp("TEW",xFilial("TFI")+TEW->TEW_CODEQU)
							Endif
							
							//Verifica se existe a integração do TEC x ATF.	
							If lTecAtf .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
								oTecProvider := TECProvider():New(TEW->TEW_BAATD, TEW->TEW_FILBAT)
								lUnic := oTecProvider:lIdUnico	
								oTecProvider:UpdateTWI(TEW->TEW_CODMV,,,,.T.)
								TecDestroy(oTecProvider)
							EndIf
			
							If lUnic
								
								aDados := {}
								// atualiza os dados relacionados com a alocação do equipamento na Base de Atendimento
								aAdd( aDados, { 'AA3_STATUS', AA3_CLIENTE } )  // atualiza o status da base de atendimento :: "Equipamento em Cliente"
								aAdd( aDados, { 'AA3_FILLOC', TEW->TEW_FILIAL } )
								If TEW->TEW_FILIAL == TEW->TEW_FILBAT
									aAdd( aDados, { 'AA3_CODCLI', cCodClient } )
									aAdd( aDados, { 'AA3_LOJA'  , clojClient } )
								Else
									At800ClToOs( @cCliBase, @cLojBase )
									aAdd( aDados, { 'AA3_CODCLI', cCliBase } )
									aAdd( aDados, { 'AA3_LOJA'  , cLojBase} )
								EndIf
								aAdd( aDados, { 'AA3_CODLOC', TFI->TFI_LOCAL  } )
								aAdd( aDados, { 'AA3_INALOC', TFI->TFI_PERINI } )
								aAdd( aDados, { 'AA3_FIALOC', TFI->TFI_PERFIM } )
								aAdd( aDados, { 'AA3_ENTEQP', TFI->TFI_ENTEQP } )
								aAdd( aDados, { 'AA3_COLEQP', TFI->TFI_COLEQP } )
								
							    At800Status( , aDados )
							EndIf
							// verifica se o equipamento separado é de outra filial
							If TEW->TEW_FILIAL <> TEW->TEW_FILBAT
								
								DbSelectArea("TWR")
								TWR->(DbSetOrder(1)) //TWR_FILIAL+TWR_CODMOV
								
								If TWR->(DbSeek(xFilial("TWR")+TEW->TEW_CODMV))
									// Grava a quantidade de saída conforme a qtde separada no item
									Reclock("TWR",.F.)
										TWR->TWR_QTDSAI := TEW->TEW_QTDVEN
									TWR->(MsUnlock())
								EndIf
							EndIf

							TEW->(DbSkip())
						EndDo
							
					EndIf
				Else
					TEW->(RecLock("TEW", .F.))
					TEW->TEW_DTRINI := dDataBase
					TEW->(MsUnLock())
					//Verifica se existe a integração do TEC x ATF.	
					If lTecAtf .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
						oTecProvider := TECProvider():New(TEW->TEW_BAATD, TEW->TEW_FILBAT)
						lUnic := oTecProvider:lIdUnico	
						oTecProvider:UpdateTWI(TEW->TEW_CODMV,,,,.T.)
						TecDestroy(oTecProvider)
					EndIf	
					
					If lUnic
						aDados := {}
						// atualiza os dados relacionados com a alocação do equipamento na Base de Atendimento
						aAdd( aDados, { 'AA3_STATUS', AA3_CLIENTE } )  // atualiza o status da base de atendimento :: "Equipamento em Cliente"
						aAdd( aDados, { 'AA3_FILLOC', TEW->TEW_FILIAL } )
						If TEW->TEW_FILIAL == TEW->TEW_FILBAT
							aAdd( aDados, { 'AA3_CODCLI', cCodClient } )
							aAdd( aDados, { 'AA3_LOJA'  , cLojClient } )
						Else
							At800ClToOs( @cCliBase, @cLojBase )
							aAdd( aDados, { 'AA3_CODCLI', cCliBase } )
							aAdd( aDados, { 'AA3_LOJA'  , cLojBase} )
						EndIf
						aAdd( aDados, { 'AA3_CODLOC', TFI->TFI_LOCAL  } )
						aAdd( aDados, { 'AA3_INALOC', TFI->TFI_PERINI } )
						aAdd( aDados, { 'AA3_FIALOC', TFI->TFI_PERFIM } )
						aAdd( aDados, { 'AA3_ENTEQP', TFI->TFI_ENTEQP } )
						aAdd( aDados, { 'AA3_COLEQP', TFI->TFI_COLEQP } )
						
					    At800Status( , aDados )
				EndIf
					// verifica se o equipamento separado é de outra filial
					If TEW->TEW_FILIAL <> TEW->TEW_FILBAT
						
						DbSelectArea("TWR")
						TWR->(DbSetOrder(1)) //TWR_FILIAL+TWR_CODMOV
						
						If TWR->(DbSeek(xFilial("TWR")+TEW->TEW_CODMV))
							// Grava a quantidade de saída conforme a qtde separada no item
							Reclock("TWR",.F.)
								TWR->TWR_QTDSAI := TEW->TEW_QTDVEN
							TWR->(MsUnlock())
						EndIf
					EndIf
				EndIf

				If Empty(cTxt)
					cTxt := "<b> "+STR0072+"</b> "+At800DsInf("TFI", "TFI_CONTRT", xFilial("TFI")+TEW->TEW_CODEQU ) //"Nr. Contrato: "
					cTxt += "<b> "+STR0070+"</b> "+TEW->TEW_PRODUT //"Cod. Produto: "
					cTxt += "<b> "+STR0071+"</b> "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+"<br>" //"Descrição: "
					If Empty(aPlEtp)
						aPlEtp := At774PlEtp("TEW",xFilial("TFI")+TEW->TEW_CODEQU)
					Endif
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³SIGATEC WorkFlow # LI - Liberação de Locação	  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				At774Mail("TEW",cCodOrc,"LI",cTxt,,,aPlEtp)
				
				lRet	:= .T.
			End Transaction

		ElseIf !lChkHrm

			If	MsgYesNo(STR0085)	//"Deseja realizar a atualização do horimetro do equipamento neste momento?"
				If	At970AtHor("SEP" /*cFase*/,;
					           cPrdAA3 /*cCodPro*/,;
					           Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC") /*cDescPro*/,;
					           TEW->TEW_BAATD /*cIDUnico*/, TEW->TEW_FILBAT )
					MsgInfo(STR0086)	//"Refaça o procedimento de solicitar a liberação da locação do equipamento."
					lExibeMsg	:= .F.
				EndIf
			EndIf

		EndIf
	EndIf
EndIf

If	!lRet .AND. lExibeMsg
	If lExgNf 
		Help(,,'AT800ExgNf',,STR0147,1,0)  //'Este equipamente exige Nota Fiscal, favor realizar a liberação atraves do Pedido de venda.'
	Else
		Help(,,'AT800Liberacao',,STR0058,1,0)  //'Não é possível realizar a liberação da Locação'
	EndIf
EndIf
RestArea(aArea)
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} At800CancLib
	Realiza o cancelamento da liberação do equipamento.

@sample 	At800CancLib()
@since  	10/02/2014
@version  	P12
@return 	lRet
/*/
//-------------------------------------------------------------------
Function At800CancLib(cTab, nOpc, nRecno)
Local aArea		:=	GetArea()
Local aDados		:= {}
Local cExgNf		:= ""
Local cDetErro	:= ""
Local aPlEtp		:= ""
Local cTxt			:= ""
Local oTecProvider	:= Nil
Local oMdlMov		:= Nil
Local cMsgErro		:= ""
Local lTecAtf 		:= SuperGetMv('MV_TECATF', .F.,'N') == 'S'
Local lGSOpTri		:= SuperGetMv('MV_GSOPTRI',.F.,.F.) //Parametro para ativar a operação triangular
Local cAgrup		:= TEW->TEW_KITSEQ
Local cCodOrc		:= TEW->TEW_ORCSER
Local cCodLoc		:= TEW->TEW_CODEQU
Local lUnic			:= .T.
Local cFilTEW  		:= xFilial("TEW")
Local cPrdAA3 		:= At820FilPd( TEW->TEW_PRODUT, TEW->TEW_FILIAL, TEW->TEW_FILBAT )
Local lContinua 	:= .F.

If lGSOpTri
	lContinua 	:= AtPosAA3(TEW->(TEW_FILBAT+TEW_BAATD), cPrdAA3)
Else
	DbSelectArea('AA3')
	AA3->( DbSetOrder( 6 ) ) // AA3_FILIAL+AA3_NUMSER
	lContinua := AA3->( DbSeek( xFilial('AA3')+TEW->TEW_BAATD ) )
EndIf

cExgNf := AA3->AA3_EXIGNF
Begin Transaction
	
	If lContinua .And. TEW->TEW_DTRINI <> CTOD("") .AND. TEW->TEW_DTRFIM == CTOD("") .AND. cExgNf == "2"

		If TEW->TEW_DTAMNT <> CTOD("")
			lContinua := .F.
			Help(,, "AT800_NOCANC",,STR0142,1,0) // "Alocação não pode ser cancelada pois o equipamento sofreu intervenção de Cancelamento ou Substituição."
		Else
			aDados := {}
			aAdd( aDados, {"TEW_DTRINI", CTOD("")})
			At800AtuMov( @cDetErro, aDados )

			If ! Empty(cAgrup)
				DbSelectArea("TEW")
				DbSetOrder(12)
				If TEW->(DbSeek(xFilial("TEW")+ cAgrup))
					While !TEW->(Eof()) .And. TEW->TEW_FILIAL == cFilTEW .AND. TEW->TEW_KITSEQ == cAgrup
						lUnic  := .T.
						aDados := {}
						aAdd( aDados, {"TEW_DTRINI", CTOD("")})
						At800AtuMov( @cDetErro, aDados )

						If Empty(aPlEtp)
							aPlEtp := At774PlEtp("TEW",xFilial("TFI")+TEW->TEW_CODEQU)
						Endif

						cTxt += "<b> "+STR0072+"</b> "+At800DsInf("TFI", "TFI_CONTRT", xFilial("TFI")+TEW->TEW_CODEQU ) //"Nr. Contrato: "
						cTxt += "<b> "+STR0070+"</b> "+TEW->TEW_PRODUT //"Cod. Produto: "
						cTxt += "<b> "+STR0071+"</b> "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+"<br>" //"Descrição: "
						
						//Verifica se existe a integração do TEC x ATF.	
						If lTecAtf .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
							oTecProvider := TECProvider():New()
							oTecProvider:UpdateTWI(TEW->TEW_CODMV,,,,.F.)
							TecDestroy(oTecProvider)
						EndIf
						
						If lUnic
							aDados := {}
							
							aAdd( aDados, { "AA3_STATUS", AA3_SEPARADO } )  // atualiza o status da base de atendimento :: "Equipamento em Cliente"
							aAdd( aDados, { "AA3_CODCLI", " " 	   } )
							aAdd( aDados, { "AA3_LOJA"  , " " 	   } )
							aAdd( aDados, { "AA3_CODLOC", " " 	   } )
							aAdd( aDados, { "AA3_INALOC", CTOD("") } )
							aAdd( aDados, { "AA3_FIALOC", CTOD("") } )
							aAdd( aDados, { "AA3_ENTEQP", CTOD("") } )
							aAdd( aDados, { "AA3_COLEQP", CTOD("") } )
							
							At800Status( , aDados )					
						Endif
						
						// verifica se o equipamento separado é de outra filial
						If TEW->TEW_FILIAL <> TEW->TEW_FILBAT
							
							DbSelectArea("TWR")
							TWR->(DbSetOrder(1)) //TWR_FILIAL+TWR_CODMOV
							
							If TWR->(DbSeek(xFilial("TWR")+TEW->TEW_CODMV))
								// Grava a quantidade de saída conforme a qtde separada no item
								Reclock("TWR",.F.)
									TWR->TWR_QTDSAI := 0
								TWR->(MsUnlock())
							EndIf
						EndIf
						
						TEW->(DbSkip())
					End
				EndIf
			Else
				//Verifica se existe a integração do TEC x ATF.
				If lTecAtf .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
					oTecProvider := TECProvider():New(TEW->TEW_BAATD,TEW->TEW_FILBAT)
					lUnic := oTecProvider:lIdUnico
					oTecProvider:UpdateTWI(TEW->TEW_CODMV,,,,.F.)
					TecDestroy(oTecProvider)
				EndIf
					
				If lUnic
					aDados := {}
					
					aAdd( aDados, { "AA3_STATUS", AA3_SEPARADO } )  // atualiza o status da base de atendimento :: "Equipamento em Cliente"
					aAdd( aDados, { "AA3_CODCLI", " " 	   } )
					aAdd( aDados, { "AA3_LOJA"  , " " 	   } )
					aAdd( aDados, { "AA3_CODLOC", " " 	   } )
					aAdd( aDados, { "AA3_INALOC", CTOD("") } )
					aAdd( aDados, { "AA3_FIALOC", CTOD("") } )
					aAdd( aDados, { "AA3_ENTEQP", CTOD("") } )
					aAdd( aDados, { "AA3_COLEQP", CTOD("") } )
					
					At800Status( , aDados )
				Endif
				
				// verifica se o equipamento separado é de outra filial
				If TEW->TEW_FILIAL <> TEW->TEW_FILBAT
					
					DbSelectArea("TWR")
					TWR->(DbSetOrder(1)) //TWR_FILIAL+TWR_CODMOV
					
					If TWR->(DbSeek(xFilial("TWR")+TEW->TEW_CODMV))
						// Grava a quantidade de saída conforme a qtde separada no item
						Reclock("TWR",.F.)
							TWR->TWR_QTDSAI := 0
						TWR->(MsUnlock())
					EndIf
				EndIf
			EndIf

			If Empty(cTxt)
				cTxt := "<b> "+STR0072+"</b> "+At800DsInf("TFI", "TFI_CONTRT", xFilial("TFI")+TEW->TEW_CODEQU ) //"Nr. Contrato: "
				cTxt += "<b> "+STR0070+"</b> "+TEW->TEW_PRODUT //"Cod. Produto: "
				cTxt += "<b> "+STR0071+"</b> "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+"<br>" //"Descrição: "
				If Empty(aPlEtp)
					aPlEtp := At774PlEtp("TEW",xFilial("TFI")+TEW->TEW_CODEQU)
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SIGATEC WorkFlow # LI - Cancelamento da Liberação de Locação   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			At774Mail("TEW",cCodOrc,"LI",cTxt,"RED",STR0073,aPlEtp) //"Cancelamento"
			
			MsgInfo(STR0100,STR0101) // "Atualização finalizada!" ### "Cancelamento da liberação"
		EndIf
		
	Else
		lContinua := .F.
		Help(,,'AT800CancLib',,STR0046,1,0)//"Não é possível Cancelar o movimento"
	EndIf

End Transaction
RestArea(aArea)
Return lContinua

//-------------------------------------------------------------------
/*/{Protheus.doc} At800RetLib
	Realiza o retorno dos equipamentos que não exige NF.

@sample 	At800RetLib()
@since  	10/02/2014
@version  	P12
@return 	lRet
/*/
//-------------------------------------------------------------------

Function At800RetLib()
Local aArea			:= GetArea()
Local aAreaTEW		:= Nil
Local cAgrup		:= TEW->TEW_KITSEQ
Local cCodEquip		:= TEW->TEW_CODEQU
Local cCodReq		:= ""
Local cExgNf		:= ""
Local lOk			:= .T.
Local lChkHrm		:= .F.
Local xAux			:= {}
Local cDetErro		:= ''
Local cTxt			:= ""
Local aPlEtp		:= {}
Local cFilTEW		:= xFilial("TEW")
Local lTEC800RL		:= ExistBlock("TEC800RL")
Local oTecProvider	:= Nil
Local lTecAtf 		:= SuperGetMv('MV_TECATF', .F.,'N') == 'S'
Local lGSOpTri		:= SuperGetMv('MV_GSOPTRI',.F.,.F.) //Parametro para ativar a operação triangular
Local lUnic			:= .T.
Local nQtdRt		:= 0
Local aPrBox		:= {}
Local aRet			:= {}
Local bVldBox		:= {|| At800VlBox("1") }
Local lParcKit		:= .F.
Local lContinua 	:= .F.
Local cPrdAA3 		:= At820FilPd( TEW->TEW_PRODUT, TEW->TEW_FILIAL, TEW->TEW_FILBAT )

If lGSOpTri
	lContinua := AtPosAA3(TEW->(TEW_FILBAT+TEW_BAATD), cPrdAA3)
Else
	DbSelectArea('AA3')
	AA3->( DbSetOrder( 6 ) ) // AA3_FILIAL+AA3_NUMSER
	lContinua := AA3->( DbSeek( xFilial('AA3')+TEW->TEW_BAATD ) )
EndIf

cExgNf := AA3->AA3_EXIGNF

If lContinua .And. TEW->TEW_DTRINI <> CTOD("") .AND. TEW->TEW_DTRFIM == CTOD("") .AND. cExgNf=="2"
	Begin Transaction

		If lTEC800RL 
			Execblock("TEC800RL", .F., .F.) 
		EndIf 

		// Verifica se a cobrança da locação do equipamento está configurada com o uso de 'horimetro'.
		// Caso afirmativo, analisará se a informação do valor de retorno desse horimetro está atualizada
		// para que a liberação de sua locação ocorra. Caso a cobrança da locação do equipamento não
		// esteja configurada com o uso de 'horimetro', então, o retorno dessa função assumirá como 
		// possível a liberação do retorno de tal equipamento.
		// Observação: Como o retorno dos equipamentos que passarem por este ponto NÃO necessitam da
		// emissão de uma NF de saída, consequentemente, os campos de número e item do pedido de venda
		// estarão com conteúdo igual a VAZIO.
		lChkHrm := At970ChkHr("RET" /*cFase*/,;
		                      TEW->TEW_NUMPED /*cNumPV*/,;
		                      TEW->TEW_ITEMPV /*cItemPV*/,;
		                      TEW->TEW_ORCSER /*cOrcSer*/,;
		                      TEW->TEW_CODMV /*cCodMV*/,;
		                      TEW->TEW_CODEQU /*cCodEqu*/,;
		                      TEW->TEW_PRODUT /*cProdut*/,;
		                      TEW->TEW_BAATD /*cBaAtd*/,;
		                      .T. /*lExibeMsg*/)
		If	lChkHrm
			
			If lOk 
				If !Empty(cAgrup)

					aAreaTEW	:= GetArea()	
					DbSelectArea("TEW")
					DbSetOrder(12)

					If TEW->(DbSeek(xFilial("TEW")+ cAgrup))
						While !TEW->(Eof()) .And. TEW->TEW_FILIAL == cFilTEW .And. TEW->TEW_KITSEQ == cAgrup
							If lTecAtf .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
								oTecProvider := TECProvider():New(TEW->TEW_BAATD,TEW->TEW_FILBAT)
								lUnic := oTecProvider:lIdUnico
								TecDestroy(oTecProvider)
								If !lUnic
									//Se for mais de um equipamento no KIT Granel.
									If TEW->TEW_QTDVEN-TEW->TEW_QTDRET > 1
										lParcKit := .T.
										Exit
									Endif
								Endif
							Endif
							
							TEW->(DbSkip())
						EndDo
	
						If lParcKit
							If MsgYesNo(STR0102)	//"Essa movimentação tem equipamentos envolvidos no KIT. Gostaria de retornar todos os equipamentos?"
								lParcKit := .F.
							Endif
						Endif

					Endif
					
					If TEW->(DbSeek(xFilial("TEW")+ cAgrup))
		
						While lOk .And. !TEW->(Eof()) .And. TEW->TEW_KITSEQ == cAgrup .And. lOk
							
							lUnic := .T.
																		
							If lParcKit
								If lTecAtf .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
									oTecProvider := TECProvider():New(TEW->TEW_BAATD,TEW->TEW_FILBAT)
									lUnic := oTecProvider:lIdUnico
									TecDestroy(oTecProvider)

									If !lUnic
										//Se for mais de um equipamento para retornar.
										If TEW->TEW_QTDVEN-TEW->TEW_QTDRET > 1													
											//Quando for Granel exibe a tela para informar a quantidade de retorno.										
											aAdd(aPrBox,{1,STR0103,TEW->TEW_QTDVEN-TEW->TEW_QTDRET,"@E 99,999,999,999","MV_PAR01 > 0","","",50,.T.}) //"Qtd. retorno"
				
											If ParamBox(aPrBox,STR0104+". "+STR0105+" - "+TEW->TEW_BAATD,@aRet,bVldBox,,,,,,,.F.)	//"Retorno de Equipamentos" ## "Base"
												nQtdRt := MV_PAR01
											Else
												cDetErro := ""
												lOk := .F.
											Endif
											aPrBox := {}
										Endif		
									Endif
								Endif								
							Endif	

							If nQtdRt <= 0
								nQtdRt := TEW->TEW_QTDVEN-TEW->TEW_QTDRET
							Endif

							If lOk .And. nQtdRt >= 1

								If lTecAtf .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
									//Realiza a inclusão da movimentação de retorno.
									oTecProvider := TECProvider():New(TEW->TEW_BAATD,TEW->TEW_FILBAT)
									lUnic := oTecProvider:lIdUnico

									If !lUnic
										DbSelectArea("TWP")
										TWP->(DbSetOrder(1))
										If TWP->(DbSeek(xFilial("TWP")+TEW->TEW_CODMV))
											oTecProvider:DeleteTWP()
										Endif
									Endif
									
									oTecProvider:InsertTWP(TEW->TEW_CODMV,,,,nQtdRt+TEW->TEW_QTDRET,.F.)
									TecDestroy(oTecProvider)				

								Endif						

								//Realiza a atualização da movimentação.
								xAux := {}
								
								If TEW->TEW_QTDVEN == (nQtdRt+TEW->TEW_QTDRET)
									aAdd( xAux, { 'TEW_DTRFIM', dDataBase } )
								Endif

								aAdd( xAux, { 'TEW_QTDRET', nQtdRt+TEW->TEW_QTDRET } )
								
								lOk := At800AtuMov( @cDetErro, xAux )
	
								If lOk
								
									xAux := {}
									cPrdAA3 := At820FilPd( TEW->TEW_PRODUT, TEW->TEW_FILIAL, TEW->TEW_FILBAT )
									If AtPosAA3( TEW->(TEW_FILBAT+TEW_BAATD), cPrdAA3) .And. AA3->AA3_MANPRE == '1'

										aAdd( xAux, { 'AA3_STATUS', AA3_MANUTENCAO } )  // Status = "Equipamento em Manutenção"
											//-------------------------------------------------
											//  Rotina para a geração de Ordem de Serviço
										lOk := lOk .And. At800AtuOs( @cDetErro, .F. /*Exclusão?*/)
									Else
										aAdd( xAux, { 'AA3_STATUS', AA3_ESTOQUE } )  // Status = "Equipamento em Estoque"
										aAdd( xAux, { "AA3_CODCLI", " " 	   } )
										aAdd( xAux, { "AA3_LOJA"  , " " 	   } )
										aAdd( xAux, { "AA3_CODLOC", " " 	   } )
										aAdd( xAux, { "AA3_INALOC", CTOD("") } )
										aAdd( xAux, { "AA3_FIALOC", CTOD("") } )
										aAdd( xAux, { "AA3_ENTEQP", CTOD("") } )
										aAdd( xAux, { "AA3_COLEQP", CTOD("") } )
									EndIf
				
									If lUnic
										lOk := lOk .And. At800Status( @cDetErro, xAux )
									Endif
									
									// verifica se o equipamento separado é de outra filial
									If TEW->TEW_FILIAL <> TEW->TEW_FILBAT
										
										DbSelectArea("TWR")
										TWR->(DbSetOrder(1)) //TWR_FILIAL+TWR_CODMOV
										
										If TWR->(DbSeek(xFilial("TWR")+TEW->TEW_CODMV))
											// Grava a quantidade de saída conforme a qtde separada no item
											Reclock("TWR",.F.)
												TWR->TWR_QTDRET := nQtdRt+TWR->TWR_QTDRET
											TWR->(MsUnlock())
										EndIf
									EndIf
									
								Endif
		
								If lOk
			
									cTxt += "<b> "+STR0072+"</b> "+At800DsInf("TFI", "TFI_CONTRT", xFilial("TFI")+TEW->TEW_CODEQU ) //"Nr. Contrato: "
									cTxt += "<b> "+STR0070+"</b> "+TEW->TEW_PRODUT //"Cod. Produto: "
									cTxt += "<b> "+STR0071+"</b> "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+"<br>" //"Descrição: "
			
									If Empty(aPlEtp)
										aPlEtp := At774PlEtp("TEW",xFilial("TFI")+TEW->TEW_CODEQU)
									Endif
			
								Endif
							Endif

							nQtdRt := 0
							TEW->(DbSkip())
						EndDo
					EndIf
	
					RestArea(aAreaTEW)
	
				Else
					If lOk					
						//Verifica se existe a integração do TEC x ATF.
						If lTecAtf .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
							oTecProvider := TECProvider():New(TEW->TEW_BAATD,TEW->TEW_FILBAT)
							lUnic := oTecProvider:lIdUnico
							If !lUnic
								//Se for mais de um equipamento.
								If TEW->TEW_QTDVEN-TEW->TEW_QTDRET > 1
									//Quando for Granel exibe a tela para informar a quantidade de retorno.
									If !MsgYesNo(STR0106)	//"Deseja retornar todos os equipamentos dessa movimentação?"
			
										aAdd(aPrBox,{1,STR0103,TEW->TEW_QTDVEN-TEW->TEW_QTDRET,"@E 99,999,999,999","MV_PAR01 > 0","","",50,.T.}) //"Qtd. retorno"
			
										If ParamBox(aPrBox,STR0104+". "+STR0105+" - "+TEW->TEW_BAATD,@aRet,bVldBox,,,,,,,.F.)	//"Retorno de Equipamentos" ## "Base"
											nQtdRt := MV_PAR01
										Else
											cDetErro := ""
											lOk := .F.
										Endif
			
										aPrBox := {}
			
									Endif
								Endif
							Endif
						Endif
											
						If nQtdRt <= 0
							nQtdRt := TEW->TEW_QTDVEN-TEW->TEW_QTDRET
						Endif
						//Realiza a atualização da movimentação.
						xAux := {}
						
						If lTecAtf .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
							//Realiza a inclusão da movimentação de retorno.
							If ValType(oTecProvider) <> "O"
								oTecProvider := TECProvider():New(TEW->TEW_BAATD,TEW->TEW_FILBAT)
								lUnic := oTecProvider:lIdUnico
							Endif

							If !lUnic
								DbSelectArea("TWP")
								TWP->(DbSetOrder(1))
								If TWP->(DbSeek(xFilial("TWP")+TEW->TEW_CODMV))
									oTecProvider:DeleteTWP()
								Endif
							Endif
							oTecProvider:InsertTWP(TEW->TEW_CODMV,,,,nQtdRt+TEW->TEW_QTDRET,.F.)
							TecDestroy(oTecProvider)				
						Endif					

						If lOk
							If TEW->TEW_QTDVEN == (nQtdRt+TEW->TEW_QTDRET)
								aAdd( xAux, { 'TEW_DTRFIM', dDataBase } )
							Endif
							
							aAdd( xAux, { 'TEW_QTDRET', nQtdRt+TEW->TEW_QTDRET } )

							//Se a base não tem Manut. Prevent. limpa o campo TEW_FECHOS
							If AA3->AA3_MANPRE == '2'
								aAdd( xAux, { 'TEW_FECHOS', CTOD('') } )
							EndIf
		
							lOk := At800AtuMov( @cDetErro, xAux )
						Endif							

						If lOk
							xAux := {}					
							cPrdAA3 := At820FilPd( TEW->TEW_PRODUT, TEW->TEW_FILIAL, TEW->TEW_FILBAT )
							
							If lGSOpTri
								lOk :=  AtPosAA3( TEW->(TEW_FILBAT+TEW_BAATD), cPrdAA3)
							Else
								DbSelectArea('AA3')
								AA3->( DbSetOrder( 6 ) ) // AA3_FILIAL+AA3_NUMSER
								lOk := AA3->( DbSeek( xFilial('AA3')+TEW->TEW_BAATD ) )
							EndIf
							
							If lOk .And. AA3->AA3_MANPRE == '1'
								aAdd( xAux, { 'AA3_STATUS', AA3_MANUTENCAO } )  // Status = "Equipamento em Manutenção"
								//-------------------------------------------------
								//  Rotina para a geração de Ordem de Serviço
								lOk := lOk .And. At800AtuOs( @cDetErro, .F. /*Exclusão?*/, nQtdRt )
							Else
								aAdd( xAux, { 'AA3_STATUS', AA3_ESTOQUE } )  // Status = "Equipamento em Estoque"
								aAdd( xAux, { "AA3_CODCLI", " " 	   } )
								aAdd( xAux, { "AA3_LOJA"  , " " 	   } )
								aAdd( xAux, { "AA3_CODLOC", " " 	   } )
								aAdd( xAux, { "AA3_INALOC", CTOD("") } )
								aAdd( xAux, { "AA3_FIALOC", CTOD("") } )
								aAdd( xAux, { "AA3_ENTEQP", CTOD("") } )
								aAdd( xAux, { "AA3_COLEQP", CTOD("") } )
							EndIf						
						Endif
	
						If lUnic
							lOk := lOk .And. At800Status( @cDetErro, xAux )
						Endif
	
						// verifica se o equipamento separado é de outra filial
						If lOk .And. TEW->TEW_FILIAL <> TEW->TEW_FILBAT
							
							DbSelectArea("TWR")
							TWR->(DbSetOrder(1)) //TWR_FILIAL+TWR_CODMOV
							
							If TWR->(DbSeek(xFilial("TWR")+TEW->TEW_CODMV))
								// Grava a quantidade de saída conforme a qtde separada no item
								Reclock("TWR",.F.)
									TWR->TWR_QTDRET := nQtdRt+TWR->TWR_QTDRET
								TWR->(MsUnlock())
							EndIf
						EndIf
						
					Endif
				EndIf
				
				If lOk
					MsgInfo(STR0062,STR0056) // 'Atualização com sucesso!' ### "Retorno de Locação"
		
				
					//Avalia se todas as separacoes foram retornadas, e se eh origem REQUISICAO para ajustar a data de termino na requisicao
					At800ReqUpd(cCodEquip,"R")
			
					If Empty(cTxt)
		
						cTxt := "<b> "+STR0072+"</b> "+At800DsInf("TFI", "TFI_CONTRT", xFilial("TFI")+TEW->TEW_CODEQU ) //"Nr. Contrato: "
						cTxt += "<b> "+STR0070+"</b> "+TEW->TEW_PRODUT //"Cod. Produto: "
						cTxt += "<b> "+STR0071+"</b> "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+"<br>" //"Descrição: "
		
						If Empty(aPlEtp)
							aPlEtp := At774PlEtp("TEW",xFilial("TFI")+TEW->TEW_CODEQU)
						Endif
		
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³SIGATEC WorkFlow # ER - Retorno de Equipamentos     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					At774Mail("TEW",TEW->TEW_ORCSER,"ER",cTxt,,,aPlEtp)
				Else
					DisarmTransaction()
					If !Empty(cDetErro)
						Help(,,'AT800RetLib',,STR0063 + CRLF + cDetErro,1,0)  // 'Atualização sem sucesso. Detalhes:'
					Endif
				EndIf
			Endif
		Else
	
			If	MsgYesNo(STR0085)	//"Deseja realizar a atualização do horimetro do equipamento neste momento?"
				If	At970AtHor("RET" /*cFase*/,;
					           cPrdAA3 /*cCodPro*/,;
					           Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC") /*cDescPro*/,;
					           TEW->TEW_BAATD /*cIDUnico*/, TEW->TEW_FILBAT )
					MsgInfo(STR0087)	//"Refaça o procedimento de solicitar o retorno da locação do equipamento."
					lExibeMsg	:= .F.
				EndIf
			EndIf
		EndIf

	End Transaction
Else
	If cExgNf=="2"
		Help(,,'AT800RetLib',,STR0064,1,0)//'Equipamento exige NF para remessa, necessário gerar o documento de saída'
	Else
		Help(,,'AT800RetLib',,STR0047,1,0)//"Não é possível realizar o retorno do equipamento"
	EndIf
EndIf
TecDestroy(oTecProvider)
RestArea(aArea)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} At800CancRet
	Valida a exclusão da nota de entrada (doc. devolução do equipamento de locação)

@sample 	At800CancRet()
@since  	10/02/2014
@version  	P12
@return 	lRet
/*/
//-------------------------------------------------------------------
Function At800CancRet()
Local aArea			:= GetArea()
Local aAreaTEW		:= {}
Local cAgrup		:= TEW->TEW_KITSEQ
Local cExgNf		:= ''
Local cCodEquip		:= TEW->TEW_CODEQU
Local lOk			:= .T.
Local xAux1			:= {}
Local xAux2			:= {}
Local cDetErro		:= ''
Local cTxt			:= ""
Local aPlEtp		:= {}
Local cFilTEW		:= xFilial("TEW")
Local lTecAtf 		:= SuperGetMv('MV_TECATF', .F.,'N') == 'S'
Local lGSOpTri		:= SuperGetMv('MV_GSOPTRI',.F.,.F.) //Parametro para ativar a operação triangular
Local oTecProvider	:= Nil
Local cCodClient 	:= ""
Local clojClient 	:= ""
Local lUnic		 	:= .T.
Local nQtdRt	 	:= 0
Local aPrBox	 	:= {}
Local aRet		 	:= {}
Local bVldBox	 	:= {|| At800VlBox("2") }
Local lParcKit		:= .F.
Local cFilBkp 		:= cFilAnt
Local cCliBase 		:= ""
Local cLojBase 		:= ""
Local lContinua 	:= .F.
Local cPrdAA3 		:= At820FilPd( TEW->TEW_PRODUT, TEW->TEW_FILIAL, TEW->TEW_FILBAT )

If lGSOpTri
	lContinua := AtPosAA3(TEW->(TEW_FILBAT+TEW_BAATD),cPrdAA3)
Else
	DbSelectArea('AA3')
	AA3->( DbSetOrder( 6 ) ) // AA3_FILIAL+AA3_NUMSER
	lContinua := AA3->( DbSeek( xFilial('AA3')+TEW->TEW_BAATD ) )
EndIf

cExgNf := AA3->AA3_EXIGNF

If lContinua .And. TEW->TEW_DTRINI <> CTOD("") .AND. (TEW->TEW_DTRFIM <> CTOD("") .OR. TEW->TEW_QTDRET > 0 ) .AND. cExgNf=="2"
	Begin Transaction
		// quando não é cancelamento de retorno de kit
		If Empty(cAgrup)
			If lTecAtf .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
				oTecProvider := TECProvider():New(TEW->TEW_BAATD,TEW->TEW_FILBAT)
				lUnic := oTecProvider:lIdUnico
				If !lUnic
					//Se for mais de um equipamento.
					If TEW->TEW_QTDVEN > 1
						//Quando for Granel exibe a tela para informar a quantidade de retorno.
						If !MsgYesNo(STR0107)	//"Deseja cancelar o retorno de todos os equipamentos dessa movimentação?"
	
							aAdd(aPrBox,{1,STR0108,TEW->TEW_QTDRET,"@E 99,999,999,999","MV_PAR01 > 0","","",50,.T.}) //"Qtd. ret. canc."
	
							If ParamBox(aPrBox,STR0109+". "+STR0110+" - "+TEW->TEW_BAATD,@aRet,bVldBox,,,,,,,.F.)	//"Cancelamento do retorno" ## "Base"
								nQtdRt := MV_PAR01
							Else
								lOk := .F.
							Endif
						Endif
					Endif
				Endif
			EndIf
			
			If lOk
				If nQtdRt <= 0
					nQtdRt := TEW->TEW_QTDRET
				Endif
			
				If lTecAtf .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
					If ValType(oTecProvider) <> "O"
						oTecProvider := TECProvider():New(TEW->TEW_BAATD)
						lUnic := oTecProvider:lIdUnico
					Endif
	
					oTecProvider:DeleteTWP(TEW->TEW_CODMV)
	
					If !lUnic .And. (TEW->TEW_QTDRET-nQtdRt) > 0
						oTecProvider:InsertTWP(TEW->TEW_CODMV,,,,(TEW->TEW_QTDRET-nQtdRt),.F.)
					Endif
	
					TecDestroy(oTecProvider)
				Endif
					
				If TEW->TEW_NUMOS <> " "
					//-------------------------------------------------
					//  Rotina para a exclusão de Ordem de Serviço
					lOk := lOk .And. At800AtuOs( @cDetErro, .T. /*Exclusão?*/)
				EndIf
				
				xAux1 := {}
				aAdd( xAux1, { 'TEW_DTRFIM', CTOD("") } )
				aAdd( xAux1, { 'TEW_QTDRET', TEW->TEW_QTDRET-nQtdRt } )
		
				xAux2 := {}
				// busca o cliente e loja e deixa a estrutura posicionada (TFJ, TFL e TFI)
				At820CliLoj( @cCodClient, @clojClient, TEW->TEW_CODEQU )
				
				aAdd( xAux2, { 'AA3_STATUS', AA3_CLIENTE } )  // atualiza o status da base de atendimento :: "Equipamento em Cliente"
				aAdd( xAux2, { 'AA3_FILLOC', TEW->TEW_FILIAL } )
				If TEW->TEW_FILIAL == TEW->TEW_FILBAT
					aAdd( xAux2, { 'AA3_CODCLI', cCodClient } )
					aAdd( xAux2, { 'AA3_LOJA'  , clojClient } )
				Else
					At800ClToOs( @cCliBase, @cLojBase )
					aAdd( xAux2, { 'AA3_CODCLI', cCliBase } )
					aAdd( xAux2, { 'AA3_LOJA'  , cLojBase } )					
				EndIf
				aAdd( xAux2, { 'AA3_CODLOC', TFI->TFI_LOCAL  } )
				aAdd( xAux2, { 'AA3_INALOC', TFI->TFI_PERINI } )
				aAdd( xAux2, { 'AA3_FIALOC', TFI->TFI_PERFIM } )
				aAdd( xAux2, { 'AA3_ENTEQP', TFI->TFI_ENTEQP } )
				aAdd( xAux2, { 'AA3_COLEQP', TFI->TFI_COLEQP } )
				
				lOk := lOk .And. Iif( lUnic , At800Status( @cDetErro, xAux2 ), .T. ) .And. At800AtuMov( @cDetErro, xAux1 )
	
				// verifica se o equipamento separado é de outra filial
				If lOk .And. TEW->TEW_FILIAL <> TEW->TEW_FILBAT
					
					DbSelectArea("TWR")
					TWR->(DbSetOrder(1)) //TWR_FILIAL+TWR_CODMOV
					
					If TWR->(DbSeek(xFilial("TWR")+TEW->TEW_CODMV))
						// Grava a quantidade de saída conforme a qtde separada no item
						Reclock("TWR",.F.)
							TWR->TWR_QTDRET := TWR->TWR_QTDRET-nQtdRt
						TWR->(MsUnlock())
					EndIf
				EndIf
	
			Endif
		Else
	
			aAreaTEW:=GetArea()
			DbSelectArea("TEW")
			DbSetOrder(12) // TEW_FILIAL + TEW_KITSEQ
	
			If TEW->(DbSeek(cFilTEW+ cAgrup))
				While !TEW->(Eof()) .And. TEW->TEW_FILIAL == cFilTEW .And. TEW->TEW_KITSEQ == cAgrup
					If lTecAtf .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
						oTecProvider := TECProvider():New(TEW->TEW_BAATD,TEW->TEW_FILBAT)
						lUnic := oTecProvider:lIdUnico
						TecDestroy(oTecProvider)
						If !lUnic
							//Se for mais de um equipamento no KIT Granel.
							If TEW->TEW_QTDRET > 1
								lParcKit := .T.
								Exit
							Endif
						Endif
					Endif
					
					TEW->(DbSkip())
				EndDo
	
				If lParcKit
					If MsgYesNo(STR0111)	//"Essa movimentação tem equipamentos envolvidos no KIT. Deseja cancelar o retorno de todos os equipamentos?"
						lParcKit := .F.
					Endif
				Endif
	
			Endif
	
			If TEW->(DbSeek(cFilTEW+ cAgrup))
	
				While TEW->(! Eof()) .And. TEW->TEW_FILIAL == cFilTEW .And. cAgrup == TEW->TEW_KITSEQ .And. lOk
					lUnic := .T.
					
					If lParcKit
						If lTecAtf .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
							oTecProvider := TECProvider():New(TEW->TEW_BAATD,TEW->TEW_FILIAL)
							lUnic := oTecProvider:lIdUnico
							TecDestroy(oTecProvider)
	
							If !lUnic
								//Se for mais de um equipamento para retornar.
								If TEW->TEW_QTDRET > 1													
									//Quando for Granel exibe a tela para informar a quantidade de cancelamento do retorno.										
									aAdd(aPrBox,{1,STR0108,TEW->TEW_QTDRET,"@E 99,999,999,999","MV_PAR01 > 0","","",50,.T.}) //"Qtd. ret. canc."
			
									If ParamBox(aPrBox,STR0109+". "+STR0110+" - "+TEW->TEW_BAATD,@aRet,bVldBox,,,,,,,.F.)	//"Cancelamento do retorno" ## "Base"
										nQtdRt := MV_PAR01
									Else
										cDetErro := ""
										lOk := .F.
									Endif
									aPrBox := {}
								Endif		
							Endif
						Endif
					Endif
					
					If nQtdRt <= 0
						nQtdRt := TEW->TEW_QTDRET
					Endif
	
					If lOk .And. nQtdRt >= 1
						If TEW->TEW_NUMOS <> " "
							
							lOk := lOk .And. At800AtuOs( @cDetErro, .T. /*Exclusão?*/)
						EndIf
						
						If lOk .And. lTecAtf .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
							oTecProvider := TECProvider():New(TEW->TEW_BAATD,TEW->TEW_FILBAT)
							lUnic := oTecProvider:lIdUnico
							oTecProvider:DeleteTWP(TEW->TEW_CODMV)
							
							If !lUnic .And. (TEW->TEW_QTDRET-nQtdRt) > 0
								oTecProvider:InsertTWP(TEW->TEW_CODMV,,,,(TEW->TEW_QTDRET-nQtdRt),.F.)
							Endif
		
							TecDestroy(oTecProvider)
						EndIf
		
						xAux1 := {}
						aAdd( xAux1, { 'TEW_DTRFIM', CTOD("") } )
						aAdd( xAux1, { 'TEW_QTDRET', TEW->TEW_QTDRET-nQtdRt } )
		
						xAux2 := {}
						// busca o cliente e loja e deixa a estrutura posicionada (TFJ, TFL e TFI)
						At820CliLoj( @cCodClient, @clojClient, TEW->TEW_CODEQU )

						aAdd( xAux2, { 'AA3_STATUS', AA3_CLIENTE } )  // Status = "Equipamento em Cliente"
						aAdd( xAux2, { 'AA3_FILLOC', TEW->TEW_FILIAL } )
						aAdd( xAux2, { 'AA3_CODCLI', cCodClient } )
						aAdd( xAux2, { 'AA3_LOJA'  , clojClient } )
						aAdd( xAux2, { 'AA3_CODLOC', TFI->TFI_LOCAL  } )
						aAdd( xAux2, { 'AA3_INALOC', TFI->TFI_PERINI } )
						aAdd( xAux2, { 'AA3_FIALOC', TFI->TFI_PERFIM } )
						aAdd( xAux2, { 'AA3_ENTEQP', TFI->TFI_ENTEQP } )
						aAdd( xAux2, { 'AA3_COLEQP', TFI->TFI_COLEQP } )
						
						cPrdAA3 := At820FilPd( TEW->TEW_PRODUT, TEW->TEW_FILIAL, TEW->TEW_FILBAT )
						
						If lGSOpTri
							lOk := lOk .And. AtPosAA3( TEW->(TEW_FILBAT+TEW_BAATD), cPrdAA3 )
						Else
							DbSelectArea('AA3')
							AA3->( DbSetOrder( 6 ) ) // AA3_FILIAL+AA3_NUMSER
							lOk := lOk .And. AA3->( DbSeek( xFilial('AA3')+TEW->TEW_BAATD ) )
						EndIf
						
						lOk := lOk .And. Iif(lUnic , At800Status( @cDetErro, xAux2 ), .T. ).And. At800AtuMov( @cDetErro, xAux1 )
		
						// verifica se o equipamento separado é de outra filial
						If lOk .And. TEW->TEW_FILIAL <> TEW->TEW_FILBAT
							
							DbSelectArea("TWR")
							TWR->(DbSetOrder(1)) //TWR_FILIAL+TWR_CODMOV
							
							If TWR->(DbSeek(xFilial("TWR")+TEW->TEW_CODMV))
								// Grava a quantidade de saída conforme a qtde separada no item
								Reclock("TWR",.F.)
									TWR->TWR_QTDRET := TWR->TWR_QTDRET-nQtdRt
								TWR->(MsUnlock())
							EndIf
						EndIf
		
						If lOk
		
							cTxt += "<b> "+STR0072+"</b> "+At800DsInf("TFI", "TFI_CONTRT", xFilial("TFI")+TEW->TEW_CODEQU ) //"Nr. Contrato: "
							cTxt += "<b> "+STR0070+"</b> "+TEW->TEW_PRODUT //"Cod. Produto: "
							cTxt += "<b> "+STR0071+"</b> "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+"<br>" //"Descrição: "
		
							If Empty(aPlEtp)
								aPlEtp := At774PlEtp("TEW",xFilial("TFI")+TEW->TEW_CODEQU)
							Endif
							
						Endif
					Endif
					nQtdRt := 0
					TEW->(DbSkip())
				EndDo
			EndIf
	
			RestArea(aAreaTEW)
		EndIf
	
		If lOk
			At800ReqUpd(cCodEquip,"E")
			If Empty(cTxt)
		
				cTxt := "<b> "+STR0072+"</b> "+At800DsInf("TFI", "TFI_CONTRT", xFilial("TFI")+TEW->TEW_CODEQU ) //"Nr. Contrato: "
				cTxt += "<b> "+STR0070+"</b> "+TEW->TEW_PRODUT //"Cod. Produto: "
				cTxt += "<b> "+STR0071+"</b> "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+"<br>"  //"Descrição: "
		
				If Empty(aPlEtp)
					aPlEtp := At774PlEtp("TEW",xFilial("TFI")+TEW->TEW_CODEQU)
				Endif
		
			Endif
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SIGATEC WorkFlow # ER - Cancelamento no Retorno de Equipamentos     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			At774Mail("TEW",TEW->TEW_ORCSER,"ER",cTxt,"RED",STR0073,aPlEtp) //"Cancelamento"
			
			MsgInfo(STR0100,STR0109) // "Atualização finalizada!" ### "Cancelamento de retorno"
		Else
			DisarmTransaction()
			If !Empty(cDetErro)
				Help(,,'AT800CancRet',,STR0063 + CRLF + cDetErro,1,0)  // 'Atualização sem sucesso. Detalhes:'
			Endif
		Endif
	End Transaction
Else
	If cExgNf == "1"
		Help(,,'AT800CancRet',,STR0065,1,0)// "Equipamento possui remessa por NF não pode ter seu retorno cancelado."
	Else
		Help(,,'AT800CancRet',,STR0048,1,0)// "Não é possível cancelar o retorno!"
	EndIf
EndIf
TecDestroy(oTecProvider)
RestArea(aArea)
Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} At800DsInf

Preenchimento dos campos virtuais (multiplas chamadas)

@sample 	At800DsInf("SA1","A1_NOME",xFilial("SA1")+M->TEW_CODCLI)
@return	ExpC	cRet - conteudo do campo descritivo informado via parametro

@since		01/05/2015
@author	Serviços
@version	P12
/*/
//------------------------------------------------------------------------------//
Function At800DsInf(cTabelaAlvo,cCampoRetorno,cChavePesq)
Local cRet 		:= ""
Local aArea		:= GetArea()

If cTabelaAlvo $ "SB1"
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(cChavePesq))
		cRet := SB1->&(cCampoRetorno)
	EndIf

ElseIf cTabelaAlvo $ "TFI|ABS|TGQ|AA1"
	dbSelectArea("TFI")
	TFI->(dbSetOrder(1))
	If	TFI->(dbSeek(cChavePesq))
		If cTabelaAlvo == "TFI"
			cRet := TFI->&(cCampoRetorno)
		ElseIf cTabelaAlvo == "ABS"
			dbSelectArea("ABS")
			ABS->(dbSetOrder(1))
			If ABS->(dbSeek(xFilial("ABS")+TFI->TFI_LOCAL ))
				cRet := ABS->&(cCampoRetorno)
			EndIf
		ElseIf cTabelaAlvo $ "TGQ|AA1"
			dbSelectArea("TGQ")
			TGQ->(dbSetOrder(1))
			If TGQ->(dbSeek(xFilial("TGQ")+TFI->TFI_CODTGQ))
				If cTabelaAlvo == "TGQ"
					cRet := TGQ->&(cCampoRetorno)
				Else
					dbSelectArea("AA1")
					AA1->(dbSetOrder(1))
					If AA1->(dbSeek(xFilial("AA1")+TGQ->TGQ_CODATE))
						cRet := AA1->&(cCampoRetorno)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf cTabelaAlvo $ "TFJ|SA1"
	dbSelectArea("TFJ")
	TFJ->(dbSetOrder(1))
	If	TFJ->(dbSeek(cChavePesq))
		If cTabelaAlvo == "TFJ"
			cRet := TFJ->&(cCampoRetorno)
		Else
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+TFJ->TFJ_CODENT+TFJ->TFJ_LOJA ))
				cRet := SA1->&(cCampoRetorno)
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return(cRet)
//-----------------------------------------------------------------------

//------------------------------------------------------------------------------
/*/{Protheus.doc} TableAttDef()
Rotina cria o objeto de widget da visao e grafico padrao do browse

@since 16/05/2015
@version 1.0
@return ExpO oTableAtt - Objeto com o widget contendo a visao e o grafico padrao do browse
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()
Local oBrwLocView := Nil
Local oBrwLocGrf  := Nil
Local oTableAtt   := FWTableAtt():New()

oTableAtt:SetAlias("TEW")

oBrwLocView := FWDSView():New()
oBrwLocView:SetId("VIS001")
oBrwLocView:SetName(STR0059) // "Equipamentos em Alocação"
oBrwLocView:SetPublic(.T.)
oBrwLocView:SetCollumns({"TEW_BAATD","TEW_LOCAL","TEW_CONTRT","TEW_CODEQU","TEW_DTRINI"})
oBrwLocView:AddFilterRelation("TFI","TFI_COD","TEW_CODEQU")
oBrwLocView:SetOrder(1)
oBrwLocView:AddFilter(STR0059,"TEW->TEW_DTRINI <> CTOD('') .And. TEW->TEW_DTRFIM == CTOD('')") // "Equipamentos em Alocação"
oTableAtt:AddView(oBrwLocView)

oBrwLocGrf := FWDSChart():New()
oBrwLocGrf:SetID("GRF001")
oBrwLocGrf:SetName(STR0060) //'Equipamentos por Contrato'
oBrwLocGrf:SetTitle(STR0060) //'Equipamentos por Contrato'
oBrwLocGrf:SetPublic(.T.)
oBrwLocGrf:SetSeries({{"TEW","TEW_BAATD","COUNT"}})
oBrwLocGrf:SetCategory({{"TFJ","TFJ_CONTRT"}})
oBrwLocGrf:SetType("BARCHART")
oBrwLocGrf:SetLegend(CONTROL_ALIGN_LEFT)
oBrwLocGrf:SetTitleAlign(CONTROL_ALIGN_TOP)
oBrwLocGrf:SetPicture("999,999,999.99")
oTableAtt:AddChart(oBrwLocGrf)

Return(oTableAtt)
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
/*/{Protheus.doc} At800ReqUpd

Avalia se é um encerramento (retorno de locação) de equipamentos de requisição ou
estorno do processo, para atualizar a requisição e os itens.

@since		27/05/2015
@author	Serviços
@version	P12
/*/
//------------------------------------------------------------------------------//
Static Function At800ReqUpd(cCodEquip,cTipoAcao)
Local cAliasTFI := GetNextAlias()
Local cQueryTFI := ""
Local cCodReq 	:= ""

//Retorno de locacao, ira atualizar os itens da requisicao com a data de retorno e a situacao como FINALIZADA
If cTipoAcao == "R"
	cQueryTFI := "SELECT TGR.TGR_CODTGQ, TGR.TGR_ITEM "
	cQueryTFI += "FROM " + RetSQLName("TFI") + " TFI, " + RetSQLName("TGR") + " TGR "
	cQueryTFI += "WHERE TFI.TFI_FILIAL = '" + xFilial("TFI") + "' AND TFI.TFI_COD = '" + cCodEquip + "' AND TFI.D_E_L_E_T_ = ' ' AND "
	cQueryTFI += 		"TFI.TFI_CODTGQ <> ' ' AND TFI.TFI_ITTGR <> ' ' AND "
	cQueryTFI += 		"TGR.TGR_FILIAL = '" + xFilial("TGR") + "' AND TGR.TGR_CODTGQ = TFI.TFI_CODTGQ AND TGR.TGR_ITEM = TFI.TFI_ITTGR AND TGR.D_E_L_E_T_ = ' ' AND "
	cQueryTFI += 		"TGR.TGR_DTFIM = ' ' AND "
	cQueryTFI += 		"( SELECT COUNT(*) "
	cQueryTFI += 		"FROM " + RetSQLName("TEW") + " TEW "
	cQueryTFI += 		"WHERE TEW.TEW_FILIAL = '" + xFilial("TEW") + "' AND TEW.TEW_CODEQU = TFI.TFI_COD AND TEW.TEW_DTRFIM = ' ' ) = 0 "
	cQueryTFI := ChangeQuery(cQueryTFI)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryTFI),cAliasTFI,.T.,.T.)

	If (cAliasTFI)->(! Eof())
		cCodReq := (cAliasTFI)->TGR_CODTGQ
		While (cAliasTFI)->(! Eof())
			dbSelectArea("TGR")
			TGR->(dbSetOrder(1))
			If TGR->(dbSeek(xFilial("TGR")+(cAliasTFI)->TGR_CODTGQ+(cAliasTFI)->TGR_ITEM )) .And. Empty(TGR->TGR_DTFIM)
				TGR->(RecLock("TGR",.F.))
					TGR->TGR_DTFIM	:= dDataBase
				TGR->(MsUnlock())
			EndIf

			(cAliasTFI)->(dbSkip())
		EndDo

		//Atualiza a requisicao como FINALIZADO
		dbSelectArea("TGQ")
		TGQ->(dbSetOrder(1))
		If TGQ->(dbSeek(xFilial("TGQ")+cCodReq ))
			TGQ->(RecLock("TGQ",.F.))
				TGQ->TGQ_SITUAC	:= "4" //Finalizado
			TGQ->(MsUnlock())
		EndIf
	EndIf

//Estorno do retorno, volta o status da requisicao para APROVADO
ElseIf cTipoAcao == "E"
	dbSelectArea("TFI")
	TFI->(dbSetOrder(1))
	If TFI->(dbSeek(xFilial("TFI")+cCodEquip ))
		dbSelectArea("TGQ")
		TGQ->(dbSetOrder(1))
		If TGQ->(dbSeek(xFilial("TGQ")+TFI->TFI_CODTGQ ))
			TGQ->(RecLock("TGQ",.F.))
				TGQ->TGQ_SITUAC := "3" //Aprovado
			TGQ->(MsUnlock())
		EndIf
	EndIf
EndIf

Return(Nil)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At800VldOs
	Função para validar o conteúdo nos campos TEW_NUMOS e TEW_ITEMOS na rotina de movimentação dos equipamentos.

@since		18/02/2016
@version	P12
@param  	cPar01, Caracter, Indica qual o campo está sendo validado pelo sistema
@return 	lRet, Lógico, Indica se o conteúdo está ok ou não.
/*/
//------------------------------------------------------------------------------
Function At800VldOs( cFldVld )

Local lOk := .T.
Local lIntTecMnt := ExistFunc('At040ImpST9') .And. ExistFunc('At800OsxTec') .And. (TEW->( ColumnPos('TEW_TPOS')) > 0 ) .And. (AA3->(ColumnPos('AA3_CODBEM')) > 0)
Local lGSOpTri		:= SuperGetMv('MV_GSOPTRI',.F.,.F.) //Parametro para ativar a operação triangular
Local lSeekOS		:= .F.

If lIntTecMnt .And. FwFldGet("TEW_TPOS") == "2"
	If cFldVld == "TEW_NUMOS"
		DbSelectArea("STJ")
		STJ->( DbSetOrder( 1 ) ) //TJ_FILIAL+TJ_ORDEM+TJ_PLANO+TJ_TIPOOS+TJ_CODBEM+TJ_SERVICO+TJ_SEQRELA
		lOk := ( STJ->( DbSeek( xFilial("STJ",FwFldGet("TEW_FILBAT"))+FwFldGet(cFldVld) ) ) )
	ElseIf cFldVld == "TEW_ITEMOS"
		lOk := .T. // aceita qualquer conteúdo para a OS do MNT
	EndIf
Else
	If cFldVld == "TEW_NUMOS"
		DbSelectArea("AB6")
		AB6->( DbSetOrder( 1 ) ) //AB6_FILIAL+AB6_NUMOS
		If lGSOpTri
			lOk := ( AB6->( DbSeek( xFilial("AB6",FwFldGet("TEW_FILBAT"))+FwFldGet(cFldVld) ) ) )
		Else
			lOk := ( AB6->( DbSeek( xFilial("AB6",FwFldGet("TEW_FILIAL"))+FwFldGet(cFldVld) ) ) )
		EndIf
	ElseIf cFldVld == "TEW_ITEMOS"
		DbSelectArea("AB7")
		AB7->( DbSetOrder( 1 ) ) //AB7_FILIAL+AB7_NUMOS+AB7_ITEM
		If lGSOpTri
			lOk := (AB7->( DbSeek( xFilial("AB7",FwFldGet("TEW_FILBAT"))+FwFldGet("TEW_NUMOS")+FwFldGet(cFldVld) ) ) )
		Else
			lOk := (AB7->( DbSeek( xFilial("AB7",FwFldGet("TEW_FILIAL"))+FwFldGet("TEW_NUMOS")+FwFldGet(cFldVld) ) ) )
	EndIf
	EndIf
EndIf

If !lOk
	Help(,, "AT800VLDOS",,STR0112,1,0,,,,,,;	//"Número da Ordem de Serviço não encontrado."
		{STR0113})	//"Informe um número de ordem de serviço válido nos módulos de Gestão de Serviços (SIGATEC) ou Manutenção de Ativos (SIGAMNT)."
EndIf

Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} At800OsxTec
	Pesquisa, posiciona e atualiza a alocação do equipamento

@since		19/02/2016
@version	P12
@param 		lExclusao, Lógico, define se a operação em execução na OS é uma exclusão (cancelamento da OS) ou finalização dela
/*/
//------------------------------------------------------------------------------
Function At800OsxTec( lExclusao, lGravaCusto )

Local dDtFim := CTOD("")
Local lIntTecMnt := ExistFunc('At040ImpST9') .And. ExistFunc('At800OsxTec') .And. (TEW->( ColumnPos('TEW_TPOS')) > 0 ) .And. (AA3->(ColumnPos('AA3_CODBEM')) > 0)
Local aArea := GetArea()
Local aAreaTEW := TEW->(GetArea())
Local oTecProv := Nil
Local lExclOk  := .F.	 
Local cLocal	:= ""
Local cCodTWZ 	:= ""
Local nCustoAtual 	:= 0
Local nCusto 	:= 0

Default lExclusao 	:= .F.
Default lGravaCusto	:= .F.

DbSelectArea("TEW")
TEW->( DbSetOrder( 9 )) //TEW_FILIAL+TEW_NUMOS+TEW_ITEMOS+TEW_TPOS

If lIntTecMnt .And. ;
	Select("STJ") > 0 .And. ;
	TEW->( DbSeek( xFilial("TEW")+STJ->TJ_ORDEM+Space(TamSx3("TEW_ITEMOS")[1])+"2" ) )

	dDtFim := If( Empty(STJ->TJ_DTMRFIM), dDatabase, STJ->TJ_DTMRFIM )

	If lExclusao
		At800HasMov( .T., TEW->(Recno()), .T. )
	EndIf
	lExclOk := At800FechOs( lExclusao, dDtFim )
	
	//Desbloqueia base da TWU
	If lExclOk
		oTecProv := TECProvider():New(TEW->TEW_BAATD)
		If oTecProv:lValido
			oTecProv:UpdateTWU(TEW->TEW_CODMV,TEW->TEW_QTDRET)
		EndIf
		TecDestroy(oTecProv)
	EndIf
	
	If lGravaCusto
		cCodTWZ := At800HasTWZ( TEW->TEW_CODEQU, TEW->TEW_ORCSER, @nCustoAtual )
		cLocal := At800RecTFI( TEW->TEW_CODEQU )
		nCusto := (STJ->TJ_CUSTMDO + STJ->TJ_CUSTMAT + STJ->TJ_CUSTMAA + STJ->TJ_CUSTMAS + STJ->TJ_CUSTTER)
		// não existe o custo lançado e irá criar a linha para o registro de custo
		If Empty( cCodTWZ )
			At995Custo(TEW->TEW_ORCSER, TEW->TEW_CODEQU, cLocal, TEW->TEW_PRODUT, "4", nCusto, "SIGAMNT")	
		Else
			// soma ou subtrai o custo atual conforme a operação em andamento
			nCusto := If( lExclusao, ( nCustoAtual - nCusto ), ( nCustoAtual + nCusto ) )
			If lExclusao .And. ( nCusto == 0 )
				// caso esteja removendo o custo completamente
				At995ExcC( TEW->TEW_ORCSER, cCodTWZ, .T.)
			Else
				// caso esteja somente atualizando / reduzindo ou aumentando o custo
				At995AtCus( TEW->TEW_ORCSER, cCodTWZ, {{"TWZ_VLCUST", nCusto }}, .T. )
			EndIf
		EndIf
	EndIf
	
EndIf

RestArea(aAreaTEW)
RestArea(aArea)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At800MntCli
	Atualiza as informações do cliente que o equipamento está alocado. Espera que o registro da base de atendimento já tenha sido atualizado.

@since		24/02/2016
@version	P12
/*/
//------------------------------------------------------------------------------
Function At800MntCli()

Local oMdlBem := Nil
Local lOk := .T.
Local lIntTecMnt := ExistFunc('At040ImpST9') .And. ExistFunc('At800OsxTec') .And. (TEW->( ColumnPos('TEW_TPOS')) > 0 ) .And. (AA3->(ColumnPos('AA3_CODBEM')) > 0)
Local aAreaAA3 := AA3->( GetArea() )
DbSelectArea("ST9")
ST9->( DbSetOrder(1)) //T9_FILIAL+T9_CODBEM

If lIntTecMnt .And. ST9->(DbSeek(AA3->(AA3_CDBMFL+AA3_CODBEM)))

	oMdlBem := FwLoadModel("MNTA080")
	oMdlBem:SetOperation(MODEL_OPERATION_UPDATE)
	lOk := oMdlBem:Activate()
	lOk := lOk .And. oMdlBem:GetModel("MNTA080_ST9"):SetValue('T9_CLIENTE', AA3->AA3_CODCLI)
	If !Empty(AA3->AA3_LOJA)
		lOk := lOk .And. oMdlBem:GetModel("MNTA080_ST9"):SetValue('T9_LOJACLI', AA3->AA3_LOJA)
	EndIf
	lOk := lOk .And. oMdlBem:GetModel("MNTA080_ST9"):SetValue('T9_INSTALA', If(Empty(AA3->AA3_CODCLI),"1","2"))

	lOk := lOk .And. oMdlBem:VldData() .And. oMdlBem:CommitData()

	If oMdlBem:lActivate
		oMdlBem:DeActivate()
	EndIf
	oMdlBem:Destroy()
	oMdlBem := Nil
EndIf
RestArea(aAreaAA3)
Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} At800LegRe()

	Função para avaliar a regra da legenda e preencher o novo campo com a informação

@since		18/02/2016
@version	P12
@return 	cRet, Caracter, Indica qual situação da legenda.
/*/
//------------------------------------------------------------------------------
Function At800LegRe()
Local aArea		:= GetArea()
Local cRet := ""

If TEW->TEW_DTSEPA == CTOD('')
	cRet := STR0036	//"Equipamento não separado"
ElseIf TEW->TEW_DTSEPA <> CTOD('') .And. TEW->TEW_DTRINI == CTOD('')
	cRet := STR0037	//"Separado"
ElseIf TEW->TEW_MOTIVO <> '1' .And. TEW->TEW_MOTIVO <>'2' .And. TEW->TEW_QTDRET == 0 .And. TEW->TEW_DTRINI <> CTOD('') .And. TEW->TEW_DTRFIM == CTOD('')
	cRet := STR0038	//"Alocado"
Elseif TEW->TEW_MOTIVO==' ' .And. TEW->TEW_QTDVEN > TEW->TEW_QTDRET .And. ( ( Empty(TEW->TEW_NUMOS) ) .Or.;
		 (!Empty(TEW->TEW_NUMOS) .And. TEW->TEW_FECHOS <> CTOD('')) )
	cRet := STR0114	//"Parcialmente devolvido"
ElseIf TEW->TEW_MOTIVO==' ' .And. (( Empty(TEW->TEW_NUMOS)) .Or. (TEW->TEW_DTRFIM <> CTOD('') .And.;
		!Empty(TEW->TEW_NUMOS) .And. TEW->TEW_FECHOS <> CTOD('')))
	cRet := STR0039	//"Devolvido"
ElseIf TEW->TEW_DTRFIM <> CTOD('') .And. !Empty(TEW->TEW_NUMOS) .And. TEW->TEW_FECHOS == CTOD('')
	cRet := STR0040	//"Devolvido e Em manutenção"
ElseIf TEW->TEW_MOTIVO=='1' .And. TEW->TEW_DTRFIM == CTOD('')
	cRet := STR0041	//"Substituído e Não devolvido"
ElseIf TEW->TEW_MOTIVO=='2' .And. TEW->TEW_DTRFIM == CTOD('')
	cRet := STR0042	//"Cancelado e Não devolvido"
ElseIf TEW->TEW_MOTIVO=='1' .And. TEW->TEW_DTRFIM <> CTOD('')
	cRet := STR0043	//"Substituído e Devolvido"
ElseIf TEW->TEW_MOTIVO=='2' .And. TEW->TEW_DTRFIM <> CTOD('')
	cRet := STR0044	//"Cancelado e Devolvido"
EndIf

RestArea(aArea)

Return cRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At800QryOs()
Função responsável por retornar o Recno do Item do Orçamento de Serviço - AB7.

@since 31/03/2016
@version 1.0
@return Recno, da tabela AB7.
/*/
//------------------------------------------------------------------------------
Static Function At800QryOs(cCOrc, cItOrc, cTip, cFilEquip, cFilTEW, cCodTEW )

Local aOldArea	:= GetArea()
Local cAtprPos	:= SuperGetMv("MV_ATPRPOS", , "2")
Local cNewAlias	:= ""
Local cWhere		:= ""
Local nPos			:= 0
Local aRet			:= {}
Local cFilOS 		:= ""

Default cCOrc  	:= ""
Default cItOrc 	:= ""
Default cTip		:= "1"
Default cFilEquip := cFilAnt

cFilOS := xFilial("AB6",cFilEquip)

If !Empty(cCOrc) .AND. !Empty(cItOrc) .AND. !Empty(cTip)

	cWhere := "AB6.AB6_ITORCS = " + If(cAtprPos == "1", "' '", "'" + cItOrc + "'")
	cWhere	:= '%' + cWhere + '%'

	cNewAlias := GetNextAlias()
	BeginSql Alias cNewAlias
		SELECT AB6.R_E_C_N_O_ RECAB6, AB7.R_E_C_N_O_ RECAB7
		  FROM %Table:AB7% AB7
		       INNER JOIN %Table:AB6% AB6 ON AB6.AB6_FILIAL = %Exp:cFilOS%
		                                 AND AB6.%NotDel%
		                                 AND AB6.AB6_NUMOS = AB7.AB7_NUMOS
				INNER JOIN %Table:TEW% TEW ON TEW_FILIAL = %Exp:cFilTEW%
					AND TEW.TEW_CODMV = %Exp:cCodTEW%
					AND TEW.TEW_CODEQU = %Exp:cItOrc%
					AND TEW.TEW_BAATD = AB7.AB7_NUMSER
					AND TEW.%NotDel%
		 WHERE AB7.AB7_FILIAL = %Exp:cFilOS%
		   AND AB7.%NotDel%
		   AND AB7.AB7_TIPO = %Exp:cTip%
		   AND AB6.AB6_CDORCS = %Exp:cCOrc%
		   AND %Exp:cWhere%
		 ORDER BY AB6.R_E_C_N_O_, AB7.R_E_C_N_O_
	EndSql

	While (cNewAlias)->(! Eof())
		If	( nPos := aScan(aRet,{|x| x[01] == (cNewAlias)->(RECAB6)}) ) == 0
			aAdd(aRet,{(cNewAlias)->(RECAB6),{}})
			nPos	:= Len(aRet)
		EndIf
		aAdd(aRet[nPos][02],(cNewAlias)->RECAB7)
		(cNewAlias)->(DbSkip())
	EndDo

	(cNewAlias)->(dbCloseArea())
Endif

RestArea(aOldArea)
Return aRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} A800ConfEC()
Chamada da interface da confirmação de entrega e coleta

@since 31/03/2016
@version 1.0
/*/
//------------------------------------------------------------------------------
Function A800ConfEC()
Local lRet := .F.
Local aArea := GetArea()

TFJ->( DbSetOrder( 1 ) ) // TFJ_FILIAL+TFJ_CODIGO
If TFJ->( DbSeek( xFilial("TFJ")+TEW->TEW_ORCSER))
	If TFJ->TFJ_STATUS == "5" .OR. TFJ->TFJ_STATUS == "6"//Cancelado ## Encerrado
		Help(,, "At870Conf",,STR0115,1,0,,,,,,{STR0116 +CRLF+STR0117+CRLF+STR0118+CRLF+STR0119+CRLF+STR0120+CRLF+STR0121})// "Não é permetido realizar a confirmação de entrega/coleta." ## "Os status permitidos são:" ## "Ativo" ## "Revisado" ## "Em revisão" ## "Aguardando aprovação" ## "Contrato em elaboração"	
	Else
		TECA743(TEW->TEW_PRODUT)
	EndIf																																													
EndIf	
RestArea(aArea)
Return

/*/{Protheus.doc} At800InfByPV()
	Retorna o conteúdo do cadastro de cliente a partir do cliente associado ao pedido de venda

@since 10/08/16
@author Inovação Gestão de Serviços
@param 		cTabCpo, Caracter, determina qual a tabela deverá ter o conteúdo retornado
@param 		cCpoRet, Caracter, campo para retorno do conteúdo
@param 		cKey, Caracter, chave para pesquisa do conteúdo
@param 		lCliPrinc, Lógico, define se as informações do cliente a serem retornadas é do principal do pedido ou de entrega
/*/
Function At800InfByPV( cTabCpo, cCpoRet, cKey, lCliPrinc )

Local cContRet := ""

Default lCliPrinc := .T.

DbSelectArea("SC5")
SC5->( DbSetOrder( 1 ) ) // C5_FILIAL+C5_NUM

If SC5->( DbSeek( cKey ) )
	
	If cTabCpo == "SA1"
		
		If lCliPrinc
			cContRet := Posicione( cTabCpo, 1, xFilial("SA1",SC5->C5_FILIAL)+SC5->C5_CLIENTE+SC5->C5_LOJACLI, cCpoRet )
		Else
			cContRet := Posicione( cTabCpo, 1, xFilial("SA1",SC5->C5_FILIAL)+SC5->C5_CLIENT+SC5->C5_LOJAENT, cCpoRet )
		EndIf
	EndIf
	
EndIf

Return cContRet

/*/{Protheus.doc} At800IsPvAdc()
	Pesquisa se o pedido sendo excluído é um pedido adicional do processo de Operação Triangular
@since  	31/08/16
@author 	Inovação Gestão de Serviços
@param 		cPedFil, Caracter, indica qual a filial do Pedido de Venda
@param 		cPedNum, Caracter, indica qual o número do Pedido de Venda
@return 	lRet, Lógico, determina se encontrou ou não a filial, número e item do pedido de venda
/*/
Function At800IsPvAdc( cPedFil, cPedNum )

Local lRet := .F.
Local cQryAlias := GetNextAlias()

BeginSql Alias cQryAlias
	SELECT TWR.TWR_CODMOV 
	FROM %Table:TWR% TWR
	WHERE TWR.TWR_FILPED = %Exp:cPedFil%
		AND TWR.TWR_NUMPED = %Exp:cPedNum%
		AND TWR.%NotDel%
EndSql

lRet := (cQryAlias)->(!EOF())

(cQryAlias)->(DbCloseArea())

Return lRet

/*/{Protheus.doc} At800SepCan()
	Desfaz o processo de separação de equipamento cancelando todas as entidades geradas e atualizadas:
		Base de Atendimento, Movimentação, Pedidos de Remessa e adicionais, OS de montagem
@since  	10/08/16
@author 	Inovação Gestão de Serviços
@param 		cTabCpo, Caracter, tabela utilizada no browse
@param 		nOpc, Numérico, número da opção selecionada no menu
@param 		nRecno, Numérico, RECNO do registro posicionado no acionamento da rotina
/*/
Function At800SepCan(cTab, nOpc, nRecno, lAutomato)
Local lIsKit			:= !Empty(TEW->TEW_CODKIT) .And. !Empty(TEW->TEW_KITSEQ)
Local lExcPed			:= !Empty(TEW->TEW_NUMPED)
Local lNaoSep			:= Empty(TEW->TEW_DTSEPA) .Or. Empty(TEW->TEW_FILBAT) .Or. Empty(TEW->TEW_BAATD)
Local lAloc			:= !Empty( TEW->TEW_DTRINI )
Local lContinua		:= .T.
Local cKitSeq			:= TEW->TEW_KITSEQ
Local aNumPed			:= {}
Local aCodMvs			:= {}
Local nX				:= 0
Local cFilOrig		:= ""
Local cFilTEW			:= TEW->TEW_FILIAL
Local cFilTWR			:= ""
Local xAux				:= {}
Local cMsgConfirm		:= ""
Local aArea			:= GetArea()
Local lIntTecMnt		:= ExistFunc('At040ImpST9') .And. ExistFunc('At800OsxTec') .And. (TEW->( ColumnPos('TEW_TPOS')) > 0 ) .And. (AA3->(ColumnPos('AA3_CODBEM')) > 0)
Local cCodClient		:= ""
Local cLojClient		:= ""
Local aVerifOS		:= {}
Local aRecOS			:= {}
Local aCabOs			:= {}
Local aAuxItens		:= {}
Local aItensOs		:= {}
Local nOpcX			:= 4
Local cTxt				:= ""
Local aPlEtp			:= {}
Local oTecProvider	:= Nil
Local lTecAtf			:= SuperGetMv('MV_TECATF', .F.,'N') == 'S'
Local lGSOpTri		:= SuperGetMv('MV_GSOPTRI',.F.,.F.) //Parametro para ativar a operação triangular
Local aSeqs			:= {}
Local aMailInfo		:= {}
Local nItMail			:= 0
Local aReservs		:= {}
Local oMdlReserv		:= Nil
Local oMdlGrid		:= Nil
Local nLin				:= 0
Local cMsgErro		:= ""
Local cCodLoc			:= TEW->TEW_CODEQU
Local cIdUnic			:= TEW->TEW_BAATD
Local nQtdVend		:= TEW->TEW_QTDVEN
Local oMdlMov			:= Nil
Local cMsg				:= ""
Local nPosOS			:= 0
Local nPosOSItem		:= 0
Local aAreaTEW 			:= {}
Local lUnic				:= .T.
Local cFilBkp 			:= cFilAnt
Local cAliasQry 		:= ""
Local nNewSaldo 		:= 0
Local cPrdAA3 			:= ""
Local aAreaTFJ			:= {}
Local aAreaTFI			:= {}
Local lAtuSlq			:= .T. //Atualiza saldo

Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .F.

Default lAutomato := .F.

If lNaoSep 
	lContinua := .F.
	MsgAlert( STR0122+CRLF+;	//"Equipamento não está separado para esta movimentação."
				STR0123, "AT800SEPCAN01" )	//"Verifique o registro selecionado."
ElseIf lAloc 
	lContinua := .F.
	MsgAlert( STR0124+CRLF+;	//"Equipamento já está alocado. Não é possível desfazer a sua separação."
				STR0125, "AT800SEPCAN02" )	//"Cancele a liberação da locação ou estorne o documento de saída para depois cancelar a separação."

ElseIf At800IsSub( TEW->TEW_CODMV )
	lContinua := .F.
	MsgAlert( STR0145, "AT800SEPCAN06" )  // "Não é possível desfazer a separação deste equipamento, pois essa separação surgiu de uma substituição"
Else

	If lIsKit
		TEW->( DbSetOrder( 12 ) ) // TEW_FILIAL+TEW_KITSEQ
		//Posiciona na primeira movimentação do KIT.
		If TEW->(DbSeek(xFilial("TEW")+TEW->TEW_KITSEQ))
		// pega todos os números de pedidos que precisam sofrer a exclusão
		// pega todos os códigos de movimentos que precisam ser excluídos
		While TEW->(!EOF()) .And. TEW->TEW_FILIAL = cFilTEW .And. TEW->TEW_KITSEQ == cKitSeq
			// adiciona o código do movimento
			aAdd( aCodMvs, TEW->(Recno()) )
			
			// verifica se o pedido já está na lista dos pedidos a serem excluídos
			If !Empty( TEW->TEW_NUMPED ) .And. (aScan( aNumPed, {|x| x[1]==TEW->TEW_FILIAL .And. x[2]==TEW->TEW_NUMPED} ) == 0 )
				lExcPed := .T.
				aAdd( aNumPed, { TEW->TEW_FILIAL, TEW->TEW_NUMPED, TEW_ITEMPV, TEW_FILBAT, TEW_BAATD } )
			EndIf
			
			TEW->( DbSkip() )
		End
		Endif
	Else
		// adiciona no o movimento que deverá ter os campos TEW_FILBAT, TEW_BAATD e TEW_DTSEPA limpados
		aAdd( aCodMvs, TEW->(Recno()) )
		
		// verifica se o pedido já está na lista dos pedidos a serem excluídos
		If !Empty( TEW->TEW_NUMPED ) .And. (aScan( aNumPed, {|x| x[1]==TEW->TEW_FILIAL .And. x[2]==TEW->TEW_NUMPED} ) == 0 )
			lExcPed := .T.
			aAdd( aNumPed, { TEW->TEW_FILIAL, TEW->TEW_NUMPED, TEW_ITEMPV, TEW_FILBAT, TEW_BAATD } )
		EndIf
		
	EndIf

	//-------------------------------------------------
	//   Reordena a TEW pelo número do Pedido para identificar outros movimentos que estejam 
	// associados pelo Pedido e que deverão ser cancelados também, pois a remessa dele deve ser estornada
	TEW->( DbSetOrder( 4 ) )  // TEW_FILIAL+TEW_NUMPED+TEW_ITEMPV
	
	For nX := 1 To Len(aNumPed)
		
		TEW->( DbSeek(aNumPed[nX,1]+aNumPed[nX,2]) )
		
		While TEW->(!EOF()) .And. ;
				TEW->TEW_FILIAL == aNumPed[nX,1] .And. ;
				TEW->TEW_NUMPED == aNumPed[nX,2]
			
			// procura pelo item do pedido no array de pedidos
			// caso não encontre, adiciona o pedido para a exclusão  
			// e adiciona o movimento para verificação dos pedidos adicionais para movimentação
			If ( aScan( aNumPed, {|x| x[1]==TEW->TEW_FILIAL .And. ;
										x[2]==TEW->TEW_NUMPED .And. ;
										x[3]==TEW->TEW_ITEMPV } ) ) == 0
				
				aAdd( aNumPed, { TEW->TEW_FILIAL, TEW->TEW_NUMPED, TEW_ITEMPV, TEW_FILBAT, TEW_BAATD } )
				If aScan( aCodMvs, TEW->(Recno()) ) == 0
					aAdd( aCodMvs, TEW->(Recno()) )
				EndIf
			EndIf
			
			TEW->(DbSkip())
		End
		
	Next nX
	
	DbSelectArea( "TWR" )
	TWR->(DbSetOrder( 1 ))  // TWR_FILIAL+TWR_CODMOV

	TEW->( DbSetOrder( 1 ) ) // TEW_FILIAL+TEW_CODMV
	
	// procura por pedidos adicionais gerados em outras filiais para a movimentação dos equipamentos
	For nX := 1 To Len( aCodMvs )
		// posiciona no registro da TEW novamente
		TEW->( DbGoTo( aCodMvs[nX] ) )
		

		
		If ( TWR->( DbSeek( xFilial("TWR",TEW->TEW_FILIAL)+TEW->TEW_CODMV ) ) )
			
			cFilTWR := TWR->TWR_FILIAL
			// itera pelos registros na tabela de pedidos adicionais da movimentação
			While TWR->(!EOF()) .And. TWR->TWR_FILIAL == cFilTWR .And. TWR->TWR_CODMOV == TEW->TEW_CODMV
				// adiciona ao array para exclusão dos pedidos associados com a remessa dos equipamentos
				aAdd( aNumPed, { TWR->TWR_FILPED, TWR->TWR_NUMPED, TEW->TEW_ITEMPV, TEW->TEW_FILBAT, TEW->TEW_BAATD } )
				TWR->( DbSkip() )
			End
		EndIf
		
			aAreaTFJ := TFJ->(GetArea())
			aAreaTFI := TFI->(GetArea())
			TFJ->( DbSetOrder( 1 ) ) // TFJ_FILIAL+TFJ_CODIGO
			TFI->( DbSetOrder( 1 ) ) //TFI_FILIAL+TFI_COD

			If TFJ->( DbSeek( xFilial("TFJ")+TEW->TEW_ORCSER)) .AND. TFI->( DbSeek( xFilial("TFI")+TEW->TEW_CODEQU ) )
				
				//  guarda os códigos de orçamentos de serviços, itens de orçamento de serviços e número de série das bases
				// para avaliar se existem Ordens de Serviço para montagem dos equipamentos
				aAdd( aVerifOS, { TFJ->TFJ_CODIGO, TFI->TFI_COD, AA3->AA3_FILORI, TEW->TEW_FILIAL, TEW->TEW_CODMV } )
			EndIf
			RestArea(aAreaTFJ)
			RestArea(aAreaTFI)
	Next nX
	
	//----------------------------------------------
	//  Dá mensagem para o usuário confirmar a atualização considerando todos os pedidos envolvidos
	If lExcPed
		cMsgConfirm := STR0126 + CRLF	//"Todos os pedidos listados a seguir precisarão serem excluídos. Tem certeza que deseja continuar?"
		aEval( aNumPed, {|x| cMsgConfirm += I18N(STR0127,{ x[1], x[2], x[4], x[5]})+CRLF } )	//"Filial: #1 / Pedido: #2 / Número de Série: #3-#4"
		
		lContinua := ( MsgYesNo( cMsgConfirm, STR0128 ) )	//"Confirmação"
	EndIf
	
	Begin Transaction
	
	// inicia o processo de exclusão dos pedidos de venda relacionados com a movimentação dos equipamentos
	If lExcPed .And. lContinua
		cFilOrig := cFilAnt
		
		DbSelectArea("SC5")
		SC5->( DbSetOrder( 1 ) ) // C5_FILIAL+C5_NUM
		
		For nX := 1 To Len(aNumPed)
			lMsErroAuto	:= .F.
			
			If SC5->( DbSeek(aNumPed[nX,1]+aNumPed[nX,2] ) )
				aSize( xAux, 0 )
				cFilAnt := aNumPed[nX,1]
				// monta o array com as informações para a exclusão do pedido
				aAdd( xAux, { "C5_FILIAL", aNumPed[nX,1], Nil } )
				aAdd( xAux, { "C5_NUM", aNumPed[nX,2], Nil } )
				
				MSExecAuto({|x,y,z| Mata410(x,y,z)}, xAux,{},5)
				
				If lMsErroAuto
					// quando encontra erro desfaz a operação e avisa o usuário com as informações gravadas
					DisarmTransaction()
	
					lContinua := .F.
					
					MsgAlert( I18N(STR0129,{aNumPed[nX,1], aNumPed[nX,2]})+CRLF+;	//"Erro na exclusão do pedido: Filial[#1] e número[#2]"
									STR0130, "AT800SEPCAN03" )	//"Verifique o motivo e retorne para desfazer a separação. O processamento será cancelado."
					MostraErro()
					Exit
				EndIf
			EndIf
		Next nX
		cFilAnt := cFilOrig
	ElseIf lIsKit .And. lContinua
		cMsgConfirm	:=	STR0131 + CRLF + ;	//"Todos os movimentos envolvidos neste Kit serão cancelados."
							STR0132	//"Tem certeza que deseja continuar?"
		lContinua := lAutomato .OR.  ( MsgYesNo( cMsgConfirm, STR0128 ) )	//"Confirmação"
	EndIf
	
	If lContinua
		DbSelectArea("AB6")
		DbSelectArea("AB7")
		
		For nX := 1 To Len(aVerifOS)
		
			aRecOS := At800QryOs(aVerifOS[nX,1],aVerifOS[nX,2],,aVerifOS[nX,3], aVerifOS[nX,4], aVerifOS[nX,5] )  //Verifica se existe O.S
			For nPosOS := 1 to Len(aRecOS)

				aSize(aCabOs,    0)
				aSize(aAuxItens, 0)
				aSize(aItensOs,  0)
				aCabOs			:= {}
				aAuxItens		:= {}
				aItensOs		:= {}

				AB6->(DbGoTo(aRecOS[nPosOS,01]))
				//Cabeçalho OS.
				aAdd(aCabOs, {"AB6_NUMOS",  AB6->AB6_NUMOS,  Nil})		//Num. OS
				aAdd(aCabOs, {"AB6_CODCLI", AB6->AB6_CODCLI, Nil})		//Cliente
				aAdd(aCabOs, {"AB6_LOJA",   AB6->AB6_LOJA,   Nil})   	//Loja
				aAdd(aCabOs, {"AB6_EMISSA", AB6->AB6_EMISSA, Nil})		//Emissão
				aAdd(aCabOs, {"AB6_CONPAG", AB6->AB6_CONPAG, Nil})		//Cond. Pagamento
				aAdd(aCabOs, {"AB6_TPORCS", AB6->AB6_TPORCS, Nil})		//Tipo Orc.
				aAdd(aCabOs, {"AB6_CDORCS", AB6->AB6_CDORCS, Nil})		//Cod. Orc.
				aAdd(aCabOs, {"AB6_ITORCS", AB6->AB6_ITORCS, Nil})		//Item Orc.

				For nPosOSItem := 1 to Len(aRecOS[nPosOS,02])
					AB7->(DbGoTo(aRecOS[nPosOS,02,nPosOSItem]))
					//Item OS.
					aAdd(aAuxItens, {"AB7_NUMOS" , AB7->AB7_NUMOS,  Nil})	//Num OS
					aAdd(aAuxItens, {"AB7_ITEM"  , AB7->AB7_ITEM,   Nil})	//Item
					aAdd(aAuxItens, {"AB7_TIPO"  , "5",             Nil})	//Tipo = Encerrado
					aAdd(aAuxItens, {"AB7_CODPRO", AB7->AB7_CODPRO, Nil})
					aAdd(aAuxItens, {"AB7_NUMSER", AB7->AB7_NUMSER, Nil})
					aAdd(aAuxItens, {"AB7_CODPRB", AB7->AB7_CODPRB, Nil})
		
					aAdd(aItensOs, aClone(aAuxItens))
					aSize(aAuxItens, 0)
					aAuxItens		:= {}
				Next nPosOSItem
					
				lMsErroAuto := .F.
				// quando o equipamento e OS são de outra filial, troca a filial para exclusão do item
				If cFilAnt <> aVerifOS[nX,3]
					cFilAnt := aVerifOS[nX,3]
				EndIf
				
				TECA450(NIL, aCabOs, aItensOs, NIL, nOpcX)
				
				// devolve a filial quando precisou trocar pq a exclusão foi em registro de outra filial
				If cFilAnt <> cFilBkp
					cFilAnt := cFilBkp
				EndIf
	
				If lMsErroAuto
					
					lContinua := .F.
					DisarmTransaction()
					
					MsgAlert( I18N(	STR0136,{AB7->AB7_NUMOS, AB7->AB7_NUMSER})+CRLF+;	//"Erro no encerramento do item na Ordem de Serviço. OS: #1/ Número Série: #2"
										STR0137, "AT800SEPCAN04" )	//"Verifique o motivo e retorne para desfazer a separação. O processamento será cancelado."
						
					MostraErro()
					EXIT
				Endif
			Next nPosOS
		
		Next nX
	EndIf
	
	If lContinua
		// adiciona os campos da movimentação de equipamentos que precisam ter o conteúdo limpo
		aSize( xAux, 0 )
		
		aAdd( xAux, {} )
		aAdd( xAux, {} )
		
		aAdd( xAux[1], { 'TEW_FILBAT', "" } )
		aAdd( xAux[1], { 'TEW_BAATD' , "" } )
		aAdd( xAux[1], { 'TEW_DTSEPA', CTOD("") } )
		aAdd( xAux[1], { 'TEW_CODCLI', "" } )
		aAdd( xAux[1], { 'TEW_LOJCLI', "" } )
		aAdd( xAux[1], { 'TEW_NUMPED', "" } )
		aAdd( xAux[1], { 'TEW_ITEMPV', "" } )
		aAdd( xAux[1], { 'TEW_QTDVEN', 0 } )
		
		// -------------------------------------------------
		//   Passa pelos registros a serem atualizados de movimentação dos equipamentos
		For nX := 1 To Len( aCodMvs )
			// posiciona nas entidades envolvidas [TEW], [TFJ, TFL e TFI] e [AA3]
			TEW->( DbGoTo( aCodMvs[nX] ) )
			At820CliLoj( @cCodClient, @cLojClient, TEW->TEW_CODEQU )
			cPrdAA3 := At820FilPd( TEW->TEW_PRODUT, TEW->TEW_FILIAL, TEW->TEW_FILBAT )
			
			If lGSOpTri
				lContinua := AtPosAA3( TEW->(TEW_FILBAT+TEW_BAATD), cPrdAA3 )
			Else
				DbSelectArea('AA3')
				AA3->( DbSetOrder( 6 ) ) // AA3_FILIAL+AA3_NUMSER
				lContinua := AA3->( DbSeek( xFilial('AA3')+TEW->TEW_BAATD ) )
			EndIf
			
			lUnic := .T.
			//Verifica se existe integração do TEC x ATF.
			If lTecAtf .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)
				
				// desfaz o vínculo de movimentação de ativos associados a base de atendimento
				oTecProvider := TECProvider():New(TEW->TEW_BAATD,TEW->TEW_FILBAT)
				lUnic := oTecProvider:lIdUnico 
				oTecProvider:DeleteTWI(TEW->TEW_CODMV, xFilial("TWI", TEW->TEW_FILIAL))
				TecDestroy(oTecProvider)

				aAreaTEW := TEW->(GetArea())
	
				TEW->(DbSetOrder(7)) //TEW_FILIAL+TEW_CODEQU+TEW_PRODUT+TEW_BAATD+TEW_KITSEQ
	
				//Desfaz a movimentação adiconal caso não tenha sido separado.
				If TEW->(DbSeek(xFilial("TEW")+TEW->TEW_CODEQU+TEW->TEW_PRODUT+Space(TamSx3("TEW_BAATD")[2]))) .And. Empty(TEW->TEW_KITSEQ)
					While !TEW->(Eof()) .AND. TEW->TEW_FILIAL == cFilTEW .And. TEW->TEW_CODEQU == cCodLoc .And. TEW->TEW_DTSEPA == CTOD('')
						If ValType(oTecProvider) <> 'O'
							oTecProvider := TECProvider():New()
						Endif
						oTecProvider:DeleteTWI(TEW->TEW_CODMV, TEW->TEW_FILIAL)
						
						oMdlMov := FwLoadModel("TECA800")
						oMdlMov:SetOperation( MODEL_OPERATION_DELETE )
						lContinua := oMdlMov:Activate()
						lContinua := lContinua .And. oMdlMov:VldData() .And. oMdlMov:CommitData()
		
						If !lContinua
							cMsgErro += IdErrorMvc( oMdlMov )
						Endif
		
						oMdlMov:DeActivate()
						oMdlMov:Destroy()
	
						TEW->(DbSkip())
					EndDo
				Endif
	
				RestArea(aAreaTEW)
			Endif			

			xAux[2] := {}
			aAdd( xAux[2], { 'AA3_STATUS', AA3_ESTOQUE } )  // '02' - Em Estoque	
			
			lAtuSlq := .T. //Atualiza o saldo
					
			If lContinua 
				// caso seja kit e a sequência não tiver sido utilizada para reduzir a qtde
				If !Empty( TEW->TEW_KITSEQ )  
				
						If aScan( aSeqs, TEW->TEW_KITSEQ) == 0
							nNewSaldo += 1
							aAdd(aSeqs, TEW->TEW_KITSEQ)
						Else
							lAtuSlq := .F.
						EndIf
					
				// caso seja controle por quantidade retorna a quantidade sendo removida
				ElseIf Empty( TEW->TEW_KITSEQ ) .And. nQtdVend > 0
					nNewSaldo += nQtdVend
					
				ElseIf Empty( TEW->TEW_KITSEQ )
					nNewSaldo += TEW->TEW_QTDVEN
				EndIf

				If nNewSaldo > TFI->TFI_QTDVEN
					nNewSaldo := TFI->TFI_QTDVEN
				EndIf
			EndIf		

			// atualiza os dados nas movimentações e base de atendimento
			lContinua := lContinua .And. Iif( lUnic ,At800Status( @cMsg, xAux[2] ),.T.) .And. At800AtuMov( @cMsg, xAux[1] )
			
			If lContinua 
				// atualiza o saldo para separação novamente do equipamento
				If lAtuSlq
					Reclock("TFI", .F. )
						TFI->TFI_SEPSLD += nNewSaldo
						TFI->TFI_SEPARA := "2"
					TFI->(MsUnlock())
				
				EndIf
				
				// exclui os pedidos adicionais de remessa associados
				If TWR->( DbSeek( xFilial("TWR",TEW->TEW_FILIAL)+TEW->TEW_CODMV ) )
					
					While TWR->(!EOF()) .And. TWR->TWR_FILIAL == TEW->TEW_FILIAL .And. TWR->TWR_CODMOV == TEW->TEW_CODMV
						
						Reclock("TWR",.F.)
						TWR->( DbDelete() )
						TWR->(MsUnlock())

						TWR->(DbSkip())
					End
				EndIf
				
				
				If lIntTecMnt .And. AA3->AA3_CODBEM <> ' '
					At800MntCli()
				EndIf
			
				// quando identificar a necessidade de capturar as informações para sendmail
				If !Empty(TFJ->TFJ_GRPCOM)
					// preenche as informações para o sendmail de situação do contrato e alocação
					cTxt := "<b> "+STR0072+"</b> "+At800DsInf("TFI", "TFI_CONTRT", xFilial("TFI")+TEW->TEW_CODEQU ) //"Nr. Contrato: "
					cTxt += "<b> "+STR0070+"</b> "+TEW->TEW_PRODUT //"Cod. Produto: "
					cTxt += "<b> "+STR0071+"</b> "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+"<br>" //"Descrição: "
			
					// adiciona na variável para controle e envio posteriormente dos emails
					If ( nItMail := aScan( aMailInfo, {|x| x[1]==TEW->TEW_CODEQU .And. x[1]==TFJ->TFJ_GRPCOM } ) ) == 0 
						If Empty(aPlEtp)
							aPlEtp := At774PlEtp("TEW",xFilial("TFI")+TEW->TEW_CODEQU)
						Endif
					
						aAdd( aMailInfo, { TEW->TEW_CODEQU, TFJ->TFJ_GRPCOM, cTxt, aClone(aPlEtp) } )
						aSize( aPlEtp, 0 )
					Else 
						aMailInfo[nItMail,3] += cTxt
					EndIf
				EndIf
				
				// captura as reservas para desfazer o vínculo com o movimento da separação
				If !Empty( TFI->TFI_RESERV ) .And. (aScan( aReservs, {|x| x==TFI->TFI_RESERV } )==0) 
					aAdd( aReservs, TFI->TFI_RESERV )
				EndIf
			Else
				DisarmTransaction()

				MsgAlert( I18N(	STR0133+CRLF+;	//"Erro na atualização do movimento do equipamento."
									STR0134,{TEW->TEW_CODMV, TEW->TEW_FILBAT, TEW->TEW_BAATD})+CRLF+;	//"Movimento: #1 / Número de Série: #2-#3"
									STR0135, "AT800SEPCAN05" )	//"Verifique o motivo e retorne para desfazer a separação. O processamento será cancelado."
				Exit
			EndIf
			
		Next nX

		// realiza a atualização de reservas vinculadas aos itens que estejam tendo a separação defeita
		TEW->( DbSetOrder( 13 ) )  // TEW_FILIAL+TEW_RESCOD+TEW_BAATD
		
		If lContinua .And. Len(aReservs) > 0
			
			oMdlReserv := FwLoadModel("TECA825C")
			oMdlGrid := oMdlReserv:GetModel("GRD_TEW")
			// atribui os textos para controle da situação da reserva
			At825CText( STR0056 )	//'Equipamento Separado'
			At825CTipo( DEF_RES_ENVIADA )
			
			For nX := 1 To Len(aReservs)
				
				If TEW->( DbSeek( xFilial("TEW")+aReservs[nX] ) )
					// inclui a operação 
					oMdlReserv:SetOperation( MODEL_OPERATION_UPDATE )
					lContinua := oMdlReserv:Activate()
					
					//  Em todos os itens da reserva removendo o vínculo com os movimentos de alocação
					// não realiza a reativação das reservas pois não há garantias que o item 
					// foi utilizado na separação e que continua disponível no período
					For nLin := 1 To oMdlGrid:Length()
						
						oMdlGrid:GoLine(nLin)
						lContinua := lContinua .And. oMdlGrid:SetValue("TEW_SUBSTI","")

					Next nLin
					// consiste os dados e grava
					lContinua := lContinua .And. oMdlReserv:VldData() .And. oMdlReserv:CommitData()
					
					If !lContinua
						DisarmTransaction()
						AtErroMvc( oMdlReserv )
						MostraErro()
						oMdlReserv:CancelData()
						Exit
					EndIf
					
					oMdlReserv:DeActivate()
				EndIf
			Next nX
		EndIf
		
		If lContinua
			cAliasQry := GetNextAlias()
			//    Pesquisa pelos registros que foram criados na separação de equipamentos para realizar a 
			//  a distribuição corretamente dos itens controlados por quantidade
			BeginSQL Alias cAliasQry
				SELECT TEW.R_E_C_N_O_ TEWRECNO
					, TEW_CODMV
				FROM %Table:TEW% TEW
				WHERE TEW_FILIAL = %xFilial:TEW%
					AND TEW.TEW_BAATD = ' '
					AND TEW.%NotDel%
					AND ( 	SELECT COUNT (TEW_CODMV )
							FROM %Table:TEW% TEWSUB
								INNER JOIN %Table:SB5% SB5 ON B5_FILIAL = %xFilial:SB5%
												AND B5_COD = TEW_PRODUT
												AND B5_ISIDUNI = '2'
												AND SB5.%NotDel%
							WHERE TEWSUB.TEW_FILIAL = %xFilial:TEW%
								AND TEWSUB.TEW_CODEQU = TEW.TEW_CODEQU
								AND TEWSUB.TEW_PRODUT = TEW.TEW_PRODUT
								AND TEWSUB.TEW_BAATD = ' '
								AND TEWSUB.TEW_KITSEQ = TEW.TEW_KITSEQ
								AND TEWSUB.TEW_CODMV < TEW.TEW_CODMV 
								AND TEWSUB.%NotDel%
						) > 0
			EndSQL
			
			While (cAliasQry)->(!EOF())
				
				TEW->( DbGoTo( (cAliasQry)->TEWRECNO ) )
				Reclock("TEW", .F.)
					TEW->( DbDelete() )
				TEW->(MsUnlock())
				(cAliasQry)->(DbSkip())
			End
		EndIf
		
	EndIf
	
	End Transaction
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SIGATEC WorkFlow # SE - Cancelamento da Separação   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua .And. ( Len(aMailInfo) > 0 )
		
		For nX := 1 To Len(aMailInfo)
			At774Mail("TFJ",aMailInfo[nX,2],"LI",aMailInfo[nX,3],"RED",STR0073,aMailInfo[nX,4]) //"Cancelamento"
			At774Mail("TFJ",aMailInfo[nX,2],"SE",aMailInfo[nX,3],"RED",STR0073,aMailInfo[nX,4]) //"Cancelamento"
		Next nX
	Endif
	
	If lContinua
		MsgInfo(STR0143,STR0144)  // "Separação desfeita com sucesso!" ### "Cancelamento da Separação"
	EndIf
EndIf

//Destroi o objeto da integração TEC x ATF
TecDestroy(oTecProvider)
RestArea(aArea)

Return 

/*/{Protheus.doc} AtuLocRetNF()
	Atualiza os dados relacionados com a movimentação quando acontece o retorno do equipamento via NF
@since  	28/09/16
@author 	Inovação Gestão de Serviços
@param 		lOk, Lógico, para indicar a situação do processamento [sucesso = .T.|erro = .F.]
@param 		oTecProvider, Objeto TECProvider, para atualizar as informações dentro do orçamento 
@param 		lTecAtf, Lógico, indica se está habilitada a integração entre GS e ATF
@param 		lIntTecMnt, Lógico, indica se está habilitada a integração entre GS e MNT
@param 		cOrigemNF, Caracter, determina qual a origem/tipo da NF de remessa do equipamento
@return 	Lógico, determina se o processamento aconteceu com sucesso (verdadeiro) ou não (falso)
/*/
Static Function AtuLocRetNF( lOk, oTecProvider, lTecATF, lIntTecMnt, cOrigemNF )
Local aDados := {}
Local aDadosOS := {"","",""}
Local cDetErro := ""
Local xAux := {}
Local lUnic := ( Posicione("SB5", 1, xFilial("SB5")+TEW->TEW_PRODUT, "B5_ISIDUNI") <> "2" )
Local lRetornaTudo := .F.

Default lOk := .T.
Default cOrigemNF := "1"  // Tipo da NF em retorno | 1=NF Filial Contrato;2=NF Filial Equipamento

// todos os dados 
lRetornaTudo := ( TEW->TEW_FILIAL == TEW->TEW_FILBAT .And. cOrigemNF == "1" ) .Or. ;
				( TEW->TEW_FILIAL <> TEW->TEW_FILBAT .And. cOrigemNF == "2" ) .Or. ;
				( TEW->TEW_FILIAL <> TEW->TEW_FILBAT .And. cOrigemNF == "1" )

//Quando for intregração TEC x ATF.
If lRetornaTudo .And. lTecATF .And. TecAtfSeek(TEW->TEW_BAATD, TEW->TEW_FILBAT)

	oTecProvider := TECProvider():New(TEW->TEW_BAATD,TEW->TEW_FILBAT)
	lUnic := oTecProvider:lIdUnico
	
	If lOk .And. AA3->AA3_MANPRE == '1'
		lOk := At800AtuOs( , .F. /*Exclusão?*/, SD1->D1_QUANT, @aDadosOS, lUnic)
	Endif
	//Inclusão de Retorno de Saldo - TWP.
	
		oTecProvider:InsertTWP(TEW->TEW_CODMV,; //Codigo da Movimentação.
		                       SD1->D1_DOC,;    //Documento
		                       SD1->D1_SERIE,;  //Serie
		                       SD1->D1_ITEM,;   //Item
		                       SD1->D1_QUANT,;  //Quantidade
		                       .T.,;		    //Exige NF?
		                       aDadosOS[1],;	//Tipo da OS
		                       aDadosOS[2],;	//Numero da OS
		                       aDadosOS[3],;	//Item da OS
							   SD1->D1_FILIAL,; // Filial da NF
							   TEW->TEW_FILIAL) // filial da movimentação
	

	TecDestroy(oTecProvider)

Endif

//Quando for Id único.
If lUnic
	If cOrigemNF == "1"
		aAdd(aDados, {'TEW_NFENT', SD1->D1_DOC})
		aAdd(aDados, {'TEW_SERENT', SD1->D1_SERIE})
		aAdd(aDados, {'TEW_ITENT', SD1->D1_ITEM})
		//Atualiza campo _SDOC dos documentos fiscais, caso habilitado
		If SerieNFId("TEW", 3, "TEW_SERENT") != "TEW_SERENT"
			aAdd(aDados, {SerieNFId("TEW", 3, "TEW_SERENT"), SerieNFId("SD1", 2, "D1_SERIE")})
		EndIf
	EndIf
	// só atualiza a data de retorno do equipamento quando todos os dados deverão ser atualizados
	If lRetornaTudo
		aAdd(aDados, {'TEW_QTDRET', SD1->D1_QUANT})
		aAdd(aDados, {'TEW_DTRFIM', SD1->D1_EMISSAO})
	EndIf

	//-----------------------------------------------------------------
	// Atualiza o movimento de locação e o status da base de atendimento
	lOk := At800AtuMov(@cDetErro, aDados)

	aSize(aDados, 0)
	aDados := {}

	If lOk .And. lRetornaTudo

		// somente atualiza a base de atendimento e gera OS quando status igual a Manutenção ou Em Cliente
		If AA3->AA3_STATUS $ '03-01'
			// -----------------------------------------------------------------
			//  Caso equipamento esteja configurado para receber inspeção após a locação
			// atualiza somente o status
			// quando não configurado, limpa os demais dados (cliente/loja,local,etc)
			If AA3->AA3_MANPRE == '1'

				//-------------------------------------------------
				//  Rotina para a geração de Ordem de Serviço
				If lOk .And. !(TecAtfSeek(AA3->AA3_NUMSER, AA3->AA3_FILORI))
					
					lOk := At800AtuOs( , .F. /*Exclusão?*/, 1 )
				EndIf
			Else
				xAux := {}
				aAdd(xAux, {'AA3_STATUS', AA3_ESTOQUE})  // Status = "Equipamento em Estoque"
				aAdd(xAux, {'AA3_CODCLI', Space(Len(AA3->AA3_CODCLI))})
				aAdd(xAux, {'AA3_LOJA',   Space(Len(AA3->AA3_LOJA))})
				aAdd(xAux, {'AA3_INALOC', CTOD('')})
				aAdd(xAux, {'AA3_FIALOC', CTOD('')})
				aAdd(xAux, {'AA3_CODLOC', Space(Len(AA3->AA3_CODLOC))})
				aAdd(xAux, {'AA3_ENTEQP', CTOD('')})
				aAdd(xAux, {'AA3_COLEQP', CTOD('')})

				lOk := At800Status(@cDetErro, xAux)
				If lOk .And. lIntTecMnt .And. AA3->AA3_CODBEM <> ' '
					At800MntCli()
				EndIf
			EndIf

		EndIf
		
		aSize( xAux, 0)
		xAux := {}

	EndIf
Else
	//Quando for Granel atualiza somente a data e a quantidade por conta do status da movimentação.
	If cOrigemNF == "1"
		// só atualiza as informações de data e qtde quando o equipamento é da mesma filial do contrato
		If lRetornaTudo
			If TEW->TEW_QTDVEN >= (TEW->TEW_QTDRET+SD1->D1_QUANT)
				aAdd( aDados, { 'TEW_DTRFIM' , SD1->D1_EMISSAO } )
			Endif
			aAdd( aDados, { 'TEW_QTDRET' , (TEW->TEW_QTDRET+SD1->D1_QUANT) } )
		EndIf
	ElseIf cOrigemNF == "2"
		// quando existir nf auxiliar de remessa, ela sempre controla a atualização de data e qtde
		If TEW->TEW_FILIAL <> TEW->TEW_FILBAT
			aAdd( aDados, { 'TEW_DTRFIM' , SD1->D1_EMISSAO } )
		Endif
		
		aAdd( aDados, { 'TEW_QTDRET' , (TEW->TEW_QTDRET+SD1->D1_QUANT) } )
	Endif
	
	If Len(aDados) > 0
		lOk := At800AtuMov( @cDetErro, aDados )
	EndIf
Endif
aSize(aDados, 0)
aDados := {}

Return lOk

/*/{Protheus.doc} AtuLocExcNF()
	Atualiza os dados relacionados com a movimentação quando acontece a exclusão da NF de retorno do equipamento via NF
@since  	28/09/16
@author 	Inovação Gestão de Serviços
@param 		cTpNfExc, Caracter, determina qual o tipo da NF sendo excluída 
				[1=Filial Contrato;2=Filial Contrato e Granel;3=Filial do Equipamento (Operação Triangular)]
@param 		lOk, Lógico, para indicar a situação do processamento [sucesso = .T.|erro = .F.]
@param 		cNotaDoc, Caracter, Indica qual o código da 
@param 		cNotaSer, Caracter, 
@param 		oTecProvider, Objeto TECProvider, para atualizar as informações dentro do orçamento 
@param 		lTecAtf, Lógico, indica se está habilitada a integração entre GS e ATF
@param 		lIntTecMnt, Lógico, indica se está habilitada a integração entre GS e MNT
@param 		cOrigemNF, Caracter, determina qual a origem/tipo da NF de remessa do equipamento
@return 	Lógico, determina se o processamento aconteceu com sucesso (verdadeiro) ou não (falso)
/*/
Static Function AtuLocExcNF( cTpNfExc, lOk, cNotaDoc, cNotaSer, oTecProvider, lTecATF, lIntTecMnt, nQtdRet )
Local aDados		:= {}
Local cDetErro		:= ""
Local xAux			:= {}
Local cSttAnt		:= ""
Local cCodClient	:= ""
Local clojClient	:= ""
Local lDesfazTudo	:= .F.
Local lUnic			:= ( Posicione("SB5", 1, xFilial("SB5")+TEW->TEW_PRODUT, "B5_ISIDUNI") <> "2" )
Local cCodMov		:= ""
Local cPrdAA3		:= ""
Local lGSOpTri		:= SuperGetMv('MV_GSOPTRI',.F.,.F.) //Parametro para ativar a operação triangular
Local cChvAA3		:= ""
Local lAtvAA3		:= .F.
Local lCpoAA3Blq	:= AA3->( ColumnPos("AA3_MSBLQL")) > 0

Default lOk := .T.
Default nQtdRet := 1
/*  Determina qual o tipo da NF sendo excluída e que precisará ter os dados atualizados dentro dos movimentos de locação
	1 = NF Pedido de Remessa Tradicional (campos preenchidos tabela TEW)
	2 = NF Remessa Equipamentos Granel (campos preenchidos tabela TWP)
	3 = NF Adicional Remessa (campos preenchidos tabela TWR)
*/
Default cTpNfExc := "1" 

lDesfazTudo := ( TEW->TEW_FILIAL == TEW->TEW_FILBAT .And. ( cTpNfExc == "1" .Or. cTpNfExc == "2" )) .Or. ;
				( TEW->TEW_FILIAL <> TEW->TEW_FILBAT .And. cTpNfExc == "3" ) .Or. ;
				(TEW->TEW_FILIAL <> TEW->TEW_FILBAT .And. ( cTpNfExc == "1" .Or. cTpNfExc == "2" )) 

// só desfaz quando há necessidade de atualizar e bloquear os saldos novamente
If lOk .And. lTecATF .And. ( (cTpNfExc == "2" .Or. cTpNfExc == "1" ) .Or. lDesfazTudo )  
	oTecProvider := TECProvider():New(TEW->TEW_BAATD)					
	lUnic := oTecProvider:lIdUnico

	oTecProvider:DeleteTWP(TEW->TEW_CODMV,TEW->TEW_FILIAL)//+SF1->F1_DOC+SF1->F1_SERIE+SD1->D1_ITEM)
	TecDestroy(oTecProvider)										
EndIf
// quando é ID Único e a NF de movimentação da TEW está sendo excluída
If cTpNfExc == "1" .Or. cTpNfExc == "2"
	aAdd(aDados, {'TEW_NFENT',  Space(Len(cNotaDoc))})
	aAdd(aDados, {'TEW_SERENT', Space(Len(cNotaSer))})
	aAdd(aDados, {'TEW_ITENT',  Space(Len(SD1->D1_ITEM))})
	If lDesfazTudo
		aAdd(aDados, {'TEW_QTDRET', (TEW->TEW_QTDRET-nQtdRet) })
	EndIf
	
	//Atualiza campo _SDOC dos documentos fiscais, caso habilitado
	If SerieNFId("TEW", 3, "TEW_SERENT") != "TEW_SERENT"
		aAdd(aDados, {SerieNFId("TEW", 3, "TEW_SERENT"), Space(Len(SerieNFId("SD1", 2, "D1_SERIE")))})
	EndIf
ElseIf cTpNfExc == "3"
	aAdd(aDados, {'TEW_QTDRET', (TEW->TEW_QTDRET-nQtdRet) })
EndIf

// só finaliza quando precisa desfazer a movimentação inteira
If lDesfazTudo
	If (nQtdRet-TEW->TEW_QTDRET) == 0
		aAdd(aDados, {'TEW_DTRFIM', CTOD("") })
	Endif
EndIf

If Len(aDados) > 0
	lOk := At800AtuMov(@cDetErro, aDados)
Endif

aSize(xAux, 0)
xAux := {}

cPrdAA3 := At820FilPd( TEW->TEW_PRODUT, TEW->TEW_FILIAL, TEW->TEW_FILBAT )
// posiciona na AA3 utilizando o campo de filial original e número de série do equipamento
If lGSOpTri
	AtPosAA3(TEW->(TEW_FILBAT+TEW_BAATD), cPrdAA3)
Else
	DbSelectArea('AA3')
	AA3->( DbSetOrder( 6 ) ) // AA3_FILIAL+AA3_NUMSER
	cChvAA3 := xFilial('AA3')+TEW->TEW_BAATD
	If (lOk := AA3->( DbSeek( cChvAA3 ) ) )
		Do While AA3->(!Eof() .AND. AA3_FILIAL+AA3_NUMSER == cChvAA3)
			//Posiciona na base de atendimento ativa
			If !lCpoAA3Blq .OR. AA3->AA3_MSBLQL <> '1'
				lAtvAA3 := .T.
				Exit
			EndIf
			AA3->(DbSkip(1))
		EndDo
		lOK := lAtvAA3
	EndIf

EndIf 

//--------------------------------------------------------
//  Refaz todas as atualizações que foram feitas com a inclusão da devolução
If lOk .And. lDesfazTudo
	If AA3->AA3_MANPRE == '1' .And. TEW->TEW_NUMOS <> ' '

		cSttAnt := AA3->AA3_STATUS
		//-------------------------------------------------
		//  Rotina para a exclusão de Ordem de Serviço
		If (lOk := At800AtuOs(@cDetErro, .T./*Exclusão?-Sim*/))
			If lUnic
				xAux := {}
				aAdd(xAux, {'AA3_STAANT', cSttAnt})
				lOk := At800Status(, xAux)
			Endif
		EndIf
		aSize(xAux, 0)
		xAux := {}
		
	Else
		If lUnic
			// quando NÃO tem manutenção preventiva é necessário reverter
			//    - Status
			//    - Cliente
			//    - Loja
			//    - Local
			//    - Dt Início e Fim
			aAdd(xAux, {'AA3_STATUS', AA3_CLIENTE})  // Status = "Equipamento em Cliente"
	
			// Captura os dados de cliente e posiciona nas tabelas superiores ao item de locação
			If At820CliLoj(@cCodClient, @clojClient, TEW->TEW_CODEQU,,TEW->TEW_FILIAL)
				aAdd(xAux, {'AA3_CODCLI', cCodClient})
				aAdd(xAux, {'AA3_LOJA',   clojClient})
				aAdd(xAux, {'AA3_CODLOC', TFI->TFI_LOCAL})
				aAdd(xAux, {'AA3_INALOC', TFI->TFI_PERINI})
				aAdd(xAux, {'AA3_FIALOC', TFI->TFI_PERFIM})
				aAdd(xAux, {'AA3_ENTEQP', TFI->TFI_ENTEQP})
				aAdd(xAux, {'AA3_COLEQP', TFI->TFI_COLEQP})
			EndIf
	
			lOk := At800Status(@cDetErro, xAux)
		Endif
		// realiza a atualização do bem no MNT (cliente e loja)
		If lOk .And. lIntTecMnt .And. AA3->AA3_CODBEM <> ' '
			At800MntCli()
		EndIf

		aSize(xAux, 0)
		xAux := {}
	EndIf
EndIf

aSize(aDados, 0)
aDados := {}

Return lOk

/*/{Protheus.doc} At800ClToOs()
	Busca e retorna o cliente e loja para ser utilizado na criação da OS de inspeção ao final da locação de equipamentos
@since  	29/09/16
@author 	Inovação Gestão de Serviços
@param 		cRetCli, Caracter, Referência, variável para retornar o código do cliente 
@param 		cRetLoj, Caracter, Referência, variável para retornar a loja que compõe o código do cliente
@return 	Lógico, Determina se conseguiu buscar a informação para retornar nos parâmetros
/*/
Static Function At800ClToOs( cRetCli, cRetLoj )
Local lFound := .F.

Default cRetCli := ""
Default cRetLoj := ""

// chama a função para manter a estrutura TFI, TFL e TFJ posicionada
lFound := At820CliLoj( @cRetCli, @cRetLoj, TEW->TEW_CODEQU, , TEW->TEW_FILIAL )

// quando a filial do equipamento é diferente da filial do contrato
// utiliza o cliente associado ao pedido de remessa para a geração da OS 
If lFound .And. ( TEW->TEW_FILIAL <> TEW->TEW_FILBAT ) 
	DbSelectArea("TWR")
	TWR->( DbSetOrder( 1 ) ) // TWR_FILIAL+TWR_CODMOV
	If ( lFound := TWR->( DbSeek( TEW->(TEW_FILIAL+TEW_CODMV) ) ) )
		cRetCli := TWR->TWR_CLIENT
		cRetLoj := TWR->TWR_LOJACL
	EndIf
EndIf

Return lFound

/*/{Protheus.doc} At800VlBox()
	Realiza a validação do parambox, da quantidade de retorno e do cancelamento do retorno dos equipamentos.
@since  	05/10/16
@author 	Inovação Gestão de Serviços
@param 		cTipVl, Caracter, Qual é o parambox "1" - Retorno , "2" - Cancelamento do Retorno.
@return 	lRet, Lógico, Determina se conseguiu passar pela validação.
/*/
Static Function At800VlBox(cTipVl)
Local lRet 		:= .T.
Default cTipVl  := "1"

If cTipVl == "1"
	If MV_PAR01 > (TEW->TEW_QTDVEN-TEW->TEW_QTDRET)
		lRet := .F.
		Help( , , "At800VlBox", ,STR0138, 1, 0,,,,,,{STR0139+" "+cValtoChar(TEW->TEW_QTDVEN-TEW->TEW_QTDRET) }) //"A quantidade informada é maior que a liberada." # "A quantidade permitida para retornar deve ser menor ou igual a:"
	Endif
ElseIf cTipVl == "2"
	If MV_PAR01 > TEW->TEW_QTDRET
		lRet := .F.
		Help( , , "At800VlBox", ,STR0140, 1, 0,,,,,,{STR0141+" "+cValtoChar(TEW->TEW_QTDRET) }) //"A quantidade informada é maior que a retornada." # "A quantidade permitida para cancelar deve ser menor ou igual a:"
	Endif
Endif

Return lRet

/*/{Protheus.doc} At800IsSub()
@description 	Avalia se o item é proveniente de uma substituição de equipamento
@since  		31.01.2017
@author 		josimar.assuncao
@param 			cCodTEW, Caracter, indica qual o número de movimentação será verificado
@return 		Lógico, indica se o item surgiu de uma substituição (.T.) ou não (.F.)
/*/
Function At800IsSub( cCodTEW )
Local lFound := .F.
Local aArea := GetArea()
Local cQrySub := GetNextAlias()

BeginSql Alias cQrySub
	SELECT TEW_SUBSTI, TEW_CODMV
	FROM %Table:TEW% TEW
	WHERE TEW.TEW_FILIAL = %xFilial:TEW%
		AND TEW.TEW_CODMV = %Exp:cCodTEW%
		AND TEW.%NotDel%
		AND EXISTS(
			SELECT 1 FROM %Table:TEW% TEWEX
			WHERE TEWEX.TEW_FILIAL = %xFilial:TEW%
				AND TEWEX.TEW_SUBSTI = TEW.TEW_CODMV
				AND TEWEX.TEW_TIPO <> '2'
		)
EndSql

If (cQrySub)->(!EOF())
	lFound := .T.
EndIf
(cQrySub)->(DbCloseArea())

RestArea(aArea)
Return lFound


/*/{Protheus.doc} At800RecTFI()
	Recupera o local do produto de locação de equipamento
@since  	15/02/2017
@author 	Inovação Gestão de Serviços
@param 		cItemTFI, Codigo da tabela TFI
@return 	cLocalTFI, Local de atendimento do produto de locação
/*/
Static Function At800RecTFI(cItemTFI)
Local aArea		:= TFI->(GetArea())
Local cLocalTFI	:= ""

DbSelectArea("TFI")
TFI->(DbSetOrder(1))

If TFI->(DbSeek(xFilial("TFI")+cItemTFI))
	cLocalTFI := TFI->TFI_CODPAI
EndIf

RestArea(aArea)

Return cLocalTFI

/*/{Protheus.doc} At800HasTWZ
@description 	Identifica se já existe lançamento de custo para o item da TFI / ORÇAMENTO
@since  		29.03.2017
@author 		Inovação Gestão de Serviços
@param 			cItemTFI, caracter, Código da tabela TFI a ser verificado.
@param 			cCodOrcSer, caracter, Código do orçamento de serviços que o item de locação está associado.
@param 			nCustoAtual, numérico, referência, Valor do custo atualmente na rotina de registro.
@return 		cCodTWZ, caracter, Código do custo lançado na rotina de registro de custos.
/*/
Static Function At800HasTWZ( cCodTFI, cCodOrcSer, nCustoAtual )
Local cCodTWZ 			:= ""
Local cQryAlias 		:= ""

Default cCodTFI 		:= ""
Default cCodOrcSer 		:= ""
Default nCustoAtual 	:= 0

If !Empty( cCodTFI ) .And. !Empty( cCodOrcSer )
	cQryAlias := GetNextAlias()

	BeginSQL Alias cQryAlias
		SELECT TWZ_CODIGO, TWZ_VLCUST
		FROM %Table:TWZ% TWZ
		WHERE TWZ_FILIAL = %xFilial:TWZ%
			AND TWZ_TPSERV = '4'
			AND TWZ_CODORC = %Exp:cCodOrcSer%
			AND TWZ_ITEM = %Exp:cCodTFI%
			AND TWZ.%NotDel%
	EndSQL

	If (cQryAlias)->(!EOF())
		cCodTWZ := (cQryAlias)->TWZ_CODIGO
		nCustoAtual := (cQryAlias)->TWZ_VLCUST
	EndIf
	(cQryAlias)->(DbCloseArea())
EndIf

Return cCodTWZ

/*/{Protheus.doc} At800BsFc
@description 	Identifica se não existem os abertas para o numero de serie
@since  		05/09/2019
@author 		Inovação Gestão de Serviços
@param 			cNumSer, caracter, Numero de Serie
@param 			cNumOS, caracter, Numero da OS
@param 			cItemOS, caracter, Item da OS
@return 		lRet, boolean, So existem OS encerradas 
/*/
Static Function At800BsFc(cNumSer, cNumOS, cItemOS)
Local lRet := .T.
Local cAlQry := GetNextAlias()

BeginSQL Alias cAlQry

	SELECT COUNT(1) AS ABERTA FROM
	%Table:AB7% AB7
	WHERE
	AB7.%NotDel% AND
	AB7.AB7_FILIAL =  %xFilial:AB7% AND
	AB7.AB7_TIPO NOT  IN ('4','5', '2') AND
	(  AB7.AB7_NUMOS <> %Exp:cNumOS%  OR
	  (AB7.AB7_NUMOS = %Exp:cNumOS% AND AB7.AB7_ITEM <> %Exp:cItemOS%) ) AND
	AB7.AB7_NUMSER = %Exp:cNumSer%

EndSQL

lRet := (cAlQry)->ABERTA = 0

(cAlQry)->(DbCloseArea())

Return lRet 

/*/{Protheus.doc} At800BsFc
@description 	Identifica se há registros na tabela TEW para verificar se utiliza locação de equipamento

@since  		15/05/2020

@author 		Inovação Gestão de Serviços

@return 		lRet, boolean, So existem OS encerradas 
/*/
Function At800UsaEq()
Local cAlQry
Local cSql := ""

If cUsaLocEqp == '0'

	cSql += " SELECT 1 REC FROM " + RetSqlName( "TEW" ) + " TEW "
	cSql += " WHERE "
	cSql += " TEW.TEW_FILIAL = '" + xFilial("TEW") + "' AND "
	cSql += " TEW.D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	cAlQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAlQry, .F., .T.)

	If (cAlQry)->(EOF())
		cUsaLocEqp := '2'
	Else
		cUsaLocEqp := '1'
	EndIf
	(cAlQry)->(DbCloseArea())
EndIf

Return (cUsaLocEqp == '1')