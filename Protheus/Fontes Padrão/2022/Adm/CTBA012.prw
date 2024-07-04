#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include "ctba012.ch"

Static __lEAIC010 := FWHasEAI("CTBA010",.T.,,.T.)

//--------------------------------------------------------------------
/*/{Protheus.doc}CTBA012
Bloqueio de Movimentação pelo calendário contábil
@author Mayara Alves
@since  16/03/2015

@param cAlias Alias da tabela
@param nReg	Numero do registro
@param nOpc	Numero da operação

@version 12
/*/
//--------------------------------------------------------------------
Function CTBA012(cAlias,nReg,nOpc)

Local aArea   := GetArea()
Local cQry    := ''
Local cAlsCTE := GetNextAlias()
Private lopc   := .F.

Default cAlias 	:= ""
Default nReg		:= 0
Default nOpc		:= 0

cQry := "SELECT CTE_MOEDA FROM" + RetSqlName("CTE") + " CTE " + CRLF
cQry += "WHERE CTE_FILIAL = '" + FWXFilial("CTE") + "' "+CRLF
cQry += "AND CTE_CALEND = '" + CTG->CTG_CALEND  + "' "+CRLF
cQry += "AND CTE.D_E_L_E_T_ = ''" + CRLF
cQry := ChangeQuery( cQry )
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQry) , cAlsCTE , .T. , .F.)

If (cAlsCTE)->(!Eof())
	If nOpc == 6 //"Bloqueio de Processo"
		lopc := .T.
		CT012LOAD() // Carga inicial na tabela CQD.
		FWExecView(STR0001,'CTBA012', MODEL_OPERATION_UPDATE,, { || .T. }) // 'Alteração - Bloqueio de Processo'
	ElseIf nOpc == 7 //"Visualizar Bloqueio"
		FWExecView(STR0002,'CTBA012', MODEL_OPERATION_VIEW,, { || .T. }) //'Visualização - Bloqueio de Processo'
	EndIf
Else
	Help( ,, 'CTBA012',, STR0003, 1, 0)//'Calendario não vinculado a uma moeda'
EndIf

(cAlsCTE)->(DbCloseArea())

RestArea(aArea)

Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0028 Action 'VIEWDEF.CTBA012' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0029 Action 'VIEWDEF.CTBA012' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0030 Action 'VIEWDEF.CTBA012' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0031 Action 'VIEWDEF.CTBA012' OPERATION 5 ACCESS 0 //'Excluir'

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()

// Cria a estru tura a ser usada no Modelo de Dados
Local oStruCAB   := FWFormStruct( 1, 'CTG', {|x| Alltrim(x) == "CTG_FILIAL"},/*lViewUsado*/ )
Local oStruCTG   := FWFormStruct( 1, 'CTG', ,/*lViewUsado*/ )
Local oStruCQD   := FWFormStruct( 1, 'CQD', /*bAvalCampo*/, /*lViewUsado*/ )
Local lInclui    := If(Type("INCLUI") = "L", INCLUI, .F.)
Local cCalendCTB := CTG->CTG_CALEND
Local cExerc     := CTG->CTG_EXERC
Local oModel, bCommit, bInTTS, bIntegEAI

// Campo virtual para o field
oStruCAB:AddField(STR0004, STR0004, 'CTG_CODCAL', 'C', 3, 0, Nil, NIL, NIL, NIL, NIL, Nil, Nil, .T.)  //"Código"
oStruCAB:AddField(STR0005, STR0005, 'CTG_EXCONT', 'C', 4, 0, Nil, NIL, NIL, NIL, NIL, Nil, Nil, .T.)  //"Exercício Contábil"

// oStruCTG:AddField(STR0014, STR0014 , "FJB_DESC" , "C", 20, 0,,,,, {|| F242SitCab(FJB->FJB_STATUS)},,, .T.) //Status
oStruCTG:AddField("", "", "CTG_LEGEND", "C", 15, 0,,,,, {|| C012CTGLEG(CTG->CTG_CALEND, CTG->CTG_EXERC, CTG->CTG_PERIOD, "", .F.)},,, .T.)
oStruCQD:AddField("", "", "CQD_LEGEND", "C", 15, 0,,,,, {|| C012CQDLEG(CQD->CQD_STATUS, CQD->CQD_CALEND, CQD->CQD_EXERC, CQD->CQD_PERIOD, CQD->CQD_PROC)},,, .T.)

// Commit de dados.
If __lEAIC010
	bCommit   := {|oModel| FWFormCommit(oModel, /* bBefore, /* bAfter */, /* bAfterSTTS */, bInTTS, /* bABeforeTTS */, bIntegEAI)}
	bInTTS    := {|oModel| lRet := .T., lRet}
	bIntegEAI := {|oModel| MsgRun("Exportando EAI",, {|| lRet := CTBA010EAI(cCalendCTB, cExerc, .F.)}), lRet}
Endif

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'CTBA012',/*bPreValidacao*/, {|oModel| Ctb012Vlid()}/*bPosValidacao*/, bCommit, /*bCancel*/ )

