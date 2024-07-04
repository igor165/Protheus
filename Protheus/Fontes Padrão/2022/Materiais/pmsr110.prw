#INCLUDE "pmsr110.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PMSR110   � Autor � Wagner Mobile Costa   � Data � 30.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do cronograma realizado x previsto                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ��� 
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PMSR110()
//������������������������������������������������������������������������Ŀ
//�Define Variaveis                                                        �
//��������������������������������������������������������������������������
Local cDesc1   := STR0001 //"Este relatorio ira imprimir o cronograma "
Local cDesc2   := STR0002 //"dos projeto(s)  conforme  os  parametros "
Local cDesc3   := STR0003 //"solicitados."
Local cString  := "AF8"
Local lDic     := .F.
Local lComp    := .T.
Local lFiltro  := .T.
Local wnrel    := "PMSR110"

Private nomeprog 	:= "PMSR110"
Private Cabec1 		:= ""
Private Cabec2 		:= ""
Private aVarRel 	:= Array(3)

//������������������������������������������������������������������������Ŀ
//� Caso ultrapasse, utiliza o tamanho grande de Lay-Out                   �
//��������������������������������������������������������������������������
Private Titulo   := STR0004 //"Cronograma fisico - Realizado"
Private Tamanho := "G"   // P/M/G
Private Limite  := 220 // 80/132/220
Private nli     := 100 // Contador de Linhas
Private aOrdem  := {}  // Ordem do Relatorio
Private cPerg   := "PMR070"  // Pergunta do Relatorio
Private aReturn := { STR0005, 1,STR0006, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
						//[1] Reservado para Formulario
						//[2] Reservado para N� de Vias
						//[3] Destinatario
						//[4] Formato => 1-Comprimido 2-Normal
						//[5] Midia   => 1-Disco 2-Impressora
						//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
						//[7] Expressao do Filtro
						//[8] Ordem a ser selecionada
						//[9]..[10]..[n] Campos a Processar (se houver)

Private lEnd    	:= .F.// Controle de cancelamento do relatorio
Private m_pag   	:= 1  // Contador de Paginas
Private nLastKey	:= 0  // Controla o cancelamento da SetPrint e SetDefault

If PMSBLKINT()
	Return Nil
EndIf

//������������������������������������������������������������������������Ŀ
//�Verifica as Perguntas Seleciondas                                       �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//� PARAMETROS                                                             �
//� MV_PAR01 : Projeto   de ?                                              �
//� MV_PAR02 : Ate?                                                        �
//� MV_PAR03 : Data projeto de                                    		   �
//� MV_PAR04 : Data projeto ate                                   		   �
//� MV_PAR05 : Versao ?		Branco = Todas, 1-2;3-3;5-5                    �
//� MV_PAR06 : Nivel ?                                                     �
//� MV_PAR07 : Fase ?                                                      �
//� MV_PAR08 : Data PREVISTO de                                            �
//� MV_PAR09 : Data PREVISTO ate                                           �
//��������������������������������������������������������������������������
Pergunte(cPerg,.F.)
//������������������������������������������������������������������������Ŀ
//�Envia para a SetPrint                                                   �
//��������������������������������������������������������������������������
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)

If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter() //Set Filter to
	Return
Endif
SetDefault(aReturn,cString)

If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter() //Set Filter to
	Return
Endif
If Empty(mv_par08) .And. Empty(mv_par09)
	dbSelectArea("AF8")
	dbSeek(xFilial()+mv_par01,.T.)
	mv_par08 := AF8->AF8_START
	mv_par09 := AF8->AF8_FINISH
	While !Eof() .And. AF8->AF8_PROJET <= mv_par02
		If AF8->AF8_DATA > mv_par04 .Or. AF8->AF8_DATA < mv_par03 .Or.;
			AF8->AF8_CLIENT > mv_par12 .Or. AF8->AF8_CLIENT < mv_par10 .Or.;
			AF8->AF8_LOJA > mv_par13 .or. AF8->AF8_LOJA < mv_par11 .Or.;
			!PmrPertence(AF8->AF8_FASE,mv_par07)
			AF8->(dbSkip())
			Loop
		EndIf
		mv_par08 := Min(mv_par08,AF8->AF8_START)
    	If !Empty(AF8->AF8_DTATUI)
			mv_par08 := Min(mv_par08,AF8->AF8_DTATUI)
		EndIf
		mv_par09 := Max(mv_par09,AF8->AF8_FINISH)
    	If !Empty(AF8->AF8_DTATUF)
			mv_par09 := Max(mv_par09,AF8->AF8_DTATUF)
		EndIf
		AF8->(dbSkip())		
	End
EndIf

PmrAddPropO("PROPRIEDADESIMPRESSAO",,;
			{ 	{ "CRONOGRAMAFISICO:PREVISTO", 000 },;
				{ "CRONOGRAMAFISICO:REALIZADO", 000 } })
PmrAddPropO("LIMITEPREVISTO",, mv_par09)
PmrAddPropO("ROTINADETALHE",, "PMRPer070")
PmrAddPropO("TODA_MATRIZ_PROJETO",, .T.)
PmrAddPropO("ESTRUTURA_PROJETO",, {})
PmrAddPropO("IMPRIME_RODAPE",, STR0008) //"Projetos impressos"
PmrAddPropO("FILTRO_CLIENTE",,{||AF1->AF1_CLIENTE  >= mv_par10 .and. AF1->AF1_LOJA >= mv_par11 .and. ;
								AF1->AF1_CLIENTE <= mv_par12 .and. AF1->AF1_lOJA <= mv_par13 } )
RptStatus({|lEnd| PMRSelReg(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)

Return(.T.)