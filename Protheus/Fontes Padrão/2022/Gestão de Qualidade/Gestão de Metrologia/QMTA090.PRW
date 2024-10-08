#include "qmta090.ch"
#include "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QMTA090	� Autor � Wanderley Goncalves Jr� Data � 27/08/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Cadastro de Incertezas do Tipo "B"             ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 			          ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �	MOTIVO DA ALTERACAO		              ���
�������������������������������������������������������������������������Ĵ��
��� Denis Martins�12/12/00�Verif.�Correcao na gravacao da Filial(QMV).    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},;  // "Pesquisar" 
					{OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;  // "Visualizar"
					{OemToAnsi(STR0003),"A090IInc"  , 0 , 3},;  // "Incluir"   
					{OemToAnsi(STR0004),"A090IInc"  , 0 , 4},;  // "Alterar"   
					{OemToAnsi(STR0005),"A090DInc"  , 0 , 5,3}}  // "Excluir"

Return aRotina

Function QMTA090()

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes					 �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0006)  //"Incertezas do tipo 'B'"

Private aPos	:= {	15,  1, 130, 315 }

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa 	 �
//� ----------- Elementos contidos por dimensao ------------	 �
//� 1. Nome a aparecer no cabecalho 							 �
//� 2. Nome da Rotina associada									 �
//� 3. Usado pela rotina										 �
//� 4. Tipo de Transa��o a ser efetuada							 �
//�	 1 - Pesquisa e Posiciona em um Banco de Dados				 �
//�	 2 - Simplesmente Mostra os Campos							 �
//�	 3 - Inclui registros no Bancos de Dados					 �
//�	 4 - Altera o registro corrente								 �
//�	 5 - Remove o registro corrente do Banco de Dados			 �
//����������������������������������������������������������������
Private aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE									 �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QMV")

Set Key VK_F12 To 

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � A090IINC � Autor � Wanderley Goncalves Jr� Data � 01/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de inclusao/alteracao de Incertezas do Tipo "B"   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � A090IINC(ExpC1,ExpN1,ExpN2)								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo								      ���
���			 � ExpN1 = Numero do registro 								  ���
���			 � ExpN2 = Opcao selecionada								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QMTA090													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

FUNCTION A090IInc(cAlias,nReg,nOpc)
Local nOpcA:=0 //, aAC := { OemToAnsi(STR0007),OemToAnsi(STR0008) }	//"Abandona"###"Confirma" 
Local bCampo := { |nField| Field(nField) } 
Local oDlg
Local nCntFor:= 1
Local oSize
//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo							 �
//����������������������������������������������������������������
Private lWDistr := If(nOpc == 3,.T.,.F.)
Private aTELA[0][0],aGETS[0]


oSize := FwDefSize():New()
oSize:AddObject( "TELA" ,  100, 100, .T., .T. ) // Totalmente dimensionavel
oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

aPos	:= {	oSize:GetDimension("TELA","LININI"), oSize:GetDimension("TELA","COLINI"), ;
				(oSize:GetDimension("TELA","LINEND")-5), oSize:GetDimension("TELA","COLEND") }


While .T.
	
	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets		   �
	//����������������������������������������������
	nOpcA:=0
	dbSelectArea(cAlias)
	
	If nOpc == 3		// Inclusao
	
		dbselectArea("QMV")
		For nCntFor:= 1 To FCount()
			M->&(EVAL(bCampo,nCntFor)) := CriaVar(Eval(bCampo,nCntFor),.T.) 
		Next nCntFor
		
		
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
								TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL 
					nOpca:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009),,aPos)  //"Quanto � exclus�o?" 
			nOpca:= 1
			@ (oSize:GetDimension("TELA","LINEND") - 5 ), 05 Say OemToAnsi(STR0010) PIXEL // "Legenda: R -> Raiz Quadrada"
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,;
						Iif(Obrigatorio(aGets,aTela),oDlg:End(),nOpca:= 1)},;
						{||nOpca:=1,oDlg:End()})
		If nOpca == 2
			RecLock(cAlias,.t.)
			For nCntFor := 1 to fCount()
			    If Alltrim(FieldName(nCntFor)) != "QMV_FILIAL"
				   fieldPut(nCntFor,M->&(FieldName(nCntFor)))
				Else 
				   Replace QMV->QMV_FILIAL with xFilial("QMV")
				Endif   
			Next nCntFor
		EndIf
	ElseIf nOpc == 4	// Alteracao
		dbSelectArea("QMV")
		For nCntFor:= 1 To FCount()
			M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
		Next nCntFor

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
								TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
			nOpca:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009),,aPos,,3)  //"Quanto � exclus�o?" 
			nOpca:= 1
			@ (oSize:GetDimension("TELA","LINEND") - 5 ), 05 Say OemToAnsi(STR0010) PIXEL // "Legenda: R -> Raiz Quadrada"
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,;
							If(Obrigatorio(aGets,aTela),oDlg:End(),nOpca:= 1)},;
							{||nOpca:=1,oDlg:End()})

		If nOpca == 2
			RecLock(cAlias,.f.)
			For nCntFor := 1 to fCount()
			    If Alltrim(FieldName(nCntFor)) != "QMV_FILIAL" 			
				fieldPut(nCntFor,M->&(FieldName(nCntFor)))
				Else 
				   Replace QMV->QMV_FILIAL with xFilial("QMV")
				Endif   
			Next nCntFor
		EndIf
	EndIf
	Exit
EndDo

dbSelectArea(cAlias)

