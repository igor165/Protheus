#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA190E.ch"

Static aAgenA	:= {} //Array para guardar as informações da TGY do atendente A
Static aAgenB	:= {} //Array para guardar as informações da TGY do atendente B
Static nRecTGY	:= 0

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
/*/{Protheus.doc} TECA190D

@description Troca de Efetivo

@author	Luiz Gabriel
@since	18/09/2019
/*/
//------------------------------------------------------------------------------
Function TECA190E()

FWExecView("","VIEWDEF.TECA190E", MODEL_OPERATION_INSERT,,,,,)


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados

@author	Luiz Gabriel
@since 18/09/2019
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	
Local oStrDAT		:= FWFormModelStruct():New()
Local oStrAtA		:= FWFormModelStruct():New()
Local oStrAtB		:= FWFormModelStruct():New()
Local aFields		:= {}
Local nX			:= 0
Local nY			:= 0
Local aTables 		:= {}
Local bPosValidacao	:= {|oModel| At190EPos(oModel)}
Local bCommit		:= {|oModel| At190EGrav(oModel)}

//valida o SXB
If !IsBlind()
	ValidSXB()
EndIf

oStrDAT:AddTable("   ",{}, STR0001) //"Troca de Efetivo"
oStrAtA:AddTable("   ",{}, "   ")
oStrAtB:AddTable("   ",{}, "   ")

AADD(aTables, {oStrDAT, "DAT"})
AADD(aTables, {oStrAtA, "ATA"})
AADD(aTables, {oStrAtB, "ATB"})

For nY := 1 To LEN(aTables)
	aFields := AT190ETbl(aTables[nY][2])

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

//Gatilhos
xAux := FwStruTrigger( 'ATA_CODTEC', 'ATA_NOMTEC',;
	'Posicione("AA1",1,xFilial("AA1") + FwFldGet("ATA_CODTEC"),"AA1_NOMTEC")', .F. )
oStrAtA:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'ATB_CODTEC', 'ATB_NOMTEC',;
	'Posicione("AA1",1,xFilial("AA1") + FwFldGet("ATB_CODTEC"),"AA1_NOMTEC")', .F. )
oStrAtB:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

oModel := MPFormModel():New('TECA190E',/*bPreValidacao*/,bPosValidacao,bCommit,/*bCancel*/)
oModel:AddFields('DATMASTER',/*cOwner*/,oStrDAT,{|oMdlDat,cAction,cField,xValue, xOldValue| PreLinDat(oMdlDat,cAction,cField,xValue,xOldValue)},/*bPosValidacao*/,/*bFieldAbp*/,/*bCarga*/,/*bFieldTfl*/)

oModel:addFields('ATAMASTER','DATMASTER',oStrAtA)
oModel:addFields('ATBMASTER','DATMASTER',oStrAtB)

oModel:setDescription(STR0001) //"Troca de Efetivo"

oModel:SetPrimaryKey({'DAT_INI'})

oModel:GetModel('DATMASTER'):SetDescription(STR0001) //"Troca de Efetivo"
oModel:GetModel('ATAMASTER'):SetDescription(STR0002) //"Atendente A"
oModel:GetModel('ATBMASTER'):SetDescription(STR0003) //"Atendente B"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	Luiz Gabriel
@since 18/09/2019
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil
Local oModel 	:= ModelDef()
Local oStrDAT	:= FWFormViewStruct():New()
Local oStrAtA	:= FWFormViewStruct():New()
Local oStrAtB	:= FWFormViewStruct():New()
Local aTables 	:= {}
Local aFields	:= {}
Local nX		:= 0
Local nY		:= 0

AADD(aTables, {oStrDAT, "DAT"})
AADD(aTables, {oStrAtA, "ATA"})
AADD(aTables, {oStrAtB, "ATB"})

For nY := 1 to LEN(aTables)
	aFields := AT190ETbl(aTables[nY][2])

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

oView:SetContinuousForm()

oView:AddField('VIEW_MASTER', oStrDAT, 'DATMASTER')
oView:EnableTitleView('VIEW_MASTER', STR0004) //"Data Inicial"

oView:AddField('VIEW_ATA',  oStrAtA, 'ATAMASTER')
oView:EnableTitleView('VIEW_ATA', STR0002) //"Atendente A"

oView:AddField('VIEW_ATB',  oStrAtB, 'ATBMASTER')
oView:EnableTitleView('VIEW_ATB', STR0003) //"Atendente B"

oView:CreateHorizontalBox( 'DATA' , 30 )
oView:CreateHorizontalBox('AtendA'	, 35)
oView:CreateHorizontalBox('AtendB'	, 35)

oView:SetOwnerView('VIEW_MASTER','DATA')
oView:SetOwnerView('VIEW_ATA','AtendA')
oView:SetOwnerView('VIEW_ATB','AtendB')

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190ETbl

@description Retorna em forma de Array as definições dos campos

@param cTable, string, define de qual tabela devem ser os campos retornados

@return aRet, array, definição dos campos

