#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'TECA803.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA803
	Browse da rotina de requisicoes de equipamentos para atendentes
@sample 	TECA803() 
@since		18/05/2015       
@version	P12
/*/
//------------------------------------------------------------------------------
Function TECA803()
Local oMBrowse := Nil

dbSelectArea("TGQ")
TGQ->(dbSetOrder(1))

oMBrowse:= FWmBrowse():New() 
oMBrowse:SetAlias("TGQ")
oMBrowse:SetDescription(STR0001) // 'Requisição a Atendentes'
oMBrowse:Activate()

Return(Nil)

//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
	Rotina para construção do menu
@sample 	Menudef() 
@since		18/05/2015       
@version 	P12
@return 	aMenu, ARRAY, lista de opções disponíveis para usuário x rotina
/*/
//------------------------------------------------------------------------------
Static Function Menudef()
Local aRotina := {}

AAdd(aRotina,{STR0015,"PesqBrw"			,0 ,1}) //"Pesquisar"
AAdd(aRotina,{STR0016,"VIEWDEF.TECA803"	,0 ,2}) //"Visualizar"
AAdd(aRotina,{STR0003,"VIEWDEF.TECA803"	,0 ,3}) //"Requerir"
AAdd(aRotina,{STR0012,"VIEWDEF.TECA803"	,0 ,4}) //"Alterar"
AAdd(aRotina,{STR0007,"VIEWDEF.TECA803"	,0 ,5}) //"Excluir"
AAdd(aRotina,{STR0006,"At803Efet"		,0 ,6}) //"Efetivar"
	
Return( aRotina )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do Model
@sample 	ModelDef() 
@param		Nenhum
@return	ExpO Objeto FwFormModel 
@since		18/05/2015       
@version	P12   
/*/
//------------------------------------------------------------------------------

Static Function ModelDef()

Local oStruTGQ	:= FWFormStruct( 1, "TGQ" )				
Local oStruTGR	:= FWFormStruct( 1, "TGR" )
Local oModel    := Nil 									

oStruTGR:SetProperty('TGR_CODTGQ', MODEL_FIELD_OBRIGAT, .F.)

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("TECA803")
oModel:AddFields("TGQMASTER",/*cOwner*/,oStruTGQ)

// Janela Locacao de equipamentos
oModel:AddGrid("TGRDETAIL","TGQMASTER",oStruTGR,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,)

oModel:SetPrimaryKey({"TGQ_FILIAL","TGQ_CODIGO"})

// Relacionamento com o GRID Principal
oModel:SetRelation("TGRDETAIL",{{"TGR_FILIAL","xFilial('TGR')"},{"TGR_CODTGQ" ,"TGQ_CODIGO"}},TGR->(IndexKey(1)))
oModel:SetDescription(STR0001)  // "Local de Atendimento"
oModel:GetModel('TGQMASTER'):SetDescription(STR0004) // 'Requisição Equipamentos'
oModel:GetModel('TGRDETAIL'):SetDescription(STR0005)  // 'Itens da Requisição Equipamentos'
oModel:SetVldActivate({|oModel| At803PreOk(oModel) })

oModel:SetActivate()

Return( oModel )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Retorna a view do browse MVC
@sample 	ModelDef() 
@since		18/05/2015       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView	   := Nil							
Local oModel   := FWLoadModel("TECA803")	
Local oStruTGQ := FWFormStruct( 2, "TGQ", {|cCpo| !( Alltrim(cCpo)$'TGQ_OBS') })
Local oStruTGR := FWFormStruct( 2, "TGR", {|cCpo| !( Alltrim(cCpo)$'TGR_CODTGQ') })

oView := FWFormView():New()	
oView:SetModel(oModel)	

oView:AddField("VIEW_TGQ"		,oStruTGQ,"TGQMASTER")	
oView:AddGrid( "TECA803_TGR" 	,oStruTGR,"TGRDETAIL")
oView:AddIncrementField("TECA803_TGR","TGR_ITEM")

