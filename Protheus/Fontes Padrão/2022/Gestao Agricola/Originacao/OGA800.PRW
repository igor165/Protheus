#INCLUDE "OGA800.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} OGA800()
Rotina para cadastro de Aviso PEPRO
@type  Function
@author rafael.kleestadt
@since 29/05/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function OGA800(pcNumAvi)
	Local oMBrowse	
	Local cFiltroDef := IIf(!Empty(pcNumAvi), "N9N_NUMERO='" + AllTrim(pcNumAvi) + "'", "")

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("N9N")
	oMBrowse:SetMenuDef("OGA800")
	oMBrowse:SetFilterDefault(cFiltroDef)
	oMBrowse:SetDescription( STR0001 ) //"Aviso PEPRO"	
	oMBrowse:Activate()

Return()

/*/{Protheus.doc} MenuDef()
Função que retorna os itens para construção do menu da rotina
@type  Function
@author rafael.kleestadt
@since 29/05/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0003, 'PesqBrw'       ,           0,  1, 0, .T. } ) //'Pesquisar'
aAdd( aRotina, { STR0004, 'ViewDef.OGA800',           0,  2, 0, Nil } ) //'Visualizar'
aAdd( aRotina, { STR0005, 'ViewDef.OGA800',           0,  3, 0, Nil } ) //'Incluir'
aAdd( aRotina, { STR0006, 'ViewDef.OGA800',           0,  4, 0, Nil } ) //'Alterar'
aAdd( aRotina, { STR0007, 'ViewDef.OGA800',           0,  5, 0, Nil } ) //'Excluir'
aAdd( aRotina, { STR0008, 'ViewDef.OGA800',           0,  8, 0, Nil } ) //'Imprimir'
aAdd( aRotina, { STR0009, 'ViewDef.OGA800',           0,  9, 0, Nil } ) //'Copiar'
aAdd( aRotina, { STR0013 ,"OGA810(N9N->N9N_NUMERO)" , 0, 10, 0, Nil } )  //"DCOs"	

Return aRotina

/*/{Protheus.doc} ModelDef()
Função que retorna o modelo padrao para a rotina
@type  Function
@author rafael.kleestadt
@since 29/05/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oStruN9N  := FWFormStruct( 1, "N9N" )
Local oStruN9Q  := FWFormStruct( 1, "N9Q" )
Local oStruN9Q2 := FWFormStruct( 1, "N9Q" )
Local oStruN9V  := FWFormStruct( 1, "N9V" )
Local oStruNBZ  := FWFormStruct( 1, "NBZ" )
Local oModel    := MPFormModel():New( "OGA800", {| oModel | PreModelo( oModel ) } , {| oModel | PosModelo( oModel ) }, {| oModel | GrvModelo( oModel ) })

oStruN9N:SetProperty( "N9N_INDICE" , MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, "OG800VNK0TAB(a, b, c)" ) ) 
oStruN9N:SetProperty( "N9N_INDPRE" , MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, "OG800VNK0TAB(a, b, c)" ) )
oStruN9N:SetProperty( "N9N_INDICE" , MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "OG800WHNID()" ) )
oStruN9N:SetProperty( "N9N_INDPRE" , MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "OG800WHNID()" ) )

oStruN9Q:SetProperty("N9Q_TIPLOC" ,  MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "OG800INTLC(1)" ) )
oStruN9Q2:SetProperty("N9Q_TIPLOC" , MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "OG800INTLC(2)" ) )

// Ao informar o estado, limpa o campo de Região, e ao informar a Região limpa o campo Estado
oStruN9Q:AddTrigger("N9Q_EST",    "N9Q_CODREG", {|| .T. }, {|| LimaCmp(1, 1) })
oStruN9Q:AddTrigger("N9Q_CODREG", "N9Q_EST",    {|| .T. }, {|| LimaCmp(2, 1) })

oStruN9Q2:AddTrigger("N9Q_EST",    "N9Q_CODREG", {|| .T. }, {|| LimaCmp(1, 2) })
oStruN9Q2:AddTrigger("N9Q_CODREG", "N9Q_EST",    {|| .T. }, {|| LimaCmp(2, 2) })

