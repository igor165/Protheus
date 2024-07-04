#INCLUDE "TMSA035.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//----------------------------------------------------------
/*/{Protheus.doc} TMSA035
Regras e Restrições de Embarque - RRE
@PARAM  --
@RETURN NÃO RETORNA NADA
@AUTHOR Rafael Souza
@OWNER TOTVS S/A
@VERSION PROTHEUS 11
@SINCE 23/03/2015
@PROJECT
@MENU
@HISTORY
/*/
//----------------------------------------------------------
Function TMSA035()

	Local oBrowse := Nil
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DJ4')			// Alias da tabela utilizada
	oBrowse:SetMenuDef('TMSA035')	// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)	// "Regras e Restrições de Embarque - RRE"

	oBrowse:Activate()

Return Nil

//-----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Utilizacao de menu Funcional

Uso: TMSA035

@sample
//MenuDef()

@author Rafael Souza.
@since 23/03/2015
@version 1.0
/*/
//-----------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 DISABLE MENU	 // Visualizar // "Pesquisar"
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TMSA035" OPERATION 2 ACCESS 0 DISABLE MENU   // "Visualizar"
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSA035" OPERATION 3 ACCESS 0                // "Incluir"
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSA035" OPERATION 4 ACCESS 0 DISABLE MENU   // "Alterar"
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSA035" OPERATION 5 ACCESS 0 DISABLE MENU   // "Excluir"
	ADD OPTION aRotina TITLE STR0015  ACTION "VIEWDEF.TMSA035" OPERATION 9 ACCESS 0 DISABLE MENU   // "Copiar"

Return(aRotina)
//-----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do Modelo

Uso: TMSA035

@sample
//ModelDef()

@author Eduardo Alberti
@since 31/03/2015
@version 1.0
/*/
//-----------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStruDJ4 := FWFormStruct( 1, 'DJ4' )
	Local oStruDJ5 := FWFormStruct( 1, 'DJ5' )
	Local oStruDJ6 := FWFormStruct( 1, 'DJ6' )
	Local oStruDJ7 := FWFormStruct( 1, 'DJ7' )
	
	oModel := MPFormModel():New('TMSA035', /*bPre*/, { |oMdl| PosVldMdl( oMdl ) } /*bPost*/, /*bCommit*/, /*bCancel*/)

	oModel:AddFields('MdFieldDJ4', Nil, oStruDJ4 ,,,) // Regras Restrições Embarque - RRE

	oModel:AddGrid('MdGridDJ5', 'MdFieldDJ4', oStruDJ5, /*bLinePre*/, {|oModelGrid,nLine| PosVldDJ5(oModelGrid, nLine)} /*bLinePost*/,  /*bPre*/,/*bPost*/, /*bLoad*/) //Itens da RRE
	oModel:AddGrid('MdGridDJ6', 'MdGridDJ5' , oStruDJ6, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/) //Caracteristicas dos itens da RRE
	oModel:AddGrid('MdGridDJ7', 'MdGridDJ5' , oStruDJ7, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/) //Check-List dos itens RRE

	oModel:SetRelation('MdGridDJ5',{ {'DJ5_FILIAL','xFilial("DJ5")'},{'DJ5_CODRRE','DJ4_CODRRE'} }, DJ5->( IndexKey(1) ) )
	oModel:SetRelation('MdGridDJ6',{ {'DJ6_FILIAL','xFilial("DJ6")'},{'DJ6_CODRRE','DJ4_CODRRE'},{'DJ6_ITEM','DJ5_ITEM'} }, DJ6->( IndexKey(1) ) )
	oModel:SetRelation('MdGridDJ7',{ {'DJ7_FILIAL','xFilial("DJ7")'},{'DJ7_CODRRE','DJ4_CODRRE'},{'DJ7_ITEM','DJ5_ITEM'} }, DJ7->( IndexKey(1) ) )

	oModel:GetModel( 'MdGridDJ5' ):SetDescription(STR0007) //-- "Itens da RRE"
	oModel:GetModel( 'MdGridDJ6' ):SetDescription(STR0008) //-- "Caracteristicas dos Itens RRE"
	oModel:GetModel( 'MdGridDJ7' ):SetDescription(STR0009) //-- "Chek-List dos Itens RRE"

	oModel:GetModel( 'MdGridDJ6' ):SetUniqueLine( {"DJ6_CODCAR"} )
	oModel:GetModel( 'MdGridDJ7' ):SetUniqueLine( {"DJ7_IDCHK"}  )

	oModel:GetModel( 'MdGridDJ6' ):SetOptional(.T.) //-- Permite grid sem dados
	oModel:GetModel( 'MdGridDJ7' ):SetOptional(.T.) //-- Permite grid sem dados

	oModel:SetDescription(STR0001) //-- "Regras e Restrições de Embarque - RRE"
	oModel:GetModel('MdFieldDJ4'):SetDescription(STR0001)//-- "Regras e Restrições de Embarque - RRE"
	oModel:SetPrimaryKey({"DJ4_CODRRE"})

