#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA581A.CH"

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

#DEFINE NPOS_CODROTA    1	//Codigo da Rota
#DEFINE NPOS_CODATEND	2	//Codigo do Atendente
#DEFINE NPOS_PERINI		3	//Período incial
#DEFINE NPOS_PERFIM		4	//Período final

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA581A - Mesa Operacional - Compensação
 	ModelDef
 		Definição do modelo de Dados

@author	Luiz Gabriel
@since	29/07/2020
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oStrCAB	:= FWFormModelStruct():New()
Local oStrFAC	:= FWFormModelStruct():New()
Local oStrMOV	:= FWFormModelStruct():New()
Local aTables 	:= {}
Local nX        := 0
Local nY        := 0
Local bCommit	:= { |oModel| At581AGrav( oModel ) }
Local bValid	:= { |oModel| At581AVld( oModel )}

oStrCAB:AddTable("   ",{}, STR0001) //"Movimentação em Lote"
oStrFAC:AddTable("   ",{}, "   ")
oStrMOV:AddTable("   ",{}, "   ")

AADD(aTables, {oStrCAB, "CAB"})
AADD(aTables, {oStrFAC, "FAC"})
AADD(aTables, {oStrMOV, "MOV"})

For nY := 1 To LEN(aTables)
	aFields := AT581ADef(aTables[nY][2])

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

//Gatilhos dos filtros
xAux := FwStruTrigger( 'CAB_ATEND', 'CAB_NOME',;
	'Posicione("AA1",1,xFilial("AA1") + FwFldGet("CAB_ATEND"),"AA1_NOMTEC")', .F. )
	oStrCAB:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

//Gatilhos do Grid
xAux := FwStruTrigger( 'MOV_ATEND', 'MOV_NOME',;
	'Posicione("AA1",1,xFilial("AA1") + FwFldGet("MOV_ATEND"),"AA1_NOMTEC")', .F. )
	oStrMOV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])	

xAux := FwStruTrigger( 'MOV_COD', 'MOV_DESC',;
	'Posicione("TW0",1,xFilial("TW0") + FwFldGet("MOV_COD"),"TW0_DESC")', .F. )
	oStrMOV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])    

oModel := MPFormModel():New('TECA581A',/*bPreValid*/,bValid,bCommit,/*bCancel*/)
oModel:SetDescription( STR0001 ) //""Movimentação em Lote""

oModel:addFields('CABMASTER',,oStrCAB, {|oMdlCAB,cAction,cField,xValue| PreLinCAB(oMdlCAB,cAction,cField,xValue)})
oModel:SetPrimaryKey({"CAB_ATEND"})

oModel:addFields('FACDETAIL','CABMASTER',oStrFAC)
oModel:addGrid('MOVDETAIL','CABMASTER', oStrMOV )

oModel:GetModel('CABMASTER'):SetDescription(STR0002) //"Filtros" 
oModel:GetModel('FACDETAIL'):SetDescription(STR0003) //"Facilitador" 
oModel:GetModel('MOVDETAIL'):SetDescription(STR0004) //"Itens da Rota"

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

