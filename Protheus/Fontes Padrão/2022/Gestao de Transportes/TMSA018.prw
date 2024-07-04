#Include "Protheus.ch"
#Include "FWMVCDEF.CH"
#Include "Fileio.ch"
#Include "TMSA018.CH"

#DEFINE CRLF Chr(13)+Chr(10)
/*/-----------------------------------------------------------
{Protheus.doc} TMSA018()
Monitor de Agendamento de Entrega

Uso: SIGATMS

@sample
//TMSA018()

@author Paulo Henrique Correa Cardoso
@since 23/07/2014
@version 1.0
-----------------------------------------------------------/*/
Function TMSA018()
Local oBrowse 	:= Nil			// Recebe o objeto do Browse

Private aRotina	:= MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DYD')
	oBrowse:SetDescription(STR0001)	// "Agendamento de Entrega"

	// Define os Status
	oBrowse:AddLegend( 'DYD_STATUS=="1"', "GREEN"  , STR0002 ) // "Em aberto"
	oBrowse:AddLegend( 'DYD_STATUS=="2"', "ORANGE" , STR0003 ) // "Realizado"
	oBrowse:AddLegend( 'DYD_STATUS=="3"', "RED"    , STR0004 ) // "Realizado com atraso"
	oBrowse:AddLegend( 'DYD_STATUS=="4"', "BLUE"   , STR0005 ) // "Não atendido"
	oBrowse:AddLegend( 'DYD_STATUS=="5"', "YELLOW" , STR0006 ) // "Aguardando Agd."
	oBrowse:AddLegend( 'DYD_STATUS=="6"', "GRAY"   , STR0007 ) // "Cancelado"

	oBrowse:Activate()

Return NIL

/*/-----------------------------------------------------------
{Protheus.doc} MenuDef()
Utilizacao de menu Funcional

Uso: TMSA018

@sample
//MenuDef()

@author Paulo Henrique Corrêa Cardoso.
@since 23/07/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function MenuDef()
Local aRotina := {}			// Recebe as Rotinas do Menu

	ADD OPTION aRotina TITLE STR0008 ACTION "AxPesqui"         OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.TMSA018"  OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0010 ACTION "VIEWDEF.TMSA018"  OPERATION 4 ACCESS 0 // "Reagendamento"
	ADD OPTION aRotina TITLE STR0011 ACTION "VIEWDEF.TMSA018"  OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0018 ACTION 'VIEWDEF.TMSA018'  OPERATION 5 ACCESS 0 // "Cancelar"

Return aRotina

/*/-----------------------------------------------------------
{Protheus.doc} ModelDef()
Definição do Modelo

Uso: TMSA018

@sample
//ModelDef()

@author Paulo Henrique Corrêa Cardoso.
@since 23/07/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function ModelDef()

Local oStruDYD := NIL 		// Recebe a Estrutura da tabela DYD
Local oStruDYJ := NIL 		// Recebe a Estrutura da tabela DYJ
Local oStruDTC := NIL 		// Recebe a Estrutura da tabela DTC
Local oModel   := NIL 		// Objeto do Model

oStruDYD := FWFormStruct( 1, 'DYD' )
oStruDYJ := FWFormStruct( 1, 'DYJ' )
oStruDTC := FWFormStruct( 1, 'DTC', { |cCampo| AllTrim( cCampo ) + "|" $ "DTC_NUMNFC|DTC_SERNFC|DTC_CODPRO|DTC_DESPRO|DTC_CODEMB|DTC_DESEMB|DTC_EMINFC|DTC_QTDVOL|DTC_PESO|DTC_PESOM3|DTC_VALOR|DTC_METRO3|" } )

//oStruDYD:SetProperty( 'DYD_TIPAGD' , MODEL_FIELD_VALID,FWBuildFeature(1,"A018VldTipo()"))

oModel := MPFormModel():New ( "TMSA018",,{|oModel| PosVldMdl(oModel)}, { |oModel| CommitMdl(oModel) }, /*bCancel*/ )

oModel:AddFields( 'MdFieldDYD',, oStruDYD )

oModel:SetVldActivate( { |oModel| VldActMdl( oModel ) } ) // Realiza a pre validação do Model

oModel:AddGrid  ( 'MdGridDYJ', 'MdFieldDYD', oStruDYJ)
oModel:AddGrid  ( 'MdGridDTC', 'MdFieldDYD', oStruDTC, /* bLinePre */, /* nLinePost */ ,/*bPre*/, /*bPos*/, {|oMdlDoc| A018LdDTC(oMdlDoc,DYD->DYD_FILDOC,DYD->DYD_DOC,DYD->DYD_SERIE) } /*BLoad*/ )

oModel:SetRelation("MdGridDYJ", { { "DYJ_FILIAL", "xFilial( 'DYJ' )"},  { "DYJ_NUMAGD", "DYD_NUMAGD" } }, DYJ->( IndexKey( 2 ) ) )

oModel:GetModel ( 'MdFieldDYD'):SetDescription (STR0001) 	// "Agendamento de Entrega"
oModel:GetModel ( 'MdGridDYJ' ):SetDescription(STR0012) 	// "Histórico Agendamentos"
oModel:GetModel ( 'MdGridDTC' ):SetDescription(STR0013)		// "Documentos Clientes"

oModel:GetModel( 'MdGridDYJ' ):SetOptional( .T. )
oModel:GetModel( 'MdGridDTC' ):SetOptional( .T. )

// Desabilita a Gravação do Grid da DTC
oModel:GetModel( 'MdGridDTC' ):SetOnlyQuery ( .T. )

oModel:SetPrimaryKey( { 'DYD_FILIAL', 'DYD_NUMAGD' } )

// Desabilita a exclusão de linhas do grid
oModel:GetModel( 'MdGridDTC' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'MdGridDYJ' ):SetNoDeleteLine( .T. )

oModel:SetActivate( )

Return (oModel)

