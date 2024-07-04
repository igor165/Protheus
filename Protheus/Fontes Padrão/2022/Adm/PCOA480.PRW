#Include "Protheus.ch"
#Include "apwizard.ch"
#INCLUDE "PCOA480.ch"

/*
	30/09/11
	Correção das Strings
*/

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOA480  ³ AUTOR ³ João Gonçalves Oliveira ³ DATA ³ 04.12.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa de Cadastramento das regras de distribuição           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOA480                                                        ³±±
±±³_DESCRI_  ³ Programa de Cadastro de Regras de Distribuição                 ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada com a sua chamada normal      ³±±
±±³          ³ partir do Menu ou a partir de uma funcao pulando assim o       ³±±
±±³          ³ browse principal e executando a chamada direta da rotina       ³±±
±±³          ³ selecionada.                                                   ³±±
±±³          ³ Exemplo: PCOA480(2) - Executa a chamada da funcao de visua-    ³±±
±±³          ³                       zacao da rotina.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpN1 : Chamada direta sem passar pela mBrowse                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PCOA480(nCallOpcx)


Private cCadastro	:= STR0001 //"Cadastro de Regras de distribuição"
Private aRotina := MenuDef()
Private nGrade  := 1

Set Key VK_F12 To A480Sele_Tipo()

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	nGrade := A480Sele_Tipo()
	If nCallOpcx <> Nil
		PCO480Dlg("ALS",ALS->(RecNo()),nCallOpcx,"",nGrade)
	Else
		MBrowse(6,1,22,75,"ALS")
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva    ³ Data³17/11/06   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera os registros correntes                       ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
f±±³          ³               ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,"AxPesqui",0,1,,.F.},;  //"Pesquisar"
{ STR0003,"AxVisual",0,2},;       //"Visualizar"
{ STR0004,"PCO480Dlg('ALS',ALS->(RecNo()),3,'',@nGrade)",0,3},;	  //"Incluir"
{ STR0005,"PCO480Dlg('ALS',ALS->(RecNo()),4,'',@nGrade)",0,4},;   //"Alterar"
{ STR0006,"PCO480Dlg('ALS',ALS->(RecNo()),5,'',@nGrade)",0,5},;   //"Excluir"
{ STR0042,"PCO480Dlg('ALU',ALU->(RecNo()),6,'',@nGrade)",0,6}}    //"Copiar"

If AMIIn(57) // AMIIn do modulo SIGAPCO (57)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona botoes do usuario na EnchoiceBar                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PCOA4801" )
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ³
		//P_E³ browse da tela de Regras de distribuição                               ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
		//P_E³               Ex. :  User Function PCOA4801                            ³
		//P_E³                      Return {{"Titulo", {|| U_Teste() } }}             ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( aUsRotina := ExecBlock( "PCOA4801", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)

Function PCO480DLG(cAlias,nReg,nCallOpcx,cEntiPlan,nGrade)

Local nContItem := 1
Local cTipoEnti := ""
Local cDescRegr := IIf(nCallOpcx == 3,Space(25),ALS->ALS_DESCR)
Local lRetoTela := .F.
Local lParam, lBrowse:=.T., lParam2, lParam3, lParam4
Local aParaWiza := {{4,"",.T.,STR0007,165,.F.,.F.},;
{4,"",.T.,STR0008,165,.F.,.F.},;
{4,"",.T.,STR0009,165,.F.,.F.},;
{4,"",.T.,STR0010,165,.F.,.F.},;
{4,"",.T.,STR0011,165,.F.,.F.},;
{4,"",.T.,STR0012,165,.F.,.F.}} //"###"Conta Orçamentária"###"Classe Orçamentária"###"Operação"###"Centro de Custo"###"Item Contábil"###"Classe de Valor"

Local aConfWiza := {.F.,.F.,.F.,.F.,.F.,.F.}

Local aColsALU  := {}
Local aColsALO  := {}
Local aRecALO   := {}
Local aHeadALO   := {}

Private oWizard
Private cRegrDist := IIf(nCallOpcx == 3 .Or. nCallOpcx == 6,Space(6),ALS->ALS_CODIGO)
Private cSalvRegr := IIf(nCallOpcx == 6,ALS->ALS_CODIGO,Space(6))
Private cEntiFilt := IIf(nCallOpcx == 3,Space(6),ALS->ALS_TPENTI)
Private lUtilPerc := IIf(nCallOpcx == 3,.T.,ALS->ALS_TPPERC $"1 " )
Private aRegrDist := {}
Private oGdRegra
Private aListEnti := {}
Private aListComb := {}
Private cEntiComb := ""
Private nEntiFilt := 4

If nCallOpcx <> 3
	
	//************************************************
	//  Força o Modo que foi cadastrado inicialmente *
	//************************************************
	nGrade := VAL(If( Empty(ALS->ALS_TPREGR) , "1" , ALS->ALS_TPREGR ))
	
EndIf
                                                                                                                                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel 1 - Tela inicial do Wizard 		            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oWizard := APWizard():New(STR0013/*<chTitle>*/,; //"Atencao"
STR0014/*<chMsg>*/, STR0015/*<cTitle>*/, ; //"Este assistente lhe ajudará a cadastrar ou dar manutenção nas regras para distribuição ""
IIf(nGrade == 1,STR0040,STR0016) +; //"Você deverá escolher os tipos de entidade utilizados na regra, na sequencia cadastrar as entidades e opcionalmente os seus percentuais "###"Você deverá na sequencia cadastrar as entidades e opcionalmente os percentuais de distribuição"
CRLF + CRLF + IIf(nCallOpcx == 3 .Or. nCallOpcx == 6,"",STR0017 +" - " + ALS->ALS_CODIGO), ; //"Regra : "
{||.T.}/*<bNext>*/,;
{||.T.}/*<bFinish>*/,;
.F./*<.lPanel.>*/, , , /*<.lNoFirst.>*/)

