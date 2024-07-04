#INCLUDE "MATA205.CH"
#INCLUDE "PROTHEUS.CH"           

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATA205  � Autor �GDP - Materiais 		�Data  �28/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grupos de Aprovadores                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAEST                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA205()
Private cCadastro := STR0001
Private aRotina   := MenuDef()
Default lAutoMacao := .F.

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("SGM")
dbSetOrder(1)
IF !lAutoMacao
	mBrowse(006,001,022,075,"SGM")
ENDIF
dbSelectArea("SGM")
dbClearFilter()
dbSetOrder(1)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A205GrpApv�Autor  � GDP - Materiais		� Data �28/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Manutencao do Grupo de Aprovadores             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void A205GrpApv(ExpC1,ExpN1,ExpN2)                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA205                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A205GrpApv(cAlias,nReg,nOpcX)
Local aArea		  := GetArea()
Local aSizeAut	  := MsAdvSize(,.F.)
Local aObjects	  := {}
Local aInfo 	  := {}
Local aPosObj	  := {}
Local aNoFields  := {"GM_DESC","GM_COD"}
Local cSeek      := ""
Local bWhile     := NIL
Local nSaveSX8   := GetSX8Len()
Local nOpcA      := 0
Local nX         := 0
Local l205Visual := .F.
Local l205Inclui := .F.
Local l205Deleta := .F.
Local l205Altera := .F.
Local lGravaOK   := .T.
Local oDlg
Local oGetDados
Local c205Num	:= SGM->GM_COD
Local c205Desc  := SGM->GM_DESC
Local oPnlMst

Private aHeader  := {}
Private aCols    := {} 

Default lAutoMacao := .F.

IF !lAutoMacao
	aArea := SGM->(GetArea())
ENDIF

//���������������������������������������������������������Ŀ
//� Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  �
//�����������������������������������������������������������
If aRotina[nOpcX][4] == 2
	l205Visual := .T.
ElseIf aRotina[nOpcX][4] == 3
	l205Inclui	:= .T.
ElseIf aRotina[nOpcX][4] == 4
	l205Altera	:= .T.
ElseIf aRotina[nOpcX][4] == 5
	l205Deleta	:= .T.
	l205Visual	:= .T.
EndIf

//����������������������������������������������������������Ŀ
//� Monta aHeader e aCols utilizando a funcao FillGetDados.  �
//������������������������������������������������������������
If l205Inclui                      
	c205Num	 := CRIAVAR("GM_COD")
	c205Desc := CriaVar("GM_DESC")
	//������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
	//� Sintaxe da FillGetDados(/*nOpcX*/,/*Alias*/,/*nOrdem*/,/*cSeek*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/) |
	//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������	
	FillGetDados(nOpcX,"SGM",1,,,,aNoFields,,,,,.T.,,,)
	aCols[1][aScan(aHeader,{|x| Trim(x[2])=="GM_ITEM"})] := StrZero(1,Len(SGM->GM_ITEM))
Else
	cSeek   := xFilial("SGM")+SGM->GM_COD
	bWhile  := {|| SGM->(GM_FILIAL+GM_COD)}
	//������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
	//� Sintaxe da FillGetDados(/*nOpcX*/,/*Alias*/,/*nOrdem*/,/*cSeek*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/) |
	//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������	
	FillGetDados(nOpcX,"SGM",1,cSeek,bWhile,,aNoFields,,,,,,,,)
EndIf  

If l205Deleta 
	dbSelectArea("SGK")
	dbSeek(xFilial())
	While !Eof() .And. xFilial()==GK_FILIAL
		If (SGK->GK_GRAPROV==SGM->GM_COD)		
			Aviso(STR0004,STR0012,{STR0006}) //"Este Grupo de Aprovadores est� vinculado ao cadastro de Engenheiros."
			Return .F.
		EndIf
		dbSkip()
	EndDo
EndIf

AAdd( aObjects, { 000, 025, .T., .F. })
AAdd( aObjects, { 100, 100, .T., .T. })
aInfo  := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj:= MsObjSize( aInfo, aObjects )

