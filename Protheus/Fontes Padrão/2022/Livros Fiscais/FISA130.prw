#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA130

@author Erick G. Dias
@since 23/06/2016
@version 11.90

/*/
//-------------------------------------------------------------------
function FISA130

local aCoors 			:= FWGetDialogSize( oMainWnd )
local cFiltro			:= ''
local cError			:= ''
local cPerg				:= 'FSA130'
local lCon				:= .f.
local lProcessa			:= .f.
local lTSS				:= .f.
Local cMV_TCNEW 		:= SuperGetMv( "MV_TCNEW" , .F. , "" ,  ) //Totvs Colaboracao 2.0
local cRpoRel			:= GetRpoRelease() // Release RPO
Local cSistUtili		:= ""
Local lGravProt			:= F0U->(FieldPos("F0U_PROT1"))>0 .And. F0U->(FieldPos("F0U_PROT2"))>0
Local aCfg				:= {}


private CDESCRF130		:= ''
private CPROC			:= ''
private CMENU			:= '1'
private cIdEnti			:= ''
private cOpFiltro		:= '7'
private cAmbiente		:= ''
private lF0UCfop        := F0U->(FieldPos("F0U_CFOP"))>0
private oDlgPrinc
private oBrowseDown
private dMvPar01
private dMvPar02
private cMvPar03
private cMvPar04
private cMvPar05
private cMvPar06
private lUsaColab	:= UsaColaboracao("1",cMV_TCNEW)

//Verifisa se utiliza TSS ou TOTVS colaboração
IF lUsaColab
		
		cSistUtili		:= "TOTVS Colaboração"
		//Quando não existir configuraçao de parametros exibie parametros para cliente configurar
		If Empty(ColGetPar("MV_AMBIEPP",""))
			ColParametros("EPP")
		Endif

		cAmbiente := iIf(ColGetPar("MV_AMBIEPP","")=="1","Produção","Homologaçao")

		//verifica Dicionario de dados do Totvs colaboração
		//Na versão 12 é ajustado SX2 da tabela CKOCOL
		lProcessa := ColCheckUpd()

		//Verifica se Versão 11 executou update Totvs Colaboração
		IF !lProcessa
			Alert("UPDATE do TOTVS Colaboração 2.0 não aplicado.")
		Endif

		//Processa pedido de prorrogação somente se existir campos de protocolo
		If !lGravProt
			Alert('Dicionário desatualizado, favor verificar atualizações do Dicionário de dados')
			lProcessa := .F.
		Endif

Else // Verifica se TSS está no ar
	
	cSistUtili		:= "TSS"
	if lCon	:=  isConnTSS(@cError)
		cIdEnti	:= RetIdEnti()		
		aCfg := getCfgCCe(cError, cIdEnti, , , , , , , , , ,  , , ,.T.,) 
        cAmbiente   := aCfg[9]
		cVersaoTSS := getVersaoTSS(@cError)

		//Verifica versão do TSS e se é 11 ou 12

		If substr(cVersaoTSS,1,2) == '12'
			If cVersaoTSS < "12.1.014"
				lTSS := .t.
			Endif
		Else
			If cVersaoTSS < "2.58A"
				lTSS	:= .t.
			Endif
		EndIF

		IF !lTSS
			lProcessa	:= .t.
		Else
			Alert('Versão do TSS incompatível.')
		Endif

	else
		Alert('Não foi possível acessar TSS - ' + CHR(13) + CHR(10) + cError)
	endif
Endif

if lProcessa
	//Irá buscar notas fiscais de remessa de mercadoria para beneficiamento

	if Pergunte(cPerg)
		dMvPar01 := mv_par01
		dMvPar02 := mv_par02
		cMvPar03 := mv_par03
		cMvPar04 := mv_par04
		cMvPar05 := AllTrim(mv_par05)
		cMvPar06 := AllTrim(mv_par06)

		Processa({|lEnd| QueryNotas()},,,.T.)

		cFiltro	:= "F0U->F0U_FILIAL =='" + xFilial("F0U") + "'" + FSA130Filt('F0U')

		Define MsDialog oDlgPrinc Title 'Gerenciamento Suspensão ICMS - '+cSistUtili+'' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oBrowseDown:= FWMBrowse():New()
		oBrowseDown:SetDescription( 'Itens da Nota Fiscal de Remessa para Benefeciamento - Entidade ' + cIdEnti + " - TSS: " + cVersaoTSS )
		oBrowseDown:DisableDetails()
		oBrowseDown:SetMenuDef( 'FISA130' )
		oBrowseDown:SetAlias( 'F0U' )
		oBrowseDown:AddLegend( "F0U->F0U_STATUS == '01' "				, "ORANGE"		, 'Suspensão Normal')
		oBrowseDown:AddLegend( "F0U->F0U_STATUS $ '02/06/10/14'"		, "YELLOW"		, 'Pronto para Transmitir')
		oBrowseDown:AddLegend( "F0U->F0U_STATUS $ '03/07/11/15'"		, "WHITE"		, 'Transmitido, aguardando retorno')
		oBrowseDown:AddLegend( "F0U->F0U_STATUS $ '04/08/12/16'"		, "GREEN"		, 'Pedido Aceito')
		oBrowseDown:AddLegend( "F0U->F0U_STATUS $ '05/09/13/17'"		, "RED"		, 'Pedido Rejeitado')
		oBrowseDown:AddLegend( "F0U->F0U_STATUS $ '18/19/20/21'"		, "PINK"		, 'Transmissão com Erro')
		oBrowseDown:ForceQuitButton()
		oBrowseDown:SetFilterDefault( cFiltro )
		oBrowseDown:SetProfileID( '1' )
		oBrowseDown:Activate(oDlgPrinc)
		activate MsDialog oDlgPrinc Center
	endif
endif

return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
static function MenuDef()

local aRotina	:= {}

if FSA130Menu() == '1'
	//Menu Principal
	ADD OPTION aRotina TITLE 'Solicitar Prorrogação'	 ACTION 'FSA130Proc("1")' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Solicitar Cancelamento' 	 ACTION 'FSA130Proc("2")' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Editar' 					 ACTION 'FSA130Proc("3")' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar'				 ACTION 'FSA130Proc("0")' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Transmissão' 			 	 ACTION 'FSA130TRAN()'    OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Histórico' 				 ACTION 'FSA130VHIS()'    OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Sincronizar' 			 	 ACTION 'FSA130ATUS()'    OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Filtros Por Status' 	 	 ACTION 'FSA130FLT()'     OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Parametros' 				 ACTION 'FSA130PRM()' OPERATION 3 ACCESS 0

elseif FSA130Menu() == '2'
	//Menu de transmissão
	ADD OPTION aRotina TITLE 'Transmissão' 			ACTION 'FSA130TRA(oMark)' OPERATION 4 ACCESS 0 //'Agrupar Filial -> Matriz'
elseif FSA130Menu() =='3' .And. !lUsaColab
	//Menu de histórico
	ADD OPTION aRotina TITLE 'Transmissão vinculada a NFE' ACTION 'FSA130VXML()' OPERATION 2 ACCESS 0 //'Agrupar Filial -> Matriz'
endif

return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA130PRM
Função que irá exibir para usuário os parâmetros iniciais, para serem
configurados no TSS

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------

function FSA130PRM()

If lUsaColab
	ColParametros("EPP")
Else
	SpedCCePar(,.F.,'55',.T.)
Endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA130FLT
Função que realiza filtros conforme seleção do cliente

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA130FLT()
Local aStatus	:= {}
Local aPerg	:= {}
Local aRet		:= {}
Local cOpcao	:= ''

aadd(aStatus,"1 - Suspensão Normal")
aadd(aStatus,"2 - Pronto para Transmitir")
aadd(aStatus,"3 - Transmitido, aguardando retorno")
aadd(aStatus,"4 - Pedido Aceito")
aadd(aStatus,"5 - Pedido Rejeitado")
aadd(aStatus,"6 - Transmissão com Erro")
aadd(aStatus,"7 - Todas")
aadd(aStatus,"8 - Ultrpassaram Data Limite")

aadd(aPerg,{2,'Filtro por Status',cOpFiltro,aStatus,105,".T.",.F.,".T."})

IF ParamBox(aPerg,"Filtro",aRet,,,.T.,,,,cFilAnt,.T.,.T.)
	cOpcao	:= SubStr(aRet[1],1,1)
	cOpFiltro	:= cOpcao
	Do CAse
		Case cOpcao	== '1'
			cFiltro	:= "F0U->F0U_FILIAL =='" + xFilial("F0U") + "' .AND. F0U->F0U_STATUS == '01' " + FSA130Filt('F0U')
		Case cOpcao	== '2'
			cFiltro	:= "F0U->F0U_FILIAL =='" + xFilial("F0U") + "' .AND. F0U->F0U_STATUS $ '02/06/10/14' " + FSA130Filt('F0U')
		Case cOpcao	== '3'
			cFiltro	:= "F0U->F0U_FILIAL =='" + xFilial("F0U") + "' .AND. F0U->F0U_STATUS $ '03/07/11/15' " + FSA130Filt('F0U')
		Case cOpcao	== '4'
			cFiltro	:= "F0U->F0U_FILIAL =='" + xFilial("F0U") + "' .AND. F0U->F0U_STATUS $ '04/08/12/16' " + FSA130Filt('F0U')
		Case cOpcao	== '5'
			cFiltro	:= "F0U->F0U_FILIAL =='" + xFilial("F0U") + "' .AND. F0U->F0U_STATUS $ '05/09/13/17' " + FSA130Filt('F0U')
		Case cOpcao	== '6'
			cFiltro	:= "F0U->F0U_FILIAL =='" + xFilial("F0U") + "' .AND. F0U->F0U_STATUS $ '18/19/20/21' " + FSA130Filt('F0U')
		Case cOpcao	== '7'
			cFiltro	:= "F0U->F0U_FILIAL =='" + xFilial("F0U") + "'"
		Case cOpcao	== '8'
			cFiltro	:= "F0U->F0U_FILIAL =='" + xFilial("F0U") + "' .AND. F0U->F0U_LIMITE <  '" + dTos(Date()) + "'"
	End

	oBrowseDown:SetFilterDefault( cFiltro )

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DtLimite
Função que calcula data limite da suspensão, considerando o status da
movimentação

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function DtLimite(dEmissao, cStatus)

Local  dRet			:= cTod('  /  /    ')

IF cStatus $ '01/02/03/05/12'
	//Suspensão Normal, adiciona somente 180 dias
	dRet := dEmissao + 180
ElseIF cStatus $ '04/06/07/09/10/11/13/16'
	//1ª Prorrogação ativa, então adiciona 360 dias
	dRet := dEmissao + 360
ElseIF cStatus $ '08/14/15/17'
	//1ª Prorrogação ativa, então adiciona 540 dias
	dRet := dEmissao + 540
EndIF

Return dRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QueryNotas
Função que irá fazer query no livro, considerando saldo na B6, para popular
tabela F0U

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function QueryNotas()

Local cCampos		:= ''
Local cAliasSd2		:= GetNextAlias()
local cAliasSB6		:= ''
Local cJoinB6		:= ''
Local cJoinf3		:= ''
Local cJoinAll		:= ''
Local cMvCODRSEF	:= SuperGetMv("MV_CODRSEF", .F., "'','100'")

DbSelectArea("SF3")
DbSetOrder(1)

DbSelectArea("F0U")
DbSetOrder(1)

DbSelectArea("F0V")
DbSetOrder(1)

cCampos	:= "F3.F3_CHVNFE,D2.D2_DOC, D2.D2_SERIE, D2.D2_CLIENTE, D2.D2_LOJA, D2.D2_COD, D2.D2_EMISSAO, D2.D2_CF, D2.D2_ITEM, D2.D2_QUANT, D2.D2_TOTAL, B6.B6_SALDO"

//JOIN com SB6
cJoinB6	:= "INNER JOIN "+RetSqlName("SB6")+" B6 ON(B6.B6_FILIAL='"+xFilial("SB6")+"' AND B6.B6_DOC = D2.D2_DOC and  "
cJoinB6    += 'B6.B6_SERIE = D2.D2_SERIE and B6.B6_LOCAL = D2.D2_LOCAL and B6.B6_PRODUTO = D2.D2_COD and B6.B6_CLIFOR = D2.D2_CLIENTE and '
cJoinB6    += "B6.B6_LOJA = D2.D2_LOJA and B6.B6_IDENT = D2.D2_IDENTB6 AND  B6.D_E_L_E_T_=' ')"

//JOIN com SF3
cJoinf3	= "INNER JOIN "+RetSqlName("SF3")+" F3 ON(F3.F3_FILIAL='"+xFilial("SF3")+"' AND F3.F3_NFISCAL= D2.D2_DOC and  "
cJoinf3 	+= 'F3.F3_SERIE = D2.D2_SERIE and F3.F3_CLIEFOR = D2.D2_CLIENTE and '
cJoinf3 	+= "F3.F3_LOJA = D2.D2_LOJA and F3.F3_CFO = D2.D2_CF AND F3.F3_CHVNFE <> ' ' AND "
cJoinF3 	+= FSA130Filt('SF3', cMvCODRSEF)
cJoinf3 	+= " F3.D_E_L_E_T_=' ')"

cJoinAll	:= cJoinB6 + cJoinf3

cCampos := "%" + cCampos + "%"
cJoinAll := "%" + cJoinAll + "%"

BeginSql Alias cAliasSd2
	COLUMN D2_EMISSAO AS DATE

	SELECT
		%Exp:cCampos%
	FROM
		%Table:SD2% D2
		%Exp:cJoinAll%

	WHERE
		D2.D2_FILIAL=%xFilial:SD2%  AND
		D2.%NotDel%

EndSql


cAliasSB6	:= cAliasSd2

ProcRegua (2)
IncProc("Selecionando documentos...")
//Atualiza informações na F0U
Do While !(cAliasSd2)->(Eof())

	If !F0U->(MSSEEK(xFilial('F0U')+(cAliasSd2)->D2_DOC+(cAliasSd2)->D2_SERIE+(cAliasSd2)->D2_ITEM+(cAliasSd2)->D2_COD+(cAliasSd2)->F3_CHVNFE))
		RecLock('F0U',.T.)
		F0U->F0U_FILIAL	:= xFilial('F0U')
		F0U->F0U_NUMNF	:= (cAliasSd2)->D2_DOC
		F0U->F0U_SER	:= (cAliasSd2)->D2_SERIE
		F0U->F0U_EMISSA	:= (cAliasSd2)->D2_EMISSAO
		F0U->F0U_LIMITE	:= DtLimite((cAliasSd2)->D2_EMISSAO,'01')
		F0U->F0U_CLIFOR	:= (cAliasSd2)->D2_CLIENTE
		F0U->F0U_LOJA	:= (cAliasSd2)->D2_LOJA
		F0U->F0U_CHVNFE	:= (cAliasSd2)->F3_CHVNFE
		F0U->F0U_ITEM	:= (cAliasSd2)->D2_ITEM
		F0U->F0U_PROD	:= (cAliasSd2)->D2_COD
		F0U->F0U_QUANTD	:= (cAliasSd2)->D2_QUANT
		F0U->F0U_QUANTN	:= (cAliasSd2)->B6_SALDO
		F0U->F0U_CHVNFE	:= (cAliasSd2)->F3_CHVNFE
		F0U->F0U_STATUS	:= '01'
		If lF0UCfop
			F0U->F0U_CFOP := (cAliasSd2)->D2_CF
		EndIf
		MsUnLock()
	Else
		RecLock('F0U',.F.)
		F0U->F0U_QUANTD	:= (cAliasSd2)->D2_QUANT
		F0U->F0U_QUANTN	:= (cAliasSd2)->B6_SALDO
		F0U->F0U_LIMITE	:= DtLimite((cAliasSd2)->D2_EMISSAO,F0U->F0U_STATUS)
		If lF0UCfop
			F0U->F0U_CFOP := (cAliasSd2)->D2_CF
		EndIf
		MsUnLock()
	EndIF

	(cAliasSd2)->(DBSKIP())
EndDo

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QueryNotas
Função chamada do menu do Browse principal, irá fazer as chamadas para
visualização, solicitação de prorrogação e cancelamento, e editar as quantidades

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA130Proc(cAcao)

CPROC	:= cAcao

If cAcao == '0'
	CDESCRF130	:= 'Visualização'
ElseIf cAcao == '1' //Solicitação de Prorrogação
	CDESCRF130	:= 'Solicitação de Prorrogação'
ElseIF cAcao == '2' //Solicitação de Cancelamento
	CDESCRF130	:= 'Solicitação de Cancelamento'
ElseIF cAcao == '3' //eDIÇÃO
	CDESCRF130	:= 'Editar Quantidades'
EndIF
If cAcao == '0'
	FWExecView('Solicitar Prrogação - ' + CDESCRF130,'FISA130', MODEL_OPERATION_VIEW,,{ || .T. }, { || .T. } )
Else
	FWExecView('Solicitar Prrogação - ' + CDESCRF130,'FISA130', MODEL_OPERATION_UPDATE,,{ || .T. }, { || .T. } )
EndIF
CPROC	:= ''

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA130STS
Função que irá popular a lista de status disponíveis

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA130STS()

Local cRet	:= ''

cRet	:= '01=Suspensão Normal;'
cRet	+= '02=1ª Prorrogação Liberada para Transmissão;03=1ª Prorrogação Transmitida;04=1ª Prorrogação Deferida;05=1ª Prorrogação Indeferida;18=1ª Prorrogação Erro;'
cRet	+= '06=2ª Prorrogação Liberada para Transmissão;07=2ª Prorrogação Transmitida;08=2ª Prorrogação Deferida;09=2ª Prorrogação Indeferida;19=2ª Prorrogação Erro;'
cRet	+= '10=1ª Cancelamento Liberado para Transmissão;11=1ª Cancelamento Transmitido;12=1ª Cancelamento Deferido;13=1ª Cancelamento Indeferido;20=1ª Cancelamento Erro;'
cRet	+= '14=2ª Cancelamento Liberado para Transmissão;15=2ª Cancelamento Transmitido;16=2ª Cancelamento Deferido;17=2ª Cancelamento Indeferido;21=2ª Cancelamento Erro;'

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA130Desc
Função utilizada junto com a view, para atualização da descrição e status

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA130Desc()
	Default CDESCRF130 := ""
	Default CPROC := ""
Return {CDESCRF130,CPROC}


Function FSA130Menu()

Local cRet	:= ''

IF type('CMENU') <> 'U'
	cRet	:= CMENU
Else
	cRet	:= '1'
EndIF

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} DefStatRet
Função que realiza a Definição dos Status

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function DefStatRet(cEvento, cRetSefaz,cStatus)

Local cRet	:= ''
Do Case
	Case cEvento == '411500' .AND. cStatus == '03'
		//Retorno da solicitação da 1ª Prorrogação
		If cRetSefaz == '1' .Or. cRetSefaz $ '100|150'
			cRet	:= '04'//Deferido 1ª Prorrogação
		Else
			cRet	:= '05'//Indeferido 1ª Prorrogação,
		EndIF

	Case cEvento == '411501' .AND. cStatus == '07'
		//Retorno da solicitação da 2ª Prorrogação
		If cRetSefaz == '1' .Or. cRetSefaz $ '100|150'
			cRet	:= '08'//Deferido 2ª Prorrogação
		Else
			cRet	:= '09'//Indeferido 2ª Prorrogação
		EndIF

	Case cEvento == '411502' .AND. cStatus == '11'
		//Retorno da solicitação do 1ª Cancelamento
		If cRetSefaz == '1' .Or. cRetSefaz $ '100|150'
			cRet	:= '12'//Deferido 1ª Cancelamento
		Else
			cRet	:= '13'//Indeferido 1ª Cancelamento,
		EndIF
	Case cEvento == '411503' .AND. cStatus == '15'
		//Retorno da solicitação do 2ª Cancelamento
		If cRetSefaz == '1' .Or. cRetSefaz $ '100|150'
			cRet	:= '16'//Deferido 2ª Cancelamento
		Else
			cRet	:= '17'//Indeferido 2ª Cancelamento
		EndIF
End

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA130TRAN
Função que ira montar browse para usuário poder selecionar quais documentos
serão transmitidos

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA130TRAN()

Local oMark := FWMarkBrowse():New()
CMENU		:= '2'
oMark:SetAlias('F0U')
oMark:SetMenuDef('FISA130')
oMark:SetDescription('Seleção dos Itens a Serem Transmitidos (' + cAmbiente + ')')
oMark:SetFieldMark( 'F0U_OK' )
oMark:SetFilterDefault( "F0U_STATUS $ '02/06/10/14/18/19/20/21'" )
oMark:DisableDetails()
oMark:SetMark('X', 'F0U', 'F0U_OK')
oMark:SetAllMark( { || .T. } )
oMark:DisableReport()
oMark:DisableConfig()
oMark:SetOnlyFields({'F0U_FILIAL','F0U_NUMNF','F0U_SER','F0U_EMISSA','F0U_CLIFOR','F0U_LOJA','F0U_ITEM','F0U_PROD','F0U_CHVNFE'})
oMark:ForceQuitButton()
oMark:Activate()

CMENU	:= '1'

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA130TRA
Função que irá chamar o processo de transmissão das movimentações selecionadas

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA130TRA(oMark)

Local lEnd	:= .F.

Processa({|lEnd| AtuTrans(oMark)},,,.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuTrans
Função que realiza a transmissão das movimentações

Quando utilizado TOTVS colaboração 2.0 o array aXML terá para cada posição uma nota, podendo existir diversas posições no array.
TOTVS colaboração espera que cada nota esteja em seu respectivo XML para que NeoGrid apenas assine XML.

Quando for utilizado TSS o array aXML terá somente uma posição, pois TSS espera receber apenas um XML com diversas notas.


@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Function AtuTrans(oMark)
Local cStatus		:= ''
Local cMarca 		:= oMark:Mark()
Local lProcessou	:= .F.
Local cEvento		:= ''
Local cXml			:= ''
Local cChaveTmp		:= ''
Local oWs			:= WsNFeSBra():New()
Local cURL    		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local lOk			:= .F.
Local nPos			:= 0
Local cRetorno		:= ''
Local aRetorno		:= {}
Local nContNf		:= 0
Local aCanc			:= {}
Local cEventCanc	:= ''
Local cIdCanc		:= ''
Local cChaveItem	:= ''
Local nCont			:= 0
Local aNfe			:= {}
Local nX			:= 0
Local aXML			:={}

aAdd(aXML, {})
nX	:=	Len (aXML)
aAdd(aXML[nX],'') //XML processado com itens
aAdd(aXML[nX],'') //Tipo de de Evento

F0U->(DbGoTop ())

If !lUsaColab
	//Abre arquivo xml
	aXML[nX][1]	:= TrabXml('1')
Endif

DbSelectArea("F0V")
DbSetOrder(4)

//Quando for Colaboração utiliza somente TrabXml('4')
ProcRegua (2)
IncProc("Gerando arquivo XML...")
F0U->(DbGoTop ())
While !F0U->( EOF() )
	If oMark:IsMark(cMarca) .AND. F0U->F0U_STATUS $ '02/06/10/14/18/19/20/21'

		lProcessou	:= .T.
		F0UStatus('F0U',@cStatus,@cEvento)

		IF cEvento $ '111502/111503'
			//Eventos de Cancelamento
			cEventCanc	:= ''
			cIdCanc		:= ''
			IF cEvento == '111502'
				cEventCanc	:= '111500'
			ElseIF cEvento == '111503'
				cEventCanc	:= '111501'
			EndIF

			//Irá procurar na F0V o último ID válido e transmiitido, para poder fazer solicitação de cancelamento
			IF F0V->(MSSEEK(xFilial('F0V')+F0U->F0U_CHVNFE +F0U->F0U_ITEM+cEventCanc))
				While !F0V->( EOF() ) .AND. F0V->F0V_CHVNFE+F0V->F0V_ITEM+ F0V->F0V_EVENTO == F0U->F0U_CHVNFE +F0U->F0U_ITEM+cEventCanc
					cIdCanc	:= F0V->F0V_IDTSS
					F0V->( DBSKIP() )
				EndDo
			EndIF

			nPos := aScan (aCanc, {|aX| aX[1] ==  F0U->F0U_CHVNFE .AND.  aX[2] ==  cEvento .AND. aX[3] ==  cIdCanc   })

			//A combinação de chave, evento e ID não poderá ser repetir
			IF nPos == 0
				aAdd(aCanc, {})
				nPos := Len(aCanc)
				aAdd (aCanc[nPos], F0U->F0U_CHVNFE)
				aAdd (aCanc[nPos], cEvento)
				aAdd (aCanc[nPos], cIdCanc)
				// Dados da Nfe
				If lUsaColab
					aAdd(aCanc[nPos],F0U->(Recno()))	//04 - Recno
					aAdd(aCanc[nPos],F0U->F0U_SER) 		//05 - Serie
					aAdd(aCanc[nPos],F0U->F0U_NUMNF) 	//06 - Numero

					If cEvento == '111502' // 1º cancelamento
						aAdd(aCanc[nPos],F0U->F0U_PROT1) 	//07 - Protocolo de autilizção
					Elseif cEvento == '111503' // 2º cancelamento
						aAdd(aCanc[nPos],F0U->F0U_PROT2) 	//07 - Protocolo de autilizção
					Endif
				Endif
			EndIF
		Else
			//Eventos de prorrogação
			IF cChaveTmp <> F0U->F0U_CHVNFE+F0U->F0U_STATUS
				//Se mudar combinação de chave+Status significa que terá que adicionar nova tag com evento e chave
				If !Empty(cChaveTmp)

					//Fechamento do detEvento
					IF !lUsaColab
						aXML[nX][1]	+= TrabXml('5',cEvento,F0U->F0U_CHVNFE)
					Endif
					//Quando Totvs Colaboração deve ser incluido novo XML com status e ChavesS
					If lUsaColab
						aAdd(aXML, {})
						nX	:=	Len(aXML)
						aAdd(aXML[nX],'') //XML processado com itens
						aAdd(aXML[nX],'') //Tipo de de Evento
					Endif
				EndIF

				//Início evento
				If !lUsaColab
					aXML[nX][1]	+= TrabXml('3',cEvento,F0U->F0U_CHVNFE)
				Endif
				aXML[nX][2] := cEvento

				// Dados da Nfe
				If lUsaColab
					aAdd(aXML[nX],F0U->F0U_CHVNFE) 	//03 - Chave da Nfe
					aAdd(aXML[nX],F0U->(Recno()))	//04 - Recno
					aAdd(aXML[nX],F0U->F0U_SER) 	//05 - Serie
					aAdd(aXML[nX],F0U->F0U_NUMNF) 	//06 - Numero
				Endif
			EndIF

			cChaveTmp	:= F0U->F0U_CHVNFE+F0U->F0U_STATUS

			//Adicionar item no XML
			nContNf++
			If !lUsaColab
				aXML[nX][1]	+= TrabXml('4','','',alltrim(STR(VAL(F0U->F0U_ITEM))),ALLtrim(STR(F0U->F0U_QUANTS)))
			Else
				aXML[nX][1]	+= TrabXml('8','','',alltrim(STR(VAL(F0U->F0U_ITEM))),ALLtrim(STR(F0U->F0U_QUANTS)))
			Endif
		EndIF


	EndIf
	F0U->( dbSkip() )
End

If !Empty(cChaveTmp) .And. !lUsaColab
	aXML[nX][1]	+= TrabXml('5',cEvento,F0U->F0U_CHVNFE)
EndIF

ASort(aCanc, , , {|x,y|x > y})
//Irá adicionar os cancelamentos
//Quando for Colaboração utiliza somente TrabXml('6') e TrabXml('7')
cChaveItem	:= ''
For nCont	:= 1 to Len(aCanc)
	If cChaveItem <> aCanc[nCont][1]+aCanc[nCont][2]
		If lUsaColab .And. !Empty(cChaveItem)
			aAdd(aXML, {})
			nX	:=	Len (aXML)
			aAdd(aXML[nX],'') //XML processado com itens
			aAdd(aXML[nX],'') //Tipo de de Evento
		Endif

		//Início evento
		If !lUsaColab
			aXML[nX][1]	+= TrabXml('3',aCanc[nCont][2],aCanc[nCont][1])
		Endif


		nContNf++
	EndIF

	aXML[nX][1]	+= Iif(lUsaColab,TrabXml('9'),TrabXml('6'))
	aXML[nX][1]	+= aCanc[nCont][3]
	aXML[nX][1]	+= Iif(lUsaColab,TrabXml('10'),TrabXml('7'))

	If lUsaColab
		aXML[nX][2] := aCanc[nCont][2] //02 - Tipo de de Evento
		aAdd(aXML[nX],aCanc[nCont][1]) //03 - Chave da Nfe
		aAdd(aXML[nX],aCanc[nCont][4]) //04 - Recno
		aAdd(aXML[nX],aCanc[nCont][5]) //05 - Serie
		aAdd(aXML[nX],aCanc[nCont][6]) //06 - Numero
		aAdd(aXML[nX],aCanc[nCont][3]) //07 - IdCanc
		aAdd(aXML[nX],aCanc[nCont][7]) //08 - Protocolo de autilizção da emissao do EPP
	Endif

	If !lUsaColab
		aXML[nX][1]	+= TrabXml('5')
	Endif

	cChaveItem :=  aCanc[nCont][1]+aCanc[nCont][2]
Next nCont

//Finaliza geração do arquivo XML
If !lUsaColab
	aXML[nX][1]	+= TrabXml('2')
Endif

ProcRegua (2)
IncProc("Transmitindo arquivo XML...")

IF lProcessou
	//Envia informações em xml para o TSS transmitir

	If lUsaColab
		lok	:= MontXmlEpp(aXML,@aRetorno,@cRetorno)
	Else
		lok	:= EnviaTSS(aXML[nX][1],@aRetorno,@cRetorno)
	Endif

	If lOk
		IncProc("Arquivo XML Transmitido...")
		//Atualiza histórico com ID do TSS, considerando combinação de Evento + chavenfe
		ProcRegua (nContNf+1)
		IncProc("Atualizando Status...")
		F0U->(DbGoTop ())
		While !F0U->( EOF() )
			If oMark:IsMark(cMarca) .AND. F0U->F0U_STATUS $ '02/06/10/14/18/19/20/21'

				IncProc("Atualizando Status..." + F0U->F0U_NUMNF )

				F0UStatus('F0U',@cStatus,@cEvento)

				//Procura evento +chavenfe
				nPos:=aScan(aRetorno,{|X| Substr(X,3,6) + Substr(X,9,44) ==cEvento + F0U->F0U_CHVNFE})
				If nPos > 0
					//Atualiza Status na F0U
					RecLock('F0U',.F.)
					F0U->F0U_STATUS	:= cStatus
					F0U->F0U_EVEESP	:= '411'+Substr(aRetorno[nPos],6,3)
					F0U->F0U_EVEENV	:= Substr(aRetorno[nPos],3,6)
					F0U->F0U_IDTSST	:= aRetorno[nPos]
					F0U->F0U_MONOK	:= ''
					MsUnLock()
					//Atualiza Histórico
					FSA130HIST(F0U->F0U_CHVNFE, F0U->F0U_ITEM, F0U->F0U_STATUS,aRetorno[nPos],'Transmitido - Aguardando Retorno da SEFAZ', cEvento, Alltrim(Str(Val(SubStr(aRetorno[nPos],53,2)))))
				EndIF

			EndIf
			F0U->( dbSkip() )
		End
		MsgInfo('Transfissão efetuada com sucesso, ' + alltrim(str(nContNf)) + ' itens foram transmitidos ')

	Else
		If !Empty(cRetorno)
			MsgAlert(cRetorno)
		Endif
	EndIF

EndIF

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} F0UStatus
Define novo status e evento para movimentação trasmitida

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function F0UStatus(cAliasF0U,cStatus,cEvento)

Default cStatus	:= ''
Default cEvento	:= ''

IF (cAliasF0U)->F0U_STATUS $ '02/18'
	cStatus	:= '03'
	cEvento	:= '111500'
ElseIF (cAliasF0U)->F0U_STATUS $ '06/19'
	cStatus	:= '07'
	cEvento	:= '111501'
ElseIF (cAliasF0U)->F0U_STATUS $ '10/20'
	cStatus	:= '11'
	cEvento	:= '111502'
ElseIF (cAliasF0U)->F0U_STATUS $ '14/21'
	cStatus	:= '15'
	cEvento	:= '111503'
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} EnviaTSS
Função que irá enviar arquivo xml gerado para o TSS

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function EnviaTSS(cXml,aRetorno,cRetorno)

Local oWs			:= WsNFeSBra():New()
Local cURL    	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local lok			:= .F.
Local cErro		:= ''

oWs:cUserToken    := "TOTVS"
oWs:cID_ENT       := cIdEnti
oWs:cXML_LOTE     := cXml
oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"
lok					 := oWs:RemessaEvento()

If lok
	If ValType("oWS:oWsRemessaEventoResult:cString") <> "U"
		If ValType("oWS:oWsRemessaEventoResult:cString") == "A"
			aRetorno:={oWS:oWsRemessaEventoResult:cString}
		Else
			aRetorno:=oWS:oWsRemessaEventoResult:cString
		EndIf
	Endif
Else
	cErro	:= IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
Endif

If lok
	cRetorno := '"Você concluíu com sucesso a transmissão do Protheus para o Totvs Services SPED."'+CRLF
Else
	cRetorno := "Houve erro durante a transmissão para o Totvs Services SPED."+CRLF+CRLF
	cRetorno += cErro
EndIf

Return lok

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA130HIST
Função que grava o histórico de transmissão

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA130HIST(cChaveNfe, cIten, cStatus,cIdTSS,cDescr, cEvento, cSeq )

RecLock('F0V',.T.)
F0V->F0V_FILIAL		:= xFilial('F0V')
F0V->F0V_ID			:= FWUUID('F0V')
F0V->F0V_DTOCOR		:= Date()
F0V->F0V_HORA		:= Time()
F0V->F0V_STATUS		:= cStatus
F0V->F0V_CHVNFE		:= cChaveNfe
F0V->F0V_ITEM		:= cIten
F0V->F0V_EVENTO		:= cEvento
F0V->F0V_SEQ		:= cSeq
F0V->F0V_DESCR		:= cDescr
F0V->F0V_IDTSS		:= cIdTSS

MsUnLock()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TrabXml
Função auxiliar para geração do arquivo xml

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function TrabXml(cOpcao,cEvento,cChave,cNumItem,cQtde,cIdToCanc)

Local cXml	:= ''
Default cEvento	:= ''
Default cChave	:= ''
Default cNumItem	:= ''
Default cQtde	:= ''
Default cIdToCanc	:= ''

If cOpcao =='1'
	//Tags do início do XML
	cXml += MontaXML("envEvento",,,,,,,.T.,.F.,.F.)
	cXml += MontaXML("eventos"	,,,,,,,.T.,.F.,.F.)
ElseIF cOpcao =='2'
	//Tags da final do Xml
	cXml += MontaXML("eventos"	,,,,,,,.F.,.T.,.F.)
	cXml += MontaXML("envEvento",,,,,,,.F.,.T.,.F.)
ElseIF cOpcao =='3'
	//Início evento
	cXml += MontaXML("detEvento",,,,,,,.T.,.F.,.F.)
	cXml += MontaXML("tpEvento",cEvento,,,,,,.T.,.T.,.F.)
	cXml += MontaXML("chNFe",cChave		,,,,,,.T.,.T.,.F.)
ElseIF cOpcao =='4'
	//Itens XML
	cXml += MontaXML("itemPedido",,,,,,,.T.,.F.,.F.)
	cXml += MontaXML("numItem",cNumItem,,,,,,.T.,.T.,.F.)
	cXml += MontaXML("qtdeItem",cQtde,,,,,,.T.,.T.,.F.)
	cXml += MontaXML("itemPedido",,,,,,,.F.,.T.,.F.)
ElseIF cOpcao =='5'
	//Fechamento do detEvento
	cXml += MontaXML("detEvento",,,,,,,.F.,.T.,.F.)
ElseIF cOpcao =='6'
	//Abertura do item de cancelamento
	cXml += MontaXML("idToCanc",,,,,,,.T.,.F.,.F.)
ElseIF cOpcao =='7'
	//fechamento do item de cancelamento
	cXml += MontaXML("idToCanc",,,,,,,.F.,.T.,.F.)
ElseIF cOpcao =='8'
	//Itens XML Colaboração
	cXml += MontaXML('itemPedido numItem="'+cNumItem+'"',,,,,,,.T.,.F.,.F.)
	//cXml += MontaXML("numItem",cNumItem,,,,,,.T.,.T.,.F.)
	cXml += MontaXML("qtdeItem",cQtde,,,,,,.T.,.T.,.F.)
	cXml += MontaXML("itemPedido",,,,,,,.F.,.T.,.F.)
ElseIF cOpcao =='9'
	//Abertura do item de cancelamento Colaboração
	cXml += MontaXML("idPedidoCancelado",,,,,,,.T.,.F.,.F.)
ElseIF cOpcao =='10'
	//fechamento do item de cancelamento Colaboração
	cXml += MontaXML("idPedidoCancelado",,,,,,,.F.,.T.,.F.)
EndIF

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} DefErro
Função que retorna o status de erro, caso o TSS não conseguir realizar a transmissão

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function DefErro(cStatus)
Local cRet	:= ''

Do Case

	Case cStatus == '03' // 1ª Prorrogação Erro
		cRet	:= '18'
	Case cStatus == '07' // 2ª Prorrogação Erro;
		cRet	:= '19'
	Case cStatus == '11' // 1ª Cancelamento Erro;
		cRet	:= '20'
	Case cStatus == '15' // 2ª Cancelamento Erro;
		cRet	:= '21'
End

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkMonitor
Função que irá verificar se o item enviado para o TSS foi realmente transmitido
para a SEFAZ, ou se deu algum erro.

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ChkMonitor(cUrl,cAliasF0U)

Local oWS
Local lOk		:= .F.
Local aMonitor	:= {}
Local nStatus	:= 0
Local cIdEvento	:= ''
Local cMotEvent	:= ''
Local cErro		:= ''

DbSelectArea("F0U")
DbSetOrder(4)

oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN	:= "TOTVS"
oWS:cID_ENT		:= cIdEnti
oWS:_URL			:=  AllTrim(cURL)+"/NFeSBRA.apw"

ProcRegua ((cAliasF0U)->(RecCount ()))
IncProc("Atualizando Monitor...")

Do While !(cAliasF0U)->(Eof())

	IncProc("Atualizando Monitor, chave -" +   (cAliasF0U)->F0U_CHVNFE)

	If !Empty((cAliasF0U)->F0U_EVEENV)
		oWS:cEVENTO		:=(cAliasF0U)->F0U_EVEENV
		oWS:cCHVINICIAL	:= (cAliasF0U)->F0U_CHVNFE
		oWS:cCHVFINAL		:= (cAliasF0U)->F0U_CHVNFE
		lOk:=oWS:NFEMONITORLOTEEVENTO()

		If lOk
			// Tratamento do retorno do evento
			If Type("oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento") <> "U"

				If Valtype(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) <> "A"
					aMonitor := {oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento}
				Else
					aMonitor := oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento
				EndIF

				nStatus	:= aMonitor[1]:nStatus

				IF nStatus == 5 .OR. nStatus == 6
					//OCorreu erro e evento não fo vinculado com Nfe
					//Precisa atualizar F0U para que usuário veja o erro e retransmita

					//Seek na F0V e adiciona em array o número da chave e item
					//Depois processar o array atualizando status da F0U e atualizando histórico tbm
					cIdEvento	:=  aMonitor[1]:cId_Evento
					cMotEvent	:= aMonitor[1]:cCMotEven

					IF F0U->(MSSEEK(xFilial('F0U')+(cAliasF0U)->F0U_CHVNFE+cIdEvento+(cAliasF0U)->F0U_ITEM ))

						//Atualiza F0U e Historico
						RecLock('F0U',.F.)

						IF nStatus == 5
							F0U->F0U_STATUS	:= DefErro(F0U->F0U_STATUS)
							FSA130HIST(F0U->F0U_CHVNFE, F0U->F0U_ITEM, F0U->F0U_STATUS,cIdEvento,cMotEvent, (cAliasF0U)->F0U_EVEESP, SubStr(cIdEvento,52,2))
						ElseIf nStatus == 6
							F0U->F0U_MONOK	:= '1'
						EndIF

						MsUnLock()

					EndIF

				EndIF
			EndIF
		 Else
			cErro	:= IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			Exit
		EndIF
	EndIF

	(cAliasF0U)->(DbSkip())
EndDo

IF !Empty(cErro)
	Aviso("SPED",cErro,{"OK"},3)
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA130VXML
Tela para visualização do XML transmitido e assinado

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA130VXML()

Local oWS
Local lOk	:= .F.
Local cURL  :=	''
Local cXml	:= ''
Local nCont	:= 0

IF F0V->F0V_STATUS $ '03/07/11/15'
	cURL    	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN	:= "TOTVS"
	oWS:cID_ENT		:= cIdEnti
	oWS:_URL			:= AllTrim(cURL)+"/NFeSBRA.apw"
	oWS:cID_EVENTO	:= F0V->F0V_EVENTO
	oWS:cChvInicial	:= F0V->F0V_CHVNFE
	oWS:cChvFinal		:= F0V->F0V_CHVNFE
	lOk				:= oWS:NFEEXPORTAEVENTO()
	If lOk
		For nCont := 1 to Len(OWS:OWSNFEEXPORTAEVENTORESULT:CSTRING)
			cXml	:= EncodeUTF8(OWS:OWSNFEEXPORTAEVENTORESULT:CSTRING[1])
			Aviso("Visualização do XML Assinado",cXml,{"Ok"},3)
		Next nCont

	Else
		Alert('Evento Transmitido ainda não foi Vinculado pela Sefaz com a Chave Eletrônica')
	EndIF
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA130VHIS
Função que monta o browse para visualização do histórico

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA130VHIS()

Local oHist
Local cFiltro	:= ''

DbSelectArea("F0V")
DbSetOrder(1)

CMENU	:= '3'
cFiltro	:= "F0V->F0V_FILIAL =='" + xFilial("F0V") + "' .AND. F0V->F0V_CHVNFE == '" + F0U->F0U_CHVNFE + "' .AND. F0V->F0V_ITEM == '" + F0U->F0U_ITEM + "'"

oHist := FWmBrowse():New()
oHist:SetOnlyFields({'F0V_STATUS','F0V_CHVNFE','F0V_ITEM','F0V_EVENTO','F0V_SEQ','F0V_DESCR'})
oHist:SetDescription( 'Visualização do Histórico')
oHist:SetAlias( 'F0V' )
oHist:AddLegend( "F0V->F0V_STATUS $ '03/07/11/15'"					, "BR_VERDE_ESCURO"		, 'Envio para SEFAZ')
oHist:AddLegend( "F0V->F0V_STATUS $ '04/08/12/16/05/09/13/17'"		, "BR_VIOLETA"		, 'Retorno da SEFAZ	')
oHist:AddLegend( "F0V->F0V_STATUS $ '18/19/20/21'"					, "BLACK"		, 'Erro ao Transmitir')
oHist:DisableDetails()
oHist:ForceQuitButton()
oHist:SetFilterDefault( cFiltro )
oHist:Activate()
CMENU	:= '1'
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DescStatus
Função que trata a descrição conforme código de retorno da SEFAZ

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function DescStatus(cCodDes, lCanc)

Local cRet	:= ''

IF lCanc
	//Mensagens de cancelamento
	DO Case
		Case cCodDes == '1'
			cRet	:= 'Autorizado pelo Fisco'
		Case cCodDes == '2'
			cRet	:= 'O pedido de Prorrogação já foi cancelado por outro Evento'
		Case cCodDes == '3'
			cRet	:= 'Solicitação do Pedido fora do Prazo'
		Case cCodDes == '4'
			cRet	:= 'Tentativa de cancelamento de prorrogação de ate 360 dias de um item que foi prorrogado por mais de 360 dias. Cancele a prorrogação por mais 360 dias previamente.'
	End
Else
	//Mensagens de prorrogação
	DO Case
		Case cCodDes == '1'
			cRet	:= 'Autorizado pelo Fisco'
		Case cCodDes == '2'
			cRet	:= 'Manifestação do Destinatário - Desconhece a Operação'
		Case cCodDes == '3'
			cRet	:= 'Manifestação do Destinatário - Operação Não Realizada'
		Case cCodDes == '4'
			cRet	:= 'O Item Não Consta na NFe'
		Case cCodDes == '5'
			cRet	:= 'O Item não Consta no pedido de Prorrogação do 1º prazo'
		Case cCodDes == '6'
			cRet	:= 'CFOP não autorizado'
		Case cCodDes == '7'
			cRet	:= 'Quantidade Inconsistente com a quantidade do Item'
		Case cCodDes == '8'
			cRet	:= 'Solicitacao do Pedido fora do Prazo'
		Case cCodDes == '9'
			cRet	:= 'Pedido de Prorrogacao Cancelado pelo Contribuinte'
	End

EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AbrePedido
Função que abre o pedido retornado no XML da SEFAZ

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function AbrePedido(cChave, cItem,cEvento,oXmlExp, nSeq, cAliasF0U)

Local clEvento		:= ''
Local cSeq			:= ''
Local cIdRet		:= ''
Local clItem		:= ''
Local cDefIndef		:= ''
Local cDescr		:= ''
Local cProtocol		:= ''
Local nlChave		:= ''
Local clSeq			:= ''
Local cJustStat		:= ''
Local cChvNFE       := ''
Local nCont			:= 0
Local nContItem		:= 0
Local aRet			:= {}
Local cIdOri		:= ''

Default cAliasF0U   := ""

If XmlChildEx(oXmlExp:_RETCONSSITNFE,"_PROCEVENTONFE") == Nil

	If ValType(XmlChildEx(oXmlExp:_RETCONSSITNFE,"_PROTNFE")) == "O" .And. ValType(XmlChildEx(oXmlExp:_RETCONSSITNFE:_PROTNFE,"_INFPROT")) == "O"

		If ValType(oXmlExp:_RETCONSSITNFE:_PROTNFE:_INFPROT:_CHNFE:TEXT) == "C"
			cChvNFE := oXmlExp:_RETCONSSITNFE:_PROTNFE:_INFPROT:_CHNFE:TEXT
		EndIf

		If cChvNFE == (cAliasF0U)->F0U_CHVNFE

			aRet    := {}
			cIdRet  := (cAliasF0U)->F0U_IDTSST
			cSeq    := (cAliasF0U)->F0U_SEQ

			If ValType(oXmlExp:_RETCONSSITNFE:_PROTNFE:_INFPROT:_CSTAT:TEXT) <> "U"
				cDefIndef	:= oXmlExp:_RETCONSSITNFE:_PROTNFE:_INFPROT:_CSTAT:TEXT
				If ValType(cDefIndef) == "N" /// Proteção colocada pois no layout diz que o a tag <cStat> é de valor numérico, apesar de retornar um valor caracter
					cDefIndef := cValToChar(cDefIndef)
				EndIf
			EndIf
			
			If ValType(oXmlExp:_RETCONSSITNFE:_XMOTIVO:TEXT) == "C"
				cDescr  := oXmlExp:_RETCONSSITNFE:_XMOTIVO:TEXT
			EndIf

			If ValType(oXmlExp:_RETCONSSITNFE:_PROTNFE:_INFPROT:_NPROT:TEXT) <> "U"
				cProtocol	:= oXmlExp:_RETCONSSITNFE:_PROTNFE:_INFPROT:_NPROT:TEXT
				If ValType(cProtocol) == "N" /// Proteção colocada pois no layout diz que o a tag <cStat> é de valor numérico, apesar de retornar um valor caracter
					cProtocol := cValToChar(cProtocol)
				EndIf
			EndIf

			Aadd(aRet,{cIdRet,cSeq,cDefIndef,cDescr,cProtocol})
		EndIf

	EndIf

ElseIf ValType(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE) == 'A'
	//Se não for um array, significa que somente existe o evento de transmissão , deverá ter ao menos dois eventos relacionados

	For nCont 	:= Len(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE) to 1  step -1 //Começo do último pois o status atual é a última posição no xml


		If type(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_TPEVENTO:TEXT) == 'N'
			clEvento	:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_TPEVENTO:TEXT
		EndIF

		If Type(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT) == 'N'
			clSeq	:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT
		EndIF

		//Somente processa evento de retorno
		If SubStr(clEvento,1,1) == '4' .AND. clSeq == AllTrim(Str(nSeq))

			If Type(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_CHNFE:TEXT) == 'N'
				nlChave	:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_CHNFE:TEXT
			EndIF

			IF clEvento $ '411502/411503'

				//Cancelamento
				IF nlChave == cChave .AND. cEvento == clEvento .AND. ;
					Valtype(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_ID:TEXT) == 'C' .AND. ;
					type(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT) == 'N' .AND. ;
					type(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPCANCPEDIDO:_STATCANCPEDIDO:TEXT) == 'N' .AND. ;
					type(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_RETEVENTO:_INFEVENTO:_NPROT:TEXT) == 'N'

					cIdOri	:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_IDPEDIDO:TEXT

					IF Valtype(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPCANCPEDIDO:_JUSTSTATUS:TEXT) == 'C'
						cJustStat	:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPCANCPEDIDO:_JUSTSTATUS:TEXT
					EndIF

					IF cJustStat <> '5'
						cDescr	:= DescStatus(cJustStat,.T.)
					Else
						cDescr		:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPCANCPEDIDO:_JUSTSTAOUTRA:TEXT
					EndIF

					aRet	:= {}
					cIdRet		:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_ID:TEXT
					cSeq		:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT
					cDefIndef	:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPCANCPEDIDO:_STATCANCPEDIDO:TEXT
					cProtocol	:= ''

					IF F0V->(MSSEEK(xFilial('F0V')+cIdOri+cChave +clItem))
						Aadd(aRet,{cIdRet,cSeq,cDefIndef,cDescr,cProtocol})
					EndIF

				EndIF

			EndIF

			IF clEvento $ '411500/411501'
				//Prorrogação
				If  valtype(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO) == 'A'
					For nContItem := 1 to Len(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO)

						If oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO[nContItem]:_NUMITEM:TEXT == alltrim(str(Val(cItem)))
							clItem	:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO[nContItem]:_NUMITEM:TEXT
							exit
						EndIF
					Next  nContItem
				Else
					If type(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO:_NUMITEM:TEXT) == 'N'
						clItem		:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO:_NUMITEM:TEXT
					EndIF

				EndIF

				IF nContItem == 0
					IF nlChave == cChave .AND. alltrim(str(Val(cItem))) == alltrim(clItem).AND. cEvento == clEvento .AND. ;
						Valtype(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_ID:TEXT) == 'C' .AND. ;
						type(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT) == 'N' .AND. ;
						type(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO:_STATPEDIDO:TEXT) == 'N' .AND. ;
						type(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_RETEVENTO:_INFEVENTO:_NPROT:TEXT) == 'N'

						IF Valtype(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO:_JUSTSTATUS:TEXT) == 'C'
							cJustStat	:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO:_JUSTSTATUS:TEXT
						EndIF

						IF cJustStat <> '10'
							cDescr	:= DescStatus(cJustStat,.F.)
						Else
							cDescr		:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO:_JUSTSTAOUTRA:TEXT
						EndIF

						aRet	:= {}
						cIdRet		:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_ID:TEXT
						cSeq		:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT
						cDefIndef	:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO:_STATPEDIDO:TEXT
						cProtocol	:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_RETEVENTO:_INFEVENTO:_NPROT:TEXT
						Aadd(aRet,{cIdRet,cSeq,cDefIndef,cDescr,cProtocol})

					EndIF
				Else

					IF SubStr(clEvento,1,1) == '4' .AND. 		nlChave == cChave .AND. alltrim(str(Val(cItem))) == alltrim(clItem).AND. cEvento == clEvento .AND. ;
						Valtype(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_ID:TEXT) == 'C' .AND. ;
						type(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT) == 'N' .AND. ;
						type(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO[nContItem]:_STATPEDIDO:TEXT) == 'N' .AND. ;
						type(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_RETEVENTO:_INFEVENTO:_NPROT:TEXT) == 'N'

						IF Valtype(oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO[nContItem]:_JUSTSTATUS:TEXT) == 'C'
							cJustStat	:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO[nContItem]:_JUSTSTATUS:TEXT
						EndIF

						IF cJustStat <> '10'
							cDescr	:= DescStatus(cJustStat,.F.)
						Else
							cDescr		:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO[nContItem]:_JUSTSTAOUTRA:TEXT
						EndIF

						aRet	:= {}
						cIdRet		:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_ID:TEXT
						cSeq		:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT
						cDefIndef	:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO[nContItem]:_STATPEDIDO:TEXT
						cProtocol	:= oXmlExp:_RETCONSSITNFE:_PROCEVENTONFE[nCont]:_RETEVENTO:_INFEVENTO:_NPROT:TEXT
						Aadd(aRet,{cIdRet,cSeq,cDefIndef,cDescr,cProtocol})

					EndIF
				EndIF
			EndIF
			//Processa somente a última posição do array para sequencia e evento
			Exit
		EndIF
	Next nCont
EndIF

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QryPendent
Função que faz query para trazer as movimentações que ainda não foram atualizadas
e precisa ser sincronizadas com retorno da Sefaz

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function QryPendent(lMonitor)

Local cAliasF0U		:= GetNextAlias()
Local cCampos		:= ''
Local cFiltro		:= ''
Default lMonitor	:= .F.

DbSelectArea("F0U")
DbSetOrder(1)

cCampos	:= "F0U.F0U_CHVNFE,F0U.F0U_IDTSST,F0U.F0U_SEQ, F0U.F0U_ITEM, F0U.F0U_EVEESP, F0U.F0U_STATUS,F0U.F0U_SER,F0U.F0U_NUMNF,F0U.F0U_EVEENV,  F0U.R_E_C_N_O_"

cCampos := "%" + cCampos + "%"

IF lMonitor
	cFiltro	:= "%F0U.F0U_MONOK = ' ' AND %"
Else
	cFiltro	:= "%%"
EndIF

BeginSql Alias cAliasF0U

	SELECT
		%Exp:cCampos%
	FROM
		%Table:F0U% F0U

	WHERE
		F0U.F0U_FILIAL=%xFilial:F0U%  AND
		F0U.F0U_STATUS IN ('03','07', '11','15')	AND
		%Exp:cFiltro%
		F0U.%NotDel%

EndSql

Return cAliasF0U

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA130ATUS
Função que irá fazeratualização de acordo com retorno da Sefaz.

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA130ATUS()

Processa({|lEnd| AtuStaSef()},,,.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuStaSef
Função que irá chama atualização de monitor e da F0U

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function AtuStaSef()

Local cAliasF0U		:= ''
Local cURL   		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local aInfNotas		:= {}


ProcRegua (2)
IncProc("Buscando Notas Pendentes...")
IncProc("Consultando Notas Pendentes...")

cAliasF0U	:= QryPendent(.T.)

If !lUsaColab
	ChkMonitor(AllTrim(cURL)+"/NFeSBRA.apw",cAliasF0U)
Else
	ColMonitor(cAliasF0U)
Endif

DbSelectArea (cAliasF0U)
(cAliasF0U)->(DbCloseArea ())

ProcRegua (2)
IncProc("Buscando Notas pendentes com SEFAZ...")

cAliasF0U	:= QryPendent()

If !lUsaColab
	AtuSefaz(cAliasF0U)
Else
	AtuColab(cAliasF0U)
Endif

DbSelectArea (cAliasF0U)
(cAliasF0U)->(DbCloseArea ())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSefaz
Função que irá ler o arquivo de retorno da SEFAZ, fazer parse e processar as informações
de retorno

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function AtuSefaz(cAliasF0U)

Local oWs			:= WsNFeSBra():New()
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cChave		:= ''
Local cStatus		:= ''
Local nCont			:= 0
Local nContAtu		:= 0
Local lParse		:= .F.
Local aRet			:= {}
Local oXmlExp
Local nSeq 	 		:= 0

oWs:cUserToken	:= "TOTVS"
oWs:cID_ENT		:= cIdEnti
oWs:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"

DbSelectArea("F0V")
DbSetOrder(2)

ProcRegua ((cAliasF0U)->(RecCount ()))
IncProc("Processando Notas...")

Do While !(cAliasF0U)->(Eof())
	lParse	:= .F.
	aRet	:= {}
	IncProc("Processando Nota - Item: " +  (cAliasF0U)->F0U_NUMNF + " - " +  (cAliasF0U)->F0U_ITEM)
	nCont++
	nSeq	:=	IIf(Empty((cAliasF0U)->F0U_IDTSST),1,val(substr((cAliasF0U)->F0U_IDTSST,len((cAliasF0U)->F0U_IDTSST)-1,2)))

	If cChave <> (cAliasF0U)->F0U_CHVNFE
		//Aqui deverá realizar consulta para obter todas as respostas vinculadas com a chavenfe
		ows:cCHVNFE		 := (cAliasF0U)->F0U_CHVNFE
		If oWs:ConsultaChaveNFE()
			lParse	:= .T.

			oXmlExp	:= XmlParser(oWs:oWSCONSULTACHAVENFERESULT:CXML_RET,"","","")

			IF !"Rejeicao" $oXmlExp:_RETCONSSITNFE:_XMOTIVO:TEXT
				aRet := AbrePedido((cAliasF0U)->F0U_CHVNFE,(cAliasF0U)->F0U_ITEM,(cAliasF0U)->F0U_EVEESP,oXmlExp,nSeq, cAliasF0U)
			EndIF
		EndIf
	Else
		//Não será necessário fazer nova consulta, pois ainda está processando a mesma chave
		lParse	:= .T.
		IF !"Rejeicao" $oXmlExp:_RETCONSSITNFE:_XMOTIVO:TEXT
			aRet := AbrePedido((cAliasF0U)->F0U_CHVNFE,(cAliasF0U)->F0U_ITEM,(cAliasF0U)->F0U_EVEESP,oXmlExp, nSeq, cAliasF0U)
		EndIF
	EndIF

	If lParse .AND. Len(aRet) > 0
		F0U->(DbGoto((cAliasF0U)->R_E_C_N_O_))

		cStatus	:= DefStatRet((cAliasF0U)->F0U_EVEESP,aRet[1][3],(cAliasF0U)->F0U_STATUS)

		If !Empty(cStatus) //.AND. F0U->F0U_IDTSS <> aRet[1][1]
			RecLock('F0U',.F.)
			F0U->F0U_STATUS	:= cStatus

			IF cStatus == '04'
				F0U->F0U_QUANT1	:= F0U->F0U_QUANTS			 
			ElseIF cStatus == '08'
				F0U->F0U_QUANT2	:= F0U->F0U_QUANTS
			ElseIF cStatus == '12'
				F0U->F0U_QUANT1	:= 0				
			ElseIF cStatus == '16'
				F0U->F0U_QUANT2	:= 0				
			EndIF
			
			F0U->F0U_QUANTS	:= 0
			F0U->F0U_LIMITE	:= DtLimite(F0U->F0U_EMISSA,cStatus)
			F0U->F0U_IDTSS	:= aRet[1][1]
			MsUnLock()			
			FSA130HIST(F0U->F0U_CHVNFE, F0U->F0U_ITEM, F0U->F0U_STATUS,aRet[1][1],aRet[1][4], (cAliasF0U)->F0U_EVEESP, aRet[1][2])
			nContAtu++
		EndIF

	EndIF

	cChave := (cAliasF0U)->F0U_CHVNFE

	(cAliasF0U)->(DBSKIP())
EndDo

MsgInfo('Processamento Concluído (' + Alltrim(str(nContAtu)) + ') de (' + Alltrim(str(nCont)) + ') foram atualizados')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruF0U		:= 	FWFormStruct(1, "F0U",{|cCampo| COMP11STRU(cCampo,"CAB")})
Local oStruF0UIT 	:= 	FWFormStruct(1, "F0U",{|cCampo| COMP11STRU(cCampo,"ITE")})

Local oModel
Local bDetalhe		:= { |oModelGrid, nLine, cAction, cField| FSA130PRE(oModelGrid, nLine, cAction, cField) }
Local lHist			:= .F.

oModel	:=	MPFormModel():New('FISA130', ,,{ |oModel| ValidForm(oModel) } )

oModel:AddFields( 'MODEL_F0U' ,, oStruF0U )
oModel:AddGrid( 'FISA130ITE', 'MODEL_F0U', oStruF0UIT,bDetalhe )

oModel:SetRelation("FISA130ITE",{{"F0U_FILIAL","xFilial('F0U')"},{"F0U_NUMNF","F0U_NUMNF"},{"F0U_SER","F0U_SER"},{"F0U_CLIFOR","F0U_CLIFOR"},{"F0U_LOJA","F0U_LOJA"},{"F0U_CHVNFE","F0U_CHVNFE"}},F0U->(IndexKey(1)))


oModel:SetPrimaryKey( {  'F0U_FILIAL'} )

oStruF0U:SetProperty( 'F0U_NUMNF'	, MODEL_FIELD_WHEN, {|| .F. })
oStruF0U:SetProperty( 'F0U_SER'		, MODEL_FIELD_WHEN, {|| .F. })
oStruF0U:SetProperty( 'F0U_CLIFOR'	, MODEL_FIELD_WHEN, {|| .F. })
oStruF0U:SetProperty( 'F0U_CLIFOR'	, MODEL_FIELD_WHEN, {|| .F. })
oStruF0U:SetProperty( 'F0U_LOJA'	, MODEL_FIELD_WHEN, {|| .F. })
oStruF0U:SetProperty( 'F0U_CHVNFE'	, MODEL_FIELD_WHEN, {|| .F. })
oStruF0U:SetProperty( 'F0U_EMISSA'	, MODEL_FIELD_WHEN, {|| .F. })

oModel:GetModel( 'FISA130ITE' ):SetNoInsertLine( .T. )
oModel:GetModel( 'FISA130ITE' ):SetNoDeleteLine( .T. )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local	oView 		:= 	FWFormView():New()
Local	oModel 		:= 	FWLoadModel( 'FISA130' )
Local	oStruF0U	:= 	FWFormStruct( 2, 'F0U',{|cCampo| COMP11STRU(cCampo,"CAB")})
Local	oStruF0UIT	:= 	FWFormStruct( 2, 'F0U',{|cCampo| COMP11STRU(cCampo,"ITE")})
Local lHist			:= .F.

oView:SetModel( oModel )

lHist := FSA130Desc()[2] == '0' // Visualização

oView:AddField( 'VIEW_F0U', oStruF0U, 'MODEL_F0U' )

oView:AddGrid( 'VIEW_F0UIT', oStruF0UIT, 'FISA130ITE' )

oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 70 )

oView:SetOwnerView( 'VIEW_F0U', 'SUPERIOR' )

oView:SetOwnerView( 'VIEW_F0UIT', 'INFERIOR' )

oView:EnableTitleView( 'VIEW_F0U',  FSA130Desc()[1] )
oView:EnableTitleView( 'VIEW_F0UIT', 'Itens Nota Fiscal' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP11STRU
Função que define quais campos serão considerados na exibição da tela

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function COMP11STRU(cCampo,cTipo)
Local 	lRet 		:= .T.
Local	cCabec		:=	""
Local	cItem		:=	""

cCabec	:=	"F0U_NUMNF/F0U_SER/F0U_CLIFOR/F0U_CLIFOR/F0U_LOJA/F0U_CHVNFE/F0U_EMISSA"

cItem	:=	"F0U_ITEM/F0U_PROD/F0U_QUANTN/F0U_STATUS/F0U_LIMITE/F0U_QUANT1/F0U_QUANT2"

If !Empty(FSA130Desc()[2])
	cItem	+= 'F0U_QUANTS'
EndIF

cCampo	:= Alltrim(cCampo)

If cTipo = "CAB"
	If !cCampo$cCabec
		lRet := .F.
	EndIf
Else
	If !cCampo$cItem
		lRet := .F.
	EndIf
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA130PRE
Função que faz validação de digitação nas linhas

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Function FSA130PRE (oModelGrid, nLine, cAction, cField)

Local lRet			:= .F.
Local nQtdeSel		:= 0
Local nQtdeDisp		:= 0
Local cProc			:= ''
Local cStatus		:= ''

If cAction == 'CANSETVALUE'
	cProc		:= FSA130Desc()[2]
	cStatus	:= oModelGrid:GetValue('F0U_STATUS' )
	//Pre digitação
	IF cProc == '1' //Pedido de Prorrogação
		If cField $ 'F0U_QUANTS/' .AND. cStatus$ '01/04/05/09'
			lRet			:= .T.
		EnDIF
	ElseIF cProc == '2' //Pedido de cancelamento
		If cField $ 'F0U_QUANTS/' .AND.cStatus $ '04/08/13/17'
			lRet			:= .T.
		EnDIF
	ElseIF cProc == '3' //Edição de quantidade
		If cField $ 'F0U_QUANTS/' .AND. cStatus $ '02/06/10/14'
			lRet			:= .T.
		EnDIF
	EndIF


ElseIF cAction == 'SETVALUE'
	nQtdeSel	:= M->F0U_QUANTS
	nQtdeDisp	:= oModelGrid:GetValue('F0U_QUANTN' )
	//Pós digitação

	If cField $ 'F0U_QUANTS/' .AND. nQtdeSel <= nQtdeDisp
		lRet			:= .T.
	Else
		Help("",1,"Help","Help",'Quantidade Informada maior que Quantidade Disponível',1,0)
	EndIF

EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Função que irá atualizar status da F0U conforme digitação do usuário

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

Local	oModel		:=	FWModelActive()
Local	oF0U		:=	oModel:GetModel('MODEL_F0U')
Local	cNumNf		:=	oF0U:GetValue('F0U_NUMNF' )
Local	cSerie		:=	oF0U:GetValue('F0U_SER' )
Local	cClieFor	:=	oF0U:GetValue('F0U_CLIFOR' )
Local	cLoja		:=	oF0U:GetValue('F0U_LOJA' )
Local	cChaveNfe	:=	oF0U:GetValue('F0U_CHVNFE' )
Local cChave		:= ''
Local lRet			:= .T.
Local cProc			:= FSA130Desc()[2]
Local cStatus		:= ''
DbSelectArea("F0U")
DbSetOrder(2)

If oModel:GetOperation() == MODEL_OPERATION_UPDATE

	FWFormCommit(oModel)

	cChave	:= cNumNf + cSerie + cClieFor + cLoja + cChavenfe
	IF F0U->(MSSEEK(xFilial('F0U')+cNumNf +cSerie+cClieFor+cLoja+cChaveNfe))
		Do While !F0U->(Eof())
			If cChave == F0U->F0U_NUMNF + F0U->F0U_SER  + F0U->F0U_CLIFOR + F0U->F0U_LOJA + F0U->F0U_CHVNFE
				cStatus	:= FSA130Stat(cProc,F0U->F0U_STATUS,F0U->F0U_QUANTS)
				Reclock("F0U",.F.)
				F0U->F0U_STATUS	:= cStatus
				MsUnLock()
			Else
				Exit
			EndIF
			F0U->(DbSkip())
		EndDo
	EndIF
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA130Stat
Função que retorna o novo Status a ser gravado

@author Erick G. Dias
@since 07/10/2013
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function FSA130Stat(cProc,cStatusOld, nQtdeSel)

Local cStatus	:= cStatusOld

If nQtdeSel > 0

	IF cProc == '1' //Prorrogação

		If cStatusOld == '01' //Suspensão normal
			cStatus	:= '02' //1ª Prorrogação a transmitir
		ElseIF cStatusOld == '04' //1ª Prorrogação deferia
			cStatus	:= '06' //2ª Prorrogação a transmitir
		ElseIF cStatusOld == '05' //1ª Prorrogação indeferida
			cStatus	:= '02' //1ª Prorrogação a transmitir
		ElseIF cStatusOld == '09' //2ª Prorrogação indeferida
			cStatus	:= '06' //1ª Prorrogação a transmitir
		EndIF

	ElseIF cProc == '2'//cancelamento
		If cStatusOld == '04' //1ªProrrogação deferida
			cStatus	:= '10' //1ª cancelamento a transmitir
		ElseIF cStatusOld == '08' //2ª Prorrogação deferia
			cStatus	:= '14' //2ª cancelamento a transmitir
		EndIF
	EndIF


Elseif cProc == '3' //edição

	If cStatusOld == '02' //1ª Prorrogação a Transmitir
		cStatus	:= '01'  //Suspensão normal
	ElseIf cStatusOld $ '06/10' //2ª Prorrogação a Transmitir ou 1ª cancelamento a transmitir
		cStatus	:= '04'  //1ª Prorrogação Deferida
	ElseIf cStatusOld == '14' //2ª Cancelamento a Transmitir
		cStatus	:= '08'  //2ª Prorrogação Deferida
	EndIF

EndIF

Return cStatus

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FSA130Filt ³ Autor ³ Henrique Pereira     ³ Data ³16.11.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³retorna o filtro para apresenação das notas baseando-se na  ³±±
±±³Descri‡…o ³wizard de configuração										    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³String contendo o filtro                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias: Alias que será filtrado                             ³±±
±±³          ³														           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FSA130Filt(cAlias, cMvCODRSEF)

Local 	cFiltro 	:= ''
Default cAlias		:= ''
Default cMvCODRSEF	:= ''

If cAlias == 'F0U'
	If !Empty(dMvpar01) .And. !Empty(dMvpar02)
		cFiltro 	+= " .AND. DTOS(F0U->F0U_EMISSA) >= '"+DTOS(dMvpar01)+"' .AND. DTOS(F0U->F0U_EMISSA) <= '"+DTOS(dMvpar02)+"'"
	EndIf
	If !Empty(cMvpar04)
		cFiltro 	+= " .AND. F0U->F0U_NUMNF >= '"+cMvpar03+"' .AND. F0U->F0U_NUMNF <= '"+cMvpar04+"'"
	EndIf
	If !Empty(cMvpar06)
		cFiltro 	+= " .AND. F0U->F0U_SER >= '"+cMvpar05+"' .AND. F0U->F0U_SER <='"+cMvpar06+"'"
	EndIf
	If lF0UCfop .And. !Empty(mv_par07) .And. !Empty(mv_par08)
		cFiltro 	+= " .AND. F0U->F0U_CFOP >= '"+mv_par07+"' .AND. F0U->F0U_CFOP <='"+mv_par08+"'"
	EndIf
EndIf

If cAlias == 'SF3'
	If !Empty(dMvpar01) .And. !Empty(dMvpar02)
		cFiltro 	+= "F3.F3_EMISSAO BETWEEN '"+DTOS(dMvpar01)+"' AND '"+DTOS(dMvpar02)+"' AND "
	EndIf
	If !Empty(cMvpar04)
		cFiltro 	+= "F3.F3_NFISCAL BETWEEN '"+cMvpar03+"' AND '"+cMvpar04+"' AND "
	EndIf
	If !Empty(cMvpar06)
		cFiltro 	+= "F3.F3_SERIE BETWEEN '"+cMvpar05+"' AND '"+cMvpar06+"' AND "
	EndIf
	If !Empty(cMvCODRSEF)
		cFiltro 	+= "F3.F3_CODRSEF IN(" + cMvCODRSEF + ") AND "
	EndIF
	If lF0UCfop .And. !Empty(mv_par07) .And. !Empty(mv_par08)
		cFiltro 	+= "F3.F3_CFO BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' AND "
	Endif
EndIf

Return cFiltro

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FSA130VlDt ³ Autor ³ Henrique Pereira     ³ Data ³16.11.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se a digitação do parâmetro Data Até? é maior que o  ³±±
±±³Descri‡…o ³parâmetro Data de?                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Boleano                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³mv_par01: Data de?                                          ³±±
±±³          ³mv_par02: Data até?                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FSA130VlDt()
Local 	lRet := .T.

If mv_par01  > mv_par02
  lRet := .F.
  MSGINFO('Data invalida! Data inicial inferior a data final.')
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} UsaColaboracao
Verifica se parametro MV_TCNEW esta configurado para 0-Todos ou 1-NFE

@author	Rafael.soliveira
@since		30/01/2018
@version	1.0
/*/
//-------------------------------------------------------------------
static function UsaColaboracao(cModelo,cMV_TCNEW)
Local lUsa := .F.
Local lEntSai := .F.