aAdd(aListEnti,{"AK5","ALP_CO    ",STR0007,"ExistCpo('AK5',AllTrim(M->ALU_ENTIDA),1)","AK5"})
aAdd(aListEnti,{"AK6","ALP_CLASSE",STR0008,"ExistCpo('AK6',AllTrim(M->ALU_ENTIDA),1)","AK6"})
aAdd(aListEnti,{"AKF","ALP_OPER  ",STR0009,"ExistCpo('AKF',AllTrim(M->ALU_ENTIDA),1)","AKF"})
aAdd(aListEnti,{"CTT","ALP_CC    ",STR0010,"ExistCpo('CTT',AllTrim(M->ALU_ENTIDA),1)","CTT"})
aAdd(aListEnti,{"CTD","ALP_ITCTB ",STR0011,"ExistCpo('CTD',AllTrim(M->ALU_ENTIDA),1)","CTD"})
aAdd(aListEnti,{"CTH","ALP_CLVLR ",STR0012,"ExistCpo('CTH',AllTrim(M->ALU_ENTIDA),1)","CTH"})

nEntiFilt := aScan(aListEnti,{|x| x[1] == cEntiFilt}) 

If nEntiFilt == 0

	nEntiFilt := 4

EndIf

If nGrade == 1
	
	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca entidades selecionadas no cadastro efetuado anteriormente. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ENDDOC*/
	
	If nCallOpcx <> 3
	
		For nContItem := 1 to Len(aConfWiza)
			aAreaSele := ALU->(GetArea())
			dbSelectArea("ALU")
			dbSetOrder(1)
			If ALU->(dbSeek(xfilial("ALU") + ALS->ALS_CODIGO + aListEnti[nContItem,1]))
				aConfWiza[nContItem] := .T.
			EndIf
			RestArea(aAreaSele)
		Next
		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 2a - Seleção dos tipos de entidade    	    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard:NewPanel(STR0019/*<chTitle>*/,; //"Seleção de entidades para regra de distribuição"
	STR0020/*<chMsg>*/,; //"Você deve selecionar os tipos de entidade que terão regras para distribuição "
	{||.T.}/*<bBack>*/,;
	{|| A480Next_Pane(@aConfWiza, , , ,@oGdRegra,@aRegrDist,@lUtilPerc,@nGrade)}/*<bNext>*/ ,;
	{||.T.}/*<bFinish>*/,;
	.T./*<.lPanel.>*/ ,;
	{|| A480Sele_Entid(oWizard,@lParam,aParaWiza,@aConfWiza)}/*<bExecute>*/)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 3 - Seleção das contas orçamentárias e percentuais   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard:NewPanel(STR0007/*<chTitle>*/,; //"Conta Orçamentária"
	STR0023/*<chMsg>*/,; //"Informe as contas orçamentárias e os percentuais de distribuição."
	{|| A480Back_Pane(@aConfWiza,@nGrade)}/*<bBack>*/,;
	{|| A480Next_Pane(@aConfWiza,.T.,@cDescRegr,aListEnti[1,1],@oGdRegra,@aRegrDist,@lUtilPerc,@nGrade)}/*<bNext>*/ ,;
	{|| .T.}/*<bFinish>*/,;
	.T./*<.lPanel.>*/ ,;
	{|| A480Regra_Ent(oWizard,@lParam,@cDescRegr,@aListEnti[1,1],@aRegrDist,nCallOpcx,@lUtilPerc, .T.)} /*<bExecute>*/)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 4 - Seleção das classes orçamentárias e percentuais  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard:NewPanel(STR0008/*<chTitle>*/,; //"Classe Orçamentária"
	STR0024/*<chMsg>*/, ; //"Informe as classes orçamentárias e os percentuais de distribuição."
	{|| A480Back_Pane(@aConfWiza,@nGrade)}/*<bBack>*/,;
	{|| A480Next_Pane(@aConfWiza,.T.,@cDescRegr,aListEnti[2,1],@oGdRegra,@aRegrDist,@lUtilPerc,@nGrade)}/*<bNext>*/ ,;
	{|| .T.}/*<bFinish>*/,;
	.T./*<.lPanel.>*/ ,;
	{|| A480Regra_Ent(oWizard,@lParam,@cDescRegr,@aListEnti[2,1],@aRegrDist,nCallOpcx,@lUtilPerc)} /*<bExecute>*/)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 5 - Seleção das operações e percentuais              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard:NewPanel(STR0009/*<chTitle>*/,; //"Operação"
	STR0025/*<chMsg>*/, ; //"Informe as operações e os percentuais de distribuição."
	{|| A480Back_Pane(@aConfWiza,@nGrade)}/*<bBack>*/,;
	{|| A480Next_Pane(@aConfWiza,.T.,@cDescRegr,aListEnti[3,1],@oGdRegra,@aRegrDist,@lUtilPerc,@nGrade)}/*<bNext>*/ ,;
	{|| .T.}/*<bFinish>*/,;
	.T./*<.lPanel.>*/ ,;
	{|| A480Regra_Ent(oWizard,@lParam,@cDescRegr,aListEnti[3,1],@aRegrDist,nCallOpcx,@lUtilPerc)} /*<bExecute>*/)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 6 - Seleção dos centros de custos e percentuais              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard:NewPanel(STR0010/*<chTitle>*/,; //"Centro de Custo"
	STR0026/*<chMsg>*/, ; //"Informe os centros de custos e os percentuais de distribuição."
	{|| A480Back_Pane(@aConfWiza,@nGrade)}/*<bBack>*/,;
	{|| A480Next_Pane(@aConfWiza,.T.,@cDescRegr,aListEnti[4,1],@oGdRegra,@aRegrDist,@lUtilPerc,@nGrade)}/*<bNext>*/ ,;
	{|| .T.} /*<bFinish>*/,;
	.T.      /*<.lPanel.>*/ ,;
	{|| A480Regra_Ent(oWizard,@lParam,@cDescRegr,aListEnti[4,1],@aRegrDist,nCallOpcx,@lUtilPerc)} /*<bExecute>*/)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 7 - Seleção dos ítens contábeis e percentuais        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard:NewPanel(STR0011/*<chTitle>*/,; //"Item Contábil"
	STR0027/*<chMsg>*/, ; //"Informe os ítens contábeis e os percentuais de distribuição."
	{|| A480Back_Pane(@aConfWiza,@nGrade)}/*<bBack>*/,;
	{|| A480Next_Pane(@aConfWiza,.T.,@cDescRegr,aListEnti[5,1],@oGdRegra,@aRegrDist,@lUtilPerc,@nGrade)}/*<bNext>*/ ,;
	{|| .T.} /*<bFinish>*/,;
	.T.  /*<.lPanel.>*/ ,;
	{|| A480Regra_Ent(oWizard,@lParam,@cDescRegr,aListEnti[5,1],@aRegrDist,nCallOpcx,@lUtilPerc)} /*<bExecute>*/)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 8 - Seleção das classes de valor e percentuais       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard:NewPanel(STR0012/*<chTitle>*/,; //"Classe de Valor"
	STR0028/*<chMsg>*/,; //"Informe as classes de valor e os percentuais de distribuição."
	{|| A480Back_Pane(@aConfWiza,@nGrade)}/*<bBack>*/,;
	{|| A480Next_Pane(@aConfWiza,.T.,@cDescRegr,aListEnti[6,1],@oGdRegra,@aRegrDist,@lUtilPerc,@nGrade)}/*<bNext>*/ ,;
	{|| .T.}/*<bFinish>*/,;
	.T./*<.lPanel.>*/ ,;
	{|| A480Regra_Ent(oWizard,@lParam,@cDescRegr,aListEnti[6,1],@aRegrDist,nCallOpcx,@lUtilPerc)} /*<bExecute>*/)
	
