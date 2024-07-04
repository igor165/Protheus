#Include 'Protheus.ch'
#INCLUDE "TECA020A.CH"
#INCLUDE 'FWMVCDEF.CH'

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
#DEFINE DEF_NAO_RECEBE_VAL		13	//Indica se o campo pode receber valor em uma operação de update.
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

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA020A
Programa de Manutencao no Cadastro de Supervisor de Postos
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA020A()
Local oBrowse

If AA1->(ColumnPos("AA1_SUPERV")) > 0  .AND. TableInDic("TXI")


	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('AA1')
	oBrowse:SetDescription(STR0001) //"Supervisores de Postos"
	oBrowse:DisableDetails()
	oBrowse:SetFilterDefault("AA1->AA1_SUPERV == '1' ")
	oBrowse:Activate()
Else
	Help(,1,"TECA020A",,STR0002, 1) //"Necessário que o campo AA1_SUPERV e a tabela TXI estejam criados"
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao de definicao do aRotina 
@return	aRotina -  lista de aRotina 
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aMenu:={}


aAdd(aMenu,{ STR0022, 'VIEWDEF.TECA020A', 0 , 2, 0, .T. } ) // 'Visualizar''
aAdd(aMenu,{ STR0021, 'VIEWDEF.TECA020A', 0, 4, 0, .T. } ) // "Vincular Postos"


Return aMenu

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o modelo de dados (MVC)  . 
@return	oModel - Objeto Model
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel		:= nil
Local oStruAA1		:=  FWFormModelStruct():New()
Local oStruTXI		:= FWFormStruct(1,'TXI')
Local oStrTMPTGY	:= FWFormModelStruct():New()
Local aTables 		:= {}
Local nY			:= 0
Local aFields		:= {}
Local nX            := 0
Local xAux			:= {}


oStruAA1:AddTable("AA1",{"AA1_FILIAL","AA1_CODTEC"}, STR0003) //"Atendentes"
oStrTMPTGY:AddTable("   ",{}, "   ")

AADD(aTables, {oStruAA1, "AA1"})
AADD(aTables, {oStruTXI, "TXI"})
AADD(aTables, {oStrTMPTGY, "TMP"})


For nY := 1 To LEN(aTables)
	aFields := aClone(AT020ADDef(aTables[nY][2], 1))

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
						aFields[nX][DEF_NAO_RECEBE_VAL		],;
						aFields[nX][DEF_VIRTUAL			])
	Next nX
	aFields := {}
Next nY

xAux := FwStruTrigger( 'AA1_DATABA', 'AA1_DATABA','At020AtGrd(.T.)', .F. )
oStruAA1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4]) 

