#INCLUDE "QDOR090.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Report.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QDOR090  � Autor � Leandro S. Sabino     � Data � 25/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Documentos vencidos e a vencer                ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR090	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QDOR090()
Local oReport
Private cPerg	:= "QDR090"

If TRepInUse()
	Pergunte(cPerg,.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	Return QDOR090R3() //Executa vers�o anterior do fonte
EndIf           

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 25.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR090                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport                                             
Local oSection1 
Local cFilDep  	 := xFilial("QAD")

DEFINE REPORT oReport NAME "QDOR090" TITLE OemToAnsi(STR0001) PARAMETER "QDR090" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (OemToAnsi(STR0002)+OemToAnsi(STR0003))
//"LISTA DE DOCUMENTOS VENCIDOS E A VENCER"##"Este programa ira imprimir uma rela�ao de Documentos Vencidos e A Vencer"##
oReport:SetLandscape(.T.)

DEFINE SECTION oSection1 OF oReport TABLES "QDH" TITLE STR0023 // "Documentos"
DEFINE CELL NAME "QDH_DOCTO"  OF oSection1 ALIAS "QDH" AUTO SIZE 
DEFINE CELL NAME "QDH_RV"     OF oSection1 ALIAS "QDH" AUTO SIZE  
DEFINE CELL NAME "QDH_TITULO" OF oSection1 ALIAS "QDH" AUTO SIZE 
DEFINE CELL NAME "QDH_DTLIM"  OF oSection1 ALIAS "QDH" 
DEFINE CELL NAME "QDH_DTLIM"  OF oSection1 ALIAS "QDH" TITLE OemToAnsi(STR0022)     SIZE 17 BLOCK{|| QDR090DI() } //"Dias"
DEFINE CELL NAME "cUsu"       OF oSection1 ALIAS "QDH" TITLE OemToAnsi(STR0021)     SIZE 25 BLOCK{|| AllTrim(QA_NUSR(QDH->QDH_FILMAT,QDH->QDH_MAT,.T.,"A"))} 
DEFINE CELL NAME "QDH_DEPTOE" OF oSection1 ALIAS "QDH" SIZE 25 BLOCK{|| AllTrim(QA_NDEPT(QDH->QDH_DEPTOE,.T.,cFilDep))}  

Return oReport



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 25.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)  	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR090                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintReport( oReport )
Local oSection1  := oReport:Section(1)
Local cFiltro 

MakeAdvplExpr("QDR090")

DbSelectarea("QDH")
DbSetOrder(1)

cFiltro:= 'QDH->QDH_FILIAL=="'  +xFilial("QDH")+'" .And. '
cFiltro:= 'QDH->QDH_OBSOL <> "S" .And. QDH->QDH_CANCEL <> "S" .And. !Empty(QDH->QDH_DTLIM) .And. '
cFiltro+= 'QDH->QDH_DOCTO >= "' +mv_par01+'" .And. QDH->QDH_DOCTO <= "' +mv_par02+'".And. '
cFiltro+= 'QDH->QDH_RV >= "' +mv_par03+'" .And. QDH->QDH_RV <= "'    +mv_par04+'".And. '
cFiltro+= 'DTOS(QDH->QDH_DTLIM) >= "'+DTOS(mv_par05)+'" .And. DTOS(QDH->QDH_DTLIM) <= "'+DTOS(mv_par06)+'".And. '
cFiltro+= 'QDH->QDH_FILMAT >= "' +mv_par11+'" .And. QDH->QDH_FILMAT <= "' +mv_par08+'".And. '
cFiltro+= 'QDH->QDH_MAT >= "' +mv_par07+'" .And. QDH->QDH_MAT <= "' +mv_par08+'".And. '
cFiltro+= 'QDH->QDH_DEPTOE >= "' +mv_par09+'" .And. QDH->QDH_DEPTOE <= "' +mv_par10+'"'

oSection1:SetFilter(cFiltro)

oSection1:Print()

Return



/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � QDOR090  � Autor � Eduardo de Souza      � Data � 23/11/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Documentos vencidos e a vencer                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR090                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Eduardo S.  �28/03/02� META � Retirada a funcao QA_AjustSX1()          ���
���Eduardo S.  �21/08/02�059354� Acertado para listar corretamente datas  ���
���            �        �      � com 4 digitos.                           ���
���Eduardo S   |13/12/02� ---- � Incluido a pergunta 11 e 12 permitindo   ���
���            �        �      � filtrar por filial de departamento.      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QDOR090R3()

Local cTitulo   := OemToAnsi(STR0001) // "LISTA DE DOCUMENTOS VENCIDOS E A VENCER"
Local cDesc1    := OemToAnsi(STR0002) // "Este programa ira imprimir uma rela�ao de Documentos Vencidos e A Vencer"
Local cDesc2    := OemToAnsi(STR0003) // "de acordo com os par�metros definidos pelo usu�rio."
Local cString   := "QDH"
Local wnrel     := "QDOR090"
Local Tamanho   := "G"

Private cPerg   := "QDR090"
Private aReturn := {STR0004,1,STR0005,1,2,1,"",1} // "Zebrado" ### "Administra�ao"##"de acordo com os par�metros definidos pelo usu�rio."
Private nLastKey:= 0
Private INCLUI  := .F.	// Colocada para utilizar as funcoes

//��������������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                                 �
//����������������������������������������������������������������������
//��������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                               �
//� mv_par01	// De Documento                                        �
//� mv_par02	// Ate Documento                                       �
//� mv_par03	// De Revisao                                          �
//� mv_par04	// Ate Revisao                                         �
//� mv_par05	// De Data Validade                                    �
//� mv_par06	// Ate Data Validade                                   �
//� mv_par07	// De Usuario Digitador                                �
//� mv_par08	// Ate Usuario Digitador                               �
//� mv_par09	// De Departamento Digitador                           �
//� mv_par10	// Ate Departamento Digitador                          �
//� mv_par11	// De Filial Usuario Digitador                         �
//� mv_par12	// Ate Filial Usuario Digitador                        �
//����������������������������������������������������������������������

