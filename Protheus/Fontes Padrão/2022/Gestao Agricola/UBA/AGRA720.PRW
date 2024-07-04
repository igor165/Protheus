#INCLUDE "AGRA720.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"


Static __aFardos	:= {}
Static __aFardosBkp 	:= {}
Static __aLivres	:= {}
Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio
Static __lAutomato   := isBlind()

/**-------------------------------------------------------------------------------------
{Protheus.doc} AGRA720
Cadastro de reservas do contrato       

@param: Nil
@author: Ricardo Tomasi
@since: 11/10/2012
@Uso: UBA
-------------------------------------------------------------------------------------**/
Function AGRA720()
	Local oBrowse 		:= Nil
	Private cSafraCTR 	:= ""	
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "DXP" )
	oBrowse:SetDescription( STR0001 ) //"Reservas" 
	If GetRpoRelease() >= "12.1.023"
		oBrowse:AddLegend( "DXP_STATUS == '1'", "GREEN", STR0041) 	//"Aguardando Take-Up"
		oBrowse:AddLegend( "DXP_STATUS == '2'", "GRAY" , STR0042) 	//"Take-Up Efetuado"	
	EndIf
	oBrowse:DisableDetails()
	oBrowse:Activate()
Return

/**-------------------------------------------------------------------------------------
{Protheus.doc} ModelDef
Retorna o modelo de Dados da rotina

@param: Nil
@author: Ricardo Tomasi
@since: 11/10/2012
@Uso: AGRA720
-------------------------------------------------------------------------------------**/
Static Function ModelDef()
	Local oModel	 := Nil
	Local oStruDXP 	 := FwFormStruct( 1, "DXP" ) // Cadastro de Reservas
	Local oStruDXQ   := FwFormStruct( 1, "DXQ" ) // Itens das Reservas

	//-----------------------------
	// Instancia o modelo de dados
	//-----------------------------
	oModel := MPFormModel():New( "AGRA720",/*bPre*/{| oModel | AGRA720PRE( oModel ) },/*bPost*/{| oModel | AGRA720POS( oModel ) } ,/*bCommit*/ { | x | GrvModelo( x ) }, /*bCancel*/{ | x | CanModelo( x ) })
	oModel:SetDescription( STR0002 ) //"Modelo de Dados do Cadastro de Reserva"
	
	//-----------------------------
	// Adiciona o gatilho conforme parâmetro do novo modelo de comercialização
	//-----------------------------
	//-- AGRColPos() = Função do fonte AGRUTIL01.PRW 
	//-- Se novo modelo de comercialização, adiciona o gatilho no campo contrato para o campo tipos de algodão aceitáveis	
	If __lnewNeg .AND. AGRColPos('DXP_TIPACT')
		oStruDXP:AddTrigger('DXP_CODCTP', 'DXP_TIPACT', , {|oModelDXP, cCampo, xValue| AGRA720TRG(oModelDXP, cCampo, xValue)})
	Else
	 	oStruDXP:AddTrigger('DXP_CODCTP', 'DXP_ITECTP', , {|oModelDXP, cCampo, xValue| Posicione("ADB", 1, xFilial("ADB")+M->DXP_CODCTP+IIF(ADB->ADB_NUMCTR==M->DXP_CODCTP,ADB->ADB_ITEM,""),"ADB_ITEM")})
	  	oStruDXP:AddTrigger('DXP_CODCTP', 'DXP_CLACOM', , {|oModelDXP, cCampo, xValue| Posicione("ADB", 1, xFilial("ADB")+M->(DXP_CODCTP+DXP_ITECTP), "ADB_CLACOM")})	
	EndIf
	
	// Adiciona a field no modelo de dados
	oModel:AddFields( "DXPMASTER", , oStruDXP )
	oModel:GetModel( "DXPMASTER" ):SetDescription( STR0003 ) //"Dados da Reserva"
		
	//------------------------------------
	// Adciona a grid no modelo de dados
	//------------------------------------
	oModel:AddGrid( "DXQDETAIL", "DXPMASTER" , oStruDXQ ,{|a, b, c, d, e, f| PreLinha(a, b, c, d, e, f) }, {|x| PosLinha( x ) } ,,, /*bload*/  )
	oModel:GetModel( "DXQDETAIL" ):SetDescription( STR0004 ) //"Dados do Item da Reserva"
     
 	//*CHAMADA DA FUNÇÃO DE CONSULTA AGENDA TAKE-UP
	// Se usa o modelo novo de comercialização então  
	//-- AGRColPos() = Função do fonte AGRUTIL01.PRW 
	If __lnewNeg .AND. IsInCallStack("OGC020") .AND. AGRColPos('DXP_CLAEXT') .AND. AGRColPos('DXP_CLAINT')
		If Type("_cTkpFis") != 'U'
			//*Campos se tornam obrigátorios para efetuar take-up
			If _cTkpFis == "SIM"
				oStruDXP:SetProperty( 'DXP_CLAEXT' , MODEL_FIELD_OBRIGAT, .T.)
			EndIf
		EndIf
		oStruDXP:SetProperty( 'DXP_CLAINT' , MODEL_FIELD_OBRIGAT, .T.)   
		
		oModel:AddCalc( 'AGRA720CALC' ,"DXPMASTER" ,"DXQDETAIL", 'DXQ_QUANT'  ,'TOTFDI'  , 'SUM',{ | oFW | oFw:GetValue('DXQDETAIL','DXQ_APROVA') == '1'},,STR0005 ) //'Total de Fardos'
		oModel:AddCalc( 'AGRA720CALC' ,"DXPMASTER" ,"DXQDETAIL", 'DXQ_SLDISP' ,'TOTDISP' , 'SUM',{ | oFW | oFw:GetValue('DXQDETAIL','DXQ_APROVA') == '1'},,STR0006 ) //'Total Disponivel'
		oModel:AddCalc( 'AGRA720CALC' ,"DXPMASTER" ,"DXQDETAIL", 'DXQ_PSBRUT' ,'TOTBRUTO', 'SUM',{ | oFW | oFw:GetValue('DXQDETAIL','DXQ_APROVA') == '1'},,STR0007 ) //'Peso Bruto Total'
		oModel:AddCalc( 'AGRA720CALC' ,"DXPMASTER" ,"DXQDETAIL", 'DXQ_PSLIQU' ,'TOTLIQU' , 'SUM',{ | oFW | oFw:GetValue('DXQDETAIL','DXQ_APROVA') == '1'},,STR0008 ) //'Peso liquido Total' 
	Else
		//------------------
		// adiciona calculo 
		//------------------
	
		oModel:AddCalc( 'AGRA720CALC' ,"DXPMASTER" ,"DXQDETAIL", 'DXQ_QUANT'  ,'TOTFDI'  , 'SUM',,,STR0005)//'Total de Fardos'
		oModel:AddCalc( 'AGRA720CALC' ,"DXPMASTER" ,"DXQDETAIL", 'DXQ_SLDISP' ,'TOTDISP' , 'SUM',,,STR0006 ) //'Total Disponivel'
		oModel:AddCalc( 'AGRA720CALC' ,"DXPMASTER" ,"DXQDETAIL", 'DXQ_PSBRUT' ,'TOTBRUTO', 'SUM',,,STR0007 ) //'Peso Bruto Total'
		oModel:AddCalc( 'AGRA720CALC' ,"DXPMASTER" ,"DXQDETAIL", 'DXQ_PSLIQU' ,'TOTLIQU' , 'SUM',,,STR0008 ) //'Peso liquido Total'
	EndIf
	
	//------------------------------------
	// Faz o relacionamento Field x Grid
	//------------------------------------
	oModel:SetRelation( "DXQDETAIL", { { "DXQ_FILIAL", "xFilial('DXQ')" }, { "DXQ_CODRES", "DXP_CODIGO" } }, DXQ->( IndexKey( 1 ) ) )

	//------------------
	// Seta linha unica
	//------------------
	//-- AGRColPos() = Função do fonte AGRUTIL01.PRW   
	If AGRColPos('DXQ_FILORG')
		oModel:GetModel( "DXQDETAIL" ):SetUniqueLine( { 'DXQ_BLOCO', 'DXQ_FILORG'  } ) 

	Else
		oModel:GetModel( "DXQDETAIL" ):SetUniqueLine( { 'DXQ_BLOCO' } )

	EndIf
	oModel:GetModel( "DXQDETAIL" ):SetOptional( .t. )
	
	If __lnewNeg
		//seta somente update pelo sel fardos
		oModel:GetModel( "DXQDETAIL" ):SetNoInsertLine(.T.)
		oModel:GetModel( "DXQDETAIL" ):SetNoDeleteLine(.T.)
	endif
	
	//------------------------------------
	// Seta validação na ativação do model
	//------------------------------------
	oModel:SetVldActivate( { | oModel | A720VLDACT(oModel) } )

	//------------------------------------
	// Validação Após Ativar do model
	//------------------------------------
	oModel:SetActivate( { | oModel | A720ACTIVE(oModel) } )

Return( oModel )

/**-------------------------------------------------------------------------------------
{Protheus.doc} ViewDef
Retorna a View (tela) da rotina

@param: Nil
@author: Ricardo Tomasi
@since: 11/09/2012
@Uso: AGRA720
-------------------------------------------------------------------------------------**/
Static Function ViewDef()
	Local oStruDXP 	:= nil 
	Local oStruDXQ 	:= nil
	Local oModel	:= FwLoadModel( "AGRA720" )
	Local oView	:= FwFormView():New() // Instancia o modelo de dados
	
	// Se for o modelo novo aplicas as propriedades		
	//-- AGRColPos() = Função do fonte AGRUTIL01.PRW 
	If __lnewNeg	 .AND. AGRColPos('DXP_TIPRES') .AND. AGRColPos('DXQ_APROVA')
		oStruDXP := FWFormStruct( 2, 'DXP' , { |x| !ALLTRIM(x) $ "DXP_ITECTP" })
		oStruDXQ := FWFormStruct( 2, 'DXQ' , { |x| !ALLTRIM(x) $ "DXQ_CODCTP|DXQ_SAFRA|DXQ_CODRES" })
		
		oStruDXP:SetProperty( 'DXP_DATAGD' , MVC_VIEW_CANCHANGE , .F.)
		oStruDXP:SetProperty( 'DXP_HORAGD' , MVC_VIEW_CANCHANGE , .F.)
		oStruDXP:SetProperty( 'DXP_DATTKP' , MVC_VIEW_CANCHANGE , .F.)
		oStruDXP:SetProperty( 'DXP_HORTKP' , MVC_VIEW_CANCHANGE , .F.)
		oStruDXP:SetProperty( 'DXP_OBSAGE' , MVC_VIEW_CANCHANGE , .F.)
	 	oStruDXQ:SetProperty( 'DXQ_BLOCO'  , MVC_VIEW_CANCHANGE , .F.)
		//*CHAMADA DA FUNÇÃO DE CONSULTA AGENDA TAKE-UP
		
		If IsInCallStack("OGC020") .OR. IsInCallStack("OGC010")
			//*Altera propriedades dos campos conforme necessidade da rotina OGC020
			oStruDXP:SetProperty( 'DXP_TIPRES' , MVC_VIEW_CANCHANGE , .F.)
		   	oStruDXP:SetProperty( 'DXP_DATA'   , MVC_VIEW_CANCHANGE , .F.)
		   	oStruDXP:SetProperty( 'DXP_CODCTP' , MVC_VIEW_CANCHANGE , .F.)
		   	oStruDXP:SetProperty( 'DXP_CODUNB' , MVC_VIEW_CANCHANGE , .F.)
		   	oStruDXP:SetProperty( 'DXP_ITECAD' , MVC_VIEW_CANCHANGE , .F.)
		   	oStruDXP:SetProperty( 'DXP_SAFRA'  , MVC_VIEW_CANCHANGE , .F.)
			If IsInCallStack("OGC010") // Altera propriedades dos campos conforme necessidade da rotina OGC010
		   		oStruDXP:SetProperty( 'DXP_CODIGO' , MVC_VIEW_CANCHANGE , .F.)
		   		oStruDXP:SetProperty( 'DXP_CLIENT' , MVC_VIEW_CANCHANGE , .F.)
		   		oStruDXP:SetProperty( 'DXP_LJCLI'  , MVC_VIEW_CANCHANGE , .F.)		   		
		   		
		   		//*Remove campos da tela pois são campos para tratamentos especificos da rotina OGC020
				oStruDXQ:RemoveField("DXQ_APROVA")
				oStruDXQ:RemoveField('DXQ_OBSERV') 
			EndIf
			If IsInCallStack("OGC020")// Altera propriedades dos campos conforme necessidade da rotina OGC020
				oStruDXP:SetProperty( 'DXP_OBSAGE' , MVC_VIEW_CANCHANGE , .F.)
				oStruDXP:SetProperty( 'DXP_DESRES' , MVC_VIEW_CANCHANGE , .F.)
			EndIf
		Else
			//*Remove campos da tela pois são campos para tratamentos especificos da rotina OGC020
			oStruDXQ:RemoveField("DXQ_APROVA")
			oStruDXQ:RemoveField('DXQ_OBSERV') 
		EndIf

	//-- Tratamento para quando o parametro não estiver ativo ou não existir - porém campos devem existir.
	ElseIf .NOT. __lnewNeg .AND. AGRColPos('DXP_TIPRES') .AND. AGRColPos('DXQ_APROVA')
		oStruDXP := FWFormStruct( 2, 'DXP' , { |x| !ALLTRIM(x) $ "DXP_TIPRES|DXP_DESRES|DXP_NOMCLI|DXP_ITECAD|DXP_STATUS|DXP_HORAGD|DXP_DATTKP|DXP_HORTKP|DXP_CLAEXT|DXP_CNOEXT|DXP_CLAINT|DXP_CNOINT|DXP_EMAIL|DXP_TIPACT|DXP_OBSAGE" })
		oStruDXQ := FWFormStruct( 2, 'DXQ' , { |x| !ALLTRIM(x) $ "DXQ_APROVA|DXQ_OBSERV|DXQ_CODCTP|DXQ_SAFRA|DXQ_CODRES" })
		oStruDXQ:RemoveField("DXQ_FILORG") // Remove o campo filial origem pois não é necessario
		oStruDXP:RemoveField("DXP_DATAGD") //em separado, pois na remoção padrão tbm removia o DXP_DATA.
		oStruDXP:SetNoFolders(.T.) //não monta o folder para os campos de take-up

	//-- Legado - Proteção de Código
	Else
		oStruDXP := FwFormStruct( 2, "DXP" ) // Cadastro de Reservas
		oStruDXQ := FWFormStruct( 2, "DXQ", {|cCampo| !(AllTRim(cCampo) $ "DXQ_CODCTP|DXQ_SAFRA|DXQ_CODRES" )} )	
	EndIf
	
	//verificar se a consulta atual é a padrão do programa
	If oStruDXP:GetProperty( 'DXP_CODCTP' , MVC_VIEW_LOOKUP) $ "NJRNNY|ADBDXP"
		// Se for o modelo novo aplicas as propriedades
		//-- AGRColPos() = Função do fonte AGRUTIL01.PRW 
		If __lnewNeg .AND. AGRColPos('DXP_TIPRES') .AND. AGRColPos('DXQ_APROVA')
			oStruDXP:SetProperty( 'DXP_CODCTP' , MVC_VIEW_LOOKUP, "NJRNNY")
		Else
			oStruDXP:SetProperty( 'DXP_CODCTP' , MVC_VIEW_LOOKUP, "ADBDXP")
		EndIf
	EndIf
	
	//Remove FIELDS    
	//-- AGRColPos() = Função do fonte AGRUTIL01.PRW
	If AGRColPos('DXP_STATUS')
		oStruDXP:RemoveField( 'DXP_STATUS')        
	EndIf
	oView:SetModel( oModel )
	oCalc := FWCalcStruct( oModel:GetModel( 'AGRA720CALC') ) // Instacia FwCalEstruct

	//-Legado- Remove Campos
	If !__lnewNeg
		oStruDXP:RemoveField("DXP_CODUNB")
		oStruDXP:RemoveField("DXP_CODREG")
		oStruDXP:RemoveField("DXP_TIPEMB")
		oStruDXP:RemoveField("DXP_QTDFAR")
		oStruDXP:RemoveField("DXP_PSMAX")
	EndIF

	//-------------------------
	// Adciona a field na view
	//-------------------------
	oView:AddField( "VIEW_DXP" , oStruDXP, "DXPMASTER" )
	oView:AddGrid(  "VIEW_DXQ" , oStruDXQ, "DXQDETAIL" )
	oView:AddField( 'VIEW_CALC', oCalc   , 'AGRA720CALC')
	  	
	oView:AddIncrementField( 'VIEW_DXQ', 'DXQ_ITEM' ) // seta campo incremental

	//------------------------------------------------
	// Cria box para parte superior e inferior da tela
	//------------------------------------------------
	oView:CreateHorizontalBox( "SUP", 40 )
	oView:CreateHorizontalBox( "MED", 50 )
	oView:CreateHorizontalBox( "RDP", 10 )

	//------------
	// Seta owner
	//------------ 
	oView:SetOwnerView( "VIEW_DXP"	,"SUP" )
	oView:SetOwnerView( "VIEW_DXQ"	,"MED" )
	oView:SetOwnerView( "VIEW_CALC"	,"RDP" )

	//-----------------
	// Adiciona botões
	//-----------------  
	//-- AGRColPos() = Função do fonte AGRUTIL01.PRW
	If __lnewNeg .AND. AGRColPos('DXP_TIPRES') .AND. AGRColPos('DXQ_APROVA')
		oView:AddUserButton( STR0009 , 'CLIPS', {| oView | GetFardos( oView ) } ) //"Selecionar Fardos"
		oView:AddUserButton( STR0086 , 'CLIPS', {| oView | AGRA720REC(oView)  } ) //"Reclassificar"
		
		//-----------------
		// Validação após ativação da view
		//-----------------
		oView:SetAfterViewActivate({|oView| AGRA720VAC(oView)})
	Else
		oView:AddUserButton( STR0009, 'CLIPS', {| oView | IncFardos( oView ) } ) //"Selecionar Fardos"
	EndIf

Return( oView )               


/**-------------------------------------------------------------------------------------
{Protheus.doc} AGRA720REC
Prepara e chama da função (AGRA650RC) de reclassificação no TAKEUP 
--- BOTAO: RECLASSIFICAR - TRATADO NA VIEW
@param: 
@author: Daniel Maniglia A. Silva
@since: 04/07/2017
@Uso: AGRA720
-------------------------------------------------------------------------------------**/
Static Function AGRA720REC(oView)
	Local oModel    	:= oView:getModel()
	Local oMdGridDXQ	:= oModel:GetModel("DXQDETAIL")
	Local cFilOrg		:= oModel:GetValue('DXQDETAIL','DXQ_FILORG' )
	Local cOldCla		:= oModel:GetValue('DXQDETAIL','DXQ_TIPO' ) 
	Local cCodRes 		:= oModel:GetValue('DXPMASTER','DXP_CODIGO')
	Local cCodBlc		:= oModel:GetValue('DXQDETAIL','DXQ_BLOCO' )
	Local cItemRes  	:= oModel:GetValue('DXQDETAIL','DXQ_ITEM' )
	Local cSafra		:= oModel:GetValue('DXPMASTER','DXP_SAFRA')
	Local cCodUnb 		:= Posicione('DXD',1,cFilOrg + cSafra + cCodBlc,'DXD_CODUNB') //pega o valor conforme do bloco
	Local cStatus 		:= oModel:GetValue('DXPMASTER','DXP_STATUS')
	
	If .NOT. oMdGridDXQ:IsDeleted()
		AGRA650RCL(cFilOrg, cOldCla,cCodRes,cItemRes, cCodBlc, cSafra,cCodUnb,cStatus,.T.)	
		
		//-- DXD - Cadastro de Blocos
		DbSelectArea("DXD")	
		DbSetOrder(1)
		If DXD->( dbSeek(cFilOrg + cSafra + cCodBlc))
			oModel:LoadValue('DXQDETAIL','DXQ_TIPO',DXD->DXD_CLACOM )
		EndIf
	Else
		MsgInfo(STR0063)
	EndIf
Return

/**-------------------------------------------------------------------------------------
{Protheus.doc} MenuDef
Menu Padrao da Rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 11/09/2012
@Uso: AGRA720
-------------------------------------------------------------------------------------**/
Static Function MenuDef()
	Local aRotina 	 := {} 
	Local lImpressao := SuperGetMv('MV_AGRA001', , .F.) 
	/*
	Parametros do array a Rotina - MENU:
		1. Nome a aparecer no cabecalho 
		2. Nome da Rotina associada 
		3. Reservado 
		4. Tipo de Transa+"o a ser efetuada: 
		4.1 - Pesquisa e Posiciona em um Banco de Dados 
		4.2 - Simplesmente Mostra os Campos 
		4.3 - Inclui registros no Bancos de Dados 
		4.4 - Altera o registro corrente 
		4.5 - Remove o registro corrente do Banco de Dados 
		5. Nivel de acesso 
		6. Habilita Menu Funcional 
	*/  
	aAdd( aRotina, { STR0010, 'PesqBrw'		  , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0011, 'ViewDef.AGRA720'	  , 0, 2, 0, .T. } ) //"Visualizar"
	aAdd( aRotina, { STR0012, 'ViewDef.AGRA720'	  , 0, 3, 0, .T. } ) //"Incluir"
	aAdd( aRotina, { STR0013, 'ViewDef.AGRA720'	  , 0, 4, 0, .T. } ) //"Alterar"
	aAdd( aRotina, { STR0014, 'ViewDef.AGRA720'	  , 0, 5, 0, .T. } ) //"Excluir"
	aAdd( aRotina, { STR0015, 'ViewDef.AGRA720'	  , 0, 8, 0, .T. } ) //"Imprimir"

	//-- Se for o modelo novo utiliza novo relatorio
	If lImpressao .AND. GetRpoRelease() >= "12.1.023"
		aAdd( aRotina, { STR0039, 'UBAR007'    , 0,  8, 0, .F. } ) //"Termo de Reserva"
		aAdd( aRotina, { STR0052, 'AGRA720HIS' , 0, 11, 0, .F. } ) //"HISTÓRICO"
		aAdd( aRotina, { STR0040, "AGRCONHECIM('DXP')", 0,  9, 0, .F. } ) //"Conhecimento"
	Else
		aAdd( aRotina, { STR0039, 'UBAR001'   , 0,  8, 0, .F. } ) //"Termo de Reserva"
	EndIf

Return( aRotina )

/**-------------------------------------------------------------------------------------
{Protheus.doc} CanModelo
Rotina após cancelamento da gravação do modelo de dados

@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA720
-------------------------------------------------------------------------------------**/
Static Function CanModelo( oModel )
	__aFardos := {}
	__aLivres := {}
Return( .T. )

/**-------------------------------------------------------------------------------------
{Protheus.doc} A720VLDACT
Valida a ativação do modelo de dados

@param: Nil
@author: Aecio Ferreira Gomes
@since: 28/12/2012
@Uso: AGRA720
-------------------------------------------------------------------------------------**/
Static Function A720VLDACT(oModel)
	Local lRet		:= .T.
	Local cQry		:= ""
	Local cAliasQry 	:= ""
	Local nAcao		:= oModel:GetOperation()
	Local oStruDXP  	:= oModel:GetModel("DXPMASTER"):GetStruct()

	//-- AGRColPos() = Função do fonte AGRUTIL01.PRW 
	If AGRColPos('DXP_STATUS')
		If !IsIncallStack("OGC020")
			If nAcao == 4 .Or. nAcao == 5
				If !EMPTY(DXP->DXP_STATUS) .AND. DXP->DXP_STATUS <> "1"
					Help('',1,STR0029,,STR0046,1) //"ATENCAO"###""O regisro deste fardão já sofreu movimentações e não pode ser manipulado."
					lRet := .F.
				EndIf
			EndIf
		Endif
	EndIf
	
	// Se usa o modelo novo de comercialização então
	//-- AGRColPos() = Função do fonte AGRUTIL01.PRW 	
	If __lnewNeg .AND. AGRColPos('DXP_TIPRES') .AND. AGRColPos('DXP_CLAEXT')  .AND. AGRColPos('DXP_CLAINT')
		If .NOT. IsInCallStack("OGC10RES") .OR.  .NOT. IsInCallStack("OGC020") .OR. .NOT. IsInCallStack("OGCO10")
			If nAcao == 4
				If DXP->DXP_TIPRES == '1'
				   oStruDXP:SetProperty("DXP_TIPRES", MODEL_FIELD_WHEN, {||.F.})
				Else
				   oStruDXP:SetProperty("DXP_TIPRES", MODEL_FIELD_WHEN, {||.T.})
				EndIf
			Else
				oStruDXP:SetProperty("DXP_TIPRES", MODEL_FIELD_WHEN, {||.T.})
			EndIf
		EndIf

		If IsInCallStack("OGC020CRV") .OR. IsInCallStack("OGC020CAG")
			//*Retira obrigatoriedade dos campos de classificadores para quando realizar cancelamento
			//*de agenda ou reserva
			oModel:GetModel("DXPMASTER"):GetStruct():SetProperty( 'DXP_CLAEXT' , MODEL_FIELD_OBRIGAT, .F. )
			oModel:GetModel("DXPMASTER"):GetStruct():SetProperty( 'DXP_CLAINT' , MODEL_FIELD_OBRIGAT, .F. )
		EndIf
	EndIf
	
	If oModel:GetOperation() == 5	//Exclusão
		cAliasQry := GetNextAlias()
		If Select(cAliasQry) > 0
			(cAliasQry)->(DbCloseArea())
		EndIf

		cQry := "SELECT DXO.DXO_NUMIE AS INSTEMB FROM "+ RetSqlName("DXO") + " DXO, "
		cQry += "WHERE DXO_FILIAL	= '"+xFilial("DXO")+"' "
		cQry += "AND DXO.DXO_CODRES	= '"+DXP->DXP_CODIGO+"' "
		cQry += "AND DXO.D_E_L_E_T_	= '' "
		cQry := ChangeQuery( cQry ) 

		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

		If !Empty((cAliasQry)->INSTEMB)
			Help(STR0043 + (cAliasQry)->INSTEMB,1,"AGR720DEL")	//"Existem Reservas relacionadas as Instruções de Embarque: "
			lRet := .F.
		Endif
		(cAliasQry)->(DbCloseArea())
	Endif
Return(lRet)


