#Include "Protheus.Ch"
#Include "DiaDs.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GIAMT     ³ Autor ³THIAGO GALVAO SILVEIRA ³ Data ³02.10.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do meio-magnetico para GIAMT  3.07               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN -> nFuncao - Funcao a ser chamada pela principal.      ³±±
±±³          ³ExpC -> String - String qualquer utilizada pelas funcoes.   ³±±
±±³          ³ExpN -> nPosFimCfp - Posicao final do arquivo CFP utilizado ³±±
±±³          ³ pela funcao sfRetCfop().                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±                                                   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GIAMT (nFuncao, cString)
	Local	xRet	:=	.T.
	Local	cCfpDia		:=	""
	//
	Default	nFuncao		:=	1
	Default	cString		:=	""
	//
	cCfpDia	:=	"GIAMT"+cEmpAnt+cFilAnt+".CFP"
	//
	If (nFuncao==1)
		xRet	:=	GIAMTCfp (cCfpDia)
	ElseIf (nFuncao==2)	
		xRet	:=	LeCfp (AllTrim (cCfpDia))
	EndIf
	//
Return (xRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GIAMTCfp  ³ Autor ³Thiago Galvao Silveira ³ Data ³02.09.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta arquivo CFP com parametros a serem utilizados no      ³±±
±±³          ³GIAMT.INI                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GIAMTCfp (cCfpDia)
	Local 	cValid 		:= ""
	Local 	nI	 		:= 1
	Local 	nOpcA	 	:= 2
	Local 	lRet	 	:= .T.
	Local 	oDlgGet
	Local	cBarra		:=	""
	Local	cTitJan		:=	""
    //
	Private	aSel		:= {}
	Private aListBox	:= {}
	Private	aMsg	  	:= {}
	Private	aValid	  	:= {}
	Private	aConteudo 	:= {}
	//                                                                                                                                                                                                                
    aAdd (aListBox, OemToAnsi ("0001 - Tipo de Declaracao"))                             ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0001 - Tipo de Declaracao")); 	     aAdd (aValid, "VldCfp ('C', 'OPCOES')") 	                      //"0001 - Tipo de Declaracao"
    aAdd (aListBox, OemToAnsi ("0002 - Motivo da Declaracao"))                           ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0002 - Motivo da Declaracao")); 	     aAdd (aValid, "VldCfp ('C', 'OPCOES')") 	                  //"0002 - Motivo da Declaracao"    
    aAdd (aListBox, OemToAnsi ("0003 - Tipo de Contribuinte"))                           ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0003 - Tipo de Contribuinte")); 	     aAdd (aValid, "VldCfp ('C', 'OPCOES')") 	                  //"0003 - Tipo de Contribuinte"    
    aAdd (aListBox, OemToAnsi ("0004 - Telefone do Contribuinte"))                       ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0004 - Telefone do Contribuinte")); 	 aAdd (aValid, "VldCfp ('C', 'FONE')") 	                      //"0004 - Telefone do Contribuinte"
    aAdd (aListBox, OemToAnsi ("0005 - Escrita Contabil regular"))                       ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0005 - Escrita Contabil regular")); 	 aAdd (aValid, "VldCfp ('L', 'SIM/NAO')") 	                  //"0005 - Escrita Contabil regular"    
    aAdd (aListBox, OemToAnsi ("0007 - Data de cadastratameno na SEFAZ"))                ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0007 - Data de cadastratameno na SEFAZ")); 	aAdd (aValid, "VldCfp ('D', 'DATA')")                 //"0007 - Data de cadastratameno na SEFAZ"    
    aAdd (aListBox, OemToAnsi ("0008 - Periodicidade"))                                  ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0008 - Periodicidade")); 	aAdd (aValid, "VldCfp ('C', 'OPCOES')")                                   //"0008 - Periodicidade"    
    aAdd (aListBox, OemToAnsi ("0009 - Codigo do Domicilio fiscal de origem"))           ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0009 - Codigo do Domicilio fiscal de origem")); 	aAdd (aValid, "VldCfp ('C', 'STR')")              //"0009 - Codigo do domicilio fiscal de origem"    
    aAdd (aListBox, OemToAnsi ("0010 - Codigo do Domicilio fiscal de destino"))          ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0010 - Codigo do Domicilio fiscal de destino")); 	aAdd (aValid, "VldCfp ('C', 'STR')")              //"0010 - Codigo do domicilio fiscal de destino"    
    aAdd (aListBox, OemToAnsi ("0011 - Codigo da Atividade Economica"))                  ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0011 - Codigo da Atividade Economica")); 	aAdd (aValid, "VldCfp ('C', 'STR')")                      //"0011 - Codigo da Atividade Economica"    
    aAdd (aListBox, OemToAnsi ("0012 - Disponibilidade de caixa no Inicio do Periodo"))  ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0012 - Disponibilidade de caixa no Inicio do Periodo")); 	aAdd (aValid, "VldCfp ('N', 'VALOR')")    //"0012 - Disponibilidade de caixa no Inicio do Periodo"    
    aAdd (aListBox, OemToAnsi ("0013 - Disponibilidade de caixa no Final do Periodo"))   ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0013 - Disponibilidade de caixa no Final do Periodo")); 	aAdd (aValid, "VldCfp ('N', 'VALOR')")    //"0013 - Disponibilidade de caixa no Final do Periodo"    
    aAdd (aListBox, OemToAnsi ("0014 - Numero de funcionarios no Inicio do periodo"))    ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0013 - Numero de funcionarios no Inicio do periodo")); 	aAdd (aValid, "VldCfp ('N', 'STR')")      //"0014 - Numero de funcionarios no Inicio do periodo"    
    aAdd (aListBox, OemToAnsi ("0015 - Numero de funcionarios no Final do Periodo"))     ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0013 - Numero de funcionarios no Final do Periodo")); 	aAdd (aValid, "VldCfp ('N', 'STR')")          //"0015 - Numero de funcionarios no Final do Periodo"    
    aAdd (aListBox, OemToAnsi ("0016 - Tipo de Contabilista"))                           ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0014 - Tipo de Contabilista")); 	aAdd (aValid, "VldCfp ('C', 'STR')")                              //"0016 - Tipo de Contabilista"    
    aAdd (aListBox, OemToAnsi ("0017 - CRC do Contabilista"))                            ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0015 - CRC do Contabilista")); 	aAdd (aValid, "VldCfp ('C', 'STR')")                              //"0017 - CRC do Contabilista"    
    aAdd (aListBox, OemToAnsi ("0018 - Houve movimentacao no periodo"))                  ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0016 - Houve movimentacao no periodo")); 	aAdd (aValid, "VldCfp ('L', 'SIM/NAO')")                  //"0018 - Houve movimentacao no periodo"    
    aAdd (aListBox, OemToAnsi ("0019 - Houve movimentacao Interestadual no Exercicio"))  ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0017 - Houve movimentacao Interestadual no Exercicio")); 	aAdd (aValid, "VldCfp ('L', 'SIM/NAO')")  //"0019 - Houve movimentacao Interestadual no Exercicio"    
    aAdd (aListBox, OemToAnsi ("0020 - Detalhamento ANEXO V"))                           ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0018 - Detalhamento ANEXO V")); 	 aAdd (aValid, "VldCfp ('L', 'SIM/NAO')") 	                  //"0020 - Detalhamento ANEXO V"    

	For nI := 1 To (Len (aListBox))
		aListBox [nI]	:=	OemToAnsi (aListBox [nI])
		aMsg [nI]		:=	OemToAnsi (aMsg [nI])
	Next (nI)                
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Le informacoes do arquivo de configuracao GIAMT?.CFP   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Load (cCfpDia)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa ListBox com opcoes para o array da configuracao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cBarra	:=	"Parametros adicionais da GIA - ICMS"	//"Parametros adicionais da GIA - ICMS"	
	cTitJan	:=	"GIA - MT"	//"GIA - MT"
	
	//
	Define MSDialog oDlgGet Title OemToAnsi (cBarra) From 180, 110 To 550, 700 Pixel Of oMainWnd
	@ 010, 020 Say OemToAnsi (cTitJan) Size 140, 007 Of oDlgGet Pixel
	@ 026, 018 To 155, 277 LABEL "" OF oDlgGet Pixel
	@ 033, 022 ListBox oListBox Var cVar Fields Header "" On DBLCLICK (List (oListBox)) Size 250, 115 Pixel
	//	
	oListBox:SetArray (aListBox)
    oListBox:bLine := {||{aListBox[oListBox:nAt]}}
	//
	Define SButton From 165, 220 Type 1 Action (nOpca := 1, oDlgGet:End ()) Enable Of oDlgGet
	Define SButton From 165, 248 Type 2 Action (nOpca := 2, oDlgGet:End ()) Enable Of oDlgGet
	//
	Activate MSDialog oDlgGet Centered
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava itens no arquivo de configuracao GIAMT?.CFP   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nOpcA==1)
		GravaIt (cCfpDia)
	Endif
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Load      ³ Autor ³Thiago Galvao Silveira ³ Data ³02.10.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega conteudo do arquivo ini passado como parametro.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> lRet (.T.)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> Arquivo .CFP a ser criado.                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Load (ArqIni)
	Local nI			:=	0
	Local cConteudo	:=	""
	Local lRet		:=	.T.
	//	
	If (File (ArqIni))
		For nI := 1 To (Len (aListBox))
			cConteudo	:=	""
			If (IsDigit (SubStr (aListBox[nI], 2, 4)))
				cConteudo	:=	Ler (ArqIni, Substr (aListBox[nI], 2, 4))
				If (Len (cConteudo)<254)
					cConteudo	:=	cConteudo+Space (254-Len (cConteudo))
				EndIf
			Endif
			aAdd (aConteudo, cConteudo)
		Next
	Else
		For nI := 1 To (Len (aListBox))
			aAdd (aConteudo, Space (254))
		Next
	Endif
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GravaIt   ³ Autor ³Thiago Galvao Silveira ³ Data ³02.09.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava arquivo INI.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> lRet (.T.)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> Arquivo .CFP a ser criado.                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaIt (ArqIni)
	Local	cArqBkp	:=	StrTran (ArqIni, ".CFP", ".#CF")
	Local	aGravar	:=	{}
	Local	nI		:=	0
	Local	lRet	:=	.T.
	//
	If File(cArqBkp)
		Ferase(cArqBkp)
	Endif
	FRename(ArqIni,cArqBkp)
	nHandle	:=	MSFCREATE(ArqIni)
	//
	For nI := 1 To (Len (aListBox))
		If (IsDigit (Substr (aListBox[nI], 2, 4)))
			aAdd (aGravar, "["+Substr (aListBox[nI], 2, 4)+"]="+Rtrim (aConteudo[nI])+Chr(13)+Chr(10))
		EndIf
	Next
	For nI := 1 To (Len (aGravar))
		FWrite (nHandle, aGravar[nI], Len(aGravar[nI]))
	Next
	FClose(nHandle)
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³List      ³ Autor ³Thiago Galvao Silveira ³ Data ³02.10.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atualiza parametro clicando.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> lRet (.T.)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO -> oListBox = Objeto listbox.                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function List (oListBox)
	Local oDlgGet2
	Local nOpcaGet	:=	2
	Local lUpdated	:=	.F.
	Local bValid
	Local lRet		:=	.T.  
    Local oOpcoes
	Local cOpcoes   := "Thiago"
	Local aOpcoes   := {"Normal","Substitutiva"}
	Private cCampo	:=	"cCpoItem"
	//
	nAt	:=	oListBox:nAt
	//
	Private cValid	:=	"{||"+aValid[nAt]+"}"
	//
	If (aSel[nAt])
		&cCampo	:=	aConteudo[nAt]
		bValid	:=	&(cValid)
		//
		Define MSDialog oDlgGet2 Title aMsg[nAt] From  300,100 To 400,620 Pixel Of oListBox
		@ 08, 20 To 27, 237 LABEL "" Of oDlgGet2 Pixel
		If (cCampo=="OPCOES")
		   @ 15, 24 ComboBox cOpcoes items aOpcoes size 210,08 of oDlgGet2 pixel
		Else
		   @ 15, 24 MSGet &cCampo Picture "@!" Valid Eval (bValid) Size 210, 08 Of oDlgGet2 Pixel
		EndIf   
		//
		Define SButton From 032, 182 Type 1 Action (lUpdated:=.T.,oDlgGet2:End ()) Enable Of oDlgGet2
		Define SButton From 032, 210 Type 2 Action (lUpdated:=.F.,oDlgGet2:End ()) Enable Of oDlgGet2
		//
		Activate MSDialog oDlgGet2 Centered
		//
		If (lUpdated)
			aConteudo[nAt]	:=	StrTran (&cCampo,'"',"'")
		Endif
	Endif
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ler       ³ Autor ³Thiago Galvao Silveira ³ Data ³02.10.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Le o CFP.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> lRet (.T.)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL -> lEnd                                                ³±±
±±³          ³ExpC -> cCpo                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ler (cArqIni, cCPO, lEnd)
	Local cIni		:=	""
	Local cConteudo	:=	""
	Local nI		:=	0
	//
	lEnd := If (lEnd==NIL, .F., lEnd)
	cCPO := "["+cCPO+"]="
	//
	If !File (cArqIni)
		Help (" ",1,"GIAMT"+cEmpAnt+cFilAnt+".CFP")
		lContinua	:=	.F.
		lEnd		:=	.T.
		Return (cIni)
	Else
		cConteudo	:=	MemoRead (cArqIni)
		nLinhas		:=	MlCount (cConteudo, 254)
		//
		For nI := 1 To nLinhas
			cLinha	:=	AllTrim (MemoLine (cConteudo, 254, nI))
			If (cCPO$cLinha)
				cIni := SubStr (cLinha, 8)
				Exit
			Endif
		Next
	Endif