oModel := MPFormModel():New('TECA020A',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields('AA1MASTER',/*cOwner*/,oStruAA1,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetPrimaryKey({"AA1_FILIAL", "AA1_CODTEC"})

oStruTXI:SetProperty("TXI_CODTEC", MODEL_FIELD_OBRIGAT, .F.)

oModel:AddGrid("TXIDETAIL","AA1MASTER",oStruTXI,{|oMdlG,nLine,cAcao,cCampo, xValor, xValorAnt| PreLinTXI(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt) })
// Relacionamento com o GRID Principal
oModel:SetRelation("TXIDETAIL",{{"TXI_FILIAL","xFilial('TXI')"},{"TXI_CODTEC" ,"AA1_CODTEC" }}	,TXI->(IndexKey(2)))
If !IsBlind()
	oModel:GetModel( 'TXIDETAIL' ):SetUniQueLine({"TXI_LOCAL", "TXI_FUNCAO", "TXI_TURNO", "TXI_DTINI", "TXI_DTFIM"})
EndIf
oModel:GetModel( 'TXIDETAIL' ):SetOptional(.T.)


oModel:AddGrid("TMPDETAIL","TXIDETAIL",oStrTMPTGY,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,{|oGrid,lCopia| At020ALdG2(oGrid,lCopia)})

// Relacionamento com o GRID Principal
oModel:GetModel( 'TMPDETAIL' ):SetOnlyQuery(.T.)
oModel:GetModel( 'TMPDETAIL' ):SetOptional(.T.)
oModel:GetModel( 'TMPDETAIL' ):SetDelAllLine(.T.)
oModel:GetModel( 'TMPDETAIL' ):SetNoInsertLine(.T.)
oModel:GetModel( 'TMPDETAIL' ):SetNoDeleteLine(.T.)
oModel:SetDescription(STR0004) //"Supervisores"
oModel:GetModel( 'TXIDETAIL' ):SetDescription(STR0005) //"Locais"
oModel:GetModel( 'TMPDETAIL' ):SetDescription(STR0003) //"Atendentes"

Return oModel

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a interface para cadastro em MVC. 
@return	oView - Objeto View
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView		:= NIL
Local oModel   := FWLoadModel('TECA020A')
Local oStruAA1		:= FWFormViewStruct():New()
Local oStruTXI		:= FWFormStruct(2,'TXI', {|cCampo| ( !AllTrim(cCampo) $"TXI_FILIAL+TXI_CODTEC+TXI_NOMTEC") },/*lViewUsado*/)
Local oStrTMPTGY	:= FWFormViewStruct():New()
Local oStruAA12		:= FWFormViewStruct():New()
Local oStruAA13		:= FWFormViewStruct():New()
Local aTables 		:= {}
Local nY			:= 0
Local aFields		:= {}
Local nX            := 0
Local lLowScreen := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366

AADD(aTables, {oStruAA1, "AA1"})
AADD(aTables, {oStruTXI, "TXI"})
AADD(aTables, {oStrTMPTGY, "TMP"})
AADD(aTables, {oStruAA12, "AA12"})
AADD(aTables, {oStruAA13, "AA13"})

For nY := 1 to LEN(aTables)
	aFields := aClone(AT020ADDef(aTables[nY][2], 2))

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
						aFields[nX][DEF_INSERT_LINE])
	Next nX
	aFields := {}
Next nY

oStruAA1:RemoVeField("AA1_FILIAL")
oStruTXI:RemoveField("TXI_DATABA")
oStruTXI:RemoveField("TXI_CODIGO")
oStrTMPTGY:RemoveField("TMP_LOCAL")

oStruTXI:RemoveField("TXI_UPD")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_AA1', oStruAA1,'AA1MASTER')
oView:AddGrid('VIEW_TXI',oStruTXI,'TXIDETAIL')
oView:AddField('VIEW_AA12', oStruAA12,'AA1MASTER')
oView:AddGrid('VIEW_TMP',oStrTMPTGY,'TMPDETAIL')
oView:AddField('VIEW_AA13', oStruAA13,'AA1MASTER')

oView:CreateHorizontalBox('SUPERIOR',20)
oView:CreateHorizontalBox('DETALHE_TXI',25)
oView:CreateHorizontalBox('DETALHE_AA1',13)
oView:CreateHorizontalBox('DETALHE_TMP',35)
oView:CreateHorizontalBox('TOTAL_AA1',7)
oView:SetOwnerView('VIEW_AA1','SUPERIOR')
oView:SetOwnerView('VIEW_TXI','DETALHE_TXI')
oView:SetOwnerView('VIEW_AA12','DETALHE_AA1')
oView:SetOwnerView('VIEW_TMP','DETALHE_TMP')
oView:SetOwnerView('VIEW_AA13','TOTAL_AA1')

oView:AddUserButton(STR0006, "", { || AT020Mapa()  }) //"Mapa de Locais"
If ExistFunc("TECR027")
	oView:AddUserButton(STR0007, "", { || TECR027() }) //"Relatorio de Supervisores"
EndIf

oView:AddOtherObject("LOAD_ATT",{|oPanel| at20AdExpC(oPanel) })
oView:SetOwnerView("LOAD_ATT","DETALHE_AA1")


oView:AddOtherObject("EXPORT_ATT",{|oPanel| at20AdExpP(oPanel) })
oView:SetOwnerView("EXPORT_ATT","DETALHE_AA1")

oView:EnableTitleView('VIEW_AA1', STR0009) //"Supervisor"
oView:EnableTitleView('VIEW_AA12', STR0003) //"Atendentes"
oView:EnableTitleView('VIEW_TXI', STR0005) //"Locais"

SetKey( VK_F10, { || At020AtGrd (.t.) })
oView:SetCloseOnOk( { || .T. } ) //Retira a opção salvar e criar um novo

If lLowScreen
	oView:SetContinuousForm()
EndIf

Return oView

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT020ADDef
Retorna o Array dos campos
@return	aRet - Array dos campos
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AT020ADDef(cTable, nOpc)
Local aRet := {}
Local cOrdem := "00"
Local nAux := 0

Do CASE
Case  "AA1" $ cTable
	If cTable == "AA1"
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_FILIAL", .T. )  //"Filial do Atendente"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_FILIAL", .F. )//"Filial do Atendente"
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_FILIAL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_FILIAL")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| xFilial("AA1")}
		aRet[nAux][DEF_NAO_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .F.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := GetSX3Cache( "AA1_FILIAL", "X3_PICTURE" )
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .T. )  
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .F. )
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_CODTEC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "" }
		aRet[nAux][DEF_NAO_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .F.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := ""
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_NOMTEC", .T. )
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_NOMTEC", .F. )
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_NOMTEC"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "" }
		aRet[nAux][DEF_NAO_RECEBE_VAL]  := .T.
		aRet[nAux][DEF_VIRTUAL] := .F.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := GetSX3Cache( "AA1_NOMTEC", "X3_PICTURE" )
		aRet[nAux][DEF_CAN_CHANGE] := .F.


		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_FUNCAO", .T. )
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_FUNCAO", .F. )
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_FUNCAO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_FUNCAO")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "" }
		aRet[nAux][DEF_NAO_RECEBE_VAL]  := .T.
		aRet[nAux][DEF_VIRTUAL] := .F.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := GetSX3Cache( "AA1_FUNCAO", "X3_PICTURE" )
		aRet[nAux][DEF_CAN_CHANGE] := .F.


		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "RJ_DESC", .T. )
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "RJ_DESC", .F. )
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_DFUNCAO"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("RJ_DESC")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| GetAdvFVal('SRJ',"RJ_DESC", xFilial("SRJ")+AA1->AA1_FUNCAO, 1, "") }
		aRet[nAux][DEF_NAO_RECEBE_VAL]  := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_CAN_CHANGE] := .F.

		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_EMAIL", .T. )
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_EMAIL", .F. )
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_EMAIL"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_EMAIL")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "" }
		aRet[nAux][DEF_NAO_RECEBE_VAL]  := .T.
		aRet[nAux][DEF_VIRTUAL] := .F.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := ""
		aRet[nAux][DEF_CAN_CHANGE] := .F.


		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_FONE", .T. )
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_FONE", .F. )
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_FONE"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_FONE")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "" }
		aRet[nAux][DEF_NAO_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .F.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := GetSX3Cache( "AA1_FONE", "X3_PICTURE" )
		aRet[nAux][DEF_CAN_CHANGE] := .F.
	EndIf

	If  nOpc == 1 .or. (cTable == "AA12" .and. nOpc == 2)
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0010 //"Data"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0010 //"Data"
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_DATABA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_DTINI")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .T.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| dDataBase }
		aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_CODEBLOCK_VALID] :=  {|| !Empty(FwFldGet("AA1_DATABA")) }
		
	EndIf
	If  nOpc == 1 .or. (cTable == "AA13" .and. nOpc == 2)
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0011 //"Total Atendentes"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0011 //"Total Atendentes"
		aRet[nAux][DEF_IDENTIFICADOR] := "AA1_TOTAA1"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 6
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| 0}
		aRet[nAux][DEF_NAO_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := "@E 999,999"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
	EndIf

Case cTable == "TXI"
		cOrdem := "20"
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0023 //"Atendentes no Posto"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0023 //"Atendentes no Posto"
		aRet[nAux][DEF_IDENTIFICADOR] := "TXI_TOTAA1"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| 0}
		aRet[nAux][DEF_NAO_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := "@E 99,999"
		aRet[nAux][DEF_CAN_CHANGE] := .T.


		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux++
		cOrdem := Soma1(cOrdem)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0010 //"Data"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0010//"Data"
		aRet[nAux][DEF_IDENTIFICADOR] := "TXI_DATABA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_DTINI")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_CODEBLOCK_INIT] := {|| dDataBase }
		aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_CAN_CHANGE] := .T.

