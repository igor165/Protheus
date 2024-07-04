#INCLUDE "ACDI050.ch" 
#include "rwmake.ch"        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ACDI050  � Autor � Sandro                � Data � 05/02/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao de etiquetas de transportadora                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function ACDI050
Local cPerg := If(IsTelNet(),'VTPERGUNTE','PERGUNTE')

IF ! &(cPerg)("AII050",.T.) 
   Return
EndIF        
If IsTelNet() 
   VtMsg(STR0001) //'Imprimindo'
   ACDI050TR()
Else 
   Processa({|| ACDI050TR()})
EndIf   
Return       

Function ACDI050TR(nID,cImp)            
Local cIndexSA4,cCondicao
Local cCodTR,aRet              
Local cRet:=''

If nID # NIL
   aRet := CBRetEti(nID,'06',NIL,.T.)
   If Len(aRet) == 0
      Return .f.
   EndIf
   cCodTR := aRet[1]   
   cRet:='R'
End
If ! CB5SetImp(If(nID==NIL,MV_PAR03,cImp),IsTelNet() )
   Return .f.
EndIf   
cIndexSA4 := CriaTrab(nil,.f.)
DbSelectArea("SA4")
cCondicao :=""                                                    
cCondicao := cCondicao + "A4_FILIAL    == '"+ xFilial()+"' .And. "
cCondicao := cCondicao + "A4_COD     >= '"+IF(nID==NIL,mv_par01,cCodTR) +"' .And. "
cCondicao := cCondicao + "A4_COD     <= '"+IF(nID==NIL,mv_par02,cCodTR) +"'"
IndRegua("SA4",cIndexSA4,"A4_COD",,cCondicao,,.f.)
DBGoTop()                         
While ! SA4->(Eof())
   If ExistBlock('IMG06')
      ExecBlock("IMG06",,,{nID})
   EndIf
   SA4->(DbSkip())
End

RetIndex("SA4")
Ferase(cIndexSA4+OrdBagExt())

If ExistBlock('IMG00')
   ExecBlock("IMG00",,,{cRet+ProcName(),IF(nID==NIL,mv_par01,cCodTR),IF(nID==NIL,mv_par02,cCodTR)})
EndIf

MSCBCLOSEPRINTER()
Return .t.
                                        
