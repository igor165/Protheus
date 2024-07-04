#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA870D.ch"

Static cRetF3 		:= ""

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
/*/{Protheus.doc} TECA870D

@description Revisão em Lote

@author	Luiz Gabriel
@since	22/06/2020
/*/
//------------------------------------------------------------------------------
Function TECA870D()
Local aButtons := {}

aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0002},; //"Processar"
				{.T.,STR0003},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // "Fechar"

FWExecView("","VIEWDEF.TECA870D", MODEL_OPERATION_INSERT,,,,,aButtons)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados

@author	Luiz Gabriel
@since 22/06/2020
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	
Local oStrDAT		:= FWFormModelStruct():New()
Local oStrFIL		:= FWFormModelStruct():New()
Local oStrCTR		:= FWFormModelStruct():New()
Local aFields		:= {}
Local nX			:= 0
Local nY			:= 0
Local aTables 		:= {}
Local xAux
Local bCommit		:= {|oModel| At870DGrav(oModel)}

oStrDAT:AddTable("   ",{}, STR0001) //"Revisão em Lote"
oStrFIL:AddTable("   ",{}, "   ")
oStrCTR:AddTable("   ",{}, "   ")

AADD(aTables, {oStrDAT, "DAT"})
AADD(aTables, {oStrFIL, "ORC"})
AADD(aTables, {oStrCTR, "CTR"})

For nY := 1 To LEN(aTables)
	aFields := AT870DTbl(aTables[nY][2])

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

//Gatilho do cabeçalho
xAux := FwStruTrigger( 'DAT_REVISA', 'DAT_DESCRI',;
	'Posicione("CN0",1,xFilial("CN0") + FwFldGet("DAT_REVISA"),"CN0_DESCRI")', .F. )
	oStrDAT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'DAT_PERCEN', 'DAT_PERCEN','AT870DPerG()', .F. )
	oStrDAT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

//Gatilhos do grid
xAux := FwStruTrigger( 'CTR_FUNCAO', 'CTR_DFUNC',;
	'Alltrim(Posicione("SRJ",1,xFilial("SRJ")+FwFldGet("CTR_FUNCAO"), "RJ_DESC"))', .F. )
	oStrCTR:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'CTR_TURNO', 'CTR_DTURNO',;
	'Alltrim(Posicione("SR6",1,xFilial("SR6")+FwFldGet("CTR_TURNO"), "R6_DESC"))', .F. )
	oStrCTR:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'CTR_CARGO', 'CTR_DCARGO',;
	'Alltrim(Posicione("SQ3",1,xFilial("SQ3")+FwFldGet("CTR_CARGO"), "Q3_DESCSUM"))', .F. )
	oStrCTR:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'CTR_ESCALA', 'CTR_NOMESC',;
	'Alltrim(Posicione("TDW",1,xFilial("TDW") + FwFldGet("CTR_ESCALA"),"TDW_DESC"))', .F. )
	oStrCTR:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'CTR_CALEND', 'CTR_DSCALE',;
	'Alltrim(Posicione("AC0",1,XFILIAL("AC0") + FwFldGet("CTR_CALEND"),"AC0_DESC"))', .F. )
	oStrCTR:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'CTR_PRODUT', 'CTR_DESCRI',;
	'Alltrim(Posicione("SB1",1,XFILIAL("SB1") + FwFldGet("CTR_PRODUT"),"B1_DESC"))', .F. )
	oStrCTR:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'CTR_LOCAL', 'CTR_DESLOC',;
	'Alltrim(Posicione("ABS",1,XFILIAL("ABS") + FwFldGet("CTR_LOCAL"),"ABS_DESCRI"))', .F. )
	oStrCTR:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'CTR_SUBTOT', 'CTR_PERCEN',;
	'AT870DPerC( FwFldGet("CTR_SUBTOT") )', .F. )
	oStrCTR:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'CTR_QTDVEN', 'CTR_SUBTOT',;
	'AT870DQTDS( FwFldGet("CTR_QTDVEN"), FwFldGet("CTR_PRCVEN") )', .F. )
	oStrCTR:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'CTR_PRCVEN', 'CTR_SUBTOT',;
	'AT870DQTDS( FwFldGet("CTR_QTDVEN"), FwFldGet("CTR_PRCVEN") )', .F. )
	oStrCTR:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'ORC_CAMPOS', 'ORC_CAMPOS','At870DClr("ORC_CAMPOS")', .F. )
	oStrFIL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'ORC_ENTIDADE', 'ORC_ENTIDADE','At870DClr("ORC_ENTIDADE")', .F. )
	oStrFIL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

oStrCTR:SetProperty('CTR_PERFIM',MODEL_FIELD_VALID,{|oModel|AT870DVldDT(oModel:GetModel(), "CTR_PERFIM")})

oModel := MPFormModel():New('TECA870D',/*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/)
oModel:AddFields('DATMASTER',/*cOwner*/,oStrDAT,,/*bPosValidacao*/,/*bFieldAbp*/,/*bCarga*/,/*bFieldTfl*/)

oModel:addGrid('ORCMASTER','DATMASTER',oStrFIL)
oModel:addGrid('CTRMASTER','DATMASTER',oStrCTR,{|oModel,nLine,cAcao,cCampo, xValue, xOldValue| a870PrcVen(oModel, nLine, cAcao, cCampo, xValue, xOldValue)})

oModel:setDescription(STR0001) //"Revisão em Lote"

oModel:SetPrimaryKey({'DAT_INI'})

oModel:GetModel('DATMASTER'):SetDescription(STR0001) //"Revisão em Lote"
oModel:GetModel('ORCMASTER'):SetDescription(STR0004) //"Filtros"
oModel:GetModel('CTRMASTER'):SetDescription(STR0005) //"Contratos"

