#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'GTPA418.ch'

Static cConfigBs	:= ''
Static cCodGZI		:= ''

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA418()
Browse da tela de processamento das comissões de contratos de turismo.
@sample 	GTPA418()
@return 	oBrowse  
@author	Lucas Brustolin -  Inovação
@since		03/02/2016
@version 	P12
/*///-------------------------------------------------------------------
Function GTPA418()
Local oBrowse		:= Nil

If Empty(Alltrim((cConfigBs	:= GTPGetRules("BASECOMCTR"))))
	Help( " ", 1, "GTPA418CFG", , STR0076+"BASECOMCTR.", 1, 0 ) //"Preencha o parâmetro "
	Return
Endif

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('G94')
oBrowse:SetFilterDefault ( "G94_TPCOM <> '1'")  
oBrowse:SetDescription(STR0001)	//Processa Comissão - Contrato Turismo   
oBrowse:AddLegend("!Empty(G94_SIMULA)"															,"RED"		,STR0020)//"Comissão Simulada"
oBrowse:AddLegend("Empty(G94_EXPFOL) .AND. Empty(G94_SIMULA) .AND. (G94_VALTSB-G94_ESTTSB)<> 0"	,"YELLOW"	,STR0021)
//"Pendente de integração com o RH" 
oBrowse:AddLegend("!Empty(G94_EXPFOL) .AND. Empty(G94_SIMULA)"									,"GREEN"	,STR0022)
//"Comissão integrada com o RH"   
oBrowse:AddLegend("(G94_VALTSB-G94_ESTTSB)== 0"													,"BLACK"	,STR0023)    
//"Comissão zerada, portanto não integrada"
oBrowse:Activate()			

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Prepara o Menu do Modelo
@sample 	MenuDef()
@return 	aRotina  
@author	Lucas Brustolin -  Inovação
@since		03/02/2016
@version 	P12
/*///-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
		ADD OPTION aRotina TITLE STR0002 	ACTION 'VIEWDEF.GTPA418' 	OPERATION 2 ACCESS 0//'Visualizar'
		ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.GTPA418'	OPERATION 8 ACCESS 0//'Imprimir'
		ADD OPTION aRotina TITLE STR0004   	ACTION 'TP418PROC()' 		OPERATION 3 ACCESS 0//'Processar Comissão'
		//TODO: QUANDO HOUVER COMISSÃO EXPORTADA PARA RH, NÃO DEVE PERMITIR A EXCLUSÃO DA COMISSAO
		ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.GTPA418' 	OPERATION 5 ACCESS 0//'Excluir'	
		ADD OPTION aRotina TITLE STR0024	ACTION 'TP418RH()' 			OPERATION 3 ACCESS 0//'Exportação Folha Pgto.'
		ADD OPTION aRotina TITLE "Est. Exp. Folha"	ACTION 'TP418RH(2)' 		OPERATION 5 ACCESS 0//'Exportação Folha Pgto.'
		If __cUserId == '000000' 
			ADD OPTION aRotina TITLE "BASECOMCTR 1"	ACTION 'ALTPARAM("1")' 		OPERATION 3 ACCESS 0//'Exportação Folha Pgto.'
			ADD OPTION aRotina TITLE "BASECOMCTR 2"	ACTION 'ALTPARAM("2")' 		OPERATION 3 ACCESS 0//'Exportação Folha Pgto.'
			ADD OPTION aRotina TITLE "BASECOMCTR 3"	ACTION 'ALTPARAM("3")' 		OPERATION 3 ACCESS 0//'Exportação Folha Pgto.'
		EndIf
Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ALTPARAM

@type Function
@author 
@since 01/09/2020
@version 1.0
@param cPARAM, character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function ALTPARAM(cPARAM)
Local aArea := GetArea()
Local aAreaGYF := GYF->(GetArea())

	If GYF->(DbSeek(xFilial("GYF")+"BASECOMCTR"))
		RECLOCK("GYF",.F.)
		GYF->GYF_CONTEU := cPARAM
		GYF->(MSUNLOCK())
		cConfigBs := cPARAM
	EndIf 
RestArea(aAreaGYF)
RestArea(aArea)
Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Prepara o Modelo de Dados
@sample 	ModelDef()
@return 	oModel  
@author	Lucas Brustolin -  Inovação
@since		03/02/2016
@version 	P12
/*///-------------------------------------------------------------------
Static Function ModelDef()


	Local oStruG94	:= FWFormStruct( 1, 'G94') // Recebe a Estrutura da Tabela Proc. Com. Contratos de Turismo;  
	Local oStruG95	:= FWFormStruct( 1, 'G95')// Recebe a Estrutura da Tabela Detalhes do Cálculo de Comissão de Contratos;
	Local aRelacao	:= {}
		
		oModel := MPFormModel():New("GTPA418",/*bPreValid*/, {|oModel| GA418PreValid(oModel)}/*bPosValid*/, /*bCommit*/, /*bCancel*/ )
		
		oModel:SetDescription("Processamento de Contratos") // Ajustado por Radu em 17/11/21: DSERGTP-6934
		
		// ------------------------------------------+
		// ATRIBUI UM COMPONENTE PARA CADA ESTRUTURA |
		// ------------------------------------------+
		oModel:AddFields( 'G94MASTER',/*cOwner*/, oStruG94 )
		
		oModel:AddGrid( 'G95DETAIL', 'G94MASTER', oStruG95, /*bLinePre*/,/* bLinePost*/, /*bPre*/ , /*bPost*/, /*bLoad*/)

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
@sample 	ViewDef()
@return 	oView  
@author	Lucas Brustolin -  Inovação
@since		03/02/2016
@version 	P12
/*///-------------------------------------------------------------------    
Static Function ViewDef()
	
	Local oView    	:= FwFormView():New()       // Recebe o objeto da View
	Local oModel   	:= FwLoadModel( "GTPA418" )	// Objeto do Model 	
	Local oStruG94	:= FWFormStruct( 2, 'G94' )	
	Local oStruG95	:= FWFormStruct( 2, 'G95' ) 
		
		oStruG94:RemoveField("G94_SIMULA")
		oStruG94:RemoveField("G94_CODGZI")
		oStruG95:RemoveField("G95_SIMULA")
		
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
		oView:CreateHorizontalBox( 'supervisor'	, 50 )
		oView:CreateHorizontalBox( 'MEIO'		, 50 )
		
		//-------------------------------------------+
		// DEFINE UM BOX PARA CADA COMPONENTE DO MVC |
		//-------------------------------------------+
		oView:SetOwnerView( 'VIEW_G94MASTER'	, 'supervisor' )
		oView:SetOwnerView( 'VIEW_G95DETAIL'	, 'MEIO' )

		oView:AddUserButton( STR0025, 'CLIPS', {|| VisulLog()} )//"Consulta Log de Processamento?<F4>"
		
		if cConfigBs == '3'
		
			oView:AddUserButton( STR0026, 'CLIPS', {|| VisulBas()} )//"Consulta Registros Base para comissão?<F5>"
			SetKey(VK_F5, {|| iif( VldTecla(), VisulBas(),.F. )})
		
		EndIf
		
		SetKey(VK_F4, {|| iif(VldTecla(),VisulLog(),.F.)})
		
		// Liga a identificacao do componente
		oView:EnableTitleView ('VIEW_G94MASTER'	,STR0007 )// 'Proc. Comi. de Contratos Turismo'
		oView:EnableTitleView ('VIEW_G95DETAIL' ,STR0008 )// 'Comissão por Produto x Vendedor'
				
Return ( oView )
//-------------------------------------------------------------------
/*/{Protheus.doc} TP418PROC()
Rotina responsavel por chamar a rotina de processamento e avaliar
o reprocessamento.
@sample 	TP418PROC()
@return 	
@author	Lucas Brustolin -  Inovação
@since		03/02/2016
@version 	P12
/*///------------------------------------------------------------------- 
Function TP418PROC()

	Local oModel	:= FwLoadModel('GTPA418')

		//Caso o calculo de comissão para o vendedor/superior seja baseado:
		
		//no total de nota fiscais relacionadas a sua agência
		if cConfigBs == '1'
			
			If Pergunte("GTPA418C",.T.) 
			
				if Empty( MV_PAR01 ) .OR. Empty( MV_PAR02 ) 
				
					FWAlertHelp( "GTPA418CPARAMETROS" , STR0077 )//"Preencha as datas e o parametro 'Agencia até.'"
			
					Return 
				
				EndIf
				
				if MV_PAR01 > MV_PAR02
				
					FWAlertHelp( "GTPA418DATAS" , STR0078 )//"Informe uma data inicial maior ou igual a data final"
					Return 
				
				EndIf
				
				FWMsgRun(,{|| TpNFAgenc( oModel )}, STR0001 , STR0079 )//"Processamento de Comissão de Contratos"##"Processamento de comissão de Contratos por total de vendas da Agência"	
			
			Else
			
				FWAlertHelp(STR0039,STR0040)//"Rotina cancelada pelo usuário."##"Preencher parametros e clicar no botão OK."		
						
			EndIf
			
		Elseif cConfigBs == '2'
		
			//no total de notas fiscais relacionadas a suas próprias vendas
			If Pergunte("GTPA418D",.T.) 
						
				if Empty( MV_PAR02 ) .OR. Empty( MV_PAR03 ) .OR. Empty( MV_PAR04 )
				
					FWAlertHelp( "GTPA418CPARAMETROS" , STR0080 )//"Preencha as datas e o parametro 'Vendedor até.'"
			
					Return 
				
				EndIf
								
				if MV_PAR03 > MV_PAR04
				
					FWAlertHelp( "GTPA418DATAS" , STR0081 )// "Informe uma data inicial maior ou igual a data final"
					Return 
				
				EndIf
				
				FWMsgRun(,{|| TpNFVend( oModel )}, STR0001 , STR0082 )// "Processamento de comissão de Contratos por total de vendas por vendedor"	
			
			Else
			
				FWAlertHelp( STR0039 , STR0040 )//"Rotina cancelada pelo usuário."##"Preencher parametros e clicar no botão OK."		
						
			EndIf
				
		Elseif cConfigBs == '3'
		//no total de baixas financeiras relacionadas as suas próprias vendas
	
			If Pergunte("GTPA418A",.T.) 
			 		
				if Empty( MV_PAR02 ) .OR. Empty( MV_PAR04 ) .OR. Empty( MV_PAR05 ) .OR. Empty( MV_PAR06 )
				
					FWAlertHelp( "GTPA418CPARAMETROS" , STR0083 )// "Preencha as datas , parametro 'Agência até.' e 'Vendedor até' "
			
					Return 
				
				EndIf
								
				if MV_PAR05 > MV_PAR06
				
					FWAlertHelp( "GTPA418DATAS" , STR0084 )//"Informe uma data inicial maior ou igual a data final"
					Return 
				
				EndIf
				
				FWMsgRun(,{|| TpBxVend( oModel )}, STR0001, STR0085  )//"Processamento de comissão de Contratos por baixas financeiras"	
		
			Else
	
				FWAlertHelp(STR0039,STR0040)//"Rotina cancelada pelo usuário."##"Preencher parametros e clicar no botão OK."		
						
			EndIf
				 	
		EndIf
		
		if oModel <> Nil
		
			oModel:Destroy()
		
		EndIf
		
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TpNFAgenc
Processamento de comissão para vendedor baseado no total de vendas da agência de turismo.
@type function
@author crisf
@since 15/12/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///-------------------------------------------------------------------
Static Function TpNFAgenc( oModel )

	Local dDataDe	:= Ctod("")
	Local dDataAte	:= Ctod("")
	Local lRet		:= .T.
	Local aProc		:= {}
	Local nTtComis	:= 0
	Local nTtNComs	:= 0
	
		dDataDe		:= MV_PAR01 
		dDataAte	:= MV_PAR02
		
	
		//Verifica se para o período informado existem comissões calculadas.	
		FWMsgRun(,{||  ExistProc( , , , , dDataDe, dDataAte, @aProc )}, STR0001 , STR0086 )//"Verificando existência de processamentos anteriores para o mesmo período." 
		
		//Caso existam comissões processadas, checa se as mesmas não foram exportadas para o RH, caso tenham sido, a rotina
		// é abortada, caso não tenham sido, é verificado com o usuário se as mesmas devem ser transferidas para comissões 
		//simuladas.
		If Len(aProc) > 0 		
		
			FWMsgRun(,{||  chkTrfComis( aProc,  oModel, @lRet, ""/*cDeVend*/, ""/*cAteVend*/ ) }, STR0087 , STR0088 )//"Comissões Existentes"##"Checando o status das comissões existentes para se necessário transferência." 
			
		EndIf
				
		If lRet 
		
			Processa( {|| PrcComisAg418( dDataDe, dDataAte, @nTtComis, @nTtNComs ) }, STR0018,STR0019)//"Aguarde"#"rocessando Comissões de Contratos de Turismo."				

			FWAlertSuccess("Foram gravados "+StrZero( nTtComis,5 )+" e não processados "+Strzero( nTtNComs,5 ), " Finalizado ")
			nTtComis	:= 0
			nTtNComs	:= 0
				
		EndIf

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} TpNFVend
Processamento de comissão para vendedor baseado no total de vendas de suas vendas.
@type function
@author crisf
@since 18/12/2017
@version 1.0
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------
Static Function TpNFVend( oModel )

	Local dDataDe	:= Ctod("")
	Local dDataAte	:= Ctod("")
	Local cDeVend	:= ''
	Local cAteVend	:= ''
	Local lRet		:= .T.
	Local aProc		:= {}
	Local nTtComis	:= 0
	Local nTtNComs	:= 0
	
		cDeVend		:= MV_PAR01
		cAteVend	:= MV_PAR02 
		dDataDe		:= MV_PAR03 
		dDataAte	:= MV_PAR04
	
		//Verifica se para o período informado existem comissões calculadas.	
		FWMsgRun(,{||  ExistProc( , , cDeVend, cAteVend , dDataDe, dDataAte, @aProc )},  STR0001 , STR0086 )//"Verificando existência de processamentos anteriores para o mesmo período." 
		
		//Caso existam comissões processadas, checa se as mesmas não foram exportadas para o RH, caso tenham sido, a rotina
		// é abortada, caso não tenham sido, é verificado com o usuário se as mesmas devem ser transferidas para comissões 
		//simuladas.
		If Len(aProc) > 0 		
		
			FWMsgRun(,{||  chkTrfComis( aProc,  oModel, @lRet, cDeVend , cAteVend ) }, STR0087 , STR0088 )//"Comissões Existentes"##"Checando o status das comissões existentes para se necessário transferência." 
			
		EndIf
				
		If lRet 
		
			Processa( {|| PrcCVend418( cDeVend, cAteVend, dDataDe, dDataAte, @nTtComis, @nTtNComs ) }, STR0018,STR0019)//"Aguarde"#"rocessando Comissões de Contratos de Turismo."				
			
			FWAlertSuccess("Foram gravados "+StrZero( nTtComis,5 )+" e não processados "+Strzero( nTtNComs,5 ), " Finalizado ")
			nTtComis	:= 0
			nTtNComs	:= 0
				
		EndIf

