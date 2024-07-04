#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA203A.CH"

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

Static aCabec   := {}   //Array para popular o cabeçalho
Static aDados	:= {}	//Array para popular a tela de batidas

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados

@author	Luiz Gabriel
@since 27/09/2022
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	
Local oStrCab		:= FWFormModelStruct():New()
Local oStrGrd		:= FWFormModelStruct():New()
Local aFields		:= {}
Local nX			:= 0
Local nY			:= 0
Local aTables 		:= {}
Local bCommit		:= { |oModel| At203ACmt( oModel )}
Local bPreValid 	:= {|oMdlG,nLine,cAcao,cCampo, xValue, xOldValue| PreLinABB(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)}
Local bPosValid		:= {|oMdlG,nLine| PosLinABB(oMdlG, nLine)}

oStrCab:AddTable("   ",{}, STR0001) //"Ajuste de Marcação"
oStrGrd:AddTable("   ",{}, "   ")

AADD(aTables, {oStrCab, "CAB"}) //Tabela do cabeçalho
AADD(aTables, {oStrGrd, "GRD"}) //Tabela do Grid

For nY := 1 To LEN(aTables)
	aFields := AT203ABTbl(aTables[nY][2])

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

oModel := MPFormModel():New('TECA203A',/*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/)
oModel:AddFields('CABMASTER',/*cOwner*/,oStrCab,,/*bPosValidacao*/,/*bFieldAbp*/,/*bCarga*/,/*bFieldTfl*/)

oModel:addGrid('GRDDETAIL','CABMASTER',oStrGrd,bPreValid,bPosValid )

oModel:setDescription(STR0001) //"Ajuste de Marcação"

oModel:SetPrimaryKey({'CAB_CODTEC'})

oModel:GetModel('CABMASTER'):SetDescription(STR0001) //"Ajuste de Marcação"
oModel:GetModel('GRDDETAIL'):SetDescription(STR0002) //"Batidas do dia"

oModel:GetModel('CABMASTER'):SetOnlyView(.T.)
oModel:GetModel('CABMASTER'):SetOnlyQuery(.T.)
oModel:GetModel('GRDDETAIL'):SetOptional(.T.)

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

//Zera as teclas de atalho para evitar erro
SetKey(VK_F8, {||})
SetKey(VK_F10, {||})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	Luiz Gabriel
@since 27/09/2022
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil
Local oModel 	:= ModelDef()
Local oStrCab	:= FWFormViewStruct():New()
Local oStrGrd	:= FWFormViewStruct():New()
Local aTables 	:= {}
Local aFields	:= {}
Local nX		:= 0
Local nY		:= 0

AADD(aTables, {oStrCab, "CAB"}) //Tabela do cabeçalho
AADD(aTables, {oStrGrd, "GRD"}) //Tabela do Grid

For nY := 1 to LEN(aTables)
	aFields := AT203ABTbl(aTables[nY][2])

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

oStrGrd:RemoveField("GRD_ABBREC")

oView:AddField('VIEW_CAB', oStrCab, 'CABMASTER')

oView:AddGrid('VIEW_GRD',  oStrGrd, 'GRDDETAIL')
oView:EnableTitleView('VIEW_GRD', STR0002) //"Batidas do dia"

oView:CreateHorizontalBox('ATENDENTE',   20)
oView:CreateHorizontalBox('BATIDAS', 80)

oView:SetOwnerView('VIEW_CAB','ATENDENTE')
oView:SetOwnerView('VIEW_GRD','BATIDAS')

oView:SetDescription(STR0001) // "Ajuste de Marcação"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT203ABTbl

@description Retorna em forma de Array as definições dos campos

@param cTable, string, define de qual tabela devem ser os campos retornados

@return aRet, array, definição dos campos

