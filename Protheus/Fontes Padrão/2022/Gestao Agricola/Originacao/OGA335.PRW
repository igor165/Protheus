#INCLUDE "OGA335.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} OGA335
Aditações / Supressões de Contratos.

@param:     Nil
@author:    Equipe Agroindustria
@since:     08/06/2010
@Uso:       SIGAARM - Originação de Grãos
@type function
*/
Static __cCodCtr    := Criavar('NJR_CODCTR',.f.) 
Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio

Function OGA335( pcCodCtr,pcCodFil)     

	Local oMBrowse := Nil
	Local cFiltroDef :=  iIf( !Empty( pcCodCtr ), "NNW_CODCTR='"+pcCodCtr+"' .And. NNW_FILIAL='"+pcCodFil+"'", "" )
	__cCodCtr := pcCodCtr

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NNW" )
	oMBrowse:SetDescription( STR0001 ) //"Alteração de Contrato"
	oMBrowse:SetFilterDefault( cFiltroDef )
	oMBrowse:SetMenuDef( "OGA335" )

	oMBrowse:AddLegend( "NNW_TIPO=='1'.And.NNW_STATUS='1'"  , "BLUE"    , STR0002   ) //"Aditação Prevista"
	oMBrowse:AddLegend( "NNW_TIPO=='1'.And.NNW_STATUS='2'"  , "GREEN"   , STR0003   ) //"Aditação Confirmada"
	oMBrowse:AddLegend( "NNW_TIPO=='2'.And.NNW_STATUS='1'"  , "YELLOW"  , STR0004   ) //"Supressão Prevista"
	oMBrowse:AddLegend( "NNW_TIPO=='2'.And.NNW_STATUS='2'"  , "RED" 	, STR0005  	) //"Supressão Confirmada"

	oMBrowse:Activate()

Return( Nil )


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param:     Nil
@return:    aRotina - Array com os itens do menu
@author:    Equipe Agroindustria
@since:     08/06/2010
@Uso:       OGA010 - Entidades
*/
Static Function MenuDef()    
	Local aRotina := {}

	aAdd( aRotina, { STR0006 , "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0007 , "ViewDef.OGA335" , 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0008 , "ViewDef.OGA335" , 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0009 , "ViewDef.OGA335" , 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0010 , "OG335CBRW"      , 0, 4, 0, Nil } ) //"Confirmar"
	aAdd( aRotina, { STR0011 , "ViewDef.OGA335" , 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0012 , "ViewDef.OGA335" , 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0013 , "ViewDef.OGA335" , 0, 9, 0, Nil } ) //"Copiar"

	aAdd( aRotina, { STR0039 , "OGR343(NNW->NNW_CODCTR, NNW->NNW_SEQ)" , 0, 4, 0, Nil } ) //"Imprimir Word"
	If !__lnewNeg //comercialização classica
		aAdd( aRotina, { STR0060 , "OG335AC01()" , 0, 7, 0, Nil } ) //"Acerto Contrato"
	EndIF

Return( aRotina )

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param:     Nil
@return:    oModel - Modelo de dados
@author:    Equipe Agroindustria
@since:     08/06/2010
@Uso:       OGA335 - Alteracao de Contrato
*/
Static Function ModelDef()
	Local oStruNNW := FWFormStruct( 1, "NNW" )
	Local oStruNNY := FWFormStruct( 1, "NNY" )
	Local oStruNN8 := FWFormStruct( 1, "NN8" ,  { |x| ALLTRIM(x) $ 'NN8_CODCTR, NN8_ITEMFX, NN8_TIPOFX, NN8_STATUS, NN8_QTDFIX, NN8_QTDENT' })	
	Local oStruNJR := FwFormStruct( 1, "NJR" )
	Local oStruN7M := NIL
	Local oStruN7N := NIL
	Local oStruN7O := NIL	
	Local oStruN9A := Nil
	Local oModel   := MPFormModel():New( "OGA335" , ,{| oModel | TudoOk( oModel ) } , {| oModel | GrvModelo( oModel ) }  )
	Local lBROWSER := IsInCallStack( "OG335CBRW" ) .or. IsInCallStack( "OGX700CAQC" )  
	
	If lBROWSER
		oStruNNY:RemoveField("NNY_CODCTR")
		oStruNNY:RemoveField("NNY_ENTORI")
		oStruNNY:RemoveField("NNY_LOJORI")
		oStruNNY:RemoveField("NNY_ENTDES")
		oStruNNY:RemoveField("NNY_LOJDES")
		oStruNNY:RemoveField("NNY_TIPENT")
		oStruNNY:RemoveField("NNY_ENTREG")

	EndIf
	If ! Empty( __cCodCtr )
		oStruNNW:SetProperty( "NNW_CODCTR" , MODEL_FIELD_INIT , { | | __cCodCtr } ) 
		oStruNNW:SetProperty( "NNW_SEQ"    , MODEL_FIELD_INIT , { | | FIniNNWSeq() } )       
	EndIf
	
	oStruNNW:SetProperty( "NNW_TIPO"  , MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "VldTpMtv('NNW_TIPO')") ) 
	oStruNNW:SetProperty( "NNW_QTDALT" , MODEL_FIELD_VALID, {| oFields | ValQTDALT( oFields:GetValue( "NNW_CODCTR" ), oFields:GetValue( "NNW_TIPO" ), oFields:GetValue( "NNW_QTDALT" ) ) } )
	oStruNNW:SetProperty( "NNW_CODCTR" , MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "OGA335VLDB()") )
	oStruNNW:SetProperty( "NNW_CODMTV" , MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "VldTpMtv('NNW_CODMTV')") )
	
	if 	!Empty( __cCodCtr ) .and. __lnewNeg //somente se novo negócio/via browser
		oStruNNW:SetProperty( "NNW_TIPO"  , MODEL_FIELD_INIT, { | | "1" }  )		
	endif
	
	If lBROWSER
		
		oStruNNW:SetProperty("NNW_QTDALT", MODEL_FIELD_WHEN, {|| .F.}) // Desbloqueia a edição somente para o campo de quantidade total
		If cPaisLoc <> "PAR" //Paraguai
			oStruNJR:SetProperty("*" , MODEL_FIELD_OBRIGAT, .F.) // remove obrigatoriedade dos campos da NJR
		EndIf
		//-- Tabela Temporaria --// 
		oStruNNY:AddField( "Qtd. Alterar", "Quantidade Alterada", 'TMP_QTDALT', TamSx3('NNY_QTDINT')[3] , TamSX3("NNY_QTDINT")[1] , 0 , /*bValid*/, /*bWhen*/, /*aValues*/ ,/*lObrigat*/, /*bInit*/, .F./*lKey*/, /*lNoUpd*/,   /*lVirtual*/) 
		oStruNNY:AddField( "Qtd. Total"  , "Qunatidade Total"   , 'TMP_QTDTOT', TamSx3('NNY_QTDINT')[3] , TamSX3("NNY_QTDINT")[1] , 0 , /*bValid*/, /*bWhen*/, /*aValues*/ ,/*lObrigat*/, /*bInit*/, .F./*lKey*/, /*lNoUpd*/,/*lVirtual*/)  
		//--Trava campos para não editar --//
		oStruNNY:SetProperty("*", MODEL_FIELD_WHEN, {|| .F.}) // Bloqueia a edição de todos os campos
		oStruNNY:SetProperty("TMP_QTDALT", MODEL_FIELD_WHEN, {|| .T.}) // Desbloqueia a edição somente para o campo de quantidade total
		
		//--Inicializador  da NNY *//
		oStruNNY:SetProperty( 'TMP_QTDTOT', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "NNY->NNY_QTDINT"))

		//--Gatilho da Tabela Temporaria --// 
		oStruNNY:AddTrigger( 'TMP_QTDALT',"TMP_QTDALT"    , {|| .t. } , {|| fOG335GCTR() })   //Atualiza Qtd cadência Tabela temporaria.

		//--Valida Qtd cadência em questão --// 
		oStruNNY:SetProperty( "TMP_QTDALT", MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "ValNNYTOT()") )

		If __lnewNeg 
			oStruN9A := FWFormStruct(1, "N9A") // Estrutura regras fiscais
			oStruN9A:RemoveField("N9A_ENTENT")
			oStruN9A:RemoveField("N9A_LJEENT")
			oStruN7M  	:= FWFormStruct( 1, "N7M" )
			oStruN7N  	:= FWFormStruct( 1, "N7N" )
			oStruN7O  	:= FWFormStruct( 1, "N7O" )
			oStruNN8  	:= FWFormStruct( 1, "NN8" )
			oStruNKA  	:= FWFormStruct( 1, "NKA" )	   
		EndIf
		If cPaisLoc == "PAR" //Paraguai
			//NN8 - fixações
			oStruNN8:AddField( "Cantidad a cambiar", "Cantidad a cambiar", 'TMP_QTDFIX', TamSx3('NN8_QTDFIX')[3] , TamSX3("NN8_QTDFIX")[1] , 0 , /*bValid*/, /*bWhen*/, /*aValues*/ ,/*lObrigat*/, /*bInit*/, .F./*lKey*/, /*lNoUpd*/,   /*lVirtual*/) 
		   	oStruNN8:SetProperty('*',MODEL_FIELD_NOUPD, .T.) //desabilito a edição dos campos
			oStruNN8:SetProperty('TMP_QTDFIX',MODEL_FIELD_NOUPD, .F.) //habilito apenas de quantidade.
	
		EndIf

	EndiF

	oModel:AddFields( "NNWUNICO", Nil, oStruNNW )
	oModel:SetDescription( STR0001 ) //"Alteração de Contrato"
	oModel:GetModel( "NNWUNICO" ):SetDescription( STR0014 ) //"Dados da Alteração do Contrato"

	IF lBROWSER

		oModel:AddGrid( "NNYUNICO", "NNWUNICO", oStruNNY )
		oModel:GetModel( "NNYUNICO" ):SetDescription( STR0030 ) //"Dados do Intervalo de Cadência"
		oModel:GetModel( "NNYUNICO" ):SetUniqueLine( { "NNY_ITEM" } )
		oModel:GetModel( "NNYUNICO" ):SetOptional(.f.)
		oModel:GetModel( "NNYUNICO" ):SetNoDelete()
		oModel:GetModel( "NNYUNICO" ):SetNoInsert()
		oModel:SetRelation( "NNYUNICO", { { "NNY_FILIAL", "xFilial( 'NNY' )" }, { "NNY_CODCTR", "NNW_CODCTR" } }, NNY->( IndexKey( 1 ) ) )

		If cPaisLoc == "PAR" //Paraguai

			//fixaçoes de preço
			oModel:AddGrid( "NN8UNICO", "NNWUNICO", oStruNN8, {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| PreValNN8(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)})
			oModel:GetModel( "NN8UNICO" ):SetDescription( "Fixações" ) //"Dados do Intervalo de Cadência"
			oModel:GetModel( "NN8UNICO" ):SetUniqueLine( { "NN8_ITEMFX" } )
			oModel:GetModel( "NN8UNICO" ):SetOptional(.f.)
			oModel:GetModel( "NN8UNICO" ):SetNoDelete()
			oModel:GetModel( "NN8UNICO" ):SetNoInsert()
			oModel:SetRelation( "NN8UNICO", { { "NN8_FILIAL", "xFilial( 'NN8' )" }, { "NN8_CODCTR", "NNW_CODCTR" } }, NN8->( IndexKey( 1 ) ) )

		Else 
			 
			// Utilizada para obter variaveis de memoria para o inicializador padrão das regras fiscais.
			oModel:AddFields("NJRUNICO", "NNWUNICO", oStruNJR ) // Estrutura seguindo relacionamento
			oModel:GetModel("NJRUNICO"):SetOnlyQuery(.T.) // Somente query
			oModel:GetModel("NJRUNICO"):SetOnlyView(.T.) // Somente visualização
			oModel:SetRelation("NJRUNICO", { { "NJR_FILIAL", "FwXFilial('NJR')" }, { "NJR_CODCTR", "NNW_CODCTR" } }, NJR->( IndexKey( 1 ) ) )

			//Regras Fiscais
			If __lnewNeg
				oStruN9A:SetProperty('N9A_CODCTR', MODEL_FIELD_OBRIGAT, .F.)
				oModel:AddGrid("N9AUNICO", "NNYUNICO", oStruN9A)
				oModel:AddGrid( "N7MUNICO", "NJRUNICO", oStruN7M )
				oModel:AddGrid( "N7NUNICO", "NJRUNICO", oStruN7N )
				oModel:AddGrid( "N7OUNICO", "NJRUNICO", oStruN7O )
				oModel:AddGrid( "NN8UNICO", "NJRUNICO", oStruNN8 )
				oModel:AddGrid( "NKAUNICO", "NJRUNICO", oStruNKA )
				
				oModel:GetModel("N9AUNICO"):SetOptional(.T.)
				oModel:GetModel( "N7MUNICO" ):SetOptional( .T. )
				oModel:GetModel( "N7NUNICO" ):SetOptional( .T. )
				oModel:GetModel( "N7OUNICO" ):SetOptional( .T. )
				oModel:GetModel( "NN8UNICO" ):SetOptional( .T. )
				oModel:GetModel( "NKAUNICO" ):SetOptional( .T. )

				oModel:SetRelation( "N9AUNICO", { { "N9A_FILIAL", "xFilial( 'N9A' )" }, { "N9A_CODCTR", "NNW_CODCTR" }, {"N9A_ITEM", "NNY_ITEM"}}, N9A->(IndexKey(1)))
				oModel:SetRelation( "N7MUNICO", { { "N7M_FILIAL", "xFilial( 'N7M' )" }, { "N7M_CODCTR", "NNW_CODCTR" } }, N7M->( IndexKey( 1 ) ) )
	   			oModel:SetRelation( "N7NUNICO", { { "N7N_FILIAL", "xFilial( 'N7N' )" }, { "N7N_CODCTR", "NNW_CODCTR" } }, N7N->( IndexKey( 1 ) ) )
	   			oModel:SetRelation( "N7OUNICO", { { "N7O_FILIAL", "xFilial( 'N7O' )" }, { "N7O_CODCTR", "NNW_CODCTR" } }, N7O->( IndexKey( 2 ) ) )
	   			oModel:SetRelation( "NN8UNICO", { { "NN8_FILIAL", "xFilial( 'NN8' )" }, { "NN8_CODCTR", "NNW_CODCTR" } }, NN8->( IndexKey( 1 ) ) )
	   			oModel:SetRelation( "NKAUNICO", { { "NKA_FILIAL", "xFilial( 'NKA' )" }, { "NKA_CODCTR", "NNW_CODCTR" } }, NKA->( IndexKey( 1 ) ) )

								
				oModel:GetModel("N9AUNICO"):SetUniqueLine({"N9A_ITEM","N9A_SEQPRI"})
			EndIf
			
		EndIf	
	
	EndIf
	oModel:SetVldActivate( { | oModel | fvldModelo( oModel, oModel:GetOperation() ) } )
	oModel:SetActivate( { | oModel | IniModelo( oModel, oModel:GetOperation() ) } )