Return oModel

//-----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Retorna a View (tela) da rotina

Uso: TMSA035

@author Eduardo Alberti
@since 01/04/2015
@version 1.0
/*/
//-----------------------------------------------------------
Static Function ViewDef()

	Local oStruDJ4  := FwFormStruct(2,'DJ4')
	Local oStruDJ5  := FwFormStruct(2,'DJ5')
	Local oStruDJ6  := FwFormStruct(2,'DJ6')
	Local oStruDJ7  := FWFormStruct(2,'DJ7')
	Local oModel    := FwLoadModel('TMSA035')
	Local oView
	Local cTitle    := ""
	Local cResource := ""
	Local bBloco
	Local aButtons  := {}
	Local nCount    := 0

	//-- Ponto de Entrada TM035BUT - utilizado para incluir botoes especificos
	If ExistBlock( "TM035BUT" )
		If Valtype( aUsrBut := Execblock( "TM035BUT", .F., .F. ) ) == "A"
			AEval( aUsrBut, { |x| AAdd( aButtons, x ) } )
		EndIf
	EndIf

	oView := FwFormView():New()

	For nCount := 1 To Len(aButtons)
		cResource:= aButtons[nCount,1]
		bBloco   := aButtons[nCount,2]
		cTitle   := aButtons[nCount,3]
		oView:AddUserButton(cTitle,cResource,bBloco)
	Next nCount
	
	
	oView:SetModel(oModel)
	oView:EnableControlBar(.T.)

	//-- Field DJ4
	oView:AddField( "MdFieldDJ4",oStruDJ4)
	oStruDJ4:AddGroup("GrpId",  STR0014 , "1", 2)   //RRE
	oStruDJ4:AddGroup("GrpRRE", STR0013 , "1", 2)   //Abrangencia RRE 
	oView:CreateHorizontalBox("Field",30)
	oView:SetOwnerView( "MdFieldDJ4","Field")

	oStruDJ4:SetProperty("DJ4_CODRRE" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStruDJ4:SetProperty("DJ4_CODCLI" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStruDJ4:SetProperty("DJ4_LOJCLI" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStruDJ4:SetProperty("DJ4_NOMCLI" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStruDJ4:SetProperty("DJ4_ABRANG" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStruDJ4:SetProperty("DJ4_RSPRAS" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStruDJ4:SetProperty("DJ4_TIPFRO" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStruDJ4:SetProperty("DJ4_TIPMOT" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStruDJ4:SetProperty("DJ4_LME"    , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStruDJ4:SetProperty("DJ4_LIV"    , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStruDJ4:SetProperty("DJ4_DATINI" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStruDJ4:SetProperty("DJ4_DATFIM" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	
	oStruDJ4:SetProperty("DJ4_RREVGE" , MVC_VIEW_GROUP_NUMBER, "GrpRRE")
	oStruDJ4:SetProperty("DJ4_RRECOL" , MVC_VIEW_GROUP_NUMBER, "GrpRRE")
	oStruDJ4:SetProperty("DJ4_RRECOT" , MVC_VIEW_GROUP_NUMBER, "GrpRRE")
	oStruDJ4:SetProperty("DJ4_RRECAL" , MVC_VIEW_GROUP_NUMBER, "GrpRRE")
	
	//-- Grid DJ5
	oView:AddGrid("MdGridDJ5",oStruDJ5, "MdGridDJ5" )
	oView:CreateHorizontalBox("GRID",35)
	oView:SetOwnerView( "MdGridDJ5","GRID")
	oView:AddIncrementView( "MdGridDJ5", "DJ5_ITEM" )
	oView:EnableTitleView("MdGridDJ5",STR0007) //-- Cadastro de veiculos

	//-- Folder DJ6 e DJ7
	oView:AddGrid( "VwGridDJ6", oStruDJ6, "MdGridDJ6" )
	oView:AddGrid( "VwGridDJ7", oStruDJ7, "MdGridDJ7" )

	oView:CreateHorizontalBox( "FOLDER", 035 )

	oView:CreateFolder( "PASTA", "FOLDER" )

	oView:AddSheet( "PASTA", "ABA01", STR0010 ) 	// Caracteristica Do Itemas
	oView:AddSheet( "PASTA", "ABA02", STR0011 )	// Check-List Do Item

	oView:CreateHorizontalBox( "GridDJ6"  , 100,,,"PASTA","ABA01" )
	oView:CreateHorizontalBox( "GridDJ7"  , 100,,,"PASTA","ABA02" )

	oView:SetOwnerView("VwGridDJ6", "GridDJ6" )
	oView:SetOwnerView("VwGridDJ7", "GridDJ7" )

Return oView
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA035Vld
@autor		: Eduardo Alberti
@descricao	: Valida Campos Do Browse
@since		: Apr./2015
@using		: Regras e Restrições de Embarque - RRE
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA035Vld()

	Local aArea  := GetArea()
	Local aArSA1 := SA1->(GetArea())
	Local lRet   := .t.
	Local cCampo := ReadVar()

	If "DJ4_CODCLI" $ cCampo .Or. "DJ4_LOJCLI" $ cCampo

		If !Empty(M->DJ4_CODCLI) .And. !Empty(M->DJ4_LOJCLI)

			DbSelectArea("SA1")
			DbSetOrder(1)
			If !MsSeek(xFilial("SA1") + M->DJ4_CODCLI + M->DJ4_LOJCLI )
				Help(' ',1,'TMSA03501')   //Cliente nao existe ! Verifique o cadastro.
				lRet := .f.
			EndIf
		EndIf
		
	ElseIf "DJ4_DATINI" $ cCampo 
		lRet:= If( !Empty( M->DJ4_DATFIM ), ( M->DJ4_DATFIM >= M->DJ4_DATINI), .T. )
				
	ElseIf "DJ4_DATFIM" $ cCampo 
		lRet:= M->DJ4_DATFIM >= M->DJ4_DATINI
	
	ElseIf "DJ4_TIPMOT" $ cCampo
		If M->DJ4_TIPFRO == '4' .And. M->DJ4_TIPMOT <> '4' //Todos
			Help(' ',1,'TMSA03506') //A opção TODOS somente poderá ser utilizada para o Tipo de Frota e Tipo de Motorista igual a TODOS.
			lRet:= .F.			
		EndIf
	EndIf

	RestArea(aArSA1)
	RestArea(aArea)

Return(lRet)
/*/-----------------------------------------------------------
{Protheus.doc} PosVldMdl()
Pos Valid do Modelo