@author	Luiz Gabriel
@since	27/09/2022
/*/
//------------------------------------------------------------------------------
Function AT203ABTbl(cTable)
Local aRet := {}
Local nAux := 0

If cTable == "CAB"  //Cabeçalho

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0003	 //"Cod. Atend"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0003 //"Cod. Atend"
	aRet[nAux][DEF_IDENTIFICADOR] := "CAB_CODATE"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0004}	//"Codigo do Atendente"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0005	 //"Nome Atend"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0005 //"Nome Atend"
	aRet[nAux][DEF_IDENTIFICADOR] := "CAB_NOMATE"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0006}	//"Nome do Atendente"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0007	//"Dt Referencia"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0007	//"Dt Referencia"
	aRet[nAux][DEF_IDENTIFICADOR] := "CAB_DTREF"
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

ElseIf cTable == "GRD" //Batidas do dia

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0008	//"Dt Batida"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0008	//"Dt Batida"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_DAT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0009	//"Dia da Semana"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0009	//"Dia da Semana"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_DOW"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 20
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0010	//"Dt Ini Prev"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0010	//"Dt Ini Prev"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_DTIPREV"
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
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0011 //"Hr Ent Prev"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0011 //"Hr Ent Prev"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_INPREV"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRINI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "99:99"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0012} //"Hora de Inicio Prevista"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0013 //"Hr Ent Rea"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0013 //"Hr Ent Rea"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_INREAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRINI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "99:99"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0014} //"Hora de Inicio Realizada"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0015	//"Dt Fim Prev"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0015	//"Dt Fim Prev"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_DTFPREV"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0016 //"Hr Sai Prev"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0016 //"Hr Sai Prev"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_OUTPREV"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRFIM")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := "99:99"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0017} //"Hora de Inicio Prevista"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0018 //"Hr Sai Rea"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0018 //"Hr Sai Rea"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_OUTREAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRFIM")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := "99:99"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0019} //"Hora de Inicio Realizada"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0020 //"Justificativa"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0020 //"Justificativa"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_JUSTIF"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "M"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "M"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_JUSTIF")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0021} //"Justificativa de ajuste de batida manual"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0022 //"Recno"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0022 //"Recno"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_ABBREC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 16
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "10"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0023} //"Recno da tabela ABB"

EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados

@description Bloco de código executado no activate
@param oModel, obj, modelo em ativação

@author	Luiz Gabriel
@since	27/09/2022
/*/
//------------------------------------------------------------------------------
Static Function InitDados(oModel)
Local oMdlCAB 	:= oModel:GetModel('CABMASTER')
Local oMdlGRD 	:= oModel:GetModel('GRDDETAIL')
Local aGrid 	:= {}
Local nX 		:= 0
Local nLinha 	:= 1

//Carrega o cabeçalho
oMdlCAB:LoadValue("CAB_CODATE", aCabec[1][2])
oMdlCAB:LoadValue("CAB_NOMATE", aCabec[2][2])
oMdlCAB:LoadValue("CAB_DTREF", aCabec[3][2])

//Carrega o grid com as agendas
If !Empty(aDados)
	aGrid := At203AGetD(aDados, oMdlCAB:GetValue("CAB_DTREF"))
	If Len(aGrid) > 0
		For nX := 1 To Len(aGrid)
			If nX > 1
				nLinha := oMdlGRD:AddLine()
			EndIf
			oMdlGRD:GoLine(nLinha)
			oMdlGRD:LoadValue("GRD_DAT", oMdlCAB:GetValue("CAB_DTREF"))
			oMdlGRD:LoadValue("GRD_DOW", TECCdow(DOW(oMdlCAB:GetValue("CAB_DTREF"))))
			oMdlGRD:LoadValue("GRD_DTIPREV",  oMdlCAB:GetValue("CAB_DTREF"))
			oMdlGRD:LoadValue("GRD_DTFPREV",  oMdlCAB:GetValue("CAB_DTREF"))
			oMdlGRD:LoadValue("GRD_INREAL", aGrid[nX][1])
			oMdlGRD:LoadValue("GRD_OUTREAL", aGrid[nX][2])
			oMdlGRD:LoadValue("GRD_INPREV", aGrid[nX][3])
			oMdlGRD:LoadValue("GRD_OUTPREV", aGrid[nX][4])
			oMdlGRD:LoadValue("GRD_ABBREC", aGrid[nX][5])
			oMdlGRD:LoadValue("GRD_JUSTIF", At203LdJust(aGrid[nX][5]))
		Next nX
		oMdlGRD:GoLine(1) 
	EndIf 
EndIf 	

//trava a criação de novas linhas e exclusão das linhas criadas
oMdlGRD:SetNoInsertLine(.T.)
oMdlGRD:SetNoDeleteLine(.T.)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinABB()

Função de Prevalidacao da grid de batidas

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Function PreLinABB(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)
Local lRet 			:= .T.
Local aSaveLines	:= FWSaveRows()
Local aArea			:= GetArea()
Local oStrGrd       := Nil

If cAcao == "CANSETVALUE"
	If cCampo == "GRD_OUTREAL" 
		If Empty( xOldValue )
			oStrGrd := oMdlG:GetStruct()
			oStrGrd:SetProperty("GRD_OUTREAL" , MODEL_FIELD_WHEN, {|| .T.} )
			oStrGrd:SetProperty("GRD_JUSTIF" , MODEL_FIELD_WHEN, {|| .T.} )
		EndIf 
	EndIf 

	If cCampo == "GRD_INREAL" 
		If Empty( xOldValue )
			oStrGrd := oMdlG:GetStruct()
			oStrGrd:SetProperty("GRD_INREAL" , MODEL_FIELD_WHEN, {|| .T.} )
			oStrGrd:SetProperty("GRD_JUSTIF" , MODEL_FIELD_WHEN, {|| .T.} )
		EndIf 
	EndIf 
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinABB()

