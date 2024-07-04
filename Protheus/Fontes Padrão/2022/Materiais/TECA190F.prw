#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA190F.ch"

#DEFINE DEF_TITULO_DO_CAMPO		01	//Titulo do campo
#DEFINE DEF_TOOLTIP_DO_CAMPO	02	//ToolTip do campo
#DEFINE DEF_IDENTIFICADOR		03	//identificador (ID) do Field
#DEFINE DEF_TIPO_DO_CAMPO		04	//Tipo do campo
#DEFINE DEF_TAMANHO_DO_CAMPO	05	//Tamanho do campo
#DEFINE DEF_DECIMAL_DO_CAMPO	06	//Decimal do campo
#DEFINE DEF_CODEBLOCK_VALID		07	//Code-block de validação do campo
#DEFINE DEF_CODEBLOCK_WHEN		08	//Code-block de validação When do campo
#DEFINE DEF_LISTA_VAL			09	//Lista de valores permitido do campo
#DEFINE DEF_OBRIGAT				10	//Indica se o campo tem preenchimento obrigatório
#DEFINE DEF_CODEBLOCK_INIT		11	//Code-block de inicializacao do campo
#DEFINE DEF_CAMPO_CHAVE			12	//Indica se trata de um campo chave
#DEFINE DEF_RECEBE_VAL			13	//Indica se o campo pode receber valor em uma operação de update.
#DEFINE DEF_VIRTUAL				14	//Indica se o campo é virtual
#DEFINE DEF_VALID_USER			15	//Valid do usuario

#DEFINE DEF_ORDEM				16	//Ordem do campo
#DEFINE DEF_HELP				17	//Array com o Help dos campos
#DEFINE DEF_PICTURE				18	//Picture do campo
#DEFINE DEF_PICT_VAR			19	//Bloco de picture Var
#DEFINE DEF_LOOKUP				20	//Chave para ser usado no LooKUp
#DEFINE DEF_CAN_CHANGE			21	//Logico dizendo se o campo pode ser alterado
#DEFINE DEF_ID_FOLDER			22	//Id da Folder onde o field esta
#DEFINE DEF_ID_GROUP			23	//Id do Group onde o field esta
#DEFINE DEF_COMBO_VAL			24	//Array com os Valores do combo
#DEFINE DEF_TAM_MAX_COMBO		25	//Tamanho maximo da maior opção do combo
#DEFINE DEF_INIC_BROWSE			26	//Inicializador do Browse
#DEFINE DEF_PICTURE_VARIAVEL	27	//Picture variavel
#DEFINE DEF_INSERT_LINE			28	//Se verdadeiro, indica pulo de linha após o campo
#DEFINE DEF_WIDTH				29	//Largura fixa da apresentação do campo
#DEFINE DEF_TIPO_CAMPO_VIEW		30	//Tipo do campo

#DEFINE QUANTIDADE_DEFS			30	//Quantidade de DEFs

Static cSitABB := "BR_VERDE"
Static lDelConf := .F.

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA190F - Mesa Operacional - Realocação
 	ModelDef
 		Definição do modelo de Dados

@author	boiani
@since	08/10/2019
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	
Local oStrAA1	:= FWFormModelStruct():New()
Local oStrTGY	:= FWFormModelStruct():New()
Local oStrALC	:= FWFormModelStruct():New()
Local oStrDTA	:= FWFormModelStruct():New()
Local aFields	:= {}
Local nX		:= 0
Local nY		:= 0
Local aTables 	:= {}
Local xAux
Local bCommit	:= { |oModel| AT190fCmt( oModel ) }
Local bValid := { |oModel| AT190fVld( oModel ) }

oStrAA1:AddTable("   ",{}, STR0001) //"Realocação"
oStrTGY:AddTable("   ",{}, "   ")
oStrALC:AddTable("   ",{}, "   ")
oStrDTA:AddTable("   ",{}, "   ")

