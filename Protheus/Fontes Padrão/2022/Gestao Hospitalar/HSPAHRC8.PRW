#INCLUDE "HSPAHRC8.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Report.ch"        

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � HSPAHRC8 � Autor � Patricia              � Data � 05/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio Conferencia de Lotes                             ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � Convertido para relatorios personalizaveis                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Gestao Hospitalar                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function HSPAHRC8()
 Local oReport
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPRC8", .F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 Else  
  HSPAHRC8R3()  
 EndIF    
 
Return(Nil)
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �REPORTDEF � Autor � L. Gustavo Caloi      � Data � 05/07/06 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()
 Local oReport 
 Local oSection1
 Local oCell 
 Local oTotaliz1

 oReport := TReport():New("HSPAHRC8", STR0003, "HSPRC8", {|oReport| RC8IMP(oReport)}, STR0001 + " " + STR0002) //"CONF�RENCIA DE LOTES DO SPP" //"Este programa tem como objetivo imprimir relat�rio " ### "de acordo com os par�metros informados pelo usu�rio."

 oReport:SetLandScape()

 oSection1 := TRSection():New(oReport, "Setor", {"QRYGSA"})        
 oSection1:SetHeaderBreak(.T.)    //Indica se cabecalho da secao sera impresso em cada quebra
 oSection1:SetHeaderPage(.T.)     //Indica que cabecalho da secao sera impresso no topo da pagina
 oSection1:SetHeaderSection(.T.)  //Indica se cabecalho da secao sera impresso (padrao)   
 oSection1:SetPageBreak(.F.)      //Indica quebra de pagina no final da secao
 oSection1:SetNoFilter({"QRYGSA"})     
 oCell := TRCell():New(oSection1, "GSA_CODLOC", "QRYGSA", "SETOR:"     ,,  2)
 oCell := TRCell():New(oSection1, "GCS_NOMLOC", "QRYGSA", "Descricao ",, 40) 

 oSection2 := TRSection():New(oSection1, "Agenda", {"QRYGSA"})        
 oSection2:SetHeaderBreak(.T.)    //Indica se cabecalho da secao sera impresso em cada quebra
 oSection2:SetHeaderPage(.T.)     //Indica que cabecalho da secao sera impresso no topo da pagina
 oSection2:SetHeaderSection(.T.)  //Indica se cabecalho da secao sera impresso (padrao)   
 oSection2:SetPageBreak(.F.)      //Indica quebra de pagina no final da secao
 oSection2:SetNoFilter({"QRYGSA"})     
 oCell := TRCell():New(oSection2, "GSA_LOTE", "QRYGSA", "LOTE:") 
 oCell := TRCell():New(oSection2, "GSA_DATSOL", "QRYGSA", STR0015     ,, 7)   //"Data Solic."
 oCell := TRCell():New(oSection2, "GSA_HORSOL", "QRYGSA", STR0016     ,, 5)   //"Hora"
 oCell := TRCell():New(oSection2, "GSA_CODEND", "QRYGSA", STR0017     ,,13)   //"Endere�o"
 oCell := TRCell():New(oSection2, "GSD_DESEND", "QRYGSA", "Descricao" ,,20)
 oCell := TRCell():New(oSection2, "GSA_REGGER", "QRYGSA", "PRONTUARIO",, 7) 
 oCell := TRCell():New(oSection2, "GSA_NOMPAC", "QRYGSA", "PACIENTE"  ,,25)    
 oCell := TRCell():New(oSection2, "RA_NOME"   , "QRYGSA", STR0019     ,,30)   //"M�dico"
 oCell := TRCell():New(oSection2, "GA7_DESC"  , "QRYGSA", STR0020     ,,25)   //"Procedimento"
 oCell := TRCell():New(oSection2, "GSA_NOMSOL", "QRYGSA", STR0021     ,,15)   //"Usu�rio Solicit"
 oCell := TRCell():New(oSection2, "GSA_DATENT", "QRYGSA", STR0022     ,, 7)   //"Data Sa�da"
 oCell := TRCell():New(oSection2, "GSA_HORENT", "QRYGSA", STR0016     ,, 5)   //"Hora"
 oCell := TRCell():New(oSection2, "GSA_NOMENT", "QRYGSA", STR0023     ,,13)   //"Usu�rio Sa�da"

 oSection3 := TRSection():New(oSection2, "Motivo Sol.", {"QRYGSA"})        
 oSection3:SetHeaderBreak(.T.)    //Indica se cabecalho da secao sera impresso em cada quebra
 oSection3:SetHeaderPage(.T.)     //Indica que cabecalho da secao sera impresso no topo da pagina
 oSection3:SetHeaderSection(.T.)  //Indica se cabecalho da secao sera impresso (padrao)   
 oSection3:SetPageBreak(.F.)      //Indica quebra de pagina no final da secao
 oSection3:SetNoFilter({"QRYGSA"})      

 oCell := TRCell():New(oSection3, "GSC_DESMOT", "QRYGSA", STR0024,,30) //"Motivo Solicita��o"
 oCell := TRCell():New(oSection3, "GSA_OBSERV", "QRYGSA", STR0025,,30) //"Obs Solicita��o"
 oCell := TRCell():New(oSection3, "GSA_DATRET", "QRYGSA", STR0026,, 7) //"Data Retor."
 oCell := TRCell():New(oSection3, "GSA_HORRET", "QRYGSA", STR0016,, 5) //"Hora"
 oCell := TRCell():New(oSection3, "GSA_NOMRET", "QRYGSA", STR0027,,13) //"Usu�rio Retor."
 
 oSection3:SetParentRecno()

 TRFunction():New(oSection2:Cell("GSA_NOMPAC")	,/* cID */,"COUNT",,/*cTitle*/,"9999",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,oSection1)

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RC8Imp   � Autor � L. Gustavo Caloi      � Data � 05/07/06 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function RC8IMP(oReport)
 Local cCond     := "%%",;
       cCond1    := "%%"
 
 If !Empty(MV_PAR03)
  cCond := "%GSA.GSA_LOTE = '" + MV_PAR03 + "'%"
 Else
  cCond := "%GSA.GSA_LOTE <> '" + SPACE(LEN(GSA->GSA_LOTE)) + "' %"
 EndIf

 If MV_PAR04 == 1                               	
  cCond1 := "%GSA.GSA_OK IN ('0')%"
 Else
  cCond1 := "%GSA.GSA_OK IN (' ','0', '1', '2')%"
 EndIf

 MakeSqlExp("HSPRC8")
 oReport:Section(1):BeginQuery()