if IsBlind() .or. "0" $ cMV_TCNEW .or. "1" $ cMV_TCNEW
	lEntSai := .T.
EndIf

If lEntSai
	If FindFunction("ColUsaColab")
		lUsa := ColUsaColab(cModelo)
	endif
endif
return (lUsa)

//-----------------------------------------------------------------------
/*/{Protheus.doc} MontXmlEpp()
Monta xml para transmissão EPP

@author Rafae Oliveira
@since 08.02.2018
@version 1.00

@param 	aXML     	- Array com dados da nota e XML com itens a serem processados
		aRetorno   - Array que retornara ID das notas processas

@Return lRetOk	   - Se a transmissão foi concluída ou não
/*/
//-----------------------------------------------------------------------
Static Function MontXmlEpp(aXML,aRetorno)
Local nX 			:= 0
Local cXml			:= ""
Local cXmlItens		:= ""
Local cTpEvento		:= ""
Local cIdEven		:= ""
Local cErro			:= ""
Local cProt			:= ""
Local cSerie		:= ""
Local cNum			:= ""
Local lRetOk		:= .F.
Local aNfe			:= {}
Local aInfXml		:= {}
Local cSeqEven		:= "01"
Local cChave		:= ""

For nX:=1 To Len(aXML)

	cTpEvento := aXML[nX][2]
	aNfe 	  := {aXML[nX][3],aXML[nX][4],aXML[nX][5],aXML[nX][6],cTpEvento}
	cSerie	  := aXML[nX][5]
	cNum	  := aXML[nX][6]
	cIdEven   := ""
	cXML	  := ""
	cXmlItens := aXML[nX][1]
	cChave	  := aXML[nX][3]

	//Pega Sequencia do evento
	cSeqEven := ColSeqEPP(aNfe)

	//Localiza protocolo de autilização da Nfe original
	If cTpEvento $ '111500-111501'
		aInfXml	:= ColExpDoc(cSerie,cNum,"NFE") // Serie +  Nota + Modelo
		cProt	:= aInfXml[7]
	Elseif cTpEvento $ '111502-111503'
		//Protocolo de autilização do EPP autorizado da F0U
		cProt	:= aXML[nX][8]
	Endif

	cXml	:= GeraEPPXml(aNfe,cXmlItens,cTpEvento,cProt,cSeqEven)

	//Adiciona a CHAVE da nota para solicitar o envio.
	If ColEnvEvento("EPP",aNfe,cXml,@cIdEven,@cErro)
		lRetOk := .T.
		aadd(aRetorno,cIdEven)
	Else
		Aviso("EPP TOTVS Colaboração 2.0",cErro,{"OK"},3)
	EndIf
