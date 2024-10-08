#INCLUDE "FINR471.CH"
#INCLUDE "PROTHEUS.Ch"                                          


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa� FINR471 �Autor� Gabriel Borges Vilete �   Data �  01/11/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �   Relat�rio de concilia��o banc�ria                        ���
���          �   Par�metros: Sele��o do que ser� impresso a partir da     ���
���							 rotina FINA471 (conciliados e/ou n�o         ���
���                          conciliados)                                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


Function FINR471(cBanco, ldecide1, ldecide2)          

Private nomeprog	:= "FINR471"    
Private cBancomov := cBanco
Private lconc1 := ldecide1
Private lconc2 := ldecide2

pergunte("AFI470",.F.)

	FINR471R4()
	
Return

Function FINR471R4()                           

Local aTRB := {}
Local oReport  

PRIVATE cPerg := "AFI470"        

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������            
Pergunte( cPerg, .F. )

aTRB := TRB->(GetArea())

oReport := ReportDef()      

			oReport:SetEdit(.F.) 
			oReport:ParamReadOnly()
			oReport:SetLandScape()
			oReport:DisableOrientation()
			oReport:HideFooter() 
			oReport:PrintDialog()


oReport := nil

RestArea(aTRB)

Return                                

         
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa � ReportDef �Autor� Gabriel Borges Vilete� Data�   01/11/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Esta funcao tem como objetivo definir as secoes, celulas,   ���
���          �totalizadores do relatorio que poderao ser configurados     ���
���          �pelo relatorio.                                             ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ReportDef()     

Local CREPORT	:= "FINR471"                    
Local CTITULO	:= OemToAnsi(STR0001)				// "CONCILIA��O BANC�RIA"
Local CDESC		:= OemToAnsi(STR0002) + ; 			// "Este programa ir� imprimir a Concilia��o Banc�ria "
	   			   OemToAnsi(STR0003) 				// "de acordo com as prefer�ncias informadas pelo usu�rio."
                                         
Local aTamReconc := TamSX3("E5_RECONC")                                                
Local aTamSeq	 := TamSX3("E5_SEQ")
Local aTamData	 := TamSX3("E5_DATA")	
Local aTamValor  := TamSX3("E5_VALOR")
Local aTamDocum	 := TamSX3("E5_DOCUMEN")		
Local aTamOcors  := TamSX3("EJ_OCORSIS")
Local aTamDescr  := TamSX3("EJ_DESCR")
Local aTamDebcre := TamSX3("EJ_DEBCRE")
Local aTamHistor := TamSX3("E5_HISTOR")
Local cPerg471	:= "AFI470"
Local oSection1		 

cTitulo	:= OemToAnsi(STR000D)						// "Concilia��o Banc�ria"

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �                                                                         �
//��������������������������������������������������������������������������


oReport	:= TReport():New( cReport,cTitulo,cPerg, { |oReport| Pergunte(cPerg , .F. ), If(! ReportPrint( oReport )  , oReport:CancelPrint(), .T. ) }, cDesc ) 

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//��������������������������������������������������������������������������

oSection1 := TRSection():New( oReport, STR000D) // "Concilia��o Banc�ria"

