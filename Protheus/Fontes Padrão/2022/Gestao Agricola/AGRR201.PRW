#INCLUDE "protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AgrR201   � Autor � Ricardo Tomasi     � Data �  24/09/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Relatorio para impress�o da uma ou varias aplica��es.      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Cliente Microsiga                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function AGRR201(cAlias, nReg)

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Aplica��o na Lavoura"
	Local titulo         := "Diverg�ncia por Aplica��o"
	Local nLin           := 80
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local aOrd           := {}

	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "AGRR201"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private cPerg        := "AGR201"
	Private wnrel        := "AGRR201"
	Private cString      := "NP1"
	Private nRegistro    := nReg

	dbSelectArea("NP1")
	dbSetOrder(1)
	

	Pergunte(cPerg,.F.)

	If nRegistro != Nil
		cPerg := ""
	EndIf

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//���������������������������������������������������������������������Ŀ
	//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
	//�����������������������������������������������������������������������

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin, nRegistro) },Titulo)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  24/09/04   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin, nReg)
	Local cFazenda  := ""
	Local cDataApl  := ""
	Local cSafra    := ""
	Local cProduto  := ""
	Local cTalhao   := ""
	Local cArea     := ""
	Local cServico  := ""
	Local aCol      := {}
	Local cIndex
	Local cChave
	Local nIndex

	Private cCodDe  := ""
	Private cCodAte := ""
	Private dDatDe  := ""
	Private dDatAte := ""
	Private cFiltro := ""

	aAdd(aCol, {00,"@!"})              //Codigo + - + Descricao
	aAdd(aCol, {28,"@E 9,999,999.99"}) //Qtd Indicada
	aAdd(aCol, {41,"@!"})              //Unidade de Medida
	aAdd(aCol, {45,"@E 9,999,999.99"}) //Qtd Aplicada
	aAdd(aCol, {59,"@E 9,999,999.99"}) //Divergencias
	aAdd(aCol, {73,"@E 999.99"})      //Percent
	aAdd(aCol, {79,"X"})      //Percent

	If nReg != Nil
		dbGoto(nReg)
		cCodDe    := NP1->NP1_CODIGO
		cCodAte   := NP1->NP1_CODIGO
		dDatDe    := NP1->NP1_DATAPL
		dDatAte   := NP1->NP1_DATAPL
	Else
		cCodDe    := IIf(Empty(MV_PAR01),'      ',MV_PAR01)
		cCodAte   := IIf(Empty(MV_PAR02),'ZZZZZZ',MV_PAR02)
		dDatDe    := IIf(Empty(MV_PAR03),CToD('01/01/80'),MV_PAR03)
		dDatAte   := IIf(Empty(MV_PAR04),CToD('31/12/20'),MV_PAR04)
	EndIf

	cFiltro += "NP1_CODIGO >= '" + cCodDe  + "' .And. "
	cFiltro += "NP1_CODIGO <= '" + cCodAte + "' .And. "
	cFiltro += "DToS(NP1_DATA) >= '" + DToS(dDatDe)  + "' .And. "
	cFiltro += "DToS(NP1_DATA) <= '" + DToS(dDatAte) + "'"
	cFiltro += IIf(Empty(aReturn[7]),""," .And. "+aReturn[7])

	dbSelectArea("NP1")
	dbSetOrder(1)

	cIndex	:= CriaTrab(nil,.f.)
	cChave	:= IndexKey()
	IndRegua("NP1",cIndex,cChave,,cFiltro,"Selecionando Registros...")
	nIndex := RetIndex("NP1")
	DbSelectArea("NP1")
	#IFNDEF TOP
	DbSetIndex(cIndex+OrdBagExt())
	#ENDIF
	DbSetOrder(nIndex+1)
	dbGoTop()

	While !Eof()

		Cabec1 := "Codigo da Previs�o: " + AllTrim(NP1->NP1_CODIGO)

		If lAbortPrint
			@ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 55
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		cFazenda := PadC("Fazenda: " + AllTrim(Posicione("NN2",2,xFilial("NN2")+NP1->NP1_FAZ,"NN2_NOME")),49) //49
		cDataApl := PadR("Data: " + DToC(NP1->NP1_DATA),24) //24
		dbSelectArea("NN1")
		dbSetOrder(1)
		dbSeek(xFilial("NN1")+NP1->NP1_SAFRA,.T.)
		cSafra   := PadR("Safra: " + NN1->NN1_ANO + "/" + NN1->NN1_SEQ + " - " + NN1->NN1_DESCRI,33)
		cProduto := PadR("Produto: " + AllTrim(NN1->NN1_CODPRO) + " " + NN1->NN1_DESPRO,40)
		cTalhao  := PadR("Talh�o: " + NP1->NP1_TALHAO + " " + Posicione("NN3",1,xFilial("NN3")+NP1->NP1_SAFRA+NP1->NP1_FAZ+NP1->NP1_TALHAO,"NN3_DESCRI"),24) //24
		cArea    := PadR("Area do Talh�o: " + Transform(NP1->NP1_AREA, X3Picture("NP1_AREA")) + " Hectares",49) //49
		cServico := PadR("Servi�o a ser executado: " + AllTrim(NP1->NP1_CODSRV) + " " + NP1->NP1_DESSRV ,76) //76

		@ nLin, 00 PSay "+---------------------------------------------------+--------------------------+"; nLin++
		@ nLin, 00 PSay "| "  +               cFazenda                   + " | " +    cDataApl      + " |"; nLin++
		@ nLin, 00 PSay "+-----------------------------------+---------------+--------------------------+";	nLin++
		@ nLin, 00 PSay "| "             + cSafra +        " | " +              cProduto            + " |";	nLin++
		@ nLin, 00 PSay "+--------------------------+--------+------------------------------------------+";	nLin++
		@ nLin, 00 PSay "| " +      cTalhao     + " | " +                cArea                      + " |";	nLin++
		@ nLin, 00 PSay "+--------------------------+---------------------------------------------------+";	nLin++
		@ nLin, 00 PSay "| " +                            cServico                                  + " |";	nLin++
		@ nLin, 00 PSay "+------------------------------------------------------------------------------+"; nLin++

		dbSelectArea('NP2')
		dbSetOrder(2)
		If dbSeek(xFilial('NP2')+NP1->NP1_CODIGO+'MO')
			nLin += 1
			@ nLin, 00 PSay "---------------------------------- MAO-DE-OBRA ---------------------------------"; nLin += 1                                                                                            
			@ nLin, 00 PSay "Codigo - Descricao             Qtd Prevista  Qtd Aplicada  Diverg�ncias         "; nLin += 1
			@ nLin, 00 PSay "--------------------------------------------------------------------------------"; nLin += 1

			While NP2->NP2_CODIGO == NP1->NP1_CODIGO .And. NP2->NP2_TIPO == 'MO'
				@ nLin, aCol[1,1] PSay Subst(AllTrim(NP2->NP2_MOCOD) + ' - ' + AllTrim(NP2->NP2_MONOM),1,27) Picture aCol[1,2]
				@ nLin, aCol[2,1] PSay NP2->NP2_QTDTOT Picture aCol[2,2]
				@ nLin, aCol[3,1] PSay Subst(NP2->NP2_UM,1,2) Picture aCol[3,2]
				@ nLin, aCol[4,1] PSay NP2->NP2_QTDRET Picture aCol[4,2]
				@ nLin, aCol[5,1] PSay (NP2->NP2_QTDRET - NP2->NP2_QTDTOT) Picture aCol[5,2]
				@ nLin, aCol[6,1] PSay Abs(((NP2->NP2_QTDRET * 100)/NP2->NP2_QTDTOT)-100) Picture aCol[6,2]
				@ nLin, aCol[7,1] PSay '%'
				nLin += 1
				dbSkip()
			EndDo
		EndIf

		dbSelectArea('NP2')
		dbSetOrder(3)
		If dbSeek(xFilial('NP2')+NP1->NP1_CODIGO+'EQ')
			nLin += 1
			@ nLin, 00 PSay "--------------------------------- EQUIPAMENTOS ---------------------------------"; nLin += 1
			@ nLin, 00 PSay "Codigo - Descricao             Qtd Prevista  Qtd Aplicada  Diverg�ncias         "; nLin += 1
			@ nLin, 00 PSay "--------------------------------------------------------------------------------"; nLin += 1
			While NP2->NP2_CODIGO == NP1->NP1_CODIGO .And. NP2->NP2_TIPO == 'EQ'
				@ nLin, aCol[1,1] PSay Subst(AllTrim(NP2->NP2_EQCOD) + ' - ' + AllTrim(NP2->NP2_EQNOM),1,27) Picture aCol[1,2]
				@ nLin, aCol[2,1] PSay NP2->NP2_QTDTOT Picture aCol[2,2]
				@ nLin, aCol[3,1] PSay Subst(NP2->NP2_UM,1,2) Picture aCol[3,2]
				@ nLin, aCol[4,1] PSay NP2->NP2_QTDRET Picture aCol[4,2]
				@ nLin, aCol[5,1] PSay (NP2->NP2_QTDRET - NP2->NP2_QTDTOT) Picture aCol[5,2]
				@ nLin, aCol[6,1] PSay Abs(((NP2->NP2_QTDRET * 100)/NP2->NP2_QTDTOT)-100) Picture aCol[6,2]
				@ nLin, aCol[7,1] PSay '%'
				nLin += 1
				dbSkip()
			EndDo
		EndIf

		dbSelectArea('NP2')
		dbSetOrder(4)
		If dbSeek(xFilial('NP2')+NP1->NP1_CODIGO+'PD')
			nLin += 1
			@ nLin, 00 PSay "---------------------------------- PRODUTOS ------------------------------------"; nLin += 1
			@ nLin, 00 PSay "Codigo - Descricao             Qtd Prevista  Qtd Aplicada  Diverg�ncias         "; nLin += 1
			@ nLin, 00 PSay "--------------------------------------------------------------------------------"; nLin += 1
			While NP2->NP2_CODIGO == NP1->NP1_CODIGO .And. NP2->NP2_TIPO == "PD"
				@ nLin, aCol[1,1] PSay PadR(AllTrim(NP2->NP2_PDCOD) + " - " + AllTrim(NP2->NP2_PDNOM),27) Picture aCol[1,2]
				@ nLin, aCol[2,1] PSay NP2->NP2_QTDTOT Picture aCol[2,2]
				@ nLin, aCol[3,1] PSay Subst(NP2->NP2_UM,1,2) Picture aCol[3,2]
				@ nLin, aCol[4,1] PSay NP2->NP2_QTDRET Picture aCol[4,2]
				@ nLin, aCol[5,1] PSay (NP2->NP2_QTDRET - NP2->NP2_QTDTOT) Picture aCol[5,2]
				@ nLin, aCol[6,1] PSay Abs(((NP2->NP2_QTDRET * 100)/NP2->NP2_QTDTOT)-100) Picture aCol[6,2]
				@ nLin, aCol[7,1] PSay '%'
				nLin += 1
				dbSkip()
			EndDo
		EndIf

		nLin += 2
		@ nLin, 00 PSay "+------------ FECHAMENTO ---------------+-------ASSINATURA DO RESPONSAVEL------+"; nLin++
		@ nLin, 00 PSay '|                                       |                                      |';	nLin++
		@ nLin, 00 PSay '+---------------------------------------+--------------------------------------+'
		nLin += 1

		Roda()

		If nReg = Nil; nLin := 80; EndIf              

		dbSelectArea('NP1')
		dbSkip()
	EndDo

	Set Filter To
	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return()

