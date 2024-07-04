#Include "GTPA418A.ch"

#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
// #Include 'GTPA418.ch'

Static oTempAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA418()
Browse da tela de processamento das comissÃµes de contratos de turismo.
@sample 	GTPA418()
@return 	oBrowse  
@author	Fernando Radu Muscalu
@since		22/11/2021
@version 	P12
/*///-------------------------------------------------------------------
Function GTPA418A()
Local oBrowse	:= Nil

If GQS->(FieldPos('GQS_PROD')) > 0
	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('G94')  
	oBrowse:SetDescription(STR0001) //"Cálculo de comissão de contrato de Fretamento Cotínuo"
	oBrowse:SetFilterDefault("G94_TPCOM == '1'")

	oBrowse:AddLegend("Empty(G94_EXPFOL)","YELLOW",STR0002) //"Pendente de integração com o RH"
	oBrowse:AddLegend("!Empty(G94_EXPFOL)","GREEN",STR0003) //"Comissão integrada com o RH"

	oBrowse:Activate()			
Else
	FWAlertHelp(STR0005, STR0004)	 //'Atualize o Dicionario.' //'O campo Produto (GQS_PROD) não existe.'

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo de dados
@sample 	oModel := ModelDef()
@return 	oModel - objeto. Instância da classe FwFormModel  
@author	Fernando Radu Muscalu 22/11/2021
@since		22/11/2021
@version 	P12
/*///-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	Local oStrG94	:= FWFormStruct(1,"G94")
	Local oStrG95	:= FWFormStruct(1,"G95")

	Local aRelacao	:= {}

	AdjustStruct(oStrG94,oStrG95)
	
	oModel := MPFormModel():New("GTPA418A",/*bPreValid*/, {|oModel| GA418PreValid(oModel)}/*bPosValid*/, {|oModel| GA418ACommit(oModel) }, /*bCancel*/ )
		
	oModel:SetDescription(STR0006) //"Processamento de Contratos"
	
	// ------------------------------------------+
	// ATRIBUI UM COMPONENTE PARA CADA ESTRUTURA |
	// ------------------------------------------+
	oModel:AddFields( 'G94MASTER',/*cOwner*/, oStrG94 )
	
	oModel:AddGrid( 'G95DETAIL', 'G94MASTER', oStrG95, /*bLinePre*/,/* bLinePost*/, /*bPre*/ , /*bPost*/, /*bLoad*/)

	// -------------------------------------------------+
	// FAZ RELACIONAMENTO ENTRE OS COMPONENTES DO MODEL |
	// -------------------------------------------------+
	aAdd(aRelacao,{ 'G95_FILIAL', 'xFilial( "G95" )'})
	aAdd(aRelacao,{ 'G95_CODG94', 'G94_CODIGO' 		})
	aAdd(aRelacao,{ 'G95_SIMULA', 'G94_SIMULA' 		})

	oModel:SetRelation( 'G95DETAIL', aRelacao , G95->( IndexKey( 1 ) )  )

	oModel:GetModel('G95DETAIL'):SetOptional(.T.)

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Prepara o Modelo de visualização
@sample 	oView := ViewDef()
@return 	oView - objeto. Instância da classe FwFormView  
@author	Fernando Radu Muscalu
@since		22/11/2021
@version 	P12
/*///-------------------------------------------------------------------    
Static Function ViewDef()
	
	Local oView    	:= FwFormView():New()       // Recebe o objeto da View
	Local oModel   	:= FwLoadModel( "GTPA418" )	// Objeto do Model 	
	Local oStruG94	:= FWFormStruct( 2, 'G94' )	
	Local oStruG95 	:= FWFormStruct( 2, 'G95' ) 
		
	AdjustStruct(oStruG94,oStruG95,"V")
	//-- Seta o Model para o modelo view
	oView:SetModel(oModel)
	
	//-------------------------------------------+
	// ATRIBUI UM COMPONENTE PARA CADA ESTRUTURA |
	//-------------------------------------------+
	oView:AddField( 'VIEW_G94MASTER'	, oStruG94	, 'G94MASTER' )
	oView:AddGrid ( 'VIEW_G95DETAIL'	, oStruG95	, 'G95DETAIL' )
	
	//-------------------------------------------+
	// DEFINE EM % A DIVISAO DA TELA, HORIZONTAL |
	//-------------------------------------------+
	oView:CreateHorizontalBox( 'CABEC'	, 50 )
	oView:CreateHorizontalBox( 'MEIO'	, 50 )
	
	//-------------------------------------------+
	// DEFINE UM BOX PARA CADA COMPONENTE DO MVC |
	//-------------------------------------------+
	oView:SetOwnerView( 'VIEW_G94MASTER', 'CABEC' )
	oView:SetOwnerView( 'VIEW_G95DETAIL', 'MEIO' )

	// Liga a identificacao do componente
	oView:EnableTitleView('VIEW_G94MASTER', STR0007 )//"Comissão de Contratos"
	oView:EnableTitleView('VIEW_G95DETAIL', STR0008 ) //'Comissão por Produto x Vendedor'
			
Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Prepara o Menu do Modelo
@sample 	MenuDef()
@return 	aRotina  
@author	Fernando Radu Muscalu
@since		22/11/2021
@version 	P12
/*///-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
		ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.GTPA418A' 	OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.GTPA418A'	OPERATION 8 ACCESS 0 //'Imprimir'
		ADD OPTION aRotina TITLE STR0011 ACTION 'G418AComFrete()' 	OPERATION 3 ACCESS 0 //'Cálculo de comissão'
		ADD OPTION aRotina TITLE STR0012 ACTION 'GA418AExclui()' 	OPERATION 5 ACCESS 0 //'Excluir'
		ADD OPTION aRotina TITLE STR0013 ACTION 'TP418RH()' 		OPERATION 3 ACCESS 0 //'Exp.Folha Pagto'
		ADD OPTION aRotina TITLE STR0014 ACTION 'TP418RH(2)' 		OPERATION 5 ACCESS 0 //"Estorno Folha Pagto"
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} G418AComFrete()
Mostra a tela de parametrização e executa o cálculo de comissão
@sample 	G418AComFrete()
@return 	
@author	Fernando Radu Muscalu
@since		22/11/2021
@version 	P12
/*///------------------------------------------------------------------- 
Function G418AComFrete()

	If Pergunte("GTPA418E",.T.) 
		
		if Empty(MV_PAR05) .And. Empty(MV_PAR06) 
		
			FWAlertHelp( STR0015 , STR0016 ) //"PARAMETROS" //"É necessário preencher os parâmetros de data."
	
			Return 
		
		EndIf
		
		if MV_PAR05 > MV_PAR06
		
			FWAlertHelp( STR0018 , STR0017 ) //"Informe uma data final igual ou superior" //"DATA"
			Return 
		
		EndIf
		
		FWMsgRun(,{|| ComisFreteCont( )}, STR0019 , STR0020) //"Processamento..." //"Filtrando apurações"

		// oTempAlias:Delete()
	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ComisFreteCont
Função responsável por criar os dados do cálculo de comissão nas 
tabelas G94 e G95
@type function
@author Fernando Radu 
@since 22/11/2021
@version 1.0
@return lOngoing, Lógico, .t., cálculo criado com sucesso
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function ComisFreteCont( )

	Local oModel		:= FwLoadModel("GTPA418A")
	Local oFields		:= oModel:GetModel("G94MASTER")
	Local oGrid			:= oModel:GetModel("G95DETAIL")

	//Local cSimulacao	:= ""
	Local cTable		:= ""
	Local cBreak		:= ""
	Local cIdG94		:= ""
	Local cFilGQR		:= ""
	Local cIdGQR		:= ""

	Local nSumComis		:= 0

	Local lOngoing		:= .T.
	Local lBreak		:= .F.
	
	//Verifica se para o perÃ­odo informado existem comissÃµes calculadas.	
	If ( Query() )
		
		cTable	:= oTempAlias:GetAlias() 		
		
		(cTable)->(DbGoTop())

		lBreak := cBreak <> (cTable)->(GQR_FILIAL+GY0_CODVD)

		While ( lOngoing .And. !( (cTable)->(EoF()) ) )

			If ( lBreak ) //.And. !Empty(cSimulacao)

				cIdG94	:= GTPXENUM("G94","G94_CODIGO",3)
				
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				oModel:Activate()

				lOngoing := oFields:SetValue("G94_CODIGO",cIdG94) .And.;// oFields:SetValue("G94_SIMULA",cSimulacao) .And.;
							oFields:SetValue("G94_VEND",(cTable)->GY0_CODVD) .And.;
							oFields:SetValue("G94_DATADE",MV_PAR05) .And.;
							oFields:SetValue("G94_DATATE",MV_PAR06) .And.;
							oFields:SetValue("G94_CODGQS",(cTable)->GQS_CODIGO)

			
			EndIf

			If (!lOngoing) //se deu erro, entao volta para checagem do While e sai.
				Loop
			EndIf

			cFilGQR		:= (cTable)->GQR_FILIAL
			cIdGQR		:= (cTable)->GQR_CODIGO

			//Alimenta o Grid - Os itens são por produtos
			cBreak		:= (cTable)->(GQR_FILIAL+GY0_CODVD)
			nSumComis	+= (cTable)->VL_COMISS

			If ( !Empty(oGrid:GetValue("G95_PROD")) )	
				lOngoing := oGrid:Length() < oGrid:AddLine()
			EndIf	

			If ( lOngoing )
				
				lOngoing := oGrid:SetValue("G95_CODG94",oFields:GetValue("G94_CODIGO")) .And.;
							oGrid:SetValue("G95_PROD",(cTable)->G54_PRODUT) .And.;
							oGrid:SetValue("G95_VALTOT",(cTable)->TOTAL) .And.;
							oGrid:SetValue("G95_COMISS",(cTable)->GQT_COMISS) .And.;//oGrid:SetValue("G95_SIMULA",oFields:GetValue("G94_SIMULA").And.;
							oGrid:SetValue("G95_VLRCOM",(cTable)->VL_COMISS) 

			EndIf

			(cTable)->(DbSkip())
			
			lBreak := cBreak <> (cTable)->(GQR_FILIAL+GY0_CODVD)
			
			//Se houver quebra de registro (Filial e Vendedor posicionado difere da
			//variável cBreak) efetua a persistência dos dados
			If ( lOngoing .And. lBreak )

				lOngoing := oFields:SetValue("G94_TPCOM","1") .And.;
							oFields:SetValue("G94_VALTSB",nSumComis) .And.;
							oFields:SetValue("G94_VALCSP",0)

				If ( oModel:VldData() )
					
					lOngoing := oModel:CommitData()

					If ( lOngoing )

						GQR->(DbSetOrder(1)) //GQR_FILIAL+GQR_CODIGO
						
						If ( GQR->(DbSeek(cFilGQR + cIdGQR )) )
							
							RecLock("GQR",.F.)
								GQR->GQR_NUMCOM := oFields:GetValue("G94_CODIGO")
							GQR->(MsUnlock())
							
						EndIf

					EndIf

				Else
					lOngoing := .F.	
				EndIf

				oModel:DeActivate()				

				nSumComis 	:= 0	
				cIdG94 		:= GTPXENUM("G94","G94_CODIGO",3)

			EndIf
			
			If ( !lOngoing )
				Loop
			EndIf

		End While

	EndIf

	If ( Valtype(oModel) == "O" .And. oModel:IsActive() )
		oModel:DeActivate()
		oModel:Destroy()
	EndIf	
	
Return(lOngoing)

//-------------------------------------------------------------------
/*/{Protheus.doc} Query
Query que separa os dados para efetuar os cálculos
@type function
@author Fernando Radu 
@since 22/11/2021
@version 1.0
@return lRet, Lógico, .t. - tabela temporária criada.
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function Query()
Local lRet		:= .T.
Local cMainQry	:= ""
Local cQuery	:= ""
Local cAlias 	:= GetNextAlias()
Local aFldConv	:= {}