oModel:AddFields( 'N9NUNICO', Nil, oStruN9N )
oModel:SetDescription( STR0001 ) //"Aviso PEPRO"
oModel:GetModel( 'N9NUNICO' ):SetDescription( STR0002 ) //"Dados do Aviso PEPRO"

oModel:AddGrid( "N9QUNICO", "N9NUNICO", oStruN9Q, , , , ) 
oModel:GetModel( "N9QUNICO" ):SetDescription( 'Regras Origem' ) //"Regras Origem"
oModel:GetModel( "N9QUNICO" ):SetUniqueLine( { "N9Q_TIPLOC" , "N9Q_SEQUEN" } )
oModel:GetModel( "N9QUNICO" ):SetOptional( .t. )
oModel:SetRelation( "N9QUNICO", { { "N9Q_FILIAL", "xFilial( 'N9Q' )" }, { "N9Q_NUMERO", "N9N_NUMERO" } }, N9Q->( IndexKey( 1 ) ) )
oModel:GetModel( 'N9QUNICO'):SetLoadFilter( , "N9Q_TIPLOC = '1'")

oModel:AddGrid( "N9QUNICO2", "N9NUNICO", oStruN9Q2, , , , ) 
oModel:GetModel( "N9QUNICO2" ):SetDescription( 'Regras Destino' ) //"Regras Destino"
oModel:GetModel( "N9QUNICO2" ):SetUniqueLine( { "N9Q_TIPLOC" , "N9Q_SEQUEN" } )
oModel:GetModel( "N9QUNICO2" ):SetOptional( .t. )
oModel:SetRelation( "N9QUNICO2", { { "N9Q_FILIAL", "xFilial( 'N9Q' )" }, { "N9Q_NUMERO", "N9N_NUMERO" } }, N9Q->( IndexKey( 1 ) ) )
oModel:GetModel( 'N9QUNICO2'):SetLoadFilter( , "N9Q_TIPLOC = '2'")

oModel:AddGrid( "NBZUNICO", "N9NUNICO", oStruNBZ,,,,, )
oModel:GetModel( "NBZUNICO" ):SetDescription( STR0015 ) //"Aviso x Itens Controle PEPRO"
oModel:GetModel( "NBZUNICO" ):SetUniqueLine( { "NBZ_CODITE" } )
oModel:GetModel( "NBZUNICO" ):SetOptional( .t. )
oModel:SetRelation( "NBZUNICO", { { "NBZ_FILIAL", "xFilial( 'NBZ' )" }, { "NBZ_NUMAVI", "N9N_NUMERO" } }, NBZ->( IndexKey( 1 ) ) )

oModel:AddGrid( "N9VUNICO", "N9NUNICO", oStruN9V,,,,, )
oModel:GetModel( "N9VUNICO" ):SetDescription( STR0022 ) //"Finalidades"STR0022
oModel:GetModel( "N9VUNICO" ):SetUniqueLine( { "N9V_FINALI" } )
oModel:GetModel( "N9VUNICO" ):SetOptional( .t. )
oModel:SetRelation( "N9VUNICO", { { "N9V_FILIAL", "xFilial( 'N9V' )" }, { "N9V_NUMERO", "N9N_NUMERO" } }, N9V->( IndexKey( 1 ) ) )

Return oModel

