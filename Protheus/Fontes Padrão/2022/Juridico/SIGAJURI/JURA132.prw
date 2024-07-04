#INCLUDE "JURA132.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//----------------------------------------------------------------------------
/*/{Protheus.doc} JURA132
Escritorio Correspondente 
@author Clovis E. Teixeira dos Santos
@since 11/06/09
@version 1.0
/*/
//----------------------------------------------------------------------------
Function JURA132()
Local oBrowse
Private nValCon	:= 0
Private dReajuste := ctod("  /  /  ")

Pergunte("JURA132",.F.)
SetKey( VK_F12, { ||Pergunte("JURA132",.T.) } )

INCLUI := .F.
ALTERA := .F.
   
/*
ChkFile('SA2')
ChkFile('NSZ')
*/

DbSelectArea('SA2')
DbSelectArea('NSZ')
 
oBrowse := FWMBrowse():New()
oBrowse:SetAlias( "SA2" )
oBrowse:SetLocate()
oBrowse:SetFilterDefault("A2_MJURIDI == '1'")    
oBrowse:SetDescription( STR0007 )
oBrowse:SetCacheView( .F. )
oBrowse:Activate()
 
Return NIL
//----------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Clovis E. Teixeira dos Santos
@since 11/06/09
@version 1.0
/*/
//----------------------------------------------------------------------------
Static Function MenuDef()  
Local aRelats := {}
Local aRotina := {}

aAdd( aRelats, { STR0113, "J132Crys('1') ", 0, 8, 0, NIL } ) //"Especialidade"
aAdd( aRelats, { STR0114, "J132Crys('2') ", 0, 8, 0, NIL } ) //"Especialidade x Comarca"
aAdd( aRelats, { STR0115, "J132Crys('3') ", 0, 8, 0, NIL } ) //"Nome Advogado Correspondente"

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA132", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA132", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA132", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA132", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0116, aRelats          , 0, 0, 0, NIL } ) // "Relatórios"
aAdd( aRotina, { STR0128, "JA132Filtro()"  , 0, 0, 0, NIL } ) // "Filtro"    

If ExistBlock("PEJ132A")   ////// novo Flavio --- Incluir Botão -- Classifica correspondente - .
 	aRotina := ExecBlock("PEJ132A",.F.,.F.,{aRotina})
EndIf	

Return aRotina
//----------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Escritorio Correspondente

@author Clovis E. Teixeira dos Santos
@since 11/06/09
@version 1.0
/*/
//----------------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := FWLoadModel( "JURA132" )
Local cParam := AllTrim( SuperGetMv('MV_JDOCUME',,'1'))    
Local oCalc1
Local oStructSA2 := FWFormStruct( 2, "SA2" )
Local oStructAC8 := FWFormStruct( 2, "AC8" ) 
Local oStructNU3 := FWFormStruct( 2, "NU3" )
Local oStructNVI := FWFormStruct( 2, "NVI" )
Local oStructNU5 := FWFormStruct( 2, "NU5" )
Local oStructNU4 := FWFormStruct( 2, "NU4" )
Local oStructNU6 := FWFormStruct( 2, "NU6" )
Local nFlxCorres := SuperGetMV("MV_JFLXCOR", , 1)	//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"
Local oStructNZI := FWFormStruct( 2, "NZI" )
Local oStructNZC := FWFormStruct( 2, "NZC" )
Local oStructNZD := FWFormStruct( 2, "NZD" )

	//Caso a chamada tenha vindo do TOTVS Jurídico
	If (FwIsInCallStack("POST") .Or. FwIsInCallStack("PUT"))
			nFlxCorres := 2
	EndIf

	oStructAC8:RemoveField( "AC8_ENTIDA")
	oStructAC8:RemoveField( "AC8_CODENT")

	oStructNU3:RemoveField( "NU3_CCREDE")
	oStructNU3:RemoveField( "NU3_LOJA"  )
	oStructNVI:RemoveField( "NVI_CCREDE")
	oStructNVI:RemoveField( "NVI_CLOJA" )
	oStructNU5:RemoveField( "NU5_COD")
	oStructNU5:RemoveField( "NU5_CFORNE")
	oStructNU5:RemoveField( "NU5_LFORNE")
	oStructNU4:RemoveField( "NU4_CFORNE")
	oStructNU4:RemoveField( "NU4_LFORNE")
	oStructNU6:RemoveField( "NU6_CNOTA" )
	oStructNZI:RemoveField( "NZI_CCORRE")
	oStructNZI:RemoveField( "NZI_LCORRE")
	oStructNZC:RemoveField( "NZC_CCORRE")
	oStructNZC:RemoveField( "NZC_LCORRE")
	oStructNZD:RemoveField( "NZD_CCORRE")
	oStructNZD:RemoveField( "NZD_LCORRE")

	//Retira agrupamento da tabela SA2, para não depender do cadastro de agrupamento 
	oStructSA2:SetProperty( "*", MVC_VIEW_GROUP_NUMBER, "" )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription( STR0007 ) // "Escritorio Correspondente"

	oView:AddField("JURA132_VIEW"   , oStructSA2, "SA2MASTER" )	//Correspondente 
	oView:AddGrid( "JURA132_DETAIL" , oStructAC8, "AC8DETAIL" )	//Contato juridico 
	oView:AddGrid( "JURA132_GRIDNU3", oStructNU3, "NU3DETAIL" )	//Atuacao - comarca 
	oView:AddGrid( "JURA132_GRIDNVI", oStructNVI, "NVIDETAIL" )	//Atuacao - area juridica 

	If nFlxCorres == 1 //1 por followup  2 assunto juridico 
		oView:AddField("JURA132_FORMNZI", oStructNZI, "NZIDETAIL" ) 
		oView:AddGrid( "JURA132_GRIDNZC", oStructNZC, "NZCDETAIL" )	//Atos Correspondentes  
		oView:AddGrid( "JURA132_GRIDNZD", oStructNZD, "NZDDETAIL" )	//Negociações Especiais 
	Else
		oView:AddGrid( "JURA132_GRIDNU5", oStructNU5, "NU5DETAIL" )	//Grid de modelo de contrato 
		oView:AddGrid( "JURA132_GRIDNU4", oStructNU4, "NU4DETAIL" )	//Pagamento correspondente - pagamento da nota 
		oView:AddGrid( "JURA132_GRIDNU6", oStructNU6, "NU6DETAIL" )	//Pagamento correspondente - desdobramento da nota 
		oCalc1 := FWCalcStruct( oModel:GetModel( 'NU6TOTAL') )		
		oView:AddField( 'JURA132_GRIDNU62', oCalc1, 'NU6TOTAL' )	
	EndIf

	oView:CreateFolder("FOLDER_01")
	oView:AddSheet("FOLDER_01", "ABA_01_01", STR0019 ) //Informações Básicas
	oView:AddSheet("FOLDER_01", "ABA_01_02", STR0020 ) //Atuação

	If nFlxCorres == 1
		oView:AddSheet("FOLDER_01", "ABA_01_03", STR0131 ) //Contrato por Ato
	Else
		oView:AddSheet("FOLDER_01", "ABA_01_03", STR0021 ) //Modelo de Contrato
		oView:AddSheet("FOLDER_01", "ABA_01_04", STR0130 ) //"Pagamento Correspondente"
	EndIf	

	oView:CreateHorizontalBox("BOX_01_F01_A01" , 50,,,"FOLDER_01","ABA_01_01") //Informações Cadastraias
	oView:CreateHorizontalBox("BOX_01_F01_A011", 50,,,"FOLDER_01","ABA_01_01") //Advogado Correspondente
	oView:CreateHorizontalBox("BOX_01_F01_A02" , 50,,,"FOLDER_01","ABA_01_02") //Atuação Comarca
	oView:CreateHorizontalBox("BOX_01_F01_A021", 50,,,"FOLDER_01","ABA_01_02") //Atuação Área

	If nFlxCorres == 1
		oView:CreateHorizontalBox("BOX_01_F01_A03"	,40,,,"FOLDER_01","ABA_01_03") //Contrato por Ato
		oView:CreateHorizontalBox("BOX_01_F01_A031" ,60,,,"FOLDER_01","ABA_01_03")

		oView:CreateFolder("FOLDER_02", "BOX_01_F01_A031")  
		oView:AddSheet("FOLDER_02", "ABA_02_01", STR0132 )	//"Atos"
		oView:AddSheet("FOLDER_02", "ABA_02_02", STR0133 )	//"Negociações Especiais"

		oView:CreateHorizontalBox("BOX_01_F02_A01" ,100	,,,"FOLDER_02","ABA_02_01")	//"Atos"
		oView:CreateHorizontalBox("BOX_01_F02_A02" ,100	,,,"FOLDER_02","ABA_02_02")	//"Negociações Especiais"
	Else
		oView:CreateHorizontalBox("BOX_01_F01_A03" ,100,,,"FOLDER_01","ABA_01_03") //Modelo de Contrato
		oView:createHorizontalBox("BOX_01_F01_A04" ,100,,,"FOLDER_01","ABA_01_04") //Pagamento Correspondente
		
		oView:CreateFolder("FOLDER_02", "BOX_01_F01_A04")  //Pagamento Correspondente
		oView:AddSheet("FOLDER_02", "ABA_02_01", STR0026 ) //Pagamento de Nota
		oView:AddSheet("FOLDER_02", "ABA_02_02", STR0027 ) //Desdobramento da Nota

		oView:CreateHorizontalBox("BOX_01_F02_A01" ,100	,,,"FOLDER_02","ABA_02_01") //Pagamento de Nota
		oView:CreateHorizontalBox("BOX_01_F02_A02" ,85	,,,"FOLDER_02","ABA_02_02") //Desdobramento da Nota
		oView:createHorizontalBox("BOX_01_F02_A021",15	,,,"FOLDER_02","ABA_02_02") //Totalizador da Nota
	EndIf

	oView:SetOwnerView( "JURA132_VIEW"   , "BOX_01_F01_A01"  )
	oView:SetOwnerView( "JURA132_DETAIL" , "BOX_01_F01_A011" )
	oView:SetOwnerView( "JURA132_GRIDNU3", "BOX_01_F01_A02"  )
	oView:SetOwnerView( "JURA132_GRIDNVI", "BOX_01_F01_A021" )

	If nFlxCorres ==1
		oView:SetOwnerView( "JURA132_FORMNZI", "BOX_01_F01_A03"  )
		oView:SetOwnerView( "JURA132_GRIDNZC", "BOX_01_F02_A01"  )
		oView:SetOwnerView( "JURA132_GRIDNZD", "BOX_01_F02_A02"  )
	Else
		oView:SetOwnerView( "JURA132_GRIDNU5", "BOX_01_F01_A03"  )
		oView:SetOwnerView( "JURA132_GRIDNU4", "BOX_01_F02_A01"  )
		oView:SetOwnerView( "JURA132_GRIDNU6", "BOX_01_F02_A02"  )
		oView:SetOwnerView( "JURA132_GRIDNU62", "BOX_01_F02_A021" )
	EndIf

	If !(cParam == '1' .AND. IsPlugin())
		oView:AddUserButton( STR0017, "CLIPS"   , {| oView | JURANEXDOC("SA2","SA2MASTER","","A2_COD",,,,,,'3',"A2_LOJA")})
	EndIf

	If nFlxCorres == 2

		oView:AddUserButton( STR0028, "CHECKED" , {| oView | JA132Nota(oModel)})	//"Enviar Nota" 
		oView:AddUserButton( STR0036, "COPYUSER", {| oView | JA132Valid(oModel)})	//"Desdobrar"
		oView:AddUserButton( STR0082 , "BMPCPO", {| oView | J132Rej(oModel)}) 		//"Reajusta Contrato"
		oView:AddUserButton( STR0083 , "RECALC", {| oView | J132Contr(oModel)}) 	//"Contrato do modelo"

		oView:AddIncrementField( 'JURA132_GRIDNU6', 'NU6_COD' ) 
	EndIf

	oView:SetUseCursor( .T. )
	oView:EnableControlBar( .T. )   

	If nFlxCorres == 2
		oView:SetNoDeleteLine( "JURA132_GRIDNU6" )
	EndIf	

	//Alteração para que a tela não seja fechada quando o usuário Salva as informações.
	oView:SetCloseOnOk({|| .F. })

