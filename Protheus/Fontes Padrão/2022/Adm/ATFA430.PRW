#INCLUDE "PROTHEUS.CH"
#INCLUDE "ATFA430.CH"
#INCLUDE 'FWMVCDEF.CH'
#include "tbiconn.ch"
#include "sigawin.ch"

#DEFINE OPER_BLOQUEAR		10
#DEFINE OPER_REVISAR        11
#DEFINE OPER_ATUALIZAR		13
#DEFINE OPER_ENC_ETAPA		12
#DEFINE OPER_ENC_PROJ		14
#DEFINE OPER_COPIAR			15
#DEFINE OPER_IMPORTAR       16
#DEFINE OPER_REVTX   		17
#DEFINE OPER_REALIZAR		18
#DEFINE OPER_EFETREAL		19

Static __cCalcDep
Static __nOper 			:= 0 // Operacao da rotina
Static __cProcPrinc  	:= "ATFA430"
Static __lConfirmar     := .T.
Static __lCtrlAprov 	:= .T.
Static __lCpyCtb		:= .F.
Static __lBTNConfirma   := .F.
//BPI
Static aDadosFNJ		:= {}	//Array da consulta F3 do grid da FNJ
Static aStatus	 		:= {}	//Descricao de Status possiveis para um projeto
Static aCargaFNJ		:= {}	//Array da carga inicial do grid da FNJ

STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location
/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ ATFA430  ณ Autor ณAlvaro Camillo Neto    ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Cadastro de Projeto do Ativo Fixo                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function ATFA430()
Local oBrowse
Local lDefTop 	:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)

// Incluido por causa da rotina MSDOCUMENT, o MVC nใo precisa de nenhuma variแvel private
Private cCadastro := STR0001
Private aRotina	:= MenuDef()

__nOper := 0

If !lDefTop
	Help("  ",1,"AFR430TOP",,STR0135 ,1,0) //"Fun็ใo disponํvel apenas para ambientes TopConnect"
	Return
EndIf

If FWHASMVC()

	ChkFile("FNB")
	ChkFile("FNC")
	ChkFile("FNE")
	ChkFile("FND")
	ChkFile("FIT")

	//BPI
	If AFVldBpi()
		ChkFile("FNJ")
	Endif

	dbSelectArea('FNB')
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'FNB' )
	oBrowse:SetDescription( STR0001 ) // 'Projeto de Imobilizado'
	oBrowse:AddLegend( "FNB_STATUS == '0'", "WHITE"		, STR0002	)// "Gerado"
	oBrowse:AddLegend( "FNB_STATUS == '1'", "GREEN"		, STR0003	)// "Ativo"
	oBrowse:AddLegend( "FNB_STATUS == '2'", "RED"  		, STR0004	)// "Encerrado"
	oBrowse:AddLegend( "FNB_STATUS == '7'", "GRAY"  	, STR0005	)// "Bloqueado - Revisใo"
	oBrowse:AddLegend( "FNB_STATUS == '8'", "YELLOW"  	, STR0006  	)// "Bloqueado - Aprovacใo"
	oBrowse:AddLegend( "FNB_STATUS == '9'", "ORANGE"  	, STR0007	)// "Bloqueado - Usuแrio"
	oBrowse:AddLegend( "FNB_STATUS == '3'", "BLACK"  	, STR0133	)// "Bloqueado - Rejei็ใo"
	oBrowse:AddLegend( "FNB_STATUS == 'A'", "BLUE"  	, STR0155	)// "Realiza็ใo Pendente"

	SetKey( VK_F12, { || Pergunte("AFA430",.T.) } )

	oBrowse:Activate()

Else
	Help(" ",1,"AF430MVC",,STR0009,1,0)//"Ambiente desatualizado, por favor atualizar com o ultimo pacote da lib "
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Alvaro Camillo Neto   ณ Data ณ30/09/11  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados         ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0010	ACTION 'PesqBrw'            	OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina TITLE STR0011	ACTION 'VIEWDEF.ATFA430'  		OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0012	ACTION 'VIEWDEF.ATFA430' 		OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0013	ACTION 'VIEWDEF.ATFA430' 		OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0014	ACTION 'VIEWDEF.ATFA430' 		OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE STR0022	ACTION 'AFA430CPY' 	 			OPERATION 2 ACCESS 0 //'Copiar'
ADD OPTION aRotina TITLE STR0015	ACTION 'AFA430ATU'    	  		OPERATION 2 ACCESS 0 //'Atualizar'
ADD OPTION aRotina TITLE STR0067	ACTION 'AFA430ETEN'   	  		OPERATION 2 ACCESS 0 //"Enc Etapa"
ADD OPTION aRotina TITLE STR0016	ACTION 'AFA430REV'    	  		OPERATION 2 ACCESS 0 //'Revisar'
ADD OPTION aRotina TITLE STR0139	ACTION 'AF430REVTX'    	  		OPERATION 2 ACCESS 0 //"Rev AVP"
ADD OPTION aRotina TITLE STR0017	ACTION 'AFA430ENC'    	  		OPERATION 2 ACCESS 0 //'Encerrar'
ADD OPTION aRotina TITLE STR0145	ACTION 'AFA430REA'    	  		OPERATION 4 ACCESS 0 //"Realizar"
ADD OPTION aRotina TITLE STR0146	ACTION 'AF430EFRE'    	  		OPERATION 2 ACCESS 0 //"Efetivar Rlz"
ADD OPTION aRotina TITLE STR0018	ACTION 'AFA430BLQ' 		  		OPERATION 20 ACCESS 0 //'Bloqueio/Desbloq'
ADD OPTION aRotina TITLE STR0019	ACTION 'AFA430IMP'    	  		OPERATION 3 ACCESS 0 //'Importar CSV'
ADD OPTION aRotina TITLE STR0020	ACTION 'AFA430Exp'    	  		OPERATION 2 ACCESS 0 //'Exportar CSV'
ADD OPTION aRotina TITLE STR0068	ACTION 'AFA430LOG' 				OPERATION 3 ACCESS 0 //"Log Proc"
ADD OPTION aRotina TITLE STR0021   ACTION 'VIEWDEF.ATFA430' 		OPERATION 8 ACCESS 0 //'Imprimir'
ADD OPTION aRotina TITLE STR0120   ACTION 'MSDOCUMENT'   	 		OPERATION 4 ACCESS 0 //"Conhecimento"

Return aRotina



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRotinas de configura็ใo do MVCณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ MODELDEF ณ Autor ณAlvaro Camillo Neto    ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Fun็ใo que define o modelo do cadastro de projeto de  imob ณฑฑ
ฑฑณ          ณ ilizado para o MVC                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ ATFA430                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Modeldef()

Local oStruFNB 	:= AF430Struct('FNB')
Local oStruFNC 	:= AF430Struct('FNC')
Local oStruFND 	:= AF430Struct('FND')
Local oStruFNE 	:= AF430Struct('FNE')
Local oStruFNJ	:= AF430Struct('FNJ')
Local oModel		:= Nil
Local aRelacFNC	:= {}
Local aRelacFND	:= {}
Local aRelacFNE	:= {}
Local aRelacFNJ	:= {}
Local lBpiAtf	:= AFVldBpi()

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'ATFA430', /*bPreValidacao*/, { |oModel| AF430POSVL(oModel) },  { |oModel| AF430GRVMD( oModel ) }, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por campo
oModel:AddFields( 'FNBMASTER', /*cOwner*/, oStruFNB )

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por grid
oModel:AddGrid( 'FNCDETAIL'		, 'FNBMASTER'	, oStruFNC, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'FNDDETAIL'		, 'FNCDETAIL'	, oStruFND, { |oModelGrid,  nLine, cAction,cField| FNDLINPRE(oModelGrid,cAction) }, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'FNEDETAIL'  	, 'FNDDETAIL'	, oStruFNE, { |oModelGrid,  nLine, cAction,cField| FNELINPRE(oModelGrid,cAction) }, { |oModelGrid| FNELINPOS(oModelGrid) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
//BPI
If lBpiAtf
	oModel:AddGrid( 'FNJDETAIL'	, 'FNEDETAIL'	, oStruFNJ, { |oModelGrid,  nLine, cAction,cField| FNJLINPRE(oModelGrid,cAction) }, { |oModelGrid,cAction| FNJLINPOS(oModelGrid) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
Endif

// Nใo permite inserir linhas na grid
If __nOper == OPER_BLOQUEAR .Or. __nOper == OPER_ENC_ETAPA .Or. __nOper == OPER_REVTX .or. ;
	__nOper == OPER_REALIZAR .or. __nOper == OPER_EFETREAL
	oModel:GetModel( 'FNCDETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FNCDETAIL' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'FNDDETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FNDDETAIL' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'FNEDETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FNEDETAIL' ):SetNoDeleteLine( .T. )
EndIf

//BPI
//Caso nao seja a acao de realizar, nao sera possivel manipular dados na grid FNJ
If lBpiAtf .and. __nOper != OPER_REALIZAR
	oModel:GetModel( 'FNJDETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FNJDETAIL' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'FNJDETAIL' ):SetNoUpdateLine( .T. )
Endif

//Relacionamento da tabela Etapa com Projeto
aAdd(aRelacFNC,{ 'FNC_FILIAL'	, 'xFilial( "FNC" )'	})
aAdd(aRelacFNC,{ 'FNC_CODPRJ'	, 'FNB_CODPRJ' 		})
aAdd(aRelacFNC,{ 'FNC_REVIS'	, 'FNB_REVIS' 			})

//Relacionamento da tabela Item da Etapa com a Etapa
aAdd(aRelacFND,{ 'FND_FILIAL'	, 'xFilial( "FND" )'	})
aAdd(aRelacFND,{ 'FND_CODPRJ'	, 'FNB_CODPRJ' 		})
aAdd(aRelacFND,{ 'FND_REVIS'	, 'FNB_REVIS' 			})
aAdd(aRelacFND,{ 'FND_ETAPA'	, 'FNC_ETAPA' 			})

//Relacionamento da tabela da configuracao contabil com Item da Etapa
aAdd(aRelacFNE,{ 'FNE_FILIAL'	, 'xFilial( "FND" )' })
aAdd(aRelacFNE,{ 'FNE_CODPRJ'	, 'FNB_CODPRJ' 		})
aAdd(aRelacFNE,{ 'FNE_REVIS'	, 'FNB_REVIS' 			})
aAdd(aRelacFNE,{ 'FNE_ETAPA'	, 'FNC_ETAPA' 			})
aAdd(aRelacFNE,{ 'FNE_ITEM'		, 'FND_ITEM' 		  	})

//BPI
If lBpiAtf
	//Relacionamento da tabela do Item da Etapa com Itens de Execucao
	aAdd(aRelacFNJ,{ 'FNJ_FILIAL'	, 'xFilial( "FNE" )'})
	aAdd(aRelacFNJ,{ 'FNJ_CODPRJ'	, 'FNB_CODPRJ' 		})
	aAdd(aRelacFNJ,{ 'FNJ_REVIS'	, 'FNB_REVIS' 		})
	aAdd(aRelacFNJ,{ 'FNJ_ETAPA'	, 'FNC_ETAPA' 		})
	aAdd(aRelacFNJ,{ 'FNJ_ITEM'		, 'FND_ITEM' 		})
	aAdd(aRelacFNJ,{ 'FNJ_LINHA'	, 'FNE_LINHA' 		})
	aAdd(aRelacFNJ,{ 'FNJ_TAFPRJ'	, 'FNE_TPATF' 		})
	aAdd(aRelacFNJ,{ 'FNJ_SLDPRJ'	, 'FNE_TPSALD' 		})
Endif

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'FNCDETAIL', aRelacFNC , FNC->( IndexKey( 1 ) )  )
oModel:SetRelation( 'FNDDETAIL', aRelacFND , FND->( IndexKey( 1 ) )  )
oModel:SetRelation( 'FNEDETAIL', aRelacFNE , FNE->( IndexKey( 1 ) )  )
//BPI
If lBpiAtf .and. __nOper != OPER_COPIAR
	oModel:SetRelation( 'FNJDETAIL', aRelacFNJ , FNJ->( IndexKey( 1 ) )  )
Endif


//Deixa o prrenchimento das tabelas opcional
oModel:GetModel( 'FNCDETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FNDDETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FNEDETAIL' ):SetOptional( .T. )
//BPI
If lBpiAtf
	oModel:GetModel( 'FNJDETAIL' ):SetOptional( .T. )
Endif

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'FNCDETAIL' ):SetUniqueLine( { 'FNC_ETAPA' } )
oModel:GetModel( 'FNDDETAIL' ):SetUniqueLine( { 'FND_ITEM'  } )
oModel:GetModel( 'FNEDETAIL' ):SetUniqueLine( { 'FNE_TPATF','FNE_TPSALD' } )
//BPI
If lBpiAtf
	oModel:GetModel( 'FNJDETAIL' ):SetUniqueLine( { 'FNJ_CBAEXE','FNJ_ITEXE','FNJ_TAFEXE','FNJ_SLDEXE' } )
Endif

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 ) //'Projeto do Imobilizado'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FNBMASTER' ):SetDescription( STR0001 ) //'Projeto do Imobilizado'
oModel:GetModel( 'FNCDETAIL' ):SetDescription( STR0023 ) //'Etapa do Projeto Imobilizado'
oModel:GetModel( 'FNDDETAIL' ):SetDescription( STR0024 ) //'Item da Etapa do Projeto Imobilizado'
oModel:GetModel( 'FNEDETAIL' ):SetDescription( STR0025 ) //'Configura็ใo contแbil da Etapa do Projeto'
//BPI
If lBpiAtf
	oModel:GetModel( 'FNJDETAIL' ):SetDescription( STR0147 ) //'Ativos de Execu็ใo'
Endif

oModel:SetVldActivate( {|oModel| AF430VLMod(oModel) } )

Return oModel

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ Viewdef  ณ Autor ณAlvaro Camillo Neto    ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Fun็ใo que define a interface do cadastro de projeto de imob ณฑฑ
ฑฑณ          ณ ilizado para o MVC                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ ATFA430                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Viewdef()
// Cria a estrutura a ser usada na View
Local oStruFNB := FWFormStruct( 2, 'FNB' )
Local oStruFNC := FWFormStruct( 2, 'FNC' )
Local oStruFND := FWFormStruct( 2, 'FND' )
Local oStruFNE := FWFormStruct( 2, 'FNE' )
Local oStruFNJ := Nil
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'ATFA430' )
Local oView		:= Nil
local lBpiAtf  := AFVldBpi()

If lBpiAtf
	oStruFNJ := FWFormStruct( 2, 'FNJ' )
Endif

// Remove campos da estrutura para nao aparecer na grid

oStruFNB:RemoveField( 'FNB_STATUS' )

oStruFNC:RemoveField( 'FNC_FILIAL' )
oStruFNC:RemoveField( 'FNC_CODPRJ' )
oStruFNC:RemoveField( 'FNC_REVIS' )
oStruFNC:RemoveField( 'FNC_STATUS' )

oStruFND:RemoveField( 'FND_FILIAL' )
oStruFND:RemoveField( 'FND_CODPRJ' )
oStruFND:RemoveField( 'FND_REVIS'  )
oStruFND:RemoveField( 'FND_ETAPA'  )
oStruFND:RemoveField( 'FND_STATUS' )

oStruFNE:RemoveField( 'FNE_FILIAL' )
oStruFNE:RemoveField( 'FNE_CODPRJ' )
oStruFNE:RemoveField( 'FNE_REVIS'  )
oStruFNE:RemoveField( 'FNE_ETAPA'  )
oStruFNE:RemoveField( 'FNE_ITEM'   )

//BPI
If lBpiAtf
	oStruFNJ:RemoveField( 'FNJ_FILIAL' )
	oStruFNJ:RemoveField( 'FNJ_CODPRJ' )
	oStruFNJ:RemoveField( 'FNJ_REVIS'  )
	oStruFNJ:RemoveField( 'FNJ_ETAPA'  )
	oStruFNJ:RemoveField( 'FNJ_ITEM'   )
	oStruFNJ:RemoveField( 'FNJ_LINHA'  )
	oStruFNJ:RemoveField( 'FNJ_TAFPRJ' )
	oStruFNJ:RemoveField( 'FNJ_SLDPRJ' )
Endif

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados serแ utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FNB', oStruFNB, 'FNBMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_FNC', oStruFNC, 'FNCDETAIL' )
oView:AddGrid(  'VIEW_FND', oStruFND, 'FNDDETAIL' )
oView:AddGrid(  'VIEW_FNE', oStruFNE, 'FNEDETAIL' )
//BPI
If lBpiAtf
	oView:AddGrid(  'VIEW_FNJ', oStruFNJ, 'FNJDETAIL' )
Endif

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_FNC', 'FNC_ETAPA' 	)
oView:AddIncrementField( 'VIEW_FND', 'FND_ITEM' 	)
oView:AddIncrementField( 'VIEW_FNE', 'FNE_LINHA' 	)
//BPI
If lBpiAtf
	oView:AddIncrementField( 'VIEW_FNJ', 'FNJ_ITRELA' 	)
Endif
// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR' , 40 )
oView:CreateHorizontalBox( 'INFERIOR' , 60 )

// Cria Folder na view
oView:CreateFolder( 'PASTA_SUPERIOR' ,'SUPERIOR' )
oView:CreateFolder( 'PASTA_INFERIOR','INFERIOR' )

// Cria pastas nas folders
oView:AddSheet( 'PASTA_SUPERIOR'    , 'ABA_PROJETO'    , STR0026 ) //'Projeto'
oView:AddSheet( 'PASTA_SUPERIOR'    , 'ABA_ETAPA'      , STR0027 ) //'Etapa'
oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_ITEM_ETAPA' , STR0028 ) //'Item Etapa'
oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_CONF_CTB'   , STR0029 ) //'Configura็ใo Contแbil'

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'PROJETO'    , 100,,, 'PASTA_SUPERIOR', 'ABA_PROJETO' )
oView:CreateHorizontalBox( 'ETAPA'      , 100,,, 'PASTA_SUPERIOR', 'ABA_ETAPA' )
oView:CreateHorizontalBox( 'ITEM_ETAPA' , 100,,, 'PASTA_INFERIOR', 'ABA_ITEM_ETAPA' )
oView:CreateVerticalBox( 'CONF_CTB'   , 100,,, 'PASTA_INFERIOR', 'ABA_CONF_CTB' )
//BPI
IF lBpiAtf
	oView:CreateHorizontalBox( 'DADOS_CTB'  , 060,'CONF_CTB',, 'PASTA_INFERIOR', 'ABA_CONF_CTB' )
	oView:CreateHorizontalBox( 'ATF_RLZ'    , 040,'CONF_CTB',, 'PASTA_INFERIOR', 'ABA_CONF_CTB' )
Endif

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FNB', 'PROJETO'   )
oView:SetOwnerView( 'VIEW_FNC', 'ETAPA'     )
oView:SetOwnerView( 'VIEW_FND', 'ITEM_ETAPA')
oView:SetOwnerView( 'VIEW_FNE', 'CONF_CTB'  )
//BPI
IF lBpiAtf
	oView:SetOwnerView( 'VIEW_FNE', 'DADOS_CTB'  )
	oView:SetOwnerView( 'VIEW_FNJ', 'ATF_RLZ'    )
Endif

// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_FNB' )
oView:EnableTitleView( 'VIEW_FNC' )
oView:EnableTitleView( 'VIEW_FND' )
oView:EnableTitleView( 'VIEW_FNE' )
//BPI
IF lBpiAtf
	oView:EnableTitleView( 'VIEW_FNJ' )
Endif

If __nOper == 0 .Or. __nOper == OPER_COPIAR
	oView:AddUserButton( STR0069, 'FORM', {|oView| AF430ATAVP() } ) //'Calc. AVP'
	oView:AddUserButton( STR0136, 'PEDIDO', {|oView| AF430CPCTB() } ) //"Copia CTB"
EndIf

If __nOper == OPER_ENC_ETAPA
	oView:AddUserButton( STR0070, 'PCOIMG32', {|oView| EncerraETP() } )//'Enc. Etapa'
	oView:AddUserButton( STR0071, 'PEDIDO',   {|oView| EncerraItm() } )//'Enc. Item'
EndIf

If  __lBTNConfirma //__nOper == OPER_REVISAR .Or. __nOper == OPER_ATUALIZAR .Or. __nOper == OPER_ENC_PROJ .Or. __nOper == OPER_REVTX
	oView:AddUserButton( STR0125, 'OK', {|oView| A430ConfVs(oView) } )	//"Confirmar"
EndIf

//Setar o folder
oView:SetAfterViewActivate({|oView| F430SelFolder(oView)})

Return oView


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA430ConfVsบAutor  ณAlvaro Camillo Neto บ Data ณ  27/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Botใo de confirmar para opera็๕es de revisao,encerramento  บฑฑ
ฑฑบ          ณ e atualizar                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A430ConfVs(oView)
Local cMensagem := ""

If __nOper == OPER_REVISAR
	cMensagem := STR0046 // "Deseja gravar a opera็ใo, bloqueando a revisใo anterior e realizando a baixa das fichas atreladas ao projeto ? "
ElseIf __nOper == OPER_ATUALIZAR
	cMensagem := STR0054 //"Deseja atualizar o projeto, gerando as fichas do ativo vinculadas a ele ? "
ElseIf __nOper == OPER_ENC_PROJ
	cMensagem := STR0058 //"Deseja encerrar o projeto, realizando a baixa das fichas do ativo vinculadas a ele ? "
ElseIf __nOper == OPER_EFETREAL
	cMensagem := STR0158 //"Deseja efetivar a baixa de provisใo realizada para esse projeto?"
EndIf

If MsgNoYes(cMensagem)
	__lConfirmar := .T.
	oView:ButtonCancelAction()
EndIf

Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430POSVLบAutor  ณAlvaro Camillo Neto บ Data ณ  27/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ P๓s valida็ใo do modelo de dados                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430POSVL(oModel)
Local lRet 			:= .T.
Local nOperation 	:= oModel:GetOperation()
Local aSaveLines 	:= FWSaveRows()
Local oView	 		:= FWViewActive()

FWModelActive(oModel)

If nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_INSERT
	If lRet
		lRet := AF430VDTI(oModel)
	EndIf

	If lRet
		aCargaFNJ := {}
		lRet := A430VldTLin(oModel)
	EndIf

	If lRet
		A430AjtLin(@oModel)
	EndIf

ElseIf nOperation == MODEL_OPERATION_DELETE
	If oView != Nil
		lRet := MsgNoYes(STR0064)//"Deseja excluir o projeto do imobilizado?"
		If !lRet
			Help( " ", 1, "AF430CANC",, STR0178, 1, 0 ) // "Opera็ใo cancelada"
		EndIf
	EndIf
EndIf

FWRestRows(aSaveLines)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA430VldTLinบAutor ณAlvaro Camillo Neto บ Data ณ  05/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza todas as pos-valida็๕es de linha do modelo na      บฑฑ
ฑฑบ          ณ  p๓s valida็ใo da rotina                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A430VldTLin(oModel)
Local lRet			:= .T.
Local oModelFNC		:= oModel:GetModel("FNCDETAIL")
Local oModelFND		:= oModel:GetModel("FNDDETAIL")
Local oModelFNE		:= oModel:GetModel("FNEDETAIL")
Local oModelFNJ		:= oModel:GetModel("FNJDETAIL")
Local aSaveLines 	:= FWSaveRows()
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nJ			:= 0
Local lAvisaAVP		:= .T.

For nX := 1 To oModelFNC:Length()
	oModelFNC:GoLine( nX )
	For nY := 1 To oModelFND:Length()
		oModelFND:GoLine( nY )
		For nZ := 1 To oModelFNE:Length()
			oModelFNE:GoLine( nZ )
			If !oModelFNE:IsDeleted()
				lRet := FNELINPOS(oModelFNE)
			EndIf

			If lRet .And. !oModelFNE:IsDeleted() .And. !Empty(oModelFNE:GetValue("FNE_USRAVP")) .And. ( __nOper == 0 .Or. __nOper == OPER_COPIAR )
				If !Af430Blind() .And. lAvisaAVP
					lRet := MsgYesNo(STR0205) //"O valor de AVP planejado foi alterado, a taxa de desconto serแ calculada a partir do novo valor. Confirma a Opera็ใo?"
					lAvisaAVP := .F.
					If !lRet
						Help( " ", 1, "AF430CANC",, STR0178, 1, 0 ) // "Opera็ใo cancelada"
					Else
						lRet := AF430VNvTX()
					EndIf
				EndIf
			EndIf

			If lRet .and. __nOper == OPER_REALIZAR
				For nJ := 1 To oModelFNJ:Length()
					oModelFNJ:GoLine( nJ )
					If !oModelFNJ:IsDeleted()
						lRet := FNJLINPOS(oModelFNJ)

						//BPI
						If lRet
							lRet := Af430FnjI(oModel)
						Endif

					EndIf
					If !lRet
						Exit
					EndIf
				Next
			Endif

			If !lRet
				Exit
			EndIf
		Next nZ

		If !lRet
			Exit
		EndIf
	Next nY

	If !lRet
		Exit
	EndIf
Next nX

FWRestRows(aSaveLines)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA430AjtLinบAutor  ณAlvaro Camillo Neto บ Data ณ  05/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza o ajuste na numera็ใo das linhas e etapas, caso     บฑฑ
ฑฑบ          ณalguma linha seja excluํda                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A430AjtLin(oModel)
Local oModelFNC		:= oModel:GetModel("FNCDETAIL")
Local oModelFND		:= oModel:GetModel("FNDDETAIL")
Local oModelFNE		:= oModel:GetModel("FNEDETAIL")
Local oModelFNJ		:= oModel:GetModel("FNJDETAIL")
Local aSaveLines 	:= FWSaveRows()
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nJ			:= 0
Local cContFNC		:= ""
Local cContFND		:= ""
Local cContFNE		:= ""
Local cContFNJ		:= ""

cContFNC := StrZero(0,TamSx3('FNC_ETAPA')[1] )
For nX := 1 To oModelFNC:Length()

	oModelFNC:GoLine( nX )
	If !oModelFNC:IsDeleted()
		cContFNC := Soma1(cContFNC)
		oModelFNC:LoadValue( 'FNC_ETAPA' , cContFNC )
	EndIf

	cContFND := StrZero(0,TamSx3('FND_ITEM')[1] )
	For nY := 1 To oModelFND:Length()

		oModelFND:GoLine( nY )
		If !oModelFND:IsDeleted()
			cContFND := Soma1(cContFND)
			oModelFND:LoadValue( 'FND_ITEM' , cContFND )
		EndIf

		cContFNE := StrZero(0,TamSx3('FNE_LINHA')[1] )
		For nZ := 1 To oModelFNE:Length()

			oModelFNE:GoLine( nZ )
			If !oModelFNE:IsDeleted()
				cContFNE := Soma1(cContFNE)
				oModelFNE:LoadValue( 'FNE_LINHA' , cContFNE )
			EndIf

			If __nOper == OPER_REALIZAR
				cContFNJ := StrZero(0,TamSx3('FNJ_LINHA')[1] )
				For nJ := 1 To oModelFNJ:Length()

					oModelFNJ:GoLine( nJ )
					If !oModelFNJ:IsDeleted()
						cContFNJ := Soma1(cContFNJ)
						oModelFNJ:LoadValue( 'FNJ_LINHA' , cContFNJ )
					EndIf

				Next nJ
			Endif

		Next nZ

	Next nY
Next nX

FWRestRows(aSaveLines)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430GRVMDบAutor  ณAlvaro Camillo Neto บ Data ณ  27/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a grava็ใo do modelo de dados                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430GRVMD( oModel )
Local cCodPrj   := oModel:GetValue("FNBMASTER","FNB_CODPRJ")
Local cRev      := oModel:GetValue("FNBMASTER","FNB_REVIS ")


//Realiza a grava็ใo do Modelo
FWFormCommit( oModel )

If __nOper == OPER_BLOQUEAR
	AF430BLQGR(cCodPrj,cRev)
ElseIf __nOper == OPER_REVISAR
	//Altera o Status para Gerado
	AF430FLAG(cCodPrj,cRev,"0")
ElseIf  __nOper == OPER_COPIAR
	//Altera o Status para Gerado
	AF430CPRLZ(cCodPrj,cRev)
	//Altera o Status para Gerado
	AF430FLAG(cCodPrj,cRev,"0")

ElseIf __nOper == OPER_ENC_ETAPA
	// Verifica se todas as etapas e itens estใo encerrados
	If VerTdEnc(cCodPrj,cRev)
		AF430DTENC(cCodPrj,cRev,dDataBase)
	EndIf
	//Atualiza o flag dos campos
	AF430FLAG(cCodPrj,cRev,"1")
ElseIf __nOper == OPER_REVTX
	__lConfirmar := .T.
ElseIf __nOper == OPER_REALIZAR
	// Verifica de ha Itens em aberto
	if HasOpenFNJ(cCodPrj,cRev)
		//Altera o Status para Gerado
		AF430FLAG(cCodPrj,cRev,"A")
    else
		//Altera o Status para Ativo
		AF430FLAG(cCodPrj,cRev,"1")
	endif
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFNDLINPRE  บAutor  ณAlvaro Camillo Neto บ Data ณ  21/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pr้ valida็ใo de linha da grid FNDDetail                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FNDLINPRE(oModelFND,cAction)
Local lRet    := .T.
Local dEncerr := oModelFND:GetValue("FND_DTENCR")

If !Empty(dEncerr) .And. Alltrim(Upper(cAction)) == 'SETVALUE'
	Help( " ", 1, "AF430FNDLIN",, STR0144, 1, 0 ) //"Etapas encerradas nใo podem ser alteradas"
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFNEDLINPREบAutor  ณAlvaro Camillo Neto บ Data ณ  21/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pr้ valida็ใo de linha da grid FNEDetail                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FNELINPRE(oModelFND, cAction)
Local lRet    := .T.
Local oModel  := FWModelActive()
Local dEncerr := oModel:GetValue("FNDDETAIL","FND_DTENCR")

If !Empty(dEncerr) .And. Alltrim(Upper(cAction)) == 'SETVALUE'
	Help( " ", 1, "AF430FNELIN",, STR0144, 1, 0 ) //"Etapas encerradas nใo podem ser alteradas"
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFNELINPOS  บAutor  ณMicrosiga           บ Data ณ  10/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ P๓s valida็ใo de linha da entidade FNEDETAIL - Configuracaoบฑฑ
ฑฑบ          ณ contแbil do bem                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FNELINPOS(oModelFNE, cAction)
Local lRet 			:= .T.
Local oModel   		:= FWModelActive()
Local cTipoBem		:= oModelFNE:GetValue("FNE_TPATF")
Local nVlSalv		:= oModelFNE:GetValue("FNE_VLSALV")
Local nPerDepr		:= oModelFNE:GetValue("FNE_PERDEP")
Local nProEstim		:= oModelFNE:GetValue('FNE_PRDEST')
Local cCodInd		:= oModelFNE:GetValue('FNE_CODIND')
Local cTpDepr		:= oModelFNE:GetValue("FNE_TPDEPR")
Local nValMax 		:= oModelFNE:GetValue("FNE_VLMXDP")
Local cTpSald 		:= oModelFNE:GetValue("FNE_TPSALD")
Local nValAVPPLAN   := oModelFNE:GetValue("FNE_AVPPLN")
Local lLinAtiva     := !oModelFNE:IsDeleted()
Local aSaveLines    := FWSaveRows()
Local nX            := 0
Local nDepAcm		:= oModel:GetValue("FNEDETAIL","FNE_VRDACM")
Local nTaxa    		:= oModel:GetValue("FNEDETAIL","FNE_TAXA")
Local dInDepr    	:= oModel:GetValue("FNEDETAIL","FNE_DINDEP")
Local cCTrAtf	  	:= oModel:GetValue("FNDDETAIL","FND_CTRATF")
Local dUltDepr		:= SuperGetMv("MV_ULTDEPR",.F.,"01/01/80")

