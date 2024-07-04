#include "Protheus.ch"
#include "Psal.ch"
#define PULA CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PSAL     ³ Autor      ³ Cristina Ogura        ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Sistema de Pesquisa Salarial e Beneficios                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³BOPS       ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³17/07/14³TPZVTW     ³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³           ³ada a limpeza.                            ³±±
±±³Flavio C.   ³02/01/17³MRH-48     ³Tratamento para não dar error.log quando o³±±
±±³            ³        ³           ³arquivo não tem o registro 30             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
// Funcao principal da Coleta Automatizada
// nChamada = 	1 - Chamada do executavel fora do SIGA
// 				2 - Chamada de dentro do SIGA	
Function PSAL(nMandou)
Local oDlgMain
Local oBtnOk
Local oBmp
Local nLinTotal
Local cDescMemo	:= ""
Local cAuxMemo	:= ""
Local aRmk		:= {}
Local oBar, oMemo
Local oIcon
Local lTela		:= .F. 
Local lRet		:= .T.
Local nx		:= 0 

Local n2HdlArq	:= 0
Local c2File	:= "" 
Local lFile1Fecha := .F.
Local lFile2Fecha := .F.
Local bSet15
Local bSet24
Local aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

Private oPSalMenu
Private oFont, oFont1, oFont2
Private aApresent	:= {}
Private aEmpresas	:= {}
Private aSelecionada:= {}
Private a1Cargos	:= {}			
Private a2Cargos	:= {}
Private a3Cargos	:= {}
Private aCargosInf	:= {}
Private aSX5		:= {}
Private aRC			:= {}
Private aRD			:= {}
Private aRE			:= {}
Private aPatroc		:= {}
Private cPesq		:= ""
Private cEmpresa	:= ""
Private cFile       := ""
Private nHdlArq 	:= 0
Private nChamada	:= 0
Private lFechado	:= .F. 

//-- Tratamento de Leitura de arquivo
Private cCRLF   //Fim da linha
Private nTam	//Tamanho da linha do arquivo texto

SetHandleCount(255)

nChamada := If(nMandou==Nil,1,nMandou)

If nMandou == 1
	SET DELETE ON
	SET DATE BRITISH
	SET AUTOPEN OFF
EndIf

cCRLF := CHR(13)+CHR(10)  	//Windows  
nTam:= 202

cFile := "PSAL.TXT"

If !FILE(cFile)
	FMens(STR0001,STR0002,{STR0003}) //"Verifique"###"Arquivo da Pesquisa Salarial nao selecionado (PSAL.TXT). O arquivo deve estar no mesmo diretorio do executavel"###"Sair"
	lRet:= .F.
Else
	nHdlArq:=FOPEN(cFile,2+16)		//2+16 Leitura e gravacao - exclusivo
	IF Ferror() <> 0
		FMens(STR0001,STR0265 + cFile + CRLF + alltrim(str(Ferror())) ,{STR0003})	 //"Verifique"###"Erro na abertura do arquivo: "###"Sair"
		lRet:= .F.
    Else
	    lFile1Fecha	:= .T.
    Endif
    
EndIf
 
IF lRet

	IF ( lRet:=FLeArq(@n2HdlArq, @c2File, @lFile2Fecha)	)

		// Fecho e apago o arquivo PSAL.TXT. 
		FClose(nHdlArq)            
		FErase(cFile)                    
		lFile1Fecha	:= .F.
		
		// Fecho e renomeio o PSAL.BKP para PSAL.TXT
		FClose(n2HdlArq)                        
		lFile2Fecha	:= .F.
		FRename(c2File,"PSAL.TXT")
					
		If FILE(cFile)
			nHdlArq:=FOPEN(cFile,2+16)		//2+16 Leitura e gravacao - exclusivo
			IF Ferror() <> 0       
			    //-- Estamos emitido a mensagem com c2File para saber qual o arquivo que nao foi aberto
				FMens(STR0001,STR0265 + c2File + CRLF + alltrim(str(Ferror())) ,{STR0003})	 //"Verifique"###"Erro na abertura do arquivo: "###"Sair"
				lRet:= .F.
		    Else
			    lFile1Fecha	:= .T.
		    Endif
		    
		EndIf
				
	Endif
	
	If lRet 

		FLeSX5()
		
			For nx:=1 To Len(aApresent)
				cDescMemo := cDescMemo + aApresent[nx]
			Next nx
			
			DEFINE FONT oFont  	NAME "Ms Sans Serif" SIZE 0,-12 BOLD
			DEFINE FONT oFont1 	NAME "Ms Sans Serif" SIZE 0,-9 BOLD
			DEFINE FONT oFont2 	NAME "Ms Sans Serif" SIZE 0,-9
			DEFINE ICON oIcon	RESNAME "SETUP" 
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Monta as Dimensoes dos Objetos         					   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			aAdvSize		:= MsAdvSize()
			aAdvSize[5]	:=	(aAdvSize[5]/100) * 85	//horizontal
			aAdvSize[6]	:=  (aAdvSize[6]/100) * 85	//Vertical
			aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
			aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
			aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
			aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*75), (((aObjSize[1,4])/100)*83) }	//1,3 Vertical /1,4 Horizontal
			
			If nChamada == 1
				DEFINE WINDOW oDlgMain TITLE "PSAL" FROM 85,70 TO 510,720 PIXEL ICON oIcon
				
				oDlgMain:oFont := oFont
				oDlgMain:SetColor(CLR_BLACK,CLR_HGRAY)
			
				If nChamada == 1
					@ 10,500 BITMAP oBmp RESNAME "LOGOSIGA" PIXEL OF oDlgMain SIZE 140,20 NOBORDER 
				EndIf	
				
				@ 10,20 SAY STR0005 PIXEL OF oDlgMain SIZE 350,20 //"PSAL - SISTEMA DE PESQUISA SALARIAL E BENEFICIOS"
				@ 30,20 TO 380,530 PIXEL
				
				@ 60,50	GET oMemo VAR cDescMemo MEMO SIZE 460,300 PIXEL OF oDlgMain READONLY
				
				@ 150,550 BUTTON oBtnOk PROMPT "&Ok" SIZE 70,20 PIXEL OF oDlgMain FONT oFont1;
				ACTION (FOK(),oDlgMain:End())
				
				ACTIVATE WINDOW oDlgMain ON INIT oBtnOk:SetFocus(.t.)
			Else 
				DEFINE DIALOG oDlgMain  FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL FONT oFont 
			
					@ aGdCoord[1],aGdCoord[4]-70 BITMAP oBmp FILENAME "LOGOSIGA.BMP" PIXEL OF oDlgMain SIZE 70,12 NOBORDER 
				
					@ aGdCoord[1],aGdCoord[2]+5 SAY STR0005 PIXEL OF oDlgMain SIZE 200,10 //"PSAL - SISTEMA DE PESQUISA SALARIAL E BENEFICIOS"
					@ aGdCoord[1]+15,aGdCoord[2]+5 TO aGdCoord[3],aGdCoord[4] PIXEL
				
					@ aGdCoord[1]+20,aGdCoord[2]+10 GET oMemo VAR cDescMemo MEMO SIZE aGdCoord[4]-20,aGdCoord[3]-30 PIXEL OF oDlgMain READONLY
				    
					bSet15 := {|| (FOK(),lTela:=.T.,oDlgMain:End())}
					bSet24 := {|| oDlgMain:End()}
					
				ACTIVATE DIALOG oDlgMain CENTERED ON INIT EnchoiceBar( oDlgMain , bSet15 , bSet24 , Nil , aButtons ) VALID lTela
			EndIf
	Endif	
Endif


//Garante o fechamento dos arquivos baixos
// Fecha o arquivo PSAL.TXT 
IF lFile1Fecha	
	FClose(nHdlArq) 
Endif

// Fecha o arquivo PSAL.bkp 
IF lFile2Fecha	
	FClose(n2HdlArq) 
Endif		

Return lRet

// Funcao quando Ok na tela de apresentacao do texto
Function FOK()
Local oDlg, oBmp
Local cPatroc
Local bSet15
Local bSet24
Local aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

Private lRet:= .F.

If Len(aPatroc) > 0
	cPatroc := aPatroc[1][2]
Else
	cPatroc := STR0006 //"Nao Informado Empresa Patrocinadora"
EndIf
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 85	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 85	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*75), (((aObjSize[1,4])/100)*83) }	//1,3 Vertical /1,4 Horizontal

aAdd(aButtons, { "POSCLI", { || FPatroc() } , OemToAnsi(STR0008) } ) //"Dados Patrocinador"
aAdd(aButtons, { "BMPUSER", { ||  FSelecao()} , OemToAnsi(STR0010) } ) //"Empresas Participantes"
aAdd(aButtons, { "NOTE", { ||  FColeta()} , OemToAnsi(STR0012) } ) //"Coleta de Dados"
aAdd(aButtons, { "CADEADO", { ||  FFechar(2)} , OemToAnsi(STR0014) } ) //"Fechar Pesquisa"
//"Atencao"###"Opcao ainda nao disponivel."###"Sair"
aAdd(aButtons, { "BUDGETY", { ||  FMens(STR0017,STR0018,{STR0003})} , OemToAnsi(STR0016) } ) //"Resultado Pesquisa"
//"Atencao"###"Opcao ainda nao disponivel."###"Sair"
aAdd(aButtons, { "RELATORIO", { ||  FMens(STR0017,STR0018,{STR0003})} , OemToAnsi(STR0020) } ) //"Relatorio"
//"Atencao"###"Opcao ainda nao disponivel."###"Sair"
aAdd(aButtons, { "BAR", { ||  FMens(STR0017,STR0018,{STR0003})} , OemToAnsi(STR0027) } ) //"Grafico"
aAdd(aButtons, { "S4WB016N", { ||  FLeHelp(15)} , OemToAnsi(STR0028) } ) //"Ajuda"
aAdd(aButtons, { "SUGESTAO", { ||  FSobre()} , OemToAnsi(STR0029) } ) //"Sobre"
		 
bSet15 := {|| FFechar(2)}
bSet24 := {|| (If(FSair(),(lRet:= .T.,oDlg:End()),))}	
	
DEFINE DIALOG oDlg TITLE STR0026 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL FONT oFont2 //"PSAL - Sistema de Pesquisa Salarial e Beneficio"

	If nChamada == 1
		@aGdCoord[1],aGdCoord[4]-70 BITMAP oBmp RESNAME "LOGOSIGA" PIXEL OF oDlg SIZE 70,12 NOBORDER
	EndIf	

	@aGdCoord[1]+5,aGdCoord[2]+5 SAY STR0007+ cPatroc PIXEL FONT oFont1 SIZE 200,7 //"Patrocinadora: "

ACTIVATE DIALOG oDlg VALID lRet CENTERED ON INIT EnchoiceBar(oDlg, bSet15, bSet24, Nil, aButtons)
        
// Funcao que monta o toolbar da Pesquisa
Function FPesqBar(oDlgMain)
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local oBtn5
Local oBtn6
Local oBtn7
Local oBtn8
Local oBtn9
Local oBtn10

DEFINE BUTTONBAR oBar OF oDlgMain PIXEL
DEFINE BUTTON oBtn1 OF oBar RESNAME "POSCLI";	//"RESPONSA";
		 TOOLTIP STR0008; //"Dados Patrocinador"
		 ACTION FPatroc() PIXEL 
		 oBtn1:cTitle := OemToAnsi(STR0009) //"Patroc."
	 
DEFINE BUTTON oBtn2 OF oBar RESNAME "BMPUSER";
		 TOOLTIP STR0010; //"Empresas Participantes"
		 ACTION FSelecao() PIXEL             
 		 oBtn2:cTitle := OemToAnsi(STR0011)  //"Empresa"
		 
DEFINE BUTTON oBtn3 OF oBar RESNAME "NOTE";
		 TOOLTIP STR0012; //"Coleta de Dados"
		 ACTION FColeta() PIXEL 
		 oBtn3:cTitle := OemToAnsi(STR0013) //"Coleta"

DEFINE BUTTON oBtn4 OF oBar RESNAME "CADEADO";
		 TOOLTIP STR0014; //"Fechar Pesquisa"
		 ACTION FFechar(2) PIXEL 
		 oBtn4:cTitle := OemToAnsi(STR0015) //"Fechar"

DEFINE BUTTON oBtn5 OF oBar RESNAME "BUDGETY";
		 TOOLTIP STR0016; //"Resultado Pesquisa"
		 ACTION FMens(STR0017,STR0018,{STR0003}) PIXEL //"Atencao"###"Opcao ainda nao disponivel."###"Sair"
		 oBtn5:cTitle := OemToAnsi(STR0019) //"Result."

DEFINE BUTTON oBtn6 OF oBar RESNAME "RELATORIO";
		 TOOLTIP STR0020; //"Relatorio"
		 ACTION FMens(STR0017,STR0018,{STR0003}) PIXEL      //"Atencao"###"Opcao ainda nao disponivel."###"Sair"
		 oBtn6:cTitle := OemToAnsi(STR0020) //"Relatorio"
		 
DEFINE BUTTON oBtn7 OF oBar RESNAME "BAR";
		 TOOLTIP STR0027; //"Grafico"
		 ACTION FMens(STR0017,STR0018,{STR0003}) PIXEL		  //"Atencao"###"Opcao ainda nao disponivel."###"Sair"
		 oBtn7:cTitle := OemToAnsi(STR0027) //"Grafico"
		 
DEFINE BUTTON oBtn8 OF oBar RESNAME "S4WB016N";
		 TOOLTIP STR0028; //"Ajuda"
		 ACTION FLeHelp(15) PIXEL
		 		 
