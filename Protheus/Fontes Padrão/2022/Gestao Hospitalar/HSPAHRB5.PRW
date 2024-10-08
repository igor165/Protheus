#INCLUDE "protheus.ch"
#INCLUDE "HSPAHRB5.ch" 
#INCLUDE "TopConn.ch"  

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � HSPAHRB5 � Autor � MARCELO JOSE          � Data � 05/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Motivos de Solicitacoes                       ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � Convertido para relatorios personalizaveis                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAHSP                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function HSPAHRB5()
 Local oReport
 
 If FindFunction("TRepInUse") .And. TRepInUse() // Se ja tem rpo para relatorios personalizaveis.
 	pergunte("HSPRB5",.F.)
  oReport := ReportDef() // Chama a funcao de montagem do relatorio que retornara um objeto de impressao.
  // Metodo que apresenta a tela de impressao a partir do objeto retornado(...instanciado) na funcao ReportDef().
  // para o usuario configurar o relatorio...
  oReport:PrintDialog()  
 ELSE  // Se ainda nao tem rpo para relatorios personalizaveis entao executa o relatorio antigo renomeado...
  HSPAHRB5R3()  
 EndIF    
 
Return( Nil )
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �REPORTDEF � Autor � MARCELO JOSE          � Data � 05/06/06 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/

Static Function ReportDef()
 Local oReport 
 Local oSection1 
 Local oCell
 Local oTotaliz
 
//��������������������������������������������������������������������������������������������������������������Ŀ
//� TReport:  Classe que instancia o componente de impressao                                                     �
//� Parametros para o  construtor inicializar as variaveis de instancia :                                        �
//�  (/*cNome Rel*/,/*cTit Rel*/,/*cPerg*/,/*{|| code-block de impres}*/,/*cdescricao*/)                                     �
//����������������������������������������������������������������������������������������������������������������


 oReport := TReport():New("HSPAHRB5","Motivos de Solicita��es","HSPRB5",{|oReport| RB5IMP(oReport)},"Impress�o dos motivos de solicita��o do prontu�rio ao SAME.")
//��������������������������������������������������������������������������������������������������������������Ŀ
//� TRSection:  Classe que instancia secoes(lay-out) do componente de impressao                                  �
//� Parametros para o  construtor inicializar as variaveis de instancia :                                        �  
//� ( /*oReport*/, /*cDescri*/,/*aTab*/,/*aOrd Rel*,/,.F./*lCpo SX3*,/,.F./*lCpo SIX*/)                          �
//����������������������������������������������������������������������������������������������������������������

 
 oSection1 := TRSection():New(oReport,OemToAnsi("Descri��o dos Motivos de Solicita��es"),{"GSC"})

 //��������������������������������������������������������������������������������������������������������������Ŀ
 //� TRCell:  Classe que instancia celulas das secoes (campos do lay-out de impressao)                            �
 //� Parametros para o construtor inicializar as variaveis de instancia :                                         �
 //� ( /*oSection*/,/*cCpoSX3*/,/*cTabSX2*/, /*cX3Tit*/,/*cX3Pict*/,/*cX3Tam*/,.F./*lPixel*/,/*{|| bCb impres}*/ )�
 //����������������������������������������������������������������������������������������������������������������

 oCell := TRCell():New(oSection1,"GSC_CODMOT","GSC")
 oCell := TRCell():New(oSection1,"GSC_DESMOT","GSC")

 //�������������������������������������������������������������������������������������������������������������������������������������Ŀ
 //� TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                    �
 //� Parametros para o construtor inicializar as variaveis de instancia :                                                                �
 //� (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/) �
 //���������������������������������������������������������������������������������������������������������������������������������������

Return( oReport )

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RB5Imp   � Autor � MARCELO JOSE          � Data � 05/06/06 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/

