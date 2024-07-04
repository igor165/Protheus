#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "CSAM040.CH"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CSAM040  ³ Autor ³ Cristina Ogura        ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera arquivo com os dados da Pesquisa Salarial             ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³18/07/14³TPZVUR³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function CSAM040()
Local cFiltra	:= ""		//Variavel para filtro
Local aIndFil	:= {}		//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

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
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0003)		//"Gera arquivo para Coleta dos Dados da Pesquisa Salarial."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RB1")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RB1","1")
bFiltraBrw 	:= {|| FilBrowse("RB1",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

dbSelectArea("RB1")
dbGotop()

mBrowse(6, 1, 22, 75, "RB1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("RB1",aIndFil)

dbSelectArea("RB1")
dbSetOrder(1)

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs040Txt      ³ Autor ³ Cristina Ogura   ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera arquivo TXT para Coleta da Pesquisa Salarial          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs040Txt(cAlias,nReg,nOpcx)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs040Txt(cAlias,nReg,nOpcx)     
Local oDlgMain, oMemo, oPatroc, oDPatroc, oCbx
Local dDtPesq		:= RB1->RB1_REAL
Local cDirPesq		:= ""
Local nOpca			:= 0
Local nOpc1			:= 0
Local a1Lbx			:= {}
Local a2Lbx			:= {}
Local aArqs			:= {}
Local cDescMemo		:= ""
Local cDescPatroc 	:= CriaVar("RB0->RB0_NOME",.F.)
Local cEmailPatroc	:= ""
Local nEnvia		:= 0
Local cAssunto		:= ""
Local cNomeDir		:= ""
Local cArqs			:= ""
Local cSays1		:= ""    
Local bExecuta
Local aButtons		:= { } //<== arrays locais de preferencia
local oProcess

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}   

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords	:= {}

Private aEmpresa	:= {}
Private aFuncao 	:= {}
Private cEmails		:= ""
Private cPesq		:= RB1->RB1_PESQ
Private cDescPesq 	:= RB1->RB1_DESCRI      
Private cFile		:= ""
Private nHandle		:= 0
Private cPatroc		:= CriaVar("RB0->RB0_EMPRES",.F.)
Private cCRLF

cCRLF := CHR(13)+CHR(10)  	//Windows

// Monta o nome do arquivo Txt
// Nome : "PSAL.TXT" 
cFile:="PSAL.TXT"
 
Pergunte("CSM040",.T.)             

nEnvia 	:= If(!Empty(mv_par01), mv_par01, 2 )
cAssunto:= If(!Empty(mv_par02), mv_par02, "")
cNomeDir:= If(!Empty(mv_par03), mv_par03, "")

// Le as Empresas e Funcoes da Pesquisa Salarial
Cs040RB4(@aEmpresa,@aFuncao)

// Monta o listbox das Empresas Participantes
Cs040Monta(1,@a1Lbx,aEmpresa)                        

// Monta o listbox das Funcoes
Cs040Monta(2,@a2Lbx,aFuncao)

// Nome interno a ser gerados o TXT
cDirPesq:= Alltrim(cNomeDir)+Alltrim(cFile)

// Variaveis para mostrar o SAY na tela
Aadd(aArqs,cDirPesq)
Aadd(aArqs,Alltrim(cNomeDir)+"PSAL.ZIP")
Aadd(aArqs,Alltrim(cNomeDir)+"LEIAME.TXT")
          
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 030 , .T. , .F. } )                                  ²
aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

aAdv1Size		:= aclone(aObjSize[5])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }					 
aAdd( aObj1Coords , { 000 , 000 , .T. , .T., .T. } )
aAdd( aObj1Coords , { 005 , 000 , .F. , .T. } )
aAdd( aObj1Coords , { 000 , 000 , .T. , .T., .T. } )       
aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T.  )   

