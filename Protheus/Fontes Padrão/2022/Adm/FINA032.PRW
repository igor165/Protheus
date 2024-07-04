#Include "Protheus.ch"
#Include "FWMVCDEF.ch"
#Include "FINA032.ch"

Static __nTotPerc	:= 0
Static __cNumImo
Static __cXml032	:= ""
Static __nOper		:= 1
Static __cVerImo	:= ""

#DEFINE	ENTER		Chr(13) + Chr(10)
#DEFINE OPER_ALTEXP	10

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA032
Cadastro de CAFIR X Imóvel

@author  rodrigo oliveira
@since 18/02/2020
@version 12
/*/
//-------------------------------------------------------------------
Function FINA032(nOpc, nRecFVV, cVersion , lBrw, nOper)
    Local aEnableButtons	:=	{	{ .F., Nil }, { .F., Nil }, ;
								{ .F., Nil }, { .F., Nil }, ;
								{ .F., Nil }, { .F., Nil }, ;
								{ .T., Nil }, { .T., Nil }, ;
								{ .F., Nil }, { .F., Nil }, ;
								{ .F., Nil }, { .F., Nil }, ;
								{ .F., Nil }, { .F., Nil }		} //"Confirmar"###"Fechar"

	If nOpc == OPER_ALTEXP
		__nOper := nOpc	:= OP_COPIA
	Else
		__nOper := nOpc
	EndIf

	__cVerImo	:= cVersion
    If ALTERA
        nOpc := MODEL_OPERATION_UPDATE
    ElseIf INCLUI .And. nOpc <> OP_COPIA
		Help(' ',1, STR0009 ,, STR0010,2,0,,,,,,)   // "NAOINCUIDO" ## "Finalize a inclusão do imóvel antes de incluir o complemento."
		Return (.F.)
	EndIf

    If lBrw
		If Valtype(__cXml032) == "C"  .and. !Empty(__cXml032)
			oModel := FwLoadModel("FINA032")
			oModel:LoadXMLData(__cXml032)
			FWExecView( STR0001,"FINA032", nOpc,/**/,{||.T.}/*bCloseOnOk*/,/*{||Fakeok()}*/,,aEnableButtons,/*bCancel*/,/**/,/*cToolBar*/, oModel )//'Complemento titulo'
			oModel:Deactivate()
			oModel:Destroy()
			oModel:= Nil
		Else
			FWExecView( STR0001,"FINA032", nOpc,/**/,{||.T.}/*bCloseOnOk*/,/*{||Fakeok()}*/,,aEnableButtons,/*bCancel*/,/**/,/*cToolBar*/,  )//'Complemento titulo'STR0001
		EndIf
	EndIf

	ZeraStatic()
Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Define o ModelDef padrão

@type Function

@author  rodrigo oliveira
@since 18/02/2020
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ModelDef() As Object
    Local oStruFVV	As Object
    Local oStruFXV	As Object
    Local oStruFVG  As Object
    Local oModel	As Object
	Local nIndFXV	As Numeric
    Local nIndFVG	As Numeric

	nIndFXV	:= Iif(FWSIXUtil():ExistIndex('FXV' , '4'), 4,1)
	nIndFVG	:= Iif(FWSIXUtil():ExistIndex('FVG' , '4'), 4,2)

    oStruFVV      := FWFormStruct( 1, 'FVV' )
    oStruFXV      := FWFormStruct( 1, 'FXV' )
    oStruFVG      := FWFormStruct( 1, 'FVG' )

  	oModel        := MPFormModel():New('FINA032', /*bPre*/, { |oModel| PosVld029(oModel, "FXV") }, /*bGrv*/, /*bCancel*/ )

    oModel:AddFields( 'MODEL_FVV_IMOVEL',, oStruFVV)
    oModel:AddGrid( 'FXVDETAIL', 'MODEL_FVV_IMOVEL', oStruFXV)
    oModel:AddGrid( 'MODEL_FVG_IMOVEL_PESSOA' , 'FXVDETAIL', oStruFVG , { || FwFldGet("FXV_TIPOEX") != '1' } )

    oStruFXV:SetProperty('FXV_CODIGO', MODEL_FIELD_INIT, { || M->FVV_CODIGO } )
	oStruFVG:SetProperty('FVG_ORIG'	 , MODEL_FIELD_INIT, {|| "2" })
	oStruFXV:SetProperty('FXV_PARTIC', MODEL_FIELD_VALID, {|| SumPartFXV('FXV_PARTIC')})
	oStruFXV:AddTrigger( "FXV_TIPOEX", "FXV_PARTIC"	, { || FwFldGet("FXV_TIPOEX") == '1' }, { || 100 })
    
	oStruFVG:SetProperty('FVG_PERC'		, MODEL_FIELD_OBRIGAT, .F. )
    oStruFVG:SetProperty('FVG_PERC'		, MODEL_FIELD_VALID, {|| SumPartFXV('FVG_PERC')})
    oStruFXV:SetProperty('FXV_PARTIC'	, MODEL_FIELD_VALID, {|| SumPartFXV('FXV_PARTIC')})
	oStruFXV:SetProperty('FXV_PARTIC'	, MODEL_FIELD_WHEN , {|| FwFldGet("FXV_TIPOEX") != '1' } )
	oStruFXV:SetProperty('FXV_VERSAO'	, MODEL_FIELD_INIT, { || FwFldGet("FVV_VERSAO") } )

    oModel:SetDescription(STR0004)  // "CAFIR X Imóvel"

	oModel:GetModel( 'FXVDETAIL' ):SetDescription( STR0004 )
    oModel:GetModel( 'MODEL_FVG_IMOVEL_PESSOA' ):SetOptional( .T. )

    oModel:SetRelation( 'FXVDETAIL', { { 'FXV_FILIAL', 'xFilial("FXV")' }, { 'FXV_CODIGO', 'FVV_CODIGO' }, { 'FXV_VERSAO', 'FVV_VERSAO' } }, FXV->( IndexKey(nIndFXV)))
    oModel:SetRelation( 'MODEL_FVG_IMOVEL_PESSOA' , { { 'FVG_FILIAL', 'xFilial("FVG")' }, { 'FVG_CODIMO', 'FXV_CODIGO' }, { 'FVG_NUMIMO', 'FXV_NUMIMO'}, { 'FVG_VERSAO', 'FXV_VERSAO'} }, FVG->( IndexKey(nIndFVG)))
	
