#INCLUDE "PROTHEUS.CH" 
#INCLUDE "PCOA014.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PCOTRYEXCEPTION.CH"
Static _aAlfabeto:=FALFABETO()

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � PCOa014		 �Autor  �Kazoolo             � Data � 10/09/2010  ���
������������������������������������������������������������������������������͹��
���Desc.     � Classe para gerar getdados e uma get para digitar f�rmulas      ���
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | olObjWnd: objeto onde ser� criado; 					   ���   
���                 | nRow: Coordenada vertical;         			           ���
���                 | nCol: Coordenada Horizontal;                  		   ���
���                 | nInferior: Altura;                      			       ���
���                 | nDireita: Largura;                               		   ���
���                 | aArrInfo: Informa��es que ser�o preenchidas nas grids da ���
���                 | planilha or�ament�ria de simula��o.					   ���   
������������������������������������������������������������������������������͹��
���Retorno   �  Objeto                                                         ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static __PCOa014Instance
Class PCOa014 

	Data oSay		As Object	// Objeto do TSay
	Data oSay1		As Object	// Objeto do TSay
	Data oButton	As Object	// Objeto do TButton
	Data oButSav	As Object	// Objeto do TButton
	Data oButExc	As Object	// Objeto do TButton
	Data oTGet		As Object	// Objeto do TGet
	Data oGetDd		As Array 	// Objeto do MsNewGetDados
	Data oPanel		As Object	// Objeto do TPanel
	Data oPanel2	As Object	// Objeto do TPanel2
	Data oFolder	As Object	// Objeto do TFolder
	Data clVar		As String	// Variavel que recebe o conte�do do Get de f�rmulas
	Data aPlanCopy	As Array	// C�pia do aCols da MsNewGetDados
	Data aFormul	As Array	// Formulas do Usuario
	Data nHeight	As Integer	// Coordenada inferior do Folder
	Data nWidth		As Integer	// Coordenada direita do Folder
	Data nOpFolder	As Integer	// Numero do Folder selecionado 
	Data nFormLimit As Integer	// Limite de caracteres que poderam ser usados pelo usuario na constru��o das f�rmulas
	Data aPlanBegin 	AS ARRAY
	Data aPlanAnother   AS ARRAY
	Data aAlfabeto
	Data cError
	Data cContaSelect	
	Data lNoExecParse
	Data aLastRanges
	Data oBuilder
	Method New(olObjWnd, nRow, nCol, nInferior, nDireita, bButSav) Constructor
	Method AddPlan(aArrInfo, cTitulo, aWhen, bFuncValid,lRSameFolder) 	//Parametro aWhen acrescentado por Fernando Radu
	Method UpdPlan(aUpdFolders)	//Acrescentado por Fernando Radu em 18/08/10
	Method NewUpdPlan(nFolder,aDataPlan,lRefazGD)
	Method DelPlan(nFolder) //
	Method SetCampoGD(cCampoGD, nNumFolder, cF3, cValid)
	Method GetInfoSave(nNumFolder) 
	Method GetFormula(nFolder, nCampo, nLinha)
	Method SetPlans(aPlan1,aOthers)
	Method GetNumFolder()
	Method FormTran(cTextForm, lVerify, cCell)
	Method FormLimite(nTamLimit)
	Method TranConta(cTextForm)
	Method SetAtualiza(cCell)
	Method ClearLineEmpty(oGetdado) //
	Method AddRange()
 	Method GetValue() 	
 	Method GetCellLinColuna()
	Method DeActivate()
	Method Formulas()
	Method TranPlan()  
	
EndClass 

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � New   		 �Autor  �Kazoolo             � Data � 10/09/2010  ���
������������������������������������������������������������������������������͹��
���Desc.     � Cria objetos visuais. TPanel, TFolder, TGet e TSay e TSay1      ���
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | oWnd: Objeto owner,onde ser� criado o visual deste objeto���   
���                 | alRow: Opcional. Coordenada Vertical;                    ���
���                 | alCol: Opcional. Coordenada Horizontal;                  ���
���                 | nInferior: Opcional. Altura;                             ���
���                 | nDireita: Opcional. Largura.                             ���  
������������������������������������������������������������������������������͹��
���Retorno   �  Objeto instanciado                                             ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method New(oWnd, alRow, alCol, nInferior, nDireita, bButSav) Class PCOa014 
Local olTPanel
Local olTPanel2
Local olTSay
Local olTSay1
Local olTGet
Local olTFolder
Local clTit	:= "New" // New
Local clMensagem

/*************************
* Variaveis para o TSay. *
*************************/
Local abText	:= {|| STR0002 } // F�rmulas 

/*************************
* Variaveis para o TGet. *
*************************/ 
Local blBlock	:= {|u| if( Pcount( )>0, SELF:clVar:= u, SELF:clVar ) } 
Local alRet		:= {}
Local nPosButs	:= 160 //230

Default alRow  		:= 0
Default alCol  		:= 0
Default nInferior 	:= 0
Default nDireita 	:= 0 

If ValType(oWnd) == "O"

	SELF:oGetDd		:= {}
	SELF:aPlanCopy	:= {}
	SELF:aFormul	:= {}
	SELF:nHeight	:= (nInferior - alRow) - 20
	SELF:nWidth		:= (nDireita - alCol)  
	SELF:aAlfabeto	:= aClone(_aAlfabeto)

	//**********************************************************************************
	//* Adiciona o limite padr�o de 600 caracteres para o usu�rio digitar as f�rmulas. *
	//**********************************************************************************
	SELF:nFormLimit := 600 
	SELF:clVar 		:= Space(600)

    olTPanel := TPanel():New(alRow, alCol,"",oWnd,,.T.,,,,nDireita,nInferior+10,.F.,.F.)

 	If nDireita == 0 .And. nInferior == 0
    	olTPanel:Align := CONTROL_ALIGN_ALLCLIENT
    EndIf

	SELF:oPanel := olTPanel

	olTPanel2 := TPanel():New((nInferior - alRow)+5,alCol-8,"",SELF:oPanel,,.T.,,,,(nDireita - alCol),015,.F.,.F.)

	If nInferior == 0
   		olTPanel2:Align := CONTROL_ALIGN_BOTTOM
	EndIf
	SELF:oPanel2 := olTPanel2

	olTSay := TSAY():New(000,000,abText,SELF:oPanel2,,,,,,.T.,,,025,010) // 025,010
	olTSay:Align := CONTROL_ALIGN_LEFT
	SELF:oSay := olTSay

	olTSay1	:= TSAY():New(007,000,{|| },SELF:oPanel2,,,,,,.T.,,,028,010)
	SELF:oSay1 := olTSay1

    olTGet := TGET():New(000,030,blBlock,SELF:oPanel2,nPosButs,012,,,,,,,,.T.,,,{||ALTERA},,,,.F.,.F.,,) // parametro 17 - when 230

	SELF:oTGet := olTGet

	SELF:oButton := tButton():New(002,nPosButs+30,STR0003 ,SELF:oPanel2,{|| Iif( FValidCPO(SELF) , SELF:OGETDD[SELF:nOpFolder]:OBROWSE:SetFocus() , olTGet:SetFocus() ) },030,012,,,,.T.,,,,{||ALTERA},,) // "Executar"

	SELF:oButSav := tButton():New(002,nPosButs+63,STR0097,SELF:oPanel2,{|| bButSav },030,012,,,,.T.,,,,{||ALTERA},,) // "Salvar"

	SELF:oButExc := tButton():New(002,nPosButs+96,STR0098,SELF:oPanel2,{|| FMENUAPLIC(SELF) },030,012,,,,.T.,,,,{||ALTERA},,) // "Aplic.Form"

	olTFolder:= TFolder():New(0,0,,, SELF:oPanel,,,, .T.,,(nDireita - alCol),(nInferior - alRow),)
    olTFolder:bChange := {|| SELF:nOpFolder := SELF:oFolder:nOption }
    SELF:nOpFolder := 1
    If nInferior == 0
		olTFolder:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf
	SELF:oFolder := olTFolder

Else
		clMensagem := STR0006 //Par�metro obrigat�rio inv�lido!
EndIf

If !Empty(clMensagem)
	SetHelp(clTit, clMensagem)
EndIf 

__PCOa014Instance := SELF
SELF:cContaSelect := ""
SELF:lNoExecParse := .F.
SELF:aLastRanges  := {}
SELF:oBuilder := FWExcelExpressionBuild():New()

Return SELF

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � ClearLineEmpty�Autor  �Kazoolo             � Data � 09/08/2010  ���
������������������������������������������������������������������������������͹��
���Desc.     � Deleta as linhas vazias									       ���
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | clCell: C�lula que foi modificada e ser� usada para      ���   
���                 | recalcular outras c�lulas.                               ���
������������������������������������������������������������������������������͹��
���Retorno   �  					                                           ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method ClearLineEmpty(oGetdado) Class PCOa014
Local nI			:= 0
Local nX			:= 0
Local nDel			:= 0
Local lEmpty		:= .T.

Default oGetDado	:= self:oGetdd[self:GetNumFolder()]

For nI := 1 to Len(oGetDado:aCols)
	lEmpty := .T.
	For nX := 1 to Len(oGetDado:aCols[nI])
		If nX <> Len(oGetDado:aCols[nI])
			If !Empty(oGetDado:aCols[nI,nX]) .or. oGetDado:aCols[nI,nX] <> nil
				lEmpty := .F.
				Exit
			Endif
		Endif
	Next nX

	If lEmpty
		aDel(oGetDado:aCols,nI)
		nDel++
	Endif

Next nI

aSize(oGetDado:aCols,Len(oGetDado:aCols)-nDel)
oGetDado:oBrowse:Refresh()

Return()

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA014   �Autor  �Microsiga           � Data �  08/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza o as os valores das celulas com formula            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Method SetAtualiza(clCell,nOpc) Class PCOa014
Local nlLinha
Local nlColuna
Local nlx
Local nly
Local clFormula		:= ""
Local clRet			:= ""
Local clProxCell	:= ""
Local llRecursao	:= Iif(!Empty(clCell),.T.,.F.)
Local lExecSoma		:= .F.
Local lFuncSoma		:= .F.
Local aRet			:= {}
Local cCelAtu:=''
Local nPosCel1:=0
Local nPosCel2:=0
If llRecursao
	alRetFun := FBUSCAPOS(clCell, SELF)
	nlLinha := alRetFun[1]
	nlColuna := alRetFun[2]
Else
	nlLinha	:= SELF:OGETDD[SELF:nOpFolder]:Nat				// Linha posicionada
	nlColuna:= SELF:OGETDD[SELF:nOpFolder]:OBROWSE:COLPOS	// Coluna posicionada
EndIf

If Empty(clCell)
	If Empty(__READVAR)
		clCell := _aAlfabeto[nlColuna]+cValToChar(nlLinha-1)
	Else
		clCell := UPPER(AllTrim(SUBSTR(__READVAR,8,Len(AllTrim(__READVAR))) + AllTrim(Str(nlLinha-1))))
	EndIF
EndIf

If nOpc == 2
	If Len(clCell) < 2
		clCell := _aAlfabeto[nlColuna-1]+cValToChar(nlLinha-1)
	EndIf
EndIf

For nlx := 2 To Len(SELF:aPlanCopy[SELF:nOpFolder])		// Percorrendo as linhas da GetDados do Folder atual.
	If lCircu
		Exit
	Endif
	For nly := 10 To Len(SELF:aPlanCopy[SELF:nOpFolder][nlx])	// Percorrendo as colunas da GetDados do Folder atual.
		If lCircu
			Exit
		Endif
		If At("=",SELF:aPlanCopy[SELF:nOpFolder][nlx][nly]) > 0

			clFormula := AllTrim(SELF:GetFormula(SELF:nOpFolder, nly, nlx))
			lFuncSoma	:= .f.
			// se a formula contem a funcao soma
			If lFuncSoma .And. !(nlColuna == nly .And. nlLinha == nlx)

				// verifica se a celula(x) esta no range da funcao =SOMA(x:y)
				lExecSoma := ExePcoSoma(clCell,clFormula)

				// se sim, executa a funcao soma
				If lExecSoma
					clRet := PCO_SOMA(clFormula,Self)[2]
					If Len(AllTrim(clRet)) <= (TamSX3("AK2_VALOR")[1]-3)
						// atualiza a celula que contem a 
						SELF:OGETDD[SELF:nOpFolder]:ACOLS[nlx][nly] := PadR(clRet,SELF:nFormLimit)
						SELF:aPlanCopy[SELF:nOpFolder][nlx][nly] := clFormula
					Else
						SetHelp("NOSETATUALIZA",STR0100) // "Erro na formula digitada. O resultado � muito grande para ser armazenado no campo AK2_VALOR. Verifique a f�rmula digitada.")
					EndIf
				EndIf
			EndIf
			// se nao vai executar a funcao =SOMA(x:y)
			If !lExecSoma
				if !Empty(clFormula)  .And. !(nlColuna == nly .And. nlLinha == nlx) .And. PCOinRange(clCell,clFormula,SELF)
					cCelAtu:=_aAlfabeto[nly]+cvaltochar(nlx-1)//celula que esta sendo alterada no momento
						nPosCel1:=aScan( aRefCirc, { |x| AllTrim( x[1] ) == Alltrim(clCell) } )//celula que disparou
						nPosCel2:=aScan( aRefCirc, { |x| AllTrim( x[2] ) == Alltrim(cCelAtu) } )//celula que esta sofrendo a alteracao
						If nPosCel1>0 .and. nPosCel2>0 .and. nPosCel1 == nPosCel2 
							lCircu:=.T. //nao pode deixar realizar a referencia circular
							SetHelp("REFCIRCULAR",STR0157+" "+cCelAtu+" "+" "+clCell+" " +STR0158)//"As c�lulas "possuem refer�ncia circular, e n�o poder�o ser calculadas. O Processo ser� interrompido."
							Exit
						Else
								aAdd(aRefCirc,{clCell,cCelAtu})//+=cCelAtu+'|'
						Endif
						aRet := SELF:FormTran(clFormula, .T., clCell)
					If aRet[1]
						If Len(AllTrim(aRet[2])) <= (TamSX3("AK2_VALOR")[1]-3)

							SELF:OGETDD[SELF:nOpFolder]:ACOLS[nlx][nly] := PadR(aRet[2],SELF:nFormLimit)
							SELF:aPlanCopy[SELF:nOpFolder][nlx][nly] := clFormula
							clProxCell := UPPER(SUBSTR(SELF:OGETDD[SELF:nOpFolder]:AHEADER[nly][2],5,LEN(SELF:OGETDD[SELF:nOpFolder]:AHEADER[nly][2])) + AllTrim(Str(nlx-1)))
							
							If clCell <> clProxCell
								SELF:SetAtualiza(clProxCell)
							EndIf

						Else
							SetHelp("NOSETATUALIZA",STR0100) // "Erro na formula digitada. O resultado � muito grande para ser armazenado no campo AK2_VALOR. Verifique a f�rmula digitada.")
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Next nly

Next nlx

SELF:OGETDD[SELF:nOpFolder]:OBROWSE:Refresh()

Return

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � GetNumFolder  �Autor  �Kazoolo             � Data � 02/08/2010  ���
������������������������������������������������������������������������������͹��
���Desc.     � N�mero do folder que est� selecionado no momento			       ���
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:    															   ���
������������������������������������������������������������������������������͹��
���Retorno   � Numero do folder que esta posicionado no momento. 			   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method GetNumFolder() Class PCOa014
Return SELF:nOpFolder

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � GetFormula    �Autor  �Kazoolo             � Data � 02/08/2010  ���
������������������������������������������������������������������������������͹��
���Desc.     � Busca formula digitada no campo selecionado. (nlCampo)          ���
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | nlFolder: Folder onde ser� pesquisado;	 			   ���
���                 | nlCampo: Campo da GetDados que ser� pesquisado.		   ���
���                 | nlLinha: Lonha da GetDados que ser� pesquisado.		   ���
������������������������������������������������������������������������������͹��
���Retorno   � 		clFormula									 			   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method GetFormula(nlFolder, nlCampo, nlLinha) Class PCOa014
Local clFormula		:= Space(SELF:nFormLimit)

Default nlFolder	:= SELF:nOpFolder							// Folder Selecionado
Default nlCampo		:= SELF:OGETDD[nlFolder]:OBROWSE:ColPos		// Campo posicionado
Default nlLinha		:= SELF:OGETDD[nlFolder]:Nat				// Linha posicionada 

If Valtype(SELF:aPlanCopy[nlFolder][nlLinha][nlCampo]) == "C"
	clFormula := PADR(AllTrim(SELF:aPlanCopy[nlFolder][nlLinha][nlCampo]), SELF:nFormLimit)
