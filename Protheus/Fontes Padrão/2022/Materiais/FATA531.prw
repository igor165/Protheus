#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA531.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATA531   �Autor  �Vendas CRM          � Data �  08/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Programa de manutecao de Tarefas de Pre-Projetos            ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Tipo de operacao(2-Visual,3-Inclui,4-Altera,etc.)   ���
���          �ExpA2 - Campos a serem exibidos na enchoice                 ���
���          �ExpC3 - Nivel da tarefa a ser incluida                      ���
���          �ExpL4 - Indica se deve ser realizada a gravacao dos dados   ���
�������������������������������������������������������������������������͹��
���Uso       �FATA530                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FATA531(nCallOpcx,aGetCpos,cNivTrf,lRefresh)

Local nRecAF2
PRIVATE cCadastro	:= STR0001 //"Tarefas do PreProjeto"
PRIVATE aRotina := MenuDef()
Default lRefresh := .F.

SaveInter()

If nCallOpcx == Nil
	mBrowse(6,1,22,75,"AF2")
Else
	cNivTrf := Soma1(cNivTrf)
	nRecAF2 := FTA531Dlg(	"AF2"	, AF2->(RecNo())	, nCallOpcx	, aGetCpos	,;
							cNivTrf	, @lRefresh			)
EndIf

RestInter() 

Return nRecAF2

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FTA531Dlg �Autor  �Vendas CRM          � Data �  08/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Programa de Inclusao,Alteracao,Visualizacao e Exclusao de   ���
���          �Tarefas de PreProjetos de Projetos.                         ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Alias do arquivo exibido                            ���
���          �ExpN2 - Numero do registro (RECNO)                          ���
���          �ExpN3 - Opcao de exibicao                                   ���
���          �ExpA4 - Campos a serem exibidos na enchoice                 ���
���          �ExpC5 - Nivel da tarefa a ser incluida                      ���
���          �ExpL6 - Indica se deve ser realizada a gravacao dos dados   ���
�������������������������������������������������������������������������͹��
���Uso       �FATA530                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FTA531Dlg(	cAlias	, nReg		, nOpcx	, aGetCpos	,;
					cNivTrf	, lRefresh	)

Local cCombo1		:= ''
Local nMoedaVis		:= 1
Local oDlg			:= Nil
Local nGdOpc		:= 0
Local l531Inclui	:= .F.
Local l531Visual	:= .F.
Local l531Altera	:= .F.
Local l531Exclui	:= .F.
Local lContinua		:= .T.
Local nOpc			:= 0
Local aSize			:= {}
Local aObjects		:= {}
Local aInfo 		:= {}
Local aPosObj       := {}
Local aCombo1		:= {}
Local aAuxCombo1	:= {}
Local aGetEnch
Local aButtons  := {}
Local aPages	:= {}
Local aTitles	:= { STR0008,; //"Produtos"
					 STR0027,;//"Relac.Tarefas"
					 STR0033} //"Componentes"

Local nPosCpo
Local cCpo
Local nRecAF2	:= AF2->(Recno())
Local aAuxArea   
Local lModelo	:= IsInCallStack("FATA530A")
Local lOrcSPms	:= SuperGetMV('MV_ORCSPMS',.F.,.F.)

Local oListBox
Local oListBox2

Local aTmpSV5 := {}
Local aTmp2SV5 := {}

Local nx		:= 0
Local ny		:= 0
Local ni		:= 0
Local nPosAF3Qt	:= 0
Local nPosAF3Ct	:= 0

PRIVATE oGD[3]
PRIVATE aSavN		:= {1,1,1}
PRIVATE aHeaderSV	:= {{},{},{}}
PRIVATE aColsSV	    := {{},{},{}}
PRIVATE oEnch
PRIVATE oFolder
PRIVATE aTELA[0][0],aGETS[0]
PRIVATE 	cSavScrVT,;
			cSavScrVP,;
			cSavScrHT,;
			cSavScrHP,;
			CurLen,;
			nPosAtu:=0,;
			nPosAnt:=9999,;
			nColAnt:=9999
			

DEFAULT cNivTrf := "001"

//������������������������������������������������������Ŀ
//� Monta o Array contendo as moedas do sistema          �
//��������������������������������������������������������
For nx := 1 to ContaMoeda()
	If l531Visual .or. xMoeda(1,1,nx,dDataBase) > 0
		aADD(aCombo1,STR(nx,1)+":"+SuperGetMv("MV_MOEDA"+STR(nx,1)))
		aADD(aAuxCombo1,nx)
	EndIf
	If nx == nMoedaVis
		cCombo1 := aCombo1[nx]
	EndIf
Next

//���������������������������������������������������������Ŀ
//� Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  �
//�����������������������������������������������������������
Do Case
	Case nOpcx == 2
		l531Visual := .T.
	Case nOpcx == 3
		l531Inclui	:= .T.
		Inclui 		:= .T.
		Altera 		:= .F.
	Case nOpcx == 4
		l531Altera	:= .T.
		Inclui 		:= .F.
		Altera 		:= .T.
	Case nOpcx == 5
		l531Exclui	:= .T.
		l531Visual	:= .T.
EndCase

//��������������������������������������������������������������Ŀ
//� Carrega as variaveis de memoria AF2                          �
//����������������������������������������������������������������
RegToMemory("AF2",l531Inclui)
If l531Inclui
	M->AF2_NIVEL := cNivTrf
EndIf