Return(lRet)
 //-------------------------------------------------------------------
/*/{Protheus.doc} ExistProc()
Verifica se existe processamento de comissão já executada para o
periodo informado nos parametros e que não sejam previsões.
@return 	
aProc - Arrray com os dados de processamentos já gravados
@author	Lucas Brustolin -  Inovação
@since		03/02/2016
@version 	P12
/*///------------------------------------------------------------------- 
Static Function ExistProc( cDeAgen, cAteAgen, cDeVend, cAteVend, dDataDe, dDataAte, aProc )
	
	Local cAliaG94		:= GetNextAlias()
	Local cAnd			:= ''
	Default cDeVend		:= ''
	Default cAteVend	:= ''
	Default	cDeAgen		:= ''
	Default cAteAgen	:= ''
	
		If !Empty(cAteVend) 
		
			cAnd	:= "	AND G94.G94_VEND BETWEEN  '"+cDeVend+"' AND '"+cAteVend+"' "
							
		EndIf
		
		if !Empty(cAteAgen) 
				
			cAnd	+= "	AND G94.G94_AGENCI BETWEEN  '"+cDeAgen+"' AND '"+cAteAgen+"' "
					
		EndIf
		
		cAnd	:= '%'+cAnd+'%'
		
		BeginSql Alias cAliaG94 
		
			SELECT G94.G94_VEND,G94.G94_AGENCI,G94.G94_CODIGO,G94.G94_DATADE,G94.G94_DATATE, G94.G94_EXPFOL, G94.R_E_C_N_O_ G94_RECNO 
			FROM %Table:G94% G94
			WHERE G94.G94_FILIAL = %xFilial:G94%
			  %exp:cAnd%
			  AND G94.G94_DATADE BETWEEN  %Exp: Dtos(dDataDe)  %  AND %Exp: Dtos(dDataAte) % 
			  AND %Exp: Dtos(dDataAte) % >= G94.G94_DATATE 
			  AND G94.G94_SIMULA = ' '
			  AND G94.%NotDel% 
			
		EndSql
		
	    //GetlastQuery()[2] retorna a consulta 	
		While (cAliaG94)->(!EOF() )
		
			aAdd(aProc, {	(cAliaG94)->G94_DATADE	,;
							(cAliaG94)->G94_DATATE	,;
							(cAliaG94)->G94_EXPFOL	,;
							(cAliaG94)->G94_RECNO	,;
							(cAliaG94)->G94_AGENCI	,;
							(cAliaG94)->G94_VEND	})
			
			(cAliaG94)->( DbSkip() )				
							
		EndDo
		
		(cAliaG94)->( DbCloseArea() )
		
Return
 //-------------------------------------------------------------------
/*/{Protheus.doc} chkTrfComis
(long_description)
@type function
@author Lucas Brustolin -  Inovação/cris
@since 03/02/2016
@version 1.0
@param aProc, array, (Descrição do parâmetro)
@param oModel, objeto, (Descrição do parâmetro)
@param lRet, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/ //-------------------------------------------------------------------
Static Function chkTrfComis( aProc, oModel, lRet, cDeVend, cAteVend )

	Local oGtpLog 		:= Nil
	Local nPosExpFol	:= 0
	Local nI			:= 0
	Local lExpFol		:= .F.
	Local lFirst		:= .T.
	Local aSupEst		:= {}
	Default cDeVend		:= ''
	Default	cAteVend	:= ''
	
			//-- Cria Objeto Log de Processamento. (Interface)
			oGtpLog := GTPLog():New("Transferencia de comissões para simulação")
			oGtpLog:SetText('-------------------------------------------------------------------------------------------------')
			
			//-- Entra: Comissoes que foram lançadas p/ folha de pgto.	
			If ( aScan( aProc, { |x|  !Empty(x[3]) } ) > 0 )
				lExpFol := .T.
				lRet := .F.
			Endif
										
			For nI := 1 To Len(aProc)
				
				//-- Entra: Comissoes que foram lançadas p/ folha de pgto.
				If lExpFol 
				
					nPosExpFol := aScan( aProc, { |x|  !Empty(x[3]) } )
				
					//-- Entra: Apenas se a mesma não tiver sido carregada(SetText)
					If nPosExpFol > 0
						//-- Alimenta unica vez.
						If lFirst						
							oGtpLog:SetText(STR0009)//'ATENÇÃO'
							oGtpLog:SetText(STR0010)//'O processamento não poderá ser realizado, pois as comissões abaixo já foram lançadas para folha de pagamento.'
							lFirst := .F.
						EndIf
						
						oGtpLog:SetText(AllTrim(STR0011+aProc[nPosExpFol][1]+STR0012+aProc[nPosExpFol][2]+STR0035+aProc[nPosExpFol][5];
						+STR0036+aProc[nPosExpFol][6] ))//-- 'Comissão lançada p/ FOL: ' # ' Até '#" Agência "##" vendedor "
					
					EndIf
					
				Else				
					//-- Entra: Apenas se a mesma não tiver sido carregada(SetText)
					If ! ( aProc[nI][1] + STR0012 + aProc[nI][2] $  oGtpLog:GetText() ) //' Até: '
						//-- Alimenta unica vez.
						If lFirst
							oGtpLog:SetText(STR0013)//'Comissões já processadas'
							oGtpLog:SetText(STR0014)//'O processamento em questão está conflitando com a(s) seguinte(s) comissão(s):'
							oGtpLog:SetText('')	
							lFirst := .F.						
						EndIf
					
						oGtpLog:SetText(AllTrim(STR0015 + Dtoc(Stod(aProc[nI][1])) + STR0012+ Dtoc(Stod(aProc[nI][2]))+STR0035+aProc[nI][5]+;
											STR0036+aProc[nI][6] ) )// Comissão De # ' Até: '##" Agência "##" vendedor "
				
					EndIf
					
				EndIf
				
			Next
			
			oGtpLog:SetText('-------------------------------------------------------------------------------------------------')				
			oGtpLog:SetText('')
			
			//-- Entra: Se houve log. para abrir interface.	
			If !lFirst		
				oGtpLog:ShowLog()
			EndIf
			
			oGtpLog:Destroy()
			
			If !lExpFol			
				
				If MsgYesNo(STR0016,STR0017)// 'Deseja substituir a(s) comissão(s) encontrada(s)?' #'(Conflito)!'
					
					oModel		:= FwLoadModel('GTPA418')
			
					For nI := 1 To Len(aProc)					
						DbSelectArea('G94')
						DbGoTo(aProc[nI][4])
					
						If  G94->( Recno() ) == aProc[nI][4]					
					
							oModel:SetOperation(MODEL_OPERATION_UPDATE )
							oModel:Activate()
							
							oField	:= oModel:GetModel("G94MASTER")
							
							if oField:SetValue("G94_SIMULA",NProxSimul(oField))
							
								//Acumla a referência do código da comissão do supervisor e o valor da comissão do superior
								//quando estiver sendo recalculado um vendedor específico
								if (!Empty(cDeVend) .OR. !'ZZZZZZ' $ cAteVend) .AND. !Empty(oField:GetValue("G94_G94SUP"))
								
									aAdd( aSupEst,{oField:GetValue("G94_G94SUP"),oField:GetValue("G94_VALCSP")} )
								
								EndIf
								
								If oModel:VldData()
								
									FwFormCommit(oModel)	
										
								Else
									JurShowErro( oModel:GetModel():GetErrormessage() )
									lRet := .F.
									Exit
								EndIf
							
							EndIf
													
							oModel:DeActivate()		
												
						EndIf
					
					Next
					
					//Estorna valores de comissão do supervisor
					if len(aSupEst) > 0
					
						EstVlSup( aSupEst,oModel )
														
					EndIf
				
					oModel:Destroy()
						
				Else
				
					lRet := .F.
				
				EndIf
					
			EndIf	
			
Return 
//------------------------------------------------------------------- 
/*/{Protheus.doc} NProxSimul
Busca o número da ultima previsão para retornar um novo número.
@type function
@author crisf
@since 06/11/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------- 
Static Function NProxSimul(oField)

	Local cCodVend	:= oField:GetValue("G94_VEND")
	Local dDtIni	:= oField:GetValue("G94_DATADE")
	Local dDtFim	:= oField:GetValue("G94_DATATE")
	Local cAgencia	:= oField:GetValue("G94_AGENCI")  
	Local cNSimula	:= ''
	
	cNSimula := G418NextSim(cCodVend,dDtIni,dDtFim,cAgencia)
	
Return cNSimula

//------------------------------------------------------------------- 
/*/{Protheus.doc} NProxSimul
Busca o nÃºmero da ultima previsÃ£o para retornar um novo nÃºmero.
@type function
@author crisf
@since 06/11/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------- 
Function G418NextSim(cCodVend,dDtIni,dDtFim,cAgencia)

	Local cAliaG94 	:= GetNextAlias()
	Local cNSimula	:= ""

	BeginSql Alias cAliaG94
	
		SELECT 
			ISNULL(MAX(G94_SIMULA),'S00') NUMPREVISAO
		FROM 
			%Table:G94% G94
		WHERE 
			G94.G94_FILIAL = %xFilial:G94%
			AND G94.G94_VEND = %exp:cCodVend%
			AND G94.G94_AGENCI = %exp:cAgencia%
			AND ( 	%Exp:DTOS(dDtIni)% BETWEEN G94_DATADE AND G94_DATATE OR
					%Exp:DTOS(dDtFim)% BETWEEN G94_DATADE AND G94_DATATE )
			AND G94.%NOTDEL%
	
	EndSql 		    
	
	cNSimula	:= 'S'+SOMA1(SUBSTRING((cAliaG94)->NUMPREVISAO,2,2))
	    		
Return cNSimula
//------------------------------------------------------------------- 
/*/{Protheus.doc} EstVlSup
Estorna o valor da comissão do supervisor, contida no calculo da comissão do vendedor, da comissão do supervisor
@type function
@author crisf
@since 09/11/2017
@version 1.0
@param aSupEst, array, (1 POSIÇÃO: codigo+n simulação da comissão do supervisor G94_G94 SUP,2 POSIÇÃO: Valor comissão)
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------- 
Static Function EstVlSup( aSupEst, oModel )

	Local lAtuSup	:= .T.
	Local nSupEst	:= 0
	Local oField	:= Nil
	Local aAreaG94	:= G94->(GetArea())
		
		For nSupEst	:= 1 to len(aSupEst)
	
			dbSelectArea("G94")
			G94->(dbSetOrder(3))	//G94_FILIAL, G94_CODIGO, G94_SIMULA, R_E_C_N_O_, D_E_L_E_T_
			if G94->(dbSeek(xFilial("G94")+aSupEst[nSupEst][1]))
			
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
				
				oModel:Activate()
				
				oField	:= oModel:GetModel("G94MASTER")
				
				if oField:GetValue("G94_VALTSB") == aSupEst[nSupEst][2]
					//Caso o valor da comissão do supervisor seja baseada em única comissão de vendedor, transforma o processamento
					//da comissão em simulação
				
					oField:SetValue("G94_SIMULA",NProxSimul(oField))
				
				Else
					
					//Caso o valor da comissão do supervisor seja baseado em comissões de vários vendedor, somente atualiza a sua própria comissão
					oField:SetValue("G94_VALTSB",oField:GetValue("G94_VALTSB")-aSupEst[nSupEst][2])
				
				EndIf
				
				If oModel:VldData()
				
					FwFormCommit(oModel)	
					lAtuSup	:= .T.
						
				Else
				
					JurShowErro( oModel:GetModel():GetErrormessage() )
					lAtuSup := .F.
					
				EndIf
				
				oModel:DeActivate()		
			
			Else
				
				lAtuSup	:= .F.
				
			EndIf
			
		Next nSupEst
		
		RestArea(aAreaG94)
													
Return lAtuSup 
//-------------------------------------------------------------------
/*/{Protheus.doc} PrcComisAg418()
Rotina responsavel por gravar as comissões de contratos de turismo.
Comissões de todas as agências conforma o periodo definido no
nos parametros.
@sample 	PrcComisAg418()
@return 	lRet = .T. Processamento OK   
@author	Lucas Brustolin -  Inovação
@since		03/02/2016
@version 	P12
/*///------------------------------------------------------------------- 
Static Function PrcComisAg418( dDataDe, dDataAte, nTtComis, nTtNComs  )

	Local cAliasSF2		:= GetNextAlias()	
	Local aFatAgPd		:= {}
	Local aDdComis		:= {}
	Local nAgenc		:= 0
	Local cTmpAO3		:= ''
	Local cFilMat		:= ""
		
		If Select(cAliasSF2) > 0
		
			(cAliasSF2)->( DbCloseArea() )
				
		EndIf
		
		QrySF2( @cAliasSF2, /*cVendde*/, /*cVendAte*/ , dDataDe, dDataAte)
		
		(cAliasSF2)->(dbGotop())
		if !(cAliasSF2)->(Eof())
			
			//Aglutina valor faturado por agência
			AgluNFAg( cAliasSF2, @aFatAgPd )
		
			//Para cada agência monta suas comissões e grava
			For nAgenc	:= 1 to len( aFatAgPd )
				
				cTmpAO3		:= GetNextAlias()
											
				//Carrega a estrutura de vendas associada a unica agência.
				EstrutNg( aFatAgPd[nAgenc][1], @cTmpAO3, ,1 )
					
				if !(cTmpAO3)->(Eof())
					
					While !(cTmpAO3)->(Eof())
						
						cFilMat := (cTMPAO3)->(GA418RetFilVendMat(VEND))
						
						//Monta a comissão do vendedor
						MntComis( aFatAgPd[nAgenc], cTmpAO3, @aDdComis, dDataDe, dDataAte, 1, cFilMat )	
						
						Begin Transaction
							
							if !GrvComis( aDdComis )
							
								nTtNComs	:= nTtNComs+1
									
							Else
							
								nTtComis	:= nTtComis+1
								 
							EndIf
						
							aDdComis	:= {}
							
						End Transaction
					
						(cTmpAO3)->(dbSkip())
						
					EndDo
					
				EndIf
				
				(cTmpAO3)->(dbCloseArea())
				
			Next nAgenc
			
			//SUPERVISOR
			For nAgenc	:= 1 to len( aFatAgPd )
			
				cTmpAO3		:= GetNextAlias()
				
				//Carrega a estrutura de vendas associada a unica agência.
				EstrutNg( aFatAgPd[nAgenc][1], @cTmpAO3, ,2 )
				
				if !(cTmpAO3)->(Eof())
					
					cFilMat := (cTMPAO3)->(GA418RetFilVendMat(VEND))
					
					//Monta a comissão do supervisor
					MntComis( aFatAgPd[nAgenc], cTmpAO3, @aDdComis, dDataDe, dDataAte, 2, cFilMat )	
					
					Begin Transaction
						
						if !GrvComis( aDdComis )
						
							nTtNComs	:= nTtNComs+1
								
						Else
						
							nTtComis	:= nTtComis+1
							 
						EndIf
					
						aDdComis	:= {}
						
					End Transaction
									
				EndIf
				
				(cTmpAO3)->(dbCloseArea())
						
			Next nAgenc
			
		Else
		
			Help(,,"Help", "PrcComisAg418", STR0089 , 1, 0)//"Para os parametros informados não existem dados."
			
		EndIf
	
		(cAliasSF2)->(dbCloseArea())
	