AADD(aTables, {oStrAA1, "AA1"})
AADD(aTables, {oStrTGY, "TGY"})
AADD(aTables, {oStrALC, "ALC"})
AADD(aTables, {oStrDTA, "DTA"})

For nY := 1 To LEN(aTables)
	aFields := AT190DDef(aTables[nY][2])

	For nX := 1 TO LEN(aFields)
		aTables[nY][1]:AddField(aFields[nX][DEF_TITULO_DO_CAMPO],;
						aFields[nX][DEF_TOOLTIP_DO_CAMPO],;
						aFields[nX][DEF_IDENTIFICADOR	],;
						aFields[nX][DEF_TIPO_DO_CAMPO	],;
						aFields[nX][DEF_TAMANHO_DO_CAMPO],;
						aFields[nX][DEF_DECIMAL_DO_CAMPO],;
						aFields[nX][DEF_CODEBLOCK_VALID	],;
						aFields[nX][DEF_CODEBLOCK_WHEN	],;
						aFields[nX][DEF_LISTA_VAL		],;
						aFields[nX][DEF_OBRIGAT			],;
						aFields[nX][DEF_CODEBLOCK_INIT	],;
						aFields[nX][DEF_CAMPO_CHAVE		],;
						aFields[nX][DEF_RECEBE_VAL		],;
						aFields[nX][DEF_VIRTUAL			],;
						aFields[nX][DEF_VALID_USER		])
	Next nX
Next nY

If ExistBlock("AT190FCP")
	ExecBlock("AT190FCP",.F.,.F.,{@oModel, @aTables} )
EndIf

xAux := FwStruTrigger( 'AA1_CODTEC', 'AA1_NOMTEC',;
	'Posicione("AA1",1,xFilial("AA1") + FwFldGet("AA1_CODTEC"),"AA1_NOMTEC")', .F. )
	oStrAA1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TGY_TIPALO', 'TGY_DESMOV',;
	'Posicione("TCU",1,xFilial("TCU") + FwFldGet("TGY_TIPALO"),"TCU_DESC")', .F. )
	oStrTGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TGY_CONTRT', 'TGY_CONTRT','At190DClr("TGY_CONTRT")', .F. )
	oStrTGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TGY_CODTFL', 'TGY_CODTFL','At190DClr("TGY_CONTRT|TGY_CODTFL")', .F. )
	oStrTGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TGY_TFFCOD', 'TGY_TFFCOD','At190DClr("TGY_CONTRT|TGY_CODTFL|TGY_TFFCOD","TGY_TFFCOD")', .F. )
	oStrTGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TGY_ESCALA', 'TGY_ESCALA','At190DClr("TGY_CONTRT|TGY_CODTFL|TGY_TFFCOD|TGY_ESCALA|TGY_TIPALO|TGY_DESMOV")', .F. )
	oStrTGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

oModel := MPFormModel():New('TECA190F',/*bPreValidacao*/,bValid,bCommit,/*bCancel*/)
oModel:SetDescription( STR0001 ) //"Realocação" 

oModel:addFields('AA1MASTER',,oStrAA1)
oModel:SetPrimaryKey({"AA1_FILIAL","AA1_CODTEC"})

oModel:addFields('TGYMASTER','AA1MASTER',oStrTGY, {|oMdlTGY,cAction,cField,xValue| PreLinTGY(oMdlTGY,cAction,cField,xValue)})
oModel:addFields('DTAMASTER','AA1MASTER',oStrDTA)
oModel:addGrid('ALCDETAIL','TGYMASTER', oStrALC,{|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinAlc(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)})


oModel:GetModel('TGYMASTER'):SetOnlyQuery(.T.)
oModel:GetModel('ALCDETAIL'):SetOnlyQuery(.T.)
oModel:GetModel('DTAMASTER'):SetOnlyQuery(.T.)


oModel:GetModel('TGYMASTER'):SetOptional(.T.)
oModel:GetModel('ALCDETAIL'):SetOptional(.T.)
oModel:GetModel('DTAMASTER'):SetOptional(.T.)

