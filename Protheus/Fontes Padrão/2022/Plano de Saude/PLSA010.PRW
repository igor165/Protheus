#Include "PLSMGER.CH"
#Include "PLSA010.CH"
#Include "PROTHEUS.CH"
#Include "COLORS.CH"
STATIC objCENFUNLGP := CENFUNLGP():New() 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA010 ³ Autor ³ Tulio Cesar          ³ Data ³ 23.05.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Operadoras   de Saude                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus 5.07                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA010
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina		:= MenuDef()
PRIVATE cCadastro	:= Oemtoansi(STR0007) //"Operadora de Saude"
PRIVATE	aNoTrig		:= {.F.,.F.,.F.,.F.}
PRIVATE cDadoAux := ""						// Criada para SXB Especifica BICPLS devido o erro na CONDPAD1 (Type mismath)
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama funcao de Browse...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA0->(DbSetOrder(1))
BA0->(dbGoTop())
BA0->(mBrowse(06,01,22,75,"BA0"))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PL010MOV ³ Autor ³ Tulio                 ³ Data ³ 23.02.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modulo de Manutencao das Localidades                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PL010MOV(cAlias,nReg,nOpc)                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL010MOV(cAlias,nReg,nOpc)
Local I__f := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Uso na enchoice...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOpca := 0

Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local aVetGet02 :={}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados da Enchoice...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE oEncBD1 
PRIVATE oDlg
PRIVATE oFolder
PRIVATE aCols   := {}
PRIVATE aHeader := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados dos Contatos por Departamento ...                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabCon := {}
PRIVATE aDadCon := {}
PRIVATE aTrbCon := {}
PRIVATE oBrwCon
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados dos Areas de Acao ...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabAre := {}
PRIVATE aDadAre := {}
PRIVATE aTrbAre := {}
PRIVATE oBrwAre
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados das Regioes de Atuacao...                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabReg := {}
PRIVATE aDadReg := {}
PRIVATE aTrbReg := {}
PRIVATE oBrwReg
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados do Organograma...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabOrg := {}
PRIVATE aDadOrg := {}
PRIVATE aTrbOrg := {}
PRIVATE oBrwOrg
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados do Cobranca de Identificacao de Usuario                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBJA := {}
PRIVATE aDadBJA := {}
PRIVATE aTrbBJA := {}
PRIVATE oBrwBJA
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados da Previsao de Pagamento de Reembolso                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBJS := {}
PRIVATE aDadBJS := {}
PRIVATE aTrbBJS := {}
PRIVATE oBrwBJS
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Operadora   X Layout IMP/EXP                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBU9 := {}
PRIVATE aDadBU9 := {}
PRIVATE aTrbBU9 := {}
PRIVATE oBrwBU9
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Operadora  X Doc. de Usuarios                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBCN := {}
PRIVATE aDadBCN := {}
PRIVATE aTrbBCN := {}
PRIVATE oBrwBCN
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Operadora  X Informações ANS                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabB07 := {}
PRIVATE aDadB07 := {}
PRIVATE aTrbB07 := {}
PRIVATE oBrwB07
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados dos TISS WEBSERVICES ...                          			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabB0F := {}
PRIVATE aDadB0F := {}
PRIVATE aTrbB0F := {}
PRIVATE oBrwB0F
PRIVATE cChave  := BA0->(BA0_CODIDE+BA0_CODINT)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Genericos...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nOpcx   := nOpc 



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialogo...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> K_Incluir
   cCadastro := OemtoAnsi(STR0008)+BA0->BA0_NOMINT //"Operadora de Saude - "
Else
   cCadastro := OemtoAnsi(STR0008) //"Operadora de Saude"
Endif

aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 100, 100, .t., .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL 

CursorWait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Folder...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPosObj[1][1],aPosObj[1][2]  FOLDER oFolder SIZE aPosObj[1][3],aPosObj[1][4] OF oDlg PIXEL;
													PROMPTS	OemtoAnsi(STR0009),;	//"Operadoras de Saúde"
															OemtoAnsi(STR0012),;	//"Contatos por Depto."
															OemtoAnsi(STR0013),;	//"Cargo Social" 
															OemtoAnsi(STR0019),;	//"Vinculo entre operadoras"
															OemtoAnsi(STR0016),;	//"Cobrança de Identificação de Usuário"
															OemtoAnsi(STR0017),;	//"Previsao Pagamento Reembolso"
															OemtoAnsi(STR0018),; 	//"Doc. obrigat. dos Usuarios"
															OemtoAnsi("Informações ANS"),;
															OemtoAnsi(STR0026) 		//"TISS WebService"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CONTATOS POR DEPARTAMENTO ...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BIM" TO aCabCon For .T.
