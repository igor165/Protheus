#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA790A.ch"

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

Static aAtend	:= {}


//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA790A - Feriados GS - Cancelamento de Feriado
 	ModelDef
 		Definição do modelo de Dados

@author	Augusto Albuquerque
@since	15/03/2021
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	
Local oStrAC0	:= FWFormModelStruct():New()
Local oStrTFF	:= FWFormModelStruct():New()
Local aFields	:= {}
Local lCancel	:= IsIncallStack("AT790Canc")
Local nX		:= 0
Local nY		:= 0
Local aTables 	:= {}
Local xAux
Local bCommit	:= { |oModel| AT790ACmt(oModel) }
Local bValid := { |oModel| At790AVld(oModel) }

oStrAC0:AddTable("   ",{}, STR0001) //"Cancelamento de Feriado"
oStrTFF:AddTable("   ",{}, "   ")

AADD(aTables, {oStrAC0, "AC0"})
AADD(aTables, {oStrTFF, "TFF"})

For nY := 1 To LEN(aTables)
	aFields := AT790ADef(aTables[nY][2], lCancel)

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

xAux := FwStruTrigger( 'AC0_CODIGO', 'AC0_DESCAL',;
	'Posicione("AC0",1,xFilial("AC0") + FwFldGet("AC0_CODIGO"),"AC0_DESC")', .F. )
	oStrAC0:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

If lCancel
	xAux := FwStruTrigger( 'AC0_CODIGO', 'AC0_CODIGO',;
		'AT790ALiAC0({"AC0_DTFER", "AC0_DESCFER"})', .F. )
		oStrAC0:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Else 
	xAux := FwStruTrigger( 'AC0_CODIGO', 'AC0_CODIGO',;
		'AT790ALiAC0({"AC0_DTFER","AC0_FERREM","AC0_DESCFER","AC0_CODMAN"})', .F. )
		oStrAC0:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
EndIf
xAux := FwStruTrigger( 'AC0_DTFER', 'AC0_DESCFER',;
	'AT790ADFer()', .F. )
	oStrAC0:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'AC0_DTFER', 'AC0_DTFER',;
	'AT790ACarr()', .F. )
	oStrAC0:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

oModel := MPFormModel():New('TECA790A',/*bPreValidacao*/, bValid, bCommit,/*bCancel*/)
oModel:SetDescription( STR0001 ) //"Alocação Por Hora" 

oModel:addFields('AC0MASTER',,oStrAC0)
oModel:SetPrimaryKey({"AC0_FILIAL","AC0_CODIGO"})

oModel:addGrid('TFFDETAIL','AC0MASTER', oStrTFF,{|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| .T.},;
{|oMdlG,nLine,cAcao,cCampo| .T.})

oModel:GetModel('TFFDETAIL'):SetOnlyQuery(.T.)

oModel:GetModel('TFFDETAIL'):SetOptional(.T.)

oModel:GetModel('AC0MASTER'):SetDescription(STR0002)	//"Calendario"
oModel:GetModel('TFFDETAIL'):SetDescription(STR0003)	//"Posto"

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	Augusto Albuquerque
@since 15/03/2021
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel := ModelDef()
Local oView
Local aTables 	:= {}
Local oStrAA1	:= FWFormViewStruct():New()
Local oStrTFF	:= FWFormViewStruct():New()
Local lCancel	:= IsIncallStack("AT790Canc")
Local nX
Local nY
Local lMonitor	:= IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366

AADD(aTables, {oStrAA1, "AC0"})
AADD(aTables, {oStrTFF, "TFF"})

For nY := 1 to LEN(aTables)
	
	aFields := AT790ADef(aTables[nY][2], lCancel)

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

oView:AddField('VIEW_MASTER', oStrAA1, 'AC0MASTER')
oView:AddGrid('DETAIL_TFF', oStrTFF, 'TFFDETAIL')
oView:CreateHorizontalBox( 'REALOC_AA1' , 35 )
oView:CreateHorizontalBox( 'REALOC_ALOC', 65 )

oView:SetOwnerView('VIEW_MASTER','REALOC_AA1')
oView:SetOwnerView('DETAIL_TFF','REALOC_ALOC')
If lMonitor
	oView:SetContinuousForm()
EndIf
oView:EnableTitleView('VIEW_MASTER', 	iIf(lCancel,STR0001,STR0042) ) //"Cancelamento de Feriado" ## //"Remanejamento de feriado"   		

If lCancel
	oView:SetDescription(STR0001) 
Else
	oView:SetDescription(STR0042)   //"Cancelamento de Feriado" ## //"Remanejamento de feriado"         
EndIf
Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados

@description Bloco de código executado no activate
@param oModel, obj, modelo em ativação