Return
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � A090DINC � Autor � Wanderley Goncalves Jr� Data � 27/08/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de exclusao de Incertezas do Tipo "B"             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � A090DINC(ExpC1,ExpN1,ExpN2)								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo									  ���
���			 � ExpN1 = Numero do registro 								  ���
���			 � ExpN2 = Opcao selecionada								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QMTA090													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A090DINC(cAlias,nReg,nOpc)
Local nOpcA //,nCntDele := 0 ,cCod ,aAC := { OemToAnsi(STR0007),OemToAnsi(STR0008) }	//"Abandona"###"Confirma" 
Local oDlg
Local nCntFor	:= 0
Local nRQMW		:= 0
Local cIndexQMW	:= ""
Local cChaveQMW	:= "" 
Local cQuery	:= ""			
Local nIndex	:= 0
Local lRet		:= .T.
Local cCodIncB	:= ""
Local oSize
Private bCampo := { |nField| FieldName(nField) } 
//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo						     �
//����������������������������������������������������������������
Private aTELA[0][0],aGETS[0]
//������������������������������������������������������Ŀ
//� Cria Variaveis de Memoria da Enchoice 				 �
//��������������������������������������������������������

oSize := FwDefSize():New()
oSize:AddObject( "TELA" ,  100, 100, .T., .T. ) // Totalmente dimensionavel
oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

aPos	:= {	oSize:GetDimension("TELA","LININI"), oSize:GetDimension("TELA","COLINI"), ;
				(oSize:GetDimension("TELA","LINEND")-5), oSize:GetDimension("TELA","COLEND") }


dbSelectArea("QMV")
For nCntFor:= 1 To FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next nCntFor

 

cCodIncB	:= QMV->QMV_CODINC
While .T.
	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets		   �
	//����������������������������������������������
	nOpcA:=0
	dbSelectArea(cAlias)
	RecLock(cAlias,.F.)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
							TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009),,aPos,,3)  //"Quanto � exclus�o?" 
		nOpca := 1
		@ (oSize:GetDimension("TELA","LINEND") - 5 ), 05 Say OemToAnsi(STR0010) PIXEL // "Legenda: R -> Raiz Quadrada"
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,;
				oDlg:End()},{||oDlg:End()})
	
	dbSelectArea(cAlias)
	nRQMW := (cAlias)->(RecNo())
	If nOpcA == 2
		//Verifica se existe codigo de incerteza do tipo B associado a familia...


		dbSelectArea("QMW")
		DbSetOrder(1)
		cIndexQMW	:= CriaTrab(nil,.f.)
		cChaveQMW	:= "QMW_FILIAL+QMW_CODINC"
		cQuery		:= "QMW_FILIAL == '"+xFilial("QMW")+"'
		cQuery		+= '.AND. QMW_CODINC == "'+cCodIncB+'"'
		
		IndRegua("QMW",cIndexQMW,cChaveQMW,,cQuery,STR0011) //"Selecionando Registros. . ."
		nIndex := RetIndex("QMW")
		dbSelectArea("QMW")
		dbSetOrder(nIndex+1)
		dbGoTop()
		
		If QMW->(!Eof())
			lRet := .F.
		Endif		
		
		If !lRet
			MsgStop(STR0012) //"Nao e possivel delecao da incerteza do tipo B, pois a mesma encontra-se relacionada a uma ou mais familia(s)."
		Endif
		
		dbSelectArea("QMW")
		Set Filter to
		RetIndex("QMW")
		FErase (cIndexQMW+OrdBagExt())
		dbSelectArea(cAlias)
		dbGoTo(nRQMW)

		If lRet
			RecLock(cAlias,.F.,.T.)
			dbDelete()
			MsUnLock()
		Endif		
	EndIf 

	Exit

EndDo

dbSelectArea(cAlias)
Return(Nil)

/*
antigo a090VlDiv
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �qmt090VlDi� Autor � Wanderley Goncalves   � Data � 9/01/1998���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida Divisor 											  ���
���			 � OBS.: Sera verificado o simbolo, transformando-o em valor  ���
���			 � 		exceto o forma de "U" (e outros que venham a ser co-  ���
���			 � 		locados pelo usuario, que ser� considerado o valor    ���
���			 � 		digitado no campo divisor. 							  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � 															  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � X3_VALID do QMV_DISTR									  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function qmt090VlDi()

Local cRet := ""

Do Case
	Case M->QMV_DISTR == "N" // Normal
		cRet := "1         "       
	Case M->QMV_DISTR == "M" // Normal k=2
		cRet := "2         "
	Case M->QMV_DISTR == "R" // R=Retangular
		cRet := "R3        "                            
	Case M->QMV_DISTR == "T"  // Tiangular
		cRet := "R6        "
	Case M->QMV_DISTR == "U"  // Forma de "U"
		cRet := "R2        " 
	Case M->QMV_DISTR == "D"  // Instrumentos Digitais
		cRet := "R12       "
	Case M->QMV_DISTR == "X"  // Instrumentos Digitais
		cRet := "RN        "
	Case M->QMV_DISTR == " "  // Branco
		cRet := "          " 
EndCase
	
M->QMV_DIV := cRet

Return .t.

/*
antigo a090WhDiv
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �qmt090WhDi� Autor � Wanderley Goncalves   � Data � 9/1/1998 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Indica se divisor pode ou nao ser alterado				  ���
���			 � (Pode ser alterado somente se Distribuicao for igual a U   ���
���Descri��o � ou outro a ser acrescentado pelo usuario) 				  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Logico													  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � X3_When QMV_DIV											  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function qmt090WhDi()

Local lRet := .t.

If M->QMV_DISTR $ "N|M|R|T|D|X" 
	lRet := .f.
EndIf
	
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QM090VLDST   �Autor  �Sandra Ribeiro   � Data �  24/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida��o do campo QMV_DISTR                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Metrologia                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����
*/
Function QM090VLDST()

Local lret :=.T.

If !Empty (M->QMV_DISTR)
	lWDistr:=.F.
Endif

Return lret 