Local nLinFNE := oModelFNE:GetLine()

//--- Flag ativada pela rotina Static Function AF430CPCTB() - Copia das Configuracoes Contabeis (Copia CTB)
If __lCpyCtb
   Return lRet
EndIf

If lRet .And. lLinAtiva .And. cCTrAtf != '2'
	lRet := ATFSALDEPR(cTipoBem,cTpSald,cTpDepr)
EndIf

//Caso a linha seja do tipo de bem 03, somente poderแ haver uma ocorrencia
If lRet .And. lLinAtiva .And. cCTrAtf != '2'  .And. cTipoBem == "03" .And. oModelFNE:Length(.T.) > 1
	lRet := .F.
	Help( " ", 1, "AF430TP03",, STR0030, 1, 0 ) //"Caso o tipo do ativo seja 03 - Bem em forma็ใo, nใo ้ permitida outra linha de configura็ใo contabil "
EndIf

If lRet .And. lLinAtiva .And. cCTrAtf != '2'  .And. cTipoBem == '01'
	lRet := .T.
	For nX := 1 To oModelFNE:Length()
		oModelFNE:GoLine( nX )
		If !oModelFNE:IsDeleted() .And. nX != nLinFNE
			If oModelFNE:GetValue("FNE_TPATF") == "01"
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nX

	If !lRet
		Help( " ", 1, "AF430TP01",, STR0121, 1, 0 )//"Somente ้ possํvel incluir um tipo 01 - Deprecia็ใo fiscal "
	EndIf
	oModelFNE:GoLine( nLinFNE )
EndIf

If lRet .And. lLinAtiva .And. cCTrAtf != '2'  .And. cTpDepr == "6" .And. nPerDepr == 0
	HELP("",1,"AF010VDUTI")
	lRet := .F.
EndIf

If lRet .And. lLinAtiva .And. cCTrAtf != '2'  .And. cTpDepr == "2" .And. (nVlSalv == 0 .Or. nPerDepr == 0)
	HELP("",1,"AF010NOSAL")
	lRet := .F.
EndIf

If lRet .And. lLinAtiva .And. cCTrAtf != '2'  .And. cTpDepr == "3" .And. nPerDepr == 0
	HELP("",1,"AF010VDUTI")
	lRet := .F.
EndIf

If lRet .And. lLinAtiva .And. cCTrAtf != '2'  .And. cTpDepr $ "4|5|8|9|"  .And. ( nProEstim == 0)
	HELP("",1,"AF010FPROD")
	lRet := .F.
EndIf

If lRet .And. lLinAtiva .And. cCTrAtf != '2'  .And. cTpDepr == "7" .And. nValMax == 0
	HELP("",1,"AF010VMXD")//Para o calculo pelo m้todo Linear com valor maximo de depreciacao ้ obrigatorio o valor maximo de depreciacao
	lRet := .F.
EndIf

If lRet .And. lLinAtiva .And. cCTrAtf != '2'  .And. cTpDepr == "A" .And. Empty(cCodInd)
	HELP("",1,"AF430CODIN",,STR0176+CRLF+STR0177,1,0)//"Campo Ind.calculo nใo preenchido."###"Para o tipo de deprecia็ใo cแlculo por ํndice ้ necessแrio informar o c๓digo do ํndice."
	lRet := .F.
EndIf

If lRet .And. lLinAtiva .And. cCTrAtf != '2'  .And. cTpDepr == "A" .And. !Empty(nTaxa)
	HELP("",1,"AF430CODINTX",,STR0179+CRLF+STR0180,1,0)//"Campo Taxa preenchido.""###"Para o tipo de deprecia็ใo cแlculo por ํndice nใo deve ser informada a taxa de deprecia็ใo"
	lRet := .F.
EndIf

If cCTrAtf != '2' .And. dInDepr < dUltDepr .And. Empty(nDepAcm)
	Help(" ",1,"AF430DEPACM",,STR0033,1,0)//"Caso a data de inicio da etapa seja anterior a data do ultimo calculo de deprecia็ใo, o campo de valor de deprecia็ใo acumulada deve ser preenchido."
	lRet := .F.
EndIf


If Empty(nValAVPPLAN)
	oModelFNE:LoadValue( "FNE_USRAVP" , "" )
EndIf

FWRestRows(aSaveLines)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430VLModบAutor  ณAlvaro Camillo Neto บ Data ณ  10/26/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a valida็ใo do modelo de dados do MVC              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430VLMod(oModel)
Local nOperation := oModel:GetOperation()
Local lRet := .T.

If lRet .And. (nOperation == MODEL_OPERATION_UPDATE ) .And. FNB->FNB_STATUS != "0" .AND. __nOper == 0
	Help(" ",1,"AF430STAALT",,STR0034 ,1,0)//"Projeto jแ possui fichas do ativo geradas. Para alterar o projeto, por favor utilizar a op็ใo de revisใo"
	lRet := .F.
EndIf

If lRet .And. (nOperation == MODEL_OPERATION_DELETE ) .And. FNB->FNB_STATUS != "0" .AND. __nOper == 0
	Help(" ",1,"AF430STADEL",,STR0035 ,1,0)//"Projeto jแ possui fichas do ativo geradas. Por favor, utilizar a op็ใo de bloqueio ou revisใo"
	lRet := .F.
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430StructบAutor  ณAlvaro Camillo Neto บ Data ณ  26/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a estrutura do modelo com o tratamento das opera็๕esฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430Struct(cAlias)
Local oStruct 	:= FWFormStruct( 1, cAlias, /*bAvalCampo*/, /*lViewUsado*/ )
Local aFields	:= {}
Local nX		:= 0
Local cPrefix	:= PrefixoCpo(cAlias)
Local cCampoBlq := cPrefix+'_MSBLQL'
Local cCampoAVP := cPrefix+'_INDAVP'
Local cCpoDtAvp := cPrefix+'_DTPROV'
Local cCpoDtExe := cPrefix+'_PRVEXC'

If __nOper == OPER_BLOQUEAR
	// Bloqueia todos os campos menos do bloqueio
	oStruct:SetProperty( '*' , MODEL_FIELD_WHEN , {|| .F. } )
	If  (cAlias)->(FieldPos(cCampoBlq)) > 0
		oStruct:SetProperty(cCampoBlq , MODEL_FIELD_WHEN , {|| .T. } )
	EndIf
ElseIf __nOper == OPER_ENC_ETAPA
	// Bloqueia todos os campos menos do bloqueio
	oStruct:SetProperty( '*' , MODEL_FIELD_WHEN , {|| .F. } )