DEFINE BUTTON oBtn9 OF oBar RESNAME "SUGESTAO";
		 TOOLTIP STR0029; //"Sobre"
		 ACTION FSobre() PIXEL		 		 
		 
DEFINE BUTTON oBtn10 OF oBar RESNAME "FINAL";
		 TOOLTIP STR0003; //"Sair"
		 ACTION (If(FSair(),(lRet:= .T.,oDlgMain:End()),)) PIXEL		 		 		 

Return NIL

// Mostra os dados da Empresa Patrocinadora 
Function FPatroc()
Local oDlgP
Local oGroup
Local oBtnOk, oBtnHlp
Local cNomePatroc 	:= Space(50)
Local cEndPatroc	:= Space(30)
Local cCidPatroc	:= Space(30)
Local cEstPatroc	:= Space(02)
Local cConPatroc	:= Space(30)
Local cFonePatroc	:= Space(15)
Local cEmailPatroc	:= Space(60)
Local bSet15
Local bSet24
Local aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

If Empty(cPesq)
	FMens(STR0001,STR0002,{STR0003}) //"Verifique"###"Arquivo da Pesquisa Salarial nao selecionado (PSAL.TXT). O arquivo deve estar no mesmo diretorio do executavel"###"Sair"
	Return Nil
EndIf	

If Len(aPatroc) > 0
	cNomePatroc := aPatroc[1][2]
	cEndPatroc	:= aPatroc[1][3]
	cCidPatroc	:= aPatroc[1][4]
	cEstPatroc	:= aPatroc[1][5]
	cConPatroc	:= aPatroc[2][1]
	cFonePatroc	:= aPatroc[2][2]
	cEmailPatroc:= aPatroc[2][3]
Else
	cNomePatroc := STR0006 //"Nao Informado Empresa Patrocinadora"
EndIf
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 70	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 80	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*70), (((aObjSize[1,4])/100)*67) }	//1,3 Vertical /1,4 Horizontal

aAdd(aButtons, { Nil, { ||  FLeHelp(1)} , OemToAnsi(STR0040) } ) //"Help"
		 
bSet15 := {|| oDlgP:End()}
bSet24 := {|| oDlgP:End()}	


DEFINE DIALOG oDlgP TITLE OemtoAnsi(STR0030) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL FONT oFont2  //"Empresa Patrocinadora da Pesquisa Salarial"

@ aGdCoord[1],aGdCoord[2] GROUP oGroup TO aGdCoord[3],aGdCoord[4] LABEL STR0031 PIXEL  //"Dados da Empresa"

@ aGdCoord[1]+18,15 SAY STR0032 	PIXEL OF oDlgP //"   Razao Social: "
@ aGdCoord[1]+15,65 GET cNomePatroc				PIXEL SIZE 150,10 OF oDlgP WHEN .F.

@ aGdCoord[1]+33,15 SAY STR0033 	PIXEL OF oDlgP //"       Endereco: "
@ aGdCoord[1]+30,65 GET cEndPatroc				PIXEL SIZE 100,10 OF oDlgP WHEN .F.

@ aGdCoord[1]+48,15 SAY STR0034	PIXEL OF oDlgP //"           Cidade: "
@ aGdCoord[1]+45,65 GET cCidPatroc				PIXEL SIZE 50,10 OF oDlgP WHEN .F.

@ aGdCoord[1]+63,15 SAY STR0035 	PIXEL OF oDlgP //"           Estado: "
@ aGdCoord[1]+60,65 GET cEstPatroc				PIXEL SIZE 10,10 OF oDlgP WHEN .F.

@ aGdCoord[1]+78,15 SAY STR0036 	PIXEL OF oDlgP //"             Fone: "
@ aGdCoord[1]+75,65 GET cFonePatroc				PIXEL SIZE 50,10 OF oDlgP WHEN .F.

@ aGdCoord[1]+93,15 SAY STR0037 	PIXEL OF oDlgP //"          Contato: "
@ aGdCoord[1]+90,65 GET cConPatroc				PIXEL SIZE 100,10 OF oDlgP WHEN .F.

@ aGdCoord[1]+108,15 SAY STR0038 	PIXEL OF oDlgP //"            Email: "
@ aGdCoord[1]+105,65 GET cEmailPatroc			PIXEL SIZE 120,10 OF oDlgP WHEN .F.

ACTIVATE DIALOG oDlgP ON INIT EnchoiceBar(oDlgP, bSet15, bSet24, Nil, aButtons) CENTERED
Return Nil 

Function FSelecao()
	Local oDlgA, oLbx
	Local cRazao	:= Space(50)
	Local cPorte	:= Space(01)
	Local cContato	:= Space(30)
	Local cEmail	:= Space(60)
	Local cFone		:= Space(15)
	Local nFunc 	:= Space(06)	                       
	Local nLbx
	Local bSet15
	Local bSet24
	Local aButtons := {}
	Local nOpcHelp := 2  //Controla o Help que será exibido conforme a tela do momento
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de arrays para dimensionar tela		                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aGDCoord		:= {}
	
	Private cRegiao	:= "0000"
	Private cDRegiao:= Space(30)
	Private cFatur 	:= "000"
	Private cDFatur := Space(30)
	Private cAtivid	:= "000"
	Private cDAtivid:= Space(30)
	
	If lFechado
		FMens(STR0017,STR0041,{STR0003}) //"Atencao"###"Fechamento ja efetuado. Dados da Pesquisa nÆo pode ser mais alterado."###"Sair"
		Return Nil
	EndIf	
	
	If Empty(cPesq)
		FMens(STR0001,STR0002,{STR0003}) //"Verifique"###"Arquivo da Pesquisa Salarial nao selecionado (PSAL.TXT). O arquivo deve estar no mesmo diretorio do executavel"###"Sair"
		Return Nil
	EndIf
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aAdvSize[5]	:=	(aAdvSize[5]/100) * 70	//horizontal
	aAdvSize[6]	:=  (aAdvSize[6]/100) * 80	//Vertical
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
	aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*70), (((aObjSize[1,4])/100)*67) }	//1,3 Vertical /1,4 Horizontal
	
	aAdd(aButtons, { Nil, { ||  FLeHelp(2)} , OemToAnsi(STR0040) } ) //"Help"
	
	DEFINE DIALOG oDlgA TITLE OemtoAnsi(STR0042) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL FONT oFont2  //"Selecione sua Empresa"
       
		@ aGdCoord[1],aGdCoord[2] LISTBOX oLbx VAR nLbx FIELDS HEADER STR0043; //"Empresas"
											COLSIZES GetTextWidth(0,"W") SIZE aGdCoord[4],aGdCoord[3]-10 OF oDlgA PIXEL FONT oFont2
	
		oLbx:SetArray(aEmpresas)
		oLbx:bLine:= {||{aEmpresas[oLbx:nAt,1]}}
		
		
		bSet15 := {|| If(Empty(cEmpresa) .Or. cEmpresa == aEmpresas[oLbx:nAt,2],;
							(cRazao:=aEmpresas[oLbx:nAt,1],;
							cPorte:=aEmpresas[oLbx:nAt,3],;
							cRegiao:=aEmpresas[oLbx:nAt,4],;
							FVerTab(1,cRegiao,@cDRegiao,Nil),;						
							cFatur:= aEmpresas[oLbx:nAt,5],;
							FVerTab(2,cFatur,@cDFatur,Nil),;				
							cAtivid:=aEmpresas[oLbx:nAt,6],;
							FVerTab(3,cAtivid,@cDAtivid,Nil),;				
							nFunc:= aEmpresas[oLbx:nAt,7],;
							cContato:=aEmpresas[oLbx:nAt,8],;
							cEmail:=aEmpresas[oLbx:nAt,9],;
							cFone:=aEmpresas[oLbx:nAt,10],;
							SelSEmpr(oLbx:nAt,cRazao,cPorte,nFunc,cContato,cEmail,cFone)),;
							FMens(STR0001,STR0045,{STR0003});
						)}//"&Confirma"
		bSet24 := {|| oDlgA:End()} //"&Sair"
	ACTIVATE MSDIALOG oDlgA ON INIT EnchoiceBar( oDlgA , bSet15 , bSet24 , Nil , aButtons ) CENTERED

Return Nil

// Seleciona a Empresa e informa os dados da empresa
Function SelSEmpr(nAt, cRazao,cPorte,nFunc,cContato,cEmail,cFone)
Local oDlgA1, oLbx
Local oSRazao, oGRazao
Local oSPorte, oGPorte
Local oS1Porte
Local oSRegiao, oGRegiao, oGDRegiao 
Local oSF41, oSF42, oSF43
Local oSFatur, oGFatur, oGDFatur
Local oSAtivid, oGAtivid, oGDAtivid
Local oSFunc, oGFunc
Local oSContato, oGContato
Local oSEmail, oGEmail
Local oSFone, oGFone
Local oGroup
Local nx

Local bSet15
Local bSet24
Local aButtons := {}
Local nOpcHelp := 2  //Controla o Help que será exibido conforme a tela do momento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

If nChamada == 2
	SETKEY( VK_F4,{||FF4Prot("4",)})
EndIf
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 70	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 95	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*85), (((aObjSize[1,4])/100)*67) }	//1,3 Vertical /1,4 Horizontal
                          
DEFINE DIALOG oDlgA1 TITLE OemtoAnsi(STR0042) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL FONT oFont2  //"Selecione sua Empresa"
     	
	
	@ aGdCoord[1],aGdCoord[2] GROUP oGroup TO aGdCoord[3],aGdCoord[4] LABEL STR0046 PIXEL //"Informe os dados da sua Empresa"

	@ aGdCoord[1]+13,aGdCoord[2]+10 SAY oSRazao 	PROMPT STR0032 PIXEL OF oDlgA1 //"   Razao Social: "
	@ aGdCoord[1]+10,aGdCoord[2]+55 GET oGRazao	VAR cRazao						PIXEL SIZE 150,10 OF oDlgA1

	@ aGdCoord[1]+28,aGdCoord[2]+10 SAY oSPorte 	PROMPT STR0047 	PIXEL OF oDlgA1 //"               Porte: "
	@ aGdCoord[1]+25,aGdCoord[2]+55 GET oGPorte 	VAR cPorte							PIXEL SIZE 10,10 OF oDlgA1;
							PICTURE "@!";
							VALID cPorte $ "P*M*G"
	@ aGdCoord[1]+28,aGdCoord[2]+75 SAY oS1Porte PROMPT STR0048 PIXEL SIZE 150,10 OF oDlgA1 //"(P-Pequena   M-Media   G-Grande)"
														 
	@ aGdCoord[1]+43,aGdCoord[2]+10 SAY oSRegiao	PROMPT STR0162	PIXEL OF oDlgA1	//Regiao
	@ aGdCoord[1]+40,aGdCoord[2]+55 GET oGRegiao 	VAR cRegiao 		PICTURE "9999" PIXEL SIZE 20,10 OF oDlgA1;
							VALID FVerTab(1,cRegiao,@cDRegiao,@oGDRegiao)						
	oGRegiao:cToolTip := STR0049							 //"F4 disponivel"
	oGRegiao:bKeyDown := {|nKey,nFlag| If(nKey==115,FF4("1",@cRegiao,@cDRegiao),),oGRegiao:Refresh(),oGDRegiao:Refresh()}
	@ aGdCoord[1]+40,aGdCoord[2]+185 SAY oSF41		PROMPT STR0050	SIZE 90,10 PIXEL OF oDlgA1	COLOR CLR_RED  //"<F4 Disponivel>"
	If nChamada == 2
		oGRegiao:cReadVar := "1"
	EndIf	
	@ aGdCoord[1]+40,aGdCoord[2]+80 GET oGDRegiao 	VAR cDRegiao 							PIXEL SIZE 100,10 OF oDlgA1	 WHEN .F.
	
	@ aGdCoord[1]+58,aGdCoord[2]+10 SAY oSFatur 	PROMPT STR0051		PIXEL OF oDlgA1 //"     Faturamento: "
	@ aGdCoord[1]+55,aGdCoord[2]+55 GET oGFatur		VAR cFatur								PIXEL SIZE 15,10 OF oDlgA1;
							VALID FVerTab(2,cFatur,@cDFatur,@oGDFatur)
	oGFatur:cToolTip := STR0049								 //"F4 Disponivel"
	oGFatur:bKeyDown := {|nKey,nFlag| If(nKey==115,FF4("2",@cFatur,@cDFatur),),oGFatur:Refresh(),oGDFatur:Refresh()}	
	@ aGdCoord[1]+55,aGdCoord[2]+185 SAY oSF42		PROMPT STR0050	SIZE 90,10 PIXEL OF oDlgA1	COLOR CLR_RED //"<F4 Disponivel>"
	If nChamada == 2
		oGFatur:cReadVar := "2"
	EndIf	
	@ aGdCoord[1]+55,aGdCoord[2]+75 GET oGDFatur 	VAR cDFatur 							PIXEL SIZE 100,10 OF oDlgA1	WHEN .F.	

	@ aGdCoord[1]+73,aGdCoord[2]+10 SAY oSAtivid	PROMPT STR0052		PIXEL OF oDlgA1 //"         Atividade: "
	@ aGdCoord[1]+70,aGdCoord[2]+55 GET oGAtivid	VAR cAtivid								PIXEL SIZE 15,10 OF oDlgA1;
							VALID FVerTab(3,cAtivid,@cDAtivid,@oGDAtivid)
	oGAtivid:cToolTip := STR0049							 //"F4 Disponivel"
	oGAtivid:bKeyDown := {|nKey,nFlag| If(nKey==115,FF4("3",@cAtivid,@cDAtivid),),oGAtivid:Refresh(),oGDAtivid:Refresh}	
	
	@ aGdCoord[1]+70,aGdCoord[2]+185 SAY oSF43		PROMPT STR0050	SIZE 90,10 PIXEL OF oDlgA1	COLOR CLR_RED //"<F4 Disponivel>"
	If nChamada == 2
		oGAtivid:cReadVar := "3"
	EndIf	
	@ aGdCoord[1]+70,aGdCoord[2]+75 GET oGDAtivid 	VAR cDAtivid 							PIXEL SIZE 100,10 OF oDlgA1	WHEN .F.

	@ aGdCoord[1]+88,aGdCoord[2]+10 SAY oSFunc	PROMPT STR0053 		PIXEL OF oDlgA1 //"Nr Funcionario: "
	@ aGdCoord[1]+85,aGdCoord[2]+55 GET oGFunc	VAR nFunc						PIXEL SIZE 40,10 OF oDlgA1;
						PICTURE "999999";
						VALID !Empty(nFunc)	

	@ aGdCoord[1]+103,aGdCoord[2]+10 SAY oSContato 	PROMPT STR0054 	PIXEL OF oDlgA1 //"           Contato: "
	@ aGdCoord[1]+100,aGdCoord[2]+55 GET oGContato 	VAR cContato;
							PICTURE "@!"			PIXEL SIZE 100,10 OF oDlgA1;
							VALID !Empty(cContato)

	@ aGdCoord[1]+118,aGdCoord[2]+10 SAY oSEmail	PROMPT STR0055	PIXEL OF oDlgA1 //"               Email: "
	@ aGdCoord[1]+115,aGdCoord[2]+55 GET oGEmail	VAR cEmail;
							PICTURE "@!"			PIXEL SIZE 120,10 OF oDlgA1;
							VALID !Empty(cEmail)

	@ aGdCoord[1]+133,aGdCoord[2]+10 SAY oSFone 	PROMPT STR0056	PIXEL OF oDlgA1 //"                Fone: "
	@ aGdCoord[1]+130,aGdCoord[2]+55 GET oGFone 	VAR cFone;
							PICTURE "999999999999999"	PIXEL SIZE 50,10 OF oDlgA1;
							VALID !Empty(cFone)
    
    
	aAdd(aButtons, { Nil, { ||  FLeHelp(3)} , OemToAnsi(STR0040) } ) //"Help"
    			 
	   
    
    bSet15 := {|| (If(FSelOk(nAt,cRazao,cPorte,cRegiao,cFatur,;
						cAtivid,nFunc,cContato,cEmail,cFone),oDlgA1:End(),),)}
   	bSet24 := {|| oDlgA1:End()} 
   
    
