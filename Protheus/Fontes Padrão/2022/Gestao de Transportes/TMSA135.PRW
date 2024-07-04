#INCLUDE "TMSA135.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//----------------------------------------------------------
/*/{Protheus.doc} TMSA135
Componente de Frete x TDA por CEP / Região 
@AUTHOR Rafael Souza
@OWNER TOTVS S/A
@VERSION PROTHEUS 12.1.2210
@SINCE 10/06/2022
@PROJECT
@MENU
@HISTORY
/*/
//----------------------------------------------------------
Function TMSA135()

	Local oBrowse := Nil
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DN9')			// Alias da tabela utilizada
	oBrowse:SetMenuDef('TMSA135')	// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001) // "Comp. Frete X TDA por CEP / REGIÃO"

	oBrowse:Activate()

Return Nil

//-----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Utilizacao de menu Funcional
Uso: TMSA135
@sample
//MenuDef()
@author Rafael Souza.
@since 10/06/2022
@version 1.0
/*/
//-----------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 DISABLE MENU	//"Pesquisar"
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TMSA135" OPERATION 2 ACCESS 0 DISABLE MENU   // "Visualizar"
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSA135" OPERATION 3 ACCESS 0                // "Incluir"
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSA135" OPERATION 4 ACCESS 0 DISABLE MENU   // "Alterar"
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSA135" OPERATION 5 ACCESS 0 DISABLE MENU   // "Excluir"
	ADD OPTION aRotina TITLE STR0009  ACTION "VIEWDEF.TMSA135" OPERATION 9 ACCESS 0 DISABLE MENU   //"Copiar"

Return(aRotina)
//-----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do Modelo
Uso: TMSA135
@sample
//ModelDef()
@author Rafael Souza
@since 31/06/2022
@version 1.0
/*/
//-----------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStruDN9 := FWFormStruct( 1, 'DN9' )
	Local oStruDNA := FWFormStruct( 1, 'DNA' )

	oStruDN9:SetProperty("DN9_CODPAS",MODEL_FIELD_NOUPD,.T.)  //Em modo de alteração não permite alterar o campo. 
	
	oModel := MPFormModel():New('TMSA135', /*bPre*/, { |oMdl| PosVldMdl( oMdl ) } /*bPost*/, /*bCommit*/, /*bCancel*/)

	oModel:AddFields('MdFieldDN9', Nil, oStruDN9 ,,,) 
	oModel:AddGrid('MdGridDNA', 'MdFieldDN9', oStruDNA, /*bLinePre*/,{|oModelGrid,nLine| PosVldDNA(oModelGrid, nLine)}/*bLinePost*/,  /*bPre*/,/*bPost*/, /*bLoad*/) //Itens do TDA
	
	oModel:SetRelation('MdGridDNA',{ {'DNA_FILIAL','xFilial("DNA")'},{'DNA_CODPAS','DN9_CODPAS'} }, DNA->( IndexKey(1) ) )
	oModel:GetModel( 'MdGridDNA' ):SetUniqueLine( {"DNA_CEPINI","DNA_CEPATE","DNA_CODREG"} )

	oModel:GetModel( 'MdGridDNA' ):SetDescription(STR0008) //-- "Itens TDA x CEP / Região"
	
	oModel:SetDescription(STR0001) //-- "Comp. Frete X TDA por CEP / REGIÃO"
	oModel:GetModel('MdFieldDN9'):SetDescription(STR0001)//-- "Comp. Frete X TDA por CEP / REGIÃO"
	oModel:SetPrimaryKey({"DN9_FILIAL","DN9_CODPAS"})

Return oModel

//-----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Retorna a View (tela) da rotina

Uso: TMSA135