/**-------------------------------------------------------------------------------------
{Protheus.doc} A720ACTIVE
Validação após ativação do modelos de dados

@param: oModel - Modelo de dados
@author: Aecio Ferreira Gomes
@since: 28/12/2012
@Uso: AGRA720
-------------------------------------------------------------------------------------**/
Static Function A720ACTIVE(oModel)
	Local oMdFieldsDXP  := oModel:GetModel( "DXPMASTER" )
	Local lRetorno	    := .T.

	// Se usa o modelo novo de comercialização então
	//-- AGRColPos() = Função do fonte AGRUTIL01.PRW 	
	If __lnewNeg .AND. AGRColPos('DXP_TIPRES') .AND. AGRColPos('DXP_DATTKP')
		If oModel:GetOperation() == MODEL_OPERATION_DELETE
			If oMdFieldsDXP:GetValue('DXP_STATUS') == '2'
				Help('',1,"AGRA720DEL") //"Não será possivel excluir reserva com status take-up efetuado."
				lRetorno := .F.			
			EndIf
		EndIf
	
		If __lnewNeg .and. (oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE )// Se usa o modelo novo de comercialização então
		
			//verifica se a safra foi informada			
			if type("_cSafraCad") <> "U" .and. !empty(_cSafraCad)
				If oMdFieldsDXP:CanSetValue("DXP_SAFRA")
					oMdFieldsDXP:SetValue('DXP_SAFRA' , _cSafraCad )		//safra
				EndIf
			endif
			
			//verifica se o cliente foi informado		
			if type("_cCodOgCli") <> "U" .and. !empty(_cCodOgCli)
				If oMdFieldsDXP:CanSetValue("DXP_CLIENT")
					oMdFieldsDXP:SetValue('DXP_CLIENT', _cCodOgCli )		// Cliente
				EndIf
			endif
			
			//verifica se a loja foi informada		
			if type("_cCodOgLoj") <> "U" .and. !empty(_cCodOgLoj)
				If oMdFieldsDXP:CanSetValue("DXP_LJCLI")
					oMdFieldsDXP:SetValue('DXP_LJCLI', _cCodOgLoj )		// Loja
				EndIf
			endif
			
			//*CHAMADA DA FUNÇÃO DE CONSULTA NECESSIDADE DE TAKE-UP
			If IsInCallStack("OGC10RES")
				If oMdFieldsDXP:CanSetValue("DXP_CODCTP")
					oMdFieldsDXP:SetValue('DXP_CODCTP', _cCntrCade )		//contrato
				EndIf
				If oMdFieldsDXP:CanSetValue("DXP_ITECAD")
					oMdFieldsDXP:SetValue('DXP_ITECAD', _cItemCade )		//item da cadencia
				EndIf
				If oMdFieldsDXP:CanSetValue("DXP_CLACOM")
					oMdFieldsDXP:SetValue('DXP_CLACOM', _cCodClass )		//classificação
				EndIf
				If oMdFieldsDXP:CanSetValue("DXP_TIPRES")
					oMdFieldsDXP:SetValue('DXP_TIPRES', "1" )				//1=Reserva de Contrato
				EndIf
			ElseIf IsInCallStack("OGC020") .AND. oModel:GetOperation() ==  MODEL_OPERATION_UPDATE
				oMdFieldsDXP:SetValue('DXP_DATTKP', dDatabase )
				oMdFieldsDXP:SetValue('DXP_HORTKP', Time() )
			EndIf
			
			//auto cura de reserva convertida para de contrato
			if oMdFieldsDXP:GetValue('DXP_TIPRES') == "1"
				if !empty(oMdFieldsDXP:GetValue('DXP_CODCTP')) //temos o contrato informado
					if empty(oMdFieldsDXP:GetValue('DXP_CLIENT')) .or. empty(oMdFieldsDXP:GetValue('DXP_LJCLI')) .or. empty(oMdFieldsDXP:GetValue('DXP_CLACOM'))
						//verifica se o cliente foi informado		
						dbSelectArea('NJR')
						NJR->(dbSetOrder(1))
						If NJR->(dbSeek(xFilial("NJR")+oMdFieldsDXP:GetValue('DXP_CODCTP')))
							
							//apropria os campos conforme a necessidade
							if empty(M->DXP_CLIENT)
								oMdFieldsDXP:SetValue('DXP_CLIENT', NJR->NJR_CODENT )
							endif
							
							
							if empty(M->DXP_CLACOM)
								oMdFieldsDXP:SetValue('DXP_CLACOM', NJR->NJR_TIPALG )
							endif
								
						endif
					endif
				endif
			endif
			
		EndIf
	EndIf
	//---------------------------------------------------
	// Carrega em um array os fardos vinculados a reserva
	//---------------------------------------------------
	LoadFardos(oModel)

Return lRetorno

/**-------------------------------------------------------------------------------------
{Protheus.doc} PreLinha
Pré validação da Grid

@author Cleber Maldonado
@since 18/12/2012
@version 1.0
-------------------------------------------------------------------------------------**/
Static Function PreLinha(oMdGridDXQ, nLine, cAction, cField, xValueNew, xValueOld)
	Local lRet 	:= .T.
	
	// Se usa o modelo novo de comercialização então
	//-- AGRColPos() = Função do fonte AGRUTIL01.PRW 	
	If __lnewNeg .AND. AGRColPos('DXP_TIPRES') .AND. AGRColPos('DXQ_APROVA')
		DO CASE
		CASE cAction $ "DELETE" .AND. FwFldGet("DXP_STATUS")== "2" .or. cAction $ "UPDATE".AND. FwFldGet("DXP_STATUS")== "2"//valida se a ação é DELETE OU UPDATE e não deixa deletar ou editar se o Take up estiver efetuado
		
				//Valida se existem fardos vinculados ao item da reserva aprovados
			If !(lRet := FwFldGet("DXQ_QUANT") == 0 )
					Help("",1,"AGR720NFAR") 
			EndIf
		CASE cAction == 'SETVALUE' .AND. FwFldGet("DXQ_APROVA")== "2" //valida se entrei no campo e estou alterando e se a aprovação é = 2 e obriga a preencher o campo OBS
			
			If IsInCallStack("OGC020")//valida se o programa está sendo executado pelo OGC020
				If (FwFldGet("DXQ_APROVA") != "1") .AND. Empty(FwFldGet("DXQ_OBSERV"))
						Help(" "  , 1, "AGRA720PC")//"O campo Observação é obrigatório. "Favor preencher o campo Observação.".//"O campo Observação é obrigatório." Para Solução: "Favor preencher o campo Observação.".
					    lRet := .F.
				EndIf
			EndIF
		ENDCASE
	Else //old valid
		DO CASE
		CASE cAction $ "DELETE"
			// Valida se existem fardos vinculados ao item da reserva
			If !(lRet := FwFldGet("DXQ_QUANT") == 0 )
				Help("",1,"AGR720NFAR") //Não é permitido reserva de blocos sem especificação dos fardos.
			EndIf
		ENDCASE
	EndIf
Return lRet

/**-------------------------------------------------------------------------------------
{Protheus.doc} PosLinha
Rotina para validaçao antes de iniciar o modelo de dados

@return:	.t. ou .f.	Verdadeiro (.t.) se deve carregar o modelo 
@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA720
-------------------------------------------------------------------------------------**/
Static Function PosLinha( oGrdDXQ )
	Local lRetorno	:= .t.
	Local nQtdFrd	:= oGrdDXQ:GetValue( "DXQ_QUANT" )
	
	If Empty( nQtdFrd )
		Help(" ",1,"AGR720NFAR")
		lRetorno := .f. 
	EndIf
	
	If lRetorno
		If .NOT. __lnewNeg // Se usa o modelo de comercialização então
			cAliasQry := GetNextAlias()
			cQry := "SELECT SUM(DXQ_QUANT) AS TOTAL FROM "+ RetSqlName("DXQ") + " DXQ," + RetSqlName("DXP") + " DXP "
			cQry += "WHERE DXQ_FILIAL	= 	'"+xFilial("DXQ")+"' "
			cQry += "AND DXP_FILIAL		= 	'"+xFilial("DXP")+"' "
			cQry += "AND DXP_CODIGO 	= 	DXQ_CODRES "
			cQry += "AND DXQ_CODRES 	<>  '"+FwFldGet("DXP_CODIGO")+"' "
			cQry += "AND DXP_CODCTP 	=   '"+FwFldGet("DXP_CODCTP")+"' "
			cQry += "AND DXP_ITECTP 	=   '"+FwFldGet("DXP_ITECTP")+"' "
			cQry += "AND DXQ.D_E_L_E_T_	=	'' "
			cQry += "AND DXP.D_E_L_E_T_	= 	''"
	
			cQry := ChangeQuery( cQry ) 
	
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	
			ADB->(dbSetOrder(1)) //Contrato + Item
			If ADB->(dbSeek(xFilial("ADB")+FwFldGet("DXP_CODCTP")+FwFldGet("DXP_ITECTP")))
				If ((cAliasQry)->TOTAL + FwFldGet("DXQ_QUANT")) > ADB->ADB_QUANT
					Help(STR0044,1,"AGR720QTD") //"Item relacionado ao embarque"
					lRetorno := .F.
				EndIf
			EndIf
		EndIf
	EndIf

Return( lRetorno )

/**-------------------------------------------------------------------------------------
{Protheus.doc} LoadFardos()
Carrega em Array os fardos pertencentes a Reserva e os fardos pertencentes ao bloco 
informado no item da reserva que estão livres

@param: oMdGridDXQ - Modelo de dados da Grid
@author: Aecio Ferreira Gomes
@since: 12/04/2013
@Uso: AGRA720
-------------------------------------------------------------------------------------**/
Static Function LoadFardos(oModel)
	Local oMdGridDXQ	:= oModel:GetModel("DXQDETAIL")
	Local aArea			:= GetArea()
	Local aRet			:= {}
	Local aSaveLines 	:= FWSaveRows()
	Local cReserv 		:= oModel:GetValue("DXPMASTER", "DXP_CODIGO")
	Local cSafra 		:= oModel:GetValue("DXPMASTER", "DXP_SAFRA")
	Local cBloco		:= ""
	Local cTipo 		:= ""
	Local lRet			:= .T.
	Local nX			:= 0

	//----------------------------------------
	// Carga dos fardos pertencentes a reserva
	//----------------------------------------
	For nX := 1 To oMdGridDXQ:Length()
		oMdGridDXQ:GoLine(nX)
		cBloco 	:= oMdGridDXQ:GetValue("DXQ_BLOCO")
		cTipo 	:= oMdGridDXQ:GetValue("DXQ_TIPO")

		// Carrega os fardos pertencentes ao bloco informando no item da reserva
		aRet := CarFardos(oModel, cReserv, cSafra, cBloco, cTipo , .T.)
		If Len(aRet) > 0
			aAdd( __aFardos, aClone(aRet))
		EndIf

		// Carrega fardos livres pertencentes ao bloco informado no item da reserva
		aRet := CarFardos(oModel, cReserv, cSafra, cBloco, cTipo , .F.)
		If Len(aRet) > 0
			aAdd( __aLivres, aClone(aRet))
		EndIf

	Next nX

	RestArea( aArea )
	FWRestRows( aSaveLines )
Return(lRet)

/**-------------------------------------------------------------------------------------
{Protheus.doc} IncFardos
Rotina de vinculo de fardos na reserva 

@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA720
-------------------------------------------------------------------------------------**/
Static Function IncFardos( oView )
	Local aArea		:= GetArea()
	Local oModel	:= FwModelActive() 
	Local oGrdDXQ	:= oModel:GetModel( "DXQDETAIL" )
	Local cCodRes 	:= FwFldGet( "DXP_CODIGO" )
	Local cCodSaf 	:= FwFldGet( "DXP_SAFRA" )
	Local cCodTip 	:= oGrdDXQ:GetValue( "DXQ_TIPO" )
	Local cCodBlq	:= oGrdDXQ:GetValue( "DXQ_BLOCO" )
	Local cItemRes  := oGrdDXQ:GetValue( "DXQ_ITEM" )

	If !Empty( cCodRes ) .And. !Empty( cCodBlq ) .And. !Empty( cCodTip )
		SelFardos( cCodRes, cCodSaf, cCodBlq, cCodTip, cItemRes )
	Else
		Help(STR0045,1,"AGR720SBLQ")	//"Bloco e tipo devem ser informados na reserva"
	EndIf

	RestArea( aArea )    
Return

/**-------------------------------------------------------------------------------------
{Protheus.doc} CarFardos
Carrega os dados dos fardos em arrays para posteriormente apresentar nos Browsers

@return:	.t. ou .f.	Verdadeiro (.t.) se deve carregar o modelo 
@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA720
-------------------------------------------------------------------------------------**/
Static Function CarFardos(oModel, cReserv, cSafra, cBloco, cTipo, lReservados)
	Local oMdGridDXQ	:= oModel:GetModel('DXQDETAIL')
	Local aArea		:= GetArea()
	Local aRecnos		:= {}
	Local aRet		:= {}
	Local cWhere    	:= "%%"
	Local lRet		:= .T.
	Local cFilFardo 	:= ""
	
	Default lReservados := .F.

	// Se usa o modelo novo de comercialização então
	//-- AGRColPos() = Função do fonte AGRUTIL01.PRW 	
	If __lnewNeg .AND. AGRColPos('DXQ_FILORG')
		cFilFardo := IIf(FwModeAccess("DXP",3) == "C",oMdGridDXQ:GetValue("DXQ_FILORG"),FWxFilial("DXI"))
	Else
		cFilFardo := FWxFilial("DXI")
	EndIf

	If lReservados
		lRet := aScan(__aFardos, { |x| x[2]+x[1] == cBloco+oMdGridDXQ:GetValue("DXQ_ITEM") } ) == 0
		If lRet
			cWhere := "%DXI.DXI_CODRES = '" +cReserv +"' And "
			cWhere += "DXI.DXI_ITERES = '" +oMdGridDXQ:GetValue("DXQ_ITEM") +"' And%"
		EndIf
	Else
		lRet := aScan(__aLivres, { |x| x[1] == cBloco} ) == 0
		If 	lRet
			cWhere := "%DXI.DXI_CODRES = '' And%"
		EndIf
	EndIf

	If lRet
		BeginSql Alias 'QryDXI'
		Select
		DXI.*, R_E_C_N_O_ AS DXIRECNO
		From
		%table:DXI% DXI
		Where
		DXI.DXI_FILIAL = %exp:cFilFardo% And
		DXI.DXI_SAFRA  = %exp:cSafra% And
		DXI.DXI_BLOCO  = %exp:cBloco% And
		DXI.DXI_CLACOM = %exp:cTipo% And
		%Exp:cWhere%
		DXI.%NotDel%
		Order By
		DXI.DXI_ETIQ
		EndSql

		QryDXI->( dbGotop() )
		While QryDXI->( !Eof() )

			If lReservados
				aAdd( aRecnos, QryDXI->(DXIRECNO))
			Else
				aAdd( aRecnos, QryDXI->(DXIRECNO))
			EndIf

			QryDXI->( dbSkip() )
		EndDo
		QryDXI->( dbCloseArea( ) )

		If Len( aRecnos ) > 0
			If lReservados
				aRet := {oMdGridDXQ:GetValue("DXQ_ITEM"), cBloco, aRecnos }
			Else
				aRet := { cBloco, aRecnos }
			EndIf
		EndIf
	EndIf

	RestArea( aArea )
Return( aClone(aRet) )

/**-------------------------------------------------------------------------------------
{Protheus.doc} SelFardos
Apresenta tela de seleção de fardos

@return:	
@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA720
-------------------------------------------------------------------------------------**/
Static Function SelFardos( cReserv, cSafra, cBloco, cTipo, nItem)
	Local oDlg		:= Nil
	Local oFwLayer	:= Nil
	Local oPnEsq 	:= Nil
	Local oPnCnt 	:= Nil
	Local oPnDir 	:= Nil
	Local oBrwEsq	:= Nil
	Local oBrwDir	:= Nil
	Local oSim		:= LoadBitmap( GetResources(), "LBOK" )	//Correção DAGROUBA-1970\DAGROUBA-892
	Local oNao		:= LoadBitmap( GetResources(), "LBNO" ) //Correção DAGROUBA-1970\DAGROUBA-892
	Local oVet		:= LoadBitmap( GetResources(), "LBNO" ) //Correção DAGROUBA-1970\DAGROUBA-892
	Local oModel	:= FwModelActive()
	Local oMdGridDXQ:= oModel:GetModel("DXQDETAIL")
	Local aArea		:= GetArea()
	Local aCords	:= FWGetDialogSize( oMainWnd )
	Local aRecnos	:= {}
	Local lRet		:= .T.
	Local nOpcX		:= 0
	Local nX		:= 0

	Static lMarcAllD := .T.
	Static lMarcAllE := .T.
	Static nSldDisp  := 0

	Private aItsEsq	:= {}
	Private aItsDir	:= {}

	//--------------------------------------------------------------------------------------------------------------------
	// Trava o registro do Bloco para impedir manutenção enquanto estiver sendo feito a seleção dos fardos para a reseerva
	//--------------------------------------------------------------------------------------------------------------------
	DXD->(dbSetOrder(1))
	If DXD->(dbSeek(xFilial("DXD")+cSafra+cBloco))
		lRet := DXD->(SoftLock("DXD") )
	EndIf

	If lRet
		nSldDisp := oMdGridDXQ:GetValue("DXQ_SLDISP")
		//--------------------------------------------------------------------------
		// Busca os fardos vinculados ao item da reserva para apresentar no browse
		//--------------------------------------------------------------------------
		If (nPos := aScan(__aFardos, { |x| x[2]+x[1] == cBloco+nItem } ) ) > 0
			aRecnos := aClone(aTail( __aFardos[nPos] ) )
		Else
			aRet := CarFardos(oModel, cReserv, cSafra, cBloco, cTipo , .T.)
			If Len(aRet) > 0
				aAdd(__aFardos, aClone(aRet))
				aRecnos := aClone( aTail(aRet) )
			EndIf
		EndIf

		If Len(aRecnos) > 0
			For nX := 1 To Len(aRecnos)
				DXI->(dbGoto(aRecnos[nX]))
				aAdd( aItsDir, { "2", DXI->DXI_ETIQ, DXI->DXI_CODIGO, DXI->DXI_PSBRUT, DXI->DXI_PSLIQU, DXI->DXI_ROMSAI,DXI->(Recno()) } )
			Next nX
			aRecnos := {}
		EndIf

		//-------------------------------------------------
		// Busca os fardos livres para apresentar no browse
		//-------------------------------------------------
		If (nPos := aScan(__aLivres, { |x| x[1] == cBloco} ) ) > 0
			aRecnos := aClone(__aLivres[nPos,2])
		Else
			aRet := CarFardos(oModel, cReserv, cSafra, cBloco, cTipo , .F.)
			If Len(aRet) > 0
				aAdd(__aLivres, aClone(aRet))
				aRecnos := aClone(aRet[2])
			EndIf
		EndIf

		If Len(aRecnos) > 0
			For nX := 1 To Len(aRecnos)
				DXI->(dbGoto(aRecnos[nX]))
				aAdd( aItsEsq, { "2", DXI->DXI_ETIQ, DXI->DXI_CODIGO, DXI->DXI_PSBRUT, DXI->DXI_PSLIQU, DXI->DXI_ROMSAI,DXI->(Recno()) } )
			Next nX
			aRecnos := {}
		EndIf

		//- Coordenadas da area total da Dialog
		oSize:= FWDefSize():New(.F.)
		oSize:AddObject("DLG",100,100,.T.,.T.)    
		oSize:SetWindowSize(aCords)
		oSize:lProp 	:= .T.      
		oSize:aMargins := {0,0,0,0}      
		oSize:Process()

		oDlg := TDialog():New(  oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0016, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Seleção de Fardos"

		// Cria Panel 
		oPnl:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3])

		oFwLayer := FwLayer():New()
		oFwLayer:Init( oPnl, .F., .T. )


		oFWLayer:AddLine( "SUP", 20, .T. )
		oFWLayer:AddLine( "INF", 80, .F. )

		oFWLayer:AddCollumn( "UNI" , 100, .F., "SUP" )
		oFWLayer:AddCollumn( "ESQ" ,  45, .F., "INF" )
		oFWLayer:AddCollumn( "CNT" ,  10, .F., "INF" )
		oFWLayer:AddCollumn( "DIR" ,  45, .F., "INF" )

		oFWLayer:AddWindow( "UNI" , "PSP", STR0017 		, 100, .f., .t., {||}, "SUP" ) //"Bloco"
		oFWLayer:AddWindow( "ESQ" , "PNE", STR0018		, 100, .f., .t., {||}, "INF" ) //"Fardos Livres"
		oFWLayer:AddWindow( "CNT" , "PNC", STR0019 		, 100, .f., .t., {||}, "INF" ) //"Ações"
		oFWLayer:AddWindow( "DIR" , "PND", STR0020		, 100, .f., .t., {||}, "INF" ) //"Fardos Reservados"

		oPnSup := oFWLayer:GetWinPanel( "UNI", "PSP", "SUP" )
		oPnEsq := oFWLayer:GetWinPanel( "ESQ", "PNE", "INF" )
		oPnCnt := oFWLayer:GetWinPanel( "CNT", "PNC", "INF" )
		oPnDir := oFWLayer:GetWinPanel( "DIR", "PND", "INF" )

		oSizeSU := FwDefSize():New()
		oSizeSU:AddObject( "PE0", 100, 100, .t., .t. )    
		oSizeSU:SetWindowSize( { 0, 0, oPnSup:nHeight, oPnSup:nWidth } )
		oSizeSU:lProp 	:= .t.
		oSizeSU:aMargins := { 0, 0, 0, 0 }      
		oSizeSU:Process()

		tSay():New( oSizeSU:aPosObj[1,1]+5, oSizeSU:aPosObj[1,2]+10, {|| STR0021 } , oPnSup, , , , , , .t., CLR_BLACK, CLR_WHITE, 040, 9 ) //"Tipo"
		tGet():New( oSizeSU:aPosObj[1,1]+5, oSizeSU:aPosObj[1,2]+30, {|| cTipo } , oPnSup, 40, 9, ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.t.,.F.,, cTipo,,,, )
		tSay():New( oSizeSU:aPosObj[1,1]+5, oSizeSU:aPosObj[1,2]+80 , {|| STR0017 } , oPnSup, , , , , , .t., CLR_BLACK, CLR_WHITE, 040, 020 ) //"Bloco"
		tGet():New( oSizeSU:aPosObj[1,1]+5, oSizeSU:aPosObj[1,2]+104, {|| cBloco } , oPnSup, 40, 9, ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.t.,.F.,, cBloco,,,, )

		oSizeE0 := FwDefSize():New()
		oSizeE0:AddObject( "PE0", 100, 100, .t., .t. )    
		oSizeE0:SetWindowSize( { 0, 0, oPnEsq:nHeight, oPnEsq:nWidth } )
		oSizeE0:lProp 	:= .t.
		oSizeE0:aMargins := { 0, 0, 0, 0 }      
		oSizeE0:Process()

		oBrwEsq := TCBrowse():New( oSizeE0:aPosObj[1,1], oSizeE0:aPosObj[1,2], oSizeE0:aPosObj[1,3], oSizeE0:aPosObj[1,4], , , , oPnEsq, , , , {|| }, {|| }, , , , , , , .f., , .t., , .f., , , )
		oBrwEsq:AddColumn( TCColumn():New(""		, { || IIf( aItsEsq[oBrwEsq:nAt,1] == "1", oSim, IIf( aItsEsq[oBrwEsq:nAt,1] == "2", oNao, oVet ) ) },,,,"CENTER",,.t.,.t.,,,,.f., ) )
		oBrwEsq:AddColumn( TCColumn():New(STR0022 	, { || aItsEsq[oBrwEsq:nAt,2] }									, , , , "LEFT" 		, 100, .f., .t., , , , .f., ) ) //"Etiqueta"
		oBrwEsq:AddColumn( TCColumn():New(STR0023	, { || aItsEsq[oBrwEsq:nAt,3] }									, , , , "LEFT" 		, 050, .f., .t., , , , .f., ) ) //"Fardo"
		oBrwEsq:AddColumn( TCColumn():New(STR0024	, { || Transform( aItsEsq[oBrwEsq:nAt,4], "@E 999,999,999.99" ) }	, , , , "RIGHT"		, 050, .f., .t., , , , .f., ) ) //"Peso Liquido"
		oBrwEsq:AddColumn( TCColumn():New(STR0025	, { || Transform( aItsEsq[oBrwEsq:nAt,5], "@E 999,999,999.99" ) }	, , , , "RIGHT"		, 050, .f., .t., , , , .f., ) ) //"Peso Bruto"
		oBrwEsq:AddColumn( TCColumn():New(""		, { || "" }                     									, , , , "LEFT"		, 001, .f., .t., , , , .f., ) )
		oBrwEsq:SetArray( aItsEsq )
		oBrwEsq:bLDblClick 		:= {|| MarcaUm( oBrwEsq, aItsEsq, oBrwEsq:nAt, .F. )}
		oBrwEsq:bHeaderClick 	:= {|| MarcaTudo( oBrwEsq, aItsEsq, oBrwEsq:nAt, @lMarcAllE, .F. ) }
		oBrwEsq:Align := CONTROL_ALIGN_ALLCLIENT

		oSizeC0 := FwDefSize():New()
		oSizeC0:AddObject( "PC0", 100, 100, .t., .t. )    
		oSizeC0:SetWindowSize( { 0, 0, oPnCnt:nHeight, oPnCnt:nWidth } )
		oSizeC0:lProp 	:= .t.
		oSizeC0:aMargins := { 0, 3, 0, 3 }
		oSizeC0:Process()

		tButton():New( oSizeC0:aPosObj[1,1]+10, oSizeC0:aPosObj[1,2], ">>" , oPnCnt, {|| MovFardos( ">", oBrwEsq, oBrwDir ) }, oSizeC0:aPosObj[1,4], 15, , /**oFont*/, , .t., , STR0026 ) //"Vincular Marcados"
		tButton():New( oSizeC0:aPosObj[1,1]+30, oSizeC0:aPosObj[1,2], "<<" , oPnCnt, {|| MovFardos( "<", oBrwEsq, oBrwDir ) }, oSizeC0:aPosObj[1,4], 15, , /**oFont*/, , .t., , STR0027 ) //"Desvincular Marcados"
		tSay():New( oSizeC0:aPosObj[1,1]+100, oSizeC0:aPosObj[1,2], {|| STR0028 } , oPnCnt, , , , , , .t., CLR_BLACK, CLR_WHITE, oSizeC0:aPosObj[1,4], 9 ) //"Qtd. Reservada"
		TGet():New( oSizeC0:aPosObj[1,1]+110, oSizeC0:aPosObj[1,2], {|| Len( aItsDir )	}, oPnCnt, oSizeC0:aPosObj[1,4], 9, "@E 999"			, , 0, , , .f., , .t., , .F., , .F., .F., , .t., .F., , "tGet1", , , , , , , , )
		tSay():New( oSizeC0:aPosObj[1,1]+125, oSizeC0:aPosObj[1,2], {|| STR0024  	}, oPnCnt, , , , , , .t., CLR_BLACK, CLR_WHITE, oSizeC0:aPosObj[1,4], 9 ) //"Peso Liquido"
		TGet():New( oSizeC0:aPosObj[1,1]+135, oSizeC0:aPosObj[1,2], {|| SomaPeso( "L" )	}, oPnCnt, oSizeC0:aPosObj[1,4], 9, "@E 999,999.99"	, , 0, , , .f., , .t., , .F., , .F., .F., , .t., .F., , "tGet2", , , , , , , , )
		tSay():New( oSizeC0:aPosObj[1,1]+150, oSizeC0:aPosObj[1,2], {|| STR0025		} , oPnCnt, , , , , , .t., CLR_BLACK, CLR_WHITE, oSizeC0:aPosObj[1,2], 9 ) //"Peso Bruto"
		TGet():New( oSizeC0:aPosObj[1,1]+160, oSizeC0:aPosObj[1,2], {|| SomaPeso( "B" )	}, oPnCnt, oSizeC0:aPosObj[1,4], 9, "@E 999,999.99"	, , 0, , , .f., , .t., , .F., , .F., .F., , .t., .F., , "tGet3", , , , , , , , )

		oSizeD0 := FwDefSize():New()
		oSizeD0:AddObject( "PD0", 100, 100, .t., .t. )    
		oSizeD0:SetWindowSize( { 0, 0, oPnDir:nHeight, oPnDir:nWidth } )
		oSizeD0:lProp 	:= .t.
		oSizeD0:aMargins := { 0, 0, 0, 0 }      
		oSizeD0:Process()

		oBrwDir := TCBrowse():New( oSizeD0:aPosObj[1,1], oSizeD0:aPosObj[1,2], oSizeD0:aPosObj[1,3], oSizeD0:aPosObj[1,4], , , , oPnDir, , , , {|| }, {|| }, , , , , , , .f., , .t., , .f., , , )
		oBrwDir:AddColumn( TCColumn():New(""		, { || IIf( aItsDir[oBrwDir:nAt,1] == "1", oSim, IIf( aItsDir[oBrwDir:nAt,1] == "2", oNao, oVet ) ) },,,,"CENTER",,.t.,.t.,,,,.f., ) )
		oBrwDir:AddColumn( TCColumn():New(""		, { || A720LEGEND(oBrwDir)},,,,"CENTER",,.t.,.t.,,,,.f., ) )
		oBrwDir:AddColumn( TCColumn():New(STR0022	, { || aItsDir[oBrwDir:nAt,2] }										, , , , "LEFT" 		, 100, .f., .t., , , , .f., ) ) //"Etiqueta"
		oBrwDir:AddColumn( TCColumn():New(STR0023 	, { || aItsDir[oBrwDir:nAt,3] }										, , , , "LEFT" 		, 050, .f., .t., , , , .f., ) ) //"Fardo"
		oBrwDir:AddColumn( TCColumn():New(STR0025	, { || Transform( aItsDir[oBrwDir:nAt,4], "@E 999,999,999.99" ) }	, , , , "RIGHT"		, 050, .f., .t., , , , .f., ) ) //"Peso Bruto"
		oBrwDir:AddColumn( TCColumn():New(STR0024	, { || Transform( aItsDir[oBrwDir:nAt,5], "@E 999,999,999.99" ) }	, , , , "RIGHT"		, 050, .f., .t., , , , .f., ) ) //"Peso Liquido"
		oBrwDir:AddColumn( TCColumn():New(""		, { || "" }                     									, , , , "LEFT"		, 001, .f., .t., , , , .f., ) )
		oBrwDir:bLDblClick 		:= {|| If(oBrwDir:COLPOS == 2, Legenda(), MarcaUm( oBrwDir, aItsDir, oBrwDir:nAt, .T. )) }
		oBrwDir:bHeaderClick 	:= {|| MarcaTudo( oBrwDir, aItsDir, oBrwDir:nAt, @lMarcAllD, .T. ) }
		oBrwDir:Align := CONTROL_ALIGN_ALLCLIENT 
		oBrwDir:SetArray( aItsDir )

		oDlg:Activate( , , , .t., , , EnchoiceBar(oDlg, {|| nOpcX := 1, oDlg:End() } , {|| nOpcX := 0, oDlg:End() } ) )

		If nOpcX == 1
			nPos := aScan(__aFardos, { |x| x[2] == cBloco } )

			//-----------------------------------------
			// Atualiza o array de fardos se vinculados
			//-----------------------------------------
			If nPos > 0
				aTail( __aFardos[nPos] ) := {}
				For nX := 1 To Len(aItsDir)
					aAdd(aTail( __aFardos[nPos] ), aTail(aItsDir[nX]) )
				Next nX
			Else
				aAdd(__aFardos, { oMdGridDXQ:GetValue("DXQ_ITEM"), cBloco, {} } )
				For nX := 1 To Len(aItsDir)
					aAdd(aTail(__aFardos)[3], aTail(aItsDir[nX]) )
				Next nX
			EndIf

			//-----------------------------------------
			// Atualiza o array de fardos livres
			//-----------------------------------------
			nPosL := aScan(__aLivres, { |x| x[1]  == cBloco } )
			If nPosL > 0
				__aLivres[nPosL,2] := {}
				For nX := 1 To Len(aItsEsq)
					aAdd(__aLivres[nPosL,2], aTail(aItsEsq[nX]) )
				Next nX
			Else
				aAdd(__aLivres, { cBloco, {} } )
				For nX := 1 To Len(aItsEsq)
					aAdd(aTail(__aLivres)[2], aTail(aItsEsq[nX]) )
				Next nX
			EndIf

			//-----------------------------------------
			// Atualiza item da reserva
			//-----------------------------------------
			oMdGridDXQ:SetValue("DXQ_QUANT" , Len( aItsDir ))
			oMdGridDXQ:SetValue("DXQ_SLDISP", nSldDisp)
			oMdGridDXQ:SetValue("DXQ_PSBRUT", SomaPeso( "B" ))
			oMdGridDXQ:SetValue("DXQ_PSLIQU", SomaPeso( "L" ))

		EndIf

	EndIf

	RestArea( aArea )
