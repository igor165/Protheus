#Include "QIEC060.CH"
#include "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Qiec060  � Autor � Vera Lucia S. Simoes  � Data � 12/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consultas - Entradas com Liberacao Urgente                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Qiec060                                                    ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Vera        �18/02/00�------� Filtra Entradas pela Filial tambem       ���
���Paulo Emidio�17/05/00�------� Retirada da funcao para Ajuste do SX1    ���
���Paulo Emidio�24/01/01�------� Correcao na abertura dos indices tempora ���
���			   �	    �	   � rio atraves da funcao IndRegua.		  ���
���Paulo Emidio�11/06/01�META  � Incluida a opcao par selecionar o tipo de���
���       	   �		�	   � Entrada a ser considera,se a mesma sera: ���
���       	   �		�	   � 1)Normal 2)Beneficiamento 3)Devolucao 	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef()

Local aRotina := {{OemToAnsi(STR0001),"AxPesqui"	, 0, 1},; //"Pesquisar"
				 {OemToAnsi(STR0002),"QEC060IMP",0, 1}}  //"Imprimir"
				 
Return aRotina

Function QIEC060
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local cFiltro := ""

Private Inclui:= .T.

//��������������������������������������������������������������Ŀ
//� Recupera o desenho padrao de atualizacoes                    �
//����������������������������������������������������������������
cCadastro := OemToAnsi(STR0003)		//"Entradas com Liberacao Urgente"

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
Private aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������

Pergunte("QEC060",.F.) 

If !(Pergunte("QEC060",.T.))
	Return
EndIf

//����������������������������������������������������������Ŀ
//� Realiza o filtro das Entradas com Liberacao Urgente		 �
//������������������������������������������������������������
cFiltro += 'QEK_FILIAL == "'+xFilial("QEK")+'"'+'.And.'
If mv_par03 == 1
	cFiltro += '(QEK_TIPONF == " " .Or. QEK_TIPONF == "N")'
ElseIf mv_par03 == 2                                  
	cFiltro += 'QEK_TIPONF == "B"'
ElseIf mv_par03 == 3            
	cFiltro += 'QEK_TIPONF == "D"'
EndIf
cFiltro += '.And. Dtos(QEK_DTENTR) >= "'+Dtos(mv_par01)+'"'
cFiltro += '.And.Dtos(QEK_DTENTR) <= "'+Dtos(mv_par02)+'"'            

cFiltro += '.And. QEK_PRODUT >= "'+mv_par04+'"'                         
cFiltro += '.And. QEK_PRODUT <= "'+mv_par05+'"'                         

cFiltro += '.And. QEK_FORNEC+QEK_LOJFOR >= "'+mv_par07+mv_par07+'"'                         
cFiltro += '.And. QEK_FORNEC+QEK_LOJFOR <= "'+mv_par08+mv_par09+'"'   

cFiltro += '.And. QEK_SITENT == "4"'

If ExistBlock("QEC60FIL") 
	cFiltro := ExecBlock("QEC60FIL",.F.,.F.,{cFiltro}) 
EndIF

dbSelectArea("QEK")
dbSetOrder(2)                                      
MsgRun(STR0015,STR0016,{||dbSetFilter({||&cFiltro},cFiltro)}) //"Selecionando as Entradas..."###"Aguarde..."

dbGoTop()
If Eof()
	Help(" ",1,"RECNO")  
Else
	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	mBrowse( 6, 1,22,75,"QEK" )
EndIf    
       
dbSelectArea("QEK") 
Set Filter To

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QEC060IMP� Autor � Vera Lucia S. Simoes  � Data � 17/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a impressao da consulta obtida                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEC060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QEC060IMP()
LOCAL cTitulo		:= OemToAnsi(STR0005)		//"ENTRADAS COM LIBERACAO URGENTE"
LOCAL cDesc1		:= OemToAnsi(STR0006)		//"Este programa ira imprimir a Consulta das Entradas"
LOCAL cDesc2		:= OemToAnsi(STR0007)		//"Inspecionadas, que tenham laudo com Categoria "
LOCAL cDesc3		:= OemToAnsi(STR0008)		//"Liberado Urgente. "
LOCAL wnrel			:= "QIEC060"
LOCAL cString		:= "QEL"

