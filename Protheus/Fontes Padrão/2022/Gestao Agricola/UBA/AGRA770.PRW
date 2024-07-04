#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"
#include "agra770.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGRA770   ºAutor  ³Ricardo Tomasi      º Data ³  12/07/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cadastro de Usuario x Balanca		                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Clientes Totvs                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AGRA770()
	Local oMBrowse	:= Nil
	
	AcertoBalanca()
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "DX6" )		//Usuário x Balança
	oMBrowse:SetDescription( STR0001 )
	oMBrowse:AddLegend( "DX6_STATUS=='1'", "GREEN", STR0002)
	oMBrowse:AddLegend( "DX6_STATUS=='2'", "RED"  , STR0003)
	
	//--Realiza o acerto do campo código 
    If DX6->(ColumnPos("DX6_CODIGO")) > 0
       AGRA770AC()
    EndIf
	
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef   ºAutor  ³Ricardo Tomasi      º Data ³  12/07/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao auxiliar para criacao do menu do browser.            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Clientes Totvs                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0004	, 'PesqBrw'        , 0, 1, 0, .T. } )	//Pesquisar
	aAdd( aRotina, { STR0005	, 'ViewDef.AGRA770', 0, 2, 0, .T. } )	//Visualizar
	aAdd( aRotina, { STR0006	, 'ViewDef.AGRA770', 0, 3, 0, .T. } )	//Incluir
	aAdd( aRotina, { STR0007	, 'ViewDef.AGRA770', 0, 4, 0, .T. } )	//Alterar
	aAdd( aRotina, { STR0008	, 'ViewDef.AGRA770', 0, 5, 0, .T. } )	//Excluir
	aAdd( aRotina, { STR0009	, 'ViewDef.AGRA770', 0, 8, 0, .T. } )	//Imprimir
	aAdd( aRotina, { STR0010    , 'ViewDef.AGRA770', 0, 9, 0, .F. } )	//Copiar

Return aRotina


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ModelDef  ºAutor  ³Ricardo Tomasi      º Data ³  12/07/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Modelo de dados da rotina							          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Clientes Totvs                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ModelDef()
	Local oStruDX6 := FWFormStruct( 1, 'DX6' )
	Local oModel := MPFormModel():New( 'AGRA770' , /*bPre*/, /*bPost*/ {| oModel | PosModelo( oModel ) } , /*bCommit*/, /*bCancel*/ )

	oModel:AddFields( 'DX6UNICO', Nil, oStruDX6 )
	oModel:SetDescription( STR0011 )
	oModel:GetModel( 'DX6UNICO' ):SetDescription( STR0011 )
	oModel:SetPrimaryKey({"DX6_FILIAL","DX6_CODIGO"})
	
	//--Certificar que o campo não será obrigatorio...ajustes do UPDDISTR
	oStruDX6:SetProperty( "DX6_CODUSU" ,MODEL_FIELD_OBRIGAT, .F.)
