#INCLUDE "QNCA070.CH"
#INCLUDE "TOTVS.CH"

Static __cEmpAnt
Static __cFilAnt

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCA070  ³ Autor ³ Aldo Marini Junior    ³ Data ³ 10/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Responsaveis                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aldo        ³30/10/01³ ---- ³ Inclusao da Opcao "Transferir" p/ transf.³±±
±±³            ³        ³      ³ de Lactos pendentes.                     ³±±
±±³Eduardo S.  ³05/09/02³ ---- ³ Alterado as funcoes AxCadastros para En- ³±±
±±³            ³        ³      ³ choices prevendo integracao com SIGAGPE. ³±±
±±³Eduardo S.  ³18/09/02³ ---- ³ Acerto na transferencia de pendencias pa ³±±
±±³            ³        ³      ³ ra gravar usuario com 10 caracteres.     ³±±
±±³Eduardo S.  ³11/10/02³ ---- ³ Acerto para transferir corretamente as   ³±±
±±³            ³        ³      ³ pendencias para o usuario destino.       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Local aRotina  := {}
Local cNivTran := GetMV("MV_QNCNTRF",.F.,9)
Local cTranFun := GetMV("MV_QNCTFUN",.F.,"N")

aAdd(aRotina,{OemToAnsi(STR0001),"AxPesqui"   , 0 , 1,,.F.})   // "Pesquisar"
aAdd(aRotina,{OemToAnsi(STR0002),"QNC070Telas", 0 , 2})   // "Visualizar"
aAdd(aRotina,{OemToAnsi(STR0003),"QNC070Telas", 0 , 3})   // "Incluir"
aAdd(aRotina,{OemToAnsi(STR0004),"QNC070Telas", 0 , 4})   // "Alterar"
aAdd(aRotina,{OemToAnsi(STR0046),"QNC070Telas", 0 , 5})   // "Excluir"

If cTranFun == "S" .And. cNivel >= cNivTran
	aAdd(aRotina,{OemToAnsi(STR0014),"QNCA070TRF"  , 0 , 4})   // "Transferir"
	aAdd(aRotina,{OemToAnsi(STR0052),"QNC070VIS"  , 0 , 2,,.F.})   //"Visual.Log"
Endif

Aadd(aRotina,{OemToAnsi(STR0048),"QNCA070Vrf", 0, 3,,.F.}) // "Mostrar Inativos"
aAdd(aRotina,{OemToAnsi(STR0009),"QNCA070Leg", 0, 6,,.F.}) // "Legenda"

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCA070   ºAutor  ³Microsiga           º Data ³  10/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Usuários                                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNAC070                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QNCA070()

Local cTranFun := GetMV("MV_QNCTFUN",.F.,"N")
Local cNivTran := GetMV("MV_QNCNTRF",.F.,9)
Local nOpc

Private cUsrInat  := GetMv("MV_QUSRINA")
Private lQNCHFIL  := GetMv("MV_QNCHFIL",.T.,.F.)
Private lUsrInat  := If(cUsrInat == "N",.T.,.F.)
Private aCRA := { OemToAnsi(STR0006), OemToAnsi(STR0007), OemToAnsi(STR0008) }  //"Confirma" ### "Redigita" ### "Abandona"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0005)  //"Respons veis/Usu rios"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QAA->(dbSetOrder(1))
QI2->(dbSetOrder(4))
QI3->(dbSetOrder(3))
QI5->(dbSetOrder(2))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'QAA' )
oBrowse:SetDescription( cCadastro )  
oBrowse:AddLegend( "Qaxa010Vld(1) == 1", 'ENABLE'    ,"Verde - Normal,sem nenhum lacto de pendencia")		//Verde - Normal,sem nenhum lacto de pendencia
oBrowse:AddLegend( "Qaxa010Vld(2) == 2", 'DISABLE'   ,"Vermelho - Demitido, sem nenhum lacto de pendencia") // Vermelho - Demitido, sem nenhum lacto de pendencia
oBrowse:AddLegend( "Qaxa010Vld(3) == 3", 'BR_AMARELO',"Amarelo - Normal,com lacto de pendencia")  			// Amarelo - Normal,com lacto de pendencia
oBrowse:AddLegend( "Qaxa010Vld(4) == 4", 'BR_AZUL'   ,"Azul - Transferido,com lacto de pendencia")  	    // Azul - Transferido,com lacto de pendencia
oBrowse:AddLegend( "Qaxa010Vld(5) == 5", 'BR_PRETO'  ,"Preta - Demitido, com lacto de pendencia")  	        // Preta - Demitido, com lacto de pendencia
oBrowse:SetFilterDefault( "QAA->QAA_STATUS == '1'" )

dbSelectArea('QAA')
QI2->(dbSetOrder(1))
QI3->(dbSetOrder(1))
QI5->(dbSetOrder(1))
oBrowse:Activate()

//Set Key VK_F12 To
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCA070Leg ³ Autor ³ Aldo Marini Junior   ³ Data ³ 24.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCA070Leg

Local aLegenda := { {'ENABLE'    , OemtoAnsi(STR0010) },;	// "Usuario ATIVO sem Lactos Pendentes"
                     {'DISABLE'   , OemtoAnsi(STR0011)},;	// "Usuario INATIVO sem Lactos Pendentes"
                     {'BR_AMARELO', OemtoAnsi(STR0012)},;  // "Usuario ATIVO com Lactos Pendentes"
                     {'BR_PRETO'  , OemtoAnsi(STR0013)} }  // "Usuario INATIVO com Lactos Pendentes"

BrwLegenda(cCadastro,STR0009 ,aLegenda) 	// "Legenda"

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QNCA070VLD ³ Autor ³Aldo Marini Junior      ³ Data ³ 24/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Retorna o numero da opcao correspondente a cor da situacao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QNCA070VLD(nOpc) - Cor correspondente                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpN1 = Numerico definindo a cor correspondente a situacao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QNCA070                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCA070VLD(nOpc)
Local nRet   := nOpc
Local lSair  := .F.
Local lAtivo := QA_SitFolh()
Local cFilUsr:= QAA->QAA_FILIAL
Local cMatUsr:= QAA->QAA_MAT


If (nOpc == 1 .Or. nOpc == 2 ) .And. !lAtivo
	nRet := 0
ElseIf (nOpc == 3 .Or. nOpc == 4 ) .And. lAtivo
	nRet := 0
Endif

If nRet > 0


	nRet := 0
	lSair := .F.
	BeginSql alias 'QI3TRB'
		SELECT QAA.QAA_FILIAL  FROM %table:QAA% QAA
		WHERE QAA.QAA_FILIAL= %exp:cFilUsr% AND QAA.QAA_MAT= %exp:cMatUsr% AND

		(EXISTS( SELECT R_E_C_N_O_ FROM %table:QI3% QI3 WHERE
			QI3.QI3_FILMAT=QAA.QAA_FILIAL AND
			QI3.QI3_MAT=QAA.QAA_MAT AND
			QI3.QI3_ENCREA = ' ' AND
			QI3.%notDel% )
		OR
		EXISTS( SELECT R_E_C_N_O_ FROM %table:QI2% QI2  WHERE
			QI2.QI2_FILMAT=QAA.QAA_FILIAL AND
			QI2.QI2_MATRES=QAA.QAA_MAT AND
			QI2.QI2_CONREA = ' ' AND
			QI2.%notDel%  )
		OR
		EXISTS( SELECT R_E_C_N_O_ FROM %table:QI5% QI5  WHERE
			QI5.QI5_FILMAT=QAA.QAA_FILIAL AND
			QI5.QI5_MAT=QAA.QAA_MAT AND
			QI5.QI5_STATUS <> '4' AND
			QI5.%notDel%  ))
	EndSql

	QI3TRB->(DBGotop())
	IF QI3TRB->(!EOF())
		If (nOpc == 2 .And. lAtivo) .Or. (nOpc == 4 .And. !lAtivo)
			lSair := .T.
			nRet := nOpc
		ElseIf (nOpc == 1 .And. lAtivo) .Or. (nOpc == 3 .And. !lAtivo)
			lSair := .T.
			nRet := 9
		Endif
	EndIF
	QI3TRB->(DbCloseArea())

    		DbSelectArea("QAA")

	If nRet == 9
		nRet := 0
	Endif
	If nOpc == 1 .Or. nOpc == 3 .And. !lSair
		nRet := nOpc
	Endif

Endif

Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QNCA070TRF ³ Autor ³Aldo Marini Junior      ³ Data ³ 25/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Transfere os lancamentos do Usuario                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QNCA070TRF()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QNCA070                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCA070TRF()

Local oDlg, oQI2, oQI3, oQI5
Local oMarcar, oCombOrd, oUsuarios, oPesq, oChk01, oChk02
Local lChk01   := .T.
Local lChk02   := .F.
Local lChk03   := .F.
Local oOk      := LoadBitmap( GetResources(), "LBTIK" )
Local oNo      := LoadBitmap( GetResources(), "LBNO" )
Local oSize
Local nRegQAA  := QAA->(Recno())
Local nOrdQAA  := QAA->(indexord())
Local nOldOrdU := 1
Local cCombOrd := 1
Local nOpcao   := 2
Local nArray   := 0
Local cMsg     := ""
Local cAttach  := ""
Local cMail    := ""
Local cQI2
Local cQI3
Local cQI5
Local aQI2     := {}
Local aQI3     := {}
Local aQI5     := {}
Local aUsrMat  := QNCUSUARIO()
Local aStatus  := {"  0%"," 25%"," 50%"," 75%","100%","Reprovado"}
Local aCombOrd := {OemToAnsi(STR0015),;		// "Matricula"
					OemToAnsi(STR0016),;	// "Nome"
					OemToAnsi(STR0017),;	// "Nome Reduzido"
					OemToAnsi(STR0018) } 	// "Depto"
Local lFolQI2 	:= .T.
Local lFolQI3 	:= .T.
Local lFolQI5 	:= .T.
Local lTMKPMS:= If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local cFiltUsr  := ""
Local aCposFiltr:= {}
Local cUsuQNC 	:= QAA->QAA_MAT
Local cFilQNC	:= QAA->QAA_FILIAL

Local aStruQI2 := FWFormStruct(3, "QI2",,.F.)[3]
Local nX

Private cTexto1   := QAA->QAA_FILIAL + " - " + QAA->QAA_MAT + " - " + QAA->QAA_NOME
Private oFolder1
Private lMarca 	  := .F.
Private aMsg 	  := {}
Private cMotTransf:= SPACE(30)
Private cFilMat   := xFilial("QAA")
Private lTrava	  := .F.
Private aTitPend  := {}
Private aPagPend  := {}
Private cGrupo	  := ""
Private aQI5Aux	  := {}

CursorWait()

For nX := 1 To Len(aStruQI2)
	If AllTrim(aStruQI2[nX,1]) $ "QI2_FILIAL;QI2_FNC;QI2_REV;QI2_TPFIC;QI2_CODCAT;QI2_CODPRO;QI2_CODACA;QI2_REVACA"
		AAdd(aCposFiltr, AllTrim(aStruQI2[nX,1]) )
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os Lactos Pendentes e de Transferencia QAB           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa({|| lTrava:=QNC070Pen(@aQI5,@aQI3,@aQI2,cFiltUsr,lChk03,cFilQNC,cUsuQNC)},OemToAnsi(STR0053) )    //"Carregando os lactos pendentes..."

IF !lTrava
	IF MsgYesNo(OemToAnsi(STR0054),OemToAnsi(STR0050))     //###"Atencao" //"Existem pendencias de Transferência deste usuario, Confirme! Para a realização destas Transferências."
		cMotTransf:=OemToAnsi(STR0019) // "Transferˆncia de Lancamentos pendentes"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava Tranferenciaa das pendencias     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QNC070Grv(@aQI5,@aQI3,@aQI2)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Limpa os Arrays apos a realizacao de Transferencia QAB      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aEval(aQI5,{|x| x[1]:=.F.,x[Len(x)]:=SPACE(12)})
		aEval(aQI3,{|x| x[1]:=.F.,x[Len(x)]:=SPACE(12)})
		aEval(aQI2,{|x| x[1]:=.F.,x[Len(x)]:=SPACE(12)})
	Endif
Endif

If Len(aQI5) == 0
	lFolQI5:=.F.
Else
	aadd(aTitPend,OemToAnsi(STR0033)) //	"Etapas/Passos"
	AaDD(aPagPend,"ETA")
Endif

If Len(aQI3) == 0
	lFolQI3:=.F.
Else
	aadd(aTitPend,OemToAnsi(STR0034)) //	"Plano de Acao"
	AaDD(aPagPend,"PLN")
Endif

If Len(aQI2) == 0
	lFolQI2:=.F.
Else
	aadd(aTitPend,OemToAnsi(STR0035)) // "Ficha de Ocorrencias/Nao-Conformidades"
	AaDD(aPagPend,"FNC")
Endif

If  !lFolQI5 .AND. !lFolQI3  .AND. !lFolQI2
	Help( " ", 1, "QNCNPENDU",,OemToAnsi(STR0038),1)	// "Nao existem pendencias para este Usuario"
	QI2->(dbSetOrder(4))
	QI3->(dbSetOrder(3))
	QI5->(dbSetOrder(2))
	Return Nil
EndIf

CursorArrow()
//------------------------------------------
oSize := FwDefSize():New(.T.)

oSize:AddObject( "CABECALHO"	,  100, 30, .T.,.F.)
oSize:AddObject( "MEIO"			,  100, 30, .T.,.T.)
oSize:AddObject( "BAIXO"	,  100, 40, .T.,.T.)

oSize:aMargins := { 3, 3, 0, 3 }

oSize:Process() // Dispara os calculos

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; // "Plano de Amostragem por Ensaio"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

DEFINE FONT oFnt NAME "Arial" SIZE 6,15 BOLD

@ oSize:GetDimension('CABECALHO'  , 'LININI'), oSize:GetDimension('CABECALHO'  , 'COLINI') TO;
 oSize:GetDimension('CABECALHO'  , 'LININI')+30, oSize:GetDimension('CABECALHO'  , 'COLINI')+270 LABEL  OemToAnsi(STR0020) OF oDlg PIXEL // "Usu rio"

@ oSize:GetDimension('CABECALHO'  , 'LININI')+13,  oSize:GetDimension('CABECALHO'  , 'COLINI')+4 SAY OemToAnsi(cTexto1) SIZE 195,010 OF oDlg PIXEL

@  oSize:GetDimension('CABECALHO'  , 'LININI'), oSize:GetDimension('CABECALHO'  , 'COLINI')+270 TO  oSize:GetDimension('CABECALHO'  , 'LININI')+30, 352 LABEL  OemToAnsi(STR0032) OF oDlg PIXEL // "Opcao"