@author Rafael Souza
@since 13/06/2022
@version 1.0
/*/
//-----------------------------------------------------------
Static Function ViewDef()

	Local oStruDN9  := FwFormStruct(2,'DN9')
	Local oStruDNA  := FwFormStruct(2,'DNA')
	Local oModel    := FwLoadModel('TMSA135')
	Local oView
	
	oView := FwFormView():New()
	
    oStruDNA:RemoveField("DNA_CODPAS")

	oView:SetModel(oModel)
	oView:EnableControlBar(.T.)

	//-- Field DN9
	oView:AddField( "MdFieldDN9",oStruDN9)
	oView:CreateHorizontalBox("Field",30)
	oView:SetOwnerView( "MdFieldDN9","Field")
	
	//-- Grid DNA
	oView:AddGrid("MdGridDNA",oStruDNA, "MdGridDNA" )
	oView:CreateHorizontalBox("GRID",70)
	oView:SetOwnerView( "MdGridDNA","GRID")
	oView:AddIncrementView( "MdGridDNA", "DNA_ITEM" )
	oView:EnableTitleView("MdGridDNA",STR0007) //-- "CEP / REGIÃO"
		
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsA135Wh
Valida a digitacao do campo 
@author Rafael Souza
@since 13/06/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function TmsA135Wh()

Local cCampo  := ReadVar()
Local lRet    := .T.


If cCampo $ 'M->DNA_CEPINI.M->DNA_CEPATE'
	lRet := Empty(FwFldGet("DNA_CODREG")) 
ElseIf cCampo == 'M->DNA_CODREG'
	lRet := Empty(FwFldGet("DNA_CEPINI")) .And. Empty(FwFldGet("DNA_CEPATE")) 
EndIf

Return( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} PosVldDNA
POS-Validação da linha
@author Rafael Souza
@since 15/06/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PosVldDNA(oGridModel, nLine)
Local lRet      := .T.
Local oModel	:= oGridModel:GetModel()	// Recebe o Model
Local oModelDNA	:= oModel:GetModel( 'MdGridDNA' )
Local cCEPINI	:= ""
Local cCEPFim	:= ""

If !oModelDNA:IsDeleted()
	cCEPINI := FwFldGet("DNA_CEPINI")
	cCEPFim	:= FwFldGet("DNA_CEPATE")

	If cCEPINI > cCEPFim
		Help(" ",1,"TMSA135001") // "Cep final deve ser maior que o inicial."
		lRet := .F. 
	EndIf 

EndIf

Return lRet



/*/-----------------------------------------------------------
{Protheus.doc} PosVldMdl()
Pos Valid do Modelo
Uso: TMSA135
@sample
//PosVldMdl(oModel)

@author Rafael Souza
@since 15/06/2022
@version 1.0
-----------------------------------------------------------/*/
Static Function PosVldMdl(oModel)
Local nOpcx		:= oModel:GetOperation()	
Local oModelDNA	:= oModel:GetModel("MdGridDNA")
Local cCEPINI 	:= oModelDNA:GetValue('DNA_CEPINI')
Local cCEPFim 	:= oModelDNA:GetValue('DNA_CEPATE')
Local cCodReg 	:= oModelDNA:GetValue('DNA_CODREG')
Local lRet      := .T.

	
If nOpcx == MODEL_OPERATION_INSERT .Or. nOpcx == MODEL_OPERATION_UPDATE
	
	// Valida a digitacao de pelo menos um campo de CEP ou Região
	If Empty(cCEPINI) .And. Empty(cCEPFim) .And. Empty(cCodReg) 
		Help(" ",1,"OBRIGAT")
		lRet := .F.
	EndIf
	
EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} Tms135Cep
Validação do CEP. 
@author Rafael Souza
@since 29/06/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function Tms135Cep()
Local cConteudo   := &(ReadVar())
Local cCampo      := ReadVar()
Local lRet        := .T.
Local nX          := 0
Local oModel      := Nil
Local oModelCep   := Nil
Local aSaveLines  := {}
Local nLine       := 0

oModel     := FWModelActive()
oModelCep  := oModel:GetModel( "MdGridDNA" )
nLine      := oModelCep:GetLine()

If cCampo == 'M->DNA_CEPINI'
	If Len(AllTrim(cConteudo)) <> Len(DNA->DNA_CEPINI)
		Return (.F.)
	EndIf
Else
	If Len(AllTrim(cConteudo)) <> Len(DNA->DNA_CEPATE)
		Return (.F.)
	EndIf
EndIf

aSaveLines  := FWSaveRows()
For nX := 1 To oModelCep:Length()

	oModelCep:GoLine(nX)
	If  nX != nLine .And. !oModelCep:IsDeleted()
		If  cConteudo >= oModelCep:GetValue( "DNA_CEPINI" ) .And. cConteudo <= oModelCep:GetValue( "DNA_CEPATE" )
			Help(" ",1,"TMSA135CEP",, STR0010 + " " + oModelCep:GetValue( "DNA_ITEM" ),4,1) //"Cep já cadastrado em um intervalo, item"
			lRet := .F.
			Exit
		EndIf
	EndIf

Next nX
FWRestRows( aSaveLines )

Return(lRet)