Endif

If SUBSTR(AllTrim(clFormula),1,1) <> "="
	clFormula := PADR(AllTrim(SELF:OGETDD[nlFolder]:ACOLS[nlLinha][nlCampo]), SELF:nFormLimit)
Endif

Return clFormula

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � FormLimite    �Autor  �Kazoolo             � Data � 02/08/2010  ���
������������������������������������������������������������������������������͹��
���Desc.     �Altera o limite m�ximo de caracteres dos campos.				   ���
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | nlTamanho: Tamanho maximo de caracteres dos campos	   ���
������������������������������������������������������������������������������͹��
���Retorno   � 	SELF											 			   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method FormLimite(nlTamanho) Class PCOa014
Local clTit := "FormLimite"
Local clMensagem

If ValType(nlTamanho) == "N"

	If Len(SELF:oFolder:aDialogs) > 0
		clMensagem := STR0008 + CRLF + STR0009 + AllTrim(Str(SELF:nFormLimit))
		//Esta configura��o � permitida apenas antes do primeiro folder ter sido criado!##Limite atual =
	Else

		If nlTamanho < 600 // Se for menor que default, ser� default
			nlTamanho := 600
		EndIf

		SELF:nFormLimit := nlTamanho
		SELF:clVar		:= Space(nlTamanho)

	Endif

Else
	clMensagem := STR0006 // Par�metro obrigat�rio inv�lido!
EndIf

If !Empty(clMensagem)
	SetHelp(clTit,clMensagem)
EndIf

Return SELF

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � FormTran      �Autor  �Kazoolo             � Data � 02/08/2010  ���
������������������������������������������������������������������������������͹��
��� DESCRICAO:      | Altera c�lulas para seus respectivos valores e trata a   ���
���                 | formula digitada pelo usuario para que os calculos 	   ���
���                 | funcionem corretamente.                                  ���
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | clTextForm: String com a f�rmula digitada pelo usu�rio.  ���
������������������������������������������������������������������������������͹��
���Retorno   � String com as c�lulas trocadas por seus respectivos valores     ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method FormTran(clTextForm,llVerify,clCell) Class PCOa014
Local clString		:= ""	// Esta vari�vel receber� o nome da c�lula se for alpha e o numero se for digito
Local alCells		:= {}	// Este array conter� todas as c�lulas contidas dentro da String clTextForm
Local nlx			:= 0
Local nly			:= 0
Local nlPos			:= 0
Local nX            := 0
Local nXa           := 0
Local clCampoGD		:= ""
Local clNumLin		:= ""
Local clCellTran	:= ""
Local nlPosAcres	:= 0
Local clTit			:= STR0099 // "Interpretador F�rmulas"
Local alRetIter		:= {.F.,""} 
Local nlDecimal		:= Iif(SuperGetMV("MV_PCODEC",,2) > 8 , 8 , SuperGetMV("MV_PCODEC",,2))
Local nlLinha		:= 0
Local nlColuna		:= 0
Local alRetPos		:= {}
Local aRetForm		:= {}
Local cLetraErro    := "ABCDEFGH" //Celular que n�o podem entrar na Formula
lOCAL cNumErro      := "0123456789"
Local lRet          := .T.

Default llVerify	:= .F.
Default clCell		:= ""

If SELF:nOpFolder > 1
	lREt:=.F.
	alRetIter[1]:= .F.
	alRetIter[2]:= STR0159 //'Planilha bloqueada para edi��o.'
Endif

//Verifica se na Formula contem uma das celulas fixas.
If lRet
	If !("PLAN" $ clTextForm) .AND. !("CTA" $ clTextForm) // Se N�o existir a informa��o da conta ou da planilha or�ament�ria
		For nX:=1 To len(alltrim(clTextForm))
			If SubStr(clTextForm,nX,1) $ cLetraErro
				For nXa:=1 To nXa
					If SubStr(clTextForm,nX+1,1) $ cNumErro
					   lRet:=.F.
					Endif
				Next nXa 
				nXa:=0
			Endif
		Next nX
	EndIf
EndIf

//Se tiver na Formula uma das Celulas Fixas dar mensagem de erro.
If !lRet
	alRetIter[1] := .F.
	alRetIter[2] := "#"+STR0101 // 'Sintaxe da f�rmula incorreta! Verifique a f�rmula digitada.'
	Return alRetIter
Endif


If SUBSTR(clTextForm,1,1) == '='

	//*****************************
	//* Chamada do interpretador. *
	//******************************/
	self:cError := ""
	alRetIter := ACLONE(FWEXCELParse(clTextForm,self))

	If alRetIter[1] .And. !llVerify

		// Valida o tamanho do resultado, em rela��o ao AK2_FORM
		If Len(AllTrim(alRetIter[2])) <= (TamSX3("AK2_VALOR")[1]-3)

			//***********************************
			//* Armazenando f�rmula do usu�rio. *
			//***********************************
			SELF:aPlanCopy[SELF:nOpFolder][SELF:OGETDD[SELF:nOpFolder]:Nat][SELF:OGETDD[SELF:nOpFolder]:OBROWSE:ColPos] := Iif(!Empty(&__READVAR), AllTrim(&__READVAR), AllTrim(SELF:clVar))
			            // Folder Atual   /Linha posicionada              //Campo posicionado

			aAdd(SELF:aFormul,{	SELF:nOpFolder,;
								SELF:OGETDD[SELF:nOpFolder]:Nat,;
								SELF:OGETDD[SELF:nOpFolder]:OBROWSE:ColPos,;
								Iif(!Empty(&__READVAR), AllTrim(&__READVAR), AllTrim(SELF:clVar))})
		Else

			alRetIter[1] := .F.
			alRetIter[2] := "#"+STR0100 // "Erro na formula digitada. O resultado � muito grande para ser armazenado no campo AK2_VALOR. Verifique a f�rmula digitada."
			Return alRetIter

		EndIf
	Endif

// Eh apenas numero
ElseIf IsDigit(clTextForm) .Or. SUBSTR(clTextForm,1,1) == '-'

	If Len(AllTrim(clTextForm)) <= (TamSX3("AK2_VALOR")[1]-3)
		alRetIter[1] := .T.
		alRetIter[2] := clTextForm
		Return alRetIter
	Else
		alRetIter[1] := .F.
		alRetIter[2] := "#"+STR0100 // "Erro na formula digitada. O resultado � muito grande para ser armazenado no campo AK2_VALOR. Verifique a f�rmula digitada."			
	EndIf

Else

	alRetIter[1] := .F.
	alRetIter[2] := "#"+STR0101 // 'Sintaxe da f�rmula incorreta! Verifique a f�rmula digitada.'
	Return alRetIter

EndIf

If !alRetIter[1]
	If PadR(alRetIter[2],1) != "#"
		alRetIter[2] := "#"+alRetIter[2]
	EndIf
EndIf

Return alRetIter

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � Formulas      �Autor  �Kazoolo             � Data � 17/09/2010  ���
������������������������������������������������������������������������������͹��
��� DESCRICAO:      | Grava em um array as formulas as serem gravadas na tabela���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | nlFolder = Numero do Folder posicionado                  ���
���                 | nlLinha  = Posic�o da Linha do registro                  ���
���                 | nlCol    = Posic�o da Coluna do registro                 ���
���                 | clFormula= Formula a ser gravada                         ���
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � Array com as formulas a serem gravadas						   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method Formulas(nlForder,nlLinha,nlCol,clFormula) Class PCOa014

	aAdd(apFormul,{	clFormula	,;
					nlForder	,;
					nlLinha		,;
					nlCol		})

Return apFormul

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � Formulas      �Autor  �Kazoolo             � Data � 18/08/2010  ���
������������������������������������������������������������������������������͹��
��� DESCRICAO:      | Substitui as formulas de planilha por seus valores	   ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | clTextForm: Formula para a convers�o					   ���
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � Char - clTextForm     										   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method TranPlan(clTextForm) Class PCOa014
Local nlI		:= 0
Local nlK		:= 0
Local nlJ		:= 0
Local nlL		:= 0
Local nlPosCell	:= 0
Local clNumPlan	:= ""
Local clPlan	:= ""
Local clCell	:= ""
Local clAux		:= ""
Local clRet		:= ""
Local clCellCol	:= ""
Local clCellLin	:= ""
Local alPlan	:= {}

For nlI:=1 to Len(AllTrim(clTextForm))
   	If SubStr(AllTrim(clTextForm),nlI,1) == "!"
   		For nlK:=nlI-1 to 1 step - 1
			If !(SubStr(AllTrim(clTextForm),nlK,1) $ "(,)=0*/+-^%><") .And. ;
				(SubStr(AllTrim(clTextForm),nlK,1) <> '"' .Or. SubStr(AllTrim(clTextForm),nlK,1) <> "'")

				clAux += SubStr(AllTrim(clTextForm),nlK,1)
			Else
				If !Empty(clAux)
					For nlJ=Len(clAux) to 1 step - 1
						clPlan += SubStr(AllTrim(clAux),nlJ,1)
					Next nlJ
				Endif
				For nlJ:=nlI+1 to Len(AllTrim(clTextForm))
					If SubStr(AllTrim(clTextForm),nlJ,1) $ "(,)=0*/+-^%><"
						Exit
					Endif
					clCell += SubStr(AllTrim(clTextForm),nlJ,1)
				Next nlJ

				For nlJ:=1 to Len(clPlan)
					If SubStr(clPlan,nlJ,1) == "N"
						For nlL:=nlJ+1 to Len(clPlan)
							clNumPlan += SubStr(clPlan,nlL,1)
						Next nlL
					Endif
				Next nlJ
				aAdd(alPlan,{clPlan,clCell,clNumPlan})
				clPlan 		:= ""
				clCell 		:= ""
				clNumPlan	:= ""
				clAux		:= ""
				Exit
			Endif
		Next nlK
	Endif
Next nlI

For nlI:=1 To Len(alPlan)

	For nlK:=1 to Len(alPlan[nlI,2])
		If ISALPHA(SUBSTR(alPlan[nlI,2],nlK,1)) .And. (ISALPHA(SUBSTR(alPlan[nlI,2],nlK+1,1)) .Or. ISDIGIT(SUBSTR(alPlan[nlI,2],nlK+1,1)))
			Do Case
				Case ISALPHA(SUBSTR(alPlan[nlI,2],nlK,1)) .And. ISALPHA(SUBSTR(alPlan[nlI,2],nlK+1,1))
			       	clCellCol := SUBSTR(alPlan[nlI,2],nlK,1)+SUBSTR(alPlan[nlI,2],nlK+1,1)

			 	Case ISALPHA(SUBSTR(alPlan[nlI,2],nlK,1)) .And. ISDIGIT(SUBSTR(alPlan[nlI,2],nlK+1,1)) 
			 		clCellCol := SUBSTR(alPlan[nlI,2],nlK,1)
			EndCase
	    Endif
	Next nlK

    For nlK:=1 to Len(alPlan[nlI,2])
    	If ISDIGIT(SUBSTR(alPlan[nlI,2],nlK,1))
    		clCellLin += SUBSTR(alPlan[nlI,2],nlK,1)
    	EndIf
    Next nlK

    nlPosCell := aScan(SELF:OGETDD[Val(alPlan[nlI,3])]:AHEADER,{|x| x[2] == "PCO_"+clCellCol})

	clRet := AllTrim(SELF:OGETDD[Val(alPlan[nlI,3])]:ACOLS[Val(clCellLin)+1][nlPosCell])

	clTextForm := StrTran(clTextForm,alPlan[nlI,1]+"!"+alPlan[nlI,2],clRet)

	clCellCol := ""
	clCellLin := ""

Next nlI

Return clTextForm

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � SetCampoGD    �Autor  �Kazoolo             � Data �  29/07/2010 ���
������������������������������������������������������������������������������͹��
��� DESCRICAO:      | Configura campo espec�fico da Getdados.				   ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | clCampoGD: Campo da GetDados que receber� a configura��o ���
���                 | nlNumFolder: N�mero do Folder onde clCampoGD se encontra ���
���                 | clF3: Opcional. Alias do F3 que ser� inclu�do no campo;  ���
���                 | clValid: Opcional. Valida��o do campo.				   ���
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � 	SELF			     										   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/ 
Method SetCampoGD(clCampoGD, nlNumFolder, clF3, clValid) Class PCOa014
Local nlPos
Local clTit		:= "SetCampoGD"
Local clMensagem

If !Empty(clCampoGD) .And. (!Empty(nlNumFolder) .And. nlNumFolder <= Len(SELF:oFolder:aDialogs))

	//*********************************************************************
	//* Acha a posi��o no array de estruturas o campo em quest�o(aHeader) *
	//*********************************************************************
	nlPos := ASCAN(SELF:OGETDD[nlNumFolder]:AHEADER, {|x| x[2] == clCampoGD})

	If nlPos > 0

	    If !Empty(clF3)
	    	If Len(clF3) > 6
	    		MsgInfo(STR0015 + CRLF + STR0016) // Alias para F3 pode ter ultrapassado quantidade de caracteres! + Talvez n�o funcione corretamente.
	    	EndIf
			SELF:OGETDD[nlNumFolder]:AHEADER[nlPos][9] := clF3
		EndIf

		If !Empty(clValid)
			If Len(clValid) > 128
				MsgInfo(STR0017 + CRLF + STR0016) // Express�o para VALID pode ter ultrapassado quantidade de caracteres! + Talvez n�o funcione corretamente.
			EndIf
			SELF:OGETDD[nlNumFolder]:AHEADER[nlPos][6] := clValid
		EndIf

		//*************************************************
		//* Adiciona o campo no array de campos edit�veis *
		//*************************************************
		AADD(SELF:OGETDD[nlNumFolder]:AALTER,AllTrim(clCampoGD))

		SELF:OGETDD[nlNumFolder]:Refresh()

	Else
		clMensagem := STR0018 // Campo n�o encontrado!
	EndIf
Else
	clMensagem := STR0019 // Par�metros obrigat�rios inv�lidos! - (<Campo GetDados>, <Numero do Folder>,,)
EndIf

If !Empty(clMensagem)
	SetHelp(clTit, clMensagem)
EndIf

Return SELF

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � GetInfoSave   �Autor  �Kazoolo             � Data �  30/07/2010 ���
������������������������������������������������������������������������������͹��
��� DESCRICAO:      | Metodo para recolher as informa��es para a efetiva��o da ���
���                 | simula��o.											   ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | nlNumFolder: N�mero do Folder que ser� retornado o ACols ���
���                 | da MsNewGetDados.				     					   ���
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � 																   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/ 
Method GetInfoSave(nlNumFolder) Class PCOa014
Local clTit := "GetInfoSave"
Local clMensagem

If ValType(nlNumFolder) == "N"
	Return SELF:OGETDD[nlNumFolder]:ACOLS
Else
	clMensagem := STR0006 // Par�metro obrigat�rio inv�lido!
EndIf

If !Empty(clMensagem)
	SetHelp(clTit, clMensagem)
EndIf

Return

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � AddPlan       �Autor  �Kazoolo             � Data �  18/08/2010 ���
������������������������������������������������������������������������������͹��
��� DESCRICAO:      | Adiciona folder com get dados preenchida.				   ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | alArrInfo: Array c/ informa��es a ser enviadas para Acols���
���                 | [1]= Obrigat�rio. Cabe�alho da planilha;				   ���
���                 | [2]= A partir deste as informa��es da planilha na mesma  ���
���                 | ordem do array de primeira posi��o (Cabe�alho);		   ���
���                 | clTitulo: T�tulo do folder;				               ���
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � Folder adicionado. (M�ximo de 6 folders) 					   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method AddPlan(alArrInfo, clTitulo, aWhen, bFuncValid,lRSameFolder) Class PCOa014
Local alColuns	:= {}
Local alLines	:= {}
Local alAlterGD	:= {}
Local olObject	:= Nil
Local clTit		:= "AddPlan"
Local clMensagem
Local nlQtdPla	:= SuperGetMv("MV_LPLAPCO",,5)
Local lGera		:= .F.
Local bFieldOk	:= {|| AllwaysTrue()}
Local nFolder	:= 0
Local lRet		:= .F.
Local llAltPlan	:= .F.
Local alRet		:= {}
Local nA		:= 0
Local nPos		:= 0

Default aWhen			:= {}
DeFault bFuncValid  	:= {||.T.}
Default lRSameFolder	:= .F.

