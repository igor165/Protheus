#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA203.CH"

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

Static cRet203F3	:= ""
Static lAjustOK		:= .F.
Static lCloseOK 	:= .F.

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA203

@description Horas Planejadas x Horas Realizadas 

@author	diego.bezerra
@since	09/12/2019
/*/
//------------------------------------------------------------------------------
Function TECA203()


Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
			 	   {.T.,STR0001},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}  // "Fechar"

ValidSXB()
FWExecView("","VIEWDEF.TECA203", MODEL_OPERATION_INSERT,,,,,aButtons)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados

@author	diego.bezerra
@since 09/12/2019
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
	
Local oStrAA1	:= FWFormModelStruct():New()	// Atendentes
Local oStrABB	:= FWFormModelStruct():New()	// Agendas
Local oStrTOT	:= FWFormModelStruct():New()	// Totais
Local aTables	:= {}
Local aFields	:= {}
Local nX		:= 0
Local nY		:= 0
Local xAux

oStrAA1:AddTable("   ",{}, "	")
oStrABB:AddTable("   ",{}, "  	")
oStrTOT:AddTable("   ",{}, "   	")

AADD(aTables, {oStrAA1, "AA1"})
AADD(aTables, {oStrABB, "ABB"})
AADD(aTables, {oStrTOT, "TOT"})

For nY := 1 to Len(aTables)
	aFields := At203Def(aTables[nY][2])
	For nX := 1 to Len(aFields)
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

xAux := FwStruTrigger( 'AA1_CODTEC', 'AA1_NOMTEC',;
	'Posicione("AA1",1,xFilial("AA1") + FwFldGet("AA1_CODTEC"),"AA1_NOMTEC")', .F. )
	oStrAA1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

oModel := MPFormModel():New('TECA203',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields('AA1MASTER',/*cOwner*/,oStrAA1,{|oMdlAA1,cAction,cField,xValue, xOldValue| PreLinAA1(oMdlAA1,cAction,cField,xValue)},/*bPosValidacao*/,/*bFieldAbp*/,/*bCarga*/,/*bFieldTfl*/)
oModel:SetPrimaryKey({"AA1_FILIAL","AA1_CODTEC"})
oModel:AddGrid('ABBDETAIL', 'AA1MASTER', oStrABB)

oModel:AddFields('FLDTOTAIS','AA1MASTER', oStrTOT)
oModel:SetDescription(STR0002) // "Planejado X Realizado"

oModel:GetModel('AA1MASTER'):SetDescription(STR0003) 	// "Filtros"
oModel:GetModel('ABBDETAIL'):SetDescription(STR0004) 	// "Agendas"
oModel:GetModel('FLDTOTAIS'):SetDescription(STR0005) 	// "Totalizadores"
 
oModel:SetActivate( {|| .T. } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	diego.bezerra
@since 09/12/2019
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel	:= ModelDef()
Local oStrAA1	:= FWFormViewStruct():New()		// Atendentes
Local oStrABB	:= FWFormViewStruct():New()		// Agendas
Local oStrTOT	:= FWFormViewStruct():New()		// Totais
Local aTables	:= {}
Local aFields	:= {}
Local aTamABB	:= {}
Local aTamAA1	:= {}
Local nX		:= 0
Local nY		:= 0
Local lMonitor	:= IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366


AADD(aTables, {oStrAA1, "AA1"})
AADD(aTables, {oStrABB, "ABB"})
AADD(aTables, {oStrTOT, "TOT"})

For nY := 1 to LEN(aTables)
	aFields := At203Def(aTables[nY][2])

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

oStrABB:RemoveField("ABB_CHEGOU")
oStrABB:RemoveField("ABB_ATENDE")
oStrAA1:RemoveField("AA1_FILIAL")
oStrAA1:RemoveField("AA1_FUNCAO")
oStrAA1:RemoveField("AA1_CDFUNC")
oStrAA1:RemoveField("RJ_DESC")
oStrABB:RemoveField("ABB_HRTOT")

oView := FWFormView():New()
oView:SetModel(oModel)

AADD(aTamAA1, 20.00)
AADD(aTamAA1, 08.00)
AADD(aTamAA1, 60.00)
AADD(aTamAA1, 12.00)

AADD(aTamABB, 84.00)
AADD(aTamABB, 16.00)

If lMonitor
	oView:SetContinuousForm()
EndIf

oView:AddField('VIEW_MASTER', oStrAA1, 'AA1MASTER')
oView:EnableTitleView('VIEW_MASTER', STR0003) // "Filtros"

oView:AddGrid('DETAIL_ABB', oStrABB, 'ABBDETAIL')
oView:EnableTitleView('DETAIL_ABB', STR0004) 	// "Agendas"

oView:AddField('VIEW_TOTAIS', oStrTOT, 'FLDTOTAIS')
oView:EnableTitleView('VIEW_TOTAIS', STR0005)//'Totalizadores'

oView:CreateHorizontalBox( 'FILTROS'	, aTamAA1[1])
oView:CreateHorizontalBox( 'BTN_FIL'	, aTamAA1[2] )
oView:CreateHorizontalBox( 'AGENDAS'	, aTamAA1[3] )
oView:CreateHorizontalBox( 'TOTAIS'		, aTamAA1[4] )

oView:CreateVerticalBox( 'BTN_FIL_L', aTamABB[1], 'BTN_FIL')
oView:CreateVerticalBox( 'BTN_FIL_R', aTamABB[2], 'BTN_FIL')

oView:AddUserButton("Exportar" ,"",{|| at203Sel() })

oView:AddOtherObject("CONSULT",{|oPanel| at203Act(oPanel) })
oView:SetOwnerView("CONSULT","BTN_FIL_R")

oView:SetOwnerView('VIEW_MASTER','FILTROS')
oView:SetOwnerView('DETAIL_ABB','AGENDAS')
oView:SetOwnerView('VIEW_TOTAIS','TOTAIS')

SetKey( VK_F10, { || FwMsgRun(Nil,{|| LoadABB()}, Nil, STR0006)}	) // "Processando..."

If ExistFunc('AT203ABTbl') .And. ABB->(ColumnPos("ABB_JUSTIF")) > 0
	SetKey( VK_F8, { || At203Batida() })
	oView:AddUserButton(STR0091,"",{|| At203Batida() },,,) //"Ajuste de Batida"
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} at203Act
	Chamada do botão cunsultar

@author	diego.bezerra
@since 09/12/2019
/*/
//-------------------------------------------------------------------
Static function at203Act(oPanel)
Local lMonitor := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366

	Local oButton	:= nil
	Local cSCSSBtn	:= ColorButton()
Local aTamanho	:= {}

If lMonitor
	AADD(aTamanho, 72.00)
Else
	AADD(aTamanho, 65.00)
EndIf
	

// Ancoramos os objetos no oPanel passado
@ (oPanel:nHeight / 2) - 12, ((oPanel:nWidth/2) - aTamanho[1]) Button oButton Prompt STR0007 Of oPanel Size 70,11 Pixel	 // "Consultar (F10)"

// Define CSS
oButton:SetCss( cSCSSBtn )

// Atribuição de ação ao acionamento do botão
oButton:bAction	:= { || At230ALoad() }
		
Return ( Nil )

//------------------------------------------------------------------------------
/*/{Protheus.doc} at190dGrava

@description Adicionar cor e alterar a fonte nos botões

@author	augusto.albuquerque
@since	29/07/2019
/*/
//------------------------------------------------------------------------------
Static Function ColorButton()
Local cCssCor	:= "QPushButton{margin-top:1px; border-color:#1F739E; font:bold; border-radius:2px; background-color:#1F739E; color:#ffffff; border-style: outset; border-width:1px; }"

Return (cCssCor)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203Def

@description Retorna em forma de Array as definições dos campos
@param cTable, string, define de qual tabela devem ser os campos retornados
@return aRet, array, definição dos campos

@author	diego.bezerra
@since	09/12/2019
/*/
//------------------------------------------------------------------------------
Function At203Def(cTable)
Local aRet 		:= {}
Local nAux 		:= 0
Local cOrdem 	:= "05"
Local nX		:= 0
local nColMarc	:= SuperGetMv("MV_COLMARC",,2)

