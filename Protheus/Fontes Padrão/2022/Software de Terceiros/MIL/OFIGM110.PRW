#INCLUDE "Ofigm110.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIGM110 � Autor �  Renata               � Data � 21/02/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorno garantia manual SC                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Garantia                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/



FUNCTION OFIGM110

LOCAL cChave, cCond

PRIVATE aCampos := {}

PRIVATE aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemToAnsi(STR0004)   //"Retorno da garanita manual" //"Retorno Fabrica Manual"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������

dbSelectArea("VG8")
dbSetOrder(1)             

//mBrowse( 6, 1,22,75,"VG8",,,,"VG8_TRANSM=='S'.and.empty(VG8_EXCLUI).and.empty(VG8_RRCNEW).and.VG8_SITRRC$('  010205')")   //(VG8_ITEPGT=0.OR.VG8_SERPGT=0)")
//return

cIndex  := CriaTrab(nil,.f.)
cChave  := Indexkey()   //"VGA_FILIAL+VGA_CODMAR+VGA_NUMOSV+VGA_ESPGAR"
cCond   := 'VG8_TRANSM=="S".and.empty(VG8_EXCLUI).and.empty(VG8_RRCNEW).and.VG8_SITRRC$("  010205")'
IndRegua("VG8",cIndex,cChave,,cCond,STR0005) //"Aguarde, filtrando registros"

DbSelectArea("VG8")
nIndex := RetIndex("VG8")
#IFNDEF TOP
   dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndex+1)

mBrowse( 6, 1,22,75,"VG8",,,,"VG8_TRANSM=='S'.and.empty(VG8_EXCLUI).and.empty(VG8_RRCNEW).and.VG8_SITRRC$('  010205')") 

dbSelectArea("VG8")
Set Filter to
RetIndex("VG8")
DbsetOrder(1)
#IFNDEF TOP
   If File(cIndex+OrdBagExt())
      fErase(cIndex+OrdBagExt())
   Endif
#ENDIF

Return
  
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GM110V    � Autor �Renata                 � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Visualiza dados do arquivo VG8                             ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GM110V(CLIAS,NREG,NOPC)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Garantia                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function GM110V(cAlias,nReg,nOpc)
**************************

IF VG8_TRANSM=='S'.and.empty(VG8_EXCLUI).and.empty(VG8_RRCNEW) 
   CPOGM110()
   AxVisual(cAlias,nReg,nOpc,aCampos)
else
   help(" ",1,"OFIGM11001")//"Garantia nao foi transmitida, foi excluida, ou reconsiderada!"
endif                                                                 

return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GM110A    � Autor �Renata                 � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Altera os campos do arquivo VG8                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GM110A(CLIAS,NREG,NOPC)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Garantia                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


Function GM110A(cAlias,nReg,nOpc)
**************************
if VG8_TRANSM=='S'.and.empty(VG8_EXCLUI).and.empty(VG8_RRCNEW)
   CPOGM110()
   AxAltera(cAlias,nReg,nOpc,aCampos)
   private cDescri := ""
   FS_SITRR("VG8->VG8_SITRRC")
   RecLock("VG8",.F.)
   VG8->VG8_DESSIT := cDescri
   MsUnlock()
else
   help(" ",1,"OFIGM11001")//"Garantia nao foi transmitida, foi excluida, ou reconsiderada!"
endif   

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CPOGM110  � Autor �Renata                 � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pega campos do arquivo VG8 no SX3                          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � CPOGM110()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Garantia                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function CPOGM110()
***************
DbSelectArea("SX3")
dbgotop()
dbseek("VG802")
aCampos := {}

do While !eof() .and. x3_arquivo == "VG8"
   if X3USO(x3_usado).And.cNivel>=x3_nivel.And.x3_campo $ ("VG8->VG8_NUMOSV/VG8->VG8_NUMRRC/VG8->VG8_ANORRC/VG8->VG8_CODMAR/VG8->VG8_DATRET/VG8->VG8_SITRRC/VG8->VG8_DATCRE/VG8->VG8_ITEPGT/VG8->VG8_SERPGT/VG8->VG8_DATEST/VG8->VG8_ITEEST/VG8->VG8_SEREST")
      aadd(aCampos,x3_campo)
   endif
   dbskip()
Enddo

DbSelectArea("VG8")

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �SITRR     � Autor �Renata                 � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Identifica a situacao da rr na montadora                   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � SITRR(ARG1)                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Garantia                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function FS_SITRR(Arg1)
*******************
if &ARG1 = "01"
   cDescri := OemtoAnsi(STR0006)  //    //"CRITICA DO RELATORIO DE RECLAMACAO"
elseif &ARG1 = "02"
   cDescri := OemtoAnsi(STR0007)  //    //"AVISO RECEBIMENTO DA RECLAMACAO"
elseif &ARG1 = "03"
   cDescri := OemtoAnsi(STR0008)  //"ATENDIMENTO DA RECLAMACAO - CREDITO"    //"ATENDIMENTO DA RECLAMACAO - LIQUIDADA"
elseif &ARG1 = "04"
   cDescri := OemtoAnsi(STR0009)  //"ATENDIMENTO DA RECLAMACAO - DEBITO"    //"ATENDIMENTO DA RECLAMACAO - ESTORNADA"
elseif &ARG1 = "05"
   cDescri := OemtoAnsi(STR0010)  //    //"ATENDIMENTO DA RECLAMACAO - RECUSADA"
endif

return(cDescri)                                                    

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},; //Pesquisar
                     { STR0002 ,"GM110V", 0 , 2},; //VIZUALIZAR
                     { STR0003 ,"GM110A", 0 , 4}}  //ALTERAR 
Return aRotina