//Não permite incluir e nem apagar registros no grid
oModel:GetModel('CTRMASTER'):SetNoInsertLine(.T.)
oModel:GetModel('CTRMASTER'):SetNoDeleteLine(.T.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	Luiz Gabriel
@since 22/06/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil
Local oModel 	:= ModelDef()
Local oStrDAT	:= FWFormViewStruct():New()
Local oStrFIL	:= FWFormViewStruct():New()
Local oStrCTR	:= FWFormViewStruct():New()
Local aTables 	:= {}
Local aFields	:= {}
Local aTamanhoLC := {}
Local lMonitor	:= IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
Local nX		:= 0
Local nY		:= 0

AADD(aTables, {oStrDAT, "DAT"})
AADD(aTables, {oStrFIL, "ORC"})
AADD(aTables, {oStrCTR, "CTR"})

For nY := 1 to LEN(aTables)
	aFields := AT870DTbl(aTables[nY][2])

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

If lMonitor
	oView:SetContinuousForm()
	AADD(aTamanhoLC, 08.00)
	AADD(aTamanhoLC, 10.00)
	AADD(aTamanhoLC, 82.00)
	AADD(aTamanhoLC, 03)
	AADD(aTamanhoLC, 27)
	AADD(aTamanhoLC, 10)
	AADD(aTamanhoLC, 60)
Else
	AADD(aTamanhoLC, 06.00)
	AADD(aTamanhoLC, 06.00)
	AADD(aTamanhoLC, 88.00)
	AADD(aTamanhoLC, 15)
	AADD(aTamanhoLC, 27)
	AADD(aTamanhoLC, 05)
	AADD(aTamanhoLC, 53)
EndIf

oStrCTR:RemoveField("CTR_TOTALC")
oStrCTR:RemoveField("CTR_RECNO")
oStrCTR:RemoveField("CTR_PLAN")

oView:AddField('VIEW_MASTER', oStrDAT, 'DATMASTER')

oView:AddGrid('VIEW_ORC',  oStrFIL, 'ORCMASTER')
oView:EnableTitleView('VIEW_ORC', STR0004) //"Filtros"

oView:AddGrid('VIEW_CTR',  oStrCTR, 'CTRMASTER')
oView:EnableTitleView('VIEW_CTR', STR0005) //"Contratos"

oView:CreateHorizontalBox('DATA',   aTamanhoLC[4])
oView:CreateHorizontalBox('Filtro', aTamanhoLC[5])
oView:CreateHorizontalBox('BOTOES', aTamanhoLC[6])
oView:CreateHorizontalBox('Contr',  aTamanhoLC[7])

oView:CreateVerticalBox( "LEFT_1",  aTamanhoLC[1], 'BOTOES')
oView:CreateVerticalBox( "LEFT_2",  aTamanhoLC[2], 'BOTOES')
oView:CreateVerticalBox( "LEFT_3",  aTamanhoLC[3], 'BOTOES')

oView:AddOtherObject("MARK",{|oPanel| a190dAllM(oPanel) })
oView:SetOwnerView("MARK","LEFT_1")

oView:AddOtherObject("BUSCA",{|oPanel| a870DSerch(oPanel) })
oView:SetOwnerView("BUSCA","LEFT_2")

oView:SetOwnerView('VIEW_MASTER','DATA')
oView:SetOwnerView('VIEW_ORC','Filtro')
oView:SetOwnerView('VIEW_CTR','Contr')

oView:AddUserButton(STR0130,"",{|| At870DSelCT(oModel) },,,)  //"Seleção de Contratos"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870DTbl

@description Retorna em forma de Array as definições dos campos

@param cTable, string, define de qual tabela devem ser os campos retornados

@return aRet, array, definição dos campos

@author	Luiz Gabriel
@since	22/06/2020
/*/
//------------------------------------------------------------------------------
Function AT870DTbl(cTable)
Local aRet := {}
Local nAux := 0

If cTable == "DAT"  //Cabeçalho
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0006 //"Tipo da Revisão"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "CN0_CODIGO", .F. ) //"Tipo da Revisão"
	aRet[nAux][DEF_IDENTIFICADOR] := "DAT_REVISA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN0_CODIGO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "CN0"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0006}	//"Tipo da Revisão"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "CN0_DESCRI", .T. )  //"Descrição"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "CN0_DESCRI", .F. ) //"Descrição"
	aRet[nAux][DEF_IDENTIFICADOR] := "DAT_DESCRI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN0_DESCRI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0007 // "Percentual de Reajuste"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0007// "Percentual de Reajuste"
	aRet[nAux][DEF_IDENTIFICADOR] := "DAT_PERCEN"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 4
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@E 999.9999"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0008} //"Indice de Reajuste dos contratos em %"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0118 // "Efetiva Revisão?"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0118 // "Efetiva Revisão?"
	aRet[nAux][DEF_IDENTIFICADOR] := "DAT_EFETIV"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_INIT] := {||2}
	aRet[nAux][DEF_LISTA_VAL] := { "1="+STR0119, "2="+STR0120} // SIM ## NÃO  
	aRet[nAux][DEF_COMBO_VAL] := { "1="+STR0119, "2="+STR0120} // SIM ## NÃO
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0121} // "Indica se realizara a efetivação da revisão."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0122 // "Aprova Revisão?"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0122 // "Aprova Revisão?"
	aRet[nAux][DEF_IDENTIFICADOR] := "DAT_APROVA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_INIT] := {||2}
	aRet[nAux][DEF_LISTA_VAL] := { "1="+STR0119, "2="+STR0120} // SIM ## NÃO  
	aRet[nAux][DEF_COMBO_VAL] := { "1="+STR0119, "2="+STR0120} // SIM ## NÃO
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0123} // "Indica se realizara a aprovação da revisão."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0124 // "Reajusta H.E.?"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0124 // "Reajusta H.E.?"
	aRet[nAux][DEF_IDENTIFICADOR] := "DAT_APLIHE"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_INIT] := {||2}
	aRet[nAux][DEF_LISTA_VAL] := { "1="+STR0119, "2="+STR0120} // SIM ## NÃO  
	aRet[nAux][DEF_COMBO_VAL] := { "1="+STR0119, "2="+STR0120} // SIM ## NÃO
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0125} // "Indica se aplicara o percentual para os registros da Hora Extra."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0126 // "Reajusta MI?"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0126 // "Reajusta MI?"
	aRet[nAux][DEF_IDENTIFICADOR] := "DAT_APLIMI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_INIT] := {||2}
	aRet[nAux][DEF_LISTA_VAL] := { "1="+STR0119, "2="+STR0120} // SIM ## NÃO  
	aRet[nAux][DEF_COMBO_VAL] := { "1="+STR0119, "2="+STR0120} // SIM ## NÃO
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0127} // "Indica se aplicara o percentual para os registros da Materiais de Implantação."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] :=  STR0128 // "Reajusta MC?"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] :=  STR0128 // "Reajusta MC?"
	aRet[nAux][DEF_IDENTIFICADOR] := "DAT_APLIMC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_INIT] := {||2}
	aRet[nAux][DEF_LISTA_VAL] := { "1="+STR0119, "2="+STR0120} // SIM ## NÃO  
	aRet[nAux][DEF_COMBO_VAL] := { "1="+STR0119, "2="+STR0120} // SIM ## NÃO
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0129} // "Indica se aplicara o percentual para os registros da Materiais de Consumo."

ElseIf cTable == "ORC" //Filtros

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0009 // "Entidade"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0009 // "Entidade"
	aRet[nAux][DEF_IDENTIFICADOR] := "ORC_ENTIDADE"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 3
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_LISTA_VAL] := { "TFJ="+STR0010, "TFL="+STR0011, "TFF="+STR0012} // "Cabeçalho do Orçamento" ## "Local de Atendimento" ## "Itens de RH"
	aRet[nAux][DEF_COMBO_VAL] := { "TFJ="+STR0010, "TFL="+STR0011, "TFF="+STR0012} // "Cabeçalho do Orçamento" ## "Local de Atendimento" ## "Itens de RH"
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0013}	//"Entidades"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0014 // "Campo"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0014 // "Campo"
	aRet[nAux][DEF_IDENTIFICADOR] := "ORC_CAMPOS"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN9_NUMERO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "T87DTA" 
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0015}	//"Campos a serem considerados no filtro"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0016 //"Valor"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0016 //"Valor"
	aRet[nAux][DEF_IDENTIFICADOR] := "ORC_PRODF"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN9_NUMERO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "T87DSU" 
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0015}	//"Campos a serem considerados no filtro"

ElseIf cTable == "CTR" //Contratos
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0017	//"Mark"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0017	//"Mark"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_MARK"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "L"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "CHECK"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0007 // "Percentual de Reajuste"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0007 // "Percentual de Reajuste"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_PERCEN"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 4
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@E 999.9999"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0008} //"Indice de Reajuste dos contratos em %"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_CONTRT", .T. ) //"Contrato"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_CONTRT", .F. ) //"Contrato"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_CONTRT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_CONTRT")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0018}	//"Número do contrato"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_CONREV", .T. ) //"Revisão Contrato"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_CONREV", .F. ) //"Revisão Contrato"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_CONREV"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_CONREV")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0019}	//"Revisão do contrato"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFL_LOCAL", .T. ) //"Local de Atendimento"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFL_LOCAL", .F. ) //"Local de Atendimento"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_LOCAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFL_LOCAL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0011} //"Local de Atendimento"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "ABS_DESCRI", .T. )  //"Descrição do Local"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "ABS_DESCRI", .F. ) //"Descrição do Local"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_DESLOC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_DESCRI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_COD", .T. ) //"Código recursos humanos"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_COD", .F. ) //"Código recursos humanos"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_TFFCOD"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_COD")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0020} //"Código recursos humanos"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_PRODUT", .T. ) //"Produto"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_PRODUT", .F. ) //"Produto"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_PRODUT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_PRODUT")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0021}	//"Produto do Contrato"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_DESCRI", .T. )	//"Descrição"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_DESCRI", .F. )	//"Descrição"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_DESCRI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_DESCRI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0022}	//"Descrição do produto de RH"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_QTDVEN", .T. )	//"Quantidade"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_QTDVEN", .F. )//"Quantidade"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_QTDVEN"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_QTDVEN")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := TamSX3("TFF_QTDVEN")[2]
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "10"
	aRet[nAux][DEF_PICTURE] := X3Picture( "TFF_QTDVEN" )
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0023}	//"Quantidade de venda"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_PRCVEN", .T. ) //"Valor Unitario"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_PRCVEN", .F. ) //"Valor Unitario"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_PRCVEN"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_PRCVEN")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := TamSX3("TFF_PRCVEN")[2]
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "11"
	aRet[nAux][DEF_PICTURE] := X3Picture( "TFF_PRCVEN" )
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0024}	//"Valor Unitario do Produto"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_SUBTOT", .T. ) //"SubTotal"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_SUBTOT", .F. ) //"SubTotal"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_SUBTOT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_SUBTOT")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := TamSX3("TFF_SUBTOT")[2]
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "12"
	aRet[nAux][DEF_PICTURE] := X3Picture( "TFF_SUBTOT" )
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0025}	//"Valor Total do Item"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_PERINI", .T. ) //"Per. Inicio "
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_PERFIM", .F. ) //"Per. Inicio "
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_PERINI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "13"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0026}	//"Inicio do periodo de Alocação."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_PERFIM", .T. )	// "Per. Fim "
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_PERFIM", .F. ) // "Per. Fim "
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_PERFIM"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "14"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0027}	//"Fim do periodo de alocação"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_FUNCAO", .T. ) //"Função"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_FUNCAO", .F. ) //"Função"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_FUNCAO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_FUNCAO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "15"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0028}	//"Função vendida no contrato"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_DFUNC", .T. ) //"Descrição"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_DFUNC", .F. ) //"Descrição da Função"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_DFUNC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_DFUNC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "16"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0029}	//"Descrição da Função vendida no contrato"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_TURNO", .T. ) //"Turno"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_TURNO", .F. ) //"Código do Turno"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_TURNO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_TURNO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "17"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0030}	//"Turno do contrato"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_DTURNO", .T. ) //"Descrição"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_DTURNO", .F. ) //"Descrição do Turno"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_DTURNO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_DTURNO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "18"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0031}	//"Descrição do turno vendida no contrato"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_SEQTRN", .T. ) //"Seq. turno"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_SEQTRN", .F. ) //"Seq. Ini. do Turno"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_SEQTRN"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_SEQTRN")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "19"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0032}	//"Sequencia do turno no contrato"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_CARGO", .T. ) //"Cargo"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_CARGO", .F. ) //"Cargo do Recurso"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_CARGO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_CARGO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "20"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0033}	//"Cargo vendido no contrato"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_DCARGO", .T. ) //"Desc.Cargo"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_DCARGO", .F. ) //"Descrição do Cargo"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_DCARGO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_DCARGO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "21"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0034}	//"Descrição do Cargo vendido no contrato"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_ESCALA", .T. ) //"Escala"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_ESCALA", .F. ) //"Codigo da Escala"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_ESCALA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_ESCALA")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "22"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0035}	//"Escala vendida no contrato"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_NOMESC", .T. ) //"Desc. Escala"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_NOMESC", .F. ) //"Descricao da Escala"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_NOMESC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_NOMESC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "23"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {"Descrição da Escala vendida no contrato"}	//"Descrição da Escala vendida no contrato"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_CALEND", .T. ) //"Calendario"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_CALEND", .F. ) //"Codigo do Calendario"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_CALEND"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_CALEND")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "24"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0036}	//"Calendario utilizado no contrato"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_DSCALE", .T. ) //"Desc. Calend"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_DSCALE", .F. ) //"Descricao do Calendario"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_DSCALE"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_DSCALE")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "25"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {"Descrição do Calendario utilizado no contrato"}	//"Descrição do Calendario utilizado no contrato"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_INSALU", .T. ) //"Insalub."
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_INSALU", .F. ) //"Insalubridade"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_INSALU"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 15
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "26"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0037}	//"Informa se o item possui insalubridade"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_GRAUIN", .T. ) //"Grau Insal."
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_GRAUIN", .F. ) //"Grau de Insalubridade"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_GRAUIN"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 15
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "27"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0038}	//"Grau de insalubridade do item"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_PERICU", .T. ) //"Pericul."
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_PERICU", .F. ) //"Periculosidade"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_PERICU"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 15
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "28"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0039}	//"Informa se o item tem periculosidade"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_TESPED", .T. ) //"TES Pedido"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_TESPED", .F. ) //"TES Pedido de venda"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_TESPED"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_TESPED")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "29"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0040}	//"TES para o pedido de venda"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_PRCVEN", .T. ) //"Valor Unitario"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_PRCVEN", .F. ) //"Valor Unitario"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_TOTALC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_PRCVEN")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := TamSX3("TFF_PRCVEN")[2]
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "30"
	aRet[nAux][DEF_PICTURE] := X3Picture( "TFF_PRCVEN" )
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0024}	//"Valor Unitario do Produto"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := "RECNO"	//"RECNO"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "RECNO"	//"RECNO"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_RECNO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 16
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "31"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := "Planilha"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] :="Planilha"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_PLAN"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFL_PLAN")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "32"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0109}	//"Planilha do contrato"

EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} a190dAllM

@description Cria o botão "Marcar Todos"
@param oPanel, obj, dialog em que o botão será criado

@author	Luiz Gabriel
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function a190dAllM(oPanel)

TButton():New( (oPanel:nHeight / 2) - 13, 5, STR0041 , oPanel, { || At870dMrk() },43,12,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Marcar ## Desmarcar Todos"

Return ( Nil )

//------------------------------------------------------------------------------
/*/{Protheus.doc} A870dSerch

@description Cria o botão "Buscar"
@param oPanel, obj, dialog em que o botão será criado

@author	Luiz Gabriel
@since	22/06/2020
/*/
//------------------------------------------------------------------------------
Static Function A870dSerch(oPanel)

TButton():New( (oPanel:nHeight / 2) - 13, 5, STR0042, oPanel, { || FwMsgRun(Nil,{|| lRet := At870Carga()}, Nil, STR0043) },50,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Buscar" # Processando

Return ( Nil )

//------------------------------------------------------------------------------
/*/{Protheus.doc} A870dCombo

@description Cria os campos do tipo Combo para o campo ORC_CAMPOS

@author	Luiz Gabriel
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Function A870dCombo()
Local aIdx    	:= {}
Local aSeek     	:= {}
Local aStruct		:= {}
Local aColumns		:= {}
Local aCampoTFF		:= {"TFF_CALEND", "TFF_CARGO", "TFF_FUNCAO", "TFF_PRODUT", "TFF_TURNO", "TFF_ESCALA", "TFF_INSALU", "TFF_PERICU", "TFF_GRAUIN", "TFF_RISCO", "TFF_TESPED"}
Local aCampoTFL		:= {"TFL_MUNIC", "TFL_LOCAL", "TFL_ESTADO"}
Local aCampoTFJ		:= {"TFJ_ANTECI", "TFJ_CODIGO", "TFJ_CONDPG", "TFJ_CNTREC", "TFJ_CONTRT"}
Local oDlgEscTela 	:= Nil
Local nSuperior  	:= 0
Local nEsquerda 	:= 0
Local nInferior 	:= 0
Local nDireita  	:= 0
Local nStepCmmIns	:= 900 //Quantidade do lote de regsitros a serem gravados na tabela temporária a cada INSERT do objeto GsTmpTable
Local cTabela		:= AllTrim(FwFldGet("ORC_ENTIDADE"))
Local aDados	:= {}
Local aCombo	:= {}
Local nX
Local nY

If !Empty(cTabela)
	//Cria estrutura e tabela tmp com os campos necessarios
	//Aadd(aStruct, {"OK"         , "C", 1 , 0})
	Aadd(aStruct, {"X3_CAMPO"	, "C", 15	, 0})
	Aadd(aStruct, {"X3_TITULO"	, "C", 25	, 0})


	//Cria indices para a tabela temporária 
	Aadd(aIdx, {"I1",{ 'X3_CAMPO' }})
	Aadd(aIdx, {"I2",{ 'X3_TITULO' }})
	
	//Aadd(aIdx, {"I2",{ 'ABB_CODTEC' }})

	//Cria arABBy da busca de acordo com os indices da tabela temporária
	aAdd(aSeek, { STR0110, {{"","C",15,0,STR0110,,"X3_CAMPO"}} })
	aAdd(aSeek, { STR0111, {{"","C",50,0,STR0111,,"X3_TITULO"}} })	
		
	//Instancia o método NEW para criação da tabela temporária
	oGSTmpTb := GSTmpTable():New('TRBAA1',aStruct, aIdx, {}, nStepCmmIns )
	cRetTab  := 'TRBAA1'

	//Validação para a criação da tabela temporária
	If !oGSTmpTb:CreateTMPTable()
		oGSTmpTb:ShowErro()
	Else
		aCombo := FWSX3Util():GetListFieldsStruct(cTabela , .F.)
		For nX := 1 To Len(aCombo)
			If GetSX3Cache( aCombo[nX][1] , "X3_PROPRI" ) == "U" .AND. aCombo[nX][2] <> 'D'
				AADD(aDados, {aCombo[nX][1], TecTituDes(aCombo[nX][1])})
			Else
				If cTabela == 'TFF' .AND. aScan(aCampoTFF, { |x| x == aCombo[nX][1]}) > 0
					AADD(aDados, {aCombo[nX][1], TecTituDes(aCombo[nX][1])})
				ElseIf cTabela == 'TFL' .AND. aScan(aCampoTFL, { |x| x == aCombo[nX][1]}) > 0
					AADD(aDados, {aCombo[nX][1], TecTituDes(aCombo[nX][1])})
				ElseIf cTabela == 'TFJ' .AND. aScan(aCampoTFJ, { |x| x == aCombo[nX][1]}) > 0
					AADD(aDados, {aCombo[nX][1], TecTituDes(aCombo[nX][1])})
				EndIf
			EndIf
		Next nX
		//Preenche Tabela temporária com as informações filtradas
		For nX := 1 To Len(aDados)
			aInsertTmp :={}
			Aadd(aInsertTmp, {'X3_CAMPO'	,aDados[nX][1]})
			Aadd(aInsertTmp, {'X3_TITULO'		,aDados[nX][2]})

			If oGSTmpTb:Insert(aInsertTmp)
				lOk := oGSTmpTb:Commit()
			Else
				lOk := .F.
				Exit
			EndIf
		Next nX
		
		For nY := 1 To Len(aStruct)
			If !(aStruct[nY][1] == "OK")
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nY][1]+"}") )			
				aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nY][1]))
				aColumns[Len(aColumns)]:SetSize(aStruct[nY][3])
				aColumns[Len(aColumns)]:SetDecimal(aStruct[nY][4])
				aColumns[Len(aColumns)]:SetPicture(PesqPict(cRetTab,aStruct[nY][1]))
			EndIf
		Next nY
		IF !IsBlind()
		    nInferior := GetScreenRes()[2] * 0.6
		    nDireita  := GetScreenRes()[1] * 0.65

		    DEFINE MSDIALOG oDlgEscTela TITLE STR0014 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL // "Campo"
			    oMrkBrowse	:= FWMarkBrowse():New()
			    oMrkBrowse:SetOwner(oDlgEscTela)
			    oMrkBrowse:DisableFilter()
			    oMrkBrowse:SetDescription(STR0112) //"Tabela"
			    oMrkBrowse:SetTemporary(.T.)   
			    oMrkBrowse:AddButton( OemTOAnsi(STR0044), {|| cRetF3  := (cRetTab)->X3_CAMPO, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
			    oMrkBrowse:AddButton( OemTOAnsi(STR0045),  {|| cRetF3  := "", oDlgEscTela:End() } ,, 2 )	//"Cancelar"
			    oMrkBrowse:SetAlias(cRetTab) //Seta o arquivo temporario para exibir a seleção dos dados
			    oMrkBrowse:SetSeek(.T., aSeek)       
			    oMrkBrowse:SetColumns(aColumns)
			    oMrkBrowse:DisableReport()
			    oMrkBrowse:SetMenuDef("")
			    oMrkBrowse:Activate()
		    ACTIVATE MSDIALOG oDlgEscTela CENTERED	
			     
		    oGSTmpTb:Close()
	     	TecDestroy(oGSTmpTb)
        Endif     	    
	EndIf
Else 
	Help( " ", 1, STR0047, Nil, STR0048, 1 )	// "Campos" ## "Não há Entidade selecionada"
EndIf 

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190SetFlt

@description Chama a função que cria os filtros nas consultas padrões
@author	fabiana.silva	
@since	05/03/2020
/*/
//------------------------------------------------------------------------------
Static Function At190SetFlt(aSeek, oBrowse)

Local aFilter := {}
Local nC := 0

For nC := 1 to Len(aSeek)
	If Len(aSeek[nC]) >= 2 .and. Len(aSeek[nC, 02]) == 1 .AND.  Len(aSeek[nC, 02, 01]) >= 7 .and. !Empty(aSeek[nC, 02, 01 ,07])
		If aScan(aFilter, {|f| f[1] == aSeek[nC, 02, 01, 07]}) == 0
			aAdd(aFilter, {aSeek[nC, 02, 01, 07], aSeek[nC, 02,01, 05], aSeek[nC, 02,01, 02], aSeek[nC, 02,01, 03], aSeek[nC, 02,01, 04], IIF(Empty(aSeek[nC, 02,01, 06]), "", aSeek[nC, 02, 01, 06])})
		EndIf
	EndIf
Next nC 

If Len(aFilter) > 0
	oBrowse:SetTemporary(.T.)
	oBrowse:SetDBFFilter(.T.)
	oBrowse:SetFilterDefault( "" ) 
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetFieldFilter(aFilter)
EndIf
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} At870dRF3()

Retorno da consulta especifica

@author Luiz Gabriel
@since 30/05/2019
/*/
//------------------------------------------------------------------
Function At870dRF3()

Return cRetF3

//-------------------------------------------------------------------
/*/{Protheus.doc} At870DSuCa()

Consulta Padrão para o campo ORC_CAMPOS

@author Luiz Gabriel
@since 30/05/2019
/*/
//------------------------------------------------------------------
Function At870DSuCa()
Local cTabela	:= AllTrim(FwFldGet("ORC_ENTIDADE"))
Local cCampo	:= AllTrim(FwFldGet("ORC_CAMPOS"))
Local cValor	:= ""

If !Empty(cTabela) .And. !Empty(cCampo)
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek(cCampo))
		cValor := AllTrim(X3CBox()) //Verifica se é campo combo
	EndIf
	
	If !Empty(cValor)
		A870dBrwArr(cTabela,cCampo,cValor)
	Else 
		a870dBrwQry(cTabela,cCampo)
	EndIf 
Else 
	Help( " ", 1, STR0047, Nil, STR0049, 1 )	// "Campos" ## "Informe uma entidade ou campo para seleção"
EndIf 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} a870dBrwQry()

Cria o browse para consulta padrão com query