Return
//------------------------------------------------------------------- 
/*/{Protheus.doc} QrySF2
(long_description)
@type function
@author crisf
@since 15/12/2017
@version 1.0
@param @cAliasSF2, ${param_type}, (Descrição do parâmetro)
@param cVendDe, character, (Descrição do parâmetro)
@param cVendAte, character, (Descrição do parâmetro)
@param dDataDe, data, (Descrição do parâmetro)
@param dDataAte, data, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------- 
Static Function QrySF2( cAliasSF2, cVendDe, cVendAte , dDataDe, dDataAte )
Local cMvPar1 := ''
Local cMvPar2 := ''

Default cVendDe	 := ''
Default cVendAte := ''

if cConfigBs = '1'
	cMvPar1 := MV_PAR01
	cMvPar2 := MV_PAR02
else
	cMvPar1 := MV_PAR03
	cMvPar2 := MV_PAR04
Endif

BeginSql Alias cAliasSF2

	SELECT
		SF2.F2_FILIAL
	, GQS.GQS_AGENCI AGENCIA
	, SF2.F2_VEND1
	, SD2.D2_COD
	, SUM(SD2.D2_TOTAL) SD2TOTAL
	FROM
		%Table:SD2% SD2
		INNER JOIN
			%Table:SF2% SF2
			ON SF2.F2_FILIAL = SD2.D2_FILIAL
			AND SF2.F2_TIPO  = 'N'
			AND SF2.F2_EMISSAO BETWEEN %exp:cMvPar1% AND %exp:cMvPar2%
			AND SF2.%NotDel%
		INNER JOIN
			%Table:SC5% SC5
			ON SC5.C5_FILIAL   = %xFilial:SC5%
			AND SC5.C5_NUM     = SD2.D2_PEDIDO
			AND SC5.C5_CLIENT  = SD2.D2_CLIENTE
			AND SC5.C5_LOJACLI = SD2.D2_LOJA
			AND SC5.C5_ORIGEM IN('GTPA600', 'GTPA300')
			AND SC5.%NotDel%
		INNER JOIN 
			%Table:GQS% GQS
			ON GQS.GQS_FILIAL   = %xFilial:GQS%
			AND GQS.GQS_VEND    = SF2.F2_VEND1
			AND GQS.GQS_STATUS  = '2'
			AND GQS.%NotDel%
	WHERE
		SD2.D2_FILIAL   = %xFilial:SD2%
		AND SD2.D2_DOC      = SF2.F2_DOC
		AND SD2.D2_SERIE    = SF2.F2_SERIE
		AND SD2.D2_CLIENTE  = SF2.F2_CLIENTE
		AND SD2.D2_LOJA     = SF2.F2_LOJA
		AND SD2.D2_TIPO     = SF2.F2_TIPO
		AND SD2.D2_EMISSAO  = SF2.F2_EMISSAO
		AND SD2.%NotDel%
	GROUP BY
		SF2.F2_FILIAL
		, SF2.F2_VEND1
		, SD2.D2_COD
		, GQS.GQS_AGENCI
	ORDER BY
		SF2.F2_FILIAL
		, AGENCIA
		, SF2.F2_VEND1
		
EndSql

Return
//------------------------------------------------------------------- 
/*/{Protheus.doc} EstrutNg
(long_description)
@type function
@author crisf
@since 18/12/2017
@version 1.0
@return ${return}, ${return_description}
/*///------------------------------------------------------------------- 
Static Function EstrutNg( cCdAgenc, cTmpAO3, cCodVend, nOpc )
Local cAnd		 := ''
Local cUnidNeg	 := ""
Local lBOracle	:= Trim(TcGetDb()) == 'ORACLE'
Local lBPost	:= Trim(TcGetDb()) == 'POSTGRES'
Local cSelect   := "%%"
Local cRowNum   := "%%"

Default cCodVend := ''


if lBOracle
	cSelect := "%SUBSTRING(AO3INF.AO3_IDESTN,1,2)%"
	cRowNum    := "%AND ROWNUM = '1'%"
ElseIf lBPost
	cSelect:= "%SUBSTRING(AO3INF.AO3_IDESTN,1,2)%"
	cRowNum:= "%LIMIT 1%"
Else
	cSelect := "%TOP 1 SUBSTRING(AO3INF.AO3_IDESTN,1,2)%"
	cRowNum    := "%%"
Endif


if Empty(cCodVend)
	cAnd := " GQS.D_E_L_E_T_  <> '*' "
Else
	cAnd += " 	GQS.GQS_VEND = '"+cCodVend+"' "	
	cAnd += " AND GQS.D_E_L_E_T_  <> '*' "
EndIf

cAnd := "%"+cAnd+"%"

cUnidNeg := Posicione("GI6",1,xFilial("GI6")+cCdAgenc,"GI6_CODADK")

if nOpc == 1
	BeginSql Alias cTmpAO3	
		SELECT 
			GQS.GQS_FILIAL, 
			GQS.GQS_AGENCI AGENCIA, 
			AO3.AO3_VEND VEND, 
			AO3.AO3_CODUSR, 
			AO3.AO3_CODUND, 
			AO3.AO3_CODEQP, 
			AO3.AO3_IDESTN, 
			AO3.AO3_NVESTN NVESTN, 
			SA3.A3_NUMRA NUMRA, 
			GQS.GQS_DSR DSR, 
			GQS.GQS_CODIGO CODIGO
		FROM 
			%Table:AO3% AO3
		INNER JOIN 
			%Table:GQS% GQS
		ON
			GQS.GQS_FILIAL = %xFilial:GQS%
			AND GQS.GQS_VEND = AO3.AO3_VEND
			//AND GQS.GQS_AGENCI = AO3.AO3_CODUND - Agência GTP não é o mesmo que unidade de negócio do CRM
			AND GQS.GQS_STATUS = '2'
			AND %exp:cAnd%
		INNER JOIN 
			%Table:SA3% SA3
		ON 
			SA3.A3_FILIAL = %xFilial:SA3%
			AND SA3.A3_COD = AO3.AO3_VEND
			AND SA3.%NotDel%
		WHERE 
			AO3_FILIAL = %xFilial:AO3%
			AND AO3.AO3_CODUND = %Exp:cUnidNeg%
			AND AO3.%NotDel%							
		ORDER BY  
			GQS.GQS_FILIAL, 
			GQS.GQS_AGENCI, 
			AO3.AO3_VEND
	EndSql 
Else //busca o responsável
	BeginSql Alias cTmpAO3
		SELECT 
			GQS.GQS_FILIAL, 
			GQS.GQS_CODIGO CODIGO,
			GQS.GQS_AGENCI AGENCIA, 
			(
				SELECT
					ADK_RESP
				FROM
					%Table:ADK% ADK
				WHERE
					ADK_FILIAL = %XFilial:ADK%
					AND ADK_COD = AO5SUP.AO5_CODANE
					AND ADK.%NotDel% 		
			) VEND,		//AO3.AO3_VEND VEND,
			GQS.GQS_DSR DSR, 
			SA3.A3_NUMRA NUMRA, 
			GQS.GQS_COMSUP
		FROM 
			%Table:GQS% GQS
		INNER JOIN 
			%Table:AO3% AO3
		ON 
			AO3.AO3_FILIAL = %xFilial:AO3%
			AND AO3.AO3_CODUND = %Exp:cUnidNeg%	//AND AO3.AO3_CODUND = %exp:cCdAgenc%
			AND AO3.AO3_VEND = GQS_VEND
			AND AO3.AO3_NVESTN < 4
			AND AO3.%NotDel%
		INNER JOIN
			%Table:AO5% AO5SUP
		ON
			AO5SUP.AO5_FILIAL = AO3.AO3_FILIAL
			AND AO5SUP.AO5_IDESTN = SUBSTRING(AO3.AO3_IDESTN,1,2)
			AND AO5SUP.%NotDel%  					  	
		INNER JOIN 
			%Table:SA3% SA3
		ON 
			SA3.A3_FILIAL = %xFilial:SA3%
			AND SA3.A3_COD = AO3.AO3_VEND
			AND SA3.%NotDel%
		WHERE
			GQS.GQS_FILIAL = %xFilial:GQS%
			AND GQS.GQS_AGENCI = %Exp:cCdAgenc%
			AND GQS.GQS_STATUS = '2'
			AND %Exp:cAnd%		
	EndSql
	
	If (cTmpAO3)->(Eof())
	
		(cTmpAO3)->(dbCloseArea())
		
		BeginSql Alias cTmpAO3	
			SELECT 
				GQS.GQS_FILIAL, 
				GQS.GQS_CODIGO CODIGO, 
				GQS.GQS_AGENCI AGENCIA, 
				(
					SELECT
						ADK_RESP
					FROM
						%Table:ADK% ADK
					WHERE
						ADK_FILIAL = %XFilial:ADK%
						AND ADK_COD = AO5SUP.AO5_CODANE
						AND ADK.%NotDel% 		
				) VEND,//AO3.AO3_VEND VEND,
				GQS.GQS_DSR DSR,
				SA3.A3_NUMRA NUMRA, 
				GQS.GQS_COMSUP
			FROM 
				%Table:GQS% GQS
			INNER JOIN 
				%Table:AO3% AO3
			ON
				AO3.AO3_FILIAL = %xFilial:AO3%
				AND AO3.AO3_IDESTN IN 
				(
					SELECT 
						%exp:cSelect%
					FROM 
						%Table:AO3% AO3INF
					WHERE 
						AO3INF.AO3_FILIAL = %xFilial:AO3%
						AND AO3INF.AO3_CODUND = %Exp:cUnidNeg% 
						AND AO3INF.%NotDel%
						%exp:cRowNum%
				)
				AND AO3.%NotDel%
				AND GQS.GQS_FILIAL = %xFilial:GQS%
				AND GQS.GQS_VEND = AO3.AO3_VEND
				AND GQS.GQS_AGENCI =  %exp:cCdAgenc%
				AND GQS.GQS_STATUS = '2'
				AND %exp:cAnd%
			INNER JOIN 
				%Table:SA3% SA3
			ON 
				SA3.A3_FILIAL = %xFilial:SA3%
				AND SA3.A3_COD = AO3.AO3_VEND
				AND SA3.%NotDel%	
			INNER JOIN
				%Table:AO5% AO5SUP
			ON
				AO5SUP.AO5_FILIAL = AO3.AO3_FILIAL
				AND AO5SUP.AO5_IDESTN = SUBSTRING(AO3.AO3_IDESTN,1,2)
				AND AO5SUP.%NotDel% 					
		EndSql					
	EndIf	
EndIf

Return
//------------------------------------------------------------------- 
/*/{Protheus.doc} AgluNFAg
Aglutina total faturado por agência
@type function
@author Lucas Brustolin -  Inovação
@since 02/12/2016
@version 1.0
@param cAliasSF2, character, (Descrição do parâmetro)
@param aFatAgPd, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///------------------------------------------------------------------- 
Static Function AgluNFAg( cAliasSF2, aFatAgPd )

	Local cAgencia	:= ''
	Local nPosProd	:= 0
	Local nTtGeral	:= 0
	Local aDdProd	:= {}

		While !(cAliasSF2)->(Eof())
			
			cAgencia	:= (cAliasSF2)->AGENCIA	
					
			While  	cAgencia == (cAliasSF2)->AGENCIA
				
				if (nPosProd	:= Ascan(aDdProd,{|x| x[1] == (cAliasSF2)->D2_COD })) == 0
				
					aAdd(aDdProd, {(cAliasSF2)->D2_COD, (cAliasSF2)->SD2TOTAL })

				Else
				
					aDdProd[nPosProd][2] := aDdProd[nPosProd][2] + (cAliasSF2)->SD2TOTAL
					
				EndIf
					
				nTtGeral	:= nTtGeral+(cAliasSF2)->SD2TOTAL 
				(cAliasSF2)->(dbSkip())
						
				if cAgencia <> (cAliasSF2)->AGENCIA
										
					aAdd(aFatAgPd, { cAgencia, nTtGeral, aDdProd })
					nTtGeral	:= 0
					aDdProd		:= {}
					
				EndIf
		
			EndDo
				
		EndDo
	
Return 
//------------------------------------------------------------------- 	
/*/{Protheus.doc} MntComis
Monto e aplico os percentuais de comissão para o vendedor
@type function
@author crisf
@since 15/12/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*///------------------------------------------------------------------- 
Static Function MntComis( aTtAgenc, cTmpAO3, aDdComis, dDataDe, dDataAte, nOpc, cFilMat )	
Local aCabec	:= {}
Local aItens	:= {}
Local aAreaGQT	:= GQT->(GetArea())
Local nPrd		:= 0
Local nPercSb	:= 0 //Percentual de comissão do produto associado ao vendedor
Local nVlComis	:= 0 //Valor da comissão por produto
Local nTtComSb	:= 0 //Valor total da comissão do vendedor
Local nTotDSR	:= 0 //Total do valor do DSR.
Local aDSR		:= {}
Local nComissa  := 0
	