/*/-----------------------------------------------------------
{Protheus.doc} ViewDef()
Definição da View

Uso: TMSA018

@sample
//ViewDef()

@author Paulo Henrique Corrêa Cardoso.
@since 23/07/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function ViewDef()
Local oView		:= NIL		// Recebe o objeto da View
Local oModel	:= NIL 		// Objeto do Model
Local oStruDYD  := NIL 		// Recebe a Estrutura da tabela DYD
Local oStruDYJ	:= NIL		// Recebe a Estrutura da tabela DYJ
Local oStruDTC	:= NIL		// Recebe a Estrutura da tabela DTC

oModel 	  := FwLoadModel( "TMSA018" )
oStruDYD  := FwFormStruct( 2,"DYD" )
oStruDYJ  := FwFormStruct( 2,"DYJ" )
oStruDTC  := FwFormStruct( 2,"DTC", { |cCampo| AllTrim( cCampo ) + "|" $ "DTC_NUMNFC|DTC_SERNFC|DTC_CODPRO|DTC_DESPRO|DTC_CODEMB|DTC_DESEMB|DTC_EMINFC|DTC_QTDVOL|DTC_PESO|DTC_PESOM3|DTC_VALOR|DTC_METRO3|" } )

oView := FwFormView():New()
oView:SetModel(oModel)

oStruDTC:SetProperty( '*' , MVC_VIEW_CANCHANGE,.F.)
oStruDYJ:SetProperty( '*' , MVC_VIEW_CANCHANGE,.F.)

oStruDYD:RemoveField ('DYD_STATUS')
oStruDYD:RemoveField ('DYD_DIAATR')
oStruDYD:RemoveField ('DYD_DATREF')
oStruDYJ:RemoveField ('DYJ_NUMAGD')
oStruDYJ:RemoveField ('DYJ_STATUS')

oView:AddField( 'VwFieldDYD' , oStruDYD , 'MdFieldDYD' )
oView:AddGrid ( 'VwGridDYJ'  , oStruDYJ , 'MdGridDYJ' )
oView:AddGrid ( 'VwGridDTC'  , oStruDTC , 'MdGridDTC' )

oView:CreateHorizontalBox( 'TOPO'   , 60 )
oView:CreateHorizontalBox( 'FOLDER' , 40 )

oView:CreateFolder( "PASTA", "FOLDER" )

oView:AddSheet( "PASTA", "ABA01", STR0013 ) // "Documentos Clientes"
oView:AddSheet( "PASTA", "ABA02", STR0012 ) //"Histórico Agendamentos"

oView:CreateHorizontalBox( "TAB_DTC"  , 100,,,"PASTA","ABA01" )
oView:CreateHorizontalBox( "TAB_DYJ"  , 100,,,"PASTA","ABA02" )

oView:AddUserButton( STR0023 , 'DOC', {|| TMSA018Doc()} ) 	//"Docum."

oView:EnableTitleView ('VwFieldDYD')

oView:SetOwnerView( 'VwFieldDYD' , 'TOPO' )
oView:SetOwnerView( 'VwGridDYJ' , 'TAB_DYJ' )
oView:SetOwnerView( 'VwGridDTC' , 'TAB_DTC' )

oView:SetFieldAction( 'DYD_DOC'		, { || A018LoadDTC() } )
oView:SetFieldAction( 'DYD_SERIE'	, { || A018LoadDTC() } )
oView:SetFieldAction( 'DYD_FILDOC'	, { || A018LoadDTC() } )
oView:SetFieldAction( 'DYD_TIPAGD'	, { || A018SetSta() } )
oView:SetFieldAction( 'DYD_PRDAGD'	, { || A018ClearHr() } )

oView:SetViewProperty("VwGridDYJ","GRIDDOUBLECLICK",{{|oFormulario,cFieldName,nLineGrid,nLineModel| gdDblClick(oFormulario,cFieldName,nLineGrid,nLineModel,oView,"DYJ")}})

Return oView

/*/-----------------------------------------------------------
{Protheus.doc} VldActMdl()
Realiza a Validaçãod de ativação do Model

Uso: TMSAB30

@sample
//VldActMdl(oModel)

@author Paulo Henrique Corrêa Cardoso.
@since 28/07/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function VldActMdl(oModel)
Local lRet 		 := .T. 		// Recebe o Retorno
Local nOperation := 0			// Recebe a Operacao realizada

nOperation := oModel:GetOperation()

If (DYD->DYD_STATUS $ '|2|3|6|' .AND. !IsInCallStack("TMSA200AGD") ) .AND. (nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE )
	Help('', 1,"TMSA01801",, STR0019,1)// "Este item nao podera sofrer alteracoes"
	lRet  := .F.
EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} PreVldGrid()
Não permite a inclução ou exclusção de linhas do grid

Uso: TMSA018

@sample
//PreVldGrid(oModelGrid, nLinha, cAcao)

@author Paulo Henrique Corrêa Cardoso.
@since 18/11/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function PreVldGrid(oModelGrid, nLinha, cAcao)
Local lRet := .T.

// Valida se pode ou não apagar uma linha do Grid
If cAcao == 'DELETE' .AND. !IsInCallStack("A018LoadDTC")
	lRet := .F.
	Help('', 1,"TMSA01801",, STR0019,1)// "Este item nao podera sofrer alteracoes"
EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} A018ClearHr()
Limpa os Campos de Hora

Uso: TMSA018

@sample
//A018ClearHr()

@author Paulo Henrique Corrêa Cardoso.
@since 29/07/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function A018ClearHr()
Local oView  := FWViewActive()			// Recebe o View Ativo

FwFldPut("DYD_INIAGD","",,,,.T.)
FwFldPut("DYD_FIMAGD","",,,,.T.)

oView:Refresh()
Return .T.

/*/-----------------------------------------------------------
{Protheus.doc} A018VldTipo()
Valida o Tipo de Agendamento

Uso: TMSA018

@sample
//A018VldTipo()

@author Paulo Henrique Corrêa Cardoso.
@since 29/07/2014admin

@version 1.0
-----------------------------------------------------------/*/
Function A018VldTipo()
Local lRet 		 := .T.		// Recebe o Retorno

If ALTERA .AND. FwFldGet("DYD_TIPAGD") == '4'

	//Alert(STR0016)// "Esta opção só pode ser utilizada na inclusão de um agendamento"
	Help('',,"TMSA01802",, STR0016,1,0)// "Esta opção só pode ser utilizada na inclusão de um agendamento"
	lRet := .F.

EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} A018SetSta()
Seta o Status do Agendamento

Uso: TMSA018

@sample
//A018SetSta()

@author Paulo Henrique Corrêa Cardoso.
@since 29/07/2014

@version 1.0
-----------------------------------------------------------/*/
Static Function A018SetSta()
Local oView  := FWViewActive()			// Recebe o View Ativo

If FwFldGet("DYD_TIPAGD") == '4' .AND. INCLUI
	FwFldPut("DYD_STATUS","5",,,,.T.)
	FwFldPut("DYD_PRDAGD","",,,,.T.)
	A018ClearHr() // Limpa os campos de Hora
ElseIf !(ALTERA .AND. FwFldGet("DYD_TIPAGD") == '4')
	FwFldPut("DYD_STATUS","1",,,,.T.)
EndIf

oView:Refresh()
Return

/*/-----------------------------------------------------------
{Protheus.doc} A018LoadDTC()
Preenche o Grid da DTC

Uso: TMSA018

@sample
//A018LoadDTC()

@author Paulo Henrique Corrêa Cardoso.
@since 28/07/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function A018LoadDTC()
Local cDoc		 := FwFldGet("DYD_DOC")		// Recebe o Documento
Local cSerie	 := FwFldGet("DYD_SERIE")	// Recebe a Serie do Documento
Local cFilDoc 	 := FwFldGet("DYD_FILDOC")	// Recebe a Filial do Documento
Local nCount 	 := 1						// Recebe o Contador
Local oModel	 := FWModelActive() 		// Recebe o Model Ativo
Local oModelDTC  := NIL						// Recebe o Model do DTC
Local lContinua	 := .T.						// Verifica se continua o Processamento
Local oView 	 := FWViewActive()			// Recebe o View Ativo

oModelDTC := oModel:GetModel("MdGridDTC")