cQuery := "SELECT " + chr(13)
cQuery += "	'1' TPCOM, " + chr(13) //--Valor Apuração
cQuery += "	GQR_FILIAL, " + chr(13)
cQuery += "	GQR_CODIGO, " + chr(13)
cQuery += "	GY0_CODVD, " + chr(13)
cQuery += "	G54_PRODUT, " + chr(13)
cQuery += "	MAX(GQS_CODIGO) GQS_CODIGO, " + chr(13)
cQuery += "	GQT_COMISS, " + chr(13)
cQuery += "	Sum(G54_TOTAL) TOTAL " + chr(13)
cQuery += "FROM " + chr(13)
cQuery += "	" + RetSQLName("GQR") + " GQR " + chr(13) //-- Apuraçao Contrato
cQuery += "INNER JOIN " + chr(13)
cQuery += "	" + RetSQLName("G9W") + " G9W " + chr(13) //-- Orçamentos apuraçao contratos
cQuery += "ON " + chr(13)
cQuery += "	G9W_FILIAL = GQR_FILIAL " + chr(13)
cQuery += "	AND G9W_CODGQR = GQR_CODIGO " + chr(13)
cQuery += "	AND G9W.D_E_L_E_T_ = ' ' " + chr(13)
cQuery += "INNER JOIN " + chr(13)
cQuery += "	" + RetSQLName("GY0") + " GY0 " + chr(13) //-- Orçamento de Contrato
cQuery += "ON " + chr(13)
cQuery += "	GY0_FILIAL = G9W_FILIAL" + chr(13)
cQuery += "	AND GY0_NUMERO = G9W_NUMGY0 " + chr(13)
cQuery += "	AND GY0_CODVD BETWEEN ' " + MV_PAR07 + "' AND '" + MV_PAR08 + "' " + chr(13)
cQuery += "	AND GY0.D_E_L_E_T_ = ' ' " + chr(13)
cQuery += "INNER JOIN " + chr(13)
cQuery += "	" + RetSQLName("G54") + " G54 " + chr(13) // -- Totais da Linha Apuração Orçam
cQuery += "ON " + chr(13)
cQuery += "	G54_FILIAL = GQR_FILIAL " + chr(13)
cQuery += "	AND G54_CODGQR = GQR_CODIGO " + chr(13)
cQuery += "	AND G54_NUMGY0 = G9W_NUMGY0 " + chr(13)
cQuery += "	AND G54_PRODUT = GY0_PRODUT " + chr(13)
cQuery += "	AND G54.D_E_L_E_T_ = ' ' " + chr(13)
cQuery += "INNER JOIN
cQuery += "	" + RetSQLName("GQT") +" GQT " + chr(13)
cQuery += "ON " + chr(13)
cQuery += "	GQT_FILIAL = GQR_FILIAL " + chr(13)
cQuery += "	AND GQT_CVEND = GY0_CODVD " + chr(13)
cQuery += "	AND GQT_PROD = G54_PRODUT " + chr(13)
cQuery += "	AND GQT.D_E_L_E_T_ = ' ' " + chr(13)
cQuery += "INNER JOIN " + chr(13)
cQuery += "	" + RetSQLName("GQS") + " GQS " + chr(13) //Comissão de Contratos 
cQuery += "ON " + chr(13)
cQuery += "	GQS_FILIAL = GQT_FILIAL " + chr(13)
cQuery += "	AND GQS_VEND = GQT_CVEND " + chr(13)
cQuery += "	AND GQS_TPCOM = '1' " + chr(13)		//Comissão de Fretamento Contínuo
cQuery += "	AND GQS_TPPAG = '1' " + chr(13)		//Tipo de Comissão: Valor Apurado
cQuery += "	AND GQS.D_E_L_E_T_ = ' ' " + chr(13)	
cQuery += "WHERE " + chr(13)
cQuery += "	GQR_FILIAL = '" + XFilial("GQR") + "' " + chr(13)
cQuery += "	AND GQR_CLIENT BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR03 + "' " + chr(13)
cQuery += "	AND GQR_LOJA BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR04 + "' " + chr(13)
cQuery += "	AND GQR_DTINIA BETWEEN '" + DToS(MV_PAR05) + "' AND '" + DToS(MV_PAR06) + "' " + chr(13)
cQuery += "	AND GQR_DTFINA BETWEEN '" + DToS(MV_PAR05) + "' AND '" + DToS(MV_PAR06) + "' " + chr(13)
cQuery += "	AND GQR_STATUS = '2' " + chr(13)	//--APURAÇÃO MEDIDA
cQuery += "	AND GQR_NUMCOM = ' ' " + chr(13) 	//--QUE NÃO POSSUA CÁLCULO DE COMISSÃO PRÉVIO
cQuery += "GROUP BY " + chr(13)
cQuery += "	GQR_FILIAL, " + chr(13)
cQuery += "	GQR_CODIGO, " + chr(13)
cQuery += "	GY0_CODVD, " + chr(13)
cQuery += "	G54_PRODUT,	" + chr(13)
cQuery += "	GQT_COMISS	" + chr(13)