// Gatilho
oStruCQD:AddTrigger( "CQD_STATUS" , "CQD_STATUS", {|| .T. }, {|| Ctb012Trig() } )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CTGMASTER', /*cOwner*/, oStruCAB )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'CTGDETAIL', 'CTGMASTER', oStruCTG, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CQDDETAIL', 'CTGDETAIL', oStruCQD, /*bLinePre*/, {|| Ctb012Pos()}/* bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CTGDETAIL', { { 'CTG_FILIAL', 'xFilial( "CTG" )' },{ 'CTG_CALEND', 'CTG_CODCAL' } ,{ 'CTG_EXERC', 'CTG_EXCONT' }   }, CTG->( IndexKey( 1 ) ) )
oModel:SetRelation( 'CQDDETAIL', { { 'CQD_FILIAL', 'xFilial( "CQD" )' },{ 'CQD_CALEND', 'CTG_CALEND' } ,{ 'CQD_EXERC', 'CTG_EXERC' } ,{ 'CQD_PERIOD', 'CTG_PERIOD' }  }, CQD->( IndexKey( 1 ) ) )

oModel:SetPrimaryKey({'xFilial("CTG")','CTG_CALEND','CTG_EXERC','CTG_PERIOD'})

//Inicializador padrão
oStruCAB:SetProperty('CTG_CODCAL'  ,MODEL_FIELD_INIT ,{|| IIF(!lInclui, CTG->CTG_CALEND, "")} )
oStruCAB:SetProperty('CTG_EXCONT'  ,MODEL_FIELD_INIT ,{|| IIF(!lInclui, CTG->CTG_EXERC,  "")} )

oStruCQD:SetProperty('CQD_STATUS'  ,MODEL_FIELD_VALID,{|| VldLinCQD()	} )

//Altera o When dos campos
oStruCAB:SetProperty( '*', MODEL_FIELD_WHEN, {|| .F.})

oStruCTG:SetProperty( '*', MODEL_FIELD_WHEN, {|| .F.})

oStruCQD:SetProperty( 'CQD_ITEM', MODEL_FIELD_WHEN, {|| .F.})
oStruCQD:SetProperty( 'CQD_PROC', MODEL_FIELD_WHEN, {|| .F.})
oStruCQD:SetProperty( 'CQD_DESC', MODEL_FIELD_WHEN, {|| .F.})

oStruCTG:SetProperty( 'CTG_LEGEND', MODEL_FIELD_WHEN, {|| .T.})

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0006 ) //'Bloqueio de Processo'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CTGMASTER' ):SetDescription( STR0007)//'Calendário Contábil'
oModel:GetModel( 'CTGDETAIL' ):SetDescription( STR0008)//'Períodos Contábeis'
oModel:GetModel( 'CQDDETAIL' ):SetDescription( STR0009)//'Processos'

// Não permite inserir linhas na grid
oModel:GetModel( 'CTGDETAIL' ):SetNoInsertLine( .T. )
oModel:GetModel( 'CQDDETAIL' ):SetNoInsertLine( .T. )

// Não permite apagar as linhas da grid
oModel:GetModel( 'CTGDETAIL' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'CQDDETAIL' ):SetNoDeleteLine( .T. )

// FWModelEvent - Integração com SIGAPFS
If FindFunction("JurEvent") .And. JurEvent("CTBA012EVPFS")
	oModel:InstallEvent("CTBA012EVPFS",, CTBA012EVPFS():New())
EndIf

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()

Local oStruCAB := FWFormStruct( 2, 'CTG',{|x| Alltrim(x) == "CTG_FILIAL"} )
Local oStruCTG := FWFormStruct( 2, 'CTG' )
Local oStruCQD := FWFormStruct( 2, 'CQD' )
// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'CTBA012' )
Local oView
Local lInclui  := If(Type("INCLUI") = "L", INCLUI, .F.)

CTB12IniCTG()

// Cria o objeto de View
oView := FWFormView():New()

//Insere campos na struct da view
//		  AddField( cIdField, cOrdem,	 cTitulo, 	cDescric, 			aHelp, cType, cPicture,	bPictVar, cLookUp, lCanChange, cFolder, cGroup, aComboValues, nMaxLenCombo, cIniBrow, lVirtual, cPictVar, lInsertLine )
oStruCAB:AddField('CTG_CODCAL' , '01' , STR0004 , STR0004 ,{ STR0004 } , 'C' , '@!'  , NIL , 			, .T. 			,NIL ,		 NIL , NIL  , 			NIL 			,IIF(!lInclui, M->CTG_CALEND, ""), .T. ,NIL )  //"Código"
oStruCAB:AddField('CTG_EXCONT' , '02' , STR0005 , STR0005,{ STR0005 } , 'C' , '@!'  , NIL , 			, .T. 			,NIL ,		 NIL , NIL  , 			NIL 			, NIL, .T. ,NIL ) //"Exercício Contábil"

oStruCTG:AddField( "CTG_LEGEND","","","",,"C","@BMP",,,.F.,,,,,,,,.F.)
oStruCQD:AddField( "CQD_LEGEND","","","",,"C","@BMP",,,.F.,,,,,,,,.F.)

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CAB', oStruCAB, 'CTGMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_CTG', oStruCTG, 'CTGDETAIL' )
oView:AddGrid(  'VIEW_CQD', oStruCQD, 'CQDDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR'	, 12 )
oView:CreateHorizontalBox( 'MEIO'		, 44 )
oView:CreateHorizontalBox( 'INFERIOR'	, 44 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CAB', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CTG', 'MEIO' )
oView:SetOwnerView( 'VIEW_CQD', 'INFERIOR' )

oView:EnableTitleView( 'VIEW_CAB', STR0007, RGB( 224, 30, 43 )  )//"Calendário Contábil"
oView:EnableTitleView( 'VIEW_CTG', STR0008, RGB( 224, 30, 43 )  )//"Períodos Contábeis"
oView:EnableTitleView( 'VIEW_CQD', STR0009, RGB( 224, 30, 43 )  )//"Processos"

oView:SetViewProperty('VIEW_CTG', "CHANGELINE", {{ |oModel| CTB12ChgLin(oModel) }} )

//Remove campo da estrutura

oStruCTG:RemoveField( 'CTG_CALEND' )
oStruCTG:RemoveField( 'CTG_EXERC' )
oStruCTG:RemoveField( 'CTG_STATUS' )

oStruCQD:RemoveField( 'CQD_CALEND' )
oStruCQD:RemoveField( 'CQD_EXERC' )

//AddUserButton: Cria botões adicionais na barra de superior da interface
If lopc
	oView:AddUserButton( STR0010, 'CLIPS', { |oView| MarcarTdos() } )//'Multipla'
EndIF
oView:AddUserButton( STR0011, 'CLIPS', { |oView| LegPeriod() } )//'Legenda Período'
oView:AddUserButton( STR0012, 'CLIPS', { |oView| LegProc() } )//'Legenda Processo'

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc}CT012LOAD
Carga inicial da tabela CQD
@author Mayara Alves
@since  16/03/2015

@version 12
/*/
//-------------------------------------------------------------------
Function CT012LOAD()
Local aArea			:= GetArea()
Local aAreaCQD		:= CQD->(GetArea())
Local aAreaSX5		:= SX5->(GetArea())
Local nLinha		:= 0				//Linha que sera inclusa na CQD