ElseIf __nOper == OPER_REVISAR
	If cAlias == "FNB"
		oStruct:SetProperty("FNB_CODPRJ" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FNB_REVIS"  , MODEL_FIELD_WHEN , {|| .F. } )
	EndIf
ElseIf __nOper == OPER_REVTX

	oStruct:SetProperty('*' , MODEL_FIELD_WHEN , {|| .F. } )
	If  (cAlias)->(FieldPos(cCampoAVP)) > 0
		oStruct:SetProperty(cCampoAVP , MODEL_FIELD_WHEN , {|| .T. } )
	EndIf

	If  (cAlias)->(FieldPos(cCpoDtAvp)) > 0
		oStruct:SetProperty(cCpoDtAvp , MODEL_FIELD_WHEN , {|| .T. } )
	EndIf

	If  (cAlias)->(FieldPos(cCpoDtExe)) > 0
		oStruct:SetProperty(cCpoDtExe , MODEL_FIELD_WHEN , {|| .T. } )
	EndIf

ElseIf __nOper == OPER_REALIZAR

	oStruct:SetProperty('*' , MODEL_FIELD_WHEN , {|| .F. } )

	If cAlias == "FNJ"
		oStruct:SetProperty('FNJ_CBAEXE' , MODEL_FIELD_WHEN , {|| .T. } )
		oStruct:SetProperty('FNJ_ITEXE'  , MODEL_FIELD_WHEN , {|| .T. } )
		oStruct:SetProperty('FNJ_TAFEXE' , MODEL_FIELD_WHEN , {|| .T. } )
		oStruct:SetProperty('FNJ_SLDEXE' , MODEL_FIELD_WHEN , {|| .T. } )
	Endif

EndIf
//RETIRADA DO INICIALIZADOR PADRAO DO CAMPO FND_TPAVP. ESTE CAMPO DEVE SER INICIALIZADO COM O VALOR DO CAMPO
//AFC_TPAVP
If cAlias == "FND"
	oStruct:SetProperty( "FND_TPAVP"  	, MODEL_FIELD_INIT, {|| AF430RTAVP("FND") }  )
Endif

If cAlias == "FNC"
	oStruct:SetProperty( "FNC_TPAVP"  	, MODEL_FIELD_INIT, {|| AF430RTAVP("FNC") }  )
Endif


//Cria็ใo de Gatilho
// [01] Id do campo de origem
// [02] Id do campo de destino
// [03] Bloco de codigo de valida็ใo da execu็ใo do gatilho
// [04] Bloco de codigo de execu็ใo do gatilho

If cAlias == "FNB"
	oStruct:AddTrigger( "FNB_TIPO"  	, "FNB_TIPO"  		, {|| .T. }  , {|| AF430GAT(cAlias,"FNB_TIPO","FNE_TPCLAS") }  )
	oStruct:AddTrigger( "FNB_SBTIPO"  	, "FNB_SBTIPO"  	, {|| .T. }  , {|| AF430GAT(cAlias,"FNB_SBTIPO") }  )
	oStruct:AddTrigger( "FNB_INDAVP"  	, "FNB_INDAVP"  	, {|| .T. }  , {|| AF430GAT(cAlias,"FNB_INDAVP") }  )
	oStruct:AddTrigger( "FNB_DTPROV"  	, "FNB_DTPROV"  	, {|| .T. }  , {|| AF430GAT(cAlias,"FNB_DTPROV") }  )
	oStruct:AddTrigger( "FNB_PRVEXC"  	, "FNB_PRVEXC"  	, {|| .T. }  , {|| AF430GAT(cAlias,"FNB_PRVEXC")  }  )
	oStruct:AddTrigger( "FNB_MOEDA"  	, "FNB_MOEDA"  	    , {|| .T. }  , {|| AF430GMD() }  )
	oStruct:AddTrigger( "FNB_MSBLQL"  	, "FNB_MSBLQL"  	, {|| .T. }  , {|| AF430GAT(cAlias,"FNB_MSBLQL")  }  )
	oStruct:AddTrigger( "FNB_TPAVP"  	, "FNB_TPAVP"    	, {|| .T. }  , {|| AF430GAT(cAlias,"FNB_TPAVP" )  }  )
ElseIf cAlias == "FNC"
	oStruct:AddTrigger( "FNC_TIPO"  	, "FNC_TIPO"  		, {|| .T. }  , {|| AF430GAT(cAlias,"FNC_TIPO","FNE_TPCLAS") }  )
	oStruct:AddTrigger( "FNC_SBTIPO"  	, "FNC_SBTIPO"  	, {|| .T. }  , {|| AF430GAT(cAlias,"FNC_SBTIPO") }  )
	oStruct:AddTrigger( "FNC_INDAVP"  	, "FNC_INDAVP"  	, {|| .T. }  , {|| AF430GAT(cAlias,"FNC_INDAVP") }  )
	oStruct:AddTrigger( "FNC_DTPROV"  	, "FNC_DTPROV"  	, {|| .T. }  , {|| AF430GAT(cAlias,"FNC_DTPROV") }  )
	oStruct:AddTrigger( "FNC_PRVEXC"  	, "FNC_PRVEXC"  	, {|| .T. }  , {|| AF430GAT(cAlias,"FNC_PRVEXC")  }  )
	oStruct:AddTrigger( "FNC_MSBLQL"  	, "FNC_MSBLQL"  	, {|| .T. }  , {|| AF430GAT(cAlias,"FNC_MSBLQL")  }  )
	oStruct:AddTrigger( "FNC_TPAVP"  	, "FNC_TPAVP"   	, {|| .T. }  , {|| AF430GAT(cAlias,"FNC_TPAVP")  }  )

ElseIf cAlias == "FND"
	oStruct:AddTrigger( "FND_PERINI"  	, "FND_PERFIM"  	, {|| .T. }  , {|| AF430GDTI() }  )
	oStruct:AddTrigger( "FND_PERFIM"  	, "FND_PRVEXC"  	, {|| .T. }  , {|| AF430GDTF() }  )
	If __nOper != OPER_REVTX
		oStruct:AddTrigger( "FND_PRVEXC"  	, "FND_PRVEXC"  	, {|| .T. }  , {|| AF430GDIN() }  )
		oStruct:AddTrigger( "FND_DTPROV"  	, "FND_DTPROV"  	, {|| .T. }  , {|| AF430GDIN() }  )
	EndIf
	oStruct:AddTrigger( "FND_VLRPLN"  	, "FND_VLRPLN"  	, {|| .T. }  , {|| AF430GPLN() }  )
	oStruct:AddTrigger( "FND_DSCITE"  	, "FND_DSCITE"  	, {|| .T. }  , {|| AF430GDSIt() }  )

	If __nOper == 0
		oStruct:AddTrigger( "FND_INDAVP" , "FND_INDAVP"  , {|| .T. }  , {|| AF430GINDV() }  )
		oStruct:AddTrigger( "FND_TPAVP"  , "FND_TPAVP"  , {|| .T. }  ,  {|| AF430GTIPV() }  )
	EndIf

ElseIf cAlias == "FNE"

	oStruct:SetProperty('FNE_AVPRLZ'  , MODEL_FIELD_WHEN , {|| AF430AVPW() } )
	oStruct:SetProperty('FNE_AVPPLN'  , MODEL_FIELD_WHEN , {|| AF430AVPW() } )

	oStruct:AddTrigger( "FNE_GRPBEM"  , "FNE_GRPBEM"  	, {|| .T. }  , {|| AF430GGRP()  }  )
	oStruct:AddTrigger( "FNE_PERDEP"  , "FNE_TAXA"  		, {|| .T. }  , {|| AF430GTDPR() }  )
	oStruct:AddTrigger( "FNE_TAXA"    , "FNE_PERDEP"  	, {|| .T. }  , {|| AF430GPDR()  }  )
	oStruct:AddTrigger( "FNE_TPATF"   , 'FNE_DINDEP'  	, {|| .T. }  , {|| AF430GTPIN()  }  )
	oStruct:AddTrigger( "FNE_TPDEPR"  , 'FNE_TPDEPR'  	, {|| .T. }  , {|| AF430GTTDP()  } )


	oStruct:AddTrigger( "FNE_TPATF"   , 'FNE_AVPPLN'  	, {|| AF430AVPW() }  , {|| 0  }  )
	oStruct:AddTrigger( "FNE_TPATF"   , 'FNE_AVPRLZ'  	, {|| AF430AVPW() }  , {|| 0  }  )
	oStruct:AddTrigger( "FNE_VRDACM"  , 'FNE_AVPPLN'  	, {|| AF430AVPW() }  , {|| 0  }  )
	oStruct:AddTrigger( "FNE_VRDACM"  , 'FNE_AVPRLZ'  	, {|| AF430AVPW() }  , {|| 0  }  )
	oStruct:AddTrigger( "FNE_VORIG"   , 'FNE_VRDACM'  	, {|| AF430AVPW() }  , {|| 0  }  )
	oStruct:AddTrigger( "FNE_VORIG"   , 'FNE_AVPPLN'  	, {|| AF430AVPW() }  , {|| 0  }  )
	oStruct:AddTrigger( "FNE_AVPPLN"  , 'FNE_AVPRLZ'  	, {|| AF430AVPW() }  , {|| 0  }  )
	oStruct:AddTrigger( "FNE_AVPPLN"  , 'FNE_AVPRLZ'  	, {|| .T. }  , {|| 0  }  )

	oStruct:AddTrigger( "FNE_AVPPLN"  , 'FNE_AVPPLN'  	, {|| .T. }  , {|| AF430GTUSR()  } )

	oStruct:AddTrigger( "FNE_TPATF"   , 'FNE_USRAVP'  	, {|| .T. }  , {|| ""  }  )
	oStruct:AddTrigger( "FNE_VRDACM"  , 'FNE_USRAVP'  	, {|| .T. }  , {|| "" }  )
	oStruct:AddTrigger( "FNE_VORIG"   , 'FNE_USRAVP'  	, {|| .T. }  , {|| ""  }  )


ElseIf cAlias == "FNJ"
	oStruct:AddTrigger( "FNJ_SLDEXE"  , "FNJ_SLDEXE"  	, {|| .T. }  , {|| AF430GSldE()  }  )
EndIf

Return oStruct


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430ATAVPบAutor  ณAlvaro Camillo Neto บ Data ณ  26/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza os valores do AVP planejado das etapas            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430ATAVP()
Local lRet        := .T.
Local oModel      := FWModelActive()
Local oModelFND   := oModel:GetModel("FNDDETAIL")
Local oModelFNE   := oModel:GetModel("FNEDETAIL")
Local aSaveLines  := FWSaveRows()
Local nOperation  := oModel:GetOperation()
Local nX          := 0
Local nY          := 0
Local cCodInd
Local nValItem
Local dDataIni
Local nValAVP
Local dPrevista
Local cTipoAVP
Local cTypes10	:= IIF(lIsRussia,"|" + AtfNValMod({1}, "|"),"") // CAZARINI - 27/03/2017 - If is Russia, add new valuations models - main models

If MsgYesNo(STR0206) //"Deseja simular o valor de AVP planejado para as etapas?"
	If (nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_INSERT)

		//Carrega tabela FND
		For nX := 1 To oModelFND:Length()
			oModelFND:GoLine( nX )
			If !oModelFND:IsDeleted()
				cCodInd    := oModelFND:GetValue('FND_INDAVP')
				dDataIni   := oModelFND:GetValue('FND_DTPROV')
				dPrevista  := oModelFND:GetValue('FND_PRVEXC')
				cTipoAVP   := oModelFND:GetValue('FND_TPAVP')

				For nY := 1 to oModelFNE:Length()
					oModelFNE:GoLine( nY )
					If cTipoAVP == '2'
						nValItem := oModelFNE:GetValue('FNE_VRDACM')
					Else
						nValItem := oModelFND:GetValue('FND_VLRPLN')
					EndIf

					If oModelFNE:GetValue('FNE_TPATF') $ ('10' + cTypes10) // Apenas Gerencial
						nValAVP := 0
						AFCalcAVP("C",,cCodInd,nValItem,,dDataIni,,@nValAVP,dPrevista)
						lRet := oModelFNE:LoadValue( "FNE_AVPPLN" , nValAVP )

						//Limpa o flag pois o sistema irแ calcular o AVP de acordo com a taxa
						lRet := oModelFNE:LoadValue( "FNE_USRAVP" , "" )
					EndIf
				Next nY

			EndIf

			If !lRet
				Exit
			EndIf
		Next

	Else
		Help(" ",1,"AF430AVP1",,STR0072,1,0)//"Op็ใo disponํvel apenas para Inclusใo e Altera็ใo"
	EndIf
EndIf


FWRestRows(aSaveLines)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEncerraETPบAutor  ณAlvaro Camillo Neto บ Data ณ  11/21/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca as etapas e os itens para serem encerrados            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EncerraETP()
Local lRet 			:= .T.
Local oModel   	:= FWModelActive()
Local oModelFNC	:= oModel:GetModel("FNCDETAIL")
Local oModelFND	:= oModel:GetModel("FNDDETAIL")
Local aSaveLines	:= FWSaveRows()
Local nX				:= 0
Local dData			:= dDataBase
Local aArea       := GetArea()
Local aAreaFNC    := FNC->(GetArea())
Local cProj			:= oModelFNC:GetValue('FNC_CODPRJ')
Local cRev			:= oModelFNC:GetValue('FNC_REVIS')
Local cEtapa		:= oModelFNC:GetValue('FNC_ETAPA')


FNC->(dbSetOrder(1)) //FNC_FILIAL+FNC_CODPRJ+FNC_REVIS+FNC_ETAPA

If FNC->(MsSeek(xFilial("FNC") + cProj + cRev + cEtapa))
	If !Empty(FNC->FNC_DTENCR)
		Help(" ",1,"AF430ENCFNC",,STR0073,1,0)//"Etapa jแ encerrada."
		lRet := .F.
	EndIf
EndIf

If lRet
	If Empty(oModelFNC:GetValue( "FNC_DTENCR" ))
		dData := dDataBase
	Else
		dData := CTOD("")
	EndIf

	oModelFNC:LoadValue( "FNC_DTENCR" , dData )
	For nX := 1 To oModelFND:Length()
		oModelFND:GoLine( nX )
		oModelFND:LoadValue( "FND_DTENCR" , dData )
	Next

EndIf

FWRestRows(aSaveLines)
RestArea(aAreaFNC)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEncerraItmบAutor  ณAlvaro Camillo Neto บ Data ณ  11/21/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca o item para ser encerrado                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EncerraItm()

Local lRet 			:= .T.
Local oModel   	:= FWModelActive()
Local oModelFNC	:= oModel:GetModel("FNCDETAIL")
Local oModelFND	:= oModel:GetModel("FNDDETAIL")
Local aSaveLines	:= FWSaveRows()
Local dData			:= dDataBase
Local aArea       := GetArea()
Local aAreaFND    := FND->(GetArea())
Local nContMk	  := 0
Local nX		  := 0

Local cProj			:= oModelFND:GetValue('FND_CODPRJ')
Local cRev			:= oModelFND:GetValue('FND_REVIS')
Local cEtapa		:= oModelFND:GetValue('FND_ETAPA')
Local cItem 		:= oModelFND:GetValue('FND_ITEM')


FND->(dbSetOrder(1)) //FND_FILIAL+FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM

If lRet .And. FND->(MsSeek(xFilial("FND") + cProj + cRev + cEtapa + cItem))
	If !Empty(FND->FND_DTENCR)
		Help(" ",1,"AF430ENCFND",,STR0074,1,0)//"Item jแ encerrado."
		lRet := .F.
	EndIf
EndIf

If lRet
	If Empty(oModelFND:GetValue( "FND_DTENCR" ))
		dData := dDataBase
	Else
		dData := CTOD("")
	EndIf
	oModelFND:LoadValue( "FND_DTENCR" , dData )
EndIf

// Verifica se todas as etapas foram marcadas/ desmarcadas e marca a etapa
If lRet
	For nX := 1 To oModelFND:Length()
		oModelFND:GoLine( nX )
		If !Empty(oModelFND:GetValue( "FND_DTENCR" ))
			nContMk++
		EndIf
	Next

	If nContMk == oModelFND:Length()
		oModelFNC:LoadValue("FNC_DTENCR", dDataBase )
	Else
		oModelFNC:LoadValue("FNC_DTENCR", CTOD("") )
	EndIf

EndIf

FWRestRows(aSaveLines)
RestArea(aAreaFND)
RestArea(aArea)

Return

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ ๐ แฟ
//ณValida็๕es de campos e gatilhosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ ๐ แู
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430AVTIPบAutor  ณAlvaro Camillo Neto บ Data ณ  04/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o campo tipo de saldo FNE_TPDEPR                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430AVTIP()
Local lRet 	   		:= .T.
Local oModel   		:= FWModelActive()
Local oModelFNE		:= oModel:GetModel("FNEDETAIL")
Local cTipoBem		:= oModelFNE:GetValue("FNE_TPATF")
Local cTpDepr		:= oModelFNE:GetValue("FNE_TPDEPR")
Local cTpSald 		:= oModelFNE:GetValue("FNE_TPSALD")
Local cCTrAtf	  	:= oModel:GetValue("FNDDETAIL","FND_CTRATF")

If cCTrAtf != '2'
	lRet := ATFSALDEPR(cTipoBem,cTpSald,cTpDepr)
EndIf

Return lRet

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430GGRPณ Autor ณAlvaro Camillo Neto    ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Gatilho para atualiza็ใo dos campos da grid do FNE         ณฑฑ
ฑฑณ          ณcom base nas informa็๕es do SNG ou FNG para o               ณฑฑ
ฑฑณ          ณtipo do bem e saldo configurados.                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430GGRP()
Local lRet 		:= .T.
Local oModel   := FWModelActive()
Local oView		:= FWViewActive()
Local cMoeda	:= oModel:GetValue("FNBMASTER","FNB_MOEDA")
Local oModelFNE:= oModel:GetModel("FNEDETAIL")
Local nX       := 0
Local nY       := 0
Local cGrupo	:= oModelFNE:GetValue("FNE_GRPBEM")
Local aCampos	:= {}
Local aArea 	:= GetArea()
Local aSaveLines  := FWSaveRows()

aAdd(aCampos,{"NG_CCONTAB","FNE_ENT01B"})
aAdd(aCampos,{"NG_CUSTBEM","FNE_ENT02B"})
aAdd(aCampos,{"NG_SUBCCON","FNE_ENT03B"})
aAdd(aCampos,{"NG_CLVLCON","FNE_ENT04B"})
aAdd(aCampos,{"NG_CDEPREC","FNE_ENT01D"})
aAdd(aCampos,{"NG_CCDESP" ,"FNE_ENT02D"})
aAdd(aCampos,{"NG_SUBCDEP","FNE_ENT03D"})
aAdd(aCampos,{"NG_CLVLDEP","FNE_ENT04D"})
aAdd(aCampos,{"NG_CCDEPR" ,"FNE_ENT01A"})
aAdd(aCampos,{"NG_CCCDEP" ,"FNE_ENT02A"})
aAdd(aCampos,{"NG_SUBCCDE","FNE_ENT03A"})
aAdd(aCampos,{"NG_CLVLCDE","FNE_ENT04A"})
If Val(cMoeda) > 9
	aAdd(aCampos,{"NG_TXDEP"+cValToChar(Val(cMoeda)),"FNE_TAXA"})
Else
	aAdd(aCampos,{"NG_TXDEPR"+cValToChar(Val(cMoeda)),"FNE_TAXA"})
EndIf

SNG->(dbSetOrder(1))
If SNG->(MsSeek( xFilial("SNG") + cGrupo ))
	For nY := 1 to oModelFNE:Length()
		oModelFNE:GoLine(nY)
		oModelFNE:LoadValue( "FNE_GRPBEM" , cGrupo )
		cTipoDep := oModelFNE:GetValue("FNE_TPDEPR")
		For nX := 1 to Len(aCampos)
			If !Empty(SNG->&(aCampos[nX][1]))
				If !(cTipoDep $ '1/7') .And. Alltrim(aCampos[nX][2]) == 'FNE_TAXA'
					Loop
				EndIf

				lRet := oModelFNE:SetValue( aCampos[nX][2] , SNG->&(aCampos[nX][1]) )
				If !lRet
					Exit
				EndIf
			EndIf
		Next nX

	Next nY
EndIf

FWRestRows(aSaveLines)

RestArea(aArea)
Return cGrupo

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430GAT  ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Gatilho para atualizacao dos campos FNC_TIPO na Etapa e nosณฑฑ
ฑฑณ          ณ itens de etapa do projeto que nใo estiverem preenchidos    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430GAT(cTabela,cCampo,cCpoFNE)
Local lRet 		:= .T.
Local oModel    := FWModelActive()
Local oView     := FWViewActive()
Local xRet      := ""
Local oModelFNC := oModel:GetModel("FNCDETAIL")
Local oModelFND := oModel:GetModel("FNDDETAIL")
Local oModelFNE := oModel:GetModel("FNEDETAIL")
Local aSaveLines:= FWSaveRows()
Local nX        := 0
Local nAt       := At("_",cCampo)
Local cPosFix   := SubStr(cCampo,nAt, Len(cCampo) )
Local cCpoAux   := ""

Default cCpoFNE := ""

//Carrega tabela FNC
If "FNB" $ cTabela
	cCpoAux := "FNB" +cPosFix
	xRet := oModel:GetValue("FNBMASTER",cCpoAux)
	For nX := 1 To oModelFNC:Length()
		cCpoAux := "FNC" +cPosFix
		oModelFNC:GoLine( nX )
		If !oModelFNC:IsDeleted()
			lRet := oModelFNC:SetValue( cCpoAux , xRet )
		EndIf
		If !lRet
			Exit
		EndIf
	Next
Else
	cCpoAux := "FNC" +cPosFix
	If FNC->(FieldPos(cCpoAux)) > 0
		xRet := oModel:GetValue("FNCDETAIL",cCpoAux)
	ENdIf
EndIf

//Carrega tabela FND
For nX := 1 To oModelFND:Length()
	cCpoAux := "FND" +cPosFix
	If FND->(FieldPos(cCpoAux)) > 0
		oModelFND:GoLine( nX )
		If !oModelFND:IsDeleted()
			lRet := oModelFND:SetValue( cCpoAux , xRet )
		EndIf
		If !lRet
			Exit
		EndIf
	EndIf
Next

//Carrega tabela FNE
For nX := 1 To oModelFNE:Length()
	oModelFNE:GoLine( nX )
	If !oModelFNE:IsDeleted()
		If !Empty(cCpoFNE)
			If FNE->(FieldPos(cCpoFNE)) > 0
				lRet := oModelFNE:SetValue( cCpoFNE , xRet )
			EndIf
		Else
			cCpoAux := "FNE" +cPosFix
			If FNE->(FieldPos(cCpoAux)) > 0
				lRet := oModelFNE:SetValue( cCpoAux  , xRet )
			EndIf
		EndIf
	EndIf
	If !lRet
		Exit
	EndIf
Next

FWRestRows(aSaveLines)

Return xRet

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430GDINณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Gatilho para atualizacao do campo FNE_DINDEP
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430GDIN()
Local lRet        := .T.
Local oModel      := FWModelActive()
Local oModelFNE   := oModel:GetModel("FNEDETAIL")
Local cCampo      := ReadVar()
Local dDataCpo    := &(cCampo)
Local dInDepr     := CTOD("")
Local cTipo       := ""
Local dDataExec   := oModel:GetValue("FNDDETAIL","FND_PRVEXC")
Local dDataProv   := oModel:GetValue("FNDDETAIL","FND_DTPROV")
Local aSaveLines  := FWSaveRows()
Local nX          := 0
Local oView       := FWViewActive()

For nX := 1 To oModelFNE:Length()
	oModelFNE:GoLine( nX )
	cTipo    := oModelFNE:GetValue("FNE_TPATF")
	dInDepr := AF430DINDP(cTipo,dDataProv,dDataExec)
	If !oModelFNE:IsDeleted()
		lRet := oModelFNE:SetValue( 'FNE_DINDEP' , dInDepr )
	EndIf
	If !lRet
		Exit
	EndIf
Next

FWRestRows(aSaveLines)

Return dDataCpo

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430GINDVณ Autor ณAlvaro Camillo Neto   ณ Data ณ 18/03/13 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Gatilho para atualizacao do campo de AVP Planejado caso o
ฑฑณDescricao ณ o indice seja branco
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430GINDV()
Local oModel    := FWModelActive()
Local oModelFNE := oModel:GetModel("FNEDETAIL")
Local cIndice   := oModel:GetValue("FNDDETAIL","FND_INDAVP")

Local aSaveLines    := FWSaveRows()
Local nX			  := 0
Local oView   	  := FWViewActive()

For nX := 1 To oModelFNE:Length()
	oModelFNE:GoLine( nX )
	If !oModelFNE:IsDeleted() .And. Empty(cIndice)
		oModelFNE:LoadValue( 'FNE_AVPPLN' , 0 )
		oModelFNE:LoadValue( 'FNE_AVPRLZ' , 0 )
		oModelFNE:LoadValue( 'FNE_USRAVP' , "" )

	EndIf
Next

FWRestRows(aSaveLines)

Return cIndice

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430GTIPVณ Autor ณAlvaro Camillo Neto   ณ Data ณ 18/03/13 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Gatilho para atualizacao do campo de AVP Planejado caso o
ฑฑณDescricao ณ tipo de avp seja alterado
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430GTIPV()
Local oModel    := FWModelActive()
Local oModelFNE := oModel:GetModel("FNEDETAIL")
Local cTipo     := oModel:GetValue("FNDDETAIL","FND_TPAVP")

Local aSaveLines    := FWSaveRows()
Local nX			  := 0
Local oView   	  := FWViewActive()

For nX := 1 To oModelFNE:Length()
	oModelFNE:GoLine( nX )
	If !oModelFNE:IsDeleted()
		oModelFNE:LoadValue( 'FNE_AVPPLN' , 0 )
		oModelFNE:LoadValue( 'FNE_AVPRLZ' , 0 )
		oModelFNE:LoadValue( 'FNE_USRAVP' , "" )
	EndIf

Next

FWRestRows(aSaveLines)

Return cTipo



/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430GTTDPณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Gatilho para atualizacao do campo FNE_TPDEPR
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430GTTDP()
Local oModel        := FWModelActive()
Local oModelFNE     := oModel:GetModel("FNEDETAIL")
Local cCampo        := ReadVar()
Local cTipDepr      := &(cCampo)
Local oView   	  := FWViewActive()

oModelFNE:LoadValue( 'FNE_PERDEP', 0 )
oModelFNE:LoadValue( 'FNE_TAXA'  , 0 )
oModelFNE:LoadValue( 'FNE_VLMXDP', 0 )
oModelFNE:LoadValue( 'FNE_VLSALV', 0 )
oModelFNE:LoadValue( 'FNE_PRDEST', 0 )
oModelFNE:LoadValue( 'FNE_CODIND', '' )

Return cTipDepr

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430GTUSRณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Gatilho para atualizacao do campo de usuario alteracao AVP
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430GTUSR()
Local oModel        := FWModelActive()
Local oModelFNE     := oModel:GetModel("FNEDETAIL")
Local nValPlan      := oModelFNE:GetValue("FNE_AVPPLN")
Local oView   	  := FWViewActive()

If nValPlan > 0
	lRet := oModelFNE:LoadValue( "FNE_USRAVP" , __cUserId   )
Else
	lRet := oModelFNE:LoadValue( "FNE_USRAVP" , "" )
EndIf

Return nValPlan




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430GTPINบAutor  ณAlvaro Camillo Neto บ Data ณ  29/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gatilho para o campo de data de inicio de depreciacao      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430GTPIN()
Local oModel   		:= FWModelActive()
Local dInDepr		:= CTOD("")
Local cTipo			:= oModel:GetValue("FNEDETAIL","FNE_TPATF")
Local dDataExec		:= oModel:GetValue("FNDDETAIL","FND_PRVEXC")
Local dDataProv     := oModel:GetValue("FNDDETAIL","FND_DTPROV")

dInDepr := AF430DINDP(cTipo,dDataProv,dDataExec)

Return dInDepr


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430GMD   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Valida o preenchimento da moeda em fun็ใo do conte๚do dos
ฑฑณ          ณ parโmetros MV_ATFMOED e MV_ATFMDMX, de forma que o valor
ฑฑณ          ณ informado nos campos de configura็ใo contแbil Valor Mแximo
ฑฑณ          ณ de Deprecia็ใo e Valor de Salvamento sejam vแlidos de acordo
ฑฑณ          ณ com as configura็๕es do sistema.Valida o preenchimento da
ฑฑณ          ณ moeda em funcao                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430GMD()
Local lRet 			:= .T.
Local oModel   		:= FWModelActive()
Local oView     	:= FWViewActive()
Local oModelFNE		:= oModel:GetModel("FNEDETAIL")
Local aSaveLines  	:= FWSaveRows()
Local nX			:= 0
Local cMoedaFNB		:= M->FNB_MOEDA

//Carrega tabela FNE
For nX := 1 To oModelFNE:Length()
	oModelFNE:GoLine( nX )
	If !oModelFNE:IsDeleted()
		lRet := oModelFNE:SetValue( "FNE_MOEDRF" , cMoedaFNB )
	EndIf
	If !lRet
		Exit
	EndIf
Next

FWRestRows(aSaveLines)

Return cMoedaFNB


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430VMDRF บAutor  ณAlvaro Camillo Neto บ Data ณ  24/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a moeda na linha da configuracao contแbil tabela FNE บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430VMDRF()
Local lRet 			:= .T.
Local oModel   	:= FWModelActive()
Local oModelFNE  	:= oModel:GetModel("FNEDETAIL")
Local cTpDepr		:= Alltrim(oModelFNE:GetValue("FNE_TPDEPR"))
Local cMoeda		:= oModelFNE:GetValue("FNE_MOEDRF")
Local cCTrAtf	  	:= oModel:GetValue("FNDDETAIL","FND_CTRATF")

Local cMoedaAtf	:= SuperGetMv("MV_ATFMOED",.F.,"1")
Local cMoedaMax	:= SuperGetMv("MV_ATFMDMX",.F.,"1")

If cCTrAtf != '2'
	cMoedaAtf	:= IIF(Empty(cMoedaAtf),"1",cMoedaAtf)
	cMoedaMax	:= IIF(Empty(cMoedaMax),"1",cMoedaMax)

	//Se o tipo de depreciacao for reducao dos saldos, a moeda deve ser igual a moeda do ativo
	If lRet .And. cTpDepr == "2" .And. Val(cMoeda) != Val(cMoedaAtf)
		Help(    ,  , "AF430MOEATF",, STR0038, 1, 0 )//"Para o tipo de depreciacao redu็ใo de saldo, a moeda do projeto deve ser igual a parametrizada no parametro MV_ATFMOED"
		lRet := .F.
	EndIf

	//Se o tipo de depreciacao for valor mแximo de depreciaco, a moeda deve ser igual a moeda do valor mแximo de deprecia็ใo
	If lRet .And. cTpDepr == "2" .And. Val(cMoeda) != Val(cMoedaAtf)
		Help(    ,  , "AF430MOEMAX",, STR0039, 1, 0 )//"Para o tipo de depreciacao valor mแximo, a moeda do projeto deve ser igual a parametrizada no parametro MV_ATFMDMX"
		lRet := .F.
	EndIf
EndIf

Return lRet
/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430RTP   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Inicializador padrใo do campo de acordo com o conte๚do dos ณฑฑ
ฑฑณ			 ณ campos FNB_TIPO do cabe็alho do projeto e FNC_TIPO da etapaณฑฑ
ฑฑณ			 ณ do projeto.												  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430RTP()

Local oModel   		:= FWModelActive()
Local cTipoClass	:= ""
Local cCampo		:= ReadVar()

If "FNC" $ cCampo
	cTipoClass	:= oModel:GetValue("FNBMASTER","FNB_TIPO")
ElseIf "FND" $ cCampo
	cTipoClass	:= oModel:GetValue("FNCDETAIL","FNC_TIPO")
Else
	cTipoClass	:= oModel:GetValue("FNDDETAIL","FND_TIPO")
EndIf

Return cTipoClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA430IItVirบAutor  ณAlvaro Camillo Neto บ Data ณ  15/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A430IItVir()
Local oModel   		:= FWModelActive()
Local cItem         := oModel:GetValue("FNDDETAIL","FND_ITEM")

cItem := IIF(Empty(cItem),"001",cItem)

Return cItem


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430RSTP   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Inicializador padrใo do campo de acordo com o conte๚do dos
campos FNB_SBTIPO do cabe็alho do projeto e FNC_SBTIPO
da etapa do projeto.
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430RSTP()
Local oModel   		:= FWModelActive()
Local cSubTipo 		:= ""
Local cCampo		:= ReadVar()

If "FNC" $ cCampo
	cSubTipo	:= oModel:GetValue("FNBMASTER","FNB_SBTIPO")
ElseIf "FND" $ cCampo
	cSubTipo	:= oModel:GetValue("FNCDETAIL","FNC_SBTIPO")
Else
	cSubTipo	:= oModel:GetValue("FNDDETAIL","FND_SBTIPO")
EndIf

Return cSubTipo

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430RTAVP   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Inicializador padrใo do campo de acordo com o conte๚do dos
campos FNB_TPAVP do cabe็alho do projeto e FNC_TPAVP
da etapa do projeto.
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430RTAVP(cTabela)
Local oModel  := FWModelActive()
Local cTipo   := ""

If Alltrim(cTabela) == "FNC"
	cTipo	:= oModel:GetValue("FNBMASTER","FNB_TPAVP")
ElseIf Alltrim(cTabela) == "FND"
	cTipo	:= oModel:GetValue("FNCDETAIL","FNC_TPAVP")
Else
	cTipo	:= oModel:GetValue("FNDDETAIL","FND_TPAVP")
EndIf

Return cTipo


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430IDEP   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Inicializador padrใo do campo de data de inicio de deprecia
็ใo
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430IDEP()
Local oModel   		:= FWModelActive()
Local dInDepr		:= CTOD("")
Local cTipo			:= '01'
Local dDataExec		:= oModel:GetValue("FNDDETAIL","FND_PRVEXC")
Local dDataProv     := oModel:GetValue("FNDDETAIL","FND_DTPROV")

dInDepr := AF430DINDP(cTipo,dDataProv,dDataExec)

Return dInDepr


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430DINDPบAutor  ณAlvaro Camillo Neto บ Data ณ  03/29/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a data de inicio de deprecia็ใo de acordo com      บฑฑ
ฑฑบ          ณ o tipo de bem                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430DINDP(cTipo,dDataProv,dDataExec)
Local dInDepr := cTod("")
Local cTypes10	:= IIF(lIsRussia,"|" + AtfNValMod({1}, "|"),"") // CAZARINI - 27/03/2017 - If is Russia, add new valuations models - main models

If cTipo == '01'
	dInDepr := RetDinDepr(dDataExec)
ElseIf cTipo $ ('10' + cTypes10)
	dInDepr := RetDinDepr(dDataProv)
EndIf

Return dInDepr
/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430VDTP   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Valida se a data de previsใo de execu็ใo ้ maior que a data
de t้rmino de perํodo de realiza็ใo de despesas.
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430VDTP()
Local oModel   		:= FWModelActive()
Local oModelFND		:= oModel:GetModel("FNDDETAIL")
Local dDataFim		:= oModelFND:GetValue("FND_PERFIM")
Local dDataPrv		:= oModelFND:GetValue("FND_PRVEXC")
Local lRet			:= .T.

If dDataFim > dDataPrv
	Help(    ,  , "AF430VDTPR",, STR0040, 1, 0 )//"Previsใo de execu็ใo deve ser maior que a data de t้rmino da etapa"
	lRet := .F.
EndIf

Return lRet

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430RDPR   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Inicializador padrใo do campo que avalia os conte๚dos dos
campos FNB_DTPROV do cabe็alho do projeto e FNC_DTPROV
da etapa do projeto.
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430RDPR()
Local oModel  := FWModelActive()
Local dDataProv := CtoD("")
Local cCampo  := ReadVar()

If "FNC" $ cCampo
	dDataProv := oModel:GetValue("FNBMASTER","FNB_DTPROV")
ElseIf "FND" $ cCampo
	dDataProv := oModel:GetValue("FNCDETAIL","FNC_DTPROV")
Else
	dDataProv := oModel:GetValue("FNDDETAIL","FND_DTPROV")
EndIf

Return dDataProv

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430RIND   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Inicializador padrใo do campo que avalia os conte๚dos dos
campos FNB_INDAVP do cabe็alho do projeto e FNC_INDAVP
da etapa do projeto.
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430RIND()
Local oModel   		:= FWModelActive()
Local cIndAvp   		:= ""
Local cCampo	  		:= ReadVar()

If "FNC" $ cCampo
	cIndAvp	:= oModel:GetValue("FNBMASTER","FNB_INDAVP")
ElseIf "FND" $ cCampo
	cIndAvp	:= oModel:GetValue("FNCDETAIL","FNC_INDAVP")
Else
	cIndAvp	:= oModel:GetValue("FNDDETAIL","FND_INDAVP")
EndIf

Return cIndAvp

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430VDTI   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Valida se a data do perํodo inicial ้ menor que a data do
perํodo final e atualiza a data de perํodo final na primeira
digita็ใo dos campos. Tamb้m atualiza a data de previsใo
de execu็ใo com o primeiro dia do m๊s imediatamente posterior
a data de perํodo final.
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430VDTI(oModel)
Local oModelFND   := oModel:GetModel("FNDDETAIL")
Local dProjeto    := oModel:GetValue("FNBMASTER","FNB_DTINIC")
Local dDataIni    := oModelFND:GetValue("FND_PERINI")
Local dDataFim    := oModelFND:GetValue("FND_PERFIM")
Local dDataProv   := oModelFND:GetValue("FND_DTPROV")
Local dDataExec   := oModelFND:GetValue("FND_PRVEXC")
Local lRet        := .T.

If lRet .and. !Empty(dDataProv)
	If dProjeto > dDataProv
		Help( , ,"AF430VDTPROV",, STR0130, 1, 0 )//"Data de inicio de provisใo deve ser maior ou igual a data de inํcio de projeto"
		lRet := .F.
	EndIf
EndIf

If lRet .and. !Empty(dDataIni)
	If dDataIni < dDataProv
		Help( , ,"AF430VDTINI",, STR0207, 1, 0 )//"Perํodo inicial deve ser igual ou posterior a data de inicio de provisใo"
		lRet := .F.
	EndIf
EndIf

If lRet .and. !Empty(dDataFim)
	If dDataIni > dDataFim
		Help( , ,"AF430VDTFIM",, STR0041, 1, 0 )//"Perํodo final da etapa deve ser maior ou igual ao inicio da etapa"
		lRet := .F.
	EndIf
EndIf

If lRet .and. !Empty(dDataExec)
	If dDataExec < dDataFim
		Help( , ,"AF430VDTEXEC",, STR0208, 1, 0 )//"Data de execu็ใo deve ser maior ou igual ao Perํodo Final"
		lRet := .F.
	EndIf
EndIf

Return lRet


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430VDTI   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ atualiza a data de previsใo
de execu็ใo com o primeiro dia do m๊s imediatamente posterior
a data de perํodo final.
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430GDTI()
Local oModel   		:= FWModelActive()
Local oModelFND		:= oModel:GetModel("FNDDETAIL")
Local dDataIni		:= oModelFND:GetValue("FND_PERINI")
Local dDataFim		:= oModelFND:GetValue("FND_PERFIM")

If Empty(dDataFim)
	dDataFim := LastDay(dDataIni)
EndIf

Return dDataFim

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430VDTF ณ Autor ณ Alvaro Camillo Neto  ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Atualiza a data de previsใo de                             ณฑฑ
ฑฑณ          ณ execu็ใo com o primeiro dia do m๊s imediatamente posterior ณฑฑ
ฑฑณ          ณ a data de perํodo final.                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430GDTF()
Local oModel    := FWModelActive()
Local oModelFND := oModel:GetModel("FNDDETAIL")
Local dDataFim  := oModelFND:GetValue("FND_PERFIM")

dDataPrv := dDataFim

Return dDataPrv

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430CLDPR   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Fun็ใo para retorno do conte๚do do parโmetro MV_CALCDEP
sem a necessidade do uso da SuperGetMV. Efetua o GETMV
do parโmetro e armazena em uma variแvel do tipo Static.
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430CLDPR()

If __cCalcDep == Nil
	__cCalcDep := GETMV("MV_CALCDEP",.T.,"0")
	__cCalcDep := IIF(Empty(__cCalcDep),"0",__cCalcDep)
EndIf

Return __cCalcDep

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430GTDPR   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Gatilho para atualiza็ใo do campo FNE_TAXA com base
na periodicidade e perํodos de deprecia็ใo informados.
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430GTDPR()
Local oModel   	:= FWModelActive()
Local oModelFNE	:= oModel:GetModel("FNEDETAIL")
Local nPeriodo	:= oModelFNE:GetValue("FNE_PERDEP")
Local cCalcDep	:= oModelFNE:GetValue("FNE_CALCDE")

Local nTaxa			:= 0

If cCalcDep == "0" // Mensal
	nTaxa := 100/(nPeriodo/12)
Else // Anual
	nTaxa := 100/ nPeriodo
EndIf


Return nTaxa

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430GPDR   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Gatilho para atualiza็ใo do campo FNE_PERDEP com base na
periodicidade e taxa de deprecia็ใo informados.
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430GPDR()
Local oModel   		:= FWModelActive()
Local oModelFNE		:= oModel:GetModel("FNEDETAIL")
Local nTaxa			:= oModelFNE:GetValue("FNE_TAXA")
Local cCalcDep		:= oModelFNE:GetValue("FNE_CALCDE")
Local nPeriodo		:= 0

If cCalcDep == "0" // Mensal
	nPeriodo := (100/nTaxa) *12
Else // Anual
	nPeriodo := 100/nTaxa
EndIf

Return nPeriodo

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430RMDF   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณInicializador padrใo do campo com base no conte๚do do
campo FNB_MOEDA.
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430RMDF()
Local oModel   	:= FWModelActive()
Local cMoeda   	:= oModel:GetValue("FNBMASTER","FNB_MOEDA")

Return cMoeda

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430VLTDP  ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณFun็ใo para validar campo em fun็ใo do
m้todo de deprecia็ใo definido.
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430VLTDP()
Local oModel   		:= FWModelActive()
Local cField		:= ReadVar()
Local lRet 			:= .F.
Local cTipDepr		:= oModel:GetValue("FNEDETAIL","FNE_TPDEPR")
Local cCTrAtf	  	:= oModel:GetValue("FNDDETAIL","FND_CTRATF")

If cCTrAtf != '2'
	If At("->",cField)>0
		cField := SubStr(cField,At("->",cField)+2,len(cField))
	EndIf

	If !Empty(&(ReadVar()))
		Do Case
			Case cTipDepr =='1'
				lRet := cField $ "FNE_PERDEP,FNE_TAXA"
			Case cTipDepr =='2'
				lRet := cField $ "FNE_PERDEP,FNE_VLSALV"
			Case cTipDepr =='3'
				lRet := cField $ "FNE_PERDEP"
			Case cTipDepr =='4'
				lRet := cField $ "FNE_PRDEST"
			Case cTipDepr =='5'
				lRet := cField $ "FNE_PRDEST"
			Case cTipDepr =='6'
				lRet := cField $ "FNE_PERDEP"
			Case cTipDepr =='7'
				lRet := cField $ "FNE_VLMXDP,FNE_PERDEP,FNE_TAXA"
			Case cTipDepr =='8'
				lRet := cField $ "FNE_VLMXDP"
			Case cTipDepr =='9'
				lRet := cField $ "FNE_PRDEST"
			Case cTipDepr =='A'
				lRet := cField $ "FNE_CODIND"
			Otherwise
				lRet := .F.
		EndCase
		If !lRet
			Help( " ", 1, "AF430FDNTUS",, STR0043, 1, 0 )//"Esse campo nใo ้ utilizado pelo m้todo de deprecia็ใo selecionado"
		EndIf
	EndIf

	/*
	1-Linea	2-RedSl	3-SAnos	4-UnPrd	5-HrPrd	6-SDigi	7-LVlMx	8-ExLin	9-ExSld
	N3_PERDEPR			   X	   X					   X
	N3_VLSALV1			   X
	N3_PRODMES							   X	   X
	N3_PRODANO							   X	   X						X		X
	N3_VMXDEPR													   X
	*/
EndIf

Return lRet


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430WMTD   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณFun็ใo para habilitar a edi็ใo do campo em fun็ใo do
m้todo de deprecia็ใo definido.
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430WTPCL()
Local lRet 			:= .T.
Local oModel   		:= FWModelActive()
Local cTipoClass	:= oModel:GetValue("FNEDETAIL","FNE_TPCLAS")

lRet := cTipoClass == "2"

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430GDSItณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gatilho para atualiza็ใo do campo descria็ใo do item       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430GDSIt()
Local oModel   		:= FWModelActive()
Local oModelFNE		:= oModel:GetModel("FNEDETAIL")
Local aSaveLines 	:= FWSaveRows()
Local cItem         := oModel:GetValue("FNDDETAIL","FND_ITEM")
Local cDesc         := oModel:GetValue("FNDDETAIL","FND_DSCITE")
Local nX            := 0
Local oView     := FWViewActive()

//Carrega tabela FNE
For nX := 1 To oModelFNE:Length()
	oModelFNE:GoLine( nX )
	oModelFNE:LoadValue( "FNE_ITVIRT"   , cItem )
Next

FWRestRows(aSaveLines)

Return cDesc

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430GPLN   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Gatilho para atualiza็ใo do campo de AVP planejado
de acordo com o ํndice de AVP quando este estiver
informado. Tambem atualiza o valor original da configura็ใo contแbil
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430GPLN()
Local lRet           := .T.
Local oModel         := FWModelActive()
Local oModelFNE      := oModel:GetModel("FNEDETAIL")
Local aSaveLines     := FWSaveRows()
Local nX             := 0
Local nVOrig         := oModel:GetValue("FNDDETAIL","FND_VLRPLN")
Local oView          := FWViewActive()

//Carrega tabela FNE
For nX := 1 To oModelFNE:Length()
	oModelFNE:GoLine( nX )
	If !oModelFNE:IsDeleted()
		lRet := oModelFNE:LoadValue( 'FNE_VORIG' , nVOrig )
	EndIf
	If !lRet
		Exit
	EndIf
Next

FWRestRows(aSaveLines)

Return nVOrig


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430IVORIณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inicializador padrao do campo de valor original do item    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430IVORI()
Local oModel   	:= FWModelActive()
Local nVOrig   	:= oModel:GetValue("FNDDETAIL","FND_VLRPLN")

Return nVOrig


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430VDP   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o valor de depreciacao acumulada do item            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430VDP()
Local lRet 	  		:= .T.
Local oModel   		:= FWModelActive()
Local nDepAcm		:= oModel:GetValue("FNEDETAIL","FNE_VRDACM")
Local nVlrBem   	:= oModel:GetValue("FNEDETAIL","FNE_VORIG")
Local nVlrMax		:= oModel:GetValue("FNEDETAIL","FNE_VLMXDP")
Local dInDepr    	:= oModel:GetValue("FNEDETAIL","FNE_DINDEP")
Local dUltDepr		:= SuperGetMv("MV_ULTDEPR",.F.,"01/01/80")
Local cCTrAtf	  	:= oModel:GetValue("FNDDETAIL","FND_CTRATF")
Local cTpDepr	  	:= oModel:GetValue("FNEDETAIL","FNE_TPDEPR")

If cCTrAtf != '2'
	If dInDepr < dUltDepr .And. Empty(nDepAcm)
		Help(" ",1,"AF430DEPACM",,STR0044,1,0)//"Caso a data de inicio da etapa seja anterior a data do ultimo calculo de deprecia็ใo, o campo de valor de deprecia็ใo acumulada deve ser preenchido."
		lRet := .F.
	EndIf

	If nDepAcm > nVlrBem
		Help(" ",1,"AF430VLMAX",,STR0122,1,0)//"Deprecia็ใo acumulada nใo pode ser maior que valor original"
		lRet := .F.
	EndIf

	If cTpDepr == '7' .And. !Empty(nVlrMax) .And.  nDepAcm > nVlrMax
		Help(" ",1,"AF430DEPMAX",,STR0123,1,0)//"Deprecia็ใo acumulada nใo pode ser maior que valor mแximo de deprecia็ใo"
		lRet := .F.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430AVPPL ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o valor de AVP planejado                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430AVPPL()
Local lRet       := .T.
Local oModel     := FWModelActive()
Local nVlrBem    := oModel:GetValue("FNEDETAIL","FNE_VORIG")
Local nVlrAVP    := oModel:GetValue("FNEDETAIL","FNE_AVPPLN")
Local cTipoAVP   := oModel:GetValue("FNDDETAIL","FND_TPAVP")
Local nDepAcm    := oModel:GetValue("FNEDETAIL","FNE_VRDACM")
Local cCTrAtf    := oModel:GetValue("FNDDETAIL","FND_CTRATF")

If cCTrAtf != '2'

	If lRet .And. nVlrAVP >= nVlrBem
		Help(" ",1,"AF430AVPPLAN",,STR0209,1,0)//"Valor de AVP planejado nใo pode ser maior ou igual que o valor original."
		lRet := .F.
	EndIf

	If lRet .And. cTipoAVP == '2' .And. nDepAcm <= 0 .And. nVlrAVP > 0
		Help(" ",1,"AF430AVPPLAN1",,STR0210,1,0)//"Para inserir AVP por parcela, ้ obrigat๓rio ter deprecia็ใo acumulada"
		lRet := .F.
	EndIf

	If lRet .And. cTipoAVP == '2' .And. nVlrAVP >= nDepAcm
		Help(" ",1,"AF430AVPPLAN2",,STR0211,1,0)//"Para inserir AVP por parcela, o AVP nใo poderแ ser maior ou igual que o valor de deprecia็ใo acumulada"
		lRet := .F.
	EndIf

	If lRet
		lRet := AF430VNvTX()
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430AVPRZ ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o valor de AVP realizado                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430AVPRZ()
Local lRet       := .T.
Local oModel     := FWModelActive()
Local nAVPRZ     := oModel:GetValue("FNEDETAIL","FNE_AVPRLZ")
Local nAVPPla    := oModel:GetValue("FNEDETAIL","FNE_AVPPLN")
Local cCTrAtf    := oModel:GetValue("FNDDETAIL","FND_CTRATF")


If cCTrAtf != '2'

	If lRet .And. nAVPRZ >= nAVPPla
		Help(" ",1,"AF430AVPRZ",,STR0212,1,0)//"Valor de AVP realizado nใo pode ser maior ou igual que o valor de AVP Planejado."
		lRet := .F.
	EndIf


EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430GRPWณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que realiza o when do campo grupo de bens            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430GRPW()
Local lRet := .T.

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430AVPWณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que realiza o when do campo grupo de bens            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430AVPW()
Local oModel  := FWModelActive()
Local lRet    := .T.
Local cIndice := oModel:GetValue("FNDDETAIL","FND_INDAVP")
Local cTipo   := oModel:GetValue("FNEDETAIL","FNE_TPATF")
Local cTypes10	:= IIF(lIsRussia,"*" + AtfNValMod({1}, "*"),"") // CAZARINI - 27/03/2017 - If is Russia, add new valuations models - main models

lRet := Alltrim(cTipo) $ ("10" + cTypes10) .and. !Empty(cIndice)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430GRPINณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inicializador padrใo do campo grupo de bens                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430GRPIN()
Local cGrupo 		:= ""
Local oModel   		:= FWModelActive()
Local oModelFNE		:= oModel:GetModel("FNEDETAIL")
Local nLinFNE 		:= oModelFNE:GetLine()

If oModelFNE:Length() > 0
	If nLinFNE >= 1
		oModelFNE:GoLine( 1 )
		cGrupo := oModelFNE:GetValue("FNE_GRPBEM")
	EndIf

	oModelFNE:GoLine( nLinFNE )
EndIf

Return cGrupo


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430CTBIN   บAutor  ณAlvaro Camillo Neto บ Data ณ  10/26/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inicializador dos campos de entidades contabeis e taxa     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430CTBIN(cCampoSNG)
Local cGrupo   		:= ""
Local aArea    		:= GetArea()
Local oModel   		:= FWModelActive()
Local cMoeda   		:= oModel:GetValue("FNBMASTER","FNB_MOEDA")
Local oModelFNE		:= oModel:GetModel("FNEDETAIL")
Local cRetorno 		:= ""
Local nValorTaxa 	:= 0
Local cCalcDep		:= ""
Local lRet			:= .T.
Local nPeriodo		:= 0
Local nLinFNE 		:= oModelFNE:GetLine()

cGrupo := AF430GRPIN()

If !Empty(cGrupo)
	cCalcDep		:= oModelFNE:GetValue("FNE_CALCDE")
	SNG->(dbSetOrder(1))
	If SNG->(MsSeek( xFilial("SNG") + cGrupo ))

		If Val(cMoeda) > 9
			nValorTaxa := SNG->&("NG_TXDEP"+cValToChar(Val(cMoeda)))
		Else
			nValorTaxa := SNG->&("NG_TXDEPR"+cValToChar(Val(cMoeda)))
		EndIf

		If cCalcDep == "0" // Mensal
			nPeriodo := (100/nValorTaxa) *12
		Else // Anual
			nPeriodo := 100/nValorTaxa
		EndIf

		If "NG_TXDEPR" $ cCampoSNG
			cRetorno := nValorTaxa
		ElseIf "PERDEP" $ cCampoSNG
			cRetorno := nPeriodo
		Else
			cRetorno := SNG->&(cCampoSNG)
		EndIf


	EndIf
EndIf

RestArea(aArea)
Return cRetorno

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430WCTD   ณ Autor ณAlvaro Camillo Neto   ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณFun็ใo para habilitar a edi็ใo do campo em fun็ใo do        ณฑฑ
ฑฑณ Uso      ณcrit้rio de deprecia็ใo definido.                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF430WCTD(nOper)

Local lRet := .T.
Local oModel   		:= FWModelActive()
Local oModelFNE		:= oModel:GetModel("FNEDETAIL")
Local cMetodo		:= ""

DEFAULT nOper := 0

//Validacao chamada do campo FNE_TAXA (Tx Depr.)
If nOper == 1 .and. oModelFNE:Length() > 0
	cMetodo := oModelFNE:GetValue("FNE_TPDEPR")
	// Depreciacao por indice de depreciacao nao permite a edicao do campo de taxa de depreciacao
    If cMetodo == "A"
		lRet := .F.
	Endif
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430BLQW()บAutor  ณMicrosiga           บ Data ณ  10/26/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo do campo When dos campos de bloqueios _MSBLQ        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430BLQW()

Return __nOper == OPER_BLOQUEAR

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430GTBLQ   บAutor  ณMicrosiga           บ Data ณ  10/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza o gatilho do campo bloqueio                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430GTBLQ(cTabela)
Local lRet 	   		:= .T.
Local oModel   		:= FWModelActive()
Local cFlagBlq 		:= ""
Local oModelFNC		:= oModel:GetModel("FNCDETAIL")
Local oModelFND		:= oModel:GetModel("FNDDETAIL")
Local aSaveLines  	:= FWSaveRows()
Local nX		  			:= 0

//Carrega tabela FNC
If "FNB" $ cTabela
	cFlagBlq := oModel:GetValue("FNBMASTER","FNB_MSBLQL")
	For nX := 1 To oModelFNC:Length()
		oModelFNC:GoLine( nX )
		If !oModelFNC:IsDeleted()
			lRet := oModelFNC:SetValue( "FNC_MSBLQL" , cFlagBlq )
		EndIf
		If !lRet
			Exit
		EndIf
	Next
Else
	cFlagBlq:= oModel:GetValue("FNCDETAIL","FNC_MSBLQL")
EndIf

//Carrega tabela FND
For nX := 1 To oModelFND:Length()
	oModelFND:GoLine( nX )
	If !oModelFND:IsDeleted()
		lRet := oModelFND:SetValue( "FND_MSBLQL" , cFlagBlq )
	EndIf
	If !lRet
		Exit
	EndIf
Next

FWRestRows(aSaveLines)

Return cFlagBlq


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430INREVบAutor  ณAlvaro Camillo Neto บ Data ณ  24/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a revisใo do projeto conforme opera็ใo                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430INREV()
Local cRevisao 		:= STRZERO(1,TamSx3("FNB_REVIS")[1] )
Local aArea			:= GetArea()
Local aAreaFNB		:= FNB->(GetArea())
Local cCodPrj		:= ""

FNB->(dbSetOrder(1)) //FNB_FILIAL+FNB_CODPRJ+FNB_REVIS

If __nOper == OPER_REVISAR
	cCodPrj  := FNB->FNB_CODPRJ
	cRevisao := AF430GetRev(cCodPrj)
	cRevisao := Soma1(cRevisao)
EndIf

RestArea(aAreaFNB)
RestArea(aArea)
Return cRevisao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430INCODบAutor  ณAlvaro Camillo Neto บ Data ณ  24/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o c๓digo  do projeto caso seja uma operacao de      บฑฑ
ฑฑบ          ณrevisใo                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430INCOD()
Local cCodPrj		:= ""

If __nOper == OPER_REVISAR
	cCodPrj		:= FNB->FNB_CODPRJ
EndIf

Return cCodPrj


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430CBASEบAutor  ณAlvaro Camillo Neto บ Data ณ  24/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo do campo FNB_CBASE para verificar se             บฑฑ
ฑฑบ          ณ jแ existe um c๓digo no ativo fixo ou outro projeto estแ    บฑฑ
ฑฑบ          ณ utilizando                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430CBASE()
Local lRet 			:= .T.
Local oModel   		:= FWModelActive()
Local aArea 		:= GetArea()
Local aAreaFNB 		:= FNB->(GetArea())
Local cCodprj		:= oModel:GetValue("FNBMASTER","FNB_CODPRJ")
Local cBase			:= oModel:GetValue("FNBMASTER","FNB_CBASE")

FNB->(dbSetOrder(2)) //FNB_FILIAL+FNB_CBASE+FNB_CODPRJ+FNB_REVIS
SN1->(dbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM

If !Empty(cBase)
	If SN1->(MSSeek(xFilial("SN1") + cBase)) .And. SN1->N1_PROJETO != cCodprj
		Help(" ",1,"JAGRAVADO")
		lRet := .F.
	EndIf

	If lRet
		If FNB->(MsSeek( xFilial("FNB") + cBase ))
			While FNB->(!EOF()) .And.  FNB->(FNB_FILIAL+FNB_CBASE) == xFilial("FNB") + cBase
				If Alltrim(cCodprj) != Alltrim(FNB->FNB_CODPRJ)
					Help(" ",1,"AF430CBASE",,STR0062 + FNB->FNB_CODPRJ +STR0063 ,1,0)//" O projeto :"##" jแ estแ utilizando esse c๓digo base de ativo "
					lRet := .F.
					Exit
				EndIf
				FNB->(dbSkip())
			EndDo
		EndIf
	EndIf
EndIf

RestArea(aAreaFNB)
RestArea(aArea)
Return lRet


/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRotinas de Processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA430REVบAutor  ณAlvaro Camillo Neto บ Data ณ  24/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a revisใo do projeto de imobilizado                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFA430REV(cAlias,nReg,nOpc)
Local aArea			:= GetArea()
Local lConfirma		:= .F.
Local lCancela		:= .F.
Local cTitulo  		:= ""
Local cPrograma 	:= ""
Local nOperation 	:= 0
Local cCodPrj		:= FNB->FNB_CODPRJ
Local cRev			:= FNB->FNB_REVIS
Local lRet			:= .T.

If lRet .And. !(FNB->FNB_STATUS $ '0/1' )
	Help(" ",1,"AF430REV",,STR0045 ,1,0)//"Nใo ้ possivel revisar o projeto com esse status"
	lRet := .F.
EndIf

If lRet .And. !Empty(AF430GetRev(cCodPrj,'8'))
	Help(" ",1,"AF430REVAPR",,STR0134 ,1,0)//"Jแ existe revisใo em processo de aprova็ใo"
	lRet := .F.
EndIf

If lRet
	lRet := CtbInTran( 1, .F. )
EndIf

If lRet
	cTitulo    		:= STR0183 //"Revisใo"
	cPrograma 		:= 'ATFA430'
	nOperation 		:= 1		 	// Visualizar
	__lConfirmar 	:= .F.
	__lBTNConfirma  := .T.
	__nOper 		:= OPER_REVISAR
	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/, /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )

	If __lConfirmar
		MsgRun( STR0061 ,, {||	lRet := AF430REVGR(cCodPrj,cRev) } ) //"Processando revisใo do Projeto..."
	EndIf
EndIf

__nOper := 0
__lConfirmar    := .F.
__lBTNConfirma  := .F.

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430REVTXบAutor  ณAlvaro Camillo Neto บ Data ณ  24/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a revisใo da taxa de AVP do projeto de imobilizado บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430REVTX(cAlias,nReg,nOpc,lAprRev,dDataRev)
Local aArea			:= GetArea()
Local lConfirma		:= .F.
Local lCancela		:= .F.
Local cTitulo  		:= ""
Local cPrograma 	:= ""
Local nOperation 	:= 0
Local cCodPrj		:= FNB->FNB_CODPRJ
Local cRev			:= FNB->FNB_REVIS
Local lRet			:= .T.
Local bOk           := Nil
Local dDataBkp		:= dDataBase
Local lAprov		:= .F.

Default lAprRev  := .F.
Default dDataRev := dDataBase

dDataBase := dDataRev

If lRet .And. !(FNB->FNB_STATUS $ '1/8' )
	Help(" ",1,"AF430REV",,STR0045 ,1,0)//"Nใo ้ possivel revisar o projeto com esse status"
	lRet := .F.
EndIf

If lRet .And. !Empty(AF430GetRev(cCodPrj,'8')) .And. Alltrim(FunName()) != "ATFA004"
	Help(" ",1,"AF430REVAPR",,STR0134 ,1,0)//"Jแ existe revisใo em processo de aprova็ใo"
	lRet := .F.
EndIf

If lRet .And. Empty(FNB->FNB_INDAVP)
	Help(" ",1,"AF430NOAVP",,STR0191+CRLF+STR0192,1,0)	//"Este projeto nใo possui tratamento de AVP, portanto a revisใo de taxa de AVP nใo serแ possivel."###"Efetue uma revisใo do projeto para possibilitar esta altera็ใo."
	lRet := .F.
EndIf



If lRet
	lRet := CtbInTran( 1, .F. )
EndIf

//Verifica se o controle de aprova็ใo estแ habilitado
If __lCtrlAprov .And. lRet
	lAprov := ATFxCtrlAprov("ATFA430","12")		//Revisar Taxa
EndIf

If lRet
	cTitulo    	:= STR0184 //""Revisใo  AVP"
	cPrograma 		:= 'ATFA430'

	__lConfirmar 	:= .F.
	__nOper 		:= OPER_REVTX

	If lAprRev
		__lConfirmar := .T.
	Else
		nOperation 		:= MODEL_OPERATION_UPDATE
		bOk          := {|| AF430VLTX() }
		FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/, bOk , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )
	EndIf

	If __lConfirmar
		If (!lAprov .Or. lAprRev)
			MsgRun( STR0141 ,, {||	lRet := AF430RTX(cCodPrj,cRev) } ) //"Processando revisใo de taxas de AVP..."
			If lRet
				AF430FLAG(cCodPrj,cRev,"1")
			EndIf
		Else
			//Gera o movimento de aprova็ใo
			cOrigem := FunName()
			lRet := AF004GrvMov("ATFA430","12",dDataBase,,,,cOrigem,"FNB",FNB->(Recno()))
			If lRet
				AF430FLAG(cCodPrj,cRev,"8")
			EndIf
		EndIf
	EndIf