@ oSize:GetDimension('CABECALHO'  , 'LININI')+8, oSize:GetDimension('CABECALHO'  , 'COLINI')+273 CHECKBOX oChk01 VAR lChk01 SIZE 62,06 OF oDlg PIXEL FONT oFnt ;
			  PROMPT OemToAnsi(STR0031) 	// "Todas Pendencias"
	@ oSize:GetDimension('CABECALHO'  , 'LININI')+16, oSize:GetDimension('CABECALHO'  , 'COLINI')+273 CHECKBOX oChk02 VAR lChk02 SIZE 62,06 OF oDlg PIXEL FONT oFnt ;
				  PROMPT OemToAnsi("Altera Grp. Etapas") 	// "Altera Gr. Etapas"
If lFolQI5 .And. lTMKPMS

	@ oSize:GetDimension('CABECALHO'  , 'LININI')+16, oSize:GetDimension('CABECALHO'  , 'COLINI')+273 CHECKBOX oChk02 VAR lChk02 SIZE 62,06 OF oDlg PIXEL FONT oFnt ;
				  PROMPT OemToAnsi("Altera Grp. Etapas") 	// "Altera Gr. Etapas"

	Define SButton From oSize:GetDimension('CABECALHO'  , 'LININI')+26, oSize:GetDimension('CABECALHO'  , 'COLINI')+273 Type 17 Action (cFiltUsr := BuildExpr('QI2',,cFiltUsr,.T.,,, aCposFiltr),;
											   lChk03 := .T.,;
											   QNC070Pen(aQI5,,,cFiltUsr,.T.,cFilQNC,cUsuQNC,@oQI5) ) Enable Of oDlg FONT oFnt

EndIf

@ oSize:GetDimension('MEIO'  , 'LININI'), oSize:GetDimension('MEIO'  , 'COLINI')TO;
 oSize:GetDimension('MEIO'  , 'LININI')+124, oSize:GetDimension('MEIO'  , 'COLINI')+351  ;
 LABEL  OemToAnsi(STR0021) OF oDlg PIXEL // "Tipos de Pendencias"

oFolder1 := TFolder():New(oSize:GetDimension('MEIO'  , 'LININI')+4,;
								oSize:GetDimension('MEIO'  , 'COLINI')+4,aTitPend,aPagPend,oDlg,,,,.T.,.F.,;
								oSize:GetDimension('MEIO'  , 'LININI')+270,;
								oSize:GetDimension('MEIO'  , 'COLINI')+113)

IF lFolQI5
	If lTMKPMS
		// Folder 1 - Etapas/Passos do Plano de Acao
		@ 001,005;
														LISTBOX oQI5 VAR cQI5 FIELDS HEADER " ",;
														Alltrim(TitSx3("QI5_FILIAL") [1]),;
														Alltrim(TitSx3("QI5_CODIGO") [1]),;
														Alltrim(TitSx3("QI2_FNC" )   [1]),;
	                                                Alltrim(TitSx3("QI5_STATUS") [1]),;
	                                                Alltrim(TitSx3("QI5_TPACAO") [1]),;
	                                                Alltrim(TitSx3("QI5_DESCTP") [1]),;
	                                                Alltrim(TitSx3("QI5_PRAZO" ) [1]),;
	                                                Alltrim(TitSx3("QI2_CODCAT" )[1]),;
	                                                Alltrim(TitSx3("QI2_CODPRO" )[1]),;
	                                                Alltrim(TitSx3("QI5_PROJET" )[1]),;
	                                                Alltrim(TitSx3("QI3_MODELO" )[1]),;
	                                                Alltrim(TitSx3("QI2_NCHAMA" )[1]);
		           SIZE oSize:GetDimension('MEIO'  , 'LININI')+288,oSize:GetDimension('MEIO'  , 'COLINI')+113 OF oFolder1:aDialogs[Ascan(aPagPend,"ETA")] PIXEL ;
		           ON DBLCLICK (QNCA070LCT(oQI5,@aQI5,lChk01,.F.) ,oQI5:Refresh(.T.))

		oQI5:SetArray(aQI5)
		oQI5:cToolTip:= OemToAnsi(STR0036) //"Duplo click para << MARCAR/DESMARCAR >> Pendˆncia"
		oQI5:bLine   := {||{ If(aQI5[oQI5:nAt,1],oOk,oNo),;
			aQI5[oQI5:nAt,2],;	                    //Filial
			Transform(aQI5[oQI5:nAt,3],PesqPict("QI3","QI3_CODIGO"))+"  "+aQI5[oQI5:nAt,4],;	// Codigo-Revisao Plano de Acao
			Transform(aQI5[oQI5:nAt,5],PesqPict("QI2","QI2_FNC"))+"  "+aQI5[oQI5:nAt,6],;	// Codigo-Revisao da FNC
			aStatus[Val(aQI5[oQI5:nAt,7])+1],;   	// Status da Acao
			aQI5[oQI5:nAt,8],;						// Tipo da Acao
			aQI5[oQI5:nAt,9],;						// Desc Tipo da Acao
			DTOC(aQI5[oQI5:nAt,10]),;				// Prazo/Vecto da Acao
			aQI5[oQI5:nAt,11],;  					// Categoria
			aQI5[oQI5:nAt,12],;                     // Produto
			aQI5[oQI5:nAt,13],;						// Projeto
 			aQI5[oQI5:nAt,14],;						// Modelo
			aQI5[oQI5:nAt,15]}}						// Chamado
		oQI5:bChange := { || IF(!Empty(aQI5[oQI5:nAt,Len(aQI5[oQI5:nAt])]),QNCA070Fun(@oUsuarios,aQI5[oQI5:nAt,Len(aQI5[oQI5:nAt])]),) }
	Else
				// Folder 1 - Etapas/Passos do Plano de Acao
		@ 001,005;
														LISTBOX oQI5 VAR cQI5 FIELDS HEADER " ",;
														Alltrim(TitSx3("QI5_FILIAL")[1]),;
														Alltrim(TitSx3("QI5_CODIGO")[1]),;
		                                               Alltrim(TitSx3("QI5_STATUS")[1]),;
		                                               Alltrim(TitSx3("QI5_TPACAO")[1]),;
		                                               Alltrim(TitSx3("QI5_DESCTP")[1]),;
		                                               Alltrim(TitSx3("QI5_DESCRE")[1]),;
		                                               Alltrim(TitSx3("QI5_PRAZO" )[1]);
		           SIZE oSize:GetDimension('MEIO'  , 'LININI')+265, oSize:GetDimension('MEIO'  , 'COLINI')+90 OF oFolder1:aDialogs[Ascan(aPagPend,"ETA")] PIXEL ;
		           ON DBLCLICK (QNCA070LCT(oQI5,@aQI5,lChk01,.F.) ,oQI5:Refresh(.T.))

		oQI5:SetArray(aQI5)
		oQI5:cToolTip:= OemToAnsi(STR0036) //"Duplo click para << MARCAR/DESMARCAR >> Pendˆncia"
		oQI5:bLine   := {||{ If(aQI5[oQI5:nAt,1]==.F.,oNO,oOK),;
			aQI5[oQI5:nAt,2],;	                    //Filial
			Transform(aQI5[oQI5:nAt,3],PesqPict("QI3","QI3_CODIGO"))+"  "+aQI5[oQI5:nAt,4],;	// Codigo-Revisao Plano de Acao
			aStatus[Val(aQI5[oQI5:nAt,5])+1],; 	// Status da Acao
			aQI5[oQI5:nAt,6],;						// Tipo da Acao
			aQI5[oQI5:nAt,7],;						// Desc Tipo da Acao
			aQI5[oQI5:nAt,10],;						// Descricao Resumida
			DTOC(aQI5[oQI5:nAt,8])}}				// Prazo/Vecto da Acao
		oQI5:bChange := { || IF(!Empty(aQI5[oQI5:nAt,Len(aQI5[oQI5:nAt])]),QNCA070Fun(@oUsuarios,aQI5[oQI5:nAt,Len(aQI5[oQI5:nAt])]),) }
	EndIf
Endif

IF lFolQI3
	// Folder 2 - Plano de Acao
	@ 001,005;
													LISTBOX oQI3 VAR cQI3 FIELDS HEADER " ",;
													Alltrim(TitSx3("QI3_FILIAL")[1]),;
													Alltrim(TitSx3("QI3_CODIGO")[1]),;
	                                               Alltrim(TitSx3("QI3_STATUS")[1]),;
	                                               Alltrim(TitSx3("QI3_ABERTU")[1]),;
	                                               Alltrim(TitSx3("QI3_ENCPRE")[1]),;
	                                               Alltrim(TitSx3("QI3_TIPO")[1]);
	           SIZE oSize:GetDimension('MEIO'  , 'LININI')+260, oSize:GetDimension('MEIO'  , 'COLINI')+90 OF oFolder1:aDialogs[Ascan(aPagPend,"PLN")] PIXEL ;
	           ON DBLCLICK (QNCA070LCT(oQI3,@aQI3,lChk01,.F.) ,oQI3:Refresh(.T.))

	oQI3:SetArray(aQI3)
	oQI3:cToolTip:= OemToAnsi(STR0036) //"Duplo click para << MARCAR/DESMARCAR >> Pendˆncia"
	oQI3:bLine   := {||{ If(aQI3[oQI3:nAt,1]==.F.,oNO,oOK),;
		aQI3[oQI3:nAt,2],;	       														//Filial
		Transform(aQI3[oQI3:nAt,3],PesqPict("QI3","QI3_CODIGO"))+"  "+aQI3[oQI3:nAt,4],;  //Codigo
		aQI3[oQI3:nAt,5],;                                                              //Status
		DTOC(aQI3[oQI3:nAt,6]),;                                                        //Abertura
		DTOC(aQI3[oQI3:nAt,7]),;                                                        //Encerramento previsto
		aQI3[oQI3:nAt,8]}}                                                              //Tipo
	oQI3:bChange := { || IF(!Empty(aQI3[oQI3:nAt,Len(aQI3[oQI3:nAt])]),QNCA070Fun(@oUsuarios,aQI3[oQI3:nAt,Len(aQI3[oQI3:nAt])]),) }
Endif

IF lFolQI2
	// Folder 3 - Ficha de Ocorrencias/Nao-conformidades
	@ 001,005;
													 LISTBOX oQI2 VAR cQI2 FIELDS HEADER " ", ;
											    		Alltrim(TitSx3("QI2_FILIAL")[1]),;
														Alltrim(TitSx3("QI2_STATUS")[1]),;
														Alltrim(TitSx3("QI2_PRIORI")[1]),;
														Alltrim(TitSx3("QI2_FNC")[1]),;
														Alltrim(TitSx3("QI2_DESCR")[1]),;
											    		Alltrim(TitSx3("QI2_OCORRE")[1]),;
											    		Alltrim(TitSx3("QI2_CONPRE")[1]);
				SIZE oSize:GetDimension('MEIO'  , 'LININI')+260,oSize:GetDimension('MEIO'  , 'COLINI')+90  OF oFolder1:aDialogs[Ascan(aPagPend,"FNC")] PIXEL ;
				ON DBLCLICK (QNCA070LCT(oQI2,@aQI2,lChk01,.F.) ,oQI2:Refresh(.T.))

	oQI2:SetArray(aQI2)
	oQI2:cToolTip:= OemToAnsi(STR0036) // "Duplo click para << MARCAR/DESMARCAR >> Pendˆncia"
	oQI2:bLine   := {||{If(aQI2[oQI2:nAt,1]==.F.,oNO,oOK),;
		aQI2[oQI2:nAt,2],;
		aQI2[oQI2:nAt,3],;
		aQI2[oQI2:nAt,8],;
		Transform(aQI2[oQI2:nAt,4],PesqPict("QI2","QI2_FNC"))+"  "+aQI2[oQI2:nAt,5],;
		aQI2[oQI2:nAt,6],;
		DtoC(aQI2[oQI2:nAt,9]),;
		DtoC(aQI2[oQI2:nAt,10]) }}
	oQI2:bChange := { || IF(!Empty(aQI2[oQI2:nAt,Len(aQI2[oQI2:nAt])]),QNCA070Fun(@oUsuarios,aQI2[oQI2:nAt,Len(aQI2[oQI2:nAt])]),) }
Endif

@ oSize:GetDimension('BAIXO'  , 'LININI')+15, oSize:GetDimension('BAIXO'  , 'COLINI')+5 BUTTON oPesq   PROMPT OemToAnsi(STR0029) ;		// "Pesquisar Usuario"
			  ACTION ( If(QNC070PUS()==.F.,QAA->(dbGoTop()),"") ,;
						If( oCombOrd:nAt == 1 .And. QAA->(IndexOrd()) <> 1, QAA->(dbSetOrder(1)),;
						If( oCombOrd:nAt == 2 .And. QAA->(IndexOrd()) <> 3, QAA->(dbSetOrder(3)),;
						If( oCombOrd:nAt == 3 .And. QAA->(IndexOrd()) <> 6, QAA->(dbSetOrder(6)),;
						If( oCombOrd:nAt == 4 .And. QAA->(IndexOrd()) <> 5, QAA->(dbSetOrder(5)),"")))), ;
			  			nOldOrdU := oCombOrd:nAt,oUsuarios:UpsTable(),oUsuarios:Refresh() ) ;
			  SIZE 53,12 PIXEL OF oDlg

@ oSize:GetDimension('BAIXO'  , 'LININI')+15, oSize:GetDimension('BAIXO'  , 'COLINI')+65 BUTTON oMarcar PROMPT OemToAnsi(STR0022) SIZE 135,12 PIXEL OF oDlg ; // "<< MARCAR/DESMARCAR USUARIOS >>"
			ACTION QNC070BUT(@oQI5,@oQI3,@oQI2,@aQI5,@aQI3,@aQI2,oFolder1:nOption,lChk01)

@ oSize:GetDimension('BAIXO'  , 'LININI')+17, oSize:GetDimension('BAIXO'  , 'COLINI')+205 SAY OemToAnsi(STR0030) SIZE 55,010 OF oDlg PIXEL //	"Ordena‡„o Usuarios:"
@ oSize:GetDimension('BAIXO'  , 'LININI')+15, oSize:GetDimension('BAIXO'  , 'COLINI')+261 COMBOBOX oCombOrd VAR cCombOrd ITEMS aCombOrd SIZE 58,70 PIXEL OF oDlg ;
			  ON CHANGE If( nOldOrdU <> oCombOrd:nAt,;
			  				(nOldOrdU := oCombOrd:nAt,;
							If( oCombOrd:nAt == 1, QAA->(dbSetOrder(1)) ,;
							If( oCombOrd:nAt == 2, QAA->(dbSetOrder(3)) ,;
							If( oCombOrd:nAt == 3, QAA->(dbSetOrder(6)) ,;
							                       QAA->(dbSetOrder(5)) ))) ,;
						   oUsuarios:UpsTable(),oUsuarios:Refresh() ) ,"")