cQuery += "UNION " + chr(13)

cQuery += "SELECT " + chr(13)
cQuery += "	'2' TPCOM, " + chr(13) //--Valor Fixo
cQuery += "	GQR_FILIAL, " + chr(13)
cQuery += "	GQR_CODIGO, " + chr(13)
cQuery += "	GY0_CODVD, " + chr(13)
cQuery += "	MAX(GQS_PROD) G54_PRODUT, " + chr(13)
cQuery += "	MAX(GQS_CODIGO) GQS_CODIGO, " + chr(13)
cQuery += "	100 GQT_COMISS, " + chr(13)
cQuery += "	SUM(GQS_VLRFIX) TOTAL " + chr(13)
cQuery += "FROM " + chr(13)
cQuery += "	" + RetSQLName("GQR") + " GQR  " + chr(13)	// Apuraçao Contrato
cQuery += "INNER JOIN " + chr(13)
cQuery += "	" + RetSQLName("G9W") + " G9W  " + chr(13) // Orçamentos apuraçao contratos
cQuery += "ON " + chr(13)
cQuery += "	G9W_FILIAL = GQR_FILIAL " + chr(13)
cQuery += "	AND G9W_CODGQR = GQR_CODIGO " + chr(13)
cQuery += "	AND G9W.D_E_L_E_T_ = ' ' " + chr(13)
cQuery += "INNER JOIN " + chr(13)
cQuery += "	" + RetSQLName("GY0") + " GY0  " + chr(13) // Orçamento de Contrato
cQuery += "ON " + chr(13)
cQuery += "	GY0_FILIAL = G9W_FILIAL " + chr(13)
cQuery += "	AND GY0_NUMERO = G9W_NUMGY0 " + chr(13)
cQuery += "	AND GY0_CODVD BETWEEN ' " + MV_PAR07 + "' AND '" + MV_PAR08 + "' " + chr(13)
cQuery += "	AND GY0.D_E_L_E_T_ = ' ' " + chr(13)
cQuery += "INNER JOIN " + chr(13)
cQuery += "	" + RetSQLName("GQS") + " GQS " + chr(13) //Comissão de Contratos	
cQuery += "ON " + chr(13)
cQuery += "	GQS_FILIAL = GQR_FILIAL " + chr(13)
cQuery += "	AND GQS_VEND = GY0_CODVD " + chr(13)
cQuery += "	AND GQS_TPCOM = '1'  " + chr(13) // Comissão de Fretamento Contínuo
cQuery += "	AND GQS_TPPAG = '2'  " + chr(13) // Tipo de Pagamento Fixo
cQuery += "	AND GQS.D_E_L_E_T_ = ' ' " + chr(13)
cQuery += "WHERE " + chr(13)
cQuery += "	GQR_FILIAL = '" + XFilial("GQR") + "' " + chr(13)
cQuery += "	AND GQR_CLIENT BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR03 + "' " + chr(13)
cQuery += "	AND GQR_LOJA BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR04 + "' " + chr(13)
cQuery += "	AND GQR_DTINIA BETWEEN '" + DToS(MV_PAR05) + "' AND '" + DToS(MV_PAR06) + "' " + chr(13)
cQuery += "	AND GQR_DTFINA BETWEEN '" + DToS(MV_PAR05) + "' AND '" + DToS(MV_PAR06) + "' " + chr(13)
cQuery += "	AND GQR_STATUS = '2' " + chr(13)	//--APURAÇÃO MEDIDA
cQuery += "	AND GQR_NUMCOM = ' ' " + chr(13) 	//--QUE NÃO POSSUA CÁLCULO DE COMISSÃO PRÉVIO
cQuery += "GROUP BY " + chr(13)
cQuery += "	GQR_FILIAL, " + chr(13)
cQuery += "	GQR_CODIGO, " + chr(13)
cQuery += "	GY0_CODVD " + chr(13)