TRCell():New( oSection1, "RECONC"	,"",STR0004 /*"Estado"*/				/*STR0008Titulo*/,/*"@D 99/99/9999"*//*Picture*/,aTamReconc[1] /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	
TRCell():New( oSection1, "SEQ"  	,"",STR0005 /*"Sequ�ncia"*/				/*STR0009Titulo*/,/*"@!"*//*Picture*/,aTamSeq[1] /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	
TRCell():New( oSection1, "DATA" 	,"",STR0006 /*"Data Movimento"*/				/*STR0010Titulo*/,/*Picture*/,aTamData[1] /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	
TRCell():New( oSection1, "VALOR"	,"",STR0007 /*"Valor Movimento"*/				/*STR0011Titulo*/,/*Picture*/,aTamValor[1]+aTamValor[2] /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	
TRCell():New( oSection1, "DOCUMEN"	,"",STR0008 /*"C�digo Documento"*/				/*STR0012Titulo*/,/*Picture*/,aTamDocum[1] /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	
TRCell():New( oSection1, "OCORSIS"	,"",STR0009 /*"Tipo Movimento"*/				/*STR0013Titulo*/,/*Picture*/,aTamOcors[1] /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	
TRCell():New( oSection1, "DESCR"	,"",STR000A /*"Descri��o"*/				/*STR0014Titulo*/,/*Picture*/,aTamDescr[1] /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "DEBCRE"	,"",STR000B /*"D/C"*/				/*STR0015Titulo*/,/*Picture*/,aTamDebcre[1] /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "HISTOR"	,"",STR000C /*"Historico"*/				/*STR0016Titulo*/,	/*Picture*/,aTamHistor[1] /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)


oSection1:SetHeaderPage()
oSection1:SetTotalInLine(.F.) 

Return(oReport)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa� ReportPrint �Autor� Gabriel Borges Vilete �Data�  01/11/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Imprime o relatorio definido pelo usuario de acordo com as  ���
���          �secoes/celulas criadas na funcao ReportDef definida acima.  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ReportPrint( oReport )    

Local oSection1 	:= oReport:Section(1)
Local cArqTmp
Local aTamReconc := TamSX3("E5_RECONC")                                                
Local aTamSeq	 := TamSX3("E5_SEQ")
Local aTamData	 := TamSX3("E5_DATA")	
Local aTamValor  := TamSX3("E5_VALOR")
Local aTamDocum	 := TamSX3("E5_DOCUMEN")		
Local aTamOcors  := TamSX3("EJ_OCORSIS")
Local aTamDescr  := TamSX3("EJ_DESCR")
Local aTamDebcre := TamSX3("EJ_DEBCRE")
Local aTamHistor := TamSX3("E5_HISTOR")
Local cRec       := "0"
						  
dbSelectArea("TRB")       

cArqTmp1 := CriaTrab(,.F.)
                   
dbSetOrder(1)       
dbGoTop()
 
oReport:SetMeter( RecCount() )

oReport:SetPageNumber(1)

While TRB->(!EOF())

	oReport:IncMeter()
	
	cRec := Soma1(cRec)
		

	SE5->(DbSetOrder(1))
	If SE5->(dbSeek(xFilial("SE5")+dtos(ctod(TRB->DATAMOV))+CBANCOMOV+TRB->AGEMOV+TRB->CTAMOV+TRB->NUMMOV))
	
		If (LCONC1) .AND. !(EMPTY(SE5->E5_RECONC))
			
			If oReport:Cancel()
				Exit
			EndIf
			
			oSection1:Init()
			
			
			oSection1:Cell("RECONC" ):SetBlock( { || SE5->E5_RECONC } )	
			oSection1:Cell("SEQ"    ):SetBlock( { || TRB->SEQMOV } )
			oSection1:Cell("DATA"   ):SetBlock( { || TRB->DATAMOV } )
			oSection1:Cell("VALOR"  ):SetBlock( { || TRB->VALORMOV } )
			oSection1:Cell("DOCUMEN"):SetBlock( { || TRB->NUMMOV } )
			oSection1:Cell("OCORSIS"):SetBlock( { || TRB->TIPOMOV } )
			oSection1:Cell("DESCR"  ):SetBlock( { || TRB->DESCMOV } )
			oSection1:Cell("DEBCRE" ):SetBlock( { || TRB->DEBCRED } )
			oSection1:Cell("HISTOR" ):SetBlock( { || TRB->DESCMOV } ) 
						
			oSection1:PrintLine()
			oSection1:Finish()
				
		ElseIf (LCONC2) .AND. (EMPTY(SE5->E5_RECONC))
			
			If oReport:Cancel()
				Exit
			EndIf
			
			oSection1:Init()
			
			oSection1:Cell("RECONC" ):SetBlock( { || SE5->E5_RECONC } )	
			oSection1:Cell("SEQ"    ):SetBlock( { || TRB->SEQMOV } )
			oSection1:Cell("DATA"   ):SetBlock( { || TRB->DATAMOV } )
			oSection1:Cell("VALOR"  ):SetBlock( { || TRB->VALORMOV } )
			oSection1:Cell("DOCUMEN"):SetBlock( { || TRB->NUMMOV } )
			oSection1:Cell("OCORSIS"):SetBlock( { || TRB->TIPOMOV } )
			oSection1:Cell("DESCR"  ):SetBlock( { || TRB->DESCMOV } )
			oSection1:Cell("DEBCRE" ):SetBlock( { || TRB->DEBCRED } )
			oSection1:Cell("HISTOR" ):SetBlock( { || TRB->DESCMOV } ) 
		
			oSection1:PrintLine() 
			
			oSection1:Finish()
		EndIf
	ElseIf (LCONC2) // Os registros n�o encontrados pelo seek que pertencem ao documento .ret n�o est�o conciliados, portando devem ser impressos
		If oReport:Cancel()
				Exit
			EndIf
			
			oSection1:Init()
			
			oSection1:Cell("RECONC" ):SetBlock( { || "" } )	
			oSection1:Cell("SEQ"    ):SetBlock( { || TRB->SEQMOV } )
			oSection1:Cell("DATA"   ):SetBlock( { || TRB->DATAMOV } )
			oSection1:Cell("VALOR"  ):SetBlock( { || TRB->VALORMOV } )
			oSection1:Cell("DOCUMEN"):SetBlock( { || TRB->NUMMOV } )
			oSection1:Cell("OCORSIS"):SetBlock( { || TRB->TIPOMOV } )
			oSection1:Cell("DESCR"  ):SetBlock( { || TRB->DESCMOV } )
			oSection1:Cell("DEBCRE" ):SetBlock( { || TRB->DEBCRED } )
			oSection1:Cell("HISTOR" ):SetBlock( { || TRB->DESCMOV } ) 
		
			oSection1:PrintLine() 
			
			oSection1:Finish()
	Endif
   	
	TRB->(dbSkip())
		
End  


Return(.T.)        
