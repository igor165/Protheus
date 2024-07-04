#INCLUDE "MDTA830.ch"
#include "Protheus.ch"

#DEFINE _nVERSAO 2 //Versao do fonte

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MDTA830  � Autor � Jackson Machado       � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa para Confirmacao                                  ���
�������������������������������������������������������������������������Ĵ��
���Objetivo  � Este Programa confirma ou cancela ordens de Servico        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDTA830()

//��������������������������������������������Ŀ
//�Guarda conteudo e declara variaveis padroes �
//����������������������������������������������
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

If !NGCADICBASE("TBB_MODULO","A","TBB",.F.)
	If !NGCADICBASE("TJK_CODPLA","A","TJK",.F.)
		If !NGINCOMPDIC("UPDMDT38","TDGQ95")
			Return .F.
		Endif
	Endif

	Private aRotina := MenuDef()

	Private cCadastro := STR0001  //"Confirmacao do Plano de Simulacao"
	Private cORDEMTJR := Space(Len(TJR->TJR_CODORD))
	Private lMarca := .t.
	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	Dbselectarea("TJQ")
	Dbselectarea("TJQ")
	Dbseek(xFILIAL("TJQ"))
	SET FILTER TO  TJQ_SITUAC == "3"

	If Eof()
   	HELP("",1,"ARQVAZIO")
	Else
   	MBROWSE(6,1,22,75,"TJQ")
	Endif

	//��������������������������������������������������������������Ŀ
	//� Devolve a condicao original do arquivo principal             �
	//����������������������������������������������������������������
	Dbselectarea("TJQ")
	SET FILTER TO
	Dbsetorder(1)

	Dbselectarea("TJQ")
	Dbsetorder(1)
	Dbseek(xFILIAL("TJQ"))

Else

	SGAA250()

Endif

//��������������������������������������������Ŀ
//�Retorna conteudo de variaveis padroes       �
//����������������������������������������������
NGRETURNPRM(aNGBEGINPRM)
Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A830Total � Autor � Jackson Machado      � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Confirmacao total do plano                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MDTA830()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A830Total(cALIAS,nREG,nOPCX)
Local aArea := GetArea()

RecLock("TJQ",.f.)
TJQ->TJQ_SITUAC := "2"
MsUnLock("TJQ")

Dbselectarea("TJR")
Dbsetorder(2)
Dbseek(xFILIAL("TJR")+TJQ->TJQ_CODPLA)
While !Eof() .And. TJR->TJR_FILIAL == xFILIAL("TJR") .And.;
		TJR->TJR_CODPLA == TJQ->TJQ_CODPLA

		RecLock("TJR",.f.)
		TJR->TJR_SITUAC := "3"
		MsUnLock("TJR")
		TJR->(Dbskip())
End
RestArea(aArea)

Return NIL

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A830Parc  � Autor � Jackson Machado      � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para montar MARKBROWSE para confirmarcao parcial    ���
���          � Teclando <ENTER> Marcar/Desmarca e <ESC> Sai               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MNTA340()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A830Parc(cAlias,nReg,nOpcx)
Local lInverte:= .f.
Local oTempTRB
Private cMarca  := GetMark()
aDbf := {}
Aadd(aDbf,{"TJR_OK"      , "C" ,02, 0 })
Aadd(aDbf,{"TJR_CODORD"  , "C" ,06, 0 })
Aadd(aDbf,{"TJR_CODPLA"  , "C" ,06, 0 })
Aadd(aDbf,{"TJR_DATPLA"  , "D" ,08, 0 })
Aadd(aDbf,{"TJR_DATINP"  , "D" ,08, 0 })
Aadd(aDbf,{"TJR_PLAEME"  , "C" ,06, 0 })
Aadd(aDbf,{"TJR_DESPLA"  , "C" ,30, 0 })

cTrbAlias := GetNextAlias()

oTempTRB := FWTemporaryTable():New( cTrbAlias, aDBF )
oTempTRB:AddIndex( "1", {"TJR_CODORD"} )
oTempTRB:AddIndex( "2", {"TJR_CODPLA"} )
oTempTRB:Create()