If !Empty(cDoc) .AND. !Empty(cSerie) .AND. !Empty(cFilDoc)

	dbSelectArea("DTC")
	DTC->( dbSetOrder(7) )

	If !A018VldDoc()

		Help('', 1,"TMSA01803",, STR0022,1)	// "Este documento não pode ser utilizado no agendamento"
		FwFldPut("DYD_DOC"	  ,""	,,,,.T.)
		FwFldPut("DYD_SERIE"  ,""	,,,,.T.)
		FwFldPut("DYD_FILDOC" ,""	,,,,.T.)

	ElseIf !FindFunction("TmsPsqDY4") .Or. !TmsPsqDY4(cFilDoc, cDoc, cSerie)

		DTC->( dbSeek( FwxFilial("DTC")+ cDoc + cSerie + cFilDoc ) )
		dbSelectArea("DYD")
		DYD->( dbSetOrder(2) )

		// Verifica se o documento jah foi utilizado em outro agendamento  não cancelado
		DYD->( dbSeek( FwxFilial("DYD")+ cFilDoc + cDoc + cSerie + REPLICATE("Z",TamSx3("DYD_NUMAGD")[1]),.T.))
		DYD->(dbSkip(-1))

		If DYD->DYD_STATUS != '6' .AND. DYD->DYD_FILDOC == cFilDoc .AND. DYD->DYD_DOC == cDoc .AND. DYD->DYD_SERIE  == cSerie
			lContinua := .F.
		EndIf

		// Documento esta livre para uso
		If lContinua

			// Limpa o Grid
			oModelDTC:ClearData(.F.)
			nCount := 1
			oModelDTC:GoLine( nCount )

			// Adiciona as linhas de documentos
			While DTC->( ! EOF() .AND. DTC_FILIAL == FwxFilial("DTC") .AND. DTC_DOC == cDoc .AND. DTC_SERIE == cSerie .AND. DTC_FILDOC == cFilDoc )

				// adiciona novas linhas no Grid
				If nCount > 1
					oModelDTC:AddLine()
				EndIf

				 FwFldPut("DTC_NUMNFC"	,DTC->DTC_NUMNFC	,nCount,,,.T.)
				 FwFldPut("DTC_SERNFC"	,DTC->DTC_SERNFC	,nCount,,,.T.)
				 FwFldPut("DTC_CODPRO"	,DTC->DTC_CODPRO	,nCount,,,.T.)
				 FwFldPut("DTC_DESPRO"	,POSICIONE("SB1",1,XFILIAL("SB1")+DTC->DTC_CODPRO,"B1_DESC"),nCount,,,.T.)
				 FwFldPut("DTC_CODEMB"	,DTC->DTC_CODEMB	,nCount,,,.T.)
				 FwFldPut("DTC_DESEMB"	,TABELA("MG",DTC->DTC_CODEMB,.F.),nCount,,,.T.)
				 FwFldPut("DTC_EMINFC"	,DTC->DTC_EMINFC	,nCount,,,.T.)
				 FwFldPut("DTC_QTDVOL"	,DTC->DTC_QTDVOL	,nCount,,,.T.)
				 FwFldPut("DTC_PESO  "	,DTC->DTC_PESO		,nCount,,,.T.)
				 FwFldPut("DTC_PESOM3"	,DTC->DTC_PESOM3	,nCount,,,.T.)
				 FwFldPut("DTC_VALOR "	,DTC->DTC_VALOR		,nCount,,,.T.)
				 FwFldPut("DTC_METRO3"	,DTC->DTC_METRO3	,nCount,,,.T.)

				DTC->(dbSkip())
				nCount += 1
			EndDo

			// Preenche os campos de Filial de Origem e de Destino
			FwFldPut("DYD_FILORI",DT6->DT6_FILORI,,,,.T.)
			FwFldPut("DYD_FILDES",DT6->DT6_FILDES,,,,.T.)

		Else
			Help('', 1,"TMSA01804",, STR0017 + DYD->DYD_NUMAGD,1)// "Documento já selecionado para o Agendamento Nro. : "

			FwFldPut("DYD_DOC"	  ,""	,,,,.T.)
			FwFldPut("DYD_SERIE"  ,""	,,,,.T.)
			FwFldPut("DYD_FILDOC" ,""	,,,,.T.)
		EndIf
	ElseIf FindFunction("TmsPsqDY4") .And. TmsPsqDY4(cFilDoc, cDoc, cSerie)

		DbSelectArea("DY4")
		DY4->(DbSetOrder(1)) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
		DY4->( dbSeek( FwxFilial("DY4")+ cFilDoc + cDoc + cSerie ) )
		dbSelectArea("DYD")
		DYD->( dbSetOrder(2) )

		// Verifica se o documento jah foi utilizado em outro agendamento  não cancelado
		DYD->( dbSeek( FwxFilial("DYD")+ cFilDoc + cDoc + cSerie + REPLICATE("Z",TamSx3("DYD_NUMAGD")[1]),.T.))
		DYD->(dbSkip(-1))

		If DYD->DYD_STATUS != '6' .AND. DYD->DYD_FILDOC == cFilDoc .AND. DYD->DYD_DOC == cDoc .AND. DYD->DYD_SERIE  == cSerie
			lContinua := .F.
		EndIf

		// Documento esta livre para uso
		If lContinua

			// Limpa o Grid
			oModelDTC:ClearData(.F.)
			nCount := 1
			oModelDTC:GoLine( nCount )

			// Adiciona as linhas de documentos
			While DY4->( ! EOF() .AND. DY4_FILIAL == FwxFilial("DY4") .AND. DY4_DOC == cDoc .AND. DY4_SERIE == cSerie .AND. DY4_FILDOC == cFilDoc )

				// adiciona novas linhas no Grid
				If nCount > 1
					oModelDTC:AddLine()
				EndIf

				DbSelectArea("DTC")
				DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto
				If DTC->(MsSeek(xFilial("DTC")+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM+DY4->DY4_CODPRO+DY4->DY4_FILORI+DY4->DY4_LOTNFC))
					FwFldPut("DTC_NUMNFC"	,DTC->DTC_NUMNFC	,nCount,,,.T.)
					FwFldPut("DTC_SERNFC"	,DTC->DTC_SERNFC	,nCount,,,.T.)
					FwFldPut("DTC_CODPRO"	,DTC->DTC_CODPRO	,nCount,,,.T.)
					FwFldPut("DTC_DESPRO"	,POSICIONE("SB1",1,XFILIAL("SB1")+DTC->DTC_CODPRO,"B1_DESC"),nCount,,,.T.)
					FwFldPut("DTC_CODEMB"	,DTC->DTC_CODEMB	,nCount,,,.T.)
					FwFldPut("DTC_DESEMB"	,TABELA("MG",DTC->DTC_CODEMB,.F.),nCount,,,.T.)
					FwFldPut("DTC_EMINFC"	,DTC->DTC_EMINFC	,nCount,,,.T.)
					FwFldPut("DTC_QTDVOL"	,DTC->DTC_QTDVOL	,nCount,,,.T.)
					FwFldPut("DTC_PESO  "	,DTC->DTC_PESO	,nCount,,,.T.)
					FwFldPut("DTC_PESOM3"	,DTC->DTC_PESOM3	,nCount,,,.T.)
					FwFldPut("DTC_VALOR "	,DTC->DTC_VALOR	,nCount,,,.T.)
					FwFldPut("DTC_METRO3"	,DTC->DTC_METRO3	,nCount,,,.T.)
				Endif
				DY4->(dbSkip())
				nCount += 1
			EndDo

			// Preenche os campos de Filial de Origem e de Destino
			FwFldPut("DYD_FILORI",DT6->DT6_FILORI,,,,.T.)
			FwFldPut("DYD_FILDES",DT6->DT6_FILDES,,,,.T.)

		Else
			Help('', 1,"TMSA01804",, STR0017 + DYD->DYD_NUMAGD,1)// "Documento já selecionado para o Agendamento Nro. : "

			FwFldPut("DYD_DOC"	  ,""	,,,,.T.)
			FwFldPut("DYD_SERIE"  ,""	,,,,.T.)
			FwFldPut("DYD_FILDOC" ,""	,,,,.T.)
		EndIf
	Else
		Help('', 1,"TMSA01805",, STR0020,1)// "Documento de Cliente não Encontrado "
		FwFldPut("DYD_DOC"	  ,""	,,,,.T.)
		FwFldPut("DYD_SERIE"  ,""	,,,,.T.)
		FwFldPut("DYD_FILDOC" ,""	,,,,.T.)
	EndIf