aAdv2Size		:= aclone(aObjSize[1])
aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 5 }					 
aAdd( aObj2Coords , { 060 , 000 , .F. , .T. } )
aAdd( aObj2Coords , { 030 , 000 , .F. , .T. } )       
aAdd( aObj2Coords , { 110 , 000 , .F. , .T. } )       
aAdd( aObj2Coords , { 015 , 000 , .F. , .T. } )       
aAdd( aObj2Coords , { 015 , 000 , .F. , .T. } )       
aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords,,.T.  )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Modo de Acesso do SRJ com RB1 e RB4. Ambas devem ser iguais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF xRetModo( "SRJ" , "RB1" ) .And. xRetModo( "SRJ" , "RB4" )

   	If Empty(a1Lbx) .Or. Empty(a2Lbx)	
		//Caso Participantes/Funcoes da Pesquisa Salarial gerados com SRJ Exclusivo e RB4 Compartilhado
		Return .F.
	EndIf

	DEFINE MSDIALOG oDlgMain FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd  PIXEL
	
		@ aObjSize[1,1],aObj2Size[1,2]	SAY OemToAnsi(STR0004)	PIXEL 	//"Pesquisa Salarial: "
		@ aObjSize[1,1],aObj2Size[2,2]	MSGET cPesq			 	PIXEL SIZE 20,7 	WHEN .F.
		@ aObjSize[1,1],aObj2Size[3,2]	MSGET cDescPesq 		PIXEL SIZE 100,7 	WHEN .F.                  
		@ aObjSize[1,1],aObj2Size[4,2]	SAY	OemToAnsi(STR0005)	PIXEL	//"Data: "
		@ aObjSize[1,1],aObj2Size[5,2]	MSGET dDtPesq			PIXEL SIZE 45,7    	WHEN .F. HASBUTTON

		@ aObjSize[2,1],aObj2Size[1,2]	SAY OemtoAnsi(STR0013)	PIXEL 	//"Empr.Patrocinadora: "
		@ aObjSize[2,1],aObj2Size[2,2]	MSGET oPatroc		VAR cPatroc;
										F3 "RB0" PIXEL SIZE 20,7;
										VALID Cs040Patroc(@cPatroc,@cDescPatroc,oPatroc,oDPatroc,@cEmailPatroc) HASBUTTON
		@ aObjSize[2,1],aObj2Size[3,2]	MSGET oDPatroc		VAR cDescPatroc	PIXEL SIZE 200,7	WHEN .F.
		
		@ aObjSize[3,1],aObj2Size[1,2]	SAY OemToAnsi(STR0006)	PIXEL	//"Texto de Apresentacao:"	 
		@ aObjSize[3,1],aObj2Size[2,2]	GET oMemo VAR cDescMemo MEMO SIZE 234,30 PIXEL OF oDlgMain;
							                VALID oMemo:Refresh()
	
		oMemo:brClicked := {||AllwaysTrue()}	
		oMemo:bLostFocus:= {||oMemo:Refresh(.T.)}	
		
		@ aObjSize[4,1],aObj2Size[1,2]	SAY OemToAnsi(STR0007)	PIXEL			//"Arquivos gerados: "
	    @ aObjSize[4,1],aObj2Size[2,2]	COMBOBOX oCbx Var cArqs ITEMS aArqs SIZE 120, 105 OF oDlgMain PIXEL 
	    
		@ aObj1Size[1,1],aObj1Size[1,2] 	LISTBOX o1Lbx FIELDS;
					HEADER	OemtoAnsi(STR0008),OemToAnsi(STR0009) SIZE aObj1Size[1,3],aObj1Size[1,4] PIXEL	//"Participantes da Pesquisa Salarial"###"Codigo"
		o1Lbx:SetArray(a1Lbx)
		o1Lbx:bLine:= {||{	a1Lbx[o1Lbx:nAt,1],a1Lbx[o1Lbx:nAt,2]}}
							
		@ aObj1Size[3,1],aObj1Size[3,2] 	LISTBOX o2Lbx FIELDS;
					HEADER	OemtoAnsi(STR0010),OemToAnsi(STR0011) SIZE aObj1Size[3,3],aObj1Size[3,4] PIXEL	//"Funcao"###"Codigo"
		o2Lbx:SetArray(a2Lbx)
		o2Lbx:bLine:= {||{	a2Lbx[o2Lbx:nAt,1],a2Lbx[o2Lbx:nAt,2]}}
							
	ACTIVATE MSDIALOG oDlgMain ON INIT EnchoiceBar(oDlgMain,{||nOpca:=1,oMemo:Refresh(.T.),oDlgMain:End()},{|| nOpca := 2,oDlgMain:End()})
	

	If nOpca == 1         
		cSays1 := OemToAnsi(STR0017)						//"Este programa gera o arquivo PSAL.TXT, no diretório  especificado  no  parâmetro" 
		cSays1 := cSays1+CHR(13)+ OemToAnsi(STR0018)		//"'Nome do Diretório'. É importante que os arquivos LEIAME.TXT e  PSAL.ZIP estejam" 
		cSays1 := cSays1+CHR(13)+ OemToAnsi(STR0019)		//"no diretório \SYSTEM\, de acordo com a instalação do sistema. Conforme definição"
		cSays1 := cSays1+CHR(13)+ OemToAnsi(STR0020)		//"do  parâmetro 'Envia  e-mail  automaticamente?' ("Sim" / "Não"), esses  arquivos" 
		cSays1 := cSays1+CHR(13)+ OemToAnsi(STR0021)		//"serão enviados às empresas participantes da pesquisa salarial, ou permanecem"
		cSays1 := cSays1+CHR(13)+ OemToAnsi(STR0022)		//"disponíveis  no diretório especificado,  para futuro envio, respectivamente." 

		bExecuta:={|oSelf|Cs040Processa(cDirPesq,a1Lbx,cDescMemo,cNomeDir,cAssunto,cDescPatroc,cEmailPatroc,nEnvia,oSelf)}
		oProcess := tNewProcess():New(cCadastro,cCadastro,bExecuta,cSays1,,, .F.)
	EndIf

