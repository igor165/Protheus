#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA204.CH" 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATA204  � Autor �GDP materiais			�Data  �29/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grupos de Engenharia                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAEST                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA204()
Private cCadastro := STR0001  //"Grupos de Engenharia"
Private aRotina   := MenuDef()
Default lAutoMacao := .F.

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("SGL")
dbSetOrder(1)
IF !lAutoMacao
	mBrowse(006,001,022,075,"SGL")
Endif
dbSelectArea("SGL")
dbClearFilter()
dbSetOrder(1)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A204GrpApv�Autor  � GDP materiais			� Data �29/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Manutencao do Grupo de Aprovadores             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void A204GrpApv(ExpC1,ExpN1,ExpN2)                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA204                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A204GrpApv(cAlias,nReg,nOpcX)
Local aArea		:= GetArea()
Local aSizeAut	:= MsAdvSize(,.F.)   
Local aObjects	:= {}
Local aInfo 	:= {}
Local aPosObj	:= {}
Local aNoFields := {"GL_DESC","GL_COD"}
Local cSeek     := ""
Local cWhile    := ""
Local nSaveSX8  := GetSX8Len()
Local nOpcA     := 0
Local nX        := 0
Local l204Visual:= .F.
Local l204Inclui:= .F.
Local l204Deleta:= .F.
Local l204Altera:= .F.
Local lGravaOK  := .T.
Local oDlg
Local oGetDados
Local c204Num	:= SGL->GL_COD 
Local c204Desc  := SGL->GL_DESC
Local oPnlMst 

Private aHeader := {}
Private aCols   := {}   

Default lAutoMacao := .F.

IF !lAutoMacao
	aArea := SGL->(GetArea())
ENDIF
               
//���������������������������������������������������������Ŀ
//� Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  �
//�����������������������������������������������������������
If  aRotina[nOpcX][4] == 2
	l204Visual := .T.
ElseIf aRotina[nOpcX][4] == 3
	l204Inclui	:= .T.
ElseIf aRotina[nOpcX][4] == 4
	l204Altera	:= .T.
ElseIf aRotina[nOpcX][4] == 5
	l204Deleta	:= .T.
	l204Visual	:= .T.
EndIf

//����������������������������������������������������������Ŀ
//� Monta aHeader e aCols utilizando a funcao FillGetDados.  �
//������������������������������������������������������������
If l204Inclui
	c204Num	 := CRIAVAR("GL_COD")
	c204Desc := CRIAVAR("GL_DESC")
	//������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
	//� Sintaxe da FillGetDados(/*nOpcX*/,/*Alias*/,/*nOrdem*/,/*cSeek*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/) |
	//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������	
	FillGetDados(nOpcX,"SGL",1,,,,aNoFields,,,,,.T.,,,)
	aCols[1][aScan(aHeader,{|x| Trim(x[2])=="GL_ITEM"})] := StrZero(1,Len(SGL->GL_ITEM))
Else
	cSeek   := xFilial("SGL")+SGL->GL_COD
	cWhile  := "SGL->GL_FILIAL+SGL->GL_COD"
	//������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
	//� Sintaxe da FillGetDados(/*nOpcX*/,/*Alias*/,/*nOrdem*/,/*cSeek*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/) |
	//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������	
	FillGetDados(nOpcX,"SGL",1,cSeek,{|| &cWhile },,aNoFields,,,,,,,,)
EndIf  

AAdd( aObjects, { 000, 025, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo  := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj:= MsObjSize( aInfo, aObjects )

IF !lAutoMacao
	DEFINE MSDIALOG oDlg TITLE STR0001 From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL	

		oPnlMst := tPanel():Create(oDlg, 0, 0,,,,,,/*CLR_RED*/,aSizeAut[5]-1,/*nHeight*/)
		oPnlMst:Align := CONTROL_ALIGN_ALLCLIENT
		
		@ 010, 5 SAY   STR0010  OF oPnlMst PIXEL //"Codigo Grupo"
		@ 008, 50 MSGET c204Num  PICTURE PesqPict("SGL","GL_COD") VALID A204Numero(c204Num)  WHEN l204Inclui .And. VisualSX3("GL_COD") OF oPnlMst PIXEL SIZE 30,10 RIGHT
		@ 010, 105 SAY   STR0011  OF oPnlMst PIXEL  //"Descricao"
		@ 008, 150 MSGET c204Desc PICTURE PesqPict("SGL","GL_DESC")VALID WHEN !l204Visual .And. VisualSX3("GL_DESC") OF oPnlMst PIXEL 
		
		oGetDados := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcX,"A204LinOK","A204TudOK","+GL_ITEM",!l204Visual)
		
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, IIf(oGetdados:TudoOk(),(nOpcA := 1,oDlg:End()),nOpcA := 0)},{||oDlg:End()})
ENDIF