EndIf

__nOper := 0
__lConfirmar   := .F.
__lBTNConfirma := .F.
dDataBase      := dDataBkp
RestArea(aArea)
Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA430CPYบAutor  ณAlvaro Camillo Neto บ Data ณ  12/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a c๓pia do projeto                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFA430CPY(cAlias,nReg,nOpc)
Local aArea         := GetArea()
Local lConfirma     := .F.
Local lCancela      := .F.
Local cTitulo       := ""
Local cPrograma     := ""
Local nOperation    := 0
Local cCodPrj       := FNB->FNB_CODPRJ
Local cRev          := FNB->FNB_REVIS
Local lRet          := .T.


If FNB->(MsSeek(xFilial("FNB") + cCodPrj + cRev))
	__nOper      := OPER_COPIAR
	cTitulo      := STR0182 //"C๓pia"
	cPrograma    := 'ATFA430'
	nOperation   := MODEL_OPERATION_INSERT
	If 	!isBlind()
	oModel       := FWLoadModel( cPrograma )
	oModel:SetOperation( nOperation ) // Inclusใo
	oModel:Activate(.T.) // Ativa o modelo com os dados posicionados
	oModel:SetValue("FNBMASTER","FNB_CBASE","")
	nRet         := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
	
	oModel:DeActivate()
	EndIf
	__nOper      := 0

EndIf

RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA430BLQบAutor  ณAlvaro Camillo Neto บ Data ณ  24/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza o bloqueio/Desbloqueio do projeto ou das     บฑฑ
ฑฑบ          ณ  etapas do projeto                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFA430BLQ(cAlias,nReg,nOpc)
Local aArea         := GetArea()
Local lConfirma     := .F.
Local lCancela      := .F.
Local cTitulo       := ""
Local cPrograma     := ""
Local nOperation    := 0
Local cCodPrj       := FNB->FNB_CODPRJ
Local cRev          := FNB->FNB_REVIS
Local lRet          := .T.

If lRet .And. !(FNB->FNB_STATUS $ '0/1/9' )
	Help(" ",1,"AF430BLOQ",,STR0048 ,1,0) // "Nใo ้ possivel bloquear/desbloquear projeto com esse status"
	lRet := .F.
EndIf

If lRet .And. !Empty(AF430GetRev(cCodPrj,'8'))
	Help(" ",1,"AF430REVAPR",,STR0134 ,1,0)//"Jแ existe revisใo em processo de aprova็ใo"
	lRet := .F.
EndIf

If lRet .and. !isBlind()
	__nOper      := OPER_BLOQUEAR
	cTitulo      := STR0185 // "Bloqueio/Desbloqueio"
	cPrograma    := 'ATFA430'
	nOperation   := MODEL_OPERATION_UPDATE
	bOk          := {|| lRet := MsgNoYes(STR0049) } //"Deseja Realizar o bloqueio/desbloqueio do projeto ou etapas ? "
	nRet         := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,bOk , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )
	__nOper      := 0
Else
	__nOper      := OPER_BLOQUEAR
	cTitulo      := STR0185 // "Bloqueio/Desbloqueio"
	cPrograma    := 'ATFA430'
	nOperation   := MODEL_OPERATION_UPDATE
EndIf

RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA430ETENบAutor  ณAlvaro Camillo Neto บ Data ณ  24/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz o encerramento da etapa                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFA430ETEN(cAlias,nReg,nOpc)
Local aArea			:= GetArea()
Local lConfirma	:= .F.
Local lCancela		:= .F.
Local	cTitulo 		:= ""
Local	cPrograma 	:= ""
Local	nOperation 	:= 0
Local cCodPrj		:= FNB->FNB_CODPRJ
Local cRev			:= FNB->FNB_REVIS
Local lRet			:= .T.

If lRet .And. !(FNB->FNB_STATUS $ '1' )
	Help(" ",1,"AF430ENC",,STR0060 ,1,0) // "Nใo ้ possivel encerrar o projeto com esse status"
	lRet := .F.
EndIf

If lRet .And. !Empty(AF430GetRev(cCodPrj,'8'))
	Help(" ",1,"AF430REVAPR",,STR0134 ,1,0)//"Jแ existe revisใo em processo de aprova็ใo"
	lRet := .F.
EndIf

If lRet
	__nOper 			:= OPER_ENC_ETAPA
	cTitulo 			:= STR0186 //"Encerramento de Etapa/Item de Etapa"
	cPrograma 	   		:= 'ATFA430'
	nOperation 	   		:=	MODEL_OPERATION_UPDATE
	bOk           		:= {|| AF430ENCVL(cCodPrj,cRev)  }
	nRet 				:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. },bOk , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )
	__nOper 			:= 0
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA430ExpบAutor  ณAlvaro Camillo Neto บ Data ณ  24/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExporta o projeto para arquivo .CSV                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFA430Exp()
Local aRet		:=	{}
Local cCodPrj	:= FNB->FNB_CODPRJ
Local cRev		:= FNB->FNB_REVIS

SaveInter()

If ParamBox({	{6,STR0076,padr("",150),"",,"",90 ,.T.,STR0077+" .CSV |*.CSV","",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},;//"Estrutura Projeto"##" Arquivo"
	"",@aRet)
	MsgRun( STR0079 ,, {||	lRet := ExportPrj(cCodPrj,cRev,aRet[1] ) } ) //"Exportando Projeto... "
EndIf

RestInter()

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA430IMPบAutor  ณAlvaro Camillo Neto บ Data ณ  24/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a importa็ใo do projeto                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFA430IMP()
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aRet		:= {}
Local aPerg		:= {}
Local lRevisa	:= .F.
Local lMostra

SaveInter()

aAdd(aPerg,{6,STR0076,padr("",150),"",,"", 90 ,.T.,STR0077+" .CSV |*.CSV" ,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE})//"Estrutura Projeto"##" Arquivo"
aAdd(aPerg,{2,STR0126,STR0127,{STR0128, STR0127 },60,"",.T.})//"Caso projeto exista, gera revisใo"##"Nใo"##"Sim"##"Nใo"
aAdd(aPerg,{2,STR0129,STR0127,{STR0128, STR0127 },60,"",.T.})//"Visualiza ap๓s importa็ใo" ##"Nใo"##"Sim"##"Nใo"

If ParamBox(aPerg, "",@aRet)
	aRetP1 	:= AjRetParam(aRet,aPerg)
	lRevisa := aRetP1[2] == 1
	lMostra := aRetP1[3] == 1
	MsgRun( STR0081 ,, {||	lRet := ImportPrj(aRetP1[1],lRevisa,lMostra) } ) //"Processando Importa็ใo do Projeto..."
EndIf

RestInter()
RestArea(aArea)
dbSelectArea("FNB")
dbGoTop()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA430ATUบAutor  ณAlvaro Camillo Neto บ Data ณ  24/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a gera็ใo das fichas do ativo fixo vinculadas      บฑฑ
ฑฑบ          ณ ao projeto de ativo                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFA430ATU(cAlias,nReg,nOpc,lAprRev)
Local aArea			:= GetArea()
Local lConfirma	:= .F.
Local lCancela		:= .F.
Local cTitulo 		:= ""
Local cPrograma 	:= ""
Local nOperation 	:= MODEL_OPERATION_VIEW
Local cCodPrj		:= FNB->FNB_CODPRJ
Local cRev			:= FNB->FNB_REVIS
Local lRet			:= .T.
Local lAprov		:= .F.

Default lAprRev 	:= .F.

If lRet .And. !(FNB->FNB_STATUS $ '0/8' )
	Help(" ",1,"AF430ATU",,STR0181 ,1,0) // "Nใo ้ possivel atualizar o projeto com esse status"
	lRet := .F.
EndIf

If lRet .And. !Empty(AF430GetRev(cCodPrj,'8')) .And. Alltrim(FunName()) != "ATFA004"
	Help(" ",1,"AF430REVAPR",,STR0134 ,1,0)//"Jแ existe revisใo em processo de aprova็ใo"
	lRet := .F.
EndIf

If lRet
	lRet := CtbInTran( 1, .F. )
EndIf

//Verifica se o controle de aprova็ใo estแ habilitado
If __lCtrlAprov .And. lRet
	lAprov := ATFxCtrlAprov("ATFA430","11")		//Atualizar
EndIf

If lRet
	cTitulo 	:= STR0187 //"Atualizar"
	cPrograma 	:= 'ATFA430'
	nOperation 	:= MODEL_OPERATION_VIEW // Visualizar
	__lConfirmar:= .F.
	__nOper     := OPER_ATUALIZAR
	__lBTNConfirma  := .T.

	If lAprRev
		__lConfirmar := .T.
	Else
		FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )
	EndIf

	If __lConfirmar
		If (!lAprov .Or. lAprRev)
			MsgRun( STR0056 ,, {||	lRet := AF430GerAT(cCodPrj,cRev) } ) //"Processando atualiza็ใo do Projeto..."
		Else
			//Gera o movimento de aprova็ใo
			cOrigem := FunName()
			lRet := AF004GrvMov("ATFA430","11",dDataBase,,,,cOrigem,"FNB",FNB->(Recno()))
			If lRet
				AF430FLAG(cCodPrj,cRev,"8")
			EndIf
		EndIf
	EndIf
EndIf

__lConfirmar:= .F.
__lBTNConfirma  := .F.
__nOper     := 0

RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA430ENC บAutor  ณAlvaro Camillo Neto บ Data ณ  11/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza o encerramento do projeto                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFA430ENC(cAlias,nReg,nOpc,lAprRev)
Local aArea			:= GetArea()
Local aAreaSN1		:= SN1->(GetArea())
Local lConfirma	    := .F.
Local lCancela		:= .F.
Local cTitulo 		:= ""
Local cPrograma 	:= ""
Local nOperation 	:= MODEL_OPERATION_VIEW
Local cCodPrj		:= FNB->FNB_CODPRJ
Local cRev			:= FNB->FNB_REVIS
Local lRet			:= .T.
Local cIdCV8        := ""
Local lAprov		:= .F.

Local cMensIni		:= STR0082 + cCodPrj +STR0083+ cRev//" Encerramento do projeto "##" revisใo: "
Local cProc			:= __cProcPrinc + "ENC"
Local cSubProc      := cCodPrj+cRev

Default lAprRev 	:= .F.

SN1->(dbSetOrder(9)) //N1_FILIAL+N1_PROJETO+N1_PROJREV+N1_PROJETP+N1_PROJITE+N1_CBASE+N1_ITEM

If lRet .And. !(FNB->FNB_STATUS $ '1/8' )
	Help(" ",1,"AF430ENC",,STR0060 ,1,0) // "Nใo ้ possivel encerrar o projeto com esse status"
	lRet := .F.
EndIf

If lRet .And. !Empty(AF430GetRev(cCodPrj,'8')) .And. Alltrim(FunName()) != "ATFA004"
	Help(" ",1,"AF430REVAPR",,STR0134 ,1,0)//"Jแ existe revisใo em processo de aprova็ใo"
	lRet := .F.
EndIf


if lRet .and. AF430AtvPo(cCodPrj)
	Help(" ",1,"AF430AtvPo",,STR0203,1,0) //"Existe(m) ativo(s) com data de aquisi็ใo superior a data base do sistema."
	lRet := .F.
endif

If lRet
	lRet := CtbInTran( 1, .F. )
EndIf

//Verifica se o controle de aprova็ใo estแ habilitado
If __lCtrlAprov
	lAprov := ATFxCtrlAprov("ATFA430","10")		//Encerrar
EndIf

If lRet
	cTitulo 			:= STR0188 //"Encerramento de Projeto"
	cPrograma  		:= 'ATFA430'
	nOperation 		:= MODEL_OPERATION_VIEW // Visualizar
	__lConfirmar    := .F.
	__nOper         := OPER_ENC_PROJ
	__lBTNConfirma  := .T.

	If lAprRev
		__lConfirmar := .T.
	Else
		FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } /*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )
	EndIf

	If __lConfirmar
		If (!lAprov .Or. lAprRev)

			ProcLogIni( {},cProc,cSubProc,@cIdCV8 )
			ProcLogAtu( "INICIO" , cMensIni ,,,.T. )

			//Existem fichas atreladas ao projeto realiza a baixa
			If AF430VerAtf(cCodPrj,cRev)
				MsgRun( STR0059 ,, {||	lRet := AF430BxAtf(cCodPrj,cRev,"21") } ) //"Processando Encerramento do Projeto..."
			EndIf

			If lRet
				//Altera o Status para encerrado
				AF430FLAG(cCodPrj,cRev,"2")
				AF430DTENC(cCodPrj,cRev,dDataBase)
			EndIf

			ProcLogAtu( "FIM" ,,,,.T.)
			ProcLogView(cFilAnt,cProc,cSubProc,cIdCV8)
		Else
			//Gera o movimento de aprova็ใo
			cOrigem := FunName()
			lRet := AF004GrvMov("ATFA430","10",dDataBase,,,,cOrigem,"FNB",FNB->(Recno()))
			If lRet
				AF430FLAG(cCodPrj,cRev,"8")
			EndIf
		EndIf
	EndIf

EndIf

__lConfirmar    := .F.
__nOper         := 0
__lBTNConfirma  := .F.

RestArea(aAreaSN1)
RestArea(aArea)
Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430FLAG บAutor  ณAlvaro Camillo Neto บ Data ณ  10/26/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Altera os campos flags do projeto                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430FLAG(cCodPrj,cRev,cFlag,lBloqMan,cFlagBloq)
Local aArea		:= GetArea()
Local aAreaFNB	:= FNB->(GetArea())
Local aAreaFNC	:= FNC->(GetArea())
Local aAreaFND	:= FND->(GetArea())
Default lBloqMan := .F.
Default cFlagBloq := ""

FNB->(dbSetOrder(1)) //FNB_FILIAL+FNB_CODPRJ+FNB_REVIS
FNC->(dbSetOrder(1)) //FNC_FILIAL+FNC_CODPRJ+FNC_REVIS+FNC_ETAPA
FND->(dbSetOrder(1)) //FND_FILIAL+FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM

If FNB->(MsSeek( xFilial("FNB") + cCodPrj + cRev ))
	RecLock("FNB",.F.)
	If lBloqMan
		If FNB->FNB_MSBLQL == '1' // Bloqueado
			FNB->FNB_STATUS := cFlagBloq
		Else
			FNB->FNB_STATUS := cFlag
		EndIf
	Else
		If Empty(FNB->FNB_DTENCR)
			FNB->FNB_STATUS := cFlag
		Else
			FNB->FNB_STATUS := "2"
		EndIf
	EndIf
	MsUnLock()
EndIf

If FNC->(MsSeek( xFilial("FNC") + cCodPrj + cRev ))
	While FNC->(!EOF()) .And. FNC->(FNC_FILIAL+FNC_CODPRJ+FNC_REVIS) ==  xFilial("FNC") + cCodPrj + cRev
		RecLock("FNC",.F.)

		If lBloqMan
			If FNC->FNC_MSBLQL == '1' // Bloqueado
				FNC->FNC_STATUS := cFlagBloq
			Else
				FNC->FNC_STATUS := cFlag
			EndIf
		Else
			If Empty(FNC->FNC_DTENCR)
				FNC->FNC_STATUS := cFlag
			Else
				FNC->FNC_STATUS := "2"
			EndIf
		EndIf

		MsUnLock()
		FNC->(dbSkip())
	EndDo
EndIf

If FND->(MsSeek( xFilial("FND") + cCodPrj + cRev ))
	While FND->(!EOF()) .And. FND->(FND_FILIAL+FND_CODPRJ+FND_REVIS) ==  xFilial("FND") + cCodPrj + cRev
		RecLock("FND",.F.)

		If lBloqMan
			If FND->FND_MSBLQL == '1' // Bloqueado
				FND->FND_STATUS := cFlagBloq
			Else
				FND->FND_STATUS := cFlag
			EndIf
		Else
			If Empty(FND->FND_DTENCR)
				FND->FND_STATUS := cFlag
			Else
				FND->FND_STATUS := "2"
			EndIf
		EndIf

		MsUnLock()
		FND->(dbSkip())
	EndDo
EndIf

RestArea(aAreaFND)
RestArea(aAreaFNC)
RestArea(aAreaFNB)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430DTENCบAutor  ณAlvaro Camillo Neto บ Data ณ  11/14/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava a data de encerramento do projeto                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430DTENC(cCodPrj,cRev,dData)

Local aArea		:= GetArea()
Local aAreaFNB	:= FNB->(GetArea())
Local aAreaFNC	:= FNC->(GetArea())
Local aAreaFND	:= FND->(GetArea())

Default dData  := dDataBase

FNB->(dbSetOrder(1)) //FNB_FILIAL+FNB_CODPRJ+FNB_REVIS
FNC->(dbSetOrder(1)) //FNC_FILIAL+FNC_CODPRJ+FNC_REVIS+FNC_ETAPA
FND->(dbSetOrder(1)) //FND_FILIAL+FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM

If FNB->(MsSeek( xFilial("FNB") + cCodPrj + cRev ))
	If Empty(FNB->FNB_DTENCR)
		RecLock("FNB",.F.)
		FNB->FNB_DTENCR := dData
		MsUnLock()
	EndIf
EndIf

If FNC->(MsSeek( xFilial("FNC") + cCodPrj + cRev ))
	While FNC->(!EOF()) .And. FNC->(FNC_FILIAL+FNC_CODPRJ+FNC_REVIS) ==  xFilial("FNC") + cCodPrj + cRev
		If Empty(FNC->FNC_DTENCR)
			RecLock("FNC",.F.)
			FNC->FNC_DTENCR := dData
			MsUnLock()
		EndIf
		FNC->(dbSkip())
	EndDo
EndIf

If FND->(MsSeek( xFilial("FND") + cCodPrj + cRev ))
	While FND->(!EOF()) .And. FND->(FND_FILIAL+FND_CODPRJ+FND_REVIS) ==  xFilial("FND") + cCodPrj + cRev
		If Empty(FND->FND_DTENCR)
			RecLock("FND",.F.)
			FND->FND_DTENCR := dData
			MsUnLock()
		EndIf
		FND->(dbSkip())
	EndDo
EndIf

RestArea(aAreaFND)
RestArea(aAreaFNC)
RestArea(aAreaFNB)
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA430LOGบAutor  ณAlvaro Camillo Neto บ Data ณ  10/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra o Log de processamento da rotina                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFA430LOG()

ProcLogView(,__cProcPrinc)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA430   บAutor  ณMicrosiga           บ Data ณ  04/23/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430RTX(cCodPrj,cRev)
Local aArea         := GetArea()
Local aAreaSN1      := SN1->(GetArea())
Local aAreaSN3      := SN3->(GetArea())
Local aAreaFNF      := FNF->(GetArea())
Local lRet          := .T.
Local cMensIni      := STR0142 + cCodPrj + STR0083+ cRev//" Revisใo de taxa projeto "##" revisใo: "
Local cProc         := __cProcPrinc + "REVTX"
Local cSubProc      := cCodPrj+cRev
Local cIdCV8        := ""

SN1->(dbSetOrder(9)) //N1_FILIAL+N1_PROJETO+N1_PROJREV+N1_PROJETP+N1_PROJITE+N1_CBASE+N1_ITEM
SN3->(dbSetOrder(11))//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO
FNF->(dbSetOrder(2)) //FNF_FILIAL+FNF_CBASE+FNF_ITEM+FNF_TIPO+FNF_SEQ+FNF_TPSALD+FNF_MOEDA+FNF_TPMOV+FNF_STATUS
FND->(dbSetOrder(1)) //FND_FILIAL+FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM

ProcLogIni( {},cProc,cSubProc,@cIdCV8 )
ProcLogAtu( "INICIO" , cMensIni ,,,.T.)

Begin Transaction

If AF430VerAtf(cCodPrj,cRev)
	If SN1->(MsSeek(xFilial("SN1") + cCodPrj + cRev ))

		While SN1->(!EOF()) .And. SN1->(N1_FILIAL+N1_PROJETO+N1_PROJREV) == xFilial("SN1") + cCodPrj + cRev

			If SN3->(MsSeek(xFilial("SN3") + SN1->N1_CBASE + SN1->N1_ITEM + "14" + "0") )

				While SN3->(!EOF()) .And. SN3->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA) == xFilial("SN3") + SN1->N1_CBASE + SN1->N1_ITEM + "14" + "0"

					If FNF->(MsSeek(xFilial("FNF") +  SN3->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_TPSALDO) + "01" + "1" + "1" ))

						If FND->(MsSeek(xFilial("FND") + SN1->(N1_PROJETO+N1_PROJREV+N1_PROJETP+N1_PROJITE) ))

							// Se a data inicial, taxa ou data final de AVP for diferente da original, realiza a revisใo
							If FNF->FNF_DTAVP != FND->FND_DTPROV .Or. FNF->FNF_INDAVP != FND->FND_INDAVP .Or. FNF->FNF_DTEXEC != FND->FND_PRVEXC
								AF440Grava(/*oGetRev*/,FNF->(RecNo()),/*lAprRev*/,FND->FND_INDAVP,FND->FND_DTPROV,.F.,.F., FND->FND_PRVEXC )
							EndIf

						EndIf

					EndIf

					SN3->(dbSkip())
				EndDo

			EndIf
			SN1->(dbSkip())
		EndDo
	EndIf
EndIf

If !lRet
	DisarmTransaction()
EndIf

End Transaction

ProcLogAtu( "FIM" ,,,,.T.)
ProcLogView(cFilAnt,cProc,cSubProc,cIdCV8)


RestArea(aAreaFNF)
RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430CancTxบAutorณAlvaro Camillo Neto บ Data ณ  23/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os valores originais de avp quando ้ cancelada      บฑฑ
ฑฑบ          ณa solicita็ใo de revisใo de AVP                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430CancTx(cCodPrj,cRev)

Local aArea         := GetArea()
Local aAreaSN1      := SN1->(GetArea())
Local aAreaSN3      := SN3->(GetArea())
Local aAreaFNF      := FNF->(GetArea())
Local aAreaFNB      := FNB->(GetArea())
Local aAreaFNC      := FNC->(GetArea())

SN1->(dbSetOrder(9)) //N1_FILIAL+N1_PROJETO+N1_PROJREV+N1_PROJETP+N1_PROJITE+N1_CBASE+N1_ITEM
SN3->(dbSetOrder(11))//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO
FNF->(dbSetOrder(2)) //FNF_FILIAL+FNF_CBASE+FNF_ITEM+FNF_TIPO+FNF_SEQ+FNF_TPSALD+FNF_MOEDA+FNF_TPMOV+FNF_STATUS
FND->(dbSetOrder(1)) //FND_FILIAL+FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM

Begin Transaction

If AF430VerAtf(cCodPrj,cRev)
	If SN1->(MsSeek(xFilial("SN1") + cCodPrj + cRev ))

		While SN1->(!EOF()) .And. SN1->(N1_FILIAL+N1_PROJETO+N1_PROJREV) == xFilial("SN1") + cCodPrj + cRev

			If SN3->(MsSeek(xFilial("SN3") + SN1->N1_CBASE + SN1->N1_ITEM + "14" + "0") )

				While SN3->(!EOF()) .And. SN3->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA) == xFilial("SN3") + SN1->N1_CBASE + SN1->N1_ITEM + "14" + "0"

					If FNF->(MsSeek(xFilial("FNF") +  SN3->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_TPSALDO) + "01" + "1" + "1" ))

						If FNB->(MsSeek(xFilial("FNB") + SN1->(N1_PROJETO+N1_PROJREV) ))
							RecLock("FNB",.F.)
								FNB->FNB_DTPROV := FNF->FNF_DTAVP
								FNB->FNB_INDAVP := FNF->FNF_INDAVP
								FNB->FNB_PRVEXC := FNF->FNF_DTEXEC
							MsUnLock()
						EndIf

						If FNC->(MsSeek(xFilial("FNC") + SN1->(N1_PROJETO+N1_PROJREV+N1_PROJETP) ))
							RecLock("FNC",.F.)
								FNC->FNC_DTPROV := FNF->FNF_DTAVP
								FNC->FNC_INDAVP := FNF->FNF_INDAVP
								FNC->FNC_PRVEXC := FNF->FNF_DTEXEC
							MsUnLock()
						EndIf

						If FND->(MsSeek(xFilial("FND") + SN1->(N1_PROJETO+N1_PROJREV+N1_PROJETP+N1_PROJITE) ))
							RecLock("FND",.F.)
								FND->FND_DTPROV := FNF->FNF_DTAVP
								FND->FND_INDAVP := FNF->FNF_INDAVP
								FND->FND_PRVEXC := FNF->FNF_DTEXEC
							MsUnLock()
						EndIf

					EndIf
					SN3->(dbSkip())
				EndDo
			EndIf
			SN1->(dbSkip())
		EndDo
	EndIf
