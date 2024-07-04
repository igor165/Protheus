#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "qmta160.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³QMTA160   ³ Autor ³Eduardo Riera          ³ Data ³ 30.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Movimentacao de Instrumentos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³14.07.02  ³Denis Martins  ³Criado funcoes de envio de e-mail aos respon³±±
±±³          ³               ³saveis para a devolucao dos mesmos.         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { { STR0001   ,"AxPesqui"  , 0 , 1,,.F.},;	//"Pesquisar"
				   { STR0002   ,"AxVisual"  , 0 , 2},;		//"Visual"
				   { STR0003   ,"A160Saida" , 0 , 3},;		//"Retirada"
				   { STR0004   ,"A160Entrada",0 , 4},;		//"Devolucao"
				   { STR0005   ,"A160Exclui" ,0 , 5},;		//"Cancela"
				   { STR0040   ,"qmta160Leg" ,0 , 6}}		//"Legenda"

Local lQmtPmov := Iif(GetNewPar("MV_QMTPMOV",'1') == '1',.F.,.T.)

If lQmtPmov
	aRotina := { { STR0002   ,"AxVisual"  , 0 , 2}}
Endif

Return aRotina

Function QMTA160()

Local cTpMov:=GetMV("MV_QMTPMOV",.F.,"1")

Local aCores   := qmta160Leg(.T.)

If cTpMov == "2"
	Help (" ",1,"QM_QMTPMO2")
	MsgAlert(OemToAnsi(STR0039),OemToAnsi(STR0038))
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0006)      //"Mov. de Instrumentos"
Private lQM160Brow := ExistBlock("QM160BROW")
Private nQaConpad := 3

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
PRIVATE aRotina := MenuDef()
Private aMarcados := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QML")
dbSetOrder(1)
dbSeek(xFilial())
If lQM160Brow
	ExecBlock("QM160BROW",.F.,.F.,{.T.,"QML"})
Endif