If nOpcA == 1	
	If l204Inclui .Or. l204Altera .Or. l204Deleta
		lGravaOk := A204Grava(c204Num,c204Desc,l204Deleta)
		If lGravaOk
			EvalTrigger()
			If l204Inclui
				While ( GetSX8Len() > nSaveSX8 )
					ConFirmSX8()
				EndDo
			EndIf
		Else
			Help(" ",1,"A085NAOREG")
			While ( GetSX8Len() > nSaveSX8 )
				RollBackSX8()
			EndDo
		EndIf
	EndIf	
Endif

If nOpcA == 0 .And. l204Inclui
	While ( GetSX8Len() > nSaveSX8 )
		RollBackSX8()
	EndDo
EndIf
RestArea(aArea)
Return 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A204LinOk � Autor � GDP materiais		    � Data �29/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a linha digitada esta' Ok                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA204                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A204LinOk(o)
Local aArea		:= GetArea()
Local nPosUser  := aScan(aHeader,{|x| AllTrim(x[2]) == "GL_USER"})
Local nX        := 0
Local lRet      := .T.
Local lDeleted  := .F.

If ValType(aCols[n,Len(aCols[n])]) == "L"// Verifico se posso Deletar
	lDeleted := aCols[n,Len(aCols[n])]// Se esta Deletado
EndIf

If lRet .And. !lDeleted        
	SGK->(dbSetOrder(2))
	SGK->(Msseek(xFilial("SGK")+aCols[n][nPosUser]))
	For nX := 1 to Len(aCols)
		If (SGK->GK_USER == aCols[nX][nPosUser]) .And. n != nX
			Help(" ",1,"JAGRAVADO")
			lRet := .F.
			Exit
		EndIf
	Next
Endif
If lRet .And. Empty(aCols[n][nPosUser])
	Aviso(STR0012,STR0013,{STR0009}) 
	lRet := .F.
EndIf
RestArea(aArea)
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A204TudOk � Autor �GDP materiais		    � Data �29/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a nota toda esta' Ok                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA204                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A204TudOk(o)
Local aArea     := GetArea()
Local nX        := 0
Local lRet      := .T.
Local lDeleted  := .F.
Local lPE       := .T.

For nX := 1 to Len(aCols)
	If ValType(aCols[nX,Len(aCols[nX])]) == "L"
		lDeleted := aCols[nX,Len(aCols[nX])]      /// Se esta Deletado
	EndIf
Next
//�������������������������������������������������������������-Ŀ
//� Pontos de Entrada para validar o aCols.                      �
//������������������������������������������������������������-���
If (ExistBlock("MT204TOK"))
	lPE := ExecBlock("MT204TOK",.F.,.F.,{lRet})
	If ValType(lPE) = "L"
		If !lPE
			lRet := .F. 
		EndIf
	EndIf
EndIf
RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A204Aprov � Autor � GDP Materias          � Data �29/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do aprovador.                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA204                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A204Aprov()
Local cVarAprov := Readvar()
Local nPosUser  := aScan(aHeader,{|x| AllTrim(x[2]) == "GL_USER"})
Local nX        := 0
Local lRet      := .T.
cVarAprov := If(Empty(cVarAprov),"",&cVarAprov)
SGK->(dbSetOrder(1))
SGK->(Msseek(xFilial("SGK")+cVarAprov))
For nX := 1 to Len(aCols)
	If (SGK->GK_USER == aCols[nX][nPosUser]).And. n != nX .And. !aCols[nX][Len(aCols[nX])]
		Help(" ",1,"JAGRAVADO")
		lRet := .F.
		Exit
	EndIf
Next nX
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A204Numero� Autor �GDP Materiais			�Data  �29/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica o grupo de aprovadores.                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA204                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A204Numero(c204Num)
Local lRet := .T.
If Empty(c204Num)
	Help(" ",1,"VAZIO")
	lRet := .F.