Return( oModel )

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param:     Nil
@return:    oView - View do modelo de dados
@author:    Equipe Agroindustria
@since:     08/06/2010
@Uso:       OGA335 - Alteracao de Contrato
*/
Static Function ViewDef()    
	Local oStruNNW    := FWFormStruct( 2, "NNW" )
	Local oStruNNY    := FWFormStruct( 2, "NNY" )
	Local oStruNN8    := FWFormStruct( 2, "NN8"  ,{ |x| ALLTRIM(x) $ 'NN8_CODCTR, NN8_ITEMFX, NN8_TIPOFX, NN8_STATUS, NN8_QTDFIX, NN8_QTDENT ' })	
	Local oModel      := FWLoadModel( "OGA335" )
	Local oView       := FWFormView():New()
	Local lBROWSER    := IsInCallStack( "OG335CBRW" )

	If lBROWSER
		oStruNNY:RemoveField("NNY_CODCTR")
		oStruNNY:RemoveField("NNY_ENTORI")
		oStruNNY:RemoveField("NNY_LOJORI")
		oStruNNY:RemoveField("NNY_ENTDES")
		oStruNNY:RemoveField("NNY_LOJDES")
		oStruNNY:RemoveField("NNY_TIPENT")
		oStruNNY:RemoveField("NNY_ENTREG")
	EndIf
	
	If !Empty( __cCodCtr ) .OR. lBROWSER
		oStruNNW:SetProperty( "NNW_CODCTR" , MVC_VIEW_CANCHANGE , .F. ) 
	EndIf
	
	If (!Empty( __cCodCtr ) .and. __lnewNeg) .or. lBROWSER //somente se novo negócio/via browser
		oStruNNW:SetProperty( "NNW_TIPO"  , MVC_VIEW_CANCHANGE, .F.  )		
	EndIf	

	oStruNNW:RemoveField("NNW_QUSUAR")

	oStruNNW:SetProperty( "NNW_SEQ" , MVC_VIEW_CANCHANGE , .F. ) 

	oView:SetModel( oModel )

	oView:AddField( "VIEW_NNW", oStruNNW, "NNWUNICO" )
	
	If AGRColPos('NNW_CODROM') //12.1.17 projeto SJC - dicionario diferencial de outubro aplicado
		oView:AddUserButton(STR0042 ,'',{|| fOG335VROM() } )      //"Romaneios"
	EndIf
	
	If lBROWSER
		
		If cPaisLoc == "PAR" //Paraguai
			oView:AddGrid( "VIEW_NNY", oStruNNY, "NNYUNICO" )
			oView:AddGrid( "VIEW_NN8", oStruNN8, "NN8UNICO" )

			oStruNNY:AddField("TMP_QTDALT", "07", "Qtd. Alterar", "Quantidade Alterada" , {},TamSx3('NNY_QTDINT')[3],PesqPict("NNY","NNY_QTDINT") ,Nil,Nil,.T.,"1",Nil,Nil,Nil,Nil,.T.)     
			oStruNNY:AddField("TMP_QTDTOT", "08", "Qtd. Total  ", "Qunatidade Total"    , {},TamSx3('NNY_QTDINT')[3], PesqPict("NNY","NNY_QTDINT") ,Nil,Nil,.T.,"1",Nil,Nil,Nil,Nil,.T.)    
			
			oStruNN8:AddField("TMP_QTDFIX", "10" , "Cantidad a cambiar ", "Cantidad a cambiar"    , {},TamSx3('NN8_QTDFIX')[3], PesqPict("NN8","NN8_QTDFIX") ,Nil,Nil,.T.,"1",Nil,Nil,Nil,Nil,.T.)    

			oView:AddIncrementField( "VIEW_NNY", "NNY_ITEM" )

			oView:CreateVerticallBox( "TELANOVA" , 100 )
			oView:CreateHorizontalBox( "SUPERIOR" , 30, "TELANOVA" )
			oView:CreateHorizontalBox( "MEIO" , 40, "TELANOVA" )
			oView:CreateHorizontalBox( "INFERIOR" , 30, "TELANOVA" )

			oView:SetOwnerView( "VIEW_NNW", "SUPERIOR" )
			oView:SetOwnerView( "VIEW_NNY", "MEIO" )
			oView:SetOwnerView( "VIEW_NN8", "INFERIOR" )

			oView:EnableTitleView( "VIEW_NNW" )
			oView:EnableTitleView( "VIEW_NNY" )
			oView:EnableTitleView( "VIEW_NN8" )

		Else
		
			oView:AddGrid( "VIEW_NNY", oStruNNY, "NNYUNICO" )

			oStruNNY:AddField("TMP_QTDALT", "07", "Qtd. Alterar", "Quantidade Alterada" , {},TamSx3('NNY_QTDINT')[3],PesqPict("NNY","NNY_QTDINT") ,Nil,Nil,.T.,"1",Nil,Nil,Nil,Nil,.T.)     
			oStruNNY:AddField("TMP_QTDTOT", "08", "Qtd. Total  ", "Qunatidade Total"    , {},TamSx3('NNY_QTDINT')[3], PesqPict("NNY","NNY_QTDINT") ,Nil,Nil,.T.,"1",Nil,Nil,Nil,Nil,.T.)    

			oView:AddIncrementField( "VIEW_NNY", "NNY_ITEM" )

			oView:CreateVerticallBox( "TELANOVA" , 100 )
			oView:CreateHorizontalBox( "SUPERIOR" , 50, "TELANOVA" )
			oView:CreateHorizontalBox( "INFERIOR" , 50, "TELANOVA" )

			oView:SetOwnerView( "VIEW_NNW", "SUPERIOR" )
			oView:SetOwnerView( "VIEW_NNY", "INFERIOR" )
		
		EndIf
	EndIf
	oView:SetCloseOnOk( {||.t.} )
Return( oView )