Return( )

/**-------------------------------------------------------------------------------------
{Protheus.doc} MovFardos
Responsavel pela transferencia dos registros entre os browsers

@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA720
-------------------------------------------------------------------------------------**/
Static Function MovFardos( cSeta, oBrwEsq, oBrwDir )
	Local oModel	:= FwModelActive() 
	Local oMdGridDXQ:= oModel:GetModel("DXQDETAIL")
	Local aArea		:= GetArea()
	Local aItsOrig 	:= {}
	Local aItsDest 	:= {}
	Local nX		:= 0 
	Local lRet		:= .T.

	If INCLUI .Or. ALTERA
		If cSeta == ">"
			aItsOrig 	:= aClone( aItsEsq )
			aItsDest 	:= aClone( aItsDir )
		EndIf
		If cSeta == "<"
			aItsOrig 	:= aClone( aItsDir )
			aItsDest 	:= aClone( aItsEsq )
		EndIf

		For nX := 1 to Len( aItsOrig )

			If nX > Len( aItsOrig )
				Exit
			EndIf

			If aItsOrig[ nX, 1 ] = "1"

				aAdd( aItsDest, aItsOrig[ nX ] )
				aItsDest[ Len( aItsDest ), 1 ] := "2"

				aDel( aItsOrig, nX )
				aSize( aItsOrig, Len( aItsOrig )-1 )
				nX--
			EndIf

		Next nX

		If !INCLUI

			DXQ->(dbSeek(xFilial("DXQ")+FwFldGet("DXP_CODIGO")+oMdGridDXQ:GetValue("DXQ_ITEM")))

			nQtdeAux := ABS(DXQ->DXQ_SLDISP - DXQ->DXQ_QUANT)		

			//-------------------------------------
			// Valida o saldo disponivel da reserva
			//-------------------------------------
			If cSeta == "<"
				If nQtdeAux > Len( aItsOrig )
					Help( , , STR0029, , STR0030, 1, 0 ) //"Atenção"###"A quantidade movimentada é superior a quantidade de fardos disponiveis"
					lRet := .F.
				Else
					nSldDisp := ( Len( aItsOrig ) - nQtdeAux ) 
				EndIf
			Else
				nSldDisp := ( Len( aItsDest ) - nQtdeAux )
			EndIf
		Else
			If cSeta == "<"
				nSldDisp := Len( aItsOrig )
			Else
				nSldDisp := Len( aItsDest )
			EndIf
		EndIf

		If lRet
			aItsOrig := ASort( aItsOrig, , , { | x, y | x[ 1 ] + x[ 2 ] < y[ 1 ] + y[ 2 ]})
			aItsDest := ASort( aItsDest, , , { | x, y | x[ 1 ] + x[ 2 ] < y[ 1 ] + y[ 2 ]})

			If cSeta == ">"
				aItsEsq := aClone( aItsOrig )
				aItsDir := aClone( aItsDest )
				lMarcAllE := .T.
				lMarcAllE := .T.
			EndIf

			If cSeta == "<"
				aItsEsq := aClone( aItsDest )
				aItsDir := aClone( aItsOrig )
				lMarcAllE := .T.
				lMarcAllE := .T.
			EndIf

			oBrwEsq:SetArray( aItsEsq )
			oBrwDir:SetArray( aItsDir )
			oBrwEsq:Refresh()
			oBrwDir:Refresh()
			RestArea(aArea)
		EndIf
	EndIf

	RestArea(aArea)
Return(lRet)

/**-------------------------------------------------------------------------------------
{Protheus.doc} MarcaUm
Marca/Desmarca Posicionado

@author: 	Aecio Ferreira Gomes
@since: 	10/12/2012
@Uso: 		AGRA720
-------------------------------------------------------------------------------------**/
Static Function MarcaUm( oBrwMrk, aItsMrk, nLinMrk, lDir)
	Local lMarca := .T.

	//Marca caso o fardo não tenha sido embarcado
	If lDir .And. !Empty(aItsMrk[ nLinMrk, 6 ])
		lMarca := .F.
	EndIf

	If lMarca

		DO CASE

		CASE aItsMrk[ nLinMrk, 1 ] == "1"
			aItsMrk[ nLinMrk, 1 ] := "2"

		CASE aItsMrk[ nLinMrk, 1 ] == "2"
			aItsMrk[ nLinMrk, 1 ] := "1"

		OTHERWISE
			MsgInfo( STR0031, STR0032 ) //"Este fardo ja esta pertence a outra reservada"###"Selecão não permitida..."

		ENDCASE

	EndIf

	oBrwMrk:Refresh()
Return

/**-------------------------------------------------------------------------------------
{Protheus.doc} MarcaAll
Marca/Desmarca Todos

@author: 	Aecio Ferreira Gomes
@since: 	10/12/2012
@Uso: 		AGRA720
-------------------------------------------------------------------------------------**/
Static Function MarcaTudo( oBrwMrk, aItsMrk, nLinMrk, lMark, lDir )
	Local nX	:= 0

	Default lMark := .T.

	For nX := 1 to Len( aItsMrk )

		//Pula caso o Fardo ja tenha sido embarcado
		If lDir .And. !Empty(aItsMrk[ nX, 6 ])
			Loop
		EndIf

		If aItsMrk[ nX, 1 ] $ "1|2"
			aItsMrk[ nX, 1 ] := If(lMark, "1", "2")
		EndIf
	Next nX

	oBrwMrk:Refresh()
	lMark := !lMark
Return( )

/**-------------------------------------------------------------------------------------
{Protheus.doc} SomaPeso
Rotina após cancelamento da gravação do modelo de dados

@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA720
-------------------------------------------------------------------------------------**/
Static Function SomaPeso( cTipo )
	Local nRet	:= 0
	Local nX	:= 0

	For nX := 1 to Len( aItsDir )

		If cTipo == "B"
			nRet += aItsDir[ nX, 4 ]
		EndIf
		If cTipo == "L"
			nRet += aItsDir[ nX, 5 ]
		EndIf

	Next nX

Return( nRet )

/**-------------------------------------------------------------------------------------
{Protheus.doc} GrvModelo
Rotina para gravação do modelo de dados

@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA720
@type: Function 
-------------------------------------------------------------------------------------**/
Static Function GrvModelo( oModel )
    	Local oMdFieldsDXP  	:= oModel:GetModel( "DXPMASTER" )
	Local oMdGridDXQ	:= oModel:GetModel("DXQDETAIL")
	Local aAreaAtu		:= GetArea()
	Local aRecnos		:= {}
	Local cCodRes		:= FwFldGet( "DXP_CODIGO" )//CODIGO DA RESERVA
	Local lContinua		:= .T.
	Local nI		:= 0
	Local nX		:= 0
	Local cFilFardo     	:= ""
	Local cMsgMemo 		:= TamSX3("NK9_MSGMEM")
	Local aMsgHist		:= {} 	
	
	cMsgMemo 		:= '' 
	aMsgHist 		:= AGR720GRVH(oModel) //monta as mensagens de histórico 
	
	If Empty(aMsgHist) .OR. .NOT. Empty(aMsgHist[1])
		BEGIN TRANSACTION
			
			//*Para inclusão e/ou alteração
			If lContinua .and. Len(__aFardos) > 0 .AND. (oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
				//-- AGRColPos() = Função do fonte AGRUTIL01.PRW 
				If AGRColPos('DXP_TIPRES')
					//seta o tipo de reserva, parametro falso 
					If !__lnewNeg
						oMdFieldsDXP:SetValue("DXP_TIPRES", "1")
					EndIf
				EndIf
				
				For nX := 1 To oMdGridDXQ:Length()
					oMdGridDXQ:GoLine(nX) 
					//-- AGRColPos() = Função do fonte AGRUTIL01.PRW 
					If AGRColPos('DXQ_FILORG')
						cFilFardo := IIf(FwModeAccess("DXP",3) == "C",oMdGridDXQ:GetValue("DXQ_FILORG"), FWxFilial("DXI")) //verificação da filial correta para listagem
					Else
						cFilFardo := FWxFilial("DXI") 
					EndIf
					
						
					//Limpa relacionamento entre a reserva e o fardo
					dbSelectArea( "DXI" )
					DXI->(dbSetOrder(5))
					DXI->(dbSeek(cFilFardo+cCodRes + oMdGridDXQ:GetValue("DXQ_ITEM")))
					While !Eof() .And. cFilFardo == DXI->DXI_FILIAL .And. cCodRes == DXI->DXI_CODRES .and. oMdGridDXQ:GetValue("DXQ_ITEM") == DXI->DXI_ITERES
						RecLock( "DXI", .F. )
						DXI->DXI_CODRES := ""
						DXI->DXI_ITERES := ""						
						if DXI->(ColumnPos('DXI_STATUS')) > 0
							DXI->DXI_STATUS := '40'		
						endIf
						DXI->(MsUnLock())
						DXI->(dbGoTop())
						DXI->(dbSeek(cFilFardo+cCodRes + oMdGridDXQ:GetValue("DXQ_ITEM")))
					End
	
					If oMdGridDXQ:IsDeleted()
						Loop
					EndIf
	
					dbSelectArea( "DXI" )
					dbSetOrder( 1 ) //Filial+ETIQUETA
	
					// Localiza os fardos vinculados ao item do contrato no array
					If (nPos := aScan(__aFardos, { |x| x[2]+x[1] == oMdGridDXQ:GetValue("DXQ_BLOCO")+oMdGridDXQ:GetValue("DXQ_ITEM") } ) ) > 0
						aRecnos := aTail( __aFardos[nPos] )
						For nI := 1 To Len(aRecnos)
							DXI->(dbGoto(aRecnos[nI]))
							RecLock( "DXI", .F. )
							DXI_CODRES := cCodRes
							if DXP->(ColumnPos('DXP_DATAGD')) > 0 .AND. DXI->(ColumnPos('DXI_STATUS')) > 0
								If  Empty( oMdFieldsDXP:GetValue('DXP_DATAGD') )
									DXI->DXI_STATUS := '50'
								Else
									DXI->DXI_STATUS := '60'
								EndIF
							endIf
							DXI_ITERES := oMdGridDXQ:GetValue("DXQ_ITEM") // Item da reserva
							DXI->(MsUnLock())
						Next nI
					EndIf
				Next nX
				
			ElseIf lContinua
				If FwModeAccess("DXP",3) == "C"
					For nX := 1 To oMdGridDXQ:Length()
						oMdGridDXQ:GoLine(nX) 
							
						cFilFardo := IIf(FwModeAccess("DXP",3) == "C",oMdGridDXQ:GetValue("DXQ_FILORG"),xFilial("DXI")) //verificação da filial correta para listagem
								
						//Limpa relacionamento entre a reserva e o fardo
						dbSelectArea( "DXI" )
						DXI->(dbSetOrder(5))
						DXI->(dbSeek(cFilFardo+cCodRes + oMdGridDXQ:GetValue("DXQ_ITEM")))
						While !Eof() .And. cFilFardo == DXI->DXI_FILIAL .And. cCodRes == DXI->DXI_CODRES ;
					                     .And. oMdGridDXQ:GetValue("DXQ_ITEM") == DXI->DXI_ITERES
							RecLock( "DXI", .F. )
								DXI->DXI_CODRES := ""
								DXI->DXI_ITERES := ""
							DXI->(MsUnLock())
							DXI->(dbGoTop())
							DXI->(dbSeek(cFilFardo+cCodRes + oMdGridDXQ:GetValue("DXQ_ITEM")))
							End
					Next nX
				Else  //default
					//Limpa relacionamento entre a reserva e o fardo
					dbSelectArea( "DXI" )
					DXI->(dbSetOrder(5))
					DXI->(dbSeek(xFilial("DXI")+cCodRes))
					While( !DXI->(Eof()).And. xFilial("DXI") == DXI->DXI_FILIAL .And. cCodRes == DXI->DXI_CODRES)
						RecLock( "DXI", .F. )
							DXI->DXI_CODRES := ""
							DXI->DXI_ITERES := ""
						DXI->(MsUnLock())
						DXI->(dbSeek(xFilial("DXI")+cCodRes))
					End
				EndIf
			EndIf
			If lContinua := FWFormCommit(oModel, /*[bBefore]*/, /*[bAfter]*/, /*[bAfterSTTS]*/, /*dentro*/, , /*<bIntegEAI >*/)
				If .NOT. Empty(aMsgHist)
					AGRGRAVAHIS(,,,,{"DXP",xFilial("DXP")+ALLTrim(cCodRes),aMsgHist[2],aMsgHist[1]})
				EndIf
			EndIf
		END TRANSACTION
		
	Else //Caso tenha cancelado a tela de motivos do histórico
		_CancHist := .T. 
		lContinua := .F. 
		oModel:SetErrorMessage( , , , "", "", STR0084, STR0085, "", "")	//"Motivo não Informado"#"Verificar motivo de histórico"
	EndIf
	
	if lContinua .And. FwFldGet( "DXP_TIPEMB" ) = "3" //Desativar regra especifica
		InativaReg(FwFldGet( "DXP_CODREG" ),FwFldGet( "DXP_CODIGO" ),oModel)
		FechaBloco(oModel)
	EndIf
	
	__aFardos := {}
	__aLivres := {}
	RestArea( aAreaAtu )
Return( lContinua )           

/*-------------------------------------------------------------------------------------
{Protheus.doc} AGR720GRVH()
Grava histórico das movimentações 

@param:  oModel
		CODIGO DA RESERVA 
		Estorno - Variável para identificar se a chamada da função pelo AGRA720APT é estorno ou aprovação de TAKE-UP   
@author: Daniel Maniglia Amancio da Silva
@since:  29/06/2017
@Uso:    AGRA720,OGC020,0GC010
-------------------------------------------------------------------------------------**/
Function AGR720GRVH(oModel)
	Local cMsgMemo 		:= TamSX3("NK9_MSGMEM")	
	Local aRetorno 		:= {}
	
	cMsgMemo := '' 
	//parametro ativo - Grava histórico somente para nova rotina RESERVA/Take-UP     
	//-- AGRColPos() = Função do fonte AGRUTIL01.PRW 
	If __lnewNeg .AND. AGRColPos('DXP_STATUS')
		//Define o tipo Alteração, Inclusão e Aprovação Take-UP
		If IsInCallStack("AGRA720APT")  //aprovar Take up e Estorno do TAKE-UP
			If _lAgra720E
				cMsgMemo := iif(!__lAutomato, AGR720HIS(STR0053,STR0077), "Estorno Automação Teste") //"Qual o motivo do Estorno?"                
			Else
				cMsgMemo := STR0054 //"Aprovação Take-Up"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
			End If
			aAdd(aRetorno,cMsgMemo)
			aAdd(aRetorno,'4')
		ElseIf  oModel:GetOperation()  == MODEL_OPERATION_INSERT .AND. IsInCallStack("AGRA720") //Incluir reserva
			cMsgMemo := STR0066 //"Inclusão da reserva pelo Cadastro de Reservas"
			aAdd(aRetorno,cMsgMemo)
			aAdd(aRetorno,'3')
		ElseIf oModel:GetOperation()  == MODEL_OPERATION_UPDATE .AND. IsInCallStack("AGRA720") //Alterar reserva
			cMsgMemo := STR0067 //Alteração da reserva pelo Cadastro de Reservas
			aAdd(aRetorno,cMsgMemo)
			aAdd(aRetorno,'4')
		ElseIf  IsInCallStack("OGC020CAG") //Cancelar Agenda
			cMsgMemo := Iif (!__lAutomato, AGR720HIS(STR0068,STR0078 ), "Cancelamento da Agenda - Automação") //Cancelamento da Agenda
			aAdd(aRetorno,cMsgMemo)
			aAdd(aRetorno,'C')
		ElseIf  IsInCallStack("OGC020CRV") //Cancelar Reserva
			cMsgMemo := iif(!__lAutomato, AGR720HIS(STR0069,STR0079), "Cancelamento da reserva - Automação") //cancelamento da reserva                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
			aAdd(aRetorno,cMsgMemo)
			aAdd(aRetorno,'C')
		ElseIf  IsInCallStack("OGC020CAR") //Cancelar Agenda e Reserva
			cMsgMemo := iif(!__lAutomato,AGR720HIS(STR0070,STR0080), "Cancelamento da Agenda e Reserva - Automação") //Cancelamento da Agenda e Reserva                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
			aAdd(aRetorno,cMsgMemo)
			aAdd(aRetorno,'C')
		ElseIf  IsInCallStack("OGC10RES") //Botão Reservar  - Necessidade de reserva
			If  oModel:GetOperation()  == MODEL_OPERATION_UPDATE     //Quando existe reserva no contrato
				cMsgMemo := STR0071 //"Alteração da reserva pela Necessidade de Reserva" 
				aAdd(aRetorno,cMsgMemo)
				aAdd(aRetorno,'3')
			ElseIf oModel:GetOperation()  == MODEL_OPERATION_INSERT  //Quando não existe reserva no contrato
				cMsgMemo := STR0072 //"Inclusão da reserva pela Necessidade de Reserva"                                                                                                                                                                                                                                                                                                                                                                                                                                                                  "
				aAdd(aRetorno,cMsgMemo)
				aAdd(aRetorno,'3')
			EndIf
		ElseIf  IsInCallStack("OGC020") //Efetuar TAKE-UP Agenda Takeup
			cMsgMemo := STR0073 //"Alteração Efetuar Take-Up"
			aAdd(aRetorno,cMsgMemo)
			aAdd(aRetorno,'4')
		ElseIf  IsInCallStack("OGC010EXV")
				
			If type("_lAgdAtrs") != "U" .AND. _lAgdAtrs = .T. //Indica se a reserva foi criada e está atrasada
				cMsgMemo := AGR720HIS(STR0081, STR0082)
				If .NOT. Empty(cMsgMemo)
					cMSGMemo := STR0076 + " - " + cMsgMemo
				EndIF
					aAdd(aRetorno,cMsgMemo)
					aAdd(aRetorno,'3')
			ElseIf type("_lOgc010Re") != "U" .AND. _lOgc010Re = .T.  //Com Reserva
				If type("_lOgc010Ag") != "U" .AND. _lOgc010Ag //Inclusão da agenda com reseva
					cMsgMemo := STR0074 //"Agendamento da reserva "
					aAdd(aRetorno,cMsgMemo)
					aAdd(aRetorno,'3')
				ElseIf type("_lOgc010Ag") != "U"
					cMsgMemo := STR0075 //Alteração da agenda com reseva
					aAdd(aRetorno,cMsgMemo)
					aAdd(aRetorno,'4')
				EndIF
			Else //Sem reserva
				If type("_lOgc010Ag") != "U" .AND. _lOgc010Ag //Inclusão da agenda com reseva
					cMsgMemo := STR0076 //"Inclusão e agendamento da reserva  "
					aAdd(aRetorno,cMsgMemo)
					aAdd(aRetorno,'3')
				EndIf
			EndIf
		EndIf
	Else
		//QUANDO INCLUI
		If oModel:GetOperation()  == MODEL_OPERATION_INSERT
			cMsgMemo := STR0066 //"Inclusão da reserva pelo Cadastro de Reservas"
			aAdd(aRetorno,cMsgMemo)
			aAdd(aRetorno,'3')
		EndIf

		//QUANDO ALTERA
		If oModel:GetOperation()  == MODEL_OPERATION_UPDATE
			cMsgMemo := STR0067 //Alteração da reserva pelo Cadastro de Reservas
			aAdd(aRetorno,cMsgMemo)
			aAdd(aRetorno,'4')
		EndIf
	
	EndIf  //FIM __lnewNeg
Return aRetorno


/*
+=================================================================================================+
| Programa  : AGR720HIS                                                                           |
| Descrição : TRATAMENTO DE HISTÓRIO DE TABELAS                                            	  |
| Autor     : Daniel Maniglia                                                                     |
| Data      : 10/07/2017                                                                          |
+=================================================================================================+     
*/
Function AGR720HIS(cMsg,cMotivo)
	Local lOpcao	:= .F.
	Local cMsgMemo 	:= TamSX3("NK9_MSGMEM")
	Local dDate	:= dDataBase
	Local cNomUsu 	:= ""
	Local oMsg	:= Nil

	cMsgMemo := ''

	DbSelectArea("NK9")
	cNomUsu := UsrRetName(RetCodUsr())

	oDlg	:= TDialog():New(350,406,588,795,cMsg,,,,,CLR_BLACK,CLR_WHITE,,,.t.)
	oDlg:lEscClose := .f.

	@ 008,008 SAY STR0054 PIXEL			//"Data"
	@ 008,024 MSGET dDate OF oDlg PIXEL WHEN .f.

	@ 008,092 SAY STR0055 PIXEL 			//"Usuário"
	@ 008,116 MSGET cNomUsu OF oDlg PIXEL WHEN .f.

	@ 032,008 SAY cMotivo PIXEL
	@ 040,008 GET oMsg Var cMsgMemo OF oDlg Multiline Size 172,062 PIXEL VALID NaoVazio(cMsgMemo)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lOpcao := .T., oDlg:End()},{|| lOpcao := .F.,oDlg:End()}) CENTERED