Default cFilMat	:= xFilial("SRA")
	
aAdd(aCabec,  (cTmpAO3)->VEND 	) //Codigo do vendedor
aAdd(aCabec,  aTtAgenc[1] 		) //Código da Agência
aAdd(aCabec,  dDataDe 			) //data inicial das nfs consideradas
aAdd(aCabec,  dDataAte 			) //Data final das nfs consideradas
aAdd(aCabec,  cCodGZI 			) //Código do log de processamento
aAdd(aCabec,  (cTmpAO3)->CODIGO ) //Codigo do cadastro de comissão				

For nPrd	:= 1 to len(aTtAgenc[3])
	
	if nOpc == 1
		if RetGQT((cTmpAO3)->VEND, aTtAgenc[3][nPrd][1], (cTmpAO3)->CODIGO, @nComissa)
			nPercSb	:= nComissa
		EndIf
	Else
		nPercSb	:= (cTmpAO3)->GQS_COMSUP
	EndIf
		
	//Garanto que se o vendedor não estiver associado a um codigo de produto do contrato
	//não tento gravar uma linha com informações de comissões zeradas.
	if nPercSb > 0
	
		nVlComis	:=  Round((aTtAgenc[3][nPrd][2]*nPercSb)/100,2)
		aAdd(aItens,{aTtAgenc[3][nPrd][1], aTtAgenc[3][nPrd][2], nPercSb, nVlComis })	
		
		nTtComSb	:= nTtComSb + nVlComis
	
	EndIf
			
Next 

If (cTmpAO3)->DSR  == "1"	.AND. nTtComSb > 0				

	// CALCULA O VLR TOTAL DE DSR PARA VENDEDOR 
	GP410RetDSR( @aDSR, aTtAgenc[1], (cTmpAO3)->NUMRA, nTtComSb, dDataDe, dDataAte, cFilMat )
	
	if len(aDSR) > 0
	
		nTotDSR := aDSR[01,06]
		
	EndIf
			
EndIf

aAdd(aCabec,   nTtComSb	)//Comissão do subordinado
aAdd(aCabec,   0		)//Valor total das baixas
aAdd(aCabec,   0 		)//Commissão total do supervisor						
aAdd(aCabec,   nTotDSR  )
aAdd(aCabec,   0		)//Valor total de estorno - Comissao subordinado
aAdd(aCabec,   0		)//Valor total de estorno - comissão do supervisor

aAdd( aDdComis, aCabec )
aAdd( aDdComis, aItens )

RestArea(aAreaGQT)
	
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GP410RetDSR
Rotina que retorna dados do DSR referente ao colaborador responsável
pela agência, não há ligação entre o fluxo de calculo do módulo GPE
http://tdn.totvs.com/pages/releaseview.action?pageId=234455345

@sample		GP410RetDSR(aDSR,cAgencia,cColabor)
@param		aDSR		Array que irá retornar dados para o calculo do
						DSR.
			cAgencia	Código da agência pesquisada, usado no filtro
						da query
			cColabor	Código do colaborador, usado na busca de 
						programação de férias
			
@author	 	SI4503 - Marcio Martins Pereira  
@since	 	11/02/2016 
@version	P12
/*///-------------------------------------------------------------------
Function GP410RetDSR(aDSR, cAgencia, cColabor, nTtComis, dDatde, dDatAte, cFilMat )
	
	Local aArea		:= GetArea()
	Local dDatI     := CTOD('')
	Local dFerini   := CTOD('')
	Local dFerfim   := CTOD('')
	Local aDtFeria	:= {}
	Local nDtFeria	:= 0
	Local nDiaUtil  := 0
	Local nDomingo  := 0
	Local nFeriado  := 0
	Local nFerias   := 0
	Local lFerias   := .F.
	
	Default cFilMat	:= xFilial("SP3") 
		
		//Ferias programadas
		For dDatI := dDatde to dDatAte
		
			lFerias  := .F.
			
			SRF->(DbSetOrder(1))
			If SRF->(DbSeek(xfilial("SRF")+cColabor,.T.))
			
				If (dDatI >= SRF->RF_DATAINI .and. dDatI <= SRF->RF_DATAINI+SRF->RF_DFEPRO1) .AND. Alltrim(SRF->RF_MAT) == Alltrim(cColabor)
			
					dFerIni := SRF->RF_DATAINI
				   	dFerFim := SRF->RF_DATAINI+SRF->RF_DFEPRO1
				    nFerias += 1
				    lFerias  := .T.
			
				ElseIf (dDatI >= SRF->RF_DATINI2 .and. dDatI <= SRF->RF_DATINI2+SRF->RF_DFEPRO2) .AND. Alltrim(SRF->RF_MAT) == Alltrim(cColabor)
			
				    dFerIni := SRF->RF_DATINI2
				    dFerFim := SRF->RF_DATINI2+SRF->RF_DFEPRO2
				    nFerias += 1
				    lFerias  := .T.
			
				ElseIf (dDatI >= SRF->RF_DATINI3 .and. dDatI <= SRF->RF_DATINI3+SRF->RF_DFEPRO3) .AND. Alltrim(SRF->RF_MAT) == Alltrim(cColabor)
			
				    dFerIni := SRF->RF_DATINI3
				    dFerFim := SRF->RF_DATINI3+SRF->RF_DFEPRO3
				    nFerias += 1
				    lFerias  := .T.
			
				Endif  
			
			EndIf
			
			If !lFerias  
			
				//Connverte a data em um número associado a um dia de semana
				If Dow(dDatI) > 1
				
					nDiaUtil += 1
				
				Else//Se for 1=Domingo
				
					nDomingo += 1
				
				Endif   
			
			Endif
				
		Next
	
	    aDtFeria	:=  GTPxGetFer( dDatde, dDatAte,, cFilMat)

		For nDtFeria	:= 1 to len(aDtFeria)
		  
	         If DOW(STOD(aDtFeria[nDtFeria][1]))  > 1 
	            nDiaUtil := nDiaUtil - 1
	            nFeriado += 1
	         Else
	            nDomingo := nDomingo - 1
	            nFeriado += 1
	         EndIf

		Next nDtFeria
		
		If ( nDiaUtil == 0 )
			nDiaUtil := 1
		EndIf
			
		aAdd( aDSR , {	dFerIni					,;	// 01. Férias Inicial
						dFerFim					,;	// 02. Férias Final
						nDiaUtil				,;	// 03. Dias uteis
						nFeriado				,;	// 04. Dias feriado
						nDomingo+nFeriado		,;  // 05. DSR 
						Round(((nTtComis/nDiaUtil)*(nDomingo+nFeriado)),2)})	//06. Domingo+Feriado	
	
		RestArea(aArea)
		
Return

 //-------------------------------------------------------------------  
/*/{Protheus.doc} $GrvComis
(long_description)
@type function
@author crisf
@since 15/12/2017
@version 1.0
@param aDdComis, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///-------------------------------------------------------------------   
Static Function GrvComis( aDdComis )
 
 	Local oModel		:= FwLoadModel("GTPA418")
	Local oField		:= Nil 
	Local oGrid			:= Nil 
	Local nItens		:= 0
	Local aGrvHis		:= {}
	Local lGravou		:= .F.
	
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		if oModel:Activate()	
			
			oField	:= oModel:GetModel("G94MASTER")
			oGrid	:= oModel:GetModel("G95DETAIL")
										
		 	oField:SetValue('G94_VEND'	, aDdComis[01][01] )
			oField:SetValue('G94_AGENCI', aDdComis[01][02] )
			oField:SetValue('G94_DATADE', aDdComis[01][03] )
			oField:SetValue('G94_DATATE', aDdComis[01][04] )
			oField:SetValue('G94_CODGZI', aDdComis[01][05] )
			oField:SetValue('G94_CODGQS', aDdComis[01][06] )				
			oField:SetValue('G94_VALTSB', aDdComis[01][07] )//Comissão do subordinado
			oField:SetValue('G94_VALCSP', aDdComis[01][09] )//Commissão total do supervisor						
			oField:SetValue('G94_VALDSR', aDdComis[01][10] )
			oField:SetValue('G94_ESTTSB', aDdComis[01][11] )//Valor total de estorno - Comissao subordinado
			
			if cConfigBs == '3'
				
				oField:SetValue('G94_VLBXFI', aDdComis[01][08] )//Valor total das baixas
				oField:SetValue('G94_ESTCSP', aDdComis[01][12] )//Valor total de estorno - comissão do supervisor
	
			EndIf
			
			For nItens	:= 1 to len(aDdComis[2])
				
				If  !( oGrid:GetLine() == 1 .And. oGrid:IsEmpty()  )
				
					oGrid:AddLine()
					
				EndIf
				
				oGrid:SetValue('G95_CODG94'	, oField:GetValue('G94_CODIGO') )
				oGrid:SetValue('G95_PROD'	, aDdComis[2][nItens][1] )
				oGrid:SetValue('G95_VALTOT'	, aDdComis[2][nItens][2] )
				oGrid:SetValue('G95_COMISS'	, aDdComis[2][nItens][3] )
				oGrid:SetValue('G95_VLRCOM'	, aDdComis[2][nItens][4] )	
				
			Next nItens
		
			If oModel:VldData()
			
				FwFormCommit(oModel)		
				oModel:DeActivate()
				
				//Grava histórico quando a base esta relacionada a base
				if cConfigBs == '3'
				
					lGravou	:= GvHisBas( aGrvHis )
				
				Else
				
					lGravou	:= .T.
					
				EndIf
				
			Else
			
				JurShowErro( oModel:GetModel():GetErrormessage() )
				lGravou := .F.

			EndIf
					
		Else
		
			lGravou	:= .F.
			
		EndIf
		
 Return lGravou
 //------------------------------------------------------------------- 
/*/{Protheus.doc} GvHisBas
Grava histórico dos registros base para calculo de comissão
@type function
@author crisf
@since 08/11/2017
@version 1.0
@param aDdBase, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///------------------------------------------------------------------- 
Static Function GvHisBas(aDdBase)

	Local oModel	:= Nil
	Local oField	:= Nil
	Local oGrid		:= Nil	
	Local lGravou	:= .T.
	Local nDdBase	:= 0

		oModel	:= FwLoadModel("GTPA426")
	
		For nDdBase	:= 1 to len(aDdBase)
				
			oModel:SetOperation(MODEL_OPERATION_INSERT )				
			oModel:Activate()
			
			oField	:= oModel:GetModel("GZJCABEC")
			
			oField:SetValue("GZJ_CODG94",	aDdBase[nDdBase][2])
							
			oGrid	:= oModel:GetModel("GZJDETALHE")
				
			If  !( oGrid:GetLine() == 1 .And. oGrid:IsEmpty()  )
			
				oGrid:AddLine()
			
			EndIf
				
			oGrid:SetValue("GZJ_FILIAL",	xFilial("GZJ"))
			oGrid:SetValue("GZJ_TABELA",	"SE1")
			oGrid:SetValue("GZJ_CODG94",	aDdBase[nDdBase][2] )
			oGrid:SetValue("GZJ_SEQUEN",	aDdBase[nDdBase][3] )
			oGrid:SetValue("GZJ_DADOS" ,	aDdBase[nDdBase][1] )
			oGrid:SetValue("GZJ_VALOR"	,	aDdBase[nDdBase][4] )
			oGrid:SetValue("GZJ_VALTSB",	aDdBase[nDdBase][5] )
			oGrid:SetValue("GZJ_VALCSP",	Round((aDdBase[nDdBase][4]*aDdBase[nDdBase][6])/100,2))
						
			If lGravou	:= oModel:VldData()
				
				lGravou	:= FwFormCommit(oModel)		
							
			Else
				
				JurShowErro( oModel:GetModel():GetErrormessage() )
				lGravou := .F.
				
			EndIf
		
			oModel:DeActivate()
		
		Next nDdBase
					 
Return lGravou 
 //------------------------------------------------------------------- 
/*/{Protheus.doc} TP418RH
Efetua a exportação dos registros de comissão para os lançamentos futuros da folha
@type function
@author crisf
@since 08/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/ //-------------------------------------------------------------------  
Function TP418RH(nOpc)
 
 	Local cCdComDe	:= ''
	Local cCdComAt	:= ''
	Local cDeVend	:= ''
	Local cAteVend	:= ''
	Local cTmpG94	:= ''
	Local cSRVCom	:= ''
	Local cSRVDSR	:= ''
	Local cErrors	:= ''
	Local cFilSRA	:= ''
	Local lGravou	:= .T.
	Local lAuxGrv	:= .T.
	
	Default nOpc	:= 1
	
	 	//Pergunte
	 	If Pergunte("GTPA418B",.T.)
	 			
 			cCdComDe	:= MV_PAR01
 			cCdComAt	:= MV_PAR02
 			cDeVend		:= MV_PAR03
 			cAteVend	:= MV_PAR04
 			
 			cTmpG94	:= GetNextAlias()
 			
 			//Seleciona registros, conforme parametros	 		
			FWMsgRun( ,{|| QryComis( @cTmpG94 , cCdComDe , cCdComAt , cDeVend , cAteVend, nOpc )}, STR0056 , STR0057 )
			//"Comissões Ativas"##"Aguarde.Consultando comissões a serem exportadas...."
	
	 		if !(cTmpG94)->(Eof())
	 		
	 			cSRVCom	:= AllTrim(GTPGetRules("VRBCOMISSN"))
	 			cSRVDSR	:= AllTrim(GTPGetRules("VRBCOMIDSR"))
	 			
	 			//Para cada registro selecionado efetua a tentativa de exportação na folha.
	 			(cTmpG94)->(dbGotop())
	 			
	 			While !(cTmpG94)->(Eof()) .AND. lGravou
										
					cFilSRA := GA410RetFilMat((cTmpG94)->A3_NUMRA,(cTmpG94)->A3_CGC)
			 		
					dbSelectArea("SRA")
					
					SRA->(DbSetOrder(1))
					
					If ( SRA->(DbSeek(cFilSRA+(cTmpG94)->A3_NUMRA )) )
									
						//Lembrar de consistir se o valor da comissão com  o valor do estorno.	
					
						If (cTmpG94)->VLREC > 0 //G94.G94_ESTTSB, G94.G94_ESTCSP
		
							Begin Transaction
								
								//Efetuo a tentativa de gravar o valor da comissão
								FWMsgRun( ,{|| lGravou	:= TPExpGPE({(cTmpG94)->A3_NUMRA, cSRVCom, (cTmpG94)->VLREC,,(cTmpG94)->A3_CGC }, nOpc)},STR0058,STR0059)
								//"Exportando para o RH" ## "Aguarde.Exportando comissão normal...."
								
								//Efetuo a tentativa de gravar o valor do DSR
								if (cTmpG94)->G94_VALDSR > 0 .AND. lGravou

									FWMsgRun( ,{|| lGravou	:= TPExpGPE({(cTmpG94)->A3_NUMRA, cSRVDSR, (cTmpG94)->G94_VALDSR,,(cTmpG94)->A3_CGC }, nOpc)},STR0058,STR0060 )
									//"Exportando para o RH" ##	"Aguarde.Exportando DSR sobre comissão...."		 			
								EndIf
								
								if !lGravou
								
									lAuxGrv	:= .F.
								
								EndIf
								
								lGravou := lGravou .AND. AtuG94((cTmpG94)->G94_CODIGO, nOpc)
								
							End Transaction
						
						Else
								
							if UPPER(STR0061) $ UPPER(cErrors) //'Comissões não integradas'
							
								cErrors	:= cErrors+STR0061//'Comissões não integradas: '
								
							EndIf										 				
						
							cErrors	:= cErrors+STR0062+(cTmpG94)->A3_NUMRA+STR0063
							//'Para a Matricula '##" o valor da comissão menos o valor do estorno não gera informação a receber."
						EndIf
						
					Else
		
						if UPPER(STR0061) $ UPPER(cErrors) //'Comissões não integradas'
						
							cErrors	:= cErrors+STR0061//'Comissões não integradas: '
							
						EndIf
						
						cErrors	:= cErrors+STR0064+(cTmpG94)->A3_NUMRA//' Matricula não localizada '
						lGravou	:= .F.

					EndIf
					
					if !lGravou
						
						if UPPER(STR0061) $ UPPER(cErrors) //'Comissões não integradas'
						
							cErrors	:= cErrors+STR0061//'Comissões não integradas: '
							
						EndIf
						
						cErrors	:= cErrors+STR0065+(cTmpG94)->A3_NUMRA//' Não foi possível gravar a comissão para a matrícula '
						
					EndIf
		 			
		 							
	 				(cTmpG94)->(dbSkip())
	 				
	 			EndDo
	 		
	 		Else
	 			
	 			lAuxGrv := .F.
	 			FWAlertHelp(STR0066,STR0067)	
	 			//"Para os parametros informados não existem registros."##"Preencher os parametros e clicar no botão OK ou verifique
	 			// quais comissões estão pendentes."	
	 		EndIf
	 		
	 		(cTmpG94)->(dbCloseArea())
	 		
	 		if lAuxGrv
	 			
	 			If ( nOpc == 1 )
	 				FWAlertSuccess(STR0068,STR0069)//"Exportação de Comissão finalizada."## "Exportação"
	 			Else
	 				FWAlertSuccess("Estorno da comissão realizado com sucesso","Finalizado")//"Exportação de Comissão finalizada."## "Exportação"
	 			EndIf
	 		Else
	 		
	 			FwAlertWarning( STR0090+cCodGZI, STR0091 )//"Existem inconsistências nas informações. Verifique o log numero "##"Aviso"
	 		
	 		EndIf
	 		
	 	Else
	 	
	 		FWAlertHelp(STR0039,STR0040)//"Rotina cancelada pelo usuário."##"Preencher os parametros e clicar no botão OK."		
	 		
	 	EndIf
	 
 Return
 //-------------------------------------------------------------------   