If (!Empty(alArrInfo) .And. ValType(alArrInfo) == "A") .And. (Len(alArrInfo) > 1)

	If lRSameFolder

		nFolder := Self:GetNumFolder()

		If Self:oGetdd[nFolder] <> Nil
			lGera := FCRIAPLAN(alArrInfo, @alColuns, @alLines, SELF:nFormLimit, aWhen)

			SELF:aPlanCopy[nFolder] := alLines

			bFieldOK := Self:oGetdd[nFolder]:bFieldOk

			Self:oGetdd[nFolder]:= nil
        Endif
	Else
		lGera := FCRIAPLAN(alArrInfo, @alColuns, @alLines, SELF:nFormLimit, aWhen)

		aAdd(SELF:aPlanCopy, alLines)

		SELF:oFolder:AddItem(clTitulo, .T.)

		bFieldOk := {|lRet| lRet := A014Valida(Self), IIf(lRet,Iif(Eval(bFuncValid),.t.,.f.),.f.) }

		nFolder := Len(SELF:oFolder:aDialogs)

	EndIf

	If lGera

		olObject :=	MsNewGetDados():New(000, 000, SELF:nHeight, SELF:nWidth,GD_INSERT + GD_UPDATE + GD_DELETE,;
		/*cLinOk*/,/*cTudoOk*/"AlwaysTrue",/*"+PCO_LINHA"*//*cIniCpos*/,;
		alAlterGD/*alAlterGDa*/,001,9999/*nMax*/, /*cFieldOk*/, /*cSuperDel*/,;
		/*cDelOk*/,/*oDLG*/SELF:oFolder:aDialogs[nFolder],/*aHeader*/alColuns,/*aCols*/alLines)

		olObject:BFIELDOK := bFieldOk

		olObject:oBrowse:Align		:= CONTROL_ALIGN_ALLCLIENT
		olObject:BLINHAOK			:= {|| FPOSLIN(SELF:OGETDD[SELF:nOpFolder]:Nat, Len(SELF:OGETDD[SELF:nOpFolder]:ACOLS), SELF:OGETDD[SELF:nOpFolder],SELF) }
		olObject:OBROWSE:BLDBLCLICK := {|| &__READVAR := FCELLPOS(SELF,1)}
		olObject:OBROWSE:BRCLICKED  := {|| Iif(SELF:nOpFolder==1,Iif(ALTERA,FMENUAPLIC(SELF),Nil),&__READVAR := FCELLPOS(SELF,2))}
		
   	    olObject:lDelete := .F.

		If lRSameFolder
			Self:oGetdd[nFolder]:= olObject
		Else
			AADD(SELF:oGetDd,olObject)
		EndIf

	Endif
Else
	clMensagem := STR0024 //N�o foi poss�vel gerar nova planilha. Organiza��o de planilhas inv�lidas!
Endif

If !Empty(clMensagem)
	SetHelp(clTit, clMensagem)
EndIf

Return SELF

// Atualiza os valores da planilha de acordo com o folder informado.

Method NewUpdPlan(nFolder,aDataPlan,lRefazGd) Class PCOa014 
Local aSync			:= {}
Default lRefazGd	:= .F.

If lRefazGd
	Self:AddPlan(aDataPlan[1], Self:oFolder:aDialogs[nFolder]:cCaption, aDataPlan[1], ,lRefazGd)
Else
	aSync := SyncData(Self:oGetDD[nFolder]:aCols,aDataPlan[1],Self:nFormLimit)
	Self:oGetDD[nFolder]:aCols	:= aClone(aSync)

 	aSync := SyncData(Self:oGetDD[nFolder]:aCols,aDataPlan[2],Self:nFormLimit)
 	Self:aPlanCopy[nFolder]		:= aClone(aSync)
Endif

Self:oGetDD[nFolder]:oBrowse:Refresh()

Return(Self)

// Apagar
Method DelPlan(nFolder) Class PCOA014

Self:oGetDD[nFolder]:= nil

aDel(Self:oGetDD,nFolder)

aSize(Self:oGetDD,Len(Self:oGetDD)-1)

aDel(Self:aPlanCopy,nFolder)
aSize(Self:aPlanCopy,Len(Self:aPlanCopy)-1)

Return(Self)

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � UpdPlan       �Autor  �Kazoolo             � Data �  20/08/2010 ���
������������������������������������������������������������������������������͹��
��� DESCRICAO:      | Atualiza getdados conforme conta.        				   ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | aUpdFolders: Array c/ inf. a ser enviadas para Acols     ���
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � 	SELF    								 					   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method UpdPlan(aUpdFolders) Class PCOa014 
Local aAuxCols	:= {}		
Local aNewCols	:= {}
Local aNewFCols	:= {}
Local aAuxForm	:= {}
Local nI		:= 0
Local nX		:= 0
Local nZ		:= 0
Local clConta	:= ""
Local clFilial	:= ""
Local clOrcame	:= ""
Local clVersao	:= ""
Local clDescri	:= ""
Local dDataI	
Local dDataF	
Local aSeries	:= {}
Local aAlltrees	:= {}
Local aGdContas	:= {}

If !Empty(aUpdFolders)
	
	For nI := 1 to len(aUpdFolders) 		
				
		For nX := 1 to len(aUpdFolders[nI,2])
				
			aAuxCols := array(len(Self:oGetDd[aUpdFolders[nI,1]]:aHeader)+1)

			For nZ := 1  to len(aUpdFolders[nI,2,nX])
				aAuxCols[nZ] := PadR(aUpdFolders[nI,2,nX,nZ],self:nFormLimit)
			Next nZ
				
			aAuxCols[Len(aAuxCols)] := .F.
			aAdd(aNewCols,aAuxCols)	
			aAuxCols 	:= {}
			
		Next nX
			
		Self:oGetDd[aUpdFolders[nI,1]]:aCols := {}
		Self:aPlanCopy[aUpdFolders[nI,1]] := {}    
			
		Self:oGetDd[aUpdFolders[nI,1]]:aCols := aClone(aNewCols)
            
		For nX:=1 to Len(aUpdFolders[nI,3])
			
			aAuxForm := array(len(Self:oGetDd[aUpdFolders[nI,1]]:aHeader)+1)
				
			For nZ := 1 to len(aUpdFolders[nI,3,nX])
				aAuxForm[nZ] := PadR(aUpdFolders[nI,3,nX,nZ],self:nFormLimit)
			Next nZ

			aAuxForm[Len(aAuxForm)] := .F.
			aAdd(aNewFCols,aAuxForm)	
			aAuxForm 	:= {}
			nY:=1

		Next nX
			
		Self:aPlanCopy[aUpdFolders[nI,1]] := aClone(aNewFCols)
			
		Self:oGetDd[aUpdFolders[nI,1]]:oBrowse:Refresh()
			
		aNewCols 	:= {}
		aNewFCols	:= {}
			
		clFilial	:= SubStr(aUpdFolders[nI,4,1,1],01,TamSx3("AKE_FILIAL")[1])
		clOrcame	:= SubStr(aUpdFolders[nI,4,1,1],03,TamSx3("AKE_ORCAME")[1])
		clVersao	:= SubStr(aUpdFolders[nI,4,1,1],18,TamSx3("AKE_REVISA")[1])
		clConta		:= aUpdFolders[nI,4,1,2]
		clDescri	:= Posicione("AK1",1,xFilial("AK1")+PadR(clOrcame,TamSX3("AK2_ORCAME")[1]),"AK1_DESCRI")
		dDataI		:= aUpdFolders[nI,4,1,3]
		dDataF		:= aUpdFolders[nI,4,1,4]
		aSeries		:= aUpdFolders[nI,5]
		aGdContas	:= aUpdFolders[nI,6]
		aAlltrees	:= aUpdFolders[nI,7]
			
		SELF:aTree	:= aClone(aAlltrees)
		SELF:aConta	:= aClone(aGdContas)
		SELF:aSeries:= aClone(aSeries)
			
	Next nI
		
Endif


aAdd(SELF:aGraphic,{	clFilial	,;
						clOrcame	,;
						clVersao	,;
						clDescri	,;
						dDataI		,;
						dDataF		,;
						aSeries		,;
						aAlltrees	,;
						aGdContas  	})
	
Return SELF 

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � SetHelp       �Autor  �Kazoolo             � Data �  30/07/2010 ���
������������������������������������������������������������������������������͹��
��� DESCRICAO:      |Mostra um help caso ocorra uma exce��o    				   ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | clTitulo: T�tulo do Help;								   ���
���                 | clMensagem: Mensagem do Help.				               ��� 
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � Help com mensagem de erro.				 					   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function SetHelp(clTitulo, clMensagem)
Return Help("   ", 1, clTitulo, Nil, clMensagem, 1, 0)

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � FCRIAPLAN     �Autor  �Kazoolo             � Data �  30/07/2010 ���
������������������������������������������������������������������������������͹��
��� DESCRICAO:  Monta os arrays que ser�o usados na planilha de simula��o	   ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | aArrInfo: Array enviado por parametro com as informa��es ���
���                 | a serem preenchidas na planilha de simula��o.            ���
���                 | alColuns: Array din�mico, semelhante as colunas do Excel.��� 
���                 | alLines: Array din�mico, semelhante as linhas do Excel.  ��� 
���                 | nlTamLimit := Limite de caracteres dos campos.           ��� 
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � lRet: .T. n�o ocorreu nenhum erro na montagem da planilha	   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function FCRIAPLAN(aArrInfo, alColuns, alLines, nlTamLimit, aWhen)
Local nlX
Local nlY
Local nWhen		:= 0
Local nlChar1	:= Asc('A')
Local nlChar2	:= Asc('A')
Local clCharX	:= "" 
Local lRet		:= .T.
Local nlDecimal	:= Iif(SuperGetMV("MV_PCODEC",,2) > 8 , 8 , SuperGetMV("MV_PCODEC",,2))
Local nIndInfo	:= 0

AADD(alColuns,{"Linha","PCO_LINHA","",6,0,,"","C","","",,,".F."/*When*/})

For nlX := 1 TO Len(aArrInfo[1])

	If Len(clCharX) > 1
		clCharX := SUBSTR(clCharX,1,1) + AllTrim(Chr(nlChar1))
	Else
		clCharX := 	AllTrim(Chr(nlChar1))
	EndIf

	If nlChar1 > Asc('Z')

		nlChar1	:= Asc('A')
		clCharX := AllTrim(Chr(nlChar2++)) + AllTrim(Chr(nlChar1))

	EndIf

	nWhen := aScan(aWhen,aArrInfo[1,nlX])

	If Valtype(aArrInfo[1,nlX]) <> "L"
		//���������������������������������������������������������������������������������������Ŀ
		//�Atencao! Caso haja a necessidade de altera��o da propriedade WHEN deve-se analisar as  �
		//�funcoes FAPLICA e A014VldExp pois avaliam o valor .T. ou .F. presente neste campo.     �
		//�����������������������������������������������������������������������������������������
		AADD(alColuns,{PADC(clCharX, 20,),"PCO_" + clCharX,"",20,0,,"","C","","",,,"n > 1 .and. " + Iif(nWhen > 0,".t.",".f.")/*When*/})
		nlChar1++
	Endif

	If clCharX == "ZZ"
		MsgAlert(STR0025) // Limite de campos exedido
		lRet := .F.
		Exit
	EndIf

Next nlX

If lRet

	For nlY := 1 To Len(aArrInfo)

		AADD(alLines,Array(Len(alColuns)+1))

		For nlX := 1 To Len(alColuns)

			nIndInfo := nlX-1

			If nlX == 1
				alLines[nlY,1] := alltrim(str(nlY-1))
			Else
				If ValType(aArrInfo[nlY][nIndInfo]) == "N"
					alLines[nlY][nlX] := PADR(AllTrim(Str(Round(aArrInfo[nlY][nIndInfo], nlDecimal))),nlTamLimit)
				ElseIf ValType(aArrInfo[nlY][nIndInfo]) == "C"
					alLines[nlY][nlX] := PADR(AllTrim(aArrInfo[nlY][nIndInfo]), nlTamLimit)
				EndIf
            Endif
		Next nlX

		alLines[Len(alLines)][Len(alColuns)+1] := .F.

	Next nlY

EndIf

Return lRet

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � FBUSCAPOS     �Autor  �Kazoolo             � Data �  10/08/2010 ���
������������������������������������������������������������������������������͹��
��� DESCRICAO:      | Busca a posi��o da c�lula no aCols da GetDados em quest�o���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | clCell: C�lula a ser tratada.	                		   ���
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � nlLinha, nlColuna											   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function FBUSCAPOS(clCell, SELF)
Local nlColuna	:= 0
Local nlLinha	:= 0
Local nlx		:= 0

clCell := AllTrim(clCell)

For nlx := 1 To Len(clCell)
	If ISDIGIT(SUBSTR(clCell,nlx,1))
		nlLinha := Val(SUBSTR(clCell,nlx,Len(clCell)))+1
		nlColuna := ASCAN(SELF:OGETDD[SELF:nOpFolder]:AHEADER, {|x| AllTrim(x[2]) == AllTrim("PCO_"+SUBSTR(clCell,1,nlx-1))})
		Exit
	EndIf
Next nlx

Return {nlLinha, nlColuna}

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � FCELLPOS      �Autor  �Kazoolo             � Data �  12/08/2010 ���
������������������������������������������������������������������������������͹��
��� DESCRICAO:      | Informa a celula em que esta posicionado				   ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     |									              		   ���
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � 		SELF										    		   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function FCELLPOS(SELF,nOpc)
Local nlFolder	:= SELF:GetNumFolder()
Local nlCol		:= SELF:OGETDD[nlFolder]:OBROWSE:COLPOS
Local nlLin		:= SELF:OGETDD[nlFolder]:Nat
Local clCell	:= ""

If nlLin-1 <> 0
	clCell := AllTrim(SELF:OGETDD[nlFolder]:AHEADER[nlCol][1]) //SubStr(SELF:OGETDD[nlFolder]:AHEADER[nlCol][2],Len(SELF:OGETDD[nlFolder]:AHEADER[nlCol][2]),1)
	clCell += AllTrim(Str(nlLin-1))
Endif

If ValType(SELF:aPlanCopy[nlFolder][nlLin][nlCol]) == "C"
	If SubStr(SELF:aPlanCopy[nlFolder][nlLin][nlCol],1,1) == "="
		SELF:clVar := PadR(SELF:aPlanCopy[nlFolder][nlLin][nlCol],SELF:nFormLimit)
	Else
		SELF:clVar := PadR(SELF:OGETDD[nlFolder]:ACOLS[nlLin][nlCol],SELF:nFormLimit)
	Endif
Else
	SELF:clVar := PadR(SELF:OGETDD[nlFolder]:ACOLS[nlLin][nlCol],SELF:nFormLimit)
Endif
SELF:oTGet:Refresh()

SELF:oSay1:cCaption:=AllTrim(clCell)
SELF:oSay1:Refresh()

Return (SELF:clVar,Iif(nOpc==1,SELF:OGETDD[SELF:nOpFolder]:EDITCELL(),Nil))

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � FPOSLIN       �Autor  �Kazoolo             � Data �  04/08/2010 ���
������������������������������������������������������������������������������͹��
��� DESCRICAO:      | Valida��o para bloquear a inser��o de linhas no ACols.   ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | nlPos: Linha posicionada no momento;                     ���
���              	| nlLinTot: Total de linhas do ACols;                      ���
���              	| olObjetc: Objeto onde o tratamento est� sendo feito.	   ���								              		   
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � lRet: Variavel de controle, para nao acrescentar linhas		   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function FPOSLIN(nlPos,nlLinTot,olObjetc,SELF)
Local lRet := .T.

If nlPos == nlLinTot
	olObjetc:OBROWSE:NAT := Iif(nlLinTot==1,1,2)
	olObjetc:Refresh()
	lRet := .F.
EndIf

Return lRet

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � FMENUAPLIC     �Autor  �Kazoolo            � Data �  20/11/2010 ���
������������������������������������������������������������������������������͹��
��� DESCRICAO: Rotina para a aplica��o de formulas                             ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     |  														   ���
�������������������������������������������������������������������������������ͱ�
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � 																   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function FMENUAPLIC(SELF)
Local clAplic 	:= Space(10)
Local cInterv	:= Space(15)
Local nlPosTVer	:= 0
Local oBtnAplic
Local oBtnFech
Local oAplic
Local oMemo
Local oInterv
Local oGetInt
Local oExpr

If "P10" $ oApp:cVersion
	If Alltrim(GetTheme()) == "OCEAN" .Or. Alltrim(GetTheme()) == "CLASSIC"
		nlPosTVer:= 200
	Elseif Alltrim(GetTheme()) == "TEMAP10"
		nlPosTVer:= 230
	Endif
Endif

