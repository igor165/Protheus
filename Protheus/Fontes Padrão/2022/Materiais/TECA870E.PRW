#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA870E.ch"

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

Static aCtr870E := {}
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados

@author	Luiz Gabriel
@since 16/11/2021
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	
Local oStrFAK		:= FWFormModelStruct():New()
Local oStrCTR		:= FWFormModelStruct():New()
Local aFields		:= {}
Local nX			:= 0
Local nY			:= 0
Local aTables 		:= {}
Local bCommit		:= { |oModel| At870ECmt( oModel )}

oStrFAK:AddTable("   ",{}, STR0001) //"Seleção de Contratos"
oStrCTR:AddTable("   ",{}, "   ")

AADD(aTables, {oStrFAK, "FAK"})
AADD(aTables, {oStrCTR, "CTR"})

For nY := 1 To LEN(aTables)
	aFields := AT870ETbl(aTables[nY][2])

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

oModel := MPFormModel():New('TECA870E',/*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/)
oModel:AddFields('FAKMASTER',/*cOwner*/,oStrFAK,,/*bPosValidacao*/,/*bFieldAbp*/,/*bCarga*/,/*bFieldTfl*/)

oModel:addGrid('CTRMASTER','FAKMASTER',oStrCTR)

oModel:setDescription(STR0001) //"Seleção de Contratos"

oModel:GetModel('CTRMASTER'):SetDescription(STR0002) //"Contratos"

oModel:SetPrimarykey({})

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

//Não permite incluir e nem apagar registros no grid
oModel:GetModel('CTRMASTER'):SetNoInsertLine(.T.)
oModel:GetModel('CTRMASTER'):SetNoDeleteLine(.T.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	Luiz Gabriel
@since 16/11/2021
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil
Local oModel 	:= ModelDef()
Local oStrFAK	:= FWFormViewStruct():New()
Local oStrCTR	:= FWFormViewStruct():New()
Local aTables 	:= {}
Local aFields	:= {}
Local nX		:= 0
Local nY		:= 0

AADD(aTables, {oStrFAK, "FAK"})
AADD(aTables, {oStrCTR, "CTR"})

For nY := 1 to LEN(aTables)
	aFields := AT870ETbl(aTables[nY][2])

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

oView:AddField('VIEW_MASTER', oStrFAK, 'FAKMASTER')

oView:AddGrid('VIEW_CTR',  oStrCTR, 'CTRMASTER')
oView:EnableTitleView('VIEW_CTR', STR0002) //"Contratos"

oView:CreateHorizontalBox('DATA',   0)
oView:CreateHorizontalBox('Contratos', 100)

oView:SetOwnerView('VIEW_MASTER','DATA')
oView:SetOwnerView('VIEW_CTR','Contratos')

oView:SetDescription(STR0001) // "Seleção de Contratos"


Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870ETbl

@description Retorna em forma de Array as definições dos campos

@param cTable, string, define de qual tabela devem ser os campos retornados

@return aRet, array, definição dos campos

@author	Luiz Gabriel
@since	16/11/2021
/*/
//------------------------------------------------------------------------------
Function AT870ETbl(cTable)
Local aRet := {}
Local nAux := 0

If cTable == "FAK"  //Cabeçalho

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0003	//"Campo Fake"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0003	//"Campo Fake"
	aRet[nAux][DEF_IDENTIFICADOR] := "FAK_CAMPO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "1"}
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0003}	//"Campo Fake"

ElseIf cTable == "CTR" //Contratos

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0004	//"Mark"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0004	//"Mark"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_MARK"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "L"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "CHECK"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0005// "Filial do Contrato"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0005 // "Filial do Contrato"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_FILCTR"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN9_FILIAL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0005}	//"Filial do Contrato"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0006 // "Contrato"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0006 // "Contrato"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_CONTRT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN9_NUMERO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0006}	//"Contrato"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0007 // "Revisão"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0007 // "Revisão"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_REVISA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN9_REVISA")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0007}	//"Revisão"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0008 //"Entidade"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0008 //"Entidade"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_ENTIDA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFJ_CODENT")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0008}	//"Entidade"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0009	//"Loja"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0009	//"Loja"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_LOJA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFJ_LOJA")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
    aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .F. 

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0010	//"Nome"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0010 //"Nome"
	aRet[nAux][DEF_IDENTIFICADOR] := "CTR_NOME"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("A1_NOME")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
    aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .F. 

EndIf

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados()
Inicializa as informações da visualização dos contratos
@sample 	InitDados()

@param  	oModel, Objeto, objeto geral do model que será alterado

@author	Luiz Gabriel
@since	16/11/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function InitDados(oModel)
Local oMdlCTR  	:= oModel:GetModel("CTRMASTER")
Local oMdlFak   := oModel:GetModel("FAKMASTER")
Local cALiasCTR := GetNextAlias()
Local nLinha    := 0

oMdlCTR:SetNoInsertLine(.F.)
oMdlCTR:SetNoDeleteLine(.F.)

oMdlCTR:ClearData()
oMdlCTR:InitLine()

oMdlFak:SetValue("FAK_CAMPO", "2" )

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

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cALiasCTR, .F., .T.)

While !(cALiasCTR)->(EOF())
    If !oMdlCTR:IsEmpty()
		nLinha := oMdlCTR:AddLine()
	EndIf
	oMdlCTR:GoLine(nLinha)
    oMdlCTR:LoadValue( "CTR_FILCTR", (cALiasCTR)->(CN9_FILIAL) )
    oMdlCTR:LoadValue( "CTR_CONTRT", (cALiasCTR)->(TFJ_CONTRT) )
    oMdlCTR:LoadValue( "CTR_REVISA", (cALiasCTR)->(CN9_REVISA) )
    oMdlCTR:LoadValue( "CTR_ENTIDA",(cALiasCTR)->(TFJ_CODENT))
    oMdlCTR:LoadValue( "CTR_LOJA", (cALiasCTR)->(TFJ_LOJA))
    oMdlCTR:LoadValue( "CTR_NOME", (cALiasCTR)->(A1_NOME) )
    (cALiasCTR)->(dbSkip())
ENDDO

(cALiasCTR)->(dbCloseArea())
oMdlCTR:GoLine(1)

oMdlCTR:SetNoInsertLine(.T.)
oMdlCTR:SetNoDeleteLine(.T.)

Return(Nil)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870ECmt
@description Commit da seleção de contratos
@return lRet
@author	Luiz Gabriel
@since	16/11/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At870ECmt(oModel)

If !isBlind()
	FwMsgRun(Nil,{|| Commit870E(oModel) }, Nil, STR0011) //"Salvando contratos..."
Else
    Commit870E(oModel)
EndIf 

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Commit870E
@description armazena no array statico os contratos selecionados
@return lRet
@author	Luiz Gabriel
@since	16/11/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Commit870E( oModel )
Local oMdlCTR 	:= oModel:GetModel("CTRMASTER")
Local nX        := 0

For nX := 1 To oMdlCTR:Length()
    oMdlCTR:GoLine(nX)
    If oMdlCTR:GetValue("CTR_MARK")
        AAdd( aCtr870E, oMdlCTR:GetValue("CTR_CONTRT")) 
    EndIf
Next nX

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCont870E
@description Retorna o array com os conratos selecionados
@return aCtr870E
@author	Luiz Gabriel
@since	16/11/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function GetCont870E()

Return aCtr870E

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ClearCtr870E
@description Retorna o array com os conratos selecionados
@return aCtr870E
@author	Luiz Gabriel
@since	16/11/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function ClearCtr870E()

Return aCtr870E := {}
