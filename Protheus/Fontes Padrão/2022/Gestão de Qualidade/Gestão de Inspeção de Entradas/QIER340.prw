#Include "QIER340.ch"
#Include "PROTHEUS.CH"
#Include "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIER340  � Autor � Leandro S. Sabino     � Data � 31/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Lista de Transferencia       			                  ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIER340	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QIER340()
Local oReport
Private cPerg	:= "QER340"

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01             // Fornecedor De              	         �
//� mv_par02             // Loja De                              �
//� mv_par03             // Fornecedor Ate             	         �
//� mv_par04             // Loja Ate                             �
//� mv_par05             // Produto De              	         �
//� mv_par06             // Produto Ate                          �
//� mv_par07             // Data Valid. De            	         �
//� mv_par08             // Data Valid. Ate            	         �
//����������������������������������������������������������������
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
��� Uso      � QIER340                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport                                             
Local oSection1 
Local oSection2   
Local cPerg := "QER340"

DEFINE REPORT oReport 	NAME "QIER340" ;
                      	TITLE OemToAnsi(STR0003);
                     	PARAMETER cPerg ;
                      	ACTION {|oReport| PrintReport(oReport)} ;
                      	DESCRIPTION OemToAnsi(STR0001)+OemToAnsi(STR0002) //"Vencimento de IQS(s)" ##"Relacao de Vencimento dos IQS(s) de Fornecedores "##"com seus respectivos Produtos. 
oReport:SetLandscape()

DEFINE SECTION oSection1 OF oReport   TITLE OemToAnsi(STR0009) TABLES "SA2" // "Fornecedor"
DEFINE SECTION oSection2 OF oSection1 TITLE OemToAnsi(STR0010) TABLES "SA5","QEG" // "Classes/Situacao"

DEFINE CELL NAME  "A2_COD" 		OF oSection1 ALIAS "SA2" 	AUTO SIZE
DEFINE CELL NAME  "A2_LOJA" 	OF oSection1 ALIAS "SA2" 	AUTO SIZE
DEFINE CELL NAME  "A2_NOME" 	OF oSection1 ALIAS "SA2" 	AUTO SIZE BLOCK {|| Substr(SA2->A2_NOME,1,25) }
DEFINE CELL NAME  "A2_DTAVA" 	OF oSection1 ALIAS "SA2" 	AUTO SIZE
DEFINE CELL NAME  "A2_DTVAL" 	OF oSection1 ALIAS "SA2" 	AUTO SIZE 
DEFINE CELL NAME  "A2_FATAVA" 	OF oSection1 ALIAS "SA2" 	AUTO SIZE BLOCK {|| Transform(SA2->A2_FATAVA,PesqPictQt("A2_FATAVA",14))}		 	ALIGN RIGHT

DEFINE CELL NAME  "A5_PRODUTO" 	OF oSection2 ALIAS "SA5" 	AUTO SIZE
DEFINE CELL NAME  "A5_NOMPROD"	OF oSection2 ALIAS "SA5" 	AUTO SIZE 
DEFINE CELL NAME  "A5_SITU"   	OF oSection2 ALIAS "SA5" 	AUTO SIZE 
DEFINE CELL NAME  "QEG_NIVEL"  	OF oSection2 ALIAS "QEG" 	AUTO SIZE 
DEFINE CELL NAME  "QEG_IQI_I"  	OF oSection2 ALIAS "QEG" 	AUTO SIZE BLOCK {|| Transform(QEG->QEG_IQI_I,PesqPictQt("QEG_IQI_I",14)) } 	ALIGN RIGHT
DEFINE CELL NAME  "QEG_IQI_S"  	OF oSection2 ALIAS "QEG" 	AUTO SIZE BLOCK {|| Transform(QEG->QEG_IQI_S,PesqPictQt("QEG_IQI_S",14)) } 	ALIGN RIGHT

Return oReport


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 31/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport		 	     	                              ���
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
Local oSection2  := oReport:Section(1):Section(1)
Local lPrimCom   := .F.
              
dbSelectArea("SA2")
dbSetOrder(1)     
dbSeek(xFilial("SA2")+mv_par01+mv_par02,.T.)

While SA2->(!Eof()) .and. A2_FILIAL+A2_COD+A2_LOJA <= xFilial("SA2")+mv_par03+mv_par04	
   	//��������������������������������������������������������������Ŀ
	//� Valida data de Validade da Avalia��o                         �
	//����������������������������������������������������������������
	If SA2->A2_DTVAL < mv_par07 .or. SA2->A2_DTVAL > mv_par08
	   SA2->(dbSkip())
	   Loop
	EndIF   
    
    lPrimCom := .T.
    
    oSection1:Init()
	oSection1:PrintLine()
   	//��������������������������������������������������������������Ŀ
	//� Imppress�o dos Produtos relacionados ao Fornecedor.          �
	//����������������������������������������������������������������
	dbSelectArea("SA5")
	dbSetOrder(1)
	If dbSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA)
        While SA5->(!EOF()) .and. SA2->A2_COD+SA2->A2_LOJA == SA5->A5_FORNECE+ SA5->A5_LOJA
	    
            //Verifica se o Produto possui tratamento no Quality
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+SA5->A5_PRODUTO))
				If RetFldProd(SB1->B1_COD,"B1_TIPOCQ") <> "Q"
				   SA5->(dbSkip())
				   Loop
			    EndIf
            EndIf
            
		   	//��������������������������������������������������������������Ŀ
			//� Valida se Produto esta no intervalo definido nos parametro   �
			//����������������������������������������������������������������
			If SA5->A5_PRODUTO < mv_par05 .or. SA5->A5_PRODUTO > mv_par06
			   SA5->(dbSkip())
			   Loop
			EndIF   

   			//��������������������������������������������������������������Ŀ
			//� Posiciona QEG. 										         �
			//����������������������������������������������������������������
			dbSelectArea("QEG")
			dbSetOrder(1)
			dbSeek(xFilial("QEG")+SA5->A5_SITU)
	    
			If lPrimCom
 		        lPrimCom := .F.
			    oSection2:Init()
			EndIf

			oSection2:PrintLine()
    		SA5->(dbSkip())   		
        EndDo
    EndIf  
    SA2->(dbSkip()) 
    oSection1:Finish()
EndDo

Return