@author Luiz Gabriel
@since 30/05/2019
/*/
//------------------------------------------------------------------
Function a870dBrwQry(cTabela,cCampo)
Local aIndex    	:= {}
Local aSeek     	:= {}
Local oDlgEscTela 	:= Nil
Local cAls			:= GetNextAlias()
Local nSuperior  	:= 0
Local nEsquerda 	:= 0
Local nInferior 	:= 0
Local nDireita  	:= 0
Local cF3			:= ""
Local cVal		 	:= ""
Local aAreaSXB		:= {}
Local lRetF3		:= .F.

cQuery := a870dQry(cTabela,cCampo,@aSeek,@aIndex)
cRetF3  := FwFldGet("ORC_PRODF")

If !Empty(cQuery)
	If !isBlind()
		nInferior := GetScreenRes()[2] * 0.6
		nDireita  := GetScreenRes()[1] * 0.65

		DEFINE MSDIALOG oDlgEscTela TITLE STR0016 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL // "Valor"
				
			oBrowse := FWFormBrowse():New()
			oBrowse:SetOwner(oDlgEscTela)
			oBrowse:SetDataQuery(.T.)
			oBrowse:SetAlias(cAls)
			oBrowse:SetQueryIndex(aIndex)
			oBrowse:SetQuery(cQuery)
			oBrowse:SetSeek(,aSeek)
			oBrowse:SetDescription(STR0112) //"Tabela"
			oBrowse:SetMenuDef("")
			oBrowse:DisableDetails()

			At190SetFlt(aSeek, @oBrowse)

			oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->&(cCampo), lRet := .T. ,oDlgEscTela:End()})
			oBrowse:AddButton( OemTOAnsi(STR0044), {|| cRetF3  := (oBrowse:Alias())->&(cCampo), lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"

			oBrowse:AddButton( OemTOAnsi(STR0045),  {|| cRetF3  := "", oDlgEscTela:End() } ,, 2 )	//"Cancelar"
			oBrowse:DisableDetails()

			If cTabela == "TFJ"
				If cCampo == "TFJ_CONDPG"
					ADD COLUMN oColumn DATA { ||  TFJ_CONDPG  } TITLE STR0014 SIZE TamSX3("TFJ_CONDPG")[1] OF oBrowse //"Campo"
					ADD COLUMN oColumn DATA { ||  E4_DESCRI  } TITLE STR0046 SIZE TamSX3("E4_DESCRI")[1] OF oBrowse	//"Descrição"
				ElseIf cCampo == 'TFJ_CODIGO'
					ADD COLUMN oColumn DATA { ||  TFJ_CODIGO  } TITLE STR0014 SIZE TamSX3("TFJ_CODIGO")[1] OF oBrowse //"Campo"
					ADD COLUMN oColumn DATA { ||  A1_NOME  } TITLE STR0046 SIZE TamSX3("A1_NOME")[1] OF oBrowse	//"Descrição"
				ElseIf cCampo == 'TFJ_CONTRT'
					ADD COLUMN oColumn DATA {|| TFJ_CONTRT} TITLE STR0018 SIZE TamSX3("TFJ_CONTRT")[1] OF oBrowse //"Número do Contrato"
					ADD COLUMN oColumn DATA {|| CN9_REVISA}  TITLE STR0050 SIZE TamSX3("CN9_REVISA")[1] OF oBrowse //"Revisão"
					ADD COLUMN oColumn DATA {|| TFJ_CODENT} TITLE STR0051 SIZE TamSX3("TFJ_CODENT")[1] OF oBrowse //"Cliente"
					ADD COLUMN oColumn DATA {|| TFJ_LOJA}  TITLE STR0052 SIZE TamSX3("TFJ_LOJA")[1] OF oBrowse //"Loja"
					ADD COLUMN oColumn DATA {|| A1_NOME} TITLE STR0053 SIZE TamSX3("A1_NOME")[1] OF oBrowse //"Nome"
				EndIf 
			ElseIf cTabela == "TFF"
				If cCampo == 'TFF_CALEND'
					ADD COLUMN oColumn DATA { ||  TFF_CALEND  } TITLE STR0054 SIZE TamSX3("TFF_CALEND")[1] OF oBrowse //"Codigo"
					ADD COLUMN oColumn DATA { ||  AC0_DESC  } TITLE STR0046 SIZE TamSX3("AC0_DESC")[1] OF oBrowse	//"Descrição"
				ElseIf cCampo == 'TFF_CARGO'
					ADD COLUMN oColumn DATA { ||  TFF_CARGO  } TITLE STR0055 SIZE TamSX3("TFF_CARGO")[1] OF oBrowse //"Cargo"
					ADD COLUMN oColumn DATA { ||  Q3_DESCSUM  } TITLE STR0046 SIZE TamSX3("Q3_DESCSUM")[1] OF oBrowse	//"Descrição"
				ElseIf cCampo == 'TFF_CONTRT'
					ADD COLUMN oColumn DATA { ||  CN9_NUMERO  } TITLE STR0056 SIZE TamSX3("CN9_NUMERO")[1]  OF oBrowse //"Contrato"
					ADD COLUMN oColumn DATA { ||  CN9_REVISA  } TITLE STR0050 SIZE TamSX3("CN9_REVISA")[1] OF oBrowse	//"Revisão"
					ADD COLUMN oColumn DATA { ||  TFJ_CODENT  } TITLE STR0051 SIZE TamSX3("TFJ_CODENT")[1] OF oBrowse //"Cliente"
					ADD COLUMN oColumn DATA { ||  TFJ_LOJA  } TITLE STR0052 SIZE TamSX3("TFJ_LOJA")[1] OF oBrowse	//"Loja"
					ADD COLUMN oColumn DATA { ||  A1_NOME  } TITLE STR0053 SIZE TamSX3("A1_NOME")[1] OF oBrowse	//"Nome"
				ElseIf cCampo == 'TFF_ESCALA'
					ADD COLUMN oColumn DATA { ||  TDW_FILIAL  } TITLE STR0057 SIZE TamSX3("TDW_FILIAL")[1] OF oBrowse //"Filial"
					ADD COLUMN oColumn DATA { ||  TFF_ESCALA  } TITLE STR0054 SIZE TamSX3("TFF_ESCALA")[1] OF oBrowse	//"Codigo"
					ADD COLUMN oColumn DATA { ||  TDW_DESC  } TITLE STR0058 SIZE TamSX3("TDW_DESC")[1] OF oBrowse	//"Escala"
				ElseIf cCampo == 'TFF_FUNCAO'
					ADD COLUMN oColumn DATA { ||  TFF_FUNCAO  } TITLE STR0054 SIZE TamSX3("TFF_FUNCAO")[1] OF oBrowse //"Codigo"
					ADD COLUMN oColumn DATA { ||  RJ_DESC  } TITLE STR0059 SIZE TamSX3("RJ_DESC")[1] OF oBrowse	//"Função"
				ElseIf cCampo == 'TFF_PRODUT'
					ADD COLUMN oColumn DATA { ||  TFF_PRODUT  } TITLE STR0054 SIZE TamSX3("TFF_PRODUT")[1] OF oBrowse //"Codigo"
					ADD COLUMN oColumn DATA { ||  B1_DESC  } TITLE STR0046 SIZE TamSX3("B1_DESC")[1] OF oBrowse	//"Descrição"
				ElseIf cCampo == 'TFF_TURNO'
					ADD COLUMN oColumn DATA {|| TFF_TURNO} TITLE STR0060 SIZE TamSX3("TFF_TURNO")[1] OF oBrowse //"Turno"
					ADD COLUMN oColumn DATA {|| R6_DESC}  TITLE STR0046 SIZE TamSX3("R6_DESC")[1] OF oBrowse //"Descrição"
				ElseIf cCampo == 'TFF_TESPED'
					ADD COLUMN oColumn DATA {|| TFF_TESPED} TITLE STR0061 SIZE TamSX3("TFF_TESPED")[1] OF oBrowse //"Cod. Tipo"
					ADD COLUMN oColumn DATA {|| F4_TIPO}  TITLE STR0062 SIZE TamSX3("F4_TIPO")[1] OF oBrowse //"Tipo TES"
					ADD COLUMN oColumn DATA {|| F4_CF} TITLE STR0063 SIZE TamSX3("F4_CF")[1] OF oBrowse //"Cod. Fiscal"
					ADD COLUMN oColumn DATA {|| F4_DUPLIC}  TITLE STR0064 SIZE TamSX3("F4_DUPLIC")[1] OF oBrowse //"Gera. Duplic"
					ADD COLUMN oColumn DATA {|| F4_ESTOQUE} TITLE STR0065 SIZE TamSX3("F4_ESTOQUE")[1] OF oBrowse //"Atu. Estoque"
					ADD COLUMN oColumn DATA {|| F4_TEXTO}  TITLE STR0066 SIZE TamSX3("F4_TEXTO")[1] OF oBrowse //"TXT Padrão"
				EndIf
			ElseIf cTabela == 'TFL'
				If cCampo == 'TFL_LOCAL'
					ADD COLUMN oColumn DATA {|| ABS_FILIAL} TITLE STR0057 SIZE TamSX3("ABS_FILIAL")[1] OF oBrowse //"Filial"
					ADD COLUMN oColumn DATA {|| TFL_LOCAL}  TITLE STR0054 SIZE TamSX3("TFL_LOCAL")[1] OF oBrowse //"Codigo"
					ADD COLUMN oColumn DATA {|| ABS_LOCPAI} TITLE STR0067 SIZE TamSX3("ABS_LOCPAI")[1] OF oBrowse //"Loc. Pai de "
					ADD COLUMN oColumn DATA {|| ABS_DESCRI}  TITLE STR0068 SIZE TamSX3("ABS_DESCRI")[1] OF oBrowse //"Local"
					ADD COLUMN oColumn DATA {|| ABS_CCUSTO} TITLE STR0069 SIZE TamSX3("ABS_CCUSTO")[1] OF oBrowse //"Centro de Custo"
					ADD COLUMN oColumn DATA {|| ABS_REGIAO}  TITLE STR0070 SIZE TamSX3("ABS_REGIAO")[1] OF oBrowse //"Região"
				ElseIf cCampo == 'TFL_ESTADO'
					ADD COLUMN oColumn DATA {|| TFL_ESTADO} TITLE STR0071 SIZE TamSX3("TFL_ESTADO")[1] OF oBrowse //"UF"
					ADD COLUMN oColumn DATA {|| X5_DESCRI}  TITLE STR0072 SIZE TamSX3("X5_DESCRI")[1] OF oBrowse //"Estado"
				ElseIf cCampo == 'TFL_MUNIC'
					ADD COLUMN oColumn DATA {|| CC2_EST} TITLE STR0072 SIZE TamSX3("CC2_EST")[1] OF oBrowse //"Estado"
					ADD COLUMN oColumn DATA {|| CC2_MUN}  TITLE STR0073 SIZE TamSX3("CC2_MUN")[1] OF oBrowse //"Municipio"
					ADD COLUMN oColumn DATA {|| TFL_MUNIC} TITLE STR0074 SIZE TamSX3("TFL_MUNIC")[1] OF oBrowse //"Codigo IBGE"
				EndIf
			EndIf 

		oBrowse:Activate()

		ACTIVATE MSDIALOG oDlgEscTela CENTERED
	Endif	
Else 
	If GetSX3Cache( cCampo , "X3_PROPRI" ) == "U"
		cF3 := GetSX3Cache( cCampo , "X3_F3" )
		If !Empty(cF3)
			aAreaSXB := SXB->(GetArea())
			DbSelectArea("SXB")
			SXB->(dbSetOrder(1))

			If SXB->(dbSeek(cF3+"5"))
				If Trim(SXB->XB_CONTEM) != ""
					cVal := Trim(SXB->XB_CONTEM)
				EndIf 			
				SXB->(DbSkip())
			EndIf
			If !Empty(cVal)
				lRetF3 := Conpad1( NIL,NIL,NIL,cF3)
				If lRetF3
					cRetF3 := &(cVal)
				EndIf
			EndIf
			RestArea(aAreaSXB) 	
		Else 
			Help( " ", 1, STR0047, Nil, STR0075, 1 )	// "Campos" ## "Não há consulta criada para esse campo"
		EndIf
	Else
		Help( " ", 1, STR0047, Nil, STR0075, 1 )	// "Campos" ## "Não há consulta criada para esse campo"
	EndIf
EndIf	

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} a870dQry()

Cria a query para a consulta padrão

@author Luiz Gabriel
@since 24/06/2020
/*/
//------------------------------------------------------------------
Function a870dQry(cTabela,cCampo,aSeek,aIndex)
Local cQuery 	:= ""