ACTIVATE DIALOG oDlgA1 ON INIT (EnchoiceBar(oDlgA1, bSet15, bSet24, Nil, aButtons)) CENTERED

If nChamada == 2
	SET KEY  VK_F4 TO
EndIf																		

Return Nil

// Salva no array aEmpresas os dados das Empresas Participantes
Function FSelOk(nQual,cRazao,cPorte,cAuxRegiao,cFatur,cAtivid,nFunc,cContato,cEmail,cFone)

If Empty(cRazao) .Or. Empty(cPorte) .Or. Empty(cAuxRegiao) .Or.;
	Empty(cFatur) .Or. Empty(cAtivid) .Or. Empty(nFunc) .Or.;
	Empty(cContato) .Or. Empty(cEmail) .Or. Empty(cFone)
	FMens(STR0017,STR0059,{STR0003}) //"Atencao"###"Existem campos para ser preenchidos."###"Sair"
	Return .F.
EndIf

aEmpresas[nQual,1]:= cRazao
aEmpresas[nQual,3]:= cPorte
aEmpresas[nQual,4]:= cAuxRegiao
aEmpresas[nQual,5]:= cFatur							
aEmpresas[nQual,6]:= cAtivid
aEmpresas[nQual,7]:= nFunc
aEmpresas[nQual,8]:= cContato				
aEmpresas[nQual,9]:= cEmail				
aEmpresas[nQual,10]:= cFone

cEmpresa := aEmpresas[nQual,2]
	
Return .T.

//Funcao para digitar os dados da Coleta da Pesquisa Salarial 
Function FColeta()
	Local bSet15
	Local bSet24
	Local aButtons := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de arrays para dimensionar tela		                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aGDCoord		:= {}   
	
	Local cCodCargo		:= ""
	Local cCargo		:= ""
	Local cFuncao  		:= ""
	Local cDescFuncao	:= ""
	Local a1Lbx 		:= {}
	Local oDlgC
	Local oLbx
	Local nLbx			:= 0
	Local cCodCor		:= ""
	Local cFilCor		:= "" 
	Local cDescCor		:= ""	
	
	If lFechado
		FMens(STR0017,STR0041,{STR0003}) //"Atencao"###"Fechamento ja efetuado. Dados da Pesquisa nÆo pode ser mais alterado."###"Sair"
		Return Nil
	EndIf	
	
	If Empty(cPesq)
		FMens(STR0001,STR0002,{STR0003}) //"Verifique"###"Arquivo da Pesquisa Salarial nao selecionado (PSAL.TXT). O arquivo deve estar no mesmo diretorio do executavel"###"Sair"
		Return Nil
	EndIf
	
	If Len(a1Cargos) == 0
		FMens(STR0001,STR0060,{STR0003}) //"Verifique"###"Arquivo da Pesquisa Salarial nao possui os cargos da Coleta de Dados. Avise a Empresa Patrocinadora"###"Sair"
		Return Nil
	EndIf	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aAdvSize[5]	:=	(aAdvSize[5]/100) * 70	//horizontal
	aAdvSize[6]	:=  (aAdvSize[6]/100) * 80	//Vertical
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
	aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*70), (((aObjSize[1,4])/100)*67) }	//1,3 Vertical /1,4 Horizontal
	
	DEFINE DIALOG oDlgC TITLE OemtoAnsi(STR0061) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL FONT oFont2  //"Selecione o Cargo para Coleta de Dados"
       
	@ aGdCoord[1],aGdCoord[2] LISTBOX oLbx VAR nLbx 	FIELDS 	HEADER STR0062,STR0063;     //"Funcao"###"Cargos"
											COLSIZES GetTextWidth(0,"WWWWWWWWWWWWWWWWWWWW"),GetTextWidth(0,"W");
									SIZE aGdCoord[4],aGdCoord[3]-10 OF oDlgC PIXEL FONT oFont2
	
		oLbx:SetArray(a1Cargos)
		oLbx:bLine:= {||{a1Cargos[oLbx:nAt,4],a1Cargos[oLbx:nAt,2]}}		
		
		aAdd(aButtons, { Nil, { ||  FLeHelp(4)} , OemToAnsi(STR0040) } ) //"Help"		
    	bSet15 := {|| cCodCargo	:= a1Cargos[oLbx:nAt,1],;
						cCargo		:= a1Cargos[oLbx:nAt,2],;        
						cFuncao		:= a1Cargos[oLbx:nAt,5],;        
						cDescFuncao	:= a1Cargos[oLbx:nAt,4],;
						a1Lbx		:= aClone(a1Cargos[oLbx:nAt,3]),;																	
						FColPesqSal(cCodCargo, cCargo, cFuncao, cDescFuncao, a1Lbx)}
    	bSet24 := {|| oDlgC:End()}
	ACTIVATE DIALOG oDlgC ON INIT (EnchoiceBar(oDlgC, bSet15, bSet24, Nil, aButtons)) CENTERED
	
Return Nil

Function FColPesqSal(cCodCargo, cCargo, cFuncao, cDescFuncao, a1Lbx)
Local oDlgC
Local oLbx
Local o1Lbx
Local oGroup
Local oSCargo, oGCargo, oSF6
Local oSCodCor, oGCodCor, oGDescCor                   
Local oSDescDet
Local oSEsp
Local oSLegenda
Local oBtnDet, oBtnEsp
Local oBtnCol, oBtn1Can, oBtn1Hlp
Local oBtnOk, oBtn2Can, oBtn2Hlp
Local nLbx		:= 0
Local cFilCor		:= ""
Local cCodCor		:= ""
Local cDescCor		:= ""
Local cDescSum		:= ""
Local nEnter		:= 1
Local nRAnt			:= 1
Local bSet15
Local bSet24
Local aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}
 
If Empty(a1Lbx)
	Aadd(a1Lbx,{00000,0.00,0.00,0.00,0.00,0.00,"00",CTOD("  /  /  ")})
EndIf	

If Len(a1Cargos) == 0
	FMens(STR0001,STR0060,{STR0003}) //"Verifique"###"Arquivo da Pesquisa Salarial nao possui os cargos da Coleta de Dados. Avise a Empresa Patrocinadora"###"Sair"
	Return Nil
EndIf	
                                     
If 	nChamada == 2
	cCodCor:=""
	cDescCor:=""
	SETKEY( VK_F6,{||FF6Prot(@cCodCor,@cDescCor,@cFilCor)})
EndIf
	/*
o1Lbx:SetArray(a1Lbx)
o1Lbx:bLine := {|| {	Transform(a1Lbx[o1Lbx:nAt,1],"99999"),;
						Transform(a1Lbx[o1Lbx:nAt,2],"99999,999.99"),;
						Transform(a1Lbx[o1Lbx:nAt,3],"99999,999.99"),;
						Transform(a1Lbx[o1Lbx:nAt,4],"99999,999.99"),;
						Transform(a1Lbx[o1Lbx:nAt,5],"999.99"),;
						Transform(a1Lbx[o1Lbx:nAt,6],"9999.99"),;
						a1Lbx[o1Lbx:nAt,7],;
						Transform(a1Lbx[o1Lbx:nAt,8],"@D 99/99/99")}}
					   */							
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 70	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 95	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*85), (((aObjSize[1,4])/100)*67) }	//1,3 Vertical /1,4 Horizontal


DEFINE DIALOG oDlgC TITLE OemtoAnsi(STR0061) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL FONT oFont2  //"Selecione o Cargo para Coleta de Dados"
    	
	@ aGdCoord[1],aGdCoord[2] GROUP oGroup TO aGdCoord[3],aGdCoord[4] LABEL STR0064 PIXEL //"Entre com os dados da Pesquisa Salarial"

	@ aGdCoord[1]+13,aGdCoord[2]+5 	SAY oSCargo 	PROMPT STR0065 	PIXEL OF oDlgC //"                 Funcao:"
	@ aGdCoord[1]+10,aGdCoord[2]+60 	GET oGCargo	VAR cDescFuncao							PIXEL SIZE 100,10 OF oDlgC WHEN .F. 

	@ aGdCoord[1]+28,aGdCoord[2]+5 	SAY oSDescDet 	PROMPT STR0066	PIXEL OF oDlgC //"Descr. Detalhada: "
	@ aGdCoord[1]+25,aGdCoord[2]+60 	BUTTON oBtnDet 	PROMPT STR0067 			SIZE 50,11	PIXEL OF oDlgC; //"&Descricao"
			  	ACTION FVerDesc(cCodCargo,cFuncao,cDescFuncao)
			  	
	@ aGdCoord[1]+28,aGdCoord[2]+120 	SAY oSEsp 		PROMPT STR0068		PIXEL SIZE 50,11 OF oDlgC //"Especificacao:"
	@ aGdCoord[1]+25,aGdCoord[2]+160 	BUTTON oBtnEsp 	PROMPT STR0069 		SIZE 50,11	PIXEL OF oDlgC; //"&Especificacao"
				ACTION FVerEspec(cCodCargo,cFuncao,cDescFuncao)
				
	If nChamada == 2
		@ aGdCoord[1]+43,aGdCoord[2]+5 	SAY oSCodCor PROMPT STR0070 	PIXEL OF oDlgC //"Cargo Correspond.:"
		@ aGdCoord[1]+40,aGdCoord[2]+60 	GET oGCodCor VAR cCodCor					PIXEL SIZE 25,7 OF oDlgC;
					VALID FVerCargo(cCodCor,cFilCor,@o1Lbx,@a1Lbx)
		oGCodCor:cToolTip := STR0071 //"F6 Disponível"
		oGCodCor:cReadVar := "1"					
		@ aGdCoord[1]+40,aGdCoord[2]+90	GET oGDescCor VAR cDescCor					PIXEL SIZE 70,7 OF oDlgC;
					WHEN .F.
		@ aGdCoord[1]+43,aGdCoord[2]+165	SAY oSF6	PROMPT	STR0072 PIXEL SIZE 100,11 OF oDlgC    			 //"<F6> Consulta os Cargos"
	EndIf
				                                               
	@ aGdCoord[1]+55,aGdCoord[2]+5 	LISTBOX o1Lbx FIELDS HEADER 	STR0073,STR0074,; //"Frequencia"###"Salario"
												STR0075,STR0076,; //"Vl.Beneficio"###"Adicionais"
												STR0077,STR0078,STR0079,STR0080; //"%Antecipacao"###"Horas"###"Mes Dissidio"###"Data Base"
				FIELDSIZES 80,100,100,100,50,50,50,70 SIZE aGdCoord[4]-20,(((aObjSize[1,3])/100)*47) PIXEL OF oDlgC
   		
				o1Lbx:SetArray(a1Lbx)
				o1Lbx:bLine := {|| {	Transform(a1Lbx[o1Lbx:nAt,1],"99999"),;
										Transform(a1Lbx[o1Lbx:nAt,2],"99999,999.99"),;
										Transform(a1Lbx[o1Lbx:nAt,3],"99999,999.99"),;
										Transform(a1Lbx[o1Lbx:nAt,4],"99999,999.99"),;
										Transform(a1Lbx[o1Lbx:nAt,5],"999.99"),;
										Transform(a1Lbx[o1Lbx:nAt,6],"9999.99"),;
										a1Lbx[o1Lbx:nAt,7],;
										Transform(a1Lbx[o1Lbx:nAt,8],"@D 99/99/99")}}
										
				o1Lbx:bLDblClick 	:= {|nRow,nCol,nFlag| EditDados(10,nCol,@o1Lbx,@a1Lbx,.F.)}
				o1Lbx:bKeyDown 		:= {|nKey,nFlag| EditDados(nKey,@nEnter,@o1Lbx,@a1Lbx,.T.,@nRAnt)}
				If nChamada == 2
					o1Lbx:bGotFocus 	:= {|nKey| EditProt(@nEnter,@o1Lbx,@a1Lbx,.T.,@nRAnt)}
				EndIf	
				                          
	If nChamada == 1				
		@ (((aObjSize[1,3])/100)*75),aGdCoord[2]+5 	SAY oSLegenda PROMPT STR0081 SIZE 150,10 PIXEL OF oDlgC		 //"<INS>Inserir linha    <DEL>Apagar linha"
	ElseIf nChamada == 2
		@ (((aObjSize[1,3])/100)*75),aGdCoord[2]+5 	SAY oSLegenda PROMPT STR0082 SIZE 150,10 PIXEL OF oDlgC		 //"<F4>Inserir linha     <F5>Apagar linha"
	EndIf	
	
	aAdd(aButtons, { Nil, { ||  FLeHelp(5)} , OemToAnsi(STR0040) } ) //"Help" 
	bSet15 := {|| If(FTudoOk(2,1,a1Lbx),FSalvaCol(cCodCargo,a1Lbx,cFuncao),),oDlgC:End()}
	bSet24 := {|| oDlgC:End()}