//Não permite incluir e nem apagar registros no grid
oModel:GetModel('MOVDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('MOVDETAIL'):SetNoDeleteLine(.T.)

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados

@description Bloco de código executado no activate
@param oModel, obj, modelo em ativação

@author	Luiz Gabriel
@since	29/07/2020
/*/
//------------------------------------------------------------------------------
Static Function InitDados(oModel)
Local oMdlCAB := oModel:GetModel('CABMASTER')

oMdlCAB:SetValue("CAB_DTMOV",dDataBase)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	Luiz Gabriel
@since 29/07/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 		:= ModelDef()
Local oView
Local aTables 		:= {}
Local aFields       := {}
Local oStrCAB		:= FWFormViewStruct():New()
Local oStrFAC		:= FWFormViewStruct():New()
Local oStrMOV		:= FWFormViewStruct():New()
Local nX
Local nY
Local ATMCAB		:= {}
Local ATMFAC		:= {}
Local ATMBTN		:= {}
Local ATMMOV		:= {}
Local lMonitor		:= IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366

AADD(aTables, {oStrCAB, "CAB"})
AADD(aTables, {oStrFAC, "FAC"})
AADD(aTables, {oStrMOV, "MOV"})

For nY := 1 to LEN(aTables)
	aFields := AT581ADef(aTables[nY][2])

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

If !lMonitor
	//Cabeçalho
	AADD(ATMCAB, 18)

	//Facilitadores
	AADD(ATMFAC, 12)

	//Botões
	AADD(ATMBTN, 7)
	AADD(ATMBTN, 08.75)
	AADD(ATMBTN, 09.00)
	AADD(ATMBTN, 83.00)

	//Movimentações
	AADD(ATMMOV, 63)
Else
	
	//Cabeçalho
	AADD(ATMCAB, 30)

	//Facilitadores
	AADD(ATMFAC, 15)

	//Botões
	AADD(ATMBTN, 10)
	AADD(ATMBTN, 08.75)
	AADD(ATMBTN, 09.00)
	AADD(ATMBTN, 83.00)

	//Movimentações
	AADD(ATMMOV, 45)

EndIf

oStrMOV:RemoveField("MOV_INITGY")
oStrMOV:RemoveField("MOV_FIMTGY")
oStrMOV:RemoveField("MOV_MOVIM")

oView:AddField('VIEW_MASTER', oStrCAB, 'CABMASTER')
oView:AddField('VIEW_FAC', oStrFAC, 'FACDETAIL')
oView:AddGrid('VIEW_MOV',  oStrMOV, 'MOVDETAIL')


oView:CreateHorizontalBox('COMP_CAB' , ATMCAB[1] )
oView:CreateHorizontalBox('COMP_FAC' , ATMFAC[1] )
oView:CreateHorizontalBox('BOTOES'	 , ATMBTN[1] )
oView:CreateHorizontalBox('COMP_MOV' , ATMMOV[1] )

oView:CreateVerticalBox( "LEFT_1",  ATMBTN[2], 'BOTOES')
oView:CreateVerticalBox( "LEFT_2",  ATMBTN[3], 'BOTOES')
oView:CreateVerticalBox( "LEFT_3",  ATMBTN[4], 'BOTOES')

oView:SetOwnerView('VIEW_MASTER','COMP_CAB')
oView:SetOwnerView( 'VIEW_FAC' , 'COMP_FAC')
oView:SetOwnerView('VIEW_MOV','COMP_MOV')

oView:AddOtherObject("MARK",{|oPanel| a581aAllM(oPanel) })
oView:SetOwnerView("MARK","LEFT_1")

oView:AddOtherObject("BUSCA",{|oPanel| At581ASrc(oPanel) })
oView:SetOwnerView("BUSCA","LEFT_2")

oView:EnableTitleView('VIEW_MASTER',STR0002) //"Filtros"
oView:EnableTitleView('VIEW_FAC',STR0003) //"Facilitador"
oView:EnableTitleView('VIEW_MOV',STR0006) //"Movimentação"

oView:SetDescription(STR0001) //"Movimentação em Lote"

oView:showInsertMsg(.F.)

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT581ADef

@description Retorna em forma de Array as definições dos campos
@param cTable, string, define de qual tabela devem ser os campos retornados
@return aRet, array, definição dos campos

@author	Luiz Gabriel
@since	29/07/2020
/*/
//------------------------------------------------------------------------------
Function AT581ADef(cTable)
Local aRet		:= {}
Local nAux 		:= 0
Local cDescri	:= "X3_DESCRIC"

If cTable == "CAB"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TW0_DESC", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TW0_DESC", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "CAB_DESC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache( "TW0_DESC", "X3_TAMANHO" )
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "TW0_DESC", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .T. )  //"Codigo do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .F. ) //"Codigo do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "CAB_ATEND"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "AA1"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0005} //"Código do Atendente"                                                                          
	
    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TW0_NOME", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TW0_NOME", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "CAB_NOME"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache( "TW0_NOME", "X3_TAMANHO" )
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "TW0_NOME", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TW0_TIPO", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TW0_TIPO", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "CAB_TIPO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache( "TW0_TIPO", "X3_TAMANHO" )
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| " "}
	aRet[nAux][DEF_LISTA_VAL] := { " ", "1="+STR0007, "2="+STR0008, "3="+STR0009} //"Folguista"##"Almocista"##"Jantista"
	aRet[nAux][DEF_COMBO_VAL] := { " ", "1="+STR0007, "2="+STR0008, "3="+STR0009} //"Folguista"##"Almocista"##"Jantista"
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "TW0_TIPO", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0010 //"Dt. Movimentação"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0010 //"Dt. Movimentação"
	aRet[nAux][DEF_IDENTIFICADOR] := "CAB_DTMOV"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0011} //"Data da movimentação"