Função de Posvalidacao do grid de batidas

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Function PosLinABB(oMdlG, nLine)
Local lRet	:= .T.

DbSelectArea("ABB")
ABB->(dbGoTo(oMdlG:GetValue("GRD_ABBREC")))				

If ABB->ABB_HRCHIN <> oMdlG:GetValue("GRD_INREAL") .Or. ABB->ABB_HRCOUT <> oMdlG:GetValue("GRD_OUTREAL")
	If Empty(oMdlG:GetValue("GRD_JUSTIF"))
		Help( , , "PosValida", , STR0024, 1, 0,,,,,,{STR0025}) //"O campo de justificativa deve ser preenchido"##"Preencha o campo de justificativa"
		lRet := .F.
	EndIf 
EndIf 

Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} Set203ACabec()

Seta Valores para o Cabeçalho na variavel statica aValores

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Function Set203ACabec(aValor)

aCabec := aValor

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Set203AGrid()

Seta Valores para o Grid de ajuste manual

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Function Set203AGrid(aValor)

aDados := aValor

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Set203ALimp()

Limpa as variaveis staticas

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Function Set203ALimp()
 aDados := {}
 aCabec := {}
Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203AGetD()

Realiza o filtro das agendas de acordo com a data de referencia para
preenchimento no grid

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Static Function At203AGetD(aAllGrid,dData)
Local aRet	:= {}
Local aAux	:= {}
Local nPos 	:= 0
Local nInd 	:= 0

nPos := AScan( aAllGrid, { |x| x[1] == DtoS(dData) })

While nPos > 0
	aAdd(aAux,AllTrim(aAllGrid[nPos][4])) //ABB_HRCHIN
	aAdd(aAux,AllTrim(aAllGrid[nPos][5])) //ABB_HRCOUT
	aAdd(aAux,AllTrim(aAllGrid[nPos][6])) //ABB_HRINI
	aAdd(aAux,AllTrim(aAllGrid[nPos][7])) //ABB_HRFIM
	aAdd(aAux,aAllGrid[nPos][11]) //Recno da ABB

	aAdd(aRet,aAux)
	aAux := {}
	nInd := nPos + 1
	nPos := 0
	nPos := AScan( aAllGrid, { |x| x[1] == DtoS(dData) }, nInd)
EndDo 

Return aRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203ACmt()

Realiza a gravação dos dados na ABB de acordo com os horarios alterados

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Function At203ACmt( oModel )
Local lRet		:= .T.
Local oMdlGRD 	:= oModel:GetModel('GRDDETAIL')
Local nX		:= 0
Local lJustf 	:= .F.

Begin Transaction
	DbSelectArea("ABB")
	For nX := 1 To oMdlGRD:Length()
		oMdlGRD:GoLine(nX)
		If oMdlGRD:IsUpdated(nX)
			ABB->(dbGoTo(oMdlGRD:GetValue("GRD_ABBREC")))				
				RecLock("ABB",.F.)		
						
				If ABB->ABB_HRCHIN <> oMdlGRD:GetValue("GRD_INREAL")
					ABB->ABB_CHEGOU := 'S'
					ABB->ABB_HRCHIN := oMdlGRD:GetValue("GRD_INREAL")
					lJustf := .T.
				EndIf 

				If ABB->ABB_HRCOUT <> oMdlGRD:GetValue("GRD_OUTREAL")
					ABB->ABB_SAIU := 'S'
					ABB->ABB_ATENDE := '1'
					ABB->ABB_HRCOUT := oMdlGRD:GetValue("GRD_OUTREAL")	
					lJustf := .T.
				EndIf
				If lJustf
					ABB->ABB_JUSTIF := oMdlGRD:GetValue("GRD_JUSTIF")
					lJustf := .F.
				EndIf 

				ABB->(MsUnlock())
		EndIf	 
	Next nX 
End Transaction

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203LdJust()

realiza o carregamento do campo de justificativa

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Static Function At203LdJust(nRecABB)
Local cMemo 	:= ""
Local aAreaABB	:= ABB->(GetArea())

DbSelectArea("ABB")
ABB->(dbGoTo(nRecABB))

If !Empty(ABB->ABB_JUSTIF)
	cMemo := ABB->ABB_JUSTIF
EndIf 

RestArea(aAreaABB)
Return cMemo
