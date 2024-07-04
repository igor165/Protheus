#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ATFA036.CH"

#DEFINE OPER_VISUA		1 //Visualiza
#DEFINE OPER_BAIXA		2 //Baixa Normal
#DEFINE OPER_BXLOT		3 //Baixa em Lote
#DEFINE OPER_CANC		4 //Cancelar Normal
#DEFINE OPER_CANCM		5 //Cancelar Multiplas
#DEFINE OPER_CANLT		6 //Cancelar em lote


Static __nOper		:= 0 // Operacao da rotina
Static lCalcula
Static nParCorrec	:= 0
Static aRecCtb		:= {}
Static lBxProvis	:= .F.
Static lValidaNFD	:= SuperGetMV("MV_AF30NDV", .F., .F.)
Static __oModelAut	:= Nil
Static __lRotAuto	:= .F.
STATIC lIsRussia	:= cPaisLoc == "RUS" // CAZARINI - Flag to indicate If is Russia location
STATIC lAtf030		:= .F.
STATIC lVisMotBx    := .F.
STATIC lGerPVBra	:= SuperGetMV("MV_ATFGRPV",.F.,.F.) .And. cPaisLoc == "BRA"
Static lExisCPC31	:= Nil
Static __nParam04   := NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} ATFA036

Rotina de Baixa de Ativos

@author felipe.cunha
@since 14/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function ATFA036(xCab,xAtivo,xOpcAuto,xParLot,lBaixaTodos,aParam, lAutLot)

Local oBrowse		:= Nil
Local lRet			:= .T.
Local cMoedaAtf		:= SuperGetMv("MV_ATFMOED")

Private aParamAuto	:= {}
Private cCadastro 	:= STR0001 //"Baixa de Ativos" - Variavel utilizado no MATA360
Private nNumDocNF	:= "" //Variable utilizada para almacenar Numero de Documento (Uso ATFA036MEX)
Private lExisCpo	:= .F.
Private nVlCor		:= 0  // Variavel utilizada para Bolivia 
Private nVlCorDep 	:= 0 //Variavel utilizada para Bolivia
Private cEspecie	:= "NF " // Necesaria para la consulta estándar COL017

DEFAULT xCab		:= Nil
DEFAULT xAtivo		:= Nil
DEFAULT xOpcAuto	:= Nil
DEFAULT xParLot		:= Nil
DEFAULT lBaixaTodos := .T.
Default aParam		:= {}
Default lAutLot		:= .F.


dbSelectArea("FN8")
dbSelectArea("FN7")
dbSelectArea("FN6")
dbSelectArea("SN3")

lExisCpo := IIf(cPaisLoc $ "PER|COL", ATF036ValC(), .F.)

If !AtfVldMoed(cMoedaAtf)
	lRet := .F.
	Help(" ",1,"ATFVLDMOED",,STR0170,1,0)//"Parametro MV_ATFMOED configurado incorretamente"
EndIf

/*
 * Carrega Pergunta Baixa de Ativo
 */

If lRet
	aParamAuto := If(aParam <> Nil,aParam,Nil)
	Pergunte("AFA036",.F.)
	AF036PerAt()
	__lRotAuto		:= .F.
	__nParam04  := If(__nParam04 == NIL, mv_par04, __nParam04)

	If (xCab <> Nil .And. xOpcAuto <> Nil) .Or. (xOpcAuto <> Nil .And. xParLot <> Nil)
		__lRotAuto := .T.
	EndIf

	If !__lRotAuto
		SetKey( VK_F12, { || Pergunte("AFA036",.T.) })

		oBrowse	:= BrowseDef()
		oBrowse:Activate()
	Else
		AF036AutRt(xCab,xAtivo,xOpcAuto,lBaixaTodos,lAutLot )
	EndIf
	__nParam04  := NIL
EndIf

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef()

Browse definition

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function BrowseDef()
Local nVisualiza	AS NUMERIC
Local cFilter		AS CHARACTER
Local lAF036BRW		AS LOGICAL
Local oBrowse		AS OBJECT

lAF036BRW	:= ExistBlock("AF036BRW")

Pergunte("AFA036",.F.)
AF036PerAt()

nVisualiza		:= MV_PAR04
IF lAF036BRW
	cFilter	:= ExecBlock( "AF036BRW", .F., .F. )
	cFilter	:= If(ValType(cFilter) == "C", cFilter, Nil )
EndIf

oBrowse		:= FWmBrowse():New()

If nVisualiza == 2
	oBrowse:SetAlias( 'SN3' )
	/*
	* Define Legenda da Browse de Bens da Baixa de Ativo
	*/
	oBrowse:AddLegend( "N3_BAIXA == '0' .AND. !AfxLegTran()"							,"GREEN"	,STR0002) // "Ativo Fixo Vigente"
	oBrowse:AddLegend( "N3_BAIXA > '0' .And. !Empty(N3_DTBAIXA) .AND. !AfxLegTran()"		,"RED"	,STR0003) // "Ativo Fixo Baixado"
	oBrowse:AddLegend( "AfxLegTran()"												,"PINK"	,STR0004) // "Ativo Transferido de Filial"
ElseIf nVisualiza == 1
	oBrowse:SetAlias( 'FN6' )
	/*
	* Define Legenda da Browse de Bens da Baixa de Ativo
	*/
	oBrowse:AddLegend( "FN6_STATUS == '1'"		, "GREEN"	, STR0092	) // "Baixa Ativa"
	oBrowse:AddLegend( "FN6_STATUS == '2'"		, "RED"		, STR0093	) // "Baixa Cancelada"
ElseIf nVisualiza == 3
	oBrowse:SetAlias( 'SN1' )
	//Define Legenda da Browse de Ativos
	oBrowse:AddLegend("!A036SN1TBx() .And. N1_STATUS != '4'","GREEN"	,STR0140	) //"Ativo Dísponivel"
	oBrowse:AddLegend("!EMPTY(N1_BAIXA) .And. N1_STATUS != '4'"	,"RED"	,STR0141	) //"Ativo Baixado"
	oBrowse:AddLegend("N1_STATUS == '4'"						,"PINK"	,STR0142	) //"Ativo Transferido de Filial"
EndIf

/*
 * Define a Descrição do Browse
 */
oBrowse:SetDescription( cCadastro )	//Baixa de Ativos

/*
 * Ativa o Browse
 */
If cFilter <> Nil
	oBrowse:SetFilterDefault(cFilter)
EndIf

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Definição de Menu da Rotina de Baixa de Ativos

@author felipe.cunha
@since 14/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0006	ACTION 'AT36Baixa()'		OPERATION 3 ACCESS 0	// "Baixar"
ADD OPTION aRotina TITLE STR0029	ACTION 'AF036BxLote()'		OPERATION 3 ACCESS 0	// "Baixa em Lote"
ADD OPTION aRotina TITLE STR0027	ACTION 'AT36Cance()'		OPERATION 8 ACCESS 0	// "Cancelar"
ADD OPTION aRotina TITLE STR0028	ACTION 'AT36CancMt()'		OPERATION 9 ACCESS 0	// "Cancelar(Multi)"
ADD OPTION aRotina TITLE STR0030	ACTION 'AF036CancL()'		OPERATION 3 ACCESS 0	// "Cancelar em Lote" 
If cPaisLoc <> "RUS"
	ADD OPTION aRotina TITLE STR0094	ACTION 'CTBC662'			OPERATION 5 ACCESS 0	// "Tracker Contábil"
EndIf
ADD OPTION aRotina TITLE STR0005	ACTION 'AT36Visual("1")'	OPERATION 2 ACCESS 0	// "Visualizar"
ADD OPTION aRotina TITLE STR0118	ACTION 'AT36Visual("2")'	OPERATION 2 ACCESS 0	// "Visualizar Ativo"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definição do Modelo de Dados u da Rotina de Baixa de Ativos

@author felipe.cunha
@since 08/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel		:= Nil

/*
 * Cria o objeto do Modelo de Dados
 */ 
Local oStrCab		:= AF036StFN6("FN6")	// Master FN6
Local oStrTip		:= AF036StTip("FN7")	// Tipos
Local oStrSld		:= AF036StVal()			// Valor
Local oStrVlAcum	:= AT36StVlAc()			// Valores Acumulados

//Criação do Modelo de Dados
oModel := MPFormModel():New('ATFA036', /*bPreValidacao*/, { |oModel| AF036Pos(oModel) }/*bPosValidacao*/,  { |oModel| AF036GRV( oModel ) }/*bGravacao*/ , /*bCancel*/ )

//Atribui os valores para carga do campo - FN6MASTER
oModel:AddFields('FN6MASTER',/*cOwner*/,oStrCab,/*bPreVld*/,/*bPostVld*/,{ || AF036Load(oModel)})

oModel:AddGrid('FN7TIPO'	,'FN6MASTER'	,oStrTip		,,,,, {|oModel|AF036LOADT( oModel ) } )
// Modelo de apoio da rotina
oModel:AddGrid('VLRACUM'	,'FN6MASTER'	,oStrVlAcum	,,,,, {|| {}})
oModel:AddGrid('FN7VALOR','FN7TIPO'  	,oStrSld		,,,,, {|oModel|AF036LOADV( oModel ) } )

//Adicional campo OK para controle da operação
bValid := FWBuildFeature(STRUCT_FEATURE_VALID,"AF036MARK()")
oStrTip:AddField(STR0007,STR0008 , 'OK', 'L', 1, 0, bValid 		, , {}	, .F.	, , .F., .F., .F., , )//'Baixa?'#//'Seleção'

//Descrição
oModel:SetDescription(STR0001) // "Baixa de Ativos"
oModel:GetModel('FN6MASTER'):SetDescription( STR0031 )	//'Cabeçalho da Baixa do Ativo'
oModel:GetModel('FN7TIPO'  ):SetDescription( STR0032 )	//'Tipos de Ativos' 
oModel:GetModel('FN7VALOR' ):SetDescription( STR0033 )	//'Valor de Baixa'
oModel:GetModel('VLRACUM' ):SetDescription( STR0034 )	//'Cálculo de Valores Acumulados do Ativo'

//Validação do Modelo de Dados para Ativação do Mesmo
oModel:SetVldActivate( {|oModel| AF036Vld(oModel , , SN3->N3_CBASE, SN3->N3_ITEM ) .AND. AT36VlAct(oModel) } )

//Desabilita a Gravação automatica dos Model FN6MASTER / FN7TIPO / FN7VALOR
oModel:GetModel( 'FN6MASTER'):SetOnlyQuery ( .T. )
oModel:GetModel( 'FN7TIPO'	):SetOnlyQuery ( .T. )
oModel:GetModel( 'FN7VALOR'	):SetOnlyQuery ( .T. )
oModel:GetModel( 'VLRACUM'	):SetOnlyQuery ( .T. )
oModel:GetModel( 'VLRACUM' ):SetOptional( .T. )

oModel:SetRelation('FN6MASTER',{{'FN6_FILIAL','FN7_FILIAL'},{'FN6_CODBX','FN7_CODBX'}}, FN7->(IndexKey(1)) )
oModel:SetRelation('FN7VALOR',{{'FN6_FILIAL','FN7_FILIAL'},{'FN6_FILORI','FN7_FILORI'},{'FN6_CBASE','FN7_CBASE'},{'FN6_CITEM','FN7_CITEM'},{'FN7_TIPO','FN7_TIPO'},{'FN7_TPSALD','FN7_TPSALD'}}, FN7->(IndexKey(2)) )
oModel:SetPrimarykey({'FN6_FILIAL','FN6_CODBX'})

oModel:SetActivate( {|oModel| AT36Activ(oModel) } )

Pergunte("AFA036",.F.)
AF036PerAt()

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definição da Interface da Rotina de Baixa de Ativos

@author felipe.cunha
@since 09/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
/*
 * Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
 */
Local oModel	:= FWLoadModel( 'ATFA036' )
Local oView		:= Nil

/*
 * Cria a estrutura de dados que será utilizada na View
 */
Local oStrFN6		:= FWFormStruct(2, 'FN6' )	//Cadastro
Local oStrTipos		:= FWFormStruct(2, 'FN7' )	//Tipos
Local oStrSaldos	:= FWFormStruct(2, 'FN7' )	//Saldos
Local cTituloFN6	:= ""
Local cMotivoFN6	:= ""
Local aAreaSX3		:= {}

/*
 * Cria o objeto de View
 */
oView := FWFormView():New()

/*
 * Define qual o Modelo de dados será utilizado
 */
oView:SetModel(oModel)

oView:AddField('FORM_ATIVO'	,oStrFN6	,'FN6MASTER') //Cabeçalho
oView:AddGrid('GRID_TIPOS'	,oStrTipos	,'FN7TIPO'	) //Tipos de Ativo
If cPaisLoc <> "RUS"
	oView:AddGrid('GRID_SALDOS'	,oStrSaldos	,'FN7VALOR'	) //Saldos de Ativo
EndIf

/*
 * Remove Campos não Usados - Cabeçalho da Baixa do Ativo
 */
oStrFN6:RemoveField( 'FN6_FILIAL' )
oStrFN6:RemoveField( 'FN6_FILORI' )

If lVisMotBx	

	aAreaSX3 := SX3->(GetArea())

	SX3->(dbSetOrder(2))
	If SX3->(dbSeek("FN6_MOTIVO"))
		cTituloFN6 := X3TITULO()
	EndIf

	oStrFN6:RemoveField('FN6_MOTIVO')

	cMotivoFN6 := FN6->FN6_MOTIVO+"="+AllTrim(POSICIONE("SX5",1,xFilial("SX5")+"16"+FN6->FN6_MOTIVO,"X5_DESCRI"))

	oStrFN6:AddField(	'FN6MOTIVO'             , ;  // [01]  C   Nome do Campo 
						'11'                    , ;  // [02]  C   Ordem 
						cTituloFN6  			, ;  // [03]  C   Titulo do campo 
						cTituloFN6  			, ;  // [04]  C   Descrição do campo 
						Nil 					, ;  // [05]  A   Array com Help 
						'C'                     , ;  // [06]  C   Tipo do campo 
						'@!'                    , ;  // [07]  C   Picture 
						Nil                     , ;  // [08]  B   Bloco de Picture Var 
						''                      , ;  // [09]  C   Consulta F3 
						.T.                     , ;  // [10]  L   Indica se o campo é editável 
						"1"                     , ;  // [11]  C   Pasta do campo 
						Nil                     , ;  // [12]  C   Agrupamento do campo 
						{cMotivoFN6}  		    , ;  // [13]  A   Lista de valores permitido do campo (Combo)  
						Nil                     , ;  // [14]  N   Tamanho Maximo da maior opção do combo 
						Nil                     , ;  // [15]  C   Inicializador de Browse 
						.T.                     , ;  // [16]  L   Indica se o campo é virtual 
						Nil                     )    // [17]  C   Picture Variável
	RestArea(aAreaSX3)

EndIf

If lIsRussia
	oStrFN6:RemoveField("FN6_NUMNF")
	oStrFN6:RemoveField("FN6_ITEMNF")
EndIf

/*
 * Remove Campos não Usados - Tipos de Ativos
 */
oStrTipos:RemoveField( 'FN7_MOTIVO' )
oStrTipos:RemoveField( 'FN7_SEQREA' )
oStrTipos:RemoveField( 'FN7_SEQ'    )
oStrTipos:RemoveField( 'FN7_CITEM'  )
oStrTipos:RemoveField( 'FN7_CBASE'  )
oStrTipos:RemoveField( 'FN7_ITEM'   )
oStrTipos:RemoveField( 'FN7_CODBX'  )
oStrTipos:RemoveField( 'FN7_MOEDA'  )
oStrTipos:RemoveField( 'FN7_FILORI' )
oStrTipos:RemoveField( 'FN7_STATUS' )
If cPaisLoc <> "RUS"
	oStrTipos:RemoveField( 'FN7_PERCBX' )
	oStrTipos:RemoveField( 'FN7_VLBAIX' )
EndIf
oStrTipos:RemoveField( 'FN7_VLDEPR' )
oStrTipos:RemoveField( 'FN7_VLATU'  )
oStrTipos:RemoveField( 'FN7_DTBAIX' )
oStrTipos:RemoveField( 'FN7_VLRESI' )

/*
 * Remove Campos não Usados - Saldos de Ativos
 */
oStrSaldos:RemoveField( 'FN7_STATUS' )
oStrSaldos:RemoveField( 'FN7_FILORI' )
oStrSaldos:RemoveField( 'FN7_DTBAIX' )
oStrSaldos:RemoveField( 'FN7_MOTIVO' )
oStrSaldos:RemoveField( 'FN7_SEQREA' )
oStrSaldos:RemoveField( 'FN7_SEQ'    )
oStrSaldos:RemoveField( 'FN7_TPSALD' )
oStrSaldos:RemoveField( 'FN7_TIPO'   )
oStrSaldos:RemoveField( 'FN7_DESCRI' )
oStrSaldos:RemoveField( 'FN7_CITEM'  )
oStrSaldos:RemoveField( 'FN7_CBASE'  )
oStrSaldos:RemoveField( 'FN7_ITEM'   )
oStrSaldos:RemoveField( 'FN7_CODBX'  )

If cPaisLoc == "RUS"
	oStrTipos:RemoveField( 'FN7_VLBAIX' )
	oStrTipos:RemoveField( 'FN7_INCOST' )
EndIf

oStrSaldos:SetProperty( "FN7_VLBAIX" , MVC_VIEW_CANCHANGE, .T.  )
oStrSaldos:SetProperty( "FN7_VLRESI" , MVC_VIEW_CANCHANGE, .F.  )

/*
 * Adiciona Campos Virtuais
 */
oStrTipos:AddField( 'OK' ,'01',STR0007,STR0007,, 'Check' ,,,,,,,,,,,, ) //'Baixa?'#//'Baixa?'

/*
 * Criar "box" horizontal para receber algum elemento da view
 */
If lIsRussia
	oView:CreateHorizontalBox('BOXCABEC'	,67) //Cabeçalho
	oView:CreateHorizontalBox('BOXTIPOS'	,33) //Tipos de Ativos
Else
	oView:CreateHorizontalBox('BOXCABEC'	,33) //Cabeçalho
	oView:CreateHorizontalBox('BOXTIPOS'	,33) //Tipos de Ativos
	oView:CreateHorizontalBox('BOXSALDOS'	,34) //Saldos de Ativo
EndIf

/*
 * Na alteração do tipo, atualiza os valores da grid FN7VALOR
 */
oView:SetViewProperty('GRID_TIPOS' , 'CHANGELINE',{{||aF36WhenTp(oModel)}} )

/*
 * Relaciona o ID da View com o "box" para exibicao
 */
oView:SetOwnerView('FORM_ATIVO'		,'BOXCABEC' )	// Cabeçalho da Baixa do Ativo
oView:SetOwnerView('GRID_TIPOS'		,'BOXTIPOS' )	// Tipos de Ativo
If cPaisLoc <> "RUS"
	oView:SetOwnerView('GRID_SALDOS'	,'BOXSALDOS')	// Saldos do Ativo
EndIf

/*
 * Bloqueia a inclusão de novas linhas
 */
oView:SetNoInsertLine('GRID_TIPOS')
If cPaisLoc <> "RUS"
	oView:SetNoInsertLine('GRID_SALDOS')
EndIf

/*
 * Bloqueia a exclusão de linhas do grid
 */
oView:SetNoDeleteLine('GRID_TIPOS')
If cPaisLoc <> "RUS"
	oView:SetNoDeleteLine('GRID_SALDOS')
EndIf

/*
 * Habilita a exibição do titulo
 */
oView:EnableTitleView('GRID_TIPOS'	, STR0032 ) //'Tipos de Ativos'
If cPaisLoc <> "RUS"
	oView:EnableTitleView('GRID_SALDOS'	, STR0033 ) //'Valor de Baixa'
EndIf

/*
 * Acrescentando regra de auto-incremento no campo de Item nos Grids
 */
oView:AddIncrementField( 'GRID_TIPOS'	,'FN7_ITEM' )
If cPaisLoc <> "RUS"
	oView:AddIncrementField( 'GRID_SALDOS'	,'FN7_ITEM' )
EndIf

/*
 * Fecha a tela apos a gravação
 */
oView:SetCloseOnOk({||.T.})

oView:bAfterViewActivate := {|oModel| AT36Carga(oModel) }

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} AF036Vld

Função Inicializador de Valores da View
@author felipe.cunha
@since 14/01/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function AF036Vld(oModel, lValidCpo, cBase , cItem)
Local lRet		:= .T.
Local lUsaMNTAT	:= Iif(ALLTRIM(GETMV("MV_NGMNTAT",.F.,"N")) $ "1/3",.T.,.F.) // N-NAO INTEGRA / 1-ALTERACOES NO ATF REPLICARAO NO MNT / 2-ALTERACOES NO MNT REPLICARAO NO ATF / 3-ALTERACOES ATUALIZARAO ATF E MNT

Default lValidCpo := .F.
Default cBase 	:= SN3->N3_CBASE
Default cItem 	:= SN3->N3_ITEM

If mv_par04 == 2 .Or. MV_PAR04 == 3 .Or.lValidCpo

	If MV_PAR04 == 2
		SN1->(dbSetOrder( 1 ))
		SN1->(dbSeek( xFilial( "SN1" ) + cBase + cItem ))
	EndIf

	If __nOper == OPER_BAIXA
	
		/*
		 * Verifica se o controle de solicitações está ativado, se sim encerra baixa
		 */
		If ( SuperGetMv( "MV_ATFSOLD", .F. ,"2" ) == "1" ) .And. Alltrim(FunName()) == "ATFA036"
			HELP(" ",1,"AF036SOLD",,STR0036 ,1,0)    //"Utilize a opção Solic. Baixa/Transf, parâmetro de controle de solicitações (MV_ATFSOLD) ativado."
			lRet := .F.
		EndIf

		/*
		 * Verifica se o registro nao esta  baixado. 
		 */
		If mv_par04 == 2 //Visualização por Tipo de Ativo (SN3)
			IF Val( SN3->N3_BAIXA ) # 0
				Help(" ",1,"AF036BAIXA",,STR0037,1,0) // "Não é possível efetuar uma baixa de um item já baixado."
				lRet := .F.
			EndIf
		ElseIf MV_PAR04 == 3 //Visualização por Ativo (SN1)
			If A036SN1TBx()
				Help(" ",1,"AF036BAIXA",,STR0143,1,0) //"Não é possível efetuar uma baixa de um Ativo já baixado."
				lRet := .F.
			EndIf
		EndIf
		/*
		 * Verifica se o bem esta bloqueado - Por Data admin	
		 */
		If !Empty(SN1->N1_DTBLOQ) .and. SN1->N1_DTBLOQ >= dDataBase 
			Help(" ",1,"A036BLOQ",,STR0038,1,0)   //"Ativo bloqueado, nao poder sofrer baixas."
			lRet := .F.
		EndIf
	
		/*
		 * Verifica se o bem esta bloqueado - Por Status 	
		 */
		If SN1->N1_STATUS $ "2|3"
			Help(" ",1,"A036BLOQ",,STR0038,1,0)   //"Ativo bloqueado, nao poder sofrer baixas."
			lRet := .F.
		ElseIf lIsRussia .And. SN1->N1_STATUS <> '1'
			Help(" ",1,"A036RUINUSE",,STR0161,1,0)   // "Fixed asset must be with status 1-In Use to be writen-off"
			lRet := .F.	
		EndIf
	
		/*
		 * Verifica se o bem e de controle de terceiros	
		 */
		If SN1->N1_TPCTRAT == "3" .AND. !FWIsInCallStack('ATFA320')
			Help(" ",1,"AfA036TERC",,STR0039 ,1,0)//"Bens em controle de terceiro somente podem ser baixados pela rotina especifica (ATFA320)"
			lRet := .F.
		EndIf
	
		/*
		 * Avalia integracao com o modulo SIGAMNT - PARCEIRO NG³
		 */
		If lUsaMNTAT .AND. !AFVLBXIntMnt(SN1->N1_CODBEM,dDataBase,"ATFA036")
			lRet := .F.
		EndIf
	
		/*
		 * Verifica se o bem foi gerado por AVP Parcela
		 */
		If Alltrim(SN1->N1_ORIGEM) == 'ATFA460' .and. !lBxProvis
			Help(" ",1,"AF036460B",,STR0040 + SN1->N1_BASESUP +"-"+SN1->N1_ITEMSUP ,1,0)  //'Este ativo foi gerado a partir do processo de constituição de provisão. Este tipo de ativo não poderá ser baixado diretamente. Baixe o ativo superior (PAI).'###"C.Base-Item: "
			lRet := .F.
		Endif
	
		If lRet
			lRet := At710Ativo(SN1->N1_PRODUTO,SN1->N1_NFISCAL,SN1->N1_NSERIE,SN1->N1_ITEM)
		EndIf
	
		/*
		 * Verifica se o ativo está relacionado com um projeto do imobilizado  
		 */
		If ATFXVerPrj(SN1->N1_CBASE,SN1->N1_ITEM, .T. )
			lRet := .F.
		EndIf
		
	EndIf
EndIf


Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} AF036VLBEM

Valida digitação do BEM (Tabela FN6)

@author Totvs
@since 14/01/2014
@version 1.0
/*/

*/
//-------------------------------------------------------------------
Function AF036VLBEM()
Local lRet 			:= .T.
Local aArea			:= GetArea()
Local aAreaSN1		:= SN1->(GetArea())
Local oModel		:= FWModelActive()
Local oModelMaster	:= oModel:GetModel(If(FWIsInCallStack("AF036BxLote") .or. lAtf030,"FN6ATIVOS", "FN6MASTER"))
Local cBase			:= oModelMaster:GetValue("FN6_CBASE")
Local cItem			:= oModelMaster:GetValue("FN6_CITEM")

SN1->(dbSetOrder(1))//N1_FILIAL+N1_CBASE+N1_ITEM

If !Empty(cBase) .And. !Empty(cItem)
	If lRet .And. !SN1->(dbSeek(xFilial("SN1") + cBase + cItem ))
		lRet := .F.
		HELP(" ",1,"REGNOIS")
	EndIf

	If lRet .And. !Empty(SN1->N1_BAIXA)
		lRet := .F.
		Help(" ",1,"ATFA036BX",,STR0119,1,0) // "Bem já está baixado."
	EndIf
	
	If lRet 
		lRet := AF036Vld(oModel,.T.,cBase,cItem)
	EndIf
	
EndIf

RestArea(aAreaSN1)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036Load

Carrega os dados do cabeçalho da baixa (Tabela FN6)

@author felipe.cunha
@since 14/01/2014
@version 1.0
@param oModel Objeto do Modelo de Dados da Rotina de Baixa de Ativos
/*/
//-------------------------------------------------------------------
Function AF036Load(oModel)
Local aDados		:= {}
Local oFN6Struct	:= oModel:GetModelStruct("FN6MASTER")[3]:oFormModelStruct //:GetFields()
Local aCposVlr		:= {}
Local cFilFN6		:= FwxFilial("FN6")
Local cFilFN7		:= FwxFilial("FN7")
Local cBase			:= ''
Local cItem			:= ''
Local aFilCpos		:= {}
Local nContCpo		:= 0
Local cChave		:= ""

aCposVlr := oFN6Struct:GetFields()

/*
 * Carrega Pergunta Baixa de Ativo
 */
Pergunte("AFA036",.F.)
AF036PerAt()
/*
 * Baixa Manual
 */
If __nOper == OPER_CANC

	If !(FunName() $ "ATFA036")
		MV_PAR04 := 1
	EndIf
	dbSelectArea("FN6")
	FN6->(dbSetOrder(1)) // Filial + Código da Baixa
	FN7->(DBSetOrder(1))

	If MV_PAR04 == 2 //Visualização do browse por Tipos de Ativo (SN3)
		cBase	:= SN3->N3_CBASE
		cItem	:= SN3->N3_ITEM
		If FWModeAccess("SN3",3) == 'E'// Quando o ambiente é totalmente exclusivo
			cFILBem := IIF(!Empty(SN3->N3_FILORIG),SN3->N3_FILORIG,SN3->N3_FILIAL)
		Else
			cFILBem := xFilial('SN3')
		End
		aRet := A036ULTCOD(SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_TPSALDO,cFILBem,Nil,.T.,SN3->N3_SEQ)
		cFilFN6 := aRet[1]
		cCodBX  := aRet[2] 
		FN6->(DbSeek(cFilFN6 + cCodBX))
		FN7->(DBSeek(cFilFN7 + cCodBX))
	ElseIf MV_PAR04 == 3 //Visualização do browse por Ativos (SN1)
		aRet := A036ULTCOD(SN1->N1_CBASE,SN1->N1_ITEM,,,SN1->N1_FILIAL,"SN1",.T.)
		cFilFN6 := aRet[1]
		cCodBX  := aRet[2] 
		FN6->(DbSeek(cFilFN6 + cCodBX))
		FN7->(DBSeek(cFilFN7 + cCodBX))
	EndIf

ElseIf __nOper == OPER_VISUA

	If MV_PAR04 == 1
		cChave := cFilFN6+FN6->FN6_CODBX
	Else
		cBase	 := SN3->N3_CBASE
		cItem	 := SN3->N3_ITEM
		cFILBem := IIF(!Empty(SN3->N3_FILORIG),SN3->N3_FILORIG,SN3->N3_FILIAL)
		aRet    := A036ULTCOD(SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_TPSALDO,cFILBem,Nil,.T.,SN3->N3_SEQ)
		cFilFN7 := aRet[1]
		cCodBX  := aRet[2]
		
		cChave := cFilFN7 + cCodBX 

	EndIf

	DbSelectArea("FN6")
	FN6->(dbSetOrder(1)) // Filial + Código da Baixa
	If FN6->(dbSeek(cChave))
		For nContCpo := 1 To Len(aCposVlr)
			If !oFN6Struct:GetProperty(aCposVlr[nContCpo][3],MODEL_FIELD_VIRTUAL)
				aAdd(aFilCpos,FN6->&(aCposVlr[nContCpo][3]))
			Else
				aAdd(aFilCpos,'')
			EndIf
		Next nContCpo
		SN1->(dbSetOrder( 1 ))
		SN1->(dbSeek( xFilial( "SN1" ) + FN6->FN6_CBASE + FN6->FN6_CITEM ))
		aFilCpos[5] := SN1->N1_DESCRIC
		aFilCpos[7] := FN6->FN6_PERCBX
		aDados := {aFilCpos,0}

		FN7->(DbSetOrder( 1 ))
		FN7->(DbSeek( cFilFN7 + FN6->FN6_CODBX))

	EndIf

EndIf

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036Pos

Verifica tabela de motivos para baixa

@author felipe.cunha
@since 14/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036Pos(oModel)

Local aArea			:= GetArea()
Local aAreaSN3		:= SN3->(GetArea())
Local aAreaSN4		:= SN4->(GetArea())

Local oModelMaster	:= oModel:GetModel(If(FWIsInCallStack("AF036BxLote") .or. lAtf030 ,"FN6ATIVOS", "FN6MASTER"))
Local oModelTipo	:= oModel:GetModel('FN7TIPO')
Local oModelValor	:= oModel:GetModel('FN7VALOR')
Local oModelAcum	:= oModel:GetModel('VLRACUM')
Local cNota			:= oModelMaster:GetValue('FN6_NUMNF')
Local cSerie		:= oModelMaster:GetValue('FN6_SERIE')
Local nPBaixa		:= oModelMaster:GetValue('FN6_PERCBX')
Local nQtdAtu		:= oModelMaster:GetValue('FN6_QTDATU')
Local nQtdBx		:= oModelMaster:GetValue('FN6_QTDBX')
Local dBaixa036		:= oModelMaster:GetValue('FN6_DTBAIX')
//Variaveis para validacao da Geracao da NF
Local lGeraNF		:= oModelMaster:GetValue( 'FN6_GERANF') == "1" 	//Define se a Nota Fiscal sera gerada na baixa do bem
Local cCliente		:= oModelMaster:GetValue( 'FN6_CLIENT')			//Cliente
Local cLoja			:= oModelMaster:GetValue( 'FN6_LOJA')			//Loja
Local cTESSaida		:= oModelMaster:GetValue( 'FN6_TESSAI')			//TES saida
Local cCondPag		:= oModelMaster:GetValue( 'FN6_CNDPAG')			//Condicao de Pagamento
Local cNatureza		:= oModelMaster:GetValue( 'FN6_NATURE')			//Natureza
Local nValNF		:= oModelMaster:GetValue( 'FN6_VALNF')			//Valor da NF
Local cTipAtivNF	:= SuperGetMV("MV_ATFMBNF",.F.,"")				//Parametro com os tipos de ativos que podem ser baixados
Local lExistTipo	:= .F.
Local nX			:= 0
Local nY			:= 0
Local lRet			:= .T.
Local cBase			:= oModelMaster:GetValue( 'FN6_CBASE' )
Local cItem			:= oModelMaster:GetValue( 'FN6_CITEM' )
Local cProduto		:= GetAdvFVal("SN1","N1_PRODUTO",XFilial("SN1")+cBase+cItem,1,"",.T.)
Local cTipo			:= ""
Local cTipoSld		:= ""
Local cSeq			:= ""
Local dDataBx		:= STOD("")
Local aTiposReav 	:= {}
Local cMotSF9		:= ''
Local lVlParcial	:= .F.
Local lTodosTipos	:= .T.
Local cIdMovSN4		:= ""
Local cCodCFDUso	:= "" //Codigo del Uso de CFDI - MEX

Private cMotivo		:= oModelMaster:GetValue('FN6_MOTIVO')

If lExisCPC31 == Nil
	lExisCPC31 := SN1->(Fieldpos("N1_BLQDEPR")) > 0 .And. cPaisLoc == "BRA" //CPC31, VERIFICA SE O CAMPO EXISTE NA BASE E SE É DA LOCALIDADE DO BRASIL
EndIF

If cPaisLoc == "MEX"
	cCodCFDUso := oModelMaster:GetValue('FN6_USOCFD')
EndIf

If __nOper == OPER_BAIXA

	If oModelValor:GetValue("FN7_PERCBX") == 0.00
 		HELP(" ",1,"AF036PERC",,STR0127,1,0) // "Percentual de Baixa não informado. Informe um percentual para efetuar baixa."
		lRet := .F.
	EndIf
	
	lRet := lRet .And. AF036VLBX(oModelMaster,oModelTipo,oModelValor)
	
	lRet := lRet .And. AF036DtBx(.F. /* lDesmarca */, /* lDtLote */, oModel)

	/*
	 * Bem em Penhora-> Não pode ser baixado pelo motivo "01-Venda"
	 * Bem Penhorado -> somente poderá ser baixado pelo motivo "12-Penhora"
	 */
	If lRet .And. SN1->N1_PENHORA == "2" .And. Subs(cMotivo,1,2) == "01"			//Em Penhora
		HELP(" ",1,"AF036EMPE",,STR0015,1,0) // "Bem em Penhora, não pode ser baixado pelo motivo '01-Venda'."
		lRet := .F.
 	ElseIf lRet .And. SN1->N1_PENHORA == "3" .And. Subs(cMotivo,1,2) != "12"		//Penhorado
		HELP(" ",1,"AF036PENH",,STR0016,1,0) // "Bem Penhorado, somente poderá ser baixado pelo motivo '12-Penhora'."
		lRet := .F.
	EndIf

	/*
	 * Verifica se o valor de venda foi digitado
	 */
	If lRet .And. (nValNF == 0 .And. cMotivo =='01')
		Help(" ",1, "AF036VLVEN",, STR0103,1,0)  //"Informe o valor da nota fiscal."
		lRet := .F.
	EndIf

	/*
	* Verifica se a quantidade de baixa foi digitada. Para a geracao da NF deve ser maior que zero.
	*/
	If lRet .And. cPaisLoc == "BRA"
		If lValidaNFD	// Sim -> Valida Nota de Devolução
			If cMotivo == '23' //Devolução de Item da Nota
				
				/* Verifica se o numero da nota esta preenchido */
				If Empty(cNota) .AND. !lGeraNF 
					Help(" ",1, "AF036NFDV",, STR0020,1,0)  //'O Nro/Série/Item da Nota devem ser informados se o parâmetro MV_AF30NDV for T e o motivo da baixa for 23-Devolução'
					lRet := .F.
				EndIf
				
				/* Verifica se a serie da nota esta preenchido */
				If !Empty(cNota) .and. Empty(cSerie)
					Help(" ",1, "AF036NFDV",,STR0020,1,0)  //'O Nro/Série/Item da Nota devem ser informados se o parâmetro MV_AF30NDV for T e o motivo da baixa for 23-Devolução'
					lRet := .F.
				EndIf
				
			EndIf
		EndIf
	EndIf
	
	/*
	 * Nao permite baixas por quantidade quando houver agregados
 	*/ 
	//Tipos de reavaliação
	If lRet
		AAdd(aTiposReav,"02") //reavaliacao
		AAdd(aTiposReav,"04") //Lei 8.200
		AAdd(aTiposReav,"41") // Reavaliação anual de bens não totalmente depreciados
		AAdd(aTiposReav,"42") // Reavaliação anual de bens totalmente depreciados
		AAdd(aTiposReav,"50") // Colombia: Depreciacao gerencial "metodo linear"
		AAdd(aTiposReav,"51") // Colombia: Depreciacao gerencial "soma dos digitos"
		AAdd(aTiposReav,"52") // Colombia: Depreciacao gerencial "reducao de saldos"
		AAdd(aTiposReav,"53") // Colombia: Depreciacao gerencial "soma dos anos"
		AAdd(aTiposReav,"54") // Colombia: Depreciacao gerencial "unidades produzidas"
		
		For nY := 1 to oModelTipo:Length()
			//Posiciona no primeiro tipo de ativo
			oModelTipo:GoLine( nY )
			
			//Verifica todos os tipos de ativos existentes para o bem selecionado
			cTipo 	:= oModelValor:GetValue("FN7_TIPO" )
			
			dbSelectArea( "SN3" )
			SN3->(dbSetOrder( 1 ) )
			SN3->(dbSeek( xFilial( "SN3" ) + cBase + cItem + cTipo ))
			
			//Verifica se o tipo de ativo está marcado
			If oModelTipo:GetValue("OK" , nY) == .T.
				lExistTipo := .T.
				If nQtdBx > 0
					For nX := 1 to Len(aTiposReav)
						If AllTrim(SN3->N3_TIPREAV) ==  aTiposReav[nX] //???Tipode reavaliação
							Help(" ",1,"AF036BXVALOR",,STR0021,1,0)  //"Este item possui agregados, tipos de reavaliacao, ou ambos. Só poderá sofrer baixas por valor."
							lRet := .F.
							Exit
						Endif
					Next nX
				Endif
			Else
				lTodosTipos := .F.
			EndIf
		Next nY
		
		If lRet .And. !lExistTipo
			Help(" ",1,"AF036SEMTP",, STR0120 ,1,0) // "Não existem tipo selecionados para a baixa."
			lRet := .F.
		EndIf
		
	EndIf
	
	/*
 	 * Nao permite baixa parcial para bens classificados como ORCAMENTO
	 */
	If lRet
		For nX := 1 to oModelAcum:Length()
			oModelAcum:GoLine( nX )
			
			If oModelAcum:GetValue('PERCBAIX') < 100
				lVlParcial := .T.
			EndIf
			
			If nQtdAtu == nQtdBx .And. (!lTodosTipos .Or. oModelAcum:GetValue('PERCBAIX') < 100) .And. ! RusCheckRevalFunctions()
				If !FWIsInCallStack('ATFA380') //ATFA380 deve liberar pois faz o cadastro de um novo ativo ao mesmo tempo que realiza a baixa.
					Help(" ",1,"AFBXTPORC",, STR0121 ,1,0) // "Quantidade total deve baixar todos os tipos em 100% de dos valores."
					lRet := .F.
					Exit
				EndIf
			EndIf
			
			If ( SN1->N1_PATRIM == 'O' ) .and.( (  oModelAcum:GetValue('PERCBAIX') < 100 ) .Or. ( nPBaixa < 100 ) .Or. ( nQtdAtu <> nQtdBx ) )
				Help(" ",1,"AFBXTPORC",,STR0019,1,0) //"Bens classificados como Orçamento somente podem sofrer baixa total"
				lRet := .F.
				Exit
			Endif
			
		Next nX
	EndIf
	
	
If lRet
		//Validação CPC31 tipo de venda sem depreciar, não pode ser em baixa parcial
		//NÃO REMOVER
		If lExisCPC31 .And. oModelMaster:GetValue("FN6_DEPREC") == '3' .And. oModelMaster:GetValue("FN6_BAIXA") <> 100
			lRet := .F.
			Help("",1,STR0174,,STR0175,1,0) // Depreciar - Opção 3 ## Opção:  3 - Não Deprecia Baixa/posteriormente, não é possivel baixar um bem parcialmente com está opção, utilize a baixa total do bem"
		Endif
	Endif
	/*
	* CIAP
	*/
	
	If lRet
		For nY := 1 to oModelTipo:Length()
			/*
			* Posiciona no primeiro tipo de ativo
			*/
			oModelTipo:GoLine( nY )
			
			/*
			* Verifica todos os tipos de ativos existentes para o bem selecionado
			*/
			cTipo 	:= oModelValor:GetValue("FN7_TIPO" )
			
			dbSelectArea( "SN3" )
			SN3->( dbSetOrder( 1 ) )
			SN3->( dbSeek( xFilial( "SN3" ) + cBase + cItem + cTipo ) )
			
			If If(SN3->N3_TIPO <> '01', AF036HASN3(), SN3->N3_TIPO == '01') .and. !Empty(SN1->N1_CODCIAP)
				If Substring(cMotivo,1,2) == "01"
					cMotSF9 := "2"
				ElseIf Substring(cMotivo,1,2) == "10"
					cMotSF9 := "3"
				ElseIf Substring(cMotivo,1,2) == "23"
					cMotSF9 := "4"
				ElseIf Substring(cMotivo,1,2) $ "02|03|05|06|07"
					cMotSF9 := "1"
				Else
				/*
				 * Outros , exemplo ->12-penhora/04-Doação/09-Reavaliação
				 */
					cMotSF9 := "5"
				EndIf
				
				dbSelectArea("SFA")
				SFA->(dbSetOrder(1))
				if AF36HASAF( SN1->N1_CODCIAP, dBaixa036, '2' , cMotSF9)
					Help("",1, "AFA036CIAP",,STR0022,1,0)		//"Este Ativo possui um código CIAP que já sofreu baixa com esse motivo nesta data."
					lRet := .F.
				endif
			endif
		Next nY
	EndIf
	
	//--------------------------------------------------------------
	// Validacoes para a geracao da Nota Fiscal
	//--------------------------------------------------------------
	If lRet .And. lGeraNF
		
		//---------------------------------
		// Valida se a Serie foi informada
		//---------------------------------
		If lRet .And. Empty(cSerie)
			lRet := .F.
			Help(" ",1, "AF036Pos1",,STR0095,1,0) //"Informe a série para a geração da Nota Fiscal."
		EndIf
		
		//------------------------------------------------------
		//Verifica o motivo da baixa com os motivos permitidos
		//------------------------------------------------------
		If lRet .And. !(cMotivo $ cTipAtivNF)
			lRet := .F.
			Help(" ",1, "AF036Pos2",,STR0096,1,0) //"Não é possivel gerar a nota fiscal para o motivo da baixa selecionado. Ver o parâmetro MV_ATFMBNF."
		EndIf
		
		//------------------------------------------------------
		//Verifica se o cliente e loja foram informados
		//------------------------------------------------------
		If lRet .And. Empty(cCliente) .Or. Empty(cLoja)
			lRet := .F.
			Help(" ",1, "AF036Pos3",,STR0097,1,0) //"O Cliente e Loja devem ser informados para a geração da nota fiscal."
		EndIf
		
		//----------------------------------------------------------
		//Verifica se o Ativo possui produto cadastrado (N1_PRODUTO)
		//----------------------------------------------------------
		If lRet .And. Empty(cProduto)
			lRet := .F.
			Help(" ",1, "AF036Pos4",,STR0098,1,0) //"O ativo não possui produto relacionado em seu cadastro para a geracao da nota fiscal."
		EndIf
		
		//--------------------------------------------
		// Verifica se o TES de saida esta preenchida
		//--------------------------------------------
		If lRet
			If !Empty(cTESSaida)
				
				//---------------------------------------------------------------------------------------
				// Verifica se a TES esta configura para gerar duplicata e se a Natureza esta preenchida
				//---------------------------------------------------------------------------------------
				If lRet .And. GetAdvFVal("SF4","F4_DUPLIC",XFilial("SF4")+cTESSaida,1,"") == 'S' .And. Empty(cNatureza)
					lRet := .F.
					Help(" ",1, "AF036Pos6",,STR0100,1,0) //"Para Tipo de Saída que atualize o financeiro a Natureza deverá ser informada."
				EndIf
			Else
				lRet := .F.
				Help(" ",1, "AF036Pos7",,STR0101,1,0) //"O Tipo de Saída precisa ser informado para a geracao da nota fiscal."
			EndIf
		EndIf
		
		//------------------------------------------------------
		// Verifica se a condicao de pagamento foi informada
		//------------------------------------------------------
		If lRet .And. Empty(cCondPag)
			lRet := .F.
			Help(" ",1, "AF036Pos8",,STR0102,1,0) //"A condição de pagamento precisa ser informada para a geracao da nota fiscal."
		EndIf
		
		//-----------------------------------------
		// Verifica se o Valor da NF foi informado
		//-----------------------------------------
		If lRet .And. nValNF == 0
			lRet := .F.
			Help(" ",1, "AF036Pos9",,STR0103,1,0) //"Informe o valor da nota fiscal."
		EndIf
		
		//------------------------------------------------------
		//Verifica se todos os tipos estao selecionados
		//------------------------------------------------------
		If lRet
			For nY := 1 to oModelTipo:Length()
				
				oModelTipo:GoLine( nY )
				
				//Verifica se o tipo de ativo está marcado
				If lRet .And. !oModelTipo:GetValue("OK" , nY)
					lRet := .F.
					Help(" ",1, "AF036Pos10",,STR0104,1,0) //"Todos os tipos devem ser selecionados para a geracao da nota fiscal."
					Exit
				EndIf
				
			Next nY
		EndIf
		
		//-----------------------------------------------------------------
		//Verifica se há os tipos 01-Depreciacao Fiscal ou 03-Adiantamento
		//-----------------------------------------------------------------
		If lRet
			lRet := .F.
			For nY := 1 to oModelTipo:Length()
				
				oModelTipo:GoLine( nY )
				
				If oModelTipo:GetValue("FN7_TIPO" , nY) $ "01|03"
					lRet := .T.
					Exit
				EndIf
				
			Next nY
			
			If !lRet
				Help(" ",1, "AF036Pos11",,STR0105,1,0) //"Para a geração da nota fiscal o ativo precisa ter os tipos 01 ou 03."
			EndIf
		EndIf
		
		If lRet .And. cPaisLoc == "MEX"
			If Empty(cCodCFDUso)
				Help(" ",1, RTrim(FWX3Titulo("FN6_USOCFD")),,STR0171 + RTrim(FWX3Titulo("FN6_USOCFD")) + STR0172,1,0) // El campo ### se encuentra vacío.
				lRet := .F.
			EndIf
		EndIf
		If lRet .And. cPaisLoc == "PER" .And. lExisCpo
			If Empty(oModelMaster:GetValue('FN6_TPDOC'))
				Help(" ",1, RTrim(FWX3Titulo("FN6_TPDOC")),,STR0171 + RTrim(FWX3Titulo("FN6_TPDOC")) + STR0172,1,0) // El campo ### se encuentra vacío.
				lRet := .F.
			EndIf
		EndIf
		If lRet .And. cPaisLoc == "COL" .And. lExisCpo
			If Empty(oModelMaster:GetValue('FN6_CODMUN'))
				Help(" ",1, RTrim(FWX3Titulo("FN6_CODMUN")),,STR0171 + RTrim(FWX3Titulo("FN6_CODMUN")) + STR0172,1,0) // El campo ### se encuentra vacío.
				lRet := .F.
			ElseIf Empty(oModelMaster:GetValue('FN6_TPACTI'))
				Help(" ",1, RTrim(FWX3Titulo("FN6_TPACTI")),,STR0171 + RTrim(FWX3Titulo("FN6_TPACTI")) + STR0172,1,0) // El campo ### se encuentra vacío.
				lRet := .F.
			ElseIf Empty(oModelMaster:GetValue('FN6_TRMPAC'))
				Help(" ",1, RTrim(FWX3Titulo("FN6_TRMPAC")),,STR0171 + RTrim(FWX3Titulo("FN6_TRMPAC")) + STR0172,1,0) // El campo ### se encuentra vacío.
				lRet := .F.
			ElseIf Empty(oModelMaster:GetValue('FN6_TIPOPE'))
				Help(" ",1, RTrim(FWX3Titulo("FN6_TIPOPE")),,STR0171 + RTrim(FWX3Titulo("FN6_TIPOPE")) + STR0172,1,0) // El campo ### se encuentra vacío.
				lRet := .F.
			EndIf
		EndIf
		
	EndIf

	//----------------------------------------------------
	// Validacao do Gestao de Servicos - Equipe Materiais
	//----------------------------------------------------
	If lRet .And. GetNewPar("MV_TECATF","N") == "S"
		lRet := TcAtfVldMov(cFilAnt,cBase,nQtdBx)
	EndIf

	RestArea(aArea)
	
	oModelTipo:GoLine( 1 )
	oModelValor:GoLine( 1 )
Else
	
	If FN6->FN6_STATUS == '2'
		Help(" ",1,"A036BXCC",, STR0114 ,1,0)  //"Baixa de Ativo já cancelada."
		lRet := .F.
	EndIf

	//----------------------------------------------------------
	// Valida se foi gerada NF e se ha mais ativos relacionados
	//----------------------------------------------------------
	If lRet .And. !IsBlind() .And. FN6->FN6_GERANF = "1" .And. !Empty(FN6->FN6_NUMNF) .And. !Empty(FN6->FN6_SERIE)

		If Len(AF036ItnNF(FN6->FN6_FILORI,FN6->FN6_NUMNF,FN6->FN6_SERIE)) > 1

			lRet := MsgNoYes(STR0148,STR0148) //"Para cancelar esta baixa, o sistema cancelará as demais baixas dos ativos presentes na Nota Fiscal. Deseja prosseguir?"###"Atenção"

			If !lRet
				oModel:SetErrorMessage("",,oModel:GetId(),"","AF036Pos",STR0150) //"Baixa cancelada pelo utilizador."
			EndIf

		EndIf

	EndIf

	cAlsSN4		:= GetNextAlias()

	For nY := 1 to oModelTipo:Length()
		cBase		:= FN6->FN6_CBASE
		cItem		:= FN6->FN6_CITEM
		cTipo		:= oModelTipo:GetValue("FN7_TIPO")
		cTipoSld	:= oModelTipo:GetValue("FN7_TPSALD")
		cSeq		:= oModelTipo:GetValue("FN7_SEQ")
		dDataBx		:= oModelTipo:GetValue("FN7_DTBAIX")
		
		If Empty(cTipoSld)
		 	dbSelectArea( "SN4" )
			SN4->(dbSetOrder( 1 ) )
			If SN4->(dbSeek( xFilial( "SN4" ) + cBase + cItem + cTipo + "01"))
				cTipoSld := SN4->N4_TPSALDO
			EndIf
		EndIf
		
		//CRLF removido por bug no TcGenQry
		cQrySN4 := " SELECT "
		cQrySN4 += " SN4.R_E_C_N_O_ RECNOSN4 "
		cQrySN4 += " FROM " + RetSqlName("SN4") + " SN4 "
		cQrySN4 += " WHERE "
		cQrySN4 += RetSqlCond("SN4")
		cQrySN4 += " AND SN4.N4_CBASE = '" + cBase + "' "
		cQrySN4 += " AND SN4.N4_ITEM = '" + cItem + "' "
		cQrySN4 += " AND SN4.N4_TIPO = '" + cTipo + "' "
		cQrySN4 += " AND SN4.N4_DATA = '" + DTOS(dDataBx) + "' "
		If lIsRussia
			cQrySN4 += " AND SN4.N4_OCORR = '06' "
			cQrySN4 += " AND SN4.N4_ORIGEM= 'ATFA036' "
		Else
			cQrySN4 += " AND SN4.N4_OCORR = '01' "
		Endif
		cQrySN4 += " AND SN4.N4_SEQ = '" + cSeq + "' "
		If !Empty(cTipoSld)
			cQrySN4 += " AND SN4.N4_TPSALDO = '" + cTipoSld + "' "
		EndIf

		dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQrySN4) , cAlsSN4 , .T. , .F.)

		If (cAlsSN4)->(!EOF()) .Or. (cAlsSN4)->(!BOF())
			SN4->(DbGoTo((cAlsSN4)->RECNOSN4))
			If !Empty(SN4->N4_IDMOV)
				cIdMovSN4 := SN4->N4_IDMOV
			Else
				lRet := .F.
				Help(" ",1, "AF036POS",,STR0144,1,0) //"ID do movimento da baixa não localizado."
			EndIf
		Else
			lRet := .F.
			Help(" ",1, "AF036POS",,STR0145,1,0) //"Registro do movimento da baixa não localizado."
		EndIf

		(cAlsSN4)->(DbCloseArea())

		DbSelectArea("SN3")
		SN3->(DbSetOrder(11)) // Filial + Código Base + Item Base + Tipo Ativo + Baixa + Tipo de Saldo
		SN3->(DbSeek(xFilial("SN3") + cBase + cItem + cTipo + '1' + cTipoSld ))
		
		/*
		* Verificando a existência ficha do ativo
		*/
		dbSelectArea("SN1")
		SN1->(dbSetOrder(1)) // Filial + Código do Bem + Item do Bem
			
		IF lRet .And. SN1->(!dbSeek(xFilial("SN1")+cBase+cItem))
			Help(" ",1,"020ATIVO")
			lRet := .F.
		EndIf
		
		If lRet .AND. SN1->N1_STATUS $ "2|3"
			Help(" ",1,"A036BLOQ",,STR0038,1,0)  //"Ativo bloqueado, nao poder sofrer baixas."
			lRet := .F.
		EndIf
		
		nVlVend	:= SN4->N4_VENDA
		
		/*
		* Apenas será possivel cancelar a baixa de um bem convertido pela rotina de cancelamento de conversão (ATFA012)
		*/
		If lRet .AND. SN4->N4_MOTIVO == '13' .And. !FWIsInCallStack("AF012CVMet")
			Help(" ",1,"AF036CCONV",,STR0044,1,0)//"Baixas com motivo 13-Conversão apenas podem ser cancelado pela rotina de cancelamento de conversão(ATFA010)"
			lRet := .F.
		EndIf
		
		If lRet .AND. SN4->N4_MOTIVO == '14' .And. !FWIsInCallStack("A103GrvAtf")
			Help(" ",1,"AF036DEB",,STR0043,1,0)//"Baixas com motivo 14 apenas podem ser cancelado pela exclusão da nota de crédito/débito"
			lRet := .F.
		EndIf
		
		If lRet .AND. SN4->N4_MOTIVO $ '16/17' .And. !FWIsInCallStack("ATFA320")
			Help(" ",1,"AF036TERC",,STR0039,1,0)//"Baixas com motivo de bens de terceiro apenas podem ser canceladas pela rotina de Controle De Terceiros(ATFA320)"
			lRet := .F.
		EndIf
		
		If lRet .AND. SN4->N4_MOTIVO $ '18' .And. !IsInCallStack("AF060Canc")
			Help(" ",1,"AF036FILAUT",,STR0042,1,0)//"Baixas com motivo 18-Transferencia Interna de Filial não pode ser cancelada"
			lRet := .F.
		EndIf
		
		If lRet .AND. ATFXVerPrj(SN3->N3_CBASE,SN3->N3_ITEM, .T. )
			lRet := .F.
		EndIf
	Next nY
	
EndIf

RestArea(aAreaSN4)
RestArea(aAreaSN3)
RestArea(aArea)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} AF036ValMot

Verifica tabela de motivos para baixa

@author felipe.cunha
@since 14/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036ValMot()
Local cRet		:= ''
Local cTabela	:= "16"
Local cPrefix	:= "X5"
Local aArea		:= GetArea()
Local bFiltro	:= { || .T. }

//Pesquisa os motivos de Baixas existentes SX5 - Tabela 16
dbSelectArea("SX5")
("SX5")->(dbSeek(xFilial("SX5")+cTabela))

//Laço para verificação dos motivos usados na baixa
While SX5->X5_FILIAL+SX5->X5_TABELA == xFilial("SX5")+cTabela
	/*
	 * Se a baixa for efetuada via rotina (Interface), será efetuado o filtro de motivos de baixa.
	 * Caso contrário, todos os motivos poderao ser utilizados (Integração).
	 */
	IF FWIsInCallStack("ATFA320")
		bFiltro := { || Alltrim(SX5->X5_CHAVE) $ '15/16/17' }
	ElseIf FunName() $ "ATFA036/ATFA036L/ATFA036M"
		bFiltro := { || !Alltrim(SX5->X5_CHAVE) $ '08/13/14/15/16/17/18' }
	EndIf

	//Carrega os motivos do array passado por parametro
	If EVal(bFiltro)
		cRet := cRet + IIf(empty(cRet),'',';') + Alltrim(&(cPrefix + "_CHAVE")) + '=' + Alltrim(X5Descri())
	EndIf
	SX5->(dbSkip())
EndDo

RestArea(aArea)

Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} AF036StFN6

Dicionario Tabela FN6 - FN6MASTER

@author felipe.cunha
@since 14/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036StFN6()
Local oStrFN6	 := FWFormStruct( 1, "FN6", /*bAvalCampo*/, /*lViewUsado*/ )
Local aCposVlr	 := {}
Local nContCpo	 := 0
Local bValid	 := {|| }
Local cTituloFN6 := ""
Local aAreaSX3	 := {}
Local lMostraVal := .T.

If FWIsInCallStack("AF036BxLote") .or. lAtf030
 __nOper := 3
EndIf

If __nOper == OPER_BXLOT .And. cPaisLoc == "BRA" .And. Type("mv_par12") == "N" 
	lMostraVal := (MV_PAR12==1)
EndIf

IF !__lRotAuto
	Pergunte("AFA036",.F.)
	AF036PerAt()
endif
/*
* Configura inicializador padrão
*/
If __nOper == OPER_BAIXA
	oStrFN6:SetProperty( "FN6_CODBX"  	, MODEL_FIELD_INIT, {|| Af036CodBx() }  )
	oStrFN6:SetProperty( "FN6_DTBAIX"  	, MODEL_FIELD_INIT, {|| dDataBase }  )
	oStrFN6:SetProperty( "FN6_DEPREC"  	, MODEL_FIELD_INIT, {|| SUPERGETMV('MV_ATFDPBX',.F.,"1") }  )
	oStrFN6:SetProperty( "FN6_FILORI"  	, MODEL_FIELD_INIT, {|| cFilAnt }  )

	If MV_PAR04 == 2 .Or. MV_PAR04 == 3 //Se a visualizacao do browse for por Ativos (SN1) ou Tipos de Ativo (SN3)
		oStrFN6:SetProperty( "FN6_CBASE"  	, MODEL_FIELD_INIT, {|| SN1->N1_CBASE }  )
		oStrFN6:SetProperty( "FN6_CITEM"  	, MODEL_FIELD_INIT, {|| SN1->N1_ITEM }  )
		oStrFN6:SetProperty( "FN6_DESCRI"  	, MODEL_FIELD_INIT, {|| SN1->N1_DESCRIC }  )
		oStrFN6:SetProperty( "FN6_QTDATU"  	, MODEL_FIELD_INIT, {|| SN1->N1_QUANTD }  )
	EndIf
EndIf

If __nOper == OPER_CANC

	aCposVlr := oStrFN6:GetFields()

	For nContCpo := 1 To Len(aCposVlr)
		If !oStrFN6:GetProperty(aCposVlr[nContCpo][3],MODEL_FIELD_VIRTUAL)

			If !aCposVlr[nContCpo][3] == 'FN6_FILIAL' .And. !aCposVlr[nContCpo][3] == 'FN6_STATUS'

				oStrFN6:SetProperty(aCposVlr[nContCpo][3], MODEL_FIELD_INIT, &("{|| FN6->"+aCposVlr[nContCpo][3] +" }") )
			EndIf
		Else
			If aCposVlr[nContCpo][3] == "FN6_BAIXA"
				oStrFN6:SetProperty(aCposVlr[nContCpo][3], MODEL_FIELD_INIT, {|| 0 }  )
			ElseIf aCposVlr[nContCpo][3] == "FN6_DESCRI" 
				oStrFN6:SetProperty(aCposVlr[nContCpo][3], MODEL_FIELD_INIT, {||SN1->N1_DESCRIC } )
			EndIf
		EndIf
	Next nContCpo

EndIf

/*
 * Validacao (X3_VALID) 
 */
If MV_PAR04 == 1 .And. !__lRotAuto
	bValid := FWBuildFeature(STRUCT_FEATURE_VALID,"AF036VLBEM()")
	oStrFN6:SetProperty('FN6_CBASE'		,MODEL_FIELD_VALID, bValid )
	oStrFN6:SetProperty('FN6_CITEM'		,MODEL_FIELD_VALID, bValid )
	oStrFN6:AddTrigger( 'FN6_CBASE'	,'FN6_CBASE'	, { || .T. } , {|| AF036GatBs('FN6_CBASE') } )
	oStrFN6:AddTrigger( 'FN6_CITEM'	,'FN6_CITEM'	, { || .T. } , {|| AF036GatBs('FN6_CITEM') } )
EndIf

oStrFN6:SetProperty('FN6_QTDBX'		,MODEL_FIELD_VALID, {|| AF036X3Val('FN6_QTDBX')	})
oStrFN6:SetProperty('FN6_SERIE'		,MODEL_FIELD_VALID, {|| AF036X3Val('FN6_SERIE')	})
oStrFN6:SetProperty('FN6_CLIENT'	,MODEL_FIELD_VALID, {|| AF036X3Val('FN6_CLIENT') })
oStrFN6:SetProperty('FN6_LOJA'		,MODEL_FIELD_VALID, {|| AF036X3Val('FN6_LOJA')	})


/*
 * Gatilhos (X3_TRIGGER)
 */
oStrFN6:AddTrigger( 'FN6_BAIXA'		,'FN6_BAIXA'	, { || .T. } , {|| AF036GatQt("FN6_BAIXA") } )
oStrFN6:AddTrigger( 'FN6_QTDBX'		,'FN6_QTDBX'	, { || .T. } , {|| AF036GatQt("FN6_QTDBX") } )
oStrFN6:AddTrigger( 'FN6_DTBAIX'	,'FN6_DTBAIX'	, { || .T. } , {|| AF036GatQt("FN6_DTBAIX") } )
oStrFN6:AddTrigger( 'FN6_DEPREC'	,'FN6_DEPREC'	, { || .T. } , {|| AF036GatQt("FN6_DEPREC") } )

If lMostraVal
	oStrFN6:AddTrigger( 'FN6_MOTIVO'  	,'FN6_MOTIVO'	, { || .T. } , {|| AF036GatMt() } )
	oStrFN6:AddTrigger( 'FN6_GERANF'	,'FN6_GERANF'	, { || .T. } , {|| AF036GatNf() } )
EndIf

/*
 * Modo Edicao (X3_WHEN) 
 */
If __nOper == OPER_BAIXA .OR. __nOper == OPER_BXLOT
	oStrFN6:SetProperty('FN6_ITEMNF'	,MODEL_FIELD_WHEN, {|| cPaisloc == "BRA" .and. lValidaNFD }) //Valida edição do campo Item da Nota Fiscal de Saida
	oStrFN6:SetProperty('FN6_CBASE'		,MODEL_FIELD_WHEN, {|| MV_PAR04 == 1 })
	oStrFN6:SetProperty('FN6_CITEM'		,MODEL_FIELD_WHEN, {|| MV_PAR04 == 1 })
	oStrFN6:SetProperty('FN6_NUMNF'		,MODEL_FIELD_WHEN, {|| AF036X3Whe('FN6_NUMNF') })
	oStrFN6:SetProperty('FN6_SERIE'		,MODEL_FIELD_WHEN, {|| AF036X3Whe('FN6_SERIE') })
	oStrFN6:SetProperty('FN6_GERANF'	,MODEL_FIELD_WHEN, {|| AF036X3Whe('FN6_GERANF') })
	oStrFN6:SetProperty('FN6_CLIENT'	,MODEL_FIELD_WHEN, {|| AF036X3Whe('FN6_CLIENT') })
	oStrFN6:SetProperty('FN6_LOJA'		,MODEL_FIELD_WHEN, {|| AF036X3Whe('FN6_LOJA') })
	oStrFN6:SetProperty('FN6_VALNF'		,MODEL_FIELD_WHEN, {|| AF036X3Whe('FN6_VALNF') })
	oStrFN6:SetProperty('FN6_CNDPAG'	,MODEL_FIELD_WHEN, {|| AF036X3Whe('FN6_CNDPAG') })
	oStrFN6:SetProperty('FN6_TESSAI'	,MODEL_FIELD_WHEN, {|| AF036X3Whe('FN6_TESSAI') })
	If lIsRussia
		oStrFN6:SetProperty(;
			'FN6_SOCURR',;
			MODEL_FIELD_WHEN,;
			{|| AF036X3Whe('FN6_SOCURR')})
	EndIf
	oStrFN6:SetProperty('FN6_NATURE'	,MODEL_FIELD_WHEN, {|| AF036X3Whe('FN6_NATURE') })
	If cPaisLoc == "MEX"
		oStrFN6:SetProperty('FN6_USOCFD'	,MODEL_FIELD_WHEN, {|| AF036X3Whe('FN6_USOCFD') })
	EndIf
	If cPaisLoc == "PER" .And. lExisCpo
		oStrFN6:SetProperty('FN6_TPDOC'	,MODEL_FIELD_WHEN, {|| AF036X3Whe('FN6_TPDOC') })
		oStrFN6:SetProperty('FN6_TIPONF',MODEL_FIELD_WHEN, {|| AF036X3Whe('FN6_TIPONF') })
	EndIf
	If cPaisLoc == "COL" .And. lExisCpo
		oStrFN6:SetProperty('FN6_CODMUN',MODEL_FIELD_WHEN, {|| AF036X3Whe('FN6_CODMUN') })
		oStrFN6:SetProperty('FN6_TPACTI',MODEL_FIELD_WHEN, {|| AF036X3Whe('FN6_TPACTI') })
		oStrFN6:SetProperty('FN6_TRMPAC',MODEL_FIELD_WHEN, {|| AF036X3Whe('FN6_TRMPAC') })
		oStrFN6:SetProperty('FN6_TIPOPE',MODEL_FIELD_WHEN, {|| AF036X3Whe('FN6_TIPOPE') })
	EndIf

ElseIf __nOper == OPER_CANC
	oStrFN6:SetProperty( '*' ,MODEL_FIELD_WHEN, {|| .F. } )
EndIf

If lVisMotBx
	
	aAreaSX3 := SX3->(GetArea())

	SX3->(dbSetOrder(2))	
	If SX3->(dbSeek("FN6_MOTIVO"))
		cTituloFN6 := X3TITULO()
	EndIf

	oStrFN6:AddField( 	cTituloFN6        				  			, ; // [01]  C   Titulo do campo 
						cTituloFN6				          			, ; // [02]  C   ToolTip do campo 
						'FN6MOTIVO'                      			, ; // [03]  C   identificador (ID) do Field 
						'C'                              			, ; // [04]  C   Tipo do campo 
						TAMSX3('FN6_MOTIVO')[1]         		 	, ; // [05]  N   Tamanho do campo 
						TAMSX3('FN6_MOTIVO')[2]          			, ; // [06]  N   Decimal do campo 
						FwBuildFeature(STRUCT_FEATURE_VALID,".T.")	, ; // [07]  B   Code-block de validação do campo 
						Nil											, ; // [08]  B   Code-block de validação When do campo 
						{} 					               			, ; // [09]  A   Lista de valores permitido do campo 
						.T.                              			, ; // [10]  L   Indica se o campo tem preenchimento obrigatório 
						FwBuildFeature(STRUCT_FEATURE_INIPAD,"FN6->FN6_MOTIVO"), ; // [11]  B   Code-block de inicializacao do campo 
						Nil                              			, ; // [12]  L   Indica se trata de um campo chave 
						Nil     			                        , ; // [13]  L   Indica se o campo pode receber valor em uma operação de update. 
						.T.                   				        )   // [14]  L   Indica se o campo é virtual 
	RestArea(aAreaSX3)

EndIf

Return oStrFN6

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036StTip

Gatilhos Tabela FN7 - FN7TIPO

@author felipe.cunha
@since 14/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036StTip()
Local oStr2	:= FWFormStruct( 1, "FN7", /*bAvalCampo*/, /*lViewUsado*/ )

/*
 * Gatilhos
 */
oStr2:AddTrigger( 'OK', 'OK', { || .T. } , {|oMdl| AF036DtBx(/* lDesmarca */, /* lDtLote */, oMdl:GetModel())  } )
If lIsRussia
	oStr2:AddField(	 	;
	"VRACUMVAL"				, ;	// [01] Title of the field		//"Actual accumulated of depreciation"
	"VRACUMVAL"				, ;	// [02] Description of the field	//"Actual accumulated of depreciation"
	"VRACUMVAL"				, ;	// [03] Id of the field
	"N"						, ;	// [04] Type
	TamSX3("N3_VRDACM1")[1]	, ;	// [05] Size
	TamSX3("N3_VRDACM1")[2]	, ;	// [06] Decimal places
	{ || .T. }				, ;	// [07] Validation
							, ;	// [08] When
							, ;	// [09] Allowed values
							.F.)// [10] Mandatory
EndiF

Return oStr2

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036StVal

Gatilhos Gatilhos Tabela FN7 - FN7VALOR

@author felipe.cunha
@since 14/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036StVal()
Local oStrFN7	:= FWFormStruct( 1, "FN7", /*bAvalCampo*/, /*lViewUsado*/ )

oStrFN7:AddTrigger( 'FN7_PERCBX', 'FN7_PERCBX', { || .T. } , {|| AF036GatVl('FN7_PERCBX') } )
oStrFN7:AddTrigger( 'FN7_VLBAIX', 'FN7_VLBAIX', { || .T. } , {|| AF036GatVl('FN7_VLBAIX') } )

Return oStrFN7

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036GatQt

Calculo  do percentual a ser baixado sobre a quantidade informada
Este calculo, não atualiza o campo FN6_BAIXA

@author felipe.cunha
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036GatQt(cCpoOrig, oMdl)
Local aArea			:= GetArea()
Local aSN1Area		:= SN1->(GetArea())
Local aSN3Area		:= SN3->(GetArea())
Local oModel		:= IIf(Empty(oMdl), FWModelActive(), oMdl)
Local oView			:= FWViewActive()

Local lBxLote		:= FWIsInCallStack("AF036BxLote") .or. lAtf030
Local oModelMaster	:= oModel:GetModel(IIf(lBxLote,"FN6ATIVOS", "FN6MASTER"))
Local oModelTipo	:= oModel:GetModel('FN7TIPO')
Local nOrig			:= oModelMaster:GetValue("FN6_QTDATU") 	//Quantidade Original
Local nQuant		:= oModelMaster:GetValue("FN6_QTDBX" ) 	//Quantidade a Ser Baixada
Local nPerBaixa		:= oModelMaster:GetValue("FN6_BAIXA" ) 	//% a Ser Baixada
Local nContTipo		:= 0
Local lAltera		:= .F.
Local cRet			:= oModelMaster:GetValue(cCpoOrig)
Local lMostraVal 	:= .T.

If lBxLote
	If __nOper == OPER_BXLOT .And. cPaisLoc == "BRA" .And. Type("mv_par12") == "N"
		lMostraVal := (MV_PAR12==1)
	EndIf
EndIf

If Type("lRusConfirmations") <> "L"
	lRusConfirmations	:= ! __lRotAuto
EndIf

If cCpoOrig == "FN6_BAIXA"	
	If !isBlind() .And. !lBxLote .And. lRusConfirmations
		lAltera := MsgYesNo(STR0135)//"Deseja alterar a quantidade de baixa?"
	ElseIf lBxLote
		lAltera := .T.
	ElseIf ! lRusConfirmations
		lAltera	:= .T.	
	EndIf
	
	//Atualiza valor percentual para atualizar grid FN7VALOR
	If lAltera
		nQuant := IIf(nPerBaixa > 0,(nPerBaixa/100) * nOrig , 0)
		oModelMaster:LoadValue("FN6_QTDBX" , nQuant )
	EndIf
	SN3->(dbSetOrder( 1 ) )
	
	//Atualiza os valores de baixa, baseados no novo percentual informado
	oModelMaster:LoadValue("FN6_PERCBX" , nPerBaixa )
		
	For nContTipo := 1 to oModelTipo:Length()
		oModelTipo:GoLine( nContTipo )
		AF036ATU(oModel, nPerBaixa )
	Next nContTipo
	
ElseIf cCpoOrig == "FN6_QTDBX"
	If !isBlind() .And. !lBxLote .And. !(lIsRussia .And. __lRotAuto)
		lAltera := MsgYesNo(STR0136)//"Deseja alterar o percentual da baixa ?"
	Else
		lAltera := .T.
	EndIf
	
	If lAltera
		nPerBaixa := IIf(nOrig > 0,(nQuant / nOrig ) * 100 , 0)
		oModelMaster:LoadValue("FN6_BAIXA" , nPerBaixa )
		oModelMaster:LoadValue("FN6_PERCBX" , nPerBaixa )		
		
		//Atualiza os valores de baixa, baseados no novo percentual informado				
		For nContTipo := 1 to oModelTipo:Length()
			oModelTipo:GoLine( nContTipo )
			AF036ATU(oModel, nPerBaixa )
		Next nContTipo		
	EndIf
	
ElseIf cCpoOrig == "FN6_DEPREC"

	//Atualiza os valores de baixa, baseados no novo percentual informado	
	For nContTipo := 1 to oModelTipo:Length()
		oModelTipo:GoLine( nContTipo )
		AF036ATU(oModel, nPerBaixa )
	Next nContTipo
ElseIf cCpoOrig == "FN6_DTBAIX"
	//Atualiza os valores de baixa, baseados no novo percentual informado	
	For nContTipo := 1 to oModelTipo:Length()
		oModelTipo:GoLine( nContTipo )
		AF036ATU(oModel, nPerBaixa )
	Next nContTipo
EndIf

/*
 * Posiciona as grids FN7TIPO e FN7VALOR na primeira linha
 */
If lMostraVal
	oModelTipo:GoLine( 1 )
	aF36WhenTp(oModel)
EndIf

RestArea(aArea)
RestArea(aSN1Area)
RestArea(aSN3Area)

If oView != Nil .And. oView:IsActive() .And. !isBlind() .And. lMostraVal
	oView:Refresh()
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036GatBs

Atualiza campos conforme código base. Utilizada quando a rotina é visualizada por baixa

@author alvaro.camillo
@since 03/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036GatBs(cCampo)

Local oModel				:= FWModelActive()
Local oView				:= FWViewActive()
Local oModelMaster		:= oModel:GetModel(If(FWIsInCallStack("AF036BxLote") .or. lAtf030,"FN6ATIVOS", "FN6MASTER"))
Local cRet					:= oModelMaster:GetValue(cCampo )
Local cBase				:= oModelMaster:GetValue("FN6_CBASE")
Local cItem				:= oModelMaster:GetValue("FN6_CITEM")

Local oGridObj		AS OBJECT

SN1->(dbSetOrder(1))//N1_FILIAL+N1_CBASE+N1_ITEM

If !Empty(cBase) .And. !Empty(cItem) .And. SN1->(dbSeek(xFilial("SN1") + cBase + cItem ))

	oModelMaster:LoadValue("FN6_DESCRI"	,SN1->N1_DESCRIC)
	oModelMaster:LoadValue("FN6_QTDATU"	,SN1->N1_QUANTD)
	If lIsRussia .And. MV_PAR04 == 1
		lRusConfirmations	:= .F.
	EndIf
	oModelMaster:SetValue("FN6_BAIXA"		,0)

	AF036LOADT(oModel,.T.)
	AF036LOADV(oModel,.T.)
	AF036ATU(oModel,,.T.)

	If lIsRussia .And. MV_PAR04 == 1
		AFA036RUGR(oModel)
		oModelMaster:SetValue("FN6_BAIXA", &(GetSX3Cache("FN6_BAIXA", "X3_RELACAO")))
		lRusConfirmations	:= .T.
	EndIf

	If oView != Nil .And. oView:IsActive() .And. !isBlind()
		If lIsRussia .And. MV_PAR04 == 1
			oGridObj	:= oView:GetViewObj("GRID_TIPOS")[3]
			oGridObj:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)
		EndIf
		oView:Refresh()
	EndIf

EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036GatNf

Atualiza campos conforme seleção da geração de NF

@author jdomingos
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036GatNf()

Local oModel			:= FWModelActive()
Local oModelMaster		:= oModel:GetModel(If(FWIsInCallStack("AF036BxLote") .Or. lAtf030 ,"FN6ATIVOS", "FN6MASTER"))
Local cGeraNf			:= oModelMaster:GetValue("FN6_GERANF" )



oModelMaster:LoadValue("FN6_NUMNF"	,CriaVar("FN6_NUMNF")			)
oModelMaster:LoadValue("FN6_SERIE"	,SerieNfId('FN6',5,'FN6_SERIE')	)
oModelMaster:LoadValue("FN6_CLIENT"	,CriaVar("FN6_CLIENT")			)
oModelMaster:LoadValue("FN6_LOJA"	,CriaVar("FN6_LOJA")			)
oModelMaster:LoadValue("FN6_CNDPAG"	,CriaVar("FN6_CNDPAG")			)
oModelMaster:LoadValue("FN6_TESSAI"	,CriaVar("FN6_TESSAI")			)
oModelMaster:LoadValue("FN6_NATURE"	,CriaVar("FN6_NATURE")			)
If lIsRussia
	oModelMaster:LoadValue("FN6_SOCURR"	,CriaVar("FN6_SOCURR"))
EndIf
If cPaisLoc == "MEX"
	oModelMaster:LoadValue("FN6_USOCFD"	,CriaVar("FN6_USOCFD"))
EndIf
If cPaisLoc == "PER" .And. lExisCpo
	oModelMaster:LoadValue("FN6_TPDOC"	,CriaVar("FN6_TPDOC"))
	oModelMaster:LoadValue("FN6_TIPONF"	,CriaVar("FN6_TIPONF"))
EndIf
If cPaisLoc == "COL" .And. lExisCpo
	oModelMaster:LoadValue("FN6_CODMUN"	,CriaVar("FN6_CODMUN"))
	oModelMaster:LoadValue("FN6_TPACTI"	,CriaVar("FN6_TPACTI"))
	oModelMaster:LoadValue("FN6_TRMPAC"	,CriaVar("FN6_TRMPAC"))
	oModelMaster:LoadValue("FN6_TIPOPE"	,CriaVar("FN6_TIPOPE"))
EndIf

Return cGeraNf

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036GatMt

Atualiza campos conforme seleção do Motivo da baixa

@author jdomingos
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036GatMt()
Local oModel			:= FWModelActive()
Local oModelMaster 	:= oModel:GetModel(If(FWIsInCallStack("AF036BxLote") .Or. lAtf030,"FN6ATIVOS", "FN6MASTER"))
Local oModelFN7		:= oModel:GetModel('FN7TIPO')
Local cMotivo			:= oModelMaster:GetValue("FN6_MOTIVO" )
Local nY				:= 1

//--------------------------------------------------------------------------------------
// No preenchimento/alteração do motivo da baixa limpa os dados relativos a Nota Fiscal
//--------------------------------------------------------------------------------------
oModelMaster:LoadValue("FN6_VALNF"	,0								)
oModelMaster:LoadValue("FN6_GERANF"	,"2"							)
oModelMaster:LoadValue("FN6_NUMNF"	,CriaVar("FN6_NUMNF")			)
oModelMaster:LoadValue("FN6_SERIE"	,SerieNfId('FN6',5,'FN6_SERIE')	)
oModelMaster:LoadValue("FN6_CLIENT"	,CriaVar("FN6_CLIENT")			)
oModelMaster:LoadValue("FN6_LOJA"	,CriaVar("FN6_LOJA")			)
oModelMaster:LoadValue("FN6_CNDPAG"	,CriaVar("FN6_CNDPAG")			)
oModelMaster:LoadValue("FN6_TESSAI"	,CriaVar("FN6_TESSAI")			)
oModelMaster:LoadValue("FN6_NATURE"	,CriaVar("FN6_NATURE")			)
If lIsRussia
	oModelMaster:LoadValue("FN6_SOCURR", CriaVar("FN6_SOCURR"))
EndIf
If cPaisLoc == "MEX"
	oModelMaster:LoadValue("FN6_USOCFD", CriaVar("FN6_USOCFD"))
EndIf
If cPaisLoc == "PER" .And. lExisCpo
	oModelMaster:LoadValue("FN6_TPDOC", CriaVar("FN6_TPDOC"))
	oModelMaster:LoadValue("FN6_TIPONF", CriaVar("FN6_TIPONF"))
EndIf
If cPaisLoc == "COL" .And. lExisCpo
	oModelMaster:LoadValue("FN6_CODMUN"	,CriaVar("FN6_CODMUN"))
	oModelMaster:LoadValue("FN6_TPACTI"	,CriaVar("FN6_TPACTI"))
	oModelMaster:LoadValue("FN6_TRMPAC"	,CriaVar("FN6_TRMPAC"))
	oModelMaster:LoadValue("FN6_TIPOPE"	,CriaVar("FN6_TIPOPE"))
EndIf

//-------------------------------------------------------------------
// Preenche o motivo da FN7, quando alterado via chamada do ATFA320. 
// caique.ferreira 23/04/2014
//-------------------------------------------------------------------
If FWIsInCallStack('ATFA320') 
	For nY := 1 To oModelFN7:Length()
		oModelFN7:GoLine( nY )
		oModel:SetValue("FN7TIPO","FN7_MOTIVO" ,cMotivo) 
	Next nY  
EndIf

Return cMotivo

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036GatMot

Valida Motivo da Baixa

@author felipe.cunha
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036GatMot()
Local aArea			:= GetArea()
Local aSN3Area		:= {}
Local oModel		:= FWModelActive()
Local oModelMaster	:= oModel:GetModel('FN6MASTER')			// Carrega Model Master
Local lVlVend		:= .T.										// Se habilita campo Valor de Venda
Local cBase			:= oModelMaster:getValue("FN6_CBASE" )	// Carga campo = Codigo Base
Local cItem			:= oModelMaster:getValue("FN6_CITEM" )	// Carga campo = Codigo Item
Local cChave		:= ''										// Chave de Pesquisa
Local aTiposReav	:= {}										// Tipos de Reavaliação
Local nX			:= 0
Local cMotivo		:= oModelMaster:getValue("FN6_MOTIVO")	// Carga campo = Motivo de Baixa
Local cFilSN3		:= XFILIAL('SN3')
Local cTypes10		:= IIF(lIsRussia,"*" + AtfNValMod({1}, "*"),"") // CAZARINI - 14/03/2017 - If is Russia, add new valuations models - main models

DbSelectArea("SN3")
aSN3Area := SN3->(GetArea())
SN3->(dbSetOrder(1))

/*
 * Tipos de reavaliação
 */
AAdd(aTiposReav,"02") // Reavaliacao
AAdd(aTiposReav,"04") // Lei 8.200
AAdd(aTiposReav,"41") // Reavaliação anual de bens não totalmente depreciados
AAdd(aTiposReav,"42") // Reavaliação anual de bens totalmente depreciados
AAdd(aTiposReav,"50") // Colombia: Depreciacao gerencial "metodo linear"
AAdd(aTiposReav,"51") // Colombia: Depreciacao gerencial "soma dos digitos"
AAdd(aTiposReav,"52") // Colombia: Depreciacao gerencial "reducao de saldos"
AAdd(aTiposReav,"53") // Colombia: Depreciacao gerencial "soma dos anos"
AAdd(aTiposReav,"54") // Colombia: Depreciacao gerencial "unidades produzidas"

For nX := 1 to Len(aTiposReav)
	If SN3->(dbSeek(cFilSN3 + cBase + cItem + aTiposReav[nX]))
		lVlVend := .T.
		Exit
	Else
		lVlVend := .F.
	Endif
Next nX

cChave := cFilSN3 + cBase + cItem
SN3->(dbSeek(cChave))

While SN3->(!Eof()) .And. cChave == SN3->N3_FILIAL+SN3->N3_CBASE+SN3->N3_ITEM
	If SN3->N3_TIPO $ ("01*10" + cTypes10)
		If Subs(cMotivo , 1 , 2 ) == '01'
			lVlVend := .T.
			Exit
		Else
			lVlVend := .F.
		Endif
	Else
		lVlVend := .F.
	Endif
	SN3->(dbSkip())
EndDo

/*
 * Zera o Valor de Venda
 */
If !lVlVend
	oModelMaster:SetValue("FN6_VALNF" , CriaVar("FN6_VALNF") )
EndIf

RestArea(aArea)
RestArea(aSN3Area)

Return lVlVend
//-------------------------------------------------------------------
/*/{Protheus.doc} AF036GPerc

Valida Coluna Percentual

@author felipe.cunha
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036GPerc()
Local oModel		:= FWModelActive()
Local oModelValor	:= Nil
Local lRet			:= .T. // Se habilita campo Perc Baixa
Local cTipo			:= ''

If oModel != Nil

	If oModel:IsActive()

		oModelValor := oModel:GetModel('FN7VALOR')
		/*
		 * Carrega o tipo de ativo posicionado no grid FN7TIPO
		 */
		cTipo := oModelValor:GetValue("FN7_TIPO" )

		/*
	 	 * Bloqueia a Alteração do Percentual de Baixa para os ativos do tipo
		 * 14 e 15, será aplicado o percentual do tipo 10/13
		 */ 
		If cTipo $ "14/15"
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} AF036GatVl

Calculo do percentual a ser baixado sobre a quant informada
Este calculo, não atualiza o campo FN6_BAIXA

@author felipe.cunha
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036GatVl(cCpoOrig)

Local oModel		:= FWModelActive()
Local oModelMaster
Local oModelValor
Local oModelTipo
Local nPercVal		:= 0
Local nValor		:= 0
Local nValAtu		:= 0
Local nLineAtu		:= 1
Local cBase			:= ''
Local cItem			:= ''
Local cTipo			:= ''
Local cTipoSald		:= ''
Local nRet			:= 0
Local cTypes10		:= IIF(lIsRussia,"*" + AtfNValMod({1}, "*"),"") // CAZARINI - 14/03/2017 - If is Russia, add new valuations models - main models

If oModel != Nil .AND. oModel:IsActive()

	oModelMaster	:= oModel:GetModel(If(FWIsInCallStack("AF036BxLote") .or. lAtf030,"FN6ATIVOS", "FN6MASTER"))
	oModelValor		:= oModel:GetModel('FN7VALOR')
	oModelTipo		:= oModel:GetModel('FN7TIPO')
	nValAtu			:= oModelValor:GetValue("FN7_VLATU" )
	cBase			:= oModelMaster:GetValue("FN6_CBASE" )
	cItem			:= oModelMaster:GetValue("FN6_CITEM" )
	cTipo			:= oModelValor:GetModel():GetValue("FN7TIPO","FN7_TIPO" )
	cTipoSald		:= oModelValor:GetModel():GetValue("FN7TIPO","FN7_TPSALD" )
	nLineAtu		:= oModelValor:GetLine()
	nLineTip		:= oModelTipo:GetLine()

	If cCpoOrig == "FN7_VLBAIX"

		nPercVal := IIf(nValAtu > 0, (oModelValor:GetValue("FN7_VLBAIX" ) / nValAtu ) * 100 ,0)
		oModelValor:LoadValue("FN7_PERCBX", Round(nPercVal,2) )
		nRet := oModelValor:GetValue("FN7_VLBAIX" ) 

	ElseIf cCpoOrig == "FN7_PERCBX"

		nValor := Round((oModelValor:GetValue("FN7_PERCBX" )/100) * nValAtu ,2)
		oModelValor:LoadValue("FN7_VLBAIX", nValor )
		nRet := oModelValor:GetValue("FN7_PERCBX" )
		nPercVal := nRet
	EndIf

	/*
	* Verifica todos os tipos de ativos existentes para o bem selecionado
	 */
	SN3->( dbSetOrder( 1 ) )
	SN3->( dbSeek( FWxFilial( "SN3" ) + cBase + cItem + cTipo ) )

	/*
	 * Atualiza os valores de baixa, baseados no novo percentual informado
	 */
	AF036ATU(oModel)

	/*
	* Atualiza tipos relacionados
	*/

	If cTipo $ ("10#13" + cTypes10) .And. oModelTipo:SeekLine({{"FN7_TIPO","15"},{"FN7_TPSALD",cTipoSald}})
		oModelValor:GoLine(nLineAtu)
		nValor := Round((nPercVal/100) * oModelValor:GetValue("FN7_VLATU" ) ,2)
		oModelValor:LoadValue("FN7_VLBAIX", nValor )
		AF036ATU(oModel)
	EndIf

	If cTipo $ ("10" + cTypes10) .And. oModelTipo:SeekLine({{"FN7_TIPO","14"},{"FN7_TPSALD",cTipoSald}})
		oModelValor:GoLine(nLineAtu)
		nValor := Round((nPercVal/100) * oModelValor:GetValue("FN7_VLATU" ) ,2)
		oModelValor:LoadValue("FN7_VLBAIX", nValor )
		AF036ATU(oModel)
	EndIf

	oModelTipo:GoLine(nLineTip)
	oModelValor:GoLine(nLineAtu)

EndIf

Return nRet
//-------------------------------------------------------------------
/*/{Protheus.doc} AF036LOADT

Função que retorna a carga da grid de Tipos de Ativos

@author felipe.cunha
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036LOADT(oModel,lLoad)
Local aArea			:= GetArea()
Local oModelPai		:= oModel:GetModel()
Local oModelFN6		:= oModelPai:GetModel(If(FWIsInCallStack("AF036BxLote") .or. lAtf030,"FN6ATIVOS", "FN6MASTER"))
Local oModFN7Tip		:= oModelPai:GetModel("FN7TIPO")
Local oView			:= FWViewActive()
Local aSN1Area		:= {}
Local aSN3Area		:= {}
Local aFN6Area		:= {}
Local aFN7Area		:= {}
Local aRetTip			:= {}
Local cChave 			:= ''
Local cFilSN3			:= xFilial("SN3")
Local cFilFN7			:= xFilial("FN7")
Local nCtnItem		:= 1
Local nTamItem		:= TamSX3("FN7_ITEM")[1]
Local aCgTipo			:= {}
Local nLinTip			:= 0
Local nRecnoSN3		:= 0
Local nRURecN3		:= 0

Default lLoad := .F.

DbSelectArea('SN1')
aSN1Area	:= SN1->(GetArea())
DbSelectArea('SN3')
aSN3Area	:= SN3->(GetArea())
DbSelectArea('FN6')
aFN6Area	:= FN6->(GetArea())
DbSelectArea('FN7')
aFN7Area	:= FN7->(GetArea())

nRURecN3	:= SN3->(Recno())

SN1->(dbSetOrder( 1 )) // N1_FILIAL+N1_CBASE+N1_ITEM   
SN3->(dbSetOrder( 1 )) // N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ     

//Baixa Manual do Ativo
If __nOper == OPER_BAIXA

	If !Empty(oModelFN6:GetValue("FN6_CBASE")) .And. !Empty(oModelFN6:GetValue("FN6_CITEM"))
		If MV_PAR04 == 2
			//Pesquisa a SN1 correpondente ao item selecionado
			SN1->(dbSeek( xFilial( "SN1" ) + SN3->N3_CBASE + SN3->N3_ITEM ))
		EndIf

		//Verifica todos os tipos de ativos existentes para o bem selecionado	
		SN3->(dbSeek( cFilSN3 + SN1->N1_CBASE + SN1->N1_ITEM ))

		oModFN7Tip:SetNoInsertLine(.F.)

		//----------------------------------------------------------------------------------------------------------------
		// Limpa a grid de tipos para nao permanecer tipos de outros ativos, quando a seleção é feita via consulta padrão
		//----------------------------------------------------------------------------------------------------------------
		If lLoad
			If oModFN7Tip:Length() > 1
				oModFN7Tip:ClearData(.F.)
			EndIf
		EndIf

		//Carrega array para exibição no grid
		While SN3->(!Eof()) .And. ( cFilSN3 + SN1->N1_CBASE + SN1->N1_ITEM == SN3->N3_FILIAL + SN3->N3_CBASE + SN3->N3_ITEM )
			
			//Must write-off only previous SN3 revaluation register
			If RusCheckRevalFunctions() .And. nRURecN3 <> SN3->(Recno())
				SN3->(dbSkip())
				Loop
			EndIf

			If ( SN3->N3_BAIXA < "1" )
				aAdd(aCgTipo,{"FN7_FILIAL"	,cFilFN7	})
				aAdd(aCgTipo,{"FN7_CODBX"	,oModelFN6:GetValue("FN6_CODBX")	})
				aAdd(aCgTipo,{"FN7_ITEM"	,	PADL(nCtnItem,nTamItem,"0")	})
				aAdd(aCgTipo,{"FN7_CBASE"	,oModelFN6:GetValue("FN6_CBASE")	})

				//Tratamento necessario para quando o ativo é selecionado via F3 MV_PAR04
				If lLoad
					Aadd(aCgTipo,{"FN7_CITEM",SN1->N1_ITEM})
				Else
					Aadd(aCgTipo,{"FN7_CITEM",oModelFN6:GetValue("FN6_CITEM")})
				EndIf

				aAdd(aCgTipo,{"FN7_DESCRI"	,SN3->N3_HISTOR	})
				aAdd(aCgTipo,{"FN7_TIPO"	,SN3->N3_TIPO		})
				aAdd(aCgTipo,{"FN7_TPSALD"	,SN3->N3_TPSALDO	})
				aAdd(aCgTipo,{"FN7_SEQ"		,SN3->N3_SEQ		})
				aAdd(aCgTipo,{"FN7_MOEDA"	,'01'				})
				aAdd(aCgTipo,{"FN7_SEQREA"	,SN3->N3_SEQREAV	})
				aAdd(aCgTipo,{"FN7_MOTIVO"	,oModelFN6:GetValue("FN6_MOTIVO")	})
				aAdd(aCgTipo,{"FN7_DTBAIX"	,oModelFN6:GetValue("FN6_DTBAIX")	})
				aAdd(aCgTipo,{"FN7_VLATU"	,0	})
				aAdd(aCgTipo,{"FN7_VLDEPR"	,0	})
				aAdd(aCgTipo,{"FN7_VLBAIX"	,0	})
				aAdd(aCgTipo,{"FN7_PERCBX"	,0	})
				aAdd(aCgTipo,{"FN7_STATUS"	,oModelFN6:GetValue("FN6_STATUS")	})
				aAdd(aCgTipo,{"FN7_FILORI"	, oModelFN6:GetValue("FN6_FILORI")		})
				aAdd(aCgTipo,{"FN7_VLRESI"	,0			})

				If lIsRussia
					aAdd(aCgTipo,{"FN7_VORIG"	, SN3->N3_VORIG1})
					Aadd(aCgTipo,{"FN7_AMPLIA", SN3->N3_AMPLIA1})
					aAdd(aCgTipo,{"FN7_CALCDP"	, 0})
					aAdd(aCgTipo,{"VRACUMVAL", SN3->N3_VRDACM1})
					aAdd(aCgTipo,{"FN7_VRDACM"	, SN3->N3_VRDACM1})
					aAdd(aCgTipo,{"FN7_CARRYV"	, ;
						SN3->(N3_VORIG1+N3_AMPLIA1-N3_VRDACM1)})
					
					Aadd(aCgTipo,{"FN7_INCOST", SN3->N3_INCOST}) //Init cost
				EndIf

				aAdd(aCgTipo,{"UPDATE"		,.F.		})

				aAdd(aRetTip,{ 0, Af36MntFN7(oModelPai,aCgTipo,'FN7TIPO') })

				//--------------------------------------------------
				// Realiza a carga do modelo quando o MV_PAR04 == 2
				// e o usuario faz a selecao do bem desejado via F3
				//--------------------------------------------------
				If lLoad

					If nCtnItem > oModFN7Tip:Length()
						nRecnoSN3 := SN3->(Recno())
						oModFN7Tip:AddLine()
						SN3->(DbGoTo(nRecnoSN3))
					EndIf

					oModFN7Tip:GoLine(nCtnItem)

					For nLinTip := 1 To Len(aCgTipo)
						If "FN7_" $ aCgTipo[nLinTip][1]
							oModFN7Tip:SetValue(aCgTipo[nLinTip][1],aCgTipo[nLinTip][2])
						EndIf
					Next nLinTip

				EndIf

				aCgTipo := aSize(aCgTipo,0)

				nCtnItem++
			EndIf

		SN3->(dbSkip())  
		EndDo

		//Posiciona na primeira linha para correta alimentação da grid de valores
		If lLoad
			oModFN7Tip:GoLine(1)
		EndIf

		oModFN7Tip:SetNoInsertLine(.T.)
	EndIf

ElseIf __nOper == OPER_CANC .Or. __nOper == OPER_VISUA 
	DbSelectArea("FN7")
	FN7->(DbSetOrder(1)) // Filial + Código da baixa + Item
	If MV_PAR04 == 1
		dbSelectArea( "SN3" )
		SN3->(dbSetOrder( 1 ))
		SN3->(dbSeek( cFilSN3 + FN6->FN6_CBASE + FN6->FN6_CITEM ))		
		cChave := cFilFN7 + FN6->FN6_CODBX
	ElseIf MV_PAR04 == 2
		If FWModeAccess("SN3",3) == 'E'// Quando o ambiente é totalmente exclusivo
			cFILBem := IIF(!Empty(SN3->N3_FILORIG),SN3->N3_FILORIG,SN3->N3_FILIAL)
		Else
			cFILBem := xFilial('SN3')
		End
		aRet    := A036ULTCOD(SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_TPSALDO,cFILBem,Nil,.T.,SN3->N3_SEQ)
		cFilFN7 := aRet[1]
		cCodBX  := aRet[2] 
		cChave  := cFilFN7 + cCodBX
	ElseIf MV_PAR04 == 3		
		aRet    := A036ULTCOD(SN1->N1_CBASE,SN1->N1_ITEM,,,SN1->N1_FILIAL,"SN1",.T.)
		cFilFN7 := aRet[1]
		cCodBX  := aRet[2] 
		cChave := cFilFN7 + cCodBX
		FN7->(DbSetOrder(1))
	EndIf

	If FN7->(DbSeek(cChave))
		//Pesquisa a SN1 correpondente ao item selecionado
		dbSelectArea( "SN1" )
		SN1->(dbSetOrder( 1 )) // Filial + Código Base + Item Base
		SN1->(dbSeek( xFilial( "SN1" ) + SN3->N3_CBASE + SN3->N3_ITEM ))

		While FN7->(!Eof()) .And. ( cChave == FN7->FN7_FILIAL + FN7->FN7_CODBX )
			If __nOper == OPER_VISUA  .OR. (__nOper == OPER_CANC .AND. FN7->FN7_STATUS == '1')
				If aScan(aRetTip, {| campo | campo[2][7] == FN7->FN7_TIPO } ) == 0 .And. FN7->FN7_MOEDA == "01"
					
					aAdd(aCgTipo,{"FN7_FILIAL"	,FN7->FN7_FILIAL	})
					aAdd(aCgTipo,{"FN7_CODBX"	,FN7->FN7_CODBX		})
					aAdd(aCgTipo,{"FN7_ITEM"	,FN7->FN7_ITEM		})
					aAdd(aCgTipo,{"FN7_CBASE"	,FN7->FN7_CBASE		})
					aAdd(aCgTipo,{"FN7_CITEM"	,FN7->FN7_CITEM		})
					aAdd(aCgTipo,{"FN7_DESCRI"	,GetAdvFVal("SN3","N3_HISTOR",cFilSN3+FN7->FN7_CBASE+FN7->FN7_CITEM+FN7->FN7_TIPO ,1,"")	})
					aAdd(aCgTipo,{"FN7_TIPO"	,FN7->FN7_TIPO		})
					aAdd(aCgTipo,{"FN7_TPSALD"	,FN7->FN7_TPSALD	})
					aAdd(aCgTipo,{"FN7_SEQ"	,FN7->FN7_SEQ		})
					aAdd(aCgTipo,{"FN7_MOEDA"	,FN7->FN7_MOEDA	})
					aAdd(aCgTipo,{"FN7_SEQREA"	,FN7->FN7_SEQREA	})
					aAdd(aCgTipo,{"FN7_MOTIVO"	,FN7->FN7_MOTIVO	})
					aAdd(aCgTipo,{"FN7_DTBAIX"	,FN7->FN7_DTBAIX	})
					aAdd(aCgTipo,{"FN7_VLATU"	,FN7->FN7_VLATU	})
					aAdd(aCgTipo,{"FN7_VLDEPR"	,FN7->FN7_VLDEPR	})
					aAdd(aCgTipo,{"FN7_VLBAIX"	,FN7->FN7_VLBAIX	})
					aAdd(aCgTipo,{"FN7_PERCBX"	,FN7->FN7_PERCBX	})
					aAdd(aCgTipo,{"FN7_STATUS"	,FN7->FN7_STATUS	})
					aAdd(aCgTipo,{"FN7_FILORI"	,FN7->FN7_FILORI	})
					aAdd(aCgTipo,{"FN7_VLRESI"	,FN7->FN7_VLRESI	})
					
					If lIsRussia
						aDFields := GetAdvFVal("SN3",{"N3_VORIG1","N3_AMPLIA1","N3_VRDACM1"},cFilSN3+FN7->FN7_CBASE+FN7->FN7_CITEM+FN7->FN7_TIPO ,1,"")
						aAdd(aCgTipo,{"FN7_VORIG"	, aDFields[1]+aDFields[2]})
						aAdd(aCgTipo,{"FN7_CALCDP"	, 0})
						aAdd(aCgTipo,{"VRACUMVAL"	, aDFields[3]})
						aAdd(aCgTipo,{"FN7_VRDACM"	, aDFields[3]})
						aAdd(aCgTipo,{"FN7_CARRYV"	, aDFields[1]+aDFields[2]+aDFields[3]})
					EndIf

					aAdd(aCgTipo,{"UPDATE"		,.T.	})
	
					aAdd(aRetTip,{ 0, Af36MntFN7(oModelPai,aCgTipo,'FN7TIPO') })
	
					aCgTipo := aSize(aCgTipo,0)
	
				EndIf
			EndIf
			FN7->(DbSkip())
		EndDo
	Else
		Help(" ",1,"A036NOREG",,STR0126,1,0) //"Nenhum registro de baixa encontrado."
		oView:SetViewCanActivate( { || .F. })
	EndIf

EndIf

RestArea(aArea)
RestArea(aSN1Area)
RestArea(aSN3Area)
RestArea(aFN6Area)
RestArea(aFN7Area)

Return aRetTip 
//-------------------------------------------------------------------
/*/{Protheus.doc} Af36MntFN7

Função que monta a carga da grid da FN7

@author jdomingos
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function Af36MntFN7(oModel,aFN7,cModelFN7)

Local oModelFN7	:= If(cModelFN7 == "FN7VALOR",oModel:GetModel("FN7TIPO"),oModel:GetModel("FN7TIPO"))
Local aCpoFN7	:= oModelFN7:GetStruct():GetFields()
Local nCampo	:= 0

aRetorno := Array(Len(aCpoFN7))

//Carrega Cabeçalho 
For nCampo := 1 To Len( aFN7 )
	If ( nPos := aScan( aCpoFN7, { |x| AllTrim( x[3] ) ==  AllTrim( aFN7[nCampo][1] ) } ) ) > 0
		If aFN7[nCampo][2] <> Nil
			aRetorno[nPos]:= aFN7[nCampo][2]
		EndIf
	EndIf
Next nCampo

aRetorno[Len(aRetorno)] := aFN7[Len(aFN7)][2]

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036MARK

Função de validação da marca do ativo

@author felipe.cunha
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036MARK()
Local aArea			:= GetArea() 
Local aSN3Area 		:= SN3->(GetArea())
Local oModel			:= FWModelActive()
Local oView			:= FWViewActive()
Local oModelMaster 	:= oModel:GetModel('FN6MASTER')			// Carrega Model Master
Local oModelTipo 		:= oModel:GetModel('FN7TIPO')			// Carrega Model TIPO
Local cBase			:= oModelMaster:GetValue("FN6_CBASE")	// Codigo Base
Local cItem			:= oModelMaster:GetValue("FN6_CITEM")	// Codigo Item
Local cTipo			:= oModelTipo:GetValue("FN7_TIPO" 	)	// Tipo de Ativo
Local cTpSaldo		:= oModelTipo:GetValue("FN7_TPSALD" )	// Tipo de Saldo

Local aSaveLines 		:= FWSaveRows()
Local lRet 			:= .T.
Local nX				:= 0
Local lMarcardo		:= oModelTipo:GetValue("OK")
Local cMarcaTipo		:= ""
Local cTypes10		:= IIF(lIsRussia,"*" + AtfNValMod({1}, "*"),"") // CAZARINI - 14/03/2017 - If is Russia, add new valuations models - main models

If __nOper != OPER_VISUA .AND.  __nOper != OPER_CANC
	
	dbSelectArea("SN3")
	
	SN3->(DBSetOrder(11)) // Filial + Código Base + Item Base + Tipo Ativo + Baixa do Ativo + Tipo de Saldo
	SN3->(dbSeek( xFilial("SN3") + cBase + cItem + cTipo + If(__nOper != OPER_CANC,"0","1") + cTpSaldo ))
	
	If lRet .And. Empty(SN3->N3_CCONTAB)
		Help(" ",1,"A036CTAV",,STR0023,1,0) //Este bem nao tem a conta do bem preenchida. Verifique se ja foi classifcado
		oModelTipo:LoadValue("OK" , .F. )
		lRet := .F.
	EndIf
	
	If Upper(AllTrim(SN3->N3_TPDEPR)) == "A"
		lRet := ATFVALIND()
		oModelTipo:LoadValue("OK" , lRet )
	EndIf
	
	If lRet .And. cTipo == '14'
		Help(" ",1,"ATFNO14" ,,STR0024,1,0)//"Os registos do Tipo 14 somente poderão ser seleccionados através do Tipo 10. Seleccione o Tipo 10 e o Tipo 14 será seleccionado automaticamente para o processo."
		lRet := .F.
	EndIf
	
	If lRet .And. cTipo == '15'
		Help(" ",1,"ATFNO15" ,,STR0025,1,0)//"Os registos do Tipo 14 somente poderão ser seleccionados através do Tipo 10. Seleccione o Tipo 10 e o Tipo 14 será seleccionado automaticamente para o processo."
		lRet := .F.
	EndIf
	
	If lRet
		If cTipo $ ("10" + cTypes10)
			cMarcaTipo := "14#15"
		ElseIf cTipo == "13"
			cMarcaTipo := "15"
		EndIf
		
		If !Empty(cMarcaTipo)
			For nX := 1 to oModelTipo:Length()
				oModelTipo:Goline( nx )
				If oModelTipo:GetValue("FN7_TIPO") $ cMarcaTipo .And. oModelTipo:GetValue("FN7_TPSALD") == cTpSaldo
					oModelTipo:LoadValue("OK" , lMarcardo )
					lRet := .T.
				EndIf
			Next nX
		Endif
	EndIf
	
ElseIF	 __nOper == OPER_CANC
	If lRet
		Help(" ",1,"CANBX" ,,STR0132,1,0)//"No cancelamento da baixa, não é possivel selecionar o tipo de bem"
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf

FWRestRows(aSaveLines)

If oView != Nil .And. oView:IsActive()
	oView:Refresh()
EndIf


RestArea(aArea)
RestArea(aSN3Area)


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036LOADV

Função que retorna a carga da grid de Valor de Ativos

@author felipe.cunha
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036LOADV(oModel,lLoad)
Local oModelPai 	:= oModel:GetModel()	// Carrega Model Master
Local oModelFN6 	:= oModelPai:GetModel('FN6MASTER')	// Carrega Model Master
Local oModelTipo	:= oModelPai:GetModel('FN7TIPO')
Local oModelValor	:= oModelPai:GetModel('FN7VALOR')
Local aArea		:= GetArea()  
Local aRetVal		:= {}
Local cBase		:= ''
Local cItem		:= ''
Local cTipo		:= ''
Local nX			:= 0
Local nTamMoeda	:= TamSX3("FN7_MOEDA")[1]
Local nTamItem	:= TamSX3("FN7_ITEM")[1]
Local cFilFN7		:= oModelTipo:GetValue("FN7_FILIAL")
Local cFilSN1		:= FWxFilial("SN1")
Local cFilSN3		:= FWxFilial("SN3")
Local nQtdMoedas	:= AtfMoedas()
Local cChave		:= ''
Local aCgTipo		:= {}
Local nLinTip		:= 0

Default lLoad		:= .F.

//Branch of FN7 must follow up branch of SN3
If lIsRussia
	cFilFN7		:= FWxFilial("FN7", IIf(Empty(cFilSN3), Nil, cFilSN3))
EndIf

/*
 * Baixa Manual do Ativo
 */
If __nOper == OPER_BAIXA

	If MV_PAR04 == 2
		//Pesquisa a SN1 correpondente ao item selecionado
		SN1->(dbSeek( xFilial( "SN1" ) + SN3->N3_CBASE + SN3->N3_ITEM ))
	EndIf

	//Verifica todos os tipos de ativos existentes para o bem selecionado	
	If  (MV_PAR04 == 2 .Or. MV_PAR04 == 3 .Or. lLoad) .And. ! RusCheckRevalFunctions()
		SN3->(dbSeek( cFilSN3 + SN1->N1_CBASE + SN1->N1_ITEM ))
	EndIf

	oModelValor:SetNoInsertLine(.F.)
	oModelValor:SetNoUpdateLine(.F.)

	For nX := 1 to nQtdMoedas

		aAdd(aCgTipo,{"FN7_FILIAL"	,cFilFN7	})
		aAdd(aCgTipo,{"FN7_CODBX"	,oModelFN6:GetValue("FN6_CODBX" )	})
		aAdd(aCgTipo,{"FN7_ITEM"	,	PADL(nX,nTamItem,"0")	})	
		aAdd(aCgTipo,{"FN7_CBASE"	,oModelFN6:GetValue("FN6_CBASE" )	})

		//Tratamento necessario para quando o ativo é selecionado via F3 MV_PAR04
		If lLoad
			Aadd(aCgTipo,{"FN7_CITEM",SN1->N1_ITEM})
		Else
			Aadd(aCgTipo,{"FN7_CITEM",oModelFN6:GetValue("FN6_CITEM")})
		EndIf

		aAdd(aCgTipo,{"FN7_DESCRI"	,SN3->N3_HISTOR	})
		aAdd(aCgTipo,{"FN7_TIPO"		,oModelTipo:GetValue("FN7_TIPO")})
		aAdd(aCgTipo,{"FN7_TPSALD"	,oModelTipo:GetValue("FN7_TPSALD")	})
		aAdd(aCgTipo,{"FN7_SEQ"		,oModelTipo:GetValue("FN7_SEQ")	})
		aAdd(aCgTipo,{"FN7_MOEDA"	,PADL(nX,nTamMoeda, "0")	})
		aAdd(aCgTipo,{"FN7_SEQREA"	,oModelTipo:GetValue("FN7_SEQREA")	})
		aAdd(aCgTipo,{"FN7_MOTIVO"	,oModelFN6:GetValue("FN6_MOTIVO")	})
		aAdd(aCgTipo,{"FN7_DTBAIX"	,oModelFN6:GetValue("FN6_DTBAIX")	})
		aAdd(aCgTipo,{"FN7_VLATU"	,0	})
		aAdd(aCgTipo,{"FN7_VLDEPR"	,0	})
		aAdd(aCgTipo,{"FN7_VLBAIX"	,0	})
		aAdd(aCgTipo,{"FN7_PERCBX"	,0	})
		aAdd(aCgTipo,{"FN7_STATUS"	,'1'	})
		aAdd(aCgTipo,{"FN7_FILORI"	, oModelFN6:GetValue("FN6_FILORI")		})
		aAdd(aCgTipo,{"FN7_VLRESI"	,0	})
		aAdd(aCgTipo,{"UPDATE"		,.F.	})

		aAdd(aRetVal,{ 0, Af36MntFN7(oModelPai,aCgTipo,'FN7VALOR') })

		//--------------------------------------------------
		// Realiza a carga do modelo quando o MV_PAR04 == 2
		// e o usuario faz a selecao do bem desejado via F3
		//--------------------------------------------------
		If lLoad


			If nX > oModelValor:Length()
				oModelValor:AddLine()
			EndIf

			oModelValor:GoLine(nX)

			For nLinTip := 1 To Len(aCgTipo)
				If "FN7_" $ aCgTipo[nLinTip][1]
					oModelValor:SetValue(aCgTipo[nLinTip][1],aCgTipo[nLinTip][2])
				EndIf
			Next nLinTip

		EndIf

		aCgTipo := aSize(aCgTipo,0)

	Next nX
	
	oModelValor:SetNoInsertLine(.T.)
	oModelValor:SetNoUpdateLine(.T.)

ElseIf __nOper == OPER_CANC .Or. __nOper == OPER_VISUA
	If MV_PAR04 == 1
		dbSelectArea( "SN3" )
		SN3->(dbSetOrder( 1 ))
		SN3->(dbSeek( cFilSN3 + FN6->FN6_CBASE + FN6->FN6_CITEM ))
		cChave := cFilFN7 + FN6->FN6_CODBX	
	Else
		cChave := cFilFN7 + oModelFN6:GetValue("FN6_CODBX")	
	EndIf

	FN7->(DbSetOrder(1)) // Filial + Còdigo de Baixa + Item
	If FN7->(DbSeek( cChave ))
		//Pesquisa a SN1 correpondente ao item selecionado
		dbSelectArea( "SN1" )
		SN1->(dbSetOrder( 1 ))
		SN1->(dbSeek( cFilSN1 + SN3->N3_CBASE + SN3->N3_ITEM ))
		cBase 	:= SN1->N1_CBASE
		cItem	:= SN1->N1_ITEM
		cTipo 	:= SN3->N3_TIPO

		While FN7->(!Eof()) .And. ( cChave == FN7->FN7_FILIAL + FN7->FN7_CODBX )  .AND. (__nOper == OPER_VISUA  .OR. (__nOper == OPER_CANC .AND. FN7->FN7_STATUS == '1'))

			cTipo 		:= oModelTipo:GetValue("FN7_TIPO")
			cTpSaldo	:= oModelTipo:GetValue("FN7_TPSALD")
			cSeq		:= oModelTipo:GetValue("FN7_SEQ")
			cSeqReav	:= oModelTipo:GetValue("FN7_SEQREA")

			If cTipo == FN7->FN7_TIPO .And. cTpSaldo == FN7->FN7_TPSALD .And. cSeq == FN7->FN7_SEQ .And. cSeqReav == FN7->FN7_SEQREA
				aAdd(aCgTipo,{"FN7_FILIAL"	,FN7->FN7_FILIAL	})
				aAdd(aCgTipo,{"FN7_CODBX"	,FN7->FN7_CODBX		})
				aAdd(aCgTipo,{"FN7_ITEM"		,FN7->FN7_ITEM		})
				aAdd(aCgTipo,{"FN7_CBASE"	,FN7->FN7_CBASE		})
				aAdd(aCgTipo,{"FN7_CITEM"	,FN7->FN7_CITEM		})
				aAdd(aCgTipo,{"FN7_DESCRI"	,SN3->N3_HISTOR		})
				aAdd(aCgTipo,{"FN7_TIPO"		,FN7->FN7_TIPO		})
				aAdd(aCgTipo,{"FN7_TPSALD"	,FN7->FN7_TPSALD	})
				aAdd(aCgTipo,{"FN7_SEQ"		,FN7->FN7_SEQ		})
				aAdd(aCgTipo,{"FN7_MOEDA"	,FN7->FN7_MOEDA		})
				aAdd(aCgTipo,{"FN7_SEQREA"	,FN7->FN7_SEQREA	})
				aAdd(aCgTipo,{"FN7_MOTIVO"	,FN7->FN7_MOTIVO	})
				aAdd(aCgTipo,{"FN7_DTBAIX"	,FN7->FN7_DTBAIX	})
				aAdd(aCgTipo,{"FN7_VLATU"	,FN7->FN7_VLATU		})
				aAdd(aCgTipo,{"FN7_VLDEPR"	,FN7->FN7_VLDEPR	})
				aAdd(aCgTipo,{"FN7_VLBAIX"	,FN7->FN7_VLBAIX	})
				aAdd(aCgTipo,{"FN7_PERCBX"	,FN7->FN7_PERCBX	})
				aAdd(aCgTipo,{"FN7_STATUS"	,FN7->FN7_STATUS	})
				aAdd(aCgTipo,{"FN7_FILORI"	,FN7->FN7_FILORI	})
				aAdd(aCgTipo,{"FN7_VLRESI"	,FN7->FN7_VLRESI	})
				aAdd(aCgTipo,{"UPDATE"		,.F.				})

				aAdd(aRetVal,{ 0, Af36MntFN7(oModelPai,aCgTipo,'FN7VALOR') })

				aCgTipo := aSize(aCgTipo,0)
			EndIf
			FN7->(DbSkip())
		EndDo
	EndIf

EndIf

RestArea(aArea)						
Return aRetVal

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036ATU

Função que retorna a carga da grid de Valor

@author felipe.cunha
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036ATU(oModel,nPercBx,lLoad,nOperRot)

Local aArea			:= GetARea()
Local oModelPrinci	:= oModel:GetModel()
Local oModelLote	:= Nil
Local oModelMaster	:= Nil
Local oModelTipo	:= oModel:GetModel("FN7TIPO")
Local oModelValor	:= oModel:GetModel('FN7VALOR')
Local oModelAcum	:= oModel:GetModel('VLRACUM')
Local dBaixa036		:= CTOD("  / /  ")
Local dBloqueio		:= CTOD("  / /  ")	// Verifica o bloqueio do bem ou do grupo  
Local dDataI		:= CTOD("  / /  ")	// Primeiro dia do Mes da Baixa
Local dData			:= CTOD("  / /  ") //Data da Baixa
Local nQtdMoedas	:= AtfMoedas()		// Verifica quantidade de moedas
Local nResidual		:= 0 // Valor Residual de Depreciação
Local nTaxaCorr		:= 0 // Taxa para correcao
Local nValCorr		:= 0
Local nValCorDep	:= 0
Local nTaxaMes		:= 0 // Taxa Mensal de Depreciação
Local nTaxaBx		:= 0
Local nPropBase		:= 0
Local nVlrOriSal	:= 0 // Valor original - Valor de salvamento
Local nCusto		:= 0 // Valor Cheio do Ativo (SN3->N3_VORIG1+SN3->N3_VRCACM1+SN3->N3_AMPLIA1)
Local nCustOrig		:= 0 // Valor Cheio do Ativo (SN3->N3_VORIG1+SN3->N3_VRCACM1+SN3->N3_AMPLIA1)
Local nDecTax		:= 0 // Numero de Decimais
Local nDias			:= 0 //???Day(LastDay(dData))				// Numero de dias no mes da baixa
Local nDiasDepr		:= 0 //???Day(dData)						// Numero de dias a depreciar
Local cMoedaAtf		:= GetMV("MV_ATFMOEDA")
Local nMoedaAtf		:= Val(cMoedaAtf)
Local nMoedaVMax	:= Val(GetMv( "MV_ATFMDMX" , .F. , " " ))
Local lVlrMxDp		:= .F.	// Controla Valor Maximo de Depreciação
Local lAtClDepr		:= .F.												// Verifica pela Classificação de Ativo se sofre Depreciação
Local lVlrSalv		:= SN3->N3_TPDEPR=='2'								//Define o valor de salvamento quando é utilizado o método de redução de saldos
Local lAtfctap		:= IIF(GetNewPar("MV_ATFCTAP","0")=="0",.F.,.T.)	// Define se os apontamentos de producao serao realizados pela rotina ATFA110
Local lCalcInd		:= AF050IND()	// Verifica se o método de depreciaco é por indice calculado
Local cTipDepr		:= SuperGetMv("MV_TIPDEPR")
/*
 * Tipo de Depreciação:
 * '0'-Proporcional
 * '1'-Mes Cheio
 * '2'-Mes Posterior (NAO calc deprec de bens baixados no mes de calc)
 * '3'-Ano proporcional com mes de aquisicao proporcional
 * '4'-Ano proporcional com mes de aquisicao cheio
 * '5'-Ano posterior
 */
Local cCalcDep		:= GetNewPar("MV_CALCDEP",'0')				// '0'-Mensal, '1'-Anual
Local cN1TipoNeg	:= Alltrim(SuperGetMv("MV_N1TPNEG",.F.,"")) // Tipos de N1_PATRIM que aceitam Valor originais negativos
Local cN3TipoNeg	:= Alltrim(SuperGetMv("MV_N3TPNEG",.F.,"")) // Tipos de N3_TIPO que aceitam Valor originais negativos
Local cMoeda		:= ''													// cMoeda
Local nTamMoeda		:= TamSX3('FN7_MOEDA')[1]
Local nTamDecim		:= 0
Local lATFA031		:= FWIsInCallStack("ATFA031")
Local cMoed			:= ''
Local aTaxaMes		:= {}
Local aTaxaFat		:= {}

Local nX			:= 0
Local nMoeda		:= 0
Local nLine01		:= 0
Local nLineAux		:= 0
Local nLineTp		:= 0
Local nTxRtFact 	:= 0
Local nTxMedia		:= 0
Local nDiasTx		:= 0
Local aRetVlBol		
Local cMVATFMCCM 	:= GetNewPar("MV_ATFMCCM","M") 
Local cMetodDep 	:= GetNewPar("MV_ATFDPBX","0") 

Local lPropBx		:= .F.
Local cManTypes	    := IIF(lIsRussia,AtfNValMod({1,2,3},"|"),"") 
Local aDepBefMod    := {}
Local cFilShare		:= ""

Default nPercBx		:= Nil
Default lLoad		:= .F.
Default nOperRot	:= 0

//--------------------------------------------------
// Ajuste para a chamada da rotina de baixa em lote
//--------------------------------------------------
If nOperRot <> 0
	__nOper := nOperRot
EndIf 

If __nOper == OPER_BAIXA .Or. __nOper == OPER_BXLOT

	dbSelectArea( "SN3" )
	SN3->( dbSetOrder( 11 ) )//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV

	If lIsRussia
		oModelTipo:SetValue("FN7_PERCBX", nPercBx)
	EndIf

	If oModelPrinci:getid() == "ATFA036L"
		oModelLote   := oModel:GetModel("FN8LOTE")
		oModelMaster := oModel:GetModel('FN6ATIVOS')
		nLineTp      := oModelTipo:GetLine()
		cFilShare	 := oModelMaster:GetValue("FN6_FILORI")
		cFilShare	 := FwxFilial("SN3",cFilShare)
		SN3->( dbSeek( cFilShare + oModelTipo:GetValue("FN7_CBASE",nLineTp) + oModelTipo:GetValue("FN7_CITEM",nLineTp) + oModelTipo:GetValue("FN7_TIPO",nLineTp) + "0" + oModelTipo:GetValue("FN7_TPSALD",nLineTp) + oModelTipo:GetValue("FN7_SEQ",nLineTp) + oModelTipo:GetValue("FN7_SEQREA",nLineTp)) )
		dBaixa036	:= oModelLote:GetValue('FN8_DTBAIX')
	ElseIf oModelPrinci:getid() == "ATFA036"
		nLineTp 		:= oModelTipo:GetLine()
		oModelMaster	:= oModel:GetModel('FN6MASTER')

		If lLoad .And. ! RusCheckRevalFunctions()
			SN3->( DbSeek( xFilial( "SN3" ) + SN1->N1_CBASE + SN1->N1_ITEM ) )
		ElseIf ! RusCheckRevalFunctions()
			SN3->( dbSeek( xFilial( "SN3" ) + oModelTipo:GetValue("FN7_CBASE",nLineTp) + oModelTipo:GetValue("FN7_CITEM",nLineTp) + oModelTipo:GetValue("FN7_TIPO",nLineTp) + "0" + oModelTipo:GetValue("FN7_TPSALD",nLineTp) + oModelTipo:GetValue("FN7_SEQ",nLineTp) + oModelTipo:GetValue("FN7_SEQREA",nLineTp) ) )
		EndIf

		dBaixa036	:= oModelMaster:GetValue('FN6_DTBAIX')
	EndIf

	lPropBx := (oModelMaster:GetValue('FN6_DEPREC') == "1") .and.( IIF((cPaisLoc=="BOL" .and. SN3->N3_TPDEPR =="5" .and. cMetodDep =='1'),.F.,.T.) )
	
	dData 		:= dBaixa036
	nDias		:= Day(LastDay(dData))
	nDiasDepr	:= Iif(lPropBx,Day(dData),nDias)

	/*
	* Moeda utilizada no método de depreciação com valor máximo
	*/
	If nMoedaVMax == 0
		nMoedaVMax := Val( cMoedaAtf )
	EndIf

	aTaxaMes := AtfMultMoe("SN3","N3_TXDEPR")

	If lIsRussia .and. oModelMaster:GetValue("FN6_DEPREC")=="2" .and. (SN3->N3_TIPO $ cManTypes)
		nTxRtFact := SN3->N3_PERDEPR/(SN3->N3_PERDEPR - RU01XFUN02_MonthBeforeModer(SN3->N3_CBASE, SN3->N3_ITEM, SN3->N3_TIPO, SN3->N3_SEQ))
		For nX := 1 to Len(aTaxaMes)
			aTaxaMes[nX] := Round(aTaxaMes[nX]*nTxRtFact, TAMSX3('N3_TXDEPR1')[2])
		Next nX
		aTaxaFat :=	AFatorCalc(aTaxaMes, SN3->N3_DINDEPR, dData, cTipDepr, cCalcDep, .T.)
		aDepBefMod	:= AtfMultMoe(,,{|x| 0})
		If !(SN3->N3_TIPO $ "01")
			aDepBefMod := RU01XFUN01_AccumDeprBeforeModer(SN3->N3_CBASE, SN3->N3_ITEM, SN3->N3_TIPO, SN3->N3_SEQ, dDatabase)
		EndIf
	EndIf 

	For nX := 1 to nQtdMoedas

		If !oModelAcum:SeekLine({{"TPATIVO",SN3->N3_TIPO},{"TPSALDO",SN3->N3_TPSALDO},{"MOEDA",PADL(nX, nTamMoeda,"0")}})
			If nX > 1 .And. oModelAcum:Length() < nQtdMoedas
				oModelAcum:AddLine()
			Else
				oModelAcum:GoLine(nX)
			EndIf

			oModelAcum:SetValue("MOEDA",PADL(nX, nTamMoeda,"0"))
			oModelAcum:SetValue("TPATIVO",SN3->N3_TIPO)
			oModelAcum:SetValue("TPSALDO",SN3->N3_TPSALDO)
		EndIf

		oModelAcum:SetValue("TAXAMES", aTaxaMes[nX] )		
		oModelAcum:SetValue("DEPREC",0)
		oModelAcum:SetValue("VLRDEP",0)
		oModelAcum:SetValue("DIFERE",0)

		If lIsRussia ;
			.And. Empty(nPercBx) ;
			.And. __nOper == OPER_BXLOT ;
			.And. oModel:GetModel('PARAMETROS'):GetValue("DEPRBONUS") == 1 ;
			.And. !Empty(oModelValor:GetValue("FN7_PERCBX"))
			nPercBx	:= oModelValor:GetValue("FN7_PERCBX")
		EndIf
		If nPercBx == Nil
			IF nX <= oModelValor:Length() 
				oModelAcum:SetValue("PERCBAIX", ((oModelValor:GetValue("FN7_VLBAIX",nX) / oModelValor:GetValue("FN7_VLATU",nX))  * 100))	
			Else
				oModelAcum:SetValue("PERCBAIX", 0 )
			EndIf
		Else
			oModelAcum:SetValue("PERCBAIX",nPercBx)
		EndIf

		If nX == 1
			oModelAcum:SetValue("VLRATUAL", Iif(SN1->N1_PATRIM # "C", SN3->N3_VORIG1+SN3->N3_VRCACM1+SN3->N3_AMPLIA1, SN3->N3_VORIG1+SN3->N3_AMPLIA1) )
		Else
			oModelAcum:SetValue("VLRATUAL", SN3->(&( "N3_VORIG"+Alltrim(Str(nX)) )+&(If(nX>9,"N3_AMPLI","N3_AMPLIA")+Alltrim(Str(nX))) ) )
		EndIf

	Next nX

	/*--------------------------------------------------------------------------
	*						  V A L O R   R E S I D U A L
	*--------------------------------------------------------------------------
	* Valor residual e' a quantia a ser depreciada de um bem.
	*
	* Se o valor da baixa for superior ao valor residual, a diferenca entre
	* esses valores representa LUCRO a ser devidamente contabilizado.
	*
	* Custo da Baixa = Valor Original em Moeda Forte
	*--------------------------------------------------------------------------
	* Valor	³ Depr.   ³ Depr.ate ³ Depr.   ³ Valor	 ³ Valor   ³ Lucro(+)
	* Original ³ Acum.   ³ Dt Baixa ³ Acum.   ³ Residual ³ Baixa   ³
	*--------------------------------------------------------------------------
	* 1.000,00 ³  300,00 ³	 20,00 ³  320,00 ³	680,00 ³  680,00 ³	 0,00
	*--------------------------------------------------------------------------
	* 1.000,00 ³  300,00 ³	 20,00 ³  320,00 ³	680,00 ³  780,00 ³  100,00
	*--------------------------------------------------------------------------
	* 2.000,00 ³2.000,00 ³	  0,00 ³ 	0,00 ³	  0,00 ³  200,00 ³  200,00
	*--------------------------------------------------------------------------
	*/

	/*
	* Controla Valor Maximo de Depreciação
	*/
	lVlrMxDp := nMoedaVMax > 0 .AND. SN3->N3_VMXDEPR > 0

	If lVlrMxDp
		lVlrMxDp := Alltrim( SN3->N3_TPDEPR ) == '7'
	EndIf

	/*
	* Define regra de proporcionalizacao para outras moedas
	*/
	If lVlrMxDp .AND. nMoedaVMax > 9
		nPropBase 	:= SN3->N3_VMXDEPR / (&("SN3->N3_VORIG"  + Str(nMoedaVMax,1)) + &("SN3->N3_AMPLI" + Str(nMoedaVMax,1)))
	ElseIf lVlrMxDp .AND. nMoedaVMax <= 9
		nPropBase 	:= SN3->N3_VMXDEPR /(&("SN3->N3_VORIG"  + Str(nMoedaVMax,1)) + &("SN3->N3_AMPLIA" + Str(nMoedaVMax,1)))
	ElseIf lVlrSalv
		nPropBase 	:= SN3->N3_VLSALV1 / SN3->(N3_VORIG1+N3_AMPLIA1)
	Endif

	/*
	* Baixa Anual de Ativos - Localizado (Incentivo Fiscal)
	*/
	If !lATFA031

		/*
		* Calculo da taxa media para cada moeda
		*/
		dDataI := FirstDay(dData)
		dDataI := Iif(SN3->N3_DINDEPR > dDataI, SN3->N3_DINDEPR, dDataI)
		dbSelectArea("SM2")
		SM2->(dbSeek(dDataI,.T.))

		/*
		* Soma todas as taxas
		*/
		For nX := 2 To nQtdMoedas
			
			cMoeda := Alltrim(Str(nX))				
			nTxMedia := 0
			nDiasTx  := 0
			
			If oModelAcum:SeekLine({{"TPATIVO",SN3->N3_TIPO},{"TPSALDO",SN3->N3_TPSALDO},{"MOEDA",PADL(nX, nTamMoeda,"0")}})
				nTxMedia := oModelAcum:GetValue("TXMEDIA")
				nDiasTx  := oModelAcum:GetValue("ADIAS")
					
				While SM2->(!Eof()) .And. SM2->M2_DATA <= dData																	
					IF &('SM2->M2_MOEDA'+cMoeda) > 0
						nTxMedia += &('SM2->M2_MOEDA'+cMoeda)
						nDiasTx  ++
					EndIf										
					SM2->(dbSkip())
				EndDo
				
				If nTxMedia == 0 .OR. nDiasTx == 0
					oModelAcum:LoadValue("ADIAS", 1)
					oModelAcum:LoadValue("TXMEDIA", 1)
				Else
					oModelAcum:LoadValue("TXMEDIA",nTxMedia / nDiasTx )
				EndIf
			EndIf
			
		Next nX
		/*
		* Pesquisa a moeda 01 para o tipo de ativo e tipo de saldo posicionado no grid, e já posiciona na linha do grid pesquisada.
		*/
		oModelAcum:SeekLine({{"TPATIVO",SN3->N3_TIPO},{"TPSALDO",SN3->N3_TPSALDO},{"MOEDA","01"}})
		nLine01 := oModelAcum:GetLine()

		/*
		* Cálculo de dias de depreciação quando for o mês cheio
		*/
		If lPropBx .And. (MesAnoAtf(DDATAI) == MesAnoAtf(dData))
			nDiasDepr = DAY(dData) - (DAY(DDATAI)-1)
		EndIf

		/*
		* Tipos de ativo em formação (adiantamento), não deve ser depreciado
		*/
		If (!lAtfctap .Or. ! (cTipDepr $ '4/5/8/9')) .And. !(SN3->N3_TIPO $ '03/13' )
			lAtClDepr := AtClssVer(SN1->N1_PATRIM)

			If lAtClDepr .OR. EMPTY(SN1->N1_PATRIM)

				/*
				* Verifica o bloqueio do bem ou do grupo
				*/
				dBloqueio := Ctod("")
				AtfBloqueio(SN3->N3_CBASE + SN3->N3_ITEM, @dBloqueio)

				If (Empty(dBloqueio) .Or. Left(Dtos(dBloqueio), 6) <= Left(Dtos(dBaixa036), 6)) .And. !SN1->N1_STATUS $ "2|3" .And. (cPaisloc <> "RUS" .Or. SN1->N1_STATUS == "1")

					aTaxaMes :=	AFatorCalc(aTaxaMes, SN3->N3_DINDEPR, dData, cTipDepr, cCalcDep, .T.)

						/*
						 * Calculo Valor de depreciação para moeda 1
						 */
					If Abs(SN3->N3_VRDACM1 + SN3->N3_VRCDA1) < Abs(SN3->N3_VORIG1+SN3->N3_VRCACM1+SN3->N3_AMPLIA1)
						If aTaxaMes[1] > 0
							nDecTax		:= TamSX3("N3_VORIG1")[2]
							nCusto		:= SN3->N3_VORIG1 + SN3->N3_VRCACM1 + SN3->N3_AMPLIA1

							If nMoedaVMax == 1 .AND. lVlrMxDp
									/*
									* Habilita o "Valor maximo de depreciação" no calculo de depreciação na moeda definida
									*/
								nCusto := IIf(Empty(SN3->N3_VMXDEPR), nCusto, SN3->N3_VMXDEPR)
							ElseIf nMoedaVMax != 1 .AND. lVlrMxDp
									/*
									* Proporcionaliza a base para as outras moedas
									*/
								nCusto := Round(NoRound(nCusto * Round(NoRound(nPropBase,nDecTax+1),nDecTax), nDecTax+1), nDecTax)
							EndIf

								/*
								* Define o valor de salvamento quando é utilizado o método de redução de saldos
								*/
							If lVlrSalv
								nVlrOriSal	:= nCusto - SN3->N3_VLSALV1
								nCusto		:= Abs(nCusto - SN3->N3_VRDACM1)
							EndIf

								/*
								* No calculo de curva de trafego a depreciacao é sobre o valor contabil ( Aquisicao - Depreciacao Acumulada)
								*/
							If lCalcInd
								nCustOrig	:= nCusto
								nCusto		:= Abs(nCusto - SN3->N3_VRDACM1)
							EndIf

							If !(oModelMaster:GetValue("FN6_DEPREC") $ '0,3') .And. (  dData > SN3->N3_DINDEPR )
								If (SN3->N3_TIPO == "05" .Or. (SN1->N1_PATRIM $ cN1TipoNeg) .Or. (SN3->N3_TIPO $ cN3TipoNeg)).and. (SN3->N3_VORIG1 + SN3->N3_AMPLIA1 + SN3->N3_VRCACM1) < 0.00
									oModelAcum:SetValue("VLRDEP",Round(nCusto * aTaxaMes[1], nDecTax) )
								Else
									If !Empty( SN3->N3_FIMDEPR )
										oModelAcum:SetValue("VLRDEP", 0 )
									Else
										For nX := 1 To nQtdMoedas
											oModelAcum:GoLine(nX)
											If (&("SN3->N3_TXDEPR" + CVALTOCHAR(nX)) > 0.00)  .Or. (cPaisLoc == "BOL"  .And. SN3->N3_TPDEPR=="5" .And. aTaxaMes[1]>0)
												If nX == 1
													If lIsRussia .and. (oModelMaster:GetValue("FN6_DEPREC") == '2') .and. !(SN3->N3_TIPO $ "01")
														oModelAcum:SetValue("VLRDEP", Round(Abs(nCusto-aDepBefMod[1]) * aTaxaFat[1], nDecTax) )
													Else
														oModelAcum:SetValue("VLRDEP", Round(Abs(nCusto) * aTaxaMes[1], nDecTax) )
													EndIf
												EndIf
											Else
												oModelAcum:SetValue("VLRDEP", 0 )
											EndIf
										Next nX
										oModelAcum:GoLine(1)
									EndIf
								EndIf
							Else
								For nX := 1 To nQtdMoedas
									oModelAcum:GoLine(nX)
									oModelAcum:SetValue("VLRDEP", 0 )
								Next nX
								oModelAcum:GoLine(1)
							EndIf

							If lPropBx
								oModelAcum:SetValue("VLRDEP", Round((oModelAcum:GetValue("VLRDEP",nLine01) / nDias) * nDiasDepr , nDecTax) ) 
							EndIf

								/*
								 * Verifica se o valor da cota eh maior do que o valor residual.
								 */
							If lCalcInd
								oModelAcum:SetValue("DIFERE", Abs(nCustOrig) - (oModelAcum:GetValue("VLRDEP",nLine01) + Abs(SN3->N3_VRDACM1+ SN3->N3_VRCDA1)))
							ElseIf lVlrSalv
								oModelAcum:SetValue("DIFERE", Abs(nVlrOriSal) - (oModelAcum:GetValue("VLRDEP",nLine01) + Abs(SN3->N3_VRDACM1+ SN3->N3_VRCDA1)))
							Else
								oModelAcum:SetValue("DIFERE", nCusto - (oModelAcum:GetValue("VLRDEP",nLine01) + Abs(SN3->N3_VRDACM1+ SN3->N3_VRCDA1)))
							EndIf

								/*
								* Residuo inferior a 1 (uma) unidade monetaria sera adicionado a cota atual.
								*/
							If !(oModelMaster:GetValue('FN6_DEPREC') $ "0,3")
								If lCalcInd .And. Round( oModelAcum:GetValue("DIFERE",nLine01) , nDecTax ) <= 0.99
									oModelAcum:SetValue("DEPREC", Abs(nCustOrig) - Abs(SN3->N3_VRDACM1 + SN3->N3_VRCDA1))
								ElseIf !lVlrSalv .And. Round( oModelAcum:GetValue("DIFERE",nLine01) , nDecTax ) <= 0.99
									oModelAcum:SetValue("DEPREC", Abs(nCusto)- Abs(SN3->N3_VRDACM1 + SN3->N3_VRCDA1))
								ElseIf lVlrSalv .And. Round( oModelAcum:GetValue("DIFERE",nLine01) , nDecTax ) <= 0.99
									oModelAcum:SetValue("DEPREC", Abs(nVlrOriSal)-Abs(SN3->N3_VRDACM1 + SN3->N3_VRCDA1))								
								Endif
							Endif
						Else
							For nX := 1 To nQtdMoedas
								oModelAcum:GoLine(nX)
								If aTaxaMes[nX] > 0.00
									If nX == 1
										oModelAcum:SetValue("VLRDEP", Round(Abs(nCusto) * aTaxaMes[nX], nDecTax) )
									EndIf
								Else
									oModelAcum:SetValue("VLRDEP", 0 )
								EndIf
							Next nX
						EndIf					
					EndIf

					If !(oModelMaster:GetValue("FN6_DEPREC") $ '0,3') .And. (  dData > SN3->N3_DINDEPR )
							/*
							 * Calculo Valor de depreciação para demais moedas
							 */
						For nX:= 2 to nQtdMoedas
								/*
								 * Moeda posicionada
								 */
							cMoed := Alltrim(Str(nX))
								
							If (&("SN3->N3_TXDEPR" + CVALTOCHAR(nX)) > 0.0000)  .Or. (cPaisLoc == "BOL"  .And. SN3->N3_TPDEPR=="5" .And. aTaxaMes[nX]>0)
								oModelAcum:SeekLine({{"TPATIVO",SN3->N3_TIPO},{"TPSALDO",SN3->N3_TPSALDO},{"MOEDA",PADL(nX, nTamMoeda,"0")}})
		
								If Abs(SN3->(&( if(nX>9,"N3_VRDAC","N3_VRDACM")+cMoed))) < Abs(SN3->(&("N3_VORIG"+cMoed))+SN3->(&(If(nX>9,"N3_AMPLI","N3_AMPLIA")+cMoed)))
									If aTaxaMes[nX] > 0
										nDecTax	:= TamSX3("N3_VORIG"  + Alltrim(Str(nX)))[2]
										nCusto	:= SN3->(&("N3_VORIG"+cMoed))+SN3->(&(If(nX>9,"N3_AMPLI","N3_AMPLIA")+cMoed))
		
										If  nX == nMoedaVMax .And. lVlrMxDp
												/*
												* Habilita o "Valor maximo de depreciação" no calculo de depreciação na moeda definida
												*/
											nCusto := IIf(Empty(SN3->N3_VMXDEPR), nCusto, SN3->N3_VMXDEPR)
										ElseIf nX != nMoedaVMax .And. lVlrMxDp
												/*
												* Proporcionaliza a base para as outras moedas
												*/
											nCusto := Round(NoRound(nCusto * Round(NoRound(nPropBase,nDecTax+1),nDecTax), nDecTax+1), nDecTax)
										EndIf
		
											/*
											* Define o valor de salvamento quando é utilizado o método de redução de saldos
											*/
										If lVlrSalv
											nVlrOriSal := nCusto - ROUND(NOROUND(nCusto * Round(NoRound(nPropBase,nDecTax+1),nDecTax),nDecTax+1),nDecTax)
											nCusto := Abs(nCusto - SN3->(&(if(nX>9,"N3_VRDAC","N3_VRDACM")+cMoed)))
										EndIf
		
											/*
											* No calculo de curva de trafego a depreciacao é sobre o valor contabil ( Aquisicao - Depreciacao Acumulada)
											*/
										If lCalcInd
											nCustOrig	:= nCusto
											nCusto		:= Abs(nCusto - SN3->(&(if(nX>9,"N3_VRDAC","N3_VRDACM")+cMoed)))
										EndIf
		
											/*
											* Reavaliação Negativa e aceitar valores negativos
											*/
										If (SN3->N3_TIPO == "05" .Or. (SN1->N1_PATRIM $ cN1TipoNeg) .Or. (SN3->N3_TIPO $ cN3TipoNeg) ) .and. (SN3->N3_VORIG1 + SN3->N3_AMPLIA1 + SN3->N3_VRCACM1) < 0.00
											oModelAcum:SetValue("VLRDEP", Round(nCusto * aTaxaMes[nX], X3Decimal("N3_VORIG"+cMoed)) )
										Else
											oModelAcum:SetValue("VLRDEP", Round(Abs(nCusto) * aTaxaMes[nX], X3Decimal("N3_VORIG"+cMoed)) )
										EndIf
		
											/*
											* Define o valor de salvamento quando é utilizado o método de redução de saldos == '0'
											*/
										If lPropBx
											oModelAcum:SetValue("VLRDEP", Round((oModelAcum:GetValue("VLRDEP") / nDias) * nDiasDepr , X3Decimal("N3_VORIG"+cMoed)) )
										EndIf
		
											/*
											* Verifica se o valor da cota eh maior do que o valor residual.
											*/
										If lCalcInd
											oModelAcum:SetValue("DIFERE", Abs(nCustOrig)	- (oModelAcum:GetValue("VLRDEP") + Abs(SN3->(&(if(nX>9,"N3_VRDAC","N3_VRDACM")+cMoed)))) )
										ElseIf lVlrSalv
											oModelAcum:SetValue("DIFERE", Abs(nVlrOriSal)	- (oModelAcum:GetValue("VLRDEP") + Abs(SN3->(&(if(nX>9,"N3_VRDAC","N3_VRDACM")+cMoed)))) )
										Else
											oModelAcum:SetValue("DIFERE", Abs(nCusto)		- (oModelAcum:GetValue("VLRDEP") + Abs(SN3->(&(if(nX>9,"N3_VRDAC","N3_VRDACM")+cMoed)))) )
										EndIf
		
											/*
											* Residuo inferior a 1 (uma) unidade monetaria sera adicionado a cota atual.
											*/
										If lCalcInd .And. Round( oModelAcum:GetValue("DIFERE") , X3Decimal("N3_VORIG2") ) <= 0.99
											If SN3->(&(iif(nX>9,"N3_VRDAC","N3_VRDACM")+cMoed)) + abs(oModelAcum:GetValue("VLRDEP")) > nCustOrig
												oModelAcum:SetValue("VLRDEP", Abs(nCustOrig) - SN3->(&(iif(nX>9,"N3_VRDAC","N3_VRDACM")+cMoed)))
											EndIf
										ElseIf !lVlrSalv .And. Round( oModelAcum:GetValue("DIFERE") , X3Decimal("N3_VORIG2") ) <= 0.99
											If SN3->(&(iif(nX>9,"N3_VRDAC","N3_VRDACM")+cMoed)) + abs(oModelAcum:GetValue("VLRDEP")) > nCusto
												oModelAcum:SetValue("VLRDEP", Abs(nCusto) - SN3->(&(iif(nX>9,"N3_VRDAC","N3_VRDACM")+cMoed)) )
											EndIf
										ElseIf lVlrSalv .And. Round( oModelAcum:GetValue("DIFERE") , X3Decimal("N3_VORIG2") ) <= 0.99
											If SN3->(&(iif(nX>9,"N3_VRDAC","N3_VRDACM")+cMoed)) + abs(oModelAcum:GetValue("VLRDEP")) > nCusto
												oModelAcum:SetValue("VLRDEP", Abs(nVlrOriSal) - SN3->(&(iif(nX>9,"N3_VRDAC","N3_VRDACM")+cMoed)) )
											EndIf
										Endif
									EndIf
								EndIf
							EndIf
						Next nX
					EndIf
				EndIf
			EndIf
		Else
			lCalcula := .F.
		EndIf

		oModelAcum:GoLine(nLine01)

		If lCalcula == Nil
			IF cpaisloc == "BOL" .and. cMVATFMCCM == "V" .and. cMetodDep == "1" .and. SN3->N3_TPDEPR!="5"
				lcalcula := .T. 
			Else
				lCalcula := If(GetMv("MV_CORREC") == "S" .and. !Empty(GetMv("MV_VALCORR")),.T.,.F.)
				If lCalcula
					nParCorrec := ( ( GetMv("MV_VALCORR") / 100 ) + 1 )
				Endif
			EndIf
		Endif
		
		/*
		* Calculo de Depreciação na Moeda 1
		*/
		If lCalcula
			/*
			* Se NAO tiver residuo na moeda 3
			*/
			oModelAcum:SeekLine({{"TPATIVO",SN3->N3_TIPO},{"TPSALDO",SN3->N3_TPSALDO},{"MOEDA",PADL(nMoedaAtf, nTamMoeda,"0")}})
			nLineAux := oModelAcum:GetLine()
			If oModelAcum:GetValue("DEPREC", nLineAux ) == 0
				oModelAcum:SetValue("VLRDEP",Round(oModelAcum:GetValue("VLRDEP",nLineAux)  * nParCorrec,X3Decimal("N3_VORIG1")) )
			Endif

			oModelAcum:SetValue("DIFERE", nLine01) := (SN3->N3_VORIG1+SN3->N3_VRCACM1+SN3->N3_AMPLIA1+nValCorr) - ( oModelAcum:GetValue("VLRDEP",nLine01) + SN3->N3_VRDACM1+SN3->N3_VRCDA1)

			If Round(oModelAcum:GetValue("DIFERE") ,X3Decimal("N3_VORIG1")) < 0
				oModelAcum:SetValue("DEPREC", (SN3->N3_VORIG1+SN3->N3_VRCACM1+SN3->N3_AMPLIA1)-(SN3->N3_VRDACM1 + SN3->N3_VRCDA1) )
			Endif
		Else
			/*
			* Regra Geral a Depr na Moeda1 ‚ calculada pela taxa media do mes,
			* enquanto existe uma taxa de referencia (UFIR). A partir de 01/01/96
			* a referncia ‚ o pr¢prio real. Dessa forma nÆo ha necessidade de
			* converter a deprecia‡Æo pela Ufir de referencia.
			*/
			If Dtos(dData) < "19960101"
				oModelAcum:SeekLine({{"TPATIVO",SN3->N3_TIPO},{"TPSALDO",SN3->N3_TPSALDO},{"MOEDA",PADL(nMoedaAtf, nTamMoeda,"0")}})
				nLineAux := oModelAcum:GetLine()
				oModelAcum:GoLine(nLine01)
				oModelAcum:SetValue("VLRDEP", Round(oModelAcum:GetValue("VLRDEP",nLineAux) * oModelAcum:GetValue("TXMEDIA",nLineAux) , nDecTax) )
				oModelAcum:SetValue("DIFERE",(SN3->N3_VORIG1 + SN3->N3_VRCACM1 + SN3->N3_AMPLIA1) - ( oModelAcum:GetValue("VLRDEP",nLine01) + SN3->N3_VRDACM1+SN3->N3_VRCDA1) )
				If Round( oModel:GetValue("VLRACUM","DIFERE", nLine01 ), nDecTax ) <= 0
					oModelAcum:SetValue("DEPREC", (SN3->N3_VORIG1+SN3->N3_VRCACM1+SN3->N3_AMPLIA1)-(SN3->N3_VRDACM1+SN3->N3_VRCDA1) )
				Endif
			EndIf
		EndIf

		/*
		* Trata os residuos de depreciacao.
		*/
		If SN3->N3_DINDEPR <= dBaixa036
			If oModelAcum:GetValue("DEPREC",nLine01) != 0
				oModelAcum:GoLine(nLine01)
				oModelAcum:SetValue("VLRDEP", oModel:GetValue("VLRACUM","DEPREC", nLine01 ) )
			Endif
		Endif
		
		/* 
		* Valor de Correção
		*/
		If lCalcula
			IF cpaisloc == "BOL" .and. cMVATFMCCM == "V" .and. cMetodDep == "1" .and. SN3->N3_TPDEPR!="5"
				aRetVlBol := ATF036BOL(1,dDataI, dData, nMoedaAtf,nTaxaCorr,oModelAcum)
				nTaxaCorr  := aRetVlBol[1][1]
				nParCorrec := nTaxaCorr 
				nValCorr   := aRetVlBol[1][2]
				nValCorDep := aRetVlBol[1][3]
				nVlCor		:= nValCorr  
				nVlCorDep	:= nValCorDep
			Else
				nTaxaCorr  := nParCorrec + 1
				nValCorr   := Round(Abs((&('SN3->N3_VORIG'+cMoedaAtf) + &(Iif(nMoedaAtf > 9,'SN3->N3_AMPLI','SN3->N3_AMPLIA')+cMoedaAtf))*nTaxaCorr),nDecTax) - ;
				Abs(SN3->N3_VRCACM1+SN3->N3_VORIG1+SN3->N3_AMPLIA1)
				nValCorDep := Round(Abs(&(If(Val(cMoedaAtf)>9,'SN3->N3_VRDAC','SN3->N3_VRDACM')+cMoedaAtf)+oModelAcum:GetValue("VLRDEP",nLineAux) )*nTaxaCorr,nDecTax) - ;
				Abs(SN3->N3_VRDACM1+SN3->N3_VRCDA1+oModelAcum:GetValue("VLRDEP",1) )
			EndIF
		Else
			If DtoS(dData) < "19941001"
				nTaxaCorr := RecMoeda(dData,cMoedaAtf)
			Else
				nTaxaCorr := 0
			Endif

			If nTaxaCorr != 0
				nValCorr   := Round(Abs((&('SN3->N3_VORIG'+cMoedaAtf)+&(Iif(nMoedaAtf > 9,'SN3->N3_AMPLI','SN3->N3_AMPLIA')+cMoedaAtf))*nTaxaCorr),nDecTax) - ;
					Abs(SN3->N3_VRCACM1+SN3->N3_VORIG1+SN3->N3_AMPLIA1)
				nValCorr   :=  nValCorr * (oModelAcum:GetValue("PERCBAIX",nLineAux)/100)
				nValCorr   := (nValCorr, X3Decimal("N3_VRCACM1"))

				nValCorDep := Round(Abs(&(Iif(nMoedaAtf > 9,'SN3->N3_VRDAC','SN3->N3_VRDACM')+cMoedaAtf)+ oModelAcum:GetValue("VLRDEP",nLineAux) ) * nTaxaCorr,nDecTax) - ;
					Abs(SN3->N3_VRDACM1+SN3->N3_VRCDA1+ oModelAcum:GetValue("VLRDEP",1))

				nValCorDep := nValCorDep  * (oModelAcum:GetValue("PERCBAIX",nLineAux)/100)
				nValCorDep := Round(nValCorDep, X3Decimal("N3_VRCDA1" ))
			EndIf

		EndIf

		/*
		* Atualiza o valor atual com valor de correcao
		*/
		oModelAcum:GoLine(nLine01)
		oModelAcum:SetValue("VLRATUAL",SN3->N3_VORIG1 + SN3->N3_VRCACM1 + SN3->N3_AMPLIA1 + nValCorr )

		For nMoeda := 1 To nQtdMoedas
					
			/*
			* Numero da Moeda
			*/
			cMoeda		:= Alltrim(Str(nMoeda))
			nTamDecim	:= TamSX3("N3_VORIG"+cMoeda)[2]

			/*
			* Cálculo do Valor Residual de Depreciação
			*/
			If cMoeda == "1"
				nResidual := SN3->N3_VRDACM1 + SN3->N3_VRCDA1
				If (SN3->N3_TIPO == "05" .Or. (SN1->N1_PATRIM $ cN1TipoNeg) .Or. (SN3->N3_TIPO $ cN3TipoNeg)) .and. (SN3->N3_VORIG1 + SN3->N3_AMPLIA1 + SN3->N3_VRCACM1) < 0.00
					nResidual := SN3->N3_VORIG1 + SN3->N3_AMPLIA1 + SN3->N3_VRCACM1 + Abs(nResidual)
				Else
					nResidual := Abs(SN3->N3_VORIG1 + SN3->N3_AMPLIA1 + SN3->N3_VRCACM1 - nResidual)
				EndIf
			Else
				nResidual := &(Iif( nMoeda > 9, 'SN3->N3_VRDAC' , 'SN3->N3_VRDACM' ) + cMoeda )
				If (SN3->N3_TIPO == "05" .Or. (SN1->N1_PATRIM $ cN1TipoNeg) .Or. (SN3->N3_TIPO $ cN3TipoNeg)) .and. (SN3->N3_VORIG1 + SN3->N3_AMPLIA1 + SN3->N3_VRCACM1) < 0.00
					nResidual := &('SN3->N3_VORIG'+cMoeda) + &(Iif(nMoedaAtf > 9,'SN3->N3_AMPLI','SN3->N3_AMPLIA') + cMoedaAtf ) + Abs(nResidual)
				Else
					nResidual := Abs(&('SN3->N3_VORIG'+cMoeda) + &(Iif( nMoedaAtf >9, 'SN3->N3_AMPLI','SN3->N3_AMPLIA') + cMoedaAtf ) - nResidual)
				Endif
			EndIf

			oModelAcum:SeekLine({{"TPATIVO",SN3->N3_TIPO},{"TPSALDO",SN3->N3_TPSALDO},{"MOEDA",PADL(nMoeda, nTamMoeda,"0")}})			
			nLineAux := oModelAcum:GetLine()
			
			If !(oModelMaster:GetValue("FN6_DEPREC") $ '0,3') .And. (  dData > SN3->N3_DINDEPR )
				oModelAcum:SetValue("VALORRESID",nResidual)
			Else
				oModelAcum:SetValue("VALORRESID",oModelAcum:GetValue("VLRATUAL"))
			EndIf
			
			/*
			* Forma de Calculo de Depreciação
			*/			
			If cCalcDep == '0' .Or. !cPaisLoc $ "BRA|ANG"
				If cPaisLoc == "ARG"
					If SN1->N1_CONSAB == "1"
						nDiasDepr := 0
					Else
						nDiasDepr := ( LastDay(dData)- FirstDay(dData) ) +1
					EndIf
				Else					
					If Month(SN3->N3_DINDEPR) == Month(dData) .And. Year(SN3->N3_DINDEPR) == Year(dData)
						/*
						* Número de dias a depreciar quando a baixa ‚ feita no mesmo mês e ano da data de inicio de depreciação.
						*/
						nDiasDepr := Iif(lPropBx, (dData-SN3->N3_DINDEPR) + 1, 1)
					ElseIf Month(SN3->N3_DINDEPR) > Month(dData) .And. Year(SN3->N3_DINDEPR) == Year(dData)
						nDiasDepr := 0
					Endif
				EndIf
			Else				
				If Year(SN3->N3_DINDEPR) == Year(dData)
					If Month(SN3->N3_DINDEPR) == Month(dData)
						oModelAcum:GoLine(nLineAux)
						nTaxaMes := ( oModelAcum:GetValue("VLRDEP",nLineAux) / 12 ) * IIf( cTipDepr $ "4|5", 1, ( (SN3->N3_DINDEPR - dData) + 1 ) / Day( LastDay(dData) ) )
						oModelAcum:SetValue("VLRDEP",oModelAcum:GetValue("VLRDEP",nLineAux) * ( ( Month(dData) - Month(SN3->N3_DINDEPR) ) / 12 ) + nTaxaMes)
					Else
						oModelAcum:GoLine(nMoeda)
						nTaxaMes := ( oModelAcum:GetValue("VLRDEP",nLineAux) / 12 ) * IIf( cTipDepr $ "4|5", 1, ( (LastDay(SN3->N3_DINDEPR)-SN3->N3_DINDEPR) + 1 ) / Day(LastDay(SN3->N3_DINDEPR)) )
						nTaxaBx  := ( oModelAcum:GetValue("VLRDEP",nLineAux) / 12 ) * IIf( cTipDepr $ "4|5", 0, Day(dData) / Day(LastDay(dData)) )
						oModelAcum:SetValue("VLRDEP",oModelAcum:GetValue("VLRDEP",nLineAux) * ( ( Month(dData) - Month(SN3->N3_DINDEPR) - 1 ) / 12 ) + nTaxaMes + nTaxaBx)
					EndIf
				EndIf			
			EndIf

			/*
			* Reavaliação Negativa e aceitar valores negativos
			*/
			If (SN3->N3_TIPO == "05" .Or. (SN1->N1_PATRIM $ cN1TipoNeg) .Or. (SN3->N3_TIPO $ cN3TipoNeg)) .and. (SN3->N3_VORIG1 + SN3->N3_AMPLIA1 + SN3->N3_VRCACM1) < 0.00
				oModelAcum:SetValue("VALORRESID", oModelAcum:GetValue("VALORRESID",nLineAux) + oModelAcum:GetValue("VLRDEP", nLineAux ) )
			ElseIf oModelAcum:GetValue("VALORRESID",nLineAux)>0
				oModelAcum:SetValue("VALORRESID", oModelAcum:GetValue("VALORRESID",nLineAux) - oModelAcum:GetValue("VLRDEP", nLineAux ) )				
			Endif

			/*
			* Cálculo do Valor da Correção Acumulada
			*/
			oModelAcum:SetValue("VRDACM", &(Iif(nMoeda > 9,'SN3->N3_VRDAC','SN3->N3_VRDACM') + cMoeda ) )
			If oModelAcum:GetValue("VALORRESID",nLineAux) >= 0
				oModelAcum:SetValue("VLRDEP", Round(oModelAcum:GetValue("VLRDEP",nLineAux) * (oModelAcum:GetValue("PERCBAIX",nLineAux)/100), X3Decimal(If(nMoeda>9,"N3_VRDME","N3_VRDMES")+cMoeda)) )
			Else
				oModelAcum:SetValue("VLRDEP",0)
			EndIf
			oModelAcum:SetValue("VALORRESID", Round(oModelAcum:GetValue("VALORRESID",nLineAux) * (oModelAcum:GetValue("PERCBAIX",nLineAux)/100), nTamDecim) )
			oModelAcum:SetValue("VALORBX", Round(oModelAcum:GetValue("VALORBX",nLineAux) * (oModelAcum:GetValue("PERCBAIX",nLineAux)/100), nTamDecim) )
			oModelAcum:SetValue("VRDACM", Round(oModelAcum:GetValue("VRDACM",nLineAux) * (oModelAcum:GetValue("PERCBAIX",nLineAux)/100), X3Decimal(If(nMoeda>9,"N3_VRDAC","N3_VRDACM")+cMoeda)) )

			If oModelAcum:GetValue("DEPREC",nLineAux) != 0
				/*
				* Baixa de bem com resíduo de depreciação em uma ou outra moeda
				*/
				oModelAcum:SetValue("VLRDEP", Round(oModelAcum:GetValue("DEPREC",nLineAux) , X3Decimal(If(nMoeda>9,"N3_VRDME","N3_VRDMES")+cMoeda)) )
			Endif

			oModelAcum:SetValue("VALORBX", Round(oModelAcum:GetValue("VLRATUAL",nLineAux) * (oModelAcum:GetValue("PERCBAIX",nLineAux)/100)	, nTamDecim) )

		Next nMoeda

		oModelAcum:SeekLine({{"TPATIVO",SN3->N3_TIPO},{"TPSALDO",SN3->N3_TPSALDO},{"MOEDA",PADL(nMoedaAtf, nTamMoeda,"0")}})
		nLineAux := oModelAcum:GetLine()

		/*
		* Cálculo de Correção da correção do bem e da depreciação.
		* A taxa de correção e a mesma para o custo e para a depreciação acumulada.
		*/	
		If lCalcula
			If ExistBlock("A36EMBRA")
				nTaxaCorr := ExecBlock("A36EMBRA",.F.,.F.)
			Else
				nTaxaCorr := nParCorrec
			EndIf
			IF cpaisloc == "BOL" .and. cMVATFMCCM == "V" .and. cMetodDep == "1" .and. SN3->N3_TPDEPR!="5"
				aRetVlBol := ATF036BOL(2,dDataI, dData, nMoedaAtf,nTaxaCorr,oModelAcum,nLineAux,nLine01)
				nValCorr   := aRetVlBol[1][1]
				nValCorDep := aRetVlBol[1][2]
				nVlCor	:= nValCorr
				nVlCorDep := nValCorDep
			Else
				nValCorr   := Round(Abs((&('SN3->N3_VORIG'+cMoedaAtf) + &(Iif(nMoedaAtf >9,'SN3->N3_AMPLI','SN3->N3_AMPLIA') + cMoedaAtf)) * nTaxaCorr),nDecTax) - ;
				Abs(SN3->N3_VRCACM1 + SN3->N3_VORIG1 + SN3->N3_AMPLIA1)

				nValCorr   := nValCorr * (oModelAcum:GetValue("PERCBAIX",nLineAux)/100)
				nValCorDep := Round((&(Iif(nMoedaAtf > 9,'SN3->N3_VRDAC','SN3->N3_VRDACM') + cMoedaAtf) + oModelAcum:GetValue("VLRDEP",nLineAux)) * nTaxaCorr ,nDecTax) - (SN3->N3_VRDACM1 + SN3->N3_VRCDA1 + oModelAcum:GetValue("VLRDEP",nLine01) )

				nValCorDep := nValCorDep * (oModelAcum:GetValue("PERCBAIX",nLineAux)/100)
				nValCorDep := Round(nValCorDep, X3Decimal("N3_VRCDA1" ))
			EndIf
		Else
			If DtoS(dData) < "19941001"
				nTaxaCorr := RecMoeda(dData,cMoedaAtf)
			Else
				nTaxaCorr := 0
			EndIf

			If ExistBlock("A36EMBRA")
				nTaxaCorr := ExecBlock("A36EMBRA",.F.,.F.)
			EndIf

			If nTaxaCorr != 0
				nValCorr   := Round(Abs((&('SN3->N3_VORIG' + cMoedaAtf) + &(Iif(nMoedaAtf > 9,'SN3->N3_AMPLI','SN3->N3_AMPLIA') + cMoedaAtf )) * nTaxaCorr),nDecTax) - Abs(SN3->N3_VRCACM1+SN3->N3_VORIG1+SN3->N3_AMPLIA1)

				nValCorr   := nValCorr * (oModelAcum:GetValue("PERCBAIX",nLineAux)/100)
				nValCorr   := (nValCorr, X3Decimal("N3_VRCACM1"))
				nValCorDep := Round( (&(Iif(nMoedaAtf > 9,'SN3->N3_VRDAC','SN3->N3_VRDACM') + cMoedaAtf) + oModelAcum:GetValue("VLRDEP",nLineAux) * nTaxaCorr),nDecTax) - (SN3->N3_VRDACM1 + SN3->N3_VRCDA1 + oModelAcum:GetValue("VLRDEP",nLine01))

				nValCorDep := nValCorDep * (oModelAcum:GetValue("PERCBAIX",nLineAux)/100)
				nValCorDep := Round(nValCorDep, X3Decimal("N3_VRCDA1" ))
			EndIf		
		EndIf
	EndIf // lATFA031
	
	/*
	* Libera a inclusão de novas linhas
	*/
	oModelValor:SetNoInsertLine(.F.)
	oModelValor:SetNoUpdateLine(.F.)

	/*
	* Carrega os valores do grid de valores do ativo
	*/
	For nX := 1 To nQtdMoedas
		/*
		* Muda de linha na grid do valores para o tipo de ativo posicionado
		*/
		If oModelAcum:SeekLine({{"TPATIVO",oModelTipo:GetValue("FN7_TIPO")},{"TPSALDO",oModelTipo:GetValue("FN7_TPSALD")},{"MOEDA",PADL(nX, nTamMoeda,"0")}})

			If lIsRussia .And. nX == nMoedaAtf
				oModelTipo:LoadValue("FN7_CALCDP",	oModelAcum:GetValue("VLRDEP"))
				oModelTipo:LoadValue("FN7_VRDACM",	oModelTipo:GetValue("VRACUMVAL") + oModelTipo:GetValue("FN7_CALCDP"))
				oModelTipo:LoadValue("FN7_CARRYV",	oModelTipo:GetValue("FN7_VORIG") - oModelTipo:GetValue("FN7_VRDACM"))
			EndIf		

			oModelValor:SeekLine({	{"FN7_TIPO",oModelTipo:GetValue("FN7_TIPO")},;
									{"FN7_TPSALD",oModelTipo:GetValue("FN7_TPSALD")},;
									{"FN7_MOEDA",PADL(nX, nTamMoeda,"0")},;
									{"FN7_FILORI",oModelTipo:GetValue("FN7_FILORI")}})

			/*
			 * Atribui os novos valores
			 */
			oModelValor:LoadValue("FN7_VLATU"	,  oModelAcum:GetValue("VLRATUAL"	))
			oModelValor:LoadValue("FN7_VLDEPR"	,  oModelAcum:GetValue("VLRDEP"		))
			oModelValor:LoadValue("FN7_VLBAIX"	,  oModelAcum:GetValue("VALORBX"	))
			oModelValor:LoadValue("FN7_PERCBX"	,  oModelAcum:GetValue("PERCBAIX"	))
			oModelValor:LoadValue("FN7_VLRESI"	,  oModelAcum:GetValue("VALORRESID"	))
		EndIf		
	Next nX

	/*
	* Bloqueia a inclusão de novas linhas
	*/
	oModelValor:SetNoInsertLine(.T.)

	oModelValor:GoLine(1)
		
	RestArea(aArea)

EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036GRV

Grava os dados da Baixa

@author felipe.cunha
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036GRV ( oModel )
Local oModelMaster	:= oModel:GetModel(If(FWIsInCallStack("AF036BxLote") .or. lAtf030,"FN6ATIVOS", "FN6MASTER"))
Local oModelTipo 	:= oModel:GetModel('FN7TIPO')		// Carrega Model VALOR
Local oModelValor	:= oModel:GetModel('FN7VALOR')		// Carrega Model VALOR
Local nCont 		:= 1	//Contador de Item do Ativo
Local lOk			:= .T.
Local cAlsAtu		:= Alias()
Local cNota			:= ""
Local cSerie		:= ""
Local nQuant		:= 0
Local nQtdOrig		:= 0
Local lCtbBxInt		:= .F.
Local cIDMOV		:= ""
Local lMovCiap		:= .F.
Local cNFItem		:= ""
Local cSN3Fil		:= FWxFilial("SN3")
Local cFilFN7		:= oModelTipo:GetValue("FN7_FILIAL")
Local nCtnTipo		:= 0
Local nCtnValor		:= 0
Local cBase			:= ''
Local cItem			:= ''
Local cTipo			:= ''
Local cTpSld		:= ''
Local cSeq			:= ""
Local cModSeq 		:= ""
Local cSeqReav		:= ""
Local dBaixa036		:= CTOD("  /  /  ")
Local cMotivo		:= ''
Local lQuant		:= AF036VQt(oModelTipo) 
Local nHdlPrv		:= 0 
Local cLoteAtf		:= LoteCont("ATF")
Local cArquivo		:= ''
Local nTotal		:= 0
Local cCliente		:= ""
Local cLoja			:= ""
Local cCondPag		:= ""
Local cProduto		:= ""
Local nValNF		:= ""
Local nTamItem		:= TamSX3("FN7_ITEM")[1]
Local nSaveSx8Len	:= GetSx8Len()
Local dBaixa		:= CTOD("")
Local cFN6FilOri	:= ""
Local cFN6CBase		:= ""
Local cFN6Item		:= ""
Local nFN6QtdBx		:= 0
Local aNotas		:= {}
Local aItensNF		:= {}
Local nX			:= 0
Local nY			:= 0
Local lAchou		:= .F.
Local cMV_NGMNTAT	:= SuperGetMV("MV_NGMNTAT",.F.,"N")  //Integração com MNT
Local cFilST9		:= FWxFilial("ST9")
Local cLanc			:= ""
Local aCampos		:= {} //Utilizado para Obtener Codigo de Uso CFDI - MEX/PER
Local oView			:= Nil
Local aFlagCTB		:= {} //Flag para contabilizaç?o Ativo
Local lAtuCiap		:= .T. //Flag para controle geracao CIAP

Local nSalesCurr	AS NUMERIC
Local cClass		AS CHARACTER
Local cInvMsg		AS CHARACTER
Local lGeraNF		AS LOGICAL
Local aArea			AS ARRAY
Local aAreaSD2		AS ARRAY
Local aFARules		AS ARRAY
Local aSaleInvs		AS ARRAY

aFARules			:= {}
aSaleInvs			:= {}

If lExisCPC31 == Nil
	lExisCPC31 := SN1->(Fieldpos("N1_BLQDEPR")) > 0 .And. cPaisLoc == "BRA" //CPC31, VERIFICA SE O CAMPO EXISTE NA BASE E SE ? DA LOCALIDADE DO BRASIL
EndIF

dbSelectArea( "SN3" )
SN3->(dbSetOrder( 11 ))

If __nOper == OPER_BAIXA	
    IF oModelMaster:GetValue("FN6_DEPREC") $ '0,3'
	 cLanc := "000371"
	Else
	 cLanc := "000370"
	EndIF	
	PcoIniLan(cLanc)
	BEGIN TRANSACTION
	
		cNota		:= oModelMaster:GetValue("FN6_NUMNF")
		cSerie		:= oModelMaster:GetValue("FN6_SERIE")
		nQuant		:= oModelMaster:GetValue("FN6_QTDBX") 
		cCliente	:= oModelMaster:GetValue("FN6_CLIENT")
 		cLoja		:= oModelMaster:GetValue("FN6_LOJA")
		cCondPag	:= oModelMaster:GetValue("FN6_CNDPAG")
		cProduto	:= GetAdvFVal("SN1","N1_PRODUTO",XFilial("SN1")+oModelMaster:GetValue("FN6_CBASE")+oModelMaster:GetValue("FN6_CITEM"),1,"")
		nValNF		:= oModelMaster:GetValue("FN6_VALNF")
		cTESSaida	:= oModelMaster:GetValue("FN6_TESSAI")
		If lIsRussia
			nSalesCurr	:= oModelMaster:GetValue("FN6_SOCURR")
		EndIf
		dBaixa		:= oModelMaster:GetValue("FN6_DTBAIX")

		cFN6FilOri	:= oModelMaster:GetValue("FN6_FILORI")
		cFN6CBase	:= oModelMaster:GetValue("FN6_CBASE")
		cFN6Item	:= oModelMaster:GetValue("FN6_CITEM")
		nFN6QtdBx	:= oModelMaster:GetValue("FN6_QTDBX")

		If lIsRussia
			cClass	:= oModelMaster:GetValue("FN6_NATURE")
		EndIf
		
		If cPaisLoc == "MEX"
			aCampos	:={ oModelMaster:GetValue("FN6_USOCFD")}
		EndIf
		
 		If cPaisLoc == "PER" .And. lExisCpo
 			aCampos	:={oModelMaster:GetValue("FN6_TPDOC"),oModelMaster:GetValue("FN6_TIPONF")}
		EndIf   
    
 		If cPaisLoc == "COL" .And. lExisCpo
 			aCampos	:={oModelMaster:GetValue("FN6_CODMUN"),oModelMaster:GetValue("FN6_TPACTI"),oModelMaster:GetValue("FN6_TRMPAC"),oModelMaster:GetValue("FN6_TIPOPE")}
		EndIf

		//-----------------------------------
		// Integracao com Gestao de Servicos
		//-----------------------------------
		If lOk .And. GetNewPar("MV_TECATF","N") == "S"
			lOk := TcBxATF(cFN6FilOri,cFN6CBase,cFN6Item,nFN6QtdBx,.T.)
		EndIf
		
		//---------------------------------------------------------
		// Geracao da Nota Fiscal
		//---------------------------------------------------------
		lGeraNF	:= oModelMaster:GetValue("FN6_GERANF") == "1"
		If lIsRussia .And. lOK .And. lGeraNF
			cSerie		:= PADR(cSerie, GetSx3Cache("D2_SERIE", "X3_TAMANHO"))
			cCliente	:= PADR(cCliente, GetSx3Cache("D2_CLIENTE", "X3_TAMANHO"))
			cLoja		:= PADR(cLoja, GetSx3Cache("D2_LOJA", "X3_TAMANHO"))
			cProduto	:= PADR(cProduto, GetSx3Cache("D2_COD", "X3_TAMANHO"))

			cNota	:= AF036RUSOI(;
				cSerie, ;
				cCliente, ;
				cLoja, ;
				cCondPag, ;
				cClass, ;
				nSalesCurr, ;
				{{;
					cProduto,;
					nQuant,;
					nValNF,;
					cTESSaida}})[1]
			
			lOk	:= ! Empty(cNota)

			If lOk
				aAdd(aSaleInvs, cNota)

				aArea		:= GetArea()
				aAreaSD2	:= SD2->(GetArea())
				SD2->(dbSetorder(3))	// D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				lOk	:= SD2->(dbSeek(xFilial("SD2") + cNota + cSerie + cCliente + cLoja + cProduto))
				lOk	:= lOk .And. ;
					oModelMaster:LoadValue("FN6_ITEMNF", SD2->D2_ITEM)
				RestArea(aAreaSD2)
				RestArea(aArea)
			EndIf

			Pergunte("AFA036", .F.)
			If ! lOk
				oModel:SetErrorMessage("", Nil, oModel:GetId(), "", "GERNF", STR0139)	// "The write-off process was interrupted as a sales invoice could not be created."
			EndIf
		ElseIf lOK .And. lGeraNF

			If cPaisLoc <> "BRA"
				//---------------------------------------------------------------
				// Estrutura do Array aNotas
				//---------------------------------------------------------------
				// aNotas[1][1] - Codigo base del Bien (N1_CBASE)
				// aNotas[1][2] - Serie Nota Fiscal (F2_SERIE)
				// aNotas[1][3] - Cliente (F2_CLIENTE)
				// aNotas[1][4] - Tienda (F2_LOJA)
				// aNotas[1][5] - Condicion de Pago (F2_COND)
				// aNotas[1][6] - Codigo Uso CFDI (F2_USOCFDI)
				// aNotas[1][7] - Fecha Baja (F2_EMISSAO)
				// aNotas[1][8] - Item de del Activo (N1_ITEM)
				// aNotas[1][9] - Producto (N1_PRODUTO)
				// aNotas[1][10] - Cantidad bajada
				// aNotas[1][11] - Valor de Nota Fiscal
				// aNotas[1][12] - TES Salida
				// aNotas[1][13] - Reservado para Folio de NF generada
				// aNotas[1][14] - Modalidad
				//---------------------------------------------------------------
				cClass := oModelMaster:GetValue("FN6_NATURE")

				aAdd(aNotas, {oModelMaster:GetValue("FN6_CBASE"), cSerie, cCliente, cLoja, cCondPag, aCampos, dDataBase, oModelMaster:GetValue("FN6_CITEM"), cProduto, nQuant, nValNF, cTESSaida, "", cClass})
	
				AF036GenNF(@aNotas) //Se genera Factura de Venta
				
				lAchou := .F.
				If aNotas[1][1] == oModelMaster:GetValue("FN6_CBASE")
					If aNotas[1][8] == oModelMaster:GetValue("FN6_CITEM")
						lAchou := .T.
					EndIf
				EndIf
	
				If lAchou
					cNota := aNotas[1][13]
				EndIf
				
				If Empty(cNota)
					lOk := .F.
				EndIf
			ElseIf lGerPVBra
				//------------------------------------------------------
				// Estrutura do Array aNotas
				//------------------------------------------------------
				// aNotas[X][1] - Codigo base do Bem (N1_CBASE)
				// aNotas[X][2] - Numero da Nota Fiscal Gerada (F2_DOC)
				// aNotas[X][3] - Serie da Nota Fiscal (F2_SERIE)
				// aNotas[X][4] - Cliente (F2_CLIENTE)
				// aNotas[X][5] - Loja (F2_LOJA)
				// aNotas[X][6] - Condicao de Pagamento (F2_COND)
				// aNotas[X][7] - Array com os dados dos itens da nota
				// aNotas[X][7][X][1] - Item do Ativo (N1_ITEM)
				// aNotas[X][7][X][2] - Produto (N1_PRODUTO)
				// aNotas[X][7][X][3] - Quantidade Baixada
				// aNotas[X][7][X][4] - Valor do item na Nota Fiscal
				// aNotas[X][7][X][5] - TES Saida
				//------------------------------------------------------
				cClass := oModelMaster:GetValue("FN6_NATURE")	
	
				Aadd(aNotas,{oModelMaster:GetValue("FN6_CBASE"),""/*Número da NF*/,cSerie,cCliente,cLoja,cCondPag,{{oModelMaster:GetValue("FN6_CITEM"),cProduto,nQuant,nValNF,cTESSaida}}})
	
				A036GrvNF(cSerie,cCliente,cLoja,cCondPag,cProduto,nQuant,nValNF,cTESSaida,dBaixa,@aNotas,cClass,oModel)
	
				lAchou := .F.
				For nX := 1 To Len(aNotas)
	
					If aNotas[nX][1] == oModelMaster:GetValue("FN6_CBASE")
	
						For nY := 1 To Len(aNotas[nX][7])
	
							If aNotas[nX][7][nY][1] == oModelMaster:GetValue("FN6_CITEM")
	
								lAchou := .T.
								Exit
	
							 EndIf
	
						Next nY
	
						If lAchou
							Exit
						EndIf
	
					EndIf
	
				Next nX
	
				If lAchou
					cNota	:= aNotas[nX][2]
				EndIf

			ElseIf cPaisLoc == "BRA"
				//------------------------------------------------------
				// Estrutura do Array aNotas
				//------------------------------------------------------
				// aNotas[X][1] - Codigo base do Bem (N1_CBASE)
				// aNotas[X][2] - Numero da Nota Fiscal Gerada (F2_DOC)
				// aNotas[X][3] - Serie da Nota Fiscal (F2_SERIE)
				// aNotas[X][4] - Cliente (F2_CLIENTE)
				// aNotas[X][5] - Loja (F2_LOJA)
				// aNotas[X][6] - Condicao de Pagamento (F2_COND)
				// aNotas[X][7] - Array com os dados dos itens da nota
				// aNotas[X][7][X][1] - Item do Ativo (N1_ITEM)
				// aNotas[X][7][X][2] - Produto (N1_PRODUTO)
				// aNotas[X][7][X][3] - Quantidade Baixada
				// aNotas[X][7][X][4] - Valor do item na Nota Fiscal
				// aNotas[X][7][X][5] - TES Saida
				//------------------------------------------------------
	
	
				Aadd(aNotas,{oModelMaster:GetValue("FN6_CBASE"),""/*Número da NF*/,cSerie,cCliente,cLoja,cCondPag,{{oModelMaster:GetValue("FN6_CITEM"),cProduto,nQuant,nValNF,cTESSaida}}})
	
				AF036GerNF(cSerie, cCliente, cLoja , cCondPag, cProduto,nQuant ,nValNF,cTESSaida,dBaixa,aNotas)
	
				lAchou := .F.
				For nX := 1 To Len(aNotas)
	
					If aNotas[nX][1] == oModelMaster:GetValue("FN6_CBASE")
	
						For nY := 1 To Len(aNotas[nX][7])
	
							If aNotas[nX][7][nY][1] == oModelMaster:GetValue("FN6_CITEM")
	
								lAchou := .T.
								Exit
	
							 EndIf
	
						Next nY
	
						If lAchou
							Exit
						EndIf
	
					EndIf
	
				Next nX
	
				If lAchou
					cNota	:= aNotas[nX][2]
				EndIf
			EndIf

			If Empty(cNota)
				If cPaisLoc != "EQU"
					oModel:SetErrorMessage("",,oModel:GetId(),"","GERNF",STR0139)		//"O processo de baixa foi interrompido, pois não foi possível criar a nota fiscal de venda."
				Else
					oModel:SetErrorMessage("",,oModel:GetId(),"","GERNF",STR0173)		//"La funcionalidad de Facturar Activo no existe para su país."
				EndIf
				lOk := .F.
			EndIf

		EndIf
		
		If lOk
			
			/*
			* Transferencia Interna é contabilizada pelos lanc da rotina ATFA060
			*/
			If !FWIsInCallStack("ATFA060") .AND. MV_PAR03 == 1
				If nHdlPrv <= 0
					nHdlPrv := HeadProva(cLoteAtf,"ATFA036",Substr(cUsername,1,6),@cArquivo)
				Endif
			EndIf
			
			FN6->(RecLock("FN6",.T.))
				FN6->FN6_FILIAL	:= FWxFilial("FN6")
				FN6->FN6_CODBX	:= oModelMaster:GetValue("FN6_CODBX")
				FN6->FN6_CBASE	:= oModelMaster:GetValue("FN6_CBASE")
				FN6->FN6_CITEM	:= oModelMaster:GetValue("FN6_CITEM")
				FN6->FN6_MOTIVO	:= oModelMaster:GetValue("FN6_MOTIVO")
				FN6->FN6_QTDATU	:= oModelMaster:GetValue("FN6_QTDATU")
				FN6->FN6_QTDBX	:= oModelMaster:GetValue("FN6_QTDBX")
				FN6->FN6_PERCBX	:= oModelMaster:GetValue("FN6_PERCBX")
				FN6->FN6_DTBAIX	:= oModelMaster:GetValue("FN6_DTBAIX")
				FN6->FN6_DEPREC	:= oModelMaster:GetValue("FN6_DEPREC")
				FN6->FN6_NUMNF	:= cNota
	
				If oModelMaster:GetValue("FN6_GERANF") == "1"
					SerieNfId('FN6',1,'FN6_SERIE',oModelMaster:GetValue("FN6_DTBAIX"),,cSerie)
				Else
					SerieNfId('FN6',1,'FN6_SERIE',,,oModelMaster:GetValue("FN6_SERIE"))
				Endif
	
				FN6->FN6_LOTE	:= oModelMaster:GetValue("FN6_LOTE")
				FN6->FN6_ITEMNF	:= oModelMaster:GetValue("FN6_ITEMNF")
				FN6->FN6_STATUS	:= oModelMaster:GetValue("FN6_STATUS")
				FN6->FN6_FILORI	:= oModelMaster:GetValue("FN6_FILORI")
				FN6->FN6_GERANF	:= oModelMaster:GetValue("FN6_GERANF")
				FN6->FN6_CLIENT	:= oModelMaster:GetValue("FN6_CLIENT")
				FN6->FN6_LOJA	:= oModelMaster:GetValue("FN6_LOJA")
				FN6->FN6_VALNF	:= oModelMaster:GetValue("FN6_VALNF")
				FN6->FN6_CNDPAG	:= oModelMaster:GetValue("FN6_CNDPAG")
				FN6->FN6_TESSAI	:= oModelMaster:GetValue("FN6_TESSAI")
				FN6->FN6_NATURE	:= oModelMaster:GetValue("FN6_NATURE")
				If lIsRussia
					FN6->FN6_SOCURR	:= oModelMaster:GetValue("FN6_SOCURR")
				EndIf
				If cPaisLoc == "MEX"
					FN6->FN6_USOCFD	:= oModelMaster:GetValue("FN6_USOCFD")
				EndIf
				If cPaisLoc == "PER" .And. lExisCpo
					FN6->FN6_TPDOC	:= oModelMaster:GetValue("FN6_TPDOC")
					FN6->FN6_TIPONF	:= oModelMaster:GetValue("FN6_TIPONF")
				EndIf
				If cPaisLoc == "COL" .And. lExisCpo
					FN6->FN6_CODMUN	:= oModelMaster:GetValue("FN6_CODMUN")
					FN6->FN6_TPACTI	:= oModelMaster:GetValue("FN6_TPACTI")
					FN6->FN6_TRMPAC	:= oModelMaster:GetValue("FN6_TRMPAC")
					FN6->FN6_TIPOPE	:= oModelMaster:GetValue("FN6_TIPOPE")
				EndIf
			
			FN6->(MsUnLock())
			
			For nCtnTipo := 1 to oModelTipo:Length()
				/*
				* Posiciona no primeiro tipo de ativo
				*/
				oModelTipo:GoLine( nCtnTipo )
				
				/*
				* Grava somente os registros marcados no grid FN7TIPOS
				*/
				If oModelTipo:GetValue("OK" , nCtnTipo)
					
					cBase	:= oModelTipo:GetValue("FN7_CBASE")
					cItem	:= oModelTipo:GetValue("FN7_CITEM")
					cTipo	:= oModelTipo:GetValue("FN7_TIPO")
					cTpSld	:= oModelTipo:GetValue("FN7_TPSALD")
					cModSeq	:= oModelTipo:GetValue("FN7_SEQ")
					cSeqReav:= oModelTipo:GetValue("FN7_SEQREA")
					
					If ! RusCheckRevalFunctions()
						//--------------------------------------------------------------------------
						// Definido o indice 11 da SN3 no começo da funcao
						// N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV
						//--------------------------------------------------------------------------
						SN3->(dbSeek( cSN3Fil + cBase + cItem + cTipo + "0" + cTpSld + cModSeq + cSeqReav ) )
					EndIf
					
					nQtdOrig		:= oModelMaster:GetValue("FN6_QTDATU")
					lCtbBxInt		:= .F.
					cIDMOV			:=  GetSXENum("SN4","N4_IDMOV",,6)
					lMovCiap		:= .T.
					cNFItem			:= oModelMaster:GetValue("FN6_ITEMNF")
					dBaixa036		:= oModelMaster:GetValue("FN6_DTBAIX")
					cMotivo			:= oModelMaster:GetValue("FN6_MOTIVO")
					
					/*
					* Faz a gravação e gera novo registro caso seja baixa parcial
					*/
					cSeq := Af036Grava(cAlsAtu, cNota, cSerie,nQuant,nQtdOrig,lCtbBxInt,cIDMOV,lMovCiap,cNFItem,dBaixa036,cMotivo,oModel,lQuant,@nHdlPrv,@nTotal,cLanc,aFlagCTB,@lAtuCiap)
					
					If lIsRussia
						aAdd(aFARules, {cBase, cItem})
					EndIf
					
					nMax := oModelValor:Length()
					nCont := 1
					For nCtnValor := 1 to oModelValor:Length()
						/*
						* Posiciona na primeira moeda
						*/
						oModelValor:GoLine( nCtnValor )
						
						If oModelValor:GetValue("FN7_VLATU") != 0
							/*
							* Inicia a gravação do registro de baixa dos saldos do ativo.
							*/
							FN7->(RecLock("FN7" , .T.))
								FN7->FN7_FILIAL	:= oModelValor:GetValue("FN7_FILIAL")
								FN7->FN7_CODBX	:= oModelValor:GetValue("FN7_CODBX" )
								FN7->FN7_ITEM	:= PADL(nCont,nTamItem,"0")
								FN7->FN7_CBASE	:= oModelValor:GetValue("FN7_CBASE"	)
								FN7->FN7_CITEM	:= oModelValor:GetValue("FN7_CITEM"	)
								FN7->FN7_TIPO	:= oModelTipo:GetValue("FN7_TIPO" )
								FN7->FN7_TPSALD	:= oModelValor:GetValue("FN7_TPSALD" )
								FN7->FN7_SEQ	:= cSeq
								FN7->FN7_SEQREA	:= oModelValor:GetValue("FN7_SEQREA" )
								FN7->FN7_MOTIVO	:= oModelMaster:GetValue("FN6_MOTIVO")
								FN7->FN7_DTBAIX	:= oModelMaster:GetValue("FN6_DTBAIX")
								FN7->FN7_MOEDA	:= oModelValor:GetValue("FN7_MOEDA"	)
								FN7->FN7_VLATU	:= oModelValor:GetValue("FN7_VLATU"	)
								FN7->FN7_VLDEPR	:= oModelValor:GetValue("FN7_VLDEPR" )
								FN7->FN7_VLBAIX	:= oModelValor:GetValue("FN7_VLBAIX" )
								FN7->FN7_PERCBX	:= oModelValor:GetValue("FN7_PERCBX" )
								FN7->FN7_FILORI	:= oModelValor:GetValue("FN7_FILORI" )
								FN7->FN7_STATUS	:= oModelValor:GetValue("FN7_STATUS" )
								FN7->FN7_VLRESI	:= oModelValor:GetValue("FN7_VLRESI" )
							FN7->(MsUnlock("FN7"))
							nCont++
						EndIf
					Next nCtnValor
				EndIf
			Next nCtnTipo
			
			//---------------------------------------------------------
			//	Integração com MNT 
			//---------------------------------------------------------
			If cMV_NGMNTAT $ "123"  .And. !Empty(FN7->FN7_CBASE) 
				dbSelectArea( "ST9" )
				ST9->(dbSetOrder( 1 ))
						
				IF ST9->(dbSeek( cFilST9 +AllTrim(FN7->FN7_CBASE) ))							
					ST9->(RecLock("ST9",.F.))
					ST9->T9_SITMAN := "I"
					ST9->(MsUnLock())							
				EndIf
										
			EndIf
			
			If !FWIsInCallStack("ATFA060") .AND. MV_PAR03 == 1
				If nHdlPrv > 0 .And. ( nTotal > 0 )
					RodaProva(nHdlPrv, nTotal)
					cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,mv_par01 == 1,mv_par02 == 1,,,,aFlagCTB)
				Endif
			EndIf
			
		EndIf
		
		//------------------
		// Executa Rollback 
		//------------------
		If !lOk
			DisarmTransaction()
		EndIf
        
	END TRANSACTION
	
	PcoFinLan(cLanc)
	
	If cPaisLoc $ "MEX|PER|COL" .And. lOk .And. lGeraNF
		oView := FWViewActive()
		If oView <> Nil
			oView:ShowUpdateMsg(.T.)
			oView:SetUpdateMessage(STR0149, STR0164 + cSerie +  RTrim(cNota)) //"Atención"- "El proceso ha finalizado con éxito y se ha generado el documento: "
		EndIf
	EndIf
	
ElseIf  __nOper == OPER_CANC

	//-------------------------------------------------------------------------------------------------------------------
	// Caso a baixa tenha gerado nota, verifica se houve mais de um item por NF (baixa em lote com nota por codigo base)
	//-------------------------------------------------------------------------------------------------------------------
	If lOk .And. FN6->FN6_GERANF == "1" .And. !Empty(FN6->FN6_NUMNF) .And. !Empty(FN6->FN6_SERIE)

		aItensNF := AF036ItnNF(FN6->FN6_FILORI,FN6->FN6_NUMNF,FN6->FN6_SERIE)

	EndIf

	//-----------------------------------------------------------------------------------------------------------
	// Para cancelamento de mais de um ativo (atrelados a uma nota), utiliza-se o cancelamento multiplo ATFA036M
	//-----------------------------------------------------------------------------------------------------------
	If Len(aItensNF) > 1

		lOk := AF036CaOut(aItensNF)

	Else

		BEGIN TRANSACTION
		
			cFN6FilOri	:= FN6->FN6_FILORI
			cFN6CBase	:= FN6->FN6_CBASE
			cFN6Item	:= FN6->FN6_CITEM
			nFN6QtdBx	:= FN6->FN6_QTDBX

			If lIsRussia
				aAdd(aFARules, {cFN6CBase, cFN6Item})
			EndIf

			//---------------------------------------
			// Validacao e exclusao do Pedido e Nota
			//---------------------------------------
			If lOk .And. !Empty(FN6->FN6_NUMNF) .And. !Empty(FN6->FN6_SERIE)
				lOk := A036VlNota(FN6->FN6_NUMNF,FN6->FN6_SERIE,FN6->FN6_CLIENT,FN6->FN6_LOJA)
			EndIf
		
			If lOk
				//Retorna o model ativo para o atfa036
				FWModelActive(oModel)
				/*
				* Transferencia Interna é contabilizada pelos lanc da rotina ATFA060
				*/
				If !FWIsInCallStack("ATFA060")
					If nHdlPrv <= 0
						nHdlPrv := HeadProva(cLoteAtf,"ATFA036",Substr(cUsername,1,6),@cArquivo)
					Endif
				EndIf
				dbSelectArea("FN7")
				FN7->(DbSetOrder(1)) // Filial + Código de Baixa
				If FN7->(DbSeek(cFilFN7 + FN6->FN6_CODBX ) )
					While lOK .And. FN7->(!Eof()) .AND. cFilFN7 + FN6->FN6_CODBX == FN7->FN7_FILIAL + FN7->FN7_CODBX										
						//---------------------------------------------------------
						//	Integração com MNT 
						//---------------------------------------------------------
						If cMV_NGMNTAT $ "123"  .And. !Empty(FN7->FN7_CBASE) 
							dbSelectArea( "ST9" )
							ST9->(dbSetOrder( 1 ))
						
							IF ST9->(dbSeek( cFilST9 +AllTrim(FN7->FN7_CBASE) ))							
								ST9->(RecLock("ST9",.F.))
								ST9->T9_SITMAN := "A"
								ST9->(MsUnLock())							
							EndIf
										
						EndIf
										
						aBusca:= {}
						aAdd(aBusca,{"FN7_TIPO",FN7->FN7_TIPO})
						aAdd(aBusca,{"FN7_TPSALD",FN7->FN7_TPSALD})
					
						If oModelTipo:SeekLine(aBusca)
							If oModelTipo:GetValue("OK")
								If FN7->FN7_MOEDA == '01'
									lOk := AF036Cance(FN6->FN6_CBASE,FN6->FN6_CITEM,FN7->FN7_TIPO,FN7->FN7_TPSALD,FN6->FN6_DTBAIX,FN7->FN7_SEQ,FN7->FN7_MOTIVO,@nHdlPrv,@nTotal,FN7->FN7_CODBX,nil,FN6->FN6_NUMNF,FN6->FN6_SERIE,FN6->FN6_CLIENT,FN6->FN6_LOJA)
								EndIf
								FN7->(RecLock("FN7",.F.))
								FN7->FN7_STATUS := '2'
								FN7->(MsUnLock())
							EndIf
						EndIf
					
						FN7->(DbSkip())
					EndDo
				EndIf
			EndIf
		
			If lOk
				FN6->(RecLock("FN6",.F.))
				FN6->FN6_STATUS := '2'
				FN6->(MsUnLock())
				/*
				Caso a baixa tenha sido em lote, verifica se todos os ativos desse lote tambem tiveram a baixa cancelada e, sendo este o caso, 
				cancela o lote. */
				AF036CaFN8(FN6->FN6_FILIAL,FN6->FN6_LOTE)
				/*-*/
			EndIf
		
			If lOk
				If lExisCPC31
					SN1->(RecLock("SN1"))
					SN1->N1_BLQDEPR := ""  
					SN1->(MsUnlock())
				Endif
			Endif

			If lOk .AND. !FWIsInCallStack("ATFA060") .AND. MV_PAR03 == 1
				If nHdlPrv > 0 .And. ( nTotal > 0 )
					RodaProva(nHdlPrv, nTotal)
					cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,mv_par01 == 1,mv_par02 == 1,,,,aFlagCTB)
				Endif
			EndIf

			//-----------------------------------
			// Integracao com Gestao de Servicos
			//-----------------------------------
			If lOk .And. GetNewPar("MV_TECATF","N") == "S"
				lOk := TcBxATF(cFN6FilOri,cFN6CBase,cFN6Item,nFN6QtdBx,.F.)
			EndIf

			//-------------------------------------
			// Rollback caso haja erro no processo
			//-------------------------------------
			If !lOk
				DisarmTransaction()
			EndIf

		END TRANSACTION

	EndIf

EndIf

// Confirma o cCodBaixa
While (GetSx8Len() > nSaveSx8Len)
	ConfirmSX8()
Enddo

If lIsRussia .And. lOk
	ProcFARules(aFARules)

	If ! IsBLind()
		cInvMsg		:= ""
		For nX := 1 To Len(aSaleInvs)
			cInvMsg	+= IIf(Empty(cInvMsg), "", ", ")
			cInvMsg	+= aSaleInvs[nX]
		Next nX
		If ! Empty(cInvMsg)
			MsgInfo(STR0162 + cInvMsg)	// "The following invoices were generated as sale: "
		EndIf
	EndIf
EndIf

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036DtBx

Verifica validade da data da baixa

@author felipe.cunha
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036DtBx(lDesmarca,lDtLote,oMdl)
// FWModelEvent:Activate will not set ATFA036 model as active before
//  Calling this function as trigger
Local oModel			:= IIf(Empty(oMdl), FWModelActive(), oMdl)
Local oModelPrincipal	:= oModel:GetModel()
Local oModelMaster		:= Nil												// Carrega Model Master
Local oModelTipo		:= oModel:GetModel("FN7TIPO")					// Carrega Model Tipo
Local oModelLote		:= Nil								
Local cRegraBx			:= ALLTRIM(GETMV("MV_ATFBXDP",.F.,"0"))		 
Local cCalcDep			:= GetNewPar("MV_CALCDEP",'0') 					// '0'-Mensal, '1'-Anual
Local lRet				:= .T.												// Retorno
Local lOcorr			:= .F.												 
Local lGspInUseM		:= If(Type('lGspInUse')=='L', lGspInUse, .F.)	// 
Local dUltDepr			:= GetMV("MV_ULTDEPR")							// Data Ult Depreciacao
Local dDataBx			:= CTOD("  /  /  ")								// Carrega valores do model
Local dDataBloq 		:= GetNewPar("MV_ATFBLQM",CTOD(""))			// Data de Bloqueio da Movimentação - MV_ATFBLQM
Local cFilSN4			:= FWxFilial("SN4")
Local aArea				:= GetArea()
Local aAreaSN4			:= SN4->(GetArea())
Local aAreaSN3			:= SN3->(GetArea())
Local lRetDepr 			:= .F.
Local lAF036DEP 		:= ExistBlock("AF036DEP")
Local cFilShare			:=""

Default lDesmarca		:= .T.
Default lDtLote			:= .T.

If __nOper != OPER_VISUA .AND. __nOper != OPER_CANC .And. __nOper != OPER_CANLT

	If oModelPrincipal:getid() == "ATFA036L"
		oModelLote 	:= oModel:GetModel("FN8LOTE")
		oModelMaster:= oModel:GetModel('FN6ATIVOS')
		If lDtLote
			dDataBx	:= oModelLote:GetValue("FN8_DTBAIX")
		Else
			dDataBx	:= oModelMaster:GetValue("FN6_DTBAIX")
		Endif
		cFilShare	:= oModelMaster:GetValue("FN6_FILORI")
		cFilShare	:= FWxFilial("SN3",cFilShare)
	ElseIf oModelPrincipal:getid() == "ATFA036"
		oModelMaster:= oModel:GetModel('FN6MASTER')
		dDataBx		:= oModelMaster:GetValue("FN6_DTBAIX")
		cFilShare		:= xFilial("SN3")
	EndIf
	
	
	cBase 		:= oModelMaster:GetValue("FN6_CBASE")
	cItem 		:= oModelMaster:GetValue("FN6_CITEM")
	cTipo 		:= oModelTipo:GetValue("FN7_TIPO")
	cTipoSLD 	:= oModelTipo:GetValue("FN7_TPSALD")
	SN3->(dbSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV
	If RusCheckRevalFunctions() .Or. SN3->(dbSeek(cFilShare + cBase + cItem + cTipo + '0' + cTipoSLD ))
	
		/*
		 * Se for GSP, pega o ultimo dia do mes anterior
		 */
		If lGspInUseM
			dUltDepr := MsSomaMes(dUltDepr,-1,.T.)
		Endif
		
		If lAF036DEP
			lRetDepr := ExecBlock("AF036DEP", .F., .F.,{dUltDepr,dDataBx})
		EndIf
	
		/*
		 * Verifica se a data da Baixa é valida
		 */
		If !Empty(dDataBx) .AND. (dDataBx <= dDataBloq)
			HELP(" ",1,"AF036BLQM",,STR0026 + DTOC(dDataBloq) ,1,0)    //"A data de aquisição do bem é igual ou menor que a data de bloqueio de movimentação : "
			lRet := .F.
		ElseIF Empty(dDataBx) .OR. dDataBx < SN3->N3_AQUISIC
			If cCalcDep == "0"
				Help(" ",1,"AFDTBAIXA")
			Else
				Help(" ",1,"AFDTBAIXA2")
			EndIf
			lRet := .F.
		ElseIf cRegraBx == "0"
			If cCalcDep == "0"
			/*
			 * Conforme regra padrao, nao aceita movimentos fora do mes posterior   
			 * ao último cálculo de depreciação, e nem anteriores ao último cálculo 
			 */
				If !lRetDepr // Retorno ponto de entrada AF036DEP 
					If dDataBx >  LastDay(dUltDepr+1) .OR. (dDataBx <= dUltDepr .And. ! RusCheckRevalFunctions())
						Help(" ",1,"AFDTBAIXA")
						lRet := .F.
					EndIf
				EndiF
			Else
				If Year(dDataBx) >  Year(dUltDepr)+1 .OR. dDataBx <= dUltDepr
					Help(" ",1,"AFDTBAIXA2")
					lRet := .F.
				EndIf
			EndIf
	
			IF lRet
			/*
			 * Verifica se a data da baixa nao e' anterior a ultima baixa do bem
			 * Caso encontre alguma movimentacao com a data da ultima depreciacao,
			 * significa que, existem movimentacoes de calculos de depreciacao ou
			 * correcao.
			 */
				dbSelectArea("SN4")
				SN4->(dbSeek( cFilSN4 + SN3->N3_CBASE + SN3->N3_ITEM + SN3->N3_TIPO + DtoS(dULTDEPR),.T.))
				While SN4->(!EOF()) .And. SN4->N4_FILIAL ==  cFilSN4 .And. ;
						SN4->N4_CBASE	==  SN3->N3_CBASE	.And. ;
						SN4->N4_ITEM	==  SN3->N3_ITEM	.And. ;
						SN4->N4_TIPO	==  SN3->N3_TIPO
					IF SN4->N4_DATA > dDataBx
						lOcorr := .T.
						Exit
					EndIf
					SN4->(dbSkip())
				EndDo
	
			/*
			 * Não aceita a data da baixa se houver ocorrência de baixa a posterior ou movimentação com a data da última depreciação. Verificar a data da baixa.                                                                 
			 */
				IF lOcorr
					If cCalcDep == "0"
						Help(" ",1,"AFDTBAIXA")
					Else
						Help(" ",1,"AFDTBAIXA2")
					EndIf
					lRet := .F.
				EndIf
			EndIf
		ElseIf cRegraBx == "1"
			If cCalcDep == "0"
			/*
			 * Verifica se a data da baixa está entre os meses imediatamente anterior e imediatamente posterior ao último cálculo de depreciação 
			 */
				If dDataBx > LastDay(dUltDepr+1)
					Help(" ",1,"AFDTBAIXA")
					lRet := .F.
				EndIf
			Else
				If Year(dDataBx) >  Year(dUltDepr)+1
					Help(" ",1,"AFDTBAIXA2")
					lRet := .F.
				EndIf
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf
	//Validacao para o bloqueio do proceco
	If lRet .And. !CtbValiDt(,dDataBx ,,,,{"ATF001"},)
		lRet := .F.
	EndIf
	
	If !lRet .And. lDesmarca
		/*
		 * Atribuido valor direto no model, evitando a chamada da função mais de uma vez, por conta da alteração do grid 
		 * Não usar SetValue nesta situação
		 */
		oModelTipo:LoadValue( 'OK' , .F. )
	EndIf
EndIf

			
RestArea(aAreaSN4)
RestArea(aAreaSN3)
RestArea(aArea)	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Af036Grava

Atualiza tela de sele‡ao de registros da baixa autom tica

@author felipe.cunha
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function Af036Grava(cAlias, cNota, cSerie,nQuant,nQtdOrig,lCtbBxInt,cIDMOV,lMovCiap,cNFItem,dBaixa036,cCodMot,oModel,lQuant,nHdlPrv,nTotal,cLanc,aFlagCTB,lAtuCiap)
Local aArea			:= GetArea()
Local oModelValor	:= oModel:GetModel("FN7VALOR")
Local oModelMaster  := oModel:GetModel(If(FWIsInCallStack("AF036BxLote") .or.lAtf030,"FN6ATIVOS", "FN6MASTER"))
Local nPropSF9  	:= 0
Local nVlrSFA   	:= 0
Local nFatorSFA 	:= 0
Local nRegSN3   	:= 0
Local nVlOrig   	:= 0
Local cTipoCorr 	:= ""
Local cBase     	:= ""
Local cItem     	:= ""
Local lCredito  	:= .F.
Local cTipoImob		:= ""
Local nX			:= 0
Local aValorMoed	:= {}
Local cTpSaldo		:= ""
Local cOcorr 		:= ""
Local aDadosComp 	:= {}
Local aValores   	:= {}
Local dLei102 		:= SuperGetMv("MV_DATCIAP",.F.,ctod("01/01/2001"))
Local cMoedaAtf 	:= SuperGetMv("MV_ATFMOEDA")
Local nMoedaATF		:= Val(cMoedaAtf)
Local lUsaMNTAT		:= Iif(ALLTRIM(SuperGetMv("MV_NGMNTAT",.F.,"N")) $ "1/3",.T.,.F.) // N-NAO INTEGRA / 1-ALTERACOES NO ATF REPLICARAO NO MNT / 2-ALTERACOES NO MNT REPLICARAO NO ATF / 3-ALTERACOES ATUALIZARAO ATF E MNT
Local cSeqReav		:= ''
Local nSavRec 		:= 0
Local cSeq  		:= ''
Local nTotDepr		:= 0
Local cLoteAtf		:= LoteCont("ATF")

/*
 * Rateio e sua contabilizacao da ficha de ativo
 */
Local aRateio	:= {}
Local lCtbRat	:= .F.					// Contabiliza Rateio
Local lLP_Rat	:= VerPadrao("81E")		// Lanc Padrão para Rateio

/*
 * AVP
 */
Local lAtfa060 := FWIsInCallStack("ATFA060")

/*
 * Verificação se a classificação de ativo sofre depreciação
 */
Local lAtClDepr		:= .F.
Local cMotSF9		:= ""	// Motivos a serem gravados no F9_MOTIVO/FA_NOTIVO
Local cFilSN3		:= FWxFilial("SN3")
Local cMoed			:= ''
Local cArquivo		:= ""
Local nVlVend		:= Iif(ExistBlock( "AF036VAL" ),ExecBlock("AF036VAL",.F.,.F.), 0)
Local nQtdMoedas 	:= AtfMoedas()			// Verifica quantidade de moedas
Local nValCorr		:= 0
Local nValCorDep	:= 0
Local nTotBaix		:= 0
Local aValBaixa		:= {}
Local aValDepr		:= {}
Local nVenda		:= 0
Local aValBx		:= AtfMultMoe(,,{|x| 0})
Local aTxMedia		:= aClone(aValBx)
Local aAtfMultM		:= aClone(aValBx)
Local lCalcChi		:= FWIsInCallStack("ATFA031")
Local lOnOff		:= MV_PAR03 == 1
Local cPadrao		:= ''
Local lPreGrv		:= ExistBlock("AF036PRC")
Local lPosGrv		:= ExistBlock("AF036POC")
Local cTypes10		:= IIF(lIsRussia,"*" + AtfNValMod({1}, "*"),"") // CAZARINI - 14/03/2017 - If is Russia, add new valuations models - main models
Local cTypes12		:= IIF(lIsRussia,"/" + AtfNValMod({2}, "/"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - recoverable models
Local aN3Tipo 		:= {}	
Local nPosTipo 		:= 0
Local nRecnoSN4		:= 0
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local lPulaCiap     := .F.
Local cTipoPos		:= ''
Local cCliente		
Local cLoja
Local cCNPJCli	
Local cInscEstad	
Local aCliente		:= {}

Default lAtuCiap := .T.

If cPaisLoc == "BOL" .AND. TYPE("nVlCor")  == "N" .AND. nVlCor <> 0 
	 nValCorr := nVlCor
EndIf
If cPaisLoc == "BOL" .AND. TYPE("nVlCorDep")  == "N" .AND. nVlCorDep <> 0 
	 nValCorDep	:= nVlCorDep
EndIf
/*
 * Ponto de Entrada chamado na Pré-Gravação dos dados baixa de ativo.
 * Substituindos os pontos de entrada ATFA030 e ATFA035.
 */
If lPreGrv
	ExecBlock("AF036PRC",.F.,.F.)
EndIf

AtfMultMoe(,,{|x| aAdd(aValBaixa,oModelValor:GetValue("FN7_VLBAIX",x))})
AtfMultMoe(,,{|x| aAdd(aValDepr,oModelValor:GetValue("FN7_VLDEPR",x))})

/*
 * Gera um novo sequencial a apartir do £ltimo sequencial gerado
 */
Default lCtbBxInt	:= .F. // Contabiliza baixa na integração
Default cIDMOV		:= ""
Default lMovCiap	:= .T.
Default cNFItem 	:= " "
Default cLanc       :="000370"
Default aFlagCTB	:= {}

cSeqReav	:= SN3->N3_SEQREAV
nSavRec	    := SN3->( Recno() )
cBase		:= SN3->N3_CBASE
cItem		:= SN3->N3_ITEM
cSeq		:= SN3->N3_SEQ
cMotivo	    := oModelMaster:GetValue('FN6_MOTIVO')
cTipoPos	:= SN3->N3_TIPO

If lAtfa060 .And. !Empty(SN1->N1_CODCIAP)

	cCNPJCli		:= GetAdvFVal("SM0","M0_CGC",cEmpAnt + FNR->FNR_FILDES)
	cInscEstad		:= GetAdvFVal("SM0","M0_INSC",cEmpAnt + FNR->FNR_FILDES)
	aCliente		:= AF36CNPJCLI(cCNPJCli, cInscEstad)
	cCliente		:= IIF(!Empty(aCliente), aCliente[1], GetAdvFVal("SA1","A1_COD",XFilial("SA1")+cCNPJCli,3) ) //A1_FILIAL+A1_CGC
	cLoja			:= IIF(!Empty(aCliente), aCliente[2], GetAdvFVal("SA1","A1_LOJA",XFilial("SA1")+cCNPJCli,3) ) //A1_FILIAL+A1_CGC

Else
	cCliente	:= oModelMaster:GetValue("FN6_CLIENT")
	cLoja		:= oModelMaster:GetValue("FN6_LOJA")
EndIf

//Busca item nota fiscal de saída
If ! Empty(cNota) 
	
	SD2->(dbSetorder(3))	// D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	If SD2->(dbSeek(xFilial("SD2") + cNota + cSerie + cCliente + cLoja + SN1->N1_PRODUTO))
		cNFItem := SD2->D2_ITEM
	EndIf

EndIf


If lExisCPC31 == Nil
	lExisCPC31 := SN1->(Fieldpos("N1_BLQDEPR")) > 0 .And. cPaisLoc == "BRA" //CPC31, VERIFICA SE O CAMPO EXISTE NA BASE E SE ? DA LOCALIDADE DO BRASIL
EndIF

If lIsRussia .and. FWisincallstack("ATFA036RUS") .and. valtype(oModel:GetModel('PARAMETROS'))=="O" .and. oModel:GetModel('PARAMETROS'):GetValue("DEPRBONUS") == 1
	cMotivo:="99"
endif

If !FWIsInCallStack("AF012CVMet")
	If SN3->N3_TIPO $ ("01*10" + cTypes10)    // Aquisi‡„o
		cPadrao := "810"
	ElseIf SN3->N3_TIPO $ "02,05"    // Reavalia‡„o
		cPadrao := "811"
	ElseIf SN3->N3_TIPO $ "03*13"      // Adiantamento
		cPadrao := "812"
	ElseIf SN3->N3_TIPO == "04"      // Lei 8200 (Dif. BTN/IPC)
		cPadrao := "813"
	Else
		cPadrao := "81A" 					// Baixa de outros tipos de ativos
	EndIf
EndIf	

/*
 * Atualiza o Cadastro de CIAP
 */
dbSelectArea("SF9")
SF9->(dbSetOrder(1))
If SF9->( dbSeek(xFilial("SF9")+SN1->N1_CODCIAP) ) .And. lMovCiap .And. (SF9->F9_VLESTOR + SF9->F9_BXICMS) < SF9->F9_VALICMS
	If ( SF9->F9_DTENTNE >= dLei102 )
		lCredito:= .T.
	Else
		lCredito:= .F.
	EndIf
	
	/*
	 * Guarda o RECNO do registro posicionado
	 */
	dbSelectArea("SN3")
	SN3->(dbSetOrder(1))	
	nRegSN3 := SN3->(Recno())
	
	SN3->(dbSeek(cFilSN3+SN1->N1_CBASE+SN1->N1_ITEM))

	While SN3->(!Eof()) .And. cFilSN3 == SN3->N3_FILIAL .And. SN1->N1_CBASE == SN3->N3_CBASE  .And. SN1->N1_ITEM  == SN3->N3_ITEM .And. lAtuCiap 
		If ( SN3->N3_TIPO $ ("01*03*10" + cTypes10) )
			nVlOrig += &('SN3->N3_VORIG' + cMoedaAtf)
			aAdd(aN3Tipo,{SN3->N3_TIPO, &('SN3->N3_VORIG' + cMoedaAtf), SN3->(Recno())})	
		EndIf
		SN3->(dbSkip())
	EndDo
	/*
	 * O valor referente ao CIAP deve ser considerado por BEM  não por tipo de bem.
	 * Este calculo deve ser feito para bens que possuem os tipos 01, 10 ou 03. 
	 * Encontrando um dos tipos que estão configurados para calculo do CIAP o valor dos demais tipos deve ser desconsiderado. 
	 * A ordem de pesquisa deve ser 01, 10, 03 (alinhado com o fiscal e documentado na issue DSERCTR1-13619 pelo P.O.)
	*/
	If lIsRussia
		/*
	 	 * Restaura o registro posicionado
	 	 */
		SN3->(dbGoto(nRegSN3))
	Else	
		If (nPosTipo:=aScan(aN3Tipo,{|x| x[1]=="01"})) > 0 
			nVlOrig :=  aN3Tipo[nPosTipo][2]
			If cTipoPos == aN3Tipo[nPosTipo][1]
				SN3->(dbGoto(aN3Tipo[nPosTipo][3]))
			Else
				lPulaCiap := .T. // QUANDO O ATIVO CONTER OS TIPOS 01 E 10 E TIVER BAIXANDO SOMENTE O TIPO 10 NÃO DEVE ALTERAR O CIAP 
			EndIf
		ElseIf (nPosTipo:=aScan(aN3Tipo,{|x| x[1]=="10"})) > 0
			nVlOrig :=  aN3Tipo[nPosTipo][2]
			SN3->(dbGoto(aN3Tipo[nPosTipo][3]))
		ElseIf (nPosTipo:=aScan(aN3Tipo,{|x| x[1]=="03"})) > 0
			nVlOrig :=  aN3Tipo[nPosTipo][2]
			SN3->(dbGoto(aN3Tipo[nPosTipo][3]))
		Else
			SN3->(dbGoto(nRegSN3))
		EndIf

		lAtuCiap := .F.
	EndIf
	
	If !lPulaCiap // bem com tipo 10 que também possui tipo 01

		//SF9->VALICMS = Valor TOTAL de ICMS que tenho direito a crédito - ICMS de Imobilização(F9_ICMIMOB)+ ICMS de frete + ICMS ST etc.
		//ICMSIMOB = N1_ICMSAPR (Se existir ICMS os valores são iguais) =  ICMS  de Imobilização 
		//SF9->VLESTOR - Valor ja apropriado do ICMS(rotina do fiscal - MATA906) 
		//SF9->BXICMS - 1 - Baixa total   - (F9_VALICMS - (F9_VLESTOR + F9_BXICMS)* 1) ) 
		//              2 - Baixa Parcial - (F9_VALICMS - (F9_VLESTOR + F9_BXICMS)* (% de BX do Ativo) ) 
		//  Obs: na baixa total, independente do motivo de baixa, o campo F9_SLDPARC deve ser atualizado com 0. O direito
		//       a crédito do ICMS acabou.

		nQtdOrig := Iif(Round(nQtdOrig, 2) == 0.00, 1, nQtdOrig)
		IF (SF9->F9_VALICMS - (SF9->F9_VLESTOR + SF9->F9_BXICMS)) > 0
			nPropSF9 := ((SF9->F9_VALICMS - (SF9->F9_VLESTOR + SF9->F9_BXICMS))*(nQuant/nQtdOrig))
			// baixou tudo e tem saldo icm
			If Round(nPropSF9, 2) == 0.00 .and. Round((SF9->F9_VALICMS- (SF9->F9_VLESTOR + SF9->F9_BXICMS)), 2) > 0.00
			nPropSF9 := (SF9->F9_VALICMS - (SF9->F9_VLESTOR + SF9->F9_BXICMS))
			Endif
		Endif
		If Round((nPropSF9 + SF9->F9_VLESTOR + SF9->F9_BXICMS), 2) > Round(SF9->F9_VALICMS, 2)
			nPropSF9 := (SF9->F9_VALICMS - (nPropSF9 + SF9->F9_VLESTOR + SF9->F9_BXICMS))
		EndIf
		nFatorSFA	:= (Year(SF9->F9_DTENTNE) + If(lCredito,4,5) - Year(dBaixa036) )
		//nVlrSFA  	:= Round(nPropSF9 * nFatorSFA * IIf(lCredito,0.25,0.20) - ((SF9->F9_VLESTOR+IIF(SF9->F9_BXICMS > 0,SF9->F9_BXICMS,0) )*oModelMaster:GetValue('FN6_PERCBX')/100 ) , 4) //Pega a % do ICMS TOTAL - O ICMS do que já foi estornado + Baixa realizada	
		nVlrSFA    := nPropSF9
		/*
		*	Motivos a serem gravados no F9_MOTIVO, FA_MOTIVO - Orientação Fiscal
		*----------------------------------------------------------------------------
		*	Motivo de baixa         	|  F9(A)_MOTIVO
		*----------------------------------------------------------------------------
		*	'01' - Venda            	| 		'2'
		*	'10' - Transferencia    	| 		'3'
		*	'23' - Devolução de nota	| 		'4'
		*----------------------------------------------------------------------------
		*	'02|03|05|06|07|   		    | 		'1'
		*		02' - Extravio		    |
		*		03' - Roubo			    |
		*		05' - Variação		    |
		*		06' - Obsolencia		|
		*		07' - Sucateamento	    |
		*----------------------------------------------------------------------------
		*	 '04|09|12'				    | 		'5'
		*	    04 - Doação			    |
		*	    09 - Reavaliação		|
		*	    12 - Penhora			|
		*/
		If Substring(cCodMot,1,2)		== "01"
			cMotSF9 := "2"
		ElseIf Substring(cCodMot,1,2) 	$ "10|18"
			cMotSF9 := "3"
		ElseIf Substring(cCodMot,1,2) 	== "23"
			cMotSF9 := "4"
		ElseIf Substring(cCodMot,1,2) 	$ "02|03|05|06|07"
			cMotSF9 := "1"
		Else     
			cMotSF9 := "5"
		EndIf
		If lIsRussia
			cCodMot:= cMotivo
		EndIf

		/*
		* Grava Registros na Tabela SF9 (MANUTENCAO CIAP)
		*/
		SF9->(RecLock("SF9", .F.))
		SF9->F9_DOCNFS 	:= cNota
		SerieNfId('SF9',1,'F9_SERNFS',,,,FN6->FN6_SERIE)
		SF9->F9_ITEMNFS := cNFItem
		SF9->F9_DTEMINS	:= dBaixa036
		SF9->F9_MOTIVO 	:= cMotSF9
		SF9->F9_BXICMS	+= nVlrSFA // Ira enviar os valores proporcionalizados, pelo % da baixa parcial com base no ICMS restante.
		SF9->F9_CLIENTE := cCliente	
		SF9->F9_LOJACLI := cLoja

		//De acordo com solicitação do time do fiscal, quando o bem não gera NF deve ser atualizado a SF9, contudo não deve replicar o valor do campo F9_CHAVENF.
		If oModelMaster:GetValue('FN6_GERANF') == "2"
			SF9->F9_CHAVENF := ""
		Endif

		/*
		* Tratamento para indicar que eh uma baixa parcial - Utilizado para montar a legenda
		*/
		If SF9->(F9_BXICMS >0 .And. F9_BXICMS+F9_VLESTOR<F9_VALICMS)
			SF9->F9_BAIXAPR := "1"
		Else
			SF9->F9_BAIXAPR := "0"
			SF9->F9_SLDPARC :=  0   // BX TOTAL Não tenho direito a  parcelas de a[rociação]
		EndIf
		SF9->(MsUnLock())
		/*
		* So grava SFA se o tipo for 01 - FISCAL
		*/
		If SN3->N3_TIPO == '01' 
			SFA->(RecLock("SFA",.T.))
			SFA->FA_FILIAL := xFilial("SFA")
			SFA->FA_DATA   := dBaixa036
			SFA->FA_TIPO   := "2"
			
			SFA->FA_VALOR  := nVlrSfa
			
			SFA->FA_FATOR  := nFatorSFA * IIf(lCredito,0.25,0.20)
			SFA->FA_CODIGO := SF9->F9_CODIGO
			SFA->FA_ROTINA := "ATFA036"
			SFA->FA_CREDIT := Iif(lCredito,"1","2") 	// 1-Credito; 2-Debito
			SFA->FA_MOTIVO := SF9->F9_MOTIVO 			// Segundo Vitor N3-FISCAL o campo FA_MOTIVO com mesmo conteudo do F9_MOTIVO p/ SPED PIS/COFINS

			/*
			* Tratamento para indicar que eh uma baixa parcial - Utilizado para montar a legenda
			*/
			If SF9->(F9_BXICMS>0 .And. F9_BXICMS+F9_VLESTOR<F9_VALICMS)
				SFA->FA_BAIXAPR := "1"
			Else
				SFA->FA_BAIXAPR := "0"
			EndIf	
			SFA->(MsUnLock())
		EndIf

		SN3->(RecLock("SN3"))
		SN3->N3_BXICMS := nVlrSFA
		SN3->(MsUnlock())
	EndIf
		/*
		* Restaura o registro posicionado
		*/
	SN3->(dbGoto(nRegSN3))
EndIf

/*
 * FIM CIAP
 */
nVlVend := IIf(Type("nVlVend") != "N", 0, nVlVend)

//Gravação bem nao deprecia mais.
If lExisCPC31
	IF oModelMaster:GetValue('FN6_DEPREC') == '3'
		SN1->(RecLock("SN1"))
		SN1->N1_BLQDEPR := "S"  
		SN1->(MsUnlock())
	Endif
Endif

/*
 * Atualiza quantidade do ativo no caso de baixas por quantidade.
 * Nas baixas por valor, parciais ou totais, nao altero a quantidade no	
 * SN1.
 *
 * Apenas Baixa de Bens do tipo 01/03/Gerencial alteram a quantidade do
 * bem, outros tipo são controles contábeis, só influenciam no valor.
 */
If ( SN3->N3_TIPO $ '01/03' .Or. AFXVLGer(SN3->N3_FILIAL,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_TPSALDO) )  .And. !FWIsInCallStack("AF012CVMet")
	/*
	 * Somente na Baixa Parcial por Qtde
	 */
	If nQuant != nQtdorig  
		If lQuant .And. ! RusCheckRevalFunctions()
			SN1->(Reclock("SN1"))
			SN1->N1_QUANTD -= nQuant
			SN1->(MsUnlock())
		EndIf
	/*
	 * Baixa Total por Quantidade
	 */
	Else
		If Round(oModelValor:GetValue("FN7_VLATU",1),X3Decimal("N3_VORIG1")) == Round(oModelValor:GetValue("FN7_VLBAIX",1),X3Decimal("N3_VORIG1"))
			If !SN3->N3_TIPO $ "02|04" .And. ! RusCheckRevalFunctions()
				//-------------------------------------------------------------------------------------
				// Variavel de quantidade alimentada para possibilitar o cancelamento da transferencia
				// entre filiais, onde a quantidade do bem tem como base o registro da SN4
				//-------------------------------------------------------------------------------------
				nQuant := SN1->N1_QUANTD

				SN1->(RecLock("SN1"))
				SN1->N1_QUANTD	:= 0
				SN1->N1_BAIXA	:= dBaixa036
				SN1->(MsUnlock())
			EndIf

			/*
			 * Avalia integracao com o modulo SIGAMNT - PARCEIRO NG
			 */
			If lUsaMNTAT .AND. !EMPTY(SN1->N1_CODBEM)
				AFGRBXIntMnt(SN1->N1_CODBEM,SN1->N1_BAIXA,"ATFA036",.F.,cNota)
			EndIf
		EndIf
	EndIf
EndIf

/*
 * Verifica se houve baixa parcial ou total.
 */
IF Str(oModelValor:GetValue("FN7_VLBAIX",1),18,2) == Str(oModelValor:GetValue("FN7_VLATU",1),18,2)	// Baixa Total

	/*
	 * AVP
	 * Se for um tipo AVP efetuo os movimentos de AVP. Exceto quando for uma
	 * transferencia entre filiais (lAtfa060) pois neste caso. Os processos
	 * sao diferentes de uma baixa comum.
	 */
	If SN3->N3_TIPO == '14' .and. !lAtfa060
		aRecCtb := AF036AVP(.T.,dBaixa036,,cIdMov)
	Endif

	/*
	 * Atualiza valores tabela SN3
	 */
	RecLock("SN3")
		SN3->N3_BAIXA	:= "1"
		SN3->N3_IDBAIXA	:= "1"
		SN3->N3_DTBAIXA	:= dBaixa036
		SN3->N3_VRCMES1	:= Round( nValCorr , X3Decimal("N3_VRCMES1") )
		SN3->N3_VRCBAL1	+= SN3->N3_VRCMES1
		SN3->N3_VRCACM1	+= SN3->N3_VRCMES1
		SN3->N3_VRCDM1	:= Round( nValCorDep, X3Decimal("N3_VRCDM1") )
		SN3->N3_VRCDB1	+= SN3->N3_VRCDM1
		SN3->N3_VRCDA1	+= SN3->N3_VRCDM1
        SN3->N3_PERCBAI := 1
	If oModelMaster:GetValue("FN6_DEPREC") $ '0,3'
  		SN3->N3_NOVO := '1'
	ElseIf oModelMaster:GetValue("FN6_DEPREC") == '2'    
  		SN3->N3_NOVO := '2'
	EndIf

	AtfMultMoe("SN3","N3_VRDMES",{|x| Round( oModelValor:GetValue("FN7_VLDEPR",x) , X3Decimal( If(x>9,"N3_VRDME","N3_VRDMES")+Alltrim(Str(x)) )) })
	AtfMultMoe("SN3","N3_VRDBAL",{|x| SN3->&(If(x>9,"N3_VRDBA","N3_VRDBAL")+Alltrim(Str(x))) + SN3->&(If(x>9,"N3_VRDME","N3_VRDMES")+Alltrim(Str(x))) })
	AtfMultMoe("SN3","N3_VRDACM",{|x| SN3->&(If(x>9,"N3_VRDAC","N3_VRDACM")+Alltrim(Str(x))) + oModelValor:GetValue("FN7_VLDEPR",x) })

	SN3->N3_SEQ     := SN3->N3_SEQ
	SN3->N3_SEQREAV := cSeqReav
	SN3->(MsUnlock())

	/*
	 * Atualiza as informações do projeto de imobilizado
	 */
	AF036AtPrj(SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_TPSALDO,oModel)

Else
	/*
	 * Baixa Parcial
	 */
	Af036Parc(cBase, cItem, cSeq, dBaixa036,,,cIDMOV,oModel)

	/*
	 * Na baixa parcial o valor a ser baixado da conta (nValBaixa1,..,
	 * nValBaixa5) ‚ SN3->N3_VORIG1+SN3->N3_VRCACM1 na moeda1 e SN3->
	 * N3_VORIG&cMoeda nas outras moedas. Isto para garantir a grava-
	 * cao dos mesmos valores em todos os arquivos.
	 */
	If !lCalcChi
		aValBx[1] := SN3->N3_VORIG1+SN3->N3_AMPLIA1+SN3->N3_VRCACM1
		For nX := 2 to nQtdMoedas
			cMoed := Alltrim(Str(nX))
			aValBx[nX] := SN3->&("N3_VORIG"+cMoed)+SN3->&(If(nX>9,"N3_AMPLI","N3_AMPLIA")+cMoed)
		Next
	EndIf
EndIf

/*
 * Garantir que grave os mesmos nros no SN5
 */
If !lCalcChi
	aValBx[1] := SN3->N3_VRDACM1+SN3->N3_VRCDA1
	AtfMultMoe(,,{|x| If(x=1,.F.,aValBx[x] := SN3->&( If(x>9,"N3_VRDAC","N3_VRDACM")+Alltrim(Str(x)) )) })
Else
	aValBx := AtfMultMoe(,,{|x| 0 })
EndIf

/*
 * Grava Dados na Tabela SN4
 * Atualiza arquivo Movimentacoes (Depreciacao)
 */
nTotDepr := 0
AtfMultMoe(,,{|x| nTotDepr += oModelValor:GetValue("FN7_VLDEPR",x) })

If nTotDepr # 0
	If lIsRussia
		cOcorr		:= "06"
	Else
		cOcorr 	   	:= IIF( SN3->N3_TIPO $ ("10,12,14,15,50,51,52,53,54" + cTypes10 + cTypes12), "20", IIF(SN3->N3_TIPO == "07","10",IIF(SN3->N3_TIPO=="08","12",IIF(SN3->N3_TIPO == "09","11","06"))))
	EndIf
	aDadosComp 	:= ATFXCompl(aTxMedia[nMoedaAtf] , &(Iif(nMoedaAtf > 9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),cCodMot,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
	cTpSaldo 	:= SN3->N3_TPSALDO
	
	nRecnoSN4 := ATFXMOV(cFilAnt,@cIDMOV,dBaixa036,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,cSeqReav,"3",nQuant,cTpSaldo,,aValDepr,aDadosComp,/*nRecnoSN4*/,/*lComple*/,/*lValSN1*/,/*lClassifica*/,lOnOff,"820"/*cPadrao*/,"ATFA036")

	//Adiciona Flag para contabilizaç?o
	If lUsaFlag
		aAdd(aFlagCTB, {"N4_LA", "S", "SN4", nRecnoSN4, 0, 0, 0})		
	EndIf
EndIf

If nTotDepr # 0 .And. !lIsRussia
	cOcorr 	   	:= IIF( SN3->N3_TIPO $ ("10,12,14,15,50,51,52,53,54" + cTypes10 + cTypes12), "20", IIF(SN3->N3_TIPO == "07","10",IIF(SN3->N3_TIPO=="08","12",IIF(SN3->N3_TIPO == "09","11","06"))))
	aDadosComp 	:= ATFXCompl(aTxMedia[nMoedaAtf] , &(Iif(nMoedaAtf>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),cCodMot,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
	cTpSaldo 	:= SN3->N3_TPSALDO
	
	nRecnoSN4 := ATFXMOV(cFilAnt,@cIDMOV,dBaixa036,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,cSeqReav,"4",nQuant,cTpSaldo,,aValDepr,aDadosComp,/*nRecnoSN4*/,/*lComple*/,/*lValSN1*/,/*lClassifica*/,lOnOff,"820"/*cPadrao*/,"ATFA036")

	//Adiciona Flag para contabilizaç?o
	If lUsaFlag
		aAdd(aFlagCTB, {"N4_LA", "S", "SN4", nRecnoSN4, 0, 0, 0})		
	EndIf
EndIf

If nTotDepr # 0
	If lLP_Rat
		If nHdlPrv == 0
			nHdlPrv := HeadProva(cLoteAtf,"ATFA036",Substr(cUsername,1,6),@cArquivo)
		EndIf
        if mv_par03==1
        	lCtbRat := .T.
        Endif
	Endif

	aRateio := ATFRTMOV(	SN3->N3_FILIAL	,;
							SN3->N3_CBASE	,;
							SN3->N3_ITEM	,;
							SN3->N3_TIPO	,;
							SN3->N3_SEQ		,;
							dBaixa036		,;
							cIdMov			,;
							aValDepr		,;
							lCtbRat  		,;
							"1"				,;
							nHdlPrv			,;
							cLoteATF		,;
							@nTotal			,;
							"1"				,;
							FunName()		,;
							"81E"			,;
							lOnOff)
	
 	If Len(aRateio) > 0
		/*
		 * Baixar o rateio, se o bem foi baixado por completo
		 */
		If SN3->N3_BAIXA == "1"
			Af011AtuStatus(aRateio[1],aRateio[2],"4")
		Endif
	Endif
 Endif

/*
 * Atualiza Arquivo de Movimentação (Correção)
 */
If nValCorr # 0 .and. !lIsRussia
	cOcorr		:= "07"
	aDadosComp	:= ATFXCompl(aTxMedia[nMoedaAtf] , &(Iif(nMoedaAtf > 9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),cCodMot,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
	aValores	:= aClone(aAtfMultM)
	aValores[1]	:= Round( nValCorr , X3Decimal("N4_VLROC1") )
	cTpSaldo	:= SN3->N3_TPSALDO
	
	nRecnoSN4 := ATFXMOV(cFilAnt,@cIDMOV,dBaixa036,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,cSeqReav,"2",nQuant,cTpSaldo,,aValores,aDadosComp,/*nRecnoSN4*/,/*lComple*/,/*lValSN1*/,/*lClassifica*/,lOnOff,cPadrao,"ATFA036")

	//Adiciona Flag para contabilizaç?o
	If lUsaFlag
		aAdd(aFlagCTB, {"N4_LA", "S", "SN4", nRecnoSN4, 0, 0, 0})		
	EndIf
EndIf

/*
 * Atualiza arquivo de Movimentações (Correção da Depreciação
 */
If nValCorDep # 0 .And. (!lIsRussia .Or. SuperGetMv("MV_SN4MULT", .F., .T.))
	cOcorr		:= "08"
	aDadosComp	:= ATFXCompl(aTxMedia[nMoedaAtf] , &(Iif( nMoedaAtf > 9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),cCodMot,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
	aValores	:= aClone(aAtfMultM)
	aValores[1]	:= Round(nValCorDep , X3Decimal("N4_VLROC1") )
	cTpSaldo	:= SN3->N3_TPSALDO
	
	nRecnoSN4 := ATFXMOV(cFilAnt,@cIDMOV,dBaixa036,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,cSeqReav,"4",0,cTpSaldo,,aValores,aDadosComp,/*nRecnoSN4*/,/*lComple*/,/*lValSN1*/,/*lClassifica*/,lOnOff,cPadrao,"ATFA036")

	//Adiciona Flag para contabilizaç?o
	If lUsaFlag
		aAdd(aFlagCTB, {"N4_LA", "S", "SN4", nRecnoSN4, 0, 0, 0})		
	EndIf
EndIf

/*
 * Atualiza arquivo Movimentacoes (Correcao da Depreciacao)
 */
If nValCorDep # 0 .And. (!lIsRussia .Or. SuperGetMv("MV_SN4MULT", .F., .T.))
	cOcorr 	   	:= "08"
	aDadosComp 	:= ATFXCompl(aTxMedia[nMoedaAtf] , &(Iif(nMoedaAtf>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),cCodMot,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
	aValores   	:= AtfMultMoe(,,{|x| 0})
	aValores[1] := Round(nValCorDep , X3Decimal("N4_VLROC1") )
	cTpSaldo 	:= SN3->N3_TPSALDO
	
	nRecnoSN4 := ATFXMOV(cFilAnt,@cIDMOV,dBaixa036,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,cSeqReav,"5",0,cTpSaldo,,aValores,aDadosComp,/*nRecnoSN4*/,/*lComple*/,/*lValSN1*/,/*lClassifica*/,lOnOff,cPadrao,"ATFA036")	

	//Adiciona Flag para contabilizaç?o
	If lUsaFlag
		aAdd(aFlagCTB, {"N4_LA", "S", "SN4", nRecnoSN4, 0, 0, 0})		
	EndIf
End

/*
 * Gera registro de movimentacao
 */
nTotBaix := 0
AtfMultMoe(,,{|x| nTotBaix += aValBaixa[x] })

/*
 * Não considerar o item de depreciação acelerada incentivada
 */
If (nTotBaix # 0) .and. !lIsRussia

	If nVlVend > 0
		nVenda  	:= Round( nVlVend  , X3Decimal("N4_VENDA"))
	Else
		nVenda  	:= Iif(cCodMot == '01',Round( oModelMaster:GetValue("FN6_VALNF"), X3Decimal("N4_VENDA")),0 )
	Endif

	cOcorr 	   		:= "01"
	aDadosComp		:= ATFXCompl(aTxMedia[nMoedaAtf] , &(Iif(nMoedaAtf>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),cCodMot,/*cCodBaix*/,/*cFilOrig*/,cSerie,cNota,nVenda,/*cLocal*/, SN3->N3_PRODMES )
	cTpSaldo		:= SN3->N3_TPSALDO
	
	nRecnoSN4 := ATFXMOV(cFilAnt,@cIDMOV,dBaixa036,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,cSeqReav,"1",nQuant,cTpSaldo,,aValBaixa,aDadosComp,/*nRecnoSN4*/,/*lComple*/,/*lValSN1*/,/*lClassifica*/,lOnOff,cPadrao,"ATFA036")
	
	//Adiciona Flag para contabilizaç?o
	If lUsaFlag
		aAdd(aFlagCTB, {"N4_LA", "S", "SN4", nRecnoSN4, 0, 0, 0})		
	EndIf
	
	PcoDetLan(cLanc,"01","ATFA036")
EndIf

/*
 * Gera registro de movimentacao
 */
If nValCorr # 0 .and. !lIsRussia
	If nVlVend > 0
		nVenda  	:= Round( nVlVend  , X3Decimal("N4_VENDA"))
	Else
		nVenda  	:= Iif(cCodMot == '01',Round( oModelMaster:GetValue("FN6_VALNF"), X3Decimal("N4_VENDA")),0 )
	Endif
	cOcorr 	   		:= "07"
	aDadosComp 		:= ATFXCompl(aTxMedia[nMoedaAtf] , &(Iif(nMoedaAtf > 9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),cCodMot,/*cCodBaix*/,/*cFilOrig*/,cSerie,cNota,nVenda,/*cLocal*/, SN3->N3_PRODMES )
	aValores		:= AtfMultMoe(,,{|x| 0})
	aValores[1] 	:= Round(nValCorr , X3Decimal("N4_VLROC1") )
	cTpSaldo 		:= SN3->N3_TPSALDO
	
	nRecnoSN4 := ATFXMOV(cFilAnt,@cIDMOV,dBaixa036,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,cSeqReav,"1",nQuant,cTpSaldo,,aValores,aDadosComp,/*nRecnoSN4*/,/*lComple*/,/*lValSN1*/,/*lClassifica*/,lOnOff,cPadrao,"ATFA036")

	//Adiciona Flag para contabilizaç?o
	If lUsaFlag
		aAdd(aFlagCTB, {"N4_LA", "S", "SN4", nRecnoSN4, 0, 0, 0})		
	EndIf
Endif

If !FWIsInCallStack("ATFA060") .OR. SN3->N3_TIPO == '05'
	nTotBaix := 0
	AtfMultMoe(,,{|x| nTotBaix += aValBx[x] })

	If nTotBaix # 0 .and. !lIsRussia
		If nVlVend > 0
			nVenda  	:= Round( nVlVend  , X3Decimal("N4_VENDA"))
		Else
			nVenda  	:= Iif(cCodMot == '01',Round( oModelMaster:GetValue("FN6_VALNF"), X3Decimal("N4_VENDA")),0 )
		Endif
		cOcorr			:= "01"
		aDadosComp 		:= ATFXCompl(aTxMedia[nMoedaAtf] , &(If(nMoedaAtf > 9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),cCodMot,/*cCodBaix*/,/*cFilOrig*/,cSerie,cNota,nVenda,/*cLocal*/, SN3->N3_PRODMES)
		cTpSaldo 		:= SN3->N3_TPSALDO
		
		nRecnoSN4 := ATFXMOV(cFilAnt,@cIDMOV,dBaixa036,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,cSeqReav,"4",nQuant,cTpSaldo,,aValBx,aDadosComp,/*nRecnoSN4*/,/*lComple*/,/*lValSN1*/,/*lClassifica*/,lOnOff,cPadrao,"ATFA036")

		//Adiciona Flag para contabilizaç?o
		If lUsaFlag
			aAdd(aFlagCTB, {"N4_LA", "S", "SN4", nRecnoSN4, 0, 0, 0})		
		EndIf
	Endif
EndIf

/*
 * Atualiza o arquivo de simulacoes, caso este exista  	
 */
If SN3->N3_TIPO $ '01|03'
	dbSelectArea("SN7")
	SN7->(dbSetOrder(1))
	If SN7->(dbSeek(xFilial("SN7")+SN3->N3_CBASE+SN3->N3_ITEM))
		If Empty(SN7->N7_VLREAL)
			//-------------------------------------------------------------
			// Atualiza o arquivo de simulacoes, desde que o valor
			// Real nao esteja preenchido. Pois caso o bem possua a
			// gregados sera gravado o valor do bem de tipo 01.
			//-------------------------------------------------------------
			SN7->(RecLock("SN7"))
				SN7->N7_DTBAIXA := dBaixa036
				SN7->N7_MOTIVO  := cCodMot
				SN7->N7_NOTA    := cNota
				SerieNfId('SN7',1,'N7_SERIE',,,,FN6->FN6_SERIE)
				SN7->N7_VLREAL  := Round( aValBaixa[1] , X3Decimal("N4_VLROC1") )
		EndIf
		SN7->(MsUnlock())
	Endif
EndIf

cTpSaldo := SN3->N3_TPSALDO

// Verifica se a classificação de ativo sofre depreciação
lAtClDepr := AtClssVer(SN1->N1_PATRIM)

//-----------------------------------------------------------------------
// Inicia gravação dos Saldos - SN5
//-----------------------------------------------------------------------
If ! SN3->N3_TIPO $ "07,08,09"
	cTipoImob := IIF(SN1->N1_PATRIM $ "CAS","C",IIF(lAtClDepr,"5","D"))
	cTipoCorr := IIF(SN1->N1_PATRIM $ "CAS","O","6")

	ATFSaldo(	SN3->N3_CCONTAB,dBaixa036,cTipoImob,aValBaixa[1],aValBaixa[2],aValBaixa[3],aValBaixa[4],aValBaixa[5],;
	"+",aTxMedia[nMoedaAtf],SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValBaixa,cTpSaldo,cCodMot)
Endif

aValorMoed := AtfMultMoe(,,{|x| If(x=1,nValCorr,0) })

cTipoImob := IIF(SN1->N1_PATRIM $ "CAS","C",IIF(lAtClDepr,"5","D"))
cTipoCorr := IIF(SN1->N1_PATRIM $ "CAS","O",IIF(lAtClDepr .AND. EMPTY(SN1->N1_PATRIM),"6","6"))

ATFSaldo(	SN3->N3_CCONTAB,dBaixa036,cTipoCorr,nValCorr,0,0,0,0,"+",aTxMedia[nMoedaAtf],SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed ,cTpSaldo,cCodMot)

If lAtClDepr .OR. EMPTY(SN1->N1_PATRIM)
	aValorMoed := AtfMultMoe(,,{|x| If(x=1,nValCorr,0) })

	cTipoCorr := "6"
	ATFSaldo(	SN3->N3_CCORREC,dBaixa036,cTipoCorr,nValCorr,0,0,0,0,"+",aTxMedia[nMoedaAtf],SN3->N3_SUBCCOR,,SN3->N3_CLVLCOR,SN3->N3_CCCORR,"2", aValorMoed ,cTpSaldo,cCodMot)

	/*
	 * Depreciacao e depreciacao acumulada
	 */
	cTipoImob := If( !SN3->N3_TIPO $ ("08,09,10,12,50,51,52,53,54" + cTypes10 + cTypes12), "4", If(SN3->N3_TIPO $ ("10,12,15,50,51,52,53,54" + cTypes10 + cTypes12) ,"Y",If(SN3->N3_TIPO == "09","L","K")))
	ATFSaldo(	SN3->N3_CDEPREC,dBaixa036,cTipoImob,;
	oModelValor:GetValue("FN7_VLDEPR",1),;
	oModelValor:GetValue("FN7_VLDEPR",2),;
	oModelValor:GetValue("FN7_VLDEPR",3),;
	oModelValor:GetValue("FN7_VLDEPR",4),;
	oModelValor:GetValue("FN7_VLDEPR",5),;
	"+",aTxMedia[nMoedaAtf],SN3->N3_SUBCDEP,,SN3->N3_CLVLDEP,SN3->N3_CCDESP,"3", aValDepr ,cTpSaldo,cCodMot)
	aValorMoed := AtfMultMoe(,,{|x| If(x=1,nValCorDep,0) })

	cTipoCorr := "7"
	ATFSaldo(	SN3->N3_CDESP  ,dBaixa036,cTipoCorr,nValCorDep,0,0,0,0,"+",aTxMedia[nMoedaAtf],SN3->N3_SUBCDES,,SN3->N3_CLVLDES,SN3->N3_CCCDES,"5", aValorMoed ,cTpSaldo,cCodMot)

	cTipoImob := If( !SN3->N3_TIPO $ ("08,09,10,12,50,51,52,53,54" + cTypes10 + cTypes12), "4", If(SN3->N3_TIPO $ ("10,12,15,50,51,52,53,54" + cTypes10 + cTypes12) ,"Y",If(SN3->N3_TIPO=="09","L","K")))
	ATFSaldo(	SN3->N3_CCDEPR ,dBaixa036,cTipoImob,;
	oModelValor:GetValue("FN7_VLDEPR",1),;
	oModelValor:GetValue("FN7_VLDEPR",2),;
	oModelValor:GetValue("FN7_VLDEPR",3),;
	oModelValor:GetValue("FN7_VLDEPR",4),;
	oModelValor:GetValue("FN7_VLDEPR",5),;
	"+",aTxMedia[nMoedaAtf],SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValDepr, cTpSaldo ,cCodMot)

	If !FWIsInCallStack("ATFA060") .OR. SN3->N3_TIPO == '05'
		cTipoImob := "5"
		ATFSaldo(	SN3->N3_CCDEPR ,dBaixa036,cTipoImob,aValBx[1],aValBx[2],aValBx[3],aValBx[4],aValBx[5],;
		"+",aTxMedia[nMoedaAtf],SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValBx,cTpSaldo,cCodMot)
	EndIf

	aValorMoed := AtfMultMoe(,,{|x| If(x=1,nValCorDep,0) })
	cTipoCorr := "7"
	ATFSaldo(	SN3->N3_CCDEPR ,dBaixa036,cTipoCorr,nValCorDep,0,0,0,0,;
	"+",aTxMedia[nMoedaAtf],SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValorMoed ,cTpSaldo,cCodMot)
EndIf

If VerPadrao(cPadrao) .AND. nHdlPrv > 0
	nTotal += DetProva(nHdlPrv,cPadrao,"ATFA036",cLoteAtf,,,,,,,,@aFlagCTB)	
EndIf

/*
 * Verifica se existe algum SN3 Ativo para o bem e caso não tenha, marca o SN1 como baixado
 */
If !FWIsInCallStack("AF012CVMet")
	AFXVlBxN1(SN3->N3_CBASE,SN3->N3_ITEM,dBaixa036)
EndIf

/*
 * Ponto de Entrada chamado na Pós-Gravação dos dados baixa de ativo.
 * Substituindos os pontos de entrada AF030GRV e AF035GRV.
 */

cSeq := SN3->N3_SEQ //Sequencia da baixa

If lPosGrv
	ExecBlock("AF036POC",.F.,.F.)
EndIf

RestArea(aArea)
Return cSeq

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036AVP

Processa a apuracao do AVP para a filial atual

@author felipe.cunha
@since 01/03/2014
@version 1.0
@param lTotal Indica se a baixa eh total ou parcial
@param dBaixa Data da baixa
@param nPerc Percentual baixado (baixa parcial)
@param cIdMov Id do movimento do bem (SN4->N4_IDMOV)

/*/
//-------------------------------------------------------------------
Function AF036AVP(lTotal,dBaixa,nPerc,cIdMov)

Local nValAvp		:= 0
Local nValVp		:= 0
Local aAreaAvp		:= GetArea()
Local nRecConst		:= 0 
Local cIdProcAvp	:= ""
Local nSaveSx8Len	:= GetSx8Len()

DEFAULT lTotal		:= .F.
DEFAULT dBaixa		:= dDataBase
DEFAULT nPerc		:= 0
DEFAULT cIdMov		:= ""

/*
 * Posiciono tabela FNF no registro de constituicao ativo
 */
dbSelectArea("FNF")
FNF->(dbSetOrder(4)) //FNF_FILIAL+FNF_CBASE+FNF_ITEM+FNF_TPMOV+FNF_STATUS
If MsSeek(xFilial("FNF")+SN3->(N3_CBASE+N3_ITEM)+"1"+"1")

	/*
	 * Identificador de Processo Atual
	 */
	cIdProcAVP	:= GetSxeNum('FNF','FNF_IDPROC','FNF_IDPROC'+cEmpAnt,3)

	/*
	 * Guardo Registro da Constituicao do AVP Atual
	 */
	nRecConst := FNF->(RECNO())

	/*
	 * Posiciono na Ficha do Ativo
	 */
	SN1->(dbSetOrder(1))
	SN1->(MsSeek(xFilial("SN1")+FNF->(FNF_CBASE+FNF_ITEM)))

	/*
	 * Apuro o AVP ate a data da baixa
	 */
	AFCalcAVP("A",FNF->FNF_TAXA,FNF->FNF_INDAVP,,FNF->FNF_PERIND,dBaixa,@nValVP,@nValAVP,SN1->N1_DTAVP)

	/*
	 * Gravo a apropriacao do AVP por baixa
	 */
	AfGrvAvp(cFilAnt,"3",dBaixa,FNF->FNF_CBASE,FNF->FNF_ITEM,FNF->FNF_TIPO,FNF->FNF_TPSALDO,' ',FNF->FNF_SEQ,,nValAvp,.F.,,,,,cIdProcAVP,aRecCTB,,cIdMov)

	/*
	 * Se Baixa total, Realizo o AVP
	 */
	If lTotal
		/*
		 * Posiciono no registro de constituicao atual
		 */
		FNF->(dbGoto(nRecConst))

		/*
		 * Valor de AVP
		 */
		nValAVP := FNF->FNF_BASE - ( FNF->(FNF_AVPVLP + FNF_ACMAVP) )

		/*
		 * Gravo a realizacao do AVP por baixa - TOTAL
		 */
		AfGrvAvp(cFilAnt,"4",dBaixa,FNF->FNF_CBASE,FNF->FNF_ITEM,FNF->FNF_TIPO,FNF->FNF_TPSALDO,' ',FNF->FNF_SEQ,,nValAvp,.F.,,,,,cIdProcAVP,aRecCTB,.T.,cIdMov)
	Else
		/*
		 * Posiciono no registro de constituicao atual
		 */
		FNF->(dbGoto(nRecConst))

		/*
		 * Valor de AVP
		 */
		nValAVP := ( FNF->(FNF_VALOR - FNF_ACMAVP) ) * nPerc

		/*
		 * Gravo a realizacao do AVP por baixa - PARCIAL
		 * Gravo a baixa do AVP - Parcial ((AVP Constituido - AVP Acumulado) * Percentual de baixa
		 */
		AfGrvAvp(cFilAnt,"4",dBaixa,FNF->FNF_CBASE,FNF->FNF_ITEM,FNF->FNF_TIPO,FNF->FNF_TPSALDO,' ',FNF->FNF_SEQ,,nValAvp,.F.,,,,,cIdProcAVP,aRecCTB,.F. /*lBxTotal*/,cIdMov)

		/*
		 * Posiciono no registro de constituicao atual
		 */
		FNF->(dbGoto(nRecConst))

		/*
		 * Gravo constituicao do saldo restante do AVP
		 */
		AfGrvAvp(cFilAnt,"1",dBaixa,FNF->FNF_CBASE,FNF->FNF_ITEM,FNF->FNF_TIPO,FNF->FNF_TPSALDO,' ',FNF->FNF_SEQ,,nValAvp,.F.,,,,,cIdProcAVP,aRecCTB,.F. /*lBxTotal*/,cIdMov)
	EndIf

	/*
	 * Confirma o cIdProcAVP
	 */
	// Confirma o cCodBaixa
	While (GetSx8Len() > nSaveSx8Len)
		ConfirmSX8()
	Enddo
EndIf

RestArea(aAreaAVP)

Return aRecCTB

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036AtPrj

Atualiza as informações do projeto de imobilizado

@author felipe.cunha
@since 01/03/2014
@version 1.0
@param cBase Codigo Base do Bem
@param cItem Item do Bem
@param cTipo Tipo do Bem
@param cTipoSld Tipo de Saldo do Bem
@param aValDepr Valor de Depreciação
/*/
//-------------------------------------------------------------------
Static Function AF036AtPrj(cBase,cItem,cTipo,cTipoSld,oModel)
Local aArea			:= GetArea()
Local aAreaSN1		:= SN1->(GetArea()) 
Local nMoeda		:= 0
Local oModelValor	:= oModel:GetModel("FN7VALOR")

SN1->(DBSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
FNE->(DBSetOrder(2)) //FNE_FILIAL+FNE_CODPRJ+FNE_REVIS+FNE_ETAPA+FNE_ITEM+FNE_TPATF+FNE_TPSALD
If SN1->(MsSeek( xFilial("SN1") + cBase + cItem))   
	/*
	 * Acumula também o tipo 14 que complementa o tipo 10
	 */
	cTipo := IIF( cTipo == '14','10', cTipo )

	If FNE->(MsSeek( xFilial("FND") + SN1->(N1_PROJETO + N1_PROJREV + N1_PROJETP + N1_PROJITE) + cTipo + cTipoSld ))
		nMoeda := Val(FNE->FNE_MOEDRF)
		RecLock("FNE",.F.)
			FNE->FNE_VRDACM += oModelValor:GetValue("FN7_VLDEPR",nMoeda)
		MsUnLock() 
	EndIf
EndIf

RestArea(aAreaSN1)
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Af036Parc

Faz geracao do novo registro do SN3 e baixa o atual

@author felipe.cunha
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function Af036Parc(cBase, cItem, cSeq, dBaixa, bComple, cTpBaixa, cIdMov, oModel)

Local aSN3Cmp		:= {}
Local oModelValor	:= oModel:GetModel("FN7VALOR")
Local oModelMaster	:= oModel:GetModel(If(FWIsInCallStack("AF036BxLote") .OR. lAtf030 ,"FN6ATIVOS", "FN6MASTER"))
Local cMaior
Local nSavRec		:= SN3->(Recno())
Local nDifDep		:= 0
Local i
Local nSuf
Local aAmplia		:= AtfMultMoe(,,{|x| 0})
Local aValDepr		:= {}
Local cRatAnt		:= ""
Local cRevAnt		:= ""
Local aRateio		:= {}
Local cSeekSN3		:= ''
Local cMoeda		:= ''
Local nPercAux		:= {}
Local cNomCmp		:= ''
Local nQtdMoedas	:= AtfMoedas()			// Verifica quantidade de moedas
Local nVrcBal1		:= 0
Local nVrcAcm1		:= 0
Local nRecBx		:= 0
Local aVRDMES		:= {}
Local lCalcChi		:= FWIsInCallStack("ATFA031")
Local cSuf			:= ''
Local aVORIG		:= {}
Local nValCorr		:= 0
Local cMoedaAtf		:= GetMV("MV_ATFMOEDA")
Local aVRDACM		:= {}
Local aVRDBAL		:= {}
Local nVRCMES1		:= 0
Local nVRCDM1		:= 0
Local nVRCDB1		:= 0
Local nVRCDA1		:= 0
Local nRemanesc		:= 0
Local nValCorDep	:= 0
Local cSeqReav		:= ''
Local nVMXDEP		:= 0
Local nVLSALV		:= 0
Local nVlOrAnt		:= 0
Local lRusDepMod	:= .F.
Local nRusRatMod	:= 0

DEFAULT cTpBaixa := "1"		// 1=Baixa Normal, 2=Baixa Adiantamento
DEFAULT cIDMOV 	 := ""

DbSelectArea("SN3")

//-----------------------------------------------------------------------
// Procuro por baixas Parciais.                                    
//-----------------------------------------------------------------------
dbSeek(XFilial("SN3") + cBase + cItem)
cSeekSN3 := xFilial("SN3") + cBase + cItem

cMaior := ""
dbEval(	{ || cMaior := If( SN3->N3_SEQ > cMaior, SN3->N3_SEQ, cMaior )},,;
{ || cSeekSN3 == SN3->N3_FILIAL+SN3->N3_CBASE+SN3->N3_ITEM })

SN3->(dbGoto(nSavRec))

If AFXVerRat()
	If SN3->N3_RATEIO == "1"
		cRatAnt	:= SN3->N3_CODRAT
		cRevAnt	:= AF011GETREV(SN3->N3_CODRAT)
		aRateio := AF036LdRat(cRatAnt,cRevAnt)
		DBSELECTAREA("SN3")
	Endif
EndIf

cSeq := Soma1(cMaior) //tratativa pro cenário de chave duplicada na SN3 quando N3_SEQ > 999
cSeqReav	:= SN3->N3_SEQREAV

aSN3Cmp	:= {}

For i:=1 To FCount()
	cNomCmp := FieldName(i)
	If lIsRussia .And. AllTrim(cNomCmp) == "N3_UUID"
		AAdd(aSN3Cmp,{cNomCmp, RU01UUIDV4()})
	Else
		AAdd(aSN3Cmp,{cNomCmp, &cNomCmp})
	EndIf
Next i

nVrcBal1 := SN3->N3_VRCBAL1
nVrcAcm1 := SN3->N3_VRCACM1
nPercAux := oModelValor:GetValue("FN7_VLBAIX",Val(cMoedaAtf)) / oModelValor:GetValue("FN7_VLATU",Val(cMoedaAtf))
AtfMultMoe(,,{|x| aAdd(aValDepr,oModelValor:GetValue("FN7_VLDEPR",x))})

Reclock("SN3")

SN3->N3_VMXDEPR -= Round(SN3->N3_VMXDEPR * nPercAux, X3Decimal("N3_VMXDEPR")) 
SN3->N3_VLSALV1 -= Round(SN3->N3_VLSALV1 * nPercAux, X3Decimal("N3_VLSALV1")) 
If lIsRussia
	nVlOrAnt		:= SN3->N3_VORIG1
	SN3->N3_INCOST	:= nVlOrAnt
	lRusDepMod		:= .F.
	nRusRatMod		:= 0
	
	If FWIsInCallStack("AF036BxLote") .or. lAtf030
		If oModel:GetModel('PARAMETROS'):GetValue("DEPRBONUS") == 1 .And. oModel:GetModel("PARAMETROS"):GetValue("DEPBNSTYPE") != 1
			lRusDepMod	:= .T.
			nPercAux	:= oModelValor:GetValue("FN7_VLBAIX",Val(cMoedaAtf)) / oModelValor:GetValue("FN7_VLATU",Val(cMoedaAtf))
			nRusRatMod	:= (SN3->&("N3_AMPLIA"+cMoedaAtf) + SN3->&("N3_VORIG"+cMoedaAtf)) * nPercAux / SN3->&("N3_AMPLIA"+cMoedaAtf)
		EndIf
	EndIf
EndIf

For i:= 1 To nQtdMoedas
	cMoeda := Alltrim(Str(i))
	nPercAux := oModelValor:GetValue("FN7_VLBAIX",i) / oModelValor:GetValue("FN7_VLATU",i)
	If !lCalcChi
		If i>9
			&('SN3->N3_VRDME'+cMoeda) -= Round(&("N3_VRDME" + cMoeda) * nPercAux, X3Decimal("N3_VRDME"+cMoeda))
			&('SN3->N3_VRDBA'+cMoeda) -= Round(&("N3_VRDBA" + cMoeda) * nPercAux, X3Decimal("N3_VRDBA"+cMoeda))
			&('SN3->N3_VRDAC'+cMoeda) -= Round(&("N3_VRDAC" + cMoeda) * nPercAux, X3Decimal("N3_VRDAC"+cMoeda))
		Else
			&('SN3->N3_VRDMES'+cMoeda) -= Round(&("N3_VRDMES" + cMoeda) * nPercAux, X3Decimal("N3_VRDMES"+cMoeda))
			&('SN3->N3_VRDBAL'+cMoeda) -= Round(&("N3_VRDBAL" + cMoeda) * nPercAux, X3Decimal("N3_VRDBAL"+cMoeda))
			&('SN3->N3_VRDACM'+cMoeda) -= Round(&("N3_VRDACM" + cMoeda) * nPercAux, X3Decimal("N3_VRDACM"+cMoeda))
		EndIf
	EndIf
	If lIsRussia
		If ! lRusDepMod
			&('SN3->N3_VORIG'+cMoeda)  -= Round(&("N3_VORIG" + cMoeda)  * nPercAux, X3Decimal("N3_VORIG" +cMoeda))
		EndIf
	
		If i>9
			aAmplia[i] 		:= Round(&("N3_AMPLI" + cMoeda) * IIf(lRusDepMod, nRusRatMod, nPercAux), X3Decimal("N3_AMPLI" +cMoeda))
			&('SN3->N3_AMPLI'+cMoeda) 	-= aAmplia[i]
		Else
			aAmplia[i] 		:= Round(&("N3_AMPLIA" + cMoeda) * IIf(lRusDepMod, nRusRatMod, nPercAux), X3Decimal("N3_AMPLIA"+cMoeda))
			&('SN3->N3_AMPLIA'+cMoeda) 	-= aAmplia[i]
		EndIf
	Else
		&('SN3->N3_VORIG'+cMoeda)  -= Round(&("N3_VORIG" + cMoeda)  * nPercAux, X3Decimal("N3_VORIG" +cMoeda))
	
		If i>9
			aAmplia[i] 		:= Round(&("N3_AMPLI" + cMoeda) * nPercAux, X3Decimal("N3_AMPLI" +cMoeda))
			&('SN3->N3_AMPLI'+cMoeda) 	-= aAmplia[i]
		Else
			aAmplia[i] 		:= Round(&("N3_AMPLIA" + cMoeda) * nPercAux, X3Decimal("N3_AMPLIA"+cMoeda))
			&('SN3->N3_AMPLIA'+cMoeda) 	-= aAmplia[i]
		EndIf
	EndIf

Next

SN3->N3_IDBAIXA := "1"
SN3->N3_VRCACM1 -= Round(SN3->N3_VRCACM1 * nPercAux, X3Decimal("N3_VRCACM1"))

If !lCalcChi
	SN3->N3_VRCMES1 -= Round(SN3->N3_VRCMES1 * nPercAux, X3Decimal("N3_VRCMES1"))
	SN3->N3_VRCBAL1 -= Round(SN3->N3_VRCBAL1 * nPercAux, X3Decimal("N3_VRCBAL1"))
	SN3->N3_VRCDM1  -= Round(SN3->N3_VRCDM1  * nPercAux, X3Decimal("N3_VRCDM1"))
	SN3->N3_VRCDB1  -= Round(SN3->N3_VRCDB1  * nPercAux, X3Decimal("N3_VRCDB1"))
	SN3->N3_VRCDA1  -= Round(SN3->N3_VRCDA1  * nPercAux, X3Decimal("N3_VRCDA1"))
EndIf

/*
 * Grava Registro de Baixa (N3_BAIXA="1") em separado qdo esta parcial.
 * O reg.de baixa ( N3_BAIXA="1" ) ser  gravado pela diferenca entre o 
 * reg. original salvo em aSN3Cmp e o reg. acima. Este ‚ o reg. que fi-
 * car  para futuras baixas ou c lculos.                               
 */
aVRDMES		:= AtfMultMoe("SN3","N3_VRDMES")
aVORIG		:= AtfMultMoe("SN3","N3_VORIG")
nVRCACM1 	:= SN3->N3_VRCACM1
aAmplia		:= AtfMultMoe("SN3","N3_AMPLIA")
nVMXDEP		:= SN3->N3_VMXDEPR
nVLSALV		:= SN3->N3_VLSALV1

If !lCalcChi
	aVRDACM	:= AtfMultMoe("SN3","N3_VRDACM")
	aVRDBAL	:= AtfMultMoe("SN3","N3_VRDBAL")

	nVRCMES1 := SN3->N3_VRCMES1
	nVRCBAL1 := SN3->N3_VRCBAL1
	nVRCDM1  := SN3->N3_VRCDM1
	nVRCDB1  := SN3->N3_VRCDB1
	nVRCDA1  := SN3->N3_VRCDA1
Else
	aVRDACM	:= AtfMultMoe(,,{|x| 0})
	aVRDBAL	:= AtfMultMoe(,,{|x| 0})

	nVRCMES1 := 0
	nVRCBAL1 := 0
	nVRCDM1  := 0
	nVRCDB1  := 0
	nVRCDA1  := 0
EndIf

If bComple <> Nil
	Eval(bComple)
Endif

MsUnlock()

nRemanesc := SN3->(RECNO())

/*
 * AVP - Se for um tipo AVP
 */
If SN3->N3_TIPO == '14'
	aRecCtb := AF036AVP(.F.,oModelMaster:GetValue("FN6_DTBAIX"),nPercAux,cIdMov)
Endif	

/*
 * Grava Registro de Baixa em separado qdo esta parcial
 */
Reclock("SN3",.T.)

For i := 1 To FCount()
	cNomCmp := aSN3Cmp[i][1]
	Replace &cNomCmp With aSN3Cmp[i][2]
Next

SN3->N3_BAIXA	:= cTpBaixa
If lIsRussia .And. cTpBaixa <> "1"
	SN3->N3_OPER	:= "1"
EndIf
SN3->N3_IDBAIXA := "1"
SN3->N3_DTBAIXA	:= dBaixa

SN3->N3_VMXDEPR -= nVMXDEP
SN3->N3_VLSALV1 -= nVLSALV
If oModelMaster:GetValue("FN6_DEPREC") $ '0,3'
  SN3->N3_NOVO := '1'
ElseIf oModelMaster:GetValue("FN6_DEPREC") == '2'    
  SN3->N3_NOVO := '2'
EndIf

If lIsRussia
	SN3->N3_INCOST	:= nVlOrAnt
EndIf
If !lCalcChi .AND. cPaisLoc == 'CHI'
	SN3->N3_USACRED := " "
EndIf

//Grava valores de Depreciaçã e Correção
nRecBx := SN3->(RECNO())

aVRDMES	:= AtfMultMoe("SN3","N3_VRDMES")

For nSuf := 1 To nQtdMoedas
	If nSuf>9
		cSuf := Alltrim(Str(nSuf))
		&('SN3->N3_VORIG'+cSuf)	-= aVORIG[nSuf]
		&('SN3->N3_VRDME'+cSuf) := Iif(!lCalcChi,Round( aValDepr[nSuf], X3Decimal("N3_VRDME"+cSuf) ),0)
		&('SN3->N3_VRDAC'+cSuf) := Iif(!lCalcChi,&('SN3->N3_VRDAC'+cSuf)-aVRDACM[nSuf]+Round(	aValDepr[nSuf], X3Decimal("N3_VORIG"+cSuf)),0)
		&('SN3->N3_VRDBA'+cSuf) := Iif(!lCalcChi,&('SN3->N3_VRDBA'+cSuf)-aVRDBAL[nSuf]+Round(	aValDepr[nSuf], X3Decimal("N3_VORIG"+cSuf)),0)
		&('SN3->N3_AMPLI'+cSuf) -= aAmplia[nSuf]

		/*
		 * Proporcionalizar o valor da ampliacao no caso de baixa parcial BOPS 9613
		 *
		 * Caso a deprec acum for > que o valor original tiro a diferen-
		 * ‡a do valor da deprec do mes para as moedas diferentes de 1  
		 */
		If nSuf != 1 .and. !lCalcChi

			If &('SN3->N3_VRDAC'+cSuf) > &('SN3->N3_VORIG'+cSuf)
				/*
				 * RESIDUO TIPO 01 EM OUTRAS MOEDAS - Caso a deprec acum for > que o 
				 * valor original tiro a diferendo valor da deprec do mes.                                
				 */
				nDifDep := &('SN3->N3_VRDAC'+cSuf) - &('SN3->N3_VORIG'+cSuf)
				&('SN3->N3_VRDAC'+cSuf) -= aValDepr[nSuf]
				&('SN3->N3_VRDME'+cSuf) -= aValDepr[nSuf]
				&('SN3->N3_VRDBA'+cSuf) -= aValDepr[nSuf]
				aValDepr[nSuf]           -= aValDepr[nSuf]
				aValDepr[nSuf] :=  &('SN3->N3_VORIG'+cSuf) - &('SN3->N3_VRDAC'+cSuf)
				&('SN3->N3_VRDAC'+cSuf) += aValDepr[nSuf]
				&('SN3->N3_VRDBA'+cSuf) += aValDepr[nSuf]
				&('SN3->N3_VRDME'+cSuf) := aValDepr[nSuf]
			Else
				If aValDepr[nSuf] != 0
					/*
					 * RESIDUO TIPO 02 EM OUTRAS MOEDAS                          
					 * Se a Dep Acum < Vlr Orig, mas nDepr1 != 0 ‚ res¡duo de depr
					 * e Depr Acum dever ser IGUAL ao Vl Orig Corrigido           
					 */
					nDifDep := &('SN3->N3_VORIG'+cSuf) - &('SN3->N3_VRDAC'+cSuf)
					&('SN3->N3_VRDAC'+cSuf) += nDifDep
					&('SN3->N3_VRDME'+cSuf) += nDifDep
					&('SN3->N3_VRDBA'+cSuf) += nDifDep
					If lCalcChi
						oModelValor:GoLine(nSuf)
						oModelValor:SetValue("FN7_VLDEPR", oModelValor:GetValue("FN7_VLDEPR",nSuf) + nDifDep )
					EndIf
				Endif
			Endif
			nDifDep := 0
		Endif
	Else
		cSuf := Alltrim(Str(nSuf))
        If nSuf == 1
            oModelValor:GoLine(nSuf)
            SN3->N3_PERCBAI := oModelValor:GetValue("FN7_VLBAIX")/oModelValor:GetValue("FN7_VLATU")
        EndIf
		&('SN3->N3_VORIG'+cSuf)	 -= aVORIG[nSuf]
		&('SN3->N3_VRDMES'+cSuf) := Iif(!lCalcChi,Round( oModelValor:GetValue("FN7_VLDEPR",nSuf), X3Decimal("N3_VRDMES"+cSuf) ),0)
		&('SN3->N3_VRDACM'+cSuf) := Iif(!lCalcChi,&('SN3->N3_VRDACM'+cSuf)-aVRDACM[nSuf]+Round(	oModelValor:GetValue("FN7_VLDEPR",nSuf), X3Decimal("N3_VORIG"+cSuf)),0)
		&('SN3->N3_VRDBAL'+cSuf) := Iif(!lCalcChi,&('SN3->N3_VRDBAL'+cSuf)-aVRDBAL[nSuf]+Round(	oModelValor:GetValue("FN7_VLDEPR",nSuf), X3Decimal("N3_VORIG"+cSuf)),0)
		&('SN3->N3_AMPLIA'+cSuf) -= aAmplia[nSuf]
        
        		/*
		 * Proporcionalizar o valor da ampliacao no caso de baixa parcial BOPS 9613
		 *
		 * Caso a deprec acum for > que o valor original tiro a diferença do valor da deprec do mes para as moedas diferentes de 1  
		 */
		If nSuf != 1 .and. !lCalcChi

			If &('SN3->N3_VRDACM'+cSuf) > &('SN3->N3_VORIG'+cSuf)
				/*
				 * RESIDUO TIPO 01 EM OUTRAS MOEDAS                             
				 * Caso a deprec acum for > que o valor original tiro a diferen-
				 * ‡a do valor da deprec do mes.                                
				 */
				nDifDep := &('SN3->N3_VRDACM'+cSuf) - &('SN3->N3_VORIG'+cSuf)
				&('SN3->N3_VRDACM'+cSuf) -= oModelValor:GetValue("FN7_VLDEPR",nSuf)
				&('SN3->N3_VRDMES'+cSuf) -= oModelValor:GetValue("FN7_VLDEPR",nSuf)
				&('SN3->N3_VRDBAL'+cSuf) -= oModelValor:GetValue("FN7_VLDEPR",nSuf)
				aValDepr[nSuf]           -= oModelValor:GetValue("FN7_VLDEPR",nSuf)
				aValDepr[nSuf] :=  &('SN3->N3_VORIG'+cSuf) - &('SN3->N3_VRDACM'+cSuf)
				&('SN3->N3_VRDACM'+cSuf) += oModelValor:GetValue("FN7_VLDEPR",nSuf)
				&('SN3->N3_VRDBAL'+cSuf) += oModelValor:GetValue("FN7_VLDEPR",nSuf)
				&('SN3->N3_VRDMES'+cSuf) := oModelValor:GetValue("FN7_VLDEPR",nSuf)
			Endif
			nDifDep := 0
		Endif
	EndIf
Next

SN3->N3_VRCACM1	:= SN3->N3_VRCACM1 - nVRCACM1 + Round( nValCorr					, X3Decimal("N3_VRCACM1"))
SN3->N3_VRCMES1	:=Iif(!lCalcChi,Round( nValCorr									, X3Decimal("N3_VRCMES1")),0)
SN3->N3_VRCBAL1	:=Iif(!lCalcChi, SN3->N3_VRCBAL1 - nVRCBAL1 + Round( nValCorr	, X3Decimal("N3_VRCBAL1")),0)
SN3->N3_VRCDM1	:=Iif(!lCalcChi,Round( nValCorDep								, X3Decimal("N3_VRCDM1" )),0)
SN3->N3_VRCDB1	:=Iif(!lCalcChi, SN3->N3_VRCDB1  - nVRCDB1 + Round( nValCorDep	, X3Decimal("N3_VRCDB1" )),0)
SN3->N3_VRCDA1	:=Iif(!lCalcChi, SN3->N3_VRCDA1  - nVRCDA1 + Round( nValCorDep	, X3Decimal("N3_VRCDA1" )),0)
SN3->N3_SEQ		:= cSeq
SN3->N3_SEQREAV	:= cSeqReav 

/*
 * Caso a deprec acum for > que o valor original tiro a diferença
 * do valor da deprec do mes para a moeda 1.                 
 */
If (SN3->N3_VRDACM1+SN3->N3_VRCDA1) > (SN3->N3_VORIG1+SN3->N3_VRCACM1)
	nDifDep := (SN3->N3_VRDACM1+SN3->N3_VRCDA1) - (SN3->N3_VORIG1+SN3->N3_VRCACM1)
	/*
	 * TRATAMENTO DE RESIDUOS NA BAIXA PARCIAL NA MOEDA 1.
	 */
	If !lCalcChi
		SN3->N3_VRDACM1 -= oModelValor:GetValue("FN7_VLDEPR",1)
		SN3->N3_VRDMES1 -= oModelValor:GetValue("FN7_VLDEPR",1)
		SN3->N3_VRDBAL1 -= oModelValor:GetValue("FN7_VLDEPR",1)
		aValDepr[1]     -= oModelValor:GetValue("FN7_VLDEPR",1)
		aValDepr[1] 	:= (SN3->N3_VORIG1+SN3->N3_VRCACM1) - (SN3->N3_VRDACM1+SN3->N3_VRCDA1)
		SN3->N3_VRDACM1 += oModelValor:GetValue("FN7_VLDEPR",1)
	Else
		SN3->N3_VRDACM1	:= 0
		SN3->N3_VRDMES1	:= 0
		SN3->N3_VRDBAL1	:= 0
		aValDepr[1]		:= 0
		aValDepr[1]		:= 0
		SN3->N3_VRDACM1	:= 0
	EndIf

	If oModelValor:GetValue("FN7_VLDEPR",1) < 0
		//-----------------------------------------------------------------------
		// RESÖDUO TIPO 01 NA MOEDA 1 ACUM MAIOR QUE VALOR ORIG
		// Caso o nValDepr1 seja negativo (o acumulado e maior que o ori-
		// ginal) tiro o valor de depreciacao a mais (nValdepr1) do regis-
		// tro de baixa e somo essa quantidade no registro remanescente.
		//-----------------------------------------------------------------------
		SN3->N3_VRDMES1 := 0
		SN3->(MsUnlock())
		
		dbGoto(nRemanesc)
		SN3->(Reclock("SN3",.F.))
		SN3->N3_VRDACM1 += (oModelValor:GetValue("FN7_VLDEPR",1) )*(-1)
		SN3->N3_VRDMES1 += (oModelValor:GetValue("FN7_VLDEPR",1) )*(-1)
		SN3->(MsUnlock())
		aValDepr[1] := 0
		dbGoto(nRecBx)
		SN3->(Reclock("SN3",.F.))
	Else
		SN3->N3_VRDBAL1 += oModelValor:GetValue("FN7_VLDEPR",1) 
		SN3->N3_VRDMES1 := oModelValor:GetValue("FN7_VLDEPR",1) 
	Endif	
Else
	If SN3->N3_TXDEPR1 != 0
		/*
		 * RESIDUO TIPO 02 EM MOEDA 1
		 * Se a Dep Acum < Vlr Orig, mas nDepr1 != 0 ‚ res¡duo de depr
		 * e Depr Acum dever ser IGUAL ao Vl Orig Corrigido
		 */
		nDifDep := (SN3->N3_VORIG1+SN3->N3_VRCACM1) - (SN3->N3_VRDACM1+SN3->N3_VRCDA1)
	Endif
Endif

If bComple <> Nil
	Eval(bComple)
Endif

SN3->(MsUnlock())

/*
 * Inclusao do rateio para a nova sequencia do item da ficha de ativo
 * de acordo com o rateio da sequencia anterior, pois trata-se de uma 
 * baixa parcial da ficha do ativo.
 */
If len(aRateio) > 0
	If AF011Grv(3,aRateio)
		SN3->(Reclock("SN3",.F.))
		SN3->N3_RATEIO := "1"
		SN3->N3_CODRAT := aRateio[1,1]
		SN3->(MsUnlock())
	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036LdRat

Carrega o Array de rateio

@author felipe.cunha
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036LdRat(cCodRat,cRevAtu)
Local aHeader	:= {}
Local aCols		:= {}
Local aAreaSNV	:= {}
Local aNewRat	:= {}
Local aRateio	:= {}
Local nI		:= 0
Local cBusca	:= ""

DbSelectArea("SNV")
aHeader		:= AF011HeadSNV()
aAreaSNV	:= SNV->(GetArea())
aNewRat		:= AF011COD()

SNV->(DbSetOrder(1))

cBusca := xFilial("SNV") +;
PadR(cCodRat,TamSx3("NV_CODRAT")[1])+;
PadR(cRevAtu,TamSx3("NV_REVISAO")[1])

If SNV->(DbSeek(cBusca))

	While SNV->(!Eof()) .and. cBusca == SNV->NV_FILIAL +;
		PadR(SNV->NV_CODRAT,TamSx3("NV_CODRAT")[1])+;
		PadR(SNV->NV_REVISAO,TamSx3("NV_REVISAO")[1])

		aAdd(aCols,Array(Len(aHeader)+1))

		For nI := 1 to len(aHeader)
			aCols[len(aCols),nI] := CriaVar(aHeader[nI,2])
			aCols[len(aCols),nI] := SNV->&(aHeader[nI,2])
		Next nI

		aCols[len(aCols),len(aHeader)+1] := .F.

		SNV->(DbSkip())
	EndDo
EndIf

RestArea(aAreaSNV)

aAdd(aRateio, {aNewRat[1],aNewRat[2],"3",1,aCols,.F.})

If aNewRat[3]
	SNV->(ConfirmSX8())
Endif

Return(aRateio)

//-------------------------------------------------------------------
/*/{Protheus.doc} AF36HASAF
Verifica se existem os dados da baixa na tabela SFA .T. se não houver dados e .F. se houver

@author felipe.cunha
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AF36HASAF( cCodigo, dDBaixa, cTipo, cMotivo)
Local lRet			:= .F.
Local aArea			:= GetArea()
Local aAreaSFA		:= {}
Local cNextAlias	:= GetNextAlias()
Local cQuery		:= ''

DbSelectArea("SFA")
aAreaSFA := SFA->(GetArea())

cQuery := "Select R_E_C_N_O_ Regno"
cQuery += " FROM "+RetSQLTab("SFA")
cQuery += " WHERE FA_FILIAL = '"+xFilial("SFA")+"'"
cQuery += " AND FA_CODIGO = '"+cCodigo+"'"
cQuery += " AND FA_DATA = '"+Dtos(dDBaixa)+"'"
cQuery += " AND FA_TIPO = '"+cTipo+"'"
cQuery += " AND FA_MOTIVO = '"+cMotivo+"'"
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)  

lRet := !(cNextAlias)->(Eof())

(cNextAlias)->(dbCloseArea())

RestArea(aAreaSFA)
RestArea(aArea)

Return lRet  

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036HASN3
Verifica se existe um item do tipo 01 ainda não baixado no cadastro do ativo

@author felipe.cunha
@since 01/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AF036HASN3()
Local aArea		:= GetArea()
Local aAreaSN3	:= {}
Local lRet		:= .T.

DbSelectArea("SN3")
aAreaSN3 := SN3->(GetArea())
SN3->(dbSetOrder(1))
/*
 * Busca o registro de tipo 01 que ainda não foi baixado.
 */
lRet := SN3->(dbSeek(xFilial("SN3")+SN1->(N1_CBASE+N1_ITEM)+"10"))

RestArea(aAreaSN3)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036Cance

Cancelamento de registro de baixa do ativo

@author marylly.araujo
@since 26/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036Cance(cBase,cItem,cTipo,cTipoSld,dDatBaix,cSeq,cMotivo,nHdlPrv,nTotal,cCodBX,cFilFN7,cNumNF,cSerie,cCliente,cLoja)

Local lCancFilho	:= .F. //Se .T., cancela os filhos (agregados -tipos 1-2-4)
/*
 * Controle de multiplas moedas
 */
Local lRet			:= .T.
Local cIdMovSN4	:= ''
Local cFilSN1		:= FWxFilial("SN1")
Local nVlVend		:= 0
Local dBaixa036	:= dDatBaix
Local cQrySN4		:= ''
Local cAlsSN4		:= GetNextAlias()
Local lPreGrv		:= ExistBlock("AF036CPR")
//AVP
//Verifica de o AVP esta implantado na base
Local lAvpAtf := AFAvpAtf()
//AVP2
//Verifica implementacao do AVP e AVP parcela
Local dUltDepr  := GetMV("MV_ULTDEPR")

Default cFilFN7 := xFilial("FN7")
Default cNumNF	:= ""
Default cSerie	:= ""
Default cCliente:= ""
Default cLoja	:= ""

/*
 * Ponto de Entrada chamado na Pré-Gravação dos dados do cancelamento de baixa de ativo.
 * Substituindos os pontos de entrada AF030CAN e AF035CAN.
 */
If lPreGrv
	ExecBlock("AF036CPR",.F.,.F.)
EndIf

If Empty(cTipoSld)
	dbSelectArea( "SN4" )
	SN4->(dbSetOrder( 1 ) )
	If SN4->(dbSeek( xFilial( "SN4" ) + cBase + cItem + cTipo + "01"))
		cTipoSld := SN4->N4_TPSALDO
	EndIf
EndIf

cQrySN4 := " SELECT "
cQrySN4 += " SN4.R_E_C_N_O_ RECNOSN4 "
cQrySN4 += " FROM " + RetSqlName("SN4") + " SN4 "
cQrySN4 += " WHERE "
cQrySN4 += RetSqlCond("SN4") + " AND "
cQrySN4 += " SN4.N4_CBASE = '" + cBase + " ' AND "
cQrySN4 += " SN4.N4_ITEM = '" + cItem + " ' AND "
cQrySN4 += " SN4.N4_TIPO = '" + cTipo + " ' AND "
If !Empty(cTipoSld)
	cQrySN4 += " SN4.N4_TPSALDO = '" + cTipoSld + "' AND"
EndIf
cQrySN4 += " SN4.N4_SEQ = '" + cSeq + "' AND "
cQrySN4 += " SN4.N4_DATA = '" + DTOS(dDatBaix) + "' AND "
cQrySN4 += " SN4.N4_OCORR != '05' AND "
cQrySN4 += " SN4.N4_OCORR != '09' "

cQrySN4 := ChangeQuery(cQrySN4)

dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQrySN4) , cAlsSN4 , .T. , .F.)

If Empty((cAlsSN4)->RECNOSN4)
	lRet := .F.
Else
	SN4->(DbGoTo((cAlsSN4)->RECNOSN4))	
EndIf

(cAlsSN4)->(DbCloseArea())
If lRet 
	cIdMovSN4	:= SN4->N4_IDMOV
	cOrigem		:= Alltrim (SN4->N4_ORIGEM)
	lRet := !EMPTY(cIdMovSN4)
	
	DbSelectArea("SN3")
	SN3->(DbSetOrder(11)) // Filial + Código Base + Item Base + Tipo Ativo + Baixa + Tipo de Saldo
	SN3->(DbSeek(FWxFilial("SN3") + cBase + cItem + cTipo + '1' + cTipoSld + cSeq ))
	
	PcoIniLan("000370")
			
	/* Verificando a existência ficha do ativo	 */
	dbSelectArea("SN1")
	SN1->(dbSetOrder(1)) // Filial + Código do Bem + Item do Bem
	SN1->(dbSeek(cFilSN1+cBase+cItem))
	IF SN1->(!Found())
		Help(" ",1,"020ATIVO")
		lRet := .F.
	EndIf
	
	If lIsRussia
	    If !Empty(SN1->N1_BAIXA) .And. dUltDepr >= SN1->N1_BAIXA .And. !(dUltDepr == SN1->N1_BAIXA .And. RusCheckRevalFunctions())
			HELP(" ",1,"AF030BX",,STR0147,1,0)//O cancelamento da baixa não pode ser realizado! Existem depreciações realizadas após a efetivação da baixa do bem.
			lRet := .F.
		EndIf
	Else
		If !Empty(SN1->N1_BAIXA) .And. dUltDepr >= SN1->N1_BAIXA .And. !(dUltDepr == SN1->N1_BAIXA)
	    	HELP(" ",1,"AF030BX",,STR0147,1,0)//O cancelamento da baixa não pode ser realizado! Existem depreciações realizadas após a efetivação da baixa do bem.
			lRet := .F.
		EndIf
	EndIf	
	If lRet .AND. SN1->N1_STATUS $ "2|3"
		Help(" ",1,"A036BLOQ",,STR0038,1,0)  //"Ativo bloqueado, nao poder sofrer baixas."
		lRet := .F.
	EndIf
	
	If lRet .AND. SN4->N4_MOTIVO $ "01/10" .And. !Empty(SN4->N4_NOTA)
		lRet := A036VlNota(cNumNF,cSerie,cCliente,cLoja)
		If !lRet
			Help(" ",1,"AF036CNOTA",,I18N(STR0045,{SN4->N4_NOTA,SN4->N4_SERIE}) ,1,0) // "Baixa de Ativo atrelado ao documento de saída : Nota: #1[nota]#  Serie: #2[serie]# .Por favor exclua a nota fiscal antes."
		EndIf
	EndIf

	nVlVend	:= SN4->N4_VENDA

	/* Apenas será possivel cancelar a baixa de um bem convertido pela rotina de cancelamento de conversão (ATFA012) */
	If lRet .AND. SN4->N4_MOTIVO == '13' .And. !FWIsInCallStack("AF012CVMet")
		Help(" ",1,"AF036CCONV",,STR0044,1,0)//"Baixas com motivo 13-Conversão apenas podem ser cancelado pela rotina de cancelamento de conversão(ATFA010)"
		lRet := .F.
	EndIf
	
	If lRet .AND. SN4->N4_MOTIVO == '14' .And. !FWIsInCallStack("A103GrvAtf")
		Help(" ",1,"AF036DEB",,STR0043,1,0)//"Baixas com motivo 14 apenas podem ser cancelado pela exclusão da nota de crédito/débito"
		lRet := .F.
	EndIf
	
	If lRet .AND. SN4->N4_MOTIVO $ '15/16/17' .And. !FWIsInCallStack("ATFA320")
		Help(" ",1,"AF036TERC",,STR0039,1,0)//"Baixas com motivo de bens de terceiro apenas podem ser canceladas pela rotina de Controle De Terceiros(ATFA320)"
		lRet := .F.
	EndIf
	
	If lRet .AND. SN4->N4_MOTIVO $ '18' .And. !FWIsInCallStack("AF060Canc")
		Help(" ",1,"AF036FILAUT",,STR0042,1,0)//"Baixas com motivo 18-Transferencia Interna de Filial não pode ser cancelada"
		lRet := .F.
	EndIf
	
	If lRet .AND. ATFXVerPrj(SN3->N3_CBASE,SN3->N3_ITEM, .T. )
		lRet := .F.
	EndIf

	/* AVP
	 * Valida se cancelamento da baixa e possivel 	 */
	If lAvpAtf .and. AFNoCanAvp(cBase,cItem,cTipo,SN4->N4_IDMOV,SN4->N4_DATA,SN4->N4_TPSALDO)
			Help(" ",1,"AF036NOCAN",,STR0081,1,0)		//"Taxa Média de Depreciação"
			lRet := .F.
		Endif
			
	/* AVP2
	 * Verifica se o bem foi gerado por AVP Parcela 	 */
	If SN1->N1_PATRIM == 'V' .and. Alltrim(SN1->N1_ORIGEM) == 'ATFA460' .and. !lAf030Auto
		Help(" ",1,"AF010A460B",,STR0086+CRLF+STR0087+SN1->N1_BASESUP +"-"+SN1->N1_ITEMSUP ,1,0)  //'Este ativo foi gerado a partir do processo de constituição de provisão. Este tipo de ativo não poderá ser baixado diretamente. Baixe o ativo superior (PAI).'###"C.Base-Item: "
		lRet := .F.
	Endif

	/* AVP2
	 * Se o bem for classificado como Orcamento, os filhos serao baixados independendo da escolha do usuário 	 */ 
	If SN1->N1_PATRIM $ 'O|V'
		lCancFilho := .T.
	Endif
	
	If lRet 
		a036AtuArq(lCancFilho,dBaixa036, SN4->N4_CBASE, SN4->N4_ITEM, SN4->N4_TIPO, SN4->N4_TPSALDO,SN4->N4_SEQ,SN4->N4_SEQREAV,/*lMovCiap*/,@nHdlPrv,@nTotal,cCodBX,cFilFN7)
	Endif
	
	PcoFinLan("000370")
	
	/* AVP2 - cancelamento 	 */
	If lRet
		/*
		 * Se o bem for classificado como Orcamento e o AVP deste for por parcela
		 * Cancelo a baixa dos filhos
		 * Excluo o bem provisório gerado pela baixa em cancelamento
		 */
		If SN1->N1_PATRIM == 'O' .and. SN1->N1_TPAVP == '2' .and. !Empty(cIdMovSN4)
			MsgRun(STR0106,"",{|| AFCanProv(SN1->N1_CBASE, SN1->N1_ITEM,SN4->N4_MOTIVO,cIdMovSN4)  })//"Excluindo bens de provisao (AVP parcela)"
	
			Pergunte("AFA036",.F.)
			AF036PerAt()
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A036AtuArq

Cancela a(s) baixa(s) efetuada(s)  e atualiza as tabelas envolvidas

@author marylly.araujo
@since 26/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A036AtuArq(lCancFilho,dDtBaixa,cBase, cItem, cTipo, cTpSaldo, cSeqSN3, cSeqReav,lMovCiap, nHdlPrv, nTotal,cCodBX,cFilFN7)
Local aArea			:= GetArea()
Local aAreaSN1		:= SN1->(GetArea())
Local aAreaSN3		:= SN3->(GetArea())
Local aAreaSN4		:= SN4->(GetArea())
Local aAreaSN7		:= SN7->(GetArea())

/* Controle de Múltiplas Moedas */
Local aValorMoed	:= {}
Local aMultMoeda	:= AtfMultMoe(,,{|x| 0})
Local aVrdAcm		:= aClone(aMultMoeda)
Local aOrig			:= aClone(aMultMoeda)
Local aVrdBal		:= aClone(aMultMoeda)
Local aVrdMes		:= aClone(aMultMoeda)
Local nVRCDA1		:= 0
Local nVrcBal1		:= 0
Local nVrcMes1		:= 0
Local nVrcAcm1		:= 0
Local cChave		:= ""
Local nRegSN4		:= 0
Local lParc			:= .F.
Local lUsaMNTAT		:= Iif(ALLTRIM(SuperGetMv("MV_NGMNTAT",.F.,"N")) $ "1/3",.T.,.F.) // N-NAO INTEGRA / 1-ALTERACOES NO ATF REPLICARAO NO MNT / 2-ALTERACOES NO MNT REPLICARAO NO ATF / 3-ALTERACOES ATUALIZARAO ATF E MNT
Local aValBaixa		:= aClone(aMultMoeda)
Local aValDepr		:= aClone(aMultMoeda)
Local nValCorr		:= 0
Local nValcorDep	:= 0
Local cTipoCorr		:= ""
Local dUltDepr		:= SuperGetMv("MV_ULTDEPR")
Local aUltDepr		:= aClone(aMultMoeda)
Local cTipoImob		:= ""
Local cTypes10		:= IIF(lIsRussia,"*" + AtfNValMod({1}, "*"),"") // CAZARINI - 14/03/2017 - If is Russia, add new valuations models - main models
Local cTypes12		:= IIF(lIsRussia,"*" + AtfNValMod({2}, "*"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - recoverable models
Local cOcorr		:= IIF( SN3->N3_TIPO $ ("10,12,15,50,51,52,53,54" + cTypes10 + cTypes12), "20", IIF(SN3->N3_TIPO == "07","10",IIF(SN3->N3_TIPO=="08","12",IIF(SN3->N3_TIPO == "09","11","06"))))
Local cOcorAux    	:= "  "
/* Estorno do movimento do rateio da ficha de ativo  */
Local cIdMov		:= ""
Local cRevAtu		:= ""
Local lLP_Rat		:= VerPadrao("81F")
Local cFilSN3		:= FWxFilial("SN3")
Local cFilSN4		:= FWxFilial("SN4")
Local cFilSN7		:= FWxFilial("SN7")
Local cLoteAtf		:= LoteCont("ATF")
Local lOnOff		:= MV_PAR03 == 1
Local cPadraoAut	:= ""
Local lPrimlPad		:= .T.
Local cCodMot		:= ''
Local cCodMotAnt    := ''
Local cArquivo		:= ""
Local nVMXDEP		:= 0
Local nVLSALV		:= 0
Local nVlOrAnt		:= 0
Local cQrySN3		:= ""
Local cAlsSN3		:= ""
Local cIDSN4Aux		:= ""
Local nRecnoSN4		:= ""
Local nRegSN3		:= 0


//Contabilizacao do Cancelamento da Transferencia
Local lCancTrans	:= FWIsInCallStack("AF060Canc")
Local nValSfa := 0
Local nParcelas     := 0
Local aFARules		AS ARRAY
aFARules			:= {}

Default lMovCiap	:= .T.
Default cFilFN7	:= xFilial("FN7")

dbSelectArea("SN4")
SN4->(dbSetOrder(1))//N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ

cCodMot	:= SN4->N4_MOTIVO
cCodMotAnt := cCodMot
//Caso seja cancelamento de baixa de bem transferido busca ocorr 03, pois vai buscar no movimento da origem da transferencia
cOcorAux   := If(lCancTrans, '03', SN4->N4_OCORR) //considera que SN4 esta posicionado no mov. a ser cancelado qdo nao eh transferencia

cTpSaldo := SN3->N3_TPSALDO

cBase    := SN3->N3_CBASE
cItem    := SN3->N3_ITEM
cTipo    := SN3->N3_TIPO
cSeq     := If(Empty(cSeqSN3),SN3->N3_SEQ,cSeqSN3)

IF cTipo $ '10' //tratamento para só movimentar CIAP do tipo 10 somente quando o bem não tiver Tipo 01
	nRegSN3 := SN3->(Recno())
	dbSelectArea("SN3")
	SN3->(dbSetOrder(1))	
	SN3->(dbSeek(cFilSN3+cBase+cItem )) 

	While SN3->(!Eof()) .And. cFilSN3 == SN3->N3_FILIAL .And. cBase == SN3->N3_CBASE  .And. cItem == SN3->N3_ITEM 
		If  SN3->N3_TIPO $ '01'
			lMovCiap := .F.	
		EndIf
		SN3->(dbSkip())
	EndDo

	// Restaura o registro posicionado
	SN3->(dbGoto(nRegSN3))
EndIF

If type("dData") == "U"
	dData := Ctod("")
EndIf

dData    := If(Empty(dData),dDtBaixa,dData)
nRegSN4 := SN4->(Recno())  //salva registro com SN4 posicionado
dAquisic := SN3->N3_AQUISIC
cSeqReav := If(!Empty(SN3->N3_SEQREAV) .and. cSeqReav = Nil,SN3->N3_SEQREAV,cSeqReav)

//----------------------
// Valores para estorno
//----------------------
aValBaixa	:= aClone(aMultMoeda)
aValDepr	:= aClone(aMultMoeda)
aValBx		:= aClone(aMultMoeda)

aRet := AF036VlrBx(cBase,cItem,cTipo,dDtBaixa,cOcorr,cSeq,cSeqReav)

aValBaixa	:= aRet[1]
aValDepr	:= aRet[2]
aValBx		:= aRet[3]

/* Atualiza quantidade do ativo */
If SN4->(dbSeek(cFilSN4 + cBase + cItem + cTipo + DTOS(dData) + cOcorAux ))   
	
	SN4->(dbGoto(nRegSN4))
	
		SN1->(Reclock("SN1",.F.))		
		//Apenas Baixa de Bens do tipo 01,03 e gerencial alteram a quantidade do bem, outros tipo são controles contábeis e só influenciam no valor do bem
		If ( SN3->N3_TIPO $ '01/03' .Or. AFXVLGer(SN3->N3_FILIAL,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_TPSALDO) )  .And. !FWIsInCallStack("AF012CVMet")
			SN1->N1_QUANTD += SN4->N4_QUANTD
		EndIf

		SN1->(msUnlock())
	
	If SN1->N1_QUANTD > 0 .OR. lCancTrans
		SN1->(Reclock("SN1",.F.))
		SN1->N1_BAIXA	:= Ctod("")
		SN1->(msUnlock())
	EndIf

	//Tratamento para corrigir o status do bem após o cancelamento da transferencia entre filiais
	If lCancTrans
		SN1->(RecLock("SN1",.F.))
		SN1->N1_STATUS := CriaVar("N1_STATUS",.T.)
		SN1->(MSUnlock())
	EndIf

	If lIsRussia
		aAdd(aFARules, {SN1->N1_CBASE, SN1->N1_ITEM})
	EndIf

	/* Avalia integracao com o modulo SIGAMNT - PARCEIRO NG 	*/
	IF lUsaMNTAT .AND. !EMPTY(SN1->N1_CODBEM)
		AFGRBXIntMnt(SN1->N1_CODBEM,SN1->N1_BAIXA,"ATFA036",.T.)
	ENDIF
	
	/* Controle de multiplas moedas 	*/
	aVRDACM := AtfMultMoe(,,{|x|  aVRDACM[x] - aValdepr[x] })
	
	/* Controle de multiplas moedas 	*/
	aVrdMes	:= AtfMultMoe(,,{|x| 0})
	nVrcMes1	:= 0
	nVrcdM1	:= 0
	
	/* Atualiza saldos do Ativos	*/
	
	/* Controle de multiplas moedas	*/
	aOrig := AtfMultMoe("SN3","N3_VORIG")
	nVMXDEP	:= SN3->N3_VMXDEPR
	nVLSALV	:= SN3->N3_VLSALV1
	
	/* Controle de multiplas moedas 	*/
	aAmplia	 := AtfMultMoe("SN3","N3_AMPLIA")
	
	nVrcMes1 := SN3->N3_VRCMES1
	nVrcBal1 := SN3->N3_VRCBAL1 - nVrcMes1
	nVrcAcm1 := SN3->N3_VRCACM1 - nVrcMes1
	
	nVrcdM1	:= SN3->N3_VRCDM1
	nVrcdB1	:= SN3->N3_VRCDB1 - nVrcdM1
	nVrcdA1	:= SN3->N3_VRCDA1 - nVrcdM1
	
	/*
	* Controle de multiplas moedas
	*/
	aVrdMes	 := AtfMultMoe("SN3","N3_VRDMES")
	
	/*
	* Controle de multiplas moedas
	*/
	aVrdBal	 := AtfMultMoe("SN3","N3_VRDBAL")
	AtfMultMoe(,,{|x| aVrdBal[x]-= aVrdMes[x] })
	
	/*
	* Controle de multiplas moedas
	*/
	aVrdAcm	 := AtfMultMoe("SN3","N3_VRDACM")
	AtfMultMoe(,,{|x| aVrdAcm[x] -= aVrdMes[x] })
	
	If ExistBlock("AF036CAN")
		ExecBlock("AF036CAN",.F.,.F.)
	Endif
	
	/*
	* Geração de lancamentos Contabeis conforme o tipo do ativo cadastrado
	*/
	If Empty(cPadraoAut)
		IF SN3->N3_TIPO $ ("01*10" + cTypes10)
			cPadrao := "814"
		ElseIF	SN3->N3_TIPO $ "02,05"
			cPadrao := "815"
		ElseIF	SN3->N3_TIPO $ "03*13"
			cPadrao := "816"
		ElseIF	SN3->N3_TIPO == "04"
			cPadrao := "817"
		Else
			cPadrao := "81B" // Cancelamento da baixa de outros tipos de ativos
		EndIf
	Else
		cPadrao := cPadraoAut
	EndIf
	
	cChave := FWxFilial("SN4")+cBase+cItem+cTipo+DTOS(dDtBaixa)
	SN4->(MsSeek(cChave))
	
	SN4->(RecLock("SN4",.F.))
	SN4->N4_LA 		:= iIf(mv_par01 # 3,"S","N")
	SN4->N4_ORIGEM 	:= FunName()
	SN4->N4_LP 		:= cPadrao
	SN4->(MsUnLock())
	
	/*
	* Verifica se existe lancamento padrao.
	*/
	lPadrao := VerPadrao(cPadrao)
	IF ( lPadrao .or. lLP_Rat ) .And. mv_par01 # 3
		/*
		* Envia p/ lanc. contabil, desde que exista lancam.padronizado
		*/
		If lPrimlPad
			If nHdlPrv == 0
				nHdlPrv := HeadProva(cLoteAtf,"ATFA030",Substr(cUsername,1,6),@cArquivo,! CtbInUse())
			Endif
			If lCancFilho
				lPrimlPad := .F.
			Endif
		Endif
		nTotal += DetProva(nHdlPrv,cPadrao,"ATFA030",cLoteAtf)
	EndIf
	
	/*
	* Verifica se a classificação de ativo sofre depreciação
	*/
	lAtClDepr := AtClssVer(SN1->N1_PATRIM)
	
	If ! SN3->N3_TIPO $ "07,08,09"
		cTipoImob := IIF(SN1->N1_PATRIM $ "CAS","C",IIF(lAtClDepr/* .AND. EMPTY(SN1->N1_PATRIM)*/,"5","D"))
		cTipoCorr := IIF(SN1->N1_PATRIM $ "CAS","O",IIF(lAtClDepr .AND. EMPTY(SN1->N1_PATRIM),"6","6"))
		If lCancTrans   //se for cancelamento de transferencia cTipoImob = 8 - transferencia - origem
			cTipoImob := "8" //N5_TIPO = 8 eh transferencia entre filiais (origem)
			cCodMot   := "" //pois na funcao atfsald retorna nil quando eh transferencia cod motivo 18
		EndIf
		ATFSaldo(	SN3->N3_CCONTAB,dDtBaixa,cTipoImob,aValBaixa[1],aValBaixa[2],aValBaixa[3],aValBaixa[4],aValBaixa[5],;
			"-",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValBaixa, cTpSaldo,cCodMot )
		If lCancTrans  //retorna codigo motivo salvo
			cCodMot   := cCodMotAnt
		EndIf	
	Endif
	/*
	* Controle de multiplas moedas
	*/
	aValorMoed	:= AtfMultMoe(,,{|x| If(x=1,nValCorr,0) })
	
	cTipoImob := IIF(SN1->N1_PATRIM $ "CAS","C",IIF(lAtClDepr,"5","D"))
	cTipoCorr := IIF(SN1->N1_PATRIM $ "CAS","O",IIF(lAtClDepr .AND. EMPTY(SN1->N1_PATRIM),"6","6"))
	ATFSaldo(	SN3->N3_CCONTAB,dDtBaixa,cTipoCorr,	nValCorr,0,0,0,0,;
		"-",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed, cTpSaldo,cCodMot )
	
	cTipoImob := IIF(SN1->N1_PATRIM $ "CAS","C",IIF(lAtClDepr,"5","D"))
	cTipoCorr := IIF(SN1->N1_PATRIM $ "CAS","O",IIF(lAtClDepr .AND. EMPTY(SN1->N1_PATRIM),"6","6"))
	ATFSaldo(	SN3->N3_CCORREC,dDtBaixa,cTipoCorr,nValCorr,0,0,0,0,;
		"-",,SN3->N3_SUBCCOR,,SN3->N3_CLVLCOR,SN3->N3_CCCORR,"2", aValorMoed,cTpSaldo,cCodMot )
	
	If lAtClDepr .OR. EMPTY(SN1->N1_PATRIM)
		
		/*
		* Controle de multiplas moedas
		*/
		If lCancTrans   //se for cancelamento de transferencia cTipoImob = 8 - transferencia - origem
			cTipoImob := "8" //N5_TIPO = 8 eh transferencia entre filiais (origem)
			cCodMot   := "" //pois na funcao atfsald retorna nil quando eh transferencia cod motivo 18
			ATFSaldo(	SN3->N3_CDEPREC ,dDtBaixa,cTipoImob,aValBx[1],aValBx[2],aValBx[3],aValBx[4],aValBx[5],;
						"-",,SN3->N3_SUBCDEP,,SN3->N3_CLVLDEP,SN3->N3_CCDESP,"3", aValBx , cTpSaldo,cCodMot)						
		EndIf
		cTipoImob := If( !SN3->N3_TIPO $ ("08,09,10,12,50,51,52,53,54" + cTypes10 + cTypes12), "4", If(SN3->N3_TIPO $ ("10,12,50,51,52,53,54" + cTypes10 + cTypes12),"Y",If(SN3->N3_TIPO=="09","L","K")))
		ATFSaldo(	SN3->N3_CDEPREC,dDtBaixa,cTipoImob,;
			aValDepr[1],;
			aValDepr[2],;
			aValDepr[3],;
			aValDepr[4],;
			aValDepr[5],;
			"-",,SN3->N3_SUBCDEP,,SN3->N3_CLVLDEP,SN3->N3_CCDESP,"3", aValDepr, cTpSaldo,cCodMot )
		If lCancTrans
		    //retorna codigo motivo salvo
			cCodMot   := cCodMotAnt
		EndIf			
		
		cTipoImob := If( !SN3->N3_TIPO $ ("08,09,10,12,50,51,52,53,54" + cTypes10 + cTypes12), "4", If(SN3->N3_TIPO $ ("10,12,50,51,52,53,54" + cTypes10 + cTypes12),"Y",If(SN3->N3_TIPO=="09","L","K")))
		If lCancTrans   //se for cancelamento de transferencia
			cCodMot   := "" //pois na funcao atfsald retorna nil quando eh transferencia cod motivo 18
		EndIf
		ATFSaldo(	SN3->N3_CCDEPR ,dDtBaixa,cTipoImob,;
			aValDepr[1],;
			aValDepr[2],;
			aValDepr[3],;
			aValDepr[4],;
			aValDepr[5],;
			"-",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValDepr, cTpSaldo,cCodMot )
		If lCancTrans  //retorna codigo motivo salvo
			cCodMot   := cCodMotAnt
		EndIf

		cTipoImob := "5"
		If lCancTrans  //retorna codigo motivo salvo
			cTipoImob := "8" //N5_TIPO = 8 eh transferencia entre filiais (origem)
			cCodMot   := "" //pois na funcao atfsald retorna nil quando eh transferencia cod motivo 18
		EndIf
		ATFSaldo(	SN3->N3_CCDEPR ,dDtBaixa,cTipoImob,aValBx[1],aValBx[2],aValBx[3],aValBx[4],aValBx[5],;
			"-",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValBx , cTpSaldo,cCodMot)
		If lCancTrans  //retorna codigo motivo salvo
			cCodMot   := cCodMotAnt
		EndIf
		/*
		* Controle de multiplas moedas
		*/
		aValorMoed	:= AtfMultMoe(,,{|x| If(x=1,nValCorDep,0) })
		
		cTipoCorr := "7"
		ATFSaldo(	SN3->N3_CDESP	,dDtBaixa,cTipoCorr, nValCorDep,0,0,0,0 ,;
			"-",,SN3->N3_SUBCDES,,SN3->N3_CLVLDES,SN3->N3_CCCDES,"5", aValorMoed, cTpSaldo,cCodMot )
		
		cTipoCorr := "7"
		ATFSaldo(	SN3->N3_CCDEPR ,dDtBaixa,cTipoCorr, nValCorDep,0,0,0,0 ,;
			"-",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValorMoed, cTpSaldo,cCodMot )
	EndIf
	
	dbSelectArea("SN7")
	SN7->(dbSetOrder(1))
	If dbSeek(xFilial("SN7")+cBase+cItem)
		RecLock("SN7",.F.)
		SN7->N7_VLREAL  := 0
		SN7->N7_DTBAIXA := CtoD("  /  /  ")
		SN7->(MsUnlock())
	EndIf

	If lCancTrans
		cIDSN4Aux	:= SN4->N4_IDMOV
		nRecnoSN4	:= SN4->(Recno())
	EndIf

	/*
	* Exclui registro de movimentacao da baixa 										³
	*/
	cIdMov := ""
	While SN4->N4_FILIAL+SN4->N4_CBASE+SN4->N4_ITEM+SN4->N4_TIPO+DTOS(SN4->N4_DATA)==cChave .And. SN4->(!Eof())
		If cSeq == SN4->N4_SEQ  .And. (SN4->N4_OCORR $ "01/06/07/08/10/20" .Or. (SN4->N4_OCORR $ "03" .And. lCancTrans))// Removida implantacao, caso baixar

			//------------------------------------------------------------------------------------------------------------------------------
			// O tratamento abaixo é necessário pois o N4_IDMOV não é corretamente ordenado e caso o ativo possua mais de uma transferencia
			// (contábil e/ou filial), o sistema tem que excluir somente os movimentos relativos a última transferencia.
			// Foi inserida avalição de RECNO pois na transferência em lote, o N4_IDMOV do segundo ativo não seguia ordem crescente, o
			// problema foi corrigido e no merge para Main será levada somente a avalição do N4_IDMOV.
			//-------------------------------------------------------------------------------------------------------------------------------
			If (lCancTrans .And. (/*cIDSN4Aux > SN4->N4_IDMOV .Or.*/ nRecnoSN4 > SN4->(Recno()))) .And.  (SN4->N4_OCORR <> '06' .And. SN4->N4_MOTIVO <> '18' )
				SN4->(DBSkip())
				Loop
			EndIf

			PcoDetLan("000370","01","ATFA036",.T.)
			//AVP
			//Cancela movimentos de AVP da baixa que esta sendo cancelada
			If SN4->N4_TIPO == '14'
				AFCanAVP(SN4->N4_CBASE,SN4->N4_ITEM,SN4->N4_TPSALDO,SN4->N4_IDMOV,@nHdlPrv,@nTotal,@cArquivo,@cLoteAtf)
			Endif
			//acrescentado por Fernando Radu Muscalu em 12/05/2011
			//Tratamento do estorno dos movimentos de rateio
			If cIdMov <> SN4->N4_IDMOV
				If cPaisLoc $ "ARG|BRA|COS"
					
					ATFRTMOV(	SN4->N4_FILIAL,;
						SN4->N4_CBASE,;
						SN4->N4_ITEM,;
						SN4->N4_TIPO,;
						SN4->N4_SEQ,;
						SN4->N4_DATA,;
						SN4->N4_IDMOV,;
						,;
						mv_par01 <> 3,;
						"2",;
						nHdlPrv,;
						cLoteATF,;
						@nTotal)
					
				Endif
			Endif
			RecLock("SN4",.F.,.T.)				// e cancelar baixa no dia da implantacao
			SN4->(dbDelete())					// Excluiria indevidamente
			SN4->(MsUnlock())
			FKCOMMIT()
		EndIf
		cIdMov := SN4->N4_IDMOV
		
		SN4->(dbskip())
	EndDo
	
	nRec := SN3->(Recno())
	If lIsRussia
		cQrySN3 := " SELECT "
		cQrySN3 += " SN3.R_E_C_N_O_ RECNOSN3 "
		cQrySN3 += " FROM " + RetSqlName("SN3") + " SN3 "
		cQrySN3 += " WHERE "
		cQrySN3 += RetSqlCond("SN3")
		cQrySN3 += " AND SN3.N3_CBASE = '" + SN3->N3_CBASE + "' "
		cQrySN3 += " AND SN3.N3_ITEM = '" + SN3->N3_ITEM + "' "
		cQrySN3 += " AND SN3.N3_TIPO = '" + SN3->N3_TIPO + "' "
		cQrySN3 += " AND SN3.N3_SEQ <> '" + SN3->N3_SEQ + "' "
		cQrySN3 += " AND SN3.N3_BAIXA = '1' "
		
		cQrySN3	:= ChangeQuery(cQrySN3)
		cAlsSN3	:= CriaTrab(, .F.)

		dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQrySN3) , cAlsSN3 , .T. , .F.)
		
		nVlOrAnt	:= 0
		If (cAlsSN3)->(!EOF())
			nVlOrAnt	:= SN3->N3_VORIG1
		EndIf
		
		(cAlsSN3)->(dbCloseArea())
		dbSelectArea("SN3")
	EndIf
	SN3->(dbSetOrder(1))
	SN3->(dbSeek(xFilial("SN3")+cBase+cItem+cTipo+"0"))
	lParc := .F.
	While SN3->(!Eof()) .And. xFilial("SN3")+cBase+cItem+cTipo+"0"= SN3->N3_FILIAL+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO+SN3->N3_BAIXA	

		If SN3->N3_TPSALDO != cTpSaldo
			SN3->(dbSkip())
			Loop
		EndIf

		If SN3->N3_SEQREAV != cSeqReav
			SN3->(dbSkip())
			Loop
		Else
			lParc := .T.
			Exit
		EndIf
		
	EndDo

	If !lParc
		/*
		* Caso não exista registro de baixa parcial, significa que o
		* bem sofreu apenas um baixa total, portanto os seus valores
		* estao ativos, sendo necess rio apenas atualizar sua situação
		* (N3_BAIXA).Quando o bem esta totalmente baixado com várias
		* parciais, no cancelamento da 1a delas ‚ como se fosse a de
		* uma baixa total.
		*/
		SN3->(dbGoto(nRec))
		A36AtVrdMes(@aUltDepr,cOcorr,dUltDepr)
		Reclock("SN3")
		SN3->N3_OK 	  	:= "  "
		SN3->N3_BAIXA   := "0"
        SN3->N3_NOVO := ""
		If lIsRussia
			SN3->N3_OPER	:= "1"
		EndIf
		SN3->N3_IDBAIXA := " "
		SN3->N3_DTBAIXA := Ctod("")
		SN3->N3_VRCBAL1 -= SN3->N3_VRCMES1
		SN3->N3_VRCACM1 -= SN3->N3_VRCMES1
		
		SN3->N3_VRCDB1  -= SN3->N3_VRCDM1
		SN3->N3_VRCDA1  -= SN3->N3_VRCDM1
		
		If FN6->FN6_DEPREC $ '1|2'
			/*
			* Controle de multiplas moedas
			*/
			AtfMultMoe("SN3","N3_VRDBAL",{|x| SN3->&( If(x>9,"N3_VRDBA","N3_VRDBAL")+Alltrim(Str(x)) ) - SN3->&( If(x>9,"N3_VRDME","N3_VRDMES")+Alltrim(Str(x)) ) })
			/*
			* Controle de multiplas moedas
			*/
			AtfMultMoe("SN3","N3_VRDACM",{|x| SN3->&( If(x>9,"N3_VRDAC","N3_VRDACM")+Alltrim(Str(x)) ) - SN3->&( If(x>9,"N3_VRDME","N3_VRDMES")+Alltrim(Str(x)) ) })
		
		EndIf

		/*
		* Controle de multiplas moedas
		*/	
		AtfMultMoe("SN3","N3_VRDMES",{|x| aUltDepr[x] })
		
		/*
		* Atualiza o Cadastro de CIAP
		*/
		dbSelectArea("SF9")
		dbSetOrder(1)
		If ( dbSeek(xFilial("SF9")+SN1->N1_CODCIAP) ) .And. lMovCiap
		    nParcelas := Iif(SF9->F9_SLDPARC==0, A036CalParc(SF9->F9_CODIGO, dDtBaixa), SF9->F9_SLDPARC)
			RecLock("SF9")
			SF9->F9_DOCNFS := ""
			SF9->F9_SERNFS := ""
			SF9->F9_ITEMNFS := ""
			SF9->F9_DTEMINS:= Ctod("")
			SF9->F9_MOTIVO := ""
			SF9->F9_BXICMS-= SN3->N3_BXICMS
			SF9->F9_SLDPARC:= nParcelas
			SF9->(MsUnlock())
			dbSelectArea("SFA")
			If (dbSeek(xFilial("SFA")+SF9->F9_CODIGO+Dtos(dDtBaixa)+'2'))
				While !Eof() .and. (SFA->FA_FILIAL+SFA->FA_CODIGO+DTOS(SFA->FA_DATA)+SFA->FA_TIPO) == (xFilial("SFA")+SF9->F9_CODIGO+DTOS(dDtBaixa)+'2')
					RecLock("SFA")
					dbDelete()
					MsUnlock()
					dbSkip()
				EndDo
			EndIf
			SN3->N3_BXICMS := 0
		EndIf
		dbSelectArea("SN3")
		SN3->(MsUnlock())
		
		If lIsRussia
			aAdd(aFARules, {SN3->N3_CBASE, SN3->N3_ITEM})
		EndIf

		/*
		* Tratamento do estorno dos movimentos de rateio
		*/
		If AFXVerRat()
			If SN3->N3_RATEIO == "1"
				cRevAtu := AF011GETREV(SN3->N3_CODRAT)
				Af011AtuStatus(SN3->N3_CODRAT,cRevAtu,"3")
			Endif
		Endif
	Else
		/*
		* Deve retornar os valores da baixa parcial para o registro de aquisição
		*/
		Reclock("SN3")
		SN3->N3_IDBAIXA := "1"
		
		SN3->N3_VMXDEPR += nVMXDEP
		SN3->N3_VLSALV1 += nVLSALV 		

		AtfMultMoe("SN3","N3_VORIG",{|x| Round( SN3->&("N3_VORIG"+Alltrim(Str(x)))  + aOrig[x]  , X3Decimal( "N3_VORIG"+Alltrim(Str(x)) ) ) })
		AtfMultMoe("SN3","N3_AMPLIA",{|x| Round( SN3->&(If(x>9,"N3_AMPLI","N3_AMPLIA")+Alltrim(Str(x)))  + aAmplia[x]  , X3Decimal( If(x>9,"N3_AMPLI","N3_AMPLIA")+Alltrim(Str(x)) ) ) })		
		
		SN3->N3_VRCMES1 := Round( SN3->N3_VRCMES1 + nVrcMes1, X3Decimal("N3_VRCMES1") )
		SN3->N3_VRCBAL1 := Round( SN3->N3_VRCBAL1 + nVrcBal1, X3Decimal("N3_VRCBAL1") )
		SN3->N3_VRCACM1 := Round( SN3->N3_VRCACM1 + nVrcAcm1, X3Decimal("N3_VRCACM1") )
		
		SN3->N3_VRCDM1  := Round( SN3->N3_VRCDM1  + nVrcdM1 , X3Decimal("N3_VRCDM1") )
		SN3->N3_VRCDB1  := Round( SN3->N3_VRCDB1  + nVrcdB1 , X3Decimal("N3_VRCDB1") )
		SN3->N3_VRCDA1  := Round( SN3->N3_VRCDA1  + nVrcdA1 , X3Decimal("N3_VRCDA1") )

		AtfMultMoe("SN3","N3_VRDBAL",{|x| Round( SN3->&(If(x>9,"N3_VRDBA","N3_VRDBAL")+Alltrim(Str(x)))  + aVrdBal[x]  , X3Decimal( If(x>9,"N3_VRDBA","N3_VRDBAL")+Alltrim(Str(x)) ) ) })
		AtfMultMoe("SN3","N3_VRDACM",{|x| Round( SN3->&(If(x>9,"N3_VRDAC","N3_VRDACM")+Alltrim(Str(x)))  + aVrdAcm[x]  , X3Decimal( If(x>9,"N3_VRDAC","N3_VRDACM")+Alltrim(Str(x)) ) ) })
		
		/*
		* Atualiza o Cadastro de CIAP
		*/
		//Salvando o valor do estorno para deduzir do valor da tabela SF9 */ 
		DbSelectArea("SFA")
		DbSetOrder(1)
		If (DbSeek(xFilial("SFA")+SN1->N1_CODCIAP+Dtos(dDtBaixa)+'2'))
			nValSfa := SFA->FA_VALOR
		EndIf
		dbSelectArea("SF9")
		SF9->(dbSetOrder(1))
		If ( dbSeek(xFilial("SF9")+SN1->N1_CODCIAP) ) .and. lMovCiap
			SF9->(RecLock("SF9"))
			SF9->F9_DOCNFS := ""
			SF9->F9_SERNFS := ""
			SF9->F9_DTEMINS:= Ctod("")
			SF9->F9_MOTIVO := ""
			SF9->F9_BXICMS -= nValSfa
			SF9->(MsUnlock())
			
			dbSelectArea("SFA")
			If (dbSeek(xFilial("SFA")+SF9->F9_CODIGO+Dtos(dDtBaixa)+'2'))
				While SFA->(!Eof()) .and. (SFA->FA_FILIAL+SFA->FA_CODIGO+DTOS(SFA->FA_DATA)+SFA->FA_TIPO) == (xFilial("SFA")+SF9->F9_CODIGO+DTOS(dDtBaixa)+'2')
					SFA->(RecLock("SFA"))
					SFA->(dbDelete())
					SFA->(MsUnlock())
					SFA->(dbSkip())
				EndDo
			EndIf
			SN3->N3_BXICMS := 0
		EndIf
		
		SN3->N3_BAIXA   := "0"
		If lIsRussia
			SN3->N3_OPER	:= "1"
		EndIf
		SN3->N3_DTBAIXA := Ctod("")
		SN3->N3_OK 	  := "  "
		SN3->(MsUnlock())
		
		/*
		* Exclui registro da baixa
		*/
		SN3->(dbGoTo( nRec ))
		/*
		* Tratamento do estorno dos movimentos de rateio
		*/
		If AFXVerRat()
			If SN3->N3_RATEIO == "1"
				AF011DEL({{SN3->N3_CODRAT}},.T.)
			Endif
		Endif
		
		Reclock( "SN3" ,.F.,.T.)
		SN3->(dbDelete())
		SN3->(MsUnlock())

		If lIsRussia
			aAdd(aFARules, {cBase, cItem})
		EndIf
	EndIf
	
Endif

/*
* Tratamento do estorno dos movimentos de rateio
*/
ATFRTMOV(SN4->N4_FILIAL,;
	SN4->N4_CBASE,;
	SN4->N4_ITEM,;
	SN4->N4_TIPO,;
	SN4->N4_SEQ,;
	SN4->N4_DATA,;
	SN4->N4_IDMOV,;
	,;
	mv_par01 <> 3,;
"2",;
	nHdlPrv,;
	cLoteATF,;
	@nTotal,;
	,;
	FunName() ,;
	"81F",;
	,lOnOff)

If nRegSN4 > 0
	SN4->(DbGoTo(nRegSN4))
	SN4->(RecLock("SN4",.F.,.T.))
	SN4->(dbDelete())
	SN4->(msUnlock())
	
	SN3->(dbSetOrder(1))
	If SN3->(MsSeek(cFilSN3 + cBase + cItem + cTipo ))
		SN3->(RecLock("SN3",.F.))
		SN3->N3_BAIXA    := "0"
		If lIsRussia
			SN3->N3_OPER	:= "1"
		EndIf
		SN3->N3_DTBAIXA  := Ctod("")
		SN3->(MSUnlock())
		
		If lIsRussia
			aAdd(aFARules, {SN3->N3_CBASE, SN3->N3_ITEM})
		EndIf

		/*
		* Tratamento do estorno dos movimentos de rateio
		*/
		If AFXVerRat()
			If SN3->N3_RATEIO == "1"
				cRevAtu := AF011GETREV(SN3->N3_CODRAT)
				Af011AtuStatus(SN3->N3_CODRAT,cRevAtu,"3")
			EndIf
		EndIf
	EndIf
	
	dbSelectArea("SN7")
	SN7->(dbSetOrder(1))
	If SN7->(dbSeek(cFilSN7 + cBase + cItem))
		SN7->(RecLock("SN7",.F.))
		SN7->N7_VLREAL  := 0
		SN7->N7_DTBAIXA := CtoD("  /  /  ")
		SN7->(msUnlock())
	EndIf
EndIf

If lIsRussia
	ProcFARules(aFARules)
EndIf

RestArea(aAreaSN7)
RestArea(aAreaSN4)
RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A036VlNota

Cancela a(s) baixa(s) efetuada(s)  e atualiza as tabelas envolvidas
Valida se a nota fiscal de saída foi estornada/excluída para permitir o cancelamento da baixa.

@author marylly.araujo
@since 31/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A036VlNota(cNota,cSerie,cCliente,cLoja)
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaSF2	:= SF2->(GetArea())    
Local lVldNF	:= SuperGetMv("MV_ATFVLNF",.F.,.T.) // Parametro que habilita/desabilita a validacao da nota fiscal na SF2
Local cPedido	:= GetAdvFVal("SC6","C6_NUM" ,XFilial("SC6")+cNota+cSerie,4,"")

DEFAULT cNota	:= ""
DEFAULT cSerie	:= ""
DEFAULT cCliente:= ""
DEFAULT cLoja	:= ""

If lVldNF
	SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If SF2->(dbSeek( xFilial("SF2") + cNota + cSerie + cCliente + cLoja))
		//-------------------------------
		// Exclui a Nota Fiscal de Saida se a nota fiscal não foi gerada pela baixa.
		//-------------------------------
		If FN6->FN6_NUMNF == cNota .And. FN6->FN6_SERIE == cSerie .And. FN6->FN6_GERANF == '1'
			lRet := AF036ExcNF(cNota,cSerie,cCliente,cLoja,cPedido)
		EndiF
	EndIf

Endif

RestArea(aAreaSF2)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036AutRt

Rotina Automatica de Baixa de Ativo
@author caique.ferreira
@since 10/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF036AutRt(xCab,xAtivo,xOpcAuto,lBaixaTodos)

Local aSN3			:= SN3->(GetArea())
Local aSN4			:= SN4->(GetArea())
Local aFN6			:= FN6->(GetArea())
Local aFN7			:= FN7->(GetArea())
Local cLog			:= ""
Local lRet			:= .T.
Local nX			:= 1
Local nY			:= 1
Local oAux			:= Nil
Local oAux2			:= Nil
Local cAtivo		:= ""
Local nFilFN6		:= aScan(xCab,		{|x| AllTrim(x[1]) == "FN6_FILIAL"})
Local nCBx			:= aScan(xCab,		{|x| AllTrim(x[1]) == "FN6_CODBX"})
Local nDEPREC		:= aScan(xCab,		{|x| AllTrim(x[1]) == "FN6_DEPREC"})
Local nPercBx       := aScan(xCab,		{|x| AllTrim(x[1]) == "FN6_PERCBX"})
Local nFilSN3		:= aScan(xAtivo,		{|x| AllTrim(x[1]) == "N3_FILIAL"})
Local nFilSN3Ori	:= aScan(xAtivo,		{|x| AllTrim(x[1]) == "N3_FILORIG"})
Local nCB			:= aScan(xAtivo,		{|x| AllTrim(x[1]) == "N3_CBASE"})
Local nItem		:= aScan(xAtivo,		{|x| AllTrim(x[1]) == "N3_ITEM"})
Local nTipo		:= aScan(xAtivo,		{|x| AllTrim(x[1]) == "N3_TIPO"})
Local nBx			:= aScan(xAtivo,		{|x| AllTrim(x[1]) == "N3_BAIXA"})
Local nTP			:= aScan(xAtivo,		{|x| AllTrim(x[1]) == "N3_TPSALDO"})
Local nSeqReav	:= aScan(xAtivo,		{|x| AllTrim(x[1]) == "N3_SEQREAV"})
Local nSeq			:= aScan(xAtivo,		{|x| AllTrim(x[1]) == "N3_SEQ"})
Local nVlVend		:= aScan(xCab,		{|x| AllTrim(x[1]) == "FN6_VLVEND"}) // Campo não existente, tratado para evitar erro em rotinas antigas
Local cTable		:= ""
Local nSaveSx8Len	:= GetSx8Len()
Local cRotina		:= FunName()
Local cTitle		:= ""
Local cFilOrig	:= ""
Local nU            := 0 
Local nLinha        := 0 
Default lBaixaTodos := .T.


If xOpcAuto == 3
	__nOper := OPER_BAIXA
	MV_PAR04 := 2
	cTable := "SN3"
	cLog := STR0089+CRLF+CRLF+CRLF		//"Rotina automática de baixa de ativos - inclusão"
	cLog += STR0091+CRLF+CRLF+CRLF		//"Lista de inconsistências"
ElseIf xOpcAuto == 5
	__nOper := OPER_CANC
	MV_PAR04 := 1
	cTable := "FN6"
	cLog := STR0090+CRLF+CRLF+CRLF		//"Rotina automática de baixa de ativos - exclusão"
	cLog += STR0091+CRLF+CRLF+CRLF		//"Lista de inconsistências"
EndIf

dbSelectArea(cTable)

If cTable $ "SN3"
	If xCab <> Nil .And. xAtivo <> Nil .And. nFilSN3 > 0 .And. nCB > 0 .And. nItem > 0 .And. nTipo > 0 .And.	nBx > 0
		cAtivo := Padr(	xAtivo[nFilSN3,2]	,TAMSX3("N3_FILIAL")[1])
		cAtivo += Padr(	xAtivo[nCB,2]	,TAMSX3("N3_CBASE")[1])
		cAtivo += Padr(	xAtivo[nItem,2]	,TAMSX3("N3_ITEM")[1])
		cAtivo += Padr(	xAtivo[nTipo,2]	,TAMSX3("N3_TIPO")[1])
		cAtivo += Padr(	xAtivo[nBx,2]	,TAMSX3("N3_BAIXA")[1])
		If nTP > 0
			cAtivo += Padr(	xAtivo[nTP,2]	,TAMSX3("N3_TPSALDO")[1])
		EndIf
	ElseIf xAtivo == Nil
		lRet := .F.
		lMsErroAuto := .T.
		Help("  ",1,"AF036AutRt",,STR0086,1,0 )//"Informe o array xAtivo."
	ElseIf xCab == Nil
		lRet := .F.
		lMsErroAuto := .T.
		Help("  ",1,"AF036AutRt",,STR0085,1,0 )//"Informe o array xCab."
	EndIf
	SN3->(dbSetOrder(11))
ElseIf cTable $ "FN6"
	If xCab <> Nil .And. nFilFN6 > 0 .And. nCBx > 0
		cAtivo := Padr(	xCab[nFilFN6,2]	,TAMSX3("FN6_FILIAL")[1])
		cAtivo += Padr(	xCab[nCBx,2]	,TAMSX3("FN6_CODBX")[1])
		FN6->(dbSetOrder(1))
	Else
		If xCab <> Nil .And. xAtivo <> Nil .And. (nFilSN3 > 0 .Or. nFilSN3Ori > 0) .And. nCB > 0 .And. nItem > 0 .And. nTipo > 0 .And.	nSeqReav > 0 .And.	nSeq > 0

			cFilOrig := If(nFilSN3Ori > 0, xAtivo[nFilSN3Ori,2], xAtivo[nFilSN3,2]) 

			cCodBx := A036ULTCOD(xAtivo[nCB,2],xAtivo[nItem,2],xAtivo[nTipo,2],xAtivo[nTP,2],cFilOrig,,,xAtivo[nSeq,2])

			If !Empty(cCodBx)
				cAtivo := xFilial("FN6")
				cAtivo += Padr( cCodBx ,TAMSX3("FN6_CODBX")[1])
			Else
				lRet := .F.
				lMsErroAuto := .T.
				Help("  ",1,"AF036AutRt",,STR0085,1,0 )//"Informe o array xCab."
			EndIf
		Else
			lRet := .F.
			lMsErroAuto := .T.
			Help("  ",1,"AF036AutRt",,STR0085,1,0 )//"Informe o array xCab."
		EndIf
		
	EndIf
EndIf


lRet := lRet .And. &(cTable+'->(dbSeek("'+cAtivo+'"))')

If lRet .And. cTable = 'FN6'.And. xOpcAuto == 5
	FN7->(dbseek(cAtivo) )
EndIf

If !&(cTable+'->(dbSeek("'+cAtivo+'"))')
	lRet := .F.
	lMsErroAuto := .T.
	Help("   ",1,"AF036AutRt",,STR0163,1,0 ) //Bem Não Encontrado
EndIf 

If lRet

	If __oModelAut == Nil
		__oModelAut := FWLoadModel( 'ATFA036' )
	EndIf
	
	If xOpcAuto == 3 .Or. cRotina $ "ATFA320"
		__oModelAut:SetOperation(MODEL_OPERATION_UPDATE)
	ElseIf xOpcAuto == 5
		__oModelAut:SetOperation(xOpcAuto)
	EndIf
	
	If cTable $ "FN6" //Posiciona na SN1 e SN3 quando o cancelamento tiver a origem a tabela FN6
		SN1->(dbSetOrder(1))
		SN3->(dbSetOrder(1))
		SN1->(dbseek(FWxFilial("SN1") + xAtivo[nCB,2] + xAtivo[nItem,2]) ) 

		If xOpcAuto == 5
			SN3->(dbSeek(FWxFilial("SN3") + xAtivo[nCB,2] + xAtivo[nItem,2] + xAtivo[nTipo,2] + '1' + FN7->FN7_SEQ ))
		Else
			SN3->(dbSeek(FWxFilial("SN3") + xAtivo[nCB,2] + xAtivo[nItem,2] + xAtivo[nTipo,2] ))
		EndIf
	EndIf
	
	if __oModelAut:Activate()
	
		If xOpcAuto == 3
			oAux	   := __oModelAut:GetModel('FN7TIPO')
			oAux2	   := __oModelAut:GetModel('FN7VALOR')
			oModelFN6 := __oModelAut:GetModel('FN6MASTER')
			If nDEPREC >0
				oModelFN6:LoadValue(xCab[nDEPREC,1], xCab[nDEPREC,2])
			EndIf
			For nX := 1 To Len(xCab) 
				If nVlVend == 0 .Or. nX != nVlVend
					If oModelFN6:CanSetValue(xCab[nX,1])
						oModelFN6:SetValue(xCab[nX,1], xCab[nX,2])
					EndIF
				EndIF
			Next nX
		
			For nY := 1 To oAux:Length()
				oAux:GoLine( nY )
				
				If lBaixaTodos
					oAux:LoadValue("OK", .T. )
				Else
					cTipo 		:= oAux:GetValue("FN7_TIPO")
					cTpSaldo	:= oAux:GetValue("FN7_TPSALD")
					If xAtivo[nTipo,2] == cTipo .And. xAtivo[nTP,2]  == cTpSaldo
						oAux:LoadValue("OK", .T. )
						oAux:LoadValue("FN7_PERCBX", xCab[nPercBx,2] )
						For nU := 1 to oAux2:Length()
						oAux2:Goline( nU )
						oAux2:SetValue("FN7_PERCBX", xCab[nPercBx,2] )
						Next
						oAux2:Goline( 1 )
						nLinha := nY
					Else
						oAux:LoadValue("OK", .F. )
					EndIf
				EndIf

			Next nY
			oAux:GoLine( nLinha )
		EndIf
	
		If lRet .And. cRotina $ "ATFA320"
			If xOpcAuto == 3
				cTitle := STR0115 // ''Confirmar Baixa Automática'
			ElseIf xOpcAuto == 5
				cTitle := STR0116 // ''Cancelar Baixa Automática'
			EndiF
			IF !( FWExecView(cTitle,;
					'ATFA036',;
					MODEL_OPERATION_UPDATE,;
					/*oDlg*/,;
					{ || .T. },;
					/*bOk*/,;
					/*nPercReducao*/,;
					/*aEnableButtons*/,;
					/*bCancel*/,;
					/*cOperatId*/,;
					/*cToolBar*/,;
					__oModelAut) == 0)
				RollBackSx8()
				lRet := .F.
			EndIf
		ElseIf lRet
			If __oModelAut:VldData()
				// Confirma o cCodBaixa
				While (GetSx8Len() > nSaveSx8Len)
					ConfirmSX8()
				Enddo
				__oModelAut:CommitData()
			Else
				RollBackSx8()
				cLog += cValToChar(__oModelAut:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
				cLog += cValToChar(__oModelAut:GetErrorMessage()[MODEL_MSGERR_MESSAGE]) + ' - '
				cLog += cValToChar(__oModelAut:GetErrorMessage()[MODEL_MSGERR_VALUE])
				lMsErroAuto := .T.
				AutoGRLog(cLog)
				lRet := .F.
			EndIf
		Else
			RollBackSx8()
		EndIf
		__oModelAut:DeActivate()
		__oModelAut:Destroy()
		__oModelAut := Nil
	else
		cLog += cValToChar(__oModelAut:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
		cLog += cValToChar(__oModelAut:GetErrorMessage()[MODEL_MSGERR_MESSAGE]) + ' - '
		cLog += cValToChar(__oModelAut:GetErrorMessage()[MODEL_MSGERR_VALUE])
		lMsErroAuto := .T.
		AutoGRLog(cLog)
		lRet := .F.	
	endif
	
EndIf


RestArea(aSN3)
RestArea(aSN4)
RestArea(aFN6)
RestArea(aFN7)
__nOper := 0
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AT36StVlAc

Estrutura de dados para armazenar no modelo os valores acumulados necessário para a análise da baixa de ativo.

@author marylly.araujo
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Function AT36StVlAc()

Local oStruVlrAc	:= FWFormModelStruct():New()

/*
 * Valor Residual de Depreciação (aDiferenca) [1]
 */
oStruVlrAc:AddField(	 	;
STR0070					, ;	// [01] Titulo do campo		//"Valor Residual de Depreciação"
STR0070					, ;	// [02] ToolTip do campo	//"Valor Residual de Depreciação"
"DIFERE"				, ;	// [03] Id do Field
"N"						, ;	// [04] Tipo do campo
TamSX3("FN7_VLRESI")[1]	, ;	// [05] Tamanho do campo
TamSX3("FN7_VLRESI")[2]	, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
						, ;	// [08] Code-block de validação When do campo
						, ;	// [09] Lista de valores permitido do campo
						.F.)// [10] Indica se o campo tem preenchimento obrigatório

/*
 * Valor da Correção Acumulada (aVrdacm) [2]
 */
oStruVlrAc:AddField(	  ;
STR0071					, ;	// [01] Titulo do campo		//"Valor de Correção Acumulada"
STR0071					, ;	// [02] ToolTip do campo	//"Valor de Correção Acumulada"
"VRDACM"				, ;	// [03] Id do Field
"N"						, ;	// [04] Tipo do campo
TamSX3("FN7_VLDEPR")[1]	, ;	// [05] Tamanho do campo
TamSX3("FN7_VLDEPR")[2]	, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
						, ;	// [08] Code-block de validação When do campo
						, ;	// [09] Lista de valores permitido do campo
						.F.)// [10] Indica se o campo tem preenchimento obrigatório

/*
 * Cálculo da Taxa Média de Depreciação - Quantidade de Dias por Moeda (aDias) [3]
 */
oStruVlrAc:AddField(	  ;
STR0072					, ;	// [01] Titulo do campo		//"Taxa Média de Depreciação - Quantidade de Dias por Moeda"	
STR0072					, ;	// [02] ToolTip do campo	//"Taxa Média de Depreciação - Quantidade de Dias por Moeda"
"ADIAS"					, ;	// [03] Id do Field
"N"						, ;	// [04] Tipo do campo
TamSX3("N3_TXDEPR1")[1]	, ;	// [05] Tamanho do campo
TamSX3("N3_TXDEPR1")[2]	, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
						, ;	// [08] Code-block de validação When do campo
						, ;	// [09] Lista de valores permitido do campo
						.F.)// [10] Indica se o campo tem preenchimento obrigatório

/*
 * Moeda (aDescMoeda) [4]
 */
oStruVlrAc:AddField(	  ;
STR0073 				, ;	// [01] Titulo do campo		//"Moeda" 
STR0073					, ;	// [02] ToolTip do campo	//"Moeda" 
"MOEDA"					, ;	// [03] Id do Field
"C"						, ;	// [04] Tipo do campo
TamSX3("FN7_MOEDA")[1]	, ;	// [05] Tamanho do campo
TamSX3("FN7_MOEDA")[2]	, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
						, ;	// [08] Code-block de validação When do campo
						, ;	// [09] Lista de valores permitido do campo
						.F.)// [10] Indica se o campo tem preenchimento obrigatório


/*
 * Tipo de Ativo [5]
 */
oStruVlrAc:AddField(	  ;
"Tipo de Ativo"			, ;	// [01] Titulo do campo		//"Tipo de Ativo"
"Tipo de Ativo"			, ;	// [02] ToolTip do campo	//"Tipo de Ativo"
"TPATIVO"				, ;	// [03] Id do Field
"C"						, ;	// [04] Tipo do campo
TamSX3("FN7_TIPO")[1]	, ;	// [05] Tamanho do campo
TamSX3("FN7_TIPO")[2]	, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
						, ;	// [08] Code-block de validação When do campo
						, ;	// [09] Lista de valores permitido do campo
						.F.)// [10] Indica se o campo tem preenchimento obrigatório

/*
 * Tipo de Saldo [6]
 */
oStruVlrAc:AddField(	  ;
"Tipo de Saldo"			, ;	// [01] Titulo do campo		//"Tipo de Saldo"
"Tipo de Saldo"			, ;	// [02] ToolTip do campo	//"Tipo de Saldo" 
"TPSALDO"				, ;	// [03] Id do Field
"C"						, ;	// [04] Tipo do campo
TamSX3("FN7_TPSALD")[1]	, ;	// [05] Tamanho do campo
TamSX3("FN7_TPSALD")[2]	, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
						, ;	// [08] Code-block de validação When do campo
						, ;	// [09] Lista de valores permitido do campo
						.F.)// [10] Indica se o campo tem preenchimento obrigatório


/*
 * Valor Atual do Ativo (aVlrAtual) [7]
 */
oStruVlrAc:AddField(	  ;
STR0074					, ;	// [01] Titulo do campo		//"Valor Atual"
STR0074					, ;	// [02] ToolTip do campo	//"Valor Atual"
"VLRATUAL"				, ;	// [03] Id do Field
"N"						, ;	// [04] Tipo do campo
TamSX3("FN7_VLATU")[1]	, ;	// [05] Tamanho do campo
TamSX3("FN7_VLATU")[2]	, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
						, ;	// [08] Code-block de validação When do campo
						, ;	// [09] Lista de valores permitido do campo
						.F.)// [10] Indica se o campo tem preenchimento obrigatório

/*
 * Valor a Depreciar (aValDepr) [8] 
 */
oStruVlrAc:AddField(	  ;
STR0075					, ;	// [01] Titulo do campo		//"Valor a Depreciar" 
STR0075					, ;	// [02] ToolTip do campo	//"Valor a Depreciar" 
"VLRDEP"				, ;	// [03] Id do Field
"N"						, ;	// [04] Tipo do campo
TamSX3("FN7_VLDEPR")[1]	, ;	// [05] Tamanho do campo
TamSX3("FN7_VLDEPR")[2]	, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
						, ;	// [08] Code-block de validação When do campo
						, ;	// [09] Lista de valores permitido do campo
						.F.)// [10] Indica se o campo tem preenchimento obrigatório

/*
 * Valor Residual (aVlrResid) [9]
 */
oStruVlrAc:AddField(	  ;
STR0076					, ;	// [01] Titulo do campo		//"Valor Residual"
STR0076					, ;	// [02] ToolTip do campo	//"Valor Residual"
"VALORRESID"			, ;	// [03] Id do Field
"N"						, ;	// [04] Tipo do campo
TamSX3("FN7_VLRESI")[1]	, ;	// [05] Tamanho do campo
TamSX3("FN7_VLRESI")[2]	, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
						, ;	// [08] Code-block de validação When do campo
						, ;	// [09] Lista de valores permitido do campo
						.F.)// [10] Indica se o campo tem preenchimento obrigatório

/*
 * Valor de Baixa (aValBaixa) [10]
 */
oStruVlrAc:AddField(	  ;
STR0077	 				, ;	// [01] Titulo do campo		//"Valor de Baixa"
STR0077					, ;	// [02] ToolTip do campo	//"Valor de Baixa"
"VALORBX"				, ;	// [03] Id do Field
"N"						, ;	// [04] Tipo do campo
TamSX3("FN7_VLBAIX")[1]	, ;	// [05] Tamanho do campo
TamSX3("FN7_VLBAIX")[2]	, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
						, ;	// [08] Code-block de validação When do campo
						, ;	// [09] Lista de valores permitido do campo
						.F.)// [10] Indica se o campo tem preenchimento obrigatório

/*
 * Percentual de Baixa (aPercBaixa) [11]
 */
oStruVlrAc:AddField(	  ;
STR0078					, ;	// [01] Titulo do campo		//"Percentual de Baixa"
STR0078					, ;	// [02] ToolTip do campo	//"Percentual de Baixa"
"PERCBAIX"				, ;	// [03] Id do Field
"N"						, ;	// [04] Tipo do campo
16						, ;	// [05] Tamanho do campo
8						, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
						, ;	// [08] Code-block de validação When do campo
						, ;	// [09] Lista de valores permitido do campo
						.F.)// [10] Indica se o campo tem preenchimento obrigatório

/*
 * Residuo inferior a 1 (uma) unidade monetaria sera adicionado a cota atual. (aDepr) [12]
 */
oStruVlrAc:AddField(	  ;
STR0079				 	, ;	// [01] Titulo do campo		//"Depreciação"
STR0079					, ;	// [02] ToolTip do campo	//"Depreciação"
"DEPREC"				, ;	// [03] Id do Field
"N"						, ;	// [04] Tipo do campo
TamSX3("FN7_VLDEPR")[1]	, ;	// [05] Tamanho do campo
TamSX3("FN7_VLDEPR")[2]	, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
						, ;	// [08] Code-block de validação When do campo
						, ;	// [09] Lista de valores permitido do campo
						.F.)// [10] Indica se o campo tem preenchimento obrigatório

/*
 * Quantidade de Baixa. (aQuant) [13]
 */
oStruVlrAc:AddField(	  ;
STR0080					, ;	// [01] Titulo do campo		//"Quantidade de Baixa" 
STR0080					, ;	// [02] ToolTip do campo	//"Quantidade de Baixa" 
"QUANTD"				, ;	// [03] Id do Field
"N"						, ;	// [04] Tipo do campo
TamSX3("FN6_QTDATU")[1]	, ;	// [05] Tamanho do campo
TamSX3("FN6_QTDATU")[2]	, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
						, ;	// [08] Code-block de validação When do campo
						, ;	// [09] Lista de valores permitido do campo
						.F.)// [10] Indica se o campo tem preenchimento obrigatório

/*
 * Taxa Media de Depreciação - Tx Media por Moeda (aTxMedia) [14]
 */
oStruVlrAc:AddField(	  ;
STR0081					, ;	// [01] Titulo do campo		//"Taxa Média de Depreciação"
STR0081					, ;	// [02] ToolTip do campo	//"Taxa Média de Depreciação"
"TXMEDIA"				, ;	// [03] Id do Field
"N"						, ;	// [04] Tipo do campo
TamSX3("N3_TXDEPR1")[1]	, ;	// [05] Tamanho do campo
TamSX3("N3_TXDEPR1")[2]	, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
						, ;	// [08] Code-block de validação When do campo
						, ;	// [09] Lista de valores permitido do campo
						.F.)// [10] Indica se o campo tem preenchimento obrigatório

/*
 * Taxa Mensal de Depreciação (aTaxaMes) [15]
 */
oStruVlrAc:AddField(	  ;
STR0082					, ;	// [01] Titulo do campo		//"Taxa Mensal "
STR0082					, ;	// [02] ToolTip do campo	//"Taxa Mensal "
"TAXAMES"				, ;	// [03] Id do Field
"N"						, ;	// [04] Tipo do campo
TamSX3("N3_TXDEPR1")[1]	, ;	// [05] Tamanho do campo
TamSX3("N3_TXDEPR1")[2]	, ;	// [06] Decimal do campo
{ || .T. }				, ;	// [07] Code-block de validação do campo
						, ;	// [08] Code-block de validação When do campo
						, ;	// [09] Lista de valores permitido do campo
						.F.)// [10] Indica se o campo tem preenchimento obrigatório

Return oStruVlrAc

//-------------------------------------------------------------------
/*/{Protheus.doc} AT36Visual

Visualizaçã

@author marylly.araujo
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AT36Visual(cTpVis)
Local lContinua	:= .T.
Local cFilFN6	:= FwxFilial("FN6")
Local lRet      :=  .T.
Default cTpVis	:= "1" //Visualiza baixa

lVisMotBx := .F.

Pergunte("AFA036",.F.)

__nParam04  := If(__nParam04 == NIL, mv_par04, __nParam04)
If __nParam04  != mv_par04
	Help(" ",1,"AF036PARAM",,STR0180,1,0) // "Sair da rotina e entrar novamente.O modo de carregar a tela foi alterado via parametro 4 do pergunte"
	lRet := .F.
EndIf
If lRet
	If cTpVis == "2" //Visualização do ativo
		
		SaveInter() //Necessario pois a abertura da ATFA012 muda os valores dos parametros
		
		DbSelectArea("SN1")
		SN1->(DbSetOrder(1)) // Filial + Código Base + Item
		
		If MV_PAR04 == 1 //Browse com base na FN6
			SN1->(DbSeek( FWxFilial("SN1") + FN6->FN6_CBASE + FN6->FN6_CITEM ) )
		ElseIf MV_PAR04 == 2 //Browse com base na SN3
			SN1->(DbSeek( FWxFilial("SN1") + SN3->N3_CBASE + SN3->N3_ITEM ) )
		EndIf
		
		FWExecView( STR0083 ,; // "Visualização da Ficha de Ativo"
		'ATFA012',;
			MODEL_OPERATION_VIEW,;
			/*oDlg*/,;
			{ || .T. },;
			/*bOk*/,;
			/*nPercReducao*/,;
			/*aEnableButtons*/,;
			/*bCancel*/,;
			/*cOperatId*/,;
			/*cToolBar*/,;
			/*oModel*/)
		
		RestInter()
		
	Else //Visualização da baixa

		__nOper	:= OPER_VISUA
		
		DbSelectArea("SN1")
		SN1->(DbSetOrder(1)) // Filial + Código Base + Item
		
		If MV_PAR04 == 1 //Browse com base na FN6
			SN1->(DbSeek( FWxFilial("FN6") + FN6->FN6_CBASE + FN6->FN6_CITEM ) )
			lVisMotBx := (cPaisLoc == "BRA")
		Else
			If MV_PAR04 == 2 //Browse com base na SN3
				SN1->(DbSeek( FWxFilial("SN3") + SN3->N3_CBASE + SN3->N3_ITEM ) )
				If FWModeAccess("SN3",3) == 'E'// Quando o ambiente é totalmente exclusivo
					cFILBem := IIF(!Empty(SN3->N3_FILORIG),SN3->N3_FILORIG,SN3->N3_FILIAL)
				Else
					cFILBem := xFilial('SN3')
				End
				aRet := A036ULTCOD(SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_TPSALDO,cFILBem,Nil,.T.,SN3->N3_SEQ)
				cFilFN6 := aRet[1]
				cCodBX  := aRet[2] 			
			ElseIf MV_PAR04 == 3 //Browse com base na SN1
				aRet := A036ULTCOD(SN1->N1_CBASE,SN1->N1_ITEM,,,SN1->N1_FILIAL,"SN1",.T.)
				cFilFN6 := aRet[1]
				cCodBX  := aRet[2] 			
			EndIf
			
			If !Empty(cCodBX)
				FN6->(DbSeek(cFilFN6 + cCodBX ))
				If FN6->FN6_STATUS == '2'
					lContinua := .F.
					Help(" ",1,"AT36Visual2",,STR0130  ,1,0) // "A baixa do registro selecionado foi cancelada."
				Else
					lVisMotBx := (cPaisLoc == "BRA")
				EndIf
			Else
				If (AF36Is030(xFilial(), SN3->N3_CBASE, SN3->N3_ITEM, SN3->N3_TIPO, SN3->N3_DTBAIXA, SN3->N3_SEQ, .T.))==""				
					AT36Visual("2")
				Endif 
				lContinua := .F.
			EndIf
		EndIf
		
		If lContinua
			FWExecView( STR0084 ,; // "Visualização da Baixa de Ativo"
			'ATFA036',;
				MODEL_OPERATION_VIEW,;
				/*oDlg*/,;
				{ || .T. },;
				/*bOk*/,;
				/*nPercReducao*/,;
				/*aEnableButtons*/,;
				/*bCancel*/,;
				/*cOperatId*/,;
				/*cToolBar*/,;
				/*oModel*/)
		EndIf

		lVisMotBx := .F.
		__nOper	:= 0
		
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AT36Activ

Função de atualização dos valores de baixa

@author marylly.araujo
@since 15/04/2014 
@version 1.0
/*/
//-------------------------------------------------------------------
Function AT36Activ(oModel)
Local aArea			:= GetArea()
Local aSN1Area		:= SN1->(GetArea())
Local aSN3Area		:= SN3->(GetArea())
Local lRet			:= .T.
Local oModelTipo	:= oModel:GetModel("FN7TIPO")
Local oModelMaster	:= oModel:GetModel(If(FWIsInCallStack("AF036BxLote") .or. lAtf030 ,"FN6ATIVOS", "FN6MASTER"))
Local nCtnTipo		:= 0
Local nPerBaixa		:= oModelMaster:GetValue("FN6_PERCBX" ) //% da baixa

For nCtnTipo := 1 To oModelTipo:Length()
	oModelTipo:GoLine(nCtnTipo)
	AF036ATU(oModel, nPerBaixa )
Next nCtnTipo

oModelTipo:GoLine(1)
aF36WhenTp(oModel)

RestArea(aSN1Area)
RestArea(aSN3Area)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AT36VlAct

Valida a ativação do Modelo

@author marylly.araujo
@since 15/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AT36VlAct(oModel)
Local aArea			:= GetArea()
Local aSN1Area		:= SN1->(GetArea())
Local aSN3Area		:= SN3->(GetArea())
Local lRet			:= .T.
Local cChave		:= ""

If __nOper == OPER_CANC
	If MV_PAR04 == 1
		cChave := FN6->FN6_CODBX
	ElseIf MV_PAR04 == 2 //Browse com base no Tipos de Ativo (SN3)
		If FWModeAccess("SN3",3) == 'E'// Quando o ambiente é totalmente exclusivo
			cFILBem := IIF(!Empty(SN3->N3_FILORIG),SN3->N3_FILORIG,SN3->N3_FILIAL)
		Else
			cFILBem := xFilial('SN3')
		End
		cChave := A036ULTCOD(SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_TPSALDO,cFILBem,"SN3",,SN3->N3_SEQ)
	ElseIf MV_PAR04 == 3 //Browse com base nos Ativos (SN1)
		cChave := A036ULTCOD(SN1->N1_CBASE,SN1->N1_ITEM,,,SN1->N1_FILIAL,"SN1")
	EndIf

	If Empty(cChave)
		IF  !(AF36Can030())
			Help(" ",1, "AF036CANBX",,STR0117,1,0)//"Não existem baixas para cancelar desse ativo."
		Endif
		lRet := .F.
	EndIf

EndIf

RestArea(aSN1Area)
RestArea(aSN3Area)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036GerNF
Gera a Nota Fiscal na Baixa do Bem.

@author Totvs
@since 14/04/2014
@version P12

@return Nil
/*/
//-------------------------------------------------------------------
Function AF036GerNF(cSerie, cCliente, cLoja , cCondPag, cProduto,nQtdBx ,nValNF,cTESSaida,dBaixa,aNotas)
Local aArea			:= GetArea()
// Array com os parametros do programa
Local cNotaFeita	:= ""
Local aCabec		:= {}
Local aItens		:= {}
Local ni			:= 0
Local aStruSD2   	:= {}
Local aStruSF2   	:= {}
Local aSF2RecNo		:= {}
Local nNotas		:= 0
Local nItens		:= 0
Local lRet			:= .T.
Local cUFOrig		:= ""
Local cUFDest		:= ""
Local cBaseNF		:= ""
Local cItemNF		:= ""
Local aEntCtb		:= {}

Default dBaixa := dDataBase

Private lMsErroAuto	:= .F.	// Variavel utilizada para verificar 1se o numero da nota foi alterado pelo
							// usuario (notas de saida e entrada com formulario proprio). 
Private lMudouNum	:= .F.	// Variavel utilizada para tratamento especifico para poder de terceiros
Private l310PODER3	:= .F.

SaveInter()

Pergunte("AFA036",.F.)

If QtdComp( nValNF, .T. ) == QtdComp( 0, .T. )
	nValNF := 1
EndIf
             
aStruSD2 := SD2->(dbStruct())
aStruSF2 := SF2->(dbStruct())

For nNotas := 1 To Len(aNotas)

	aItens := {}
	aCabec := {}
	/*-*/
	cBaseNF		:= aNotas[nNotas][1]
	cCliente	:= aNotas[nNotas][4]
	cLoja		:= aNotas[nNotas][5]
	cCondPag	:= aNotas[nNotas][6]
	cSerie		:= aNotas[nNotas][3]

	SA1->(MsSeek(xFilial("SA1") + cCliente + cLoja))

	//Inicializa variáveis fiscais do cliente	
	MaFisIni(cCliente, cLoja, "C", "N", SA1->A1_TIPO,,,,, "MATA461",,,,,, cCliente, cLoja)
	cUFOrig := MaFisRet(,"NF_UFORIGEM")
	cUFDest := MaFisRet(,"NF_UFDEST")
	MaFisEnd()

	For nI := 1 to len(aStruSF2)
		Do Case
			Case ALLTRIM(aStruSF2[nI,1]) == 'F2_FILIAL'
				Aadd(aCabec,xFilial("SF2"))							// Filial
			Case ALLTRIM(aStruSF2[nI,1]) == 'F2_CLIENTE'
				Aadd(aCabec,cCliente)								// Cliente
			Case ALLTRIM(aStruSF2[nI,1]) == 'F2_LOJA'
				Aadd(aCabec,cLoja)									// Loja
			Case ALLTRIM(aStruSF2[nI,1]) == 'F2_CLIENT'
				Aadd(aCabec,cCliente)								// Cliente
			Case ALLTRIM(aStruSF2[nI,1]) == 'F2_LOJENT'
				Aadd(aCabec,cLoja)									// Loja
			Case ALLTRIM(aStruSF2[nI,1]) == 'F2_TIPO'
				Aadd(aCabec,"N")							    	// Tipo (Normal)
			Case ALLTRIM(aStruSF2[nI,1]) == 'F2_TIPOCLI'
				Aadd(aCabec,SA1->A1_PESSOA)					    	// Tipo de cliente (F=Pessoa Fisica; J=Pessoa Juridica)
			Case ALLTRIM(aStruSF2[nI,1]) == 'F2_EMISSAO'
				Aadd(aCabec,dBaixa)							    // Data de emissao
			Case ALLTRIM(aStruSF2[nI,1]) == 'F2_COND'
				Aadd(aCabec,cCondPag)					    	 	// Condicao de pagamento
			Case ALLTRIM(aStruSF2[nI,1]) == 'F2_HORA'
				Aadd(aCabec,SubStr(Time(),1,5))						// Hora do processamento
			Case ALLTRIM(aStruSF2[nI,1]) == 'F2_EST'
				Aadd(aCabec,SA1->A1_EST)			 	        	// Estado
			Case ALLTRIM(aStruSF2[nI,1]) == 'F2_NEXTDOC'
				Aadd(aCabec,"      ")						    	// Proximo docto
			Case ALLTRIM(aStruSF2[nI,1]) == 'F2_UFORIG'
				Aadd(aCabec,cUFOrig)						    	// UF Origem
			Case ALLTRIM(aStruSF2[nI,1]) == 'F2_UFDEST'
				Aadd(aCabec,cUFDest)								// UF Destino
			Case ALLTRIM(aStruSF2[nI,1]) == 'F2_DTLANC'
				Aadd(aCabec,StoD(""))								// Flag de Contabiliza??o								// UF Destino
			Otherwise
				Aadd( aCabec, CriaVar(aStruSF2[nI,1]) )
		EndCase
	Next nI

	For nItens := 1 To Len(aNotas[nNotas][7])

		AAdd(aSF2RecNo,0)
		AAdd(aItens,{})

		
		cItemNF		:= aNotas[nNotas][7][nItens][1]
		cProduto	:= aNotas[nNotas][7][nItens][2]
		nQtdBx		:= aNotas[nNotas][7][nItens][3]
		nValNF		:= aNotas[nNotas][7][nItens][4]
		cTESSaida	:= aNotas[nNotas][7][nItens][5]

		aEntCtb := A36RetEnt(cBaseNF,cItemNF)		

		SB1->(MsSeek(xFilial("SB1") + cProduto))
		SF4->(MsSeek(xFilial("SF4") + cTESSaida))
		For nI := 1 to Len(aStruSD2)
			Do Case
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_FILIAL'
					Aadd( aItens[nItens],xFilial("SD2"))					// Filial
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_ITEM'
					Aadd( aItens[nItens],StrZero(1,TamSX3("D2_ITEM")[1]))	// Item
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_COD'
					Aadd( aItens[nItens],cProduto)							// Produto
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_UM'
					Aadd( aItens[nItens],SB1->B1_UM)						// Unidade de medida
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_QUANT'
					Aadd( aItens[nItens],nQtdBx)							// Quantidade
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_PRCVEN'
					Aadd( aItens[nItens],nValNF/nQtdBx) 					// Preco unitario
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_TOTAL'
					Aadd( aItens[nItens], nValNF)			 				// Valor total do item
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_TES'
					Aadd( aItens[nItens],cTESSaida)							// TES
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_CF'
					Aadd( aItens[nItens], SF4->F4_CF)						// Codigo Fiscal
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_DESCON'
					Aadd( aItens[nItens],0)									// Desconto
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_PEDIDO'
					Aadd( aItens[nItens],' ')								// Pedido de Venda
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_CLIENTE'
					Aadd( aItens[nItens],cCliente)							// Cliente
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_LOJA'
					Aadd(aItens[nItens],cLoja)								// Loja
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_TP'
					Aadd(aItens[nItens],SB1->B1_TIPO)						// Tp Produto
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_EMISSAO'
					Aadd(aItens[nItens],dBaixa)								// Emissao
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_PRUNIT'
					Aadd( aItens[nItens], nValNF/nQtdBx)	 				// Valor unitario do item
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_TIPO'
					Aadd(aItens[nItens],"N")								// Tipo
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_LOCAL'
					Aadd(aItens[nItens],SB1->B1_LOCPAD)						// Local
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_CONTA'
					Aadd(aItens[nItens],aEntCtb[1])							// Conta
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_CCUSTO'
					Aadd(aItens[nItens],aEntCtb[2])							// Centro de Custo
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_ITEMCC'
					Aadd(aItens[nItens],aEntCtb[3])							// Item Contabil
				Case ALLTRIM(aStruSD2[nI,1]) == 'D2_CLVL'
					Aadd(aItens[nItens],aEntCtb[4])							// Item Contabil
			Otherwise
				Aadd(aItens[nItens],CriaVar(aStruSD2[nI,1]) ) 				// demais campo da estrutura da tabela SD2 necessarios na criacao da nota fiscal sem pedido de vendas*/
			EndCase
		Next nI

	Next nItens

	cNotaFeita := MaNfs2Nfs(,,SA1->A1_COD,SA1->A1_LOJA,cSerie,(MV_PAR01 == 1),(MV_PAR02 == 1),(MV_PAR03 == 1),,,,,,,,,,{|| .T.},aSF2RecNo,aItens,aCabec,.F.,{|| .T.},,{|| .T.})

	If Empty(cNotaFeita)
		lRet := .F.
	Else
		aNotas[nNotas][2] := cNotaFeita	
	EndIf

Next nNotas

RestInter()
RestArea( aArea )

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036ExcNF

Exclusao da Nota Fiscal

@author Totvs
@since 23/04/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF036ExcNF(cNumNFS,cSerie,cCliente,cLoja,cPedido)
Local aAreaSF2		:= SF2->(GetArea())
Local aRegSD2		:= {}
Local aRegSE1		:= {}
Local aRegSE2		:= {}
Local lRet			:= .T.
Local lAglutCtb		:= .F.
Local lCtbOnLine	:= .F.
Local lDigita		:= .F.

Local nX			AS NUMERIC
Local cTmpAls		AS CHARACTER
Local cQuery		AS CHARACTER
Local cKeySC6		AS CHARACTER
Local aSOExcl		AS ARRAY
Local aArea			AS ARRAY
Local aAreaSC5		AS ARRAY
Local aAreaSC6		AS ARRAY
Local aAutoExcLi	AS ARRAY
Local aAutoExcIt	AS ARRAY
Local aAutoExcHe	AS ARRAY
Local aAutoExcBo	AS ARRAY
Local aTmp			AS ARRAY

Private lMsErroAuto	:= .F.

DEFAULT cNumNFS := ""
DEFAULT cSerie	:= ""
DEFAULT cCliente:= ""
DEFAULT cLoja	:= ""
DEFAULT cPedido	:= ""

Pergunte("AFA036",.F.)
AF036PerAt()

lDigita			:= MV_PAR01 == 1
lAglutCtb		:= MV_PAR02 == 1
lCtbOnLine		:= MV_PAR03 == 1

If lRet .And. lIsRussia
	cQuery	:= " select d2_pedido "
	cQuery	+= "   from " + RetSqlName("SD2")
	cQuery	+= "  where d_e_l_e_t_ = ' ' "
	cQuery	+= "    and d2_filial = '"+xFilial("SD2")+"' "
	cQuery	+= "    and d2_doc = '" + ;
		PADR(cNumNFS, GetSx3Cache("D2_DOC", "X3_TAMANHO"))+"' "
	cQuery	+= "    and d2_serie = '" + ;
		PADR(cSerie, GetSx3Cache("D2_SERIE", "X3_TAMANHO"))+"' "
	cQuery	+= " group by d2_pedido "
	cTmpAls	:= RU01GETALS(cQuery)
	aSOExcl	:= {}
	While (cTmpAls)->(! EOF())
		aAdd(aSOExcl, ;
			PADR((cTmpAls)->d2_pedido, GetSx3Cache("C5_NUM", "X3_TAMANHO")))
		(cTmpAls)->(dbSkip())
	EndDo
	(cTmpAls)->(dbCloseArea())
ElseIf lGerPVBra
	aSOExcl	:= {}
	if !Empty(cPedido)
		aAdd(aSOExcl,PADR(cPedido, GetSx3Cache("C5_NUM", "X3_TAMANHO")))		
	EndIf
EndIf

SF2->(DbSetOrder(1))
If	SF2->(MsSeek(xFilial("SF2") + cNumNFS + cSerie + cCliente + cLoja, .F.))
	//-- Verifica se o estorno do documento de saida pode ser feito.
 	If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2) .or. lAtf030
		//-- Estorna o documento de saida.
		
		SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,lDigita,lAglutCtb,lCtbOnLine,.T.,,1))
	Else
		lRet := .F.
		Help(" ",1, "AF036ExcNF",,STR0109,1,0) //"Não é possivel cancelar a Nota Fiscal."
	EndIf
Else
	lRet := .F.
	Help(" ",1, "AF036ExcNF",,STR0110,1,0) //"Nota Fiscal não localizada."
EndIf

// victor.rezende - Perform exclusion of created sales order
If lRet .And. (lIsRussia .Or. (lGerPVBra .And. Len(aSOExcl)>0 ))
	aArea		:= GetArea()
	aAreaSC5	:= SC5->(GetArea())
	aAreaSC6	:= SC6->(GetArea())

	aAutoExcLi	:= {}
	SC5->(dbSetOrder(1))	// C5_FILIAL+C5_NUM
	SC6->(dbSetOrder(1))	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	
	/*
	 * Grants all SO related to the invoice
	 * Feeds control arrays
	 */
	For nX := 1 To Len(aSOExcl)
		lRet	:= SC5->(dbSeek(xFilial("SC5") + aSOExcl[nX]))
		If ! lRet
			If lGerPVBra
				Help("",1,"AF036BRAINVSONFOUND",,STR0165,1,0)
			Else
				Help("",1,"AF036RUSINVSONFOUND",,STR0156,1,0)	// "The associated sales order could not be found, the storno of the invoice is not possible."
			EndIf
			Exit
		EndIf

		cKeySC6		:= xFilial("SC6") + SC5->C5_NUM

		aAutoExcHe	:= {}
		aAutoExcBo	:= {}
		aAdd(aAutoExcHe, {"C5_NUM",		SC5->C5_NUM,		Nil})
		aAdd(aAutoExcHe, {"C5_CLIENTE",	SC5->C5_CLIENTE,	Nil})
		aAdd(aAutoExcHe, {"C5_LOJACLI",	SC5->C5_LOJACLI,	Nil})

		If SC6->(dbSeek(cKeySC6))
			While SC6->(C6_FILIAL+C6_NUM) == cKeySC6
				aTmp	:= {}
				aAdd(aTmp, {"C6_NUM",		SC6->C6_NUM,		Nil})
				aAdd(aTmp, {"C6_ITEM",		SC6->C6_ITEM,		Nil})
				aAdd(aTmp, {"C6_PRODUTO",	SC6->C6_PRODUTO,	Nil})
				aAdd(aTmp, {"C6_UM",		SC6->C6_UM,			Nil})
				aAdd(aTmp, {"C6_QTDVEN",	SC6->C6_QTDVEN,		Nil})
				aAdd(aTmp, {"C6_PRUNIT",	SC6->C6_PRUNIT,		Nil})
				aAdd(aTmp, {"C6_VALOR",		SC6->C6_VALOR,		Nil})
				aAdd(aTmp, {"C6_TES",		SC6->C6_TES,		Nil})
				aAdd(aTmp, {"C6_LOCAL",		SC6->C6_LOCAL,		Nil})
				aAdd(aAutoExcBo, aTmp)
				SC6->(dbSkip())
			EndDo
		EndIf

		aAutoExcIt	:= {aAutoExcHe, aAutoExcBo}
		aAdd(aAutoExcLi, aAutoExcIt)
	Next nX

	/*
	 * Perform SO exclusions via MSExecAuto
	 */
	If lRet
		dbSelectArea("SC5")

		For nX := 1 To Len(aAutoExcLi)
			aAutoExcHe	:= aAutoExcLi[nX, 01]
			aAutoExcBo	:= aAutoExcLi[nX, 02]

			lRet		:= SC5->(dbSeek(xFilial("SC5") + aAutoExcHe[01, 02]))
			If ! lRet
				If lGerPVBra
					Help("",1,"AF036BRAINVSONFOUND2",,STR0165,1,0)
				Else
					Help("",1,"AF036RUSINVSONFOUND2",,STR0156,1,0)	// "The associated sales order could not be found, the storno of the invoice is not possible."
				EndIf
				Exit
			EndIf
			lMsErroAuto	:= .F.
			MSExecAuto({|x,y,z| MATA410(x,y,z)}, aAutoExcHe, aAutoExcBo, 5)
			lRet		:= ! lMsErroAuto
			If ! lRet
				MostraErro()
				Exit
			EndIf
		Next nX
	EndIf

	RestArea(aAreaSC6)
	RestArea(aAreaSC5)
	RestArea(aArea)
EndIf

RestArea(aAreaSF2)

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036X3Val

Funcao para realizar validacoes dinamicas, atendendo a baixa individual e em lote
Na baixa individual a FN6 é uma enchoice e na baixa em lote se torna uma grid

@author Totvs
@since 23/04/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF036X3Val(cCampoFN6)
Local lRet			:= .T.
Local oModel		:= FWModelActive()
Local oModelFN6	:= Nil

Default cCampoFN6	:= ""

If FWIsInCallStack("AF036BxLote") .Or. lAtf030
	oModelFN6 := oModel:GetModel("FN6ATIVOS")
Else
	oModelFN6 := oModel:GetModel("FN6MASTER")
EndIf

Do Case

	Case cCampoFN6 == "FN6_QTDBX"
		lRet := Positivo(oModelFN6:GetValue("FN6_QTDBX")) .And. (oModelFN6:GetValue("FN6_QTDBX") <= oModelFN6:GetValue("FN6_QTDATU"))

	Case cCampoFN6 == "FN6_SERIE"
		If ExistBlock("A036VLDSER") //Específico para alterar a validação do campo série - Para clientes que utilizam o PE do faturamento SX5NOTA
			lRet := ExecBlock("A036VLDSER", .F., .F., {oModelFN6})
		else
			lRet := IF(oModelFN6:GetValue("FN6_GERANF") == '1',EXISTCPO('SX5','01'+oModelFN6:GetValue("FN6_SERIE")),.T.)
		EndIf

	Case cCampoFN6 == "FN6_CLIENT"
		lRet := ExistCpo('SA1',oModelFN6:GetValue("FN6_CLIENT")+RTRIM(oModelFN6:GetValue("FN6_LOJA")),,,,!EMPTY(oModelFN6:GetValue("FN6_LOJA"))) 

	Case cCampoFN6 == "FN6_LOJA"
		lRet := ExistCpo('SA1',oModelFN6:GetValue("FN6_CLIENT")+oModelFN6:GetValue("FN6_LOJA")) 

EndCase

If cPaisLoc == "COL" .And. cCampoFN6 $ "FN6_CLIENT|FN6_LOJA" .And. lRet
	ATF036Cte( oModelFN6 )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AF036X3Whe

Funcao para habilitar/desabilitar campos dinamicamente, atendendo a baixa individual e em lote
Na baixa individual a FN6 é uma enchoice e na baixa em lote se torna uma grid

@author Totvs
@since 23/04/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF036X3Whe(cCampoFN6)
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oModelFN6	:= Nil

Default cCampoFN6	:= ""

If oModel != Nil
	If FWIsInCallStack("AF036BxLote") .or. lAtf030
		oModelFN6 := oModel:GetModel("FN6ATIVOS")
	Else
		oModelFN6 := oModel:GetModel("FN6MASTER")
	EndIf
EndIf

If oModelFN6 != Nil 
	Do Case

	Case cCampoFN6 == "FN6_NUMNF"
		lRet := oModelFN6:GetValue("FN6_GERANF") == '2'

	Case cCampoFN6 == "FN6_GERANF"
		lRet := oModelFN6:GetValue("FN6_MOTIVO") $ GETMV('MV_ATFMBNF')
	
	Case cCampoFN6 == "FN6_CLIENT"
		lRet := oModelFN6:GetValue("FN6_GERANF") == '1'

	Case cCampoFN6 == "FN6_LOJA"
		lRet := oModelFN6:GetValue("FN6_GERANF") == '1'

	Case cCampoFN6 == "FN6_VALNF"
		lRet := oModelFN6:GetValue("FN6_MOTIVO") $ GETMV('MV_ATFMBNF')

	Case cCampoFN6 == "FN6_CNDPAG"
		lRet := oModelFN6:GetValue("FN6_GERANF") == '1'

	Case cCampoFN6 == "FN6_TESSAI"
		lRet := oModelFN6:GetValue("FN6_GERANF") == '1'

	Case lIsRussia .And. cCampoFN6 == "FN6_SOCURR"
		lRet := oModelFN6:GetValue("FN6_GERANF") == '1'
		
	Case cPaisLoc == "MEX"
		If cCampoFN6 == "FN6_USOCFD"
			lRet := oModelFN6:GetValue("FN6_GERANF") == '1'
		EndIf

	Case cPaisLoc == "PER" .And. lExisCpo
		If cCampoFN6 $ "FN6_TPDOC|FN6_TIPONF"
			lRet := oModelFN6:GetValue("FN6_GERANF") == '1'
		EndIf

	Case cPaisLoc == "COL" .And. lExisCpo
		If cCampoFN6 $ "FN6_CODMUN|FN6_TPACTI|FN6_TRMPAC|FN6_TIPOPE"
			lRet := oModelFN6:GetValue("FN6_GERANF") == '1'
		EndIf

	Case cCampoFN6 == "FN6_NATURE"
		lRet := oModelFN6:GetValue("FN6_GERANF") == '1' .And. (lIsRussia .Or. GetAdvFVal("SF4","F4_DUPLIC",XFilial("SF4")+oModelFN6:GetValue("FN6_TESSAI"),1,"") == 'S')
	EndCase
EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AT36Baixa
Rotina de Baixa de Ativos

@author jdomingos

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function AT36Baixa()
Local aArea			:= GetArea()
Local cTitulo		:= STR0006 //"Baixar"
Local cPrograma		:= 'ATFA036'
Local nOperation	:= MODEL_OPERATION_UPDATE
Local cFilOld       := cFilAnt
Local lRet          := .T.

Pergunte("AFA036",.F.)

__nParam04  := If(__nParam04 == NIL, mv_par04, __nParam04)

If __nParam04  != mv_par04
	Help(" ",1,"AF036PARAM",,STR0180,1,0) // "Sair da rotina e entrar novamente.O modo de carregar a tela foi alterado via parametro 4 do pergunte"
	lRet := .F.
EndIf
If lRet
	If MV_PAR04 == 2  // BROWSE pelo SN3
		If SN3->(!EOF())
			// Tratamento realizado para ambiente exclusivo, respeitando o item selecionado 
			If FWModeAccess("SN3",3) == 'E'
				cFilAnt := Iif (SN3->N3_FILIAL <> cFilAnt, SN3->N3_FILIAL, cFilAnt )
			else
			// Tratamento para ambientes compartilhados, onde irá ser respeitado a filial origem da inclusão do ativo
				cFilAnt := Iif (SN3->N3_FILORIG <> cFilAnt, SN3->N3_FILORIG, cFilAnt )
			EndIf
			SN1->(DbSetOrder( 1 ))
			SN1->(DbSeek( XFilial("SN1") + SN3->N3_CBASE + SN3->N3_ITEM ))
		Else
			Help(" ",1,"NORECS") //"Este arquivo não contem dados a apresentar."
			lRet := .F.
		EndIf
	ElseIf MV_PAR04 == 3 // BROWSE no SN1
		If SN1->(!EOF())
			If FWModeAccess("SN1",3) == 'E'
				cFilAnt := Iif (SN1->N1_FILIAL <> cFilAnt, SN1->N1_FILIAL, cFilAnt )
			else
				SN3->(DbSetOrder( 1 ))
				SN3->(DbSeek( SN1->N1_FILIAL + SN1->N1_CBASE + SN1->N1_ITEM ))
				cFilAnt := Iif (SN3->N3_FILORIG <> cFilAnt, SN3->N3_FILORIG, cFilAnt )
			EndIf
		Else
			Help(" ",1,"NORECS") //"Este arquivo não contem dados a apresentar."
			lRet := .F.		
		Endif	
	EndIf
	If lRet
		__nOper := OPER_BAIXA

		nOk := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )

		If nOk == 1 // Caso cancele a operação 0 = Confirmar
			RollBackSx8()
		EndIf

		__nOper := 0
	EndIf
Endif
RestArea(aArea)
cFilAnt := cFilOld

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AT36Cance
Cancelamento de baixa simples

@author jdomingos

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function AT36Cance()
Local aArea			:= GetArea()
Local cTitulo		:= STR0027			//"Cancelar"
Local cPrograma		:= 'ATFA036'
Local nOperation	:= MODEL_OPERATION_UPDATE
Local nVisualiza	:= MV_PAR04

__nOper	:= OPER_CANC

	If nVisualiza == 2
		dbSelectArea("SN1")
		SN1->( dbSetOrder(1) )

		If SN1->( dbSeek(xFilial('SN1')+SN3->N3_CBASE+SN3->N3_ITEM) )
			nRet	:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
		EndIf
	
	ElseIf nVisualiza == 1

		dbSelectArea("SN1")
		SN1->( dbSetOrder(1) )

		If SN1->( dbSeek(xFilial('SN1')+FN6->FN6_CBASE+FN6->FN6_CITEM) )
			nRet	:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
		EndIf
	Else
	
		nRet	:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
	
	EndIf

__nOper	:= 0

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AT36CancMt
Cancelamento de multiplas baixa

@author Totvs

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function AT36CancMt()
Local aArea		:= GetArea()
Local cTitulo		:= STR0027		//"Cancelar"
Local cPrograma	:= 'ATFA036M'
Local nOperation	:= MODEL_OPERATION_UPDATE

__nOper	:= OPER_CANCM

nRet	:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )

__nOper	:= 0

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} aF36WhenTp
Habilita ou não a edição dos valore

@author jdomingos

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function aF36WhenTp(oModel)

Local oModelTipo  	:= oModel:GetModel("FN7TIPO")
Local oModelValor	:= oModel:GetModel('FN7VALOR')

If __oModelAut <> Nil .And. FWIsInCallStack("ATFA320")
	oModelTipo  := __oModelAut:GetModel("FN7TIPO")
	oModelValor := __oModelAut:GetModel('FN7VALOR')
EndIf

If __nOper == OPER_CANC .Or. oModelTipo:GetValue("FN7_TIPO") $ "14#15"  .Or. __nOper == OPER_VISUA 
	oModelValor:SetNoUpdateLine(.T.)
Else
	oModelValor:SetNoUpdateLine(.F.)
EndIf

oModelValor:GoLine(1)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} AT36Carga

Definições posteriores a ativação da view

@author Totvs

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function AT36Carga(oModel)

Local oModelMaster	:= oModel:GetModel('FN6MASTER')
Local oView			:= FWViewActive() 

If __nOper == OPER_CANC
	oModelMaster:LoadValue("FN6_DTBAIX", dDataBase)

	//----------------------------------------------------------------------------------
	// Tratamento para permitir a confirmação do cancelamento da baixa, pois o processo
	// é de alteração, porém o campo FN6_STATUS não é mudado em tela e sim na gravação
	//----------------------------------------------------------------------------------
	oView:lModify := .T.
	oView:oModel:lModify := .T.

EndIf

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} Af036CodBx

Encontra o Próximo código de baixa

@author Totvs

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function Af036CodBx()
Local aArea 		:= GetArea()
Local aAreaFN6 	:= FN6->(GetArea())
Local cCodBx		:= ""
FN6->(dbSetOrder(1))

If lIsRussia
	cCodBx	:= RU09D03Nmb("FAWOFF")
Else
	FN6->(dbSetOrder(1))

cCodBx := GETSXENUM("FN6","FN6_CODBX")

While FN6->(dbSeek(xFilial("FN6") + cCodBx ))
	ConfirmSX8()
	cCodBx := GETSXENUM("FN6","FN6_CODBX")
EndDo
EndIf

RestArea(aAreaFN6)
RestArea(aArea)
Return cCodBx
//-------------------------------------------------------------------
/*/{Protheus.doc} A036ULTCOD

Retorna o ultimo numero de baixa para o ativo

@author Totvs

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function A036ULTCOD(cBase,cItem,cTipo,cTipSal,cFilOri,cTabela,lArray,nSeq)
Local aArea		:= GetArea()
Local cTab		:= GetNextAlias()
Local cCodBx	:= ""
Local cFilFN6 := ""
Local xRet		:= {}
Local cQuery	:= ""

Default cFilOri	:= If(cTabela == "SN1",XFilial("SN1"),XFilial("SN3"))
Default cTabela := "SN3"
Default lArray  := .F.
Default nSeq    := ""

If cTabela == "SN3"
	cQuery += " SELECT  "
	cQuery += "    MAX(FN7_CODBX) CODBX  "
	cQuery += " FROM "+ RetSQLName("FN7")
	cQuery += " WHERE  "
	cQuery += "    FN7_CBASE  = '" + cBase   + "' AND "
	cQuery += "    FN7_CITEM  = '" + cItem   + "' AND "
	cQuery += "    FN7_TIPO   = '" + cTipo   + "' AND "
	cQuery += "    FN7_TPSALD = '" + cTipSal + "' AND "
	cQuery += "    FN7_FILORI = '" + cFilOri + "' AND "
	cQuery += "    FN7_SEQ 	  = '" + nSeq    + "' AND "
	cQuery += "    FN7_STATUS = '1' AND "
	cQuery += "    D_E_L_E_T_ = ' '  "
ElseIf cTabela == "SN1"
	cQuery += " SELECT  "
	cQuery += "    MAX(FN6_CODBX) CODBX  "
	cQuery += " FROM "+ RetSQLName("FN6")
	cQuery += " WHERE  "
	cQuery += "    FN6_CBASE  = '" + cBase   + "' AND "
	cQuery += "    FN6_CITEM  = '" + cItem   + "' AND "
	cQuery += "    FN6_FILORI = '" + cFilOri + "' AND "
	cQuery += "    FN6_STATUS = '1' AND "
	cQuery += "    D_E_L_E_T_ = ' '  "
EndIf

cQuery := ChangeQuery(cQuery)

DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.T.)

If (cTab)->(!EOF())
	cCodBx := (cTab)->CODBX
EndIf

(cTab)->(DBCloseArea())

If !Empty(cCodBx) .and. lArray
	cQuery := ""
	If cTabela == "SN3"
		cQuery += " SELECT  "
		cQuery += "    MAX(FN7_FILIAL) FILIAL  "
		cQuery += " FROM "+ RetSQLName("FN7")
		cQuery += " WHERE  "
		cQuery += "    FN7_CODBX  = '" + cCodBx   + "' AND "
		cQuery += "    FN7_CBASE  = '" + cBase   + "' AND "
		cQuery += "    FN7_CITEM  = '" + cItem   + "' AND "
		cQuery += "    FN7_TIPO   = '" + cTipo   + "' AND "
		cQuery += "    FN7_TPSALD = '" + cTipSal + "' AND "
		cQuery += "    FN7_FILORI = '" + cFilOri + "' AND "
		cQuery += "    FN7_SEQ 	  = '" + nSeq    + "' AND "
		cQuery += "    FN7_STATUS = '1' AND "
		cQuery += "    D_E_L_E_T_ = ' '  "
	ElseIf cTabela == "SN1"
		cQuery += " SELECT  "
		cQuery += "    MAX(FN6_FILIAL) FILIAL  "
		cQuery += " FROM "+ RetSQLName("FN6")
		cQuery += " WHERE  "
		cQuery += "    FN6_CODBX  = '" + cCodBx   + "' AND "
		cQuery += "    FN6_CBASE  = '" + cBase   + "' AND "
		cQuery += "    FN6_CITEM  = '" + cItem   + "' AND "
		cQuery += "    FN6_FILORI = '" + cFilOri + "' AND "
		cQuery += "    FN6_STATUS = '1' AND "
		cQuery += "    D_E_L_E_T_ = ' '  "
	EndIf
	cQuery := ChangeQuery(cQuery)
	
	DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.T.)
	
	If (cTab)->(!EOF())
		cFilFN6 := (cTab)->FILIAL
	EndIf
	
	(cTab)->(DBCloseArea())
	
EndIf

RestArea(aArea)

If lArray
	xRet := {cFilFN6,cCodBx}
Else
	xRet := cCodBx
EndIf


Return xRet


//-------------------------------------------------------------------
/*/{Protheus.doc}AF030PerAut
Carrega o valor das variaveis da rotina automatica
@author William Matos Gundim Junior
@since  13/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF036PerAt()
Local nX 		:= 0
Local cVarParam := ""

If Type("aParamAuto") != "U"
	For nX := 1 to Len(aParamAuto)
		cVarParam := Alltrim(Upper(aParamAuto[nX][1]))
		If "MV_PAR" $ cVarParam
			&(cVarParam) := aParamAuto[nX][2]
		EndIf
	Next nX
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}AF036VlrBx
Retorna os valores de baixa da tabela FN7
@author TOTVS
@since  13/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function AF036VlrBx(cBase,cItem,cTipo,dDtBaixa,cOcorr,cSeq,cSeqReav)
Local aArea		:= GetArea()
Local aAreaSN4	:= SN4->(GetArea())
Local aRet			:= {}
Local aMultMoeda	:= AtfMultMoe(,,{|x| 0})
Local aValBaixa	:= AClone(aMultMoeda)
Local aValDepr	:= AClone(aMultMoeda)
Local aValBx		:= AClone(aMultMoeda)
Local lAchou    := .F.

//-----------------
// Valor da Baixa
//-----------------
DbSelectArea("SN4")
SN4->(DbSetOrder(1)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ
cChaveSN4 := XFilial("SN4")+cBase+cItem+cTipo+DTOS(dDtBaixa)+"01"+cSeq
If SN4->(DbSeek(cChaveSN4))
	While SN4->(!Eof()) .And. cChaveSN4 = SN4->(N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ)
		If !(SN4->N4_SEQREAV = cSeqReav .And. SN4->N4_TIPOCNT = "1")
			SN4->(DbSkip())
			Loop
		Else
            lAchou := .T.
			Exit
		Endif
		SN4->(DbSkip())
	EndDo

	// *******************************
	// Controle de multiplas moedas  *
	// *******************************
	If lAchou
		aValBaixa := AtfMultMoe("SN4","N4_VLROC")
        lAchou := .F.
    EndIf
Endif

//---------------------------------------
// Obtem o valor da depreciação na baixa
//---------------------------------------
DbSelectArea("SN4")
SN4->(DbSetOrder(1)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ
cChaveSN4 := xFilial("SN4")+cBase+cItem+cTipo+DTOS(dDtBaixa)+cOcorr+cSeq
If SN4->(DbSeek(cChaveSN4))
	While SN4->(!Eof()) .And. cChaveSN4 = SN4->(N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ)
		If SN4->N4_SEQ != cSeq
			SN4->(DbSkip())
			Loop
		Else
            lAchou := .T.
			Exit
		Endif
		SN4->(DbSkip())
	EndDo
		
	// *******************************
	// Controle de multiplas moedas  *
	// *******************************
	If lAchou
		aValDepr := AtfMultMoe("SN4","N4_VLROC")
    EndIf
EndIf

//-------------------------------------------------
// Obtem o valor da depreciação acumulada na baixa
//-------------------------------------------------
DbSelectArea("SN4")
SN4->(DbSetOrder(1)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ
cChaveSN4 := xFilial("SN4")+cBase+cItem+cTipo+DTOS(dDtBaixa)+"01"+cSeq
If SN4->(DbSeek(cChaveSN4))
	While SN4->(!Eof()) .And. cChaveSN4 = SN4->(N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ)
		If !(SN4->N4_SEQREAV = cSeqReav .And. SN4->N4_TIPOCNT = IIF(lIsRussia,"3","4") )
			SN4->(DbSkip())
			Loop
		Else
            lAchou := .T.
			Exit
		Endif
		SN4->(DbSkip())
	EndDo
		
	// *******************************
	// Controle de multiplas moedas  *
	// *******************************
    If lAchou
		aValBx := AtfMultMoe("SN4","N4_VLROC")
    End
Endif

aRet := {aValBaixa,aValDepr,aValBx}

RestArea(aAreaSN4)
RestArea(aArea)

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc}AF036VQt
Valida se o ativo vai realiza a baixa de quantidade
@author TOTVS
@since  13/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF036VQt(oModelTipo)
Local lRet := .T.
Local nLin := oModelTipo:GetLine()
Local cTypes10	:= "" // CAZARINI - 14/03/2017 - If is Russia, add new valuations models - main models
Local aTypes10	:= {}
Local nTypes10	:= 0
If lIsRussia
	cTypes10 := AtfNValMod({1}, "|")
	aTypes10 := Separa(cTypes10, '|', .f.)
EndIf

lRet := oModelTipo:SeekLine({{"FN7_TIPO","01"}}) .OR. oModelTipo:SeekLine({{"FN7_TIPO","03"}}) .OR. (!oModelTipo:SeekLine({{"FN7_TIPO","01"}}) .AND. oModelTipo:SeekLine({{"FN7_TIPO","10"}}) ) .OR. (!oModelTipo:SeekLine({{"FN7_TIPO","03"}}) .AND. oModelTipo:SeekLine({{"FN7_TIPO","13"}}) )
If lIsRussia
	If !lRet
		For nTypes10 := 1 to len( aTypes10 )
			lRet :=	(!oModelTipo:SeekLine({{"FN7_TIPO","01"}}) .AND. oModelTipo:SeekLine({{"FN7_TIPO",aTypes10[nTypes10]}}) ) 
			If lRet
				Exit
			Endif
		Next nTypes10
	Endif
EndIf

oModelTipo:GoLine(nLin)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF036ValBx
Valida se permite a quantidade Zero para baixa
@author TOTVS
@since  13/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF036VLBX(oModelMaster,oModelTipo,oModelValor)
Local lRet 			:= .T.
Local nQtdBx		:= oModelMaster:GetValue('FN6_QTDBX')
Local nPBaixa		:= oModelMaster:GetValue('FN6_BAIXA')
Local nQtdAtu		:= oModelMaster:GetValue('FN6_QTDATU')
Local aSaveLines 	:= FWSaveRows()
Local nX			:= 0
Local nY			:= 0
Local nMarc			:= 0
Local nTotBx		:= 0


For nX := 1 to oModelTipo:Length()
	oModelTipo:GoLine(nX)
	If oModelTipo:GetValue("OK")
		nMarc++
		If oModelTipo:GetValue("FN7_TIPO") $ '01/03' .And. nQtdAtu != nQtdBx .And. nPBaixa == 100 .And. !FWIsInCallStack("AF012CVMet")
			lRet := .F.
			HELP(" ",1,"AF036QTD1",,STR0133,1,0)//"Para realizar a baixa de 100% dos tipos de ativo 01 ou 03, a quantidade de baixa deve ser igual a quantidade do ativo."
		EndIf
	EndIf
	If !lRet
		Exit
	EndIf
Next nX

If lRet .And. nMarc == oModelTipo:Length() .And. nPBaixa == 100 .And. nQtdAtu != nQtdBx .And. !FWIsInCallStack("AF012CVMet")
	lRet := .F.
	HELP(" ",1,"AF036QTD2",,STR0134,1,0)//"Para realizar a baixa de 100% de todo o ativo, a quantidade de baixa deve ser igual a quantidade do ativo."
EndIf

If lRet .And. nQtdAtu == nQtdBx .And. nPBaixa != 100  .And. !FWIsInCallStack("AF012CVMet")
	lRet := .F.
	HELP(" ",1,"AF036QTD3",,STR0137,1,0)//"A quantidade de baixa é igual a quantidade atual da ficha, portanto o percentual de baixa deve ser igual a 100%"
EndIf

If lRet
	For nX := 1 to oModelTipo:Length()
		
		oModelTipo:GoLine(nX)
		
		If oModelTipo:GetValue("OK")
			
			nTotBx := 0
			
			For nY := 1 to oModelValor:Length()
				oModelValor:GoLine(nY)
				nTotBx += oModelValor:GetValue("FN7_VLBAIX")
			Next nY
			
			If Empty(nTotBx)
				lRet := .F.
				HELP(" ",1,"AF036QTD4",,STR0138,1,0)//"Preencher valor de baixa do ativo."
			EndIf
		EndIf
		
		If !lRet
			Exit
		EndIf
	Next nX
	
EndIf

FWRestRows(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A036SN1TBx 
Verifica se o bem foi totalmente baixado.
@author TOTVS
@since  13/11/2015
@version 12
/*/
//-------------------------------------------------------------------
Function A036SN1TBx()
Local aSaveArea	:= GetArea()
Local cAliasQry	:= GetNextAlias()
Local lRet			:= .T.

BeginSql Alias cAliasQry
	SELECT R_E_C_N_O_ RECNOSN3
	FROM %table:SN3% SN3
	WHERE SN3.N3_FILIAL		= %exp:SN1->N1_FILIAL%
			AND SN3.N3_CBASE	= %exp:SN1->N1_CBASE%
			AND SN3.N3_ITEM	= %exp:SN1->N1_ITEM%
			AND SN3.N3_BAIXA	= '0'
			AND SN3.%NotDel%
EndSQL

If (cAliasQry)->(!Eof())
	lRet := .F.
EndIf

(cAliasQry)->(DbCloseArea())

RestArea(aSaveArea)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} AF036CaFN8
Verifica se todos as baixa de um lote foram canceladas e cancela o lote.

@author TOTVS
@since  11/12/2015
@version 12
/*/
//-------------------------------------------------------------------
Function AF036CaFN8(cFilFN6,cLote)
Local aArea			:= GetArea()
Local aAreaFN8		:= FN8->(GetArea())
Local cNextAlias	:= GetNextAlias()
Local cQuery		:= ''
Local nAtivo := 0

cQuery += " SELECT COUNT(FN6_CODBX) CONT "
cQuery += " FROM "+ RetSQLTab("FN6")
cQuery += " WHERE  "
cQuery += " FN6_FILIAL = '"+cFilFN6+"' AND "
cQuery += " FN6_LOTE = '"+cLote+"' AND "
cQuery += " FN6_STATUS = '1' AND "
cQuery += " FN6.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)  

nAtivo := (cNextAlias)->CONT

If Empty(nAtivo)
	FN8->(dbSetOrder(1))
	If FN8->(dbSeek(cFilFN6+cLote))
		FN8->(RecLock("FN8",.F.))
		FN8->FN8_STATUS := '2'
		FN8->(MsUnLock())	
	EndIf
EndIf


(cNextAlias)->(dbCloseArea())
RestArea(aArea)
RestArea(aAreaFN8)

Return

/*/{Protheus.doc}AF036CaOut

Cancela a baixa de outros ativos quando gerada nota com mais de um ativo

@author TOTVS
@since  22/12/2016
@version 12
/*/
Function AF036CaOut(aItensNF)
Local aAreaFN6		:= FN6->(GetArea())
Local aAreaFN7		:= FN7->(GetArea())
Local oModel036M	:= FWLoadModel("ATFA036M")
Local oModelFN7		:= oModel036M:GetModel("FN7TIPO")
Local oModelPar		:= oModel036M:GetModel("PARAMETROS")
Local lRet			:= .T.
Local cLog			:= ""
Local nX			:= 0

oModel036M:SetOperation(MODEL_OPERATION_UPDATE)
oModel036M:Activate()

//------------------------------------
// Tratamento para campos obrigatorio
//------------------------------------
oModelPar:SetValue("DATADE"	,dDataBase	,.T.)
oModelPar:SetValue("DATAATE",dDataBase	,.T.)

oModelFN7:SetNoInsertLine(.F.)

For nX := 1 To Len(aItensNF)

	FN6->(DBGoTo(aItensNF[nX]))

	FN7->(DBSetOrder(1)) //FN7_FILIAL+FN7_CODBX+FN7_ITEM
	If FN7->(DBSeek(XFilial("FN7")+FN6->FN6_CODBX))

		While FN7->(!Eof()) .And. FN7->FN7_CODBX == FN6->FN6_CODBX

			If FN7->FN7_MOEDA == "01"

				nLine := oModelFN7:AddLine()

				If !EMPTY( FN6->FN6_LOTE )
					oModelFN7:SetValue("LOTE", FN6->FN6_LOTE, .T.)
				EndIf

				oModelFN7:SetValue("OK"			,.T.				,.T.)
				oModelFN7:SetValue("FN7_FILIAL"	,FN7->FN7_FILIAL	,.T.)	// FN7_FILIAL
				oModelFN7:SetValue("FN7_CODBX"	,FN7->FN7_CODBX		,.T.)	// FN7_CODBX
				oModelFN7:SetValue("FN7_ITEM"	,FN7->FN7_ITEM		,.T.)	// FN7_ITEM
				oModelFN7:SetValue("FN7_CBASE"	,FN7->FN7_CBASE		,.T.)	// FN7_CBASE
				oModelFN7:SetValue("FN7_CITEM"	,FN7->FN7_CITEM		,.T.)	// FN7_CITEM
				oModelFN7:SetValue("FN7_TIPO"	,FN7->FN7_TIPO		,.T.) 	// FN7_TIPO
				oModelFN7:SetValue("FN7_TPSALD"	,FN7->FN7_TPSALD	,.T.)	// FN7_TPSALD
				oModelFN7:SetValue("FN7_SEQ"	,FN7->FN7_SEQ		,.T.)	// FN7_SEQ
				oModelFN7:SetValue("FN7_SEQREA"	,FN7->FN7_SEQREA	,.T.)	// FN7_SEQREA
				oModelFN7:SetValue("FN7_MOTIVO"	,FN7->FN7_MOTIVO	,.T.)	// FN7_MOTIVO
				oModelFN7:SetValue("FN7_DTBAIX"	,FN7->FN7_DTBAIX	,.T.)	// FN7_DTBAIX
				oModelFN7:SetValue("FN7_VLATU"	,FN7->FN7_VLATU		,.T.)	// FN7_VLATU
				oModelFN7:SetValue("FN7_VLDEPR"	,FN7->FN7_VLDEPR	,.T.)	// FN7_VLDEPR
				oModelFN7:SetValue("FN7_VLBAIX"	,FN7->FN7_VLBAIX	,.T.)	// FN7_VLBAIX
				oModelFN7:SetValue("FN7_PERCBX"	,FN7->FN7_PERCBX	,.T.)	// FN7_PERCBX
				oModelFN7:SetValue("FN7_STATUS"	,FN7->FN7_STATUS	,.T.)	// FN7_STATUS
				oModelFN7:SetValue("FN7_FILORI"	,FN7->FN7_FILORI	,.T.)	// FN7_FILORI
				oModelFN7:SetValue("FN7_MOEDA"	,FN7->FN7_MOEDA		,.T.)	// FN7_MOEDA
				oModelFN7:SetValue("FN7_VLRESI"	,FN7->FN7_VLRESI	,.T.)	// FN7_VLRESI

			EndIf

		FN7->(DbSkip())
		EndDo

	EndIf

Next nX

oModelFN7:SetNoInsertLine(.T.)
oModelFN7:SetLine(1)

If oModel036M:VldData()
	oModel036M:CommitData()
Else
	lRet := .F.
	cLog := cValToChar(oModel036M:GetErrorMessage()[4]) + ' - '
	cLog += cValToChar(oModel036M:GetErrorMessage()[5]) + ' - '
	cLog += cValToChar(oModel036M:GetErrorMessage()[6])

	Help( ,,"AF036Canc",,cLog, 1, 0 )

EndIf

oModel036M:DeActivate()
oModel036M:Destroy()
oModel036M:Nil

RestArea(aAreaFN7)
RestArea(aAreaFN6)

Return lRet

/*/{Protheus.doc}AF036ItnNF

Confere se ha mais de um ativo por NF (mesmo codigo base, item diferente)

@author TOTVS
@since  22/12/2016
@version 12
/*/
Function AF036ItnNF(cFilOri,cNumNF,cNumItem)
Local aItensNF	:= {}
Local cAliasQry	:= GetNextAlias()

BeginSQL Alias cAliasQry
SELECT R_E_C_N_O_
FROM %Table:FN6%
WHERE	FN6_FILORI	= %Exp:cFilOri%		AND
		FN6_NUMNF	= %Exp:cNumNF%		AND
		FN6_SERIE	= %Exp:cNumItem%	AND
		FN6_GERANF	= '1'				AND
		FN6_STATUS	= '1'				AND
		%NotDel%
EndSQL

While (cAliasQry)->(!Eof())

	AAdd(aItensNF,(cAliasQry)->R_E_C_N_O_)

(cAliasQry)->(DBSkip())
EndDo

(cAliasQry)->(DbCloseArea())

Return aItensNF


//-------------------------------------------------------------------
/*/{Protheus.doc} AF36Can030

Executa o cancelamento de uma baixa realizada pela rotina ATFA030 

@author EDUARDO.FLIMA
@since 11/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF36Can030()
Local lAuxAuto :=.F.
Local lAuxHelp := .F.
Local lAuxMSHel:=.f. 
Local lSetAuto := .F.
Local lSetHelp := .F.
Local lRet :=.F.
Local cRot := AF36Is030(xFilial(), SN3->N3_CBASE, SN3->N3_ITEM, SN3->N3_TIPO, SN3->N3_DTBAIXA, SN3->N3_SEQ, .F.)


//If !empty(cRot)
//	Guardo os valores referente a HELP
	lAuxAuto :=lSetAuto
	lAuxHelp := lSetHelp
// Forço a exibição de help na rotina automática 	
	lSetAuto := _SetAutoMode(.F.)
	lSetHelp := HelpInDark(.F.)
	If Type('lMSHelpAuto') == 'L'
		lAuxMSHel:=lMSHelpAuto
		lMSHelpAuto := !lMSHelpAuto
	EndIf
	//Preencho dados para ExecAuto de cancelamento de Baixa  							
	aDadosAuto:= {	{'N3_CBASE'   , SN3->N3_CBASE	, Nil},;	// Codigo base do ativo Selecionado
	{'N3_ITEM'    , SN3->N3_ITEM			, Nil},;	// Item do Ativo Selecionado
	{'N3_TIPO'    , SN3->N3_TIPO			, Nil},;	// Tipo do ativo Selecionado
	{'N3_BAIXA'    , SN3->N3_BAIXA			, Nil},;	// Data da baixa do ativo Selecionado 
	{'N3_SEQ'    , SN3->N3_SEQ		, Nil}}	// sequencia de movimentação do ativo Selecionado
	If cRot =="ATFA030"
		//Executo o cancelamento diretamente no ATFA030 caso a baixa ocorra com sucesso sera apresentado um HELP informando que
		// o mesmo foi cancelado pelo processo do  ATFA030 							
		lRet:= MSExecAuto({|x, y, z| AtfA030(x, y, z)},aDadosAuto, 5)
	Elseif cRot =="ATFA035"
		//Executo o cancelamento diretamente no ATFA030 caso a baixa ocorra com sucesso sera apresentado um HELP informando que
		// o mesmo foi cancelado pelo processo do  ATFA030 							
		lRet:= MSExecAuto({|x, y, z| AtfA035(x, y, z)},aDadosAuto, 5)
	Elseif Empty(cRot)
		lRet:= MSExecAuto({|x, y, z| AtfA030(x, y, z)},aDadosAuto, 5)
	Endif 
//	restaura os valores de Help
	lSetAuto := lAuxAuto
	lSetHelp := lAuxHelp
	If Type('lMSHelpAuto') == 'L'
		lMSHelpAuto := lAuxMSHel
	EndIf						
//Endif 
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} AF36Can030

Verifica se é uma baixa realizada pela rotina ATFA030		   

@author EDUARDO.FLIMA
@since 13/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF36Is030(cFilN3, cBase, cItem, cTipo, dDataBx, cSeq, lVisual)
Local cSeekSN4 	:=""
Local 	  cRet  	:=""
Default  cFilN3	:=""
Default  cBase  	:=""
Default  cItem  	:=""
Default  cTipo  	:=""
Default  dDataBx	:=""
Default  cSeq   	:=""
Default  lVisual  :=.F.

cSeekSN4 := cFilN3+cBase+cItem+cTipo+DTOS(dDataBx)+"01"+cSeq
SN4->(dbSetOrder(1)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se é uma baixa realizada pela rotina ATFA030		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (SN4->(dbSeek(cSeekSN4))) .and. (alltrim(SN4->N4_ORIGEM)= "ATFA030" .or. alltrim(SN4->N4_ORIGEM)= "ATFA035" .or. Empty(SN4->N4_ORIGEM) ) //Verifica se é uma baixa realizada pela rotina ATFA030
	If lVisual
		AxVisual("SN3",SN3->( RECNO() ),2,)	
	Endif 
	cRet:= alltrim(SN4->N4_ORIGEM)
Endif 	
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ATF036Oper

Função permite alterar nOper para execução automática 

@author William.bezerra
@since 24/10/2017
@version 1.0


/*/
//-------------------------------------------------------------------
Function ATF036Oper(nOper)

__nOper := nOper

Return



//-----------------------------------------------------------------------
/*/{Protheus.doc} RusCheckRevalFunctions()

Check for Russian revaluation functions

@param		None
@return		None
@author 	victor.rezende
@since 		18/09/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function RusCheckRevalFunctions()
Return lIsRussia .And. IsInCallStack("RU01T04COM")

//-------------------------------------------------------------------
/*/{Protheus.doc} ATF036Reset

Função para reiniciar as estataticas na execução automatica

@author eveline.silva
@since 14/11/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function ATF036Reset()

__nOper    := 0 // Operacao da rotina
lCalcula    := Nil
nParCorrec  := 0
aRecCtb           := {}
lBxProvis   := .F.
lValidaNFD  := SuperGetMV("MV_AF30NDV", .F., .F.)
__oModelAut := Nil
__lRotAuto  := .F.
lIsRussia   := cPaisLoc == "RUS"
lVisMotBx   := .F.
lAtf030 	:= .F.

Return
/*/{Protheus.doc} A36RetEnt

Retorna a entidades contabeis para gravar na NF de saída

@author TOTVS
@since 20/10/2019
@version 1.0
/*/
Static Function A36RetEnt(cBase,cItem)
Local aAreasn3 := SN3->(GetArea())
Local aRetEnt  := {"","","",""}

DEFAULT cBase := ""
DEFAULT cItem := ""

SN3->(dbSetOrder(1))
If SN3->(dbSeek(xFilial("SN3")+cBase+cItem+"01")) //Sempre pego do tipo 01 (Mesma regra da transferência - Definida pelo P.O.)
	aRetEnt[1] := AllTrim(SN3->N3_CCONTAB) 
	aRetEnt[2] := AllTrim(SN3->N3_CUSTBEM) 
	aRetEnt[3] := AllTrim(SN3->N3_SUBCCON) 
	aRetEnt[4] := AllTrim(SN3->N3_CLVLCON) 
EndIf
RestArea(aAreaSN3)

Return aRetEnt
/*/{Protheus.doc} A036GrvNF

Grava NF de saída 

@author TOTVS
@since 20/01/2020
@version 1.0
/*/
Function A036GrvNF(cSerie, cCliente, cLoja , cCondPag, cProduto,nQuant ,nValNF,cTESSaida,dBaixa,aNotas,cNatureza)
Local nX
Local nNotas
Local nItens
Local aPvlNfs  := {}
Local aBloqueio:= {}
Local aCabec   := {}
Local aItens   := {}	
Local aParam460:= Array(30)
Local aGerNF   := {}
Local lRet     := .T.

Private lMsErroAuto := .F.

Default cSerie 	 := ""
Default cCliente := ""
Default cLoja 	 := ""
Default cCondPag := ""
Default cProduto := ""
Default nQuant   := 0
Default nValNF   := 0
Default cTESSaida:= ""
Default dBaixa   := StoD("")
Default aNotas   := {}
Default cNatureza:= ""
	
SaveInter()

If Empty(cNatureza)
	SA1->(dbSetOrder(1))
	If SA1->(MsSeek(xFilial("SA1")+cCliente+cLoja))
		cNatureza := SA1->A1_NATUREZ
	EndIf
EndIf

Pergunte("MT460A",.F.)

For nx := 1 to 30
	aParam460[nx] := &("mv_par" + StrZero(nx, 2) )
Next nx

For nNotas := 1 To Len(aNotas)

	cBaseNF		:= aNotas[nNotas][1]

	aCabec := {}	
	aAdd( aCabec, { "C5_TIPO"	 , "N"			 , Nil } )
	aAdd( aCabec, { "C5_DOCGER " , "1"			 , Nil } )
	aAdd( aCabec, { "C5_CLIENTE" , cCliente		 , Nil } )
	aAdd( aCabec, { "C5_LOJACLI" , cLoja		 , Nil } )
	aAdd( aCabec, { "C5_CONDPAG" , cCondPag		 , Nil } )
	aAdd( aCabec, { "C5_NATUREZ" , cNatureza     , Nil } )	

	aItens	:= {}
	
	For nItens := 1 To Len(aNotas[nNotas,7])
		cItemNF		:= aNotas[nNotas][7][nItens][1]
		cProduto	:= aNotas[nNotas][7][nItens][2]
		nQtdBx		:= aNotas[nNotas][7][nItens][3]
		nValNF		:= aNotas[nNotas][7][nItens][4]
		cTESSaida	:= aNotas[nNotas][7][nItens][5]

		aEntCtb := A36RetEnt(cBaseNF,cItemNF)

		aTmp := {}
		aAdd(aTmp, { "C6_ITEM",		StrZero(nItens,2),Nil })
		aAdd(aTmp, { "C6_PRODUTO",	cProduto,		Nil })
		aAdd(aTmp, { "C6_QTDVEN", 	nQtdBx,			Nil })
		aAdd(aTmp, { "C6_PRCVEN", 	nValNF/nQtdBx,	Nil })
		aAdd(aTmp, { "C6_VALOR", 	nValNF, 		Nil })
		aAdd(aTmp, { "C6_TES",		cTESSaida,		Nil })
		aAdd(aTmp, { "C6_CONTA",	aEntCtb[1],		Nil })
		aAdd(aTmp, { "C6_CC",		aEntCtb[2],		Nil })		
		aAdd(aTmp, { "C6_ITEMCTA",	aEntCtb[3],		Nil })
		aAdd(aTmp, { "C6_CLVL",		aEntCtb[4],		Nil })
		aAdd(aItens, aTmp)
	Next nItens

	lMsErroAuto := .F.	
	MSExecAuto( { |x,y,z| MATA410(x,y,z) }, aCabec, aItens, 3 )
	
	If lMsErroAuto
		If !IsBlind()
			MostraErro()		
		EndIf
		lRet := .F.
	Else		
		aPvlNfs := {}
		aBloqueio := {}
		// Liberacao de pedido
		Ma410LbNfs( 2, @aPvlNfs, @aBloqueio )
		
		// Checa itens liberados
		Ma410LbNfs( 1, @aPvlNfs, @aBloqueio )
		
		// Caso tenha itens liberados manda faturar	
		If Empty(aBloqueio) .And. !Empty(aPvlNfs)
			nItemNf  := a460NumIt(cSerie)
			aGerNF := {}
			aadd(aGerNF,{})

			// Efetua as quebras de acordo com o numero de itens
			For nX := 1 To Len(aPvlNfs)
				If Len(aGerNF[Len(aGerNF)])>=nItemNf
					aadd(aGerNF,{})
				EndIf
				aadd(aGerNF[Len(aGerNF)],aClone(aPvlNfs[nX]))
			Next nX
			
			For nX := 1 To Len(aGerNF)
				aNotas[nNotas,2] := MaPvlNfs(aGerNF[nX],cSerie,.F. ,.F. ,.T. ,aParam460[04]==1,aParam460[05]==1,aParam460[07],aParam460[08],aParam460[16]==1,aParam460[16]==2)	
			Next nX			
		ElseIf !Empty(aBloqueio)
			//Aviso("Atenção","Não foi possível liberar o pedido de venda."+CRLF+"Verifique a existência de bloqueio de crédito e/ou estoque.",{"Ok"})	
			//STR0149
			Help("",1,"AF036BRASONOINVOICE",,STR0166 + CRLF + STR0167,1,0)
			lRet := .F.
		EndIf

	EndIf	
Next nNotas

RestInter()

Return lRet

/*/{Protheus.doc} A036FN6NF

Função de verificação de NF com vinculo no Ativo Fixo.

@author TOTVS
@since 29/07/2020
@version 1.0
/*/
Function A036FN6NF(cFilFN,cFilNF, cDoc, cSerie) 
Local lRet := .T.
Local cQuery := ""
Local cAreac := ""
Local cAliasTMPc := ""
Default cFilFN := ""
Default cFilNF := ""
Default cDoc := ""
Default cSerie := ""

If Empty(cFilNF) .and. Empty(cDoc) .and. Empty(cSerie)
    lRet:= .T.
EndIf

If !Empty(cFilNF) .And. FWModeAccess("FN6") == "C"
	cAliasTMPc := GetNextALias()
	cQuery := " SELECT COUNT(FN6_FILIAL) QTD FROM " + RetSQLName("FN6")+" FN6 "+;
					"WHERE FN6_FILIAL = '"+cFilFN+"' AND "+;
						"FN6_NUMNF= '"+cDoc+"' AND "+;
						"FN6_SERIE= '"+cSerie+"' AND "+;
						"FN6_FILORI = '"+cFilNF +"' AND "+;
						"FN6.D_E_L_E_T_ = ' ' "
	cAreac := Alias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasTMPc , .T. , .T.)
	If (cAliasTMPc)->QTD > 0 
		If !(cPaisLoc $ "MEX|PER|COL")
			lRet := .F.
			Help(" ",1, "AF036NF",,STR0168,1,0) //"Nota atrelada a baixa do Ativo."
		Else 
			lRet := .T.
			Help(" ",1, "AF036NF",,STR0169,1,0) //"Al finalizar el borrado, tendrá que realizar la Anulación de la Baja del Activo manualmente, en la rutina Bajas (ATFA036)."
		EndIF
	Endif
	(cAliasTMPc)->(DBCloseArea())
	dbSelectArea(cAreac)
ElseIf FWModeAccess("FN6") == "E"
	FN6->(DBSetOrder(5))
	If FN6->(DBSeek(cFilFN+SF2->F2_DOC+SF2->F2_SERIE))
		IF cPaisLoc $ "MEX|PER|COL"
			lRet := .T.
			Help(" ",1, "AF036NF",,STR0169,1,0) //"Al finalizar el borrado, tendrá que realizar la Anulación de la Baja del Activo manualmente, en la rutina Bajas (ATFA036)."
		Else
			lRet := .F.
			Help(" ",1, "AF036NF",,STR0168,1,0) //"Nota atrelada a baixa do Ativo."
		EndIf
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} A36ROBOLOTE
	Casos de teste do robo para baixa em lote
	@author Totvs
	@since 18/05/2021
	/*/
Function A36ROBOLOTE() 

	lAtf030 := .T.

Return

/*/{Protheus.doc} A036CalParc
    Calcula o nro de parcelas restantes (F9_SLDPARC) para apuração de ICMS (SIGAFIS)
	Em caso de cancelamento da baixa, verificar se existem existem parcelas remanescentes
	e atualizar o campo acima. F9_SLDPARC = F9_QDTPARC - (RESULTADO DA QUERY)
	@author 
	@since
/*/
Static Function A036CalParc(cCodSfa, dData )
Local nParcelas as numeric 
Local cQuery    as character
Local cAliasSFA as character

nParcelas  := 0
cQuery     := ""
cAliasSFA  := SFA->(GetNextAlias())

Default cCodSfa := SF9->(F9_CODIGO)
Default dData   := Ctod("  /  /  ")

/*/ FA_FILIAL, FA_CODIGO, FA_DATA, FA_TIPO, FA_MOTIVO, R_E_C_D_E_L_ /*/
cQuery := " SELECT COUNT(FA_TIPO) NPARCELASAPUR "
cQuery += "   FROM  " + RetSqlName("SFA") 
cQuery += "  WHERE FA_FILIAL  = '"+xFilial("SFA")+"' "
cQuery += "    AND FA_CODIGO  = '"+cCodSFA+"' "
cQuery += "    AND FA_TIPO    = '1' "                    // TIPO ='1'- indicação de movimentos de Apuração de Icms (SIGAFIS)
cQuery += "    AND FA_DATA    <= '"+Dtos(dData)+"' "
cQuery += "    AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSFA, .T. ,.F.)
TcSetField(cAliasSFA,"NPARCELASAPUR","N",17, 0)

If (cAliasSFA)->(NPARCELASAPUR) > 0 
	nParcelas := SF9->F9_QTDPARC - (cAliasSFA)->(NPARCELASAPUR)
	nParcelas := IIf(nParcelas < 0 , 0, nParcelas )
EndIf
(cAliasSFA)->(dbCloseArea())

Return(nParcelas)

/*/{Protheus.doc} A36AtVrdMes
    Atualiza o array ultdepr com os valores da ultima depreciação para atualização dos campos
	N3_VRDMES para todas as moedas
	deve ser chamada com a Tabela SN3 posicionada e com a data do mv_ultdepr correto de acordo com a filial
	@author TOTVS
	@since 10/06/2022
/*/
Static Function A36AtVrdMes(aUltDepr,cOcorr,dUltDepr)
	Local aArea	:= GetArea()
		
	DBSelectArea("SN4")
	SN4->(dbSetOrder(1)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ  
	IF SN4->(MsSeek(SN3->N3_FILIAL+ SN3->N3_CBASE + SN3->N3_ITEM + SN3->N3_TIPO + Dtos(dUltDepr) +cOcorr ))
		aUltDepr := AtfMultMoe("SN4","N4_VLROC")
	END
	RestArea(aArea)
	aSize(aArea,0)
	aArea := nil 

Return

/*
Funcao para verificar quando o CNPJ for igual no cliente/fornecedor utiliza a inscrição estadual para diferenciacao.
*/
Static Function AF36CNPJCLI(cCNPJ,cInscEstad)

Local aArea	:=	getarea()
Local aCliente	:= {}

Default cInscEstad := ""
SA1->(DbSetOrder(3))


If SA1->(MsSeek(xFilial("SA1") +cCNPJ))

	While SA1->(!EOF()) .And. cCNPJ == SA1->A1_CGC
		If AllTrim(SA1->A1_INSCR) == AllTrim(cInscEstad)
			aADD(aCliente,SA1->A1_COD)
			aADD(aCliente,SA1->A1_LOJA)
			Exit
		Endif
		SA1->(Dbskip())
		Loop
	ENDDO

Endif

RestArea(aArea)

Return (aCliente)