aTrb := {}
Aadd(aTrb,{"TJR_OK"     ,NIL," "    ,})
Aadd(aTrb,{"TJR_CODORD" ,NIL,STR0002,})  //"Ordem"
Aadd(aTrb,{"TJR_CODPLA" ,NIL,STR0003,})   //"Plano"
Aadd(aTrb,{"TJR_DATPLA" ,NIL,STR0004,})   //"Data Original"
Aadd(aTrb,{"TJR_DATINP" ,NIL,STR0005,})   //"Data Prevista Inicio"
Aadd(aTrb,{"TJR_PLAEME" ,NIL,STR0006,})   //"Plano Emergencial"
Aadd(aTrb,{"TJR_DESPLA" ,NIL,STR0007,})   //"Descricao"

Processa({ |lEnd| MDT830Trb(nOpcx) })

Private aRotina := {{STR0008  ,"MDT830AlVl", 0 , 1},;  //"Visualizar"
                    {STR0009,"MDT830AlDt", 0 , 4}}  //"Alterar Data"

OldRot := aClone(aRotina)

Dbselectarea(cTrbAlias)
DbGoTop()
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������

Dbselectarea(cTrbAlias)

MarkBrow((cTrbAlias),"TJR_OK","",aTrb,lInverte,cMarca,"MDT830Invert()",,,,"MDT830Mark()")

lMarcou := .f.
dbSelectArea(cTRBAlias)
dbGoTop()
While !Eof()
   If !Empty((cTrbAlias)->TJR_OK)
      lMarcou := .T.
      Exit
   Endif
   Dbselectarea(cTrbAlias)
   DbSkip()
End

If lMarcou
   Processa({|lEnd| MDT830Proc(cAlias,nReg,nOpcx)})
   EvalTrigger() // Processa Gatilhos
Endif

//��������������������������������������������������������������Ŀ
//� Devolve a condicao original do arquivo principal             �
//����������������������������������������������������������������

oTempTRB:Delete()
Dbselectarea("TJR")
Set Filter To
Dbsetorder(1)

aRotina := aClone(OldRot)
Return NIL

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT830Trb � Autor � Jackson Machado      � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega TRB                                                ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MNTA340()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT830Trb(nOpcx)

Dbselectarea("TJR")
Dbsetorder(2)
Dbseek(xFilial("TJR")+TJQ->TJQ_CODPLA)

ProcRegua(LastRec())
While !Eof() .And. TJR->TJR_CODPLA == TJQ->TJQ_CODPLA

	IncProc()
	If TJR->TJR_SITUAC != "2"
		Dbskip()
		Loop
	Endif

	DbSelectArea("TJK")
	DbSetOrder(1)
	DbSeek(xFilial("TJK")+TJR->TJR_PLAEME)
	Dbselectarea(cTrbAlias)
	DbAppend()

	(cTrbAlias)->TJR_CODORD  := TJR->TJR_CODORD
	(cTrbAlias)->TJR_CODPLA  := TJR->TJR_CODPLA
	(cTrbAlias)->TJR_DATPLA  := TJR->TJR_DATPLA
	(cTrbAlias)->TJR_DATINP  := TJR->TJR_DATINP
	(cTrbAlias)->TJR_PLAEME  := TJR->TJR_PLAEME
	(cTrbAlias)->TJR_DESPLA  := TJK->TJK_DESPLA

	Dbselectarea("TJR")
	Dbskip()
End
Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT830Invert Autor � Jackson Machado      � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inverter marcacoes                                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MNTA340()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT830Invert()
Local nReg := (cTrbAlias)->(Recno())

Dbselectarea(cTrbAlias)
Dbgotop()
While !Eof()
   (cTrbAlias)->TJR_OK := IIf(TJR_OK == "  ",cMarca,"  ")
   Dbskip()
End

(cTrbAlias)->(Dbgoto(nReg))
lRefresh := .t.
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT830AlVl � Autor � Jackson Machado      � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Fun��o para visualizacao padrao do registro                ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MNTA340()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT830AlVl(cAlias,nReg,nOpcx)
Local aArea := GetArea()

Dbselectarea("TJR")
Dbsetorder(1)
If Dbseek(xFILIAL("TJR")+(cTrbAlias)->TJR_CODORD+(cTrbAlias)->TJR_CODPLA)
   NGCAD01("TJR",Recno(),2)
Endif

Dbselectarea(cTrbAlias)
RestArea(aArea)
Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT830AlDt � Autor � Jackson Machado      � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para alterar a data da Ordem do Plano de Simulacao. ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MDTA830()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT830AlDt(cAlias,nReg,nOpcx)
Local oMenu
nOpca := 0
dDtInp := (cTrbAlias)->TJR_DATINP

