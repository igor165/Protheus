#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FINA590A.ch'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/* {Protheus.doc} FINA590A

Tela de Manutenção de Comprovante

@Author		rodrigo.pirolo

@Since		11/06/2015
@Sample		FINA590A()
@Version	V12.1.6
@Project 	P12
@menu		SIGAFIN>Atualizações>Contas a Pagar>Manutenção de Borderô
@Return		Nil
@history
*/
//-------------------------------------------------------------------

Function FINA590A()

Local oBrws
Local aArea		:= GetArea()
Local aRotina	:= MenuDef()

oBrws := FWMBrowse():New()
oBrws:SetAlias( 'FRY' )
oBrws:SetDescription( STR0001 )//STR0001 "Manutenção de Comprovante"
oBrws:Activate()

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/* {Protheus.doc} MenuDef

MenuDef da Tela de Manutenção de Comprovante

@author		rodrigo.pirolo

@since		11/06/2015
@Sample		Local aRotina	:= MenuDef()
@Version	V12.1.6
@Project 	P12
@Return		aRotina
*/
//-------------------------------------------------------------------

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0002	Action "VIEWDEF.FINA590A" OPERATION 2 ACCESS 0//STR0002 'Visualizar'
ADD OPTION aRotina Title STR0003	Action "VIEWDEF.FINA590A" OPERATION 3 ACCESS 0//STR0003 'Incluir'
ADD OPTION aRotina Title STR0004	Action "VIEWDEF.FINA590A" OPERATION 4 ACCESS 0//STR0004 'Alterar'
ADD OPTION aRotina TITLE STR0005	Action "VIEWDEF.FINA590A" OPERATION 5 ACCESS 0//STR0005 'Excluir'

Return(aRotina)