@author	Luiz Gabriel
@since	18/09/2019
/*/
//------------------------------------------------------------------------------
Function AT190ETbl(cTable)
Local aRet := {}
Local nAux := 0
Local lMV_MultFil := TecMultFil() //Indica se considera multiplas filiais

If cTable == "DAT"  //Cabeçalho
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0004 //"Data Inicial"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0004 //"Data Inicial"
	aRet[nAux][DEF_IDENTIFICADOR] := "DAT_INI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|| At190EVldDt() }
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.	
	aRet[nAux][DEF_HELP] := {STR0005}	//"Data de Referencia para realização da Troca"
	
ElseIf cTable == "ATA" //Atendente A

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] :=  TecTituDes("AA1_CODTEC")  //"Codigo do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] :=  TecTituDes("AA1_CODTEC", .F.) //"Codigo do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "ATA_CODTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "T19AA1"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|| At190EAte("ATAMASTER")}
	aRet[nAux][DEF_HELP] := {STR0006} //"Codigo do Atendente A para realização da troca"
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes("AA1_NOMTEC")  //"Nome Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes("AA1_NOMTEC", .F.) //"Nome Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "ATA_NOMTEC"
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

	If lMV_MultFil	

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0030	//"Filial da Alocação"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0030 //"Filial da Alocação"
		aRet[nAux][DEF_IDENTIFICADOR] := "ATA_FILIAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_FILIAL")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "03"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0030}	//"Filial da Alocação"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0031	//"Código do Contrato"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0031 //"Código do Contrato"
		aRet[nAux][DEF_IDENTIFICADOR] := "ATA_CONTRT"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_CONTRT")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "04"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0031}	//"Código do Contrato"
	
	Endif

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0007 //"Local de Atendimento"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0007 //"Local de Atendimento"
	aRet[nAux][DEF_IDENTIFICADOR] := "ATA_LOCAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_LOCAL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0008} //"Código do Local de Atendimento"
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes("ABS_DESCRI")  //"Descrição do local"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes("ABS_DESCRI", .F.) //"Descrição do local"
	aRet[nAux][DEF_IDENTIFICADOR] := "ATA_NOMLOC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_DESCRI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0009	//"Posto"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0009 //"Posto"
	aRet[nAux][DEF_IDENTIFICADOR] := "ATA_POSTO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_COD")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0010}	//"Código do Posto"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0037	//"Turno"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0037 //"Turno"
	aRet[nAux][DEF_IDENTIFICADOR] := "ATA_TURNO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_TURNO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0038 	//"Sequência" 
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0038  //"Sequência" 
	aRet[nAux][DEF_IDENTIFICADOR] := "ATA_SEQ"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_SEQ")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_LOOKUP] := "T19ASE" //At190dCons("SEQ_A")
	aRet[nAux][DEF_HELP] := {STR0039}	//"Sequência do Turno" 

ElseIf cTable == "ATB" //Atendente B
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes("AA1_CODTEC")  //"Codigo do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes("AA1_CODTEC", .F.) //"Codigo do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "ATB_CODTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "T19AA1"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|| At190EAte("ATBMASTER")}	
	aRet[nAux][DEF_HELP] := {STR0011}	//"Código do atendente cadastrado no 'Gestão de Serviços'"
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes("AA1_NOMTEC") //"Nome Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes("AA1_NOMTEC", .F.) //"Nome Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "ATB_NOMTEC"
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

	If lMV_MultFil	

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0030	//"Filial da Alocação"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0030 //"Filial da Alocação"
		aRet[nAux][DEF_IDENTIFICADOR] := "ATB_FILIAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_FILIAL")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "03"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0030}	//"Filial da Alocação"

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0031	//"Código do Contrato"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0031//"Código do Contrato"
		aRet[nAux][DEF_IDENTIFICADOR] := "ATB_CONTRT"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_CONTRT")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "04"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
		aRet[nAux][DEF_HELP] := {STR0031}	//"Código do Posto"
	
	Endif
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0007 //"Local de Atendimento"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0007 //"Local de Atendimento"
	aRet[nAux][DEF_IDENTIFICADOR] := "ATB_LOCAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_LOCAL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0008} //"Código do Local de Atendimento"	
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes("ABS_DESCRI") //"Descrição do local"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes("ABS_DESCRI", .F.) //"Descrição do local"
	aRet[nAux][DEF_IDENTIFICADOR] := "ATB_NOMLOC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_DESCRI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0009 //"Posto"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0009 //"Posto"
	aRet[nAux][DEF_IDENTIFICADOR] := "ATB_POSTO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_COD")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0010}	//"Código do Posto"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0037	//"Turno"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0037 //"Turno"
	aRet[nAux][DEF_IDENTIFICADOR] := "ATB_TURNO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_TURNO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0038	//"Sequência" 
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0038 //"Sequência" 
	aRet[nAux][DEF_IDENTIFICADOR] := "ATB_SEQ"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_SEQ")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_LOOKUP] := "T19BSE" //At190dCons("SEQ_A")
	aRet[nAux][DEF_HELP] := {STR0039}	//"Sequência do Turno"

EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190EAte

@description Verifica se o Atendente tem Alocação em mais de 1 posto
e smanutenções

@param cIdMdl, Caracter, Id do modelo a ser validado

@return lRet, Logico, Indica se o atendente pode ser selecionado

@author	Luiz Gabriel
@since	18/09/2019
/*/
//------------------------------------------------------------------------------
Function At190EAte(cIdMdl)
Local oView		:= iif(!IsBlind(), FwViewActive(), NIL)
Local oModel	:= FwModelActive()
Local oMdlAte	:= NIL
Local cAliQry 	:= GetNextAlias()
Local cMsg 		:= ""
Local lRet 		:= .T. 
Local cIdcFal 	:= ""
Local aIdCFal 	:= ""
Local aAloc 	:= {}
Local cCodAtend	:= ""
Local dDataIni	:= Ctod("")
Local cCodTFF	:= ""
Local cCodTFL	:= ""
Local lAllHE	:= .T.
Local lMV_MultFil := TecMultFil()
Local cCodCtr	:= ""
Local cFIlTGY	:= ""
Local cWhere	:= ""
Local cFilBkp 	:= cFilAnt
Local cFiTFFTGY := FWJoinFilial("TGY","TFF","TGY","TFF",.T.)
Local cFiTFLTFF := FWJoinFilial("TFF","TFL","TFF","TFL",.T.)
Local cJoinAA1	:= ""