Return oView

//----------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Escritorio Correspondente
@author Clovis E. Teixeira dos Santos
@since 11/06/09
@version 1.0
@obs NU2MASTER - Dados do Escritorio Correspondente
/*/
//----------------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructSA2 := FWFormStruct( 1, "SA2", )
Local oStructAC8 := FWFormStruct( 1, "AC8", , .F. )       
Local oStructNU3 := FWFormStruct( 1, "NU3", )
Local oStructNVI := FWFormStruct( 1, "NVI", )
Local oStructNU5 := FWFormStruct( 1, "NU5", )
Local oStructNU4 := FWFormStruct( 1, "NU4", )
Local oStructNU6 := FWFormStruct( 1, "NU6", )
Local nFlxCorres := SuperGetMV("MV_JFLXCOR", , 1)	//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"
Local oStructNZI := FWFormStruct( 1, "NZI" )
Local oStructNZC := FWFormStruct( 1, "NZC" )
Local oStructNZD := FWFormStruct( 1, "NZD" )

	//Caso a chamada tenha vindo do TOTVS Jurídico, ignora o fluxo
	If (FwIsInCallStack("POST") .Or. FwIsInCallStack("PUT"))
		nFlxCorres := 2
	EndIf

	//----------------------------------------------
	//Monta o modelo do formulário
	//----------------------------------------------
	oStructAC8:RemoveField( "AC8_ENTIDA")
	oStructAC8:RemoveField( "AC8_CODENT")
	oStructNU5:RemoveField( "NU5_COD")
	oStructNU5:RemoveField( "NU5_CFORNE")
	oStructNU5:RemoveField( "NU5_LFORNE")
	oStructNU3:RemoveField( "NU3_CCREDE")
	oStructNU3:RemoveField( "NU3_LOJA"  )
	oStructNVI:RemoveField( "NVI_CCREDE")
	oStructNVI:RemoveField( "NVI_CLOJA" )
	oStructNU4:RemoveField( "NU4_CFORNE")
	oStructNU4:RemoveField( "NU4_LFORNE")
	oStructNU6:RemoveField( "NU6_CNOTA" )
	oStructNZI:RemoveField( "NZI_CCORRE")
	oStructNZI:RemoveField( "NZI_LCORRE")
	oStructNZC:RemoveField( "NZC_CCORRE")
	oStructNZC:RemoveField( "NZC_LCORRE")
	oStructNZD:RemoveField( "NZD_CCORRE")
	oStructNZD:RemoveField( "NZD_LCORRE")

	oModel:= MPFormModel():New( "JURA132", /*Pre-Validacao*/, {|oX| JA132TOK(oX)}/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:SetDescription( STR0008 ) // "Modelo de Dados de Escritorio Correspondente"
	JurSetRules( oModel, "SA2MASTER",, "SA2" )
	JurSetRules( oModel, "AC8DETAIL",, "AC8" )

	oModel:AddFields("SA2MASTER", NIL, oStructSA2, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:AddGrid(  "AC8DETAIL", "SA2MASTER" /*cOwner*/, oStructAC8, {|oX, oY, Oz| JA132DelLine(oX, oY, Oz)}, /*bLinePost*/,/*bPre*/, /*bPost*/)
	oModel:AddGrid(  "NU5DETAIL", "SA2MASTER" /*cOwner*/, oStructNU5, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/)
	oModel:AddGrid(  "NU3DETAIL", "SA2MASTER" /*cOwner*/, oStructNU3, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/)
	oModel:AddGrid(  "NVIDETAIL", "SA2MASTER" /*cOwner*/, oStructNVI, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/)
	oModel:AddGrid(  "NU4DETAIL", "SA2MASTER" /*cOwner*/, oStructNU4, {|oX, oY, Oz| JA132NU4(oX, oY, Oz)},{|oX|JA132NumNota(oX)}/*bLinePost*/ ,/*bPre*/, /*bPost*/)
	oModel:AddGrid(  "NU6DETAIL", "NU4DETAIL" /*cOwner*/, oStructNU6, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/)
	oModel:AddCalc( 'NU6TOTAL', "NU4DETAIL", "NU6DETAIL", 'NU6_VALOR', 'NU6__TOT', 'SUM', { ||.T. },,'Total' )
	oModel:AddFields("NZIDETAIL", "SA2MASTER" /*cOwner*/, oStructNZI, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:AddGrid(  "NZCDETAIL", "SA2MASTER" /*cOwner*/, oStructNZC, /*bLinePre*/, { |oX| J132LOkNZC(oX) }/*bLinePost*/,/*bPre*/, /*bPost*/)
	oModel:AddGrid(  "NZDDETAIL", "SA2MASTER" /*cOwner*/, oStructNZD, /*bLinePre*/, { |oX| J132LOkNZD(oX) }/*bLinePost*/,/*bPre*/, /*bPost*/)

	oModel:GetModel( "SA2MASTER" ):SetDescription( STR0009 ) // "Dados de Escritorio Correspondente"
	oModel:GetModel( "AC8DETAIL" ):SetDescription( STR0014 ) // "Dados de Relacionamento Entidade x Contato"
	oModel:GetModel( "NU3DETAIL" ):SetDescription( STR0022 ) // "Dados Atuação - Comarca"
	oModel:GetModel( "NVIDETAIL" ):SetDescription( STR0023 ) // "Dados Atuação - Área Jurídica"
	oModel:GetModel( "NU5DETAIL" ):SetDescription( STR0024 ) // "Dados Contrato Padrão"
	oModel:GetModel( "NU4DETAIL" ):SetDescription( STR0024 ) // "Dados Contrato Padrão"
	oModel:GetModel( "NU6DETAIL" ):SetDescription( STR0024 ) // "Dados Contrato Padrão"
	oModel:GetModel( "NZIDETAIL" ):SetDescription( STR0134 ) // "Dados Contrato por Ato"
	oModel:GetModel( "NZCDETAIL" ):SetDescription( STR0135 ) // "Dados Atos do Contrato"
	oModel:GetModel( "NZDDETAIL" ):SetDescription( STR0136 ) // "Dados Negociações Especiais do Contrato"

	oModel:GetModel( "AC8DETAIL" ):SetUniqueLine( { "AC8_CODCON" } )
	oModel:GetModel( "NU5DETAIL" ):SetUniqueLine( { "NU5_CTCONT" } )
	oModel:GetModel( "NU4DETAIL" ):SetUniqueLine( { "NU4_NUMNOT", "NU4_PARCEL" } )
	oModel:GetModel( "NU3DETAIL" ):SetUniqueLine( { "NU3_CCOMAR" } )
	oModel:GetModel( "NVIDETAIL" ):SetUniqueLine( { "NVI_CAREA"  } )
	oModel:GetModel( "NZCDETAIL" ):SetUniqueLine( { "NZC_ESTADO", "NZC_CESCRI"	, "NZC_CAREA"	, "NZC_CCLIEN", "NZC_LCLIEN", "NZC_CTPSER" 	} )
	oModel:GetModel( "NZDDETAIL" ):SetUniqueLine( { "NZD_CESCRI", "NZD_CAREA"	, "NZD_CCLIEN"	, "NZD_LCLIEN", "NZD_DTINI"	, "NZD_DTFIM"	} )
	
	oModel:SetRelation("NU3DETAIL", {{"NU3_FILIAL", "XFILIAL('NU3')" }, {"NU3_CCREDE", "A2_COD"} ,{"NU3_LOJA"  ,"A2_LOJA"}}, NU3->( IndexKey( 1 ) ) )
	oModel:SetRelation("NVIDETAIL", {{"NVI_FILIAL", "XFILIAL('NVI')" }, {"NVI_CCREDE", "A2_COD"} ,{"NVI_CLOJA" ,"A2_LOJA"}}, NVI->( IndexKey( 1 ) ) )
	oModel:SetRelation("AC8DETAIL", {{"AC8_FILIAL", "XFILIAL('AC8')" }, {"AC8_FILENT", "xFilial('SA2')"},{"AC8_ENTIDA",'"SA2"'},{"AC8_CODENT","PadR(SA2->(A2_COD+A2_LOJA), TamSX3('AC8_CODENT')[1] )" } }, 'AC8_CODENT' )
	oModel:SetRelation("NU5DETAIL", {{"NU5_FILIAL", "XFILIAL('NU5')" }, {"NU5_CFORNE", "A2_COD"} ,{"NU5_LFORNE","A2_LOJA"}}, NU5->( IndexKey( 1 ) ) )
	oModel:SetRelation("NU4DETAIL", {{"NU4_FILIAL", "XFILIAL('NU4')" }, {"NU4_CFORNE", "A2_COD"} ,{"NU4_LFORNE","A2_LOJA"}}, NU4->( IndexKey( 1 ) ) )
	oModel:SetRelation("NU6DETAIL", {{"NU6_FILIAL", "XFILIAL('NU6')" }, {"NU6_CNOTA" , "NU4_COD"}}, NU6->( IndexKey( 1 )))
	oModel:SetRelation("NZIDETAIL", {{"NZI_FILIAL", "XFILIAL('NZI')" }, {"NZI_CCORRE", "A2_COD"} ,{"NZI_LCORRE","A2_LOJA"}}, NZI->( IndexKey( 1 ) ) )
	oModel:SetRelation("NZCDETAIL", {{"NZC_FILIAL", "XFILIAL('NZC')" }, {"NZC_CCORRE", "A2_COD"} ,{"NZC_LCORRE","A2_LOJA"}}, NZC->( IndexKey( 1 ) ) )
	oModel:SetRelation("NZDDETAIL", {{"NZD_FILIAL", "XFILIAL('NZD')" }, {"NZD_CCORRE", "A2_COD"} ,{"NZD_LCORRE","A2_LOJA"}}, NZD->( IndexKey( 1 ) ) )

	//Abas opcionais para o fluxo de correspondente por Assunto Juridico	
	If nFlxCorres == 2
		oModel:SetOptional("NZIDETAIL", .T.)
		oModel:SetOptional("NZCDETAIL", .T.)
	EndIf

	//Abas opcionais para ambos os fluxos 
	oModel:SetOptional("NU3DETAIL", .T.)
	oModel:SetOptional("NVIDETAIL", .T.)
	oModel:SetOptional("NU5DETAIL", .T.)
	oModel:SetOptional("NU4DETAIL", .T.)
	oModel:SetOptional("NU6DETAIL", .T.)
	oModel:SetOptional("NZDDETAIL", .T.)

	//Alteração para melhorar a perfomance no PNA
	oModel:GetModel( 'NU4DETAIL' ):SetLoadFilter( { { 'NU4_DATAEM', "MV_PAR01", MVC_LOADFILTER_GREATER_EQUAL }, { 'NU4_DATAEM', "MV_PAR02", MVC_LOADFILTER_LESS_EQUAL }  } )
	oModel:SetOnDemand()

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA132TOK
Valida informações ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 20/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA132TOK(oModel)
Local lRet      := .T.
Local aArea     := GetArea()
Local cContato  := AllTrim(oModel:GetValue('AC8DETAIL','AC8_CODCON'))
Local nOpc      := oModel:GetOperation()
Local cParam	:= AllTrim( SuperGetMv('MV_JDOCUME',,'1'))
Local oModelNU4 := oModel:GetModel('NU4DETAIL')
Local nLineNU4  := oModelNU4:nLine
Local nQtdLNU4  := oModelNU4:GetQtdLine()    
Local nI		:= 0
Local nFlxCorres:= SuperGetMV("MV_JFLXCOR", , 1)	//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"
Local nLinAtu	:= 0			
Local nQtdLins	:= 0 
Local oModelNZC	:= Nil
Local oModelNZD	:= Nil

	//Caso a chamada tenha vindo do TOTVS Jurídico, ignora o fluxo
	If (FwIsInCallStack("POST") .Or. FwIsInCallStack("PUT"))
			nFlxCorres := 2
	EndIf

	If nOpc == 3 .Or. nOpc == 4
		
		If Empty(cContato) 		//Contato jurídico  
			ApMsgInfo(STR0025)	//"É necessário vincular ao menos um advogado ao correspondente", "É necessário vincular ao menos um advogado ao Correspondente" )
			lRet := .F.
			
		// se for inclusão e não vier do totvs jurídico, seta o flag jurídico	
		Elseif ((nOpc == 3) .And. !( FwIsInCallStack("POST") .Or. FwIsInCallStack("PUT") ) )
			lRet := oModel:SetValue("SA2MASTER","A2_MJURIDI",'1')
		Endif

		//Valida os campos aba Modelo de contrato 
		If lRet
			If (!Empty(FwFldGet('NU5_CMOEDA')) .Or. !Empty(FwFldGet('NU5_VALOR'))) .And.;
				!(!Empty(FwFldGet('NU5_CMOEDA')) .And. !Empty(FwFldGet('NU5_VALOR')))
				ApMsgInfo(STR0056) //Preencher os campos obrigatórios, Código da Moeda e Valor do Modelo de Contrato.
				lRet := .F.
			Endif
		Endif
		
		If lRet
			lRet := JA132CkNU4(oModel)    
		EndIf
			

		if lRet
			If ExistBlock("J132UPST") .And. !ExecBlock("J132UPST",.F.,.F.,{oModel})
				If JA132NU4Upd(oModel) .And. oModel:GetValue('NU4DETAIL','NU4_STSJUR') $ "3|4|5"
					ApMsgInfo(STR0067) //Esta nota não pode ser mais alterada! A nota já foi enviada para o Contas a Pagar.
					lRet := .F.
				EndIf
			Endif
		Endif
			
		
		if lRet .And. nOpc == 4 .And. JA132NU4Upd(oModel)
			if ApMsgYesNo(STR0068) //Esta sendo alterada uma nota já cadastrada. O status de pagamento será revertido para "Imcompleto", Confirma Operação?"
				oModel:SetValue("NU4DETAIL","NU4_STSJUR",'1')
			Else
				ApMsgAlert(STR0072)
				lRet := .F.
			Endif
		Endif

		For nI := 1 To nQtdLNU4
		
			oModelNU4:GoLine( nI )              
		
			If lRet .And. oModel:IsFieldUpdated('NU4DETAIL','NU4_OBS')
				oModelNU4:SetValue("NU4_DATAUL", DATE())
				oModelNU4:SetValue("NU4_CUSERA", __CUSERID)
				oModelNU4:SetValue("NU4_DUSERA", cUserName)
			EndIf                     
		Next
		oModelNU4:GoLine( nLineNU4 )
		
		//Verifica se fluxo de Correspondente esta por Follow-up
		If lRet .And. nFlxCorres == 1
		
			oModelNZC := oModel:GetModel("NZCDETAIL")
			oModelNZD := oModel:GetModel("NZDDETAIL")
			
			//Gera Financeiro
			If FwFldGet("NZI_ENVPAG") == "1"
			
				If Empty( FwFldGet("NZI_NATURE") ) .Or. Empty( FWFLDGET("NZI_TIPOTI") )
				
					JurMsgErro(STR0137 + RetTitle("NZI_NATURE") +", "+ RetTitle("NZI_TIPOTI") + STR0138)	//"Os campos " " são obrigatórios."
					lRet := .F.
				Else
				
					//Limpa campo de produto na NZC
					J132LimPro( oModelNZC, "NZC_PRODUT" ) 
				EndIf
				
			//Gera Compras			
			Else
			
				If Empty( FwFldGet("NZI_CONDPG") )
				
					JurMsgErro(STR0137 + RetTitle("NZI_CONDPG") + STR0138)	//"Os campos " " são obrigatórios."
					lRet := .F.
				Else
					
					//Valida campo produto da NZC
					nLinAtu		:= oModelNZC:nLine			
					nQtdLins  	:= oModelNZC:GetQtdLine()    
					For nI:=1 To nQtdLins
						oModelNZC:GoLine( nI )
						
						If !oModelNZC:IsDeleted() .And. Empty( oModelNZC:GetValue("NZC_PRODUT") )
							JurMsgErro(STR0137 + RetTitle("NZC_PRODUT") + STR0138 + " - " + STR0135)	//"Os campos " " são obrigatórios." "Dados Atos do Contrato" 
							lRet := .F.
							Exit
						EndIf	
					Next nI
					oModelNZC:GoLine( nLinAtu )
				EndIf
				
			EndIf
		EndIf
				
	EndIf

	If lRet
		If nOpc == 5
			If cParam == '2'
				lRet := JurExcAnex ('SA2',oModel:GetValue("SA2MASTER","A2_COD"),oModel:GetValue("SA2MASTER","A2_LOJA"),'3')
			Else
				lRet := JurExcAnex ('SA2',oModel:GetValue("SA2MASTER","A2_COD"),oModel:GetValue("SA2MASTER","A2_LOJA"),'1')		
			EndIf
		EndIf		
	EndIf	

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA132Nota(oModel)
Altera a informação de Status do Pagamento
@param 	oModel  	Model a ser verificado
@Return Nil

@author Clóvis Eduardo Teixeira
@since 24/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA132Nota(oModel)
Local cStatusPgt := oModel:GetValue("NU4DETAIL","NU4_STSJUR")   
Local oModelNU4  := oModel:GetModel('NU4DETAIL')
Local nOpc       := oModel:GetOperation()       
Local lRet       := .T.    

//==> 12/07/2012 - Tania - (SM-JURI042) - Incluir aqui Ponto de Entrada JA132NENV para consistir Desdobramento.
//@param	oModel	=>	Model a ser verificado
//@Return	lRet	=>	Retorno lógico - só prosseguir com a Function se lRet = .T.
//
If ExistBlock('JA132NENV')
  lRet := ExecBlock('JA132NENV',.F.,.F.,{oModel})
EndIf  

If lRet
	If nOpc == 4
	  If Empty(cStatusPgt)
	    ApMsgAlert(STR0029) //Este correspondente ainda possui nenhuma nota cadastrada. Operação cancelada!
	  ElseIf !JA132Cad(oModel)
	  	If oModelNU4:GetQtdLine() <= 1
			ApMsgAlert(STR0029) //Este correspondente ainda possui nenhuma nota cadastrada. Operação cancelada
		Else
			ApMsgInfo(STR0125) //Confirme o cadastro da nota antes de enviá-la
		EndIf
	  Else
		Do case
			Case cStatusPgt == '1' .And. Ja132VlrN(oModel) .And. ApMsgYesNo(STR0037)
		  	    lRet := oModelNU4:SetValue("NU4_STSJUR","2")
		      if lRet 
		        ApMsgInfo(STR0030) //A nota foi submetida a rotina de aprovação com sucesso! Operação Realizada!
		      else
		        ApMsgAlert(STR0065)  //Erro ao submeter a nota para aprovação
		      endif  
	
			Case cStatusPgt == '2'
	    	    ApMsgAlert(STR0031) //Esta nota já foi submetida a rotina de aprovação. Operação cancelada!
	
			Case cStatusPgt == '3'
		        ApMsgAlert(STR0032) //Esta nota já foi aprovada. Operação cancelada!
	
	    	Case cStatusPgt == '4'
	        	ApMsgAlert(STR0033) //Esta nota foi cancelada. Operação cancelada!
		End Case
	   Endif
	Else
	  ApMsgAlert(STR0035) //Esta operação só pode ser realizada com o model em modo de alteração
	Endif
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} JA132MontaArray(oModel)
Cria um array com todos os contratos vinculados ao contrato padrão
@param 	oModel  	Model a ser verificado
@Return Nil
@author Clóvis Eduardo Teixeira
@since 24/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA132MontaArray(cCodForne, cLojaForne)
Local aArea     := GetArea()
Local cQuery     := ""
Local cAliasQry := GetNextAlias()
Local aDados    := {}
Local cToday    := dTos(Date())

	cQuery := "	SELECT NUQ.NUQ_NUMPRO, NSU.NSU_VALOR, NUQ.NUQ_INSTAN, " + CRLF
	cQuery +=  		" NSU_CAJURI, NUQ_COD , NSU.NSU_SEQUEN, NSU.NSU_SEQORI , NSU.NSU_DTREAJ , " + CRLF
	cQuery +=  		" NSU.NSU_FLGREJ , NSU.NSU_FIMVGN , NSU.NSU_INIVGN, NSU.NSU_COD, NSQ.NSQ_PAGUNI, " + CRLF
	cQuery +=  		" NSZ_CCLIEN, NSZ_LCLIEN, NSZ_NUMCAS " + CRLF
	cQuery += "	FROM "+RetSqlName("NSU")+" NSU, " + CRLF
	cQuery +=  		RetSqlName("NUQ")+" NUQ, " + CRLF
	cQuery +=  		RetSqlName("NSQ")+" NSQ, " + CRLF
	cQuery +=  		RetSqlName("NSZ")+" NSZ " + CRLF  
	cQuery += " WHERE NUQ.NUQ_CAJURI  = NSU.NSU_CAJURI " + CRLF
	cQuery +=   " AND NSU.NSU_CTCONT  = NSQ.NSQ_COD " + CRLF
  cQuery +=   " AND NUQ.NUQ_CAJURI  = NSZ.NSZ_COD " + CRLF
  cQuery +=   " AND NSU.NSU_CAJURI  = NSZ.NSZ_COD " + CRLF		  
	cQuery += 	" AND NUQ.NUQ_INSTAN  = NSU.NSU_INSTAN " + CRLF
	cQuery +=   " AND NUQ.NUQ_CCORRE  = NSU.NSU_CFORNE " + CRLF
	cQuery +=   " AND NUQ.NUQ_LCORRE  = NSU.NSU_LFORNE " + CRLF
	cQuery +=   "	AND NSU.NSU_CFORNE  = '" + cCodForne + "' " + CRLF
	cQuery +=   " AND NSU.NSU_LFORNE  = '" + cLojaForne + "' " + CRLF
	cQuery +=   " AND (NSU.NSU_FIMVGN > '" + cToday + "' OR NSU.NSU_FIMVGN = '' OR NSU.NSU_DCAREN > '" + cToday + "') " + CRLF
	cQuery +=   "	AND NSU.NSU_FILIAL  = '" + xFilial("NSU") + "' " + CRLF
	cQuery +=   "	AND NUQ.NUQ_FILIAL  = '" + xFilial("NUQ") + "' " + CRLF
	cQuery +=   "	AND NSQ.NSQ_FILIAL  = '" + xFilial("NSQ") + "' " + CRLF
	cQuery +=   "	AND NSZ.NSZ_FILIAL  = '" + xFilial("NSZ") + "' " + CRLF
	cQuery +=   "	AND NSU.NSU_DESAUT  = '1' " + CRLF
	cQuery +=   "	AND NSU.D_E_L_E_T_ = ' ' " + CRLF
	cQuery +=   "	AND NUQ.D_E_L_E_T_ = ' ' " + CRLF
	cQuery +=   " AND NSQ.D_E_L_E_T_ = ' ' " + CRLF	
	cQuery +=   "	AND NSZ.D_E_L_E_T_ = ' ' " + CRLF  
  cQuery +=  " ORDER BY NSZ.NSZ_NUMCAS "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	(cAliasQry)->( dbGoTop() )

	While !(cAliasQry)->( EOF())
	  aAdd(aDados, {(cAliasQry)->NUQ_NUMPRO, (cAliasQry)->NSU_VALOR , (cAliasQry)->NUQ_INSTAN, (cAliasQry)->NSU_CAJURI, ; 
	                (cAliasQry)->NUQ_COD   , (cAliasQry)->NSU_SEQUEN, (cAliasQry)->NSU_SEQORI, (cAliasQry)->NSU_DTREAJ, ;
	                (cAliasQry)->NSU_FLGREJ, (cAliasQry)->NSU_FIMVGN, (cAliasQry)->NSU_INIVGN, (cAliasQry)->NSU_COD,    ; 
	                (cAliasQry)->NSQ_PAGUNI, (cAliasQry)->NSZ_CCLIEN, (cAliasQry)->NSZ_LCLIEN, (cAliasQry)->NSZ_NUMCAS})
	                  
		(cAliasQry)->( dbSkip() )
	End
	
	(cAliasQry)->( dbCloseArea())

RestArea(aArea)

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} JA132Valid(aDados)
Tela de exibição dos processos a ser desdobrados
@param 	oModel  	Model a ser verificado
@Return Nil
@author Clóvis Eduardo Teixeira
@since 24/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA132Valid(oModel)
Local aArea     	:= GetArea()
Local cCodForne   := FwFldGet("A2_COD")
Local cLojaForne  := FwFldGet("A2_LOJA")
Local cValorHon   := FwFldGet("NU4_VLRHON")
Local cValorDesp  := FwFldGet("NU4_VLRDES")
Local cNotaDesdo  := FwFldGet("NU4_NOTDES")
Local cVlrNota    := FwFldGet("NU4_VLRNOT")
Local cValorCont  := FwFldGet("NU5_VALOR")
Local cNumNota    := FwFldGet("NU4_COD")
Local aDados      := JA132MontaArray(cCodForne, cLojaForne)
Local aDesd       := {}
Local nOpc        := oModel:GetOperation()
Local nI          := 0
Local cTotalDesdb := 0
Local lRet        := .T.
Local oModelNU4 	:= oModel:GetModel('NU4DETAIL')

	If cNotaDesdo == '1'
		ApMsgAlert(STR0053) //A nota selecionada já foi desdobrada. Operação cancelada!
		lRet := .F.
	ElseIf oModelNU4:IsDeleted() .Or. oModelNU4:IsInserted() .Or. oModelNU4:IsUpdated()
		ApMsgInfo(STR0127) //Não é possível realizar o desdobramento, pois esta nota ou está sendo criada ou foi alterada ou está sendo excluida. Confirme antes de desdobrar!
		lRet := .F.
	ElseIf nOpc == 4
		//Desdobramento de Honorários
		If Len(aDados) <> 0 .And. !Empty(cValorHon)
			if ApMsgYesNo(STR0038)  //Deseja realizar o desdobramento dos honorários desta nota?
				For nI := 1 To Len(aDados)
					cTotalDesdb += aDados[nI][2]
				Next
				if JA132VldPre(cValorHon, cValorCont)
					aDesd := JURA101(cCodForne, cLojaForne, cNumNota, cVlrNota, 'H')
					JA132Desd(aDesd, aDados)
				Endif
			Endif
			
			//Desdobramento de Despesas
		Elseif Len(aDados) <> 0 .And. !Empty(cValorDesp)
			if ApMsgYesNo(STR0071) //Deseja realizar o desdobramento das despesas desta nota?
				For nI := 1 To Len(aDados)
					cTotalDesdb += aDados[nI][2]
				Next
				if JA132VldPre(cValorDesp, cValorCont)
					aDesd := JURA101(cCodForne, cLojaForne, cNumNota, cVlrNota, 'D')
					JA132Desd(aDesd, aDados)
				Endif
			Endif
		Elseif Empty(cValorHon) .And. Empty(cValorDesp)
			ApMsgAlert(STR0060) //Não foi possível realizar a operação, a nota a ser desdobrada não possui valor. Operação Cancelada!
			lRet := .F.
		Else
			ApMsgAlert(STR0044) //Não foi localizado nenhum contrato deste correspondente para desdobrar. Operação Cancelada!
			lRet := .F.
		Endif
	Else
		ApMsgInfo(STR0045) //Esta ação não pode ser realizada, o cadastro deve estar em modo de alteração. Operação cancelada!
		lRet := .F.	
	Endif

