#include "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSRXMLT   �Autor  �Totvs				 � Data �  15/04/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorno processamento xml XMLLOG							  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSRXMLT(cXMLFile)
LOCAL cDesc1    	:= "Este programa tem como objetivo imprimir o log de "
LOCAL cDesc2    	:= "retorno do processamento do XML TISS."
LOCAL cDesc3    	:= ""
LOCAL cString   	:= ""             

PRIVATE cRel		:= "PLSRXMLT"+cXMLFile         
PRIVATE cPathSrvJ	:=  GETMV("MV_RELT")
PRIVATE cTamanho	:= "G"  
PRIVATE cTitulo 	:= "TISS - XML de Retorno"
PRIVATE cabec1  	:= ""
PRIVATE cabec2  	:= ""
PRIVATE aReturn 	:= { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 } 
PRIVATE nomeprog	:= "PLSRXMLT" 
PRIVATE nLastKey	:=0
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE aRet 		:= {.T.,"",cPathSrvJ+cRel+".##R"}       
//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint                                                           �
//����������������������������������������������������������������������������
cRel := SetPrint(cString,cRel,"",@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
//��������������������������������������������������������������������������Ŀ
//� Parametros																 �
//����������������������������������������������������������������������������
If Empty(cXMLFile)   
   Return( {.F.,'Arquivo n�o especificado!'} )
EndIf
//��������������������������������������������������������������������������Ŀ
//� Configura impressora                                                     �
//����������������������������������������������������������������������������
SetPrintFile(cRel)
SetDefault(aReturn,cString)
//��������������������������������������������������������������������������Ŀ
//� impress�o																 �
//����������������������������������������������������������������������������
PLSRXMLImp(cXMLFile)    
//��������������������������������������������������������������������������Ŀ
//� Flush																	 �
//����������������������������������������������������������������������������
MS_FLUSH()
//��������������������������������������������������������������������������Ŀ
//� Fim da rotina                                                            �
//����������������������������������������������������������������������������
Return(aRet)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSRXMLImp �Autor  �Totvs              � Data �  15/04/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Leitura arquivo de logs									  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PLSRXMLImp(cXMLFile)
LOCAL li		:= 1
LOCAL cBuffer	:= 0
                          
@li,000 PSAY Replicate("-",80)
li++
@ li, 000 PSAY Space( 40-Len(cTitulo)/2 ) + cTitulo
li++
@li,000 PSAY Replicate("-",80)
li++
li++

If ! File( PLSMUDSIS("\TISS\LOG\" + cXMLFile + ".txt") )
	@ li, 000 PSAY "O log de processamento " + cXMLFile + " n�o encontrado."
	Return
EndIf

FT_FUSE( PLSMUDSIS("\TISS\LOG\" + cXMLFile + ".txt") )
FT_FGOTOP()

While !FT_FEOF()

	cBuffer := FT_FREADLN()
	If SubStr(cBuffer,1,1) == "*"
		li++
	EndIf
	@ li, 000 PSAY cBuffer
	li++
	FT_FSKIP()
	
EndDo

FT_FUSE()

Set Printer To
//��������������������������������������������������������������������������Ŀ
//� Fim da rotina                                                            �
//����������������������������������������������������������������������������
Return