/*/{Protheus.doc} ${function_method_class_name}
(long_description)
@type function
@author crisf
@since 08/11/2017
@version 1.0
@param @cTmpG94, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///-------------------------------------------------------------------  
Static Function QryComis( cTmpG94, cCdComDe, cCdComAt, cVendDe, cVendAt, nOpc )
	 
	 Local cJoinSRK	:= ""
	 Local cExpFol	:= ""
	 
	 Default nOpc := 1
	 
	 If ( nOpc == 2 )
	 
	 	cJoinSRK := "% INNER JOIN " + chr(13)
	 	cJoinSRK += "	" + RetSQLName("SRK") + " SRK " + chr(13)
	 	cJoinSRK += "ON " + chr(13)
	 	cJoinSRK += "	RK_FILIAL = " + chr(13)
	 	cJoinSRK += "	( " + chr(13)
		cJoinSRK += "		SELECT " + chr(13)
		cJoinSRK += "			DISTINCT " + chr(13)
		cJoinSRK += "			RA_FILIAL " + chr(13)
		cJoinSRK += "		FROM " + chr(13)
		cJoinSRK += "			" + RetSQLName("SRA") + " SRA " + chr(13)
		cJoinSRK += "		WHERE " + chr(13)
		cJoinSRK += "			SRA.D_E_L_E_T_= ' ' " + chr(13)
		cJoinSRK += "			AND RA_MAT = SA3.A3_NUMRA " + chr(13)
		cJoinSRK += "			AND RA_CIC = SA3.A3_CGC " + chr(13)
		cJoinSRK += "			AND RA_SITFOLH =  '' " + chr(13) 
		cJoinSRK += ") " + chr(13)
	 	cJoinSRK += "	AND RK_MAT = SA3.A3_NUMRA " + chr(13)
	 	cJoinSRK += "	AND RK_DTREF = G94.G94_EXPFOL " + chr(13)
	 	cJoinSRK += "	AND RK_VLSALDO = RK_VALORTO " + chr(13)
	 	cJoinSRK += "	AND SRK.D_E_L_E_T_= ' ' " + chr(13)
	 	cJoinSRK += "%"
	 	
	 	cExpFol := "% G94.G94_EXPFOL <> ''%"
	 	
	 Else
	 	cJoinSRK	:= "%%" 
	 	cExpFol 	:= "% G94.G94_EXPFOL = ''%"
	 	
	 EndIf
	 
	 BeginSql Alias cTmpG94
	 
		SELECT 
			G94.G94_CODIGO,
			G94.G94_VEND, 
			G94.G94_AGENCI, 
			G94.G94_DATADE,
			G94.G94_DATATE, 
			G94.G94_VALTSB,
			G94.G94_VALCSP,
			G94.G94_VALDSR,
			G94.G94_VLBXFI,
			G94.G94_G94SUP, 
			G94_CODGZI, 
			SA3.A3_NUMRA,
			SA3.A3_CGC,
			G94.G94_ESTTSB, 
			G94.G94_ESTCSP,
			(G94.G94_VALTSB-G94.G94_ESTTSB) VLREC
		FROM 
			%Table:SA3% SA3
		INNER JOIN  
			%Table:G94% G94
		ON 
			G94.G94_FILIAL = %xFilial:G94%
	    	AND G94.G94_VEND BETWEEN %exp:cVendDe% AND %exp:cVendAt%
	      	AND G94.G94_CODIGO BETWEEN %exp:cCdComDe%  AND %exp:cCdComAt%
	       	AND G94.G94_SIMULA = ' '
			AND %Exp:cExpFol%
			AND G94.%NotDel%
			%Exp:cJoinSRK%	
   		WHERE
   			SA3.A3_FILIAL =  %xFilial:SA3%
	   		AND SA3.A3_COD = G94.G94_VEND 
	   		AND SA3.A3_CGC <> ''
	   		AND SA3.%NotDel%	
  		  	
	EndSql 
	 
 Return
  //------------------------------------------------------------------- 
/*/{Protheus.doc} AtuG94
(long_description)
@type function
@author crisf
@since 08/11/2017
@version 1.0
@param cCodG94, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/ //------------------------------------------------------------------- 
Static Function AtuG94(cCodG94, nOpc)

Local lAtualiz	:= .T.
Local oModel	:= Nil
Local aAreaG94	:= G94->(GetArea())

Local cModel	:= ""

Default nOpc	:= 1
		
If ( FwIsInCallStack("GTPA418") )
	cModel := "GTPA418"
ElseIf ( FwIsInCallStack("GTPA418A") )
	cModel := "GTPA418A"
EndIf

dbSelectArea("G94")
G94->(dbSetOrder(3))//G94_FILIAL, G94_CODIGO, G94_SIMULA, R_E_C_N_O_, D_E_L_E_T_
	
If G94->(dbSeek(xFilial("G94")+cCodG94+Space(TamSX3("G94_SIMULA")[1])))
	
	oModel	:= FwLoadModel(cModel)
	
	oModel:SetOperation(MODEL_OPERATION_UPDATE )				
	oModel:Activate()		
			
	oField	:= oModel:GetModel("G94MASTER")	
	
	If ( nOpc == 1 )
	
		oField:SetValue("G94_EXPFOL",Msdate())
	
	Else
		
		oField:SetValue("G94_EXPFOL",StoD(""))
	
	EndIf
	
	If lAtualiz	:= oModel:VldData()
		
		lAtualiz	:= FwFormCommit(oModel)		
					
	Else
		
		JurShowErro( oModel:GetModel():GetErrormessage() )
		lAtualiz := .F.
		
	EndIf

	oModel:DeActivate()
	
Else

	lAtualiz	:= .F.
	
EndIf

RestArea(aAreaG94)		

Return lAtualiz	
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldTecla
Verifica se as teclas de atalho são chamadas de denntro da manutenção do Demonstrativo, as rotinas acionadas pelas teclas não 
poderão ser acionadas do Brownser.
@type function
@author crisf
@since 31/10/2017
@version 1.0
@param oView, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function VldTecla()

	Local oView	:= FwViewActive()
	
	If !oView:IsActive()
	
		FWAlertHelp(STR0070,STR0071)
		//"Teclas de atalho indisponiveis na tela principal"##"Visualizar a Comissão calculada e acessar via teclas ou Ações Relacionadas"
		Return .F.
	
	Else
	
		Return .T.
	
	Endif
	
Return
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VisulLog
Visualização do log de processamento
@type function
@author crisf
@since 09/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function VisulLog()
	
	Local oView		:= FwViewActive()
	Local cCodGZI	:= ''
	Local aAreaGZI	:= GZI->(GetArea())

		cCodGZI   := oView:GetModel():GetModel("G94MASTER"):GetValue("G94_CODGZI")	
		
		dbSelectArea("GZI")
		GZI->(dbSetOrder(1))
		if GZI->(dbSeek(xFilial("GZI")+cCodGZI))
	
			FWExecView("Visualizar","GTPA038",MODEL_OPERATION_VIEW,,{|| .T.}) //"Visualizar"
			
		Else
			
			FWAlertHelp( STR0072+cCodGZI,STR0073 )//"Código de log não disponível "##"Comunicar ao administrador do sistema." 
			
		EndIf
		RestArea(aAreaGZI)
	
Return
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VisulBas
Visualiza os registros base para calculo da comissão.
@type function
@author crisf
@since 09/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function VisulBas()
	
	Local oView		:= FwViewActive()
	Local cCodG94   := oView:GetModel():GetModel("G94MASTER"):GetValue("G94_CODIGO")	
	Local aAreaGZJ	:= GZJ->(GetArea())
	
		dbSelectArea("GZJ")
		GZJ->(dbSetOrder(1))
		if GZJ->(dbSeek(xFilial("GZJ")+cCodG94))
	
			FWExecView("Visualizar","GTPA426",MODEL_OPERATION_VIEW,,{|| .T.}) //"Visualizar"
			
		Else
			
			FWAlertHelp(STR0074+cCodG94+STR0075,STR0073)
			//Histórico ("##")base não localizado."##"Comunicar ao administrador do sistema."
			
		EndIf
		RestArea(aAreaGZJ)
	
Return
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PrcCVend418
(long_description)
@type function
@author crisf
@since 19/12/2017
@version 1.0
@param cDeVend, character, (Descrição do parâmetro)
@param cAteVend, character, (Descrição do parâmetro)
@param dDataDe, data, (Descrição do parâmetro)
@param dDataAte, data, (Descrição do parâmetro)
@param oModel, objeto, (Descrição do parâmetro)
@param nTtComis, numérico, (Descrição do parâmetro)
@param nTtNComs, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function PrcCVend418( cDeVend, cAteVend, dDataDe, dDataAte, nTtComis, nTtNComs ) 

	Local cAliasSF2		:= GetNextAlias()	
	Local cTmpAO3		:= ''
	Local aFatAgPd		:= {}
	Local aDdComis		:= {}
	Local nAgenc		:= 0
			
		If Select(cAliasSF2) > 0
		
			(cAliasSF2)->( DbCloseArea() )
				
		EndIf
		
		QrySF2( @cAliasSF2, cDeVend, cAteVend , dDataDe, dDataAte)

		if !(cAliasSF2)->(Eof())
		
			//Aglutina valor faturado por agência para calcular a comissão do(s) superiores
			AgluNFAg( cAliasSF2, @aFatAgPd )
		
			//Grava a comissão do supervisor
			For nAgenc	:= 1 to len( aFatAgPd )
			
				 cTmpAO3		:= GetNextAlias()
				
				//Carrega a estrutura de vendas associada a unica agência.
				EstrutNg( aFatAgPd[nAgenc][1], @cTmpAO3, , 2 )
				
				if !(cTmpAO3)->(Eof())
					
					//Monta a comissão do superior
					MntComis( aFatAgPd[nAgenc], cTmpAO3, @aDdComis, dDataDe, dDataAte, 2 )	
					
					Begin Transaction
						
						if !GrvComis( aDdComis )
						
							nTtNComs	:= nTtNComs+1
								
						Else
						
							nTtComis	:= nTtComis+1
							 
						EndIf
					
						aDdComis	:= {}
						
					End Transaction
									
				EndIf
				
				(cTmpAO3)->(dbCloseArea())
						
			Next nAgenc
		
			(cAliasSF2)->(dbGotop())
			While !(cAliasSF2)->(Eof())
			
				 cTmpAO3		:= GetNextAlias()
				 
				//Carrega a estrutura de vendas associada a único vendedor.
				EstrutNg( (cAliasSF2)->AGENCIA, @cTmpAO3, (cAliasSF2)->F2_VEND1, 1 )
				
				if (cTmpAO3)->(Eof())
				//Caso o vendedor não seja localizado na estrutura ligado a um supervisor, verifica se o mesmo é um 
				//vendedor supervisor
					(cTmpAO3)->(dbCloseArea())
					 cTmpAO3		:= GetNextAlias()
					EstrutNg( (cAliasSF2)->AGENCIA, @cTmpAO3, (cAliasSF2)->F2_VEND1, 2 )
				
				EndIf
				
				if !(cTmpAO3)->(Eof())
					
					//Monta a comissão dos vendedores 
					MntCVend( cAliasSF2, cTmpAO3, aDdComis, dDataDe, dDataAte )
					
					Begin Transaction
						
						if !GrvComis( aDdComis )
						
							nTtNComs	:= nTtNComs+1
								
						Else
						
							nTtComis	:= nTtComis+1
							 
						EndIf
					
						aDdComis	:= {}
						
					End Transaction
					
				Else
				
					(cAliasSF2)->(dbSkip())
					nTtNComs	:= nTtNComs+1
					
				EndIf
				
				(cTmpAO3)->(dbCloseArea())
					
			EndDo
			
		Else
			
			Help(,,"Help", "PrcComisAg418", "Para os parametros informados não existem dados. Verifique se o pedido de venda foi gerado e encerrado." , 1, 0)
			
		EndIf
		
		(cAliasSF2)->( DbCloseArea() )
		