Return Iif(lOpcao,cMsgMemo,'')


/**-------------------------------------------------------------------------------------
{Protheus.doc} AGR720WHEN()
Validação de edição dos campos

@param: Nil
@author: Aecio Ferreira Gomes
@since: 01/11/2012
@Uso: AGRA720
-------------------------------------------------------------------------------------**/
Function AGR720WHEN()
	Local lRet := .T.
 
	//-- AGRColPos() = Função do fonte AGRUTIL01.PRW 
	//-- Se novo modelo de comercialização
	If __lnewNeg .AND. AGRColPos('DXP_STATUS')  .AND. AGRColPos('DXQ_APROVA')
		DO CASE
					
		CASE ( "DXP_CLIENT" $ ReadVar() )
				lRet := Empty( M->DXP_CODCTP ) .or.	Empty( DXP->DXP_CLIENT )		
		CASE ( "DXP_LJCLI" $ ReadVar() )
				lRet := Empty( M->DXP_CODCTP ) .or.	Empty( DXP->DXP_LJCLI )		
		ENDCASE
	Else
		DO CASE
		CASE ( "DXP_CLIENT" $ ReadVar() )
			lRet := Empty( M->DXP_SAFRA )

		CASE ( "DXP_LJCLI" $ ReadVar() )
			lRet := Empty( M->DXP_SAFRA )    

		ENDCASE
	EndIf

Return(lRet)

/**-------------------------------------------------------------------------------------
{Protheus.doc} A720LEGEND()
Retorna a legenda do registro, Verde = Disponivel; Vemelho = Embarcado

@param: Nil
@author: Aecio Ferreira Gomes
@since: 01/11/2012
@Uso: AGRA720
-------------------------------------------------------------------------------------**/
Static Function A720LEGEND(oBrwDir)
	Local oVerde	:= LoadBitmap( GetResources(), "br_verde_ocean" )
	Local oVermelho	:= LoadBitmap( GetResources(), "br_vermelho_ocean" )

Return( If(Empty(oBrwDir:AARRAY[oBrwDir:NAT][6]), oVerde, oVermelho) )

/**-------------------------------------------------------------------------------------
{Protheus.doc} Legenda()
Apresenta tela de legenda do registro
Verde 	= Fardo Pendente
Vermelho  = Fardo Embarcado

@param: Nil
@author: Aecio Ferreira Gomes
@since: 11/04/2013
@Uso: AGRA720
-------------------------------------------------------------------------------------**/
Static Function Legenda()
	Local aLeg	  := {}

	aAdd(aLeg,{"BR_VERDE"     ,STR0033 })    //"Fardo Pendente"
	aAdd(aLeg,{"BR_VERMELHO"  ,STR0034 })    //"Fardo Embarcado"

	BrwLegenda(STR0035,STR0036,aLeg) //"Legenda"###"Status"
Return

/**-------------------------------------------------------------------------------------
{Protheus.doc} AGRA720CPO()
Validação de campos

@param: Nil
@author: Aecio Ferreira Gomes
@since: 12/04/2013
@Uso: AGRA720
-------------------------------------------------------------------------------------**/
Function AGRA720CPO()
	Local aArea 		:= GetArea()
	Local lRet			:= .T.

	DO CASE
	CASE ( "DXP_CLIENT" $ Readvar() )
			// Valida se o registro informado existe na base de dados	
			lRet :=	Vazio() .Or. ExistCpo('SA1',FwFldGet("DXP_CLIENT")+IF( !Empty( FwFldGet("DXP_LJCLI") ), FwFldGet("DXP_LJCLI"), ''), 1)
			
	CASE ( "DXP_LJCLI" $ Readvar() )
			// Valida se o registro informado existe na base de dados	
			lRet :=	Vazio() .Or. ExistCpo('SA1',FwFldGet("DXP_CLIENT")+FwFldGet("DXP_LJCLI"), 1)

	CASE ( "DXP_SAFRA" $ Readvar() )
			// Valida se o registro informado existe na base de dados	
			//-- Tratamento utilizado pelo UBA - Exemplo AGRA615
		If AGRColPos('NN1_CODSAF')
				lRet := Vazio() .Or. ExistCpo('NJU')
		Else
				lRet := Vazio() .Or. ExistCpo('NN1')
		EndIf
			cSafraCTR := FwFldGet('DXP_SAFRA')	
						
	CASE ( "DXP_CODCTP" $ Readvar() )
			//-- AGRColPos() = Função do fonte AGRUTIL01.PRW 
			//-- Se novo modelo de comercialização
		If __lnewNeg .AND. AGRColPos('DXP_STATUS')  .AND. AGRColPos('DXQ_APROVA')
				// Valida se o registro informado existe na base de dados	
				lRet := Vazio() .Or. ExistCPO("NJR", FwFldGet("DXP_CODCTP"), 1)
				
			If !(Vazio())
					dbSelectArea('NJR')
					dbSetOrder(1)
				If dbSeek(xFilial("NJR")+FwFldGet("DXP_CODCTP"))
					If NJR->NJR_CODSAF != FwFldGet('DXP_SAFRA')
							Help(,,STR0029,,STR0037, 1, 0 ) //"Atenção"###"A safra do contrato difere da safra informada na reserva"
							lRet := .F.
					elseif 	!(NJR->NJR_TIPO $ '1|2')
							Help(" ",1,"AGRA720CT1")  //O contrato informado é inválido. O tipo difere de Vendas ou Compras.
							lRet := .F.
					elseif !(NJR->NJR_STATUS $ 'I|A')
							Help(" ",1,"AGRA720CT2") //O contrato informado é inválido. O status difere de Iniciado ou Aberto. 
							lRet := .F.
					elseif empty(NJR->NJR_TKPFIS)
						 	Help(" ",1,"AGRA720CT3") //O contrato informado é inválido. O tipo de Take-up não está informado. 
							lRet := .F.
					elseif empty(NJR->NJR_TIPALG)
							Help(" ",1,"AGRA720CT4") //O contrato informado é inválido. O tipo de Algodão não está informado.  
							lRet := .F.
					elseif POSICIONE("NJ0",1,xFilial("NJ0") + NJR->NJR_CODENT + NJR->NJR_LOJENT,"NJ0_CODCLI") != FwFldGet("DXP_CLIENT") .OR. POSICIONE("NJ0",1,xFilial("NJ0") + NJR->NJR_CODENT + NJR->NJR_LOJENT,"NJ0_LOJCLI") != FwFldGet("DXP_LJCLI") //valida se o cliente da entidade do contrato é o mesmo da reserva
							Help(" ",1,"AGRA720CT5")  //O cliente da reserva é divergente do cliente do contrato.
							lRet := .F.
					Endif
				Endif
			endif
		Else
				// Valida se o registro informado existe na base de dados	
				lRet := Vazio() .Or. ExistCPO("ADB", FwFldGet("DXP_CODCTP")+IF( !Empty(FwFldGet("DXP_ITECTP") ), FwFldGet("DXP_ITECTP"), ''), 1)
				
			If !(Vazio())
					dbSelectArea('ADA')
					dbSetOrder(1)
				If dbSeek(xFilial("ADA")+FwFldGet("DXP_CODCTP"))
					If AGRColPos('NN1_CODSAF')
						If ADA->ADA_CODSAF != FwFldGet('DXP_SAFRA')
								Help(,,STR0029,,STR0037, 1, 0 ) //"Atenção"###"A safra do contrato difere da safra informada na reserva"
								lRet := .F.
						ElseIf ADA->ADA_CODCLI != FwFldGet('DXP_CLIENT') .OR. ADA->ADA_LOJCLI != FwFldGet('DXP_LJCLI')
								Help(" ",1,"AGRA720CT5")  //O cliente da reserva é divergente do cliente do contrato.
								lRet := .F.
						Endif
					Else
						If ADA->ADA_SAFRA != FwFldGet('DXP_SAFRA')
								Help(,,STR0029,,STR0037, 1, 0 ) //"Atenção"###"A safra do contrato difere da safra informada na reserva"
								lRet := .F.
						ElseIf ADA->ADA_CODCLI != FwFldGet('DXP_CLIENT') .OR. ADA->ADA_LOJCLI != FwFldGet('DXP_LJCLI')
								Help(" ",1,"AGRA720CT5")  //O cliente da reserva é divergente do cliente do contrato.
								lRet := .F.
						Endif
					EndIf
				Endif
			Endif
		EndIf
		
		//-- AGRColPos() = Função do fonte AGRUTIL01.PRW 
		//-- Se novo modelo de comercialização	
		//If __lnewNeg .AND. AGRColPos('DXP_ITECAD')
	CASE ( AGRColPos('DXP_ITECAD') .AND. "DXP_ITECAD" $ Readvar() )
				//-- Se novo modelo de comercialização, adiciona o gatilho no campo contrato para o campo tipos de algodão aceitáveis	
		If __lnewNeg
					// Valida se o registro informado existe na base de dados	
					lRet := ExistCPO("NNY", FwFldGet("DXP_CODCTP")+FwFldGet("DXP_ITECAD") , 1)
		EndIf
		//Else 
	CASE ( "DXP_ITECTP" $ Readvar() )
				// Valida se o registro informado existe na base de dados	
				lRet := ExistCPO("ADB", FwFldGet("DXP_CODCTP")+FwFldGet("DXP_ITECTP") , 1)
		//EndIf   
		
	CASE ( "DXQ_BLOCO" $ Readvar() )
			// Valida se o registro informado existe na base de dados
		If .Not. __lnewNeg
				lRet := Vazio() .Or. ExistChav("DXD", xFilial("DXD") + M->DXP_SAFRA + M->DXQ_BLOCO, 1)
		Else
				lRet := Vazio() .Or. ExistCPO("DXD", M->DXP_SAFRA + M->DXQ_BLOCO, 1)		 
		EndIf

	ENDCASE

	RestArea(aArea)
Return(lRet)

/**-------------------------------------------------------------------------------------
{Protheus.doc} AGRA720GQT()
Gatilha o saldo disponivel do bloco e vincula os fardos ao item da reserva

@param: Nil
@author: Aecio Ferreira Gomes
@since: 18/04/2013
@Uso: AGRA720
-------------------------------------------------------------------------------------**/
Function AGRA720GQT()
	Local oModel     := FwModelActive()
	Local oMdGridDXQ := oModel:GetModel("DXQDETAIL")
	Local aRet 		 := {}
	Local aRecnos	 := {}
	Local aArea		 := GetArea()
	Local cReserv	 := FwFldGet("DXP_CODIGO")
	Local cSafra	 := FwFldGet("DXP_SAFRA")
	Local cBloco	 := oMdGridDXQ:GetValue("DXQ_BLOCO")
	Local cTipo		 := oMdGridDXQ:GetValue("DXQ_TIPO")
	Local nRet		 := 0       
	Local nPsBrut	 := 0
	Local nPsLiqu	 := 0
	Local nX		 := 0

	nSldDisp := 0
	
	If Empty(cTipo)
		
		dbSelectArea("DXD")
		dbSetOrder(1)
		If dbSeek( xFilial("DXD") + cSafra + cBloco)
			cTipo := DXD->DXD_CLACOM			
		Endif
	Endif

	If !Empty(cBloco)

		//---------------------------------------------------
		// Busca os fardos disponivels pertencentes ao bloco
		//---------------------------------------------------
		If (nPos := aScan(__aLivres, { |x| x[1] == cBloco } )) == 0
			aRet  := CarFardos(oModel, cReserv, cSafra, cBloco, cTipo , .F.)

			If Len(aRet) > 0
				aRecnos := aTail(aRet)
			Endif

			// Adiciona no array de fardos livres o bloco.
			aAdd(__aLivres, {cBloco,{}})
		Else
			//----------------------------------
			// Retira os fardos do array livres 
			//----------------------------------
			If Len(aTail(__aLivres[nPos])) > 0
				aRecnos := aClone( aTail( __aLivres[nPos] ) )

				// Retira os fardos do array de livres para adicionar no array de vinculados
				aTail(__aLivres[nPos]) := {}
			EndIf
		EndIf

		//----------------------------------------------------------------------
		// Adiciona os fardos disponiveis no Array de fardos vinculados ao item
		//----------------------------------------------------------------------
		If Len(aRecnos) > 0
			If (nPos := aScan(__aFardos, { |x| x[2]+x[1] == cBloco+oMdGridDXQ:GetValue("DXQ_ITEM") } ) ) == 0
				aAdd(__aFardos, { oMdGridDXQ:GetValue("DXQ_ITEM"), cBloco, aClone(aRecnos) } )
			Else
				For nX := 1 To Len(aRecnos)
					aAdd(aTail(__aFardos[nPos]), aRecnos[nX])
				Next nX
			EndIf

			//-------------------------------------
			// Verifica a posição do item no array
			//-------------------------------------
			nPos := aScan(__aFardos, { |x| x[2]+x[1] == cBloco+oMdGridDXQ:GetValue("DXQ_ITEM") } )

			//--------------------------
			// Calcula os saldo do item
			//--------------------------
			If nPos > 0
				If !INCLUI
					DXQ->(dbSetOrder(1))
					If DXQ->(dbSeek(xFilial("DXQ")+FwFldGet("DXP_CODIGO")+oMdGridDXQ:GetValue("DXQ_ITEM") ) )
						// Se o bloco selecionado igual ao da base de dados
						If cBloco == DXQ->(DXQ_BLOCO)
							nSldDisp := ( Len(aTail( __aFardos[nPos] ) ) - ABS(DXQ->DXQ_SLDISP - DXQ->DXQ_QUANT))
						Else
							nSldDisp := Len(aTail( __aFardos[nPos] ) )
							nRet := nSldDisp
						EndIf
					Else
						nSldDisp := Len(aTail( __aFardos[nPos] ) )
						nRet := nSldDisp
					EndIf
				Else
					nSldDisp := Len(aTail( __aFardos[nPos] ) )
					nRet  := nSldDisp
				EndIf

				//-----------------------------------------
				// Calcula o total de peso bruto e liquido
				//-----------------------------------------
				For nX := 1 To Len(aTail( __aFardos[nPos] ) )
					DXI->(dbGoto(aTail( __aFardos[nPos] )[nX]))
					nPsLiqu += DXI->DXI_PSLIQU
					nPsBrut += DXI->DXI_PSBRUT
				Next nX

			EndIf

		EndIf

	EndIf
	
	oMdGridDXQ:LoadValue("DXQ_TIPO"  , cTipo)
	oMdGridDXQ:SetValue("DXQ_SAFRA" , cSafra)
	oMdGridDXQ:SetValue("DXQ_SLDISP", nSldDisp)
	oMdGridDXQ:SetValue("DXQ_PSBRUT", nPsBrut)
	oMdGridDXQ:SetValue("DXQ_PSLIQU", nPsLiqu)

	RestArea(aArea)
Return (nRet)

/**-------------------------------------------------------------------------------------
{Protheus.doc} AGRA720FCP()
Filtro do contrato de parceria para a consulta padrão ADBDXP

@param: Nil
@author: Aecio Ferreira Gomes
@since: 30/04/2013
@Uso: AGRA720
-------------------------------------------------------------------------------------**/
Function AGRA720FCP()
	Local cAliasQry := ""
	Local aArea		:= GetArea()
	Local cfiltro	:= ""
	Local cfiltroS	:= ""

	cAliasQry:= GetNextAlias( )
	If Select(cAliasQry) > 0
		(cAliasQry)->(DbCloseArea())
	EndIf
	
	//-- Tratamento utilizado pelo UBA - Exemplo AGRA615
	If AGRColPos('NN1_CODSAF')
		cfiltroS := "% ADA.ADA_CODSAF = '" + M->DXP_SAFRA + "' %"
	Else
		cfiltroS := "% ADA.ADA_SAFRA  = '" + M->DXP_SAFRA + "' %"
	EndIf
	
	BeginSQL Alias cAliasQry
		Select * From %table:ADA% ADA
			Where ADA.ADA_FILIAL = %xFilial:ADA%
			  And ADA.D_E_L_E_T_ = ''
			  And ADA.ADA_CODCLI = %exp:M->DXP_CLIENT%
			  And ADA.ADA_LOJCLI = %exp:M->DXP_LJCLI%    	
			  And %exp:cfiltroS% 		  
	EndSql

	dbSelectArea(cAliasQry)
	(cAliasQry)->( dbGoTop() )
	if (cAliasQry)->(!Eof())
		If AGRColPos('NN1_CODSAF') .AND. Alltrim(M->DXP_SAFRA) = AllTrim((cAliasQry)->ADA_CODSAF)
			cfiltro := "@# ADB_CODCLI == '"+M->DXP_CLIENT+"'"+" .AND. ADB_LOJCLI =='"+M->DXP_LJCLI+"'" /*+" .AND. ADB_SAFRA =='"+M->DXP_SAFRA*/+"@#"
		Elseif  M->DXP_SAFRA = (cAliasQry)->ADA_SAFRA
			cfiltro := "@# ADB_CODCLI == '"+M->DXP_CLIENT+"'"+" .AND. ADB_LOJCLI =='"+M->DXP_LJCLI+"'" /*+" .AND. ADB_SAFRA =='"+M->DXP_SAFRA*/+"@#"
		else
			cfiltro := '@#"1" <> "1"@#'
		endif
	else
		cfiltro := '@#"1" <> "1"@#'
	endif

	(cAliasQry)->(DbCloseArea())

	RestArea(aArea)
Return(cfiltro)

/* {Protheus.doc} AGRA720POS
Função que grava o modelo de dados após a confirmação

@author 	marcelo.wesan
@since 		23/03/2017
@version 	1.0
@param.:    oModel - Modelo de dados
@return:    lRetorno [Retorno do Commit - podendo ser .T. ou .F.]
*/
Static Function AGRA720POS( oModel )
	Local lRetorno		:= .T.
	Local nX            := 0
	Local nOperation	:= oModel:GetOperation()
	Local oMdFieldsDXP  := oModel:GetModel("DXPMASTER")
	Local oModelDXQ		:= oModel:GetModel('DXQDETAIL')
	Local nI			:= 0
	Local aRecnos		:= {}
	Local aTiposAct     := {}

	//-- AGRColPos() = Função do fonte AGRUTIL01.PRW
	If AGRColPos('DXP_STATUS') .OR. AGRColPos('DXP_TIPRES')

		//---- QUANDO ALTERACAO
		If nOperation == MODEL_OPERATION_UPDATE      //--- IF 01
			//Valida se o status é Take up efetuado e não permite a edição
			If FwFldGet("DXP_STATUS") = "2"      //--- IF 02
				Help(" "  , 1, "AGRA720TA" )	//Esta reserva não pode ser alterada!, Take-up já realizado.
				lRetorno := .F.
			Else
				If nOperation == MODEL_OPERATION_UPDATE .AND. IsInCallStack("OGC020") // valida se a edição é executada pelo OGC020
					For nX := 1 To  oModelDXQ:Length()
						oModelDXQ:Goline( nX )
						If (Empty(FwFldGet("DXQ_BLOCO"))) //Não tem registros no browse BLOCOS
							Exit
						EndIf
						If (FwFldGet("DXQ_APROVA") != "1") .AND. Empty(FwFldGet("DXQ_OBSERV")) // valida se a aprovação é diferente de 1 e obriga o usuario a preencher o campo obs
							Help(" "  , 1, "AGRA720PC")//"O campo Observação é obrigatório. "Favor preencher o campo Observação.".
							lRetorno := .F.
						EndIf
					Next nX
				EndIf
			EndIf	//--- ENDIF 02
		EndIf	//--- ENDIF 01

		If __lnewNeg // Se usar o novo modelo de comercialização então
			//--- IF 01
			If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
				//--- IF 02
				If  .not. IsInCallStack("OGC020") .or. .not. IsInCallStack("OGC010") .or. .not. IsInCallStack("OGC10RES")
					//--- IF 03
					If FwFldGet("DXP_TIPRES") = "1" // valida  o tipo de reserva
						If empty(FwFldGet("DXP_CLIENT"))
							Help(" "  , 1, "AGRA720CL")//"O campo cliente é obrigatório. "Favor preencher o campo Cliente."
							lRetorno := .F.
						ElseIf empty(FwFldGet("DXP_LJCLI"))
							Help(" "  , 1, "AGRA720LJ")//"O campo loja cliente é obrigatório. "Favor preencher o campo loja cliente."
							lRetorno := .F.
						ElseIf empty(FwFldGet("DXP_CODCTP"))
							Help(" "  , 1, "AGRA720CT")//"O campo Contrato é obrigatório. "Favor preencher o campo Contrato."
							lRetorno := .F.
						ElseIf empty(FwFldGet("DXP_ITECAD"))
							Help(" "  , 1, "AGRA720CAD")//"O campo cadencia é obrigatório. "Favor preencher o campo cadencia."
							lRetorno := .F.
						ElseIf empty(FwFldGet("DXP_CLACOM"))
							Help(" "  , 1, "AGRA720TP")//"O campo class comercial é obrigatório. "Favor preencher o campo class comercial."
							lRetorno := .F.
						EndIf
						//--- ELSEIF 03
					ElseIf FwFldGet("DXP_TIPRES") = "2" .and. .NOT. empty(FwFldGet("DXP_CODCTP"))
						Help(" "  , 1, "AGRA720TR")//"Quando o tipo de reserva, for  especifica não deve ser informado contrato. "Remova o contrato ou altere o tipo de reserva para reserva de contrato."
						lRetorno := .F.
					EndIf	//--- ENDIF 03
				EndIf //--- IF 02

				//Verifica se o fardo não foi apropriado em outra reserva
				For nX := 1 To oModelDXQ:Length()
					oModelDXQ:GoLine(nX)
					If !oModelDXQ:IsDeleted() .and. lRetorno
						//apropria os tipos aceitaveis
						If oModelDXQ:GetValue("DXQ_APROVA") == '1' // linha aprovada
							aAdd(aTiposAct,{oModelDXQ:GetValue("DXQ_TIPO"), oModelDXQ:GetValue("DXQ_PSLIQU") })
						EndIf

						dbSelectArea( "DXI" )
						dbSetOrder( 1 ) //Filial+ETIQUETA
						// Localiza os fardos vinculados ao item do contrato no array
						If (nPos := aScan(__aFardos, { |x| x[2]+x[1] == oModelDXQ:GetValue("DXQ_BLOCO")+oModelDXQ:GetValue("DXQ_ITEM") } ) ) > 0
							aRecnos := aTail( __aFardos[nPos] )
							For nI := 1 To Len(aRecnos)
								DXI->(dbGoto(aRecnos[nI]))
								If !empty(DXI->DXI_CODRES) .and. DXI->DXI_CODRES <> oMdFieldsDXP:GetValue("DXP_CODIGO") //está apropriado em outra reserva
									Help(" "  , 1, "AGRA720BUS")//"Existem fardos selecionados já utilizados em outra reserva."
									lRetorno := .F.
									Exit
								EndIf
							Next nI
						ElseIf !empty(oModelDXQ:GetValue("DXQ_BLOCO")) .and. !empty(oModelDXQ:GetValue("DXQ_ITEM"))
							Help(" "  , 1, "AGRA720BNF")//"Existem blocos que não possuem fardos vinculados"
							lRetorno := .F.
						EndIf
					EndIf
				Next nX

				//validação de quantidade aceitavel - somente tratmento de take-up
				If IsInCallStack("OGC10RES") .or. IsInCallStack("AGRA720")
					If lRetorno .and. !AGRA720VTAC(oMdFieldsDXP:GetValue("DXP_CODCTP"), "1", aTiposAct, oMdFieldsDXP:GetValue("DXP_CODIGO"))
						lRetorno := .F.
					EndIf
				ElseIf IsInCallStack("OGC020TKP")
					If lRetorno .and. !AGRA720VTAC(oMdFieldsDXP:GetValue("DXP_CODCTP"), "2", aTiposAct, oMdFieldsDXP:GetValue("DXP_CODIGO"))
						lRetorno := .F.
					EndIf
				EndIf

				If lRetorno
					//Elimina os registros dos fardos selecionados na N87 (Regra BCI) que não estão mais no contrato
					OGC080EXFR( {__aFardos,  __aFardosBkp } )
				EndIf
			EndIf 	//--- IF 01
		EndIf  //-- fiM __lnewNeg

		If oModel:GetOperation() == MODEL_OPERATION_DELETE //avaliar
			If oMdFieldsDXP:GetValue('DXP_STATUS') == '2'
				Help('', 1, "AGRA720DEL")	//"Não será possivel excluir reserva com status take-up efetuado."
				lRetorno := .f.
			EndIf
		EndIf
	EndIf   //-- AGRColPos
Return( lRetorno )