EndIf

End Transaction


RestArea(aAreaFNC)
RestArea(aAreaFNB)
RestArea(aAreaFNF)
RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430REVGRบAutor  ณAlvaro Camillo Neto บ Data ณ  10/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a revisao do projeto, baixando as fichas do ativo   บฑฑ
ฑฑบ          ณda antiga revisao e alterando o status dela                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430REVGR(cCodPrj,cRev,lAprRev)
Local aArea			:= GetArea()
Local lRet			:= .T.
Local cMensIni		:= STR0084 + cCodPrj + STR0083+ cRev//" Revisใo do projeto "##" revisใo: "
Local cProc			:= __cProcPrinc + "REV"
Local cSubProc      := cCodPrj+cRev
Local cIdCV8        := ""
Local lAprov		:= .F.
Local aEtapa		:= {}
Local cDetalhe		:= ""
Local nX			:= 0
Local nY			:= 0
Local nRecFNB		:= 0
Local nRecFNB2		:= 0

Default lAprRev 	:= .F.

//Verifica se o controle de aprova็ใo estแ habilitado
If __lCtrlAprov
	lAprov := ATFxCtrlAprov("ATFA430","06")		//Revisar
EndIf

If (!lAprov .Or. lAprRev)

	ProcLogIni( {},cProc,cSubProc,@cIdCV8 )
	ProcLogAtu( "INICIO" , cMensIni ,,,.T.)

	Begin Transaction

	If AF430VerAtf(cCodPrj,cRev)
		lRet := AF430BxAtf(cCodPrj,cRev,"20",/*cEtapa*/,/*cItem*/,.T.,@aEtapa)
	EndIf

	//Altera o Status da Revisใo anterior para Bloqueado por Revisใo
	If lRet .And. !lAprRev
		lRet := AF430CriaRev(cCodPrj,cRev,cProc,@aEtapa)
		cRevNov := AF430GetRev(cCodPrj,'0')
		AF430DTREV(cCodPrj,cRevNov,dDataBase)
	EndIf

	//Altera o Status da Revisใo anterior para Bloqueado por Revisใo
	If lRet
		AF430FLAG(cCodPrj,cRev,"7")
		AF430DTENC(cCodPrj,cRev,dDataBase)
	EndIf

	//Altera o Status da Revisใo anterior para Bloqueado por Revisใo
	If lRet .And. lAprRev
		cRev := AF430GetRev(cCodPrj,'8')
		AF430FLAG(cCodPrj,cRev,"0")
	EndIf

	If !lRet
		DisarmTransaction()
	EndIf

	End Transaction

	If !lAprRev
		For nX := 1 to Len(aEtapa)
			cDetalhe 	:= ""
			aLogAux  := aEtapa[nX][5]
			For nY := 1 to Len(aLogAux)
				cDetalhe += aLogAux[nY]
			Next nY

			If !Empty(cDetalhe)
				ProcLogAtu("ERRO",STR0090 + aEtapa[nX][3] + STR0091 + aEtapa[nX][4] ,cDetalhe,,.F. )// " Etapa: "##" Item da Etapa: "
			EndIf
		Next nX
	EndIf

	ProcLogAtu( "FIM" ,,,,.T.)
	ProcLogView(cFilAnt,cProc,cSubProc,cIdCV8)
Else
	//Gera o movimento de aprova็ใo
	cOrigem := FunName()
	nRecFNB := FNB->(Recno())
	lRet := AF430CriaRev(cCodPrj,cRev)
	If lRet
		nRecFNB2 := FNB->(Recno())
		FNB->(DbGoTo(nRecFNB))
		lRet := AF004GrvMov("ATFA430","06",dDataBase,,,,cOrigem,"FNB",nRecFNB)
		FNB->(DbGoTo(nRecFNB2))
		If lRet
			cRev := AF430GetRev(cCodPrj)
			AF430FLAG(cCodPrj,cRev,"8")
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430CriaRevบAutor  ณAlvaro Camillo Neto บ Data ณ  10/27/11 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria a nova revisao do projeto                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430CriaRev(cCodPrj,cRev,cProc,aEtapa)
Local lRet 	:= .T.
Local aArea := GetArea()
Local oModel:= Nil
Local aLog	:= {}

Default cProc  := ""
Default aEtapa := {}

__nOper := OPER_REVISAR

dbSelectArea("FNB")
FNB->(dbSetOrder(1)) //FNB_FILIAL+FNB_CODPRJ+FNB_REVIS
If FNB->(MsSeek(xFilial("FNB") + cCodPrj + cRev))
	oModel := FWLoadModel( 'ATFA430' )
	oModel:SetOperation( 3 ) // Inclusใo
	oModel:Activate(.T.) // Ativa o modelo com os dados posicionados
	If ( lRet := oModel:VldData() )
		// Se o dados foram validados faz-se a grava็ใo efetiva dos dados (commit)
		oModel:CommitData()
	Else
		aErro   := oModel:GetErrorMessage()
		If !Empty(cProc)
			aAdd(aLog,STR0109 + ' [' + AllToChar( aErro[1]  ) + ']')//"Id do formulแrio de origem:"
			aAdd(aLog,STR0110 + ' [' + AllToChar( aErro[2]  ) + ']')//"Id do campo de origem:     "
			aAdd(aLog,STR0111 + ' [' + AllToChar( aErro[3]  ) + ']')//"Id do formulแrio de erro:  "
			aAdd(aLog,STR0112 + ' [' + AllToChar( aErro[4]  ) + ']')//"Id do campo de erro:       "
			aAdd(aLog,STR0113 + ' [' + AllToChar( aErro[5]  ) + ']')//"Id do erro:                "
			aAdd(aLog,STR0114 + ' [' + AllToChar( aErro[6]  ) + ']')//"Mensagem do erro:          "
			aAdd(aLog,STR0115 + ' [' + AllToChar( aErro[7]  ) + ']')//"Mensagem da solu็ใo:       "
			aAdd(aLog,STR0116 + ' [' + AllToChar( aErro[8]  ) + ']')//"Valor atribuido:           "
			aAdd(aLog,STR0117 + ' [' + AllToChar( aErro[9]  ) + ']')//"Valor anterior:            "
			aAdd(aEtapa, {cCodPrj,cRev,"","", aLog} )
		Else
			AutoGrLog( STR0109 + ' [' + AllToChar( aErro[1]  ) + ']' )//"Id do formulแrio de origem:"
			AutoGrLog( STR0110 + ' [' + AllToChar( aErro[2]  ) + ']' )//"Id do campo de origem:     "
			AutoGrLog( STR0111 + ' [' + AllToChar( aErro[3]  ) + ']' )//"Id do formulแrio de erro:  "
			AutoGrLog( STR0112 + ' [' + AllToChar( aErro[4]  ) + ']' )//"Id do campo de erro:       "
			AutoGrLog( STR0113 + ' [' + AllToChar( aErro[5]  ) + ']' )//"Id do erro:                "
			AutoGrLog( STR0114 + ' [' + AllToChar( aErro[6]  ) + ']' )//"Mensagem do erro:          "
			AutoGrLog( STR0115 + ' [' + AllToChar( aErro[7]  ) + ']' )//"Valor atribuido:           "
			AutoGrLog( STR0116 + ' [' + AllToChar( aErro[8]  ) + ']' )//"Valor atribuido:           "
			AutoGrLog( STR0117 + ' [' + AllToChar( aErro[9]  ) + ']' )//"Valor anterior:            "
			MostraErro()
		EndIf
	EndIf
	// Desativamos o Model
	oModel:DeActivate()
EndIf

__nOper := 0

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430BxAtfบAutor  ณAlvaro Camillo Neto บ Data ณ  10/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a baixa das fichas do ativo vinculadas ao projeto   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430BxAtf(cCodPrj,cRev,cMotivo,cEtapa,cItem,lTodos,aEtapa)
Local lRet 			:= .T.
Local aArea			:= GetArea()
Local aAreaSN1		:= SN1->(GetArea())
Local aAreaSN3		:= SN3->(GetArea())
Local cRotBaixa 	:= AllTrim(GetNewPar("MV_ATFRTBX", "ATFA030"))
Local aBaixa		:= {}
Local aParam030	:= {}
Local aLog			:= {}
Local xAtivo := {}
Local xCab := {}

Local nX				:= 0
Local cDetalhe			:= ""
Local nY				:= 0
Local bWhile		:= {|| }

Default cEtapa := ""
Default cItem	:= ""
Default lTodos := .T.
Default aEtapa		:= {}

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private lAutoErrNoFile := .T.

SN1->(dbSetOrder(9)) //N1_FILIAL+N1_PROJETO+N1_PROJREV+N1_PROJETP+N1_PROJITE+N1_CBASE+N1_ITEM
SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
FND->(dbSetOrder(1)) //FND_FILIAL+FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM

BEGIN TRANSACTION

aAdd( aParam030, {"MV_PAR01", 2} )
aAdd( aParam030, {"MV_PAR02", 2} )

If lTodos
	bSeek :={|| SN1->(MsSeek(xFilial("SN1") + cCodPrj + cRev)) }
Else
	bSeek :={|| SN1->(MsSeek(xFilial("SN1") + cCodPrj + cRev + cEtapa + cItem)) }
EndIf


If Eval(bSeek)

	If lTodos
		bWhile :={|| SN1->(!EOF()) .And. SN1->(N1_FILIAL+N1_PROJETO+N1_PROJREV) == xFilial("SN1") + cCodPrj + cRev }
	Else
		bWhile :={|| SN1->(!EOF()) .And. SN1->(N1_FILIAL+N1_PROJETO+N1_PROJREV+N1_PROJETP+N1_PROJITE) == xFilial("SN1") + cCodPrj + cRev + cEtapa + cItem}
	EndIf

	If FND->(MsSeek( xFilial("FND") + SN1->(N1_PROJETO+N1_PROJREV+N1_PROJETP+N1_PROJITE)))
		While Eval(bWhile)

			If Empty(SN1->N1_BAIXA) // Verifica se a ficha jแ nใo foi baixada
				aBaixa 		:= {}
				aLog			:= {}
				If SN3->(MsSeek( xFilial("SN3") + SN1->(N1_CBASE + N1_ITEM) ))
					xCab :={ 	{"FN6_FILIAL"	,xFilial("SN3")			,NIL},;
								{"FN6_CBASE"	,SN3->N3_CBASE		,NIL},;
								{"FN6_CITEM"	,SN3->N3_ITEM			,NIL},;
								{"FN6_MOTIVO"	,cMotivo				,NIL},;  
								{"FN6_BAIXA"	,100	,NIL},;  
								{"FN6_QTDATU" ,SN1->N1_QUANTD		,NIL},; 
								{"FN6_QTDBX"	,SN1->N1_QUANTD		,NIL},;
								{"FN6_DTBAIX"	,dDatabase			,NIL},;
								{"FN6_NUMNF"	,""					,NIL},;  
								{"FN6_SERIE"	,""					,NIL},;  
								{"FN6_PERCBX"	,100				,NIL},;
								{"FN6_VLVEND"	,SN3->N3_VORIG1		,NIL},;
								{"FN6_DEPREC"	,GETMV('MV_ATFDPBX')	,NIL}	 }
							
					xAtivo:={ 		{"N3_FILIAL"	, xFilial("SN3")		,NIL},;
								{"N3_CBASE"	, SN3->N3_CBASE	,NIL},;
								{"N3_ITEM"	, SN3->N3_ITEM		,NIL},;
						   	   	{"N3_TIPO"		, SN3->N3_TIPO		,NIL},;
								{"N3_BAIXA"     	, SN3->N3_BAIXA	,NIL},;
					   		  	{"N3_TPSALDO"	, SN3->N3_TPSALDO	,NIL} }
					

					//ณExecuta a Baixa do Bem ณ
					MsExecAuto({|a,b,c|ATFA036(a,b,c)},xCab,xAtivo,3)  

					If lMsErroAuto
						aLog := GETAUTOGRLOG()
						lMsErroAuto := .F.
						If lTodos
							DisarmTransaction()
						EndIf
						lRet := .F.
					Endif

					aAdd(aEtapa, {SN1->N1_PROJETO,SN1->N1_PROJREV,SN1->N1_PROJETP,SN1->N1_PROJITE, aLog} )

					If !lRet
						Exit
					EndIf
				EndIf
			EndIf
			SN1->(dbSkip())
		EndDo
	EndIf
EndIf

END TRANSACTION

If lTodos
	If lRet
		ProcLogAtu( "MENSAGEM",  STR0085 + cCodPrj + STR0086 + cRev + STR0089,,,.T. )//" As etapas do projeto "##" Revisใo: "##" foram encerradas corretamente "
	Else
		For nX := 1 to Len(aEtapa)
			cDetalhe 	:= ""
			aLogAux  := aEtapa[nX][5]
			For nY := 1 to Len(aLogAux)
				cDetalhe += aLogAux[nY]
			Next nY

			ProcLogAtu( IIF(Empty(cDetalhe),"MENSAGEM","ERRO"),STR0090 + aEtapa[nX][3] + STR0091 + aEtapa[nX][4] ,cDetalhe,,.F. )// " Etapa: "##" Item da Etapa: "
		Next nX
	EndIf
EndIf

RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430BLQGRบAutor  ณAlvaro Camillo Neto บ Data ณ  10/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a alteracao dos status dos itens do projeto e caso  บฑฑ
ฑฑบ          ณexista itens no ativo, realiza o bloqueio dos mesmos        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430BLQGR(cCodPrj,cRev)
Local aArea			:= GetArea()
Local aAreaFND		:= FND->(GetArea())
Local aAreaSN1		:= SN1->(GetArea())
Local cFlagAtivo 	:= "0"
Local cFlagBloq	:= "9"

FND->(dbSetOrder(1)) //FND_FILIAL+FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM
SN1->(dbSetOrder(9)) //N1_FILIAL+N1_PROJETO+N1_PROJREV+N1_PROJETP+N1_PROJITE+N1_CBASE+N1_ITEM

//Existem fichas atreladas ao projeto
If SN1->(MsSeek(xFilial("SN1") + cCodPrj + cRev))
	FND->(MsSeek( xFilial("FND") + cCodPrj + cRev ))
	While FND->(!EOF()) .And. FND->(FND_FILIAL+FND_CODPRJ+FND_REVIS) == xFilial("FND") + cCodPrj + cRev
		If SN1->(MsSeek(xFilial("SN1") + FND->(FND_CODPRJ + FND_REVIS + FND_ETAPA + FND_ITEM) ))
			RecLock("SN1",.F.)

			If FND->FND_MSBLQL == '1' // Bloqueado
				SN1->N1_STATUS := '2' // Bloqueado
			Else // Desbloqueado
				SN1->N1_STATUS := '1' // Em Uso
			EndIf

			MsUnLock()
		EndIf
		FND->(dbSkip())
	EndDo
	cFlagAtivo := "1"
Else
	cFlagAtivo := "0"
EndIf

AF430FLAG(cCodPrj,cRev,cFlagAtivo,.T.,cFlagBloq)

RestArea(aAreaFND)
RestArea(aAreaSN1)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430GerATบAutor  ณAlvaro Camillo Neto บ Data ณ  25/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo que realiza a grava็ใo das fichas do ativo do        บฑฑ
ฑฑบ          ณprocesso                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430GerAT(cCodPrj,cRev)
Local lRet		:= .T.
Local aCab  	:= {}
Local aItens	:= {}
Local aItensAux := {}
Local aParam	:= {}
Local cMoedaATF := Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1"))
Local aArea		:= GetArea()
Local aAreaFNB	:= FNB->(GetArea())
Local aAreaFNC	:= FNC->(GetArea())
Local aAreaFND	:= FND->(GetArea())
Local aAreaFNE	:= FNE->(GetArea())
Local cItem 	:= ""
Local dDataBkp  := dDataBase
Local aLog      := {}
Local aEtapa    := {}
Local nX        := 0
Local nY        := 0
Local cIdCV8    := ""
Local dDataAVP  := CTOD("")
Local lAvpAtf2  := AFAvpAtf2()
Local cMensIni  := STR0092 + cCodPrj + STR0083+ cRev //" Atualiza็ใo do projeto "##" revisใo: "
Local cProc     := __cProcPrinc + "ATU"
Local cSubProc     := cCodPrj+cRev
Local lExiUserCpo  := .T.

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private lAutoErrNoFile := .T.


ProcLogIni( {},cProc,cSubProc,@cIdCV8 )
ProcLogAtu( "INICIO" , cMensIni,,,.T. )

FNB->(dbSetOrder(1)) //FNB_FILIAL+FNB_CODPRJ+FNB_REVIS
FNC->(dbSetOrder(1)) //FNC_FILIAL+FNC_CODPRJ+FNC_REVIS+FNC_ETAPA
FND->(dbSetOrder(1)) //FND_FILIAL+FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM
FNE->(dbSetOrder(1)) //FNE_FILIAL+FNE_CODPRJ+FNE_REVIS+FNE_ETAPA+FNE_ITEM+FNE_LINHA

Begin Transaction

aAdd( aParam, {"MV_PAR01", 2} )
aAdd( aParam, {"MV_PAR02", 1} )
aAdd( aParam, {"MV_PAR03", 2} )

If FNB->(MsSeek( xFilial("FNB") + cCodPrj + cRev )) .And. FNC->(MsSeek( xFilial("FNC") + cCodPrj + cRev ))

	cItem := ATFXProxIt(cFilAnt,FNB->FNB_CBASE)

	While FNC->(!EOF()) .And. FNC->(FNC_FILIAL+FNC_CODPRJ+FNC_REVIS) == xFilial("FNC") + FNB->(FNB_CODPRJ+FNB_REVIS) .And. lRet
		lRet := FND->(MsSeek(xFilial("FND") + FNC->(FNC_CODPRJ+FNC_REVIS+FNC_ETAPA) ))

		While FND->(!EOF()) .And. FND->(FND_FILIAL+FND_CODPRJ+FND_REVIS+FND_ETAPA) == xFilial("FND") + FNC->(FNC_CODPRJ+FNC_REVIS+FNC_ETAPA) .And. lRet

			lRet := FNE->(MsSeek(xFilial("FNE") + FND->(FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM) ))

			dDataBase := FNB->FNB_DTINIC
			If lRet .And. FND->FND_MSBLQL != '1' .And. FND->FND_STATUS != '2' .And. FND->FND_CTRATF != '2' .And. Empty(FND->FND_DTENCR)
				If FND->FND_SBTIPO == "1" // Ativo Fixo
					cPatrim := "N"
				ElseIf FND->FND_SBTIPO == "2" // Intangํvel
					cPatrim := "I"
				ElseIf FND->FND_SBTIPO == "4" // Or็amento de Provisใo
			   		cPatrim := "O"
				Else //Diferido
					cPatrim := "D"
				EndIf

				aCab    := {}
				aItens  := {}
				aLog	  := {}
				dDataAVP := FND->FND_DTPROV

				AAdd(aCab,{"N1_CBASE"  	, FNB->FNB_CBASE	,NIL})
				AAdd(aCab,{"N1_ITEM"   	, cItem				,NIL})
				AAdd(aCab,{"N1_AQUISIC"	, FNB->FNB_DTINIC	,NIL})
				AAdd(aCab,{"N1_DESCRIC"	, FND->FND_DSCITE 	,NIL})
				AAdd(aCab,{"N1_QUANTD" 	, 1			  		,NIL})
				AAdd(aCab,{"N1_PATRIM" 	, cPatrim     		,NIL})
				AAdd(aCab,{"N1_GRUPO" 	, FNE->FNE_GRPBEM 	,NIL})
				AAdd(aCab,{"N1_STATUS" 	, "1"				,NIL})
				AAdd(aCab,{"N1_PROJETO"	, FND->FND_CODPRJ	,NIL})
				AAdd(aCab,{'N1_PROJREV'	, FND->FND_REVIS	,NIL})
				AAdd(aCab,{'N1_PROJETP'	, FND->FND_ETAPA	,NIL})
				AAdd(aCab,{'N1_PROJITE'	, FND->FND_ITEM		,NIL})
				AAdd(aCab,{'N1_LOCAL'	, FNB->FNB_LOCPRJ	,NIL})
				AAdd(aCab,{'N1_INDAVP'	, FND->FND_INDAVP	,NIL})
				AAdd(aCab,{'N1_INIAVP'	, dDataAVP      	,NIL})
				AAdd(aCab,{'N1_DTAVP'	, FND->FND_PRVEXC	,NIL})
				AAdd(aCab,{'N1_ORIGEM'	, "ATFA430"			,NIL})

				If lAvpAtf2
					AAdd(aCab,{'N1_TPAVP', FND->FND_TPAVP	,NIL})
				EndIf

				While FNE->(!EOF()) .And. FNE->(FNE_FILIAL+FNE_CODPRJ+FNE_REVIS+FNE_ETAPA+FNE_ITEM) == xFilial("FNE") + FND->(FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM) .And. lRet

					aItensAux := {}

					AAdd(aItensAux,{"N3_CBASE"	    , FNB->FNB_CBASE 	,NIL})
					AAdd(aItensAux,{"N3_ITEM"       , cItem				,NIL})
					AAdd(aItensAux,{"N3_TIPO"  		, FNE->FNE_TPATF 	,NIL})
					AAdd(aItensAux,{"N3_TPSALDO"    , FNE->FNE_TPSALD	,NIL})
					AAdd(aItensAux,{"N3_TPDEPR"  	, FNE->FNE_TPDEPR	,NIL})
					AAdd(aItensAux,{"N3_BAIXA" 		, "0"           	,NIL})
					AAdd(aItensAux,{"N3_HISTOR" 	, FND->FND_DSCITE	,NIL})
					AAdd(aItensAux,{"N3_CCONTAB" 	, FNE->FNE_ENT01B ,NIL})
					AAdd(aItensAux,{"N3_CUSTBEM" 	, FNE->FNE_ENT02B ,NIL})
					AAdd(aItensAux,{"N3_SUBCCON" 	, FNE->FNE_ENT03B ,NIL})
					AAdd(aItensAux,{"N3_CLVLCON" 	, FNE->FNE_ENT04B ,NIL})
					AAdd(aItensAux,{"N3_CDEPREC" 	, FNE->FNE_ENT01D ,NIL})
					AAdd(aItensAux,{"N3_CCDESP" 	, FNE->FNE_ENT02D ,NIL})
					AAdd(aItensAux,{"N3_SUBCDEP" 	, FNE->FNE_ENT03D ,NIL})
					AAdd(aItensAux,{"N3_CLVLDEP" 	, FNE->FNE_ENT04D ,NIL})
					AAdd(aItensAux,{"N3_CCDEPR" 	, FNE->FNE_ENT01A ,NIL})
					AAdd(aItensAux,{"N3_CCCDEP" 	, FNE->FNE_ENT02A ,NIL})
					AAdd(aItensAux,{"N3_SUBCCDE" 	, FNE->FNE_ENT03A ,NIL})
					AAdd(aItensAux,{"N3_CLVLCDE" 	, FNE->FNE_ENT04A ,NIL})
					AAdd(aItensAux,{"N3_DINDEPR" 	, FNE->FNE_DINDEP ,NIL})

					cMoedaPrj := cValToChar(Val(FNE->FNE_MOEDRF))
					AAdd(aItensAux,{"N3_VORIG"+cMoedaPrj , FNE->FNE_VORIG        	,NIL})
					AAdd(aItensAux,{IIF(cMoedaPrj <= '9',"N3_TXDEPR","N3_TXDEP") + cMoedaPrj , FNE->FNE_TAXA ,NIL})
					AAdd(aItensAux,{IIF(cMoedaPrj <= '9',"N3_VRDACM","N3_VRDAC") + cMoedaPrj , FNE->FNE_VRDACM ,NIL})

					If cMoedaPrj != cMoedaAtf
						nValorOri := xMoeda(FNE->FNE_VORIG,Val(cMoedaPrj),Val(cMoedaAtf),FNB->FNB_DTINIC)
						nDepAcm	 := xMoeda(FNE->FNE_VRDACM,Val(cMoedaPrj),Val(cMoedaAtf),FNB->FNB_DTINIC)
						AAdd(aItensAux,{"N3_VORIG"+cMoedaAtf , nValorOri ,NIL})
						AAdd(aItensAux,{IIF(cMoedaAtf <= '9',"N3_TXDEPR","N3_TXDEP") + cMoedaAtf , FNE->FNE_TAXA ,NIL})
						AAdd(aItensAux,{IIF(cMoedaPrj <= '9',"N3_VRDACM","N3_VRDAC") + cMoedaAtf , nDepAcm       ,NIL})
					EndIf

					If cMoedaPrj != "1"
						nValorOri := xMoeda(FNE->FNE_VORIG,Val(cMoedaPrj),1,FNB->FNB_DTINIC)
						nDepAcm	 := xMoeda(FNE->FNE_VRDACM,Val(cMoedaPrj),1,FNB->FNB_DTINIC)
						AAdd(aItensAux,{"N3_VORIG1"  , nValorOri     	,NIL})
						AAdd(aItensAux,{"N3_TXDEPR1" , FNE->FNE_TAXA   	,NIL})
						AAdd(aItensAux,{"N3_VRDACM1" , nDepAcm       ,NIL})
					EndIf

					AAdd(aItensAux,{'N3_PERDEPR'	, FNE->FNE_PERDEP ,NIL})
					AAdd(aItensAux,{'N3_VMXDEPR'	, FNE->FNE_VLMXDP ,NIL})
					AAdd(aItensAux,{'N3_VLSALV1'	, FNE->FNE_VLSALV ,NIL})
					AAdd(aItensAux,{'N3_PRODANO'	, FNE->FNE_PRDEST ,NIL})
					AAdd(aItensAux,{'N3_CODIND'		, FNE->FNE_CODIND ,NIL})
					If (lExiUserCpo .And. !Empty(FNE->FNE_USRAVP)) .OR. (FNE->FNE_REVIS != '0001')
						AAdd(aItensAux,{"N3AVPPLAN" 	, FNE->FNE_AVPPLN ,NIL})
					EndIf
					AAdd(aItensAux,{"N3AVPREAL" 	, FNE->FNE_AVPRLZ ,NIL})

					aAdd(aItens,aItensAux)
					FNE->(dbSkip())
				EndDo

				MSExecAuto({|x,y,z,w| Atfa012(x,y,z,w)},aCab,aItens,3,aParam)
				cItem := ATFXProxIt(cFilAnt,FNB->FNB_CBASE)

				If lMsErroAuto
					aLog := GETAUTOGRLOG()
					lMsErroAuto := .F.
					DisarmTransaction()
					lRet := .F.
				Endif

				aAdd(aEtapa, {FND->FND_CODPRJ,FND->FND_REVIS,FND->FND_ETAPA,FND->FND_ITEM, aLog} )

				If !lRet
					Exit
				EndIf

			EndIf
			FND->(dbSkip())
		EndDo

		FNC->(dbSkip())
	EndDo
Else
	Help(" ",1,"AF430ATFL",,STR0057 ,1,0)//"C๓digo do projeto nใo encontrado"
	lRet := .F.
EndIf

End Transaction

If lRet
	ProcLogAtu( "MENSAGEM",  STR0085 + cCodPrj + STR0086 + cRev + STR0093,,,.T. ) //" As etapas do projeto "##" Revisใo: "##" foram atualizadas corretamente "
Else
	For nX := 1 to Len(aEtapa)
		cDetalhe 	:= ""
		aLogAux  := aEtapa[nX][5]
		For nY := 1 to Len(aLogAux)
			cDetalhe += aLogAux[nY]
		Next nY

		ProcLogAtu( IIF(Empty(cDetalhe),"MENSAGEM","ERRO"), STR0090 + aEtapa[nX][3] + STR0091 + aEtapa[nX][4] ,cDetalhe,,.F. ) // " Etapa: "##" Item da Etapa: "
	Next nX
EndIf
If lRet
	AF430FLAG(cCodPrj,cRev,"1")
EndIf

ProcLogAtu( "FIM" ,,,,.T.)
ProcLogView(cFilAnt,cProc,cSubProc,cIdCV8)

dDataBase := dDataBkp

RestArea(aAreaFNE)
RestArea(aAreaFND)
RestArea(aAreaFNC)
RestArea(aAreaFNB)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430ENCVL  บAutor  ณAlvaro Camillo Neto บ Data ณ  11/21/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
1ฑบDesc.     ณ Realiza a valida็ใo do encerramento da etapa               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430ENCVL(cCodPrj,cRev)
Local lRet 		:= .T.
Local oView		:= FWViewActive()
Local aEtapa	:= {}
Local nX			:= 0
Local nY			:= 0
Local cDetalhe := ""
Local aLogAux  := {}
Local cMensIni		:= STR0082 + cCodPrj + STR0083+ cRev//" Encerramento do projeto "##" revisใo: "
Local cProc			:= __cProcPrinc + "ENCETP"
Local cSubProc    := cCodPrj+cRev
Local cIdCV8        := ""

If lRet
	lRet := VerItEnc()
EndIf


If lRet
	lRet := MsgNoYes(STR0095)//"Deseja realizar o encerramento das etapas ? "
EndIf

If lRet
	ProcLogIni( {},cProc,cSubProc,@cIdCV8 )
	ProcLogAtu( "INICIO" , cMensIni ,,,.T. )
	MsgRun( STR0059 ,, {||lRet := GrvEncEtp(@aEtapa) } ) //"Processando Encerramento do Projeto..."

	If lRet
		ProcLogAtu( "MENSAGEM",  STR0085 + cCodPrj + STR0086 + cRev + STR0089,,,.T. ) //" As etapas do projeto "##" Revisใo: "##" foram encerradas corretamente "
	Else
		For nX := 1 to Len(aEtapa)
			cDetalhe := ""
			aLogAux  := aEtapa[nX][5]
			For nY := 1 to Len(aLogAux)
				cDetalhe += aLogAux[nY]
			Next nY

			ProcLogAtu( IIF(Empty(cDetalhe),"MENSAGEM","ERRO"), STR0090 + aEtapa[nX][3] + STR0091 + aEtapa[nX][4] ,cDetalhe,,.F. ) // " Etapa: "##" Item da Etapa: "

		Next nX
	ENdIf

	ProcLogAtu( "FIM" ,,,,.T.)
	If oView <> Nil
		ProcLogView(cFilAnt,cProc,cSubProc,cIdCV8)
	EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerItEnc  บAutor  ณMicrosiga           บ Data ณ  12/13/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se algum item foi selecionado para encerramento   บฑฑ
ฑฑบ          ณ da etapa                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VerItEnc()
Local lRet 			:= .F.
Local oModel   		:= FWModelActive()
Local oModelFNC		:= oModel:GetModel("FNCDETAIL")
Local oModelFND		:= oModel:GetModel("FNDDETAIL")
Local aSaveLines	:= FWSaveRows()
Local nX			:= 0
Local nY			:= 0

For nX := 1 To oModelFNC:Length()
	oModelFNC:GoLine( nX )
	For nY := 1 To oModelFND:Length()
		oModelFND:GoLine( nY )

		If  !Empty(oModelFND:GetValue("FND_DTENCR")) .And. oModelFND:GetValue("FND_STATUS") $ '0/1'
			lRet  := .T.
		EndIf

		If lRet
			Exit
		EndIf
	Next nY
	If lRet
		Exit
	EndIf