Return(cIni)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³VldCfp    ³ Autor ³Thiago Galvao Silveira ³ Data ³02.09.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida string do CFP.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> lRet (.T./.F.)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> cTipo - Tipo do campo.                              ³±±
±±³          ³ExpC -> cCampo - Campo a ser tratado.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VldCfp (cTipo, cCampo)
	Local	lRet		:=	.T.
	Local	cConteudo	:=	&(ReadVar())
	Local	nI			:=	0
	//
	Default	cTipo	:=	""
	Default	cCampo	:=	""
	//
	cConteudo	:=	Alltrim (cConteudo)
	//
	If (cTipo=="N")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Avalia valores numericos                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(Isdigit (SubStr (cConteudo, nI, 1)))
			lRet	:=	.F.
		Endif
	ElseIf cTipo=="D"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Avalia datas.                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		If (CToD (cConteudo)==CToD (Space (8)))
		   lRet	:=	.F.
		Endif
	EndIf
	//
	If (cCampo=="OPCOES")
		If !(AllTrim (cConteudo)$"123456") .Or. Empty(cConteudo)
		   Help (" ", 1, "OPCAO INVALIDA",,"Escolha uma opcao [1 - Normal, 2 - Substitutiva]", 3, 0)	//"Permitido somente 1 digito! [1 - Normal, 2 - Substitutiva]"
		   lRet	:=	.F.
		Endif
	ElseIf (cCampo=="DATA")
  	    If (Len (AllTrim (cConteudo))<>10)
		   Help (" ", 1, "DATA INVALIDA",,"Inserir Data no Formato DD/MM/AAAA", 3, 0)	//"Inserir Data no Formato DD/MM/AAAA"
		   lRet	:=	.F.
		Endif
    ElseIf (cCampo=="FONE")
  	    If (Len (AllTrim (cConteudo))<>16)
		   Help (" ", 1, "FORMATO INVALIDO",,"Inserir Telefone no Formato (0XX)99-999-9999", 3, 0)	//"Inserir Telefone no Formato (0XX)99-999-9999"
		   lRet	:=	.F.
		Endif
	ElseIf (cCampo=="VALOR")
		If (Len (AllTrim (cConteudo))>16) .OR. !("."$((cConteudo)))
		   Help (" ", 1, "VALOR INVALIDO",,"Inserir Valor no formato 9999999999999.99", 3, 0)	//"Inserir Valor no formato 9999999999999.99"
		   lRet	:=	.F.
		Endif
	ElseIf (cCampo=="SIM/NAO")
		If !(AllTrim (cConteudo)$"S/N")
		   Help (" ", 1, "CONTEUDO INVALIDO",,"Informar S para Sim e N para Não", 3, 0)	//"Informar S para Sim e N para Não"
		   lRet	:=	.F.
		Endif
	EndIf	
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LeCfp     ³ Autor ³Thiago Galvao Silveira ³ Data ³02.09.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta o CFP em um array para ser utilizado no INI.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> aRet - array conteudo CFP.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> cArquivo - Arquivo CFP.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LeCfp (cArquivo)
	Local	cConteudo	:= MemoRead (cArquivo)
	Local	nLinhas		:= MlCount (cConteudo, 254)
	Local	nI			:= 0
	Local	aRet		:= {}
	//
	For nI := 1 To nLinhas
		cLinha	:=	AllTrim (MemoLine (cConteudo, 254, nI))
		aAdd (aRet, {SubStr (cLinha, 2, 3), SubStr (cLinha, 8)})
	Next