//-------------------------------------------------------------------
/* {Protheus.doc} ModelDef
Definição do modelo de Dados

@author		rodrigo.pirolo

@since		11/06/2015
@Sample		Local oModel := ModelDef()
@Version	V12.1.6
@Project 	P12
@Return		oModel
*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oModel 
Local oStrFRY:= FWFormStruct(1,'FRY')
Local oStrSEA:= FWFormStruct(1,'SEA')

oModel := MPFormModel():New('FINA590A',,,)

oModel:addFields('FIELDFRY', , oStrFRY)

oStrSEA:SetProperty('EA_FORNECE', MODEL_FIELD_VIRTUAL, .T.)

oStrSEA:RemoveField( 'EA_VERSAO' )
oStrSEA:RemoveField( 'EA_CLVLCR' )
oStrSEA:RemoveField( 'EA_ITEMC' )
oStrSEA:RemoveField( 'EA_CCC' )
oStrSEA:RemoveField( 'EA_CREDIT' )
oStrSEA:RemoveField( 'EA_CLVLDB' )
oStrSEA:RemoveField( 'EA_ITEMD' )
oStrSEA:RemoveField( 'EA_CCD' )
oStrSEA:RemoveField( 'EA_DEBITO' )
oStrSEA:RemoveField( 'EA_CONTANT' )
oStrSEA:RemoveField( 'EA_AGEANT' )
oStrSEA:RemoveField( 'EA_PORTANT' )
oStrSEA:RemoveField( 'EA_FILORIG' )
oStrSEA:RemoveField( 'EA_OCORR' )
oStrSEA:RemoveField( 'EA_SITUANT' )
oStrSEA:RemoveField( 'EA_SALDO' )
oStrSEA:RemoveField( 'EA_SITUACA' )
oStrSEA:RemoveField( 'EA_TRANSF' )
oStrSEA:RemoveField( 'EA_TIPOPAG' )
oStrSEA:RemoveField( 'EA_MODELO' )
oStrSEA:RemoveField( 'EA_NUMCON' )
oStrSEA:RemoveField( 'EA_CART' )
oStrSEA:RemoveField( 'EA_DATABOR' )
oStrSEA:RemoveField( 'EA_AGEDEP' )
oStrSEA:RemoveField( 'EA_PORTADO' )


oStrSEA:SetProperty('EA_FORNECE',MODEL_FIELD_NOUPD,.T.)
oModel:addGrid('GRIDSEA', 'FIELDFRY', oStrSEA, {|| .T.})

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'GRIDSEA', { { 'EA_FILIAL' ,  'xFilial( "SEA" )' }  ,  ; 
                                   { 'EA_NUMBOR' ,  'FRY_BORDER'      }  ,  ; 
                                   { 'EA_CART',  'FRY_RECPAG'        }  ,  ;
                                   { 'EA_VERSAO',  'FRY_VERSAO'        }} ,  ;
                                      SEA->( IndexKey( 3 ) ) )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'GRIDSEA' ):SetUniqueLine( { 'EA_PREFIXO' , 'EA_NUM' , 'EA_PARCELA' } )
oModel:GetModel('FIELDFRY'):SetOnlyView( .T. )
oModel:getModel('FIELDFRY'):SetDescription(STR0007)//STR0007 'Cabeçalho do Borderô'
oModel:getModel('GRIDSEA'):SetDescription(STR0006)//STR0006 'Título'

Return oModel

//-------------------------------------------------------------------
/* {Protheus.doc} ViewDef
Definição do interface

@author		rodrigo.pirolo

@since		11/06/2015
@Sample		Local oModel := ModelDef()
@Version	V12.1.6
@Project 	P12
@Return		oView
*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oView
Local oModel := ModelDef()
Local oStrFRY:= FWFormStruct(2, 'FRY')
Local oStrSEA:= FWFormStruct(2, 'SEA')

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('FORMFRY' , oStrFRY,'FIELDFRY' )
oView:AddGrid('FORMSEA' , oStrSEA,'GRIDSEA') 

oStrFRY:RemoveField( 'FRY_PROAPR' )
oStrFRY:RemoveField( 'FRY_USNOME' )
oStrFRY:RemoveField( 'FRY_USUSOL' )
oStrFRY:RemoveField( 'FRY_URNOME' )
oStrFRY:RemoveField( 'FRY_USUCRI' )
oStrFRY:RemoveField( 'FRY_SITBRD' )
oStrFRY:RemoveField( 'FRY_RECPAG' )
oStrFRY:RemoveField( 'FRY_STATUS' )
oStrFRY:RemoveField( 'FRY_VERSAO' )
oStrFRY:RemoveField( 'FRY_DVCTA' )
oStrFRY:RemoveField( 'FRY_DVAGE' )
oStrFRY:RemoveField( 'FRY_SITUAC' )
oStrFRY:RemoveField( 'FRY_MODELO' )

oView:CreateHorizontalBox( 'BOXFORMFRY', 25)

oStrSEA:RemoveField( 'EA_CONTANT' )
oStrSEA:RemoveField( 'EA_AGEANT' )
oStrSEA:RemoveField( 'EA_PORTANT' )
oStrSEA:RemoveField( 'EA_TIPOPAG' )
oStrSEA:RemoveField( 'EA_MODELO' )
oStrSEA:RemoveField( 'EA_DATABOR' )
oStrSEA:RemoveField( 'EA_NUMBOR' )
oStrSEA:RemoveField( 'EA_AGEDEP' )
oStrSEA:RemoveField( 'EA_PORTADO' )
oStrSEA:RemoveField( 'EA_TIPOPAG' )
oStrSEA:RemoveField( 'EA_MODELO' )
oStrSEA:RemoveField( 'EA_DATABOR' )
oStrSEA:RemoveField( 'EA_AGEDEP' )
oStrSEA:RemoveField( 'EA_PORTADO' )
oStrSEA:RemoveField( 'EA_VERSAO' )
oStrSEA:RemoveField( 'EA_CONTANT' )
oStrSEA:RemoveField( 'EA_AGEANT' )
oStrSEA:RemoveField( 'EA_PORTANT' )

oStrSEA:SetProperty('EA_LOJA',MVC_VIEW_CANCHANGE,.F.)
oStrSEA:SetProperty('EA_PARCELA',MVC_VIEW_CANCHANGE,.F.)
oStrSEA:SetProperty('EA_NUM',MVC_VIEW_CANCHANGE,.F.)
oStrSEA:SetProperty('EA_PREFIXO',MVC_VIEW_CANCHANGE,.F.)

oView:CreateHorizontalBox( 'BOXFORMSEA', 75)

oView:SetOwnerView('FORMSEA','BOXFORMSEA')
oView:SetOwnerView('FORMFRY','BOXFORMFRY')

oView:SetNoInsertLine('FORMSEA')
oView:SetNoDeleteLine('FORMSEA')

oView:EnableTitleView('FORMSEA' , STR0006 ) //STR0006 'Títulos'
oView:EnableTitleView('FORMFRY' , STR0007 ) //STR0007 'Cabeçalho do Borderô'

Return oView

//-------------------------------------------------------------------
/* {Protheus.doc} F590ACpv

Função para retorno de informação sobre se o Titulo
precisa (1) de comprovante de pagamento ou se não precisa (2).

@Author		rodrigo.pirolo

@Since		11/06/2015
@Sample		cCpvPgt := F590ACpv(SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_NATUREZ)
@Version	V12.1.6
@Project 	P12
@Param		cFornece = Fornecedor cadastrado no Titulo
@Param		cLoja = Loja do Fornecedor cadastrada no Titulo
@Param		cNatureza = Natureza cadastrada no Titulo
@Return		cCpvPgt = 1 = Precisa de Comprovante de Pagamento
@Return		cCpvPgt = 2 = Não precisa de Comprovante de Pagamento
*/
//-------------------------------------------------------------------

