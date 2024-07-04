#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPA013()
Dados da qualidade do produto na NFS
Adaptação da função TSMPA013
@author Itamar Oliveira
@since 19/01/2004
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLSMPA013()
Local cFiltra
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina 	:= 	{ 	{ "Pesquisar",		"AxPesqui"  	, 0, 1},; 		 //Pesquisar
						  	{ "Visualizar", 		"SMP019Vis"	, 0, 2},;		 //Visualizar
					  	  	{ "Alterar", 			"SMP019Alt"	, 0, 3},; 		 //Alterar
					  	  	{ "Informar Laudo", 	"SMP019Lau"	, 0, 4} } 		 //Informar laudo por faixa

// Nao tera opcao de Inclusao. Essa rotina sera utilizada para atualizar
// dados de qualidade do produto na Nota Fiscal de Saida (SD2)
Private cCadastro := "Dados de Qualidade"
Private aSize	  := MsAdvSize(,.F.,430)
Private aObjects  := {} 
Private aPosObj   := {} 
Private aSizeAut  := MsAdvSize() // devolve o tamanho da tela atualmente no micro do usuario
Private aIndFil	  := {}
Private bFiltraBrw:= {|| Nil}

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

AAdd( aObjects, { 315,  70, .T., .t. } )
AAdd( aObjects, { 100, 100, .t., .t. } )

aInfo   := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("DH3") // Tabela: Nota Fiscal de Saida
DH3->(dbSetOrder(4))

cFiltra := "DH3_FILIAL == '"+XFilial("DH3")+"' .And. DH3_GEROU != '1'"
bFiltraBrw := {|| FilBrowse("DH3", @aIndFil, @cFiltra) }
Eval(bFiltraBrw)

dbSelectArea("DH3")
DbGoTop()

mBrowse(6, 1, 22, 75, "DH3")

EndFilBrw("DH3", aIndFil)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SMP019LOk()
Valida Linhas da Getdados  
@author Itamar Oliveira
@since 24/01/2005
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function SMP019LOk()
Local lRet := .T.  // Conteudo de retorno
Local nPosLaudo:= aScan( aHeader, { |x| Alltrim(x[2])=="DH3_LAUDO" } )

If  !aCols[n][Len(aHeader)+1] .and. Empty( aCols[n][nPosLaudo]) 
	MsgInfo("Informe o numero do laudo")
	lRet := .F.
EndIf

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} SMP019TOk()
Valida Linhas da Getdados  
@author Itamar Oliveira
@since 24/01/2005
@version 1.0
@return _lRet
/*/
//-------------------------------------------------------------------
Function SMP019TOk()
Local _lRet := .T. // Conteudo de retorno
Local _nInd := 0	// Indexador de laco For/Next  		
Local nPosLaudo:= aScan( aHeader, { |x| Alltrim(x[2])=="DH3_LAUDO" } )

For _nInd:=1 To Len(aCols)
	If  !aCols[_nInd][Len(aHeader)+1] .and. Empty( aCols[_nInd][nPosLaudo])
		MsgInfo("Existem linhas sem preenchimento do numero do laudo")
		_lRet := .F.
		Exit
	EndIf
Next

Return ( _lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} SMP019Grava()
Efetua gravacao dos dados na tabela LHW(Grupo de Car.Fis-Qui)
@author Itamar Oliveira
@since 24/01/2005
@version 1.0
@param nOpc
@return _lRet
/*/
//-------------------------------------------------------------------
Static Function SMP019Grava(nOpc)
Local lRet       := .T.	// Conteudo de retorno 
Local nInd       := 0	// Indexador de laco For/Next
Local nItem   	 := 0   // Sequenciador de itens 
Local nPosLaudo	 := aScan( aHeader, { |x| Alltrim(x[2])=="DH3_LAUDO" } )

// Alteracao
dbSelectArea("DH3") // Tabela: Nota Fiscal de Saida
dbSetOrder(3)   	// Ordem : DH3_DOCD2 + DH3_SERIE

If MsSeek(xFilial("DH3")+M->DH3_DOCD2+M->DH3_SERIE)
	For nInd:=1 To Len(aCols)	
		RecLock("DH3",.F.)
			DH3->DH3_LAUDO := aCols[nInd][nPosLaudo]
		MsUnLock()                                 
		DbSkip()
	Next