Return (aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³XMLConv   ³ Autor ³Thiago Galvao Silveira ³ Data ³30.09.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Converte um campo para o formato XML                       ³±±	
±±³			 ³ CAMPO1 ====>"(<descricao>CAMPO1</descricao>)"                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function XMLConv(cCampo,cTipo,nTamanho,cTag,lTagI,lTagF,nDeslc)
Local cXML       := ""  // Campo no Formato XML
Local cTagI      := ""  // Tag de Inicio
Local cTagF      := ""  // Tag de Fim

Default cCampo   := ""  // Campo a ser convertido 
Default cTipo    := ""  // Tipo do campo a ser convertido
Default nTamanho := 0   // Tamanho do Campo a ser convertido
Default cTag     := ""  // Descricao da Tag
Default lTagI    := .T. // Inicio de estrutura
Default lTagF    := .T. // Fim de estrutura
Default nDeslc   := 0   // Numero de posicoes deslocadas a direita

cTagI  := Replicate(" ",nDeslc)+"<"+cTag+">"
cTagF  := IIF(!lTAGI,Replicate(" ",nDeslc)+"</"+cTag+">","</"+cTag+">")

If cTipo == "N"
   IF Empty(cCampo) 
      cCampo   := "0"
   Else
      If valtype(cCampo) == "N"
         cCampo := Transform(cCampo,"@e 9999999999999.99")
         cCampo := StrTran(cCampo," ","")
         cCampo := StrTran(cCampo,",",".")
      Else                 
         cCampo := RetChar(AllTrim(cCampo),.T.,.T.,.T.,.T.,.F.,nTamanho,.F.)
         cCampo := Substr(cCampo,2,13)+"."+Substr(cCampo,15,2)
      EndIf   
   EndIf
EndIf            
If cTipo == "C"
   If ("&"$(cCampo))
      cCampo := StrTran(cCampo,"&","&Amp;")
   EndIf                    
   cCampo := AllTrim(cCampo)
   cCampo := Replicate(" ",nTamanho-Len(cCampo))+cCampo
EndIf
If cTipo == "D"
   cCampo := Subs(DtoS(cCampo),7,2)+"/"+Subs(DtoS(cCampo),5,2)+"/"+Subs(DtoS(cCampo),1,4)
EndIf

cCampo := Substr(cCampo,1,nTamanho) 

If lTagI .And. lTagF
   cXml := cTagI+cCampo+cTagF
ElseIf lTagI .And. !lTagF
   cXml := cTagI
ElseIf !lTagI .And. lTagF
   cXml := cTagF
EndIf

Return(cXML)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GerarApur ³ Autor ³Thiago Galvao Silveira ³ Data ³07.10.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera as Apuracoes necessarias de acordo com a periodicidade³±±	
±±³			 ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function GerarApur(cPeriod,cDet)
Local nMesApurI := 0
Local nMesApurF := 0
Local nAnoApur  := 0
Local nApur     := 1
Local nApurCtr  := 1
Local nArqApur  := 0
Local cArqApur  := "" 
Local nPeriod   := 0
Local aPerg     := GIAMT(2)
Local aCampIC   := {}          
Local aCampST   := {}          
Local cArqTrbIC := "" 
Local cArqTrbST := "" 
Local cApurIC   := ""
Local cApurST   := ""
Local cResumeF3 := ""
Local cResF3QEs := ""
Local cAliasIC  := "A"+StrZero(nApurCtr,2)
Local cAliasST  := "S"+StrZero(nApurCtr,2)
Local cLinha    := ""
Local nHandle
Local lRet      := .T.
Local dDtIni    := ""
Local dDtFin    := ""
Default cDet    := "N"

AADD(aCampIC,{"ApurICMS","C",8,0})               
AADD(aCampST,{"ApurST","C",6,0})               

cArqTrbIC := CriaTrab(aCampIC,.T.)           
cArqTrbST := CriaTrab(aCampST,.T.)           
dbUseArea(.T.,__LocalDriver,cArqTrbIC,"AIC",.T.,.F.)
dbUseArea(.T.,__LocalDriver,cArqTrbST,"AST",.T.,.F.)

	
nMesApurI := Val(Substr(DTOS(dDmaInc),5,2))
nMesApurF := Val(Substr(DTOS(dDmaFin),5,2))
nAnoApur  := Val(Substr(DTOS(dDmaInc),1,4))
nPeriod   := Val(aPerg[aScan(aPerg, {|x| x[1]=="008"})][2])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Numero de Apuracoes de acordo com a periodicidade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nPeriod == 1
   nApur := 1
   nMesApurI := nMesApurF
ElseIf nPeriod == 3
   If nMesApurI <= 6
      nApur     := 1 + nMesApurF - nMesApurI
      If nMesApurF >= 7 
         nApur     := 1 + nMesApurF - nMesApurI
      EndIf
   ElseIf nMesApurI >= 7
         nApur     := 1 + nMesApurF - nMesApurI
   EndIf   
ElseIf nPeriod == 2
   nApur     := 1 + nMesApurF - nMesApurI
EndIf

cResumeF3 := ResumeF3("IC",dDmainc,dDmaFin,"*",.F.,.T.,1,.F.,2,Nil,Nil,{},{},"",.T.,"RF3",.F.)
If cPeriod$"1"
   cResF3QEs := ResumeF3("IC",dDmainc,dDmaFin,"*",.F.,.T.,1,.F.,2,Nil,Nil,{},{},"",.T.,"TMP",.F.,.F.,.T.)
ElseIf cPeriod$"3"
   cResF3QEs := ResumeF3("IC",StoD(ALLTRIM(str(Year(ddmafin))+"0101")),StoD(ALLTRIM(str(Year(ddmafin))+"1231")),"*",.F.,.T.,1,.F.,2,Nil,Nil,{},{},"",.T.,"TMP",.F.,.F.,.T.)
Else
   cResF3QEs := ResumeF3("IC",StoD(ALLTRIM(str(Year(ddmafin)-1)+"0101")),StoD(ALLTRIM(str(Year(ddmafin)-1)+"1231")),"*",.F.,.T.,1,.F.,2,Nil,Nil,{},{},"",.T.,"TMP",.F.,.F.,.T.)
EndIf


While nApurCtr <= nApur
    cApurIC   := FisApur("IC",nAnoApur,nMesApurI,2,0,"*",.F.,{},1,.T.,"A"+strzero(nApurCtr,2),"")
    cApurST   := FisApur("ST",nAnoApur,nMesApurI,2,0,"*",.F.,{},1,.T.,"S"+strzero(nApurCtr,2),"")
    cAliasIC  := "A"+StrZero(nApurCtr,2)
    cAliasST  := "S"+StrZero(nApurCtr,2)
    nMesApurI +=1
    nArqApur  +=1
    nApurCtr  +=1
    DbSelectArea("AIC")
	RecLock("AIC",.T.)
	AIC->ApurICMS := cAliasIC
    MsUnlock()
	DbSelectArea("AST")
	RecLock("AST",.T.)
	AST->ApurST := cAliasST
    MsUnlock()	
EndDo
         
MontaV(cDet)

Return(lRet)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CodEst    ³ Autor ³Thiago Galvao Silveira ³ Data ³07.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o codigo do Estado especificado                    ³±±	
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function CodEst(cEstado)
Local  cCodEst   := 0
Local  nPos		:= 0
Local  aCodEst	:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados da Tabela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aCodEst,{"AC","01"})
AADD(aCodEst,{"AL","02"})
AADD(aCodEst,{"AM","03"})
AADD(aCodEst,{"AP","04"})
AADD(aCodEst,{"BA","05"})
AADD(aCodEst,{"CE","06"})
AADD(aCodEst,{"DF","07"})
AADD(aCodEst,{"ES","08"})
AADD(aCodEst,{"GO","10"})
AADD(aCodEst,{"EX","90"})
AADD(aCodEst,{"MA","12"})
AADD(aCodEst,{"MS","28"})
AADD(aCodEst,{"MT","13"})
AADD(aCodEst,{"MG","14"})
AADD(aCodEst,{"PA","15"})
AADD(aCodEst,{"PB","16"})
AADD(aCodEst,{"PR","17"})
AADD(aCodEst,{"PE","18"})
AADD(aCodEst,{"PI","19"})
AADD(aCodEst,{"RN","20"})
AADD(aCodEst,{"RS","21"})
AADD(aCodEst,{"RJ","22"})
AADD(aCodEst,{"RO","23"})
AADD(aCodEst,{"RR","24"})
AADD(aCodEst,{"SC","25"})
AADD(aCodEst,{"SP","26"})
AADD(aCodEst,{"SE","27"})
AADD(aCodEst,{"TO","29"})

