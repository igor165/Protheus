//#include "FiveWin.ch" 
#include "AVERAGE.CH"
#include  "EICC010.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � EIC010   � Autor � Gilson Nascimento     � Data � 28/08/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Desembaraco - Consulta de Documento                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void eicc010(void)                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAEIC                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function EICC010
PRIVATE aRotina := MenuDef()

PRIVATE cCadastro := OemtoAnsi(STR0003) //"Consulta Documento"
mBrowse( 6, 1,22,75,"SYB")
Return 


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 26/01/07 - 14:28
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := { {STR0001,"AxPesqui", 0 , 1},;  //"Pesquisar"
                    { STR0002,"C010Cons", 0 , 2} }   //"Consultar"
                    
// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("IC010MNU")
	aRotAdic := ExecBlock("IC010MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C010Cons  � Autor � Gilson Nascimento     � Data �28/08/96  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de visualizacao de uma solicitacao de compra      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void C010Cons(ExpC1,ExpN1,ExpN2)                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAEIC                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function C010Cons(cAlias,nReg,nOpcx)
LOCAL bCampo,nCnt,nSavRec
LOCAL GetList:={},cDocto:=Space(10)
LOCAL oDlg, oGet
//��������������������������������������������������������������Ŀ
//� Verifica se existe algum dado no arquivo                     �
//����������������������������������������������������������������
dbSelectArea( cAlias )
dbSetOrder(1)
If EasyRecCount() == 0
   Return .T.
Endif

//��������������������������������������������������������������Ŀ
//� Verifica se esta' na filial correta                          �
//����������������������������������������������������������������
If xFilial("SYB") != SYB->YB_FILIAL
   Help(" ",1,"A000FI")
   Return .T.
Endif

//��������������������������������������������������������������Ŀ
//� Consiste a existencia de Declaracoes para esta Despesa       �
//����������������������������������������������������������������
dbSelectArea('SWD')
dbSetOrder(3)
SWD->(dbSeek(xFilial()+SYB->YB_DESP))
If Eof()
   HELP(" ",1,"EICNODECL")
   dbSelectARea(cAlias)
   Return .T.
Endif

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aHeader[0],nUsado:=0

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aCampos:={"WD_DOCTO","WD_HAWB","W6_DESP","Y5_NOME","W6_REF_DES","W6_FAT_DES","W7_PO_NUM","WD_VALOR_R","WD_DES_ADI"}

//bHotArea := {|| HotAreas(10, 4,17,75,nUsado)}
//bCampo := {|nCPO| Field(nCPO) }
dbSelectArea(cAlias)

//������������������������������������������������������Ŀ
//� Cria WorkFile para GetDadDB()                        �
//��������������������������������������������������������
cNomArq := E_CriaTrab()
///cDocto  := SWD->WD_DOCTO  LCS.15/08/2008
cDOCTO := SPACE(LEN(SWD->WD_DOCTO))  //LCS.15/08/2008
MSAGUARDE({|| C010GRAVATRB(cDOCTO)},STR0007)  //"Pesquisando Documentos..."  //LCS.15/08/2008
DO WHILE .T.

   dbSelectArea("TRB")
   dbGoTop()
   nOpca := 0
   DEFINE MSDIALOG oDlg TITLE STR0004 From 9,0 To 28,80 OF oMainWnd  //"Despesas"

     TRB->(oGet := MSGetDB():New(34,5,128,315,nOpcx,"E_LinOk","E_TudOk","",.F., , ,.F., ,"TRB"))
     oGet:oBrowse:bwhen:={||(dbSelectArea("TRB"),.t.)}

     @ 1.4 ,0.8 SAY OemToAnsi(STR0005)  //"Despesa"
     @ 1.4 ,005 MSGET SYB->YB_DESP  When .F.
     @ 1.4 ,010 MSGET SYB->YB_DESCR When .F. SIZE 100,10
     @ 1.4 ,025 SAY OemToAnsi(STR0006)  //"Documento"
     //@ 1.4 ,030 MSGET cDocto F3 "WD1" SIZE 40,10 VALID ( IF(!EMPTY(cDocto),c010GravaTRB(cDocto),), cDocto:=SWD->WD_DOCTO,oGet:Hide(),oGet:Refresh() )
     @ 1.4 ,030 MSGET cDocto F3 "WD1" SIZE 40,10 VALID ( IF(!EMPTY(cDocto),(nOpca:=1),.T.),.T. )
   
   ACTIVATE MSDIALOG oDlg ON INIT (oGet:oBrowse:Refresh(),EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||oDlg:End()})) CENTERED 
   

   IF nOpca == 1
      MsAguarde({||c010GravaTRB(cDocto)},STR0007)  //"Pesquisando Documentos..."
      LOOP
   ENDIF

   EXIT

ENDDO
TRB->(E_EraseArq(cNomArq))
dbSelectArea( cAlias )

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �c010GravaT� Autor � Gilson Nascimento     � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava o TRB para uso na GETDADB                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAEIC                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function c010GravaTRB(cDocto)
LOCAL cAliasAnt:=Alias()
dbSelectArea("TRB")
AvZap()
dbSelectArea("SWD")
dbSetOrder(3)
SWD->(dbSeek(xFilial()+SYB->YB_DESP+if(Empty(cDocto),'',cDocto)))

While !EOF() .and. WD_FILIAL==xFILIAL("SWD") .AND. WD_DESPESA==SYB->YB_DESP

   MsProcTxt(STR0008+ALLTRIM(SWD->WD_HAWB))  //"Lendo Processo: "
   // Filtra o Documento Valido
   If (!Empty(cDocto) .and. WD_DOCTO # cDocto)
      DBSkip()
      Loop
   Endif

   // Posiciona os Arquivos
   SW6->(DBSEEK(xFilial()+SWD->WD_HAWB))
   SW7->(DBSEEK(xFilial()+SWD->WD_HAWB))
   SY5->(DBSEEK(xFilial()+SW6->W6_DESP))

   // Grava os Dados	
   TRB->(DBAPPEND())
   TRB->WD_DOCTO  := SWD->WD_DOCTO
   TRB->WD_HAWB   := SWD->WD_HAWB
   TRB->W6_DESP   := SW6->W6_DESP
   TRB->Y5_NOME   := SY5->Y5_NOME
   TRB->W6_REF_DES:= SW6->W6_REF_DES
   TRB->W6_FAT_DES:= SW6->W6_FAT_DES
   TRB->W7_PO_NUM := SW7->W7_PO_NUM
   TRB->WD_VALOR_R:= SWD->WD_VALOR_R
   TRB->WD_DES_ADI:= SWD->WD_DES_ADI
   
   // Proximo Registro
   DBSkip()
   
Enddo

dbSelectArea("SWD")
dbSetOrder(1)
dbSelectArea(cAliasAnt)

Return .T.