@ 187, 003 TO 291,352 LABEL  OemToAnsi(STR0023) OF oDlg PIXEL // "Usuarios Destinos"
@ oSize:GetDimension('BAIXO'  , 'LININI')+30, oSize:GetDimension('BAIXO'  , 'COLINI') TO;
oSize:GetDimension('BAIXO'  , 'LININI')+124, oSize:GetDimension('BAIXO'  , 'COLINI')+351 LABEL  OemToAnsi(STR0023) OF oDlg PIXEL // "Usuarios Destinos"
@ oSize:GetDimension('BAIXO'  , 'LININI')+40, oSize:GetDimension('BAIXO'  , 'COLINI')+10 LISTBOX oUsuarios VAR cUsr; //143
			  FIELDS QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_NOME,QAA->QAA_APELID,QAA->QAA_CC+"-"+QA_NDEPT(QAA->QAA_CC,.F.,QAA->QAA_FILIAL) ;
			  HEADER OemToAnsi(STR0024),OemToAnsi(STR0025),OemToAnsi(STR0026),OemToAnsi(STR0017),OemToAnsi(STR0028) ;	// "Fil" ### "C¢digo" ### "Nome" ### "Nome Reduzido" ### "Depto"
			  ALIAS "QAA" ;
			  SIZE 333,077 PIXEL ;
			  OF oDlg

oUsuarios:GoTop()
oUsuarios:UpStable()
oUsuarios:Refresh()


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,;
										{||If(QNC070FIM( aClone(aQI5),aClone(aQI3),aClone(aQI2),oDlg,lChk02,cFilQNC,cUsuQNC),(nOpcao:=1,oDlg:End()),)},;
										{||(nOpcao:=2,oDlg:End())})

If nOpcao == 1	// OK
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Tranferenciaa das pendencias     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QNC070Grv(@aQI5,@aQI3,@aQI2,lChk02,cFilQNC,cUsuQNC,cFiltUsr)
Endif

dbSelectArea("QAA")
dbSetOrder(nOrdQAA)
dbGoTo(nRegQAA)

QI2->(dbSetOrder(4))
QI3->(dbSetOrder(3))
QI5->(dbSetOrder(2))

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCA070Fun ³ Autor ³ Aldo Marini Junior  ³ Data ³ 26.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza ponteiro de usuarios                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QNCA070Fun(oUsuarios,cChave)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oUsuarios= Objeto contendo os Usuarios                     ³±±
±±³          ³ cChave   = Caracter contendo a chave de pesquisa de usuario³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC070BUT(oQI5,oQI3,oQI2,aQI5,aQI3,aQI2,nFolderItem,lChk01)
Local cPaginas:= aPagPend[nFolderItem]

If QAA->QAA_STATUS <> "2"
	DO CASE
		CASE cPaginas == "ETA"	// Etapas
			QNCA070LCT(oQI5,@aQI5,lChk01,.T.)
			oQI5:Refresh()

		CASE cPaginas == "PLN"	// Plano de Acao
			QNCA070LCT(oQI3,@aQI3,lChk01,.T.)
			oQI3:Refresh()

		CASE cPaginas == "FNC"	// FNC
			QNCA070LCT(oQI2,@aQI2,lChk01,.T.)
			oQI2:Refresh()
	EndCASE
Else
	Help( " ", 1,"USRINATIVO",,OemToAnsi(STR0037),1 )	// "Usuario selecionado esta INATIVO"
Endif

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCA070Fun ³ Autor ³ Aldo Marini Junior  ³ Data ³ 26.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza ponteiro de usuarios                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QNCA070Fun(oUsuarios,cChave)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oUsuarios= Objeto contendo os Usuarios                     ³±±
±±³          ³ cChave   = Caracter contendo a chave de pesquisa de usuario³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCA070LCT(oArray,aArray,lChk01,lButton)

Local nArray := 0

IF QAA->QAA_STATUS =="2"
	Help( " ", 1,"USRINATIVO" )
	Return Nil
Endif

If cTexto1 == QAA->QAA_FILIAL + " - " + QAA->QAA_MAT + " - " + QAA->QAA_NOME
	Help(" ",1,"QADUSRTRF",, OemToAnsi(STR0055),1)        //"Usuário não pode Transferir ele mesmo."
	Return Nil
Endif

If Len(aArray) > 0
	If lChk01 .And. lButton
		lMarca := !lMarca
		For nArray := 1 to Len(aArray)
			aArray[nArray,1] := lMarca
			If lMarca
				aArray[nArray,Len(aArray[nArray])] := QAA->QAA_FILIAL+QAA->QAA_MAT
			Else
				aArray[nArray,Len(aArray[nArray])] := Space(12)
			Endif
		Next
	Else
		aArray[oArray:nAt,1] := !(aArray[oArray:nAt,1])
		If aArray[oArray:nAt,1] == .T.
			aArray[oArray:nAt,Len(aArray[oArray:nAt])] := QAA->QAA_FILIAL+QAA->QAA_MAT
		Else
			aArray[oArray:nAt,Len(aArray[oArray:nAt])] := Space(12)
		Endif
	Endif
Endif

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCA070Fun ³ Autor ³ Aldo Marini Junior  ³ Data ³ 26.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza ponteiro de usuarios                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QNCA070Fun(oUsuarios,cChave)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oUsuarios= Objeto contendo os Usuarios                     ³±±
±±³          ³ cChave   = Caracter contendo a chave de pesquisa de usuario³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QNCA070Fun(oUsuarios,cChave)

Local nOrdem:= QAA->(Indexord())

QAA->(dbSetOrder(1))
If !QAA->(dbSeek(cChave))
	oUsuarios:GoTop()
Endif

QAA->(dbSetOrder(nOrdem))

oUsuarios:UpStable()
oUsuarios:Refresh()

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC070Telas³ Autor ³ Eduardo de Souza     ³ Data ³ 05/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela Cadastro de Usuarios                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC070Telas(ExpC1,ExpN1,ExpN2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do arquivo                                   ³±±
±±³          ³ ExpN1 - Numero do registro                                 ³±±
±±³          ³ ExpN2 - Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC070Telas(cAlias,nReg,nOpc)

Local oDlg
Local nI     := 0
Local nOpcao := 0
Local nSaveSx8 := GetSX8Len()
Local lRet   := .T.
Local lTMKPMS:= If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local cParticip  := ""
Local cRecurso	 := ""
Local cOperador	 := ""
Local oEnchoice
Local aMsSize	:= MsAdvSize()

Private lAltUsr:= .F.
Private lIntGPE:= If(GetMv("MV_QGINT",.F.,"N") == "S",.T.,.F.)
Private bCampo := {|nCPO| Field( nCPO ) }
Private aTELA[0][0]
Private aGETS[0]

DbSelectArea("QAA")
DbSetOrder(1)
Set Filter To

If nOpc == 3
   For nI := 1 To FCount()
       cCampo := Eval( bCampo, nI )
       lInit  := .F.
       If ExistIni( cCampo )
          lInit := .T.
          M->&( cCampo ) := InitPad( GetSX3Cache(cCampo,"X3_RELACAO") )
          If ValType( M->&( cCampo ) ) = "C"
             M->&( cCampo ) := PADR( M->&( cCampo ), GetSX3Cache(cCampo,"X3_TAMANHO") )
          EndIf
          If M->&( cCampo ) == Nil
             lInit := .F.
          EndIf
       EndIf
       If !lInit
          M->&( cCampo ) := FieldGet( nI )
          If ValType( M->&( cCampo ) ) = "C"
             M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
          ElseIf ValType( M->&( cCampo ) ) = "N"
             M->&( cCampo ) := 0
          ElseIf ValType( M->&( cCampo ) ) = "D"
             M->&( cCampo ) := CtoD( "  /  /  " )
          ElseIf ValType( M->&( cCampo ) ) = "L"
             M->&( cCampo ) := .f.
          EndIf
       EndIf
	Next nI
	M->QAA_FILIAL:= xFilial("QAA")
Else
   For nI := 1 To FCount()
       M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
   Next nI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variavel utilizada para bloquear os campos que nao podem ser alterados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIntGPE .And. (INCLUI .Or. M->QAA_TPUSR == "1")
	lAltUsr:= .T.
EndIf

If lRet
//	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 000,000 TO 385,625 PIXEL // "Responsaveis/Usuarios"
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 000,000 To aMsSize[6]-40,aMsSize[5]-350  OF oMainWnd PIXEL

	oDlg:lMaximized := .T.

	oEnchoice := Msmget():New("QAA",nReg,nOpc,,,,,{014,002,190,312})

	oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	If nOpc == 2 .Or. nOpc == 5
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{ || If(nOpc == 5,If(QNC070Dele(),oDlg:End(),.F.),oDlg:End() )},{|| oDlg:End()}) CENTERED
	ElseIf nOpc == 3 .Or. nOpc == 4
	    If !lTMKPMS
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(QNC070TOK(lTMKPMS),(QNC070GrUs(nOpc),nOpcao := 1,oDlg:End()),)},{|| oDlg:End()}) CENTERED
		Else
			If nOpc == 4
				cRecurso  := QAA->QAA_RECUR
				cParticip := QAA->QAA_PARTIC
				cOperador := QAA->QAA_OPERAD
			Endif
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(QNC070TOK(lTMKPMS),(QNC070GrUs(nOpc,cParticip,cRecurso,cOperador),nOpcao := 1,oDlg:End()),)},{|| oDlg:End()}) CENTERED
		Endif
	EndIf

	If !lUsrInat
		Set Filter To
	Else
		MsgRun(OemToAnsi(STR0047),OemToAnsi(STR0044),{||Q070Filtro()}) //"Selecionando Usu rios" ### "Aguarde..."
	Endif

	While (GetSX8Len() > nSaveSx8)
		If nOpcao == 1
		   	ConfirmSX8()
		Else
			RollBackSX8()
		Endif
	Enddo

Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC070GrUs³ Autor ³ Eduardo de Souza      ³ Data ³ 05/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Usuarios                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC070GrUs(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC070GrUs(nOpc,cParticip,cRecurso,cOperador)

Local lRecLock:= .F.
Local nI      := 0
Local lTMKPMS:= If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local lRetAE8 := .T.
Local lRetSU7 := .T.
Local lRetALL := .F.

Default cParticip  := ""
Default cRecurso   := ""
Default cOperador  := ""

If nOpc == 3
	lRecLock:= .T.
EndIf

Begin Transaction

	If lTMKPMS
        cParticip := M->QAA_PARTIC
       	cRecurso  := M->QAA_RECUR
	   	cOperador := M->QAA_OPERAD

        lRetALL := QN070Chk(cParticip,cRecurso,cOperador)

        If lRetALL
	        If !lIntGPE
				QNC070RDZ(cParticip,"QAA",xFilial("QAA")+M->QAA_MAT, 1,cEmpAnt,cFilAnt,M->QAA_PARTIC)
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄx¿
				//³Qdo o codigo do usuario é gerado via integração, o seu código    ³
				//³ja consta no formato Empresa+Filial+codigo.		            	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄxÙ
				QNC070RDZ(cParticip,"QAA",xFilial("QAA")+M->QAA_MAT,1,cEmpAnt,cFilAnt,M->QAA_PARTIC)
			Endif

			lRetAE8 := QN070ChkAE8(cRecurso)
			If lRetAE8
				QNC070RDZ(cParticip,"AE8",xFilial("AE8")+cRecurso, 1,cEmpAnt,cFilAnt,M->QAA_RECUR)
			Else
				MsgAlert("Este recurso encontra-se relacionado a outro usuário","Aviso")
				lRet := .F.
			EndIf

			lRetSU7 := QN070ChkSU7(cOperador)
			If lRetSU7
				QNC070RDZ(cParticip,"SU7",xFilial("SU7")+cOperador ,1 ,cEmpAnt    ,cFilAnt,M->QAA_OPERAD)
			Else
				MsgAlert("Este operador encontra-se relacionado a outro usuário","Aviso")
				lRet := .F.
			EndIf

			DbSelectArea("AE8")
			DbSetOrder(1)

			If AE8->(DbSeek(xFilial("AE8")+cRecurso))
				If Empty(AE8->AE8_CODRD0)
					RecLock("AE8",.F.)
					AE8->AE8_CODRD0 := cRecurso
					MsUnLock()
				EndIf
			EndIf
	  	EndIf
	Endif

If valAltFunc()==.T.
EndIf

	DbSelectArea("QAA")
	M->QAA_LOGIN:= UPPER(M->QAA_LOGIN)
	RecLock("QAA",lRecLock)
		For nI := 1 TO FCount()
			FieldPut(nI,M->&(Eval(bCampo,nI)))
		Next nI
	MsUnLock()

	QNCATULEG(QAA->QAA_FILIAL,QAA->QAA_MAT)//Atualiza legenda do usuários na alteração.

End Transaction

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QNC070Dele ³ Autor ³ Eduardo de Souza    ³ Data ³ 05/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exclusao de registros do Cadastro de Usuarios              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC070Dele()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC070Dele()

Local lRet   := .F.
Local nOrdQI2:= 0
Local nOrdQI3:= 0
Local nOrdQI4:= 0
Local nOrdQI5:= 0
Local nOrdQIE:= 0
Local nOrdQIF:= 0
Local cModoQAA  := ""
Local cTMKPMS	:= Str(GetNewPar("MV_QTMKPMS",1),1)
Local lTMKPMS:= If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local lRetTMK := .T.
Local lRetPMS := .T.

If lIntGpe .And. M->QAA_TPUSR == "1" .And. !lTMKPMS

	If SubStr(QAA->QAA_MAT,1,FWSizeFilial()+2) <> cEmpAnt+cFilAnt
		__cFilAnt := cFilAnt
		__cEmpAnt := cEmpAnt

		IF !fAbrEmpresa("SRA",1,SubStr(QAA->QAA_MAT,1,2),SubStr(QAA->QAA_MAT,3,FWSizeFilial()),@cModoQAA)
			MsgAlert(OemToAnsi(STR0051 )+" SRA",OemToAnsi(STR0050)) // "Nao foi possivel encontrar o arquivo" ### "Atencao"
			Return .F.
		Endif
		If QUASRA->(dbSeek(SubStr(QAA->QAA_MAT,3,FWSizeFilial())+SubStr(QAA->QAA_MAT,FWSizeFilial()+1,6)))
			lRet := .T.
		Endif

		cFilAnt := __cFilAnt
		cEmpAnt := __cEmpAnt

		fFecEmpresa("QUASRA")

	Else
		If SRA->(dbSeek(SubStr(QAA->QAA_MAT,3,FWSizeFilial())+SubStr(QAA->QAA_MAT,FWSizeFilial()+1,6)))
			lRet := .T.
		Endif
	Endif

Endif

If !lRet .And. (!lIntGpe .Or. M->QAA_TPUSR <> "1")
	nOrdQI2:= QI2->(IndexOrd())
	nOrdQI3:= QI3->(IndexOrd())
	nOrdQI4:= QI4->(IndexOrd())
	nOrdQI5:= QI5->(IndexOrd())
	nOrdQIE:= QIE->(IndexOrd())
	nOrdQIF:= QI5->(IndexOrd())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VALIDACAO DO QNC QUANDO EXISTIR INTEGRACAO TMK X PMS X QNC ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTMKPMS $ "2|3|4"
		lRetTMK := If(cTMKPMS $ "2|4" ,Tk090IntDel(QAA->QAA_PARTIC),.T.)
		lRetPMS := If(cTMKPMS $ "3|4" ,PMSDelRec(QAA->QAA_PARTIC),.T.)
	EndIf

	MsgRun(OemToAnsi(STR0045),OemToAnsi(STR0046),{|| lRet:= Iif(FindFunction("QAAValExc"), QAAValExc(), .F.) }) // "Validando Exclusao de Usuarios..." ### "Aguarde..."
	If lRet
		Begin Transaction
			If RecLock("QAA",.F.)
				QAA->(DbDelete())
				MsUnlock()
				QAA->(DbSkip())
			Endif
		End Transaction
	EndIf
	QI2->(DbSetOrder(nOrdQI2))
	QI3->(DbSetOrder(nOrdQI3))
	QI4->(DbSetOrder(nOrdQI4))
	QI5->(DbSetOrder(nOrdQI5))
	QIE->(DbSetOrder(nOrdQIE))
	QIF->(DbSetOrder(nOrdQIF))
Else
  	Help(" ",1,"QX10EXGPE") // "O Usuario somente podera ser excluido pelo modulo Gestao de Pessoal."
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QNC070VExc ³ Autor ³ Eduardo de Souza    ³ Data ³ 05/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida Exclusao de Usuarios                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC070VExc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC070VExc()

Local nOrd01  := 0
Local cIndex  := ""
Local cKey    := ""
Local cFiltro := ""
Local lApaga  := .T.
Local QTD	  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CADASTRO DAS NAO CONFORMIDADES                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga

	cAlias := GetNextAlias()
	cQuery := "Select Count (*)  QTD"
	cQuery += " From " + RetSqlName("QI2") + " QI2 "
	cQuery += " Where QI2.QI2_FILMAT = '" + QAA->QAA_FILIAL + "'
	cQuery += " AND QI2.QI2_MAT = '" + QAA->QAA_MAT + "'
	cQuery += " OR (QI2.QI2_FILRES = '" + QAA->QAA_FILIAL + "'
	cQuery += " AND QI2.QI2_MATRES = '" + QAA->QAA_MAT + "' )
	cQuery += " AND QI2.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

	If (cAlias)->QTD > 0
		lApaga := .F.
	Endif

	dbSelectArea(cAlias)
	dbCloseArea()

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CADASTRO DAS ACOES                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	cQuery := "Select Count (*)  QTD"
	cQuery += " From " + RetSqlName("QI3") + " QI3 "
	cQuery += " Where QI3.QI3_FILMAT = '" + QAA->QAA_FILIAL + "' and "
	cQuery += "       QI3.QI3_MAT = '" + QAA->QAA_MAT + "' and "
	cQuery += "       QI3.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)

	If Qtd > 0
		lApaga := .F.
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ACAO CORRETIVA X EQUIPE                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QI4->(IndexOrd())
	DbSelectarea("QI4")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QI4_FILMAT+QI4_MAT"
	cFiltro := "QI4->QI4_FILMAT+QI4->QI4_MAT == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QI4",cIndex,cKey,,cFiltro,OemToAnsi(STR0045)) //"Validando Exclusao..."
	If QI4->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QI4")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QI4->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ACAO CORRETIVA X ACOES                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	cQuery := "Select Count (*)  QTD"
	cQuery += " From " + RetSqlName("QI5") + " QI5 "
	cQuery += " Where QI5.QI5_FILMAT = '" + QAA->QAA_FILIAL + "' and "
	cQuery += "       QI5.QI5_MAT = '" + QAA->QAA_MAT + "' and "
	cQuery += "       QI5.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)

	If Qtd > 0
		lApaga := .F.
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ DOCUMENTOS ANEXO PLANO/ETAPAS                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QIE->(IndexOrd())
	DbSelectarea("QIE")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QIE_FILMAT+QIE_MAT"
	cFiltro := "QIE->QIE_FILMAT+QIE->QIE_MAT == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QIE",cIndex,cKey,,cFiltro,OemToAnsi(STR0045)) //"Validando Exclusao..."
	If QIE->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QIE")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QIE->(DbSetOrder(nOrd01))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ DOCUMENTOS ANEXO FICHAS                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	nOrd01:= QIF->(IndexOrd())
	DbSelectarea("QIF")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QIF_FILMAT+QIF_MAT"
	cFiltro := "QIF->QIF_FILMAT+QIF->QIF_MAT == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
	IndRegua("QIF",cIndex,cKey,,cFiltro,OemToAnsi(STR0045)) //"Validando Exclusao..."
	If QIF->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QIF")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QIF->(DbSetOrder(nOrd01))