/*/{Protheus.doc} ViewDef()
Função que retorna a view para o modelo padrao da rotina
@type  Function
@author rafael.kleestadt
@since 29/05/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oStruN9N	:= FWFormStruct( 2, "N9N" )
Local oStruN9Q	:= FWFormStruct( 2, "N9Q" )
Local oStruNBZ  := FWFormStruct( 2, "NBZ" )
Local oStruN9V  := FWFormStruct( 2, "N9V" )
Local oModel	:= FWLoadModel( "OGA800" )
Local oView		:= FWFormView():New()

oStruN9Q:RemoveField( "N9Q_NUMERO" )
oStruN9Q:RemoveField( "N9Q_TIPLOC" )
oStruNBZ:RemoveField( "NBZ_NUMAVI" )
oStruN9N:RemoveField( "N9N_DTDINI" )
oStruN9N:RemoveField( "N9N_DTDFIN" )
oStruN9N:RemoveField( "N9N_DTEINI" )
oStruN9N:RemoveField( "N9N_DTEFIN" )
oStruN9N:RemoveField( "N9N_DTSINI" )
oStruN9N:RemoveField( "N9N_DTSFIN" )
oStruN9V:RemoveField( "N9V_NUMERO" )
oStruN9V:RemoveField( "N9V_CODIGO" )

oView:SetModel( oModel )

//cria a pasta principal
oView:CreateFolder( "PEPROFOLDER")

//abas folder aviso pepro
oView:AddSheet('PEPROFOLDER', 'PRINCIPAL', 	 STR0001) // "Aviso PEPRO"
oView:AddSheet('PEPROFOLDER', 'REGRAORIG',	 STR0020) //"Regras Origem"
oView:AddSheet('PEPROFOLDER', 'REGRADEST',	 STR0021) //"Regras Destino"
oView:AddSheet('PEPROFOLDER', 'AVIXITEMC',   STR0015) //"Aviso x Itens Controle PEPRO"
oView:AddSheet('PEPROFOLDER', 'FINALIDADE',  STR0022) //"Finalidades"

//view "Aviso PEPRO"
oView:AddField( "VIEW_N9N", oStruN9N, "N9NUNICO")
oView:CreateHorizontalBox( "BOX-PRIN" , 100, , , "PEPROFOLDER", "PRINCIPAL" )
oView:SetOwnerView( "VIEW_N9N", "BOX-PRIN" )
oView:EnableTitleView( "VIEW_N9N" )

//view "Regras Origem"
oView:AddGrid( "VIEW_N9Q", oStruN9Q, "N9QUNICO")
oView:CreateHorizontalBox( "BOX-TOP-ORIG" , 100, , , "PEPROFOLDER", "REGRAORIG" )
oView:SetOwnerView( "VIEW_N9Q", "BOX-TOP-ORIG" )
oView:EnableTitleView( "VIEW_N9Q")
oView:AddIncrementField( "VIEW_N9Q", "N9Q_SEQUEN" )

//view "Regras Destino"
oView:AddGrid( "VIEW_N9Q2", oStruN9Q, "N9QUNICO2")
oView:CreateHorizontalBox( "BOX-TOP-DEST" , 100, , , "PEPROFOLDER", "REGRADEST" )
oView:SetOwnerView( "VIEW_N9Q2", "BOX-TOP-DEST" )
oView:EnableTitleView( "VIEW_N9Q2")
oView:AddIncrementField( "VIEW_N9Q2", "N9Q_SEQUEN" )

//view "Aviso x Itens Controle PEPRO"
oView:AddGrid( "VIEW_NBZ", oStruNBZ, "NBZUNICO")
oView:CreateHorizontalBox( "BOX-TOP-ITE" , 100, , , "PEPROFOLDER", "AVIXITEMC" )
oView:SetOwnerView( "VIEW_NBZ", "BOX-TOP-ITE" )
oView:EnableTitleView( "VIEW_NBZ")

//view "Finalidades"
oView:AddGrid( "VIEW_N9V", oStruN9V, "N9VUNICO")
oView:CreateHorizontalBox( "BOX-TOP-FIN" , 100, , , "PEPROFOLDER", "FINALIDADE" )
oView:SetOwnerView( "VIEW_N9V", "BOX-TOP-FIN" )
oView:EnableTitleView( "VIEW_N9V")

oView:SetCloseOnOk( {||.t.} )

Return oView

/*/{Protheus.doc} OGA800ENT()
Função para validar se a entidade informada possui cliente
@type  Function
@author rafael.kleestadt
@since 01/06/2018
@version version
@param param, param_type, param_descr
@return return, logical, True or False
@example
(examples)
@see (links_or_references)
/*/
Function OGA800ENT()

Local aArea := GetArea()

If Empty(Posicione("NJ0", 1, xFilial("NJ0") + FwFldGet("N9N_CODENT"), "NJ0_CODCLI"))

    Help(" ", 1, ".OGA800000001.") //##Problema: Entidade Inválida. 
    Return .F.                     //##Solução: Informe uma entidade com cliente.

EndIf

RestArea(aArea)

Return .T.

/*/{Protheus.doc} PosModelo(oModel)
pos validação do modelo para não permitir cadastrar outros estados se a linha estiver em branco(todos)
@type  Static Function
@author rafael.kleestadt
@since 01/06/2018
@version 1.0
@param oModel, object, objeto do modelo
@return True, Logical, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function PosModelo(oModel)
Local oModelN9N  := oModel:GetModel( "N9NUNICO" )
Local nOperation := oModel:GetOperation()

