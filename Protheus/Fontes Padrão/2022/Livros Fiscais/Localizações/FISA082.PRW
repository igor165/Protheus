#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FISA082.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA082
Cadastro MVC para atender o cadastro de Tipo de Comprovante.

@author Leandro Prado
@since 17/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA082()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Tipo de Comprovante.
oBrw:SetAlias( 'CFG')
oBrw:SetMenuDef( 'FISA082' )

oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 17/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return FWMVCMenu( "FISA082" )      
//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Leandro Prado
@since 17/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruCFG := FWFormStruct( 1, 'CFG' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('FISA082',,{|oModel| ValidModel(oModel)},{|oModel| SaveModel(oModel)})

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_CFG', /*cOwner*/, oStruCFG)
oModel:GetModel( 'MODEL_CFG' ):SetPrimaryKey( { 'CFG_FILIAL' , 'CFG_CODIGO'} )

Return oModel             
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Leandro Prado
@since 17/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FWLoadModel( 'FISA082' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruCFG	:= FWFormStruct( 2, 'CFG' )// Cria a estrutura a ser usada na View
Local oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_CFG', oStruCFG, 'MODEL_CFG' )

oView:EnableTitleView( 'VIEW_CFG',  STR0001 ) //Tipo de Comprovante

oView:CreateHorizontalBox( 'FIELDSCFG', 100 )

oView:SetOwnerView( 'VIEW_CFG', 'FIELDSCFG' )

oStruCFG:RemoveField('CFG_DESPEC')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Leandro Prado
@since 08/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local cDespec := ""
Local cEspec := oModel:GetValue( 'MODEL_CFG', 'CFG_ESPEC')
Local nOperation := oModel:GetOperation()

If nOperation <> MODEL_OPERATION_DELETE
	If cEspec = '1'
		cDespec := 'NF'
	ElseIf cEspec = '2'
		cDespec := 'NDC'
	ElseIf cEspec = '3'
		cDespec := 'NCE'
	ElseIf cEspec = '4'
		cDespec := 'NCC'
	ElseIf cEspec = '5
		cDespec := 'NDE'
	ElseIf cEspec = '6'
		cDespec := 'NDP'
	ElseIf cEspec = '7'
		cDespec := 'NDI'
	ElseIf cEspec = '8'
		cDespec := 'NCP'
	ElseIf cEspec = '9'
		cDespec := 'NCI'
	EndIf
	
	oModel:LoadValue( 'MODEL_CFG', 'CFG_DESPEC', cDespec )   
EndIf
	
FwFormCommit( oModel )	
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Funcao de validação do modelo, chamada no final, no momento da gravacao do modelo

@return oView - Objeto da View MVC

@author Leandro Prado
@since 31/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )
Local lRet			:=	.T.
Local nOperation	:= oModel:GetOperation()
Local cRG1415		:= oModel:GetValue( 'MODEL_CFG', 'CFG_RG1415')
Local cDespec		:= PADR(oModel:GetValue( 'MODEL_CFG', 'CFG_DESPEC'), 5, ' ')
Local cModulo		:= oModel:GetValue( 'MODEL_CFG', 'CFG_MODULO')
Local cCompro		:= oModel:GetValue( 'MODEL_CFG', 'CFG_COMPRO')
Local cEspec		:= oModel:GetValue( 'MODEL_CFG', 'CFG_ESPEC')
Local cTipo		:= oModel:GetValue( 'MODEL_CFG', 'CFG_TIPO')
Local cSerie		:= oModel:GetValue( 'MODEL_CFG', 'CFG_SERIE')
Local aArea 		:=	GetArea()
Local nTamSerF1	:=   TamSX3("F1_SERIE")[1]
Local nTamSerF2	:=   TamSX3("F2_SERIE")[1]
Local nI:=0
// Se deletando, verifica se existe SF1 ou SF2 usando RG1415;
If nOperation == MODEL_OPERATION_DELETE
	("SF1")->(DbSetOrder(6))
	If ("SF1")->(MsSeek(xFilial("SF1")+cDespec+cRG1415))
		If  cPaisLoc == "ARG"  
			While !SF1->(EOF()) .And. xFilial("SF1") + SF1->F1_ESPECIE + SF1->F1_RG1415  == xFilial("SF1")+cDespec+cRG1415 
				IF SF1->F1_SERIE == Padr(cSerie,nTamSerF1)
					lRet := .F.
					EXIT
				ENDIF
				    SF1->(dbSkip())
				EndDo
		 Else
		 	lRet := .F.
		 EndIf
	Else
		("SF2")->(DbSetOrder(9)) 
		If ("SF2")->(MsSeek(xFilial("SF2")+cDespec+cRG1415))
			If  cPaisLoc == "ARG"  
				While !SF2->(EOF()) .And. xFilial("SF2") + SF2->F2_ESPECIE + SF2->F2_RG1415  == xFilial("SF2")+cDespec+cRG1415  
					IF SF2->F2_SERIE == Padr(cSerie,nTamSerF2)
					 	lRet := .F.
					 	EXIT
				    ENDIF
				    SF2->(dbSkip())
				EndDo
			Else
				lRet := .F.
			EndIf
			
		EndIf
	EndIf
	
	If !(lRet)
		Help( ,,"FISA082EXCLUIR",,, 5, 0 )
	EndIf
ElseIf nOperation == MODEL_OPERATION_INSERT
	lRet := F082VldUni( "CFG" , cModulo + cEspec + cSerie + cTipo + cRG1415 , 3)
	If lRet	
		("CFG")->(DbSetOrder(1))
		If ("CFG")->(MsSeek(xFilial("CFG") + cModulo+cEspec+cCompro+cSerie))  
			lRet := .F.
			RestArea(aArea)
		EndIf
	EndIf
	If !(lRet)
		Help( ,,"FISA082INCLUIR",,, 5, 0 )
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F082VldUni
Funcao generica de validacao da chave unica da tabela utilizando MsSeek 
	
@param	cAlias - Alias da tabela para o MsSeek
		nOrder - Indice do seek
		cChave - Chave 

@return lOk - 
			.T. Para validacao OK
			.F. Para validacao NAO OK

@author Leandro Prado
@since 16/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function F082VldUni( cAlias , cChave , nOrder)
Local	lOk		   := .T.

Default nOrder :=	3
Default cChave :=	""
Default cAlias := ""	  

(cAlias)->(DbSetOrder(nOrder))
If (cAlias)->(MsSeek(xFilial("CFG") + cChave))  
	lOk := .F.
  	Help( ,,"FISA082INCLUIR",,, 1, 0 )                                     
EndIf

Return lOk