//��������������������������������������������������������������������Ŀ
//� Tratamento do array aGetCpos com os campos Inicializados do AF2    �
//����������������������������������������������������������������������
If aGetCpos <> Nil
	aGetEnch	:= {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	DbSeek("AF2")
	While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == "AF2"
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nPosCpo	:= aScan(aGetCpos,{|x| x[1]==Alltrim(X3_CAMPO)})
			If nPosCpo > 0
				If aGetCpos[nPosCpo][3]
					aAdd(aGetEnch,AllTrim(X3_CAMPO))
				EndIf
			Else
				aAdd(aGetEnch,AllTrim(X3_CAMPO))
			EndIf
		EndIf
		dbSkip()
	End
	
	For nx := 1 to Len(aGetCpos)
		cCpo	:= "M->"+Trim(aGetCpos[nx][1])
		&cCpo	:= aGetCpos[nx][2]
	Next nx
EndIf

//��������������������������������Ŀ
//�Monta GetDados dos produtos(AF3)�
//����������������������������������
cSeek 	:= 	xFilial("AF3")+M->AF2_ORCAME+M->AF2_VERSAO+M->AF2_TAREFA
bWhile	:=	{||AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3->AF3_VERSAO+AF3->AF3_TAREFA} 
FillGetDados(nOpc,"AF3",5,cSeek,bWhile,,,,,,,,@aHeaderSV[1],@aColsSV[1])
If lOrcSPms //Chamadas da atualiza��o de custo deve ser feita apenas com a nova integra��o CRM x PMS
	nPosAF3Qt := aScan(aHeaderSV[1],{|x|AllTrim(x[2]) == "AF3_QUANT"})
	If nPosAF3Qt > 0
		aHeaderSV[1][nPosAF3Qt][6] += " .AND. FT531Custo('AF3_QUANT')" //Adiciona a chamada da fun��o FT531Custo no valid do campo AF3_QUANT
	EndIf
	nPosAF3Ct := aScan(aHeaderSV[1],{|x|AllTrim(x[2]) == "AF3_CUSTD"})
	If nPosAF3Ct > 0
		aHeaderSV[1][nPosAF3Ct][6] += " .AND. FT531Custo('AF3_CUSTD')" //Adiciona a chamada da fun��o FT531Custo no valid do campo AF3_CUSTD
	EndIf
EndIf
nX		:=  aScan(aHeaderSV[1],{|x|AllTrim(x[2]) == "AF3_ITEM"})
If (nX > 0) .AND. (Len(aColsSV[1]) == 1) .AND. Empty(aColsSV[1][1][nX])
	aColsSV[1][1][nX]	:= "01"
EndIf

//�������������������������������������Ŀ
//�Monta Getdados das predecessoras(AF7)�
//���������������������������������������
cSeek 	:= 	xFilial("AF7")+M->AF2_ORCAME+M->AF2_VERSAO+M->AF2_TAREFA
bWhile	:=	{||AF7->AF7_FILIAL+AF7->AF7_ORCAME+AF7->AF7_VERSAO+AF7->AF7_TAREFA} 
FillGetDados(nOpc,"AF7",3,cSeek,bWhile,,,,,,,,@aHeaderSV[2],@aColsSV[2],{|a,b|FT531AfCo2(a,b)})
nX		:=  aScan(aHeaderSV[2],{|x|AllTrim(x[2]) == "AF7_ITEM"})
If (nX > 0) .AND. (Len(aColsSV[2]) == 1) .AND. Empty(aColsSV[2][1][nX])
	aColsSV[2][1][nX]	:= "01"
EndIf              

//��������������������������������������������Ŀ
//�Monta aHeader/aCols da tabela ADX (folder 3)�
//����������������������������������������������
cSeek 	:= 	xFilial("ADX")+M->AF2_ORCAME+M->AF2_TAREFA
bWhile	:=	{||ADX->ADX_FILIAL+ADX->ADX_ORCAME+ADX->ADX_TAREFA} 
FillGetDados(nOpcx,"ADX",1,cSeek,bWhile,,,,,,,,@aHeaderSV[3],@aColsSV[3],{|a,b|FT531AfCo1(a,b)})
nx		:=  aScan(aHeaderSV[3],{|x|AllTrim(x[2]) == "ADX_ITEM"})
If (nx > 0) .AND. (Len(aColsSV[3]) == 1) .AND. Empty(aColsSV[3][1][nx])
	aColsSV[3][1][nx]	:= "01"
EndIf

DbSelectArea("AF2")

If lContinua
	If !l531Inclui
		AF2->( dbGoTo(nRecAF2) )
	EndIf

	//������������������������������������������������������Ŀ
	//� Faz o calculo automatico de dimensoes de objetos     �
	//��������������������������������������������������������
	aSize := MsAdvSize(,.F.,400)
	aObjects := {}
	
	AAdd( aObjects, { 100, 100 , .T., .T. } )
	AAdd( aObjects, { 100, 100 , .T., .T. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
	oEnch := MsMGet():New("AF2",AF2->(RecNo()),nOpcx,,,,,aPosObj[1],aGetEnch,3,,,,oDlg,,,,,,,Ft530Field("AF2"))
	
	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,aPages,oDlg,,,, .T., .T.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
	oFolder:bSetOption:={|nFolder| A531SetOption(nFolder,oFolder:nOption) }
	
	For ni := 1 to Len(oFolder:aDialogs)
		DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[ni]
	Next
	dbSelectArea("SX2")

	nGdOpc 		:= IIf(l531Inclui .OR. l531Altera,GD_INSERT+GD_UPDATE+GD_DELETE,0)
	
	oFolder:aDialogs[1]:oFont := oDlg:oFont
	oGD[1]		:= MsNewGetDados():New(0,0,aPosObj[2,3]-aPosObj[2,1]-23,aPosObj[2,4]-4,nGdOpc,"A531GD1LinOk","A531GD1TudOk","+AF3_ITEM",,,300,,,,oFolder:aDialogs[1],aHeaderSV[1],aColsSV[1])
	
	oFolder:aDialogs[2]:oFont := oDlg:oFont
	oGD[2]		:= MsNewGetDados():New(0,0,aPosObj[2,3]-aPosObj[2,1]-23,aPosObj[2,4]-4,If(lModelo .OR. INCLUI,nGdOpc,0),"A531GD2LinOk","A531GD2TudOK","+AF7_ITEM",,,300,,,,oFolder:aDialogs[2],aHeaderSV[2],aColsSV[2])
	
	oFolder:aDialogs[3]:oFont := oDlg:oFont
	oGd[3]		:= MsNewGetDados():New(0,0,aPosObj[2,3]-aPosObj[2,1]-23,aPosObj[2,4]-4,nGdOpc,"A531GD3LinOk","A531GD3TudOK","+ADX_ITEM",,,300,"F531GDFOk",,,oFolder:aDialogs[3],aHeaderSV[3],aColsSV[3])

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||EncChgFoco(oEnch),If(Obrigatorio(aGets,aTela).And.;
	AGDTudok(1).AND. AGDTudok(2) .AND.; 
	AGDTudok(3),(nOpc:=1,oDlg:End()),Nil)},{||oDlg:End()},,aButtons)
	
	// N�o deve aplicar refresh na visualizacao do PreProjeto (arvore/planilha)
	lRefresh := .F.
	dbSelectArea("AF2")
	If (nOpc == 1) .And. (l531Inclui .Or. l531Altera .Or. l531Exclui)
		// Aplicar refresh na visualizacao do PreProjeto (arvore/planilha)
		lRefresh := .T.
		
		Begin Transaction
		Processa({||FTA531Grava(l531Exclui,@nRecAF2,.T.)},STR0026) //"Gravando Estrutura..."
		End Transaction
	EndIf
	
Endif

//������������������������������������������������������������������������Ŀ
//�Destrava Todos os Registros                                             �
//��������������������������������������������������������������������������
MsUnLockAll()

Return nRecAF2

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A531SetOption�Autor  �Vendas CRM       � Data �  08/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao que controla a GetDados ativa na visualizacao do     ���
���          �Folder.                                                     ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Numero do folder a ser acessado                     ���
���          �ExpN2 - Numero do folder atual                              ���
�������������������������������������������������������������������������͹��
���Uso       �FATA530                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A531SetOption(nFolder,nOldFolder)

//�����������������������Ŀ
//�Calcula total da tarefa�
//�������������������������
If oFolder:nOption == 3
	Ft531Soma()
EndIf

oGD[nFolder]:Refresh()

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �A531GD1LinOk� Autor � Vendas CRM          � Data � 08-01-2008 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao LinOk da GetDados 1.                               ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � FATA531                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function A531GD1LinOk()
Local lRet		:= F531ChkCol(@oGd[1])
Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �A531GD1TudOk� Autor � Vendas CRM          � Data � 08-01-2008 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao TudOk da GetDados 1.                               ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � FATA531                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function A531GD1TudOk()

Local nx
Local lRet := .T.
Local nPosProd	:= aScan(oGd[1]:aHeader,{|x|AllTrim(x[2])=="AF3_PRODUT"})
Local nPosQT	:= aScan(oGd[1]:aHeader,{|x|AllTrim(x[2])=="AF3_QUANT"})
Local N			:= oGd[1]:nAt
Local nQtdPrd	:= 0

For nx := 1 to Len(oGd[1]:aCols)
	n	:= nx
	If !aTail(oGd[1]:aCols[n]) .AND. (!Empty(oGd[1]:aCols[n][nPosProd]) .Or. !Empty(oGd[1]:aCols[n][nPosQT]))
		nQtdPrd++
		If !A531GD1LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

//��������������������������������������Ŀ
//�Valida se foram informados os produtos�
//����������������������������������������
If lRet .AND. (nQtdPrd == 0)
	lRet := .F.
	MsgAlert(STR0032)//"Cadastrar pelo menos um produto na tarefa"
EndIf

Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �A531GD2TudOk� Autor � Vendas CRM          � Data � 08-01-2008 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao TudOk da GetDados 3.                               ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � FATA531                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function A531GD2TudOk()
Local nx := 0
Local nPosPredec	:= aScan(oGd[2]:aHeader,{|x|AllTrim(x[2])=="AF7_PREDEC"})
Local lRet			:= .T.
Local N				:= oGd[2]:nAt

For nx := 1 to Len(oGd[2]:aCols)
	n	:= nx
	If !Empty(oGd[2]:aCols[n][nPosPredec])
		If !A531GD2LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next
	
Return lRet


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �A531GD2LinOk� Autor � Vendas CRM          � Data � 08-01-2008 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao LinOk da GetDados 3.                               ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � FATA531                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function A531GD2LinOk()

//������������������������������������������������������Ŀ
//� Verifica os campos obrigatorios do SX3.              �
//��������������������������������������������������������
Local lRet 		:= F531ChkCol(@oGd[2])
Local nPosItem	:= aScan(oGd[2]:aHeader,{|x| AllTrim(x[2])=="AF7_ITEM"})
Local aArea     := GetArea()
Local aAreaAF7  := AF7->(GetArea())
Local N			:= oGd[2]:nAt

If !FTA531Loop(M->AF2_ORCAME,oGd[2]:aCols[n][2],M->AF2_TAREFA,M->AF2_VERSAO)
	Aviso(STR0030, STR0029, {"Ok"})
	lRet := .F.
EndIf

restArea(aAreaAF7)
restArea(aArea)

Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FTA531Grava� Autor � Vendas CRM           � Data � 08-01-2008 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Faz a gravacao do PreProjeto.                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpL1 - Indica se os registros devem ser deletados            ���
���          �ExpN2 - Numero do recno da tabela AF2                         ���
���          �ExpL3 - Indica se deve exibir a regua de processamento        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �FATA530                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function FTA531Grava(lDeleta,nRecAF2,lProc)

Local aArea		:= GetArea()
Local lAltera	:= (nRecAF2!=Nil)
Local bCampo 	:= {|n| FieldName(n) }
Local nX        := 0
Local nCntFor   := 0
Local nCntFor2  := 0
Local nPosProd	:= 0
Local nPosPrd	:= 0
Local cChave    := ""
Local nOpcMemo  := 0

Default	lProc	:= .F.

//�������������������������������������������������������Ŀ
//�Caso o usuario nao tenha acessado alguma configuracao, �
//�os objetos nao estarao criados.                        �
//���������������������������������������������������������
If (oGd[1] == Nil) .OR. (oGd[2] == Nil)
	Return Nil
EndIf

nPosProd	:= aScan(oGd[1]:aHeader,{|x|AllTrim(x[2])=="AF3_PRODUT"})
nPosPrd		:= aScan(oGd[2]:aHeader,{|x|AllTrim(x[2])=="AF7_PREDEC"})

If lProc
	ProcRegua(Len(oGd[1]:aCols)+Len(oGd[2]:aCols)+Len(oGd[3]:aCols))
EndIf

If !lDeleta
	
	Begin Transaction	

	//������������������������������������������������������Ŀ
	//� Grava o arquivo de de Tarefas do PreProjeto          �
	//��������������������������������������������������������
	If ALTERA
		AF2->(dbGoto(nRecAF2))
		RecLock("AF2",.F.)
	Else
		RecLock("AF2",.T.)
	EndIf

	For nx := 1 TO FCount()
		FieldPut(nx,M->&(EVAL(bCampo,nx)))
	Next nx

	AF2->AF2_FILIAL := xFilial("AF2")

	MsUnlock()
	
	If Type(M->AF2_CODMEM) <> Nil
		cChave := M->AF2_CODMEM
	EndIf
	If Empty(M->AF2_OBS) .And. ALTERA
		nOpcMemo := 2 // Deleta Campo Memo
	Else
		nOpcMemo := 1 // Mantem funcionamento anterior
	EndIf
	
	MSMM(cChave ,TamSx3("AF2_OBS")[1] ,,M->AF2_OBS ,nOpcMemo ,,,"AF2" ,"AF2_CODMEM")
	nRecAF2	:= AF2->(RecNo())
	cPrePro := AF2->AF2_ORCAME
	cEDTPai := AF2->AF2_EDTPAI
	
	//�����������������������������������������������������Ŀ
	//� Grava arquivo AF3 (Despesas)                        �
	//�������������������������������������������������������
	dbSelectArea("AF3")
	
	nPosRecNo:= aScan(oGd[1]:aHeader,{|x|AllTrim(x[2])=="AF3_REC_WT"})
	
	For nCntFor := 1 to Len(oGd[1]:aCols)
		If !oGd[1]:aCols[nCntFor][Len(oGd[1]:aHeader)+1]
			If !Empty(oGd[1]:aCols[nCntFor][nPosProd])
				If oGd[1]:aCols[nCntFor][nPosRecNo] > 0
					dbGoto(oGd[1]:aCols[nCntFor][nPosRecNo])
					RecLock("AF3",.F.)
				Else
					RecLock("AF3",.T.)
				EndIf
				For nCntFor2 := 1 To Len(oGd[1]:aHeader)
					If ( oGd[1]:aHeader[nCntFor2][10] != "V" )
						AF3->(FieldPut(FieldPos(oGd[1]:aHeader[nCntFor2][2]),oGd[1]:aCols[nCntFor][nCntFor2]))
					EndIf
				Next nCntFor2
				AF3->AF3_FILIAL	:= xFilial("AF3")
				AF3->AF3_ORCAME	:= AF2->AF2_ORCAME
				AF3->AF3_VERSAO	:= AF2->AF2_VERSAO
				AF3->AF3_TAREFA	:= AF2->AF2_TAREFA
				MsUnlock()
			EndIf
		Else
			If oGd[1]:aCols[nCntFor][nPosRecNo] > 0
				dbGoto(oGd[1]:aCols[nCntFor][nPosRecNo])
				RecLock("AF3",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
		EndIf

		If lProc
			IncProc()
		EndIf

	Next nCntFor
	
	//�����������������������������������������������������Ŀ
	//� Grava arquivo AF7 (Predecessoras)                   �
	//�������������������������������������������������������
	dbSelectArea("AF7")   
	nPosRecNo:= aScan(oGd[2]:aHeader,{|x|AllTrim(x[2])=="AF7_REC_WT"})
	For nCntFor := 1 to Len(oGd[2]:aCols)
		If !oGd[2]:aCols[nCntFor][Len(oGd[2]:aHeader)+1]
			If !Empty(oGd[2]:aCols[nCntFor][nPosPrd])
				If oGd[2]:aCols[nCntFor][nPosRecNo] > 0
					dbGoto(oGd[2]:aCols[nCntFor][nPosRecNo])
					RecLock("AF7",.F.)
				Else
					RecLock("AF7",.T.)
				EndIf
				For nCntFor2 := 1 To Len(oGd[2]:aHeader)
					If ( oGd[2]:aHeader[nCntFor2][10] != "V" )
						AF7->(FieldPut(FieldPos(oGd[2]:aHeader[nCntFor2][2]),oGd[2]:aCols[nCntFor][nCntFor2]))
					EndIf
				Next nCntFor2
				AF7->AF7_FILIAL	:= xFilial("AF7")
				AF7->AF7_ORCAME	:= AF2->AF2_ORCAME
				AF7->AF7_VERSAO	:= AF2->AF2_VERSAO
				AF7->AF7_TAREFA	:= AF2->AF2_TAREFA
				MsUnlock()
			EndIf
		Else
			If oGd[2]:aCols[nCntFor][nPosRecNo] > 0
				dbGoto(oGd[2]:aCols[nCntFor][nPosRecNo])
				RecLock("AF7",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
		EndIf
		
		If lProc
			IncProc()
		EndIf
		
	Next nCntFor

	//���������������������������������������������������Ŀ
	//� Grava arquivo ADX (Componentes)                   �
	//�����������������������������������������������������
	dbSelectArea("ADX")

	nPosComp := aScan(oGd[3]:aHeader,{|x|AllTrim(x[2])=="ADX_CODCMP"})
	nPosRecNo:= aScan(oGd[3]:aHeader,{|x|AllTrim(x[2])=="ADX_REC_WT"})
	nPosMemo := aScan(oGd[3]:aHeader,{|x|AllTrim(x[2])=="ADX_MEMO"  })   
	
	For nCntFor	:= 1 to Len(oGd[3]:aCols)
		If !aTail(oGd[3]:aCols[nCntFor])
			If !Empty(oGd[3]:aCols[nCntFor][nPosComp])
				If oGd[3]:aCols[nCntFor][nPosRecNo] > 0
					dbGoto(oGd[3]:aCols[nCntFor][nPosRecNo])
					RecLock("ADX",.F.)
				Else
					RecLock("ADX",.T.)
				EndIf
				For nCntFor2 := 1 To Len(oGd[3]:aHeader)
					If (oGd[3]:aHeader[nCntFor2][10] != "V" )
						ADX->(FieldPut(FieldPos(oGd[3]:aHeader[nCntFor2][2]),oGd[3]:aCols[nCntFor][nCntFor2]))
					EndIf
				Next nCntFor2
				ADX->ADX_FILIAL	:= xFilial("ADX")
				ADX->ADX_ORCAME	:= AF2->AF2_ORCAME
				ADX->ADX_VERSAO	:= AF2->AF2_VERSAO
				ADX->ADX_TAREFA	:= AF2->AF2_TAREFA
				
				//����������������Ŀ
				//�Grava campo memo�
				//������������������
				If ( nPosMemo <> 0 )
					If !Empty(oGd[3]:aCols[nCntFor][nPosMemo])
						MSMM(ADX->ADX_CODMEM,,,oGd[3]:aCols[nCntFor][nPosMemo],1,,,"ADX","ADX_CODMEM")
					ElseIf !Empty(ADX->ADX_CODMEM)
						MSMM(ADX->ADX_CODMEM,,,,2)
					EndIf
				EndIf
				
				MsUnlock()
			EndIf
		Else 
			If oGd[3]:aCols[nCntFor][nPosRecNo] > 0
				dbGoto(oGd[3]:aCols[nCntFor][nPosRecNo]) 
				If !Empty(ADX->ADX_CODMEM)
					MSMM(ADX->ADX_CODMEM,,,,2)
				EndIf
				RecLock("ADX",.F.)
				DbDelete()
				MsUnLock()
			EndIf
		EndIf
	Next 

	End Transaction

	ADX->(FkCommit()) 

Else
	
	If lProc
		IncProc()
	EndIf
	
	FTAExcAF2(,,nRecAF2)	
	
EndIf

RestArea(aArea)

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �AGDTudOk� Autor � Vendas Cliente          � Data � 08-01-2008 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao auxiliar utilizada pela EnchoiceBar para executar a   ���
���          � TudOk da GetDados                                            ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1 - Numero da getdados a ser validada                     ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �Validacao TudOk da Getdados                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function AGDTudok(nGetDados)

Local lRet			:= .T.

Eval(oFolder:bSetOption,nGetDados)
oGD[nGetDados]:oBrowse:lDisablePaint := .F.

lRet := oGd[nGetDados]:TudoOk()

Return lRet 

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FTA531Prod� Autor � Vendas Cliente        � Data � 18-05-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de validacao da Predecessora da tarefa ( EDT )         ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpL1 - Indica se foi acionada pela get de produtos adicionais���
���������������������������������������������������������������������������Ĵ��
��� Uso      �FATA531                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function FTA531Prod(lAdic)

Local aArea		:= GetArea()
Local aAreaSB1	:= SB1->(GetArea())
Local aDadosB1	:= {}
Local lRet		:= .T.
Local cProduto	:= &(ReadVar())
Local nPosProd	:= 0
Local nPosDesc	:= 0
Local nPosQuant	:= 0
Local nPosUM	:= 0
Local nX		:= 0
Local N			:= 0

Default lAdic	:= .F.

If lAdic
	aHeader	:= aObj[3][6]:aHeader
	aCols	:= aObj[3][6]:aCols
	N		:= aObj[3][6]:nAt
Else
	aHeader	:= oGD[1]:aHeader
	aCols	:= oGD[1]:aCols
	N		:= oGD[1]:nAt
EndIf 

nPosProd	:= aScan(aHeader,{|x|AllTrim(x[2]) == "AF3_PRODUT"})
nPosDesc	:= aScan(aHeader,{|x|AllTrim(x[2]) == "AF3_DESCRI"})
nPosQuant	:= aScan(aHeader,{|x|AllTrim(x[2]) == "AF3_QUANT"})
nPosUM 		:= aScan(aHeader,{|x|AllTrim(x[2]) == "AF3_UM"})

If !Empty(cProduto)
	lRet := ExistCpo("SB1",cProduto)
EndIf

//����������������������������������������������Ŀ
//�Verifica se a tarefa ainda nao foi selecionada�
//������������������������������������������������
If lRet
	For nX := 1 to Len(aCols)
		If (N <> nX) .AND. !aTail(aCols[nX]) .AND. (aCols[nX][nPosProd] == cProduto)
			lRet	:= .F.
			MsgStop(STR0034,STR0035) //"Este produto ja foi incluido."###"Aten��o"
		EndIf
	Next nX
EndIf

//���������������������Ŀ
//�Preenche a descricao �
//�����������������������
If lRet
	aDadosB1	:= GetAdvFVal("SB1",{"B1_DESC","B1_UM"},xFilial("SB1")+cProduto,1,{"",""})
	aCols[N][nPosDesc]	:= aDadosB1[1]
	aCols[N][nPosUM]		:= aDadosB1[2]
EndIf

RestArea(aAreaSB1)
RestArea(aArea)

Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FTA531PRDE� Autor � Vendas CRM            � Data � 18-05-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de validacao da Predecessora da tarefa ( EDT )         ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �FATA531                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function FTA531PrdE()

Local aArea		:= GetArea()
Local aAreaAF2	:= AF2->(GetArea())
Local lRet		:= .T.
Local cPredec	:= &(ReadVar())
Local nPosDesc	:= aScan(oGd[2]:aHeader,{|x|AllTrim(x[2]) == "AF7_DESCRI"})
Local nPosTask	:= aScan(oGd[2]:aHeader,{|x|AllTrim(x[2]) == "AF7_PREDEC"})
Local nX		:= 0
Local N			:= oGd[2]:nAt

If !Empty(cPredec)
	If cPredec!=M->AF2_TAREFA
		AF2->(DbSetOrder(5))	//AF2_FILIAL+AF2_ORCAME+AF2_VERSAO+AF2_TAREFA+AF2_ORDEM
		lRet := AF2->(DbSeek(xFilial("AF2")+M->AF2_ORCAME+M->AF2_VERSAO+cPredec))
	Else
		MsgStop(STR0036,STR0035)//"A tarefa nao pode ser predecessora dela mesma."###"Aten��o"
		lRet := .F.
	EndIf
EndIf

//����������������������������������������������Ŀ
//�Verifica se a tarefa ainda nao foi selecionada�
//������������������������������������������������
If lRet
	For nX := 1 to Len(oGd[2]:aCols)
		If (N <> nX) .AND. !aTail(oGd[2]:aCols[nX]) .AND. (oGd[2]:aCols[nX][nPosTask] == cPredec)
			lRet	:= .F.
			MsgStop(STR0037,STR0035)//"Esta tarefa ja foi selecionada como predecessora."###"Aten��o"
		EndIf
	Next nX
EndIf

//������������������������������Ŀ
//�Preenche a descricao da tarefa�
//��������������������������������
If lRet
	oGd[2]:aCols[N][nPosDesc]	:= AF2->AF2_DESCRI
EndIf

RestArea(aAreaAF2)
RestArea(aArea)

Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FTA531Loop� Autor � Vendas CRM            � Data � 22-04-2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se existe alguma referencia circular no PreProjeto   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 - Codigo do modelo/projeto                              ���
���          �ExpC2 - Codigo da tarefa atual                                ���
���          �ExpC3 - Codigo da tarefa checada                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �FATA530                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function FTA531Loop(cPrePro,cTarefa,cTskChk,cVersao)
Local lRet 		:= .T.
Local aArea 	:= GetArea()
Local aAreaAF7	:= AF7->(GetArea())

dbSelectArea("AF7")
AF7->(dbSetOrder(3))	//AF7_FILIAL+AF7_ORCAME+AF7_VERSAO+AF7_TAREFA+AF7_ITEM
AF7->(dbSeek(xFilial("AF7")+cPrePro+cVersao+cTarefa))

While lRet .And. !AF7->(Eof()) .And. xFilial("AF7")+cPrePro+cVersao+cTarefa==AF7_FILIAL+AF7_ORCAME+AF7_VERSAO+AF7_TAREFA
	If AF7->AF7_PREDEC == cTskChk
		lRet := .F.
		Exit
	EndIf
	lRet := FTA531Loop(AF7->AF7_ORCAME,AF7->AF7_PREDEC,cTskChk,AF7->AF7_VERSAO)
	dbSelectArea("AF7")
	dbSkip()
End

RestArea(aAreaAF7)
RestArea(aArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Vendas CRM         � Data � 08/01/2008  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,"AxPesqui"  , 0 , 1,,.F.},; //"Pesquisar"
							{ STR0003,"FTA531Dlg", 0 , 2},; //"Visualizar"
							{ STR0004,"FTA531Dlg", 0 , 3},; //"Incluir"
							{ STR0005,"FTA531Dlg", 0 , 4},; //"Alterar"
							{ STR0006,"FTA531Dlg", 0 , 5},; //"Excluir"
							{ STR0007,"MSDOCUMENT",0,4 }} //"Conhecimento"
Return(aRotina)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FT531CMP � Autor � Vendas CRM             � Data � 09-02-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que importa o cadastro de composicoes para uma deter- ���
���          � minada EDT do Orcamento.                                     ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1 - Numero do registro a ser importado                    ���
���          �ExpO2 - Objeto da Tree                                        ���
���          �ExpC3 - Alias do arquivo temporario                           ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �FATA530                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function FT531CMP(nRecAF1,oTree,cArquivo) 

Local oDlg
Local oDescri
Local cDescri    := ''
Local cCompos := SPACE(Len(AE1->AE1_COMPOS))
Local oBold
Local oBmp
Local oQuant		:= Nil
Local lOk        := .F.
Local cAlias     := ""
Local nRecAlias  := 0
Local nQuant		:= 0
Local cTarefa    := Space(TamSx3("AF2_TAREFA")[1])

If oTree != Nil
	// verifica os dados da EDT/Tarefa posicionada no tree
	cAlias:= SubStr(oTree:GetCargo(),1,3)
	nRecAlias:= Val(SubStr(oTree:GetCargo(),4,12))
Else
	cAlias := (cArquivo)->ALIAS
	nRecAlias := (cArquivo)->RECNO
EndIf

If cAlias == "AF5"
	dbSelectArea(cAlias)
	dbGoto(nRecAlias)

	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	DEFINE MSDIALOG oDlg FROM 125,150 TO 400,540 TITLE cCadastro Of oMainWnd PIXEL

		@  17,  0 TO 18 ,245 LABEL '' OF oDlg PIXEL
		@   6, 10 SAY STR0011 Of oDlg PIXEL SIZE 69, 08 FONT oBold //"Importar Composicao"
			
		@  30,  15 SAY STR0013 Of oDlg PIXEL SIZE 58, 08 //'Cod. Composicao'
		@  29,  65 MSGET cCompos Picture PesqPict('AE1','AE1_COMPOS') F3 'AE1';
		           Valid Vazio(cCompos) .Or. RefDlg(@cCompos,@cDescri,@oDescri);
		           OF oDlg PIXEL SIZE 92, 08 HASBUTTON
			
		@  50,  15 SAY STR0014 Of oDlg PIXEL SIZE 43, 08 //"Descricao"
		@  50,  65 GET oDescri VAR cDescri MEMO SIZE 106,33 PIXEL OF oDlg //READONLY
		
		@  90,  15 SAY STR0016 Of oDlg PIXEL SIZE 45, 08 //'Quantidade'
		@  90,  65 GET oQuant VAR nQuant Picture PesqPict('AF2','AF2_QUANT') Valid Positivo(nQuant) OF oDlg PIXEL
			
		@ 115,  92 BUTTON STR0017 SIZE 35 ,11  FONT oDlg:oFont ACTION  (lOk:=.T.,oDlg:End()) OF oDlg PIXEL When !Empty(cCompos) .And. !Empty(nQuant) //"Confirma"
		
		@ 115, 132 BUTTON STR0018 SIZE 35 ,11  FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL  //'Cancela'

	ACTIVATE MSDIALOG oDlg CENTERED

	If lOk 
		nRecAF2 := Ft531Impor(	oTree			,	nRecAF1		,	AF5->AF5_NIVEL	,	cCompos	,	cTarefa	,;
									AF5->AF5_EDT	,	Nil				,	Nil					,	Nil			,	Nil			,;
									Nil				,	cDescri		,	Nil					,	Nil			,	Nil 		,;
									nQuant )
	EndIf
EndIf

Return lOk

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �RefDlg� Autor � Edson Maricate            � Data � 09-02-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Executa a validacao e o refresh dos gets da janela            ���   
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 - Codigo da composicao                                  ���
���          �ExpC2 - Descicao da composicao                                ���
���          �ExpO3 - Objeto da descricao (para refresh)                    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �FATA530                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function RefDlg(cCompos,cDescri,oDescri)

Local aArea		:= GetArea()
Local aAreaAE1	:= AE1->(GetArea())
Local lRet 		:= .T.

AE1->(dbSetOrder(1))
If AE1->(MsSeek(xFilial("AE1") + cCompos))
	Do Case
		// 1 - or�amento/projeto
		// 2 - or�amento
		Case AE1->AE1_USO == "1" .Or. AE1->AE1_USO == "2"
			cDescri := AE1->AE1_DESCRI
			oDescri:Refresh()

		// inativa		
		Case AE1->AE1_USO == "3"
			Aviso(STR0038 ,STR0039, {"OK"})//"Composi��o"###"Esta composi��o est� inativa e n�o pode ser importada ou associada ao orcamento."
			lRet := .F.		

		Otherwise
			lRet := .F.
					
	EndCase
	
Else
	HELP("  ",1,"REGNOIS")
	lRet := .F.	
EndIf

RestArea(aAreaAE1)
RestArea(aArea)

Return lRet

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������Ŀ��
���Fun��o    �Ft531Impor � Autor � Edson Maricate       � Data � 09-02-2001              ���
����������������������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao que importa/associa a composicao no Orcamento.                      ���
����������������������������������������������������������������������������������������Ĵ��
���Parametros�ExpO01 - Objeto da tree do projeto                                         ���
���          �ExpN02 - Numero do registro(RECNO) do projeto (AF1)                        ���
���          �ExpC03 - Nivel atual na arvore                                             ���
���          �ExpC04 - Codigo da composicao                                              ���
���          �ExpC05 - Codigo da tarefa                                                  ���
���          �ExpC06 - Codigo da EDT Pai                                                 ���
���          �ExpL07 - Identifica se cria registro na tabela AF2 - Tarefas               ���
���          �ExpC08 - Numero sequencial do produto (AF3)                                ���
���          �ExpC09 - Numero sequencial da despesa (AF4)                                ���
���          �ExpN10 - Numero do registro da tabela AF2                                  ���
���          �ExpC11 - Codigo do projeto                                                 ���
���          �ExpC12 - Descricao atribuida                                               ���
���          �ExpL13 - Mantem produto/recurso/despesa?                                   ���
���          �ExpC14 - Ultimo item do produto/recurso da tarefa(referencia)              ���
����������������������������������������������������������������������������������������Ĵ��
��� Uso      �PMS101CMP                                                                  ���
�����������������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Static Function Ft531Impor(	oTree		, nRecAF1	, cNivelAtu		, cCompos	,;
							cTarefa		, cEDTPAI	, lCriaAF2		, cItemAF3	,;
							cItemAF4	, nRecAF2	, cPREPRO		, cDescri	,;
							lMantProd	, cItemRec	, cVERSAO		, nQuant)

Local aArea     := GetArea()
Local aAreaAE1  := AE1->(GetArea())
Local aAreaAE2  := AE2->(GetArea())
Local aAreaAE3  := AE3->(GetArea())
Local aAreaAE4  := AE4->(GetArea())
Local aAreaADV  := ADV->(GetArea())
Local aAreaSB1  := SB1->(GetArea())
Local aAreaAF2  := AF2->(GetArea())
Local nRetAF2   := 0
Local nAuxAF2   := 0
Local cNivelTrf := cNivelAtu
Local bCampo    := {|n| FieldName(n) }
Local nx
Local lPadrao   := .T.
Local cAux      := ""
Local cBmp		:= Ft530Bmp("AF2")  
Local cCargo	:= ""
Local lMult	:= SuperGetMv("MV_PMSCUST",.F.,"1") == "1"

DEFAULT lCriaAF2 := .T.
DEFAULT cItemAF3 := "00"
DEFAULT cItemAF4 := "00"
DEFAULT cItemRec := "00"
DEFAULT cPREPRO  := AF1->AF1_ORCAME
DEFAULT cVERSAO  := AF1->AF1_VERSAO
DEFAULT lMantProd := .F.
DEFAULT nQuant	:= 1

dbSelectArea("AE1")
dbSetOrder(1)
If dbSeek(xFilial("AE1")+cCompos)

	Begin Transaction

	If lCriaAF2
		If nRecAF2 == Nil              
			RegToMemory("AF2",.T.)		
			cNivelTrf := StrZero(Val(cNivelTrf) + 1, TamSX3("AF2_NIVEL")[1])
			RecLock("AF2",.T.)
			For nx := 1 TO FCount()
				FieldPut(nx,M->&(EVAL(bCampo,nx)))
			Next nx
			AF2->AF2_FILIAL	:= xFilial("AF2")
			AF2->AF2_ORCAME	:= AF1->AF1_ORCAME
			AF2->AF2_VERSAO	:= AF1->AF1_VERSAO
			AF2->AF2_NIVEL	:= cNivelTrf
	   		AF2->AF2_TAREFA	:= FTAGetNum("2",AF2->AF2_ORCAME,GetNivel(AF2->AF2_ORCAME,cEDTPai),cEDTPai,,,AF2->AF2_VERSAO)
			AF2->AF2_DESCRI	:= IIf(cDescri==Nil .Or.Empty(cDescri),AE1->AE1_DESCRI,cDescri)
			AF2->AF2_UM		:= AE1->AE1_UM
			AF2->AF2_QUANT	:= nQuant
			AF2->AF2_COMPOS	:= cCompos
			AF2->AF2_EDTPAI	:= cEDTPai
			AF2->AF2_GRPCOM	:= AE1->AE1_GRPCOM
			AF2->AF2_TPTARE	:= AE1->AE1_TPTARE
	
			MsUnlock()
			
			Ft530AltTT("AF2",AF2->(Recno()),.T.)
			
		Else

			AF2->(dbGoto(nRecAF2))
			RecLock("AF2",.F.)
			AF2->AF2_DESCRI := IIf(cDescri==Nil .Or.Empty(cDescri),AE1->AE1_DESCRI,cDescri)
			AF2->AF2_UM     := AE1->AE1_UM
			AF2->AF2_QUANT  := nQuant
			AF2->AF2_COMPOS := cCompos
			AF2->AF2_GRPCOM := AE1->AE1_GRPCOM
	
			MsUnlock()
			
			AF3->(DbSetOrder(5))	//AF3_FILIAL+AF3_ORCAME+ AF3_VERSAO+AF3_TAREFA+AF3_ITEM
			AF3->(DbSeek(xFilial("AF3")+AF2->AF2_ORCAME+AF2->AF2_VERSAO+AF2->AF2_TAREFA))
			While AF3->(!Eof()) .And. xFilial("AF3")+AF2->AF2_ORCAME+AF2->AF2_VERSAO+AF2->AF2_TAREFA == ;
								AF3->(AF3_FILIAL+AF3_ORCAME+AF3_VERSAO+AF3_TAREFA)
				If lMantProd == .F. // mantem produto/recurso/despesa?
					RecLock("AF3",.F.,.T.)
					AF3->(DbDelete())
					AF3->(MsUnlock())
					AF3->(DbSkip())
				Else
					//guarda o ultimo item do produto/recurso da tarefa
					If !Empty(AF3->AF3_RECURS)
						cItemRec := AF3->AF3_ITEM
					Else
						cItemAF3 := AF3->AF3_ITEM
					EndIf
				EndIf
				AF3->(DbSkip())
			EndDo
	
			AF4->(DbSetOrder(1))
			AF4->(DbSeek(xFilial("AF4")+AF2->AF2_ORCAME+AF2->AF2_TAREFA))
			While AF4->(!Eof()) .And. xFilial("AF4")+AF2->AF2_ORCAME+AF2->AF2_TAREFA == ;
								AF4->(AF4_FILIAL+AF4_ORCAME+AF4_TAREFA)
				If lMantProd = .F. // mantem produto/recurso/despesa?
					RecLock("AF4",.F.,.T.)
					AF4->(DbDelete())
					AF4->(MsUnlock())
				Else
					//guarda o ultimo item da despesa da tarefa
					cItemAF4 := AF4->AF4_ITEM
				EndIf
				AF4->(DbSkip())
			EndDo
		EndIf
        
		RegToMemory("AF2",.F.)
		nRetAF2	:= AF2->(RecNo())
		cCargo := "AF2"+StrZero(AF2->(RecNo()),12)
		
		//�����������������Ŀ
		//�Importa perguntas�
		//�������������������
		Ft530CpPrg(	"1"		, cCompos  			, "3"	, AF2->AF2_ORCAME	,;
					Nil		, AF2->AF2_TAREFA	,,AF2->AF2_VERSAO,)
	
		oTree:AddItem(AllTrim(Substr(AF2->AF2_DESCRI,1,50)),cCargo,cBmp,cBmp,2) 
		oTree:Refresh()
		
	EndIf

	FkCommit()
	
	//�������������������Ŀ
	//�Importa os produtos�
	//���������������������
	dbSelectArea("AE2")
	dbSetOrder(1)
	dbSeek(xFilial("AE2")+cCompos)
	While !AE2->(Eof()) .And. xFilial("AE2")+cCompos == AE2->AE2_FILIAL+AE2->AE2_COMPOS
		
		//���������������������������������������������������������Ŀ
		//�A mesma tabela e utilizada em 2 abas da composicao, Itens�
		//�e recursos. Somente os itens interessam a este processo  �
		//�����������������������������������������������������������
		If !Empty(AE2->AE2_RECURS)
			AE2->(DbSkip())
			Loop
		EndIf

		RegToMemory("AF3",.T.)		
		RecLock("AF3",.T.)
		For nx := 1 TO FCount()
			FieldPut(nx,M->&(EVAL(bCampo,nx)))
		Next nx
		AF3->AF3_FILIAL	:= xFilial("AF3")
		AF3->AF3_ORCAME	:= IF(lCriaAF2,AF2->AF2_ORCAME,cPREPRO)
		AF3->AF3_VERSAO	:= IF(lCriaAF2,AF2->AF2_VERSAO,cVERSAO)
		AF3->AF3_TAREFA	:= IF(lCriaAF2,AF2->AF2_TAREFA,cTarefa)
		AF3->AF3_PRODUT	:= AE2->AE2_PRODUT 
		AF3->AF3_ITEM	:= AE2->AE2_ITEM
		If lMult
			AF3->AF3_QUANT	:= nQuant * IIf(AE2->AE2_FATOR>0,AE2->AE2_FATOR * AE2->AE2_QUANT,AE2->AE2_QUANT)
		Else
			AF3->AF3_QUANT	:= IIf(AE2->AE2_FATOR>0,AE2->AE2_FATOR * AE2->AE2_QUANT,AE2->AE2_QUANT)
		EndIf
		AF3->AF3_FATOR	:= AE2->AE2_FATOR
		AF3->AF3_CUSTD	:= Posicione( "SB1", 1, xFilial("SB1") + AE2->AE2_PRODUT, "B1_CUSTD" )

		MsUnlock()
	
		AE2->(DbSkip())
	End

	//�������������������Ŀ
	//�Importa componentes�
	//���������������������
	dbSelectArea("ADV")
	dbSetOrder(1)
	dbSeek(xFilial("ADV")+cCompos)
	While !ADV->(Eof()) .And. xFilial("ADV")+cCompos == ADV->ADV_FILIAL+ADV->ADV_COMPOS
		
		cMemoTxt	:= If(Empty(ADV->ADV_CODMEM),"",Msmm(ADV->ADV_CODMEM))
				
		//Importa os campos
		RecLock("ADX",.T.)

		ADX->ADX_FILIAL	:= xFilial("ADX")
		ADX->ADX_ORCAME	:= AF2->AF2_ORCAME
		ADX->ADX_VERSAO	:= AF2->AF2_VERSAO
		ADX->ADX_TAREFA	:= AF2->AF2_TAREFA
		ADX->ADX_ITEM	:= ADV->ADV_ITEM
		ADX->ADX_CODCMP	:= ADV->ADV_CODCMP
		ADX->ADX_ITCOMP	:= ADV->ADV_ITCOMP
		ADX->ADX_QUANT	:= Iif(lMult,nQuant * ADV->ADV_QUANT,ADV->ADV_QUANT) 
		ADX->ADX_OPERA	:= ADV->ADV_OPERA
		ADX->ADX_IMPRES	:= ADV->ADV_IMPRES
		ADX->ADX_IMPMEM	:= ADV->ADV_IMPMEM

		MsUnlock()
		
		//Importa o memo  
		If !Empty(cMemoTxt)
			MSMM(ADX->ADX_CODMEM,,,cMemoTxt,1,,,"ADX","ADX_CODMEM")
		EndIf
	
		ADV->(DbSkip())
	End
	
	End Transaction
	
	//����������������������Ŀ
	//�Importa subcomposicoes�
	//������������������������
	dbSelectArea("AE4")
	dbSetOrder(1)
	dbSeek(xFilial("AE4")+cCompos)
	While !AE4->(Eof()) .And. xFilial("AE4")+cCompos == AE4->AE4_FILIAL+AE4->AE4_COMPOS
		If lCriaAF2
			nAuxAF2 := Ft531Impor(	oTree			, nRecAF1  			, cNivelTrf	, AE4->AE4_SUBCOM	,;
									AF2->AF2_TAREFA	, cEDTPai			, .F.		, @cItemAF3			,;
									@cItemAF4		, AF2->(Recno())	, cPrePro	, cDescri			,;
									Nil				, @cItemRec			, cVERSAO)
		Else
			nAuxAF2 := Ft531Impor(	oTree			, nRecAF1			, cNivelTrf	, AE4->AE4_SUBCOM	,;
									AE4->AE4_QUANT	, cTarefa			, cEDTPai	, @cItemAF3			,;
									@cItemAF4		, AF2->(Recno())	, cPrePro	, cDescri			,;
									Nil				, @cItemRec			, cVERSAO)
		EndIf
		AE4->(dbSkip())
	End

EndIf

RestArea(aAreaAF2)
RestArea(aAreaAE1)
RestArea(aAreaAE2)
RestArea(aAreaAE3)
RestArea(aAreaAE4)
RestArea(aAreaADV)
RestArea(aAreaSB1)
RestArea(aArea)

Return nRetAF2

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FT531AfCo1�Autor  �Vendas Clientes     � Data �  04/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina de inicializacao do campo ADX_DSCCMP, na montagem do ���
���          �aCols                                                       ���
�������������������������������������������������������������������������͹��
���Parametros�ExpA1 - aCols do componente                                 ���
���          �ExpA2 - aHeader do componente                               ���
�������������������������������������������������������������������������͹��
���Uso       �FATA531                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FT531AfCo1(aCols,aHeader)

Local aArea		:= GetArea()
Local nPos		:= Len(aCols)
Local nPCod		:= aScan(aHeader,{|x|AllTrim(x[2])== "ADX_CODCMP"})
Local nPItem	:= aScan(aHeader,{|x|AllTrim(x[2])== "ADX_ITCOMP"})
Local nPDesc	:= aScan(aHeader,{|x|AllTrim(x[2])== "ADX_DSCCMP"})
Local nPDescIt	:= aScan(aHeader,{|x|AllTrim(x[2])== "ADX_DSCITE"})

aCols[nPos][nPDesc]		:= Posicione("ADR",1,xFilial("ADR")+aCols[nPos][nPCod],"ADR_DESCRI")
aCols[nPos][nPDescIt]	:= Posicione("ADU",1,xFilial("ADU")+aCols[nPos][nPCod]+aCols[nPos][nPItem],"ADU_DESC")

RestArea(aArea)

Return .T.
             
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FT531AfCo2�Autor  �Vendas Clientes     � Data �  04/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina de inicializacao do campo AF7_DESCRI, na montagem do ���
���          �aCols                                                       ���
�������������������������������������������������������������������������͹��
���Parametros�ExpA1 - aCols das tarefas associadas                        ���
���          �ExpA2 - aHeader das tarefas associadas                      ���
�������������������������������������������������������������������������͹��
���Uso       �FATA531                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FT531AfCo2(aCols,aHeader)

Local aArea		:= GetArea()
Local nPos		:= Len(aCols)
Local nPCod		:= aScan(aHeader,{|x|AllTrim(x[2])== "AF7_PREDEC"})
Local nPDesc	:= aScan(aHeader,{|x|AllTrim(x[2])== "AF7_DESCRI"})

aCols[nPos][nPDesc]		:= Posicione("AF2",6,xFilial("AF2")+M->AF2_ORCAME+M->AF2_VERSAO+aCols[nPos][nPCod],"AF2_DESCRI")

RestArea(aArea)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FT531Psq  �Autor  �Vendas CRM          � Data �  31/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina de pesquisa (F3) de registros                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Alias a ser tratado na pesquisa                     ���
�������������������������������������������������������������������������͹��
���Uso       �FATA530                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FT531Psq(cAlias)

Local cWhere	:= "" 
Local aCposLst	:= {}
Local nOrder	:= 1  
Local cCpoPesq	:= ""
Local cRetCpo	:= ""
Local cRetorno	:= ""  
Local lRet		:= .F.
Local lContinua	:= .F.
Local cCodComp	:= "" 
Local bSeek		:= Nil
Local cBcoUsado	:= Upper(TcGetDB())
                 
//�������������������������������������������������������������Ŀ
//�Nao eh necessario utilizar o pre-projeto na pesquisa do mesmo�
//���������������������������������������������������������������
Do Case
	Case cAlias == "ADR"
		
		If Empty(M->AF2_TPTARE)
		
			MsgStop(STR0040,STR0035) //"Selecione o tipo desta tarefa antes de selecionar seus componentes."###"Aten��o"
		
		Else
			
			aCposLst	:= {"ADR_CODIGO","ADR_DESCRI"}
			
			If	cBcoUsado <> "ORACLE"
				cWhere		+= " ADT.ADT_CODTAR = '" + M->AF2_TPTARE + "' "
			Else 
				cWhere		+= " ADT.ADT_CODTAR = '" + M->AF2_TPTARE + "' AND ADT_FILIAL = ADR_FILIAL AND ADT_CODCMP = ADR_CODIGO"
			Endif

			//����������������Ŀ
			//�Remove deletados�
			//������������������
			If TcSrvType() != "AS/400"
				cWhere	+= " AND ADT.D_E_L_E_T_ = ' ' "
			Else
				cWhere	+= " AND ADT.@DELETED@ = ' ' "
			EndIf
							
			nOrder		:= 2  
			cCpoPesq	:= "ADR_DESCRI" 
			cRetCpo		:= "ADR_CODIGO"
			
			If	cBcoUsado <> "ORACLE"
				cJoin		:= " INNER JOIN "+RetSqlName("ADT")+" AS ADT ON ADT_FILIAL = ADR_FILIAL AND ADT_CODCMP = ADR_CODIGO "
			Else
				cJoin		:= ", "+RetSqlName("ADT")+" ADT "
			Endif 											
			
			lContinua	:= .T. 
			bSeek		:= {||DbSeek(xFilial(cAlias)+cRetorno)}

        EndIf

	Case cAlias == "ADU"
		
		cCodComp	:= AllTrim(aCols[n][aScan(aHeader,{|x|AllTrim(x[2]) == "ADX_CODCMP" })])
		
		If Empty(cCodComp)
	
			MsgStop(STR0041,STR0035)//"Selecione o componente deste item antes de selecionar seu item de complexidade."###"Aten��o"
	
		Else
	
			aCposLst	:= {"ADU_ITEM","ADU_DESC","ADU_QUANT"}
			
			If	cBcoUsado <> "ORACLE"
				cWhere		+= " ADU.ADU_CODCMP = '" + cCodComp + "' "
			Else 
				cWhere		+= " ADU.ADU_CODCMP = '" + cCodComp + "' AND ADU_FILIAL = ADR_FILIAL AND ADU_CODCMP = ADR_CODIGO"
			Endif
		
			//����������������Ŀ
			//�Remove deletados�
			//������������������
			If TcSrvType() != "AS/400"
				cWhere	+= " AND ADR.D_E_L_E_T_ = ' ' "
			Else
				cWhere	+= " AND ADR.@DELETED@ = ' ' "
			EndIf
			
			If	cBcoUsado <> "ORACLE"
				cJoin		:= " INNER JOIN "+RetSqlName("ADR")+" AS ADR ON ADU_FILIAL = ADR_FILIAL AND ADU_CODCMP = ADR_CODIGO "
			Else 
				cJoin		:= ", "+RetSqlName("ADR")+" ADR  "			
			Endif 
				
			nOrder		:= 2  
			cCpoPesq	:= "ADU_DESC" 
			cRetCpo		:= "ADU_ITEM"
			lContinua	:= .T.
			bSeek		:= {||DbSeek(xFilial(cAlias)+cCodComp+cRetorno)}
	
		EndIf
	
	Case cAlias == "SKG"
		
		aCposLst	:= {"KG_CODQST","KG_DESC","KG_TIPOQST"}
	
		//����������������Ŀ
		//�Remove deletados�
		//������������������
		If TcSrvType() != "AS/400"
			cWhere	+= " SKG.D_E_L_E_T_ = ' ' "
		Else
			cWhere	+= " SKG.@DELETED@ = ' ' "
		EndIf

		cWhere		+= ""
		nOrder		:= 1  
		cCpoPesq	:= "KG_DESC" 
		cRetCpo		:= "KG_CODQST"
		cJoin		:= ""
		lContinua	:= .T.
		bSeek		:= {||DbSeek(xFilial(cAlias)+cRetorno)}


EndCase

If lContinua

	cRetorno := Ft530F3(cAlias	, cWhere	, aCposLst	, nOrder	,;
						cCpoPesq, cRetCpo	, cJoin		)
	
	//�����������������������������������������������������Ŀ
	//�Posiciona alias para que a pesquisa do SXB recupere o�
	//�registro localizado pelo usuario                     �
	//�������������������������������������������������������
	If !Empty(cRetorno)
		(cAlias)->(DbSetOrder(1))
		If (cAlias)->(Eval(bSeek))
			lRet := .T.
		EndIf
	EndIf

EndIf

Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �F531GDFOk	    � Autor � Vendas Clientes   � Data � 31/01/2008 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao Field Ok nas GetDados                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � FATA531                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function F531GDFOk()

Local aArea		:= GetArea()
Local lRet		:= .T.
Local cCampo	:= AllTrim(ReadVar())
Local nPDesc	:= aScan(oGd[3]:aHeader,{|x|AllTrim(x[2])== "ADX_DSCCMP"})
Local nPCod		:= aScan(oGd[3]:aHeader,{|x|AllTrim(x[2])== "ADX_CODCMP"})
Local nPItComp	:= aScan(oGd[3]:aHeader,{|x|AllTrim(x[2])== "ADX_ITCOMP"})
Local nPDescIt	:= aScan(oGd[3]:aHeader,{|x|AllTrim(x[2])== "ADX_DSCITE"})
Local nPQuant	:= aScan(oGd[3]:aHeader,{|x|AllTrim(x[2])== "ADX_QUANT" })
Local nPQtOri	:= aScan(oGd[3]:aHeader,{|x|AllTrim(x[2])== "ADX_QTDORI"})
Local nX		:= 0 
Local cSufixo	:= ""  
Local oObj		:= Nil

Do Case
	Case cCampo == "M->ADX_CODCMP"
	
		If (lRet := Ft531VlCmp(M->ADX_CODCMP,M->AF2_TPTARE))

			oGd[3]:aCols[oGd[3]:nAt][nPDesc]	:= Posicione("ADR",1,xFilial("ADR")+M->ADX_CODCMP,"ADR_DESCRI")
			
			//�������������������������Ŀ
			//�Limpa os campos a direita�
			//���������������������������		
			For nX := (nPCod+2) to Len(oGd[3]:aHeader) 
				If !(IsHeadRec(oGd[3]:aHeader[nX][2]) .Or. IsHeadAlias(oGd[3]:aHeader[nX][2]))
					oGd[3]:aCols[oGd[3]:nAt][nX] := CriaVar(oGd[3]:aHeader[nX][2])
				EndIF
			Next nX
		

		EndIf
		
	Case cCampo == "M->ADX_ITCOMP"
	
		DbSelectArea("ADU")
		DbSetOrder(1) //ADU_FILIAL+ADU_CODCMP+ADU_ITEM
		If DbSeek(xFilial("ADU")+oGd[3]:aCols[oGd[3]:nAt][nPCod]+M->ADX_ITCOMP)
			oGd[3]:aCols[oGd[3]:nAt][nPDescIt]	:= ADU->ADU_DESC

			//���������������������������������������������������������Ŀ
			//�Preenche os campos a direita com base no item selecionado�
			//�����������������������������������������������������������			
			For nX := (nPDescIt + 1) to Len(oGd[3]:aHeader)
				If !(IsHeadRec(oGd[3]:aHeader[nX][2]) .Or. IsHeadAlias(oGd[3]:aHeader[nX][2]))
					cSufixo	:= SubStr(oGd[3]:aHeader[nX][2],At("_",oGd[3]:aHeader[nX][2]),10)
					If (cSufixo <> "_MEMO") 
						If (ADU->(FieldPos("ADU"+cSufixo)) > 0)
							oGd[3]:aCols[oGd[3]:nAt][nX] := ADU->&("ADU"+cSufixo)
						EndIf
					Else
						oGd[3]:aCols[oGd[3]:nAt][nX] := Msmm(ADU->ADU_CODMEM)
					EndIf
				EndIf
			Next nX   
			
			oGd[3]:aCols[oGd[3]:nAt][nPQtOri]	:= oGd[3]:aCols[oGd[3]:nAt][nPQuant]
			oGd[3]:aCols[oGd[3]:nAt][nPItComp]	:= M->ADX_ITCOMP

			Ft531Soma()
					
		Else
			lRet := .F.
		EndIf	 
		
	Case cCampo == "M->ADX_QUANT" 
		
		oGd[3]:aCols[oGd[3]:nAt][nPQuant] := M->ADX_QUANT
		Ft531Soma()

EndCase

RestArea(aArea)

Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �A531GD3LinOk� Autor � Vendas Clientes     � Data � 30-01-2008 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de validacao das Linhas da GetDados.                   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �LinOk da GetDados 3.                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function A531GD3LinOk()
Local lRet 		:= F531ChkCol(@oGd[3])
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F531ChkCol�Autor  �Vendas CRM          � Data �  06/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verificacao dos campos obrigatorios do acols passado        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 - Objeto da GetDados                                  ���
���          �ExpA2 - Lista de campos obrigatorios(alem do SX3)           ���
�������������������������������������������������������������������������͹��
���Uso       �FATA530                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function F531ChkCol(oObj,aObrigOpc)

Local lRet 		:= .T.   
Local nX		:= 0 
Local nAt		:= oObj:nAt

Default aObrigOpc	:= {}

//��������������������������Ŀ
//�Valida campos obrigatorios�
//����������������������������
If !aTail(oObj:aCols[nAt]) .AND. oObj:lModified
	For nX := 1 to Len(oObj:aHeader)
		If Empty(oObj:aCols[nAt][nX]) .AND. (X3Obrigat(oObj:aHeader[nX][2]) .OR. (aScan(aObrigOpc,AllTrim(oObj:aHeader[nX][2]))>0 ))
			Help('',1,'OBRIGAT2')
			lRet := .F.
			Exit
		EndIf
	Next nX
	//Elimina futuras validacoes para o mesmo objeto ate a prox. alteracao
	If lRet
		oObj:lModified := .F.
	EndIf
EndIf

Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �A531GD3TudOK� Autor � Vendas Clientes     � Data � 30-01-2008 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �TudoOk da GetDados 3                                          ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �TudOk da GetDados 3.                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function A531GD3TudOK()

Local lRet		:= A531GD3LinOk()

If lRet	
	Ft531Soma()
EndIf

Return lRet  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft531Soma �Autor  �Vendas CRM          � Data �  02/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza a soma das complexidades e atribui o valor ao produ-���
���          �to da aba de produtos.                                      ���
�������������������������������������������������������������������������͹��
���Uso       �FATA530                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft531Soma(nLinha,nFator,aColsAux)

Local nPQtdHr	:= aScan(oGd[3]:aHeader	,{|x|AllTrim(x[2])== "ADX_QUANT"})
Local nPOpera	:= aScan(oGd[3]:aHeader	,{|x|AllTrim(x[2])== "ADX_OPERA"})
Local nPFator	:= 0
Local nPQtdPr	:= 0
Local nX		:= 0
Local nTotHr	:= 0
Local nTamCols	:= 0

Default aColsAux:= oGd[1]:aCols

nPFator	:= aScan(oGd[1]:aHeader	,{|x|AllTrim(x[2])== "AF3_FATOR"})
nPQtdPr	:= aScan(oGd[1]:aHeader	,{|x|AllTrim(x[2])== "AF3_QUANT"})

//�������������������������������������Ŀ
//�Permite calcular apenas a linha atual�
//���������������������������������������
If nLinha == Nil
	nLinha 		:= 1
	nTamCols	:= Len(aColsAux)
Else
	nTamCols	:= nLinha
EndIf

//���������������������������������������������Ŀ
//�Efetua recalculo do total de horas utilizadas�
//�����������������������������������������������
//Soma componentes
For nX := 1 to Len(oGd[3]:aCols)
	If !aTail(oGd[3]:aCols[nX])
		If oGd[3]:aCols[nX][nPOpera] == "1"
			nTotHr	+= oGd[3]:aCols[nX][nPQtdHr]
		ElseIf oGd[3]:aCols[nX][nPOpera] == "2"
			nTotHr	-= oGd[3]:aCols[nX][nPQtdHr]
		EndIf
	EndIf
Next nX

//Calcula totais na aba de produtos
For nX := nLinha to nTamCols
	If !aTail(aColsAux[nX]) .And. nTotHr <> 0
		aColsAux[nX][nPQtdPr]	:= nTotHr * Iif(nFator<>Nil,nFator,aColsAux[nX][nPFator])
	EndIf
Next nX

Return nTotHr

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATA531   �Autor  �Microsiga           � Data �  02/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft531VlFat()

Local aArea	:= GetArea()
Local lRet	:= Positivo()

If lRet .AND. !aTail(aCols[N]) .AND. !IsInCallStack("Ft531Def")  
	If IsInCallStack("FATA531")
		Ft531Soma(N,&(ReadVar()),@aCols)
	Else
		Ft531Soma(oGd[1]:nAt,&(ReadVar()),@oGd[1]:aCols)
	EndIf
EndIf

RestArea(aArea)

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATA531   �Autor  �Microsiga           � Data �  02/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft531VlCmp(cCompo,cTarefa)

Local lRet		:= .F.
Local aArea		:= GetArea()
Local aAreaADR	:= ADR->(GetArea())

If ADR->(DbSeek(xFilial("ADR")+M->ADX_CODCMP))
	DbSelectArea("ADT")
	DbSetOrder(1)
	If DbSeek(xFilial("ADT")+cTarefa+cCompo)
		lRet := .T.
	Else
		MsgStop(STR0042)//"O componente selecionado n�o pertence ao tipo desta tarefa"
	EndIf
Else
	HELP("  ",1,"REGNOIS")
EndIf
           
RestArea(aAreaADR)
RestArea(aArea)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft531HrCal�Autor  �Vendas Clientes     � Data �  28/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calcula media de horas trabalhadas no calendario, contando  ���
���          �somente dias trabalhados                                    ���
�������������������������������������������������������������������������͹��
���Uso       �FATA530                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft531HrCal(cCalend)

Local aArea		:= GetArea()
Local aAreaSH7	:= SH7->(GetArea())
Local aArrays	:= {}
Local cHoras	:= ""
Local nTotal	:= 0
Local nHoras	:= 0
Local nDiaTrab	:= 0
Local nX 		:= 0
Local nPeriodo	:= 0

PRIVATE nPrecisao	:= SuperGetMV("MV_PRECISA")

DbSelectArea("SH7")
DbSetOrder(1)
DbSeek(xFilial("SH7") + cCalend )

aArrays	:= A780Arrays(2)

For nX := 1 to Len(aArrays)
	cHoras 	:= A640Time(aArrays[nX])
	nHoras	:= HoraToInt(cHoras)
	If nHoras > 0
		nDiaTrab++
		nTotal	+= nHoras
	EndIf
Next nX

nPeriodo := Round(nTotal/nDiaTrab,2)

RestArea(aAreaSH7)
RestArea(aArea)

Return nPeriodo

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft531Def  �Autor  �Vendas Clientes     � Data �  16/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Tela para preenchimento de informacoes comuns ao projeto,   ���
���          �como traslado, fator e turno.                               ���
�������������������������������������������������������������������������͹��
���Uso       �Fata530                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft531Def(lIncModelo)

Local aArea			:= GetArea()
Local oDlg			:= Nil
Local oGetD			:= Nil
Local nX			:= 0
Local aCpoGDa       := {}
Local aAlter		:= {}
Local nSuperior		:= 014				// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda		:= 008				// Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior		:= 140				// Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita		:= 368				// Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
Local nOpc			:= GD_UPDATE
Local cLinOk		:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols
Local cTudoOk		:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local nFreeze		:= 000              // Campos estaticos na GetDados.
Local nMax			:= 999              // Numero maximo de linhas permitidas. Valor padrao 99
Local cFieldOk		:= "AllwaysTrue"    // Funcao executada na validacao do campo
Local cSuperDel		:= ""				// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk		:= "AllwaysTrue"	// Funcao executada para validar a exclusao de uma linha do aCols
Local aHead			:= {}				// Array a ser tratado internamente na MsNewGetDados como aHeader
Local aCol			:= {}				// Array a ser tratado internamente na MsNewGetDados como aCols
Local cAliasSql		:= "TMP1"			// Alias do retorno da query
Local cQuery		:= ""				// Query para pesquisa das informacoes
Local cPropost		:= AF1->AF1_CODORC	// Codigo da proposta
Local cProjeto		:= AF1->AF1_ORCAME	// Codigo do projeto
Local cVersao			:= AF1->AF1_VERSAO	// Versao da simulacao
Local nOpcX			:= 0				// Indica se o usuario confirmou a gravacao
Local aDummy		:= {}				// Array utilizado na funcao FillGetDados, sem outra funcao
Local aColNew		:= {}				// Array aCols da lista de produtos adicionais
Local aAux 			:= {}

Local cHrTurnoDef   := GetMv("MV_FATTRDE",,"08:00")		//Iniciado padrao para campo Turno (AF3_TURNO)
Local cQtTrasla
Public lCancTrans	:= .F.	

Default lIncModelo	:= .F.

//-----------------------------------------------------------------------------------------------------------
// Se for chamado direto da rotina de Modelos desconsidera, pois, a fun��o usa como base informa��es da ADY.
//-----------------------------------------------------------------------------------------------------------
If FunName() <> 'FATA530A'
	cQtTrasla := Ft531Translado()
EndIf

//�������������������������������������������������Ŀ
//�Campos da getdados / campos editaveis da getdados�
//���������������������������������������������������
aCpoGDa	:= {"AF3_PRODUT","AF3_DESCRI","AF3_FATOR","AF3_CALCTR","AF3_TURNO","AF3_HRTRAN"}
aAlter	:= {"AF3_FATOR","AF3_CALCTR","AF3_TURNO","AF3_HRTRAN"}

//Carrega aHead
DbSelectArea("SX3")
SX3->(DbSetOrder(2)) // Campo
For nX := 1 to Len(aCpoGDa)
	If SX3->(DbSeek(aCpoGDa[nX]))
		Aadd(aHead,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE	,;
			SX3->X3_TAMANHO	,;
			SX3->X3_DECIMAL	,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT	,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
	Endif
Next nX

//���������������������������������������������Ŀ
//�Seleciona os produtos utilizados na simulacao�
//�����������������������������������������������
If Select(cAliasSql) > 0
	(cAliasSql)->(DbCloseArea())
EndIf

cQuery	:= "SELECT DISTINCT AF3_PRODUT,AF3_FATOR,AF3_CALCTR,AF3_TURNO,AF3_HRTRAN" 
cQuery	+= " FROM " + RetSqlName("AF3")+ " AF3 "
cQuery	+= " WHERE AF3_FILIAL = '" + xFilial("AF3") + "'"
cQuery	+= " AND AF3_ORCAME = '" + cProjeto + "' AND AF3_VERSAO = '" + cVersao + "' AND  AF3_TAREFA <> '' AND AF3.D_E_L_E_T_ = ' ' "
	
If lIncModelo
	cQuery	+= " AND AF3_CALCTR <> '' "
EndIf
	
cQuery	:= ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSql,.T.,.T.)
DbGoTop()
	        
//�����������������Ŀ
//�Montagem do aCols�
//�������������������
While !Eof()

	aAux := {}
	
	For nX := 1 to Len(aHead)
	
		SX3->(DbSeek(aHead[nX][2]))
		If	Alltrim(aHead[nX][2]) <> "AF3_DESCRI" .AND. Alltrim(aHead[nX][2]) <> "AF3_TURNO" .AND. Alltrim(aHead[nX][2]) <> "AF3_HRTRAN"
			Aadd(aAux,(cAliasSql)->&(aHead[nX][2]))
		Endif 				

		If	aHead[nX][2] == "AF3_DESCRI"
			Aadd(aAux,Posicione("SB1",1,xFilial("SB1")+(cAliasSql)->AF3_PRODUT,"B1_DESC",""))
		Endif
		
		If	Alltrim(aHead[nX][2]) == "AF3_TURNO"
			Aadd(aAux,TransForm(cHrTurnoDef,"99:99"))
		Endif 
		
		If	Alltrim(aHead[nX][2]) == "AF3_HRTRAN" 

			If	EMPTY(TMP1->AF3_HRTRAN)
				Aadd(aAux,TransForm(cQtTrasla,"99:99"))
			Else
				If	Val(cQtTrasla) > 0 .AND. cQtTrasla <> TMP1->AF3_HRTRAN
				
					If	TMP1->AF3_HRTRAN == "00:00"
						Aadd(aAux,TransForm(cQtTrasla,"99:99"))					
					Else 
					
						If	Aviso( STR0035 , STR0050 , { STR0051 , STR0052	 } ) == 1 	//"Aten��o"###"Entidade possui translado informado no cadastro"###"Atualizar"###"Cancelar"
							Aadd(aAux,TransForm(cQtTrasla,"99:99"))
						Else 
							Aadd(aAux,TransForm(TMP1->AF3_HRTRAN,"99:99"))
							lCancTrans := .T.
						Endif 						
					Endif 						
					
				Else 
					Aadd(aAux,TransForm(TMP1->AF3_HRTRAN,"99:99"))									
				Endif 					
			Endif 				
			
		Endif 						

	Next nX
		
	Aadd(aAux,.F.)
	Aadd(aCol,aAux)
	
	DbSkip()
	
End
	
(cAliasSql)->(DbCloseArea())


//������������������������������������������������������Ŀ
//�Se for inclusao de um modelo em um projeto existente, �
//�simplesmente adota os valores atuais como base, sem   �
//�perguntar novamente                                   �
//��������������������������������������������������������
If lIncModelo

	nOpcX := 1
	Ft531GrDef(aCol,aHead,cPropost,cProjeto,.F.,cVersao)

Else

	If	Len(aAux) > 0 

		DEFINE MSDIALOG oDlg TITLE STR0045 FROM 178,181 TO 508,935 PIXEL //"Defini��es do projeto"
	
			// Cria as Groups do Sistema
			@ 003,003 TO 146,373 LABEL STR0046 PIXEL OF oDlg //"Produtos e/ou Servi�os associados a este projeto:"
	
			// Cria Componentes Padroes do Sistema
			DEFINE SBUTTON FROM 150,316 TYPE 1 ENABLE OF oDlg Action (If(Ft531GrDef(oGetD:aCols,oGetD:aHeader,cPropost,cProjeto,,cVersao),(oDlg:End(),nOpcX:=1),.F.))
			DEFINE SBUTTON FROM 150,346 TYPE 2 ENABLE OF oDlg Action oDlg:End()
	
			// Cria ExecBlocks dos Componentes Padroes do Sistema
			oGetD:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,Nil,;
			                             aAlter,nFreeze,Len(aCol),cFieldOk,cSuperDel,cDelOk,oDlg,aHead,aCol)
		
		ACTIVATE MSDIALOG oDlg CENTERED 
	
	Else
	
		MsgAlert(STR0049,STR0035)	//"Nenhum projeto criado/informado op��o de defini��es n�o habilitada"###"Aten��o"

	Endif 	

EndIf

If nOpcX == 1
	
	//�����������������������������������������Ŀ
	//�Atualiza a relacao de produtos adicionais�
	//�������������������������������������������
    aColNew	:= {}
	FillGetDados(4,"AF3",5,xFilial("AF3")+cProjeto+cVersao,{||AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3->AF3_VERSAO},;
		{||Empty(AF3->AF3_TAREFA)},{"AF3_FATOR","AF3_COMPOS","AF3_CALCTR","AF3_TURNO"};
		,,,,,,aDummy,@aColNew)
                  
	aObj[3][6]:SetArray(aColNew,.T.)
	aObj[3][6]:Refresh()	

	//����������������������������Ŀ
	//�Atualiza o total de produtos�
	//������������������������������
	aColNew	:= {}
	aDummy 	:= {}
	Ft530Prod(@aDummy,@aColNew)
	aObj[3][5]:SetArray(aColNew,.T.)
	aObj[3][5]:Refresh()	

EndIf

RestArea(aArea)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft531GrDef�Autor  �Vendas Clientes     � Data �  19/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Aciona a tela 'MsAguarde' para a gravacao das definicoes    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA530                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft531GrDef(aCol,aHead,cPropost,cProjeto,lConfirma,cVersao) 

Local 	lRet 		:= .F.
Default lConfirma	:= .T.

If lConfirma
	lRet := MsgYesNo(STR0047) //"Confirma a grava��o destas defini��es?"
Else
	lRet := .T.
EndIf

If lRet
	MsgRun(STR0048,"",{|| CursorWait(), Ft531GrDe2(aCol,aHead,cPropost,cProjeto,cVersao), CursorArrow()}) //"Salvando defini��es"
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft531GrDe2�Autor  �Vendas Clientes     � Data �  19/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Gravacao das definicoes do projeto                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA530                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft531GrDe2(aCol,aHead,cPropost,cProjeto,cVersao)

Local aArea		:= GetArea()
Local aAreaAF3	:= AF3->(GetArea())
Local aAreaSCJ	:= SCJ->(GetArea())
Local aAreaAD1	:= AD1->(GetArea())
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSUS	:= SUS->(GetArea())
Local nX		:= 0
Local cFilAF3	:= xFilial("AF3")
Local nPProd	:= aScan(aHead,{|x|AllTrim(x[2]) == "AF3_PRODUT"	})
Local nPFator	:= aScan(aHead,{|x|AllTrim(x[2]) == "AF3_FATOR"	})
Local nPCalcu	:= aScan(aHead,{|x|AllTrim(x[2]) == "AF3_CALCTR"	})
Local nPTurno	:= aScan(aHead,{|x|AllTrim(x[2]) == "AF3_TURNO"	})
Local nPVlrTra	:= aScan(aHead,{|x|AllTrim(x[2]) == "AF3_HRTRAN"	})
Local nQuant	:= 0
Local nQtdGrv	:= 0
Local nDecs		:= TamSX3("AF3_QUANT")[2] 
Local cQuery	:= ""       
Local cAliasSql	:= "TMP2"  
Local lNewRec	:= .F.  
Local nRecAF3	:= 0
Local aHeadPro	:= {}
Local aColPro	:= {}
Local nPAcProd	:= 0
Local nPAcQtd	:= 0
Local nQuantVnd	:= 0
Local nHrTurno	:= 0
Local nQtTrasla	:= 0
Local cItem		:= ""

cItem	:= Ft531MaxIt(cProjeto,cVersao)

//Carrega a quantidade de horas padrao para o traslado para prospect/cliente
For nX := 1 to Len(aCol)

	DbSelectArea("AF3")
	DbSetOrder(6) //AF3_FILIAL+AF3_ORCAME+AF3_VERSAO+AF3_PRODUT
	
	AF3->(DbSeek(cFilAF3+cProjeto+cVersao+aCol[nX][nPProd]))

	While !AF3->(Eof()) .AND.;
		AF3->AF3_FILIAL	== cFilAF3 .AND.;
		AllTrim(AF3->AF3_ORCAME) == AllTrim(cProjeto) .AND.;
		AF3->AF3_VERSAO == cVersao .AND.;
		AF3->AF3_PRODUT	== aCol[nX][nPProd]
		
		If !Empty(AF3->AF3_TAREFA)
		
			nQuant	:= Ft531Qtd(AF3->AF3_ORCAME,AF3->AF3_TAREFA,,,AF3->AF3_VERSAO)
			RecLock("AF3",.F.)
			AF3->AF3_FATOR	:= aCol[nX][nPFator]
			AF3->AF3_QUANT	:= Round(nQuant * aCol[nX][nPFator],nDecs)
			AF3->AF3_CALCTR	:= aCol[nX][nPCalcu]
			AF3->AF3_TURNO	:= aCol[nX][nPTurno]
			If	aCol[nX][nPCalcu] == "2"
				AF3->AF3_HRTRAN	:= "00:00"
			Else
				AF3->AF3_HRTRAN	:= aCol[nX][nPVlrTra]			
			Endif 
							
			MsUnLock()
			
		EndIf
		
		AF3->(DbSkip())

	End
Next nX

//Carrega os totais para o projeto (sem produtos adicionais)
Ft530Prod(@aHeadPro,@aColPro,cProjeto,.F.,cVersao)
nPAcProd	:= aScan(aHeadPro,{|x|AllTrim(x[2]) == "AF3_PRODUT"})
nPAcQtd		:= aScan(aHeadPro,{|x|AllTrim(x[2]) == "AF3_QUANT" })

For nX := 1 to Len(aCol)
	
	//Quantidade de horas do produto/servico
	nQuantVnd	:= aColPro[aScan(aColPro,{|x| x[nPAcProd] == aCol[nX][nPProd]})][nPAcQtd]
	
	//��������������������������������������������������������������Ŀ
	//�Antes de incluir o registro do traslado, verifica se existe um�
	//�registro para este produto na aba de produtos adicionais      �
	//����������������������������������������������������������������
	cQuery	:= "SELECT R_E_C_N_O_ AS RECNUM FROM " + RetSqlName("AF3")
	cQuery	+= " WHERE AF3_FILIAL = '" + cFilAF3 + "' AND AF3_ORCAME = '" + cProjeto + "' AND AF3_VERSAO = '"+cVersao+"' "
	cQuery	+= " AND AF3_PRODUT = '" + aCol[nX][nPProd] + "' AND AF3_TAREFA = '' "
	cQuery	+= " AND D_E_L_E_T_ = ' ' "

	cQuery	:= ChangeQuery(cQuery)
	
	If Select(cAliasSql) > 0
		(cAliasSql)->(DbCloseArea())
	EndIf
	
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSql,.T.,.T.)
	DbGoTop()
	
	//�����������������������������������������������Ŀ
	//�Se for um registro ja gravado, armazena o recno�
	//�������������������������������������������������
	If !(cAliasSql)->(Eof())
		lNewRec	:= .F.
		nRecAF3 := (cAliasSql)->RECNUM
	Else
		lNewRec := .T.
	EndIf
	
	(cAliasSql)->(DbCloseArea())
	
	DbSelectArea("AF3")
	
	If !lNewRec
		DbGoTo(nRecAF3)
	EndIf
        
	//�������������������Ŀ
	//�Calculo do traslado�
	//���������������������
	If	aCol[nX][nPCalcu] == "1" .AND. !Empty(aCol[nX][nPTurno])
            
		nHrTurno := Val(aCol[nX][nPTurno])  //Ft531HrCal(aCol[nX][nPTurno])
		nQtTrasla:= (nQuantVnd / nHrTurno) * 2 //Ida + Volta

		//Arredonda para o proximo numero
		If	nQtTrasla <> Int(nQtTrasla)
			nQtTrasla := Int(nQtTrasla+1)
		EndIf
		
		//Tratamento do item
		If lNewRec
			cItem := Soma1(cItem)
		EndIf
		
		nQuant	:= Round(nQtTrasla * Val(aCol[nX][nPVlrTra]) ,nDecs)
		
		If nQuant > 0
			
			nQtdGrv := Round(nQtTrasla * Val(aCol[nX][nPVlrTra]) ,nDecs)
					
			RecLock("AF3",lNewRec)
			AF3->AF3_FILIAL	:= cFilAF3
			AF3->AF3_ITEM	:= If(lNewRec,cItem,AF3->AF3_ITEM)
			AF3->AF3_ORCAME	:= cProjeto
			AF3->AF3_VERSAO  := cVersao
			AF3->AF3_TAREFA	:= ""
			AF3->AF3_PRODUT	:= aCol[nX][nPProd]
			AF3->AF3_QUANT	:= nQtdGrv + Ft530RetAd("P",aCol[nX][nPProd])
			AF3->AF3_MOEDA	:= 1
			MsUnLock()  
		    
			Ft530SomAd("T",aCol[nX][nPProd],nQtdGrv)
			
		EndIf
	
	ElseIf !lNewRec     
		
		If Ft530RetAd("P",aCol[nX][nPProd]) == 0
			//Se nao possui adicional de pergunta, apaga produto adicional
			RecLock("AF3",.F.)
			DbDelete()
			MsUnLock()
		Else
			//Se possui adicional de pergunta, subtrai traslado
			RecLock("AF3",.F.)
			AF3->AF3_QUANT	-= Ft530RetAd("T",aCol[nX][nPProd]) 
			MsUnLock()
		EndIf
	
	EndIf
	
