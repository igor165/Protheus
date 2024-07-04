#Include "Protheus.ch"
#Include "TMSA017.CH"
#INCLUDE "FWMVCDEF.CH"                 

//===========================================================================================================
/* Responsaveis pelo Cartão OPeradora de Frota
@author  	Leandro Paulino
@version 	P11 R11.80
@build		700120420A
@since 	18/12/2013
@return 	*/
//===========================================================================================================
Function TMSA017( )

Local oMBrowse	:= Nil
                                                                                                                      	
Private aRotina	:= MenuDef()

//===========================================================================================================
// Funcao de BROWSE
//===========================================================================================================
oMBrowse:= FWMBrowse():New()
oMBrowse:SetAlias("DDQ")
oMBrowse:SetDescription( OemToAnsi( STR0001  ) ) //--'Cartão Operadora de Frota'
oMBrowse:Activate()

Return

//===========================================================================================================
/* Retorna o modelo de Dados da rotina Cadastro de Motorista
@author  	Leandro Paulino
@version 	P11 R11.7
@build		700120420A
@since 	10/10/2012
@return 	oModel - Modelo de Dados */
//===========================================================================================================
Static Function ModelDef()

Local oModel		:= Nil
Local oStruDDQ		:= FwFormStruct( 1, "DDQ" )

oModel	:= MpFormModel():New( "Tmsa017", ,{|| OS040VldId('02')} ,  { |oModel| CommitMdl( oModel ) }, /*bCancel*/ )
oModel:SetDescription( OemToAnsi(STR0001) )	 //"Cartão Operadora de Frota"
oModel:AddFields( "TMSA017_DDQ", Nil, oStruDDQ )
oModel:SetPrimaryKey( { "DDQ_FILIAL", "DDQ_CODFOR", "DDQ_LOJFOR", "DDQ_CGC" } )

Return( oModel )                                                                           

//===========================================================================================================
/* Retorna a View (tela) da rotina Cadastro Cartão Operadora de Frota
@author  	Leandro Paulino
@version 	P11 R11.7
@build		700120420A
@since 	10/10/2012
@return 	oView -  */
//===========================================================================================================
Static Function ViewDef()

Local oModel := FwLoadModel("TMSA017")
Local oView := Nil

oView := FwFormView():New()
oView:SetModel(oModel)
oView:AddField("TMSA017_DDQ", FWFormStruct(2,"DDQ"))
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("TMSA017_DDQ","TELA")

Return(oView)

//===========================================================================================================
/* Gravação do Model
@author  	Leandro Paulino
@version 	P11 R11.7
@build		700120420A
@since 	10/10/2012
@return 	lRet */
//===========================================================================================================
Static Function CommitMdl( oMdl )

Local lRet 		:= .T.
Local aArea		:= DDQ->( GetArea() )

lRet := FwFormCommit( oMdl )

If ExistBlock("TA017GRV")
	ExecBlock("TA017GRV",.F.,.F.,{nOpc})
EndIf

RestArea( aArea )

Return( lRet )

//===========================================================================================================
/* Retorna as operações disponiveis para o Cadastramento dos Responsaveis pelo Cartão
@author  	Leandro Paulino
@version 	P11 R11.80
@build		700120420A
@since 	18/12/2013
@return 	aRotina - Array com as opçoes de Menu */
//===========================================================================================================
Static Function MenuDef()

Local lTA017BRW	:= ExistBlock("TA017BRW")

Local aRotina		:= {{ 'Pesquisar'	,		"AxPesqui"				,0 , 1,,.F. },;  	//"Pesquisar"
							{ 'Visualizar'	,		"VIEWDEF.TMSA017"		,0 , 2 },;  		//"Visualizar"
							{ 'Incluir'		,		"VIEWDEF.TMSA017"		,0 , 3 },;  		//"Incluir"
							{ 'Alterar'		,		"VIEWDEF.TMSA017"		,0 , 4 },;  		//"Alterar"
							{ 'Excluir'		,		"VIEWDEF.TMSA017"		,0 , 5 } }  		//"Excluir"

If	lTA017BRW
	aRotUser := ExecBlock("TA017BRW",.f.,.f.)
	If	ValType(aRotUser) == "A"
		aEval(aRotUser,{|x| AAdd(aRotina,x)})
	EndIf
EndIf
						
Return( aRotina ) 


//=============================================
/* Valida o CPF/CNPJ do Responsável pelo Cartão
@author  Leandro Paulino
@version P11 R11.80
@build	700120420A
@since 	18/12/2013
@return 	Logico */
//=============================================
Function TmsA017CGC()                                                              
Local lRet   := .T.
Local aArea  := GetArea()

If !CGC(M->DDQ_CGC)
	lRet := .F.
EndIf

RestArea( aArea )

Return( lRet )

//=============================================
/* Validação dos campos da tabela DDQ
@author  Leandro Paulino
@version P11 R11.80
@build	700120420A
@since 	18/12/2013
@return 	Logico */
//=============================================
Function TMsa017Vld()                             
Local lRet := .T.

If !Empty(M->DDQ_CODFOR) .And. !Empty(M->DDQ_LOJFOR)
	SA2->(DbSetOrder(1))
	If SA2->(MsSeek(xFilial("SA2")+M->DDQ_CODFOR+M->DDQ_LOJFOR))
		If SA2->A2_MSBLQL == "1"
			HELP(" ",1,"REGBLOQ")
			lRet := .F.
		EndIf
	Else
		HELP(" ",1,"REGNOIS")
		lRet := .F.
	EndIf
EndIf

Return  lRet 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA017SCAºAutor  ³Marcelo Nunes       º Data ³  16/11/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta status cartao pamcard.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Valid do campo DDQ_IDCART                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA017SCA()                             
Local lRet := .T.
Local cCodFor   := M->DDQ_CODFOR
Local cLojFor   := M->DDQ_LOJFOR
Local cIdOpe    := M->DDQ_IDCART
Local aConsCard := {}

	M->DDQ_STATUS := ' '
  	aRetCNPJ := PamCNPJEmp('02', cFilAnt)
	AAdd (aConsCard,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
	AAdd (aConsCard,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
	AAdd (aConsCard,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
	AAdd (aConsCard,{'viagem.cartao.numero', AllTrim( cIdOpe ) } )

	lRet := PamFindCar(aConsCard,,.T.,,.T.)

Return  lRet