ElseIf cTable == "FAC"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0012 //"Per. Ini."
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0012 //"Per. Ini."
	aRet[nAux][DEF_IDENTIFICADOR] := "FAC_DTINI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0013} //"Data Inicial para a movimentação da Rota"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0014 //"Per. Fin."
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0014 //"Per. Fin."
	aRet[nAux][DEF_IDENTIFICADOR] := "FAC_DTFIM"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0015} //"Data Final para a movimentação da Rota"
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At581aAtd(oMdl,cField,xNewValue)}

ElseIf cTable == "MOV"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := " "	//"Mark"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := " "	//"Mark"
	aRet[nAux][DEF_IDENTIFICADOR] := "MOV_MARK"
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
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TW0_COD", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TW0_COD", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "MOV_COD"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache( "TW0_COD", "X3_TAMANHO" )
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "TW0_COD", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0016}	//"Código da rota de cobertura a ser movimentada"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TW0_DESC", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TW0_DESC", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "MOV_DESC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache( "TW0_DESC", "X3_TAMANHO" )
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "TW0_DESC", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0017//"Dt Ini"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0018//"Data Inicial"
	aRet[nAux][DEF_IDENTIFICADOR] := "MOV_DTINI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0019} //"Data Inicial para a movimentação da Rota"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0020 //"Dt Fim"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "Data Final" //"Data Final"
	aRet[nAux][DEF_IDENTIFICADOR] := "MOV_DTFIM"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0022} //"Data Final para a movimentação da Rota"
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At581aAtd(oMdl,cField,xNewValue)}

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "MOV_ATEND"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache( "AA1_CODTEC", "X3_TAMANHO" )
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "AA1_CODTEC", "X3_PICTURE" )
    aRet[nAux][DEF_LOOKUP] := "AA1"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At581aAtd(oMdl,cField,xNewValue)}

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TW0_NOME", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TW0_NOME", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "MOV_NOME"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := GetSX3Cache( "TW0_NOME", "X3_TAMANHO" )
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "TW0_NOME", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0023 //"Dt Ini"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0024 //"Data Inicial"
	aRet[nAux][DEF_IDENTIFICADOR] := "MOV_INITGY"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0025} //"Data Inicial da TGY"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0026 //"Dt Ini"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0027 //"Data Inicial"
	aRet[nAux][DEF_IDENTIFICADOR] := "MOV_FIMTGY"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0028} //"Data Final TGY"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0029	//"Movimentado"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0029	//"Movimentado"
	aRet[nAux][DEF_IDENTIFICADOR] := "MOV_MOVIM"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "L"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "L"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "10"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	If TW1->(ColumnPos("TW1_FILTFF") > 0)
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_FILIAL", .T. )  //"Numero do Contrato"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_FILIAL", .F. )  //"Numero do Contrato"
		aRet[nAux][DEF_IDENTIFICADOR] := "MOV_FILTFF"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := Len(cFilAnt)
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "11"
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .F.
	EndIf

EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} a581aAllM

@description Cria o botão "Marcar Todos"
@param oPanel, obj, dialog em que o botão será criado

@author	Luiz Gabriel
@since	29/07/2020
/*/
//------------------------------------------------------------------------------
Static Function a581aAllM(oPanel)

TButton():New( (oPanel:nHeight / 2) - 13, 5, STR0030 , oPanel, { || At581AMrk() },43,12,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Marcar ## Desmarcar Todos"

Return ( Nil )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581AMrk

@description Marca/Desmarca todos os campos MOV_MARK

@author	Luiz Gabriel
@since	29/07/2020
/*/
//------------------------------------------------------------------------------
Static Function At581AMrk()
Local oModel 	:= FwModelActive()
Local oView  	:= FwViewActive()
Local oMdlMOV	:= oModel:GetModel('MOVDETAIL')
Local nLine		:= oMdlMOV:GetLine()
Local nX		:= 0