Else
	
	If nGrade == 3
		
		aAdd(aListComb,"1 - " + STR0007)
		aAdd(aListComb,"2 - " + STR0008)
		aAdd(aListComb,"3 - " + STR0009)
		aAdd(aListComb,"4 - " + STR0010)
		aAdd(aListComb,"5 - " + STR0011)
		aAdd(aListComb,"6 - " + STR0012)
		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 2b - Grade de distribuição das entidades	    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard:NewPanel(STR0043/*<chTitle>*/,; //"Grade de entidades para regra de distribuição"
	STR0044/*<chMsg>*/,; //"Você deve informar as entidades que serão utilizadas na regra de distribuição "
	{|| A480Back_Pane(@aConfWiza,@nGrade,@aColsALO) }/*<bNext>*/ ,;
	{|| A480Next_Pane(@aConfWiza, ,@cDescRegr, ,@oGdRegra,@aRegrDist,@lUtilPerc,@nGrade) }/*<bNext>*/ ,;
	{||.T.}/*<bFinish>*/,;
	.T./*<.lPanel.>*/ ,;
	{|| A480Grade_Reg(oWizard,@lParam,@cDescRegr,nCallOpcx,@lUtilPerc,@aColsALO,@aRecALO,@aHeadALO,@nGrade)}/*<bExecute>*/)

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel 9 - Finalização do cadastramento das regras          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWizard:NewPanel(STR0029/*<chTitle>*/,; //"Finalização"
STR0030/*<chMsg>*/,; //"Ao finalizar as regras anteriormente informadas serão cadastradas"
{|| A480Back_Pane(@aConfWiza,@nGrade,@aColsALO,@aRecALO,@aHeadALO)}/*<bBack>*/,;
{||.T.}/*<bNext>*/,;
{|| A480Grava_Regr(oWizard,lParam,@aRegrDist,@cDescRegr,nCallOpcx,@lUtilPerc,@nGrade,aColsALO,aRecALO,aHeadALO)}/*<bFinish>*/,;
.F./*<.lPanel.>*/ ,;
{|| A480Final_Regr(oWizard,@lParam,@aRegrDist,@cDescRegr,nCallOpcx,@lUtilPerc,@nGrade)} /*<bExecute>*/)

oWizard:Activate( .T./*<.lCenter.>*/,;
{||.T.}/*<bValid>*/,;
{||.T.}/*<bInit>*/,;
{||.T.}/*<bWhen>*/)

Return(lRetoTela)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A480Sele_Entid ºAutor  ³João Gonçalves de Oliveira º Data ³ 30/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para seleção dos tipos de entidade para planejamento            º±±
±±º          ³                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A480Sele_Entid(oWizard, lParam, aParaWiza,aConfWiza,nGrade,cDescRegr,lUtilPerc)

If lParam == NIL
	ParamBox(aParaWiza ,STR0023, aConfWiza,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel])  //"Parametros"
	lParam := .T.
Else
	a480Rest_Par(aConfWiza)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A480Regra_Ent ºAutor  ³João Gonçalves de Oliveira º Data ³ 04/12/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para configuração dos percentuais de distribuição               º±±
±±º          ³                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A480Regra_Ent(oWizard,lParam,cDescRegr,cTipoEnti,aRegrDist,nCallOpcx,lUtilPerc,lChkPercent)
Local nContItem := 0
Local oPanel

Default lChkPercent := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets com os dados do cabeçalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel := oWizard:oMPanel[oWizard:nPanel]
oSayCodi := TSay():New( 005, 008,{|| STR0021},oPanel,,,.F.,.F.,.F.,.T.,,,,, .F.,.F.,.F.,.F.,.F.)
oSayDesc := TSay():New( 020, 008,{|| STR0022},oPanel,,,.F.,.F.,.F.,.T.,,,,,.F.,.F.,.F.,.F.,.F.)
oChkPerc := TCheckBox():New(034,008,STR0049,{|u| If(PCount() > 0,lUtilPerc := u,lUtilPerc)},oPanel, 60, 12, ,,,{|| nCallOpcx == 3 },, ,, .T.,,,,)//"Utiliza Percentual ?"
oGetCodi := TGet():New( 004, 045,{|u| If(PCount() > 0,cRegrDist := u,cRegrDist)},oPanel,025,,'@!',{|| ! Empty(cRegrDist) .And. ExistChav("ALS",cRegrDist)},,,,.F.,,.T.,,.F.,{|| nCallOpcx == 3 .Or. nCallOpcx == 6},.F.,.F.,         ,   ,.F.,,"cRegrDist",,,,)
oGetDesc := TGet():New( 019, 045,{|u| If(PCount() > 0,cDescRegr :=u,cDescRegr)},oPanel,090,,'@!',{|| ! Empty(cDescRegr)},,,,.F.,,.T.,,.F.,{|| nCallOpcx == 3  .Or. nCallOpcx == 6},.F.,.F.,         ,.F.,.F.,,"cDescRegr",,,,)