@author	Augusto Albuquerque
@since	15/03/2021
/*/
//------------------------------------------------------------------------------
Static Function InitDados(oModel)
Local oMdlTFF := oModel:GetModel('TFFDETAIL')

aAtend:= {}

oMdlTFF:SetNoInsertLine(.T.)
oMdlTFF:SetNoDeleteLine(.T.)
oMdlTFF:SetNoUpdateLine(.T.)

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT790ADef
@description Criação dos campos
@return aRet
@author Augusto Albuquerque
@since  15/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AT790ADef(cTable, lCancel)
Local aRet		:= {}
Local nAux 		:= 0 

Default lCancel := .T.

If cTable == "AC0"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AC0_CODIGO", .F. )		//"Codigo do Calendario"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AC0_CODIGO", .F. )		//"Codigo do Calendario"
	aRet[nAux][DEF_IDENTIFICADOR] := "AC0_CODIGO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AC0_CODIGO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := TamSX3("AC0_CODIGO")[2]
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| Empty(xNewValue) .OR. ExistCpo("AC0",xNewValue,1) }
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "AC0"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0043} //"Codigo do Calendario."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AC0_DESC", .F. )		//"Data da Alocação"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AC0_DESC", .F. )		//"Data da Alocação"
	aRet[nAux][DEF_IDENTIFICADOR] := "AC0_DESCAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AC0_DESC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	if lCancel
		cAux := STR0044// "Data do feriado que deseja cancelar, fixo ou não, caso seja fixo digite o dia no ano corrente."
	Else 
		cAux := STR0040 //"Data do feriado que deseja remanejar."
	EndIf

	If !lCancel

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0038   //"Motivo do Cancelamento"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0038  //"Motivo do Cancelamento"
		aRet[nAux][DEF_IDENTIFICADOR] := "AC0_CODMAN"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 6
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.} 
		aRet[nAux][DEF_OBRIGAT] := .T.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "03"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_LOOKUP] := "ABNCAN" 
		aRet[nAux][DEF_HELP] := {STR0039}	//"Motivo do cancelamento do feriado."
		
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0037	//"Nova Data"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0037	//"Nova Data"
		aRet[nAux][DEF_IDENTIFICADOR] := "AC0_FERREM"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.} 
		aRet[nAux][DEF_OBRIGAT] := .T.
		aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl, cField, xNewValue| AT790VLD(oMdl, cField, xNewValue) }
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "04"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0041}	 //"Nova data do feriado." 
	EndIf
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "RR0_DATA", .F. )	//"Data do Feriado"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "RR0_DATA", .F. )	//"Data Inicial"
	aRet[nAux][DEF_IDENTIFICADOR] := "AC0_DTFER"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.} //AT790AVerD
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| AT790AVerD(oMdl,cField,xNewValue) }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {cAux}	//"Data inicial do periodo. Baseado na data base do sistema."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "RR0_DESC", .F. )	//"Descrição do Feriado"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "RR0_DESC", .F. )		//"Descrição do Feriado"
	aRet[nAux][DEF_IDENTIFICADOR] := "AC0_DESCFER"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("RR0_DESC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

ElseIf cTable == "TFF"
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0045 //"Codigo do Posto"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0045 //"Codigo do Posto"
	aRet[nAux][DEF_IDENTIFICADOR] := "TFF_COD"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_COD")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0046 //"Descrição do Posto"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0046 //"Descrição do Posto"
	aRet[nAux][DEF_IDENTIFICADOR] := "TFF_PRODUT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("B1_DESC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0047 //"Data inicial do Posto"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0047 //"Data inicial do Posto"
	aRet[nAux][DEF_IDENTIFICADOR] := "TFF_PERINI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_PERINI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0048 // "Data Final do Posto"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0048 // "Data Final do Posto"
	aRet[nAux][DEF_IDENTIFICADOR] := "TFF_PERFIM"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_PERFIM")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_CONTRT", .T. ) //"Contrato"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_CONTRT", .F. ) //"Contrato"
	aRet[nAux][DEF_IDENTIFICADOR] := "TFF_CONTRT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_CONTRT")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_CONREV", .T. )  //"Revisão"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_CONREV", .T. )  //"Revisão"
	aRet[nAux][DEF_IDENTIFICADOR] := "TFF_CONREV"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_CONREV")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_ESCALA", .T. ) //"Codigo da Escala"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_ESCALA", .F. ) //"Codigo da Escala"
	aRet[nAux][DEF_IDENTIFICADOR] := "TFF_ESCALA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_ESCALA")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
 
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := "Descrição da Escala"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "Descrição da Escala"
	aRet[nAux][DEF_IDENTIFICADOR] := "TFF_DESESC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TDW_DESC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFL_LOCAL", .T. ) // "Codigo do Local"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFL_LOCAL", .F. )  //"Codigo do Local"
	aRet[nAux][DEF_IDENTIFICADOR] := "TFF_LOCAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFL_LOCAL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "ABS_DESCRI", .T. ) //"Descrição do Local"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "ABS_DESCRI", .F. ) //"Descrição do Local"
	aRet[nAux][DEF_IDENTIFICADOR] := "TFF_DESLOC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_DESCRI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "10"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

EndIf

Return (aRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT790ALiAC0
@description Liberação dos campos no grid de filtro
@return 
@author Augusto Albuquerque
@since  15/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT790ALiAC0( aCampos )
Local oModel    := FwModelActive()
Local oView 	:= FwViewActive()
Local oMdlAC0	:= oModel:GetModel("AC0MASTER")
Local oMdlTFF	:= oModel:GetModel("TFFDETAIL")
Local oStrAC0 	:= oMdlAC0:GetStruct()
Local lLibera	:= !Empty(FwFldGet("AC0_CODIGO"))
Local nX

oMdlTFF:ClearData()

aAtend:= {}

For nX := 1 To Len(aCampos)
	oStrAC0:SetProperty(aCampos[nX], MODEL_FIELD_WHEN, {|| lLibera})
	If !lLibera
		If aCampos[nX] $ "AC0_DTFER|AC0_FERREM"
			oMdlAC0:LoadValue(aCampos[nX], SToD(""))
		Else
			oMdlAC0:LoadValue(aCampos[nX], "")
		EndIf
	EndIf
Next nX

If !isBlind()
	oView:Refresh()
EndIf

Return 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT790ACarr
@description Faz a carga do grid da TFFDETAIL quando preenche a data do feriado
@return 
@author Augusto Albuquerque
@since  15/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT790ACarr()
FwMsgRun(Nil,{|| CarregaTFF()}, Nil, STR0004) //"Carregando..."

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaTFF
@description Faz a carga do grid da TFFDETAIL quando preenche a data do feriado
@return 
@author Augusto Albuquerque
@since  15/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CarregaTFF()
Local oModel    := FwModelActive()
Local oView		:= FwViewActive()
Local oMdlAC0 	:= oModel:GetModel('AC0MASTER')
Local oMdlTFF 	:= oModel:GetModel('TFFDETAIL')
Local dData 	:= oMdlAC0:GetValue("AC0_DTFER")
Local cCodAC0	:= oMdlAC0:GetValue("AC0_CODIGO")
Local cSql 		:= ""
Local cAuxCod	:= ""
Local cAliasQry
Local lGsGeHor	:= SuperGetMV('MV_GSGEHOR',,.F.)
Local nLinha 	:= 1

oMdlTFF:SetNoInsertLine(.F.)
oMdlTFF:SetNoDeleteLine(.F.)
oMdlTFF:SetNoUpdateLine(.F.)

aAtend:= {}

oMdlTFF:ClearData()
oMdlTFF:InitLine()

If !EMPTY(cCodAC0) .AND. !EMPTY(dData) 
	
	cSql := ""
	cSql += " SELECT TFF.TFF_COD, SB1.B1_DESC, TFF.TFF_PERINI, TFF.TFF_PERFIM, TFF.TFF_CONTRT, TFF.TFF_CONREV "
	cSql += " , TGY.TGY_ATEND, TGY.TGY_CODTDX, TGY.TGY_GRUPO, TFF.TFF_ESCALA, TGY.TGY_TIPALO, TGY.TGY_ITEM, TGY.TGY_FILIAL, TGY.R_E_C_N_O_ REC "
	cSql += " , TFF.TFF_ESCALA, TDW.TDW_DESC, TFL.TFL_LOCAL, ABS.ABS_DESCRI "
	If lGsGeHor
		cSql += " , TGY.TGY_ENTRA1, TGY.TGY_SAIDA1, TGY.TGY_ENTRA2, TGY.TGY_SAIDA2, TGY.TGY_ENTRA3, TGY.TGY_SAIDA3, TGY.TGY_ENTRA4, TGY.TGY_SAIDA4 "
	EndIf
	cSql += " FROM " + RetSqlName( "TFF" ) + " TFF "
	cSql += " INNER JOIN " + RetSqlName("TFL") + " TFL "
	cSql += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
	cSql += " AND TFL.D_E_L_E_T_ = ' ' "
	cSql += " AND TFF.TFF_CODPAI = TFL.TFL_CODIGO "
	cSql += " INNER JOIN " + RetSqlName( "ABS" ) + " ABS ON TFL.TFL_LOCAL = ABS.ABS_LOCAL AND "
	cSql += " ABS.ABS_FILIAL = '" + xFilial("ABS") + "' "
	cSql += " AND ABS.D_E_L_E_T_ = ' ' "
	cSql += " LEFT JOIN " + RetSqlName( "TDW" ) + " TDW "
	cSql += " ON TDW.TDW_FILIAL = '" + xFilial("TDW") + "' "
	cSql += " AND TDW.D_E_L_E_T_ = ' ' "
	cSql += " AND TDW.TDW_COD = TFF.TFF_ESCALA " 
	cSql += " INNER JOIN " + RetSqlName( "AC0" ) + " AC0 "
	cSql += " ON AC0.AC0_CODIGO = TFF.TFF_CALEND " 
	cSql += " AND AC0.AC0_FILIAL = '" + xFilial("AC0") +"' "
	cSql += " AND AC0.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB1.B1_COD = TFF.TFF_PRODUT AND "
	cSql += " SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
	cSql += " SB1.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName( "TGY" ) + " TGY "
	cSql += " ON TGY.TGY_FILIAL = '" + xFilial("TGY") +"' "
	cSql += " AND TGY.TGY_CODTFF = TFF.TFF_COD "
	cSql += " AND TGY.D_E_L_E_T_ = ' ' "
	cSql += " WHERE "
	cSql += " TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
	cSql += " AND TFF.TFF_CALEND = '" + cCodAC0 + "' "
	cSql += " AND ( '" + DTOS(dData) + "' BETWEEN TFF.TFF_PERINI AND TFF.TFF_PERFIM ) "
	cSql += " AND TFF.D_E_L_E_T_ = ' ' "
	cSql += " AND ( '" + DTOS(dData) + "' BETWEEN TGY.TGY_DTINI AND TGY.TGY_DTFIM ) "
	cSql += " AND TGY.TGY_ULTALO <> ' ' "
	
	cSql := ChangeQuery(cSql)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
	While !(cAliasQry)->(EOF())
		If TFF_COD <> cAuxCod
			cAuxCod := (cAliasQry)->(TFF_COD)
			AADD( aAtend, { (cAliasQry)->(TFF_ESCALA),;
							(cAliasQry)->(TFF_COD),;
							(cAliasQry)->(TGY_ATEND),;
							(cAliasQry)->(TGY_GRUPO),;
							(cAliasQry)->(TGY_CODTDX),;
							(cAliasQry)->(TGY_TIPALO),;
							(cAliasQry)->(TGY_FILIAL),;
							(cAliasQry)->(TGY_ITEM),;
							(cAliasQry)->(REC),;
							{} } )
			If lGsGeHor
				AADD( aAtend[Len(aAtend)][10], {(cAliasQry)->(TGY_ENTRA1), (cAliasQry)->(TGY_SAIDA1)})
				AADD( aAtend[Len(aAtend)][10], {(cAliasQry)->(TGY_ENTRA2), (cAliasQry)->(TGY_SAIDA2)})
				AADD( aAtend[Len(aAtend)][10], {(cAliasQry)->(TGY_ENTRA3), (cAliasQry)->(TGY_SAIDA3)})
				AADD( aAtend[Len(aAtend)][10], {(cAliasQry)->(TGY_ENTRA4), (cAliasQry)->(TGY_SAIDA4)})
			EndIf
			If !oMdlTFF:IsEmpty()
				nLinha := oMdlTFF:AddLine()
			EndIf
			//// TFF_ESCALA TDW_DESC TFL_LOCAL ABS_DESCRI
			oMdlTFF:GoLine(nLinha)
			oMdlTFF:LoadValue("TFF_COD", (cAliasQry)->(TFF_COD))
			oMdlTFF:LoadValue("TFF_PRODUT",(cAliasQry)->(B1_DESC))
			oMdlTFF:LoadValue("TFF_PERINI", STOD((cAliasQry)->(TFF_PERINI)))
			oMdlTFF:LoadValue("TFF_PERFIM", STOD((cAliasQry)->(TFF_PERFIM)))
			oMdlTFF:LoadValue("TFF_CONTRT", (cAliasQry)->(TFF_CONTRT))
			oMdlTFF:LoadValue("TFF_CONREV", (cAliasQry)->(TFF_CONREV))
			oMdlTFF:LoadValue("TFF_ESCALA", (cAliasQry)->(TFF_ESCALA))
			oMdlTFF:LoadValue("TFF_DESESC", (cAliasQry)->(TDW_DESC))
			oMdlTFF:LoadValue("TFF_LOCAL", (cAliasQry)->(TFL_LOCAL))
			oMdlTFF:LoadValue("TFF_DESLOC", (cAliasQry)->(ABS_DESCRI))

		Else
			AADD( aAtend, { (cAliasQry)->(TFF_ESCALA),;
							(cAliasQry)->(TFF_COD),;
							(cAliasQry)->(TGY_ATEND),;
							(cAliasQry)->(TGY_GRUPO),;
							(cAliasQry)->(TGY_CODTDX),;
							(cAliasQry)->(TGY_TIPALO),;
							(cAliasQry)->(TGY_FILIAL),;
							(cAliasQry)->(TGY_ITEM),;
							(cAliasQry)->(REC),;
							{} } )
			If lGsGeHor
				AADD( aAtend[Len(aAtend)][10], {(cAliasQry)->(TGY_ENTRA1), (cAliasQry)->(TGY_SAIDA1)})
				AADD( aAtend[Len(aAtend)][10], {(cAliasQry)->(TGY_ENTRA2), (cAliasQry)->(TGY_SAIDA2)})
				AADD( aAtend[Len(aAtend)][10], {(cAliasQry)->(TGY_ENTRA3), (cAliasQry)->(TGY_SAIDA3)})
				AADD( aAtend[Len(aAtend)][10], {(cAliasQry)->(TGY_ENTRA4), (cAliasQry)->(TGY_SAIDA4)})
			EndIf
		EndIf
		(cAliasQry)->(dbSkip())

	End
	(cAliasQry)->(dbCloseArea())
	oMdlTFF:GoLine(1)
Else
	Help(,,"CarregaTFF",, STR0005 ,1,0) // "Por favor, digite um calendario e uma data de feriado validos!"
EndIf

oMdlTFF:SetNoInsertLine(.T.)
oMdlTFF:SetNoDeleteLine(.T.)
oMdlTFF:SetNoUpdateLine(.T.)

If !IsBlind() .AND. VALTYPE(oView) == "O"
	oView:Refresh('DETAIL_TFF')
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT790VLD
@description Validação para a nova data do feriado
@return 
@author Diego Bezerra
@since  15/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function AT790VLD(oMdl, cField, xNewValue)

Local oMdlFull	:= oMdl:GetModel()
Local dDataFer	:= oMdlFull:GetModel("AC0MASTER"):GetValue("AC0_DTFER")
Local lRet 		:= .T.

If (xNewValue == dDataFer)
	lRet := .F.
	Help(,,"AT790VLD",, STR0036 ,1,0) //"A nova data do feriado deve ser diferente da data de original."
Else
	lRet := AT790AVerD(oMdl, , xNewValue, .F.)
EndIf

Return lRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT790AVerD
@description Valid de Feriado para o dia digitado
@return 
@author Augusto Albuquerque
@since  15/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT790AVerD(oMdl,cField,xNewValue,lFeriad)
Local oMdlFull	:= oMdl:GetModel()
Local cCodAC0	:= oMdlFull:GetModel("AC0MASTER"):GetValue("AC0_CODIGO")
Local cQuery 	:= ""
Local cAliasQry	:= GetNextAlias()
Local lRet 		:= .T.

Default lFeriad := .T.

If !Empty(xNewValue)
	cQuery :=  ""
	cQuery += " SELECT 1  "
	cQuery += " FROM " + RetSqlName( "AC0" ) + " AC0 "
	cQuery += " INNER JOIN " + RetSqlName( "RR0" ) + " RR0 "
	cQuery += " ON RR0.RR0_FILIAL = AC0.AC0_FILIAL "
	cQuery += " AND RR0.RR0_CODCAL = AC0.AC0_CODIGO "
	cQuery += " AND RR0.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE "
	cQuery += " AC0.AC0_FILIAL = '" + xFilial("AC0") + "' "
	cQuery += " AND AC0.AC0_CODIGO = '" + cCodAC0 + "' "
	cQuery += " AND AC0.D_E_L_E_T_ = ' ' "
	cQuery += " AND ( RR0.RR0_DATA = '" + DToS(xNewValue) + "' "
	cQuery += " OR ( RR0.RR0_MESDIA = '" + MesDia(xNewValue) + "'AND RR0.RR0_FIXO = 'S' ))"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	If lFeriad
		If (cAliasQry)->(EOF())
			lRet := .F.	
			If !IsBlind()
				Help(,,"AT790AVerD",, STR0006 ,1,0) //"Não foi encontrado feriado para esse dia."
			EndIf
		EndIf
	Else
		If !(cAliasQry)->(EOF())
			lRet := .F.	
			If !IsBlind()
				Help(,,"AT790AVerD",, STR0049 ,1,0) //"Ja existe feriado cadastrado para esse dia!"
			EndIf
		EndIf
	EndIf
	(cAliasQry)->(dbCloseArea())
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT790ACmt
@description Criação da tela no commit
@return 
@author Augusto Albuquerque
@since  15/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT790ACmt( oModel )
Local oDlg
Local oPanTop
Local oPanBot
Local oFont
Local nMeter
Local oMeter
Local oSay
Local oSayMsg
Local lRet 		:= .T.
Local nTotal	:= Len(aAtend)
Local lIsCancel	:= isInCallStacK('AT790Canc')

If !isBlind()
	DEFINE MSDIALOG oDlg TITLE STR0007 FROM 0,0 TO 100,450 PIXEL STYLE DS_MODALFRAME // "Geração das Agenda"
		oPanTop := TPanel():New( 0, 0, , oDlg, , , , , , 0, 0, ,  )
		oPanTop:Align := CONTROL_ALIGN_ALLCLIENT

		oPanBot := TPanel():New( 0, 0, , oDlg, , , , ,/*CLR_YELLOW*/, 0, 25 , )
		oPanBot:Align := CONTROL_ALIGN_BOTTOM

		DEFINE FONT oFont NAME "Arial" SIZE 0,16
		// "Serão processados "#" Atendentes para o dia selecionado"
		@ 05,08 SAY oSay Var "<center>"+STR0008+cValToChar(nTotal)+STR0009+"</center>" PIXEL SIZE 210,65 HTML FONT oFont PIXEL OF oPanTop

		nMeter := 0
		oMeter := TMeter():New(02,7,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oPanBot,200,100,,.T.,,,.F.)
		//"Processando..."#
		@ 10,02 SAY oSayMsg Var "<center>"+STR0010+"</center>" PIXEL SIZE 210,65 HTML FONT oFont PIXEL OF oPanBot

	if lIsCancel
		ACTIVATE DIALOG oDlg CENTERED ON INIT (lRet := ProcesCanc(oModel, oDlg,oMeter,oSayMsg))
	Else
		ACTIVATE DIALOG oDlg CENTERED ON INIT (lRet := ProcIncCal(oModel, oDlg, oMeter))
	EndIf
