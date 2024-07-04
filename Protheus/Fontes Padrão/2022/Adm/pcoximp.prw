#INCLUDE "pcoximp.ch"
#INCLUDE "PRINT.CH"
#INCLUDE "PROTHEUS.CH"
Static aPapel		:= {}
Static PrtFontes := 1
Static cNameSave	:= ""

Static cPrtPerg 	:= ""
Static oPrint
Static aPaperSize	:= {}
Static aSave		:= {}
Static nTpPaper	:= 1
Static aFontes		:= {}
Static aCondFil	:= {}
Static PcoPrtTit	:= ""
Static aSetCols		:= {}
Static nPagAtu		:= 0
Static lRodape		:= .T.
Static nPcoPrtFor	:= 1
Static lPcoPrtPrev	:= .T.
Static nPcoPrtCop	:= 1
Static nClassic	:= 1
Static nOldPosY	:= 0
Static nTipo		:= 0
Static Tamanho
Static Li			:= 1
Static aSavRet							//Compatibilizacao relatorio classico
Static nSavPag		:= 1
Static aImprime	:= {}   
Static aPosY := {}
Static SavwnRel
Static aRodape := {}
/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³PcoPrtIni³ AUTOR ³ Edson Maricate         ³ DATA ³ 07-01-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Funcao generia de inicializacao para impressao grafica.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PcoPrtIni                                                    ³±±
±±³_DESCRI_  ³ Funcao generia de inicializacao para impressao grafica.      ³±±
±±³_DESCRI_  ³ utilizando as funcoes TmsPrinter do Protheus.                ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada em impressoes de relatorios ³±±
±±³_FUNC_    ³ graficos utilizando o conceito de celulas/cores e fontes.    ³±±
±±³_FUNC_    ³ Sempre devera ser executada no inicio da montagem do relat.  ³±±
±±³_FUNC_    ³ para criacao do objeto grafico oPrint.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpC1 : Titulo do Relatorio                                  ³±±
±±³_PARAMETR_³ ExpL2 : Indica se o relatorio devera ser impresso no formato ³±±
±±³_PARAMETR_³         LandScape ( Paisagem )                               ³±±
±±³_PARAMETR_³ ExpN3 : Fonte utilizada no relatorio ( 1=Courier New,        ³±±
±±³_PARAMETR_³         2=Arial )                                            ³±±
±±³_PARAMETR_³ ExpL4 : Indica se imprime o rodape na quebra de paginas.     ³±±
±±³_PARAMETR_³ ExpL5 : Variavel de confirmacao para geracao do relatorio.   ³±±
±±³_PARAMETR_³ ExpC6 : Grupo de perguntas utilizado no relatorio.           ³±±
±±³_PARAMETR_³ ExpC7 : Texto informativo contendo os detalhes do relatorio. ³±±
±±³_PARAMETR_³ ExpL8 : Flag para utilização do formato padrao (SetPrint).   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoPrtIni(cTitulo,lForceLand,nFontes,lImpRodape,lOk,cPerg,cDetail,lClassic,nOrient,aFiltros,aRoda)

Local aRet	:= {}
Local cUserName	:= ""

PRIVATE aReturn							//Compatibilizacao relatorio classico
PRIVATE nLastKey	:= 0					//Compatibilizacao relatorio classico
PRIVATE Titulo		:= cTitulo			//Compatibilizacao relatorio classico
DEFAULT lForceLand := .F.
DEFAULT nOrient	 := 1	// 1=Portrait ## 2=Landscape
DEFAULT lImpRodape := .T.
DEFAULT cPerg	:= ""
DEFAULT cDetail	:= STR0001+cTitulo+STR0002 //"Este relatorio ira imprimir a "###" de acordo com os parametros solicitados pelo usuário. Para mais informações sobre este relatorio consulte o Help do Programa ( F1 )."
DEFAULT lClassic	:= .F.
DEFAULT aFiltros 	:= {}
DEFAULT aRoda     := {}

nClassic		:= If(lClassic,2,1)
nPcoPrtFor	:= If(lForceLand,2,nOrient)
lRodape		:= lImpRodape
PcoPrtTit	:= cTitulo+SPACE(30)
nPagAtu		:= 0
lPcoPrtPrev	:= .T.
nPcoPrtCop	:= 1
aCondFil		:= aFiltros
aSave			:= {}
cPrtPerg 	:= cPerg
PrtFontes	:= nFontes
aRodape     := AClone(aRoda)

// Tamanhos dos papeis em PIXEL
aPapel := {STR0020,STR0021,STR0022,STR0023,STR0024,STR0025} // Carta, A4, A3 , Oficio 1, Oficio 2, Oficio 9
aPaperSize:= {	{3150,2400},; // Carta
					{3350,2330},; // A4						
					{4745,3300},; // A3
					{4010,2400},; // Oficio 1
					{3730,2400},; // Oficio 2
					{3560,2390} } // Oficio 9					

psworder(1)
PswSeek(__cUSerID)
aRet      := PswRet(1) 
cUserName := aRet[1][2]

aAdd(aSave,{"PGREPORT1.1",PrtFontes, Nil })
cNameSave := ""


If lClassic
	lOk := .F.
	aReturn := { STR0003, 1,STR0004, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"

	Tamanho := If(nPcoPrtFor==2,"G","M")
	
	LI := 350
	
	wnrel:=SetPrint("",ProcName(1),cPerg,@Titulo,cDetail,"","",.F.,{},!lForceLand,Tamanho)

	If nLastKey == 27
		Set Filter To
		Return
	Endif

	lOk := .T.
	SetDefault(aReturn,"")

	If lOk
		If !Empty(cPerg)
			Pergunte(cPerg,.F.)
		EndIf
	EndIf
	nTipo := IIF(aReturn[4]==1,15,18)
	aImprime	:= {} 
	aPosY := {}
	SavwnRel := wnrel

	aSavRet := aClone(aReturn)
	Return
	
Else
	//Carrega profile do usuario (expansao da arvore do projeto)
	If FindProfDef( cUserName, "PCOXIMP", "PAPER_TYPE", "PCOXIMP" )
		nTpPaper := Val(RetProfDef(cUserName,"PCOXIMP","PAPER_TYPE", "PCOXIMP"))
	Endif
	
	oPrint := PrintNew( cTitulo )
	
	lOk := PcoPrtDlg(@oPrint,@nPcoPrtFor,lForceLand,cPerg,cDetail,@lPcoPrtPrev,@nPcoPrtCop,@nFontes)

	If lOk
	
		If nFontes == 1
			aAdd(aFontes,{TFont():New("Courier New",03,06,,.T.,,,,.T.,.F.),16})
			aAdd(aFontes,{TFont():New("Courier New",06,08,,.T.,,,,.T.,.F.),18})
			aAdd(aFontes,{TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.),22})
			aAdd(aFontes,{TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.),5})                                   
			aAdd(aFontes,{TFont():New("Courier New",15,15,,.T.,,,,.T.,.F.),6})
			aAdd(aFontes,{TFont():New("Courier New",20,20,,.T.,,,,.T.,.F.),7})

			aAdd(aFontes,{TFont():New("Courier New",03,06,,.F.,,,,.T.,.F.),16})
			aAdd(aFontes,{TFont():New("Courier New",06,08,,.F.,,,,.T.,.F.),18})

		Else
			aAdd(aFontes,{TFont():New("Arial",03,06,,.T.,,,,.T.,.F.),16})
			aAdd(aFontes,{TFont():New("Arial",06,08,,.T.,,,,.T.,.F.),18})
			aAdd(aFontes,{TFont():New("Arial",10,10,,.F.,,,,.T.,.F.),22})
			aAdd(aFontes,{TFont():New("Arial",10,10,,.T.,,,,.T.,.F.),5})
			aAdd(aFontes,{TFont():New("Arial",15,15,,.T.,,,,.T.,.F.),6})
			aAdd(aFontes,{TFont():New("Arial",20,20,,.T.,,,,.T.,.F.),7})

			aAdd(aFontes,{TFont():New("Arial",03,06,,.F.,,,,.T.,.F.),16})
			aAdd(aFontes,{TFont():New("Arial",06,08,,.F.,,,,.T.,.F.),18})

		EndIf

	
		If !Empty(cPerg)
			Pergunte(cPerg,.F.)
		EndIf
		If lForceLand .Or. nPcoPrtFor == 2 
			PrintLandScape()
			nPcoPrtFor := 2 
			nOrient	:=2
		Else
			PrintPortrait()
			nOrient	:=1
		EndIf
		// Grava a configuração da impressora do usuario
		If FindProfDef( cUserName, "PCOXIMP", "PAPER_TYPE", "PCOXIMP" )
			WriteProfDef(cUserName, "PCOXIMP", "PAPER_TYPE", "PCOXIMP", cUserName, "PCOXIMP", "PAPER_TYPE", "PCOXIMP", Str(nTpPaper) )
		Else                
			WriteNewProf( cUserName, "PCOXIMP", "PAPER_TYPE", "PCOXIMP", Str(nTpPaper) )
		Endif     
	EndIf