Local cAls			:= GetNextAlias()
Local cStatus		:= "1"				//Status do processo
Local cCalend		:= ""				//Cod. calendario
Local cExerc		:= ""				//Exercico
Local lIntPFS		:= CQD->(ColumnPos("CQD_PFSREC")) > 0 .And. SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local aBind         := {}

Static _cQryCTG 

If _cQryCTG == nil 
	_cQryCTG := "SELECT X5_CHAVE, CTG_CALEND, CTG_EXERC,CTG_PERIOD, CTG_STATUS "
	_cQryCTG += " FROM "+RetSqlName("CTG")+" CTG "
	_cQryCTG += " INNER JOIN "+RetSqlName("SX5")+" SX5 "
	_cQryCTG += " ON X5_FILIAL = ? "
	_cQryCTG += " AND X5_TABELA = ? "
	_cQryCTG += " AND SX5.D_E_L_E_T_  = ? "
	_cQryCTG += " WHERE CTG_FILIAL = ? "
	_cQryCTG += " AND CTG_CALEND = ? "
	_cQryCTG += " AND CTG_EXERC = ? "
	_cQryCTG += " AND CTG.D_E_L_E_T_ = ? "
	_cQryCTG += " AND NOT EXISTS(SELECT 1 FROM "+RetSqlName("CQD")+" CQD "
	_cQryCTG += " WHERE CQD.CQD_FILIAL = ? "
	_cQryCTG += " AND CQD.CQD_CALEND = CTG.CTG_CALEND "
	_cQryCTG += " AND CQD.CQD_EXERC  = CTG.CTG_EXERC "
	_cQryCTG += " AND CQD.CQD_PERIOD = CTG.CTG_PERIOD"
	_cQryCTG += " AND CQD.D_E_L_E_T_ = ?)"
	_cQryCTG += " ORDER BY CTG_PERIOD, X5_CHAVE"
	_cQryCTG := ChangeQuery(_cQryCTG)
EndIf 
AADD(aBind,xFilial("SX5"))
AADD(aBind,'U1')
AADD(aBind,Space(1))
AADD(aBind,xFilial("CTG"))
AADD(aBind,CTG->CTG_CALEND)
AADD(aBind,CTG->CTG_EXERC)
AADD(aBind,Space(1))
AADD(aBind,xFilial("CQD"))
AADD(aBind,Space(1))

dbUseArea(.T.,"TOPCONN",TcGenQry2(,,_cQryCTG,aBind),cAls,.T.,.T.)