Define MsDialog oDlg5 Title OemToAnsi(STR0010)+STR0011+(cTrbAlias)->TJR_CODORD From 15,25 To 23,90 Of oMainWnd   //"Altera a Data Prevista"###"  O.S. "

@ 20.5,10 Say OemToAnsi(STR0012) Size 37,7 OF oDLG5 PIXEL   //"Data..:"
@ 20,30   MSGET dDtInp SIZE 45,10 OF oDLG5 PIXEL PICTURE "99/99/99" HASBUTTON

NGPOPUP(aSMenu,@oMenu)
oDlg5:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oDlg5)}
Activate MsDialog oDlg5 On Init EnchoiceBar(oDlg5,{||nOpca:=1,oDlg5:End()},{||oDlg5:End()})

If nOpca = 1
   (cTrbAlias)->TJR_DATINP := dDtInp
   MsUnLock(cTrbAlias)
   Dbselectarea("TJR")
	Dbsetorder(1)
	If Dbseek(xFILIAL("TJR")+(cTrbAlias)->TJR_CODORD+(cTrbAlias)->TJR_CODPLA)
		RecLock("TJR",.f.)
		TJR->TJR_DATINP := dDtInp
		MsUnLock("TJR")
	EndIf
Endif

Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT830Proc� Autor � Jackson Machado      � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Fun��o para alteracao da tabela TJR com os reg. marcados   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MNTA340()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT830Proc()
Local nCntSit := 0

Dbselectarea(cTrbAlias)
Dbgotop()

ProcRegua(LastRec())

While !Eof()

   IncProc()
   lCont := If((lMarca .And. !Empty(TJR_OK)) .Or. (!lMarca .And. Empty(TJR_OK)),.t.,.f.)

   If lCont

		Dbselectarea("TJR")
		Dbsetorder(1)
		Dbseek(xFilial("TJR")+(cTrbAlias)->TJR_CODORD)

		RecLock("TJR",.f.)
		TJR->TJR_SITUAC := "3"
		MsUnLock("TJR")

	EndIf
	DbSelectArea(cTrbAlias)
	Dbskip()
End

Dbselectarea("TJR")
Dbsetorder(2)
Dbseek(xFILIAL("TJR")+TJQ->TJQ_CODPLA)
While !Eof() .And. TJR->TJR_FILIAL == xFILIAL("TJR") .And.;
			TJR->TJR_CODPLA == TJQ->TJQ_CODPLA
	If TJR->TJR_SITUAC == "2"
		nCntSit++
	EndIf
   DbSkip()
End

If nCntSit = 0
	RecLock("TJQ",.f.)
	TJQ->TJQ_SITUAC := "2"
	MsUnLock("TJQ")
EndIf

Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A830Cancel� Autor � Jackson Machado       � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para cancelar a confirmacao do plano de Simulacao.   ���
�������������������������������������������������������������������������Ĵ��
���Tabelas   �TJQ - Plano de Simulacao                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaMDT                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A830Cancel()
	If MsgYesNo(STR0013) //"Deseja mesmo cancelar o Plano de Simula��o atual?"
		RecLock("TJQ",.f.)
		TJQ->TJQ_SITUAC := "1"
		MsUnLock("TJQ")
	EndIf
Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Jackson Machado       � Data �02/06/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Utilizacao de Menu Funcional.                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaMDT                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina :=	{{STR0014,"AxPesqui" , 0 , 1}   ,;  //"Pesquisar"
                   {STR0015,"A830Total", 0 , 4, 0},; 	 //"Total"
                   {STR0016,"A830Parc", 0 , 4, 0},; 	 //"Individual"
						 {STR0017,"A830Cancel", 0 , 4, 0}} //"Cancelar"

Return aRotina

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT830Mark � Autor � Jackson Machado      � Data �08/03/2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para marcar op��o do MARKBROWSE                     ���
���          � Teclando <ENTER> Marcar/Desmarca e <ESC> Sai               ���
���          � (Necess�ria a cria��o da fun��o pois com a marca��o padr�o ���
���          � estava se perdendo no TRB)                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MDTA830()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT830Mark()
Local nReg := (cTrbAlias)->(Recno())

dbSelectArea(cTrbAlias)
(cTrbAlias)->(Dbgoto(nReg))
RecLock(cTrbAlias,.F.)
(cTrbAlias)->TJR_OK := IIf(Empty((cTrbAlias)->TJR_OK),cMarca,"  ")
MsUnlock(cTrbAlias)

(cTrbAlias)->(Dbgoto(nReg))
lRefresh := .t.
Return .T.