EndIf
	
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} SMP019Alt()
Efetua gravacao dos dados na tabela LHW(Grupo de Car.Fis-Qui)
@author Itamar Oliveira
@since 26/01/2005
@version 1.0
@param cAlias
@param nReg
@param nOpc
@return _lRet
/*/
//-------------------------------------------------------------------
Function SMP019Alt(cAlias,nReg,nOpc)
Local oDlg                              	   	// Janela de dados
Local aAreaAnt:= GetArea()						// Salva ambiente
Local cKeyDH3 := cFilial+DH3->DH3_DOCD2+DH3->DH3_SERIE	// Chave para busca de registros na tabela
Local cCampos := "DH3_COD|DH3_QUANT|DH3_LAUDO"		// Campos a serem exibidos na GetDados
Local cCpoVar := "DH3_COD|DH3_QUANT|DH3_LAUDO"		// Campos para criacao de variaveis de memoria
Local aExibe  := {"DH3_DOCD2", "DH3_SERIE"}			// Campos exibidos na Enchoice()
Local aAltera := {}								// Campo editavel da Enchoice()
Local aAlter  := {"DH3_LAUDO"}
Local nCnt    := 0 									// Contador de registros para geracao do aCols
Local nOpca   := 0  								// Recebe o valor de saida da DIALOG - Quando "1" 
local nLimite										// operacao foi confirmada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de variaveis Privates   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nUsado := 0
Private aTela[0][0]
Private aGets[0]
Private aHeader[0]
Private oGetd 

RegToMemory(cAlias)

dbSelectArea("SX3")
MsSeek(cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera o aHeader para os campos da GetDados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Eof() .And. (x3_arquivo == cAlias)
	
	If X3USO(x3_usado) .And. cNivel >= x3_nivel .and.Trim(x3_Campo)$cCampos
	
		nUsado++
		
		Aadd(aHeader,{ Trim(x3_titulo), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal, x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context } )
			
	EndIf

	dbSkip()
	
Endd
		
dbSelectArea("DH3") // Tabela: Nota Fiscal Saida
dbSetOrder(3)   	// Ordem : DH3_DOCD2 + DH3_SERIE

MsSeek(cKeyDH3)

nCnt := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Varre tabela para apurar com quantas linhas devera ser gerado o aCols ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While DH3->DH3_FILIAL+DH3->DH3_DOCD2+DH3->DH3_SERIE == cKeyDH3
	nCnt++
	dbSkip()
EndDo

Private aCols[nCnt][nUsado+1]

MsSeek(cKeyDH3)

nCnt := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Varre tabela para alimentar as colunas do aCols ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While DH3->DH3_FILIAL+DH3->DH3_DOCD2+DH3->DH3_SERIE == cKeyDH3
	nCnt++
	dbSelectArea("SX3")
	MsSeek(cAlias)
	nUsado:=0
	
	While !Eof() .And. (x3_arquivo == cAlias)
		If X3USO(x3_usado) .And. cNivel >= x3_nivel .and.Trim(x3_Campo)$cCampos
			nUsado++
			If x3_context == "V"
				aCols[nCnt][nUsado] := CriaVar(AllTrim(x3_campo))
			Else
				aCols[nCnt][nUsado] := &(cAlias+"->"+x3_campo)
			EndIf	
		Endif
		dbSkip()
	End 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atribui .F. para a coluna que determina se alinha do aCols esta deletada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[nCnt][nUsado+1] := .F.

	dbSelectArea("DH3")
	dbSkip()
	
EndDo

nLimite := len(aCols)

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	EnChoice( cAlias, nReg, nOpc,,,,aExibe, aPosObj[1], aAltera, , , , , , ,.T. )

	oGetd := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"SMP019LOk","SMP019TOk",,,aAlter,,,nLimite)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(oGetd:TudoOk(),(nOpca:=1, oDlg:End()),nOpca := 0)},{||oDlg:End()}) 

If nOpca == 1 // Operacao de alteracao confirmada
	Begin Transaction
		SMP019Grava(nOpc)
	End Transaction        
Endif               

RestArea(aAreaAnt)

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} SMP019Vis()
Efetua visualizacao dos dados na tabela LHW(Grupo de Car.Fis-Qui)
@author Itamar Oliveira
@since 26/01/2005
@version 1.0
@param cAlias
@param nReg
@param nOpc
@return _lRet
/*/
//-------------------------------------------------------------------
Function SMP019Vis(cAlias,nReg,nOpc)
Local oDlg                              		   	// Janela de dados
Local aAreaAnt:= GetArea()							// Salva ambiente
Local cKeyDH3 := cFilial+DH3->DH3_DOCD2+DH3->DH3_SERIE	// Chave para busca de registros na tabela
Local cCampos := "DH3_COD|DH3_QUANT|DH3_LAUDO"		// Campos a serem exibidos na GetDados
Local cCpoVar := "DH3_COD|DH3_QUANT|DH3_LAUDO"		// Campos para criacao de variaveis de memoria
Local aExibe  := {"DH3_DOCD2", "DH3_SERIE"}			// Campos exibidos na Enchoice()
Local aAltera := {}	// Campo editavel da Enchoice()
Local nCnt    := 0 									// Contador de registros para geracao do aCols
Local nOpca   := 0  								// Recebe o valor de saida da DIALOG - Quando "1" 
local nLimite										// operacao foi confirmada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de variaveis Privates   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nUsado := 0
Private aTela[0][0]
Private aGets[0]
Private aHeader[0]
Private oGetd 

