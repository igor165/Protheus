#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "COLORS.CH"
#include "JPEG.CH"
#include "PLSA169.CH"
#INCLUDE "hat-actions.ch"

STATIC __cTipoUsoTit := GetNewPar("MV_PLCDTIT", "T")
STATIC __cTipoRegTit := GetNewPar("MV_PLTRTIT", "00")
STATIC __cGrauParTit := GetNewPar("MV_PLCDTGP", "01")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA169 ³ Autor ³Geraldo Felix Junior    ³ Data ³ 06.06.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±	
±±³Descricao ³ Transferencia de Usuarios entre contratos.                 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSA169()                                                  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA169()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := STR0011 //"Transfêrencia de beneficiário" 
PRIVATE cSelecao := ""
PRIVATE cNomTit := ""
PRIVATE aCritica := {}
PRIVATE cMatricula := ''
PRIVATE lObrgTit	:= .T.
PRIVATE aDadFam	:= {}

//³ Endereca a funcao de BROWSE                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F12,{|a,b| Pergunte("PLS169",.T.) })

Pergunte("PLS169",.F.)

// mv_par01 - Visualiza matriculas ?
BQQ->(DbSetOrder(1))
BQQ->(DbGoTop())
BQQ->(mBrowse(06,01,22,75,"BQQ"))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET KEY VK_F12 TO
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PL169MOV ³ Autor ³Geraldo Felix Junior.  ³ Data ³ 06.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Movimentacao da transferencia.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL169MOV(cAlias,nReg,nOpc,aVetC,aCampM)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local I__f := 0
LOCAL nOpca := 0
LOCAL bOk := {|| Iif(!VAL169PLS(nOpc), .F., (nOpca := 1, Iif(M->BQQ_TODOS = '0' .and. Empty(M->BQQ_USUARI), ;
	MsgAlert(STR0012), If(nOpc = K_Incluir, If(Obrigatorio(aGets, aTela), nOpca := 1, nOpca :=2 ), nOpca := 1)))), (nOpca == 1) } //"Informe um usuário!"
LOCAL aButtons := {}
LOCAL lExpUsr := BQQ->( FieldPos("BQQ_EXPUSR") ) > 0
LOCAL lExpFam := BQQ->( FieldPos("BQQ_EXPFAM") ) > 0

PRIVATE oDlg
PRIVATE oEnchoice
PRIVATE oGetDados
PRIVATE aTELA[0, 0]
PRIVATE aGETS[0]
PRIVATE aHeader  := {}
PRIVATE n        := 1
PRIVATE aCols    := {}
PRIVATE aVetTrab := {}
PRIVATE aChave   := {}
PRIVATE nOpcx    := nOpc
PRIVATE oFolder
PRIVATE lUseBWC  := .F.
PRIVATE lBloqAll := .F.

DEFAULT aCampM	:= {}
DEFAULT aVetC	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria as variaveis de memoria M->??? da vida.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Copy "BQQ" TO Memory Blank

If Len(aCampM) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Exemplo de preenchimento do array                                        |
	//|                                                                          |
	//| aadd(aCampM,{ {BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_CONEMP,;         |
	//| BA1->BA1_VERCON,BA1->BA1_SUBCON,BA1->BA1_VERSUB,BA1->BA1_MATRIC} ,;      |
	//| {PlsIntPad(),cCodEmpD,cCodConD,cVerConD,cSubConD,cVerSubD,''} )          |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	M->BQQ_EMPORI := aCampM[1, 1, 2]
	M->BQQ_EMPDES := aCampM[1, 2, 2]
	M->BQQ_CONORI := aCampM[1, 1, 3]
	M->BQQ_VCOORI := aCampM[1, 1, 4]
	M->BQQ_CONDES := aCampM[1, 2, 3]
	M->BQQ_VCODES := aCampM[1, 2, 4]
	M->BQQ_SUBORI := aCampM[1, 1, 5]
	M->BQQ_VRSORI := aCampM[1, 1, 6]
	M->BQQ_SUBDES := aCampM[1, 2, 5]
	M->BQQ_VRSDES := aCampM[1, 2, 6]
	M->BQQ_FAMORI := aCampM[1, 1, 7]
Endif

If Type('M->BQQ_FAMDES') == 'U'
	Aviso(STR0013, STR0014, {STR0015}) //"Atenção!"###"Esta versão da transferência exige que a propriedade do campo BQQ_FAMDES esteja como USADO! Altere a propriedade do campo usando o CONFIGURADOR!"###"Voltar"
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informacoes sobre a resolucao de tela para montar os objetos...     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 200, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
aadd(aButtons,{"FILTRO"   ,{|| (M->BQQ_EXPFAM := A169Build( "BA3",oDlg,Iif(lExpFam,M->BQQ_EXPFAM,NIL) ), lRefresh := .T.) },STR0016,STR0017} ) //"Filtro Família"###"Filtro Fam"
aadd(aButtons,{"FILTRO"   ,{|| (M->BQQ_EXPUSR := A169Build( "BA1",oDlg,Iif(lExpUsr,M->BQQ_EXPUSR,NIL) ), lRefresh := .T.) },STR0018,STR0019} ) //"Filtro Usuário"###"Filtro Usr"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnchoice := MSMGET():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.)
ACTIVATE MSDIALOG oDlg ON INIT Eval({||EnchoiceBar(oDlg,{||Iif((Iif(ExistBlock("PLSA169OK"),ExecBlock("PLSA169OK",.F.,.F.),.T.).and.Eval(bOk)),oDlg:End(),.F.)}, {||oDlg:End()},.F.,aButtons) })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rotina de gravacao dos dados...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK .and. nOpc = K_Incluir
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama rotina de processamento...                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Existblock("PL169PROU")
		Processa( {|| Execblock("PL169PROU",.F.,.F.,{cAlias,nReg,nOpc}) }, STR0020 ) //"Processando transferência..."
	Else
		
		If BQQ->( FieldPos("BQQ_CONSUB") ) > 0 .AND. M->BQQ_CONSUB == "1" 
			
			If FindFunction("PLTRANCSB")
				
				//Executa o processo de transferência de contrato e subcontrato sem bloquear os beneficiários e criar uma nova familia
				//levando em consideração o campo BQQ_CONSUB		
				Processa( {|| PLTRANCSB(M->BQQ_CODINT, M->BQQ_EMPORI, M->BQQ_CONORI, M->BQQ_VCOORI, M->BQQ_SUBORI, M->BQQ_VRSORI, M->BQQ_FAMORI, M->BQQ_CONDES,;
				 		                M->BQQ_VCODES, M->BQQ_SUBDES, M->BQQ_VRSDES ) }, STR0020 )
			Else
				//essa mensagem não foi incluida no CH pois não pode ser alterada.
				MsgAlert("A função PLTRANCSB não foi encontrada para concluir o processo de transferência entre contrato e subcontrato, entre em contato com o suporte", "Atenção")
			EndIf
		Else
			Processa( {|| PL169PROC(cAlias,nReg,nOpc,,aCritica,aDadFam) }, STR0020 ) //"Processando transferência..."
		EndIf 
	Endif
Else
	BQQ->(RollBackSX8())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL169PROC ºAutor  ³Geraldo Felix Juniorº Data ³  03/18/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processa transferencia. Criada para ser usada com o         º±±
±±º          ³PROCESSA().                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL169PROC(cAlias,nReg,nOpc,lAutomato,aCritica,aDadFam)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cModelo := GetNewPar("MV_PLTITCD", "2")
Local aArea     := GetArea()
Local nCnt
LOCAL nFcount	:= 0
LOCAL aXConteudo:= {}
LOCAL xConteudo	:= 0
LOCAL nBa3Lock	:= 0
LOCAL cUpdt		:= ""
LOCAL lJuriOri 	:= NIL
LOCAL lJuriDes	:= NIL
LOCAL cKey		:= ""
LOCAL cChave	:= ""
LOCAL lProdNiv	:= .F.
LOCAL cChaveCob	:= ""
LOCAL cBA3MatAnt:= ""
LOCAL cForCob	:= ""
LOCAL cOldMat	:= ""
LOCAL cNewMat	:= ""
Local aDigitos	:= {}
LOCAL dOldData	:= cTod('')
LOCAL aAC    	:= { STR0003 , STR0001  }
LOCAL cProAnt	:= ''
LOCAL cVerAnt	:= ''
LOCAL nRecNewFam:= 0
LOCAL cOldUsr	:= ''
LOCAL cNewUsr	:= ''
LOCAL _cNivel   := ''
LOCAL _cChave   := ''
LOCAL aCliente  := {}
LOCAL cAno 		:= ''
LOCAL cMes 		:= ''
LOCAL cBloFat	:= ''
LOCAL cProNew	:= ''
LOCAL cVerNew	:= ''
LOCAL aUsrFam	:= {}
LOCAL lBloqBA3	:= .T.
LOCAL nUsrFam	:= 0
LOCAL cCodCli	:= ""
LOCAL cCodLoj	:= ""
LOCAL nVencto	:= 0
LOCAL cNature := ""
LOCAL cCobNiv	:= ""
LOCAL cTipCon	:= ""
LOCAL nStru 	:= 0
LOCAL nIt		:= 0
LOCAL lExistTitul:= .F.
LOCAL aStrubdk  :={}
LOCAL aStruBZX  :={}
LOCAL aStruBF4	:={}
local aStruBYX	:={}
local aStruBCP	:={}
LOCAL aCamposBDK:={}
LOCAL aCamposBF4:={}
LOCAL aCamposBYX:={}
LOCAL aCamposBZX:={}
LOCAL aCamposBCP:={}
LOCAL aBDKItens	:={}
LOCAL aBZXItens	:={}
LOCAL aBF4Itens :={}
LOCAL aBYXItens :={}
LOCAL aBCPItens :={}
LOCAL lCentralObr := GetNewPar("MV_PLSEXCO",.F.) .AND. FindFunction("PLSCENTOBR") //Indica se o sistema utilizara a atualizacao automatica da central de obrigacoes sempre que um cadastro relevante for alterado no Protheus
Local lUsaSIP := "1" $ GetNewPar("MV_PLSTIPO","")
Local lUsaSIB := "2" $ GetNewPar("MV_PLSTIPO","")
Local lSIPSincrono := "1" $ GetNewPar("MV_PLOBRSI","1,2")
Local lSIBSincrono := "2" $ GetNewPar("MV_PLOBRSI","1,2")
LOCAL aCritSib := {}
LOCAL aOpcSip := {}
LOCAL aDadCobJob := {}
LOCAL aCmpOriTran := {}
LOCAL aCmpDesTran := {}
LOCAL aDadCob := {}
LOCAL aDadCli := {}
LOCAL lCritSib := .F.
LOCAL nBkpPar01 := 0
LOCAL lTransfCartAnt := GetNewPar("MV_PLCATAN",.F.)//indica se deverá importar ou não a carteirinha antiga na transferencia para o beneficiario de destino
LOCAL lNewFam := .F.
LOCAL cGrpFam := ""
LOCAL lReturn := .F.
LOCAL lPl169Grv := ExistBlock("PL169GRV")
LOCAL lPl169Fim := ExistBlock("PL169FIM")
LOCAL cCodRas   := "" 
LOCAL cCodNewTit	:=''
LOCAL cCodRefTitB3K :=''
LOCAL nI            := 0
LOCAL aMatHAT       := {}
LOCAL cChaveHAT     := ""
LOCAL aDadosBCA		:= {}
LOCAL lBloqUsr		:= .F.
LOCAL lBloqFut      := .F. // Define se irá transferir beneficiários que estão com bloqueio futuro - Padrão é .F.
LOCAL cMotDes 		:= ""
LOCAL cBloFatDes 	:= ""

DEFAULT lAutomato := .F. // Automatização 
DEFAULT aCritica  := {}  // Devido a automação a Critica precisa esta vazio
DEFAULT aDadFam   := {}  // Dados Correspondente a Familia Origem (Ex: Alteração do Salario da Familia)

cBloFat := Posicione("BG3",1,xFilial("BG3")+M->BQQ_MOTBLO,"BG3_BLOFAT")
BG7->(DbGoTo(nReg))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem o numero de usuarios a serem processados para repassar a regua de progresso |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nRegua := PL169REGUA()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a regua...                                                                 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutomato
	ProcRegua(nRegua)
Endif	