Return
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MntCVend
(long_description)
@type function
@author crisf
@since 19/12/2017
@version 1.0
@param cAliasSF2, character, (Descrição do parâmetro)
@param cTmpAO3, character, (Descrição do parâmetro)
@param aDdComis, array, (Descrição do parâmetro)
@param dDataDe, data, (Descrição do parâmetro)
@param dDataAte, data, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function MntCVend( cAliasSF2, cTmpAO3, aDdComis, dDataDe, dDataAte  )	
Local aCabec	:= {}
Local aItens	:= {}
Local aAreaGQT	:= GQT->(GetArea())
Local nPercSb	:= 0 //Percentual de comissão do produto associado ao vendedor
Local nVlComis	:= 0 //Valor da comissão por produto
Local nTtComSb	:= 0 //Valor total da comissão do vendedor
Local nTotDSR	:= 0 //Total do valor do DSR.
Local cCodVend	:= (cAliasSF2)->F2_VEND1
Local cCodAgen	:= (cAliasSF2)->AGENCIA
Local aDSR		:= {}
Local nComissa  := 0
	
aAdd(aCabec,  (cTmpAO3)->VEND 		) //Codigo do vendedor
aAdd(aCabec,  (cAliasSF2)->AGENCIA	) //Código da Agência
aAdd(aCabec,  dDataDe 				) //data inicial das nfs consideradas
aAdd(aCabec,  dDataAte 				) //Data final das nfs consideradas
aAdd(aCabec,  cCodGZI 				) //Código do log de processamento
aAdd(aCabec,  (cTmpAO3)->CODIGO	 	) //Codigo do cadastro de comissão				

While cCodVend+cCodAgen == (cAliasSF2)->F2_VEND1+(cAliasSF2)->AGENCIA
	
	if RetGQT((cTmpAO3)->VEND, (cAliasSF2)->D2_COD, (cTmpAO3)->CODIGO, @nComissa)
		nPercSb	:= nComissa
	EndIf
						
	//Garanto que se o vendedor não estiver associado a um codigo de produto do contrato
	//não tento gravar uma linha com informações de comissões zeradas.
	if nPercSb > 0
	
		nVlComis	:=  Round(( (cAliasSF2)->SD2TOTAL*nPercSb)/100,2 )
		aAdd(aItens,{(cAliasSF2)->D2_COD, (cAliasSF2)->SD2TOTAL, nPercSb, nVlComis })	
		
		nTtComSb	:= nTtComSb + nVlComis
	
	EndIf


(cAliasSF2)->(dbSkip())

EndDo
		
If (cTmpAO3)->DSR  == "1"	.AND. nTtComSb > 0				

	// CALCULA O VLR TOTAL DE DSR PARA VENDEDOR 
	GP410RetDSR( @aDSR, (cAliasSF2)->AGENCIA, (cTmpAO3)->NUMRA, nTtComSb, dDataDe, dDataAte )
	
	if len(aDSR) > 0
	
		nTotDSR := aDSR[01,06]
		
	EndIf

EndIf
	
aAdd(aCabec,   nTtComSb	)//Comissão do subordinado
aAdd(aCabec,   0		)//Valor total das baixas
aAdd(aCabec,   0 		)//Commissão total do supervisor						
aAdd(aCabec,   nTotDSR  )
aAdd(aCabec,   0		)//Valor total de estorno - Comissao subordinado
aAdd(aCabec,   0		)//Valor total de estorno - comissão do supervisor

aAdd( aDdComis, aCabec )
aAdd( aDdComis, aItens )

RestArea(aAreaGQT)
	
Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TpBxVend
Calculo de comissão por baixa de titulo
@type function
@author crisf
@since 19/12/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function TpBxVend( oModel )

	Local cDeVend		:= ''
	Local cAteVend		:= ''
	Local cDeAgenc		:= ''
	Local cAtAgenc		:= '' 
	Local cResumo		:= ''
	Local dDataDe		:= Ctod("")
	Local dDataAte	    := Ctod("")
	Local aProc			:= {}
	Local nTtComis		:= 0
	Local nTtNComs		:= 0
	Local lRet			:= .T.
	
			cDeAgenc	:= MV_PAR01
			cAtAgenc	:= MV_PAR02
			cDeVend		:= MV_PAR03
			cAteVend	:= MV_PAR04
			dDataDe		:= MV_PAR05 
			dDataAte	:= MV_PAR06
			
			
			//Verifica se para o período informado existem comissões calculadas.					
			FWMsgRun(,{||  ExistProc( cDeAgenc, cAtAgenc, cDeVend, cAteVend, dDataDe, dDataAte, aProc )}, , STR0001 , STR0086 )//"Verificando existência de processamentos anteriores para o mesmo período." 
		
			If Len(aProc) > 0 		
		
				FWMsgRun(,{||  chkTrfComis( aProc,  oModel, @lRet, cDeVend , cAteVend ) }, STR0087 , STR0088 )//"Comissões Existentes"##"Checando o status das comissões existentes para se necessário transferência." 
			
			EndIf
			
			If lRet 
			
				Processa( {|| cResumo	:= PrcCBxTit418( cDeAgenc, cAtAgenc, cDeVend, cAteVend, dDataDe, dDataAte, @nTtComis, @nTtNComs ) }, STR0018,STR0019)
				
				cResumo	:= cResumo+CRLF+STR0049+StrZero( nTtComis,5 )+CRLF//'Total de comissões calculadas para vendedores '
				cResumo	+= ' Não foram gravados '+Strzero( nTtNComs,5 )+CRLF
				
				FWAlertSuccess("Foram gravados "+StrZero( nTtComis,5 )+" e não processados "+Strzero( nTtNComs,5 ), " Finalizado ")
				nTtComis	:= 0
				nTtNComs	:= 0
				
			EndIf

Return(lRet)
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PrcCBxTit418
(long_description)
@type function
@author crisf
@since 19/12/2017
@version 1.0
@param cDeAgenc, character, (Descrição do parâmetro)
@param cAtAgenc, character, (Descrição do parâmetro)
@param cDeVend, character, (Descrição do parâmetro)
@param cAteVend, character, (Descrição do parâmetro)
@param dDataDe, data, (Descrição do parâmetro)
@param dDataAte, data, (Descrição do parâmetro)
@param nTtComis, numérico, (Descrição do parâmetro)
@param nTtNComs, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Function PrcCBxTit418( cDeAgenc, cAtAgenc, cDeVend, cAteVend, dDataDe, dDataAte, nTtComis, nTtNComs )

	Local cTmpBxNf	:= ''
	Local cCodVend	:= ''
	Local cChvSE1	:= ''
	Local nNivelAt	:= ''
	Local cUnidNeg	:= ''
	Local cAgencAt	:= ''
	Local cMatrSb	:= ''
	Local cDSR		:= ''
	Local cResumo	:= ''
	Local cNumG94	:= ''
	Local cSequen	:= '000'
		
	Local oModel	:= Nil
	
	Local nTtBxFin	:= 0 //Valor total das baixas associadas ao vendedor
	Local nTtComSb	:= 0 //Valor total da comissão associada ao subordinado
	Local nTtComSp  := 0 //Valor total de comissão do supervisor baseado no total baixado do vendedor
	Local nPercSup	:= 0 //Percentual de comissão do supervisor
	Local nTotDSR	:= 0 //Total do DSR calculado em cima do valor da comissão do vendedor
	Local nTtSup	:= 0 //Total de comissões de supervisores calculadas
	Local nVlEstVd	:= 0 //Total do valor do estorno da baixa referente ao fechamento da ultima comissão(vendedor) exportada para o RH 
	Local nVlEstSp	:= 0 //Total do valor do estorno da baixa referente ao fechamento da ultima comissão(superior) exportada para o RH  
	Local nVlCmSTt	:= 0 //Valor total da comissão sobre único título baixado
	Local nPosTt	:= 0 //Posição do titulo no array histórico
	Local nVlAux	:= 0 //Acumula os valores base para calculo da comissaõ do vendedor para calcular 
	Local lGrvBas	:= .T.
	
	Local aVends	:= {}
	Local aGrvHis	:= {} 
	Local aDSR		:= {}
	
		cTmpBxNf		:= GetNextAlias()
		FWMsgRun( ,{|| CTitBaix( @cTmpBxNf, cDeAgenc, cAtAgenc, cDeVend, cAteVend, dDataDe, dDataAte )},STR0041,STR0042)
		//"Titulos Baixados"##"Aguarde consultando titulos baixados para os parametros informados...."
		
		if (cTmpBxNf)->(Eof())
			
			FWAlertHelp(STR0043,STR0044)
			//"Para os parametros informados não existem titulos baixados."##"Verificar o preenchimento dos parametros e clicar no botão,
			// OK ou consulta o responsável financeiro."
			(cTmpBxNf)->(DbCloseArea())
			Return " "
			
		EndIf
		
		oModel		:= FwLoadModel("GTPA418")
		
		While !(cTmpBxNf)->(Eof())
			
			//PAra o mesmo vendedor verifica quantas parcelas foram pagas dentro do periodo para cada nota fiscal
			cCodVend	:= (cTmpBxNf)->GQS_VEND
			nNivelAt	:= (cTmpBxNf)->AO3_NVESTN
			cUnidNeg	:= (cTmpBxNf)->AO3_CODUND
			cAgencAt	:= (cTmpBxNf)->GQS_AGENCI
			nPercSup	:= (cTmpBxNf)->GQS_COMSUP
			cMatrSb		:= (cTmpBxNf)->A3_NUMRA	
			cDSR		:= (cTmpBxNf)->GQS_DSR	
									
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			oModel:Activate()			
	
			oField	:= oModel:GetModel("G94MASTER")
			oGrid	:= oModel:GetModel("G95DETAIL")
			
			oField:SetValue('G94_VEND'	, (cTmpBxNf)->GQS_VEND )
			oField:SetValue('G94_AGENCI', cAgencAt )
			oField:SetValue('G94_DATADE', dDataDe )
			oField:SetValue('G94_DATATE', dDataAte )
			oField:SetValue('G94_CODGZI', cCodGZI )
			oField:SetValue('G94_CODGQS',(cTmpBxNf)->GQS_CODIGO)
			
			//Verifica se o próximo número já foi usado 
			if ProxNum(oField,oField:GetValue('G94_CODIGO'))
			
				cNumG94	:= oField:GetValue('G94_CODIGO')
				
				Begin Transaction
									
					While cCodVend == (cTmpBxNf)->GQS_VEND 
					
						If !oGrid:SeekLine({ {'G95_CODG94', cNumG94}, {'G95_PROD',(cTmpBxNf)->D2_COD }})
		
							If  !( oGrid:GetLine() == 1 .And. oGrid:IsEmpty()  )
								oGrid:AddLine()
							EndIf
							
							oGrid:SetValue('G95_CODG94'	, cNumG94)
							oGrid:SetValue('G95_PROD'	, (cTmpBxNf)->D2_COD )
							oGrid:SetValue('G95_VALTOT'	, (cTmpBxNf)->D2_TOTAL )
							oGrid:SetValue('G95_COMISS'	, (cTmpBxNf)->GQT_COMISS )
							oGrid:SetValue('G95_VLRCOM'	, (cTmpBxNf)->VLCOMIS )						
							
							nVlAux	:= nVlAux+(cTmpBxNf)->D2_TOTAL 
							
						Else
							
						   oGrid:SetValue('G95_VALTOT'	, oGrid:GetValue('G95_VALTOT',oGrid:GetLine())+(cTmpBxNf)->D2_TOTAL )
						   oGrid:SetValue('G95_VLRCOM'	, oGrid:GetValue('G95_VLRCOM',oGrid:GetLine())+(cTmpBxNf)->VLCOMIS )	
							
							nVlAux	:= nVlAux+(cTmpBxNf)->D2_TOTAL 
										
						EndIf			
						
						nTtComSb	:= nTtComSb + (cTmpBxNf)->VLCOMIS
						
						if cChvSE1	<> (cTmpBxNf)->E1_FILIAL+(cTmpBxNf)->E1_CLIENTE+(cTmpBxNf)->E1_LOJA+(cTmpBxNf)->E1_PREFIXO+(cTmpBxNf)->E1_NUM+(cTmpBxNf)->E1_PARCELA+'NF '
						
							nTtBxFin	:= nTtBxFin+(cTmpBxNf)->E1_VALOR
						
							cChvSE1	:= (cTmpBxNf)->E1_FILIAL+(cTmpBxNf)->E1_CLIENTE+(cTmpBxNf)->E1_LOJA+(cTmpBxNf)->E1_PREFIXO+(cTmpBxNf)->E1_NUM+(cTmpBxNf)->E1_PARCELA+'NF '
							//chave única: E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_D_E_L_
							//Indice 2: E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
							//Grava histórico de base de calculo
							cSequen	:= Soma1(cSequen)
							aAdd(aGrvHis,{cChvSE1,cNumG94,cSequen,(cTmpBxNf)->E1_VALOR,0,nPercSup})
														
						EndIf
						
						//Acumula o valor da comissão sobre o titulo,aglutindo o valor calculo por produto
						nVlCmSTt	:= (cTmpBxNf)->VLCOMIS						
						if (nPosTt	:= Ascan(aGrvHis,{|x,y|  x[1] == cChvSE1 })) > 0 
								
							aGrvHis[nPosTt][5]	:= aGrvHis[nPosTt][5]+(cTmpBxNf)->VLCOMIS
						
						EndIf
						 						
						(cTmpBxNf)->(dbSkip())	
								
					EndDo

					If cDSR == "1"					
						
						// CALCULA O VLR TOTAL DE DSR PARA VENDEDOR 
						GP410RetDSR( @aDSR, cAgencAt, cMatrSb, nTtComSb, dDataDe, dDataAte )
			
						if len(aDSR) > 0
						
							nTotDSR := aDSR[01,06]
							
						EndIf
						
						aDSR		:= {}
						
					EndIf
					
					//Verifico se existem titulos baixados no mês anterior que após o processamento de comissão e a exportação,
					//os mesmos foram estornados e se encontram abertos ou com valores de baixa diferente 
					ChkEstor( cCodVend, @nVlEstVd, @nVlEstSp, dDataDe, dDataAte )
										
					oField:SetValue('G94_VALTSB', nTtComSb )//Comissão do subordinado
					oField:SetValue('G94_VLBXFI', nTtBxFin )//Valor total das baixas
					oField:SetValue('G94_VALCSP', nTtComSp )//Commissão total do supervisor						
					oField:SetValue('G94_VALDSR', nTotDSR  )
					oField:SetValue('G94_ESTTSB', nVlEstVd )//Valor total de estorno - Comissao subordinado
					oField:SetValue('G94_ESTCSP', nVlEstSp )//Valor total de estorno - comissão do supervisor
						
					If oModel:VldData()
						FwFormCommit(oModel)		
						oModel:DeActivate()
											
						//Valor	total da comissão do supervisor			
						nTtComSp	:= (nVlAux*nPercSup)/100
						
						aAdd(aVends,{" ", cCodVend, cAgencAt, nNivelAt, cUnidNeg, nTtBxFin, nTtComSb, nTtComSp, cNumG94, nVlEstSp })
						
						lGrvBas	:= GvHisBas(aGrvHis)
						
						if lGrvBas
						
							nTtComis	:= nTtComis + 1
						
						Else
						
							nTtNComs	:= nTtNComs + 1
							
						EndIf
												
						cChvSE1		:= ''
						nTtBxFin	:= 0
						nTtComSb	:= 0
						nPercSup	:= 0
						nTtComSp	:= 0
						cMatrSb		:= ''  
						cAgencAt	:= ''
						cSequen		:= '000'
						aGrvHis		:= {}
						nTotDSR		:= 0
						nVlAux		:= 0
						
					Else
					
						JurShowErro( oModel:GetModel():GetErrormessage() )
						lRet := .F.
						
						cChvSE1		:= ''
						nTtBxFin	:= 0
						nTtComSb	:= 0
						nPercSup	:= 0
						nTtComSp	:= 0
						cMatrSb		:= ''  
						cAgencAt	:= ''
				
					EndIf
			
				End Transaction
						
			Else
			
				FWAlertHelp(STR0045,STR0046)
				//"Numero usado, não foi possível atualizar com um novo número de cálculo de comissão."##"Contactar o administrador do sistema."
				(cTmpBxNf)->(DbCloseArea())
				Return
				
			EndIf
			
		EndDo
		
		(cTmpBxNf)->(DbCloseArea())		
		
		//Verifico se para o vendedor atual deve-se gerar um registro de comissão para um supervisor
		FWMsgRun( ,{|| nTtSup	:= GrvComSup(aVends,dDataDe,dDataAte,oModel)},STR0047,STR0048)
		//"Comissões de supervisores"##"Aguarde consultado e gravando comissões de supervisores...."
		
		oModel:Destroy()
		
		cResumo	:= CRLF+STR0049+StrZero(len(aVends),3)+CRLF//'Total de comissões calculadas para vendedores '
		cResumo	+= STR0050+StrZero(nTtSup,3)+CRLF//'Total de comissões calculadas para supervisores ' 
		