If	ValType(oModel) == "O" .AND. oModel:IsActive() .AND. oModel:GetId() == "TECA190E"
	dDataIni	:= oModel:GetValue("DATMASTER","DAT_INI")

	oMdlAte := oModel:GetModel(cIdMdl)
	
	If cIdMdl == "ATAMASTER"
		cCodAtend	:= oMdlAte:GetValue("ATA_CODTEC")
	ElseIf cIdMdl == "ATBMASTER"
		cCodAtend	:= oMdlAte:GetValue("ATB_CODTEC")
	EndIf
	
	//Se campo estiver vazio limpa os outros campos
	If Empty(cCodAtend)
		If cIdMdl == "ATAMASTER"
			oMdlAte:LoadValue("ATA_NOMTEC","")
			oMdlAte:LoadValue("ATA_LOCAL","")
			oMdlAte:LoadValue("ATA_NOMLOC","")
			oMdlAte:LoadValue("ATA_POSTO","")
			oMdlAte:LoadValue("ATA_TURNO","")
			oMdlAte:LoadValue("ATA_SEQ","")

			WhensATX(.F.)

			If lMV_MultFil
				oMdlAte:LoadValue("ATA_FILIAL","")
				oMdlAte:LoadValue("ATA_CONTRT","")
			Endif
			
			If !IsBlind()
				oView:Refresh('VIEW_ATA')
			EndIf			
		ElseIf cIdMdl == "ATBMASTER"
			oMdlAte:LoadValue("ATB_NOMTEC","")
			oMdlAte:LoadValue("ATB_LOCAL","")
			oMdlAte:LoadValue("ATB_NOMLOC","")
			oMdlAte:LoadValue("ATB_POSTO","")
			oMdlAte:LoadValue("ATB_TURNO","")
			oMdlAte:LoadValue("ATB_SEQ","")
			
			WhensATX(.F.)

			If lMV_MultFil
				oMdlAte:LoadValue("ATB_FILIAL","")
				oMdlAte:LoadValue("ATB_CONTRT","")
			Endif

			If !IsBlind()
				oView:Refresh('VIEW_ATB')
			EndIf		
		EndIf
	EndIf
	
	lRet := !Empty(cCodAtend) .And. At190Exist("AA1",cCodAtend,1)
	
	If lRet
		
		If !lMV_MultFil
			cWhere 	  := " TGY.TGY_FILIAL = '" + xFilial("TGY") + "' AND "
			cFiTFFTGY := " TFF.TFF_FILIAL = '" + xFilial("TFF") + "'"
			cFiTFLTFF := " TFL.TFL_FILIAL = '" + xFilial("TFL") + "'"
		Else
			cJoinAA1 := " JOIN "+RetSqlName("AA1")+" AA1 ON AA1.AA1_FILIAL = '" + xFilial("AA1") + "'"
			cJoinAA1 +=	" AND AA1.AA1_CODTEC =  '" + cCodAtend + "'"
			cJoinAA1 +=	" AND AA1.D_E_L_E_T_ = ''"
		Endif
		
		cWhere 	  := "%"+cWhere+"%"
		cFiTFFTGY := "%"+cFiTFFTGY+"%"
		cFiTFLTFF := "%"+cFiTFLTFF+"%"
		cJoinAA1  := "%"+cJoinAA1+"%"
		
		//verifica se o atendente está alocado no posto no período
		BeginSql Alias cAliQry
		
			Select TGY.TGY_CODTFF,
					TGY.TGY_CODTDX,
					TGY.TGY_ATEND,
					TGY.TGY_SEQ,
					TGY.TGY_ESCALA,
					TGY.TGY_DTINI,
					TGY.TGY_DTFIM,
					TGY.R_E_C_N_O_,	
					TFL.TFL_LOCAL,
					TGY.TGY_FILIAL,
					TFF.TFF_CONTRT
			FROM %Table:TGY% TGY
				JOIN %Table:TFF% TFF ON %Exp:cFiTFFTGY%
					AND TFF.%NotDel%
					AND TFF.TFF_COD = TGY.TGY_CODTFF
				JOIN %Table:TFL% TFL ON %Exp:cFiTFLTFF%
			  		AND TFL.%NotDel%
			  		AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
				%Exp:cJoinAA1%
			Where 
				(TGY.TGY_DTFIM >=  %exp:dDataIni% AND TGY.TGY_DTINI <= %exp:dDataIni%  OR
				TGY.TGY_DTFIM >=  %exp:dDataIni% AND TGY.TGY_DTINI >= %exp:dDataIni%)  AND
				(TFF.TFF_PERFIM >=  %exp:dDataIni% AND TFF.TFF_PERINI <= %exp:dDataIni% )  AND
				TGY.TGY_ATEND = %Exp:cCodAtend% AND
				TGY.TGY_TIPALO = '001' AND
				%Exp:cWhere%
				TGY.%NotDel%
			ORDER BY TGY_ULTALO DESC
		EndSql
		
		If (cAliQry)->(EOF())
			lRet := .F.
			cMsg := STR0012 //"Atendente não possui alocação neste período ou não é um Atendente efetivo"
		Else
			
			cFIlTGY	:= (cAliQry)->(TGY_FILIAL)
			cCodCtr := (cAliQry)->(TFF_CONTRT)

			If lMV_MultFil .And. cFilAnt != cFIlTGY
				cFilAnt := cFIlTGY
			EndIf

			Do While (cAliQry)->(!Eof())
				If aScan(aAloc, { |a|  (cAliQry)->TGY_CODTFF  == a[1] .And. (cAliQry)->TGY_CODTDX  == a[3] .And. (cAliQry)->TGY_ATEND  == a[4]}) = 0
					aAdd(aAloc, {(cAliQry)->TGY_CODTFF,(cAliQry)->TFL_LOCAL,;
					 			(cAliQry)->TGY_CODTDX,(cAliQry)->TGY_ATEND,;
					 			(cAliQry)->TGY_SEQ,(cAliQry)->TGY_ESCALA,;
					 			(cAliQry)->(R_E_C_N_O_),(cAliQry)->TGY_DTFIM,;
					 			(cAliQry)->TGY_DTINI} )
				EndIf 
				 (cAliQry)->(DbSkip(1))
			EndDo
		
		EndIf
		
		If Len(aALoc) == 1 .And. aAloc[01, 09] == dToS(dDataIni)
			lRet := .F.
			cMsg := STR0029 //"Não é possivel realizar a troca no primeiro dia de agenda"
		EndIf
		
		If lRet .and. Len(aAloc) == 1
			
			(cAliQry)->(dbCloseArea())
			
			cCodTFF := aAloc[01, 01]
			cCodTFL := aAloc[01, 02]
			cCodEscala := aAloc[01, 06]
			cCodSeq	:= aAloc[01, 05]

			aIdCFal :=  GetAdvFVal("ABQ",{"ABQ_CONTRT", "ABQ_ITEM", "ABQ_ORIGEM"}, xFilial("ABQ")+cCodTFF+xFilial("TFF"),3  , {"", "", ""})
			
			cIdCFal := aIdCFal[01]+aIdCFal[02]+aIdCFal[03]
			
				//Verifica se existe agenda com manutenção/atendida no período para o Posto ou se o atendente possui agenda para outro posto no período
				
				BeginSql Alias cAliQry
					Column TDV_DTREF as Date
					Select 
						TDV.TDV_DTREF, 
						ABB.ABB_CODTEC, 
						ABB.ABB_HRINI, 
						ABB.ABB_HRFIM, 
						ABB.ABB_ATENDE, 
						ABB.ABB_MANUT, 
						ABB.ABB_IDCFAL,
						ABQ.ABQ_CODTFF,
						CASE WHEN ABN.ABN_TIPO IS NULL THEN ' '
							ELSE ABN.ABN_TIPO END AS ABN_TIPO
					From 				 
						%Table:ABB% ABB
						INNER JOIN %Table:TDV%  TDV ON TDV.TDV_FILIAL = %xFilial:TDV% AND
							TDV.TDV_CODABB = ABB.ABB_CODIGO AND
							TDV.%NotDel%
						INNER JOIN %Table:ABQ%  ABQ ON (			ABQ.ABQ_CONTRT||ABQ.ABQ_ITEM ||	ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL AND
																	ABQ.ABQ_FILIAL = %xFilial:ABQ% AND
																	ABQ.%NotDel%	)
						LEFT JOIN %Table:ABR% ABR ON ABR.ABR_FILIAL = %xFilial:ABR% AND
							ABR.%NotDel% AND
							ABR.ABR_AGENDA = ABB.ABB_CODIGO
						LEFT JOIN %Table:ABN% ABN ON ABN.ABN_FILIAL = %xFilial:ABN% AND
							ABN.%NotDel% AND
							ABN.ABN_CODIGO = ABR.ABR_MOTIVO
					Where
						( ( ( ABB.ABB_ATENDE = '1'  OR ABB.ABB_MANUT  = '1' OR ABB.ABB_CHEGOU = 'S') AND 
									ABB_IDCFAL =  %Exp:cIdCFal%    )  OR  
									(  ABB.ABB_IDCFAL <>  %Exp:cIdCFal%   ) ) AND
						TDV.TDV_DTREF >= %exp:dDataIni% AND
						ABB.ABB_CODTEC =  %Exp:cCodAtend% AND
						ABB.ABB_FILIAL = %xFilial:ABB% AND
						ABB.%NotDel%
					ORDER BY TDV.TDV_DTREF,ABQ.ABQ_CODTFF,ABB.ABB_HRINI
				EndSql
					
				lAllHE := .T.
				
				While (cAliQry)->(!Eof())
					If (cAliQry)->(ABN_TIPO) != "04"
						lAllHE := .F.
						Exit
					EndIf
					(cAliQry)->(DbSkip())
				End
				
				(cAliQry)->(DbGoTop())
				
				If  !(cAliQry)->(Eof()) .AND. !lAllHE
					lRet := .F.
					
					cMsg := STR0013 //"Encontrada(s) agenda(s) que inviabiliza(m) a troca de efetivo no período "
					
					Do While (cAliQry)->(!Eof())
						
						cMsg += CRLF + STR0014+ DtoC((cAliQry)->TDV_DTREF)+;   //"Data de Referência: "
						IIF((cAliQry)->ABB_IDCFAL<>cIdCFal ,CRLF+STR0015+(cAliQry)->ABQ_CODTFF, "")+CRLF+; //"Agenda em outro posto: "
						STR0016+ (cAliQry)->(ABB_HRINI +"~" + ABB_HRFIM)+CRLF+; //"Horário: "
						STR0017+ IIF((cAliQry)->ABB_MANUT ="1", STR0027, STR0028)+CRLF+; //"Manutenção: " //Sim##Não
						STR0018+ IIF((cAliQry)->ABB_ATENDE="1", STR0027, STR0028)
						
						(cAliQry)->(DbSkip())
						
					EndDo	
				
				Else
					//Informa o Local e Posto para o campo
					If cIdMdl == "ATAMASTER"
						oMdlAte:LoadValue("ATA_LOCAL",cCodTFL)
						oMdlAte:LoadValue("ATA_NOMLOC",Posicione("ABS",1,xFilial("ABS") + cCodTFL,"ABS_DESCRI"))
						oMdlAte:LoadValue("ATA_POSTO",cCodTFF)
						
						If !Empty(oModel:GetValue("ATBMASTER", "ATB_CODTEC"))
							InfoSeq(dDataIni, oModel, oModel:GetValue("ATBMASTER", "ATB_CODTEC"), "ATA", aAloc[1][6], aAloc[1][5])
							InfoSeq(dDataIni, oModel, oModel:GetValue("ATAMASTER", "ATA_CODTEC"), "ATB", aAgenB[1][6], aAgenB[1][5])
							WhensATX(.T.)
						EndIf
						If lMV_MultFil							
							oMdlAte:LoadValue("ATA_FILIAL",cFilTGY)
							oMdlAte:LoadValue("ATA_CONTRT",cCodCtr)
						Endif
						
						//Realiza a copia do aray para criação da TGY
						aAgenA := AClone(aAloc)
						
					ElseIf cIdMdl == "ATBMASTER"
						oMdlAte:LoadValue("ATB_LOCAL",cCodTFL)
						oMdlAte:LoadValue("ATB_NOMLOC",Posicione("ABS",1,xFilial("ABS") + cCodTFL,"ABS_DESCRI"))
						oMdlAte:LoadValue("ATB_POSTO",cCodTFF)	

						If !Empty(oModel:GetValue("ATBMASTER", "ATB_CODTEC"))
							InfoSeq(dDataIni, oModel, oModel:GetValue("ATBMASTER", "ATB_CODTEC"), "ATA", aAgenA[1][6], aAgenA[1][5])
							InfoSeq(dDataIni, oModel, oModel:GetValue("ATAMASTER", "ATA_CODTEC"), "ATB", aAloc[1][6], aAloc[1][5])
							WhensATX(.T.)
						EndIf

						If lMV_MultFil
							oMdlAte:LoadValue("ATB_FILIAL",cFilTGY)
							oMdlAte:LoadValue("ATB_CONTRT",cCodCtr)
						Endif
						
						//Realiza a copia do aray para criação da TGY
						aAgenB := AClone(aAloc)
										
					EndIf
				EndIf
		
		ElseIf lRet .And. Len(aAloc) > 1
			lRet := .F.
			cMsg := STR0019 //"Atendente possui mais de uma alocação neste período em postos distintos "
		EndIf
		
		(cAliQry)->(dbCloseArea())
		
		If lMV_MultFil .And. cFilBkp != cFilAnt
			cFilAnt := cFilBkp
		EndIf
	Else
		cMsg := STR0020 //"Atendente selecionado é Inválido"
	EndIf
	
	If !lRet
		Help(,,"At190EAte",,cMsg,1,0)
	EndIf

EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190EPos

@description Validação do modelo de dados

@param oModel, Objeto, Modelo de dados

@return lRet, Logico, Indica se o tudo está correto e pode ser realizado a troca

@author	Luiz Gabriel
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Function At190EPos(oModel)
Local lRet		:= .T.
Local oMdlDAT	:= oModel:GetModel("DATMASTER")
Local oMdlATA	:= oModel:GetModel("ATAMASTER")
Local oMdlATB	:= oModel:GetModel("ATBMASTER")
Local cMsg		:= ""

//Verifica se a data está preenchida
If Empty(oMdlDAT:GetValue("DAT_INI"))
	lRet := .F.
	cMsg := STR0021 //"Preencha a data inicial para realização da troca de efetivos"
EndIf

If lRet .And. (Empty(oMdlATA:GetValue("ATA_CODTEC")) .Or. Empty(oMdlATB:GetValue("ATB_CODTEC")))
	lRet := .F.
	cMsg := STR0022 //"Selecione o Atendente para realização da troca"
EndIf

If lRet .And. oMdlATA:GetValue("ATA_CODTEC") == oMdlATB:GetValue("ATB_CODTEC")
	lRet := .F.
	cMsg := STR0023 //"Os Atendentes selecionados devem ser diferentes para realização da troca de efetivo"
