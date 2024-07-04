#INCLUDE "Protheus.ch"
#INCLUDE "Tmsa810.ch"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ TMSA810  ³ Autor ³ Robson Alves          ³ Data ³ 06.08.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao de novas pracas.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ³        ³      ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa810()

Local nOpca 	   := 0			// Variavel utilizada para definir a acao do programa.
Local aSays   	   := {}			// Array utilizado na descricao do objetivo do programa.
Local aButtons    := {}			// Array para definir os botoes da tela
Local cCadastro   := STR0002	// Titulo do programa( "Geracao de Novas Pracas" ). 
Local cPerg       := "TMA810"	// Grupo de perguntas.
Local cCdrDes     := ""			// Regiao Destino.
Local lVlrFrt     := .F.	// Busca Valores na Tabela de Frete.

Pergunte(cPerg, .F.) // Carrega o grupo de perguntas.

AADD(aSays, STR0003 ) //"Este programa tem como objetivo, gerar novas pracas de atendimento."

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:=1, FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	
FormBatch( cCadastro, aSays, aButtons)
	
If	nOpca == 1
	M->DT0_TABFRE   := MV_PAR01 // Variavel criada pela utilizacao no F3 do campo "DT0_TABTAR".
	M->DT0_TIPTAB   := MV_PAR02 // Variavel criada pela utilizacao no F3 do campo "DT0_TABTAR".
	cCdrDes         := MV_PAR03

	If MsgYesNo(OemToAnsi(STR0013) + " " + M->DT0_TABFRE + "/" + M->DT0_TIPTAB, OemToAnsi(STR0004))
		lVlrFrt := .T.
	EndIF
 	
	Processa( { |lEnd| Tmsa810Prc( lEnd, cCadastro, cCdrDes, lVlrFrt ) }, STR0004 ) //"Aguarde o processamento..."

EndIf	

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tmsa810Prc³ Autor ³ Robson Alves          ³ Data ³06.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua o processamento da rotina                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa810Prc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa810Prc( lEnd, cCadastro, cCdrDes, lVlrFrt )

Local cCond     := ""														// Variavel utilizada para montar a condicao na IndRegua().
Local aObjects  := {}														// Array utilizado para o posicionamento dos objetos.
Local aPosObj   := {}														// Array utilizado para o posicionamento dos objetos.
Local aSize     := MsAdvSize()											// Array utilizado para o posicionamento da tela.
Local aInfo     := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}	// Array utilizado para o posicionamento da tela.
Local nOpcA 	 := 0  														// Variavel utilizada para definir a acao do programa.
Local oDlg	      															// Objeto da GetDados e Dialog.
Local nExcMin   := 0
Local nValMin   := 0
Local cContPar  := ""
Local aMV_CdrOri:= {}
Local aSM0      := FWLoadSM0()
Local nCnt      := 0
Local aArea     := GetArea()

Default lVlrFrt := .F.

Private aHeader := {},oGetD												// Array utilizado na GetDados.
Private aCols   := {}														// Array utilizado na GetDados.
Private aRotina := {}														// Array utilizado na GetDados.

If Empty(MV_PAR04)
	cCadastro += " - " + M->DT0_TABFRE + "/" + M->DT0_TIPTAB + STR0012
Else
	DT3->(DbSetOrder(1))
	DT3->(MsSeek(xFilial("DT3")+MV_PAR04))
	cCadastro += " - " + M->DT0_TABFRE + "/" + M->DT0_TIPTAB + STR0005 + MV_PAR04 + "-" + DT3->DT3_DESCRI
EndIf

/* aRotina definido por ser obrigatorio na utilizacao da GetDados. */
aRotina :={	{ STR0006, "Axpesqui", 0, 1},; //"Pesquisar"
				{ STR0007, "AxVisual", 0, 2},; //"Visualizar"
				{ STR0008, "AxInclui", 0, 3},; //"Incluir"
				{ STR0009, "AxAltera", 0, 4} } //"Alterar"