oView:CreateHorizontalBox("CABEC",30)		
oView:CreateHorizontalBox("ITENS",70)

oView:SetOwnerView("VIEW_TGQ"			, "CABEC"	)
oView:SetOwnerView("TECA803_TGR"		, "ITENS"	)
oView:SetDescription( STR0001 ) //'Requisição a Atendentes'

Return(oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At803Efet
	Efetivar a requisicao de equipamentos para atendentes
@sample 	At803Efet() 
@since		18/05/2015       
@version	P12
/*/
//------------------------------------------------------------------------------

Function At803Efet()
Local aSize    := MsAdvSize(.T.)
Local oDlg     := Nil	
Local oEnchoice:= Nil
Local aButtons := {}
Local nOpcBtn  := 0

If TGQ->TGQ_SITUAC <> "1"
	Help( " ", 1, "At803Situac", , STR0008, 1, 0 ) // 'Situação dessa requisição não permite efetivação. Apenas situação SOLICITADO é permitido efetivar.'
	Return(Nil)
EndIf

Aadd( aButtons, {"HISTORIC", {|| At803Detalhe()}, STR0019, STR0019 , {|| .T.}} ) //'Detalhes'###'Detalhes'

dbSelectArea("TGQ")
TGQ->(RegToMemory("TGQ",.F.))

DEFINE DIALOG oDlg TITLE STR0009 FROM aSize[7],0 TO aSize[6]/1.5,aSize[5]/1.5 PIXEL   // 'Efetivação de Requisição'
	oEnchoice := MSMGet():New("TGQ",TGQ->(RecNo()),4,,,,,{030,003,oDlg:nClientHeight/2-30,oDlg:nClientWidth/2-10},,4,,,,,,.T.,.T.,,,,,,,.T.)
	oEnchoice:oBox:Align = CONTROL_ALIGN_ALLCLIENT
ACTIVATE DIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| Iif(At803VldEfet(),(nOpcBtn := 1, oDlg:End()),Nil) },{|| nOpcBtn := 0, oDlg:End()},,aButtons )) CENTERED

//Atualizacao das demais tabelas
If nOpcBtn == 1
	If M->TGQ_SITUAC == "2" //Reprovado
		TGQ->(RecLock("TGQ",.F.))
			TGQ->TGQ_SITUAC := "2"
			TGQ->TGQ_OBS	:= M->TGQ_OBS
		TGQ->(MsUnlock())
	
	ElseIf M->TGQ_SITUAC == "3" //Aprovado
		MsgRun(STR0017,STR0018,{|| At803GrvEfet() }) //'Efetivando aprovação de Requisição'###'Aguarde...'
		
	EndIf
EndIf 

Return(Nil)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At803Detalhe
	Exibe o detalhe da requisicao na tela de 
@sample 	At803Detalhe() 
@since		27/05/2015       
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function At803Detalhe()

FWExecView(STR0001,"TECA803",MODEL_OPERATION_VIEW) //'Requisição a Atendentes'

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At803VldEfet
	Validacao da acao de efetivacao
@sample 	At803VldEfet() 
@since		18/05/2015       
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function At803VldEfet()

If !(M->TGQ_SITUAC $ "2|3")
	Help( " ", 1, "At803VldSit", , STR0010, 1, 0 ) // 'Informe a situação Reprovado ou Aprovado.'
	Return(.F.)
EndIf

If M->TGQ_SITUAC == "2" .And. Empty(M->TGQ_OBS)
	Help( " ", 1, "At803VldRej", , STR0011, 1, 0 ) // 'Ao rejeitar uma requisição, é obrigatório informar o campo observação'
	Return(.F.)
EndIf

Return(.T.)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At803PreOk
	Validacao da tela na inclusao, alteracao e exclusao
@param		oModel,objeto,Modelo de Dados de Requisição
@sample 	At803VldEfet(oModel) 
@since		18/05/2015       
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function At803PreOk(oModel)

If oModel:GetOperation() == 5 .And. TGQ->TGQ_SITUAC <> "1"
	Help( " ", 1, "At803Exc", , STR0013, 1, 0 ) // 'Não é possível excluir requisição já encerrada (aprovada ou rejeitada).'
	Return(.F.)
ElseIf oModel:GetOperation() == 4 .And. TGQ->TGQ_SITUAC <> "1"
	Help( " ", 1, "At803Alt", , STR0014, 1, 0 ) // 'Não é possível alterar requisição já encerrada (aprovada ou rejeitada).'
	Return(.F.)
EndIf

Return(.T.)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At803GrvEfet
	Gravacao de efetivacao como aprovada, gerando registros nas tabelas relacionadas
@sample 	At803GrvEfet() 
@since		18/05/2015       
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function At803GrvEfet()
Local cMsgErro := ""

Begin Transaction
		
dbSelectArea("TGR")
TGR->(dbSetOrder(1))
TGR->(dbSeek(xFilial("TGR")+TGQ->TGQ_CODIGO ))
While TGR->(!Eof()) .And. TGR->(TGR_FILIAL+TGR_CODTGQ) == xFilial("TGR")+M->TGQ_CODIGO
	
	//Inclui nas tabelas TFI e TEW
	dbSelectArea("TFI")
	TFI->(RecLock("TFI",.T.))
		TFI->TFI_FILIAL	:= xFilial("TFI")
		TFI->TFI_COD		:= GetSXENum('TFI','TFI_COD')
		ConfirmSX8()
		TFI->TFI_CODTGQ	:= TGR->TGR_CODTGQ
		TFI->TFI_ITEM		:= TGR->TGR_ITEM
		TFI->TFI_PRODUT	:= TGR->TGR_PRODUT
		TFI->TFI_QTDVEN	:= TGR->TGR_QUANT
		TFI->TFI_PERINI	:= TGR->TGR_DTINI
		TFI->TFI_SEPARA	:= "2" //Nao separado totalmente
		TFI->TFI_SEPSLD	:= TGR->TGR_QUANT
		TFI->TFI_PERFIM	:= TGR->TGR_DTFIM
		TFI->TFI_ITTGR	:= TGR->TGR_ITEM
		TFI->TFI_CODATD	:= TGQ->TGQ_CODATE
	TFI->(MsUnlock())
	
	//Gera a tabela TEW
	If !At800Start( @cMsgErro,,TGQ->TGQ_CODIGO,TFI->TFI_COD)
		DisarmTransaction()
		Exit
	EndIf			

	TGR->(dbSkip())
EndDo

//Atualiza a requisicao como aprovada
If Empty(cMsgErro)
	TGQ->(RecLock("TGQ",.F.))
		TGQ->TGQ_SITUAC := "3"
		TGQ->TGQ_OBS	:= M->TGQ_OBS
	TGQ->(MsUnlock())
	
	ConfirmSX8()
Else
	RollBackSX8()
	Help( " ", 1, "At803Tew", , cMsgErro, 1, 0 )
EndIf

End Transaction

Return(Nil)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At803InPad
	Função p/tratamento especial dos inicializadores padrões.
	Esta função só se faz necessário enquanto este programa não for totalmente modificado para MVC. 
@sample 	At803InPad(cCpo)
@since		01/07/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function At803InPad(cCpo)
Local cRet	:=	NIL	//---	Variável que irá conter o retorno para o inicializador padrão do campo mencionado no parâmetro
If	IsInCallStack("At803Efet")
	//---	Somente serão executadas as instruções abaixo se o controle da tela NÃO FOR através do MVC...
	If	cCpo	==	"TGQ_NOMATE"
		cRet	:=	Posicione("AA1", 1, xFIlial("AA1")+M->TGQ_CODATE, "AA1_NOMTEC")
	EndIf
Else
	//---	Somente serão executadas as instruções abaixo se o controle da tela FOR através do MVC...
	If	cCpo	==	"TGQ_NOMATE"
		cRet	:=	Posicione("AA1", 1, xFIlial("AA1")+FwFldGet("TGQ_CODATE"), "AA1_NOMTEC")
	EndIf
EndIf
Return	cRet