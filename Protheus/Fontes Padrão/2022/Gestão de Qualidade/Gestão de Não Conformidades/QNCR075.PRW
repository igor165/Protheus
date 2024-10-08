
#INCLUDE "QNCR075.ch"
#INCLUDE "Protheus.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QNCR075  � Autor � Leandro S. Sabino     � Data � 07/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio Log de Transferencia  			                  ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQNC	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QNCR075()
Local oReport
Private cPerg   := "QIG075"

Pergunte(cPerg,.F.)
oReport := ReportDef()
oReport:PrintDialog()

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 07/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQNC                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport                                             
Local oSection0 
Local oSection1 

oReport   := TReport():New("QNCR075",OemToAnsi(STR0001),cPerg,{|oReport| PrintReport(oReport)},OemToAnsi(STR0002)+OemToAnsi(STR0003))
oReport:SetLandscape()
//"Lista de Transferencia das Pendencias FNC e/ou Planos e Etapas"
//"Este programa ir� imprimir uma rela�ao de transferencias"
//"de acordo com os par�metros definidos pelo usu�rio."

oSection0 := TRSection():New(oReport,OemToAnsi(STR0001),{"QIG"}) 
oSection1 := TRSection():New(oSection0,OemToAnsi(STR0001),{"QIG"}) 
oSection0:SetEdit(.F.)
oSection1:SetEdit(.F.)

Return oReport


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 07/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)  	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQNC                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintReport( oReport )
Local oSection0  := oReport:Section(1)
Local oSection1  := oReport:Section(1):Section(1)
Local atppend    := {}
Local lData      := .T.
Local cFiltro 


MakeAdvplExpr(cPerg)
              
DbSelectarea("QIG")
DbSetOrder(1)

cFiltro:= 'QIG->QIG_FILIAL =="'  +xFilial("QIG")+'" .And. '
cFiltro+= 'QIG->QIG_FNC    >= "' +mv_par01+'" .And. QIG->QIG_FNC    <= "' +mv_par02+'" .And. '
cFiltro+= 'QIG->QIG_REVFNC >= "' +mv_par03+'" .And. QIG->QIG_REVFNC <= "' +mv_par04+'" .And. '
cFiltro+= 'QIG->QIG_CODIGO >= "' +mv_par05+'" .And. QIG->QIG_CODIGO <= "' +mv_par06+'" .And. '
cFiltro+= 'QIG->QIG_REVCOD >= "' +mv_par07+'" .And. QIG->QIG_REVCOD <= "' +mv_par08+'" .And. '                      
cFiltro+= 'QIG->QIG_FILDE  >= "' +mv_par09+'" .And. QIG->QIG_MATDE  >= "' +mv_par10+'" .And. '
cFiltro+= 'QIG->QIG_FILDE  <= "' +mv_par11+'" .And. QIG->QIG_MATDE  <= "' +mv_par12+'" .And. '		  
cFiltro+= 'QIG->QIG_FILPAR >= "' +mv_par13+'" .And. QIG->QIG_MATPAR >= "' +mv_par14+'" .And. '
cFiltro+= 'QIG->QIG_FILPAR <= "' +mv_par15+'" .And. QIG->QIG_MATPAR <= "' +mv_par16+'" .And. '
cFiltro+= 'DTOS(QIG->QIG_DTTRAN) >= "'+DTOS(mv_par17)+'" .And. DTOS(QIG->QIG_DTTRAN) <= "'+DTOS(mv_par18)+'"'

cKey:= 'QIG->QIG_FILIAL+DTOS(QIG->QIG_DTTRAN)+QIG->QIG_SEQTRF'

oSection1:SetFilter(cFiltro) 

QNCCBOX("QIG_TPPEND",@atppend)

oSection0:Init()
oSection0:PrintLine()