ENDIF

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs040Processa ³ Autor ³ Cristina Ogura   ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento da geração da pesquisa						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs040Processa(cDirPesq,a1Lbx,cDescMemo,cNomeDir,cAssunto,  ³±±
±±³          ³ cDescPatroc,cEmailPatroc,nEnvia)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs040Processa(cDirPesq,a1Lbx,cDescMemo,cNomeDir,cAssunto,cDescPatroc,cEmailPatroc,nEnvia, oProcess)

// Gera arquivo Txt da Pesquisa
cFile := cDirPesq
FGeraTxt(a1Lbx,cDescMemo)

// Copia os arquivos PSAL.ZIP, LEIAME.TXT e PSAL.TXT para o diretorio da pergunte
Cs040Copia(cNomeDir)
	
// Parametro para enviar email automaticamente	

If 	nEnvia == 1		
	MsgRun( OemToAnsi( STR0023 ),"",;
			{||Cs040Email(cDirPesq,cAssunto,cDescMemo,cDescPatroc,cEmailPatroc)})	//"Aguarde. Enviando Email..."
EndIf 

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FGeraTxt     ³ Autor ³ Cristina Ogura   ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que gera arquivo txt com os dados da Pesquisa      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FGeraTxt(a1Lbx,cDescMemo)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM040                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FGeraTxt(a1Lbx,cDescMemo)
Local cTexto	:= ""
Local nLinTotal	:= 0        
Local nx		:= 0
Local ny		:= 0
Local cCargo	:= ""
Local aFator	:= {}
Local cFil		:= ""
Local cDescDet	:= ""

nHandle := MSFCREATE(cFile)
If FERROR() # 0 .Or. nHandle < 0
	Help("",1,"Csm040HAND")		//Verifique o nome do arquivo gerado
	FClose(nHandle)
	Return Nil
