#INCLUDE "ATFA003.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

#DEFINE OPER_BLOQUEAR	10
#DEFINE OPER_REVISAR	11

Static __cCalcDep
Static __nOper 		:= 0 // Operacao da rotina

/*/
����������������������������������������������������������������������������?
�������������������������������������������������������������������������Ŀ�?
���Fun��o    ?ATFA003  ?Autor �Mauricio Pequim Jr.    ?Data ?09/12/11 ��?
�������������������������������������������������������������������������Ĵ�?
���Descricao ?Cadastro de Al�adas de aprova��o por opera��o              ��?
�������������������������������������������������������������������������Ĵ�?
��?Uso      ?SIGAATF                                                    ��?
�������������������������������������������������������������������������Ĵ�?
���Parametros?Nenhum                                                     ��?
��������������������������������������������������������������������������ٱ?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
/*/
Function ATFA003()
Local oBrowse
Private cCadastro := STR0001 //"Al�adas de aprova��o por opera��o"
__nOper := 0

ChkFile("FNH")
ChkFile("FNK")
ChkFile("FNL")
ChkFile("SN0")

dbSelectArea('FNK')
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'FNK' )
oBrowse:SetDescription( STR0001 )  //"Al�adas de aprova��o por opera��o"
oBrowse:AddLegend( "FNK_STATUS == '1'", "GREEN"		, STR0002  ) //"Habilitado"
oBrowse:AddLegend( "FNK_STATUS == '2'", "RED"  		, STR0003) //"Desabilitado"

oBrowse:Activate()

Return

/*
��������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������Ŀ�?
���Programa  �MenuDef   ?Autor ?Mauricio Pequim Jr.  ?Data ?0/09/11  ��?
�������������������������������������������������������������������������Ĵ�?
���Descri��o ?Utilizacao de menu Funcional                               ��?
�������������������������������������������������������������������������Ĵ�?
���Retorno   �Array com opcoes da rotina.                                 ��?
�������������������������������������������������������������������������Ĵ�?
���Parametros�Parametros do array a Rotina:                               ��?
��?         ?. Nome a aparecer no cabecalho                             ��?
��?         ?. Nome da Rotina associada                                 ��?
��?         ?. Reservado                                                ��?
��?         ?. Tipo de Transa��o a ser efetuada:                        ��?
��?         ?	1 - Pesquisa e Posiciona em um Banco de Dados         ��?
��?         ?   2 - Simplesmente Mostra os Campos                       ��?
��?         ?   3 - Inclui registros no Bancos de Dados                 ��?
��?         ?   4 - Altera o registro corrente                          ��?
��?         ?   5 - Remove o registro corrente do Banco de Dados        ��?
��?         ?. Nivel de acesso                                          ��?
��?         ?. Habilita Menu Funcional                                  ��?
�������������������������������������������������������������������������Ĵ�?
��?  DATA   ?Programador   �Manutencao efetuada                         ��?
�������������������������������������������������������������������������Ĵ�?
��?         ?              ?                                           ��?
��������������������������������������������������������������������������ٱ?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
/*/

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0014  	ACTION 'PesqBrw'            	OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina TITLE STR0015 	ACTION 'VIEWDEF.ATFA003'  		OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0016   	ACTION 'VIEWDEF.ATFA003' 		OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0017  	ACTION 'AFA003REV'    	  		OPERATION 2 ACCESS 0 //'Revisar'
ADD OPTION aRotina TITLE STR0018	ACTION 'AFA003BLQ' 		  		OPERATION 20 ACCESS 0 //'Bloqueio/Desbloq'
ADD OPTION aRotina TITLE STR0020	ACTION 'AFA003ATU' 		  		OPERATION 30 ACCESS 0 //"Atualiza Aprv."

Return aRotina



//������������������������������Ŀ
//�Rotinas de configura��o do MVC?
//��������������������������������

/*
����������������������������������������������������������������������������?
�������������������������������������������������������������������������Ŀ�?
���Fun��o    ?MODELDEF ?Autor �Mauricio Pequim Jr.    ?Data ?09/12/11 ��?
�������������������������������������������������������������������������Ĵ�?
���Descricao ?Fun��o que define o modelo do cadastro Al�adas de aprova��o��?
��?         ?por opera��o para o MVC                                    ��?
�������������������������������������������������������������������������Ĵ�?
��?Uso      ?ATFA003                                                    ��?
�������������������������������������������������������������������������Ĵ�?
���Parametros?Nenhum                                                     ��?
��������������������������������������������������������������������������ٱ?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
/*/
Static Function Modeldef()

Local oStruFNK 	:= AF003Struct('FNK')
Local oStruFNL 	:= AF003Struct('FNL')
Local oModel		:= Nil
Local aRelacFNL	:= {}

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'ATFA003', /*bPreValidacao*/, /*bPreValidacao*/ , /*bPosGrava*/ , /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields( 'FNKMASTER', /*cOwner*/, oStruFNK )

// Remove campos da estrutura para nao aparecer na grid
oStruFNL:RemoveField( 'FNL_FILIAL' )
oStruFNL:RemoveField( 'FNL_ROTINA' )
oStruFNL:RemoveField( 'FNL_REVIS' )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
oModel:AddGrid( 'FNLDETAIL'		, 'FNKMASTER'	, oStruFNL, /*bLinePre*/ , { |oModelGrid| FNLLINPOS(oModelGrid) }/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// N�o permite inserir linhas na grid
If __nOper == OPER_BLOQUEAR
	oModel:GetModel( 'FNLDETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FNLDETAIL' ):SetNoDeleteLine( .T. )
EndIf

//Relacionamento da tabela Etapa com Projeto
aAdd(aRelacFNL,{ 'FNL_FILIAL'	, 'xFilial( "FNL" )'	})
aAdd(aRelacFNL,{ 'FNL_ROTINA'	, 'FNK_ROTINA' 		})
aAdd(aRelacFNL,{ 'FNL_REVIS'	, 'FNK_REVIS' 			})

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'FNLDETAIL', aRelacFNL , FNL->( IndexKey( 1 ) )  )

//Deixa o prenchimento das tabelas opcional
//oModel:GetModel( 'FNLDETAIL' ):SetOptional( .T. )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'FNLDETAIL' ):SetUniqueLine( { 'FNL_OPER' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0006) //'Al�adas de aprova��o por opera��o'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FNKMASTER' ):SetDescription( STR0006 ) // //'Al�adas de aprova��o por opera��o'
oModel:GetModel( 'FNLDETAIL' ):SetDescription( STR0007) //'Itens da al�ada de aprova��o por opera��o'

oStruFNK:SetProperty("FNK_ROTINA",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, SX3Valid("FNK_ROTINA")+' .And. AF003ROT()' ))

Return oModel

/*/
����������������������������������������������������������������������������?
�������������������������������������������������������������������������Ŀ�?
���Fun��o    ?Viewdef  ?Autor �Mauricio Pequim Jr.    ?Data ?09/12/11 ��?
�������������������������������������������������������������������������Ĵ�?
���Descricao ?Fun��o que define a interface do cadastro Al�adas de       ��?
��?         ?aprova��o por opera��o para o MVC                          ��?
�������������������������������������������������������������������������Ĵ�?
��?Uso      ?ATFA003                                                    ��?
�������������������������������������������������������������������������Ĵ�?
���Parametros?Nenhum                                                     ��?
��������������������������������������������������������������������������ٱ?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
/*/
Static Function Viewdef()
// Cria a estrutura a ser usada na View
Local oStruFNK := FWFormStruct( 2, 'FNK' )
Local oStruFNL := FWFormStruct( 2, 'FNL' )
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'ATFA003' )
Local oView		:= Nil