BeginSql Alias "QRYGSA"
 SELECT GSA_DATSOL, GSA_HORSOL, GSA_CODEND, GSD_DESEND, GSA_NOMPAC, GSA_REGGER, RA_NOME,
 GA7_DESC, GSA_NOMSOL, GSA_DATENT, GSA_HORENT, GSA_NOMENT, GSC_DESMOT, GSA_OBSERV,
 GSA_DATRET, GSA_HORRET, GSA_NOMRET, GSA_LOTE, GSA_OK, GSA_CODLOC, GCS_NOMLOC
 FROM %table:GSA% GSA
 JOIN %table:GSD% GSD ON GSD_CODEND = GSA_CODEND AND GSD_FILIAL = %xFilial:GSD% AND GSD.%NotDel%
 LEFT JOIN %table:SRA% SRA ON RA_CODIGO = GSA_CODCRM AND RA_FILIAL = %xFilial:SRA% AND SRA.%NotDel%
 LEFT JOIN %table:GA7% GA7 ON GA7_CODPRO = GSA_CODPRO AND GA7_FILIAL = %xFilial:GA7% AND GA7.%NotDel%
 JOIN %table:GSC% GSC ON GSC_CODMOT = GSA_CODMOT AND GSC_FILIAL = %xFilial:GSC% AND GSC.%NotDel%
 JOIN %table:GCS% GCS ON GCS_CODLOC = GSA_CODLOC AND GCS_FILIAL = %xFilial:GCS% AND GCS.%NotDel%
 WHERE GSA.GSA_FILIAL = %xFilial:GSA% AND GSA.%NotDel%
       AND GSA.GSA_DATSOL BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)% 
       AND %Exp:cCond%
       AND %Exp:cCond1%
 ORDER BY GSA_FILIAL, GSA_CODLOC, GSA_LOTE
EndSql
 oReport:Section(1):EndQuery()

 oReport:Section(1):Section(1):SetParentQuery()
 oReport:Section(1):Section(1):SetParentFilter({|L| QRYGSA->GSA_CODLOC == L}, {|| QRYGSA->GSA_CODLOC})
                                                                                                        
 oReport:Section(1):Section(1):Section(1):SetParentQuery()
 oReport:Section(1):Section(1):Section(1):SetParentFilter({|L| QRYGSA->GSA_CODLOC == L}, {|| QRYGSA->GSA_CODLOC})

 oReport:SetMeter(QRYGSA->(LastRec()))
 oReport:Section(1):Print() // processa as informacoes da tabela principal