If nOpcx == K_Incluir
   n := 1
   Store COLS Blank "BIM" TO aDadCon FROM aCabCon
Else
   BIM->(DbSetOrder(1))
   If ! BIM->(MsSeek(xFilial("BIM")+cChave)) 
 	   n := 1
       Store COLS Blank "BIM" TO aDadCon FROM aCabCon
   Else
 	   n := 1
       Store COLS "BIM" TO aDadCon FROM aCabCon VETTRAB aTrbCon While BIM->BIM_CODINT == cChave
   Endif                                  
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ COBRANCA DE IDENTIFICACAO DE USUARIOS                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BJA" TO aCabBJA For .T.
If nOpcx == K_Incluir
   n := 1
   Store COLS Blank "BJA" TO aDadBJA FROM aCabBJA
Else
   BJA->(DbSetOrder(1))
   If ! BJA->(MsSeek(xFilial("BJA")+cChave)) 
 	   n := 1
       Store COLS Blank "BJA" TO aDadBJA FROM aCabBJA
   Else
 	   n := 1
       Store COLS "BJA" TO aDadBJA FROM aCabBJA VETTRAB aTrbBJA While BJA->BJA_CODINT == cChave
   Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PREVISAO DE PAGAMENTO DE REEMBOLSO                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BJS" TO aCabBJS For .T.
If nOpcx == K_Incluir
   n := 1
   Store COLS Blank "BJS" TO aDadBJS FROM aCabBJS
Else
   BJS->(DbSetOrder(1))
   If ! BJS->(MsSeek(xFilial("BJS")+cChave)) 
 	   n := 1
       Store COLS Blank "BJS" TO aDadBJS FROM aCabBJS
   Else
 	   n := 1
       Store COLS "BJS" TO aDadBJS FROM aCabBJS VETTRAB aTrbBJS While BJS->BJS_CODINT == cChave
   Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AREAS DE ACAO    ...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BIA" TO aCabAre For .T.
If nOpcx == K_Incluir
   Store COLS Blank "BIA" TO aDadAre FROM aCabAre
Else
   BIA->(DbSetOrder(1))
   If ! BIA->(MsSeek(xFilial("BIA")+cChave)) 
       Store COLS Blank "BIA" TO aDadAre FROM aCabAre
   Else
       Store COLS "BIA" TO aDadAre FROM aCabAre VETTRAB aTrbAre While BIA->BIA_CODINT == cChave
   Endif                                  
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ REGIOES DE ATUACAO...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*Store Header "BIJ" TO aCabReg For .T.
If nOpcx == K_Incluir
   Store COLS Blank "BIJ" TO aDadReg FROM aCabReg
Else
   BIJ->(DbSetOrder(1))
   If ! BIJ->(MsSeek(xFilial("BIJ")+cChave)) 
       Store COLS Blank "BIJ" TO aDadReg FROM aCabReg
   Else
       Store COLS "BIJ" TO aDadReg FROM aCabReg VETTRAB aTrbReg While BIJ->BIJ_CODINT == cChave
   Endif                                  
Endif*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SOCIAL ...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BIF" TO aCabOrg For .T.
If nOpcx == K_Incluir
   Store COLS Blank "BIF" TO aDadOrg FROM aCaborg
Else
   BIF->(DbSetOrder(1))
   If ! BIF->(MsSeek(xFilial("BIF")+cChave)) 
       Store COLS Blank "BIF" TO aDadOrg FROM aCabOrg
   Else
       Store COLS "BIF" TO aDadOrg FROM aCabOrg VETTRAB aTrbOrg While BIF->BIF_CODINT == cChave
   Endif                                  
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Layout  X Operadora                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BU9" TO aCabBU9 For .T.
If nOpcx == K_Incluir
   Store COLS Blank "BU9" TO aDadBU9 FROM aCabBU9
Else
   BU9->(DbSetOrder(1))
   If ! BU9->(MsSeek(xFilial("BU9")+cChave)) 
       Store COLS Blank "BU9" TO aDadBU9 FROM aCabBU9
   Else
       Store COLS "BU9" TO aDadBU9 FROM aCabBU9 VETTRAB aTrbBU9 While BU9->BU9_CODOPE == cChave
   Endif                                  
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Doc Usuarios  X Operadora                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BCN" TO aCabBCN For .T.
If nOpcx == K_Incluir
   Store COLS Blank "BCN" TO aDadBCN FROM aCabBCN
