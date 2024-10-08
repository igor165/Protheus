#include "Ofigm020.ch" 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIGM020 � Autor �  Renata               � Data � 01/09/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao na Garantia Cupom de Revisao VW                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Garantia                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIGM020

PRIVATE aCampos := {}

Private aRotina := MenuDef()
                      
Private bGM020FiltraBrw, cCondGM020, aIndVGA := {}

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemToAnsi(STR0004)   // //"Garantia Cupom Revisao"
Private cMarca

M->VGA_CHASSI := Space(27)

cMarca := GetMark()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������

DbSelectArea("VGA")
RetIndex()
DbSetOrder(1)
cCondGM020 := 'VGA_ESPGAR=="R".and.VGA_IMPOSV=="S".and.VGA_EXPGAR="S"'
aIndVGA    := {}
bGM020FiltraBrw := {|| FilBrowse("VGA",@aIndVGA,@cCondGM020) }
Eval(bGM020FiltraBrw)

DbSelectArea("SXB")
DbSetOrder(1)
If SXB->(DbSeek( "VG2   " + "6" ))
   RecLock("SXB",.F.)
   SXB->XB_CONTEM := 'VG2->VG2_CODMAR==M->VGA_CODMAR'
   MsUnLock()
Endif

//mBrowse( 6, 1,22,75,"VGA",,,,"VGA_ESPGAR=='R' .and. VGA_IMPOSV=='S' .And. VGA_TRANSM == 'N' .and.VGA_EXPGAR='S'")
Markbrow("VGA","VGA_OK", "VGA_ESPGAR # 'R' .Or. VGA_IMPOSV # 'S' .Or. VGA_TRANSM # 'N' .Or. VGA_EXPGAR # 'S'" ,,,cMarca)

//Retira o Filtro da Ordem de Servicos, selecionando a ordem principal
dbSelectArea("VGA")
RetIndex()
dbClearFilter()
aEval(aIndVGA,{|x| Ferase(x[1]+OrdBagExt())})
dbSetOrder(1)

Return
  

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GM020V    � Autor �Renata                 � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Visualiza dados no VGA/VG5 referente a cupom  revisao      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GM020(cAlias,nReg,nOpc)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � garantia                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function GM020V(cAlias,nReg,nOpc)

Private lRefresh := .t.

M->VGA_CHASSI := CRIAVAR("VGA_CHASSI",.F.)

IF VGA_ESPGAR=='R' .and. VGA_IMPOSV=='S'
	Inclui := .f.
	Altera := .f.
	M->VGA_CHASSI := Posicione("VV1",1,xFilial("VV1")+VGA->VGA_CHAINT,"VV1_CHASSI")
   CPOM020()
   AxVisual(cAlias,nReg,nOpc,aCampos)
Else
   Help(" ",1,"OFIGM02001") 

Endif                                                                 

DbSelectArea("VGA") 
Eval(bGM020FiltraBrw)

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GM020I    � Autor �Fabio                  � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inclui dados no VGA/VG5 referente a cupom  revisao         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � garantia                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GM020I(cAlias,nReg,nOpc)
               
Private lRefresh := .t.

Inclui := .t.
Altera := .f.

M->VGA_CHASSI := CRIAVAR("VGA_CHASSI",.F.)
CPOM020()
If AxInclui(cAlias,nReg,nOpc,aCampos) == 1
		                 
  DbSelectArea("VV1")
  DbSetOrder(2)
  DbSeek(xFilial("VV1")+M->VGA_CHASSI)
  DbSelectArea("VGA")
	RecLock("VGA",.f.)
	VGA->VGA_ESPGAR := "R"
	VGA->VGA_IMPOSV := "S"
	VGA->VGA_EXPGAR := "S"
   VGA->VGA_TRANSM := "N"
   VGA->VGA_CHAINT := VV1->VV1_CHAINT
   MsUnLock()
	   
EndIf   

DbSelectArea("VGA") 
Eval(bGM020FiltraBrw)

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GM020A    � Autor �Renata                 � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Altera dados no VGA/VG5 referente a cupom  revisao         ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GM020A(cAlias,nReg,nOpc)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � garantia                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GM020A(cAlias,nReg,nOpc)

Private lRefresh := .t.


If VGA_ESPGAR=='R' .and. VGA_IMPOSV=='S'
	Inclui := .f.
	Altera := .t.
	M->VGA_CHASSI := Posicione("VV1",1,xFilial("VV1")+VGA->VGA_CHAINT,"VV1_CHASSI")
	
   CPOM020()
   If AxAltera(cAlias,nReg,nOpc,aCampos) == 1
		RecLock("VGA",.f.)
	   VGA->VGA_TRANSM := "N"
	   MsUnLock()   
	EndIf   
Else
   Help(" ",1,"OFIGM02001") 
Endif   

DbSelectArea("VGA") 
Eval(bGM020FiltraBrw)

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CPOM020   � Autor �Renata                 � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pega os campos do VGA no SX3                               ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �CPOM020()                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � garantia                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CPOM020()

DbSelectArea("SX3")
DbSeek("VGA")
aCampos := {}

Do While !eof() .and. x3_arquivo == "VGA"

   If X3USO(x3_usado) .And. cNivel>=x3_nivel .And.!( Alltrim(x3_campo) $ [VGA_ESPGAR/VGA_RECONS/VGA_CODGAR/VGA_DESGAR/VGA_NFIPEC/VGA_NFISER/VGA_SERNFI/VGA_AUTFAB/VGA_RESER1/VGA_RESER2/VGA_RESER3/VGA_RESER4/VGA_VALPEC/VGA_VALTPO/VGA_TEMPAD/VGA_NUMNFI/VGA_SERIEN/VGA_IMPOSV/VGA_DATTRA/VGA_ARQFAB/VGA_DATRET/VGA_SITUAC/VGA_DATCRE/VGA_VALCRE/VGA_LANCRE/VGA_DATDEB/VGA_VALDEB/VGA_LANDEB/VGA_CODEST/VGA_DIFPGT/VGA_EXPGAR/VGA_TRANSM] )
   
      aadd(aCampos,x3_campo)
   
   Endif

   DbSkip()

Enddo

DbSelectArea("VGA")

Return   

Function FS_TESTE()

if VG2->VG2_CODMAR==POSICIONE("VV1",1,xFilial("VV1")+VGA->VGA_CHAINT,"VV1_CODMAR")
 
    Return(.T.)
    
Endif  

Return(.f.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GM020E    �Autor  �Fabio               � Data �  11/22/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Expora para o arquivo intermediario                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GM020E()
      
Local nRecVGA := VGA->(Recno())

&& Chama processo de exportacao
OFIIA060(cMarca,3)
      
DbSelectArea("VGA")
RetIndex()
DbSetOrder(1)
Eval(bGM020FiltraBrw)
             
DbGoTo(nRecVGA)

Return

Static Function MenuDef()
Local aRotina := {{STR0001    ,"axPesqui", 0, 1},;  //Pesquisar
                    {STR0002  ,"GM020V"  , 0, 2},;  //Visualizar
                    {STR0006  ,"GM020I"  , 0, 3},;  //Incluir
                    {STR0003 ,"GM020A"  , 0 , 4},;	//Alterar
                    {STR0007 ,"GM020E"  , 0 , 2}}   //"Exportar"
Return aRotina