Next

Return lRetOk

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColSeqEPP
Devolve o número da próxima sequencia para envio do evento de CC-e.

@author 	Rafel Oliveira
@since 		08/02/2018
@version 	1.0

@param	aNFe, array, Array com os dados da NF-e.<br>[1] - Chave<br>[2] - Recno<br>[3] - Serie<br>[4] - Numero

@return cSequencia string com as a sequencia que deve ser utilizada.
/*/
//-----------------------------------------------------------------------
function ColSeqEPP(aNFe)

Local cErro			:= ""
Local cAviso		:= ""
Local cSequencia	:= "01"
Local cXMl			:= ""
Local lRetorno		:= .F.

Local oDoc			:= nil
Local aDados		:= {}
Local aDadosXml		:= {}

oDoc := ColaboracaoDocumentos():new()
oDoc:cTipoMov	:= "1"
oDoc:cIDERP	:= aNfe[3] + aNfe[4] + FwGrpCompany()+FwCodFil()
oDoc:cMOdelo	:= "EPP"

if odoc:consultar()
	aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|NPROT")
	aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|NSEQEVENTO")
	aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|TPEVENTO")	
	aadd(aDados,"EVENTO|INFEVENTO|NSEQEVENTO")
	aadd(aDados,"EVENTO|INFEVENTO|TPEVENTO")

	lRetorno := !Empty(oDoc:cXMlRet)

	if lRetorno
		cXml := oDoc:cXMLRet
	else
		cXml := oDoc:cXML
	endif

	aDadosXml := ColDadosXMl(cXml, aDados, @cErro, @cAviso)

	//Se ja foi autorizado pega o sequencial do XML de envio.
	if lRetorno .And. aDadosXml[3] == aNFe[5] // verifica se é mesmo evento
		if !Empty( aDadosXml[1] )
			cSequencia := StrZero(Val(Soma1(aDadosXml[2])),2)
		Endif
	elseIF lRetorno .And. aDadosXml[3] <> aNFe[5]
		cSequencia := "01"
	Else
		cSequencia := StrZero(Val(aDadosXml[4]),2)
	endif

else
	cSequencia := "01"
endif

oDoc := Nil
DelClassIntf()

return cSequencia


//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} GeraEPPXml
Função que monta o Xml para pedido de prorrogação

@author Rafael.Oliveira
@since 05.02.2018
@version 1.00

@param	Null

/*/
//--------------------------------------------------------------------------------------------
Static Function GeraEPPXml(aNfe,cTxtXml,cTpEvento,cProt,cSeqEven)