EndIf	

Return oPrint

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³PcoPrtCell³ AUTOR ³ Edson Maricate        ³ DATA ³ 07-01-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³Funcao de impressao das celulas do relatorio.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PcoPrtCell                                                   ³±±
±±³_DESCRI_  ³ Funcao de impressao das celulas do relatorio.                ³±±
±±³_DESCRI_  ³ Deve ser utilizado junto com a funcao PcoPrtIni.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpN1 : Posição X de impressão da celula                     ³±±
±±³_PARAMETR_³ ExpN2 : Posição Y de impressão da celula                     ³±±
±±³_PARAMETR_³ ExpN3 : Tamanho da celula                                    ³±±
±±³_PARAMETR_³ ExpN4 : Altura da celula                                     ³±±
±±³_PARAMETR_³ ExpC5 : Texto a ser exibido                                  ³±±
±±³_PARAMETR_³ ExpO6 : Objeto oPrint criado pela PcoPrtIni                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoPrtCell(nPosX,nPosY,nTamanho,nAltura,cSay,oPrint,nStilo,nFonte,nColor,cToolTip, lAlinDir,cCampo,cPicture,lCentral,lNumero)
Local cBmp 
Local nScan
Local lImpText := .F.
Local nAltAtu := 1

DEFAULT nFonte := 1
DEFAULT lAlinDir := .F.
DEFAULT cToolTip := ""
DEFAULT nTamanho := PcoPrtTam(1)
DEFAULT lCentral := .F.
DEFAULT cSay := ""
DEFAULT lNumero := .F.

lAlinDir := If(lCentral, .F., lAlinDir)

If cCampo <> Nil
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek(cCampo)
		If cToolTip <> Nil 
			cToolTip := AllTrim(X3TITULO())
		EndIf
		cSay := Transform(cSay, X3_PICTURE)
	EndIf
EndIf

If cPicture <> Nil
	cSay := Transform(cSay, cPicture)
EndIf

If nClassic == 2 
	nScan := aScan(aPosY,{|x| x[1] == nPosY })
	If nScan > 0   // Recupera a posicao do nPosY ( retorno da linha na impressao )
		LI := aPosY[nScan,2]
		nOldPosY := aPosY[nScan,1]
	Else
		If nPosY<>nOldPosY
			aAdd(aPosY,{nOldPosY,LI})
			LI ++
			If nStilo == 4
				LI++
			EndIf
			nOldPosY := nPosY
		EndIf
	EndIf
	If nStilo == 4
		aAdd(aImprime,{LI-1,If(Tamanho=="G",220*(nPosX+3)/3400,132*(nPosX+3)/2400),cToolTip})
	EndIf
	If lAlinDir
		aAdd(aImprime,{LI,If(Tamanho=="G",NoRound((220*(nPosX+4)/3400)+(220*nTamanho/3400)-Len(AllTrim(cSay)),0) ,NoRound((132*(nPosX+7)/2400)+(132*nTamanho/2400)-Len(Alltrim(cSay)),0) ),AllTrim(cSay)})
	Else
		aAdd(aImprime,{LI,If(Tamanho=="G",220*(nPosX+7)/3400,132*(nPosX+7)/2400),cSay})
	EndIf
Else
	Do Case
		Case nStilo == 2
			PrintBox(nPosY,nPosX,nPosY+nAltura,nPosX+nTamanho)
			If nColor != Nil
				PrintBmpBox(nPosY+2 ,nPosX+2 ,nColor,nTamanho-5,nAltura-5)
			EndIf
			lImpText := .T.
		Case nStilo == 3
			If nColor != Nil
				PrintBmpBox(nPosY ,nPosX ,nColor,nTamanho,nAltura)
			EndIf
			lImpText := .T.
		Case nStilo == 4
			PrintBox(nPosY,nPosX,nPosY+nAltura,nPosX+nTamanho)
			If nColor != Nil
				PrintBmpBox(nPosY+2 ,nPosX+2 ,nColor,nTamanho-5,nAltura-5)
			EndIf
			PrintSay(nPosY+1,nPosX+3,cToolTip,{1,1})
			nAltAtu := 16
			nPosY += 6
			lImpText := .T.
		Case nStilo == 5 .Or. nStilo == 1 // Estilo 1 fora de uso - Compatibilizacao com relatorios antigos.
			lImpText := .T.
		Case nStilo == 6 // Para impressão do cabeçalho referente ao campo ( Utiliza o tooltip como texto interno ) igual ao 2, porem utiliza o tooltip
			PrintBox(nPosY,nPosX,nPosY+nAltura,nPosX+nTamanho)
			If nColor != Nil
				PrintBmpBox( nPosY+2 ,nPosX+2 ,nColor,nTamanho-5,nAltura-5)
			EndIf
			cSay := cToolTip
			cToolTip := ""
			lImpText := .T.
		Case nStilo == 7
			PrintBox(nPosY+nAltura-1,nPosX,nPosY+nAltura,nPosX+nTamanho)
			If nColor != Nil
				PrintBmpBox( nPosY+2 ,nPosX+2 ,nColor,nTamanho-5,nAltura-5)
			EndIf
			lImpText := .T.
		Case nStilo == 8
			PrintImage( nPosY+2 ,nPosX+2 ,cSay,nTamanho-5,nAltura-5)
	EndCase		

	If lImpText
		If lAlinDir
			PrintSay(nPosY+(nAltura/2)-aFontes[nFonte][2],nPosX+nTamanho-PcoPrtSize(Alltrim(cSay),nFonte, lAlinDir, lNumero),Alltrim(cSay),{nFonte,1})
		ElseIf lCentral
			PrintSay(nPosY+(nAltura/2)-aFontes[nFonte][2],nPosX+4+((nTamanho-PcoPrtSize(Alltrim(cSay),nFonte))/2),Alltrim(cSay),{nFonte,1})
		Else
			If ( PcoPrtSize(Alltrim(cSay),nFonte)>nTamanho .Or. CRLF $ cSay ).And. nAltura > (aFontes[nFonte][2])*4
				If PcoPrtSize(Alltrim("Z"),nFonte)<nTamanho
					cSay := AllTrim(cSay)
					While Len(cSay) > 0 .And. !Empty(cSay) 
						cLiSay := Substr(cSay,1,1)
						nLargAtu := PcoPrtSize(cLiSay,nFonte)
						While nLargAtu<=nTamanho .And. Len(cLiSay)+1 <= Len(cSay)
							nLargAtu += PcoPrtSize(Substr(cSay,Len(cLiSay)+1,1),nFonte)
							If Substr(cSay,Len(cLiSay),2) == CRLF
								cLiSay := Substr(cSay,1,Len(cLiSay)-1)+"  "
								Exit
							Else
								cLiSay := Substr(cSay,1,Len(cLiSay)+1)
							EndIf
						End 
						If (nAltAtu+(aFontes[nFonte][2])*2) < nAltura
							PrintSay(nPosY+nAltAtu,nPosX+7,cLiSay,{nFonte,1})
							cSay := Substr(cSay,Len(cLiSay)+1)
							nAltAtu += (aFontes[nFonte][2])*2
						Else
							Exit
						EndIf
					End
				EndIf
			Else
				PrintSay(nPosY+(nAltura/2)-aFontes[nFonte][2],nPosX+7,cSay,{nFonte,1})
			EndIf
		EndIf
	EndIf
EndIf

Return
               
Function PcoPrtSize(cSay,nFonte, lAlinDir, lNumero)
Local nSize := 0
Local nx
Local aSize := 	{ {14.793,6.25,13.793,11.25,14.5},{19.2,2.692,15.241,13.692,17.55},{20,11.112,18,16,19.5},{21.05,10.028,19.05,17,20.75},{31.500,15.384,29.500,27,31},{41.66,20.20,38.66,36,41.2},{14.793,6.25,13.793,11.25,14.493},{17.241,2.692,15.241,13.692,16.82}} 
Local aCorrec := 	{ {.075,0,.04,.03,.045},{.070,0,.04,.03,.045},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}} 

DEFAULT lAlinDir := .F.
DEFAULT lNumero := .F.

For nx := 1 to Len(cSay)
	If Substr(cSay,nx,1)=="." .Or. Substr(cSay,nx,1)=="," .or. Substr(cSay,nx,1)=="I" 
		nSize += aSize[nFonte,2]-(aCorrec[nFonte,2]*Len(cSay))
	ElseIf Substr(cSay,nx,1)$"abcdefghijklmnopqrstuvwxyz"
		nSize += aSize[nFonte,4]-(aCorrec[nFonte,4]*Len(cSay))
	ElseIf Substr(UPPER(cSay),nx,1)$"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		nSize += aSize[nFonte,3]-(aCorrec[nFonte,3]*Len(cSay))
	ElseIf Substr(UPPER(cSay),nx,1)$"1"
		nSize += aSize[nFonte,5]-(aCorrec[nFonte,5]*Len(cSay))
	Else
		nSize += aSize[nFonte,1]-(aCorrec[nFonte,1]*Len(cSay))
	EndIf