Return cResumo
//-------------------------------------------------------------------
/*/{Protheus.doc} CTitBaix
Consulta os titulos baixados para os parametros informados
@type function
@author crisf
@since 03/11/2017
@version 1.0
@param cTmpTit, character, (Descrição do parâmetro)
@param dDataDe, data, (Descrição do parâmetro)
@param dDataAte, data, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------
Static Function CTitBaix(cTmpTit,cDeAgenc,cAtAgenc,cDeVend,cAteVend,dDataDe,dDataAte)

/* Case
   1. quando existe somente um item e unica parcela
---2. quando existe somente uma parcela porém n itens 
---3. quando existe somente unica parcela, n itens e tem desconto financeiro
---4. quando existem n parcelas e unico item
---5. quando existem n parcelas e vários itens
*/
	BeginSql Alias cTmpTit
	
		SELECT SE1.E1_FILIAL, SE1.E1_NUM, SE1.E1_PREFIXO, SE1.E1_TIPO, SE1.E1_PARCELA, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_EMISSAO, SE1.E1_EMIS1, 
			SE1.E1_VENCREA, SE1.E1_VALOR, SE1.E1_BASEIRF, SE1.E1_IRRF, SE1.E1_ISS,SE1.E1_BAIXA,SE1.E1_VEND1, SE1.E1_COMIS1, SE1.E1_VALLIQ, 
			SE1.E1_PEDIDO, SE1.E1_SERIE, SE1.E1_STATUS, SE1.E1_ORIGEM,
			GQS.GQS_AGENCI,GQS.GQS_VEND, GQS.GQS_COMSUP,GQS.GQS_DSR, GQS.GQS_CODIGO,
			SD2.D2_COD,SD2.D2_TOTAL,SD2.D2_PEDIDO,SD2.D2_ITEMPV,
			SF2.F2_VEND1,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_DUPL,SF2.F2_EMISSAO,SF2.F2_VALMERC,	
			GQT_PROD,GQT_COMISS,
			 SA3.A3_NUMRA,	 
			AO3.AO3_CODUND,AO3.AO3_CODUSR,AO3.AO3_NVESTN,
				( CASE 
				     WHEN E1_PARCELA = ' ' AND E1_VALOR = D2_TOTAL THEN ROUND((E1_VALOR*GQT_COMISS)/100,2) 
					  WHEN E1_PARCELA = ' ' AND E1_VALOR <> D2_TOTAL AND  E1_VALOR = F2_VALMERC THEN ROUND((D2_TOTAL*GQT_COMISS)/100,2) 
					  WHEN E1_PARCELA = ' ' AND E1_VALOR <> D2_TOTAL AND  E1_VALOR <> F2_VALMERC THEN (E1_VALOR*ROUND((D2_TOTAL*100)/F2_VALMERC,2))*GQT_COMISS 
					 WHEN E1_PARCELA <> '' AND D2_TOTAL = F2_VALMERC THEN ROUND((E1_VALOR*GQT_COMISS)/100,2)  
					 WHEN E1_PARCELA <> ''  THEN (E1_VALOR*ROUND((D2_TOTAL*100)/F2_VALMERC,2))*GQT_COMISS 	
	 			ELSE 1
				 END ) AS VLCOMIS
		FROM %table:SF2% SF2
		INNER JOIN %table:SE1% SE1 
		   ON SE1.%NotDel%
		  AND SE1.E1_FILIAL = %xfilial:SE1% 
		  AND SE1.E1_VEND1 BETWEEN %Exp:cDeVend% AND %Exp:cAteVend%  
		  AND SE1.E1_TIPO = 'NF'
		   AND SF2.F2_FILIAL = %xfilial:SF2% 
		  AND SF2.F2_SERIE = SE1.E1_SERIE
		  AND SF2.F2_EMISSAO = SE1.E1_EMIS1  
		  AND SF2.F2_CLIENTE = SE1.E1_CLIENTE
		  AND SF2.F2_LOJA = SE1.E1_LOJA
		  AND SF2.F2_PREFIXO = SE1.E1_PREFIXO
		INNER JOIN %table:GQS% GQS
		       ON GQS.%NotDel%
					 AND GQS.GQS_FILIAL = %xfilial:GQS% 
					 AND GQS.GQS_VEND = SE1.E1_VEND1
					 AND GQS.GQS_AGENCI BETWEEN %Exp:cDeAgenc% AND %Exp:cAtAgenc% 
					 AND GQS.GQS_STATUS = '2'
		INNER JOIN %table:SD2% SD2 
			    ON SD2.%NotDel%
		        AND SF2.F2_FILIAL = SD2.D2_FILIAL
				AND SF2.F2_DOC = SD2.D2_DOC
				AND SF2.F2_SERIE = SD2.D2_SERIE
				AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
				AND SF2.F2_LOJA = SD2.D2_LOJA
				AND SF2.F2_TIPO = 'N'
			    AND EXISTS(SELECT SC5.C5_NUM
						  FROM %table:SC5% SC5
						  WHERE %NotDel%
						     AND SC5.C5_FILIAL = %xfilial:SC5% 
								AND SD2.D2_PEDIDO = SC5.C5_NUM
								AND SC5.C5_ORIGEM IN('GTPA600', 'GTPA300') 
								)
		INNER JOIN  %table:GQT%  GQT
		        ON GQT.%NotDel%
			   AND GQT.GQT_FILIAL = GQS.GQS_FILIAL	  
			   AND GQT.GQT_CVEND = GQS.GQS_VEND	  
			   AND GQT.GQT_CODIGO = GQS.GQS_CODIGO
		       AND GQT.GQT_PROD = SD2.D2_COD
		INNER JOIN %table:SA3% SA3
		        ON SA3.%NotDel%
			   AND SA3.A3_FILIAL = %xfilial:SA3% 
			   AND SA3.A3_COD = GQS.GQS_VEND
		INNER JOIN  %table:AO3% AO3
		       ON AO3.%NotDel%  
			  AND AO3.AO3_FILIAL = %xfilial:AO3% 
			  AND AO3.AO3_VEND = GQS.GQS_VEND 
		ORDER BY GQS_AGENCI, GQS_VEND, SE1.E1_NUM, SE1.E1_PREFIXO, SE1.E1_PARCELA, SD2.D2_COD

	EndSql 	

Return 
//-------------------------------------------------------------------  
/*/{Protheus.doc} $ProxNum
consiste o proximo número e caso necessário o substitui.
@type function
@author crisf
@since 06/11/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*///------------------------------------------------------------------- 
Static Function ProxNum(oField,cCodG94)
 
 	Local cAliaG94	:= GetNextAlias()
 	Local lExist	:= .T.
 	Local cCodAux	:= cCodG94
 	
 		While lExist
 		
	 		BeginSql Alias cAliaG94
	 		
	 			SELECT ISNULL(G94_CODIGO,'') CODIGO
	 			FROM %Table:G94% G94
				WHERE G94.G94_FILIAL = %xFilial:G94%
			      AND G94.G94_CODIGO = %exp:cCodG94%
			      AND G94.%NOTDEL%
			      
	 		EndSql 		    
	    	//GetlastQuery()[2]
	    	
	    	if !Empty((cAliaG94)->CODIGO)
	    	
	    		cCodG94	:= GetSxeNum("G94", "G94_CODIGO")   		
	    		
	    	Else
	    		
	    		lExist	:= .F.
	    			
	    	EndIf
	    	
	    	(cAliaG94)->(dbCloseArea())
	    	
    	EndDo    	
	
		if !lExist .AND. LockByName("G94"+cCodG94,.T.) .AND. cCodG94 <> cCodAux
		
			lExist	:= !(oField:SetValue("G94_CODIGO",cCodG94))		
			
		EndIf
	    	
 Return !lExist
  //-------------------------------------------------------------------
/*/{Protheus.doc} $GrvComSup
Grava Comissão do supervisor
@type function
@author crisf
@since 07/11/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
/*/  //-------------------------------------------------------------------
Static Function GrvComSup(aVends,dDataDe,dDataAte,oModel)
 
  	Local aSups		:= {}
  	Local nVend		:= 0
 	Local nPosSup	:= 0
 	Local nSupers	:= 0
 	Local nOper		:= 0
 	Local nTtSup	:= 0
 	Local nRecno	:= 0
 	Local aAreaG94	:= G94->(GetArea())
 	Local oField	:= Nil 
 	Local cCodSup	:= ''
 	Local cCodComs	:= ''
	
		For nVend	:= 1 to len(aVends)
		
			cCodSup	:= PesqSup(aVends[nVend][2],aVends[nVend][4],aVends[nVend][5])
			
			//Caso o supervisor esteja associado a uma venda, consequentemente a uma baixa de titulo poderá não ter supervisor de venda ou
			//Caso um vendedor não esteja associado a um supervisor
			if !Empty(cCodSup)
			
				aVends[nVend][1] :=	cCodSup
			
			EndIf
							 
		Next nVend
		
		//Garante que os vendedores estão ordenados por supervisores
		Asort(aVends,,,{ | x,y| y[1] > x[1] } )
		
		//Acumula o valor da comissão de cada supervisor e para cada supervisor grava um calculo de comissão.
		For nVend	:= 1 to len(aVends)
		
			If !Empty(aVends[nVend][1])
				
				if (nPosSup	:= Ascan(aSups,{|x,y| x[1] == aVends[nVend][1] })) == 0
					//aAdd(aVends,{1-" ",2-cCodVend,3-cAgencAt,4-nNivelAt,5-cUnidNeg,6-nTtBxFin,7-nTtComSb,8-nTtComSp,9-cNumG94,10-nVlEstSp})
					aAdd(aSups,{aVends[nVend][1],aVends[nVend][3],aVends[nVend][6],aVends[nVend][7],aVends[nVend][8],aVends[nVend][10]})
				
				Else
	
					aSups[nPosSup][3]	:= aSups[nPosSup][3]+aVends[nVend][06] //Valor total de baixas financeiras
					aSups[nPosSup][4]	:= aSups[nPosSup][4]+aVends[nVend][07] //Valor total da comissão dos subordinados
					aSups[nPosSup][5]	:= aSups[nPosSup][5]+aVends[nVend][08] //Valor total da comissão do supervisor
					aSups[nPosSup][6]	:= aSups[nPosSup][6]+aVends[nVend][10] //Valor total de estorno do estorno
					 
				EndIf	
		
			EndIf
				
		Next nVend
		
		nTtSup	:= len(aSups)	
		For nSupers	:= 1 to nTtSup
		
			//Verifica se para cada supervisor já existe um cadastro de comissão gerada, caso exista aglutina o valor
			ExistSup( aSups[nSupers][1], Dtos(dDataDe), Dtos(dDataAte), @nRecno )
			
			dbSelectArea("G94")
			
			if nRecno <> 0
				
				G94->(dbGoto(nRecno))
				
				oModel:SetOperation(MODEL_OPERATION_UPDATE )
				nOper	:= 4
				
			Else
			
				oModel:SetOperation(MODEL_OPERATION_INSERT )
				nOper	:= 3
					
			EndIf
			
			oModel:Activate()				
			oField	:= oModel:GetModel("G94MASTER")	
			
			//Verifica se o proximo numero já foi usado 
			if (nOper == 3 .AND. ProxNum(oField,oField:GetValue('G94_CODIGO'))) .OR. nOper == 4
			
				if nOper == 3
				
					oField:SetValue('G94_VEND'	, aSups[nSupers][1])
					oField:SetValue('G94_AGENCI', aSups[nSupers][2] )
					oField:SetValue('G94_DATADE', dDataDe )
					oField:SetValue('G94_DATATE', dDataAte )	
					oField:SetValue('G94_VLBXFI', aSups[nSupers][3])//Valor total das baixas			
					oField:SetValue('G94_VALTSB', aSups[nSupers][5])//aSups[nPosSup][4])//Comissão do subordinado	
					oField:SetValue('G94_CODGZI', cCodGZI )			
					oField:SetValue('G94_ESTTSB', aSups[nSupers][6])//valor do estorno das comissoes
									
				Else
					
					oField:SetValue('G94_VALTSB', oField:GetValue('G94_VALTSB') + aSups[nSupers][5])//aSups[nSupers][4])//Comissão do subordinado atual supervisor
					oField:SetValue('G94_VLBXFI', oField:GetValue('G94_VLBXFI') + aSups[nSupers][3])//Valor total das baixas
					oField:SetValue('G94_ESTTSB', oField:GetValue('G94_ESTTSB') + aSups[nSupers][6])//valor do estorno das comissoes
							
				EndIf
				
				cCodComs	:= oField:GetValue('G94_CODIGO')
				
				If oModel:VldData()
					
					FwFormCommit(oModel)		
					oModel:DeActivate()
					
					//Vincula o código da comissão do supervisor com o código da comissão do vendedor
					VincVdSp(aVends,aSups[nSupers][1],cCodComs,oModel)
					
				Else
					
					JurShowErro( oModel:GetModel():GetErrormessage() )
					lRet := .F.
					Exit
					
				EndIf
			
			EndIf
				
		Next nSupers
		
		RestArea(aAreaG94)
	