EndIf               

// O arquivo TXT tera as 2 primeiras posicoes indicando o conteudo da linha:
// O tamanho do arquivo sera de 200 caracter
      
// Tipo 00 - Codigo Pesquisa + Descricao
cTexto:= "00" 				// Tipo                     C	2	
cTexto+= cPesq				// Codigo da Pesquisa   	C	4	
cTexto+= cDescPesq			// Descricao da Pesquisa	C   50
cTexto+= Space(144)
cTexto+= cCRLF
FWrite(nHandle,cTexto)

// Tipo 10 - Texto de Apresentacao
cTexto := ""      
nLinTotal := MlCount(cDescMemo,200)
For nx:=1 To nLinTotal 
	cTexto:= Memoline(cDescMemo,200,nx)	+ cCRLF
	FWrite(nHandle,cTexto)
Next nx
                                                  
// Tipo 20 - // Empresas Participantes
For nx:= 1 To Len(a1Lbx)
	cTexto:= "20"						// Tipo						C	02
	cTexto+=a1Lbx[nx][1]				// Nome da Participante		C	50
	cTexto+=a1Lbx[nx][2]				// Codigo do Participante	C	04
	cTexto+=Space(01)					// Porte					C	01	a1Lbx[nx][3]				
	cTexto+=Space(04)					// Regiao					C	04 a1Lbx[nx][4]
	cTexto+=Space(03)					// Faturamento				C	03	a1Lbx[nx][5]
	cTexto+=Space(03)					// Atividade				C	03	a1Lbx[nx][6]
	cTexto+=Space(06)					// Nr Funcionario			C	06 Str(a1Lbx[nx][7],6)		
	cTexto+=Space(30)					// Contato					C	30 a1Lbx[nx][8]
	cTexto+=Space(60)					// Email					C	60 a1Lbx[nx][9]
	cTexto+=Space(15)					// Fone						C	15 a1Lbx[nx][10]
	cTexto+=Space(22)
	cTexto+=cCRLF
	FWrite(nHandle,cTexto)		
Next nx

// Tipo 30 - Cargos
For nx:= 1 To Len(aFuncao)
    cCargo := ""
	FMontaFator(aFuncao[nx][2],aFuncao[nx][1],@cCargo,,,,@aFator)
	cFil := aFuncao[nx][2]	
	cFil := If ((cFil==Nil .Or. xFilial("SQ3"))== Space(FWGETTAMFILIAL),cFilial,cFil)	
	
	dbSelectArea("SQ3")
	dbSetOrder(1)
	If dbSeek(cFil+cCargo)
	
		cTexto:= "30" 							// Tipo                     C	2	
		cTexto+= "1"							// 1-Cod + Descr Sumaria	C	1
		cTexto+= cCargo							// Codigo do Cargos     	C	5
		cTexto+= Substr(SQ3->Q3_DESCSUM,1,30)	// Descricao da Pesquisa	C   30
		cTexto+= aFuncao[nx][2]				// Codigo da Filial			C	2	
		cTexto+= aFuncao[nx][1]				// Codigo da Funcao			C	5	
		cTexto+= DESCFUN(aFuncao[nx][1],xFilial("SRJ"),20)	// Descricao da Funcao C	20
		nContTex := 200 - Len(cTexto)
		cTexto+= Space(nContTex)
		cTexto+=cCRLF
		FWrite(nHandle,cTexto)		

		cTexto := ""
		cDescDet := MSMM(SQ3->Q3_DESCDET)
		nLinTotal := MlCount(cDescDet,197)
		For ny:=1 To nLinTotal 
			cTexto:= Memoline(cDescDet,197,ny)	+ cCRLF
			FWrite(nHandle,"302"+cTexto)
		Next ny

		For ny:= 1 To Len(aFator) Step 2
			cTexto:= "30" 							// Tipo                     C	2	
			cTexto+= "3"							// 1-Especificacao do Cargo	C	1
			cTexto+= aFator[ny][1]					// Fator					C	2
			cTexto+= Space(01)						// Espaco					C	1
			cTexto+= aFator[ny][2]					// Descricao do Fator		C	30
			cTexto+= Space(02)						// Espaco					C	2
			cTexto+= aFator[ny][3]					// Grau do Fator			C	2
			cTexto+= Space(01)						// Espaco					C	1
			cTexto+= aFator[ny][4]					// Descricao do Grau		C	30
			If 	ny+1 <= Len(aFator)
				cTexto+= "*"						// Separador				C	1
				cTexto+= aFator[ny+1][1]			// Fator					C	2
				cTexto+= Space(01)					// Espaco					C	1
				cTexto+= aFator[ny+1][2]			// Descricao do Fator		C	30
				cTexto+= Space(02)					// Espaco					C	2
				cTexto+= aFator[ny+1][3]			// Grau do Fator			C	2
				cTexto+= Space(01)					// Espaco					C	1
				cTexto+= aFator[ny+1][4]			// Descricao do Grau		C	30
			Else
				cTexto+= Space(69)	
			EndIf
			cTexto+=Space(60)+cCRLF
			FWrite(nHandle,cTexto)		
	    Next ny
	EndIf	    