RestArea(aArea)
Return lRet
	 

//-------------------------------------------------------------------
/*/{Protheus.doc} JA132Desd(aDesd)
Rotina que realiza o desdobramento da nota pelos processos ligados
ao correspondente
@param 	oModel  	Model a ser verificado
@Return Nil
@author Clóvis Eduardo Teixeira
@since 24/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA132Desd(aDesd, aDados)
Local aArea     := GetArea()
Local nCt       := 0
Local oModel    := FWModelActive()
Local oAux      := oModel:GetModel("NU6DETAIL")
Local oAux2     := oModel:GetModel("NU4DETAIL")  
Local ccCorre   := oModel:GetValue("SA2MASTER","A2_COD")  
Local clCorre   := oModel:GetValue("SA2MASTER","A2_LOJA")
Local aAreaNSZ  := NSZ->(GetArea())
Local nValor    := 0 
Local nAux      := 0 
Local lRet      := .T.
Local cNumPro, cPoloAti, cPoloPas, cNumCas, cClien, cNClien, cNumContr  
Local nI                                                 
Local cTipo
Local dIniVigenc := ctod('')                                                                      
Local dFimVigenc := ctod('')       
Local cDescContr := ''                                                               

	For nI := 1 To Len(aDesd)
   	nCt++
		If nCt > 1
			If oAux:AddLine() <> nCt
				lRet := .F.
				ApMsgInfo( STR0024 )
				Exit
			EndIf
		EndIf
           
		cNumPro   := ''
		cPoloAti  := ''
		cPoloPas  := ''
		cNumCas   := ''   
		cClien    := ''                                                                      
		lClien    := ''
		cNClien   := '' 
		cNumContr := aDesd[nI][3] 
	    nValor    := aDesd[nI][2]			
		cTipo	  := aDesd[nI][4] 
	    dIniVigenc:= aDesd[nI][5]
	    dFimVigenc:= aDesd[nI][6]

		cNumPro   := rTrim(Posicione('NUQ',2, xFilial('NUQ')+ aDesd[nI][1] + '1','NUQ_NUMPRO'))
		cPoloAti  := rTrim(Posicione('NT9',3, xFilial('NT9')+ aDesd[nI][1] + '1' + '1','NT9_NOME'))
		cPoloPas  := rTrim(Posicione('NT9',3, xFilial('NT9')+ aDesd[nI][1] + '2' + '1','NT9_NOME'))   
		cNumCas   := rTRim(Posicione('NSZ',1, xFilial('NSZ')+ aDesd[nI][1], 'NSZ_NUMCAS'))		
		cClien	  := rTRim(Posicione('NSZ',1, xFilial('NSZ')+ aDesd[nI][1], 'NSZ_CCLIEN'))		
		cLlien	  := rTRim(Posicione('NSZ',1, xFilial('NSZ')+ aDesd[nI][1], 'NSZ_LCLIEN'))					
		cNClien   := rTRim(Posicione('SA1',1, xFilial('SA1')+ cClien + cLlien,'A1_NOME'))	   
		cDescContr:= rTRim(POSICIONE('NSQ',1, xFilial('NSQ')+ cTipo,		  'NSQ_DESC'))	   
					
		
		If !oAux:SetValue("NU6_VALOR", (nValor)) .Or. !oAux:SetValue("NU6_CAJURI", (aDesd[nI][1]))  .Or. ;
	       !oAux:SetValue("NU6_NUMPRO", cNumPro) .Or. !oAux:SetValue("NU6_PATIVO", cPoloAti)  .Or.;
	       !oAux:SetValue("NU6_PPASSI", cPoloPas) .Or. !oAux:SetValue("NU6_NUMCAS", cNumCas) .Or. ;
	       !oAux:SetValue("NU6_CCLIEN", cClien) .Or. !oAux:SetValue("NU6_LCLIEN", cLlien) .Or.;
  	       !oAux:SetValue("NU6_DCLIEN", cNClien) .Or. !oAux:SetValue("NU6_CCONTR", cNumContr) .Or.;			    	       
  	       !oAux:SetValue("NU6_CTCONT", cTipo) .Or. !oAux:SetValue("NU6_DTCONT", cDescContr) .Or.;
  	       !oAux:SetValue("NU6_INIVGN", dIniVigenc) .Or. !oAux:SetValue("NU6_FIMVGN", dFimVigenc)   	       
			lRet := .F.
			ApMsgInfo( STR0014 )
			Exit
		EndIf  
				
		if lRet
  		If ( nAux := aScan(aDados, {|x| AllTrim(x[4]) == AllTrim(aDesd[nI][1] ) } ) ) > 0
			  If aDados[nAux][13] == '1' .And. ApMsgYesNo(STR0086) //Este desdobramento é proveniente de um contrato com pagamento único. Deseja encerrar este contrato?
			    lRet := JA183Enc(aDados[nAux][4], ccCorre, clCorre, aDados[nAux][3], aDados[nAux][6], aDados[nAux][7], aDados[nAux][12])
			  Endif
			Endif    
		Endif	
	Next

	if lRet .And. Len(aDesd) > 0 
	  lRet := oAux2:SetValue("NU4_NOTDES",'1')
	  ApMsgInfo(STR0062,STR0063) //Desdobramento Realizado com Sucesso, aperte o botão "Confirmar" para finalizar a operação., Desdobramento de Notas
	Endif
            
RestArea(aAreaNSZ) 
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA132DelLine(oModel)
Rotina de validação para o grid de contatos do correspondente
@param 	oModel 	Model a ser verificado
@Return lRet
@author Clóvis Eduardo Teixeira
@since 26/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA132DelLine(oModelGrid, nLine, nOpc)
Local aArea      := GetArea()
Local oModel     := oModelGrid:GetModel()
Local oModelSA2  := oModel:GetModel( "SA2MASTER" )
Local cCcorresp  := oModelSA2:GetValue( "A2_COD")
Local cLcorresp  := oModelSA2:GetValue( "A2_LOJA")
Local lRet       := .T.
Local cProc

	If nOpc == 'DELETE'
    cProc := Posicione('NUQ',4,xFilial('NUQ')+ cCcorresp + cLcorresp + oModelGrid:GetValue('AC8_CODCON', nLine),'NUQ_CAJURI')
    if !Empty(cProc)
      lRet := .F.
      ApMsgAlert(STR0054 +cProc)
    Endif
	EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ja132VlrN(oModel)
Rotina de validação para o grid de contatos do correspondente
@param 	oModel 	Model a ser verificado
@Return lRet
@author Clóvis Eduardo Teixeira
@since 26/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Ja132VlrN(oModel)
Local aArea    := GetArea()
Local lRet     := .T.
Local nTtlDesb := 0
Local nVlrNota := FwFldGet("NU4_VLRNOT") //oModel:GetValue("NU4DETAIL","NU4_VLRHON")
Local nI
Local oModelGrid := oModel:GetModel( "NU6DETAIL" )

For nI := 1 To oModelGrid:GetQtdLine()

	If !oModelGrid:IsDeleted( nI ) .And. !oModelGrid:IsEmpty( nI ) 
		oModelGrid:GoLine(nI)
		nTtlDesb += FwFldGet("NU6_VALOR") //(oModelGrid:GetValue( 'NU6_VALOR', nI ))
	EndIf

Next

if nTtlDesb > nVlrNota
	ApMsgInfo(STR0055)
	lRet = .F.
End if

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA132VldPre(oModel)
Pré-validação do contrato antes de realizar o desdobramento
@param 	oModel 	Model a ser verificado
@Return lRet
@author Clóvis Eduardo Teixeira
@since 26/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA132VldPre(cValorHon, cValorCont)
Local lRet := .T.

	If cValorHon < cValorCont
		If SuperGetMV( 'MV_JGEDBME',,.T.)
			If !ApMsgYesNo(STR0061+CRLF+STR0064) //O valor da nota a ser desdobrada é inferior ao valor do contrato. Deseja continuar assim mesmo?
				ApMsgAlert(STR0047) //Operação Cancelada!
				lRet := .F.
			EndIf
		Else
			ApMsgInfo( STR0061+CRLF+STR0047 ) //O valor da nota a ser desdobrada é inferior ao valor do contrato. Operação Cancelada!
			lRet := .F.
		EndIf			        	
	Endif

Return lRet        
 
//-------------------------------------------------------------------
/*/{Protheus.doc} JA132DelNU4(oModelGrid, nLine, nOpc)
Rotina de validação para o grid de notas do correspondente
@param 	oModel 	Model a ser verificado
@Return lRet
@author Clóvis Eduardo Teixeira
@since 26/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA132NU4(oModelGrid, nLine, nOpc)
Local aArea:= GetArea()
Local lRet := .T.

