#INCLUDE "HSPAHRC1.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHRC1  � Autor � ANTONIO CARLOS     � Data �  18/08/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Relatorio Atendimentos Cancelados - Periodo                ���
�������������������������������������������������������������������������͹��
���Obs:      � Convertido para relatorios personalizaveis                 ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHRC1()

Local oReport
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPRC1",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE 
  HSPAHRC1R3()  
 EndIF    
Return( Nil )     


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �REPORTDEF � Autor � Antonio Carlos        � Data � 18/08/06 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2
 Local oCell
 Local oBreak1
 Local oTotaliz1, oTotaliz2

 oReport := TReport():New("HSPAHRC1",STR0003,"HSPRC1",{|oReport| RC1IMP(oReport)}, STR0001 + STR0002 + STR0003) 
 //###"Extrato Geral Atendimento"### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."
 
//oReport:SetLandscape()         // Imprimir relatorio em formato paisagem
 oReport:SetPortrait()          // Imprimir relatorio em formato retrato

 oSection1 := TRSection():New(oReport,STR0008,{"GCY","GCS"})
 oSection1:SetHeaderPage(.T.)
 oSection1:SetHeaderBreak(.F.)
 oCell := TRCell():New(oSection1,"GCY_CODLOC","GCY",)
 oCell := TRCell():New(oSection1,"GCS_NOMLOC","GCS","")

 oSection2 := TRSection():New(oSection1,STR0003,{"GCY","GES","QRYRC1","GBH"})
 oSection2:SetHeaderPage(.T.)
 oSection2:SetHeaderBreak(.F.)
 oSection2:SetNoFilter({"QRYRC1"})
 oCell := TRCell():New(oSection2,"GCY_REGATE","GCY",)
 oCell := TRCell():New(oSection2,"GBH_NOME","QRYRC1",,,25)
 oCell := TRCell():New(oSection2,"GCY_DATATE","GCY",,,,,{||IIF(Empty(("QRYRC1")->GCY_DATATE)," ", HS_DTOC(("QRYRC1")->GCY_DATATE, 1))})
 oCell := TRCell():New(oSection2,"GCY_HORATE","GCY",)
 oCell := TRCell():New(oSection2,"DATLOG","QRYRC1",STR0014,,12) //"Dt. Canc."
 oCell := TRCell():New(oSection2,"HORLOG","QRYRC1",STR0015,,10) //"Hr. Canc."
 oCell := TRCell():New(oSection2,"USERLOG","QRYRC1",STR0016,,20) //"Usu�rio"
 oCell := TRCell():New(oSection2,"GES_DESCRI","QRYRC1",,,30)

 oBreak1   := TRBreak():New(oSection1,oSection2:Cell("GCY_REGATE"), STR0011,.F.) 
 oTotaliz1 := TRFunction():new(oSection2:Cell("GCY_REGATE"),,"COUNT",oBreak1," ==>",,,.F.,.F.,.F.,,)  
 oTotaliz2 := TRFunction():new(oSection2:Cell("GCY_REGATE"),,"COUNT",,STR0010,,,.T.,.F.,.F.,,)
                                                                                                               
 //���������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
 //� TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        �
 //� Parametros para o construtor inicializar as variaveis de instancia :                                                                                    �
 //� (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  �
 //�����������������������������������������������������������������������������������������������������������������������������������������������������������

Return( oReport )

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RC1Imp    � Autor � Antonio Carlos        � Data � 18/08/06 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function RC1IMP(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local cCond1:= "%%"

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)                      

If MV_PAR07 == 1  //ORDENAR POR NOME 
 cCond1:="%GCS_NOMLOC, GBH_NOME%"
Else 						 //ordenar por Dt + Hr Cancelamento
 cCond1:="%GCS_NOMLOC , ANOLOG, MESLOG, DIALOG, HORLOG%"
EndIf     

oSection1:BeginQuery()