RegToMemory(cAlias,INCLUI)

dbSelectArea("SX3")
MsSeek(cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera o aHeader para os campos da GetDados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Eof() .And. (x3_arquivo == cAlias)
	
	If X3USO(x3_usado) .And. cNivel >= x3_nivel .and.Trim(x3_Campo)$cCampos
	
		nUsado++
		
		Aadd(aHeader,{ Trim(x3_titulo), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal, x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context } )
			
	EndIf

	dbSkip()
	
Endd
		
dbSelectArea("DH3") // Tabela: Nota Fiscal de Saida
dbSetOrder(3)   	// Ordem : DH3_DOCD2 + DH3_SERIE

MsSeek(cKeyDH3)

nCnt := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Varre tabela para apurar com quantas linhas devera ser gerado o aCols ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While DH3->DH3_FILIAL+DH3->DH3_DOCD2+DH3->DH3_SERIE == cKeyDH3
	nCnt++
	dbSkip()
EndDo

Private aCols[nCnt][nUsado+1]

MsSeek(cKeyDH3)

nCnt := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Varre tabela para alimentar as colunas do aCols ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While DH3->DH3_FILIAL+DH3->DH3_DOCD2+DH3->DH3_SERIE == cKeyDH3
	nCnt++
	dbSelectArea("SX3")
	MsSeek(cAlias)
	nUsado:=0
	
	While !Eof() .And. (x3_arquivo == cAlias)
		If X3USO(x3_usado) .And. cNivel >= x3_nivel .and.Trim(x3_Campo)$cCampos
			nUsado++
			If x3_context == "V"
				aCols[nCnt][nUsado] := CriaVar(AllTrim(x3_campo))
			Else
				aCols[nCnt][nUsado] := &(cAlias+"->"+x3_campo)
			EndIf	
		Endif
		dbSkip()
	End 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atribui .F. para a coluna que determina se alinha do aCols esta deletada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[nCnt][nUsado+1] := .F.

	dbSelectArea("DH3")
	dbSkip()
	
EndDo

nLimite := len(aCols)

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	EnChoice( cAlias, nReg, nOpc,,,,aExibe, aPosObj[1], aAltera, , , , , , ,.T. )

	oGetd := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"AllwaysTrue","AllwaysTrue",,.T.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}) 

RestArea(aAreaAnt)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SMP019Lau ³ Autor ³ Itamar Oliveira		³ Data ³ 14/09/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de atualizacao de laudos de qualidade por faixas    ³±±
±±³          ³ de notas fiscais										      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template DCL - SIMP										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//-------------------------------------------------------------------
/*/{Protheus.doc} SMP019Lau()
Rotina de atualizacao de laudos de qualidade por faixas de notas fiscais
@author Itamar Oliveira
@since 14/09/2005
@version 1.0
@return _lRet
/*/
//-------------------------------------------------------------------
Function SMP019Lau()
Local _cPerg := "LAUDO1", _lValid := .T., _cNFIni := 0

If Pergunte(_cPerg,.T.)
//	If AllTrim(mv_par01) == 0
	If mv_par01 == 0
		MsgInfo("Número inicial da NF em branco! Não foi possível selecionar as NF's para aplicar o numero do laudo.")
		_lValid := .F.

//	ElseIf AllTrim(mv_par02) == 0
	ElseIf mv_par02 == 0
		MsgInfo("Número final da NF em branco! Não foi possível selecionar as NF's para aplicar o numero do laudo.")
		_lValid := .F.            

//	ElseIf AllTrim(mv_par03) == ""
	ElseIf mv_par03 == ""
		MsgInfo("É obrigatório o preenchimento do número do laudo de qualidade!")
		_lValid := .F.

	ElseIf mv_par01 > mv_par02
		MsgInfo("O número da NF inicial é maior do que o número da NF final. Por favor, corrija.")
		_lValid := .F.
	EndIf
	
	If _lValid
		DbSelectArea("DH3")
		DbSetOrder(3) //DH3_DOCD2
		_cNFIni := StrZero(mv_par01, 6)
		If (DBSeek(xFilial("DH3") + _cNFIni))
			Do While Val(DH3->DH3_DOCD2) <= mv_par02 .And. !EOF()
				RecLock("DH3", .F.)
					DH3->DH3_LAUDO := mv_par03
			    MsUnlock()
			    DbSkip()                                   
			EndDo
		Else
			MsgInfo("Não foi encontrado a Nota Fiscal de número " + AllTrim(mv_par01))
		EndIf
	EndIf
EndIf

Return