Case cTable ==  "TMP"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "ABS_LOCAL", .T. ) 
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "ABS_LOCAL", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_LOCAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_LOCAL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "ABS_LOCAL", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_CODTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "AA1_CODTEC", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_NOMTEC", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_NOMTEC", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_NOMTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "AA1_CODTEC", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TGY_CODTFF", .T. ) 
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TGY_CODTFF", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_CODTFF"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_CODTFF")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "TGY_CODTFF", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_PRODUT", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_PRODUT", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_PRODUT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_PRODUT")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "B1_DESC", .T. ) 
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "B1_DESC", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_DPROD"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("B1_DESC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_CAN_CHANGE] := .F.


	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_ESCALA", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_ESCALA", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_ESCALA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_ESCALA")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_NOMESC", .T. ) 
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_NOMESC", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_DESEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TDW_DESC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_CAN_CHANGE] := .F.


	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_TURNO", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_TURNO", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_TURNO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_TURNO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_SEQTRN", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_SEQTRN", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_SEQTRN"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_SEQTRN")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "R6_DESC", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "R6_DESC", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_DTURNO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("R6_DESC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| ""}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TGY_DTINI", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TGY_DTINI", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_TGYDTI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_DTINI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| Ctod("")}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "TGY_DTINI", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux++
	cOrdem := Soma1(cOrdem)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TGY_DTFIM", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TGY_DTFIM", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TMP_TGYDTF"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_DTFIM")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| Ctod("")}
	aRet[nAux][DEF_NAO_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := cOrdem
	aRet[nAux][DEF_PICTURE] := GetSX3Cache( "TGY_DTFIM", "X3_PICTURE" )
	aRet[nAux][DEF_CAN_CHANGE] := .F.
EndCase

Return aRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At020ALdGP
Função de Load do Grid de Atendentes
@return	aRet - Array dos campos
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At020ALdGr(oMdlGrid,lCopy, lLoad)
Local aColsGrid := {}

Default lCopy := .F.
Default lLoad := .F.

Processa({|lEnd| aColsGrid := At020ALdGP(oMdlGrid,lCopy, @lEnd, lLoad) },STR0012,STR0013,.T. )  //"Aguarde..." //"Carregando Atendentes vinculados"

Return aColsGrid

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At020ALdGP
Função de Load do Grid de Atendentes
@return	aRet - Array dos campos
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At020ALdG2(oMdlGrid,lCopy)
Local aColsGrid := {}
Local oModel := oMdlGrid:GetModel("TECA020A")
Local oMdlTXI := NIL
Local oStrTXI := NIL

If oModel:GetOperation() == MODEL_OPERATION_VIEW
	aColsGrid :=  At020ALdGr(oMdlGrid,lCopy, .t.)
	//configura o campo como visual
	oMdlTXI := oModel:GetModel("TXIDETAIL")
	oStrTXI := oMdlTXI:GetStruct()

	oStrTXI:SetProperty("TXI_DATABA", MODEL_FIELD_WHEN, {|| .F. })

EndIf

Return aColsGrid

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At020ALdGr
Função de Load do Grid de Atendentes
@return	aRet - Array dos campos
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At020ALdGP(oMdlGrid,lCopy, lEnd, lLoad)

Local aColsGrid	:= {}
Local cAlias		:= GetNextAlias()
Local cDtVazio 		:= Dtos(Ctod(""))
Local nTotal		:= 0
Local oModel		:= oMdlGrid:GetModel("TECA020A")
Local cLocal		:= ""
Local dData         := Ctod("")
Local dDataIni		:= Ctod("")
Local dDataFim		:= Ctod("")
Local cExpDtTGY		:= ""
Local cExpDtTGZ		:= ""
Local cExpDtTDV		:= ""
Local nX := 0
Local nY := 0
Local nTotLoc		:= 0
Local nTotAA1		:= 0
Local nLinha		:= 0
Local aLinha		:= {}

Default lEnd := .F.
Default lLoad := .F.

If !lLoad
	oMdlGrid:InitLine()
EndIf
If !oModel:GetModel("TXIDETAIL"):IsDeleted() 

	If oModel:GetModel("TXIDETAIL"):GetLine() > 0 .AND. !oModel:GetModel("TXIDETAIL"):IsEmpty()
		
		nTotLoc := oModel:GetModel("TXIDETAIL"):GetValue("TXI_TOTAA1")
		dData := oModel:GetModel("AA1MASTER"):GetValue("AA1_DATABA")
		cLocal :=  oModel:GetModel("TXIDETAIL"):GetValue("TXI_LOCAL")

		cLocal := StrTran(cLocal, "'", "''")
		dDataIni := oModel:GetModel("TXIDETAIL"):GetValue("TXI_DTINI")
		If Empty(dDataIni)
			dDataIni := dData
		EndIf
		dDataFim :=  oModel:GetModel("TXIDETAIL"):GetValue("TXI_DTFIM")
		If Empty(dDataFim)
			cExpDtTGY :=" AND ( TGY.TGY_DTFIM = '" + cDtVazio + "'  OR TGY.TGY_DTFIM  >= '" +Dtos(dDataIni  ) +"' ) "
			cExpDtTGZ := " AND ( TGZ.TGZ_DTFIM = '" + cDtVazio + "'  OR TGZ.TGZ_DTFIM  >= '" +Dtos(dDataIni  ) +"' ) "

			cExpDtTDV := " AND TDV.TDV_DTREF >= '" +  Dtos(dDataIni) + "'"
		Else
			cExpDtTGY := " AND ( '" + DTos(dDataFim) + "' >=  TGY.TGY_DTINI AND " + ;
						"( '" + Dtos(dDataIni) +"' <= TGY.TGY_DTFIM  OR  TGY.TGY_DTFIM = '" + cDtVazio + "' ) ) "
			cExpDtTGZ := " AND ( '" + DTos(dDataFim) + "' >=  TGZ.TGZ_DTINI AND " + ;
						"( '" + Dtos(dDataIni) +"' <= TGZ.TGZ_DTFIM  OR  TGZ.TGZ_DTFIM = '" + cDtVazio + "' ) ) "

			cExpDtTDV := " AND TDV.TDV_DTREF BETWEEN '" +  Dtos(dDataIni) + "' AND '" +  Dtos(dDataFim)  + "'"
		EndIf
		If Empty(dDataFim)
			dDataFim := dData
		EndIf
		

	EndIf

	If !Empty(cLocal)
		
		cExpDtTGY := "%"+cExpDtTGY+"%"
		cExpDtTGZ := "%"+cExpDtTGZ+"%"
		cExpDtTDV := "%"+cExpDtTDV+"%"


		BeginSQL alias cAlias
			COLUMN TMP_TGYDTI AS DATE
			COLUMN TMP_TGYDTF AS DATE

			Select * 
			FROM
			(
			SELECT 
				TGY.TGY_FILIAL AS TMP_FILIAL,			
				TFF.TFF_LOCAL AS TMP_LOCAL,
				AA1.AA1_CODTEC AS TMP_CODTEC,
				AA1.AA1_NOMTEC AS TMP_NOMTEC,
				TGY.TGY_CODTFF AS TMP_CODTFF,
				TGY.TGY_DTINI AS TMP_TGYDTI,
				TGY.TGY_DTFIM AS TMP_TGYDTF,
				TGY.TGY_TIPALO AS TMP_TIPALO,
				TFF.TFF_ESCALA AS TMP_ESCALA,
				TDW.TDW_DESC AS TMP_DESEC,
				TFF.TFF_TURNO AS TMP_TURNO,
				TGY.TGY_SEQ AS TMP_SEQTRN,
				SR6.R6_DESC AS TMP_DTURNO,
				TFF.TFF_PRODUT AS TMP_PRODUT,
				SB1.B1_DESC AS TMP_DPROD
			FROM 
			%table:TFF% TFF	  
			INNER JOIN  %table:TDX% TDX ON (  TDX.TDX_CODTDW = TFF.TFF_ESCALA AND
												TDX.TDX_FILIAL = %xfilial:TDX% AND  
												TDX.%notDel%) 
			INNER JOIN %table:TGY% TGY ON (  TGY.TGY_CODTFF = TFF.TFF_COD  AND   
												TGY.TGY_FILIAL = %xfilial:TGY% AND 
												TGY.TGY_CODTDX = TDX.TDX_COD AND 
												TGY.%notDel% 
												%Exp:cExpDtTGY%)
			INNER JOIN %table:AA1% AA1 ON (  TGY.TGY_ATEND = AA1.AA1_CODTEC  AND   
												AA1.AA1_FILIAL = %xfilial:AA1% AND  
												AA1.%notDel% )
			INNER JOIN %table:SB1% SB1 ON (  SB1.B1_COD = TFF.TFF_PRODUT AND
												SB1.B1_FILIAL = %xfilial:SB1% AND  
												SB1.%notDel%) 
			INNER JOIN %table:TDW% TDW ON (  TDW.TDW_COD = TFF.TFF_ESCALA AND
												TDW.TDW_FILIAL = %xfilial:TDW% AND  
												TDW.%notDel%) 
			LEFT JOIN %table:SR6% SR6 ON ( SR6.R6_TURNO = TFF.TFF_TURNO AND
												SR6.R6_FILIAL = %xfilial:SR6% AND  
												SR6.%notDel%)
			WHERE TFF.TFF_FILIAL = %xfilial:TFF% AND
			TFF.TFF_LOCAL = %exp:cLocal% AND
			TFF.%notDel%
		UNION ALL
			SELECT DISTINCT
				ABB.ABB_FILIAL AS TMP_FILIAL,
				TFF.TFF_LOCAL AS TMP_LOCAL,	
				AA1.AA1_CODTEC AS TMP_CODTEC,
				AA1.AA1_NOMTEC AS TMP_NOMTEC,
				TFF.TFF_COD AS TMP_CODTFF,
				TDV.TDV_DTREF AS TMP_TGYDTI,
				TDV.TDV_DTREF AS TMP_TGYDTF,
				ABB.ABB_TIPOMV AS TMP_TIPALO,
				TFF.TFF_ESCALA AS TMP_ESCALA,
				TDW.TDW_DESC AS TMP_DESEC,
				TFF.TFF_TURNO AS TMP_TURNO,
				TFF.TFF_SEQTRN AS TMP_SEQTRN,
				SR6.R6_DESC AS TMP_DTURNO,
				TFF.TFF_PRODUT AS TMP_PRODUT,
				SB1.B1_DESC AS TMP_DPROD
			FROM 
				%table:TFF% TFF
				INNER JOIN %table:ABQ% ABQ ON (  ABQ.ABQ_CODTFF =  TFF.TFF_COD AND	
												ABQ.ABQ_FILTFF = TFF.TFF_FILIAL AND
												ABQ.%NotDel% AND
												ABQ.ABQ_FILIAL = %xFilial:ABQ% )
				INNER JOIN %table:ABB% ABB ON ( ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND 
												ABB.ABB_FILIAL = %xFilial:ABB% AND 
												ABB.%NotDel% AND
												ABB.ABB_MANUT = '1' )
				INNER JOIN %table:TDV% TDV ON ( TDV.TDV_CODABB = ABB.ABB_CODIGO AND
												TDV.TDV_FILIAL = %xFilial:TDV% AND
												TDV.%NotDel% 
												%Exp:cExpDtTDV% ) 
				INNER JOIN %table:ABR% ABR ON (  ABR.ABR_AGENDA = ABB.ABB_CODIGO  AND
												ABR.ABR_FILIAL = %xfilial:ABR% AND  
												ABR.%notDel% )
				INNER JOIN %table:AA1% AA1 ON (  ABR.ABR_CODSUB = AA1.AA1_CODTEC  AND   
												AA1.AA1_FILIAL = %xfilial:AA1% AND  
												AA1.%notDel% )
			INNER JOIN %table:SB1% SB1 ON (  SB1.B1_COD = TFF.TFF_PRODUT AND
												SB1.B1_FILIAL = %xfilial:SB1% AND  
												SB1.%notDel%) 
			INNER JOIN %table:TDW% TDW ON (  TDW.TDW_COD = TFF.TFF_ESCALA AND
												TDW.TDW_FILIAL = %xfilial:TDW% AND  
												TDW.%notDel%) 
			LEFT JOIN %table:SR6% SR6 ON ( SR6.R6_TURNO = TFF.TFF_TURNO AND
												SR6.R6_FILIAL = %xfilial:SR6% AND  
												SR6.%notDel%)	
			
			WHERE TFF.TFF_FILIAL = %xfilial:TFF% AND
			TFF.TFF_LOCAL = %exp:cLocal% AND
			TFF.%notDel%
		UNION ALL
				SELECT 
				TGZ.TGZ_FILIAL AS TMP_FILIAL,
				TFF.TFF_LOCAL AS TMP_LOCAL,
				AA1.AA1_CODTEC AS TMP_CODTEC,
				AA1.AA1_NOMTEC AS TMP_NOMTEC,
				TGZ.TGZ_CODTFF AS TMP_CODTFF,
				TGZ.TGZ_DTINI AS TMP_TGYDTI,
				TGZ.TGZ_DTFIM AS TMP_TGYDTF,
				TGX.TGX_TIPO  AS TMP_ABNTP,
				TFF.TFF_ESCALA AS TMP_ESCALA,
				TDW.TDW_DESC AS TMP_DESEC,
				TFF.TFF_TURNO AS TMP_TURNO,
				TFF.TFF_SEQTRN AS TMP_SEQTRN,
				SR6.R6_DESC AS TMP_DTURNO,
				TFF.TFF_PRODUT AS TMP_PRODUT,
				SB1.B1_DESC AS TMP_DPROD
			FROM 
			%table:TFF% TFF
			INNER JOIN  %table:TGX% TGX ON (  TGX.TGX_CODTDW = TFF.TFF_ESCALA AND
												TGX.TGX_FILIAL = %xfilial:TGX% AND  
												TGX.%notDel%) 
			INNER JOIN %table:TGZ% TGZ ON (  TGZ.TGZ_CODTFF = TFF.TFF_COD  AND 
												TGZ.TGZ_ESCALA = TFF.TFF_ESCALA AND  
												TGZ.TGZ_CODTDX = TGX.TGX_COD AND
												TGZ.TGZ_FILIAL = %xfilial:TGZ% AND  
												TGZ.%notDel%
												%Exp:cExpDtTGZ% )
			INNER JOIN %table:AA1% AA1 ON (  TGZ.TGZ_ATEND = AA1.AA1_CODTEC  AND   
												AA1.AA1_FILIAL = %xfilial:AA1% AND  
												AA1.%notDel% )
			INNER JOIN %table:SB1% SB1 ON (  SB1.B1_COD = TFF.TFF_PRODUT AND
												SB1.B1_FILIAL = %xfilial:SB1% AND  
												SB1.%notDel%) 
			INNER JOIN %table:TDW% TDW ON (  TDW.TDW_COD = TFF.TFF_ESCALA AND
												TDW.TDW_FILIAL = %xfilial:TDW% AND  
												TDW.%notDel%) 
			LEFT JOIN %table:SR6% SR6 ON ( SR6.R6_TURNO = TFF.TFF_TURNO AND
												SR6.R6_FILIAL = %xfilial:SR6% AND  
												SR6.%notDel%)
			WHERE TFF.TFF_FILIAL = %xfilial:TFF% AND
			TFF.TFF_LOCAL = %exp:cLocal% AND 
			TFF.%notDel%	)X
			WHERE
			%exp:dData% >= X.TMP_TGYDTI AND 
			( X.TMP_TGYDTF = %exp:cDtVazio% OR X.TMP_TGYDTF >= %exp:dData%  ) AND
			%exp:dData% BETWEEN %exp:dDataIni% AND %exp:dDataFim%
			ORDER BY X.TMP_CODTEC, X.TMP_CODTFF, X.TMP_PRODUT
		EndSQL

		ProcRegua((cAlias)->(RecCount()))
		If !lLoad
			oMdlGrid:SetNoInsertLine(.F.)
			oMdlGrid:SetNoUpDateLine(.F.)
		EndIf
		While (cAlias)->(!Eof())	
			IncProc()
			nX++	
			
			If !lLoad
				If !oMdlGrid:IsEmpty()
					nLinha := oMdlGrid:AddLine()
					oMdlGrid:GoLine(nLinha)
				EndIf
				
				For nY := 1 To Len(oMdlGrid:aHeader)	
					oMdlGrid:Loadvalue(oMdlGrid:aHeader[nY][2], (cAlias)->&(oMdlGrid:aHeader[nY][2]))
				Next nY
			Else
				aLinha := Array(Len(oMdlGrid:aHeader)+1)
				For nY := 1 To Len(oMdlGrid:aHeader)	
					aLinha[nY] := (cAlias)->&(oMdlGrid:aHeader[nY][2])
				Next nY
				aLinha[Len(oMdlGrid:aHeader)+1] := .F.
				Aadd(aColsGrid,{ 0, aClone(aLinha)})
			EndIf
			(cAlias)->(DbSkip())
		EndDo
		If !lLoad
			oMdlGrid:SetNoInsertLine(.T.)
			oMdlGrid:SetNoUpDateLine(.T.)		
			If oMdlGrid:GetLine() > 0 
				oMdlGrid:GoLine(1)
			EndIf
		EndIf
		(cAlias)->(DbCloseArea())
	EndIf
EndIf
nTotal := nX
nTotAA1 := oModel:GetModel("AA1MASTER"):GetValue("AA1_TOTAA1")
oModel:LoadValue("AA1MASTER","AA1_TOTAA1", nTotAA1 + nTotal )

If oModel:GetModel("TXIDETAIL"):GetLine() > 0 .AND. !oModel:GetModel("TXIDETAIL"):IsEmpty() .AND.  !Empty(cLocal)
	oModel:LoadValue("TXIDETAIL","TXI_DATABA", dData)
	oModel:LoadValue("TXIDETAIL","TXI_TOTAA1", nTotal)
EndIf

Return aColsGrid 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} at20AdExpP
Função de Adição do Botão Exportar CSV
@return	aRet - Array dos campos
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function at20AdExpP(oPanel)
Local lLowScreen := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
Local aTamanho := {}

