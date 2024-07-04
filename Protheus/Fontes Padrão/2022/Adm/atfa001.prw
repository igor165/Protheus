#INCLUDE "PROTHEUS.CH"
#INCLUDE "ATFA001.CH"
// Define dos modos das rotinas
#DEFINE VISUALIZAR	2
#DEFINE INCLUIR		3
#DEFINE ALTERAR	 	4
#DEFINE EXCLUIR	  	5
#DEFINE OK	  		1
#DEFINE CANCELA		2
#DEFINE  ENTER		Chr(13)+Chr(10)
/*
����������������������������������������������������������������������������� 
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA001  �Autor  �Alvaro Camillo Neto � Data �  16/11/10    ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de Dados Auxiliares ATF                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ATF                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFA001()

Local cFiltro			:= ""
Private cCadastro  		:= STR0001  //"Dados Auxiliares ATF"
Private cAlias  		:= "SN0"					// 
Private aRotina    		:= MenuDef()				// 

cFiltro := "SN0->N0_TABELA == '00'"

dbSelectArea(cAlias)
(cAlias)->(dbSetOrder(1)) // N0_FILIAL+N0_TABELA+N0_CHAVE
(cAlias)->(dbGotop())

dbSelectArea('SN0')
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'SN0' )
oBrowse:SetDescription( cCadastro ) 
oBrowse:SetFilterDefault( cFiltro )  
oBrowse:Activate()



Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA001MAN �Autor  �Alvaro Camillo Neto � Data �  19/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��o de manutn��o Dados Auxiliares ATF                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ATF                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFA001MAN(cAlias,nRecNo,nOpc)

Local aHeader 		:= {}
Local aCols   		:= {}
Local cCPOs			:= ""		// Campos que aparecer�o na getdados
Local cChav			:= ""

Private oEnch		:= Nil
Private oDlg		:= Nil
Private oGet		:= Nil

//�����������������������������������Ŀ
//� Variaveis internas para a MsMGet()�
//�������������������������������������
Private aTELA[0][0]
Private aGETS[0]

//��������������������������������������Ŀ
//�Variaveis para a MsAdvSize e MsObjSize�
//����������������������������������������
Private lEnchBar	:= .F. // Se a janela de di�logo possuir� enchoicebar (.T.)
Private lPadrao		:= .F. // Se a janela deve respeitar as medidas padr�es do Protheus (.T.) ou usar o m�ximo dispon�vel (.F.)
Private nMinY		:= 400 // Altura m�nima da janela

Private aSize		:= MsAdvSize(lEnchBar, lPadrao, nMinY)
Private aInfo		:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3} // Coluna Inicial, Linha Inicial
Private aObjects	:= {}
Private aPosObj		:= {}

aAdd(aObjects,{50,50,.T.,.F.})		// Definicoes para a Enchoice
aAdd(aObjects,{150,150,.T.,.F.})	// Definicoes para a Getdados
aAdd(aObjects,{100,015,.T.,.F.})

aPosObj := MsObjSize(aInfo,aObjects)// Mantem proporcao - Calcula Horizontal


// Valida��o da inclus�o
If (cAlias)->(RecCount()) == 0 .And. !(nOpc==INCLUIR)
	Return .T.
Endif

//Tratamento para executar a opcao que se deseja 
//Necessario por nao ter rotina de Inclusao.
//nOpc chega com a posi��o do array aRotina
nOpc := aRotina[nOpc,4]

cCPOs := "N0_FILIAL/N0_TABELA"
cChav := (cAlias)->N0_CHAVE
cChav := Alltrim(cChav)

// Valida��o de altera��o
IF nOpc != 2 .AND. !ATF001LVTB(cChav)
	Return nil
ENDIF

aHeader	:= CriaHeader(NIL,cCPOs,aHeader)
aCols	:= CriaAcols(aHeader,cAlias,1,xFilial("SN0")+cChav,nOpc,aCols)
MontaTela(aHeader,aCols,nRecNo,nOpc)

Return nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CriaHeader�Autor  �Alvaro Camillo Neto � Data �  19/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria o Aheader da getdados                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ATF                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CriaHeader(cCampos,cExcessao,aHeader)
Local   aArea		:= (cAlias)->(GetArea())
Default aHeader 	:= {}
DEFAULT cCampos 	:= "" // Campos a serem conciderados
DEFAULT cExcessao	:= "" // Campos que n�o conciderados

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == cAlias
	If (cNivel >= SX3->X3_NIVEL) .AND. !(AllTrim(SX3->X3_CAMPO) $ Alltrim(cExcessao)) .And. (X3USO(SX3->X3_USADO))
		aAdd( aHeader, { AlLTrim( X3Titulo() ),; // 01 - Titulo
		SX3->X3_CAMPO	,;			// 02 - Campo
		SX3->X3_Picture	,;			// 03 - Picture
		SX3->X3_TAMANHO	,;			// 04 - Tamanho
		SX3->X3_DECIMAL	,;			// 05 - Decimal
		SX3->X3_Valid  	,;			// 06 - Valid
		SX3->X3_USADO  	,;			// 07 - Usado
		SX3->X3_TIPO   	,;			// 08 - Tipo
		SX3->X3_F3		,;			// 09 - F3
		SX3->X3_CONTEXT ,;       	// 10 - Contexto
		SX3->X3_CBOX	,; 	  		// 11 - ComboBox
		SX3->X3_RELACAO , } )  		// 12 - Relacao
	Endif
	SX3->(dbSkip())
End
RestArea(aArea)
Return(aHeader)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CriaAcols �Autor  �Alvaro Camillo Neto � Data �  19/11/09  ���
�������������������������������������������������������������������������͹��
���Desc.     �Func�a que cria Acols                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�aHeader : aHeader aonde o aCOls ser� baseado                ���
���          �cAlias  : Alias da tabela                                   ���
���          �nIndice : Indice da tabela que sera usado para              ���
���          �cComp   : Informacao dos Campos para ser comparado no While ���
���          �nOpc    : Op��o do Cadastro                                 ���
���          �aCols   : Opcional caso queira iniciar com algum elemento   ���
�������������������������������������������������������������������������͹��
���Uso       � ATF                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CriaAcols(aHeader,cAlias,nIndice,cComp,nOpc,aCols)
Local 	nX			:= 0
Local 	nCols     	:= 0
Local   aArea		:= (cAlias)->(GetArea())
DEFAULT aCols 		:= {}

IF nOpc == INCLUIR
	aAdd(aCols,Array(Len(aHeader)+1))
	For nX := 1 To Len(aHeader)
		aCols[1][nX] := CriaVar(aHeader[nX][2])
	Next nX
	aCols[1][Len(aHeader)+1] := .F.
Else
	(cAlias)->(dbSetOrder(nIndice))
	(cAlias)->(dbSeek(cComp))
	While (cAlias)->(!Eof()) .And. ALLTRIM((cAlias)->(N0_FILIAL+N0_TABELA)) == ALLTRIM(cComp)
		aAdd(aCols,Array(Len(aHeader)+1))
		nCols ++
		For nX := 1 To Len(aHeader)
			If ( aHeader[nX][10] != "V")
				aCols[nCols][nX] := (cAlias)->(FieldGet(FieldPos(aHeader[nX][2])))
			Else
				aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
			Endif
		Next nX
		aCols[nCols][Len(aHeader)+1] := .F.
		(cAlias)->(dbSkip())
	End
EndIf
RestArea(aArea)
Return(aCols)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MontaTela �Autor  �Alvaro Camillo Neto � Data �  19/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Func��o respons�vel por montar a tela                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ATF                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MontaTela(aHeader,aCols,nReg,nOpc)
//�����������������������������������Ŀ
//� Variaveis da MsNewGetDados()      �
//�������������������������������������
Local nOpcX		  	:= 0						// Op��o da MsNewGetDados
Local cLinhaOk     	:= "ATF001LOK()"			// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk      	:= "AllwaysTrue()"			// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""						// Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000						// Campos estaticos na GetDados.
Local nMax         	:= 999						// Numero maximo de linhas permitidas.
Local aAlter    	:= {}						// Campos a serem alterados pelo usuario
Local cFieldOk     	:= "AllwaysTrue"			// Funcao executada na validacao do campo
Local cSuperDel     := "AllwaysTrue"			// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk        := "AllwaysTrue"			// Funcao executada para validar a exclusao de uma linha do aCols
//�����������������������������������Ŀ
//� Variaveis da MsMGet()             �
//�������������������������������������

Local aAlterEnch	:= {}						// Campos que podem ser editados na Enchoice
Local aPos		  	:= {000,000,080,400}		// Dimensao da MsMget em relacao ao Dialog  (LinhaI,ColunaI,LinhaF,ColunaF)
Local nModelo		:= 3						// Se for diferente de 1 desabilita execucao de gatilhos estrangeiros
Local lF3 		  	:= .F.						// Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria
Local lMemoria		:= .T.						// Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao
Local lColumn		:= .F.						// Indica se a apresentacao dos campos sera em forma de coluna
Local caTela 		:= ""						// Nome da variavel tipo "private" que a enchoice utilizara no lugar da propriedade aTela
Local lNoFolder	:= .F.							// Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)
Local lProperty	:= .F.							// Indica se a enchoice nao utilizara as variaveis aTela e aGets, somente suas propriedades com os mesmos nomes

//�����������������������������������Ŀ
//� Variaveis da EnchoiceBar()        �
//�������������������������������������
Local nOpcA			:= 0						// Bot�o Ok ou Cancela
Local nCont			:= 0
Local aArea			:= GetArea()
Local lExistGet

Local oTabela		:= Nil
Local oDescric		:= Nil

Private cTabela 	:= ""
Private cDescric	:= ""
Private aSaveaCols  := AClone(aCols)

//aSaveaCols		:= AClone(aCols)
//aCols 			:= AClone(aSaveaCols)

If nOpc != INCLUIR
	cTabela := IIF( (cAlias)->N0_TABELA == "00", (cAlias)->N0_CHAVE, (cAlias)->N0_TABELA)
	cTabela	:= Alltrim(cTabela)
	cDescric	:= GetAdvFVal("SN0","N0_DESC01",xFilial("SN0") +"00"+cTabela ) 
Else
	cTabela 	:= CriaVar("N0_TABELA")
	cDescric	:= CriaVar("N0_DESC01")
EndIf

//����������������������������������������������������������������������
//�Adiciona os campos a serem atualizados pelo usuario na MsNewGetDados�
//����������������������������������������������������������������������
For nCont := 1 to Len(aHeader)
	If ( aHeader[nCont][10] != "V") .And. X3USO(aHeader[nCont,7])
		aAdd(aAlter,aHeader[nCont,2])
	EndIf
Next nCont

//����������������������Ŀ
//�Defini��od dos Objetos�
//������������������������
oDlg := MSDIALOG():New(aSize[7],aSize[2],aSize[6],aSize[5],cCadastro,,,,,,,,,.T.)

If nOpc == INCLUIR .Or. nOpc == ALTERAR
	nOpcX	:= GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nOpcX	:= 0
EndIf

oTPane1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,16,.T.,.F.)
oTPane1:Align := CONTROL_ALIGN_TOP

@ 4, 006 SAY STR0003  	SIZE 70,7 PIXEL OF oTPane1 //"Tabela:"
@ 4, 062 SAY STR0004 SIZE 70,7 PIXEL OF oTPane1 //"Descricao:" 

@ 3, 026 MSGET oTabela 	 VAR cTabela 	Picture "@!" When INCLUI Valid NaoVazio(cTabela) .And. ATFA001Tab(cTabela)  SIZE 30,7 PIXEL OF oTPane1
@ 3, 090 MSGET oDescric  VAR cDescric   Picture "@!" Valid NaoVazio(cDescric) SIZE 150,7 PIXEL OF oTPane1

//�������������Ŀ
//�MsNewGetDados�
//���������������
oGet:=	MsNewGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4],nOpcX,;
        cLinhaOk ,cTudoOk ,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDLG,aHeader,aCols)
oGet:obrowse:align:= CONTROL_ALIGN_ALLCLIENT

oDlg:bInit 		:= EnchoiceBar(oDlg,{||IIF( IIF(nOpc == INCLUIR .Or. nOpc == ALTERAR, ATFA001TOK() , .T.) ,(nOpcA:=1,oDlg:End()), )},{|| oDlg:End()})
oDlg:lCentered	:= .T.
oDlg:Activate()

If nOpcA == OK .AND. !(nOpc == VISUALIZAR)
	Begin Transaction
	AT001Grava(nOpc)
	End Transaction
Endif

RestArea(aArea)
Return(nOpcA)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AT001Grava �Autor  �Alvaro Camillo Neto � Data �  19/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para efetuar a grava��o nas tabelas                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ATF                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AT001Grava(nOpc)
Local nX		:= 0
Local nI 		:= 0
Local nPosChav	:= aScan(oGet:aHeader,{|x|AllTrim(Upper(x[2]))==Upper("N0_CHAVE")})
Local lGrava	:= .F.
Local nLenACOLS := 0
Local nLenASAVE := 0

If nOpc == INCLUIR .Or. nOpc == ALTERAR
	
	//���������������������������Ŀ
	//�Grava o cabe�alho da tabela�
	//�����������������������������
	lGrava := ( (cAlias)->(dbSeek(xFilial(cAlias)+"00"+cTabela)) )
	RecLock(cAlias,!lGrava)
	(cAlias)->N0_FILIAL := xFilial(cAlias)
	(cAlias)->N0_TABELA := "00"
	(cAlias)->N0_CHAVE	:= cTabela
	(cAlias)->N0_DESC01	:= cDescric
	
	MsUnLock()
	
	//������������������������Ŀ
	//�Grava os Itens da Tabela�
	//��������������������������
	(cAlias)->(dbSetOrder(1))	//N0_FILIAL + N0_TABELA + N0_CHAVE

    nTamACOLS := len( oGet:Acols )
    nTamASAVE := len( aSaveACOLS )
    While nTamASAVE < nTamACOLS	//Ajustes de tamanho de arrays devido as inclus�es
       aadd(aSaveAcols, oGet:Acols[++nTamASAVE] ) 
    Enddo
        
	For nX:= 1 to Len(oGet:aCols)
		lGrava := ( (cAlias)->(dbSeek(xFilial(cAlias)+cTabela+aSaveACols[nX,nPosChav])) )

		If oGet:Acols[nX,Len(oGet:aHeader)+1] .And. lGrava
			RecLock(cAlias,!lGrava)
			( cAlias )->( dbDelete() )
			MsUnlock()
		ElseIf !oGet:Acols[nX,Len(oGet:aHeader)+1]
			RecLock(cAlias,!lGrava)
			(cAlias)->N0_FILIAL := xFilial(cAlias)
			(cAlias)->N0_TABELA := cTabela
			For nI:= 1 to Len(oGet:aHeader)
				(cAlias)->(FieldPut(FieldPos(Trim(oGet:aHeader[nI,2])),oGet:aCols[nX,nI]))
			Next nI
			MsUnLock()
		EndIf
	Next nX
	aSaveACols := Aclone(oGet:Acols) // Atualizando os dados da chave apos gravacao do banco

ElseIf nOpc == EXCLUIR
	//���������������Ŀ
	//�Deleta os Itens�
	//�����������������
	(cAlias)->(dbSetOrder(1)) // N0_FILIAL + N0_TABELA + N0_CHAVE
	If (cAlias)->(dbSeek(xFilial(cAlias)+ "00" + cTabela))
		RecLock(cAlias,.F.)
		( cAlias )->( dbDelete() )
		MsUnlock()
	EndIf
	
	(cAlias)->(dbSeek(xFilial(cAlias)+cTabela))
	While (cAlias)->(!EOF()) .And. (cAlias)->(N0_FILIAL + N0_TABELA ) == xFilial(cAlias)+cTabela
		RecLock(cAlias,.F.)
		( cAlias )->( dbDelete() )
		MsUnlock()
		(cAlias)->(dbSkip())
	EndDo
	
EndIf

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA001TOK �Autor  �Alvaro Camillo Neto � Data �  20/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o TudoOK da rotina                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ATF                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFA001TOK(nOpc)
Local lRet 			:= .T.
Local nX	  			:= 0
Local aCols 		:= oGet:aCols
Local aHeader		:= oGet:aHeader
Local nPosChav		:= aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("N0_CHAVE")})
Local nItens		:= 0
Local nPos			:= 0

lRet := NaoVazio(cTabela) .And. NaoVazio(cDescric) .And. ATFA001Tab(cTabela)
If nOpc == INCLUIR
	lRet := NaoVazio(cTabela) .And. NaoVazio(cDescric) .And. ATFA001Tab(cTabela)
EndIf

If lRet
	For nX:= 1 to Len(aCols)
		If !aCols[nX][Len(aHeader)+1]
			If !ATF001LOK(nX)
				lRet := .F.
				Exit
			ElseIF !Empty(aCols[nX][nPosChav])
				nItens++
			EndIf
		EndIf
	Next nX
EndIf

If lRet .And. nItens == 0
	Help(" ",1, "ATFM00LIN")	//"Por favor, crie pelo menos um item"
	lRet := .F.
EndIf


Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA001LOK �Autor  �Alvaro Camillo Neto � Data �  20/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o LinOK da rotina                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ATF                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATF001LOK(nLinha,lHelp)
Local lRet 		:= .T.
Local nX	  	:= 0
Local aCols 	:= oGet:aCols
Local aHeader	:= oGet:aHeader
Local nPosChav	:= aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("N0_CHAVE" )})
Local nPosDesc01:= aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("N0_DESC01")})

Default nLinha := oGet:nAt
Default lHelp := .T.

If !aCols[nLinha][Len(aHeader)+1] .And. (Empty(aCols[nLinha][nPosChav]) .or. Empty(aCols[nLinha][nPosDesc01]) ) 
	lRet := .F.
Else
	For nX:= 1 to Len(aCols)
		If !aCols[nX][Len(aHeader)+1] .And. nX != nLinha .And. ALLTRIM(aCols[nX][nPosChav]) == ALLTRIM(aCols[nLinha][nPosChav])
			If lHelp
				Help(" ",1, "ATFMDPLIN" )	//"Linha Duplicada"
			EndIf
			lRet := .F.
			Exit
		EndIf
	Next nX
Endif

Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA001Tab  �Autor  �Alvaro Camillo Neto � Data �  20/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao para o campo N0_TABELA                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ATF                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFA001Tab( cTabela )
Local lRet	:= .T.

If lRet .And. cTabela == "00"
	Help(" ",1, "ATFMTAB00" )  // "Tabela 00 exclusivo para o sistema"
	lRet := .F.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA001VLTB�Autor  �--------------------� Data �------------���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o de tabelas validas para alteracao                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ATF                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ATF001LVTB(cTabela)
Local lRet := .T.
Local aTabRestritas := {"01","03","04","13"}

IF aScan(aTabRestritas,{|cTabRest| Alltrim(cTabela) == cTabRest}) > 0

	HELP(" ",1,"ATF001LVTB",,STR0010,1,0) // "Tabela de manuten��o restrita. Esta a��o n�o pode ser executada nesta tabela"
    lRet := .F.
    
ENDIF

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Alvaro Camillo Neto    � Data �19/11/09 ���
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
���          �	 1 - Pesquisa e Posiciona em um Banco de Dados            ���
���          �   2 - Simplesmente Mostra os Campos                        ���
���          �   3 - Inclui registros no Bancos de Dados                  ���
���          �   4 - Altera o registro corrente                           ���
���          �   5 - Remove o registro corrente do Banco de Dados         ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina ,{STR0005 		, "AxPesqui"		,0,1 }) //"Pesquisar" 
aAdd( aRotina ,{STR0006	   		, "ATFA001MAN"		,0,2 })//"Visualizar" 
aAdd( aRotina ,{STR0008   		, "ATFA001MAN"		,0,4 })//"Alterar" 


Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Atf001Desc    �Autor  � Jose Lucas     � Data �  11/12/11  ���
�������������������������������������������������������������������������͹��
���Desc.     � Validar o conteudo do campo N0_DESC01 permitindo somente   ���
���          � conte�dos pr� definidos.                                   ���
�������������������������������������������������������������������������͹��
���Sintaxe   � Atf001Desc()							                      ���
�������������������������������������������������������������������������͹��
���Parametros�                                  					      ���
�������������������������������������������������������������������������͹��
���Uso       � ATFA001                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
Function Atf001Desc()
Local aSavArea := GetArea()
Local lRet     := .T.
Local cReadVar := ReadVar()

If AllTrim(cReadVar) $ "M->N0_DESC01"
	If cPaisLoc $ "ARG|BRA|COS" .and. AllTrim(SN0->N0_TABELA) == "06"
		If Subs(M->N0_DESC01,3,1) $ "/" .and. Subs(M->N0_DESC01,7,1) $ "|" .and. Subs(M->N0_DESC01,11,1) $ "/"
			lRet := .T.
		Else
			Help(" ",1,"N0_DESC01",,STR0011,3,1)
			lRet := .F.	
		EndIf
	EndIf	
EndIf
RestArea(aSavArea)
Return lRet		
		 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Atf001Chave   �Autor  � Jose Lucas     � Data �  11/12/11  ���
�������������������������������������������������������������������������͹��
���Desc.     � Validar o conteudo do campo N0_CHAVE n�o permitindo dupli- ���
���          � cidades.                                                   ���
�������������������������������������������������������������������������͹��
���Sintaxe   � Atf001Chave()    					                      ���
�������������������������������������������������������������������������͹��
���Parametros�                                  					      ���
�������������������������������������������������������������������������͹��
���Uso       � ATFA001                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
Function Atf001Chave()
Local aSavArea  := GetArea()
Local lRet      := .T.
Local cReadVar  := ReadVar()
Local nCount    := 1
Local nPosChave :=0

// cTabela nao existe
If Type("cTabela") == "U"
	cTabela := FwFldGet("N0_TABELA")
	If Type("cTabela") == "U"
		cTabela := N0_TABELA
	EndIf
EndIf

SN0->(dbSetOrder(1))
If  SN0->(dbSeek(xFilial("SN0")+cTabela+M->N0_CHAVE))
	Help(" ",1,"N0_CHAVE",,STR0012,3,1)
	lRet      := .F.
Endif	
If lRet .AND. AllTrim(cReadVar) $ "M->N0_CHAVE"
	If cPaisLoc $ "ARG|BRA|COS" .and. AllTrim(SN0->N0_CHAVE) == "05"
		nPosChave	:= Ascan(aHeader,{|x| AllTrim(x[2]) == "N0_CHAVE" })        		
		For nCount := 1 To Len(aCols)
			If nPosChave > 0
				If AllTrim(aCols[nCount][nPosChave]) $ M->N0_CHAVE .and. nCount <> n
					lRet := .F.
				EndIf
			EndIf
			
		Next nCount		
		If ! lRet	 
			Help(" ",1,"N0_CHAVE",,STR0012,3,1)
		EndIf
	EndIf		
EndIf
RestArea(aSavArea)
Return lRet			

             