Do Case 
	Case cTabela == "TFJ"
		If cCampo == "TFJ_CONDPG"
			cQuery += " SELECT DISTINCT TFJ_CONDPG,E4_DESCRI "
			cQuery += " FROM " + RetSqlName("TFJ") + " TFJ "
			cQuery += " LEFT JOIN " + RetSqlName("SE4") + " SE4 "
			cQuery +=        " ON SE4.E4_FILIAL = '" + xFilial("SE4") + "' AND "
			cQuery +=           " SE4.E4_CODIGO = TFJ.TFJ_CONDPG AND "
			cQuery +=           " SE4.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
			cQuery += " TFJ.D_E_L_E_T_ = ' ' "

			Aadd( aSeek, { STR0110, {{"","C",TamSX3("TFJ_CONDPG")[1],0,STR0110,,"TFJ_CONDPG"}} } ) //"Campo"
			Aadd( aSeek, { STR0046, {{"","C",TamSX3("E4_DESCRI")[1],0,STR0046,,"E4_DESCRI"}} } ) // "Descrição" ## "Descrição"

			Aadd( aIndex, "TFJ_CONDPG" )
			Aadd( aIndex, "E4_DESCRI" )

		ElseIf cCampo == "TFJ_CODIGO"
			cQuery += " SELECT TFJ_CODIGO,A1_NOME "
			cQuery += " FROM " + RetSqlName("TFJ") + " TFJ "
			cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 "
			cQuery +=        " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
			cQuery +=           " AND TFJ_CODENT = A1_COD "
			cQuery +=			" AND TFJ_LOJA = A1_LOJA "
			cQuery +=           " AND SA1.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
			cQuery += " TFJ.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFJ.TFJ_STATUS = '1' "

			Aadd( aSeek, { STR0110, {{"","C",TamSX3("TFJ_CODIGO")[1],0,STR0110,,"TFJ_CODIGO"}} } ) //"Campo"
			Aadd( aSeek, { STR0046, {{"","C",TamSX3("A1_NOME")[1],0,STR0046,,"A1_NOME"}} } ) //"Descrição" ## "Descrição"

			Aadd( aIndex, "TFJ_CODIGO" )
			Aadd( aIndex, "A1_NOME" )
		ElseIf cCampo == 'TFJ_CONTRT'
			Aadd( aSeek, { STR0018, {{"","C",TamSX3("TFJ_CONTRT")[1],0,STR0018,,"TFJ_CONTRT"}} } )	//"Número do Contrato" # "Número do Contrato"
			Aadd( aSeek, { STR0050, {{"","C",TamSX3("CN9_REVISA")[1],0,STR0050,,"CN9_REVISA"}} } ) //"Revisão"
			Aadd( aSeek, { STR0051, {{"","C",TamSX3("TFJ_CODENT")[1],0,STR0051,,"TFJ_CODENT"}} } ) //"Cliente"
			Aadd( aSeek, { STR0052, {{"","C",TamSX3("TFJ_LOJA")[1],0,STR0052,,"TFJ_LOJA"}} } ) //"Loja"
			Aadd( aSeek, { STR0053, {{"","C",TamSX3("A1_NOME")[1],0,STR0053,,"A1_NOME"}} } ) //"Nome"
			
			Aadd( aIndex, "TFJ_CONTRT" )
			Aadd( aIndex, "CN9_REVISA" )
			Aadd( aIndex, "TFJ_CODENT" )
			Aadd( aIndex, "TFJ_LOJA" )
			Aadd( aIndex, "A1_NOME" )
			Aadd( aIndex, "CN9_FILIAL")  // adicionado para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último

			cQuery := " SELECT DISTINCT CN9_FILIAL, TFJ.TFJ_CONTRT, CN9.CN9_REVISA, TFJ.TFJ_CODENT, TFJ.TFJ_LOJA, SA1.A1_NOME "
			cQuery += " FROM " + RetSqlName("CN9") + " CN9 "
			cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
			cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
			cQuery += " AND TFJ.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFJ.TFJ_CONTRT = CN9.CN9_NUMERO "
			cQuery += " AND TFJ.TFJ_CONREV = CN9.CN9_REVISA "
			cQuery += " AND TFJ.TFJ_STATUS = '1' "
			cQuery += " AND TFJ.TFJ_FILIAL || TFJ.TFJ_CONTRT NOT IN ( SELECT TFJ2.TFJ_FILIAL || TFJ2.TFJ_CONTRT FROM " + RetSqlName("TFJ") + " TFJ2 WHERE TFJ2.TFJ_STATUS = '2' AND TFJ2.D_E_L_E_T_ = ' ' AND TFJ2.TFJ_FILIAL = '" + xFilial("TFJ") + "' )"
			cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
			cQuery += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
			cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO "
			cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "
			cQuery += " ON TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
			cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFF.TFF_CODPAI = TFL.TFL_CODIGO "
			cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
			cQuery += " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
			cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
			cQuery += " AND SA1.A1_COD = TFJ.TFJ_CODENT "
			cQuery += " AND SA1.A1_LOJA = TFJ.TFJ_LOJA "
			cQuery += " WHERE CN9.CN9_FILIAL = '" +  xFilial('CN9') + "' AND "
			cQuery += " CN9.D_E_L_E_T_ = ' ' "
		EndIf 
	Case cTabela == "TFF"
		If cCampo == 'TFF_CALEND'

			cQuery := " SELECT DISTINCT TFF.TFF_CALEND, AC0.AC0_DESC "
			cQuery += " FROM " + RetSqlName("AC0") + " AC0 "
			cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "
			cQuery += " ON TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND "
			cQuery += " TFF.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFF.TFF_CALEND = AC0.AC0_CODIGO "
			cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
			cQuery += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND "
			cQuery += " TFL.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
			cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
			cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
			cQuery += " TFJ.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
			cQuery += " AND TFJ.TFJ_STATUS = '1' "
			cQuery += " AND TFJ.TFJ_CONTRT <> ' ' "
			cQuery += " WHERE AC0.AC0_FILIAL = '" + xFilial("AC0") + "' AND "
			cQuery += " AC0.D_E_L_E_T_ = ' ' "

			Aadd( aSeek, { STR0054, {{"","C",TamSX3("TFF_CALEND")[1],0,STR0054,,"TFF_CALEND"}} } ) // "Codigo" ## "Codigo"
			Aadd( aSeek, { STR0046, {{"","C",TamSX3("AC0_DESC")[1],0,STR0046,,"AC0_DESC"}} } ) // "Descrição" ## "Descrição"

			Aadd( aIndex, "TFF_CALEND" )
			Aadd( aIndex, "AC0_DESC" )
		ElseIf cCampo == 'TFF_CARGO'

			cQuery := " SELECT DISTINCT TFF.TFF_CARGO, SQ3.Q3_DESCSUM "
			cQuery += " FROM " + RetSqlName("SQ3") + " SQ3 "
			cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "
			cQuery += " ON TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND "
			cQuery += " TFF.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFF.TFF_CARGO = SQ3.Q3_CARGO "
			cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
			cQuery += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND "
			cQuery += " TFL.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
			cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
			cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
			cQuery += " TFJ.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
			cQuery += " AND TFJ.TFJ_STATUS = '1' "
			cQuery += " AND TFJ.TFJ_CONTRT <> ' ' "
			cQuery += " WHERE SQ3.Q3_FILIAL = '" + xFilial("AC0") + "' AND "
			cQuery += " AC0.D_E_L_E_T_ = ' ' "

			Aadd( aSeek, { STR0054, {{"","C",TamSX3("TFF_CARGO")[1],0,STR0054,,"TFF_CARGO"}} } ) // "Codigo" ## "Codigo"
			Aadd( aSeek, { STR0046, {{"","C",TamSX3("Q3_DESCSUM")[1],0,STR0046,,"Q3_DESCSUM"}} } ) // "Descrição" ## "Descrição"

			Aadd( aIndex, "TFF_CARGO" )
			Aadd( aIndex, "Q3_DESCSUM" )
		ElseIf cCampo == 'TFF_ESCALA'

			Aadd( aSeek, { STR0057, {{"","C",TamSX3("TDW_FILIAL")[1],0,STR0057,,"TDW_FILIAL"}} } ) // "Filial" ## "Filial"
			Aadd( aSeek, { STR0054, {{"","C",TamSX3("TFF_ESCALA")[1],0,STR0054,,"TFF_ESCALA"}} } ) // "Codigo" ## "Codigo"
			Aadd( aSeek, { STR0058, {{"","C",TamSX3("TDW_DESC")[1],0,STR0058,,"TDW_DESC"}} } ) // "Escala" ## "Escala"
			Aadd( aSeek, { STR0054, {{"","C",TamSX3("TDW_COD")[1],0,STR0054,,"TDW_COD"}} } ) // "Codigo" ## "Codigo"

			Aadd( aIndex, "TDW_FILIAL" )
			Aadd( aIndex, "TFF_ESCALA" )
			Aadd( aIndex, "TDW_COD" )
			Aadd( aIndex, "TDW_DESC" )

			cQuery := " SELECT DISTINCT TDW.TDW_COD, TDW.TDW_DESC, TFF.TFF_ESCALA, TDW.TDW_FILIAL  "
			cQuery += " FROM " + RetSqlName("TDW") + " TDW "
			cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "
			cQuery += " ON TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND "
			cQuery += " TFF.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFF.TFF_ESCALA = TDW.TDW_COD "
			cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
			cQuery += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND "
			cQuery += " TFL.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
			cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
			cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
			cQuery += " TFJ.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
			cQuery += " AND TFJ.TFJ_STATUS = '1' "
			cQuery += " AND TFJ.TFJ_CONTRT <> ' ' "
			cQuery += " WHERE TDW.TDW_FILIAL = '" + xFilial("TDW") + "' AND "
			cQuery += " TDW.TDW_STATUS = '1' AND "
			cQuery += " TDW.D_E_L_E_T_ = ' ' "
		ElseIf cCampo == 'TFF_FUNCAO'
			Aadd( aSeek, { STR0054, {{"","C",TamSX3("TFF_FUNCAO")[1],0,STR0054,,"TFF_FUNCAO"}} } ) // "Codigo" ## "Codigo"
			Aadd( aSeek, { STR0059, {{"","C",TamSX3("RJ_DESC")[1],0,STR0059,,"RJ_DESC"}} } ) // "Função" ## "Função"

			Aadd( aIndex, "TFF_FUNCAO" )
			Aadd( aIndex, "RJ_DESC" )
			
			cQuery := " SELECT DISTINCT TFF.TFF_FUNCAO, SRJ.RJ_DESC  "
			cQuery += " FROM " + RetSqlName("SRJ") + " SRJ "
			cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "
			cQuery += " ON TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND "
			cQuery += " TFF.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFF.TFF_FUNCAO = SRJ.RJ_FUNCAO "
			cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
			cQuery += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND "
			cQuery += " TFL.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
			cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
			cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
			cQuery += " TFJ.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
			cQuery += " AND TFJ.TFJ_STATUS = '1' "
			cQuery += " AND TFJ.TFJ_CONTRT <> ' ' "
			cQuery += " WHERE SRJ.RJ_FILIAL = '" + xFilial("SRJ") + "' AND "
			cQuery += " SRJ.D_E_L_E_T_ = ' ' "
		ElseIf cCampo == 'TFF_PRODUT'
			Aadd( aSeek, { STR0076, {{"","C",TamSX3("TFF_PRODUT")[1],0,STR0076,,"TFF_PRODUT"}} } )	//"Código do Produto" # "Código do Produto"
			Aadd( aSeek, { STR0046, {{"","C",TamSX3("B1_DESC")[1],0,STR0046,,"B1_DESC"}} } )	//"Descrição" # "Descrição"

			Aadd( aIndex, "TFF_PRODUT" )
			Aadd( aIndex, "B1_DESC" )

			cQuery := " SELECT DISTINCT TFF.TFF_PRODUT, SB1.B1_DESC, SB1.B1_FILIAL "
			cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
			cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "
			cQuery += " ON TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND "
			cQuery += " TFF.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFF.TFF_PRODUT = SB1.B1_COD "
			cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
			cQuery += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND "
			cQuery += " TFL.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
			cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
			cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
			cQuery += " TFJ.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
			cQuery += " AND TFJ.TFJ_STATUS = '1' "
			cQuery += " AND TFJ.TFJ_CONTRT <> ' ' "
			cQuery += " WHERE SB1.B1_FILIAL = '" +  xFilial('SB1') + "' AND "
			cQuery += " SB1.D_E_L_E_T_ = ' ' "
		ElseIf cCampo == 'TFF_TURNO'
			Aadd( aSeek, { "Turnos", {{"","C",TamSX3("TFF_TURNO")[1],0,"Turnos",,"TFF_TURNO"}} } ) //"Loja"
			
			Aadd( aIndex, "TFF_TURNO" )
			Aadd( aIndex, "R6_FILIAL" )

			cQuery := "SELECT DISTINCT SR6.R6_FILIAL, TFF_TURNO, SR6.R6_DESC"
			cQuery += " FROM " + RetSqlName("SR6") + " SR6 "
			cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "
			cQuery += " ON TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND "
			cQuery += " TFF.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFF.TFF_TURNO = SR6.R6_TURNO "
			cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
			cQuery += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND "
			cQuery += " TFL.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
			cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
			cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
			cQuery += " TFJ.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
			cQuery += " AND TFJ.TFJ_STATUS = '1' "
			cQuery += " AND TFJ.TFJ_CONTRT <> ' ' "
			cQuery += " WHERE R6_FILIAL = '"+xFilial("SR6")+"' AND SR6.D_E_L_E_T_ = ' ' "
		ElseIf cCampo == 'TFF_TESPED'
			Aadd( aSeek, { STR0061, {{"","C",TamSX3("TFF_TESPED")[1],0,STR0061,,"TFF_TESPED"}} } ) //"Cod. Tipo"
			Aadd( aSeek, { STR0062, {{"","C",TamSX3("F4_TIPO")[1],0,STR0062,,"F4_TIPO"}} } ) //"Tipo TES"
			Aadd( aSeek, { STR0063, {{"","C",TamSX3("F4_CF")[1],0,STR0063,,"F4_CF"}} } ) //"Cod. Fiscal"
			Aadd( aSeek, { STR0064, {{"","C",TamSX3("F4_DUPLIC")[1],0,STR0064,,"F4_DUPLIC"}} } ) //"Gera. Duplic"
			Aadd( aSeek, { STR0065, {{"","C",TamSX3("F4_ESTOQUE")[1],0,STR0065,,"F4_ESTOQUE"}} } ) //"Atu. Estoque"
			Aadd( aSeek, { STR0066, {{"","C",TamSX3("F4_TEXTO")[1],0,STR0066,,"F4_TEXTO"}} } ) //"TXT Padrão"
			
			Aadd( aIndex, "TFF_TESPED" )
			Aadd( aIndex, "F4_TIPO" )
			Aadd( aIndex, "F4_CF" )
			Aadd( aIndex, "F4_DUPLIC" )
			Aadd( aIndex, "F4_ESTOQUE" )
			Aadd( aIndex, "F4_TEXTO" )

			cQuery := "SELECT DISTINCT SF4.F4_CODIGO, SF4.F4_TIPO, SF4.F4_CF, SF4.F4_DUPLIC, SF4.F4_ESTOQUE, SF4.F4_TEXTO,TFF.TFF_TESPED "
			cQuery += " FROM " + RetSqlName("SF4") + " SF4 "
			cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "
			cQuery += " ON TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND "
			cQuery += " TFF.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFF.TFF_TESPED = SF4.F4_CODIGO "
			cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
			cQuery += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND "
			cQuery += " TFL.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
			cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
			cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
			cQuery += " TFJ.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
			cQuery += " AND TFJ.TFJ_STATUS = '1' "
			cQuery += " AND TFJ.TFJ_CONTRT <> ' ' "
			cQuery += " WHERE SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4.D_E_L_E_T_ = ' ' "
		EndIf
	Case cTabela == "TFL"
		If cCampo == 'TFL_LOCAL'
			Aadd( aSeek, { STR0057, {{"","C",TamSX3("ABS_FILIAL")[1],0,STR0057,,"ABS_FILIAL"}} } ) // "Filial" ## "Filial"
			Aadd( aSeek, { STR0054, {{"","C",TamSX3("TFL_LOCAL")[1],0,STR0054,,"TFL_LOCAL"}} } ) // "Codigo" ## "Codigo"
			Aadd( aSeek, { STR0067, {{"","C",TamSX3("ABS_LOCPAI")[1],0,STR0067,,"ABS_LOCPAI"}} } ) // "Loc. Pai de " ## "Loc. Pai de "
			Aadd( aSeek, { STR0068, {{"","C",TamSX3("ABS_DESCRI")[1],0,STR0068,,"ABS_DESCRI"}} } ) // "Local" ## "Local"
			Aadd( aSeek, { STR0069, {{"","C",TamSX3("ABS_CCUSTO")[1],0,STR0069,,"ABS_CCUSTO"}} } ) // "Centro de Custo" ## "Centro de Custo"
			Aadd( aSeek, { STR0070, {{"","C",TamSX3("ABS_REGIAO")[1],0,STR0070,,"ABS_REGIAO"}} } ) // "Região" ## "Região"

			Aadd( aIndex, "ABS_FILIAL" )
			Aadd( aIndex, "TFL_LOCAL" )
			Aadd( aIndex, "ABS_LOCPAI" )
			Aadd( aIndex, "ABS_DESCRI" )
			Aadd( aIndex, "ABS_CCUSTO" )
			Aadd( aIndex, "ABS_REGIAO" )

			cQuery := " SELECT DISTINCT ABS.ABS_FILIAL, ABS.ABS_LOCPAI, ABS.ABS_DESCRI, ABS.ABS_CCUSTO, ABS.ABS_REGIAO, TFL.TFL_LOCAL "
			cQuery += " FROM " + RetSqlName("ABS") + " ABS "
			cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "
			cQuery += " ON TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND "
			cQuery += " TFF.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFF.TFF_LOCAL = ABS.ABS_LOCAL "
			cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
			cQuery += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND "
			cQuery += " TFL.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
			cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
			cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
			cQuery += " TFJ.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
			cQuery += " AND TFJ.TFJ_STATUS = '1' "
			cQuery += " AND TFJ.TFJ_CONTRT <> ' ' "
			cQuery += " WHERE ABS.ABS_FILIAL = '" + xFilial("ABS") + "' AND "
			cQuery += " ABS.D_E_L_E_T_ = ' ' "
		ElseIf cCampo = 'TFL_ESTADO'
			Aadd( aSeek, { STR0071, {{"","C",TamSX3("TFL_ESTADO")[1],0,STR0071,,"TFL_ESTADO"}} } ) // "UF" ## "UF"
			Aadd( aSeek, { STR0072, {{"","C",TamSX3("X5_DESCRI")[1],0,STR0072,,"X5_DESCRI"}} } ) // "Estado" ## "Estado"

			Aadd( aIndex, "TFL_ESTADO" )
			Aadd( aIndex, "X5_DESCRI" )

			cQuery := " SELECT DISTINCT ABS.ABS_ESTADO TFL_ESTADO, SX5.X5_DESCRI "
			cQuery += " FROM " + RetSqlName("TFL") + " TFL "
			cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "
			cQuery += " ON TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND "
			cQuery += " TFF.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFF.TFF_LOCAL = TFL.TFL_LOCAL "
			cQuery += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
			cQuery += " INNER JOIN " + RetSqlName("ABS") + " ABS "
			cQuery += " ON ABS.ABS_FILIAL = '" + xFilial("ABS") + "' AND "
			cQuery += " ABS.D_E_L_E_T_ = ' ' "
			cQuery += " AND ABS.ABS_LOCAL = TFL.TFL_LOCAL "
			cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
			cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
			cQuery += " TFJ.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
			cQuery += " AND TFJ.TFJ_STATUS = '1' "
			cQuery += " AND TFJ.TFJ_CONTRT <> ' ' "
			cQuery += " INNER JOIN " + RetSqlName("SX5") + " SX5 "
			cQuery += " ON SX5.X5_FILIAL = '" + xFilial("SX5") + "' AND "
			cQuery += " SX5.D_E_L_E_T_ = ' ' "
			cQuery += " AND SX5.X5_TABELA = '12' "
			cQuery += " AND SX5.X5_CHAVE = ABS.ABS_ESTADO"
			cQuery += " WHERE TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND "
			cQuery += " TFL.D_E_L_E_T_ = ' ' "
		ElseIf cCampo = 'TFL_MUNIC'
			Aadd( aSeek, { STR0072, {{"","C",TamSX3("CC2_EST")[1],0,STR0072,,"CC2_EST"}} } ) // "Estado" ## "Estado"
			Aadd( aSeek, { STR0073, {{"","C",TamSX3("CC2_MUN")[1],0,STR0073,,"CC2_MUN"}} } ) // "Municipio" ## "Municipio"
			Aadd( aSeek, { STR0074, {{"","C",TamSX3("TFL_MUNIC")[1],0,STR0074,,"TFL_MUNIC"}} } ) // "Codigo IBGE" ## "Codigo IBGE"

			Aadd( aIndex, "CC2_EST" )
			Aadd( aIndex, "CC2_MUN" )
			Aadd( aIndex, "TFL_MUNIC" )

			cQuery := " SELECT DISTINCT ABS.ABS_CODMUN TFL_MUNIC, CC2.CC2_EST, CC2.CC2_MUN "
			cQuery += " FROM " + RetSqlName("TFL") + " TFL "
			cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "
			cQuery += " ON TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND "
			cQuery += " TFF.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFF.TFF_LOCAL = TFL.TFL_LOCAL "
			cQuery += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
			cQuery += " INNER JOIN " + RetSqlName("ABS") + " ABS "
			cQuery += " ON ABS.ABS_FILIAL = '" + xFilial("ABS") + "' AND "
			cQuery += " ABS.D_E_L_E_T_ = ' ' "
			cQuery += " AND ABS.ABS_LOCAL = TFL.TFL_LOCAL "
			cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
			cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
			cQuery += " TFJ.D_E_L_E_T_ = ' ' "
			cQuery += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
			cQuery += " AND TFJ.TFJ_STATUS = '1' "
			cQuery += " AND TFJ.TFJ_CONTRT <> ' ' "
			cQuery += " INNER JOIN " + RetSqlName("CC2") + " CC2 "
			cQuery += " ON CC2.CC2_FILIAL = '" + xFilial("CC2") + "' AND "
			cQuery += " CC2.D_E_L_E_T_ = ' ' "
			cQuery += " AND CC2.CC2_CODMUN = ABS.ABS_CODMUN "
			cQuery += " WHERE TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND "
			cQuery += " TFL.D_E_L_E_T_ = ' ' "
		EndIf