If !(oMdlMOV:isEmpty())
	For nX := 1 To oMdlMOV:Length()
		oMdlMOV:GoLine(nX)
		oMdlMOV:SetValue("MOV_MARK", !(oMdlMOV:GetValue("MOV_MARK")))
	Next nX

	oMdlMOV:GoLine(nLine)
	If !IsBlind()
		oView:Refresh()
	EndIf
EndIf

Return (.T.)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581ASrc

@description Cria o botão "Buscar"
@param oPanel, obj, dialog em que o botão será criado

@author	Luiz Gabriel
@since	29/07/2020
/*/
//------------------------------------------------------------------------------
Static Function At581ASrc(oPanel)

TButton():New( (oPanel:nHeight / 2) - 13, 5, STR0031, oPanel, { || FwMsgRun(Nil,{|| lRet := BuscaRota()}, Nil, STR0032) },50,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Buscar" #Processando

Return ( Nil )

//------------------------------------------------------------------------------
/*/{Protheus.doc} BuscaRota

@description Função para buscar as rotas de cobertura de acordo com o filtro

@author	Luiz Gabriel
@since 29/07/2020
/*/
//------------------------------------------------------------------------------
Static Function BuscaRota()
Local oModel	:= FwModelActive()
Local oView		:= FwViewActive()
Local oMdlCAB	:= oModel:GetModel("CABMASTER")
Local oMdlFAC	:= oModel:GetModel("FACDETAIL")
Local oMdlMOV 	:= oModel:GetModel("MOVDETAIL")
Local nLinha 	:= 0
Local cAliasRot	:= GetNextAlias()	
Local cWhere 	:= "%"
Local lDtIni	:= .F.
Local lDtFim	:= .F.

//Verifica se os campos de facilitadores estão preenchidos
If !Empty(oMdlFAC:GetValue("FAC_DTINI"))
	lDtIni := .T.
EndIf 

If !Empty(oMdlFAC:GetValue("FAC_DTFIM"))
	lDtFim	:= .T.
EndIf 

//Cria os filtros para carregar o grid
If !Empty(oMdlCAB:GetValue("CAB_DESC"))
	cWhere += " AND TW0.TW0_DESC LIKE '%" + UPPER(ALLTRIM(oMdlCAB:GetValue("CAB_DESC"))) + "%' "
EndIf 

If !Empty(oMdlCAB:GetValue("CAB_ATEND"))
	cWhere += " AND TW0.TW0_ATEND = '"+ oMdlCAB:GetValue("CAB_ATEND") + "'"
EndIf 

If !Empty(oMdlCAB:GetValue("CAB_TIPO"))
	cWhere += " AND TW0.TW0_TIPO = '"+ oMdlCAB:GetValue("CAB_TIPO") + "'"
EndIf 

If TW0->(ColumnPos("TW0_STATUS")) > 0
	cWhere += " AND (TW0.TW0_STATUS = '1' OR TW0.TW0_STATUS = ' ') "
EndIf

If TW0->(ColumnPos("TW0_VAGA")) > 0
	cWhere += " AND TW0.TW0_VAGA <> '1' "
EndIf
cWhere += "%"

BeginSql Alias cAliasRot

	COLUMN TGZ_DTINI AS DATE
	COLUMN TGZ_DTFIM AS DATE

	SELECT
		TW0.TW0_COD, 
		TW0.TW0_DESC,
		TW0.TW0_ATEND,
		CASE WHEN AA1.AA1_NOMTEC IS NOT NULL THEN AA1.AA1_NOMTEC ELSE '' END AA1_NOMTEC,
		MIN(TGZ.TGZ_DTINI) TGZ_DTINI,
	    MAX(TGZ.TGZ_DTFIM) TGZ_DTFIM
	FROM
		%Table:TW0% TW0
	LEFT JOIN %table:AA1% AA1 ON
		AA1.AA1_FILIAL = %xFilial:AA1% AND 
		AA1.AA1_CODTEC = TW0.TW0_ATEND AND
		AA1.%NotDel%
	LEFT JOIN %table:TGZ% TGZ ON
		TGZ.TGZ_FILIAL = %xFilial:TGZ% AND
		TGZ.TGZ_CODTW0 = TW0.TW0_COD AND
		TGZ.TGZ_ATEND = TW0.TW0_ATEND AND
		TGZ.TGZ_DTINI <> '' AND
		TGZ.%NotDel%		
	WHERE
		TW0.TW0_FILIAL = %xFilial:TW0%
		%exp:cWhere%
		AND TW0.%NotDel%
	GROUP BY
		TW0.TW0_COD,
		TW0.TW0_DESC,
		TW0.TW0_ATEND,
		AA1_NOMTEC	
EndSql

oMdlMOV:SetNoInsertLine(.F.)
oMdlMOV:SetNoDeleteLine(.F.)
oMdlMOV:ClearData()
oMdlMOV:InitLine()

While (cAliasRot)->(!Eof())
	If !oMdlMOV:IsEmpty()
		nLinha := oMdlMOV:AddLine()
	EndIf
	oMdlMOV:GoLine(nLinha)
	oMdlMOV:LoadValue("MOV_MARK", .T. )
	oMdlMOV:LoadValue("MOV_COD",  (cAliasRot)->(TW0_COD) )
	oMdlMOV:LoadValue("MOV_DESC", (cAliasRot)->(TW0_DESC) )
	
	If !Empty((cAliasRot)->(TW0_ATEND) )
		oMdlMOV:LoadValue("MOV_ATEND", (cAliasRot)->(TW0_ATEND) )
		oMdlMOV:LoadValue("MOV_NOME", (cAliasRot)->(AA1_NOMTEC) )
		oMdlMOV:LoadValue("MOV_MOVIM", .T. )
	EndIf
	If TW1->(ColumnPos("TW1_FILTFF") > 0)
		oMdlMOV:LoadValue("MOV_FILTFF", Posicione("TW1",1,xFilial("TW1")+(cAliasRot)->(TW0_COD),"TW1_FILTFF") )
	EndIf
	If !Empty((cAliasRot)->(TGZ_DTINI))
		oMdlMOV:LoadValue("MOV_DTINI", (cAliasRot)->(TGZ_DTINI) )
		oMdlMOV:LoadValue("MOV_INITGY", (cAliasRot)->(TGZ_DTINI) )
	EndIf
	
	If lDtIni
		oMdlMOV:LoadValue("MOV_DTINI", oMdlFAC:GetValue("FAC_DTINI") )		
	EndIf 	
	
	If !Empty((cAliasRot)->(TGZ_DTFIM))
		oMdlMOV:LoadValue("MOV_DTFIM", (cAliasRot)->(TGZ_DTFIM) )
		oMdlMOV:LoadValue("MOV_FIMTGY", (cAliasRot)->(TGZ_DTFIM) )
	EndIF
	
	If lDtFim
		oMdlMOV:LoadValue("MOV_DTFIM", oMdlFAC:GetValue("FAC_DTFIM") )
	EndIf 

	(cAliasRot)->(dbSkip())

EndDo

(cAliasRot)->(dbCloseArea())
oMdlMOV:GoLine(1)

oMdlMOV:SetNoInsertLine(.T.)
oMdlMOV:SetNoDeleteLine(.T.)

If !IsBlind()
	oView:Refresh()
EndIf	

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581AGrav

@description Realiza o processamento das revisões

@return lRet, Logico, Indica se a gravação foi feita com sucesso

@author	Luiz Gabriel
@since	29/07/2020
/*/
//------------------------------------------------------------------------------
Static Function At581AGrav(oModel)
Local lRet		:= .T.
Local aResult	:= {}
Local nMeter 	:= 0
Local nTotal 	:= 0
Local oDlg		:= Nil
Local oMeter	:= Nil
Local cErrMsg	:= ""
Local nOk		:= 0
Local nNoOk		:= 0		
Local lExibe	:= .F.