Uso: TMSA035

@sample
//PosVldMdl(oModel)

@author Katia.
@since 08/10/2015
@version 1.0
-----------------------------------------------------------/*/
Static Function PosVldMdl(oModel)
Local nOpcx		:= oModel:GetOperation()	
Local oModelDJ4	:= oModel:GetModel("MdFieldDJ4")
Local cQuery    	:= ""
Local cAliasQDJ4	:= GetNextAlias()
Local aArea		:= GetArea() 
Local cRREVGE 	:= oModelDJ4:GetValue('DJ4_RREVGE')
Local cRRECOL 	:= oModelDJ4:GetValue('DJ4_RRECOL')
Local cRRECOT 	:= oModelDJ4:GetValue('DJ4_RRECOT')
Local cRRECAL 	:= oModelDJ4:GetValue('DJ4_RRECAL')
Local cTipFro  	:= oModelDJ4:GetValue('DJ4_TIPFRO')
Local cTipMot  	:= oModelDJ4:GetValue('DJ4_TIPMOT')
Local cDtIniAtu	:= oModelDJ4:GetValue('DJ4_DATINI')
Local cDtFimAtu	:= oModelDJ4:GetValue('DJ4_DATFIM')

Local lRREVGE   := Iif(Empty(oModelDJ4:GetValue('DJ4_RREVGE')),.F.,oModelDJ4:GetValue('DJ4_RREVGE'))
Local lRRECAL   := Iif(Empty(oModelDJ4:GetValue('DJ4_RRECAL')),.F.,oModelDJ4:GetValue('DJ4_RRECAL'))
Local lRRECOL   := Iif(Empty(oModelDJ4:GetValue('DJ4_RRECOL')),.F.,oModelDJ4:GetValue('DJ4_RRECOL'))
Local lRRECOT   := Iif(Empty(oModelDJ4:GetValue('DJ4_RRECOT')),.F.,oModelDJ4:GetValue('DJ4_RRECOT'))
	
Local lRet        := .T.
Local lExiste     := .F.
Local cRetRRE     := ""
Local cMV_TMSRRE  := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza

	
If nOpcx == MODEL_OPERATION_INSERT .Or. nOpcx == MODEL_OPERATION_UPDATE

	//--- Se nenhum dos campos Abrangencia estiver marcado, solicita marcacao.
	If !lRREVGE .And. !lRRECAL .And. !lRRECOL .And. !lRRECOT
		lRet:= .F.
		Help(' ',1,'TMSA03504')  //Obrigatorio informar a Abrangencia da RRE !
	EndIf
	 
	//--- Verifica se existe RRE vigente para a abrangencia 
	If lRet .And. (lRRECAL .Or. lRRECOL .Or. lRRECOT)
		lRet:= TMSA035ABR(oModelDJ4:GetValue('DJ4_CODCLI'), oModelDJ4:GetValue('DJ4_LOJCLI'),;
		oModelDJ4:GetValue('DJ4_CODRRE'),cDtIniAtu,cDtFimAtu,lRRECAL,lRRECOL,lRRECOT,@cRetRRE)
		If !lRet
			Help(' ',1,'TMSA03505',,STR0016 + "-" + AllTrim(RetTitle('DJ4_CODRRE'))+ ': '+ cRetRRE ,09,01)  //Este cliente ja possui uma Regra de Restrição de Embarque Vigente para esta Abrangencia.
		EndIf
	EndIf
	
	If lRet
		cCodRRE:= ""
		//-- Verifica se existe RRE vigentes
		cQuery := ""
		cQuery += "SELECT DJ4_DATINI, DJ4_DATFIM, DJ4_CODRRE, DJ4_CODCLI, DJ4_LOJCLI, DJ4_TIPFRO, DJ4_TIPMOT, "
		cQuery += " DJ4_RREVGE, DJ4_RRECOL, DJ4_RRECOT, DJ4_RRECAL "
		cQuery += " FROM " + RetSqlName("DJ4")+ " DJ4 "
		cQuery += " WHERE DJ4.DJ4_FILIAL = '" + xFilial('DJ4') + "' "
		cQuery += " AND DJ4.DJ4_CODCLI = '" + oModelDJ4:GetValue('DJ4_CODCLI') + "' "
		cQuery += " AND DJ4.DJ4_LOJCLI = '" + oModelDJ4:GetValue('DJ4_LOJCLI') + "' "
		cQuery += " AND DJ4.DJ4_CODRRE <> '" + oModelDJ4:GetValue('DJ4_CODRRE')  + "' "
		cQuery += " AND (		DJ4.DJ4_DATFIM = ' ' " 
		cQuery += " 			OR  (  "
		cQuery += "					('" + DtoS(cDtIniAtu) + "'  >= DJ4.DJ4_DATINI AND  '" + DtoS(cDtIniAtu) + "'  <= DJ4.DJ4_DATFIM) OR "
		cQuery += " 					('" + DtoS(cDtFimAtu) + "'  >= DJ4.DJ4_DATINI AND  '" + DtoS(cDtFimAtu) + "'  <= DJ4.DJ4_DATFIM) OR "
		cQuery += " 					('" + DtoS(cDtIniAtu) + "'  <= DJ4.DJ4_DATINI AND  '" + DtoS(cDtFimAtu) + "'  >= DJ4.DJ4_DATFIM)    "
		cQuery += " 	   			 )  ) "
		
		cQuery += " AND (DJ4.DJ4_TIPFRO = '" + cTipFro + "' " 
		cQuery += " OR DJ4.DJ4_TIPMOT = '" + cTipMot + "' ) "  
				
		cQuery += " AND DJ4.D_E_L_E_T_=' ' "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQDJ4, .F., .T.)
		TcSetField(cAliasQDJ4,"DJ4_DATINI","D",TamSX3("DJ4_DATINI")[1],TamSX3("DJ4_DATINI")[2])
		TcSetField(cAliasQDJ4,"DJ4_DATFIM","D",TamSX3("DJ4_DATFIM")[1],TamSX3("DJ4_DATFIM")[2])
		While (cAliasQDJ4)->(!Eof())
			lExiste:= .F.
		
			//--- Verifica 
			If lRRECAL .And. (cAliasQDJ4)->DJ4_RRECAL = 'T' 
				lExiste:= .T.
			EndIf
		     
			If lRREVGE .And. (cAliasQDJ4)->DJ4_RREVGE = 'T'
				lExiste:= .T.
			EndIf                             
		
			If lRRECOL .And. (cAliasQDJ4)->DJ4_RRECOL = 'T' 
				lExiste:= .T.
			EndIf                             
		
			If lRRECOT .And. (cAliasQDJ4)->DJ4_RRECOT = 'T'
				lExiste:= .T.
			EndIf
			
			cCodRRE:= (cAliasQDJ4)->DJ4_CODRRE
			
			If lExiste
				Exit
			EndIf
			
			(cAliasQDJ4)->(dbSkip())
		EndDo
		(cAliasQDJ4)->(dbCloseArea())
		
		If lExiste
			Help(' ',1,'TMSA03502',, STR0017 + "-" + AllTrim(RetTitle('DJ4_CODRRE'))+ ': '+ cCodRRE ,09,01) //"Este cliente ja possui uma Regra de Restrição de Embarque Vigente"         
			lRet:= .F. 
		EndIf
	EndIf	
EndIf
	
RestArea(aArea)	
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSA035ABR()
Valida se há mais de uma Regra de Restrição 'valida' para
Abrangencia Cotação, Sol.Coleta e Calculo de Frete
@author Katia.
@since 15/12/2015
@version 1.0
-----------------------------------------------------------/*/
Function TMSA035ABR(cCodCli, cLojCli,cCodRRE,cDtIniAtu,cDtFimAtu,lRRECAL,lRRECOL,lRRECOT,cRetRRE)
Local lRet      := .T.         
Local cQuery    := ""
Local cAliasQry := GetNextAlias()