EndIf

Return lApaga

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q070Filtro ³ Autor ³Aldo Marini Junior    ³ Data ³31/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Filtra os Usuarios/Responsaveis Inativos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q070Filtro()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA070													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q070Filtro()
Local cFiltro := Qa_FilSitF() //"ativo"

oBrowse:SetFilterDefault(cFiltro)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QNCA070Vrf ³ Autor ³ Aldo Marini Junior   ³ Data ³31/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Filtra alternadamente Usuarios Inativos e/ou Ativos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QNCA070Vrf()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA070Vrf                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCA070Vrf()
lUsrInat:= !lUsrInat

If !lUsrInat
	oBrowse:SetFilterDefault("QAA->QAA_STATUS <> '*'")
Else
	MsgRun(OemToAnsi(STR0047),OemToAnsi(STR0044),{||Q070Filtro()}) //"Selecionando Usu rios" ### "Aguarde..."
Endif

Return(NIL)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fAbrEmpresa	  ³ Autor ³Wilson de Godoy        ³ Data ³03/01/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Abre o Arquivo da Outra Empresa                        			³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ cAlias - Alias do Arquivo a Ser Aberto							³
³          ³ nOrdem - Ordem do Indice              							³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fAbrEmpresa(cAlias,nOrdem,cEmpAte,cFilAte,cModo)
Local lRet

IF ( lRet := MyEmpOpenFile("QUA"+cAlias,cAlias,nOrdem,.t.,cEmpAte,@cModo) )
	dbSelectArea( "QUA"+cAlias )
Else
	MsgAlert( OemToAnsi( STR0051+" "+ cAlias )  ) //"Nao foi possivel encontrar o arquivo"
EndIF

Return( lRet )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fFecEmpresa	  ³ Autor ³Wilson de Godoy        ³ Data ³03/01/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Fecha o Arquivo da Outra Empresa                        		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ cAlias - Alias do Arquivo a Ser Fechado						³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fFecEmpresa( cAlias )

IF Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
EndIF

Return( .T. )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³MyEmpOpenFile ³ Autor ³Wilson de Godoy        ³ Data ³03/01/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Abre Arquivo de Outra Empresa                         			³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³x1 - Alias com o Qual o Arquivo Sera Aberto                  	³
³          ³x2 - Alias do Arquivo Para Pesquisa e Comparacao                ³
³          ³x3 - Ordem do Arquivo a Ser Aberto                              ³
³          ³x4 - .T. Abre e .F. Fecha                                       ³
³          ³x5 - Empresa                                                    ³
³          ³x6 - Modo de Acesso (Passar por Referencia)                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function MyEmpOpenFile(x1,x2,x3,x4,x5,x6)
Local cSavE := cEmpAnt, cSavF := cFilAnt, xRet
cEmpAnt := __cEmpAnt
cFilAnt := __cFilAnt
xRet	:= EmpOpenFile(@x1,@x2,@x3,@x4,@x5,@x6)
cEmpAnt := cSavE
cFilAnt := cSavF