ACTIVATE DIALOG oDlgC ON INIT EnchoiceBar(oDlgC, bSet15, bSet24, Nil, aButtons) CENTERED

If 	nChamada == 2
	SET KEY VK_F6 TO
EndIf	

Return Nil	

// Funcao que salva os dados do listbox num array de coletados
Static Function FSalvaCol(cCargo,a1Lbx,cFuncao)
Local nPos:= 0

nPos:= Ascan(a1Cargos,{|x| Alltrim(x[1]) == Alltrim(cCargo).And. ;
							Alltrim(x[5]) == Alltrim(cFuncao)})
If nPos > 0
	a1Cargos[nPos][3] := aClone(a1Lbx)
EndIf				
	
Return Nil

// Funcao que monta a descricao detalhada do Cargo numa tela
Function FVerDesc(cCodCargo,cFuncao,cDescFuncao)
Local oDlg, oMemo
Local oBtnOk, oBtnHlp
Local cDescMemo := ""
Local nPos		:= 0

Local bSet15
Local bSet24
Local aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

nPos:= Ascan(a2Cargos,{|x| Alltrim(x[1]) == Alltrim(cCodCargo)})
If nPos <= 0
	cDescMemo := STR0083	 //"Nao ha descricao detalhada"
Else
	While nPos <= Len(a2Cargos)
		If a2Cargos[nPos,1] == cCodCargo
			cDescMemo += a2Cargos[nPos,2] 
		EndIf	
		nPos := nPos + 1
	EndDo
EndIf
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 60	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 60	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*45), (((aObjSize[1,4])/100)*55) }	//1,3 Vertical /1,4 Horizontal

aAdd(aButtons, { Nil, { ||  FLeHelp(6)} , OemToAnsi(STR0040) } ) //"Help"
	
DEFINE DIALOG oDlg TITLE STR0084 + cDescFuncao FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL FONT oFont2 //"Descricao Detalhada do Cargo: "

	@ aGdCoord[1],aGdCoord[2]	GET oMemo VAR cDescMemo MEMO SIZE aGdCoord[4],aGdCoord[3] PIXEL OF oDlg READONLY
		
	bSet15 := {|| oDlg:End()}
	bSet24 := {|| oDlg:End()}
	
ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15, bSet24, Nil, aButtons) CENTERED

Return Nil

// Funcao que mostra as especificacoes do Cargo numa tela
Function FVerEspec(cCodCargo,cFuncao,cDescFuncao)
Local oDlg, oLbx
Local oBtnOk, oBtnHlp
Local nLbx	:= 0
Local aLbx	:= {}
Local bSet15
Local bSet24
Local aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

nPos:= Ascan(a3Cargos,{|x| Alltrim(x[1]) == Alltrim(cCodCargo)})
If nPos <= 0
	Aadd(aLbx,{STR0085,""}) //"Nao ha especificacoes para este Cargo"
Else
	While nPos <= Len(a3Cargos)
		If a3Cargos[nPos,1] == cCodCargo
			Aadd(aLbx,{a3Cargos[nPos,3],a3Cargos[nPos,5]})
		EndIf	
		nPos := nPos + 1
	EndDo
EndIf
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 60	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 60	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*45), (((aObjSize[1,4])/100)*55) }	//1,3 Vertical /1,4 Horizontal

aAdd(aButtons, { Nil, { ||  FLeHelp(7)} , OemToAnsi(STR0040) } ) //"Help"


DEFINE DIALOG oDlg TITLE STR0086+ cDescFuncao FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL FONT oFont2 //"Especificacao do Cargo : "

	@ aGdCoord[1],aGdCoord[2] LISTBOX oLbx VAR nLbx FIELDS 	HEADER STR0087,STR0088; //"Especificacao"###"Necessario"
											COLSIZES	GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
														GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");
											SIZE aGdCoord[4],aGdCoord[3] OF oDlg PIXEL FONT oFont2
	
		oLbx:SetArray(aLbx)
		oLbx:bLine:= {||{aLbx[oLbx:nAt,1],aLbx[oLbx:nAt,2]}}
	
	bSet15 := {|| oDlg:End()}
	bSet24 := {|| oDlg:End()}	
	
ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15, bSet24, Nil, aButtons)
Return Nil

//Funcao que gera o arquivo Retorno da Pesquisa Salarial, pegando o PSAL.TXT
//e transformando em PSAL+cEmpresa.Ret com o tipo 60 e 70 gravados
// nTipo == 1			Sair para continuar a digitacao depois
// nTipo == 2			Sair para enviar o Txt
Function FFechar(nTipo)
Local oDlg1, oMeter
Local nFix:= 1
Local nOpt:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

If lFechado
	FMens(STR0017,STR0041,{STR0003}) //"Atencao"###"Fechamento ja efetuado. Dados da Pesquisa nÆo pode ser mais alterado."###"Sair"
	Return Nil
EndIf	

If nTipo == 2 .And. Empty(cEmpresa)
	FMens(STR0001,STR0089,{STR0003}) //"Verifique"###"Existe algum dado da empresa que nÆo foi preenchido."###"Sair"
	Return Nil
EndIf	

If nTipo == 2 
	While .T.
		nOpt:= FMens(STR0090,STR0091,{STR0092,STR0093,STR0094}) //"Confirme"###"Finalizar Pesquisa Salarial?"###"Sim"###"Nao"###"Help"
		If nOpt == 1
			Exit
		ElseIf nOpt == 2
			Return Nil
		ElseIf nOpt == 3
			FLeHelp(8)
			Loop
		EndIf		
	EndDo	
EndIf
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 40	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 20	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*50), (((aObjSize[1,4])/100)*55) }	//1,3 Vertical /1,4 Horizontal
              

DEFINE DIALOG oDlg1 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL TITLE STR0095 //"Aguarde..." 00,00 60,307

	@aGdCoord[1]+10,aGdCoord[2] METER oMeter VAR nFix SIZE (aGdCoord[4]/2)+30,8 OF oDlg1 PIXEL TOTAL 4;
	BARCOLOR CLR_BLACK,CLR_WHITE COLOR CLR_WHITE,CLR_BLACK NOPERCENTAGE
	
	If nChamada == 2
		oDlg1:bStart := {|| CursorWait(), FBar(nTipo,nFix,oDlg1,oMeter) }
	EndIf

ACTIVATE DIALOG oDlg1 CENTERED NOWAIT

If nChamada == 1
	FBar(nTipo,@nFix,oDlg1,oMeter)
EndIf	

Return .T.

//Funcao monta a barra de apresentacao dos Bitmaps
Static Function FBar(nTipo,nFix,oDlg1,oMeter)
Local cArqDest:=""

nFix++
oMeter:Set(nfix)				
SysRefresh()

FSEEK(nHdlArq,0,2)			// procura fim do arquivo

FGera60()
		
FGera70()

FGera99()

nFix++
oMeter:Set(nfix)				
SysRefresh()

FClose(nHdlArq)

If nTipo == 2
	lFechado := .T.
	cArqDest:="PSAL"+cEmpresa+".RET"
	FRename(cFile,cArqDest)
EndIf	
            
If nTipo == 2
	MSGINFO(STR0096,STR0017) //"Encerramento da Pesquisa com sucesso."###"Atencao"
Else
	MSGINFO(STR0097,STR0017)	 //"Dados atualizado com sucesso."###"Atencao"
EndIf	
oDlg1:End()

Return NIL
                    

// Funcao que le o arquivo PSAL.TXT enviado pelas empresas
Function FLeArq(n2HdlArq, c2File, lFile2Fecha)
Local aAuxCargo	:= {}
Local nLidos 	:= 0
Local nTamArq	:= 0
Local nPos		:= 0

Local xBuffer
Local cCargo	:= ""
Local cAuxCargo	:= ""
Local cTabela	:= ""
Local cAuxFuncao:= ""

Local nx 		:= 0  
Local lRet		:= .T.