If cTable == "AA1"
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "CN9_NUMERO", "X3_DESCRIC" )  //"Numero do Contrato"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "CN9_NUMERO", "X3_DESCRIC" ) //"Numero do Contrato"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_NUMERO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN9_NUMERO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "TFJCTR" 
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0008}	// "Número do contrato"
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0009	// "Posto"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0009	 // "Posto"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_POSTO"
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
	aRet[nAux][DEF_LOOKUP] := "T03DTF" //At203Cons("POSTO")
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0010}	// "Código de recursos humanos"
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_FILIAL", "X3_DESCRIC" )  //"Filial do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_FILIAL", "X3_DESCRIC" ) //"Filial do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_FILIAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_FILIAL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| xFilial("AA1")}
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_CODTEC", "X3_DESCRIC" )  //"Codigo do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_CODTEC", "X3_DESCRIC" ) //"Codigo do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_CODTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "AA1" 
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0011} // "Código do atendente cadastrado no 'Gestão de Serviços'"
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_NOMTEC", "X3_DESCRIC" )  //"Nome do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_NOMTEC", "X3_DESCRIC" ) //"Nome do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_NOMTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] :=STR0012 //  "Código do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] :=STR0012 //  "Código do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_CDFUNC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CDFUNC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_FUNCAO", "X3_DESCRIC" )  //"Função do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_FUNCAO", "X3_DESCRIC" ) //"Função do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_FUNCAO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_FUNCAO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "RJ_DESC", "X3_DESCRIC" )  //"Descricao da Funcao"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "RJ_DESC", "X3_DESCRIC" ) //"Descricao da Funcao"
	aRet[nAux][DEF_IDENTIFICADOR] := "RJ_DESC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("RJ_DESC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0013 // "Data Inicial"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0013 // "Data Inicial"
	aRet[nAux][DEF_IDENTIFICADOR] := "DTS_DTINI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_CODEBLOCK_VALID] := {||At203VldDt("DTS_DTINI")}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| dDataBase}
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0014} // "Data inicial do periodo. Baseado na data base do sistema."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0015 // "Data Final"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0015 // "Data Final"
	aRet[nAux][DEF_IDENTIFICADOR] := "DTS_DTFIM"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_CODEBLOCK_VALID] := {||At203VldDt("DTS_DTFIM")}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| dDataBase}
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "10"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0016} // "Data final do periodo. Baseado na database do sistema."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0017 // "Status da agenda"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0017 // "Status da agenda"
	aRet[nAux][DEF_IDENTIFICADOR] := "ABB_STMARC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_INIT] := {||1}
	aRet[nAux][DEF_LISTA_VAL] := {STR0070, STR0071, STR0072, STR0073} //"1=Todas"#"2=Batidas pendentes"#"3=sem marcação no ponto"#"4=com marcação no ponto"
	aRet[nAux][DEF_COMBO_VAL] := {STR0070, STR0071, STR0072, STR0073} //"1=Todas"#"2=Batidas pendentes"#"3=sem marcação no ponto"#"4=com marcação no ponto"
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "11"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0018} // "Indica se apresenta as agendas enviadas ao ponto ou não"

ElseIf cTable == "ABB"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0019 // "Legenda"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0019 //"Legenda"
	aRet[nAux][DEF_IDENTIFICADOR] := "ABB_LEGEND"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "BT"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "BT"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|| AT203Legen("ABB_LEGEND")}
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "BR_VERDE"}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] :=STR0012 //  "Código do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] :=STR0012 //  "Código do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "ABB_CODTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_CODTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := GetSX3Cache( "AA1_NOMTEC", "X3_DESCRIC" )  //"Nome do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := GetSX3Cache( "AA1_NOMTEC", "X3_DESCRIC" ) //"Nome do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "ABB_NOMTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0020}	//"Nome do Atendente"
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0021 // "Data de referência"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0021 // "Data de referência"
	aRet[nAux][DEF_IDENTIFICADOR] := "ABB_DTREF"
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
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0022	//"Dia da Semana"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0022	//"Dia da Semana"
	aRet[nAux][DEF_IDENTIFICADOR] := "ABB_DOW"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 20
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0023 // "Atende"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0023 // "Atende"
	aRet[nAux][DEF_IDENTIFICADOR] := "ABB_ATENDE"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_ATENDE")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := "Chegou"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "Chegou"
	aRet[nAux][DEF_IDENTIFICADOR] := "ABB_CHEGOU"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_CHEGOU")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	
	For nX := 1 to nColMarc
		
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		cOrdem := Soma1(cOrdem)
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0024+cValToChar(nX) // "Entrada "
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0024+cValToChar(nX) // "Entrada "
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_HRCHIN"+cValToChar(nX)
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRINI")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := "99:99"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		cOrdem := Soma1(cOrdem)
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0025+cValToChar(nX) // "Saida "
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0025+cValToChar(nX) // "Saida "
		aRet[nAux][DEF_IDENTIFICADOR] := "ABB_HRCOUT"+cValToChar(nX)
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRINI")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := "99:99"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		
	Next nX
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	cOrdem := Soma1(cOrdem)
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0026 // "Diferença"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0026 // "Diferença"
	aRet[nAux][DEF_IDENTIFICADOR] := "ABB_DIF"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 12
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	cOrdem := Soma1(cOrdem)
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := "ABB TOTAL"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "ABB TOTAL"
	aRet[nAux][DEF_IDENTIFICADOR] := "ABB_HRTOT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRTOT")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	
ElseIf cTable == "TOT"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0027 // "Total de Hrs. Planejadas"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0027 // "Total de Hrs. Planejadas"
	aRet[nAux][DEF_IDENTIFICADOR] := "TOT_HRPLAN"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 12
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0028 // "Total de Hrs. Apontadas"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0028 // "Total de Hrs. Apontadas"
	aRet[nAux][DEF_IDENTIFICADOR] := "TOT_HRAPO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 12
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0029 // "Dif. Tot. de Hrs"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0029 // "Dif. Tot. de Hrs"
	aRet[nAux][DEF_IDENTIFICADOR] := "TOT_DIFHR"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 12
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	
EndIf

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190dCons

Construção da consulta especifica

@author diego.bezerra
@since 10/12/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At203Cons(cTipo)

Local lRet		:= .F.
Local oColumn 	:= NIL
Local oModel 	:= FwModelActive()
Local oMdlAA1	:= Nil
Local aSeek		:= {}
Local aIndex	:= {}
Local nSuperior	:= 0
Local nEsquerda := 0
Local nInferior := 0
Local nDireita	:= 0
Local cSpcCTR 	:= Space(TamSx3("CN9_NUMERO")[1])
Local cContrat	:= ""
Local cTitle	:= ""
Local cAls      := GetNextAlias()

cRet203F3 := ""
	
	oMdlAA1 := oModel:GetModel("AA1MASTER")
	cContrat := oMdlAA1:GetValue("AA1_NUMERO")
	cTitle := "Posto de trabalho"	// "Posto de Trabalho"
	
	Aadd( aSeek, { STR0034 , {{"","C",TamSX3("TFF_COD")[1],0,STR0034,,}}})		 // "Código do Posto"
	Aadd( aSeek, { STR0035, {{"","C",TamSX3("B1_COD")[1],0,STR0035,,}}}) // "Código do Produto"
	Aadd( aSeek, { STR0036, {{"","C",TamSX3("B1_DESC")[1],0,STR0036,,}}})		// "Descrição"
	Aadd( aSeek, { STR0037, {{"","C",TamSX3("TFF_CONTRT")[1],0,STR0037,,}}})	 // "Contrato"
	Aadd( aSeek, { STR0038, {{"","C",TamSX3("ABS_DESCRI")[1],0,STR0038,,}}})	 // "Descrição do Posto"
	
	Aadd( aIndex, "TFF_COD" )
	Aadd( aIndex, "B1_COD" )
	Aadd( aIndex, "B1_DESC" )
	Aadd( aIndex, "TFF_CONTRT" )
	Aadd( aIndex, "ABS_DESCRI" )
	Aadd( aIndex, "TFF_FILIAL")  // adicionado para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último
	
	cQry := " SELECT TFF.TFF_FILIAL, TFF.TFF_COD, SB1.B1_COD, SB1.B1_DESC, TFF.TFF_CONTRT, ABS.ABS_DESCRI, TFF.TFF_PERINI, TFF.TFF_PERFIM, TFF.TFF_QTDVEN "
	cQry += " FROM " + RetSqlName("TFF") + " TFF "
	cQry += " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB1.B1_COD = TFF.TFF_PRODUT AND "
	cQry += " SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ = ' ' "
	cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL "
	cQry += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
	cQry += " AND TFL.D_E_L_E_T_ = ' ' "
	cQry += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
	cQry += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
	cQry += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
	cQry += " AND TFJ.D_E_L_E_T_ = ' ' "
	cQry += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
	cQry += " AND TFJ.TFJ_STATUS = '1' "
	cQry += " AND TFJ.TFJ_CONTRT <> '" + cSpcCTR + "' "
	If !EMPTY(cContrat)
		cQry += " AND TFJ.TFJ_CONTRT = '" + cContrat + "' "
	EndIf
	cQry += " INNER JOIN " + RetSqlName( "ABS" ) + " ABS ON TFL.TFL_LOCAL = ABS.ABS_LOCAL AND "
	cQry += " ABS.ABS_FILIAL = '" + xFilial("ABS") + "' AND ABS.D_E_L_E_T_ = ' ' "
	cQry += " WHERE TFF.TFF_FILIAL = '" +  xFilial('TFF') + "' AND "
	cQry += " TFF.D_E_L_E_T_ = ' ' "