Return(Nil) 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHRC8R3� Autor � MARCELO JOSE       � Data �  22/03/05   ���
�������������������������������������������������������������������������͹��
���Descricao � CONFERENCIA DE LOTES DO SPP                                ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHRC8R3()

Local cDesc1  := STR0001 //"Este programa tem como objetivo imprimir relat�rio "
Local cDesc2  := STR0002 //"de acordo com os par�metros informados pelo usu�rio."
Local cDesc3  := ""
Local cPict   := STR0003 //"CONF�RENCIA DE LOTES DO SPP"
Local titulo  := STR0003 //"CONF�RENCIA DE LOTES DO SPP"
Local nLin    := 80
Local Cabec1  := ""
Local Cabec2  := ""
Local imprime := .T.
Local aOrd    := {}

Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 220
Private tamanho     := "G"
Private nomeprog    := "HSPAHRC8" 
Private nTipo       := 15
Private aReturn     := {STR0004, 1, STR0005, 2, 2, 1, "", 1} //"Zebrado"###"Administra��o"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "HSPAHRC8"
Private cString     := "GSA"
Private cPerg       := "HSPRC8"
Private aVetor      := {}
Private nMaxLin     := 0 // quantidade maxima de linhas p/ impressao
Private cSQL        := ""  
Private dData_De    := ""
Private dData_Ate   := "" 
Private cLote       := ""
Private nTipRel     := 0
Private cCodImp     := ""

If !Pergunte(cPerg, .T.)
	Return(Nil)
EndIf  

dData_De  := MV_PAR01
dData_Ate := MV_PAR02
cLote     := MV_PAR03
nTipRel   := MV_PAR04                                  
cCodImp   := MV_PAR05

nMaxLin := HS_MaxLin(cCodImp)
nLin    := nMaxLin * 2

wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .F.)

If nLastKey == 27
	Return(Nil)
EndIf

SetDefault(aReturn, cString)

If nLastKey == 27
	Return(Nil)
EndIf

nTipo := If(aReturn[4] == 1, 15, 18)
RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin)}, Titulo)

Return(Nil)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor �MARCELO JOSE        � Data �  22/03/05   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa Principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(Cabec1, Cabec2, Titulo, nLin)   

Local cQueLote  := ""
Local cQueSetor := ""
Local nTotSetor := 0

 /*         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21       22
  0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789*/

Cabec1 := STR0006 //"Data Solic.  Hora   Endere�o                           Paciente                                     M�dico                          Procedimento                          Usu�rio Solicit  Data Sa�da   Hora   Usu�rio Sa�da" 

Cabec2 := STR0007 //"                                                                                                    Motivo Solicita��o              Obs Solicita��o                                        Data Retor.  Hora   Usu�rio Reto."

DbSelectArea("GSA")

cSQL := "SELECT GSA.GSA_DATSOL, GSA.GSA_HORSOL, GSA.GSA_CODEND, GSD.GSD_DESEND, GSA.GSA_NOMPAC, GSA.GSA_REGGER, SRA.RA_NOME,"
cSQL += " GA7.GA7_DESC, GSA.GSA_NOMSOL, GSA.GSA_DATENT, GSA.GSA_HORENT, GSA.GSA_NOMENT, GSC.GSC_DESMOT, GSA.GSA_OBSERV,"
cSQL += " GSA.GSA_DATRET, GSA.GSA_HORRET, GSA.GSA_NOMRET, GSA.GSA_LOTE, GSA.GSA_OK, GSA.GSA_CODLOC, GCS.GCS_NOMLOC"
cSQL += " FROM " + RetSqlName("GSA") + " GSA"
cSQL += " JOIN " + RetSqlName("GSD") + " GSD ON GSD.GSD_FILIAL = '" + xFilial("GSD") + "' AND GSD.D_E_L_E_T_ <> '*' AND GSD.GSD_CODEND = GSA.GSA_CODEND"
cSQL += " LEFT JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO = GSA.GSA_CODCRM"
cSQL += " LEFT JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GSA.GSA_CODPRO"
cSQL += " JOIN " + RetSqlName("GSC") + " GSC ON GSC.GSC_FILIAL = '" + xFilial("GSC") + "' AND GSC.D_E_L_E_T_ <> '*' AND GSC.GSC_CODMOT = GSA.GSA_CODMOT"
cSQL += " JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GSA.GSA_CODLOC"
cSQL += " WHERE GSA.GSA_FILIAL = '" + xFilial("GSA") + "' AND GSA.D_E_L_E_T_ <> '*'"
cSQL += " AND GSA.GSA_DATSOL BETWEEN '" + DTOS(dData_De) + "' AND '" + DTOS(dData_Ate) + "'"