Return nTtSup
//------------------------------------------------------------------- 
/*/{Protheus.doc} ${function_method_class_name}
(long_description)
@type function
@author crisf
@since 07/11/2017
@version 1.0
@param aSubord, array, (Descrição do parâmetro)
@param cCodSup, character, (Descrição do parâmetro)
@param cCodComs, character, (Descrição do parâmetro)
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/  //------------------------------------------------------------------- 
Static Function VincVdSp(aSubord,cCodSup,cCodComs,oModel)
 
 	Local nVend		:= 0
 	Local aAreaG94	:= G94->(GetArea())
 	
 		For nVend	:= 1 to len(aSubord)
 		
 			if aSubord[nVend][1] == cCodSup
 			
 				dbSelectArea("G94")
 				G94->(dbSetOrder(3))//G94_FILIAL, G94_CODIGO, G94_SIMULA, R_E_C_N_O_, D_E_L_E_T_
 				if G94->(dbSeek(xFilial("G94")+aSubord[nVend][9]))	
	 				
	 				oModel:SetOperation(MODEL_OPERATION_UPDATE )				
					oModel:Activate()				
					oField	:= oModel:GetModel("G94MASTER")	
				
					oField:SetValue("G94_G94SUP",cCodComs)
					
					If oModel:VldData()
						
						FwFormCommit(oModel)		
						oModel:DeActivate()
					
					Else
						
						JurShowErro( oModel:GetModel():GetErrormessage() )
						lRet := .F.
						Exit
						
					EndIf
 				
 				EndIf
 				
 			EndIf
 			
 		Next nVend
 	
 	RestArea(aAreaG94)
 	
 Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PesqSup
Retorna o código do supervisor, supondo que exista somente Único supervisor
@type function
@author crisf
@since 07/11/2017
@version 1.0
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------
Static Function PesqSup(cCodVend, nNivel, cUnidNeg)

	Local cTmpAO3	:= GetNextAlias()
	Local cCodSup	:= ''
	
		 BeginSql Alias cTmpAO3
	
			SELECT AO3.AO3_VEND, AO3.AO3_CODEQP, AO3.AO3_CODUSR
			FROM %Table:AO3% AO3
			WHERE AO3.%NotDel%
			AND AO3.AO3_FILIAL = %xFilial:AO3%
			AND AO3.AO3_CODUND = %exp:cUnidNeg%
			AND AO3.AO3_NVESTN < %exp:nNivel%
			AND AO3.AO3_IDESTN = (SELECT SUBSTRING(AO3A.AO3_IDESTN,1,4)
							  FROM %Table:AO3% AO3A 
							  WHERE AO3A.%NotDel%
								AND AO3A.AO3_FILIAL = %xFilial:AO3%
								AND AO3A.AO3_CODUND = %exp:cUnidNeg%
								AND AO3A.AO3_NVESTN = %exp:nNivel%
								AND AO3A.AO3_VEND = %exp:cCodVend%)
		
			EndSql 
			//GetlastQuery()[2]
			if !(cTmpAO3)->(Eof())
			
				cCodSup	:= (cTmpAO3)->AO3_VEND

			EndIf
			
			(cTmpAO3)->(dbCloseArea())
			
Return cCodSup
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkEstor
(long_description)
@type function
@author crisf
@since 09/11/2017
@version 1.0
@param cCodVend, character, (Descrição do parâmetro)
@param nValrEst, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function ChkEstor(cCodVend, nVlEstVd, nVlEstSp, dDataDe, dDataAt)

	Local cCodComi	:= ''
	Local aTtEstor	:= {}
	Local nTtEstor	:= 0

		//Pesquisa o código do último fechamento - exportação para a folha
		PsqUlFec( cCodVend, @cCodComi )
			
		if !Empty(cCodComi)
		
			//Pesquisa quais titulos baixados entre o periodo de calculo da comissão anterior
			//foram estornado/cancelados a baixa e continuam em aberto ou baixado no periodo posterior
			PsqTtEst( cCodComi, @aTtEstor, Dtos(dDataDe), Dtos(dDataAt) )
			
			if len(aTtEstor) > 0
			
				For nTtEstor	:= 1 to len(aTtEstor)
				
					nVlEstVd	:= nVlEstVd+aTtEstor[nTtEstor][3]
					nVlEstSp	:= nVlEstSp+aTtEstor[nTtEstor][2]
					
				Next nTtEstor
			
			EndIf
			
		EndIf
			
Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PsqUlFec
Retorna o código do último período de fechamento/exportação para a folha
@type function
@author crisf
@since 09/11/2017
@version 1.0
@param cCodVend, character, (Descrição do parâmetro)
@param cCodComi, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function PsqUlFec(cCodVend,cCodComi)

	Local cTmpFech	:= GetNextAlias()
 
 		//Pesquiso o último período de fechamento do vendedor
	 	BeginSql Alias cTmpFech
				
		  SELECT G94.G94_CODIGO
		  FROM %Table:G94% G94
		  WHERE G94_FILIAL =  %xFilial:G94%
		    AND G94.G94_VEND =  %exp:cCodVend%
		    AND G94.%NotDel%
			AND G94_EXPFOL = (	SELECT MAX(EXPFOL.G94_EXPFOL) 
							    FROM %Table:G94% EXPFOL
								WHERE EXPFOL.G94_FILIAL = ' '
								    AND EXPFOL.G94_VEND =  %exp:cCodVend%
									AND EXPFOL.G94_EXPFOL <> ' '
									 AND G94.%NotDel%
									 )
			
		EndSql

		if !(cTmpFech)->(Eof())
		
			cCodComi	:= (cTmpFech)->G94_CODIGO
	
		EndIf
								  
		(cTmpFech)->(dbCloseArea())	
			
Return 
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PsqTtEst
(long_description)
@type function
@author crisf
@since 09/11/2017
@version 1.0
@param cCodComi, character, (Descrição do parâmetro)
@param aTtEstor, array, (Descrição do parâmetro)
@param dDataDe, data, (Descrição do parâmetro)
@param dDataAt, data, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function PsqTtEst(cCodComi, aTtEstor, cDataDe, cDataAt)

	Local cTmpGZJ	:= GetNextAlias()
	Local ntamchv	:=TamSx3("E1_FILIAL")[1]+TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+TamSX3("E1_TIPO")[1]
	Local cSelect	:= ''
	Local cAnd		:= ''
	Local lBOracle	:= Trim(TcGetDb()) = 'ORACLE'
		
		cSelect	:=	"	GZJ.GZJ_FILIAL, GZJ.GZJ_CODG94, GZJ.GZJ_SEQUEN, GZJ_VALCSP, GZJ_VALTSB,  "+CRLF
		
		if !lBOracle
		
		 	cSelect	+=	"	CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),GZJ_DADOS)) "+CRLF
			cAnd	:= " E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO = SUBSTRING(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),GZJ_DADOS)),1,"+Strzero(ntamchv)+")"
		Else

			cSelect	+=	"	 UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(GZJ_DADOS, 4000,1)) GZJ_DADOS "+CRLF
			cAnd	:= " E1_FILIAL|E1_CLIENTE|E1_LOJA|E1_PREFIXO|E1_NUM|E1_PARCELA|E1_TIPO = SUBSTRING(UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(GZJ_DADOS, 4000,1)),1,"+Strzero(ntamchv)+")"
		
		EndIf
	
		cSelect	:= '%'+cSelect+'%'
	    cAnd	:= '%'+cAnd+'%'
	    	
		BeginSql Alias cTmpGZJ
				
			SELECT %exp:cSelect%
			FROM %Table:GZJ% GZJ
			WHERE GZJ.GZJ_FILIAL =  %xFilial:GZJ%
			  AND GZJ.GZJ_CODG94 = %exp:cCodComi%
			  AND GZJ.%NotDel%
			  AND EXISTS(SELECT E1_NUM
							FROM %Table:SE1% SE1
							WHERE SE1.%NotDel%
							 AND %exp:cAnd%
							 AND (E1_BAIXA = ' ' OR E1_BAIXA BETWEEN %exp:cDataDe% AND %exp:cDataAt%)
						 )
		EndSql

		if !(cTmpGZJ)->(Eof())
		
			While !(cTmpGZJ)->(Eof())
			
				aAdd(aTtEstor,{(cTmpGZJ)->GZJ_SEQUEN, (cTmpGZJ)->GZJ_VALCSP, (cTmpGZJ)->GZJ_VALTSB})
			
			(cTmpGZJ)->(dbSkip())
			
			EndDo
			
		EndIf
								  
		(cTmpGZJ)->(dbCloseArea())		
		 
Return
//------------------------------------------------------------------- 
/*/{Protheus.doc} $ExistSup
(long_description)
@type function
@author crisf
@since 07/11/2017
@version 1.0
@param cCodSup, character, (Descrição do parâmetro)
@param cDtDe, character, (Descrição do parâmetro)
@param cDtAte, character, (Descrição do parâmetro)
@param nRecno, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------- 
Static Function ExistSup( cCodSup, cDtDe, cDtAte, nRecno )
 
 	Local cTmpG94	:= GetNextAlias()
 	
	 	BeginSql Alias cTmpG94
			
			SELECT ISNULL(G94.R_E_C_N_O_,0) RECNOG94
	 			FROM %Table:G94% G94
				WHERE G94.G94_FILIAL = %xFilial:G94%
			      AND G94.G94_VEND	 = %exp:cCodSup%
			      AND ( %Exp:cDtDe% BETWEEN G94_DATADE AND G94_DATATE OR
		      		%Exp:cDtAte% BETWEEN G94_DATADE AND G94_DATATE )
		      	  AND G94.G94_SIMULA = ' '
			      AND G94.%NOTDEL%
		
 		EndSql 		    
    	//GetlastQuery()[2]
	    
	    nRecno	:= (cTmpG94)->RECNOG94
	    
	    (cTmpG94)->(dbCloseArea())
	    
 Return 
 
Function GA418PreValid(oModel)
 
Local lRet	:= .t.

If ( oModel:GetOperation() == MODEL_OPERATION_DELETE )

	If ( !Empty(oModel:GetModel("G94MASTER"):GetValue("G94_EXPFOL")) )
		
		lRet := .f.
		
		FWAlertHelp("A comissão não poderá ser excluída","Quando existe um valor a ser pago em Folha, não é possível excluí-la. Primeiramente, a comissão, que fora exportada para a folha, deverá ser estornada.")
		  
	EndIf

EndIf
 
Return(lRet)

Function GA418RetFilVendMat(cVend,cFilVend)

Local cFilVendMat	:= ""

Local aDadosSA3		:= {}

Default cFilVend	:= xFilial("SA3")

aDadosSA3 := SA3->(GetAdvFVal("SA3",{"A3_NUMRA","A3_CGC"},cFilVend+cVend,1,{}))

If ( Len(aDadosSA3) > 0 )
	cFilVendMat := GA410RetFilMat(aDadosSA3[1],aDadosSA3[2])
EndIf

Return(cFilVendMat)


/*/
 * {Protheus.doc} GTPA815()
 * Retorna se existe registro na GQT
 * type    Function
 * author  Eduardo Ferreira
 * since   27/08/2020
 * version 12.1.30
 * param   cVend, cProd, cCod
 * return  lRet
/*/
Static Function RetGQT(cVend, cProd, cCod, nComissa)
Local cAliasGQT	:= GetNextAlias()
Local lRet      := .T.

BeginSql Alias cAliasGQT
	SELECT 
		GQT.GQT_CODIGO,
		GQT.GQT_CVEND ,
		GQT.GQT_PROD  ,
		GQT_COMISS
	FROM 
		%Table:GQT% GQT
	WHERE 
		GQT.GQT_FILIAL = %xFilial:GQT%
		AND GQT.GQT_CVEND = %exp:cVend%
		AND GQT.GQT_PROD = %exp:cProd%
		AND GQT.GQT_CODIGO = %exp:cCod%
		AND GQT.%NotDel%
EndSql 	

lRet := (cAliasGQT)->(!Eof())

if lRet
	nComissa := (cAliasGQT)->GQT_COMISS
EndIf

(cAliasGQT)->(DBCloseArea())

Return lRet