cQry := ChangeQuery(cQry)

	nSuperior := 0
	nEsquerda := 0

	nInferior := GetScreenRes()[2] * 0.6
	nDireita  := GetScreenRes()[1] * 0.65

	DEFINE MSDIALOG oDlgEscTela TITLE cTitle FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL

	oBrowse := FWFormBrowse():New()
	oBrowse:SetOwner(oDlgEscTela)
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetAlias(cAls)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetQuery(cQry)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetDescription(cTitle)
	oBrowse:SetMenuDef("")
	oBrowse:DisableDetails()
	
		oBrowse:SetDoubleClick({ || cRet203F3 := (oBrowse:Alias())->TFF_COD, lRet := .T. ,oDlgEscTela:End()})
		oBrowse:AddButton( OemTOAnsi(STR0039), {|| cRet203F3  := (oBrowse:Alias())->TFF_COD, lRet := .T., oDlgEscTela:End() } ,, 2 )	// "Confirmar"

	oBrowse:AddButton( OemTOAnsi(STR0040),  {|| cRet203F3  := "", oDlgEscTela:End() } ,, 2 ) // "Cancelar"
	oBrowse:DisableDetails()
	
		ADD COLUMN oColumn DATA { ||  TFF_COD  		} TITLE STR0034 SIZE TamSX3("TFF_COD")[1] OF oBrowse	// "Código do Posto"
		ADD COLUMN oColumn DATA { ||  STOD(TFF_PERINI )} TITLE STR0042 SIZE TamSX3("TFF_PERINI")[1] OF oBrowse	 // "Período Inicial"
		ADD COLUMN oColumn DATA { ||  STOD(TFF_PERFIM )} TITLE STR0043 SIZE TamSX3("TFF_PERFIM")[1] OF oBrowse // "Período Final"
		ADD COLUMN oColumn DATA { ||  TFF_QTDVEN  	} TITLE GetSX3Cache( "TFF_QTDVEN", "X3_DESCRIC" ) SIZE TamSX3("TFF_QTDVEN")[1] OF oBrowse
		ADD COLUMN oColumn DATA { ||  B1_COD 		} TITLE STR0035 SIZE TamSX3("B1_COD")[1] OF oBrowse		 // "Código do Produto"
		ADD COLUMN oColumn DATA { ||  B1_DESC  		} TITLE STR0036 SIZE TamSX3("B1_DESC")[1] OF oBrowse	// "Descrição"
		ADD COLUMN oColumn DATA { ||  TFF_CONTRT  	} TITLE STR0037 SIZE TamSX3("TFF_CONTRT")[1] OF oBrowse	 // "Contrato"
		ADD COLUMN oColumn DATA { ||  ABS_DESCRI  	} TITLE STR0038 SIZE TamSX3("ABS_DESCRI")[1] OF oBrowse	// "Descrição do Posto"
	
	oBrowse:Activate()

	ACTIVATE MSDIALOG oDlgEscTela CENTERED

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At203dRF3()

Retorno da consulta especifica