CQD->(DbSetOrder(1)) //CQD_FILIAL+CQD_CALEND+CQD_EXERC+CQD_PERIOD+CQD_PROC
	cCalend	:= CTG->CTG_CALEND
	cExerc		:= CTG->CTG_EXERC

		While (cAls)->(!Eof())

			//Se for CTB001 pega o status da CTG - Calendario contabil
	Iif((cAls)->X5_CHAVE=="CTB001", cStatus:= (cAls)->CTG_STATUS,cStatus:="1")
			SX5->(dbSeek(XFilial("SX5")+"U1"+(cAls)->X5_CHAVE))

	//- força a validação da não existencia do registro, pois outra thread pode ter efetuado sua inclusão
	If !CQD->(DbSeek(Xfilial("CQD")+(cAls)->CTG_CALEND + (cAls)->CTG_EXERC + (cAls)->CTG_PERIOD+(cAls)->X5_CHAVE))  //Inclui registros encontradas na SX5
		//- verifica se a linha é zero
		//- esta neste ponto para evitar ser chamada quando o Als for EOF
		If nLinha == 0 
			//Função para trazer os item da tabela
			nLinha := CountItem((cAls)->CTG_CALEND,(cAls)->CTG_EXERC,(cAls)->CTG_PERIOD)
		EndIf 
				nLinha++

				RecLock("CQD",.T.)

				CQD->CQD_FILIAL	:=	xFilial("CQD")
		CQD->CQD_CALEND	:=	(cAls)->CTG_CALEND
		CQD->CQD_EXERC	:=	(cAls)->CTG_EXERC
		CQD->CQD_PERIOD	:=	(cAls)->CTG_PERIOD
				CQD->CQD_ITEM	:=	STRZERO(nLinha, 3, 0)
				CQD->CQD_PROC	:=	(cAls)->X5_CHAVE
		CQD->CQD_DESC	:=	SX5->(X5Descri())
				CQD->CQD_STATUS	:=	cStatus
				If lIntPFS //Alteracao SOLICTADA PELO MODULO SIGAPFS
					CQD->CQD_PFSREC := "1"
				EndIf
				CQD->(MsUnlock())

				// Integração SIGAPFS x SIGAFIN
		IIf( FindFunction("JFtSyncCQD"), JFtSyncCQD(cCalend, cExerc, (cAls)->CTG_PERIOD, (cAls)->X5_CHAVE ), Nil )
	EndIF
	(cAls)->(dbSkip())
EndDo

(cAls)->(DbCloseArea())

RestArea( aAreaSX5 )
RestArea(aAreaCQD)
RestArea(aArea)

aSize(aArea,0)
aArea := nil 

aSize(aAreaCQD ,0)
aAreaCQD := nil 

aSize(aAreaSX5,0)
aAreaSX5 := nil 

aSize(aBind,0)
aBind := nil 

Return nil


//-------------------------------------------------------------------
/*/{Protheus.doc}CountItem
Traz o numero de itens por periodo
@author Mayara Alves
@since  16/03/2015

@param cCalend		Cod. calendario
@param cExerc		Exercicio
@param cPeriod		Periodo

@return nRet		Numero do item

@version 12
/*/
//-------------------------------------------------------------------
Static Function CountItem(cCalend,cExerc,cPeriod)
Local nRet		:= 0	 //Retorna o numero do item
Local cQry		:= ''
Local cAlis	:= GetNextAlias()

Default cCalend	:= ""
Default cExerc	:= ""
Default cPeriod	:= ""

cQry := "SELECT COUNT(CQD_ITEM) ITEM FROM " + RetSqlName("CQD") + " CQD " + CRLF
cQry += "WHERE CQD_FILIAL = '" + FWXFilial("CQD") + "' "+CRLF
cQry += "AND CQD_CALEND = '" + cCalend  + "' "+CRLF
cQry += "AND CQD_EXERC	= '" + cExerc  + "' "+CRLF
cQry += "AND CQD_PERIOD = '" + cPeriod  + "' "+CRLF
cQry += "AND CQD.D_E_L_E_T_ = ''" + CRLF
cQry += "GROUP BY CQD_ITEM "+CRLF

cQry := ChangeQuery( cQry )

dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQry) , cAlis , .T. , .F.)


If (cAlis)->(!Eof())
	nRet := (cAlis)->ITEM
EndIf

(cAlis)->(DbCloseArea())

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc}MarcarTdos
o usuário poderá informar qual o status ele quer aplicar para os processos do período posicionado.
o usuário poderá informar qual o status ele quer aplicar para os processos para todos os períodos do calendário.

@author Mayara Alves
@since  16/03/2015
@return lRet
@version 12
/*/
//-------------------------------------------------------------------
Static Function MarcarTdos()
Local aPergs 	:= {}
Local aRet 	:= {}
Local lRet 	:= .F.


aAdd( aPergs ,{2,STR0013	,"1",{"1="+STR0014, "2="+STR0015},50,'.T.',.T.})//"Aplicar" ### "1=Periodo" ### "2=Calendario"
aAdd( aPergs ,{2,STR0016	,"1",{"1="+STR0017, "2="+STR0018}	, 50,'.T.',.T.})  // "Status do Processo" ### "1=Aberto" ### "2=Bloqueado"


If ParamBox(aPergs ,STR0019,aRet)//"Parametros "
	AtuGrdCQD(aRet)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AtuGrdCQD
Atualiza grid da CQD quando for chamado pelo multiplos
@author Mayara Alves
@since  16/03/2015
@param cPar

@version 12
/*/
//-------------------------------------------------------------------
Static Function AtuGrdCQD(cPar)
Local oModel		:= FWModelActive()
Local oModelCQD		:= oModel:GetModel('CQDDETAIL')
Local oModelCTG		:= oModel:GetModel('CTGDETAIL')
Local aSaveLine		:= FWSaveRows()
Local nI			:= 0
Local nX			:= 0
Local oView		:= FWViewActive()

Default cPar := ""

//cPar[1] - 1 = Perido 2 = Calendario
//cPar[2] - 1 = Aberto 2 = Bloquea