Next
If lNumero .And. lAlinDir 
	If cSay != "0,00"
		nSize -= ( aSize[nFonte,2]*Len(cSay) ) + aCorrec[nFonte, 1]
	EndIf	
	If Subs(cSay, 1, 1) == "-"
		nSize -= 22
	ElseIf cSay == "0,00"
		nSize -= 10
	Else
		nSize -= 8
	EndIf
EndIf

Return nSize
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoPrtCab³ Autor ³ Edson Maricate         ³ Data ³07-01-2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de impressao do cabecalho no objeto TmsPrint         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PcoPrtCab                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PcoPrtCab(oPrint,nStilo,cFileLogo)

Local nx
Local nLin

DEFAULT nStilo    := 1
DEFAULT cFileLogo := "LGRL"+SM0->M0_CODIGO+cFilAnt+".BMP"

PRIVATE aReturn  // Compatibilizacao com a versao classica
If nClassic == 2
	aReturn := aSavRet
	aImprime := aSort( aImprime,,, { | x , y | Str(x[1],5)+Str(x[2],5) < Str(y[1],5)+Str(y[2],5) } )	
	For nx := 1 to Len(aImprime)
		@ aImprime[nx,1],aImprime[nx,2] PSAY aImprime[nx,3]
		LI := aImprime[nx,1]
	Next
	M_PAG	:= nSavPag
	aImprime := {}     
	aPosY    := {}      
	wnrel := SavwnRel
	cabec(PcoPrtTit,"","",wnrel,Tamanho,nTipo)
	aSavRet:=aReturn
	nSavPag := M_PAG
	SavwnRel := wnrel
Else
	
	If !File( cFileLogo )
		cFileLogo := "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
	Endif
	If nPagAtu	== 0 .And. !Empty(cPrtPerg)
		If ImpSX1(cFileLogo)
			nPagAtu++
		Endif	
	Endif	
	
	If nPagAtu > 0 .And. lRodape
		If nPcoPrtFor == 2 
			//-- Formato do array
			//aRodaPe[n,1] // Texto a ser impresso
			//aRodaPe[n,2] // Centralizado (.T./.F.)
			If !Empty(aRodape)
				nLin := aPaperSize[nTpPaper][2]-(Len(aRodaPe)*30)-60
				PrintLine(nLin-10, 20, nLin-10, aPaperSize[nTpPaper][1] )
				PrintLine(nLin-09, 20, nLin-09, aPaperSize[nTpPaper][1] )
				For nX := 1 To Len(aRodape)
					If !aRodape[nX,2] //-- Centralizado
						PrintSay(nLin-10,30,aRodape[nX,1],{3,1} )
					Else
						PrintSay(nLin-10,(aPaperSize[nTpPaper][1]/2-PcoPrtSize(Alltrim(aRodape[nX,1]),1)/2),aRodape[nX,1],{3,1} )
					Endif
					nLin+= 30
				Next nX
				PrintSay(nLin-10,30,DTOC(MsDate())+" "+Time(),{3,1} )	// "Hora :" //"Hora : "
				PrintSay(nLin-10,aPaperSize[nTpPaper][1]-200,STR0006+Transform(nPagAtu,"@e 99999"),{3,1} )	
			Else
				PrintLine(aPaperSize[nTpPaper][2]-40, 20, aPaperSize[nTpPaper][2]-40, aPaperSize[nTpPaper][1] )
				PrintLine(aPaperSize[nTpPaper][2]-39, 20, aPaperSize[nTpPaper][2]-39, aPaperSize[nTpPaper][1] )
				PrintSay(aPaperSize[nTpPaper][2]-40,30,DTOC(MsDate())+" "+Time(),{3,1} )
				PrintSay(aPaperSize[nTpPaper][2]-40,aPaperSize[nTpPaper][1]-200,STR0006+Transform(nPagAtu,"@e 99999"),{3,1} )	
			EndIf
		Else
			//-- Formato do array
			//aRodaPe[n,1] // Texto a ser impresso
			//aRodaPe[n,2] // Centralizado (.T./.F.)
			If !Empty(aRodape)
				nLin := aPaperSize[nTpPaper][1]-(Len(aRodaPe)*30)-60
				PrintLine(nLin-10, 20, nLin-10, aPaperSize[nTpPaper][2] )
				PrintLine(nLin-09, 20, nLin-09, aPaperSize[nTpPaper][2] )
				For nX := 1 To Len(aRodape)
					If !aRodape[nX,2] //-- Centralizado
						PrintSay(nLin-10,30,aRodape[nX,1],{3,1} )
					Else
						PrintSay(nLin-10,(aPaperSize[nTpPaper][2]/2-PcoPrtSize(Alltrim(aRodape[nX,1]),1)/2),aRodape[nX,1],{3,1} )
					Endif
					nLin+= 30
				Next nX
				PrintSay(nLin-10,30,DTOC(MsDate())+" "+Time(),{3,1} )	// "Hora :" //"Hora : "
				PrintSay(nLin-10,aPaperSize[nTpPaper][2]-200,STR0006+Transform(nPagAtu,"@e 99999"),{3,1} )	
			Else
				PrintLine(aPaperSize[nTpPaper][1]-40, 20, aPaperSize[nTpPaper][1]-40, aPaperSize[nTpPaper][2] )
				PrintLine(aPaperSize[nTpPaper][1]-39, 20, aPaperSize[nTpPaper][1]-39, aPaperSize[nTpPaper][2] )
				PrintSay(aPaperSize[nTpPaper][1]-40,30,DTOC(MsDate())+" "+Time(),{3,1} )	
				PrintSay(aPaperSize[nTpPaper][1]-40,aPaperSize[nTpPaper][2]-200,STR0006+Transform(nPagAtu,"@e 99999"),{3,1} )	
			EndIf
		Endif
	EndIf
	PrintEndPage()
	PrintStartPage()
	If nStilo == 1 .Or. nStilo == 3 //-- Imprime Logo a Esquerda
		PrintImage(30,30, cFileLogo,474,117)
	ElseIf nStilo == 2 .Or. nStilo == 4 //-- Imprime Logo a Direita
		If nPcoPrtFor == 2 
			PrintImage(30,aPaperSize[nTpPaper][1]-425, cFileLogo,474,117)
		Else
			PrintImage(30,aPaperSize[nTpPaper][2]-425, cFileLogo,474,117)
		EndIf
	EndIf
	If nPcoPrtFor == 2 
		PrintSay(100,(aPaperSize[nTpPaper][1]/2)-(PcoPrtSize(Alltrim(PcoPrtTit),5)/2),AllTrim(PcoPrtTit),{5,1})
	Else
		PrintSay(100,(aPaperSize[nTpPaper][2]/2)-(PcoPrtSize(Alltrim(PcoPrtTit),5)/2),AllTrim(PcoPrtTit),{5,1})
	EndIf
	If nStilo == 1 .Or. nStilo == 2 //-- Imprime Filial e Data Base
		PrintSay(146,30,QA_CHKFIL(cFilAnt,,.T.),{3,1} )
		If nPcoPrtFor == 2 
			PrintSay(146,aPaperSize[nTpPaper][1]-425,STR0007+DTOC(dDataBase),{3,1}) //"Data Base : "
			PrintLine(190, 20, 190, aPaperSize[nTpPaper][1] )
			PrintLine(191, 20, 191, aPaperSize[nTpPaper][1] )
		Else
			PrintSay(146,aPaperSize[nTpPaper][2]-425,STR0007+DTOC(dDataBase),{3,1}) //"Data Base : "
			PrintLine(190, 20, 190, aPaperSize[nTpPaper][2] )
			PrintLine(191, 20, 191, aPaperSize[nTpPaper][2] )
		Endif
	EndIf
EndIf

nPagAtu++

Return 200

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoPrtCol³ Autor ³ Edson Maricate         ³ Data ³07-01-2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de configuracao das colunas do relatorio             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PcoPrtCol                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PcoPrtCol(aColunas,lAlignAuto,nChange)

Local nMaxCalc
Local nMaxAtu
Local nDiff  
Local nx

Default lAlignAuto := .F.

// Quando utilizado o Alinhamento automatico, o final da coluna devera vir preenchido na ultima posicao do array aColunas