@author diego.bezerra
@since 10/12/2019
/*/
//------------------------------------------------------------------
Function At203RF3()
	
Return cRet203F3

Static Function PreLinAA1(oMdlAA1,cAction,cField,xValue)

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At230ALoad
@description  Barra de Processamento pois o carregamento pode demorar.
@return lRet
@author Augusto Albuquerque
@since  16/12/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At230ALoad( oPanel )
Local lRet


FwMsgRun(Nil,{|| LoadABB()}, Nil, STR0006) // "Processando..."
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadABB
@description  Load do Grid com as agendas e contagens das horas. 
@return .T.
@author Augusto Albuquerque
@since  16/12/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function LoadABB()
Local cQuery 		:= ""
Local cAliasQry		:= GetNextAlias()
Local oModel	 	:= FwModelActive()
Local oView 		:= FwViewActive()
Local oMdlAA1		:= oModel:GetModel("AA1MASTER")
Local oMdlABB		:= oModel:GetModel("ABBDETAIL")
Local oMdlTOT		:= oModel:GetModel("FLDTOTAIS")
Local dDatIni		:= oMdlAA1:GetValue("DTS_DTINI")
Local dDatFim		:= oMdlAA1:GetValue("DTS_DTFIM")
Local cContrato 	:= oMdlAA1:GetValue("AA1_NUMERO")
Local cPosto		:= AllTrim(oMdlAA1:GetValue("AA1_POSTO"))
Local cCodTec		:= AllTrim(oMdlAA1:GetValue("AA1_CODTEC"))
Local cStatus		:= AllTrim(oMdlAA1:GetValue("ABB_STMARC"))
Local cCodAtend		:= ""
Local nLinha		:= 1
Local cDatRef		:= ""
Local nBatidas		:= 1
Local lPrimeira		:= .T.
Local lMuda			:= .F.
Local lEntrou		:= .T.
Local nTotHrPla		:= 0
Local nTotHrRea		:= 0
Local nTotHora		:= 0
Local nHrCh			:= 0
Local lHora			:= .F.
Local nTotPlan		:= 0
Local nTotRea		:= 0
Local nlen			:= 0
local nColMarc		:= SuperGetMv("MV_COLMARC",,2)
Local aAgendas		:= {}
Local nX

oMdlABB:SetNoInsertLine(.F.)
oMdlABB:SetNoDeleteLine(.F.)
oMdlTOT:LoadValue("TOT_HRPLAN"	, "" )
oMdlTOT:LoadValue("TOT_HRAPO"	, "" )
oMdlTOT:LoadValue("TOT_DIFHR"	, "" )

oMdlABB:ClearData()
oMdlABB:InitLine()

If !Empty(dDatIni) .AND. !Empty(dDatFim)
	cContrato := AT203dLimp(cContrato)
	cPosto := AT203dLimp(cPosto)
	cCodTec := AT203dLimp(cCodTec)

	cQuery := " SELECT ABB.ABB_HRCHIN, ABB.ABB_HRCOUT, TDV.TDV_DTREF, ABB.ABB_HRTOT, ABB.ABB_CODTEC, AA1.AA1_NOMTEC, "
	cQuery += " ABB.ABB_CHEGOU, ABB.ABB_HRINI, ABB.ABB_HRFIM, ABB.ABB_ATENDE, ABB.ABB_MANUT, ABB.ABB_CODIGO, ABB.R_E_C_N_O_ ABBREC " 
	cQuery += " FROM " + RetSqlName("ABB") + " ABB "
	cQuery += " INNER JOIN " + RetSqlName( "TDV" ) + " TDV "
	cQuery += " ON TDV.TDV_FILIAL = '" + xFilial("TDV") + "' AND TDV.D_E_L_E_T_ = ' ' "
	cQuery += " AND TDV.TDV_CODABB = ABB.ABB_CODIGO "
	cQuery += " INNER JOIN " + RetSqlName( "ABQ" ) + " ABQ "
	cQuery += " ON ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "' AND ABQ.D_E_L_E_T_ = ' ' "
	cQuery += " AND ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL "
	cQuery += " INNER JOIN " + RetSqlName( "TFJ" ) + " TFJ "
	cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND TFJ.D_E_L_E_T_ = ' ' "
	cQuery += " AND TFJ.TFJ_CONTRT = ABQ.ABQ_CONTRT AND TFJ.TFJ_STATUS = '1' "
	cQuery += " INNER JOIN " + RetSqlName( "TFF" ) + " TFF "
	cQuery += " ON TFF.TFF_FILIAL = ABQ.ABQ_FILTFF AND TFF.D_E_L_E_T_ = ' ' "
	cQuery += " AND TFF.TFF_COD = ABQ.ABQ_CODTFF "
	cQuery += " INNER JOIN " + RetSqlName( "AA1" ) + " AA1 "
	cQuery += " ON AA1.AA1_FILIAL = '" + xFilial("AA1") + "' AND AA1.D_E_L_E_T_ = ' ' "
	cQuery += " AND AA1.AA1_CODTEC = ABB.ABB_CODTEC "
	cQuery += " WHERE ABB.D_E_L_E_T_ = ' ' AND ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
	cQuery += " AND TDV.TDV_DTREF BETWEEN '" + DToS(dDatIni) + "' AND '" + DToS(dDatFim) + "' "
	If !Empty(cContrato)
		cQuery += " AND TFJ.TFJ_CONTRT = '" + cContrato + "' "
	EndIf
	If !Empty(cPosto)
		cQuery += " AND TFF.TFF_COD = '" + cPosto + "' "
	EndIf
	If !Empty(cCodTec)
		cQuery += " AND ABB.ABB_CODTEC = '" + cCodTec + "' "
	EndIf
	
	cQuery += " ORDER BY ABB.ABB_CODTEC, TDV.TDV_DTREF, ABB.ABB_DTINI, ABB.ABB_HRINI "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	If !(cAliasQry)->(EOF())
		lHora := .T.
	EndIf
	
	aAgendas := AT203Agend( cAliasQry, cStatus )
	(cAliasQry)->(dbCloseArea())
	
	If oMdlABB:GetMaxLines() < Len(aAgendas)
		oMdlABB:SetMaxLines(Len(aAgendas))
	EndIf
	
	oMdlABB:ClearData()
	oMdlABB:InitLine()
	If !Empty(aAgendas)
		nLen := Len(aAgendas)
		For nX := 1 To nLen
			lEntrou := .F.
			If aAgendas[nX][1] <> cDatRef .OR. cCodAtend <> aAgendas[nX][2]
				lEntrou := .T.
				If !oMdlABB:IsEmpty()
					If !lPrimeira
						If nBatidas == 1 .AND. lMuda 
							oMdlABB:LoadValue("ABB_LEGEND","BR_PRETO")
							nHrCh := 0
						EndIf
						nTotRea := SomaHoras( nTotHrRea, nTotRea)
						nTotPlan := SomaHoras( nTotHrPla, nTotPlan)
						nTotHora := SubHoras( nTotHrPla, nTotHrRea )
						cHora	:= TecConvHr( ABS(nTotHora) )
						If nTotHora > 0
							cHora := " - " + cHora
						EndIf
						oMdlABB:LoadValue("ABB_DIF", cHora)
						oMdlABB:LoadValue("ABB_HRTOT", TecConvHr( ABS(nTotHrPla) ) )
					EndIf
					nLinha := oMdlABB:AddLine()
					lMuda := .F.
					nBatidas := 1
					nTotHrRea := 0
					nTotHrPla := 0
				EndIf
				oMdlABB:GoLine(nLinha)
				oMdlABB:LoadValue("ABB_DTREF", STOD(aAgendas[nX][1]))
				oMdlABB:LoadValue("ABB_CODTEC", aAgendas[nX][2])
				oMdlABB:LoadValue("ABB_NOMTEC", aAgendas[nX][3])	
				oMdlABB:LoadValue("ABB_DOW", TECCdow(DOW(STOD(aAgendas[nX][1]))))
				oMdlABB:LoadValue("ABB_HRCHIN" + cValToChar(nBatidas), AllTrim(aAgendas[nX][4]))
				oMdlABB:LoadValue("ABB_HRCOUT" + cValToChar(nBatidas), AllTrim(aAgendas[nX][5]))
				If Empty(aAgendas[nX][4]) .OR. Empty(aAgendas[nX][5])
					If Empty(aAgendas[nX][4]) .AND. !Empty(aAgendas[nX][5])
						If aAgendas[nX][8] == "1"
							oMdlABB:LoadValue("ABB_HRCHIN" + cValToChar(nBatidas), AllTrim(aAgendas[nX][6]))
							nHrCh := Val(STRTRAN(ElapTime( aAgendas[nX][6]+":00" , AllTrim(aAgendas[nX][5])+":00"), ":","."))
						Else
							oMdlABB:LoadValue("ABB_LEGEND","BR_VERMELHO")
							nHrCh := 0
						EndIf
					ElseIf !Empty(aAgendas[nX][4]) .AND. Empty(aAgendas[nX][5])
						If aAgendas[nX][8] == "1"
							oMdlABB:LoadValue("ABB_HRCOUT" + cValToChar(nBatidas), AllTrim(aAgendas[nX][7]))
							nHrCh := Val(STRTRAN(ElapTime( AllTrim(aAgendas[nX][4])+":00" , aAgendas[nX][7]+":00"), ":","."))
						Else
							oMdlABB:LoadValue("ABB_LEGEND","BR_VERMELHO")
							nHrCh := 0
						EndIf
					Else
						If aAgendas[nX][8] == "1"
							oMdlABB:LoadValue("ABB_HRCHIN" + cValToChar(nBatidas), AllTrim(aAgendas[nX][6]))
							oMdlABB:LoadValue("ABB_HRCOUT" + cValToChar(nBatidas), AllTrim(aAgendas[nX][7]))
							nHrCh := Val(STRTRAN(ElapTime( AllTrim(aAgendas[nX][6])+":00" , aAgendas[nX][7]+":00"), ":","."))
						Else
							oMdlABB:LoadValue("ABB_LEGEND","BR_VERMELHO")
							lMuda := .T.
							nHrCh := 0
						EndIf
					EndIf
				Else
					If aAgendas[nX][10] == "N"
						oMdlABB:LoadValue("ABB_HRCHIN" + cValToChar(nBatidas), "")
						oMdlABB:LoadValue("ABB_HRCOUT" + cValToChar(nBatidas), "")
						nHrCh := 0
						oMdlABB:LoadValue("ABB_LEGEND","BR_PRETO")
					Else
						nHrCh := Val(STRTRAN(ElapTime( AllTrim(aAgendas[nX][4])+":00" , AllTrim(aAgendas[nX][5])+":00"), ":","."))
						oMdlABB:LoadValue("ABB_LEGEND","BR_VERDE")
					EndIf
				EndIf	
			ElseIf nBatidas < nColMarc
				lEntrou := .T.
				nBatidas ++
				oMdlABB:LoadValue("ABB_HRCHIN" + cValToChar(nBatidas), AllTrim(aAgendas[nX][4]))
				oMdlABB:LoadValue("ABB_HRCOUT" + cValToChar(nBatidas), AllTrim(aAgendas[nX][5]))
				If Empty(aAgendas[nX][4]) .OR. Empty(aAgendas[nX][5]) 
					If Empty(aAgendas[nX][4]) .AND. !Empty(aAgendas[nX][5])
						If aAgendas[nX][8] == "1"
							oMdlABB:LoadValue("ABB_HRCHIN" + cValToChar(nBatidas), AllTrim(aAgendas[nX][6]))
							nHrCh := Val(STRTRAN(ElapTime( aAgendas[nX][6]+":00" , AllTrim(aAgendas[nX][7])+":00"), ":","."))
						Else
							oMdlABB:LoadValue("ABB_LEGEND","BR_VERMELHO")
							nHrCh := 0
						EndIf
					ElseIf !Empty(aAgendas[nX][4]) .AND. Empty(aAgendas[nX][5])
						If aAgendas[nX][8] == "1"
							oMdlABB:LoadValue("ABB_HRCOUT" + cValToChar(nBatidas), AllTrim(aAgendas[nX][7]))
							nHrCh := Val(STRTRAN(ElapTime( AllTrim(aAgendas[nX][4])+":00" , aAgendas[nX][7]+":00"), ":","."))
						Else
							oMdlABB:LoadValue("ABB_LEGEND","BR_VERMELHO")
							nHrCh := 0
						EndIf
					Else
						If aAgendas[nX][8] == "1"
							oMdlABB:LoadValue("ABB_HRCHIN" + cValToChar(nBatidas), AllTrim(aAgendas[nX][6]))
							oMdlABB:LoadValue("ABB_HRCOUT" + cValToChar(nBatidas), AllTrim(aAgendas[nX][7]))
							nHrCh := Val(STRTRAN(ElapTime( AllTrim(aAgendas[nX][6])+":00" , aAgendas[nX][7]+":00"), ":",".")) //Val(STRTRAN(Right(aAgendas[nX][9], 5), ":","."))
						ElseIf lMuda
							oMdlABB:LoadValue("ABB_LEGEND","BR_PRETO")
							nHrCh := 0
						Else
							oMdlABB:LoadValue("ABB_LEGEND","BR_VERMELHO")
							lMuda := .T.
							nHrCh := 0
						EndIf
					EndIf
				Else
					If aAgendas[nX][10] == "N"
						oMdlABB:LoadValue("ABB_HRCHIN" + cValToChar(nBatidas), "")
						oMdlABB:LoadValue("ABB_HRCOUT" + cValToChar(nBatidas), "")
						nHrCh := 0
						oMdlABB:LoadValue("ABB_LEGEND","BR_PRETO")
					Else
						nHrCh := Val(STRTRAN(ElapTime( AllTrim(aAgendas[nX][4])+":00" , AllTrim(aAgendas[nX][5])+":00"), ":","."))
						If lMuda
							oMdlABB:LoadValue("ABB_LEGEND","BR_VERMELHO")
						Else
							oMdlABB:LoadValue("ABB_LEGEND","BR_VERDE")
						EndIf
					EndIf
				EndIf
			EndIf
			If lEntrou
				nTotHrRea := SomaHoras( nTotHrRea, ABS( nHrCh ) )
				nTotHrPla := SomaHoras( nTotHrPla, Val(STRTRAN(ElapTime( AllTrim(aAgendas[nX][6])+":00" , aAgendas[nX][7]+":00"), ":",".")) )
				cCodAtend	:= aAgendas[nX][2]
				cDatRef		:= aAgendas[nX][1]
				lPrimeira := .F.
			EndIf
			If nX == nLen
				oMdlABB:LoadValue("ABB_HRTOT", cValToChar(nTotHrPla))
				nTotRea := SomaHoras( nTotHrRea, nTotRea )
				nTotPlan := SomaHoras( nTotHrPla, nTotPlan )
				nTotHora := SubHoras( nTotHrPla, nTotHrRea )
				cHora	:= TecConvHr( ABS(nTotHora) )
				If nTotHora > 0
					cHora := " - " + cHora
				EndIf
				oMdlABB:LoadValue("ABB_DIF", cHora)
				If nTotRea > 0 .OR. nTotPlan > 0
					nTotRea := TecConvHr( nTotRea )
					nTotPlan := TecConvHr( nTotPlan )
					oMdlTOT:LoadValue("TOT_HRPLAN"	, nTotPlan )
					oMdlTOT:LoadValue("TOT_HRAPO"	, nTotRea )
					nTotPlan := SubHoras( Val(AllTrim(STRTRAN(nTotPlan, ":","."))), Val(AllTrim(STRTRAN(nTotRea, ":","."))) )
					cHora := TecConvHr( ABS(nTotPlan) )
					If nTotPlan > 0
						cHora := " - " + cHora 
					EndIf
					oMdlTOT:LoadValue("TOT_DIFHR"	, cHora )
				EndIf
			EndIf
		Next nX
		
		oMdlABB:GoLine(1)
	Else
		If !IsBlind()
			Help(,,"AT203NODATA",, STR0090 ,1,0) //"Não há dados para serem exibidos."
		EndIf
	EndIf
EndIf

oMdlABB:SetNoInsertLine(.T.)
oMdlABB:SetNoDeleteLine(.T.)
If !IsBlind()
	oView:Refresh('DETAIL_ABB')
EndIf

//Alimenta array statico para uso no ajuste manual
Set203ALimp()
Set203AGrid(aAgendas)

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT203Agend
@description Preenchumento do array auxiliar que será usado para load do grid
@return aRet - Array com as informações das agendas
@author Augusto Albuquerque
@since  16/12/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AT203Agend ( cAliasQry, cStatus )
Local aRet		:= {}
Local cHrFim	:= ""
Local cCodAtend	:= ""
Local cHoraIni	:= ""
Local cHoraFim	:= ""
Local cDatRef	:= ""
Local aAux		:= {}
Local lEnvia	:= .F.
Local lMuda		:= .F.

If cStatus == "1" 
	While !(cAliasQry)->(EOF())
		If (cAliasQry)->(ABB_MANUT) == "1"
			HoraManut( @cHoraIni, @cHoraFim, (cAliasQry)->(ABB_CODIGO), (cAliasQry)->(ABB_HRINI), (cAliasQry)->(ABB_HRFIM) )
		Else
			cHoraIni := (cAliasQry)->(ABB_HRINI)
			cHoraFIm := (cAliasQry)->(ABB_HRFIM)
		EndIf
		AADD(aRet, { (cAliasQry)->(TDV_DTREF),;		
					(cAliasQry)->(ABB_CODTEC),;	
					(cAliasQry)->(AA1_NOMTEC),;	
					(cAliasQry)->(ABB_HRCHIN),;
					(cAliasQry)->(ABB_HRCOUT),;
					cHoraIni,;
					cHoraFIm,;
					(cAliasQry)->(ABB_ATENDE),;
					(cAliasQry)->(ABB_HRTOT),;
					(cAliasQry)->(ABB_CHEGOU),;
					(cAliasQry)->(ABBREC)})
		(cAliasQry)->(dbSkip())	
	EndDo
ElseIf cStatus == "2"
	While !(cAliasQry)->(EOF())
		If (cAliasQry)->(ABB_MANUT) == "1"
			HoraManut( @cHoraIni, @cHoraFim, (cAliasQry)->(ABB_CODIGO), (cAliasQry)->(ABB_HRINI), (cAliasQry)->(ABB_HRFIM) )
		Else
			cHoraIni := (cAliasQry)->(ABB_HRINI)
			cHoraFIm := (cAliasQry)->(ABB_HRFIM)
		EndIf
		If (cAliasQry)->(TDV_DTREF) <> cDatRef .OR. cCodAtend <> (cAliasQry)->(ABB_CODTEC)
			cHrFim := (cAliasQry)->(ABB_HRCOUT)		
			If lEnvia
				EnviaABB( aAux, @aRet )
				aAux := {}
				lEnvia := .F.
			Else
				aAux := {}
			EndIf
			If ( Empty( (cAliasQry)->(ABB_HRCHIN) ) )
				lMuda := .F.
			Else 
				nTotHrPla := 0
				AADD(aAux, { (cAliasQry)->(TDV_DTREF),;		
							 (cAliasQry)->(ABB_CODTEC),;	
							 (cAliasQry)->(AA1_NOMTEC),;	
							 (cAliasQry)->(ABB_HRCHIN),;
							 (cAliasQry)->(ABB_HRCOUT),;
							 cHoraIni,;
							 cHoraFIm,;
							 (cAliasQry)->(ABB_ATENDE),;
							 (cAliasQry)->(ABB_HRTOT),;
							 (cAliasQry)->(ABB_CHEGOU),;
							 (cAliasQry)->(ABBREC)})
				lMuda := .T.
			EndIf
		Else
			If lMuda 
				If ( Empty( cHrFim ) .OR. ( Empty( (cAliasQry)->(ABB_HRCHIN) ) .OR. Empty( (cAliasQry)->(ABB_HRCOUT) ) ) ) .OR. lEnvia
					AADD(aAux, { (cAliasQry)->(TDV_DTREF),;		
								 (cAliasQry)->(ABB_CODTEC),;	
								 (cAliasQry)->(AA1_NOMTEC),;	
								 (cAliasQry)->(ABB_HRCHIN),;
								 (cAliasQry)->(ABB_HRCOUT),;
								 cHoraIni,;
								 cHoraFIm,;
								 (cAliasQry)->(ABB_ATENDE),;
								 (cAliasQry)->(ABB_HRTOT),;
								 (cAliasQry)->(ABB_CHEGOU),;
								 (cAliasQry)->(ABBREC)})
					lEnvia := .T.
				EndIf
			EndIf
		EndIf
		cCodAtend	:= (cAliasQry)->(ABB_CODTEC)
		cDatRef		:= (cAliasQry)->(TDV_DTREF)
		(cAliasQry)->(dbSkip())
	EndDo
ElseIf cStatus == "3"
	While !(cAliasQry)->(EOF())
		If (cAliasQry)->(ABB_MANUT) == "1"
			HoraManut( @cHoraIni, @cHoraFim, (cAliasQry)->(ABB_CODIGO), (cAliasQry)->(ABB_HRINI), (cAliasQry)->(ABB_HRFIM) )
		Else
			cHoraIni := (cAliasQry)->(ABB_HRINI)
			cHoraFIm := (cAliasQry)->(ABB_HRFIM)
		EndIf
		If (cAliasQry)->(TDV_DTREF) <> cDatRef .OR. cCodAtend <> (cAliasQry)->(ABB_CODTEC)
			If lEnvia
				EnviaABB( aAux, @aRet )
				aAux := {}
				lEnvia := .F.
			Else
				aAux := {}
			EndIf
			If (Empty( (cAliasQry)->(ABB_HRCHIN) ) .AND. (cAliasQry)->(ABB_ATENDE) == "2") .OR.;
				(!Empty((cAliasQry)->(ABB_HRCHIN)) .AND.(cAliasQry)->(ABB_CHEGOU) == "N")
				AADD(aAux, { (cAliasQry)->(TDV_DTREF),;		
							 (cAliasQry)->(ABB_CODTEC),;	
							 (cAliasQry)->(AA1_NOMTEC),;	
							 (cAliasQry)->(ABB_HRCHIN),;
							 (cAliasQry)->(ABB_HRCOUT),;
							 cHoraIni,;
							 cHoraFIm,;
							 (cAliasQry)->(ABB_ATENDE),;
							 (cAliasQry)->(ABB_HRTOT),;
							 (cAliasQry)->(ABB_CHEGOU),;
							 (cAliasQry)->(ABBREC)})
				lEnvia := .T.
			Else
				lEnvia := .F.
			EndIf
		Else
			If lEnvia
				AADD(aAux, { (cAliasQry)->(TDV_DTREF),;		
							 (cAliasQry)->(ABB_CODTEC),;	
							 (cAliasQry)->(AA1_NOMTEC),;	
							 (cAliasQry)->(ABB_HRCHIN),;
							 (cAliasQry)->(ABB_HRCOUT),;
							 cHoraIni,;
							 cHoraFIm,;
							 (cAliasQry)->(ABB_ATENDE),;
							 (cAliasQry)->(ABB_HRTOT),;
							 (cAliasQry)->(ABB_CHEGOU),;
							 (cAliasQry)->(ABBREC)})
			EndIf
		EndIf
		cCodAtend	:= (cAliasQry)->(ABB_CODTEC)
		cDatRef		:= (cAliasQry)->(TDV_DTREF)
		(cAliasQry)->(dbSkip())
	EndDo
Else
	While !(cAliasQry)->(EOF())
		If (cAliasQry)->(ABB_MANUT) == "1"
			HoraManut( @cHoraIni, @cHoraFim, (cAliasQry)->(ABB_CODIGO), (cAliasQry)->(ABB_HRINI), (cAliasQry)->(ABB_HRFIM) )
		Else
			cHoraIni := (cAliasQry)->(ABB_HRINI)
			cHoraFIm := (cAliasQry)->(ABB_HRFIM)
		EndIf
		If (cAliasQry)->(TDV_DTREF) <> cDatRef .OR. cCodAtend <> (cAliasQry)->(ABB_CODTEC)	
			If lEnvia
				EnviaABB( aAux, @aRet )
				aAux := {}
				lEnvia := .F.
			Else
				aAux := {}
			EndIf
			If !(Empty( (cAliasQry)->(ABB_HRCHIN)) .OR. Empty( (cAliasQry)->(ABB_HRCOUT))) .OR. (cAliasQry)->(ABB_ATENDE) == "1"
				AADD(aAux, { (cAliasQry)->(TDV_DTREF),;		
							 (cAliasQry)->(ABB_CODTEC),;	
							 (cAliasQry)->(AA1_NOMTEC),;	
							 (cAliasQry)->(ABB_HRCHIN),;
							 (cAliasQry)->(ABB_HRCOUT),;
							 cHoraIni,;
							 cHoraFIm,;
							 (cAliasQry)->(ABB_ATENDE),;
							 (cAliasQry)->(ABB_HRTOT),;
							 (cAliasQry)->(ABB_CHEGOU),;
							 (cAliasQry)->(ABBREC)})
				lEnvia := .T.
			EndIf
		Else
			If lEnvia .AND. (!(Empty( (cAliasQry)->(ABB_HRCHIN) ) .OR. Empty( (cAliasQry)->(ABB_HRCOUT))) .OR. (cAliasQry)->(ABB_ATENDE) == "1" ) .AND. (cAliasQry)->(ABB_CHEGOU) = "S"
				AADD(aAux, { (cAliasQry)->(TDV_DTREF),;		
							 (cAliasQry)->(ABB_CODTEC),;	
							 (cAliasQry)->(AA1_NOMTEC),;	
							 (cAliasQry)->(ABB_HRCHIN),;
							 (cAliasQry)->(ABB_HRCOUT),;
							 cHoraIni,;
							 cHoraFIm,;
							 (cAliasQry)->(ABB_ATENDE),;
							 (cAliasQry)->(ABB_HRTOT),;
							 (cAliasQry)->(ABB_CHEGOU),;
							 (cAliasQry)->(ABBREC)})
			Else
				lEnvia := .F.
			EndIf
		EndIf
		cCodAtend	:= (cAliasQry)->(ABB_CODTEC)
		cDatRef		:= (cAliasQry)->(TDV_DTREF)
		(cAliasQry)->(dbSkip())
	EndDo
EndIf

If lEnvia	
	EnviaABB( aAux, @aRet )
EndIf

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EnviaABB
@description Preenchumento do array que será usado para load do grid
@return .T.
@author Augusto Albuquerque
@since  16/12/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function EnviaABB( aAux, aRet )
Local nX
For nX := 1 To Len(aAux)
	AADD(aRet, {aAux[nX][1],;
				aAux[nX][2],;
				aAux[nX][3],;
				aAux[nX][4],;
				aAux[nX][5],;
				aAux[nX][6],;
				aAux[nX][7],;
				aAux[nX][8],;
				aAux[nX][9],;
				aAux[nX][10],;
				aAux[nX][11]})
Next nX

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} HoraManut
@description Verificação da primeira ABR.
@return .T.
@author Augusto Albuquerque
@since  16/12/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function HoraManut( cHoraIni, cHoraFim, cCodABB, cHrIniABB, cHrFimABB )
Local aSave 	:= GetArea()
Local cAreaTmp 	:= GetNextAlias()

BeginSql Alias cAreaTmp

	SELECT ABR.ABR_HRINIA, ABR.ABR_HRFIMA, ABN.ABN_TIPO
	  FROM %table:ABR% ABR
	 INNER JOIN %table:ABN% ABN
	 	ON ABN.ABN_FILIAL = %xFilial:ABN%
	 	AND ABR.%NotDel%
	 	AND ABR.ABR_MOTIVO = ABN_CODIGO
	 WHERE ABR.%NotDel%
	   AND ABR.ABR_FILIAL = %xFilial:ABR%
	   AND ABR_AGENDA = %exp:cCodABB%
	 ORDER BY ABR.ABR_MANUT
	 
EndSql

If (cAreaTmp)->( !EOF() ) .AND. (cAreaTmp)->(ABN_TIPO) <> "04"
	cHoraIni := (cAreaTmp)->(ABR_HRINIA)
	cHoraFim := (cAreaTmp)->(ABR_HRFIMA)
Else
	cHoraIni := cHrIniABB
	cHoraFim := cHrFimABB
EndIf

(cAreaTmp)->(dbCloseArea())

RestArea( aSave )

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT203Legen
@description Legenda para o grid de agendas
@return .T.
@author Augusto Albuquerque
@since  16/12/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AT203Legen( cCampo, aLegenda )
Local oLegABB 	:= FwLegend():New()
Local nLen		:= 0

Default cCampo   := ""
Default aLegenda := {}

If !Empty(cCampo)
	oLegABB:Add( ""		, "BR_VERDE"	, STR0044 ) // "Batidas com Conformidades"
	oLegABB:Add( ""		, "BR_VERMELHO"	, STR0046 ) // "Batidas Pendentes"
	oLegABB:Add( ""		, "BR_PRETO"	, STR0045 ) // "Batidas com Inconformidades"
	oLegABB:View()
	DelClassIntf()
Else
	aAdd(aLegenda, {"ABB_LEGEND",{}} )
	nLen := len(aLegenda) 
	aAdd(aLegenda[nLen][2], {"BR_VERDE"	 	,STR0044 } ) // "Batidas com Conformidades"
	aAdd(aLegenda[nlen][2], {"BR_VERMELHO"	,STR0046 } ) // "Batidas Pendentes"
	aAdd(aLegenda[nLen][2], {"BR_PRETO"	 	,STR0045 } ) // "Batidas com Inconformidades"
EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidSXB()

Realiza a validação das consultas.

aVldSXB[nX,1] = Consulta
aVldSXB[nX,2] = Tipo da consulta
aVldSXB[nX,3] = Descrição
aVldSXB[nX,4] = Tabela
aVldSXB[nX,5] = Expressão
aVldSXB[nX,6] = Retorno

@author diego.bezerra
@since 11/12/2019
/*/
//------------------------------------------------------------------------------
Static Function ValidSXB()
Local lRet 		:= .T.
Local nX		:= 0
Local cMsgSXB	:= ""