Else
	if lIsCancel
		lRet := ProcesCanc(oModel)
	Else
		lRet := ProcIncCal(oModel)	
	EndIf
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcesCanc
@description Processamento de Cancelamento no commit
@return 
@author Augusto Albuquerque
@since  15/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ProcesCanc(oModel, oDlg,oMeter,oSayMsg)
Local oMdl790	:= Nil //FwLoadModel("TECA790")
Local oMdlAC0 	:= oModel:GetModel('AC0MASTER')
Local oMdlRR0	:= Nil
Local oStruRR0 	:= Nil//oMdl:GetStruct()
Local aErrors	:= {}
Local aErroMVC	:= {}
Local aFieldsRR0:= {}
Local aValue	:= {}
Local cSeq		:= ""
Local cCodAC0	:= oMdlAC0:GetValue("AC0_CODIGO")
Local cKeyTGY	:= ""
Local cMsg		:= ""
Local dData 	:= oMdlAC0:GetValue("AC0_DTFER")
Local dDtUltalo	:= SToD("")
Local lRet		:= .T.
Local nRecno	:= 0
Local nReg		:= 0
Local nTotal	:= Len(aAtend)
Local nX
Local nZ
Local oGsAloc	:= GsAloc():New()
Local oGsLog	:= GsLog():New(.T.)