Next nx

// Tipo 40 - Tabelas do Sistemas                               
Cs040SX5("RC")            // Regioes
                                    
Cs040SX5("RD")            // Atividade  

Cs040SX5("RE")            // Faturamento
                            
dbSelectArea("RB0")
dbSetOrder(1)
dbSeek(xFilial("RB0")+cPatroc)

// Tipo 50 - Empresa Patrocinadora
cTexto:= "50" 									// Tipo                     C	2	
cTexto+= "1"									// Identificador 					C 	1
cTexto+= Subst(RB0->RB0_EMPRES,1,4)			// Codigo da Patrocinador	C	4	
cTexto+= Subst(RB0->RB0_NOME,1,50)			// Nome da Patrocinadora	C   50
cTexto+= Subst(RB0->RB0_ENDERE,1,30)			// Endereco             	C   30
cTexto+= Subst(RB0->RB0_CIDADE,1,30)			// Cidade               	C   30
cTexto+= Subst(RB0->RB0_ESTADO,1,02)			// Estado               	C   2 
cTexto+= Space(81)
cTexto+= cCRLF
FWrite(nHandle,cTexto)

cTexto:= "50" 									// Tipo                     C	2	
cTexto+= "2"									// Identificador 					C 	1
cTexto+= Subst(RB0->RB0_CONTAT,1,30)			// Contato              	C   30
cTexto+= Subst(RB0->RB0_FONE,1,15)			// Fone                 	C   15
cTexto+= Subst(RB0->RB0_EMAIL,1,60)			// Email                 	C   60
cTexto+= Space(92)
cTexto+= cCRLF
FWrite(nHandle,cTexto)

// Tipo 99 - Fim
cTexto:= "99" 							// Tipo                     C	2	
cTexto+= Space(198)
cTexto+= cCRLF
FWrite(nHandle,cTexto)

FClose(nHandle)

Return Nil                    

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs040Monta   ³ Autor ³ Cristina Ogura   ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta array com os dados do Participante ou da Funcao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs040Monta(nQual,aArray,aDados)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM040                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs040Monta(nQual,aArray,aDados)
Local nx	:= 0