Local cXml			:= ""
Local aUf			:= {}
Local cCnpj			:= SM0->M0_CGC
Local cData			:= Dtos(Date())
Local cHora			:= Time()
Local cDhEvento		:= ""
Local cCodOrgao		:= ""
Local cAmbiente		:= "2"
Local cVerLayout	:= "1.00"
Local cVerLayEven	:= "1.00"
Local cVerEven		:= "1.00"
Local cVerEpp 		:= "1.00"
Local cHrVerao		:= "2"
Local cHorario		:= "2"
Local cUTC			:= "03:00"	//Brasilia
local cError		:= ""
Local nPosUf		:= 0
Local cIdEvento		:= ""
Local cUF			:= Upper(Left(LTrim(SM0->M0_ESTENT),2))
Local cDescEvento 	:= ""
Local cChvNfe		:= ""
Local lHVerao   	:=.F.			        	                  // Horario de Verão    .F. sem horario de verão/ .T. com horario de verão
Local lErpHverao	:= GetNewPar("MV_HVERAO",.F.)   		  // Verifica se o local fisico do servidor está em Horário de Verão  .F. Não / .T. Sim

Local aData		:={}         				    			  //Array da função FwTimeUF

cChvNfe := aNfe[1]

If cTpEvento $ "111500#111501"
	cDescEvento := "Pedido de Prorrogacao"