BeginSql alias "QRYRC1"
 SELECT GCY_CODLOC, GCS_NOMLOC, GCY_REGATE, GBH_NOME, GCY_DATATE, GCY_HORATE, GES_DESCRI,;
        SUBSTRING(GCY_LOGCAN, 19, 10) AS DATLOG, SUBSTRING(GCY_LOGCAN, 25, 4) AS ANOLOG,;
        SUBSTRING(GCY_LOGCAN, 22, 2) AS MESLOG, SUBSTRING(GCY_LOGCAN, 19, 2) AS DIALOG,;
        SUBSTRING(GCY_LOGCAN, 32, 5) AS HORLOG, SUBSTRING(GCY_LOGCAN, 1, 15) AS USERLOG
 FROM %table:GCY% GCY 
     JOIN %table:GCS% GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = %xFilial:GCS% AND GCS.%NotDel%
     JOIN %table:GBH% GBH ON GBH.GBH_CODPAC = GCY.GCY_REGGER AND GBH.GBH_FILIAL = %xFilial:GBH% AND GBH.%NotDel%
     JOIN %table:GES% GES ON GES.GES_CODIGO = GCY.GCY_CODMOT AND GES.GES_FILIAL = %xFilial:GES% AND GES.%NotDel% 
 WHERE GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%NotDel%
   AND GCY.GCY_CODLOC BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
   AND GCY.GCY_DATATE BETWEEN %Exp:DTOS(MV_PAR03)% AND %Exp:DTOS(MV_PAR04)%
   AND GCY.GCY_CODMOT BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
   AND GCY.GCY_TPALTA = %Exp:'99'%
   ORDER BY %Exp:cCond1%
EndSql

oSection1:EndQuery()
oSection2:SetParentQuery()
oSection2:SetParentFilter( {|G| ("QRYRC1")->GCY_CODLOC  == G }, {|| ("QRYRC1")->GCY_CODLOC})

oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(QRYRC1->(LastRec()))
 
Return( NIL )


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHRC1R3� Autor � Daniel Peixoto     � Data �  03/08/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Relatorio Atendimentos Cancelados - Periodo                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ�� 
���Altera��es� L.Gustavo Caloi 28/03/06 -> Padroniza��o da HS_MsgInf()    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHRC1R3()


/*���������������������������������������������������������������������Ŀ
 � Declaracao de Variaveis                                             �
 ����������������������������������������������������������������������� */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := STR0003 //"Atendimentos Cancelados"
Local nLin           := 80
Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd 				   := {}    

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80                  
Private tamanho      := "M"
Private nomeprog     := "HSPAHRC1" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := {STR0004, 1, STR0005, 2, 2, 1, "", 1}      //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRC1" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg        := "HSPRC1"

Private cString  := ""

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

/*��������������������������������������������������������������������Ŀ
 � PARAMETROS                                                           �
 � MV_PAR01	Do Setor                                                    �
 � MV_PAR02	Ate Setor                                                   �
 � MV_PAR03	Da Data                                                     �
 � MV_PAR04	Ate Data                                                    �
 � MV_PAR05	Do Motivo                                                   �
 � MV_PAR06	Ate Motivo                                                  �
 � MV_PAR07	Ordenar Por   1=PACIENTE 2=DAT+HR CANCEL.                   �
 | MV_PAR08 Impressora ?                                              |
 ���������������������������������������������������������������������� */

If !Pergunte(cPerg,.T.)
	return
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)


RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � Daniel Peixoto     � Data �  17/05/05   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
                                                               