For nx:=1 To Len(aDados)
	If 	nQual == 1			// Empresas Participantes
		dbSelectArea("RB0")
		dbSetOrder(1)
		If 	dbSeek(xFilial("RB0")+aDados[nx][1])
			Aadd(aArray,{	RB0->RB0_NOME,RB0->RB0_EMPRES,RB0->RB0_PORTE,;
							RB0->RB0_REGIAO,RB0->RB0_FATURA,RB0->RB0_ATIVID,;
							RB0->RB0_NRFUNC,RB0->RB0_CONTAT,RB0->RB0_EMAIL,;
							RB0->RB0_FONE})

			If 	Empty(cEmails)							
				cEmails := Alltrim(RB0->RB0_EMAIL) + ";"
			Else				
				cEmails := cEmails + Alltrim(RB0->RB0_EMAIL) + ";"
			EndIf	
		EndIf		
	ElseIf nQual == 2		// Funcoes
		dbSelectArea("SRJ")
		dbSetOrder(1)
		If	dbSeek(xFilial("SRJ")+aDados[nx][1])	
			Aadd(aArray,{SRJ->RJ_DESC,SRJ->RJ_FUNCAO})
		EndIf
	EndIf
Next nx

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs040RB4     ³ Autor ³ Cristina Ogura   ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta array da Empresa e da Funcao do arquivo RB4.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs040RB4()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM040                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs040RB4()
Local aSaveArea	:= GetArea()

dbSelectArea("RB4")
dbSetOrder(1)
If dbSeek(xFilial("RB4")+cPesq)
	While !Eof() .And.	xFilial("RB4")+cPesq ==;
				        RB4->RB4_FILIAL+RB4->RB4_PESQ
                
		If !Empty(RB4->RB4_EMPRES)
			Aadd(aEmpresa,{RB4->RB4_EMPRES,RB4->RB4_FILIAL})
		EndIf	
		
		If !Empty(RB4->RB4_FUNCAO)	
			Aadd(aFuncao,{RB4->RB4_FUNCAO,RB4->RB4_FILIAL})
		EndIf
		
		dbSkip()
	EndDo					         
EndIf

RestArea(aSaveArea)

Return Nil      

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs040Dir     ³ Autor ³ Cristina Ogura   ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica o diretorio que sera gravado o arquivo TXT.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs040Dir(cDirPesq)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM040                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs040Dir()
Local _mvRet  := Alltrim(ReadVar())
Local _cPath  := mv_par03

_oWnd := GetWndDefault()

_cPath:=cGetFile(OemtoAnsi(STR0014),OemToAnsi(STR0012),0,,.F.,GETF_RETDIRECTORY+GETF_LOCALFLOPPY+GETF_LOCALHARD) //"Arquivos para Pesquisa Salarial"###"Selecione Diretorio"

&_mvRet := _cPath

If _oWnd != Nil
	GetdRefresh()
EndIf

Return .T.   
                              
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs040SX5     ³ Autor ³ Cristina Ogura   ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Le do SX5 as tabelas para ser gravadas no TXT.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs040SX5(cTabela)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM040                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs040SX5(cTabela)
Local aTabela 	:= {}
Local nx		:= 0

dbSelectArea("SX5")                                                         
dbSetOrder(1)
If 	dbSeek(xFilial("SX5")+cTabela)	
	While !Eof() .And. xFilial("SX5")+cTabela== SX5->X5_FILIAL+SX5->X5_TABELA 
		Aadd(aTabela,Substr(SX5->X5_CHAVE,1,4)+Space(01)+Substr(SX5->X5_DESCRI,1,30))
		dbSkip()
	EndDo
EndIf     
For nx := 1 To Len(aTabela) Step 5
	cTexto:= "40" 							// Tipo '''                 C	2	
	cTexto+= cTabela						// Tabela					C	2
	cTexto+= aTabela[nx]					// Codigo 					C	35
	If nx+1 <= Len(aTabela)
		cTexto+= "*"						// Separador				C	1
		cTexto+= aTabela[nx+1]				// Codigo					C	35
	Else
		cTexto+= Space(36)					// Espaco					C	36
	EndIf	                     
	If nx+2 <= Len(aTabela)
		cTexto+= "*"						// Separador				C	1	
		cTexto+= aTabela[nx+2]				// Codigo 					C	35
	Else
		cTexto+= Space(36)					// Espaco					C	36
	EndIf	
	If nx+3 <= Len(aTabela)
		cTexto+= "*"						// Separador				C	1	
		cTexto+= aTabela[nx+3]				// Codigo					C	35
	Else
		cTexto+= Space(36)					// Espaco					C	36
	EndIf
	If nx+4 <= Len(aTabela)	
		cTexto+= "*"						// Separador				C	1		
		cTexto+= aTabela[nx+4]				// Codigo					C	35
	Else
		cTexto+= Space(36)					// Espaco					C	36
	EndIf	                                                              
	cTexto+=Space(17)+cCRLF					// Espaco					C	17
	FWrite(nHandle,cTexto)		