Begin Transaction
	AgrupaRota(oModel,@aResult)
	nTotal := Len(aResult)
	If !IsBlind() .And. nTotal > 0
		oDlg := nil
		oSayMtr := nil
		nMeter := 0
		DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0033 + cValToChar(nTotal) + STR0034 // "Executando " ## " rotas . . . "
			oSayMtr := tSay():New(10,10,{||STR0035},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
			oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlg,220,10,,.T.,/*uParam10*/,/*uParam11*/,.T.)
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (ExecutaRot(aResult, @cErrMsg ,@oDlg ,@oMeter ,@nOk ,@nNoOk, @lExibe))
	Else
		ExecutaRot(aResult, @cErrMsg)
	EndIf
End Transaction

If !isBlind()
	If nOk == 0 .And. nNoOk == 0
		Aviso(STR0036,STR0037,{STR0038},2) //"Movimentação da rota "##"Não há rotas para movimentar"##"OK
	Else
		If lExibe
			cMsg := STR0039+cValToChar(nOk)+CRLF;		//"Rotas Movimentadas: " 
					+STR0040+cValToChar(nNoOk)+CRLF+CRLF;	//"Rotas não movimentadas: "
					+STR0041+TxLogPath("GsLogRotaLote") //"Foi gerado o log no arquivo "
					Aviso(STR0036,cMsg,{STR0038},2)					//"Movimentação da rota "{"OK"}
					
					If nOk == 0 .And. nNoOk > 0 
						Help( " ", 1, "NOAGENDA", Nil, STR0055, 2 ) // "Rota não movimentada, pois não existe agenda para o periodo informado"
					EndIf		
		Else
			Aviso(STR0036,STR0053,{STR0038},2)	//"Movimentação da rota "##"Todas as rotas foram processadas"##"OK	
		EndIf
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AgrupaRota