Local aVldSXB	:= {{"T03DTF", STR0047, STR0049,"TFF",'At203Cons("POSTO")',"At203RF3()"}}	

DbSelectArea("SXB")
SXB->(DbSetOrder(1))

For nX := 1 To Len(aVldSXB)
	If !SXB->(DbSeek(aVldSXB[nX,1]))

		If Empty(cMsgSXB)
			cMsgSXB := STR0051 + "(SXB):"+CRLF+CRLF  // "Realize a inclusão da Consulta Padrão - "
		Endif

		cMsgSXB += STR0052 + aVldSXB[nX,1]+CRLF	// "Consulta: "
		cMsgSXB += STR0053 + aVldSXB[nX,2]+CRLF	// "Tipo da consulta: "
		cMsgSXB += STR0054 + aVldSXB[nX,3]+CRLF	// "Descrição: "
		cMsgSXB += STR0055 + aVldSXB[nX,4]+CRLF	// "Tabela: "
		cMsgSXB += STR0056 + aVldSXB[nX,5]+CRLF	// "Expressão: "
		cMsgSXB += STR0057 + aVldSXB[nX,6]+CRLF+CRLF	// "Retorno: "

	Endif
Next nX

If !Empty(cMsgSXB)
	AtShowLog(cMsgSXB,STR0058, .T., .T., .F.)	 // "Inconsistência na Consulta Padrão."
	lRet := .F.
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190Expor