Default oDlg		:= Nil
Default oMeter	:= Nil
Default oSayMsg	:= Nil

Begin Transaction
	If !isBlind()
		oMeter:SetTotal(nTotal)
		oMeter:Set(nReg)
	EndIf
	DbSelectArea("AC0")
	AC0->(DbSetOrder(1))

	If AC0->(MSSeek( xFilial("AC0") + cCodAC0 ) )
		oMdl790	:= FwLoadModel("TECA790")
		oMdl790:SetOperation(MODEL_OPERATION_UPDATE)
		If oMdl790:Activate()
			oMdlRR0 := oMdl790:GetModel("RR0DETAIL")
			If oMdlRR0:SeekLine({{ "RR0_DATA", dData }},,.T. ) .OR.;
				oMdlRR0:SeekLine({{ "RR0_MESDIA", MesDia(dData) }, { "RR0_FIXO", "S" }},,.T. )
				oStruRR0 := oMdlRR0:GetStruct()
				aFieldsRR0 := oStruRR0:GetFields()
				For nX := 1 To Len(aFieldsRR0)
					If !aFieldsRR0[nX][14] .AND. aFieldsRR0[nX][3] <> 'RR0_FILIAL'//Retirada dos campos virtuais
						AADD( aValue, {aFieldsRR0[nX][3], oMdlRR0:GetValue(aFieldsRR0[nX][3])})
					EndIf
				Next nX
				lRet := oMdlRR0:DeleteLine()
				If !lRet .OR. !(oMdl790:VldData() .AND. oMdl790:CommitData())
					lRet := .F.
					aErroMVC := oMdl790:GetErrorMessage()
					CargaErroM(@aErrors, aErroMVC)
				EndIf
				oMdl790:DeActivate()
				oMdl790:Destroy()
				If lRet
					DbSelectArea("TGY")
					TGY->(DbSetOrder(1))
					For nX := 1 To nTotal
						oGsLog:addLog("Cancelamento Fer.", " ")
						oGsLog:addLog("Cancelamento Fer.", "------------------")
						oGsLog:addLog("Cancelamento Fer.", STR0011 + aAtend[nX][3]) // "Atendente: "
						oGsLog:addLog("Cancelamento Fer.", STR0012+ aAtend[nX][2]) // "Posto: " 
						If !isBlind()
							//"Total de: " # " Atendentes. Sendo processando: "
							oSayMsg:SetText("<center>"+STR0013+cValToChar(nTotal)+STR0014+cValToChar(nReg)+"</center>")
							oMeter:Set(++nReg) // Atualiza Gauge/Tmeter
						EndIf
						cSeq := GetAgendas(aAtend[nX][3], aAtend[nX][2], dData)
						If !Empty(cSeq)
							cKeyTGY := aAtend[nX][7] + aAtend[nX][1] + aAtend[nX][5] + aAtend[nX][2] + aAtend[nX][8]
							nRecno := aAtend[nX][9]
							If TGY->(MSSeek( cKeyTGY ) )
								dDtUltalo := TGY->TGY_ULTALO
								TGY->(RecLock("TGY", .F.))
									TGY->TGY_ULTALO := DaySub(dData, 1)
								TGY->( MsUnlock() )
							EndIf
							oGsAloc:defEscala( aAtend[nX][1] )
							oGsAloc:defPosto( aAtend[nX][2] )
							oGsAloc:defTec( aAtend[nX][3] )
							oGsAloc:defGrupo( aAtend[nX][4] )
							oGsAloc:defConfal( aAtend[nX][5] )
							oGsAloc:defDate( dData, dData ) 
							oGsAloc:defSeq( cSeq )
							oGsAloc:defTpAlo( aAtend[nX][6] )
							oGsAloc:defCob( .F. )
							oGsAloc:defGeHor( aAtend[nX][10] )
							oGsAloc:defRec(nRecno)
							If oGsAloc:vldData()
								oGsAloc:ProjAloc()
								If !EMPTY( oGsAloc:defMessage() )
									oGsLog:addLog("Cancelamento Fer.", oGsAloc:defMessage())
								EndIf
								oGsAloc:GravaAloc( .F. )
								oGsLog:addLog("Cancelamento Fer.", oGsAloc:defMessage())
							Else
								oGsLog:addLog("Cancelamento Fer.", oGsAloc:defMessage())
							EndIf
							If TGY->(MSSeek( cKeyTGY ) )
								TGY->(RecLock("TGY", .F.))
									TGY->TGY_ULTALO := dDtUltalo
								TGY->( MsUnlock() )
							EndIf
						EndIf
						oGsAloc:destroy()			
					Next nX
					oGsLog:addLog("Cancelamento Fer.", "------------------")
					oMdl790	:= FwLoadModel("TECA790")
					oMdl790:SetOperation(MODEL_OPERATION_UPDATE)
					If oMdl790:Activate()
						oMdlRR0 := oMdl790:GetModel("RR0DETAIL")
						nLinha := oMdlRR0:AddLine()
						oMdlRR0:GoLine(nLinha)
						For nX := 1 To Len(aValue)
							oMdlRR0:LoadValue(aValue[nX][1], aValue[nX][2])
						Next nX
						If lRet .AND. !(oMdl790:VldData() .AND. oMdl790:CommitData())
							lRet := .F.
							aErroMVC := oMdl790:GetErrorMessage()
							CargaErroM(@aErrors, aErroMVC)
						EndIf
						oMdl790:DeActivate()
						oMdl790:Destroy()
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
End Transaction