Begin Transaction

	// Bloqueio futuro - 0 = Não e 1 = Sim
	If BQQ->(fieldPos('BQQ_BLOQFU')) > 0  
		lBloqFut := IIF(M->BQQ_BLOQFU == "1", .T., .F.)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona os usuarios da origem...                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSql := "SELECT * FROM "+RetSqlName('BA1')+" WHERE BA1_CODINT = '"+M->BQQ_CODINT+"' "
	cSql += "AND BA1_CODEMP = '"+M->BQQ_EMPORI+"' "

	If lBloqFut // Bloquei Futuro
		cSql += "AND (BA1_DATBLO = '"+SPACE(LEN(dTos(BA1->BA1_DATBLO)))+"' "
		cSql += "OR BA1_DATBLO > "+DtoS(dDataBase)+") "
	Else // Padrão
		cSql += "AND BA1_DATBLO = '"+SPACE(LEN(dTos(BA1->BA1_DATBLO)))+"' "
	EndIf
	
	If !Empty(M->BQQ_CONORI)
		cSql += "AND BA1_CONEMP = '"+M->BQQ_CONORI+"' AND BA1_VERCON = '"+M->BQQ_VCOORI+"' "
	Endif
	If !Empty(M->BQQ_SUBORI)
		cSql += "AND BA1_SUBCON = '"+M->BQQ_SUBORI+"' AND BA1_VERSUB = '"+M->BQQ_VRSORI+"' "
	Endif
	If !Empty(M->BQQ_FAMORI)
		cSql +=  " AND BA1_MATRIC = '"+M->BQQ_FAMORI+"' "
	Endif

	If !Empty(M->BQQ_USUARI)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³alteracao daher ipaseal															  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cUser := alltrim(M->BQQ_USUARI)
		cUser := strtran(cUser,",","','")
		cUser := "('" + cUser + "')"
		cSql  += " AND BA1_TIPREG IN " + cUser

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso seja transf. somente o titular, deve-sa cancelar todos os outros usuarios.   |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Alltrim(M->BQQ_USUARI) == "00" .AND. lBloqAll)
			cUpdt := "UPDATE "+RetSqlName("BA1")+" SET BA1_DATBLO = '"+dTos(M->BQQ_DATEXC)+ "',"
			cUpdt += "BA1_MOTBLO = '"+M->BQQ_MOTBLO+"', BA1_CONSID = 'U', BA1_IMAGE = 'DISABLE' "
			If BA1->( FieldPos("BA1_BLOFAT") ) > 0
				cUpdt += ",BA1_BLOFAT = '"+cBloFat+"' "
			Endif
			cUpdt += " WHERE "
			cUpdt += "BA1_CODINT = '"+M->BQQ_CODINT+"' AND BA1_CODEMP = '"+M->BQQ_EMPORI+"' "
			If !Empty(M->BQQ_CONORI)
				cUpdt += "AND BA1_CONEMP = '"+M->BQQ_CONORI+"' AND BA1_VERCON = '"+M->BQQ_VCOORI+"' "
			Endif
			If !Empty(M->BQQ_SUBORI)
				cUpdt += "AND BA1_SUBCON = '"+M->BQQ_SUBORI+"' AND BA1_VERSUB = '"+M->BQQ_VRSORI+"' "
			Endif
			If !Empty(M->BQQ_FAMORI)
				cUpdt += " AND BA1_MATRIC = '"+M->BQQ_FAMORI+"' "
			Endif
			cUpdt += " AND BA1_GRAUPA <> '"+__cGrauParTit+"' "

			If lBloqFut // Bloquei Futuro
				cUpdt += " AND (BA1_MOTBLO = ' ' OR BA1_DATBLO > "+DtoS(M->BQQ_DATEXC)+") "
			Else // Padrão
				cUpdt += " AND BA1_MOTBLO = ' ' "
			EndIf

			cUpdt += " AND D_E_L_E_T_ = ' ' "
			TcSqlExec(cUpdt)
		Endif
	Endif
	cSql += " AND "+RetSqlName("BA1")+".D_E_L_E_T_ = ' ' "
	cSql += "ORDER BY BA1_CODINT, BA1_CODEMP, BA1_CONEMP, BA1_VERCON, BA1_SUBCON, BA1_VERSUB, BA1_MATRIC, BA1_TIPREG"
	PlsQuery(cSql,"TRB169")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste a selecao...                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If TRB169->( Eof() )
		If !lAutomato
			MsgAlert(STR0021) //"Não existem usuários cadastrados nesta empresa."
		Endif	
		TRB169->( dbClosearea() )
		RestArea(aArea)
		lReturn := .T.
	Endif
	If !lReturn
		lJuriOri := !Empty(M->BQQ_CONORI)
		lJuriDes := !Empty(M->BQQ_CONDES)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o lote de transferencia..                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PLUPTENC("BQQ",nOpc)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava os registros no destino...                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !TRB169->( Eof() )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ So sera possivel saber se familia vai ser bloqueada apos a analize de    ³
			//³ todos os membros da mesma...                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lBloqBA3 := .F.

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Redefine a matriz de membros da familia...                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aUsrFam := {}
			If !Empty(M->BQQ_EXPUSR)
				BA1->( dbSetorder(02) )
				If BA1->( msSeek(xFilial("BA1")+TRB169->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)) )
					BA1->( dbEval({|| Aadd(aUsrFam,{BA1->BA1_TIPREG,BA1->BA1_TIPUSU,.F.}) },{||},;
						{|| BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == TRB169->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)}) )
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Compara o registro com os usuarios selecionados...                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M->BQQ_TODOS == '0'
				If !TRB169->BA1_TIPREG $ Alltrim(M->BQQ_USUARI)
					TRB169->( dbSkip() )
					If !lAutomato
						IncProc(STR0022+TRB169->BA1_CODINT+"."+TRB169->BA1_CODEMP+"."+TRB169->BA1_MATRIC+"."+TRB169->BA1_TIPREG) //"Desconsiderando usuário - "
					Endif	
					Loop
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera chave de campos...                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cChave := TRB169->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB+BA1_MATRIC)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera a nova matricula da Familia...                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(BQQ_FAMDES)
				If BA3->( dbSeek(xFilial("BA3")+M->BQQ_CODINT+M->BQQ_EMPDES+M->BQQ_FAMDES) )
					cMatricula := BA3->BA3_MATRIC
					cNewMat    := M->(BQQ_CODINT+'.'+BQQ_EMPDES+'.'+cMatricula)
				Endif
			Else
				cMatricula := ''
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera matricula da familia de destino...                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cMatricula)
				cMatricula := PLPROXMAT(M->BQQ_CODINT,M->BQQ_EMPDES)
				cNewMat    := M->(BQQ_CODINT+'.'+BQQ_EMPDES+'.'+cMatricula)
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona familia de Origem... no subcontrato de origem....              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lJuriOri
				BA3->( dbSetorder(07) )
				cKey := M->(BQQ_CODINT+BQQ_EMPORI+BQQ_CONORI+BQQ_VCOORI+BQQ_SUBORI+BQQ_VRSORI)+TRB169->BA1_MATRIC
				dOldData := BQC->BQC_DATCON
			Else
				BA3->( dbSetorder(01) )
				cKey := (M->BQQ_CODINT+M->BQQ_EMPORI+TRB169->BA1_MATRIC)
				dOldData := M->BQQ_DATINC
			Endif

			If !BA3->( MsSeek(xFilial("BA3")+cKey) )
				TRB169->( dbSkip() )
				Loop
			Endif

			// Trata filtro da familia...
			If BQQ->( FieldPos("BQQ_EXPFAM") ) > 0 .and. !Empty(M->BQQ_EXPFAM) .and. !BA3->( &(M->BQQ_EXPFAM) )
				TRB169->( dbSkip() )
				Loop
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza variavel com as referencias da familia de origem...             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nBa3Lock   := BA3->( Recno() )

			If lTransfCartAnt
				cBA3MatAnt := "" 										// Matricula do sistema antigo
			Else
				cBA3MatAnt := BA3->BA3_MATANT 										// Matricula do sistema antigo
			Endif
			
			cGrpFam    := BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)			// Matricula do grupo familiar do desmembramento
			cOldMat    := BA3->(BA3_CODINT+'.'+BA3_CODEMP+'.'+BA3_MATRIC)	// Matricuca Atual, sera a matricula da familia bloqueada!
			cProAnt    := BA3->BA3_CODPLA										// Codigo do plano atual
			cVerAnt    := BA3->BA3_VERSAO										// Versao do plano atual
			cCodCli    := BA3->BA3_CODCLI
			cCodLoj    := BA3->BA3_LOJA
			nVencto    := BA3->BA3_VENCTO
			cNature    := BA3->BA3_NATURE
			cCobNiv    := BA3->BA3_COBNIV
			cTipCon    := BA3->BA3_TIPCON
			
			If BQQ->(fieldPos('BQQ_CODRAS')) > 0  
				cCodRas := M->BQQ_CODRAS
			EndIf
			
			While !TRB169->( Eof() ) .and. TRB169->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB+BA1_MATRIC) == cChave

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona usuario na tabela original BA1...                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BA1->(dbGoto(TRB169->R_E_C_N_O_))

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Executa filtro do usuario...                                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If BQQ->( FieldPos("BQQ_EXPUSR") ) > 0 .and. !Empty(M->BQQ_EXPUSR) .and. !BA1->( &(M->BQQ_EXPUSR) )

					TRB169->( dbSkip() )
					Loop
					
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Compara o registro com os usuarios selecionados...                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If M->BQQ_TODOS == '0'
					If !TRB169->BA1_TIPREG $ Alltrim(M->BQQ_USUARI)
						TRB169->( dbSkip() )
						If !lAutomato
							IncProc(STR0022+TRB169->BA1_CODINT+"."+TRB169->BA1_CODEMP+"."+TRB169->BA1_MATRIC+"."+TRB169->BA1_TIPREG)
						Endif	
						Loop
					Endif
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona Empresa                                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lAutomato
					IncProc(STR0023+TRB169->BA1_CODINT+"."+TRB169->BA1_CODEMP+"."+TRB169->BA1_MATRIC+"."+TRB169->BA1_TIPREG) //"Transferindo usuário - "
					IncProc()
				Endif	

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona Empresa                                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectarea("BG9")
				BG9->( dbSetorder(01) )
				BG9->( MsSeek(xFilial("BG9")+M->(BQQ_CODINT+BQQ_EMPDES)) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Mesmo difinindo o bloqueio da familia aqui, uma segunda analize sera feita³
				//³ ao final do processamento...                                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lBloqBA3 := .T.

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona e analisa dados do destino...                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lJuriDes
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona o contrato                                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectarea("BT5")
					BT5->( dbSetorder(01) )
					BT5->( MsSeek(xFilial("BT5")+M->(BQQ_CODINT+BQQ_EMPDES+BQQ_CONDES+BQQ_VCODES)) )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona o Sub contrato                                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectarea("BQC")
					BQC->( dbSetorder(01) )
					BQC->( MsSeek(xFilial("BQC")+M->(BQQ_CODINT+BQQ_EMPDES+BQQ_CONDES+BQQ_VCODES+BQQ_SUBDES+BQQ_VRSDES)) )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Foi solicitado para manter o produto original da familia...              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If BQQ->( FieldPos("BQQ_PROORI") ) > 0 .and. M->BQQ_PROORI == '1'
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifico se o produto original existe no subcontrato de destino...       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectarea("BT6")
						BT6->( dbSetorder(01) )
						If BT6->( MsSeek(xFilial("BT6")+M->(BQQ_CODINT+BQQ_EMPDES+BQQ_CONDES+BQQ_VCODES+BQQ_SUBDES+BQQ_VRSDES+cProAnt+cVerAnt)) )
							cProNew := BT6->BT6_CODPRO
							cVerNew := BT6->BT6_VERSAO
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Se no destino nao existir o produto da origem, a rotina sugere um outro produto      |
							//| de acordo com os parametros da transferencia...                                      |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If Empty(M->BQQ_CODPRO)
								dbSelectarea("BT6")
								BT6->( dbSetorder(01) )
								BT6->( MsSeek(xFilial("BT6")+M->(BQQ_CODINT+BQQ_EMPDES+BQQ_CONDES+BQQ_VCODES+BQQ_SUBDES+BQQ_VRSDES)) )
								cProNew := BT6->BT6_CODPRO
								cVerNew := BT6->BT6_VERSAO
							Else
								dbSelectarea("BT6")
								BT6->( dbSetorder(01) )
								BT6->( MsSeek(xFilial("BT6")+M->(BQQ_CODINT+BQQ_EMPDES+BQQ_CONDES+BQQ_VCODES+BQQ_SUBDES+BQQ_VRSDES+BQQ_CODPRO+BQQ_VRSPRO)) )
								cProNew := BT6->BT6_CODPRO
								cVerNew := BT6->BT6_VERSAO
							Endif
						Endif
					Else
						If Empty(M->BQQ_CODPRO)
							dbSelectarea("BT6")
							BT6->( dbSetorder(01) )
							BT6->( MsSeek(xFilial("BT6")+M->(BQQ_CODINT+BQQ_EMPDES+BQQ_CONDES+BQQ_VCODES+BQQ_SUBDES+BQQ_VRSDES)) )
							cProNew := BT6->BT6_CODPRO
							cVerNew := BT6->BT6_VERSAO
						Else
							dbSelectarea("BT6")
							BT6->( dbSetorder(01) )
							BT6->( MsSeek(xFilial("BT6")+M->(BQQ_CODINT+BQQ_EMPDES+BQQ_CONDES+BQQ_VCODES+BQQ_SUBDES+BQQ_VRSDES+BQQ_CODPRO+BQQ_VRSPRO)) )
							cProNew := BT6->BT6_CODPRO
							cVerNew := BT6->BT6_VERSAO
						Endif
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona a forma de cobranca do sub contrato                			 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectarea("BT9")
					BT9->( dbSetorder(01) )
					If !BT9->( MsSeek(xFilial("BT9")+M->(BQQ_CODINT+BQQ_EMPDES+BQQ_CONDES+BQQ_VCODES+BQQ_SUBDES+BQQ_VRSDES+BT6->BT6_CODPRO+BT6->BT6_VERSAO)) )
						cChavCob := (BT6->BT6_CODINT+BT6->BT6_CODPRO+BT6->BT6_VERSAO)
					Else
						cForCob := BT9->BT9_CODFOR
					Endif

				Elseif !lJuriDes .or. !Empty(M->BQQ_CODPRO)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona o  produto da pessoa fisica ou se informado um prod. para PJ.  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(M->BQQ_CODPRO)
						dbSelectarea("BI3")
						BI3->( dbSetorder(01) )
						BI3->( MsSeek(xFilial("BI3")+M->(BQQ_CODINT+BQQ_CODPRO+BQQ_VRSPRO)))
					Else
						BA3->( dbSetorder(01) )
						BA3->( MsSeek(xFilial("BA3")+TRB169->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)) )
						dbSelectarea("BI3")
						BI3->( dbSetorder(01) )
						BI3->( MsSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)) )
					Endif					
					cChavCob := BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)
					// Atualiza a forma de cobrança
					BJ3->(DbSelectArea("BJ3"))
					BJ3->(DbSetOrder(1))
					If BJ3->(DbSeek(xFilial("BJ3")+cChavCob))
						cForCob := BJ3->BJ3_CODFOR
					EndIf

				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cria nova familia... no novo subcontrato....                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectarea("BTS")
				BTS->( dbSetorder(01) )
				BTS->( MsSeek(xFilial("BTS")+TRB169->BA1_MATVID) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Armazena informacoes da familia de origem...                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aXConteudo:= {}
				For nCnt := 1 To BA3->( fCount() )
					Aadd( aXconteudo, BA3->(FieldGet(nCnt)) )
				Next

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Marca usuario na matriz de usuarios transferidos...                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aUsrFam) > 0
					nUsrFam := Ascan(aUsrFam, {|x| x[1] == TRB169->BA1_TIPREG})
					If nUsrFam > 0
						aUsrFam[nUsrFam, 3] := .T.
					Endif
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cria nova familia... no novo subcontrato....                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectarea("BA3")
				BA3->( dbSetorder(01) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se a familia ja existe...                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !BA3->( MsSeek(xFilial("BA3")+M->(BQQ_CODINT+BQQ_EMPDES+cMatricula)))
					lNewFam := .T.
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Processa transferencia da familia...                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RecLock("BA3",.T.)
					For nCnt := 1 To BA3->( fCount() )
						cCampo    := BA3->( Field(nCnt) )
						xConteudo := BA3->( FieldGet(nCnt) )
						If     cCampo == "BA3_LOTTRA"
							If BQQ->( FieldPos("BQQ_LOTTRA") ) > 0
								BA3->( FieldPut(nCnt, M->BQQ_LOTTRA) )
							Endif
						Elseif cCampo == "BA3_CODEMP"
							BA3->( FieldPut(nCnt, M->BQQ_EMPDES) )
						Elseif cCampo == "BA3_CONEMP"
							If lJuriDes
								BA3->( FieldPut(nCnt, M->BQQ_CONDES) )
							Endif
						Elseif cCampo == "BA3_VERCON"
							If lJuriDes
								BA3->( FieldPut(nCnt, M->BQQ_VCODES) )
							Endif
						Elseif cCampo == "BA3_SUBCON"
							If lJuriDes
								BA3->( FieldPut(nCnt, M->BQQ_SUBDES) )
							Endif
						Elseif cCampo == "BA3_VERSUB"
							If lJuriDes
								BA3->( FieldPut(nCnt, M->BQQ_VRSDES) )
							Endif
						Elseif cCampo == "BA3_DATTRA"
							BA3->( FieldPut(nCnt, DATE()) )
						Elseif cCampo == "BA3_DATCON"
							If BQQ->(FieldPos("BQQ_INCORI")) > 0
								If  M->BQQ_INCORI == '0'  // nao mantem a data de inclusao
									If lJuriOri
										BA3->( FieldPut(nCnt, dOldData) )
									Else
										BA3->( FieldPut(nCnt, M->BQQ_DATINC) )
									Endif
								Else
									BA3->( FieldPut(nCnt, aXConteudo[nCnt] ) )
								Endif
							Else
								If lJuriOri
									BA3->( FieldPut(nCnt, dOldData) )
								Else
									BA3->( FieldPut(nCnt, M->BQQ_DATINC) )
								Endif
							Endif
						Elseif cCampo $ "BA3_DATBAS,BA3_DATCIV"
							If BQQ->(FieldPos("BQQ_INCORI")) > 0
								If M->BQQ_INCORI == '0'  // nao mantem a data de inclusao
									BA3->( FieldPut(nCnt,M->BQQ_DATINC) )
								Else // mantem a mesma data de inclusao
									BA3->( FieldPut(nCnt, aXConteudo[nCnt] ) )
								Endif
							Else
								If cCampo == "BA3_DATBAS"
									BA3->( FieldPut(nCnt, Iif(lJuriOri,dOldData,M->BQQ_DATINC) ) )
								Else
									BA3->( FieldPut(nCnt,M->BQQ_DATINC) )
								Endif
							Endif
						Elseif cCampo == "BA3_TIPCON"
							BA3->( FieldPut(nCnt, Iif(lJuriDes,BT5->BT5_TIPCON,GetNewPar("MV_PLSTIPC","1"))) )
						Elseif cCampo == "BA3_TIPOUS"
							BA3->( FieldPut(nCnt, Iif((lJuriDes),"2","1")) )
						Elseif cCampo == "BA3_MATFMB"
							BA3->( FieldPut(nCnt, '') )
						Elseif cCampo == "BA3_MATANT"
							If lTransfCartAnt
								BA3->( FieldPut(nCnt, "") )
							Else
								BA3->( FieldPut(nCnt, cBA3MatAnt) )
							Endif
						Elseif cCampo == "BA3_MATRIC"
							BA3->( FieldPut(nCnt, cMatricula) )
						Elseif cCampo == "BA3_TRAORI"
							BA3->( FieldPut(nCnt, StrTran(cOldMat, '.','')) )
						Elseif cCampo == "BA3_CODPLA"
							If lJuriDes
								BA3->( FieldPut(nCnt, cProNew) )
							Else
								BA3->( FieldPut(nCnt, BI3->BI3_CODIGO) )
							Endif
						Elseif cCampo == "BA3_VERSAO"
							If lJuriDes
								BA3->( FieldPut(nCnt, cVerNew) )
							Else
								BA3->( FieldPut(nCnt, BI3->BI3_VERSAO) )
							Endif
						Elseif cCampo == "BA3_FORPAG"
							BA3->( FieldPut(nCnt,Iif(Empty(cForCob), aXConteudo[nCnt], cForCob) ) )
						Elseif cCampo == "BA3_SEGPLA"
							BA3->( FieldPut(nCnt, Iif(lJuriDes ,BT6->BT6_CODSEG,BI3->BI3_CODSEG)) )
						Elseif cCampo == "BA3_DESSEG"
							BA3->( FieldPut(nCnt, Iif(lJuriDes ,BT6->BT6_DESSEG,BI3->BI3_DESSEG)) )
						Elseif cCampo == "BA3_MODPAG"
							BA3->( FieldPut(nCnt, Iif(lJuriDes ,BT6->BT6_MODPAG,BI3->BI3_MODPAG)) )
						Elseif cCampo == "BA3_APLEI"
							BA3->( FieldPut(nCnt, Iif(lJuriDes ,BT6->BT6_APOSRG,BI3->BI3_APOSRG)) )
						Elseif cCampo == "BA3_ABRANG"
							BA3->( FieldPut(nCnt, Iif(lJuriDes ,BT6->BT6_ABRANG,BI3->BI3_ABRANG)) )
						Elseif cCampo == "BA3_DESABR"
							BA3->( FieldPut(nCnt, Iif(lJuriDes ,Posicione("BF7",1,xFilial("BF7")+BT6->BT6_ABRANG,"BF7_DESORI"),Posicione("BF7",1,xFilial("BF7")+BI3->BI3_ABRANG,"BF7_DESORI"))) )
						Elseif cCampo == "BA3_CODACO"
							BA3->( FieldPut(nCnt, Iif(lJuriDes ,BT6->BT6_CODACO,BI3->BI3_CODACO)) )
						Elseif cCampo == "BA3_GRPCOB"
							If BQQ->( FieldPos("BQQ_GRPCOB") ) > 0
								BA3->( FieldPut( nCnt, Iif(!Empty(M->BQQ_GRPCOB), M->BQQ_GRPCOB, aXConteudo[nCnt]) ) )
							Endif
						ElseIf cCampo == "BA3_CODCLI"
							BA3->( FieldPut(nCnt, cCodCli) )
						ElseIf cCampo == "BA3_LOJA"
							BA3->( FieldPut(nCnt, cCodLoj) )
						ElseIf cCampo == "BA3_VENCTO"
							BA3->( FieldPut(nCnt, nVencto) )
						ElseIf cCampo == "BA3_COBNIV"
							BA3->( FieldPut(nCnt, cCobNiv) )
						ElseIf cCampo == "BA3_NATURE"
							BA3->( FieldPut(nCnt, cNature) )
						ElseIf cCampo == "BA3_ROTINA"
							BA3->BA3_ROTINA := BJ0->(Posicione("BJ0",1,xFilial("BJ0")+cForCob,"BJ0_ROTINA"))
						ElseIf cCampo == "BA3_GRPFAM" .AND. M->BQQ_MOTTRA = "01" //Grava grupo familiar quando esta desmembrando a familia
							BA3->( FieldPut(nCnt, cGrpFam ) )
						ElseIf cCampo == "BA3_MOTBLO"
							BA3->( FieldPut(nCnt, "") )
						ElseIf BQQ->(fieldPos('BQQ_CODRAS')) > 0 .AND. cCampo == "BA3_CODRAS"
							BA3->( FieldPut(nCnt, cCodRas) )
						//na transferência da familia, o tipo de rastreio sempre deverá ser do tipo Vincular código
						ElseIf BQQ->(fieldPos('BQQ_CODRAS')) > 0 .AND. cCampo == "BA3_TIPVIN"
							BA3->( FieldPut(nCnt, '0') )
						// Caso o titular tenha sido alterado, o valor do salario da familia pode ter sido alterado (PLSA169SAL)
						ElseIf cCampo == "BA3_VALSAL" .AND. !Empty(aDadFam) .AND. M->BQQ_TODOS == "0"
							BA3->( FieldPut(nCnt, aDadFam[1,2]) ) // Posição correspondente ao novo valor do salario	
						Else 
							BA3->( FieldPut(nCnt, aXConteudo[nCnt] ) )
						Endif
					Next
					BA3->( MsUnlock() )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava o numero do registro da nova familia...                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nRecNewFam := BA3->( Recno() )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Transfere as formas de cobranca cobranca da mensalidade...               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PL169FOR(StrTran(cNewMat, '.', ''), lJuriDes, lJuriOri, .F.,cOldMat,cOldUsr)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Transfere as formas de cobranca cobranca da taxa de adesao...            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PL169TXA(StrTran(cNewMat, '.', ''), lJuriDes, lJuriOri,cOldMat,cOldUsr)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ leva opcionais e suas formas de cobranca para a familia...               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PL169OPC(StrTran(cNewMat, '.', ''), lJuriDes, lJuriOri,.T.,cOldMat,cOldUsr)
				Else

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava o numero do registro da nova familia...                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nRecNewFam := BA3->( Recno() )
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Reposiciona o BA3 na nova familia gerada...                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BA3->( dbGoto(nRecNewFam) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Usa a funcao de calculo de idade para cacular o tempo de plano do usuario³
				//| neste caso usuarios com mais de 5 anos de plano nao cumpre CPT           |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTmpPlano 	:= Calc_Idade(M->BQQ_DATINC, TRB169->BA1_DATINC)
				cBA1MatAnt	:= TRB169->BA1_MATANT
				cOldUsr		:= TRB169->( BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Processa a Transferencia dos usuarios...                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nFcount 	:= BA1->( fCount() )  // Desconsiderar R_E_C_N_O_  e o D_E_L_E_T_
				If Len(aCritica) > 0
					nTpRg := Ascan(aCritica, {|x| x[2] == TRB169->BA1_TIPREG})
				Else
					nTpRg := 0
				EndIf

				// Verifica na transferecia se ja existe um titular no destino caso não tenha se a origem não for titular esse transforma em titular.
				If TRB169->BA1_TIPREG <> __cTipoRegTit
					cChvPesBA1 := xFilial("BA1")+PlsIntPad()+ M->BQQ_EMPDES
					If BA1->(MsSeek(cChvPesBA1))
						While !BA1->(Eof()) .and. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP) == cChvPesBA1
							If BA1->BA1_TIPREG == __cTipoRegTit
								lExistTitul :=.T.
								//Guardando o matricula do titular para popular o campo B3K_CODTIT
								cCodNewTit	:= BA1->( BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO )
								Exit
							Endif
							BA1->(DbsKip())
						Enddo
					Endif
				Endif

				RecLock("BA1",.T.)
				For nCnt := 1 To nFcount
					cCampo := BA1->( Field(nCnt) )
					nPos   := TRB169->( FieldPos( cCampo ) )
					cConte := TRB169->( FieldGet(nPos) )
					If     cCampo == "BA1_LOTTRA"
						If BQQ->( FieldPos("BQQ_LOTTRA") ) > 0
							BA1->( FieldPut(nCnt, M->BQQ_LOTTRA) )
						Endif
					Elseif cCampo == "BA1_CODEMP"
						BA1->( FieldPut(nCnt, M->BQQ_EMPDES) )
					Elseif cCampo == "BA1_CONEMP"
						If lJuriDes
							BA1->( FieldPut(nCnt, M->BQQ_CONDES) )
						Endif
					Elseif cCampo == "BA1_VERCON"
						If lJuriDes
							BA1->( FieldPut(nCnt, M->BQQ_VCODES) )
						Endif
					Elseif cCampo == "BA1_SUBCON"
						If lJuriDes
							BA1->( FieldPut(nCnt, M->BQQ_SUBDES) )
						Endif
					Elseif cCampo == "BA1_VERSUB"
						If lJuriDes
							BA1->( FieldPut(nCnt, M->BQQ_VRSDES) )
						Endif
					Elseif cCampo == "BA1_DATINC"
						If BQQ->( FieldPos("BQQ_INCORI") ) > 0
							If M->BQQ_INCORI == '0'
								BA1->( FieldPut(nCnt, M->BQQ_DATINC) )
							Else
								BA1->( FieldPut(nCnt, cConte) )
							Endif
						Else
							BA1->( FieldPut(nCnt, M->BQQ_DATINC) )
						Endif
					Elseif cCampo == "BA1_TIPINC"

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Trata o campo tipo de inclusao do usuario...                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(M->BQQ_CODPRO)
							nRegBI3 := BI3->( Recno() )
							cTipPla := BI3->BI3_APOSRG
							If BI3->( MsSeek(xFilial("BI3")+BA3->BA3_CODINT+cProAnt+cVerAnt) )
								If (cTipPla == '1' .and. BI3->BI3_APOSRG == '0') .or. (cTipPla == '0' .and. BI3->BI3_APOSRG == '1')
									BA1->( FieldPut(nCnt, '5') )
								Else
									BA1->( FieldPut(nCnt, '4') )
								Endif
							Endif
							BI3->( dbGoto(nRegBI3) )
						Else
							If lJuriOri .and. Empty(M->BQQ_CODPRO)
								nRegBI3 := BI3->( Recno() )
								cTipPla := BT6->BT6_APOSRG
								If BI3->( MsSeek(xFilial("BI3")+BA3->BA3_CODINT+cProAnt+cVerAnt) )
									If (cTipPla == '1' .and. BI3->BI3_APOSRG == '0') .or. (cTipPla == '0' .and. BI3->BI3_APOSRG == '1')
										BA1->( FieldPut(nCnt, '5') )
									Else
										BA1->( FieldPut(nCnt, '4') )
									Endif
								Endif
								BI3->( dbGoto(nRegBI3) )
							Else
								BA1->( FieldPut(nCnt, '4') )
							Endif
						Endif

					Elseif cCampo == "BA1_TIPREG"
						If cModelo == "1"
							If nTpRg > 0
								// Grava os campos relacionados...  
								cGrauPa := IIF(nTpRg == 2 .And. aCritica[nTpRg, 3] == __cTipoUsoTit, __cGrauParTit , aCritica[nTpRg, 6] )
								BA1->BA1_GRAUPA := cGrauPa
								cTipUsu := aCritica[nTpRg, 3]
								BA1->BA1_TIPUSU := cTipUsu
								IF BA1->BA1_TIPUSU == __cTipoUsoTit 
									BT2->(DBSETORDER(1))//BT2_FILIA+BT2_CODDEP+BT2_SEQDE
									BT2->(MsSeek(XFILIAL("BT2") + __cGrauParTit))  
									cTipReg := BT2->BT2_SEQDE
								ELSE
									cTipReg := PL169TipRg(cGrauPa, aCritica[nTpRg, 2], BA1->BA1_TIPUSU, M->BQQ_CODINT+M->BQQ_EMPDES+cMatricula)[1]
								ENDIF
							Else
								cTipReg := cConte
							EndIf

						Else

							If nTpRg > 0
								// Grava os campos relacionados...
								cGrauPa := aCritica[nTpRg, 6]
								BA1->BA1_GRAUPA := cGrauPa
								cTipUsu := aCritica[nTpRg, 3]
								BA1->BA1_TIPUSU := cTipUsu
								IF BA1->BA1_TIPUSU == __cTipoUsoTit
									BF2->(DBSETORDER(1))//BF2_FILIA+BF2_GRAUPA+BF2_SEQDE
									BF2->(DBSEEK(XFILIAL() + __cTipoUsoTit))
									cTipReg := BF2->BF2_SEQDE
								ELSE
									cTipReg := PL169TipRg(cGrauPa, aCritica[nTpRg, 2], BA1->BA1_TIPUSU, M->BQQ_CODINT+M->BQQ_EMPDES+cMatricula)[1]
								ENDIF
							Else
								cTipReg := cConte
							EndIf
						EndIf
						
						BA1->BA1_TIPREG := cTipReg

						// Calcula o digito verificador
						BA1->BA1_DIGITO := cDigito := IIF(FindFunction("StrTPLS"),Modulo11(StrTPLS(M->BQQ_CODINT+M->BQQ_EMPDES+cMatricula+BA1->BA1_TIPREG)),Modulo11(M->BQQ_CODINT+M->BQQ_EMPDES+cMatricula+BA1->BA1_TIPREG))

					Elseif cCampo == "BA1_DIGITO"
						BA1->( FieldPut(nCnt, BA1->BA1_DIGITO) )

					Elseif cCampo $ "BA1_TIPUSU"
						//	Gravado junto com o BA1_TIPREG 
						If ((TRB169->BA1_GRAUPA == __cGrauParTit .and. Empty(M->BQQ_FAMDES)) .or. !lExistTitul) .and. nTpRg < 0  // Novo Titular
							BA1->( FieldPut(nCnt, "T") )
						ElseIf nTpRg > 0
							BA1->( FieldPut(nCnt, aCritica[nTpRg, 3]) )
						ElseIf !Empty(M->BQQ_FAMDES) // Transferencias entre familias, nao grava nada. Ver BA1_TIPREG
							BA1->( FieldPut(nCnt, BA1->BA1_TIPUSU) )
						Else
							BA1->( FieldPut(nCnt, cConte) )
						EndIf
						
					Elseif cCampo == "BA1_GRAUPA"
						//	Gravado junto com o BA1_TIPREG 
						If  TRB169->BA1_GRAUPA == __cGrauParTit .and. Empty(M->BQQ_FAMDES) .and. nTpRg < 0 // Novo Titular
							BA1->( FieldPut(nCnt, __cGrauParTit) )
						ElseIf nTpRg > 0
							BA1->( FieldPut(nCnt, aCritica[nTpRg, 6]) )
						ElseIf !Empty(M->BQQ_FAMDES) // Transferencias entre familias, nao grava nada. Ver BA1_TIPREG
							BA1->( FieldPut(nCnt, BA1->BA1_GRAUPA) ) 
						Else
							BA1->( FieldPut(nCnt, cConte) )
						EndIf
						
					Elseif cCampo == "BA1_DATTRA"
						BA1->( FieldPut(nCnt, Date()) )

					Elseif cCampo == "BA1_MATRIC"
						BA1->( FieldPut(nCnt, cMatricula) )
		
					Elseif cCampo == "BA1_MATANT"
						If lTransfCartAnt
							BA1->( FieldPut(nCnt,  "") )
						Else
							BA1->( FieldPut(nCnt,  cBA1MatAnt) )
						Endif
					Elseif cCampo == "BA1_MATUSB"
						BA1->( FieldPut(nCnt, '') )

					Elseif cCampo == "BA1_TRAORI"
						BA1->( FieldPut(nCnt, TRB169->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) ))

					Elseif cCampo == "BA1_DATCAR" .AND. M->BQQ_CARENC == '0'
						BA1->( FieldPut(nCnt, M->BQQ_DATCAR) )

					Elseif cCampo == "BA1_DATCPT"
						If nTmpPlano < 5
							If M->BQQ_CPTORI == '0'
								BTS->( RecLock("BTS") )
								BTS->BTS_DATCPT := TRB169->BA1_DATCPT
								BTS->( MsUnlock() )
								BA1->( FieldPut(nCnt, Ctod("")) )
							Else
								If Empty(TRB169->BA1_DATCPT)
									If !Empty(BTS->BTS_DATCPT)
										BA1->( FieldPut(nCnt, BTS->BTS_DATCPT) )
									Endif
								Else
									BA1->( FieldPut(nCnt, cConte) )
								Endif
							Endif
						Endif

					Elseif cCampo == "BA1_CODPLA"	// Leva para o usuario,
						If BQQ->( FieldPos("BQQ_PROORI") ) > 0 .and. M->BQQ_PROORI == '1'
							BA1->( FieldPut(nCnt, cConte) )
						Else
							nTpRg := Ascan(aCritica, {|x| x[2] == TRB169->BA1_TIPREG})
							If nTpRg == 0
								If !Empty(cConte) // Faz o que ja fazia...
									BA1->( FieldPut(nCnt, Iif(lJuriDes, BT6->BT6_CODPRO, BI3->BI3_CODIGO)) )
								Endif
							Else
								If Empty(aCritica[nTpRg, 7])
									If !Empty(cConte) // Faz o que ja fazia...
										BA1->( FieldPut(nCnt, Iif(lJuriDes, BT6->BT6_CODPRO, BI3->BI3_CODIGO)) )
									Endif
								Else
									BA1->( FieldPut(nCnt, aCritica[nTpRg, 7]) )
								Endif
							Endif
						Endif

					Elseif cCampo $ "BA1_DATBLO, BA1_MOTBLO"
						// Nao faz nada, apenas para nao levar o usuario ja bloqueado.

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Para tratamento da emissao de carteirinha "1" informa que e alteracao	       ³
						//³ BA1_EMICAR = 0=Nunca Emitir;1=Cad. Alterado;2=Cartao Preparado;3=Cartao Gerado ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Elseif cCampo == "BA1_EMICAR"
						If GetNewPar("MV_PLSEMIC","0") == "1"
							BA1->( FieldPut(nCnt, "1") )
						EndIf
					Elseif cCampo == "BA1_VIACAR"
						If GetNewPar("MV_PLSVIAC",.F.) // indica se devera reiniciar a numeracao da via do cartao quando houver transferencia do usuario
							BA1->( FieldPut(nCnt, 0) )
						Else
							BA1->( FieldPut(nCnt, cConte) )
						EndIf
					Elseif cCampo == "BA1_VERSAO"
						If BQQ->( FieldPos("BQQ_PROORI") ) > 0 .and. M->BQQ_PROORI == '1'
							If !Empty(cConte) // Apenas se o usuario conter plano na origem.
								BA1->( FieldPut(nCnt, Iif(lJuriDes, BT6->BT6_VERSAO, BI3->BI3_VERSAO)) )
							Endif
						Else
							nTpRg := Ascan(aCritica, {|x| x[2] == TRB169->BA1_TIPREG})
							If nTpRg == 0
								If !Empty(cConte) // Faz o que ja fazia...
									BA1->( FieldPut(nCnt, Iif(lJuriDes, BT6->BT6_VERSAO, BI3->BI3_VERSAO)) )
								Endif
							Else
								If Empty(aCritica[nTpRg, 7])
									If !Empty(cConte) // Faz o que ja fazia...
										BA1->( FieldPut(nCnt, Iif(lJuriDes, BT6->BT6_VERSAO, BI3->BI3_VERSAO)) )
									Endif
								Else
									BA1->( FieldPut(nCnt, aCritica[nTpRg, 8]) )
								Endif
							Endif
						Endif

					Elseif BQQ->( FieldPos("BQQ_MOTTRA") ) > 0 .and.;
							BA1->( FieldPos("BA1_MOTTRA") ) > 0 .and. cCampo == "BA1_MOTTRA"
						BA1->( FieldPut(nCnt, M->BQQ_MOTTRA) )

					Elseif BQQ->( FieldPos("BQQ_PLPOR") ) > 0 .and.;
							BA3->BA3_TIPOUS = '1' .AND.;
							BA1->( FieldPos("BA1_PLPOR") ) > 0 .and.;
							M->BQQ_MOTTRA = "43" .and. cCampo == "BA1_PLPOR"
						BA1->( FieldPut(nCnt, IIf(!Empty(M->BQQ_PLPOR),M->BQQ_PLPOR,strzero(val(BI3->BI3_SUSEP),9))) )

					Elseif BA1->( FieldPos("BA1_LOCSIB") ) > 0 .and. cCampo == "BA1_LOCSIB"
						A169Ans(nCnt,cConte,'0')

					Elseif BA1->( FieldPos("BA1_ENVANS") ) > 0 .and. cCampo == "BA1_ENVANS"
						A169Ans(nCnt,cConte,cTod(' '))

					Elseif BA1->( FieldPos("BA1_INCANS") ) > 0 .and. cCampo == "BA1_INCANS"
						A169Ans(nCnt,cConte,cTod(' '))

					Elseif BA1->( FieldPos("BA1_EXCANS") ) > 0 .and. cCampo == "BA1_EXCANS"
						A169Ans(nCnt,cConte,cTod(' '))

					Elseif BA1->( FieldPos("BA1_TRADES") ) > 0 .and. cCampo == "BA1_TRADES"
						BA1->( FieldPut(nCnt, ' ') )

					Elseif BA1->( FieldPos("BA1_CODCCO") ) > 0 .and. cCampo == "BA1_CODCCO"
						A169Ans(nCnt,cConte,' ')

					Else
						BA1->( FieldPut(nCnt, cConte) )
					Endif
				Next
				BA1->( MsUnlock() )
  

				//verifica se uma nova BA3 foi criada e se o usuario é o titular e se gera um novo cliente para familia nova ou mantem o da familia origem
				if lNewFam .and. BA1->BA1_TIPUSU == __cTipoUsoTit .and. GetNewPar("MV_PLCPCLI", "0") == "1"
						
					aDadCli := PLSCL(BA1->(Recno()))
					
					if len(aDadCli) > 0
					
						BA3->(RecLock("BA3",.F.))
							BA3->BA3_CODCLI := aDadCli[1]
							BA3->BA3_LOJA := aDadCli[2]
						BA3->(MsUnlock())
					
					endIf
					
				endIf

				Aadd(aMatHAT, { M->BQQ_CODINT+M->BQQ_EMPDES+cMatricula+BA1->BA1_TIPREG+BA1->BA1_DIGITO, BA1->BA1_NOMUSR })
							
				If mv_par01 = 1
					Aadd(aDigitos, { M->BQQ_CODINT+M->BQQ_EMPDES+cMatricula+BA1->BA1_TIPREG+BA1->BA1_DIGITO, BA1->BA1_NOMUSR })
				Endif
				nRecNewBen := BA1->(Recno())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Define a chave global para pesquisa nas tabelas filhas...                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cGlobalKey := M->(BQQ_CODINT+BQQ_EMPORI)+TRB169->BA1_MATRIC+TRB169->BA1_TIPREG

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Transfere as PRE-Existencias - BF3...                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BF3->( dbSetorder(01) )
				If BF3->(MsSeek(xFilial("BF3")+cGlobalKey))
					While !BF3->( Eof() ) .and. BF3->BF3_CODINT+BF3->BF3_CODEMP+BF3->BF3_MATRIC+BF3->BF3_TIPREG == cGlobalKey
						aConteudo 	:= {}
						nRegBF3 	:= BF3->( RecNo() )

						For nCnt := 1 To BF3->( fCount() )
							Aadd(aConteudo, BF3->( FieldGet(nCnt) ))
						Next

						RecLock("BF3", .T.)
						For nCnt := 1 To BF3->( fCount() )
							cField 	:= BF3->( Field(nCnt) )
							If cField == "BF3_CODEMP"
								BF3->( FieldPut(nCnt, M->BQQ_EMPDES) )

							Elseif cField == "BF3_MATRIC"
								BF3->( FieldPut(nCnt, cMatricula) )

							Elseif cField == "BF3_TIPREG"
								BF3->( FieldPut(nCnt, BA1->BA1_TIPREG) )

							Else
								BF3->( FieldPut(nCnt, aConteudo[nCnt]) )
							Endif
						Next
						BF3->( msUnlock() )
						BF3->( dbGoto(nRegBF3) )
						BF3->( dbSkip() )
					Enddo
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Transfere Documentos Obrigatórios - B...                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PL169DOCOBR(cGlobalKey, cMatricula, BA1->BA1_TIPREG)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carencia diferenciada para procedimentos - BYY...                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BYY->( dbSetorder(01) )
				If BYY->(MsSeek(xFilial("BYY")+cGlobalKey))
					While !BYY->( Eof() ) .and. BYY->BYY_CODINT+BYY->BYY_CODEMP+BYY->BYY_MATRIC+BYY->BYY_TIPREG == cGlobalKey
						aConteudo 	:= {}
						nRegBYY 	:= BYY->( RecNo() )

						For nCnt := 1 To BYY->( fCount() )
							Aadd(aConteudo, BYY->( FieldGet(nCnt) ))
						Next

						RecLock("BYY", .T.)
						For nCnt := 1 To BYY->( fCount() )
							cField 	:= BYY->( Field(nCnt) )

							If cField == "BYY_CODEMP"
								BYY->( FieldPut(nCnt, M->BQQ_EMPDES) )

							Elseif cField == "BYY_MATRIC"
								BYY->( FieldPut(nCnt, cMatricula) )

							Elseif cField == "BYY_TIPREG"
								BYY->( FieldPut(nCnt, BA1->BA1_TIPREG) )

							Else
								BYY->( FieldPut(nCnt, aConteudo[nCnt]) )
							Endif
						Next
						BYY->( msUnlock() )
						BYY->( dbGoto(nRegBYY) )
						BYY->( dbSkip() )
					Enddo
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Transfere as Situacoes Adversas - BHH...                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BHH->( dbSetorder(01) )
				If BHH->(MsSeek(xFilial("BHH")+cGlobalKey))
					While !BHH->( Eof() ) .and. BHH->BHH_CODINT+BHH->BHH_CODEMP+BHH->BHH_MATRIC+BHH->BHH_TIPREG == cGlobalKey
						aConteudo 	:= {}
						nRegBHH 	:= BHH->( RecNo() )

						For nCnt := 1 To BHH->( fCount() )
							Aadd(aConteudo, BHH->( FieldGet(nCnt) ))
						Next

						RecLock("BHH", .T.)
						For nCnt := 1 To BHH->( fCount() )
							cField 	:= BHH->( Field(nCnt) )
							If cField == "BHH_CODEMP"
								BHH->( FieldPut(nCnt, M->BQQ_EMPDES) )

							Elseif cField == "BHH_MATRIC"
								BHH->( FieldPut(nCnt, cMatricula) )

							Elseif cField == "BHH_TIPREG"
								BHH->( FieldPut(nCnt, BA1->BA1_TIPREG) )

							Else
								BHH->( FieldPut(nCnt, aConteudo[nCnt]) )
							Endif
						Next
						BHH->( msUnlock() )
						BHH->( dbGoto(nRegBHH) )
						BHH->( dbSkip() )
					Enddo
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Transfere o saldo anterior do usuario para a nova matricula              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If PLSALIASEX("BK2") .And. ;
						BK2->(FieldPos("BK2_CODINT")) > 0 .And. BK2->(FieldPos("BK2_CODEMP")) > 0 .And. ;
						BK2->(FieldPos("BK2_MATRIC")) > 0 .And. BK2->(FieldPos("BK2_TIPREG")) > 0 .And. ;
						BK2->(FieldPos("BK2_DIGITO")) > 0 .And. SIX->(MsSeek("BDF9")) .And. ;
						SIX->(MsSeek("BDF8")) 			  .And. SIX->(MsSeek("BDFA")) .And. ;
						SIX->(MsSeek("BDFB")) 			  .And. SIX->(MsSeek("BDFC")) .And. ;
						BK2->(FieldPos("BK2_MOTFEC")) > 0

					BA1->(dbGoto(TRB169->R_E_C_N_O_))

					cAno := subs(dtos(dDataBase),1,4)
					cMes := subs(dtos(dDataBase),5,2)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Obtem o nivel de cobranca e o cliente...		                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Len(aCliente) == 0
						aCliente := PLS770NIV(BA1->BA1_CODINT,BA1->BA1_CODEMP,;
							BA1->BA1_MATRIC,If(BA3->BA3_TIPOUS=="1","F","J"),;
							BA1->BA1_CONEMP,BA1->BA1_VERCON,BA1->BA1_SUBCON,;
							BA1->BA1_VERSUB,1)
					Endif

					If Len(aCliente) > 0

						_cNivel := aCliente[1, 18]
						If     _cNivel == "1" // Empresa
							_cChave := BA1->BA1_CODINT+BA1->BA1_CODEMP

						Elseif _cNivel == "2" //Nivel contrato
							_cChave := BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_CONEMP+BA1->BA1_VERCON

						Elseif _cNivel == "3"  //Nivel subcontrato
							_cChave := BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_CONEMP+BA1->BA1_VERCON+BA1->BA1_SUBCON+BA1->BA1_VERSUB

						Elseif _cNivel == "4" //Nivel familia
							_cChave := BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC

						Elseif _cNivel == "5" //Usuario
							// encontrar uma chave para o usuario...

						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se houve cobranca no mes... 							    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						BDF->(DbSetOrder(Val(_cNivel)+7))
						If !BDF->(MsSeek(xFilial("BDF")+_cNivel+_cChave+cAno+cMes))//se ja nao gerou cobranca no mes
							cAnoMesAnt := PLSDIMAM(cAno,cMes,"0")
							cAno       := subs(cAnoMesAnt,1,4)
							cMes       := subs(cAnoMesAnt,5,2)
						Endif
					Endif

					cSQL := "SELECT * FROM " + RetSqlName("BK2") + " "
					cSQL +=  "WHERE BK2_FILIAL = '"+xFilial("BK2")+"' AND "
					cSQL +=    "BK2_CODINT = '" + BA1->BA1_CODINT + "' AND "
					cSQL +=    "BK2_CODEMP = '" + BA1->BA1_CODEMP + "' AND "
					cSQL +=    "BK2_MATRIC = '" + BA1->BA1_MATRIC + "' AND "
					cSQL +=    "BK2_TIPREG = '" + BA1->BA1_TIPREG + "' AND "
					cSQL +=    "BK2_DIGITO = '" + BA1->BA1_DIGITO + "' AND "
					cSQL +=    "BK2_ANO    = '" + cAno + "' AND "
					cSQL +=    "BK2_MES    = '" + cMes + "' AND "
					cSQL +=   "(BK2_SALDO  > 0 OR BK2_SALDO2 > 0) AND "
					cSQL +=    "D_E_L_E_T_ = ' '"
					PlsQuery(cSQL,"TrbBK2")

					While !TrbBK2->(Eof())
						//CRIO O NOVO BK2
						BK2->(RecLock("BK2",.T.))
						BK2->BK2_FILIAL := xFilial("BK2")
						BK2->BK2_CODINT := M->BQQ_CODINT
						BK2->BK2_CODEMP := M->BQQ_EMPDES
						BK2->BK2_MATRIC := cMatricula
						BK2->BK2_TIPREG := cTipReg
						BK2->BK2_DIGITO := cDigito
						BK2->BK2_ANO    := TrbBK2->BK2_ANO
						BK2->BK2_MES    := TrbBK2->BK2_MES
						BK2->BK2_SALDO  := TrbBK2->BK2_SALDO
						BK2->BK2_SALDO2 := TrbBK2->BK2_SALDO2
						BK2->BK2_PROPRI := TrbBK2->BK2_PROPRI
						BK2->BK2_CODLAN := TrbBK2->BK2_CODLAN
						BK2->BK2_PLNUCO := TrbBK2->BK2_PLNUCO
						BK2->BK2_PREFIX := TrbBK2->BK2_PREFIX
						BK2->BK2_NUMTIT := TrbBK2->BK2_NUMTIT
						BK2->BK2_TIPTIT := TrbBK2->BK2_TIPTIT
						BK2->BK2_TIPLAN := TrbBK2->BK2_TIPLAN
						BK2->(MsUnLock())

						//ZERO O SALDO DA PASSOA
						BK2->(dbGoto(TrbBK2->R_E_C_N_O_))
						BK2->(RecLock("BK2",.F.))
						BK2->BK2_SALDO  := 0
						BK2->BK2_SALDO2 := 0
						BK2->BK2_MOTFEC := M->BQQ_MOTBLO
						BK2->(MsUnlock())

						TrbBK2->(DbSkip())
					Enddo
					TrbBK2->(DbCloseArea())
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso o usuario tenha um produto espeficio, levo as suas formas de cobranca  |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PL169FOR(StrTran(cNewMat, '.', ''), lJuriDes, lJuriOri,.T.,cOldMat,cOldUsr)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ leva opcionais e suas formas de cobranca para o usuario...               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PL169OPC(StrTran(cNewMat, '.', ''), lJuriDes, lJuriOri,.F.,cOldMat,cOldUsr,cTipReg)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Bloqueia o usuario no contrato anterior...                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BA1->( dbGoto(TRB169->R_E_C_N_O_) )

				aDadosBCA := {}
				lBloqUsr  := .F. 

				// Verifica se o usuário do contrato anterior tem bloqueio futuro
				If !Empty(BA1->BA1_DATBLO) .And. BA1->BA1_DATBLO > dDataBase .And. lBloqFut

					DbSelectArea("BCA")
					BCA->(DbSetOrder(1))
					If DbSeek(xFilial("BCA")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+DtoS(BA1_DATBLO))+"0")

						aAdd(aDadosBCA,BCA->BCA_DATA) 		//[1]
						aAdd(aDadosBCA,BCA->BCA_MOTBLO)		//[2]
						aAdd(aDadosBCA,BCA->BCA_BLOFAT) 	//[3]

					EndIf
					
					// Se tiver realiza o desbloqueio do usuario
					IF !Empty(aDadosBCA)
						cMotDes 	:= GetNewPar("MV_MOTDESB","") // MV_MOTDESB = Motivo do Desbloqueio
						cBloFatDes 	:= Posicione("BG3",1,xFilial("BG3")+cMotDes,"BG3_BLOFAT") 

						PL260BLOUS("BA1", BA1->(Recno()), 4, .T.,cMotDes, aDadosBCA[1], cBloFatDes,,,,,.F.) 
						lBloqUsr := .T. // Ira bloquear o usuario da nova familia com bloqueio futuro
					EndIf

				EndIf

				RecLock("BA1",.F.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ A data do bloqueio nao pode ser menor que a data de inclusao do usuario...³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If M->BQQ_DATEXC < TRB169->BA1_DATINC
					BA1->BA1_DATBLO	:= dDataBase
				Else
					BA1->BA1_DATBLO	:= M->BQQ_DATEXC
				Endif

				BA1->BA1_MOTBLO	:= M->BQQ_MOTBLO
				If BA1->( FieldPos("BA1_BLOFAT") ) > 0
					BA1->BA1_BLOFAT := Posicione("BG3",1,xFilial("BG3")+M->BQQ_MOTBLO,"BG3_BLOFAT")
				Endif
				BA1->BA1_IMAGE	:= "DISABLE"
				BA1->BA1_MATUSB := BA1->BA1_MATANT
				If !lTransfCartAnt
					BA1->BA1_MATANT := ''
				Endif
				// Nivel de bloqueio eh de usuario.
				If BA1->( fieldPos("BA1_CONSID") ) > 0
					BA1->BA1_CONSID := 'U'
				Endif
				If BA1->( FieldPos("BA1_TRADES") ) > 0
					cTraDes := StrTran(cNewMat, '.', '')+cTipReg+cDigito
					BA1->BA1_TRADES := cTraDes
				Endif
				BA1->(MsUnlock())

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava historico de bloqueio do usuarior...                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BCA->(Reclock("BCA",.T.))
				BCA->BCA_FILIAL := xFilial("BCA")
				BCA->BCA_MATRIC := TRB169->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
				BCA->BCA_TIPREG := TRB169->BA1_TIPREG
				BCA->BCA_TIPO   := '0'

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ A data do bloquei nao pode ser menor que a data de inclusao do usuario...³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BCA->BCA_DATA   := IIf(M->BQQ_DATEXC < TRB169->BA1_DATINC, dDatabase, M->BQQ_DATEXC)

				BCA->BCA_MOTBLO := M->BQQ_MOTBLO
				BCA->BCA_NIVBLQ := IIf(M->BQQ_TODOS == '1', 'F', 'U')
				BCA->BCA_USUOPE := PLRETOPE()
				BCA->BCA_BLOFAT := cBloFat
				BCA->BCA_DATLAN	:=DATE()
				BCA->BCA_HORLAN	:=TIME()
				BCA->BCA_MATANT   	:= BA1->BA1_MATANT
				BCA->( MsUnlock() )


				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 		//³ Gera pedido de bloqueio para o HAT                                                        ³
		  		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
				If FWAliasInDic("BNV", .F.) .And. GetNewPar("MV_PLSHAT","0") == "1" 
					cCodTra := _beneficiaryStatus_blo
					BNV->(DbSetOrder(2))//BNV_FILIAL+BNV_CODTRA+BNV_ALIAS+BNV_CHAVE
							
					//Verifico se ja tem desbloqueio nao enviado, se tiver, excluo
	       	 		If !BNV->(MsSeek(xFilial("BNV")+cCodTra+"BCA"+BCA->(BCA_MATRIC+BCA_TIPREG)+Dtos(BCA->BCA_DATA)))
						cChaveHAT := BCA->(BCA_MATRIC+BCA_TIPREG)+Dtos(BCA->BCA_DATA)+BCA->BCA_TIPO
						PLHATPedPD(K_Incluir,_beneficiaryStatus_blo,"BCA",cChaveHAT,NIL,1)	
	        		EndIf	
				EndIf

				cNewUsr := StrTran(cNewMat, '.', '') + cTipReg //+cDigito

				aBDKItens:={}
				aBZXItens:={}
				aBF4Itens:={}
				aBYXItens:={}
				aBCPItens:={}

				//Chamo a rotina genérica que atualiza o Núcleo de Informações da Central de Obrigações
				If lCentralObr .AND. (lUsaSIP .OR.  lUsaSIB)
					nBkpPar01 := mv_par01
					aAreaBA1 := BA1->(GetArea())
					aAreaBA3 := BA3->(GetArea())
					aAreaBTS := BTS->(GetArea())
					lNovoCCO := M->BQQ_CODCCO != "1"	
					lEnviaOpe := lNovoCCO

					If PlSibEnvANS(BA3->BA3_TIPOUS,BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_CONEMP,BA1->BA1_VERCON,;
								BA1->BA1_SUBCON,BA1->BA1_VERSUB,BA1->BA1_INFANS)
								
						BTS->(Dbsetorder(1))
						
						//Vou mandar o bloqueio da família de origem
						BA3->(dbGoto(nBa3Lock))
						BA1->(dbGoto(TRB169->R_E_C_N_O_))
						BTS->(MsSeek(xFilial("BTS")+BA1->BA1_MATVID))
						lMudaCont:= M->BQQ_CODPRO <> BA3->BA3_CODPLA .And. !lNovoCCO
															
						IF lMudaCont .Or. !lNovoCCO       
							dIncAnt := BA1->BA1_DATINC
						Else
							oModel := PlPrDadNio(aDadCob,,.T.,lUsaSIP)
							cB3KMat	:= oModel:GetValue( "B3KMASTER", 'B3K_MATRIC')
							cNomBen	:= oModel:GetValue( "B3KMASTER", 'B3K_NOMBEN')
							aAdd(aCritSib,{cB3KMat,cNomBen,""})

							oModel:SetValue( "B3KMASTER", 'B3K_OPESIB','4')//Envio um bloqueio
							oModel:SetValue( "B3KMASTER", 'B3K_DATBLO',BQQ->BQQ_DATEXC)//Data de inclusao
							oModel:SetValue( "B3KMASTER", 'B3K_MOTBLO',Posicione("BG3",1,xFilial("BG3")+M->BQQ_MOTBLO,"BG3_BLQANS"))//Data de inclusao

							If lNovoCCO
								dIncAnt := BA1->BA1_DATINC
							Else	
								dDatInc	:= BQQ->BQQ_DATINC
							EndIf

							If FindFunction("PLGetHrCentral")
								oModel := PLGetHrCentral(oModel)
							EndIf
							
							If lSIPSincrono .OR. lSIBSincrono 
								oModel:commitData()
							Else
								aAdd(aCmpOriTran,oModel)
								aAdd(aOpcSip,K_Alterar)
								aAdd(aDadCobOri,{})
							EndIf
						EndIf						
						//Vou mandar a matricula nova para que o NIO:
						//- Crie um novo benef na B3K
						//- Se for desmembramento ele envia apenas a mudança de matricula
						BA3->(dbGoto(nRecNewFam))
						BA1->(dbGoto(nRecNewBen))
						oModel := PlPrDadNio(aDadCob,lNovoCCO,.F.,lUsaSIP)
						cB3KMat	:= oModel:GetValue( "B3KMASTER", 'B3K_MATRIC')
						cNomBen	:= oModel:GetValue( "B3KMASTER", 'B3K_NOMBEN')

						//Capturando o codigo de titular para distribuir no B3K_CODTIT
						If oModel:GetValue( "B3KMASTER", 'B3K_TIPDEP') = '01'
							cCodRefTitb3k := cB3KMat
						Endif

						aAdd(aCritSib,{cB3KMat,cNomBen,""})
						If lNovoCCO 
							oModel:GetValue( "B3KMASTER", 'B3K_CODCCO',"")
						EndIf
						
						dDatInc	:= oModel:GetValue( "B3KMASTER", 'B3K_DATINC')
						If lMudaCont .Or. !lNovoCCO
							oModel:SetValue( "B3KMASTER", 'B3K_DATINC',dIncAnt)
						EndIf
						
						// Gravo o codigo do titular para validações na central e para não ocorrer criticas SIBVLDB065
						If oModel:GetValue( "B3KMASTER", 'B3K_TIPDEP') <>'01'
							oModel:SetValue( "B3KMASTER", 'B3K_CODTIT',cCodRefTitb3k)
						Endif
					

						If lSIPSincrono .OR. lSIBSincrono 
							oModel:SetValue( "B3KMASTER", 'B3K_OPESIB',IIf(lNovoCCO,'1','2'))//Envio uma inclusão
							PLCGrvBen( oModel,.F.,aCritSib )
							DelClassInf()
							If lMudaCont
								oModel := PlPrDadNio(aDadCob,.F.,.T.,lUsaSIP)						
								oModel:SetValue( "B3KMASTER", 'B3K_OPESIB','3')//Envio uma mudança contratual

								// Gravo o codigo do titular para validações na central e para não ocorrer criticas SIBVLDB065
								If oModel:GetValue( "B3KMASTER", 'B3K_TIPDEP') <>'01'
									oModel:SetValue( "B3KMASTER", 'B3K_CODTIT',cCodRefTitb3k)
								Endif

								PLCGrvBen( oModel,.F.,aCritSib )
								DelClassInf()					
							EndIf
						Else
							aAdd(aCmpDesTran,oModel)
							aAdd(aOpcSip,K_Alterar)
							aAdd(aDadCobJob,aDadCob)
						EndIf
						
						// Bloqueio o Usuário com data de bloqueio futuro
						If lBloqUsr
							PL260BLOUS("BA1", BA1->(Recno()), 4, .T.,aDadosBCA[2], aDadosBCA[1], aDadosBCA[3],,,,,.F.)
						EndIf

					EndIf

					RestArea(aAreaBA3)
					RestArea(aAreaBA1)
					RestArea(aAreaBTS)
					mv_par01 := nBkpPar01

				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera Usuarios Faixa Etarias
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BDK->(DbSetOrder(1))
				If(BDK->(DbSeek(xFilial("BDK")+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG)))
					aCamposBDK:={}
					aBDKItens :={}
					aStrubdk  := BDK->(dbStruct())
					While !BDK->(Eof()) .and. (xFilial("BDK")+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG = BDK->BDK_FILIAL+BDK->BDK_CODINT+BDK->BDK_CODEMP+BDK->BDK_MATRIC+BDK->BDK_TIPREG)
						For nStru=1 to Len(aStrubdk)
							If     aStrubdk[nStru,1]="BDK_CODINT"
								Aadd(aCamposBDK,{aStrubdk[nStru,1],BQQ->BQQ_CODINT})
							ElseIf aStrubdk[nStru,1]="BDK_CODEMP"
								Aadd(aCamposBDK,{aStrubdk[nStru,1],BQQ->BQQ_EMPDES})
							ElseIf aStrubdk[nStru,1]="BDK_MATRIC"
								Aadd(aCamposBDK,{aStrubdk[nStru,1],cMatricula})
							Else
								Aadd(aCamposBDK,{aStrubdk[nStru,1],BDK->&(aStrubdk[nStru,1])})
							Endif
						Next
						Aadd(aBDKItens,aCamposBDK)
						aCamposBDK:={}
						BDK->(Dbskip())
					Enddo
					For nIt:=1 to Len(aBDKItens)
						RecLock("BDK",.T.)
						For nStru := 1 To Len(aBDKItens[nIt])
							FieldPut(FieldPos(Trim(aBDKItens[nIt,nStru,1])),aBDKItens[nIt,nStru,2])
						Next
						MsUnlock()
					Next
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chama ponto de entrada logo apos a gravacao de todas as tabelas...       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lPl169Grv
					ExecBlock("PL169GRV",.f.,.f.,{cOldMat,cNewMat,cOldUsr,cNewUsr})
				Endif
				
				//Caso a transfêrencia seja realizada para uma familia já existente
				//É necessário garantir a atualização dos campos
				If BQQ->(fieldPos('BQQ_CODRAS')) > 0 .and. BA3->(fieldPos('BA3_CODRAS')) 
					If Empty(BA3->BA3_CODRAS)
						RecLock("BA3",.F.) 	
				    	  BA3->BA3_CODRAS := cCodRas	
						  BA3->BA3_TIPVIN := '0'
				    	BA3->(MsUnlock())	
					EndIf
				EndIf
				
				//Atualizo a matricula nas tabelas do GH.
				GBH->(DbSetOrder(8))
				If GBH->(MsSeek(xFilial("GBH")+BA1->BA1_MATVID))
					RecLock("GBH",.F.) 	
						GBH->GBH_USUARI := M->BQQ_CODINT + M->BQQ_EMPDES + cMatricula + cTipReg + cDigito					  				
				    GBH->(MsUnlock())					    
				EndIF				
						
				GD4->(DbSetOrder(3))		
				If GD4->(DbSeek(xFilial("GD4") + cGrpFam+BA1->(BA1_TIPREG + BA1_DIGITO)))
						While !GD4->(Eof()) 
							If Alltrim(GD4->GD4_MATRIC) == cGrpFam+BA1->(BA1_TIPREG + BA1_DIGITO)
								RecLock("GD4",.F.) 	
									GD4->GD4_MATRIC := M->BQQ_CODINT + M->BQQ_EMPDES + cMatricula + cTipReg + cDigito													  								 		
								GD4->(MsUnlock())
							Endif
							GD4->(DbsKip())
						Enddo
				Endif													
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Reposiciona o arquivo, caso este tenha sido desposicionado pelo P.E...   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BA1->( dbGoto(TRB169->R_E_C_N_O_) )
				TRB169->( dbSkip() )
				cForCob	 := ""

			Enddo

			If Len(aCmpOriTran) > 0
				StartJob("PLJOBNIO",GetEnvServer(),.F.,cEmpAnt,cFilAnt,;
					"B3K",aCmpOriTran,nOpcx,.T./*lMult*/,aOpcSip,;
					dDataBase,aDadCobJob)
			EndIf
			If Len(aCmpDesTran) > 0
				StartJob("PLJOBNIO",GetEnvServer(),.F.,cEmpAnt,cFilAnt,;
					"B3K",aCmpDesTran,nOpcx,.T./*lMult*/,aOpcSip,;
					dDataBase,aDadCobJob)
			EndIf

			If lCritSib .AND. !GetNewPar("MV_PLGRCRI",.T.)
				DisarmTransaction()
				TRB169->( dbCloseArea() )
				RestArea(aArea)
				lReturn := .T.
			EndIf
			If !lReturn
				If lPl169Fim
					ExecBlock("PL169FIM",.f.,.f.,{cOldMat,cNewMat})
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Transfere os valores da Faixa Salarial Familia                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectarea("B1B")
				If DbSeek(xFilial("B1B")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG))
					While B1B->(!EOF()) .AND. B1B->(B1B_CODIGO+B1B_NUMCON+B1B_VERCON+B1B_SUBCON+B1B_VERSUB+B1B_CODPRO+B1B_VERPRO+B1B_CODFOR)=BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)
						B1C->( RecLock("B1C", .T.) )
						For nCnt := 1 To B1C->( fCount() )
							cCampo 		:= B1C->( Field(nCnt) )
							If cCampo     == "B1C_FILIAL"
								B1C->( FieldPut(nCnt, xFilial("B1C") ) )
							ElseIf cCampo == "B1C_CODOPE"
								B1C->( FieldPut(nCnt, BA3->BA3_CODINT ) )
							ElseIf cCampo == "B1C_CODEMP"
								B1C->( FieldPut(nCnt, BA3->BA3_CODEMP ) )
							ElseIf cCampo == "B1C_MATRIC"
								B1C->( FieldPut(nCnt, BA3->BA3_MATRIC ) )
							ElseIf cCampo == "B1C_CODFOR"
								B1C->( FieldPut(nCnt, 	BA3->BA3_FORPAG ) )
							Else
								cCampoB1C := StrTran(cCampo, "B1C","B1B")
								If FieldPos(cCampoB1C) > 0
									B1C->( FieldPut(nCnt, &("B1B->"+cCampoB1C)) )
								Endif
							Endif
						Next
						B1C->( MsUnlock() )
						B1B->(DbSkip())
					Enddo
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Transfere os valores da Faixa Salarial Familia x QTD.                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectarea("B1G")
				If DbSeek(xFilial("B1G")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG))
					While B1G->(!EOF()) .AND. B1G->(B1G_CODIGO+B1G_NUMCON+B1G_VERCON+B1G_SUBCON+B1G_VERSUB+B1G_CODPRO+B1G_VERPRO+B1G_CODFOR)=BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)
						B1H->( RecLock("B1H", .T.) )
						For nCnt := 1 To B1H->( fCount() )
							cCampo 		:= B1H->( Field(nCnt) )
							If cCampo	  =="B1H_FILIAL"
								B1H->( FieldPut(nCnt, xFilial("B1H") ) )
							ElseIf cCampo == "B1H_CODOPE"
								B1H->( FieldPut(nCnt, BA3->BA3_CODINT ) )
							ElseIf cCampo == "B1H_CODEMP"
								B1H->( FieldPut(nCnt, BA3->BA3_CODEMP ) )
							ElseIf cCampo == "B1H_MATRIC"
								B1H->( FieldPut(nCnt, BA3->BA3_MATRIC ) )
							ElseIf cCampo == "B1H_CODFOR"
								B1H->( FieldPut(nCnt, 	BA3->BA3_FORPAG ) )
							Else
								cCampoB1H := StrTran(cCampo, "B1H","B1G")
								If FieldPos(cCampoB1H) >0
									B1H->( FieldPut(nCnt, &("B1G->"+cCampoB1H)) )
								Endif
							Endif
						Next
						B1H->( MsUnlock() )
						B1G->(DbSkip())
					Enddo
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Bloqueia a Familia no contrato anterior...                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BA3->( dbGoto(nBa3Lock) )

				If Empty(M->BQQ_FAMORI) .OR.;  // Transferindo toda a empresa...
					( !Empty(M->BQQ_FAMORI) .and. M->BQQ_TODOS == '1' ) .or.; // Transferindo todos de uma familia especifica...
					( !Empty(M->BQQ_FAMORI) .and. M->BQQ_TODOS <> '1' .and. lBloqAll) // Transferindo apenas
					// parte de uma familia especifica, porem os que ficam serao bloqueados...

					// Se ficou algum usuario sem ser transferido, a familia nao sera bloqueada.
					If BQQ->( FieldPos("BQQ_EXPUSR") ) > 0 .and. !Empty(M->BQQ_EXPUSR)
						For nUsrFam := 1 To Len(aUsrFam)
							If !aUsrFam[nUsrFam, 3]
								lBloqBA3 := .F.
								Exit
							Endif
						Next
					ENDIF

					If lBloqBA3 .OR. lBloqAll
						BA3->( RecLock("BA3", .F.) )
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ A data do bloqueio nao pode ser menor que a data de inclusao da familia...³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If M->BQQ_DATEXC < BA3->BA3_DATBAS
							BA3->BA3_DATBLO	:= dDatabase
						Else
							BA3->BA3_DATBLO	:= M->BQQ_DATEXC
						Endif

						BA3->BA3_MOTBLO	:= M->BQQ_MOTBLO
						If BA3->( FieldPos("BA3_BLOFAT") ) > 0
							BA3->BA3_BLOFAT := Posicione("BG3",1,xFilial("BG3")+M->BQQ_MOTBLO,"BG3_BLOFAT")
						Endif
						BA3->BA3_MATFMB := BA3->BA3_MATANT	// Armazena o conteudo do campo de matricula antigo...
						If !lTransfCartAnt
							BA3->BA3_MATANT := ''  				// Zera Matricula Antiga(Sistema Antigo) na origem, para  AQUI
						Endif
						// Solucionar falha no MsSeek que posicionava a familia bloqueada!
						If BA3->( FieldPos("BA3_TRADES") ) > 0
							BA3->BA3_TRADES := StrTran(cNewMat, '.', '')			// Grava pra onde essa familia foi transferida!
						Endif
						BA3->( MsUnlock() )

						BC3->( RecLock("BC3",.T.) )
						BC3->BC3_FILIAL	:= xFilial("BC3")
						BC3->BC3_MATRIC	:= BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
						BC3->BC3_TIPO	:= '0'
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ A data do bloqueio nao pode ser menor que a data de inclusao da familia...³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If M->BQQ_DATEXC < BA3->BA3_DATBAS
							BC3->BC3_DATA	:= dDatabase
						Else
							BC3->BC3_DATA	:= M->BQQ_DATEXC
						Endif
						BC3->BC3_MOTBLO	:= M->BQQ_MOTBLO
						BC3->BC3_USUOPE	:= PLRETOPE()
						If M->BQQ_TODOS == '1'
							BC3->BC3_NIVBLQ	:= 'F'
						Else
							BC3->BC3_NIVBLQ	:= 'U'
						Endif
						BC3->BC3_BLOFAT	:= cBloFat
						BC3->( msUnlock() )
					Endif
				Endif
			EndIf		
		Enddo

		lCritSib := Len(aCritSib) > 0
		If lCritSib .and. !lAutomato
			PLSCRIGEN(aCritSib,{ {"Codigo Crit.","@C",5} , {"Descrição","@C",200 } , {"Solução","@C",200 } }, "  Críticas de Beneficiários  ")
		EndIf

		If !lReturn
			//Bloqueia todos beneficiários se foi definido para bloquear quem permanece na família
			If (lBloqAll)
				cUpdt := "UPDATE "+RetSqlName("BA1")+" SET BA1_DATBLO = '"+dTos(M->BQQ_DATEXC)+ "',"
				cUpdt += "BA1_MOTBLO = '"+M->BQQ_MOTBLO+"', BA1_CONSID = 'U', BA1_IMAGE = 'DISABLE' "
				If BA1->( FieldPos("BA1_BLOFAT") ) > 0
					cUpdt += ",BA1_BLOFAT = '"+cBloFat+"' "
				Endif
				cUpdt += " WHERE "
				cUpdt += "BA1_CODINT = '"+M->BQQ_CODINT+"' AND BA1_CODEMP = '"+M->BQQ_EMPORI+"' "
				If !Empty(M->BQQ_CONORI)
					cUpdt += "AND BA1_CONEMP = '"+M->BQQ_CONORI+"' AND BA1_VERCON = '"+M->BQQ_VCOORI+"' "
				Endif
				If !Empty(M->BQQ_SUBORI)
					cUpdt += "AND BA1_SUBCON = '"+M->BQQ_SUBORI+"' AND BA1_VERSUB = '"+M->BQQ_VRSORI+"' "
				Endif
				If !Empty(M->BQQ_FAMORI)
					cUpdt += " AND BA1_MATRIC = '"+M->BQQ_FAMORI+"' "
				Endif

				If lBloqFut // Bloqueio Futuro
					cUpdt += " AND (BA1_MOTBLO = ' ' OR BA1_DATBLO > "+DtoS(M->BQQ_DATEXC)+")"
				Else // Padrão
					cUpdt += " AND BA1_MOTBLO = ' ' "
				EndIf

				cUpdt += " AND D_E_L_E_T_ = ' ' "
				TcSqlExec(cUpdt)
			Endif

			//	Verificar se ficou Titular na Família Origem, senão será solicitado quem será o novo
			nFcount := BA1->(RECNO())
			lExistTitul := .T.
			BA1->(DBSETORDER(1))
			BA1->(DBSEEK(XFILIAL() + M->(BQQ_CODINT + BQQ_EMPORI + BQQ_FAMORI + __cTipoUsoTit)))	//	Posiciona no Titular na Família Origem
			WHILE !BA1->(EOF()) .AND. BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPUSU) == M->(BQQ_CODINT + BQQ_EMPORI + BQQ_FAMORI + __cTipoUsoTit)
				IF EMPTY(BA1->BA1_DATBLO)	//	Achou um Titular Ativo na Família
					lExistTitul := .F.
					EXIT
				ENDIF
				BA1->(DBSKIP())
			ENDDO
			IF lExistTitul	//	Se não tem um Titular Ativo
				IF LEN(aCritica) == 1	//	Se restou só 1 Usuário ele será o Titular
					aCritica[1, 3] := __cTipoUsoTit
					aCritica[1, 6] := __cGrauParTit
				ELSE
					WHILE LEN(aCritica) > 0	//	Executa até que seja indicado um novo Titular para a Familia Origem
						
						IF ASCAN(aCritica, {|x| x[5]})	//	Só sai se marcou Titular
							EXIT
						Else
							PLS169MRK(.F., , .F.)	//	Atualiza o aCritica	
						ENDIF
					ENDDO
				ENDIF
				FOR nCnt := 1 TO LEN(aCritica)
					BA1->(DBGOTO(aCritica[nCnt, 10]))
					IF EMPTY(BA1->BA1_DATBLO)
						RECLOCK("BA1")	//	Atualiza o Tipo e Grau dos Membros da Família
						BA1_TIPUSU := aCritica[nCnt, 3]
						BA1_GRAUPA := aCritica[nCnt, 6]
						If BA1->( FieldPos("BA1_RESFAM") ) > 0 .AND. aCritica[nCnt, 3] == __cTipoUsoTit
							BA1_RESFAM := "1"
						EndIf
						MSUNLOCK()
					ENDIF
				NEXT
			ENDIF
			BA1->(DBGOTO(nFcount))
		EndIf
	EndIf