If ExistBlock('JA132DNU4')

  lRet := ExecBlock('JA132DNU4',.F.,.F.,{oModelGrid,nLine,nOpc})

  If ValType(lRet) <> 'L'
    lRet :=  .T.
  EndIf

EndIf

    
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA132NU6(cCajuri)
Rotina para preechimento do campo NU6_DCLIEN
@param 	cCajuri - Código do assunto jurídico
@Return cRet
@author Clóvis Eduardo Teixeira
@since 24/11/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA132NU6(cCajuri)
Local aArea   := GetArea()
Local cRet    := ''
Local cClien  := rTRim(Posicione('NSZ',1, xFilial('NSZ')+ cCajuri, 'NSZ_CCLIEN'))	
Local cLclien := rTRim(Posicione('NSZ',1, xFilial('NSZ')+ cCajuri, 'NSZ_LCLIEN'))			

	if !Empty(cCajuri)
	  cRet := rTRim(Posicione('SA1',1, xFilial('SA1')+ cClien + cLclien,'A1_NOME'))					         
	Endif  

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA132NumNota(cCodNota, cNumNota, cNumParc, cForne, clForne)
Rotina para verificaçãoi da repetição da chave num_nota+parcela
@param 	CodNota  - Codigo da Nota
@param 	NumNota  - Numero da Nota
@param cNumParc - Numero da Parcela
@param cForne	  - Codigo do Fornecedor
@param clForne	  - Loja do Forncedor
@Return lRet
@author Clóvis Eduardo Teixeira
@since 24/11/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA132NumNota(oModelNU4)
Local aArea     := GetArea()
Local lRet      := .T.
Local cAliasQry := ''
Local oModel    := oModelNU4:GetModel() //FwModelActive()
Local nLine	  := oModelNU4:GetLine()
Local cNumNota  := AllTrim(oModel:GetValue('NU4DETAIL','NU4_NUMNOT'))
Local cNumParc  := AllTrim(oModel:GetValue('NU4DETAIL','NU4_PARCEL'))
Local cForne    := AllTrim(oModel:GetValue('SA2MASTER','A2_COD'))
Local clForne   := AllTrim(oModel:GetValue('SA2MASTER','A2_LOJA'))
Local cTmpCod	  := oModelNU4:GetValue("NU4_COD",nLine)	
Local cTmpNta	  := ALLTRIM(JurGetDados("NU4",1,xFilial("NU4")+cTmpCod,"NU4_NUMNOT"))	
Local cTmpParc  := ALLTRIM(JurGetDados("NU4",1,xFilial("NU4")+cTmpCod,"NU4_PARCEL"))	
		           