EndIf
oView:Refresh()
Return .T.

/*/-----------------------------------------------------------
{Protheus.doc} PosVldMdl()
Pos Valid do Modelo

Uso: TMSA018

@sample
//PosVldMdl(oModel)

@author Paulo Henrique Corrêa Cardoso.
@since 25/07/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function PosVldMdl(oModel)
Local nOpcx		 := oModel:GetOperation()	// Recebe a Opção
Local oModelDYJ := NIL						// Recebe o Modelo da DYJ
Local nMaxLinha	 := 0						// Recebe o numero maximo de Linhas
Local lRet 		 := .T.						// Recebe o Retorno

If nOpcx == MODEL_OPERATION_UPDATE

	oModelDYJ := oModel:GetModel("MdGridDYJ")
	nMaxLinha  := oModelDYJ:Length()
	oModelDYJ:GoLine( nMaxLinha )

	// Verifica se houve alteração
	If (	oModel:GetValue('MdFieldDYD',"DYD_TIPAGD") == oModel:GetValue('MdGridDYJ',"DYJ_TIPAGD",nMaxLinha) .AND.;
			oModel:GetValue('MdFieldDYD',"DYD_DATAGD") == oModel:GetValue('MdGridDYJ',"DYJ_DATAGD",nMaxLinha) .AND.;
			oModel:GetValue('MdFieldDYD',"DYD_PRDAGD") == oModel:GetValue('MdGridDYJ',"DYJ_PRDAGD",nMaxLinha) .AND.;
			oModel:GetValue('MdFieldDYD',"DYD_INIAGD") == oModel:GetValue('MdGridDYJ',"DYJ_INIAGD",nMaxLinha) .AND.;
			oModel:GetValue('MdFieldDYD',"DYD_FIMAGD") == oModel:GetValue('MdGridDYJ',"DYJ_FIMAGD",nMaxLinha) .AND.;
			oModel:GetValue('MdFieldDYD',"DYD_MOTAGD") == oModel:GetValue('MdGridDYJ',"DYJ_MOTAGD",nMaxLinha) )

		lRet := .F.
		oModel:SetErrorMessage (,,,,,STR0014)//"Não Houve Alteração nos dados Agendamento!"
	EndIf

EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} CommitMdl()
Commit do Agendamento

Uso: TMSA018

@sample
//CommitMdl(oModel)

@author Paulo Henrique Corrêa Cardoso.
@since 23/07/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function CommitMdl( oModel )
Local aArea		:= GetArea()				// Recebe a area ativa
Local lRet		:= .T.						// Recebe o Retorno
Local nOpcx 	:= oModel:GetOperation()	// Recebe a operação realizada
Local oModelDYJ := NIL						// Recebe o Modelo da DYJ
Local nMaxLinha	:= 0						// Recebe o numero maximo de Linhas
Local nLinha	:= 0						// Recebe a linha
Local cFilDoc	:= ""						// Recebe a Filial do documento
Local cDoc		:= ""						// Recebe o Numero do documento7
Local cSerie	:= ""						// Recebe a Serie do documento
Local cNumAgd	:= ""						// Recebe o numero do agendamento
Local oDlgCan	:= NIL						// Recebe o objeto da Dialog de cancelamento
Local oCanObs	:= NIL						// Recebe o objeto do Campo de observação de cancelamento
Local cCanObs	:= ""						// Recebe o valor digitado no campo de observação de cancelamento
Local lCanOk	:= .F.						// Recebe os valores dos botões da Dialog de Obs de Cancelamento
Local aAtraso 	:= {}
Local lCpoDtHr	:= DYJ->(FieldPos("DYJ_DATHST")) > 0

cFilDoc	:= oModel:GetValue('MdFieldDYD',"DYD_FILDOC")
cDoc	:= oModel:GetValue('MdFieldDYD',"DYD_DOC")
cSerie	:= oModel:GetValue('MdFieldDYD',"DYD_SERIE")
cNumAgd	:= oModel:GetValue('MdFieldDYD',"DYD_NUMAGD")

If nOpcx !=  MODEL_OPERATION_DELETE // Inclusão ou Alteração

	// Prepara o Grid para Salvar o Historico
	If nOpcx == MODEL_OPERATION_INSERT

		If !FindFunction('TmsPsqDY4') .Or. !TmsPsqDY4(cFilDoc, cDoc, cSerie)
			// Atualiza DTC
			dbSelectArea("DTC")
			DTC->( dbSetOrder(3) )
			If DTC->( dbSeek(FwxFilial("DTC")+ cFilDoc  + cDoc + cSerie ) )

				While DTC->( !EOF() .AND. DTC_FILIAL == FwxFilial("DTC") .AND. DTC_FILDOC == cFilDoc .AND. DTC_DOC == cDoc  .AND. DTC_SERIE == cSerie )

					RecLock("DTC",.F.)
					DTC->DTC_NUMAGD := cNumAgd
					DTC->(MsUnLock())

					DTC->(dbSkip())
				EndDo
			EndIf
		Else
			// Atualiza DY4
			dbSelectArea("DY4")
			DY4->( dbSetOrder(1) ) //Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
			If DY4->(MsSeek(FwxFilial("DY4")+cFilDoc + cDoc + cSerie))
				While DY4->( !EOF() .AND. DY4_FILIAL == FwxFilial("DY4") .AND. DY4_FILDOC == cFilDoc .AND. DY4_DOC == cDoc  .AND. DY4_SERIE == cSerie )
					DbSelectArea("DTC")
					DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto
					If DTC->(MsSeek(xFilial("DTC")+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM+DY4->DY4_CODPRO+DY4->DY4_FILORI+DY4->DY4_LOTNFC))
						RecLock("DTC",.F.)
						DTC->DTC_NUMAGD := cNumAgd
						DTC->(MsUnLock())
					Endif
					DY4->(dbSkip())
				EndDo
			Endif
		Endif

		// Atualiza DT6
		dbSelectArea("DT6")
		DT6->( dbSetOrder(1) )
		If DT6->( dbSeek(FwxFilial("DT6")+ cFilDoc  + cDoc + cSerie ) )
			RecLock("DT6",.F.)
			DT6->DT6_NUMAGD := cNumAgd
			DT6->(MsUnLock())
		EndIf

		nLinha := 1
		oModelDYJ := oModel:GetModel("MdGridDYJ")
		oModelDYJ:GoLine( nLinha )

		oModel:SetValue( "MdFieldDYD" , "DYD_DATREF",oModel:GetValue('MdFieldDYD',"DYD_DATAGD") )

	ElseIf nOpcx == MODEL_OPERATION_UPDATE

		// Atualiza o Status de acordo com o Tipo
		 A018SetSta()

		oModelDYJ := oModel:GetModel("MdGridDYJ")
		oModelDYJ:AddLine()
		nMaxLinha  := oModelDYJ:Length()
		oModelDYJ:GoLine( nMaxLinha )
		nLinha := nMaxLinha

		aAtraso := A018CalAtr(oModel:GetValue('MdFieldDYD',"DYD_DATAGD"),oModel:GetValue('MdFieldDYD',"DYD_TIPAGD"),oModel:GetValue('MdFieldDYD',"DYD_NUMAGD"))

		dbSelectarea("DYD")
		DYD->( dbSetOrder(1) )

		If DYD->( dbSeek( FwxFilial("DYD") + cNumAgd ) )

			If DYD->DYD_TIPAGD == '4'
				oModel:SetValue( "MdFieldDYD" , "DYD_DATREF",oModel:GetValue('MdFieldDYD',"DYD_DATAGD") )
				oModel:SetValue( "MdFieldDYD" , "DYD_DIAATR",0 )
			Endif

		EndIf

		If !Empty(aAtraso[1]) .AND. aAtraso[2] >= 0
			oModel:SetValue( "MdFieldDYD" , "DYD_DATREF",aAtraso[1] )
			oModel:SetValue( "MdFieldDYD" , "DYD_DIAATR",aAtraso[2] )
		Endif

	EndIf

	// Preenche os campos do Historico
	If nLinha > 0
		oModel:SetValue( "MdGridDYJ" , "DYJ_ITEAGD", STRZERO(nLinha,3) )
		oModel:SetValue( "MdGridDYJ" , "DYJ_TIPAGD", oModel:GetValue('MdFieldDYD',"DYD_TIPAGD") )
		oModel:SetValue( "MdGridDYJ" , "DYJ_DATAGD", oModel:GetValue('MdFieldDYD',"DYD_DATAGD") )
		oModel:SetValue( "MdGridDYJ" , "DYJ_PRDAGD", oModel:GetValue('MdFieldDYD',"DYD_PRDAGD") )
		oModel:SetValue( "MdGridDYJ" , "DYJ_INIAGD", oModel:GetValue('MdFieldDYD',"DYD_INIAGD") )
		oModel:SetValue( "MdGridDYJ" , "DYJ_FIMAGD", oModel:GetValue('MdFieldDYD',"DYD_FIMAGD") )
		oModel:SetValue( "MdGridDYJ" , "DYJ_MOTAGD", oModel:GetValue('MdFieldDYD',"DYD_MOTAGD") )
		If lCpoDtHr
			oModel:SetValue( "MdGridDYJ" , "DYJ_DATHST", dDataBase )
			oModel:SetValue( "MdGridDYJ" , "DYJ_HORHST", StrTran(Left(Time(),5),':','') )
		EndIf
	EndIf

	// Salva os Dados
	lRet:= FWFormCommit( oModel )
ELse

	If IsInCallStack("TMSA200AGD")
		// Exclusão
		lRet:= FWFormCommit( oModel )
	Else
		// Cancelamento
		Define MsDialog oDlgCan Title STR0025  From 000,000 To 200,490 Of oDlgCan Pixel //"Motivo de Cancelamento"
		@005,032 Say STR0026 Size 150,007 Pixel Of oDlgCan //"Digite um motivo para o cancelamento:"
		@015,032 GET oCanObs VAR cCanObs OF oDlgCan MULTILINE SIZE 200,050 COLORS 0, 16777215 HSCROLL PIXEL
		@070,032 Button STR0027	 Size 036,013 Pixel Action (lCanOk := !Empty(cCanObs),oDlgCan:End())//"&Confirmar"
		@070,072 Button STR0028 Size 036,013 Pixel Action(lCanOk := .F.,oDlgCan:End()) //"&Sair"
		Activate MsDialog oDlgCan Centered

		If  lRet := lCanOk

			cCanObs := + CRLF + CRLF + "-------------------" + STR0025 + "-------------------" + CRLF + cCanObs // "Motivo de Cancelamento"
			dbSelectArea("DYD")
			DYD->(dbSetOrder(1))

			If DYD->( dbSeek(FwxFilial("DYD")+ cNumAgd ) )
				RecLock("DYD",.F.)
				DYD->DYD_STATUS := "6"
				DYD->DYD_DTCAGD := DDATABASE
				DYD->DYD_MOTAGD := DYD->DYD_MOTAGD + cCanObs
				DYD->(MsUnLock())
			EndIf
			oModel:DeActivate()
		Else
				oModel:SetErrorMessage (,,,,,STR0029) //"Campo Motivo de Cancelamento deve ser preenchido. "
		EndIf
	EndIf

	If lRet
		If !FindFunction('TmsPsqDY4') .Or. !TmsPsqDY4(cFilDoc, cDoc, cSerie)
			// Atualiza DTC
			dbSelectArea("DTC")
			DTC->( dbSetOrder(3) )
			If DTC->( dbSeek(FwxFilial("DTC")+ cFilDoc  + cDoc + cSerie ) )

				While DTC->( !EOF() .AND. DTC_FILIAL == FwxFilial("DTC") .AND. DTC_FILDOC == cFilDoc .AND. DTC_DOC == cDoc  .AND. DTC_SERIE == cSerie )

					RecLock("DTC",.F.)
					DTC->DTC_NUMAGD := ""
					DTC->(MsUnLock())

					DTC->(dbSkip())
				EndDo
			EndIf
		Else
			// Atualiza Dy4
			dbSelectArea("DY4")
			DY4->( dbSetOrder(1) )
			If DY4->( dbSeek(FwxFilial("DY4")+ cFilDoc  + cDoc + cSerie ) )
				While DY4->( !EOF() .AND. DY4_FILIAL == FwxFilial("DY4") .AND. DY4_FILDOC == cFilDoc .AND. DY4_DOC == cDoc  .AND. DY4_SERIE == cSerie )
					DbSelectArea("DTC")
					DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto
					If DTC->(MsSeek(xFilial("DTC")+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM+DY4->DY4_CODPRO+DY4->DY4_FILORI+DY4->DY4_LOTNFC))
						RecLock("DTC",.F.)
						DTC->DTC_NUMAGD := ""
						DTC->(MsUnLock())
					Endif
					DY4->(dbSkip())
				EndDo
			Endif
		Endif

		// Atualiza DT6
		dbSelectArea("DT6")
		DT6->( dbSetOrder(1) )
		If DT6->( dbSeek(FwxFilial("DT6")+ cFilDoc  + cDoc + cSerie ) )
			RecLock("DT6",.F.)
			DT6->DT6_NUMAGD := ""
			DT6->(MsUnLock())
		EndIf
	EndIf

EndIf


RestArea( aArea )

Return( lRet )


/*---------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} TMSA018Fil()
Filtra linhas do Grid
Uso: SIGATMS

@sample
//TMSA018Fil()

@author Paulo Henrique Correa Cardoso
@since 20/08/2014
@version 1.0
//----------------------------------------------------------------------------------------------------------------------------------
*/
Function TMSA018Fil()
	Local nCount    := 0				// Recebe o Contador
	Local aRet      := {}				// Recebe o Retorno
	Local aCpos     := {}				// Recebe os Campos do SX3 - DYD
	Local cQuery    := ""				// Recebe a Query
	Local aAreaAtu  := GetArea()		// Recebe a Area Ativa
	Local cAliasDYD := GetNextAlias()	// Recebe o Proximo alias

	aCpos := A018CamposDYD()

	Aadd( aCpos, "DYD_STTAGD" )

	cQuery := "SELECT * FROM (
	cQuery += "SELECT DYD1.DYD_NUMAGD DYD_NUMAGD,DYD1.R_E_C_N_O_ DYDRECNO"
	cQuery += "  FROM "
	cQuery += RetSqlName("DYD") + " DYD1"
	cQuery += "    WHERE DYD1.DYD_FILIAL = '" + xFilial('DYD')  + "'"
	cQuery += "      AND DYD1.DYD_NUMAGD = '" + DT6->DT6_NUMAGD + "'"
	cQuery += "      AND DYD1.D_E_L_E_T_ = ' ' "
	cQuery += " UNION ALL "
	cQuery += "SELECT DYD2.DYD_NUMAGD DYD_NUMAGD,DYD2.R_E_C_N_O_ DYDRECNO"
	cQuery += "  FROM "
	cQuery += RetSqlName("DYJ") + " DYJ, "
	cQuery += RetSqlName("DYD") + " DYD2 "
	cQuery += "    WHERE DYJ.DYJ_FILIAL = '" + xFilial('DYJ')  + "'"
	cQuery += "      AND DYJ.DYJ_FILDOC = '" + DT6->DT6_FILDOC + "'"
	cQuery += "      AND DYJ.DYJ_DOC    = '" + DT6->DT6_DOC    + "'"
	cQuery += "      AND DYJ.DYJ_SERIE  = '" + DT6->DT6_SERIE  + "'"
	cQuery += "      AND DYJ.D_E_L_E_T_ = ' ' "
	cQuery += "      AND DYD2.DYD_FILIAL = '" + xFilial('DYD')  + "'"
	cQuery += "      AND DYD2.DYD_NUMAGD = DYJ_NUMAGD "
	cQuery += "      AND DYD2.D_E_L_E_T_ = ' ' ) QRYAGD "
	cQuery += "    GROUP BY DYD_NUMAGD, DYDRECNO""
	cQuery += "    ORDER BY DYD_NUMAGD"

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDYD,.T.,.T.)

	While (cAliasDYD)->(!Eof())

		DYD->( dbGoTo( (cAliasDYD)->DYDRECNO ) )

		Aadd( aRet, { (cAliasDYD)->DYDRECNO, Array( Len(aCpos) + 1)  })

		For nCount := 1 To Len(aCpos)

			If aCpos[nCount] == "DYD_STTAGD"
				aRet[Len(aRet)][2][nCount] := ""
			ElseIf aCpos[nCount] == "DYD_NOMUSR"
				aRet[Len(aRet)][2][nCount] := CriaVar('DYD_NOMUSR')
			ElseIf aCpos[nCount] == "DYD_NOMREM"
				aRet[Len(aRet)][2][nCount] := CriaVar('DYD_NOMREM')
			ElseIf aCpos[nCount] == "DYD_NOMDES"
				aRet[Len(aRet)][2][nCount] := CriaVar('DYD_NOMDES')
			Else
				aRet[Len(aRet)][2][nCount] := DYD->(FieldGet(FieldPos(aCpos[nCount])))
			EndIf
	Next nCount

		aRet[Len(aRet)][2][Len(aCpos)+1] := .F.

		(cAliasDYD)->(dbSkip())
	EndDo

	(cAliasDYD)->(dbCloseArea())

	RestArea(aAreaAtu)

