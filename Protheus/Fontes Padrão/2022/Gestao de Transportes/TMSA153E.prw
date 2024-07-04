#INCLUDE 'PROTHEUS.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TMSA153E.ch'

Static cTipVei := " " //Variável com objetico de otimização de desempenho, utilizada para determinar os tipos de veículos conforme Contrato de Demanda e Grupo de Regiao
Static lAbrangCli := .F.
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA153E 
Estrutura da tela inclusão de demandas automáticas
@type function
@author Gustavo Henrique Baptista
@version 1.0
@since 03/05/2018
/*/ 
//-------------------------------------------------------------------------------------------------
Function TMSA153E()
Private oBrwDemAut  := Nil

Return

/*/{Protheus.doc} TMCONDEM
//Função para chamar a tela de geração de demandas automáticas ( dentro do contrato), sem os botões do menu.
@author gustavo.baptista
@since 11/05/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function TMCONDEM()
Local lRet := .T.
Local aButtons   := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0012/*"Gerar Demandas"*/},{.T.,STR0002/*Fechar*/},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //botão fechar
//Array do enable buttons{1 - Copiar,2 - Recortar,3 - Colar,4 - Calculadora,5 - Spool,6 - Imprimir,7 - Confirmar,8 - Cancelar,9 - WalkTrhough,10 - Ambiente,11 - Mashup,12 - Help,13 - Formulário HTML,14 - ECM}		

	lAbrangCli := DL7->DL7_ABRANG == '2'
	
	If DL7->DL7_STATUS == '4'
		If DL7->DL7_FIMVIG < DATE()
			MsgStop(STR0036)//O contrato está inativo e vencido.
			lRet := .F.
		Else
			MsgAlert(STR0037)//O contrato está inativo.
		EndIf
	Endif

	If lRet
		If DL7->DL7_STATUS <> '1' .AND. DL7->DL7_STATUS <> '4'
			MsgInfo(STR0013)//Só é possível gerar demandas para contratos Ativos ou Inativos.
			lRet := .F.			
		Else
			FWExecView(STR0001,"TMSA153E",4,,{|| .T.},,,aButtons) //Gerar Demandas
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} ModelDef
//Modelo de dados
@author gustavo.baptista
@since 03/05/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()
	Local oStruDL7  := MdoStruDL7()
	Local oModel	:= MPFormModel():New('TMSA153E', /*bPre*/, {|oModel| TMS153EPos(oModel)}, {|oModel| TMS153EGRV(oModel)}, /*bCancel*/) 
	Local oStruDLA := MdoStruDLA(oModel) 
	Local oStruDLL := FWFormStruct(1, 'DLL') 
	
	//Descricao
	oModel:SetDescription(STR0003)//"Demandas automáticas"
	
	//Field master
	oModel:addFields('MASTER_DL7',nil,oStruDL7)
	
	oStruDLA:RemoveField('DLA_CODDMD')
	oStruDLA:RemoveField('DLA_SEQDMD')
	
	oStruDLL:RemoveField('DLL_CODDMD')
	oStruDLL:RemoveField('DLL_SEQDMD')
	
	//Adiciona os grids
	oModel:AddGrid('GRID_ORI' ,'MASTER_DL7',oStruDLA, , ,{| oDlOri,nLine,cOpera | TMS153EVLD( oDlOri, nLine, cOpera)} , ,{|oModelOri|T153ELdOri()} )
	oModel:AddGrid('GRID_DES' ,'MASTER_DL7',oStruDLL,,,,,{|oModelDes|T153ELdDes()})
	
	//Grid nao obrigatorio 
	oModel:GetModel('GRID_ORI'):SetOptional(.T.)
	oModel:GetModel('GRID_DES'):SetOptional(.T.)
	
	oModel:GetModel('GRID_ORI'):SetDescription(STR0004)//"Regiões de Origem"
	oModel:GetModel('GRID_DES'):SetDescription(STR0005)//"Regiões de Destino"
	
	oModel:GetModel( 'GRID_ORI' ):SetUniqueLine( {'DLA_CODREG'} )
	oModel:GetModel( 'GRID_DES' ):SetUniqueLine( {'DLL_CODREG'} )

	oModel:SetOnlyQuery('GRID_ORI',.T.)
	oModel:SetOnlyQuery('GRID_DES',.T.)
	oModel:SetOnlyQuery('MASTER_DL7',.T.)

	oStruDL7:SetProperty('DL7_DTPREV', MODEL_FIELD_VALID,{|oModel|TM153EVld('DL7_DTPREV','0',oModel:GetModel())})	
	oStruDL7:SetProperty('DL7_HRPREV', MODEL_FIELD_VALID,{|oModel|TM153EVld('DL7_HRPREV','0',oModel:GetModel())})

	oStruDLA:SetProperty('DLA_DTPREV', MODEL_FIELD_VALID,{|oModel|TM153EVld('DLA_DTPREV',"1",oModel:GetModel())})
	oStruDLA:SetProperty('DLA_HRPREV', MODEL_FIELD_VALID,{|oModel|TM153EVld('DLA_HRPREV',"1",oModel:GetModel())})

	oStruDLA:SetProperty("DLA_QTD", MODEL_FIELD_WHEN,{|oModel|iif(oModel:GetModel():GetValue("MASTER_DL7","DL7_UM")=='1',.T.,.F.)})
	
	
	oStruDL7:SetProperty("DL7_TIPVEI", MODEL_FIELD_WHEN,{|oModel|TM153EWHEN('DL7_TIPVEI',oModel:GetModel())})
	oStruDL7:SetProperty('DL7_TIPVEI', MODEL_FIELD_VALID,{|oModel|TM153EVld('DL7_TIPVEI',"0",oModel:GetModel())})

	
	oStruDL7:SetProperty('DL7_LOJTMP', MODEL_FIELD_VALID,{|oModel|T153EVLDLJ('DL7_LOJTMP',oModel)})

	oStruDL7:SetProperty('DL7_LOJTMP', MODEL_FIELD_WHEN,{||lAbrangCli})	

	oStruDL7:SetProperty("DL7_NOMTMP", MODEL_FIELD_INIT,{|oModel|T153ENmCli(oModel)})

	oStruDLA:SetProperty("DLA_SEQREG", MODEL_FIELD_WHEN,{||.F.})
	oStruDLL:SetProperty("DLL_SEQREG", MODEL_FIELD_WHEN,{||.F.})

	oStruDLA:SetProperty("DLA_PREVIS", MODEL_FIELD_INIT,{||'2'})
	oStruDLL:SetProperty("DLL_PREVIS", MODEL_FIELD_INIT,{||'2'})

	//Remove inicializador padrao
	oStruDLA:SetProperty("DLA_NOMREG", MODEL_FIELD_INIT,{||''})
	oStruDLL:SetProperty("DLL_NOMREG", MODEL_FIELD_INIT,{||''})

	oStruDLA:SetProperty('DLA_CODCLI', MODEL_FIELD_VALID,{|oModel|TM153EVld('DLA_CODCLI',"1",oModel:GetModel())})
	oStruDLA:SetProperty('DLA_LOJA', MODEL_FIELD_VALID,{|oModel|TM153EVld('DLA_LOJA',"1",oModel:GetModel())})

	oStruDLA:SetProperty("DLA_CODCLI", MODEL_FIELD_INIT,{|oModel|oModel:GetModel():GetValue("MASTER_DL7","DL7_CLIDEV")})
	oStruDLA:SetProperty("DLA_LOJA", MODEL_FIELD_INIT,{|oModel|oModel:GetModel():GetValue("MASTER_DL7","DL7_LOJTMP")})
	oStruDLA:SetProperty("DLA_NOMCLI", MODEL_FIELD_INIT,{|oModel|T153ENmCli(oModel)}) 

	oStruDLA:AddTrigger('DLA_DTPREV' , 'DLA_DTPREV', {||.T.}, {|oModel|GatilhoDL7(oModel,'DLA_DTPREV','1')})
	oStruDLA:AddTrigger('DLA_CODREG' , 'DLA_CODREG', {||.T.}, {|oModel|GatilhoDL7(oModel,'DLA_CODREG','1')})

	oStruDLL:SetProperty('DLL_DTPREV', MODEL_FIELD_VALID,{|oModel|TM153EVld('DLL_DTPREV',"2",oModel:GetModel())})
	oStruDLL:SetProperty('DLL_HRPREV', MODEL_FIELD_VALID,{|oModel|TM153EVld('DLL_HRPREV',"2",oModel:GetModel())})
	oStruDLL:AddTrigger('DLL_DTPREV' , 'DLL_DTPREV', {||.T.}, {|oModel|GatilhoDL7(oModel,'DLL_DTPREV','2')})
	oStruDLL:AddTrigger('DLL_CODREG' , 'DLL_CODREG', {||.T.}, {|oModel|GatilhoDL7(oModel,'DLL_CODREG','2')})

	oModel:SetPrimaryKey( {} )
	
Return oModel