Return oModel


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ViewDef   ºAutor  ³Ricardo Tomasi      º Data ³  12/07/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Modelo de visualização da rotina				              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Clientes Totvs                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ViewDef()
	Local oStruDX6 := FWFormStruct( 2, 'DX6' )
	Local oModel   := FWLoadModel( 'AGRA770' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_DX6', oStruDX6, 'DX6UNICO' )
	oView:CreateHorizontalBox( 'UNICO', 100 )
	oView:SetOwnerView( 'VIEW_DX6', 'UNICO' )
	
	oView:SetFieldAction( 'DX6_MODAL', { |oView| AGRA770WHN(oView) } )

Return oView


/*/{Protheus.doc} PosModelo
//-- Bloco de código de pós-validação do modelo, equilave ao "TUDOOK". 

@author 	ana.olegini
@since 		30/04/2018
@param 		oModel,		object, Modelo do Objeto
@return 	lRetorno, 	Logico, Retorna se verdadeito ou falso
@example
(examples)
@see (links_or_references)
/*/
Static Function PosModelo( oModel )
	Local lRetorno		:= .T.
	Local nOperation	:= oModel:GetOperation()
		
	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		If Empty( oModel:GetValue( "DX6UNICO", "DX6_CODUSU" ) ) .AND. Empty( oModel:GetValue( "DX6UNICO", "DX6_GRPUSR" ) )
			Help(" ",1,".AGRA77000001.")	//Os campos de usuário e grupo de usuário estão vazios.#Favor informar um usuário ou um grupo de usuário para o vínculo com a balança.
			lRetorno := .F.
		EndIf
	EndIf
	
Return lRetorno


/*/{Protheus.doc} AGRA770GP
//-- Valida se existe o grupo de usuario informado
//-- Função encontra-se na SX3 - X3_VALID do campo DX6_GRPUSR

@author 	ana.olegini
@since 		30/04/2018
@return 	lRetorno, 	Logico, Retorna se verdadeito ou falso
@example
(examples)
@see (links_or_references)
/*/
Function AGRA770GP()
	Local  lRetorno := .F.
	
	If Empty( FWFldGet('DX6_CODUSU') )
		PswOrder(1)
		If PswSeek(FWFldGet('DX6_GRPUSR'), .F.)
		    lRetorno := .T.
		Else
		    Help(" ",1,"REGNOIS")		//PADRAO SISTEMA - Não existe registro relacionado a este código. 
		EndIf
	Else
		Help(" ",1,".AGRA77000002.")	//Não é permitido informar o campo grupo de usuário se o campo de usuário está preenchido.#Favor informar usuário ou grupo de usuário.
	EndIf
	
Return lRetorno


/*/{Protheus.doc} AGRA770US
//-- Valida se o usuario pode ser informado
//-- Função encontra-se na SX3 - X3_VALID do campo DX6_CODUSU

@author 	ana.olegini
@since 		30/04/2018
@return 	lRetorno, 	Logico, Retorna se verdadeito ou falso
@example
(examples)
@see (links_or_references)
/*/
Function AGRA770US()
	Local lRetorno := .T.

	If .NOT. Empty( FWFldGet('DX6_GRPUSR') )
		Help(" ",1,".AGRA77000003.")	//Não é permitido informar o campo de usuário se o campo grupo de usuário está preenchido.#Favor informar usuário ou grupo de usuário.
		lRetorno := .F.
	EndIf
Return lRetorno


/*/{Protheus.doc} AGRA770BL
//-- Valida se existe a balança e se já possui algun vinculo
//-- Retorno de mensagens padrão
//-- Função encontra-se na SX3 - X3_VALID do campo DX6_CODBAL

@author 	ana.olegini
@since 		30/04/2018
@return 	lRetorno, 	Logico, Retorna se verdadeito ou falso
@example
(examples)
@see (links_or_references)
/*/
Function AGRA770BL()
	Local  lRetorno := .T.
	
	lRetorno := ExistCpo( "DX5", FWFldGet('DX6_CODBAL') ,1)
	
	If lRetorno .AND. .NOT. Empty(FWFldGet('DX6_CODUSU'))
		lRetorno := ExistChav("DX6", FWFldGet('DX6_CODUSU') + FWFldGet('DX6_CODBAL') ,1) 
	EndIf
	If lRetorno .AND. .NOT. Empty(FWFldGet('DX6_GRPUSR'))
		lRetorno := ExistChav("DX6", FWFldGet('DX6_GRPUSR') + FWFldGet('DX6_CODBAL') ,3) 
	EndIf
Return lRetorno

/*/{Protheus.doc} AGRA770AC
//--Realiza o acerto no campo de código com o sequencial

@author  ana.olegini
@since 	 02/05/2018
@return  lRetorno, 	Logico, Retorna se verdadeito ou falso
@example
(examples)
@see (links_or_references)
/*/
Function AGRA770AC()
	Local lRetorno 	:= .T.
	Local aArea		:= GetArea()
	
	dbSelectArea("DX6")
	dbGoTop()
	While DX6->(!Eof()) 
		
		If Empty( DX6->DX6_CODIGO )
			RecLock("DX6",.F.)
				DX6->DX6_CODIGO := GETSXENUM("DX6","DX6_CODIGO")
		    MsUnLock()	
	    EndIf 
		DX6->(dbSkip())
	EndDo
	DX6->(dbCloseArea())
    
    RestArea( aArea )
Return lRetorno


/*{Protheus.doc} AGRA770WHN
Função para dicionário [SX3] - validação para limpar os campos de data e hora 
Função encontra-se no campo X3_WHEN dos campos da tabela DX6: 
- DX6_DTINI - DX6_DTFIM - DX6_HRINI - DX6_HRFIM

@author 	ana.olegini
@since 		09/05/2018
@return 	Sequência da Operação
*/
Static Function AGRA770WHN(oView)
	Local oField	:= FWModelActive()	
	Local oDX6		:= oField:GetModel( "DX6UNICO" )
	Local lRetorno  := .T.

	//-- Modalidade - 0=Automatico 1=Manual 2=Ambas
	If oDX6:GetValue("DX6_MODAL") == "0" .AND. DX6->(ColumnPos("DX6_DTINI")) > 0 .AND. DX6->(ColumnPos("DX6_HRINI")) > 0 .AND.;
	 	DX6->(ColumnPos("DX6_DTFIM")) > 0 .AND. DX6->(ColumnPos("DX6_HRFIM")) > 0
		oDX6:LoadValue("DX6_DTINI" , cTod('//'))
		oDX6:LoadValue("DX6_HRINI" , "")
		oDX6:LoadValue("DX6_DTFIM" , cTod('//'))
		oDX6:LoadValue("DX6_HRFIM" , "")
	EndIf
	oView:Refresh()	
Return lRetorno

/*{Protheus.doc} AcertoBalanca
Acerto de campos - temporario
Responsável por fazer a inserção dos codigos unicos caso os registros não tenham
@author 	felipe.mendes
@since 		25/01/2019
*/
Static Function AcertoBalanca()

	if DX6->(ColumnPos("DX6_DTINI")) > 0 .AND. DX6->(ColumnPos("DX6_HRINI")) > 0 .AND.;
	 	DX6->(ColumnPos("DX6_DTFIM")) > 0 .AND. DX6->(ColumnPos("DX6_HRFIM")) > 0
		DbSelectArea("DX6")
		DbGoTop()
		While DX6->(!Eof()) 
		
			If DX6->DX6_MODAL <> '0' .AND. RecLock("DX6", .F.)
				If Empty(DX6->DX6_DTINI)
					DX6->DX6_DTINI := dDatabase
				EndIf
				If Empty(DX6->DX6_HRINI)
					DX6->DX6_HRINI := SUBSTR(TIME(), 1, 2) + ":" + SUBSTR(TIME(), 4, 2)  
				EndIf
				If Empty(DX6->DX6_DTFIM)
					DX6->DX6_DTFIM := StoD("20991231")
				EndIf
				If Empty(DX6->DX6_HRFIM)
					DX6->DX6_HRFIM := "23:59"
				EndIf
			EndIf						
			DX6->(MsUnlock())
			DX6->(DbSkip())
		EndDo
	endIf


Return 