/** {Protheus.doc} OGA335VLDB
Validar o código do contrato e retornar a próxima sequencia do item

@param:     Nil
@return:    .T. / .F.
@author:    Equipe Agroindustria
@since:     08/06/2010
@Uso:       OGA335
*/
Function OGA335VLDB( )
	Local aAreaAtu  	:= GetArea()
	Local oModel        := FWModelActive()
	Local oModeLNNW     := oModel:GetModel("NNWUNICO")
	Local cCodCtr       := oModeLNNW:GetValue( "NNW_CODCTR" )
	Local lContinua		:= .t.
	Local cNeg          := ""

    If !(FWIsInCallStack("OGX700CAQC")) .and. !(FWIsInCallStack("OGX700QCTR"))  
    	If oModelNNW:GetValue("NNW_TIPO") ="2"
    		cNeg := Posicione("NJR", 1, xFilial("NJR") + oModelNNW:GetValue("NNW_CODCTR"), "NJR_CODNGC")
    		If ! Empty(cNeg)
    			Help("",1,"OGA335TIPO ") //Não é permitido suprimir contratos que possuem  registro de negócio. .
    			Return .F.
    		EndIf 
    	EndIf
    EndIf

	IF .Not. ExistCpo( 'NJR', cCodCtr )
		lContinua := .f.
	ElseIF ! Oga335VldC( cCodCtr )   //Contrato com Modelo Automatico n. pode ser alterado
		lContinua := .f.
	ElseIF ! OGA335VLDA()  			// Contrato Faz Parte de Acordo de Trocas e n. pode ser alterado...
		lContinua := .f.
	ElseIf !VLDALTCTR(cCodCtr)
		oModelNNW:LoadValue( "NNW_CODCTR" , "")
		Return( .F. )
	EndIf
	
	IF lContinua
		FIniNNWSeq()  				//Inicializa o Sequencial NNW_SEQ
	EndIF

	RestArea( aAreaAtu )
Return( lContinua )


/** {Protheus.doc} ValQTDALT

@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Vinicius Pagung
@since:     08/01/2016
@Uso:       OGA335 - Alteracao de Contrato
*/
Static Function ValQTDALT( cCodigo, cTipo, nQtdAlt )
	Local aAreaAtu  := GetArea()
	Local lRetorno  := .t.
	Local nQtdCtr   := 0
	Local nQtalocada := 0
	Local nQtdFree  :=0

	If cTipo =='2'//Essa verificação abaixo, só é necessário se for supressão.
		NJR->( dbSetOrder( 1 ) )
		If NJR->( dbSeek( xFilial( "NJR" ) + cCodigo ) )
			IF NJR->NJR_TIPO == '1'//CTR COMPRA
				AGRIFDBSEEK("NKB",cCodigo,1,.f.)
			ElseIf NJR->NJR_TIPO == '2'//CTR VENDA
				AGRIFDBSEEK("NKB",cCodigo,3,.f.)
			EndIf
			IF NKB->( DbSeek( FwXFilial('NKB') + NJR->(NJR_CODCTR)))//Busca na tabela as quantidades vinculadas do contrato.
				While NKB->(! Eof() )                                                                                                        
					nQtalocada += NKB->NKB_QTDADE
					NKB->( DbSkip() )
				EndDo
			EndIf 

			nQtdFree := NJR->( NJR_QTDCTR )- nQtalocada //VERIFICA QUANTIDADE LIVRE NO CONTRATO.

			If nQtdFree < nQtdAlt
				lRetorno := .f.
				Help( , , STR0015, , STR0038, 1, 0 ) //"AJUDA"###"Quantidade Indisponivel, Verifique os Vinculos do Contrato."
			Else  // 
				nQtdCtr := nQtdFree - nQtdAlt
			EndIf

			If NJR->( NJR_TIPO ) $ "1|3"
				If nQtdCtr < ( NJR->( NJR_QTEFIS ) - NJR->( NJR_QTSFIS ) ) .Or. nQtdCtr < ( NJR->( NJR_QTEFCO ) - NJR->( NJR_QTSFCO ) )
					lRetorno := .f.
					Help( , , STR0015, , STR0016, 1, 0 ) //"AJUDA"###"Quantidade não permitida para a movimentação existente no contrato."
				EndIf
			ElseIf NJR->( NJR_TIPO ) $ "2|4"
				If nQtdCtr < ( NJR->( NJR_QTSFIS ) - NJR->( NJR_QTEFIS ) ) .Or. nQtdCtr < ( NJR->( NJR_QTSFCO ) - NJR->( NJR_QTEFCO ) )
					lRetorno := .f.
					Help( , , STR0015, , STR0016, 1, 0 ) //"AJUDA"###"Quantidade não permitida para a movimentação existente no contrato."
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea( aAreaAtu )
Return( lRetorno )

/** {Protheus.doc} Oga335VldA
Rotina de Validação, ref. ao processo de Troca,
Verifica se o Ctrato não Faz Parte de um processo de Troca,
(Não poderei alterar um Ctrato que faz parte de um Ctrato de Troca )

@param:     NIL
@author:    E.coelho
@since:     27/01/2015
@Uso:       SIGAAGR
*/
Function  Oga335VldA( )
	Local aAreaAtu          := GetArea()
	Local oModel            := FWModelActive()
	Local oModeLNNW         := oModel:GetModel("NNWUNICO")
	Local cNnwCodCtr        := oModelNNW:GetValue("NNW_CODCTR")
	Local lContinua         := .t.

	If AliasInDic("NKT") //-- Tabela ref. ao Processo de Troca --//
		dbSelectArea( "NKT" )
		NKT->( dbSetOrder( 2 ) ) //NKT_FILIAL+NKT_CODCTR
		IF NKT->( dbSeek( fWxFilial( "NKT" ) + cNnwCodCtr) .and. EMPTY(NKT_NUMPED))
			Help(,1, STR0015,,STR0022 + NKT->NKT_TRCNUM , 1, 0 )
			lContinua := .f.
		EndIF
	EndIF

	RestArea (aAreaAtu )
Return ( lContinua )

/** {Protheus.doc} Oga335VldC
Rotina de Validação, de contratos do tipo Automatico
Contratos do tipo automatico não podem sofrer,Aditação /
Supressão. 

@param:     cCodCTR -> codigo do Contrato a analisar o tipo
@author:    E.coelho
@since:     27/01/2015
@Uso:       SIGAAGR
*/
Function  Oga335VldC( cCodCtr )
	Local aAreaAtu          := GetArea()
	Local lContinua         := .t.

	NJR->( dbSetOrder( 1 ) )
	If NJR->( dbSeek( xFilial( "NJR" ) + cCodCtr ) )
		IF NJR->NJR_MODELO == "3"   				// Tratamento para modelo de contrato Automatico
			Help(,1, STR0015,,STR0040 , 1, 0 )		// #Ajuda #"Não é permitido gerar Aditação/Supressão para contrato automático"
			lContinua := .f.
		EndIF
	EndIF

	RestArea (aAreaAtu )
Return ( lContinua )



/** {Protheus.doc} VldTpMtv
Rotina de Validação do tipo de motivo e tipo da alteração.

@param:     NIL
@author:    Equipe Agroindustria
@since:     01/07/2015
@Uso:       SIGAAGR
*/
Function  VldTpMtv(callFld)
	Local aAreaAtu          := GetArea()
	Local oModel            := FWModelActive()
	Local oModeLNNW         := oModel:GetModel("NNWUNICO")
	Local cNnwCodMtv        := oModelNNW:GetValue("NNW_CODMTV")
	Local cNnwTipo          := oModelNNW:GetValue("NNW_TIPO")
	Local cExced            := IIf (AGRColPos('NNW_CODROM') , oModelNNW:GetValue("NNW_ADEXCE"), '')  //12.1.17 projeto SJC - dicionario diferencial de outubro aplicado
	Local lContinua         := .t.
	Local cNeg              := ""
	
	If !(FWIsInCallStack("OGX700CAQC")) .and. !(FWIsInCallStack("OGX700QCTR"))  
		If "NNW_TIPO" $ Readvar()
			If lRet := Pertence("1|2")
				If oModelNNW:GetValue("NNW_TIPO") ="2"
					cNeg := Posicione("NJR", 1, xFilial("NJR") + oModelNNW:GetValue("NNW_CODCTR"), "NJR_CODNGC")
		            If ! Empty(cNeg)
		                Help("",1,"OGA335TIPO ") //Não é permitido suprimir contratos que possuem  registro de negócio. .
		                Return .F.
		            EndIf 
		         EndIf
		    EndIf
		EndIf
	EndIf
	
	dbSelectArea( "NNQ" )

	if callFld == "NNW_TIPO" 
		if  empty(cNnwTipo) 
			Help(,1, STR0015,,STR0023 , 1, 0 ) //AJUDA ## "O Tipo da Alteração do Contrato é um campo obrigatório."                                                                                                                                                                                                                                                                                                                                                                                                                                                          
			lContinua := .f.
		elseif  .not. (cNnwTipo == "1" .or. cNnwTipo == "2") 
			Help(,1, STR0015,,STR0024 , 1, 0 ) //AJUDA ## "O Tipo da Alteração é inválido"
			lContinua := .f.
		endif
	endif

	if callFld == "NNW_CODMTV" 
		if  empty(cNnwCodMtv) 
			Help(,1, STR0015,,STR0025, 1, 0 ) //AJUDA ## "O Motivo da Alteração do Contrato é um campo obrigatório."
			lContinua := .f.
		elseif  .not.  NNQ->( dbSeek( fWxFilial( "NNQ" ) + cNnwCodMtv ))
			Help(,1, STR0015,,STR0026 , 1, 0 )  //AJUDA ## "O Motivo da Alteração é inválido."
			lContinua := .f.
		endif
		If AGRColPos('NNW_CODROM') //12.1.17 projeto SJC - dicionario diferencial de outubro aplicado
			if lContinua .And. (NNQ->NNQ_ADEXCE == '1' .And. cExced == '2')
				Help(,1, STR0015,,STR0041 , 1, 0 )  //AJUDA ## "O Motivo da Alteração só pode ser utilizado por Excedente de Carga."
				lContinua := .f.
			EndIf
		EndIf
	endif

	if lContinua
		IF .not. empty(cNnwCodMtv) .and. .not. empty(cNnwTipo) //se tem dados vai para a validação
			IF NNQ->( dbSeek( fWxFilial( "NNQ" ) + cNnwCodMtv ) )
				IF NNQ->NNQ_TIPO != cNnwTipo
					Help(,1, STR0015,,STR0027 , 1, 0 ) //AJUDA ## "O Tipo do Motivo da alteração é diferente do Tipo da Alteração do Contrato"  
					lContinua := .f.
				ENDIF   
			ENDIF
		ENDIF
	endif

	RestArea (aAreaAtu )
Return ( lContinua )