Return aRet

/*/{Protheus.doc} A018CamposDYD
Função para carregamento dos campos da DYD
@author izac.ciszevski
@since 17/05/2018
@type function
/*/
Static Function A018CamposDYD( )
	Local aFields := {}
	Local nField  := 0
	Local oDYD	  := FwFormStruct(2,"DYD")

	For nField := 1 to Len(oDYD:aFields)
		AAdd(aFields, oDYD:aFields[nField][1] )
	Next nField

	FwFreeObj(oDYD)

Return aFields


/*/-----------------------------------------------------------
{Protheus.doc} A018CalAtr()
Realiza o calculo de dias de atraso

Uso: TMSA018

@sample
//A018CalAtr(dDatAgend,cTipo)

@author Paulo Henrique Corrêa Cardoso.
@since 02/09/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function A018CalAtr(dNewDatAgd,cTipo,cNumAgd)
Local aRet		   := {}				// Recebe o Retorno
Local nDiasDif	   := 0					// Recebe a diferença de dias
Local nDiasAtr	   := 0					// Recebe os dias de Atraso
Local dNewDatRef   :=  STOD("//")		// Recebe a Nova data de Referencia
Local lZeraAtr	   := .F.				// Zera Atraso

Default dNewDatAgd :=  STOD("//")		// Recebe a nova data de agendamento
Default cTipo	   := ""				// Recebe o Tipo de Agendamento
Default cNumAgd	   := ""				// Recebe o Numero do agendamento

// Adiciona os valores Default no aRet
Aadd( aRet,STOD("//") )
Aadd(aRet,-1)

dbSelectarea("DYD")
DYD->( dbSetOrder(1) )

If DYD->( dbSeek( FwxFilial("DYD") + cNumAgd ) )

	// Pega a diferença da Nova data de agendamento com a ultima data de Agendamento
	nDiasDif := DateDiffDay(dNewDatAgd,DYD->DYD_DATAGD)

	If dNewDatAgd < DYD->DYD_DATAGD
		nDiasDif = nDiasDif * (-1)
	EndIf

	// Cria a nova data de Referencia
	dNewDatRef := DaySum(DYD->DYD_DATREF, nDiasDif)

	dbSelectarea("DYJ")
	DYJ->( dbSetOrder(2) )
	If DYJ->( dbSeek( FwxFilial("DYJ") + cNumAgd ) )

		// Realiza a diferença entre a data de referencia e a primeira data de agendamento
		nDiasAtr := DateDiffDay(dNewDatRef,DYJ->DYJ_DATAGD)

		If lZeraAtr := dNewDatRef < DYJ->DYJ_DATAGD
			nDiasAtr = nDiasAtr * (-1)
		EndIf

		If cTipo $ "1|3"  .OR. lZeraAtr //	Prioriade Transp. | Transportador
			aRet[1]  := Iif( nDiasAtr < 0 .AND. lZeraAtr , dNewDatAgd ,dNewDatRef)
			aRet[2]  := Iif( nDiasAtr < 0 ,0 ,nDiasAtr)
		EndIf
	EndIf
EndIf

Return aRet

/*/-----------------------------------------------------------
{Protheus.doc} A018AtStNA()
Atualiza para Status "Não Atendido" os Agendamentos em aberto
com Data menor que a do Dia

