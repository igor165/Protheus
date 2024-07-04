#include "pmsr260.ch"
#include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PMSR260   ³ Autor ³ Cristiano G. da Cunha ³ Data ³ 24.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao da Planilha do Orcamento / Projeto                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1   - Arquivo temporario                                ³±±
±±³          ³aArray1 - Array com os campos selecionados                  ³±±
±±³          ³cExp2   - Orcamento / Projeto                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PMSR260(cArquivo,aCampos,cCompTit)
Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := cCompTit 
Local titulo         := cCompTit 
Local nLin           := 80
Local Cabec1         := ""
Local Cabec2         := ""
Local aOrd           := {}
Local aArea			 := GetArea()
Local aAreaTrb 		 := (cArquivo)->(GetArea())

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "PMSR260"
Private nTipo        := 18
Private aReturn      := { STR0004,1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private CbTxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "PMSR260"
Private cPerg   := "PMR260"  // Pergunta do Relatorio
Private cString := "AF8"

SaveInter()


dbSelectArea(cArquivo)

Pergunte(cPerg,.F.)

// monta a interface padrão com o usuário...
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

// RPTSTATUS monta janela com a régua de processamento
RptStatus({|| Pmr260Imp(Cabec1,Cabec2,Titulo,nLin,cArquivo,aCampos) },Titulo)

RestInter()
RestArea(aAreaTrb)
RestArea(aArea) 
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pmr260Imp³ Autor ³ Cristiano G. da Cunha  ³ Data ³ 24.05.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Pmr260Imp(Cabec1,Cabec2,Titulo,nLin)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSR260                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Pmr260Imp(Cabec1,Cabec2,Titulo,nLin,cArquivo,aCampos)
Local nCntLet := 0, nCount := 0, ny := 0
Local nOpcRel  := 1
Local lContinua
Local aCpoImp	:= {}
Local aProcForm := {}
Local nX 		:= 0
Local cCpoImp	:= ""

Local i := 0
Local j := 0

Local nTamMax   := 0      // tamanho máximo de uma coluna
Local nColuna   := 220    // posição da coluna atual a ser impressa

Local lPrintAll   := .F.  // imprime a descrição das tarefas em todas páginas
Local lPrintFirst := .T.  // imprime a descrição das tarefas apenas na 1a. página

Local nPagina  := 0       // percorre as páginas a serem impressas
Local aPaginas := {}      // páginas a serem impressas
Local nTotPag  := 1       // total de páginas a serem impressas

Local nColIni  := 0       // posição da coluna dentro da página

Local aColunas := {}      // informações sobre as colunas a serem impressas
Local aColuna  := {}      // informações sobre uma coluna
Local aColPlan := {}      // 

Local nSpace   := 1       // espaço após cada coluna
Local nRecno   := (cArquivo)->(Recno())

// parâmetro "Repete descrição"
If mv_par01 == 2
	lPrintAll := .T.
EndIf

For nx := 1 to Len(aCampos)
	If Substr(aCampos[nx][1],1,1)=="$"
		aCpoAux  := &(Substr(aCampos[nx][1],2,Len(aCampos[nx][1])-1)+"(2)")
		aAdd(aCpoImp,aCpoAux)
	ElseIf Substr(aCampos[nx][1],1,1)=="%"
		aCpoAux := {AllTrim(Substr(aCampos[nx][1],  2, 12)),;  // descricao
		            Substr(aCampos[nx][1], 58, 60),;           // expressao
		            AllTrim(Substr(aCampos[nx][1], 22, 35)),;  // picture
		            Val(Substr(aCampos[nx][1], 17,  2)),;      // tamanho
		            Substr(aCampos[nx][1], 15,  1)}            // tipo de dado
		aAdd(aCpoImp,aCpoAux)
	ElseIf Substr(aCampos[nx][1],1,1)#"|"
		dbSelectArea("SX3")
		dbSetOrder(2)
		If MsSeek(aCampos[nx][1])
			aCpoAux := { Trim(X3TITULO()), "X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)), AllTrim(X3_PICTURE),X3_TAMANHO,X3_TIPO}
			aAdd(aCpoImp,aCpoAux)			
		EndIf
	EndIf	
Next

lContinua := .T.
aColPlan := {}
For i := 1 To Len(aCpoImp)
	aColuna := {}
	aEval( aCpoImp[i] ,{|x| aAdd( aColuna ,x ) } )
	aAdd( aColuna ,len(rTrim( aCpoImp[i][1] )) )
	aAdd( aColPlan ,aColuna )
Next i
                       
(cArquivo)->(dbGoTop())
While (cArquivo)->(!Eof())
	For i := 1 To Len(aColPlan)
		If aColPlan[i][5] == "N"
			If Empty(aColPlan[i][3])
				cVlrCol := rTrim(Str((cArquivo)->(FieldGet(FieldPos(aColPlan[i][2])))))
			Else
				cVlrCol := rTrim(Transform((cArquivo)->(FieldGet(FieldPos(aColPlan[i][2]))), aColPlan[i][3]))
	  		EndIf
	  	ElseIf aColPlan[i][5] == "D"
			If Empty(aColPlan[i][3])
				cVlrCol := dtoc((cArquivo)->(FieldGet(FieldPos(aColPlan[i][2]))))
			Else
				cVlrCol := rTrim(Transform((cArquivo)->(FieldGet(FieldPos(aColPlan[i][2]))), aColPlan[i][3]))
  			EndIf
	  	
	  	Else	
			If Empty(aColPlan[i][3])
				cVlrCol := rTrim((cArquivo)->(FieldGet(FieldPos(aColPlan[i][2]))))
			Else
				cVlrCol := rTrim(Transform((cArquivo)->(FieldGet(FieldPos(aColPlan[i][2]))), aColPlan[i][3]))
  			EndIf
		EndIf
		
		If aColPlan[i][6] < len( cVlrCol )
			aColPlan[i][6] := len( cVlrCol )
		EndIf
		
	Next i
	(cArquivo)->(dbSkip())
EndDo

For i := 1 To Len(aColPlan)
	nTamMax := aColPlan[i][6]

	If nColuna + nTamMax + 3 > 220
		nColuna := 0
		aAdd(aPaginas, 0)
				
	 	If lPrintAll .Or. lPrintFirst
			
			// código da tarefa
			aColuna := {}
			
			aAdd(aColuna, aColPlan[1][1]) // 1 - descrição da coluna
			aAdd(aColuna, aColPlan[1][2]) // 2 - expressão da coluna
			aAdd(aColuna, aColPlan[1][3]) // 3 - picture da coluna
			aAdd(aColuna, aColPlan[1][4]) // 4 - tamanho da coluna
			aAdd(aColuna, aColPlan[1][6]) // 5 - tamanho máximo da coluna
			aAdd(aColuna, nColuna)        // 6 - posição da coluna			
			aAdd(aColuna, aColPlan[1][5])  // 7 - tipo de dado da coluna
			
			aAdd(aColunas, aClone(aColuna))
			nColuna += aColPlan[1][6] + nSpace
			
			// descrição da tarefa		
			aColuna := {}
			
			aAdd(aColuna, aColPlan[2][1])         // 1 - descrição da coluna
			aAdd(aColuna, aColPlan[2][2])         // 2 - expressão da coluna
			aAdd(aColuna, aColPlan[2][3])         // 3 - picture da coluna
			aAdd(aColuna, aColPlan[2][4])         // 4 - tamanho da coluna
			aAdd(aColuna, aColPlan[2][6]) // 5 - tamanho máximo da coluna			
			aAdd(aColuna, nColuna)               // 6 - posição da coluna			
			aAdd(aColuna, aColPlan[2][5])         // 7 - tipo de dado da coluna
			
			aAdd(aColunas, aClone(aColuna))
			nColuna += aColPlan[2][6] + nSpace
			
			aPaginas[Len(aPaginas)] := 2
			
			If lPrintFirst
				lPrintFirst := .F.
			EndIf
		EndIf
	EndIf
  
	If i < 3
		Loop
	EndIf
	
	aColuna := {}
	  
	aAdd(aColuna, aColPlan[i][1]) // 1 - descrição da coluna
	aAdd(aColuna, aColPlan[i][2]) // 2 - expressão da coluna
	aAdd(aColuna, aColPlan[i][3]) // 3 - picture da coluna
	aAdd(aColuna, aColPlan[i][4]) // 4 - tamanho da coluna
	aAdd(aColuna, aColPlan[i][6]) // 5 - tamanho máximo da coluna
	aAdd(aColuna, nColuna)        // 6 - posição da coluna			
	aAdd(aColuna, aColPlan[i][5]) // 7 - tipo de dado da coluna
  
	aAdd(aColunas, aColuna)

	nColuna += nTamMax + nSpace

	aPaginas[Len(aPaginas)]++
Next

If Len(aPaginas) > 1
	nOpcRel := Aviso(STR0006,STR0007,{STR0008,STR0009,STR0010}) //"Tamanho"###"O total de colunas selecionadas excedeu ao tamanho maximo do relatorio."###"Cancelar"###"Resumido"###"Completo"
	If nOpcRel == 1
		lContinua := .F.
	ElseIf nOpcRel == 2
		Aviso(STR0011,STR0012,{STR0013}) //"Relatorio Resumido"###"O relatorio sera ajustado subtraindo-se alguns campos para que os registros sejam impressos obedecendo o tamanho da pagina."###"Ok"
	ElseIf nOpcRel == 3
		Aviso(STR0014,STR0015,{STR0013}) //"Relatorio Completo"###"O relatorio sera impresso contendo quebras de paginas para impressao de todos os dados dos registros."###"Ok"
	EndIf
EndIf

If lContinua

	// impressão resumida imprimir apenas os campos
	// mais a esquerda da planilha, de modo a caber
	// em apenas uma página
	If nOpcRel == 2
		nTotPag := 1
	Else
		nTotPag := Len(aPaginas)
	EndIf

	// indica quantos registros serão processados para a régua
	SetRegua((cArquivo)->(RecCount()) * Len(aPaginas))
	
	lImpDet := .F.
	nColIni := 0

	For nPagina := 1 To nTotPag
		dbSelectArea(cArquivo)
		(cArquivo)->(dbGoTop())
		
		nColIni := GetInicio(aPaginas, nPagina)

		While !(cArquivo)->(Eof())
			nLin++
			
			For j := 1 To aPaginas[nPagina]
				If nLin > 60
					If lImpDet
						@ nLin, 00 PSay __PrtThinLine()
						lImpDet := .T.
					EndIf
		
					Cabec1 	:= MontaCabec(aColunas, nColIni + j, nColIni + aPaginas[nPagina], nSpace)
					nLin		:=	Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)

					nLin += 1
				EndIf
			
  				nCol := 1
  			
				// processa campo da planilha	
				nCntLet := 0
				nCount := 0

				For ny := 1 To Len(aColunas)
					nCntLet++
					
					If nCntLet > 26
						nCntLet	:= 1
						nCount++
					EndIf
					
					If nCount > 0
						&(Chr(64 + nCntLet) + Chr(48 + nCount)) := (cArquivo)->(FieldGet(ny))
					Else
						&(Chr(64 + nCntLet)) := (cArquivo)->(FieldGet(ny))
					EndIf

				Next

				// processa variáveis globais
				cCpoImp := aColunas[nColIni + j][2];

				If RepVar(@cCpoImp, aColunas[nColIni + j][2]) == -1
					Alert("Erro processando o campo " + Substr(aAuxCps[aProcForm[nx]][1], 2, 12) +;
					"=" + cBlock)
					MsUnlock()
					Return			
				EndIf

				// imprime a coluna
				nCol := aColunas[nColIni + j][6]

				Do Case 
					Case aColunas[nColIni + j][7] == "N"
				  		If Empty(aColunas[nColIni + j][3])
				  			@ nLin, nCol PSay PadL(&cCpoImp, aColunas[nColIni + j][5])
				  		Else
				  			@ nLin, nCol PSay PadL(Transform(&cCpoImp, aColunas[nColIni + j][3]),;
				  		                  aColunas[nColIni + j][5])
				  		EndIf					

  				Otherwise
 					If Empty(aColunas[nColIni + j][3])
				  		@ nLin, nCol PSay PadR(&cCpoImp, aColunas[nColIni + j][5])
				  	Else
				  		@ nLin, nCol PSay PadR(Transform(&cCpoImp, aColunas[nColIni + j][3]),;
				  		                  aColunas[nColIni + j][5])
				  	EndIf					
						
				EndCase                              
			Next
			
			dbSelectArea(cArquivo)
			(cArquivo)->(dbSkip())
      
			IncRegua()
		End                                    
    
		@ nLin + 1, 00 PSay __PrtThinLine()

		nLin := 60
	Next

	// finaliza a execução do relatório
	Set Device To Screen
	
	// se impressão em disco, chama o gerenciador de impressão
	If aReturn[5] == 1
		dbCommitAll()
		Set Printer To
		OurSpool(wnrel)
	EndIf
EndIf	

(cArquivo)->(dbGoTo(nRecno))
	
MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³MaxLength³ Autor ³ Adriano Ueda           ³ Data ³ 18/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Impressao do relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parâmetros³ aItem                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PMSR260                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MaxLength(aItem)
	Local nTamCampo := 0
	Local nTamTit   := 0
	Local nTamMax   := 0

	If aItem[5] == "N" .And. !Empty(aItem[3])
		nTamCampo := Len(Transform(1, aItem[3]))
		
		If nTamCampo < aItem[4]
			nTamCampo := aItem[4]
		EndIf
	Else
		// tamanho do campo
		nTamCampo := aItem[4]
	EndIf
	
	nTamTit := Len(aItem[3])
	
	nTamMax := If(nTamCampo > nTamTit, nTamCampo, nTamTit)	

Return nTamMax


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³MaxLength³ Autor ³ Adriano Ueda           ³ Data ³ 18/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Impressao do relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parâmetros³ aItem                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PMSR260                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GetInicio(aPaginas, nPagina)
	Local i := 1
	Local nOffset := 0
	
	For i := 1 To (nPagina - 1)
		nOffset += aPaginas[i]
	Next
Return nOffset

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³MontaCabe³ Autor ³ Adriano Ueda           ³ Data ³ 18/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Monta o cabeçalho do relatório                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parâmetros³ aColunas - Colunas do relatório                              ³±±
±±³          ³ nInicio  - índice da coluna inicial a ser impressa           ³±±
±±³          ³ nFim     - índice da coluna final a ser impressa             ³±±
±±³          ³ nSpace   - espaço entre no final das colunas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PMSR260                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaCabec(aColunas, nInicio, nFim, nSpace)
	Local i := 1
	Local cBuffer := ""

	For i := nInicio To nFim 
		If aColunas[i][7] == "N"
			cBuffer += PadL(aColunas[i][1], aColunas[i][5]) + Space(nSpace)
		Else
			cBuffer	+= PadR(aColunas[i][1], aColunas[i][5]) + Space(nSpace)
		EndIf
	Next
Return cBuffer