nPos	:= Ascan(aCodEst,{|x|x[1]==cEstado})
cCodEst	:= aCodEst[nPos,2]
  
Return(cCodEst)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ValEst    ³ Autor ³Thiago Galvao Silveira ³ Data ³11.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Aglutina os Valores do SF3 por estado, quando a            ³±±	
±±³          ³ quando a periodicidade for semestral                       ³±±	
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function ValEst() 
Local nPosE    := 0
Local nEntr    := 0
Local nPosS    := 0
Local nSaid    := 0
Local nPosNC   := 0
Local nNCont   := 0
Local aResEnt  := {}
Local aResSd   := {}
Local aResNC   := {}
Local aTam     := {}
Local aCampos  := {}
Local cArqTrbE := ""
Local cArqTrbS := ""


DbSelectArea("TMP")
Dbgotop()

While !EOF()

      //Entradas
      
      If substr(CFOP,1,1)$"2/3" 
         nPosE := Ascan(aResEnt,{|x|x[1]==UF})
	     If nPosE==0
	        AADD(aResEnt,{UF,VALCONT,BASEICM,OUTRICM,ISENICM})
	        nEntr +=1
	     Else
   		    aResEnt[nPosE,1] :=UF
		    aResEnt[nPosE,2] +=VALCONT
		    aResEnt[nPosE,3] +=BASEICM
			aResEnt[nPosE,4] +=OUTRICM
            aResEnt[nPosE,5] +=ISENICM
         Endif
         
      //Saidas nao contribuinte 
      
      ElseIf substr(CFOP,1,1)$"6/7" .AND. AllTrim(CFOP)$"6107/6108/6258/6307/6357"
         nPosNC := Ascan(aResNC,{|x|x[1]==UF})
	     If nPosNC==0
	        AADD(aResNC,{UF,VALCONT,BASEICM})
	        nNCont +=1
	     Else
		    aResNC[nPosNC,1] :=UF
		    aResNC[nPosNC,2] +=VALCONT
		    aResNC[nPosNC,3] +=BASEICM
         Endif   
      
      //Saidas contribuinte   
         
      ElseIf substr(CFOP,1,1)$"6/7" .AND. !AllTrim(CFOP)$"6107/6108/6258/6307/6357"
         nPosS := Ascan(aResSd,{|x|x[1]==UF})
	     If nPosS==0
	        AADD(aResSd,{UF,VALCONT,BASEICM,OUTRICM,ISENICM})
	        nSaid +=1
	     Else
		    aResSd[nPosS,1] :=UF
		    aResSd[nPosS,2] +=VALCONT
		    aResSd[nPosS,3] +=BASEICM
			aResSd[nPosS,4] +=OUTRICM
            aResSd[nPosS,5] +=ISENICM
         Endif
      EndIf
      DbSkip()