While !oReport:Cancel() .And. QIG->(!Eof())  
	If lData 
		oReport:PrintText(Alltrim(RetTitle("QIG_DTTRAN"))+STR0007+dtoc(mv_par17)+STR0008+dtoc(mv_par18)) //### //": De "###" at� "
		lData := .F.
	Endif           
	
	oSection1:Init()
	oReport:SkipLine(1) 
	oReport:FatLine()
	//����������������������������������������������Ŀ
	//�TIPO Data de Transferencia - Sequencia   	 �
	//������������������������������������������������
	IF !EMPTY(QIG->QIG_FNC)																	 
		oReport:PrintText(Alltrim(RetTitle("QIG_FNC"))+": "+Alltrim(TransForm(QIG->QIG_FNC,"@R ###########/####"))+"   "+Alltrim(RetTitle("QIG_DTTRAN"))+"-"+Alltrim(RetTitle("QIG_SEQTRF"))+": "+DToC(QIG->QIG_DTTRAN)+' - '+QIG->QIG_SEQTRF,oReport:Row(),025) 
	ELSEIF !EMPTY(QIG->QIG_CODIGO) .AND. EMPTY(QIG->QIG_TPACAO)
		oReport:SkipLine(1) 
		oReport:PrintText(Alltrim(RetTitle("QIG_CODIG"))+": "+Alltrim(TransForm(QIG->QIG_CODIGO,"@R ###########/####"))+"   "+Alltrim(RetTitle("QIG_DTTRAN"))+"-"+Alltrim(RetTitle("QIG_SEQTRF"))+": "+DToC(QIG->QIG_DTTRAN)+' - '+QIG->QIG_SEQTRF,oReport:Row(),025) 
	ELSE
		oReport:SkipLine(1) 
		oReport:PrintText(Alltrim(RetTitle("QIG_CODIG"))+": "+Alltrim(TransForm(QIG->QIG_CODIGO,"@R ###########/####"))+"   "+Alltrim(RetTitle("QIG_DTTRAN"))+"-"+Alltrim(RetTitle("QIG_SEQTRF"))+": "+DToC(QIG->QIG_DTTRAN)+' - '+QIG->QIG_SEQTRF,oReport:Row(),025) 
		oReport:SkipLine(1)	
		oReport:PrintText(Alltrim(RetTitle("QIG_TPACAO"))+": "+Alltrim(QIG->QIG_TPACAO)+" - "+FQNCDTPACAO(QIG->QIG_TPACAO),oReport:Row(),025) 
	ENDIF	

	//���������������������������������������������������������������������������������Ŀ
	//�Tipo de Transferencia  Responsavel pela Transferencia   Motivo da Transferencia	�
	//�����������������������������������������������������������������������������������
	oReport:SkipLine(1) 
	oReport:PrintText(Alltrim(RetTitle("QIG_TPPEND"))+": "+atppend[VAL(QIG->QIG_TPPEND)],oReport:Row(),025) 
	oReport:SkipLine(1) 
	oReport:PrintText(Alltrim(RetTitle("QIG_MATRES"))+": "+QIG->QIG_FILRES+" - "+QIG->QIG_MATRES+" "+Alltrim(QA_NUSR(QIG->QIG_FILRES,QIG->QIG_MATRES))+"            "+Alltrim(RetTitle("QIG_MOTIVO"))+": "+QIG->QIG_MOTIVO,oReport:Row(),025) 

	//������������������������������������������������Ŀ
	//�Usuario Origem                 				                       �
	//��������������������������������������������������
 	oReport:SkipLine(1) 
	oReport:PrintText(Alltrim(RetTitle("QIG_MATDE"))+": "+QIG->QIG_FILDE +" - "+QIG->QIG_MATDE+" "+Alltrim(QA_NUSR(QIG->QIG_FILDE,QIG->QIG_MATDE)),oReport:Row(),025) 

	//������������������������������������������������Ŀ
	//�Usuario Destino                				   �
	//��������������������������������������������������
 	oReport:SkipLine(1) 
	oReport:PrintText(Alltrim(RetTitle("QIG_MATPAR"))+": "+QIG->QIG_FILPAR +" - "+QIG->QIG_MATPAR+" "+Alltrim(QA_NUSR(QIG->QIG_FILPAR,QIG->QIG_MATPAR)),oReport:Row(),025) 
	oReport:SkipLine(1)	
	oReport:FatLine()

	oSection1:PrintLine()	

	QIG->(DbSkip())
	
	oSection1:Finish()
Enddo
oSection0:Finish()
Return