Next nX

RestArea(aAreaAD1)	
RestArea(aAreaAF3)
RestArea(aAreaSCJ)
RestArea(aAreaSA1)
RestArea(aAreaSUS)
RestArea(aArea)
	
Return Nil  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft531Qtd  �Autor  �Vendas Clientes     � Data �  20/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a quantidade de horas para a tarefa selecionada     ���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA530                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft531Qtd(cProjeto,cTarefa,lQtdOri,cModOri,cVersao)

Local aArea		:= Getarea()
Local aAreaADX	:= ADX->(GetArea())
Local cFilADX	:= xFilial("ADX")
Local nQtd		:= 0
Local cQuery	:= "" 
Local cAliasQry	:= "ADXTMP"

Default cTarefa	:= ""
Default lQtdOri  := .F.
Default cModOri  := ""

cTarefa := AllTrim(cTarefa)

#IFDEF TOP

	If Select(cAliasQry) > 0
		(cAliasQry)->(DbCloseArea())
	EndIf

	
	cQuery	:= " SELECT "+IIf(lQtdOri," SUM(ADX_QTDORI) "," SUM(ADX_QUANT) ") + "ADX_QUANT "
	cQuery	+= " FROM " + RetSqlName("ADX")
	cQuery	+= " WHERE ADX_FILIAL = '" + cFilADX + "' AND ADX_ORCAME = '" + cProjeto + "' AND ADX_VERSAO = '" + cVersao + "'"

	If !Empty(cTarefa)
		cQuery	+= " AND ADX_TAREFA = '" + cTarefa + "' "
	ElseIf !Empty(cModOri)
		cQuery	+= " AND ADX_PROORI = '" + cModOri + "' "
	EndIf

	If TcSrvType() != "AS/400"
		cQuery	+= " AND D_E_L_E_T_ = ' ' "
	Else
		cQuery	+= " AND @DELETED@ = ' ' "
	EndIf

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
	DbGoTop()
	
	nQtd := (cAliasQry)->ADX_QUANT
	
	(cAliasQry)->(DbCloseArea())
	