End Transaction

If Len(aMatHAT) > 0 .And. FWAliasInDic("BNV", .F.) .And. GetNewPar("MV_PLSHAT","0") == "1" 
	cCodTra := _beneficiaries_inc
	BNV->(DbSetOrder(2))//BNV_FILIAL+BNV_CODTRA+BNV_ALIAS+BNV_CHAVE

	for nI:=1 to Len(aMatHAT)					
		//Verifico se ja tem desbloqueio nao enviado, se tiver, excluo
		If !BNV->(MsSeek(xFilial("BNV")+cCodTra+"BA1"+aMatHAT[nI,1]))
			cChaveHAT := aMatHAT[nI,1]
			PLHATPedPD(K_Incluir,cCodTra,"BA1",cChaveHAT,NIL,1)	
		EndIf	
	Next
EndIf

If !lReturn
	TRB169->( dbCloseArea() )
	RestArea(aArea)
	If Len(aDigitos) > 0 .and. !lAutomato
		PLSCRIGEN(aDigitos,{{STR0024, "@C", 100}, {STR0025, "@C", 170}}, STR0026) //"Matricula"###"Nome Do Usuário"###"Matriculas Geradas"
	Endif

	If BQQ->(FieldPos("BQQ_ADAPT")) > 0
		PLSDTADAPT(aDigitos)
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS169MRK ºAutor  ³Geraldo Felix Juniorº Data ³  12/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³MarkBrowse para selecionar os usuarios a serem transferidos º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PLSA169MRK(oBjeto,lMarcaDesmarca)                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS169MRK(lDireto, oObjex, lTitular)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Static objCENFUNLGP := CENFUNLGP():New()

Local aArea := GetArea() 
LOCAL oDlg
LOCAL nOpca := 0
LOCAL bOK := { || (oCritica:SetArray(aCritica), Iif( PLSA169VAL(@oCritica), (nOpca := K_OK, oDlg:End()), .F.))}
LOCAL bCancel := { || oDlg:End() }
LOCAL oCritica
LOCAL cSQL
LOCAL nInd
LOCAL oBold
LOCAL lPergunta := .F.
LOCAL lTransTit := .F.
LOCAL xRetorno

DEFAULT lDireto := .F.
Default oObjex := Nil
DEFAULT lTitular := .T.