If lLowScreen
	AADD(aTamanho, 52.00)
Else
	AADD(aTamanho, 44.00)
EndIf

TButton():New( (oPanel:nHeight / 2) - 13, (oPanel:nWidth/2) - aTamanho[1], STR0014 , oPanel, { || At020AExDP()  },43,12,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Exportar Dados" //"Exportar CSV"

Return ( Nil )


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} at20AdExpC
Função de Adição do Botão Carregar Atendentes
@return	aRet - Array dos campos
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function at20AdExpC(oPanel)
Local lLowScreen := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
Local aTamanho := {}
Local oView := FwViewActive()

If lLowScreen
	AADD(aTamanho, 52.00)
Else
	AADD(aTamanho, 44.00)
EndIf

TButton():New( (oPanel:nHeight / 2) - 13, (oPanel:nWidth/2) - ((aTamanho[1]+IIF(!lLowScreen, 5, 0))*2) , STR0026 , oPanel, { || At020AtGrd (.t.) },43,12,,,.F.,.T.,.F.,,.F.,{ || oView:GetOperation()<>MODEL_OPERATION_VIEW},,.F. )	//"Carr Atend (F10)"

Return ( Nil )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At020AtGrd
Função de Atualização do Grid de Atendentes ao Alterar da Data
@return	aRet - Array dos campos
@author	fabiana.silva
@since 	07/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At020AtGrd(lLoadAll)
Local oView := FwViewActive()
LOcal oModel := FwModelActive()
Local oModlTMP := oModel:GetModel("TMPDETAIL")
Local oModlTXI := oModel:GetModel("TXIDETAIL")
Local aSaveLines := FWSaveRows()
Local dData := FwFldGet("AA1_DATABA")
Local nX := 0
Local lUpd := .F.
Local nLineBckp := 0