IF  nOperation == MODEL_OPERATION_UPDATE
	DbSelectArea("N9W")
	N9W->(DbSetOrder(1)) // N9W_FILIAL+N9W_NUMAVI+N9W_NUMDCO+N9W_SEQEST
	If  N9W->(DbSeek(xFilial("N9W")+oModelN9N:GetValue("N9N_NUMERO")))
		While N9W->(!Eof())	.AND. N9W->N9W_FILIAL+N9W->N9W_NUMAVI == xFilial("N9N")+oModelN9N:GetValue("N9N_NUMERO")				
		   If RecLock("N9W", .F.)
			  cUMDest 		  := oModelN9N:GetValue("N9N_UNMEPR")
			  cProduto 		  := oModelN9N:GetValue("N9N_CODPRO")
			  nVlMaxP  		  := oModelN9N:GetValue("N9N_VLMAXP")				
			  N9W->N9W_VLMAX  := nVlMaxP					 
			  N9W->N9W_VLPREV := AGRX001(oModelN9N:GetValue("N9N_UNIMED"),cUMDest, N9W->N9W_QUANT , cProduto) * nVlMaxP 
			  
			  N9W->(MsUnlock())
			EndIf
		
		N9W->(DbSkip())
		EndDo		
	ENDIF
ENDIF

Return .T.

/*/{Protheus.doc} getObsInd
Retorna observação conforme Índice cadastrado no Aviso
@author tamyris.g
@since 22/06/2018
@version undefined

@type function
/*/
Function getObsInd(cNumAvi, cCodCli, cLojCli, cTpAlgo )
	
	Local cAliasN9N := GetNextAlias()	
	Local cQryN9N   := ''
	
	cUfOrig    := SUPERGETMV("MV_ESTADO", .f., "")
	cUfDest    := POSICIONE("SA1",1, xFilial("SA1") + cCodCli + cLojCli, "A1_EST")
	cRetorno   := ''
	
	Default cTpAlgo := ''
	
	cQryN9N := " Select N9U_CODREG "
	cQryN9N += "   FROM " + RetSqlName("N9N") + " N9N "
	cQryN9N += " Inner Join " + RetSqlName("N9U") + " N9U ON N9U_NUMAVI = N9N_NUMERO AND N9U.D_E_L_E_T_ = '' "
	cQryN9N += "   Where N9N_NUMERO = '" + cNumAvi + "' And N9N.D_E_L_E_T_ = '' "
	cQryN9N := ChangeQuery(cQryN9N)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryN9N), cAliasN9N, .F., .T.)

	If (cAliasN9N)->(!EoF())
		cRetorno := (cAliasN9N)->N9U_CODREG
	EndIf
	
	dbSelectArea("N9N")
	N9N->(dbSetOrder(1))
	If N9N->( dbSeek(xFilial("N9N")+ cNumAvi ) )
		If NK0->(DbSeek(xFilial("NK0") + N9N->N9N_INDICE ))
			cObserv   := AgrGetInd( NK0->NK0_INDICE,NK0->NK0_TPCOTA, dDataBase, N9N->N9N_CODPRO, cTpAlgo, N9N->N9N_SAFRA, cUfOrig, cUfDest, 'O', cRetorno)
			
			If !empty(cObserv)
				cRetorno := cObserv
			EndIf
		EndIF
	EndIf
	 
Return cRetorno

/*/{Protheus.doc} OG800VNK0TAB
//TODO Valida se o indice informado no campo é do tipo tabela
@author claudineia.reinert
@since 25/10/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, modelo de dados
@param cCampo, characters, nome do campo
@param xNewValue, , valor informado no campo
@type function
/*/
Function OG800VNK0TAB(oModel, cCampo, xNewValue)
	Local lRet := .F.

	dbSelectArea("NK0")
	NK0->( dbSetOrder(1) )
	If NK0->(DbSeek(xFilial("NK0") + xNewValue))
		If NK0->NK0_TPCOTA == "T"
			lRet := .T.
		EndIf
	EndIf
	
	If .not. lRet
		Help( , , STR0017, , STR0018, 1, 0 ) //"AJUDA"###"Indice informado não é do tipo tabela. Informe um indice do tipo tabela."
	EndIf