Return( xRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNC070FIM ºAutor  ³Telso Carneiro      º Data ³  16/09/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica e Libera a Transferência                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCA070TRF()                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QNC070FIM(alQI5,alQI3,alQI2,oDlg,lChk02,cFilQNC,cUsuQNC)
Local lRet		:=.F.
Local nI 		:= 0
Local oDlgC
Local oSize
Local aCof		:= {}
Local oCof
Local cCof
Local cFilDe	:= Space(FWSizeFilial())
Local cMatDe	:= ""
Local cFilPara	:= Space(FWSizeFilial())
Local cMatPara	:= ""
Local lTemQI2	:= .F.
Local lTemQI3	:= .F.
Local lTemQI5	:= .F.
Local cTMKPMS	:= Str(GetNewPar("MV_QTMKPMS",1),1)

Default lChk02  := .F.

For nI := 1 to Len(alQI5)
	IF alQI5[nI,1]
		lTemQI5:=.T.
		Exit
	Endif
Next
For nI := 1 to Len(alQI3)
	IF alQI3[nI,1]
		lTemQI3:=.T.
		Exit
	Endif
Next
For nI := 1 to Len(alQI2)
	IF alQI2[nI,1]
		lTemQI2:=.T.
		Exit
	Endif
Next

IF lTemQI2 .OR. lTemQI3 .OR. lTemQI5
	IF lTemQI5
		If lChk02
			cGrupo 	 := QNC070Grp()
		EndIf
		For nI :=1 TO Len(alQI5 )
			If (alQI5[nI,1])
				If cTMKPMS > "1"
					QI5->(dbGoTo(alQI5[nI,17])) //Recno
				Else
					QI5->(dbGoTo(alQI5[nI,9])) //Recno
				EndIf
				If ((cTMKPMS > "1") .AND.(lChk02 = .T.))

					cGrpDe   := alQI5[nI][14]

					AADD(aCof,{aTitPend[Ascan(aPagPend,"ETA")] ,;
					alQI5[nI,2],;	                    //Filial
					Transform(alQI5[nI,3],PesqPict("QI5","QI5_CODIGO"))+"  "+alQI5[nI,4],; // Codigo-Revisao Plano de Acao
					cGrpDe,; 		//Grupo De
					cGrupo}) 			//Grupo Para
				Else
					cFilDe	:= cFilQNC
					cMatDe	:= cUsuQNC
					cFilPara:= SubStr(alQI5[nI,len(alQI5[nI])],1,FWSizeFilial())
					cMatPara:= SubStr(alQI5[nI,len(alQI5[nI])],FWSizeFilial()+1,TamSX3("QI5_MAT")[1])

					QnTrfPMS (cMatDe,alQI5[nI])
				   	AADD(aCof,{aTitPend[Ascan(aPagPend,"ETA")] ,;
					alQI5[nI,2],;	                    //Filial
					Transform(alQI5[nI,3],PesqPict("QI5","QI5_CODIGO"))+"  "+alQI5[nI,4],; // Codigo-Revisao Plano de Acao
					cFilDe+"-"+cMatDe+" "+QA_NUSR(cFilDe,cMatDe),; 			//DE
					cFilPara+"-"+cMatPara+" "+QA_NUSR(cFilPara,cMatPara)}) //PARA
				EndIf
			Endif
		Next
	Endif
	IF lTemQI3
		For nI :=1 TO Len(alQI3 )
			If (alQI3[nI,1])
				QI3->(dbGoTo(alQI3[nI,9])) //Recno
				cFilDe	:= QI3->QI3_FILMAT
				cMatDe	:= QI3->QI3_MAT
				cFilPara:= SubStr(alQI3[nI,len(alQI3[nI])],1,FWSizeFilial())
				cMatPara:= SubStr(alQI3[nI,len(alQI3[nI])],FWSizeFilial()+1,TamSX3("QI5_MAT")[1])

				AADD(aCof,{aTitPend[Ascan(aPagPend,"PLN")],;
				alQI3[nI,2],;	                    //Filial
				Transform(alQI3[nI,3],PesqPict("QI3","QI3_CODIGO"))+"  "+alQI3[nI,4],; // Codigo-Revisao Plano de Acao
				cFilDe+"-"+cMatDe+" "+QA_NUSR(cFilDe,cMatDe),; 			//DE
				cFilPara+"-"+cMatPara+" "+QA_NUSR(cFilPara,cMatPara)}) //PARA
			Endif
		Next
	Endif
	IF lTemQI2
		For nI :=1 TO Len(alQI2 )
			If (alQI2[nI,1])
				QI2->(dbGoTo(alQI2[nI,7]))
				cFilDe	:= QI2->QI2_FILRES
				cMatDe	:= QI2->QI2_MATRES
				cFilPara:= SubStr(alQI2[nI,len(alQI2[nI])],1,FWSizeFilial())
				cMatPara:= SubStr(alQI2[nI,len(alQI2[nI])],FWSizeFilial()+1,TamSX3("QI5_MAT")[1])

				AADD(aCof,{aTitPend[Ascan(aPagPend,"FNC")],;
				alQI2[nI,2],;	                    //Filial
				Transform(alQI2[nI,4],PesqPict("QI2","QI2_FNC"))+"  "+alQI2[nI,5],; // Codigo-Revisao FNC
				cFilDe+"-"+cMatDe+" "+QA_NUSR(cFilDe,cMatDe),; 			//DE
				cFilPara+"-"+cMatPara+" "+QA_NUSR(cFilPara,cMatPara)}) //PARA
			Endif
		Next
	Endif

oSize := FwDefSize():New(.T.)

oSize:AddObject( "CABECALHO"	,  100, 100, .T.,.T.)

oSize:aMargins := { 3, 3, 0, 3 }

oSize:Process()

DEFINE MSDIALOG oDlgC TITLE OemToAnsi(STR0056) ; //"Confirmação de Transferências"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

	If cTMKPMS > "1" .AND. lChk02
			@oSize:GetDimension('CABECALHO'  , 'LININI'), oSize:GetDimension('CABECALHO'  , 'COLINI');
			LISTBOX oCof VAR cCof FIELDS HEADER ;
			OemToAnsi(STR0021),; //"Tipos de Pendencias"
			OemToAnsi(STR0024),; //"Fil"
			OemToAnsi(STR0025),; //"C¢digo"
			OemToAnsi("Do Grupo de Etapas"),;   //"Transferências realizadas (DE): "
			OemToAnsi("Para o Grupo de Etapas");    //"Transferências realizadas (PARA): "
		    COLSIZES NIL,NIL,NIL,120,120 ;
			SIZE oSize:GetDimension('CABECALHO'  , 'XSIZE'), oSize:GetDimension('CABECALHO'  , 'YSIZE') OF oDlgC PIXEL

		oCof:SetArray(aCof)
		oCof:bLine := {|| aCof[oCof:nAt] }

	Else
		@oSize:GetDimension('CABECALHO'  , 'LININI'), oSize:GetDimension('CABECALHO'  , 'COLINI');
			LISTBOX oCof VAR cCof FIELDS HEADER ;
			OemToAnsi(STR0021),; //"Tipos de Pendencias"
			OemToAnsi(STR0024),; //"Fil"
			OemToAnsi(STR0025),; //"C¢digo"
			OemToAnsi(STR0057),;   //"Transferências realizadas (DE): "
			OemToAnsi(STR0058);    //"Transferências realizadas (PARA): "
		    COLSIZES NIL,NIL,NIL,120,120 ;
			SIZE oSize:GetDimension('CABECALHO'  , 'XSIZE'), oSize:GetDimension('CABECALHO'  , 'YSIZE') OF oDlgC PIXEL

		oCof:SetArray(aCof)
		oCof:bLine := {|| aCof[oCof:nAt] }
	EndIf

	ACTIVATE MSDIALOG oDlgC CENTERED ON INIT EnchoiceBar(oDlgC,{|| lRet:=.T.,oDlgC:End()},{|| lRet:= .F.,oDlgC:End()} )

	IF lRet
		lRet:= MsgYesNo(OemToAnsi(STR0049),OemToAnsi(STR0050)) .And. QNC070Jus(oDlg)  //"Confirma Transferencia de Lancamentos Pendentes ?"###"Atencao"
	Endif
Endif

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QNC070Jus  ³ Autor ³Telso Carneiro        ³ Data ³16/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Tela de Justificativa (Motivo)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QNC070Jus(oDlg) 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QNCA070TRF()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QNC070Jus(oDlg)

Local oMotTransf
Local lGrava	:= .F.
Local oDlgTransf

DEFINE MSDIALOG oDlgTransf TITLE OemToAnsi(STR0059) FROM 150,000 TO 230,280 OF oDlg PIXEL    //"Motivo da Transferência"

@ 005,005 MSGET oMotTransf VAR cMotTransf SIZE 130,010 OF oDlgTransf PIXEL

DEFINE SBUTTON FROM 021,075 TYPE 1 ENABLE OF oDlgTransf;
ACTION  (If(NaoVazio(cMotTransf),(lGrava := .T.,oDlgTransf:End()),));

DEFINE SBUTTON FROM 021,105 TYPE 2 ENABLE OF oDlgTransf;
ACTION  (lGrava := .F.,oDlgTransf:end());

ACTIVATE MSDIALOG oDlgTransf CENTERED

Return lGrava

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNC070PUS ºAutor  ³Telso Carneiro      º Data ³ 27/09/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela de Pesquisa do Usuario para definir a Filial/Codigo    º±±
±±º          ³												              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QNCA070TRF                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QNC070PUS()

Local lRet:= .T.
Local oDlgU
Local oFilUsr
Local cFilUsr := xFilial("QAA")
Local oCodUsr
Local oDesUsr
Local cCodUsr:= Space(TamSx3("QAA_MAT" )[1])
Local cDesUsr:= Space(TamSx3("QAA_NOME")[1])

DEFINE MSDIALOG oDlgU FROM 000,000 TO 160,470 TITLE OemToAnsi(STR0001) PIXEL  //"Pesquisar"

@ 020,003 TO 065,233 LABEL OemToAnsi(STR0020) OF oDlgU PIXEL    //"Usuário"

@ 030,006 SAY OemToAnsi(STR0024) SIZE 010,008 OF oDlgU PIXEL  //"Fil"
@ 040,006 MSGET oFilUsr VAR cFilUsr PICTURE Repl("@!",FWSizeFilial()) F3 "SM0" SIZE 055,008 OF oDlgU PIXEL ;
VALID QA_CHKFIL(cFilUsr,@cFilMat)

@ 030,070 SAY OemToAnsi(STR0025) SIZE 044,008 OF oDlgU PIXEL   //"C¢digo"
@ 040,070 MSGET oCodUsr VAR cCodUsr PICTURE '@!' F3 "QDE" SIZE 044,008 OF oDlgU PIXEL ;
VALID (cDesUsr:= QA_NUSR(cFilUsr,cCodUsr,.T.),	oDesUsr:Refresh(),QA_CHKMAT(cFilUsr,cCodUsr))

@ 030,125 SAY OemToAnsi(STR0026) SIZE 85,008 OF oDlgU PIXEL   //"Nome"
@ 040,125 MSGET oDesUsr VAR cDesUsr SIZE 85,008 OF oDlgU PIXEL WHEN .f.



ACTIVATE MSDIALOG oDlgU CENTERED ON INIT EnchoiceBar(oDlgU,{|| lRet:=.T., oDlgU:End()},{|| lRet:=.F., oDlgU:End()} )

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNC070Pen ºAutor  ³Telso Carneiro      º Data ³ 27/09/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega nos Arrays as Pendencias de Transferencias QAB      º±±
±±º          ³e pendencias Atuais de FNC e/ou Planos de Acao e/ou Etapas  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QNCA070TRF()                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

STATIC Function QNC070Pen(aQI5,aQI3,aQI2,cFiltUsr,lChk03,cFilQNC, cUsuQNC,oQI5)

Local nI		:= 0
Local nIs		:= 0
Local lRet		:= .T.
Local cFiltro   := ""
Local cKey      := ""
Local aBuscaPed := {}
Local aRecTrf   := {}
Local cFilAtu   := Space(FWSizeFilial())
Local cMatAtu   := ""
Local aQI2Sit   := {}
Local aQI3Sit   := {}
Local aQI2Pri   := {}
Local aQTipo    := {}
Local cQuery	:= ""
Local cQryQI2	:= ""
Local cQryQI3	:= ""
Local cAlias	:= "QI5"
Local cAlias1	:= ""
Local cAliasQI2 := "QI2"
Local cAliasQI3 := "QI3"
Local cQueryInt	:= ""
Local lFiltro	:= .F.
Local lTMKPMS	:= If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local bLine     := If(lChk03 , oQI5:bLine , {|| .T.} )
Local lDBF		:= .F.

Default lChk03   := .F.
Default cFilQNC	 := Space(FWSizeFilial())
Default cUsuQNC	 := ""
Default cFiltUsr := ""

Default aQI2 := {}
Default aQI3 := {}
Default aQI5 := {}

QNCCBOX("QI2_STATUS",@aQI2Sit)
QNCCBOX("QI3_STATUS",@aQI3Sit)
QNCCBOX("QI2_PRIORI",@aQI2Pri)
QNCCBOX("QI3_TIPO"  ,@aQTipo)

ProcRegua(2)

IncProc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os Lactos de Transferencia e QAB                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAtu	 := cFilQNC //QAA->QAA_FILIAL
cMatAtu  :=	cUsuQNC //QAA->QAA_MAT
aAdd(aBuscaPed,{cFilAtu,cMatAtu})

DbSelectArea("QAB")
DbSetOrder(2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os Lactos de Transferencia e Matricula atual         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If QAB->(DbSeek(cFilAtu+cMatAtu))
	While QAB->(!Eof()) .And. QAB->QAB_FILP + QAB->QAB_MATP == cFilAtu + cMatAtu
		If Ascan(aRecTrf,QAB->(Recno())) > 0
			QAB->(DbSkip())
			Loop
		Else
			Aadd(aRecTrf,QAB->(Recno()))
		Endif
		If QAB->QAB_FILP+QAB->QAB_MATP == cFilAtu+cMatAtu
			If QAB->QAB_FILP+QAB->QAB_MATP <> QAB->QAB_FILD+QAB->QAB_MATD
				If Ascan(aBuscaPed,{|X| X[1]+X[2] == QAB->QAB_FILD+QAB->QAB_MATD}) == 0
					Aadd(aBuscaPed,{QAB->QAB_FILD,QAB->QAB_MATD})
				Endif
			EndIf
			cFilAtu := QAB->QAB_FILD
			cMatAtu := QAB->QAB_MATD
			QAB->(DbSeek(cFilAtu+cMatAtu))
		Else
			QAB->(DbSkip())
		EndIf
	EndDo
EndIf

IncProc()

cFilAtu	 := cFilQNC //QAA->QAA_FILIAL
cMatAtu  :=	cUsuQNC //QAA->QAA_MAT

For nIs:=1 TO Len(aBuscaPed)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as pendencias no Array (campos) - Ficha Ocorrencia/Nao-conformidade ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

  	cAliasQI2 := GetNextAlias()
	cQryQI2 := "SELECT QI2_FILIAL,QI2_STATUS,QI2_ANO,QI2_FNC,QI2_REV,QI2_DESCR,QI2_PRIORI,QI2_OCORRE,QI2_CONPRE,R_E_C_N_O_ QI2RECNO "
	cQryQI2 += "FROM " + RetSqlName("QI2") + " QI2 "
	cQryQI2 += "WHERE "
	cQryQI2 += " QI2_FILRES = '"+aBuscaPed[nIs,1]+"' AND "
	cQryQI2 += " QI2_MATRES = '"+aBuscaPed[nIs,2]+"' AND "
	cQryQI2 += " QI2_CONREA = ' ' AND "
	cQryQI2 += " QI2.D_E_L_E_T_ = ' '"

	cQryQI2 := ChangeQuery(cQryQI2)
	dbUseArea( .T., "TOPCONN", TcGenQry(, , cQryQI2 ), cAliasQI2, .T., .T. )

	TcSetField(cAliasQI2,"QI2_OCORRE","D")
	TcSetField(cAliasQI2,"QI2_CONPRE","D")
	TcSetField(cAliasQI2,"QI2_CONREA","D")


	While (cAliasQI2)->(!Eof())
		If aBuscaPed[nIs,1]+aBuscaPed[nIs,2]<>cFilAtu+cMatAtu 	// Usuario Transf. QAB
			aAdd(aQI2,{.T.,;
			(cAliasQI2)->QI2_FILIAL,;							// Filial FNC
			aQI2Sit[Val((cAliasQI2)->QI2_STATUS)],;
			(cAliasQI2)->QI2_FNC,;
			(cAliasQI2)->QI2_REV,;
			(cAliasQI2)->QI2_DESCR,;
			IIF(!lDBF,(cAliasQI2)->QI2RECNO,(cAliasQI2)->(Recno())),;
			aQI2Pri[Val((cAliasQI2)->QI2_PRIORI)],;
			(cAliasQI2)->QI2_OCORRE,;
			(cAliasQI2)->QI2_CONPRE,;
			cFilAtu+cMatAtu})
			lRet:=.F.
		Else
			aAdd(aQI2,{.F.,;
			(cAliasQI2)->QI2_FILIAL,;							// Filial FNC
			aQI2Sit[Val((cAliasQI2)->QI2_STATUS)],;
			(cAliasQI2)->QI2_FNC,;
			(cAliasQI2)->QI2_REV,;
			(cAliasQI2)->QI2_DESCR,;
			IIF(!lDBF,(cAliasQI2)->QI2RECNO,(cAliasQI2)->(Recno())),;
			aQI2Pri[Val((cAliasQI2)->QI2_PRIORI)],;
			(cAliasQI2)->QI2_OCORRE,;
			(cAliasQI2)->QI2_CONPRE,;
			Space(12)})
		Endif
		(cAliasQI2)->(dbSkip())
	Enddo
	(cAliasQI2)->(DbCloseArea())
	DbSelectArea("QI2")
	dbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as pendencias no Array (campos) - Plano de Acao      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasQI3 := GetNextAlias()
	cQryQI3 := "SELECT QI3_FILIAL,QI3_MAT,QI3_CODIGO,QI3_REV,QI3_STATUS,QI3_ABERTU,QI3_ENCPRE,QI3_TIPO,R_E_C_N_O_ QI3RECNO "
	cQryQI3 += "FROM " + RetSqlName("QI3") + " QI3 "
	cQryQI3 += "WHERE QI3_FILMAT = '"+aBuscaPed[nIs,1]+"' AND "
	cQryQI3 += " QI3_MAT = '"+aBuscaPed[nIs,2]+"' AND "
	cQryQI3 += " QI3_ENCREA = ' ' AND "
	cQryQI3 += " QI3.D_E_L_E_T_ = ' '"

	cQryQI3 := ChangeQuery(cQryQI3)
	dbUseArea( .T., "TOPCONN", TcGenQry(, , cQryQI3 ), cAliasQI3, .T., .F. )

	TcSetField(cAliasQI3,"QI3_ABERTU","D")
	TcSetField(cAliasQI3,"QI3_ENCPRE","D")

	While (cAliasQI3)->(!Eof())
		If aBuscaPed[nIs,1]+aBuscaPed[nIs,2]<>cFilAtu+cMatAtu 	// Usuario Transf. QAB
			AADD( aQI3,{.T.,;
			(cAliasQI3)->QI3_FILIAL,;							// Filial Plano de Acao
			(cAliasQI3)->QI3_CODIGO,;							// Codigo Plano de Acao
			(cAliasQI3)->QI3_REV,;								// Revisao da Acao
			aQI3Sit[Val((cAliasQI3)->QI3_STATUS)],;			// Status da Acao
			(cAliasQI3)->QI3_ABERTU,;							// Data Abertura
			(cAliasQI3)->QI3_ENCPRE,;							// Encerramento Previsto
			aQTipo[Val((cAliasQI3)->QI3_TIPO)],;				// Tipo Acao
			IIF(!lDBF,(cAliasQI3)->QI3RECNO,(cAliasQI3)->(Recno())),;// Registro para controle
			cFilAtu+cMatAtu})                          			// Usuario transf (PARA)
			lRet:=.F.
		Else
			AADD( aQI3,{.F.,;
			(cAliasQI3)->QI3_FILIAL,;							// Filial Plano de Acao
			(cAliasQI3)->QI3_CODIGO,;							// Codigo Plano de Acao
			(cAliasQI3)->QI3_REV,;								// Revisao da Acao
			aQI3Sit[Val((cAliasQI3)->QI3_STATUS)],;			// Status da Acao
			(cAliasQI3)->QI3_ABERTU,;							// Data Abertura
			(cAliasQI3)->QI3_ENCPRE,;							// Encerramento Previsto
			aQTipo[Val((cAliasQI3)->QI3_TIPO)],;				// Tipo Acao
			IIF(!lDBF,(cAliasQI3)->QI3RECNO,(cAliasQI3)->(Recno())),;								// Registro para controle
			Space(12)})
		Endif
		DbSkip()
	Enddo
	(cAliasQI3)->(DbCloseArea())
	dbSelectArea("QI3")
	dbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as pendencias no Array (campos)                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QI5")
	dbSetOrder(2)
	dbSeek(aBuscaPed[nIs,1]+aBuscaPed[nIs,2])

	If lTMKPMS
		cQueryInt := ""
		cQueryInt += ",QI5_PROJET"
		cQueryInt += ",QI5_TAREFA"
	EndIf

	If Empty(cFiltUsr)
		cAlias := GetNextAlias()
		cFiltro := "SELECT QI5_FILMAT,QI5_MAT,QI5_PEND,QI5_FILIAL,QI5_CODIGO,QI5_REV,QI5_STATUS,QI5_TPACAO,QI5_PRAZO,QI5_DESCRE,R_E_C_N_O_ QI5RECNO"+cQueryInt+" "
		cFiltro += "FROM " + RetSqlName("QI5") + " QI5 "
		cFiltro += "WHERE "
		cFiltro += " QI5.QI5_FILMAT = '"+aBuscaPed[nIs,1]+"' AND "
		cFiltro += " QI5.QI5_MAT = '"   +aBuscaPed[nIs,2]+"' AND "
		cFiltro += " QI5.D_E_L_E_T_ = ' '"
		cFiltro := ChangeQuery(cFiltro)
		dbUseArea( .T., "TOPCONN", TcGenQry(, , cFiltro ), cAlias, .T., .F. )
		TcSetField(cAlias,"QI5_PRAZO" ,"D")
		TcSetField(cAlias,"QI5_REALIZ","D")
	Else
		cAlias := GetNextAlias()
		cFiltro := "SELECT QI5_FILIAL,QI5_CODIGO,QI5_REV,QI5_STATUS,QI5_TPACAO,QI5_PRAZO,QI5_FILMAT,QI5_MAT,QI5_DESCRE,QI5.R_E_C_N_O_ QI5RECNO"+cQueryInt+" "
		cFiltro += "FROM " + RetSqlName("QI2") + " QI2, " + RetSqlName("QI5") + " QI5 "
		cFiltro += "WHERE (" + cFiltUsr + ") AND "
		cFiltro += " QI2_CODACA = QI5_CODIGO AND "
		cFiltro += " QI5.QI5_FILIAL = '" +xFilial("QI5")+ "' AND "
		cFiltro += " QI2.QI2_FILIAL = '" +xFilial("QI2")+ "' AND "
		cFiltro += " QI5.QI5_MAT = '"+AllTrim(cUsuQNC)+"' AND "
		cFiltro += " QI5.D_E_L_E_T_ = ' ' AND "
		cFiltro += " QI2.D_E_L_E_T_ = ' '"
		cFiltro := ChangeQuery(cFiltro)
		dbUseArea( .T., "TOPCONN", TcGenQry(, , cFiltro ), cAlias, .T., .F. )
		TcSetField(cAlias,"QI5_PRAZO" ,"D")
		TcSetField(cAlias,"QI5_REALIZ","D")
		lFiltro := .T.
		aQI5Aux := aClone(aQI5)
		aQI5 := {}
	EndIf

	While !(cAlias)->(Eof()) .And. (((cAlias)->QI5_FILMAT+(cAlias)->QI5_MAT == aBuscaPed[nIs,1]+aBuscaPed[nIs,2]).OR.!Empty(cFiltUsr) )
		If !((cAlias)->QI5_STATUS $ "4|5") .AND. If(lTMKPMS,!Empty((cAlias)->QI5_TAREFA),.T.)
			DbSelectArea("QI3")
			DbSetOrder(2)
			QI3->(DbSeek((cAlias)->QI5_FILIAL+(cAlias)->QI5_CODIGO+(cAlias)->QI5_REV))
			cGrpDe := QI3->QI3_MODELO
			If Empty(QI3->QI3_ENCREA)
				If lTMKPMS
						cQueryInt := ", QI2_NCHAMA "
						cAlias1 := GetNextAlias()
						cQuery := "SELECT DISTINCT QI2_FNC, QI2_REV, QI2_CODCAT, QI2_CODPRO "+cQueryInt
						cQuery += "FROM " + RetSqlName("QI2") + " QI2 "
						cQuery += "WHERE QI2.QI2_FILIAL  = '" + xFilial("QI2") + "' AND "
						cQuery += " QI2.D_E_L_E_T_ = ' ' AND "
						cQuery += " QI2.QI2_CODACA = '" + (cAlias)->QI5_CODIGO + "' "

						cQuery := ChangeQuery(cQuery)
						dbUseArea( .T., "TOPCONN", TcGenQry(, , cQuery ), cAlias1, .T., .F. )

						TcSetField(cAlias1,"QI5_PRAZO" ,"D")
						TcSetField(cAlias1,"QI5_REALIZ","D")

	                If ((aBuscaPed[nIs,1]+aBuscaPed[nIs,2]<>cFilAtu+cMatAtu) .AND. !lFiltro  ) // Usuario Transf. QAB
						AADD( aQI5,{.T.,;
						(cAlias)->QI5_FILIAL,;							// Filial Plano de Acao
						(cAlias)->QI5_CODIGO,;							// Codigo Plano de Acao
						(cAlias)->QI5_REV,;								// Revisao da Acao
						(cAlias1)->QI2_FNC,;							// Ficha de Não Conformidade
						(cAlias1)->QI2_REV,;							// Revisão da FNC
						(cAlias)->QI5_STATUS,;							// Status da Acao
						(cAlias)->QI5_TPACAO,;							// Tipo da Acao
						FQNCDTPACAO((cAlias)->QI5_TPACAO),;				// Desc Tipo da Acao
						(cAlias)->QI5_PRAZO,;							// Prazo/Vecto da Acao
						(cAlias1)->QI2_CODCAT,;							// Categoria da FNC
						(cAlias1)->QI2_CODPRO,;							// Produto da FNC
						(cAlias)->QI5_PROJET,;							// Projeto no qual está alocado.
						cGrpDe,;										// Grupo ao qual o plano pertence
						(cAlias1)->QI2_NCHAMA,;							// Chamado
						(cAlias)->QI5_TAREFA,;
						Iif(lDBF,(cAlias)->(Recno()),(cAlias)->QI5RECNO),;// Registro para controle
						cFilAtu+cMatAtu})
						lRet:=.F.
					Else
						AADD( aQI5,{.F.,;
						(cAlias)->QI5_FILIAL,;							// Filial Plano de Acao
						(cAlias)->QI5_CODIGO,;							// Codigo Plano de Acao
						(cAlias)->QI5_REV,;								// Revisao da Acao
						(cAlias1)->QI2_FNC,;							// Ficha de Não Conformidade
						(cAlias1)->QI2_REV,;							// Revisão da FNC
						(cAlias)->QI5_STATUS,;							// Status da Acao
						(cAlias)->QI5_TPACAO,;							// Tipo da Acao
						FQNCDTPACAO((cAlias)->QI5_TPACAO),;				// Desc Tipo da Acao
						(cAlias)->QI5_PRAZO,;							// Prazo/Vecto da Acao
						(cAlias1)->QI2_CODCAT,;							// Categoria da FNC
						(cAlias1)->QI2_CODPRO,;							// Produto da FNC
						(cAlias)->QI5_PROJET,;							// Projeto no qual está alocado.
						cGrpDe,;										// Grupo ao qual o plano pertence
						(cAlias1)->QI2_NCHAMA,;							// Chamado
						(cAlias)->QI5_TAREFA,;
						Iif(lDBF,(cAlias)->(Recno()),(cAlias)->QI5RECNO),;// Registro para controle
						Space(Len(cFilAtu+cMatAtu))})
					Endif
				Else
					If aBuscaPed[nIs,1]+aBuscaPed[nIs,2]<>cFilAtu+cMatAtu // Usuario Transf. QAB
						AADD( aQI5,{.T.,;
						(cAlias)->QI5_FILIAL,;							// Filial Plano de Acao
						(cAlias)->QI5_CODIGO,;							// Codigo Plano de Acao
						(cAlias)->QI5_REV,;								// Revisao da Acao
						(cAlias)->QI5_STATUS,;							// Status da Acao
						(cAlias)->QI5_TPACAO,;							// Tipo da Acao
						FQNCDTPACAO((cAlias)->QI5_TPACAO),;				// Desc Tipo da Acao
						(cAlias)->QI5_PRAZO,;							// Prazo/Vecto da Acao
						Iif(lDBF,(cAlias)->(Recno()),(cAlias)->QI5RECNO),;// Registro para controle
						(cAlias)->QI5_DESCRE,;							// Descricao Resumida
						cFilAtu+cMatAtu})
						lRet:=.F.
					Else
						AADD( aQI5,{.F.,;
						(cAlias)->QI5_FILIAL,;							// Filial Plano de Acao
						(cAlias)->QI5_CODIGO,;							// Codigo Plano de Acao
						(cAlias)->QI5_REV,;								// Revisao da Acao
						(cAlias)->QI5_STATUS,;							// Status da Acao
						(cAlias)->QI5_TPACAO,;							// Tipo da Acao
						FQNCDTPACAO((cAlias)->QI5_TPACAO),;				// Desc Tipo da Acao
						(cAlias)->QI5_PRAZO,;							// Prazo/Vecto da Acao
						Iif(lDBF,(cAlias)->(Recno()),(cAlias)->QI5RECNO),;// Registro para controle
						(cAlias)->QI5_DESCRE,;							// Descricao Resumida
						Space(12)})
					Endif
				EndIf
				If ((aBuscaPed[nIs,1]+aBuscaPed[nIs,2]<>cFilAtu+cMatAtu) .AND. !lFiltro  ) // Usuario Transf. QAB
					(cAlias1)->(DbCloseArea())
				EndIf
			EndIf
		Endif
		(cAlias)->(dbSkip())
	Enddo

	If !Empty(cFiltUsr)
		(cAlias)->(DbCloseArea())
	EndIf

	If lFiltro .AND. Len(aQI5)==0
		aQI5 := aClone(aQI5Aux)
	 EndIf

 	If lTMKPMS
	   	aQI5 := aSort(aQI5,,,{|x,y| DtoS(x[10]) < DtoS(y[10]) })
	Else
		aQI5 := aSort(aQI5,,,{|x,y| DtoS(x[8]) < DtoS(y[8]) })
	EndIf

	If ValType(oQI5) == "O"
	 	If Len(aQI5) > 0
	 		oQI5:SetArray(aQI5)
			oQI5:bLine := bLine
			oQI5:Refresh()
			oFolder1:Refresh()
	 	EndIf
 	EndIf

	DbSelectArea("QI5")
	DbSetOrder(1)
Next

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNC070Grv ºAutor  ³Telso Carneiro      º Data ³ 22/09/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³GRAVA os Arrays das Pendencias de Transferencias QAB        º±±
±±º          ³e pendencias Atuais de Auditorias/Agendas                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QAD015Atu()                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QNC070Grv(aQI5,aQI3,aQI2,lAltEtp,cFilQNC,cUsuQNC,cFiltUsr)

Local nI		:= 0
Local cSeqTrf	:= ""
Local cFilDe	:= Space(FWSizeFilial())
Local cMatDe	:= ""
Local cFilPara	:= Space(FWSizeFilial())
Local cMatPara	:= ""
Local lExtQIG	:= ChkFile("QIG")
Local aUsuarios := {}
Local aUsrMat	:= QA_USUARIO()
Local aUsr		:= {}
Local nArray        := 0
Local cDepto	:= ""
Local cEtapa	:= ""
Local cDesc 	:= ""
Local lTMKPMS  := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local bCampo   := {|nCpo| Field(nCpo) }
Local lTransf      := .F.
Local lQNCFICHA := ExistBlock( "QNCFICHA" )
Local lQNCRACAO := ExistBlock( "QNCRACAO" )
Local lQNCEACAO := ExistBlock( "QNCEACAO" )

Default lAltEtp := .F.
Default cFiltUsr := ""
CursorWait()
If lTMKPMS
	lTransf :=.T.
Endif

Begin Transaction

dbSelectArea("QAA")
dbSetOrder(1)

If lExtQIG
	cSeqTrf:= GetSxeNum("QIG","QIG_SEQTRF")
Endif

If lAltEtp      //Caso tenha alteração de etapa
	DbSelectArea("QUO")
	DbSetOrder(1)
	If !Empty(cGrupo)
		If QUO->(DbSeek(xFilial("QUO")+AllTrim(cGrupo)))
			cDepto := QUO->QUO_DEPTO
			DbSelectArea("QUP")
			DbSetOrder(2)
			If QUP->(DbSeek(xFilial("QUO")+cGrupo))
				cEtapa := QUP->QUP_TPACAO
			Endif
			For nI := 1 To Len(aQI5)
				If aQI5[nI][1]
					DbSelectArea("QI2")
					DbSetOrder(2)
					QI2->(DbSeek(xFilial("QI2")+aQI5[nI][5]+aQI5[nI][6]))
				 	cDesc := MSMM(QI2->QI2_DDETA)
					cGrpDe   := aQI5[nI][14]
				   	cTpAcao := aQI5[nI][8]

					QNCGeraPlano(aQI5[nI][5],aQI5[nI][6],cDepto,cGrupo,aQI5[nI][3],aQI5[nI][4],cEtapa,aQI5[nI][8],.T.,,,,cDesc,lTransf,aQI5[nI])
				EndIf
			Next
		EndIf
	EndIf
Else
	dbSelectArea("QI2")
	For nArray := 1 to Len(aQI2)
		If (aQI2[nArray,1])
			dbGoTo(aQI2[nArray,7])
			cFilDe:= QI2->QI2_FILRES
			cMatDe:= QI2->QI2_MATRES

			RecLock("QI2",.F.)
			QI2->QI2_FILRES := SubStr(aQI2[nArray,Len(aQI2[nArray])],1,FWSizeFilial())
			QI2->QI2_MATRES := SubStr(aQI2[nArray,Len(aQI2[nArray])],FWSizeFilial()+1,TamSX3("QI2_MATRES")[1])
			MsUnLock()

			cFilPara:= QI2->QI2_FILRES
			cMatPara:= QI2->QI2_MATRES

			If Ascan(aUsr,{ |x| x[1]+x[2] == cFilPara+cMatPara })== 0
				Aadd(aUsr,{cFilPara,cMatPara})
			EndIf

			If lExtQIG
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Log de Transferencia³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QNC070Log(QI2->QI2_FNC,QI2->QI2_REV,,,,"1",cSeqTrf,cMotTransf,cFilDe,cMatDe,cFilPara,cMatPara)
			Endif

			If QAA->(dbSeek(QI2->QI2_FILRES + QI2->QI2_MATRES )) .And. QAA->QAA_RECMAI == "1"
				cMail := AllTrim(QAA->QAA_EMAIL)

				If !Empty(cMail)

					cMsg := QNCSENDMAIL(1,OemToAnsi(STR0039))	// "Ficha de Ocorrencia/Nao-Conformidade (Transferencia de Lancamentos)."
					cAttach := ""
					aMsg:={{OemToAnsi(STR0040)+" "+TransForm(QI2->QI2_FNC,PesqPict("QI2","QI2_FNC"))+"-"+QI2->QI2_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5) , cMsg, cAttach } }	// "Ocorrencia/Nao-conformidade No. "

					// Geracao de Mensagem
					IF lQNCFICHA 
						aMsg := ExecBlock( "QNCFICHA", .f., .f. )
					Endif

					aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail, aMsg})

				Endif
			Endif
		Endif
	Next

	dbSelectArea("QI3")
	For nArray := 1 to Len(aQI3)
		If (aQI3[nArray,1])
			dbGoTo(aQI3[nArray,9])
			cFilDe:= QI3->QI3_FILMAT
			cMatDe:= QI3->QI3_MAT

			RecLock("QI3",.F.)
			QI3->QI3_FILMAT := SubStr(aQI3[nArray,Len(aQI3[nArray])],1,fwsizefilial())
			QI3->QI3_MAT    := SubStr(aQI3[nArray,Len(aQI3[nArray])],fwsizefilial()+1,TamSX3("QI3_MAT")[1])
			MsUnLock()

			cFilPara:= QI3->QI3_FILMAT
			cMatPara:= QI3->QI3_MAT

			If Ascan(aUsr,{ |x| x[1]+x[2] == cFilPara+cMatPara })== 0
				Aadd(aUsr,{cFilPara,cMatPara})
			EndIf

			If lExtQIG
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Log de Transferencia³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QNC070Log(,,QI3->QI3_CODIGO,QI3->QI3_REV,,"2",cSeqTrf,cMotTransf,cFilDe,cMatDe,cFilPara,cMatPara)
			Endif

			If QAA->(dbSeek(QI3->QI3_FILMAT + QI3->QI3_MAT )) .And. QAA->QAA_RECMAI == "1"
				cMail := AllTrim(QAA->QAA_EMAIL)

				If !Empty(cMail)

					cMsg := QNCSENDMAIL(2,OemToAnsi(STR0041),.T.)	// "Plano de Acao (Transferencia de Lancamentos)"
					cAttach := ""
					aMsg:={{OemToAnsi(STR0042)+" "+TransForm(QI3->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"-"+QI3->QI3_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach} }	// "Plano de Acao No. "

					// Geracao de Mensagem para o Responsavel do Plano de Acao
					IF lQNCRACAO
						aMsg := ExecBlock( "QNCRACAO", .f., .f., { OemToAnsi(STR0041),.T. } ) // "Plano de Acao (Transferencia de Lancamentos)"
					Endif

					aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail, aMsg} )
				Endif
			Endif
		Endif
	Next

	dbSelectArea("QI3")
	dbSetOrder(2)

	dbSelectArea("QI5")
	For nArray := 1 to Len(aQI5)
		If (aQI5[nArray,1])
			IF !Empty(cFiltUsr)
				QI5->(DbSetorder(4))  //QI5_FILIAL+QI5_CODIGO+QI5_REV+QI5_TPACAO
				If Dbseek(xFilial("QI5")+aQI5[nArray,3]+aQI5[nArray,4]+aQI5[nArray,8])
					cFilDe	     :=cFilQNC
					cMatDe   :=cUsuQNC

					RecLock("QI5",.F.)
						QI5->QI5_FILMAT := SubStr(aQI5[nArray,len(aQI5[nArray])],1,fwsizefilial())
						QI5->QI5_MAT    := SubStr(aQI5[nArray,len(aQI5[nArray])],fwsizefilial()+1,TamSX3("QI5_MAT")[1])
					MsUnLock()

					cFilPara:=QI5->QI5_FILMAT
					cMatPara:=QI5->QI5_MAT

					If Ascan(aUsr,{ |x| x[1]+x[2] == cFilPara+cMatPara })== 0
						Aadd(aUsr,{cFilPara,cMatPara})
					EndIf

				Endif
			Else
				If lTMKPMS
					dbGoTo(aQI5[nArray,17]) //Recno
				Else
					dbGoTo(aQI5[nArray,9]) //Recno
				EndIf
				cFilDe	     :=QI5->QI5_FILMAT
				cMatDe   :=QI5->QI5_MAT

				RecLock("QI5",.F.)
					QI5->QI5_FILMAT := SubStr(aQI5[nArray,len(aQI5[nArray])],1,fwsizefilial())
					QI5->QI5_MAT    := SubStr(aQI5[nArray,len(aQI5[nArray])],fwsizefilial()+1,TamSX3("QI5_MAT")[1])
				MsUnLock()

				cFilPara:=QI5->QI5_FILMAT
				cMatPara:=QI5->QI5_MAT

				If Ascan(aUsr,{ |x| x[1]+x[2] == cFilPara+cMatPara })== 0
					Aadd(aUsr,{cFilPara,cMatPara})
				EndIf

			Endif

	 		If lExtQIG
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Log de Transferencia³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QNC070Log(,,QI5->QI5_CODIGO,QI5->QI5_REV,QI5->QI5_TPACAO,"3",cSeqTrf,cMotTransf,cFilDe,cMatDe,cFilPara,cMatPara)
			Endif

			If QI3->(dbSeek(QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV))
				If QAA->(dbSeek(QI5->QI5_FILMAT + QI5->QI5_MAT )) .And. QAA->QAA_RECMAI == "1"
					cMail := AllTrim(QAA->QAA_EMAIL)

					If !Empty(cMail)

						cMsg := QNCSENDMAIL(3,OemToAnsi(STR0043),.T.)	// "Existe(m) Etapa(s) para voce neste Plano de Acao para ser executado (Transferencia de Lancamentos)."
						cAttach := ""
						aMsg:={{OemToAnsi(STR0042)+" "+TransForm(QI5->QI5_CODIGO,PesqPict("QI5","QI5_CODIGO"))+"-"+QI5->QI5_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach} }	// "Plano de Acao No. "

						// Geracao de Mensagem para o Responsavel do Plano de Acao
						IF lQNCEACAO
							aMsg := ExecBlock( "QNCEACAO", .f., .f., { OemToAnsi(STR0043) } ) 	// "Existe(m) Etapa(s) para voce neste Plano de Acao para ser executado (Transferencia de Lancamentos)."
						Endif

						aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail, aMsg} )
					Endif
				Endif
			Endif
		Endif
	Next