// Criado arquivo PSAL.BKP do PSAL que sera o PSAL.TXT sem o Tipo 60 e 70 
c2File := "PSAL.BKP"
Begin Sequence 

	If 	FILE(c2File)
		FERASE(c2File)	
	Endif
	
	IF ( n2HdlArq:= FCreate(c2File,0) ) <0 		// 0 - Leitura e Gravacao         
	   lRet:= .F.  
	   FMens(STR0001,STR0266 + c2File + CRLF + alltrim(str(Ferror())) ,{STR0003})	 //"Verifique"###"Erro ao criar o arquivo: "###"Sair"
	   Break
	Endif        
	
	lFile2Fecha	:= .T.
	
	FSEEK(nHdlArq,0,0)
	nTamArq := FSEEK(nHdlArq,0,2)
	FSEEK(nHdlArq,0,0)
	
	While nLidos <= nTamArq
	
		xBuffer := Space(nTam)
		FREAD(nHdlArq,@xBuffer,nTam)
		
		If Substr(xBuffer,1,2) == "00"				// Codigo da Pesquisa no SIGA
			cPesq := Substr(xBuffer,3,4)
			FWrite(n2HdlArq,xBuffer)
		ElseIf Substr(xBuffer,1,2) == "10"			// Texto de Apresentacao
			Aadd(aApresent,Alltrim(Substr(xBuffer,3,197))+cCRLF)
			FWrite(n2HdlArq,xBuffer)
		ElseIf Substr(xBuffer,1,2) == "20"						// Empresas Participantes
			Aadd(aEmpresas,{		Substr(xBuffer,03,50),;	// Nome da Empresa
									Substr(xBuffer,53,04),;	// Codigo da Empresa
									Substr(xBuffer,57,01),;	// Porte
									"0000",;					// Regiao
									"000",;						// Faturamento
									"000",;						// Atividade
									Substr(xBuffer,68,06),;	// Nr de Funcionarios
									Substr(xBuffer,74,30),;	// Contato
									Substr(xBuffer,104,60),;	// Email
									Substr(xBuffer,164,15)	})	// Fone                  
			FWrite(n2HdlArq,xBuffer)						
		ElseIf Substr(xBuffer,1,2) == "30"			// Cargos da Pesquisa	
			FWrite(n2HdlArq,xBuffer)
			If Substr(xBuffer,3,1) == "1"			// Cod+Descricao do Cargo no SIGA
				cCargo := Substr(xBuffer,4,5)
				Aadd(a1Cargos,{cCargo,Substr(xBuffer,9,30),{{00000,0.00,0.00,0.00,0.00,0.00,"00",CTOD("  /  /  ")}},Substr(xBuffer,46,20),Substr(xBuffer,41,5)})
			ElseIf Substr(xBuffer,3,1) == "2"		// Descricao Detalhada do Cargo no SIGA
				Aadd(a2Cargos,{cCargo,Alltrim(Substr(xBuffer,4,196))})		
			ElseIf Substr(xBuffer,3,1) == "3"		// Especificacao do Cargo no SIGA
				nPos:= Ascan(a3Cargos,{|x| Alltrim(x[1]) == Alltrim(cCargo)})
				If nPos <= 0
					Aadd(a3Cargos,{cCargo,;
									Substr(xBuffer,4,2),;		// Fator
									Substr(xBuffer,7,30),;		// Descricao do Fator
									Substr(xBuffer,39,2),;		// Grau
									Substr(xBuffer,42,30)})		// Descricao do Grau
	
					Aadd(a3Cargos,{cCargo,;
									Substr(xBuffer,73,2),;		// Fator
									Substr(xBuffer,76,30),;	// Descricao do Fator
									Substr(xBuffer,108,2),;	// Grau
									Substr(xBuffer,111,30)})	// Descricao do Grau
				EndIf
			EndIf
		ElseIf Substr(xBuffer,1,2) == "40"			// Tabela SX5 de Regiao, Faturamento e Atividade
			FWrite(n2HdlArq,xBuffer)
			cTabela := Substr(xBuffer,3,2)
			If !Empty(Substr(xBuffer,5,4))
				Aadd(aSX5,{cTabela,Substr(xBuffer,5,4),Substr(xBuffer,10,30)})			
			EndIf
			If !Empty(Substr(xBuffer,41,4))
				Aadd(aSX5,{cTabela,Substr(xBuffer,41,4),Substr(xBuffer,46,30)})
			EndIf	
			If !Empty(Substr(xBuffer,77,4))
				Aadd(aSX5,{cTabela,Substr(xBuffer,77,4),Substr(xBuffer,82,30)})
			EndIf
			If !Empty(Substr(xBuffer,113,4))			
				Aadd(aSX5,{cTabela,Substr(xBuffer,113,4),Substr(xBuffer,118,30)})
			EndIf
			If !Empty(Substr(xBuffer,149,4))	
				Aadd(aSX5,{cTabela,Substr(xBuffer,149,4),Substr(xBuffer,154,30)})		
			EndIf
		ElseIf Substr(xBuffer,1,2) == "50"			// Dados da Empresa Patrocinadora
			FWrite(n2HdlArq,xBuffer)
			If Substr(xBuffer,3,1) == "1"
				Aadd(aPatroc,{	Substr(xBuffer,4,4),;	// Codigo da Patrocinadora no SIGA
									Substr(xBuffer,8,50),;	// Razao Social da Patrocinadora
									Substr(xBuffer,58,30),;	// Endereco 
									Substr(xBuffer,88,30),;	// Cidade
									Substr(xBuffer,118,2)})	// Estado
			ElseIf Substr(xBuffer,3,1) == "2"
				Aadd(aPatroc,{	Substr(xBuffer,4,30),;	// Contato
									Substr(xBuffer,34,15),;	// Fone
									Substr(xBuffer,49,60)})	// Email
			EndIf						
		ElseIf Substr(xBuffer,1,2) == "60"		// Dados Informados da Empresas Participante	
			cEmpresa:= Substr(xBuffer,53,04)
			Aadd(aSelecionada,{	Substr(xBuffer,03,50),;		// Nome da Empresa
										Substr(xBuffer,53,04),;		// Codigo da Empresa
										Substr(xBuffer,57,01),;		// Porte
										Substr(xBuffer,58,04),;		// Regiao
										Substr(xBuffer,62,03),;		// Faturamento
										Substr(xBuffer,65,03),;		// Atividade
										Substr(xBuffer,68,06),;		// Nr de Funcionarios
										Substr(xBuffer,74,30),;		// Contato
										Substr(xBuffer,104,60),;		// Email
										Substr(xBuffer,164,15)})		// Fone	
		ElseIf Substr(xBuffer,1,2) == "70"	// Dados Informados do Cargo
			cAuxCargo := Substr(xBuffer,3,5)
			Aadd(aCargosInf,{	cAuxCargo,;							// Codigo Cargo
								Val(Substr(xBuffer,8,5)),;	// Frequencia		
								Val(Substr(xBuffer,13,12)),;	// Salario			
								Val(Substr(xBuffer,25,12)),;	// Vl Beneficio	
								Val(Substr(xBuffer,37,12)),;	// Adicionais 		
								Val(Substr(xBuffer,49,06)),;	// %Antecipacao  	
								Val(Substr(xBuffer,55,07)),;	// Horas  			
								Substr(xBuffer,62,02),;		// Dissidio			
								CtoD(Substr(xBuffer,64,08)),;	// Data Base 
								Substr(xBuffer,72,5)})			// Codigo Funcao
			cAuxCargo := Substr(xBuffer,77,5)
			If !Empty(cAuxCargo)
				Aadd(aCargosInf,{	cAuxCargo,;							// Codigo do Cargo
									Val(Substr(xBuffer,82,5)),;	// Frequencia		
									Val(Substr(xBuffer,87,12)),;	// Salario			
									Val(Substr(xBuffer,99,12)),;	// Vl Beneficio	
									Val(Substr(xBuffer,111,12)),;	// Adicionais 		
									Val(Substr(xBuffer,123,06)),;	// %Antecipacao  	
									Val(Substr(xBuffer,129,07)),;	// Horas  			
									Substr(xBuffer,136,02),;		// Dissidio						
									CtoD(Substr(xBuffer,138,08)),;// Data Base 									
									Substr(xBuffer,146,5)})		// Codigo da Funcao	
			EndIf							
		EndIf
		
		nLidos += 200
		
	EndDo	                
	
	// Atualiza o array de Empresas quando ja existir a Empresa Selecionada
	If Len(aSelecionada) > 0
		nPos:= Ascan(aEmpresas,{|x| Alltrim(x[2]) == Alltrim(cEmpresa)})
		If nPos > 0
			aEmpresas[nPos][1] := aSelecionada[1][1]
			aEmpresas[nPos][2] := aSelecionada[1][2]
			aEmpresas[nPos][3] := aSelecionada[1][3]
			aEmpresas[nPos][4] := aSelecionada[1][4]
			aEmpresas[nPos][5] := aSelecionada[1][5]
			aEmpresas[nPos][6] := aSelecionada[1][6]
			aEmpresas[nPos][7] := aSelecionada[1][7]
			aEmpresas[nPos][8] := aSelecionada[1][8]
			aEmpresas[nPos][9] := aSelecionada[1][9]
			aEmpresas[nPos][10] := aSelecionada[1][10]		
		EndIf
	EndIf
		
	// Atualiza os dados do Cargo quando ja existir dados Informados
	For nx:=1 To Len(a1Cargos)
		aAuxCargo := {}
		cAuxCargo := a1Cargos[nx][1]
		cAuxFuncao:= a1Cargos[nx][5]
		nPos:= Ascan(aCargosInf,{|x| 	Alltrim(x[1]) == Alltrim(cAuxCargo) .And. ;
										Alltrim(x[10]) == Alltrim(cAuxFuncao)})
		If nPos > 0
			While nPos <= Len(aCargosInf)
				If 	cAuxCargo == aCargosInf[nPos][1] .And.;
					cAuxFuncao == aCargosInf[nPos][10]
					Aadd(aAuxCargo,{		aCargosInf[nPos][2],;
											aCargosInf[nPos][3],;
											aCargosInf[nPos][4],;
											aCargosInf[nPos][5],;
											aCargosInf[nPos][6],;
											aCargosInf[nPos][7],;
											aCargosInf[nPos][8],;
											aCargosInf[nPos][9],;
											aCargosInf[nPos][10]})
				EndIf	
				nPos := nPos + 1
			EndDo
		EndIf					
		If Len(aAuxCargo) == 0
			Aadd(aAuxCargo,{00000,0.00,0.00,0.00,0.00,0.00,"00",CTOD("  /  /  "),""})
		Else		
			a1Cargos[nx][3] := aClone(aAuxCargo)
		EndIf	
	Next nx  
	
	
	If  ( Len(aApresent) == 0 .And. Len(aEmpresas) == 0)
		FMens(STR0001,STR0004,{STR0003})	 //"Verifique"###"Arquivo da Pesquisa Salarial com problemas. (PSAL.TXT). Avise a empresa Patrocinadora da Pesquisa Salarial"###"Sair"
		lRet:= .F.
	Endif	
End

Return lRet


// Funcao le o SX5 e monta as tabela para as Empresa Participantes
Static Function FLeSX5()
Local nx

For nx:= 1 To Len(aSX5)
	If aSX5[nx][1] == "RC"
		Aadd(aRC,{aSX5[nx][2],aSX5[nx][3]})
	ElseIf aSX5[nx][1] == "RD"
		Aadd(aRD,{aSX5[nx][2],aSX5[nx][3]})	
	ElseIf aSX5[nx][1] == "RE"
		Aadd(aRE,{aSX5[nx][2],aSX5[nx][3]})	
	EndIf	
Next nx

Return Nil


// Funcao que executa a saida do PSAL 
Static Function FSair()
Local nOpt:=0

If Empty(cPesq)
	FMens(STR0001,STR0002,{STR0003}) //"Verifique"###"Arquivo da Pesquisa Salarial nao selecionado (PSAL.TXT). O arquivo deve estar no mesmo diretorio do executavel"###"Sair"
	Return .F.
EndIf	

nOpt:=FMens(STR0017,STR0098,{STR0092,STR0093}) //"Atencao"###"Confirma saida do sistema"###"Sim"###"Nao"

If !lFechado
	If nOpt == 1
		FFechar(1)			
	Else 
		Return .F.
	EndIf	
EndIf

oFont:End()
oFont1:End()

Return .T.


//Funcao que monstra o help conforme opcao selecionada.
Function FLeHelp(nOpcao)
Local cDescMemo:=""
Local oMemo, oBntSair, oDlg
Local cTitulo:=""                                
Local bSet15
Local bSet24
Local aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 60	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 70	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*60), (((aObjSize[1,4])/100)*57) }	//1,3 Vertical /1,4 Horizontal

If nOpcao == 15		// Mostrar todos os helps
	cTitulo  := STR0099  //"Help do PSAL- Sistema de Pesquisa Salarial e Benefícios"
	cDescMemo:= STR0100  //"O Sistema de Pesquisa Salarial e Benefícios, foi desenvolvido para facilitar a Coleta "
	cDescMemo+= STR0101 //"de Dados das empresas que estão participando da pesquisa salarial, esse sistema permite a "
	cDescMemo+= STR0102+PULA //"digitação dos dados diretamente no sistema, evitando a circulação de papéis entre as empresas."
	cDescMemo+= STR0103 //"A empresa que esta promovendo a pesquisa salarial, a Patrocinadora, envia o PSAL.EXE "
	cDescMemo+= STR0104 //"acompanhado de um arquivo,  para as empresas que participarão da pesquisa. Com o executável "
	cDescMemo+= STR0105  //"a empresa Participante, informa os dados de sua empresa, diretamente no sistema e já os envia "
	cDescMemo+= STR0106 //"de volta à empresa patrocinadora, "
	cDescMemo+= STR0107 //"A Empresa Patrocinadora simplesmente, lê o arquivo com os dados das empresas participante e "
	cDescMemo+= STR0108 //"processa o Resultado da Pesquisa Salarial. "
	cDescMemo+= STR0109 //"Essas facilidades são do Sistema de Cargos e Salários da Microsiga, portanto, todos os clientes "
	cDescMemo+= STR0110+PULA //"Microsiga possuem essas facilidades. "
EndIf	

If	nOpcao == 1 .Or. nOpcao == 15
	If 	nOpcao == 15
		cDescMemo += PULA+PULA
		cDescMemo += STR0111 + PULA //"Empresa Patrocinadora da Pesquisa"
		cDescMemo += STR0112 +PULA //"Será apresentado os dados da empresa que esta promovendo a Pesquisa Salarial."
	Else
		cTitulo	 := STR0113	 //"Dados da Empresa Patrocinadora da Pesquisa"
		cDescMemo:= STR0112 +PULA //"Será apresentado os dados da empresa que esta promovendo a Pesquisa Salarial."
	EndIf	
	cDescMemo+= STR0114 //"Normalmente, uma empresa decide fazer a Pesquisa Salarial, ou para implantar um "
	cDescMemo+= STR0115  //"Plano de Cargos e Salários ou para saber, o comportamento salarial do mercado, dentro "
	cDescMemo+= STR0116+PULA //"de um determinado período ou setor da empresa."
	cDescMemo+= STR0117 //"É papel da Empresa Patrocinadora, selecionar os cargos a serem pesquisados, as "
	cDescMemo+= STR0118 //"empresas que participarão da pesquisa, definir as datas de realização, a entrega da "
	cDescMemo+= STR0119 //"coleta dos dados e realizar a pesquisa propriamente dita, através dos cálculos "
	cDescMemo+= STR0120+PULA+PULA //"estatísticos e valores definidos, para a realização de uma Pesquisa Salarial."
	If 	nOpcao == 1
		cDescMemo+= STR0121 //"Como utilizar: Essa rotina é meramente informativa, somente são apresentado os "
		cDescMemo+= STR0122  //"dados da empresa Patrocinadora, não podendo ser alterado nenhum deles,"
		cDescMemo+= STR0123+PULA+PULA //"servindo apenas para consulta dos dados."
	EndIf	
	cDescMemo+= STR0124+PULA //"Os dados informados são:"
	cDescMemo+= STR0125+PULA //"  Razão Social:"
	cDescMemo+= STR0126+PULA //"      Nome da empresa que esta realizando a Pesquisa Salarial."
	cDescMemo+= STR0127+PULA //"  Endereço:"
	cDescMemo+= STR0128+PULA //"      Endereço da empresa que esta realizando a Pesquisa Salarial."
	cDescMemo+= STR0129+PULA //"  Cidade:"
	cDescMemo+= STR0130+PULA //"      Cidade da empresa que esta realizando a Pesquisa Salarial."
	cDescMemo+= STR0131+PULA //"  Estado:"
	cDescMemo+= STR0132+PULA	 //"      Estado da empresa que esta realizando a Pesquisa Salarial."
	cDescMemo+= STR0133+PULA //"  Fone:"
	cDescMemo+= STR0134+PULA //"      Telefone da empresa que esta realizando a Pesquisa Salarial."
	cDescMemo+= STR0135+PULA //"  Contato:"
	cDescMemo+= STR0136+PULA //"      Nome da pessoa responsável pela Pesquisa Salarial."
	cDescMemo+= STR0137+PULA //"  Email:"
	cDescMemo+= STR0138+PULA //"      Email de contato da empresa que esta realizando a Pesquisa Salarial."