ElseIf cTpEvento $ "111502#111503"
	cDescEvento := "Cancelamento de Pedido de Prorrogacao"
EndIf

//Carrega parametros
cAmbiente		:= ColGetPar("MV_AMBIEPP","2")
cVerLayout		:= ColGetPar("MV_VEREPP2","1.00")
cVerLayEven		:= ColGetPar("MV_VEREPP3","1.00")
cVerEven		:= ColGetPar("MV_VEREPP1","1.00")
cVerEpp 		:= ColGetPar("MV_VEREPP","1.00")

cHrVerao		:= ColGetPar("MV_HRVERAO","2")
cHorario	 	:= ColGetPar("MV_HORARIO","2")



// Montagem do ID do evento
cIdEvento := "ID"+cTpEvento+cChvNfe+cSeqEven

// Tabela do IBGE
aUf := SpedTabIBGE()

// Codigo do Orgao
nPosUf := aScan(aUf,{|x| Upper(x[1]) == cUF})
If nPosUf > 0
	cCodOrgao := aUf[nPosUf][4]
Endif

// Data e Hora do Evento - Formato: 2011-07-27T14:17:00-03:00 (UTC)
If FindFunction("FwTimeUF")

	If cHrVerao == "1"			//1-Sim ### 2-Nao
		lHVerao   :=.T.
	else
		lHVerao   :=.F.
	EndIF

	If cHorario == "1"		//Fernando de Noronha
		cUF  := "FERNANDO DE NORONHA"
	Endif

	If !lErpHverao
	   lErpHverao := lHVerao
	Endif

	aData := FwTimeUF(cUF,,lErpHVerao)

	cdata		:= aData[1]
	cData		:= Dtos(Date())
	cData		:= Substr(cData,1,4)+"-"+Substr(cData,5,2)+"-"+Substr(cData,7,2)

	cHora		:= aData[2]
