#INCLUDE "ACDI020.ch" 
#include "rwmake.ch"        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ACDI020  � Autor � Sandro                � Data � 05/02/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao de etiquetas de Localizacao                      ���
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

Function ACDI020
Local cPerg := If(IsTelNet(),'VTPERGUNTE','PERGUNTE')

IF ! &(cPerg)("AII020",.T.) 
   Return
EndIF
If IsTelNet() 
   VtMsg(STR0001) //'Imprimindo'
   ACDI020LO()
Else 
   Processa({|| ACDI020LO()})
EndIf   

Return       

Function ACDI020LO(nId,cImp)            
Local cIndexSBE,cCondicao
Local cCodLoc,cCodAlmox,aRet
Local cRet:=''

If nID # NIL
   aRet := CBRetEti(nID,'02',NIL,.T.)   
   IF Len(aRet) == 0
      Return .f.
   EndIf
   cCodLoc   := aRet[1]
   cCodAlmox := aRet[2]  
   cRet := 'R'
End
If ! CB5SetImp(If(nID==NIL,MV_PAR05,cImp),IsTelNet() )
   Return .f.
EndIf   
cIndexSBE := CriaTrab(nil,.f.)
DbSelectArea("SBE")
cCondicao :=""                                                    
cCondicao := cCondicao + "BE_FILIAL    == '"+ xFilial()+"' .And. "
cCondicao := cCondicao + "BE_LOCAL     >= '"+ If(nID==NIL,mv_par01,cCodAlmox) +"' .And. "
cCondicao := cCondicao + "BE_LOCAL     <= '"+ If(nID==NIL,mv_par02,cCodAlmox) +"' .And. "
cCondicao := cCondicao + "BE_LOCALIZ   >= '"+ If(nID==NIL,mv_par03,cCodLoc) +"' .And. "
cCondicao := cCondicao + "BE_LOCALIZ   <= '"+ If(nID==NIL,mv_par04,cCodLoc) +"' "
IndRegua("SBE",cIndexSBE,"BE_LOCAL",,cCondicao,,.f.)
DBGoTop()                         

While ! SBE->(Eof())
   If ExistBlock('IMG02')
     ExecBlock("IMG02",.f.,,{nID})
   EndIf
   SBE->(DbSkip())
End
If ExistBlock('IMG00')
   ExecBlock("IMG00",,,{cRet+ProcName()})
EndIf

MSCBCLOSEPRINTER()
RetIndex("SBE")
Ferase(cIndexSBE+OrdBagExt())
Return .t.