EndIf	

If 	nOpcao == 2 .Or. nOpcao = 15                                            
	If 	nOpcao == 15
		cDescMemo += PULA+PULA
		cDescMemo += STR0010+PULA //"Empresas Participantes"
		cDescMemo += STR0139		 //"Será apresentado todas as empresas que participarão da Pesquisa Salarial, essas "
	Else
		cTitulo	 := STR0140	 //"Empresas Participantes da Pesquisa"
		cDescMemo := STR0139 //"Será apresentado todas as empresas que participarão da Pesquisa Salarial, essas "
	EndIf	
	cDescMemo+= STR0141  //"empresas foram selecionadas pela empresa Patrocinadora, através de alguns critérios "
	cDescMemo+= STR0142  //"que são importantes dentro de uma seleção como, porte das empresas, números de "
	cDescMemo+= STR0143  //"funcionários, concorrentes, mesma região geográfica, ramo de atividade, organização "
	cDescMemo+= STR0144  //"e lembrando sempre que são essas empresas que formarão o universo de "
	cDescMemo+= STR0145  //"abrangência do mercado, mostrando qual a remuneração praticada para "
	cDescMemo+= STR0146 + PULA //"os cargos escolhidos."
	If 	nOpcao == 2                           
		cDescMemo+= PULA
		cDescMemo+= STR0147 //"Como utilizar: Aparece uma relação com todas as Empresas que estão "
		cDescMemo+= STR0148 //"participando da Pesquisa Salarial, posicione sobre a razão social de sua empresa e "
		cDescMemo+= STR0149+PULA + PULA //"apertar o botão de Ok."
		cDescMemo+= STR0150 //"Observação: Lembrando que uma fez confirmado esses dados, o sistema não permitirá "
		cDescMemo+=	STR0151+PULA //"selecionar outra empresa, apenas a selecionada da primeira vez."
	EndIf	
EndIf
	
If 	nOpcao == 3 .Or. nOpcao == 15
	If nOpcao == 15
		cDescMemo += PULA+PULA
		cDescMemo += STR0152+PULA //"Dados da Empresa Participante"
		cDescMemo +=STR0153		 //"Foi selecionado anteriormente uma Empresa, após feito isso, aparecerá alguns dados que "
	Else	
		cTitulo	 := STR0154	 //"Dados da Empresa Participante da Pesquisa"
		cDescMemo:= STR0153 //"Foi selecionado anteriormente uma Empresa, após feito isso, aparecerá alguns dados que "
	EndIf	
	cDescMemo+= STR0155+PULA+PULA //"devem ser preenchidos com relação a sua empresa, para auxiliar no resultado da Pesquisa Salarial."
	cDescMemo+= STR0156 + PULA //"Os dados a serem informados são:"
	cDescMemo+= STR0157+ PULA //"Razão Social: "
	cDescMemo+= STR0158+ PULA //"    Razão Social ou Apelido da empresa participante."
	cDescMemo+= STR0159+ PULA //"Porte:	"
	cDescMemo+= STR0160+PULA //"    Porte da empresa participante."
	cDescMemo+= STR0161 + PULA //"    Pode ser informado apenas 'P'-Pequena,'M'-Médio ou 'G'-Grande "
	cDescMemo+= STR0162+ PULA //"Região: "
	cDescMemo+= STR0163+PULA //"    Código da região onde fica localizada a empresa participante."
	cDescMemo+= STR0164+PULA //"    Aperte F4, para consultar os códigos válidos."
	cDescMemo+=STR0165+ PULA //"Faturamento: "
	cDescMemo+= STR0166 + PULA //"    Código do valor de faturamento da empresa participante."
	cDescMemo+= STR0164 + PULA //"    Aperte F4, para consultar os códigos válidos."
	cDescMemo+=STR0167 + PULA //"Atividade: "
	cDescMemo+= STR0168 +PULA //"    Código do ramo de atividade da empresa participante."
	cDescMemo+= STR0169+PULA //"    Aperte F4 para consultar os códigos válidos."
	cDescMemo+=	STR0170+ PULA //"Nr Funcionário: "
	cDescMemo+= STR0171+PULA //"    Números de funcionários que possui a empresa participante. "
	cDescMemo+=	STR0172+ PULA //"Contato: "
	cDescMemo+= STR0173+PULA //"    Nome da pessoa responsável pelos dados na empresa participante."
	cDescMemo+=	STR0174 + PULA //"Email: "
	cDescMemo+= STR0175+PULA //"    Email da pessoa responsável pelos dados na empresa participante."
	cDescMemo+=	STR0176+ PULA  //"Fone: "
	cDescMemo+= STR0177+PULA //"    Telefone da pessoa responsável pelos dados na empresa participante."
EndIf

If 	nOpcao == 4 .Or. nOpcao == 15
	If 	nOpcao == 15
		cDescMemo += PULA+PULA
		cDescMemo += STR0178+PULA //"Cargos a serem pesquisados"
		cDescMemo += STR0179  //"Será apresentado os dados para se realizar a Coleta propriamente dita, esse passo é o "
	Else
		cTitulo  := STR0178  //"Cargos a serem pesquisados"
		cDescMemo:= STR0179 		 //"Será apresentado os dados para se realizar a Coleta propriamente dita, esse passo é o "
	EndIf	
	cDescMemo+= STR0180 //"mais importante dentro de uma Pesquisa Salarial, pois é dele que se obtém todo o "
	cDescMemo+= STR0181 + PULA //"resultado da Pesquisa Salarial. "
	cDescMemo+= STR0182 //"Para se realizar uma Coleta de Dados, é necessário "
	cDescMemo+= STR0183 //"que as empresas Participantes, tenha uma identificação precisa dos cargos "
	cDescMemo+= STR0184  //"pesquisados e das especificações necessárias para esse cargo, conhecendo bem o "
	cDescMemo+= STR0185 + PULA //"cargo a chance de cometer erros é menor, no momento de informar os dados."
	If nOpcao == 4
		cDescMemo+= STR0186 //"Como utilizar: Aparecerá uma relação com todos os cargos que deverão ser pesquisados os salários, "
		cDescMemo+= STR0187+PULA //"posicione sobre um dos cargos e apertar o botão de OK. "
	EndIf	
EndIf
	
If nOpcao == 5 .Or. nOpcao == 15                          
	If nOpcao == 15
		cDescMemo += PULA+PULA
		cDescMemo += STR0188+PULA //"Dados dos cargos"
		cDescMemo += STR0189+PULA		 //"Após feito isso, aparecerá dados importantes para identificação do cargo são eles: "
	Else	
		cTitulo  := STR0188	 //"Dados dos cargos"
		cDescMemo:= STR0189+PULA //"Após feito isso, aparecerá dados importantes para identificação do cargo são eles: "
	EndIf	
	cDescMemo+= STR0190+ PULA //"   Cargo: "
	cDescMemo+= STR0191+PULA //"     Nome do cargo ou descrição sumária do cargo."
	cDescMemo+= STR0192+ PULA //"   Descrição detalhada: "
	cDescMemo+= STR0193+PULA //"     Descrição detalhada do que cargo, onde haverá detalhes descritos para evitar dúvidas e contribuir para esclarecer melhor os cargos."
	cDescMemo+= STR0194+PULA //"   Especificação:"
	cDescMemo+= STR0195+PULA //"     São os requisitos necessários exigidos pelo cargos."
	
	If 	nChamada == 2
		cDescMemo +=STR0196+ PULA //"   Cargo Correspondente:"
		cDescMemo +=STR0197+ PULA      //"     Deve ser preenchido o código do Cargo correspondente ao da Pesquisa Salarial."
	EndIf
	
	cDescMemo+= PULA
	cDescMemo+= STR0198+PULA //"Os dados da Coleta que devem ser informados são:"
	cDescMemo+= STR0199+ PULA //"Freqüência: "
	cDescMemo+= STR0200+PULA //"    Nr de funcionários com um determinado salário."
	cDescMemo+= STR0201+ PULA //"Salário: "
	cDescMemo+= STR0202+PULA //"    Valor do salário do funcionário."
	cDescMemo+= STR0203+PULA //"Vl. Benefício: "
	cDescMemo+= STR0204+PULA //"    Valores dos benefícios pago pela empresa."
	cDescMemo+= STR0205+PULA //"Adicionais: "
	cDescMemo+= STR0206+PULA //"    Valores adicionais que são acrescidos no salário do funcionario."
	cDescMemo+= STR0207+PULA //"%Antecipação: "
	cDescMemo+= STR0208+PULA //"    Percentual de Antecipação pago pelo empresa."
	cDescMemo+= STR0209+PULA //"Horas: "
	cDescMemo+= STR0210+PULA //"    Horas que o funcionário trabalha na empresa."
	cDescMemo+= STR0211+ PULA //"Mês Dissídio: "
	cDescMemo+= STR0212+PULA //"    Mês do dissídio na empresa."
EndIf
	
If nOpcao == 6
	cTitulo  := STR0213 //"Descrição Detalhada do Cargo"
	cDescMemo:= STR0214 //"A descrição detalhada, auxilia para descrever melhor o cargo a ser pesquisado,"
	cDescMemo+= STR0215+PULA //"com maiores detalhes descritos para evitar dúvidas."
EndIf
	
If nOpcao == 7
	cTitulo  := STR0216 //"Especificação do Cargo"
	cDescMemo:= STR0217+PULA //"A especificação do cargo são os requisitos mínimos, necessários exigidos pelo cargo"
EndIf	

If nOpcao == 8 .Or. nOpcao == 15
	If nOpcao == 15
		cDescMemo += PULA+PULA
		cDescMemo += STR0218+PULA //"Fechar Pesquisa Salarial"
		cDescMemo += STR0219 //"O momento de fechar uma Pesquisa Salarial é quando todos os dados da pesquisa "
		cDescMemo += STR0220 + PULA //"foram informados, os dados são os da Empresa Participante e da Coleta."
		cDescMemo += STR0221 //"Quando se tiver a certeza de que a pesquisa pode ser encerrada, confirme "
		cDescMemo += STR0222+ PULA //"o seu encerramento."
		cDescMemo += STR0223  //"Ser  gerado um arquivo com o seguinte nome: PSAL9999.RET, onde 9999 é o código "
		cDescMemo += STR0224+PULA //"de controle interno para identificar a empresa participante."
		cDescMemo += STR0225 //"Observação: Caso queira alterar qualquer informação da Pesquisa "
		cDescMemo += STR0226 //"após o seu fechamento, somente renomeio o arquivo PSAL9999.RET para "
		cDescMemo += STR0227 //"PSAL.TXT, podendo assim continuar a informar os dados, mas "
		cDescMemo += STR0228 +PULA //"não se esquecendo, que se deve fazer o fechamento novamente."
	Else	
		cTitulo   := STR0218 //"Fechar Pesquisa Salarial"
		cDescMemo := STR0219 //"O momento de fechar uma Pesquisa Salarial é quando todos os dados da pesquisa "
		cDescMemo += STR0220 + PULA //"foram informados, os dados são os da Empresa Participante e da Coleta."
		cDescMemo += STR0221 //"Quando se tiver a certeza de que a pesquisa pode ser encerrada, confirme "
		cDescMemo += STR0222+ PULA //"o seu encerramento."
		cDescMemo += STR0223  //"Ser  gerado um arquivo com o seguinte nome: PSAL9999.RET, onde 9999 é o código "
		cDescMemo += STR0224+PULA //"de controle interno para identificar a empresa participante."
		cDescMemo += STR0225 //"Observação: Caso queira alterar qualquer informação da Pesquisa "
		cDescMemo += STR0226 //"após o seu fechamento, somente renomeio o arquivo PSAL9999.RET para "
		cDescMemo += STR0227 //"PSAL.TXT, podendo assim continuar a informar os dados, mas "
		cDescMemo += STR0228+PULA //"não se esquecendo, que se deve fazer o fechamento novamente."
	EndIf	
EndIf              

If 	nOpcao == 9 
	cTitulo   := STR0229 //"Região"
	cDescMemo := STR0230 //"Selecione a região onde se localiza a sua empresa e aperte o botão de Ok, "
	cDescMemo += STR0231 //"automaticamente o campo de região será preenchido com o código e "
	cDescMemo += STR0232+ PULA //"a descrição da região selecionada."
EndIf

If nOpcao == 10 
	cTitulo   := STR0233 //"Faturamento"
	cDescMemo := STR0234 //"Selecione aproximadamente o valor de faturamento da sua empresa e aperte o botão de Ok, "
	cDescMemo += STR0235 //"automaticamente o campo de faturamento será preenchido com o código e "
	cDescMemo += STR0236+ PULA //"a descrição do valor de faturamento selecionado."
EndIf

If nOpcao == 11 
	cTitulo   := STR0237 //"Ramo de Atividade"
	cDescMemo := STR0238 //"Selecione o ramo de atividade da sua empresa e aperte o botão de Ok, "
	cDescMemo += STR0239 //"automaticamente o campo de atividade será preenchido com o código e "
	cDescMemo += STR0240+ PULA //"a descrição da atividade selecionada."
EndIf

If nOpcao == 12 .And. nChamada == 2
	cTitulo   := STR0063 //"Cargos"
	cDescMemo := STR0241 //"Selecione o cargo correspondente ao da Pesquisa Salarial e aperte o botão de Ok, "
	cDescMemo += STR0242 //"após a seleção do Cargo, será gerado automaticamente os dados de frequência e "
	cDescMemo += STR0243+ PULA //"e salário."