EndIf

Aadd(aUsr,{cFilQNC,cUsuQNC}) //Coloca o usuario origem no array para atualização de pendencias
End Transaction

For nI := 1 to Len(aUsr)
	QNCATULEG(aUsr[nI,1],aUsr[nI,2])//Atualiza legenda do usuários vinculados durante a transferencias
Next nI

If Len(aUsuarios) > 0
	QaEnvMail(aUsuarios,,,,aUsrMat[5],"2")
Endif
CursorArrow()

Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QNC070Log  ³ Autor ³Telso Carneiro        ³ Data ³16/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Grava Log da Transferência                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QNC070Log(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,ExpC7,ExpC8,  ³±±
±±³          ³            ExpC9,ExpC11,ExpC12)		                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpC1  - Numero da FNC(Cogido)                              ³±±
±±³          ³ExpC2  - Revisao da FNC                                     ³±±
±±³          ³ExpC3  - Numero do Plano de Acao(Codigo)                    ³±±
±±³          ³ExpC4  - Revisao do Plano de Acao                           ³±±
±±³          ³ExpC5  - Tipo de Etapa do Plano de Acao(Codigo)  			  ³±±
±±³          ³ExpC6  - Tipo de Pendencia 1-FNC 2-PLA 3-ETA     			  ³±±
±±³          ³ExpC7  - Sequencia de gravacao da Transferencia(SXE/SXF)    ³±±
±±³          ³ExpC8  - Motivo da Transferencia	                          ³±±
±±³          ³ExpC09 - Filial De										  ³±±
±±³          ³ExpC10 - Matricula De										  ³±±
±±³          ³ExpC11 - Filial Para										  ³±±
±±³          ³ExpC12 - Matricula Para									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QNCA070TRF()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QNC070Log(cNumFNC,cRevFNC,cNumPLA,cRevPLA,cTpAcao,cTpPend,;
							cSeqTrf,cMotTransf,cFilDe,cMatDe,cFilPara,cMatPara)