Else
   BCN->(DbSetOrder(1))
   If ! BCN->(MsSeek(xFilial("BCN")+cChave)) 
       Store COLS Blank "BCN" TO aDadBCN FROM aCabBCN
   Else
       Store COLS "BCN" TO aDadBCN FROM aCabBCN VETTRAB aTrbBCN While BCN->BCN_CODOPE == cChave
   Endif                                  
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informações ANS                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEXI("B07")
	Store Header "B07" TO aCabB07 For .T.
	If nOpcx == K_Incluir
	   Store COLS Blank "B07" TO aDadB07 FROM aCabB07
	Else
	   B07->(DbSetOrder(1))
	   If ! B07->(MsSeek(xFilial("B07")+cChave)) 
	       Store COLS Blank "B07" TO aDadB07 FROM aCabB07
	   Else
	       Store COLS "B07" TO aDadB07 FROM aCabB07 VETTRAB aTrbB07 While B07->B07_CODINT == cChave
	   Endif                                  
	Endif
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TISS WEBSERVICES		 ...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEXI("B0F")
	Store Header "B0F" TO aCabB0F For .T.
	If nOpcx == K_Incluir
	   n := 1
	   Store COLS Blank "B0F" TO aDadB0F FROM aCabB0F
	Else
	   B0F->(DbSetOrder(1))
	   If ! B0F->(MsSeek(xFilial("B0F")+cChave)) 
	 	   n := 1
	       Store COLS Blank "B0F" TO aDadB0F FROM aCabB0F
	   Else
	 	   n := 1
	       Store COLS "B0F" TO aDadB0F FROM aCabB0F VETTRAB aTrbB0F While B0F->B0F_CODINT == cChave
	   Endif                                  
	Endif
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ENCHOICE (BD1)                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx <> K_Incluir
   BA0->(DbGoTo(nReg))
Endif   

If nOpcx == K_Incluir
   Copy "BA0" TO Memory Blank
