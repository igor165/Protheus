#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPA013()
Dados da qualidade do produto na NFS
Adapta豫o da fun豫o TSMPA013
@author Itamar Oliveira
@since 19/01/2004
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLSMPA013()
Local cFiltra
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa뇙o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Endereca a funcao de BROWSE     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Definicao de variaveis Privates   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Private nUsado := 0
Private aTela[0][0]
Private aGets[0]
Private aHeader[0]
Private oGetd 

RegToMemory(cAlias)

dbSelectArea("SX3")
MsSeek(cAlias)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Gera o aHeader para os campos da GetDados �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Varre tabela para apurar com quantas linhas devera ser gerado o aCols �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
While DH3->DH3_FILIAL+DH3->DH3_DOCD2+DH3->DH3_SERIE == cKeyDH3
	nCnt++
	dbSkip()
EndDo

Private aCols[nCnt][nUsado+1]

MsSeek(cKeyDH3)

nCnt := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Varre tabela para alimentar as colunas do aCols �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿌tribui .F. para a coluna que determina se alinha do aCols esta deletada �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Definicao de variaveis Privates   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Private nUsado := 0
Private aTela[0][0]
Private aGets[0]
Private aHeader[0]
Private oGetd 

RegToMemory(cAlias,INCLUI)

dbSelectArea("SX3")
MsSeek(cAlias)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Gera o aHeader para os campos da GetDados �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Varre tabela para apurar com quantas linhas devera ser gerado o aCols �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
While DH3->DH3_FILIAL+DH3->DH3_DOCD2+DH3->DH3_SERIE == cKeyDH3
	nCnt++
	dbSkip()
EndDo

Private aCols[nCnt][nUsado+1]

MsSeek(cKeyDH3)

nCnt := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Varre tabela para alimentar as colunas do aCols �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿌tribui .F. para a coluna que determina se alinha do aCols esta deletada �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    쿞MP019Lau � Autor � Itamar Oliveira		� Data � 14/09/05 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Rotina de atualizacao de laudos de qualidade por faixas    낢�
굇�          � de notas fiscais										      낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Template DCL - SIMP										  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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
		MsgInfo("N�mero inicial da NF em branco! N�o foi poss�vel selecionar as NF's para aplicar o numero do laudo.")
		_lValid := .F.

//	ElseIf AllTrim(mv_par02) == 0
	ElseIf mv_par02 == 0
		MsgInfo("N�mero final da NF em branco! N�o foi poss�vel selecionar as NF's para aplicar o numero do laudo.")
		_lValid := .F.            

//	ElseIf AllTrim(mv_par03) == ""
	ElseIf mv_par03 == ""
		MsgInfo("� obrigat�rio o preenchimento do n�mero do laudo de qualidade!")
		_lValid := .F.

	ElseIf mv_par01 > mv_par02
		MsgInfo("O n�mero da NF inicial � maior do que o n�mero da NF final. Por favor, corrija.")
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
			MsgInfo("N�o foi encontrado a Nota Fiscal de n�mero " + AllTrim(mv_par01))
		EndIf
	EndIf
EndIf

Return