If   lAlignAuto
	aSetCols := aClone(aColunas)
	If nPcoPrtFor == 2 
		nMaxCalc :=  aPaperSize[nTpPaper][1]
	Else
		nMaxCalc :=  aPaperSize[nTpPaper][2]
	Endif	
	nMinAtu := aColunas[1]
	nMaxAtu	:= aColunas[Len(aColunas)]
	nDiff 	:= (nMaxCalc-(nMaxAtu-nMinAtu))/(nMaxAtu-nMinAtu)
	aSetCols[1]:= 20
	For nx := 1 to len(aColunas)-1
		If nChange<>Nil .And. nChange > 0
			If nx > nChange
				aSetCols[nx] := aColunas[nx]+(nMaxCalc-(nMaxAtu-nMinAtu))
			EndIf
		Else
			aSetCols[nx] := aColunas[nx]+(nDiff*(aColunas[nx+1]-aColunas[nx]))+20
		EndIf
	Next
	aSetCols[Len(aColunas)] := nMaxCalc
Else
	aSetCols	:= aClone(aColunas)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoPrtPos³ Autor ³ Edson Maricate         ³ Data ³07-01-2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a posicao da coluna no relatorio                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PcoPrtPos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PcoPrtPos(nCol)

Return aSetCols[nCol]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoPrtTam³ Autor ³ Edson Maricate         ³ Data ³07-01-2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o tamanho da coluna no relatorio                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PcoPrtTam                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PcoPrtTam(nCol)
Local nRet

	If nCol == Len(aSetCols)
		If nPcoPrtFor == 2 
			nRet := aPaperSize[nTpPaper][1]-aSetCols[nCol]	
		Else
			nRet := aPaperSize[nTpPaper][2]-aSetCols[nCol]	
		Endif	
	Else
		nRet := aSetCols[nCol+1]-aSetCols[nCol]+1
	EndIf
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoPrtEnd³ Autor ³ Edson Maricate         ³ Data ³08-01-2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de finalizacao da impressao grafica.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PcoPrtEnd(oPrint)
Local nX := 0
Local nLin := 0
Local aSaveParam := {}
PRIVATE aReturn 
If nClassic == 2
	M_PAG	:= nSavPag
	aReturn := aSavRet
	aImprime := aSort( aImprime,,, { | x , y | Str(x[1],5)+Str(x[2],5) < Str(y[1],5)+Str(y[2],5) } )	
	For nx := 1 to Len(aImprime)      
		LI := aImprime[nx,1]
		@ LI,aImprime[nx,2] PSAY aImprime[nx,3]
	Next
	M_PAG := nSavPag
	aImprime := {} 	  
	wnrel := SavwnRel
	LI++
	IF li != 80  
		roda(LI,"",Tamanho)
	EndIF

	If aReturn[5] = 1
		Set Printer TO
		dbCommitAll()
		ourspool(wnrel)
	Endif
		
	MS_FLUSH()
	