Else
	cData		:= Substr(cData,1,4)+"-"+Substr(cData,5,2)+"-"+Substr(cData,7,2)

	cHora		:= Time()
EndIf
If cHrVerao == "1"			//1-Sim ### 2-Nao
	If cHorario == "1"		//Fernando de Noronha
		cUtc := "01:00"
	ElseIf cHorario == "2"	//Brasilia
		cUtc := "02:00"
	ElseIf	cHorario == "4"	//Acre
		cUtc := "04:00"
	Else
		cUtc := "03:00"		//Manaus
	Endif
Else
	If cHorario == "1"		//Fernando de Noronha
		cUtc := "02:00"
	ElseIf cHorario == "2"	//Brasilia
		cUtc := "03:00"
	ElseIf	cHorario == "4"	//Acre
		cUtc := "05:00"
	Else
		cUtc := "04:00"		//Manaus
	Endif
Endif

cDHEvento 	:=cData
cDHEvento 	+= "T"
cDHEvento 	+= cHora
cDHEvento 	+= "-"
cDHEvento	+= cUtc

// Montagem do Xml
cXml +=	 '<evento versao="'+cVerLayEven+'" xmlns="http://www.portalfiscal.inf.br/nfe">'

cXml += '<infEvento Id="'+cIdEvento+'">'