PRIVATE cPerg		:= "  "
PRIVATE aReturn		:= { OemToAnsi(STR0009), 1,OemToAnsi(STR0010), 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nLastKey	:= 0
PRIVATE cTamanho	:= "M"

wnrel:= SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho,,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| QEC060Im(@lEnd,ctitulo,wnRel)},ctitulo)
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QEC060Im � Autor � Marcelo Pimentel      � Data � 06/05/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia para funcao que faz a impressao da consulta.         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEC060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function QEC060Im(lEnd,ctitulo,wnRel)
Local aAreas	:={QE6->(GetArea()), QEK->(GetArea()), QEL->(GetArea()), SA2->(GetArea())}
Local cbcont    := 0
Local cbTxt     := SPACE(10)
Local cCabec1   := ""
Local cNomeProg := "QIEC060"
Local cSeek     := ""
Local nTipo     := 15

cCabec1 := PADR(FwX3Titulo("QEK_FORNEC"),TAMSX3('A2_NREDUZ')[1]) + Space(1)   //Fornecedor
cCabec1 += PADR(FwX3Titulo("QEK_PRODUT"),TAMSX3('QE6_DESCPO')[1] - 9)         //Produto
cCabec1 += PADR(FwX3Titulo("QEK_DTENTR"),TAMSX3('QEK_DTENTR')[1]) + Space(4)  //Dt Entr.
cCabec1 += PADR(AllTrim(FwX3Titulo("QEK_LOTE"))+'/'+AllTrim(FwX3Titulo("QEK_DOCENT")),  TAMSX3('D1_LOTEFOR')[1]) + Space(2)  //Lote-Lote Fornec.
cCabec1 += FwX3Titulo("QEK_VERIFI")  + Space(2)                               // I/C
cCabec1 += PADR(FwX3Titulo("QEK_PEDIDO"),TAMSX3('QEK_PEDIDO')[1]) + Space(4) //No. Pedido
cCabec1 += FwX3Titulo("QEK_TAMLOT") + Space(1)
cCabec1 += FwX3Titulo("QEL_LAUDO") + Space(4)


Li    := 80
m_pag := 1
dbSelectArea("QEK")
QEK->(dbGoTop())
SetRegua(RecCount()) //Total de Elementos da Regua
While QEK->(!Eof())

	QEL->(dbSetOrder(3))
	cSeek := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+DTOS(QEK_DTENTR)+QEK_LOTE)

	If	QEL->(dbSeek(xFilial("QEL")+cSeek+Space(TamSx3("QEL_LABOR")[1])))
		// Verifica se o Laudo tem categoria Liberado Urgente
		If QIEXLdLU(QEL->QEL_LAUDO)

			IncRegua()
			If Li > 58
				Cabec(cTitulo,cCabec1,"",cNomeProg,cTamanho,nTipo,,.F.)
			EndIf

			@Li,000 PSAY QEK->(QEK_FORNEC	+ " - " + QEK->QEK_LOJFOR)
			@Li,021 PSAY QEK->QEK_PRODUT
			@Li,052 PSAY QEK->QEK_DTENTR
			@Li,064 PSAY QEK->QEK_LOTE
			@Li,085 PSAY IIF(QEK->QEK_VERIFI == 1,STR0012,STR0013)		//"Ins"###"Cer"
			@Li,098 PSAY QEK->QEK_PEDIDO
			@Li,113 PSAY QEK->QEK_TAMLOT
			@Li,127 PSAY QEL->QEL_LAUDO
			
			Li++

			SA2->(dbSetOrder(1))
			If SA2->(dbSeek(xFilial("SA2")+QEK->(QEK_FORNEC+QEK_LOJFOR)))
				@Li,000 PSAY SA2->A2_NREDUZ
			EndIf
			QE6->(dbSetOrder(1))
			If QE6->(dbSeek(xFilial("QE6")+QEK->QEK_PRODUT))
				@Li,021 PSAY QE6->QE6_DESCPO
			EndIf
			@Li,064 PSAY QEK->QEK_DOCENT
			Li+=2
		EndIf
	EndIf
	QEK->(dbSkip())
EndDo

If Li != 80
	Roda(cbcont,cbtxt)
EndIf

Set Device To Screen

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	ourSpool(wnrel)
EndIf
MS_FLUSH()
QEK->(dbGoTop())
aEval(aAreas, {|x| RestArea(x)})
Return .T.