FWModelActive(oModel)
If !EMPTY(aErrors)
	For nX := 1 To LEN(aErrors)
		For nZ := 1 To LEN(aErrors[nX])
			cMsg += If(Empty(aErrors[nX][nZ]), aErrors[nX][nZ], aErrors[nX][nZ] + CRLF )
		Next
		cMsg += CRLF + REPLICATE("-",30) + CRLF
	Next
	If !ISBlind()
		AtShowLog(cMsg,STR0015,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.)	//"Exclusão do Feriado"
	EndIf
EndIf

oGsLog:printLog("Cancelamento Fer.")
If !IsBlind()
	MsgInfo(STR0016 +TxLogPath(ALLTRIM(cFilant)+"Cancelamento Fer.")) // "Processamento concluido. Log gerado em: "
EndIf


If !isBlind()
	oDlg:End() 
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetAgendas
@description Retorna agenda e sequencia do atendente no dia.
@return 
@author Augusto Albuquerque
@since  15/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetAgendas( cCodTec, cCodTFF, dDataFer, lCancel, aAgendas)
Local cRet		:= ""
Local cTurno	:= ""
Local cSeq		:= ""
Local cQuery 	:= ""
Local cAliasQry	:= GetNextAlias()
Local dDataAux	:= SToD("")
Local nDifAux	:= 0

Default aAgendas := {}
Default lCancel := .T.

cQuery := "" 
cQuery += " SELECT ABB.ABB_CODIGO, ABB.ABB_DTINI, ABB.ABB_DTFIM, ABB.ABB_HRINI, ABB.ABB_HRFIM, ABB.ABB_ATENDE, ABB.ABB_CHEGOU, ABB.ABB_IDCFAL, ABB_FILIAL, TDV.TDV_DTREF, TDV.TDV_TURNO, TDV.TDV_SEQTRN "
cQuery += " , ABB.ABB_CODTEC "
cQuery += " FROM " + RetSqlName( "TDV" ) + " TDV "
cQuery += " INNER JOIN " + RetSqlName( "ABB" ) + " ABB "
cQuery += " ON ABB.ABB_CODIGO = TDV.TDV_CODABB "
cQuery += " AND ABB.ABB_FILIAL = TDV.TDV_FILIAL "
cQuery += " AND ABB.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSqlName( "ABQ" ) + " ABQ " 
cQuery += "ON ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM  AND "
cQuery += " ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "' "
cQuery += " AND ABQ.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSqlName( "TFF" ) + " TFF "
cQuery += " ON TFF.TFF_FILIAL = ABQ.ABQ_FILTFF "
cQuery += " AND TFF.TFF_COD = ABQ.ABQ_CODTFF "
cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSqlName( "TGY" ) + " TGY "
cQuery += " ON " 
cQuery += " TGY.TGY_FILIAL = '" + xFilial("TGY") +"' "
cQuery += " AND TGY.TGY_CODTFF = TFF.TFF_COD "
cQuery += " AND TGY.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " ABB.ABB_CODIGO = TDV.TDV_CODABB"
cQuery += " AND ABB.D_E_L_E_T_ = ' ' "
cQuery += " AND ABB.ABB_CODTEC = '" + cCodTec + "' "
cQuery += " AND TFF.TFF_COD = '" + cCodTFF + "' "
If lCancel
	cQuery += " AND TDV.TDV_DTREF BETWEEN '" +  Dtos(DaySub(dDataFer,6)) + "' AND '" +  Dtos(DaySum(dDataFer,6))  + "' "
Else
	cQuery += " AND TDV.TDV_DTREF = '" + Dtos(dDataFer) + "' "