/** {Protheus.doc} AGRA720APT
Função chamada no OGC020 para aprovar Take up

@param:     Nil
@author:    Marcelo Wesan
@since:     24/03/2017
@Uso:       
*/
Function AGRA720APT(oModel, lEstorno)
	Local oMdFieldsDXP := oModel:GetModel( "DXPMASTER" )
	Local oMdGridDXQ   := oModel:GetModel("DXQDETAIL")
	Local oMdCalc      := oModel:GetModel( 'AGRA720CALC')
	Local oModelN7I    := oModel:GetModel("N7IMASTER") // Obtem o submodelo da Grid N7I para gravação do histórico
	Local cSafra       := oMdFieldsDXP:GetValue("DXP_SAFRA") //FwFldGet( "DXP_SAFRA" ) //CODIGO DA SAFRA
	Local cCodRes	   := oMdFieldsDXP:GetValue("DXP_CODIGO") //FwFldGet( "DXP_CODIGO" ) //CODIGO DA RESERVA
	Local cCodCtr      := oMdFieldsDXP:GetValue("DXP_CODCTP") //FwFldGet( "DXP_CODCTP" )//CODIGO DA CONTRATO
	Local cCodCad      := oMdFieldsDXP:GetValue("DXP_ITECAD") //FwFldGet( "DXP_ITECAD" )//CODIGO DA CADENCIA
	Local nQtd         := oMdCalc:GetValue("TOTLIQU") //TOTAL LIQUIDO
	Local cFilFardo    := ""
	Local lContinua    := .F.
	Local nItA         := 1
	Local nItB         := 1
	Local nItC         := 1
	Local aBlocos      := {}
	Local lRetorno     := .F.
	Local aTiposAct    := {}
	Local aMsgHist	   := {}
	Local aFardTkp		:= {}
	Local aFardEmbar	:= {}
	Local cFilOrg		:= ""
	Local cItemDXQ		:= ""
	Local nIt			:= ""
	Local lRet          := .T.
	Local lHelp1        := .F.
	Local lHelp2        := .F.
	Local lHelp3        := .F.
	Local lHelp4        := .F.

	Private _lAgra720E := .F.

	Default lEstorno   := .F.

	_CancHist := .F.

	BEGIN TRANSACTION

		If lEstorno // Se for estorno monta o array de fardos para remoção do contrato
			dbSelectArea("DXI")
			DXI->(dbSetOrder(5))

			For nIt := 1 To oMdGridDXQ:Length() // Percorre a grid DXQ para verificar se possui blocos reprovados

				cFilOrg := oMdGridDXQ:GetValue("DXQ_FILORG", nIt)
				cItemDXQ := oMdGridDXQ:GetValue("DXQ_ITEM", nIt)

				if DXI->(ColumnPos('DXI_STATUS')) > 0
					DXI->(dbGoTop())
					If DXI->(dbSeek(cFilOrg + cCodRes + cItemDXQ))
						While !DXI->(Eof()) .AND. cFilOrg == DXI->DXI_FILIAL .AND. cCodRes == DXI->DXI_CODRES .AND. cItemDXQ == DXI->DXI_ITERES
							aAdd(aFardEmbar, {DXI->DXI_FILIAL, DXI->DXI_SAFRA, DXI->DXI_ETIQ, "04", DXI->DXI_CODIGO, oMdFieldsDXP:GetValue("DXP_FILIAL")} ) // Fardos para validação de instrução de embarque
							aAdd(aFardTkp, {DXI->DXI_FILIAL, DXI->DXI_SAFRA, DXI->DXI_ETIQ, "02", cCodCtr, oMdFieldsDXP:GetValue("DXP_FILIAL")} )

							RecLock( "DXI", .F. )
							DXI->DXI_STATUS := '60'	//Take-Up Agendado
							DXI->(MsUnLock())

							DXI->(dbSkip())
						End
					EndIf
				endIf
			Next nIt

			DXI->(dbCloseArea())
		Else
			DXI->(dbSelectArea("DXI"))
			DXI->(dbSetOrder(5))

			For nIt := 1 To oMdGridDXQ:Length() // Percorre a grid DXQ para verificar se possui blocos reprovados

				cFilOrg := oMdGridDXQ:GetValue("DXQ_FILORG", nIt)
				cItemDXQ := oMdGridDXQ:GetValue("DXQ_ITEM", nIt)

				if DXI->(ColumnPos('DXI_STATUS')) > 0
					DXI->(dbGoTop())
					If DXI->(MsSeek(cFilOrg + cCodRes + cItemDXQ))
						While !DXI->(Eof()) .AND. cFilOrg == DXI->DXI_FILIAL .AND. cCodRes == DXI->DXI_CODRES .AND. cItemDXQ == DXI->DXI_ITERES

							RecLock( "DXI", .F. )
							DXI->DXI_STATUS := '70'	//Take-Up
							DXI->(MsUnLock())

							DXI->(dbSkip())
						End
					EndIf
				endIf
			Next nIt

			DXI->(dbCloseArea())
		EndIf

		if lEstorno
			nQtd = nQtd * -1
			_lAgra720E := .T.  //Identifica a operação de estorno
		else
			//validação de quantidade aceitavel
			For nItA := 1 To oMdGridDXQ:Length() // Percorre a grid DXQ para verificar se possui blocos reprovados
				If oMdGridDXQ:GetValue("DXQ_APROVA" , nItA) == '1' // linha aprovada
					aAdd(aTiposAct,{oMdGridDXQ:GetValue("DXQ_TIPO",nItA), oMdGridDXQ:GetValue("DXQ_PSLIQU",nItA) })
				Endif
			Next nItA

			if !AGRA720VTAC(cCodCtr, "2", aTiposAct, cCodRes)
				//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
				lRet := .F.
				DisarmTransaction()
				Break
			endif
		endif

		If !Empty(aFardEmbar) .AND. !OGC040VEMB(aFardEmbar, STR0102) // Valida se os fardos possuem instrução de embarque # "Estornar take-up"
			//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
			lRet := .F.
			Break
		EndIf

		aMsgHist := AGR720GRVH(oModel) //monta as mensagens de histórico

		If Empty(aMsgHist) .OR. .NOT. Empty(aMsgHist[1])  //Se o array de retorno de histórico não for vazio e te o valor do texto de histórico existir

			//BEGIN TRANSACTION

			If  IsInCallStack("OGC020")
				If (oMdFieldsDXP:GetValue("DXP_STATUS") == '2' .and. !lEstorno) .or. (oMdFieldsDXP:GetValue("DXP_STATUS") == '1' .and. lEstorno) // Validação se a reserva ja não esta efetuada, devido a atualização do browser
					//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
					lRet := .F.
					lHelp1 := .T.
					DisarmTransaction()
					Break
				EndIf
				If oMdGridDXQ:IsEmpty() // Validação para não deixar aprovar uma reserva sem blocos
					//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
					lRet := .F.
					lHelp2 := .T.
					DisarmTransaction()
					Break
				EndIf

				If lEstorno .AND. !AGRA720VEST(oModel , 'VINFIX')
					//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
					lRet := .F.
					lHelp3 := .T.
					DisarmTransaction()
					Break
				EndIf

				If lEstorno .AND. !AGRA720VEST(oModel, 'QAOUT')
					//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
					lRet := .F.
					lHelp4 := .T.
					DisarmTransaction()
					Break
				EndIf

				lContinua = AGRA720ATU(cCodCtr,cCodCad,cCodRes,cSafra, nQtd, oModel, lEstorno, aFardTkp)

				If  lContinua

					If !lEstorno

						oMdFieldsDXP:SetValue('DXP_STATUS', "2")
						// ###### Gravação do Histórico de Blocos Reprovados #####
						For nItA := 1 To oMdGridDXQ:Length() // Percorre a grid DXQ para verificar se possui blocos reprovados
							If oMdGridDXQ:GetValue("DXQ_APROVA" , nItA) == '2' // Se a Linha esta reprovada então faz a carga de dados
								aAdd(aBlocos, AGRA720FDS(oMdGridDXQ:GetValue("DXQ_SAFRA" , nItA), oMdGridDXQ:GetValue("DXQ_BLOCO" , nItA),;
									oMdGridDXQ:GetValue("DXQ_TIPO" , nItA), oMdGridDXQ:GetValue("DXQ_CODRES" , nItA), ;
									oMdGridDXQ:GetValue("DXQ_ITEM" , nItA), oMdGridDXQ:GetValue("DXQ_FILORG" , nItA), ;
									oMdFieldsDXP:GetValue("DXP_CLAINT"), oMdFieldsDXP:GetValue("DXP_CLAEXT"), ;
									oMdFieldsDXP:GetValue("DXP_DATA"), oMdGridDXQ:GetValue("DXQ_OBSERV" , nItA), oMdFieldsDXP:GetValue("DXP_CODCTP")))

								//remover o relacionamento
								cFilFardo := IIf(FwModeAccess("DXP",3) == "C",oMdGridDXQ:GetValue("DXQ_FILORG"),xFilial("DXI")) //verificação da filial correta para listagem

								//Limpa relacionamento entre a reserva e o fardo
								dbSelectArea( "DXI" )
								DXI->(dbSetOrder(5))
								DXI->(dbSeek(cFilFardo + cCodRes + oMdGridDXQ:GetValue("DXQ_ITEM", nItA)))
								While !Eof() .And. cFilFardo == DXI->DXI_FILIAL ;
										.And. cCodRes == DXI->DXI_CODRES ;
										.And. oMdGridDXQ:GetValue("DXQ_ITEM", nItA) == DXI->DXI_ITERES

									RecLock( "DXI", .F. )
									DXI->DXI_CODRES := ""
									DXI->DXI_ITERES := ""
									DXI->(MsUnLock())
									DXI->(dbGoTop())
									DXI->(dbSeek(cFilFardo+cCodRes + oMdGridDXQ:GetValue("DXQ_ITEM", nItA)))
								End
							EndIf
						Next nItA

						// Monta a Grid N7I com a carga de dados proveniente dos blocos reprovados
						For nItB := 1 To Len(aBlocos) // Percorre os blocos que foram reprovados
							For nItC := 1 to Len(aBlocos[nItB]) // Percorre e popula a grid com os blocos e seus respectivos fardos reprovados
								oModelN7I:SetValue("N7I_FARDO", aBlocos[nItB][nItC][1])
								oModelN7I:SetValue("N7I_CODRES", aBlocos[nItB][nItC][2])
								oModelN7I:SetValue("N7I_CODCTP", aBlocos[nItB][nItC][3])
								oModelN7I:SetValue("N7I_BLOCO", aBlocos[nItB][nItC][4])
								oModelN7I:SetValue("N7I_FILORG", aBlocos[nItB][nItC][5])
								oModelN7I:SetValue("N7I_CLAINT", aBlocos[nItB][nItC][6])
								oModelN7I:SetValue("N7I_CLAEXT", aBlocos[nItB][nItC][7])
								oModelN7I:SetValue("N7I_DATARE", aBlocos[nItB][nItC][8])
								oModelN7I:SetValue("N7I_MOTIVO", aBlocos[nItB][nItC][9])
								oModelN7I:AddLine() // Adiciona uma linha a grid e já posiciona na mesma
							Next nItC
						Next nItB
						If Len(aBlocos) > 0  // Verifica se o array não esta vazio para a deletar a ultima linha proveniente do loop
							oModelN7I:DeleteLine(.T.) // Deleta a ultima linha adicionada vazia por conta do loop
						EndIf
					Else
						oMdFieldsDXP:SetValue('DXP_STATUS', "1")

						For nItA := 1 To oModelN7I:Length() // Percorre a grid DXQ para verificar se possui blocos reprovados
							oModelN7I:GoLine(nItA)
							oModelN7I:DeleteLine()
						Next nItA
					EndIf
				EndIf
			EndIf

			If lContinua
				lRetorno := FWFormCommit(oModel, /*[bBefore]*/, /*[bAfter]*/, /*[bAfterSTTS]*/, /*dentro*/, , /*<bIntegEAI >*/)
				AGRGRAVAHIS(,,,,{"DXP",xFilial("DXP")+ALLTrim(cCodRes),aMsgHist[2],aMsgHist[1]})
			EndIf

			//Processa({|| OGX016(FwxFilial("NJR"), oMdFieldsDXP:GetValue('DXP_CODCTP')) }, STR0087) //precisamos recalcular, pq na função de regra fiscal ele só recalcula se não tem valor.

			//OGX055(FwxFilial("NJR"), oMdFieldsDXP:GetValue('DXP_CODCTP'), oMdFieldsDXP:GetValue('DXP_ITECAD'))	//Recalcula Valores da regra FISCAL

			//END TRANSACTION
		Else
			_CancHist := .T.
		EndIf

		If lEstorno .AND. !lContinua
			Help(" ",1,"OGC020ESTNOK")	//Não foi possivel estornar o Take up
		EndIf

		If .NOT. lContinua
			DisarmTransaction()
		EndIf

	END TRANSACTION

	//Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
	If !lRet
		If lEstorno
			Do Case
			Case lHelp1
				Help(" ",1,"OGC020ESTNOK")	//Não foi possivel estornar o Take up
			Case lHelp2
				Help(" ",1,"OGC020ESTNOK")	//Não foi possivel estornar o Take up
			Case lHelp3
				Help( " ", 1, "OGC020ESTVINFI")
			Case lHelp4
				Help( " ", 1, "OGC020ESTQAOUT")
			End Case
		EndIf
		Return .F.
	EndIf

Return lContinua


/*{Protheus.doc} AGRA720ATU
Atualiza informações de quantidade takep -up, quando aprovada ou não

@author 	marcelo.wesan
@since 		24/03/2017
@version 	1.0
@param 		cSafra		, character, Informação da rotina AGRA720	- SAFRA
@param 		cCodCtr		, character, Informação da rotina AGRA720	- CONTRATO
@param 		cCodRes	    , character, Informação da rotina AGRA720   - RESERVA
@param 		cQtd	    , character, Informação da rotina AGRA720   - QUANTIDADE
@return 	lRetorno	, logico   , Retorno verdadeiro .T. ou falso .F.
*/
Function AGRA720ATU(cCodCtr,cCodCad,cCodRes,cSafra, nQtd, oModel, lEstorno, aFardTkp)
	Local aCab			:= {}
	Local aItens		:= {}
	Local aLinha		:= {}
	Local aModelo		:= {}
	Local lRetorno 		:= .T.
	Local cChave 		:= cCodCtr + cCodCad
	Local nIndice 		:= 1
	Local nQTNNY    	:= 0
	Local nMax      	:= 0
	Local nQtdInt   	:= 0
	Local nTotal    	:= 0

	Default lEstorno := .F.
	Default aFardTkp := {}

	//**Informar o modelo para gravar via validaçoes MVC
	aAdd( aModelo, { 'OGA290'		, 'Rotina'  } )
	aAdd( aModelo, { 'NJRUNICO'	, 'Model Field'	} )
	aAdd( aModelo, { 'NNYUNICO'	, 'Model Grid'	} )

	dbSelectArea("NJR")
	dbSetOrder(1)
	If NJR->(DbSeek(XFilial("NJR") + cCodCtr  + cCodRes))//CONTRATO
		DbSelectArea("NNY")//Cadência
		DbSetOrder(1)
		If DbSeek( xFilial("NNY") + cCodCtr + cCodCad)
			While .Not. NNY->(Eof()) .AND. NNY->NNY_CODCTR == cCodCtr .AND. NNY->NNY_ITEM == cCodCad
				nQTNNY := NNY->NNY_TKPQTD
				nQtdInt:= NNY->NNY_QTDINT
				nTotal := nQTNNY + nQtd
				nMax := nQtdInt + nQtdInt * NJR->NJR_TOLENT / 100 //max

				aLinha := {}
				aAdd( aLinha, { 'NNY_TKPQTD'	,  nTotal })
				aAdd( aLinha, { 'NNY_ITEM'      , cCodCad })
				aAdd( aItens, aLinha )

				NNY->(dbSkip())
			EndDo
		EndIf
		If  nTotal <= nMax
			lRetorno := AGRA720MVC( ,'NNY' , aCab, aItens, cChave, nIndice, aModelo, oModel, lEstorno, aFardTkp )
		Else
			Help('', 1, "AGRA720LR") //"Limite  da reserva atingida.Verifique a quantidade reservada!! "
			lRetorno := .F.
		EndIf
	EndIf
Return (lRetorno)


/** {Protheus.doc} AGRA720MVC
Função grava MVC via modelo de dados

@param:     Nil
@author:    Marcelo Wesan
@since:     24/03/2017
@Uso:       
*/
Function AGRA720MVC( cMaster, cDetail, aCpoMaster, aCpoDetail, cChave, nIndice, aModelo, oModelRes, lEstorno, aFardTkp )
	Local aAreaOri	:= GetArea()
	Local oModel	:= Nil
	Local oAux		:= Nil
	Local oStruct	:= Nil
	Local aAux 		:= {}
	Local nItErro 	:= 0
	Local nI 		:= 0
	Local nJ 		:= 0
	Local nPos 		:= 0
	Local lAux 		:= .T.
	Local lRet 		:= .T.

	Default oModelRes := Nil
	Default lEstorno := .F.
	Default aFardTkp := {}

	//*Variaveis para utilização do modelo de dados
	cRotina := aModelo[1][1]	//Nome da Rotina
	cModelo	:= aModelo[2][1]	//Nome do modelo do field
	cGridMo := aModelo[3][1]	//Nome do modelo do grid

	If cRotina == "AGRA630"
		cUserBenf := ''
		//dbSelectArea( cMaster )
		//dbSetOrder( nIndice )
		//If DbSeek( xFilial( cMaster ) + cChave )
		//	cUserBenf := DXJ->DXJ_CODUNB
		//EndIf
	EndIf
	
	oModel := FWLoadModel( cRotina )
	// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
	oModel:SetOperation( 4 )
	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	//oModel:Activate()
	IF !oModel:Activate() // Verificando se o VldActivate Falhou
		cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
		Help( ,,STR0029,,cMsg, 1, 0 ) //"Atenção"
		Return (.f.)
	EndIF

	// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
	oAux := oModel:GetModel( cModelo )   // Modelo da NJJ Cab. Romaneio = NJJUNICO, dos Itens == NJMUnico
	// Obtemos a estrutura de dados do cabeçalho
	oStruct := oAux:GetStruct()
	aAux := oStruct:GetFields()
	If lRet .AND. .NOT. Empty(cMaster)
		dbSelectArea( cMaster )
		dbSetOrder( nIndice )
		If DbSeek( xFilial( cMaster ) + cChave )

			For nI := 1 To Len( aCpoMaster )
				// Verifica se os campos passados existem na estrutura do cabeçalho
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoMaster[nI][1] ) } ) ) > 0
					// È feita a atribuição do dado aos campo do Model do cabeçalho
					If !( lAux := oModel:SetValue( cModelo, aCpoMaster[nI][1],aCpoMaster[nI][2] ) )
						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						lRet := .F.
						Exit
					EndIf
				EndIf
			Next
		EndIf
	EndIf
	If lRet .AND. .NOT. Empty(cDetail)
		dbSelectArea( cDetail )
		dbSetOrder( nIndice )
		If DbSeek( xFilial( cDetail ) + cChave )
			// Instanciamos apenas a parte do modelo referente aos dados do item
			oAux := oModel:GetModel( cGridMo )
			// Obtemos a estrutura de dados do item
			oStruct := oAux:GetStruct()
			aAux := oStruct:GetFields()
			nItErro := 0
			For nI := 1 To Len( aCpoDetail )
				// Atribui a linha que quer alterar
				oAux:SeekLine({{aCpoDetail[1][2][1], aCpoDetail[1][2][2] }}) //seta a posição da linha a ser atualizada
				If .NOT. aCpoDetail[nI][1][1] = "NNY_ITEM"
					For nJ := 1 To Len( aCpoDetail[nI] )
						// Verifica se os campos passados existem na estrutura de item
						If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0
							If aCpoDetail[nI][nJ][1] != 'NNY_ITEM' .AND. .NOT. ( lAux := oModel:SetValue( cGridMo, aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )
								// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
								// o método SetValue retorna .F.
								lRet 	:= .F.
								nItErro := nI
								Exit
							EndIf
						EndIf
					Next
				EndIf
				If !lRet
					Exit
				EndIf
			Next
		EndIf
	EndIf

	If !lEstorno // Se não for estorno, então realiza a gravação das regras fiscais
		lRet := AGRA720N9A(oModelRes, oModel)
	ElseIf lEstorno .AND. !Empty(aFardTkp)
		lRet := AGRA720INAT(aFardTkp, .F., oModel)
	EndIf

	If lRet
		// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
		// neste momento os dados não são gravados, são somente validados.
		If lRet := oModel:VldData()
			// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
			lRet := oModel:CommitData() //erro variavel AGRVNKA não existe
			
		EndIf
	EndIf
	If !lRet
		// Se os dados não foram validados obtemos a descrição do erro para gerar
		// LOG ou mensagem de aviso
		aErro := oModel:GetErrorMessage()
		AutoGrLog( STR0091 	+ ': [' + AllToChar( aErro[1] ) + ']' )	//"Id do formulário de origem"
		AutoGrLog( STR0093 	+ ': [' + AllToChar( aErro[2] ) + ']' )	//"Id do campo de origem"
		AutoGrLog( STR0094 	+ ': [' + AllToChar( aErro[3] ) + ']' )	//"Id do formulário de erro"
		AutoGrLog( STR0095 	+ ': [' + AllToChar( aErro[4] ) + ']' )	//"Id do campo de erro"
		AutoGrLog( STR0096	+ ': [' + AllToChar( aErro[5] ) + ']' )	//"Id do erro"
		AutoGrLog( STR0097	+ ': [' + AllToChar( aErro[6] ) + ']' )	//"Mensagem do erro"
		AutoGrLog( STR0098	+ ': [' + AllToChar( aErro[7] ) + ']' )	//"Mensagem da solução"
		AutoGrLog( STR0099	+ ': [' + AllToChar( aErro[8] ) + ']' )  //"Valor atribuído"
		AutoGrLog( STR0100	+ ': [' + AllToChar( aErro[9] ) + ']' )	//"Valor anterior"
		If nItErro > 0
			AutoGrLog( STR0101	+ ': [' + AllTrim( AllToChar( nItErro ) ) + ']' )	//"Erro no Item"
		EndIf
		MostraErro()
	EndIf
	// Desativamos o Model
	oModel:DeActivate()
	RestArea(aAreaOri)
Return lRet

/*{Protheus.doc} AGRA720CON
Função de filtro da consulta NJRNNY (contratos x cadencias)

@author 	ana.olegini
@since 		29/03/2017
@version 	1.0
/*/
Function AGRA720CON()
	Local aFiltro   := {}
	Local cInfo 	:= ""
	Local cFiltro	:= ""
	Local cTemp 	:= GetNextAlias()
	Local cQuery   	:= ""
	Local nX		:= 0
   	Local oModel    := FwModelActive()
   	Local oModelDXP := oModel:GetModel('DXPMASTER')
    
    	//Query para montar o filtro para consulta.
   	cQuery := " SELECT * "
   	cQuery +=   " FROM "+ RetSqlName('NNY')+" NNY"
   	cQuery +=  " WHERE NNY.NNY_FILIAL = '"+xFilial("NNY")+"'"
	cQuery +=    " AND EXISTS (SELECT * FROM "+ retSqlName('NJR')+" NJR"
   	cQuery +=                        " WHERE NJR.D_E_L_E_T_ = ' ' "
   	cQuery +=                          " AND NJR.NJR_FILIAL = NNY.NNY_FILIAL "
   	cQuery +=                          " AND NJR.NJR_CODCTR = NNY.NNY_CODCTR "
   	cQuery +=                          " AND NJR.NJR_CODSAF = '"+oModelDXP:GetValue('DXP_SAFRA')+"'"
   	cQuery +=                          " AND NJR.NJR_TIPO   IN ('1','2') "    
   	cQuery +=                          " AND NJR.NJR_STATUS IN ('I','A') "
   	cQuery +=                          " AND NJR.NJR_TKPFIS <> '' "
   	cQuery +=                          " AND NJR.NJR_TIPALG <> '' )"
 	cQuery := ChangeQuery( cQuery )
	If select(cTemp) <> 0
		(cTemp)->(dbCloseArea())	
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTemp,.T.,.T.)   
	//*Alimenta o array para tratar o filtro.
	While .Not. (cTemp)->(Eof()) .AND. (cTemp)->NNY_FILIAL == xFilial("NNY")
		aAdd( aFiltro, { (cTemp)->NNY_CODCTR } )		
		(cTemp)->( dbSkip() )
	EndDo
    	(cTemp)->(dbCloseArea())
	
	//*Cria o Filtro com base na query acima	
	For nX := 1 TO Len(aFiltro)
		If nX <> Len(aFiltro)
    			cInfo += aFiltro[nx][1]+","           
		Else
    			cInfo += aFiltro[nx][1]
		EndIf
	Next nX
	//Filtro com todos os contratos referente a query.
	cFiltro := "@# NNY_CODCTR $ ' "+cInfo+" ' @#"
Return(cFiltro)


/*{Protheus.doc} AGRA720VAC
(Pós ativação da view, permite alterar o campo DXP_TIPACT para somente leitura)
@type function
@author roney.maia
@since 28/04/2017
@version 1.0
@param oView, objeto, (View Ativa)
@return ${lRet}, ${.T. - Valido, .F. - Inválido }
*/
Static Function AGRA720VAC(oView)
	Local lRet 		:= .T.
	Local oGetTipAct 	:= Nil

	If __lnewNeg .AND. oView:GetOperation() != MODEL_OPERATION_VIEW // se utiliza o novo modelo de comercialização e a operação é diferente de visualização
		oGetTipAct 	:= oView:GetViewObj("DXPMASTER")[3]:GetFwEditCtrl("DXP_TIPACT"):OCTRL // Resgata o objeto FwTGet referente ao campo DXP_TIPACT
		oGetTipAct:lReadOnly := .T. // habilita somente leitura
	EndIf
Return lRet


/*{Protheus.doc}
(Função de gatilho para o campo contrato devido ao novo modelo de comercialização)
@type function
@author roney.maia
@since 28/04/2017
@version 1.0
@param oModelDXP, objeto, (Submodelo DXPMASTER)
@param cCampo, character, (Nome do campo que acionou o gatilho)
@param xValue, variável, (Valor informado no campo acionado)
@return ${cValueFin}, ${Valor atribuido ao campo destino}
*/
Static Function AGRA720TRG(oModelDXP, cCampo, xValue)
	Local cValueFin	:= "" // Valor gatilhado ao campo destino
	Local cTempN7E 	:= GetNextAlias() // Alias temporario
	Local cQuery   	:= "" // Query para N7E - grid de tipos de algodão aceitáveis no contrato - NJR

	cQuery := " SELECT N7E_TIPACE"
	cQuery += " FROM "+ RetSqlName('N7E')+" N7E"
	cQuery += " WHERE N7E_FILIAL = '"+xFilial("N7E")+"'"
	cQuery += " AND N7E.D_E_L_E_T_ = '' "
	cQuery += " AND N7E_CODCTR = '"+xValue+"'"
	cQuery := ChangeQuery( cQuery )

	If select(cTempN7E) <> 0 // Se o alias se encontra aberta, fecha o alias
		(cTempN7E)->(dbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTempN7E,.T.,.T.)  // Executa a query

	While .Not. (cTempN7E)->(Eof())
		cValueFin += (cTempN7E)->N7E_TIPACE + " " + STR0051 + " " // #Ou
		(cTempN7E)->( dbSkip() )
	EndDo

	cValueFin := Iif(!Empty(cValueFin) , Substr(cValueFin, 1, Len(cValueFin) - (Len(STR0051) + 2)), "") // Remove o ultimo #Ou adicionado a string

	(cTempN7E)->(dbCloseArea()) // Fecha o alias