// Codigo do Orgao - Tabela IBGE
cXml += "<cOrgao>"
cXml += cCodOrgao
cXml += "</cOrgao>"

// Ambiente: 1-Producao ### 2-Homologacao
cXml += "<tpAmb>"
cXml += cAmbiente
cXml += "</tpAmb>"

cXml += "<CNPJ>"
cXml += cCnpj
cXml += "</CNPJ>"

// Chave da Nf-e
cXml += "<chNFe>"
cXml += cChvNfe
cXml += "</chNFe>"

cXml += "<dhEvento>"
cXml += cDHEvento
cXml += "</dhEvento>"

cXml += "<tpEvento>"
cXml += cTpEvento
cXml += "</tpEvento>"

// Sequencia do evento
cXml += "<nSeqEvento>"
cXml += cValToChar(Val(cSeqEven))
cXml += "</nSeqEvento>"

// Versao do evento
cXml += "<verEvento>"
cXml += cVerEven
cXml += "</verEvento>"

cXml += '<detEvento versao="'+cVerEpp+'">'

//Descricao do Evento
cXml += '<descEvento>'+cDescEvento+'</descEvento>'

//Quando for cancelamento imprime protocolo por ultimo
If cTpEvento $ '111502/111503'
	// tags ja tratada com itens a serem prorrogados
	cXml += cTxtXml
	cXml += '<nProt>'+cProt+'</nProt>'
Else
	cXml += '<nProt>'+cProt+'</nProt>'
	// tags ja tratada com itens a serem prorrogados
	cXml += cTxtXml
Endif

// tags ja tratada com itens a serem prorrogados
//cXml += cTxtXml

cXml += "</detEvento>"
cXml += "</infEvento>"

// Fechando tag Evento
cXml += "</evento>"

Return cXml


/*/{Protheus.doc} AtuColab
Função que irá ler o arquivo de retorno da SEFAZ, fazer parse e processar as informações
de retorno

@author Rafael Oliveira
@since 23/02/18
@version 11.90
/*/
Static Function AtuColab(cAliasF0U)

Local cChave		:= ''
Local cStatus		:= ''
Local nCont			:= 0
Local nContAtu		:= 0
Local lParse		:= .F.
Local aRet			:= {}
Local oXmlExp
Local nSeq 	 		:= 0
Local oDoc			:= ColaboracaoDocumentos():new()
local cAmbiente		:= SubStr(ColGetPar("MV_AMBIEPP","2"),1,1)
Local aProt			:= {}

//Localiza nota e roda Historico
oDoc:cModelo	:= "EPP"
oDoc:cTipoMov	:= "1"
//oDoc:cQueue		:= "170"
//oDoc:cFlag		:= "0"
//oDoc:cAmbiente	:= cAmbiente

DbSelectArea("F0V")
DbSetOrder(2)

ProcRegua ((cAliasF0U)->(RecCount ()))
IncProc("Processando Notas...")

Do While !(cAliasF0U)->(Eof())
	lParse	:= .F.
	aRet	:= {}
	IncProc("Processando Nota - Item: " +  (cAliasF0U)->F0U_NUMNF + " - " +  (cAliasF0U)->F0U_ITEM)
	nCont++
	nSeq	:=	IIf(Empty((cAliasF0U)->F0U_IDTSST),1,val(substr((cAliasF0U)->F0U_IDTSST,len((cAliasF0U)->F0U_IDTSST)-1,2)))
	cXml	:= ""

	If cChave <> (cAliasF0U)->F0U_CHVNFE
		//Aqui deverá realizar consulta para obter todas as respostas vinculadas com a chavenfe

		oDoc:cIDERP		:= (cAliasF0U)->F0U_SER+(cAliasF0U)->F0U_NUMNF+FwGrpCompany()+FwCodFil()

		If odoc:consultar()
			lParse	:= .T.
			oXmlExp	:= XmlParser(oDoc:cXMLRet,"","","")

			oDoc:lHistorico	:= .T.
			oDoc:buscahistorico()

			//Ordena o a Historico para trazer o mais recente primeiro.
			//aSort(oDoc:aHistorico,,,{|x,y| ( if( Empty(x[4]),"99/99/9999",DToC(x[4])) +x[5] > if(empty(y[4]),"99/99/9999",DToC(x[4]))+y[5])})
			
			//Ordena o a Historico para trazer o mais recente na ultima possição.
			aSort(oDoc:aHistorico,,,{|x,y| ( if( Empty(x[4]),"99/99/9999",DToC(x[4])) +x[5] < if(empty(y[4]),"99/99/9999",DToC(x[4]))+y[5])})
			aRet := ColPedido((cAliasF0U)->F0U_CHVNFE,(cAliasF0U)->F0U_ITEM,(cAliasF0U)->F0U_EVEESP,oXmlExp,nSeq,oDoc:aHistorico)
		Endif
	Else
		//Não será necessário fazer nova consulta, pois ainda está processando a mesma chave
		lParse	:= .T.
		aRet := ColPedido((cAliasF0U)->F0U_CHVNFE,(cAliasF0U)->F0U_ITEM,(cAliasF0U)->F0U_EVEESP,oXmlExp,nSeq,oDoc:aHistorico)
	EndIF

	If lParse .AND. Len(aRet) > 0
		F0U->(DbGoto((cAliasF0U)->R_E_C_N_O_))
		cStatus	:= DefStatRet((cAliasF0U)->F0U_EVEESP,aRet[1][3],(cAliasF0U)->F0U_STATUS)

		If !Empty(cStatus) //.AND. F0U->F0U_IDTSS <> aRet[1][1]
			RecLock('F0U',.F.)
			F0U->F0U_STATUS	:= cStatus

			//somente Guarda protocolo de autorização do EPP
			IF cStatus == '04'
				F0U->F0U_QUANT1	:= F0U->F0U_QUANTS
			ElseIF cStatus == '08'
				F0U->F0U_QUANT2	:= F0U->F0U_QUANTS
			ElseIF cStatus == '12'
				F0U->F0U_QUANT1	:= 0
			ElseIF cStatus == '16'
				F0U->F0U_QUANT2	:= 0
			EndIF

			F0U->F0U_QUANTS	:= 0
			F0U->F0U_LIMITE	:= DtLimite(F0U->F0U_EMISSA,cStatus)
			F0U->F0U_IDTSS	:= aRet[1][1]
			MsUnLock()
			FSA130HIST(F0U->F0U_CHVNFE, F0U->F0U_ITEM, F0U->F0U_STATUS,aRet[1][1],aRet[1][4], (cAliasF0U)->F0U_EVEESP, aRet[1][2])
			nContAtu++
		EndIF
	EndIF

	cChave := (cAliasF0U)->F0U_CHVNFE

	(cAliasF0U)->(DBSKIP())
EndDo

MsgInfo('Processamento Concluído (' + Alltrim(str(nContAtu)) + ') de (' + Alltrim(str(nCont)) + ') foram atualizados')

oDoc := Nil

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ColPedidoColPedido
Função que abre o pedido retornado no XML da SEFAZ

@author Rafael Oliveira
@since 23/02/18
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ColPedido(cChave, cItem,cEvento,oXmlExp, nSeq,aHist)

Local clEvento		:= ''
Local cSeq			:= ''
Local cIdRet		:= ''
Local clItem		:= ''
Local cDefIndef		:= ''
Local cDescr		:= ''
Local cProtocol		:= ''
Local nlChave		:= ''
Local clSeq			:= ''
Local cJustStat		:= ''
Local nCont			:= 0
Local nContItem		:= 0
Local aRet			:= {}
Local cIdOri		:= ''
Local oXmlItem
Local cXmotivo		:= ""