#ELSE

	DbSelectArea("ADX")
	DbSetOrder(2)//ADX_FILIAL+ADX_ORCAME+ADX_VERSAO+ADX_TAREFA+ADX_ITEM
	DbSeek(cFilADX+cProjeto+cVersao+cTarefa)
	
	//����������������������������������Ŀ
	//�Acumula o total de horas da tarefa�
	//������������������������������������
	While !ADX->(Eof()) .AND.;
		ADX->ADX_FILIAL == cFilADX .AND.;
		ADX->ADX_ORCAME == cProjeto .AND.;
		ADX->ADX_VERSAO == cVersao
		If !Empty(cTarefa) .And. ADX->ADX_TAREFA == cTarefa
			nQtd += IIf(lQtdOri,ADX->ADX_QTDORI,ADX->ADX_QUANT)
		ElseIf !Empty(cModOri) .And. ADX->ADX_PROORI == cModOri
			nQtd += IIf(lQtdOri,ADX->ADX_QTDORI,ADX->ADX_QUANT)
		EndIf
		
		ADX->(DbSkip())

	End 

#ENDIF

RestArea(aAreaADX)
RestArea(aArea)

Return nQtd   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft531MaxIt�Autor  �Vendas Clientes     � Data �  21/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o proximo item da tabela AF3, para o projeto atual  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft531MaxIt(cProjeto,cVersao)