If nCallOpcx <> 3 .Or. ! Empty(cRegrDist)
	If !lChkPercent
		oChkPerc :bWhen := {|| .F.}
		If nCallOpcx == 3
			oGetCodi :bWhen := {|| .F.}
			oGetDesc :bWhen := {|| .F.}
		EndIf
	EndIf
EndIf

nLinALU := 0
aHeader := GetaHeader("ALU",,{"ALU_CODIGO","ALU_DESCR","ALU_TPENTI"})
nPosiCamp := aScan(aListEnti,{|x| x[1] == cTipoEnti})
nCampEnti := aListEnti[nPosiCamp,2]

If nPosiCamp <> 0
	aHeader := a480Subs_Ent("ALU_ENTIDA",aListEnti[nPosiCamp,2],aListEnti[nPosiCamp,4])
EndIf

aColsALU := {}

If Len(aRegrDist) > 0
	
	For nContItem := 1 to Len(aRegrDist)
		
		If aRegrDist[nContItem,4] == cTipoEnti 
			aAdd(aColsALU,Array(Len(aHeader) + 1))
			nLinALU ++
			// Varre o aHeader para preencher o acols
			AEval(aHeader, {|x,y| aColsALU[nLinALU][y] := If(Alltrim(x[2])$"ALU_ALI_WT|ALU_REC_WT",NIL,If(x[10] == "V" , CriaVar(AllTrim(x[2])),;
			aRegrDist[nContItem,IIf(AllTrim(x[2])=="ALU_ENTIDA",5,IIf(AllTrim(x[2])=="ALU_DESCEN",6,IIf(AllTrim(x[2])=="ALU_PERC",7,10)))]  )) })
			
			// Deleted			
			aColsALU[nLinALU][Len(aHeader) + 1] := aRegrDist[nContItem,8] 
			
			//Endif
		EndIf
		
	Next
	
EndIf

If Len(aColsALU) == 0
	
	dbSelectArea("ALU")
	dbSetOrder(1)
	dbSeek(xFilial("ALU") + IIf(nCallOpcx == 6,cSalvRegr,cRegrDist) + cTipoEnti)
	While nCallOpcx != 3 .And. ! Eof() .And. ALU->ALU_FILIAL + ALU_CODIGO + ALU_TPENTI == xfilial("ALU") + IIf(nCallOpcx == 6,cSalvRegr,cRegrDist) + cTipoEnti
		
		aAdd(aColsALU,Array(Len(aHeader) + 1))
		nLinALU ++
		// Varre o aHeader para preencher o acols
		AEval(aHeader, {|x,y| aColsALU[nLinALU][y] := If(Alltrim(x[2])$"ALU_ALI_WT|ALU_REC_WT",NIL,If(x[10] == "V" , CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) )) })
		// Deleted
		aColsALU[nLinALU][Len(aHeader) + 1] := .F.
		//Endif
		ALU->(DbSkip())
		
	EndDo
	
EndIf

If Len(aColsALU) == 0
	
	AAdd(aColsALU,Array(Len(aHeader) + 1))
	nLinALU++
	
	// Varre o aHeader para preencher o acols
	AEval(aHeader, {|x,y| aColsALU[nLinALU][y] := IIf(Upper(AllTrim(x[2])) == "ALU_ITEM", StrZero(1,Len(ALU->ALU_ITEM)),  If(!(x[2]$"ALU_ALI_WT|ALU_REC_WT"), CriaVar(AllTrim(x[2])), NIL))})
	
	// Deleted
	aColsALU[nLinALU][Len(aHeader) + 1] := .F.
	
EndIf

oGdRegra := MsNewGetDados():New(50,4,136,278,7,,,"+ALU_ITEM",,,,,,,oPanel,aHeader,aColsALU)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a480Rest_ParºAutor  ³Paulo Carnelossi   º Data ³ 30/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para restauracao dos conteudos das variaveis MV_PAR  º±±
±±º          ³na navegacao entre os paineis do assistente de copia        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a480Rest_Par(aParam)
Local nX
Local cVarMem

For nX := 1 TO Len(aParam)
	cVarMem := "MV_PAR"+AllTrim(STRZERO(nX,2,0))
	&(cVarMem) := aParam[nX]
Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A480Subs_EntºAutor  ³João Gonçalves de Oliveira º Data ³ 06/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para substituição do campo tipo entidade para cadastramento  º±±
±±º          ³das regras                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A480Subs_Ent(cCampAnte,cCampNovo,cValiNovo)

Local aAreaSX3 := SX3->(GetArea())

SX3->(dbSetOrder(2))
SX3->(dbSeek(cCampNovo))
aHeader[2,6] := cValiNovo
aHeader[2,9] := SX3->x3_f3

SX3->(RestArea(aAreaSX3))
Return aHeader

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A480Back_PaneºAutor  ³João Gonçalves de Oliveira º Data ³ 11/12/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para tratamento quando do passo anterior no wizard (bBack)   º±±
±±º          ³                                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A480Back_Pane(aConfWiza,nGrade,aColsALO,aRecALO,aHeadALO)

Local lRet := .T.
Local nContItem

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica o painel anterior de acordo com os tipos de entidade       ~³
//³ selecionados anteriormente, quando da utilização da opção de          ~³
//³ distribuição por entidade                                             ~³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nGrade == 1
	
	nPaneAtua := oWizard:NPanel
	
	
	nContItem := nPaneAtua - 3
	nPaneAnte := nPaneAtua
	While nContItem >= 1
		
		If (nContItem + 2) <= nPaneAtua
			
			If ! aConfWiza[nContItem]
				
				nPaneAnte --
				
			Else
				
				nContItem := 0
				
			EndIf
			
		EndIf
		nContItem --
		
	End
	
	oWizard:NPanel := nPaneAnte

Else

	aColsALO := aClone(oGdRegra:aCols)
	
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A480Next_PaneºAutor  ³João Gonçalves de Oliveira º Data ³ 07/12/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para tratamento quando do próximo passo do wizard            º±±
±±º          ³                                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A480Next_Pane(aConfWiza,lConfBrow,cDescRegr,cTipoEnti,oGdRegra,aRegrDist,lUtilPerc,nGrade)