Else
   Copy "BA0" TO Memory
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MSMGET -> CONTRATO                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias:="BA0";oEncBD1 := MSMGet():New(cAlias,nReg,nOpcx,,,,,{aPosObj[1][1],aPosObj[1][2],aPosObj[1][4]-15,aPosObj[1][3]-3},,,,,,oFolder:aDialogs[1],,,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GETDADOS -> CONTATOS POR DEPARTAMENTO ...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                                            
oBrwCon := TPLSBrw():New(003,005,aPosObj[1][3]-5,aPosObj[1][4]-15, nil  ,oFolder:aDialogs[2], nil , nil , nil ,nil   ,nil, .T.   , nil ,.T.   ,nil   ,aCabCon,aDadCon,.F.,"BIM",nOpcx,STR0020) //"Contatos por Departamento"
oBrwCon:aVetTrab := aClone(aTrbCon)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GETDADOS -> ORGANOGRAMA...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwOrg := TPLSBrw():New(003,005,aPosObj[1][3]-5,aPosObj[1][4]-15, nil  ,oFolder:aDialogs[3], nil , nil , nil ,nil   ,nil, .T.   , nil ,.T.   ,nil   ,aCabOrg,aDadOrg,.F.,"BIF",nOpcx,STR0013) //"Cargo Social"
oBrwOrg:aVetTrab := aClone(aTrbOrg)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GETDADOS -> AREAS DE ACAO ...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwAre := TPLSBrw():New(003,005,aPosObj[1][3]-5,aPosObj[1][4]-15,nil  ,oFolder:aDialogs[4], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabAre,aDadAre,.F.,"BIA",nOpcx,STR0014) //"Areas de Acao"
oBrwAre:aVetTrab := aClone(aTrbAre)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GETDADOS -> OPERADORA   X CONTRATO                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBJA := TPLSBrw():New(003,005,aPosObj[1][3]-5,aPosObj[1][4]-15, nil  ,oFolder:aDialogs[5], nil , nil , nil ,nil   ,nil, .T.   , nil ,.T.   ,nil   ,aCabBJA,aDadBJA,.F.,"BJA",nOpcx,STR0016,nil,nil,nil,aVetGet02,'PlsVldBJA')
oBrwBJA:aVetTrab := aClone(aTrbBJA)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GETDADOS -> OPERADORA   X PREVISAO DE PAGAMENTO REEMBOLSO           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBJS := TPLSBrw():New(003,005,aPosObj[1][3]-5,aPosObj[1][4]-15, nil  ,oFolder:aDialogs[6], nil , nil , nil ,nil   ,nil, .T.   , nil ,.T.   ,nil   ,aCabBJS,aDadBJS,.F.,"BJS",nOpcx,STR0017) //"Previsao Pagamento Reembolso"
oBrwBJS:aVetTrab := aClone(aTrbBJS)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GETDADOS -> OPERADORA   X DOC USUARIOS                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBCN := TPLSBrw():New(003,005,aPosObj[1][3]-5,aPosObj[1][4]-15, nil  ,oFolder:aDialogs[7], nil , nil , nil ,nil   ,nil, .T.   , nil ,.T.   ,nil   ,aCabBCN,aDadBCN,.F.,"BCN",nOpcx,STR0018) //"Doc. obrigat. dos Usuarios"
oBrwBCN:cVldLine := 'PLSXANAFAI( { "BCN_CODDOC","BCN_SEXO","BCN_TIPUSR","BCN_GRAUPA" },"BCN_IDAINI","BCN_IDAFIN",oBrwBCN:Linha())'
oBrwBCN:aVetTrab := aClone(aTrbBCN)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GETDADOS -> INFORMAÇÕES ANS                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEXI("B07")
	oBrwB07 := TPLSBrw():New(003,005,aPosObj[1][3]-5,aPosObj[1][4]-15, nil  ,oFolder:aDialogs[8], nil , nil , nil ,nil   ,nil, .T.   , nil ,.T.   ,nil   ,aCabB07,aDadB07,.F.,"B07",nOpcx,"Informações ANS") //"Informações ANS"
	oBrwB07:aVetTrab := aClone(aTrbB07) 
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GETDADOS -> TISS WEBSERVICE ...                         			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                                            
If PLSALIASEXI("B0F")
	oBrwB0F := TPLSBrw():New(003,005,aPosObj[1][3]-5,aPosObj[1][4]-15, nil  ,oFolder:aDialogs[9], nil , nil , nil ,nil   ,nil, .T.   , nil ,.T.   ,nil   ,aCabB0F,aDadB0F,.F.,"B0F",nOpcx,STR0026) //"TISS WebService"
	oBrwB0F:aVetTrab := aClone(aTrbB0F)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa Dialog                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       

CursorArrow()

ACTIVATE MSDIALOG oDlg ON INIT(A010Init(oDlg,{|| nOpca := 1,if(a010del(nOpc) .And. Obrigatorio(oEncBD1:aGets,oEncBD1:aTela) .And. PL010SUSEP() .And. PL010VALOP(), Eval({|| oDlg:End()}) ,(nOpca:=3,.F.))},{|| nOpca := 3,oDlg:End()}))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Rotina de Gravacao dos Dados...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> K_Incluir
   BA0->(DbGoTo(nReg))
Endif

If 	nOpca == K_OK

      If nOpcx <> K_Visualizar
      
             PLUPTENC("BA0",nOpcx)
            
             aChave := {}
             aadd(aChave,{"BIM_CODINT",M->BA0_CODIDE+M->BA0_CODINT})
             oBrwCon:Grava(aChave)

             aChave := {}
             aadd(aChave,{"BIA_CODINT",M->BA0_CODIDE+M->BA0_CODINT})
             oBrwAre:Grava(aChave)             

             aChave := {}
             aadd(aChave,{"BIF_CODINT",M->BA0_CODIDE+M->BA0_CODINT})
             oBrwOrg:Grava(aChave)             

             aChave := {}
             aadd(aChave,{"BJA_CODINT",M->BA0_CODIDE+M->BA0_CODINT})
             oBrwBJA:Grava(aChave)             

             aChave := {}
             aadd(aChave,{"BJS_CODINT",M->BA0_CODIDE+M->BA0_CODINT})
             oBrwBJS:Grava(aChave)             
             
             aChave := {}
             aadd(aChave,{"BCN_CODOPE",M->BA0_CODIDE+M->BA0_CODINT})
             oBrwBCN:Grava(aChave)             
             
	    	 If PLSALIASEXI("B07")
	    	     aChave := {}
	             aadd(aChave,{"B07_CODINT",M->BA0_CODIDE+M->BA0_CODINT})
	             oBrwB07:Grava(aChave)     
	         EndIf    
             
             If PLSALIASEXI("B0F")
	             aChave := {}
	             aadd(aChave,{"B0F_CODINT",M->BA0_CODIDE+M->BA0_CODINT})
	             oBrwB0F:Grava(aChave)
	         EndIf    
             
             If nOpc == K_Excluir
                BMB->(DbSetOrder(1))
                While BMB->(MsSeek(xFilial("BMB")+M->BA0_CODIDE+M->BA0_CODINT))
                      BMB->(RecLock("BMB",.F.))
                      BMB->(DbDelete())
                      BMB->(MsUnLock())
                Enddo
             Endif   
             If ExistBlock("PLS010A")
                Execblock("PLS010A",.f.,.f.,{nOpc} )
             EndIf
      Endif    
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal de Movimentacao                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A010Init   ³ Autor ³ Tulio Cesar         ³ Data ³ 23.02.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Barra de Ferramentas                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A010Init(oDlg,bOk,bCancel,lMessageDel)
LOCAL aButtons    := {}
Return(EnchoiceBar(oDlg,bOk,bCancel,.F.,aButtons))
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA010WHE ³ Autor ³ Tulio Cesar         ³ Data ³ 23.02.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Conteudo do SX3_WHEN do campo BJA_GRAUPA                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA010WHE(cTipo)
LOCAL lFlag

If     cTipo == "1"
       lFlag := M->BJA_GRAUPA <> GETMV("MV_PLCDTGP")
ElseIf cTipo == "2"   
       lFlag := M->BCN_GRAUPA <> GETMV("MV_PLCDTGP")
Endif       
       
Return(lFlag)



Static Function a010del(nOpc)
LOCAL lRet    := .T.          
LOCAL aChaves := {}

If nOpc == K_Excluir
   aadd(aChaves,{"BI3","BI3_CODINT",BA0->(BA0_CODIDE+BA0_CODINT)}) //Produto
   aadd(aChaves,{"BF8","BF8_CODINT",BA0->(BA0_CODIDE+BA0_CODINT)}) //Tab Honorarios
   aadd(aChaves,{"BAQ","BAQ_CODINT",BA0->(BA0_CODIDE+BA0_CODINT)}) //Especialidades Medicas
   aadd(aChaves,{"BFN","BFN_CODINT",BA0->(BA0_CODIDE+BA0_CODINT)}) //SubEspecialidade
   aadd(aChaves,{"BLD","BLD_CODINT",BA0->(BA0_CODIDE+BA0_CODINT)}) //Pacotes
   aadd(aChaves,{"BG9","BG9_CODINT",BA0->(BA0_CODIDE+BA0_CODINT)}) //Grp Empresa
   aadd(aChaves,{"BAW","BAW_CODINT",BA0->(BA0_CODIDE+BA0_CODINT)}) //RDA X Operadora
   aadd(aChaves,{"BEF","BEF_OPEMOV",BA0->(BA0_CODIDE+BA0_CODINT)}) //Liberacao
   aadd(aChaves,{"BEA","BEA_OPEMOV",BA0->(BA0_CODIDE+BA0_CODINT)}) //Autorizacao SADT
   aadd(aChaves,{"BE4","BE4_CODOPE",BA0->(BA0_CODIDE+BA0_CODINT)}) //Internacoes
   aadd(aChaves,{"BD7","BD7_CODOPE",BA0->(BA0_CODIDE+BA0_CODINT)}) //SubItens
   aadd(aChaves,{"BD6","BD6_CODOPE",BA0->(BA0_CODIDE+BA0_CODINT)}) //Itens
   aadd(aChaves,{"BD5","BD5_CODOPE",BA0->(BA0_CODIDE+BA0_CODINT)}) //Guias
   aadd(aChaves,{"BCI","BCI_CODOPE",BA0->(BA0_CODIDE+BA0_CODINT)}) //Pegs
   aadd(aChaves,{"BFM","BFM_CODINT",BA0->(BA0_CODIDE+BA0_CODINT)}) //US Mensais
   aadd(aChaves,{"BDT","BDT_CODINT",BA0->(BA0_CODIDE+BA0_CODINT)}) //Calendario Pagto

   lRet := PLSCHKDEL(aChaves)
EndIf


Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSLSC500  ³ Autor ³ Daher	          ³ Data ³ 01.06.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ 										                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ F3 	                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Padrao do mBrowse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSLSA010(cDado1,cDado2,lTela)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oDlg
LOCAL nOpca     := 0
LOCAL bOK       := { || nOpca := K_OK, oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }
LOCAL oCritica
LOCAL cSQL
LOCAL aLista    := {}
LOCAL nInd                     
LOCAL nPos
Local aCampos := {}
Local aBls    := {}
DEFAULT lTela := .T.     
DEFAULT cDado2:= ""
                                                                                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ coloca virgula no comeco (caso tenha inicializador padrao)               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDado1  := AllTrim(cDado1)
cDado2  := AllTrim(cDado2)
if subs(cDado1,len(cDado1),1) != "," .AND. cDado1 != ""
	cDado1 += ","
endif

aCriticas := {}
DbSelectArea("BF7")
DbSetOrder(1)
BF7->(DbGoTop())
While !BF7->(Eof())
    aadd(aCriticas,{BF7->BF7_CODORI,BF7->BF7_DESORI,'1'})         
	BF7->(DbSkip())
Enddo
	
For nInd := 1 To Len(aCriticas)
	If aCriticas[nInd,3] == "1"
		aadd(aLista,{aCriticas[nInd,1],aCriticas[nInd,2],If(aCriticas[nInd,1]$cDado1+cDado2,.T.,.F.)})
	Endif
Next

If lTela

   DEFINE MSDIALOG oDlg TITLE STR0021 FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault() //"Abrangencias"

   @ 020,012 SAY oSay PROMPT STR0022 SIZE 300,010 OF oDlg PIXEL COLOR CLR_HBLUE //"Selecione as formas de relacionamento entre as operadoras"

   oCritica := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
                                            
   oCritica:AddColumn(TcColumn():New(" ",{ || IF(aLista[oCritica:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
            "@c",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))     

   oCritica:AddColumn(TcColumn():New(STR0023,{ || OemToAnsi(aLista[oCritica:nAt,1]) },; //"Codigo"
            "@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))     

   oCritica:AddColumn(TcColumn():New(STR0024,{ || OemToAnsi(aLista[oCritica:nAt,2]) },; //"Descricao"
            "@C",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))     

  //-- LGPD -------
  if objCENFUNLGP:isLGPDAt()
    aCampos := {.F.,"BF7_CODORI","BF7_DESORI" } //checkbox , Codigo , Descricao
    aBls := objCENFUNLGP:getTcBrw(aCampos)
    oCritica:aObfuscatedCols := aBls
  endif
  //---------------
   oCritica:SetArray(aLista)         
   oCritica:bLDblClick := { || aLista[oCritica:nAt,3] := IF(aLista[oCritica:nAt,3],.F.,.T.) }

   ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

Else
   nOpca := K_OK
Endif

If nOpca == K_OK
                  
   cDado1 := ""
   cDado2 := ""
   For nInd := 1 To Len(aLista)
   
       If aLista[nInd,3]
			If nInd <= 20
             cDado1 += aLista[nInd,1]+","
          Else                           
             cDado2 += aLista[nInd,1]+","
          Endif   
          
          nPos := Ascan(aCriticas,{|x| x[1] == aLista[nInd,1]})
          If nPos > 0
             aCriticas[nPos,3] := "0"
          Endif   
       Endif   
   Next
Endif
                                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ tira a virgula do final                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if subs(cDado1,len(cDado1),1) == ","
	cDado1 := subs(cDado1,1,len(cDado1)-1)
endif                

if subs(cDado2,len(cDado2),1) == ","
	cDado2 := subs(cDado2,1,len(cDado2)-1)
endif                

cDadoAux := cDado1
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³21/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Private aRotina := {{ STR0001,'AxPesqui' , 0 ,K_Pesquisar		, 0, .F.},;//"Pesquisar"
                		{ STR0002,'pl010Mov' , 0 ,K_Visualizar	, 0, Nil},;//"Visualizar"
       		   	  		{ STR0003,'pl010Mov' , 0 ,K_Incluir			, 0, Nil},;//"Incluir"
						   			{ STR0004,'pl010Mov' , 0 ,K_Alterar			, 0, Nil},;//"Alterar"
                		{ STR0005,'pl010Mov' , 0 ,K_Excluir			, 0, Nil},;//"Excluir"
                		{ STR0006,'PL030MOV' , 0 ,K_Alterar			, 0, Nil},;
                     { 'Acesso Carol','PL010CARUS' , 0 ,K_Alterar			, 0, Nil} }
        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para incluir nova Rotina do usuario no menu        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                           	
If ExistBlock("PL010ENT")
	aRotAdic := ExecBlock("PL010ENT", .F., .F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIF
EndIF

// fim do ponto de entrada
Return(aRotina) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PL010SUSEP ³ Autor ³ Luciano Aparecido  ³ Data ³ 10.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Campo Obrigatório para Operadora Padrão  (Padrão TISS)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PLS                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PL010SUSEP()
Local lRet    := .T.
Local cOperad := PlsIntPad()
	
If !Empty(cOperad)	
	lRet := M->(BA0_CODIDE+BA0_CODINT) <> cOperad .Or. (M->(BA0_CODIDE+BA0_CODINT) == cOperad .And. !Empty(M->BA0_SUSEP))		
	
	If ! lRet
        SX3->(DbSetOrder(2))
        SX3->(MsSeek("BA0_SUSEP"))
		Help("",,"GETOBG",,X3Titulo() + CRLF + STR0025,1,16)  //"Campo obrigatório para a operadora padrão."
	EndIf
Endif

Return lRet    


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PL010VALOP ³ Autor ³ Fernando Separovic ³ Data ³ 07.01.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Não deixa cadastrar duas operadoras com o mesmo código     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PLS                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PL010VALOP()
Local lRet    := .T.

lRet := ExistChav("BA0",M->BA0_CODIDE+M->BA0_CODINT,1) .And. FreeForUse("BA0",xFilial("BA0")+M->BA0_CODIDE+M->BA0_CODINT)	
	

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Pls010Cgc ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca o Cgc ou CPF de acordo com o tipo de pessoa          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pls010Cgc(cTipPes, cCNPJ)    

Local lRetorno := .T.
                  
If PLSALIASEXI("B07")
	If ReadVar() == "M->B07_NUMDOC"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida o tipo de pessoa                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTipPes == "F" .AND. !(Len(AllTrim(cCNPJ))==11)
			Help(" ",1,"CPFINVALID")
			lRetorno := .F.
		ElseIf cTipPes == "J" .AND. !(Len(AllTrim(cCNPJ))==14)  
			Help(" ",1,"CGC")     
			lRetorno := .F.
		EndIf     
	ElseIf ReadVar() == "M->B07_TPDOC"
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida o tipo de pessoa                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTipPes == "F" .And. !Empty(M->B07_NUMDOC) .And. !(Len(AllTrim(cCNPJ))==11)
			Help(" ",1,"CPFINVALID")
			lRetorno := .F.
		ElseIf cTipPes == "J" .And. !Empty(M->B07_NUMDOC) .And. !( Len(AllTrim(cCNPJ))==14)  
			Help(" ",1,"CGC")     
			lRetorno := .F.
		EndIf     
	
	Endif
EndIf

Return(lRetorno)    

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA010   ºAutor  ³Microsiga           º Data ³  15/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funca de validacao das datas de vigencia, chamada no       º±±
±±º          ³ botao de OK da Rotina Cobranca de Identificacao de Usuario º±±
±±º          ³ Tabela - BJA - Operadora Cobranca Usuarios  				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PlsVldBJA()
Local lRet     := .T.
Local cOper    := M->BA0_CODIDE + M->BA0_CODINT 
Local cTipUsr  := M->BJA_TIPUSR
Local cGraupa  := M->BJA_GRAUPA
Local cMotivo  := M->BJA_MOTIVO
Local nPosMot  := Ascan(oBrwBJA:aHeader,{|x| Alltrim(x[2])=="BJA_MOTIVO"})
Local nPosUsr  := Ascan(oBrwBJA:aHeader,{|x| Alltrim(x[2])=="BJA_TIPUSR"})
Local nPosGrau := Ascan(oBrwBJA:aHeader,{|x| Alltrim(x[2])=="BJA_GRAUPA"}) 
Local nPosIni  := Ascan(oBrwBJA:aHeader,{|x| Alltrim(x[2])=="BJA_VIGINI"})
Local nPosFin  := Ascan(oBrwBJA:aHeader,{|x| Alltrim(x[2])=="BJA_VIGFIN"}) 
Local nPosCbr  := Ascan(oBrwBJA:aHeader,{|x| Alltrim(x[2])=="BJA_COBRAR"}) 
Local nUsado   := Len(oBrwBJA:aHeader)
Local nX       := 0 
Local aArea	   := GetArea()                                          

DbSelectArea("BJA")
BJA->(dbSetOrder(1))

If BJA->( FieldPos("BJA_VIGFIN") ) > 0 .and. BJA->( FieldPos("BJA_VIGINI") ) > 0

	If lRet
		For nX := 1 To Len(oBrwBJA:aCols)
			If !aCols[nX][nUsado+1]
				If nX < n
					If M->BJA_MOTIVO == oBrwBJA:aCols[nX][nPosMot] .And. M->BJA_TIPUSR  == oBrwBJA:aCols[nX][nPosUsr] .And. M->BJA_GRAUPA == oBrwBJA:aCols[nX][nPosGrau] .And. M->BJA_COBRAR == oBrwBJA:aCols[nX][nPosCbr]
						If !M->BJA_VIGINI == CTOD(" / / ")
							If M->BJA_VIGINI <= oBrwBJA:aCols[nX][nPosFin]
								Aviso(STR0032,STR0035,{STR0031},2)//"Vigência Inicial"###"A Data Incial da Nova Vigência Precisa ser Maior que a Data Final da Ultima Vigência!"###"Ok"
								lRet := .F.
								Return .F.
							Endif
						Endif
					Endif
				Endif
			Endif
		Next nX
		
		If !M->BJA_VIGFIN == CTOD(" / / ") .And. M->BJA_VIGINI > M->BJA_VIGFIN
			Aviso(STR0032,STR0027,{STR0031},2)//"Vigência Inicial"###"A vigência inicial deve ser menor ou igual a vigência final."###"Ok"
			lRet := .F.
			Return .F.
		EndIf
		
		For nX := 1 To Len(oBrwBJA:aCols)
			If !aCols[nX][nUsado+1]
				If nX < n
					If !M->BJA_VIGINI == CTOD(" / / ")
						If M->BJA_MOTIVO == oBrwBJA:aCols[nX][nPosMot] .And. M->BJA_TIPUSR  == oBrwBJA:aCols[nX][nPosUsr] .And. M->BJA_GRAUPA == oBrwBJA:aCols[nX][nPosGrau] .And.;
							M->BJA_VIGINI >= oBrwBJA:aCols[nX][nPosIni] .And. M->BJA_VIGINI <= oBrwBJA:aCols[nX][nPosFin] .And. M->BJA_COBRAR == oBrwBJA:aCols[nX][nPosCbr]
							
							Aviso(STR0033,STR0034,{STR0031},2)//"Vigência Informada"###"Já existe um intervalo de data que compreende a data selecionada!"###"Ok"
							lRet := .F.
							Return .F.
						Endif
					Endif
				Endif
			Endif
		Next nX
		
		For nX := 1 To Len(oBrwBJA:aCols)
			If !aCols[nX][nUsado+1]
				If nX < n
					If  M->BJA_MOTIVO == oBrwBJA:aCols[nX][nPosMot] .And. M->BJA_TIPUSR  == oBrwBJA:aCols[nX][nPosUsr] .And. M->BJA_GRAUPA == oBrwBJA:aCols[nX][nPosGrau] .And. M->BJA_COBRAR == oBrwBJA:aCols[nX][nPosCbr]
						If oBrwBJA:aCols[nX][nPosMot] == cMotivo .And. oBrwBJA:aCols[nX][nPosFin] == CTOD(" / / ") 
							Aviso(STR0029,STR0030,{STR0031},2) //"Vigência em Aberto"###"Já existe uma Vigência em Aberto!"###"Ok"
							lRet := .F.
							Return .F.
						EndIf
					Endif
				Endif
			Endif
		Next nX
	Endif
Endif

RestArea(aArea)

Return(lRet)    


//-----------------------------------------------------------------
/*/{Protheus.doc} procRetCar
 Processa retorno da Carol
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Function PL010CARUS()

   Local cTitulo   := "Integração Carol x Auditoria"
   Local oDlg      := MSDialog():New(000,000,280,650,cTitulo,,,,,CLR_BLACK,CLR_WHITE,,,.T.)
   Local nOpca     := 0
   Local cUser     := Space(80)
   Local cPass1    := Space(50)
   Local cPass2    := Space(50)
   Local cToken    := ''
   Local bOK       := {|| IIF(VldPassCar(cUser,cPass1,cPass2),(nOpca := 1, oDlg:End()),nOpca := 0) } 
   Local bCancel   := {|| nOpca := 0, oDlg:End() }    
   Local aRet      := {}
   Local aButtons  := {}
 
   @ 045,010 SAY oSay PROMPT 'Informe o usuário/senha de acesso a Carol' SIZE 330,010 OF oDlg PIXEL COLOR CLR_RED
      
   @ 065,010 SAY oSay PROMPT 'Usuário:'  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED
   @ 065,060 MSGET cUser SIZE 120,006 OF oDlg PIXEL COLOR CLR_BLACK 
      
   @ 080,010 SAY oSay PROMPT 'Senha:'  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED
   @ 080,060 MSGET cPass1 SIZE 120,006 PASSWORD OF oDlg PIXEL COLOR CLR_BLACK
      
   @ 095,010 SAY oSay PROMPT 'Repita a Senha:'  SIZE 080,010 OF oDlg PIXEL COLOR CLR_RED
   @ 095,060 MSGET cPass2 SIZE 120,006 PASSWORD OF oDlg PIXEL COLOR CLR_BLACK

   EnChoiceBar(oDlg,bOK,bCancel,.F.,aButtons)
   oDlg:lCentered := .T.
   oDlg:Activate()

   if nOpca == 1

      oCarol := PLAudCarol():New(PlsIntPad())
      oCarol:cUser := Alltrim(cUser)
      oCarol:cPass := Alltrim(cPass1)

      MsAguarde( {|| aRet := oCarol:getToken() })

      if !aRet[1]
         MsgInfo(oCarol:cError)
      else
         cToken := aRet[2]
         oCarol:resetAtrib()
         oCarol:loadAccess()
         aRet := oCarol:getXAutKey(cToken)
         if aRet[1]
            BA0->(recLock("BA0",.F.))
            BA0->BA0_CARTOK := aRet[2]
            BA0->(msUnLock())
         else
            MsgInfo(oCarol:cError)
         endIf
         MsgInfo('Solicitação de Token de Acesso realizada com sucesso.')
      endif

   endif
   
Return


//-----------------------------------------------------------------
/*/{Protheus.doc} VldPassCar
 Valida a digitacao de usuario e senha da Carol
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function VldPassCar(cUser,cPass1,cPass2)

   Local lRet := .T.
   
   if empty(cUser)
      MsgInfo('Informe o campo de usuário.')
      lRet := .F.

   elseIf empty(cPass1) .Or. empty(cPass2)
      MsgInfo('Informe os campos de senhas.')
      lRet := .F.

   elseIf Alltrim(cPass1) <> Alltrim(cPass2)
      MsgInfo('As senhas não coincidem.')
      lRet := .F.

   endIf 

Return lRet