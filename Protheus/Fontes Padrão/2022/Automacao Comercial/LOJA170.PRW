#INCLUDE "LOJA170.CH"
#INCLUDE "FIVEWIN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ LojA170	³ Autor ³ Fernando Godoy	     ³ Data ³ 16/10/96³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Leitura X 									        	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA     ³ BOPS ³Prograd.³ALTERACAO                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³23/06/05  ³083499³Marcos  ³Incluido a funcao LJVLDSERIE para verificar ³±±
±±³          ³      ³        ³se o nro de serie do ECF conectado e o mesmo³±± 
±±³          ³      ³        ³cadastrado na estacao                       ³±±
±±³05/04/07  ³122711³Conrado ³Alterada a utilização da chamada            ³±±
±±³          ³      ³        ³SubStr(cUsuario,7,15) por cUserName         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LojA170

LOCAL nOpca 		:= 0
LOCAL oDlg
Local cImpressora := LJGetStation("IMPFISC")
Local cLock 		:= cUserName+cEstacao  
Local lRet			:= .T.  // Retorno da funcao
Local nHandle     	:= -1
Local lEmitNfce	  	:= FindFunction("LjEmitNFCe") .AND.  LjEmitNFCe()								// Sinaliza se utiliza NFC-e						
Local lIsMDI 		:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),SetMDIChild(0)) //Verifica se acessou via SIGAMDI

Private cCadastro := OemToAnsi(STR0001)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre a impressora fiscal - FATURAMENTO                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModulo == "FAT"
	If Type("nHdlECF") == "U" .Or. nHdlECF == -1
  		nHandle := IFAbrir(SuperGetMv("MV_IMPFIS"),SuperGetMv("MV_PORTFIS"))
    	Private lFiscal := nHandle >= 0
  EndIf
Else
	If type("nHdlECF") == "N"
		nHandle := nHdlECF
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o controle via LockByName para evitar que um usuário acesse       ³
//³ 2 vezes uma rotina que use os periféricos de automação, evitando assim³
//³ a concorrência dos mesmos.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIsMDI .And. !LockByName( cLock )
	lRet := .F.
Else
	If !lFiscal
		//Para Emitir a Leitura X da Impressora fiscal, deve-se
		//estar cadastrado como usu rio fiscal e com os parƒmetros da impressora corretos.
		//Aten‡„o
		MsgStop(Oemtoansi(STR0002)+;
		Oemtoansi(STR0003),;
		Oemtoansi(STR0004))
		lRet := .F.
	ElseIf lEmitNfce
		MsgInfo( STR0012 + Chr(10) + STR0013 )	//"A Leitura X está disponível apenas para Emissor de Cupom Fiscal (ECF) configurado."  ## "Não há emissão em Equipamento não fiscal com NFC-e."				 
		lRet := .F.	
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Consiste o numero de serie do equipamento conforme arq. sigaloja.bin ³ 
		//³somente se o parametro MV_LJNSECF = .T.                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	LJVLDSERIE()
			DEFINE MSDIALOG oDlg FROM 39,85 TO 210,340 TITLE OemToAnsi(cCadastro) PIXEL OF oMainWnd
			DEFINE FONT oFont NAME "Ms Sans Serif" BOLD
			// Objetivo do Programa
			@ 7, 4 TO 60, 121 LABEL STR0005 OF oDlg PIXEL
			
			// Este programa tem como
			// objetivo efetuar	a	impress„o	do
			// cupom de leitura impressora fiscal
			@ 19, 15 SAY OemToAnsi(STR0006 +STR0007 +STR0008 + cImpressora + ".") SIZE 100, 40 OF oDlg PIXEL FONT oFont
			DEFINE SBUTTON FROM 65, 65 TYPE 1;
			ACTION (nOpca := 1,IF(MsgYesNo( OemToAnsi(STR0010),OemToAnsi(STR0011) ),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
			DEFINE SBUTTON FROM 65, 94 TYPE 2;
			ACTION oDlg:End() ENABLE OF oDlg
			
			ACTIVATE MSDIALOG oDlg CENTERED
			
			If nOpca == 1
				If LjProfile( 21 )
					Processa({|lEnd| IFLeituraX( nHandle )})
				EndIf
			Endif
			oFont:End()
		EndIf
	EndIf	
EndIf

If cModulo == "FAT"
	nHandle := IFFechar(nHandle, SuperGetMv("MV_PORTFIS"))
EndIf

Return lRet
