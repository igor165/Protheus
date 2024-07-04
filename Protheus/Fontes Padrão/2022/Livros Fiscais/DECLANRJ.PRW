#INCLUDE "DECLANRJ.CH"
#Include "Protheus.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³sfDiaDsCfp³ Autor ³Gustavo G. Rueda       ³ Data ³27.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta arquivo CFP com parametros a serem utilizados no      ³±±
±±³          ³DIADS.INI                                                   ³±±
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
Function DeclanRj (cCfpDeclan)
	Local 	cValid 		:= ""
	Local 	nI	 		:= 1
	Local 	nOpcA	 	:= 2
	Local 	lRet	 	:= .T.
	Local 	oDlgGet
	Local	cBarra		:=	""
	Local	cTitJan		:=	""
	Local	lAutomato	:= iif(IsBlind(),.T.,.F.)
    //
	Private	aSel		:= {}
	Private aListBox	:= {}
	Private	aMsg	  	:= {}
	Private	aValid	  	:= {}
	Private	aConteudo 	:= {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preenchimento QUADRO F³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd (aListBox, Upper (OemToAnsi (STR0001)))		; aAdd (aSel, .F.); aAdd (aMsg, "")				 ; 	aAdd (aValid, "") //"Quadro F - Receita Bruta - Estabelecimento."
	aAdd (aListBox, Replicate ("-", Len (STR0001)*1.6)); aAdd (aSel, .F.); aAdd (aMsg, "")				 ; 	aAdd (aValid, "")
	aAdd (aListBox, "")									; aAdd (aSel, .F.); aAdd (aMsg, "")				 ; 	aAdd (aValid, "")
	aAdd (aListBox, Upper (OemToAnsi (STR0002)))		; aAdd (aSel, .F.); aAdd (aMsg, "")				 ; 	aAdd (aValid, "") //"Receita Bruta Total"
	aAdd (aListBox, "")									; aAdd (aSel, .F.); aAdd (aMsg, "")				 ; 	aAdd (aValid, "")
	aAdd (aListBox, OemToAnsi (STR0003))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0003)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')")	//"0001 - Janeiro"
	aAdd (aListBox, OemToAnsi (STR0004))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0004)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") //"0002 - Fevereiro"
	aAdd (aListBox, OemToAnsi (STR0005))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0005)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") //"0003 - Marco"
	aAdd (aListBox, OemToAnsi (STR0006))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0006)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") //"0004 - Abril"
	aAdd (aListBox, OemToAnsi (STR0007))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0007)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") //"0005 - Maio"
	aAdd (aListBox, OemToAnsi (STR0008))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0008)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") //"0006 - Junho"	
	aAdd (aListBox, OemToAnsi (STR0009))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0009)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") //"0007 - Julho"
	aAdd (aListBox, OemToAnsi (STR0010))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0010)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") //"0008 - Agosto"
	aAdd (aListBox, OemToAnsi (STR0011))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0011)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") //"0009 - Setembro"
	aAdd (aListBox, OemToAnsi (STR0012))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0012)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") //"0010 - Outubro"
	aAdd (aListBox, OemToAnsi (STR0013))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0013)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") //"0011 - Novembro"
	aAdd (aListBox, OemToAnsi (STR0014))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0014)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") //"0012 - Dezembro"
	aAdd (aListBox, "") 	  	 						; aAdd (aSel, .F.); aAdd (aMsg, "")                 ;		aAdd (aValid, "")
	//
	aAdd (aListBox, Upper (OemToAnsi (STR0015)))		; aAdd (aSel, .F.); aAdd (aMsg, "")				  ; 	aAdd (aValid, "") //"Vendas de Mercadorias Sujeitas a Substituicao Tributaria"
	aAdd (aListBox, "")									; aAdd (aSel, .F.); aAdd (aMsg, "")				  ; 	aAdd (aValid, "")
	aAdd (aListBox, OemToAnsi (STR0020))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0020)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0013 - Janeiro"
	aAdd (aListBox, OemToAnsi (STR0021))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0021)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0014 - Fevereiro"
	aAdd (aListBox, OemToAnsi (STR0022))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0022)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0015 - Marco"
	aAdd (aListBox, OemToAnsi (STR0023))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0023)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0016 - Abril"
	aAdd (aListBox, OemToAnsi (STR0024))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0024)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0017 - Maio"
	aAdd (aListBox, OemToAnsi (STR0025))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0025)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0018 - Junho"	
	aAdd (aListBox, OemToAnsi (STR0026))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0026)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0019 - Julho"
	aAdd (aListBox, OemToAnsi (STR0027))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0027)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0020 - Agosto"
	aAdd (aListBox, OemToAnsi (STR0028))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0028)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0021 - Setembro"
	aAdd (aListBox, OemToAnsi (STR0029))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0029)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0022 - Outubro"
	aAdd (aListBox, OemToAnsi (STR0030))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0030)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0023 - Novembro"
	aAdd (aListBox, OemToAnsi (STR0031))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0031)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0024 - Dezembro"
	aAdd (aListBox, "") 	  	 						; aAdd (aSel, .F.); aAdd (aMsg, "")                ;	aAdd (aValid, "")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preenchimento do QUADRO G³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd (aListBox, Upper (OemToAnsi (STR0016)))		; aAdd (aSel, .F.); aAdd (aMsg, "")				 ; 	aAdd (aValid, "") //"Quadro G - Receita Bruta - Empresa."
	aAdd (aListBox, Replicate ("-", Len (STR0016)*1.6)); aAdd (aSel, .F.); aAdd (aMsg, "")				 ; 	aAdd (aValid, "")
	aAdd (aListBox, "")									; aAdd (aSel, .F.); aAdd (aMsg, "")				 ; 	aAdd (aValid, "")
	aAdd (aListBox, Upper (OemToAnsi (STR0002)))		; aAdd (aSel, .F.); aAdd (aMsg, "")				 ; 	aAdd (aValid, "") //"Receita Bruta Total"
	aAdd (aListBox, "")									; aAdd (aSel, .F.); aAdd (aMsg, "")				 ; 	aAdd (aValid, "")
	aAdd (aListBox, OemToAnsi (STR0032))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0032)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0025 - Janeiro"
	aAdd (aListBox, OemToAnsi (STR0033))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0033)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0026 - Fevereiro"
	aAdd (aListBox, OemToAnsi (STR0034))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0034)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0027 - Marco"
	aAdd (aListBox, OemToAnsi (STR0035))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0035)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0028 - Abril"
	aAdd (aListBox, OemToAnsi (STR0036))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0036)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0029 - Maio"
	aAdd (aListBox, OemToAnsi (STR0037))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0037)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0030 - Junho"	
	aAdd (aListBox, OemToAnsi (STR0038))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0038)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0031 - Julho"
	aAdd (aListBox, OemToAnsi (STR0039))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0039)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0032 - Agosto"
	aAdd (aListBox, OemToAnsi (STR0040))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0040)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0033 - Setembro"
	aAdd (aListBox, OemToAnsi (STR0041))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0041)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0034 - Outubro"
	aAdd (aListBox, OemToAnsi (STR0042))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0042)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0035 - Novembro"
	aAdd (aListBox, OemToAnsi (STR0043))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0043)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0036 - Dezembro"
	aAdd (aListBox, "") 	  	 						; aAdd (aSel, .F.); aAdd (aMsg, "")                 ;		aAdd (aValid, "")
	//
	aAdd (aListBox, Upper (OemToAnsi (STR0015)))		; aAdd (aSel, .F.); aAdd (aMsg, "")				  ; 	aAdd (aValid, "") //"Vendas de Mercadorias Sujeitas a Substituicao Tributaria"
	aAdd (aListBox, "")									; aAdd (aSel, .F.); aAdd (aMsg, "")				  ; 	aAdd (aValid, "")
	aAdd (aListBox, OemToAnsi (STR0044))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0044)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0037 - Janeiro"
	aAdd (aListBox, OemToAnsi (STR0045))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0045)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0038 - Fevereiro"
	aAdd (aListBox, OemToAnsi (STR0046))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0046)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0039 - Marco"
	aAdd (aListBox, OemToAnsi (STR0047))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0047)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0040 - Abril"
	aAdd (aListBox, OemToAnsi (STR0048))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0048)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0041 - Maio"
	aAdd (aListBox, OemToAnsi (STR0049))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0049)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0042 - Junho"	
	aAdd (aListBox, OemToAnsi (STR0050))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0050)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0043 - Julho"
	aAdd (aListBox, OemToAnsi (STR0051))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0051)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0044 - Agosto"
	aAdd (aListBox, OemToAnsi (STR0052))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0052)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0045 - Setembro"
	aAdd (aListBox, OemToAnsi (STR0053))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0053)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0046 - Outubro"
	aAdd (aListBox, OemToAnsi (STR0054))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0054)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0047 - Novembro"
	aAdd (aListBox, OemToAnsi (STR0055))				; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi(STR0055)); 	aAdd (aValid, "VldCfp ('N', 'VALOR')") 	//"0048 - Dezembro"
	aAdd (aListBox, "") 	  	 						; aAdd (aSel, .F.); aAdd (aMsg, "")                ;	aAdd (aValid, "")
	//
	For nI := 1 To (Len (aListBox))
		aListBox [nI]	:=	OemToAnsi (aListBox [nI])
		aMsg [nI]		:=	OemToAnsi (aMsg [nI])
	Next (nI)                
	//
	Load (cCfpDeclan)
	//
	cBarra	:=	STR0017	//"Parametros adicionais da DECLAN - RJ."	
	cTitJan	:=	STR0017	//"DECLAN - RJ."
	
	if !lAutomato
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
	endif

	If (nOpcA==1) .or. lAutomato
		GravaIt (cCfpDeclan)
	Endif
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³sfLoad    ³ Autor ³Gustavo G. Rueda       ³ Data ³27.08.2003³±±
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
	Local aTotMes := {}
    //
 	CalcRB(_aTotal[006],_aTotal[007],0,,@aTotMes) // Retorna Receita Bruta e Subst.Tributaria
	//	
	If (File (ArqIni))
		For nI := 1 To (Len (aListBox))
			cConteudo	:=	""
			If (IsDigit (SubStr (aListBox[nI], 2, 4)))
				cConteudo	:=	Ler (ArqIni, Substr(aListBox[nI],2,4))
				If Substr(aListBox[nI],1,4)=="0001" // Janeiro Rec.Bruta
					cConteudo := Transform(aTotMes[1][1],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0002" // Fevereiro Rec.Bruta
					cConteudo := Transform(aTotMes[2][1],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0003" //Marco Rec.Bruta
					cConteudo := Transform(aTotMes[3][1],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0004"  //Abril Rec.Bruta
					cConteudo := Transform(aTotMes[4][1],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0005"  //Maio Rec.Bruta
					cConteudo := Transform(aTotMes[5][1],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0006"  //Junho Rec.Bruta
					cConteudo := Transform(aTotMes[6][1],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0007"  //Julho Rec.Bruta
					cConteudo := Transform(aTotMes[7][1],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0008"  //Agosto Rec.Bruta
					cConteudo := Transform(aTotMes[8][1],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0009"  //Setembro Rec.Bruta
					cConteudo := Transform(aTotMes[9][1],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0010" //Outubro Rec.Bruta
					cConteudo := Transform(aTotMes[10][1],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0011" //Novembro Rec.Bruta
					cConteudo := Transform(aTotMes[11][1],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0012" // Dezembro Rec.Bruta
					cConteudo := Transform(aTotMes[12][1],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0013" // Janeiro Subst.Tributaria
					cConteudo := Transform(aTotMes[1][2],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0014" // Fevereiro Subst.Tributaria
					cConteudo := Transform(aTotMes[2][2],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0015" // Marco Subst.Tributaria
					cConteudo := Transform(aTotMes[3][2],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0016" // Abril Subst.Tributaria
					cConteudo := Transform(aTotMes[4][2],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0017" // Maio Subst.Tributaria
					cConteudo := Transform(aTotMes[5][2],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0018" // Junho Subst.Tributaria
					cConteudo := Transform(aTotMes[6][2],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0019" // Julho Subst.Tributaria
					cConteudo := Transform(aTotMes[7][2],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0020" // Agosto Subst.Tributaria
					cConteudo := Transform(aTotMes[8][2],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0021" // Setembro Subst.Tributaria
					cConteudo := Transform(aTotMes[9][2],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0022" // Outubro Subst.Tributaria
					cConteudo := Transform(aTotMes[10][2],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0023" // Novembro Subst.Tributaria
					cConteudo := Transform(aTotMes[11][2],"@E 999999999999.99")
				Elseif Substr(aListBox[nI],1,4)=="0024" // Dezembro Subst.Tributaria
					cConteudo := Transform(aTotMes[12][2],"@E 999999999999.99")
				Else
					cConteudo	:=	Ler (ArqIni, Substr (aListBox[nI], 2, 4))
				Endif
				If (Len (cConteudo)<254)
					cConteudo	:=	cConteudo+Space (254-Len (cConteudo))
				EndIf
			Endif
			aAdd (aConteudo, cConteudo)
		Next
	Else
		For nI := 1 To (Len (aListBox))
			If nI==6
				AADD(aConteudo,Transform(aTotMes[1][1],"@E 999999999999.99")) // Janeiro Rec.Bruta
			Elseif nI==7
				AADD(aConteudo,Transform(aTotMes[2][1],"@E 999999999999.99")) // Fevereiro Rec.Bruta
			Elseif nI==8
				AADD(aConteudo,Transform(aTotMes[3][1],"@E 999999999999.99")) // Marco Rec.Bruta
			Elseif nI==9
				AADD(aConteudo,Transform(aTotMes[4][1],"@E 999999999999.99")) // Abril Rec.Bruta
			Elseif nI==10
				AADD(aConteudo,Transform(aTotMes[5][1],"@E 999999999999.99")) // Maio Rec.Bruta
			Elseif nI==11
				AADD(aConteudo,Transform(aTotMes[6][1],"@E 999999999999.99")) // Junho Rec.Bruta
			Elseif nI==12
				AADD(aConteudo,Transform(aTotMes[7][1],"@E 999999999999.99")) // Julho Rec.Bruta
			Elseif nI==13
				AADD(aConteudo,Transform(aTotMes[8][1],"@E 999999999999.99")) // Agosto Rec.Bruta
			Elseif nI==14
				AADD(aConteudo,Transform(aTotMes[9][1],"@E 999999999999.99")) // Setembro Rec.Bruta
			Elseif nI==15
				AADD(aConteudo,Transform(aTotMes[10][1],"@E 999999999999.99")) // Outubro Rec.Bruta
			Elseif nI==16
				AADD(aConteudo,Transform(aTotMes[11][1],"@E 999999999999.99")) // Novembro Rec.Bruta
			Elseif nI==17
				AADD(aConteudo,Transform(aTotMes[12][1],"@E 999999999999.99")) // Dezembro Rec.Bruta
			Elseif nI==21
				AADD(aConteudo,Transform(aTotMes[1][2],"@E 999999999999.99")) // Janeiro Subst.Tributaria
			Elseif nI==22
				AADD(aConteudo,Transform(aTotMes[2][2],"@E 999999999999.99")) // Fevereiro Subst.Tributaria
			Elseif nI==23
				AADD(aConteudo,Transform(aTotMes[3][2],"@E 999999999999.99")) // Marco Subst.Tributaria
			Elseif nI==24
				AADD(aConteudo,Transform(aTotMes[4][2],"@E 999999999999.99")) // Abril Subst.Tributaria
			Elseif nI==25
				AADD(aConteudo,Transform(aTotMes[5][2],"@E 999999999999.99")) // Maio Subst.Tributaria
			Elseif nI==26
				AADD(aConteudo,Transform(aTotMes[6][2],"@E 999999999999.99")) // Junho Subst.Tributaria
			Elseif nI==27
				AADD(aConteudo,Transform(aTotMes[7][2],"@E 999999999999.99")) // Julho Subst.Tributaria
			Elseif nI==28
				AADD(aConteudo,Transform(aTotMes[8][2],"@E 999999999999.99")) // Agosto Subst.Tributaria
			Elseif nI==29
				AADD(aConteudo,Transform(aTotMes[9][2],"@E 999999999999.99")) // Setembro Subst.Tributaria
			Elseif nI==30
				AADD(aConteudo,Transform(aTotMes[10][2],"@E 999999999999.99")) // Outubro Subst.Tributaria
			Elseif nI==31
				AADD(aConteudo,Transform(aTotMes[11][2],"@E 999999999999.99")) // Novembro Subst.Tributaria
			Elseif nI==32
				AADD(aConteudo,Transform(aTotMes[12][2],"@E 999999999999.99")) // Dezembro Subst.Tributaria
			Else
				aAdd (aConteudo, Space (254))
            Endif
		Next
	Endif
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³sfGravaIt ³ Autor ³Gustavo G. Rueda       ³ Data ³27.08.2003³±±
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
±±³Programa  ³sfList    ³ Autor ³Gustavo G. Rueda       ³ Data ³27.08.2003³±±
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
		@ 15, 24 MSGet &cCampo Picture "@!" Valid Eval (bValid) Size 210, 08 Of oDlgGet2 Pixel
		//
		Define SButton From 032, 182 Type 1 Action (lUpdated:=.t.,oDlgGet2:End ()) Enable Of oDlgGet2
		Define SButton From 032, 210 Type 2 Action (lUpdated:=.f.,oDlgGet2:End ()) Enable Of oDlgGet2
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
±±³Programa  ³sfLer     ³ Autor ³Gustavo G. Rueda       ³ Data ³27.08.2003³±±
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
		Help (" ",1, cArqIni)
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
±±³Programa  ³sfVldCfp  ³ Autor ³Gustavo G. Rueda       ³ Data ³27.08.2003³±±
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
Static Function VldCfp (cTipo, cCampo)
	Local	lRet		:=	.T.
	Local	cConteudo	:=	&(ReadVar())
	Local	nI			:=	0
	Local	nPonto		:=	0
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
		For nI := 1 To (Len (cConteudo))
		 	If SubStr (cConteudo, nI, 1)$".," .And. nPonto==0
		 		nPonto++
		 	Else
				If !(Isdigit (SubStr (cConteudo, nI, 1)))
					Help (" ", 1, "NUMERICO",,STR0019, 3, 0)	//"Somente devera ser informado numeros nesta posicao. Formato: 999999999999.99"
					lRet	:=	.F.
					Exit
				Endif
			EndIf
		Next
	Elseif (cTipo=="RB")  // Receita Bruta --> RB
		Help (" ", 1, "NODISP",,STR0056, 3, 0)
			lRet :=	.F.
	Else // Substituicao Tributaria -->SB
		Help (" ", 1, "NODISP",,STR0057, 3, 0)
			lRet :=	.F. 
	EndIf
	//
	If (cCampo=="VALOR")
		If (Len (AllTrim (cConteudo))>15)
			Help (" ", 1, "VALOR",,STR0019, 3, 0)	//"Permitido no maximo 15 caracteres, sendo os dois ultimos as decimais.. Formato: 999999999999.99"
			lRet	:=	.F.
		Endif
	EndIf	
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³sfLeCfp   ³ Autor ³Gustavo G. Rueda       ³ Data ³27.08.2003³±±
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
Function LeCfp (cArquivo)
	Local	cConteudo	:=	MemoRead (cArquivo)
	Local	nLinhas		:= MlCount (cConteudo, 254)
	Local	nI			:=	0
	Local	aRet		:=	{}
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
±±³Programa  ³Declanc   ³ Autor ³Cecilia Carvalho       ³ Data ³12.06.2012³±±
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
Function LeDeclanc ()
Local cConteudo	 :=	""
Local cConcatena := ""        
Local cAuxFil    := ""
Local cParam     := "MV_DECLAN1/MV_DECLAN2/MV_DECLAN3/MV_DECLAN4/MV_DECLAN5/MV_DECLAN6/MV_DECLAN7/MV_DECLAN8/MV_DECLAN9/"
Local lAchou     := .F.                                        


DbSelectArea ("SX6")
SX6->(DbSeek (xFilial ("SX6")+"MV_DECLANC"))
If xFilial ("SX6")==SX6->X6_FIL .And. "MV_DECLANC"$SX6->X6_VAR
    cAuxFil := SX6->X6_FIL
    lAchou := .T.     
Else
    SX6->(DbSeek (Space(FWSizeFilial())+"MV_DECLANC"))
    If SX6->X6_FIL==Space(FWSizeFilial()) .And. "MV_DECLANC"$SX6->X6_VAR
        cAuxFil := Replicate(" ",FWSizeFilial())
        lAchou := .T.
    EndIf
EndIf
If lAchou
    cConcatena	:=	AllTrim (SX6->X6_CONTEUD)
	If !Empty (cConcatena)
		If SubStr (cConteudo, Len (cConteudo), 1)$"\/#*"
			If SubStr (cConcatena, 1, 1)$"\/#*"
				cConteudo	+=	SubStr (cConcatena, 2)
			Else
				cConteudo	+=	cConcatena
			EndIf
		Else
			If SubStr (cConcatena, 1, 1)$"\/#*"
				cConteudo	+=	cConcatena
			Else
				cConteudo	+=	"/"+cConcatena
			EndIf
		EndIf
	EndIf
              
    SX6->(DbSeek (cAuxfil+"MV_DECLAN1"))
	Do While !SX6->(Eof ()) .And. cAuxFil==SX6->X6_FIL .And. Alltrim(SX6->X6_VAR)$cParam
		cConcatena	:=	AllTrim (SX6->X6_CONTEUD)
		If !Empty (cConcatena)
			If SubStr (cConteudo, Len (cConteudo), 1)$"\/#*"
				If SubStr (cConcatena, 1, 1)$"\/#*"
					cConteudo	+=	SubStr (cConcatena, 2)
				Else
					cConteudo	+=	cConcatena
				EndIf
			Else
				If SubStr (cConcatena, 1, 1)$"\/#*"
					cConteudo	+=	cConcatena
				Else
					cConteudo	+=	"/"+cConcatena
				EndIf
			EndIf
		EndIf
		SX6->(DbSkip ())
	EndDo
EndIf
Return (cConteudo)


//-------------------------------------------------------------------
/*/{Protheus.doc} GrTRBDec
@Autor Desconhecido

>>Rebranch<<
@Matheus Massarotto
@since 23/10/2019
@version 12.1.25

Preenche o temporário TRB com a informação de código de município, código da distribuição e valor.
Para o registro 0400 da Declan/RJ
/*/
//-------------------------------------------------------------------
Function GrTRBDec(lAltera,lSaida)
Local lIntTms	:= GetNewPar("MV_INTTMS",.F.)
Local lFound	:= .F.
Local nLocMun	:= 0
Local nLocDis	:= 0
Local aAreaDT6
Local aAreaSA1
Local aAreaDT5	
Local aAreaDUE
Local aAreaDUL
Local cA1Mun	:= 'SA1->(FieldGet (SA1->(FieldPos(&(SuperGetMv ("MV_DECMUN"))[1]))))' //Campo do SA1 baseado no parâmetro posição [1] que contem código do municipio
Local cA1Dis	:= 'SA1->(FieldGet (SA1->(FieldPos(&(SuperGetMv ("MV_DECMUN"))[3]))))' //Campo do SA1 baseado no parâmetro posição [3] que contem código da distribuição
Local cA2Mun	:= 'SA2->(FieldGet (SA2->(FieldPos(&(SuperGetMv ("MV_DECMUN"))[2]))))' //Campo do SA2 baseado no parâmetro posição [2] que contem código do municipio
Local cA2Dis	:= 'SA2->(FieldGet (SA2->(FieldPos(&(SuperGetMv ("MV_DECMUN"))[4]))))' //Campo do SA2 baseado no parâmetro posição [4] que contem código da distribuição
Local lDevolucao:= iif(SF3->F3_TIPO$"DB",.T.,.F.)
Local lDUESol   := iif(DUE->(FieldPos("DUE_CODSOL")) > 0,.T.,.F.)
Local lAchou	:= .F.
Local lParamOK	:= iif(Type(SuperGetMv ("MV_DECMUN",""))=="A" .and. Len(&(SuperGetMv ("MV_DECMUN")))>=4,.T.,.F.) //Existe um array no parâmetro MV_DECMUN e contém mais de 4 posições

Default lAltera := .F. 
Default lSaida 	:= iif( Val(Left(AllTrim (SF3->F3_CFO),1))>=5,.T.,.F.) 

DbSelectArea("DT6")
DT6->(dbSetOrder(1))
if lIntTms .And. (DT6->(MsSeek(xFilial("DT6")+SF3->F3_FILIAL+SF3->F3_NFISCAL+SF3->F3_SERIE))) //Se possuir integração com TMS
 
 	DbSelectArea("DTC")
	DTC->(DbSetOrder(3))
	If DT6->DT6_DOCTMS <> (StrZero(8,Len(DT6->DT6_DOCTMS)))
		/*
			Tipos de Documentos TMS
			-----------------------
			6 - CTRC Devolucao
			7 - CTRC Reentrega
			8 - CTRC Complemento
			9 - CTRC Retorno
			P - CTRC Subustituição
			M - CTRC Anulação

			Os Tipos de Documentos "6|7|8|9|P|M|", não estão relacionados com um registro da tabela DTC, para encontrar o DTC, 
			o processo abaixo busca o DT6 original para poder posicionar no DTC correspondente.					
		*/
		If ( DT6->DT6_DOCTMS $ "6|7|8|9|P|M|" )
			aAreaDT6 := GetArea("DT6")
			DT6->(MsSeek (xFilial ("DT6")+DT6->DT6_FILDOC+DT6->DT6_DOCDCO+DT6->DT6_SERIE))
			lFound:= DTC->(MsSeek (xFilial ("DTC")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
			RestArea(aAreaDT6)
		Else
			lFound:= DTC->(MsSeek (xFilial ("DTC")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
		EndIf
	Else	// CTRC COMPLEMENTAR
		lFound:= DTC->(MsSeek (xFilial ("DTC")+DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO))
	EndIf
	
	If lFound 
		/*Quanto o inicio do Frete for na Transportadora*/
		If DTC->DTC_SELORI == "1"
			
			nLocMun:= iif(type("MV_PAR20")<>"U",MV_PAR20,0)
			nLocDis:= iif(type("MV_PAR31")<>"U",MV_PAR31,0)
		
		/*Quanto o inicio do Frete for no Cliente*/
		ElseIf DTC->DTC_SELORI == "2" .and. lParamOK
			
			aAreaSA1 := GetArea("SA1")
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			if SA1->(MsSeek(xFilial("SA1")+DT6->(DT6_CLIREM+DT6_LOJREM)))
				nLocMun := &(cA1Mun)
				nLocDis := &(cA1Dis)
			endif
			RestArea(aAreaSA1)

		/*Origem e Local de Coleta*/
		ElseIf DTC->DTC_SELORI == "3" .and. lParamOK
			If !Empty(DTC->DTC_NUMSOL)
				
				/*Posiciona na Ordem de Coleta*/
				aAreaDT5 := GetArea("DT5")
				DbSelectArea("DT5")
				DT5->(DbSetOrder(1))
				If DT5->(MsSeek(xFilial("DT5")+DTC->DTC_FILORI+DTC->DTC_NUMSOL))
					
					/*Verifica se o Solicitante tem Sequencias de Endereco*/
					If Empty(DT5->DT5_SEQEND)
						aAreaDUE := GetArea("DUE")
						DbSelectArea("DUE")
						DUE->(dbSetOrder(1))
						If !lDUESol
							lAchou := DUE->(MsSeek(xFilial("DUE")+DT5->(DT5_DDD+DT5_TEL)))
						Else
							lAchou := DUE->(MsSeek(xFilial("DUE")+DT5->DT5_CODSOL))
						EndIf
						
						if lAchou
							aAreaSA1 := GetArea("SA1")
							DbSelectArea("SA1")
							SA1->(DbSetOrder(1))
							if SA1->(MsSeek(xFilial("SA1")+DUE->(DUE_CODCLI+DUE_LOJCLI)))
								nLocMun := &(cA1Mun)
								nLocDis := &(cA1Dis)
							endif
							RestArea(aAreaSA1)
						endif
						lAchou := .F.
						RestArea(aAreaDUE)
					Else
						aAreaDUL := GetArea("DUL")
						If !lDUESol
							DbSelectArea("DUL")
							DUL->(dbSetOrder(1))
							lAchou := DUL->(MsSeek(xFilial("DUL")+DT5->(DT5_DDD+DT5_TEL+DT5_SEQEND)))
						Else
							DUL->(dbSetOrder(3))
							lAchou := DUL->(MsSeek(xFilial("DUL")+DT5->(DT5_CODSOL+DT5_SEQEND)))
						EndIf
						
						if lAchou
							aAreaSA1 := GetArea("SA1")
							DbSelectArea("SA1")
							SA1->(DbSetOrder(1))
							if SA1->(MsSeek(xFilial("SA1")+DUL->(DUL_CODCLI+DUL_LOJCLI)))
								nLocMun := &(cA1Mun)
								nLocDis := &(cA1Dis)
							endif
							RestArea(aAreaSA1)
						endif
						lAchou := .F.
						RestArea(aAreaDUL)
					EndIf
				EndIf
				
				RestArea(aAreaDT5)
			
			EndIf
		EndIf
	EndIf

Else

	if lParamOK
		if !lDevolucao
			nLocMun := &(cA1Mun)
			nLocDis := &(cA1Dis)
		else
			nLocMun := &(cA2Mun)
			nLocDis := &(cA2Dis)
		endif
	endif

endif

if !empty(nLocMun) //Código do município

	if valtype(nLocMun)=="C"
		nLocMun := val(nLocMun)
	endif
	
	if valtype(nLocDis)=="C"
		nLocDis := val(nLocDis)
	endif

	lAltera := TRB->(MsSeek (nLocMun))

	If lAltera
		RecLock ("TRB", .F.)
		If lSaida
			TRB->VALOR += SF3->F3_VALCONT
		Else
			TRB->VALOR += Iif(!lDevolucao, SF3->F3_VALCONT, 0 )
		Endif	
		MsUnLock()
	Else 	
		RecLock ("TRB", .T.)

			TRB->CODMUN := nLocMun
			TRB->CODDIS := nLocDis

			If lSaida 
				TRB->VALOR := SF3->F3_VALCONT
			Else
				TRB->VALOR += Iif(!lDevolucao, SF3->F3_VALCONT, 0 )
			Endif
		MsUnLock ()
	Endif
	
endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DECLANX1
@Autor Desconhecido

@Matheus Massarotto
@since 07/08/2020
@version 12.1.27

Verifico se determinado parâmetro do X1(pergunte) existe.
Declan/RJ
/*/
//-------------------------------------------------------------------
Function DECLANX1(cPerg,cParam)
Local oFwSX1Util
Local aPergunte	:= {}
Local lRet		:= .T.
Local nPos		:= 1
Local oError    := ErrorBlock({|e| Conout("ERRO na função DECLANX1: " +e:Description +"- Filial " + FWGETCODFILIAL + " " + Time()+ "ERRORSTACK:"	+ Chr(10)+Chr(13) + e:ErrorStack , lRet:=.F.)})

Default cPerg	:= ""
Default cParam	:= ""

	if GetRPORelease() < "12.1.030"

		Begin Sequence
			//Garanto que estarão sem espaço e maisculo
			cParam	:= alltrim(UPPER(cParam))
			cPerg	:= alltrim(UPPER(cPerg))

			//pego a posição do parametro que se deseja verificar
			nPos:= val(right(cParam,2))

			//Classe que retorna os campos do SX1 (Perguntas) cadastrados para o ID passado
			oFwSX1Util:= FwSX1Util():New()
			oFwSX1Util:AddGroup(cPerg)
			oFwSX1Util:SearchGroup()
			aPergunte:= oFwSX1Util:GetGroup(cPerg)

			//Verifico se o parâmetro existe
			if !(len(aPergunte)>1 .and. len(aPergunte[2])>(nPos-1) .and. Upper(AllTrim(aPergunte[2][nPos]:CX1_VAR01)) == cParam)
				lRet:=.F.
			endif
			
		End Sequence

		//Limpo o array e limpo o objeto
		FwFreeArray(aPergunte)
		oFwSX1Util:= Nil

		//Tratamento para caso de erro apresentar a msg com conout.
		ErrorBlock(oError)

	endif

Return (lRet)