oModel:GetModel('AA1MASTER'):SetDescription(STR0002)	//"Atendente"
oModel:GetModel('TGYMASTER'):SetDescription(STR0003)	//"Configuração de Alocação"
oModel:GetModel('ALCDETAIL'):SetDescription(STR0004)	//"Projeção de Alocação"
oModel:GetModel('DTAMASTER'):SetDescription(STR0005)	//"Data de Alocação"

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

If ExistBlock("AT190FMo")
	ExecBlock("AT190FMo",.F.,.F.,{@oModel,@aTables} )
EndIf

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	boiani
@since 08/10/2019
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 		:= ModelDef()
Local oView
Local aTables 		:= {}
Local oStrAA1		:= FWFormViewStruct():New()
Local oStrTGY		:= FWFormViewStruct():New()
Local oStrDTA		:= FWFormViewStruct():New()
Local oStrALC		:= FWFormViewStruct():New()
Local nX
Local nY
Local nC
Local lMV_MultFil	:= TecMultFil()

AADD(aTables, {oStrAA1, "AA1"})
AADD(aTables, {oStrTGY, "TGY"})
AADD(aTables, {oStrALC, "ALC"})
AADD(aTables, {oStrDTA, "DTA"})

For nY := 1 to LEN(aTables)
	aFields := AT190DDef(aTables[nY][2])

	For nX := 1 to LEN(aFields)
		aTables[nY][1]:AddField(aFields[nX][DEF_IDENTIFICADOR],;
						aFields[nX][DEF_ORDEM],;
						aFields[nX][DEF_TITULO_DO_CAMPO],;
						aFields[nX][DEF_TOOLTIP_DO_CAMPO],;
						aFields[nX][DEF_HELP],;
						aFields[nX][DEF_TIPO_CAMPO_VIEW],;
						aFields[nX][DEF_PICTURE],;
						aFields[nX][DEF_PICT_VAR],;
						aFields[nX][DEF_LOOKUP],;
						aFields[nX][DEF_CAN_CHANGE],;
						aFields[nX][DEF_ID_FOLDER],;
						aFields[nX][DEF_ID_GROUP],;
						aFields[nX][DEF_COMBO_VAL],;
						aFields[nX][DEF_TAM_MAX_COMBO],;
						aFields[nX][DEF_INIC_BROWSE],;
						aFields[nX][DEF_VIRTUAL],;
						aFields[nX][DEF_PICTURE_VARIAVEL],;
						aFields[nX][DEF_INSERT_LINE],;
						aFields[nX][DEF_WIDTH])
		If aTables[nY][2] == "AA1" .AND. !(aFields[nX][DEF_IDENTIFICADOR] $ "AA1_CODTEC|AA1_NOMTEC")
			aTables[nY][1]:RemoveField(aFields[nX][DEF_IDENTIFICADOR])
		EndIf
	Next nX
Next nY


oStrTGY:RemoveField("TGY_RECNO")
oStrALC:RemoveField("ALC_KEYTGY")
oStrALC:RemoveField("ALC_ITTGY")
oStrALC:RemoveField("ALC_TURNO")
oStrALC:RemoveField("ALC_EXSABB")
oStrALC:RemoveField("ALC_ITEM")
oStrALC:RemoveField("ALC_GRUPO")

If !lMV_MultFil
	oStrTGY:RemoveField("TGY_FILIAL")
EndIf

For nC := 1 to 4
	oStrTGY:RemoveField("TGY_ENTRA"+ Str(nC, 1))
	oStrTGY:RemoveField("TGY_SAIDA"+ Str(nC, 1))
Next

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_MASTER', oStrAA1, 'AA1MASTER')
oView:AddField('VIEW_TGY',  oStrTGY, 'TGYMASTER')
oView:AddField('VIEW_DTA',  oStrDTA, 'DTAMASTER')
oView:AddGrid('DETAIL_ALC', oStrALC, 'ALCDETAIL')