EndDo

aTam  	:= TAMSX3("F3_ESTADO")
AADD(aCampos,{"UF"		,"C",aTam[1],aTam[2]})
aTam  	:= TAMSX3("F3_VALCONT")                               
AADD(aCampos,{"VLCONTC"	,"N",aTam[1],aTam[2]})                         
aTam  	:= TAMSX3("F3_VALCONT")                               
AADD(aCampos,{"VLCONTNC","N",aTam[1],aTam[2]})                         
aTam  	:= TAMSX3("F3_BASEICM")                               
AADD(aCampos,{"BSICMC"	,"N",aTam[1],aTam[2]})                
aTam  	:= TAMSX3("F3_BASEICM")                               
AADD(aCampos,{"BSICMNC"	,"N",aTam[1],aTam[2]})                         
aTam  	:= TAMSX3("F3_ISENICM")                               
AADD(aCampos,{"ISENICM"	,"N",aTam[1],aTam[2]})                         
aTam  	:= TAMSX3("F3_OUTRICM")                               
AADD(aCampos,{"OUTRICM"	,"N",aTam[1],aTam[2]})                         


cArqTrbE := CriaTrab(aCampos,.T.)           
cArqTrbS := CriaTrab(aCampos,.T.)           
dbUseArea(.T.,__LocalDriver,cArqTrbE,"AEN",.T.,.F.)
dbUseArea(.T.,__LocalDriver,cArqTrbS,"ASD",.T.,.F.)