@description Realiza a leitura dos itens marcados do grid e agrupa em um array

@author	Luiz Gabriel
@since	29/07/2020
/*/
//------------------------------------------------------------------------------
Static Function AgrupaRota(oModel,aResult)
Local oMdlMOV 	:= oModel:GetModel('MOVDETAIL')
Local nX		:= 0
Local nLinha	:= 0

nLinha := oMdlMOV:Length()

For nX := 1 To nLinha
	oMdlMOV:GoLine(nX)
	If oMdlMOV:GetValue("MOV_MARK") .AND. !EMPTY(oMdlMOV:GetValue("MOV_ATEND")) .AND.;
			!EMPTY(oMdlMOV:GetValue("MOV_DTFIM"))
		aAdd(aResult,;
			{oMdlMOV:GetValue("MOV_COD"),;
			oMdlMOV:GetValue("MOV_ATEND"),;
			oMdlMOV:GetValue("MOV_DTINI"),;
			oMdlMOV:GetValue("MOV_DTFIM"),;
			oMdlMOV:GetValue("MOV_INITGY"),;
			oMdlMOV:GetValue("MOV_FIMTGY");
			})
	EndIf 
Next nX

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ExecutaRot

@description Realiza o processamento das movimentações das rotas

@author	Luiz Gabriel
@since	29/07/2020
/*/
//------------------------------------------------------------------------------
Static Function ExecutaRot(aProcs, cErrMsg, oDlg, oMeter,nOk,nNoOk, lExibe)
Local nX
Local lLoadBar
Local oGsLog	:= GsLog():new()
Local lMvGsRota	:= FindFunction("At581GsRota") .And. At581GsRota()
Local lOk 			:= .T.
Default oDlg 		:= nil
Default oMeter 		:= nil
Default nOk			:= 0
Default nNoOk		:= 0
Default lExibe		:= .F.

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