/** {Protheus.doc} fvldModelo
@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Equipe Agroindustria
@since:     08/06/2010
@Uso:       OGA335 - Alteracao de Contrato
*/
Static Function fvldModelo( oModel, nOperation )
	Local lRetorno  := .t.
	
	If nOperation != MODEL_OPERATION_VIEW 
       	If !Empty(__cCodCtr)
       		lRetorno := VLDALTCTR( __cCodCtr )
       	ElseIf nOperation != MODEL_OPERATION_INSERT
       		lRetorno := VLDALTCTR( NNW->(NNW_CODCTR) )
       	EndIf
    EndIf	

	If lRetorno .and. nOperation == MODEL_OPERATION_UPDATE
		If NNW->( NNW_STATUS ) = "2"
			lRetorno := .f.
			Help( , , STR0015, , STR0017, 1, 0 ) //"AJUDA"###"Somente Aditações/Supressões -Previstas- podem ser alteradas."
		EndIf
	EndIf

	If lRetorno .and. nOperation == MODEL_OPERATION_DELETE
		If NNW->( NNW_STATUS ) = "2"
			lRetorno := .f.
			Help( , , STR0015, , STR0018, 1, 0 ) //"AJUDA"###"Somente Aditações/Supressões -Previstas- podem ser excluidas."
		EndIf
	EndIf
	
Return( lRetorno )

/** {Protheus.doc} IniModelo
@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Vinicius Becher Pagung
@since:     20/01/2016
@Uso:       OGA335 - Alteracao de Contrato
*/
Static Function IniModelo( oModel, nOperation )
	Local lRetorno  := .t.
	Local lBROWSER  := IsInCallStack( "OG335CBRW" )
	Local oModelNNY := oModel:GetModel("NNYUNICO")
	Local nQtdAuto  := NNW->NNW_QTDALT
	Local nTotTemp  := 0
	
	/*Gatilha a quantidade da alteração, caso possuir apenas uma cadência.*/
	IF lRetorno .and. nOperation == MODEL_OPERATION_UPDATE
		If lBROWSER
			nTotTemp := fWfldGet( "NNY_QTDINT" )   
			If .Not. oModelNNY:IsDeleted()
				IF oModelNNY:Length() == 1
					If NNW->NNW_TIPO == "1"  
						nTotTemp += nQtdAuto
						oModelNNY:LoadValue("TMP_QTDALT", nQtdAuto)
						oModelNNY:LoadValue("TMP_QTDTOT", nTotTemp )//Soma e mostra o total da cadencia na tabela total temporaria.   
					ElseIf NNW->NNW_TIPO == "2"
						nTotTemp -= nQtdAuto
						oModelNNY:LoadValue("TMP_QTDALT", nQtdAuto)
						oModelNNY:LoadValue("TMP_QTDTOT", nTotTemp )//Subtrai e mostra o total da cadencia na tabela total temporaria. 
					EndIf   
				EndIf
			EndIf
		EndIf
	EndIf

Return( lRetorno )

/** {Protheus.doc} GrvModelo


@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Vinicius Becher Pagung
@since:     20/01/2016
@Uso:       OGA335 - Alteracao de Contrato
*/
Static Function GrvModelo( oModel )
	Local oModelNNY := oModel:GetModel("NNYUNICO")
	Local nLinha    := 0
	Local nX        := 0 
	Local lConfirma := IsInCallStack( "OG335CBRW" ) .or. IsInCallStack( "OGX700CAQC" )
	Local nIt := 0 
	Local lRetorno := .T.
	
	If lConfirma
		//grava os dados no contrato
		if !OGA335C() 
     		oModel:SetErrorMessage('OGA335', 'NNY_QTDINT' , 'NNYUNICO' , 'NNY_QTDINT' , STR0015, STR0052, STR0053)   
			Return( .F. )
		endif

		/*Caso a supressão deixar a cadência zerada, deletar linha cadência.*/
		nLinha := oModelNNY:GetLine()
		For nX := 1 to oModelNNY:Length()
			oModelNNY:GoLine( nX )
			If .Not. oModelNNY:IsDeleted()
				If oModelNNY:GetValue( "NNY_QTDINT" ) == 0 
					oModelNNY:SetNoDelete(.F.)
					oModelNNY:DeleteLine()
				EndIf
			EndIf
		Next nX
		
		oModelNNY:GoLine( nLinha )
	EndIf  
	
	FWFormCommit( oModel )	
	BEGIN TRANSACTION
	/*Força o recalculo das previsões*/
	If lConfirma 
		//Posicionamos na NJR
		DbselectArea( "NJR" )
		NJR->(DbGoTop())
		NJR->(dbSetOrder(1))
		if NJR->(dbSeek(FwXFilial("NJR")+oModel:GetValue("NNWUNICO","NNW_CODCTR")))
		
			if !empty(NJR->NJR_CODNGC) .and. !empty(NJR->NJR_VERSAO)
				
				oModelNJR := FWLoadModel( 'OGA290' )
				oModelNJR:SetOperation( 4 ) //atualizar
				
				For nIt := 1 To Len(oModelNJR:aAllSubModels)
					oModelNJR:aAllSubModels[nIt]:GetStruct():SetProperty( "*", MODEL_FIELD_OBRIGAT, .F.  )
					oModelNJR:aAllSubModels[nIt]:GetStruct():SetProperty( "*", MODEL_FIELD_WHEN, {| oField | .T. } ) 
				Next nIt
											
				// Antes de atribuirmos os valores dos campos temos que ativar o modelo
				oModelNJR:Activate()
				If oModelNJR:GetValue("NJRUNICO","NJR_QTDCTR") > 0
					lRet := OGX018(oModelNJR:GetValue("NJRUNICO","NJR_FILIAL"), oModelNJR:GetValue("NJRUNICO","NJR_CODCTR"), .t., oModelNJR )
					if lRet									
						If ( lRet := oModelNJR:VldData() ) 				
							lRet := oModelNJR:CommitData()	  					
						else
							OGX700ERRO(oModelNJR)
						EndIf						
					endif
					
					if !lRet						
						lRetorno := .f.
						DisarmTransaction()
					endif	
				EndIf
			endif
			
		endif
		
	endif	
	END TRANSACTION
Return( lRetorno )