Uso: TMSA018

@sample
//A018AtStNA()

@author Paulo Henrique Corrêa Cardoso.
@since 01/09/2014
@version 1.0
-----------------------------------------------------------/*/
Function A018AtStNA()
Local cPath			:= CurDir()			//Informa o Path do arquivo
Local cNameFile		:= ""				//Caminho do arquivo
Local nArq			:= 0				//Numero de handle do Arquivo
Local lContinua 	:= .T.				// Continua o Processamento
Local aArqDir 		:= {}				// Recebe os Arquivos "*.tms"
Local nCount		:= 0				// Recebe o Contador de Arquivos
Local cQuery		:= ""				// Recebe a Query da DYD
Local cAliasDYD		:= ""				// Recebe o Alias da DYD

// Nome do Arquivo
cNameFile := cPath+"\"+DTOS(dDataBase)+"_"+ FWxFilial("DYD")+".tms"

// Apaga os arquivos Existentes
aArqDir := DIRECTORY("*.tms", cPath)

For nCount := 1  to Len(aArqDir)

	If SubStr(aArqDir[nCount][1],1,8) != DTOS(dDataBase)
		FERASE( aArqDir[nCount][1] )
	EndIf

Next nCount

// Cria o Arquivo se ele não existir
If !File(cNameFile,0,.F.)

	If (nArq:=FCREATE(cNameFile,0,,.F.)) == -1
		Help('', 1,"TMSA01806",, STR0021 + STR(FERROR()),1) //"Erro na manutenção de status: "
		lContinua := .F.
	Else
		FClose(nArq)
	EndIf
Else
	lContinua := .F.
EndIf

// Atualiza o Status para "Não Atendido"
If lContinua
	dbSelectArea("DYD")

	cAliasDYD := GetNextAlias()

	cQuery +="	SELECT    										"
	cQuery +="		R_E_C_N_O_  AS RECNO						"
	cQuery +="	FROM " +RetSqlName("DYD")
	cQuery +="	WHERE  											"
	cQuery +="		DYD_STATUS = '1' 							"
	cQuery +="		AND DYD_DATAGD <= '"+ DTOS(dDataBase) +"' 	"
	cQuery +="		AND D_E_L_E_T_ = ' '						"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDYD)
	While (cAliasDYD)->(!Eof())

		DYD->( dbGoTo( (cAliasDYD)->RECNO ) )

		If DYD->DYD_DATAGD <= dDataBase .AND. DYD->DYD_STATUS == '1'

			RecLock("DYD",.F.)
			DYD->DYD_STATUS := '4'
			DYD->(MsUnLock())

		EndIf

		(cAliasDYD)->(dbSkip())
	EndDo
	(cAliasDYD)->(dbCloseArea())

EndIf

Return



/*/-----------------------------------------------------------
{Protheus.doc} A018VldDoc()
Valida se o documento digitado pode ser incluido no agendamento