Else
	If nPagAtu > 0 .And. lRodape
		If nPcoPrtFor == 2 
			//-- Formato do array
			//aRodaPe[n,1] // Texto a ser impresso
			//aRodaPe[n,2] // Centralizado (.T./.F.)
			If !Empty(aRodape)
				nLin := aPaperSize[nTpPaper][2]-(Len(aRodaPe)*30)-60
				PrintLine(nLin-10, 20, nLin-10, aPaperSize[nTpPaper][1] )
				PrintLine(nLin-09, 20, nLin-09, aPaperSize[nTpPaper][1] )
				For nX := 1 To Len(aRodape)
					If !aRodape[nX,2] //-- Centralizado
						PrintSay(nLin-10,30,aRodape[nX,1],{3,1} )
					Else
						PrintSay(nLin-10,(aPaperSize[nTpPaper][1]/2-PcoPrtSize(Alltrim(aRodape[nX,1]),1)/2),aRodape[nX,1],{3,1} )
					Endif
					nLin+= 30
				Next nX
				PrintSay(nLin-10,30,DTOC(MsDate())+" "+Time(),{3,1} )	// "Hora :" //"Hora : "
				PrintSay(nLin-10,aPaperSize[nTpPaper][1]-200,STR0006+Transform(nPagAtu,"@e 99999"),{3,1} )	
			Else
				PrintLine(aPaperSize[nTpPaper][2]-40, 20, aPaperSize[nTpPaper][2]-40, aPaperSize[nTpPaper][1] )
				PrintLine(aPaperSize[nTpPaper][2]-39, 20, aPaperSize[nTpPaper][2]-39, aPaperSize[nTpPaper][1] )
				PrintSay(aPaperSize[nTpPaper][2]-40,30,DTOC(MsDate())+" "+Time(),{3,1} )	// "Hora :" //"Hora : "
				PrintSay(aPaperSize[nTpPaper][2]-40,aPaperSize[nTpPaper][1]-200,STR0006+Transform(nPagAtu,"@e 99999"),{3,1} )	// "Pag." //"Pag. "
			EndIf
		Else
			//-- Formato do array
			//aRodaPe[n,1] // Texto a ser impresso
			//aRodaPe[n,2] // Centralizado (.T./.F.)
			If !Empty(aRodape)
				nLin := aPaperSize[nTpPaper][1]-(Len(aRodaPe)*30)-60
				PrintLine(nLin-10, 20, nLin-10, aPaperSize[nTpPaper][2] )
				PrintLine(nLin-09, 20, nLin-09, aPaperSize[nTpPaper][2] )
				For nX := 1 To Len(aRodape)
					If !aRodape[nX,2] //-- Centralizado
						PrintSay(nLin-10,30,aRodape[nX,1],{3,1} )
					Else
						PrintSay(nLin-10,(aPaperSize[nTpPaper][2]/2-PcoPrtSize(Alltrim(aRodape[nX,1]),1)/2),aRodape[nX,1],{3,1} )
					Endif
					nLin+= 30
				Next nX
				PrintSay(nLin-10,30,DTOC(MsDate())+" "+Time(),{3,1} )	// "Hora :" //"Hora : "
				PrintSay(nLin-10,aPaperSize[nTpPaper][2]-200,STR0006+Transform(nPagAtu,"@e 99999"),{3,1} )	
			Else
				PrintLine(aPaperSize[nTpPaper][1]-40, 20, aPaperSize[nTpPaper][1]-40, aPaperSize[nTpPaper][2] )
				PrintLine(aPaperSize[nTpPaper][1]-39, 20, aPaperSize[nTpPaper][1]-39, aPaperSize[nTpPaper][2] )
				PrintSay(aPaperSize[nTpPaper][1]-40,30,DTOC(MsDate())+" "+Time(),{3,1} )	// "Hora :" //"Hora : "
				PrintSay(aPaperSize[nTpPaper][1]-40,aPaperSize[nTpPaper][2]-200,STR0006+Transform(nPagAtu,"@e 99999"),{3,1} )	// "Pag." //"Pag. "
			Endif
		EndIf
	EndIf
	PrintEndPage()
	MakeDir(SuperGetMV('MV_RELT'))
	
	If Len(aSave)>2 .And. !Empty(cNameSave)
		aSaveParam := {}
		If !Empty(cPrtPerg)
			dbSelecTArea("SX1")
			dbSetOrder(1)
			dbSeek(cPrtPerg)
			nx := 1
			While !Eof() .And. X1_GRUPO == cPrtPerg
				If Type('mv_par'+StrZero(nx,2)) <> "U"
					aAdd(aSaveParam,{X1PERGUNT(),ToXlsFormat(&('mv_par'+StrZero(nx,2)))})
				EndIf
				nx++
				dbSkip()
			End
		EndIf
		aSave[1,3] := {aPapel[nTpPaper],If(nPcoPrtFor==2,STR0015,STR0014),DTOC(MsDate())+" "+Time(),cUserName,AllTrim(SM0->M0_NOME)+" / "+AllTrim(SM0->M0_FILIAL),aSaveParam,FunName() }
		If !(".PGS"$cNameSave)
			cNameSave := AllTrim(cNameSave)+".PGS"
		EndIf
		If !("\"$cNameSave)
			cNameSave := GetMV("MV_RELT")+AllTrim(cNameSave)
		EndIf
		__VSave(aSave,cNameSave)
	EndIf

	If lPcoPrtPrev
		oPrint:Preview()
	Else
		For nX := 1 to nPcoPrtCop
			oPrint:Print() 
		Next
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoPrtLim³ Autor ³ Edson Maricate         ³ Data ³08-01-2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de finalizacao da impressao grafica.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PcoPrtLim(nLimite)
Local lRet := .F.

//-- Adiaciona o tamanho do array de rodape
nLimite += (Len(aRodaPe)*30-30)

If nClassic == 2
	If Tamanho == "G"
		If LI==350 .Or.(LI > 58)
			lRet := .T.
		EndIf
	Else
		If LI==350 .Or.(LI > 58)
			lRet := .T.
		EndIf
	EndIf	
Else
	If nPcoPrtFor == 2 
		If nLimite > aPaperSize[nTpPaper][2]-190-38 //2200
			lRet := .T.
		EndIf
	Else
		If nLimite > aPaperSize[nTpPaper][1]-190-38 //3000
			lRet := .T.
		EndIf
	Endif
EndIf
Return lRet

Function PcoPrtLine(nPosY, nPosXIni, nPosXFim)	
DEFAULT nPosXIni := 190
DEFAULT nPosXFim := If(nPcoPrtFor == 2, aPaperSize[nTpPaper][1], aPaperSize[nTpPaper][2])

If nClassic == 2
	If Tamanho == "G"
		aAdd(aImprime,{LI,01,__PrtThinLine()})
	Else
		aAdd(aImprime,{LI,01,__PrtThinLine()})
	EndIf
	LI++
Else
	If nPcoPrtFor == 2
		PrintLine(nPosXIni, nPosY, nPosXIni, nPosXFim )
	Else
		PrintLine(nPosXIni, nPosY, nPosXIni, nPosXFim )
	EndIf
EndIf
	
Return

Static Function PrtFilter()
Local nx
Local aRet	:= {}

If ParamBox( aCondFil ,STR0008,@aRet)   //"Configurar Filtros"
	For nx := 1 to Len(aRet)
		aCondFil[nx][4] := aRet[nx]
	Next
EndIf

Return 

Function PrtGetFilter(nFilter)

Return aCondFil[nFilter][4]


Function PcoPrtDlg(oPrint,nOption,lLandScape,cPerg,cDescri,lPreview,nCopias,nFontes)
Local lRet := .F.
Local cPapel
Local oDlg,Formato,Titulo,oSayTit,oFormato,oBmpPor,oSBtn7,oSBtn8,oSBtn9,oGrp10,oBmpLan,oBmp14,oChk15,oGrp15,oGet16,oBmp16,oDetail,oConfig,oSBtn19,oSBtn20
oDlg := MSDIALOG():Create()
oDlg:cName := "oDlg"
oDlg:cCaption := STR0009 //"Gerenciador de Impressao"
oDlg:nLeft := 0
oDlg:nTop := 0
oDlg:nWidth := 491
oDlg:nHeight := 380
oDlg:lShowHint := .F.
oDlg:lCentered := .T.
oDlg:bInit := {|| (If(nOption==1,(oBmpPor:Show(),oBmpLan:Hide()),(oBmpPor:Hide(),oBmpLan:Show()))),(oDetail:cCaption := cDescri),(oConfig:cTooltip:= STR0010)  } //"Configuracao da  Impressora"



Formato := TGROUP():Create(oDlg)
Formato:cName := "Formato"
Formato:cCaption := STR0011 //"Formato"
Formato:nLeft := 209
Formato:nTop := 12
Formato:nWidth := 185
Formato:nHeight := 224
Formato:lShowHint := .F.
Formato:lReadOnly := .F.
Formato:Align := 0
Formato:lVisibleControl := .T.

Titulo := TGROUP():Create(oDlg)
Titulo:cName := "Titulo"
Titulo:cCaption := STR0012 //"Titulo"
Titulo:nLeft := 22
Titulo:nTop := 88
Titulo:nWidth := 180
Titulo:nHeight := 62
Titulo:lShowHint := .F.
Titulo:lReadOnly := .F.
Titulo:Align := 0
Titulo:lVisibleControl := .T.

@ 20,17 COMBOBOX oPapel VAR cPapel ITEMS aPapel SIZE 52,120 VALID SetPapel(oPapel:nAt) OF oDlg PIXEL 
oPapel:nAt := nTpPaper

oSayTit := TGET():Create(oDlg)
oSayTit:cName := "oSayTit"
oSayTit:nLeft := 35
oSayTit:nTop := 109
oSayTit:nWidth := 155
oSayTit:nHeight := 26
oSayTit:lShowHint := .F.
oSayTit:lReadOnly := .F.
oSayTit:Align := 0
oSayTit:cVariable := "PcoPrtTit "
oSayTit:bSetGet := {|u| If(PCount()>0,PcoPrtTit :=u,PcoPrtTit ) }
oSayTit:lVisibleControl := .T.
oSayTit:lPassword := .F.
oSayTit:lHasButton := .F.
oSayTit:bWhen := {|| !PgrInUse() }

oFormato := TRADMENU():Create(oDlg)
oFormato:cName := "oFormato"
oFormato:cCaption := STR0013 //"Teste"
oFormato:nLeft := 221
oFormato:nTop := 34
oFormato:nWidth := 161
oFormato:nHeight := 43
oFormato:lShowHint := .F.
oFormato:lReadOnly := .F.
oFormato:Align := 0
oFormato:cVariable := "nOption"
oFormato:bSetGet := {|u| If(PCount()>0,nOption:=u,nOption) }
oFormato:lVisibleControl := .T.
oFormato:aItems := { STR0014,STR0015} //"Retrato"###"Paisagem"
oFormato:nOption := nOption
oFormato:bWhen := {|| !lLandScape }
oFormato:bChange := {|| If(oFormato:nOption==1,(oBmpPor:Show(),oBmpLan:Hide(),oPrint:SetPortrait()), (oBmpPor:Hide(),oBmpLan:Show(),oPrint:SetLandscape())) }

oBmpPor := TBITMAP():Create(oDlg)
oBmpPor:cName := "oBmpPor"
oBmpPor:nLeft := 254
oBmpPor:nTop := 88
oBmpPor:nWidth := 113
oBmpPor:nHeight := 131
oBmpPor:lShowHint := .F.
oBmpPor:lReadOnly := .F.
oBmpPor:Align := 0
oBmpPor:lVisibleControl := .T.
oBmpPor:cResName := "PcoPrtPor"
oBmpPor:lStretch := .F.
oBmpPor:lAutoSize := .F.

oSBtn7 := SBUTTON():Create(oDlg)
oSBtn7:cName := "oSBtn7"
oSBtn7:cToolTip := STR0016 //"Confirma Impressao"
oSBtn7:nLeft := 411
oSBtn7:nTop := 17
oSBtn7:nWidth := 59
oSBtn7:nHeight := 22
oSBtn7:lShowHint := .F.
oSBtn7:lReadOnly := .F.
oSBtn7:Align := 0
oSBtn7:lVisibleControl := .T.
oSBtn7:nType := 1
oSBtn7:bLClicked := {|| lRet:=.T.,oDlg:End() }

oSBtn8 := SBUTTON():Create(oDlg)
oSBtn8:cName := "oSBtn8"
oSBtn8:cToolTip := STR0017 //"Cancelar Impressao"
oSBtn8:nLeft := 411
oSBtn8:nTop := 48
oSBtn8:nWidth := 59
oSBtn8:nHeight := 22
oSBtn8:lShowHint := .F.
oSBtn8:lReadOnly := .F.
oSBtn8:Align := 0
oSBtn8:lVisibleControl := .T.
oSBtn8:nType := 2
oSBtn8:bLClicked := {|| oDlg:End() }

oSBtn9 := SBUTTON():Create(oDlg)
oSBtn9:cName := "oSBtn9"
oSBtn9:cToolTip := STR0018 //"Parametros do Relatorio"
oSBtn9:nLeft := 411
oSBtn9:nTop := 78
oSBtn9:nWidth := 59
oSBtn9:nHeight := 22
oSBtn9:lShowHint := .F.
oSBtn9:lReadOnly := .F.
oSBtn9:Align := 0
oSBtn9:lVisibleControl := .T.
oSBtn9:nType := 5
oSBtn9:bWhen := {|| !Empty(cPerg) }
oSBtn9:bLClicked := {|| Pergunte(cPerg) }

oGrp10 := TGROUP():Create(oDlg)
oGrp10:cName := "oGrp10"
oGrp10:cCaption := STR0019 //"Descricao"
oGrp10:nLeft := 16
oGrp10:nTop := 242
oGrp10:nWidth := 381
oGrp10:nHeight := 84
oGrp10:lShowHint := .F.
oGrp10:lReadOnly := .F.
oGrp10:Align := 0
oGrp10:lVisibleControl := .T.

oBmpLan := TBITMAP():Create(oDlg)
oBmpLan:cName := "oBmpLan"
oBmpLan:nLeft := 246
oBmpLan:nTop := 87
oBmpLan:nWidth := 116
oBmpLan:nHeight := 113
oBmpLan:lShowHint := .F.
oBmpLan:lReadOnly := .F.
oBmpLan:Align := 0
oBmpLan:lVisibleControl := .F.
oBmpLan:cResName := "PcoPrtLan"
oBmpLan:lStretch := .F.
oBmpLan:lAutoSize := .F.

oBmp14 := TBITMAP():Create(oDlg)
oBmp14:cName := "oBmp14"
oBmp14:cCaption := "oBmp14"
oBmp14:nLeft := 22
oBmp14:nTop := 17
oBmp14:nWidth := 179
oBmp14:nHeight := 66
oBmp14:lShowHint := .F.
oBmp14:lReadOnly := .F.
oBmp14:Align := 0
oBmp14:lVisibleControl := .T.
oBmp14:cResName := "PCOIMPRES"
oBmp14:lStretch := .F.
oBmp14:lAutoSize := .F.

oChk15 := TCHECKBOX():Create(oDlg)
oChk15:cName := "oChk15"
oChk15:cCaption := "Preview"
oChk15:nLeft := 22
oChk15:nTop := 217
oChk15:nWidth := 176
oChk15:nHeight := 20
oChk15:lShowHint := .F.
oChk15:lReadOnly := .F.
oChk15:Align := 0
oChk15:cVariable := "lPreview"
oChk15:bSetGet := {|u| If(PCount()>0,lPreview:=u,lPreview) }
oChk15:lVisibleControl := .T.

oGrp15 := TGROUP():Create(oDlg)
oGrp15:cName := "oGrp15"
oGrp15:cCaption := "Copias "
oGrp15:nLeft := 22
oGrp15:nTop := 154
oGrp15:nWidth := 179
oGrp15:nHeight := 59
oGrp15:lShowHint := .F.
oGrp15:lReadOnly := .F.
oGrp15:Align := 0
oGrp15:lVisibleControl := .T.

oGet16 := TGET():Create(oDlg)
oGet16:cName := "oGet16"
oGet16:nLeft := 36
oGet16:nTop := 176
oGet16:nWidth := 154
oGet16:nHeight := 25
oGet16:lShowHint := .F.
oGet16:lReadOnly := .F.
oGet16:Align := 0
oGet16:cVariable := "nCopias"
oGet16:bSetGet := {|u| If(PCount()>0,nCopias:=u,nCopias) }
oGet16:lVisibleControl := .T.
oGet16:lPassword := .F.
oGet16:Picture := "999"
oGet16:lHasButton := .F.
oGet16:bValid := {|| nCopias > 0 }

oBmp16 := TBITMAP():Create(oDlg)
oBmp16:cName := "oBmp16"
oBmp16:cCaption := "oBmp16"
oBmp16:nLeft := 16
oBmp16:nTop := 325
oBmp16:nWidth := 380
oBmp16:nHeight := 22
oBmp16:lShowHint := .F.
oBmp16:lReadOnly := .F.
oBmp16:Align := 0
oBmp16:lVisibleControl := .T.
oBmp16:cResName := "PCOIMPR2"
oBmp16:lStretch := .F.
oBmp16:lAutoSize := .F.

oDetail := TSAY():Create(oDlg)
oDetail:cName := "oDetail"
oDetail:nLeft := 25
oDetail:nTop := 258
oDetail:nWidth := 365
oDetail:nHeight := 62
oDetail:lShowHint := .F.
oDetail:lReadOnly := .F.
oDetail:Align := 0
oDetail:cVariable := "cDescri"
oDetail:bSetGet := {|u| If(PCount()>0,cDescri:=u,cDescri) }
oDetail:lVisibleControl := .T.
oDetail:lWordWrap := .F.
oDetail:lTransparent := .F.

oConfig := SBUTTON():Create(oDlg)
oConfig:cName := "oConfig"
oConfig:nLeft := 411
oConfig:nTop := 108
oConfig:nWidth := 59
oConfig:nHeight := 22
oConfig:lShowHint := .F.
oConfig:lReadOnly := .F.
oConfig:Align := 0
oConfig:lVisibleControl := .T.
oConfig:nType := 6
oConfig:bLClicked := {|| oPrint:Setup() }

oSBtn19 := SBUTTON():Create(oDlg)
oSBtn19:cName := "oSBtn19"
oSBtn19:cCaption := "oSBtn19"
oSBtn19:nLeft := 411
oSBtn19:nTop := 138
oSBtn19:nWidth := 59
oSBtn19:nHeight := 22
oSBtn19:lShowHint := .F.
oSBtn19:lReadOnly := .F.
oSBtn19:Align := 0
oSBtn19:lVisibleControl := .T.
oSBtn19:nType := 17
oSBtn19:bWhen := {|| !Empty(aCondFil) }
oSBtn19:bLClicked := {|| PrtFilter() }

oSBtn20 := SBUTTON():Create(oDlg)
oSBtn20:cName := "oSBtn20"
oSBtn20:cCaption := "oSBtn20"
oSBtn20:nLeft := 411
oSBtn20:nTop := 170
oSBtn20:nWidth := 59
oSBtn20:nHeight := 22
oSBtn20:lShowHint := .F.
oSBtn20:lReadOnly := .F.
oSBtn20:Align := 0
oSBtn20:lVisibleControl := .T.
oSBtn20:nType := 11
oSBtn20:bWhen := {|| PgrInUse() }
oSBtn20:bLClicked := {|| (PgrEdit(@PcoPrtTit,oFormato:nOption,@nFontes),oFormato:Refresh(),oSayTit:Refresh()) }


oSBtn20 := SBUTTON():Create(oDlg)
oSBtn20:cName := "oSBtn20"
oSBtn20:cCaption := "oSBtn20"
oSBtn20:nLeft := 411
oSBtn20:nTop := 205
oSBtn20:nWidth := 59
oSBtn20:nHeight := 22
oSBtn20:lShowHint := .F.
oSBtn20:lReadOnly := .F.
oSBtn20:Align := 0
oSBtn20:lVisibleControl := .T.
oSBtn20:nType := 14
oSBtn20:bWhen := {|| PgrInUse() }
oSBtn20:bLClicked := {|| (PgrLoad(@PcoPrtTit,@oSayTit,@oFormato,oDLg),PgrLoadRfs(@PcoPrtTit,@oSayTit,@oFormato)) }


oSBtn20 := SBUTTON():Create(oDlg)
oSBtn20:cName := "oSBtn20"
oSBtn20:cCaption := "oSBtn20"
oSBtn20:nLeft := 411
oSBtn20:nTop := 240
oSBtn20:nWidth := 59
oSBtn20:nHeight := 22
oSBtn20:lShowHint := .F.
oSBtn20:lReadOnly := .F.
oSBtn20:Align := 0
oSBtn20:lVisibleControl := .T.
oSBtn20:nType := 13
oSBtn20:bLClicked := {|| SaveRel() }



oDlg:Activate()

Return lRet





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXIMP   ºAutor  ³Carlos A. Gomes Jr. º Data ³  16/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de atualização do Titulo do Relatorio               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function SetPrtTit(cNewTitulo)

Default cNewTitulo := PcoPrtTit

PcoPrtTit := cNewTitulo

Return


Function SetPapel(nPapel)

nTpPaper	:= nPapel

Return


Static Function PrintNew(cTitulo)

aAdd(aSave,{"NEW",cTitulo})
	
Return TMSPrinter():New( cTitulo )


Static Function PrintLandScape()

aAdd(aSave,{"SETLAND"})

Return oPrint:SetLandscape()


Static Function PrintPortrait()

aAdd(aSave,{"SETPORT"})

Return oPrint:SetPortrait()

Static Function PrintBox(nPosY,nPosX,nAltura,nTamanho)

aAdd(aSave,{"PRINTBOX",nPosY,nPosX,nAltura,nTamanho})

Return oPrint:Box(nPosY,nPosX,nAltura,nTamanho)


Static Function PrintBmpBox(nPosY ,nPosX ,nColor,nTamanho,nAltura)
Local cBmp

cBmp := OnePixBmp(ConvRGB(nColor),,"PMSBMP")

aAdd(aSave,{"PRINTBMPBOX",nPosY ,nPosX ,nColor,nTamanho,nAltura})

Return oPrint:SayBitmap( nPosY ,nPosX ,cBmp,nTamanho,nAltura)

Static Function PrintSay(nPosY,nPosX,cSay,aPrintFonte)

aAdd(aSave,{"PRINTSAY",nPosY,nPosX,cSay,aPrintFonte})

Return oPrint:Say(nPosY,nPosX,cSay,aFontes[aPrintFonte[1],aPrintFonte[2]] )


Static Function PrintImage( nPosY ,nPosX ,cImage,nTamanho,nAltura)

aAdd(aSave,{"PRINTIMAGE",nPosY ,nPosX ,LoadBmp(cImage),nTamanho,nAltura,cImage})

Return oPrint:SayBitmap( nPosY ,nPosX ,cImage,nTamanho,nAltura)

Static Function PrintLine(nPosY,nPosX,nAltura,nTamanho)

aAdd(aSave,{"PRINTLINE",nPosY,nPosX,nAltura,nTamanho})

Return oPrint:Line(nPosY,nPosX,nAltura,nTamanho)


Static Function PrintEndPage()

aAdd(aSave,{"ENDPAGE"})	

Return oPrint:EndPage()

Static Function PrintStartPage()

aAdd(aSave,{"STARTPAGE"})	

Return oPrint:StartPage()


Function PgrSpool()

Local aLoad	:= {}
Local cFile := SPACE(250)
Local oDlg
Local aRet	:= {}
Private cCadastro := STR0026 //"Spool de Relatórios Gráficos"

MakeDir(SuperGetMV('MV_RELT'))
cDirIni := "SERVIDOR"+SuperGetMV('MV_RELT')



DEFINE MSDIALOG oDlg FROM 51 ,40  TO 465,443 TITLE 'spool' Of oMainWnd PIXEL

	oPanel := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,1245,23,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	@ 4, 12 BITMAP RESNAME "PCOSPOOL" oF oPanel SIZE 300,300  WHEN .F. PIXEL NOBORDER

   @ 41 ,9   SAY STR0027 Of oPanel PIXEL SIZE 40 ,9   //'Arquivo'

   @ 40 ,38  MSGET cFile Valid AtuFile(@oPanel2,cFile,aLoad) OF oPanel PIXEL HASBUTTON SIZE 115,9

   @ 40 ,153 BUTTON STR0028 SIZE 35 ,11  FONT oPanel:oFont ACTION (cFile := cGetFile(STR0029, STR0030,0,"SERVIDOR"+GetMv("MV_RELT"),.T.,GETF_LOCALHARD+GETF_LOCALFLOPPY),AtuFile(@oPanel2,cFile,aLoad)  ) OF oPanel PIXEL  //'Procurar' #"Arquivos .PGS |*.PGS"#"Selecionar Arquivo"

	oPanel2 := TPanel():New(62,12,'',oDlg, oDlg:oFont, .T., .T.,, ,180,125,.T.,.T. )


   DEFINE SBUTTON FROM 193,128 TYPE 6   ACTION (If(File(cFile),RptStatus( {|| AuxLoad(aLoad) }),Nil)) ENABLE OF oPanel
   DEFINE SBUTTON FROM 193,160 TYPE 2   ACTION oDLg:End() ENABLE OF oPanel

	oDlg:lMaximized := .F.
ACTIVATE MSDIALOG oDlg


Return 

Static Function AtuFile(oPanel,cFile,aLoad)

Local aInfo
Local nx          

aLoad := {}      

MsFreeObj(oPanel,.T.)

If !(".PGS"$UPPER(cFile)) .And. !Empty(cFile)
		cFile := AllTrim(cFile)+".PGS"
	EndIf
	If !("\"$cFile)
		cFile := SuperGetMV('MV_RELT')+cFile
	EndIf
	If File(cFile)
		aLoad		:= __VRestore(cFile)
		If aLoad[1,1] == "PGREPORT1.1" 
			aInfo := {{STR0027,AllTrim(cFile)},{STR0031,aLoad[1,3,1]},{STR0032,aLoad[1,3,2]},{STR0033,aLoad[1,3,3]},{STR0034,aLoad[1,3,4]},{STR0035,aLoad[1,3,5]},{STR0036,aLoad[1,3,7]},{STR0037,""}}
			For nx := 1 to Len(aLoad[1,3,6])
				aAdd(aInfo,{aLoad[1,3,6,nx,1],aLoad[1,3,6,nx,2]})
			Next nx
			PmsDispBox(aInfo,2,"",{65,100},,1,RGB(230,230,255),RGB(240,240,240),oPanel,1,1,.T.,"")	
		Else
			AViso(STR0038,STR0039,{STR0040},2) // "Arquivo incompativel!"#"O arquivo selecionado não é compativel com este visualizador. Verifique o arquivo selecionado e a sua integridade."
		EndIf  
	EndIf
	
	
Return


Static Function SaveRel()
Local aRet := {}
Local cCodUsr := RetCodUsr()
Private cCadastro := STR0041 // "Salvar relatorio em disco"

If Empty(cNameSave)
	Do Case 
		Case SuperGetMv("MV_PGRSAVE",.F.,"1") == "1"
			cNameSave := AllTrim(PcoPrtTit)
		Case SuperGetMv("MV_PGRSAVE",.F.,"1") == "2"
			cNameSave := AllTrim(PcoPrtTit)+" "+Str(Day(MsDate()),2)+"_"+Str(Month(MsDate()),2)+"_"+Str(Year(MsDate()),4)+" "+Substr(Time(),1,2)+"h"+Substr(Time(),4,2)+"m "+AllTrim(cPrtPerg)
		Case SuperGetMv("MV_PGRSAVE",.F.,"1") == "3"			
			cNameSave := UsrRetName(cCodUsr)+" "+AllTrim(PcoPrtTit)+" "+Str(Day(MsDate()),2)+"_"+Str(Month(MsDate()),2)+"_"+Str(Year(MsDate()),4)+" "+Substr(Time(),1,2)+"h"+Substr(Time(),4,2)+"m "+AllTrim(cPrtPerg)
	EndCase
EndIf
	
If ParamBox({	{6,STR0042,Padr(cNameSave,220),"","","", 95 ,.T.,STR0029,""} },STR0030,@aRet,,,,,,,,.F.) //"Salvar Como"
	cNameSave := aRet[1]
EndIf

Return


Static Function LoadBmp(cBmp,lArray)

Local nRead	:= 0
Local cRet	:= ''
Local cLoad	:= ''
DEFAULT lArray := .F.

nBmp := FOpen(cBmp)
If nBmp != -1
	If lArray // Quebra em blocos ( array ) 
		cRet := {}
		nMax := fSeek(nBmp,0,2)	
		While nRead < nMax
			fSeek(nBmp,0,nRead)
			fRead(nBmp,@cLoad,1024)
			aAdd(cRet,cLoad)
			nRead+= 1024
		End
	Else
		nMax := fSeek(nBmp,0,2)
		fSeek(nBmp,0,0)
		FRead(nBmp,@cRet,nMax)
	EndIf
	
	fClose(nBmp)
EndIf
Return cRet	


Static Function AuxLoad(aLoad)
Local cBmp
Local nx
Local aFilesErase	:= {}


SetRegua(Len(aLoad))
If !Empty(aLoad) .And. aLoad[1,1] == "PGREPORT1.1" 
	If aLoad[1,2] == 1
		aAdd(aFontes,{TFont():New("Courier New",03,06,,.T.,,,,.T.,.F.),16})
		aAdd(aFontes,{TFont():New("Courier New",06,08,,.T.,,,,.T.,.F.),18})
		aAdd(aFontes,{TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.),22})
		aAdd(aFontes,{TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.),5})                                   
		aAdd(aFontes,{TFont():New("Courier New",15,15,,.T.,,,,.T.,.F.),6})
		aAdd(aFontes,{TFont():New("Courier New",20,20,,.T.,,,,.T.,.F.),7})

		aAdd(aFontes,{TFont():New("Courier New",03,06,,.F.,,,,.T.,.F.),16})
		aAdd(aFontes,{TFont():New("Courier New",06,08,,.F.,,,,.T.,.F.),18})

	Else
		aAdd(aFontes,{TFont():New("Arial",03,06,,.T.,,,,.T.,.F.),16})
		aAdd(aFontes,{TFont():New("Arial",06,08,,.T.,,,,.T.,.F.),18})
		aAdd(aFontes,{TFont():New("Arial",10,10,,.F.,,,,.T.,.F.),22})
		aAdd(aFontes,{TFont():New("Arial",10,10,,.T.,,,,.T.,.F.),5})
		aAdd(aFontes,{TFont():New("Arial",15,15,,.T.,,,,.T.,.F.),6})
		aAdd(aFontes,{TFont():New("Arial",20,20,,.T.,,,,.T.,.F.),7})

		aAdd(aFontes,{TFont():New("Arial",03,06,,.F.,,,,.T.,.F.),16})
		aAdd(aFontes,{TFont():New("Arial",06,08,,.F.,,,,.T.,.F.),18})

	EndIf
	IncRegua()

	For nx := 2 to Len(aLoad)
		IncRegua()
		Do Case
			Case aLoad[nx,1] == "NEW"
				oPrint := TMSPrinter():New( aLoad[nx,2] )
			Case aLoad[nx,1] == "SETLAND"
				oPrint:SetLandscape()
			Case aLoad[nx,1] == "SETPORT"
				oPrint:SetPortrait()	
			Case aLoad[nx,1] == "PRINTBOX"
				oPrint:Box(aLoad[nx,2],aLoad[nx,3],aLoad[nx,4],aLoad[nx,5])
			Case aLoad[nx,1] == 	"PRINTBMPBOX"						
				cBmp := OnePixBmp(ConvRGB(aLoad[nx,4]),,"PMSBMP")				
				oPrint:SayBitmap( aLoad[nx,2] ,aLoad[nx,3] ,cBmp,aLoad[nx,5],aLoad[nx,6])
			Case aLoad[nx,1] == 	"PRINTSAY"
				oPrint:Say(aLoad[nx,2],aLoad[nx,3],aLoad[nx,4],aFontes[aLoad[nx,5,1],aLoad[nx,5,2]] )
			Case aLoad[nx,1] == 	"PRINTIMAGE"
				cBmp := aLoad[nx,4]
				cFileBmp := CriaTrab(,.F.) // aLoad[nx,7]
				nHandBmp := MSfCreate(cFileBmp)
				fWrite(nHandBmp,cBmp,Len(cBmp))
				fClose(nHandBmp)
				oPrint:SayBitmap( aLoad[nx,2] ,aLoad[nx,3] ,cFileBmp,aLoad[nx,5],aLoad[nx,6])
				aAdd(aFilesErase,cFileBmp)
			Case aLoad[nx,1] == 	"PRINTLINE"
				oPrint:Line(aLoad[nx,2],aLoad[nx,3],aLoad[nx,4],aLoad[nx,5])
			Case aLoad[nx,1] == 	"ENDPAGE"
				oPrint:EndPage()
			Case aLoad[nx,1] == 	"STARTPAGE"		
				oPrint:StartPage()
		EndCase
	Next nx
	oPrint:Preview()

	For nx := 1 to Len(aFilesErase)
		fErase(aFilesErase[nx])
	Next
