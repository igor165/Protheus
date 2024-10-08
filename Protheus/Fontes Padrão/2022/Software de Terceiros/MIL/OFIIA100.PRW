#include "ofiia100.ch"
#include "Protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIIA100 � Autor � Emilton               � Data � 11/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Importacao da Tabela de Fornecedores para Garantia         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Integracao montadora                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIIA100

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0004)   //Importacao da Tabela de Fornecedores p/Garantia
Private cCodMar  && Variavel criada para nao ter conflito com a segunda pergunte
Private lMsErroAuto := .f.

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������

If !Pergunte("OFIMAR",.t.)
   Return
EndIf

cCodMar := MV_PAR01
                          
DbSelectArea("VIH")
DbSetOrder( 1 )
cIndVIH := CriaTrab(Nil, .F.)
IndRegua("VIH",cIndVIH,IndexKey(),,"VIH_CODMAR == cCodMar",OemToAnsi(STR0004) )
                    
mBrowse( 6, 1,22,75,"VIH")

DbSelectArea("VIH")
RetIndex()

#IFNDEF TOP
   If File(cIndVIH+OrdBagExt())
      fErase(cIndVIH+OrdBagExt())
   Endif
#ENDIF

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �IA100I    � Autor � Emilton               � Data � 20/07/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chama a funcao de gravacao de integracao de pedido da mon  ���
���          � tadora                                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �IA100I(CLIAS,NREG,NOPC)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PECAS                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function IA100I(cAlias,nReg,nOpc)

If xFilial("VIH") != VIH->VIH_FILIAL .or. (VIH->(EOF()) .and. VIH->(BOF()))
   Help(" ",1,"ARQVAZIO")
   Return .f.
Endif                        

// Help(" ",1,"VFIMPMOD")

dbSelectArea("VIH")
dbSeek( xFilial("VIH") + cCodMar )

dbSelectArea("VE4")
dbSetOrder(1)
dbSeek( xFilial("VE4") + cCodMar )

Processa( {|| FS_INTVIH()} )

return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_INTVIH � Autor � Emilton               � Data � 20/07/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao dos dados do arquivo Fornecedores p/Garantia      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Integracao montadora                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_INTVIH()

Local ixi    := 0
Local _CDFOR := Space(03)
Local _DESFO := Space(30)

Local nRegTrans := 0

DbSelectArea("VIH")                                                                           
dbSeek( xFilial("VIH") )

Begin Transaction

   While xFilial("VIH") == VIH->VIH_FILIAL .and. VIH->VIH_CODMAR == cCodMar .and. !Eof()

      For ixi := 1 to 5

         _FORNE := "VIH->VIH_CDFOR"+Str(ixi,1)
         _NOFOR := "VIH->VIH_DESFO"+Str(ixi,1)

         If Empty(&_FORNE)
            Loop
         EndIf

         dbSelectArea("VG7")
         dbSetOrder(1)
         dbSeek( xFilial("VG7")+cCodMar+&_FORNE)

         RecLock("VG7", !Found() )
         VG7_FILIAL := xFilial("VG7")
         VG7_CODMAR := cCodMar
         VG7_CODFOR := &_FORNE
         VG7_NOMFOR := &_NOFOR

      Next

      DbSelectArea("VIH")
      DbSkip()

   EndDo

End Transaction

FS_DELIAX100()

If lMsErroAuto
   MostraErro()
EndIf   

return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �IA100V    � Autor � Emilton               � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � visualiza os dados dos arquivos VIH                        ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � AxVisual(cAlias,nReg,nOpc,aCampos)                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function IA100V(cAlias,nReg,nOpc)

Private aCampos := {}

CPOIA100()
AxVisual(cAlias,nReg,nOpc,aCampos)

return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CPOIA100  � Autor � Emilton               � Data � 01/06/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Pega os campos no SX3 para serem mostrados na visualizacao  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � CPOIA100()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � integracao                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CPOIA100()

DbSelectArea("SX3")
dbgotop()
dbseek("VIH")
aCampos := {}

While !eof() .and. x3_arquivo == "VIH"

   If X3USO(x3_usado) .And. cNivel>=x3_nivel
      aadd(aCampos,x3_campo)
   EndIf
   
   dbSkip()
   
EndDo

DbSelectArea("VIH")

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_DELIAX100 Autor � Emilton               � Data � 01/06/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Apaga os dados do arquivo VID                              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FS_DELIAX00()                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � integracao                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_DELIAX100()

dbselectarea("VIH")
dbgotop()
IF Ma280Flock("VIH")
   DbClearInd()
   OpenIndx("VIH",.F.)
   delete all for VIH->VIH_CODMAR == cCodMar
   pack
//   reindex
   DbCloseArea()
Endif

ChkFile("VIH",.F.)

return

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},;	//Pesquisar
                     { STR0002 ,"IA100V", 0 , 2},;	//Visualizar
                     { STR0003 ,"IA100I", 0 , 3}} 	//Importar
Return aRotina
