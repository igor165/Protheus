#INCLUDE "LOJR060.CH"

#include "PROTHEUS.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Lojr060	³ Autor ³ Vendas e Clientes 	³ Data ³ 27.12.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao de Cartas										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lojr060(void)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lojr060()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis 										     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local CbTxt
Local oTexto, oDlgCarta
Local oGrava, oApaga
LOCAL aCarta:={}
Local Titulo := STR0001 // Emissao de Cartas para Mala Direta
Local cDesc1 := STR0002 // Este programa ir  imprimir as Cartas para Mala Direta selecionadas
Local cDesc2 := STR0003 // de acordo com o numero de copias solicitadas.Para imprimir uma carta
Local cDesc3 := STR0004 // para cada registro do arquivo, coloque um campo deste arquivo.
Local aArea := {Alias(),IndexOrd(),Recno()} // salva a situacao atual
Local cString:="SA1"

Private nHdlt:=0
// Zebrado / Administracao
Private aReturn 	:= { STR0005, 1, STR0006, 2, 2, 1, "",1 }
Private nomeprog	:="LOJR060"
Private aLinha  	:= { } ,cNomeArq:=Space(8)
Private cPerg	 	:="LJR060"
Private wnrel	 	:="LOJR060"
Private lGrava		:=.F.
Private nCria		:=0
Private cTexto
Private nArqPrin	:=1
Private nArq     	:= 0
Private nColunas 	:= 70
Private Limite      := 220		//Limite para impressao
Private cTamanho    := "G"		// Tamanho do relatorio

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt 	:= SPACE(10)
cbcont	:= 0
li 		:= 80
m_pag 	:= 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros   ³
//³ mv_par01	  // Do Codigo 			  ?³
//³ mv_par02	  // Ate' o Codigo        ?³
//³ mv_par03	  // Quantas Copias		  ?³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array de bancos e tabela de campos 					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aMLD:=Directory("*.MLD")
AEval(aMLD,{|x| Aadd(aCarta,PadR(Upper(Substr(x[1],1,At(".",x[1])-1)),8)) })
Aadd(aCarta,STR0007)                   // Novo
If Len(aCarta) == 1
	cNomeArq:="SEM_NOME.MLD"
	 // Verifica Qual Arquivo ir  ser utilizado
	nArqPrin := SelArqMala() //Seleciona o Arquivo a Imprimir Cliente/Fornec.
	If nArqPrin == 0
		Return .F.
	EndIf
Else
	SetArquivo(aCarta)  //escolha cartas gravadas em disco retorna nArq
	If nArq==0
		Return .F.
	Endif
	If nArq==Len(aCarta)  //Novo
		cNomeArq:="SEM_NOME.MLD"
		 // Verifica Qual Arquivo ser  utilizado
		nArqPrin := SelArqMala() //Seleciona o Arquivo a Imprimir Cliente/Fornec.
		If nArqPrin == 0
			Return .F.
		EndIf
	Else
		cNomeArq:=Trim(aCarta[nArq])+".MLD"
		nHdlt :=FOPEN(cNomeArq,2)
		cTexto:=SPACE(FSEEK(nHdlt,0,2))
		FSEEK(nHdlt,0,0)
		FREAD(nHdlt,@cTexto,LEN(cTexto))
		nArqPrin := IIf(At("#A1_",upper(cTexto))>0,1,2)
      FCLOSE(nHdlt)
	Endif
EndIf

	// Edi‡„o de Cartas para Mala Direta
	DEFINE MSDIALOG oDlgCarta FROM 39,85 TO 370,640 TITLE;
	OemToAnsi(STR0008) PIXEL OF oMainWnd
	// Texto
	@	15, 10 TO 165, 221 LABEL STR0009 OF oDlgCarta PIXEL
	If nArqPrin == 1
		cPerg  :="LJR060"
		Pergunte("LJR060",.F.)
		cString:="SA1"
		DbSelectArea("SA1")
	ElseIf nArqPrin == 2  //Fornecedores
		cPerg  :="LJR061"
		Pergunte("LJR061",.F.)
		cString:="SA2"
		DbSelectArea("SA2")
	EndIf
	@ 25, 15 GET oTexto VAR cTexto SIZE 200, 135 OF oDlgCarta MEMO PIXEL
	@	4, 10 SAY STR0010 SIZE 48,7 OF oDlgCarta PIXEL // Nome Arquivo:
	@	3, 55 MSGET oNome VAR cNomeArq OF oDlgCarta PIXEL
	DEFINE SBUTTON FROM 18,235 TYPE 6 ENABLE OF oDlgCarta;
	  ACTION ( TesteImp(cDesc1,cDesc2,cDesc3,Titulo,cString))
	DEFINE SBUTTON FROM 32,235 TYPE 2 ENABLE OF oDlgCarta;
		ACTION ( oDlgCarta:End() )
	DEFINE SBUTTON oGrava FROM 47, 235 TYPE 13 ENABLE OF oDlgCarta;
		ACTION ( lGrava := .T., R060_Arq(cNomeArq) )
	DEFINE SBUTTON oApaga FROM 62, 235 TYPE 3 ENABLE OF oDlgCarta;
		ACTION ( lGrava := .F., R060_Arq(cNomeArq) , lGrava := .T. )
	ACTIVATE MSDIALOG oDlgCarta CENTERED