Return cValueFin

/*{Protheus.doc} /
(Consulta de fardos de cada bloco reprovado)
@type function
@author roney.maia
@since 17/05/2017
@version 1.0
@param cSafra, character, (Código da Safra)
@param cBloco, character, (Código do Bloco)
@param cClacom, character, (Classificação Comercial)
@param cCodRes, character, (Código da Reserva)
@param cIteRes, character, (Item da Reserva)
@param cFilOrg, character, (Código da Filial de Origem)
@param cClaInt, character, (Código do classificador Interno)
@param cClaExt, character, (Código do classificador Externo)
@param cDataRes, character, (Data da Reserva)
@param cMotivo, character, (Motivo da Reprovação)
@param cContrato, character, (Contrato de Venda da Reserva)
@return ${return}, ${Array de Fardos}
*/
Static Function AGRA720FDS(cSafra, cBloco, cClacom, cCodRes, cIteRes, cFilOrg, cClaInt, cClaExt, cDataRes, cMotivo, cContrato)
	Local aFardos := {}
	Local cQuery	:= ""
	Local cTemp	:= GetNextAlias()

	//Query para montar o filtro para consulta.
	cQuery := " SELECT DXI_CODIGO "
	cQuery += " FROM "+ RetSqlName('DXI')+" DXI"
	cQuery += " WHERE DXI.DXI_FILIAL = '"+xFilial("DXI")+"'"
	cQuery += " AND DXI.D_E_L_E_T_ = '' "
	cQuery += " AND DXI.DXI_SAFRA = '" + cSafra + "'"
	cQuery += " AND DXI.DXI_BLOCO = '" + cBloco + "'"
	cQuery += " AND DXI.DXI_CLACOM = '" + cClacom + "'"
	cQuery += " AND DXI.DXI_CODRES = '" + cCodRes + "'"
	cQuery += " AND DXI.DXI_ITERES = '" + cIteRes + "'"
	cQuery := ChangeQuery( cQuery )

	If select(cTemp) <> 0
		(cTemp)->(dbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTemp,.T.,.T.)
	//*Alimenta o array para tratar o filtro.
	While .Not. (cTemp)->(Eof())
		aAdd( aFardos, {(cTemp)->DXI_CODIGO, cCodRes, cContrato, cBloco, cFilOrg, cClaInt, cClaExt, Date(), cMotivo })
		(cTemp)->( dbSkip() )
	EndDo
	(cTemp)->(dbCloseArea())
Return aFardos


/*{Protheus.doc} GetFardos
Busca de Fardos e Blocos
@author jean.schulze
@since 19/05/2017
@version undefined
@param oView, object, descricao
@type function
*/
Function GetFardos(oView,lAuto)
	Local oModel
	Local oModelDXQ
	Local cCodCtr
	Local cSafra
	Local cCodRes
	Local cCad
	Local cTipRes
	Local cTipoEmb
	Local cEmbloca
	Local cTiposCtr := ""
	Local aFilHVI   := {}
	Local aFarSelec := {}
	Local aGrpBlc   := {}
	Local nCont     := 0
	Local npos      := 0
	Local aRecnos   := {}
	Local nPsLiqu   := 0
	Local nPsBrut   := 0
	Local nx        := 0
	Local cClacom   := ""
	Local lExtsUpd  := .f.
	Local cItemCont := 0
	Local lExtsOne  := .f.
	Local nQtdCad   := 0
	Local nTolen    := 0
	Local cAprova   := "1"
	Local aArea		:= GetArea()
	Local nQtdUsada
	Local aOptions  := {}
	Local cSeqItem  := "00"
	Local cFiltroN80 := ""

	Default lAuto := .F.

	IF !lAuto
		oModel    	:= oView:getModel()
		oModelDXQ 	:= oModel:getModel("DXQDETAIL")
	else
		oModel    	:= FWModelActive()
		oModelDXQ 	:= oModel:getModel("DXQDETAIL")
	EndIf
	cCodCtr 	:= FwFldGet( "DXP_CODCTP" )
	cSafra		:= FwFldGet( "DXP_SAFRA" )
	cCodRes   	:= FwFldGet( "DXP_CODIGO")
	cCad      	:= FwFldGet( "DXP_ITECAD")
	cTipRes   	:= FwFldGet( "DXP_TIPRES")
	cTipoEmb	:= FwFldGet( "DXP_TIPEMB")
	cCodRes		:= FwFldGet( "DXP_CODIGO")
	cEmbloca  	:= IIF(FwFldGet( "DXP_TIPEMB") = "3", FwFldGet( "DXP_CODREG"),"")
	nQtdUsada := AGRA720ALO(cCodRes, cCodCtr, cCad)

	if oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE //só executa quando é update ou insert

		If .Not. Empty(FwFldGet( "DXP_CODREG")) .And. FwFldGet( "DXP_TIPEMB") = "3"
			If Empty(FwFldGet( "DXP_SAFRA"))
				//"O campo de safra não foi informado. Informe o campo para realizar o emblocamento específico."
				AGRHELP("AGRA720SAFRA", STR0103, STR0104)
				Return .F.
			Else
				Processa({|| UBAA070(FwFldGet( "DXP_CODREG"), FwFldGet( "DXP_SAFRA")) }, STR0105) //"Abrindo rotina de emblocamento..."
			EndIf

		EndIf

		//só chama se o contrato foi preenchido
		if !empty(cCodCtr)

			dbSelectArea("NJR")
			dbSelectArea("NNY")
			//busca o tipo padrão
			cTiposCtr := Posicione("NJR",1,xFilial("NJR")+cCodCtr,"NJR_TIPALG")
			cTiposCtr := IIF(allTrim(cTiposCtr) == "-", "", cTiposCtr ) //problema de gravar com mascara
			nTolen    := Posicione("NJR",1,xFilial("NJR")+cCodCtr,"NJR_TOLENT")
			nQtdCad   := Posicione("NNY",1,xFilial("NNY")+cCodCtr+cCad,"NNY_QTDINT")

			if !empty(cTiposCtr) //para ter tipos aceitavéis tem que existir tipo padrão
				dbSelectArea( "N7E" )
				N7E->( dbSetOrder( 1 ) )
				N7E->( dbSeek( xFilial( "N7E" ) + cCodCtr ) )
				While !( Eof() ) .And. N7E->( N7E_FILIAL ) + N7E->( N7E_CODCTR ) == xFilial( "N7E" ) + cCodCtr
					cTiposCtr += " OU " + N7E->( N7E_TIPACE )
					N7E->( dbSkip() )
				EndDo
			endif

			//monta o array de hvi
			dbSelectArea( "N7H" )
			N7H->( dbSetOrder( 1 ) )
			N7H->( dbSeek( xFilial( "N7H" ) + cCodCtr ) )
			While !( Eof() ) .And. N7H->( N7H_FILIAL ) + N7H->( N7H_CODCTR ) == xFilial( "N7H" ) + cCodCtr
				aADD(aFilHVI,{N7H->( N7H_CAMPO ),N7H->( N7H_HVIDES ) ,N7H->( N7H_VLRINI ), N7H->( N7H_VLRFIM ) })
				N7H->( dbSkip() )
			EndDo

		elseif cTipRes == "1" //reserva de contrato
			//help de selecionar contrato AGRA720SCTR
			Help('',1,"AGRA720SCTR") //"Necessário informar um contrato para realizar a consulta"
			Return(.F.)
		endif

		//monta o array de hvi
		If cTipRes == "2" .AND. !Empty(cEmbloca) //Reserva Específica
			dbSelectArea( "N81" )
			N81->( dbSetOrder( 1 ) )
			N81->( dbSeek( FwxFilial( "N81" ) + cEmbloca + "3") )
			While !( Eof() ) .And. N81->N81_FILIAL == FwxFilial( "N81" ) .And. N81->N81_CODEMB == cEmbloca .And. N81->N81_TIPEMB = "3" .And. N81->N81_TIPREG = "1"
				aADD(aFilHVI,{N81->( N81_CAMPO ),N81->( N81_CODREG ) ,N81->( N81_VLDE ), N81->( N81_VLATE ) })
				cFiltroN80 := " DXD_CODREG = '"+ cEmbloca +"' AND DXD_TIPEMB = '3'"
				N81->( dbSkip() )
			EndDo
		EndIf

		__aFardosBkp := __aFardos

		//monta filtro da DXI
		cFiltroDXI := "DXI_SAFRA = '"+alltrim(cSafra)+"' AND (DXI_CODRES = '"+alltrim(cCodRes)+"' OR DXI_CODRES = '')"

		//monta as opções
		if !empty(cCodCtr)
			aAdd(aOptions, {'_cCodCtr', cCodCtr})
		endif

		aFarSelec := AGRX720(cFiltroDXI, cTiposCtr, @aFilHVI, /* Filtro N9D*/ , aOptions ,__aFardos, /*fardos excluídos*/ , nQtdCad, nTolen, nQtdUsada, cFiltroN80, cCodCtr, IIF( IsBlind() , .T. , .F. )) //consulta especifica de fardos

		FWModelActive(oModel, .t.) //tratamento para selecionar o model atual

		if aFarSelec[1] //foi clicado em ok

			//ativar o update do model
			oModelDXQ:SetNoInsertLine(.F.)
			oModelDXQ:SetNoDeleteLine(.F.)

			//monta a agrupação de bloco X fardo
			For nCont := 1  to Len(aFarSelec[2]) //listagem de dados
				nPos = AScan(aGrpBlc, {|x| AllTrim(x[1]+x[2]) ==  AllTrim(aFarSelec[2][nCont][1]+aFarSelec[2][nCont][3] )} ) /*busca o bloco por filial + bloco*/

				if npos > 0 //já está no array principal
					aADD(aGrpBlc[npos][3],aFarSelec[2][nCont][1]+aFarSelec[2][nCont][4]+aFarSelec[2][nCont][5])
				else
					aADD(aGrpBlc,{aFarSelec[2][nCont][1],aFarSelec[2][nCont][3] ,{aFarSelec[2][nCont][1]+aFarSelec[2][nCont][4]+aFarSelec[2][nCont][5] }}) //array(filial+bloco, array(filial+fardo))
				endif
			Next nCont

		    /*Deleta td, e verifica se tem algum para reativa*/
			For nX := 1 to oModelDXQ:Length()
				oModelDXQ:GoLine( nX )
				oModelDXQ:DeleteLine() //atualiza valores dos calculos também
				oModelDXQ:LoadValue("DXQ_FILORG", "")
				oModelDXQ:LoadValue("DXQ_BLOCO",  "")
				oModelDXQ:LoadValue("DXQ_SAFRA" , "")
				oModelDXQ:LoadValue("DXQ_SLDISP", 0)
				oModelDXQ:LoadValue("DXQ_QUANT" , 0)
				oModelDXQ:LoadValue("DXQ_PSBRUT", 0)
				oModelDXQ:LoadValue("DXQ_PSLIQU", 0)
			nExt nX

			if INCLUI // no update nao podemos usar os métodos abaixo
				oModelDXQ:cleardata() // Limpa o Grid
				oModelDXQ:InitLine() // reset
			endif

			//reset all
			__aFardos := {} //reset
			__aLivres := {} //reset
			nCont     := 1 //counter
			lExtsOne  := .f. //verifica se existe a linha 1

			if Len(aGrpBlc) > 0 //temos seleção

				while nCont <= Len(aGrpBlc) //while para evitar problemas com o for

					//reset de dados
					nPsLiqu   := 0
					nPsBrut   := 0
					aRecnos   := {}
					cClacom   := ""
					lExtsUpd  := .f. //somente para update

					if !INCLUI

						if oModelDXQ:Length() > 0

							//verifica se tem a linha 1
							if !lExtsOne //só será chamada na primeira passagem do while
								For nX := 1 to oModelDXQ:Length()
									oModelDXQ:GoLine( nX )
									if val(oModelDXQ:GetValue( "DXQ_ITEM")) == 1
										lExtsOne := .t.
										EXIT
									endif
								nExt nX

								if !lExtsOne //não existe ainda
									oModelDXQ:AddLine()
									oModelDXQ:LoadValue( "DXQ_ITEM",   "01")
									lExtsUpd := .t.
								endif
							endif

							//restaura as linhas antigas
							if !lExtsUpd
								For nX := 1 to oModelDXQ:Length()
									oModelDXQ:GoLine( nX )
									if oModelDXQ:isDeleted()
										oModelDXQ:UnDeleteLine()
										lExtsUpd := .t.
										EXIT
									endif
								nExt nX
							endif

						endif

						if !lExtsUpd

							oModelDXQ:GoLine(oModelDXQ:Length()) //ultima linha do grid
							cItemCont := Soma1(oModelDXQ:GetValue("DXQ_ITEM"))

							nX := oModelDXQ:Length() + 1

							IF nX > 1
								oModelDXQ:AddLine()
							EndIF

							oModelDXQ:GoLine(nX)
							oModelDXQ:LoadValue( "DXQ_ITEM", cItemCont)
						endif
					else
						IF nCont > 1
							oModelDXQ:AddLine()
						EndIF
						cSeqItem := SOMA1(cSeqItem)
						oModelDXQ:GoLine(nCont)
						oModelDXQ:LoadValue( "DXQ_ITEM",  cSeqItem)
					endif

					oModelDXQ:LoadValue( "DXQ_FILORG", aGrpBlc[nCont][1])
					oModelDXQ:LoadValue( "DXQ_BLOCO",  aGrpBlc[nCont][2])

					//insere os dados de tipo
					dbSelectArea("DXD")
					dbSetOrder(1)
					If dbSeek( aGrpBlc[nCont][1] + cSafra + aGrpBlc[nCont][2] )
						cClacom :=  DXD->DXD_CLACOM
						oModelDXQ:LoadValue("DXQ_TIPO"  , cClacom	)
					Endif

					//-----------------------------------------
					// Atualiza o array de fardos se vinculados
					//-----------------------------------------
					For nX := 1 To Len(aGrpBlc[nCont][3])
						dbSelectArea( "DXI" )
						DXI->( dbSetOrder( 1 ) )
						if DXI->( dbSeek( aGrpBlc[nCont][3][nx] ) )
							aAdd( aRecnos, Recno())
							nPsLiqu += DXI->DXI_PSLIQU
							nPsBrut += DXI->DXI_PSBRUT
						endif
					Next nX

					aADD(__aFardos, { oModelDXQ:GetValue( "DXQ_ITEM"), aGrpBlc[nCont][2], aRecnos } )

					//-----------------------------------------
					// Atualiza o array de fardos se vinculados
					//----------------------------------------

					//-----------------------------------------
					// Atualiza item da reserva
					//-----------------------------------------
					oModelDXQ:SetValue("DXQ_SAFRA" , cSafra)
					oModelDXQ:SetValue("DXQ_SLDISP", QtdFarBlc( aGrpBlc[nCont][1],  aGrpBlc[nCont][2], cSafra, cClacom, cCodRes ))
					oModelDXQ:SetValue("DXQ_QUANT" , Len( aRecnos ))
					oModelDXQ:SetValue("DXQ_PSBRUT", nPsBrut)
					oModelDXQ:SetValue("DXQ_PSLIQU", nPsLiqu)
					oModelDXQ:SetValue("DXQ_APROVA", cAprova)
					nCont++
				enddo
			endif

			//devolve a propriedade original
			oModelDXQ:SetNoInsertLine(.T.)
			oModelDXQ:SetNoDeleteLine(.T.)
		endif

	endif
	NJR->(dbCloseArea())
	NNY->(dbCloseArea())
	RestArea(aArea)
Return(.T.)


/*{Protheus.doc} QtdFarBlc
Retorna a quantidade de fardos x blocos selecionados
@author jean.schulze
@since 30/05/2017
@version undefined
@param cFilBlc, characters, descricao
@param cBloco, characters, descricao
@param cSafra, characters, descricao
@param cClacom, characters, descricao
@param cCodRes, characters, descricao
@type function
*/
function QtdFarBlc(cFilBlc, cBloco, cSafra, cClacom, cCodRes )
	Local aQtdBlcFar := 0
	Local cQuery	 := ""
	Local cTemp	     := GetNextAlias()

	//Query para montar o filtro para consulta.
	cQuery := " SELECT COUNT(*) as Count "
	cQuery += " FROM "+ RetSqlName('DXI')+" DXI"
	cQuery += " WHERE DXI.DXI_FILIAL = '"+cFilBlc+"'"
	cQuery += " AND DXI.DXI_SAFRA = '" + cSafra + "'"
	cQuery += " AND DXI.D_E_L_E_T_ = '' "
	cQuery += " AND DXI.DXI_BLOCO = '" + cBloco + "'"
	cQuery += " AND DXI.DXI_CLACOM = '" + cClacom + "'"
	cQuery += " AND (DXI.DXI_CODRES = '' OR DXI.DXI_CODRES = '" + cCodRes + "')"

	cQuery := ChangeQuery( cQuery )

	If select(cTemp) <> 0
		(cTemp)->(dbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTemp,.T.,.T.)

	if ! (cTemp)->(Eof())
		aQtdBlcFar := (cTemp)->Count
		(cTemp)->( dbSkip() )
	Endif

	(cTemp)->(dbCloseArea())

return aQtdBlcFar


/** {Protheus.doc} AGRA720HIS
Apresenta em tela de Historico do contrato

@param:     Nil
@author:    Marcelo Wesan
@since:     29/06/2017
@Uso:       AGRA720HIS
*/
Function AGRA720HIS()
	Local cChaveI := "DXP->("+Alltrim(AGRSEEKDIC("SIX","DXP1",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))

	AGRHISTTABE("DXP",cChaveA)
Return

/*{Protheus.doc} AGRA720VTAC
Valida a quantidade limite de tipos aceitaveis do contrato 
@author jean.schulze
@since 03/07/2017
@version undefined
@param cCodCtr, characters, descricao
@param cTkpSts, characters, descricao
@param lTipoNew, logical, descricao
@type function
*/
Static function AGRA720VTAC(cCodCtr, cTkpSts, lTipoNew, cCodRes)
	Local aTpAceit   := {}
	Local dQdtAce    := 0
	Local nPos       := 0
	Local nX         := 0
	Local cAliasDXP  := GetNextAlias()
	Local dQtdTotTKP := 0
	Local dTotTpPdr  := 0  //valor total do tipo padrão

	Default cTkpSts := "1" //1 Valida Todas as Reservas, 2 - Valida somente a reserva em aprovação.
	Default lTipoNew := {}

	//busca dados do contrato
	DbselectArea( "NJR")
	NJR->(DbGoTop())
	NJR->(DbsetOrder(1))
	if NJR->(Dbseek(xFilial("NJR")+cCodCtr))

		// compor os limites conforme cada tipo aceitavel
		// adicionar o extra por tipo + % tolerancia
		DbselectArea( "N7E")
		N7E->(DbGoTop())
		N7E->(DbsetOrder(1))
		N7E->(Dbseek(xFilial("N7E")+cCodCtr))

		While !Eof() .And. xFilial("N7E") == NJR->NJR_FILIAL .AND. N7E->N7E_CODCTR == NJR->NJR_CODCTR
			dQdtAce  := 0 //reset

			dQdtAce  := (NJR->NJR_QTDCTR * N7E->N7E_PERCEN / 100)  //quantidade permitida conforme a quantidade consolidada do contrato
			dQdtAce  := dQdtAce + (dQdtAce * NJR->NJR_TOLENT / 100) //soma a tolerancia

			aAdd(aTpAceit, {N7E->N7E_TIPACE,dQdtAce,0}) //coloca o tipo + quantidade limite + qtd usada

			N7E->( dbSkip() )
		enddo

		//totalizar os limites conforme cada tipo
		//reservas com take-up efetuado.
		BeginSql Alias cAliasDXP
			Select
			DXQ.DXQ_TIPO, SUM(DXQ.DXQ_PSLIQU) PSLIQUI
			From  %table:DXP% DXP 
			INNER JOIN %Table:DXQ% DXQ ON DXQ.DXQ_FILIAL = DXP.DXP_FILIAL
									  AND DXQ.DXQ_CODRES = DXP.DXP_CODIGO 
		                              AND DXQ.%notDel%		                            
			Where DXP.DXP_FILIAL = %exp:xFilial("DXP")% And
				  DXP.DXP_CODCTP = %exp:NJR->NJR_CODCTR% And
				  DXP.DXP_STATUS = "2" And
				  DXQ.DXQ_APROVA = "1" And		
			      DXP.%NotDel%
			GROUP BY DXP.DXP_CODIGO,
			         DXQ.DXQ_TIPO
		EndSql

		(cAliasDXP)->( dbGotop() )
		While (cAliasDXP)->( !Eof() )
			nPos := aScan(aTpAceit, { |x| x[1] == (cAliasDXP)->(DXQ_TIPO)} )
			if nPos > 0
				aTpAceit[nPos][3] += (cAliasDXP)->(PSLIQUI) //apropria os valores já tem take-up
			else
				dTotTpPdr += (cAliasDXP)->(PSLIQUI) //adiciona outros tipos
			endif
			(cAliasDXP)->( dbSkip() )
		EndDo
		(cAliasDXP)->( dbCloseArea() )

		//verifica se é para todas as reservas abertas, ou somente a atual
		if cTkpSts == "1" //verifica todos que estão reservado tbm
			cAliasDXP := GetNextAlias() //pega nova area livre

			BeginSql Alias cAliasDXP
				Select
				DXQ.DXQ_TIPO, SUM(DXQ.DXQ_PSLIQU) PSLIQUI
				From  %table:DXP% DXP 
				INNER JOIN %Table:DXQ% DXQ ON DXQ.DXQ_FILIAL = DXP.DXP_FILIAL
									      AND DXQ.DXQ_CODRES = DXP.DXP_CODIGO 
		                                  AND DXQ.%notDel%			                            
				Where DXP.DXP_FILIAL = %exp:xFilial("DXP")% And
				      DXP.DXP_CODIGO <> %exp:cCodRes% And
					  DXP.DXP_CODCTP = %exp:NJR->NJR_CODCTR% And
					  DXP.DXP_STATUS = "1"	And		
					  DXQ.DXQ_APROVA = "1"  And		  
				      DXP.%NotDel%
				GROUP BY DXP.DXP_CODIGO,
				         DXQ.DXQ_TIPO
			EndSql

			(cAliasDXP)->( dbGotop() )
			While (cAliasDXP)->( !Eof() )

				nPos := aScan(aTpAceit, { |x| x[1] == (cAliasDXP)->(DXQ_TIPO)} )
				if nPos > 0
					aTpAceit[nPos][3] += (cAliasDXP)->(PSLIQUI) //apropria os valores já tem take-up
				else
					dTotTpPdr += (cAliasDXP)->(PSLIQUI)
				endif

				(cAliasDXP)->( dbSkip() )
			EndDo
			(cAliasDXP)->( dbCloseArea() )
		endif

		//inclui tbm o tipo padrao :P
		//verifica o dado do registro atual
		For nX := 1 To Len(lTipoNew)
			nPos := aScan(aTpAceit, { |x| x[1] == lTipoNew[nX][1]} )
			if nPos > 0
				aTpAceit[nPos][3] += lTipoNew[nX][2] //apropria os valores já tem take-up
			elseif lTipoNew[nX][1] = NJR->NJR_TIPALG //é diferente do tipo padrão
				dTotTpPdr += lTipoNew[nX][2] //apropria o tipo padrao
			else
				if cTkpSts == "1"
					Msginfo(STR0065, STR0064) //help not working
					return(.t.) //retorna true pq o take-up continua
				else
					//o tipo escolhido não existe
					Help('',1,"AGRA720VTAC1")  //O bloco possui Tipo incompatível com o contrato.
					return(.f.)
				endif
			endif
		Next nX

		//verificar os valores informados
		For nX := 1 To Len(aTpAceit)
			if aTpAceit[nX][2] < aTpAceit[nX][3]
				//mostra o help conforme a necessidade
				if cTkpSts == "1"
					Msginfo(STR0059 + CRLF + STR0021 + ": " + aTpAceit[nX][1] + CRLF + STR0083 + ": " + cValToChar(aTpAceit[nX][3] - aTpAceit[nX][2]), STR0060 ) //help not working
					return(.t.) //retorna true pq o take-up continua
				else
					Help('',1, STR0060,, STR0059 + CRLF + STR0021 + ": " + aTpAceit[nX][1] + CRLF + STR0083 + ": " + cValToChar(aTpAceit[nX][3] - aTpAceit[nX][2]), 1, 0)
					return(.f.)
				endif
			endif

			dQtdTotTKP += aTpAceit[nX][3] //somando de todos os tipos
		Next nX

		//verifica a quantidade total - versao consolidada
		if (dQtdTotTKP + dTotTpPdr) > (NJR->NJR_QTDCTR + (NJR->NJR_QTDCTR * NJR->NJR_TOLENT/100))
			if cTkpSts == "1"
				Msginfo(STR0061 + CRLF + STR0083 + ": " + cValToChar((dQtdTotTKP + dTotTpPdr) - (NJR->NJR_QTDCTR + (NJR->NJR_QTDCTR * NJR->NJR_TOLENT/100))), STR0062 ) //help not working
				return(.t.) //retorna true pq o take-up continua
			else
				Help('',1, STR0062,, STR0061 + CRLF + STR0083 + ": " + cValToChar((dQtdTotTKP + dTotTpPdr) - (NJR->NJR_QTDCTR + (NJR->NJR_QTDCTR * NJR->NJR_TOLENT/100))), 1, 0)
				return(.f.)
			endif
		endif
	endif
return .T.