IF !lAutoMacao
	DEFINE MSDIALOG oDlg TITLE STR0001 From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL	

		oPnlMst := tPanel():Create(oDlg, 0, 0,,,,,,/*CLR_RED*/,aSizeAut[5]-1,/*nHeight*/)
		oPnlMst:Align := CONTROL_ALIGN_ALLCLIENT

		@ 015,005 SAY   STR0002  OF oPnlMst PIXEL //"N�mero"
		@ 014,050 MSGET c205Num  PICTURE PesqPict("SGM","GM_COD") VALID A205Numero(c205Num) WHEN l205Inclui .And. VisualSX3("GM_COD") OF oPnlMst PIXEL SIZE 30,10 RIGHT
		@ 015,105 SAY   STR0003  OF oPnlMst PIXEL  //"Descricao"
		@ 014,150 MSGET c205Desc PICTURE PesqPict("SGM","GM_DESC") WHEN !l205Visual .And. VisualSX3("GM_DESC") OF oPnlMst PIXEL 

	oGetDados := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcX,"A205LinOK","A205TudOK","+GM_ITEM",!l205Visual)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, IIf(oGetdados:TudoOk(),(nOpcA := 1,oDlg:End()),nOpcA := 0)},{||oDlg:End()})
ENDIF

If nOpcA == 1	
	If l205Inclui .Or. l205Altera .Or. l205Deleta
		lGravaOk := A205Grv(c205Num,c205Desc,l205Deleta)
		If lGravaOk
			EvalTrigger()
			If l205Inclui
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

If nOpcA == 0 .And. l205Inclui
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
���Fun��o    �A205LinOk � Autor �Rodrigo T. Silva       � Data �28/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a linha digitada esta' Ok                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA205                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A205LinOk(o)
Local aArea		 := GetArea()
Local nPosNivel := aScan(aHeader,{|x| AllTrim(x[2]) == "GM_NIVEL"})
Local nPosUser  := aScan(aHeader,{|x| AllTrim(x[2]) == "GM_USER"}) 
Local nPosSup	:= aScan(aHeader,{|x| AllTrim(x[2]) == "GM_SUPER"})
Local nX        := 0
Local lRet      := .T.
Local lDeleted  := .F.

If Empty(aCols[n][nPosNivel]) .And. n == 1
	lRet := .T.
EndIf

If ValType(aCols[n,Len(aCols[n])]) == "L"   // Verifico se posso Deletar
	lDeleted := aCols[n,Len(aCols[n])]      // Se esta Deletado
EndIf

If lRet .And. !lDeleted        
	For nX := 1 to Len(aCols)
		If (aCols[n][nPosUser] == aCols[nX][nPosUser]) .And. n != nX .And. !aCols[nX,Len(aCols[n])]
			Help(" ",1,"JAGRAVADO")
			lRet := .F.
			Exit
		EndIf
	Next
	If lRet .And. !Empty(aCols[n][nPosSup]) .And. (aCols[n][nPosSup] == aCols[n][nPosUser]) .And. !aCols[n,Len(aCols[n])]
		Aviso(STR0004,STR0005,{STR0006})
		lRet := .F.
	EndIf			
Endif

If !lDeleted
	If Empty(aCols[n][nPosUser]) .And. lRet
		Aviso(STR0004,STR0013,{STR0006}) //"O c�digo do usu�rio n�o pode ficar em branco, digite o c�digo correto."
		lRet := .F.
	Endif
	If Empty(aCols[n][nPosNivel]) .And. lRet
		Aviso(STR0004,STR0014,{STR0006}) //"O c�digo do usu�rio n�o pode ficar em branco, digite o c�digo correto."		
		lRet := .F.
	Endif
EndIf
RestArea(aArea)
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A205TudOk � Autor � GDP - Materiais       � Data �31/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a nota toda esta' Ok                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA205                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A205TudOk(o)
Local aArea     := GetArea()
Local nPosNivel := aScan(aHeader,{|x| AllTrim(x[2]) == "GM_NIVEL"})
Local nX        := 0
Local lRet      := .T.
Local lDeleted  := .F.
Local lPE       := .T.

For nX := 1 to Len(aCols)
	If ValType(aCols[nX,Len(aCols[nX])]) == "L"
		lDeleted := aCols[nX,Len(aCols[nX])]      /// Se esta Deletado
	EndIf
	If !lDeleted
		If Empty(aCols[nX][nPosNivel]) .And. lRet
			Help(" ",1,"A205NIVEL")
			lRet := .F.
		Endif
	EndIf
Next