Function F590ACpv(cFornece,cLoja,cNatureza)

Local cCpvPgt		:= ""
Local cCpvPgtSA2	:= ""
Local cCpvPgtSED	:= ""

If !Empty(cFornece) .AND. !Empty(cNatureza)

	DbSelectArea("SA2")
	SA2->( DbSetOrder(1) )
	
	If DbSeek( xFilial("SA2") + cFornece + cLoja )
		cCpvPgtSA2 := SA2->A2_CPVPGT
	EndIf
	
	DbSelectArea("SED")
	SED->( DbSetOrder(1) )
	
	If DbSeek( xFilial("SED") + cNatureza )
		cCpvPgtSED := SED->ED_CPVPGT
	EndIf
	
	If !Empty(cCpvPgtSA2) .AND. !Empty(cCpvPgtSED)
		
		If cCpvPgtSA2 == "1" .AND. cCpvPgtSED == "1"
			cCpvPgt	:= "1"
		ElseIf cCpvPgtSA2 == "1" .AND. cCpvPgtSED == "2"
			cCpvPgt	:= "1"
		ElseIf cCpvPgtSA2 == "2" .AND. cCpvPgtSED == "1"
			cCpvPgt	:= "1"
		ElseIf cCpvPgtSA2 == "2" .AND. cCpvPgtSED == "2"
			cCpvPgt	:= "2"
		EndIf
		
	ElseIf Empty(cCpvPgtSA2) .AND. Empty(cCpvPgtSED)
		
		cCpvPgt	:= "2"
		
	ElseIf !Empty(cCpvPgtSA2) .AND. Empty(cCpvPgtSED)
		
		If cCpvPgtSA2 == "1"
			cCpvPgt	:= "1"
		Else
			cCpvPgt	:= "2"
		EndIf
		
	ElseIf Empty(cCpvPgtSA2) .AND. !Empty(cCpvPgtSED)
		
		If cCpvPgtSED == "1"
			cCpvPgt	:= "1"
		Else
			cCpvPgt	:= "2"
		EndIf
		
	EndIf
EndIf

Return cCpvPgt

//-------------------------------------------------------------------
/* {Protheus.doc} FINA590A

Tela de Manutenção de Comprovante

@Author		rodrigo.pirolo

@Since		11/06/2015
@Sample		FINA590A()
@Version	V12.1.6
@Project 	P12
@menu		SIGAFIN>Atualizações>Contas a Pagar>Manutenção de Borderô
@Return		Nil
@history
*/
//-------------------------------------------------------------------

Function F590AExec()

FWExecView(STR0001, 'FINA590A', 4, , { || .T. } )  //STR0001 "Manutenção de Comprovantes"

Return

/*
{Protheus.doc} F590AGRV

Função para Gravar a alteração do campo EA_CPVPGT.

@Author		Rodrigo Pirolo
@Since		11/06/2015
@Sample		F590AGrid( oModel )
@Version	P12.1.6
@Project	P12
@menu
@Param		oModel, objeto,modelo de dados ativo (Painel de Tarifa)
@Return		lRet
*/

Static Function F590AGRV( oModel )

Local oModelFRY	:= oModel:GetModel("FIELDFRY")	// Recebe o Modelo da FRY
Local oModelSEA	:= oModel:GetModel("GRIDSEA")	// Recebe o Modelo da SEA

Local lRet		:= .F.

If oModel:VldData()

	oModel:CommitData()
	lRet := .T.
	
Else

	lRet := .F.

EndIf

Return lRet