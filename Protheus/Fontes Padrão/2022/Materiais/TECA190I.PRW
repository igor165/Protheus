#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA190I.CH"

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

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA190I

@description  Configuração de Alocação

@author	boiani
@since	25/11/2020
/*/
//------------------------------------------------------------------------------
Function TECA190I()
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,STR0002},{.T.,STR0003},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}} //"Salvar"#"Cancelar"
FwExecView( STR0001, "VIEWDEF.TECA190I", MODEL_OPERATION_INSERT,; //"Configuração de Alocação"
            /*oOwner*/, {||.T.}, /*bOk*/, 45, aButtons )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Modelo da interface

@author	boiani
@since	25/11/2020
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	
Local oStrTFF	:= FWFormModelStruct():New()
Local oStrTGY	:= FWFormModelStruct():New()
Local aFields	:= {}
Local nX		:= 0
Local nY		:= 0
Local aTables 	:= {}
Local xAux
Local bValid := { || AT190IVld() }
Local bCommit := { || AT190ICmt() }
Local lMulFil 	:= TecMultFil()

oStrTFF:AddTable("   ",{}, STR0004	) //"Posto de Trabalho"
oStrTGY:AddTable("   ",{}, "   ")

AADD(aTables, {oStrTFF, "TFF"})
AADD(aTables, {oStrTGY, "TGY"})

For nY := 1 To LEN(aTables)
	aFields := AT190IDef(aTables[nY][2])

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

xAux := FwStruTrigger( 'TFF_FILIAL', 'TFF_CODIGO',;
	'SPACE(6)', .F. )
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TFF_FILIAL', 'TFF_CALEND',;
	'SPACE(6)', .F. )
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