//<- Se for um novo cadastro ou Se a linha não esta deletada  
//   E se houve alterações no numero da nota OU da parcela e se esta diferente do valor já gravado na tabela ->	
If oModelNU4:IsInserted() .OR. ( !oModelNU4:IsDeleted(nLine) .And. (oModel:IsFieldUpdated('NU4DETAIL',' NU4_NUMNOT',nLine) .OR. oModel:IsFieldUpdated('NU4DETAIL','NU4_PARCEL', nLine) .AND. ;
	( cTmpNta <> ALLTRIM(oModelNU4:GetValue("NU4_NUMNOT",nLine)) .AND. cTmpParc <> ALLTRIM(oModelNU4:GetValue("NU4_PARCEL",nLine)))))
	
	cAliasQry := GetNextAlias()
		
	BeginSql Alias cAliasQry
		SELECT
			NU4.R_E_C_N_O_ NU4_CODREC
		FROM
			%Table:NU4% NU4
		WHERE
			NU4.NU4_NUMNOT = %Exp:cNumNota% AND
			NU4.NU4_PARCEL = %Exp:cNumParc% AND
			NU4.NU4_CFORNE = %Exp:cForne%   AND
			NU4.NU4_LFORNE = %Exp:clForne%  AND
			NU4.NU4_FILIAL = %xFilial:NU4%  AND
			NU4.%NotDel%
	EndSql
			
	dbSelectArea(cAliasQry)
				
	If !(cAliasQry)->( EOF() )
		//<- Se for alguma atualização, só poderá dar a mensagem se foi no número da nota OU o número da parcela->   
		If oModelNU4:GetDataID() <> (cAliasQry)->NU4_CODREC
			ApMsgInfo(STR0066) // "Ja existe nota com este número de parcela cadastrada. Favor revisar!"
			lRet := .F.	
		EndIF
		
	EndIf
		
	(cAliasQry)->( dbCloseArea())
		
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA132TamNota(cNumNota, cNumParc)
Rotina para do preenchimento dos 9 caracteres do numero da nota.
@param 	NumNota - Numero da Nota
@param 	NumNota - Numero da Parcela
@Return lRet
@author Clóvis Eduardo Teixeira
@since 24/11/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA132TamNota(cNumNota)
Local lRet := .T.

 if !(Len(ALLTRIM(M->NU4_NUMNOT)) == 9)
   ApMsgInfo(STR0069) //O número da nota deve ser preenchido com 9 caracteres   
   lRet := .F.
 Endif
 
Return lRet      
 
//-------------------------------------------------------------------
/*/{Protheus.doc} JA132NU4Upd(oModel)
Rotina para verificação de alteração no model NU4
@Return lRet
@author Clóvis Eduardo Teixeira
@since 24/11/2010
@version 1.0
/*/
//-------------------------------------------------------------------     
Static Function JA132NU4Upd(oModel)     
Local aArea      := GetArea()
Local oModelGrid := oModel:GetModel("NU4DETAIL")                                    
Local lRet := .F.   

	if (oModel:IsFieldUpdated('NU4DETAIL','NU4_NUMNOT') .Or. oModel:IsFieldUpdated('NU4DETAIL','NU4_PARCEL') .Or.;
 	  oModel:IsFieldUpdated('NU4DETAIL','NU4_DATARF') .Or.;
	  oModel:IsFieldUpdated('NU4DETAIL','NU4_DATAEM') .Or. oModel:IsFieldUpdated('NU4DETAIL','NU4_DATAVE') .Or. ;
  	  oModel:IsFieldUpdated('NU4DETAIL','NU4_VLRHON') .Or. oModel:IsFieldUpdated('NU4DETAIL','NU4_CMOEDE') .Or. ;
	      oModel:IsFieldUPdated('NU4DETAIL','NU4_VLRDES') .Or. oModel:IsFieldUpdated('NU4DETAIL','NU4_VLRNOT')) .And. ;
	        !oModelGrid:IsInserted()
	         lRet := .T. 
	Endif

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J132Rej()
Tela de Confirmacao que reajusta o contrato
@param omodel
@author Paulo Borges
@since 03/01/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J132Rej(oModel)
Local aArea   := GetArea()
Local ctc 		:= FwfldGet('NU5_CTCONT')
Local lRet    := .T.
Local DReaj   := FwfldGet('NU5_DTREAJ')
Local cPart   := JurUsuario(__CUSERID)
Local nOpc    := oModel:GetOperation()

Private oDlg

	If nOpc <> 4
		ApMsgInfo(STR0035) //"Esta operação só pode ser realizada com o model em modo de alteração"
		lRet := .F.    
		Return(lret)
	endif
			
	If Empty(ctc)
		ApMsgInfo(STR0094) //"Este correspondente ainda nao possui nenhum modelo cadastrado. Operação cancelada!"
		lRet := .F.    
		Return(lret)
	Endif
	
	if !Empty(dReaj)
		If !MsgYesNo("Contrato já reajustado, Confirma novo reajuste?")
			Return(.F.)
		endif
	endif
		
	If !Empty(cPart)
			
		Define MsDialog oDlg Title STR0095 FROM 176, 188  To 530, 500 Pixel // reajuste //"Reajuste "
	
			nValCon := 0			
			
			@ 022, 050 Say STR0096 Size 060, 008 Pixel Of oDLG // "Reajuste de Contrato"  //"Reajuste de Contrato"
			@ 042, 050 Say STR0097 Size 050, 008 Pixel Of oDlg  //"Informe a Data "
			@ 052, 050 MsGet oreajuste Var dReajuste Size 060, 009  Pixel Of odlg hasbutton //Valid IIf( empty(dReajuste), ApMsgAlert( "Data incorreta " ), .T.)   
	
			@ 072, 050 Say STR0098 Size 050, 008 Pixel Of oDLG //novo valor //"Qual o novo valor"
			@ 082, 050 MsGet nValCon Size 060, 009 Picture '@E 99,999,999,999.99' Pixel Of oDLG hasbutton Valid IIf( nValCon < 0, ApMsgAlert( STR0099 ), .T.)   //"Valor incorreto "
			
			@ 100,040 BUTTON obntOk Prompt STR0100 Size 28, 10 Of oDLG Pixel Action ( J132Reaj2(oModel, nValCon ,dReajuste)) //"Reajustar"
			@ 100,090 BUTTON obntSair Prompt STR0089 Size 28, 10 Of oDLG Pixel Action oDlg:End() //"Sair"
			
		Activate MsDialog oDlg Centered
			
	Else
			ApMsgAlert(STR0101) // "O usuário atual não está vinculado a nenhum participante, verifique!" //"O usuário atual não está vinculado a nenhum participante, verifique!"
	EndIf

RestArea(aArea)
	
Return

//-------------------------------------------------------------------
/* { Protheus.doc } J132Reaj2()
Rotina que reajusta o contrato
@param nValCon
@author Paulo Borges
@since 03/01/2011
@version 1.0
*/
//-------------------------------------------------------------------
Function J132Reaj2(oModel, nValCon , dReajuste)
Local aArea     := GetArea()                    
Local aAreaNSU	:= NSU->(GetArea())
Local rlRet     := .T.
Local prxsequen := "", rSequen, rSeqOri, rCajuri, rCcorresp, rLcorresp, rCodCont, rInstan, rcPadra, rcMoeda, rDetalh, rInivgn, rFimvgn, rDesaut
Local oModelNSU := FWLoadModel( 'JURA088' )
Local rvalor    := oModel:GetValue("NU5DETAIL","NU5_VALOR")
Local nI        := 0
Local lEncerra  := .t.
Local l132rej   := ExistBlock('132REJBL')
Local cCodReg   := ''                                            
Local cQueryCt	:= ""
Local aRecnos	  := {}

Private nValant := oModel:GetValue("NU5DETAIL","NU5_VALOR")
Private rTipoC  := oModel:GetValue("NU5DETAIL","NU5_CTCONT")
Private rforne  := oModel:GetValue("SA2MASTER","A2_COD")
Private rlForne := oModel:GetValue("SA2MASTER","A2_LOJA")