oView:CreateHorizontalBox( 'REALOC_AA1' , 16 )
oView:CreateHorizontalBox( 'REALOC_TGY', 26)
oView:CreateHorizontalBox( 'REALOC_DTA', 17)
oView:CreateHorizontalBox( 'REALOC_BTN', 8)
oView:CreateHorizontalBox( 'REALOC_ALOC', 33)

oView:CreateVerticalBox( 'V_ABA02_2', 9, 'REALOC_BTN' )
oView:CreateVerticalBox( 'V_ABA04_2', 82, 'REALOC_BTN' )

oView:AddOtherObject("PROCONF",{|oPanel| at190dPConf(oPanel) })
oView:SetOwnerView("PROCONF","V_ABA02_2")


oView:SetOwnerView('VIEW_MASTER','REALOC_AA1')

oView:SetOwnerView('VIEW_TGY','REALOC_TGY')
oView:SetOwnerView('VIEW_DTA','REALOC_DTA')
oView:SetOwnerView('DETAIL_ALC','REALOC_ALOC')

oView:SetContinuousForm()

oView:EnableTitleView('VIEW_MASTER', 	STR0002) 		//"Atendente"
oView:EnableTitleView('VIEW_TGY', 		STR0003) 		//"Configuração de Alocação"
oView:EnableTitleView('VIEW_DTA', 		STR0006)		//"Período de Alocação"

oView:SetDescription(STR0001) //"Realocação"

If ExistBlock("AT190FVi")
	ExecBlock("AT190FVi",.F.,.F.,{@oView,@aTables} )
EndIf

Return oView
//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados

@description Bloco de código executado no activate
@param oModel, obj, modelo em ativação

@author	boiani
@since	08/10/2019
/*/
//------------------------------------------------------------------------------
Static Function InitDados(oModel)
Local oMdl190d := FwModelActive()
Local oMdlAA1 := oModel:GetModel("AA1MASTER")
Local oMdlDTA := oModel:GetModel("DTAMASTER")
Local oStrAA1 := oMdlAA1:GetStruct() 
Local oStrDTA := oMdlDTA:GetStruct()
Local nX
Local aMarks := ACLONE(At190DSMar())
Local dDataDe
Local dDataAte

If oMdl190d:GetId() == 'TECA190D' .AND. oModel:GetId() == 'TECA190F' 
	oMdlAA1:SetValue("AA1_CODTEC", oMdl190d:GetValue("AA1MASTER","AA1_CODTEC"))
	oStrAA1:SetProperty("AA1_CODTEC", MODEL_FIELD_WHEN, {|| .F.})
	oStrAA1:SetProperty("AA1_NOMTEC", MODEL_FIELD_WHEN, {|| .F.})
	For nX := 1 TO LEN(aMarks)
		If !EMPTY(aMarks[nX][1])
			If EMPTY(dDataDe)
				dDataDe := aMarks[nX][9]
			EndIf
			If EMPTY(dDataAte)
				dDataAte := aMarks[nX][9]
			EndIf
			If aMarks[nX][9] < dDataDe
				dDataDe := aMarks[nX][9] 
			EndIf
			If aMarks[nX][9] > dDataAte
				dDataAte := aMarks[nX][9] 
			EndIf
		EndIf
	Next nX
	oMdlDTA:SetValue("DTA_DTINI",dDataDe)
	oMdlDTA:SetValue("DTA_DTFIM",dDataAte)
EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190fCmt
	
@description	Realizar a gravação dos dados 
@since			08/10/2019
@author			boiani
/*/
//------------------------------------------------------------------------------
Function AT190fCmt(oModel)

At190dExec("GravaAloc2( .F., xPar,,,xPar2)", cSitABB, lDelConf)

Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190fVld
	
@description	Realizar a validação do modelo
@since			10/10/2019
@author			boiani
/*/
//------------------------------------------------------------------------------
Function AT190fVld(oModel)
cSitABB 	:= "BR_VERDE"
lDelConf 	:= .F.
Return At190dExec("VldGrvAloc( @xPar,@xPar2 )", @cSitABB,@lDelConf)