Local aArea		:= GetArea()
Local cAliasTmp	:= "TMP3"
Local cQuery	:= ""
Local cItem		:= StrZero(0,TamSX3("AF3_ITEM")[1])

If Select(cAliasTmp) > 0
	(cAliasTmp)->(DbCloseArea())
EndIf

cQuery	:= "SELECT MAX(AF3_ITEM) AF3_ITEM FROM "+ RetSqlName("AF3")
cQuery	+= " WHERE AF3_ORCAME = '" + cProjeto + "'" 
cQuery	+= " AND AF3_VERSAO = '" + cVersao + "'"
cQuery	+= " AND D_E_L_E_T_ = ' '"
cQuery	+= " AND AF3_TAREFA = ''"

cQuery	:= ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp,.T.,.T.)
DbGoTop()

If !Eof() .AND. !Empty((cAliasTmp)->AF3_ITEM)
	cItem	:= (cAliasTmp)->AF3_ITEM
EndIf

(cAliasTmp)->(DbCloseArea())

RestArea(aArea) 

Return cItem


/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �Ft531Translado�Autor  �Eduardo Gomes Junior� Data �  04/09/13   ���
�����������������������������������������������������������������������������͹��
���Desc.     � Pesquisa existencia de translado no cadastro da entidade		  ���
�����������������������������������������������������������������������������͹��
���Uso       � FT531CLT                                                   	  ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function Ft531Translado()