Iif (cPar[2] == "1", cStatus:= "1",cStatus:= "4"	) //1- Aberto 4- Bloqueado

If  cPar[1] == "1" //1 = Perido

	For nI := 1 To oModelCQD:Length()
		oModelCQD:GoLine( nI )
		oModelCQD:SetValue("CQD_STATUS",cStatus,.T.)	// CTG_STATUS
	Next
ElseIf cPar[1] == "2" // 2 = Calendario

	For nX := 1 To oModelCTG:Length()
		oModelCTG:GoLine( nX )
		For nI := 1 To oModelCQD:Length()
			oModelCQD:GoLine( nI )
			oModelCQD:SetValue("CQD_STATUS",cStatus,.T.)	// CTG_STATUS
		Next nI
	Next nX

EndIf

FWRestRows( aSaveLine )

oView:Refresh()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc}C012CQDLEG
Funcao que retona a Legenda do grid da CQD

Verde: Aberto
Amarelo: Parcialmente bloqueado
Vermelho: Bloqueado

1=Aberto;2=Fechado;3=Transportado;4=Bloqueado;5=Periodo

@author Mayara Alves
@since  16/03/2015
@param cStatus		Status
@param cCalend		Cod. Calendario
@param cExerc		Exercico
@param cPeriod		Periodo
@param cProc		Processo

@return cDesc		Cor da legenda

@version 12
/*/
//-------------------------------------------------------------------
Static Function C012CQDLEG(cStatus,cCalend,cExerc,cPeriod,cProc)

Local cDesc 	:= ""
Local aArea		:= GetArea()
Local aAreaCTG	:= CTG->(GetArea())
Local aSaveLine := FWSaveRows()

Default cStatus	:= ""
Default cCalend	:= ""
Default cExerc	:= ""
Default cPeriod	:= ""
Default cProc	:= ""

//Apenas esse processo permitirá o status fechado e transportado.
If cProc == "CTB001" .And. !(cStatus $ "4|5")
	dbSelectArea("CTG")
	CTG->(DbSetOrder(1)) //CQD_FILIAL+CQD_CALEND+CQD_EXERC+CQD_PERIOD
	If CTG->(DbSeek(Xfilial("CTG")+cCalend + cExerc + cPeriod))
		 Iif(CTG->CTG_STATUS<>"1",cStatus:="4",cStatus:="1")
	EndIf
EndIf

Do Case
	Case cStatus == "1"
		cDesc := "BR_VERDE"
	Case cStatus == "4"
		cDesc := "BR_VERMELHO"
	Case cStatus == "5"
		cDesc := "BR_AZUL"
EndCase

FWRestRows( aSaveLine )

RestArea(aAreaCTG)
RestArea(aArea)
Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc}C012CTGLEG
Funcao que retona a Legenda do grid da CTG

Verde: Aberto
Vermelho: Bloqueado

@author Mayara Alves
@since  16/03/2015

@param cCalend		Cod. Calendario
@param cExerc		Exercico
@param cPeriod		Periodo
@param cProc		Processo
@param lAtu		Se é atualização

@return cDesc		Cor da legenda

@version 12
/*/
//-------------------------------------------------------------------
Static Function C012CTGLEG(cCalend,cExerc,cPeriod,cProc,lAtu)
Local cDesc 		:= ""
Local cQry			:= ''
Local cAls			:= GetNextAlias()
Local aArea		:= GetArea()
Local aAreaCQD	:= CQD->(GetArea())
Local aAreaCTG	:= CTG->(GetArea())
Local aSaveLine 	:= FWSaveRows()
Local oModel		:= Nil //FWModelActive()
Local oModelCQD	:= Nil// oModel:GetModel('CQDDETAIL')

Local nI		:= 0
Local cSttAnt := ""
Local cStatus	:= ""
Local nDif		:= 0

Default cCalend	:= ""
Default cExerc	:= ""
Default cPeriod	:= ""
Default cProc 	:= ""
Default lAtu		:= .F.

If !lAtu //Se for no inicializador do campo
	cQry := "SELECT COUNT(DISTINCT CQD_STATUS) NLINHA FROM " + RetSqlName("CQD") + " CQD " + CRLF
	cQry += "WHERE CQD_FILIAL = '" + FWXFilial("CQD") + "' "+CRLF
	cQry += "AND CQD_CALEND = '" + cCalend  + "' "+CRLF
	cQry += "AND CQD_EXERC = '" + cExerc  + "' "+CRLF
	cQry += "AND CQD_PERIOD = '" + cPeriod + "' "+CRLF
	cQry += "AND CQD.D_E_L_E_T_ = ''" + CRLF

	cQry := ChangeQuery( cQry )

	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQry) , cAls , .T. , .F.)

	If (cAls)->(!Eof())
		If (cAls)->NLINHA <> 1
			cStatus := "2" //Amarelo: Parcialmente bloqueado
		Else
			dbSelectArea("CQD")
			CQD->(DbSetOrder(1)) //CQD_FILIAL+CQD_CALEND+CQD_EXERC+CQD_PERIOD+CQD_PROC
			If CQD->(DbSeek(Xfilial("CQD")+cCalend + cExerc + cPeriod+cProc))
				If CQD->CQD_STATUS == "1"
					cStatus := "1" //Verde: Aberto
				ElseIf CQD->CQD_STATUS == "4"
					cStatus := "3" //Vermelho: Bloqueado
				EndIf
			EndIf
		EndIF

	EndIf

	(cAls)->(DbCloseArea())