EndIf

If !lRet
	Help(,,"At190EPos",,cMsg,1,0)
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190EGrav

@description Realiza a gravação das agendas

@return lRet, Logico, Indica se a gravação foi feita com sucesso

@author	Luiz Gabriel
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function At190EGrav(oModel)

Local lRet	:= .T.

Begin Transaction
	If !IsBlind()
		FwMsgRun(Nil,{|| lRet := TrocaAten(oModel)}, Nil, STR0024) //"Ajustando as Agendas dos atendente"
	Else
		lRet := TrocaAten(oModel)
	EndIf
End Transaction

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TrocaAten

@description Função para realizar a troca das agendas dos atendentes

@param oModel - Modelo de dados

@return lRet, Logico, Indica se a gravação foi feita com sucesso

@author	Luiz Gabriel
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function TrocaAten(oModel)
Local cCodAtend 	:= ""
Local dData 		:= ""
Local cCodTFF 		:= ""
Local cMsg			:= ""
Local nC 			:= 0
Local nRecA			:= 0
Local nRecB			:= 0
Local lMV_MultFil 	:= TecMultFil()
Local cFIlTGYA		:= ""
Local cFIlTGYB		:= ""
Local cFilBkp 		:= cFilAnt

At190eGSRc(0)

//Realiza a exclusão da agenda dos atendentes
For nC := 1 to 2
	dData :=  oModel:GetValue("DATMASTER", "DAT_INI")
	If nC = 1
		cCodAtend :=  oModel:GetValue("ATAMASTER", "ATA_CODTEC")
		cCodTFF := oModel:GetValue("ATAMASTER", "ATA_POSTO")
		If lMV_MultFil
			cFilTGYA := oModel:GetValue("ATAMASTER", "ATA_FILIAL")
			If cFilAnt != cFilTGYA
				cFilAnt := cFilTGYA
			EndIf
		Endif
	Else
		cCodAtend :=  oModel:GetValue("ATBMASTER", "ATB_CODTEC")
		cCodTFF := oModel:GetValue("ATBMASTER", "ATB_POSTO")
		If lMV_MultFil
			cFilTGYB := oModel:GetValue("ATBMASTER", "ATB_FILIAL")
			If cFilAnt != cFilTGYB
				cFilAnt := cFilTGYB
			EndIf
		Endif
	EndIf
	
	cMsg := ""
	
	lRet := At190ExAg(cCodAtend, dData, cCodTFF, @cMsg)
	
	If !lRet
		DisarmTransaction()
		Help(,,"At190ExAg",,cMsg,1,0)
		Exit
	EndIf
Next nC

If lRet
	AT330ArsSt(,.T.)
	If lMV_MultFil .And. cFilAnt != cFIlTGYB
		cFilAnt := cFIlTGYB
	EndIf
	//Ajusta a TGY do B para o A
	lRet := AjustaTGY(aAgenA[1][4],aAgenB[1][1],aAgenB[1][6],aAgenB[1][3],aAgenB[1][5],dData,aAgenB[1][7], @nRecA)	
	If lRet
		If lMV_MultFil .And. cFilAnt != cFIlTGYA
			cFilAnt := cFIlTGYA
		EndIf
		//Ajusta a TGY do A para o B
		lRet := AjustaTGY(aAgenB[1][4],aAgenA[1][1],aAgenA[1][6],aAgenA[1][3],aAgenA[1][5],dData,aAgenA[1][7], @nRecB)		
		If lRet
			If lMV_MultFil .And. cFilAnt != cFIlTGYB
				cFilAnt := cFIlTGYB
			EndIf
			//Aloca o atendente A
			At190eGSRc(nRecA)
			lRet := At330AloAut(, , , , , , dData, STOD(aAgenB[1][8]), , , , , , , aAgenA[1][4],aAgenB[1][1], , , , , , oModel:GetValue("ATAMASTER", "ATA_SEQ") )
			If lRet			
				If lMV_MultFil .And. cFilAnt != cFIlTGYA
					cFilAnt := cFIlTGYA
				EndIf
				//Aloca atendente B
				At190eGSRc(nRecB)
				lRet := At330AloAut(, , , , , , dData, STOD(aAgenA[1][8]), , , , , , , aAgenB[1][4],aAgenA[1][1], , , , , , oModel:GetValue("ATBMASTER", "ATB_SEQ") )
			EndIf	
		EndIf	
	EndIf
EndIf

At190eGSRc(0)

If !lRet
	DisarmTransaction()
EndIf

If lMV_MultFil .And. cFilAnt != cFilBkp
	cFilAnt := cFilBkp
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaTGY

@description Função para realizar o ajuste da TGY dos atendentes

@param cCodAten - código do atendente para ter a agenda ajustada
@param cCodTFF - Código do posto que terá ajuste
@param cEscala - Código da escala a ser ajustada
@param cCodTDX - Código da TDX a ser ajustada
@param cSeqTur - Sequencia do turno a ser ajustada
@param dDataIni - data inicial a ser considerada para ajuste
@param nRecno - numero do Recno para ser copiada

@return lRet, Logico, Indica se a troca no TGY foi realizada com sucesso