/** {Protheus.doc} OGA335C
Rotina para que confirmação da alteracao do contrato.

@param:     Nil
@author:    Equipe Agroindustria
@since:     08/06/2010
@Uso:       SIGAARM - Originação de Grãos
*/
Function OGA335C( cAlias, nReg, nAcao )
	Local aAreaAtu    := GetArea()
	Local aAreaNJR    := NJR->( GetArea()  )
	Local cCodCtr     := NNW->( NNW_CODCTR )
	Local cTipo       := NNW->( NNW_TIPO   )
	Local nQuant      := NNW->( NNW_QTDALT )
	Local nQtdCtrOg   := 0
	Local lContinua   := .t.
	Local nRet        := 1
	Local cCodNgc := IIF(ColumnPos("NJR_CODNGC"),NJR->(NJR_CODNGC),"")
	Local cVersao := IIF(ColumnPos("NJR_VERSAO"),NJR->(NJR_VERSAO),"")

	IF lContinua
		If AliasInDic("NKT") //-- Tabela ref. ao Processo de Troca --//
			dbSelectArea( "NKT" )
			NKT->( dbSetOrder( 2 ) ) //NKT_FILIAL+NKT_CODCTR
			IF NKT->( dbSeek( fWxFilial( "NKT" ) + cCodCtr )  .and. EMPTY(NKT_NUMPED))
				Help(,, STR0015,,STR0028 + NKT->NKT_TRCNUM , 1, 0 )
				lContinua := .f.
			EndIF
		EndIF
	EndIF

	if lContinua
		if .not. ValQTDALT(cCodCtr, cTipo, nQuant) //refaz o calculo, pode ter entrado alguma entrega
			lContinua := .f.
		elseif .not. VldFixQtd(cTipo, cCodCtr, nQuant) //valida as fixações
			lContinua := .f.    
		EndIF
	endif

	//-- PE para Validações  --//
	IF lContinua .And. ( (ExistBlock("OG335COK")) )
		If (! ExecBlock("OG335COK",.F.,.F.) )
			lContinua   := .F.
		EndIf
	EndIf
	//-------------------------------------//

	IF lContinua

		dbSelectArea( "NJR" ) // Contratos
		dbSetOrder( 1 )
		If dbSeek( xFilial( "NJR" ) + cCodCtr )			
			
			If FWISINCALLSTACK('A094Commit') .or. FWISINCALLSTACK("OGX700CANC") //via aprovação de alçada - multa
				nRet := AGRGRAVAHIS(STR0019,,,,{"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR,IIf(cTipo = "1","A","S"),STR0046}) //"Alteração do contrato. Cancelamento de quantidade."                                                                                                                                                                                                                                                                                                                                                                                                                                                                
			Else
				nRet := AGRGRAVAHIS(STR0019,"NJR",NJR->NJR_FILIAL+NJR->NJR_CODCTR, IIf(cTipo = "1","A","S")) 
			EndIf			

			If nRet = 1  //"Deseja confirmar esta alteração?"   
				BEGIN TRANSACTION

					//salva a quantidade original
					nQtdCtrOg := NJR->NJR_QTDCTR
					// Atualiza status da alteração
					If RecLock( "NNW", .f. )
						NNW->( NNW_STATUS ) := "2"
						NNW->(NNW_QUSUAR  ) := UsrRetName(RetCodUsr())
						NNW->( MsUnLock() )
					EndIf
					
					// Atualiza quantidades do contrato de acordo com as aditações / supressões
					OGA335AtuQtd()

					//atualiza as fixações
					if empty(cCodNgc) .and. empty(cVersao)
						OGA335UpFx(cTipo, nQtdCtrOg,nQuant)
					endif
						
					// Atualiza qtdes do contrato e saldos
					OGX010QTDS()

					// Atualiza autorizações
					OGX010QAut()

					// Atualiza Previsão financeira
					if empty(cCodNgc) .and. empty(cVersao)
						OGA250ATUF( cCodCtr, nQuant, cTipo )
					endif
					
					//Se for troca pedido coloca status como pendente
					if empty(cCodNgc) .and. empty(cVersao)
						dbSelectArea( "NKT" )
						NKT->( dbSetOrder( 2 ) ) //NKT_FILIAL+NKT_CODCTR
						IF NKT->( dbSeek( fWxFilial( "NKT" ) + NJR->NJR_CODCTR) .and. !EMPTY(NKT_NUMPED))
							StatusNKT('01')
						EndIF
					endif	
					
					
				END TRANSACTION
			Else
				lContinua := .F.
			endif               
		Else
			Help( , , STR0015, , STR0021 + Chr(10) + Chr(13) + "[ " + xFilial( "NJR" ) + " - " + cCodCtr + " ]", 1, 0 ) //"AJUDA"###"Contrato não localizado na tabela de contratos (NJR)."
		EndIf


	EndIF
	

	RestArea( aAreaNJR )
	RestArea( aAreaAtu )
Return lContinua


/** {Protheus.doc} OGA335AtuQtd
Rotina para atualização das quantidades do contrato de acordo com as aditações / supressões.

@param:     NIL
@author:    Marlon Richard Trettin
@since:     27/01/2015
@Uso:       SIGAAGR
*/
Function OGA335AtuQtd() 
	Local nQtdAlt := 0
	Local cCodCtr := NJR->( NJR_CODCTR )
	Local cSeqCtr := "000"
	Local nVlrTot := NJR->( NJR_VLRTOT )
	Local nPrcInt := 0
	Local nTotFin := 0
	Local cCodNgc := IIF(ColumnPos("NJR_CODNGC"),NJR->(NJR_CODNGC),"")
	Local cVersao := IIF(ColumnPos("NJR_VERSAO"),NJR->(NJR_VERSAO),"")
	
	If !Empty(NJR->( NJR_ULTALT ))
		cSeqCtr := NJR->( NJR_ULTALT )
	EndIf  
	
	// Calcula a qtde de aditações / supressões
	dbSelectArea( "NNW" ) // Aditações / Supressões
	dbSetOrder( 1 ) //NNW_FILIAL+NNW_CODCTR+NNW_SEQ
	If dbSeek( xFilial( "NNW" ) + cCodCtr )
		While .Not. NNW->( Eof() ) .And. NNW->( NNW_FILIAL + NNW_CODCTR ) == xFilial( "NNW" ) + cCodCtr

			If NNW->( NNW_STATUS ) == "2" // Se estiver confirmada

				If NNW->( NNW_TIPO ) == "1"         // Aditação 
					nQtdAlt += NNW->( NNW_QTDALT )
				ElseIf NNW->( NNW_TIPO ) == "2"     // Supressão
					nQtdAlt -= NNW->( NNW_QTDALT )
				EndIf
				cSeqCtr := NNW->( NNW_SEQ )

			EndIf

			NNW->( DbSkip() )
		EndDo
	EndIf

	// Atualiza o contrato
	If RecLock( "NJR", .f. )
		If !Empty(cSeqCtr) .And. cSeqCtr <> " "
			NJR->( NJR_ULTALT ) := cSeqCtr
		EndIF
		NJR->( NJR_QTDCTR ) := NJR->( NJR_QTDINI ) + nQtdAlt

		//--<< Aplicar no calculo a conversão da unidade de medida
		//--<< Utilizar NJR_QTDCTR para considerar os aditivo caso houver
		NJR->( NJR_VLRTOT ) := Round( NJR->NJR_QTDCTR * AGRX003( NJR->NJR_CODPRO, NJR->NJR_UMPRC, NJR->NJR_VLRUNI, TamSX3('NJR_VLRUNI')[2]), TamSX3('NJR_VLRTOT')[2])

		msUnLock()
	EndIf


	// Atualiza dados do financeiro do contrato
	if empty(cCodNgc) .and. empty(cVersao)
		dbSelectArea( "NN7" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "NN7" ) + cCodCtr )
			While .Not. NN7->( Eof() ) .And. NN7->( NN7_FILIAL + NN7_CODCTR ) == xFilial( "NN7" ) + cCodCtr
				nPrcInt := ( NN7->( NN7_VALOR ) / nVlrTot ) * 100
				If RecLock( "NN7", .f. )
					NN7->( NN7_VALOR ) := Round( ( ( NJR->NJR_VLRTOT * nPrcInt ) / 100 ) , TamSX3( "NN7_VALOR" )[2] )
					nTotFin            += NN7->( NN7_VALOR ) 
					msUnLock()
					
				EndIf
	
				NN7->( dbSkip() )
			EndDo
	
			/*Corrige centavo faltante*/
			if nTotFin <> NJR->NJR_VLRTOT 
				dbSelectArea( "NN7" )
				dbSetOrder( 1 )
				if dbSeek( xFilial( "NN7" ) + cCodCtr )
					If RecLock( "NN7", .f. )
						NN7->( NN7_VALOR ) += (NJR->NJR_VLRTOT - nTotFin) //soma o valor que faltou para completar o valor total
						msUnLock()
					EndIf
				endif    
			endif
	
		EndIf
	endif
Return NIL

/** {Protheus.doc} OGA335UpFx
Rotina para atualização das fixações do contrato de acordo com as aditações / supressões.

@param:     cNNWTipo
@author:    Equipe Agroindustria
@since:     01/07/2015
@Uso:       SIGAAGR
*/
Static Function OGA335UpFx(cNNWTipo, nQtdOrig,nQuant)
	Local nQtdFix   := 0 //quantidade de fixações
	local cAliasNN8 := GetNextAlias()
	local cQueryNN8 := ""
	Local lPar := .F. 

	//define query base das fixações
	cQueryNN8 := "SELECT * "
	cQueryNN8 +=   " FROM "+ RetSqlName("NN8") + " NN8 "
	cQueryNN8 +=  " WHERE NN8.D_E_L_E_T_ = ' '"
	cQueryNN8 +=    " AND NN8.NN8_FILIAL = '" + xFilial( 'NN8' ) + "'"  
	cQueryNN8 +=    " AND NN8.NN8_CODCTR = '" + NJR->NJR_CODCTR + "'"     


	if cNNWTipo == "1" //adição

		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryNN8),cAliasNN8,.T.,.T.) //area de trabalho 
		dbSelectArea(cAliasNN8)        
		
		nQtdFix := OG335CTFIX(NJR->NJR_CODCTR)
		
		if NJR->( NJR_TIPFIX ) == "1" //Fixo  
			if cPaisLoc == "PAR"
				lPar := .T.
				(cAliasNN8)->(dbGoTop())            
				if (cAliasNN8)->(!Eof())    
					//alterar a quantidade da fixacao prevista
					UpdFixQtd((cAliasNN8)->NN8_CODCTR ,(cAliasNN8)->NN8_ITEMFX) //atualiza os valores da fixacao
				endif   

			else  
				(cAliasNN8)->(DbGoTop())            
				if (cAliasNN8)->(!Eof())   
					if nQtdFix = 1 .and. (cAliasNN8)->NN8_QTDFIX = nQtdOrig //a mesma quantidade
						UpdFixQtd((cAliasNN8)->NN8_CODCTR ,(cAliasNN8)->NN8_ITEMFX) //atualiza os valores da fixacao
					endif
				endif
			Endif
		elseif NJR->( NJR_TIPFIX ) == "2" //Fixar
			if cPaisLoc == "PAR"
				lPar := .T.
				(cAliasNN8)->(dbGoTop())            
				if (cAliasNN8)->(!Eof())    
					//alterar a quantidade da fixacao prevista
					UpdFixQtd((cAliasNN8)->NN8_CODCTR ,(cAliasNN8)->NN8_ITEMFX) //atualiza os valores da fixacao
				endif   

			else  
				(cAliasNN8)->(DbGoTop())            
				if (cAliasNN8)->(!Eof())    
					if nQtdFix = 1 .and. (cAliasNN8)->NN8_TIPOFX = "0" //alterar a quantidade da fixacao prevista
						UpdFixQtd((cAliasNN8)->NN8_CODCTR ,(cAliasNN8)->NN8_ITEMFX) //atualiza os valores da fixacao
					endif
				endif   
			Endif
		elseif NJR->( NJR_TIPFIX ) == "3" //Basis

			lPar := .T.
			(cAliasNN8)->(dbGoTop())            
			if (cAliasNN8)->(!Eof())    
				//alterar a quantidade da fixacao prevista
				UpdFixQtd((cAliasNN8)->NN8_CODCTR ,(cAliasNN8)->NN8_ITEMFX) //atualiza os valores da fixacao
			endif   


		endif

		(cAliasNN8)->( dbCloseArea() )      

	elseif cNNWTipo == "2" //supressao
		if NJR->( NJR_TIPFIX ) == "1" //Fixo AND contador = 1 e fixado = contrato

			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryNN8),cAliasNN8,.T.,.T.) //area de trabalho  
			dbSelectArea(cAliasNN8)       
			nQtdFix := OG335CTFIX(NJR->NJR_CODCTR) //contagem de dados			

			(cAliasNN8)->(DbGoTop())            
			if (cAliasNN8)->(!Eof())    
				if nQtdFix = 1 .and. (cAliasNN8)->NN8_QTDFIX = nQtdOrig //a mesma quantidade
					UpdFixQtd((cAliasNN8)->NN8_CODCTR ,(cAliasNN8)->NN8_ITEMFX) //atualiza os valores da fixacao
				endif
			endif

			(cAliasNN8)->( dbCloseArea() )      

		elseif NJR->( NJR_TIPFIX ) == "2" //Fixar e previsto aberto
			//seleciona o previsto
			cQueryNN8 +=    " AND NN8.NN8_TIPOFX = '0' "    
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryNN8),cAliasNN8,.T.,.T.) //area de trabalho
			dbSelectArea(cAliasNN8)
			nQtdFix := OG335CTFIX(NJR->NJR_CODCTR,'0') //contagem de dados previsto

			(cAliasNN8)->(DbGoTop())            
			if (cAliasNN8)->(!Eof()) 
				if nQtdFix = 1 .and. (cAliasNN8)->NN8_QTDFIX = nQtdOrig //a mesma quantidade
					If cPaisLoc == "PAR"
						CalcFixcao()
					Else
						UpdFixQtd((cAliasNN8)->NN8_CODCTR ,(cAliasNN8)->NN8_ITEMFX)
					EndIf
				endif
			endif
			(cAliasNN8)->( dbCloseArea() )  
		endif   
	endif       

return 

/** {Protheus.doc} UpdFixQtd
Rotina para atualização das fixações do contrato de acordo com as aditações / supressões.

@param:     cNNWTipo
@author:    Equipe Agroindustria
@since:     01/07/2015
@Uso:       SIGAAGR
*/
Static Function UpdFixQtd(cCodCtr, cItemFx)
	//altera a quantidade da fixacao
	dbSelectArea( "NN8" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "NN8" ) + cCodCtr + cItemFx  )

		If RecLock( "NN8", .f. ) //conforme OGA280 e OGA290
			NN8->( NN8_QTDFIX ) := NJR->( NJR_QTDCTR )

			if NJR->( NJR_TIPO ) == "1" //compras
				NN8->( NN8_VLRTOT ) := Round( NN8->( NN8_VLRUNI ) * AGRX001( NJR->NJR_UM1PRO, NJR->NJR_UMPRC, NN8->( NN8_QTDFIX ), NJR->NJR_CODPRO ) ,2 )
				NN8->( NN8_VALTOT ) := Round( NN8->( NN8_VALUNI ) * AGRX001( NJR->NJR_UM1PRO, NJR->NJR_UMPRC, NN8->( NN8_QTDFIX ), NJR->NJR_CODPRO ) ,2 )
			elseif NJR->( NJR_TIPO ) == "2" //vendas    
				NN8->( NN8_VLRTOT ) := Round( NN8->( NN8_QTDFIX ) * AGRX003( NJR->NJR_CODPRO, NJR->NJR_UMPRC, NN8->NN8_VLRUNI, TamSX3('NJR_VLRUNI')[2]), TamSX3('NN8_VLRTOT')[2]) 
				NN8->( NN8_VALTOT ) := Round( NN8->( NN8_QTDFIX ) * AGRX003( NJR->NJR_CODPRO, NJR->NJR_UMPRC, NN8->NN8_VALUNI, TamSX3('NJR_VLRUNI')[2]), TamSX3('NN8_VALTOT')[2])
			endif           
			msUnLock()
		EndIf

	endif