Next nX

If !lRet
	Help(" ",1,"AF430ENCETP",,STR0132,1,0)//"Nenhuma etapa/item foi selecionado para encerramento."
EndIf

FWRestRows(aSaveLines)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerTdEnc  บAutor  ณAlvaro Camillo Neto บ Data ณ  02/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออeฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se todos items do projeto estใo encerrados         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VerTdEnc(cCodPrj,cRev)
Local lRet      := .F.
Local cQuery    := ""
Local cAliasTMP := GetNextAlias()
Local aArea     := GetArea()

cQuery    += " SELECT                                    " + CRLF
cQuery    += "     COUNT(*) ETP_ATIVA                    " + CRLF
cQuery    += " FROM "+RetSQLName("FND")+" FND            " + CRLF
cQuery    += " WHERE                                     " + CRLF
cQuery    += "     FND_FILIAL = '"+xFilial("FND")+"' AND " + CRLF
cQuery    += "     FND_CODPRJ = '"+cCodPrj+"'        AND " + CRLF
cQuery    += "     FND_REVIS  = '"+cRev+"'           AND " + CRLF
cQuery    += "     FND_DTENCR = ''                   AND " + CRLF
cQuery    += "     FND.D_E_L_E_T_ = ''                   " + CRLF

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)

If (cAliasTMP)->ETP_ATIVA == 0
	lRet := .T.
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrvEncEtp  บAutor  ณAlvaro Camillo Neto บ Data ณ  11/21/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava o encerramento das etapas                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrvEncEtp(aEtapa)
Local lRet 			:= .T.
Local oModel   		:= FWModelActive()
Local oModelFNC		:= oModel:GetModel("FNCDETAIL")
Local oModelFND		:= oModel:GetModel("FNDDETAIL")
Local aSaveLines	:= FWSaveRows()
Local nX			:= 0
Local nY			:= 0
Local cCodPrj     	:= ""
Local cRev     		:= ""
Local cMotivo     	:= ""
Local cEtapa    	:= ""
Local cItem     	:= ""
Default aEtapa		:= {}

FND->(dbSetOrder(1)) //FND_FILIAL+FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM
Begin Transaction
For nX := 1 To oModelFNC:Length()
	oModelFNC:GoLine( nX )
	For nY := 1 To oModelFND:Length()
		oModelFND:GoLine( nY )
		cCodPrj     := oModelFND:GetValue("FND_CODPRJ")
		cRev     	:= oModelFND:GetValue("FND_REVIS")
		cMotivo     := "21"
		cEtapa    	:= oModelFND:GetValue("FND_ETAPA")
		cItem     	:= oModelFND:GetValue("FND_ITEM")

		If  !Empty(oModelFND:GetValue("FND_DTENCR")) .And. oModelFND:GetValue("FND_STATUS") $ '0/1'
			lRet  := AF430BxAtf(cCodPrj,cRev,cMotivo,cEtapa,cItem,.F.,@aEtapa)
		EndIf

		If !lRet
			DisarmTransaction()
			Exit
		EndIf

	Next nY

	If !lRet
		Exit
	EndIf

Next nX

End Transaction

FWRestRows(aSaveLines)
Return lRet

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRotina de Importa็ใo / Exporta็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImportPrj บAutor  ณAlvaro Camillo Neto บ Data ณ  21/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a exporta็ใo do projeto de imobilizado             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImportPrj(cArq,lRevisa,lMostra)
Local lRet 		:= .T.
Local nHandle  	:= 0
Local aTabela	:= {}
Local aLinha	:= {}
Local aEstruct	:= {}
Local aDados	:= {}
Local aDadosAux	:= {}
Local cTabela	:= ""
Local nX		:= 0
Local nY		:= 0
Local nEtapa 	:= 0
Local nItem  	:= 0
Local nCfg		:= 0
Local aFNB		:= {}
Local aFNC 		:= {}
Local aFND 		:= {}
Local aFNE 		:= {}
Local cMensIni	:= STR0096 + cArq //"Importando projeto do Arquivo "
Local cProc		:= __cProcPrinc + "IMP"
Local cIdCV8    := ""
Local cSubProc	:= ""
Local cArqDest  := ""
Local cExt		:= ""
Default lRevisa := .F.

SplitPath(cArq,,,@cArqDest,@cExt)

cSubProc := Alltrim(cArqDest+cExt)

ProcLogIni( {},cProc,cSubProc, @cIdCV8 )

ProcLogAtu( "INICIO" , cMensIni ,,,.T. )

If (nHandle := FT_FUse(AllTrim(cArq)))== -1
	Help(" ",1,"NOFILEIMPOR")
	lRet:= .F.
EndIf

If lRet
	nTot:=FT_FLASTREC()
	FT_FGOTOP()

	//Realiza a Leitura da 1 linha para capturar as tabelas
	aLinha := AF430RDLN()
	FT_FSKIP()

	If Alltrim(aLinha[1]) != "0"
		Aviso(STR0097,STR0098,{STR0099})//"Estrutura incorreta."##"Cabecalho nao encontrado"##"Abandona"
		lRet := .F.
	EndIf

	If lRet
		For nX := 2 to Len(aLinha)
			AADD( aTabela, {aLinha[nX], {} } )
		Next nX
	EndIf

	// Carrega a estrutura da tabela
	If lRet
		For nX := 1 to Len(aTabela)
			aLinha := AF430RDLN()
			aEstruct := {}

			For nY := 2 to Len(aLinha)
				aAdd(aEstruct,aLinha[nY])
			Next nX

			aTabela[nX][2] := aClone(aEstruct)

			FT_FSKIP()
		Next nX
	EndIf

	//Realiza a Leitura dos dados
	Do While lRet .And. !FT_FEOF()

		aLinha := AF430RDLN()

		If Len(aLinha) <= 0
			FT_FSKIP()
			Loop
		EndIf

		nId := Val(aLinha[1])

		If nId <= 0 .Or. nId > Len(aTabela)
			lRet:= .F.
			Aviso(STR0097,STR0100,{STR0099})//"Estrutura incorreta."##"1บ Elemento da Linha nใo contem Id da Tabela, por favor conferir layout"##"Abandona"
			Exit
		EndIf

		aDel(aLinha,1)
		aSize(aLinha,Len(aLinha)-1)

		cTabela	:= Alltrim(aTabela[nId][1])
		aEstruct := aTabela[nId][2]

		If ( Len(aLinha) ) != Len( aEstruct )
			lRet:= .F.
			Aviso(STR0097,STR0101,{STR0099})//"Estrutura incorreta."##"Quantidade de colunas de dados nใo confere com a quantidade de campos configurados nas primeiras linhas"##"Abandona"
			Exit
		EndIf

		aDadosAux := {}

		For nX := 1 to Len(aLinha)
			aAdd(aDadosAux,{ aEstruct[nX] , aLinha[nX] } )
		Next nX

		// Prepara as informa็๕es
		// Convertendo para os tipos corretos e verificando se o campo existe no dicionario
		aDados := AF430Dado(cTabela,aDadosAux)

		If cTabela == "FNB"

			aFNB := aClone(aDados)

		ElseIf cTabela == "FNC"

			If (nEtapa := aScan( aDados, { |x| AllTrim( x[1] ) ==  "FNC_ETAPA" } ) ) > 0
				aAdd(aFNC, { aDados[nEtapa][2] , aClone(aDados) } )
			EndIf

		ElseIf cTabela == "FND"
			If (nEtapa := aScan( aDados, { |x| AllTrim( x[1] ) ==  "FND_ETAPA" } ) ) > 0 .And.;
				(nItem := aScan( aDados, { |x| AllTrim( x[1] ) ==  "FND_ITEM" } ) ) > 0

				aAdd(aFND, { aDados[nEtapa][2] ,aDados[nItem][2] , aClone(aDados) } )

			EndIf
		ElseIf cTabela == "FNE"
			If (nEtapa := aScan( aDados, { |x| AllTrim( x[1] ) ==  "FNE_ETAPA" } ) ) > 0 .And.;
				(nItem := aScan( aDados, { |x| AllTrim( x[1] ) ==  "FNE_ITEM" } ) ) > 0 .And. ;
				(nCfg := aScan( aDados, { |x| AllTrim( x[1] ) ==  "FNE_LINHA" } ) ) > 0

				aAdd(aFNE, { aDados[nEtapa][2] ,aDados[nItem][2] , aDados[nCfg][2] , aClone(aDados) } )

			EndIf
		EndIf

		FT_FSKIP()
	EndDo

	FT_FUSE()

	If lRet
		lRet := AFA430AUT(aFNB,aFNC,aFND,aFNE,3,lMostra,cProc,lRevisa)
	EndIf

EndIf

ProcLogAtu( "FIM" ,,,,.T.)
If !lRet
	ProcLogView(,cProc,cSubProc,cIdCV8)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExportPrj บAutor  ณAlvaro Camillo Neto บ Data ณ  21/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a exporta็ใo do projeto de imobilizado             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ExportPrj(cCodPrj,cRev,cArq)
Local lRet 		:= .T.
Local aArea		:= GetArea()
Local aAreaFNB	:= FNB->(GetArea())
Local aAreaFNC	:= FNC->(GetArea())
Local aAreaFND	:= FND->(GetArea())
Local aAreaFNE	:= FNE->(GetArea())
Local aTabela	:= {}
Local nX			:= 0
Local nY			:= 0
Local cID		:= ""
Local cLin		:= ""

Local aStrFNB	:= FNB->(DbStruct())
Local aStrFNC	:= FNC->(DbStruct())
Local aStrFND	:= FND->(DbStruct())
Local aStrFNE	:= FNE->(DbStruct())

Default cArq := ""

FNB->(dbSetOrder(1)) //FNB_FILIAL+FNB_CODPRJ+FNB_REVIS
FNC->(dbSetOrder(1)) //FNC_FILIAL+FNC_CODPRJ+FNC_REVIS+FNC_ETAPA
FND->(dbSetOrder(1)) //FND_FILIAL+FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM
FNE->(dbSetOrder(1)) //FNE_FILIAL+FNE_CODPRJ+FNE_REVIS+FNE_ETAPA+FNE_ITEM+FNE_LINHA

If lRet .And. FNB->(!MsSeek( xFilial("FNB") + cCodPrj + cRev ))
	Help(" ",1,"AF430IMP01",,STR0102 ,1,0)//"Projeto nใo encontrado"
	lRet := .F.
EndIf

IF lRet .And. Empty( cArq )
	Help(" ",1,"AF430IMP02",,STR0103 ,1,0)//"Arquivo nao informado!"
	lRet := .F.
Endif

If lRet

	aAdd(aTabela,{"FNB",aStrFNB})
	aAdd(aTabela,{"FNC",aStrFNC})
	aAdd(aTabela,{"FND",aStrFND})
	aAdd(aTabela,{"FNE",aStrFNE})

	If At('.',cArq) == 0
		cArq	:=	AllTrim(cArq)+'.CSV'
	EndIf

	If (nHandle := FCreate(cArq))== -1
		Help(" ",1,"AF430IMP03",,STR0104 ,1,0)//"Erro na criacao do arquivo!"
		Return
	EndIf

	// Lista de tabelas
	cLin:="0"
	For nY := 1 to len(aTabela)
		cLin += ';'+aTabela[nY,1]
	Next
	cLin += CRLF
	FWrite(nHandle,cLin,Len(cLin))

	//Lista de Campos das tabelas
	For nY := 1 to len(aTabela)
		cId		:= Alltrim(str(nY))
		cLin 		:= cId
		aStruct	:= aTabela[nY,2]
		For nX:=1 To Len(aStruct)
			cLin	+=	';'+aStruct[nX,1]
		Next nX
		cLin += CRLF
		FWrite(nHandle,cLin,Len(cLin))
	Next nY

	FNB->(!MsSeek( xFilial("FNB") + cCodPrj + cRev ))
	While FNB->(!EOF()) .And. FNB->(FNB_FILIAL+FNB_CODPRJ+FNB_REVIS) == xFilial("FNB") + cCodPrj + cRev

		cID	:= "1"
		cLin  := ExpLinPrj("FNB", aStrFNB, FNB->(Recno()),cId )
		FWrite(nHandle,cLin,Len(cLin))

		FNC->(MsSeek(  xFilial("FNC") + FNB->(FNB_CODPRJ+FNB_REVIS) ))
		While FNC->(!EOF()) .And. FNC->(FNC_FILIAL+FNC_CODPRJ+FNC_REVIS) == xFilial("FNC") + FNB->(FNB_CODPRJ+FNB_REVIS)

			cID	:= "2"
			cLin  := ExpLinPrj("FNC", aStrFNC, FNC->(Recno()),cId )
			FWrite(nHandle,cLin,Len(cLin))

			FND->(MsSeek(xFilial("FND") + FNC->(FNC_CODPRJ+FNC_REVIS+FNC_ETAPA) ))
			While FND->(!EOF()) .And. FND->(FND_FILIAL+FND_CODPRJ+FND_REVIS+FND_ETAPA) == xFilial("FND") + FNC->(FNC_CODPRJ+FNC_REVIS+FNC_ETAPA)

				cID	:= "3"
				cLin  := ExpLinPrj("FND", aStrFND, FND->(Recno()),cId )
				FWrite(nHandle,cLin,Len(cLin))

				FNE->(MsSeek(xFilial("FNE") + FND->(FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM) ))
				While FNE->(!EOF()) .And. FNE->(FNE_FILIAL+FNE_CODPRJ+FNE_REVIS+FNE_ETAPA+FNE_ITEM) == xFilial("FNE") + FND->(FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM)

					cID	:= "4"
					cLin  := ExpLinPrj("FNE", aStrFNE, FNE->(Recno()),cId )
					FWrite(nHandle,cLin,Len(cLin))

					FNE->(dbSkip())
				EndDo

				FND->(dbSkip())
			EndDo

			FNC->(dbSkip())
		EndDo

		FNB->(dbSkip())
	EndDo

	FClose(nHandle)

	Aviso(STR0105,STR0106,{STR0107})//"Finalizado"##"Exportacao gerada com sucesso"##"Ok"

EndIf

RestArea(aAreaFNE)
RestArea(aAreaFND)
RestArea(aAreaFNC)
RestArea(aAreaFNB)
RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExpLinPrj บAutor  ณAlvaro Camillo Neto บ Data ณ  21/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a linha do arquivo para exporta็ใo                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ExpLinPrj(cTab, aStruct, nRecno,cId)
Local aArea := GetArea()
Local cRet	:= ""
Local nX		:= 0

DbSelectArea(cTab)
(cTab)->(DbGoTo(nRecno))

cRet :=cId
For nX := 1 To Len(aStruct)
	Do Case
		Case aStruct[nX,2] == "C"
			cRet += ';'+(cTab)->( FieldGet(FieldPos(aStruct[nX,1])) )
		Case aStruct[nX,2] == "L"
			cRet += ';'+(cTab)->(IIf(FieldGet(FieldPos(aStruct[nX,1])),"T","F"))
		Case aStruct[nX,2] == "D"
			cRet += ';'+(cTab)->(Dtos(FieldGet(FieldPos(aStruct[nX,1]))))
		Case aStruct[nX,2] == "N"
			cRet += ';'+(cTab)->(Str(FieldGet(FieldPos(aStruct[nX,1]))))
		Otherwise
			cRet += ';'
	EndCase
Next
cRet += CRLF


RestArea(aArea)
Return cRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA430AUT บAutor  ณAlvaro Camillo Neto บ Data ณ  21/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de cria็ใo automatica de projetos.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ
ฑฑบ          ณParametros:
ฑฑบ          ณEstruta dos Arrays
ฑฑบ          ณaFNB
ฑฑบ          ณ[ [ cCampo , xConteudo ] ]
ฑฑบ          ณ[ [ cCampo , xConteudo ] ]
ฑฑบ          ณ
ฑฑบ          ณaFNC
ฑฑบ          ณ[ cEtapa , [ [cCampo , xConteudo ] ] ]
ฑฑบ          ณ[ cEtapa , [ [cCampo , xConteudo ] ] ]
ฑฑบ          ณ
ฑฑบ          ณaFND
ฑฑบ          ณ[ cEtapa ,cItem ,[ [ cCampo , xConteudo] ] ]
ฑฑบ          ณ[ cEtapa ,cItem ,[ [ cCampo , xConteudo] ] ]
ฑฑบ          ณ
ฑฑบ          ณaFNE
ฑฑบ          ณ[ cEtapa ,cItem , cLinha , [ [cCampo , xConteudo] ]  ]
ฑฑบ          ณ[ cEtapa ,cItem , cLinha , [ [cCampo , xConteudo] ]  ]
ฑฑบ          ณ
ฑฑบ          ณnOperation : Op็ใo para executar a importa็ใo
ฑฑบ          ณ
ฑฑบ          ณlMostra : se mostra o projeto ap๓s importa็ใo para manuten็ใo ou importa direto
ฑฑบ          ณ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AFA430AUT(aFNB,aFNC,aFND,aFNE,nOperation,lMostra,cProc,lRevisa)
Local lRet 			:= .T.
Local nCampo		:= 0
Local nEtapa   		:= 0
Local nItem			:= 0
Local nCFG 			:= 0
Local oModel		:= Nil
Local oModelFNB		:= Nil
Local oModelFNC		:= Nil
Local oModelFND		:= Nil
Local oModelFNE		:= Nil
Local aCpoFNB  		:= {}
Local aCpoFNC 		:= {}
Local aCpoFND 		:= {}
Local aCpoFNE 		:= {}
Local aAuxFNC 	 	:= {}
Local aAuxFND 		:= {}
Local aAuxFNE 		:= {}
Local nLinFNC		:= 0
Local nLinFND		:= 0
Local nLinFNE		:= 0
Local nPos			:= 0
Local cDetalhe		:= ""
Local aArea			:= GetArea()
Local aAreaFNB		:= FNB->(GetArea())
Local aAreaSN1		:= SN1->(GetArea())
Local cCodPrj		:= ""
Local lExistPrj		:= .F.
Local lAprov		:= .F.
Local nOper

Local nItErro		:= 0

Default nOperation   := MODEL_OPERATION_INSERT
Default lMostra 		:= .T.
Default lRevisa 		:= .F.

//Verifica se o controle de aprova็ใo estแ habilitado
If __lCtrlAprov
	lAprov := ATFxCtrlAprov("ATFA430","06")		//Revisar
EndIf

//Ordena็ใo dos array de entrada
aSort(aFNC,,,{|x,y| x[1] < y[1] })
aSort(aFND,,,{|x,y| x[1]+x[2] < y[1]+y[2] })
aSort(aFNE,,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] })

//Busca a chave do projeto
If (nPos := aScan( aFNB, { |x| AllTrim( x[1] ) ==  AllTrim( "FNB_CODPRJ" ) } ) ) > 0
	cCodPrj := aFNB[nPos][2]
EndIf

FNB->(DBSetOrder(1)) ////FNB_FILIAL+FNB_CODPRJ+FNB_REVIS

lExistPrj := FNB->(MSSeek(xFilial("FNB") + cCodPrj ))


If lExistPrj .And. lRevisa // Projeto existente e serแ revisado
	__nOper := OPER_REVISAR
	If lRet .And. !Empty(AF430GetRev(cCodPrj,'8'))
		Help(" ",1,"AF430REVAPR",,STR0134 ,1,0)//"Jแ existe revisใo em processo de aprova็ใo"
		lRet := .F.
	EndIf
ElseIf lExistPrj //  Retorno da fun็ใo
	lRet := .F.
	Help(" ",1,"AF430IMPNAO",,STR0124 ,1,0)//"Projeto jแ cadastrado, por favor utilize a op็ใo de criar revisใo como Sim"
EndIf

If lRet
	oModel := FWLoadModel( 'ATFA430' )
	oModel:SetOperation( nOperation )
	lRet := oModel:Activate()
EndIf

If lRet
	oModelFNB	:= oModel:GetModel( "FNBMASTER" )
	oModelFNC	:= oModel:GetModel( "FNCDETAIL" )
	oModelFND	:= oModel:GetModel( "FNDDETAIL" )
	oModelFNE	:= oModel:GetModel( "FNEDETAIL" )

	aCpoFNB	:= oModelFNB:GetStruct():GetFields()
	aCpoFNC	:= oModelFNC:GetStruct():GetFields()
	aCpoFND	:= oModelFND:GetStruct():GetFields()
	aCpoFNE	:= oModelFNE:GetStruct():GetFields()
EndIf


//Carrega Cabe็alho do Projeto
If lRet
	For nCampo := 1 To Len( aFNB )
		If ( nPos := aScan( aCpoFNB, { |x| AllTrim( x[3] ) ==  AllTrim( aFNB[nCampo][1] ) } ) ) > 0
			If !( lAux := AF430SetVl(oModelFNB,aFNB[nCampo][1], aFNB[nCampo][2] ) )
				lRet    := .F.
				Exit
			EndIf
		EndIf
	Next nCampo
EndIf

If lRet
	nLinFNC := 1

	For nEtapa := 1 To Len( aFNC )
		aDadosFNC := aFNC[nEtapa][2]
		cEtpFNC	 := aFNC[nEtapa][1]

		If nLinFNC > 1
			// Incluimos uma nova linha de item
			If  ( nItErro := oModelFNC:AddLine() ) != nLinFNC
				// Se por algum motivo o metodo AddLine() nใo consegue incluir a linha,
				// ele retorna a quantidade de linhas jแ
				// existem no grid. Se conseguir retorna a quantidade mais 1
				lRet    := .F.
				Exit
			EndIf
		EndIf

		For nCampo := 1 To Len( aDadosFNC )
			If ( nPos := aScan( aCpoFNC, { |x| AllTrim( x[3] ) ==  AllTrim( aDadosFNC[nCampo][1] ) } ) ) > 0
				If !( lAux := AF430SetVl(oModelFNC,aDadosFNC[nCampo][1], aDadosFNC[nCampo][2] ) )
					lRet    := .F.
					nItErro := nLinFNC
					Exit
				EndIf
			EndIf
		Next nCampo

		nLinFNC++

		If !lRet
			Exit
		EndIf

		//Busca a Etapa no Array de Item de Etapa
		If ( nPosItm := aScan( aFND , { |x| AllTrim( x[1] ) ==  AllTrim( cEtpFNC ) } ) ) > 0

			nLinFND := 1

			For nItem := nPosItm to Len(aFND)

				cEtpFND 		:= aFND[nItem][1]
				cItmFND 		:= aFND[nItem][2]
				aDadosFND 		:= aFND[nItem][3]

				If !lRet .Or. Alltrim(cEtpFNC) != Alltrim(cEtpFND)
					Exit
				EndIf

				If nLinFND > 1
					If  ( nItErro := oModelFND:AddLine() ) != nLinFND
						lRet    := .F.
						Exit
					EndIf
				EndIf

				For nCampo := 1 To Len( aDadosFND )
					If ( nPos := aScan( aCpoFND, { |x| AllTrim( x[3] ) ==  AllTrim( aDadosFND[nCampo][1] ) } ) ) > 0
						If !( lAux := AF430SetVl(oModelFND,aDadosFND[nCampo][1], aDadosFND[nCampo][2] ) )
							lRet    := .F.
							nItErro := nLinFND
							Exit
						EndIf
					EndIf
				Next nCampo

				nLinFND++


				//Busca o Item no Array de Configura็ใo CTB
				If ( nPosCfg := aScan( aFNE , { |x| AllTrim( x[1] ) + AllTrim( x[2] )  ==  AllTrim( cEtpFND ) + AllTrim( cItmFND ) } ) ) > 0

					nLinFNE := 1

					For nCFG := nPosCfg to Len(aFNE)

						cEtpFNE 		:= aFNE[nCFG][1]
						cItmFNE 		:= aFNE[nCFG][2]
						cCfgFNE 		:= aFNE[nCFG][3]
						aDadosFNE 		:= aFNE[nCFG][4]

						If !lRet .Or. Alltrim(cEtpFND) + Alltrim(cItmFND)  != Alltrim(cEtpFNE) + Alltrim(cItmFNE)
							Exit
						EndIf

						If nLinFNE > 1
							If  ( nItErro := oModelFNE:AddLine() ) != nLinFNE
								lRet    := .F.
								Exit
							EndIf
						EndIf

						For nCampo := 1 To Len( aDadosFNE )
							If ( nPos := aScan( aCpoFNE, { |x| AllTrim( x[3] ) ==  AllTrim( aDadosFNE[nCampo][1] ) } ) ) > 0
								If !( lAux := AF430SetVl(oModelFNE,aDadosFNE[nCampo][1], aDadosFNE[nCampo][2] ) )
									lRet    := .F.
									nItErro := nLinFNE
									Exit
								EndIf
							EndIf
						Next nCampo

						nLinFNE++

					Next nCFG
					If !lRet
						Exit
					EndIf
				Else // Para permitir imprimir projeto sem configura็ใo contแbil
					oModelFNE:LoadValue("FNE_LINHA", StrZero(1,TamSX3("FNE_LINHA")[1]) )
					oModelFND:LoadValue("FND_CTRATF",'2')
				EndIf

			Next nItem
			If !lRet
				Exit
			EndIf
		EndIf

	Next nEtapa

EndIf

If lRet .And. oModel:VldData()

	cCodPrj := oModelFNB:GetValue("FNB_CODPRJ")
	cRev    := oModelFNB:GetValue("FNB_REVIS")

	If __nOper == OPER_REVISAR

		cRevAnt := AF430GetRev(cCodPrj,'1')
		If Empty(cRevAnt)
			cRevAnt := AF430GetRev(cCodPrj,'0')
		EndIf

		If lAprov
			//Gera o movimento de aprova็ใo
			lRet := AF430IMAPR(cCodPrj,cRevAnt)
			If lRet
				oModel:CommitData()
				AF430FLAG(cCodPrj,cRev,"8")
			EndIf
		Else
			SN1->(dbSetOrder(9)) //N1_FILIAL+N1_PROJETO+N1_PROJREV+N1_PROJETP+N1_PROJITE+N1_CBASE+N1_ITEM

			If AF430VerAtf(cCodPrj,cRevAnt)
				lRet := AF430BxAtf(cCodPrj,cRevAnt,"20")
			EndIf

			If lRet
				oModel:CommitData()
				AF430DTREV(cCodPrj,cRev,dDataBase)
				AF430FLAG(cCodPrj,cRevAnt,"7")
				AF430DTENC(cCodPrj,cRevAnt,dDataBase)
			Else
				oModel:= Nil
			EndIf
		EndIf
	Else
		oModel:CommitData()
	EndIf

	If lRet

		If oModel != Nil
			oModel:DeActivate()
		EndIf

		If lMostra
			__nOper 			:= OPER_IMPORTAR
			FNB->(DBSetOrder(1)) ////FNB_FILIAL+FNB_CODPRJ+FNB_REVIS
			FNB->(MSSeek(xFilial("FNB") + cCodPrj + cRev ))
			cTitulo 			:= STR0001 //'Projeto de Imobilizado'
			nOperation 			:= MODEL_OPERATION_VIEW
			cPrograma  			:= 'ATFA430'
			nOpt := FWExecView( cTitulo , cPrograma, nOperation , /*oDlg*/, {|| .T. } /*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/,/*cOperatId*/,/*cToolBar*/)
		EndIf
	EndIf
Else
	lRet := .F.
EndIf

If lRet
	If !Empty(cProc)
		ProcLogAtu( "MENSAGEM",  STR0108,,,.T. ) //" Projeto Importado com sucesso "
	EndIf
ElseIf oModel != Nil
	// Se os dados nใo foram validados obtemos a descri็ใo do erro para gerar LOG ou mensagem de aviso
	aErro   := oModel:GetErrorMessage()
	// A estrutura do vetor com erro ้:
	//  [1] Id do formulแrio de origem
	//  [2] Id do campo de origem
	//  [3] Id do formulแrio de erro
	//  [4] Id do campo de erro
	//  [5] Id do erro
	//  [6] mensagem do erro
	//  [7] mensagem da solu็ใo
	//  [8] Valor atribuido
	//  [9] Valor anterior

	If !Empty(cProc)
		cDetalhe += STR0109 + ' [' + AllToChar( aErro[1]  ) + ']'+ CRLF//"Id do formulแrio de origem:"
		cDetalhe += STR0110 + ' [' + AllToChar( aErro[2]  ) + ']'+ CRLF//"Id do campo de origem:     "
		cDetalhe += STR0111 + ' [' + AllToChar( aErro[3]  ) + ']'+ CRLF//"Id do formulแrio de erro:  "
		cDetalhe += STR0112 + ' [' + AllToChar( aErro[4]  ) + ']'+ CRLF//"Id do campo de erro:       "
		cDetalhe += STR0113 + ' [' + AllToChar( aErro[5]  ) + ']'+ CRLF//"Id do erro:                "
		cDetalhe += STR0114 + ' [' + AllToChar( aErro[6]  ) + ']'+ CRLF//"Mensagem do erro:          "
		cDetalhe += STR0115 + ' [' + AllToChar( aErro[7]  ) + ']'+ CRLF//"Mensagem da solu็ใo:       "
		cDetalhe += STR0116 + ' [' + AllToChar( aErro[8]  ) + ']'+ CRLF//"Valor atribuido:           "
		cDetalhe += STR0117 + ' [' + AllToChar( aErro[9]  ) + ']'+ CRLF//"Valor anterior:            "
		If nItErro > 0
			cDetalhe += STR0118 + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' + CRLF//"Erro no Item:              "
		EndIf
		ProcLogAtu( "ERRO" , STR0119 ,cDetalhe,,.F. )//" Erro na Importa็ใo, verifique "
	Else
		AutoGrLog( STR0109 + ' [' + AllToChar( aErro[1]  ) + ']' )//"Id do formulแrio de origem:"
		AutoGrLog( STR0110 + ' [' + AllToChar( aErro[2]  ) + ']' )//"Id do campo de origem:     "
		AutoGrLog( STR0111 + ' [' + AllToChar( aErro[3]  ) + ']' )//"Id do formulแrio de erro:  "
		AutoGrLog( STR0112 + ' [' + AllToChar( aErro[4]  ) + ']' )//"Id do campo de erro:       "
		AutoGrLog( STR0113 + ' [' + AllToChar( aErro[5]  ) + ']' )//"Id do erro:                "
		AutoGrLog( STR0114 + ' [' + AllToChar( aErro[6]  ) + ']' )//"Mensagem do erro:          "
		AutoGrLog( STR0115 + ' [' + AllToChar( aErro[7]  ) + ']' )//"Valor atribuido:           "
		AutoGrLog( STR0116 + ' [' + AllToChar( aErro[8]  ) + ']' )//"Valor atribuido:           "
		AutoGrLog( STR0117 + ' [' + AllToChar( aErro[9]  ) + ']' )//"Valor anterior:            "

		If nItErro > 0
			AutoGrLog( STR0118 + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' )//" Erro na Importa็ใo, verifique "
		EndIf

		MostraErro()
	EndIf
	If oModel != Nil
		// Desativamos o Model
		oModel:DeActivate()
	EndIf
EndIf


__nOper 			:= 0
RestArea(aAreaSN1)
RestArea(aAreaFNB)
RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430RDLN บAutor  ณAlvaro Camillo Neto บ Data ณ  25/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a Leitura da Linha e retorna um array com os dados บฑฑ
ฑฑบ          ณ jแ separados                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430RDLN()
Local aLinha := {}
Local cLinha := ""

//Tratamento para linhas com tamanho superior a 1020 Bytes
If ( Len(FT_FREADLN()) < 1023 )
	cLinha	:= FT_FREADLN()
Else
	cLinha	:= ""
	While .T.
		/*Verifica se encontrou o final da linha.*/
		If ( Len(FT_FREADLN()) < 1023 )
			cLinha += FT_FREADLN()
			Exit
		Else
			cLinha += FT_FREADLN()
			FT_FSKIP()
		EndIf
	EndDo
EndIf

aLinha := StrToKarr( cLinha, ";" )

Return aLinha


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430Dado บAutor  ณAlvaro Camillo Neto บ Data ณ  25/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Prepara as informa็๕es,Convertendo para os tipos corretos  บฑฑ
ฑฑบ          ณ  e verificando se o campo existe no dicionario             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430Dado(cTabela,aDados)
Local aRet 		:= {}
Local aStruct  := (cTabela)->(dbStruct())
Local nX			:= 0
Local nPos		:= 0


For nX := 1 to Len(aDados)
	If ( nPos := aScan( aStruct, { |x| AllTrim( x[1] ) ==  AllTrim( aDados[nX][1] ) } ) ) > 0
		Do Case
			Case aStruct[nPos][2] == "C"
				AADD(aRet,{aStruct[nPos][1] , aDados[nX][2] })

			Case aStruct[nPos][2] == "L"
				AADD(aRet,{aStruct[nPos][1] , aDados[nX][2]=="T" })

			Case aStruct[nPos][2] == "D"
				AADD(aRet,{aStruct[nPos][1] , STOD( aDados[nX][2] ) })

			Case aStruct[nPos][2] == "N"
				AADD(aRet,{aStruct[nPos][1] , Val( aDados[nX][2] ) })
		EndCase
	EndIf
Next nX


Return aClone(aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430SetVlบAutor  ณAlvaro Camillo Neto บ Data ณ  28/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o campo para importa็ใo do projeto                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA430                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430SetVl(oModel,cCampo,cConteudo)
Local lRet 		:= .T.
Local aArea 	:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())

cCampo := Alltrim(cCampo)

SX3->(dbSetOrder(2)) // X3_CAMPO

If cCampo == "FND_ITEM"  .Or. cCampo == "FNE_LINHA"  .Or. cCampo == "FNC_ETAPA" // Campos Auto Incrementados pela View
	lRet := oModel:LoadValue( cCampo , cConteudo )
Else
	If SX3->(MsSeek(cCampo))
		If X3USO(SX3->X3_USADO) .And. SX3->X3_VISUAL != "V" .And. SX3->X3_CONTEXT != "V" .And. !( "_MSBLQL" $ SX3->X3_CAMPO )
			If !Empty(cConteudo)
				If cCampo == "FNB_CODPRJ"
					lRet := oModel:LoadValue( cCampo , cConteudo )
				Else
					If cCampo != "FNE_GRPBEM"
						lRet := oModel:SetValue( cCampo , cConteudo )
					Else
						If Empty(oModel:GetValue(cCampo))
							lRet := oModel:SetValue( cCampo , cConteudo )
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSX3)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjRetParamบAutor  ณAlvaro Camillo Neto บ Data ณ  17/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAjusta as repostas do aParambox                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 		                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjRetParam(aRet,aParamBox)