For nX := 1 To Len(aProcs)
	cErrMsg := ""	
	If lMvGsRota
		lOk := At581ARtLt(aProcs[nX],@cErrMsg)
	Else
		lOk := At581Efet("MV", aProcs[nX][1], dDatabase, aProcs[nX][2], .F. , aProcs[nX][3], aProcs[nX][4], aProcs[nX][5], aProcs[nX][6],,@cErrMsg,.T.)
	Endif

	oGsLog:addLog("RotaLote", "---------------------------------------------------"+CRLF+CRLF )
	oGsLog:addLog("RotaLote", STR0042 + AllToChar(aProcs[nX][1]) ) //"Código da Rota: "
	oGsLog:addLog("RotaLote", STR0043 + AllToChar(aProcs[nX][2]) ) //"Código do Funcionario: "
	oGsLog:addLog("RotaLote", STR0044 + AllToChar(aProcs[nX][3]) ) //"Inicio da Movimentação: "
	oGsLog:addLog("RotaLote", STR0045 + AllToChar(aProcs[nX][4]) ) //"Fim da Movimentação: "

	If lOk
		nOk++
		If !Empty(cErrMsg)
			lExibe := .T.
			If lMvGsRota
				oGsLog:addLog("RotaLote", STR0056 + AllToChar(cErrMsg) ) //"Msg de Ok: "
			Else
				oGsLog:addLog("RotaLote", STR0046 + AllToChar(cErrMsg) ) //"Msg de Erro: "
			Endif
		EndIf
	Else
		lExibe := .T.
		nNoOk ++
		oGsLog:addLog("RotaLote", STR0046 + AllToChar(cErrMsg) ) //"Msg de Erro: "
	EndIf

	If lLoadBar
        oMeter:Set(nX)
        oMeter:Refresh()
	EndIf
Next nX

If !EMPTY(aProcs)
	oGsLog:printLog("RotaLote")
EndIf

If lLoadBar
	oDlg:End()
EndIf

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581aAtd()

Validação do Grid de movimentação e Facilitador

@author Luiz Gabriel
@since 29/07/2020
/*/
//------------------------------------------------------------------------------
Function At581aAtd(oMdlG,cCampo,xValue)
Local lRet		:= .T.
Local aArea		:= {}
Local cTitleErr	:= ""
Local cErrMsg	:= ""

If oMdlG:GetId() == "MOVDETAIL"
	If cCampo == "MOV_ATEND"
		If !oMdlG:GetValue("MOV_MOVIM")
			aArea := AA1->(GetArea())
			DbSelectArea("AA1")
			AA1->(DbSetOrder(1))
			If !AA1->(DbSeek(xFilial("AA1")+xValue))
				cTitleErr	:= STR0047 //"Valor Invalido"
				cErrMsg		:= STR0048 //"Informe o código correto" 
				lRet := .F.
			EndIf
			RestArea(aArea)
		Else
			cTitleErr	:= STR0049 //"Rota de cobertura já movimentada"
			cErrMsg		:= STR0050 //"Não é possivel alterar codigo de atendente de Rotas movimentadas" 
			lRet		:= .F.
		EndIf
	ElseIf cCampo == "MOV_DTFIM"
		If xValue < oMdlG:GetValue("MOV_DTINI")
			cTitleErr	:= STR0051 //"Verificar datas"
			cErrMsg		:= STR0052 //"Data Final não pode ser menor que a Data Inicial"
			lRet		:= .F.
		EndIf
	EndIf 
ElseIf oMdlG:GetId() == "FACDETAIL"
	If cCampo == "FAC_DTFIM"
		If xValue < oMdlG:GetValue("FAC_DTINI")
			cTitleErr	:= STR0051 //"Verificar datas"
			cErrMsg		:= STR0052 //"Data Final não pode ser menor que a Data Inicial"
			lRet		:= .F.
		EndIf
	EndIf 
EndIf

If !lRet
	oMdlG:GetModel():SetErrorMessage(oMdlG:GetId(),cCampo,oMdlG:GetModel():GetId(),cCampo,cCampo,;
		cTitleErr, cErrMsg )
EndIf		

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At581AVld()

Pré-valid do modelo

@author Mateus Boiani
@since 04/08/2020
/*/
//------------------------------------------------------------------------------
Function At581AVld(oModel)
Local oMdlMOV 	:= oModel:GetModel('MOVDETAIL')
Local nX		:= 0
Local nLinha	:= 0
Local lRet := .T.

nLinha := oMdlMOV:Length()
If !isBlind()
	For nX := 1 To nLinha
		oMdlMOV:GoLine(nX)
		If oMdlMOV:GetValue("MOV_MARK")
			If EMPTY(oMdlMOV:GetValue("MOV_ATEND")) .OR. EMPTY(oMdlMOV:GetValue("MOV_DTFIM"))
				lRet := MsgYesNo(STR0054)
				//"Uma ou mais rotas marcadas não possuem Atendente e/ou Data Fim. Nenhuma agenda será gerada para estes registros. Continuar com a operação?"
				Exit
			EndIf
		EndIf 
	Next nX