aTam := TamSX3( "DVA_FILIAL" )
Aadd(aHeader,{RetTitle("DVA_FILIAL"),"DVA_FILIAL"	,PesqPict("DVA","DVA_FILIAL",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DVA"," "})
aTam := TamSX3( "DVA_CDRORI" )
Aadd(aHeader,{RetTitle("DVA_CDRORI"),"DVA_CDRORI"	,PesqPict("DVA","DVA_CDRORI",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DVA"," "})
aTam := TamSX3( "DVA_REGORI" )
Aadd(aHeader,{RetTitle("DVA_REGORI"),"DVA_REGORI"	,PesqPict("DVA","DVA_REGORI",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DVA"," "})
aTam := TamSX3( "DVA_CDRDES")	
Aadd(aHeader,{RetTitle("DVA_CDRDES"),"DVA_CDRDES"	,PesqPict("DVA","DVA_CDRDES" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DVA"," "})
aTam := TamSX3( "DVA_REGDES" )
Aadd(aHeader,{RetTitle("DVA_REGDES"),"DVA_REGDES"	,PesqPict("DVA","DVA_REGDES",aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DVA"," "})
If Empty(MV_PAR04)
	aTam := TamSX3( "DVA_KM" )	
	Aadd(aHeader,{RetTitle("DVA_KM"),"DVA_KM"	,PesqPict("DVA","DVA_KM" ,aTam[1]),aTam[1],aTam[2],"",USADO, "N" ,"DVA"," "})
	aTam := TamSX3( "DTK_EXCMIN" )	
	Aadd(aHeader,{RetTitle("DTK_EXCMIN"),"DTK_EXCMIN"	,PesqPict("DTK","DTK_EXCMIN" ,aTam[1]),aTam[1],aTam[2],"",USADO, "N" ,"DTK"," "})
	aTam := TamSX3( "DT0_TABTAR" )	
	Aadd(aHeader,{RetTitle("DT0_TABTAR"),"DT0_TABTAR"	,PesqPict("DT0","DT0_TABTAR" ,aTam[1]),aTam[1],aTam[2],"Tmsa810Vld()",USADO, "C" ,"DT0"," "})
	aTam := TamSX3( "DTF_KMDE" )	
	Aadd(aHeader,{RetTitle("DTF_KMDE"),"DTF_KMDE"	,PesqPict("DTF","DTF_KMDE" ,aTam[1]),aTam[1],aTam[2],"",USADO, "N" ,"DTF"," "})
	aTam := TamSX3( "DTF_KMATE" )	
	Aadd(aHeader,{RetTitle("DTF_KMATE"),"DTF_KMATE"	,PesqPict("DTF","DTF_KMATE" ,aTam[1]),aTam[1],aTam[2],"",USADO, "N" ,"DTF"," "})
Else
	aTam := TamSX3("DT1_VALOR")
	Aadd(aHeader,{RetTitle("DT1_VALOR") ,"DT1_VALOR" ,PesqPict("DT1","DT1_VALOR" ,aTam[1]),aTam[1],aTam[2],"",USADO, "N" ,"DT1"," "})
	aTam := TamSX3("DT1_INTERV")
	Aadd(aHeader,{RetTitle("DT1_INTERV"),"DT1_INTERV",PesqPict("DT1","DT1_INTERV",aTam[1]),aTam[1],aTam[2],"",USADO, "N" ,"DT1"," "})
	aTam := TamSX3("DTK_EXCMIN")
	Aadd(aHeader,{RetTitle("DTK_EXCMIN"),"DTK_EXCMIN",PesqPict("DTK","DTK_EXCMIN",aTam[1]),aTam[1],aTam[2],"",USADO, "N" ,"DTK"," "})
	aTam := TamSX3("DTK_VALMIN")
	Aadd(aHeader,{RetTitle("DTK_VALMIN"),"DTK_VALMIN",PesqPict("DTK","DTK_VALMIN",aTam[1]),aTam[1],aTam[2],"",USADO, "N" ,"DTK"," "})
EndIf

/* Obtem todas as Regioes de Origem configuradas. */
For nCnt := 1 To Len(aSM0)
	If aSM0[nCnt][1] == cEmpAnt
		cContPar := SuperGetMV("MV_CDRORI", .F.,"",aSM0[nCnt][2])
		
		If !Empty(cContPar) .And. Ascan( aMV_CdrOri, { |x| x[1]+x[2] == aSM0[nCnt][2] + cContPar } )  == 0
			aAdd(aMV_CdrOri, {aSM0[nCnt][2], cContPar} )
		EndIf
		
	EndIf
Next

//--- Caso nao encontrar o parametro por Filial, pesquisar o parametro com a Filial em Branco
If Len(aMV_CdrOri) == 0
	aAdd(aMV_CdrOri, (Space(TamSx3("DTK_FILIAL")[1]), SuperGetMV("MV_CDRORI", .F.,"")) )
EndIf


ProcRegua( Len(aMV_CdrOri) )
DT0->(dbSetOrder(1))
DT1->(dbSetOrder(1))

For nCnt:= 1 To Len(aMV_CdrOri)
	nExcMin   := 0
	nValMin   := 0

	If (lVlrFrt == .T.)
		If Empty(MV_PAR04)
			If DTK->(MsSeek(xFilial("DTK")+MV_PAR01+MV_PAR02+Left(aMV_CdrOri[nCnt][2],Len(DVA->DVA_CDRORI))+MV_PAR03))
				nExcMin   := DTK->DTK_EXCMIN
				nValMin   := DTK->DTK_VALMIN
			ElseIf DTK->(MsSeek(xFilial("DTK")+MV_PAR01+MV_PAR02))
				nExcMin   := DTK->DTK_EXCMIN
				nValMin   := DTK->DTK_VALMIN
			EndIf
		Else
			If DTK->(MsSeek(xFilial("DTK")+MV_PAR01+MV_PAR02+Left(aMV_CdrOri[nCnt][2],Len(DVA->DVA_CDRORI))+MV_PAR03+Space(Len(DT1->DT1_CODPRO))+MV_PAR04))
				nExcMin   := DTK->DTK_EXCMIN
				nValMin   := DTK->DTK_VALMIN
			ElseIf DTK->(MsSeek(xFilial("DTK")+MV_PAR01+MV_PAR02))
				nExcMin   := DTK->DTK_EXCMIN
				nValMin   := DTK->DTK_VALMIN
			EndIf
		EndIf
	EndIf

	If Empty(MV_PAR04)
		If DT0->(!MsSeek(xFilial("DT0")+MV_PAR01+MV_PAR02+Left(aMV_CdrOri[nCnt][2],Len(DVA->DVA_CDRORI))+MV_PAR03))
			Aadd(aCols,{aMV_CdrOri[nCnt][1], ;
							Left(aMV_CdrOri[nCnt][2],Len(DVA->DVA_CDRORI)), ;
							Posicione("DUY",1,xFilial("DUY")+Left(aMV_CdrOri[nCnt][2],Len(DVA->DVA_CDRORI)),"DUY_DESCRI"), ;
							MV_PAR03, ;
							Posicione("DUY",1,xFilial("DUY")+MV_PAR03,"DUY_DESCRI"), ;
							Posicione("DVA",1,xFilial("DVA")+Left(aMV_CdrOri[nCnt][2],Len(DVA->DVA_CDRORI))+MV_PAR04,"DVA_KM"), ;
							0, ;
							Space(Len(DT0->DT0_TABTAR)), ;
							nExcMin, ;
							nValMin, ;
							.F.})
		EndIf
	Else
		If DT1->(!MsSeek(xFilial("DT1")+MV_PAR01+MV_PAR02+Left(aMV_CdrOri[nCnt][2],Len(DVA->DVA_CDRORI))+MV_PAR03+Space(Len(DT1->DT1_CODPRO))+MV_PAR04))
			Aadd(aCols,{aMV_CdrOri[nCnt][1], ;
							Left(aMV_CdrOri[nCnt][2],Len(DVA->DVA_CDRORI)), ;
							Posicione("DUY",1,xFilial("DUY")+Left(aMV_CdrOri[nCnt][2],Len(DVA->DVA_CDRORI)),"DUY_DESCRI"), ;
							MV_PAR03, ;
							Posicione("DUY",1,xFilial("DUY")+MV_PAR03,"DUY_DESCRI"), ;
							0, ;
							0, ;
							nExcMin, ;
							nValMin, ;
							.F.})
		EndIf
	EndIf
Next

If !Empty( aCols )
	Aadd( aObjects, { 100, 100, .T., .T., .F. } )
	aPosObj := MsObjSize( aInfo, aObjects )
	DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]
		oGetD := MSGetDados():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],4,"TMSA810LOk","TMSA810TOk",,.T.,,,,Len( aCols ))
		If Empty(MV_PAR04)
			oGetD:oBrowse:aAlter := { "DT0_TABTAR", "DTK_EXCMIN"}
			oGetD:oBrowse:bEditcol := { || !Empty( GdFieldGet("DTO_TABTAR") ) .And. oGetD:LinhaOk(),(oGetD:oBrowse:GoDown(),oGetD:oBrowse:nColPos := GdFieldPos("DT0_TABTAR") ) ,Nil}
		Else
			oGetD:oBrowse:aAlter := {"DT1_VALOR","DT1_INTERV","DTK_EXCMIN","DTK_VALMIN"}
		EndIf
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| IIF(oGetD:TudoOk(),(nOpcA:=1,oDlg:End()),)},{||oDlg:End()}))		
	
	If nOpcA == 1
		Begin Transaction
			Processa( { |lEnd| Tmsa810Grv() }, STR0010 ) //"Aguarde a gravacao..."
		End Transaction
	EndIf
Else	
	Help(" ", 1, "JAGRAVADO") //"Ja existe registro com esta informacao"
EndIf	

RestArea(aArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA810LOk   ³ Autor ³ Robson Alves          ³ Data ³07.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia da linha digitada.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA810LOk()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Logico                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA070                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA810LOk(nLinha)

Local lRet     := .T.	// Retorno da funcao.

Return( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA810TOk   ³ Autor ³ Robson Alves          ³ Data ³07.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia final.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA810TOk()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Logico                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA810                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA810TOk()

Local lRet := .T.	// Retorno da funcao.
Local nA   := 0	// Contador do For.

For nA := 1 To Len( aCols )
	lRet := TMSA810LOk( nA )
	If !lRet
		Exit
	EndIf
Next nA 

Return( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA810Vld   ³ Autor ³ Robson Alves          ³ Data ³07.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de campo.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA810Vld()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Logico                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA810                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA810Vld()

Local lRet

lRet := ExistCpo( "DTF", M->DT0_TABFRE + M->DT0_TIPTAB + M->DT0_TABTAR )
If lRet
	GDFieldPut( "DTF_KMDE" , Posicione( "DTF", 1, xFilial("DTF") + M->DT0_TABFRE + M->DT0_TIPTAB + M->DT0_TABTAR, "DTF_KMDE" ), n )
	GDFieldPut( "DTF_KMATE", Posicione( "DTF", 1, xFilial("DTF") + M->DT0_TABFRE + M->DT0_TIPTAB + M->DT0_TABTAR, "DTF_KMATE" ), n )
EndIf

Return( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA810Chk   ³ Autor ³ Valdemar Roberto      ³ Data ³04.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de componente.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA810Chk()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Logico                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA810                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA810Chk()

Local lRet

If !Empty(MV_PAR04)
	lRet := Vazio() .Or. ExistCpo('DT3',MV_PAR04)
	If lRet
		DVE->(DbSetOrder(2))
		If DVE->(!MsSeek(xFilial('DVE')+MV_PAR04+MV_PAR01+MV_PAR02))
			lRet := .F.
			Help("",1,"TMSA81001") //"Este Componente nao pertence ao layout da tabela utilizada"
		EndIf
	EndIf
Endif

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA810SX1   ³ Autor ³ Robson Alves          ³ Data ³07.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de parametros( SX1 ).                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA810Vld()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Logico                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA810                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA810SX1()
Return( ExistCpo( "SX5", "M5" + MV_PAR02 ) .And. ExistCpo( "DTL", MV_PAR01 + MV_PAR02 ) )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tmsa810Grv³ Autor ³ Robson Alves          ³ Data ³06.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava as tabelas de tarifas.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa810Grv()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa810Grv()

Local nA        := 0 						// Contador no For.
Local nB        := 0							// Contador no For.
Local bCampo    := {|x| FieldName(x) }	// Bloco para retornar o nome do campo. 
Local lRec
Local lProcessa := .T.
Local cValAte   := ""
Local cFatPes   := ""
Local aConfig   := {}
Local lSubFaixa := FindFunction("ALIASINDIC") .And. AliasInDic("DW1")

aConfig := TamSX3("DT1_VALATE")
cValAte := Replicate("9",(aConfig[1] - aConfig[2] - 1)) + "." + Replicate("9",aConfig[2])
aConfig := TamSX3("DT1_FATPES")
cFatPes := Replicate("9",(aConfig[1] - aConfig[2] - 1)) + "." + Replicate("9",aConfig[2])

Begin Transaction
	
ProcRegua(Len(aCols))
DT0->(DbSetOrder(1))
DT1->(DbSetOrder(1))
DTK->(DbSetOrder(1))
For nA := 1 To Len (aCols)
	IncProc()
	If Empty(MV_PAR04)
		lProcessa := !Empty(GdFieldGet("DT0_TABTAR",nA))
	Else
		lProcessa := !Empty(GdFieldGet("DT1_VALOR",nA))
	EndIf
	If !(GdDeleted(nA)) .And. lProcessa
		If DT0->(!MsSeek(xFilial("DT0")+MV_PAR01+MV_PAR02+GdFieldGet("DVA_CDRORI",nA)+GdFieldGet("DVA_CDRDES",nA)))
			/* Efetua a gravacao da tabela de frete .*/
			RecLock( "DT0", .T.)
			DT0->DT0_FILIAL := xFilial("DT0")
			DT0->DT0_TABFRE := MV_PAR01
			DT0->DT0_TIPTAB := MV_PAR02
			DT0->DT0_CDRORI := GdFieldGet( "DVA_CDRORI", nA )
			DT0->DT0_CDRDES := GdFieldGet( "DVA_CDRDES", nA )
			If Empty(MV_PAR04)
				DT0->DT0_TABTAR := GdFieldGet( "DT0_TABTAR", nA )
			Else
				DT0->DT0_TABTAR := Space(Len(DT0->DT0_TABTAR))
			EndIf
			DT0->DT0_CATTAB := Posicione("DTL",1,xFilial("DTL")+M->DT0_TABFRE+M->DT0_TIPTAB,"DTL_CATTAB")
			MsUnLock()
		EndIf			
	EndIf
	If !(GdDeleted(nA)) .And. !Empty(MV_PAR04)
		/* Efetua a gravacao nos itens da tabela de frete .*/
		lRec := DT1->(!MsSeek(xFilial("DT1")+MV_PAR01+MV_PAR02+GdFieldGet("DVA_CDRORI",nA)+GdFieldGet("DVA_CDRDES",nA)+Space(Len(DT1->DT1_CODPRO))+MV_PAR04))
		RecLock( "DT1", lRec)
		DT1->DT1_FILIAL := xFilial("DT1")
		DT1->DT1_TABFRE := MV_PAR01
		DT1->DT1_TIPTAB := MV_PAR02
		DT1->DT1_CDRORI := GdFieldGet( "DVA_CDRORI", nA )
		DT1->DT1_CDRDES := GdFieldGet( "DVA_CDRDES", nA )
		DT1->DT1_CODPAS := MV_PAR04
		DT1->DT1_ITEM   := StrZero(1,Len(DT1->DT1_ITEM))
		DT1->DT1_VALATE := Val(cValAte)
		DT1->DT1_FATPES := Val(cFatPes)
		DT1->DT1_VALOR  := GdFieldGet( "DT1_VALOR" , nA )
		DT1->DT1_INTERV := GdFieldGet( "DT1_INTERV", nA )
		DT1->DT1_TARIFA := StrZero(2,Len(DT1->DT1_TARIFA))
		MsUnLock()
		/* Efetua a gravacao no complemento da tabela de frete .*/
		If GdFieldGet( "DTK_VALMIN", nA ) <> 0
			lRec := DTK->(!MsSeek(xFilial("DTK")+MV_PAR01+MV_PAR02+GdFieldGet("DVA_CDRORI",nA)+GdFieldGet("DVA_CDRDES",nA)+Space(Len(DT1->DT1_CODPRO))+MV_PAR04))
			RecLock( "DTK", lRec)
			DTK->DTK_FILIAL := xFilial("DT1")
			DTK->DTK_TABFRE := MV_PAR01
			DTK->DTK_TIPTAB := MV_PAR02
			DTK->DTK_CDRORI := GdFieldGet( "DVA_CDRORI", nA )
			DTK->DTK_CDRDES := GdFieldGet( "DVA_CDRDES", nA )
			DTK->DTK_CODPAS := MV_PAR04
			DTK->DTK_EXCMIN := GdFieldGet( "DTK_EXCMIN", nA )
			DTK->DTK_VALMIN := GdFieldGet( "DTK_VALMIN", nA )
			MsUnLock()
		EndIf
		/* Efetua a gravacao nos sub-faxias dos itens da tabela de frete .*/
		If lSubFaixa
			lRec := DW1->(!MsSeek(xFilial("DW1")+MV_PAR01+MV_PAR02+GdFieldGet("DVA_CDRORI",nA)+GdFieldGet("DVA_CDRDES",nA)+Space(Len(DW1->DW1_CODPRO))+MV_PAR04+StrZero(1,Len(DW1->DW1_ITEM))))
			RecLock( "DW1", lRec)
			DW1->DW1_FILIAL := xFilial("DW1")
			DW1->DW1_TABFRE := MV_PAR01
			DW1->DW1_TIPTAB := MV_PAR02
			DW1->DW1_CDRORI := GdFieldGet( "DVA_CDRORI", nA )
			DW1->DW1_CDRDES := GdFieldGet( "DVA_CDRDES", nA )
			DW1->DW1_CODPAS := MV_PAR04
			DW1->DW1_ITEDT1 := StrZero(1,Len(DW1->DW1_ITEDT1))
			DW1->DW1_ITEM   := StrZero(1,Len(DW1->DW1_ITEM))
			DW1->DW1_VALATE := Val(cValAte)
			DW1->DW1_FATPES := Val(cFatPes)
			DW1->DW1_VALOR  := GdFieldGet( "DT1_VALOR" , nA )
			DW1->DW1_INTERV := GdFieldGet( "DT1_INTERV", nA )
			MsUnLock()
		EndIf
	EndIf
Next nA

End Transaction

Return Nil