Default cRetRRE := ""

cQuery := ""
cQuery += "SELECT DJ4_CODRRE, DJ4_RREVGE, DJ4_RRECOL, DJ4_RRECOT, DJ4_RRECAL "
cQuery += " FROM " + RetSqlName("DJ4")+ " DJ4 "
cQuery += " WHERE DJ4.DJ4_FILIAL = '" + xFilial('DJ4') + "' "
cQuery += " AND DJ4.DJ4_CODCLI = '" + cCodCli + "' "
cQuery += " AND DJ4.DJ4_LOJCLI = '" + cLojCli + "' "
cQuery += " AND DJ4.DJ4_CODRRE <> '" + cCodRRE  + "' "
cQuery += " AND (		DJ4.DJ4_DATFIM = ' ' " 
cQuery += " 			OR  (  "
cQuery += "					('" + DtoS(cDtIniAtu) + "'  >= DJ4.DJ4_DATINI AND  '" + DtoS(cDtIniAtu) + "'  <= DJ4.DJ4_DATFIM) OR "
cQuery += " 					('" + DtoS(cDtFimAtu) + "'  >= DJ4.DJ4_DATINI AND  '" + DtoS(cDtFimAtu) + "'  <= DJ4.DJ4_DATFIM) OR "
cQuery += " 					('" + DtoS(cDtIniAtu) + "'  <= DJ4.DJ4_DATINI AND  '" + DtoS(cDtFimAtu) + "'  >= DJ4.DJ4_DATFIM)    "
cQuery += " 	   			 )  ) "
cQuery += " AND DJ4.D_E_L_E_T_=' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
While (cAliasQry)->(!Eof())
	If lRRECAL .And. (cAliasQry)->DJ4_RRECAL = 'T'
		lRet:= .F.		
	EndIf
	If lRRECOT .And. (cAliasQry)->DJ4_RRECOT = 'T'
		lRet:= .F.		
	EndIf                             
	If lRRECOL .And. (cAliasQry)->DJ4_RRECOL = 'T'
		lRet:= .F.				
	EndIf                            
	If !lRet 
		cRetRRE:= (cAliasQry)->DJ4_CODRRE
		Exit
	EndIf	
	(cAliasQry)->(dbSkip())	
EndDo
(cAliasQry)->(dbCloseArea())


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PosVldDJ5
POS-Validação da linha

@author Katia

@since 05/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PosVldDJ5(oGridModel, nLine)
Local lRet       := .T.
Local oModel 	   := oGridModel:GetModel()	// Recebe o Model
Local oModelDJ5  := oModel:GetModel( 'MdGridDJ5' )

If !oModelDJ5:IsDeleted()
	If Empty(oModelDJ5:GetValue("DJ5_CODPRO")) .And. Empty(oModelDJ5:GetValue("DJ5_CODGRP"))
		Help('',1,'TMSA03507',, AllTrim(RetTitle('DJ5_CODGRP')) + ' ' + STR0018 + ' ' + AllTrim(RetTitle('DJ5_CODPRO')),4,1)  //Campo Obrigatorio dos itens da RRE não informado.     
		lRet := .F.
	EndIf	
EndIf

Return lRet