cMainQry := "SELECT "
cMainQry += "	TAB.*, " + chr(13)
cMainQry += "	((GQT_COMISS)/100 * TOTAL) VL_COMISS " + chr(13)
cMainQry += "FROM ( " + chr(13)
cMainQry += "	" + cQuery + " " + chr(13)
cMainQry += "	) TAB " + chr(13)
cMainQry += "ORDER BY " + chr(13)
cMainQry += "	TAB.GQR_FILIAL, " + chr(13)
cMainQry += "	TAB.GY0_CODVD, " + chr(13)
cMainQry += "	TAB.G54_PRODUT "

aAdd(aFldConv,{ "GQR_FILIAL",;
				GetSx3Cache("GQR_FILIAL","X3_TIPO"),;
				GetSx3Cache("GQR_FILIAL","X3_TAMANHO"),;
				GetSx3Cache("GQR_FILIAL","X3_DECIMAL")})

aAdd(aFldConv,{ "GY0_CODVD",;
				GetSx3Cache("GY0_CODVD","X3_TIPO"),;
				GetSx3Cache("GY0_CODVD","X3_TAMANHO"),;
				GetSx3Cache("GY0_CODVD","X3_DECIMAL")})

aAdd(aFldConv,{ "COMISSAO",;
				GetSx3Cache("GQT_COMISS","X3_TIPO"),;
				GetSx3Cache("GQT_COMISS","X3_TAMANHO"),;
				GetSx3Cache("GQT_COMISS","X3_DECIMAL")})

