#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECA950.CH" 
#INCLUDE "FWMVCDEF.CH"

Static cCodLinha := ''

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA950

Rotina de Cadastro de Check-In para a tabela TIM

@sample		TECA920() 

@param	   	Nenhum
@author   	arthur.colado
@version  	V119 
@since    	09/10/2013 
@return   	Nil	
/*/
//--------------------------------------------------------------------

Function TECA950()

	Local oBrowse		:= Nil
	Local cCadastro	:= STR0003	// "Ajustar Check_In"

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias( "TIM" )
	oBrowse:SetDescription( cCadastro )
	oBrowse:DisableDetails()
	oBrowse:Activate()			

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Define o menu funcional. 

@sample    	MenuDef() 

@param	   	Nenhum
@author   	arthur.colado
@version  	V119
@since    	09/10/2013 
@return   	aRotina
/*/
//--------------------------------------------------------------------

Static Function MenuDef()

	Local aRotina	:= FWMVCMenu( "TECA950" )

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definição do Model

@sample 	ModelDef() 

@param	   	Nenhum
@author   	arthur.colado
@version  	V119
@since    	09/10/2013 
@return   	oModel

/*/
//--------------------------------------------------------------------

Static Function ModelDef()
	Local oModel			:= Nil
	Local oStruTIM			:= FWFormStruct(1,'TIM')
	Local bCommit			:= {|| At950Grava(oModel)}
	Local bPosValidacao	:= {|| At950PosValid(oModel)}
	Local aAux				:= {}

	aAux := FwStruTrigger("TIM_MOTIVO","TIM_DESMOT","At950DescMot()",.F.,Nil,Nil,Nil)
	oStruTIM:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

	oModel := MPFormModel():New('TECA950',/*bPreValidacao*/,/*{|oModel|AT710VLD(oModel)}*/,bCommit,/*bCancel*/)

	oModel:AddFields('TIMMASTER',/*cOwner*/,oStruTIM,/*bPreValidacao*/,bPosValidacao,/*bCarga*/,/*bFieldAbp*/)

	oModel:SetPrimaryKey({"TIM_FILIAL","TIM_CODTEC"})

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definição da View

@sample 	ViewDef()

@param	   Nenhum
@author   arthur.colado
@version  V119
@since    09/10/2013 
@return   oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local oModel   	:= FWLoadModel('TECA950')
	Local oStruTIM 	:= FWFormStruct(2,'TIM')

	oView:= FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VIEW_CAB',oStruTIM,'TIMMASTER')
	oView:CreateHorizontalBox('SUPERIOR',100)
	oView:SetOwnerView( 'VIEW_CAB','SUPERIOR' )

return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc}  At950Grava

Grava os dados do cadastro

@sample   At950Grava