End Case 

If !Empty(cQuery)
	cQuery := ChangeQuery(cQuery)
EndIf 

Return cQuery 

//-------------------------------------------------------------------
/*/{Protheus.doc} a870dBox()

Função para construir os valores para a consulta padrão a870dBox

@author Luiz Gabriel
@since 24/06/2020
/*/
//------------------------------------------------------------------
Static Function a870dBox(cTabela,cCampo,cValor)
Local aValor	:= {}
Local aCampos	:= {}
Local aQuebra	:= {}
Local nX 		:= 0

aValor := StrTokArr(cValor,';')
For nX := 1 To Len(aValor)
	aQuebra	:= StrTokArr(aValor[nX],'=')
	Aadd(aCampos,{aQuebra[1],Alltrim(aQuebra[2])})
Next nX
	
Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} A870dBrwArr()

Função para criar F3 para os campos do tipo comboBOX

@author Luiz Gabriel
@since 24/06/2020
/*/
//------------------------------------------------------------------
Static Function A870dBrwArr(cTabela,cCampo,cValor)
Local oDlgEscTela 	:= Nil
Local nSuperior  	:= 0
Local nEsquerda 	:= 0
Local nInferior 	:= 0
Local nDireita  	:= 0
Local oBrw			:= NIL
Local oColumns		:= Nil
Local aCampos		:= {}

cRetF3  := FwFldGet("ORC_PRODF")

If !Empty(cTabela) .And. !Empty(cCampo)

	aCampos := a870dBox(cTabela,cCampo,cValor)

	If Len(aCampos) > 0 

		If !isBlind()
			nInferior := GetScreenRes()[2] * 0.6
			nDireita  := GetScreenRes()[1] * 0.65

			DEFINE MSDIALOG oDlgEscTela TITLE STR0016 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL // "Valor"
				DEFINE FWFORMBROWSE oBrw DATA ARRAY ARRAY aCampos LINE BEGIN 1 OF oDlgEscTela
					
					ADD COLUMN oColumns DATA &("{ || aCampos[oBrw:At()][1] }") TITLE STR0016 		SIZE 1		OF oBrw // "Valor"
					ADD COLUMN oColumns DATA &("{ || aCampos[oBrw:At()][2] }") TITLE STR0046 	SIZE 20 	OF oBrw

					oBrw:SetDoubleClick({ || cRetF3 :=aCampos[oBrw:nAt,01], lRet := .T. ,oDlgEscTela:End()})
					oBrw:AddButton( OemTOAnsi(STR0044), {|| cRetF3 := aCampos[oBrw:nAt,01], lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"

					oBrw:AddButton( OemTOAnsi(STR0045),  {|| cRetF3  := "", oDlgEscTela:End() } ,, 2 )	//"Cancelar"
					oBrw:DisableDetails()

				ACTIVATE FWFORMBROWSE oBrw

			ACTIVATE MSDIALOG oDlgEscTela CENTERED
		EndIf	
	Else 
		Help( " ", 1, STR0047, Nil, STR0075, 1 )	//"Campos" ## "Não há consulta criada para esse campo"
	EndIf	
Else 
	Help( " ", 1, STR0047, Nil, STR0049, 1 )	//"Campos" ## "Informe uma entidade ou campo para seleção"
EndIf 

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870dMrk

@description Marca/Desmarca todos os campos CTR_MARK

@author	Luiz Gabriel
@since	25/06/2020
/*/
//------------------------------------------------------------------------------
Function At870dMrk()
Local oModel 	:= FwModelActive()
Local oView  	:= FwViewActive()
Local oMdlCTR	:= oModel:GetModel('CTRMASTER')
Local nLine		:= oMdlCTR:GetLine()
Local nX		:= 0

If !(oMdlCTR:isEmpty())
	For nX := 1 To oMdlCTR:Length()
		oMdlCTR:GoLine(nX)
		oMdlCTR:SetValue("CTR_MARK", !(oMdlCTR:GetValue("CTR_MARK")))
	Next nX

	oMdlCTR:GoLine(nLine)
	If !IsBlind()
		oView:Refresh()
	EndIf
EndIf

Return (.T.)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870Carga

@description Realiza a carga das TFF´s no grid de contrato

@author	Luiz Gabriel
@since	22/06/2020
/*/
//------------------------------------------------------------------------------
Function At870Carga()
Local oView		:= FwViewActive()
Local oModel 	:= FwModelActive()
Local oMdlDAT 	:= oModel:GetModel('DATMASTER')
Local oMdlORC 	:= oModel:GetModel('ORCMASTER')
Local oMdlCTR 	:= oModel:GetModel('CTRMASTER')
Local cSql		:= ""
Local nLinha	:= 0
Local nPerc		:= 0
Local nPrcVen	:= 0

//Verifica se há algum filtro preenchido
If !oMdlORC:IsEmpty() .AND. (!Empty(oMdlOrc:GetValue("ORC_PRODF")) .AND. !oMdlOrc:IsDeleted())

	cSql := At870Filtr(oMdlORC)

	oMdlCTR:SetNoInsertLine(.F.)
	oMdlCTR:SetNoDeleteLine(.F.)

	oMdlCTR:ClearData()
	oMdlCTR:InitLine()

	cSql := ChangeQuery(cSql)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
	While !(cAliasQry)->(EOF())
		If !oMdlCTR:IsEmpty()
			nLinha := oMdlCTR:AddLine()
		EndIf
		oMdlCTR:GoLine(nLinha)
		oMdlCTR:LoadValue("CTR_MARK", .T. )
		If !Empty(oMdlDAT:GetValue("DAT_PERCEN"))
			oMdlCTR:LoadValue("CTR_PERCEN", oMdlDAT:GetValue("DAT_PERCEN"))
			nPerc 	:= oMdlCTR:GetValue("CTR_PERCEN")
			nPrcVen	:= (cAliasQry)->(TFF_PRCVEN) + ( (cAliasQry)->(TFF_PRCVEN) / 100) * nPerc
			oMdlCTR:LoadValue('CTR_PRCVEN',(cAliasQry)->(TFF_PRCVEN) + ( (cAliasQry)->(TFF_PRCVEN) / 100) * nPerc )
		Else 
			nPrcVen	:= (cAliasQry)->(TFF_PRCVEN)
			oMdlCTR:LoadValue("CTR_PRCVEN", (cAliasQry)->(TFF_PRCVEN))
		EndIf	

		oMdlCTR:LoadValue("CTR_CONTRT", (cAliasQry)->(TFF_CONTRT))
		oMdlCTR:LoadValue("CTR_CONREV", (cAliasQry)->(TFF_CONREV))
		oMdlCTR:SetValue("CTR_LOCAL", (cAliasQry)->(TFF_LOCAL))
		oMdlCTR:LoadValue("CTR_TFFCOD", (cAliasQry)->(TFF_COD))
		oMdlCTR:SetValue("CTR_PRODUT", (cAliasQry)->(TFF_PRODUT))
		oMdlCTR:LoadValue("CTR_QTDVEN", (cAliasQry)->(TFF_QTDVEN))
		oMdlCTR:LoadValue("CTR_SUBTOT", ((cAliasQry)->(TFF_QTDVEN)*nPrcVen))
		oMdlCTR:LoadValue("CTR_PERINI", SToD((cAliasQry)->(TFF_PERINI)))
		oMdlCTR:LoadValue("CTR_PERFIM", SToD((cAliasQry)->(TFF_PERFIM)))
		oMdlCTR:SetValue("CTR_FUNCAO", (cAliasQry)->(TFF_FUNCAO))
		oMdlCTR:SetValue("CTR_TURNO", (cAliasQry)->(TFF_TURNO))
		oMdlCTR:LoadValue("CTR_SEQTRN", (cAliasQry)->(TFF_SEQTRN))
		oMdlCTR:SetValue("CTR_CARGO", (cAliasQry)->(TFF_CARGO))
		oMdlCTR:SetValue("CTR_ESCALA", (cAliasQry)->(TFF_ESCALA))
		oMdlCTR:SetValue("CTR_CALEND", (cAliasQry)->(TFF_CALEND))
		oMdlCTR:LoadValue("CTR_INSALU", X3Combo("TFF_INSALU", (cAliasQry)->(TFF_INSALU)))
		oMdlCTR:LoadValue("CTR_GRAUIN", X3Combo("TFF_GRAUIN", (cAliasQry)->(TFF_GRAUIN)))
		oMdlCTR:LoadValue("CTR_PERICU", X3Combo("TFF_PERICU", (cAliasQry)->(TFF_PERICU)))
		oMdlCTR:LoadValue("CTR_TESPED", (cAliasQry)->(TFF_TESPED))	
		oMdlCTR:LoadValue("CTR_TOTALC", ((cAliasQry)->(TFF_QTDVEN)*nPrcVen))	
		oMdlCTR:LoadValue("CTR_RECNO", (cAliasQry)->(R_E_C_N_O_ ))
		oMdlCTR:LoadValue("CTR_PLAN", (cAliasQry)->(TFL_PLAN))	
		
		(cAliasQry)->(dbSkip())
	End
		
	(cAliasQry)->(dbCloseArea())
	oMdlCTR:GoLine(1)

	oMdlCTR:SetNoInsertLine(.T.)
	oMdlCTR:SetNoDeleteLine(.T.)

	If !isBlind()
		oView:Refresh()
	EndIf	
Else 
	Help( " ", 1, STR0005, Nil, STR0077, 1 )	//"Contratos" ## "Informe ao menos um filtro para carregar os itens do contrato"
EndIf 

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870Filtr

@description Realiza a criação da query para carregamento do grid com base nos
filtros informados no GRID ORCMASTER

@return cSql, Caracter, Retorna a query para execução

@author	Augusto Albuquerque
@since	22/06/2020
/*/
//------------------------------------------------------------------------------
Static Function At870Filtr(oMdlORC)
Local aWhere	:= {}
Local cQuery	:= ""
Local cWhere	:= ""
Local cValorWhere	:= ""
Local cCampo	:= ""
Local cValor	:= ""
Local lReplica	:= .F.
Local nX

For nX := 1 To oMdlOrc:Length()
	oMdlOrc:GoLine(nX)
	If !oMdlOrc:IsDeleted()
		AADD( aWhere, {oMdlOrc:GetValue("ORC_CAMPOS"), Left(oMdlOrc:GetValue("ORC_PRODF"), TamSX3(oMdlOrc:GetValue("ORC_CAMPOS"))[1])})
	EndIf 
Next nX
aWhere := ASort(aWhere,,,{|x,y| x[1] < y[1]})

For nX := 1 To Len(aWhere)
	If nX <> 1
		If aWhere[nX][1] == cCampo
			If !lReplica 
				cValorWhere += "'" + cValor + "', "
			EndIf
			cValorWhere += "'" + aWhere[nX][2] + "',"
			lReplica := .T.
		Else
			If lReplica
				cValorWhere := SubStr(cValorWhere, 1, Len(cValorWhere)-1)
				cWhere += " AND " + cCampo + " IN ( " + cValorWhere + " ) "
			Else
				cWhere += " AND " + cCampo + " = '" + Left(cValor, TamSX3(cCampo)[1]) + "' "
			EndIf

			lReplica := .F.
			cCampo := aWhere[nX][1]
			cValor := aWhere[nX][2]
		EndIf
	Else
		cCampo := aWhere[nX][1] 
		cValor := aWhere[nX][2]
	EndIf	
