#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA089.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA089
Cadastro MVC para atender o cadastro do Período Dispensado da EFD - Contribuições.

@author Simone dos Santos de Oliveira
@since 05.05.2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA089()

	Local   oBrowse
	Private EAI_MESSAGE_MVC := ""
	
	//DbSelectarea("CKN")
	
	IF  AliasIndic("CKN") 
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("CKN")
		oBrowse:SetDescription(STR0001) //"Cadastro do Período Dispensado da EFD - Contribuições"
		oBrowse:Activate()
	Else
		Help("",1,"Help","Help",STR0002,1,0) // "Tabela CKN não cadastrada no sistema!"
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Simone dos Santos de Oliveira
@since 05.05.2014
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            

Static Function MenuDef()

	Local aRotina := {}
	
	
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA089' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA089' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA089' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA089' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Simone dos Santos de Oliveira
@since 05.05.2014
@version 1.0

/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	Local oStructCAB := FWFormStruct( 1 , "CKN" )    
	
	oModel	:=	MPFormModel():New('FISA089MOD', ,{ |oModel| ValidForm(oModel) } )
	
	oModel:AddFields( 'FISA089MOD' ,, oStructCAB )	   
	
	oModel:SetPrimaryKey({"CKN_FILIAL"},{"CKN_MESEFD"},{"CKN_ANOEFD"},{"CKN_MESDIS"},{"CKN_ANODIS"})	

	oModel:SetDescription(STR0007) // "Período Dispensado EFD-Contribuições"
	
Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Simone dos Santos de Oliveira
@since 05.05.2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel( "FISA089" )
	Local oStructCAB := FWFormStruct( 2 , "CKN" )	

	oView:SetModel(oModel)

	oView:AddField( "VIEW_CAB" , oStructCAB , 'FISA089MOD')	

	oView:CreateHorizontalBox( "CABEC" , 100 )

	oView:SetOwnerView( "VIEW_CAB" , "CABEC" )	
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidChav
Validação das informações digitadas no form.

@author Simone dos Santos de Oliveira
@since 05.05.2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function ValidChav()

	Local lRet	:=	.T.

	Local cCampo	:=	ReadVar()
	Local cCampo2:=	Substr( cCampo , 4 )
	Local cChv	:=	""
	Local cRet	:=	""	

	If "CKN" == SubStr( cCampo2 , 1 , 3 )
		//Chave UNICA da tabela
		cChv	:=	'FWFLDGET( "CKN_MESEFD" ) + '
		cChv	+=	'FWFLDGET( "CKN_ANOEFD"  ) + '
		cChv	+=	'FWFLDGET( "CKN_MESDIS" ) + '
		cChv	+=	'FWFLDGET("CKN_ANODIS")'
		
	EndIf
	
	//Converto a chamada do FWFLDGET para o campo de memoria "M->"
	cChv	:=	StrTran( cChv , 'FWFLDGET("' + cCampo2 + '")' , cCampo )   
	
	//Executo a macro para retornar as informacoes dos campos do modelo e validar a chave unica
	cRet	:=	&( cChv )
		
	DbSelectArea ("CKN")
	CKN->(DbSetOrder (1))
	If CKN->(DbSeek(xFilial("CKN")+cRet))		
		lRet := .F.			
		Help("",1,"Help","Help",STR0008,1,0) //"Período dispensado da EFD - Contribuições já cadastrados!"
	EndIF

Return lRet  


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Validação das informações digitadas no form.

@author Rafael.Soliveira
@since 16.10.2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function ValidForm(oModel)

Local lRet	:=	.T.
Local nMes	:= 0
Local nAno	:= 0
Local cMot	:= ""
Local nOp	:=	oModel:GetOperation()


If  (nOp == 3 .Or. nOp == 4)  .And. CKN->(FieldPos("CKN_MTCOMP"))>0 
	nMes	:= Val(oModel:GetValue('FISA089MOD','CKN_MESEFD'))
	nAno	:= Val(oModel:GetValue('FISA089MOD','CKN_ANOEFD'))
	cMot	:= oModel:GetValue('FISA089MOD','CKN_MTCOMP')
	
	//A partir de 01 de agosto de 2017 deve ser informado motivo 
	If Empty(cMot) .And. ((nMes >= 08 .and. nAno >= 2017) .or. nAno >= 2018)
		lRet := .F.			
		Help("",1,"Help","Help",STR0009,1,0) //"A partir de 01 de agosto de 2017 é obrigatório preencher motivo situação."
	EndIF
Endif

Return lRet