DEFINE MSDIALOG oAplic FROM 000,000 TO 187,432  TITLE STR0001 PIXEL STYLE DS_MODALFRAME of oMainWnd //"Simula��o"

	oBtnAplic	:= tButton():New(02,07,STR0003,oAplic,{|| FAPLICA(SELF,AllTrim(Upper(clAplic)),cInterv,oAplic) },35,12,,,,.T.) //&Executar
	oBtnFech	:= tButton():New(02,44,STR0085,oAplic,{|| oAplic:End()},35,12,,,,.T.) //&Fechar

	oExpr		:= tGroup():New(20,03,60,215, STR0007,oAplic,,,.T.) //"Express�o - F�rmula"
	oMemo		:= tMultiget():New(27,07,{|u|if(Pcount()>0,clAplic:=u,clAplic)},oAplic,205,30,,,,,,.T.)

	oInterv		:= tGroup():New(65,03,88,215,STR0010,oAplic,,,.T.) // "Intervalo"
	oGetInt		:= TGet():New(72,07,{|u| if(PCount()>0,cInterv:=u,cInterv)},oAplic,206,10,"@!",,,,,,,.T.,,,,,,,,,,"cInterv")

oAplic:Activate(,,,.T.,,,)

Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � FAPLICA        �Autor  �Kazoolo            � Data �  20/11/2010 ���
������������������������������������������������������������������������������͹��
��� DESCRICAO: Rotina para a aplica��o de formulas                             ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     |  														   ���
�������������������������������������������������������������������������������ͱ�
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � 																   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function FAPLICA(SELF,clAplic,cInterv,oAplic)
Local lRet			:= .T.
Local clCaracProib	:= "!@#$%�&*()_+{}^~�`][;.>,<=/�����'?*"
Local cCarIni		:= "+-*/)_%"
Local aExpression	:= Nil
Local oParse
Local oPCOObject := self
Local nlI
Local cExpBase
Local nX			:= 0
Local aHeadPlan		:= Self:OGETDD[Self:nOpFolder]:AHEADER
Local aCelInter		:= {} //Celulas contidas no intervalo
Local aTmp			:= {} //Array auxiliar
Local cColuna		:= "" //Identificacao da coluna
Local nPos			:= 0
Local lValida := .T. //caso n�o digitar valor nenhum a flag n�o permite entrar no erro de formula incorreta

cInterv	:= StrTran(cInterv,";",":")
cInterv	:= StrTran(cInterv,",",":")

clAplic := UPPER(AllTrim(clAplic))

oPCOObject:cError:=''

If IsAlpha(PadL(clAplic,1)) .Or. (SubStr(clAplic,2,1) $ cCarIni)
	Aviso(STR0045,STR0013+CRLF+STR0104,{STR0086}) // "Aten��o" ## "Sintaxe da f�rmula incorreta!" ## "Digite uma express�o no formato '=(celula + celula)' ou '=(valor - celula)' ou '=(valor * valor)'" ## "OK"
	lRet := .F.
EndIf

If Empty(clAplic)
	Aviso(STR0045,STR0014,{STR0086}) // "N�o foi incluido nenhum express�o." //"Ok"
	lRet := .F.
	lValida := .F.
ElseIf Empty(cInterv)
	Aviso(STR0045,STR0020,{STR0086}) //"N�o foi informado o intervalo de coluna e linha." //"Ok"
	lRet := .F.
EndIf

//Verifica se ha celulas de colunas nao editaveis no intervalo
aCelInter := STRTOKARR(cInterv,":")
For nX := 1 To Len(aCelInter)

	//Obtem somente a identificacao da coluna
	aTmp := SplitCellEnd(aCelInter[nX])
	cColuna  := Upper(aTmp[2])

	//Localiza a coluna no aHeader
	nPos := Ascan(aHeadPlan, {|x| AllTRIM(x[1]) == cColuna })

	//Avalia se a coluna existe e se eh editavel atraves do campo When
	If nPos == 0 .Or. (".F." $ Upper(aHeadPlan[nPos][13]))
		lRet := .F.
		If lValida == .T.
			Aviso(STR0045,STR0005,{STR0086}) //"Erro na c�lula digitada. Verifique no campo Intervalo as c�lulas digitadas."
		EndIf
		Exit
	EndIf
	
Next nX

If lRet
	If cInterv $ clCaracProib 
		Aviso(STR0045,STR0021,{STR0086}) // "Foi informado caracteres proibidos na Coluna Inicial." //"Ok"
		lRet := .F.
	EndIf
	//Zera as variaveis do parser, e internar para nao resolver range agora
	self:lNoExecParse := .T.
	self:aLastRanges  := {} 
	self:oBuilder:Deactivate()
	self:oBuilder:Activate()
	self:oBuilder:AddPlanLimits("PLAN_ATUAL",22,22)
	If self:oBuilder:SetIntervalo("PLAN_ATUAL",cInterv) // Se o intervalo for validado, ser� executado a f�rmula e o intervalo informado

		clAplic := StrTran(clAplic,CHR(10),"") // Removendo quebras de linhas
		clAplic := StrTran(clAplic,CHR(13),"") // Removendo quebras de linhas
		clAplic := Alltrim(clAplic) // Removendo espa�os em brancos da express�o
		clAplic := Alltrim(SubStr(clAplic,2))

		oParse := FWExpressionParser():New()
		oParse:bRealName  := {|x,y,z,u|   PCOExGetName(x,y,z,u,oPCOObject)}
		oParse:bRangeFunc := {|x,y,z,u,l| PCOExRange(x,y,z,u,l,oPCOObject)}
		oParse:bValidArgs := {|x,y,z|   PCOValidArgs(x,y,z,oPCOObject)}
		oParse:lCanUseNoDelcFuncs := .T.
		oParse:Parser(clAplic)
		lRet := Empty(oParse:Error)
		If lRet
			cExpBase := StrTran(oParse:cParsedInput,"," ,";")
			cExpBase := StrTran(cExpBase,".T." ,STR0124) //"VERDADEIRO"
			cExpBase := StrTran(cExpBase,".F." ,STR0125) //"FALSO"
			cExpBase := StrTran(cExpBase,"." ,",")

			aExpression := self:oBuilder:Build("=" + cExpBase,self:aLastRanges)
	  		If !Empty(aExpression)
				self:lNoExecParse := .F.
				lRet := FATUGTDAD(SELF,aExpression)
				If lRet
					oAplic:End()
					If Type('lCircu')=='U'//se nao existir, deve criar.
						lCircu:=.F.
					Endif
					For nlI:=1 To Len(aExpression)
						If lCircu//na aplicacao da formula ao encontrar referencia circular deve parar.
							lRet:=.F.
							exit
						Endif
						MsgRun( STR0112 , STR0111 , {|| FSetAtu(Self,aExpression,3) }) // "Aguarde... Aplicando as f�rmulas nas demais c�lulas." ## "Aplicador de F�rmulas"
					Next nlI
				EndIf
				SELF:oGetDD[SELF:nOpFolder]:oBrowse:SetFocus()
			Else
				lRet := .F.
				If EMPTY(self:oBuilder:GetError())
					Aviso(STR0045,STR0101,{STR0086})
				Else
					Aviso(STR0045,self:oBuilder:GetError(),{STR0086})
				EndIf
			EndIf

		Else
			lRet := .F.
			If "TOKEN" $ UPPER(oParse:Error)
				oParse:SetError(STR0101)
			EndIf
			Aviso(STR0045,oParse:Error,{STR0086})
		EndIf
	Else
		lRet := .F.
		Aviso(STR0045,self:oBuilder:GetError(),{STR0086})
	EndIf
	
	//Restaura o parser
	self:lNoExecParse := .F.
EndIf

Return lRet

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � FATUGTDAD      �Autor  �Kazoolo            � Data �  20/11/2010 ���
������������������������������������������������������������������������������͹��
��� DESCRICAO: Atualiza getdados com os novos valores feitas pela aplica��o    ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     |  														   ���
�������������������������������������������������������������������������������ͱ�
���Uso     ADMI  �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � 																   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function FATUGTDAD(SELF,alCell,lNoParser)
Local nlI			:= 0
Local clForm		:= ""
Local lRet			:= .T.
Local alPosCell		:= {}
Local alCelulas		:= {}
Local alInterp		:= {}
Local lFuncSoma		:= .F.
Local lFuncCont		:= .F.
Default lNoParser	:= .F.

For nlI:=1 To Len(alCell)

	alPosCell	:= FBUSCAPOS(alCell[nlI,1],SELF)
	alCelulas	:= FALTCELL(alCell[nlI,2])[1]
	clForm		:= alCell[nlI,2]
	lFuncSoma	:= "=SOMA(" $ UPPER(AllTrim(clForm))
	lFuncCont	:= "=CONTA(" $ UPPER(AllTrim(clForm))

	If IsDigit(clForm)
		Aadd(alInterp,.T.)
		Aadd(alInterp,clForm)
	Else
		If lNoParser
			Aadd(alInterp,.T.)
			Aadd(alInterp,clForm)
		Else
			alInterp := FWEXCELParse(clForm,self)
		Endif
	EndIf

	If alInterp[1]
		If Len(AllTrim(alInterp[2])) <= ((TamSX3("AK2_VALOR")[1])-3)
			If Len(SELF:oGetDd[1]:aCols) >= alPosCell[1]
				SELF:oGetDd[1]:aCols[alPosCell[1],alPosCell[2]] := PadR(alInterp[2],SELF:nFormLimit)
				SELF:aPlanCopy[1][alPosCell[1]][alPosCell[2]]	:= PadR(alCell[nlI,2],SELF:nFormLimit)
			Else
				lRet := .F.
				SetHelp("NOFAPLICA",STR0137) // "Erro na formula digitada. O resultado � muito grande para ser armazenado no campo AK2_VALOR. Verifique a f�rmula digitada."				
				Exit
			EndIf
		Else
			lRet := .F.
			SetHelp("NOFAPLICA",STR0100) // "Erro na formula digitada. O resultado � muito grande para ser armazenado no campo AK2_VALOR. Verifique a f�rmula digitada."				
			Exit
		EndIf
	Else
		SetHelp("NOFAPLICA",alInterp[2]) // "Erro na formula digitada. O resultado � muito grande para ser armazenado no campo AK2_VALOR. Verifique a f�rmula digitada."				
		lRet := .F.
		Exit
	Endif

Next nlI

If lRet
	Self:oGetDd[1]:oBrowse:Refresh()
Endif

For nlI := 1 To Len(alCell) 
	alCell[nlI,2] := PadR(alCell[nlI,2],SELF:nFormLimit)
Next nlI

Return lRet

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � FALTCELL      �Autor  �Kazoolo            � Data �  20/11/2010  ���
������������������������������������������������������������������������������͹��
��� DESCRICAO: Array com as celulas que devem ser alteradas                    ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     |  														   ���
�������������������������������������������������������������������������������ͱ�
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � 																   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function FALTCELL(clAplic)
Local nlI		:= 0
Local nlK		:= 0
Local alAlt		:= {}
Local alForm	:= {}
Local clNum		:= ""
Local clCell	:= ""
Local clForm	:= ""
Local clCarac	:= "()/-*+^%;"

For nlI:=1 To Len(clAplic)
	If ISALPHA(SubStr(clAplic,nlI,1)) .And. ISDIGIT(SubStr(clAplic,nlI+1,1))
		aAdd(alForm,clForm)
		clForm := ""

		clCell 	:= SubStr(clAplic,nlI,1)
		nlIni 	:= nlI
		For nlK:=nlI+1 TO Len(clAplic)
			If SubStr(clAplic,nlK,1) $ clCarac
				nlI := nlK-1
				Exit
			Else
				clNum += SubStr(clAplic,nlK,1)
			Endif
		Next nlK
		clCell += clNum
		aAdd(alAlt,clCell)
		clCell	:= ""
		clNum	:= ""
	Elseif ISALPHA(SubStr(clAplic,nlI,1)) .And. ISALPHA(SubStr(clAplic,nlI+1,1)) .And. ISDIGIT(SubStr(clAplic,nlI+2,1))
		aAdd(alForm,clForm)
		clForm := ""

		clCell := SubStr(clAplic,nlI,1)+SubStr(clAplic,nlI+1,1)
		For nlK:=nlI+2 TO Len(clAplic)
			If SubStr(clAplic,nlK,1) $ clCarac
				nlI := nlK-1
				Exit
			Else
				clNum += SubStr(clAplic,nlK,1)
			Endif
		Next nlK
		clCell += clNum
		aAdd(alAlt,clCell)
		clCell 	:= ""
		clNum	:= ""
	Else
		clForm += SubStr(clAplic,nlI,1)
	Endif
Next nlI

If !Empty(clForm)
	If !(AllTrim(clForm) $ "0123456789")
		aAdd(alForm,clForm)
	Endif
Endif

Return {alAlt,alForm}

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � FALFABETO     �Autor  �Kazoolo            � Data �  20/11/2010  ���
������������������������������������������������������������������������������͹��
��� DESCRICAO: Array com as colunas possiveis                                  ���
������������������������������������������������������������������������������͹��
��� PARAMETROS:     |  														   ���
�������������������������������������������������������������������������������ͱ�
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � 																   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function FALFABETO()
Local alAlfa 	:= {}
Local clLetra	:= "A"
Local nlI		:= 0

aAdd(alAlfa,"") // Coluna de representa��o do n�mero da linha da planilhas utilizadas na simula��o estat�stica.
aAdd(alAlfa,clLetra)

For nlI:=1 To 702
	If clLetra ==  "Z"
		clLetra := "AA"
		aAdd(alAlfa,clLetra)
		Loop
	Endif
	If Len(clLetra) == 2
		If SubStr(clLetra,2,1) $ "0123456789"
			clLetra := Soma1(clLetra)
			If SubStr(clLetra,2,1) == "A"
		   		aAdd(alAlfa,clLetra)
		   		Loop
			Else
				Loop
			Endif
		Else
			clLetra := Soma1(clLetra)
			If SubStr(clLetra,2,1) == "0" 
				Loop
			Else
				aAdd(alAlfa,clLetra)
			Endif
		Endif
	Else
	 	clLetra := Soma1(clLetra)
		aAdd(alAlfa,clLetra)
	Endif

	If clLetra == "ZZ"
		Exit
	Endif
Next nlI

Return alAlfa

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � TRANSNUM       �Autor  �Kazoolo            � Data �  06/08/2010 ���
������������������������������������������������������������������������������͹��
��� DESCRICAO:      | Coloca a picture correta quando o resultado final for    ���
���                 | numerico                                       		   ��� 
������������������������������������������������������������������������������͹��
��� PARAMETROS:     | clNum  = Numero a ser convertido                 		   ��� 
���                 | nOpc   = Op��o de retorno                       		   ��� 
���                 |          [1] = Retorno do interpretador com o numero de  ��� 
���                 |                casas decimais determinada pelo usuario   ��� 
���                 |                troca o ponto por virgula                 ��� 
���                 |          [2] = Valida os decimais de cada valor passado  ��� 
���                 |                pela formula                              ��� 
�������������������������������������������������������������������������������ͱ�
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
��� RETORNO:        |Numerico										     	   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function TRANSNUM(clNum,nOpc)
Local nlDecima	:= Iif(SuperGetMV("MV_PCODEC",,2) > 8 , 8 , SuperGetMV("MV_PCODEC",,2))
Local nlI		:= 0
Local nlk		:= 0
Local nlIni		:= 1
Local nlFim		:= Len(AllTrim(clNum))
Local nlUlt		:= 2
Local nlPonto	:= 0
Local nlCont	:= 0
Local clOpera	:= ",+/-*^%()"
Local clTranNum	:= ""
Local alForm	:= {}

If nOpc == 1 

	clNum := STRTRAN( AllTrim(Str(Round(Val(clNum),nlDecima))) , "." , ",")