Next nX 

If lReplica
	cValorWhere := SubStr(cValorWhere, 1, Len(cValorWhere)-1)
	cWhere += " AND " + cCampo + " IN ( " + cValorWhere + " ) "
Else
	If "TFL_ESTADO" == Alltrim(cCampo) .OR. "TFL_MUNIC" == Alltrim(cCampo)
		If "TFL_ESTADO" == Alltrim(cCampo)
			cCampo := StrTran( cCampo, "TFL", "ABS" )
		Else
			cCampo := "ABS_CODMUN"
		EndIf	
		cWhere += " AND " + cCampo + " = '" + Left(cValor, TamSX3(cCampo)[1]) + "' "	
	Else
		cWhere += " AND " + cCampo + " = '" + Left(cValor, TamSX3(cCampo)[1]) + "' "
	EndIf	
EndIf

cQuery += " SELECT TFF_CONTRT,TFF_CONREV,TFF_LOCAL,TFF_COD,TFF_PRODUT, "
cQuery += " TFF_QTDVEN,TFF_PRCVEN,TFF_FUNCAO,TFF_TURNO,TFF_SEQTRN,TFF_CARGO, "
cQuery += " TFF_ESCALA,TFF_CALEND,TFF_INSALU,TFF_GRAUIN,TFF_PERICU,TFF_TESPED,TFF.R_E_C_N_O_,  "
cQuery += " TFF.TFF_PERINI, TFF.TFF_PERFIM, TFL.TFL_PLAN "
cQuery += " FROM " + RetSqlName("TFF") + " TFF "
cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
cQuery += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' AND "
cQuery += " TFL.D_E_L_E_T_ = ' ' "
cQuery += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
cQuery += " LEFT JOIN " + RetSqlName("ABS") + " ABS "
cQuery += " ON ABS.ABS_FILIAL = '" + xFilial("ABS") + "' AND "
cQuery += " ABS.D_E_L_E_T_ = ' ' "
cQuery += " AND ABS.ABS_LOCAL = TFL.TFL_LOCAL "
cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
cQuery += " TFJ.D_E_L_E_T_ = ' ' "
cQuery += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
cQuery += " AND TFJ.TFJ_STATUS = '1' "
cQuery += " AND TFJ.TFJ_CONTRT <> ' ' "
cQuery += " AND TFJ.TFJ_FILIAL || TFJ.TFJ_CONTRT NOT IN ( SELECT TFJ2.TFJ_FILIAL || TFJ2.TFJ_CONTRT FROM " + RetSqlName("TFJ") + " TFJ2 WHERE TFJ2.TFJ_STATUS = '2' AND TFJ2.D_E_L_E_T_ = ' ' AND TFJ2.TFJ_FILIAL = '" + xFilial("TFJ") + "' )"
cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9 "
cQuery += " ON TFJ.TFJ_CONTRT = CN9.CN9_NUMERO "
cQuery += " AND TFJ.TFJ_CONREV = CN9.CN9_REVISA "
cQuery += " AND CN9_REVATU = ' ' "
cQuery += " AND CN9.CN9_FILIAL = '" + xFilial("CN9") + "' "
cQuery += " AND CN9.D_E_L_E_T_ = ' ' "
cQuery += " WHERE TFF.TFF_FILIAL = '" + xFilial("TFF") + "' AND "
cQuery += " TFF.TFF_COBCTR <> '2' AND "
If FindFunction("TecEncDtFt") .AND. TecEncDtFt()
	cQuery += " ( (TFF.TFF_DTENCE > '" + DToS(dDataBase) + "' AND TFF.TFF_ENCE <> '1') OR (TFF.TFF_DTENCE = '" + Space(TamSX3("TFF_DTENCE")[1]) + "' AND TFF.TFF_ENCE <> '1' )) AND "
Else
	cQuery += " TFF.TFF_ENCE <> '1' AND "
EndIf
cQuery += " TFF.D_E_L_E_T_ = ' ' "
cQuery += cWhere

Return cQuery

//------------------------------------------------------------------------------
/*/{Protheus.doc} a870PrcVen

@description Função para atualizar os valores de venda do item

@author	Luiz Gabriel
@since	22/06/2020
/*/
//------------------------------------------------------------------------------
Function a870PrcVen(oModel, nLine, cAcao, cCampo, xValue, xOldValue)
Local nValor 	:= 0
Local nPRCVEN	:= 0 
Local aArea		:= {}

If oModel <> NIL
	If cAcao == 'SETVALUE'
		If cCampo = "CTR_PERCEN"
			nPRCVEN	:= oModel:GetValue("CTR_TOTALC")
			If xValue <> 0
				nValor := nPRCVEN + ( nPRCVEN / 100) * xValue
				oModel:LoadValue("CTR_PRCVEN", nValor)
				oModel:LoadValue("CTR_SUBTOT", nValor * oModel:GetValue("CTR_QTDVEN",nLine))
			Else 
				oModel:LoadValue("CTR_PRCVEN", nPRCVEN)
				oModel:LoadValue("CTR_SUBTOT", nPRCVEN * oModel:GetValue("CTR_QTDVEN",nLine))
			EndIf
		EndIf 
	EndIf
EndIf 

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870DClr

@description Realiza o processamento das revisões

@return lRet, Logico, Indica se a gravação foi feita com sucesso

@author	Augusto Albuquerque
@since	26/06/2020
/*/
//------------------------------------------------------------------------------	
Function At870DClr(cCampo)
Local oModel := FwModelActive()
Local oView := FwViewActive()
Local oMdlORC := oModel:GetModel("ORCMASTER")

If cCampo == 'ORC_ENTIDADE'
	oMdlORC:LoadValue("ORC_CAMPOS",SPACE(1))
	oMdlORC:LoadValue("ORC_PRODF",SPACE(1))
ElseIf cCampo == 'ORC_CAMPOS'
	oMdlORC:LoadValue("ORC_PRODF",SPACE(1))
EndIf

If !ISBlind()
	oView:Refresh('VIEW_ORC')
Endif

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870DPerG

@description gatilho para preencher automatico os contratos filtrados
caso seja mudado somente o valor do percentual
@author	Augusto Albuquerque
@since	22/06/2020
/*/
//------------------------------------------------------------------------------
Function AT870DPerG(oModel, cAction, cField, xValue)
Local oView		:= FwViewActive()
Local oModel 	:= FwModelActive()
Local oMdlDAT 	:= oModel:GetModel('DATMASTER')
Local oMdlCTR 	:= oModel:GetModel('CTRMASTER')
Local nReajust	:= oMdlDAT:GetValue("DAT_PERCEN")
Local nLinha	:= oMdlCtr:Length()
Local nX

If !oMdlCTR:IsEmpty() //nLinha > 0
	If MsgYesNo(STR0078) // "Quer replicar a porcentagem para os itens ja filtrados? "
		For nX := 1 To nLinha
			oMdlCtr:GoLine(nX)
			TFF->(DbSetOrder(1))
			TFF->(DbSeek(xFilial('TFF') + oMdlCTR:GetValue("CTR_TFFCOD")))
			oMdlCTR:LoadValue("CTR_PERCEN", nReajust)
			oMdlCTR:LoadValue('CTR_PRCVEN',TFF->TFF_PRCVEN + ( TFF->TFF_PRCVEN / 100) * nReajust )
			oMdlCTR:LoadValue('CTR_SUBTOT', oMdlCTR:GetValue("CTR_PRCVEN"))
		Next nX
		oMdlCtr:GoLine(1)
		oView:Refresh("VIEW_CTR")
	EndIf
EndIf


Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870DVldDT

@description Função para verificar se pode alterar a data fim do contrato
@author	Augusto Albuquerque
@since	22/06/2020
/*/
//------------------------------------------------------------------------------
Function AT870DVldDT(oModel, cCampo)
Local aErrorDef	:= {}
Local dDtIniLoc	:= CToD('')
Local dDtFimLoc	:= CToD('')
Local lRet		:= .T.
Local oMdlCTR	:= Nil

Default oModel	:= FwModelActive()

oMdlCTR := oModel:GetModel("CTRMASTER")

If cCampo == 'CTR_PERFIM'
	If !At740Recor(oMdlCTR:GetValue("CTR_CONTRT"))
		lRet := .F.
		AAdd( aErrorDef, {oMdlCTR:GetID(),STR0080,STR0079}) // "Contrato recorrente não pode ser alterado a data!" ## "Não é possivel edição."
	EndIf
EndIf

If !lRet
	oModel:GetModel():SetErrorMessage(;
	oModel:GetId(),;	//ID DO FORMULáRIO EM VALIDAçãO
	cCampo,;			//ID DO CAMPO DO FORMULáRIO EM VALIDAçãO
	aErrorDef[1][1],;	//ID DO FORMULáRIO EM QUE OCORREU O ERRO
	cCampo,;			//ID DO CAMPO DO FORMULáRIO EM QUE OCORREU O ERRO
	cCampo,;			//ID DA MENSAGEM DE HELP
	aErrorDef[1][2],;	//MENSAGEM DE ERRO
	aErrorDef[1][3] )	//MENSAGEM DE SOLUçãO
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870DGrav

@description Realiza o processamento das revisões

@return lRet, Logico, Indica se a gravação foi feita com sucesso

@author	Luiz Gabriel
@since	22/06/2020
/*/
//------------------------------------------------------------------------------
Function At870DGrav(oModel)
Local cTpRev	:= ""
Local cTextErr	:= ""
Local lRet		:= .T.
Local aResult	:= {}
Local aErrors	:= {}
Local nMeter 	:= 0
Local nTotal 	:= 0
Local oMdlDAT 	:= oModel:GetModel('DATMASTER')
Local cAprova	:= oMdlDAT:GetValue("DAT_APROVA")
Local cEfetiva	:= oMdlDAT:GetValue("DAT_EFETIV")
Local oDlg		:= Nil
Local oMeter	:= Nil
Local nX

cTpRev	:= oMdlDAT:GetValue("DAT_REVISA")

Begin Transaction
	lRet := ProcessRev(oModel, @aResult)
	If !IsBlind() .AND. lRet
		oDlg := nil
		oSayMtr := nil
		nMeter := 0
		nTotal := LEN(aResult)
		DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0092 + cValToChar(nTotal) + STR0093 // "Executando revisão de " ## " contrato(s) . . . "
			oSayMtr := tSay():New(10,10,{||STR0094},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
			oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlg,220,10,,.T.,/*uParam10*/,/*uParam11*/,.T.)
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (ExecutaRev(aResult, cTpRev, @aErrors,@oDlg,@oMeter, cAprova, cEfetiva, oModel))
	Else
		ExecutaRev(aResult, cTpRev, @aErrors, Nil, NIl, cAprova, cEfetiva, oModel )
	EndIf
End Transaction

If !isBlind() .AND. lRet
	If !Empty(aErrors)
		For nX := 1 To Len(aErrors)
			cTextErr += CRLF + aErrors[nX]
		Next nX
		TxLogFile("revlote",cTextErr)
		Aviso(STR0103,STR0104+CRLF+STR0105+TxLogPath("revlote"),{STR0106},2) // "Atenção" ## "Ocorreram erros no processo de revisão de contratos" ## "Foi gerado o log no arquivo " ## "OK"
	Else
		MsgInfo(STR0102) // "Todos os contratos foram processados."
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ProcessRev

@description Função para realizar o processamento dos contratos

@return lRet, Logico, Indica se a processamento foi feito com sucesso

@author	Luiz Gabriel
@since	22/06/2020
/*/
//------------------------------------------------------------------------------
Static Function ProcessRev(oModel, aResult)
Local lRet		:= .T.
Local oMdlDAT 	:= oModel:GetModel('DATMASTER')
Local oMdlORC 	:= oModel:GetModel('ORCMASTER')
Local oMdlCTR 	:= oModel:GetModel('CTRMASTER')
Local nX		:= 0
Local nLinha	:= 0
Local lNoRecor	:= .T.
Local aDados	:= {}
Local cTpRev	:= ""

cTpRev	:= oMdlDAT:GetValue("DAT_REVISA")

If !Empty(cTpRev)
	nLinha := oMdlCTR:Length()
	For nX := 1 To nLinha
		oMdlCTR:GoLine(nX)
		If oMdlCTR:GetValue("CTR_MARK")
			lNoRecor := At740Recor(oMdlCTR:GetValue("CTR_CONTRT"))
			If lNoRecor
				aAdd(aDados,{{"TFF_COD",oMdlCTR:GetValue("CTR_TFFCOD")},;
				{"TFF_QTDVEN",oMdlCTR:GetValue("CTR_QTDVEN")},;
				{"TFF_PRCVEN",oMdlCTR:GetValue("CTR_PRCVEN")},;
				{"TFF_PERINI",oMdlCTR:GetValue("CTR_PERINI")},;
				{"TFF_PERFIM",oMdlCTR:GetValue("CTR_PERFIM")},;
				{"PERC",oMdlCTR:GetValue("CTR_PERCEN")}})
			Else 
				aAdd(aDados,{{"TFF_COD",oMdlCTR:GetValue("CTR_TFFCOD")},;
				{"TFF_QTDVEN",oMdlCTR:GetValue("CTR_QTDVEN")},;
				{"TFF_PRCVEN",oMdlCTR:GetValue("CTR_PRCVEN")},;
				{"TFF_PERINI",oMdlCTR:GetValue("CTR_PERINI")},;
				{"PERC",oMdlCTR:GetValue("CTR_PERCEN")}})
			EndIf 

			GetItsCTR( @aDados, lNoRecor, oMdlDAT, oMdlCTR:GetValue("CTR_TFFCOD"), oMdlCTR:GetValue("CTR_PERCEN"), oMdlCTR:GetValue("CTR_PERINI"), oMdlCTR:GetValue("CTR_PERFIM") )
		EndIf 
	Next nX
	aResult := At870DProc(aDados, cTpRev) 
	
Else 
	Help( " ", 1, STR0005, Nil, STR0082, 1 ) // "Contratos" ## "Informe o Tipo de Revisão no campo Tp. Revisão(DAT_REVISA)"
EndIf 

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870DProc
@description Executa revisão em lote

@param aProcs, array, array contendo os contratos que devem ser revisados
@param cTpRev, string, código do tipo de revisão

O array aProcs deve seguir o seguinte modelo:
{
    {
        {cCampo1, xValor},;  \
        {cCampo2, xValor},;   |==> registros da mesma "linha" do TECA740 (RH, MI, MC ou TFL)
        {cCampo3, xValor},;  /
        [...],
    },;
    {
        [...]
    },;

    [...]

}

Exemplo:

aDados :=    {;
    {;
        {"TFF_COD","000661"},; //<-- O campo chave é obrigatório (TFF_COD,TFG_COD,TFH_COD ou TFL_CODIGO)
        {"TFF_PRCVEN", 20000},;
        {"TFF_QTDVEN", 2},;
        {"TFF_ESCALA", "00001"};
    },;
    {;
        {"TFG_COD","000592"},;
        {"TFG_QTDVEN", 1},;
        {"TFG_PRCVEN", 100};
    };
            }


@author Mateus Boiani
@since  23/06/2020
/*/
//------------------------------------------------------------------------------
Function At870DProc(aDados, cTpRev)
Local cTipo 	:= ""
Local cContrat 	:= ""
Local cCodigo	:= ""
Local cAliasCtr := ""
Local cSql 		:= ""
Local cMsg 		:= ""
Local nX
Local nPosKey 	:= 0
Local nAux 		:= 0
Local aErrors 	:= {}
Local aProcs 	:= {}