Local nX	:= 1

IF ValType(aRet) == "A" .AND. Len(aRet) == Len(aParamBox)
	For nX := 1 to Len(aParamBox)
		If aParamBox[nX][1] == 1
			aRet[nX] := aRet[nX]
		ElseIf aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "C"
			aRet[nX] := aScan(aParamBox[nX][4],{|x| Alltrim(x) == aRet[nX]})
		ElseIf aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "N"
			aRet[nX] := aRet[nX]
		Endif
	Next nX
ENDIF

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430VerAtfบAutor  ณAlvaro Camillo Neto บ Data ณ  05/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se existe algum imobilizado ativo (nao baixado)   บฑฑ
ฑฑบ          ณ com o projeto/revisใo                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430VerAtf(cCodPrj,cRev)
Local lRet 			:= .F.
Local aArea			:= GetArea()
Local aAreaSN1		:= SN1->(GetArea())

SN1->(dbSetOrder(9)) //N1_FILIAL+N1_PROJETO+N1_PROJREV+N1_PROJETP+N1_PROJITE+N1_CBASE+N1_ITEM
If SN1->(MsSeek(xFilial("SN1") + cCodPrj + cRev))
	While SN1->(!EOF()) .And. SN1->(N1_FILIAL+N1_PROJETO+N1_PROJREV) == xFilial("SN1") + cCodPrj + cRev
		If Empty(SN1->N1_BAIXA)
			lRet := .T.
			Exit
		EndIf
		SN1->(dbSkip())
	EndDo
EndIf

RestArea(aAreaSN1)
RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430GetRevบAutor  ณAlvaro Camillo Neto บ Data ณ  22/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a ultima revisใo com o status passado por parametro บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430GetRev(cCodPrj,cFlag)
Local cRet     := ""
Local aArea    := GetArea()
Local aAreaFNB := FNB->(GetArea())

Default cFlag := ""

FNB->(DBSetOrder(1)) ////FNB_FILIAL+FNB_CODPRJ+FNB_REVIS

If FNB->(MsSeek(xFilial("FNB") + cCodPrj ))
	While FNB->(!EOF()) .And. FNB->(FNB_FILIAL+FNB_CODPRJ) == xFilial("FNB") + cCodPrj
		If (Alltrim(FNB->FNB_STATUS) == Alltrim(cFlag)) .Or. Empty(cFlag)
			cRet := FNB->FNB_REVIS
		EndIf
		FNB->(dbSkip())
	EndDo
EndIf

RestArea(aAreaFNB)
RestArea(aArea)
Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA430   บAutor  ณMicrosiga           บ Data ณ  02/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430IMAPR(cCodPrj,cRev)
Local aArea    := GetArea()
Local aAreaFNB := FNB->(GetArea())
Local lRet     := .T.
Local cOrigem  := ""

FNB->(DBSetOrder(1)) // FNB_FILIAL+FNB_CODPRJ+FNB_REVIS

If FNB->(MsSeek(xFilial("FNB") + cCodPrj + cRev ))
	cOrigem := FunName()
	lRet := AF004GrvMov("ATFA430","06",dDataBase,,,,cOrigem,"FNB",FNB->(Recno()))
EndIf

RestArea(aAreaFNB)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430DTENCบAutor  ณAlvaro Camillo Neto บ Data ณ  11/14/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava a data de revisใo do projeto                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430DTREV(cCodPrj,cRev,dData)

Local aArea		:= GetArea()
Local aAreaFNB	:= FNB->(GetArea())
Local aAreaFND	:= FND->(GetArea())
Local aAreaFNE	:= FNE->(GetArea())

Default dData  := dDataBase

FNB->(dbSetOrder(1)) //FNB_FILIAL+FNB_CODPRJ+FNB_REVIS
FND->(dbSetOrder(1)) //FND_FILIAL+FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM
FNE->(dbSetOrder(1)) //FNE_FILIAL+FNE_CODPRJ+FNE_REVIS+FNE_ETAPA+FNE_ITEM+FNE_LINHA

If FNB->(MsSeek( xFilial("FNB") + cCodPrj + cRev ))
	RecLock("FNB",.F.)
	FNB->FNB_DTREV := dData
	MsUnLock()
EndIf

If FNE->(MsSeek( xFilial("FNE") + cCodPrj + cRev ))
	While FNE->(!EOF()) .And. FNE->(FNE_FILIAL+FNE_CODPRJ+FNE_REVIS) == xFilial("FNE") + cCodPrj + cRev
		If FNE->FNE_DINDEP < dData
			RecLock("FNE",.F.)
			FNE->FNE_DINDEP := dData + 1
			MsUnLock()
		EndIf
		FNE->(dbSkip())
	EndDo
EndIf


RestArea(aAreaFNE)
RestArea(aAreaFND)
RestArea(aAreaFNB)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430CPCTBบAutor  ณAlvaro Camillo Neto บ Data ณ  21/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a c๓pia das configura็๕es contแbeis para           บฑฑ
ฑฑบ          ณ todos itens da etapa                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430CPCTB()
Local oModel       := FWModelActive()
Local oModelFND    := oModel:GetModel("FNDDETAIL")
Local oModelFNE    := oModel:GetModel("FNEDETAIL")
Local aSaveLines   := FWSaveRows()
Local nOperation   := oModel:GetOperation()
Local nX           := 0
Local nY           := 0
Local nZ           := 0
Local aConfCtb     := {}
Local aConfAtu     := {}
Local aAux         := {}
Local cContCpy     := ""
Local cTipo        := ""
Local cSaldo       := ""
Local dDataExec    := cTod("")
Local dDataProv    := cTod("")
Local oView        := FWViewActive()
Local nLin         := 1

If (nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_INSERT)
	If MsgNoYes(STR0137,STR0138)//"Deseja copiar as configura็๕es contแbeis para todos os itens da etapa?"##"Atencao"

		// Ativa o flag para limpar a FNE
		// __lCpyCtb := .T.

		//Realiza copia das informacoes contabeis da linha atual
		aConfCtb := AF430GetCtb(oModelFNE)

        If Len( aConfCtb ) > 0

		    nLinFND := oModelFND:GetLine()

			For nX := 1 To oModelFND:Length()
				If nX == nLinFND
					Loop
				EndIf

				oModelFND:GoLine( nX )
				If !oModelFND:IsDeleted() .And. Empty(oModelFND:GetValue("FND_DTENCR"))
					oModelFNE := oModel:GetModel("FNEDETAIL")

	             	//Realiza c๓pia das informa็๕es contแbeis da linha atual
					aConfAtu := AF430GetCtb(oModelFNE)

			        //Exclui todas as linha de configura็ใo contแbil do item da etapa
			        AF430ClrMd(oModelFNE)

	                // Usada para impedir a acao da validacao na copia - caso do valor de maxima depreciacao
	       	     	__lCpyCtb := .T.
	                // Evita problemas no AddLine do Model

					//Realiza as C๓pias da configura็ใo contแbil
					For nY := 1 to Len(aConfCtb)

						nLin := oModelFNE:AddLine()

	                    /*
	                    If oModel:HasErrorMessage()
	                       oView:ShowLastError()   // Usado apenas para verificar problemas nao detectados no AddLine()
	                    EndIf  */

						cTipo	:= aConfCtb[nY][1]
						cSaldo	:= aConfCtb[nY][2]
						aAux	:= aConfCtb[nY][3]

						For nZ := 1 to Len(aAux)
							If Alltrim(aAux[nZ][1]) == 'FNE_DINDEP'
								dDataExec := oModelFND:GetValue("FND_PRVEXC")
								dDataProv := oModelFND:GetValue("FND_DTPROV")
								cContCpy  := AF430DINDP(cTipo,dDataProv,dDataExec)
							ElseIf Alltrim(aAux[nZ][1]) == 'FNE_LINHA'
								cContCpy := StrZero(nLin,TamSx3('FNE_LINHA')[1])
							ElseIf aAux[nZ][3] // campo ้ copiado
								cContCpy := aAux[nZ][2]
							ElseIf Alltrim(aAux[nZ][1]) == 'FNE_VORIG'
								cContCpy := oModelFND:GetValue("FND_VLRPLN")
							Else //campo ้ mantido
								cContCpy := A430CPYORI(cTipo,cSaldo,aAux[nZ][1],aConfAtu)
							EndIf

							If !Empty(cContCpy)
								oModelFNE:LoadValue(aAux[nZ][1],cContCpy)
							EndIf
						Next nZ
						nLin++
					Next nY

	                // Reset da Flag
	       	     	__lCpyCtb := .F.

				EndIf
			Next nX

        EndIf
	EndIf
Else
	Help(" ",1,"AF430AVP2",,STR0072,1,0)//"Op็ใo disponํvel apenas para Inclusใo e Altera็ใo"
EndIf

FWRestRows(aSaveLines)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA430CPYORIบAutor  ณMicrosiga           บ Data ณ  22/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o valor original do campo                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A430CPYORI(cTipo,cSaldo,cCampo,aConfAtu)
Local xConteudo := ""
Local nPos      := 0
Local nPosCPO   := 0
Local aAux      := {}

nPos := aScan(aConfAtu, {|aConf| Alltrim(Upper(aConf[1] + aConf[2])) == Alltrim(Upper(cTipo + cSaldo) )  })

If nPos > 0
	aAux := aConfAtu[nPos][3]
	nPosCPO := aScan( aAux, {|aCampo| Alltrim(Upper(aCampo[1])) == Alltrim(Upper(cCampo) )  })
	If nPosCPO > 0
		xConteudo := aAux[nPosCPO][2]
	EndIf
EndIf

Return xConteudo
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430GetCtbบAutor ณAlvaro Camillo Neto บ Data ณ  21/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina que retorna os dados e estrutura do item contแbil    บฑฑ
ฑฑบ          ณcorrente                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430GetCtb(oModel)
Local aCtbCfg := {}
Local aStrFNE := oModel:GetStruct():aFields
Local nX      := 0
Local nY      := 0
Local aAux    := {}
Local cAux    := ""
Local cCampoExc := 'FNE_FILIAL\FNE_CODPRJ\FNE_REVIS\FNE_ETAPA\FNE_ITEM\FNE_ITVIRT\FNE_VRDACM\FNE_VORIG\FNE_AVPPLN\FNE_AVPRLZ\FNE_VLSALV\FNE_VLMXDP\FNE_USRAVP'
Local lCpy	  := .T.
Local lCheck  := .T.
Local cTipo   := ""
Local cSaldo  := ""


For nX := 1 to oModel:Length()
	oModel:GoLine( nX )
	If !oModel:IsDeleted()

        //--- Intervencao destinada a Validar uma linha antes da Copia
        //--- Evitar a situacao em que uma linha 'errada' eh copiada
        lCheck := FNELINPOS( oModel )

        If lCheck

		   aAux := {}
		   For nY := 1 to Len(aStrFNE)
			   lCpy := !( Alltrim(aStrFNE[nY][3]) $ cCampoExc )
			   cAux := oModel:GetValue(aStrFNE[nY][3])
			   aAdd(aAux,{aStrFNE[nY][3],cAux,lCpy})
		   Next nY


		   cTipo := oModel:GetValue("FNE_TPATF")
		   cSaldo := oModel:GetValue("FNE_TPSALD")

		   aAdd(aCtbCfg, {cTipo,cSaldo, aClone(aAux) } )

        Else
           //--- Abandona o Loop e deixa o array aCtbCfg vazio
           aCtbCfg := {}
           Exit
           //
        EndIf

	EndIf
Next nX

Return aCtbCfg


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430ClrMdบAutor  ณAlvaro Camillo Neto บ Data ณ  03/21/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclui todas as linha do modelo                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430ClrMd(oModelX)
Local nX          := 0

For nX := 1 to oModelX:Length()
	oModelX:GoLine( nX )
	oModelX:DeleteLine()
Next nX

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430VLTXบAutor  ณMicrosiga           บ Data ณ  05/31/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a valida็ใo da revisใo da taxa                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430VLTX()
Local lRet         := .T.
Local oModel       := FWModelActive()
Local oModelFNB    := oModel:GetModel("FNBMASTER")
Local oModelFNC    := oModel:GetModel("FNCDETAIL")
Local oModelFND    := oModel:GetModel("FNDDETAIL")
Local aSaveLines   := FWSaveRows()
Local nX           := 0
Local nZ           := 0
Local cCodPrj      := ""
Local cRevis       := ""
Local cEtapa       := ""
Local cItem        := ""
Local dData        := CTOD("")

lRet := MsgNoYes(STR0140) //"Deseja revisar o AVP das fichas do imobilizado ? "

If lRet
	For nX := 1 to oModelFNC:Length()
		oModelFNC:GoLine(nX)

		For nZ := 1 to oModelFND:Length()
			oModelFND:GoLine(nZ)
			cCodPrj := oModelFNB:GetValue("FNB_CODPRJ")
			cRevis  := oModelFNB:GetValue("FNB_REVIS")
			cEtapa  := oModelFNC:GetValue("FNC_ETAPA")
			cItem   := oModelFND:GetValue("FND_ITEM")
			dData   := oModelFND:GetValue("FND_DTPROV")

			lRet := VerApurAVP(cCodPrj,cRevis,cEtapa,cItem,dData)

			If !lRet
				Exit
			EndIf

		Next nZ

		If !lRet
			Exit
		EndIf
	Next nX
EndIf


FWRestRows(aSaveLines)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerApurAVPบAutor  ณMicrosiga           บ Data ณ  05/31/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se foi realizada alguma apura็ใo posterior        บฑฑ
ฑฑบ          ณ a data de revisใo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VerApurAVP(cCodPrj,cRevis,cEtapa,cItem,dData)
Local lRet      := .T.
Local aArea     := GetArea()
Local cQuery    := " "
Local cAliasTRB := GetNextAlias()

If Select(cAliasTRB) > 0
	(cAliasTRB)->(dbCloseArea())
EndIf

cQuery += " SELECT " + CRLF
cQuery += "     COUNT(*) FNFCONT " + CRLF
cQuery += " FROM "+RetSQLName("FNF") +" FNF " + CRLF
cQuery += " INNER JOIN "+RetSQLName("SN1") +" SN1 ON " + CRLF
cQuery += "     FNF_FILIAL = N1_FILIAL AND " + CRLF
cQuery += "     FNF_CBASE  = N1_CBASE  AND " + CRLF
cQuery += "     FNF_ITEM   = N1_ITEM " + CRLF
cQuery += " WHERE  " + CRLF
cQuery += "     N1_FILIAL  = '"+xFilial("SN1")+"'  AND " + CRLF
cQuery += "     N1_PROJETO = '"+cCodPrj+"'         AND " + CRLF
cQuery += "     N1_PROJREV = '"+cRevis+"'          AND " + CRLF
cQuery += "     N1_PROJETP = '"+cEtapa+"'          AND " + CRLF
cQuery += "     N1_PROJITE = '"+cItem+"'           AND " + CRLF
cQuery += "     FNF_DTAVP  > '"+DTOS(dData) +"'   AND " + CRLF
cQuery += "     SN1.D_E_L_E_T_ = ''                AND " + CRLF
cQuery += "     FNF.D_E_L_E_T_ = '' "                    + CRLF

//Executa a query
cQuery := ChangeQuery(cQuery )

dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasTRB , .T. , .F.)
(cAliasTRB)->(dbGoTop())

If (cAliasTRB)->(!EOF())
	If !Empty( (cAliasTRB)->FNFCONT )
		lRet := .F.
	EndIf
EndIf

(cAliasTRB)->(dbCloseArea())

If !lRet
	Help(" ",1,"AF430AVPB",,STR0148 + dToc(dData) ,1,0) //"Jแ existe apura็ใo para esse item na data "
EndIf

RestArea(aArea)
Return lRet

//BPI
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA430REA บAutor  ณMauricio Pequim Jr  บ Data ณ  26/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza amarra็ใo Item Etapa x Bens Execu็ใo               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFA430REA(cAlias,nReg,nOpc)
Local aArea         := GetArea()
Local lConfirma     := .F.
Local lCancela      := .F.
Local cTitulo       := ""
Local cPrograma     := ""
Local nOperation    := 0
Local cCodPrj       := FNB->FNB_CODPRJ
Local cRev          := FNB->FNB_REVIS
Local lRet          := .T.
Local cStatus		:= ""

//Verifico se a Baixa de Provisao de Imobilizado esta implantada
Local lBpiAtf := AFVldBpi()

If !lBpiAtf
	Help(" ",1,"AF430NOBPI",,STR0008,1,0)//"Dicionแrio de dados e RPO desatualizados, por favor atualizar lib do ambiente e executar atualizador do m๓dulo ATF e FIN"
	lRet := .F.
Endif

If lRet .and. !(FNB->FNB_STATUS $ "1/A")

	cStatus := AF430Stat(FNB->FNB_STATUS)

	Help("  ",1,"AFR430RLZ",,STR0149 + CRLF + cStatus ,1,0)   //"Apenas projetos ativos poderใo receber informa็๕es de realiza็ใo."###"Status Atual: "
	lRet := .F.
Endif

If lRet
	__nOper      := OPER_REALIZAR
	cTitulo      := STR0189 //"Realiza็ใo de Projeto"
	cPrograma    := 'ATFA430'
	nOperation   := MODEL_OPERATION_UPDATE
	bOk          := {|| .T. } //"Deseja Realizar o bloqueio/desbloqueio do projeto ou etapas ? "
	nRet         := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,bOk , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )
	__nOper      := 0
EndIf

RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFNJLINPRE บAutor  ณMauricio Pequim Jr. บ Data ณ  27/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pr้ valida็ใo de linha da grid FNJDetail                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FNJLINPRE(oModelFNJ, cAction)
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local nVlrFNJ	:= oModel:GetValue("FNJDETAIL","FNJ_VLREXE")
Local dDtRlz	:= oModel:GetValue("FNJDETAIL","FNJ_DTCONT")
Local nVlrRlz	:= oModel:GetValue("FNEDETAIL","FNE_VLRRLZ")
Local nVlrAtf	:= oModel:GetValue("FNEDETAIL","FNE_VORIG")

Local aSaveLines:= FWSaveRows()

//Registro com realizacao efetivada
If nVlrFNJ > 0 .and. !Empty(dDtRlz)
	Help("  ",1,"AFR430EX1",,STR0159 ,1,0) //"Este registro ja teve sua realiza็ใo efetivada e nใo pode sofrer manuten็๕es"
	lRet := .F.
Endif

//deleta a linha (FNJ)
If lRet .and. nVlrFnj > 0 .And. Alltrim(Upper(cAction)) == 'DELETE'
	nVlrRlz -= nVlrFNJ
	oModel:LoadValue("FNEDETAIL", "FNE_VLRRLZ" , nVlrRlz  )
EndIf

//Reativa linha deletada (FNJ)
If lRet .and. nVlrFnj > 0 .And. Alltrim(Upper(cAction)) == 'UNDELETE'
	nVlrRlz += nVlrFNJ
	If nVlrRlz > nVlrAtf
		Help("  ",1,"AFR430EX2",,STR0151 ,1,0) //"O valor realizado nใo pode ser maior que o valor original do imobilizado"
		lRet := .F.
	Else
		oModel:LoadValue("FNEDETAIL", "FNE_VLRRLZ" , nVlrRlz  )
	Endif
EndIf



FWRestRows(aSaveLines)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFNELINPOS บAutor  ณMicrosiga           บ Data ณ  27/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ P๓s valida็ใo de linha da entidade FNJDETAIL - Bens de     บฑฑ
ฑฑบ          ณ execucao                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FNJLINPOS(oModelFNJ)

Local lRet        := .T.
Local oModel      := FWModelActive()
Local lLinAtiva   := !oModelFNJ:IsDeleted()
Local aSaveLines  := FWSaveRows()
Local nX          := 0
Local nValRlz     := 0
Local nLinFNJ     := oModelFNJ:GetLine()
Local cBase       := oModelFNJ:GetValue("FNJ_CBAEXE")
Local cItem       := oModelFNJ:GetValue("FNJ_ITEXE")
Local cTipo        := oModelFNJ:GetValue("FNJ_TAFEXE")
Local cTpSld      := oModelFNJ:GetValue("FNJ_SLDEXE")
Local nVlorig     := oModel:GetValue("FNEDETAIL","FNE_VORIG")
Local l430Rlz     := ISINCALLSTACK('AFA430REA')
Local aArea       := GetArea()
Local dDataIni    := oModel:GetValue("FNDDETAIL","FND_PERINI")
Local dDataFim    := oModel:GetValue("FNDDETAIL","FND_PERFIM")
Local aAreaSN1    := SN1->(GetArea())

SN1->(dbSetOrder(1)) //N1_FILIAL + N1_CBASE + N1_ITEM

If lRet .And. lLinAtiva
	If SN1->(dbSeek(xFilial("SN1") + cBase + cItem ))
		If !(SN1->N1_STATUS $ '0/1')
			Help("  ",1,"AF430POS04",,STR0204 ,1,0) //"Este ativo estแ Bloqueado !"
			lRet := .F.
		EndIf
	EndIf
EndIf

//Verifica campos nao preenchidos na FNJ
If lRet .And. lLinAtiva .and. !Empty(cBase+cItem+cTipo+cTpSld) .and. (Empty(cBase) .or. Empty(cItem) .or. Empty(cTipo) .or. Empty(cTpSld))
	Help("  ",1,"AF430POS01",,STR0152 ,1,0) //"Verifique o preenchimento dos dados do bem a ser relacionado ao projeto para realizacao"
	lRet := .F.
EndIf

If lRet .And. lLinAtiva
	If SN1->(dbSeek(xFilial("SN1") + cBase + cItem ))
		If SN1->N1_AQUISIC < dDataIni .Or. SN1->N1_AQUISIC > dDataFim
			Help("  ",1,"AF430POS03",,STR0193 ,1,0) //"A data de aquisi็ใo do ativo estแ fora do intervalo do Perํodo do Item da Etapa."
			lRet := .F.
		EndIf
	EndIf
EndIf

//Verifica valor realizado
If lRet .And. lLinAtiva
	For nX := 1 To oModelFNJ:Length()
		oModelFNJ:GoLine( nX )
		If !oModelFNJ:IsDeleted()
			nValRlz += oModelFNJ:GetValue("FNJ_VLREXE")
		EndIf
	Next nX

	If nValRlz > 0 .and. nValRlz > nVlOrig
		Help("  ",1,"AF430POS02",,STR0151 ,1,0) //"O valor realizado nใo pode ser maior que o valor original do imobilizado"
		lRet := .F.
	EndIf
	oModelFNJ:GoLine( nLinFNJ )
EndIf

//Caso a linha nao tenha dados do bem de execucao,
//deleto a mesma para nao gravar registro em branco na FNJ
If lRet .And. lLinAtiva .and. Empty(cBase+cItem+cTipo+cTpSld) .and. l430Rlz
	lRet := oModelFNJ:DeleteLine(.T.)
Endif



FWRestRows(aSaveLines)
RestArea(aAreaSN1)
RestArea(aArea)
Return lRet



/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430GSldE ณ Autor ณMauricio Pequim Jr.  ณ Data ณ 30/09/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Gatilho para atualiza็ใo dos campos da grid do FNJ		  ณฑฑ
ฑฑณ          ณ com base nas informa็๕es do SN3  						  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430GSldE()
Local lRet			:= .T.
Local oModel		:= FWModelActive()
Local oView		:= FWViewActive()
Local oModelFNJ	:= oModel:GetModel("FNJDETAIL")
Local oModelFNE	:= oModel:GetModel("FNEDETAIL")
Local nX			:= 0
Local cBase		:= oModelFNJ:GetValue("FNJ_CBAEXE")
Local cItem		:= oModelFNJ:GetValue("FNJ_ITEXE")
Local cTipo		:= oModelFNJ:GetValue("FNJ_TAFEXE")
Local cTpSld		:= oModelFNJ:GetValue("FNJ_SLDEXE")
Local nVlrFNJ		:= oModelFNJ:GetValue("FNJ_VLREXE")
Local nVlrRlz		:= oModel:GetValue('FNEDETAIL','FNE_VLRRLZ')
Local nVlrAtf  	 := oModel:GetValue("FNEDETAIL","FNE_VORIG")
Local aCampos		:= {}
Local aArea 		:= GetArea()
Local aSaveLines  := FWSaveRows()

aAdd(aCampos,{"N3_VORIG1","FNJ_VLREXE"})