@param		Nenhum
@author   	arthur.colado
@version  	V119
@since    	09/10/2013 
@return   	lRet
/*/
//--------------------------------------------------------------------

Static Function At950Grava(oModel)
	Local lRet			:= .T.
	Local cEvento		:= AllTrim(oModel:GetValue("TIMMASTER","TIM_EVENTO"))
	Local cData		:= oModel:GetValue("TIMMASTER","TIM_DATA")
	Local cHora		:= oModel:GetValue("TIMMASTER","TIM_HORA")
	Local cMotivo		:= oModel:GetValue("TIMMASTER","TIM_MOTIVO")

	dbSelectArea("ABB")
	ABB-> (DbSetOrder (8))//ABB_FILIAL + ABB_CODIGO
 
	If ( ABB->( DbSeek(xFilial("ABB") + cCodLinha )))
		
		cAliasABB := GetNextAlias()
		cAliasBkp := At550GtAls()	

		aQry540 := AT540ABBQry( ABB->ABB_CODTEC, ABB->ABB_CHAVE, ABB->ABB_DTINI, ABB->ABB_DTFIM, ABB->ABB_HRINI, ABB->ABB_HRFIM, ABB->ABB_CODIGO, .T., ABB->ABB_ENTIDA )
	
		If Len(aQry540) > 0 
		
			cQryABB := aQry540[1]

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryABB),cAliasABB)
										
			AT550StAls(cAliasABB)
		
			oMdlManut := FWLoadModel( "TECA550" )	
		
			oMdlManut:SetOperation(MODEL_OPERATION_INSERT)
			lRet := oMdlManut:Activate()
		
			If lRet		
				lRet := lRet .And. oMdlManut:SetValue( 'ABRMASTER', 'ABR_MOTIVO', cMotivo)
			
				If cEvento == "Entrada"
					
					lRet := lRet .And. oMdlManut:SetValue( 'ABRMASTER', 'ABR_DTINI', cData)
					lRet := lRet .And. oMdlManut:SetValue( 'ABRMASTER', 'ABR_HRINI', cHora)
			
				ElseIf cEvento == "Saida"
					
					lRet := lRet .And. oMdlManut:SetValue( 'ABRMASTER', 'ABR_DTFIM', cData)
					lRet := lRet .And. oMdlManut:SetValue( 'ABRMASTER', 'ABR_HRFIM', cHora)
				EndIf
			
				lRet := lRet .And. oMdlManut:SetValue( 'ABRMASTER', 'ABR_OBSERV', 'Ajuste pelo Monitor de Check-In')
			
				lRet := oMdlManut:VldData() .And. oMdlManut:CommitData()
				If ( !lRet )
					aErro   := oMdlManut:GetErrorMessage()
					Help( ,, 'AT950MANUT',, aErro[MODEL_MSGERR_MESSAGE], 1, 0 )
				EndIf
			EndIf
			
			oMdlManut:DeActivate()
			oMdlManut:Destroy()
		At550StAls(cAliasBkp)		
		
		lRet := lRet .And. oModel:SetValue("TIMMASTER","TIM_CODABB",cCodLinha)
		lRet := lRet .And. oModel:SetValue("TIMMASTER","TIM_STATUS","1")
	
		EndIf
	
	EndIf
		
	lRet := lRet .And. FWFormCommit( oModel )

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At950PosValid

Valida os campos para preenchimento obrigatório

@sample   	At950PosValid
@param	   	Nenhum
@author   	arthur.colado
@version  	V119
@since    	09/10/2013 
@return  	lRet
/*/
//--------------------------------------------------------------------

Static Function At950PosValid(oModel)

	Local lRet		:= .T.
	Local cStatus	:= FwFldGet("TIM_STATUS")
	Local dData	:= FwFldGet("TIM_DATA")
	Local cHora	:= FwFldGet("TIM_HORA")
	Local cCodTec	:= FwFldGet("TIM_CODTEC")
	Local cEvento	:= AllTrim(FwFldGet("TIM_EVENTO"))
	Local cLocal	:= FwFldGet("TIM_LOCAL")
	Local cCodAbb	:= FwFldGet("TIM_CODABB")
	Local cMotivo	:= FwFldGet("TIM_MOTIVO")
	Local cAlias	:= GetNextAlias()
	Local dDtIni	:= ""
	Local cHrIni	:= ""
	Local dDtFim	:= ""
	Local cHrFim	:= ""

	If Empty(FwFldGet("TIM_MOTIVO")) 
	
		Help( ,,STR0001,, STR0002, 1, 0 )
		lRet	:= .F.
		
	EndIf


Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc}  At950DescMot

Posiciona os dados da Consulta Padrão na Tabela ABN

@sample   	At950DescMot

@param	   	Nenhum
@author   	arthur.colado
@version  	V119
@since    	09/10/2013 
@return  	cDesc
/*/
//--------------------------------------------------------------------

Function At950DescMot()
	
	Local cDesc	:= ""

	cDesc := Posicione("ABN",1,xFilial("ABN") + FwFldGet("TIM_MOTIVO"),"ABN->ABN_DESC")

Return(cDesc)

//------------------------------------------------------------------------------
/*/{Protheus.doc}  AT950ExecView

Função recebe parametro e chama o FwExecAuto

@sample   	At950DescMot

@param	   	Nenhum
@author   	arthur.colado
@version  	V119
@since    	09/10/2013 
@return  	
/*/
//--------------------------------------------------------------------
Function AT950ExecView(cCodigo)

Local lConfirm := .F.
	
	cCodLinha := cCodigo
	lConfirm := ( FwExecView(" ", "VIEWDEF.TECA950", 4, /*oOwner*/, {||.T.}, /*bOk*/, 30, , ) == 0 )

Return lConfirm