@author	Luiz Gabriel
@since	29/05/2019
/*/
//------------------------------------------------------------------------------
Static Function AjustaTGY(cCodAten,cCodTFF,cEscala,cCodTDX,cSeqTur,dDataIni,nRecno,nNewRec)
Local lRet			:= .T.
Local aArea			:= GetArea()
Local oMdl580e  	:= Nil
Local oMdlTDX   	:= Nil
Local oMdlTGY		:= Nil
Local aDados		:= {}
Local nX			:= 0
Local lUsaEscala	:= .F.
Local lMV_GSGEHOR 	:= SuperGetMV("MV_GSGEHOR",,.F.)
Local cMsg			:= ""
Default nNewRec := 0

At190EVlrTGY(nRecno,@aDados,dDataIni)

DbSelectArea("TFF")
TFF->(DbSetOrder(1))

If TFF->(DBSeek(xFilial("TFF") + cCodTFF)) 	
	
	If lMV_GSGEHOR
		lUsaEscala := VldEscala(0, cEscala, cCodTFF)
	EndIf
	
	At580EGHor(lUsaEscala)
	
	oMdl580e := FwLoadModel("TECA580E")
	oMdl580e:SetOperation(MODEL_OPERATION_UPDATE)
	oMdl580e:Activate()
			
	oMdlTDX := oMdl580e:GetModel("TDXDETAIL")
	oMdlTGY := oMdl580e:GetModel("TGYDETAIL")

	At580VdFolder({1})

	If oMdlTDX:SeekLine({{ "TDX_COD", cCodTDX }})		

		oMdlTGY:GoLine(oMdlTGY:Length())

		If !Empty(oMdlTGY:GetValue("TGY_ATEND"))
			oMdlTGY:AddLine()
		Endif
		
		If Empty(oMdlTGY:GetValue("TGY_ATEND"))
			
			oMdlTGY:LoadValue("TGY_ITEM",TecXMxTGYI(cEscala, cCodTDX, cCodTFF)) 
			For nX := 1 To Len(aDados)
				If aDados[nX][1] $ "TGY_GRUPO|TGY_DTINI|TGY_DTFIM|TGY_TIPALO"
					lRet := oMdlTGY:SetValue(aDados[nX][1],aDados[nX][2])
				Else
					If !Empty(aDados[nX][2])
						lRet := oMdlTGY:LoadValue(aDados[nX][1],aDados[nX][2])
					Endif
				EndIf
				If !lRet
					Exit
				EndIf
			Next nX
			
			If lRet
				lRet := oMdlTGY:SetValue("TGY_ATEND", cCodAten)
			EndIf			

			If lRet
				If oMdl580e:VldData() .And. oMdl580e:CommitData()
					nNewRec := TGY->(RECNO())
					oMdl580e:DeActivate()
					oMdl580e:Destroy()
				Else
					If oMdl580e:HasErrorMessage()
						lRet := .F.
						AtErroMvc( oMdl580e )
						If !IsBlind()
							MostraErro()
						EndIf
					Else 
						cMsg := STR0032 + cCodAten //"Problemas na gravação das configurações do atendente "
						lRet := .F.
					EndIf	
				EndIf
			Else
				cMsg := STR0033 + cCodAten //"Problemas na inclusão das informações de configuração para o atendente "
			EndIf

		Else
			lRet := .F.
			cMsg := STR0034 + cCodAten //"Problemas na inclusão de uma nova linha para o atendente "
		Endif
				
	Else
		lRet := .F.
		cMsg := STR0035 + cCodAten //"Não foi encontrado o codigo do turno para o atendente "
	EndIf
	
	oMdl580e:DeActivate()
	oMdl580e:Destroy()
	
	//Ajusta a data final da alocação
	If lRet
		TGY->(DBGoTo(nRecno))
		TGY->(RECLOCK("TGY", .F.))
			If TGY->TGY_DTINI > dDataIni
				TGY->TGY_DTINI := dDataIni-1
			EndIf
			TGY->TGY_DTFIM := dDataIni-1
		TGY->(MSUNLOCK())
	EndIf
Else
	lRet := .F.
	cMsg := STR0036 + cCodAten
EndIf

If !lRet .And. !Empty(cMsg)
	Help(,,"AjustaTGY",,cMsg,1,0)
EndIf 

RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190ExAg

@description Realiza a exclusão das agendas dos atendentes

@param cCodAtend - Código do atendente que terá a agenda excluida
@param dDataIni - Data inicial a ser considerada para exclusão
@param cCodTFF - codigo do posto que terá a agenda excluida
@param cMsg - Mensagem de erro

@return lRet, Logico, Indica se a exclusão foi feita com sucesso

@author	Luiz Gabriel
@since	18/09/2019
/*/
//------------------------------------------------------------------------------
Function At190ExAg(cCodAtend, dDataIni, cCodTFF, cMsg)
Local lRet := .T.
Local cAliQry := GetNextAlias()
Local aMarks := {}
Local aBkpMarks := {}

Default cMsg := ""

aMarks := {}

BeginSql Alias cAliQry
	 Column ABB_DTINI as Date
	 Column ABB_DTFIM as Date
	 Column ABB_DTREF as Date

	 Select TDV.TDV_DTREF AS ABB_DTREF,
	 		ABB.ABB_CODIGO,
	 		ABB.ABB_DTINI,
	 		ABB.ABB_DTFIM,
	 		ABB.ABB_CODTEC,
	 		ABB.ABB_HRINI,
	 		ABB.ABB_HRFIM,
	 		ABB.ABB_ATENDE,
	 		ABB.ABB_CHEGOU,
	 		ABB.ABB_MANUT,
	 		ABB.ABB_IDCFAL,
	 		ABQ.ABQ_CODTFF,
			ABB.ABB_FILIAL 
	 From
	 	%Table:TDV% TDV,
	 	%Table:ABQ% ABQ,
	 	%Table:ABB% ABB
	 Where
	 	ABB.ABB_CODIGO = TDV.TDV_CODABB AND
	 	TDV.TDV_DTREF >= %exp:dDataIni% AND
	 	TDV.TDV_FILIAL = %xFilial:TDV% AND
	 	TDV.%NotDel% AND
	 	ABQ.ABQ_CONTRT||ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL AND
	 	ABB.ABB_CODTEC =  %Exp:cCodAtend% AND
	 	ABB.ABB_FILIAL = %xFilial:ABB% AND
	 	ABB.%NotDel% AND
	 	ABQ.ABQ_CODTFF = %exp:cCodTFF% AND
	 	ABQ.ABQ_FILIAL = %xFilial:ABQ% AND
	 	ABQ.%NotDel%
	 ORDER BY TDV.TDV_DTREF, ABB.ABB_DTINI, ABB.ABB_HRINI, ABB.ABB_DTFIM
	 