nPosE :=1
While nPosE <= nEntr
    DbSelectArea("AEN") 
	RecLock("AEN",.T.)
	AEN->UF      := aResEnt[nPosE,1]
	AEN->VLCONTC := aResEnt[nPosE,2] 
	AEN->BSICMC  := aResEnt[nPosE,3] 
	AEN->OUTRICM := aResEnt[nPosE,4] 
	AEN->ISENICM := aResEnt[nPosE,5] 
	MsUnlock()
	nPosE +=1
EndDo

nPosS :=1
While nPosS <= nSaid
    DbSelectArea("ASD")
	nPosNC := Ascan(aResNC,{|x|x[1]==aResSd[nPosS,1]})	
    RecLock("ASD",.T.)
	ASD->UF      := aResSd[nPosS,1]
    ASD->VLCONTC := aResSd[nPosS,2] 
	ASD->BSICMC  := aResSd[nPosS,3] 
	ASD->OUTRICM := aResSd[nPosS,4] 
	ASD->ISENICM := aResSd[nPosS,5] 
	If nPosNC <> 0
	   ASD->VLCONTNC:= aResNC[nPosNC,2] 
	   ASD->BSICMNC := aResNC[nPosNC,3] 
	EndIF   
	MsUnlock()
    nPosS +=1
EndDo

nPosNC :=1
While nPosNC <= nNCont 
      DbSelectArea("ASD")
	  nPosS := Ascan(aResSd,{|x|x[1]==aResNC[nPosNC,1]})
	  If nPosS==0
	     RecLock("ASD",.T.)
	     ASD->UF      := aResNC[nPosNC,1]        
  	     ASD->VLCONTNC:= aResNC[nPosNC,2] 
	     ASD->BSICMNC := aResNC[nPosNC,3] 
   	     MsUnlock()
   	  EndIF 