dbSelectArea(aArea[1]) // Restaura a situacao anterior
dbSetOrder(aArea[2])
dbGoto(aArea[3])
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³TesteImp	³ Autor ³ Aline Correa do Vale  ³ Data ³ 20/10/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Manda a carta para controle de impressao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³TesteImp()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TesteImp(cDesc1,cDesc2,cDesc3,Titulo,cString)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTexto == ""
	Return
EndIf
SetPrint( cString , wnrel , cPerg , Titulo ,;
		  cDesc1  , cDesc2, cDesc3, .F.	   ,;
		  ""	  , .F.   , cTamanho		)
		  
If nLastkey = 27
	Return
Endif

//-- Paisagem
nColunas := iif( aReturn[04] == 2, 122, 70 )

RptStatus({|lEnd| ImpCarta(@lEnd,wnRel,cString)},Titulo)
Return Nil

/* Fun‡„o que exibe tela de sele‡„o de arquivo a imprimir
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Carta 	³ Autor ³ Aline Correa do Vale  ³ Data ³ 13.10.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Escolha do arquivo para impressao da carta (mala direta)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ SelArqMala                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SelArqMala(nArqPrin)

Local oDlgArq
Local oList
Local aArqs   :={}
Local nList   := 0
DEFAULT nArqPrin := 0 

// Arquivos
DEFINE MSDIALOG oDlgArq FROM 1,10 TO 100,200 TITLE ;
	OemToAnsi(STR0011) PIXEL OF oMainWnd
Aadd(aArqs, STR0012)  // Cliente
Aadd(aArqs, STR0013)  // Fornecedor
// Ajustes de Tela para Protheus
@	3, 5 TO 50, 65 OF oDlgArq PIXEL
@ 13, 10 LISTBOX oList VAR nList ITEMS aArqs SIZE 45,30 OF oDlgArq PIXEL
DEFINE SBUTTON FROM	6,68 TYPE 1 ENABLE OF oDlgArq;
	ACTION ( nArqPrin := nList, oDlgArq:End() )
DEFINE SBUTTON FROM 19,68 TYPE 2 ENABLE OF oDlgArq;
	ACTION ( nArqPrin := 0, oDlgArq:End() )
ACTIVATE MSDIALOG oDlgArq CENTERED
Return (nArqPrin)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ ImpCarta ³ Autor ³ Antonio Maniero Jr.   ³ Data ³ 27.12.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impress„o da Carta escolhida                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ImpCarta(Texto,Linha Inicial,Lin. Final,Coluna Inicial,Tipo³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpCarta(lEnd,wnrel,cString)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis 														  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local j
Local i
Local nColIni 	:= 5
Local cAcentos	:="€ú‡úŽúú…ú†ú úúˆúŠú‚ú¡ú“ú”ú•ú¢ú£ú"
Local cAcSubst	:="C,c,A~A'a`a~a'E'e^e`e'i'o^o~o`o'U'"
Local cImpCar 	:=""
Local nLin		:=5
Local cLine2
Local cTexto2
Local cFimLinha
Local cLine
Local nTotLin       					// Numero total de linhas
Local lTemMacro	:=.F.					// Verifica se existe macro execucao
Local nReg 								// Numero do registro
Local wFilial 							// Filial correspondente ao Arquivo
Local nEspLin	:= 4					// Tamanho do espaco entre as linhas

Private cCod
Private cLoja
Private nCop:=1

SetDefault(aReturn,cString)

lTemMacro:=VerArquivo(cTexto)
dbSelectArea( cString )
SetRegua(Reccount())
dbSeek( xFilial() + mv_par01 , .T.)

If nLastkey==27
	Return .F.
EndIf

wFilial := IIF(nArqPrin==1,A1_FILIAL,A2_FILIAL)
While !Eof()
	IncRegua()	// implementa regua
	If xFilial( cString) != wFilial
		Exit
	EndIf

	nReg := RecNo( )
	cCod := IIF(nArqPrin==1,A1_COD,A2_COD)
	cLoja:= IIF(nArqPrin==1,A1_LOJA,A2_LOJA)
	nCop := 1

	If nArqPrin == 1
		cCond := 'A1_COD + A1_LOJA == cCod + cLoja .and. nCop <= mv_par03 ' + ;
				'.and. A1_COD >="'+ mv_par01 +'" .and. A1_COD <= "' + mv_par02 +'"'
	Else
		cCond := 'A2_COD + A2_LOJA == cCod + cLoja .and. nCop <= mv_par03 ' +;
				'.and. A2_COD >="'+ mv_par01 +'" .and. A2_COD <= "' + mv_par02 +'"'
	EndIf
    
	nLin	+= nEspLin         					// Espacamento entre cada registro impresso
	
	While !Eof() .and. &cCond

		nCop++
		cImpLin:=""
		For j:=1 TO LEN(cTexto)
			cImpCar:=SubStr(cTexto,j,1)
			If cImpCar==Chr(9)
				cImpCar:="    "
			EndIf
			If cImpCar=="#"
				cImpCar:=LR060Form(Substr(cTexto,j+1,At("#",Substr(cTexto,j+1))-1),cString)
				If Valtype(cImpCar) != "C"
					ourspool(wnrel)           		// Libera impressao antes de sair da rotina
					Return .F.
				EndIf
				j+=At("#",Substr(cTexto,j+1))
			EndIf
			cImpLin+=cImpCar
		Next j
		cLine2:=cImpLin								// Quebra a linha de acordo com o numero de colunas
		cImpLin:=""
		nTotLin:=Len(cLine2)/nColunas
		For i:=1 To nTotLin
			cLine:=Substr(cLine2,1,nColunas)
			cFimLinha:=Substr(cLine2,nColunas,2)
			cLine2:=Substr(cLine2,nColunas +1 ) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento no final da linha para verificar    ³
			//³se tem alguma palavra que ira aparecer quebrada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If " " $ cFimLinha .or. Chr(141) $ cFimLinha .or. Chr(10) $ cFimLinha .or. Chr(13) $ cFimLinha
				cImpLin+=cLine
			Else
				cImpLin+=Substr(cLine,1,Rat(" ",cLine))
				cLine2:=Substr(cLine,Rat(" ",cLine)+1)+cLine2
			EndIf
		Next i
		cTexto2:=cImpLin+cLine2
		For i:=1 To MLCOUNT(cTexto2,nColunas)
			cLine:=MEMOLINE(cTexto2,nColunas,i)
			cImpLin:=""
			For j:=1 TO LEN(cLine)
				cImpCar:=SubStr(cLine,j,1)
				If AT(cImpCar,cAcentos)>0
					cImpCar:=SubStr(cAcSubst,AT(cImpCar,cAcentos),1)+CHR(8)+SUBSTR(cAcSubSt,AT(cImpCar,cAcentos)+1,1)
					If Valtype(cImpCar) != "C"
						ourspool(wnrel)				// Libera impressao antes de sair da rotina
						Return .F.
					EndIf
				EndIf
				cImpLin:=cImpLin+cImpCar
			Next j
			@nLin++,nColIni PSay cImpLin
		Next i
	EndDo
	dbSelectArea( cString )
	dbGoto( nReg )
	dbSkip( )
EndDo

If !lGrava .and. nCria==1
	FErase(cNomeArq)
EndIf

If aReturn[5] = 1
   Set Printer TO 
   dbCommitAll()
   ourspool(wnrel)
Endif

FCLOSE(nHdlt)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³SetArquivo³ Autor ³ Jorge Queiroz         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona o Arquivo a Consultar                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SetArquivo(aBancos, oDlgCarta)
Local oDlgArqs, oList

If aBancos != Nil
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a tela de Bancos de Dados 									  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nArq := 1
	// Arquivos Prontos
	DEFINE MSDIALOG oDlgArqs FROM 1,10 TO 100,167 TITLE;
	OemToAnsi(STR0013) OF oDlgCarta PIXEL
	@ 5,5 LISTBOX oList VAR nArq ITEMS aBANCOS PIXEL
	DEFINE SBUTTON FROM	5, 50 TYPE 1 ENABLE OF oDlgArqs;
		ACTION ( oDlgArqs:End() )
	DEFINE SBUTTON FROM 18, 50 TYPE 2 ENABLE OF oDlgArqs;
		ACTION ( nArq := 0 ,oDlgArqs:End() )

	ACTIVATE MSDIALOG oDlgArqs CENTERED
EndIf

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³LR060Form ³ Autor ³ Antonio Maniero Jr.   ³ Data ³ 28/12/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina verificadora da formula digitada                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³Expc1 - cForm   " Nome do Campo que sera substuido     "    ³±±
±±³			 ³Expc2 - cString " Nome do Alias do relatorio SA1 / SA2 "    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³LOJR060                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LR060Form( cForm ,cString )

Local xResult
Local bBlock:=ErrorBlock()

Private lRet:=.T.

DEFAULT cString := "   "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso do usuario digitar um campo     ³
//³diferente do  relatorio escolhido	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SubStr(cForm,1,2) <> SubStr(cString,2,3) 
	MsgAlert(STR0019 + cForm + STR0020+	;   			//O campo ## nao existe na tabela
	IIf(cString=="SA1", STR0012 , STR0013)	+ STR0021)	//Verifique se os dois primeiros carcteres do campo correspondem a os da tabela
	lRet:=.F.
EndIf	

If lRet
	BEGIN SEQUENCE
		xResult := &cForm
		If Valtype(xResult) == "N"
			xResult:=Val(xResult)
		ElseIf Valtype(xResult) == "L"
			xResult:=IIF(xResult=="x",.T.,.F.)
		ElseIf Valtype(xResult) == "D"
			xResult:=Ctod(xResult) // A data ‚ digitada pelo usu rio, portanto j  estar  no formato do pa¡s vigente.
		EndIf
	END SEQUENCE
	ErrorBlock(bBlock)
EndIf
	
Return IIF(lRet,xResult,lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³VerArquivo³ Autor ³ Antonio Maniero Jr.   ³ Data ³ 28/12/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica qual e' o arquivo usado na carta                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³LOJR060                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VerArquivo(cTexto)
Local cTexto3,lTemMacro:=.F.,lMacro:=.F., cString2
cTexto += If(At(chr(13),cTexto)>0,"",chr(13))
cTexto3:=cTexto
lMacro:=( At("#",cTexto3)!=0 .And. At("_",cTexto3)!=0)
lMacro:=( At("#",Subs(cTexto3,At("#",cTexto)+1))!=0 .And. lMacro)
While (!lTemMacro .or. cTexto3=="") .and. lMacro
	cString2:=Substr(cTexto3,At("#",cTexto3)+1)
	cString2:=Substr(cString2,1,At("#",cString2)-1)
	lTemMacro:=(At("#",cTexto3)!=0 .and. At("_",cString2)!=0)
	cTexto3:=Substr(cTexto3,At("#",cTexto3)+1)
	cTexto3:=Substr(cTexto3,At("#",cTexto3)+1)
EndDo
cString2:=IIF(!lTemMacro,IIF(nArqPrin==1,"SA1","SA2"),"S"+Upper(Substr(cString2,At("_",cString2)-2,2)))
dbSelectArea(cString2)
Return lTemMacro

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³R060_Arq	³ Autor ³ Aline Correa do Vale  ³ Data ³ 20/10/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava / Apaga no arquivo em disco                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³LOJR060                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R060_Arq(cNomeArq)
IF lGrava  // inclusao
	cNomeArq:=NomeCarta(Iif(cNomeArq=="SEM_NOME.MLD","SEM_NOME.MLD",cNomeArq))
	IF !FILE(cNomeArq) .or. cNomeArq == "SEM_NOME.MLD"
		* - Manutencao: Fri	03-01-1996	16:33:49
		*	Verifica Nome de Arquivo
		nHdlt:=FCREATE(cNomeArq,0)
		If nHdlt < 0 .or. At(" ",cNomeArq) > 0
			Help(" ",1,"NAOVALID")
			FERASE(cNomeArq)
		EndIf
	ElseIf File(cNomeArq)
		// Arquivo da carta j  existe !!!
		MsgInfo(OemtoAnsi(STR0014))
		// Sobrepoe Arquivo? / Atencao
		IF MsgYesNo(OemToAnsi(STR0015),OemToAnsi(STR0016))
			FClose(nHdlt)
			FErase(cNomeArq)
			nHdlt:=FCREATE(cNomeArq,0)
		Else
			Return .F.
		EndIF
	EndIF
	If File(cNomeArq)
		FWrite(nHdlt,cTexto,Len(cTexto))
        FClose(nHdlt)
	EndIf
Else	// Exclusao
	IF !FILE(cNomeArq) .or. cNomeArq == "SEM_NOME.MLD"
		Help(" ",1,"NAOVALID")
		Return .F.
	Else
		// Exclui Arquivo? / Atencao
		If MsgYesNo(OemToAnsi(STR0017),OemToAnsi(STR0018))
			FClose(nHdlt)
			FErase(cNomeArq)
		Endif
	EndIf
EndIF

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³NomeCarta ³ Autor ³ Antonio Maniero Jr.   ³ Data ³ 28/12/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Pede o nome da carta a ser gravada/impressa                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³LOJR060                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NomeCarta(cNomeArq)
cNomeArq:=PadR(cNomeArq,8)
If At(".",cNomeArq) > 0
	cNomeArq := Subs(cNomeArq,1,At(".",cNomeArq)-1)
EndIf
Return Trim(cNomeArq)+".MLD"