aAdd(aFldConv,{ "TOTAL",;
				GetSx3Cache("G54_TOTAL","X3_TIPO"),;
				GetSx3Cache("G54_TOTAL","X3_TAMANHO"),;
				GetSx3Cache("G54_TOTAL","X3_DECIMAL")})
//RADU - JCA: DSERGTP-8012
GTPNewTempTable(cMainQry,cAlias,,aFldConv,@oTempAlias)	//GTPTemporaryTable(cMainQry,cAlias,,aFldConv,@oTempAlias)

If ( Select(oTempAlias:GetAlias()) == 0 )

	lRet := .F.

	FwAlertError(STR0022,STR0021) //"Não foi possível encontrar os dados referente aos parâmetros informados." //"Sem dados"

EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} AdjustStruct
Ajusta a estrutura do modelo de dados e da view.
@type function
@author Fernando Radu 
@since 22/11/2021
@version 1.0
@return 
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function AdjustStruct(oStrG94,oStrG95,cTypeStr)

	Default cTypeStr	:= "M"

	oStrG94:RemoveField("G94_AGENCI")
	oStrG94:RemoveField("G94_DAGENC")
	oStrG94:RemoveField("G94_VALDSR")
	oStrG94:RemoveField("G94_VLBXFI")
	oStrG94:RemoveField("G94_CODGZI")
	oStrG94:RemoveField("G94_G94SUP")
	oStrG94:RemoveField("G94_DFORMU")
	oStrG94:RemoveField("G94_FORMUL")
	
	
	If ( cTypeStr == "M" ) //estrutura de modelo de dados

		oStrG94:SetProperty("*",MODEL_FIELD_OBRIGAT,.f.)
		oStrG94:SetProperty("G94_CODIGO",MODEL_FIELD_OBRIGAT,.t.)
		//oStrG94:SetProperty("G94_SIMULA",MODEL_FIELD_OBRIGAT,.t.)
		oStrG94:SetProperty("G94_VEND",MODEL_FIELD_OBRIGAT,.t.)

		oStrG95:SetProperty("*",MODEL_FIELD_OBRIGAT,.f.)
		oStrG95:SetProperty("G95_CODG94",MODEL_FIELD_OBRIGAT,.t.)
		oStrG95:SetProperty("G95_PROD",MODEL_FIELD_OBRIGAT,.t.)

		//Remove-se campos desnecessários da estrutura

	Else	//estrutura da view
		
		oStrG95:RemoveField("G95_SIMULA")

	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GA418AExclui