EndIf

	DEFINE DIALOG oDlg TITLE STR0094 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL FONT oFont1 //"Help"

		@ aGdCoord[1],aGdCoord[2] TO aGdCoord[3],aGdCoord[4] PIXEL
		@ aGdCoord[1]+5,aGdCoord[2]+5 SAY cTitulo PIXEL OF oDlg SIZE 200,10 FONT oFont

		@ aGdCoord[1]+15,aGdCoord[2]+5	GET oMemo VAR cDescMemo MEMO SIZE aGdCoord[4]-20,aGdCoord[3]-30 PIXEL OF oDlg READONLY 
			
	    bSet15 := {|| oDlg:End()} //"&Sair"
	    bSet24 := {|| oDlg:End()} //"&Sair"
	ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15, bSet24, Nil, aButtons) CENTERED
	
Return .t.

// Funcao que trata a digitacao dos dados coletados da pesquisa salarial
Static Function EditDados(nKey,nCol,oObj,aDados,lKey,nRAnt)
Local nClick:= 0
Local cTemp := ""
Local lSim	:= .F.

If 	nChamada == 2       
	nCol := oObj:nColPos
EndIf	

If ( lKey )
	If nKey # 45 .And. nKey # 46 .And. nKey # 13
		Return Nil
	EndIf
		                                         
	If Len(aDados) <=0 .And. nKey==46
		Return Nil
	EndIf
				
	If nKey == 45 			//Inserir linha
		If FTudoOk(1,oObj:nAt,aDados)
			Aadd(aDados,{00000,0.00,0.00,0.00,0.00,0.00,"00",Ctod("  /  /  ")})
			lSim := .T.
		EndIf	
	ElseIf nKey == 46		// Apagar linha      
		aDel(aDados,oObj:nAt)
		aSize(aDados,Len(aDados)-1)						
		lSim := .T.
	EndIf
	
	
EndIf
	       
	If Len(aDados) <= 0
		If FTudoOk(1,oObj:nAt,aDados)
			Aadd(aDados,{00000,0.00,0.00,0.00,0.00,0.00,"00",Ctod("  /  /  ")})
			lSim := .T.
		EndIf	
	Endif
	
	If lSim	
		oObj:SetArray(aDados)
		oObj:bLine := {|| {	Transform(aDados[oObj:nAt,1],"99999"),;
								Transform(aDados[oObj:nAt,2],"99999,999.99"),;
								Transform(aDados[oObj:nAt,3],"99999,999.99"),;
								Transform(aDados[oObj:nAt,4],"99999,999.99"),;
								Transform(aDados[oObj:nAt,5],"999.99"),;
								Transform(aDados[oObj:nAt,6],"9999.99"),;
								aDados[oObj:nAt,7],;
								Transform(aDados[oObj:nAt,8],"@D 99/99/99")}}
		oObj:SetFocus()
		oObj:Refresh(.T.)
		Return Nil		
	EndIf	
	                            
If !Empty(nCol)
	If 	nChamada == 1
		nClick 	:= oObj:nAtCol(nCol)
	Else
		nClick  := nCol
	EndIf		
	cTemp	:=aDados[oObj:nAt][nClick]		                  
	If nClick == 1				// Frequencia
		If nChamada == 1
			If oObj:lEditCol(nClick,@cTemp,"99999",{||FVerif(nClick,cTemp)})
				aDados[oObj:nAt][nClick] := cTemp
			EndIf
		Else 
			lEditCel(aDados,oObj,"99999",nCol,{||FVerif(nClick,cTemp)})			
		EndIf	
	ElseIf nClick == 2 .Or. nClick == 3 .Or. nClick==4  
		If nChamada == 1
			If oObj:lEditCol(nClick,@cTemp,"99999,999.99",{||FVerif(nClick,cTemp)})
				aDados[oObj:nAt][nClick] := cTemp
			EndIf			
		Else                
			lEditCel(aDados,oObj,"99999,999.99",nCol,{||FVerif(nClick,cTemp)})
		EndIf	
	ElseIf nClick == 5	
		If nChamada == 1
			If oObj:lEditCol(nClick,@cTemp,"999.99")
				aDados[oObj:nAt][nClick] := cTemp
			EndIf	
		Else                                            
			lEditCel(aDados,oObj,"999.99",nCol)			
		EndIf	
	ElseIf nClick == 6                
		If nChamada == 1
			If oObj:lEditCol(nClick,@cTemp,"9999.99",{||FVerif(nClick,cTemp)})
				aDados[oObj:nAt][nClick] := cTemp
			EndIf					
		Else 
			lEditCel(aDados,oObj,"9999.99",nCol,{||FVerif(nClick,cTemp)})					
		EndIf	
	ElseIf nClick == 7  // Mes do dissidio             
		If nChamada ==1 
			If oObj:lEditCol(nClick,@cTemp,"@!",{||FVerif(nClick,cTemp)})
				aDados[oObj:nAt][nClick] := cTemp
			EndIf					
		Else
			lEditCel(aDados,oObj,"@!",nCol,{||FVerif(nClick,cTemp)})			
		EndIf	
	ElseIf nClick == 8	// Data Base 
		If nChamada ==1 
			If oObj:lEditCol(nClick,@cTemp,"@!",{||FVerif(nClick,cTemp)})
				aDados[oObj:nAt][nClick] := cTemp
			EndIf					
		Else
			lEditCel(aDados,oObj,"@!",nCol,{||FVerif(nClick,cTemp)})			
		EndIf		
	EndIf	
	oObj:SetFocus()
EndIf
	
oObj:DrawSelect()

Return NIL  


// Funcao que verifica o FF4 no Protheus
Static Function FF4Prot(nEstou)

If nEstou == "4"
	If 	ReadVar() == "1"
		nEstou := "1"                  
		FF4(nEstou,@cRegiao,@cDRegiao)
	ElseIf ReadVar() == "2"
		nEstou := "2"	      
		FF4(nEstou,@cFatur,@cDFatur)
	ElseIf ReadVar() =="3"
		nEstou := "3"                
		FF4(nEstou,@cAtivid,@cDAtivid)
	EndIf	
EndIf	

Return Nil


// Funcao que executa o F4 para montar o listbox do SX5
Static Function FF4(nEstou,cCod,cDescr)
Local oDlg, oLbx
Local oBtnOk, oBtnHlp
Local nLbx:= 0
Local aLbx:= {}                       
Local nF4 := 0
Local bSet15
Local bSet24
Local aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

If nEstou == "1"
	nF4		:= 9
	cTitulo := STR0244 //"Regiao da sua Empresa"
	aLbx 	:= aClone(aRC)
ElseIf nEstou == "2"
	nF4		:= 10
	cTitulo := STR0245 //"Faturamento da sua Empresa"
	aLbx 	:= aClone(aRE)	
ElseIf nEstou == "3"
	nF4		:= 11
	cTitulo := STR0246		 //"Ramo de Atividade da sua Empresa"
	aLbx 	:= aClone(aRD)	                                  
Else
	Return Nil	
EndIf
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 60	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 60	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*45), (((aObjSize[1,4])/100)*55) }	//1,3 Vertical /1,4 Horizontal
	

DEFINE DIALOG oDlg TITLE cTitulo FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL FONT oFont2

	@ aGdCoord[1],aGdCoord[2] LISTBOX oLbx VAR nLbx FIELDS HEADER STR0247,STR0248; //"Selecione"###"Codigo"
											COLSIZES	GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"),;
														GetTextWidth(0,"BBBB");
											SIZE aGdCoord[4],aGdCoord[3] OF oDlg PIXEL FONT oFont2
	
		oLbx:SetArray(aLbx)
		oLbx:bLine:= {||{aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,1]}}
   	
   	aAdd(aButtons, { Nil, { ||  FLeHelp(nF4)} , OemToAnsi(STR0040) } ) //"Help"		
	bSet15 := {|| cCod:= aLbx[oLbx:nAt,1],cDescr:=aLbx[oLbx:nAt,2],oDlg:End()}
    bSet24 := {|| oDlg:End()}
	
ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15, bSet24, Nil, aButtons) CENTERED 

Return Nil


// Funcao que verifica o codigo digitado nas tabela existentes
Static Function FVerTab(nEstou,cCod,cDescr,oObj)
Local nPos := 0

If Empty(cCod)
	Return .F.
EndIf	

If nEstou == 1				// Tabela RC - Regioes
	nPos:= Ascan(aRC,{|x| Alltrim(x[1]) == Alltrim(cCod)})
ElseIf nEstou == 3		// Tabela RD - Faturamento
	nPos:= Ascan(aRD,{|x| Alltrim(x[1]) == Alltrim(cCod)})
ElseIf nEstou == 2		// Tabela RE - Ramo de Atividade
	nPos:= Ascan(aRE,{|x| Alltrim(x[1]) == Alltrim(cCod)})
EndIf	

If nPos <= 0
	Return .F.
EndIf

If nEstou == 1
	cDescr := aRC[nPos][2]
ElseIf nEstou == 3
	cDescr := aRD[nPos][2]
ElseIf nEstou == 2
	cDescr := aRE[nPos][2]
EndIf

If !Empty(oObj)
	oObj:Refresh(.t.)
EndIf

Return .T.


// Funcao que gera o tipo 60 - Empresa Selecionada para ser gravado no TXT
Static Function FGera60()
Local nPos	:= 0
Local cTexto:= ""

nPos:= Ascan(aEmpresas,{|x| Alltrim(x[2]) == Alltrim(cEmpresa)})
If nPos > 0
	cTexto:= "60"							// Tipo				C	2
	cTexto+= Left(aEmpresas[nPos][1],50)	// Nome Empresa		C	50
	cTexto+= Left(cEmpresa,4)				// Codigo Empresa	C	4
	cTexto+= Left(aEmpresas[nPos][3],1)	// Porte			C	1
	cTexto+= Left(aEmpresas[nPos][4],4)	// Regiao			C	4
	cTexto+= Left(aEmpresas[nPos][5],3)	// Faturamento		C	3
	cTexto+= Left(aEmpresas[nPos][6],3)	// Atividade		C	3
	cTexto+= Left(aEmpresas[nPos][7],6)	// Nr Funcionario	C	6
	cTexto+= Left(aEmpresas[nPos][8],30)	// Contato			C	30	
	cTexto+= Left(aEmpresas[nPos][9],60)	// Email			C	60	
	cTexto+= Left(aEmpresas[nPos][10],15)	// Fone				C	15
	cTexto+= Space(22)
	cTexto+= cCRLF
	FWRITE(nHdlArq,cTexto,nTam) 
EndIf	
	
Return Nil	


// Funcao que gera o Tipo 70 - Dados da Coleta Informada para ser gravado no TXT
Static Function FGera70()
Local ny			:= 0
Local nx			:= 0
Local cCodCargo		:= ""
Local cCodFuncao	:= ""
Local cTexto		:= ""
Local aDadosCargo	:= {}

For ny := 1 To Len(a1Cargos)
	cCodCargo	:= a1Cargos[ny][1]
	cCodFuncao	:= a1Cargos[ny][5]
	aDadosCargo	:= aClone(a1Cargos[ny][3])
	For nx:=1 To Len(aDadosCargo)
		If aDadosCargo[nx][1] == 0
			Loop
		EndIf	
	
		cTexto:= "70"							// Tipo				C	2
		cTexto+= cCodCargo						// Codigo Cargo		C	5
		cTexto+= Str(aDadosCargo[nx][1],5)	// Frequencia		N 	5
		cTexto+= Str(aDadosCargo[nx][2],12,2)	// Salario			N	12	
		cTexto+= Str(aDadosCargo[nx][3],12,2)	// Vl Beneficio		N	12
		cTexto+= Str(aDadosCargo[nx][4],12,2)	// Adicionais 		N	12
		cTexto+= Str(aDadosCargo[nx][5],6,2)	// %Antecipacao  	N	6
		cTexto+= Str(aDadosCargo[nx][6],7,2)	// Horas  			N	7	
		cTexto+= aDadosCargo[nx][7]			// Dissidio			C	2	
		cTexto+= DtoC(aDadosCargo[nx][8])		// Data Base 		C	8	
		cTexto+= Substr(cCodFuncao,1,5)		// Cod Funcao		C	5
		cTexto+= Space(124)
		cTexto+= cCRLF
		FWRITE(nHdlArq,cTexto,nTam)
	Next nx	
Next ny

Return .T.


// Funcao que gera o Tipo 99 - Trailler do arquivo PSAL.TXT
Static Function FGera99()
Local cTexto	:= ""

cTexto	:= "99"						// Tipo                     C	2	
cTexto	+= STR0249+Space(188) //"GERADO OK "
cTexto	+= cCRLF
FWrite(nHdlArq,cTexto)                             
           
Return Nil	


// Funcao que monta a tela de mensagem do PSAL
Static Function FMens(cCaption,cMensagem,aBotoes)
Local ny       := 0
Local nx       := 0
Local nSize		:= 1
Local aSize		:= {	{134,304,35,155,35,113,51},; 	// Tamanho 1
					  		{134,450,35,155,35,185,51},;	// Tamanho 2
					  		{200,450,35,210,50,185,82} }	// Tamanho 3
Local bSet15
Local bSet24
Local aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

Private nOpcAviso	:= 0
Private oDlgAviso

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero de botoes Max. 5 e o tamanho da Msg.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	Len(aBotoes) > 3 
	If Len(cMensagem) > 286
		nSize := 3
	Else
		nSize := 2
	EndIf