cCadastro := STR0011
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa os campos de filtro, caso eles existam...                                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BQQ->(FieldPos("BQQ_EXPFAM")) > 0 .and. BQQ->(FieldPos("BQQ_EXPUSR")) > 0 .and. lDireto
	If !Empty(M->BQQ_EXPFAM) .or. !Empty(M->BQQ_EXPUSR)
		If MsgYesNo(STR0027) //'Ao informar uma família neste campo, os filtros selecionados nos botões Filtro Família e Filtro Usuário serão removidos... Deseja continuar?'
			M->BQQ_EXPFAM := ''
			M->BQQ_EXPUSR := ''
		Else
			Return(.F.)
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefine a matriz toda vez que entrar no F3...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCritica := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona os usuarios da origem...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSql := " SELECT BA1_NOMUSR, BA1_TIPREG, BA1_TIPUSU, BA1_GRAUPA, R_E_C_N_O_ RECNO "
cSql +=   " FROM "+RetSqlName("BA1")+" "
cSql +=  " WHERE BA1_FILIAL = '"+xFilial("BA1")+"' AND BA1_CODINT = '"+M->BQQ_CODINT+"' "
cSql +=    " AND BA1_CODEMP = '"+M->BQQ_EMPORI+"'"

// Bloqueio futuro - 0 = Não e 1 = Sim
If BQQ->(fieldPos('BQQ_BLOQFU')) > 0  
	If M->BQQ_BLOQFU == "1" // Bloqueio futuro igual a sim
		cSql += " AND (BA1_DATBLO = '"+ SPACE(08)+"' OR BA1_DATBLO > "+DtoS(dDataBase)+") "
	Else // Filtro Padrão
		cSql += " AND BA1_DATBLO = '"+ SPACE(08)+"' "
	EndIf
Else // Filtro Padrão
	cSql += " AND BA1_DATBLO = '"+ SPACE(08)+"' "
EndIf

If !Empty(M->BQQ_CONORI)
	cSql +=  " AND BA1_CONEMP = '"+M->BQQ_CONORI+"' AND BA1_VERCON = '"+M->BQQ_VCOORI+"' "
Endif
If !Empty(M->BQQ_SUBORI)
	cSql +=  " AND BA1_SUBCON = '"+M->BQQ_SUBORI+"' AND BA1_VERSUB = '"+M->BQQ_VRSORI+"' "
Endif
If !Empty(M->BQQ_FAMORI)
	cSql +=  " AND BA1_MATRIC = '"+M->BQQ_FAMORI+"' "
Endif
cSql +=    " AND D_E_L_E_T_ = ' ' "
PLSQuery(cSQL,"TRBBA1")
IF TRBBA1->(EOF())
	IF lTitular
		MSGALERT(STR0096)	//	"Não existem Usuários ativos nessa Família!"
		Return(.F.)
	ENDIF