Função chamada em Menu para a exclusão do cálculo de comissão
@type function
@author Fernando Radu 
@since 22/11/2021
@version 1.0
@return
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Function GA418AExclui()

	FWMsgRun(,{|| ExcluiComissao( )}, STR0019 , STR0023) //"Excluindo comissão" //"Processamento..."

Return()

Static Function ExcluiComissao()

	Local oModel := FwLoadModel("GTPA418A")

	oModel:SetOperation(MODEL_OPERATION_DELETE) 
	oModel:Activate()

	If (oModel:VldData())
		oModel:CommitData()
	EndIf

	oModel:DeActivate()
	oModel:Destroy()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GA418ACommit
Função chamada dentro do bloco de commit do modelo de dados para 
a persistência de dados do cálculo nas tabelas G94, G95 e GQR
@type function
@author Fernando Radu 
@since 22/11/2021
@version 1.0
@return lRet, Lógico, .t. - persistência efetuada com sucesso
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function GA418ACommit(oModel)

	Local lRet := .T.

	Local cQry 		:= ""
	Local cNumCom	:= oModel:GetModel("G94MASTER"):GetValue("G94_CODIGO")

	lRet := oModel:VldData()

	If ( lRet )
		lRet := FwFormCommit(oModel) //oModel:CommitData()
	EndIf

	If ( lRet .And. oModel:GetOperation() == MODEL_OPERATION_DELETE )
		
		cQry := " UPDATE " + RetSQLName("GQR")	
		cQry += " SET GQR_NUMCOM = '' "
		cQry += " WHERE "
		cQry += " 	GQR_FILIAL = '" + XFilial("GQR") + "' "
		cQry += " 	AND GQR_NUMCOM = '" + cNumCom + "' "
		cQry += " 	AND D_E_L_E_T_ = ' ' "

		If ( TcSqlExec(cQry) < 0 )
			lRet := .f.
		EndIf

	EndIf

Return(lRet)