EndIf
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinCAB()

Pré-valid do campo CAB_ATEND

@author Matheus Gonçalves
@since 24/09/2020
/*/
//------------------------------------------------------------------------------
Static Function PreLinCAB(oMdlCAB,cAction,cField,xValue)
Local lRet := .T.
Local cQry
Local cAliasQry := GetNextAlias()

If VALTYPE(oMdlCAB) == 'O' .AND. oMdlCAB:GetId() == "CABMASTER"
	If cAction == "SETVALUE"
		If cField == "CAB_ATEND"
			If !EMPTY(xValue)
				xValue := AT190dLimp(xValue)
				cQry := " SELECT 1 "
				cQry += " FROM " + RetSqlName("AA1") + " AA1 "
				cQry += " WHERE AA1.AA1_FILIAL = '" +  xFilial('AA1') + "' AND "
				cQry += " AA1.D_E_L_E_T_ = ' ' "
				cQry += " AND AA1.AA1_CODTEC = '" + xValue + "' "
				cQry := ChangeQuery(cQry)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasQry, .F., .T.)
				lRet := (cAliasQry)->(!EOF())
				(cAliasQry)->(DbCloseArea())
			EndIf
		EndIF
	EndIf
EndIf
Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At581aExc
Executa uma função Static
@author		Matheus Gonçalves
@since		22/04/2021
@Versão 	1.0
/*/
//------------------------------------------------------------------------------
Function At581aExc()
	BuscaRota()
Return 
//------------------------------------------------------------------------------
/*/{Protheus.doc} At581aGrv
Executa uma função Static
@author		Matheus Gonçalves
@since		22/04/2021
@Versão 	1.0
/*/
//------------------------------------------------------------------------------
Function At581aGrv(oModel)
	At581AGrav(oModel)
Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581ARtLt
Executa a nova rota em lote.
@author		Kaique Schiller
@since		21/09/2021
/*/
//------------------------------------------------------------------------------
Function At581ARtLt(aRotas,cMsg)
Local oModel  := Nil
Local oMdlTW0 := Nil
Local lRet	  := .T.
Default aRotas := {}
Default cMsg   := ""

DbSelectArea("TW0")
TW0->(DbSetOrder(1))
If TW0->(DbSeek(xFilial("TW0")+aRotas[NPOS_CODROTA]))
	oModel	:= FWLoadModel("TECA581")
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()
	oMdlTW0  := oModel:GetModel('TW0MASTER')
	If Empty(oMdlTW0:GetValue("TW0_ATEND"))
		lRet := oMdlTW0:SetValue("TW0_ATEND",aRotas[NPOS_CODATEND] )
	Endif
	If lRet .And. oMdlTW0:GetValue("DET_DTINI") != aRotas[NPOS_PERINI]
		lRet := lRet .And. oMdlTW0:SetValue("DET_DTINI",aRotas[NPOS_PERINI] )	
	Endif
	If lRet .And. oMdlTW0:GetValue("DET_DTFIM") != aRotas[NPOS_PERFIM]
		lRet := lRet .And. oMdlTW0:SetValue("DET_DTFIM",aRotas[NPOS_PERFIM] )
	Endif
	If lRet
		If oModel:HasErrorMessage()
			If !EMPTY(STRTRAN(Alltrim(oModel:GetErrorMessage()[6]), CRLF))
				cMsg += STRTRAN(Alltrim(oModel:GetErrorMessage()[6]), CRLF)
			EndIf
			If !EMPTY(STRTRAN(Alltrim(oModel:GetErrorMessage()[7]), CRLF))
				If !EMPTY(cErrMsg)
					cMsg += " / "
				EndIF
				cMsg += STRTRAN(Alltrim(oModel:GetErrorMessage()[7]), CRLF)
			EndIf
		Endif
		lRet := lRet .And. At581YAgen(.F.,@cMsg) //Projeta as agendas da rota.
		lRet := lRet .And. At581dYCmt(.F.,@cMsg) //Grava as agendas projetadas.
	Endif
Endif

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At581ABusc()

Executa a rotina BuscaRota

@author Mateus Boiani
@since 07/10/2021
/*/
//------------------------------------------------------------------------------
Function At581ABusc()

Return BuscaRota()