EndIf
cQuery += " GROUP BY ABB_CODIGO, ABB_DTINI, ABB_DTFIM, ABB_HRINI, ABB_HRFIM, ABB_ATENDE, ABB_CHEGOU, ABB_IDCFAL, ABB_FILIAL,TDV.TDV_DTREF, TDV.TDV_TURNO, TDV.TDV_SEQTRN, ABB.ABB_CODTEC "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While !(cAliasQry)->(EOF())
	If lCancel
		If DateDiffDay(dDataFer, SToD((cAliasQry)->(TDV_DTREF))) < DateDiffDay(dDataFer, dDataAux)
			dDataAux := SToD((cAliasQry)->(TDV_DTREF))
			cTurno := (cAliasQry)->(TDV_TURNO)
			cSeq := (cAliasQry)->(TDV_SEQTRN)
			nDifAux := DateDiffDay(dDataFer, dDataAux)
		EndIf
	Else
		aAdd(aAgendas,{;
			(cAliasQry)->ABB_FILIAL,;
			(cAliasQry)->ABB_CODIGO,; 
			(cAliasQry)->ABB_DTINI,;
			(cAliasQry)->ABB_HRINI,; 
			(cAliasQry)->ABB_HRFIM,; 
			(cAliasQry)->ABB_ATENDE,;
			(cAliasQry)->ABB_CHEGOU,;
			(cAliasQry)->ABB_CODTEC;
		})
	EndIf
	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(dbCloseArea())
If lCancel
	If !Empty(dDataAux)
		If dDataAux <  dDataFer 
			cRet := NextDayType(dDataAux, cTurno, cSeq, DateDiffDay(dDataFer, dDataAux))
		Else
			cRet := PreviousDay(dDataAux, cTurno, cSeq, DateDiffDay(dDataFer, dDataAux))
		EndIf
	EndIf
EndIf
Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CargaErroM
@description Retorna no array os erros do MVC
@return 
@author Augusto Albuquerque
@since  15/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static function CargaErroM(aErrors, aErroMVC)
AADD(aErrors, {	 STR0017 + ' [' + AllToChar( aErroMVC[1] ) + ']',;	//"Id do formulário de origem:"
									 STR0018 + ' [' + AllToChar( aErroMVC[2] ) + ']',;	//"Id do campo de origem:"
									 STR0019 + ' [' + AllToChar( aErroMVC[3] ) + ']',;	//"Id do formulário de erro:"
									 STR0020+ ' [' + AllToChar( aErroMVC[4] ) + ']',;	//"Id do campo de erro:"
									 STR0021 + ' [' + AllToChar( aErroMVC[5] ) + ']',;	//"Id do erro:"
									 STR0022 + ' [' + AllToChar( aErroMVC[6] ) + ']',;	//"Mensagem do erro:"
									 STR0023 + ' [' + AllToChar( aErroMVC[7] ) + ']',;	//"Mensagem da solução:"
									 STR0024 + ' [' + AllToChar( aErroMVC[8] ) + ']',;	//"Valor atribuído:"
									 STR0025 + ' [' + AllToChar( aErroMVC[9] ) + ']';	//"Valor anterior:"
									 })
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} NextDayType

@description Retorna o PJ_DIA de um determinado dia calculado apartir dos parâmetros

@param dDtBase, date, dia que será usado como base para o calculo
@param cTurno, string, código da tabela de horário utilizado como base
@param cSeqBase, string, código da semana da tabela de horário utilizado como base
@param nDays, int, valor positivo de quantos dias a função deve rodar para frente

Exemplo de uso:
    -> Igual PreviousDay, porém "rodando para frente"

@return cRet, string, Tipo do dia.

@author	boiani
@since	23/07/2020
/*/
//------------------------------------------------------------------------------
Static Function NextDayType(dDtBase, cTurno, cSeqBase, nDays, cFilProc)
Local cRet := 'N'
Local nAuxDia
Local aSeqTno := {}
Local cQry := GetNextAlias()
Local cFilBkp := cFilAnt
Default cFilProc := cFilAnt

If !EMPTY(dDtBase) .AND. !EMPTY(cTurno) .AND. !EMPTY(cSeqBase) .AND. nDays > 0
    If LEN(AllTrim(cFilProc)) == LEN(Alltrim(cFilAnt))
        cFilAnt := cFilProc
    EndIf
    nAuxDia := DOW(dDtBase)

    BeginSQL Alias cQry
        SELECT DISTINCT PJ_SEMANA 
            FROM %Table:SPJ% SPJ
            WHERE SPJ.PJ_FILIAL = %xFilial:SPJ%
            AND SPJ.%NotDel%
            AND SPJ.PJ_TURNO = %Exp:cTurno%
    EndSQL

    While (cQry)->(!Eof())
        AADD(aSeqTno, (cQry)->(PJ_SEMANA))
        (cQry)->(DbSkip())
    End
    (cQry)->(DbCloseArea())
    If !EMPTY(aSeqTno) .AND. ASCAN(aSeqTno, cSeqBase) > 0
        While nDays > 0
            If nAuxDia + 1 == 2
                If LEN(aSeqTno) == ASCAN(aSeqTno, cSeqBase)
                    cSeqBase := aSeqTno[1]
                Else
                    cSeqBase := aSeqTno[(ASCAN(aSeqTno, cSeqBase) + 1)]
                EndIF
                nAuxDia++
            ElseIf nAuxDia + 1 == 8
                nAuxDia := 1
            Else
                nAuxDia++
            EndIf
            nDays--
        End
        cRet := cSeqBase
    EndIf
EndIf
cFilAnt := cFilBkp
Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreviousDay

@description Retorna o PJ_DIA de um determinado dia calculado apartir dos parâmetros

@param dDtBase, date, dia que será usado como base para o calculo
@param cTurno, string, código da tabela de horário utilizado como base
@param cSeqBase, string, código da semana da tabela de horário utilizado como base
@param nDays, int, valor negativo de quantos dias a função deve rodar para trás

Exemplo de uso:
    -> Em uma escala 12x36 (código "001"), é preciso descobrir qual seria o tipo do dia 01/01/2099 
    sem saber qual a sequência deste dia. Caso algum outro dia nesta tabela de horário
    seja conhecido - por exemplo, o dia 31/01/2099 é da sequência "02" (PJ_SEMANA), basta
    executar esta rotina de seguinte maneira:

    PreviousDay(;
        31/01/2099,;               //(data referente aos demais params)
        "001",.                    //(Código da tabela de horário 12x36)
        "02",;                     //(a data do primeiro param está na semana "02")
        01/01/2099 - 31/01/2099    //(número [negativo] de dias que a rotina deve "girar para trás" 
                                        para chegar na sequência desejada (PJ_SEMANA), e assim,
                                        no tipo do dia dessa sequência para este dia da semana )
    )

@return cRet, string, Tipo do dia.

@author	boiani
@since	23/07/2020
/*/
//------------------------------------------------------------------------------
Static Function PreviousDay(dDtBase, cTurno, cSeqBase, nDays, cFilProc)
Local cRet := 'N'
Local nAuxDia
Local aSeqTno := {}
Local cQry := GetNextAlias()
Local cFilBkp := cFilAnt
Default cFilProc := cFilAnt
If !EMPTY(dDtBase) .AND. !EMPTY(cTurno) .AND. !EMPTY(cSeqBase) .AND. nDays < 0

    If LEN(AllTrim(cFilProc)) == LEN(Alltrim(cFilAnt))
        cFilAnt := cFilProc
    EndIf

	nAuxDia := DOW(dDtBase)
	
	BeginSQL Alias cQry
		SELECT DISTINCT PJ_SEMANA 
		  FROM %Table:SPJ% SPJ
		 WHERE SPJ.PJ_FILIAL = %xFilial:SPJ%
		   AND SPJ.%NotDel%
		   AND SPJ.PJ_TURNO = %Exp:cTurno%
	EndSQL
	
	While (cQry)->(!Eof())
		AADD(aSeqTno, (cQry)->(PJ_SEMANA))
		(cQry)->(DbSkip())
	End
	(cQry)->(DbCloseArea())
	
    If !EMPTY(aSeqTno) .AND. ASCAN(aSeqTno, cSeqBase) > 0
        While nDays < 0
            If nAuxDia - 1 == 1
                If 1 == ASCAN(aSeqTno, cSeqBase)
                    cSeqBase := aSeqTno[LEN(aSeqTno)]
                Else
                    cSeqBase := aSeqTno[(ASCAN(aSeqTno, cSeqBase) - 1)]
                EndIF
                nAuxDia--
            ElseIf nAuxDia - 1 == 0
                nAuxDia := 7
            Else
                nAuxDia--
            EndIf
            nDays++
        End
        cRet := cSeqBase
    EndIf