if lMulFil
	xAux := FwStruTrigger( 'TFF_FILIAL', 'TFF_FILIAL',;
		'At190ILimp()', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	
	xAux := FwStruTrigger( 'TFF_CODIGO', 'TFF_CALEND',;
		'Posicione("TFF",1,xFilial("TFF",FwFldGet("TFF_FILIAL")) + FwFldGet("TFF_CODIGO"),"TFF_CALEND")', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Else
	xAux := FwStruTrigger( 'TFF_CODIGO', 'TFF_CALEND',;
		'Posicione("TFF",1,xFilial("TFF") + FwFldGet("TFF_CODIGO"),"TFF_CALEND")', .F. )
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf

xAux := FwStruTrigger( 'TFF_CODIGO', 'TFF_CODIGO',;
	'At190ILoad()', .F. )
	oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
    
	
oModel := MPFormModel():New('TECA190I',/*bPreValidacao*/, bValid, bCommit,/*bCancel*/)
oModel:SetDescription( STR0005 ) //"Config. Alocações"

oModel:addFields('TFFMASTER',,oStrTFF)
oModel:SetPrimaryKey({"TFF_FILIAL","TFF_CODIGO"})

oModel:addGrid('TGYDETAIL','TFFMASTER', oStrTGY)

oModel:GetModel('TGYDETAIL'):SetOnlyQuery(.T.)
oModel:GetModel('TGYDETAIL'):SetOptional(.T.)

oModel:GetModel('TFFMASTER'):SetDescription(STR0006) //"Posto"
oModel:GetModel('TGYDETAIL'):SetDescription(STR0007) //"Efetivos"

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	boiani
@since	25/11/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel := ModelDef()
Local oView
Local aTables 	:= {}
Local oStrTFF	:= FWFormViewStruct():New()
Local oStrTGY	:= FWFormViewStruct():New()
Local nX
Local nY
Local lMonitor	:= IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
Local lMulFil 	:= TecMultFil()

AADD(aTables, {oStrTFF, "TFF"})
AADD(aTables, {oStrTGY, "TGY"})

For nY := 1 to LEN(aTables)
	
	aFields := AT190IDef(aTables[nY][2])

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
	Next nX
Next nY

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_POSTO', oStrTFF, 'TFFMASTER')
oView:AddGrid('DETAIL_TGY', oStrTGY, 'TGYDETAIL')

oView:CreateHorizontalBox( 'CONFIG_TFF' , 35 )
oView:CreateHorizontalBox( 'CONFIG_TGY', 65 )

oView:SetOwnerView('VIEW_POSTO','CONFIG_TFF')
oView:SetOwnerView('DETAIL_TGY','CONFIG_TGY')

oStrTGY:RemoveField("TGY_RECTGY")

If !lMulFil
	oStrTFF:RemoveField("TFF_FILIAL")
EndIf

oView:EnableTitleView('VIEW_POSTO',STR0008) //"Posto de Trabalho"

oView:SetDescription(STR0005) //"Config. Alocações"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} AT190IDef
	Define os campos da tela

@author	boiani
@since	25/11/2020
/*/
//-------------------------------------------------------------------
Function AT190IDef(cTable)
Local aRet		:= {}
Local nAux 		:= 0
Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais

If cTable == "TFF"
    If lMV_MultFil
        AADD(aRet, ARRAY(QUANTIDADE_DEFS))
        nAux := LEN(aRet)
        aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes("CN9_FILIAL", .T.)
        aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes("CN9_FILIAL", .F.)
        aRet[nAux][DEF_IDENTIFICADOR] := "TFF_FILIAL"
        aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
        aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
        aRet[nAux][DEF_TAMANHO_DO_CAMPO] := Len(cFilAnt)
        aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
        aRet[nAux][DEF_OBRIGAT] := .F.
        aRet[nAux][DEF_RECEBE_VAL] := .T.
        aRet[nAux][DEF_VIRTUAL] := .T.
        aRet[nAux][DEF_ORDEM] := "01"
        aRet[nAux][DEF_PICTURE] := "@!"
        aRet[nAux][DEF_LOOKUP] := "SM0"
        aRet[nAux][DEF_CAN_CHANGE] := .T.
        aRet[nAux][DEF_CODEBLOCK_INIT] := {|| cFilAnt}
        aRet[nAux][DEF_HELP] := {STR0009} //"Filial do Posto"
        aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| !EMPTY(xNewValue) .AND.;
                                            ExistCpo("SM0", cEmpAnt+xNewValue)}
    EndIf

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0012 //"Posto"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0012 //"Posto"
	aRet[nAux][DEF_IDENTIFICADOR] := "TFF_CODIGO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_COD")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "T19IPS" //At190dCons("POSTO_CFG")
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0010}	//"Código de recursos humanos."
    aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| AT190IVlFl(oMdl,cField,xNewValue)}

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0013 //"Calendário"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0013 //"Calendário"
	aRet[nAux][DEF_IDENTIFICADOR] := "TFF_CALEND"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AC0_CODIGO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "T19ICL" //At190dCons("CALENDARIO")
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0011} //"Código do calendário"
    aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| AT190IVlFl(oMdl,cField,xNewValue)}

ElseIf cTable == "TGY"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0014 //"Código do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0014 //"Código do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_CODTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0015 //"Nome"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0015 //"Nome"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_NOMTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0016 //"Data Ult. Aloc."
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0016 //"Data Ult. Aloc."
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_ULTALO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0017 //"Seq. Atual"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0017 //"Seq. Atual"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_SEQ"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_SEQ")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0018 //"Seq. Implantação"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0018 //"Seq. Implantação"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_IMPSEQ"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_SEQ")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0019 //"Trab. Prox. Feriado?"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0019 //"Trab. Prox. Feriado?"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_PROXFE"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "9"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
    aRet[nAux][DEF_LISTA_VAL] := { "1="+STR0020, "2="+STR0021, "3="+STR0022} //"Sim"#"Não"#"Não se aplica"
    aRet[nAux][DEF_COMBO_VAL] := { "1="+STR0020, "2="+STR0021, "3="+STR0022} //"Sim"#"Não"#"Não se aplica"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := "RECNO"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "RECNO"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_RECTGY"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 16
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At190ILimp
	Limpa os registros do grid

@author	boiani
@since	25/11/2020
/*/
//-------------------------------------------------------------------
Function At190ILimp()
Local oModel := FwModelActive()
Local oMdlTGY := oModel:GetModel("TGYDETAIL")
Local oView := FwViewActive()

oMdlTGY:SetNoInsertLine(.F.)
oMdlTGY:SetNoDeleteLine(.F.)

oMdlTGY:ClearData()
oMdlTGY:InitLine()

If !isBlind() .AND. VALTYPE(oView) == 'O'
    oView:Refresh('DETAIL_TGY')
EndIF

oMdlTGY:SetNoInsertLine(.T.)
oMdlTGY:SetNoDeleteLine(.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At190ILimp
	Carrega a configuração de alocação no grid

@author	boiani
@since	25/11/2020
/*/
//-------------------------------------------------------------------
Function At190ILoad()
Local oModel := FwModelActive()
Local oMdlTGY := oModel:GetModel("TGYDETAIL")
Local oMdlTFF := oModel:GetModel("TFFMASTER")
Local cPosto := oMdlTFF:GetValue("TFF_CODIGO")
Local cFilTFF := ''
Local cSql
Local cAliasQry
Local nLinha := 1
Local oView := FwViewActive()
Local lMulFil 	:= TecMultFil()

If lMulFil 
	cFilTFF := oMdlTFF:GetValue("TFF_FILIAL")
Else
	cFilTFF := xFilial("TFF")
EndIf

At190ILimp()

oMdlTGY:SetNoInsertLine(.F.)
oMdlTGY:SetNoDeleteLine(.F.)

If !EMPTY(cPosto)
    cSql := " SELECT TGY.TGY_ATEND, AA1.AA1_NOMTEC, TGY.TGY_ULTALO, "
    cSql += " TGY.TGY_SEQ, TDX_SEQTUR, TGY.TGY_PROXFE, TGY.R_E_C_N_O_ REC "
    cSql += " FROM " + RetSqlName( "TGY" ) + " TGY "
    cSql += " INNER JOIN " + RetSqlName( "AA1" ) + " AA1 ON "
    cSql += " AA1.AA1_FILIAL = '" + xFilial("AA1") + "' AND "
    cSql += " AA1.D_E_L_E_T_ = ' ' AND "
    cSql += " AA1.AA1_CODTEC = TGY.TGY_ATEND "
    cSql += " INNER JOIN " + RetSqlName( "TDX" ) + " TDX ON "
    cSql += " TDX.TDX_FILIAL = '" + xFilial("TDX", cFilTFF) + "' AND "
    cSql += " TDX.TDX_COD = TGY.TGY_CODTDX AND "
    cSql += " TDX.D_E_L_E_T_ = ' ' "
    cSql += " WHERE "
    cSql += " TGY.D_E_L_E_T_ = ' ' AND "
    cSql += " TGY.TGY_FILIAL = '" + xFilial("TGY",cFilTFF) + "' AND "
    cSql += " TGY.TGY_CODTFF = '" + cPosto + "' "
    cSql := ChangeQuery(cSql)
    cAliasQry := GetNextAlias()
    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

    While !(cAliasQry)->(EOF())
        If !oMdlTGY:IsEmpty()
            nLinha := oMdlTGY:AddLine()
        EndIf
        oMdlTGY:GoLine(nLinha)
        oMdlTGY:LoadValue("TGY_CODTEC",(cAliasQry)->TGY_ATEND)
        oMdlTGY:LoadValue("TGY_NOMTEC",(cAliasQry)->AA1_NOMTEC)
        oMdlTGY:LoadValue("TGY_ULTALO",STOD((cAliasQry)->TGY_ULTALO))
        oMdlTGY:LoadValue("TGY_SEQ",(cAliasQry)->TGY_SEQ)
        oMdlTGY:LoadValue("TGY_IMPSEQ",(cAliasQry)->TDX_SEQTUR)
        If EMPTY((cAliasQry)->TGY_PROXFE)
            oMdlTGY:LoadValue("TGY_PROXFE",'3')
        Else
            oMdlTGY:LoadValue("TGY_PROXFE",(cAliasQry)->TGY_PROXFE)
        EndIf
        oMdlTGY:LoadValue("TGY_RECTGY",(cAliasQry)->REC)
        (cAliasQry)->(DbSkip())
    End
    (cAliasQry)->(DbCloseArea())
    oMdlTGY:GoLine(1)
    If !isBlind() .AND. VALTYPE(oView) == 'O'
        oView:Refresh('DETAIL_TGY')
    EndIF
EndIf

oMdlTGY:SetNoInsertLine(.T.)
oMdlTGY:SetNoDeleteLine(.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AT190IVlFl
	Validação do posto e calendário

@author	boiani
@since	25/11/2020
/*/
//-------------------------------------------------------------------
Function AT190IVlFl(oMdlTFF,cField,xNewValue)
Local lRet 		:= .T.
Local lMulFil 	:= TecMultFil()
If !EMPTY(xNewValue)
    If cField == "TFF_CODIGO"
        DbSelectArea("TFF")
        DbSetOrder(1)
		If lMulFil
        	lRet := DbSeek(xFilial("TFF",oMdlTFF:GetValue("TFF_FILIAL"))+xNewValue)
		Else
			lRet := DbSeek(xFilial("TFF")+xNewValue)
		EndIf
    ElseIf cField == "TFF_CALEND"
        DbSelectArea("AC0")
        DbSetOrder(1)
		If lMulFil
       		lRet := DbSeek(xFilial("AC0",oMdlTFF:GetValue("TFF_FILIAL"))+xNewValue)
		Else
			lRet := DbSeek(xFilial("AC0")+xNewValue)
		EndIf
    EndIf
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AT190IVld
	Validação da modificação do calendário no posto

@author	boiani
@since	25/11/2020
/*/
//-------------------------------------------------------------------
Function AT190IVld()
Local lRet := .T.
Local lMulFil 	:= TecMultFil()
Local oModel := FwModelActive()
Local oMdlTFF := oModel:GetModel("TFFMASTER")
Local oMdlTGY := oModel:GetModel("TGYDETAIL")
Local cCodTFF := oMdlTFF:GetValue("TFF_CODIGO")
Local cCalend := oMdlTFF:GetValue("TFF_CALEND")
Local cFilTFF := IIF(lMulFil,oMdlTFF:GetValue("TFF_FILIAL"),xFilial("TFF"))

If !EMPTY(cCodTFF)
    If POSICIONE("TFF",1,xFilial("TFF",cFilTFF) + cCodTFF,"TFF_CALEND") != cCalend
        If !isBlind()
            lRet := MsgYesNo(STR0023) //"A operação modificará o calendário do Posto. Deseja continuar?"
        EndIF
    EndIF
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AT190ICmt
@description Bloco de código executado para gravar o modelo

@author	boiani
@since	25/11/2020
/*/
//-------------------------------------------------------------------
Function AT190ICmt()
Local oModel := FwModelActive()
Local lMulFil 	:= TecMultFil()
Local oMdlTFF := oModel:GetModel("TFFMASTER")
Local oMdlTGY := oModel:GetModel("TGYDETAIL")
Local nX
Local cPosto := oMdlTFF:GetValue("TFF_CODIGO")
Local cFilTFF := IIF(lMulFil,oMdlTFF:GetValue("TFF_FILIAL"),xFilial("TFF"))
Local cCalend := oMdlTFF:GetValue("TFF_CALEND")

If !EMPTY(cPosto)
    Begin Transaction
        DbSelectArea("TFF")
        DbSetOrder(1)
        If TFF->(DbSeek(xFilial("TFF", cFilTFF) + cPosto))
            TFF->(RECLOCK("TFF", .F.))
            TFF->TFF_CALEND := cCalend
            TFF->( MsUnlock() )

            DbSelectArea("TGY")
            DbSetOrder(1)

            For nX := 1 TO oMdlTGY:Length()
                oMdlTGY:GoLine(nX)
                If !EMPTY(oMdlTGY:GetValue("TGY_RECTGY"))
                    TGY->(DBGoTo(oMdlTGY:GetValue("TGY_RECTGY")))
                    TGY->(RECLOCK("TGY", .F.))
                    TGY->TGY_PROXFE := oMdlTGY:GetValue("TGY_PROXFE")
                    TGY->( MsUnlock() )
                EndIf
            Next nX
        EndIf
    End Transaction
EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AT190ICmt
@description Bloco de código executado no activate
@param oModel, obj, modelo em ativação

@author	boiani
@since	25/11/2020
/*/
//-------------------------------------------------------------------
Static Function InitDados(oModel)
Local oMdlTGY := oModel:GetModel('TGYDETAIL')

oMdlTGY:SetNoInsertLine(.T.)
oMdlTGY:SetNoDeleteLine(.T.)

Return