return
/** {Protheus.doc} VldFixQtd
Rotina para atualização das fixações do contrato de acordo com as aditações / supressões.

@param:     cNNWTipo
@author:    Equipe Agroindustria
@since:     01/07/2015
@Uso:       SIGAAGR
*/
Static Function VldFixQtd(cNNWTipo, cCodCtrFix, nQtdAlt)
	local cAliaNN8   := GetNextAlias()
	local nTotQtdFix := 0
	local nCountFix  := 0

	if cNNWTipo = "2" //supressão
		dbSelectArea( "NJR" ) // Contratos
		dbSetOrder( 1 )
		If dbSeek( xFilial( "NJR" ) + cCodCtrFix )

			//Query Fixações 
			BeginSql Alias cAliaNN8
			SELECT NN8.*
			FROM %Table:NN8% NN8                        
			WHERE NN8.%notDel%
			AND NN8_FILIAL  = %Exp:xFilial('NN8')%
			AND NN8_CODCTR  = %Exp:NJR->NJR_CODCTR%
			AND NN8_ITEMFX <> ''
			AND NN8_TIPOFX  = '1' //somente firme                         
			EndSQL

			DbSelectArea( cAliaNN8 )
			(cAliaNN8)->(DbGoTop())

			while !(cAliaNN8)->( Eof( ) )   
				nCountFix  += 1
				nTotQtdFix += (cAliaNN8)->NN8_QTDFIX 
				(cAliaNN8)->(Dbskip())          
			end

			if  NJR->( NJR_TIPFIX ) == "2" .or. nCountFix > 1  .or. nTotQtdFix <>  NJR->( NJR_QTDCTR ) //Se o contrato for preço a Fixar, ou contador fixação > 1, ou quantidade do contrato for <> soma fixada, validar:   
				if (NJR->( NJR_QTDCTR ) - nQtdAlt) < nTotQtdFix //Se (quantidade do contrato – quantidade a diminuir) < quantidade soma NN8, então dar mensagem, e não deixar continuar.
					Help(,, STR0015,,STR0029 , 1, 0 ) //"Supressão Não pode ser confirmada, pois o contrato já possui fixação de preço maior"                                                                                                                                                                                                                                                                                                                                   
					(cAliaNN8)->( dbCloseArea() )
					return(.f.)
				endif
			endif           
			(cAliaNN8)->( dbCloseArea() ) 
		endif       
	endif
return (.t.)

/** {Protheus.doc} FIniNNWSeq
Função que Inicializa o Cpo NNW_SEQ

@param:     Nil
@return:    Cpo atualizado
@author:    Equipe Agroindustria
@since:     19/10/2015
@Uso:       OGA335
*/
Static Function FIniNNWSeq()
	Local aAreaAtu      := GetArea()
	Local oModel        := FWModelActive()
	Local oModeLNNW     := IIF( Empty( __cCodCtr ),oModel:GetModel("NNWUNICO"),nil)
	Local cCodCtr       := ''
	Local cNovoIt       := ""

	IF Empty( __cCodCtr )
		cCodCtr := oModeLNNW:GetValue( "NNW_CODCTR" )
	Else
		cCodCtr := __cCodCtr
	Endif

	BeginSql Alias 'QryNNW'
	Select Max( NNW_SEQ ) As UltSeq
	From %Table:NNW% NNW
	Where NNW.NNW_CODCTR = %Exp:cCodCtr% 
	And NNW.NNW_FILIAL = %xFilial:NNW% 
	And NNW.%NotDel%
	EndSql

	If .Not. QryNNW->( Eof() )
		If .Not. Empty( AllTrim( QryNNW->( UltSeq ) ) )
			cNovoIt := Soma1( QryNNW->( UltSeq ) )
		Else
			cNovoIt := Soma1( Replicate( "0", TamSX3( "NNW_SEQ" )[1] ) )
		EndIf
	Else
		cNovoIt := Soma1( Replicate( "0", TamSX3( "NNW_SEQ" )[1] ) )
	EndIf
	QryNNW->( dbCloseArea( ) )

	IF Valtype(oModelNNW) == 'O'
		oModeLNNW:LoadValue( "NNW_SEQ", cNovoIt )
	EndIF

	RestArea( aAreaAtu )
Return( cNovoIt )

/** {Protheus.doc} OG335CBRW
Função que inicializa gride.

@return:    lRetorno - verdadeiro ou falso
@author:    Vinicius Becher Pagung
@since:     05/01/2016
@Uso:       OGA335 
*/
Function OG335CBRW( )

	FWExecView(STR0031,"OGA335",4,,{|| .T.})//Abre o browser e Força usuário distribuir as quantidades na cadência.

Return(  )


/**{Protheus.doc}fOG335GCTR
@return Gatilha campos conforme Necessidade.
@Este gatilho foi criado como um gatilho DUMMY, para preencher TMP_QTDTOT, que esta como X3_WHEN setado como .F.
O campo de origem deve ser o campo de destino.
@author:    Vinicius Becher Pagung
@since:     06/01/2016
@Uso:       OGA335
@version 1.0
*/
function fOG335GCTR()
	Local aAreaAtu  := GetArea()
	Local oModel    := FWModelActive()
	Local oModelNNY := oModel:GetModel("NNYUNICO")
	Local nTotTemp  := fWfldGet( "NNY_QTDINT" )

	If .Not. oModelNNY:IsDeleted()
		IF oModelNNY:Length() <> 1 //
			If NNW->NNW_TIPO == "1"      
				nTotTemp += FWfldGet( "TMP_QTDALT" )
				oModelNNY:LoadValue("TMP_QTDTOT", nTotTemp )//Soma e mostra o total da cadencia na tabela total temporaria.   
			EndIf
			If NNW->NNW_TIPO == "2"
				nTotTemp -= FWfldGet( "TMP_QTDALT" )
				oModelNNY:LoadValue("TMP_QTDTOT", nTotTemp )//Subtrai e mostra o total da cadencia na tabela total temporaria. 
			EndIf
		EndIf
	EndIf
	RestArea( aAreaAtu )

Return ( fWfldGet( "TMP_QTDALT" ) ) 


/** {Protheus.doc} ValNNYTOT

@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Vinicius Becher Pagung
@since:     07/01/2016
@Uso:       OGA335 - Alteracao de Contrato
*/
Function ValNNYTOT( )
	Local lRetorno  := .T.
	Local aAreaAtu  := GetArea()
	Local oModel    := FWModelActive()
	Local oModelNNY := oModel:GetModel("NNYUNICO")
	Local oModelNNW := oModel:GetModel("NNWUNICO")
	Local nQtalocada:= 0
	Local nSomaTot  := 0
	Local nLinha    := 0
	Local nX        := 0 
	Local nQtdFim   := 0
	Local nQtdInt    := oModelNNY:GetValue("NNY_QTDINT")
	Local cTpCtrato := ''
	Local nGetLine  := 0

	nLinha := oModelNNY:GetLine()
	For nX := 1 to oModelNNY:Length()
		oModelNNY:GoLine( nX )
		If .Not. oModelNNY:IsDeleted()
			nSomaTot += oModelNNY:GetValue( "TMP_QTDALT" )
			nGetLine := oModelNNY:GetValue( "TMP_QTDALT" )
			If nGetLine > oModelNNY:GetValue( "NNY_QTDINT" ) .and. NNW->NNW_TIPO == '2'
				Help( , , STR0015, , STR0033, 1, 0 ) //"AJUDA"###"Cadência Sem Saldo Suficiente"
				lRetorno := .F.
			EndIf
		EndIf
	Next nX
	oModelNNY:GoLine( nLinha )  

	If nSomaTot > NNW->NNW_QTDALT 
		Help( , , STR0015, , STR0032, 1, 0 ) //"AJUDA"###"A Alteração Nao Possui Saldo Suficiente"
		lRetorno := .F.
	EndIf

	If NNW->NNW_TIPO == '2' // Se for uma supressão, realizar a verificação se existem vinculos no contrato/cadencia.
		AGRIFDBSEEK("NJR",oModelNNW:GetValue("NNW_CODCTR"),1,.f.)

		/*Necessário para utilizar a função OG285CTRV*/ 
		IF NJR->NJR_TIPO == '1'
			cTpCtrato := '2'//Contrato de compra passa a ser tipo '2', pois o OG285CTRV trata o tipo 2 como Ctr compra.
		ElseIf NJR->NJR_TIPO == '2'
			cTpCtrato := '1'//contrato de venda
		EndIf
		nQtalocada := OG285CTRV(NNW->NNW_CODCTR,oModelNNY:GetValue("NNY_ITEM"), NJR->NJR_QTDINI, cTpCtrato)
		nQtdFim := nQtdInt - nQtalocada

		If oModelNNY:GetValue("TMP_QTDALT") > nQtdFim 
			Help( , , STR0015, , STR0034, 1, 0 ) //"AJUDA"###"O Cadencia não possui Saldo Suficente, Pois Se Encontra Vinculada!!!"
			lRetorno := .F.
		EndIf
	EndIf

	RestArea( aAreaAtu )
Return( lRetorno )