Return oModel

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Define a ViewDef padrão para o cadastro de Pessoa

@type Function

@author rafael rondon
@since 01/11/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ViewDef() As Object

	Local oModel        := FWLoadModel( 'FINA032' )  
    Local oStruFVV      := FWFormStruct(2, 'FVV', { |x| AllTrim(x) $ 'FVV_CODIGO|FVV_CODPES|FVV_NOMPES|FVV_TIPOEX|FVV_PARTIC|FVV_NOME' } )
    Local oStruFXV      := FWFormStruct( 2, 'FXV' )
    Local oStruFVG      := FWFormStruct( 2, 'FVG' )
    Local oView         := FWFormView():New()
	
	oView:SetModel( oModel )

    oView:AddField( 'VIEW_FVV_IMOVEL' , oStruFVV  , 'MODEL_FVV_IMOVEL'   )
    oView:AddGrid( 'VIEW_FXV_IMOVEL'  , oStruFXV  , 'FXVDETAIL'          )
    oView:AddGrid( 'VIEW_FVG_IMOVEL'  , oStruFVG  , 'MODEL_FVG_IMOVEL_PESSOA' /*'FVGDETAIL'*/          )

    oView:EnableTitleView( 'VIEW_FXV_IMOVEL', STR0013 ) // 'Cafir do Imóvel'
    oView:EnableTitleView( 'VIEW_FVG_IMOVEL', STR0014 ) // 'Cadastro de terceiros'

    oView:AddIncrementField( 'VIEW_FXV_IMOVEL', 'FXV_NUMIMO' )

	oStruFVV:SetProperty( '*', MVC_VIEW_CANCHANGE, .F. )

	oStruFXV:SetProperty("FXV_CODPES",MVC_VIEW_LOOKUP,"FVUFVV")
	
    oStruFVG:RemoveField("FVG_NUMIMO")
	oStruFVG:RemoveField("FVG_VERSAO")
	oStruFXV:RemoveField("FXV_VERSAO")
	oStruFVG:RemoveField("FVG_ORIG")

  	oView:EnableTitleView("VIEW_FXV_IMOVEL", STR0004 ) // "CAFIR X Imovel"
    oView:CreateHorizontalBox( 'Cabec' , 20 )
    oView:CreateHorizontalBox( 'Imov'  , 40 )
    oView:CreateHorizontalBox( 'Terc'  , 40 )

    oView:SetOwnerView( 'VIEW_FVV_IMOVEL' , 'Cabec'    )
    oView:SetOwnerView( 'VIEW_FXV_IMOVEL' , 'Imov'    )
    oView:SetOwnerView( 'VIEW_FVG_IMOVEL' , 'Terc'    )

    oView:SetCloseOnOK( { || .T. } )

Return oView

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SumPartFXV()
Soma o total de participaão no imóvel

@type Function