Else
	oModel		:= FWModelActive()
	oModelCQD	:= oModel:GetModel('CQDDETAIL')

	For nI:= 1 To oModelCQD:Length()

		oModelCQD:GoLine( nI )
		cStatus:= oModelCQD:GetValue("CQD_STATUS")	// CTG_STATUS

		If cStatus <> cSttAnt .And. !cStatus $ "2|3" .And. nI<>1
			nDif++
		EndIf
		cSttAnt := cStatus
	Next

	If nDif == 0
		Iif(cStatus=="1",cStatus:="1",cStatus:="3")

	Else
		cStatus := "2" //Amarelo: Parcialmente bloqueado
	EndIf
EndIf

Do Case
	Case cStatus == "1"
		cDesc := "BR_VERDE"
	Case cStatus == "2"
		cDesc := "BR_AMARELO"
	Case cStatus == "3"
		cDesc := "BR_VERMELHO"
EndCase



FWRestRows( aSaveLine )

RestArea(aAreaCTG)
RestArea(aAreaCQD)
RestArea(aArea)
Return cDesc


//-------------------------------------------------------------------
/*/{Protheus.doc}VldLinCQD
Valida linha da CQD para não permitir status igual a 2 e 3
@author Mayara Alves
@since  16/03/2015

@return lRet

@version 12
/*/
//-------------------------------------------------------------------
Static Function VldLinCQD()

Local oView		:= FWViewActive()
Local oModel	:= FWModelActive()
Local oModelCQD	:= oModel:GetModel('CQDDETAIL')
Local oModelCTG	:= oModel:GetModel('CTGDETAIL')
Local cStatus 	:= oModelCQD:GetValue("CQD_STATUS")	//Status
Local cCalend 	:= oModelCQD:GetValue("CQD_CALEND")	//Calendario
Local cSExerc 	:= oModelCQD:GetValue("CQD_EXERC")	//Exercicio
Local cPeriod 	:= oModelCQD:GetValue("CQD_PERIOD")	//Periodo
Local cProc		:= oModelCQD:GetValue("CQD_PROC") 	//Processo
Local lRet		:= .T.
Local aSaveLine := FWSaveRows()

//Valida o status seleciona
If cStatus $ "2|3"
	lRet := .F.
	oModel:SetErrorMessage("","","","","CQD_STATUS",STR0020,STR0021)
	//'Indicativo do status do periodo. Pode ser: "Aberto" ou "Bloquieado". Os tipos "Fechado" e "Transportado" são gerados por outro rotina'
	//'Os tipos "Fechado" e "Transportado" são gerados por outras rotinas, portanto não podem ser atualizados aqui.'
EndIf

//Atualiza a legenda
If lRet
	oModelCQD:SetValue("CQD_LEGEND",C012CQDLEG(cStatus,cCalend,cSExerc,cPeriod,cProc),.T.)	// CTG_STATUS
	oModelCTG:SetValue("CTG_LEGEND",C012CTGLEG(cCalend,cSExerc,cPeriod,cProc,.T.),.T.)	// CTG_STATUS
EndIf
FWRestRows( aSaveLine )

If ValType(oView) = "O"
	oView:Refresh()
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}LegPeriod
Funcao de legenda do perido
@author Mayara Alves
@since  16/03/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function LegPeriod()
Local aLegenda	 := {}

aAdd(aLegenda,{"BR_VERDE"		,STR0017}) //"Aberto"
aAdd(aLegenda,{"BR_AMARELO"		,STR0027}) //"Parcialmente bloqueado"
aAdd(aLegenda,{"BR_VERMELHO" 	,STR0018}) //"Bloqueado"

BrwLegenda(STR0022,STR0023, aLegenda ) //"Status do Periodo"###"Legenda"
Return


//-------------------------------------------------------------------
/*/{Protheus.doc}LegProc
Funcao de legenda do processo
@author Mayara Alves
@since  16/03/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function LegProc()
Local aLegenda	 := {}

aAdd(aLegenda,{"BR_VERDE"		,STR0017}) //"Aberto"
aAdd(aLegenda,{"BR_VERMELHO"	,STR0018}) //"Bloqueado"
aAdd(aLegenda,{"BR_AZUL"		,STR0026}) //"Parcial"


BrwLegenda(STR0024,STR0023, aLegenda )//"Status do Processo"###"Legenda"
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}CTBA012FEC
//Atuialisa status da CQD-Bloquei de processos para contabilidade
//Função chamada no fonte CTBA400 - Ct400CTG
@author Mayara Alves
@since  16/03/2015
@param cCalend		Cod. Calendario
@param cExerc		Exercico
@version 12
/*/
//-------------------------------------------------------------------
Function CTBA012FEC(cCalend,cExerc)
Local aArea		:= GetArea()
Local aAreaCQD	:= CQD->(GetArea())

Default cCalend	:= ""
Default cExerc	:= ""