Local aArea 	:= GetArea()
Local aUsrMat	:= QA_USUARIO()
Local cMatFil	:= aUsrMat[2]
Local cMatCod	:= aUsrMat[3]

Default cNumFNC	:= ""
Default cRevFNC	:= ""
Default cNumPLA	:= ""
Default cRevPLA	:= ""
Default cTpAcao	:= ""

QAA->(DbSetOrder(1))

DbSelectArea("QIG")
DbSetOrder(1)

RecLock("QIG",.T.)
QIG->QIG_FILIAL:= xFilial("QIG")
QIG->QIG_FNC   := cNumFNC    	// Numero da FNC(Cogido)
QIG->QIG_REVFNC:= cRevFNC    	// Revisao da FNC
QIG->QIG_CODIGO:= cNumPLA    	// Numero do Plano de Acao(Codigo)
QIG->QIG_REVCOD:= cRevPLA    	// Revisao do Plano de Acao
QIG->QIG_TPACAO:= cTpAcao    	// Tipo de Etapa do Plano de Acao(Codigo)
QIG->QIG_DTTRAN:= dDataBase  	// Tipo de Pendencia 1-FNC 2-PLA 3-ETA
QIG->QIG_SEQTRF:= cSeqTrf    	// Sequencia de gravacao da Transferencia(SXE/SXF)
QIG->QIG_TPPEND:= cTpPend   	// 1-FNC  2-PLA 3-ETA
QIG->QIG_MOTIVO:= cMotTransf    // Motivo da Transferencia
QIG->QIG_FILRES:= cMatFil		// Filial do Responsavel
QIG->QIG_MATRES:= cMatCod		// Matricula do Responsavel
QIG->QIG_FILDE := cFilDe       	// Filial De
QIG->QIG_MATDE := cMatDe		// Matricula De
QIG->QIG_FILPAR:= cFilPara      // Filial Para
QIG->QIG_MATPAR:= cMatPara		// Matricula Para
MsUnlock()

RestaRea(aArea)
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNC070Vis ºAutor  ³Telso Carneiro      º Data ³  14/09/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡ao ³ Visualiza Log de Transferencia (Historico)                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCA070                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function QNC070Vis()

Local nOpca
Local oDlgR
Local nX
Local aColsDE:={}
Local aColsPA:={}
Local aHeaLog :={}
Local cSeek
Local cWhile
Local lDe   := .F.//Indica se existe registros para DE
Local lPara := .F.//Indica se existe registros para PARA

Private oGetDE
Private oGetPA

IF !ChkFile("QIG")
	Return(NIL)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem o GetDados das Pendencias DE  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QIG")
dbSetOrder(1)
If !dbSeek(xFilial("QIG")+QAA->QAA_FILIAL+QAA->QAA_MAT)
	lDe := .T.
EndIF