@description Função para Exportar o arquivo .CSV

@author	diego.bezerra
@since	12/12/2019
/*/
//------------------------------------------------------------------------------
Static function at203Exp()

Local aIncCpo	:= {}
Local aNoCpo	:= {}
Local aLegenda	:= {}

AT203Legen( , @aLegenda )

TecGrd2CSV("AGENDAS","ABBDETAIL","DETAIL_ABB",aNoCpo,aIncCpo,aLegenda, "TECA203")

Return ( .T. )
//------------------------------------------------------------------------------
/*/{Protheus.doc} At203GVal

@description Executa um GetValue caso o FwFldGet não consiga retornar o valor do campo

@author	diego.bezerra
@since	12/12/2019
/*/
//------------------------------------------------------------------------------
Function At203GVal(cForm, cField)
Local xValue := FwFldGet(cField)
Local oModel := FwModelActive()
Local oSubModel

If EMPTY(xValue) .AND. VALTYPE(oModel) == "O"
	oSubModel := oModel:GetModel(cForm)
	If VALTYPE(oSubModel) == "O"
		xValue := oSubModel:GetValue(cField)
	EndIf
EndIf

Return xValue

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203ExHTML

@description Chamada principal da função de exportação para HTML

@author	diego.bezerra
@since	13/12/2019
/*/
//------------------------------------------------------------------------------
Static Function At203ExHTML()