EndSql

Do While ! (cAliQry)->(Eof())
	
	AADD(aMarks, {(cAliQry)->ABB_CODIGO,;
		(cAliQry)->ABB_DTINI,;
		(cAliQry)->ABB_HRINI,;
		(cAliQry)->ABB_DTFIM,;
		(cAliQry)->ABB_HRFIM,;
		(cAliQry)->ABB_ATENDE,;
		(cAliQry)->ABB_CHEGOU,;
		(cAliQry)->ABB_IDCFAL,;
		(cAliQry)->ABB_DTREF,;
		.F.,;
		(cAliQry)->ABQ_CODTFF,;
		(cAliQry)->ABB_FILIAL})
	
	(cAliQry)->(DbSkip(1))

EndDo

(cAliQry)->(DbCloseArea())

If Len(aMarks) > 0
	aBkpMarks := AClone(At190DSMar())
	
	At190DSMar(aMarks)
	lRet := At190DDlt2(.F., .T., cCodAtend, @cMsg)
	
	At190DSMar(aBkpMarks)
EndIf	
 				
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190EVldDt

@description Função para validar o campo de data

@author	Luiz Gabriel
@since	18/09/2019
/*/
//------------------------------------------------------------------------------
Static Function At190EVldDt()
Local lRet		:= .T.
Local oModel 	:= FwModelActive()
Local dDataIni	:= Nil

If	ValType(oModel) == "O" .AND. oModel:IsActive() .AND. oModel:GetId() == "TECA190E"

	dDataIni	:= oModel:GetValue("DATMASTER", "DAT_INI")

	If Empty(dDataIni)
		Help(,,"DAT_INI",,STR0026,1,0) //"Informe a Data de Troca de Efetivo"
		lRet := .F.
	EndIf

EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinDat

@description campo para zeras os valores quando a data é alterada

@param oMdlDat - Modelo de dados a ser validado
@param cAction - Ação ocorrida na validação
@param cField - campo a ser validado
@param xValue - Valor atual do campo
@param xOldValue - valor anterior do campo

@author	Luiz Gabriel
@since	18/09/2019
/*/
//------------------------------------------------------------------------------
Static Function PreLinDat(oMdlDat,cAction,cField,xValue,xOldValue)
Local oModel		:= FwModelActive()
Local lMV_MultFil 	:= TecMultFil() //Indica se considera multiplas filiais

If VALTYPE(oMdlDat) == 'O' .AND. oMdlDat:GetId() == "DATMASTER"
	If cField == "DAT_INI" .AND. cAction == "SETVALUE"
		If xValue <> oMdlDat:GetValue("DAT_INI") .AND. !Empty(oMdlDat:GetValue("DAT_INI"))
			//Mudou a Data, zera os campos para validar novamente
			If lMV_MultFil
				oModel:LoadValue("ATAMASTER","ATA_FILIAL","")
			EndIf	
			oModel:LoadValue("ATAMASTER", "ATA_CODTEC","")
			oModel:LoadValue("ATAMASTER", "ATA_NOMTEC","")
			oModel:LoadValue("ATAMASTER", "ATA_LOCAL","")
			oModel:LoadValue("ATAMASTER", "ATA_NOMLOC","")
			oModel:LoadValue("ATAMASTER", "ATA_POSTO","")
			oModel:LoadValue("ATAMASTER", "ATA_FILIAL","")
			oModel:LoadValue("ATAMASTER", "ATA_CONTRT","")
			oModel:LoadValue("ATAMASTER", "ATA_TURNO","")
			oModel:LoadValue("ATAMASTER", "ATA_SEQ","")
			
			If lMV_MultFil
				oModel:LoadValue("ATBMASTER","ATB_FILIAL","")
			EndIf	
			oModel:LoadValue("ATBMASTER", "ATB_CODTEC","")
			oModel:LoadValue("ATBMASTER", "ATB_NOMTEC","")
			oModel:LoadValue("ATBMASTER", "ATB_LOCAL","")
			oModel:LoadValue("ATBMASTER", "ATB_NOMLOC","")
			oModel:LoadValue("ATBMASTER", "ATB_POSTO","")
			oModel:LoadValue("ATBMASTER", "ATB_FILIAL","")
			oModel:LoadValue("ATBMASTER", "ATB_CONTRT","")
			oModel:LoadValue("ATBMASTER", "ATB_TURNO","")
			oModel:LoadValue("ATBMASTER", "ATB_SEQ","")

			WhensATX(.F.)
			
		EndIf
	EndIf
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190EVlrTGY

@description Função retornar os valores da TGY a ser gravada

@param nRecno - numero do Recno para ser copiada
@param aDados - Array contendo os valores a serem copiados
@param dDataIni - numero do Recno para ser copiada

@author	Luiz Gabriel
@since	18/09/2019
/*/
//------------------------------------------------------------------------------
Static Function At190EVlrTGY(nRecno,aDados,dDataIni)
Local aArea	:= GetArea()
Local nC

TGY->(DBGoTo(nRecno))

aAdd(aDados,{"TGY_DTINI", dDataIni})
aAdd(aDados,{"TGY_DTFIM", TGY->TGY_DTFIM})
aAdd(aDados,{"TGY_GRUPO", TGY->TGY_GRUPO})
aAdd(aDados,{"TGY_TIPALO", TGY->TGY_TIPALO})
aAdd(aDados,{"TGY_TURNO", TGY->TGY_TURNO})
aAdd(aDados,{"TGY_SEQ", TGY->TGY_SEQ})

If TecXHasEdH()
	For nC := 1 to 4
		aAdd(aDados,{"TGY_ENTRA"+ Str(nC, 1), &("TGY->TGY_ENTRA"+ Str(nC, 1))})
		aAdd(aDados,{"TGY_SAIDA"+ Str(nC, 1), &("TGY->TGY_SAIDA"+ Str(nC, 1))})
	Next
EndIf

RestArea(aArea)

Return aDados
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190eGSRc

@description Função de Get/Set da Static nRecTGY
@param nSetValue, int, valor que substituirá o valor da variavel nRecTGY
@return nRecTGY, int, variavel Static declarada

@author	Mateus Boiani
@since	15/10/2019
/*/
//------------------------------------------------------------------------------
Function At190eGSRc(nSetValue)
If VALTYPE(nSetValue) == 'N'
	nRecTGY := nSetValue