Next nx
           
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs040Patroc  ³ Autor ³ Cristina Ogura   ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica os dados do patrocinador da Pesquisa             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs040Patroc()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM040                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs040Patroc(cPatroc,cDescPatroc,oPatroc,oDPatroc,cEmailPatroc)

dbSelectArea("RB0")
dbSetOrder(1)
If !dbSeek(xFilial("RB0")+cPatroc)
	Help("",1,"Cs040NOCAD")
	Return .F.
EndIf

cPatroc 	:= RB0->RB0_EMPRES
cDescPatroc := RB0->RB0_NOME
cEmailPatroc:= RB0->RB0_EMAIL

oPatroc:Refresh(.T.)

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs040Email   ³ Autor ³ Cristina Ogura   ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que envia os emails para as Empresas Participantes ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs040Email()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM040                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs040Email(cDirPesq,cAssunto,cMensagem,cDescPatroc,cEmailPatroc)

Local lOk		:= .F.		// Variavel que verifica se foi conectado OK
Local lSendOk	:= .F.		// Variavel que verifica se foi enviado OK
Local cError	:= ""
Local cAttach1	:= ""
Local cAttach2	:= "" 
Local cAttach3	:= ""
Local cEmailTo	:= ""
Local cEmailBcc	:= ""
Local lMailAuth	:= SuperGetMv("MV_RELAUTH",,.T.)
Local cMailAuth := ""      
Local lResult	:= .F.
Local cAtuDir 	:= ""

Private cMailConta	:= Nil
Private cMailServer	:= Nil
Private cMailSenha	:= Nil

cMailConta	:= If(cMailConta 	== NIL,GETMV("MV_EMCONTA"),cMailConta)
cMailServer	:= If(cMailServer 	== NIL,GETMV("MV_RELSERV"),cMailServer)
cMailSenha	:= If(cMailSenha 	== NIL,GETMV("MV_EMSENHA"),cMailSenha)

//Verifica se existe o SMTP Server
If 	Empty(cMailServer)
	Help(" ",1,"SEMSMTP")//"O Servidor de SMTP nao foi configurado !!!" ,"Atencao"
	Return(.F.)
EndIf

//Verifica se existe a CONTA 
If 	Empty(cMailServer)
	Help(" ",1,"SEMCONTA")//"A Conta do email nao foi configurado !!!" ,"Atencao"
	Return(.F.)
EndIf

//Verifica se existe a Senha
If 	Empty(cMailServer)
	Help(" ",1,"SEMSENHA")	//"A Senha do email nao foi configurado !!!" ,"Atencao"
	Return(.F.)
EndIf                                              
  
If !Empty ( AllTrim( cAtuDir := GetPvProfString( GetEnvServer(), "StartPath", "", GetADV97() ) ) )
	If !( Subst( cAtuDir , 1 , 1 ) $ "\/" )
		cAtuDir := "\"+cAtuDir
	EndIf   
	If !( Subst( cAtuDir , -1	) $ "\/" )
		cAtuDir += "\"
	EndIf  
EndIf
                
#IFNDEF TOP
	MSCOPYFILE(cDirPesq, cAtuDir+"PSAL.TXT")
#ELSE
	__COPYFILE(cDirPesq, cAtuDir+"PSAL.TXT")
#ENDIF