// Remove campos da estrutura para nao aparecer na grid
oStruFNL:RemoveField( 'FNL_FILIAL' )
oStruFNL:RemoveField( 'FNL_ROTINA' )
oStruFNL:RemoveField( 'FNL_REVIS' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser?utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FNK', oStruFNK, 'FNKMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_FNL', oStruFNL, 'FNLDETAIL' )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR' , 20 )
oView:CreateHorizontalBox( 'INFERIOR' , 80 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FNK', 'SUPERIOR'     	)
oView:SetOwnerView( 'VIEW_FNL', 'INFERIOR' 	)

// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_FNK' )
oView:EnableTitleView( 'VIEW_FNL' )

Return oView


/*
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������ͻ�?
���Programa  �AF003Struct�Autor  �Mauricio Pequim Jr. ?Data ? 26/10/11  ��?
�������������������������������������������������������������������������͹�?
���Desc.     ?Retorna a estrutura do modelo com o tratamento das			 ��?
��?         ?operacoes                                                  ��?
�������������������������������������������������������������������������͹�?
���Uso       ?AP                                                         ��?
�������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
*/
Static Function AF003Struct(cAlias)
Local oStruct 	:= FWFormStruct( 1, cAlias, /*bAvalCampo*/, /*lViewUsado*/ )
Local aFields	:= {}
Local nX			:= 0
Local cPrefix	:= PrefixoCpo(cAlias)
Local cCampoBlq:= cPrefix+'_STATUS'

If __nOper == OPER_BLOQUEAR
	// Bloqueia todos os campos menos do bloqueio
	oStruct:SetProperty( '*' , MODEL_FIELD_WHEN , {|| .F. } )
	oStruct:SetProperty(cCampoBlq , MODEL_FIELD_WHEN , {|| .T. } )
ElseIf __nOper == OPER_REVISAR
	If cAlias == "FNK"
		oStruct:SetProperty("FNK_ROTINA" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FNK_STATUS" , MODEL_FIELD_WHEN , {|| .F. } )
	EndIf
EndIf
*/

//Cria��o de Gatilho
// [01] Id do campo de origem
// [02] Id do campo de destino
// [03] Bloco de codigo de valida��o da execu��o do gatilho
// [04] Bloco de codigo de execu��o do gatilho
If cAlias == "FNK"
	oStruct:AddTrigger( "FNK_ROTINA" , "FNK_ROTINA"	, {|| .T. }  , {|| AF003GTL("FNK_ROTINA","FNK_DESCRT") }  )
	oStruct:AddTrigger( "FNK_STATUS" , "FNK_STATUS"	, {|| .T. }  , {|| AF003GTL("FNK_STATUS","FNL_STATUS") }  )
ElseIf cAlias == "FNL"
	oStruct:AddTrigger( "FNL_OPER"	, "FNL_OPER"	, {|| .T. }  , {|| AF003GTL("FNL_OPER","FNL_DESCOP") }  )
	oStruct:AddTrigger( 'FNL_CODAPR' , 'FNL_CODAPR' , {|| .T. }  , {|| AF003GTL("FNL_CODAPR","FNL_NOMAPR") }  )
EndIf

Return oStruct



//
//revisao de alcada
//


/*
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������ͻ�?
���Programa  �AFA003REV �Autor  �Mauricio Pequim Jr. ?Data ? 24/10/11   ��?
�������������������������������������������������������������������������͹�?
���Desc.     ?Realiza a revis�o do projeto de imobilizado                ��?
��?         ?                                                           ��?
�������������������������������������������������������������������������͹�?
���Uso       ?AP                                                         ��?
�������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
*/
Function AFA003REV(cAlias,nReg,nOpc)

Local aArea         := GetArea()
Local lConfirma     := .F.
Local lCancela      := .F.
Local cTitulo       := ""
Local cPrograma     := ""
Local nOperation    := 0
Local cRotina       := FNK->FNK_ROTINA
Local cRev          := FNK->FNK_REVIS
Local lRet          := .T.


If lRet .And. FNK->FNK_STATUS == '2'
	Help(" ",1,"AF003BLOQ",,STR0008 ,1,0) //"N�o ?possivel revisar al�ada de aprova��o com esse status"
	lRet := .F.
EndIf

If lRet .and. FNL->(MsSeek(xFilial("FNL") + cRotina + cRev))

	nRecno		 := FNK->(RECNO())
	__nOper      := OPER_REVISAR
	cTitulo      := STR0006 //'Al�adas de Aprova��o por Opera��o'
	cPrograma    := 'ATFA003'
	nOperation   := MODEL_OPERATION_INSERT

	oModel       := FWLoadModel( cPrograma )
	oModel:SetOperation( nOperation ) // Inclus�o
	oModel:Activate(.T.) // Ativa o modelo com os dados posicionados

	nRet         := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
	oModel:DeActivate()
	__nOper      := 0

	If nRet == 0 //Confirmou
		AF003Flag(nRecno)
	Endif

EndIf

RestArea(aArea)
Return


//
//revisao de alcada
//


/*
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������ͻ�?
���Programa  �AFA003BLQ �Autor  �Mauricio Pequim Jr. ?Data ? 24/10/11   ��?
�������������������������������������������������������������������������͹�?
���Desc.     ?Realiza o Bloqueio da Alcada de aprovacao                  ��?
��?         ?                                                           ��?
�������������������������������������������������������������������������͹�?
���Uso       ?AP                                                         ��?
�������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
*/
Function AFA003BLQ(cAlias,nReg,nOpc)

Local aArea			:= GetArea()
Local lConfirma	:= .F.
Local lCancela		:= .F.
Local cTitulo		:= ""
Local cPrograma	:= ""
Local nOperation	:= 0
Local cRotina		:= FNK->FNK_ROTINA
Local cRev			:= FNK->FNK_REVIS
Local cStatus		:= FNK->FNK_STATUS
Local cNewRev		:= Soma1(cRev)
Local lRet			:= .T.
Local nRecFNK		:= FNK->(RECNO())

If FNK->(MsSeek(xFilial("FNK") + cRotina + cNewRev))
	Help(" ",1,"AF003REVS",,STR0009+CRLF+STR0010 ,1,0) //"Existe revis�o posterior para esta al�ada de aprova��o"###"N�o ?possivel bloquear/desbloquear al�ada de aprova��o neste caso"
	lRet := .F.
Else
	FNK->(dbGoto(nRecFNK))
EndIf

If lRet .and. FNL->(MsSeek(xFilial("FNL") + cRotina + cRev))

	__nOper      := OPER_BLOQUEAR
	cTitulo      := STR0011 //'Al�adas de Aprova��o por Opera��o - Bloqueio/Desbloqueio'
	cPrograma    := 'ATFA003'
	nOperation   := MODEL_OPERATION_UPDATE

	nRet         := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,{ |oModel| AF003VLBLQ(oModel) } , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/ )

	__nOper      := 0

EndIf

RestArea(aArea)

Return


/*
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������ͻ�?
���Programa  �AF003FLAG �Autor  �Mauricio Pequim Jr. ?Data ? 10/26/11   ��?
�������������������������������������������������������������������������͹�?
���Desc.     ?Altera os campos flags do projeto                            ��?
��?         ?                                                           ��?
�������������������������������������������������������������������������͹�?
���Uso       ?AP                                                        ��?
�������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
*/
Static Function AF003FLAG(nRecno,lBloq)
Local aArea		:= GetArea()

DEFAULT nRecno := 0
DEFAULT lBloq	:= .F.

FNK->(dbSetOrder(1)) //FNK_FILIAL+FNK_ROTINA+FNK_REVIS
FNL->(dbSetOrder(1)) //FNL_FILIAL+FNL_ROTINA+FNL_REVIS+FNL_OPER+FNL_CODAPR

FNK->(DBGOTO(nRecno))

If FNL->( MsSeek( xFilial("FNL") + FNK->(FNK_ROTINA+FNK_REVIS) ) )

	BEGIN TRANSACTION

	//Desabilita o cabecalho (FNK)
	//Se lBloq = .F. - chamada da revisao de alcada
	//Se lBloq = .T. - Chamada da bloqueio de alcada
	RecLock("FNK",.F.)
	If !lBloq
		FNK->FNK_STATUS := '2'
	Endif
	MsUnLock()

	//Desabilita os detalhes (FNL)
	dbselectArea('FNL')
	cKey := xFilial("FNL") + FNL->(FNL_ROTINA+FNL_REVIS)

	While FNL->(!Eof()) .and. cKey == FNL->(FNL->FNL_FILIAL+FNL_ROTINA+FNL_REVIS)
		RecLock("FNL",.F.)
		FNL->FNL_STATUS := FNK->FNK_STATUS
		MsUnLock()
		FNL->(DBSKIP())
	Enddo

	END TRANSACTION

EndIf

RestArea(aArea)

Return


/*
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������ͻ�?
���Programa  �AF003INREV�Autor  �Mauricio Pequim Jr. ?Data ? 24/10/11   ��?
�������������������������������������������������������������������������͹�?
���Desc.     �Retorna a revis�o do projeto conforme opera��o              ��?
��?         ?                                                           ��?
�������������������������������������������������������������������������͹�?
���Uso       ?AP                                                         ��?
�������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
*/
Function AF003INREV()
Local cRevisao 	:= STRZERO(1,TamSx3("FNK_REVIS")[1] )
Local aArea			:= GetArea()
Local aAreaFNK		:= FNK->(GetArea())
Local cRotina		:= ""

FNK->(dbSetOrder(1)) //FNK_FILIAL+FNK_ROTINA+FNK_REVIS

If __nOper == OPER_REVISAR
	cRotina		:= FNK->FNK_ROTINA
	If FNK->(MsSeek(xFilial("FNK") + cRotina ))
		While FNK->(!EOF()) .And.  FNK->(FNK_FILIAL+FNK_ROTINA) == xFilial("FNK") + cRotina
			cRevisao := FNK->FNK_REVIS
			FNK->(dbSkip())
		EndDo
		cRevisao := Soma1(cRevisao)
	EndIf
EndIf

RestArea(aAreaFNK)
RestArea(aArea)
Return cRevisao

/*
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������ͻ�?
���Programa  �AF003INROT�Autor  �Mauricio Pequim Jr  ?Data ? 13/12/11   ��?
�������������������������������������������������������������������������͹�?
���Desc.     �Retorna o c�digo da rotina caso seja uma operacao de revisao��?
�������������������������������������������������������������������������͹�?
���Uso       ?AP                                                         ��?
�������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
*/
Function AF003INROT()

Local cRotina		:= ""

If __nOper == OPER_REVISAR
	cRotina		:= FNK->FNK_ROTINA
EndIf

Return cRotina


/*
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������ͻ�?
���Programa  �AF003INIC �Autor  �Mauricio Pequim Jr  ?Data ? 13/12/11   ��?
�������������������������������������������������������������������������͹�?
���Desc.     ?Inicializador padrao p/ os campos FNK_DESCROT e FNL_DESCOP ��?
��?         ?                                                           ��?
�������������������������������������������������������������������������͹�?
���Uso       ?AP                                                         ��?
�������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
*/
Function AF003INIC(cCampo)

Local oModel   	:= FWModelActive()
Local oModelFNL	:= oModel:GetModel("FNLDETAIL")
Local cRet := ""

DEFAULT cCampo := '0'

If !INCLUI .or. (__nOper == OPER_REVISAR .And. oModelFNL:nLine==0)

	If cCampo == '1' //FNK_DESCROT
		cRet := Posicione("SN0",1,xFilial("SN0")+"20"+FNK->FNK_ROTINA ,'SUBSTR(N0_DESC01,1,20)')
	ElseIf cCampo == '2' //FNL_DESCOP
		cRet := Posicione("SN0",1,xFilial("SN0")+"21"+FNL->FNL_OPER,"SUBSTR(N0_DESC01,1,20)")
	Endif

Endif

Return cRet


/*/
����������������������������������������������������������������������������?
�������������������������������������������������������������������������Ŀ�?
���Fun��o    ?AF003GTL ?Autor �Mauricio Pequim Jr     ?Data ?30/09/11 ��?
�������������������������������������������������������������������������Ĵ�?
���Descricao ?Gatilho para atualizacao dos campos          				  ��?
�������������������������������������������������������������������������Ĵ�?
��?Uso      ?SIGAATF                                                    ��?
�������������������������������������������������������������������������Ĵ�?
���Parametros?Nenhum                                                     ��?
��������������������������������������������������������������������������ٱ?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
/*/
Function AF003GTL(cCampoOri,cCampoAtu)

Local oModel   := FWModelActive()
Local oModelFNK:= oModel:GetModel("FNKMASTER")
Local oModelFNL:= oModel:GetModel("FNLDETAIL")
Local cResult	:= ""
Local cDescr	:= ""

SN0->(dbSetOrder(1))

If cCampoOri == "FNK_ROTINA"
	cResult:= oModel:GetValue("FNKMASTER","FNK_ROTINA")

	If SN0->(MsSeek(xFilial('SN0')+'20'+cResult))
		cDescr := SUBSTR(SN0->N0_DESC01,1,20)
	Endif
	oModelFNK:LoadValue( cCampoAtu , cDescr )

ElseIf cCampoOri == "FNL_OPER"
	cResult:= oModel:GetValue("FNLDETAIL","FNL_OPER")
	If SN0->(MsSeek(xFilial('SN0')+'21'+cResult))
		cDescr := SUBSTR(SN0->N0_DESC01,1,20)
	Endif
	oModelFNL:LoadValue( cCampoAtu , cDescr )

ElseIf cCampoOri == "FNL_CODAPR"
	cResult:= oModel:GetValue("FNLDETAIL","FNL_CODAPR")
	cDescr := UsrRetName(cResult)

	oModelFNL:LoadValue( cCampoAtu , cDescr )
ElseIf cCampoOri == "FNK_STATUS"
	cResult:= oModel:GetValue("FNKMASTER","FNK_STATUS")
	AF003STAT(oModel,cResult)
Endif

Return cResult


/*/
����������������������������������������������������������������������������?
�������������������������������������������������������������������������Ŀ�?
���Fun��o    ?AF003GNAP?Autor �Mauricio Pequim Jr     ?Data ?30/09/11 ��?
�������������������������������������������������������������������������Ĵ�?
���Descricao ?inicializador padrao do campo FNL_NOMAPR         			  ��?
�������������������������������������������������������������������������Ĵ�?
��?Uso      ?SIGAATF                                                    ��?
�������������������������������������������������������������������������Ĵ�?
���Parametros?Nenhum                                                     ��?
��������������������������������������������������������������������������ٱ?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
/*/
Function AF003GNAP()

Local oModel   	:= FWModelActive()
Local oModelFNL	:= oModel:GetModel("FNLDETAIL")
Local cDescr	:= ""

If !INCLUI .or. (__nOper == OPER_REVISAR .And. oModelFNL:nLine==0)
	cDescr := UsrRetName(FNL->FNL_CODAPR)
Endif

Return cDescr



/*
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������ͻ�?
���Programa  �A003Stat  �Autor �Alvaro Camillo Neto ?Data ? 05/12/11   ��?
�������������������������������������������������������������������������͹�?
���Desc.     ?Realiza todas as pos-valida��es de linha do modelo na      ��?
��?         ? p�s valida��o da rotina                                   ��?
�������������������������������������������������������������������������͹�?
���Uso       ?AP                                                         ��?
�������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
*/
Static Function AF003Stat(oModel,cStatus)
Local lRet			:= .T.
Local oModelFNL	:= oModel:GetModel("FNLDETAIL")
Local aSaveLines	:= FWSaveRows()
Local nX				:= 0

// N�o permite inserir linhas na grid
If __nOper == OPER_BLOQUEAR

	For nX := 1 To oModelFNL:Length()
		oModelFNL:GoLine( nX )
		oModelFNL:LoadValue( "FNL_STATUS" , cStatus )
	Next nX

Endif

FWRestRows(aSaveLines)

Return lRet

/*
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������ͻ�?
���Programa  �AF003VLBLQ�Autor  �Mauricio Pequim Jr  ?Data ? 13/12/11   ��?
�������������������������������������������������������������������������͹�?
���Desc.     ?Realiza todas as pre-valida��es de linha do grid permitindo��?
��?         ? ou nao a edicao da linha                                  ��?
�������������������������������������������������������������������������͹�?
���Uso       ?AP                                                         ��?
�������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
*/
Function AF003VLBLQ(oModel)

Local oModelFNL	:= oModel:GetModel("FNLDETAIL")
Local cFlagFNK		:= ""
Local cFlagFNL		:= ""
Local cOper			:= ""
Local lRet			:= .T.
Local aSaveLines  := FWSaveRows()
Local nX		  		:= 0

cFlagFNK := oModel:GetValue("FNKMASTER","FNK_STATUS")

If cFlagFNK == '2' //Desabilitado

	For nX := 1 To oModelFNL:Length()
		oModelFNL:GoLine( nX )
		If !oModelFNL:IsDeleted()
			cFlagFNL := oModel:GetValue("FNLDETAIL","FNL_STATUS")
			If cFlagFNK != cFlagFNL
				cOper := oModel:GetValue("FNLDETAIL","FNL_OPER")
				Help(" ",1,"AF003STATUS",,STR0012+CRLF+STR0013+ cOper ,1,0) //"Status da rotina e da opera��o est�o divergentes."###"Verifique status da operacao "
				lRet := .F.
			Endif
   	Endif

		If !lRet
			Exit
		EndIf
	Next

EndIf

FWRestRows(aSaveLines)

Return lRet


/*
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������ͻ�?
���Programa  �AF003BLQV �Autor  �Mauricio Pequim Jr  ?Data ? 13/12/11   ��?
�������������������������������������������������������������������������͹�?
���Desc.     ?Realiza todas as pre-valida��es de linha do grid permitindo��?
��?         ? ou nao a edicao da linha                                  ��?
�������������������������������������������������������������������������͹�?
���Uso       ?AP                                                         ��?
�������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
*/
Function AF003BLQV()

Local oModel   	:= FWModelActive()
Local cPeriodo		:= ""
Local lRet			:= .F.

cPeriodo := oModel:GetValue("FNLDETAIL","FNL_PERIOD")

IF cPeriodo != '0'
	lRet := .T.
Endif

Return lRet



/*
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������ͻ�?
���Programa  �AFA003ATU �Autor  �Mauricio Pequim Jr. ?Data ? 24/10/11   ��?
�������������������������������������������������������������������������͹�?
���Desc.     ?Realiza a atualizacao dos aprovadores nas tarefas de       ��?
��?         ?aprovacao                                                  ��?
�������������������������������������������������������������������������͹�?
���Uso       ?AP                                                         ��?
�������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
*/
Function AFA003ATU(cAlias,nReg,nOpc)

Local aArea         := GetArea()
Local cRotina       := FNK->FNK_ROTINA
Local cRev          := FNK->FNK_REVIS
Local lRet          := .T.
Local cAliasQry 	:= GetNextAlias()

If lRet .And. FNK->FNK_STATUS == '2'
	Help(" ",1,"AF003ATU1",,STR0023 ,1,0) //"Este controle de al�ada est?bloqueado. Utilize uma revisao ativa para realizar a atualiza��o de aprovadores."
	lRet := .F.
EndIf

FNL->(dbSetOrder(1))
If lRet .and. FNL->(MsSeek(xFilial("FNL") + cRotina + cRev))

	nRecno		 := FNK->(RECNO())

	lAtualiza := MSGYESNO(STR0021,STR0022) //"Deseja realmente atualizar as tarefas de aprova��o deste processo com os aprovadores atuais?"###"Aten��o"


	If lAtualiza //Confirmou

		cQuery := "SELECT FNL_CODAPR, FNM.R_E_C_N_O_ RECNOFNM FROM " + RetSQLTab('FNM')
		cQuery +=  " INNER JOIN "+ RetSQLTab('FNL')+" ON "
		cQuery +=    " FNM_ROTINA = FNL_ROTINA AND "
		cQuery +=    " FNM_OPER = FNL_OPER "
		cQuery +=  " WHERE "
		cQuery += 	 " FNM_STATUS = '1' AND "
		cQuery += 	 " FNM_CODAPR <> FNL_CODAPR AND "
		cQuery +=    " FNL_STATUS <> '2' AND "
		cQuery += RetSqlCond("FNL") + " AND "
		cQuery += RetSqlCond("FNM")

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

		dbSelectArea(cAliasQry)

		DbGotop()
		If !EOF() .AND. !BOF()

			BEGIN TRANSACTION

			While !(cAliasQry)->(Eof())

				FNM->(DBGOTO((cAliasQry)->RECNOFNM))

				RecLock("FNM")
				FNM->FNM_CODAPR := (cAliasQry)->FNL_CODAPR
				FNM->(MsUnlock())

				(cAliasQry)->(dbskip())
	        Enddo

			END TRANSACTION

		Endif
		(cAliasQry)->(DbCloseArea())

	Endif

EndIf

RestArea(aArea)

Return


/*
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������ͻ�?
���Programa  �Af003ROT      �Autor�Jose Domingos Caldana Jr �Data?6/10/12��?
�������������������������������������������������������������������������͹�?
���Descri�ao �Verifica se j?existe conteudo na Grid                      ��?
�������������������������������������������������������������������������Ĺ�?
���Retorno   �[L] - .T. Se nao existir conteudo na Grid                   ��?
�������������������������������������������������������������������������Ĺ�?
���Parametros?                                                           ��?
�������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
*/
Function Af003ROT()

Local oModel   		:= FWModelActive()
Local oModelFNL		:= oModel:GetModel("FNLDETAIL")
Local nx
Local lRet 			:= .T.

For nX := 1 To oModelFNL:Length()
	oModelFNL:GoLine( nX )
	If !Empty(oModel:GetValue("FNLDETAIL","FNL_OPER")) .And. !oModelFNL:IsDeleted()
		lRet := .F.
		Help(" ",1,"AF003ROT",,STR0024 ,1,0) //"N�o ?possivel alterar a rotina, pois j?existe opera��o informada."
		Exit
	EndIf
Next nX

Return lRet


/*
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������ͻ�?
���Programa  �SX3Valid      �Autor�Jose Domingos Caldana Jr �Data?6/10/12��?
�������������������������������������������������������������������������͹�?
���Descri�ao �Recupera validacao de Campo do dicion�rio de dados (SX3)    ��?
�������������������������������������������������������������������������Ĺ�?
���Retorno   �[C] - Express�o de Valida��o do campo                       ��?
�������������������������������������������������������������������������Ĺ�?
���Parametros�[C] - Codigo do Campo                                       ��?
�������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
*/

Static Function SX3Valid(cCampo)

Local aArea 	:= GetArea()
Local aAreaSX3
Local cValid	:= ""

If ValType(cCampo) == "C"

	aAreaSX3 	:= SX3->(GetArea())

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek(cCampo))
		cValid := IIf(!Empty(SX3->X3_VALID),Alltrim(SX3->X3_VALID),"")
		cValid += IIf(!Empty(SX3->X3_VALID).And.!Empty(SX3->X3_VLDUSER)," .And. ","")
		cValid += IIf(!Empty(SX3->X3_VLDUSER),Alltrim(SX3->X3_VLDUSER),"")
	EndIf

	RestArea(aAreaSX3)

EndIf

If Empty(cValid)
	cValid := ".T."
Endif

RestArea(aArea)

Return cValid


/*
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������ͻ�?
���Programa  �FNLLINPOS     �Autor�Jose Domingos Caldana Jr �Data?6/10/12��?
�������������������������������������������������������������������������͹�?
���Descri�ao �Valida se Chave ja foi cadastrada                           ��?
�������������������������������������������������������������������������Ĺ�?
���Retorno   �[L] - .T. Se Rotina+Operacao nao existir                    ��?
�������������������������������������������������������������������������Ĺ�?
���Parametros�[O] - Modelos da Grid - Tabela FNL                          ��?
�������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
*/

Static Function FNLLINPOS(oModelFNL)
Local lRet 			:= .T.
Local oModel   		:= FWModelActive()
Local cRotina		:= oModel:GetValue("FNKMASTER","FNK_ROTINA")
Local cOper			:= oModelFNL:GetValue("FNL_OPER")

If !oModelFNL:IsDeleted()
	lRet :=  ExistCpo("FNH",cRotina+cOper)
EndIf

Return lRet


//Master