EndIf
Return nRecTGY

//------------------------------------------------------------------------------
/*/{Protheus.doc} InfoSeq

@description Função para pegar a sequencia e turno da TDV
@return Nil

@author	Augusto Albuquerque
@since	11/09/2020
/*/
//------------------------------------------------------------------------------
Static Function InfoSeq( dData, oMdlFull, cCodTec, cIdMdl, cCodEscala, cCodSeq )
Local cQuery 	:= ""
Local cAliasTDV	:= GetNextAlias()
Local aSeqs		:= {}
Local oMdlATE	:= oMdlFull:GetModel(cIdMdl+"MASTER")
Local nPosDt	:= 0

cQuery := ""
cQuery += " SELECT TDV.TDV_TURNO, TDV.TDV_SEQTRN, TDV.TDV_DTREF "
cQuery += " FROM " + RetSqlName("TDV") + " TDV "
cQuery += " INNER JOIN " + RetSqlName("ABB") + " ABB "
cQuery += " ON ABB.ABB_FILIAL = '" + xFilial("ABB") + "' " 
cQuery += " AND ABB.ABB_CODIGO = TDV.TDV_CODABB "
cQuery += " AND ABB.ABB_CODTEC = '" + cCodTec + "' "
cQuery += " AND ABB.D_E_L_E_T_ = '' "
cQuery += " WHERE "
cQuery += " TDV.TDV_FILIAL = '" + xFilial("TDV") + "' "
cQuery += " AND TDV.TDV_DTREF BETWEEN '" + DToS(dData - 3) + "' AND '" + DToS(dData + 3) + "' " 
cQuery += " AND TDV.D_E_L_E_T_ = '' "
cQuery += " ORDER BY TDV_DTREF "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTDV, .F., .T.)

While ((cAliasTDV)->(!EOF()))
	AADD(aSeqs, {(cAliasTDV)->TDV_TURNO,;
				(cAliasTDV)->TDV_SEQTRN,;
				(cAliasTDV)->TDV_DTREF})
	
	(cAliasTDV)->(dbSkip())
End

(cAliasTDV)->(dbCloseArea())

If Len(aSeqs) > 0
	nPosDt := Ascan(aSeqs, {|x| x[3] == DToS(dData)})

	If nPosDt > 0
		oMdlATE:LoadValue(cIdMdl+"_TURNO", aSeqs[nPosDt][1])
		oMdlATE:LoadValue(cIdMdl+"_SEQ", aSeqs[nPosDt][2])
	Else
		oMdlATE:LoadValue(cIdMdl+"_TURNO", aSeqs[1][1])
		oMdlATE:LoadValue(cIdMdl+"_SEQ", aSeqs[1][2])
	EndIf
Else
	oMdlATE:LoadValue(cIdMdl+"_TURNO", cCodEscala)
	oMdlATE:LoadValue(cIdMdl+"_SEQ", cCodSeq)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} WhensATX

@description Função para travar os campos de sequencia no grid
@return Nil

@author	Augusto Albuquerque
@since	11/09/2020
/*/
//------------------------------------------------------------------------------
Static Function WhensATX( lAberto )
Local oModel := FwModelActive()
Local oView := FwViewActive()
Local oMdlATA := oModel:GetModel("ATAMASTER")
Local oMdlATB := oModel:GetModel("ATBMASTER")
Local oStrATA := oMdlATA:GetStruct()
Local oStrATB := oMdlATB:GetStruct()

Default lAberto := .F.

oStrATA:SetProperty("ATA_SEQ", MODEL_FIELD_WHEN, {|| lAberto})

oStrATB:SetProperty("ATB_SEQ", MODEL_FIELD_WHEN, {|| lAberto})

If !IsBlind() .AND. VALTYPE(oView) == 'O'
	oView:Refresh('VIEW_ATA')
	oView:Refresh('VIEW_ATB')
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidSXB()

Realiza a validação das consultas.

aVldSXB[nX,1] = Consulta
aVldSXB[nX,2] = Tipo da consulta
aVldSXB[nX,3] = Descrição
aVldSXB[nX,4] = Tabela
aVldSXB[nX,5] = Expressão
aVldSXB[nX,6] = Retorno

@author Luiz Gabriel
@since 21/09/2020
/*/
//------------------------------------------------------------------------------
Static Function ValidSXB()
Local lRet 		:= .T.
Local nX		:= 0
Local cMsgSXB	:= ""
Local aArea		:= GetArea()
Local aVldSXB	:= {{"T19ASE",STR0040,STR0041	,"SPJ",'At190dCons("SEQ_A")'		,"At190dRF3()"},;	//"Consulta Específica" # "Sequência."
					{"T19BSE",STR0040,STR0041	,"SPJ",'At190dCons("SEQ_B")'		,"At190dRF3()"}}	//"Consulta Específica" # "Sequência."

DbSelectArea("SXB")
SXB->(DbSetOrder(1))

For nX := 1 To Len(aVldSXB)
	If !SXB->(DbSeek(aVldSXB[nX,1]))

		If Empty(cMsgSXB)
			cMsgSXB := STR0042 + "(SXB):"+CRLF+CRLF //"Realize a inclusão da Consulta Padrão - "
		Endif

		cMsgSXB += STR0043 + aVldSXB[nX,1]+CRLF			//"Consulta: "
		cMsgSXB += STR0044 + aVldSXB[nX,2]+CRLF			//"Tipo da consulta: "
		cMsgSXB += STR0045 + aVldSXB[nX,3]+CRLF			//"Descrição: "
		cMsgSXB += STR0046 + aVldSXB[nX,4]+CRLF			//"Tabela: "
		cMsgSXB += STR0047 + aVldSXB[nX,5]+CRLF			//"Expressão: "
		cMsgSXB += STR0048 + aVldSXB[nX,6]+CRLF+CRLF	//"Retorno: "

	Endif
Next nX

If !Empty(cMsgSXB)
	AtShowLog(cMsgSXB,STR0049, .T., .T., .F.)	//"Inconsistência na Consulta Padrão."
	lRet := .F.
Endif

RestArea(aArea)

Return lRet