Local aArea		:= GetArea()

Local aAreaADY	:= SCJ->(GetArea())
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSUS	:= SUS->(GetArea())
Local cHrTrasla := "00:00"

If	M->ADY_ENTIDA == "1" 
    
    dbSelectArea("SA1")
    dbSetOrder(1)
    If	dbSeek(xFilial("SA1")+M->ADY_CODIGO+M->ADY_LOJA)
		cHrTrasla := SA1->A1_HRTRANS    
    Endif 
    
Else 

    dbSelectArea("SUS")
    dbSetOrder(1)
    If	dbSeek(xFilial("SUS")+M->ADY_CODIGO+M->ADY_LOJA)
		cHrTrasla := SUS->US_TRASLA    
    Endif 
    
Endif 

RestArea(aArea)
RestArea(aAreaADY)
RestArea(aAreaSA1)
RestArea(aAreaSUS)

Return(cHrTrasla)

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �Ft531CpoTrans�Autor  �Eduardo Gomes Junior� Data �  04/09/13   ���
����������������������������������������������������������������������������͹��
���Desc.     � Valida se o campo AF3_HRTRAN pode ser alterado             	 ���
����������������������������������������������������������������������������͹��
���Uso       � X3_WHEN do campo AF3_HRTRAN                                	 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function Ft531CpoTrans()