EndIf	

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCORepDef ºAutor  ³ Gustavo Henrique  º Data ³  08/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Define as secoes do relatorio personalizavel a partir      º±±
±±º          ³ dos niveis do cubo selecionado.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPO1 - Objeto TReport                                     º±±
±±º          ³ EXPC2 - Codigo do cubo selecionado no pergunte PCRCUB      º±±
±±º          ³ EXPA3 - Array com os dados dos niveis do cubo selecionado  º±±
±±º          ³ EXPA4 - Array com os objetos TRSection para cada nivel     º±±
±±º          ³         do cubo selecionado.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ EXPA1 - Array com os objetos das secoes criadas            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle Orcamentario                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoTRCubo( oReport, cCubo, aNiveis, aSections,lShowHeader )
                             
Local oObjSec

Local aArea 	:= GetArea()
Local nSecAtu	:= 0			// Posicao do objeto TRSection atual do array aSections
DEFAULT lShowHeader	:=	.T.
If !Empty( cCubo )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Percorre tabela com os niveis do cubo, criando o array aSections com a colecao de objetos de secoes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('AKW')
	dbSetOrder(1)
	
	MsSeek( xFilial() + cCubo )

	While !Eof() .And. AKW_FILIAL + AKW_COD == xFilial() + cCubo
	
		If Len( aSections ) == 0
			oObjSec := oReport
		Else
			oObjSec := oObjSec:Section(1)
		EndIf				
		                                                                                                    
		AAdd( aSections, TRSection():New( oObjSec, AllTrim(AKW_CONCDE), {AKW_ALIAS} ))

		              
		nSecAtu := Len(aSections)

		aSections[nSecAtu]:ShowHeader(lShowHeader)

		aSections[nSecAtu]:SetNoFilter({AKW_ALIAS})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso tenha mais de um campo no mesmo nivel de cubo, cria o nome das celulas com a  ³
		//³ descricao do nivel do cubo (AKW_DESCRI)                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If "+" $ AKW_RELAC
			   
			TRCell():New( aSections[nSecAtu], AllTrim(AKW_DESCRI),,AKW_DESCRI,/*Picture*/,/*Tamanho*/,/*lPixel*/,)	// Codigo
			TRCell():New( aSections[nSecAtu], "DESCRICAO_"+AllTrim(AKW_DESCRI),,STR0019,/*Picture*/,/*Tamanho*/,/*lPixel*/,)	// Descricao
			AAdd( aNiveis, {	AKW->AKW_ALIAS,;
								AllTrim(AKW_DESCRI),;
								"DESCRICAO_"+AllTrim(AKW_DESCRI),;
								AKW->AKW_TAMANH,;
								AKW->AKW_DESCRI } )
		Else
			TRCell():New( aSections[nSecAtu], Alltrim(StrTran(AKW_RELAC,AKW_ALIAS+"->","")),,AKW_DESCRI,/*Picture*/,,/*lPixel*/, )	// Codigo
			TRCell():New( aSections[nSecAtu], Alltrim(StrTran(AKW_DESCRE,AKW_ALIAS+"->","")),,STR0019,/*Picture*/,/*Tamanho*/,/*lPixel*/,)	// Descricao
			AAdd( aNiveis, {	AKW->AKW_ALIAS,;
								Alltrim(StrTran(AKW_RELAC,AKW_ALIAS+"->","")),;
								Alltrim(StrTran(AKW_DESCRE,AKW_ALIAS+"->","")),;
								AKW->AKW_TAMANH,;
								AKW->AKW_DESCRI } )
		EndIf
                            
		dbSkip()
		
	EndDo

