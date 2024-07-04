#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPC300N.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPC300N()
Cadastro de Terceiros
 
@sample	GTPC300N()
 
@return	oBrowse	Retorna o Cadastro de Terceiros
 
@author	Equipe GTP -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPC300N()

Local oBrowse		:= Nil	

Private aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias('G6Z')
oBrowse:SetDescription(STR0001)	//Cadastro de Terceiros
oBrowse:Activate()

Return ( oBrowse )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	Equipe GTP -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= nil
Local oStruG6Z	:= FWFormStruct(1,'G6Z')
Local bPosValid	:= {|oModel|TP300NTdOK(oModel)}
Local aTrigAux	:= Nil

oModel := MPFormModel():New('GTPC300N', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/ )

aTrigAux := FwStruTrigger("G6Z_TRECUR", "G6Z_TRECUR", "ClearCp300()" )
oStruG6Z:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])

aTrigAux := FwStruTrigger("G6Z_FORNEC", "G6Z_LOJAFO", "Posicione('SA2',1,xFilial('SA2')+FwFldGet('G6Z_FORNEC')+IIF(SA2->A2_COD==FwFldGet('G6Z_FORNEC'),SA2->A2_LOJA,''),'A2_LOJA' )" ) 
oStruG6Z:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])

aTrigAux := FwStruTrigger("G6Z_LOJAFO", "G6Z_NOMFOR", "Posicione('SA2',1,xFilial('SA2')+FwFldGet('G6Z_FORNEC')+FwFldGet('G6Z_LOJAFO') ,'A2_NOME'  )")	
oStruG6Z:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])

oStruG6Z:SetProperty("G6Z_CPF", MODEL_FIELD_VALID, {|oModel|  ( Empty(FwFldGet('G6Z_CPF')) .OR.  CGC(FwFldGet('G6Z_CPF')) )   })

oModel:AddFields('G6ZMASTER',/*cOwner*/,oStruG6Z)
oModel:SetDescription(STR0001)
oModel:GetModel('G6ZMASTER'):SetDescription(STR0002)	//Dados do Terceiro
oModel:SetPrimaryKey({"G6Z_FILIAL","G6Z_CODIGO"})//AJUSTAR 

Return ( oModel )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
 
@sample	ViewDef()
 
@return	oView  Retorna a View
 
@author	Equipe GTP -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= ModelDef() 
Local oView		:= FWFormView():New()
Local oStruG6Z	:= FWFormStruct(2, 'G6Z')

oView:SetModel(oModel)
oView:SetDescription(STR0001) 
oView:AddField('VIEW_G6Z' ,oStruG6Z,'G6ZMASTER')
oView:CreateHorizontalBox('TELA', 100)
oView:SetOwnerView('VIEW_G6Z','TELA')

Return ( oView )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Retorna as opções do Menu
 
@author	Equipe GTP -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.GTPC300N' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPC300N' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPC300N' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.GTPC300N' OPERATION 5 ACCESS 0 // Excluir

Return ( aRotina )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP300NTdOK()
Definição do Menu
 
@sample	TP300NTdOK()
 
@return	lRet - verifica se validação está ok
 
@author	Inovação
@since		11/04/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function TP300NTdOK(oModel)
Local lRet	:= .T.
Local oMdlG6Z	:= oModel:GetModel('G6ZMASTER')
If (oMdlG6Z:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlG6Z:GetOperation() == MODEL_OPERATION_UPDATE)
	If ( !ExistCpo("SA2",FwFldGet('G6Z_FORNEC') + FwFldGet('G6Z_LOJAFO')) )
		Help( ,, 'Help',"TP300NTdOK", STR0007, 1, 0 ) //Fornecedor inválido.
	     lRet := .F.
	ElseIf !ValidaCPF(oMdlG6Z)
	     Help( ,, 'Help',"TP300NTdOK", STR0008, 1, 0 ) //CPF já cadastrado.
	     lRet := .F.
    EndIf
EndIf

Return (lRet)

/*/{Protheus.doc} GTP300NSet
//TODO Descrição auto-gerada.
@author osmar.junior
@since 14/02/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GTP300NSet()

Local aArea 	:= GetArea()
Local cF3		:= ""
Local lRet  	:= .F.

If FwFldGet("G6Z_TRECUR") == "1"
	cF3 := "GTPTEC" // Colaboradores
Else
	cF3	:= "GTPTEV" // Veiculos ST9
EndIf 

lRet := Conpad1( , , , cF3 )

RestArea(aArea)

Return( lRet )

/*/{Protheus.doc} GTP300NRet
//TODO Descrição auto-gerada.
@author osmar.junior
@since 14/02/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GTP300NRet()

Local cCod		:= ""

	&(Readvar()) := G6Z->G6Z_CODIGO
	cCod := G6Z->G6Z_CODIGO

Return(cCod)

/*/{Protheus.doc} ValidaCPF
//TODO Descrição auto-gerada.
@author osmar.junior
@since 14/02/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function ValidaCPF(oModel)
Local lRet := .T.
Local lDupCPFTer := SuperGetMv("MV_GTPCPF",,.F. )

	If lDupCPFTer .AND. ( FwFldGet('G6Z_TRECUR')=='1' .AND. !Empty(FwFldGet('G6Z_CPF') ) )
		If !ExistChav("G6Z", oModel:GetValue("G6Z_CPF"), 4 )  
			lRet := .F.
		EndIf
	EndIf	
	
Return lRet

/*/{Protheus.doc} ClearCp300
//TODO Descrição auto-gerada.
@author osmar.junior
@since 14/02/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function ClearCp300()
Local oModel    := FwModelActive()
Local oModelG6Z := oModel:GetModel('G6ZMASTER')

	If oModelG6Z:Getvalue('G6Z_TRECUR') == '1' //1=Colaborador;2=Veiculo
		oModelG6Z:LoadValue('G6Z_PREFCA', '')
		oModelG6Z:LoadValue('G6Z_PLACA', '')
		oModelG6Z:LoadValue('G6Z_MARCA', '')
		oModelG6Z:LoadValue('G6Z_MODELO', '')
		
	Else
		oModelG6Z:LoadValue('G6Z_DDD', '')
		oModelG6Z:LoadValue('G6Z_TELEFO', '')
		oModelG6Z:LoadValue('G6Z_CPF', '')
	EndIf

Return .T.