Local oMdl		 	:= FwModelActive()
Local oMdlAA1		:= oMdl:GetModel("AA1MASTER")
Local cPathSrv		:= Alltrim(SuperGetMv("MV_TECPATH"))
Local cHTMLSrc		:= cPathSrv + "TECA203_AgendasGS.html"
Local cHTMLDst		:= cPathSrv + "TECA203.htm"
Local cCodtec		:= ""
Local cNomTec		:= ""
Local dDataIni		:= cTod("")
Local dDataFim		:= cTod("")
Local cRet			:= ""
Local cErrMsg		:= ""
Local lRet			:= .T.
Local aErro			:= {}

dDataIni	:= oMdlAA1:GetValue("DTS_DTINI")
dDataFim	:= oMdlAA1:GetValue("DTS_DTFIM")
cCodtec		:= oMdlAA1:GetValue("AA1_CODTEC")
cNomTec		:= oMdlAA1:GetValue("AA1_NOMTEC")

cRet := TmpHtml(cCodtec, cNomTec, dDataIni, dDataFim, cHTMLSrc, cHTMLDst, oMdl, oMdlAA1,@lRet, @cErrMsg)

If lRet
	AVISO(STR0061, STR0062+cHTMLDst, {STR0001}, 1)	// "Marcações" ## "Arquivo HTML gerado com sucesso em "
Else
	If !Empty(cErrMsg)
		AtShowLog(cErrMsg,STR0061, .T., .T., .T.)	// "Marcações"
	EndIf
EndIf

Return aErro

//------------------------------------------------------------------------------
/*/{Protheus.doc} TmpHtml

@description Carrega o template HTML
@return cRet, String, marcação html

@author	diego.bezerra
@since	13/12/2019
/*/
//------------------------------------------------------------------------------
Static Function TmpHtml(cCodtec, cNomTec, dDataIni, dDataFim, cHTMLSrc, cHTMLDst, oMdl, oMdlAA1, lRet, cErrMsg)

Local oMdlABB	:= oMdl:GetModel("ABBDETAIL")
Local nX		:= 0
Local nY		:= 0
Local nColunas	:= SuperGetMv("MV_COLMARC",,2)
Local oHTMLBody	:= Nil
Local lCodTec	:= Empty(cCodtec)
Local cAux		:= ""
Local cBranco	:= Replicate("-", 3)
Local cHtmlTH	:= ""
Local cHtmlTD	:= ""
Local cHtml		:= ""
Local cClass	:= ""
Local cValDif	:= ""
Local cRet		:= ""
Local nTotReal	:= 0
Local nTotPlan	:= 0
Local nTotDif	:= 0
Local cClassTot	:= ""

Default cCodtec	:= ""
Default cNomTec	:= ""
Default dDataIni := sTod("")
Default dDataFim := sTod("")

// Verifica a existência do template html
If File(cHTMLSrc) .AND. !oMdlABB:IsEmpty()
	oHTMLBody:= TWFHTML():New(cHTMLSrc)
	lRet	 := .T.
	For nX := 1 to oMdlABB:Length()
		oMdlABB:GoLine(nX)
		
		cClassTot := ""
		If cAux != oMdlABB:GetValue("ABB_CODTEC")
			If nX > 1
				nTotDif := nTotReal - nTotPlan
				If nTotDif < 0
					nTotDif := nTotDif * -1
					cClassTot := "negativo"
				ElseIf nTotDif > 0
					cClassTot := "positivo"
				EndIf
				cHtml += '</table>'+CRLF
				cHtml += '<table class="subtot"><tr> <th>'+STR0074+'</th><td>' + TecConvHr(nTotPlan) + '</td>' //Total orçado: 
				cHtml += '<th>'+STR0075+'</th> <td>' + TecConvHr(nTotReal) + '</td>'// Total realizado: 
				cHtml += '<th>'+STR0076+'</th> <td class="'+cClassTot+'">' + TecConvHr(nTotDif) + '</td> </tr> </table>'+CRLF //Dif.Tot. de Hrs: 
				nTotPlan 	:= 0
				nTotReal 	:= 0
			EndIf
			cHtml += '<div class="cab"><table class="tabcab">'+CRLF
			If lCodTec
				cHtml += ' <tr> <th>' + STR0077 + '</th><td>'+oMdlABB:GetValue("ABB_CODTEC")+'</td>' //Código: 
				cHtml += '<th>' + STR0078 + '</th><td>'+oMdlABB:GetValue("ABB_NOMTEC")+'</td> </tr>' //Nome: 
			Else
				cHtml += '<tr> <th>' + STR0077 + '</th> <td>'+cCodTec+'</td>'//Código: 
				cHtml += '<th>' + STR0078 + '</th> <td>'+cNomTec+'</td> </tr>'+CRLF //Nome:
			EndIf

			cHtml += '<tr> <th>' + STR0079 + '</th> <td class="date">'+TecDToStr(dDataIni)+'</td>'//Data Inicial: 
			cHtml += '<th>' + STR0080 + '</th> <td class="date">'+TecDToStr(dDataFim) + '</td></tr>' //Data Final:
			cHtml += '</table></div>'+CRLF
			cHtml += '<div class="grid"><table style="width:90%;"> <thead> <tr>'+CRLF
			cHtmlTH := '<th>Data</th> <th>Dia</th> '
			For nY := 1 to nColunas
				cHtmlTH += '<th>' + STR0081 + ' '+cValToChar(nY)+'</th>' //Entrada
				cHtmlTH += '<th>' + STR0082 + ' '+cValToChar(nY)+'</th>' //Saída
			Next nY
			
			cHtmlTH += '<td>' + STR0083 + '</td>' //Diferença
			cHtml += cHtmlTH + '</tr> </thead><tbody>' +CRLF
		EndIf
			cHtmlTD := '<tr> <td> ' + TecDToStr(oMdlABB:GetValue("ABB_DTREF")) + '</td>' //Data
			cHtmlTD += '<td> ' + oMdlABB:GetValue("ABB_DOW") +'</td>' //Dia da semana
		For nY := 1 to nColunas
			cHtmlTD += '<td> '+iIf(Empty(oMdlABB:GetValue("ABB_HRCHIN"+cValToChar(nY))),cBranco,oMdlABB:GetValue("ABB_HRCHIN"+cValToChar(nY)))+'</td>'
			cHtmlTD += '<td> '+iIf(Empty(oMdlABB:GetValue("ABB_HRCOUT"+cValToChar(nY))),cBranco,oMdlABB:GetValue("ABB_HRCOUT"+cValToChar(nY)))+'</td>'
			
			If !Empty(oMdlABB:GetValue("ABB_HRCHIN" + cValToChar(nY))) .AND. !Empty(oMdlABB:GetValue("ABB_HRCOUT" + cValToChar(nY)))
				nTotReal := SomaHoras(Val(STRTRAN(ElapTime( oMdlABB:GetValue("ABB_HRCHIN"+cValToChar(nY))+":00", oMdlABB:GetValue("ABB_HRCOUT"+cValToChar(nY))+":00"), ":",".")), nTotReal)
			Else
				nTotReal := SomaHoras(nTotReal, 0)
			EndIf
		Next nY
		
		nTotPlan := SomaHoras(nTotPlan, TecConvHr(oMdlABB:GetValue("ABB_HRTOT"))) 
		
		If RIGHT(Left(oMdlABB:GetValue("ABB_DIF"),2),1) == '-'
			cValDif := SUBSTR(oMdlABB:GetValue("ABB_DIF"), 4,5)
			cClass := "class='negativo'"
		Else
			cValDif := oMdlABB:GetValue("ABB_DIF")
		EndIf
		
		cHtmlTD += '<td '+cClass+'> ' + cValDif + '</td> </tr>'+CRLF
		cHtml += cHtmlTD
		If nX == oMdlABB:Length()
			nTotDif := SubHoras(nTotReal, nTotPlan)
			If nTotDif < 0
				nTotDif := nTotDif * -1
				cClassTot := "negativo"
			ElseIf nTotDif > 0
				cClassTot := "positivo"
			EndIf
			cHtml += '</table>' + CRLF
			cHtml += '<table class="subtot"><tr> <th> Total orçado: </th><td>' + TecConvHr(nTotPlan) + '</td>' 
			cHtml += '<th>' + STR0084 + '</th> <td>' + TecConvHr(nTotReal) + '</td>' //"Total realizado:"
			cHtml += '<th>' + STR0076 + ' </th> <td class="'+cClassTot+'">' + TecConvHr(nTotDif) + '</td> </tr> </table>'+CRLF //"Dif.Tot. de Hrs:"
		EndIf
		cAux := oMdlABB:GetValue("ABB_CODTEC")
		cClass := ""
	Next nX 
	
	cHtml += '</table>'+CRLF
	oHTMLBody:ValByName('Data',cHtml)
	oHTMLBody:SaveFile(cHTMLDst)
	cRet:= MtHTML2Str(cHTMLDst)
	
	ShellExecute("open",GetSrvProfString("ROOTPATH","/") + cHTMLDst ,"","",2)
	
	If Empty(cRet)
		lRet := .F.
		cErrMsg := STR0063 // "Ocorreu problemas na geração do arquivo html. Por favor verifique o template TECA203_Agendas.html"
	EndIf