Local lRet := .T.
Local lEntiUnic := .T.
Local lCodiRegr := .T.
Local nPercEnti := 0
Local nPosiDEnt := 0
Local cDescTpEn := 0
Local nPosiEnti := 0
Local nPaneAtua := oWizard:NPanel
Local nContTota := Len(aConfWiza)
Local nProxPane := nPaneAtua
Local nContItem := 1
Local nContColu	:= 1
Local aEntiPane := {}
Local lSeleVali := .F.
Local nContRegr
Local lLinhVazi := .F.
Local lValiFilt := .T.
Local nContEnti := 0
Local aEntFil	:= {}
Local nX

lCodiRegr := IIf(Empty(cRegrDist) .Or. Empty(cDescRegr),.F.,.T.)

If lConfBrow <> NIL
	
	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua validação dos percentuais (caso utilize) e se existe³
	//³código para a regra de distribuição                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ENDDOC*/
	
	nPosiPerc := aScan(oGdRegra:aHeader,{|x| AllTrim(x[2]) == "ALU_PERC"})
	nPosiEnti := aScan(oGdRegra:aHeader,{|x| AllTrim(x[2]) == "ALU_ENTIDA"})
	
	For nContItem := 1 to Len(oGdRegra:aCols)
		
		nPercaCols := oGdRegra:aCols[nContItem,nPosiPerc]
		
		If nPercaCols <> 0 .Or. ! lUtilPerc
			
			If ! oGdRegra:aCols[nContItem,Len(oGdRegra:aCols[nContItem])]
				
				nPercEnti += nPercaCols
			
			EndIf	
			
			/*BEGINDOC
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Adiciona dados do aCols no vetor aRegrDist que controla³
			// as informações das getdados quando configurado para    ³
			//³distribuição por entidade                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ENDDOC*/
			
			If nGrade == 1	// Distribuição por entidade
				
				nPosiDEnt := aScan(aListEnti,{|x| x[1] == cTipoEnti})
				cDescTpEn := IIf(nPosiDEnt <> 0,aListEnti[nPosiDEnt,3],"")
				lSeleVali := .T.
				nPosiRegr := aScan(aRegrDist,{|x| x[1] == cRegrDist + cTipoEnti + oGdRegra:aCols[nContItem,1]})
				
				If nPosiRegr == 0
				
					aAdd(aRegrDist,{cRegrDist + cTipoEnti + oGdRegra:aCols[nContItem,1],cRegrDist,cDescRegr,cTipoEnti,oGdRegra:aCols[nContItem,2],;
					oGdRegra:aCols[nContItem,3],oGdRegra:aCols[nContItem,4],oGdRegra:aCols[nContItem,5],cDescTpEn,oGdRegra:aCols[nContItem,1]})
				
				Else
							
					aRegrDist[nPosiRegr,5] := oGdRegra:aCols[nContItem,nPosiEnti]					
					aRegrDist[nPosiRegr,6] := oGdRegra:aCols[nContItem,3]
					aRegrDist[nPosiRegr,7] := oGdRegra:aCols[nContItem,4]
					aRegrDist[nPosiRegr,8] := oGdRegra:aCols[nContItem,5]					
					
				EndIf
				
			EndIf
				
			
		EndIf
		
		/*BEGINDOC
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a entidade não foi informada duas vezes    ³
		// quando configurado para distribuição por entidade      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ENDDOC*/
		
		If nGrade == 1		
		
			If aScan(aEntiPane,oGdRegra:aCols[nContItem,nPosiEnti]) == 0
				
				aAdd(aEntiPane,oGdRegra:aCols[nContItem,nPosiEnti])
			
			Else
				
				lEntiUnic := .F.
					
			EndIf											
			
			If ! Empty(oGdRegra:aCols[nContItem,nPosiEnti]) 

				nContEnti ++

			EndIf				
			
		EndIf
		
	Next
	
	lRet := nPercEnti == IIf(lUtilPerc,100,0) .And. lEntiUnic .And. lCodiRegr .And. nContEnti > 0
	
Else
	
	If nGrade == 1
		
		For nContItem := 1 to Len(aConfWiza)
			
			If aConfWiza[nContItem]
				
				lSeleVali := .T.
				
			EndIf
			
		Next
		
		If ! lSeleVali
			
			lRet := .F.
			Aviso(STR0013,STR0035,{"Ok"},2)//"Atenção"###"Selecione entidade(s) para prosseguir "
			
		EndIf
		
		/*BEGINDOC
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Ÿ´Ÿ¿
		//³Exclui do vetor de controle as entidades que tiveram    ³
		// a seleção desabilitada                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Ÿ´ŸÙ
		//ENDDOC*/
		
		If Len(aRegrDist) > 0
			
			aClonDist := aClone(aRegrDist)
			aRegrDist := {}
			For nContItem := 1 to Len(aListEnti)
				
				For nContRegr := 1 to Len(aClonDist)
					If aClonDist[nContRegr,4] == aListEnti[nContItem,1] .And. aConfWiza[nContItem]
						aAdd(aRegrDist,{aClonDist[nContRegr,1],aClonDist[nContRegr,2],aClonDist[nContRegr,3],aClonDist[nContRegr,4],;
						aClonDist[nContRegr,5],aClonDist[nContRegr,6],aClonDist[nContRegr,7],aClonDist[nContRegr,8],aClonDist[nContRegr,9],aClonDist[nContRegr,10]})
					EndIf
				Next
				
			Next
			
		EndIf
		
	Else	
		
		nPosiPerc := aScan(oGdRegra:aHeader, {|x| AllTrim(x[2]) == "ALO_PERC"})
		If nGrade == 3
			nPosiFilt := aScan(oGdRegra:aHeader, {|x| AllTrim(x[2]) == "ALO_" + AllTrim(Substr(aListEnti[Val(Substr(cEntiComb,1,1)),2],5,6)) })			
		EndIf	
		
		For nContItem := 1 to Len(oGdRegra:aCols)
			
			nPercaCols := oGdRegra:aCols[nContItem,nPosiPerc]
			
			If nPercaCols <> 0
				
				If ! oGdRegra:aCols[nContItem,Len(oGdRegra:aCols[nContItem])]
					
					nPercEnti += nPercaCols
					
				EndIf
				
			EndIf
			
			If nGrade == 3 
			
				If !oGdRegra:aCols[nContItem,Len(oGdRegra:aCols[nContItem])] .and. Empty(oGdRegra:aCols[nContItem,nPosiFilt])
									
					lValiFilt := .F.
					lRet      := .F.
				
				// Monta vetor para validação de percentual para cada entidade de filtro.			
				ElseIf !oGdRegra:aCols[nContItem,Len(oGdRegra:aCols[nContItem])]
				
					If (nX := aScan( aEntFil , {|x| x[1]==oGdRegra:aCols[nContItem,nPosiFilt]} )) > 0

						aEntFil[nX,2] += nPercaCols

					Else

						Aadd( aEntFil , { oGdRegra:aCols[nContItem,nPosiFilt] , nPercaCols } )
					
					EndIf
				
				EndIf
				
			EndIf	                                                                                                             i			

			nContEnti := 0
			
			For nContColu := 1 to Len(oGdRegra:aCols[nContItem])
				
				If ! Empty(oGdRegra:aCols[nContItem,nContColu])
					
					nContEnti ++
					
				EndIf
				
			Next			
			
		Next
		
		lSeleVali := .T.
		
		If Len(oGdRegra:aCols) == 0
			
			lLinhVazi := .T.
			
		EndIf
		
		If lRet
		
			If nGrade == 3
	
				// Valida percentual por entidade do filtro
				If lUtilPerc
				
					lRet := ( aScan( aEntFil , {|x| x[2]<>100 } )==0 ) .And. lEntiUnic .And. lCodiRegr .And. nContEnti > 0
				
				Else
				
					lRet := ( aScan( aEntFil , {|x| x[2]<> 0 	} )==0 ) .And. lEntiUnic .And. lCodiRegr .And. nContEnti > 0
				
				EndIf
				
			Else
	
				lRet := nPercEnti == IIf(lUtilPerc,100,0) .And. lEntiUnic .And. lCodiRegr .And. nContEnti > 0
				
			EndIf
		
		EndIf
		
	EndIf
	