cSeek  := QIG->QIG_FILIAL+QIG->QIG_FILDE+QIG->QIG_MATDE
cWhile := "QIG->QIG_FILIAL+QIG->QIG_FILDE+QIG->QIG_MATDE"

  FillGetDados(nOpca,"QIG",1     ,cSeek ,{|| &cWhile},         ,         ,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
//FillGetDados(nOpca,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry

aHeaLog := aClone(aHeader)
aColsDE := aClone(aCols)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zera aHeader e Acols para monta a GetDados PARA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := {}
aCols   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem o GetDados das Pendencias PARA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QIG")
dbSetOrder(2)
If !dbSeek(xFilial("QIG")+QAA->QAA_FILIAL+QAA->QAA_MAT)
	lPara := .T.
EndIf

cSeek  := QIG->QIG_FILIAL+QIG->QIG_FILPAR+QIG->QIG_MATPAR
cWhile := "QIG->QIG_FILIAL+QIG->QIG_FILPAR+QIG->QIG_MATPAR"

  FillGetDados(nOpca,"QIG",2     ,cSeek ,{|| &cWhile},         ,         ,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
//FillGetDados(nOpca,Alias,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry

aHeaLog := aClone(aHeader)
aColsPA := aClone(aCols)

IF lDe .And. lPara
	Help( " ", 1, "QNCNPENDU",,OemToAnsi(STR0038),1)	// "Nao existem pendencias para este Usuario"
	Return(Nil)
Endif

dbSelectArea("QIG")
dbSetOrder(3)  //FILIAL+DATA+SEQ

DEFINE MSDIALOG oDlgR TITLE OemToAnsi(STR0060) FROM 9,0 TO 40,100     //"Historico de Transferências das Pendencias de Fichas,Planos e Etapas "

RegToMemory("QIG")

@015,002 SAY OemToAnsi(STR0057)+QAA->QAA_FILIAL+"-"+QAA->QAA_MAT+" "+QA_NUSR(QAA->QAA_FILIAL,QAA->QAA_MAT) PIXEL    //"Transferências realizadas (DE): "
oGetDE :=MsNewGetDados():New(025,002,120,395,0,"AllwaysTrue()","AllwaysTrue()",,,,,,,,oDlgR,aHeaLog,aColsDE)

@125,002 SAY OemToAnsi(STR0058)+QAA->QAA_FILIAL+"-"+QAA->QAA_MAT+" "+QA_NUSR(QAA->QAA_FILIAL,QAA->QAA_MAT) PIXEL    //"Transferências realizadas (PARA): "
oGetPA :=MsNewGetDados():New(135,002,230,395,0,"AllwaysTrue()","AllwaysTrue()",,,,,,,,oDlgR,aHeaLog,aColsPA)

ACTIVATE MSDIALOG oDlgR CENTERED ON INIT EnchoiceBar(oDlgR,{|| oDlgR:End()},{|| oDlgR:End()} )

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNC070TMK ºAutor  ³Leandro		     º Data ³  01/02/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡ao ³ Valida se o usuario foi incluido via TMK		              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCA070                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function QNC070TMK()
Local lTMKPMS   := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local nFilFun 	:= 0
Local nFilAnt   := 0
Local cPriFil 	:= ""
Local cCodigo   := ""
Local aArea     := GetArea()
Local lRet      := .T.
Local nEmpAnt   := 0

If lTMKPMS .And. (GetMv("MV_QTMKPMS",.F.,1) == 2)

	nEmpAnt := len(cEmpAnt)
	nFilFun := len(cFilAnt)
	nFilAnt := len(cFilAnt)

	aArea := GetArea()
	DbSeek("QAA")
	cModoQAA:= FWModeAccess("QAA",3)
	DbSetOrder(1)

	cPriFil := QXPOSFIL(cEmpAnt)

	If cModoQAA == "C"
		cCodigo := SubStr(M->QAA_MAT,(nEmpAnt+cPriFil)+1,10)
	Else
		cCodigo := SubStr(M->QAA_MAT,(nEmpAnt+nFilAnt)+1,10)
	Endif

	DbSelectArea("SU7")
	dbSetOrder(1)
	If DbSeek(xFilial("SU7") + cCodigo)
		If !Empty(M->QAA_LOGIN)
			MsgAlert(STR0061,STR0062)//"Devido a integracao com o ambiente de Call Center o usuario nao podera ser excluido ou alterado."##"Atencao, usuario bloqueado para manutencao!!"
    		lRet := .F.
    	Endif
     Endif
    RestArea(aArea)

Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCDELRDZ ºAutor  ³Leandro		     º Data ³  27/11/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡ao ³Na alteracao da RDZ, excluir o relacionamento anterior      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCA070                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC070RDZ(cPessoa  ,cEntidade,cChaveEntidade,nIndice,cEmp   ,cFil,cChave)

Local cRDZFil := ""
Local aArea   := GetArea()
Local lAddNew := .T.

DEFAULT cFil := cFilAnt

cRDZFil := xFilial( "RDZ" , cFil )

dbSelectArea('RDZ')
RDZ->(dbSetOrder(3))
lAddNew := !( RDZ->( MsSeek( cRDZFil + cEmp + cFil + cEntidade + cPessoa) ) )
RecLock("RDZ",lAddNew)

RDZ->RDZ_FILIAL := cRDZFil
RDZ->RDZ_EMPENT := cEmp
RDZ->RDZ_FILENT := cFil
RDZ->RDZ_ENTIDA := cEntidade
If lAddNew
	RDZ->RDZ_CODENT := cChaveEntidade
	RDZ->RDZ_CODRD0 := cPessoa
	RDZ->RDZ_ENTIND := StrZero( nIndice , GetSx3Cache( "RDZ_ENTIND" , "X3_TAMANHO" ) )
Else
	RDZ->RDZ_CODENT := cChaveEntidade
Endif

MsUnlock()

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QValPart   ºAutor  ³Sandra Ribeiro    º Data ³  19/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca o departamento de correção cadastrado para o produto.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QValPartRec(cPart)

Local cRecur := ""
Local aArea	:= GetArea()

DbSelectArea("RDZ")
DbSetOrder(2)

//RDZ_FILIAL+RDZ_CODRD0+RDZ_EMPENT+RDZ_FILENT+RDZ_ENTIDA - Indice 2 da RDZ

If RDZ->(DbSeek(xFilial("RDZ")+AllTrim(cPart)+cEmpAnt+cFilAnt+"AE8"))
	RecLock("QAA",.F.)
	cRecur := RDZ->RDZ_CODENT
	MsUnLock()
	cRecur := AllTrim(STUFF(cRecur,1,2,""))
	DbSelectArea("AE8")
	AE8->(DBSetOrder(1))
	If AE8->(DbSeek(xFilial("AE8")+cRecur))
		M->QAA_DESCRE := AllTrim(AE8->AE8_DESCRI)
	EndIf
EndIf

RestArea( aArea )

Return cRecur

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QValPart   ºAutor  ³Sandra Ribeiro    º Data ³  19/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca o departamento de correção cadastrado para o produto.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QValPartOpe(cPart)

Local cOperad := ""
Local aArea	  := GetArea()

DbSelectArea("RDZ")
DbSetOrder(2)

//RDZ_FILIAL+RDZ_CODRD0+RDZ_EMPENT+RDZ_FILENT+RDZ_ENTIDA - Indice 2 da RDZ
If RDZ->(DbSeek(xFilial("RDZ")+AllTrim(cPart)+cEmpAnt+cFilAnt+"SU7"))
	RecLock("QAA",.F.)
	cOperad := RDZ->RDZ_CODENT
	MsUnLock()
	cOperad := AllTrim(STUFF(cOperad,1,2,""))
	DbSelectArea("SU7")
	SU7->(DBSetOrder(1))
	If SU7->(DbSeek(xFilial("SU7")+cOperad))
		M->QAA_DESCOP := AllTrim(SU7->U7_NOME)
	EndIf
EndIf

RestArea( aArea )

Return cOperad


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QN070Chk  ³ Autor ³Leandro                ³ Data ³ 05/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Func. verifica se já existe participante, recurso e operador³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QN070Chk(cParticip,cRecurso,cOperador)

Local lRet    := .F.

cAlias := GetNextAlias()
cQuery := "SELECT COUNT (*)  QTD"
cQuery += " FROM " + RetSqlName("QAA") + " QAA "
cQuery += " WHERE QAA.QAA_FILIAL = '" + xFilial("QAA") + "' AND "
cQuery += "       QAA.QAA_PARTIC = '" + cParticip + "' AND "
cQuery += "       QAA.QAA_RECUR  = '" + cRecurso + "' AND "
cQuery += "       QAA.QAA_OPERAD = '" + cOperador + "' AND "
cQuery += "       QAA.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

If (cAlias)->QTD== 0
	lRet := .T.
Endif
dbSelectArea(cAlias)
dbCloseArea()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QN070ChkAE8 Autor ³Leandro                ³ Data ³ 05/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Func. verifica se já existe participante, recurso e operador³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QN070ChkAE8(cRecurso)

Local lRet := If(!Empty(cRecurso),.F.,.T.)

cAlias := GetNextAlias()
cQuery := "SELECT COUNT (*)  QTD"
cQuery += " FROM " + RetSqlName("QAA") + " QAA "
cQuery += " WHERE QAA.QAA_FILIAL = '" + xFilial("QAA") + "' AND "
cQuery += "       QAA.QAA_RECUR  = '" + cRecurso + "' AND "
cQuery += "       QAA.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

If (cAlias)->QTD == 0
	lRet := .T.
Endif
dbSelectArea(cAlias)
dbCloseArea()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QN070ChkSU7 Autor ³Leandro                ³ Data ³ 05/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Func. verifica se já existe participante, recurso e operador³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QN070ChkSU7(cOperador)

Local lRet := If(!Empty(cOperador),.F.,.T.)

cAlias := GetNextAlias()
cQuery := "SELECT COUNT (*)  QTD"
cQuery += " FROM " + RetSqlName("QAA") + " QAA "
cQuery += " WHERE QAA.QAA_FILIAL = '" + xFilial("QAA") + "' AND "
cQuery += "       QAA.QAA_OPERAD = '" + cOperador + "' AND "
cQuery += "       QAA.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

If (cAlias)->QTD == 0
	lRet := .T.
Endif
dbSelectArea(cAlias)
dbCloseArea()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡ao	 ³QN070VldDel º Autor ³ Paulo Fco. Cruz Nt. º Data ³16/09/2009º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡ao ³Validação da exclusao de usuarios para integração			  º±±
±±º          ³TMK x PMS x QNC											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³QNC070Log(ValA1)                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ValA1 - Código de participante do usuario a excluir		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso		 ³QNCA070()                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QN070VldDel(cPart)
Local cMat   := ""
Local lApaga := .T.

dbSelectArea("RDZ")
dbSetOrder(2)

//RDZ_FILIAL+RDZ_CODRD0+RDZ_EMPENT+RDZ_FILENT+RDZ_ENTIDA - Indice 2 da RDZ
If RDZ->(DbSeek(xFilial("RDZ")+cPart+cEmpAnt+xFilial("QAA")+"QAA"))
	cMat := RDZ->RDZ_CODENT
	cMat := AllTrim(STUFF(cMat,1,2,"")) // Retira filial

	If !Empty(cMat)
		dbSelectArea("QAA")
		dbSetOrder(1)
		If dbSeek(xFilial("QAA")+cMat)
			lApaga := Iif(FindFunction("QAAValExc"), QAAValExc(), .F.)
		EndIf
	EndIf
EndIf

Return lApaga


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡ao	 ³QnTrfPMS    º Autor ³ Sandra Ribeiro      º Data ³10/08/2009º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡ao ³Busca e altera o responsavel pela tarefa no PMS quando inte º±±
±±º          ³grado via MV_QTMKPMS  									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso		 ³QNCA070()                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QnTrfPMS(cMatDe,aEtapa)

Local cRecPara	:= ""
Local cRevisao	:= ""
Local cRecDe	:= ""
Local lRet		:= .T.
Local lTMKPMS	:= If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local nX
Local bCampo 	:= {|n| FieldName(n) }
Local aAreaAFA
Local cItem

Default cMatDe := ""

If lTMKPMS
	If !Empty(aEtapa[13])
		cRevisao := PmsAF8Ver(aEtapa[13])
	EndIf

	DbSelectArea("QAA")
	DbSetOrder(1)
	If QAA->(DbSeek(aEtapa[18]))
		If !Empty(QAA->QAA_RECUR)
			cRecPara := QAA->QAA_RECUR
		Else
		   	Alert("Atenção","Não há recurso para este usuário! A tarefa não será transferida!")
			lRet := .F.
		EndIf
	EndIf

	If QAA->(DbSeek((aEtapa[2])+cMatDe))
		cRecDe := QAA->QAA_RECUR
	EndIf

	If lRet
		DbSelectArea("AFA")
		DbSetOrder(5) //AFA_FILIAL+AFA_PROJET +AFA_REVISA+ AFA_TAREFA+AFA_RECURS
		If AFA->(DbSeek((aEtapa[2])+(aEtapa[13])+cRevisao+(aEtapa[16])+cRecDe))
			aAreaAFA := AFA->(GetArea())
			cItem:=strzero(0,AFA->(TamSX3("AFA_ITEM")[1]))
			AFA->(DbSetOrder(1))
			AFA->(DbSeek( (aEtapa[2])+(aEtapa[13])+cRevisao+(aEtapa[16]) ))
			Do While AFA->(!Eof()) .And. (aEtapa[2])+(aEtapa[13])+cRevisao+(aEtapa[16])==AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA)
				cItem := AFA->AFA_ITEM
				AFA->(DbSkip())
			EndDo
			cItem := Soma1(cItem)
			RestArea(aAreaAFA)

			RegToMemory( "AFA", .F.)
			RecLock("AFA",.F.)
				AFA->AFA_RESP := "2"
			MsUnLock()

			dbSelectArea("AFA")
			RecLock("AFA",.T.)
			For nx := 1 TO FCount()
				FieldPut(nx,M->&(EVAL(bCampo,nx)))
			Next nx
			AFA->AFA_FILIAL	:= xFilial("AFA")
			AFA->AFA_RECURS	:= cRecPara
			AFA->AFA_RESP	:= "1"
			AFA->AFA_ITEM	:= cItem
			MsUnlock()
		EndIf
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 |QNC070Grp  ³ Autor ³Telso Carneiro        ³ Data ³16/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Tela de Seleção do Grupo de Etapas                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QNC070Grp ()    											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QNCA070TRF()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QNC070Grp()

Local oDlgGrp
Local lGrava	:= .F.
Local cGrpEtp   := Space(Len(QUO->QUO_GRUPO))

DEFINE MSDIALOG oDlgGrp TITLE "Selecione o Novo Grupo de Etapas" FROM 150,000 TO 230,280 PIXEL    //Selecione Novo grupo de etapas

@ 005,005 MSGET oGrpEtp VAR cGrpEtp F3 "QUO1" OF oDlgGrp SIZE 130,010  PIXEL

DEFINE SBUTTON FROM 021,075 TYPE 1 ENABLE OF oDlgGrp ACTION  (If(VldGrpEtp(cGrpEtp ).And. NaoVazio(cGrpEtp),(lGrava := .T.,oDlgGrp:End()),));

DEFINE SBUTTON FROM 021,105 TYPE 2 ENABLE OF oDlgGrp ACTION  (oDlgGrp:End());

ACTIVATE MSDIALOG oDlgGrp CENTERED

Return cGrpEtp


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCA070   ºAutor  ³Iolanda Vilanova	 º Data ³  04/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validar se o grupo de etapas informado existe na QUO       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCA070                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function  VldGrpEtp(cGrpEtp )
Local lRet := .T.

DbSelectArea ("QUO")
QUO->(DbSetOrder(1))//QUO_FILIAL+QUO_GRUPO
If !QUO->(DbSeek(xFilial("QUO")+cGrpEtp ))
	Help(" ",1,'REGNOIS')
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNC070FIL ºAutor  ³Rafael Duram Santos º Data ³  03/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Filtro Alias QI5/QI2 para tratamento em DBF                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP11                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNC070FIL(cCodQI5,cFilQI5,cMatQI5,cMatQNC)

Local lRet := .T.
Local aArea := QI2->(GetArea())

If cFilQI5 <> xFilial("QI5")
	lRet := .F.
	Return lRet
Endif

If cMatQI5 <> Alltrim(cMatQNC)
	lRet := .F.
	Return lRet
Endif

DbSelectArea("QI2")
QI2->(DbClearFilter())
QI2->(DbSetOrder(5))
If !QI2->(DbSeek(xFilial("QI2")+cCodQI5))
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} QNC070TOK
@type  Static Function
@author rafael.hesse
@since 13/07/2022
@param lTMKPMS, Lógico, indica se tem Integracao do QNC com TMK e PMS
@return lRet, Lógico, indica se o cadastro está válido para inclusão/alteração
/*/
Static Function QNC070TOK(lTMKPMS)
Local lRet := .T.	

	If !(QX10VldEmp(lIntGPE) .AND. QA010VRCFG(.T.) .AND. Obrigatorio(aGETS,aTELA) .AND. Q070VUso() )
		lRet := .F.
	EndIf

	lRet := IIf( lRet .And. Altera .And. M->QAA_STATUS == '2' .And. FindFunction("QAAValIna"), QAAValIna(), lRet) //Iif na mesma linha para facilitar cobertura

Return lRet