nPosNC +=1
EndDo

Return() 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AglutVal  ³ Autor ³Thiago Galvao Silveira ³ Data ³11.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Aglutina os Valores de outros creditos conforme o Codigo,  ³±±	
±±³          ³ quando a periodicidade for semestral.                      ³±±	
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function AglutVal(cPeriod)
Local aOutros  := {}
Local nSelect  := 1
Local aResOut  := {}
Local aResOut2 := {}
Local nPos     := 0
Local nCont    := 0
Local nCont2   := 0
Local nApur    := 0
Local cMesRef  := ""

dbSelectArea("AIC")           
nApur := LastRec()

dbSelectArea("SM0")           
cCodFil:= SM0->M0_CODIGO
While nSelect<=nApur
      dbselectArea("A"+StrZero(nSelect,2))
      dbSeek(CCodFil)
      cMesRef := Substr((Alias())->DESCR,17,2)
      cCodigo :="006"
      dbSeek("006")
      dbSkip()
      While cCodigo==(Alias())->CODIGO .and. (Alias())->(!Eof())
            If cPeriod == "3"
               IF cMesRef<="06"
                  cMesRef:="06"
                  nPos := Ascan(aResOut,{|x|x[2]==(Alias())->SUBCOD})
	              If nPos==0
	                 AADD(aResOut,{cMesRef,(Alias())->SUBCOD,(Alias())->VALOR})
	                 nCont+=1
	              Else
  		             aResOut[nPos,1] :=cMesRef
   		             aResOut[nPos,2] :=(Alias())->SUBCOD
		             aResOut[nPos,3] +=(Alias())->VALOR
                  EndIf   
               Else
                  cMesRef:="12"
                  nPos := Ascan(aResOut2,{|x|x[2]==(Alias())->SUBCOD})
	              If nPos==0
	                 AADD(aResOut2,{cMesRef,(Alias())->SUBCOD,(Alias())->VALOR})
	                 nCont2+=1
	              Else
  		             aResOut2[nPos,1] :=cMesRef
   		             aResOut2[nPos,2] :=(Alias())->SUBCOD
		             aResOut2[nPos,3] +=(Alias())->VALOR
                  EndIf   
               EndIF   
            Else
                AADD(aResOut,{cMesRef,(Alias())->SUBCOD,(Alias())->VALOR})
                nCont+=1
            EndIf   
            (Alias())->(dbSkip())
      EndDo      
      dbSelectArea("AIC")
      nSelect +=1
EndDo

AADD(aOutros,{"MES","C",2,0})               
AADD(aOutros,{"CODOUTR","C",4,0})               
AADD(aOutros,{"VALOR","N",13,2})               
cArqTrb  := CriaTrab(aOutros,.T.)           
dbUseArea(.T.,__LocalDriver,cArqTrb,"OUT",.T.,.F.)


// Informacao Anual ou Mensal ou do 1 semestre

nPos := 1                 
While nPos <= nCont
      DbSelectArea("OUT")
	  RecLock("OUT",.T.)            
      OUT->MES     := aResOut[nPos,1]
      OUT->CODOUTR := aResOut[nPos,2]
	  OUT->VALOR   := aResOut[nPos,3]
	  MsUnlock()
	  nPos +=1
EndDo

// Informacao do 2 semestre

nPos := 1
While nPos <= nCont2
      DbSelectArea("OUT")
	  RecLock("OUT",.T.)            
      OUT->MES     := aResOut2[nPos,1]
      OUT->CODOUTR := aResOut2[nPos,2]
	  OUT->VALOR   := aResOut2[nPos,3]
	  MsUnlock()
	  nPos +=1
EndDo

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MontaV    ³ Autor ³Angelica N. Rabelo     ³ Data ³03.06.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera os valores das operacoes Isentas/Nao Tributadas para o³±±	
±±³			 ³ ANEXO V.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function MontaV(cDetalhe)

Local cAliasSF3 := ""
Local cDoc		:= ""
Local cSerie	:= ""
Local cCLi		:= ""
Local cLoj		:= ""
Local aCampAnV  := {}
Local cArqTrbANV:= ""
Local cIndANV   := ""

#IFDEF TOP
	Local cQuery    := ""	
	Local NX        := 0
	Local aStru     := {}
#ELSE
	Local cIndSF3   := ""
	Local cChave	:= ""
	Local cFiltro	:= ""	
#ENDIF

AADD(aCampAnV,{"Codigo","C",4,0})               
AADD(aCampAnV,{"Isent","N",14,2})   