@author Rodrigo Oliveira
@since 01/11/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Function SumPartFXV(cCampo As Character) As Numeric
	Local oModel 		As Object
	Local oGrid			As Object
	Local nPerc			As Numeric
	Local nTotPerOld 	As Numeric
	Local nI			As Numeric
	Local lRet			As Logical
	
	oModel	:= FwModelActive()
	oGrid	:= oModel:GetModel("MODEL_FVG_IMOVEL_PESSOA")
	nPerc	:= 0
	nI		:= 0
	lRet	:= .T.
	
	If __cNumImo == NIL
		__cNumImo := FwFldGet("FXV_NUMIMO")
	ElseIf cCampo == "FXV_PARTIC" .And. FwFldGet("FXV_NUMIMO") != __cNumImo
		__cNumImo := FwFldGet("FXV_NUMIMO")
		__nTotPerc := 0
		If oModel:lModify
			__nTotPerc := 0
			For nI := 1 To oGrid:Length()
				__nTotPerc	+= oGrid:GetValue("FVG_PERC", nI)
			Next
		Else
			__nTotPerc += oGrid:GetValue("FVG_PERC")
		EndIf
	EndIf
	
	If cCampo == "FVG_PERC"
		nTotPerOld := __nTotPerc
		If oModel:lModify
			__nTotPerc := 0
			For nI := 1 To oGrid:Length()
				__nTotPerc	+= oGrid:GetValue("FVG_PERC", nI)
			Next
		Else
			__nTotPerc += oGrid:GetValue("FVG_PERC")
		EndIf
	EndIf
	
	If cCampo == "FVG_PERC"
	 	If ( oGrid:GetValue("FVG_PERC") ) < 0
			oModel:SetErrorMessage("MODEL_FVV_IMOVEL", , "MODEL_FVV_IMOVEL", , , STR0015, STR0016, , ) // 'NEGATIVO' ## 'Porcentagem de participação não pode ser negativa.'
			lRet	:= .F.
		Else
			If ( oModel:GetValue("FXVDETAIL", "FXV_PARTIC") + __nTotPerc ) <= 100
				nPerc	:= oGrid:GetValue("FVG_PERC")
			Else
				__nTotPerc	:= nTotPerOld
				oModel:SetErrorMessage("MODEL_FVV_IMOVEL", , "MODEL_FVV_IMOVEL", , , STR0017, STR0018, , ) // 'Percentagem total superior a 100%' ## "Total das porcentagens de participação (proprietário + terceiros) não deve ser maior que 100%"
				nPerc	:= 0
				lRet	:= .F.
			EndIf
		EndIf
	Else
		If ( oModel:GetValue("FXVDETAIL", "FXV_PARTIC") ) < 0
			oModel:SetErrorMessage("MODEL_FVV_IMOVEL", , "MODEL_FVV_IMOVEL", , , STR0015, STR0016, , ) // 'NEGATIVO' ## 'Porcentagem de participação não pode ser negativa.'
			lRet	:= .F.
		Else
			If (oModel:GetValue("FXVDETAIL", "FXV_PARTIC") + __nTotPerc) <= 100
				nPerc	:= oModel:GetValue("FXVDETAIL", "FXV_PARTIC")
			Else
				oModel:SetErrorMessage("MODEL_FVV_IMOVEL", , "MODEL_FVV_IMOVEL", , , STR0017, STR0018, , ) // 'Percentagem total superior a 100%' ## "Total das porcentagens de participação (proprietário + terceiros) não deve ser maior que 100%"
				nPerc	:= 0
				lRet	:= .F.
			EndIf
		EndIf
	EndIf
	
	If nPerc == 100 .And. FwFldGet("FXV_TIPOEX") $ '2|4'
		oModel:SetErrorMessage("MODEL_FVV_IMOVEL", , "MODEL_FVV_IMOVEL", , , STR0019, STR0020, , ) // 'PARCEIR' ## 'Tipo de exploração não permite exploração individual de 100%.'
		lRet	:= .F.
	EndIf
Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ZeraStatic()
Zera as variáveis estáticas

@type Function

@author Rodrigo Oliveira
@since 12/03/2020
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ZeraStatic()

	__nTotPerc	:= 0
	__cXml032	:= ""
Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FVVIniPad()
Inicializador padrão dos campos da Field

@type Function

@author Rodrigo Oliveira
@since 12/03/2020
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Function FVVIniPad(cCampo As Character) As Character
	Local cRet		As Character
		
	cRet	:= ''
	
	If cCampo == 'FVV_CODIGO'
		cRet	:= FVV->FVV_CODIGO
	ElseIf cCampo == 'FVV_CODPES'
		cRet	:= FVV->FVV_CODPES
	ElseIf cCampo == 'FVV_NOMPES'
		cRet	:= Posicione('FVU',1,xFilial('FVU')+FVV->FVV_CODPES,'FVU_NOME')
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} FIN032INI
Validação da grid de /cafir X Imóvel

@author Rodrigo Oliveira
@since 12/03/2020

@return Logico
/*/
//-------------------------------------------------------------------
Function FIN032INI()

Local lRet As Logical
Local oModel As Object
Local cCodigo As Character

oModel 	:= FWModelActive()
cCodigo := oModel:GetValue("FXVDETAIL","FXV_CODMUN")
lRet 	:= .F.

If Vazio() 
	lRet	:= .T.
ElseIf ExistCpo("CC2", FwFldGet("FXV_UF") + FwFldGet("FXV_CODMUN") )
	CC2->(DbSetOrder(1))
	If CC2->(MsSeek(xFilial("CC2") + FwFldGet("FXV_UF") + cCodigo ))
		cRet :=  CC2->CC2_CODMUN
		lRet := .T.
		oModel:LoadValue("FXVDETAIL","FXV_CODMUN", cRet)
	EndIf
EndIf

Return lRet