Default aDados :=    {}

For nX := 1 To Len(aDados)
    If (nPosKey := ASCAN(aDados[nX], {|a| a[1] == "TFF_COD"})) > 0
        cTipo := "TFF"
		cCodigo	:= aDados[nX][nPosKey][2]
    ElseIf (nPosKey := ASCAN(aDados[nX], {|a| a[1] == "TFL_CODIGO"})) > 0
        cTipo := "TFL"
		cCodigo	:= aDados[nX][nPosKey][2]
    ElseIf (nPosKey := ASCAN(aDados[nX], {|a| a[1] == "TFH_COD"})) > 0
        cTipo := "TFH"
		cCodigo	:= aDados[nX][nPosKey][2]
    ElseIf (nPosKey := ASCAN(aDados[nX], {|a| a[1] == "TFG_COD"})) > 0
        cTipo := "TFG"
		cCodigo	:= aDados[nX][nPosKey][2]
	ElseIf (nPosKey := ASCAN(aDados[nX], {|a| a[1] == "TFU_CODIGO"})) > 0
		cTipo := "TFF"
		cCodigo	:= POSICIONE("TFU",1,xFilial("TFU")+aDados[nX][nPosKey][2],"TFU_CODTFF")
    EndIf
    If nPosKey > 0
        cContrat := POSICIONE(cTipo,1,xFilial(cTipo)+cCodigo,cTipo+"_CONTRT")
        IF !Empty(cContrat)
            If EMPTY(aProcs) .OR. (nAux := ASCAN(aProcs, {|a| a[1] == cContrat})) == 0
                AADD(aProcs, {cContrat,"",.T.,{}})
                AADD(aProcs[LEN(aProcs)][4],ACLONE(aDados[nX]))
            ElseIf nAux > 0
                AADD(aProcs[nAux][4],ACLONE(aDados[nX]))
            EndIF
        Else
            AADD(aErrors, (STR0083 + aDados[nX][nPosKey][2] + "(" + cTipo + ")"+CRLF+REPLICATE("-",50))) // "Contrato não localizado para o item "
        EndIf
    EndIf
Next nX

For nX := 1 To LEN(aProcs)
    //1=Ativo;2=Em Revisão;3=Revisado;4=Aguardado aprovação;5=Encerrado;6=Cancelado;7=Inativo
    cAliasCtr := GetNextAlias()
    cSql := ""
    cSql += " SELECT TFJ.TFJ_STATUS, TFJ.TFJ_CODIGO FROM " + RetSqlName("TFJ") + " TFJ "
    cSql += " WHERE TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
    cSql += " TFJ.D_E_L_E_T_ = ' ' AND TFJ.TFJ_CONTRT = '" + aProcs[nX][1] + "'
    cSql := ChangeQuery(cSql)
    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasCtr, .F., .T.)

    While !(cAliasCtr)->(EOF())
        If !((cAliasCtr)->TFJ_STATUS $ '1|3')
            aProcs[nX][3] := .F.
            cMsg := STR0084 + aProcs[nX][1] + STR0085 // "O contrato " ## " não será processado pois encontra-se "
            If (cAliasCtr)->TFJ_STATUS == '2'
                cMsg += STR0086 // "Em Revisão"
            ElseIf (cAliasCtr)->TFJ_STATUS == '4'
                cMsg += STR0087 // "Aguardado aprovação"
            ElseIf (cAliasCtr)->TFJ_STATUS == '5'
                cMsg += STR0088 // "Encerrado"
            ElseIf (cAliasCtr)->TFJ_STATUS == '6'
                cMsg += STR0089 // "Cancelado"
            ElseIf (cAliasCtr)->TFJ_STATUS == '7'
                cMsg += STR0090 // "Inativo"
            Else
                cMsg := STR0084 + aProcs[nX][1] + STR0091 // "O contrato " ## " não será processado pois não está Ativo ou Revisado "
            EndIf
            AADD(aErrors, cMsg+CRLF+REPLICATE("-",50))
            Exit
        ElseIf (cAliasCtr)->TFJ_STATUS == '1'
            aProcs[nX][2] := (cAliasCtr)->TFJ_CODIGO
        EndIf
        (cAliasCtr)->(DbSkip())
    End
    (cAliasCtr)->(DbCloseArea())
Next nX

Return aProcs
//------------------------------------------------------------------------------
/*/{Protheus.doc} ExecutaRev
@description Executa as revisões de acordo com o parâmetro aProcs

@param aProcs, array, array contendo os contratos que devem ser revisados
@param cTpRev, string, código do tipo de revisão
@param aErrors, array, array com os erros capturados durante a execução
@param oDlg, obj, dialog em que a loadbar fica posicionada
@param oMeter, obj, loadbar

@author Mateus Boiani
@since  23/06/2020
/*/
//------------------------------------------------------------------------------
Static Function ExecutaRev(aProcs, cTpRev, aErrors, oDlg, oMeter, cAprova, cEfetiva, oModel)
Local nX
Local nY
Local nZ
Local lLoadBar
Local lProcessa := .T.
Local lRecorre	:= .F. //'TFJ_REFER', 'TFJ_PREVIS')
Local lApliMC	:= oModel:GetValue("DATMASTER", "DAT_APLIMC") == '1'
Local lApliMI	:= oModel:GetValue("DATMASTER", "DAT_APLIMI") == '1'
Local nError := 0
Local cTextErr := ""
Local cContrato := ""
Local cNewTFJ	:= ""

Default oDlg := nil
Default oMeter := nil
Default cAprova := "2"
Default cEfetiva := "2"

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil
If !EMPTY(cTpRev) .AND. POSICIONE("CN0",1,xFilial("CN0")+cTpRev,"CN0_TIPO") == 'F'
    For nX := 1 To Len(aProcs)
        If aProcs[nX][3]
            lProcessa := .T.
            DbSelectArea("TFJ")
            TFJ->(DbSetOrder(1))
            TFJ->(MsSeek(xFilial("TFJ")+aProcs[nX][2]))

            DbSelectArea("CN9")
			CN9->(DbSetOrder(1))
			CN9->(MsSeek(xFilial("CN9")+aProcs[nX][2]+TFJ->TFJ_CONREV))

            For nY := 1 TO LEN(aProcs[nX][4])
                For nZ := 1 To LEN(aProcs[nX][4][nY])
                    If aProcs[nX][4][nY][nZ][1] == 'TFF_COD'
                        If !EMPTY(POSICIONE("TFF",1,xFilial("TFF") + aProcs[nX][4][nY][nZ][2],"TFF_CODSUB"))
                            lProcessa := .F.
                            AADD(aErrors, STR0095 + aProcs[nX][4][nY][nZ][2] + STR0096) // "O item de código " ## " (TFF) contém substituto (TFF_CODSUB)"
                            AADD(aErrors, STR0084 + TFJ->TFJ_CONTRT + STR0098+CRLF+REPLICATE("-",50)) // "O contrato " ## " não foi processado."
                            Exit
                        EndIf
                    ElseIf aProcs[nX][4][nY][nZ][1]  == 'TFH_COD'
                        If !EMPTY(POSICIONE("TFH",1,xFilial("TFH") + aProcs[nX][4][nY][nZ][2],"TFH_CODSUB"))
                            lProcessa := .F.
                            AADD(aErrors, STR0095 + aProcs[nX][4][nY][nZ][2] + STR0097) // "O item de código " ## " (TFH) contém substituto (TFH_CODSUB)"
                            AADD(aErrors, STR0084 + TFJ->TFJ_CONTRT + STR0098+CRLF+REPLICATE("-",50)) // "O contrato " ## " não foi processado."
                            Exit
                        EndIf
                    ElseIf aProcs[nX][4][nY][nZ][1]  == 'TFG_COD'
                        If !EMPTY(POSICIONE("TFG",1,xFilial("TFG") + aProcs[nX][4][nY][nZ][2],"TFG_CODSUB"))
                            lProcessa := .F.
                            AADD(aErrors, STR0095 + aProcs[nX][4][nY][nZ][2] + STR0099) // "O item de código " ## " (TFG) contém substituto (TFG_CODSUB)"
                            AADD(aErrors, STR0084 + TFJ->TFJ_CONTRT + STR0098+CRLF+REPLICATE("-",50)) // "O contrato " ## " não foi processado."
                            Exit
                        EndIf
                    ElseIf aProcs[nX][4][nY][nZ][1]  == 'TFL_CODIGO'
                        If !EMPTY(POSICIONE("TFL",1,xFilial("TFL") + aProcs[nX][4][nY][nZ][2],"TFL_CODSUB"))
                            lProcessa := .F.
                            AADD(aErrors, STR0095 + aProcs[nX][4][nY][nZ][2] + STR0100) // "O item de código " ## " (TFL) contém substituto (TFL_CODSUB)"
                            AADD(aErrors, STR0084 + TFJ->TFJ_CONTRT + STR0098+CRLF+REPLICATE("-",50)) // "O contrato " ## " não foi processado."
                            Exit
                        EndIf
                    EndIf
                Next nZ
            Next nY
            If lProcessa
                    cContrato := TFJ->TFJ_CONTRT
					cCodTFJ	:= TFJ->TFJ_CODIGO
					lRecorre := TFJ->TFJ_CNTREC == '1'
                    If !At870PRev(cCodTFJ,; //cCodTfj
                            TFJ->TFJ_CONTRT,; //cCont
                            TFJ->TFJ_CONREV,; //cRevis
                            .T.,;             //lSemTela
                            cTpRev,;          //cCodCN0
                            .F.,;             //lRevAssist
                            0,;               //nPercAuto
                            0,;               //nDiasAuto
                            {|oModel| At870dExec(oModel,aProcs[nX][4], @aErrors, lRecorre, lApliMC, lApliMI )},;         //bSemTela
                            @cNewTFJ )
                        AADD(aErrors, STR0084 + cContrato + STR0098+CRLF+REPLICATE("-",50)) // "O contrato " ## " não foi processado."
                        nError++
			    	Else
				    	If cEfetiva == "1"
					    	If !At870EftRv(cNewTFJ,; //cCodTfj
									cTpRev,; //cCont
									"F",; //cRevis
									.T.,;
									{|oModel| AT870DEfet(oModel, @aErrors)})
						    	AADD(aErrors, STR0084 + cContrato + STR0113+CRLF+REPLICATE("-",50)) // "O contrato " ## " não foi efetivado."
						    	nError++
					    	Else
						    	If cAprova == "1"
								    At870AprRv(TFJ->TFJ_CONTRT,TFJ->TFJ_CONREV,TFJ->TFJ_STATUS,.T.)
							    EndIf
						    EndIf
					    EndIf
                    EndIf  
            Else
                nError++
            EndIf
        EndIf
        If lLoadBar
            oMeter:Set(nX)
            oMeter:Refresh()
        EndIf
    Next nX
Else
    AADD(aErrors, STR0101) // "Tipo de revisão inválida."
EndIf

If lLoadBar
	oDlg:End()
EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At870dExec
@description bloco de código executado na tela da revisão

@param oModel, obj, modelo que será utilizado para posicionar
@param aItens, array, array com instruções chave/valor para inserir no modelo
@param aErrors, array, array com os erros capturados durante a execução

@return lRet, bool, indica se conseguiu revisar (.T.) ou não (.F.)

@author Mateus Boiani
@since  23/06/2020
/*/
//------------------------------------------------------------------------------
Function At870dExec(oModel,aItens,aErrors, lRecorre, lApliMC, lApliMI )
Local nX
Local nY
Local nZ
Local nA
Local aArea		:= GetArea()
Local aCompet	:= {}
Local aOrdem 	:= {"TFL","TFF","TFH","TFG","TFU"}
Local aChave 	:= {"TFL_CODIGO","TFF_COD","TFH_COD","TFG_COD","TFU_CODIGO"}
Local aSubMdls	:= {"TFL_LOC","TFF_RH","TFH_MC","TFG_MI","TFU_HE"}
Local cCompet	:= ""
Local cCodTFL	:= ""
Local cCodTFF	:= ""
Local cCodTFJ	:= oModel:GetValue("TFJ_REFER","TFJ_CODIGO")
Local nPosChv 	:= 0
Local nValor	:= 0
Local nPercen	:= 0
Local nPosPerc	:= 0
Local nTotal	:= 0
Local cValKey 	:= ""
Local lRet 		:= .T.

For nY := 1 To Len(aOrdem)
    If !lRet
        Exit
    EndIf
    For nX := 1 To Len(aItens)
        If !lRet
            Exit
        EndIf
		If (aOrdem[nY]+"_") $ aItens[nX][1][1]
			nPosChv := ASCAN(aItens[nX], {|a| a[1] == aChave[nY]})
			cValKey := aItens[nX][nPosChv][2]
			If lRet .AND. (lRet := PosByKey(aOrdem[nY],cValKey,oModel))
				For nZ := 1 To LEN(aItens[nX])
					If aItens[nX][nZ][1] != aChave[nY]
						If aItens[nX][nZ][1] != "PERC"
							If !oModel:SetValue(aSubMdls[nY],aItens[nX][nZ][1],aItens[nX][nZ][2])
								lRet := .F.
								AADD(aErrors, STR0107 + aItens[nX][nZ][1] + "(" + AllToChar(aItens[nX][nZ][2]) + ")") // "Não foi possível inserir o valor no campo "
								If oModel:HasErrorMessage()
									If !EMPTY(STRTRAN(Alltrim(oModel:GetErrorMessage()[6]), CRLF))
										AADD(aErrors, STRTRAN(Alltrim(oModel:GetErrorMessage()[6]), CRLF) )
									EndIf
									If !EMPTY(STRTRAN(Alltrim(oModel:GetErrorMessage()[7]), CRLF))
										AADD(aErrors, STRTRAN(Alltrim(oModel:GetErrorMessage()[7]), CRLF) )
									EndIf
								EndIf
								Exit
							EndIf
						EndIf
					Else
						If (aOrdem[nY] == 'TFF' .OR. ((aOrdem[nY] == 'TFG' .AND. lApliMI) .OR. (aOrdem[nY] == 'TFH' .AND. lApliMC))) .AND. lRecorre .AND. TecBHasCrn()
							If Len(aCompet := CompetTGT( aItens[nX][nZ][2], aOrdem[nY] )) > 0
								If (nPosPerc := Ascan( aItens[nX], { |a| a[1] == "PERC"})) > 0
									nPercen := aItens[nX][nPosPerc][2]
									For nA := 1 To Len(aCompet)
										nTotal := aCompet[nA][2] + ( aCompet[nA][2] / 100) * nPercen
										At740IAuto(aOrdem[nY], oModel:GetValue(aSubMdls[nY],aOrdem[nY]+"_COD"), aCompet[nA][1], nTotal, cCodTFJ )
									Next nA
								EndIf
							EndIf
						EndIf
					EndIf
				Next nZ
			Else
				AADD(aErrors, STR0108+ cValKey + "(" + aOrdem[nY] + ")" ) // "Não foi possível posicionar o item "
				Exit
			EndIf
		EndIf
    Next nX
Next nY

RestArea(aArea)
Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} PosByKey
@description Posiciona na linha do modelo utilizando um campo chave

@param cTabela, string, tabela do registro
@param cValChave, string, valor do registro chave
@param oModel, obj, modelo que será utilizado para posicionar

@return lRet, bool, indica se conseguiu posicionar (.T.) ou não (.F.)

@author Mateus Boiani
@since  23/06/2020
/*/
//------------------------------------------------------------------------------
Static Function PosByKey(cTabela, cValChave, oModel)
Local lRet := .F.
Local lPrecific := .F.
Local cCodTFL := ""
Local cCodTFF := ""
Local oMdlTFL
Local oMdlTFF
Local oMdlTFH
Local oMdlTFG
Local oMdlTFU