Return lRet

/*/{Protheus.doc} GrvModelo()
Função de gravação do modelo
@type  Static Function
@author rafael.kleestadt
@since 21/11/2018
@version 1.0
@param oModel, object, objeto do modelo principal
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function GrvModelo(oModel)
	Local nOperation := oModel:GetOperation()
	Local lRet       := FWFormCommit( oModel )

	//Atualiza a previsão de recebimento DCO
	If lRet .And. nOperation == MODEL_OPERATION_UPDATE

		Processa({ || fAtuPrvRec(oModel) }, STR0019) //"Atualizando previsão de recebimento do DCO..."

	EndIf

Return .T.

/*/{Protheus.doc} fAtuPrvRec(oModel)
Atualiza a previsão de recebimento DCO
@type  Static Function
@author rafael.kleestadt
@since 21/11/2018
@version 1.0
@param oModel, object, objeto do modelo principal
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function fAtuPrvRec(oModel)
	Local oMldN9N    := oModel:GetModel("N9NUNICO")

	DbSelectArea("N9U")
	N9U->(DbSetOrder(1))
	If N9U->(DbSeek(FwxFilial("N9U")+oMldN9N:GetValue("N9N_NUMERO")))
		While N9U->(! EOF()) .And. N9U->(N9U_FILIAL+N9U_NUMAVI) == FwxFilial("N9U")+oMldN9N:GetValue("N9N_NUMERO")
			OGA810AVLP(N9U->N9U_FILIAL, N9U->N9U_NUMAVI, N9U->N9U_NUMDCO)
			N9U->(DbSkip())
		EndDo
	EndIf
	N9U->(DbCloseArea())

Return .T.

/*/{Protheus.doc} PreModelo(oModel)
Pre validação do modelo 
@type  Static Function
@author Christopher.miranda
@since 20/11/2018
@version 1.0
@param oModel, object, objeto do modelo
@return True, Logical, True or False
@example
@see (links_or_references)
/*/
Static Function PreModelo( oModel )

Return .T.

/*/{Protheus.doc} OG800WHNID()
Verifica se o dco já tem faturamento e se tiver bloqueia a alteração do índice.
@type  Function
@author rafael.kleestadt
@since 26/11/2018
@version 1.0
@param param, param_type, param_descr
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Function OG800WHNID()
	Local oModel    := FwModelActive()
	Local oModelN9N := oModel:GetModel( "N9NUNICO" )

	DbSelectArea("N8K")
	N8K->(DbSetOrder(7)) //N8K_FILIAL+N8K_NUMAVI+N8K_NUMDCO+N8K_SEQDCO
	If N8K->(DbSeek(FwxFilial("N8K")+oModelN9N:GetValue("N9N_NUMERO")))
		Return .F.
	EndIf
	N8K->(DbCloseArea())

Return .T.

/*{Protheus.doc} OG800INTLC
Inicializa o campo N9Q_TIPLOC de acordo com a aba que está aberta "Regras Origem" ou "Regras Destino"

@author francisco.nunes
@since 13/02/2019
@version 1.0
@return, cRet, 1-Origem;2-Destino
@type function
*/
Function OG800INTLC(nIndAba)

	Local cRet := ""
	
	cRet := IIf(nIndAba == 1, "1", "2")
	
Return cRet

/*{Protheus.doc} LimaCmp
Limpa as descrições dos campos Estado e Região, de acordo com o solicitado

@author francisco.nunes
@since 13/02/2019
@version 1.0
@param nCmp, 1-Limpa o campo Região; 2-Limpa o campo Estado
@param, nModel, 1-Origem;2-Destino
@type function
*/
Static Function LimaCmp(nCmp, nModel)

	Local oModel    := FWModelActive()
	Local oModelN9Q := IIf(nModel == 1, oModel:GetModel("N9QUNICO"), oModel:GetModel("N9QUNICO2"))
	
	If nCmp == 1
		oModelN9Q:LoadValue("N9Q_DESREG", "")		
	Else
		oModelN9Q:LoadValue("N9Q_ESTADO", "")
	EndIf
	
Return ""