/*{Protheus.doc} AGRA720VEST
//Função de validação para vinculo de blocos.
@author roney.maia
@since 11/12/2017
@version 1.0
@return ${return}, ${.T. - Valido, .F. - Inválido}
@param oModel, object, Modelo de Dados
@param cTipo, characters, Tipo de validação
@type function
*/
Static Function AGRA720VEST(oModel, cTipo)

	Local aArea		:= GetArea()
	Local lRet 		:= .T.
	Local oModelDXP	:= oModel:GetModel('DXPMASTER')
	Local oModelDXQ	:= oModel:GetModel('DXQDETAIL')
	Local cQuery	:= ""
	Local cAliasQry	:= GetNextAlias()
	Local nIt		:= 0

	Do Case

	Case cTipo == 'VINFIX' // Validação se existe blocos vinculados a fixações
		If Select(cAliasQry) > 0
			(cAliasQry)->(dbCloseArea())
		EndIf

		cQuery := "SELECT N8D_BLOCO FROM "+ RetSqlName("N8D") + " N8D"
		cQuery += " INNER JOIN " + RetSqlName("NN8") + " NN8 ON"
		cQuery += " NN8.NN8_FILIAL = '" + FwXFilial('NN8') + "'"
		cQuery += " AND NN8.D_E_L_E_T_ = '' "
		cQuery += " AND NN8.NN8_CODCTR = N8D.N8D_CODCTR"
		cQuery += " AND NN8.NN8_ITEMFX = N8D.N8D_ITEMFX"
		cQuery += " WHERE N8D.N8D_FILIAL = '"+FwXFilial("N8D")+"'"
		cQuery += " AND N8D.D_E_L_E_T_ = '' "
		cQuery += " AND N8D.N8D_CODCTR = '" + oModelDXP:GetValue('DXP_CODCTP') + "'"
		cQuery += " AND (NN8.NN8_QTDFIX - NN8.NN8_QTDENT) > 0"

		If oModelDXQ:Length() > 0
			cQuery += " AND ("

			For nIt := 1 To oModelDXQ:Length()
				cQuery += "N8D.N8D_BLOCO = '" + oModelDXQ:GetValue('DXQ_BLOCO', nIt) + "'"
				cQuery += " OR "
			Next nIt
			cQuery := SubStr(cQuery, 1, len(cQuery) -4 )
			cQuery += ")"
		EndIf

		cQuery := ChangeQuery( cQuery )

		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

		If (cAliasQry)->(!EOF())
			lRet := .F.
		EndIf

	Case cTipo == 'QAOUT' // Validação se fardos bci vinculados
		If Select(cAliasQry) > 0
			(cAliasQry)->(dbCloseArea())
		EndIf

		cQuery := "SELECT N87_ETIQ FROM "+ RetSqlName("N87") + " N87"
		cQuery += " WHERE N87_FILIAL = '"+FwXFilial("N87")+"'"
		cQuery += " AND D_E_L_E_T_ = '' "
		cQuery += " AND N87_CODCTR = '" + oModelDXP:GetValue('DXP_CODCTP') + "'"
		cQuery += " AND N87_APLICA = '3'"
		cQuery += " AND N87_ETIQ <> ''"

		cQuery := ChangeQuery( cQuery )

		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

		If (cAliasQry)->(!EOF())
			lRet := .F.
		EndIf

	EndCase

	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)

Return lRet

Function AGRA720PRE(oModel)
	If  oModel:GetOperation() ==  MODEL_OPERATION_UPDATE
		cSafraCTR := FwFldGet('DXP_SAFRA')
	EndIf
Return .T.

/*{Protheus.doc} AGRA720ALO
Retorna a quantidade já alocada para a cadência do contrato(excluindo a atual) - Difere da quantidade imputada no NNY(somente que sofreu take-up efetuado)
@author jean.schulze
@since 23/02/2018
@version 1.0
@return ${return}, ${return_description}
@param cCodRes, characters, descricao
@param cCodCtr, characters, descricao
@param cCodCadenc, characters, descricao
@type function
*/
function AGRA720ALO(cCodRes, cCodCtr, cCodCadenc)
	Local nQtdAloc  := 0
	Local cAliasDXP := GetNextAlias()

	BeginSql Alias cAliasDXP
		Select SUM(DXQ.DXQ_PSLIQU) PSLIQUI
		From  %table:DXP% DXP 
		INNER JOIN %Table:DXQ% DXQ ON DXQ.DXQ_FILIAL = DXP.DXP_FILIAL
							      AND DXQ.DXQ_CODRES = DXP.DXP_CODIGO 
                                  AND DXQ.%notDel%			                            
		Where DXP.DXP_FILIAL = %exp:xFilial("DXP")% And
		      DXP.DXP_CODIGO <> %exp:cCodRes% And
			  DXP.DXP_CODCTP = %exp:cCodCtr% And
			  DXP.DXP_ITECAD = %exp:cCodCadenc%	And		
			  DXQ.DXQ_APROVA = "1"  And		  
		      DXP.%NotDel%
		GROUP BY DXP.DXP_CODCTP, DXP.DXP_ITECAD
	EndSql

	(cAliasDXP)->( dbGotop() )
	if (cAliasDXP)->( !Eof() )
		nQtdAloc := (cAliasDXP)->(PSLIQUI)
	endif

return nQtdAloc

/*{Protheus.doc} AGRA720N9A
//Função para gravar as quantidades específicas dos fardos por filial de origem
na tabela N9A (Regras Fiscais).
@author roney.maia
@since 23/02/2018
@version 1.0
@return ${return}, ${.T. - Válido, .F. - Inválido}
@param oModelDXP, object, Objeto modelo da Reserva
@type function
*/
Static Function AGRA720N9A(oModel, oModelC)

	Local aArea			:= GetArea()
	Local lRet 			:= .T.
	Local oModelDXP 	:= oModel:GetModel("DXPMASTER")
	Local oModelDXQ   	:= oModel:GetModel("DXQDETAIL")
	Local aFilFard		:= {}
	Local nIt			:= 0
	Local cFilOrg		:= ""
	Local cCodRes		:= ""
	Local cItemRes		:= ""
	Local cFilDXP		:= oModelDXP:GetValue("DXP_FILIAL")
	Local cCodCtr		:= oModelDXP:GetValue("DXP_CODCTP")
	Local cIteCad		:= oModelDXP:GetValue("DXP_ITECAD")
	Local oModelCtr		:= oModelC // Contrato de venda
	Local oModelNJR		:= Nil
	Local oModelNNY		:= Nil
	Local oModelN9A		:= Nil
	Local cFils			:= ""
	Local aFils			:= {}
	Local aAuxFil		:= {}
	Local cFilAux		:= ""
	Local nSomaFil 		:= 0
	Local aSomaFil		:= {} // Array contendo as filiais e a soma de fardos das mesmas
	Local aFilFim		:= {}
	Local nQtdDisp		:= 0
	Local aLinFil		:= {}
	Local nX			:= 0
	Local nFil			:= 0
	Local nPosX			:= 0
	Local nPosY			:= 0
	Local nPosW			:= 0
	Local nSaldoP		:= 0
	Local cSeqPri		:= ""
	Local lAtende		:= .F.
	Local aFardGrv		:= {}
	Local nLinLast		:= 0

	/* Array de campos que serão gravados
	  na tabela N9D (Movimentação de Fardos)
	{{"N9D_SAFRA", }, 
	 {"N9D_FARDO", },
	 {"N9D_TIPMOV", "02"},
	 {"N9D_PESINI",},
	 {"N9D_PESFIM",},
	 {"N9D_DATA",},
	 {"N9D_STATUS",},
	 {"N9D_CODCTR",},
	 {"N9D_ITEETG",}, 
	 {"N9D_CODRES",},
	 {"N9D_ITERES",},
	 {"N9D_ITEREF",},
	 {"N9D_FILORG",}}   */

	// ############## TRATAMENTO DO ARRAY DE FARDOS E SOMA DOS PESOS POR FILIAL ############
	dbSelectArea("DXI")
	DXI->(dbSetOrder(5))
	
	For nIt := 1 To oModelDXQ:Length() // Popula o array de fardos
		If "1" $ oModelDXQ:GetValue("DXQ_APROVA" , nIt) // Blocos Aprovados
	  		cFilOrg		:= oModelDXQ:GetValue("DXQ_FILORG", nIt)
	  		cCodRes		:= oModelDXQ:GetValue("DXQ_CODRES", nIt)
	  		cItemRes	:= oModelDXQ:GetValue("DXQ_ITEM", nIt)
	  		
	  		DXI->(dbGoTop())
			If DXI->(dbSeek(cFilOrg + cCodRes + cItemRes))
				While !DXI->(Eof()) .AND. cFilOrg == DXI->DXI_FILIAL .AND. cCodRes == DXI->DXI_CODRES .AND. cItemRes == DXI->DXI_ITERES
					aAdd(aFilFard, {/* 1 */ DXI->DXI_FILIAL, ;
									/* 2 */ DXI->DXI_ETIQ, ;
									/* 3 */ DXI->DXI_PSESTO, ;
									/* 4 */ DXI->DXI_SAFRA, ;
									/* 5 */ DXI->DXI_CODRES, ;
									/* 6 */ DXI->DXI_ITERES, ;
									/* 7 */ cFilDXP, ;
									/* 8 */ DXI->DXI_BLOCO, ;
									/* 9 */ DXI->DXI_CODIGO})
									
					If !(AllTrim(DXI->DXI_FILIAL) $ AllTrim(cFils))
						cFils += AllTrim(DXI->DXI_FILIAL) + ";"
						aAdd(aFils, AllTrim(DXI->DXI_FILIAL))
					EndIf
					DXI->(dbSkip())    
				End
			EndIf
		EndIf
	Next nIt
  	
  	aAuxFil := aClone(aFilFard) // Clona o array de filiais para uso posterior
  	
	For nIt := 1 To Len(aFils)
		While (nPos := aScan(aAuxFil, {|x| AllTrim(x[1]) $ aFils[nIt]})) > 0
	  		
	  		cFilAux := aAuxFil[nPos][1] // Filial de origem do fardo
	  		nSomaFil += aAuxFil[nPos][3] // Soma de fardos por filial
	  		
	  		aAdd(aFilFim, aClone(aAuxFil[nPos]))
	  		 
	  		aDel(aAuxFil, nPos)
			aSize(aAuxFil, Len(aAuxFil) - 1)
		EndDo
	  	
	  	aAdd(aSomaFil, {cFilAux, aClone(aFilFim), nSomaFil})
  	
	  	cFilAux := "" // Reset de variaveis auxiliares
	  	nSomaFil := 0 // Reset de variaveis auxiliares
	  	aFilFim := {} // Reset de variaveis auxiliares  	
	Next nIt
	
  	DXI->(dbCloseArea()) // Fecha o alias dos fardos
  	
  	// ############################ TRATAMENTO DO CONTRATO DE VENDA ##################################
  	
  	dbSelectArea("NJR") // Abre a NJR
  	NJR->(dbSetorder(1)) // Seta primeiro indice
  	NJR->(dbGoTop()) // Posiciona no topo
  	
	If NJR->(dbSeek(FwXFilial("NJR") + cCodCtr)) .AND. oModelCtr:IsActive() .AND. oModelCtr:GetOperation() == MODEL_OPERATION_UPDATE // Procura o contrato relacionado aos blocos da DXQ
  		
  		oModelNJR := oModelCtr:GetModel("NJRUNICO")
		oModelNNY := oModelCtr:GetModel("NNYUNICO")
		oModelN9A := oModelCtr:GetModel("N9AUNICO")
		
		
		If oModelNNY:SeekLine({ {"NNY_ITEM", cIteCad} }) // Posiciona na previsão referente a reserva

			If Empty(aLinFil) // ### >>> Se vazio, nenhuma filial disponivel foi encontrada devido a quebra de regra fiscal por take-up
				aAdd(aLinFil, {0, "", "last", .F.})
			EndIf
			
			For nFil := 1 To Len(aSomaFil)	// Array de filiais de origem
				
				// ######################### LOOP DE FARDOS DA FILIAL SELECIONADA ##################	
				While !Empty(aSomaFil[nFil][2])
				
					//###################### CONDIÇÃO PARA UMA FILIAL DE FARDOS QUE NÃO POSSUE REGRA FISCAL DECLARADA NO CONTRATO ###################
					If (nPosX := aScan(aLinFil, {|x| x[2] == aSomaFil[nFil][1] })) == 0
						
						cSeqPri := Soma1(oModelN9A:GetValue("N9A_SEQPRI", oModelN9A:Length()))
						
						nX := oModelN9A:AddLine() // Adiciona uma linha e posiciona na mesma

						oModelN9A:SetLine(nX) // reposiciono. 

						If Len(aLinFil) > 0 .AND. aLinFil[1][1] == 0 // ### >>> Avalia o array devido a quebra de regra fiscal por take-up, caso não existir uma regra fiscal sem take-up
							aLinFil[1][1] := nX
							aLinFil[1][2] := oModelN9A:GetValue("N9A_FILORG", nX)
						EndIf
						
						nLinLast := nX - 1
						
						oModelN9A:SetValue("N9A_SEQPRI", cSeqPri) // Incremento manual de Item
						oModelN9A:SetValue("N9A_TES", oModelNJR:GetValue('NJR_TESEST')) // Incremento manual de Item
						oModelN9A:SetValue("N9A_CODFIN", oModelNJR:GetValue('NJR_CODFIN')) // Incremento manual de Item

						oModelN9A:SetValue("N9A_FILORG", aSomaFil[nFil][1] )			

						nQtdDisp := 0
						nSaldoP := 0
												
						lAtende := .F. // Reset inicial de variavel.
						
						// Se não possue mais saldo, busca saldo disponível de outras Regras Fiscais debitando o mesmo
						For nIt := 1 To oModelN9A:Length()
							If nIt != nX // Redução de Quantidade somente de regras diferentes da principal posicionada
								nQtdDisp := oModelN9A:GetValue("N9A_QUANT", nIt) - oModelN9A:GetValue("N9A_QTDTKP", nIt)
								
								If (nSaldoP + nQtdDisp) >= aSomaFil[nFil][3]
									lAtende := .T.
								ElseIf nIt == nLinLast .AND. !lAtende // Se for a ultima linha e não tem saldo, entra na tolerância
									lAtende := .T.
									aSomaFil[nFil][3] := (nQtdDisp + nSaldoP) // Reduz a quantidade restante da ultima regra fiscal disponivel
								EndIf
								
								If nQtdDisp > 0 // Se há quantidade disponivel, remove saldo
									oModelN9A:GoLine(nIt)
									If lAtende // Se o saldo necessário ja atende então obtem somente o necessário
										oModelN9A:SetValue("N9A_QUANT", oModelN9A:GetValue("N9A_QUANT", nIt) - (aSomaFil[nFil][3] - nSaldoP))
										// Se não possue take-up  e não possue saldo, entçao deleta a linha
										If oModelN9A:GetValue("N9A_QUANT", nIt) <= 0 .AND. oModelN9A:GetValue("N9A_QTDTKP", nIt) <= 0
											oModelN9A:GoLine(nIt) // Posiciona na linha que deseja deletar
											oModelN9A:DeleteLine() // Deleta a linha
										EndIf
										
										oModelN9A:GoLine(nX) // Posiciona na linha pertencente
										oModelN9A:SetValue("N9A_QUANT", oModelN9A:GetValue("N9A_QUANT", nX) + (aSomaFil[nFil][3] -  nSaldoP))
									ElseIf (nQtdDisp + nSaldoP) >= aSomaFil[nFil][3] // Se possue saldo contando o saldo disponivel
										// Se o saldo antender mais que o suficiente, então somente reduz o necessario contanto o Saldo disponivel anteriormente
										oModelN9A:SetValue("N9A_QUANT", oModelN9A:GetValue("N9A_QUANT", nIt) - (aSomaFil[nFil][3] - nSaldoP))
										// Se não possue take-up  e não possue saldo, entçao deleta a linha
										If oModelN9A:GetValue("N9A_QUANT", nIt) <= 0 .AND. oModelN9A:GetValue("N9A_QTDTKP", nIt) <= 0
											oModelN9A:GoLine(nIt) // Posiciona na linha que deseja deletar
											oModelN9A:DeleteLine() // Deleta a linha
										EndIf
										
										oModelN9A:GoLine(nX) // Posiciona na linha pertencente
										oModelN9A:SetValue("N9A_QUANT", oModelN9A:GetValue("N9A_QUANT", nX) + (aSomaFil[nFil][3] - nSaldoP)) // Atribui o saldo reduzido
									Else
										oModelN9A:SetValue("N9A_QUANT", oModelN9A:GetValue("N9A_QUANT", nIt) - nQtdDisp)
										// Se não possue take-up  e não possue saldo, entçao deleta a linha
										If oModelN9A:GetValue("N9A_QUANT", nIt) <= 0 .AND. oModelN9A:GetValue("N9A_QTDTKP", nIt) <= 0
											oModelN9A:GoLine(nIt) // Posiciona na linha que deseja deletar
											oModelN9A:DeleteLine() // Deleta a linha
										EndIf
										
										oModelN9A:GoLine(nX) // Posiciona na linha pertencente
										oModelN9A:SetValue("N9A_QUANT", oModelN9A:GetValue("N9A_QUANT", nX) + nQtdDisp) // Atribui o saldo reduzido
										nSaldoP += nQtdDisp
									EndIf
								EndIf
								
								If lAtende // Se a quantidade ja antende, então faz atribuição
									oModelN9A:GoLine(nX) // Posiciona na linha pertencente
									//realiza a copia da linha da N9A base(nIt) para a nova(nX)
									If !CopyN9A(oModelN9A,nIt)
										oModelCtr:SetErrorMessage( , , , "", "", STR0088, STR0089, "", "")	//#"Falha ao gravar Regras Fiscais."#"Verificar o contrato informado."
										Return .F.
									EndIf
									If Empty(oModelN9A:GetValue("N9A_TAKEUP", nX)) // Atribuição de indetificador de take-up da regra fiscal
										oModelN9A:SetValue("N9A_TAKEUP", cCodRes)
									EndIf

									For nIt := 1 To Len(aSomaFil[nFil][2]) // Para cada fardo restante debita com o saldo disponivel
										oModelN9A:SetValue("N9A_QTDTKP", oModelN9A:GetValue("N9A_QTDTKP", nX) + aSomaFil[nFil][2][nIt][3])
										
										aAdd(aFardGrv , {{"N9D_FILIAL", aSomaFil[nFil][2][nIt][1]}, ;
														{"N9D_SAFRA", aSomaFil[nFil][2][nIt][4]}, ;
										 				{"N9D_FARDO", aSomaFil[nFil][2][nIt][2]}, ;
										 				{"N9D_TIPMOV", "02"}, ;
										 				{"N9D_PESINI", aSomaFil[nFil][2][nIt][3]}, ;
										 				{"N9D_PESFIM", aSomaFil[nFil][2][nIt][3]}, ;
										 				{"N9D_DATA", dDataBase}, ;
										 				{"N9D_STATUS", "2"} , ;
										 				{"N9D_CODCTR", cCodCtr}, ;
										 				{"N9D_ITEETG", cIteCad} , ;
										 				{"N9D_CODRES", aSomaFil[nFil][2][nIt][5]}, ;
										 				{"N9D_ITERES", aSomaFil[nFil][2][nIt][6]}, ;
										 				{"N9D_ITEREF", oModelN9A:GetValue("N9A_SEQPRI", nX)}, ;
										 				{"N9D_FILORG", aSomaFil[nFil][2][nIt][7]}, ;
														{"N9D_BLOCO", aSomaFil[nFil][2][nIt][8]}, ;
														{"N9D_CODFAR", aSomaFil[nFil][2][nIt][9]}})
										
										aSomaFil[nFil][2][nIt][3] := 0 // Remove o saldo total dos fardos	
									Next nIt
									
									// Como foi adição de linha por não haver filial, então adiciona a mesma na nova linha
									oModelN9A:SetValue("N9A_FILORG", aSomaFil[nFil][1]) 
									
									While (nPosW := aScan(aSomaFil[nFil][2], {|x| x[3] <= 0})) > 0 // Remove os fardos do array que estao com saldo 0
				  						aDel(aSomaFil[nFil][2], nPosW)
					  					aSize(aSomaFil[nFil][2], Len(aSomaFil[nFil][2]) - 1)
									EndDo
				  					
				  					Exit
								EndIf
							
							EndIf
						Next nIt
					//###################### CONDIÇÃO ELSE PARA UMA FILIAL DE FARDOS QUE POSSUE REGRA FISCAL DECLARADA NO CONTRATO ###################
					Else // Se existe a filial
						nX := aLinFil[nPosX][1] // Obtém a linha da Regra Fiscal
						oModelN9A:GoLine(nX)
						
						nQtdDisp := oModelN9A:GetValue("N9A_QUANT", nX) - oModelN9A:GetValue("N9A_QTDTKP", nX) // obtem a quantidade disponivel da regra fiscal
						
						// ######################### DEBITO DE SALDO DISPONIVEL POR FILIAL ENQUANTO ESTIVER QUANTIDADE DISPONIVEL ##################	
						If nQtdDisp > 0 .AND. !aLinFil[nPosX][4] // Se possuir saldo e não está totalmente debitado
							For nIt := 1 To Len(aSomaFil[nFil][2]) // Loop com os dados de cada fardo da filial, da filial selecionada
						 		nQtdDisp := oModelN9A:GetValue("N9A_QUANT", nX) - oModelN9A:GetValue("N9A_QTDTKP", nX) // obtem a quantidade disponivel da regra fiscal
						 		
								If nQtdDisp <= 0 // Se igual a zero então debitou o saldo
						 			Exit
								EndIf
						 		
								If aSomaFil[nFil][2][nIt][3] <= nQtdDisp  // Debita os fardos pelo peso completo
									If Empty(oModelN9A:GetValue("N9A_TAKEUP", nX)) // Atribuição de indetificador de take-up da regra fiscal
										oModelN9A:SetValue("N9A_TAKEUP", cCodRes)
									EndIf

									oModelN9A:SetValue("N9A_QTDTKP", oModelN9A:GetValue("N9A_QTDTKP", nX) + aSomaFil[nFil][2][nIt][3] )
			  						aSomaFil[nFil][3] -= aSomaFil[nFil][2][nIt][3] // Reduz da soma total dos fardos por filial
			  						
			  						aAdd(aFardGrv , {{"N9D_FILIAL", aSomaFil[nFil][2][nIt][1]}, ;
													{"N9D_SAFRA", aSomaFil[nFil][2][nIt][4]}, ;
										 			{"N9D_FARDO", aSomaFil[nFil][2][nIt][2]}, ;
										 			{"N9D_TIPMOV", "02"}, ;
										 			{"N9D_PESINI", aSomaFil[nFil][2][nIt][3]}, ;
										 			{"N9D_PESFIM", aSomaFil[nFil][2][nIt][3]}, ;
										 			{"N9D_DATA", dDataBase}, ;
										 			{"N9D_STATUS", "2"} , ;
										 			{"N9D_CODCTR", cCodCtr}, ;
										 			{"N9D_ITEETG", cIteCad} , ;
										 			{"N9D_CODRES", aSomaFil[nFil][2][nIt][5]}, ;
										 			{"N9D_ITERES", aSomaFil[nFil][2][nIt][6]}, ;
										 			{"N9D_ITEREF", oModelN9A:GetValue("N9A_SEQPRI", nX)}, ;
										 			{"N9D_FILORG", aSomaFil[nFil][2][nIt][7]}, ;
													{"N9D_BLOCO", aSomaFil[nFil][2][nIt][8]}, ;
													{"N9D_CODFAR", aSomaFil[nFil][2][nIt][9]}})
			  						
			  						aSomaFil[nFil][2][nIt][3] := 0 // Remove o saldo total dos fardos	
								EndIf
							Next nIt
		  					
							While (nPosW := aScan(aSomaFil[nFil][2], {|x| x[3] <= 0})) > 0 // Remove os fardos do array que estao com saldo 0
		  						aDel(aSomaFil[nFil][2], nPosW)
			  					aSize(aSomaFil[nFil][2], Len(aSomaFil[nFil][2]) - 1)
							EndDo
		  					
		  					aLinFil[nPosX][4] := .T.
		  					
		  				// ######################### TRATAMENTO PARA LINHAS DAS REGRAS FISCAIS COM MAIS DE UMA FILIAL ##################	
						ElseIf Empty(aLinFil[nPosX][3]) .AND. aLinFil[nPosX][4] // Se possue saldo e ainda possue fardos da mesma filial
							aLinFil[nPosX][2] := "" // Limpa filial para não utilizar e não implicar no aScan posterior
						
							If (nPosY := aScan(aLinFil, {|x| AllTrim(x[2]) == AllTrim(aSomaFil[nFil][1]) })) > 0 // Proxima Regra Fiscal
								nPosX := nPosY // Alterna para proxima linha com a mesma filial
							EndIf
							
						// ######################### TRATAMENTO PARA LINHAS DAS REGRAS FISCAIS COM MAIS DE UMA FILIAL OU NÃO ##################					
						ElseIf aLinFil[nPosX][3] == "last" // Se for a ultima ou filial unica e não possuir saldo, porem a fardos disponiveis
							
							nQtdDisp := 0
							nSaldoP := 0
													
							oModelN9A:GoLine(nX) // Posiciona na linha pertencente
							nQtdPrinc := oModelN9A:GetValue("N9A_QUANT", nX) - oModelN9A:GetValue("N9A_QTDTKP", nX)
							
							If nQtdPrinc >= aSomaFil[nFil][3]
								If Empty(oModelN9A:GetValue("N9A_TAKEUP", nX)) // Atribuição de indetificador de take-up da regra fiscal
									oModelN9A:SetValue("N9A_TAKEUP", cCodRes)
								EndIf

								For nIt := 1 To Len(aSomaFil[nFil][2]) // Para cada fardo restante debita com o saldo disponivel
									oModelN9A:SetValue("N9A_QTDTKP", oModelN9A:GetValue("N9A_QTDTKP", nX) + aSomaFil[nFil][2][nIt][3])
										
									aAdd(aFardGrv , {{"N9D_FILIAL", aSomaFil[nFil][2][nIt][1]}, ;
													{"N9D_SAFRA", aSomaFil[nFil][2][nIt][4]}, ;
										 			{"N9D_FARDO", aSomaFil[nFil][2][nIt][2]}, ;
										 			{"N9D_TIPMOV", "02"}, ;
										 			{"N9D_PESINI", aSomaFil[nFil][2][nIt][3]}, ;
										 			{"N9D_PESFIM", aSomaFil[nFil][2][nIt][3]}, ;
										 			{"N9D_DATA", dDataBase}, ;
										 			{"N9D_STATUS", "2"} , ;
										 			{"N9D_CODCTR", cCodCtr}, ;
										 			{"N9D_ITEETG", cIteCad} , ;
										 			{"N9D_CODRES", aSomaFil[nFil][2][nIt][5]}, ;
										 			{"N9D_ITERES", aSomaFil[nFil][2][nIt][6]}, ;
										 			{"N9D_ITEREF", oModelN9A:GetValue("N9A_SEQPRI", nX)}, ;
										 			{"N9D_FILORG", aSomaFil[nFil][2][nIt][7]}, ;
													{"N9D_BLOCO", aSomaFil[nFil][2][nIt][8]}, ;
													{"N9D_CODFAR", aSomaFil[nFil][2][nIt][9]}})
																
									aSomaFil[nFil][2][nIt][3] := 0 // Remove o saldo total dos fardos	
								Next nIt
								
								While (nPosW := aScan(aSomaFil[nFil][2], {|x| x[3] <= 0})) > 0 // Remove os fardos do array que estao com saldo 0
			  						aDel(aSomaFil[nFil][2], nPosW)
				  					aSize(aSomaFil[nFil][2], Len(aSomaFil[nFil][2]) - 1)
								EndDo
							Else
								
								lAtende := .F. // Reset inicial de variavel.
								
								If oModelN9A:Length() == nX .AND. nX != 1 // Verificação de tolerancia para pegar ultima linha caso nao tiver saldo disponivel
									nLinLast := nX - 1
								Else
									nLinLast := oModelN9A:Length()
								EndIf
								
								// Se não possue mais saldo, busca saldo disponível de outras Regras Fiscais debitando o mesmo
								For nIt := 1 To oModelN9A:Length()
									
									If nIt != nX // Redução de Quantidade somente de regras diferentes da principal posicionada
										nQtdDisp := oModelN9A:GetValue("N9A_QUANT", nIt) - oModelN9A:GetValue("N9A_QTDTKP", nIt)
										
										If (nQtdPrinc + nSaldoP + nQtdDisp) >= aSomaFil[nFil][3]
											lAtende := .T.
										ElseIf nIt == nLinLast .AND. !lAtende // Se for a ultima linha e não tem saldo, entra na tolerância
											lAtende := .T.
											aSomaFil[nFil][3] := (nQtdPrinc + nQtdDisp + nSaldoP) // Reduz a quantidade restante da ultima regra fiscal disponivel
										EndIf
										
										If nQtdDisp > 0 // Se há quantidade disponivel, remove saldo
											oModelN9A:GoLine(nIt)
											If lAtende // Se o saldo necessário ja atende então obtem somente o necessário
												oModelN9A:SetValue("N9A_QUANT", oModelN9A:GetValue("N9A_QUANT", nIt) - (aSomaFil[nFil][3] - (nQtdPrinc + nSaldoP)))
												// Se não possue take-up  e não possue saldo, entçao deleta a linha
												If oModelN9A:GetValue("N9A_QUANT", nIt) <= 0 .AND. oModelN9A:GetValue("N9A_QTDTKP", nIt) <= 0
													oModelN9A:GoLine(nIt) // Posiciona na linha que deseja deletar
													oModelN9A:DeleteLine() // Deleta a linha
												EndIf
												
												oModelN9A:GoLine(nX) // Posiciona na linha pertencente
												oModelN9A:SetValue("N9A_QUANT", oModelN9A:GetValue("N9A_QUANT", nX) + (aSomaFil[nFil][3] - (nQtdPrinc + nSaldoP)))
											ElseIf (nQtdDisp + nSaldoP) >= aSomaFil[nFil][3] // Se possue saldo contando o saldo disponivel
												// Se o saldo antender mais que o suficiente, então somente reduz o necessario contanto o Saldo disponivel anteriormente
												oModelN9A:SetValue("N9A_QUANT", oModelN9A:GetValue("N9A_QUANT", nIt) - (aSomaFil[nFil][3] - nSaldoP))
												// Se não possue take-up  e não possue saldo, entçao deleta a linha
												If oModelN9A:GetValue("N9A_QUANT", nIt) <= 0 .AND. oModelN9A:GetValue("N9A_QTDTKP", nIt) <= 0
													oModelN9A:GoLine(nIt) // Posiciona na linha que deseja deletar
													oModelN9A:DeleteLine() // Deleta a linha
												EndIf
												
												oModelN9A:GoLine(nX) // Posiciona na linha pertencente
												oModelN9A:SetValue("N9A_QUANT", oModelN9A:GetValue("N9A_QUANT", nX) + (aSomaFil[nFil][3] - nSaldoP)) // Atribui o saldo reduzido
											Else
												oModelN9A:SetValue("N9A_QUANT", oModelN9A:GetValue("N9A_QUANT", nIt) - nQtdDisp)
												// Se não possue take-up  e não possue saldo, entçao deleta a linha
												If oModelN9A:GetValue("N9A_QUANT", nIt) <= 0 .AND. oModelN9A:GetValue("N9A_QTDTKP", nIt) <= 0
													oModelN9A:GoLine(nIt) // Posiciona na linha que deseja deletar
													oModelN9A:DeleteLine() // Deleta a linha
												EndIf
												
												oModelN9A:GoLine(nX) // Posiciona na linha pertencente
												oModelN9A:SetValue("N9A_QUANT", oModelN9A:GetValue("N9A_QUANT", nX) + nQtdDisp) // Atribui o saldo reduzido
												nSaldoP += nQtdDisp
											EndIf
										EndIf
										
										If lAtende // Se a quantidade ja antende, então faz atribuição
											oModelN9A:GoLine(nX) // Posiciona na linha pertencente
											If Empty(oModelN9A:GetValue("N9A_TAKEUP", nX)) // Atribuição de indetificador de take-up da regra fiscal
												oModelN9A:SetValue("N9A_TAKEUP", cCodRes)
											EndIf

											For nIt := 1 To Len(aSomaFil[nFil][2]) // Para cada fardo restante debita com o saldo disponivel
												oModelN9A:SetValue("N9A_QTDTKP", oModelN9A:GetValue("N9A_QTDTKP", nX) + aSomaFil[nFil][2][nIt][3])
												
												aAdd(aFardGrv , {{"N9D_FILIAL", aSomaFil[nFil][2][nIt][1]}, ;
																{"N9D_SAFRA", aSomaFil[nFil][2][nIt][4]}, ;
												 				{"N9D_FARDO", aSomaFil[nFil][2][nIt][2]}, ;
												 				{"N9D_TIPMOV", "02"}, ;
												 				{"N9D_PESINI", aSomaFil[nFil][2][nIt][3]}, ;
												 				{"N9D_PESFIM", aSomaFil[nFil][2][nIt][3]}, ;
												 				{"N9D_DATA", dDataBase}, ;
												 				{"N9D_STATUS", "2"} , ;
												 				{"N9D_CODCTR", cCodCtr}, ;
												 				{"N9D_ITEETG", cIteCad} , ;
												 				{"N9D_CODRES", aSomaFil[nFil][2][nIt][5]}, ;
												 				{"N9D_ITERES", aSomaFil[nFil][2][nIt][6]}, ;
												 				{"N9D_ITEREF", oModelN9A:GetValue("N9A_SEQPRI", nX)}, ;
												 				{"N9D_FILORG", aSomaFil[nFil][2][nIt][7]}, ;
																{"N9D_BLOCO", aSomaFil[nFil][2][nIt][8]}, ;
																{"N9D_CODFAR", aSomaFil[nFil][2][nIt][9]}})
												
												aSomaFil[nFil][2][nIt][3] := 0 // Remove o saldo total dos fardos	
											Next nIt
											
											While (nPosW := aScan(aSomaFil[nFil][2], {|x| x[3] <= 0})) > 0 // Remove os fardos do array que estao com saldo 0
						  						aDel(aSomaFil[nFil][2], nPosW)
							  					aSize(aSomaFil[nFil][2], Len(aSomaFil[nFil][2]) - 1)
											EndDo
						  					
						  					Exit
										EndIf
									ElseIf oModelN9A:Length() == 1 // Se conter apenas uma linha, então considera tolerância, Pois não precisa debitar de outras regras fiscais
										
										oModelN9A:GoLine(nX) // Posiciona na linha pertencente
										If Empty(oModelN9A:GetValue("N9A_TAKEUP", nX)) // Atribuição de indetificador de take-up da regra fiscal
											oModelN9A:SetValue("N9A_TAKEUP", cCodRes)
										EndIf
										For nIt := 1 To Len(aSomaFil[nFil][2]) // Para cada fardo restante debita com o saldo disponivel
											oModelN9A:SetValue("N9A_QTDTKP", oModelN9A:GetValue("N9A_QTDTKP", nX) + aSomaFil[nFil][2][nIt][3])
											
											aAdd(aFardGrv , {{"N9D_FILIAL", aSomaFil[nFil][2][nIt][1]}, ;
															{"N9D_SAFRA", aSomaFil[nFil][2][nIt][4]}, ;
											 				{"N9D_FARDO", aSomaFil[nFil][2][nIt][2]}, ;
											 				{"N9D_TIPMOV", "02"}, ;
											 				{"N9D_PESINI", aSomaFil[nFil][2][nIt][3]}, ;
											 				{"N9D_PESFIM", aSomaFil[nFil][2][nIt][3]}, ;
											 				{"N9D_DATA", dDataBase}, ;
											 				{"N9D_STATUS", "2"} , ;
											 				{"N9D_CODCTR", cCodCtr}, ;
											 				{"N9D_ITEETG", cIteCad} , ;
											 				{"N9D_CODRES", aSomaFil[nFil][2][nIt][5]}, ;
											 				{"N9D_ITERES", aSomaFil[nFil][2][nIt][6]}, ;
											 				{"N9D_ITEREF", oModelN9A:GetValue("N9A_SEQPRI", nX)}, ;
											 				{"N9D_FILORG", aSomaFil[nFil][2][nIt][7]}, ;
															{"N9D_BLOCO", aSomaFil[nFil][2][nIt][8]}, ;
															{"N9D_CODFAR", aSomaFil[nFil][2][nIt][9]}})
											
											aSomaFil[nFil][2][nIt][3] := 0 // Remove o saldo total dos fardos	
										Next nIt
										
										While (nPosW := aScan(aSomaFil[nFil][2], {|x| x[3] <= 0})) > 0 // Remove os fardos do array que estao com saldo 0
					  						aDel(aSomaFil[nFil][2], nPosW)
						  					aSize(aSomaFil[nFil][2], Len(aSomaFil[nFil][2]) - 1)
										EndDo
					  					
					  					Exit
										
									EndIf
								Next nIt
							EndIf
						ElseIf nQtdDisp <= 0
							aLinFil[nPosX][2] := "" // Limpa a filial da linha pois a mesma ja atendeu a quantidade disponivel
						EndIf
					EndIf
				EndDo
			Next nFil
		EndIf
	Else
		lRet := .F.
		oModelCtr:SetErrorMessage( , , , "", "", STR0088, STR0089, "", "")	//#"Falha ao gravar Regras Fiscais."#"Verificar o contrato informado."
	EndIf
  	
	If lRet .AND. oModelCtr:VldData() // Se ocorreu tudo biene então grava os fardos na tabela de movimento de fardos
  		aRetGrv := AGRMOVFARD(aFardGrv, 1) // Passa os fardos para gravação
		If !Empty(aRetGrv[2])
  			oModelCtr:SetErrorMessage( , , , "", "", aRetGrv[2], STR0090, "", "") //#"Verificar os fardos informados para gravação na movimentação de fardos."
  			lRet := .F.
		EndIf
	EndIf
	
  	RestArea(aArea)