Else
	Do Case
		Case Len(cMensagem) > 170 .And. Len(cMensagem) < 250
			nSize := 2
		Case Len(cMensagem) >= 250
			nSize := 3
		OtherWise
			nSize := 1
	EndCase
EndIf
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 60	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 60	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+38), (((aObjSize[1,3])/100)*50), (((aObjSize[1,4])/100)*55) }	//1,3 Vertical /1,4 Horizontal


DEFINE DIALOG oDlgAviso FROM aAdvSize[7]-15,0 TO aSize[nSize][1],aSize[nSize][2] TITLE OemtoAnsi(cCaption) PIXEL FONT oFont2

	@ aGdCoord[1]-20   ,aGdCoord[2]  SAY cCaption Of oDlgAviso PIXEL SIZE 35 ,9 FONT oFont2
	@ aGdCoord[1] ,aGdCoord[2]  SAY cMensagem Of oDlgAviso PIXEL SIZE aSize[nSize][6],aSize[nSize][5] FONT oFont2
	TButton():New(1000,1000," ",oDlgAviso,{||Nil},32,10,,,.F.,.T.,.F.,,.F.,,,.F.)
	ny := (aSize[nSize][2]/2)-36
	For nx:=1 to Len(aBotoes)
		cAction:="{||nOpcAviso:="+Str(Len(aBotoes)-nx+1)+",oDlgAviso:End()}"
		bAction:=&(cAction)
		TButton():New(aSize[nSize][7],ny,OemToAnsi(AllTrim(aBotoes[Len(aBotoes)-nx+1])), oDlgAviso,bAction,32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
		ny -= 35
	Next nx

ACTIVATE DIALOG oDlgAviso CENTERED

Return (nOpcAviso)


// Funcao que verifica campo a campo dos dados da coleta
Static Function FVerif(nClick,xValor)

If nClick == 1 		//Frequencia
	If Empty(xValor)
		FMens(STR0017,STR0250,{STR0003}) //"Atencao"###"Frequencia nao pode ser zero."###"Sair"
		Return .F.
	EndIf
ElseIf nClick == 2	//Salario
	If Empty(xValor)
		FMens(STR0017,STR0251,{STR0003}) //"Atencao"###"Valor do Salario nao pode ser zero."###"Sair"
		Return .F.
	EndIf
ElseIf nClick == 6	// Horas
	If Empty(xValor)
		FMens(STR0017,STR0252,{STR0003}) //"Atencao"###"Horas trabalhadas deve ser preenchida."###"Sair"
		Return .F.
	EndIf
ElseIf nClick == 7	// Mes Dissidio
	If Empty(xValor) .Or. Val(xValor) < 0 .Or. Val(xValor) > 12
		FMens(STR0017,STR0253,{STR0003}) //"Atencao"###"Mes do Dissidio Invalido."###"Sair"
		Return .F.
	EndIf
ElseIf nClick == 8	// Data Base
	If Empty(xValor)
		FMens(STR0017,STR0254,{STR0003}) //"Atencao"###"Data base deve ser preenchida."###"Sair"
		Return .F.
	EndIf	
EndIf			

Return .T.


// Funcao que verifica o listbox digitado com os dados da coleta.
Static Function FTudoOk(nEstou,nVer,aLbx)
Local nx	:= 0

If nEstou == 1			// Verificar somente a linha indicada por nVer
	If nVer > 0 .And. nVer <= Len(aLbx)
		If Empty(aLbx[nVer,1]) .Or. Empty(aLbx[nVer,2]) .Or. Empty(aLbx[nVer,6])
			FMens(STR0017,STR0255,{STR0003}) //"Atencao"###"Existem campos que nao foram preenchidos.Verifique os campo de Frequencia, Salario ou Horas"###"Sair"
			Return .F.
		EndIf	
		If Val(aLbx[nVer,7]) <= 0 .Or. Val(aLbx[nVer,7]) > 12
			FMens(STR0017,STR0256,{STR0003}) //"Atencao"###"Verifique o campo Mes Dissidio."###"Sair"
			Return .F.
		EndIf
		If Empty(aLbx[nVer,8])
			FMens(STR0017,STR0257,{STR0003}) //"Atencao"###"Verifique a Data Base."###"Sair"
			Return .F.
		EndIf			
	EndIf
ElseIf nEstou == 2 	// Verificar todo o lisbox
	For nx:=1 To Len(aLbx)
		If Empty(aLbx[nx,1]) .Or. Empty(aLbx[nx,2]) .Or. Empty(aLbx[nx,6])
			FMens(STR0017,STR0255,{STR0003}) //"Atencao"###"Existem campos que nao foram preenchidos.Verifique os campo de Frequencia, Salario ou Horas"###"Sair"
			Return .F.
		EndIf	
		If Val(aLbx[nx,7]) <= 0 .Or. Val(aLbx[nx,7]) > 12
			FMens(STR0017,STR0256,{STR0003}) //"Atencao"###"Verifique o campo Mes Dissidio."###"Sair"
			Return .F.
		EndIf
		If Empty(aLbx[nx,8]) 
			FMens(STR0017,STR0257,{STR0003}) //"Atencao"###"Verifique a Data Base."###"Sair"
			Return .F.
		EndIf		
	Next nx
EndIf

Return .T.


// Funcao que mostra os dados sobre o PSAL  
Static Function FSobre()
Local oDlgS
Local oBtnS
Local bSet15
Local bSet24
Local aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 60	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 50	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+10), (((aObjSize[1,3])/100)*40), (((aObjSize[1,4])/100)*55) }	//1,3 Vertical /1,4 Horizontal


DEFINE DIALOG oDlgS TITLE STR0258 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL FONT oFont2 //"Sobre..."

	@aGdCoord[1]+5,aGdCoord[2] SAY STR0259 PIXEL FONT oFont1 SIZE 200,7 //"Sistema: PSAL - Pesquisa Salarial e Beneficios"
	
	@aGdCoord[1]+15,aGdCoord[2] SAY STR0260 PIXEL FONT oFont1 SIZE 200,7 //"Versao: 8.11"
		
	@aGdCoord[1]+25,aGdCoord[2] SAY "http://www.totvs.com.br" PIXEL FONT oFont1 SIZE 200,7 COLOR CLR_BLUE
	@aGdCoord[1]+35,aGdCoord[2] SAY "ftp://ftp.totvs.com.br" PIXEL FONT oFont1 SIZE 200,7 COLOR CLR_BLUE
		
	bSet15 := {|| oDlgS:End()}
	bSet24 := {|| oDlgS:End()}
ACTIVATE DIALOG oDlgS ON INIT EnchoiceBar(oDlgS, bSet15, bSet24, Nil, aButtons) CENTERED
Return .T.


Static Function lEditCel(aCampos,oBrowse,cPict,nCol,bValid)
Local oDlg
Local oRect
Local oGet1
Local oBtn
Local cMacro := ''
Local nRow   := oBrowse:nAt
Local oOwner := oBrowse:oWnd

DEFAULT cPict := ''
DEFAULT nCol  := oBrowse:nColPos

  oRect := tRect():New(0,0,0,0)            // obtem as coordenadas da celula (lugar onde
  oBrowse:GetCellRect(nCol,,oRect)   // a janela de edicao deve ficar)
  aDim  := {oRect:nTop,oRect:nLeft,oRect:nBottom,oRect:nRight}

  DEFINE DIALOG oDlg OF oOwner  FROM 0, 0 TO 0, 0 STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL

  cMacro := "M->CELL"+StrZero(nRow,6)
  &cMacro:= aCampos[nRow,nCol]
  cPict  := cPict

  @ 0,0 GET oGet1 VAR &(cMacro) SIZE 0,0 OF oDlg FONT oOwner:oFont PICTURE cPict PIXEL ;
  		 VALID bValid
  oGet1:Move(-2,-2, (aDim[ 4 ] - aDim[ 2 ]) + 4, aDim[ 3 ] - aDim[ 1 ] + 4 )

  @ 0, 0 BUTTON oBtn PROMPT "ze" SIZE 0,0 OF oDlg
  oBtn:bGotFocus := {|| oDlg:nLastKey := VK_RETURN, oDlg:End(0)}

  oGet1:cReadVar  := cMacro

  ACTIVATE DIALOG oDlg ON INIT oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])

  aCampos[nRow,nCol] := &cMacro
  oBrowse:aArray[nRow,nCol] := &cMacro
  oBrowse:nAt := nRow
  SetFocus(oBrowse:hWnd)
  oBrowse:Refresh()

Return Nil


// Funcao que verifica cod do cargo correspondente qdo dentro do SIGA
Static Function FVerCargo(cCodCor,cFilCor,o1Lbx,a1Lbx)
Local nOpcao:= 0
Local aSaveArea	:= GetArea()
Local aPesquisa	:= {}                                      
Local nQuantos	:= 0
Local nSalario	:= 0
Local nx		:= 0
                         
If 	Empty(cCodCor)
	Return .T.
EndIf

nOpcao := FMens(STR0001,STR0261,{STR0092,"Não"}) //"Verifique"###"Confirma geração dos Dados para este Cargo?"###"Sim"

If 	nOpcao == 1		// Sim
	dbSelectArea("SRJ")
	dbSetOrder(4)
	If 	dbSeek(cFilCor+cCodCor)
		While !Eof() .And. cFilCor+cCodCor == SRJ->RJ_FILIAL+SRJ->RJ_CARGO
                 
			nQuantos := 0
			nSalario := SRJ->RJ_SALARIO
			dbSelectArea("SRA")
			dbSetOrder(7)
			If 	dbSeek(SRA->RA_FILIAL+SRJ->RJ_FUNCAO)	
				While !Eof() .And. SRA->RA_FILIAL+SRJ->RJ_FUNCAO == SRA->RA_FILIAL+SRA->RA_CODFUNC
					nQuantos := nQuantos + 1
					dbSkip()			
				EndDo
			EndIf

			Aadd(aPesquisa,{SRJ->RJ_FUNCAO,nQuantos,nSalario})						    
						
			dbSelectArea("SRJ")
			dbSetOrder(4)				
			dbSkip()
		EndDo 		
	EndIf		                                             
	
	a1Lbx:= {}
	For nx:=1 To Len(aPesquisa)
		Aadd(a1Lbx,{aPesquisa[nx][2],aPesquisa[nx][3],0.00,0.00,0.00,0.00,"00",CTOD("  /  /  ")})
	Next nx
	
	o1Lbx:SetArray(a1Lbx)
	o1Lbx:bLine := {|| {	Transform(a1Lbx[o1Lbx:nAt,1],"99999"),;
							Transform(a1Lbx[o1Lbx:nAt,2],"99999,999.99"),;
							Transform(a1Lbx[o1Lbx:nAt,3],"99999,999.99"),;
							Transform(a1Lbx[o1Lbx:nAt,4],"99999,999.99"),;
							Transform(a1Lbx[o1Lbx:nAt,5],"999.99"),;
							Transform(a1Lbx[o1Lbx:nAt,6],"9999.99"),;
							a1Lbx[o1Lbx:nAt,7],;
							Transform(a1Lbx[o1Lbx:nAt,8],"@D 99/99/99")}}
	o1Lbx:Refresh()
EndIf

RestArea(aSaveArea)
Return .T.


// Monstrar na tela um listbox com os dados do cargos para ser selecionado
Static Function FF6Prot(cCod,cDescr,cFilCor)
Local aLbx	:=	{}
Local oLbx, oDlg
Local nLbx	:= 0
Local bSet15
Local bSet24
Local aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 60	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 50	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+10), (((aObjSize[1,3])/100)*37), (((aObjSize[1,4])/100)*55) }	//1,3 Vertical /1,4 Horizontal

aAdd(aButtons, { Nil, { ||  FLeHelp(12)} , OemToAnsi(STR0040) } ) //"Help"

If  ReadVar() # "1"
	Return .T.
EndIf	
                   
dbSelectArea("SQ3")
dbSetOrder(1)
dbGotop()
While !Eof()
	aAdd(aLbx,{SQ3->Q3_CARGO,SQ3->Q3_DESCSUM,SQ3->Q3_FILIAL})
	dbSkip()
EndDo


DEFINE DIALOG oDlg TITLE STR0262 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL FONT oFont2 //"Selecione Cargo Correspondente"

	@ aGdCoord[1],aGdCoord[2] LISTBOX oLbx VAR nLbx FIELDS 	HEADER STR0263,STR0264; //"Cod Cargo"###"Descrição"
											COLSIZES 	GetTextWidth(0,"BBBBB"),;
														GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");
											SIZE aGdCoord[4],aGdCoord[3] OF oDlg PIXEL FONT oFont2
	
		oLbx:SetArray(aLbx)
		oLbx:bLine:= {||{aLbx[oLbx:nAt,1],aLbx[oLbx:nAt,2]}}

	bSet15 := {||cCod:= aLbx[oLbx:nAt,1],cDescr:=aLbx[oLbx:nAt,2],cFilCor:=aLbx[oLbx:nAt,3],oDlg:End()}
	bSet24 := {|| oDlg:End()}
ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15, bSet24, Nil, aButtons) CENTERED 
Return .t.

             
// Funcao chamada no momento de digitar os Dados da Coleta somente no Protheus
Static Function EditProt(nCol,oObj,aDados,lKey,nRAnt)

SETKEY( VK_F4,{|| EditDados(45,@nCol,@oObj,@aDados,.T.,@nRAnt)})
SETKEY( VK_F5,{|| EditDados(46,@nCol,@oObj,@aDados,.T.,@nRAnt)})

Return .T.