Uso: TMSA018

@sample
//A018VldDoc()

@author Paulo Henrique Corrêa Cardoso.
@since 11/09/2014
@version 1.0
-----------------------------------------------------------/*/
Function A018VldDoc()
Local lRet := .F.   //Recebe o Retorno

If !(DT6->DT6_DOCTMS $ "|1|3|8|E|F|G|K|L|" ) .AND. !(DT6->DT6_STATUS $ "7|9|" ) .AND. DT6->DT6_BLQDOC == "2" .AND. Empty (DT6->DT6_NUMAGD)
	lRet := .T.
EndIf

Return lRet



/*/-----------------------------------------------------------
{Protheus.doc} TMSA018Doc()
Tela para visualização do Documento através do Agendamento de Entrega

Uso: TMSA018

@sample
//TMSA018Doc()

@author Rafael Souza
@since 21/10/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function TMSA018Doc()

Local aAreaDT6 := DT6->(GetArea())  // Recebe a Area Atual

DT6->(DbSetOrder(1))
	If DT6->(MsSeek(xFilial("DT6")+DYD->DYD_FILDOC+DYD->DYD_DOC+DYD->DYD_SERIE))
		cCadastro := STR0024 //"Manutencao de Documentos - Visualizar"
		TMSA500Mnt("DT6",DT6->(Recno()),2)
	EndIf

RestArea( aAreaDT6 )

Return

/*/-----------------------------------------------------------
{Protheus.doc} TMSA018Agd()
Valida se o Update do Agendamento já foi executado

Uso: TMSA018

@sample
//TMSA018Agd()

@author Paulo Henrique Corrêa Cardoso.
@since 13/11/2014
@version 1.0
-----------------------------------------------------------/*/
Function TMSA018Agd()
Local lRet := .F.		// Recebe o Retorno

If	DYD->(ColumnPos("DYD_DIAATR"))>0
	lRet := .T.
Endif

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSA018Vld()
Validações do agendamento de entrega

Uso: TMSA018 e TMSA050

@sample

@author Rafael dos Santos Souza
@since 13/07/2015
@version 1.0
-----------------------------------------------------------/*/
Function TMSA018Vld(cCampo, dDatAgend, cHoraIni, cHoraFim)

	Local lRet      := .T.                //Recebe o Retorno
	Local nHorAtu   := 0
	Local nHoraIni  := 0                  // Recebe a Hora de Inicio do Agendamento
	Local nHoraFim  := 0                  // Recebe a Hora de Fim do Agendamento
	Local cHora     := Substr(Time(),1,5) // Recebe a hora atual do sistema
	Local cAliasFld := ""                 // Recebe o Alias da tabela

	Default cCampo    := ""
	Default dDatAgend := Stod("//") // Recebe a Data do Agendamento
	Default cHoraIni  := ""         // Recebe a Hora inicial Formatada
	Default cHoraFim  := ""         // Recebe a Hora final Formatada

	If Empty(cCampo)
		cCampo := ReadVar()
	EndIf

	If "DYD_" $ cCampo
		cAliasFld := "DYD"
	ElseIf "DTC_" $ cCampo
		cAliasFld := "DTC"
	EndIf

	If ! Empty(cAliasFld)

		Iif(Empty(dDatAgend), dDatAgend := &("M->" + cAliasFld + "_DATAGD"), )
		Iif(Empty(cHoraIni) , cHoraIni  := &("M->" + cAliasFld + "_INIAGD"), )
		Iif(Empty(cHoraFim) , cHoraFim  := &("M->" + cAliasFld + "_FIMAGD"), )

		cHoraIni := Transform(cHoraIni, PesqPict(cAliasFld, cAliasFld + "_INIAGD"))
		cHoraFim := Transform(cHoraFim, PesqPict(cAliasFld, cAliasFld + "_FIMAGD"))

		If ! Empty(dDatAgend)
			nHoraIni := DataHora2Str(dDatAgend, cHoraIni)
			nHorAtu  := DataHora2Str(dDatAgend, cHora)
			nHoraFim := DataHora2Str(dDatAgend, cHoraFim)
		EndIf

		Do Case
		Case Empty(dDatAgend)
			Help('',,"TMSA01810",, STR0033,1,0) // "Informe primeiramente a Data de Agendamento"
			lRet := .F.

		Case cCampo $ 'M->' + cAliasFld + '_DATAGD'

			If dDatAgend < dDatabase
				Help('',,"TMSA01807",, STR0030,1,0) // "Data de Agendamento menor que a data base"
				lRet := .F.
			EndIf

		Case cCampo $ 'M->' + cAliasFld + '_INIAGD'

			If 	nHoraIni < nHorAtu .And. dDatAgend <= dDatabase
				Help('',,"TMSA01808",, STR0031,1,0) // "Hora de Agendamento menor que a Hora atual"
				lRet := .F.
			EndIf

		Case cCampo $ 'M->' + cAliasFld + '_FIMAGD'

			If (nHoraFim <= nHoraIni) .Or. (nHoraFim <= nHorAtu .And. dDatAgend <= dDatabase)
				Help('',,"TMSA01809",, STR0032,1,0) // "Hora fim menor que a hora inicial / hora atual"
				lRet := .F.
			EndIf

		End Case
	EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} A018LdDTC()
Realiza o Load das informacoes da DTC e, no caso de Reent./Dev. carrega DTC
a partir da DY4

Uso: TMSA018

@sample
//A018LdDTC()

@author Ramon Prado
@since 06/08/2015
@version 1.0
-----------------------------------------------------------/*/
Function A018LdDTC(oMdlDTC,cFilDoc,cDoc,cSerie)
Local aAreaDTC	:= DTC->(GetArea())
Local aAreaDY4	:= DT6->(GetArea())
Local oStructDTC	:= oMdlDTC:GetStruct()
Local aCamposDTC	:= aClone(oStructDTC:GetFields())
Local aLoadDTC	:= {}
Local cAliasQry 	:= GetNextAlias()
Local cQuery    	:= ""
Local nLinha		:= 1
Local nY			:= 0

