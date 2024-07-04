#INCLUDE "QNCR110.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QNCR110  � Autor � Leandro S. Sabino     � Data � 31/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Lista de Etapas Vencidas e a Vencer		                  ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QNCR110	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QNCR110()
Local oReport
Private cPerg	  := "QNR110"
Private lTMKPMS   := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS �

Pergunte(cPerg,.F.)
oReport := ReportDef()
oReport:PrintDialog()

Return
      

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 31/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QNCR110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport                                             
Local oSection1 

oReport   := TReport():New("QNCR110",OemToAnsi(STR0001),"QNR110",{|oReport| PrintReport(oReport)},OemToAnsi(STR0002)+OemToAnsi(STR0003))
oReport:SetLandscape()
//"LISTA DE ETAPAS VENCIDAS E A VENCER"##"Este programa ira imprimir uma rela�ao de Usuarios com Etapas"
//"Vencidas e a Vencer de acordo com os par�metros definidos pelo usu�rio.

oSection1 := TRSection():New(oReport,OemToAnsi(STR0025),{"QI5"})	// "Etapas do Plano" 
TRCell():New(oSection1,"QI5_CODIGO" ,"QI5") 
TRCell():New(oSection1,"QI5_REV"    ,"QI5") 
TRCell():New(oSection1,"QI5_TPACAO" ,"QI5",,,25,,{|| SubStr(FQNCDTPACAO(QI5->QI5_TPACAO),1,55) } ) 
TRCell():New(oSection1,"cUsuario"   ,"  " ,TitSX3("QAA_NOME")[1],,TamSX3("QAA_NOME")[1],,{|| SubStr(QA_NUSR(QI5->QI5_FILMAT,QI5->QI5_MAT),1,30)} ) 
TRCell():New(oSection1,"QI5_PRAZO"  ,"QI5",TitSX3("QMF_DIAS")[1],,15,,{|| QNCR110DI()}) 

Return oReport


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 31/05/06 ���
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
Local cFiltro 

MakeAdvplExpr("QNR110")
              
DbSelectarea("QI5")
DbSetOrder(1)

cFiltro:= 'QI5->QI5_FILIAL >= "'+mv_par01+'" .And. QI5->QI5_FILIAL <= "'+mv_par02+'" .And. '
cFiltro+= 'RIGHT(QI5->QI5_CODIGO,4) >= "'+mv_par03+'" .And. RIGHT(QI5->QI5_CODIGO,15) <= "'+mv_par04+'" .And. '
cFiltro+= 'RIGHT(QI5->QI5_CODIGO,4)+LEFT(QI5->QI5_CODIGO,15) >= "'+RIGHT(mv_par05,4)+Left(mv_par05,15)+'" .And. '
cFiltro+= 'RIGHT(QI5->QI5_CODIGO,4)+LEFT(QI5->QI5_CODIGO,15) <= "'+RIGHT(mv_par06,4)+Left(mv_par06,15)+'" .And. '
cFiltro+= 'QI5->QI5_REV >= "'+mv_par07+'" .And. QI5->QI5_REV <= "'+mv_par08+'" .And. '
cFiltro+= 'QI5->QI5_MAT >= "'+mv_par09+'" .And. QI5->QI5_MAT <= "'+mv_par10+'" .And. '
cFiltro+= 'QI5->QI5_TPACAO >= "'+mv_par11+'" .And. QI5->QI5_TPACAO <= "'+mv_par12+'" .And. '
cFiltro+= 'DTOS(QI5->QI5_PRAZO) >= "'+DTOS(mv_par13)+'" .And. DTOS(QI5->QI5_PRAZO) <= "'+DTOS(mv_par14)+'".And. '
If Upper(TcGetDb()) $ "DB2/400"
	cFiltro+= 'QI5->QI5_PEND == "S" .And. DTOS(QI5->QI5_PRAZO)=="        "'
Else
    cFiltro+= 'QI5->QI5_PEND == "S" .And. !Empty(DTOS(QI5->QI5_PRAZO))'
Endif

oSection1:SetFilter(cFiltro)
oSection1:Print()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 31/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Gerar os dias vencidos			                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QDR090DI			   	     	                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QNCR110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function QNCR110DI()

If (QI5->QI5_PRAZO - dDatabase) > 0
	cDias:= (StrZero((QI5->QI5_PRAZO - dDatabase),4))+" "+ OemToAnsi(STR0009)// "A Vencer"
Else
	cDias:= (StrZero((dDataBase - QI5->QI5_PRAZO),4))+" "+ OemToAnsi(STR0010)// "Vencido"
EndIf

return cDias