Else
	For nlI:=nlIni to nlFim
		aAdd(alForm,SubStr(clNum,nlI,1))
	Next nlI

	For nlI:=1 to Len(alForm)
		If alForm[nlI] $ clOpera
			nlCont:=1
			If alForm[nlI] == "-" .And. nlI == nlUlt
				clTranNum += alForm[nlI]
			Else
				For nlK:=nlUlt to Len(alForm)
					If alForm[nlK] $ clOpera
						nlUlt := nlK+1
						Exit
					Else
						clTranNum += alForm[nlK]
					EndIf
				Next nlK

				nlI := nlK

				If Val(clTranNum) <> 0
					If "." $ clTranNum
						For nlK:=1 to Len(clTranNum)
							If SubStr(clTranNum,nlK,1) $ "."
								nlPonto++
							EndIf
						Next nlK

						If nlPonto > 1
							clNum 	:= STR0126 //"Erro"
							nlPonto := 0
							Exit
						EndIf
					EndIf
					clTranNum 	:= ""
					nlPonto 	:= 0
				Else
					clTranNum :=  ""
				EndIf
			Endif
		EndIf
	Next nlI

	If nlCont == 0
		For nlI:=2 to Len(alForm)
			clTranNum += alForm[nlI]
		Next nlI

		If Val(clTranNum) <> 0
			If "." $ clTranNum
				For nlK:=1 to Len(clTranNum)
					If SubStr(clTranNum,nlK,1) $ "."
						nlPonto++
					EndIf
				Next nlK

				If nlPonto > 1
					clNum 	:= STR0126 //"Erro"
					nlPonto := 0
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return clNum

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � SyncData     �Autor  �Kazoolo            � Data �  26/07/2010   ���
������������������������������������������������������������������������������͹��
��� DESCRICAO:      | Sicroniza acols para garantir que exista os campos da    ���
���                 | linha (primeira coluna) e a coluna da informa��o de linha���
���                 | deletada                                                 ���
�������������������������������������������������������������������������������ͱ�
��� PARAMETROS:     | nlP (Capital)										       ���
���					| nlI (Taxa de Juros)								       ���
���					| nlN (Tempo de Aplica��o)				        	       ���
�������������������������������������������������������������������������������ͱ�
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
��� RETORNO:        | Array [1][1] = Resultado Final					       ��� 
���                 |       [1][2] = Valor logico (.T. = Execu��o correta      ��� 
���                 |                     .F. = Execu��o incorreta             ��� 
���                 |       [1][3] = Mensagem de erro                          ��� 
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Function SyncData(aAuxCols,aData,nLimitCell)
Local aSync		:= {}
Local aLinha	:= {}
Local nI		:= 0
Local nX		:= 0
Local lConteudo

If Len(aAuxCols) > Len(aData)
	For nI := 1 To Len(aAuxCols)

		lConteudo := .t.

		For nX := 2 To Len(aAuxCols[nI])-1
			If aAuxCols[nI,nX] == nil
				lConteudo := .f.
			Else
				lConteudo := .t.
			EndIf
		Next nX

		If !lConteudo
			aAdd(aLinha,nI)
		EndIf

	Next nI

	If Len(aLinha) > 0
		For nI := 1 To Len(aLinha)
			aDel(aAuxCols,aLinha[nI])
		Next nI

		aSize(aAuxCols,Len(aLinha))
	EndIf
ElseIf Len(aData) > Len(aAuxCols)

	nDif := Len(aData) - Len(aAuxCols)

	For nI := 1 To nDif
		aAdd(aAuxCols,Array(Len(aAuxCols[1])))
		aAuxCols[Len(aAuxCols),1] := alltrim(Str(Len(aAuxCols)-1))
		aAuxCols[Len(aAuxCols),Len(aAuxCols[Len(aAuxCols)])] := .f.
	Next nI
EndIf

nDif := Len(aAuxCols[Len(aAuxCols)]) - Len(aData[Len(aData)])

If nDif == 1 //caso contenha somente o campo de linha a mais
	For nI := 1 To Len(aData)

		aAdd(aSync,Array(Len(aAuxCols[nI])))

		//Linha
		aSync[nI,1] := aAuxCols[nI,1]

  		For nX := 1 to Len(aData[nI])
  			If ValType(aData[nI,nX]) <> "L"
    			aSync[nI,nX+1] := Padr(PcoCasting(aData[nI,nX],"C"),nLimitCell)
    		Else
    			aSync[nI,nX+1] := aData[nI,nX]
    		EndIf

   		Next nX

	Next nI
ElseIf nDif == 2 //caso contenha o campo de linha e o campo de delecao
	For nI := 1 To Len(aData)

		aAdd(aSync,Array(Len(aAuxCols[nI])))

		//Linha
		aSync[nI,1] := aAuxCols[nI,1]

   		For nX := 1 To Len(aData[nI])

   			If ValType(aData[nI,nX]) <> "L"
    			aSync[nI,nX+1] := Padr(PcoCasting(aData[nI,nX],"C"),nLimitCell)
    		Else
    			aSync[nI,nX+1] := aData[nI,nX]
    		EndIf
   		Next nX

   		aAdd(aSync,Array(Len(aAuxCols[nI])))
   		aSync[nI,Len(aSync)] := aAuxCols[nI,Len(aAuxCols[nI])]

	Next nI
Else
	aSync := aClone(aData)

	For nI := 1 To Len(aSync)
		For nX := 2 To Len(aSync[nI])-1
			aSync[nI,nX] := PadR(PcoCasting(aSync[nI,nX],"C"),nLimitCell)
		Next nX
	Next nI
EndIf

Return(aSync)

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � FVALIDCPO     �Autor  �Kazoolo             � Data �  12/08/2010 ���
������������������������������������������������������������������������������͹��
���DESCRICAO:|Valida entradas do campo formulas, botao executar				   ���
������������������������������������������������������������������������������͹��
���PARAMETRO:|Self				    					              		   ���
������������������������������������������������������������������������������͹��
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
���Retorno   � L�gico - lRetorno								    		   ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function FVALIDCPO(Self)
Local lRet := .F.

If PadL(AllTrim(Self:clVar),1) == "="
	Self:clVar := UPPER( PadR( Self:clVar , SELF:nFormLimit ) )
	lRet := A014VldExp(Self,2)
	If lRet
		MsgRun( STR0112 , STR0111 , {|| FSetAtu(SELF,Nil,2) }) // "Aguarde... Aplicando as f�rmulas nas demais c�lulas." ## "Aplicador de F�rmulas"
	EndIf
Else
	lRet := .T.
EndIf

Return lRet

/* 
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � PCO_JCOM     �Autor  �Kazoolo            � Data �  26/07/2010   ���
������������������������������������������������������������������������������͹��
��� DESCRICAO:      | Valida c�lula da getdados						   ���
�������������������������������������������������������������������������������ͱ�
��� PARAMETROS:     | nlP (Capital)										       ���
���					| nlI (Taxa de Juros)								       ���
���					| nlN (Tempo de Aplica��o)				        	       ���
�������������������������������������������������������������������������������ͱ�
���Uso       �SigaPco                                                     	   ���
������������������������������������������������������������������������������͹��
��� RETORNO:        | Array [1][1] = Resultado Final					       ��� 
���                 |       [1][2] = Valor logico (.T. = Execu��o correta      ��� 
���                 |                     .F. = Execu��o incorreta             ��� 
���                 |       [1][3] = Mensagem de erro                          ��� 
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Function A014Valida(Self)
Local lRet := .T.

If AllTrim(&__ReadVar) == AllTrim(SELF:OGETDD[SELF:nOpFolder]:aCols[SELF:OGETDD[SELF:nOpFolder]:Nat][SELF:OGETDD[SELF:nOpFolder]:OBROWSE:COLPOS])
	lRet := .T.
Else
	&__ReadVar := UPPER( PadR( &__REadVar , SELF:nFormLimit ) )
	lRet := A014VldExp(Self,1)
	If lRet
		MsgRun( STR0112 , STR0111 , {|| FSetAtu(SELF,Nil,1) }) // "Aguarde... Aplicando as f�rmulas nas demais c�lulas." ## "Aplicador de F�rmulas"
	EndIf
EndIf

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A014VldExp�Autor  �Microsiga           � Data �  07/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida a expressao digitada                                 ���
�������������������������������������������������������������������������͹��
���Uso       �PCOA014                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function A014VldExp(SELF,nOpcx,cFAplExp,aCelFrm)
Local lRet			:= .F.
Local aRetFrmTr		:= {}
Local cBkpCols		:= ""
Local cBkpFVar		:= ""
Local cBkpRead		:= ""
Local cFrmAK2		:= ""
Local nI			:= 0
Local nPosCol		:= 0
Local nPosLin		:= 0
Local aTmp			:= {}
Local cLinha		:= ""
Local cColuna		:= ""

Default cFAplExp := ""
Default aCelFrm  := {}

Do Case

	// valida linha do aCols, chamado pelo enter na celula do aCols
	Case ProcName(1) == 'A014VALIDA' .And. nOpcx == 1

		cBkpCols	:= SELF:OGETDD[SELF:nOpFolder]:aCols[SELF:OGETDD[SELF:nOpFolder]:Nat][SELF:OGETDD[SELF:nOpFolder]:OBROWSE:COLPOS]
		cBkpFVar	:= SELF:clVar
		cBkpRead	:= &__ReadVar
		cFrmAK2		:= SELF:aPlanCopy[SELF:nOpFolder][SELF:OGETDD[SELF:nOpFolder]:Nat][SELF:OGETDD[SELF:nOpFolder]:OBROWSE:ColPos]
		aRetFrmTr := SELF:FormTran(&__ReadVar)

		If aRetFrmTr[1] // se o resultado da formula for valido

			// aCols
			SELF:OGETDD[SELF:nOpFolder]:aCols[SELF:OGETDD[SELF:nOpFolder]:Nat][SELF:OGETDD[SELF:nOpFolder]:OBROWSE:COLPOS] := PadR(aRetFrmTr[2],SELF:nFormLimit)
			SELF:OGETDD[SELF:nOpFolder]:OBROWSE:Refresh()
			// memoria
			&__ReadVar := PADR(aRetFrmTr[2],SELF:nFormLimit)
			// formulas
			SELF:clVar := PADR(&__ReadVar,SELF:nFormLimit)
			SELF:oTGet:Refresh()
			// AK2_FORM
			If PadL(AllTrim(cBkpRead),1) == "="
				SELF:aPlanCopy[SELF:nOpFolder][SELF:OGETDD[SELF:nOpFolder]:Nat][SELF:OGETDD[SELF:nOpFolder]:OBROWSE:ColPos] := AllTrim(cBkpRead)
			Else
				SELF:aPlanCopy[SELF:nOpFolder][SELF:OGETDD[SELF:nOpFolder]:Nat][SELF:OGETDD[SELF:nOpFolder]:OBROWSE:ColPos] := ""
			EndIf
			lRet := aRetFrmTr[1]

		Else
			If PadL(aRetFrmTr[2],1) == "#"
				SetHelp( "NOA014VLDEXP" , STR0029) //SubStr(aRetFrmTr[2],2,Len(aRetFrmTr[2])) )
			Else
				SetHelp( "NOA014VLDEXP" , STR0102 +aRetFrmTr[2]+ STR0103 ) // "Express�o: '" ## "' inv�lida. Digite uma c�lula ou uma express�o v�lida."
			EndIf
			SELF:OGETDD[SELF:nOpFolder]:aCols[SELF:OGETDD[SELF:nOpFolder]:Nat][SELF:OGETDD[SELF:nOpFolder]:OBROWSE:COLPOS] := cBkpCols
			SELF:OGETDD[SELF:nOpFolder]:OBROWSE:Refresh()
			SELF:clVar := cBkpFVar
			SELF:oTGet:Refresh()
			&__ReadVar := cBkpRead
			lRet := aRetFrmTr[1]
		EndIf

    // valida TGet do campo Formulas, chamado pelo botao Executar
	Case ProcName(1) == 'FVALIDCPO' .And. nOpcx == 2

		//Valida se ha celula selecionada
		If !Empty(SELF:oSay1:cCaption) 
		
			//Obtem os dados da celula posiciona
			aTmp	:= SplitCellEnd(SELF:oSay1:cCaption)
			cColuna	:= Upper(aTmp[2])
			cLinha	:= aTmp[1]

			//Obtem a coluna no aHeader
			nPosCol := Ascan(SELF:OGETDD[SELF:nOpFolder]:AHEADER, {|x| AllTrim(x[1]) == cColuna })

			//Obtem a linha no aCols
			nPosLin := Ascan(SELF:OGETDD[SELF:nOpFolder]:ACOLS, {|x| AllTrim(x[1]) == cLinha })

			//Posiciona na celula
			SELF:OGETDD[SELF:nOpFolder]:OBROWSE:COLPOS := nPosCol
			SELF:OGETDD[SELF:nOpFolder]:OBROWSE:Nat := nPosLin

			//Verifica se a coluna eh editavel atraves da propriedade WHEN do aHeader
			If ".T." $ Upper(SELF:OGETDD[SELF:nOpFolder]:AHEADER[nPosCol][13]) .And. nPosLin > 1

				cBkpCols	:= SELF:OGETDD[SELF:nOpFolder]:aCols[nPosLin][nPosCol]
				cBkpFVar	:= SELF:clVar
				cBkpRead	:= &__ReadVar
				cFrmAK2		:= SELF:aPlanCopy[SELF:nOpFolder][nPosLin][nPosCol]
				aRetFrmTr	:= SELF:FormTran(SELF:clVar)
	
				// se o resultado da formula for valido
				If aRetFrmTr[1]

					// aCols
					SELF:OGETDD[SELF:nOpFolder]:aCols[nPosLin][nPosCol] := PADR(aRetFrmTr[2],SELF:nFormLimit)
					SELF:OGETDD[SELF:nOpFolder]:OBROWSE:Refresh()
					// memoria
					&__ReadVar := PADR(aRetFrmTr[2],SELF:nFormLimit)
					// formulas
					SELF:clVar := PADR(cBkpFVar,SELF:nFormLimit)
					SELF:oTGet:Refresh()
					// AK2_FORM
					If PadL(AllTrim(SELF:clVar),1) == "="
						SELF:aPlanCopy[SELF:nOpFolder][nPosLin][nPosCol] := AllTrim(SELF:clVar)
					Else
						SELF:aPlanCopy[SELF:nOpFolder][nPosLin][nPosCol] := ""
					EndIf
					lRet := aRetFrmTr[1]

				Else
					If PadL(aRetFrmTr[2],1) == "#"
						SetHelp( "NOA014VLDEXP" , STR0029 ) //SubStr(aRetFrmTr[2],2,Len(aRetFrmTr[2])) )
					Else
						SetHelp( "NOA014VLDEXP" , STR0102 +aRetFrmTr[2]+ STR0103 ) // "Express�o: '" ## "' inv�lida. Digite uma c�lula ou uma express�o v�lida."
					EndIf
					SELF:clVar := cBkpFVar
					SELF:oTGet:Refresh()
					lRet := aRetFrmTr[1]
				EndIf

			EndIf

		EndIf

	// valida campo da tela de "Clicar e Arrastar"
	Case ProcName(1) == 'FAPLICA' .And. nOpcx == 3

		cBkpCols	:= SELF:OGETDD[SELF:nOpFolder]:aCols[SELF:OGETDD[SELF:nOpFolder]:Nat][SELF:OGETDD[SELF:nOpFolder]:OBROWSE:COLPOS]
		cBkpFVar	:= SELF:clVar
		cFrmAK2		:= SELF:aPlanCopy[SELF:nOpFolder][SELF:OGETDD[SELF:nOpFolder]:Nat][SELF:OGETDD[SELF:nOpFolder]:OBROWSE:ColPos]
		aRetFrmTr := SELF:FormTran(cFAplExp)

		If aRetFrmTr[1]

			// aCols
			SELF:OGETDD[SELF:nOpFolder]:aCols[SELF:OGETDD[SELF:nOpFolder]:Nat][SELF:OGETDD[SELF:nOpFolder]:OBROWSE:COLPOS] := aRetFrmTr[2]
			SELF:OGETDD[SELF:nOpFolder]:OBROWSE:Refresh()
			// formula
			SELF:clVar := PADR(cFAplExp,SELF:nFormLimit)
			SELF:oTGet:Refresh()

			lRet := aRetFrmTr[1]

		Else
			If PadL(aRetFrmTr[2],1) == "#"
				SetHelp( "NOA014VLDEXP" , STR0029) //SubStr(aRetFrmTr[2],2,Len(aRetFrmTr[2])) )
			Else
				SetHelp( "NOA014VLDEXP" , STR0102 +aRetFrmTr[2]+ STR0103 ) // "Express�o: '" ## "' inv�lida. Digite uma c�lula ou uma express�o v�lida."
			EndIf
			lRet := aRetFrmTr[1]
		EndIf

EndCase

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCO_CELU  �Autor  �Microsiga           � Data �  10/14/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o conteudo de uma celula                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �PCOA014                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function PCO_SOMA(cForm,Self)
Local aRet		:= {}
Local aPosOper	:= {}
Local aFormRes	:= {}
Local aCelPos	:= {}
Local cRet		:= ""
Local cOper		:= "=(:)+-*/"
Local cCarProib	:= ",.;�`'�\|"
Local cColIni	:= ""
Local cLinIni	:= ""
Local cColFim	:= ""
Local cLinFim	:= ""
Local cCelula	:= ""
Local nResult	:= 0
Local nlCIni	:= 0
Local nlCFim	:= 0
Local nLinIni	:= 0
Local nLinFim	:= 0
Local nA		:= 0
Local nB		:= 0
Local nPosIni	:= 0
Local nQuant	:= 0
Local nPosFun	:= 0
Local lRet		:= .T.

cForm := AllTrim(cForm)

// valido caracteres especiais
For nA:=1 To Len(cForm)
	If SubStr(cForm,nA,1) $ cCarProib
		lRet := .F.
	EndIf
Next nA

// verifica se existe o separador :
If At(":",cForm) == 0
	lRet := .F.
EndIf

If !lRet
	Aadd(aRet,.F.)
	Aadd(aRet,"#"+ STR0113) //  "Erro na F�rmula digitada. A fun��o SOMA() s� aceita o caracter : como separador de f�rmulas e deve conter a express�o: SOMA( CELULA1 : CELULA2 )."
	Return aRet
EndIf

If lRet
	
	For nA:=1 To Len(cForm)
		If (SubStr(cForm,nA,1) $ cOper)
			Aadd(aPosOper,nA)
		EndIf
	Next nA

	// separo o que e celula ou formula
	For nA:=1 To (Len(aPosOper)-1)
		nPosIni := aPosOper[nA]+1
		nQuant  := (aPosOper[nA+1]-aPosOper[nA])-1
		If nQuant > 0
			Aadd(aFormRes,SubStr(cForm,nPosIni,nQuant))
		EndIf
	Next nA

	If Len(aFormRes) < 3
		Aadd(aRet,.F.)
		Aadd(aRet,"#"+STR0114) // "Erro na F�rmula digitada. A fun��o SOMA() s� aceita o caracter : como separador de f�rmulas."
		Return aRet
	EndIf

	// separa linha inicial e coluna inicial
	For nA:=1 To Len(aFormRes[2])
		If IsAlpha(SubStr(aFormRes[2],nA,1))
			cColIni += SubStr(aFormRes[2],nA,1)
		ElseIf IsDigit(SubStr(aFormRes[2],nA,1))
			cLinIni += SubStr(aFormRes[2],nA,1)
		EndIf
	Next nA

	If Empty(cLinIni)
		cLinIni := "-1"
	EndIf
	
	// valida se a linha e coluna iniciais sao validas
	nLinIni := Val(cLinIni)+1
	nPosFun := ASCAN(SELF:OGETDD[SELF:nOpFolder]:AHEADER, { |x| AllTrim(x[1]) == cColIni })
	If (nPosFun < 10) .Or. (nLinIni > Len(SELF:OGETDD[SELF:nOpFolder]:aCols)) .Or. (nLinIni == 0)
		lRet := .F.
	EndIf

	// separa linha final e coluna final
	If lRet
		For nA:=1 To Len(aFormRes[3])
			If IsAlpha(SubStr(aFormRes[3],nA,1))
				cColFim += SubStr(aFormRes[3],nA,1)
			ElseIf IsDigit(SubStr(aFormRes[3],nA,1))
				cLinFim += SubStr(aFormRes[3],nA,1)
			EndIf
		Next nA

		If Empty(cLinFim)
			cLinFim := "-1"
		EndIf

		// valida se a linha e coluna finais sao validas
		nLinFim := Val(cLinFim)+1
		nPosFun := ASCAN(SELF:OGETDD[SELF:nOpFolder]:AHEADER, { |x| AllTrim(x[1]) == cColFim })
		If (nPosFun < 10) .Or. (nLinFim > Len(SELF:OGETDD[SELF:nOpFolder]:aCols)) .Or. (nLinFim == 0)
			lRet := .F.
		EndIf
	EndIf

	If !lRet
		Aadd(aRet,.F.)
		Aadd(aRet,"#"+STR0115) // "Erro na formula digitada. Verifique se as c�lulas s�o todas v�lidas."
		Return aRet
	EndIf

	// traduz as colunas para numeros
	nlCIni	:= If(aScan(_aAlfabeto,cColIni)>0,aScan(_aAlfabeto,cColIni),1)
	nlCFim	:= If(aScan(_aAlfabeto,cColFim)>0,aScan(_aAlfabeto,cColFim),1)

	// varre da coluna inicial a linha final para somar os vales das celulas
	nLinIni--
	nLinFim--
	For nA := nlCIni To nlCFim
		For nB := nLinIni To nLinFim
			cCelula := _aAlfabeto[nA]+cValToChar(nB)
			aCelPos := FBUSCAPOS(cCelula,SELF)
			If aCelPos[1] > 0 .And. aCelPos[2] > 0
				If aCelPos[1] <= Len(SELF:oGetDd[1]:aCols)
					nResult	+= Val(AllTrim(Iif(Empty(SELF:oGetDd[1]:aCols[aCelPos[1],aCelPos[2]]),"0",SELF:oGetDd[1]:aCols[aCelPos[1],aCelPos[2]])))
				EndIf
			EndIf
		Next nB
	Next nA

	Aadd(aRet,.T.)
	Aadd(aRet,cValToChar(nResult))

EndIf

Return aRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA014   �Autor  �Jair Ribeiro        � Data �  12/20/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                    	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TranConta(clTextForm) Class PCOa014
Local nPos1	:= 0
Local nPos2	:= 0
Local cSub 	:= 0
Local cForm	:= ""
Local aRet	:= {}

While "CONTA(" $ clTextForm
	nPos1 	:= at("CONTA(",upper(clTextForm))
	cSub 	:= SubStr(clTextForm,nPos1)
	nPos2 	:= at(")",cSub)
	cForm	:= SubStr(cSub,1,nPos2)
	aRet	:= FValConta(cForm,SELF)
	If aRet[1]
		clTextForm	:= aRet[2]
	Else
		Exit
	EndIf
EndDo

Return aRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA014   �Autor  �Jair Ribeiro        � Data �  12/21/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAPCO	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FValConta(cForm,Self) 
Local cPar 			:= ""
Local nPosFolder	:= 0
Local nPosConta		:= 0	
Local aPar			:= {}
Local aPosition		:= {}
Local aPlan1		:= aClone(Self:APLANBEGIN)
Local aPlanOthers	:= aClone(Self:APLANANOTHER)
Local aRet			:= {}
	
cPar := STRTRAN(cForm,"CONTA(","")
cPar := SubStr(cPar,1,Len(cPar)-1)
aPar := Separa(cPar,";")
	
If Empty(aPar[2])
	aPar[2]:= "1"
EndIf
 //=CONTA(1101010001;2;I1)
 //aparm[1] := 1101010001
 //aparm[2] := 2
 //apparm[3] := I1
If Val(aPar[2]) > Len(Self:OFOLDER:ADIALOGS) .Or. Val(aPar[2]) == 0
	aAdd(aRet,.F.)
	aAdd(aRet,"#"+STR0120) // "Planilha Inexistente"
Else
	If !Empty(aPar) .and. Len(aPar) == 3
		If !Empty(aPosition := GetCellGD(Self,aPar[3],Val(aPar[2])))
			If VAL(aPar[2]) == 1
				If (nPosConta := AsCan(aPlan1,{|aX| Ax[1] == aPar[1]})) > 0
					If Len(aPlan1[nPosConta][2]) > 0
						If aPosition[2] > len(aPlan1[nPosConta,2])
							aAdd(aRet,.f.)
							aAdd(aRet,"#"+STR0116+STR0156) // "Linha inexistente"
						Else
							If aPosition[1] > len(aPlan1[nPosConta,2][aPosition[2]])
								aAdd(aRet,.f.)
								aAdd(aRet,"#"+STR0117+STR0156) // "Coluna inexistente"
							Else
								aAdd(aRet,.T.)
								If aPlan1[nPosConta,2][aPosition[2]+1][1] == cValToChar(aPosition[2])
									aAdd(aRet,aPlan1[nPosConta,2][aPosition[2]+1,aPosition[1]])
								Else
									aAdd(aRet,aPlan1[nPosConta,2][aPosition[2]+1,aPosition[1]-1])
								EndIf
							EndIf
						EndIf
					Else
						aAdd(aRet,.F.)
						aAdd(aRet,"#"+STR0118+STR0156) // "Celula Invalida"
					EndIf
				Else
					aAdd(aRet,.F.)
					aAdd(aRet,"#"+STR0119+STR0156) // "Conta Orcamentaria Inexistente"
				EndIf
			ElseIf VAL(aPar[2]) > 1
				If !Empty(aPlanOthers)
					If(nPosFolder := AsCan(aPlanOthers,{|aX| Ax[1,1] == VAL(aPar[2])}))>0
						If(nPosConta := AsCan(aPlanOthers[nPosFolder],{|aX| Ax[3] == aPar[1]}))>0
							If Len(aPlanOthers[nPosFolder][nPosConta][4])	 > 0 //NA POSICAO 4
								If aPosition[2] > len(aPlanOthers[nPosFolder,nPosConta,4])
									aAdd(aRet,.f.)
									aAdd(aRet,"#"+STR0116+STR0156) // "Linha inexistente"
								Else
									If aPosition[1] > len(aPlanOthers[nPosFolder,nPosConta,4][aPosition[2]])
										aAdd(aRet,.f.)
										aAdd(aRet,"#"+STR0117+STR0156) // "Coluna inexistente"
									Else
										aAdd(aRet,.T.)
										aAdd(aRet,aPlanOthers[nPosFolder,nPosConta,4][aPosition[2]+1,aPosition[1]-1])
									EndIf
								EndIf
							Else
								aAdd(aRet,.F.)
								aAdd(aRet,"#"+STR0118+STR0156) // "Celula Invalida"
							EndIf
						Else
							aAdd(aRet,.F.)
							aAdd(aRet,"#"+STR0119+STR0156) // "Conta Orcamentaria Inexistente"
						EndIf
					Else
						aAdd(aRet,.F.)
						aAdd(aRet,"#"+STR0120+STR0156) // "Planilha Inexistente"
					EndIf
				Else
					aAdd(aRet,.F.)
					aAdd(aRet,"#"+STR0121+STR0156) // "Existe somente uma planilha ativa"
				EndIf
			Else
				aAdd(aRet,.F.)
				aAdd(aRet,"#"+STR0120+STR0156) // "Planilha Inexistente"
			EndIf
		Else
			aAdd(aRet,.F.)
			aAdd(aRet,"#"+STR0122+STR0156) // "Celula inexistente na planilha informada"
		EndIf
	Else
		aAdd(aRet,.F.)
		aAdd(aRet,"#"+STR0123+STR0156) // "Parametros para formula conta invalido"
	EndIf
EndIf

Return aRet

Method SetPlans(aPlan1,aOthers) Class  PCOA014

Self:aPlanBegin 	:= aPlan1
Self:aPlanAnother	:= aOthers

Return(self)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetCellGD �Autor  �Jair Ribeiro	     � Data �  12/21/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAPCO	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetCellGD(oGD,cCell,nFolder)
Local aRet		:= {}
Local nI		:= 0
Local cCellAux  := alltrim(cCell)
Local cLetter	:= ""
Local cNumber	:= ""
Local nPosHead	:= 0
Local nLin		:= 0

For nI := 1 To Len(cCellAux)
	If IsAlpha(Substr(cCellAux,nI,1))
		cLetter += Substr(cCellAux,nI,1)
	Else
		cNumber += Substr(cCellAux,nI,1)
	EndIf
Next nI
nPosHead := aScan(oGD:oGetdd[nFolder]:aHeader,{|x| alltrim(x[2]) == "PCO_"+cLetter})
If nPosHEad > 0
	nLin := val(cNumber)
	aRet := {nPosHead,nLin}
EndIf

Return aRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ExePcoSoma�Autor  �Microsiga           � Data �  10/22/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se a celula esta no range da formula soma(x:y)     ���
�������������������������������������������������������������������������͹��
���Uso       �PCOA014                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ExePcoSoma(clCell,cFormula)
Local lRet		:= .F.
Local cOper		:= "=(:)"
Local nA		:= 0
Local nPosIni	:= 0
Local nQuant	:= 0
Local nRang1Ltr	:= 0
Local nRang1Num	:= 0
Local nRang2Ltr	:= 0
Local nRang2Num	:= 0
Local nCellLtr	:= 0
Local nCellNum	:= 0
Local aPosOper	:= {}
Local aCells	:= {}

If !Empty(clCell) .And. !Empty(cFormula)

	For nA:=1 To Len(cFormula)
		If (SubStr(cFormula,nA,1) $ cOper)
			Aadd(aPosOper,nA)
		EndIf
	Next nA

	For nA:=2 To (Len(aPosOper)-1)
		nPosIni := aPosOper[nA]+1
		nQuant  := (aPosOper[nA+1]-aPosOper[nA])-1
		If nQuant > 0
			Aadd(aCells,SubStr(cFormula,nPosIni,nQuant))
		EndIf
	Next nA

	// primeira formula do range
	For nA:=1 To Len(aCells[1])
		If IsAlpha(SubStr(aCells[1],nA,1))
			nRang1Ltr += aScan(_aAlfabeto,SubStr(aCells[1],nA,1))
		Else
			nRang1Num += Val(SubStr(aCells[1],nA,1))
		EndIf
	Next nA

	// segunda formula do range
	For nA:=1 To Len(aCells[2])
		If IsAlpha(SubStr(aCells[2],nA,1))
			nRang2Ltr += aScan(_aAlfabeto,SubStr(aCells[2],nA,1))
		Else
			nRang2Num += Val(SubStr(aCells[2],nA,1))
		EndIf
	Next nA

	// celula que teve seu falor alterado
	For nA:=1 To Len(clCell)
		If IsAlpha(SubStr(clCell,nA,1))
			nCellLtr += aScan(_aAlfabeto,SubStr(clCell,nA,1))
		Else
			nCellNum += Val(SubStr(clCell,nA,1))
		EndIf
	Next nA

    If ((nCellLtr >= nRang1Ltr) .And. (nCellLtr <= nRang2Ltr)) .And. ((nCellNum >= nRang1Num) .And. (nCellNum <= nRang2Num))
    	lRet := .T.
    EndIf

EndIf

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FSetAtu   �Autor  �Microsiga           � Data �  10/24/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Encapsulamento do metodo SetAtualiza() para que seja       ���
���          � possivel o uso do MsgRun()                                 ���
�������������������������������������������������������������������������͹��
���Uso       �PCOA014                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function FSetAtu(oObj,aCelulas,xOpc)
Local nA := 0
Default aCelulas := {}
Private aRefCirc:={}
If Type("lCircu") == "U"
	Private lCircu :=.F.
Endif

If Len(aCelulas) > 0
	For nA:=1 To Len(aCelulas)
		oObj:SetAtualiza(aCelulas[nA,1],xOpc)
	Next nA
Else
	oObj:SetAtualiza(Nil,xOpc)
EndIf

Return

//------------------------------------------------------------------
Method GetValue(cCelName,nPlanilha) Class PCOa014
Local xRet := ""
Local aPos := self:GetCellLinColuna(cCelName,nPlanilha)
If !Empty(aPos)
	xRet :=	AllTrim(self:OGETDD[nPlanilha]:aCols[aPos[1]][aPos[2]])
Endif

Return xRet

//------------------------------------------------------------------  
//Retorna a linha e coluna de uma celular, 1 pos do array a linha
//a segunda a coluna                                                  
//------------------------------------------------------------------  
Static Function SplitCellEnd(cCelName)
Local nX
Local cChar
Local cColuna := ""
Local cLine	  := ""
Local lLineFix := .F.
Local lColFix  := .F.
For nX := 1 to Len(cCelName)
	cChar := SubStr(cCelName,nX,1)
	If cChar == "$"
		If Empty(cColuna)
			lColFix := .T.
		Else
			lLineFix := .T.
		EndIf
	ElseIf Upper(cChar) $ "QWERTYUIOPASDFGHJKLZXCVBNM"
		cColuna += cChar
	Else
		cLine += cChar
	EndIf
Next nX

Return {cLine,cColuna,lLineFix,lColFix}

//------------------------------------------------------------------
Method DeActivate() Class PCOa014
__PCOa014Instance := Nil
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCellLinColuna
Retorna a posicao em rela��o a o array de dados de uma celula

@param cCelName Celula a se avaliada
@param nPlanilha Posi��o da planilha
@param nConta Posicao da Conta
@param nPosFolder posicao da folder

@return aRet Array com linha e coluna

@author Rodrigo Antonio
@since 17/11/2011
@version P10 
/*/
//-------------------------------------------------------------------
Method GetCellLinColuna(cCelName,nPlanilha,nConta,nPosFolder) Class PCOa014
Local cColuna		:= ""
Local lContinua		:= .T.
Local cLine			:= ""
Local nLine			:= 0 
Local nMaxColunas	:= 0
Local nMaxLinhas	:= 0
Local nPos			:= 0
Local aRet			:= {}
Local aTmp			:= SplitCellEnd(cCelName)
Local nColEdit		:= 0

Default nConta		:= 0
Default nPlanilha	:= Self:nOpFolder
Default nPosFolder	:= 0

If nConta == 0
	nMaxLinhas	:= Len(self:OGETDD[nPlanilha]:aCols )
	nMaxColunas := Len(self:OGETDD[nPlanilha]:aHeader)
Else
	If nPlanilha > 1
		nMaxLinhas := Len(Self:aPlanAnother[nPlanilha-1][nConta][4] )
		nMaxColunas := Len(Self:aPlanAnother[nPlanilha-1][nConta][4][1] ) 	
	Else
		nMaxLinhas := Len(self:aPlanBegin[nConta][2] )
		nMaxColunas := Len(self:aPlanBegin[nConta][2][1]) 		
	Endif
Endif

cLine	  := aTmp[1]
cColuna   := aTmp[2]

IF !Empty(cLine)
	nLine := Val(cLine)
	nLine++
Else
	self:cError := STR0118 + ": " + cCelName //"Celula Invalida"
	lContinua := .F.
Endif

If lContinua
	nPos := aScan(self:aAlfabeto,{|x|x==cColuna}) //Obtem a posicao da coluna
	
	nColEdit	:= Ascan(self:OGETDD[nPlanilha]:aHeader, {|x| '.T.' $ Upper(x[13]) })  //Identifica a coluna editavel inicial atrav�s do When do aHeader

	If nColEdit > 0
		nColEdit := Ascan(self:aAlfabeto, {|x| Upper(Alltrim(x)) == Upper(AllTrim(self:OGETDD[nPlanilha]:aHeader[nColEdit][1])) })  //Identifica a coluna editavel
	EndIf

	If nPos >= nColEdit
		If nLine > nMaxLinhas 
			self:cError := STR0118 + ": " + cCelName + ". " + STR0116 //"Celula Invalida"###Linha inexistente
		ElseIf nPos > nMaxColunas
			self:cError := STR0118 + ": " + cCelName + ". " + STR0117 //"Celula Invalida"###Coluna inexistente
		Else
			aAdd(aRet,nLine)
			aAdd(aRet,nPos)
		Endif
	
	Else
		self:cError := STR0118 + ": " + cCelName //"Celula Invalida"
	Endif
EndIf


Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} AddRange
Adiciona um range na expressao sendo analisada no momento

@param cCtaAndPlan Contem a conta e/ou a planilha
@param cCellIni Celula inicial
@param cCellEnd Celula final

@return cSeqRange Retorna a o ID da sequencia criada

@author Rodrigo Antonio
@since 17/11/2011
@version P10 
/*/
//-------------------------------------------------------------------
Method AddRange(cCtaAndPlan,cCellIni,cCellEnd) Class PCOa014
Local oNode
Local cSeqRange
cSeqRange := "##RANGE" + AllTrim(Str(Len(self:aLastRanges )+1)) + "##"
oNode := FWExcelNodeExpression():New(cSeqRange,cCtaAndPlan,cCellIni,cCellEnd) 
aAdd(self:aLastRanges ,oNode)
Return cSeqRange

//-------------------------------------------------------------------
/*/{Protheus.doc} FWEXCELParse
Instancia o Parser de express�o, valida a mesma e se correta 
faz a execus�o.

@param cInput Express�o de entrada do parser
@param oPCOObject Objeto da planilha do PCO(PCOa014)

@return aRet, Array no formato esperado pelo objeto PCOa014, se a foi bem sucedido
ira possuir dois elementos, o primeiro um .T. e o segundo o valor da formula chamada.

@author Rodrigo Antonio
@since 17/11/2011
@version P10 
/*/
//-------------------------------------------------------------------
Function FWEXCELParse(cInput,oPCOObject)
Local oParse
Local aRet := {}
Local xResult
Local oExp

cInput := Alltrim(SubStr(cInput,2))

oParse := FWExpressionParser():New()
oParse:aReservedWords := GetExcelFuncs()
oParse:bRealName  := {|x,y,z,u|   PCOExGetName(x,y,z,u,oPCOObject)}
oParse:bRangeFunc := {|x,y,z,u,l| PCOExRange(x,y,z,u,l,oPCOObject)}
oParse:bValidArgs := {|x,y,z|   PCOValidArgs(x,y,z,oPCOObject)}

oParse:Parser(cInput)
aAdd(aRet,Empty(oParse:Error))

If !aRet[1]
	//���������������������������������������������������A�
	//� Foi inserida uma mensagem generica de erro pois o �
	//� parser pode retornar mensagens nao tratadas difi- �
	//� cultando a possibilidade de personalizar a mensa- �
	//� gem de erro                                       �
	//���������������������������������������������������A�
	If !EMPTY(oParse:Error)
		If "TOKEN" $ UPPER(oParse:Error)
			aAdd(aRet,STR0101)
		Else
			aAdd(aRet,oParse:Error)	
		EndIf
	Else
		aAdd(aRet,STR0029) //"A f�rmula digitada cont�m erro(s)"
	EndIf
Else

 	   	TRY EXCEPTION

			xResult := &(oParse:cParsedInput)

			If ValType(xResult) == "L"
				Aadd(aRet,If(xResult,STR0124,STR0125)) //"VERDADEIRO"###"FALSO"
			ElseIf ValType(xResult) == "C" .And. IsAlpha(xResult)
				Aadd(aRet,xResult)
			Else
				aAdd(aRet,TRANSNUM(cValToChar(xResult),1)) //oParse:Error
			EndIf

	    CATCH EXCEPTION  USING oExp
		    aRet[1] := .F.
		    aAdd(aRet, STR0127 + oExp:DESCRIPTION) //"O seguinte erro aconteceu:"
	    END TRY

EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOValidArgs
Fun��o chamada pelo Parser para validarmos a chamada de uma fun��o.
Por exemplo aqui podemos validar se determinada funcao recebeu o 
numero certo de parametros.

@param oParser Objeto do Parser
@param cFuncName Nome da fun��o encontrada na expressao
@param aArgs Array com os argumentos encontrados
@param oPCOObject Objeto da planilha do PCO(PCOa014)

@return lRet Set .T. a conta esta certa., se .F. dever� setar o erro no parser via SetError.

@author Rodrigo Antonio
@since 17/11/2011
@version P10 
/*/
//-------------------------------------------------------------------
Function PCOValidArgs(oParser,cFuncName,aArgs,oPCOObject)
Local lRet 		:= .T.
Local nPar			:= 0
Local nQtdPar		:= 0

If UPPER(cFuncName) == "DISTRBINOM"
	/*
	 * Valida��o dos argumentos obrigat�rios das fun��es da simula��o estat�stica
	 */	
	For nPar := 1 To 4
		If Len(aArgs) < nPar
			lRet := .F.
  			oParser:SetError(STR0140+cFuncName+".") // "Quantidade de argumentos insuficiente para a fun��o "
  			Exit
  		EndIf
  	Next nPar
ElseIf UPPER(cFuncName)+"|" $ "BDD|DISTEXPON|VF|JUROS|JUROSC|MONT|MONTC|EPGTO|"//a fun��o 'E' estava entrando aqui
	/*
	 * Defini��o da quantidade de argumentos obrigat�rios que devem ser validados antes de ser executados 
	 * na simula��o estat�stica.
	 */
	If UPPER(cFuncName)+"|" $ "JUROS|JUROSC|MONT|MONTC|"	
		nQtdPar := 5
	ElseIf UPPER(cFuncName) == "EPGTO" .or. UPPER(cFuncName) =="BDD"
		nQtdPar := 4
	ElseIf UPPER(cFuncName)+"|" $ "DISTEXPON|VF|"
		nQtdPar := 3
	EndIf
	
	/*
	 * Valida��o dos argumentos obrigat�rios das fun��es da simula��o estat�stica
	 */	
	For nPar := 1 To nQtdPar
		If Len(aArgs) < nPar
			lRet := .F.
  			oParser:SetError(STR0144 + cFuncName + ".") //"Quantidade de argumentos insuficiente para a fun��o "
  			Exit
  		EndIf
  	Next nPar
  	
  	nQtdPar := nQtdPar + 1
Else
	If Len(aArgs) == 0
		lRet := .F.
  		oParser:SetError(STR0144 + cFuncName + ".") //"O segundo par�metro da fun��o MENOR() deve ser num�rico."
  	EndIf	
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldContaRange
Fun��o auxiliar para validar o range num acesso de range

@param cConta Numero da Conta contabil
@param nPlanilha Posi��o da planilha para se determinar se usamos o aPlanBegin ou aPlanAnother
@param cCellIni Celula Inicial
@param cCellFim Celula Final
@param oParser Objeto do Parser
@param oPCOObject Objeto da planilha do PCO(PCOa014)
@param nPosIni Variavel recebida como referencia para atualizarmos a posicao inicial
@param nPosFim Variavel recebida como referencia para atualizarmos a posicao Final
@param nLineIni Variavel recebida como referencia para atualizarmos a linha inicial
@param nLineFim Variavel recebida como referencia para atualizarmos a linha Final
@param nMaxColunas  Variavel recebida como referencia para atualizarmos o numero maximo de colunas
@param nMaxLinhas Variavel recebida como referencia para atualizarmos o numero maximo de Linhas
@return lRet Set .T. a conta esta certa.

@author Rodrigo Antonio
@since 24/11/2011
@version P10 
/*/
//-------------------------------------------------------------------
Static Function VldContaRange(cConta,nPlanilha,cCellIni,cCellFIm,oParser,oPCOObject,nPosIni,nPosFim,nLineIni,nLineFim,nMaxColunas,nMaxLinhas)
Local lRet			:= .F.
Local nPos			:= At("CTA",cConta) 
Local aPlan1		:= oPCOObject:aPlanBegin
Local aPlanOthers	:= oPCOObject:aPlanAnother
Local nPosConta
Local nPosFolder
Local atmp
If nPos > 0
	cConta := SubStr(cConta,nPos+3)	  
	If oPCOObject:cContaSelect != cConta .or. nPlanilha !=oPCOObject:nOpFolder //� possivel acessar a mesma conta de outra planilha
		nPosConta := aScan(aPlan1,{|aX| Ax[1] == cConta})
		If nPlanilha == 1 //Planilha orcamentaria original
			If nPosConta > 0
				If Len(aPlan1[nPosConta][2]) > 0
					//-------------------------------------
					//Determina a posicao da linha e coluna
					//-------------------------------------
					aTmp  := oPCOObject:GetCellLinColuna(cCellIni,nPlanilha,nPosConta)
					If !Empty(aTmp)
						nLineIni := aTmp[1] -1
						nPosIni  := aTmp[2]
						aTmp  := oPCOObject:GetCellLinColuna(cCellFim,nPlanilha,nPosConta)
						If !Empty(aTmp)
							nLineFim := aTmp[1] -1
							nPosFim  := aTmp[2]
							nMaxLinhas := Len(aPlan1[nPosConta][2] )
							nMaxColunas := Len(aPlan1[nPosConta][2][1] )
							lRet := .t.
						Else
							oParser:setError(oPCOObject:cError)
						Endif

					Else
						oParser:setError(oPCOObject:cError)
					Endif

				Else
					oParser:setError(STR0128 + cConta + STR0129 + AllTrim(Str(nPlanilha)) + STR0130) //"Planilha or�amentaria:"###" e Pasta "###" est�o vazias."
				EndIf
			Else
				oParser:setError(STR0119 + ':' + cConta ) // "Conta Orcamentaria Inexistente"
			Endif
        Else //Planilha de comparacao ou seja > 2 
			nPosFolder := aScan(aPlanOthers,{|aX| Ax[1,1] == nPlanilha} )
			If nPosFolder > 0
				nPosConta := aScan(aPlanOthers[nPosFolder],{|aX| Ax[3] == cConta})
				If nPosConta> 0
					//-------------------------------------
					//Determina a posicao da linha e coluna
					//-------------------------------------
					aTmp  := oPCOObject:GetCellLinColuna(cCellIni,nPlanilha,nPosConta) 
					If !Empty(aTmp)
						nLineIni := aTmp[1] -1
						nPosIni  := aTmp[2]
						aTmp  := oPCOObject:GetCellLinColuna(cCellFim,nPlanilha,nPosConta)
						If !Empty(aTmp)
							nLineFim := aTmp[1] -1
							nPosFim  := aTmp[2]
							
							nMaxLinhas	:= Len(oPCOObject:OGETDD[nPlanilha]:aCols )
		   					nMaxColunas := Len(oPCOObject:OGETDD[nPlanilha]:aHeader)
							
							lRet := .t.
						Else
							oParser:setError(oPCOObject:cError)
						Endif

					Else
						oParser:setError(oPCOObject:cError)
					Endif
				Else
					oParser:setError(STR0119 + ':' + cConta ) // "Conta Orcamentaria Inexistente"
				Endif
			Else
				oParser:setError(STR0120) // "Planilha Inexistente"
			Endif
		Endif
	Else
		oParser:setError(STR0131) //"N�o � permitido acessar a propria conta usando o operador CTA."
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetContaValue
Fun��o auxiliar para retornar o valor de uma celula em outra conta

@param cConta Numero da Conta contabil
@param nPlanilha Posi��o da planilha para se determinar se usamos o aPlanBegin ou aPlanAnother
@param cCell Celula
@param oParser Objeto do Parser
@param oPCOObject Objeto da planilha do PCO(PCOa014)

@return xRet Valor da celula

@author Rodrigo Antonio
@since 24/11/2011
@version P10 
/*/
//-------------------------------------------------------------------
Static Function GetContaValue(cConta,nPlanilha,cCell,oParser,oPCOObject)
Local xRet			:= ""
Local nPos			:= At("CTA",cConta) 
Local aPlan1		:= oPCOObject:aPlanBegin
Local aPlanOthers	:= oPCOObject:aPlanAnother
Local nLin
Local nCol
Local aTmp
Local nPosConta
Local nPosFolder
If nPos > 0
	cConta := SubStr(cConta,nPos+3)
	If oPCOObject:cContaSelect != cConta .or. nPlanilha !=oPCOObject:nOpFolder//conta de outra planilha

		If nPlanilha == 1 //Planilha orcamentaria original
			nPosConta := aScan(aPlan1,{|aX| Ax[1] == cConta})
			If nPosConta > 0
				If Len(aPlan1[nPosConta][2]) > 0
					//-------------------------------------
					//Determina a posicao da linha e coluna
					//-------------------------------------
					aTmp  := oPCOObject:GetCellLinColuna(cCell,nPlanilha,nPosConta)
					If !Empty(aTmp)
						nLin := aTmp[1]
						nCol := If(aTmp[2]<=0,aTmp[2]+=1,aTmp[2]-=1)
						xRet := aPlan1[nPosConta][2][nLin][nCol]
					Else
						oParser:setError(oPCOObject:cError)
					Endif
				Else
					oParser:setError(STR0128 + cConta + STR0129 + AllTrim(Str(nPlanilha)) + STR0130) //"Planilha or�amentaria:"###" e Pasta "###" est�o vazias."
				EndIf
			Else
				oParser:setError(STR0119 + ':' + cConta ) // "Conta Orcamentaria Inexistente"
			Endif
		Else //Planilha maior que 2, � uma planilha aberta para compara��o
			nPosFolder := aScan(aPlanOthers,{|aX| Ax[1,1] == nPlanilha} )
			If nPosFolder > 0
				nPosConta := aScan(aPlanOthers[nPosFolder],{|aX| Ax[3] == cConta})
				If nPosConta> 0
					//-------------------------------------
					//Determina a posicao da linha e coluna
					//-------------------------------------
					aTmp  := oPCOObject:GetCellLinColuna(cCell,nPlanilha,nPosConta,nPosFolder) 
					If !Empty(aTmp)
						nLin := aTmp[1]
						nCol := aTmp[2]-1 // Diminui uma coluna, j� que a planilha escondida est� no objeto, n�o na Getdado, ent�o desconsidera a coluna de Linha do Grid
						xRet := aPlanOthers[nPosFolder][nPosConta][4][nLin][nCol]
					Else
						oParser:setError(oPCOObject:cError)
					Endif

				Else
					oParser:setError(STR0119 + ':' + cConta ) // "Conta Orcamentaria Inexistente"
				Endif
			Else
				oParser:setError(STR0120) //"Planilha inexistente."
			Endif

		Endif
	Else
		oParser:setError(STR0131) //"N�o � permitido acessar a propria conta usando o operador CTA."
	Endif
Endif

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOExGetName
Esta fun��o � chamada pelo Parse de express�o para quando identificado
um acesso a celula.
Essa fun��o tem a funcionalidade de parsar as seguintes expressoes
Simples:
A1 
Acesso a planilhas da mesma conta
Plan1!A1

Acesso a planilhas de outras contas
CTA11101010!Plan1!A1

Ela retorna o valor da celula

@param oParser	Objeto do Parser
@param xParam1 Possui a celula ou a planilha ou a Conta contabil.
@param xParam2 Possui a celula ou a planilha.
@param xParam3 Celula inicial, s� recebida quando recebemos a conta contabil e a planlha de acesso
@param oPCOObject Objeto da planilha do PCO(PCOa014)

@return xRet Valor da celula

@author Rodrigo Antonio
@since 21/11/2011
@version P10 
/*/
//-------------------------------------------------------------------
Function PCOExGetName(oParser,xParam1,xParam2,xParam3,oPCOObject)
Local xRet			:= ""
Local aReserWords	:= {{STR0124, ".T."},{STR0125,".F."}} //"VERDADEIRO"###"FALSO"
Local nPos			:= 0
Local nPlanilha		:= oPCOObject:nOpFolder
Local cCellName		:= xParam1
Local lContinua		:= .T.
Local cPlan			:= ""
Local cConta		:= ""
Local nX			:= 0

//Caso venha xParam2 e nao venha o xParam3, o primeiro cara contem o nome da planilha.
//Caso venha o xParam2 e xParam3 ,temos a conta no xParam2, e a planilha no xParam3
If !Empty(xParam3)  
	If Empty(xParam2)       
		oParser:setError(STR0132) //Para referenciar planilhas com contas, utilize 'CTA' + conta + '!PLAN' + o numero da pasta + '!' + o numero da c�lula."
		lContinua := .F.
	Endif
	If lContinua
		nPos := At("PLAN",UPPER(xParam2))
		If nPos > 0
			cPlan := SubStr(xParam2,nPos+4)
			nPlanilha := PcoValPlan(cPlan,oPCOObject)
			If  nPlanilha == 0 
				oParser:setError(STR0133) //"Para referenciar planilhas utilize 'Plan' + o numero do folder + o operador ! + o numero da c�lula."
				lContinua := .F.
			Endif
			xRet := GetContaValue(@xParam1,nPlanilha,xParam3,oParser,oPCOObject)
			//----------------------------------
			//Nao continuamos aqui porque  ja
			//Temos o Valor da Celula
			//----------------------------------
			lContinua := .F.
		Else
			oParser:setError(STR0133) //"Para referenciar planilhas utilize 'Plan' + o numero do folder + o operador ! + o numero da c�lula."
			lContinua := .F.
		Endif
	Endif

ElseIf !Empty(xParam2)
	nPos := At("PLAN",UPPER(xParam1))
	If nPos > 0
		cPlan := SubStr(xParam1,nPos+4)
		nPlanilha := PcoValPlan(cPlan,oPCOObject)
		If  nPlanilha == 0 
			oParser:setError(STR0133) //"Para referenciar planilhas utilize 'Plan' + o numero do folder + o operador ! + o numero da c�lula."
			lContinua := .F.
		Endif
		cCellName := xParam2
	Else
		oParser:setError(STR0133) //"Para referenciar planilhas utilize 'Plan' + o numero do folder + o operador ! + o numero da c�lula."
		lContinua := .F.
	Endif
Endif

If lContinua
	If oParser:cNameFuncAvl == "CONTA"
		xRet := "'" + cCellName + "'"
	Else
		nPos := aScan(aReserWords,{|x| x[1] == cCellName })
		If nPos > 0
		    xRet := aReserWords[nPos][2]
		Else
			xRet := oPCOObject:GetValue(cCellName,nPlanilha)
			If !Empty(oPCOObject:cError)
				oParser:setError(oPCOObject:cError)
			Else
				If Empty(xRet)
					oParser:setError(STR0135  + cCellName + STR0136) //"O Conte�do da celula "###" � vazio, fazendo que a formula fique inv�lida."
				Else
					If at("-",xRet) > 0 
						xRet := "(" + xRet + ")"
					Endif

					//Tratamento para alterar a virgula por ponto dos valores devido o protheus n�o considerar virgula nos calculos
					If nPos := At(",",xRet) > 0
						xRet := STRTRAN(xRet,",",".")
					Endif

				Endif
			Endif
		Endif
	Endif
	If Type('aCelInFim')=="A"
		If Empty (xParam3)//nao tem conta
			If !Empty(xParam2)//possui informacao de planilha
				aAdd(aCelInFim,{'','','',nplanilha})
			Else	
				aAdd(aCelInFim,{'','','',''})
			Endif
		Else//tem conta
			aAdd(aCelInFim,{'','',xparam1,nplanilha})
		Endif
	Endif
Endif

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOExRange
Esta fun��o � chamada pelo Parse de express�o para quando identificado
um Range.
Essa fun��o tem a funcionalidade de parsar as seguintes expressoes
Range simples:
A1:A10 ou A1:C15
Acesso a planilhas da mesma conta
Plan1!A1:A10 ou Plan2!A1:C15

Acesso a planilhas de outras contas
CTA11101010!Plan1!A1:A10 ou CTA11101010!Plan!A1:C15

Ela deve retornar um Array com os valores das celulas.

@param oParser	Objeto do Parser
@param xParam1 Possui a celula inicial ou a planilha inicial ou a Conta contabil inicial
@param xParam2 Possui a celula inicial ou final, ou a planilha inicial 
@param xParam3 Celula inicial, s� recebida quando recebemos a conta contabil e a planlha de acesso
@param xParam4 Celula final  , s� recebida quando recebemos a conta contabil e a planlha de acesso
@param oPCOObject Objeto da planilha do PCO(PCOa014)

@return aRetorno Array com os dados do range, caso seja encontrado algum erro, o
mesmo deve ser informado ao parser, por meio do metodo setError.

@author Rodrigo Antonio
@since 21/11/2011
@version P10 
/*/
//-------------------------------------------------------------------
Function PCOExRange(oParser,xParam1,xParam2,xParam3,xParam4,oPCOObject)
Local cRet := ""
Local aTmp
Local nLineIni
Local nLineFim
Local cLineIni
Local nColIni
Local cLineFim
Local nColFim
Local nPosIni
Local nPosFim
Local nX, nY
Local cColBase
Local cCellName
Local xValue
Local lContinua := .T.
Local nPos 
Local cColFim
Local nMaxLinhas
Local nMaxColunas
Local nColEdit	:= 0

Local nPlanilha := oPCOObject:nOpFolder

Local cPlan
Local cCell1 := xParam1
Local cCell2 := xParam2
Local cRefRange
Local cColIni
Local lCta := .F.
Local nPosAntAlf:= 0
Local cConFimAnt:= ""

//Caso venha xParam3 e nao venha o xParam4, o primeiro cara contem o nome da CONTA, o segundo a planilha, e terceiro o inicio do range, e o 4 o final
//Caso venha o xParam3 e xParam4 ,o primeiro cara contem o nome aplanilha, e segundo o inicio do range, e terceiro o 4 o final
//Caso venha xParam3, o primeiro cara contem o nome da planilha.

If !Empty(xParam4)
	If Empty(xParam2)
		oParser:setError(STR0134) //"Para referenciar planilhas com contas, utilize 'CTA' + conta + '!PLAN' + o numero da pasta + '!' + o intervalo de c�lulas.
		lContinua := .F.
	Endif
	If lContinua
		nPos := At("PLAN",UPPER(xParam2))
		If nPos > 0
			cPlan := SubStr(xParam2,nPos+4)
			nPlanilha := PcoValPlan(cPlan,oPCOObject)
			If  nPlanilha == 0 
				oParser:setError(STR0133) //"Para referenciar planilhas utilize 'Plan' + o numero do folder + o operador ! + o numero da c�lula."
				lContinua := .F.
			Endif
			 lCta := .T.
			 cCell1 := xParam3
  			 cCell2 := xParam4
		Else
			oParser:setError(STR0133) //"Para referenciar planilhas utilize 'Plan' + o numero do folder + o operador ! + o numero da c�lula."
			lContinua := .F.
		Endif
	Endif
Else
	If !Empty(xParam3)
		nPos := At("PLAN",UPPER(xParam1))
		If nPos > 0
			cPlan := SubStr(xParam1,5)
			nPlanilha := PcoValPlan(cPlan,oPCOObject)
			If  nPlanilha == 0
				oParser:setError(STR0133) //"Para referenciar planilhas utilize 'Plan' + o numero do folder + o operador ! + o numero da c�lula."
				lContinua := .F.
			Endif

			cCell1 := xParam2
			cCell2 := xParam3
		Else
			oParser:setError(STR0133) //"Para referenciar planilhas utilize 'Plan' + o numero do folder + o operador ! + o numero da c�lula."
			lContinua := .F.
		Endif
	Endif
Endif
If lContinua 
	If !lCta
		If Len(oPCOObject:OGETDD) >= nPlanilha // Verifica��o se existe mesmo a planilha aberta na simula��o
			nMaxLinhas	:= Len(oPCOObject:OGETDD[nPlanilha]:aCols )
			nMaxColunas := Len(oPCOObject:OGETDD[nPlanilha]:aHeader)
					
			aTmp := SplitCellEnd(cCell1)
			nLineIni := Val(aTmp[1])
			cColIni  := Upper(aTmp[2])
		
			aTmp := SplitCellEnd(cCell2)
			nLineFim := Val(aTmp[1])
			cColFim  := Upper(aTmp[2])
		
			nPosIni := aScan(oPCOObject:OGETDD[nPlanilha]:AHEADER,{|x| AllTrim(x[1]) == cColIni})
			nPosFim := aScan(oPCOObject:OGETDD[nPlanilha]:AHEADER,{|x| AllTrim(x[1]) == cColFim})
			
			If nPosFim == 0
				If nLineIni == nLineFim
					nPosAntAlf := aScan(_aAlfabeto, {|letra| letra == cColFim})
					If nPosAntAlf > 0
						cConFimAnt := _aAlfabeto[nPosAntAlf]
					EndIf
				EndIf
				nPosFim := aScan(oPCOObject:OGETDD[nPlanilha]:AHEADER,{|x| AllTrim(x[1]) == cColFim})
			EndIf				
		Else
			oParser:setError(STR0138+CVALTOCHAR(nPlanilha)+STR0139) //Linha inexistente
			lContinua := .F.
		EndIf
	Else
	   lContinua := VldContaRange(xParam1,nPlanilha,xParam3,xParam4,oParser,oPCOObject,@nPosIni,@nPosFim,@nLineIni,@nLineFim,@nMaxColunas,@nMaxLinhas)
	Endif
EndIf
If lContinua
	//--------------------------------------
	//Valida o Range
	//--------------------------------------
	
	nColEdit	:= Ascan(oPCOObject:OGETDD[nPlanilha]:AHEADER, {|x| '.T.' $ Upper(x[13]) })  //Identifica a coluna editavel inicial atrav�s do When do aHeader

	If nPosIni == 0 .Or. nPosIni > nMaxColunas
		oParser:setError(STR0117) //Coluna inexistente
		lContinua := .F.
	ElseIf nPosIni < nColEdit
		oParser:setError(STR0089) // "Digite uma coluna inicial v�lida."
		lContinua := .F.	
	ElseIf nPosFim == 0 .Or. nPosFim > nMaxColunas
			oParser:setError(STR0117) //Coluna inexistente
			lContinua := .F.
	Endif
	If lContinua
		cColIni:=_aAlfabeto[nPosIni]+cValtochar(nLineIni)
		cColFim:=_aAlfabeto[nPosFim]+cvaltochar(nLineFim)
		

		If nLineIni < 1 .Or. nLineIni > nMaxLinhas
			oParser:setError(STR0116 + ": " + cValToChar(nLineIni)) //Linha inexistente
			lContinua := .F.
		ElseIf nLineFim == 0 .Or. nLineFim > nMaxLinhas
			oParser:setError(STR0116 + ": " + cValToChar(nLineFim)) //Linha inexistente
			lContinua := .F.
		Endif
	Endif
Endif
If lContinua
	If !oPCOObject:lNoExecParse
	 	cRet := '{ '
		For nX := nPosIni to nPosFim
			cColBase := oPCOObject:aAlfabeto[nX]
				For nY := nLineIni to nLineFim
					cCellName := cColBase + Alltrim(Str(nY))
					If lCta
						xValue := GetContaValue(xParam1,nPlanilha,cCellName,oParser,oPCOObject)
					Else
						xValue := oPCOObject:GetValue(cCellName,nPlanilha)
					Endif
					If !Empty(xValue)
						cRet += cValTochar(xValue) +","
					Endif
				Next nY
		Next nX
		cRet := SubStr(cRet,1,Len(cRet)-1) + "}"
	Else
		cRefRange := Iif(xParam3 == Nil  .And. xParam4 == Nil,"PLAN"+CVALTOCHAR(oPCOObject:nOpFolder),xParam1 + Iif(lCta,"!"+xParam2,"")) 
		cRet := oPCOObject:AddRange(cRefRange,cCell1,cCell2)
	Endif
Endif

If Type('aCelInFim')=="A" 
	If  Len(aCelInFim) > 0
		aCelInFim[len(acelInFim)][1]:=cColIni
		aCelInFim[len(acelInFim)][2]:=cColFim
		aCelInFim[len(acelInFim)][4]:=nPlanilha
	Else
		aAdd(aCelInFim,{cColIni,cColFim,'',nPlanilha})
	Endif

EndIf

Return cRet

Function PCO_CONTA(xContaOrca,xPlanilha,xCelula)
Local clTextForm := "CONTA(" + cValToChar(xContaOrca) + ";" +  cValToChar(xPlanilha) +  ";" + cValToChar(xCelula) +")"
Local aRet := __PCOa014Instance:TranConta(clTextForm)
If aRet[1]
	Return Val(aRet[2])
Endif
Return ""
//valida se a celula esta contida no intervalo
//-------------------------------------------------------------------
/*/{Protheus.doc} PCOInRange
Funcao auxiliar que verifica se a celula a ser atualizada esta no range da funcao

@param clCell Celula que esta sendo atualizada
@param clFormula Formula que contem o range a ser avaliado


@return lRet Se a celula estiver no intervalo, retorna .T.

@author Jandir Deodato
@since 26/11/2012
@version P10 
/*/
//-------------------------------------------------------------------

Static Function PCOinRange(clCell,clFormula,oObjPCO)
Local nLinini:=0
Local NColini:=0
Local nLinfim:=0
Local cColfim
Local cRange:="|"
Local cFormula:=clFormula
Local nX:=0
Local ny:=0
Local lRet:=.F.
Local aTMP:={}
Local cColIni
Local nColfim
Private	aCelinFim:={}
If !Empty(clCell) .and. !Empty(cFormula)
	FWEXCELParse(clFormula,oObjPCO)
	For nY:=1 to len(aCelinFim)
		IF Empty(aCelInFim[ny][3]) 
			If !Empty(aCelInFim[nY][4])//planilha
				If aCelInFim[nY][4]>1//referenciou outra planilha 
					Loop
				Endif
			Endif
		Else
			IF AllTrim(aCelInFim[ny][3]) <> Alltrim(oObjPCO:cContaSelect) .or. aCelInFim[nY][4]>1
				Loop
			Endif
		Endif
		If Alltrim(clCell)==aCelInFim[nY][1] .or. Alltrim(clCell)==aCelInFim[nY][2]
			lRet:=.T.
			Exit
		Endif
			aTMP:=SplitCellEnd(aCelinFim[ny][1])
			nLinIni:=Val(aTMP[1])
			cColIni:=Upper(aTMP[2])
			aTMP:=SplitCellEnd(aCelinFim[ny][2])
			nLinFim:=Val(aTMP[1])
			cColFim:=Upper(aTMP[2])
			nColfim:=	Ascan(_aAlfabeto,cColFim)
			NColIni:=	Ascan(_aAlfabeto,cColini)
			If nColFim > 0 .and. nColIni >0 
				For Nx := nLinIni To nLinFim
					If lRet
						Exit
					Endif
					NColIni:=	Ascan(_aAlfabeto,cColini)
					 While nColIni <= nColFim .and. !lRet .and. nColIni <522
					 	cRange+=_aAlfabeto[nColIni]+cValtoChar(nX)+"|"
					 	nColIni++
					 	If clCell $ cRange
							lRet:=.T.
							Exit
						Endif	
					 EndDo
				Next Nx
			Endif
	Next Ny
Endif
Return lRet  



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA014   �Autor  �Microsiga           � Data �  06/06/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function PcoValPlan(cPlan,oPCOObject)

Local nX 		:= 0
Local lPlanNVal	:= .F.
Local nPlan		:= 0

For nX := 1 To Len(cPlan)
   	lPlanNVal := !IsDigit(SubStr(cPlan,nX,1))
   	If lPlanNVal
   		Exit
   	EndIf
Next
			
nPlan := Val(cPlan)
			
If  lPlanNVal .Or. nPlan > Len(oPCOObject:OGETDD)
	nPlan := 0
EndIf

Return nPlan