Pergunte(cPerg,.F.)

wnrel := AllTrim(SetPrint(cString,wnrel,cPerg,ctitulo,cDesc1,cDesc2,"",.F.,,.F.,Tamanho))

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| QDOR090Imp(@lEnd,ctitulo,wnRel,tamanho)},ctitulo)

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �QDOR090Imp� Autor � Eduardo de Souza      � Data � 23/11/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Envia para funcao que faz a impressao do relatorio.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QDOR090Imp(ExpL1,ExpC1,ExpC2,ExpC3)                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR090                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function QDOR090Imp(lEnd,ctitulo,wnRel,tamanho)

Local cCabec1  := ""
Local cCabec2  := ""
Local cbtxt    := SPACE(10)
Local nTipo	   := GetMV("MV_COMP")
Local cbcont   := 0
Local cIndex1  := CriaTrab(Nil,.F.)
Local cFiltro  := ""
Local cKey     := ""
Local cDias    := ""
Local cValidade:= ""
Local cFilDep  := xFilial("QAD")

DbSelectarea("QDH")
DbSetOrder(1)

cFiltro:= 'QDH->QDH_FILIAL=="'  +xFilial("QDH")+'" .And. '
cFiltro:= 'QDH->QDH_OBSOL <> "S" .And. QDH->QDH_CANCEL <> "S" .And. !Empty(QDH->QDH_DTLIM) .And. '
cFiltro+= 'QDH->QDH_DOCTO >= "' +mv_par01+'" .And. QDH->QDH_DOCTO <= "' +mv_par02+'".And. '
cFiltro+= 'QDH->QDH_RV >= "' +mv_par03+'" .And. QDH->QDH_RV <= "'    +mv_par04+'".And. '
cFiltro+= 'DTOS(QDH->QDH_DTLIM) >= "'+DTOS(mv_par05)+'" .And. DTOS(QDH->QDH_DTLIM) <= "'+DTOS(mv_par06)+'".And. '
cFiltro+= 'QDH->QDH_FILMAT >= "' +mv_par11+'" .And. QDH->QDH_FILMAT <= "' +mv_par08+'".And. '
cFiltro+= 'QDH->QDH_MAT >= "' +mv_par07+'" .And. QDH->QDH_MAT <= "' +mv_par08+'".And. '
cFiltro+= 'QDH->QDH_DEPTOE >= "' +mv_par09+'" .And. QDH->QDH_DEPTOE <= "' +mv_par10+'"'

cKey:= 'QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+DTOS(QDH->QDH_DTLIM)'

IndRegua("QDH",cIndex1,cKey,,cFiltro,OemToAnsi(STR0016)) // "Selecionando Registros.."

Li     := 80
m_Pag  := 1

cCabec1:= OemToAnsi(STR0017) // "DT TRANSF. RESPONSAVEL        DEPTO                     MOTIVO                          TIPO"                          

QDH->(DbSeek(xFilial("QDH")))
SetRegua(QDH->(RecCount())) // Total de Elementos da Regua

While QDH->(!Eof())
	If FWModeAccess("QAD")=="E" //!Empty(cFilDep)
		cFilDep:= QDH->QDH_FILMAT
	EndIf
	If lEnd
		Li++
		@ PROW()+1,001 PSAY OemToAnsi(STR0018) // "CANCELADO PELO OPERADOR"
		Exit
	EndIf
	If Li > 60
		Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
	EndIf

    @ Li,000 PSay QDH->QDH_DOCTO
    @ Li,018 PSay QDH->QDH_RV
    @ Li,022 PSay Left(QDH->QDH_TITULO, 131)
	@ Li,154 PSay DToC(QDH_DTLIM)

	If (QDH->QDH_DTLIM - dDatabase) > 0
		cDias:= StrZero((QDH->QDH_DTLIM - dDatabase),4)
		cValidade:=	OemToAnsi(STR0019) // "A Vencer"
	Else
		cDias:= StrZero((dDataBase - QDH->QDH_DTLIM),4)
		cValidade:=	OemToAnsi(STR0020) // "Vencido"
	EndIf
   
    
	@ Li,165 PSay cDias
	@ Li,170 PSay cValidade
	@ Li,183 PSay QA_NUSR(QDH->QDH_FILMAT,QDH->QDH_MAT,.T.,"A") // Apelido
	@ Li,198 PSay AllTrim(QA_NDEPT(QDH->QDH_DEPTOE,.T.,cFilDep))
    Li++
	QDH->(DbSkip())


EndDo

If Li != 80
	Roda(cbcont,cbtxt,tamanho)
EndIf

RetIndex("QDH")
Set Filter to

//��������������������������������������������������������������Ŀ
//� Apaga indice de trabalho                                     �
//����������������������������������������������������������������
cIndex1 += OrdBagExt()
Delete File &(cIndex1)

Set Device To Screen

If aReturn[5] = 1
	Set Printer TO 
	DbCommitAll()
	Ourspool(wnrel)
Endif
MS_FLUSH()

Return .T.


Static Function QDR090DI()

If (QDH->QDH_DTLIM - dDatabase) > 0
	cDias:= (StrZero((QDH->QDH_DTLIM - dDatabase),4))+" "+ OemToAnsi(STR0019)
Else
	cDias:= (StrZero((dDataBase - QDH->QDH_DTLIM),4))+" "+ OemToAnsi(STR0020)
EndIf

return cDias