Local cSQL 	     := ""
Local cCodLoc		 := ""
Local nTotSetor	 := 0
Local nTotGeral	 := 0

 cSQL := "SELECT GCY.GCY_CODLOC, GCS.GCS_NOMLOC, GCY.GCY_REGATE, GBH.GBH_NOME, GCY.GCY_DATATE, GCY.GCY_HORATE, "
 cSQL += " GES.GES_DESCRI, SUBSTRING(GCY.GCY_LOGCAN, 19, 10) AS DATLOG, SUBSTRING(GCY.GCY_LOGCAN, 25, 4) AS ANOLOG, "
 cSQL += " SUBSTRING(GCY.GCY_LOGCAN, 22, 2) AS MESLOG, SUBSTRING(GCY.GCY_LOGCAN, 19, 2) AS DIALOG, SUBSTRING(GCY.GCY_LOGCAN, 32, 5) AS HORLOG, "
 cSQL += " SUBSTRING(GCY.GCY_LOGCAN, 1, 15) AS USERLOG "
 cSQL += " FROM " + RetSQLName("GCY") + " GCY" 
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC "
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCY.GCY_REGGER "
 cSQL += " JOIN " + RetSQLName("GES") + " GES ON GES.GES_CODIGO = GCY.GCY_CODMOT " 
 cSQL += " WHERE "
 cSQL += " GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
 cSQL += " AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " AND GES.GES_FILIAL = '" + xFilial("GES") + "' AND GES.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCY.GCY_CODLOC BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
 cSQL += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
 cSQL += " AND GCY.GCY_CODMOT BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
 cSQL += " AND GCY.GCY_TPALTA = '99' "
 cSQL += " ORDER BY GCS_NOMLOC  "
 If MV_PAR07 == 1  //ORDENAR POR NOME 
 	 cSQL += " , GBH_NOME "
 Else 						 //ordenar por Dt + Hr Cancelamento
   cSQL += " , ANOLOG, MESLOG, DIALOG, HORLOG "
 EndIf     
 
 cSql := ChangeQuery(cSql)
 
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0006, STR0012, STR0013) //"Nenhum dado foi encontrado para a selecao efetuada!"###"Aten��o"###"Fun��o Aux. da RPTSTATUS"
  DbCloseArea()
  Return()
 Endif

/*���������������������������������������������������������������������Ŀ
 � SETREGUA -> Indica quantos registros serao processados para a regua �
 ����������������������������������������������������������������������� */

 SetRegua(100)

 While !EOF()

	 IncRegua()
   
   If lAbortPrint
      @nLin,00 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   
   If nLin > nMaxLin
               /*            					 1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16       17
       					             0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.012 */
      Cabec1 := STR0008 //"Setor"
  		  Cabec2 := STR0009// "Atend.  Nome                       Dt. Atd.    Hr. Atd  Dt. Canc.  Hr. Canc. Usuario          Motivo"
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   Endif
   
   If cCodLoc <> QRY->GCY_CODLOC
    If !EMPTY(cCodLoc)     
      nLin ++
      @nLin,007 PSAY STR0010 + TRANSFORM(nTotSetor, "@E 999,999")  //"Total de Atendimentos Cancelados..: "
      nLin += 2                                                                                
      @nLin,000 PSAY REPLI("-",132)
      nLin += 2
    EndIf         
    @nLin,000 PSAY QRY->GCY_CODLOC + " - " + QRY->GCS_NOMLOC
    cCodLoc := QRY->GCY_CODLOC
    nTotSetor := 0
    nLin ++
  EndIf    
   
  @nLin,000 PSAY QRY->GCY_REGATE
  @nLin,008 PSAY SUBSTR(QRY->GBH_NOME, 1, 25)
  @nLin,035 PSAY DTOC(STOD(QRY->GCY_DATATE))
  @nLin,047 PSAY QRY->GCY_HORATE
  @nLin,056 PSAY QRY->DATLOG   //DT. CANC.
  @nLin,067 PSAY QRY->HORLOG   //HR CANC.
  @nLin,077 PSAY QRY->USERLOG  //USUARIO   
  @nLin,094 PSAY QRY->GES_DESCRI                //motivo

  nTotSetor ++  
  nTotGeral ++
  nLin ++  
  
    
  dbSkip() /* Avanca o ponteiro do registro no arquivo */
  
  If EOF()
    nLin ++
    @nLin,007 PSAY STR0010 + TRANSFORM(nTotSetor, "@E 999,999")  //"Total de Atendimentos Cancelados..: "
    nLin += 2                                                                                
    @nLin,000 PSAY REPLI("-",132)
    nLin += 2
    @nLin,007 PSAY STR0011 + TRANSFORM(nTotGeral, "@E 999,999")    //"Total Geral..: "
  EndIf

EndDo



/*���������������������������������������������������������������������Ŀ
 � Finaliza a execucao do relatorio...                                 �
 ����������������������������������������������������������������������� */

SET DEVICE TO SCREEN

/*���������������������������������������������������������������������Ŀ
 � Se impressao em disco, chama o gerenciador de impressao...          �                                           	
 ����������������������������������������������������������������������� */

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()
DBCloseArea()

Return   