EndIf

cFilAnt := cFilBkp

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT790ADFer
@description Retorna a descrição do Feriado.
@return 
@author Augusto Albuquerque
@since  15/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT790ADFer()
Local oMdlFull	:= FwModelActive()
Local cCodAC0	:= oMdlFull:GetModel("AC0MASTER"):GetValue("AC0_CODIGO")
Local cQuery 	:= ""
Local cAliasQry	:= GetNextAlias()
Local cRet 		:= ""
Local dDataFer	:= FwFldGet("AC0_DTFER")

If !Empty(dDataFer)
	cQuery :=  ""
	cQuery += " SELECT RR0.RR0_DESC  "
	cQuery += " FROM " + RetSqlName( "AC0" ) + " AC0 "
	cQuery += " INNER JOIN " + RetSqlName( "RR0" ) + " RR0 "
	cQuery += " ON RR0.RR0_FILIAL = AC0.AC0_FILIAL "
	cQuery += " AND RR0.RR0_CODCAL = AC0.AC0_CODIGO "
	cQuery += " AND RR0.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE "
	cQuery += " AC0.AC0_FILIAL = '" + xFilial("AC0") + "' "
	cQuery += " AND AC0.AC0_CODIGO = '" + cCodAC0 + "' "
	cQuery += " AND AC0.D_E_L_E_T_ = ' ' "
	cQuery += " AND ( RR0.RR0_DATA = '" + DToS(dDataFer) + "' "
	cQuery += " OR ( RR0.RR0_MESDIA = '" + MesDia(dDataFer) + "'AND RR0.RR0_FIXO = 'S' ))"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	If !(cAliasQry)->(EOF())
		cRet := (cAliasQry)->(RR0_DESC)
	EndIf

	(cAliasQry)->(dbCloseArea())
EndIf

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At790AVld
@description Executa os Valids do Fonte.
@return 
@author Augusto Albuquerque
@since  15/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At790AVld( oModel )
Local lRet		:= .T.
Local oMdlAC0	:= oModel:GetModel("AC0MASTER")
Local oMdlTFF	:= oModel:GetModel("TFFDETAIL")
Local cCodAC0	:= oMdlAC0:GetValue("AC0_CODIGO")
Local cQuery 	:= ""
Local cAliasQry	:= GetNextAlias()

If oMdlTFF:IsEmpty()
	lRet := .F.
	If !IsBlind()
		Help(,,"At790AVld",, STR0026 ,1,0) // "Não foi possivel localizar nenhum posto!"
	EndIf
EndIf

If lRet
	cQuery :=  ""
	cQuery += " SELECT COUNT(RR0.RR0_DATA) TOTAL "
	cQuery += " FROM " + RetSqlName( "AC0" ) + " AC0 "
	cQuery += " INNER JOIN " + RetSqlName( "RR0" ) + " RR0 "
	cQuery += " ON RR0.RR0_FILIAL = AC0.AC0_FILIAL "
	cQuery += " AND RR0.RR0_CODCAL = AC0.AC0_CODIGO "
	cQuery += " AND RR0.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE "
	cQuery += " AC0.AC0_FILIAL = '" + xFilial("AC0") + "' "
	cQuery += " AND AC0.AC0_CODIGO = '" + cCodAC0 + "' "
	cQuery += " AND AC0.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
	If !(cAliasQry)->(EOF())
		If !(lRet := (cAliasQry)->(TOTAL) > 1)
			If !IsBlind()
				Help(,,"At790AVld",, STR0027 ,1,0) // "Não é possivel processar esse dia, pois, o calendario so possui um feriado valido e não é possivel alterar."
			EndIf
		EndIf
	EndIf

	(cAliasQry)->(dbCloseArea())
EndIf

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcIncCal
@description Processamento de inclusão de um feriado em uma nova data. Realiza manutenção do tipo cancelamento para o dia selecionado
@return 
@author Diego Bezerra
@since  15/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static function ProcIncCal(oModel, oDlg, oMeter)

Local oGsLog	:= GsLog():New(.T.)
Local oMdlAC0 	:= oModel:GetModel('AC0MASTER')		// Modelo de dados do cadastro de calendários
Local dData 	:= oMdlAC0:GetValue("AC0_FERREM")	// Nova data do feriado
Local dDataRef	:= oMdlAC0:GetValue("AC0_DTFER")    // Data original do feriado
Local cCodMan	:= oMdlAC0:GetValue("AC0_CODMAN")	// Código do tipo de manutenção
Local cCodCal	:= oMdlAC0:GetValue("AC0_CODIGO")	// Código do calendario
Local nCount 	:= 0
Local lLoadBar	:= .F.
Local aAgendas	:= {}
Local aErrors	:= {}
Local aErroMVC	:= {}
Local nX		:= 0
Local nZ		:= 0
Local lRet		:= .T.
Local cMsg		:=  ""

Default oDlg 	:= NIL
Default oMeter 	:= NIL

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

For nX := 1 To Len(aAtend)
	GetAgendas(aAtend[nX][3], aAtend[nX][2], dData, .F., @aAgendas)
Next nX