cArqTrbANV := CriaTrab(aCampAnV,.T.)           
dbUseArea(.T.,__LocalDriver,cArqTrbANV,"ANV",.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Indice  do Arquivo de Trabalho.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndANV := CriaTrab(Nil, .F.)
IndRegua("ANV",cIndANV,"CODIGO",,,STR0010)  // "Criando indice do Arquivo de Trabalho"		
dbClearIndex()  	
dbSetIndex(cIndANV + OrdBagExt()) 

#IFDEF TOP
	lQuery := .T.
	cAliasSF3 := "RFF"
	aStru  	:= SF3->(dbStruct())
	cQuery 	:= "SELECT * "
	cQuery 	+= "FROM "+RetSqlName("SF3")+" "
	cQuery 	+= "WHERE F3_FILIAL='"+xFilial("SF3")+"' AND "
	cQuery 	+= "F3_ENTRADA>='"+Dtos(mv_par01)+"' AND "
	cQuery 	+= "F3_ENTRADA<='"+Dtos(mv_par02)+"' AND "                   
	cQuery 	+= "SUBSTRING(F3_CFO,1,1)>='5' AND "
	cQuery	+= "F3_DTCANC = '"+Dtos(Ctod(""))+"' AND "					  				
		
	cQuery += "F3_CODISS = '" + Space(TamSx3('F3_CODISS')[1]) + "' AND "
	cQuery += "F3_CNAE = '" + Space(TamSx3('F3_CNAE')[1]) + "' AND "
	cQuery += "F3_CODRSEF NOT IN ('102','110','301','302','303','304','305','306') AND "
		
	cQuery 	+= "D_E_L_E_T_ = ' ' "					
	cQuery 	+= "ORDER BY "+SqlOrder(SF3->(IndexKey()))		
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
		
	For nX := 1 To len(aStru)
		If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
			TcSetField(cAliasSF3,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX
	dbSelectArea(cAliasSF3)	
#ELSE             
	cAliasSF3 := "SF3"
	dbSelectArea(cAliasSF3)
	cIndSF3	:=	CriaTrab(NIL,.F.)
	cChave	:=	IndexKey()
	cFiltro	:=	"SF3->F3_FILIAL=='"+xFilial("SF3")+"' .And. DTOS(SF3->F3_ENTRADA)>='"+Dtos(mv_par01)+"' .AND. DTOS(SF3->F3_ENTRADA)<='"+Dtos(mv_par02)+"' .AND. SUBS(SF3->F3_CFO,1,1) >='5'"						
	cFiltro	+=  " .And. DTOS(SF3->F3_DTCANC)=='"+Dtos(Ctod(""))+"'"								
	
	cFiltro	+= " .And. SF3->F3_CODISS = '" + space(TamSx3("F3_CODISS")[1]) + "'"
	cFiltro += " .And. SF3->F3_CNAE = '" + Space(TamSx3('F3_CNAE')[1]) + "'"
	cFiltro += " .And. !(SF3->F3_CODRSEF $ '102/110/301/302/303/304/305/306') "
		
	IndRegua(cAliasSF3,cIndSF3,cChave,,cFiltro)
	(cAliasSF3)->(DbgoTop()) 
#ENDIF

IF cDetalhe=="N" .or. empty(cDetalhe)   // Vai totalizar ANEXO V com 1499

   While !Eof()
  	  GravANV("1499")
  	  dbSelectArea(cAliasSF3)	
      dbSkip()
   Enddo     
    			 
ELSE     // Vai totalizar as Isentas nos codigos informados em F4_CODDET
  
  	While !Eof()
	    dbSelectArea("SD2")
    	SD2->(DbSetOrder(3))
	    #IFDEF TOP
			SD2->(MsSeek(xFilial("SD2")+RFF->F3_NFISCAL+RFF->F3_SERIE+RFF->F3_CLIEFOR+RFF->F3_LOJA)) 
	    #ELSE
			SD2->(MsSeek(xFilial("SD2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)) 
		#ENDIF
	    
    	if !eof()
	
		    cDoc   := SD2->D2_DOC
		    cSerie := SD2->D2_SERIE
	    	cCli   := SD2->D2_CLIENTE
		    cLoj   := SD2->D2_LOJA
        
		    While cDoc==SD2->D2_DOC .and. cSerie==SD2->D2_SERIE .and. cCli==SD2->D2_CLIENTE .and. cLoj==SD2->D2_LOJA
			   dbSelectArea("SF4")
		       SF4->(DbSetOrder(1))
    		   dbSeek(xFilial("SF4")+SD2->D2_TES)		
	    	   
	    	   if !eof() .and. !empty(SF4->F4_CODDET)
		    	   GravANV(SF4->F4_CODDET)    
		       endif	   
     	       	        
    		   dbSelectArea("SD2")
		       dbSkip()    	
    		Enddo
    
	    Endif
    
    	#IFDEF TOP
		    dbSelectArea("RFF")
		#ELSE
			dbSelectArea(cAliasSF3)
		#ENDIF    
    	dbSkip()
    
	Enddo
  
ENDIF


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GRAVANV   ³ Autor ³Angelica N. Rabelo     ³ Data ³03.06.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava tabela ANV com os Cód.Detalhe/Valores Isentas/Nao    ³±±	
±±³			 ³ Tributadas.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function GravANV(cCod)

   dbSelectArea("ANV")
   dbSeek(cCod)

   if eof()        	            
	   RecLock("ANV",.T.)
   	   ANV->CODIGO := cCod
   	   
 	   #IFDEF TOP
          ANV->ISENT  := RFF->F3_ISENICM
	   #ELSE           
		  ANV->ISENT  := SF3->F3_ISENICM              
	   #ENDIF
   else
	   RecLock("ANV",.F.)
       #IFDEF TOP
	       ANV->ISENT  := ANV->ISENT+RFF->F3_ISENICM              				  	   
	   #ELSE 
		   ANV->ISENT  := ANV->ISENT+SF3->F3_ISENICM              
	   #ENDIF		
   endif	  
   msUnlock()
Return