If valtype(aHist) == 'A'

	For nCont 	:= Len(aHist) to 1 step -1 //Começo do último pois o status atual é a última posição no xml

		IF aHist[nCont][8] == "536" .And. !Empty(aHist[nCont][2]) //Processa somente retorno da NeoGrid

			oXmlItem	:= XmlParser(aHist[nCont][2],"","","")
			cXmotivo	:= oXmlItem:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_XMOTIVO:TEXT

			If type(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_TPEVENTO:TEXT) == 'N'
				clEvento	:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_TPEVENTO:TEXT
			EndIF

			If Type(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT) == 'N'
				clSeq	:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT
			EndIF

			//Somente processa evento de retorno
			If SubStr(clEvento,1,1) == '4' .AND. clSeq == AllTrim(Str(nSeq))

				If Type(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CHNFE:TEXT) == 'N'
					nlChave	:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CHNFE:TEXT
				EndIF

				IF clEvento $ '411502/411503'

					//Cancelamento
					IF nlChave == cChave .AND. cEvento == clEvento .AND. ;
						Valtype(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT) == 'C' .AND. ;
						type(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT) == 'N' .AND. ;
						type(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPCANCPEDIDO:_STATCANCPEDIDO:TEXT) == 'N' .AND. ;
						type(oXmlItem:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_NPROT:TEXT) == 'N'

						cIdOri	:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_IDPEDIDO:TEXT

						IF Valtype(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPCANCPEDIDO:_JUSTSTATUS:TEXT) == 'C'
							cJustStat	:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPCANCPEDIDO:_JUSTSTATUS:TEXT
						EndIF

						IF cJustStat <> '5'
							cDescr	:= DescStatus(cJustStat,.T.)
						Else
							cDescr		:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPCANCPEDIDO:_JUSTSTAOUTRA:TEXT
						EndIF

						aRet	:= {}
						cIdRet		:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT
						cSeq		:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT
						cDefIndef	:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPCANCPEDIDO:_STATCANCPEDIDO:TEXT
						cProtocol	:= ''

						IF F0V->(MSSEEK(xFilial('F0V')+cIdOri+cChave +clItem))
							Aadd(aRet,{cIdRet,cSeq,cDefIndef,cDescr,cProtocol})
						EndIF

					EndIF

				EndIF

				IF clEvento $ '411500/411501'
					//Prorrogação
					If  valtype(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO) == 'A'
						For nContItem := 1 to Len(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO)

							If oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO[nContItem]:_NUMITEM:TEXT == alltrim(str(Val(cItem)))
								clItem	:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO[nContItem]:_NUMITEM:TEXT
								exit
							EndIF
						Next  nContItem
					Else
						If type(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO:_NUMITEM:TEXT) == 'N'
							clItem		:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO:_NUMITEM:TEXT
						EndIF

					EndIF

					IF nContItem == 0
						IF nlChave == cChave .AND. alltrim(str(Val(cItem))) == alltrim(clItem).AND. cEvento == clEvento .AND. ;
							Valtype(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT) == 'C' .AND. ;
							type(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT) == 'N' .AND. ;
							type(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO:_STATPEDIDO:TEXT) == 'N' .AND. ;
							type(oXmlItem:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_NPROT:TEXT) == 'N'

							IF Valtype(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO:_JUSTSTATUS:TEXT) == 'C'
								cJustStat	:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO:_JUSTSTATUS:TEXT
							EndIF

							IF cJustStat <> '10'
								cDescr	:= DescStatus(cJustStat,.F.)
							Else
								cDescr		:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO:_JUSTSTAOUTRA:TEXT
							EndIF

							aRet	:= {}
							cIdRet		:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT
							cSeq		:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT
							cDefIndef	:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO:_STATPEDIDO:TEXT
							cProtocol	:= oXmlItem:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_NPROT:TEXT
							Aadd(aRet,{cIdRet,cSeq,cDefIndef,cDescr,cProtocol})

						EndIF
					Else

						IF SubStr(clEvento,1,1) == '4' .AND. nlChave == cChave .AND. alltrim(str(Val(cItem))) == alltrim(clItem).AND. cEvento == clEvento .AND. ;
							Valtype(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT) == 'C' .AND. ;
							type(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT) == 'N' .AND. ;
							type(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO[nContItem]:_STATPEDIDO:TEXT) == 'N' .AND. ;
							type(oXmlItem:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_NPROT:TEXT) == 'N'

							IF Valtype(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO[nContItem]:_JUSTSTATUS:TEXT) == 'C'
								cJustStat	:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO[nContItem]:_JUSTSTATUS:TEXT
							EndIF

							IF cJustStat <> '10'
								cDescr	:= DescStatus(cJustStat,.F.)
							Else
								cDescr		:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO[nContItem]:_JUSTSTAOUTRA:TEXT
							EndIF

							aRet	:= {}
							cIdRet		:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT
							cSeq		:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT
							cDefIndef	:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_RESPPEDIDO:_ITEMPEDIDO[nContItem]:_STATPEDIDO:TEXT
							cProtocol	:= oXmlItem:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_NPROT:TEXT
							Aadd(aRet,{cIdRet,cSeq,cDefIndef,cDescr,cProtocol})

						EndIF
					EndIF
				EndIF
			EndIF
		Endif
		//Processa somente Até encontrar altimo pedido efetuado para item
		//Exit
	Next nCont
EndIF

Return aRet




//-------------------------------------------------------------------
/*/{Protheus.doc} ColMonitor
Função que irá verificar se o item enviado para o TSS foi realmente transmitido
para a SEFAZ, ou se deu algum erro.

@author Erick G. Dias
@since 23/06/16
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ColMonitor(cAliasF0U)

Local lOk		:= .F.
Local aMonitor	:= {}
Local nStatus	:= 0
Local cChave	:= ''
Local cIdEvento	:= ''
Local cMotEvent	:= ''
Local cErro		:= ''
Local cXmotivo	:= ''
Local clEvento	:= ''
Local clSeq		:= ''
Local nSeq		:= ''
Local clItem	:= ''
Local nItem		:= ''
Local nCont		:= 0
Local oDoc		:= ColaboracaoDocumentos():new()
Local oXmlItem


DbSelectArea("F0U")
DbSetOrder(4)

ProcRegua ((cAliasF0U)->(RecCount ()))
IncProc("Atualizando Monitor...")

//Atualiza CKO com IDERP para arquivos de retorno 536 para que historico seja completo
AtuaCKO()

Do While !(cAliasF0U)->(Eof())

	IncProc("Atualizando Monitor, chave -" +   (cAliasF0U)->F0U_CHVNFE)

	If !Empty((cAliasF0U)->F0U_EVEENV)
		oDoc:cModelo	:= "EPP"
		oDoc:cTipoMov	:= "1"
		oDoc:cIDERP		:= (cAliasF0U)->F0U_SER+(cAliasF0U)->F0U_NUMNF+FwGrpCompany()+FwCodFil()
		nSeq	:=	IIf(Empty((cAliasF0U)->F0U_IDTSST),1,val(substr((cAliasF0U)->F0U_IDTSST,len((cAliasF0U)->F0U_IDTSST)-1,2)))

		If oDoc:consultar()

			oDoc:lHistorico	:= .T.
			oDoc:buscahistorico()
			
			//Ordena o a Historico para trazer o mais recente na ultima possição.
			aSort(oDoc:aHistorico,,,{|x,y| ( if( Empty(x[4]),"99/99/9999",DToC(x[4])) +x[5] < if(empty(y[4]),"99/99/9999",DToC(x[4]))+y[5])})
			
			// Tratamento do retorno do evento
			For nCont 	:= Len(oDoc:aHistorico) to 1 step -1 //Começo do último pois o status atual é a última posição no xml

				If oDoc:aHistorico[nCont][8] $ "534-535" .And. !Empty(oDoc:aHistorico[nCont][2] )
				//If !Empty(oDoc:cXMlRet)

					oXmlItem	:= XmlParser(oDoc:aHistorico[nCont][2],"","","")
					//oXmlItem	:= XmlParser(oDoc:cXMlRet,"","","")
					cXmotivo	:= oXmlItem:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_XMOTIVO:TEXT

					If type(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_TPEVENTO:TEXT) == 'N'
						clEvento	:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_TPEVENTO:TEXT
					EndIF

					If Type(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT) == 'N'
						clSeq	:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT
					EndIF

					If Type(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CHNFE:TEXT) == 'N'
						nlChave	:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CHNFE:TEXT
					EndIF

					iF valType(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT) == 'C'
						cIdRet		:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT
					Endif

					If clEvento == Alltrim((cAliasF0U)->F0U_EVEENV)  .AND. clSeq == AllTrim(Str(nSeq))
						IF "Rejeicao" $ cXmotivo .Or. "Rejeição" $ cXmotivo

							If clEvento == '111500' 		// 1ª Prorrogação Erro
								cDefIndef := '18'
							ElseIf clEvento =='111501'		//2ª Prorrogação Erro;
								cDefIndef := '19'
							Elseif clEvento == '111502'		//1ª Cancelamento Erro;
								cDefIndef := '20'
							Elseif clEvento == '111503'		//2ª Cancelamento Erro;
								cDefIndef := '21'
							Endif

							If cDefIndef =='18' .or. cDefIndef=='19' .or. cDefIndef=='20' .or. cDefIndef=='21'
								IF F0U->(MSSEEK(xFilial('F0U')+(cAliasF0U)->F0U_CHVNFE+cIdRet+(cAliasF0U)->F0U_ITEM ))
									//Atualiza F0U e Historico
									RecLock('F0U',.F.)

									F0U->F0U_STATUS	:= cDefIndef
									FSA130HIST(F0U->F0U_CHVNFE, F0U->F0U_ITEM, F0U->F0U_STATUS,cIdRet,cXmotivo,(cAliasF0U)->F0U_EVEESP, clSeq)

									MsUnLock()
								Endif
							Endif

						Elseif oDoc:cQueue =='534' //oDoc:aHistorico[nCont][8] == "534" //Guarda protocolo de vinculo com NFe

							If  valtype(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_ITEMPEDIDO) == 'A'
								For nItem := 1 to Len(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_ITEMPEDIDO)
									If oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_ITEMPEDIDO[nItem]:_NUMITEM:TEXT == alltrim(str(Val((cAliasF0U)->F0U_ITEM)))
										clItem	:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_ITEMPEDIDO[nItem]:_NUMITEM:TEXT
										exit
									EndIF
								Next  nItem
							Else
								If type(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_ITEMPEDIDO:_NUMITEM:TEXT) == 'N'
									clItem		:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_ITEMPEDIDO:_NUMITEM:TEXT
								EndIF
							EndIF

							//Guarda protocolo do pedido
							If nlChave == (cAliasF0U)->F0U_CHVNFE .AND. (cAliasF0U)->F0U_EVEENV == clEvento .AND. clSeq == AllTrim(Str(nSeq)) .AND.  val((cAliasF0U)->F0U_ITEM) == val(clItem) .AND. ;
								type(oXmlItem:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_NPROT:TEXT) == 'N'

								//F0U_FILIAL, F0U_CHVNFE, F0U_IDTSST, F0U_ITEM, R_E_C_N_O_, D_E_L_E_T_
								IF F0U->(MSSEEK(xFilial('F0U')+(cAliasF0U)->F0U_CHVNFE+cIdRet+(cAliasF0U)->F0U_ITEM ))
									cProtocol	:= oXmlItem:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_NPROT:TEXT

									RecLock('F0U',.F.)
									If clEvento == '111500'
										F0U->F0U_PROT1 := cProtocol
									ElseIf clEvento =='111501'
										F0U->F0U_PROT2 := cProtocol
									Endif
									MsUnLock()
								Endif
							Endif
						Endif
						Exit //processa somente ultimo registro
					Endif					
				Endif				
			Next
		EndIF
	EndIF

	(cAliasF0U)->(DbSkip())
EndDo

oDoc := Nil

Return


/*/{Protheus.doc} AtuaCKO
Função que irá Atualizar tabela CKOCOL com IDERP para que historico exiba registros 536 - retorno do pedido de prorrogação ou cancelamentos


@author Rafael Oliveira
@since 23/02/18
@version 11.90
/*/

Static Function AtuaCKO()
Local aAreaF0U 	:= GetArea()
Local nOrder1	:= F0U->( indexOrd() )
Local aArquivos	:= {}
Local nX		:= 0
Local nOrder2	:= CKO->( indexOrd() )
Local nRecno2	:= CKO->( recno() )
Local oXmlItem
Local cChave	:= ''
Local cIDERP	:= ''

//Localiza arquivos de Retorno de pedido de prorrogação 536
DbSelectArea("CKO")
CKO->(DbSetOrder(4)) //CKO_CODEDI, CKO_FLAG, CKO_DT_RET, R_E_C_N_O_, D_E_L_E_T_

//Adiciona no array todos retorno 536 sem IDERP
If CKO->(MsSeek("536"))
	While (!CKO->(Eof()) .And. CKO->CKO_CODEDI =='536')
		If Empty(CKO->CKO_IDERP)

			//Pega Chave da NFE
			oXmlItem	:= XmlParser(CKO->CKO_XMLRET,"","","")
			
			If Type(oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CHNFE:TEXT) == 'N'
				cChave	:= oXmlItem:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CHNFE:TEXT
			EndIF		

			//Guardo nome do arquivo
			Aadd(aArquivos, {CKO->CKO_ARQUIV, CKO->(Recno()),cChave,""})
		Endif
		CKO->(DbSkip())
	End
EndIF

F0U->(DbSetOrder(3)) //F0U_FILIAL, F0U_CHVNFE, F0U_ITEM, R_E_C_N_O_, D_E_L_E_T_

For nX := 1 to Len(aArquivos)

	//Pesquisa Chave	
	If F0U->(MsSeek(xFilial('F0U')+aArquivos[nX,3]))

		//ID_ERP
		cIDERP		:= F0U->F0U_SER+F0U->F0U_NUMNF+FwGrpCompany()+FwCodFil()
		
		aArquivos[nX,4] := cIDERP	//Guarda IDERP		
		
	Endif
Next

//Atualiza arquivo de retorno
For nX := 1 to Len(aArquivos)
	CKO->(DbGoTo(aArquivos[nX,2])) 
	CKO->(RecLock('CKO',.F.))
		CKO->CKO_IDERP := aArquivos[nX,4]
	CKO->(MsUnLock())
Next

//Restaura possição F0U
F0U->( dbSetOrder( nOrder1 )) 
RestArea(aAreaF0U)


//Restaura CKO possicionada na consulta
CKO->( dbSetOrder( nOrder2 ) )
CKO->( dbGoTo( nRecno2 ) )

Return