mBrowse(6,1,22,75,"QML",,"QML_FLAGB=='A'",,,,aCores)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A160Saida ³ Autor ³ Eduardo Riera         ³ Data ³ 30.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controla as movimentacoes de Saida do instrumento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 01/08/00 ³ Iuri Seto     ³Inclui no SX1 a opcao "Retorne na Val.Cal.?"³±±
±±³          ³               ³se o usuario escolher "Sim", a data de      ³±±
±±³          ³               ³retorno sera a validade da calibracao, se   ³±±
±±³          ³               ³escolher "Nao", o retorno sera a data de    ³±±
±±³          ³               ³hoje mais os dias de retorno.               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function a160Saida(cAlias,nReg,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cArqInd := CriaTrab(,.F.)
Local cChave  := ""
Local cFiltro := ""
Local aSavaRot:= aClone(aRotina)
Local nIndex
Local nOrdQML := QML->(IndexOrd())
Local cArqFil := CriaTrab(,.F.)

Private cMarca   := GetMark(,"QM2", "QM2_OK")
Private lInverte := .F.

aRotina := {{ STR0001	,"AxPesqui"	, 0 , 1 },; //"Pesquisar"
			{ STR0007   ,"A160Gera"	, 0 , 2}}   //"Efetuar Saida"

aMarcados := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros:                                                  ³
//³ MV_PAR01  : Familia Inicial                                  ³
//³ MV_PAR02  : Familia Final                                    ³
//³ MV_PAR03  : Instrumento de                                   ³
//³ MV_PAR04  : Instrumento Ate                                  ³
//³ MV_PAR05  : Departamento de                                  ³
//³ MV_PAR06  : Departamento ate                                 ³
//³ MV_PAR07  : Responsavel de                                   ³
//³ MV_PAR08  : Responsavel ate                                  ³
//³ MV_PAR09  : Dias p/ Devolucao                                ³
//³ MV_PAR10  : Devolve na data de Validade da Calibracao        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RetIndex("QM2")
dbClearFilter()
Ferase(cArqFil+OrdBagExt())

dbSelectArea("QM2")
dbSetOrder(1)
dbGoTop()
If ( Pergunte("QMT160",.T.) )

	cChave := "QM2_FILIAL+QM2_TIPO+QM2_INSTR+QM2_REVINV"

	cFiltro:= "QM2_FILIAL=='"+xFilial("QM2")+"'.And."
	cFiltro+= "QM2_TIPO>='"  +MV_PAR01+"'.And."
	cFiltro+= "QM2_TIPO<='"  +MV_PAR02+"'.And."
	cFiltro+= "QM2_INSTR>='" +MV_PAR03+"'.And."
	cFiltro+= "QM2_INSTR<='" +MV_PAR04+"'.And."
	cFiltro+= "QM2_DEPTO>='" +MV_PAR05+"'.And."
	cFiltro+= "QM2_DEPTO<='" +MV_PAR06+"'.And."
	cFiltro+= "QM2_RESP>='"  +MV_PAR07+"'.And."
	cFiltro+= "QM2_RESP<='"  +MV_PAR08+"'.And."		
	cFiltro+= "QM2_STATUS <> '0'.And."
	cFiltro+= "QM2_FLAG == '1'.And."   
	cFiltro+= "DTOS(QM2_VALDAF)>='"+Dtos(dDataBase+MV_PAR09)+"'"

	If lQM160Brow
		cFiltro+= ExecBlock("QM160BROW",.F.,.F.,{.F.,"QM2"})
	Endif

	cFilSQL:= "QM2_FILIAL='"+xFilial("QM2")+"' AND "
	cFilSQL+= "QM2_TIPO>='"  +MV_PAR01+"' AND "
	cFilSQL+= "QM2_TIPO<='"  +MV_PAR02+"' AND "
	cFilSQL+= "QM2_INSTR>='" +MV_PAR03+"' AND "
	cFilSQL+= "QM2_INSTR<='" +MV_PAR04+"' AND "
	cFilSQL+= "QM2_DEPTO>='" +MV_PAR05+"' AND "
	cFilSQL+= "QM2_DEPTO<='" +MV_PAR06+"' AND "
	cFilSQL+= "QM2_RESP>='"  +MV_PAR07+"' AND "
	cFilSQL+= "QM2_RESP<='"  +MV_PAR08+"' AND "		
	cFilSQL+= "QM2_STATUS <> '0' AND "
	cFilSQL+= "QM2_FLAG = '1' AND "   
	cFilSQL+= "QM2_VALDAF>='"+Dtos(dDataBase+MV_PAR09)+"'"

	Processa( {|| cMarca := getcMarca("QM2", cFilSQL) }, STR0043, STR0044,.F.) //"Aguarde..." ### "Buscando registros..." 

	dbSelectArea("QM2")
	IndRegua("QM2",cArqInd,cChave,,cFiltro)
	nIndex := RetIndex("QM2")

	dbSetOrder(nIndex+1)
	dbGotop()
	
	If ( !Eof() )
		MarkBrow("QM2","QM2_OK","a160Veri()",,@lInverte,@cMarca,"SetMrkAll('QM2', 'QM2_OK', cMarca)",,,,"MrkDblClk('QM2', 'QM2_OK', lInverte, cMarca)")
	Else
		Help(" ",1,"RECNO")
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna as condicoes anteriores                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRotina := Aclone(aSavARot)
RetIndex("QM2")
dbClearFilter()
Ferase(cArqInd+OrdBagExt())
dbSelectArea("QML")
dbSetOrder(nOrdQML)
dbGoto(nReg)
Return(.F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A160Gera  ³ Autor ³ Eduardo Riera         ³ Data ³ 30.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria a Movimentacao de Saida para o instrumento            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 01/08/00 ³ Iuri Seto     ³Inclui no SX1 a opcao "Retorne na Val.Cal.?"³±±
±±³          ³               ³se o usuario escolher "Sim", a data de      ³±±
±±³          ³               ³retorno sera a validade da calibracao, se   ³±±
±±³          ³               ³escolher "Nao", o retorno sera a data de    ³±±
±±³          ³               ³hoje mais os dias de retorno.               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function a160Gera(cAlias,cCampo,nOpcE,cMarca,lInverte)

Local lInclui   := .F.
Local lTipoMov  := .F.
Local nRegQMl   := 0
Local lContinua := .T.
Local nRecno    := Recno()
Local nOrdem    := (cAlias)->(IndexOrd())
Local cInstr    := ""
Local lJahEmp	:= .F.
Local lGrvOk	:= .T.
Local cArqSel	:= CriaTrab(Nil,.F.)
Local cChvs		:= "QM2_FILIAL+QM2_INSTR"
Local cCondi	:= ""
Local nIndexs	:= ""
Local aArea		:= GetArea()
Local lGrQML	:= .F.   
Local cPerRemp  := GetMV("MV_QMTREMP",.T.,"1") //Indica se no re-emprestimo o Instrumento sera devolvido ao responsavel, opcoes Sim(1) ou Nao(2)
Local nX		:= 0
Local lQMT160GF := ExistBlock("QMT160GF")
Private c_Local
Private c_Depto
Private d_DtRet
Private d_DtCol
Private c_HrCol
Private c_HrRet
Private c_Status
Private c_Resp
Private c_FilRel 
Private a_Cpousu := {}
Private n_Freq
Private aCpoUsu := {}

cPerRemp := IIf(Empty(cPerRemp),"1",cPerRemp)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Localiza todos os registros (QM2) com o mesmo cMarca e procura por movimentacoes.	 ³
//³em aberto.Caso exista, ira avisar o usuario como proceder.(Novo empresto/Cancelamento)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QM2")
cCondi	:= "QM2_FILIAL == '"+xFilial()+"' .And. "
cCondi	+= "QM2_OK == '"+cMarca+"'"

IndRegua("QM2",cArqSel,cChvs,,cCondi,STR0015) //"Selecionando Registros..."
nIndexs := RetIndex("QM2")

dbSetOrder(nIndexs+1)
dbSelectArea("QM2")
dbGotop() // Esta na Indregua()


While !QM2->(Eof())
	dbSelectArea("QML")	
	dbSetOrder(1)
	If ( dbSeek(xFilial("QML")+QM2->QM2_INSTR) ) //+QM2->QM2_REVINS+"A"
		If Alltrim(QML->QML_FLAGB) == "A"
			lJahEmp		:= .T.
			If  QML->QML_DTRET > dDatabase    // Verifico os requisitos de data
				MsgAlert(STR0036)
				lContinua := .F.				
				lGrvOk := .F.	
			EndIf
			Exit //Se encontrou o primeiro
		Endif
	Endif	
    dbSelectArea("QM2")
	dbSkip()
Enddo             

dbClearFilter()
Ferase(cArqSel+OrdBagExt())

RestArea(aArea)

dbSelectArea("QM2")
dbGotop() // Esta na Indregua()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aqui eu procuro um instrumento valido pois na      ³
//³ markbrowse nao foi possivel validar O QM1_LOCAL    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While ( !Eof() .And. lContinua )
	If QM2->QM2_OK == cMarca
		If !a160Movi()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Registros.                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QM1")
			dbSetOrder(1)
			dbSeek(xFilial("QM1")+QM2->QM2_TIPO)
			If ( QM1->QM1_LOCAL=="S" )
				lContinua	:= .F.
			Else
				lTipoMov := .T.
			EndIf
		EndIf
	EndIf
	dbSelectArea("QM2")
	If ( lContinua )
		cInstr := QM2->QM2_INSTR
		While ( !Eof() .And. QM2->QM2_INSTR==cInstr  )
			dbSkip()
		EndDo
	EndIf
EndDo
If ( lContinua )
	HELP(" ",1,"QMTA160MOV")
EndIf
If ( lTipoMov .And. !lContinua )
	Help(" ",1,"QMTA160TIP")
EndIf



If lJahEmp //.and. lContinua
	lGrvOk := MsgYesNo(OemToAnsi(STR0024)+OemToAnsi(STR0025)+IIF(cPerRemp == "1",OemToAnsi(STR0034),OemToAnsi(STR0035)),OemToAnsi(STR0028))
	If lGrvOk .and. Existblock("QM160EMPR")
		lGrvOk := Execblock("QM160EMPR",.F.,.F.,{QM2->QM2_INSTR,QM2->QM2_REVINS})
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aqui e' montada uma enchoice para validacao de campos   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGrvOk
    Q160SX3 ("QML",aCpoUsu)  //  Cria Array com os campos criados pelo usuario

	dbSelectArea("QML")
	If ( !lContinua .And. AxInclui("QML",1,,,"a160IniCpo",,"Qmt160tOk()") == 1 )
		nFreqGer := QML->QML_FREQ // Guarda frequencia sugerida na enchoice
									  // para usar em todos os registros
		While ( !Eof() )
			If mv_par10 == 1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula automaticamente a data de devolucao e os dias de ³
				//³ emprestimo para a data de validade da calibracao.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				n_freq := QM2->QM2_VALDAF - dDataBase
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula a data de devolucao e os dias de emprestimo      ³
				//³ de acordo com os dias digitados no dias p/ retorno, a    ³
				//³ data e os dias serao iguais para todos instrumentos      ³
				//³ selecionados.                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				n_freq := nFreqGer
			EndIf			
			If QM2->QM2_OK == cMarca
				If !a160Movi()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona Registros.                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("QM1")
					dbSetOrder(1)
					dbSeek(xFilial("QM1")+QM2->QM2_TIPO)
					dbSelectArea("QMP")
					dbSetOrder(1)
					dbSeek(xFilial("QMP")+ QM2->QM2_STATUS)
					If ( QM2->QM2_VALDAF < dDataBase+n_Freq )
						Help(" ",1,"QMTA160VLD",,QM2->QM2_INSTR,3,1) // A data de afericao vencera antes
																				// do retorno do Instrumento
						n_Freq := QM2->QM2_VALDAF - dDataBase
					EndIf
					If ( QM1->QM1_LOCAL=="S" )
						Begin Transaction
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Localiza o movimento em aberto                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lGrQML := .F.
							dbSelectArea("QML")	
							nRegQML := Recno()
							dbSetOrder(1)
							If ( dbSeek(xFilial("QML")+QM2->QM2_INSTR+QM2->QM2_REVINS+"A") )
								RecLock("QML")
								QML->QML_FILIAL := xFilial("QML")
								QML->QML_DTCOL  := d_DtRet
								QML->QML_HRCOL  := c_HrCol
								QML->QML_FILREL := cFilAnt								
								QML->QML_RESRET := QM1->QM1_RDISTR
								//Gravacao do campo QML_RESCOL para garantir a integridade quando o instrumento
								//ja esta emprestado e sofrera novo emprestimo..
								If lJahEmp
									QML->QML_RESCOL := QM1->QM1_RDISTR 
								Endif	
								QML->QML_FLAGB  := "B"   
								For nX := 1 To Len(aCpoUsu)				//Campos Criados pelo usuario
									&("QML->"+aCpoUsu[nX,1]) := a_CpoUsu[nX]
								Next								
								lGrQML := .T.
							EndIf
							dbSelectArea("QML")
							dbGoto(nRegQML)
        		
							RecLock("QML",lInclui)
							QML->QML_FILIAL := xFilial("QML")
							QML->QML_INSTR  := QM2->QM2_INSTR
							QML->QML_REVINS := QM2->QM2_REVINS
							QML->QML_TIPO   := QM2->QM2_TIPO
							QML->QML_REVTIP := QM1->QM1_REVTIP  
							QML->QML_DESCR  := QM2->QM2_DESCR
							QML->QML_DTRet  := d_DtRet
							QML->QML_HRRet  := c_HrRet
							QML->QML_FILREL := cFilAnt
							QML->QML_RESRET := c_Resp
							QML->QML_DEPTO  := c_Depto
							QML->QML_LOCAL  := c_local
							QML->QML_HRCOL  := c_HrCol    
							QML->QML_DTLIM  := QM2->QM2_VALDAF
							QML->QML_FREQ   := n_freq
							QML->QML_FLAGB  := "A"
							QML->QML_DTCOL  := d_DtRet+n_freq
							QML->QML_STATUS := c_Status
							QML->QML_FILREL := c_FilRel   
							For nX := 1 To Len(aCpoUsu)				//Campos Criados pelo usuario
								&("QML->"+aCpoUsu[nX,1]) := a_CpoUsu[nX]
							Next							
                	
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza Cadastro de Instrumentos                  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          
							DbSelectArea("QM2")
							dbSetOrder(1)
							RecLock("QM2")
							If lJahEmp .and. cPerRemp == "2"
									QM2->QM2_DEPTO := c_Depto
									QM2->QM2_FILRES:= cFilAnt
									QM2->QM2_RESP  := c_Resp
							Else
								If lGrQML
									QM2->QM2_DEPTO	:= QM1->QM1_DISTR
									QM2->QM2_FILRES	:= QM1->QM1_FILRES								
									QM2->QM2_RESP	:= QM1->QM1_RDISTR
									c_Local			:= ""
								Else
									QM2->QM2_DEPTO := QML->QML_DEPTO
									QM2->QM2_RESP  := c_Resp
								Endif
							EndIf
							QM2->QM2_LOCAL := c_Local
							QM2->QM2_STATUS:= QML->QML_STATUS
						End Transaction
						//Ponto de entrada utilizado para gravar qualquer campo do instrumento apos o emprestimo
						If lQMT160GF
							ExecBlock("QMT160GF",.F.,.F.,{QML->QML_INSTR,QML->QML_REVINS})
						EndIf
					EndIf
				EndIf
			EndIf
			dbSelectArea("QM2")
			cInstr := QM2->QM2_INSTR
			While ( !Eof() .And. QM2->QM2_INSTR==cInstr  )
				dbSkip()
			EndDo
			lInclui := .T.
		EndDo
		If ( !lInclui )
			RecLock("QML")
			dbDelete()
			MsUnlock()
		EndIf	
	EndIf
//Else
//	MessageDlg(OemToAnsi(STR0027),,3) //Nenhum instrumento selecionado foi movimentado
Endif

CloseBrowse()

dbSelectArea(cAlias)

If nOrdem == 0
	dbSetOrder(1)
Else	
	dbSetOrder(nOrdem)
Endif	
dbGoto(nRecno)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A160IniCpo³ Autor ³ Eduardo Riera         ³ Data ³ 30.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializa os campos da Enchoice.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function a160IniCpo()

M->QML_DTRET := dDataBase
M->QML_HRRET := Time()
M->QML_FREQ  := MV_PAR09
M->QML_DTCOL := dDataBase+MV_PAR09
M->QML_STATUS:= QM2->QM2_STATUS

Return(Nil)

/*/
antigo a160TudOk
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Qmt160tOk ³ Autor ³ Eduardo Riera         ³ Data ³ 30.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida os campos da Enchoice                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Qmt160TOk()
Local lret:=.T.
Local nX  := 0

c_Depto  := M->QML_DEPTO
c_Local  := M->QML_LOCAL
n_Freq   := M->QML_FREQ
d_dtRet  := M->QML_DTRET
c_HrRet  := M->QML_HRRET
d_dtCol  := M->QML_DTCOL
c_HrCol  := M->QML_HRCOL
c_Resp   := M->QML_RESRET
c_Status := M->QML_STATUS
c_Local  := M->QML_LOCAL
c_FilRel := M->QML_FILREL
For nX := 1 To Len(aCpoUsu)				//Campos Criados pelo usuario
	aAdd (a_CpoUsu, &("M->"+aCpoUsu[nX,1]))  
Next	



If ExistBlock("QMT160OK")
	lRet := ExecBlock("QMT160OK",.F.,.F.)  
EndIf 
 
Return lret

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A160Entrad³ Autor ³ Eduardo Riera         ³ Data ³ 30.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controla as movimentacoes de Entrada do Intrumento         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function a160Entrada(cAlias,nReg,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cArqInd := CriaTrab(,.F.)
Local cChave  := ""
Local cFiltro := ""
Local aSavaRot:= aClone(aRotina)
Local nIndex
Local cMarca  := Left(GetMark(),TamSX3("QML_OK")[1]) 
Local nOrdQML := QML->(IndexOrd())
Local aCampos := {{"QML_OK"    ,"",""},; 
  					{"QML_INSTR" ,"",TitSX3("QML_INSTR")[1]},;
					{"QML_REVINS","",TitSX3("QML_REVINS")[1]},;
					{"QML_DTRET" ,"",TitSX3("QML_DTRET")[1]},;
      				{"QML_HRRET" ,"",TitSX3("QML_HRRET")[1]},;
      				{"QML_DTCOL" ,"",TitSX3("QML_DTCOL")[1]},;
      				{"QML_HRCOL" ,"",TitSX3("QML_HRCOL")[1]},;
					{"QML_DTLIM" ,"",TitSX3("QML_DTLIM")[1]},;
					{"QML_FREQ"  ,"",TitSX3("QML_FREQ")[1]},;
      				{"QML_DEPTO" ,"",TitSX3("QML_DEPTO")[1]},;
      				{"QML_LOCAL" ,"",TitSX3("QML_LOCAL")[1]},;
      				{"QML_STATUS","",TitSX3("QML_STATUS")[1]}}
Local cFilSQL := ""
Private lInverte := .F.

if len(TitSX3("QML_DESCR")) > 0    // monta array com descr se foi aplicado o UPDQMT01 
	acampos := {}
	aCampos := {{"QML_OK"    ,"",""},; 
  					{"QML_INSTR" ,"",TitSX3("QML_INSTR")[1]},;
					{"QML_REVINS","",TitSX3("QML_REVINS")[1]},;
					{"QML_DESCR" ,"",TitSX3("QML_DESCR")[1]},;
					{"QML_DTRET" ,"",TitSX3("QML_DTRET")[1]},;
      				{"QML_HRRET" ,"",TitSX3("QML_HRRET")[1]},;
      				{"QML_DTCOL" ,"",TitSX3("QML_DTCOL")[1]},;
      				{"QML_HRCOL" ,"",TitSX3("QML_HRCOL")[1]},;
					{"QML_DTLIM" ,"",TitSX3("QML_DTLIM")[1]},;
					{"QML_FREQ"  ,"",TitSX3("QML_FREQ")[1]},;
      				{"QML_DEPTO" ,"",TitSX3("QML_DEPTO")[1]},;
      				{"QML_LOCAL" ,"",TitSX3("QML_LOCAL")[1]},;
      				{"QML_STATUS","",TitSX3("QML_STATUS")[1]}}
 EndIf      

aRotina := {{ STR0001	,"AxPesqui"	, 0 , 1 },; //"Pesquisar"
			{ STR0009   ,"A160Baixa" , 0 , 3}}  //"Efetuar Entrada"

aMarcados := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros:                                                  ³
//³ MV_PAR01  : Familia Inicial                                  ³
//³ MV_PAR02  : Familia Final                                    ³
//³ MV_PAR03  : Instrumento de                                   ³
//³ MV_PAR04  : Instrumento Ate                                  ³
//³ MV_PAR05  : Departamento de                                  ³
//³ MV_PAR06  : Departamento ate                                 ³
//³ MV_PAR07  : Responsavel de                                   ³
//³ MV_PAR08  : Responsavel ate                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ( Pergunte("QMT161",.T.) )
	cArqInd	:= CriaTrab(,.F.)
	nIndex	:= 0
	cChave  := "QML_FILIAL+QML_TIPO"
	//cFiltro:= "QML_FILIAL=='"+xFilial("QML")+"'.And."
	cFiltro+= "QML_TIPO>='"  +MV_PAR01+"'.And."
	cFiltro+= "QML_TIPO<='"  +MV_PAR02+"'.And."
	cFiltro+= "QML_INSTR>='" +MV_PAR03+"'.And."
	cFiltro+= "QML_INSTR<='" +MV_PAR04+"'.And."
	cFiltro+= "QML_DEPTO>='" +MV_PAR05+"'.And."
	cFiltro+= "QML_DEPTO<='" +MV_PAR06+"'.And."
	cFiltro+= "QML_RESRET>='"+MV_PAR07+"'.And."
	cFiltro+= "QML_RESRET<='"+MV_PAR08+"'.And."
	cFiltro+= "QML_FLAGB=='A'"

	If lQM160Brow
		cFiltro+= ExecBlock("QM160BROW",.F.,.F.,{.F.,"QML"})
	Endif

	cFilSQL:= "QML_TIPO>='"  +MV_PAR01+"' AND "
	cFilSQL+= "QML_TIPO<='"  +MV_PAR02+"' AND "
	cFilSQL+= "QML_INSTR>='" +MV_PAR03+"' AND "
	cFilSQL+= "QML_INSTR<='" +MV_PAR04+"' AND "
	cFilSQL+= "QML_DEPTO>='" +MV_PAR05+"' AND "
	cFilSQL+= "QML_DEPTO<='" +MV_PAR06+"' AND "
	cFilSQL+= "QML_RESRET>='"+MV_PAR07+"' AND "
	cFilSQL+= "QML_RESRET<='"+MV_PAR08+"' AND "
	cFilSQL+= "QML_FLAGB='A'"
	
	//Garantir um cMarca diferente dos instrumentos emprestados
	Processa( {|| cMarca := getcMarca("QML", cFilSQL) }, STR0043, STR0044,.F.) //"Aguarde..." ### "Buscando registros..." 

	dbSelectArea("QML")
	IndRegua("QML",cArqInd,cChave,,cFiltro)
	nIndex := RetIndex("QML")
	dbSetOrder(nIndex+1)

	dbSelectArea("QML")
	dbGotop() // IndRegua
	If ( ! Eof() )
		MarkBrow("QML","QML_OK",,aCampos,,@cMarca,"SetMrkAll('QML', 'QML_OK', cMarca)",,"xFilial","xFilial","MrkDblClk('QML', 'QML_OK', lInverte, cMarca)")
	Else
		Help(" ",1,"RECNO")
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna as condicoes anteriores                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRotina := Aclone(aSavARot)
RetIndex("QML")
dbClearFilter()
Ferase(cArqInd+OrdBagExt())
dbSelectArea("QML")
If lQM160Brow
	ExecBlock("QM160BROW",.F.,.F.,{.T.,"QML"})
Endif
dbSetOrder(nOrdQML)
dbGoto(nReg)
Return(3)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A160Baixa ³ Autor ³ Eduardo Riera         ³ Data ³ 30.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Baixa a movimentacao do instrumento.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function a160Baixa(cAlias,cCampo,nOpcE,cMarca,lInverte)
Local lMovs := .T.
Local lInco := .F.
Local nCounts := 0
Local lAltLoc := GetMV("MV_QMLTLOC",.F.,"1") == "1" 
local lQMT160KD := .T.
Local lPe160KD := ExistBlock("QMT160KD")
Local lQMT160BX := ExistBlock("QMT160BX")
Local nX := 0

dbSelectArea("QML")
dbGotop()

	IF !EMPTY(aMarcados)
		FOR nX := 1 TO LEN(aMarcados)

			QML->(DBGOTO( aMarcados[nX] ))

			If  QML->QML_DTRET <= dDatabase  //Faco a  movimentacao de retorno quando a Data de Retirada for menor que  a Data de Devolucao
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona Registros.                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nCounts++
				lMovs := .T.
				dbSelectArea("QM1")
				dbSetOrder(1)
				dbSeek(xFilial("QM1")+QML->QML_TIPO)

				dbSelectArea("QM2")
				dbSetOrder(1)
				dbSeek(xFilial("QM2")+QML->QML_INSTR)
				
				//Ponto de entrada p/ validacao de OK para devolução de instrumentos
				//LCA - TSC815 - Novembro 2017
				IF lPe160KD
				lQMT160KD := ExecBlock("QMT160KD",.F.,.F.)  
				lInco      := lQMT160KD
				EndIf 
				
				IF lQMT160KD
						RecLock("QML",.F.)
						QML->QML_FILIAL := xFilial("QML")
						QML->QML_DTCOL  := dDataBase
						QML->QML_HRCOL  := If (Empty(MV_PAR09),Time(),MV_PAR09)
						QML->QML_FLAGB  := "B"
						//Altera Localizacao 
						If lAltLoc 
							QML->QML_LOCAL  := MV_PAR10 // Se nao preencher, retorna branco
						Endif   
						MsUnLock()
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza Cadastro de Instrumentos                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("QM2")
						dbSetOrder(1)
						RecLock("QM2")
						If !Empty(mv_par11) //Novo Departamento
							QM2->QM2_DEPTO := mv_par11
						Else
							QM2->QM2_DEPTO := QM1->QM1_DISTR
						Endif
			
						If !Empty(mv_par12) //Novo Responsavel
							QM2->QM2_RESP  := mv_par12
						Else
							QM2->QM2_RESP  := QM1->QM1_RDISTR
						Endif
			
						QM2->QM2_LOCAL := MV_PAR10 //QML->QML_LOCAL
						MsUnLock()
				ELSE 
					EXIT 
				ENDIF 
				If lQMT160BX
					ExecBlock("QMT160BX",.F.,.F.,{QML->QML_INSTR,QML->QML_REVINS})
				EndIf
			Else
				lInco := .F.
			EndIf
		NEXT nX
	ENDIF

If !lMovs //Caso nao tenha escolhido instrumento
    MsgInfo(OemToAnsi(STR0029),OemToAnsi(STR0031)) //"Nenhum instrumento foi movimentado"
Else
    If !lInco .And. nCounts == 0
        MsgAlert(STR0037) //" O sistema nao conseguiu executar a movimentacao de um ou mais instrumentos, verifique os dados de  emprestimo."
    Else
        MsgInfo(Alltrim(Str(nCounts))+STR0030,OemToAnsi(STR0031)) //" instrumento(s) movimentado(s)"
    EndIf
Endif

CloseBrowse()

dbSelectArea(cAlias)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A160Status³ Autor ³ Eduardo Riera         ³ Data ³ 30.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica o Status do Instrumento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A160Status()

Local lRetorno
Local aArea := { Alias() , IndexOrd() , Recno() }
dbSelectArea("QMP")
dbSetOrder(1)
dbSeek(xFilial("QMP")+M->QML_STATUS)
If ( QMP->QMP_ATUAL != "S" )
	lRetorno := .F.
Else
	lRetorno := .T.
EndIf

dbSelectArea(aArea[1])
dbSetOrder(aArea[2])
dbGoto(aArea[3])
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A160Depto ³ Autor ³ Eduardo Riera         ³ Data ³ 30.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica o Depto  do Instrumento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A160Depto()

Local lRetorno
Local aArea := { Alias() , IndexOrd() , Recno() }
dbSelectArea("QM1")
dbSetOrder(1)
dbSeek(xFilial("QM1")+QM2->QM2_TIPO)
If ( QM1->QM1_DISTR ==  M->QML_DEPTO )
	Help(" ",1,"QMTA160DEP") // O instrumento nao pode ser movimentado para o departamento padrao
	lRetorno := .F.
Else
	lRetorno := .T.
EndIf

dbSelectArea(aArea[1])
dbSetOrder(aArea[2])
dbGoto(aArea[3])
Return(lRetorno)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a160Exclui³ Autor ³ Eduardo Riera         ³ Data ³ 08.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclusao da Movimentacao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function a160Exclui(cAlias,nReg,nOpcx)

Local nOpcA

Private aAC := {STR0011,STR0013} //"Abandona"###"Confirma"
Private cOkFunc
Private cDelFunc

If ( QML->QML_FLAGB!="B" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Registros.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QM1")
	dbSetOrder(1)
	dbSeek(xFilial("QM1")+QML->QML_TIPO)
	dbSelectArea("QM2")
	dbSetOrder(1)
	dbSeek(xFilial("QM2")+QML->QML_INSTR)
	dbSelectArea(cAlias)
	Begin Transaction
		nOpca := AxDeleta(cAlias,nReg,nOpcx)
		If ( nOpca == 2 )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza Cadastro de Instrumentos                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QM2")
			dbSetOrder(1)
			RecLock("QM2")
			QM2->QM2_DEPTO := QM1->QM1_DISTR
			QM2->QM2_RESP  := QM1->QM1_RDISTR
			QM2->QM2_LOCAL := QML->QML_LOCAL
		EndIf
	End Transaction
Else
	Help(" ",1,"QMTA160DEL") // Nao pode ser excluido
EndIf
Return(nOpcA)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a160Movi  ³ Autor ³ Wanderley Goncalves   ³ Data ³ 04.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca instrumentos que podem sofrer movimentacao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function a160Movi()

Local lRet := .T.

QM1->(DbSetOrder(1))
QM1->(DbSeek(xFilial("QM1")+QM2->QM2_TIPO))

If !QM1->(Eof())
	If QM1->QM1_LOCAL == "S"
		lRet := .F.
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Qmt160DvolºAutor  ³Denis Martins       º Data ³  07/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pelo envio de e-mail aos responsaveis dosº±±
±±º          ³emprestimos                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ X2_ROTINA - QML                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt160Dvol()

Local cMsgR			:= ""
Local cSubject		:= ""
Local lFirst 		:= .T.
Local cIndex		:= ""
Local cNomePri		:= ""
Local cNomeArq		:= SubStr(DtoS(dDataBase),5,7)+".QMD"  
Local n				:= 30

Private lEnviad 		:= .F.
Private nCurrent	:= 0
Private nTamTxt		:= 0 
Private nFilePosTxt	:= 0
Private cBufTxt		:= ""
Private aUsrMail	:= {}
Private nHdl		:= 0
Private lAchou		:= .F.
Private cMail		:= ""
Private cRecMa  	:= ""
Private	TRB_FILIAL	:=	""
Private	TRB_INSTR	:=	""
Private	TRB_REVINS	:=	""
Private	TRB_RESRET	:=	""
Private	TRB_DTCOL	:=	""
Private cQuery		:= ""
Private cKey := ""
Private cNomeAnt	:= ""
Private cTpMail		:= ""
cSubject := OemToAnsi(STR0014) //Aviso de Devolucao de Instrumento

//Deleta arquivo anterior
While  n >  3
	If File(SubStr(DtoS(dDataBase-n),5,7)+".QMD")
   		FErase(SubStr(DtoS(dDataBase-n),5,7)+".QMD")
	Endif 
	n--  
enddo
 

//Cria arquivo com data
If File(cNomeArq)
	nHdl := FOpen( cNomeArq, FO_READWRITE+FO_SHARED ) 
Else	
	nHdl := FCreate( cNomeArq, FC_NORMAL ) 
Endif		

dbSelectArea("QML")                                 
cKey := "QML_FILIAL+QML_RESRET+QML_INSTR"
cQuery := "SELECT QML_FILIAL,QML_INSTR,QML_REVINS,QML_FLAGB,QML_RESRET,QML_DTCOL "
cQuery += " FROM " + RetSqlName("QML") +" QML "
cQuery += " WHERE QML.QML_FILIAL = '"	+ xFilial("QML") + "' AND "
cQuery += " QML.QML_FLAGB = 'A' AND " 			
cQuery += " QML.D_E_L_E_T_<>'*' "
    cQuery += " ORDER BY " + SqlOrder(cKey)

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
dbSelectArea("TRB")

TcSetField( "TRB", "QML_DTCOL", "D")

While !Eof()
	
	TRB_FILIAL	:=	TRB->QML_FILIAL
	TRB_INSTR	:=	TRB->QML_INSTR
	TRB_REVINS	:=	TRB->QML_REVINS
	TRB_RESRET	:=	TRB->QML_RESRET
	TRB_DTCOL	:=	TRB->QML_DTCOL 
	cNomePri	:=  TRB->QML_RESRET			
			

	//Enviar e-mail qdo usuario anterior for diferente de usuario corrente
	//e tiver instrumento jah associado.
	
	If cNomeAnt <> cNomePri .and. !lFirst .and. !Empty(Alltrim(cMail)) .and. Alltrim(cRecMa) == "1"
		If cTpMail == "1"
			cMsgr+='</body>'
			cMsgr+='</html>'
		Endif	
	
		aMsg:= { { cSubject,cMsgR, "" } }     		                                              
		aadd(aUsrMail,{ IIf(!Empty(cNomeAnt),cNomeAnt,Alltrim(QAA->QAA_APELID)),Trim(cMail),aMsg })
		If cTpMail == "1"
			If lEnviad //Len(cMsgR) > 714 //Somente enviar quando existir instrumento(s).
				QaEnvMail(aUsrMail,,,,)
			Endif
		Else
			If lEnviad //Len(cMsgR) > 239 //Somente enviar quando existir instrumento(s).
				QaEnvMail(aUsrMail,,,,)
			Endif
		Endif	
		cNomePri := TRB_RESRET
		aMsg := {}
		cMsgR := ""
		lFirst := .t.
		aUsrMail := {}
	Endif	

	dbSelectArea("QM2")
	dbSetOrder(1)
	If !dbSeek(xFilial("QM2")+TRB_INSTR+Inverte(TRB_REVINS))
		dbSelectArea("QML")		
		QML->(dbSkip())
		Loop
	Endif
	
	
	dbSelectArea("QAA")
	dbSetOrder(1)
	dbSeek(xFilial("QAA")+TRB_RESRET)
    cMail	:= Alltrim(QAA->QAA_EMAIL)
	cRecMa  := QAA->QAA_RECMAI
	cTpMail := QAA->QAA_TPMAIL
	
	If dDataBase >= (QM2->QM2_VALDAF - 5) .and. ((QM2->QM2_VALDAF - 5) <= (dDataBase + 5) .and. (QM2->QM2_VALDAF + 5) >= dDataBase)
		If Alltrim(cNomePri) == Alltrim(TRB_RESRET) .and. !Empty(cMail) .and. Alltrim(cRecMa) == "1"
			cNomePri := TRB_RESRET
			If cTpMail == "1" // Se for HTML
				If lFirst
					cMsgr :='<html>'
					cMsgr +='<head>'
					cMsgr +='<meta http-equiv="Content-Language" content="pt-br">'
					cMsgr +='<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
					cMsgr +='<meta name="GENERATOR" content="Microsoft FrontPage 4.0">'
					cMsgr +='<meta name="ProgId" content="FrontPage.Editor.Document">'
					cMsgr +='<title>SigaQmt - Devolucao</title>'
					cMsgr +='</head>'
					cMsgr +='<body>'
					cMsgr +='<p>'+OemToAnsi(STR0019)+SubStr(QAA->QAA_NOME,1,15)+';'+'</p>'
					cMsgr +='<p>'+OemToAnsi(STR0016) //Por motivo de afericao desse(s) instrumento(s), por 		
					cMsgr +=OemToAnsi(STR0017)+'</p>' //gentileza devolve-lo(s) ao departamento de metrologia.
					cMsgr +='<table border="1" width="100%" borderColor=#0099cc cellSpacing=1 borderColorLight=#0099cc border=1>'
					cMsgr +='  <tr>'
					cMsgr +='  <td width="50%">'
					cMsgr +='      <p align="center"><b>'+OemToAnsi(STR0008)+'</b></td>' //Instrumento
					cMsgr +='  <td width="50%">'
					cMsgr +='      <p align="center"><b>'+OemToAnsi(STR0018)+'</b></td>' //Data de Afericao
					cMsgr +='  </tr>'
					cMsgr +='</table>'
					lFirst := .F.
					lEnviad := .F.				
				Endif
				Qmt160GIns(@cMsgR)				
			Else // Se for do Tipo Texto
				If lFirst
					cMsgr :="* * * * *"+OemToAnsi(STR0014)+"* * * * *"+Chr(13)+Chr(10)+Chr(13)+Chr(10) 
					cMsgr +=OemToAnsi(STR0019)+SubStr(QAA->QAA_NOME,1,15)+';'+Chr(13)+Chr(10) 
					cMsgr +=OemToAnsi(STR0016)+Chr(13)+Chr(10)  //Por motivo de afericao desse(s) instrumento(s), por 		
					cMsgr +=OemToAnsi(STR0017)+Chr(13)+Chr(10)  //gentileza devolve-lo(s) ao departamento de metrologia.				Endif		
					cMsgr +=Chr(13)+Chr(10)
					cMsgr +=Chr(13)+Chr(10)
					cMsgr +=OemToAnsi(STR0008)+"............"+OemToAnsi(STR0018)+Chr(13)+Chr(10)
					lFirst := .F.
					lEnviad := .F.				
				Endif
				Qmt160GIns(@cMsgR)
			Endif	
		Else
			If cTpMail == "1"
				cMsgr+='</body>'
				cMsgr+='</html>'
			Endif	
	
			aMsg:= { { cSubject,cMsgR, "" } }     		                                              
			aadd(aUsrMail,{ IIf(!Empty(TRB_RESRET),TRB_RESRET,Alltrim(QAA->QAA_APELID)),Trim(cMail),aMsg })
			If cTpMail == "1"
				If lEnviad
					QaEnvMail(aUsrMail,,,,)
					lEnviad := .F.
				Endif
			Else
				If lEnviad
					QaEnvMail(aUsrMail,,,,)
					lEnviad := .F.
				Endif
			Endif	
			aUsrMail := {}
			cNomePri := TRB_RESRET
			aMsg := {}
			cMsgR := ""
			lFirst := .t.
			If cTpMail == "1" .and. !Empty(cMail) .and. Alltrim(cRecMa) == "1"
				If lFirst
					cMsgr :='<html>'
					cMsgr +='<head>'
					cMsgr +='<meta http-equiv="Content-Language" content="pt-br">'
					cMsgr +='<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
					cMsgr +='<meta name="GENERATOR" content="Microsoft FrontPage 4.0">'
					cMsgr +='<meta name="ProgId" content="FrontPage.Editor.Document">'
					cMsgr +='<title>SigaQmt - Devolucao</title>'
					cMsgr +='</head>'
					cMsgr +='<body>'
					cMsgr +='<p>'+OemToAnsi(STR0019)+SubStr(QAA->QAA_NOME,1,15)+';'+'</p>'
					cMsgr +='<p>'+OemToAnsi(STR0016)
					cMsgr += OemToAnsi(STR0017)+'</p>'
					cMsgr +='<table border="1" width="100%" borderColor=#0099cc cellSpacing=1 borderColorLight=#0099cc border=1>'
					cMsgr +='  <tr>'
					cMsgr +='  <td width="50%">'
					cMsgr +='      <p align="center" font face="Arial"><b>'+OemToAnsi(STR0008)+'</b></font></p></td>' 
					cMsgr +='  <td width="50%">'
					cMsgr +='      <p align="center" font face="Arial"><b>'+OemToAnsi(STR0018)+'</b></font></p></td>'
					cMsgr +='  </tr>'
					cMsgr +='</table>'
					lFirst := .F.    
					lEnviad := .F.				
				Endif
			Else
				If !Empty(cMail) .and. Alltrim(cRecMa) == "1"
					If lFirst 
						cMsgr :="* * * * *"+OemToAnsi(STR0014)+"* * * * *"+Chr(13)+Chr(10)+Chr(13)+Chr(10)  
						cMsgr +=OemToAnsi(STR0019)+SubStr(QAA->QAA_NOME,1,15)+';'+Chr(13)+Chr(10) 
						cMsgr +=OemToAnsi(STR0016)+Chr(13)+Chr(10)  //Por motivo de afericao desse(s) instrumento(s), por 		
						cMsgr +=OemToAnsi(STR0017)+Chr(13)+Chr(10)  //gentileza devolve-lo(s) ao departamento de metrologia.				Endif		
						cMsgr +=Chr(13)+Chr(10)
						cMsgr +=Chr(13)+Chr(10)
						cMsgr +=OemToAnsi(STR0008)+"............"+OemToAnsi(STR0018)+Chr(13)+Chr(10)
						lFirst := .F.
						lEnviad := .T.				
					Endif
			Endif
			Endif
			Qmt160GIns(@cMsgR)
		Endif
	Endif

	dbSelectArea("TRB")
	cNomeAnt := TRB->QML_RESRET

	dbSkip()
Enddo
//Garantir o envio do ultimo Responsavel
If cTpMail == "1" .and. !Empty(cMail) .and. Alltrim(cRecMa) == "1"
	If lEnviad //.and. Len(cMsgR) > 714
		aMsg:= { { cSubject,cMsgR, "" } }     		                                              
		aadd(aUsrMail,{ IIf(!Empty(TRB_RESRET),TRB_RESRET,Alltrim(QAA->QAA_NOME)),Trim(cMail),aMsg })
		QaEnvMail(aUsrMail,,,,)
	Endif	
Else
	If !Empty(cMail) .and. Alltrim(cRecMa) == "1"
		If lEnviad //.and. Len(cMsgR) > 239
			aMsg:= { { cSubject,cMsgR, "" } }     		                                              
			aadd(aUsrMail,{ IIf(!Empty(TRB_RESRET),TRB_RESRET,Alltrim(QAA->QAA_NOME)),Trim(cMail),aMsg })
			QaEnvMail(aUsrMail,,,,)
		Endif	
	Endif	
Endif	

If File(cIndex+OrdBagExt())
	dbSelectArea("QML")
	dbSetOrder(1)
	Ferase(cIndex + OrdBagExt())
Else
	dbSelectArea("TRB")
	dbCloseArea()
	dbSelectArea("QML")
	dbSetOrder(1)
Endif	

//Fecha arquivo com os instrumentos
If nHdl > 0
	FClose(nHdl)
Endif	

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Qmt160GInsºAutor  ³Denis Martins       º Data ³  07/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pela gravacao do arquivo texto.          º±±
±±º          ³Instrumento+"D"+Codigo Responsavel Emprestimo				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp1 - Texto Html                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA160                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt160GIns(cMsgR)
If nHdl > 0 .and. !Empty(cMail) .and. Alltrim(cRecMa) == "1"
	nTamTxt := FSEEK( nHdl, 0, FS_END ) //Verifica o tamanho do arquivo
	FSEEK( nHdl, 0 ) //Seta o FSeek para inicio do arquivo 
       	
	nCurrent := 37 //Tamanho da Linha Instrumento + Hora 
	        	
	While( nCurrent <= nTamTxt )
		nFilePosTxt := FSEEK( nHdl, 0, FS_RELATIVE )
		cBufTxt     := FREADSTR( nHdl, nCurrent )
		nBytesTxt   := AT( TRB_INSTR+"D"+TRB_RESRET, cBufTxt )				
		    	
		If nBytesTxt > 0
			lAchou	:= .T.
			Exit
		Else
			lAchou	:= .F.	
		Endif  	
		nCurrent += 37
		Loop
	Enddo
	If !lAchou

		FWrite( nHdl, TRB_INSTR+"D"+TRB_RESRET+TIME()) //Emprestimos		
		FWrite( nHdl, Chr(13)+Chr(10))				

		If cTpMail == "1" //Html
			cMsgr +='<table border="1" width="100%" borderColor=#0099cc cellSpacing=1 borderColorLight=#0099cc border=1>'
			cMsgr +='  <tr>'
			cMsgr +='    <td width="50%">'
			cMsgr +='      <p align="center">'+TRB_INSTR+'</td>'
			cMsgr +='    <td width="50%">'
			cMsgr +='      <p align="center">'+SubStr(DtoS(QM2->QM2_VALDAF),7,2) + "/" +SubStr(DtoS(QM2->QM2_VALDAF),5,2)+"/"+SubStr(DtoS(QM2->QM2_VALDAF),1,4)+'</td>'
			cMsgr +='  </tr>'
			cMsgr +='</table>'
			lEnviad := .T.
		Else
		//Instrumentos............Data de Afericao
		//MMMMMMMMMMMMMMMM........99/99/9999 
			cMsgr +=SubStr(Alltrim(TRB_INSTR),1,16)+Repl(".",28-Len(TRB_INSTR))+SubStr(DtoS(QM2->QM2_VALDAF),7,2) + "/" +SubStr(DtoS(QM2->QM2_VALDAF),5,2)	+ "/" + SubStr(DtoS(QM2->QM2_VALDAF),1,4)+Chr(13)+Chr(10)
			lEnviad := .T.			
		Endif	
	Endif	
Endif
Return cMsgR
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Qmt160Emp ºAutor  ³Denis Martins       º Data ³  07/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pelo envio de e-mail aos responsaveis dosº±±
±±º          ³instrumentos emprestados                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SX2 - ROTINA (QML)                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt160Emp()

Local nHdl			:= 0
Local cMsgR			:= ""
Local cSubject		:= ""
Local cInstr		:= ""
Local cMail			:= ""
Local lFirst 		:= .T.
Local lEnvia 		:= .F.
Local cIndex		:= ""
Local lAchou		:= .F.
Local nCurrent		:= 0
Local nTamTxt		:= 0 
Local nFilePosTxt	:= 0
Local cBufTxt		:= ""
Local cNomePri		:= ""
Local cNomeApl		:= ""        
Local aMatUsr		:= QA_USUARIO()
Local cMailLog		:= aMatUsr[5]
Local cNomeArq		:= SubStr(DtoS(dDataBase),5,7)+aMatUsr[3]+".QMT"
Local cKey          := ""        
Local n				:= 30
Local cQuery		:= ""

Private aUsrMail	:= {}
Private	TRB_FILIAL	:=	""
Private	TRB_INSTR	:=	""
Private	TRB_REVINS	:=	""
Private	TRB_RESRET	:=	""
Private	TRB_DTCOL	:=	""
Private cTpMail		:=  ""
//Deleta arquivo anterior

While  n >  3
	If File(SubStr(DtoS(dDataBase-n),5,7)+aMatUsr[3]+".QMT")
   		FErase(SubStr(DtoS(dDataBase-n),5,7)+aMatUsr[3]+".QMT")
	Endif 
	n--  
enddo

//Cria arquivo com data
If File(cNomeArq)
	nHdl := FOpen( cNomeArq, FO_READWRITE+FO_SHARED ) 
Else	
	nHdl := FCreate( cNomeArq, FC_NORMAL ) 
Endif		

dbSelectArea("QAA")
dbSetOrder(1)
dbSeek(xFilial("QAA")+aMatUsr[3])
cTpMail := QAA->QAA_TPMAIL

dbSelectArea("QML")

cKey   := "QML_FILIAL+QML_INSTR"
cQuery := "SELECT QML_FILIAL,QML_INSTR,QML_REVINS,QML_FLAGB,QML_RESRET,QML_DTCOL "
cQuery += " FROM " + RetSqlName("QML") +" QML "
cQuery += " WHERE QML.QML_FILIAL = '"	+ xFilial("QML") + "' AND "
cQuery += " QML.QML_FLAGB = 'A' AND " 			
cQuery += " QML.D_E_L_E_T_<>'*' "
cQuery += " ORDER BY " + SqlOrder(cKey)

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
dbSelectArea("TRB")

TcSetField( "TRB", "QML_DTCOL", "D")

While !Eof()

	TRB_FILIAL	:=	TRB->QML_FILIAL
	TRB_INSTR	:=	TRB->QML_INSTR
	TRB_REVINS	:=	TRB->QML_REVINS
	TRB_RESRET	:=	TRB->QML_RESRET
	TRB_DTCOL	:=	TRB->QML_DTCOL
				
	dbSelectArea("QM2")
	dbSetOrder(1)
	If dbSeek(xFilial("QM2")+TRB_INSTR+Inverte(TRB_REVINS))
		cNomePri := QM2->QM2_RESP
	Else
		dbSelectArea("QML")
		QML->(dbSkip())
		Loop	
	Endif	
	aMsg:= {}
	If Alltrim(aMatUsr[3]) == Alltrim(cNomePri)
		If dDataBase >= (QM2->QM2_VALDAF - 5) .and. ((QM2->QM2_VALDAF - 5) <= (dDataBase + 5) .and. (QM2->QM2_VALDAF + 5) >= dDataBase)
			dbSelectArea("QAA")
			dbSetOrder(1)
			If dbSeek(xFilial("QAA")+cNomePri)
				cMail	:= Alltrim(QAA->QAA_EMAIL)
				cNomeApl := QAA->QAA_APELID
			Endif
			If dbSeek(xFilial("QAA")+TRB_RESRET)
				cMailRCol := QAA->QAA_EMAIL
				cNomRCol  := QAA->QAA_NOME	
			Endif
			If cTpMail == "1"
				If lFirst
					cMsgR := ""
					cMsgR	:='<html>'
					cMsgR	+='<head>'
					cMsgR	+='<title>SigaQmt</title>'
					cMsgR	+='</head>'
					cMsgR	+='<body>'
					cMsgR	+='<table borderColor=#0099cc height=32 cellSpacing=1 width=670 borderColorLight=#0099cc border=1>' //657
					cMsgR	+='  <tr>'
					cMsgR	+='    <td width="670">' 
					cMsgR	+='      <p align="center"><b><i><font face="Arial" size="3">'+ 'Aviso de Instrumento(s) Emprestado(s) a Calibrar' + '</font></i></b></p>' //'Aviso de Instrumento(s) Emprestado(s) a Calibrar'
					cMsgR	+='    </td>'
					cMsgR	+='  </tr>'
					cMsgR	+='</table>'
					cMsgR	+='<br>'
					cMsgR	+='<table borderColor=#0099cc height=32 cellSpacing=1 width=670 borderColorLight=#0099cc border=1>'
					cMsgR	+='  <tr>'
					cMsgR	+='    <td width="247" height="32">'
					cMsgR	+='      <p align="center"><b><font face="Arial">' + OemToAnsi(STR0008) + '</font></b></p>' //'Instrumento'
					cMsgR	+='    </td>'
					cMsgR	+='    <td width="160" height="32">' 
					cMsgR	+='      <p align="center"><font face="Arial"><b>' + OemToAnsi(STR0020) + '</b></font></p>'//'Responsavel'
					cMsgR	+='    </td>'
					cMsgR	+='    <td width="120" height="32">' 
					cMsgR	+='      <p align="center"><b><font face="Arial">' + OemToAnsi(STR0021) + '</font></b></p>' //'Dt.Devolucao'
					cMsgR	+='    </td>'
					cMsgR	+='    <td width="120" height="32">' 
					cMsgR	+='      <p align="center"><b><font face="Arial">' + OemToAnsi(STR0022) + '</font></b></p>'//'Dt.Afericao'
					cMsgR	+='    </td>'
					cMsgR	+='  </tr>'
					cMsgR	+='</table>'
					cMsgR	+='<br>'
					lFirst := .F.
				Endif
			Else
				If lFirst
					cMsgR	:= ""
					cMsgR	:=OemToAnsi(STR0023)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
					cMsgR	+=OemToAnsi(STR0008)+".........."+OemToAnsi(STR0020)+"........"+OemToAnsi(STR0021)+"........"+OemToAnsi(STR0022)+CHR(13)+CHR(10)
					lFirst := .F.
				Endif					
			Endif
			cInstr := TRB_INSTR
			cSubject := OemToAnsi(STR0014) //AVISO DE DEVOLUCAO DE INSTRUMENTO
			If Alltrim(cNomePri) == Alltrim(QM2->QM2_RESP)
				If nHdl > 0
					nTamTxt := FSEEK( nHdl, 0, FS_END ) //Verifica o tamanho do arquivo
					FSEEK( nHdl, 0 ) //Seta o FSeek para inicio do arquivo 
        	
					nCurrent := 27 //Tamanho da Linha Instrumento + Hora 
		        	
					While( nCurrent <= nTamTxt )
						nFilePosTxt := FSEEK( nHdl, 0, FS_RELATIVE )
						cBufTxt     := FREADSTR( nHdl, nCurrent )
						nBytesTxt   := AT( TRB_INSTR+"E", cBufTxt )				
			    	
						If nBytesTxt > 0
							lAchou	:= .T.
							Exit
						Else
							lAchou	:= .F.	
						Endif  	
						nCurrent += 27
						Loop
					Enddo
					If !lAchou

						FWrite( nHdl, cInstr+"E"+TIME()) //Emprestimos		
						FWrite( nHdl, Chr(13)+Chr(10))				

						If cTpMail == "1"
							cMsgR	+='<table borderColor=#0099cc height=32 cellSpacing=1 width=670 borderColorLight=#0099cc border=1>'
							cMsgR	+='  <tr>'
							cMsgR	+='    <td width="247" height="32">'
							cMsgR	+='      <p align="left">'+Alltrim(TRB_INSTR)+'</td>'
							cMsgR	+='    <td width="160" height="32">'  
							cMsgR	+='      <p align="left">'+cNomeApl+'</td>'
							cMsgR	+='    <td width="120" height="32">' 
							cMsgR	+='      <p align="center" height="32">'+SubStr(DtoS(TRB_DTCOL),7,2) + "/" +SubStr(DtoS(TRB_DTCOL),5,2)	+ "/" + SubStr(DtoS(TRB_DTCOL),1,4)+'</td>'
							cMsgR	+='    <td width="120">' 
							cMsgR	+='      <p align="center" height="32">'+SubStr(DtoS(QM2->QM2_VALDAF),7,2) + "/" +SubStr(DtoS(QM2->QM2_VALDAF),5,2)	+ "/" + SubStr(DtoS(QM2->QM2_VALDAF),1,4)+'</td>'
							cMsgR	+='  </tr>'
							cMsgR	+='</table>' 
							lEnvia	:= .T.
						Else
							cMsgR	+=CHR(13)+CHR(10)
							cMsgR	+=Alltrim(TRB_INSTR)+"........"+cNomeApl+"........"+SubStr(DtoS(TRB_DTCOL),7,2)+"/"+SubStr(DtoS(TRB_DTCOL),5,2)+"/"+SubStr(DtoS(TRB_DTCOL),1,4)+"............"+SubStr(DtoS(TRB_DTCOL),7,2)+"/"+SubStr(DtoS(TRB_DTCOL),5,2)+"/"+SubStr(DtoS(TRB_DTCOL),1,4)+CHR(13)+CHR(10)
							lEnvia	:= .T.							
						Endif	
					Endif	
				Endif	  
			Endif
		Endif
	Endif	
	dbSelectArea("TRB")      	  
	dbSkip()
Enddo                               
If cTpMail == "1"
	cMsgR	+= '</body>'
	cMsgR	+= '</html>'
Endif	

aMsg:= { { cSubject,cMsgR, "" } }     		                                              
aadd(aUsrMail,{ IIf(!Empty(cNomePri),cNomePri,Alltrim(QAA->QAA_APELID)),Trim(cMailLog),aMsg })

If cTpMail == "1"
	If lEnvia 
		QaEnvMail(aUsrMail,,,,)
	Endif	 
Else
	If lEnvia 
		QaEnvMail(aUsrMail,,,,)
	Endif	 
Endif

If File(cIndex+OrdBagExt())
	dbSelectArea("QML")
	dbSetOrder(1)
	Ferase(cIndex + OrdBagExt())
Else
	dbSelectArea("TRB")
	dbCloseArea()
	dbSelectArea("QML")
	dbSetOrder(1)
Endif	

//Fecha arquivo texto
If nHdl > 0
	FClose(nHdl)
Endif	

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Qmt160AVI ºAutor  ³Denis Martins       º Data ³  29/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pelo envio de e-mail aos responsaveis dosº±±
±±º          ³instrumentos emprestados que ainda nao forao devolvidos     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SX2 - ROTINA (QML)                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt160AVI()

Local nHdl			:= 0
Local cMsgR			:= ""
Local cSubject		:= ""
Local cInstr		:= ""
Local cNome			:= ""
Local cMail			:= ""
Local cMailCol 		:= ""
Local lIdt			:= .T.
Local nHeight		:= 28
Local aUsResMail	:= {}
Local lFirst 		:= .T.
Local lEnvia 		:= .F.
Local cIndex		:= ""
Local cCond			:= ""
Local nIndex	
Local nPosNom		:= 0
Local lPrim			:= .T.
Local lAchou		:= .F.
Local nCurrent		:= 0
Local nTamTxt		:= 0 
Local nFilePosTxt	:= 0
Local cBufTxt		:= ""
Local nBytesTxt		:= 0
Local cNomePri		:= ""
Local cNomeApl		:= ""
Local lFisrt		:= .T.
Local aMatUsr		:= QA_USUARIO()
Local cMailLog		:= aMatUsr[5]
Local cNomeArq		:= SubStr(DtoS(dDataBase),5,7)+aMatUsr[3]+".QMV"
Local oDlgEmp
Local cQuery		:= ""
Local cKey          := ""
Local cPrResp 		:= ""
Local cMsgI 		:= ""
Local cMdMail 		:= ""
Local cEnvMo		:= ""   
Local nx			:= 0                    
Local cEnome		:= ""
Local n             :=30
Local cRELACNT    := Alltrim(SuperGetMv("MV_RELACNT"))
Private cNomRCol    := ""
Private aUsrMail	:= {}
Private	TRB_FILIAL	:=	""
Private	TRB_INSTR	:=	""
Private	TRB_REVINS	:=	""
Private	TRB_RESRET	:=	""
Private	TRB_DTCOL	:=	CTOD("")
Private TRB_FILRES	:=  ""
Private cTpMail		:=  ""
Private aIResp		:= {}

//Deleta arquivo anterior 

While  n >  3
	If File(SubStr(DtoS(dDataBase-n),5,7)+aMatUsr[3]+".QMV")
   		FErase(SubStr(DtoS(dDataBase-n),5,7)+aMatUsr[3]+".QMV")
	Endif 
	n--  
enddo

//Cria arquivo com data
If File(cNomeArq)
	nHdl := FOpen( cNomeArq, FO_READWRITE+FO_SHARED ) 
Else	
	nHdl := FCreate( cNomeArq, FC_NORMAL ) 
Endif		

dbSelectArea("QML")

cKey   := "QML_FILIAL+QML_RESRET+QML_INSTR"
cQuery := "SELECT QML_FILIAL,QML_INSTR,QML_REVINS,QML_FLAGB,QML_RESRET,QML_DTCOL,QML_FILRET "
cQuery += " FROM " + RetSqlName("QML") +" QML "
cQuery += " WHERE QML.QML_FILIAL = '"	+ xFilial("QML") + "' AND "
cQuery += " QML.QML_FLAGB = 'A' AND " 			
cQuery +=  "QML.QML_DTCOL  < '"	+ DtoS(dDataBase) + "' AND "
cQuery += " QML.D_E_L_E_T_<>'*' "
cQuery += " ORDER BY " + SqlOrder(cKey)

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
dbSelectArea("TRB")

TcSetField( "TRB", "QML_DTCOL", "D") 
//Associa o responsavel pela primeira vez...
If !Eof()
	cNomePri := TRB->QML_RESRET
Endif

While !Eof()
	TRB_FILIAL	:=	TRB->QML_FILIAL
	TRB_INSTR	:=	TRB->QML_INSTR
	TRB_REVINS	:=	TRB->QML_REVINS
	TRB_RESRET	:=	TRB->QML_RESRET
	TRB_DTCOL	:=	TRB->QML_DTCOL
	TRB_FILRES	:=	TRB->QML_FILRET
    //Pegar o Mail Logado
	dbSelectArea("QAA")
	dbSetOrder(1)
	If dbSeek(TRB_FILRES+TRB_RESRET) //xFilial("QAA")
		cNomRCol  := QAA->QAA_NOME	
		cMailLog  := QAA->QAA_EMAIL
	Endif

	//Monta array com os responsaveis pelos instrumentos...
	dbSelectArea("QM2")
	dbSetOrder(1)
	If dbSeek(xFilial("QM2")+TRB_INSTR+Inverte(TRB_REVINS))
		dbSelectArea("QAA")
		dbSetOrder(1)
		If dbSeek(QM2->QM2_FILRES+QM2->QM2_RESP)	//xFilial("QAA")
			cTpMail := QAA->QAA_TPMAIL
			Aadd(aIResp,{TRB_INSTR,TRB_DTCOL,QM2->QM2_RESP,QAA->QAA_TPMAIL,QAA->QAA_EMAIL,QAA->QAA_NOME})
		Endif
	Endif
               
	If Alltrim(cNomePri) <> Alltrim(TRB_RESRET)
		If Len(cMsgR) > 0
			If cTpMail == "1"
				cMsgR	+= '</body>'
				cMsgR	+= '</html>'
			Endif	
			aMsg:= { { cSubject,cMsgR, "" } }     		                                              
			If Empty(cMailLog)
				cMailLog := cRELACNT
			Endif
			aadd(aUsrMail,{ cNomePri,Trim(cMailLog),aMsg })

			If lEnvia
				If !Empty(cMailLog)
					QaEnvMail(aUsrMail,,,,)
				Endif	
			Endif
			lEnvia := .F.					 
		Else
			If lEnvia
				If !Empty(cMailLog)
					QaEnvMail(aUsrMail,,,,)
				Endif	
			Endif
			lEnvia := .F.	
		Endif	 
		aUsrMail := {}
		lFirst := .T.
	Endif

	aMsg:= {}

	dbSelectArea("QAA")
	dbSetOrder(1)
	If dbSeek(TRB_FILRES+TRB_RESRET) //xFilial("QAA")
		cNomRCol  := QAA->QAA_NOME	
	Endif

	If cTpMail == "1"
		If lFirst
			cMsgR   := ""
			cMsgR	:='<html>'
			cMsgR	+='<head>'
			cMsgR	+='<title>SigaQmt</title>'
			cMsgR	+='</head>'
			cMsgR	+='<body>'
			cMsgR	+='<table borderColor=#0099cc height=32 cellSpacing=1 width=670 borderColorLight=#0099cc border=1>' //657
			cMsgR	+='  <tr>'
			cMsgR	+='    <td width="670">' 
			cMsgR	+='      <p align="center"><b><i><font face="Arial" size="3">'+ OemToAnsi(STR0032) + '</font></i></b></p>' //'Aviso de Instrumento(s) Emprestado(s) Nao Devolvidos'
			cMsgR	+='    </td>'
			cMsgR	+='  </tr>'
			cMsgR	+='</table>'
			cMsgR	+='<br>'
			cMsgR	+='<table borderColor=#0099cc height=32 cellSpacing=1 width=670 borderColorLight=#0099cc border=1>'
			cMsgR	+='  <tr>'
			cMsgR	+='    <td width="247" height="32">'
			cMsgR	+='      <p align="center"><b><font face="Arial">' + OemToAnsi(STR0008) + '</font></b></p>' //'Instrumento'
			cMsgR	+='    </td>'
			cMsgR	+='    <td width="160" height="32">' 
			cMsgR	+='      <p align="center"><font face="Arial"><b>' + OemToAnsi(STR0020) + '</b></font></p>'//'Responsavel'
			cMsgR	+='    </td>'
			cMsgR	+='    <td width="120" height="32">' 
			cMsgR	+='      <p align="center"><b><font face="Arial">' + OemToAnsi(STR0021) + '</font></b></p>' //'Dt.Devolucao'
			cMsgR	+='    </td>'
			cMsgR	+='    <td width="120" height="32">' 
			cMsgR	+='      <p align="center"><b><font face="Arial">' + OemToAnsi(STR0033) + '</font></b></p>'//'Data Atual'
			cMsgR	+='    </td>'
			cMsgR	+='  </tr>'
			cMsgR	+='</table>'
			cMsgR	+='<br>'
			lFirst := .F.
		Endif
	Else
		If lFirst
			cMsgR	:= ""
			cMsgR	:=OemToAnsi(STR0032)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
			cMsgR	+=OemToAnsi(STR0008)+".........."+OemToAnsi(STR0020)+"........"+OemToAnsi(STR0021)+"........"+OemToAnsi(STR0033)+CHR(13)+CHR(10)
			lFirst := .F.
		Endif					
	Endif
	cInstr := TRB_INSTR
	cSubject := OemToAnsi(STR0032) //AVISO DE DEVOLUCAO DE INSTRUMENTO
	If nHdl > 0
		nTamTxt := FSEEK( nHdl, 0, FS_END ) //Verifica o tamanho do arquivo
		FSEEK( nHdl, 0 ) //Seta o FSeek para inicio do arquivo 
       	
		nCurrent := 27 //Tamanho da Linha Instrumento + Hora 
        	
		While( nCurrent <= nTamTxt )
			nFilePosTxt := FSEEK( nHdl, 0, FS_RELATIVE )
			cBufTxt     := FREADSTR( nHdl, nCurrent )
			nBytesTxt   := AT( TRB_INSTR+"E", cBufTxt )				
	    	
			If nBytesTxt > 0
				lAchou	:= .T.
				Exit
			Else
				lAchou	:= .F.	
			Endif  	
			nCurrent += 27
			Loop
		Enddo
		If !lAchou

			FWrite( nHdl, cInstr+"E"+TIME()) //Emprestimos		
			FWrite( nHdl, Chr(13)+Chr(10))				

			If cTpMail == "1"
				cMsgR	+='<table borderColor=#0099cc height=32 cellSpacing=1 width=670 borderColorLight=#0099cc border=1>'
				cMsgR	+='  <tr>'
				cMsgR	+='    <td width="247" height="32">'
				cMsgR	+='      <p align="left">'+Alltrim(TRB_INSTR)+'</td>'
				cMsgR	+='    <td width="160" height="32">'  
				cMsgR	+='      <p align="left">'+SubStr(cNomRCol,1,10)+'</td>'
				cMsgR	+='    <td width="120" height="32">' 
				cMsgR	+='      <p align="center" height="32">'+SubStr(DtoS(TRB_DTCOL),7,2) + "/" +SubStr(DtoS(TRB_DTCOL),5,2)	+ "/" + SubStr(DtoS(TRB_DTCOL),1,4)+'</td>'
				cMsgR	+='    <td width="120">' 
				cMsgR	+='      <p align="center" height="32">'+SubStr(DtoS(dDataBase),7,2) + "/" +SubStr(DtoS(dDataBase),5,2)	+ "/" + SubStr(DtoS(dDataBase),1,4)+'</td>'
				cMsgR	+='  </tr>'
				cMsgR	+='</table>' 
				lEnvia	:= .T.
			Else
				cMsgR	+=CHR(13)+CHR(10)
				cMsgR	+=Alltrim(TRB_INSTR)+"........"+SubStr(cNomRCol,1,10)+"........"+SubStr(DtoS(TRB_DTCOL),7,2)+"/"+SubStr(DtoS(TRB_DTCOL),5,2)+"/"+SubStr(DtoS(TRB_DTCOL),1,4)+"............"+SubStr(DtoS(dDataBase),7,2)+"/"+SubStr(DtoS(dDataBase),5,2)+"/"+SubStr(DtoS(dDataBase),1,4)+CHR(13)+CHR(10)
				lEnvia	:= .T.							
			Endif	
		Endif	
	Endif	  

	cNomePri := TRB_RESRET

	dbSelectArea("TRB")      	  
	dbSkip()
Enddo                               
If cTpMail == "1"
	cMsgR	+= '</body>'
	cMsgR	+= '</html>'
Endif	

aMsg:= { { cSubject,cMsgR, "" } }     		                                              
aadd(aUsrMail,{ IIf(!Empty(cNomePri),cNomePri,Alltrim(QAA->QAA_APELID)),Trim(cMailLog),aMsg })

If cTpMail == "1"
	If lEnvia 
		If !Empty(cMailLog)
			QaEnvMail(aUsrMail,,,,)
		Endif	
	Endif	            
	lEnvia := .F.
Else
	If lEnvia 
		If !Empty(cMailLog)
			QaEnvMail(aUsrMail,,,,)
		Endif	
	Endif	 
	lEnvia := .F.
Endif
//Envia e-mail para os responsaveis dos instrumentos - QM2
If Len(aIResp) > 0
	lFirst := .t.
	aSort(aIResp,,, { |x,y| x[3] < y[3] } )
	cPrResp := ""                   
	cMsgI 	:= ""
	cMdMail := ""
	cEnvMo	:= ""   
	aUsrMail:= {}                  
	lAchou	:= .F.	
	For nx := 1 To Len(aIResp)
		If nHdl > 0
			nTamTxt := FSEEK( nHdl, 0, FS_END ) //Verifica o tamanho do arquivo
			FSEEK( nHdl, 0 ) //Seta o FSeek para inicio do arquivo 
       	
			nCurrent := 27 //Tamanho da Linha Instrumento + Hora 
        		
			While( nCurrent <= nTamTxt )
				nFilePosTxt := FSEEK( nHdl, 0, FS_RELATIVE )
				cBufTxt     := FREADSTR( nHdl, nCurrent )
				nBytesTxt   := AT(aIResp[nx][1]+"R", cBufTxt )				
	    	
				If nBytesTxt > 0
					lAchou	:= .T.
					Exit
				Else
					lAchou	:= .F.	
				Endif  	
				nCurrent += 27
				Loop
			Enddo		
			If !lAchou
				FWrite( nHdl, aIResp[nx][1]+"R"+TIME()) //Emprestimos		
				FWrite( nHdl, Chr(13)+Chr(10))				
			Endif	
		Endif
		
		If cPrResp <> aIResp[nx][3]
			If !lFirst 
				If cMdMail == "1"
					cMsgI	+= '</body>'
					cMsgi	+= '</html>'
				Endif	                                   
				aMsg:= {}				
				aMsg:= { { OemToAnsi(STR0032),cMsgI, "" } }  //Instrumentos emprestados Nao devolvidos...     		                                               
				aUsrMail := {}
				aadd(aUsrMail,{cEnome,Trim(cEnvMo),aMsg })
				If !Empty(cEnvMo) .and. !lAchou
					QaEnvMail(aUsrMail,,,,)
				Endif	
			Endif				
			
			cMsgI := ""
			cMsgI := QM160Msca(aIResp[nx][4],cMsgI)
			cMsgI := Q160SmIns(aIResp[nx][4],cMsgI,aIResp[nx][1],aIResp[nx][2],aIResp[nx][6],aIResp[nx][5])			
		Else
			cMsgI := Q160SmIns(aIResp[nx][4],cMsgI,aIResp[nx][1],aIResp[nx][2],aIResp[nx][6],aIResp[nx][5])			
		Endif                     
		lFirst := .f.
		cPrResp := aIResp[nx][3]
		cMdMail := aIResp[nx][4]
		cEnvMo	:= aIResp[nx][5]
		cEnome	:= aIResp[nx][6]		
	Next nx
Endif

If Len(aIResp) > 0
	If cMdMail == "1"
		cMsgI	+= '</body>'
		cMsgI	+= '</html>'
	Endif	
	aMsg:= {}				
	aMsg:= { { OemToAnsi(STR0032) ,cMsgI, "" } }  //"Instrumento(s) Emprestado(s) NAO Devolvido(s)"     		                                               
	aUsrMail := {}
	aadd(aUsrMail,{cEnome,Trim(cEnvMo),aMsg })
	If !Empty(cEnvMo) .and. !lAchou		
		QaEnvMail(aUsrMail,,,,)
	Endif	
Endif

If File(cIndex+OrdBagExt())
	dbSelectArea("QML")
	dbSetOrder(1)
	Ferase(cIndex + OrdBagExt())
Else
	dbSelectArea("TRB")
	dbCloseArea()
	dbSelectArea("QML")
	dbSetOrder(1)
Endif	

//Fecha arquivo texto
If nHdl > 0
	FClose(nHdl)
Endif	
		
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QM160Msca ºAutor  ³Denis Martins       º Data ³  01/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³MONTA CABECALHO DE INSTRUMENTOS EMPRESTADOS E AINDA NAO DE- º±±
±±º          ³VOLVIDOS                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA160                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM160Msca(cTipos)
If cTipos == "1"
	cMsgI  	:='<html>'
	cMsgI  	+='<head>'
	cMsgI  	+='<title>SigaQmt</title>'
	cMsgI  	+='</head>'
	cMsgI  	+='<body>'
	cMsgI  	+='<table borderColor=#0099cc height=32 cellSpacing=1 width=670 borderColorLight=#0099cc border=1>' //657
	cMsgI  	+='  <tr>'
	cMsgI  	+='    <td width="670">' 
	cMsgI  	+='      <p align="center"><b><i><font face="Arial" size="3">'+ OemToAnsi(STR0032) + '</font></i></b></p>' //'Aviso de Instrumento(s) Emprestado(s) Nao Devolvidos'
	cMsgI  	+='    </td>'
	cMsgI  	+='  </tr>'
	cMsgI  	+='</table>'
	cMsgI  	+='<br>'
	cMsgI  	+='<table borderColor=#0099cc height=32 cellSpacing=1 width=670 borderColorLight=#0099cc border=1>'
	cMsgI  	+='  <tr>'
	cMsgI  	+='    <td width="247" height="32">'
	cMsgI  	+='      <p align="center"><b><font face="Arial">' + OemToAnsi(STR0008) + '</font></b></p>' //'Instrumento'
	cMsgI  	+='    </td>'
	cMsgI  	+='    <td width="160" height="32">' 
	cMsgI  	+='      <p align="center"><font face="Arial"><b>' + OemToAnsi(STR0020) + '</b></font></p>'//'Responsavel'
	cMsgI  	+='    </td>'
	cMsgI  	+='    <td width="120" height="32">' 
	cMsgI  	+='      <p align="center"><b><font face="Arial">' + OemToAnsi(STR0021) + '</font></b></p>' //'Dt.Devolucao'
	cMsgI  	+='    </td>'
	cMsgI  	+='    <td width="120" height="32">' 
	cMsgI  	+='      <p align="center"><b><font face="Arial">' + OemToAnsi(STR0033) + '</font></b></p>'//'Data Atual'
	cMsgI  	+='    </td>'
	cMsgI  	+='  </tr>'
	cMsgI  	+='</table>'
	cMsgI  	+='<br>'
Else
	cMsgI  	:=OemToAnsi(STR0032)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cMsgI  	+=OemToAnsi(STR0008)+".........."+OemToAnsi(STR0020)+"........"+OemToAnsi(STR0021)+"........"+OemToAnsi(STR0033)+CHR(13)+CHR(10)
Endif

Return cMsgI			

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q160SmIns ºAutor  ³Denis Martins       º Data ³  01/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³MONTA ITENS DE INSTRUMENTOS EMPRESTADOS E AINDA NAO DEVOLVI-º±±
±±º          ³DOS                                                    	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA160                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q160SmIns(cTipos,cMsgI,cIinstrm,dDtIns,cEnome,cMlRes)

If cTipos == "1"
	cMsgI  	+='<table borderColor=#0099cc height=32 cellSpacing=1 width=670 borderColorLight=#0099cc border=1>'
	cMsgI  	+='  <tr>'
	cMsgI  	+='    <td width="247" height="32">'
	cMsgI  	+='      <p align="left">'+Alltrim(cIinstrm)+'</td>'
	cMsgI  	+='    <td width="160" height="32">'  
	cMsgI  	+='      <p align="left">'+SubStr(cEnome,1,10)+'</td>'
	cMsgI  	+='    <td width="120" height="32">' 
	cMsgI  	+='      <p align="center" height="32">'+SubStr(DtoS(dDtIns),7,2) + "/" +SubStr(DtoS(dDtIns),5,2)	+ "/" + SubStr(DtoS(dDtIns),1,4)+'</td>'
	cMsgI  	+='    <td width="120">' 
	cMsgI  	+='      <p align="center" height="32">'+SubStr(DtoS(dDataBase),7,2) + "/" +SubStr(DtoS(dDataBase),5,2)	+ "/" + SubStr(DtoS(dDataBase),1,4)+'</td>'
	cMsgI  	+='  </tr>'
	cMsgI  	+='</table>' 
Else
	cMsgI  	+=CHR(13)+CHR(10)
	cMsgI  	+=Alltrim(cIinstrm)+"........"+SubStr(cEnome,1,10)+"........"+SubStr(DtoS(dDtIns),7,2)+"/"+SubStr(DtoS(dDtIns),5,2)+"/"+SubStr(DtoS(dDtIns),1,4)+"............"+SubStr(DtoS(dDataBase),7,2)+"/"+SubStr(DtoS(dDataBase),5,2)+"/"+SubStr(DtoS(dDataBase),1,4)+CHR(13)+CHR(10)
Endif	

Return cMsgI

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q160SX3 ³ Autor ³Nilton MK                ³      ³07/08/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta array com os campos criados pelo usuario              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QMT                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 

Static Function Q160SX3 (cAlias,aCpoUsu)
Local nX := 0
Local aStrut
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos criados pelo usuario						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStrut := FWFormStruct(3,cAlias)[3] // Busca os campos usados (X3_USADO) da tabela
For nX := 1 to Len(aStrut)
	If cNivel >= GetSx3Cache(aStrut[nX,1],"X3_NIVEL") .And. GetSx3Cache(aStrut[nX,1],"X3_PROPRI") == "U" .And. GetSx3Cache(aStrut[nX,1],"X3_CONTEXT") <>"V"
		If aScan(aCpoUsu,{|aCpo| AllTrim(aCpo[1]) == AllTrim(aStrut[nX,1])}) == 0
			aAdd(aCpoUsu,{aStrut[nX,1],GetSx3Cache(aStrut[nX,1],"X3_TIPO"),GetSx3Cache(aStrut[nX,1],"X3_CONTEXT")})
		EndIf
	EndIf 
Next nX

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A160Veri  ³ Autor ³ Rafael Duram Santos  ³ Data ³ 11.10.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o   ³ Verifica se o instrumento já foi emprestado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a160Veri()

Local lRet := .F.

If IsInCallStack("canmark")
	Return .F.
Endif

DbSelectArea("QML")
QML->(DbSetOrder(1))

If QML->(DbSeek(xFilial("QM2")+QM2->QM2_INSTR+QM2->QM2_REVINS+'A'))
	lRet := .T.
Endif

Return(lRet)


/*/{Protheus.doc} getcMarca
Retorna um cMarca diferente dos instrumentos emprestados
@type  Static Function
@author rafael.kleestadt
@since 26/08/2019
@version version
@param param, param_type, param_descr
@return cMarca, caractere, marca ainda não usada no banco de dados
@example
(examples)
@see (links_or_references)
/*/
Static Function getcMarca(cAliasQM, cFiltro)
Local cMarca  := ""
Local cQuery  := ""
Local cAlias  := GetNextAlias()
Local cDb     := TcGetDB() //http://tdn.totvs.com/x/PYVc
Local cFilQM := xFilial(cAliasQM)
Local cTabQM := RetSqlName(cAliasQM)

While 1 == 1

	cMarca := GetMark(,cAliasQM, cAliasQM+"_OK")

 	cQuery := " SELECT "+cAliasQM+"."+cAliasQM+"_OK "
	cQuery += "   FROM "+cTabQM+" " +cAliasQM+" "
	cQuery += "  WHERE "+cAliasQM+"."+cAliasQM+"_FILIAL = '"+cFilQM+"' "
	cQuery += "    AND "+cAliasQM+".D_E_L_E_T_ <> '*' "
	If !EMPTY(cFiltro)
		cQuery += "    AND "+cFiltro "
	EndIf
	cQuery += "    AND "+cAliasQM+"."+cAliasQM+"_OK = '"+cMarca+"'"
	If !(cDb $ "ORACLE")
		cQuery += " COLLATE SQL_Latin1_General_CP1_CS_AS "
	EndIf
		
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	If (cAlias)->(!Eof())
		(cAlias)->(DbCloseArea())
		Loop
	Else
		Exit
	EndIf

EndDo

Return cMarca

/*/{Protheus.doc} fGuarMarcads
Guarda os registros marcados
@type  Function
@author rafael.kleestadt
@since 06/05/2020
@version 1.0
@param cChave, caractere, registro contendo os dados da chave unica
@param lGrv, Logical, gravar / excluir registro do array
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function fGrvMarcad(nChave, lGrv)
nPos := 0

nPos := Ascan(aMarcados, nChave )

If lGrv
	If nPos == 0
		AADD(aMarcados, nChave)
	EndIf
Else
	If nPos <> 0
		aDel(aMarcados,nPos)
		aSize(aMarcados,Len(aMarcados)-1)
	EndIf
EndIf
	
Return Nil

/*/{Protheus.doc} SetMrkAll
Ação do clicke no cabeçalho da coluna flag marca / desmarca todos os registros
@type  Function
@author rafael.kleestadt
@since 06/05/2020
@version 1.0
@param cAliasMrk, Character, alias a ser manipulado
@param cFlag, Character, campo a ser marcado / desmarcado
@param cMarca, Character, marca a ser usada pelo browse
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function SetMrkAll(cAliasMrk, cFlag, cMarca)
Local aAreaAnt	:= GetArea()

DbSelectArea(cAliasMrk)
DbSeek(xFilial(cAliasMrk))

	(cAliasMrk)->(dbGotop()) 

    While (cAliasMrk)->(!Eof())
		If !a160Movi() .OR. cAliasMrk = "QML"
			RecLock(cAliasMrk,.F.)
			If Empty((cAliasMrk)->&(cFlag))
				(cAliasMrk)->&(cFlag)    := cMarca
				fGrvMarcad((cAliasMrk)->(RECNO()), .T.)
			Else
				(cAliasMrk)->&(cFlag)    := "  "
				fGrvMarcad((cAliasMrk)->(RECNO()), .F.)
			Endif
			MsUnlock()
		EndIf
        (cAliasMrk)->(dbSkip())
    EndDo
    
    (cAliasMrk)->(dbGotop()) 

MarkBRefresh()

RestArea(aAreaAnt)
Return NIL

/*/{Protheus.doc} MrkDblClk
Ação do click na coluna flag marca / desmarca o registro
@type  Function
@author rafael.kleestadt
@since 06/05/2020
@version 1.0
@param lInverte, Logical, Indica se a marca deve ser considerada invertida.
@param cAliasMrk, Character, alias a ser manipulado
@param cFlag, Character, campo a ser marcado / desmarcado
@param cMarca, Character, marca a ser usada pelo browse
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function MrkDblClk(cAliasMrk, cFlag, lInverte, cMarca)
Local aAreaAnt	:= GetArea()

If !a160Movi() .OR. cAliasMrk = "QML"

	If IsMark(cFlag,cMarca,lInverte)
        RecLock((cAliasMrk),.F.)
            (cAliasMrk)->&(cFlag) := "  "
        MsUnlock()
    Else
        RecLock((cAliasMrk),.F.)
            (cAliasMrk)->&(cFlag) := cMarca
        MsUnlock()
    Endif
	
	If IsMark(cFlag,cMarca,lInverte)
		fGrvMarcad((cAliasMrk)->(RECNO()), .T.)
	Else
		fGrvMarcad((cAliasMrk)->(RECNO()), .F.)
	EndIf

Endif	
RestArea(aAreaAnt)
Return .T.

/*/{Protheus.doc} qmta160Leg
controle da egenda do browse
@type  Function
@author rafael.kleestadt
@since 07/05/2020
@version 1.0
@param lRetCor, logical, indica se deve retornar o array das cores da legenda
@return aRet, array, array das cores da legenda
@example
(examples)
@see (links_or_references)
/*/
Function qmta160Leg(lRetCor)
Local aRet   := {}
Local aCores := {{"BR_VERDE"   ,"EMPTY(QML_FLAGB == 'A')", "Instrumento devolvido" },; //"Instrumento devolvido" 
				 {"BR_VERMELHO","!EMPTY(QML_FLAGB == 'A')", "Instrumento emprestado"}}  //"Instrumento emprestado"


DEFAULT lRetCor := .F.
If ValType(lRetCor) <> 'L'
    lRetCor := .F.
EndIf

If lRetCor
    aEval( aCores, {|x|  Aadd( aRet, {x[2],x[1]} ) } )
Else
    aEval( aCores, {|x|  Aadd( aRet, {x[1],x[3]} ) } )
    BrwLegenda(cCadastro,STR0040,aRet) //"Legenda"
    aRet := Nil
EndIf

Return(aRet)