Else
	lRet := .F.
	If oMdlABB:IsEmpty()
		cErrMsg := STR0064 // "Por favor, selecione uma jornada valida."
	Else
		cErrMsg := STR0065	 // "O Template TECA203_Agendas.html não foi encontrado no caminho especificado"	
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} at203Sel
	Interface para escolher o tipo de exportação de arquivo.

@author	diego.bezerra
@since 09/12/2019
/*/
//-------------------------------------------------------------------
Static function at203Sel()

Local nRadio 		:= 0
Local aItems 		:= {}
Local lOk	 		:= .F.
Local oRadio		:= Nil
Local oOk			:= Nil
Local oSay			:= Nil

DEFINE MSDIALOG oDlg FROM 0,0 TO 180,380  PIXEL Style 128 TITLE STR0066 // "Exportação de arquivo"
	oSay := TSay():New( 005,010,{||OemToAnsi(STR0069)},; //'<p>Para qual formato deseja exportar o arquivo? </p>'
					oDlg,,TFont():New("Arial",,-11,.T.,.F.) ,,,,.T.,,,168,130,,,,,,.T.)     
	aItems := {'.CSV','.HTML'}
	oRadio := TRadMenu():New (15,05,aItems,,oDlg,,,,,,,,100,12,,,,.T.)
	oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
	oOk := TButton():New( 070, 140, STR0039,oDlg,{|| oDlg:End(), lOk := .T. }, 38,12,,,.F.,.T.,.F.,,.F.,,,.F. )	// "Confirmar"

	ACTIVATE MSDIALOG oDlg CENTERED
	
	If lOk 
		If nRadio == 1
			FwMsgRun(Nil,{|| lRet := at203Exp()}, Nil, STR0067)	// "Exportando CSV..."
		ElseIf nRadio == 2
			FwMsgRun(Nil,{|| lRet := At203ExHTML()}, Nil, STR0068) // "Exportando HTML..."
		EndIf
	EndIf
Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT203dLimp
@description  Verifica se esxiste aspa simples para não dar error.log
@return xValue
@author Augusto Albuquerque
@since  16/12/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT203dLimp(xValue)

If At("'", xValue) > 0
	xValue := STRTRAN(xValue, "'","")
EndIf

Return xValue


//------------------------------------------------------------------------------
/*/{Protheus.doc} At203VldDt

@description Função para validar os campos de data da Estrutura PRJ

@param cTpValid - Campo que será validado


@author	Diego Bezerra
@since	19/12/2019
/*/
//------------------------------------------------------------------------------
Static Function At203VldDt(cTpValid)
Local lRet		:= .T.
Local oModel 	:= FwModelActive()
Local oMdlAA1	:= Nil
Local dGetIni	:= Nil
Local dGetFim	:= Nil
Local cHelp		:= STR0085 //"O período informado não é válido"	
Local cSolucao	:= ""

Default cTpValid	:= ""

If	ValType(oModel) == "O" .AND. oModel:IsActive() .AND. oModel:GetId() == "TECA203"

	oMdlAA1		:= oModel:GetModel('AA1MASTER')
	dGetIni		:= oMdlAA1:GetValue("DTS_DTINI")
	dGetFim		:= oMdlAA1:GetValue("DTS_DTFIM")

	Do Case

		Case	cTpValid == "DTS_DTINI"
			If	Empty(dGetIni)
				cSolucao := STR0086 //"Informe a data inicial"
				lRet	:= .F.
			ElseIf	dGetIni > dGetFim
				cSolucao := STR0087 //"A data inicial deve ser anterior ou igual à data final."
				lRet	:= .F.
			EndIf

		Case	cTpValid == "DTS_DTFIM"
			If	Empty(dGetFim)
				cSolucao	:= STR0089 //"Informe a data final"	
				lRet	:= .F.
			ElseIf	dGetFim < dGetIni
				cSolucao	:= STR0088 //"A data final deve ser posterior ou igual à data inicial."	
				lRet	:= .F.
			EndIf
	End Case
EndIf

If !lRet
	oModel:GetModel():SetErrorMessage(oModel:GetId(),cTpValid,oModel:GetModel():GetId(),cTpValid,cTpValid,;
			cHelp, cSolucao )
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203Exec
Executa um comando genérico recebido via string

@author		Augsuto Albuquerque
@since		22/01/2020
@param 		cCommand - Comando via string a ser executado
@return 	xRet	 - Retorno da macro execução

@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Function At203Exec( cCommand, xPar)
Local xRet := (&(cCommand))

Return xRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At203Batida
@description  Realiza o ajuste de batida

@author Luiz Gabriel
@since  27/09/2022
/*/ 
//--------------------------------------------------------------------------------------------------------------------
Function At203Batida()
Local oModel 	:= NIL
Local aButtons 	:= {}
Local lPerm 	:= At680Perm(NIL, __cUserId, "070", .T.)
Local aCabec	:= {} 
Local oMdlABB	:= Nil

If lPerm
	lAjustOK := .F.
	lCloseOK := .F.
	oModel  := FwModelActive()
    oMdlABB	:= oModel:GetModel("ABBDETAIL")
	If At203MPonto(oMdlABB)
		Aadd(aCabec,{"CODTEC",oMdlABB:GetValue("ABB_CODTEC")})
		Aadd(aCabec,{"NOMTEC",oMdlABB:GetValue("ABB_NOMTEC")})
		Aadd(aCabec,{"DATAREF",oMdlABB:GetValue("ABB_DTREF")})
		Set203ACabec(aCabec)
		aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0092},; //"Ajustar"
						{.T.,STR0001},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // "Fechar"

		FWExecView( STR0091, "VIEWDEF.TECA203A", MODEL_OPERATION_INSERT, /*oDlg*/, {||.T.}/*bCloseOk*/,	{|| At203bOk()}/*bOk*/,30, aButtons, {||At203bClose()}/*bCancel*/ ) //"Ajuste de Batida"
	EndIf
	FwModelActive(oModel)
	If !lCloseOK .And. !lAjustOK
		SetKey( VK_F8, { || At203Batida() })
		SetKey( VK_F10, { || FwMsgRun(Nil,{|| LoadABB()}, Nil, STR0006)}	) // "Processando..."
	EndIf 
	If lAjustOK
		At230ALoad()
	EndIf 
Else
	Help( , , "At203Batida", , STR0093, 1, 0,,,,,,{STR0094}) //"Usuário sem permissão de realizar ajuste de batida manual"##"Verifique a configuração de permissões do usuario na rotina TECA680, permissão 070."
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At203bClose

@description  Seta a variavel para indicar que clicou no botão fechar e atualizar a tela

@author Luiz Gabriel
@since  27/09/2022
/*/ 
//--------------------------------------------------------------------------------------------------------------------
Static Function At203bClose()

lCloseOK := .T.
SetKey( VK_F8, { || At203Batida() })
SetKey( VK_F10, { || FwMsgRun(Nil,{|| LoadABB()}, Nil, STR0006)}	) // "Processando..."

Return lCloseOK

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At203bOk

@description  Seta a variavel para indicar que clicou no botão ajustar e atualizar a tela

@author Luiz Gabriel
@since  27/09/2022
/*/ 
//--------------------------------------------------------------------------------------------------------------------
Static Function At203bOk()

lAjustOK := .T.
SetKey( VK_F8, { || At203Batida() })
SetKey( VK_F10, { || FwMsgRun(Nil,{|| LoadABB()}, Nil, STR0006)}	) // "Processando..."

Return lAjustOK

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At203MPonto
@description  Verifica se o atendente está configurado para batida de ponto, e se o dia possui pendências

@author Luiz Gabriel
@since  27/09/2022
/*/ 
//--------------------------------------------------------------------------------------------------------------------
Static Function At203MPonto(oMdlABB)
Local lRet		:= .T. 
Local aAreaAA1	:= AA1->(GetArea())

DbSelectArea("AA1")
AA1->(DbSetOrder(1))
If AA1->(DbSeek(xFilial("AA1")+oMdlABB:GetValue("ABB_CODTEC"))) .And. AA1->AA1_MPONTO == "2"
	Help( , , "At203MPonto", , STR0095, 1, 0,,,,,,{STR0096}) //"Atendente selecionado não tem configuração para batidas manuais"##"Verifique a configuração do campo AA1_MPONTO"
	lRet := .F.
EndIf 

If lRet 
	If oMdlABB:GetValue("ABB_LEGEND") == "BR_VERDE"
	Help( , , "At203MPonto", , STR0097, 1, 0,,,,,,{STR0098}) //"O dia selecionado não tem pendências de batidas"##"selecione um dia que tem pendências de batidas"
	lRet := .F.		
	EndIf 
EndIf 

RestArea(aAreaAA1)
Return lRet 