/** {Protheus.doc} TudoOk
@param:     oModel
@author:    Vinicius Pagung
@since:     07/01/2016
@Uso:       OGA335
*/
Static Function TudoOk( oModel )
	Local lRetorno  := .T.
	Local oModelNNY := oModel:GetModel("NNYUNICO")
	Local oModelNNW := oModel:GetModel("NNWUNICO")
	Local oModelN9A	:= Nil
	Local nSomaTot  := 0
	Local nLinha    := 0
	Local nX        := 0 
	Local nGridTot  := 0
	Local nQtalocada:= 0
	Local nQtdFim   := 0
	Local nQtdInt   := 0
	Local lConfirma := IsInCallStack( "OG335CBRW" ) .or. IsInCallStack( "OGX700CAQC" )
	Local cTpCtrato	:= ''
	Local cSeqPri	:= ""

	/*Necessário refazer o processo de verificação, caso usuário nao complete a transação no momento, pode haver alteração de contraco
	por exemplo, em caso de supressão, pode ter ocorrido um vinculo de contrato, nesse meio tempo, e o saldo pode ter ficado abaixo da alteração.*/
	If lConfirma
		nLinha := oModelNNY:GetLine()
		For nX := 1 to oModelNNY:Length()
			oModelNNY:GoLine( nX )
			If .Not. oModelNNY:IsDeleted()
				nSomaTot += oModelNNY:GetValue( "TMP_QTDALT" )
				If NNW->NNW_TIPO == '1'
					nGridTot := oModelNNY:GetValue( "NNY_QTDINT" ) + oModelNNY:GetValue( "TMP_QTDALT" )
					// Se for aditação então adiciona uma nova regra fiscal e adiciona a quantidade a mesma
					If __lnewNeg .AND. !Empty(oModelNNY:GetValue("TMP_QTDALT"))// Se possue a tabela N9A e é o novo modelo de comercialização
						oModelN9A := oModel:GetModel("N9AUNICO")
						cSeqPri := Soma1(oModelN9A:GetValue("N9A_SEQPRI", oModelN9A:Length()))

						oModelN9A:AddLine()
						oModelN9A:SetValue("N9A_SEQPRI", cSeqPri) // Incremento manual de Item
						oModelN9A:SetValue("N9A_QUANT", oModelNNY:GetValue("TMP_QTDALT"))
					EndIf
				Else
					// Validação das regras fiscais para verificação de saldo disponivel considerando regras fiscais com global futura e saldo disponivel
					If __lnewNeg .AND. !Empty(oModelNNY:GetValue("TMP_QTDALT"))// Se possue a tabela N9A e é o novo modelo de comercialização
						oModelN9A := oModel:GetModel("N9AUNICO")
						// Valida a previsão de entrega e regras fiscais para realizar a supressão, caso valido, ja realiza o fifo
						If ! (lRetorno := OGX335VTKP(oModelNNY, oModelN9A))
							Return lRetorno
						EndIf
					EndIf

					nGridTot := oModelNNY:GetValue( "NNY_QTDINT" ) - oModelNNY:GetValue( "TMP_QTDALT" )
				EndIf
				
				If NNW->NNW_TIPO == '2' // Se for uma supressão, realizar a verificação se existem vinculos no contrato/cadencia.
					AGRIFDBSEEK("NJR",oModelNNW:GetValue("NNW_CODCTR"),1,.f.)
					IF NJR->NJR_TIPO == '1'
						cTpCtrato := '2'//Contrato de compra
					ElseIf NJR->NJR_TIPO == '2'
						cTpCtrato := '1'//contrato de venda
					Else
						//Para os ctratos de Deposito em Terceiro/ Deposito de Terceiro, não existe esse vinculo
						cTpCtrato := ''        
					EndIf

					IF !Empty ( cTpCtrato ) //Indica que é um Ctato de Compra ou Venda....
						nQtalocada := OG285CTRV(NNW->NNW_CODCTR,oModelNNY:GetValue("NNY_ITEM"), NJR->NJR_QTDINI, cTpCtrato)      
						nQtdInt := oModelNNY:GetValue( "NNY_QTDINT" )
						nQtdFim := nQtdInt - nQtalocada

						If oModelNNY:GetValue("TMP_QTDALT") > nQtdFim 
							Help( , , STR0015, , STR0035, 1, 0 ) //"AJUDA"###"Houve Alteração na Cadência, Saldo da Cadência Vinculado!!!"
							lRetorno := .F.
							Exit
						EndIf
					EndIF
				EndIf
			EndIf
			oModelNNY:LoadValue( "NNY_QTDINT" , nGridTot ) 
		Next nX 
		oModelNNY:GoLine( nLinha ) 
		If nSomaTot <> NNW->NNW_QTDALT
			IF NNW->NNW_TIPO == '1'
				Help( , , STR0015, ,STR0036, 1, 0 ) //"AJUDA"###"-Aditação- não foi completamente distribuida!"
				lRetorno := .F.
			Else
				Help( , , STR0015, ,STR0037, 1, 0 ) //"AJUDA"###"-Supressão- não foi completamente distribuida!"
				lRetorno := .F.
			EndIf
		EndIf

	EndIf    
Return( lRetorno )

Static Function fOG335VROM(  )
    Local aAreaAtu := GetArea()
    Local xRet 
    Local oModel    := FWModelActive()
	Local oModelNNW := oModel:GetModel("NNWUNICO")
	Local cCodRom   := ""
    cCodRom := oModelNNW:GetValue("NNW_CODROM")
    If !Empty(cCodRom)
	    DbSelectArea( "NJJ" )
	    NJJ->( dbSetOrder( 1 ) )
		If NJJ->( dbSeek( xFilial( "NJJ" ) + cCodRom ) )
		    If NJJ_TIPENT == '1' //Gerencial
		        xRet := FWExecView( STR0042, "OGA255", MODEL_OPERATION_VIEW, , , ,5 ) 
		    Else
		        xRet := FWExecView( STR0042, "OGA250", MODEL_OPERATION_VIEW, , , ,5 )
		    EndIf
	    EndIF
    Else
    	Help( , , STR0015, ,STR0043, 1, 0 ) //"AJUDA"###"Opção disponível apenas para Alteração por Excedente de Carga"
    	xRet := .F.
    EndIF
    RestArea( aAreaAtu )
Return xRet

Static Function OGX335VTKP(oModelNNY, oModelN9A)

	Local aArea 	:= GetArea()
	Local lRet		:= .T.
	Local oModel	:= oModelNNY:GetModel()
	Local nqTSupres	:= oModelNNY:GetValue("TMP_QTDALT")
	Local nQuantRF	:= 0 
	Local nTkp		:= 0
	Local nIns		:= 0
	Local nNF		:= 0
	Local nQtdhg	:= 0
	Local nSaldoLn	:= 0
	Local nIt		:= 0

	// ### VALIDAÇÃO DE QUANTIDADE PARA SUPRESSÃO ###
	For nIt := 1 To oModelN9A:Length()
		If Empty(oModelN9A:GetValue("N9A_CODROM", nIt)) // Se possue romaneio, possue nf global futura, então não inclui no loop
			nQuantRF	:= oModelN9A:GetValue("N9A_QUANT", nIt) // Quantidade da RF
			nTkp 		:= oModelN9A:GetValue("N9A_QTDTKP", nIt) // Quantidade Take-Up
			nIns 		:= oModelN9A:GetValue("N9A_QTDINS", nIt) // Quantidade Instrução
			nNF 		:= oModelN9A:GetValue("N9A_QTDNF", nIt) // Quantidade NF

			// Verifica qual a maior quantidade de cada linha, verificando o Take-up, instrução e Nota Fiscal
			If nTkp > nIns .AND. nTkp > nNF
				nQtdhg := nTkp
			ElseIf nIns > nTkp .AND. nIns > nNF
				nQtdhg := nIns
			Else
				nQtdhg := nNF
			EndIf

			nSaldoLn += (nQuantRF - nQtdhg)  // Soma o saldo disponível de cada linha, considerando a maior quantidade	
		EndIf
	Next nIt

	// Verifica se a supressão é maior que o saldo disponivel
	If nqTSupres > nSaldoLn
		lRet := .F.
		//Help("",1,"OGA335SUPRESS") // # O saldo disponível para o cancelamento foi ultrapassado. # Verificar a quantidade disponível para cancelamento.
		oModel:SetErrorMessage( , , , "", "", STR0044, STR0045, "", "") // # "O saldo disponível para o cancelamento foi ultrapassado." # "Verificar a quantidade disponível para cancelamento."
	Else
		// ### REALIZA A SUPRESSÃO DAS REGRAS FISCAIS ###
		For nIt := 1 To oModelN9A:Length()
			If Empty(oModelN9A:GetValue("N9A_CODROM", nIt)) // Somente para regras fiscais sem nota global futura
				
				oModelN9A:GoLine(nIt) // Posiciona na linha

				nQuantRF	:= oModelN9A:GetValue("N9A_QUANT") // Quantidade da RF
				nTkp 		:= oModelN9A:GetValue("N9A_QTDTKP") // Quantidade Take-Up
				nIns 		:= oModelN9A:GetValue("N9A_QTDINS") // Quantidade Instrução
				nNF 		:= oModelN9A:GetValue("N9A_QTDNF") // Quantidade NF

				// Verifica qual a maior quantidade de cada linha, verificando o Take-up, instrução e Nota Fiscal
				If nTkp > nIns .AND. nTkp > nNF
					nQtdhg := nTkp
				ElseIf nIns > nTkp .AND. nIns > nNF
					nQtdhg := nIns
				Else
					nQtdhg := nNF
				EndIf

				// FIFO -- Logica no qual Se a Quantidade a realizar a supressão for maior que o saldo disponivel de cada regra fiscal
				// então vai reduzindo a quantidade de cada regra pelo saldo, e consequentemente reduzindo a quantidade de supressão.
				If nqTSupres > (nQuantRF - nQtdhg) // Se maior que o saldo disponível, então realiza a redução total
					lRet := oModelN9A:SetValue("N9A_QUANT", nQuantRF - (nQuantRF - nQtdhg)) // Reduz a quantidade
					nqTSupres -= (nQuantRF - nQtdhg) 
				ElseIf nqTSupres > 0 .AND. nqTSupres <= (nQuantRF - nQtdhg) // Se for menor ou igual a quantidade disponivel, então reduz a quantidade de supressao
					lRet := oModelN9A:SetValue("N9A_QUANT", nQuantRF - nqTSupres) // Reduz a quantidade de supressão
					nqTSupres := 0
				EndIf

				If oModelN9A:GetValue("N9A_QUANT", nIt) <= 0 // Se chegou a zerar uma regra fiscal, possivelmente sem take-up, então deleta a mesma.
					oModelN9A:DeleteLine()
				EndIf

				If nqTSupres <= 0 // Se não houver mais quantidade de supressão, então não precisa mais validar
					Exit
				EndIf

			EndIf
		Next nIt
	Endif

	RestArea(aArea)
	
Return lRet


/*/{Protheus.doc} VLDALTCTR
//TODO Valida se permite incluir/alterar/excluir/copiar aditação/supressão para o contrato
@author claudineia.reinert
@since 30/05/2019
@version 1.0
@return ${return}, ${return_description}
@param cCodCtr, characters, descricao
@type function
/*/
Static function VLDALTCTR(cCodCtr)
	Local lRet 		:= .T.
	Local aAreaNJR  := NJR->(GETAREA())
	
	NJR->(dbSetOrder(1))
    If NJR->(dbSeek(xFilial("NJR") + cCodCtr))
    	If !( (NJR->NJR_MODELO == '2' .Or. NJR->NJR_MODELO == '3') .And. NJR->NJR_STATUS $ 'P|A|I' )
           //se contrato não estiver previsto, aberto(confirmado) ou iniciado não permite trabalhar com a aditação/supressao
           AGRHELP(STR0014,STR0050, STR0051) //AJUDA "Ação disponível apenas para Contrato com situação Previsto,Confirmado ou Iniciado.". //Verifique a situação do contrato.
           lRet := .F.
           
         EndIf
		If __lnewNeg 
		   If Empty(NJR->NJR_CODNGC)		
		      //AJUDA "Para Nova comerciliação não é permitida a alteração da quantidade do Contrato classico." //Verifique a situação do contrato.
              AGRHELP(STR0014,STR0054, STR0051) 
           	  lRet := .F.           
		   EndIf
		Else 
			If !Empty(NJR->NJR_CODNGC)		
			    //AJUDA "Para comercializacao classica não é permitida a alteração da quantidade do Contrato do novo negocio." //Verifique a situação do contrato.
				AGRHELP(STR0014,STR0055, STR0051) 
           		lRet := .F.           
			EndIf
		EndIf 
    EndIf
    
    RestArea(aAreaNJR)