if empty(dReajuste)
  ApMsgInfo(STR0085)  //"Data em Branco"
	Return
endif 

if !JA132TOK(oModel)  
	ApMsgInfo( STR0076 ) //"Não foi possível reajustar o contrato, Verificar as validaçoes da rotina do correspondente"
	Return
endif			

if !JA132ValCon(rTipoC,rForne,rlforne,dReajuste)
	ApMsgInfo( STR0080 ) //"Não existem contratos validos para reajuste ou a data de reajuste é menor que o inicio da vigência ou maior que o fim da vigência, Verifique!"
	Return
endif


ApMsgInfo(STR0081)  //informa encerramento do contrato

oModel:SetValue("NU5DETAIL","NU5_VALANT", nValant ) 
oModel:SetValue("NU5DETAIL","NU5_VALOR", nValCon ) 
oModel:SetValue("NU5DETAIL","NU5_DTREAJ", dReajuste )
	 
oModel:CommitData()		 

if !rlRet
	Return(rlRet)
endif		


If l132rej
	rlRet := ExecBlock('132REJBL', .F., .F.)    

	If ValType(lRetCon) <> "L"
		rlret := .T.
	EndIf
EndIf

If !rlret
	Return(rlRet)
EndIf	 

cQueryCt	:= "	SELECT	NSU.R_E_C_N_O_	" + CRLF
cQueryCt	+= "	FROM	"+RetSqlName("NSU")+" NSU	" + CRLF
cQueryCt	+= "	WHERE	NSU.NSU_FILIAL = '" + xFilial('NSU')+ "'	" + CRLF
cQueryCt	+= "	AND		NSU.NSU_CTCONT = '" + rTipoC + "'	" + CRLF
cQueryCt	+= "	AND		NSU.NSU_CFORNE = '" + rForne + "'	" + CRLF
cQueryCt	+= "	AND		NSU.NSU_LFORNE = '" + rlforne + "'	" + CRLF
cQueryCt	+= "	AND		NSU.NSU_FLGREJ <> '1'	" + CRLF
cQueryCt	+= "	AND		NSU.D_E_L_E_T_ = ' '	" + CRLF

aRecnos	:= JurSQL(cQueryCt, "R_E_C_N_O_" )

DbSelectArea("NSU")

For nI := 1 to Len(aRecnos)
	NSU->(DbGoto( aRecnos[nI][1] ))
	If  (NSU->NSU_FLGREJ <> "1" )  //.AND. NSU->NSU_FIMVGN > dDATABASE  //CONTRATO NAO REAJUSTADO 		
		//Salva os dados para incluir o novo contrato 
		rSequen   := NSU->NSU_SEQUEN
		rSeqOri   := NSU->NSU_SEQORI
		rCajuri   := NSU->NSU_CAJURI
		rCcorresp := NSU->NSU_CFORNE  
		rLcorresp := NSU->NSU_LFORNE                  
		rCodCont  := NSU->NSU_CTCONT  
		rInstan   := NSU->NSU_INSTAN                 
		rcPadra   := NSU->NSU_CPADRA                 
		rcMoeda   := NSU->NSU_CMOEDA                 
		rValor    := NSU->NSU_VALOR                 
		rDetalh   := NSU->NSU_DETALH                 
		rInivgn   := NSU->NSU_INIVGN                 
		rDesaut   := NSU->NSU_DESAUT                 
		prxsequen := 	strzero(Val(rSequen)+1,3)	   //verifica se ja houve reajuste e pega a proxima sequencia		
         
		//Ativa o model dos contratos para ajustar o anterior
		oModelNSU:SetOperation(MODEL_OPERATION_UPDATE)	
		oModelNSU:Activate()
		oModelNSU:SetValue("NSUMASTER","NSU_FLGREJ","1")   //reajustado	  
		if Empty(rSeqOri)  // grava se for primeiro reajuste
			oModelNSU:SetValue("NSUMASTER","NSU_SEQORI",prxSequen) 
		endif

		oModelNSU:SetValue("NSUMASTER","NSU_DTREAJ",dReajuste)		

		If lEncerra 
			oModelNSU:SetValue("NSUMASTER","NSU_FIMVGN",dReajuste-1)

			//-- Se o contrato em questao estiver com carencia, encerra o contrato tambem pela Data da Carencia.
			If !Empty( oModelNSU:GetValue("NSUMASTER","NSU_DCAREN") )
				oModelNSU:SetValue("NSUMASTER","NSU_DCAREN",dReajuste-1)				
				oModelNSU:SetValue("NSUMASTER","NSU_NCAREN",0)				
			EndIf
		Endif	

		if oModelNSU:VldData()

			cCodReg := GETSXENUM("NSU","NSU_COD")
			if RecLock('NSU', .T.)               
	
				NSU->NSU_FILIAL := xFilial('NSU')  
				NSU->NSU_COD    := cCodReg
				NSU->NSU_SEQUEN := prxsequen
				NSU->NSU_VALOR  := nValCon                 
				NSU->NSU_DTREAJ := CTOD('  /  /  ')                 
				NSU->NSU_SEQORI := rSequen
				NSU->NSU_CAJURI := rCajuri
				NSU->NSU_CFORNE := rCcorresp  
				NSU->NSU_LFORNE := rLcorresp                  
				NSU->NSU_CTCONT := rCodCont  
				NSU->NSU_INSTAN := rInstan                 
				NSU->NSU_CPADRA := rcPadra                 
				NSU->NSU_CMOEDA := rcMoeda                 
				NSU->NSU_DETALH := rDetalh                 
				NSU->NSU_INIVGN := dReajuste //rFimVgn+1                 
				NSU->NSU_FIMVGN := CTOD('  /  /  ')   //rFimvgn+365                 		
				NSU->NSU_DESAUT := rDesaut                 
				NSU->NSU_FLGREJ := '2'                 	//nao reajustado			  	
				MsUnlock() 
			Endif  

			oModelNSU:CommitData()
		else
			ApMsgAlert( STR0077 )			//"Não foi possível alterar o status do contrato para reajustado  , Verificar as validaçoes do campo "
		endif
	  
		oModelNSU:DeActivate()
 
	Endif

Next nI
RestArea(aAreaNSU)
RestArea(aArea)

if rlRet
	ApMsgInfo( STR0079  )  //"Contratos reajustados com sucesso"
Endif