/*/{Protheus.doc} ViewDef
//View
@author gustavo.baptista
@since 03/05/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()
	Local oModel   := FWLoadModel('TMSA153E')
	Local oStruDL7 := VwStruDL7(oModel)
	Local oStruDLA := VwStruDLA(oModel)
	Local oStruDLL := FWFormStruct(2, 'DLL')
	Local bBloco := "{|oView| .F.}"
	Local oView
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	//Seta o model para a view
	oView:SetModel(oModel)
	oView:AddField( 'VIEW_DL7', oStruDL7, 'MASTER_DL7' )
	
	oStruDLL:RemoveField( 'DLL_CODDMD' )
	oStruDLL:RemoveField( 'DLL_SEQDMD' )
	
	//Divide a tela principal em duas partes cima e baixo
	oView:CreateVerticalBox('BOX_MAIN', 100,,/*lPixel*/)
	
	oView:CreateHorizontalBox('BOX_CABEC', 42,'BOX_MAIN',/*lPixel*/)
	oView:CreateHorizontalBox('BOX_DETAIL' , 58,'BOX_MAIN',/*lPixel*/)
	
	oView:CreateVerticalBox('BOX_REGORI', 50,'BOX_DETAIL',/*lPixel*/)
	oView:CreateVerticalBox('BOX_REGDES', 50,'BOX_DETAIL',/*lPixel*/)

	oView:addGrid('GRID_ORI',oStruDLA,'GRID_ORI')
	oView:addGrid('GRID_DES',oStruDLL,'GRID_DES')

	oView:AddIncrementField( 'GRID_ORI', 'DLA_SEQREG' )
	oView:AddIncrementField( 'GRID_DES', 'DLL_SEQREG' )
	
	oView:EnableTitleView('GRID_ORI', STR0010) //Região Origem 
	oView:EnableTitleView('GRID_DES', STR0011) //Região Destino

	//Vincula os browses aos box			
	oView:SetOwnerView( 'GRID_ORI', 'BOX_REGORI' )	
	oView:SetOwnerView( 'GRID_DES', 'BOX_REGDES' )
	
	oView:SetOwnerView( 'VIEW_DL7', 'BOX_CABEC')
	
	oView:SetAfterViewActivate({|oView| AfterVwAct(oView) })

Return oView