//�������������������������������������������������������������-Ŀ
//� Pontos de Entrada para validar o aCols.                      �
//������������������������������������������������������������-���
If (ExistBlock("MT205TOK"))
	lPE := ExecBlock("MT205TOK",.F.,.F.,{lRet})
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
���Fun��o    �A205Numero� Autor �GDP MAteriais			�Data  �30/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica o grupo de aprovadores.                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA205                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A205Numero(c205Num)
Local lRet := .T.
If Empty(c205Num)
	Help(" ",1,"VAZIO")
	lRet := .F.
EndIf
Return lRet
                
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A205Grv 	�Autor  �GDP MAteriais			� Data �30/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de gravacao do Grupo de Aprovadores                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA205                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A205Grv(c205Num,c205Desc,l205Deleta)

Local nPosItem := aScan(aHeader,{|x| AllTrim(x[2]) == "GM_ITEM"})
Local nPosUser := aScan(aHeader,{|x| AllTrim(x[2]) == "GM_USER"})
Local nPosSup  := aScan(aHeader,{|x| AllTrim(x[2]) == "GM_SUPER"})
Local nX       := 0
Local ny       := 0   
Local lRet     := .T.
Local lMT205VLD:= .F.
Default lAutoMacao := .F.

//�������������������������������������������������������������-Ŀ
//� Pontos de Entrada para validar o aCols.                      �
//������������������������������������������������������������-���
If (ExistBlock("MT205VLD"))
	lMT205VLD := ExecBlock("MT205VLD",.F.,.F.,{aHeader,aCols,l205Deleta,c205Num})
	If ValType(lMT205VLD) = "L"
		lRet := lMT205VLD
	EndIf
EndIf

If lRet
	Begin Transaction	
	dbSelectArea("SGM") 
	dbSetOrder(1)	
	For nX = 1 to Len(aCols)
		IF !lAutoMacao		
			If dbSeek(xFilial("SGM")+c205Num+aCols[nx][nPosItem])
				RecLock("SGM",.F.)
			Else
				RecLock("SGM",.T.)
			EndIf
			
			If !l205Deleta
				If !aCols[nX,Len(aCols[nX])]
					//������������������������������������������������Ŀ
					//� Atualiza dados da GetDados                     �
					//��������������������������������������������������
					For nY := 1 to Len(aHeader)
						If ( aHeader[nY][10] <> "V" )
							SGM->(FieldPut(FieldPos(Trim(aHeader[nY][2])),aCols[nX][nY]))
						EndIf
					Next nY
					//�������������������������������������������������Ŀ
					//� Atualiza os Campos do Cabecalho/Rodape          �
					//���������������������������������������������������
					SGM->GM_FILIAL := xFilial("SGM")
					SGM->GM_COD    := c205Num
					SGM->GM_DESC   := c205Desc
					SGM->GM_SUPER  := aCols[nX][nPosSup]
					SGM->GM_NOME   := UsrRetName(aCols[nX][nPosUser])
				Else
					dbDelete()
				EndIf
			Else
				dbDelete()
			EndIf
		ENDIF
	Next nX
	IF !lAutoMacao
		SGM->(MsUnLock())
	ENDIF
	End Transaction 
	//������������������������������������������������������-Ŀ
	//� Pontos de Entrada apos gravacao.                      �
	//�����������������������������������������������������-���
	If (ExistBlock("MT205GRV"))
		ExecBlock("MT205GRV",.F.,.F.,{aHeader,aCols,l086Deleta,c205Num})
	EndIf
EndIf

Return .T. 

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor �GDP Materiais		    � Data �30/10/2010���
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

Private aRotina	:=     {{OemToAnsi(STR0007),"AxPesqui",0,1,0,.F.},;	//"Pesquisar"
 						{OemToAnsi(STR0008),"A205GrpApv",0,2,0,nil},;	//"Visualizar"
						{OemToAnsi(STR0009),"A205GrpApv",0,3,0,nil},; //"Incluir"
						{OemToAnsi(STR0010),"A205GrpApv",0,4,0,nil},; //"Alterar"
						{OemToAnsi(STR0011),"A205GrpApv",0,5,0,nil} } //"Excluir"	

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
//��������������������������������������������������������������������������
If ExistBlock("MTA205MNU")
	ExecBlock("MTA205MNU",.F.,.F.)
EndIf

Return(aRotina)