EndIf

If lRet
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Identifica o próximo painel de acordo com os tipos de entidade        ~³
	//³ selecionados anteriormente, quando a configuração for distribuição    ~³
	//³ por entidade                                                          ~³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If nGrade == 1
		
		For nContItem := 1 to nContTota
			
			If (nContItem + 1) >= nPaneAtua
				
				If ! aConfWiza[nContItem]
					nProxPane ++
				Else
					nContItem := nContTota ++
				EndIf
				
			EndIf
			
		Next
		
		oWizard:NPanel := nProxPane
		
	EndIf
	
Else
	
	If lSeleVali
		
		aRegrDist := {}
		
		If ! lCodiRegr
			
			Aviso(STR0013,STR0034,{"Ok"},2)  //"Atenção"###"Faltam informações no cabeçalho"
			
		Else
		
			If lLinhVazi .Or. nContEnti == 0
			
				Aviso(STR0013,STR0041,{"Ok"},2)  //"Atenção"###"Impossível cadastramento sem entidade "
			
			Else

				If ! lValiFilt

					Aviso(STR0013,STR0048,{"Ok"},2)  //"Atenção"###"Faltam informações da entidade do filtro"
	
				Else
		
						If lEntiUnic
						
							Aviso(STR0013,STR0032,{"Ok"},2)  //"Atenção"###"Cadastro com percentuais inconsistentes "
						
						Else		

				
						Aviso(STR0013,STR0033,{"Ok"},2)  //"Atenção"###"Entidade em duplicidade "
						
						EndIf
				
				EndIf
			
			EndIf	
		
		EndIf		
		
	EndIf
	
EndIf

If ExistBlock("PCO480VLD")
	lRet := ExecBlock("PCO480VLD",nGrade)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A480Final_Regr ºAutor  ³João Gonçalves de Oliveira º Data ³ 07/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para gravação das regras de distribuição informadas             º±±
±±º          ³                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A480Final_Regr(oWizard,lParam,aRegrDist,cDescRegr,nCallOpcx,lUtilPerc,nGrade)
Local nContItem := 1
Local aListDesc := {}
Local nLinhSaid := 65
Local cBlockSay := ""
Local oSayCod1
Local oSayDes1
Local oSayEnt1
Local oSayDes3

oPanel := oWizard:oMPanel[oWizard:nPanel]

oSayCod1 := TSay():New( 005, 008,{|| STR0021  },oPanel,,,.F.,.F.,.F.,.T.,,,,,.F.,.F.,.F.,.F.,.F.) // Código
oSayCod1 := TSay():New( 004, 045,{|| cRegrDist},oPanel,,,.F.,.F.,.F.,.T.,,,,,.F.,.F.,.F.,.F.,.F.)
oSayDes1 := TSay():New( 020, 008,{|| STR0022  },oPanel,,,.F.,.F.,.F.,.T.,,,,,.F.,.F.,.F.,.F.,.F.) // Descrição
oSayDes1 := TSay():New( 019, 045,{|| cDescRegr},oPanel,,,.F.,.F.,.F.,.T.,,,,,.F.,.F.,.F.,.F.,.F.)
oSayEnti := TSay():New( 050, 008,{|| STR0031  },oPanel,,,.F.,.F.,.F.,.T.,,,,,.F.,.F.,.F.,.F.,.F.) // Tipos de entidade cadastrados

For nContItem := 1 to Len(aRegrDist)
	
	If aScan(aListDesc,aRegrDist[nContItem,9]) == 0
		aAdd(aListDesc,aRegrDist[nContItem,9])
	EndIf
	
Next

For nContItem := 1 to Len(aListDesc)
	cBlockSay := "{|| '" + aListDesc[nContItem] + "'}"
	oSayDes3  := TSay():New(nLinhSaid,018,&cBlockSay,oPanel,,,.F.,.F.,.F.,.T.,,,,,.F.,.F.,.F.,.F.,.F.)
	nLinhSaid += 15
Next

If nGrade <> 1
	
	cBlockSay := "{|| '" + IIf(nGrade == 2,STR0047,STR0046) + "'}"  // Grade de Distribuição###Distribuição por Filtro
	oSayDes3  := TSay():New(nLinhSaid,018,&cBlockSay,oPanel,,,.F.,.F.,.F.,.T.,,,,,.F.,.F.,.F.,.F.,.F.)
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A480Grava_Regr ºAutor  ³João Gonçalves de Oliveira º Data ³ 10/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para gravação das regras de distribuição informadas             º±±
±±º          ³                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A480Grava_Regr(oWizard,lParam,aRegrDist,cDescRegr,nCallOpcx,lUtilPerc,nGrade,aColsALO,aRecALO,aHeadALO)