Return(rlRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA132Nota(oModel)
Altera a informação de Status do Pagamento
@param 	oModel  	Model a ser verificado
@Return Nil

@author Clóvis Eduardo Teixeira
@since 24/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J132Contr(oModel)
Local rTipoC    := oModel:GetValue("NU5DETAIL","NU5_CTCONT")
Local rforne    := oModel:GetValue("SA2MASTER","A2_COD")
Local rlForne   := oModel:GetValue("SA2MASTER","A2_LOJA")
Local cReajustado := '1' 
Local oModelSAVE := FWModelActive()

JURA088( "", "" , rforne , rlForne , .t. , rTipoC , cReajustado)

FWModelActive(oModelSAVE)

Return

Function JA132ValCon(rTipoC,rForne,rlforne,dReajuste)
Local aArea     := GetArea()
Local RetCon := .f.

	DbSelectArea("NSU")
	NSU->(DbSetFilter({|| NSU->(NSU_FILIAL+NSU_CTCONT+NSU_CFORNE+NSU_LFORNE) == xFilial('NSU')+rTipoC+rForne+rlforne},;  
	"NSU->(NSU_FILIAL+NSU_CTCONT+NSU_CFORNE+NSU_LFORNE) == xFilial('NSU')+rTipoC+rForne+rlforne"))
	NSU->(DbGoTop())
	
	While !NSU->(Eof())
	
		If NSU->NSU_FLGREJ <> "1" .And. dReajuste >= NSU->NSU_INIVGN  .And. (Empty(NSU->NSU_FIMVGN) .Or. dReajuste <= NSU->NSU_FIMVGN .Or. dReajuste <= NSU->NSU_DCAREN) //CONTRATO NAO REAJUSTADO
			RetCon := .t.	
			Exit
		endif
		NSU->(DbSkip())		
	
	Enddo
	NSU->(dbClearFilter())	

RestArea(aArea)

Return(RetCon)

//-------------------------------------------------------------------
/*/{Protheus.doc} J132Crys
Geracao do relatorio em Crystal Reports JUR132 (Relacao de Advogados
Correspondentes)

@param	cTpRelat	Tipo de Relatorio:
						1 - Por Especialidade
						2 - Por Especialidade e Comarca
						3 - Por Pesquisa de Nome

@Return Nil

@author Daniel Magalhaes
@since 25/08/2011
@version 1.0

/*/
//-------------------------------------------------------------------
Function J132Crys(cTpRelat)
Local cGetEspec   := Space(TamSX3("NQB_COD")[1])
Local cDesEspec   := ""
Local cGetComarca := Space(TamSX3("NQ6_COD")[1])
Local cDesComarca := ""
Local cGetNome    := Space(TamSX3("U5_CODCONT")[1])
Local cIsNumPag   := "S"
Local cParams
Local lOk         := .F.
Local lCancel     := .F.
Local oDlgCrys

Default cTpRelat := "1"

While .T.

	DEFINE MSDIALOG oDlgCrys TITLE STR0102 FROM 000,000 TO 160,280 PIXEL Style DS_MODALFRAME //"Relação de Advogados Correspondentes"

	If cTpRelat $ "1,2"
		oGetEspec   := TJurPnlCampo():New(002,006,050,022,oDlgCrys,STR0105,"NQB_COD", {|| },{|| cGetEspec := oGetEspec:Valor},Nil,Nil,Nil,"NQB"   ) //"Cód Especialidade"
	EndIf

	If cTpRelat == "2"
		oGetComarca := TJurPnlCampo():New(002,070,050,022,oDlgCrys,STR0106,"NQ6_COD", {|| },{|| cGetComarca := oGetComarca:Valor},Nil,Nil,Nil,"NQ6") //"Cód Comarca"
	EndIf

	If cTpRelat == "3"
		oGetNome    := TJurPnlCampo():New(002,006,100,022,oDlgCrys,STR0107,"U5_CONTAT",{|| },{|| cGetNome  := oGetNome:Valor} ,Nil,Nil,Nil,"SU5NTA") //"Nome Advogado Correspondente"
	EndIf

	@ 060,006 Button "Ok" Size 050,012 PIXEL OF oDlgCrys  Action (lOk := J132VldCrys(cTpRelat,cGetEspec,cGetComarca,cGetNome), oDlgCrys:End()) //"Ok"
	@ 060,066 Button STR0043 Size 050,012 PIXEL OF oDlgCrys  Action (lCancel := .T., oDlgCrys:End()) //"Cancelar"

	ACTIVATE MSDIALOG oDlgCrys CENTERED
	
	If lCancel
		Exit
	ElseIf lOk
		Exit
	EndIf

EndDo

If lOk
	
	If cTpRelat $ "1,2"
		cDesEspec   := Posicione("NQB",1,xFilial("NQB")+cGetEspec,"NQB_DESC")
	EndIf
	
	If cTpRelat == "2"
		cDesComarca := Posicione("NQ6",1,xFilial("NQ6")+cGetComarca,"NQ6_DESC")
	EndIf
	
	/*nPosResult := aScan( aCbxResult, cCbxResult )
	
	Do Case
		Case nPosResult == 1
			cOptions := "2" + cOptions
		Case nPosResult == 2
			cOptions := "1" + cOptions
		Otherwise
			cOptions := "1" + cOptions
	EndCase*/

	cParams := cTpRelat + ";"
	cParams += cGetEspec + ";"
	cParams += cDesEspec + ";"
	cParams += cGetComarca + ";"
	cParams += cDesComarca + ";"
	cParams += cGetNome + ";"
	cParams += cIsNumPag + ";"

	/*
	CALLCRYS (rpt , params, options), onde:
	rpt = Nome do relatório, sem o caminho.

	params = Parâmetros do relatório, separados por vírgula ou ponto e vírgula. Caso seja marcado este parâmetro, serão desconsiderados os parâmetros marcados no SX1.

	options = Opções para não se mostrar a tela de configuração de impressão , no formato x;y;z;w ,onde:
	x = Impressão em Vídeo(1), Impressora(2), Impressora(3), Excel (4), Excel Tabular(5), PDF(6) e Texto (7) .
	y = Atualiza Dados  ou não(1)
	z = Número de Cópias, para exportação este valor sempre será 1.
	w = Título do Report, para exportação este será o nome do arquivo sem extensão.

	*/

	//JCallCrys(cNomeRelat,cParams,cOptions,.T.,.T.)
	Do Case
		Case cTpRelat == "1"
			If Existblock( 'JURR132A' )
				U_JURR132A(cGetEspec, cDesEspec)
			Else
				JURR132A(cGetEspec, cDesEspec)
			EndIf
		Case cTpRelat == "2"
			If Existblock( 'JURR132B' )
				U_JURR132B(cGetEspec, cDesEspec, cGetComarca, cDesComarca)
			Else
				JURR132B(cGetEspec, cDesEspec, cGetComarca, cDesComarca)
			EndIf
		Case cTpRelat == "3"
			If Existblock( 'JURR132C' )
				U_JURR132C(cGetNome)
			Else
				JURR132C(cGetNome)
			EndIf
	EndCase
	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J132VldCrys
Valida os parametros do relatorio em Crystal Reports JUR132

@param	cTpRelat	Tipo de Relatorio:
						1 - Por Especialidade
						2 - Por Especialidade e Comarca
						3 - Por Pesquisa de Nome
		cGetEspec	Valor do campo Cod Especialidade
		cGetComarca	Valor do campo Cod Comarca
		cGetNome	Valor do campo Nome do Advogado Correspondente

@return Nil

@author Daniel Magalhaes
@since 25/08/2011
@version 1.0

		#define STR0110 "Preencha o campo Código da Especialidade"
		#define STR0111 "Preencha o campo Código da Comarca"
		#define STR0112 "Preencha o campo Nome do Advogado Correspondente"

/*/
//-------------------------------------------------------------------
Static Function J132VldCrys(cTpRelat,cGetEspec,cGetComarca,cGetNome)
Local lRet := .F.

Default cTpRelat    := ""
Default cGetEspec   := ""
Default cGetComarca := ""
Default cGetNome    := ""

If cTpRelat == "1"
	If !Empty(cGetEspec)
		If ExistCpo("NQB", cGetEspec, 1)
			lRet := .T.
		EndIf
	Else
		ApMsgInfo(STR0110) //"Preencha o campo Código da Especialidade"
	EndIf

ElseIf cTpRelat == "2"
	If !Empty(cGetEspec)
		If ExistCpo("NQB", cGetEspec, 1)
			lRet := .T.
		EndIf
	Else
		ApMsgInfo(STR0110) //"Preencha o campo Código da Especialidade"
	EndIf
	
	If lRet
		If !Empty(cGetComarca)
			If ExistCpo("NQ6", cGetComarca, 1)
				lRet := .T.
			EndIf
		Else
			ApMsgInfo(STR0111) //"Preencha o campo Código da Comarca"
		EndIf
	EndIf
	
ElseIf cTpRelat == "3"
	If !Empty(cGetNome)
		lRet := .T.
	Else
		ApMsgInfo(STR0112) //"Preencha o campo Nome do Advogado Correspondente"
	EndIf

EndIf

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} JA132CkHnDe()
Verifica se o Pagamento de Correspondente esta preenchido os campos de Hono ou de Despesa
@param 	oModel  	Model a ser verificado
@Return Nil

@author Clóvis Eduardo Teixeira
@since 24/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA132CkHnDe(oModel)
Local aArea     := GetArea()
Local oModelNU4 := oModel:GetModel('NU4DETAIL') 
Local nI		 		:= 0   
Local lRet    	:= .F.

For nI := 1 To oModelNU4:GetQtdLine()
	oModelNU4:GoLine( nI )	
	If !oModelNU4:IsDeleted()
		If  !Empty(FwFldGet('NU4_VLRHON')) .And. !Empty(FwFldGet('NU4_VLRDES'))			
			lRet:= .T.
		Else
			Do Case 
				Case Empty(FwFldGet('NU4_VLRHON')) .And. !Empty(FwFldGet('NU4_VLRDES'))
					oModel:SetValue('NU4DETAIL','NU4_CMOEHO','')
				Case Empty(FwFldGet('NU4_VLRDES')) .And. !Empty(FwFldGet('NU4_VLRHON'))
					oModel:SetValue('NU4DETAIL','NU4_CMOEDE','')
			EndCase 
			
		EndIf
	EndIf	
Next

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA132CkNU4()
Valida os campos de Pagamento de Nota
@param 	oModel  	Model a ser verificado
@Return Nil

@author Jorge Luis Branco Martins Junior
@since 24/05/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA132CkNU4(oModel)
Local aArea     := GetArea()
Local oModelNU4 := oModel:GetModel('NU4DETAIL') 
Local nCtNU4	  := 0  
Local lRet      := .T.   
Local nQtde     := oModelNU4:GetQtdLine()

For nCtNU4 := 1 To nQtde
	oModelNU4:GoLine(nCtNU4)
	
	If oModelNU4:isUpdated() .And. !oModelNU4:IsDeleted()
		
		If nQtde == 1 .And. Empty(oModelNU4:GetValue('NU4_VLRDES')) .And. Empty(oModelNU4:GetValue('NU4_VLRHON'));
		   .And. Empty(oModelNU4:GetValue('NU4_NUMNOT')) .And. Empty(oModelNU4:GetValue('NU4_DATARF'))
			Exit
		EndIf		
		
		If lRet
			if Empty(oModelNU4:GetValue('NU4_NUMNOT'))
				JurMsgErro(STR0124 + CRLF + CRLF + STR0120 + oModelNU4:GetValue('NU4_COD')) //Numero da nota não pode estar vazia ### Verificar Cód Notas: 
				lRet := .F.
				Exit
			Endif
		Endif
		
		If lRet
			if !Empty(oModelNU4:GetValue('NU4_NUMNOT'))
				If Empty(oModelNU4:GetValue('NU4_DATAEM'))
					JurMsgErro(STR0048 + CRLF + CRLF + STR0120 + oModelNU4:GetValue('NU4_COD')) //É necessário preencher o campo de Data de Emissão da Nota ### Verificar Cód Notas:
					lRet := .F.
					Exit
				ElseIf oModelNU4:GetValue('NU4_DATAEM') > Date()
					JurMsgErro(STR0121 + CRLF + CRLF + STR0120 + oModelNU4:GetValue('NU4_COD')) //Data de Emissão da Nota não pode ser maior que a data atual ### Verificar Cód Notas:
					lRet := .F.
					Exit
				EndIf
			Endif
		Endif
		
		If lRet
			if !Empty(oModelNU4:GetValue('NU4_NUMNOT')) .And. Empty(oModelNU4:GetValue('NU4_DATAVE'))
				JurMsgErro(STR0117 + CRLF + CRLF + STR0120 + oModelNU4:GetValue('NU4_COD')) //É necessário preencher o campo de Data de Vencimento da Nota ### Verificar Cód Notas:
				lRet := .F.
				Exit
			Endif
		Endif
		
		If lRet
			If X3Obrigat("NU4_DATARF") .And. X3Usado("NU4_DATARF")
				If !Empty(oModelNU4:GetValue('NU4_NUMNOT'))
					If Empty(oModelNU4:GetValue('NU4_DATARF'))
						JurMsgErro(STR0084 + CRLF + CRLF + STR0120 + oModelNU4:GetValue('NU4_COD')) //E necessário preencher o campo de Data de Referencia  da Nota ### Verificar Cód Notas:
						lRet := .F.
						Exit
					ElseIf oModelNU4:GetValue('NU4_DATARF') > Date()
						JurMsgErro(STR0122 + CRLF + CRLF + STR0120 + oModelNU4:GetValue('NU4_COD')) //Data de Referencia da Nota não pode ser maior que a data atual  ### Verificar Cód Notas:
						lRet := .F.
						Exit
					EndIf
				Endif
			EndIf
		Endif
		
		If lRet
			If !Empty(oModelNU4:GetValue('NU4_NUMNOT'))
			
				Do Case
					Case Empty(oModelNU4:GetValue('NU4_CMOEHO')) .And. !Empty(oModelNU4:GetValue('NU4_VLRDES'));
					     .And. !Empty(oModelNU4:GetValue('NU4_CMOEDE'))
						oModelNU4:SetValue('NU4_VLRHON',0)
					Case Empty(oModelNU4:GetValue('NU4_VLRHON')) .And. !Empty(oModelNU4:GetValue('NU4_VLRDES'));
					     .And. !Empty(oModelNU4:GetValue('NU4_CMOEDE'))
						oModelNU4:SetValue('NU4_CMOEHO','')
					Case Empty(oModelNU4:GetValue('NU4_VLRDES')) .And. !Empty(oModelNU4:GetValue('NU4_VLRHON'));
					     .And. !Empty(oModelNU4:GetValue('NU4_CMOEHO'))
						oModelNU4:SetValue('NU4_CMOEDE','')
					Case Empty(oModelNU4:GetValue('NU4_CMOEDE')) .And. !Empty(oModelNU4:GetValue('NU4_VLRHON'));
						   .And. !Empty(oModelNU4:GetValue('NU4_CMOEHO'))
						oModelNU4:SetValue('NU4_VLRDES',0)
				EndCase
				
				Do Case
					Case !Empty(oModelNU4:GetValue('NU4_VLRHON')) .And. Empty(oModelNU4:GetValue('NU4_CMOEHO'))
						JurMsgErro(STR0051 + CRLF + CRLF + STR0120 + oModelNU4:GetValue('NU4_COD')) //É necessário preencher o campo de Código da moeda Honorário ### Verificar Cód Notas:
						lRet := .F.
						Exit
					Case !Empty(oModelNU4:GetValue('NU4_CMOEHO')) .And. Empty(oModelNU4:GetValue('NU4_VLRHON'))
						JurMsgErro(STR0049 + CRLF + CRLF + STR0120 + oModelNU4:GetValue('NU4_COD')) //É necessário preencher o campo de Valor do Honorário ### Verificar Cód Notas:
						lRet := .F.
						Exit
					Case !Empty(oModelNU4:GetValue('NU4_VLRDES')) .And. Empty(oModelNU4:GetValue('NU4_CMOEDE'))
						JurMsgErro(STR0052 + CRLF + CRLF + STR0120 + oModelNU4:GetValue('NU4_COD')) //É necessário preencher o campo de Código da moeda Despesa ### Verificar Cód Notas:
						lRet := .F.
						Exit
					Case !Empty(oModelNU4:GetValue('NU4_CMOEDE')) .And. Empty(oModelNU4:GetValue('NU4_VLRDES'))
						JurMsgErro(STR0118 + CRLF + CRLF + STR0120 + oModelNU4:GetValue('NU4_COD')) //É necessário preencher o campo de Valor da Despesa ### Verificar Cód Notas:
						lRet := .F.
						Exit
					Case Empty(oModelNU4:GetValue('NU4_VLRDES')) .And. Empty(oModelNU4:GetValue('NU4_CMOEDE')) .And. ;
						Empty(oModelNU4:GetValue('NU4_VLRHON')) .And. Empty(oModelNU4:GetValue('NU4_CMOEHO'))
						JurMsgErro(STR0119 + CRLF + CRLF + STR0120 + oModelNU4:GetValue('NU4_COD')) // A nota para pagamento não contém honorários ou despesas. Deverá ser cadastrado algum valor para possibilitar a confirmação da nota ### Verificar Cód Notas:
						lRet := .F.
						Exit
					Case !Empty(oModelNU4:GetValue('NU4_VLRDES')) .And. !Empty(oModelNU4:GetValue('NU4_CMOEDE')) .And. ;
						!Empty(oModelNU4:GetValue('NU4_VLRHON')) .And. !Empty(oModelNU4:GetValue('NU4_CMOEHO'))
						JurMsgErro(STR0070 + CRLF + CRLF + STR0120 + oModelNU4:GetValue('NU4_COD')) //A nota para pagamento contem honorários e despesas, devera ser cadastrado em notas separadas para possibilitar o desdobramento! Operação Cancelada. ### Verificar Cód Notas: 
						lRet := .F.
						Exit
				EndCase
			Endif
		Endif
	EndIf
Next

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA132VldDt()
Valid das datas
@param 	cDate  Data a ser validada
@Return Nil

@author Jorge Luis Branco Martins Junior
@since 24/05/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA132VldDt(cDate)
Local lRet := .T.

If cDate > Date()
	ApMsgAlert(STR0123)//Data não pode ser maior que a data atual
	lRet := .F.
ElseIF !J132VDts()// Valida data de Emissão < Dta de Vencimento 	
	lRet := .F.
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} JA132Cad(oModel)
Verifica se a linha do Grid é um registro cadastrado no banco

@param 	oModel  	Model a ser verificado
@Return .T. Se existir no banco
        .F. Se não existir no banco
        
@author Jorge Luis Branco Martins Junior
@since 11/06/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA132Cad(oModel)
Local lRet 		:= .F.
Local aArea  		:= GetArea()
Local cQuery 		:= ''
Local cCod 			:= ''
Local cTmp   		:= GetNextAlias()

cCod := Alltrim(oModel:GetValue("NU4DETAIL","NU4_COD"))

cQuery := "SELECT COUNT(*) QTD"
cQuery += "	FROM " + RetSqlName( 'NU4' ) + " NU4"
cQuery += " WHERE D_E_L_E_T_ = ' ' AND NU4_COD = '" + cCod + "'"

cQuery := ChangeQuery(cQuery) // By JPP - 06/03/2014 - 11:56 - Inclusão da função ChangeQuery para o funcionamento query em diversos bancos de dados.

dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cTmp, .T., .T. )

If (cTmp)->QTD > 0
	lRet := .T.
EndIf

(cTmp)->( dbCloseArea() )

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA132Filtro()
Verifica se existe o pergunte "JURA132"


@Return .T./.F. Se existe ou não o pergunte.
        
@author Rafael Rezende Costa
@since 01/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA132Filtro()
Local lRet	:=	Pergunte("JURA132",.T.)	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J132VDts(oModel)
Verifica se a data de vencimento da nota esta apos da data de emissão

@param 	oModel  	Model a ser verificado
@Return .T. Se existir no banco
         .F. Se não existir no banco
        
@author Rafael Rezende Costa
@since 19/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J132VDts(oModel)
Local lRet := .T.

Default oModel := FWModelActive()
	
	If oModel:GetID() == 'JURA132' .And. !Empty(oModel:GetModel('NU4DETAIL'):GetValue('NU4_DATAEM')).And.!empty(oModel:GetModel('NU4DETAIL'):GetValue('NU4_DATAVE'))
		IF oModel:GetModel('NU4DETAIL'):GetValue('NU4_DATAEM') > oModel:GetModel('NU4DETAIL'):GetValue('NU4_DATAVE')
			lRet := .F.
			ApMsgAlert(STR0129) // "A data de vencimento não pode ser anterior à data de emissão."
		EndIf		
			
	ElseIF	oModel:GetID() == 'NU4DETAIL'.AND. !EMPTY(oModel:GetValue('NU4_DATAEM')).AND.!EMPTY(oModel:GetValue('NU4_DATAVE'))
		IF oModel:GetValue('NU4_DATAEM') > oModel:GetValue('NU4_DATAVE')
			lRet := .F.
			ApMsgAlert(STR0129) //"A data de vencimento não pode ser anterior à data de emissão."
		EndIf			
	EndIf
	
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} JA132WHEN
Habilitar ou não a edição do campo passado por parâmetro.

@param 	cCampo  	Nome do campo do X3_WHEN
@Return lRet	 	.T./.F. Habilita ou não a edição do campo.
@author Julio de Paula Paz
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA132WHEN(cCampo)
Local lRet      	:= .T.
Local oModel    := FWModelActive()

Begin Sequence
   	If IsInCallStack("JURA132")
   	   If cCampo == "NU4_VLRHON"
		   If oModel:GetValue('NU4DETAIL','NU4_NOTDES') == "1"
		      lRet := .F.
		   EndIf
       EndIf
       
	   If cCampo == "NU4_VLRDES"
	      If oModel:GetValue('NU4DETAIL','NU4_NOTDES') == "1"
		      lRet := .F.
		   EndIf
	   EndIf   
	   
	   If cCampo == "NU4_VLRNOT"
	      If oModel:GetValue('NU4DETAIL','NU4_NOTDES') == "1"
		      lRet := .F.
		   EndIf
	   EndIf  
	   
	EndIf 
End Sequence

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} J132LOkNZC
Valida linha do grid NZC

@param 	oModeNZC	- Model da NZC
@Return lRetorno	- .T./.F. 
@author Rafael Tenorio da Costa
@since 18/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J132LOkNZC( oModelNZC )
	
	Local lRetorno := .T.
	Local cTpSerAtu	:= oModelNZC:GetValue("NZC_CTPSER")	
	Local cAgrVlAtu	:= oModelNZC:GetValue("NZC_AGRUVL")
	Local nLinAtu 	:= oModelNZC:nLine
	Local nQtdLins  := oModelNZC:GetQtdLine()
	Local nCont		:= 0    
	
	//Valida preenchimento do campo produto
	lRetorno := J132ValCmp( "NZC_PRODUT", oModelNZC:GetValue("NZC_PRODUT") )
	
	//Valida preenchimento do agrupamento de valor			
	If lRetorno
		For nCont:=1 To nQtdLins
			oModelNZC:GoLine( nCont )
			
			If !oModelNZC:IsDeleted() .And. nCont <> nLinAtu 
				If oModelNZC:GetValue("NZC_CTPSER") == cTpSerAtu .And. oModelNZC:GetValue("NZC_AGRUVL") <> cAgrVlAtu
											  
					JurMsgErro(STR0140)	//"Agrupamento de valor inválído, não pode existir o mesmo tipo de serviço com agrupamento de valor diferente."
					lRetorno := .F.
					Exit
				EndIf
			EndIf
		Next nCont
		oModelNZC:GoLine( nLinAtu )
	EndIf	
			
Return lRetorno

//------------------------------------------------------------------
/*/{Protheus.doc} J132LOkNZD
Valida linha do grid NZD

@param 	oModeNZD	- Model da NZD
@Return lRetorno	- .T./.F. 
@author Rafael Tenorio da Costa
@since 18/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J132LOkNZD( oModeNZD )
	
	Local lRetorno 	:= .T.
	Local cComarca	:= oModeNZD:GetValue("NZD_CCOMAR") 
	Local cForo		:= oModeNZD:GetValue("NZD_CFORO")
	Local cVara		:= oModeNZD:GetValue("NZD_CVARA")

	//Valida comarca, foro e vara	
	If !Empty(cComarca) .Or. !Empty(cForo) .Or. !Empty(cVara)
		If Empty(cComarca) .Or. Empty(cForo) .Or. Empty(cVara)
			JurMsgErro(STR0139)		//"Algum dos campos comarca, foro ou vara não foi preenchido."
			lRetorno := .F.
		EndIf
	EndIf  
	
Return lRetorno

//------------------------------------------------------------------
/*/{Protheus.doc} J132ValCmp
Valida campos das tabela NZx
Uso NZC_PRODUT
@param 	cCampo 		- Nome do campo
@param 	xConteudo 	- Conteudo do campo 
@Return lRet	 	.T./.F. Habilita ou não a edição do campo.
@author Rafael Tenorio da Costa
@since 18/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J132ValCmp(cCampo, xConteudo)

	Local aArea		:= GetArea() 
	Local lRet 		:= .T.
	Local xAux		:= Nil

	cCampo := AllTrim( cCampo )
	
	Do Case
	
		Case cCampo $ "NZC_PRODUT"
	
			//Gera Compras
			If FwFldGet("NZI_ENVPAG") == "2" .And. Empty( xConteudo )
				JurMsgErro(STR0137 + RetTitle(cCampo) + STR0138)	//"Os campos " " são obrigatórios."
				lRet := .F.			
			EndIf

		Case cCampo $ "NZD_CFORO"
		
			xAux := AllTrim( FwFldGet("NZD_CCOMAR") )
		
			DbSelectArea("NQC")
			NQC->( DbSetOrder(1) )	//NQC_FILIAL+NQC_COD
			If NQC->( DbSeek( xFilial("NQC") + xConteudo) )
			
			 	If !Empty(xAux) .And. xAux <> NQC->NQC_CCOMAR  
					lRet := .F.
				EndIf				
			EndIf
		
		Case cCampo $ "NZD_CVARA"
		
			xAux := AllTrim( FwFldGet("NZD_CFORO") )
		
			DbSelectArea("NQE")
			NQE->( DbSetOrder(1) )	//NQE_FILIAL+NQE_COD
			If NQE->( DbSeek( xFilial("NQE") + xConteudo) )
			
				If !Empty(xAux) .And. xAux <> NQE->NQE_CLOC2N
			 		lRet := .F.
			 	EndIf				
			EndIf
			
	End Case
	
	RestArea( aArea )

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} J132LimPro
Limpa os campos produto da NZC e NZD

@param 	oModelAux	- Model da NZC ou NZD
@param 	cCampo		- Campo que tera seu conteudo zerado
@author Rafael Tenorio da Costa
@since 20/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J132LimPro( oModelAux, cCampo )

	Local nCont		:= 1
	Local nLinAtu 	:= oModelAux:nLine
	Local nQtdLins  := oModelAux:GetQtdLine()    
	
	//Limpa campo	
	For nCont:=1 To nQtdLins
		oModelAux:GoLine( nCont )
		oModelAux:LoadValue(cCampo, "")
	Next nCont
	
	oModelAux:GoLine( nLinAtu )

Return Nil

//------------------------------------------------------------------
/*/{Protheus.doc} Ja132NQCFil
Filtro da consulta padrão de foro NQCNZD, utilizando a comarca.  

@return cFiltro - Retorna o filtro
@author Rafael Tenorio da Costa
@since 07/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Ja132NQCFil()

	Local aArea		:= GetArea()
	Local cFiltro	:= "@#"
	Local oModel    := FWModelActive()	
	Local cComarca  := oModel:GetValue("NZDDETAIL", "NZD_CCOMAR")
	
	If !Empty( cComarca )	
		cFiltro += "NQC->NQC_CCOMAR == '"+cComarca+"'"
	EndIf	
	
	cFiltro += "@#"
	RestArea( aArea )

Return cFiltro

//------------------------------------------------------------------
/*/{Protheus.doc} Ja132NQEFil
Filtro da consulta padrão da vara NQENZD, utilizando o foro.  

@return cFiltro - Retorna o filtro
@author Rafael Tenorio da Costa
@since 07/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Ja132NQEFil()

	Local aArea		:= GetArea()
	Local cFiltro	:= "@#"
	Local oModel    := FWModelActive()
	Local cForo		:= oModel:GetValue("NZDDETAIL", "NZD_CFORO")
	
	If !Empty( cForo )	
		cFiltro += "NQE->NQE_CLOC2N == '"+cForo+"'"
	EndIf	
	
	cFiltro += "@#"
	RestArea( aArea )

Return cFiltro
