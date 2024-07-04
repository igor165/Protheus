#INCLUDE "QDOR100.CH"
#INCLUDE "Report.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QDOR100  � Autor � Leandro S. Sabino     � Data � 26/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Pendencia de Devolucao de Revisao Anterior    ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR100	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QDOR100()
Local oReport
Private cPerg	:= "QDR100"

If TRepInUse()
	Pergunte(cPerg,.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	Return QDOR100R3() //Executa vers�o anterior do fonte
EndIf

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 26/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport                                             
Local oSection1 
Local cFilDep  := xFilial("QAD")

oReport   := TReport():New("QDOR100",OemToAnsi(STR0001),"QDR100",{|oReport| PrintReport(oReport)},OemToAnsi(STR0002)+OemToAnsi(STR0003)+OemToAnsi(STR0004))
oReport:SetLandscape(.T.)
//"Devolucao de Revisao Anterior"##"Este programa ir� imprimir uma rela��o das pend�ncias de "##
//"devolucao de revisao anterior de documentos, de acordo com "##"os par�metros definidos pelo usu�rio."

oSection1 := TRSection():New(oReport,STR0010,{"QDU"}) //"Devolucao de Revisao Anterior"
TRCell():New(oSection1,"cUsu"       ,""   ,OemToAnsi(STR0011),,25,,{|| SubStr(QA_NUSR(QDU->QDU_FILMAT,QDU->QDU_MAT,.T.),1,30) } ) //"Usuario"
TRCell():New(oSection1,"QDU_DEPTO"  ,"QDU",                  ,,25,,{|| QA_NDEPT(QDU->QDU_DEPTO,.T.,cFilDep)} )
TRCell():New(oSection1,"cNCOP"      ," "  ,OemToAnsi(STR0012),,12,,{|| Transform(QDU->QDU_NCOP,"9999") } ) //"Total Copias"
TRCell():New(oSection1,"cDEV"       ," "  ,OemToAnsi(STR0013),,11,,{|| Transform((QDU->QDU_NCOP - QDU->QDU_COPPEN),"9999") } )//"Devolvidas" 
TRCell():New(oSection1,"cNDEV"      ,""   ,OemToAnsi(STR0014),,13,,{|| Transform(QDU->QDU_COPPEN,"9999") } ) //"Nao Devolvidas"
TRCell():New(oSection1,"QDU_DTGERA" ,"QDU") 
TRCell():New(oSection1,"QDU_DTBAIX" ,"QDU") 
Return oReport


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � RF080Imp      � Autor � Leandro Sabino   � Data � 22.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RF080Imp(ExpO1)   	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR080                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintReport( oReport )
Local oSection1  := oReport:Section(1)
Local cDoco      := ""
Local cRvDoco    := "" 
Local cFiltro    := " "
Local cSeek      := " "

MakeAdvplExpr(oReport:uParam)

DbSelectArea("QDU")
DbSetOrder(1)

cFiltro:= 'QDU->QDU_FILIAL == "'+xFilial("QDU")+'".And.'
cFiltro+= 'QDU->QDU_DOCTO >=  "'+mv_par01+'" .And. QDU->QDU_DOCTO <= "'+mv_par02+'" .And. '
cFiltro+= 'QDU->QDU_RV >=     "'+mv_par03+'" .And. QDU->QDU_RV <=    "'+mv_par04+'" .And. '
cFiltro+= 'QDU->QDU_MAT >=    "'+mv_par05+'" .And. QDU->QDU_MAT <=   "'+mv_par06+'" .And. '
cFiltro+= 'QDU->QDU_DEPTO >=  "'+mv_par07+'" .And. QDU->QDU_DEPTO <= "'+mv_par08+'"'

oSection1:SetFilter(cFiltro)
While !oReport:Cancel() .And. QDU->(!Eof())
	cSeek:= QDU->QDU_DOCTO+QDU->QDU_RV
	While QDU->(!Eof()) .And. QDU->QDU_DOCTO+QDU->QDU_RV == cSeek
		If 	cDoco <> QDU->QDU_DOCTO .or. cRvDoco <> QDU->QDU_RV
			oSection1:Finish()
			oSection1:Init()
			oReport:SkipLine(1) 
			oReport:ThinLine()
			oReport:PrintText(OemToAnsi(STR0010)+"  "+QDU->QDU_DOCTO +" /  "+QDU->QDU_RV,oReport:Row(),025) // "DOCUMENTO/REVISAO"
			oReport:SkipLine(1)	
			oReport:ThinLine()
		Endif
		cDoco   := QDU->QDU_DOCTO
		cRvDoco := QDU->QDU_RV
		oSection1:PrintLine()
		QDU->(dbSkip())
	EndDo
Enddo

//��������������������������������������������������������������Ŀ
//� Devolve as ordens originais dos arquivos                     �
//����������������������������������������������������������������
RetIndex("QDU")
Set Filter to


Return .T.



/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � QDOR100  � Autor � Eduardo de Souza      � Data � 24/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Pendencia de Devolucao de Revisao Anterior    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR100                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QDOR100R3()

Local cTitulo:= OemToAnsi(STR0001) //"Devolucao de Revisao Anterior"
Local cDesc1 := OemToAnsi(STR0002) //"Este programa ir� imprimir uma rela��o das pend�ncias de "
Local cDesc2 := OemToAnsi(STR0003) //"devolucao de revisao anterior de documentos, de acordo com "
Local cDesc3 := OemToAnsi(STR0004) //"os par�metros definidos pelo usu�rio."
Local cString:= "QDU"
Local wnrel  := "QDOR100"
Local Tamanho:= "M"

Private cPerg   := "QDR100"
Private aReturn := {STR0005,1,STR0006, 1, 2, 1, "",1} //"Zebrado"###"Administra��o"
Private nLastKey:= 0
Private INCLUI  := .F.	// Colocada para utilizar as funcoes

//��������������������������������������������������������������Ŀ
//� VerIfica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                               �
//� mv_par01	// De  Documento                                        �
//� mv_par02	// Ate Documento                                        �
//� mv_par03	// De  Revisao                                          �
//� mv_par04	// Ate Revisao                                          �
//� mv_par05	// De  Usuario                                          �
//� mv_par06	// Ate Usuario                                          �
//� mv_par07	// De  Departamento                                     �
//� mv_par08	// Ate Departamento                                     �
//����������������������������������������������������������������������
Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,ctitulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)