If !Empty(cLote)
 cSQL += " AND GSA.GSA_LOTE = '" + cLote + "'"
Else
 cSQL += " AND GSA.GSA_LOTE <> '" + SPACE(LEN(GSA->GSA_LOTE)) + "' "
EndIf

If nTipRel == 1
 cSQL += " AND GSA.GSA_OK = '0'"
EndIf

cSQL += " ORDER BY GSA_FILIAL, GSA_CODLOC, GSA_LOTE" 

cSQL := ChangeQuery(cSQL)
TCQUERY cSQL NEW ALIAS "QRY"

DbSelectArea("QRY")
DbGoTop()

SetRegua(100)

If Eof()
	HS_MsgInf(STR0008, STR0009, STR0010) //"Nao h� dados a serem impressos para a sele�o efetuada!"###"Aten��o"###"Verifique a sele��o" 
EndIf  

While !Eof()

 IncRegua()
 
 If lAbortPrint
	 @nLin, 000 PSAY STR0011 //"*** CANCELADO PELO OPERADOR ***"
	 Exit
 EndIf   
 
 If nLin > nMaxLin
		Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
		nLin := 9
	EndIf

 If QRY->GSA_CODLOC <> cQueSetor 
  If !Empty(cQueSetor) 
   nLin := nLin + 2
   @nLin, 000 PSAY STR0014 + STR(nTotSetor)  //"==> Total do Setor: "
   nLin := nLin + 2
  EndIf 
  cQueLote  := ""
  cQueSetor := QRY->GSA_CODLOC
  nTotSetor := 0
 EndIf 
 
 If QRY->GSA_LOTE <> cQueLote
  nLin++
  @nLin, 000 PSAY STR0012 + QRY->GSA_LOTE  //"Lote......: "
  nLin++
  @nLin, 000 PSAY STR0013 + QRY->GSA_CODLOC + " " + QRY->GCS_NOMLOC  //"Setor.....: " 
  cQueLote := QRY->GSA_LOTE  
 EndIf 
 
 nLin++
 @nLin, 000 PSAY IIF(Empty(QRY->GSA_DATSOL), " ", HS_DTOC(STOD(QRY->GSA_DATSOL), 1))
 @nLin, 013 PSAY QRY->GSA_HORSOL  
 @nLin, 020 PSAY QRY->GSA_CODEND + " " + SUBSTR(QRY->GSD_DESEND, 1, 20)
 @nLin, 055 PSAY QRY->GSA_REGGER + " " + SUBSTR(QRY->GSA_NOMPAC, 1, 36)
 @nLin, 100 PSAY SUBSTR(QRY->RA_NOME, 1, 30)
 @nLin, 132 PSAY SUBSTR(QRY->GA7_DESC, 1, 36)
 @nLin, 170 PSAY SUBSTR(QRY->GSA_NOMSOL, 1, 15) 
 @nLin, 187 PSAY IIF(Empty(QRY->GSA_DATENT), " ", HS_DTOC(STOD(QRY->GSA_DATENT), 1))
 @nLin, 200 PSAY QRY->GSA_HORENT
 @nLin, 207 PSAY SUBSTR(QRY->GSA_NOMENT, 1, 13)
 nLin++
 @nLin, 100 PSAY SUBSTR(QRY->GSC_DESMOT, 1, 30)
 @nLin, 132 PSAY QRY->GSA_OBSERV
 @nLin, 187 PSAY IIF(Empty(QRY->GSA_DATRET), " ", HS_DTOC(STOD(QRY->GSA_DATRET), 1))
 @nLin, 200 PSAY QRY->GSA_HORRET
 @nLin, 207 PSAY SUBSTR(QRY->GSA_NOMRET, 1, 13)

 nTotSetor++
 
 DbSkip()
 
EndDo

nLin := nLin + 2
@nLin, 000 PSAY STR0014 + STR(nTotSetor)  //"==> Total do Setor: " 

DbCloseArea()

SET DEVICE TO SCREEN
 If aReturn[5] == 1
 	DbCommitAll()
	 SET PRINTER TO
	 OurSpool(wnrel)
 EndIf

 MS_FLUSH()

Return(Nil)