Static Function RB5IMP(oReport)
 Local oSection1 := oReport:Section(1)
 Local cOrder    := ""  

 If MV_PAR03 == 1
 	cOrder := "%GSC_CODMOT%"
 Else 
 	cOrder := "%GSC_DESMOT%"
 EndIf	

 //-- Transforma parametros Range em expressao SQL
 MakeSqlExpr(oReport:uParam)                        

 oReport:Section(1):BeginQuery()

	BeginSql Alias "GSC"
	SELECT GSC_CODMOT, GSC_DESMOT
	FROM %table:GSC% GSC
	WHERE GSC_FILIAL = %xFilial:GSC% 	AND GSC.%NotDel%
		AND GSC_CODMOT >= %Exp:mv_par01%
		AND GSC_CODMOT <= %Exp:mv_par02%
	ORDER BY %Exp:cOrder%
	EndSql

 oReport:Section(1):EndQuery()
 oReport:SetMeter(GSC->(LastRec()))
 oSection1:Print() // processa as informacoes da tabela principal

Return( NIL )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHRB5R3� Autor � PAULO JOSE         � Data �  20/10/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Relatorio de Motivos de Solicitacoes                       ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function HSPAHRB5R3()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cDesc1  := STR0004 //"Este programa tem como objetivo imprimir relat�rio "
Local cDesc2  := STR0005 //"de acordo com os par�metros informados pelo usu�rio."
Local cDesc3  := STR0006 //"Relat�rio de Motivos de Solicita��o"
Local cPict   := ""
Local titulo  := STR0003 //"Relat�rio de Motivos de Solicita��o"
Local nLin    := 80
Local Cabec1  := STR0001 //"Codigo              Descricao"
Local Cabec2  := " "
Local imprime := .T.
Local aOrd    := {}  

Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 80
Private tamanho     := "P"
Private nomeprog    := "HSPAHRB5" // nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := {STR0007, 1, STR0008, 2, 2, 1, "", 1} //"Zebrado"###""Administra��o""
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "HSPAHRB5" // nome do arquivo usado para impressao em disco
Private cCod_De     := ""
Private cCod_Ate    := ""
Private cOrdem      := ""
Private cCod_Imp    := ""
Private nMaxLin     := 0 // quantidade maxima de linhas p/ impressao
Private cString     := "GSC"

If !Pergunte("HSPRB5", .T.)
 Return
EndIf

cCod_De  := MV_PAR01
cCod_Ate := MV_PAR02 
cCod_Imp := MV_PAR04          
  
nMaxLin := HS_MaxLin(cCod_Imp)

wnrel := SetPrint(cString, NomeProg, "HSPRB5", @titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho,, .T.)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn, cString)

If nLastKey == 27
 Return
EndIf

nTipo := If(aReturn[4] == 1, 15, 18)

//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������

RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin)}, Titulo)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �RUNREPORT � Autor � AP6 IDE            � Data �  20/10/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function RunReport(Cabec1, Cabec2, Titulo, nLin) 

Local cSQL := ""

DbSelectArea("GSC")
DbSetOrder(1) // GSC_FILIAL + GSC_CODMOT 

cSQL := "SELECT GSC.GSC_CODMOT, GSC.GSC_DESMOT"
cSQL += " FROM " + RetSQLName("GSC") + " GSC"
cSQL += " WHERE GSC.GSC_FILIAL = '" + xFilial("GSC") + "' AND GSC.D_E_L_E_T_ <> '*'"
cSQL += " AND GSC.GSC_CODMOT BETWEEN '" + cCod_De + "' AND '" + cCod_Ate + "'"

If MV_PAR03 ==1
 cSQL += " ORDER BY GSC.GSC_FILIAL, GSC.GSC_CODMOT"
Else
 cSQL += " ORDER BY GSC.GSC_FILIAL, GSC.GSC_DESMOT"
EndIf

cSQL := ChangeQuery(cSQL)
TCQUERY cSQL NEW ALIAS "QRY"

DbSelectArea("QRY")
DbGoTop() 
SetRegua(100)

While !Eof()

IncRegua()

If lAbortPrint
 @nLin, 000 PSAY STR0002 //"*** CANCELADO PELO OPERADOR ***"
 Exit
EndIf

If nLin > nMaxLin // Salto de Pagina.
	Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
	nLin := 9
EndIf

@nLin, 000 PSAY QRY->GSC_CODMOT
@nLin, 020 PSAY QRY->GSC_DESMOT
nLin++

DbSkip()

EndDo

DbCloseArea()

//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������

SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������

If aReturn[5] == 1 
 DbCommitAll()
 SET PRINTER TO
 OurSpool(wnrel)
EndIf

MS_FLUSH()

Return()