/*/{Protheus.doc} MdoStruDL7
//Gera modelo do cabeçalho
@author gustavo.baptista
@since 03/05/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MdoStruDL7() 
	Local oStruDL7 := FWFormStruct(1, 'DL7', {|x| ALLTRIM(x) $ 'DL7_COD, DL7_CLIDEV, DL7_LOJDEV, DL7_NOMDEV, DL7_ABRANG, DL7_UM, DL7_INIVIG, DL7_FIMVIG'} )
			 
	oStruDL7:SetProperty('DL7_COD'	 , MODEL_FIELD_WHEN,{||.F.})
	oStruDL7:SetProperty('DL7_CLIDEV', MODEL_FIELD_WHEN,{||.F.})
	oStruDL7:SetProperty('DL7_UM'	 , MODEL_FIELD_WHEN,{||.F.})
	oStruDL7:SetProperty('DL7_INIVIG', MODEL_FIELD_WHEN,{||.F.})
	oStruDL7:SetProperty('DL7_FIMVIG', MODEL_FIELD_WHEN,{||.F.})
	oStruDL7:SetProperty('DL7_ABRANG', MODEL_FIELD_WHEN,{||.F.})

	oStruDL7:RemoveField("DL7_LOJDEV")
	oStruDL7:RemoveField("DL7_NOMDEV")

	oStruDL7:AddField(STR0043														,;	// 	[01]  C   Titulo do campo  
					  STR0043														,;	// 	[02]  C   ToolTip do campo
					 'DL7_LOJTMP'		     										,;	// 	[03]  C   Id do Field
					 "C"															,;	// 	[04]  C   Tipo do campo
					 TAMSX3("DL7_LOJDEV")[1]										,;	// 	[05]  N   Tamanho do campo
					 0																,;	// 	[06]  N   Decimal do campo
					 NIL															,;	// 	[07]  B   Code-block de validação do campo
					 NIL															,;	// 	[08]  B   Code-block de validação When do campo
					 NIL															,;	//	[09]  A   Lista de valores permitido do campo
					 .T.															,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					  {||DL7->DL7_LOJDEV}	  						                ,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL															,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL															,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.															)	// 	[14]  L   Indica se o campo é virtual			

	oStruDL7:AddField(STR0044														,;	// 	[01]  C   Titulo do campo  
					  STR0044 													   ,;	// 	[02]  C   ToolTip do campo
					 'DL7_NOMTMP'		     										,;	// 	[03]  C   Id do Field
					 "C"															,;	// 	[04]  C   Tipo do campo
					 TAMSX3("A1_NOME")[1]										    ,;	// 	[05]  N   Tamanho do campo
					 0																,;	// 	[06]  N   Decimal do campo
					 NIL															,;	// 	[07]  B   Code-block de validação do campo
					 NIL															,;	// 	[08]  B   Code-block de validação When do campo
					 NIL															,;	//	[09]  A   Lista de valores permitido do campo
					 .F.															,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL                     						                ,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL															,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL															,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.															)	// 	[14]  L   Indica se o campo é virtual	
		
	
	oStruDL7:AddField(STR0020														,;	// 	[01]  C   Titulo do campo  
					  STR0020														,;	// 	[02]  C   ToolTip do campo
					 'DLE_CODGRD'		     										,;	// 	[03]  C   Id do Field
					 "C"															,;	// 	[04]  C   Tipo do campo
					 TAMSX3("DLE_CODGRD")[1]										,;	// 	[05]  N   Tamanho do campo
					 0																,;	// 	[06]  N   Decimal do campo
					 NIL															,;	// 	[07]  B   Code-block de validação do campo
					 NIL															,;	// 	[08]  B   Code-block de validação When do campo
					 NIL															,;	//	[09]  A   Lista de valores permitido do campo
					 .F.															,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 {||DLE->DLE_CODGRD}											,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL															,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL															,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.															)	// 	[14]  L   Indica se o campo é virtual
					 
	oStruDL7:AddField(STR0021														,;	// 	[01]  C   Titulo do campo  
					  STR0021														,;	// 	[02]  C   ToolTip do campo
					 'DLE_DESGRD'		     										,;	// 	[03]  C   Id do Field
					 "C"															,;	// 	[04]  C   Tipo do campo
					 TAMSX3("DLC_DESCRI")[1]										,;	// 	[05]  N   Tamanho do campo
					 0																,;	// 	[06]  N   Decimal do campo
					 NIL															,;	// 	[07]  B   Code-block de validação do campo
					 NIL															,;	// 	[08]  B   Code-block de validação When do campo
					 NIL															,;	//	[09]  A   Lista de valores permitido do campo
					 .F.															,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 {||Posicione('DLC', 1, xFilial('DLC') + DLE->DLE_CODGRD, 'DLC_DESCRI')},;	//	[11]  B   Code-block de inicializacao do campo
					 NIL															,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL															,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.															)	// 	[14]  L   Indica se o campo é virtual
					 
	oStruDL7:AddField(STR0022														,;	// 	[01]  C   Titulo do campo  
					  STR0022														,;	// 	[02]  C   ToolTip do campo
					 'DLE_QTD'		     											,;	// 	[03]  C   Id do Field
					 "N"															,;	// 	[04]  C   Tipo do campo
					 TAMSX3("DLE_QTD")[1]											,;	// 	[05]  N   Tamanho do campo
					 4																,;	// 	[06]  N   Decimal do campo
					 NIL															,;	// 	[07]  B   Code-block de validação do campo
					 NIL															,;	// 	[08]  B   Code-block de validação When do campo
					 NIL															,;	//	[09]  A   Lista de valores permitido do campo
					 .T.															,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 {||DLE->DLE_QTD}												,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL															,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL															,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.															)	// 	[14]  L   Indica se o campo é virtual

	oStruDL7:AddField(STR0023														,;	// 	[01]  C   Titulo do campo  
					  STR0023														,;	// 	[02]  C   ToolTip do campo
					 'DL7_FILEXE'		     										,;	// 	[03]  C   Id do Field
					 "C"															,;	// 	[04]  C   Tipo do campo
					 TamSX3('DL7_FILIAL')[1]										,;	// 	[05]  N   Tamanho do campo
					 0																,;	// 	[06]  N   Decimal do campo
					 FwBuildFeature( STRUCT_FEATURE_VALID,"ExistCpo('SM0', cEmpAnt+M->DL7_FILEXE)")	,;	// 	[07]  B   Code-block de validação do campo
					 NIL															,;	// 	[08]  B   Code-block de validação When do campo
					 NIL															,;	//	[09]  A   Lista de valores permitido do campo
					 .T.															,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 {||cFilAnt}													,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL															,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL															,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.															)	// 	[14]  L   Indica se o campo é virtual
					 
	oStruDL7:AddField(STR0024														,;	// 	[01]  C   Titulo do campo  
					  STR0024														,;	// 	[02]  C   ToolTip do campo
					 'DL7_TIPVEI'		     										,;	// 	[03]  C   Id do Field
					 "C"															,;	// 	[04]  C   Tipo do campo
					 TamSX3('DUT_TIPVEI')[1]										,;	// 	[05]  N   Tamanho do campo
					 0																,;	// 	[06]  N   Decimal do campo
					 FwBuildFeature( STRUCT_FEATURE_VALID, "T153VLTVEI()"),;  // [07]  B   Code-block de validação do campo
					 NIL															,;	// 	[08]  B   Code-block de validação When do campo
					 NIL															,;	//	[09]  A   Lista de valores permitido do campo
					 .F.															,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL															,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL															,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL															,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .F.															)	// 	[14]  L   Indica se o campo é virtual
					 
	oStruDL7:AddField(STR0025														,;	// 	[01]  C   Titulo do campo  
					  STR0025														,;	// 	[02]  C   ToolTip do campo
					 'DL7_DESVEI'		     										,;	// 	[03]  C   Id do Field
					 "C"															,;	// 	[04]  C   Tipo do campo
					 TamSX3('DUT_DESCRI')[1]										,;	// 	[05]  N   Tamanho do campo
					 0																,;	// 	[06]  N   Decimal do campo
					 NIL															,;	// 	[07]  B   Code-block de validação do campo
					 NIL															,;	// 	[08]  B   Code-block de validação When do campo
					 NIL															,;	//	[09]  A   Lista de valores permitido do campo
					 .F.															,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL															,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL															,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL															,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.															)	// 	[14]  L   Indica se o campo é virtual

	oStruDL7:AddField(STR0007														,;	// 	[01]  C   Titulo do campo  
					  STR0007														,;	// 	[02]  C   ToolTip do campo
					 'DL7_QTDCON'		     										,;	// 	[03]  C   Id do Field
					 "N"															,;	// 	[04]  C   Tipo do campo
					 14																,;	// 	[05]  N   Tamanho do campo
					 4																,;	// 	[06]  N   Decimal do campo
					 NIL															,;	// 	[07]  B   Code-block de validação do campo
					 NIL															,;	// 	[08]  B   Code-block de validação When do campo
					 NIL															,;	//	[09]  A   Lista de valores permitido do campo
					 .T.															,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL															,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL															,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL															,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .F.															)	// 	[14]  L   Indica se o campo é virtual
					 
	oStruDL7:AddField(STR0008														,;	// 	[01]  C   Titulo do campo  
					  STR0008														,;	// 	[02]  C   ToolTip do campo
					 'DL7_QTDDMD'		     										,;	// 	[03]  C   Id do Field
					 "N"															,;	// 	[04]  C   Tipo do campo
					 14																,;	// 	[05]  N   Tamanho do campo
					 0																,;	// 	[06]  N   Decimal do campo
					 NIL															,;	// 	[07]  B   Code-block de validação do campo
					 NIL															,;	// 	[08]  B   Code-block de validação When do campo
					 NIL															,;	//	[09]  A   Lista de valores permitido do campo
					 .T.															,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL															,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL															,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL															,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .F.															)	// 	[14]  L   Indica se o campo é virtual
					 
	oStruDL7:AddField(STR0009														,;	// 	[01]  C   Titulo do campo  
					  STR0009														,;	// 	[02]  C   ToolTip do campo
					 'DL7_QTDBAS'		     										,;	// 	[03]  C   Id do Field
					 "N"															,;	// 	[04]  C   Tipo do campo
					 14																,;	// 	[05]  N   Tamanho do campo
					 4																,;	// 	[06]  N   Decimal do campo
					 NIL															,;	// 	[07]  B   Code-block de validação do campo
					 NIL															,;	// 	[08]  B   Code-block de validação When do campo
					 NIL															,;	//	[09]  A   Lista de valores permitido do campo
					 .F.															,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 {||iIf (DL7->DL7_UM =='2', 1, 0)}								,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL															,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL															,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.															)	// 	[14]  L   Indica se o campo é virtual

	oStruDL7:AddField(STR0026														,;	// 	[01]  C   Titulo do campo  
					  STR0026														,;	// 	[02]  C   ToolTip do campo
					 'DL7_DTPREV'		     										,;	// 	[03]  C   Id do Field
					 "D"															,;	// 	[04]  C   Tipo do campo
					 8																,;	// 	[05]  N   Tamanho do campo
					 0																,;	// 	[06]  N   Decimal do campo
					 NIL															,;	// 	[07]  B   Code-block de validação do campo
					 NIL															,;	// 	[08]  B   Code-block de validação When do campo
					 NIL															,;	//	[09]  A   Lista de valores permitido do campo
					 .F.															,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL															,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL															,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL															,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.															)	// 	[14]  L   Indica se o campo é virtual
					 
	oStruDL7:AddField(STR0027														,;	// 	[01]  C   Titulo do campo  
					  STR0027														,;	// 	[02]  C   ToolTip do campo
					 'DL7_HRPREV'		     										,;	// 	[03]  C   Id do Field
					 "C"															,;	// 	[04]  C   Tipo do campo
					 5                    											,;	// 	[05]  N   Tamanho do campo
					 0																,;	// 	[06]  N   Decimal do campo
					 NIL															,;	// 	[07]  B   Code-block de validação do campo
					 NIL															,;	// 	[08]  B   Code-block de validação When do campo
					 NIL															,;	//	[09]  A   Lista de valores permitido do campo
					 .F.															,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL															,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL															,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL															,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.															)	// 	[14]  L   Indica se o campo é virtual
					 
					 
	oStruDL7:AddTrigger("DL7_QTDCON", "DL7_QTDCON", {||.T.}, {|oModel|GatilhoDL7(oModel,"DL7_QTDCON","1")})
	oStruDL7:AddTrigger("DL7_QTDDMD", "DL7_QTDDMD", {||.T.}, {|oModel|GatilhoDL7(oModel,"DL7_QTDDMD","1")})
	oStruDL7:AddTrigger('DL7_TIPVEI', 'DL7_TIPVEI', {||.T.}, {|oModel|GatilhoDL7(oModel,'DL7_TIPVEI')})
	
	
Return oStruDL7

/*/{Protheus.doc} MdoStruDLA
//Função para carregar a estrutura da DLA e permitir que o campo quantidade seja carrergado com 0 na inicialização.
@author wander.horongoso
@since 18/06/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, Modelo da tela
@param cGrid, characters, indica se será Grid de região origem ou destino.
@type function
/*/
Static Function MdoStruDLA(oModel) 
Local oStruDLA := FWFormStruct(1, 'DLA')
	
	oStruDLA:RemoveField('DLA_QTD')			 
	
	oStruDLA:AddField(STR0028											,;	// 	[01]  C   Titulo do campo  
					  STR0028											,;	// 	[02]  C   ToolTip do campo
					 'DLA_QTD'		     								,;	// 	[03]  C   Id do Field
					 "N"												,;	// 	[04]  C   Tipo do campo
					 TamSX3('DLA_QTD')[1]					     		,;	// 	[05]  N   Tamanho do campo
					 4													,;	// 	[06]  N   Decimal do campo
					 NIL												,;	// 	[07]  B   Code-block de validação do campo
					 NIL												,;	// 	[08]  B   Code-block de validação When do campo
					 NIL												,;	//	[09]  A   Lista de valores permitido do campo
					 .F.												,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL												,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL												,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL												,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.												)	// 	[14]  L   Indica se o campo é virtual
	
	oStruDLA:AddTrigger("DLA_QTD", "DLA_QTD", {||.T.}, {|oModel|GatQtdDLA(oModel)})
	
	oStruDLA:SetProperty('*', MODEL_FIELD_OBRIGAT,.F.)

Return oStruDLA

/*/{Protheus.doc} VwStruDL7
//Gera view do cabeçalho
@author gustavo.baptista
@since 03/05/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function VwStruDL7(oModel) 
	Local oStruDL7 := FWFormStruct(2, 'DL7', {|x| ALLTRIM(x) $ 'DL7_COD, DL7_CLIDEV, DL7_LOJDEV, DL7_NOMDEV, DL7_ABRANG, DL7_UM, DL7_INIVIG, DL7_FIMVIG'} )
	Local cMask:= "@E 999,999,999.9999"
	
	If DL7->DL7_UM == '2'
		cMask:= "@E 999,999,999"
	Else
		cMask:= "@E 999,999,999.9999"
	EndIf

	oStruDL7:RemoveField("DL7_LOJDEV")

	oStruDL7:RemoveField("DL7_NOMDEV")

	oStruDL7:AddField("DL7_LOJTMP"	     											,;	// [01]  C   Nome do Campo
						"2"															,;	// [02]  C   Ordem
						STR0043														,;	// [03]  C   Titulo do campo//"Descrição"
						STR0043														,;	// [04]  C   Descricao do campo//"Descrição"
						{STR0047}													,;	// [05]  A   Array com Help						//STR0046 - 'Loja do Devedor'						
						"C"															,;	// [06]  C   Tipo do campo
						""															,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var {|cMask|PICVARQTDM(cMask,oModel)}
						"DL7LOJ"													,;	// [09]  C   Consulta F3
						.T.															,;	// [10]  L   Indica se o campo é alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						.T.															,;	// [16]  L   Indica se o campo é virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha após o campo

	oStruDL7:AddField("DL7_NOMTMP"		     										,;	// [01]  C   Nome do Campo
						"3"															,;	// [02]  C   Ordem
						STR0044														,;	// [03]  C   Titulo do campo//"Descrição"
						STR0044														,;	// [04]  C   Descricao do campo//"Descrição"
						{STR0048}													,;	// [05]  A   Array com Help						//STR0048 - 'Nome do Devedor'
						"C"															,;	// [06]  C   Tipo do campo
						""															,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var {|cMask|PICVARQTDM(cMask,oModel)}
						""															,;	// [09]  C   Consulta F3
						.F.															,;	// [10]  L   Indica se o campo é alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						.T.															,;	// [16]  L   Indica se o campo é virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha após o campo							
	
	oStruDL7:AddField("DLE_CODGRD"		     										,;	// [01]  C   Nome do Campo
						"19"														,;	// [02]  C   Ordem
						STR0020														,;	// [03]  C   Titulo do campo//"Descrição"
						STR0020														,;	// [04]  C   Descricao do campo//"Descrição"
						{STR0049}													,;	// [05]  A   Array com Help						//STR0049 - {'Código Grupo de Região'}
						"C"															,;	// [06]  C   Tipo do campo
						"@!"														,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var {|cMask|PICVARQTDM(cMask,oModel)}
						""															,;	// [09]  C   Consulta F3
						.F.															,;	// [10]  L   Indica se o campo é alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						.T.															,;	// [16]  L   Indica se o campo é virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha após o campo

	oStruDL7:AddField("DLE_DESGRD"		     										,;	// [01]  C   Nome do Campo
						"20"														,;	// [02]  C   Ordem
						STR0021														,;	// [03]  C   Titulo do campo//"Descrição"
						STR0021														,;	// [04]  C   Descricao do campo//"Descrição"
						{STR0050}													,;	// [05]  A   Array com Help						//STR0050 - 'Descrição Grupo de Região'
						"C"															,;	// [06]  C   Tipo do campo
						"@!"														,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var {|cMask|PICVARQTDM(cMask,oModel)}
						""															,;	// [09]  C   Consulta F3
						.F.															,;	// [10]  L   Indica se o campo é alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						.T.															,;	// [16]  L   Indica se o campo é virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha após o campo

	oStruDL7:AddField("DLE_QTD"		     											,;	// [01]  C   Nome do Campo
						"21"														,;	// [02]  C   Ordem
						STR0022														,;	// [03]  C   Titulo do campo//"Descrição"
						STR0022														,;	// [04]  C   Descricao do campo//"Descrição"
						{STR0051}													,;	// [05]  A   Array com Help						//STR0051 - 'Quantidade do Grupo de Região'
						"N"															,;	// [06]  C   Tipo do campo
						cMask														,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var {|cMask|PICVARQTDM(cMask,oModel)}
						""															,;	// [09]  C   Consulta F3
						.F.															,;	// [10]  L   Indica se o campo é alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						.T.															,;	// [16]  L   Indica se o campo é virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha após o campo

	oStruDL7:AddField("DL7_FILEXE"		     										,;	// [01]  C   Nome do Campo
						"22"														,;	// [02]  C   Ordem
						STR0023														,;	// [03]  C   Titulo do campo//"Descrição"
						STR0023														,;	// [04]  C   Descricao do campo//"Descrição"
						{STR0052}													,;	// [05]  A   Array com Help						//STR0052 - 'Filial de Execução'
						"C"															,;	// [06]  C   Tipo do campo
						""															,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var {|cMask|PICVARQTDM(cMask,oModel)}
						"XM0"														,;	// [09]  C   Consulta F3
						.T.															,;	// [10]  L   Indica se o campo é alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						.T.															,;	// [16]  L   Indica se o campo é virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha após o campo

	oStruDL7:AddField("DL7_TIPVEI"		     										,;	// [01]  C   Nome do Campo
						"23"														,;	// [02]  C   Ordem
						STR0024														,;	// [03]  C   Titulo do campo//"Descrição"
						STR0024														,;	// [04]  C   Descricao do campo//"Descrição"
						{STR0053}													,;	// [05]  A   Array com Help						//STR0053 - 'Tipo do Veículo da Meta'
						"C"															,;	// [06]  C   Tipo do campo
						""															,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var {|cMask|PICVARQTDM(cMask,oModel)}
						"DUT3"														,;	// [09]  C   Consulta F3
						.T.															,;	// [10]  L   Indica se o campo é alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						.T.															,;	// [16]  L   Indica se o campo é virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha após o campo
					 
	oStruDL7:AddField("DL7_DESVEI"		     										,;	// [01]  C   Nome do Campo
						"24"														,;	// [02]  C   Ordem
						STR0025														,;	// [03]  C   Titulo do campo//"Descrição"
						STR0025														,;	// [04]  C   Descricao do campo//"Descrição"
						{STR0054}													,;	// [05]  A   Array com Help						//STR0054 - 'Descrição do Tipo de Veículo da Meta'
						"C"															,;	// [06]  C   Tipo do campo
						""															,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var {|cMask|PICVARQTDM(cMask,oModel)}
						""															,;	// [09]  C   Consulta F3
						.F.															,;	// [10]  L   Indica se o campo é alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						.T.															,;	// [16]  L   Indica se o campo é virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha após o campo
					 
	oStruDL7:AddField("DL7_QTDCON"		     										,;	// [01]  C   Nome do Campo
						"25"														,;	// [02]  C   Ordem
						STR0007														,;	// [03]  C   Titulo do campo//"Descrição"
						STR0007														,;	// [04]  C   Descricao do campo//"Descrição"
						{STR0055}													,;	// [05]  A   Array com Help						//STR0055 - 'Quantidade a Consumir'
						"N"															,;	// [06]  C   Tipo do campo
						cMask														,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var {|cMask|PICVARQTDM(cMask,oModel)}
						""															,;	// [09]  C   Consulta F3
						.T.															,;	// [10]  L   Indica se o campo é alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						.F.															,;	// [16]  L   Indica se o campo é virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha após o campo
						
	oStruDL7:AddField("DL7_QTDDMD"		     										,;	// [01]  C   Nome do Campo
						"26"														,;	// [02]  C   Ordem
						STR0008														,;	// [03]  C   Titulo do campo//"Descrição"
						STR0008														,;	// [04]  C   Descricao do campo//"Descrição"
						{STR0056}													,;	// [05]  A   Array com Help						//STR0056 - 'Quantidade Demandas'
						"N"															,;	// [06]  C   Tipo do campo
						"@E 99999"													,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var {|cMask|PICVARQTDM(cMask,oModel)}
						""															,;	// [09]  C   Consulta F3
						iif(DL7->DL7_UM=='1',.T.,.F.)								,;	// [10]  L   Indica se o campo é alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						.F.															,;	// [16]  L   Indica se o campo é virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha após o campo
	
	oStruDL7:AddField("DL7_QTDBAS"		     										,;	// [01]  C   Nome do Campo
						"27"														,;	// [02]  C   Ordem
						STR0009														,;	// [03]  C   Titulo do campo//"Descrição"
						STR0009														,;	// [04]  C   Descricao do campo//"Descrição"
						{STR0057}													,;	// [05]  A   Array com Help						//STR0057 - 'Quantidade Base'
						"N"															,;	// [06]  C   Tipo do campo
						"@E 999,999,999.9999"										,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var {|cMask|PICVARQTDM(cMask,oModel)}
						""															,;	// [09]  C   Consulta F3
						.F.															,;	// [10]  L   Indica se o campo é alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						.T.															,;	// [16]  L   Indica se o campo é virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha após o campo

	oStruDL7:AddField("DL7_DTPREV"		     										,;	// [01]  C   Nome do Campo
						"28"														,;	// [02]  C   Ordem
						STR0026														,;	// [03]  C   Titulo do campo//"Descrição"
						STR0026														,;	// [04]  C   Descricao do campo//"Descrição"
						{STR0058}													,;	// [05]  A   Array com Help						//STR0058 - 'Data Previsão de Atendimento'
						"D"															,;	// [06]  C   Tipo do campo
						""															,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var {|cMask|PICVARQTDM(cMask,oModel)}
						""															,;	// [09]  C   Consulta F3
						.T.															,;	// [10]  L   Indica se o campo é alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						.T.															,;	// [16]  L   Indica se o campo é virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha após o campo

	oStruDL7:AddField("DL7_HRPREV"		     										,;	// [01]  C   Nome do Campo
						"29"														,;	// [02]  C   Ordem
						STR0027														,;	// [03]  C   Titulo do campo//"Descrição"
						STR0027														,;	// [04]  C   Descricao do campo//"Descrição"
						{STR0059}													,;	// [05]  A   Array com Help						//STR0059 - 'Hora Previsão de Atendimento'
						"C"															,;	// [06]  C   Tipo do campo
						"@R 99:99"													,;	// [07]  C   Picture
						NIL															,;	// [08]  B   Bloco de Picture Var {|cMask|PICVARQTDM(cMask,oModel)}
						""															,;	// [09]  C   Consulta F3
						.T.															,;	// [10]  L   Indica se o campo é alteravel
						NIL															,;	// [11]  C   Pasta do campo
						NIL															,;	// [12]  C   Agrupamento do campo
						NIL															,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL															,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL															,;	// [15]  C   Inicializador de Browse
						.T.															,;	// [16]  L   Indica se o campo é virtual
						NIL															,;	// [17]  C   Picture Variavel
						NIL															)	// [18]  L   Indica pulo de linha após o campo

	oStruDL7:SetProperty('DL7_COD', MVC_VIEW_ORDEM, '00')
	oStruDL7:SetProperty('DL7_CLIDEV', MVC_VIEW_ORDEM, '02')
	oStruDL7:SetProperty('DL7_LOJTMP', MVC_VIEW_ORDEM, '03')
	oStruDL7:SetProperty('DL7_NOMTMP', MVC_VIEW_ORDEM, '04')
	oStruDL7:SetProperty('DL7_ABRANG', MVC_VIEW_ORDEM, '05')

Return oStruDL7

Static Function VwStruDLA(oModel) 
Local oStruDLA := FWFormStruct(2, 'DLA')
	
	If DL7->DL7_UM == '2'
		cMask:= "@E 999,999,999"
	Else
		cMask:= "@E 999,999,999.9999"
	EndIf

	oStruDLA:RemoveField( 'DLA_CODDMD' )
	oStruDLA:RemoveField( 'DLA_SEQDMD' )
	oStruDLA:RemoveField( 'DLA_QTD' )

	oStruDLA:AddField("DLA_QTD"									,;	// [01]  C   Nome do Campo
	 				  "6"										,;	// [02]  C   Ordem
					  STR0028									,;	// [03]  C   Titulo do campo//"Descrição"
					  STR0028									,;	// [04]  C   Descricao do campo//"Descrição"
					  {STR0060}									,;	// [05]  A   Array com Help						//STR0060 - 'Quantidade por região. Esta quantidade será levada em consideração na montagem da viagem.'
					  "N"										,;	// [06]  C   Tipo do campo
					  cMask										,;	// [07]  C   Picture
					  NIL										,;	// [08]  B   Bloco de Picture Var {|cMask|PICVARQTDM(cMask,oModel)}
					  ""										,;	// [09]  C   Consulta F3
					  .T.										,;	// [10]  L   Indica se o campo é alteravel
					  NIL										,;	// [11]  C   Pasta do campo
					  NIL										,;	// [12]  C   Agrupamento do campo
					  NIL										,;	// [13]  A   Lista de valores permitido do campo (Combo)
					  NIL										,;	// [14]  N   Tamanho maximo da maior opção do combo
					  NIL										,;	// [15]  C   Inicializador de Browse
					  .T.										,;	// [16]  L   Indica se o campo é virtual
					  NIL										,;	// [17]  C   Picture Variavel
					  NIL										)	// [18]  L   Indica pulo de linha após o campo

	oStruDLA:SetProperty('DLA_SEQREG', MVC_VIEW_ORDEM, '0')
	oStruDLA:SetProperty('DLA_CODREG', MVC_VIEW_ORDEM, '1')
	oStruDLA:SetProperty('DLA_NOMREG', MVC_VIEW_ORDEM, '2')
	oStruDLA:SetProperty('DLA_QTD',   MVC_VIEW_ORDEM, '3')
	oStruDLA:SetProperty('DLA_DTPREV', MVC_VIEW_ORDEM, '4')
	oStruDLA:SetProperty('DLA_HRPREV', MVC_VIEW_ORDEM, '5')
	oStruDLA:SetProperty('DLA_CODCLI', MVC_VIEW_ORDEM, '6')
	oStruDLA:SetProperty('DLA_LOJA',   MVC_VIEW_ORDEM, '7')		
	oStruDLA:SetProperty('DLA_NOMCLI', MVC_VIEW_ORDEM, '8')		
	oStruDLA:SetProperty('DLA_PREVIS', MVC_VIEW_ORDEM, '9')
Return oStruDLA
					
/*/{Protheus.doc} TMS153EPos
Funcao de pos validacao do modelo
@author Ruan Ricardo Salvador
@since 17/08/2018
@type function
/*/					
Static Function TMS153EPos(oModel)
	Local lMVITMSDMD := SuperGetMv("MV_ITMSDMD",.F.,.F.)
	Local oModelOri := oModel:GetModel('GRID_ORI')
	Local lRet := .T.
	
	If lMVITMSDMD 
		lRet := VldColDMD(1, oModelOri, oModel:GetValue('MASTER_DL7','DL7_FILEXE'))
	Endif	
	
Return lRet
					
Static Function TMS153EGRV(oModel)
Local lRet		:= .T.
Local oModelDL7 := oModel:GetModel('MASTER_DL7')
Local oModelOri := oModel:GetModel('GRID_ORI')
Local oModelDes := oModel:GetModel('GRID_DES')
Local oView		:= Nil //receberá a view se tudo estiver OK
Local aGridReg 	:= {}
Local aQuant	:= {}
Local cCodDmd	:= oModelDL7:GetValue("DL7_COD")  
Local cCodCli	:= oModelDL7:GetValue("DL7_CLIDEV") 
Local cLojCli	:= oModelDL7:GetValue("DL7_LOJTMP") 
Local cUnidDmd	:= oModelDL7:GetValue("DL7_UM")
Local nQtdDmd 	:= oModelDL7:GetValue("DL7_QTDDMD")
Local nQtdBas 	:= oModelDL7:GetValue("DL7_QTDBAS")
Local nX		:= 0
Local nY		:= 0
Local lYesNo    := .T.

	For nY:= 1 to oModelOri:Length()
		If !Empty(oModelOri:GetValue("DLA_CODREG",nY)) .AND. !oModelOri:IsDeleted(nY)
			aAdd(aGridReg,{"1",oModelOri:GetValue("DLA_CODREG",nY),oModelOri:GetValue("DLA_QTD",nY), oModelOri:GetValue("DLA_PREVIS",nY), oModelOri:GetValue("DLA_DTPREV",nY), oModelOri:GetValue("DLA_HRPREV",nY), oModelOri:GetValue("DLA_CODCLI",nY), oModelOri:GetValue("DLA_LOJA",nY) })
		Endif
	Next

	If Len(aGridReg) == 0
		FwClearHLP()
		oModel:SetErrorMessage (,,,,,STR0014) //"Nenhuma região de origem foi selecionada."
		lRet := .F.
	Endif 
	
	If lRet .AND. ((Empty(oModelDL7:GetValue("DL7_QTDCON"))  .OR. Empty(oModelDL7:GetValue("DL7_QTDDMD"))))
		FwClearHLP()
		oModel:SetErrorMessage (,,,,,STR0015)//"Informe os campos do cabeçalho."
		lRet := .F.
	EndIf
	
	For nY:= 1 to oModelDes:Length()
		If !Empty(oModelDes:GetValue("DLL_CODREG",nY)) .AND. !oModelDes:IsDeleted(nY)
			aAdd(aGridReg,{"2",oModelDes:GetValue("DLL_CODREG",nY),oModelDes:GetValue("DLL_PREVIS",nY), oModelDes:GetValue("DLL_DTPREV",nY), oModelDes:GetValue("DLL_HRPREV",nY) })
		EndIf
	Next

	If lRet
		If !IsBlind()
			lYesNo := MSGYESNO(STR0016,STR0017)//"Confirma a Geração de Demandas?" //"Confirmação"
		EndIf
		If lYesNo		
			Processa( {||lRet := TmRegIncDm(cCodDMD,aQuant,aGridReg,@oModel,nQtdDmd,nQtdBas,cCodCli,cLojCli,cUnidDmd)}, STR0041,STR0042,.F.) //Aguarde... - Gerando demandas..	
		Else
			FwClearHLP()
			oModel:SetErrorMessage (,,,,,STR0018)//"Operação cancelada"
			lRet:= .F.
		EndIf
	EndIf

	//Limpa o array, conforme orientação do frame
	aGridReg:= aSize(aGridReg,0)
	
	If lRet  // Altera mensagem padrao de registro alterado com sucesso.
		If !IsBlind()
			oView:= FwViewActive()
			oView:SetUpdateMessage(STR0012,STR0040) //"Gerar Demandas", "Demandas geradas com sucesso."
			oView:ShowUpdateMsg(.T.)
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmRegIncDm
//Função para implementação da regua via função processa, e as inclusões de demanda serem realizas por uma unica regua de processamento.
@author Marlon Augusto Heiber
@since 11/07/2018
@param cCrtDemand,aQuant,aGridReg,oModel,nQtdDmd,nQtdBas,cCodCli,cLojCli,cUnidDmd
@type Static Function
/*/
//-------------------------------------------------------------------------------------------------
Static Function TmRegIncDm(cCrtDemand,aQuant,aGridReg,oModel,nQtdDmd,nQtdBas,cCodCli,cLojCli,cUnidDmd)
Local lRet := .T.
Local nX   := 0
	ProcRegua(nQtdDmd)
	For nX :=1 to nQtdDmd
		IncProc()
		aAdd(aQuant,nQtdBas)
		If !TmIncDem(cCrtDemand, , ,aQuant , aGridReg, 1, oModel,cCodCli,cLojCli,cUnidDmd) 
			lRet := .F.
			Exit
		EndIf
		aQuant:= aSize(aQuant,0)
	Next nX
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GatilhoDL7
//Função de Gatilho dos campos da rotina TMSA153E
@author gustavo.baptista
@since 22/05/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@param cCampo, Caracter, Campo que chamou o gatilho
@param cGrid - caracter - grid que deverá atualizar ("0" = Master_DL7 "1"= GRID_ORI "2"= GRID_DES )
@type function
/*/
//-------------------------------------------------------------------------------------------------
Static Function GatilhoDL7(oModel, cCampo, cGrid)
Local lRet:= .T.
Local nQtdBase:= 0
Local oModelDL7 := oModel:GetModel('MASTER_DL7')
Local oModelORI := oModelDL7:GetModel('GRID_ORI')
Local oModelDES := oModelDL7:GetModel('GRID_DES')
Local oView	   := FwViewActive()
Local nX := 0
Local nQtd:= 0
Local aAreaDUT   := DUT->(GetArea())

Default cCampo := ""
Default cGrid := ""

	DUT->(dbSetOrder(1))
	If DUT->(DbSeek(xFilial('DUT') + FWFldGet('DL7_TIPVEI')))
		FWFldPut('DL7_DESVEI',DUT->DUT_DESCRI)
	EndIf				

	If cGrid == "1"
		If (cCampo == "DL7_QTDCON") .OR. (cCampo == "DL7_QTDDMD")

			If oModel:GetValue("DL7_UM") == "2" //se for veículo, deverá assumir a qtd a ser consumida como quantidade					 
				oModel:LoadValue("DL7_QTDDMD",oModel:GetValue("DL7_QTDCON"))
			Else				
				If !Empty(oModel:GetValue("DL7_QTDDMD"))
					nQtdBase := oModel:GetValue("DL7_QTDCON") / oModel:GetValue("DL7_QTDDMD")
				EndIf
					
				If oModelORI:Length(.T.) > 0
					For nX := 1 to oModelORI:GetQtdLine()
						oModelORI:SetLine(nX)
						If !oModelORI:IsDeleted(nX)
							nQtd := nQtdBase / oModelORI:Length(.T.)
							oModelORI:LoadValue("DLA_QTD", nQtd, nX)
						EndIf						
					Next nX
				EndIf
				
				oModel:LoadValue("DL7_QTDBAS",nQtdBase)
				oModelOri:SetLine(1)
				If !IsBlind()
					oView:Refresh("GRID_ORI")
				EndIf
 			EndIf
			
		EndIf
		If cCampo == "DLA_DTPREV"
			If !Empty(oModelORI:GetValue("DLA_DTPREV")) .AND. oModelORI:GetValue("DLA_DTPREV") = Date()
				oModelORI:ClearField('DLA_HRPREV')	
			EndIf
		EndIf	
		If cCampo == 'DLA_CODREG'
			oModelORI:LoadValue('DLA_PREVIS', '2')
			T153EPrev(oModelDL7:GetModel("MASTER_DL7"):GetValue('DL7_COD'), oModelORI:GetValue('DLA_CODREG'), oModelDL7:GetModel("MASTER_DL7"):GetValue('DLE_CODGRD'),'1',oModel)
		EndIf
	Endif	
	If cGrid == "2"
		If cCampo == "DLL_DTPREV"
			If !Empty(oModelDES:GetValue("DLL_DTPREV")) .AND. oModelDES:GetValue("DLL_DTPREV") = Date()
				oModelDES:ClearField('DLL_HRPREV')	
			EndIf
		EndIf
		if cCampo == 'DLL_CODREG'
			oModelDES:LoadValue('DLL_PREVIS', '2')
			T153EPrev(oModelDL7:GetModel("MASTER_DL7"):GetValue('DL7_COD'), oModelDES:GetValue('DLL_CODREG'), oModelDL7:GetModel("MASTER_DL7"):GetValue('DLE_CODGRD'),'2',oModel)
		endif
	Endif

	RestArea(aAreaDUT)
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GatQtdDLA
//Gatilha as quantidades, conforme a quantidade informada na grid de regiões
@author gustavo.baptista
@since 22/05/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
//-------------------------------------------------------------------------------------------------
Static Function GatQtdDLA(oModel)
Local nX		:= 0
Local nQtdBas	:= 0
Local oModelAux := oModel:GetModel('MASTER_DL7')
Local oModelDL7 := oModelAux:GetModel('MASTER_DL7')
Local nQtdTot	:= 0
Local lRet 		:= .T.

	For nX:=1 to oModel:GetQTDLine()
		If !oModel:IsDeleted(nX)
			nQtdBas+= oModel:GetValue("DLA_QTD",nX)
		EndIf
	Next

	nQtdTot:= nQtdBas * oModelDL7:GetValue("DL7_QTDDMD")

	oModelDL7:LoadValue("DL7_QTDBAS",nQtdBas)
	oModelDL7:LoadValue("DL7_QTDCON",nQtdTot)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMS153EVLD
//Valida as grids de região
@author gustavo.baptista
@since 24/05/2018
@version 1.0
@return ${return}, ${return_description}
@param oModelGrid, object, descricao
@param nLine, numeric, descricao
@param cOpera, characters, descricao
@type function
/*/
//-------------------------------------------------------------------------------------------------
Static function TMS153EVLD( oModelGrid, nLine, cOpera)
Local lRet	     := .T.
Local nOperation := oModelGrid:GetOperation()
Local oModelAux  := oModelGrid:GetModel( 'MASTER_DL7' )
Local oModelDL7  := oModelAux:GetModel( 'MASTER_DL7' )
Local nX	     := 0
Local nQtdBas    := 0
Local nQtdTot 	 := 0

	If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE )
		If oModelDL7:GetValue("DL7_UM") == '1' .And. ((cOpera == "DELETE") .Or. (cOpera == "UNDELETE"))// Peso
			For nX := 1 to oModelGrid:GetQtdLine()
				If !oModelGrid:IsDeleted(nX) .AND. nX <> nLine
					nQtdBas += oModelGrid:GetValue("DLA_QTD",nX)
				EndIf
			Next nX		
			If (cOpera == "DELETE") 	
				nQtdTot := nQtdBas * oModelDL7:GetValue("DL7_QTDDMD")
				oModelDL7:LoadValue("DL7_QTDBAS", nQtdBas)
				oModelDL7:LoadValue("DL7_QTDCON", nQtdTot)	
			ElseIf (cOpera == "UNDELETE")
				nQtdBas := nQtdBas + oModelGrid:GetValue("DLA_QTD",nLine)
				nQtdTot := nQtdBas * oModelDL7:GetValue("DL7_QTDDMD")
				oModelDL7:LoadValue("DL7_QTDBAS", nQtdBas)
				oModelDL7:LoadValue("DL7_QTDCON", nQtdTot)
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM153EVld
Valid de campos da rotina TMSA153E
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@Param cCampo - caracter - campo que é chamado no valid
@Param cGrid - caracter - grid que deverá atualizar ("0" = Master_DL7 "1"= GRID_ORI "2"= GRID_DES )
@since 20/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TM153EVld(cCampo,cGrid,oModel)  
Local lRet 	 	:= .T.
Local oModelDL7 := oModel:GetModel('MASTER_DL7')
Local oModelORI := oModel:GetModel('GRID_ORI')
Local oModelDES := oModel:GetModel('GRID_DES')
Local cHora  	
Local dData	
Local aAreaDUT	:= {}
Default cGrid 	:= "0"	
	
	If lRet .AND. ((cCampo == 'DL7_DTPREV') .OR. (cCampo == 'DLA_DTPREV')  .OR. (cCampo == 'DLL_DTPREV'))
		iIf(cGrid = "0",dData := oModelDL7:GetValue(cCampo),iIf(cGrid = "1",dData := oModelORI:GetValue(cCampo),dData := oModelDES:GetValue(cCampo)))
		If !Empty(dData) 
			If (cCampo == 'DLA_DTPREV' .OR. cCampo == 'DLL_DTPREV') .AND. (dData < Date())
				FwClearHLP()
				oModel:SetErrorMessage (,,,,,STR0029)	//"Data de previsão não pode ser menor que a data atual." 		
				lRet := .F.
			EndIf
			If lRet .AND. cCampo == 'DL7_DTPREV'
				If dData < oModelDL7:GetValue('DL7_INIVIG') .OR. dData > oModelDL7:GetValue('DL7_FIMVIG')
					FwClearHLP()
					oModel:SetErrorMessage (,,,,,STR0030) //"Data de previsão está fora do período de vigência do contrato."			
					lRet := .F.
				EndIf
				If dData = Date()
					oModelDL7:ClearField('DL7_HRPREV')	
				EndIf
			EndIf
		EndIf
	EndIf			
	If lRet .AND. ((cCampo == 'DL7_HRPREV') .OR. (cCampo == 'DLA_HRPREV') .OR. (cCampo == 'DLL_HRPREV'))
		iIf(cGrid = "0",cHora := oModelDL7:GetValue(cCampo),iIf(cGrid = "1",cHora := oModelORI:GetValue(cCampo),cHora := oModelDES:GetValue(cCampo)))
		If !TMSVldHora(cHora) //valida se o formato da hora está ok sem chamar a função help
			FwClearHLP()
			oModel:SetErrorMessage (,,,,,STR0031,STR0032) //"Horário informado inválido"  "Verifique o formato: HH:MM" 
			lRet := .F.
		EndIf
		If lRet .AND. !Empty(cHora) .And. iIF(cCampo == 'DL7_HRPREV',oModelDL7:GetValue('DL7_DTPREV') = Date(),iIf(cGrid = "1",oModelORI:GetValue('DLA_DTPREV') = Date(),oModelDES:GetValue('DLL_DTPREV') = Date()) ) 
			If (cCampo == 'DLA_HRPREV' .OR. cCampo == 'DLL_HRPREV') .AND. (Alltrim(cHora) < (Substr(TIME(),1,2) + Substr(TIME(),4,2)))
				FwClearHLP()
				oModel:SetErrorMessage (,,,,,STR0033) //"Hora de previsão não pode ser menor que hora atual."
				lRet := .F.
			EndIf
		EndIf		
	EndIf
	
	If cGrid = "0"
		If lRet .AND. cCampo == 'DL7_TIPVEI' 
			If DLF->(DBSeek(xFilial('DLF')+ oModelDL7:GetValue('DL7_COD') + DLE->DLE_CODGRD + oModelDL7:GetValue('DL7_TIPVEI')))
				aAreaDUT   := DUT->(GetArea())
				DUT->(dbSetOrder(1))
				If DUT->(DbSeek(xFilial('DUT') + oModelDL7:GetValue('DL7_TIPVEI'))) 
					oModelDL7:LoadValue('DL7_DESVEI',DUT->DUT_DESCRI)
				Else
					If !Empty(oModelDL7:GetValue('DL7_TIPVEI'))
						FwClearHLP()
						oModel:SetErrorMessage (,,,,,STR0034,STR0035) // "Não existe registro relacionado a este código de veículo."  "Informe um código de veículo válido que exista no cadastro de veículos ou efetue o cadastro deste tipo de veículo no programa de cadastro de típos de veículos." 
						lRet := .F.
					EndIf
					oModelDL7:ClearField('DL7_DESVEI')
				EndIf
				RestArea(aAreaDUT)
			else
			    FwClearHLP()
				oModel:SetErrorMessage (,,,,,STR0038)	// "O tipo de veículo infomado não esta cadastrado para o grupo de região. "			
				lRet := .F.
			endif
		EndIf
	EndIf

	if cGrid == '1'
		if cCampo == "DLA_CODCLI"
			lRet :=  T153ECLILJ(oModelORI:GetValue("DLA_CODCLI"))
			if !lRet
			    FwClearHLP()
				oModel:SetErrorMessage (,,,,,STR0045)	//"A combinação Código Cliente + Loja informada é invalida ou inexistente."  				
			endif  
		elseif cCampo == 'DLA_LOJA'
			lRet :=  T153ECLILJ(oModelORI:GetValue("DLA_CODCLI"), oModelORI:GetValue("DLA_LOJA"))
			if !lRet
			    FwClearHLP()
				oModel:SetErrorMessage (,,,,,STR0045)	//"A combinação Código Cliente + Loja informada é invalida ou inexistente."  				
			endif		
		endif
	endif

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM153EWHEN
When de campos da rotina TMSA153E
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@since 20/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TM153EWHEN(cCampo,oModel)
Local lRet := .T.
Local oModelDL7 := oModel:GetModel('MASTER_DL7')

	If cCampo == 'DL7_TIPVEI'
	 	cTipVei := TMS153EVei(oModelDL7:GetValue("DL7_COD"),oModelDL7:GetValue("DLE_CODGRD"))
		lRet    := !Empty(cTipVei)
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMS153EF3()
Filtro de consulta padrão (F3) da rotina TMSA153E
@author  Marlon Augusto Heiber
@since   20/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TMS153EF3(cCampo)  
Local lRet := .T.

	If cCampo == 'DL7_TIPVEI'
	 	If Empty(cTipVei) //Variavel de tipo Static cTipVei declarada no topo do programa é alimentada no When do campo ao abrir a rotina.
	 		cTipVei := TMS153EVei(DL7->DL7_COD,DLE->DLE_CODGRD)
	 	EndIf
	 	lRet := DUT->DUT_TIPVEI $ cTipVei
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMS153EVei
//Função que retorna os tipos de veículos conforme contrato e grupo de região da tabela DLF.
@author Marlon Agusto Heiber
@since 20/06/2018
@return cTipVei
@param cCodCrt, characters, código do contrato
@param cCodGrd, characters, código do grupo de região
@type function
/*/
//-------------------------------------------------------------------
Function TMS153EVei(cCrtDmd, cCodGrd)
Local cTipVei := ''
Local cQuery  := ''
Local cTemp   := GetNextAlias() 
	
	cQuery := " SELECT DLF_TIPVEI FROM " + RetSqlName('DLF') + " DLF "
	cQuery += " WHERE DLF_FILIAL = '" + xFilial("DLF") + "'"
	cQuery += " AND DLF_CRTDMD = '" + cCrtDmd + "'"
	cQuery += " AND DLF_CODGRD = '" + cCodGrd + "'"
	cQuery += " AND D_E_L_E_T_ = ' '"	
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
	
	While (cTemp)->(!Eof())
		cTipVei += (cTemp)->DLF_TIPVEI + ";"     	
		(cTemp)->(dbSkip())	
	EndDo
	
	(cTemp)->(DbCloseArea())
	
Return cTipVei

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterVwAct
Validação após ativar a view 
@type Static Function
@author Marlon Augusto Heiber
@version 12.1.17
@since 21/06/2018
/*/
//-------------------------------------------------------------------
Static Function AfterVwAct(oView) 	
Local oModel 	 := Nil         	// Recebe o Model 
Local oModelDL7  := Nil 			// Recebe o Model 
Local lRet 		 := .T.	
Local nTamTipVei := 0
Local cTipVei	 := ""
Local aAreaDUT   := DUT->(GetArea())
Default oView    := FwViewActive()
	
	oModel	  := oView:GetModel()
	oModelDL7 := oModel:GetModel('MASTER_DL7')  
	
	If Empty(oModelDL7:GetValue('DL7_TIPVEI'))
		nTamTipVei := TamSX3('DUT_TIPVEI')[1]
		cTipVei := TMS153EVei(oModelDL7:GetValue('DL7_COD'),oModelDL7:GetValue('DLE_CODGRD'))
		If !Empty(cTipVei)
			If Len(cTipVei) == (nTamTipVei + 1) .AND. RAT(";",cTipVei) = (nTamTipVei + 1)
				DUT->(dbSetOrder(1))
				DUT->(DbSeek(xFilial('DUT') + SubStr(cTipVei,1,nTamTipVei)))
				oModelDL7:LoadValue('DL7_TIPVEI',DUT->DUT_TIPVEI)
				oModelDL7:LoadValue('DL7_DESVEI',DUT->DUT_DESCRI)
			EndIf
		EndIf
	EndIf
	
	oView:Refresh('MASTER_DL7')
	RestArea(aAreaDUT)
	
Return lRet

/*/{Protheus.doc} T153EPrev
//Função para setar a informação de região prevista 
@author gustavo.baptista
@since 03/07/2018
@version 1.0
@return ${return}, ${return_description}
@param cCrtDmd, characters, descricao
@param cCodReg, characters, descricao
@param cCodGrd, characters, descricao
@param cTipReg, characters, descricao
@param oModelGrid, object, descricao
@type function
/*/
Function T153EPrev(cCrtDmd, cCodReg, cCodGrd,cTipReg,oModelGrid)
Local lRet := .T.
Local cQuery := ''
Local cAliasQry := GetNextAlias()

		If cTipReg == '1'
			cQuery := " SELECT DLM_CODREG "
			cQuery += " FROM " 		 + RetSqlName("DLM") + " DLM "
			cQuery += " WHERE 		DLM.DLM_FILIAL = '" + xFilial('DLM') + "' "
			cQuery += " AND 		DLM.DLM_CRTDMD = '" + cCrtDmd + "' "
			cQuery += " AND 		DLM.DLM_CODGRD = '" + cCodGrd + "' "  
			cQuery += " AND 		DLM.DLM_CODREG = '" + cCodReg + "' " 
			cQuery += " AND 		DLM.D_E_L_E_T_ = ' ' "
		ElseIf cTipReg == '2'
			cQuery := " SELECT DLN_CODREG "
			cQuery += " FROM " 		 + RetSqlName("DLN") + " DLN "
			cQuery += " WHERE 		DLN.DLN_FILIAL = '" + xFilial('DLN') + "' "
			cQuery += " AND 		DLN.DLN_CRTDMD = '" + cCrtDmd + "' "
			cQuery += " AND 		DLN.DLN_CODGRD = '" + cCodGrd + "' "  
			cQuery += " AND 		DLN.DLN_CODREG = '" + cCodReg + "' " 
			cQuery += " AND 		DLN.D_E_L_E_T_ = ' ' "		
		EndIf
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		
		While (cAliasQry)->(!Eof())
			If cTipReg == '1' .And. M->DLA_CODREG == (cAliasQry)->DLM_CODREG //Origem
				oModelGrid:LoadValue('DLA_PREVIS', '1')
			ElseIf cTipReg == '2' .And. M->DLL_CODREG == (cAliasQry)->DLN_CODREG //Destino
				oModelGrid:LoadValue('DLL_PREVIS', '1')
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} T153EVLDLJ
//Verifica se a combinação cliente + Loja possui contrato específio. Caso sim, bloqueia.
@author André Luiz Custódio
@since 23/08/2018
@version 12.17
@return ${return}, ${return_description}
@param cCampo, characters, Define qual campo que será validado no When
@type function
/*/
Function T153EVLDLJ(cCampo,oModel)

	Local lRet      := .T.
	Local cQuery    := ""
	Local cLojTmp   := ""
	Local cAliasQry := GetNextAlias()

	cLojTmp := oModel:GetModel():GetValue("MASTER_DL7","DL7_LOJTMP")

	if cCampo == 'DL7_LOJTMP' .And. lAbrangCli
	
		cQuery:= " SELECT DISTINCT '1'  CTR_ESPEC"
		cQuery+= " FROM "+RetSqlName('DL7')+" DL7 "
		cQuery+= " WHERE DL7.DL7_FILIAL = '"+xFilial("DL7")+"'"
		cQuery+= " AND DL7.DL7_CLIDEV = '"+ DL7->DL7_CLIDEV +"'"		
		cQuery+= " AND DL7.DL7_LOJDEV = '"+ cLojTmp +"'"
		cQuery+= " AND DL7.DL7_ABRANG = '1' "   // Específico (Cliente e Loja)
		cQuery+= " AND DL7.DL7_TIPCTR = '"+ DL7->DL7_TIPCTR +"'"
		cQuery+= " AND DL7.DL7_STATUS = '1' "   // Em aberto ou Ativo
		cQuery+= " AND DL7.DL7_COD   <> '"+ DL7->DL7_COD +"'
		cQuery+= " AND DL7.D_E_L_E_T_ = '' "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .F., .T. )

		if (cAliasQry)->CTR_ESPEC == '1'
			lRet := .F.
			FwClearHLP()
			oModel:GetModel():SetErrorMessage (,,,,,STR0046) //"A combinação Código Cliente + Loja informada é invalida ou inexistente." 				
		endif	

		(cAliasQry)->(DbCloseArea())	
	endif

	if lRet
		lRet := T153ECLILJ(DL7->DL7_CLIDEV, cLojTmp)   
		if !lRet
		    FwClearHLP()
			oModel:GetModel():SetErrorMessage (,,,,,STR0045)	//"A combinação Código Cliente + Loja informada possui um outro Contrato de Demandas do mesmo tipo, em aberto e com abrangência específica (Cliente e Loja). "  
		else
			oModel:GetModel():LoadValue("MASTER_DL7", "DL7_NOMTMP", POSICIONE("SA1",1,XFILIAL("SA1")+DL7->DL7_CLIDEV+oModel:GetModel():GetValue("MASTER_DL7","DL7_LOJTMP"),"A1_NOME"))			
		endif                                                      
	EndIf
	

return lRet 

/*/{Protheus.doc} T153ECLILJ
//Valida  a combinação Cod Cliente + Loja.
@author André Luiz Custódio
@since 23/08/2018
@version 12.17
@type function
/*/
Function T153ECLILJ(cCodCli,cLoja)
	Local lRet := .F.
	Local cQuery := ""
	Local cAliasQry := GetNextAlias()
	Default cLoja := ""

	cQuery:= " SELECT DISTINCT '1'  CLIENTE"
	cQuery+= " FROM "+RetSqlName('SA1')+" SA1 "
	cQuery+= " WHERE A1_FILIAL = '"+xFilial("SA1")+"'"
	cQuery+= " AND   A1_COD = '"+cCodCli+"'"
	
	if !Empty(cLoja)
		cQuery+= " AND A1_LOJA = '"+ cLoja +"'"		
	Endif
	
	cQuery+= " AND D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .F., .T. )

	if (cAliasQry)->CLIENTE == '1'
		lRet := .T.
	endif		

	(cAliasQry)->(DbCloseArea())		

Return lRet 

/*/{Protheus.doc} T153ELdOri
Load do grid origem
@type function
@author ruan.salvador
@since 03/09/2018
@param oModelOri 
/*/
Static Function T153ELdOri()
	Local cTemp:= GetNextAlias()
	Local cQuery := ''
	
	Local aLoad := {}
	
	cQuery  := " SELECT DLM_SEQREG, DLM_CODREG, DLM_QTD"
	cQuery  += "   FROM "+RetSqlName('DLM')+ " DLM "			           
	cQuery  += "  WHERE DLM.DLM_FILIAL = '" + xFilial('DLM') + "'"
	cQuery  += "    AND DLM.DLM_CRTDMD = '"+ DLE->DLE_CRTDMD +"'
	cQuery  += "    AND DLM.DLM_CODGRD = '"+ DLE->DLE_CODGRD +"'
	cQuery  += "    AND DLM.D_E_L_E_T_ = '' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )	
	
	While (cTemp)->(!Eof())
		aAdd(aLoad,{0,{xFilial("DLA"),; //filial
			         (cTemp)->DLM_SEQREG,; //sequencia da regiao
			         (cTemp)->DLM_CODREG,; //codigo de regiao
			         Posicione('DUY', 1, xFilial('DUY') + (cTemp)->DLM_CODREG, 'DUY_DESCRI'),;//nome
			         CTOD('  /  /  '),;//dt de previsao
			         Space(TamSX3('DLA_HRPREV')[1]),;//hr de previsao
			         DL7->DL7_CLIDEV,; //cod cliente
			         DL7->DL7_LOJDEV,; //loja cliente
			         Posicione('SA1', 1, xFilial('SA1') + DL7->DL7_CLIDEV + DL7->DL7_LOJDEV, 'A1_NOME'),;//nome cliente
			         '1',;//prevista
			         (cTemp)->DLM_QTD}}) //quantidade
		(cTemp)->(dbSkip())
	EndDo

	(cTemp)->(DbCloseArea())
	
Return aLoad

/*/{Protheus.doc} T153ELdDes
Load do grid destino
@type function
@author ruan.salvador
@since 03/09/2018
@param oModelOri 
/*/
Static Function T153ELdDes()
	Local cTemp:= GetNextAlias()
	Local cQuery := ''
		
	Local aLoad := {}
	
	cQuery  := " SELECT DLN_SEQREG, DLN_CODREG"
	cQuery  += "   FROM "+RetSqlName('DLN')+ " DLN "			           
	cQuery  += "  WHERE DLN.DLN_FILIAL = '" + xFilial('DLN') + "'"
	cQuery  += "    AND DLN.DLN_CRTDMD = '"+ DLE->DLE_CRTDMD +"'
	cQuery  += "    AND DLN.DLN_CODGRD = '"+ DLE->DLE_CODGRD +"'
	cQuery  += "    AND DLN.D_E_L_E_T_ = '' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )	
	
	While (cTemp)->(!Eof())
		aAdd(aLoad,{0,{xFilial("DLN"),; //filial
			         (cTemp)->DLN_SEQREG,; //sequencia da regiao
			         (cTemp)->DLN_CODREG,; //codigo de regiao
			         Posicione('DUY', 1, xFilial('DUY') + (cTemp)->DLN_CODREG, 'DUY_DESCRI'),;//nome
			         CTOD('  /  /  '),;//dt de previsao
			         Space(TamSX3('DLL_HRPREV')[1]),;//hr de previsao
			         '1'}}) //prevista
		(cTemp)->(dbSkip())
	EndDo

	(cTemp)->(DbCloseArea())
	
Return aLoad


/*/{Protheus.doc} T153ENmCli
//Retorna o nome do cliente a partir das informações do cliente do contrato
@author wander.horongoso
@since 06/09/2018
@version 1.0
@return cRet, nome do cliente
@param oModel, object, Model que contém o campo a ser retornado
@type function
/*/
Static Function T153ENmCli(oModel)
Local cRet

  cRet := Posicione("SA1",1,xFilial("SA1") + DL7->DL7_CLIDEV + oModel:GetModel():GetValue("MASTER_DL7","DL7_LOJTMP"),"A1_NOME")
  
return cRet

/*/{Protheus.doc} T153ENmCli
//Validações para o campo virtual DL7_DESVEI
@author natalia.neves
@since 16/10/2018
@version 1.0
@return cRet, .T. or .F.
@type function
/*/
Function T153VLTVEI()

Local lRet := .T.

	lRet := ExistCpo('DLF', FWFldGet('DL7_COD')+FWFldGet('DLE_CODGRD')+FWFldGet('DL7_TIPVEI'))

	if !lRet
		FWFldPut('DL7_DESVEI','')
		lRet := Vazio()
	EndIf

Return lRet