If nLastKey = 27
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
EndIf

RptStatus({|lEnd| QDOR100Imp(@lEnd,ctitulo,wnRel,tamanho)},ctitulo)

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QDOR100Imp� Autor � Eduardo de Souza      � Data � 24/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia para funcao que faz a impressao do relatorio.        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function QDOR100Imp(lEnd,ctitulo,wnRel,tamanho)

Local cCabec1  := " "
Local cCabec2  := " "
Local cbtxt    := SPACE(10)
Local cbcont   := 0
Local nTipo		:= GetMV("MV_COMP")
Local cIndex1  := CriaTrab(Nil,.F.)
Local cFilDep  := xFilial("QAD")
Local cFiltro  := " "
Local cSeek    := " "

Li   := 80
m_pag:= 1

cFiltro:= 'QDU->QDU_FILIAL == "'+xFilial("QDU")+'".And.'
cFiltro+= 'QDU->QDU_DOCTO >= "'+mv_par01+'" .And. QDU->QDU_DOCTO <= "'+mv_par02+'" .And. '
cFiltro+= 'QDU->QDU_RV >= "'+mv_par03+'" .And. QDU->QDU_RV <= "'+mv_par04+'" .And. '
cFiltro+= 'QDU->QDU_MAT >= "'+mv_par05+'" .And. QDU->QDU_MAT <= "'+mv_par06+'" .And. '
cFiltro+= 'QDU->QDU_DEPTO >= "'+mv_par07+'" .And. QDU->QDU_DEPTO <= "'+mv_par08+'"'

IndRegua("QDU",cIndex1,QDU->(IndexKey()),,cFiltro,OemToAnsi(STR0007))	//"Selecionando Registros.."

//          1         2         3         4         5         6         7         8         9        10        11        12        13
//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//USUARIO                              DEPTO                      TOTAL COPIAS  DEVOLVIDAS  NAO DEVOLVIDAS  DATA GERACAO  DATA BAIXA
cCabec1:= OemToAnsi(STR0008) //"USUARIO                              DEPTO                      TOTAL COPIAS  DEVOLVIDAS  NAO DEVOLVIDAS  DATA GERACAO  DATA BAIXA"

QDU->(DbSeek(xFilial("QDU")))
SetRegua(QDU->(LastRec())) // Total de Elementos da Regua

While QDU->(!Eof())
	cSeek:= QDU->QDU_DOCTO+QDU->QDU_RV
	If lEnd
		li++
		@ PROW()+1,001 PSAY OemToAnsi(STR0009) //"CANCELADO PELO OPERADOR"
		Exit
	EndIf
	If Li > 58
		Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
	EndIf
	@ Li,000 PSay OemToAnsi(STR0010)+" "+AllTrim(QDU->QDU_DOCTO)+"/"+QDU->QDU_RV // "DOCUMENTO/REVISAO"
	Li++
	@ Li,000 PSay __PrtFatLine()
	Li++
	While QDU->(!Eof()) .And. QDU->QDU_DOCTO+QDU->QDU_RV == cSeek
		IncRegua()
		If lEnd
			Li++
			@ PROW()+1,001 PSAY OemToAnsi(STR0009) //"CANCELADO PELO OPERADOR"
			Exit
		EndIf
		If Li > 58
			Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
		EndIf
		@ Li,000 PSay SubStr(QA_NUSR(QDU->QDU_FILMAT,QDU->QDU_MAT,.T.),1,30)
		If FWModeAccess("QAD")=="E"  //!Empty(xFilial("QAD"))
			cFilDep:= QDU->QDU_FILMAT
		EndIf
		@ Li,037 PSay QA_NDEPT(QDU->QDU_DEPTO,.T.,cFilDep)
		@ Li,072 PSay Transform(QDU->QDU_NCOP,"9999")
		@ Li,084 PSay Transform((QDU->QDU_NCOP - QDU->QDU_COPPEN),"9999")
		@ Li,100 PSay Transform(QDU->QDU_COPPEN,"9999")
		@ Li,108 PSay QDU->QDU_DTGERA
		@ Li,121 PSay QDU->QDU_DTBAIX
		QDU->(DbSkip())
		Li++
	EndDo
	@ Li,000 Psay __PrtThinLine()
	Li+=2
EndDo

If Li <> 80
	Roda(cbcont,cbtxt,tamanho)
EndIf

//��������������������������������������������������������������Ŀ
//� Devolve as ordens originais dos arquivos                     �
//����������������������������������������������������������������
RetIndex("QDU")
Set Filter to

//��������������������������������������������������������������Ŀ
//� Apaga indices de trabalho                                    �
//����������������������������������������������������������������
cIndex1 += OrDbagExt()
Delete File &(cIndex1)

Set Device To Screen

If aReturn[5] = 1
	Set Printer TO
	DbCommitAll()
	ourspool(wnrel)
EndIf
MS_FLUSH()

Return .T.