Local lRet			:= .T.
Local cQtTrasla		:= Ft531Translado()

If	!EMPTY(cQtTrasla) .AND. !lCancTrans
	MsgInfo(STR0010,STR0001)	//Entidade possui translado informado no cadastro. N�o � poss�vel realizar altera��o###"Aten��o"
	lRet := .F.
Endif 

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} FT531Custo
Realiza o calculo de custos da tarefa na proposta de servi�o
@sample 	FT531Custo( cCampo )
@param		cCampo		, Caracter	, Campo que fez a chamada da fun��o
@Return   	.T.		 	, L�gico   , Sempre retorna .T. pois apenas atualiza os campos de custo do cabe�alho
@author		Squad CRM/Fat
@since		12/05/2021
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Function FT531Custo(cCampo)

Local aRetCus	:= {}
Local nPosCmp	:= 0

Default cCampo	:= ""

If !Empty(cCampo)
	nPosCmp	:= aScan(aHeader,{|x|AllTrim(x[2]) == cCampo})
	If nPosCmp > 0
	//Carrega a informa��o de memoria para o acols para que o calculo seja feito, j� que ainda n�o saiu do campo
		If cCampo == "AF3_QUANT"
			aCols[n][nPosCmp] := M->AF3_QUANT
		ElseIf cCampo == "AF3_CUSTD"
			aCols[n][nPosCmp] := M->AF3_CUSTD
		EndIf
	EndIf