Local nContItem := 1
Local nI
Local aDeleALU  := {}
Local aDeleALO  := {}

Do Case

	Case nCallOpcx == 3 .Or. nCallOpcx == 6
	
		Reclock("ALS",.T.)
		ALS_FILIAL := xfilial("ALS")
		ALS_CODIGO := cRegrDist
		ALS_DESCR  := cDescRegr
		ALS_TPPERC := IIf(lUtilPerc,"1","2")
		ALS_TPREGR := StrZero(nGrade,1)		
		
		If nGrade == 3		
		
			ALS_TPENTI := aListEnti[Val(Substr(cEntiComb,1,1)),1]
			
		EndIf	
		
		MsUnlock()
		
	Case nCallOpcx == 4
	
		If ALS->(dbSeek(xfilial("ALS") + cRegrDist))
		
			Reclock("ALS",.F.)
			ALS_DESCR  := cDescRegr			
			
			If nGrade == 3		
		
				ALS_TPENTI := aListEnti[Val(Substr(cEntiComb,1,1)),1]
			
			EndIf			
			
			MsUnlock()
			
		EndIf
		
	Case nCallOpcx == 5
	
		If ALS->(dbSeek(xfilial("ALS") + cRegrDist))
		
			Reclock("ALS",.F.)
			Dele
			MsUnlock()
			
		EndIf
		
		If ALU->(dbSeek(xfilial("ALU") + cRegrDist))
			
			While ALU->ALU_CODIGO == cRegrDist .And. ! ALU->(Eof())
				aAdd(aDeleALU,ALU->(Recno()))
				ALU->(dbSkip())
			End
			For nContItem := 1 to Len(aDeleALU)
				ALU->(dbGoTo(aDeleALU[nContItem]))
				Reclock("ALU",.F.)
				Dele
				MsUnlock()
			Next
			
		EndIf
		
		If ALO->(dbSeek(xfilial("ALO") + cRegrDist))
			
			While ALO->ALO_CODIGO == cRegrDist .And. ! ALU->(Eof())
				aAdd(aDeleALO,ALO->(Recno()))
				ALU->(dbSkip())
			End
			For nContItem := 1 to Len(aDeleALO)
				ALO->(dbGoTo(aDeleALO[nContItem]))
				Reclock("ALO",.F.)
				Dele
				MsUnlock()
			Next
			
		EndIf
		
EndCase

For nContItem := 1 to Len(aRegrDist)

	Do Case
	
		Case nCallOpcx == 3
			If ! aRegrDist[nContItem,8]
				Reclock("ALU",.T.)
				ALU_FILIAL := xfilial("ALU")
				ALU_CODIGO := aRegrDist[nContItem,2]
				ALU_DESCR  := aRegrDist[nContItem,3]
				ALU_TPENTI := aRegrDist[nContItem,4]
				ALU_ITEM   := aRegrDist[nContItem,10]
				ALU_ENTIDA := aRegrDist[nContItem,5]
				ALU_DESCEN := aRegrDist[nContItem,6]
				ALU_PERC   := aRegrDist[nContItem,7]
				MsUnlock()
				
			EndIf
			
		Case nCallOpcx == 4 .Or. nCallOpcx == 6
			
			If ALU->(dbSeek(xfilial("ALU") + aRegrDist[nContItem,1] + aRegrDist[nContItem,5]))
			
				Reclock("ALU",.F.)
				If ! aRegrDist[nContItem,8]                                
					ALU->ALU_ENTIDA := aRegrDist[nContItem,5]
					ALU->ALU_PERC   := aRegrDist[nContItem,7]
				Else
					ALU->(DbDelete())
				EndIf
				MsUnlock()
				
			Else
		  		If ! aRegrDist[nContItem,8]   
					Reclock("ALU",.T.)
					ALU_FILIAL := xfilial("ALU")
					ALU_CODIGO := aRegrDist[nContItem,2]
					ALU_DESCR  := aRegrDist[nContItem,3]
					ALU_TPENTI := aRegrDist[nContItem,4]
					ALU_ITEM   := aRegrDist[nContItem,10]
					ALU_ENTIDA := aRegrDist[nContItem,5]
					ALU_DESCEN := aRegrDist[nContItem,6]
					ALU_PERC   := aRegrDist[nContItem,7]
					MsUnlock()
				EndIf
			EndIf
			
	EndCase
	
Next


If nCallOpcx = 3  .Or. nCallOpcx == 6 // Inclusao ou Cópia
	
	// Grava Grade
	For nI := 1 To Len(oGdRegra:aCols)
		If oGdRegra:aCols[nI][Len(oGdRegra:aCols[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("ALO",.T.)
		EndIf
		
		// Varre o aHeader e grava com base no aCols
		AEval(oGdRegra:aHeader,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), oGdRegra:aCols[nI][y])), ) })
		
		// Grava campos que nao estao disponiveis na tela
		Replace ALO_FILIAL With xFilial("ALO")
		Replace ALO_CODIGO With cRegrDist
		Replace ALO_DESCR  With cDescRegr
		MsUnlock()
	Next nI
	
ElseIf nCallOpcx = 4 
	
	// Grava Grade
	For nI := 1 To Len(oGdRegra:aCols)
		If nI <= Len(aRecALO) .And. aRecALO[nI] > 0
			ALO->(DbGoto(aRecALO[nI]))
			Reclock("ALO",.F.)
		Else
			If oGdRegra:aCols[nI][Len(oGdRegra:aCols[nI])] // Verifica se a linha esta deletada
				Loop
			Else
				Reclock("ALO",.T.)
			EndIf
		EndIf
		
		If oGdRegra:aCols[nI][Len(oGdRegra:aCols[nI])] // Verifica se a linha esta deletada
			ALO->(DbDelete())
		Else
			// Varre o aHeader e grava com base no acols
			AEval(oGdRegra:aHeader,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), oGdRegra:aCols[nI][y])), ) })
			
			// Grava campos que nao estao disponiveis na tela
			Replace ALO_FILIAL With xFilial()
			Replace ALO_CODIGO With cRegrDist
			Replace ALO_DESCR  With cDescRegr
			MsUnlock()
		EndIf
	Next nI
	