Default lLoadAll := .F.

If oModel:GetOperation() <> MODEL_OPERATION_VIEW
	oModel:LoadValue("AA1MASTER","AA1_TOTAA1", 0)
	If !oModlTXI:IsEmpty()
		nLineBckp := oModlTXI:GetLine()
		For nX := 1 to oModlTXI:Length()
			
				oModlTXI:GoLine(nX)
				If lLoadAll .OR.  oModlTXI:GetValue("TXI_DATABA") <> dData

					oModlTMP:ClearData(.F., .F.)

					At020ALdGr(oModlTMP,.f.)
					lUpd := .T.
				EndIf


		Next nX
		If lUpd
			oView:Refresh("VIEW_TMP")
			oView:Refresh("VIEW_AA13")
			oView:Refresh("VIEW_TXI")
		EndIf
		oModlTXI:GoLine(nLineBckp)
	EndIf
	FWRestRows( aSaveLines )
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTXI
@description 	PreLinTXI validação para a grid de Locais ao excluir/deletar um local

@param 		oMdlG, nLine,cAcao, cCampo Modelo, linha, código da ação e nome do campo
@since		07/02/2020
@version	P12
@author	 fabiana.silva
/*/
//------------------------------------------------------------------------------
Static Function PreLinTXI(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt)

Local aArea			:= GetArea() 
Local aSaveLines	:= FWSaveRows()
Local oModel		:= If(oMdlG <> nil, oMdlG:GetModel(), nil)
Local nTotLoc		:= 0
Local nTotAA1		:= 0
Local oView := FwViewActive()


If oModel <> Nil .And. oModel:GetId() == 'TECA020A'
	If "DELETE" $ cAcao
		nTotLoc := oMdlG:GetValue("TXI_TOTAA1")
		If cAcao == 'DELETE'
			nTotLoc *= -1
		Else // cAcao == 'UNDELETE'
			nTotLoc *= 1
		EndIf
		nTotAA1 := oModel:GetModel("AA1MASTER"):GetValue("AA1_TOTAA1")
		oModel:LoadValue("AA1MASTER","AA1_TOTAA1", nTotAA1 + nTotLoc)	

		oView:Refresh("VIEW_AA13")

	EndIf	
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT020Mapa
@description  Função para abertura de mapa dos postos.
@author Augusto Albuquerque
@since  05/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AT020Mapa()
Local aLocal	:= {}
Local aError	:= {}
Local cMsg		:= ""
Local cHtml		:= ""
Local cFile		:= ""
Local cAliasABS	:= GetNextAlias()
Local cFilPesq	:= ""
Local nSleep	:= 1000
Local nLineBckp
Local nX
Local oModel	:= FwModelActive()
Local oMdlTXI	:= oModel:GetModel("TXIDETAIL")

nLineBckp := oMdlTXI:GetLine()
For nX := 1 To oMdlTXI:Length()
	oMdlTXI:GoLine(nX)
	If !oMdlTXI:IsDeleted()
		If nX > 1
			cFilPesq += "','"
		EndIf
		cFilPesq += oMdlTXI:GetValue("TXI_LOCAL")
	EndIf
Next nX
oMdlTXI:GoLine(nLineBckp)

BEGINSQL ALIAS cAliasABS
	SELECT ABS.ABS_LATITU, ABS.ABS_LONGIT, ABS.ABS_DESCRI, ABS.ABS_LOCAL, ABS.ABS_END, ABS.ABS_MUNIC, ABS.ABS_ESTADO
	FROM %Table:ABS% ABS 
	WHERE ABS.ABS_FILIAL = %xFilial:ABS% 
		AND ABS.%NotDel%
		AND ABS.ABS_LOCAL IN (%exp:cFilPesq%)
ENDSQL

While !( cAliasABS )->( EOF() )
	If Empty( ( cAliasABS )->ABS_LATITU ) .OR. Empty( ( cAliasABS )->ABS_LONGIT )
		If Empty( ( cAliasABS )->ABS_END ) .OR. Empty( ( cAliasABS )->ABS_MUNIC ) .OR. Empty( ( cAliasABS )->ABS_ESTADO )
			AADD( aError, { ( cAliasABS )->ABS_LOCAL,;
							( cAliasABS )->ABS_DESCRI} )
		Else
			aLatLon := TECGtCoord( ( cAliasABS )->ABS_END, ( cAliasABS )->ABS_MUNIC, ( cAliasABS )->ABS_ESTADO )
			If Len( aLatLon ) > 0 .AND. !Empty( aLatLon[1] ) .AND.  !Empty( aLatLon[2] )
				DbSelectArea("ABS")
				ABS->(DbSetOrder(1))
				If ABS->(DbSeek(xFilial("ABS")+ ( cAliasABS )->ABS_LOCAL ))
					RecLock("ABS", .F.)
						ABS->ABS_LATITU := aLatLon[1]
						ABS->ABS_LONGIT := aLatLon[2]
					MsUnlock()
				EndIf
				AADD( aLocal, { aLatLon[1],;
								aLatLon[2],;
								STR0015,;
								"red"})
			EndIf
		EndIf
	Else
		AADD( aLocal, { ( cAliasABS )->ABS_LATITU,;
						( cAliasABS )->ABS_LONGIT,;
						STR0015,; //"Local de atendimento"
						"red"} )
	EndIf
	( cAliasABS )->( DbSkip() )
EndDo
( cAliasABS )->( DbCloseArea() )

If Len(aError) > 0
	cMsg := STR0016+CRLF+CRLF+CRLF //"Foram encontrados alguns cadastros que não possuem latitude e/ou longitude"
	For nX := 1 To Len(aError)
		cMsg += Alltrim(Str(nX)) + " " + STR0018 + " " + aError[nX][1] + " " + STR0017 + " " + aError[nX][2] + CRLF //"Local: " //"Numero do Local: "
	Next nX
	cMsg += CRLF+CRLF+STR0019  //"Verifique nos cadastros citados acima, se os campos de Latitude e Longitude foram informados."
	If !IsBlind()
		AtShowLog(cMsg,STR0020,.T.,.T., ,.F.) // STR0020 //"Latitude / Longitude"
	EndIf
EndIf

If Len(aLocal) > 0
	cHtml := TECHTMLMap( , aLocal, "16", 1 )

	cFile := GetTempPath() + "locationcheckin.html"

	TECGenMap( cHtml, cFile, nSleep, .T. )
EndIf

	MsgAlert(STR0025, "") // "Processo concluido!"
Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At020AExDP
@description  Função para processamento de exportacao dos dados
@author fabiana.silva
@since  12/02/2020
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function At020AExDP()
Local oModel := FwModelActive()
Local oModlTMP := oModel:GetModel("TMPDETAIL")

If !oModlTMP:IsEmpty()
	TecGrd2CSV("VIEW_TMP","TMPDETAIL","VIEW_TMP",/*aNoCpos*/,/*aIncCpo*/,/*aLegenda*/,"TECA020A", /*cFldVld*/)
Else
	MsgStop(STR0027) //"Não há dados para exportar"
EndIf

Return 
//------------------------------------------------------------------------------
/*/{Protheus.doc} At190dExec
Executa um comando genérico recebido via string

@author		Matheus Gonçalves
@since		09/12/2020
@param 		cCommand - Comando via string a ser executado
@Versão 	1.0
/*/
//------------------------------------------------------------------------------
Function At020aExec( cCommand)
Local oModel    := FwLoadModel("TECA020A")
Local oModlTMP	:= oModel:GetModel("TMPDETAIL")
Local xRet 

If IsBlind()
	oModel:Activate()
	oModlTMP:Activate()
EndIF

xRet := (&(cCommand))

Return xRet