EndIf
	
RestArea( aArea )

Return
Static Function ImpSX1(cFileLogo)
Local	lImp	:=	.F.
Local cAlias	:=	''
Local aBkpCols	:=	aClone(aSetCols)
Local nLin		:=	220                      
Local cPicture
Local nMaxCalc

DEFAULT cFileLogo  := "LGRL"+SM0->M0_CODIGO+cFilAnt+".BMP"
           
If !File( cFileLogo )
	cFileLogo := "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
Endif

If GetMv("MV_IMPSX1") == "S" .and. Substr(cAcesso,101,1) == "S"
	cAlias := Alias()
	DbSelectArea("SX1")
	DbSeek(cPrtPerg)                         
	If nPcoPrtFor == 2 
		nMaxCalc :=  aPaperSize[nTpPaper][1]
	Else
		nMaxCalc :=  aPaperSize[nTpPaper][2]
	Endif	
	// Inicio cabecalho
	PrintStartPage()
	PrintImage(30,30, cFileLogo,474,117)
	If nPcoPrtFor == 2 
		PrintSay(100,(aPaperSize[nTpPaper][1]/2)-(PcoPrtSize(Alltrim(PcoPrtTit),5)/2),AllTrim('Parametros - '+PcoPrtTit),{5,1})
	Else
		PrintSay(100,(aPaperSize[nTpPaper][2]/2)-(PcoPrtSize(Alltrim(PcoPrtTit),5)/2),AllTrim('Parametros - '+PcoPrtTit),{5,1})
	EndIf
	PrintSay(146,30,QA_CHKFIL(cFilAnt,,.T.),{3,1} )
	If nPcoPrtFor == 2 
		PrintSay(146,aPaperSize[nTpPaper][1]-425,STR0007+DTOC(dDataBase),{3,1}) //"Data Base : "
		PrintLine(190, 20, 190, aPaperSize[nTpPaper][1] )
		PrintLine(191, 20, 191, aPaperSize[nTpPaper][1] )
	Else
		PrintSay(146,aPaperSize[nTpPaper][2]-425,STR0007+DTOC(dDataBase),{3,1}) //"Data Base : "
		PrintLine(190, 20, 190, aPaperSize[nTpPaper][2] )
		PrintLine(191, 20, 191, aPaperSize[nTpPaper][2] )
	Endif      
	// Fim cabecalho

	PcoPrtCol({30,900,nMaxCalc-40},.F.,2)  
	While !EOF() .AND. X1_GRUPO = cPrtPerg
		cVar := "MV_PAR"+StrZero(Val(X1_ORDEM),2,0)
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60, "Pergunta "+ X1_ORDEM + " : "+ AllTrim(X1Pergunt()) ,oPrint,1,4,/*RgbColor*/)
		If X1_GSC == "C"
			xStr:=StrZero(&cVar,2)
			//@ nLin,Pcol()+3 PSAY Iif(&(cVar)>0,X1_DEF&xStr,"")
			If ( &(cVar)==1 )
				PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60, X1Def01() ,oPrint,1,4,/*RgbColor*/)
			ElseIf ( &(cVar)==2 )                                                  
				PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60, X1Def02() ,oPrint,1,4,/*RgbColor*/)
			ElseIf ( &(cVar)==3 )
				PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60, X1Def03() ,oPrint,1,4,/*RgbColor*/)
			ElseIf ( &(cVar)==4 )
				PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60, X1Def04() ,oPrint,1,4,/*RgbColor*/)
			ElseIf ( &(cVar)==5 )
				PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60, X1Def05() ,oPrint,1,4,/*RgbColor*/)
			EndIf
		Else
			uVar := &(cVar)
			If ValType(uVar) == "N"
				cPicture:= "@E "+Replicate("9",X1_TAMANHO-X1_DECIMAL-1)
				If( X1_DECIMAL>0 )
					cPicture+="."+Replicate("9",X1_DECIMAL)
				Else
					cPicture+="9"
				EndIf
				PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60, TransForm(&(cVar),cPicture) ,oPrint,1,4,/*RgbColor*/)
			ElseIf ValType(uVar) == "D"
				PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60, Dtoc(&(cVar)) ,oPrint,1,4,/*RgbColor*/)
			ElseIf ValType(uVar) == "L"
				PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60, Iif(&(cVar),'.T.','.F.') ,oPrint,1,4,/*RgbColor*/)
			Else
				PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60, &(cVar) ,oPrint,1,4,/*RgbColor*/)
			EndIf
		EndIf
		DbSkip()
		nLin+=70
	End
	DbSelectArea(cAlias)
	lImp	:=	.T.
EndIf
aSetCols 	:=	aClone(aBkpCols)
Return lImp