ElseIf nCallOpcx = 5 // Exclusao
	// Exclui Regra
	
	For nI := 1 To Len(oGdRegra:aCols)
		If nI <= Len(aRecALO) .And. aRecALO[nI] > 0
			ALO->(DbGoto(aRecALO[nI]))
			Reclock("ALO",.F.)
			ALO->(DbDelete())
			MsUnLock()
		EndIf
	Next nI
	
EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A480Sele_Tipo  ºAutor  ³João Gonçalves de Oliveira º Data ³ 30/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para seleção do tipo de cadastramento da regra de distribuição  º±±
±±º          ³                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A480Sele_Tipo()

Local aParaWiz2 := {{3,STR0039,1,{STR0037,STR0038,STR0046},165,"",.F.}}
Local aConfWiz2 := {.F.}
Local lRet

//ParamBox(aParaWiz2 ,STR0023,@aConfWiz2,,,.F.,120,3, ,"PCOA480_001",,.T.)  //"Parametros"
lRet := ParamBox(aParaWiz2 ,STR0023,@aConfWiz2,,,.F.,,, ,"PCOA480_001",,.T.)//"Parametros"

//*********************************************
// Quando a Parambox é caancelada retorna nil *
//*********************************************
If lRet
	
	nGrade := aConfWiz2[1]
	
EndIf

Return(nGrade)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A480Grade_Reg ºAutor  ³João Gonçalves de Oliveira º Data ³ 27/05/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para configuração de grade no cadastramento das regras de       º±±
±±º          ³ distribuição                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A480Grade_Reg(oWizard,lParam,cDescRegr,nCallOpcx,lUtilPerc,aColsALO,aRecALO,aHeadALO,nGrade)

Local nContItem := 0
Local oPanel
Local nList := 1
Local nI


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gets com os dados do cabeçalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oPanel   := oWizard:oMPanel[oWizard:nPanel]
oSayCodi := TSay():New( 005, 008,{|| STR0021},oPanel,,,.F.,.F.,.F.,.T.,,,,,.F.,.F.,.F.,.F.,.F.)
oSayDesc := TSay():New( 020, 008,{|| STR0022},oPanel,,,.F.,.F.,.F.,.T.,,,,,.F.,.F.,.F.,.F.,.F.)

If nGrade == 3

	cEntiComb := aListComb[nEntiFilt]
	oSayComb := TSay():New( 020, 140,{|| STR0045},oPanel,,,.F.,.F.,.F.,.T.,,,,,.F.,.F.,.F.,.F.,.F.)
	oCombList := TComboBox():New(020,168,{|u|If(PCount()>0,cEntiComb:=u , cEntiComb)},aListComb,100,100,oPanel,,,,,,.T.,,,)
	
EndIf

oChkPerc := TCheckBox():New(034,008,STR0049,{|u| If(PCount() > 0,lUtilPerc := u,lUtilPerc)},oPanel, 60, 12, ,,,{|| nCallOpcx == 3},, ,, .T.,,,,)//"Utiliza Percentual ?"
oGetCodi := TGet():New( 004, 045,{|u| If(PCount() > 0,cRegrDist :=u,cRegrDist)},oPanel,025,,'@!',{|| ! Empty(cRegrDist) .And. ExistChav("ALS",cRegrDist)},,,,.F.,,.T.,,.F.,{|| nCallOpcx == 3 .Or. nCallOpcx == 6},.F.,.F.,         ,   ,.F.,,"cRegrDist",,,,)
oGetDesc := TGet():New( 019, 045,{|u| If(PCount() > 0,cDescRegr :=u,cDescRegr)},oPanel,090,,'@!',{|| ! Empty(cDescRegr)},,,,.F.,,.T.,,.F.,{|| nCallOpcx == 3 .Or. nCallOpcx = 6},.F.,.F.,         ,.F.,.F.,,"cDescRegr",,,,)

If nCallOpcx <> 3 .Or. ! Empty(cRegrDist)
	
	oChkPerc :bWhen := {|| .F.}
	
EndIf

nLinALO := 0
aHeadALO := GetaHeader("ALO",,{"ALO_CODIGO","ALO_DESCR"})

If Len(aColsALO) == 0
	
	dbSelectArea("ALO")
	dbSetOrder(1)
	dbSeek(xFilial("ALO") + IIf(nCallOpcx == 6,cSalvRegr,cRegrDist))
	
	While nCallOpcx != 3 .And. ! Eof() .And. ALO->ALO_FILIAL + ALO_CODIGO == xfilial("ALO") + IIf(nCallOpcx == 6,cSalvRegr,cRegrDist)
		
		aAdd(aColsALO,Array(Len(aHeadALO) + 1))
		nLinALO ++
		
		// Varre o aHeader para preencher o acols
		aEval(aHeadALO, {|x,y| aColsALO[nLinALO][y] := If(Alltrim(x[2])$"ALO_ALI_WT|ALO_REC_WT",NIL,If(x[10] == "V" , CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) )) })
		
		// Deleted
		aColsALO[nLinALO][Len(aHeadALO) + 1] := .F.
		aAdd( aRecALO, ALO->( Recno() ) )
		
		//Endif
		ALO->(DbSkip())
		
	End
	
EndIf

If Len(aColsALO) == 0
	
	aAdd(aColsALO,Array(Len(aHeadALO) + 1))
	nLinALO++
	
	// Varre o aHeader para preencher o acols
	AEval(aHeadALO, {|x,y| aColsALO[nLinALO][y] := IIf(Upper(AllTrim(x[2])) == "ALO_ITEM", StrZero(1,Len(ALO->ALO_ITEM)),  If(!(x[2]$"ALO_ALI_WT|ALO_REC_WT"), CriaVar(AllTrim(x[2])), NIL))})
	
	// Deleted
	aColsALO[nLinALO][Len(aHeadALO) + 1] := .F.
	
EndIf

oGdRegra := MsNewGetDados():New(50,4,136,278,7,,,"+ALO_ITEM",,,,,,,oPanel,aHeadALO,aColsALO)

Return