cAttach1:= Alltrim(cAtuDir) + "PSAL.TXT"
cAttach2:= Alltrim(cAtuDir) + "PSAL.ZIP"
cAttach3:= Alltrim(cAtuDir) + "LEIAME.TXT" 

/*cMensagem
"A empresa patrocinadora da Pesquisa Salarial, "
"através do sistema da Microsiga, possibilita que a Coleta de Dados "
"seja feita sem utilizar qualquer formulário para o seu preenchimento."
"Seguem os três arquivos necessários ao processo de Coleta automatizada. "
"Abra o arquivo LEIAME.TXT e siga as instruções nele contidas."
*/


cMensagem:= cMensagem + cCRLF   + cCRLF
cMensagem:= cMensagem + STR0024 + cDescPatroc
cMensagem:= cMensagem + STR0025
cMensagem:= cMensagem + STR0026 + cCRLF
cMensagem:= cMensagem + STR0027
cMensagem:= cMensagem + STR0028    

// Sempre enviar o mesmo email para o Patrocinador da Pesquisa Salarial
cEmailTo := Alltrim(cEmailPatroc)
cEmailBcc:= cEmails
                                
// Envia e-mail com os dados necessarios
If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha) 
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a autenticacao no servidor SMTP                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMailAuth
		If ( "@" $ cMailConta )
			cMailAuth := Subs(cMailConta,1,At("@",cMailConta)-1)
		Else
			cMailAuth := cMailConta
		EndIf
		lResult := MailAuth(cMailAuth,cMailSenha)
	Else
		lResult := .T. //Envia E-mail
	Endif	
	
	If 	lOk .And. lResult                                                                        
		SEND MAIL 	FROM cMailConta;
					TO cEmailTo;
 					BCC cEmailBcc;					
					SUBJECT cAssunto;
					BODY cMensagem;  
					ATTACHMENT cAttach1,cAttach2,cAttach3;					
					RESULT lSendOk 
		If !lSendOk
			//Erro no Envio do e-mail
			GET MAIL ERROR cError
			MsgInfo(cError,OemToAnsi(STR0015)) //"Erro no envio de Email" 		
		EndIf
		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		MsgInfo(cError,OemToAnsi(STR0015)) // "Erro no envio de Email"
	EndIf
EndIf                   
  
Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs040Copia	³ Autor ³ Marcos Alves     ³ Data ³ 28/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Copia os arquivos PSAL.ZIP, LEIAME.TXT e PSAL.TXT para    ³±±
±±³          ³ o diretorio da pergunte                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs040Copia(cNomeDir)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM040                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs040Copia(cNomeDir)
Local cAtuDir := ""
  
IF !Empty ( AllTrim( cAtuDir := GetPvProfString( GetEnvServer(), "StartPath", "", GetADV97() ) ) )
	IF !( Subst( cAtuDir , 1 , 1 ) $ "\/" )
		cAtuDir := "\"+cAtuDir
	EndIF   
	IF !( Subst( cAtuDir , -1	) $ "\/" )
		cAtuDir += "\"
	EndIF  
EndIf
                                  
cNomeDir := Alltrim(cNomeDir)                                       

#IFNDEF TOP
	MSCOPYFILE(cAtuDir+"PSAL.ZIP"	,cNomeDir+"PSAL.ZIP")
	MSCOPYFILE(cAtuDir+"LEIAME.TXT",cNomeDir+"LEIAME.TXT")
#ELSE
	__COPYFILE(cAtuDir+"PSAL.ZIP"	,cNomeDir+"PSAL.ZIP")
	__COPYFILE(cAtuDir+"LEIAME.TXT",cNomeDir+"LEIAME.TXT")
#ENDIF 	

Return .T.

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³28/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³CSAM040                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   

Static Function MenuDef()

 Local aRotina :=  {	{ STR0001,'PesqBrw',0,1,,.F.},;		//"Pesquisar"
						{ STR0002,'Cs040Txt', 0,4}}	//"Gerar Texto"						

Return aRotina