ELSE
	IF !lTitular
		M->BQQ_FAMDES	:= ""	//	Limpa para permitir definir novo Titular na Família Origem, que foi transferido
	ENDIF
	TRBBA1->(dbEval({||aadd(aCritica, { ;
		TRBBA1->BA1_NOMUSR, ;
		TRBBA1->BA1_TIPREG, ;
		TRBBA1->BA1_TIPUSU, ;
		.F., ;	//	Vem com todos os itens desmarcados
		(TRBBA1->BA1_GRAUPA == __cGrauParTit .AND. EMPTY(M->BQQ_FAMDES)), ;	//	Se informar família destino, esse usuário não pode ser Titular
		TRBBA1->BA1_GRAUPA, ;
		'', ;
		'', ;
		(TRBBA1->BA1_GRAUPA == __cGrauParTit), ;	//	A posição 9 guarda a informação se o beneficiário era titular antes de qualquer alteração pelo F11
		TRBBA1->RECNO})}))	//	Posição Física do Registro
	TRBBA1->(DbCloseArea())
	RestArea(aArea)
	/*IF LEN(aCritica) == 1 .AND. EMPTY(M->BQQ_FAMDES) .AND. !("BQQ_FAMORI" $ __READVAR)	//	Se restou só 1 Usuário ele será o Titular se for nova Família Destino
		aCritica[1, 5] := .T.
		aCritica[1, 3] := __cTipoUsoTit
		aCritica[1, 6] := __cGrauParTit
	ELSE
	*/
		If !lDireto

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ativa tecla de atalho para troca do titular...                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SetKey(VK_F10 ,{||PLS169Tit(oCritica)})

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ativa tecla de atalho para troca do grau de parentesco e tipo de usuario...³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SetKey(VK_F11 ,{||PLS169Tpa(oCritica, aCritica[oCritica:nAt,2])})

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ativa janela para selecao dos usuario que serao transferidos...          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DEFINE MSDIALOG oDlg TITLE STR0024+M->BQQ_CODINT+"."+M->BQQ_EMPORI+"."+M->BQQ_FAMORI FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()
			@ 020,012 SAY oSay PROMPT STR0028 SIZE 100,010 OF oDlg PIXEL COLOR CLR_HBLUE //"Selecione os usuários"
			@ 007,012 say oSay PROMPT STR0029 SIZE 100,010 OF oDlg PIXEL COLOR CLR_HBLUE FONT oBold	//"F10 - Marca/Desmarca Titular"
			@ 007,140 say oSay PROMPT STR0030 SIZE 300,010 OF oDlg PIXEL COLOR CLR_HBLUE FONT oBold //"F11 - Altera Grau Parentesco / Tipo de usuário / Produto"
			TButton():New(185,105,STR0091,,bOK    ,050,010,,,,.T.) //Botão Confirmar
			TButton():New(185,180,STR0092,,bCancel,050,010,,,,.T.) //Botão Cancelar
			oCritica := TcBrowse():New( 035, 012, 330, 145,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
			oCritica:AddColumn(TcColumn():New(" ",{ || IIF(aCritica[oCritica:nAt,4],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
				"@!",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))
			oCritica:AddColumn(TcColumn():New(STR0031,{ || IIF(aCritica[oCritica:nAt,5],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },; //"Titular"
				"@!",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))
			oCritica:AddColumn(TcColumn():New(STR0025,{ || OemToAnsi(aCritica[oCritica:nAt,1]) },; //"Nome do usuário"
				"@!",nil,nil,nil,160,.F.,.F.,nil,nil,nil,.F.,nil))
			oCritica:AddColumn(TcColumn():New(STR0032,{ || OemToAnsi(aCritica[oCritica:nAt,2]) },; //"Tipo de registro"
				"@!",nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))
			oCritica:AddColumn(TcColumn():New(STR0033,{ || OemToAnsi(aCritica[oCritica:nAt,3]) },; //"Tipo de usuário"
				"@!",nil,nil,nil,045,.F.,.F.,nil,nil,nil,.F.,nil))
			oCritica:AddColumn(TcColumn():New(STR0034,{ || OemToAnsi(aCritica[oCritica:nAt,6]) },; //"Grau de Parentesco"
				"@!",nil,nil,nil,045,.F.,.F.,nil,nil,nil,.F.,nil))
			oCritica:AddColumn(TcColumn():New(STR0035,{ || OemToAnsi(aCritica[oCritica:nAt,7]) },; //"Produto"
				"@!",nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))
			oCritica:AddColumn(TcColumn():New(STR0036,{ || OemToAnsi(aCritica[oCritica:nAt,8]) },; //"Versão"
				"@!",nil,nil,nil,035,.F.,.F.,nil,nil,nil,.F.,nil))

		//-------------------------------------------------------------------
		//  LGPD
		//-------------------------------------------------------------------
			if objCENFUNLGP:isLGPDAt()
				aCampos := {.F., ;
							.F., ;
							"BA1_NOMUSR", ;
							"BA1_TIPREG", ;
							"BA1_TIPUSU", ;
							"BA1_GRAUPA", ;
							.F., ;
							.F.	}
				
				aBls := objCENFUNLGP:getTcBrw(aCampos)

				oCritica:aObfuscatedCols := aBls
			endif

			oCritica:SetArray(aCritica)
			oCritica:bLDblClick := {||(aCritica[oCritica:nAt, 4] := !aCritica[oCritica:nAt, 4], ;	//	Inverte a seleção
				aCritica[oCritica:nAt, 5] := ;	//	(Só será Titular se for nova Família) e (estiver selecionado) e (era titular na origem) e (não existir outro titular marcado)
				(EMPTY(M->BQQ_FAMDES) .AND. aCritica[oCritica:nAt, 4] .AND. aCritica[oCritica:nAt,9] .AND. ASCAN(aCritica, {|x| x[5]}) == oCritica:nAt))}
			ACTIVATE MSDIALOG oDlg /*ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})*/
		ENDIF
	//ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta string com os tipos de registros dos usuarios que serao transferidos...  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lTitular
		If nOpca == K_OK .or. lDireto
			lBloqAll := .F.
			cSelecao := ""

			For nInd := 1 To Len(aCritica)
				If aCritica[nInd,4]
					cSelecao += aCritica[nInd,2]+","

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Sim, o titular esta sendo tranferido tambem...                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If aCritica[nInd,9] //Verifica se o registro era originalmente do Titular, podemos mudar no F11 a informação da posição 6
						lTransTit := .T.
					Endif
				Endif

				If aCritica[nInd,5] .and. aCritica[nInd,6] == __cGrauParTit
					cNomTit := aCritica[nInd,1]
				Elseif (lTransTit .and. aCritica[nInd,6] <> __cGrauParTit .and. !aCritica[nInd,4])
					lPergunta := .T.
				Endif
			Next
			cSelecao := Left(cSelecao,(Len(cSelecao)-1))  // Retira a virgula do final da string

		//Verifica se algum beneficiário não foi transferido, caso o titular original seja
		//Para que a pergunta de bloqueio ocorra somente na transferência do titular e haja
		//outros membros na família
			For nInd := 1 To Len(aCritica)
				if lTranstit .AND. !aCritica[nInd, 4]
					lPergunta := .T.
					Exit
				EndIF
			Next
		Endif
		If lDireto
			Return(lDireto)
		Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso nao seja transferida a familia inteira, pergunta se eh para bloquear na   |
	//³ origem, os usuarios que nao serao transferidos...                              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPergunta
			lBloqAll := MsgYesNo(STR0037) //"Existe um ou mais usuários que não serão transferidos, deseja bloqueá-los na origem?"
		Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ocorre que se so restar um usuario na familia e ele estiver sendo transferido, |
	//³ a familia tambem devera ser bloqueada.                                         |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lBloqAll

		// Primeiro avalia se eh o ultimo usuario que esta sendo transferido.
			If Len(aCritica) == 1 .and. aCritica[1, 4]
				lBloqAll := .T.
			Endif

		// Em segundo lugar, avalia se a familia inteira esta sendo transferida, nos casos que o recurso foi
		// utilizado para diferenciar o produto dos usuarios transferidos.
			If !lBloqAll
				For nInd := 1 To Len(aCritica)
					lBloqAll := aCritica[nInd, 4]
					If !lBloqAll
						Exit
					Endif
				Next
			Endif
		Endif
		IF !EMPTY(cSelecao)
			M->BQQ_USUARI := cSelecao
			If !(ValType(oObjex) == "U")
				oObjex:refresh()
			EndIF
		ENDIF
	ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefine as teclas de atalho...                                                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SET KEY VK_F10 TO
	SET KEY VK_F11 TO
ENDIF

If ReadVar() == "M->BQQ_USUARI"
	xRetorno := .T.
Else
	xRetorno := cSelecao
EndIf

Return xRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA169TitºAutor  ³Geraldo Felix Juniorº Data ³  06/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o MarkBrowse de selecao do titular...                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLS169Tit(oObj)	//	[F10]

Local lRet := .T.
LOCAL nCnt

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Chama ponto de entrada para validar a obrigatoriedade do titular na transferência
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PL169VTI")
	lObrgTit := ExecBlock("PL169VTI",.f.,.f.,{nCnt})
	If (!lObrgTit)
		Return lRet
	EndIf
EndIf

IF EMPTY(M->BQQ_FAMDES)
	For nCnt := 1 To Len(oObj:aArray)
		oObj:aArray[nCnt, 5] := (nCnt == oObj:nAt)
		IF oObj:aArray[nCnt, 5]	//	É Títular
			oObj:aArray[nCnt, 3] := __cTipoUsoTit	//	Marca Tipo de Usuário como TITULAR := "T"
			oObj:aArray[nCnt, 4] := .T.	//	Força seleção do registro se só foi marcado como TITULAR
			oObj:aArray[nCnt, 6] := __cGrauParTit	//	Código do TITULAR := "01"
		ELSEIF oObj:aArray[nCnt, 4]	//	Se estiver marcado será Dependente
			oObj:aArray[nCnt, 3] := "D"	//	Tipo de Usuário
			IF oObj:aArray[nCnt, 6] == __cGrauParTit
				oObj:aArray[nCnt, 6] := "  "	//	Apaga Grau se indicou como Titular sem marcar no F10
			ENDIF
		ENDIF
		If oObj:aArray[nCnt, 6] == __cGrauParTit .and. nCnt # oObj:nAt
			oObj:aArray[nCnt, 4] := .F.
		Endif
	Next
	oObj:Refresh()
	aCritica := ACLONE(oObj:aArray)
ELSEIF oObj:aArray[oObj:nAt, 4]
	MsgAlert(STR0084) //"Nao é permitido mais de um titular na família"
ENDIF

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA169VALºAutor  ³Geraldo Felix Juniorº Data ³  13/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a coluna de titulares...                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLSA169VAL(oObj)

LOCAL nCnt := ASCAN(oObj:aArray, {|x| x[5]})	//	Posição do Titular Selecionado
LOCAL lRet := .T.

IF lObrgTit
	IF nCnt == 0 .AND. EMPTY(M->BQQ_FAMDES)	//	É obrigatório um Títular na Família Origem, se a Destino for nova
		MsgAlert(STR0038) //	"Informe o TITULAR!"
		lRet := .F.
	ELSE
		IF EMPTY(M->BQQ_FAMDES)	//	Só pode ter Titular se não existir Família Destino
			oObj:aArray[nCnt, 3] := __cTipoUsoTit	//	Marca Tipo de Usuário como TITULAR := "T"
			oObj:aArray[nCnt, 4] := .T.	//	Força seleção do registro se só foi marcado como TITULAR
			oObj:aArray[nCnt, 6] := __cGrauParTit	//	Código do TITULAR := "01"
		ENDIF
		FOR nCnt := 1 TO LEN(oObj:aArray)
			IF oObj:aArray[nCnt, 4] .OR. oObj:aArray[nCnt, 5]	//	Está Selecionado ou é Titular?
				IF EMPTY(M->BQQ_FAMDES) .AND. !oObj:aArray[nCnt, 4]
					oObj:aArray[nCnt, 4] := .T.
				ENDIF
				IF !oObj:aArray[nCnt, 5]	//	Se não for Titular
					oObj:aArray[nCnt, 3] := "D"	//	Garante que os demais registros selecionados serão Dependentes
					IF ( Empty(oObj:aArray[nCnt, 6]) .OR. oObj:aArray[nCnt, 1] == "01" )	//	Solicita a atualização do Grau de Parentesco caso não esteja preenchido ou seja de titular 
						PLS169Tpa(oObj, oObj:aArray[nCnt, 2], .F., nCnt)
						IF Empty(cSelecao)
							EXIT
						ENDIF	
					ELSE
						IF EMPTY(M->BQQ_FAMDES)	//	Para Uma Nova Família
							IF oObj:aArray[nCnt, 6] == __cGrauParTit
								MsgAlert(STR0084) //"Nao é permitido mais de um titular na família"
								lRet := .F.
								Exit
							ENDIF
						ELSE	//	Para Uma Familia Já Existente
							IF oObj:aArray[nCnt, 6] == __cGrauParTit
								MsgAlert(STR0042) //"Impossível transferir usuário como titular. A família destino já possui um titular. Altere o tipo de usuário e informe o grau de parentesco deste usuário em relação ao titular da família destino!"
								lRet := .F.
								Exit
							ENDIF
						ENDIF
					ENDIF
				ENDIF
				// Caso tenha um novo titular na familia
				IF oObj:aArray[nCnt, 5] .AND. oObj:aArray[nCnt, 2] <> __cTipoRegTit .AND. lRet
					// Verifica se na familia anterior tinha o salario (BA3_VALSAL),
					// Se sim, permitir que o usuario altere antes de gravar a nova familia
					aDadFam := PLSA169SAL(oObj:aArray[nCnt, 2],nCnt,aDadFam)
				EndIf   

			ENDIF
		NEXT
	ENDIF
ENDIF
M->BQQ_USUARI := cSelecao	//	Atualiza a variavel de memoria com os tipos de registros que serao transferidos..
aCritica := ACLONE(oObj:aArray)

RETURN(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA169Mud   ºAutor  ³Microsiga         º Data ³  11/25/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLSA169Mud(oObj, cTipUsr)

LOCAL nCnt
LOCAL lForca := .T.

For nCnt := 1 To Len(oObj:aArray)
	If oObj:aArray[nCnt,4] .And. oObj:aArray[nCnt,3] == __cTipoUsoTit .and. cTipUsr == __cTipoUsoTit .and. nCnt <> oObj:nAt
		MsgAlert(STR0084)//"Nao é permitido mais de um titular na família"
		lForca := .F.
		EXIT
	Endif
Next

Return(lForca)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VAL169PLS ºAutor  ³Geraldo Felix Juniorº Data ³  13/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a gravacao da rotina.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VAL169PLS(nOpc)

LOCAL nCnt       := 0
LOCAL cModelo    := GetMv("MV_PLTITCD")
LOCAL aProdBT6   := {}
LOCAL cKeyBT6    := ''
LOCAL aProdOri   := {}
LOCAL aProdDes   := {}
LOCAL aShowDif   := {}
LOCAL cExpFam    := Iif(BQQ->(FieldPos("BQQ_EXPFAM")) > 0, M->BQQ_EXPFAM, '')
LOCAL lConSub	 := .F.  

//Validação para a funcionalidade de transferência apenas do contrato e subcontrato
If BQQ->(FieldPos("BQQ_CONSUB")) > 0 .AND. M->BQQ_CONSUB == "1" 
	
	lConSub := .T.
	
	If EMPTY(M->BQQ_CONORI) .OR. EMPTY(M->BQQ_VCOORI) .OR. EMPTY(M->BQQ_CONDES) .OR. EMPTY(M->BQQ_VCODES) .OR. EMPTY(M->BQQ_SUBORI) .OR. ;
	   EMPTY(M->BQQ_VRSORI) .OR. EMPTY(M->BQQ_SUBDES) .OR. EMPTY(M->BQQ_VRSDES) .OR. EMPTY(M->BQQ_FAMORI) .OR. EMPTY(M->BQQ_FAMDES)

		MsgAlert("Preencha todos os campos habilitados para edição", "Atenção")
		Return .F.
	EndIf
EndIf 

If !lConSub  

	If nOpc = K_Incluir .and. Empty(M->BQQ_CONDES) .and. Empty(M->BQQ_CODPRO)
		MsgAlert(STR0039) //"Quando o destino e Pessoa Física, torna-se obrigatório o apontamento de um produto."
		Return(.F.)
	Endif
	
	If !Empty(M->BQQ_FAMDES)
		If Empty(M->BQQ_FAMORI)
			MsgAlert(STR0040) //"Quando o Campo Fam. Destino é informado, torna-se obrigatório o preenchimento do campo Família, indicando uma família de origem."
			Return(.F.)
		Endif
		BA3->( dbSetorder(01) )
		If !BA3->(dbSeek(xFilial("BA3") + M->(BQQ_CODINT + BQQ_EMPDES + BQQ_FAMDES)))
			MsgAlert(STR0041) //"A família de destino não existe. Informe uma matricula de família valida no destino."
			Return(.F.)
		Endif
		For nCnt := 1 To Len(aCritica)
			If aCritica[nCnt, 4] .OR. M->BQQ_TODOS == "1"
				If aCritica[nCnt, 6] == __cGrauParTit .and. aCritica[nCnt, 3] == __cTipoUsoTit
					MsgAlert(STR0042) //"Impossível transferir usuário como titular. A família destino já possui um titular. Altere o tipo de usuário e informe o grau de parentesco deste usuário em relação ao titular da família destino!"
					Return(.F.)
				Endif
				cGrauPa := aCritica[nCnt, 6]
				cTipUsu := aCritica[nCnt, 3]
				cTipReg := aCritica[nCnt, 2]
				If !(PL169TipRg(cGrauPa,cTipReg,cTipUsu,(M->BQQ_CODINT+M->BQQ_EMPDES+M->BQQ_FAMDES))[2])
					If cModelo == '1'
						Help("",1,"PLS260T1")
					Else
						Help("",1,"PLS260T2")
					Endif
					Return(.F.)
				Endif
			Endif
		Next
	Endif
	BG9->( dbSetorder(01) )
	BG9->( dbSeek(xFilial("BG9")+M->BQQ_CODINT+M->BQQ_EMPDES) )
	If BG9->BG9_TIPO == '2'
		If Empty(M->BQQ_CONDES)
			MsgAlert(STR0043) //"Campo Contrato Destino e obrigatório em transferências onde a empresa destino e pessoa jurídica!"
			Return(.F.)
		Elseif Empty(M->BQQ_SUBDES)
			MsgAlert(STR0044) //"Campo Subcontrato Destino e obrigatório em transferências onde a empresa destino e pessoa jurídica!"
			Return(.F.)
		Endif
		BQC->( dbSetorder(01) )
		If BQC->( MsSeek(xFilial("BQC")+M->(BQQ_CODINT+BQQ_EMPDES+BQQ_CONDES+BQQ_VCODES+BQQ_SUBDES+BQQ_VRSDES)) )
			If !Empty(BQC->BQC_DATBLO)
				If !MsgStop(STR0045) //"Impossivel continuar... O subcontrato de destino encontra-se bloqueado!"
					Return(.F.)
				Endif
			Endif
		Endif
		If ( M->(BQQ_EMPORI+BQQ_CONORI+BQQ_VCOORI+BQQ_SUBORI+BQQ_VRSORI) ==;
				M->(BQQ_EMPDES+BQQ_CONDES+BQQ_VCODES+BQQ_SUBDES+BQQ_VRSDES) ) .and. Empty(cExpFam)
			If !Empty(M->BQQ_FAMORI) .and. !Empty(M->BQQ_FAMDES)
				If !(M->BQQ_FAMORI <> M->BQQ_FAMDES)
					MsgAlert(STR0046) //"Impossível transferir para si próprio! O Destino deve ser diferente da origem!"
					Return(.F.)
				Endif
			Elseif Empty(M->BQQ_FAMORI) .and. !Empty(M->BQQ_FAMDES)
				MsgAlert(STR0047) //"Quando a família destino e informada, a família origem passa a ser obrigatória!"
				Return(.F.)
			Elseif 	Empty(M->BQQ_FAMORI) .and. Empty(M->BQQ_FAMDES)
				MsgAlert(STR0046) //"Impossível transferir para si próprio! O Destino deve ser diferente da origem!"
				Return(.F.)
			Endif
		Endif
	Elseif BG9->BG9_TIPO == '1'
		If Empty(M->BQQ_FAMORI) .and. !Empty(M->BQQ_FAMDES)
			MsgAlert(STR0047) //"Quando a família destino e informada, a família origem passa a ser obrigatória!"
			Return(.F.)
		Elseif Empty(M->BQQ_FAMORI) .and. Empty(M->BQQ_FAMDES)
			If !MsgYesNo(STR0048+M->BQQ_EMPORI+STR0049+M->BQQ_EMPDES+" ?") //"Tem certeza absoluta de quem vai transferir todo o grupo empresa "###" para o grupo "
				Return(.F.)
			Endif
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Mantem produto original... Sim ou Nao ?                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("BI3")
		BI3->( dbSetorder(01) )
		If !BI3->( msSeek(xFilial("BI3")+M->BQQ_CODINT+M->BQQ_CODPRO+M->BQQ_VRSPRO) )
			MsgAlert(STR0050) //"O produto informado não existe. Por favor, verifique!"
			Return(.F.)
		Elseif !(BI3->BI3_TIPO $ '1,3')
			MsgAlert(STR0051) //"O produto informado não é permitido para contratos de pessoa física!"
			Return(.F.)
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mantem produto original... Sim ou Nao ?                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BQQ->( FieldPos("BQQ_PROORI") ) > 0 .and. M->BQQ_PROORI = '1'
		If BG9->BG9_TIPO == '2'
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Primeiro verifica na origem...                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cKeyBT6 := M->(BQQ_CODINT+BQQ_EMPORI+BQQ_CONORI+BQQ_VCOORI+BQQ_SUBORI+BQQ_VRSORI)
			dbSelectarea("BT6")
			BT6->( dbSetorder(01) )
			If BT6->( MsSeek(xFilial("BT6")+cKeyBT6) )
				While !BT6->( Eof() ) .and. BT6->BT6_CODINT+BT6->BT6_CODIGO+BT6->BT6_NUMCON+BT6->BT6_VERCON+;
						BT6->BT6_SUBCON+BT6->BT6_VERSUB == cKeyBT6
					Aadd(aProdOri, {BT6->BT6_CODPRO, BT6->BT6_VERSAO,Posicione("BI3",1,xFilial("BI3")+BT6->(BT6_CODPRO+BT6_VERSAO),"BI3_VERSAO")})
					BT6->( dbSkip() )
				Enddo
			Else
				MsgAlert(STR0052) //"Não foi encontrado produto no subcontrato de origem!"
				Return(.F.)
			Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Depois verifica no destino....                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cKeyBT6 := M->(BQQ_CODINT+BQQ_EMPDES+BQQ_CONDES+BQQ_VCODES+BQQ_SUBDES+BQQ_VRSDES)
			IF BT6->( MsSeek(xFilial("BT6")+cKeyBT6) )
				While !BT6->( Eof() ) .and. BT6->BT6_CODINT+BT6->BT6_CODIGO+BT6->BT6_NUMCON+BT6->BT6_VERCON+;
						BT6->BT6_SUBCON+BT6->BT6_VERSUB == cKeyBT6
					Aadd(aProdDes,{BT6->BT6_CODPRO,BT6->BT6_VERSAO,Posicione("BI3",1,xFilial("BI3")+BT6->(BT6_CODPRO+BT6_VERSAO),"BI3_VERSAO")})
					BT6->( dbSkip() )
				Enddo
			Else
				MsgAlert(STR0053) //"Não foi encontrado produto no subcontrado de destino!"
				Return(.F.)
			Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Garantindo a integridade das matrizes...                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aProdOri) == 0
				MsgAlert(STR0054) //"Não foi encontrado produto no subcontrado de origem!"
				Return(.F.)
			Endif
			If Len(aProdDes) == 0
				MsgAlert(STR0053) //"Não foi encontrado produto no subcontrado de destino!"
				Return(.F.)
			Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Depois compara a origem com o destino...                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nCnt := 1 To Len(aProdOri)
				If (nPos := Ascan(aProdDes, {|x| x[1]+x[2] == aProdOri[nCnt, 1]+aProdOri[nCnt, 2]})) == 0
					Aadd(aShowDif, {aProdOri[nCnt, 1],;
						aProdOri[nCnt, 2],;
						Posicione("BI3",1,xFilial("BI3")+aProdOri[nCnt, 1]+aProdOri[nCnt, 2],"BI3_VERSAO")})
				Endif
			Next
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se encontrar diferenca avisa ao usuario e pede a confirmacao...          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aShowDif) > 0
				If MsgYesNo(STR0055) //"Inconsistências ao tentar manter produto original da família / usuário. Nem todos os produtos da origem estão cadastrados no destino. Confirme para visualizar estes produtos ou cancele e revise o cadastro do subcontrato de destino"
					cRodape := STR0056 //"As famílias ou usuários destes produtos serão transferidos com o"
					cRodape += STR0057+aProdDes[1, 1]+" - "+aProdDes[1, 2]+". " //"código de plano "
					cRodape += STR0058 //"DESEJA CONTINUAR COM A TRANSFERÊNCIA?"
					If !PLSCRIGEN(aShowDif, { ;
							{STR0035,"@C", 070}, ; //"Produto"
							{STR0036,"@C", 050}, ;
							{STR0059,"@C", 150}}, STR0060, .T., cRodape)[1] //"Descricao"###"Produtos"
						Return(.F.)
					Endif
				Else
					Return(.F.)
				Endif
			Endif
		Endif
	Endif
EndIf

Return If( !lConSub, PLS169DEST(), .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA260CLI ³ Autor ³ Geraldo Felix Jr.  ³ Data ³ 13.06.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Altera um registro do arquivo de cliente                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA260CLI

Local I__f := 0
LOCAL oDlg
LOCAL nOpca     := 0
LOCAL oEnc
LOCAL aRet
LOCAL bOK       := { || nOpca := 1,If( Obrigatorio(oEnc:aGets,oEnc:aTela),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL bCancel   := { || oDlg:End() }
LOCAL cCadastro := STR0066 //"Alteração Cliente"
LOCAL aOldTela  := aTela
LOCAL aOldGets  := aGets
LOCAL nOrdBA3   := BA3->(IndexOrd())
LOCAL nRecBA3   := BA3->(Recno())

PRIVATE aTela   := {}
PRIVATE aGets   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro FROM ndLinIni,000 TO ndLinFin,ndColFin OF GetWndDefault()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Copy "SA1" To Memory
oEnc := SA1->(MsMGet():New("SA1",SA1->(Recno()),K_Alterar,,,,,{015,004,192,390},,,,,,oDlg,,,.F.))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,{})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define tratamento de acordo com a opcao...                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclui movimento...                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA1->(PLUPTENC("SA1",K_Alterar))
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura aGets e aTela e Arquivo de Usuarios...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := aOldTela
aGets := aOldGets
BA3->(DbSetOrder(nOrdBA3))
BA3->(DbGoTo(nRecBA3))

Return(.F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA169   ºAutor  ³Microsiga           º Data ³  01/17/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL169WHEN(cTipo)

LOCAL lRet := .F.

If cTipo == "1"
	If M->BQQ_TODOS = '0' .and. !Empty(M->BQQ_FAMORI)
		lRet := .T.   
	Else 		
		cSelecao := ""
		M->BQQ_USUARI := ""
		oDlg:refresh()                                                                         
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL169FOR  ºAutor  ³Geraldo Felix Juniorº Data ³  04/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Transfere a forma de cobranca do produto/sub contrato da   º±±
±±º          ³para a familia em seu destino.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PL169FOR(cMatricula, lJuriDes, lJuriOri, lUsuario, cOldMat)

Local i
LOCAL aGetArea 	:= {}
LOCAL nCnt		:= 0
LOCAL aXconteudo:= {}
LOCAL cAno		:= Str(Year(BA3->BA3_DATBAS), 4)
LOCAL cMes 		:= StrZero(Month(BA3->BA3_DATBAS), 2)
LOCAL aArea		:= GetArea()
LOCAL cCodInt 	:= Substr(cMatricula, atCodOpe[1], atCodOpe[2])
LOCAL cCodEmp 	:= Substr(cMatricula, atCodEmp[1], atCodEmp[2])
LOCAL cMatric 	:= Substr(cMatricula, atMatric[1], atMatric[2])
LOCAL aFaixas 	:= {}
LOCAL nCodFai	:= 0

DEFAULT lUsuario := .F.

Aadd( aGetArea, {"BG9",BG9->( Recno() )} )
Aadd( aGetArea, {"BT5",BT5->( Recno() )} )
Aadd( aGetArea, {"BQC",BQC->( Recno() )} )
Aadd( aGetArea, {"BT6",BT6->( Recno() )} )
Aadd( aGetArea, {"BG9",BG9->( Recno() )} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Primeira situacao: Pessoa juridica !								|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lJuriDes
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o  produto da pessoa juridica                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lUsuario
		dbSelectarea("BT6")
		BT6->( dbSetorder(01) )
		BT6->( MsSeek(xFilial("BT6")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+;
			BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO)) )
	Else
		dbSelectarea("BT6")
		BT6->( dbSetorder(01) )
		BT6->( MsSeek(xFilial("BT6")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+;
			BA1_VERCON+BA1_SUBCON+BA1_VERSUB+BA1_CODPLA )) )
	Endif

	If BT6->( Eof() )
		Return()
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ pega a forma de cobranca...                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BT9->( dbSetorder(01) )
	If BT9->( MsSeek(xFilial("BT9")+BT6->BT6_CODINT+BT6->BT6_CODIGO+BT6->BT6_NUMCON+BT6->BT6_VERCON+BT6->BT6_SUBCON+BT6->BT6_VERSUB+BT6->BT6_CODPRO+BT6->BT6_VERSAO) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa todas as formas de cobrancas...                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !BT9->( Eof() ) .and. (BT6->BT6_CODINT+BT6->BT6_CODIGO+BT6->BT6_NUMCON+BT6->BT6_VERCON+;
				BT6->BT6_SUBCON+BT6->BT6_VERSUB+BT6->BT6_CODPRO+BT6->BT6_VERSAO) == (BT9->BT9_CODIGO+;
				BT9->BT9_NUMCON+BT9->BT9_VERCON+BT9->BT9_SUBCON+;
				BT9->BT9_VERSUB+BT9->BT9_CODPRO+BT9->BT9_VERSAO)


			If BT9->BT9_CODFOR <> BA3->BA3_FORPAG
				BT9->( dbSkip() )
				Loop
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Transfere a forma de cobranca...                        			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lUsuario
				RecLock("BJK", .T.)
				BJK->BJK_FILIAL := xFilial("BJK")
				BJK->BJK_CODOPE := cCodInt
				BJK->BJK_CODEMP := cCodEmp
				BJK->BJK_MATRIC := cMatric
				BJK->BJK_CODFOR := BT9->BT9_CODFOR
				BJK->BJK_AUTOMA := '1'	
				BJK->( MsUnlock() )
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona registro no cadastro de formas de cobranca...             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BJ1->(MsSeek(xFilial("BJ1") + BT9->BT9_CODFOR))
			
			// Alteração feita para uso na função PLSGERGRFM
			// Na linha 1685 do PLSA169 é feito a gravação da faixa salarial da familia, portanto essa gravação
			// da faixa salarial será usada somente para quando não for chamado do PLSA169, para não duplicar
			If BT9->BT9_CODFOR == "108" .AND. !IsInCallStack("PLSA169")

				// Transfere os valores da Faixa Salarial Familia                     
				cSQL := "SELECT * FROM " + RetSQLName("B1B")+" WHERE B1B_FILIAL = '"+xFilial("B1B")+"' AND "
				cSQL += "B1B_CODIGO = '"+BT6->BT6_CODINT + BT6->BT6_CODIGO+"' AND "
				cSQL += "B1B_NUMCON = '"+BT6->BT6_NUMCON+"' AND "
				cSQL += "B1B_VERCON = '"+BT6->BT6_VERCON+"' AND "
				cSQL += "B1B_SUBCON = '"+BT6->BT6_SUBCON+"' AND "
				cSQL += "B1B_VERSUB = '"+BT6->BT6_VERSUB+"' AND "
				cSQL += "B1B_CODPRO = '"+BT6->BT6_CODPRO+"' AND "
				cSQL += "B1B_VERPRO = '"+BT6->BT6_VERSAO+"' AND "
				cSQL += "B1B_FAIFAM = '" + BJ1->BJ1_FAIFAM + "' AND B1B_CODFOR = '" + BT9->BT9_CODFOR + "' AND "
				cSQL += "D_E_L_E_T_= '' "
			
				PLSQuery(cSQL,"TRB1B")

				While !TRB1B->( Eof() )
					If !lUsuario
						
						B1C->( RecLock("B1C", .T.) )
						For nCnt := 1 To B1C->( fCount() )
							cCampo 		:= B1C->( Field(nCnt) )

								If cCampo == "B1C_CODOPE"
								B1C->( FieldPut(nCnt, cCodInt ) )

							Elseif cCampo == "B1C_CODEMP"
								B1C->( FieldPut(nCnt, cCodEmp ) )

							Elseif cCampo == "B1C_MATRIC"
								B1C->( FieldPut(nCnt, cMatric ) )

							Elseif cCampo == "B1C_CODFOR"
									B1C->( FieldPut(nCnt, BA3->BA3_FORPAG) )
							
							Elseif cCampo == "B1C_AUTOMA"
								B1C->( FieldPut(nCnt, "1") )

							Else
								cCampoB1B := "TRB1B->"+StrTran(cCampo, "B1C","B1B")
								If B1B->(FieldPos(Substr(cCampoB1B,8))) > 0 .and.;
									B1C->(FieldPos(cCampo)) > 0
									B1C->( FieldPut(nCnt, &cCampoB1B) )
								Endif
							Endif
						Next
						B1C->( MsUnlock() )
					EndIf
					TRB1B->( dbSkip() )
				EndDo
				
				TRB1B->(DbCloseArea())
							
				// Transfere os valores da Faixa Salarial Familia x QTD.                 
				cSQL := "SELECT * FROM " + RetSQLName("B1G")+" WHERE B1G_FILIAL = '"+xFilial("B1G")+"' AND "
				cSQL += "B1G_CODIGO = '"+BT6->BT6_CODINT + BT6->BT6_CODIGO+"' AND "
				cSQL += "B1G_NUMCON = '"+BT6->BT6_NUMCON+"' AND "
				cSQL += "B1G_VERCON = '"+BT6->BT6_VERCON+"' AND "
				cSQL += "B1G_SUBCON = '"+BT6->BT6_SUBCON+"' AND "
				cSQL += "B1G_VERSUB = '"+BT6->BT6_VERSUB+"' AND "
				cSQL += "B1G_CODPRO = '"+BT6->BT6_CODPRO+"' AND "
				cSQL += "B1G_VERPRO = '"+BT6->BT6_VERSAO+"' AND "
				cSQL += "B1G_FAIFAM = '" + BJ1->BJ1_FAIFAM + "' AND B1G_CODFOR = '" + BT9->BT9_CODFOR + "' AND "
				cSQL += "D_E_L_E_T_= '' "
			
				PLSQuery(cSQL,"TRB1G")

				While !TRB1G->( Eof() )
					If !lUsuario
								
						B1H->( RecLock("B1H", .T.) )
						For nCnt := 1 To B1H->( fCount() )
							cCampo 		:= B1H->( Field(nCnt) )

							If cCampo == "B1H_CODOPE"
								B1H->( FieldPut(nCnt, cCodInt ) )

							Elseif cCampo == "B1H_CODEMP"
								B1H->( FieldPut(nCnt, cCodEmp ) )

							Elseif cCampo == "B1H_MATRIC"
								B1H->( FieldPut(nCnt, cMatric ) )

							Elseif cCampo == "B1H_CODFOR"
								B1H->( FieldPut(nCnt, BA3->BA3_FORPAG) )
							
							Elseif cCampo == "B1H_AUTOMA"
								B1H->( FieldPut(nCnt, "1") )

							Else
								cCampoB1G := "TRB1G->"+StrTran(cCampo, "B1H","B1G")
								If B1G->(FieldPos(Substr(cCampoB1G,8))) > 0 .and.;
									B1H->(FieldPos(cCampo)) > 0
									B1H->( FieldPut(nCnt, &cCampoB1G) )
								Endif
							Endif
						Next
						B1H->( MsUnlock() )
					EndIf
					TRB1G->( dbSkip() )
				EndDo
				TRB1G->(DbCloseArea())
				RestArea(aArea)
				BT9->( dbSkip() )
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Obtem a quantidade de usuarios na empresa...                      	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCodQtd := '001'

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Transfere os valores da forma de cobranca...                       	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cSQL := "SELECT * FROM " + RetSQLName("BTN")+" WHERE "
				cSQL += "BTN_FILIAL = '"+xFilial("BTN")+"' AND "
				cSQL += "BTN_CODIGO = '"+BT9->BT9_CODIGO+"' AND "
				cSQL += "BTN_NUMCON = '"+BT9->BT9_NUMCON+"' AND "
				cSQL += "BTN_VERCON = '"+BT9->BT9_VERCON+"' AND "
				cSQL += "BTN_SUBCON = '"+BT9->BT9_SUBCON+"' AND "
				cSQL += "BTN_VERSUB = '"+BT9->BT9_VERSUB+"' AND "
				cSQL += "BTN_CODPRO = '"+BT9->BT9_CODPRO+"' AND "
				cSQL += "BTN_VERPRO = '"+BT9->BT9_VERSAO+"' AND "
				cSQL += "BTN_CODQTD = '"+Iif(cCodQtd=='ZZZ','001',cCodQtd)+"' AND "
				cSQL += "BTN_FAIFAM = '" + BJ1->BJ1_FAIFAM + "' AND BTN_CODFOR = '"+BT9->BT9_CODFOR+ "' AND "
				cSQL += "D_E_L_E_T_ = ' ' AND BTN_TABVLD = (SELECT MAX(BTN_TABVLD) FROM " + RetSQLName("BTN")
				cSQL += " WHERE BTN_FILIAL = '"+xFilial("BTN")+"' AND "
				cSQL += "BTN_CODIGO = '"+BT9->BT9_CODIGO+"' AND "
				cSQL += "BTN_NUMCON = '"+BT9->BT9_NUMCON+"' AND "
				cSQL += "BTN_VERCON = '"+BT9->BT9_VERCON+"' AND "
				cSQL += "BTN_SUBCON = '"+BT9->BT9_SUBCON+"' AND "
				cSQL += "BTN_VERSUB = '"+BT9->BT9_VERSUB+"' AND "
				cSQL += "BTN_CODPRO = '"+BT9->BT9_CODPRO+"' AND "
				cSQL += "BTN_VERPRO = '"+BT9->BT9_VERSAO+"' AND "
				cSQL += "BTN_CODQTD = '"+Iif(cCodQtd=='ZZZ','001',cCodQtd)+"' AND "
				cSQL += "BTN_FAIFAM = '" + BJ1->BJ1_FAIFAM + "' AND BTN_CODFOR = '"+BT9->BT9_CODFOR+ "' AND "
				cSQL += "BTN_TABVLD <= '" + cAno + cMes + "' AND D_E_L_E_T_ = ' ') "
				cSQL += "ORDER BY BTN_CODFOR, BTN_TIPUSR DESC,BTN_GRAUPA DESC ,BTN_SEXO DESC"
				PlsQuery(cSql, "TRB1")

				While !TRB1->( Eof() )
					If !lUsuario
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Transfere os valores da forma de cobranca...                        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						BBU->( RecLock("BBU", .T.) )
						For nCnt := 1 To BBU->( fCount() )
							cCampo 		:= BBU->( Field(nCnt) )

							If cCampo == "BBU_CODOPE"
								BBU->( FieldPut(nCnt, cCodInt ) )

							Elseif cCampo == "BBU_CODEMP"
								BBU->( FieldPut(nCnt, cCodEmp ) )

							Elseif cCampo == "BBU_MATRIC"
								BBU->( FieldPut(nCnt, cMatric ) )

							Elseif cCampo == "BBU_AUTOMA"
								BBU->( FieldPut(nCnt, "1") )

							Else
								cCampoBTN := "TRB1->"+StrTran(cCampo, "BBU","BTN")
								If BTN->(FieldPos(Substr(cCampoBTN,7))) > 0 .and.;
									BBU->(FieldPos(cCampo)) > 0
									BBU->( FieldPut(nCnt, &cCampoBTN) )
								Endif
							Endif
						Next
						BBU->( MsUnlock() )
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Transfere o valor de cobranca para a faixa especifica do usuario... ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Analiza faixas po tipo de usuario...                                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(TRB1->BTN_TIPUSR) .and. TRB1->BTN_TIPUSR <> BA1->BA1_TIPUSU
							TRB1->( dbSkip() )
							Loop
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Analiza faixas por grau de parentesco...                            ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(TRB1->BTN_GRAUPA) .and. TRB1->BTN_GRAUPA <> BA1->BA1_GRAUPA
							TRB1->( dbSkip() )
							Loop
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Analiza faixas por sexo...                                          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !(TRB1->BTN_SEXO $ '3, ') .and. TRB1->BTN_SEXO <> BA1->BA1_SEXO
							TRB1->( dbSkip() )
							Loop
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Ignora lixo de base de dados...                                     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (TRB1->BTN_IDAINI == 0 .and. TRB1->BTN_IDAFIN == 0) .or. TRB1->BTN_VALFAI == 0
							TRB1->( dbSkip() )
							Loop
						Endif
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Transfere os descontos dos valores da forma de cobranca...          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cSql := "SELECT * FROM "+RetSqlName("BFT")+" WHERE "
					cSql += "BFT_FILIAL = '"+xFilial("BFT") +"' AND "
					cSql += "BFT_CODIGO = '"+TRB1->BTN_CODIGO+"' AND "
					cSql += "BFT_NUMCON = '"+TRB1->BTN_NUMCON+"' AND "
					cSql += "BFT_VERCON = '"+TRB1->BTN_VERCON+"' AND "
					cSql += "BFT_SUBCON = '"+TRB1->BTN_SUBCON+"' AND "
					cSql += "BFT_VERSUB = '"+TRB1->BTN_VERSUB+"' AND "
					cSql += "BFT_CODPRO = '"+TRB1->BTN_CODPRO+"' AND "
					cSql += "BFT_VERPRO = '"+TRB1->BTN_VERPRO+"' AND "
					cSql += "BFT_CODFOR = '"+TRB1->BTN_CODFOR+"' AND "
					cSql += "BFT_CODFAI = '"+TRB1->BTN_CODFAI+"' AND "
					cSql += "D_E_L_E_T_ = ' ' "
					PlsQuery(cSql, "TRB2")

					While !TRB2->( Eof() )
						If !lUsuario
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Transfere os valores dos descontos...                               ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							BFY->( RecLock("BFY", .T.) )
							For nCnt := 1 To BFY->( fCount() )
								cCampo 		:= BFY->( Field(nCnt) )

								If cCampo == "BFY_CODOPE"
									BFY->( FieldPut(nCnt, cCodInt ) )

								Elseif cCampo == "BFY_CODEMP"
									BFY->( FieldPut(nCnt, cCodEmp ) )

								Elseif cCampo == "BFY_MATRIC"
									BFY->( FieldPut(nCnt, cMatric ) )

								Elseif cCampo == "BFY_AUTOMA"
									BFY->( FieldPut(nCnt, "1") )

								Else
									cCampoBFY := "TRB2->"+StrTran(cCampo, "BFY","BFT")
									If BFT->( FieldPos(Substr(cCampoBFY,7)) ) > 0 .and.;
										BFY->( FieldPos(cCampo) ) > 0
										BFY->( FieldPut(nCnt, &cCampoBFY) )
									Endif

								Endif
							Next
							BFT->( MsUnlock() )
						Endif
						TRB2->( dbSkip() )
					Enddo
					TRB2->( dbClosearea() )
					RestArea(aArea)
					TRB1->( dbSkip() )
				Enddo
				TRB1->( dbCloseArea() )
				RestArea(aArea)
				BT9->( dbSkip() )
			EndIf
		Enddo
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o produto da pessoa fisica... pessoa fisica e obrigatorio...   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o  produto da pessoa juridica                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lUsuario
		dbSelectarea("BI3")
		BI3->( dbSetorder(01) )
		BI3->( MsSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
	Else
		dbSelectarea("BI3")
		BI3->( dbSetorder(01) )
		BI3->( MsSeek(xFilial("BI3")+BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)))
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao encontrar o produto nao pode continuar...                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BI3->( Eof() )
		Return()
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona a forma de cobranca padrao do produto...                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BJ3->( dbSetorder(01) )
	If BJ3->( MsSeek(xFilial("BJ3")+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO) )
		While !BJ3->( Eof() ) .and. BJ3->BJ3_FILIAL+BJ3->BJ3_CODIGO+BJ3->BJ3_VERSAO ==;
			BI3->BI3_FILIAL+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO

			If BJ3->BJ3_CODFOR <> BA3->BA3_FORPAG
				BJ3->( dbSkip() )
				Loop
			Endif

			If !lUsuario
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Transfere a forma de cobranca...                        			³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("BJK", .T.)
				BJK->BJK_FILIAL := xFilial("BJK")
				BJK->BJK_CODOPE := cCodInt
				BJK->BJK_CODEMP := cCodEmp
				BJK->BJK_MATRIC := cMatric
				BJK->BJK_CODFOR := BJ3->BJ3_CODFOR
				BJK->BJK_AUTOMA := '1'
				BJK->( MsUnlock() )
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Transfere as faixas de valores...                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSql := "SELECT * FROM "+RetSqlName("BB3")+" WHERE BB3_FILIAL = '"+xFilial("BB3")+"' "
			cSql += "AND BB3_CODIGO = '"+BI3->BI3_CODINT+BI3->BI3_CODIGO+"' "
			cSql += "AND BB3_VERSAO = '"+BI3->BI3_VERSAO+"' "
			cSql += "AND BB3_CODFOR = '"+BJ3->BJ3_CODFOR+"' "
			cSql += "AND D_E_L_E_T_ = ' ' "
			PlsQuery(cSql, "TRB1")

			While !TRB1->( Eof() )
				If !lUsuario
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Transfere os valores da forma de cobranca...                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					BBU->( RecLock("BBU", .T.) )
					For nCnt := 1 To BBU->( fCount() )
						cCampo 		:= BBU->( Field(nCnt) )

						If cCampo == "BBU_CODOPE"
							BBU->( FieldPut(nCnt, cCodInt ))

						Elseif cCampo == "BBU_CODEMP"
							BBU->( FieldPut(nCnt, cCodEmp ))

						Elseif cCampo == "BBU_MATRIC"
							BBU->( FieldPut(nCnt, cMatric ))

						Elseif cCampo == "BBU_AUTOMA"
							BBU->( FieldPut(nCnt, "1") )

						Else
							cCampoBB3 := "TRB1->"+StrTran(cCampo, "BBU","BB3")
							If BB3->( FieldPos(Substr(cCampoBB3,7)) ) > 0 .and.;
									BBU->( FieldPos(cCampo) ) > 0

								BBU->( FieldPut(nCnt, &cCampoBB3) )
							Endif

						Endif
					Next
					BBU->( MsUnlock() )
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Transfere o valor de cobranca para a faixa especifica do usuario... ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Analiza faixas po tipo de usuario...                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(TRB1->BB3_TIPUSR) .and. TRB1->BB3_TIPUSR <> BA1->BA1_TIPUSU
						TRB1->( dbSkip() )
						Loop
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Analiza faixas por grau de parentesco...                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(TRB1->BB3_GRAUPA) .and. TRB1->BB3_GRAUPA <> BA1->BA1_GRAUPA
						TRB1->( dbSkip() )
						Loop
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Analiza faixas por sexo...                                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !(TRB1->BB3_SEXO $ '3, ') .and. TRB1->BB3_SEXO <> BA1->BA1_SEXO
						TRB1->( dbSkip() )
						Loop
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ignora lixo de base de dados...                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (TRB1->BB3_IDAINI == 0 .and. TRB1->BB3_IDAFIN == 0) .or. TRB1->BB3_VALFAI == 0
						TRB1->( dbSkip() )
						Loop
					Endif
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Transfere os descontos da forma de cobranca...                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cSql := "SELECT * FROM "+RetSqlName("BFS")+" WHERE BFS_FILIAL = '"+xFilial("BFS")+"' "
				cSql += "AND BFS_CODIGO = '"+TRB1->BB3_CODIGO+"' "
				cSql += "AND BFS_VERSAO = '"+TRB1->BB3_VERSAO+"' "
				cSql += "AND BFS_CODFOR = '"+TRB1->BB3_CODFOR+"' "
				cSql += "AND BFS_CODFAI = '"+TRB1->BB3_CODFAI+"' "
				cSql += "AND D_E_L_E_T_ = ' ' "
				PlsQuery(cSql, "TRB2")

				While !TRB2->( Eof() )
					If !lUsuario
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Transfere os valores dos descontos...                               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						BFY->( RecLock("BFY", .T.) )
						For nCnt := 1 To BFY->( fCount() )
							cCampo 		:= BFY->( Field(nCnt) )

							If cCampo == "BFY_CODOPE"
								BFY->( FieldPut(nCnt, cCodInt ) )

							Elseif cCampo == "BFY_CODEMP"
								BFY->( FieldPut(nCnt, cCodEmp ) )

							Elseif cCampo == "BFY_MATRIC"
								BFY->( FieldPut(nCnt, cMatric ) )

							Elseif cCampo == "BFY_AUTOMA"
								BFY->( FieldPut(nCnt, "1") )

							Else
								cCampoBFY := "TRB2->"+StrTran(cCampo, "BFY","BFS")
								If BFS->( FieldPos(SubStr(cCampoBFY,7)) ) > 0 .and.;
										BFY->( FieldPos(cCampo) ) > 0

									BFY->( FieldPut(nCnt, &cCampoBFY) )
								Endif
							Endif
						Next
						BFT->( MsUnlock() )
					Endif
					TRB2->( dbSkip() )
				Enddo
				TRB2->( dbCloseArea() )
				RestArea(aArea)
				TRB1->( dbSKip() )
			Enddo
			TRB1->( dbClosearea() )
			RestArea(aArea)
			BJ3->( dbSkip() )
		Enddo
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura posicao dos arquivos...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i := 1 To Len(aGetArea)
	dbSelectarea(aGetArea[i,1])
	dbGoto(aGetArea[i,2])
Next

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL169TXA  ºAutor  ³Geraldo Felix Juniorº Data ³  04/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Transfere a forma de cobranca da taxa de adesao do prod/subº±±
±±º          ³para a familia em seu destino.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PL169TXA(cMatricula, lJuriDes, lJuriOri,cOldMat)

Local aArea     := GetArea()
LOCAL aGetArea 	:= {}
LOCAL nCnt		:= 0
LOCAL aXconteudo:= {}
LOCAL cAno		:= Str(Year(BA3->BA3_DATBAS), 4)
LOCAL cMes 		:= StrZero(Month(BA3->BA3_DATBAS), 2)
LOCAL cCodInt 	:= Substr(cMatricula, atCodOpe[1], atCodOpe[2])
LOCAL cCodEmp 	:= Substr(cMatricula, atCodEmp[1], atCodEmp[2])
LOCAL cMatric 	:= Substr(cMatricula, atMatric[1], atMatric[2])

Aadd( aGetArea, {"BG9",BG9->( Recno() )} )
Aadd( aGetArea, {"BT5",BT5->( Recno() )} )
Aadd( aGetArea, {"BQC",BQC->( Recno() )} )
Aadd( aGetArea, {"BT6",BT6->( Recno() )} )
Aadd( aGetArea, {"BG9",BG9->( Recno() )} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Primeira situacao: Pessoa juridica !								|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lJuriDes
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o  produto da pessoa juridica                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectarea("BT6")
	BT6->( dbSetorder(01) )
	BT6->( MsSeek(xFilial("BT6")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+;
		BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO)) )

	If BT6->( Eof() )
		Return()
	Endif

	BTK->( dbSetorder(01) )
	If BTK->( MsSeek(xFilial("BTK")+BT6->BT6_CODINT+BT6->BT6_CODIGO+BT6->BT6_NUMCON+BT6->BT6_VERCON+;
		BT6->BT6_SUBCON+BT6->BT6_VERSUB+BT6->BT6_CODPRO+BT6->BT6_VERSAO) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa todas as formas de cobrancas...                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !BTK->( Eof() ) .and. (BT6->BT6_CODINT+BT6->BT6_CODIGO+BT6->BT6_NUMCON+BT6->BT6_VERCON+;
			BT6->BT6_SUBCON+BT6->BT6_VERSUB+BT6->BT6_CODPRO+BT6->BT6_VERSAO) == (BTK->BTK_CODIGO+;
			BTK->BTK_NUMCON+BTK->BTK_VERCON+BTK->BTK_SUBCON+;
			BTK->BTK_VERSUB+BTK->BTK_CODPRO+BTK->BTK_VERSAO)

			RecLock("BJL", .T.)
			BJL->BJL_FILIAL := xFilial("BJK")
			BJL->BJL_CODOPE := cCodInt
			BJL->BJL_CODEMP := cCodEmp
			BJL->BJL_MATRIC := cMatric
			BJL->BJL_CODFOR := BTK->BTK_CODFOR
			BJL->BJL_AUTOMA := '1'
			BJL->( MsUnlock() )

			cSql := "SELECT * FROM "+RetSqlName("BR6")+" WHERE BR6_FILIAL = '"+xFilial("BR6")+"' "
			cSql += "AND BR6_CODIGO = '"+BTK->BTK_CODIGO+"' "
			cSql += "AND BR6_NUMCON = '"+BTK->BTK_NUMCON+"' "
			cSql += "AND BR6_VERCON = '"+BTK->BTK_VERCON+"' "
			cSql += "AND BR6_SUBCON = '"+BTK->BTK_SUBCON+"' "
			cSql += "AND BR6_VERSUB = '"+BTK->BTK_VERSUB+"' "
			cSql += "AND BR6_CODFOR = '"+BTK->BTK_CODFOR+"' "
			cSql += "AND BR6_CODPRO = '"+BA3->BA3_CODPLA+"' "
			cSql += "AND D_E_L_E_T_  = ' '"
			PlsQuery(cSql, "TRB1")

			While !TRB1->( Eof() )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Transfere os valores da forma de cobranca...                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BRX->( RecLock("BRX", .T.) )
				For nCnt := 1 To BRX->( fCount() )
					cCampo 		:= BRX->( Field(nCnt) )

					If cCampo == "BRX_CODOPE"
						BRX->( FieldPut(nCnt, cCodInt ) )

					Elseif cCampo == "BRX_CODEMP"
						BRX->( FieldPut(nCnt, cCodEmp ) )

					Elseif cCampo == "BRX_MATRIC"
						BRX->( FieldPut(nCnt, cMatric ) )

					Elseif cCampo == "BRX_AUTOMA"
						BRX->( FieldPut(nCnt, "1") )

					Else
						cCampoBRX := "TRB1->"+StrTran(cCampo, "BRX","BR6")
						If BR6->( FieldPos(SubStr(cCampoBRX,7)) ) > 0 .and. BRX->( FieldPos(cCampo) ) > 0
							BRX->( FieldPut(nCnt, &cCampoBRX) )
						Endif
					Endif
				Next
				BRX->( MsUnlock() )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Transfere os descontos dos valores da forma de cobranca...          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cSql := "SELECT * FROM "+RetSqlName("BFV")+" WHERE "
				cSql += "BFV_FILIAL = '"+xFilial("BFV") +"' AND "
				cSql += "BFV_CODIGO = '"+TRB1->BR6_CODIGO+"' AND "
				cSql += "BFV_NUMCON = '"+TRB1->BR6_NUMCON+"' AND "
				cSql += "BFV_VERCON = '"+TRB1->BR6_VERCON+"' AND "
				cSql += "BFV_SUBCON = '"+TRB1->BR6_SUBCON+"' AND "
				cSql += "BFV_VERSUB = '"+TRB1->BR6_VERSUB+"' AND "
				cSql += "BFV_CODPRO = '"+TRB1->BR6_CODPRO+"' AND "
				cSql += "BFV_VERPRO = '"+TRB1->BR6_VERPRO+"' AND "
				cSql += "BFV_CODFOR = '"+TRB1->BR6_CODFOR+"' AND "
				cSql += "BFV_CODFAI = '"+TRB1->BR6_CODFAI+"' AND "
				cSql += "D_E_L_E_T_ = ' ' "
				PlsQuery(cSql, "TRB2")

				While !TRB2->( Eof() )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Transfere os valores dos descontos...                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					BFZ->( RecLock("BFZ", .T.) )
					For nCnt := 1 To BFZ->( fCount() )
						cCampo 		:= BFZ->( Field(nCnt) )

						If cCampo == "BFZ_CODOPE"
							BFZ->( FieldPut(nCnt, cCodInt ) )

						Elseif cCampo == "BFZ_CODEMP"
							BFZ->( FieldPut(nCnt, cCodEmp ) )

						Elseif cCampo == "BFZ_MATRIC"
							BFZ->( FieldPut(nCnt, cMatric ) )

						Elseif cCampo == "BFZ_AUTOMA"
							BFZ->( FieldPut(nCnt, "1") )

						Else
							cCampoBFZ := "TRB2->"+StrTran(cCampo, "BFZ","BFV")
							If BFV->( FieldPos(Substr(cCampoBFZ,7)) ) > 0 .and. BFZ->( FieldPos(cCampo) ) > 0
								BFZ->( FieldPut(nCnt, &cCampoBFZ) )
							Endif
						Endif
					Next
					BFZ->( MsUnlock() )
					TRB2->( dbSkip() )
				Enddo
				TRB2->( dbClosearea() )
				RestArea(aArea)
				TRB1->( dbSkip() )
			Enddo
			TRB1->( dbCloseArea() )
			RestArea(aArea)
			BTK->( dbSkip() )
		Enddo
	Endif
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o  produto da pessoa fisica... no caso de PF, eh obrigatorio...³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(M->BQQ_CODPRO)
		dbSelectarea("BI3")
		BI3->( dbSetorder(01) )
		BI3->( MsSeek(xFilial("BI3")+M->(BQQ_CODINT+BQQ_CODPRO+BQQ_VRSPRO)))
	Else
		Return() 
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao encontrar o produto nao pode continuar...                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BI3->( Eof() )
		Return()
	Endif

	BJ9->( dbSetorder(01) )
	If !BJ9->( MsSeek(xFilial("BJ9")+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO) )
		//Critica
		Return()
	Endif

	While !BJ9->( Eof() ) .and. BJ9->BJ9_CODIGO+BJ9->BJ9_VERSAO == BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO
		BJL->( RecLock("BJL", .T.) )
		BJL->BJL_FILIAL := xFilial("BJL")
		BJL->BJL_CODOPE := cCodInt
		BJL->BJL_CODEMP := cCodEmp
		BJL->BJL_MATRIC := cMatric
		BJL->BJL_CODFOR := BJ9->BJ9_CODFOR
		BJL->( MsUnlock() )

		cSql := "SELECT * FROM "+RetSqlName("BRY")+" WHERE BRY_FILIAL = '"+xFilial("BRY")+"' "
		cSql += "AND BRY_CODIGO = '"+BI3->BI3_CODINT+ BI3->BI3_CODIGO+"' "
		cSql += "AND BRY_VERSAO = '"+BI3->BI3_VERSAO+"' "
		cSql += "AND BRY_CODFOR = '"+BJ9->BJ9_CODFOR+"' "
		cSql += "AND D_E_L_E_T_ = ' ' "
		PlsQuery(cSql, "TRB1")

		While !TRB1->( Eof() )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Transfere os valores da forma de cobranca...                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BRX->( RecLock("BRX", .T.) )
			For nCnt := 1 To BRX->( fCount() )
				cCampo 		:= BRX->( Field(nCnt) )

				If cCampo == "BRX_CODOPE"
					BRX->( FieldPut(nCnt, cCodInt ) )

				Elseif cCampo == "BRX_CODEMP"
					BRX->( FieldPut(nCnt, cCodEmp ) )

				Elseif cCampo == "BRX_MATRIC"
					BRX->( FieldPut(nCnt, cMatric ) )

				Elseif cCampo == "BRX_AUTOMA"
					BRX->( FieldPut(nCnt, "1") )

				Else
					cCampoBRX := "TRB1->"+StrTran(cCampo, "BRX","BRY")
					If BRY->( FieldPos(SubStr(cCampoBRX,7)) ) > 0 .and. BRX->( FieldPos(cCampo) ) > 0
						BRX->( FieldPut(nCnt, &cCampoBRX) )
					Endif
				Endif
			Next
			BRX->( MsUnlock() )

			cSql := "SELECT * FROM "+RetSqlName("BFX")+" WHERE BFX_FILIAL = '"+xFilial("BFX")+"' "
			cSql += "AND BFX_CODIGO = '"+BI3->BI3_CODINT+BI3->BI3_CODIGO+"' "
			cSql += "AND BFX_VERSAO = '"+BI3->BI3_VERSAO+"' "
			cSql += "AND BFX_CODFOR = '"+BJ9->BJ9_CODFOR+"' "
			cSql += "AND D_E_L_E_T_ = ' ' "
			PlsQuery(cSql, "TRB2")

			While !TRB2->( Eof() )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Transfere os valores dos descontos...                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BFZ->( RecLock("BFZ", .T.) )
					For nCnt := 1 To BFZ->( fCount() )
						cCampo 		:= BFZ->( Field(nCnt) )

						If cCampo == "BFZ_CODOPE"
							BFZ->( FieldPut(nCnt, cCodInt ) )

						Elseif cCampo == "BFZ_CODEMP"
							BFZ->( FieldPut(nCnt, cCodEmp ) )

						Elseif cCampo == "BFZ_MATRIC"
							BFZ->( FieldPut(nCnt, cMatric ) )

						Elseif cCampo == "BFZ_AUTOMA"
							BFZ->( FieldPut(nCnt, "1") )

						Else
							cCampoBFZ := "TRB2->"+StrTran(cCampo, "BFZ","BFX")
							If BFX->( FieldPos(Substr(cCampoBFZ,7)) ) > 0 .and. BFZ->( FieldPos(cCampo) ) > 0
								BFZ->( FieldPut(nCnt, &cCampoBFZ) )
							Endif
						Endif
					Next
				BFZ->( MsUnlock() )
				TRB2->( dbSkip() )
			Enddo
			TRB2->( dbClosearea() )
			RestArea(aArea)
			TRB1->( dbSkip() )
		Enddo
		TRB1->( dbClosearea() )
		RestArea(aArea)
		BJ9->( dbSkip() )
	Enddo
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL169OPC  ºAutor  ³Geraldo Felix Juniorº Data ³  03/18/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Transfere os opcionais vinculados ou nao para a familia/usr.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Plano de Saude                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PL169OPC(cMatricula,lJuriDes,lJuriOri,lFamilia,cOldMat,cOldUsr,cTipReg)

//	lFamilia = .T. = Familias
//	lFamilia = .F. = Usuarios

LOCAL nCnt := 0
LOCAL cCodInt := Substr(cMatricula, atCodOpe[1], atCodOpe[2])
LOCAL cCodEmp := Substr(cMatricula, atCodEmp[1], atCodEmp[2])
LOCAL cMatric := Substr(cMatricula, atMatric[1], atMatric[2])
LOCAL nIfOpc := 0
LOCAL aStruOpc := {}
LOCAL cSql := ""
Local cCodOpc := ""
Local cTpReg := ""
Local lAtu:=.T.
Local lPl169Opc := ExistBlock("PL169OPC")

DEFAULT cTipReg := BA1->BA1_TIPREG

IF VALTYPE(M->BQQ_IMPOPC) == "U"	//	O BQQ_IMPOPC é Virtual e o FIELDPOS não funcionaria aqui
	//	Para manter o Legado o Parâmetro MV_PLAUTOP, está no Inicializador Padrão do campo
	//	mas se ele não existir no Dicionário, será criado a variável
	M->BQQ_IMPOPC := STR(GetNewPar("MV_PLAUTOP", 1), 1)
ENDIF

/*----------------------------------------------------------------------------------------------------------
Faço uma busca para ver se a familia nova deste beneficiario possui um opcional vinculado ao subcontrato.
------------------------------------------------------------------------------------------------------------*/
IF !EMPTY(M->BQQ_FAMDES)
	if Select("TRBOPC") > 0
		TRBOPC->(DbCloseArea())
	endif
	cSql := "SELECT BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB, BA3_CODPLA, BA1_TIPREG, BHS.* "
	cSql +=  " FROM " + RetSqlName('BA3') + " BA3, " + RetSqlName('BA1') + " BA1, " + RetSqlName('BHS') + " BHS "
	cSql += " WHERE BA3_MATRIC = '" + M->BQQ_FAMDES + "'"
	cSql +=   " AND BA1_MATRIC = '" + M->BQQ_FAMDES + "'"
	cSql +=   " AND BA3_FILIAL = '" + xFilial('BA3') + "'"
	cSql +=   " AND BA1_FILIAL = '" + xFilial('BA1') + "'"
	cSql +=   " AND BHS_FILIAL = '" + xFilial('BHS') + "'"
	cSql +=   " AND BA3_CODINT = '" + cCodInt + "'"
	cSql +=   " AND BA3_CODEMP = '" + cCodEmp + "'"
	cSql +=   " AND BA3_CODINT = BA1_CODINT "
	cSql +=   " AND BA3_CODEMP = BA1_CODEMP "
	cSql +=   " AND BHS_NUMCON = BA3_CONEMP "
	cSql +=   " AND BA3_CODPLA = BHS_CODPRO "
	cSql +=   " AND BHS_SUBCON = BA3_SUBCON "
	cSql +=   " AND BA1.D_E_L_E_T_ = ' ' "
	cSql +=   " AND BA3.D_E_L_E_T_ = ' ' "
	cSql +=   " AND BHS.D_E_L_E_T_ = ' ' "
	cSql +=   " AND BHS_TIPVIN = '1' "
	cSql += " ORDER BY BHS_CODPLA, BA1_TIPREG DESC "
	PlsQuery(cSql, "TRBOPC")
	cTpReg := TRBOPC->BA1_TIPREG
	//Caso não tenha nenhum opcional vinculado não adiciono.
	While !TRBOPC->(EOF())
		//Apenas adiciono para o ultimo beneficiario, ou seja o que está sendo transferido no momento.
		If !(TRBOPC->BHS_CODPLA == cCodOpc .OR. cTpReg <> TRBOPC->BA1_TIPREG)
			
			cCodOpc := TRBOPC->BHS_CODPLA
			RecLock("BF4", .T.)
			BF4->BF4_FILIAL := xFilial('BF4')
			BF4->BF4_CODINT := cCodInt
			BF4->BF4_CODEMP := cCodEmp
			BF4->BF4_MATRIC := cMatric
			BF4->BF4_CODPRO := TRBOPC->BHS_CODPLA
			BF4->BF4_VERSAO := TRBOPC->BHS_VERPRO
			BF4->BF4_TIPREG := TRBOPC->BA1_TIPREG
			BF4->BF4_DATBAS := M->BQQ_DATINC
			BF4->BF4_TIPVIN := TRBOPC->BHS_TIPVIN
			MsUnlock()
		ENDIF
		TRBOPC->(dbSkip())
	EndDo
	TRBOPC->(DbCloseArea())
ENDIF

//	Campo "Imp.Opcional", BQQ_IMPOPC pode ser:
//	"0"	//	Não Importa nada
//	"1"	//	Traz tudo do Contrato (Mantendo Legado)
//	"2"	//	Traz só os Vinculados (Novo)
IF M->BQQ_IMPOPC <> "0"	//	Importa Opcionais
	If lJuriDes
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o  produto da pessoa juridica                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectarea("BT6")
		BT6->( dbSetorder(01) )
		BT6->( MsSeek(xFilial("BT6")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+;
		BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO)) )
		
		If BT6->( Eof() )
			Return()
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona os opcionais do subcontrato...                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BHS->( dbSetorder(01) )
		cKeyBHS := BT6->BT6_CODINT+BT6->BT6_CODIGO+BT6->BT6_NUMCON+BT6->BT6_VERCON+BT6->BT6_SUBCON+BT6->BT6_VERSUB+;
		BT6->BT6_CODPRO+BT6->BT6_VERSAO
		
		If BHS->( MsSeek(xFilial("BHS")+cKeyBHS) )
			While !BHS->( Eof() ) .and. BHS->(BHS_CODINT+BHS_CODIGO+BHS_NUMCON+BHS_VERCON+BHS_SUBCON+BHS_VERSUB+;
				BHS_CODPRO+BHS_VERPRO) == cKeyBHS
				
				//	Importa Tudo OU Só os Vinculados no Contrato/Plano
				IF M->BQQ_IMPOPC == "1" .OR. (M->BQQ_IMPOPC == "2" .AND. BHS->BHS_TIPVIN == "1")
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Adiciona o opcional... vinculados ou nao! A diferenca e que o vinculado vem com valor zerado!     |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lFamilia
						RecLock("BF1", .T.)
						BF1->BF1_FILIAL := xFilial("BF1")
						BF1->BF1_CODINT := cCodInt
						BF1->BF1_CODEMP := cCodEmp
						BF1->BF1_MATRIC := cMatric
						BF1->BF1_CODPRO := BHS->BHS_CODPLA
						BF1->BF1_VERSAO := BHS->BHS_VERPLA
						BF1->BF1_DATBAS := BA3->BA3_DATBAS
						If BF1->(FieldPos("BF1_TIPVIN")) > 0
							BF1->BF1_TIPVIN := BHS->BHS_TIPVIN
						Endif
						MsUnlock()
					Else	//	Usuário
						lTrazOpc := PLSPerm(	BA1->BA1_TIPUSU, BA1->BA1_GRAUPA, BA1->BA1_ESTCIV, BA1->BA1_SEXO, Nil, BA3->BA3_CODINT, BHS->BHS_CODPLA, BHS->BHS_VERPLA, BA1->BA1_DATINC, BA1->BA1_DATNAS, Nil, Nil, Nil, Nil, Nil, lJuriDes)
						If lTrazOpc
						
							BF4->(DbSetOrder(1))//BF4_FILIAL+BF4_CODINT+BF4_CODEMP+BF4_MATRIC+BF4_TIPREG+BF4_CODPRO
							If BF4->(MsSeek(xFilial("BF4")+ cCodInt + cCodEmp + cMatric + cTipReg )) //BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
								lAtu:=.F.
							Endif

							If lAtu
								RecLock("BF4", .T.)
								BF4->BF4_FILIAL := xFilial("BF4")
								BF4->BF4_CODINT := cCodInt
								BF4->BF4_CODEMP := cCodEmp
								BF4->BF4_MATRIC := cMatric
								BF4->BF4_CODPRO := BHS->BHS_CODPLA
								BF4->BF4_VERSAO := BHS->BHS_VERPLA
								If BQQ->(FieldPos("BQQ_INCORI")) > 0
									If  M->BQQ_INCORI == '0'  // nao mantem a data de inclusao
										BF4->BF4_DATBAS := M->BQQ_DATINC
									Else
										BF4->BF4_DATBAS := BA1->BA1_DATINC
									Endif
								Else
									BF4->BF4_DATBAS := BA1->BA1_DATINC
								Endif
								BF4->BF4_TIPREG := cTipReg
								If BF4->( FieldPos("BF4_TIPVIN") ) > 0
									BF4->BF4_TIPVIN := BHS->BHS_TIPVIN
								Endif
								aAdd(aStruOpc,{ALLTRIM(BHS->BHS_CODPLA),.T.})
								MsUnlock()
							Endif
						Else
							aAdd(aStruOpc,{ALLTRIM(BHS->BHS_CODPLA),.F.})
						Endif
						
						//	Transfere Documentos Obrigatórios do Usuário Origem
						PL169DOCOBR(cGlobalKey, cMatric, cTipReg)
					Endif
					
					If lPl169Opc
						ExecBlock("PL169OPC", .F., .F., {lFamilia, cOldMat, cCodInt, cCodEmp, cMatric, cOldUsr})
					Endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Para opcionais nao vinculados, levo tbm as formas de cobranca...         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If BHS->BHS_TIPVIN == '0'
						BJW->( dbSetorder(01) )
						
						cKeyBJW := BHS->(BHS_CODINT+BHS_CODIGO+BHS_NUMCON+BHS_VERCON+BHS_SUBCON+BHS_VERSUB)+;
						BHS->(BHS_CODPRO+BHS_VERPRO+BHS_CODPLA+BHS_VERPLA)
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Forma de cobranca do opcional...                                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If BJW->( MsSeek(xFilial("BJW")+cKeyBJW) )
							While !BJW->( Eof() ) .and. BJW->(BJW_CODIGO+BJW_NUMCON+BJW_VERCON+BJW_SUBCON+BJW_VERSUB)+;
								BJW->(BJW_CODPRO+BJW_VERSAO+BJW_CODOPC+BJW_VEROPC) == cKeyBJW
								If lFamilia
									RecLock("BK0", .T.)
									BK0->BK0_FILIAL := xFilial("BK0")
									BK0->BK0_CODOPE := cCodInt
									BK0->BK0_CODEMP := cCodEmp
									BK0->BK0_MATRIC := cMatric
									BK0->BK0_CODOPC := BJW->BJW_CODOPC
									BK0->BK0_VEROPC := BJW->BJW_VEROPC
									BK0->BK0_CODFOR := BJW->BJW_CODFOR
									MsUnlock()
								Else
									nIfOpc := aScan(aStruOpc, {|x| x[1] == BJW->BJW_CODOPC})
									If nIfOpc > 0 .And. aStruOpc[nIfOpc, 2] .And. BHS->BHS_TIPVIN == "0"
										RecLock("BYX", .T.)
										BYX->BYX_FILIAL := xFilial("BYX")
										BYX->BYX_CODOPE := cCodInt
										BYX->BYX_CODEMP := cCodEmp
										BYX->BYX_MATRIC := cMatric
										BYX->BYX_CODOPC := BJW->BJW_CODOPC
										BYX->BYX_VEROPC := BJW->BJW_VEROPC
										BYX->BYX_CODFOR := BJW->BJW_CODFOR
										BYX->BYX_TIPREG := cTipReg
										BYX->BYX_RGIMP  := '1'
										MsUnlock()
									Endif
								Endif
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Pega a faixa de acordo com a quantidade usuarios na empresa.             ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cCodQtd := '001'
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Monta chave dos valores dos opcionais...                                 ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ??ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lFamilia
									cKeyBBX := xFilial("BBX")+ 	BA3->BA3_CODINT + BA3->BA3_CODEMP + BA3->BA3_CONEMP +;
									BA3->BA3_VERCON + BA3->BA3_SUBCON + BA3->BA3_VERSUB +;
									BA3->BA3_CODPLA + BA3->BA3_VERSAO + BK0->BK0_CODOPC +;
									BK0->BK0_VEROPC + BK0->BK0_CODFOR + Iif(cCodQtd=='ZZZ','001',cCodQtd)
								Else
									cKeyBBX := xFilial("BBX")+ 	BA3->BA3_CODINT + cCodEmp + BA3->BA3_CONEMP +;
									BA3->BA3_VERCON + BA3->BA3_SUBCON + BA3->BA3_VERSUB +;
									BA3->BA3_CODPLA + BA3->BA3_VERSAO + BYX->BYX_CODOPC +;
									BYX->BYX_VEROPC + BYX->BYX_CODFOR + Iif(cCodQtd=='ZZZ','001',cCodQtd)
								Endif
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Posiciona valores...                                                     ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								BBX->(DbSetOrder(1))
								If BBX->(MsSeek(cKeyBBX))
									While ! BBX->(Eof()) .And. BBX->BBX_FILIAL+BBX->BBX_CODIGO+BBX->BBX_NUMCON+BBX->BBX_VERCON+BBX->BBX_SUBCON+;
										BBX->BBX_VERSUB+BBX->BBX_CODPRO+BBX->BBX_VERPRO+BBX->BBX_CODOPC+BBX->BBX_VEROPC+;
										BBX->BBX_CODFOR+BBX->BBX_CODQTD == cKeyBBX
										If lFamilia
											
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Transfere os valores da forma de cobranca...                        ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											RecLock("BBY", .T.)
											For nCnt := 1 To BBY->( fCount() )
												cCampo := BBY->( Field(nCnt) )
												If     cCampo == "BBY_CODOPE"
													BBY->( FieldPut(nCnt, cCodInt ) )
												Elseif cCampo == "BBY_CODEMP"
													BBY->( FieldPut(nCnt, cCodEmp ) )
												Elseif cCampo == "BBY_MATRIC"
													BBY->( FieldPut(nCnt, cMatric ) )
												Elseif cCampo == "BBY_AUTOMA"
													BBY->( FieldPut(nCnt, "1") )
												Else
													cCampoBBY := "BBX->"+StrTran(cCampo, "BBY","BBX")
													If BBX->( FieldPos(SubStr(cCampoBBY,6)) ) > 0 .and.;
														BBY->( FieldPos(cCampo) ) > 0
														BBY->( FieldPut(nCnt, &cCampoBBY) )
													Endif
												Endif
											Next
											MsUnlock()
										Else
											
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Transfere os valores da forma de cobranca...                        ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											nIfOpc := aScan(aStruOpc, {|x| x[1] == BBX->BBX_CODOPC})
											If nIfOpc > 0 .And. aStruOpc[nIfOpc, 2] .And. BHS->BHS_TIPVIN == "0"
												RecLock("BZX", .T.)
												For nCnt := 1 To BZX->( fCount() )
													cCampo := BZX->( Field(nCnt) )
													If     cCampo == "BZX_CODOPE"
														BZX->( FieldPut(nCnt, cCodInt ) )
													Elseif cCampo == "BZX_CODEMP"
														BZX->( FieldPut(nCnt, cCodEmp ) )
													Elseif cCampo == "BZX_MATRIC"
														BZX->( FieldPut(nCnt, cMatric ) )
													Elseif cCampo == "BZX_AUTOMA"
														BZX->( FieldPut(nCnt, "1") )
													Elseif cCampo == "BZX_TIPREG"
														BZX->BZX_TIPREG :=  cTipReg
													Elseif cCampo == "BZX_RGIMP"
														BZX->BZX_RGIMP  :=  '1'
													Else
														cCampoBZX := "BBX->"+StrTran(cCampo, "BZX","BBX")
														If BBX->( FieldPos(SubStr(cCampoBZX,6)) ) > 0 .and. BZX->( FieldPos(cCampo) ) > 0
															BZX->( FieldPut(nCnt, &cCampoBZX) )
														Endif
													Endif
												Next
												MsUnlock()
											Endif
										Endif
										BBX->( dbSkip() )
									Enddo
								Endif
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Transfere os valores dos descontos...                               ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								BJW->( dbSkip() )
							Enddo
						Endif
					Endif
				ENDIF
				BHS->( dbSkip() )
			Enddo
		Endif
	Else
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o  produto da pessoa fisica... no caso de PF, eh obrigatorio...³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(M->BQQ_CODPRO)
			dbSelectarea("BI3")
			BI3->( dbSetorder(01) )
			BI3->( MsSeek(xFilial("BI3")+M->(BQQ_CODINT+BQQ_CODPRO+BQQ_VRSPRO)))
		Else
			Return()
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao encontrar o produto nao pode continuar...                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If BI3->( Eof() )
			Return()
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona os opcionais do do produto...                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BT3->( dbSetorder(01) )
		cKeyBT3 := BI3->(BI3_CODINT + BI3_CODIGO + BI3_VERSAO)
		
		If BT3->( MsSeek(xFilial("BT3")+cKeyBT3) )
			While !BT3->( Eof() ) .and. BT3->(BT3_CODIGO+BT3_VERSAO) == cKeyBT3
				
				//	Importa Tudo OU Só os Vinculados no Contrato/Plano
				IF M->BQQ_IMPOPC == "1" .OR. (M->BQQ_IMPOPC == "2" .AND. BT3->BT3_TIPVIN == "1")
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Adiciona o opcional... vinculados ou nao! A diferenca e que o vinculado vem com valor zerado!     |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lFamilia
						RecLock("BF1", .T.)
						BF1->BF1_FILIAL := xFilial("BF1")
						BF1->BF1_CODINT := cCodInt
						BF1->BF1_CODEMP := cCodEmp
						BF1->BF1_MATRIC := cMatric
						BF1->BF1_CODPRO := BT3->BT3_CODPLA
						BF1->BF1_VERSAO := BT3->BT3_VERPLA
						BF1->BF1_DATBAS := BA3->BA3_DATBAS
						If BF1->(FieldPos("BF1_TIPVIN")) > 0
							BF1->BF1_TIPVIN := BT3->BT3_TIPVIN
						Endif
						MsUnlock()
					Else
						lTrazOpc := PLSPerm(BA1->BA1_TIPUSU, BA1->BA1_GRAUPA, BA1->BA1_ESTCIV, BA1->BA1_SEXO, Nil, BA3->BA3_CODINT, BT3->BT3_CODPLA, BT3->BT3_VERPLA, BA1->BA1_DATINC, BA1->BA1_DATNAS, Nil, Nil, Nil, Nil, Nil, lJuriDes)
						If lTrazOpc
							RecLock("BF4", .T.)
							BF4->BF4_FILIAL := xFilial("BF4")
							BF4->BF4_CODINT := cCodInt
							BF4->BF4_CODEMP := cCodEmp
							BF4->BF4_MATRIC := cMatric
							BF4->BF4_CODPRO := BT3->BT3_CODPLA
							BF4->BF4_VERSAO := BT3->BT3_VERPLA
							If BQQ->(FieldPos("BQQ_INCORI")) > 0
								If  M->BQQ_INCORI == '0'  // nao mantem a data de inclusao
									BF4->BF4_DATBAS := M->BQQ_DATINC
								Else
									BF4->BF4_DATBAS := BA1->BA1_DATINC
								Endif
							Else
								BF4->BF4_DATBAS := BA1->BA1_DATINC
							Endif
							BF4->BF4_TIPREG := cTipReg
							If BF4->( FieldPos("BF4_TIPVIN") ) > 0
								BF4->BF4_TIPVIN := BT3->BT3_TIPVIN
							Endif
							aAdd(aStruOpc,{ALLTRIM(BT3->BT3_CODPLA),.T.})
							msUnlock()
						Else
							aAdd(aStruOpc,{ALLTRIM(BT3->BT3_CODPLA),.F.})
						Endif
					Endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Para opcionais nao vinculados, levo tbm asformas de cobranca...          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If BT3->BT3_TIPVIN == '0'
						BJY->( dbSetorder(01) )
						
						cKeyBJY := BT3->(BT3_CODIGO+BT3_VERSAO+BT3_CODPLA+BT3_VERPLA)
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Forma de cobranca do opcional...                                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If BJY->( MsSeek(xFilial("BJY")+cKeyBJY) )
							While !BJY->( Eof() ) .and. BJY->(BJY_CODIGO+BJY_VERSAO+BJY_CODOPC+BJY_VEROPC) == cKeyBJY
								
								If lFamilia
									RecLock("BK0", .T.)
									BK0->BK0_FILIAL := xFilial("BK0")
									BK0->BK0_CODOPE := cCodInt
									BK0->BK0_CODEMP := cCodEmp
									BK0->BK0_MATRIC := cMatric
									BK0->BK0_CODOPC := BJY->BJY_CODOPC
									BK0->BK0_VEROPC := BJY->BJY_VEROPC
									BK0->BK0_CODFOR := BJY->BJY_CODFOR
									MsUnlock()
								Else
									nIfOpc := aScan(aStruOpc, {|x| x[1] == BJY->BJY_CODOPC})
									If nIfOpc > 0 .And. aStruOpc[nIfOpc, 2] .And. BT3->BT3_TIPVIN == "0"
										RecLock("BYX", .T.)
										BYX->BYX_FILIAL := xFilial("BYX")
										BYX->BYX_CODOPE := cCodInt
										BYX->BYX_CODEMP := cCodEmp
										BYX->BYX_MATRIC := cMatric
										BYX->BYX_CODOPC := BJY->BJY_CODOPC
										BYX->BYX_VEROPC := BJY->BJY_VEROPC
										BYX->BYX_CODFOR := BJY->BJY_CODFOR
										BYX->BYX_TIPREG := cTipReg
										BYX->BYX_RGIMP  := '1'
										MsUnlock()
									Endif
								Endif
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Monta chave dos valores dos opcionais...                                 ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lFamilia
									cKeyBBV := xFilial("BBV")+ 	BA3->BA3_CODINT + BA3->BA3_CODPLA + BA3->BA3_VERSAO + ;
									BK0->BK0_CODOPC + BK0->BK0_VEROPC + BK0->BK0_CODFOR
								Else
									cKeyBBV := xFilial("BBV")+ 	BA1->BA1_CODINT + BA3->BA3_CODPLA + BA3->BA3_VERSAO + ;
									BYX->BYX_CODOPC + BYX->BYX_VEROPC + BYX->BYX_CODFOR
								Endif
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Posiciona valores...                                                     ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								BBV->(DbSetOrder(1))
								BBV->(MsSeek(cKeyBBV))
								While !BBV->(Eof()) .and.	BBV->BBV_FILIAL+BBV->BBV_CODIGO+BBV->BBV_VERSAO+BBV->BBV_CODOPC+;
									BBV->BBV_VEROPC+BBV->BBV_CODFOR == cKeyBBV
									If lFamilia
										
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Transfere os valores da forma de cobranca...                        ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										RecLock("BBY", .T.)
										For nCnt := 1 To BBY->( fCount() )
											cCampo := BBY->( Field(nCnt) )
											
											If     cCampo == "BBY_CODOPE"
												BBY->( FieldPut(nCnt, cCodInt ) )
												
											Elseif cCampo == "BBY_CODEMP"
												BBY->( FieldPut(nCnt, cCodEmp ) )
												
											Elseif cCampo == "BBY_MATRIC"
												BBY->( FieldPut(nCnt, cMatric ) )
												
											Elseif cCampo == "BBY_AUTOMA"
												BBY->( FieldPut(nCnt, "1") )
												
											Else
												cCampoBBY := "BBV->"+StrTran(cCampo, "BBY","BBV")
												If BBV->( FieldPos(Substr(cCampoBBY,6)) ) > 0 .and. BBY->( FieldPos(cCampo) ) > 0
													BBY->( FieldPut(nCnt, &cCampoBBY) )
												Endif
											Endif
										Next
										MsUnlock()
									Else
										
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Transfere os valores da forma de cobranca...                        ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										nIfOpc := aScan(aStruOpc, {|x| x[1] == BBV->BBV_CODOPC})
										If nIfOpc > 0 .And. aStruOpc[nIfOpc, 2] .And. BT3->BT3_TIPVIN == "0"
											RecLock("BZX", .T.)
											For nCnt := 1 To BZX->( fCount() )
												cCampo := BZX->( Field(nCnt) )
												
												If     cCampo == "BZX_CODOPE"
													BZX->( FieldPut(nCnt, cCodInt ) )
													
												Elseif cCampo == "BZX_CODEMP"
													BZX->( FieldPut(nCnt, cCodEmp ) )
													
												Elseif cCampo == "BZX_MATRIC"
													BZX->( FieldPut(nCnt, cMatric ) )
													
												Elseif cCampo == "BZX_AUTOMA"
													BZX->( FieldPut(nCnt, "1") )
													
												Elseif cCampo == "BZX_TIPREG"
													BZX->BZX_TIPREG :=  cTipReg
													
												Elseif cCampo == "BZX_RGIMP"
													BZX->BZX_RGIMP  :=  '1'
													
												Else
													cCampoBZX := "BBV->"+StrTran(cCampo, "BZX","BBV")
													If BBV->( FieldPos(SubStr(cCampoBZX,6)) ) > 0 .and. BZX->( FieldPos(cCampo) ) > 0
														BZX->( FieldPut(nCnt, &cCampoBZX) )
													Endif
												Endif
											Next
											MsUnlock()
										Endif
									Endif
									BBV->( dbSkip() )
								Enddo
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Transfere os valores dos descontos...                               ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								BJY->( dbSkip() )
							Enddo
						Endif
					Endif
				Endif
				BT3->( dbSkip() )
			Enddo
		Endif
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL169REGUAºAutor  ³Geraldo Felix Juniorº Data ³  03/18/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtem a quantidade registros a serem processados pela regua º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PL169REGUA()

LOCAL cSql 		:= ''
LOCAL nRegua 	:= 0
Local aArea     := GetArea()

cSql := "SELECT Count(*) AS TOTAL FROM "+RetSqlName('BA1')+" WHERE BA1_CODINT = '"+M->BQQ_CODINT+"' "
cSql += "AND BA1_CODEMP = '"+M->BQQ_EMPORI+"' AND BA1_DATBLO = '"+SPACE(LEN(dTos(BA1->BA1_DATBLO)))+"' "
If !Empty(M->BQQ_CONORI)
	cSql += "AND BA1_CONEMP = '"+M->BQQ_CONORI+"' AND BA1_VERCON = '"+M->BQQ_VCOORI+"' "
Endif
If !Empty(M->BQQ_SUBORI)
	cSql += "AND BA1_SUBCON = '"+M->BQQ_SUBORI+"' AND BA1_VERSUB = '"+M->BQQ_VRSORI+"' "
Endif
If !Empty(M->BQQ_FAMORI)
	cSql += " AND BA1_MATRIC = '"+M->BQQ_FAMORI+"' "
Endif
If !Empty(M->BQQ_USUARI)
	cSql += "AND BA1_TIPREG LIKE '%["+Alltrim(M->BQQ_USUARI)+"]%' "
Endif
cSql += " AND "+RetSqlName("BA1")+".D_E_L_E_T_ = ' ' "
PlsQuery(cSql,"TRB1")
nRegua := TRB1->TOTAL
TRB1->( dbClosearea() )
RestArea(aArea)

Return(nRegua)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL169HIST ºAutor  ³Alexander Santos    º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mostra o Log de Transferencia do Usario (BA1) POSICIONADO   º±±
±±º          ³			                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Esta funcao vai selecionar todo o historico de transferenciaº±±
±±º          ³da tabela BA1 mostrando os campos BA1_DATTRA,BA1_TRADES,    º±±
±±º          ³BA1_TRAORI independente da posicao do registro na tabela.   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PL169HIST(lDireto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva posicao das tabelas                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nRegBA1 := BA1->(Recno())
Local nOrdBA1 := BA1->(IndexOrd())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aLog	     := {}
Local cTitTela
Local cMat

DEFAULT lDireto := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz uma mudanca de ordem para procura da matricula                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA1->(DbSetOrder(2)) // BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Titulo da Tela									                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitTela := BA1->BA1_CODINT+'.'+BA1->BA1_CODEMP+'.'+BA1->BA1_MATRIC+'-'+BA1->BA1_TIPREG+' - '+BA1->BA1_NOMUSR

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavel para procura da matricula com os registro de DESTINO            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMatDes := BA1->BA1_TRADES

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona o Registro na matriz de acordo com a matricula corrente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aLog, {BA1->BA1_DATTRA,BA1->BA1_CODINT+'.'+BA1->BA1_CODEMP+'.'+BA1->BA1_MATRIC+'.'+BA1->BA1_TIPREG+'-'+BA1->BA1_DIGITO,TransForm(BA1->BA1_TRAORI,"@R XXXX.XXXX.XXXXXX.XX-X"),TransForm(BA1->BA1_TRADES,"@R XXXX.XXXX.XXXXXX.XX-X"),BA1->(RecNo()) })
lContinua := .T.
While lContinua

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Acrescenta registros na matriz procurando a matricula pelo campo BA1_TRAORI ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMat := BA1->BA1_TRAORI
	If  !Empty(cMat) .and. BA1->(MsSeek(xFilial("BA1")+cMat))
		Aadd(aLog, {BA1->BA1_DATTRA,BA1->BA1_CODINT+'.'+BA1->BA1_CODEMP+'.'+BA1->BA1_MATRIC+'.'+BA1->BA1_TIPREG+'-'+BA1->BA1_DIGITO,TransForm(BA1->BA1_TRAORI,"@R XXXX.XXXX.XXXXXX.XX-X"),TransForm(BA1->BA1_TRADES,"@R XXXX.XXXX.XXXXXX.XX-X"),BA1->(RecNo()) })
	Else

	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³Acrescenta o restante dos registros procurando a  ³
	   //³matricula pelo campo BA1_TRADES 				    ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While lContinua
			If  !Empty(cMatDes) .and. BA1->(MsSeek(xFilial("BA1")+cMatDes))
				cMatDes := BA1->BA1_TRADES
				Aadd(aLog, {BA1->BA1_DATTRA,BA1->BA1_CODINT+'.'+BA1->BA1_CODEMP+'.'+BA1->BA1_MATRIC+'.'+BA1->BA1_TIPREG+'-'+BA1->BA1_DIGITO,TransForm(BA1->BA1_TRAORI,"@R XXXX.XXXX.XXXXXX.XX-X"),TransForm(BA1->BA1_TRADES,"@R XXXX.XXXX.XXXXXX.XX-X"),BA1->(RecNo()) })
			Else
				lContinua := .F.
			Endif
		Enddo
	Endif
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordena a Matriz por data				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aLog := aSort(aLog,,, { |x, y| x[1] < y[1] })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a tela com os dados da Matriz aLOG³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ! lDireto
	If  ExistBlock("PL169HIS")
		ExecBlock("PL169HIS",.f.,.f.,aLog)
	Else
		PLSCRIGEN(aLog,{ {STR0067,"@D", 60 },{STR0024,"@C", 70 },{STR0068,"@C", 70 },{STR0069,"@C", 70 },{STR0070,"@C", 60 } },STR0071+cTitTela) //"Data Transferência"###"Matricula"###"Matricula Origem"###"Matricula Destino"###"Num. Registro"###" Histórico de Transferência -> "
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura posicao das tabelas                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA1->(dbSetOrder(nOrdBA1))
BA1->(dbGoTo(nRegBA1))

Return(aLog)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS260Usr  ³ Autor ³ Geraldo Felix Junior³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula o proximo tipo de registro de cada usuario .       |±±
±±³          ³ Na transferencia entre familias...                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 24.09.02 ³      ³ Tulio Cesar ³ Nao permitir duplicidade de TIPREG    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL169TipRg(cGrauPa,cTipReg,cTipUsu,cMatFam)

LOCAL cSeqIni := "00"
LOCAL cSeqFim := "00"
LOCAL cSeq    := cTipReg
LOCAL lRet    := .T.
LOCAL lExitFor:= .F.
LOCAL nInd    := 1
LOCAL aTipReg := {}
LOCAL nCnt    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro que indica qual o modelo a ser utilizado pela Instituicao de saude  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cModelo := GetMv("MV_PLTITCD")
LOCAL nRecBa1 := BA1->( Recno() )

If cModelo == "1"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico se o grau de parentesco pesquisado, possui sequencia inicial e final ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cGrauPa)
		BA1->( dbGoto(nRecBa1) )
		Return({cSeq,lRet})
	Endif

	If Empty(cMatFam)
		BA1->( dbGoto(nRecBa1) )
		Return({cSeq,lRet})
	Endif

	BT2->(DBSetOrder(1))
	lRet := BT2->(MsSeek(xFilial("BT2")+cGrauPa))

	If lRet
		cSeqIni := BT2->BT2_SEQDE  //00
		cSeqFim := BT2->BT2_SEQATE   //00
		cSeq    := cSeqIni

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o usuario para montar o tipo de registro no novo dependente...                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BA1->( dbSetorder(02) )
		If !BA1->( dbSeek(xFilial("BA1")+cMatFam) )
			BA1->( dbGoto(nRecBa1) )
			Return({cSeq,lRet})
		Endif

		// Carrega matriz com dados para comparacao.
		BA1->( dbEval({|| Aadd(aTipReg, {BA1->BA1_GRAUPA, BA1->BA1_TIPREG}) },,{|| BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == cMatFam}) )

		For nCnt := 1 To Len(aTipReg)
			If cGrauPa == aTipReg[nCnt, 1]
				cSeq := StrZero((Val(cSeq)+1),2)
				While .T.
					If Ascan(aTipReg,{ |x| x[2] == cSeq }) > 0
						cSeq := StrZero((Val(cSeq)+1),2)
					Else
						lExitFor := .T.
						Exit
					Endif
				Enddo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Mostro o assistente caso a quantidade de grau de parentesco ultrapasse a quantidade  |
				//³ permitida no cadastro                                                                |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cSeq > cSeqFim
					lRet := .F.
					//					  Criticar
					BA1->( dbGoto(nRecBa1) )
					Return({cSeq,lRet})
				Endif
				If lExitFor
					Exit
				Endif
			Endif
		Next
	Endif
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico as parametrizacoes para o cada tipo de usuario             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BF2->(DBSetOrder(1))
	lRet := BF2->(MsSeek(xFilial("BF2")))
	If lRet
		While !BF2->(EOF())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se o tipo de usuario que procuro, possui uma sequencia inicial e final                  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim(cTipUsu) $ AllTrim(BF2->BF2_GRAUPA)
				cSeqIni := BF2->BF2_SEQDE
				cSeqFim := BF2->BF2_SEQATE
				cSeq    := cSeqIni

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona o usuario para montar o tipo de registro no novo dependente...                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BA1->( dbSetorder(02) )
				If !BA1->( dbSeek(xFilial("BA1")+cMatFam) )
					BA1->( dbGoto(nRecBa1) )
					Return({cSeq,lRet})
				Endif

				// Carrega matriz com dados para comparacao.
				BA1->( dbEval({|| Aadd(aTipReg, {BA1->BA1_GRAUPA, BA1->BA1_TIPREG, BA1->BA1_TIPUSU}) },,{|| BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == cMatFam}) )

				For nInd := 1 To Len(aTipReg)
					If AllTrim(aTipReg[nInd, 3]) $ AllTrim(BF2->BF2_GRAUPA) .AND. ASCAN(aTipReg,{|x| x[2] == cSeq}) > 0	//	Só incrementa se a Sequência já existir
						cSeq := StrZero((Val(cSeq)+1),2)
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Mostro o assistente caso a quantidade de grau de parentesco ultrapasse a quantidade  |
					//³ permitida no cadastro                                                                |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cSeq > cSeqFim
						lRet := .F.
						//						critica
						BA1->( dbGoto(nRecBa1) )
						Return({cSeq,lRet})
					Endif
				Next
				Exit
			Endif
			BF2->(DBSkip())
		Enddo
	Endif
Endif

BA1->( dbGoto(nRecBa1) )
Return({cSeq,lRet})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS169Tpa  ³ Autor ³ Geraldo Felix Junior³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alterar o tipo de usuario / grau de parentesco do usuario  |±±
±±³          ³ transferido...                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 24.09.02 ³      ³ Tulio Cesar ³ Nao permitir duplicidade de TIPREG    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS169Tpa(oCritica, cTipReg, lGrauPar, nAtx)	//	[F11]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oDlg
LOCAL nOpca := 0
LOCAL bCancel := { || oDlg:End() }
LOCAL cGrauPa
LOCAL cTipUsu
LOCAL cNomeUs
LOCAL bOK := { || Iif( PLSA169MUD(oCritica,cTipUsu),(nOpca := K_OK, oDlg:End()),.F.) }
LOCAL bDesGra
LOCAL bDesUsu
LOCAL cDesGra
LOCAL cDesUsu
LOCAL cF31 := 'B37PLS'
LOCAL cF32 := 'B47PLS'
LOCAL cF33 := 'BVZPLS'
LOCAL cF34 := 'BJHPLS'

PRIVATE cCodPro	:= CriaVar("BQQ_CODPRO")
PRIVATE cDesPro	:= ''
PRIVATE cVersao	:= CriaVar("BQQ_VRSPRO")

DEFAULT lGrauPar := .T.
DEFAULT nAtx := oCritica:nAt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Chama ponto de entrada para validar a alteração do grau de parentesco e o tipo de usuário
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PL169VLTP")
 	lVldTp := ExecBlock("PL169VLTP",.f.,.f.,Nil)
	If (!lVldTp)
		Return cSelecao
	EndIf
Endif

//	As inicializações das variáveis estão aqui, devido a definição da "nAtx"
cGrauPa := aCritica[nAtx, 6]	//	Grau de Parentesco
bDesGra := {|| Posicione("BRP",1,xFilial("BRP")+cGrauPa,"BRP_DESCRI") }
cDesGra := Eval(bDesGra)
cTipUsu := aCritica[nAtx, 3]	//	Tipo do Usuário
bDesUsu := {|| Posicione("BIH",1,xFilial("BIH")+cTipUsu,"BIH_DESCRI") }
cDesUsu := Eval(bDesUsu)
cNomeUs := aCritica[nAtx, 1]	//	Nome do Usuário

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa janela para selecao dos usuario que serao transferidos...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0024+M->BQQ_CODINT+"."+M->BQQ_EMPORI+"."+M->BQQ_FAMORI+"-"+cTipReg FROM 05,07 TO 22,70 OF GetWndDefault()
@ 035, 005 SAY oSay PROMPT STR0025    SIZE 100,010 OF oDlg PIXEL //"Nome do Usuário"
@ 035, 050 MSGet cNomeUs              SIZE 200,010 OF oDlg PIXEL When .F.
@ 055, 005 SAY oSay PROMPT STR0072    SIZE 100,010 OF oDlg PIXEL //"Grau parentesco"
@ 055, 050 MSGet cGrauPa PICTURE "@!" Size 025,010 OF oDlg PIXEL	;
 	Valid(IIF(EMPTY(cGrauPa), (MSGALERT(STR0007 + " " + STR0034, STR0013), .F.), .T.) .AND. PL169VLD('1', cGrauPa, @cDesGra, cTipReg)) F3 cF31
@ 055, 080 MSGet cDesGra PICTURE "@!" Size 100,010 OF oDlg PIXEL	When .F.
@ 075, 005 SAY oSay PROMPT STR0033    SIZE 100,010 OF oDlg PIXEL  //"Tipo de usuário"
IF lGrauPar
	@ 075, 050 MSGet cTipUsu PICTURE "@!" Size 025,010 OF oDlg PIXEL Valid( PL169VLD('2', cTipUsu, @cDesUsu, cTipReg) ) F3 cF32
ELSE
	@ 075, 050 MSGet cTipUsu PICTURE "@!" Size 025,010 OF oDlg PIXEL When .F.
ENDIF
@ 075, 080 MSGet cDesUsu PICTURE "@!" Size 100,010 OF oDlg PIXEL When .F.
@ 095, 005 SAY oSay PROMPT STR0073    SIZE 100,010 OF oDlg PIXEL  //"Produto "
@ 095, 050 MSGet cCodPro PICTURE "@!" Size 025,010 OF oDlg PIXEL	Valid( PL169VLD('3', (cCodPro), @cDesPro, cTipReg, @cVersao) ) F3 cF33
@ 095, 080 MSGet cDesPro PICTURE "@!" Size 100,010 OF oDlg PIXEL	When .F.
@ 115, 005 SAY oSay PROMPT STR0074    SIZE 100,010 OF oDlg PIXEL  //"Versão "
@ 115, 050 MSGet cVersao PICTURE "@!" SIZE 025,010 OF oDlg PIXEL Valid( PL169VLD('4', (cCodPro+cVersao), @cDesPro, cTipReg, @cVersao) ) F3 cF34
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta string com os tipos de registros dos usuarios que serao transferidos...  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK
	aCritica[nAtx, 3] := cTipUsu
	aCritica[nAtx, 6] := cGrauPa
	aCritica[nAtx, 7] := cCodPro
	aCritica[nAtx, 8] := cVersao
	oCritica:SetArray(aCritica)
	oCritica:Refresh()
	IF !(aCritica[nAtx, 2] $ cSelecao)
		cSelecao += aCritica[nAtx, 2] + ","	//	Adiciona o Registro corrente nos Selecionados
	ENDIF
ELSE	//	Cancela
	cSelecao := SPACE(LEN(cSelecao))
Endif

Return(cSelecao)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA169   ºAutor  ³Microsiga           º Data ³  07/22/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PL169VLD(cTipo, cVar, cDescri, cTipReg, cVersao)

LOCAL lRet := .F.

If Empty(cVar)
	lRet := .T.
ELSE
	If cTipo == '1'
		IF cVar == __cGrauParTit .AND. !EMPTY(M->BQQ_FAMDES)	//	Não Permite Grau "Titular" se for transferência para outra Família, pois já tem 1 Titular
			MsgAlert(STR0084)//"Nao é permitido mais de um titular na família"
		ELSE
			lRet := BRP->(dbSeek(xFilial("BRP")+cVar))
			cDescri := BRP->BRP_DESCRI
		ENDIF
	Elseif cTipo == '2'
		lRet := BIH->(dbSeek(xFilial("BIH")+cVar))
		cDescri := BIH->BIH_DESCRI
	Elseif cTipo == '3'
		lRet := BI3->(dbSeek(xFilial("BI3")+PlsIntPad()+cVar))
		If !lRet
			msgAlert(STR0075) //"Produto invalido!"
		Else
			cDescri := BI3->BI3_DESCRI
		Endif
	Elseif cTipo == '4'
		lRet := BI3->(dbSeek(xFilial("BI3")+PlsIntPad()+cVar))
		If !lRet
			msgAlert(STR0076) //"Versão do produto não invalida!"
		Endif
	Endif
ENDIF

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A169Build ºAutor  ³Geraldo Felix Juniorº Data ³  05/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³chama o construtor de filtros. Valida possibilidade de se   º±±
±±º          ³construir um filtro para a transferencia.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A169Build(cAlias,oDlg,cExpres)

LOCAL lExpres 	:= .T.
LOCAL cTxt		:= ''

If BQQ->( FieldPos("BQQ_EXPFAM") ) == 0
	cTxt := STR0077+CHR(13)+CHR(10) //"Filtro indisponível... Campo BQQ_EXPFAM não existe na base de dados "
	lExpres := .F.
Endif
If BQQ->( FieldPos("BQQ_EXPUSR") ) == 0
	cTxt += STR0078 //"Filtro indisponível... Campo BQQ_EXPUSR não existe na base de dados."
	lExpres := .F.
Endif
If lExpres
	If !Empty(M->BQQ_FAMORI)
		If cAlias == 'BA3'
			cTxt := STR0079 //'Filtro de famílias esta indisponível... A família já foi informada no campo Família.'
		Else
			cTxt := STR0080 //'Filtro de usuários esta indisponível... A família foi informada no campo Família. Utilize o campo Usuários para selecionar os usuários que serão transferidos.'
		Endif
		MsgStop(cTxt)
		cExpres := ''
		lExpres := .F.
	Endif
Else
	MsgStop(cTxt)
Endif
If lExpres
	cExpres := BuildExpr(cAlias,oDlg,cExpres)
Endif

Return(cExpres)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³01/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Private aRotina := {	;
	{ STR0004, 'AxPesqui', 0, K_Pesquisar , 0, .F.},; //'Pesquisar'
	{ STR0005, 'PL169MOV', 0, K_Visualizar, 0, Nil},; //'Visualizar'
	{ STR0006, 'PL169MOV', 0, K_Incluir   , 0, Nil} } //'Incluir'

If ExistBlock("PLS169M1")
	aPtoEntrada := ExecBlock("PLS169M1",.F.,.F.)
	aadd( aRotina,{ aPtoEntrada[1] ,aPtoEntrada[2] , 0 , K_Incluir , 0, Nil} )
Endif

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A169Ans  º Autor ³ Microsiga Protheus º Data ³  24/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Sempre que a rotina migrar o codigo CCO do beneficiario    º±±
±±º          ³ (BQQ_CODCCO=1), os demais dados referente a ANS deverao    º±±
±±º          ³ ser migrados tambem.										  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A169Ans(nCnt,cConte,cVal)

If BQQ->(FieldPos("BQQ_CODCCO")) > 0
	If M->BQQ_CODCCO != "1"
		BA1->( FieldPut(nCnt,cVal) )
	Else
		BA1->( FieldPut(nCnt, cConte) )
	EndIf
Else
	BA1->( FieldPut(nCnt,cVal) )
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS169SXB ºAutor  ³                    º Data ³  23/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa a consulta padrao (especifica)                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLS169SXB()

Local aArea     := GetArea()
Local cSql 	:= ""
Local aIndices 	:= {}
Local aHeader 	:= {}
Local lRet		:= .F.
Local oConsulta	:= Nil
Local cCampo := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a query da consulta padrao																		³
//³Converte primeiro campo para string pois o mesmo eh chave na consulta padrao e na pesquisa do mesmo	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->BQQ_TODOS == '0'
	cSql := " SELECT BG3_CODBLO,BG3_DESBLO  FROM "+RetSqlName("BG3")+" "
	cSql += " WHERE BG3_FILIAL = '"+xFilial("BG3")+"' AND "
	cSql += " BG3_PERBLO='1' AND BG3_TIPBLO='0' AND "
	cSql += " D_E_L_E_T_ = ' ' "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a aHeader da consulta³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SX3->( dbSetOrder( 2 ) )
	SX3->( dbGotop(  ) )
	If SX3->( dbSeek( "BG3_CODBLO", .F. ) )
		Aadd(aHeader,{SX3->X3_TITULO,SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"}) //"Id. Periodo"
		aAdd( aIndices, {"BG3_CODBLO",SX3->X3_TITULO})
	Endif
	If SX3->( dbSeek( "BG3_DESBLO", .F. ) )
		Aadd(aHeader,{SX3->X3_TITULO,SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"}) //"Id. Periodo"
		aAdd( aIndices, {"BG3_DESBLO",SX3->X3_TITULO})
	Endif
 	cCampo:='BG3_CODBLO'

Else
	cSql := " SELECT BG1_CODBLO,BG1_DESBLO  FROM "+RetSqlName("BG1")+" "
	cSql += " WHERE BG1_FILIAL = '"+xFilial("BG1")+"' AND"
	cSql += " BG1_PERBLO='1' AND BG1_TIPBLO='0' AND "
	cSql += " D_E_L_E_T_ = ' ' "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a aHeader da consulta³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SX3->( dbSetOrder( 2 ) )
	SX3->( dbGotop(  ) )
	If SX3->( dbSeek( "BG1_CODBLO", .F. ) )
		Aadd(aHeader,{SX3->X3_TITULO,SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"}) //"Id. Periodo"
		aAdd( aIndices, {"BG1_CODBLO",SX3->X3_TITULO})
	Endif
	If SX3->( dbSeek( "BG1_DESBLO", .F. ) )
		Aadd(aHeader,{SX3->X3_TITULO,SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"}) //"Id. Periodo"
		aAdd( aIndices, {"BG1_DESBLO",SX3->X3_TITULO})
	Endif
	cCampo:='BG1_CODBLO'
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a consulta padrao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oConsulta:=PlsIntSxb():New()
oConsulta:cTitle 		:= "Motivos de bloqueio" 					    								//Titulo da Consulta
oConsulta:cQuery 		:= cSql															//Query dos dados a serem apresentados
oConsulta:aIndex 		:= aIndices														//Indices disponiveis (deve usar os mesmos campos da query)
oConsulta:aHeader 		:= aHeader                      								//Header da grid presente consulta (deve usar os mesmos campos da query)
oConsulta:aReturn		:= {cCampo}	//Campos de retorno da consulta (deve usar os mesmos campos da query)
oConsulta:lDataBaseRM 	:= .T.															//Indica se a query eh executada na base do protheus ou da RM
oConsulta:Show()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coleta o retorno³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(oConsulta:aRetSXB) > 0
	VAR_IXB := oConsulta:aRetSXB[1]
	lRet:=.t.
EndIf
RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma   PlsVldBlo ºAutor  ³                    º Data ³  23/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa a validação do campo BQQ_MOTBLO                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function PlsVldBlo(lSX7)

Local lRet      := .T.
Local cDescBlo  := ""
Local cMotBlo   := Iif(Inclui,Iif(!Empty(M->BQQ_MOTBLO),M->BQQ_MOTBLO,""),BQQ->BQQ_MOTBLO)
Local cAliasBlo := ""
Local cMotBloF3 := GetSx3Cache("BQQ_MOTBLO", "X3_F3") 

Default lSX7    := .F.

If !Empty(cMotBlo)
	
	//Devido a alterações no F3, é necessário essa validação para não causar inconsistência
	If M->BQQ_TODOS == "1" .AND. cMotBloF3 == "PLMBLO" 
		
		cAliasBlo := "BG1"
	Else
		cAliasBlo := "BG3"
	EndIf
	
	lRet := ExistCpo(cAliasBlo, cMotBlo, 1) .and. Posicione(cAliasBlo, 1, xFilial(cAliasBlo) + cMotBlo, cAliasBlo+'_TIPBLO') == '0'
	
	cDescBlo := Iif(lRet, &(cAliasBlo+"->"+cAliasBlo+"_DESBLO"), "")
	
	If !Inclui .And. !lSX7
		lSX7 := .T.
	EndIf
Else
	lSX7 := .T.
EndIf

Return(Iif(!lSX7,lRet,cDescBlo))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºClasse	 ³PlsIntSxb ºAutor  ³                    º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Interface padrao para elaboracao de consultas padrao de tabeº±±
±±º          ³las que intermediarias da integracao Protheus x Classis. Tamº±±
±±º          ³bem se aplica a tabelas do banco de dados do CorporeRM      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºPremissas ³1 - Chaves utilizadas nao podem conter campos numericos.    º±±
±±º          ³2 - aHeader deve estar no mesmo layout do padrao microsiga. º±±
±±º          ³3 - Layout de aIndexes deve ser {x1 - Chave, x2 - Descricao}º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Integracao Microsiga Protheus x Rm ClassisNet               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Class PlsIntSxb
	Data oDlg	   			//Formulario "Dialog" principal
	Data oCmbIndP			//ComboBox de Indices exibidos
	Data oBtnPsq			//Botao Pesquisar
	Data oGetDds			//GetDados com os itens da consulta
	Data oGetExp			//Get com a expressao a ser buscada
	Data cTitle				//Titulo da consulta Padrao
	Data cQuery				//Query dos itens a buscar
	Data lDataBaseRM		//Consulta eh feita no banco da RM - Default .F.
	Data aHeader			//Header da grid da consulta padrao
	Data aIndex				//Indices da consulta {x1= Chave,x2=Descricao}
	Data aReturn			//Campos a serem retornados pela consulta
	Data cIndPesq			//RESERVADO - Indice utilizado na pesquisa
	Data cExpres			//RESERVADO - Expressao a ser buscada
	Data aCols				//RESERVADO - Itens da getDados buscada
	Data aRetSXB			//RESERVADO - Retorno definido

	Method New() CONSTRUCTOR
	Method LoadData()
	Method ReLoadData()
	Method LoadInterface()
	Method Search()
	Method Show()
	Method setReturn()
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Microsiga           º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Method New 	                                              º±±
±±º          ³ Metodo Construtor da classe PlsintSxb                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method New() Class PlsIntSxb

	::oDlg	   		:= Nil
	::oCmbIndP		:= Nil
	::oBtnPsq		:= Nil
	::oGetDds		:= Nil
	::cTitle		:= ""
	::cQuery		:= ""
	::aRetSXB		:= {}
	::aReturn		:= {}
	::aHeader		:= {}
	::aCols			:= {}
	::aIndex		:= {}
	::cIndPesq		:= ""
	::cExpres		:= Space(300)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Microsiga           º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Method Show 	                                              º±±
±±º          ³ Exibe a Consulta Padrao				                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method Show() class PlsIntSxb

	If ::oDlg == Nil
		::LoadInterface()
	Endif
	If Select('TRQ') <= 0
		::LoadData()
	Endif
	::oDlg:Activate()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Microsiga           º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Method LoadData                                            º±±
±±º          ³ Executa a query e grava na aCols 	                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method LoadData() class PlsIntSxb

Local aStruct := {}
Local nI := 0
Local nJ := 0
Local cMacro := ""
Local nAmbTOP,nAmbCLASSIS
Local cIndSel := ::aIndex[::oCmbIndP:nAt,1]
Local cQryAux := ""

Private aColsAux := {}

If !Empty(::cQuery)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona a ordenacao de acordo com o indice escolhido³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! "ORDER BY" $ upper(::cQuery)
		cQryAux += ::cQuery + " ORDER BY "
		For nI:= 1 to len(cIndSel)
			If substr(cIndSel,nI,1) != "+"
				cQryAux += substr(cIndSel,nI,1)
			else
				cQryAux += ","
			endif
		Next
	EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a query³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQryAux := ChangeQuery(cQryAux)
	iif(Select('QRY')>0,QRY->(dbCloseArea()),Nil)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryAux),'QRY', .F., .T.)
	dbSelectArea('QRY')

	If IsInCallStack("PLPESINTSXB")
		TcSetField('QRY',"BEA_DATPRO" ,"D", TamSx3("BEA_DATPRO")[1], TamSx3("BEA_DATPRO")[2] )
		TcSetField('QRY',"BE4_DTALTA" ,"D", TamSx3("BE4_DTALTA")[1], TamSx3("BE4_DTALTA")[2] )
	Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem a estrutura da tabela³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStruct := QRY->(dbStruct())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona os registros na aCols Auxiliar³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsAux := {}
	nI := 1
	While QRY->(!Eof())
		cMacro := "aAdd(aColsAux,{"

	        //Adiciona cada campo da query
		For ni := 1 to len(aStruct)
			cMacro += "QRY->" + alltrim(aStruct[nI,1])

				//Adiciona a virgula ou fecha o bloco se for ultimo campo
			if nI < len(aStruct)
				cMacro += ","
			else
				cMacro += ",.F.})"
			endif
		Next

			//Executa a macro montada, (adiciona na aCols Auxiliar)
		&(cMacro)

		QRY->(dbSkip())
	EndDo
	QRY->(dbCloseArea())

		//Copia a aCols auxiliar para a aCols da classe PlsIntSxb
	::aCols := aClone(aColsAux)
	::oGetDds:aCols := aClone(aColsAux)
	::oGetDds:Refresh()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Microsiga           º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Method ReLoadData                                          º±±
±±º          ³ Recarrega os dados de acordo com o indice                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method ReloadData() class PlsIntSxb

if ValType(::oGetDds) == "O"
	::LoadData()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Microsiga           º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Method LoadInterface                                       º±±
±±º          ³ Realiza a pintura da dialog da consulta                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method LoadInterface() class PlsIntSxb

Local aIndAux := {}
Local nI := 0
Local lOk := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona os indices na variavel auxiliar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to len(::aIndex)
	aAdd(aIndAux,::aIndex[nI,2])
Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a tela da consulta³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
::oDlg:= MSDIALOG():Create()
::oDlg:cName     := "oDlg"
::oDlg:cCaption  := ::cTitle
::oDlg:nLeft     := 0
::oDlg:nTop      := 10
::oDlg:nWidth    := 507
::oDlg:nHeight   := 440
::oDlg:lShowHint := .F.
::oDlg:lCentered := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a Combo "Indice"		       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
::oCmbIndP:= TCOMBOBOX():Create(::oDlg)
::oCmbIndP:cName 	  	  	:= "oCmbIndP"
::oCmbIndP:nLeft 	  	  	:= 10
::oCmbIndP:nTop 	  		:= 8
::oCmbIndP:nWidth 	  		:= 380
::oCmbIndP:nHeight   		:= 22
::oCmbIndP:lShowHint 		:= .F.
::oCmbIndP:lReadOnly 		:= .F.
::oCmbIndP:Align 	  		:= 0
::oCmbIndP:cVariable 		:= "::cIndPesq"
::oCmbIndP:bSetGet   		:= {|u| If(PCount()>0,::cIndPesq:=u,::cIndPesq)}
::oCmbIndP:lVisibleControl 	:= .T.
::oCmbIndP:aItems    		:= aIndAux
::oCmbIndP:bWhen     		:= {|| .T.}
::oCmbIndP:bChange			:= {|| ::ReLoadData() }
::oCmbIndP:nAt				:= 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o Get "Expressao"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
::oGetExp:= TGET():Create(::oDlg)
::oGetExp:cName 	 		:= "oGetExp"
::oGetExp:nLeft 	 		:= 10
::oGetExp:nTop 	 	   		:= 35
::oGetExp:nWidth 	 		:= 380
::oGetExp:nHeight 	 		:= 22
::oGetExp:lShowHint 		:= .F.
::oGetExp:lReadOnly 		:= .F.
::oGetExp:Align 	 		:= 0
::oGetExp:lVisibleControl 	:= .T.
::oGetExp:lPassword 		:= .F.
::oGetExp:lHasButton		:= .F.
::oGetExp:cVariable 		:= "::cExpres"
::oGetExp:bSetGet 	 		:= {|u| If(PCount()>0,::cExpres:=u,::cExpres)}
::oGetExp:Picture   		:= "@!"
::oGetExp:bWhen     		:= {|| .T.}
::oGetExp:bChange			:= {|| .T.}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o botao Pesquisar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
::oBtnPsq:= TButton():Create(::oDlg)
::oBtnPsq:cName 		:= "oBtnPsq"
::oBtnPsq:cCaption 		:= "Pesquisar"
::oBtnPsq:nLeft 		:= 400
::oBtnPsq:nTop  		:= 8
::oBtnPsq:nWidth    	:= 90
::oBtnPsq:nHeight 		:= 22
::oBtnPsq:lShowHint 	:= .F.
::oBtnPsq:lReadOnly 	:= .F.
::oBtnPsq:Align 		:= 0
::oBtnPsq:bAction 		:= {|| ::Search() }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a getDados Alunos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
::oGetDds:= MsNewGetDados():New( 33, 5, 185, 244 ,GD_UPDATE, /*cLinhaOk*/, /*cTudoOk*/,/*incremento*/,/*aAltera*/,/*lVazio*/,999,/*cCampoOk*/,/*Superdel*/,/*cApagaOk*/,::oDlg,::aHeader,::aCols)
::oGetDds:oBrowse:bLdblClick := {||  ::oDlg:End(), ::setReturn() }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o botao Cancel³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBtnCancel := SButton():Create(::oDlg)
oBtnCancel:cName	:= "oBtnCancel"
oBtnCancel:nLeft	:= 75
oBtnCancel:nTop		:= 380
oBtnCancel:nWidth	:= 30
oBtnCancel:nHeight	:= 24
oBtnCancel:nType	:= 02
oBtnCancel:bAction	:= {|| ::oDlg:End() }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o botao OK³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBtnOK := SButton():Create(::oDlg)
oBtnOK:cName	:= "oBtnOk"
oBtnOK:nLeft	:= 13
oBtnOK:nTop		:= 380
oBtnOK:nWidth	:= 30
oBtnOK:nHeight	:= 24
oBtnOK:nType	:= 01
oBtnOk:bAction	:= {|| ::oDlg:End(), ::setReturn() }

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Microsiga           º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Method Search		                                      º±±
±±º          ³Busca por um registro na getDados de acordo com a expressao º±±
±±º          ³informada. (Busca do SXB)									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method Search() class PlsIntSxb

Local nI 		:= 0
Local nJ		:= 0
Local cIndSel 	:= ::aIndex[::oCmbIndP:nAt,1]
Local aCmpInd 	:= {}
Local aPosicoes := {}
Local cAux 		:= ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Coleta todos os campos do indice escolhido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to len(cIndSel)
	if substr(cIndSel,nI,1) != "+"
		cAux += substr(cIndSel,nI,1)
	else
		aAdd(aCmpInd,alltrim(cAux))
		cAux := ""
	endif
Next
aAdd(aCmpInd,alltrim(cAux))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Coleta as posicoes dos campos do indice escolhido dentro da aHeader³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to len(aCmpInd)
	For nJ := 1 to len(::aHeader)
		If alltrim(upper(::aHeader[nJ,2])) == alltrim(upper(aCmpInd[nI]))
			aAdd(aPosicoes,nJ)
			exit
		EndIf
	Next
Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a expressao a partir das posicoes coletadas e compara com a expressao do usuario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAux := ""
For nI := 1 to len(::oGetDds:aCols)
		//Coleta o valor da linha, somando somente os campos que compoe o indice
	For nJ := 1 to len(aPosicoes)
		cAux += ::oGetDds:aCols[nI,aPosicoes[nJ]]
	Next

	If rtrim(::cExpres) $ cAux
		::oGetDds:oBrowse:nAt := nI
		exit
	Else
		cAux := ""
	Endif
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Microsiga           º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Method setReturn		                                      º±±
±±º          ³Define o conteudo de retorno da consulta					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method setReturn() class PlsIntSxb

Local nPosCmp	:= 0
Local nI		:= 0
Local nJ		:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Coleta a posicao do campo de retorno³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(::aReturn) > 0
	For nI := 1 to len(::aReturn)
		For nJ := 1 to len(::aHeader)
			If alltrim(upper(::aReturn[nI])) == alltrim(upper(::aHeader[nJ,2]))
				nPosCmp := nJ
				exit
			EndIf
		Next

		If nPosCmp > 0 .and. Len(::oGetDds:aCols)>0
			aAdd(::aRetSXB,::oGetDds:aCols[::oGetDds:oBrowse:nAt,nPosCmp])
		EndIf
		nPosCmp := 0
	Next
EndIF

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pl090PSSXBºAutor  ³                    º Data ³  23/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa a consulta padrao (especifica)                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Pl090PSSXB()

Local cSql 	:= ""
Local aIndices 	:= {}
Local aHeader 	:= {}
Local lRet		:= .F.
Local oConsulta	:= Nil
Local aArea     := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a query da consulta padrao																		³
//³Converte primeiro campo para string pois o mesmo eh chave na consulta padrao e na pesquisa do mesmo	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSql := " SELECT BAX_CODESP,BAQ_DESCRI  FROM "+RetSqlName("BAX")+" BAX,"+RetSqlName("BAQ")+" BAQ "
cSql += " WHERE BAX_FILIAL = '"+xFilial("BAX")+"' AND"
cSql += " BAX_CODIGO  = '"+M->BE1_CODRDA+"' AND "
cSql += " BAX_CODINT  = '"+M->BE1_OPERDA+"' AND "
cSql += " BAX_CODLOC  = '"+Subs(M->BE1_CODLOC,1,3)+"' AND "
cSql += " BAQ_FILIAL = '"+xFilial("BAQ")+"' AND"
cSql += " BAQ_CODINT  = BAX_CODINT AND "
cSql += " BAQ_CODESP  = BAX_CODESP AND "
cSql += " BAX.D_E_L_E_T_ = ' ' AND "
cSql += " BAQ.D_E_L_E_T_ = ' ' "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a aHeader da consulta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SX3->( dbSetOrder( 2 ) )
SX3->( dbGotop(  ) )
If SX3->( dbSeek( "BAX_CODESP", .F. ) )
	Aadd(aHeader,{SX3->X3_TITULO,SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"}) //"Id. Periodo"
	aAdd( aIndices, {"BAX_CODESP",SX3->X3_TITULO})
Endif

If SX3->( dbSeek( "BAQ_DESCRI", .F. ) )
	Aadd(aHeader,{SX3->X3_TITULO,SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"}) //"Id. Periodo"
	aAdd( aIndices, {"BAQ_DESCRI",SX3->X3_TITULO})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a consulta padrao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oConsulta:=PlsIntSxb():New()
oConsulta:cTitle 		:= STR0026 					    								//Titulo da Consulta
oConsulta:cQuery 		:= cSql															//Query dos dados a serem apresentados
oConsulta:aIndex 		:= aIndices														//Indices disponiveis (deve usar os mesmos campos da query)
oConsulta:aHeader 		:= aHeader                      								//Header da grid presente consulta (deve usar os mesmos campos da query)
oConsulta:aReturn		:= {"BAX_CODESP"}	//Campos de retorno da consulta (deve usar os mesmos campos da query)
oConsulta:lDataBaseRM 	:= .T.															//Indica se a query eh executada na base do protheus ou da RM
oConsulta:Show()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coleta o retorno³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(oConsulta:aRetSXB) > 0
	VAR_IXB := oConsulta:aRetSXB[1]
	lRet:=.t.
EndIf

RestArea(aArea)

Return lRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSDTADAPT
Salva a data da adaptação inserida na BQQ na tabela BA1

@author	Lucas de Azevedo Nonato
@since		10/11/2015
@version	P11
@Return
@Obs
/*/
//---------------------------------------------------------------------------------------
Function PLSDTADAPT(aDigitos)

Local nI := 1

BA1->(dbSetOrder(1))
If !Empty(aDigitos)
	For nI=1 To Len(aDigitos)
		If BA1->(dbSeek(xFilial('BA1') + SubStr(aDigitos[nI, 1],0,14)))
			RecLock("BA1", .F.)
				BA1->BA1_DATADP := M->BQQ_DTADAP
			BA1->(MsUnlock())
		EndIf
	Next
EndIf

Return

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLS169DEST
Verifica se a data da inclusão de algum beneficiário transferido será inferior à data da Inclusão
do titular da família destino
@author	Oscar Zanin
@since		15/03/2016
@version	P12
/*/
//---------------------------------------------------------------------------------------
Function PLS169DEST()

Local lRet := .T.
Local aAreaB := getArea()
Local cChvDest := xFilial("BA1") + M->BQQ_CODINT + M->BQQ_EMPDES + M->BQQ_FAMDES + __cTipoUsoTit
Local cChvOrig := xFilial("BA1") + M->BQQ_CODINT + M->BQQ_EMPORI + M->BQQ_FAMORI
Local dDtIncTitD := Date()
Local dDtIncOrig := Date()
Local lFamDes := !(EmpTy(M->BQQ_FAMDES))
LOCAL dDatInc := M->BQQ_DATINC	//	Data da Inclusão / Transferência

//	Valida Data de Inclusão
BA1->(DbSetOrder(1)) //	BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPUSU + BA1_TIPREG + BA1_DIGITO
IF M->BQQ_INCORI == '0'
	BA3->(DbSetOrder(1)) //	BA3_FILIAL + BA3_CODINT + BA3_CODEMP + BA3_MATRIC + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB
	BA3->(DBSEEK(cChvOrig)) //	Posiciona na Família Origem
	dDatInc := MAX(dDatInc, BQC->BQC_DATCON)	//	Data de Inclusão do SubContrato
	dDatInc := MAX(dDatInc, BA3->BA3_DATBAS)	//	Data de Inclusão da Família
	IF BA1->(DBSEEK(cChvOrig)) //	Posiciona na Família Origem
		WHILE !BA1->(EOF()) .AND. BA1->(BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC) == cChvOrig //	Enquanto for a família..
			IF M->BQQ_TODOS == "1" .OR. BA1->BA1_TIPREG $ AllTrim(M->BQQ_USUARI) //	É um Transferido
				dDatInc := MAX(dDatInc, BA1->BA1_DATINC)	//	Data de Inclusão do usuário
				dDatInc := MAX(dDatInc, BA1->BA1_DATNAS)	//	Data de Nascimento do usuário
			ENDIF
			BA1->(DBSKIP())
		ENDDO
	ENDIF
	IF dDatInc > M->BQQ_DATINC	//	Achou nova Data para a Inclusão
		lRet := MsgYesNo( ;	//	"O Sistema comparou as Datas de Inclusão do SubContrato, da Família e dos Usuários, e verificou que a data mínima aceitável é "
			STR0097 + "'" + DTOC(dDatInc) + "' !" + CHR(13) + ;
			STR0098)	//	"Deseja continuar (S/N) ?"
		M->BQQ_DATINC := dDatInc
	ENDIF
	IF !lRet
		RETURN(.F.)	//	Retorna para informar nova Data
	ENDIF
ENDIF

If lFamDes	//Informou família de destino?
	If BA1->(MsSeek(cChvDest)) //Buscamos o Titular da família
		dDtIncTitD := BA1->BA1_DATINC //Pegamos a data da inclusão dele
		If M->BQQ_INCORI == "0" //Se não mantém a data original
			dDtIncOrig := M->BQQ_DATINC
			If Empty(dDtIncOrig) //Se não informou a data, retorna aviso e .F.
				lRet := .F.
				MsgAlert(STR0093) //"Atenção, Preencha a data de inclusão dos beneficiários na família destino (campo BQQ_DATINC)"
			elseif dDtIncOrig < dDtIncTitD //Se a data original for anterior, dá o alerta
				lRet := MsgYesNo(STR0094)//"A data de inclusão de pelo menos um dos beneficiários transferidos é anterior à data da inclusão do titular da família destino. Deseja prosseguir?"
			EndIf
			if !lRet	//	Não precisa testar os demais
				IF BA1->(MsSeek(cChvOrig)) //Posiciona na família origem para verificar a data de nascimento
					While !(BA1->(EoF())) .AND. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == cChvOrig //Enquanto a família..
						If IIF(M->BQQ_TODOS == "1", .T., BA1->BA1_TIPREG $ AllTrim(M->BQQ_USUARI)) //Verificamos só os transferidos
							If BA1->BA1_DATNAS > dDtIncOrig //Se a data original for anterior, dá o alerta e sai do laço
								lRet := .F.
								MsgStop(STR0095)//"A data de transferência de pelo menos um beneficiário é superior à data de nascimento"
								Exit
							EndIF
						EndIf
						BA1->(DbSkip())
					EndDo
				EndIf
			ENDIF
		else
			If BA1->(MsSeek(cChvOrig)) //Posiciona na família origem
				While !(BA1->(EoF())) .AND. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == cChvOrig //Enquanto a família..
					If IIF(M->BQQ_TODOS == "1", .T., BA1->BA1_TIPREG $ AllTrim(M->BQQ_USUARI)) //Verificamos só os transferidos
						If BA1->BA1_DATINC < dDtIncTitD //Se a data original for anterior, dá o alerta e sai do laço
							lRet := MsgYesNo(STR0094)//"A data de inclusão de pelo menos um dos beneficiários transferidos é anterior à data da inclusão do titular da família destino. Deseja prosseguir?"
							Exit
						EndIF
					EndIf
					BA1->(DbSkip())
				EndDo
			EndIF
		EndIF
	EndIf
EndIf
RestArea(aAreaB)

return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlPrDadNio

Recupera e formata os dados do beneficiário para serem enviados ao NIO

@param aDadCob Dados da cobertura do beneficiário que serão carregados
@param cTraDes Matrícula de origem
@param cTraOri Matrícula de destino

@author everton.mateus
@since 16/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlPrDadNio(aDadCob,lNovoCCO,lOriTran,lUsaSIP)

Local lRotBlo 	:= .F.
Local lBloq	 	:= .F.

Default aDadCob 	:= {}
Default lNovoCCO 	:= .F.
Default lOriTran 	:= .T.
Default lUsaSIP		:= .T.

oModel	:= Pl260DadNio('1',,,,aDadCob,lRotBlo,lBloq,K_Alterar,lUsaSIP,lNovoCCO,lOriTran)

Return oModel


Function PLSMatTit(cMatFam,cCodTit,cGrpFam)
Local cMatTit := ""
Local aAreaBA1 := BA1->(GetArea())
Local aArea := BA3->(GetArea())
Local aAreaB3W := B3W->(GetArea())

//A familia não é desmembrada (grpfam está vazio)
If Empty(cGrpFam)	
	BA1->(DbSetOrder(1)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU+BA1_TIPREG+BA1_DIGITO
	B3W->(DbSetOrder(1)) //B3W_FILIAL+B3W_CODOPE+B3W_CODCCO
	
	If BA1->(MsSeek(xFilial("BA1")+cMatFam+cCodTit))
	
	    cMatTit := cMatFam + BA1->(BA1_TIPREG + BA1_DIGITO)
	    
		cRegAns := POSICIONE("BA0",1,xFilial("BA0")+BA1->BA1_CODINT,"BA0_SUSEP")
		
		//Procuro o titular na base da ANS, para pegar a matrícula que está lá
		If !Empty(BA1->BA1_CODCCO) .AND. B3W->(MsSeek(xFilial("B3W")+cRegAns+BA1->BA1_CODCCO))
			
			cMatTit := B3W->B3W_MATRIC
		
		ElseIf GetNewPar("MV_PLMATAN",.F.) .AND.!Empty(BA1->BA1_MATANT) //Verifica se tem matrícula antiga
			
			cMatTit := BA1->BA1_MATANT
			
		EndIf //If !Empty(BA1->BA1_CODCCO)...
		
		If ExistBlock("PLRETMAT")
	   		cMatAux := ExecBlock("PLRETMAT",.F.,.F.,{ cAlias })
	   		If !Empty(cMatAux)
	   			cMatTit := cMatAux
	   		EndIf
	   	EndIf
		
	EndIf
Else //A familia é desmembrada, então vou buscar o titular na origem do desmembramento
	cMatFam := AllTrim(BA3->BA3_GRPFAM)
	BA3->(DbSetOrder(1))
	If BA3->(MsSeek(xFilial("BA3")+cMatFam))
		cMatTit := PLSMatTit(cMatFam,cCodTit,AllTrim(BA3->BA3_GRPFAM))
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaBA1)
RestArea(aAreaB3W)

Return cMatTit
/********************************************************************/
//	Transfere Documentos Obrigatórios do Usuário Origem
STATIC FUNCTION PL169DOCOBR(cUserOri, cMatricula, cTipoReg)

LOCAL nCnt := 0

cUserOri := XFILIAL("BCP") + cUserOri
BCP->(DBSETORDER(1))	//	BCP_FILIAL+BCP_CODOPE+BCP_CODEMP+BCP_MATRIC+BCP_TIPREG+BCP_CODDOC
CHKFILE("BCP",, "BCPX")	//	Alias Temporário do Usuário Original
BCPX->(DBSETORDER(1))
IF BCPX->(DBSEEK(cUserOri))	//	Posiciona no Usuário Original
	WHILE !BCPX->(EOF()) .AND. cUserOri == BCPX->(BCP_FILIAL + BCP_CODOPE + BCP_CODEMP + BCP_MATRIC + BCP_TIPREG)

		//	Se não existir no Destino e For Obrigatório na Origem, irá inclui-lo
		IF !BCP->(DBSEEK(XFILIAL("BCP") + M->(BQQ_CODINT + BQQ_EMPDES) + cMatricula + cTipoReg + BCPX->BCP_CODDOC)) .AND. BCPX->BCP_DOCOBR == "1"
			RECLOCK("BCP", .T.)
			FOR nCnt := 1 TO BCP->(FCOUNT())
				BCP->(FIELDPUT(nCnt, BCPX->(FIELDGET(nCnt))))
			NEXT
			BCP->BCP_CODEMP := M->BQQ_EMPDES
			BCP->BCP_MATRIC := cMatricula
			BCP->BCP_TIPREG := cTipoReg
			MSUNLOCK()
		ENDIF
		BCPX->(DBSKIP())
	ENDDO
ENDIF
BCPX->(DBCLOSEAREA())

RETURN

/*/{Protheus.doc} PLSCL
Cliente e Loja

@author Karine Riquena Limp
@since 21/12/2016
@version P11
/*/
static function PLSCL(nRecnoBA1)

local cVlCod 	:= ''
local cVlLoj 	:= '' 
local cCodSa1 := ''
local cLojSa1 := ''
local cCpf		:= ''
local aExecAuto := {}

private lMsErroAuto := .F.

BBL->(dbSetorder(2))
if BBL->(MsSeek(xFilial("BBL")+"PLSA260   "+"BA1"+"SA1"))

	BA1->(dbGoto(nRecnoBA1))
	
	if !empty(BA1->BA1_CPFUSR)
		cCpf := BA1->BA1_CPFUSR
	elseIf !Empty(BA1->BA1_CPFPRE)
		cCpf := BA1->BA1_CPFPRE
	elseIf !Empty(BA1->BA1_CPFMAE)
		cCpf := BA1->BA1_CPFMAE
	elseIf !Empty(BA1->BA1_CPFPAI)
		cCpf := BA1->BA1_CPFPAI
	endIf
	
	SA1->(dbSetorder(03) )
	if !SA1->( MsSeek(xFilial("SA1")+cCpf) )
				
		cCodSa1 := getSX8Num("SA1","A1_COD")
					
		aExecAuto := {{"A1_COD"		,cCodSa1, NIL},;
						{"A1_LOJA"	,"01", NIL},;
						{"A1_NOME"   ,BA1->BA1_NOMUSR, NIL},;
						{"A1_NREDUZ" ,IIF(EMPTY(BA1->BA1_NREDUZ), BA1->BA1_NOMUSR, BA1->BA1_NREDUZ ), NIL},;
						{"A1_TIPO"	,"F", NIL},;
						{"A1_EST"		,BA1->BA1_ESTADO, NIL},;
						{"A1_END"		,BA1->BA1_ENDERE, NIL},;
						{"A1_MUN"		,BA1->BA1_MUNICI, NIL},;
						{"A1_DDD"		,BA1->BA1_DDD, NIL},;
						{"A1_TEL"		,BA1->BA1_TELEFO, NIL},;
						{"A1_EMAIL"	,BA1->BA1_EMAIL, NIL}}
				
		lMsErroAuto := .F.

		MSExecAuto({|x,y| Mata030(x,y)},aExecAuto,3)
	
		
		If lMsErroAuto
			MOSTRAERRO()
		Else
			confirmSX8()
		Endif
		
	else
		cCodSa1 := SA1->A1_COD
		cLojSa1 := SA1->A1_LOJA
	endIf

endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return({cCodSa1, "01"})

/*/{Protheus.doc} PLSCONSUB
limpa os campos abaixo quando o campo BQQ_CONSUB é preenchido

@author Thiago Ribas
@since 13/08/18
/*/
function PLSCONSUB()  

M->BQQ_EMPORI := SPACE( TamSX3( "BQQ_EMPORI" )[1] )
M->BQQ_EMPDES := SPACE( TamSX3( "BQQ_EMPDES" )[1] )
M->BQQ_CONORI := SPACE( TamSX3( "BQQ_CONORI" )[1] )
M->BQQ_CONDES := SPACE( TamSX3( "BQQ_CONDES" )[1] )
M->BQQ_SUBORI := SPACE( TamSX3( "BQQ_SUBORI" )[1] )
M->BQQ_SUBDES := SPACE( TamSX3( "BQQ_SUBDES" )[1] )
M->BQQ_FAMORI := SPACE( TamSX3( "BQQ_FAMORI" )[1] )
M->BQQ_FAMDES := SPACE( TamSX3( "BQQ_FAMDES" )[1] )
M->BQQ_CODPRO := SPACE( TamSX3( "BQQ_CODPRO" )[1] )
M->BQQ_VRSPRO := SPACE( TamSX3( "BQQ_VRSPRO" )[1] )
M->BQQ_GRPCOB := SPACE( TamSX3( "BQQ_GRPCOB" )[1] )
M->BQQ_DEMORI := SPACE( TamSX3( "BQQ_DEMORI" )[1] )
M->BQQ_DEMDES := SPACE( TamSX3( "BQQ_DEMDES" )[1] )
M->BQQ_TODOS  := "1"
M->BQQ_CARENC := "1"
M->BQQ_CPTORI := "1"
M->BQQ_CODCCO := "1"
M->BQQ_IMPOPC := "1"
M->BQQ_INCORI := "0"
M->BQQ_PROORI := "0"
M->BQQ_DATINC := STOD("")
M->BQQ_DATEXC := dDataBase
M->BQQ_MOTBLO := "044"

Return ""

/*/{Protheus.doc} PLTRANCSB
Faz a transferência de contrato e subcontrato 

@author Thiago Ribas
@since 13/08/18
/*/
Function PLTRANCSB( cCodOpe, cCodEmp, cConOri, cVerCoOri, cSbConOri, cVersbOri, cMatriFam, cConDes, cVerCoDes, cSbConDes, cVersbDes, lAutomato )  

LOCAL aDadosBe     := {}

DEFAULT cCodOpe    := ""
DEFAULT cCodEmp    := ""
DEFAULT cConOri    := ""
DEFAULT cVerCoOri  := ""
DEFAULT cSbConOri  := ""
DEFAULT cVersbOri  := ""
DEFAULT cMatriFam  := ""  
DEFAULT cConDes    := ""
DEFAULT cVerCoDes  := ""
DEFAULT cSbConDes  := ""
DEFAULT cVersbDes  := ""
DEFAULT lAutomato :=.F.

BA3->(DbSetOrder(7))
If BA3->( MsSeek( xFilial("BA3") + cCodOpe + cCodEmp + cConOri + cVerCoOri + cSbConOri + cVersbOri + cMatriFam ) )
	
	BEGIN TRANSACTION
		
		//grava lote da transferência
		PLUPTENC("BQQ",3)
		
		//Altera o contrato e subcontrato na família
		RecLock( "BA3",.F. )
		BA3->BA3_CONEMP := cConDes
		BA3->BA3_VERCON := cVerCoDes
		BA3->BA3_SUBCON := cSbConDes
		BA3->BA3_VERSUB := cVersbDes
		BA3->( MsUnlock() )
		
		//Altera contrato e subcontrato no beneficiário
		BA1->( DbSetOrder(1) )
		If BA1->( MsSeek( xFilial("BA1") + cCodOpe + cCodEmp + cMatriFam ) )
			
			While BA1->(BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC) == xFilial("BA1") + cCodOpe + cCodEmp + cMatriFam
				
				AADD(aDadosBe, {BA1->BA1_MATVID, BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),BA1->BA1_CONEMP, cConDes, BA1->BA1_VERCON, cVerCoDes, ;
				 				BA1->BA1_SUBCON, cSbConDes,BA1->BA1_VERSUB,cVersbDes, dDataBase,Time(),RetCodUsr()} )
				
				RecLock( "BA1",.F. )
				BA1->BA1_CONEMP := cConDes
				BA1->BA1_VERCON := cVerCoDes
				BA1->BA1_SUBCON := cSbConDes
				BA1->BA1_VERSUB := cVersbDes
				BA1->( MsUnlock() )
							
			BA1->( DbSkip() )	
			EndDo 
		EndIf
		
		//Gera o histórico de alteração
		PLHTRANSF(aDadosBe)
		
		iF !lAutomato 
			MsgInfo(STR0099, STR0100) //"Transferência concluída com sucesso" # "Sucesso"
		EndIF	

	END TRANSACTION
Else
	iF !lAutomato 
		MsgAlert(STR0101, STR0013) //"A família selecionada não foi encontrada" #"Atenção"
	Endif	
EndIf

Return

/*/{Protheus.doc} PLHTRANSF
Grava o histórico da transferência de contrato e subcontrato( apenas para a 
funcionalidade que utiliza o campo BQQ_CONSUB) 

@author Thiago Ribas
@since 13/08/18
/*/
Function PLHTRANSF(aDadosHst)

LOCAL nI   := 0
LOCAL nLen := 0

DEFAULT aDadosHst := {}

nLen := LEN(aDadosHst)

For nI := 1 To nLen
	
	RecLock( "BQT",.T. )
	BQT->BQT_FILIAL := xFilial("BQT")
	BQT->BQT_MATVID := aDadosHst[nI][1]
	BQT->BQT_MATRIC := aDadosHst[nI][2]
	BQT->BQT_CONORI := aDadosHst[nI][3]
	BQT->BQT_CONDES := aDadosHst[nI][4]
	BQT->BQT_VCOORI := aDadosHst[nI][5]
	BQT->BQT_VCODES := aDadosHst[nI][6]
	BQT->BQT_SUBORI := aDadosHst[nI][7]
	BQT->BQT_SUBDES := aDadosHst[nI][8]
	BQT->BQT_VRSORI := aDadosHst[nI][9]
	BQT->BQT_VRSDES := aDadosHst[nI][10]
	BQT->BQT_DTRANS := aDadosHst[nI][11]
	BQT->BQT_HORA   := aDadosHst[nI][12]
	BQT->BQT_CDOPER := aDadosHst[nI][13]
	BQT->( MsUnlock() )
Next

Return

/*/{Protheus.doc} PLS169SAL
Função para quando for alterado o titular da nova familia, verificar se a familia anterior possuia salario
para caso o usuario queira alterar ou permanecer como o valor

@author Vinicius.Queiros
@since 29/11/19
/*/

Static Function PLSA169SAL(cTipReg,nAtx,aDadFam)

// Definição variaveis...                                                      
Local oDlg
Local nOpca 	:= 0
Local bCancel 	:= { || oDlg:End() }
Local bOK 		:= { || (nOpca := K_OK, oDlg:End())}
Local cNomeUs	
Local cSql		
Local nSalFam 	:= 0
Local nSalAlt   

aDadFam := {} // Sempre limpa o array 

// Seleciona a familia...                                       
cSql := " SELECT BA3_VALSAL FROM "+RetSqlName("BA3")+" "
cSql += " WHERE BA3_FILIAL = '"+xFilial("BA3")+"' AND BA3_CODINT = '"+M->BQQ_CODINT+"' "
cSql += " AND BA3_CODEMP = '"+M->BQQ_EMPORI+"'"
If !Empty(M->BQQ_CONORI)
	cSql += " AND BA3_CONEMP = '"+M->BQQ_CONORI+"' AND BA3_VERCON = '"+M->BQQ_VCOORI+"' "
Endif
If !Empty(M->BQQ_SUBORI)
	cSql += " AND BA3_SUBCON = '"+M->BQQ_SUBORI+"' AND BA3_VERSUB = '"+M->BQQ_VRSORI+"' "
Endif
If !Empty(M->BQQ_FAMORI)
	cSql += " AND BA3_MATRIC = '"+M->BQQ_FAMORI+"' "
Endif
cSql += " AND BA3_VALSAL <> 0 "
cSql += " AND D_E_L_E_T_ = ' ' "

PLSQuery(cSQL,"TRBBA3")

If ! TRBBA3->(EOF())
	nSalFam := TRBBA3->BA3_VALSAL // Atribui o valor do salario da familia
EndIf

TRBBA3->(DbCloseArea())

If nSalFam > 0 // Exibir o browser somente se achar valor na familia, caso contrario nao precisar ser alterado
	// Inicializa a varivel nome
	cNomeUs := aCritica[nAtx, 1] //	Nome do Usuário
	nSalAlt := nSalFam 			 // Atribui o salario na variavel
	// Ativa janela para alterar o valor do salario da familia...         
	DEFINE MSDIALOG oDlg TITLE STR0024+" "+M->BQQ_CODINT+"."+M->BQQ_EMPORI+"."+M->BQQ_FAMORI+"-"+cTipReg FROM 05,07 TO 17,70 

		@ 035, 005 SAY oSay PROMPT STR0103    SIZE 100,010 OF oDlg PIXEL //"Nome do Titular"
		@ 034, 050 MSGet cNomeUs              SIZE 190,010 OF oDlg PIXEL When .F.
		@ 055, 005 SAY oSay PROMPT STR0104    SIZE 150,010 OF oDlg PIXEL //Alterar o salário da família destino?
		@ 070, 005 SAY oSay PROMPT STR0102    SIZE 100,010 OF oDlg PIXEL //Salário: 
		@ 069, 050 MSGet nSalAlt PICTURE "@E 9,999,999,999,999.99" Size 060,010 OF oDlg PIXEL When .T.

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

	If nOpca == K_OK
		aAdd(aDadFam,{.T.,nSalAlt})
	Else
		MsgInfo(STR0105) // "O valor do salário não foi alterado, portanto irá permanecer com o valor atual da familia origem."
		aAdd(aDadFam,{.T.,nSalFam})
	Endif
EndIf

Return(aDadFam)