DbSelectArea("DY4")
DY4->(DbSetOrder(1)) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
If MsSeek(xFilial("DY4")+cFilDoc+cDoc+cSerie)
	cQuery := " SELECT DY4_NUMNFC T01_NUMNFC,DY4_SERNFC T01_SERNFC,DY4_CLIREM T01_CLIREM,DY4_LOJREM T01_LOJREM,DY4_FILORI T01_FILORI,DY4_LOTNFC T01_LOTNFC,DY4_CODPRO T01_CODPRO,DY4_QTDVOL T01_QTDVOL "
	cQuery += " FROM " + RetSqlName("DY4") + " DY4 "
	cQuery += " WHERE DY4_FILIAL = '" + xFilial("DY4") + "' "
	cQuery += " AND DY4_FILDOC = '" + cFilDoc + "' "
	cQuery += " AND DY4_DOC = '" + cDoc + "' "
	cQuery += " AND DY4_SERIE = '" + cSerie + "' "
	cQuery += " AND DY4.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)


	While (cAliasQry)->(!Eof())
		aAdd(aLoadDTC,{nLinha,Array(Len(aCamposDTC))})
		DbSelectArea("DTC")
		DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto
		If DTC->(MsSeek(xFilial("DTC")+(cAliasQry)->T01_NUMNFC+(cAliasQry)->T01_SERNFC+(cAliasQry)->T01_CLIREM+(cAliasQry)->T01_LOJREM+(cAliasQry)->T01_CODPRO+(cAliasQry)->T01_FILORI+(cAliasQry)->T01_LOTNFC))
			For nY := 1 To Len(aCamposDTC)
				If !aCamposDTC[nY][MODEL_FIELD_VIRTUAL]
					If aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_NUMNFC"
						aLoadDTC[nLinha][2][nY]	:= DTC->DTC_NUMNFC
					ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_SERNFC"
						aLoadDTC[nLinha][2][nY]	:= DTC->DTC_SERNFC
					ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_CODPRO"
						aLoadDTC[nLinha][2][nY]	:= DTC->DTC_CODPRO
					ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_CODEMB"
						aLoadDTC[nLinha][2][nY]	:= DTC->DTC_CODEMB
					ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_EMINFC"
						aLoadDTC[nLinha][2][nY]	:= DTC->DTC_EMINFC
					ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_QTDVOL"
						aLoadDTC[nLinha][2][nY]	:= DTC->DTC_QTDVOL
					ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_PESO"
						aLoadDTC[nLinha][2][nY]	:= DTC->DTC_PESO
					ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_PESOM3"
						aLoadDTC[nLinha][2][nY]	:= DTC->DTC_PESOM3
					ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_VALOR"
						aLoadDTC[nLinha][2][nY]	:= DTC->DTC_VALOR
					ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_METROM3"
						aLoadDTC[nLinha][2][nY]	:= DTC->DTC_METROM3
					Endif
				Else
					If aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_DESPRO"
						aLoadDTC[nLinha][2][nY]	:= Posicione("SB1",1,xFilial("SB1")+DTC->DTC_CODPRO,"B1_DESC")
					ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_DESEMB"
						aLoadDTC[nLinha][2][nY]	:= Tabela("MG",DTC->DTC_CODEMB,.F.)
					Endif
				Endif
			Next nY
			nLinha++
		Endif
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())
Else
	cQuery := " SELECT DTC_NUMNFC T01_NUMNFC,DTC_SERNFC T01_SERNFC,DTC_CODPRO T01_CODPRO,DTC_CODEMB T01_CODEMB,DTC_EMINFC T01_EMINFC,DTC_QTDVOL T01_QTDVOL,DTC_PESO T01_PESO,DTC_PESOM3 T01_PESOM3,DTC_VALOR T01_VALOR,DTC_METRO3 T01_METRO3 "
	cQuery += " FROM " + RetSqlName("DTC") + " DTC "
	cQuery += " WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
	cQuery += " AND DTC_FILDOC = '" + cFilDoc + "' "
	cQuery += " AND DTC_DOC = '" + cDoc + "' "
	cQuery += " AND DTC_SERIE = '" + cSerie + "' "
	cQuery += " AND DTC.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
	TcSetField(cAliasQry,"T01_EMINFC","D",8,0)

	While (cAliasQry)->(!Eof())
		aAdd(aLoadDTC,{nLinha,Array(Len(aCamposDTC))})
		For nY := 1 To Len(aCamposDTC)
			If !aCamposDTC[nY][MODEL_FIELD_VIRTUAL]
				If aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_NUMNFC"
					aLoadDTC[nLinha][2][nY]	:= (cAliasQry)->T01_NUMNFC
				ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_SERNFC"
					aLoadDTC[nLinha][2][nY]	:= (cAliasQry)->T01_SERNFC
				ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_CODPRO"
					aLoadDTC[nLinha][2][nY]	:= (cAliasQry)->T01_CODPRO
				ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_CODEMB"
					aLoadDTC[nLinha][2][nY]	:= (cAliasQry)->T01_CODEMB
				ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_EMINFC"
					aLoadDTC[nLinha][2][nY]	:= (cAliasQry)->T01_EMINFC
				ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_QTDVOL"
					aLoadDTC[nLinha][2][nY]	:= (cAliasQry)->T01_QTDVOL
				ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_PESO"
					aLoadDTC[nLinha][2][nY]	:= (cAliasQry)->T01_PESO
				ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_PESOM3"
					aLoadDTC[nLinha][2][nY]	:= (cAliasQry)->T01_PESOM3
				ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_VALOR"
					aLoadDTC[nLinha][2][nY]	:= (cAliasQry)->T01_VALOR
				ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_METROM3"
					aLoadDTC[nLinha][2][nY]	:= (cAliasQry)->T01_METROM3
				Endif
			Else
				If aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_DESPRO"
					aLoadDTC[nLinha][2][nY]	:= Posicione("SB1",1,xFilial("SB1")+(cAliasQry)->T01_CODPRO,"B1_DESC")
				ElseIf aCamposDTC[nY][MODEL_FIELD_IDFIELD] == "DTC_DESEMB"
					aLoadDTC[nLinha][2][nY]	:= Tabela("MG",(cAliasQry)->T01_CODEMB,.F.)
				Endif
			Endif
			*/
		Next nY
		nLinha++
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

Endif

If nLinha == 1
	Help('',1,'TMSA14602') // "Não foram encontrados Documentos para o critério de seleção"
EndIf

RestArea(aAreaDY4)
RestArea(aAreaDTC)
Return aLoadDTC


/*/{Protheus.doc}  gridDblDT6(oFormulario,cFieldName,nLineGrid,nLineModel,oView)
    (long_description)
    @type  Static Function
    @author Felipe Barbiere
    @since 27/06/2021
    @version 1.0
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function gdDblClick(oFormulario,cFieldName,nLineGrid,nLineModel,oView,cAlias)
Local cTxtMotivo := ""
If cFieldName $ "DYJ_MOTAGD" 
	cTxtMotivo := FwFldGet("DYJ_MOTAGD")
	TMSErrDtl(cTxtMotivo)
EndIf

Return