If VALTYPE(oModel) == "O" .AND. (oModel:GetId() == "TECA740" .OR. oModel:GetId() == "TECA740F")
    lPrecific := (oModel:GetId() == "TECA740F")
    oMdlTFL := oModel:GetModel("TFL_LOC")
    oMdlTFF := oModel:GetModel("TFF_RH")
    oMdlTFH := oModel:GetModel("TFH_MC")
    oMdlTFG := oModel:GetModel("TFG_MI")
	oMdlTFU := oModel:GetModel("TFU_HE")
    If cTabela == "TFL"
        If oMdlTFL:SeekLine({{"TFL_CODIGO",cValChave}})
            lRet := (oMdlTFL:GetValue("TFL_CODIGO") == cValChave)
        EndIf
    ElseIf cTabela == "TFF"
        cCodTFL := POSICIONE("TFF",1,xFilial("TFF")+cValChave,"TFF_CODPAI")
        If oMdlTFL:SeekLine({{"TFL_CODIGO",cCodTFL}})
            If oMdlTFF:SeekLine({{"TFF_COD",cValChave}})
                lRet := (oMdlTFF:GetValue("TFF_COD") == cValChave)
            EndIf
        EndIf
    ElseIf cTabela == "TFG"
        If lPrecific
            cCodTFL := POSICIONE("TFG",1,xFilial("TFG")+cValChave,"TFG_CODPAI")
            If oMdlTFL:SeekLine({{"TFL_CODIGO",cCodTFL}})
                If oMdlTFG:SeekLine({{"TFG_COD",cValChave}})
                    lRet := (oMdlTFG:GetValue("TFG_COD") == cValChave)
                EndIf
            EndIf
        Else
            cCodTFF := POSICIONE("TFG",1,xFilial("TFG")+cValChave,"TFG_CODPAI")
            cCodTFL := POSICIONE("TFF",1,xFilial("TFF")+cCodTFF,"TFF_CODPAI")
            If oMdlTFL:SeekLine({{"TFL_CODIGO",cCodTFL}})
                If oMdlTFF:SeekLine({{"TFF_COD",cCodTFF}})
                    If oMdlTFG:SeekLine({{"TFG_COD",cValChave}})
                        lRet := (oMdlTFG:GetValue("TFG_COD") == cValChave)
                    EndIf
                EndIf
            EndIf
        EndIf
    ElseIf cTabela == "TFH"
        If lPrecific
            cCodTFL := POSICIONE("TFH",1,xFilial("TFH")+cValChave,"TFH_CODPAI")
            If oMdlTFL:SeekLine({{"TFL_CODIGO",cCodTFL}})
                If oMdlTFH:SeekLine({{"TFH_COD",cValChave}})
                    lRet := (oMdlTFH:GetValue("TFH_COD") == cValChave)
                EndIf
            EndIf
        Else
            cCodTFF := POSICIONE("TFH",1,xFilial("TFH")+cValChave,"TFH_CODPAI")
            cCodTFL := POSICIONE("TFF",1,xFilial("TFF")+cCodTFF,"TFF_CODPAI")
            If oMdlTFL:SeekLine({{"TFL_CODIGO",cCodTFL}})
                If oMdlTFF:SeekLine({{"TFF_COD",cCodTFF}})
                    If oMdlTFH:SeekLine({{"TFH_COD",cValChave}})
                        lRet := (oMdlTFH:GetValue("TFH_COD") == cValChave)
                    EndIf
                EndIf
            EndIf
        EndIf
	ElseIf cTabela == "TFU"
		cCodTFF := POSICIONE("TFU",1,xFilial("TFU")+cValChave,"TFU_CODTFF")
		cCodTFL := POSICIONE("TFF",1,xFilial("TFF")+cCodTFF,"TFF_CODPAI")
		If oMdlTFL:SeekLine({{"TFL_CODIGO",cCodTFL}})
			If oMdlTFF:SeekLine({{"TFF_COD",cCodTFF}})
				If oMdlTFU:SeekLine({{"TFU_CODIGO",cValChave}})
					lRet := (oMdlTFU:GetValue("TFU_CODIGO") == cValChave)
				EndIf
			EndIf
		EndIf
    EndIf
EndIf
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870DEfet

@description insere valor no campo justificativa na efetivação da revisão
@return lRet

@author	Augusto Albuquerque
@since	22/06/2020
/*/
//------------------------------------------------------------------------------
Function AT870DEfet(oModel,aErrors)
Local oMdlCN9	:= oModel:GetModel("CN9MASTER") 
Local lRet		:= .T.
Local cMensagem := STR0114 +;	//"Revisão incluida por meio da Revisão em Lote."
				CRLF + STR0115 + __cUserID + CRLF +;	//"Usuário: "
				STR0116 + dToC(Date()) + CRLF +;	//"Data da inclusão: "
				STR0117 + Time()	//"Horário da inclusão: "
				
If !oMdlCN9:SetValue("CN9_JUSTIF", cMensagem)
	lRet := .F.
	If oModel:HasErrorMessage()
		If !EMPTY(STRTRAN(Alltrim(oModel:GetErrorMessage()[6]), CRLF))
			AADD(aErrors, STRTRAN(Alltrim(oModel:GetErrorMessage()[6]), CRLF) )
		EndIf
		If !EMPTY(STRTRAN(Alltrim(oModel:GetErrorMessage()[7]), CRLF))
			AADD(aErrors, STRTRAN(Alltrim(oModel:GetErrorMessage()[7]), CRLF) )
		EndIf
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetItsCTR

@description Realiza o calculo para os itens de MI/MC/HE
@return lRet, Logico, Indica se a gravação foi feita com sucesso

@author	Augusto Albuquerque
@since	07/10/2021
/*/
//------------------------------------------------------------------------------
Static Function GetItsCTR( aDados, lNoRecor, oMdlDAT, cCodTFF, nPercen, dDataIni, dDataFim )
Local cQuery	:= ""
Local cAliasITS	:= ""
Local dDtQryFim	:= SToD("")
Local dDtQryFim := STod("")
Local lApliMC	:= oMdlDAT:GetValue("DAT_APLIMC") == '1'
Local lApliMI	:= oMdlDAT:GetValue("DAT_APLIMI") == '1'
Local lApliHE	:= oMdlDAT:GetValue("DAT_APLIHE") == '1'
Local lExecut	:= lApliMC .OR. lApliMI .OR. lApliHE

If lExecut
	cQuery := ""
	If lApliMI
		cQuery += " SELECT TFG.TFG_PRCVEN AS PRECO, TFG.TFG_QTDVEN AS QUANTIDADE, TFG.TFG_COD AS CODIGO, TFG.TFG_PERINI AS DTINI, TFG.TFG_PERFIM AS DTFIM, 'TFG' AS TABELA "
		cQuery += " FROM " + RetSqlName("TFG") + " TFG "
		cQuery += " WHERE "
		cQuery += " TFG.TFG_FILIAL = '" + xFilial("TFG") + "' "
		cQuery += " AND TFG.TFG_COBCTR <> '2' "
		cQuery += " AND TFG.TFG_CODPAI = '" + cCodTFF + "' "
		cQuery += " AND TFG.D_E_L_E_T_ = ' ' "

		If lApliMC
			cQuery += " UNION ALL "
		EndIf
	EndIf

	If lApliMC
		cQuery += " SELECT TFH.TFH_PRCVEN AS PRECO, TFH.TFH_QTDVEN AS QUANTIDADE, TFH.TFH_COD AS CODIGO, TFH.TFH_PERINI AS DTINI, TFH.TFH_PERFIM AS DTFIM, 'TFH' AS TABELA "
		cQuery += " FROM " + RetSqlName("TFH") + " TFH "
		cQuery += " WHERE "
		cQuery += " TFH.TFH_FILIAL = '" + xFilial("TFH") + "' "
		cQuery += " AND TFH.TFH_COBCTR <> '2' "
		cQuery += " AND TFH.TFH_CODPAI = '" + cCodTFF + "' "
		cQuery += " AND TFH.D_E_L_E_T_ = ' ' "

		If lApliHE
			cQuery += " UNION ALL "
		EndIf
	EndIf

	If lApliHE
		cQuery += " SELECT TFU.TFU_VALOR AS PRECO, 1 AS QUANTIDADE, TFU.TFU_CODIGO AS CODIGO, '1' AS DTINI, '1' AS DTFIM, 'TFU' AS TABELA "
		cQuery += " FROM " + RetSqlName("TFU") + " TFU "
		cQuery += " WHERE "
		cQuery += " TFU.TFU_FILIAL = '" + xFilial("TFU") + "' "
		cQuery += " AND TFU.TFU_CODTFF = '" + cCodTFF + "' "
		cQuery += " AND TFU.D_E_L_E_T_ = ' ' "
	EndIf

	cQuery := ChangeQuery(cQuery)
	cAliasITS := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasITS, .F., .T.)

	While !(cAliasITS)->(EOF())
		If (cAliasITS)->(TABELA) <> 'TFU'
			dDtQryIni := SToD((cAliasITS)->(DTINI))
			dDtQryFim := SToD((cAliasITS)->(DTFIM))

			If dDataFim < dDtQryFim
				dDtQryFim := dDataFim
			EndIf

			If dDataIni > dDtQryIni
				dDtQryIni := dDataIni
			EndIf

			If lNoRecor
				aAdd(aDados,{{(cAliasITS)->(TABELA)+"_COD",(cAliasITS)->(CODIGO)},;
				{(cAliasITS)->(TABELA)+"_QTDVEN",(cAliasITS)->(QUANTIDADE)},;
				{(cAliasITS)->(TABELA)+"_PRCVEN",(cAliasITS)->(PRECO) + ( (cAliasITS)->(PRECO) / 100) * nPercen},;
				{(cAliasITS)->(TABELA)+"_PERINI",dDtQryIni},;
				{(cAliasITS)->(TABELA)+"_PERFIM",dDtQryFim},;
				{"PERC",nPercen}})
			Else 
				aAdd(aDados,{{(cAliasITS)->(TABELA)+"_COD",(cAliasITS)->(CODIGO)},;
				{(cAliasITS)->(TABELA)+"_QTDVEN",(cAliasITS)->(QUANTIDADE)},;
				{(cAliasITS)->(TABELA)+"_PRCVEN",(cAliasITS)->(PRECO) + ( (cAliasITS)->(PRECO) / 100) * nPercen},;
				{(cAliasITS)->(TABELA)+"_PERINI",dDataIni},;
				{"PERC",nPercen}})
			EndIf
		Else 
			aAdd(aDados,{{"TFU_CODIGO",(cAliasITS)->(CODIGO)},;
				{"TFU_VALOR", (cAliasITS)->(PRECO) + ( (cAliasITS)->(PRECO) / 100) * nPercen},;
				{"PERC",nPercen}})
		EndIf
		(cAliasITS)->(dbSkip())
	EndDo
	(cAliasITS)->(dbCloseArea())
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CompetTGT

@description Verifica se possui TGT para o prox periodo de medição

@return lRet, Logico, Indica se existe

@author	Augusto Albuquerque
@since	07/10/2021
/*/
//------------------------------------------------------------------------------
Static Function CompetTGT( cCodItem, cIdItem )
Local aArea		:= GetArea()
Local aRet		:= {}
Local cQuery	:= ""
Local cAliasTGT	:= GetNextAlias()
Local lExcedente := TecBHasExc()

cQuery := ""
cQuery += " SELECT TGT.TGT_COMPET, TGT.TGT_VALOR "
cQuery += " FROM " + RetSQLName("TGT") + " TGT "
cQuery += " WHERE "
cQuery += " TGT.TGT_FILIAL = '" + xFilial("TGT") + "' "
cQuery += " AND TGT.D_E_L_E_T_ = ' ' "
cQuery += " AND TGT.TGT_TPITEM = '" + cIdItem + "' "
cQuery += " AND TGT.TGT_CDITEM = '" + cCodItem + "' "
If lExcedente
	cQuery += " AND TGT.TGT_EXCEDT <> '1' "
EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTGT, .F., .T.)

While !(cAliasTGT)->(EOF())
	If ASCAN(aRet, { |x| x[1] == (cAliasTGT)->(TGT_COMPET)}) == 0
		AADD(aRet, {(cAliasTGT)->(TGT_COMPET), (cAliasTGT)->(TGT_VALOR)})
	EndIf
	(cAliasTGT)->(dbSkip())
EndDo
(cAliasTGT)->(dbCloseArea())

RestArea(aArea)

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870DPerC

@description Gatilho do campo 'CTR_SUBTOT' para o percentual ('CTR_PERCEN')

@return nRet, valor em porcentagem

@author	Augusto Albuquerque
@since	07/10/2021
/*/
//------------------------------------------------------------------------------
Function AT870DPerC( nValTotal )
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel 		:= FwModelActive()
Local nRet	    	:= 0
Local nAux			:= 0

If oModel <> Nil
	nAux := nValTotal / oModel:GetValue("CTRMASTER", "CTR_TOTALC")

	If nAux >= 1
		nAux -= 1
	EndIf

	nRet := nAux * 100
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870DQTDS

@description Gatilho para preencher o campo Total, quando altera a quantidade ou o valor

@return nRet, valor total do item

@author	Augusto Albuquerque
@since	07/10/2021
/*/
//------------------------------------------------------------------------------
Function AT870DQTDS( nQtd, nPrcVen )
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel 		:= FwModelActive()
Local nRet	    	:= 0

nRet := nQtd * nPrcVen


FWRestRows( aSaveLines )
RestArea(aArea)

Return nRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870DSelCT
@description Chama a tela de seleção de contrato e preenche os contratos no grid de filtro
@return Verdadeiro(.T.)
@author	Luiz Gabriel
@since	22/06/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At870DSelCT(oModel)
Local oMdlORC 	:= oModel:GetModel('ORCMASTER')
Local aButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0044},;
			 	   {.T.,STR0003},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Incluir" ## "Fechar"
Local nOpcA		:= 0
Local aContrt	:= {}
Local nX 		:= 0
Local nLinha	:= 1

nOpcA := FWExecView("","VIEWDEF.TECA870E", MODEL_OPERATION_INSERT,,,,60,aButtons)

If nOpcA == 0
	aContrt := GetCont870E()
	For nX := 1 To Len(aContrt)
		If !oMdlORC:IsEmpty()
			nLinha := oMdlORC:AddLine()
		EndIf
		oMdlORC:GoLine(nLinha)
		oMdlORC:LoadValue( "ORC_ENTIDADE", "TFJ" ) //Entidade
		oMdlORC:LoadValue( "ORC_CAMPOS", "TFJ_CONTRT" ) //Campo
		oMdlORC:LoadValue( "ORC_PRODF", aContrt[nX] ) //Valor
	Next nX
	//Limpa o array statico
	ClearCtr870E()	
EndIf 
oMdlORC:GoLine(1)

Return .T.