Return lRet

/*{Protheus.doc} AGRA720INAT
//Função de remoção dos fardos com take-up efetuado no contrato.
@author roney.maia
@since 05/03/2018
@version 1.0
@return ${return}, ${.T. - Válido, .F. - Inválido}
@param aFardos, array, Array de fardos selecionados para remoção de vinculo e debito
@type function
*/
Function AGRA720INAT(aFardos, lRPrevEnt, oModelC)

	Local aArea		:= GetArea()
	Local lRet 		:= .T.
	Local oModelCtr	:= Nil
	Local cAliasN9D	:= GetNextAlias()
	Local cQuery	:= ""
	Local nIt		:= 0
	Local aRemFard	:= {}
	Local oModelNNY	:= Nil
	Local oModelN9A	:= Nil
	Local cCtrNew	:= ""
	Local lNewCtr	:= .F.
	Local aErro		:= {}
	Local aFardosR	:= {}
	Local aRetMov	:= {}
	Local lActCtr	:= .F.

	Default lRPrevEnt 	:= .T.
	Default oModelC		:= Nil

	lActCtr := (!lRPrevEnt .AND. oModelC != Nil) // Variavel utilizada para usar um modelo de contrato já ativo

	cQuery += "SELECT * FROM " + RetSqlName("N9D") + " N9D"
	cQuery += " WHERE D_E_L_E_T_ = '' AND ("

	For nIt := 1 To Len(aFardos) // Busca os fardos unicos do contrato, com movimento 02 reserva, obtendo a previsão de entrega e a regra fiscal
		cQuery += "(N9D_FILIAL='" + aFardos[nIt][1] + ; //filial do fardo
		"' AND N9D_FILORG='" + aFardos[nIt][6] + ; // filial de mocimento do fardo
		"' AND N9D_SAFRA='" + aFardos[nIt][2] + ;
			"' AND N9D_FARDO='" + aFardos[nIt][3] + ;
			"' AND N9D_TIPMOV='" + aFardos[nIt][4] + ; // ("02" Reserva)
		"' AND N9D_CODCTR='" + aFardos[nIt][5] + ; // Contrato
		"' AND N9D_STATUS='2') OR" // Status Ativo

		// Array para desvinculo na tabela de movimento de fardos
		aAdd(aFardosR,  { /*aFilds*/{{"N9D_STATUS","3"}}, /*aChave*/{{aFardos[nIt][1]},; // Filial do fardo
		{aFardos[nIt][6]},; // Filial de movimento do fardo
		{aFardos[nIt][2]},; // Safra
		{aFardos[nIt][3]},; // Etiqueta do Fardo
		{aFardos[nIt][4]},; // Tipo de Movimentação ("02" - Reserva)
		{"2"},;	// Ativo
		{aFardos[nIt][5]}} }) // Código do Contrato

	Next nIt

	cQuery := SubStr(cQuery, 1, Len(cQuery) - 2)
	cQuery += ") ORDER BY N9D_CODCTR"

	cQuery := ChangeQuery( cQuery )

	If Select(cAliasN9D) > 0 // Se o alias estiver aberto, fecha o alias
		(cAliasN9D)->( dbCloseArea() )
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasN9D, .F., .T. ) // Executa a query

	dbSelectArea(cAliasN9D)
	(cAliasN9D)->(dbGoTop())

	While !(cAliasN9D)->(EOF())
		aAdd(aRemFard, {(cAliasN9D)->N9D_CODCTR, (cAliasN9D)->N9D_ITEETG, (cAliasN9D)->N9D_ITEREF, (cAliasN9D)->N9D_PESFIM, (cAliasN9D)->N9D_FILORG})
		(cAliasN9D)->(dbSkip())
	EndDo

	(cAliasN9D)->( dbCloseArea() )

	// ###################### REMOÇÃO DOS FARDOS DA PREVISÃO DE ENTREGA E DAS REGRAS FISCAIS
	
	If lActCtr // Se utiliza o contrato
		oModelCtr := oModelC
	Else
		oModelCtr := FwLoadModel("OGA290") // modelo da rotina Contrato de Venda
		oModelCtr:SetOperation(MODEL_OPERATION_UPDATE) // Alteração
	EndIf

	dbSelectArea("NJR") // Abre a NJR
	NJR->(dbSetorder(1)) // Seta primeiro indice
	NJR->(dbGoTop()) // Posiciona no topo

	oModelNNY := oModelCtr:GetModel("NNYUNICO")
	oModelN9A := oModelCtr:GetModel("N9AUNICO")

	oModelNNY:SetNoUpdateLine(.F.) // habilita atualização de campos

	For nIt := 1 To Len(aRemFard)

		If !lActCtr // Se for o padrão de remoção sem atualização do valor da prev de entrega

			If !(AllTrim(aRemFard[nIt][1]) $ cCtrNew)
				If oModelCtr:IsActive()
					oModelCtr:DeActivate()
				EndIf

				cCtrNew := AllTrim(aRemFard[nIt][1])
				lNewCtr	:= .T.
			Else
				lNewCtr	:= .F.
			EndIf

			// Posicionamento e ativação do modelo do contrato caso for um contrato diferente
			If lNewCtr  .AND. !oModelCtr:IsActive() // Verificação se caso for um novo contrato então realiza o dbseek.
				If NJR->(dbSeek(aRemFard[nIt][5] + aRemFard[nIt][1]))
					oModelCtr:Activate()
				Else
					If oModelCtr:IsActive()
						oModelCtr:DeActivate()
					EndIf
					oModelCtr:Destroy()
					RestArea(aArea)
					Return {.F., STR0091 + aRemFard[nIt][1]} // # "Contrato não localizado"
				EndIf
			EndIf
		EndIf
		// ################### REMOÇÃO DE FARDOS DA PREVISÃO E REGRAS FISCAIS ###################
		If oModelNNY:SeekLine({ {"NNY_ITEM", aRemFard[nIt][2]} }) // Posiciona na previsão referente a reserva
			If oModelN9A:SeekLine({ {"N9A_SEQPRI", aRemFard[nIt][3]} })
				If lRPrevEnt
					oModelNNY:SetValue("NNY_TKPQTD", oModelNNY:GetValue("NNY_TKPQTD") - aRemFard[nIt][4] ) // Reduz o fardo da previsão de entrega
				EndIf
				oModelN9A:SetValue("N9A_QTDTKP", oModelN9A:GetValue("N9A_QTDTKP") - aRemFard[nIt][4] ) // Reduz o fardo da regra fiscal
				//guardo a linha atual
				nLinBkp := oModelN9A:Getline()
				//procuro a linha sem reserva, que é a original.
				If oModelN9A:SeekLine({ {"N9A_TAKEUP", Space(TamSx3("N9A_TAKEUP")[1]) } }) .AND. (oModelN9A:length() > 1)
					//retorno a quantidade original
					oModelN9A:SetValue('N9A_QUANT', (oModelN9A:GetValue("N9A_QUANT") + aRemFard[nIt][4]) )
					//volto pra linha do takeup
					oModelN9A:GoLine(nLinBkp)
					//deleto a linha e o codigo da reserva.
					If oModelN9A:GetValue("N9A_QTDTKP") <= 0
						oModelN9A:ClearField("N9A_TAKEUP")
						oModelN9A:DeleteLine()
					EndIf

				Else //se não achar é porque só tem uma linha, então só apago o codigo da reserva porque os fardos já forma desvinculados.
					oModelN9A:ClearField("N9A_TAKEUP")
				EndIf

			EndIf
		EndIf

	Next nIt

	If lRet := oModelCtr:VldData() // Valida o modelo
		aRetMov := AGRMOVFARD(, 2, 2, , aFardosR) // Inativa os fardos removidos
		If !Empty(aRetMov[2])
			oModelCtr:SetErrorMessage( , , , "", "", aRetMov[2], STR0090, "", "") //#"Verificar os fardos informados para gravação na movimentação de fardos."
			lRet := .F.
		EndIf

		If lRet .AND. !lActCtr // Se o retorno foi bem sucedido e a carga do modelo do contrato foi realizado através dessa função
			lRet := oModelCtr:CommitData()  // Grava os dados
		EndIf
	EndIf

	If !lRet .AND. !lActCtr
		aErro := oModelCtr:GetErrorMessage()
		AutoGrLog( STR0091 	+ ': [' + AllToChar( aErro[1] ) + ']' )	//"Id do formulário de origem"
		AutoGrLog( STR0093 	+ ': [' + AllToChar( aErro[2] ) + ']' )	//"Id do campo de origem"
		AutoGrLog( STR0094 	+ ': [' + AllToChar( aErro[3] ) + ']' )	//"Id do formulário de erro"
		AutoGrLog( STR0095 	+ ': [' + AllToChar( aErro[4] ) + ']' )	//"Id do campo de erro"
		AutoGrLog( STR0096	+ ': [' + AllToChar( aErro[5] ) + ']' )	//"Id do erro"
		AutoGrLog( STR0097	+ ': [' + AllToChar( aErro[6] ) + ']' )	//"Mensagem do erro"
		AutoGrLog( STR0098	+ ': [' + AllToChar( aErro[7] ) + ']' )	//"Mensagem da solução"
		AutoGrLog( STR0099	+ ': [' + AllToChar( aErro[8] ) + ']' )  //"Valor atribuído"
		AutoGrLog( STR0100	+ ': [' + AllToChar( aErro[9] ) + ']' )	//"Valor anterior"
		MostraErro()
	EndIf

	If !lActCtr
		oModelCtr:DeActivate() // Desativa o modelo
		oModelCtr:Destroy() // Destroy o objeto modelo
	EndIf

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} UBAA130REG
@author carlos.augusto
@since 29/10/2018
@version 1.0
@return ${return}, ${return_description}
@param cTipEmb, characters, descricao
@type function
/*/
Function AGRA720REG(cCodigo, cTipEmb)
	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local oModel	:= FwModelActive()

	If .Not. Empty(cTipEmb) .And. cTipEmb == '2'
		lRet := .F.
	EndIf

	If lRet
		If .Not. Empty(cTipEmb)
			lRet := ExistCpo("N80",cCodigo + cTipEmb,1)
		Else

			DbSelectArea("N80")
			N80->(dbSetOrder(1))
			If N80->(dbSeek(FwxFilial("N80")+cCodigo+"3"+"1"))
				cTipEmb := N80->N80_TIPEMB
			ElseIf N80->(dbSeek(FwxFilial("N80")+cCodigo+"1"+"1"))
				cTipEmb := N80->N80_TIPEMB
			Else
				lRet := .F.
			EndIf
			N80->(dbCloseArea())
		EndIf
	EndIf
	If lRet
		If cTipEmb = "3" .And. oModel:GetValue("DXPMASTER", "DXP_TIPRES") != "2"
			lRet := .F.
			//"O Tipo de Reserva não permite selecionar a regra de emblocamento. Favor selecionar alterar o Tipo de Reserva."
			AGRHELP("AGRA720TIPORESERV",STR0106, STR0107)
		ElseIf cTipEmb = "1" .And. oModel:GetValue("DXPMASTER", "DXP_TIPRES") != "1"
			lRet := .F.
			AGRHELP("AGRA720TIPORESERV",STR0106, STR0107)
		EndIf
		If lRet
			oModel:SetValue("DXPMASTER", "DXP_TIPEMB",cTipEmb)
		EndIf

	EndIf
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} InativaReg
//Inativa a Regra
@author carlos.augusto
@since 30/10/2018
@version 1.0
@return ${return}, ${return_description}
@param cCodigo, characters, descricao
@type function
/*/
Static Function InativaReg(cCodigo, cRegra, oModel)
	Local aArea		:= GetArea()
	DbSelectArea("N80")
	N80->(dbSetOrder(1))
	If N80->(dbSeek(FwxFilial("N80") + cCodigo + "3"))
		RecLock( "N80", .F. )
		If oModel:GetOperation() == MODEL_OPERATION_DELETE
			N80->N80_ATIVO := "1"
		Else
			N80->N80_ATIVO := "2"
		EndIf
		N80->N80_RESERV := cRegra
		N80->(MsUnLock())
	EndIf
	RestArea(aArea)
Return


/*/{Protheus.doc} FechaBloco
//Fecha todos os blocos selecionados na reserva
@author carlos.augusto
@since 30/10/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, characters, descricao
@type function
/*/
Static Function FechaBloco(oModel)
	Local oMdGridDXQ	:= oModel:GetModel("DXQDETAIL")
	Local aArea			:= GetArea()
	Local aSaveLines 	:= FWSaveRows()
	Local cSafra 		:= oModel:GetValue("DXPMASTER", "DXP_SAFRA")
	Local cBloco		:= ""
	Local cTipo 		:= ""
	Local nX			:= 0

	//----------------------------------------
	// Carga dos fardos pertencentes a reserva
	//----------------------------------------
	For nX := 1 To oMdGridDXQ:Length()
		oMdGridDXQ:GoLine(nX)
		cBloco 	:= oMdGridDXQ:GetValue("DXQ_BLOCO")
		cTipo 	:= oMdGridDXQ:GetValue("DXQ_TIPO")

		//1=Vazio;2=Iniciado;3=Finalizado;4=Emblocado Fisicamente
		DbSelectArea("DXD")
		DXD->(dbSetOrder(1))
		If DXD->(dbSeek(FwxFilial("DXD") + cSafra + cBloco))
			RecLock( "DXD", .F. )
			DXD->DXD_STATUS := "3"
			DXD->(MsUnLock())
		EndIf
	Next nX

	RestArea( aArea )
	FWRestRows( aSaveLines )

Return

/*/{Protheus.doc} CopyN9A
//Copia registros da N9A que esta sendo consumido a quantidade para a nova linha N9A gerada pelo take-up
//copia campo que não são carregados automaticamente ao adicionar uma linha na N9A
//e alguns campos que são carregados automaticamente serão sobrescritos para manter dados do registro base
// valores e quantidades não serão copiados
@author claudineia.reinert
@since 05/05/2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, Objeto, Modelo da N9A ativo posicionado no novo registro da N9A que o take-up esta gerando
@param nBase, numerico, numero da linha da N9A que deve ser copiada como base
@type function
/*/
Static Function CopyN9A(oModelN9A, nBase)
	Local lRet := .F.
	Local oStruct := oModelN9A:GetStruct()
	Local aFldN9A := oStruct:GetFields()
	Local nI := 0
	Local cNoFld := 'N9A_SEQPRI|N9A_TAKEUP|N9A_FILORG|N9A_STAPRE' //campos para não copiar

	For nI := 1 To Len( aFldN9A )
		If !AllTrim( aFldN9A[nI][3]) $ cNoFld .and. (aFldN9A[nI][4] == "C" .or. aFldN9A[nI][4] == "D")
			If !oModelN9A:LoadValue(aFldN9A[nI][3], oModelN9A:GetValue(aFldN9A[nI][3], nBase))										
				lRet := .F.
				Exit
			EndIf
			lRet := .T.
		EndIf
	Next

Return lRet