Begin Transaction

	// Realiza a inclusão do novo feriado no calendário
	lRet := copyAC0(dDataRef, cCodCal, dData, @aErrors, @aErroMVC)

	If lRet 
		For nX := 1 To Len(aAgendas)
			If lLoadBar
				oMeter:Set(++nCount)
				oMeter:Refresh()
			EndIf
			// Posicionar na ABB
			ABB->(DbSetOrder(8))
			lRet := ABB->(MsSeek(aAgendas[nX][1] + aAgendas[nX][2]))
			If lRet 
				At550SetAlias("ABB")
				At550SetGrvU(.T.)
				// Instanciar o modelo do teca550
				oMdl550 := FwLoadModel("TECA550")
				oMdl550:SetOperation( MODEL_OPERATION_INSERT)
				lRet := oMdl550:Activate()
				If lRet 
					// Setar o código da manutenção
					oMdl550:SetValue("ABRMASTER","ABR_MOTIVO", cCodMan)
					Begin Transaction
						// Realizar o commit dos dados
						If !oMdl550:VldData() .OR. !oMdl550:CommitData()
							// Salvando mensagens de erro do modelo
							aErroMVC := oMdl550:GetErrorMessage()
							CargaErroM(@aErrors, aErroMVC)
							oGsLog:addLog(STR0028, " ")	//"Inclusao de Feriado"        
							oGsLog:addLog(STR0028, " ------------------------------ ") //"Inclusao de Feriado"        
							oGsLog:addLog(STR0028, STR0011 + aAgendas[nX][8] + " -- "+;  //"Inclusao de Feriado" ## //"Atendente: "    
										STR0029 + DTOC(dData) + STR0030 + aAgendas[nX][4] + STR0031 + aAgendas[nX][5]) //"Data: " ## " de " ## " às "
							oGsLog:addLog(STR0028, " "+STR0029 + DTOC(dDataRef)) //"Inclusao de Feriado" ##  "Data: "
							oGsLog:addLog(STR0028, " "+ STR0032 + DTOC(dData)) 	 //"Inclusao de Feriado" ## "Não foi possível realizar o cancelamento da agenda para o dia do feriado de "
						Else
							oGsLog:addLog(STR0028, " ") //"Inclusao de Feriado"        
							oGsLog:addLog(STR0028, " ------------------------------ ") //"Inclusao de Feriado"        
							oGsLog:addLog(STR0028, STR0011 + aAgendas[nX][8] + " -- " + ; // "Inclusao de Feriado" ## //"Atendente: "        
										STR0029 + DTOC(dData) + STR0030 + aAgendas[nX][4] + STR0031 + aAgendas[nX][5]) //"Data: " ## " de " ## " às "
							oGsLog:addLog(STR0028, " " + STR0029 + DTOC(dData)) // "Data: "
							oGsLog:addLog(STR0028, STR0033 + DTOC(dDataRef)) //" Agenda cancelada por conta de remanejamento do feriado de "
						EndIf
					End Transaction
				EndIf
			Else
				oGsLog:addLog(STR0028, " ") //"Inclusao de Feriado"
				oGsLog:addLog(STR0028, " ------------------------------ ") //"Inclusao de Feriado"
				oGsLog:addLog(STR0028, STR0034 + aAgendas[nX][8] + " para a data " + DTOC(dData) ) //" Não foram encontradas agendas a serem canceladas para o atendente "
			EndIf
		Next nX
	EndIf
End Transaction

FWModelActive(oModel)
If !EMPTY(aErrors)
	For nX := 1 To LEN(aErrors)
		For nZ := 1 To LEN(aErrors[nX])
			cMsg += If(Empty(aErrors[nX][nZ]), aErrors[nX][nZ], aErrors[nX][nZ] + CRLF )
		Next nZ
		cMsg += CRLF + REPLICATE("-",30) + CRLF
	Next
	If !ISBlind()
		AtShowLog(cMsg, STR0035,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.)	//"Remanejamento de feriado"
	EndIf
EndIf

oGsLog:printLog(STR0028)//"Inclusao de Feriado"
If lRet .And. !IsBlind()
	MsgInfo(STR0016 + TxLogPath(ALLTRIM(cFilant) + STR0028)) //"Processamento concluido. Log gerado em: "
EndIf

If !isBlind()
	oDlg:End() 
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} copyAC0
@description Realiza a cópia de um feriado, incluindo em uma nova data
@return 
@author Diego Bezerra
@since  15/03/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function copyAC0(dDataRef, cCodAC0, dNewData, aErrors, aErroMVC)
Local aValue		:= {}
Local aFieldsRR0	:= {}
Local oMdl790		:= Nil
Local oStruRR0		:= Nil
Local oMdlRR0		:= Nil
Local lRet 			:= .T.
Local nX			:= 0

If AC0->(MSSeek( xFilial("AC0") + cCodAC0 ) )
	oMdl790	:= FwLoadModel("TECA790")
	oMdl790:SetOperation(MODEL_OPERATION_UPDATE)
	oMdl790:Activate()
	oMdlRR0 := oMdl790:GetModel("RR0DETAIL")
	If oMdlRR0:SeekLine({{ "RR0_DATA", dDataRef }},,.T. ) .OR.;
		oMdlRR0:SeekLine({{ "RR0_MESDIA", MesDia(dDataRef) }, { "RR0_FIXO", "S" }},,.T. )
		oStruRR0 := oMdlRR0:GetStruct()
		aFieldsRR0 := oStruRR0:GetFields()
		For nX := 1 To Len(aFieldsRR0)
			If !aFieldsRR0[nX][14] .AND. aFieldsRR0[nX][3] <> 'RR0_FILIAL'//Retirada dos campos virtuais
				AADD( aValue, {aFieldsRR0[nX][3], oMdlRR0:GetValue(aFieldsRR0[nX][3])})
			EndIf
		Next nX
	
		oMdlRR0:GoLine(oMdlRR0:Length())
		oMdlRR0:GoLine(oMdlRR0:AddLine())

	For nX := 1 To Len(aValue)
		If (aValue[nX][1] == 'RR0_FIXO')
			lRet := lRet .AND. oMdlRR0:LoadValue(aValue[nX][1], "N")
		ElseIf (aValue[nX][1] == 'RR0_DESC')
			lRet := lRet .AND. oMdlRR0:LoadValue(aValue[nX][1], "Remanejado do dia - " + DToC(dDataRef))
		ElseIf (aValue[nX][1] == 'RR0_DATA')
			lRet := lRet .AND. oMdlRR0:LoadValue(aValue[nX][1], dNewData)
		Else
			lRet := lRet .AND. oMdlRR0:LoadValue(aValue[nX][1], aValue[nX][2])
		EndIf
	Next nX

	If lRet .AND. !(oMdl790:VldData() .AND. oMdl790:CommitData())
		lRet := .F.
		aErroMVC := oMdl790:GetErrorMessage()
		CargaErroM(@aErrors, aErroMVC)
	EndIf
		oMdl790:DeActivate()
		oMdl790:Destroy()
	EndIf
EndIf
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At790APr
@description Chamando função estática para Automação  
@author Matheus.Gonçalves
@since  08/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At790APr(oModel)	
	ProcesCanc(oModel)
Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtPegaAg
@description Chamando função estática para Automação  
@author Matheus.Gonçalves
@since  09/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At790ATy(dDtBase, cTurno, cSeqBase, nDays)
	NextDayType(dDtBase, cTurno, cSeqBase, nDays)
Return	
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtPegaAg
@description Chamando função estática para Automação  
@author Matheus.Gonçalves
@since  09/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At790ADy(dDtBase, cTurno, cSeqBase, nDays)
	PreviousDay(dDtBase, cTurno, cSeqBase, nDays)
Return