dbSelectArea("CQD")
CQD->(dbSetOrder(1))
If CQD->(dbSeek(xFilial("CQD")+cCalend+cExerc))
	While CQD->CQD_FILIAL == XFilial("CQD") .And. CQD->CQD_CALEND == cCalend .And. ;
			CQD->CQD_EXERC == cExerc .And. CQD->(!Eof())
		If CQD->CQD_PROC == "CTB001"
			Reclock("CQD",.F.)
			CQD->CQD_STATUS := '2' //Fechado
			CQD->(MsUnlock())
		EndIf
	CQD->(dbSkip())
	EndDO
EndIf

RestArea(aAreaCQD)
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}CTBA012ALT
Altera Bloquei de processos CQD
Função chamada no fonte CTBA010 - Ctb010Grava
@author Mayara Alves
@since  16/03/2015
@param cCalend		Cod. Calendario
@param cExerc		Exercico
@param cPeriod		Periodo
@param cStatus		Status
@version 12
/*/
//-------------------------------------------------------------------
Function CTBA012ALT(cCalend,cExerc,cPeriod,cStatus)
Local aArea		:= GetArea()
Local aAreaCQD	:= CQD->(GetArea())
Local lIntPFS   := cStatus == '1' .And. CQD->(ColumnPos("CQD_PFSREC")) > 0 .And. SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN

Default cCalend	:= ""
Default cExerc	:= ""
Default cPeriod	:= ""
Default cStatus	:= ""

// Exclui o calendário, caso não existam lançamentos
dbSelectArea("CQD")
CQD->(dbSetOrder(1))//CQD_FILIAL+CQD_CALEND+CQD_EXERC+CQD_PERIOD+CQD_PROC
If CQD->(dbSeek(xFilial("CQD")+cCalend+cExerc+cPeriod+"CTB001"))
	If CQD->CQD_STATUS <> cStatus
		Reclock("CQD",.F.)
		CQD->CQD_STATUS := cStatus
		If lIntPFS //Alteracao SOLICTADA PELO MODULO SIGAPFS
			CQD->CQD_PFSREC := "1"
		EndIf
		CQD->(MsUnlock())
	EndIf
EndIf

RestArea(aAreaCQD)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}Ctb012When
Liberação dos campos data.
@author Kaique Schiller
@since  28/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Function Ctb012When()
Local lRet 		:= .F.
Local oModel 	:= FWModelActive()
Local oModelCQD := oModel:GetModel("CQDDETAIL")

If oModelCQD:GetValue("CQD_STATUS") == "5"
	lRet := .T.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}Ctb012VlDt
Validação das Datas.
@author Kaique Schiller
@since  28/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Function Ctb012VlDt()
Local lRet 		:= .T.
Local oModel 	:= FWModelActive()
Local oModelCTG := oModel:GetModel("CTGDETAIL")
Local oModelCQD := oModel:GetModel("CQDDETAIL")
Local cDtIniCtg := oModelCTG:GetValue("CTG_DTINI")
Local cDtIniCqd := oModelCQD:GetValue("CQD_DTINI")
Local cDtFimCtg := oModelCTG:GetValue("CTG_DTFIM")
Local cDtFimCqd := oModelCQD:GetValue("CQD_DTFIM")

If !Empty(cDtIniCqd)
	If cDtIniCtg > cDtIniCqd .OR. cDtFimCtg < cDtIniCqd
		lRet := .F.
	Elseif !Empty(cDtFimCqd) .AND. cDtIniCqd > cDtFimCqd
		lRet := .F.
	Endif
Endif

If !Empty(cDtFimCqd)
	If cDtIniCtg > cDtFimCqd .OR. cDtFimCtg < cDtFimCqd
		lRet := .F.
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}Ctb012Trig
Gatilho para zerar as datas.
@author Kaique Schiller
@since  28/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function Ctb012Trig()
Local oModel	:= FWModelActive()
Local oModelCQD	:= oModel:GetModel("CQDDETAIL")
Local dData 	:= CTOD(SPACE(8))

If oModelCQD:GetValue("CQD_STATUS") <> "5"
	oModelCQD:LoadValue("CQD_DTINI",dData)
	oModelCQD:LoadValue("CQD_DTFIM",dData)
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}Ctb012Pos
Validação LinhaOk.
@author Kaique Schiller
@since  28/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function Ctb012Pos()
Local lRet		:= .T.
Local oModel 	:= FWModelActive()
Local oModelCQD	:= oModel:GetModel("CQDDETAIL")

// Integração SIGAPFS x SIGAFIN
IIf( lRet .And. FindFunction("JVldProc"), lRet := JVldProc(oModel), lRet := .T. )

If lRet .and. oModelCQD:GetValue("CQD_STATUS") == "5"
	If Empty(oModelCQD:GetValue("CQD_DTINI")) .or. Empty(oModelCQD:GetValue("CQD_DTFIM"))
		lRet := .F.
		Help( ,, 'Ctb012Pos',, STR0032, 1, 0) //"O periodo necessita de Data inicial e Data Final"
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}Ctb012Vlid
Pos Validação.
@Param cCampo
@author Kaique Schiller
@since  28/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Function Ctb012Vlid()
Local lRet	 	:= .T.
Local oModel 	:= FWModelActive()
Local nOperacao	:= oModel:GetOperation()

If nOperacao == MODEL_OPERATION_UPDATE
	Ctb012Html()
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}Ctb012SX3
Localiza as Descrições dos campos.
@Param cCampo
@author Kaique Schiller
@since  28/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Function Ctb012Sx3(cCampo)
Local cRetorno := ""
Local aAreaSX3 := SX3->(GetArea())

dbSelectArea("SX3")
dbSetOrder(2)
If dbSeek(cCampo)
	cRetorno := SX3->X3_TITULO
EndIf

RestArea(aAreaSX3)

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc}Ctb012Html
Gera o Html e envia o e-mail.
@author Kaique Schiller
@since  28/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function Ctb012Html()
Local oModel 	:= FWModelActive()
Local oModelCTG := oModel:GetModel("CTGDETAIL")
Local oModelCQD := oModel:GetModel("CQDDETAIL")
Local cHtml   	:= ""
Local nX 		:= 0
Local nZ 		:= 0
Local cPeriodo 	:= ""
Local nCont 	:= 0
Local lPeHtml := ExistBlock("CT012BWF")
Local cHtmlPe := ""

For nX := 1 to oModelCTG:Length()
	oModelCTG:GoLine(nX)
	For nZ := 1 to oModelCQD:Length()
		oModelCQD:GoLine(nZ)
		If oModelCQD:IsUpdated(nZ)
			If cPeriodo <> oModelCQD:GetValue("CQD_PERIOD")
				If nCont == 4
					cHtml += '<br><br>'
					cHtml += '<table style="text-align: left; width: 100%;" border="0" cellpadding="2" cellspacing="1"><tbody>'
					cHtml += '<tr style="font-family: Arial;"><th valign="center" style="background-color: gray; font-weight: bold; color: white;"><small>'
					cHtml += '</font></font></body></html>'
					Ctb010EnWf(,cHtml)
					nCont := 0
				Endif
				If nCont == 0
					cHtml := '<html><body><font face="Arial"><br>'
				Endif
				cHtml += '<hr style="width: 100%; height: 2px; font-family: Arial;">'
				cHtml += '<br> '+Ctb012Sx3("CTG_FILIAL")+':'+cValtoChar(FWCodFil())
				cHtml += '&nbsp&nbsp&nbsp'+Ctb012Sx3("CTG_CALEND")+': '+oModelCTG:GetValue("CTG_CALEND")

				cHtml += '&nbsp&nbsp&nbsp '+Ctb012Sx3("CTG_DTINI")+': '+DTOC(oModelCTG:GetValue("CTG_DTINI"))
				cHtml += '&nbsp&nbsp&nbsp '+Ctb012Sx3("CTG_DTFIM")+': '+DTOC(oModelCTG:GetValue("CTG_DTFIM"))
				cHtml += '<p align=center > '+STR0025+'</p>' //"Processos Alterados."
				cHtml += '<hr style="width: 100%; height: 2px; font-family: Arial;">'
				nCont++
			Endif
			cPeriodo := oModelCQD:GetValue("CQD_PERIOD")
			cHtml += '<br> '+X3Combo("CQD_STATUS",oModelCQD:GetValue("CQD_STATUS"))
			cHtml += '&nbsp&nbsp'+oModelCQD:GetValue("CQD_PROC")
			cHtml += '&nbsp&nbsp'+oModelCQD:GetValue("CQD_DESC")

			If lPeHtml
				cHtmlPe := 	ExecBlock("CT012BWF",.F.,.F.,{ cHtml, nCont, oModelCTG, oModelCQD })

				If ValType(cHtmlPe) != "C" .OR. Empty(Alltrim(cHtmlPE))
					Help(" ",1,"CT012BWF_ERR",,"Error PE CT012BWF WF - HTML!",3,1)
				Else
					cHtml := cHtmlPe
				EndIf
			EndIf

		Endif
	Next
	If oModelCTG:Length() == nX
		cHtml += '<br><br>'
		cHtml += '<table style="text-align: left; width: 100%;" border="0" cellpadding="2" cellspacing="1"><tbody>'
		cHtml += '<tr style="font-family: Arial;"><th valign="center" style="background-color: gray; font-weight: bold; color: white;"><small>'
		cHtml += '</font></font></body></html>'
		Ctb010EnWf(,cHtml)
	Endif
Next

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CTB12ChgLin
Posiciona CTG para o WalkThru

@author TOTVS
@since  23/06/2021
@version 12
/*/
//-------------------------------------------------------------------
Static Function CTB12ChgLin(oModel)
Local cChave 	:= ""
Local oModelCTG	:= oModel:GetModel('CTGDETAIL')

cChave := xFilial("CTG")
cChave += oModelCTG:GetValue("CTG_CALEND")
cChave += oModelCTG:GetValue("CTG_EXERC")
cChave += oModelCTG:GetValue("CTG_PERIOD")

CTG->(dbSetOrder(1))
CTG->(dbSeek(cChave))
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CTB12ChgLin
Posiciona CTG para o WalkThru

@author TOTVS
@since  23/06/2021
@version 12
/*/
//-------------------------------------------------------------------
Static Function CTB12IniCTG()
//Posiciono no primeiro período para o WalkThru
dbSelectArea("CTG")
CTG->(dbSetOrder(1))
CTG->(dbSeek(xFilial("CTG")+CTG->(CTG_CALEND+CTG_EXERC)))

Return