EndIf

//Realiza o calculo de custo assim como � feito no projeto e no or�amento de projeto
aRetCus	:= PmsAF2CusTrf(5)

If Len(aRetCus) > 0		
	M->AF2_CUSTO  := aRetCus[1]
	M->AF2_CUSTO2 := aRetCus[2]	
	M->AF2_CUSTO3 := aRetCus[3]	
	M->AF2_CUSTO4 := aRetCus[4]						
	M->AF2_CUSTO5 := aRetCus[5]
	If cPaisLoc == "BOL"                                                                                                             
		M->AF2_VALIT  := (M->AF2_IT*(M->AF2_VALBDI+M->AF2_VALUTI+M->AF2_CUSTO))/100   
		M->AF2_VALUTI := (M->AF2_UTIL*(M->AF2_VALBDI+M->AF2_VALIT+M->AF2_CUSTO))/100  
	EndIf		
	M->AF2_VALBDI:= aRetCus[1]*IIf(M->AF2_BDI <> 0,M->AF2_BDI,PmsGetBDIPad('AF2',M->AF2_ORCAME,,M->AF2_EDTPAI, M->AF2_UTIBDI ))/100
	M->AF2_TOTAL := aRetCus[1]+M->AF2_VALBDI+IIf(cPaisLoc=="BOL",M->AF2_VALIT+M->AF2_VALUTI,0)
	oEnch:Refresh() //Atualiza cabe�alho da tarefa
EndIf                                            

Return .T.