Return lRet

/** {Protheus.doc} CalcFixcao

@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Jonisson Henckel
@since:     05/10/2018
@Uso:       OGA335 - Alteracao de Contrato
*/

Static Function CalcFixcao()

Local cCodCtr 		:= NJR->NJR_CODCTR
Local nVlSprssao	:= 0
Local nVlrAditac    := 0
Local nVlrAdxSup    := 0
Local nQtdCtr       := NJR->NJR_QTDCTR
Local nNovoVlrFx    := 0
Local lContinua     := .F.

	
	BeginSql Alias cAliasQry
	
		SELECT NNW_CODCTR,
		       NNW_SEQ,
		       NNW_TIPO,
		       NNW_DATA,
		       NNW_QTDALT,
		       NNW_STATUS,
		       NN8_QTDFIX,
		       NN8_TIPOFX,
		       NJR_QTDCTR,
		
		  (SELECT SUM(NNW_QTDALT)
		   FROM %TABLE:NNW% NNW
		   WHERE NNW_TIPO ='2'
		     AND NNW_CODCTR = %Exp:cCodCtr%
		     AND NNW_STATUS = '2'
		     AND NNW.%NotDel%) AS NNW_SUPRESSOES,
		
		  (SELECT SUM(NNW_QTDALT)
		   FROM %TABLE:NNW% NNW
		   WHERE NNW_TIPO ='1'
		     AND NNW_CODCTR = %Exp:cCodCtr%
		     AND NNW_STATUS = '2'
		     AND NNC.%NotDel%) AS NNW_ADITACOES
		FROM %TABLE:NNW% NNW
		LEFT JOIN %TABLE:NN8% NN8 ON NN8_FILIAL = NNW_FILIAL
		AND NN8.%NotDel%
		AND NN8_CODCTR =%Exp:cCodCtr%
		LEFT JOIN %TABLE:NJR% NJR ON NJR_FILIAL = NNW_FILIAL
		AND NJR_CODCTR =%Exp:cCodCtr%
		AND NJR.%NotDel%
		WHERE NNW_CODCTR =%Exp:cCodCtr%
		  AND NNW.%NotDel%
		
	EndSQL
	
	//Recebe o valor dos retornos da Query.
	nVlSprssao := (cAliasQry)->NNW_SUPRESSOES
	nVlrAditac := (cAliasQry)->NNW_ADITACOES
	nVlrAdxSup :=  nVlrAditac - nVlSprssao
	nNovoVlrFx :=  nQtdCtr +nVlrAdxSup 
	 
	
	dbSelectArea( "NN8" )
	dbSetOrder( 1 )
	If MsSeek( xFilial( "NN8" ) + cCodCtr )
		lContinua := .T. //caso possua fixação, continua.
	Else
		Help( ,,STR0015,, STR0047, 1, 0 ) //"Ajuda"###"Não foi encontrada uma fixação."
		Return( Nil )
	EndIf
	
	If RecLock("NN8", .F.)
		NN8->NN8_QTDFIX := nQuant		
		msUnLock()
	Endif
	
Return	


/*/{Protheus.doc} PreValNN8()
	validação das fixações de preço
	@type  Static Function
	@author mauricio.joao
	@since 23/07/2019
	@version 1.0
	@param oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue
	@return return, logical, retorno booleano
/*/

 Static Function PreValNN8(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
 Local nLinNN8 := 0 //contagem das linhas
 Local nTotAlt := 0 //total a alterar  
 Local oModel := FwModelActive()
 Local oNNW := oModel:GetModel("NNWUNICO")

If cIDField == "TMP_QTDFIX" .AND. cAction == "SETVALUE" //se for o campo tmpqtdfix e estiver setando valor
	
	//pego o total das linhas pra validar
	For nLinNN8 := 1 to oGridModel:Length()		
		Iif(nLinNN8 != nLine,nTotAlt += oGridModel:GetValue("TMP_QTDFIX",nLinNN8),) //só somo se não for a linha atual.
	Next nLinNN8
	
	oGridModel:GoLine(nLine) //volto a linh acorrente

	If (xValue + nTotAlt) > oNNW:GetValue("NNW_QTDALT") //se a soma das linhas mais a linha atual, for maior do que a qtd disp para alterar, retorna falso
		Help(NIL, NIL, "Validación de Cantidad", NIL, "Cantidad no válida",;
			 1, 0, NIL, NIL, NIL, NIL, NIL, {"Compruebe el número de fijaciones cambiadas."}) 
		Return .F.
	EndIf  

	If xValue > (oGridModel:GetValue("NN8_QTDFIX",nLine)-oGridModel:GetValue("NN8_QTDENT",nLine)) //se a diferença entre fix e entrega for maior do que o setado, retorna falso
			Help(NIL, NIL, "Validación de Cantidad", NIL, "Cantidad no válida",;
			 1, 0, NIL, NIL, NIL, NIL, NIL, {"Compruebe el número de fijaciones cambiadas."}) 
		Return .F.
	EndIf

	oGridModel:GetValue("NN8_QTDFIX",nLine)

EndIf

Return .T.

/*/{Protheus.doc} fQtdFix
Função responsavel por retornar o numero de fixações(NN8) geradas para o contrato
@type function
@version  P12
@author claudineia.reinert
@since 17/08/2022
@param cCodCtr, character, codigo do contrato
@param cTpFix , character, tipo da fixação NN8_TIPOFX(0=prevista,1=firme)
@return numeric, numero de registros de fixação(NN8)
/*/
Function OG335CTFIX(cCodCtr,cTpFix)
	Local cQuery := ""
	Local cAliasQry := GetNextAlias()
	Local nContFix := 0
	DEFAULT cTpFix := ""

	cQuery := "SELECT COUNT(*) QTD"
	cQuery +=   " FROM "+ RetSqlName("NN8") + " NN8 "
	cQuery +=  " WHERE NN8.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NN8.NN8_FILIAL = '" + FWxFilial( 'NN8' ) + "' "  
	cQuery +=    " AND NN8.NN8_CODCTR = '" + cCodCtr + "' "   
	If !Empty(cTpFix) 
		cQuery +=    " AND NN8.NN8_TIPOFX = '" + cTpFix +"' "
	EndIf
	cQuery := ChangeQuery( cQuery ) 
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.) //area de trabalho 
	
	If !(cAliasQry)->( Eof() )
		nContFix := (cAliasQry)->QTD    
	EndIf

	(cAliasQry)->( DbCloseArea() )

return nContFix


/*/{Protheus.doc} OG335AC01
Rotina de acerto para a fixação do contrato devido a um erro na função de aditação. 
Fará ajuste conforme a NNW posicionada, para o contrato com fixação do tipo fixo, 
comercialização classica e onde há divergencia da qtd do contrato maior que a quantidade fixada.
Outros cenarios poderão ser adicionados aqui.
@type function
@version  P12
@author claudineia.reinert
@since 18/08/2022
@return Logical, .T. 
/*/
Function OG335AC01()
	Local aArea := GetArea()
	Local aAreaNJR := NJR->(GetArea())
	Local cQuery 	:= ""
	Local cAliasQry := ""
	Local nContFix 	:= 0
	Local lAcerto := .F.
		
	cAliasQry := GetNextAlias()
	cQuery := " SELECT NJR.NJR_CODCTR,NJR.NJR_DATA, NJR.NJR_QTDINI,NJR.NJR_QTDCTR,NJR.NJR_TIPFIX,NN8.NN8_QTDFIX,NN8.NN8_ITEMFX,NN8.NN8_TIPOFX " 
	cQuery += " FROM " + RetSqlName("NN8") + " NN8 " 
	cQuery += " INNER JOIN " + RetSqlName("NJR") + " NJR ON NJR.D_E_L_E_T_ = ' ' AND NJR.NJR_FILIAL = '"+FWxFilial("NJR")+"' "  
	cQuery += " AND NJR.NJR_CODCTR = NN8_CODCTR AND NJR.NJR_TIPFIX = '1' AND NJR.NJR_CODNGC = ' ' "
	cQuery += " AND NJR.NJR_STATUS IN ('A' , 'I') "  //MODELO CLASSICO E CONTRATO ABERTO OU INICIADO
	cQuery += " WHERE NN8.D_E_L_E_T_ = ' ' AND NN8.NN8_FILIAL = '"+FwXFilial("NN8")+"' "  
	cQuery += " AND NN8_TIPOFX = '1' AND NN8_ITEMFX <> '' AND NN8_QTDFIX <> NJR_QTDCTR "    
	cQuery += " AND NN8_CODCTR = '"+ NNW->NNW_CODCTR +"' "    
	cQuery := ChangeQuery( cQuery )
    dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	If !(cAliasQry)->(EOF())
		nContFix := OG335CTFIX((cAliasQry)->NJR_CODCTR)
		If nContFix = 1 .AND. (cAliasQry)->NJR_QTDCTR > (cAliasQry)->NN8_QTDFIX //valida se realmente tem apenas uma fixação
			//trata o acerto quando quantidade contrato maior que a fixação - para tratar erro identificado e ja corrigido na aditação
			If .Not. MsgYesNo(STR0056, STR0057 + (cAliasQry)->NJR_CODCTR )  //##"Foi identificado divergência na fixação do contrato e esta rotina fará o acerto, deseja continuar?" ##"Rotina de acerto - contrato "
				Return( .f. )  
			EndIf

			DbselectArea( "NJR" )
			NJR->(DbGoTop())
			NJR->(dbSetOrder(1))
			If NJR->(dbSeek(FwXFilial("NJR")+(cAliasQry)->NJR_CODCTR)) //necessario posicionar no contrato
				UpdFixQtd( (cAliasQry)->NJR_CODCTR, (cAliasQry)->NN8_ITEMFX )
				lAcerto := .T.
				MsgAlert(STR0058) //##"Acerto finalizado."
			EndIf
		EndIf
	EndIf
	(cAliasQry)->(DbCloseArea())

	If !lAcerto
		MsgAlert(STR0059) //##"Não foi identificado divergências."
	EndIf

    RestArea(aAreaNJR)
    RestArea(aArea)

Return .T.