EndIf
Return lRet
                
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A204Grava �Autor  �GDP Materiais 			� Data �29/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de gravacao do Grupo de Aprovadores                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA204                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A204Grava(c204Num,c204Desc,l204Deleta)
Local nPosItem := aScan(aHeader,{|x| AllTrim(x[2]) == "GL_ITEM"})
Local nPosCom  := aScan(aHeader,{|x| AllTrim(x[2]) == "GL_USER"})
Local nX       := 0
Local ny       := 0   
Local lRet     := .T.
Local lMT204VLD:= .F.
Default lAutoMacao := .F.

//�������������������������������������������������������������-Ŀ
//� Pontos de Entrada para validar o aCols.                      �
//������������������������������������������������������������-���
If (ExistBlock("MT204VLD"))
	lMT204VLD := ExecBlock("MT204VLD",.F.,.F.,{aHeader,aCols,l204Deleta,c204Num})
	If ValType(lMT204VLD) = "L"
		lRet := lMT204VLD
	EndIf
EndIf

If lRet
	Begin Transaction		
	dbSelectArea("SGL") 
	dbSetOrder(1)	
	For nX = 1 to Len(aCols)
		IF !lAutoMacao		
			If dbSeek(xFilial("SGL")+c204Num+aCols[nx][nPosItem])
				RecLock("SGL",.F.)
			Else
				RecLock("SGL",.T.)          			      
			EndIf			                
			
			If !l204Deleta
				If !aCols[nX,Len(aCols[nX])]
					//������������������������������������������������Ŀ
					//� Atualiza dados da GetDados                     �
					//��������������������������������������������������
					For nY := 1 to Len(aHeader)
						If ( aHeader[nY][10] <> "V" )
							SGL->(FieldPut(FieldPos(Trim(aHeader[nY][2])),aCols[nX][nY]))
						EndIf
					Next nY
					//�������������������������������������������������Ŀ
					//� Atualiza os Campos do Cabecalho                 �
					//���������������������������������������������������
					SGL->GL_FILIAL	:= xFilial("SGL")
					SGL->GL_COD		:= c204Num
					SGL->GL_DESC	:= c204Desc
				Else
					dbDelete()
				EndIf
			Else
				dbDelete()
			EndIf
		ENDIF
	Next nX
	IF !lAutoMacao	
		SGL->(MsUnLock())
	ENDIF
	End Transaction
	
	//������������������������������������������������������-Ŀ
	//� Pontos de Entrada apos gravacao.                      �
	//�����������������������������������������������������-���
	If (ExistBlock("MT204GRV"))
		ExecBlock("MT204GRV",.F.,.F.,{aHeader,aCols,l204Deleta,l204Deleta,c204Num})
	EndIf	
EndIf
Return .T. 

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor �GDP Materiais		    � Data �29/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()     
Private aRotina	:=     {{OemToAnsi(STR0002),"AxPesqui",0,1,0,.F.},;	//"Pesquisar"
 						{OemToAnsi(STR0003),"A204GrpApv",0,2,0,nil},;	//"Visualizar"
						{OemToAnsi(STR0004),"A204GrpApv",0,3,0,nil},; //"Incluir"
						{OemToAnsi(STR0005),"A204GrpApv",0,4,0,nil},; //"Alterar"
						{OemToAnsi(STR0006),"A204GrpApv",0,5,0,nil} } //"Excluir"	

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
//��������������������������������������������������������������������������
If ExistBlock("MTA204MNU")
	ExecBlock("MTA204MNU",.F.,.F.)
EndIf
Return(aRotina)   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A204VldUsr�Autor  �Rodrigo T. Silva       � Data �30/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se o Usuario pertence ao Cadastro de Engenheiros.   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA204                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A204VldUsr()
Local aArea   := GetArea()
Local lRetorno:= .T.
Default lAutoMacao := .F.

dbSelectArea("SGK")
dbSetOrder(2)
IF !lAutoMacao
	If !dbSeek(xFilial("SGK")+M->GL_USER)
		Aviso(STR0007,STR0008,{STR0009}) 
		lRetorno:= .F.
	EndIf
ENDIF

RestArea(aArea)

Return lRetorno