SN3->(dbSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV
If SN3->(MsSeek( xFilial("SN3") + cBase + cItem + cTipo + "0" + cTpSld ))
	For nX := 1 to Len(aCampos)
		If SN3->(FieldPos(aCampos[nX][1])) > 0 .And. FNJ->(FieldPos(aCampos[nX][2])) > 0
			If !Empty(SN3->&(aCampos[nX][1]))
				lRet := oModelFNJ:LoadValue( aCampos[nX][2] , SN3->&(aCampos[nX][1]) )
				If !lRet
					Exit
				EndIf
			EndIf
		EndIf
	Next nX

	If lRet
		nVlrRlz += oModelFNJ:GetValue("FNJ_VLREXE")
		nVlrRlz -= nVlrFNJ		//valor anterior da FNJ_VLREXE
		oModelFNE:LoadValue( "FNE_VLRRLZ" , nVlrRlz  )
	Endif

EndIf

FWRestRows(aSaveLines)

RestArea(aArea)
Return .T.


/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430VLBEX ณ Autor ณMauricio Pequim Jr.  ณ Data ณ 26/07/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณFun็ใo para validar campo em fun็ใo do m้todo de deprecia็ใoณฑฑ
ฑฑณ          ณ definido.											  	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430VLBEX()
Local oModel   	:= FWModelActive()
Local oModelFNJ	:= oModel:GetModel("FNJDETAIL")
Local lRet 		:= .T.
Local cBase		:= oModelFNJ:GetValue("FNJ_CBAEXE")
Local cItem		:= oModelFNJ:GetValue("FNJ_ITEXE")
Local cTipo		:= oModelFNJ:GetValue("FNJ_TAFEXE")
Local cTpSld	:= oModelFNJ:GetValue("FNJ_SLDEXE")
Local cTipSld	:= oModel:GetValue("FNEDETAIL","FNE_TPSALD")
Local cTipAtf	:= oModel:GetValue("FNEDETAIL","FNE_TPATF")

If !Empty(cBase) .and. !Empty(cItem) .and. !Empty(cTipo) .and. !Empty(cTpSld) .and. !Empty(cTipSld) .and. !Empty(cTipAtf)

	SN3->(dbSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV
	If !(SN3->(MsSeek( xFilial("SN3") + cBase + cItem + cTipo + "0" + cTpSld )))
		Help( " ", 1, "AF430VLBEX1",, STR0153, 1, 0 ) //"Imobilizado nใo localizado"
		lRet := .F.
	ElseIF cTpSld != cTipSld .or. cTipo != cTipAtf
		Help( " ", 1, "AF430VLBEX2",, STR0154, 1, 0 )  //"Imobilizado deve possuir mesmo Tipo de Ativo e Tipo de Saldo do Item de Etapa"
		lRet := .F.
	Endif
Endif

Return lRet


/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ FNJSxbFil  ณ Autor ณMauricio Pequim Jr.  ณ Data ณ 26/07/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณFiltro de Consulta Padrao SN302							  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FNJSxbFilt()

Local oModel   	:= FWModelActive()
Local cTipo		:= oModel:GetValue("FNEDETAIL","FNE_TPATF")
Local cTpSld	:= oModel:GetValue("FNEDETAIL","FNE_TPSALD")
Local cProjeto	:= oModel:GetValue("FNEDETAIL","FNE_CODPRJ")
Local cRevisao	:= oModel:GetValue("FNEDETAIL","FNE_REVIS")
Local cAliasQry	:= "SN3430"
Local cCadastro  := STR0160 //"Imobilizados"
Local aCampos    := {}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis da MsNewGetDados()      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aHeadSXB 		:= {}
Local aColsSXB      := {}
Local nOpcGet		:= 0									 			   	// GD_INSERT+GD_UPDATE+GD_DELETE					// Op็ใo da MsNewGetDados
Local cLinhaOk     	:= "AllwaysTrue"  										// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk      	:= "AllwaysTrue"									   	// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""			               			  		  		// Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000              								   	// Campos estaticos na GetDados.
Local aAlter      	:= {}                   		                   		// Campos a serem alterados pelo usuario
Local cFieldOk     	:= "AllwaysTrue"					 	  		        // Funcao executada na validacao do campo
Local cSuperDel     := "AllwaysTrue"          			  			 		// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk        := "AllwaysTrue"    					 				// Funcao executada para validar a exclusao de uma linha do aCols
Local lRet 			:= .T.
Local nOpcA			:= 0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis para a MsAdvSize e MsObjSizeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lEnchBar   := .F. // Se a janela de diแlogo possuirแ enchoicebar (.T.)
Local lPadrao    := .F. // Se a janela deve respeitar as medidas padr๕es do Protheus (.T.) ou usar o mแximo disponํvel (.F.)
Local nMinY	     := 400 // Altura mํnima da janela
Local aSize	  	 := MsAdvSize(lEnchBar, lPadrao, nMinY)
Local aInfo	 	 := {aSize[1],aSize[2],aSize[3],aSize[4],3,3} // Coluna Inicial, Linha Inicial
Local aObjects	 := {}
Local aPosObj	 := {}
Local aRecNo	 := {}
Local oDlg		 := Nil
Local oPanelGet	 := Nil
Local nX         := 0
Local bOK		 := {|| (AF430VldF3(aColsSXB,oGetSN3:nAt),oDlg:End())}
Local bCancel    := {|| oDlg:End() }
Local bVisual    := {|| AF430VBem(aColsSXB,oGetSN3:nAt)}
Local aSvKeys	 := GetKeys()

Private oGetSN3 	:= Nil

aDadosFNJ	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefini็ใo das posi็๕es dos objetos na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para a Getdados
aPosObj := MsObjSize(aInfo,aObjects) // Mantem proporcao - Calcula Horizontal

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem do acols da get de modificadoresณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aCampos,"N3_CBASE")
aAdd(aCampos,"N3_ITEM")
aAdd(aCampos,"N3_TIPO")
aAdd(aCampos,"N3_TPSALDO")
aAdd(aCampos,"N3_VORIG1")
aAdd(aCampos,"N3_HISTOR")

SN3->(DbSetOrder(11))

cQuery := "SELECT N3_CBASE, N3_ITEM, N3_TIPO, N3_TPSALDO, N3_HISTOR,N3_VORIG1, N1_PROJETO, N1_PROJREV, N1_PROJETP "
cQuery += "FROM " + RetSQLTab('SN3')
cQuery += "JOIN " + RetSQLTab('SN1')
cQuery += "  ON  SN3.N3_FILIAL  = SN1.N1_FILIAL AND "
cQuery += "      SN3.N3_CBASE   = SN1.N1_CBASE AND "
cQuery += "      SN3.N3_ITEM	= SN1.N1_ITEM "
cQuery += " WHERE "
cQuery +=   " N1_FILIAL  = '" +xFilial("SN1")+ "' AND "
cQuery +=   " N3_FILIAL  = '" +xFilial("SN3")+ "' AND "
cQuery += 	" N1_PROJETO = '" +cProjeto	    + "' AND "
cQuery += 	" N1_PROJREV = ' ' AND "
cQuery += 	" N1_PROJETP = ' ' AND "
cQuery += 	" N1_STATUS IN ('0','1') AND "
cQuery += 	" N3_TIPO    = '" + cTipo	    + "' AND "
cQuery += 	" N3_TPSALDO = '" + cTpSld	    + "' AND "
cQuery += 	" N3_BAIXA	= '0' AND "
cQuery +=   " SN1.D_E_L_E_T_ = ' ' AND "
cQuery +=   " SN3.D_E_L_E_T_ = ' ' AND "
cQuery += 	" NOT EXISTS ("
cQuery +=         " SELECT FNJ_CBAEXE "
cQuery +=         " FROM "+RetSqlName("FNJ")+" "
cQuery +=         " WHERE FNJ_FILIAL = '"+xFilial("FNJ")+"' AND "
cQuery +=				" FNJ_CBAEXE = N3_CBASE AND "
cQuery +=				" FNJ_ITEXE  = N3_ITEM AND "
cQuery +=				" FNJ_TAFEXE = N3_TIPO AND "
cQuery +=				" FNJ_SLDEXE = N3_TPSALDO AND "
cQuery +=				" D_E_L_E_T_ = ' ' )"

cQuery += " ORDER BY N3_CBASE, N3_ITEM, N3_TIPO, N3_TPSALDO"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

dbSelectArea(cAliasQry)
DbGotop()

aHeadSXB := AF430CvHeader(aCampos)
aColsSXB := AF430CvAcols (aHeadSXB, cAliasQry )

(cAliasQry)->(dbCloseArea())

oDlg := MSDIALOG():New(0,0,500,730,cCadastro,,,,,,,,,.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEstrutura de Panelsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPanelGet 			:= TPanel():New(0,0,'',oDlg,, .T., .T.,, ,100,100,.T.,.T. )
oPanelGet:Align 	:= CONTROL_ALIGN_ALLCLIENT

oGetSN3	:= 	MsNewGetDados():New(0,0,100,100,nOpcGet,;
			cLinhaOk ,cTudoOk,cIniCpos,/*aAlter*/,nFreeze,999,cFieldOk,cSuperDel,cDelOk,oPanelGet,aHeadSXB,aColsSXB)
oGetSN3:obrowse:align:= CONTROL_ALIGN_ALLCLIENT

oButtonBar := FWButtonBar():new()
oButtonBar:Init(oDlg,015,015,CONTROL_ALIGN_BOTTOM,.T.,.F.)

oButtonBar:addBtnText( STR0161	, STR0161+" <Alt-X>" , bCancel,,,CONTROL_ALIGN_RIGHT, .T.) //"Fechar"###"Fechar"
SetKEY(K_ALT_X,{||Eval(bCancel)})

oButtonBar:addBtnText( STR0162	, STR0162+" <Alt-O>" , bOk,,,CONTROL_ALIGN_RIGHT) //"Confirmar"###"Confirmar"
SetKEY(K_ALT_O,{||Eval(bOk)})

oButtonBar:addBtnText( STR0011	, STR0011+" <Alt-V>" , bVisual,,,CONTROL_ALIGN_RIGHT) //"Visualizar"###"Visualizar"
SetKEY(K_ALT_V,{||Eval(bVisual)})

oDlg:lCentered	:= .T.
oDlg:Activate()

SetKEY(K_ALT_O, NIL)
SetKEY(K_ALT_X, NIL)
SetKEY(K_ALT_V, NIL)

RestKeys( aSvKeys , .T. )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณAF430CvHeaderบAutor ณMauricio Pequim Jr. บ Data ณ 10/03/10  บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณCria o Aheader da getdados                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430CvHeader(aCampos)
Local aArea	  		:= GetArea()
Local aAreaSX3	  	:= SX3->(GetArea())
Local aHeader 		:= {}
Local nX			:= 0

SX3->(dbSetOrder(2)) // X3_CAMPO

For nX := 1 to Len(aCampos)
	SX3->(msSeek(aCampos[nX]))

	Aadd( aHeader, { Rtrim( SX3->(X3Titulo())), ;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID, 	;
						SX3->X3_USADO,	;
						SX3->X3_TIPO, 	;
						".T.",;
						SX3->X3_CONTEXT, ;
						SX3->X3_CBOX } )
Next nX

RestArea(aAreaSX3)
RestArea(aArea)
Return(aHeader)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณAF430CvAcolsบAutor ณMauricio Pequim Jr. บ Data ณ  10/03/11  บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o aCols da getdados de conversใo                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430CvAcols( aHeadSXB ,cAliasQry)
Local nX		:= 0
Local nCols		:= 0
Local aArea		:= GetArea()
Local aColsSXB	:= {}

DbSelectArea(cAliasQry)
(cAliasQry)->(dbGotop())
While !Eof()

	aAdd(aColsSXB,Array(Len(aHeadSXB)+1))
	nCols ++
	For nX := 1 To Len(aHeadSXB)
		aColsSXB[nCols][nX] := (cAliasQry)->( FieldGet( FieldPos( aHeadSXB[nX][2]  ) ) )
	Next nX
	aColsSXB[nCols][Len(aHeadSXB)+1] := .F.
    (cAliasQry)->(dbSkip())

Enddo

RestArea( aArea )

Return aColsSXB


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFNJSxbRFlt  บAutor ณMauricio Pequim Jr. บ Data ณ 31/07/2012 บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de retorno da consulta SN302                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FNJSxbRFlt(nCpo)

Local uRet		:= ""
Local oModel	:= FWModelActive()
Local oModelFNJ	:= oModel:GetModel("FNJDETAIL")
Local cBase		:= oModelFNJ:GetValue("FNJ_CBAEXE")
Local cItem		:= oModelFNJ:GetValue("FNJ_ITEXE")
Local cTipo		:= oModelFNJ:GetValue("FNJ_TAFEXE")
Local cTpSld	:= oModelFNJ:GetValue("FNJ_SLDEXE")

If Len(aDadosFNJ) > 0
	uRet := aDadosFNJ[nCpo]
Else
	DO CASE
		CASE nCpo == 1
			uRet := cBase
		CASE nCpo == 2
			uRet := cItem
		CASE nCpo == 3
			uRet := cTipo
		CASE nCpo == 4
			uRet := cTpSld
		OTHERWISE
			uRet := ""
	END CASE
Endif

Return uRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณAF430VldF3  บAutor ณMauricio Pequim Jr. บ Data ณ 31/07/2012 บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de retorno da consulta SN302                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430VldF3(aColsSXB,nPos)

aDadosFNJ := {}

If Len(aColsSXB) > 0
	aDadosFNJ := aClone(aColsSXB[nPos])
Endif

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณAF430STAT   บAutor ณMauricio Pequim Jr. บ Data ณ 31/07/2012 บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Combo box dos campos de Status do projeto                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430STAT(cCodStatus)

Local cStatus := ""

DEFAULT cCodStatus := ""

cStatus := "0="+STR0002 +";"	//Gerado
cStatus += "1="+STR0003 +";"	//Ativo
cStatus += "2="+STR0004 +";"	//Encerrado
cStatus += "3="+STR0133 +";"	//"Bloqueado - Rejei็ใo"
cStatus += "7="+STR0005 +";"	//"Bloqueado - Revisใo"
cStatus += "8="+STR0006 +";"	//"Bloqueado - Aprovacใo"
cStatus += "9="+STR0007 +";"	//"Bloqueado - Usuแrio"
cStatus += "A="+STR0155 		//"Realiza็ใo Pendente"

//Utilizado apenas para o retorno da descricao do Status
If !Empty(cCodStatus)

	If Len(aStatus) == 0
		aStatus := STRTOKARR(cStatus,";")
	Endif

	If (nPos := Ascan(aStatus,{|aCod| Substr(aCod,1,1) == Alltrim(cCodStatus)}) ) > 0
		cStatus := STR0150 + Substr(aStatus[nPos],3)
	Endif
Endif

Return cStatus


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณAF430VBem   บAutor ณMauricio Pequim Jr. บ Data ณ 31/07/2012 บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Visualizacao do bem (tela de consulta F3)                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430VBem(aColsSXB,nPos)

Local aAreaSN1	:= SN1->(GetArea())
Local aArea		:= GetArea()

If Len(aColsSXB) > 0
	If !Empty(aColsSXB[nPos][1]) .and. !Empty(aColsSXB[nPos][2])
		dbSelectArea("SN1")
		SN1->(dbSetOrder(1))
		If SN1->(MsSeek(xFilial("SN1")+aColsSXB[nPos][1]+aColsSXB[nPos][2]))
			FWExecView("","ATFA012",/*Por padrใo a opera็ใo ้ Veiw*/, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/)
		Endif
	Endif
EndIf

RestArea(aAreaSN1)
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA430ATU บAutor  ณAlvaro Camillo Neto บ Data ณ  24/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a gera็ใo das fichas do ativo fixo vinculadas      บฑฑ
ฑฑบ          ณ ao projeto de ativo                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430EFRE(cAlias,nReg,nOpc)
Local aArea			:= GetArea()
Local lConfirma		:= .F.
Local lCancela		:= .F.
Local cTitulo 		:= ""
Local cPrograma 	:= ""
Local nOperation 	:= MODEL_OPERATION_VIEW
Local cCodPrj		:= FNB->FNB_CODPRJ
Local cRev			:= FNB->FNB_REVIS
Local lRet			:= .T.
//Verifico se a Baixa de Provisao de Imobilizado esta implantada
Local lBpiAtf := AFVldBpi()

If !lBpiAtf
	Help(" ",1,"AF430NOBPI",,STR0008,1,0)//"Dicionแrio de dados e RPO desatualizados, por favor atualizar lib do ambiente e executar atualizador do m๓dulo ATF e FIN"
	lRet := .F.
Endif

If lRet .and. !(FNB->FNB_STATUS == 'A' )
	cStatus := AF430Stat(FNB->FNB_STATUS)
	Help("  ",1,"AFR430RLZ",,STR0156 + CRLF + cStatus ,1,0)   //"Apenas projetos com status - Realiza็ใo Pendente - poderใo ter realiza็๕es efetivadas."
	lRet := .F.
EndIf

If lRet
	lRet := CtbInTran( 1, .F. )
EndIf

If lRet
	cTitulo 	:= STR0190 //"Efetiva็ใo de realiza็ใo de projeto"
	cPrograma 	:= 'ATFA430'
	nOperation 	:= MODEL_OPERATION_VIEW // Visualizar
	__lConfirmar:= .F.
	__nOper     := OPER_EFETREAL
	__lBTNConfirma  := .T.

	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )

	If __lConfirmar
		MsgRun( STR0157 ,, {||	lRet := AF430GerRz(cCodPrj,cRev) } ) //"Efetivando as realiza็๕es do projeto...."
	EndIf
EndIf

__lConfirmar:= .F.
__lBTNConfirma  := .F.
__nOper     := 0

RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430GerRzบAutor  ณMauricio Pequim Jr  บ Data ณ  01/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo que realiza a grava็ใo das fichas do ativo do        บฑฑ
ฑฑบ          ณprocesso                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430GerRZ(cCodPrj,cRev)
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaFNB	:= FNB->(GetArea())
Local aAreaFNC	:= FNC->(GetArea())
Local aAreaFND	:= FND->(GetArea())
Local aAreaFNE	:= FNE->(GetArea())
Local aAreaFNJ	:= FNJ->(GetArea())
Local aRecnosFNJ:= {}
Local nX        := 0
Local cIdCV8    := ""
Local cMensIni  := STR0092 + cCodPrj + STR0083+ cRev //" Atualiza็ใo do projeto "##" revisใo: "
Local cProc     := __cProcPrinc + "EFETRLZ"
Local cSubProc  := cCodPrj+cRev
Local cAliasQry	:= "FNJ430"
Local nTotal	:= 0
Local cArquivo	:= ''
Local cLoteAtf	:= LoteCont("ATF")
Local cPadrao	:= "880"
Local lPadrao   := VerPadrao(cPadrao)
Local lDigita	:= .T.
Local lAglutina := .f.
Local nHdlPrv	:= 0
Local nValorLanc := 0
Local lAllContab := .T.
Local cItens := ""
Local lOnOff	:= .T.

PRIVATE LanceiCtb := .F.

Pergunte("AFA430",.F.)
lOnOff := MV_PAR01 == 1
lDigita := MV_PAR02 == 1
lAglutina := MV_PAR03 == 1

ProcLogIni( {},cProc,cSubProc,@cIdCV8 )
ProcLogAtu( "INICIO" , cMensIni,,,.T. )

If lPadrao

	FNB->(dbSetOrder(1)) //FNB_FILIAL+FNB_CODPRJ+FNB_REVIS
	FNC->(dbSetOrder(1)) //FNC_FILIAL+FNC_CODPRJ+FNC_REVIS+FNC_ETAPA
	FND->(dbSetOrder(1)) //FND_FILIAL+FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM
	FNE->(dbSetOrder(1)) //FNE_FILIAL+FNE_CODPRJ+FNE_REVIS+FNE_ETAPA+FNE_ITEM+FNE_LINHA
	FNJ->(dbSetOrder(2)) //FNJ_FILIAL+FNJ_CODPRJ+FNJ_REVIS+FNJ_ETAPA+FNJ_ITEM+FNJ_LINHA+FNJ_TAFPRJ+FNJ_SLDPRJ+FNJ_CBAEXE+FNJ_ITEXE+FNJ_TAFEXE+FNJ_SLDEXE

	//Query na FNJ
	cQuery := "SELECT R_E_C_N_O_ FNJRECNO, FNJ_FILIAL, FNJ_CODPRJ, FNJ_REVIS, FNJ_ETAPA, FNJ_ITEM, "
	cQuery += "FNJ_LINHA, FNJ_TAFPRJ, FNJ_SLDPRJ, FNJ_CBAEXE, FNJ_ITEXE, FNJ_TAFEXE, FNJ_SLDEXE "
	cQuery += " FROM " + RetSQLTab('FNJ')
	cQuery += " WHERE "
	cQuery += 	 "FNJ_CODPRJ = '" + cCodPrj	+"' AND "
	cQuery += 	 "FNJ_REVIS  = '" + cRev     +"' AND "
	cQuery += 	 "FNJ_DTCONT = ' ' AND "
	cQuery += 	 RetSqlCond("FNJ")

	cQuery += "ORDER BY FNJ_FILIAL,FNJ_CODPRJ,FNJ_REVIS,FNJ_ETAPA,FNJ_ITEM,FNJ_LINHA,FNJ_TAFPRJ,FNJ_SLDPRJ,FNJ_CBAEXE,FNJ_ITEXE,FNJ_TAFEXE,FNJ_SLDEXE "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	dbSelectArea(cAliasQry)
	DbGotop()

	//array com recnos
	While (cAliasQry)->(!EOF())
		aadd( aRecnosFNJ, (cAliasQry)->(FNJRECNO) )
		(cAliasQry)->(dbSkip())
	EndDo

	If Len(aRecnosFNJ) == 0
		lRet := .F.
	Endif

	(cAliasQry)->(dbCloseArea())

	If lRet .and. lOnOff
		Begin Transaction

			For nX := 1 to Len(aRecnosFNJ)

				DbSelectArea("FNJ")
				dbSetOrder(2)
				FNJ->(dbGoto(aRecnosFNJ[nX]))

				FNB->(MsSeek( xFilial("FNB") + cCodPrj + cRev ))
				FNC->(MsSeek( xFilial("FNC") + cCodPrj + cRev ))
				FND->(MsSeek( xFilial("FND") + cCodPrj + cRev + FNJ->FNJ_ETAPA ))
				FNE->(MsSeek( xFilial("FNE") + cCodPrj + cRev + FNJ->FNJ_ETAPA + FNJ->FNJ_ITEM ))

				//Verifico Handle de contabilizacao
				If nHdlPrv <= 0
					nHdlPrv := HeadProva(cLoteAtf,"ATFA430",Substr(cUsername,1,6),@cArquivo)
				EndIf

				If nHdlPrv > 0
 					nValorLanc := DetProva(nHdlPrv,cPadrao,"ATFA430",cLoteAtf)
					nTotal += nValorLanc

					if nValorLanc > 0
						RecLock("FNJ")
						FNJ->FNJ_DTCONT  := dDatabase
						MsUnlock( )
					else
						lAllContab := .F.
						cItens += STR0201 +FNJ->FNJ_ETAPA + STR0202+ FNJ->FNJ_CBAEXE  //" Etapa :"##" Bem : "
					endif
				Endif

			Next

			If nHdlPrv > 0 .And. nTotal > 0
				RodaProva(nHdlPrv, nTotal)
				cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,lDigita,lAglutina)
				if lAllContab
					AF430FLAG(cCodPrj,cRev,"1")
					ProcLogAtu( "MENSAGEM",  STR0163,STR0164 + cCodPrj + STR0086 + cRev + STR0093,,.T. ) //"Processo efetuado com sucesso."##"Foram efetivadas as baixas de provisใo do projeto "##" Revisใo: "##" foram atualizadas corretamente "
	         	else
	     			ProcLogAtu( "ERRO", STR0194, STR0195 + cCodPrj + " " + cRev+ STR0196 +cItens+ STR0197 ,,.T. ) //"Alguns dos bens para realiza็ใo nใo foram contabilizados."##"Os seguintes Bens do projeto "##" nใo foram contabilizados: "##", o projeto nใo teve a realiza็ใo efetivada."
	          	endif
			Else
				ProcLogAtu( "ERRO", STR0198 , STR0199 + cCodPrj + " " + cRev+ STR0200 ,,.T. ) // "A realiza็ใo nใo foi contabilizada."##"Todos os Bens do projeto "##" nใo foram contabilizados, o projeto nใo teve a realiza็ใo efetivada."
		   Endif

		End Transaction

	Else
		ProcLogAtu( "ERRO", STR0165, STR0166 + cCodPrj + STR0086 + cRev ,,.T. ) // "Nใo foram encontrados registros."##"Nใo foram encontrados registros para realiza็ใo neste Projeto: "
	EndIf
Else
	ProcLogAtu( "ERRO", STR0167 , STR0167 + STR0168,,.T. )  //"Lan็amento Padrใo 880 - Baixa de Provisใo nใo cadastrado."##"O processamento nใo se realizarแ sem o mesmo."
Endif

ProcLogAtu( "FIM" ,,,,.T.)
ProcLogView(cFilAnt,cProc,cSubProc,cIdCV8)

RestArea(aAreaFNJ)
RestArea(aAreaFNE)
RestArea(aAreaFND)
RestArea(aAreaFNC)
RestArea(aAreaFNB)
RestArea(aArea)

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf430FnjI บAutor  ณMauricio Pequim Jr  บ Data ณ  07/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica a existencia de duplicidades nas realizacoes       บฑฑ
ฑฑบ          ณ efetuadas (Ativos relacionados a cada Item de Etapa)       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Af430FnjI(oModel)

Local lRet := .T.
Local oModelFNE		:= oModel:GetModel("FNEDETAIL")
Local oModelFNJ		:= oModel:GetModel("FNJDETAIL")
Local cBaseExe		:= ""
Local cItemExe		:= ""
Local cTipoExe		:= ""
Local cTpSldExe		:= ""
Local cEtapaPrj		:= ""
Local cItemPrj		:= ""
Local cLinhaPrj		:= ""

If __nOper == OPER_REALIZAR

	cBaseExe  := oModelFNJ:GetValue("FNJ_CBAEXE")
	cItemExe  := oModelFNJ:GetValue("FNJ_ITEXE")
	cTipoExe  := oModelFNJ:GetValue("FNJ_TAFEXE")
	cTpSldExe := oModelFNJ:GetValue("FNJ_SLDEXE")
	cEtapaPrj := oModelFNE:GetValue('FNE_ETAPA')
	cItemPrj  := oModelFNE:GetValue('FNE_ITEM')
	cLinhaPrj := oModelFNE:GetValue("FNE_LINHA")

	If !Empty(cBaseExe)
		If Len(aCargaFNJ) > 0

			//Busco o bem nos dados do FNJ dos bens do projeto
			nPos :=  aScan(aCargaFNJ, {|e| e[1] == cBaseExe .and. e[2] == cItemExe .and. e[3] == cTipoExe .and. e[4] == cTpSldExe } )

			//Caso tenha sido encontrado mas em outro item de projeto, cancelo a inclusao
			If nPos > 0 .and. ( aCargaFNJ[nPos][5] != cEtapaPrj .or. ;
								aCargaFNJ[nPos][6] != cItemPrj .or. ;
								aCargaFNJ[nPos][7] != clinhaPrj  )

				Help("  ",1,"AF430FNJVLD",, STR0169 + CRLF+;		//"Imobilizado relacionado em duplicidade."
											STR0170 + cBaseExe+ STR0171 + cItemExe + CRLF+CRLF+;  //"Cod.Base: "###" /Item: "
											"--------- "+STR0172 + " 01 --------" + CRLF +;		//"Ocorr๊ncia"
											STR0173 + aCargaFNJ[nPos][5] + CRLF +;				//"Etapa: "
											STR0174 + aCargaFNJ[nPos][6] + CRLF +;				//"Item Etapa: "
											STR0175 + aCargaFNJ[nPos][7] + CRLF +;		//"Cfg. Contแbil: "
											"--------- "+STR0172 + " 02 --------" + CRLF +;		//"Ocorr๊ncia"
											STR0173 + cEtapaPrj + CRLF +;						//"Etapa: "
											STR0174 + cItemPrj  + CRLF +;						//"Item Etapa: "
											STR0175 + cLinhaPrj  + CRLF ,1,0) 					//"Cfg. Contแbil: "

				lRet := .F.

			ElseIf nPos == 0
				aadd(aCargaFNJ, {	cBaseExe, cItemExe, cTipoExe, cTpSldExe, cEtapaPrj, cItemPrj, cLinhaPrj })
			EndIf
		Else
			aadd(aCargaFNJ, {	cBaseExe, cItemExe, cTipoExe, cTpSldExe, cEtapaPrj, cItemPrj, cLinhaPrj })
		EndIf
	Endif
Endif

Return lRet





/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430CPRLZ ณ Autor ณMauricio Pequim Jr.  ณ Data ณ 13/11/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Zera o valor de realizacao do projeto quando realizada uma ณฑฑ
ฑฑณ          ณ copia do mesmo										  	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430CPRLZ(cCodPrj,cRev)

Local aArea		:= GetArea()
Local aAreaFNE	:= FNE->(GetArea())

FNE->(dbSetOrder(1)) //FNE_FILIAL+FNE_CODPRJ+FNE_REVIS+FNE_ETAPA+FNE_ITEM+FNE_LINHA

If FNE->(MsSeek( xFilial("FNE") + cCodPrj + cRev ))
	While FNE->(!EOF()) .And. FNE->(FNE_FILIAL+FNE_CODPRJ+FNE_REVIS) ==  xFilial("FNE") + cCodPrj + cRev
		RecLock("FNE",.F.)
		FNE->FNE_VLRRLZ := 0
		MsUnLock()
		FNE->(dbSkip())
	EndDo
EndIf

RestArea(aAreaFNE)
RestArea(aArea)

Return


/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ F430SelFolderณ Autor ณMauricio Pequim Jr.ณ Data ณ 04/10/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Seleciona o folder conforme a necessidade da rotina  o     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//-------------------------------------------------------------------
/* SelectFolder
Seleciona e exibe um FOLDER. Pode ser usado tanto para Folders do View,
quanto para folders criadas pelo metodo CreateFolder().

param cID ID da Folder ou do View
param xFolder N๚mero da Folder ou Tํtulo dela
param nType Tipo de Folder [ 1 - VIEW ; 2 - FOLDER ]
*/
Static Function F430SelFolder(oView)

If (__nOper == OPER_REALIZAR .or. __nOper == OPER_EFETREAL)
	oView:SelectFolder('PASTA_INFERIOR',2,2)
Else
	oView:SelectFolder('PASTA_INFERIOR',1,2)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ HasOpenFNJ   ณ Autor ณAlexandre Circenis ณ Data ณ 17/01/13 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Retorna .T. se ainda existirem itens de execucao (FNJ)     ณฑฑ
ฑฑณ          ณ nao contabilizados para um projeto.                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cCodProj - Codigo do Projeto                               ณฑฑ
ฑฑณ          ณ cRev     - Revisใo do Projeto                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function HasOpenFNJ(cCodPrj, cRev)
Local aSavArea := GetArea()
Local cQuery
Local cAliasQry := GetNextAlias()

cQuery := "SELECT R_E_C_N_O_ FNJRECNO, FNJ_FILIAL, FNJ_CODPRJ, FNJ_REVIS, FNJ_ETAPA, FNJ_ITEM, "
cQuery += "FNJ_LINHA, FNJ_TAFPRJ, FNJ_SLDPRJ, FNJ_CBAEXE, FNJ_ITEXE, FNJ_TAFEXE, FNJ_SLDEXE "
cQuery += " FROM " + RetSQLTab('FNJ')
cQuery += " WHERE "
cQuery += 	 "FNJ_CODPRJ = '" + cCodPrj	+"' AND "
cQuery += 	 "FNJ_REVIS  = '" + cRev     +"' AND "
cQuery += 	 "FNJ_DTCONT = ' ' AND "
cQuery += 	 RetSqlCond("FNJ")

cQuery += "ORDER BY FNJ_FILIAL,FNJ_CODPRJ,FNJ_REVIS,FNJ_ETAPA,FNJ_ITEM,FNJ_LINHA,FNJ_TAFPRJ,FNJ_SLDPRJ,FNJ_CBAEXE,FNJ_ITEXE,FNJ_TAFEXE,FNJ_SLDEXE "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

dbSelectArea(cAliasQry)

// Se a query retornar conteudo hแ resgitros nใo contabilizados no FNJ

lRet := !(cAliasQry)->(Eof())

(cAliasQry)->(dbCloseArea())

RestArea(aSavArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AF430AtvPo   ณ Autor ณAlexandre Circenis ณ Data ณ 31/01/13 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Retorna .T. caso existam ativos ligados o projeto com data ณฑฑ
ฑฑณ          ณ  de aquisi็ใo superior a data base.                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cCodProj - Codigo do Projeto                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF430AtvPo(cCodProj)
Local aSavArea := GetArea()
Local lRet
Local cAliasQry := GetNextAlias()
Local cQuery :=  ''

cQuery := "SELECT N1_CBASE , N1_ITEM"
cQuery += " FROM  "+RetSQLName("SN1")+" SN1"
cQuery += " WHERE"
cQuery += " SN1.N1_FILIAL = '"+xFilial("SN1")+"'"
cQuery += " AND SN1.N1_PROJETO = '"+cCodProj+"'"
cQuery += " AND SN1.N1_AQUISIC >  '"+Dtos(dDataBase)+"'"
cQuery += " AND SN1.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

dbSelectArea(cAliasQry)

// Se a query retornar conteudo ha ativos com data de aqusicao
// Posterior a data base.

lRet := !(cAliasQry)->(Eof())

(cAliasQry)->(dbCloseArea())

RestArea(aSavArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf430BlindบAutor  ณAlvaro Camillo Netoบ Data ณ  13/02/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se a rotina esta sendo executada por um processo  บฑฑ
ฑฑบ          ณ automatico                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Af430Blind()
Local lRet   := .T.
Local oView  := FWViewActive()
Local cId    := ""

If oView != Nil
	cId := oView:GetModel():GetId()
	If Alltrim(cId) == "ATFA430"
		lRet := .F.
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF430VNvTXบAutor  ณAlvaro Camillo Netoบ Data ณ  14/03/13    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se a taxa calculada estแ fora do tamanho do campo บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF430VNvTX()
Local oModel  := FWModelActive()
Local nTaxa   := 0  // AFCalcTx(cCodInd,nValBem,nValAVP,dDataIni,dDataFin)
Local lRet    := .T.
Local nMax    := Val(Replicate("9" , TamSx3("N1_TAXAVP")[1] - ( TamSx3("N1_TAXAVP")[2] + 1 ) ))
Local cTipoAVP:= oModel:GetValue("FNDDETAIL","FND_TPAVP")
Local cCodInd := oModel:GetValue("FNDDETAIL","FND_INDAVP")
Local nValBem := 0
Local nValAVP := oModel:GetValue("FNEDETAIL","FNE_AVPPLN")
Local dDataIni:= oModel:GetValue("FNDDETAIL","FND_DTPROV")
Local dDataFin:= oModel:GetValue("FNDDETAIL","FND_PRVEXC")

If Alltrim(cTipoAVP) == '2'
	nValBem := oModel:GetValue("FNEDETAIL","FNE_VRDACM")
Else
	nValBem := oModel:GetValue("FNEDETAIL","FNE_VORIG")
EndIf

nTaxa := AFCalcTx(cCodInd,nValBem,nValAVP,dDataIni,dDataFin)

If nTaxa > nMax
	Help("  ",1,"AFR430TXAVP",,STR0213 ,1,0) //"Taxa de AVP equivalente para esse valor de AVP planejado ้ invแlida"
	lRet := .F.
EndIf

Return lRet

