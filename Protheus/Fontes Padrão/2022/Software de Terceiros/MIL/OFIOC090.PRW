// ษออออออออหออออออออป
// บ Versao บ 017    บ
// ศออออออออสออออออออผ

#INCLUDE "ofioc090.ch"
#INCLUDE "TOPCONN.CH"
#Include "protheus.ch"
#Include "OFIXDEF.ch"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006860_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ OFIOC090 ณ Autor ณ  Fabio                ณ Data ณ 19/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Movimento do Produtivo                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico  (Modelo3)                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณObservacaoณ As tratativas das variaveis VOK_INCMOB/VOK_INCTEM estao    ณฑฑ
ฑฑณ          ณ desmembradas apenas para documentar e facilitar a analise eณฑฑ
ฑฑณ          ณ eventuais implementacoes, caso passe a ser necessario      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOC090

Private aRotina := MenuDef()
Private cCadastro := (STR0003) // //"Movimento do Produtivo"
Private lTopConn  := .T.
Private aVetCampos := {}
Private aMensagem  := {}
cIndVAI := CriaTrab(Nil, .F.)
cChave  := "VAI_FILIAL+VAI_CODTEC"
cCond   := "VAI->VAI_FUNPRO == '1' .And. (Empty(VAI->VAI_DATDEM) .Or. dDataBase < VAI->VAI_DATDEM)"        // A = OS Aberta

If ExistBlock("OFC090FB")
	cCond := ExecBlock("OFC090FB",.f.,.f.,{cCond})
Endif

IndRegua("VAI",cIndVAI,cChave,,cCond, (STR0003) ) // //"Movimento do Produtivo"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
mBrowse( 6, 1,22,75,"VAI")

DbSelectArea("VAI")
DbClearFilter()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOC090     บAutor  ณFabio               บ Data ณ  10/10/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tela                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OC090(cAlias,nReg,nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam := 0
Local nTam := 0
////////////////////////////////////////////////////////////////////////////////////////////

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor := 0
Local cTitulo
Local i        := 0

Local oGetDb

Private oLbaSrv , oFolder
//Private aTela	:= {}
//Private aGets	:= {}
Private aHeader:= {}
Private cArqIndex1 := CriaTrab(NIL, .F.) , cArqIndex2 := CriaTrab(NIL, .F.)    && Cria Indice de trabalho
Private cArqTMP1 := CriaTrab(NIL, .F.) , cArqTMP2 := CriaTrab(NIL, .F.)
Private aTELA[0][0], aGETS[0], n:=1,nOpca:=0 , nIndVO2 := 0
Private aSrv := {}, aConta := {}, aPecas := {} , lRSrv:=.f.
Private nTotal := 0 , nTPecas := 0, nTPadrao := 0, nTTrab := 0, nTCob := 0, nTExtra := 0, nTAus := 0, nTVend := 0, nTParado := 0 , nTConta := 0
Private nTCHorDis:=0,nTCHorPar:=0,nTCHorTra:=0,nTCHorExt:=0,nTCHorAus:=0,nTCHorVen:=0,nTCHorCob:=0,nTCValVen:=0,nTCQtdPec:=0

Private oObjTempTable
Private o2ObjTempTable

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณData inicial e Final ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !PERGUNTE("OC090")

	Return

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da Enchoice                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("VAI")
RegToMemory("VAI",.T.)

aCpoEnchoice  :={}

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VAI")
While !Eof().and.(x3_arquivo=="VAI")

	If X3USO(x3_usado).and.x3_nivel>0
		AADD(aCpoEnchoice,x3_campo)
	Endif

	dbSkip()

End

DbSelectArea("VAI")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

DbSelectArea("VO2")

&& Cria aHeader
FS_CRIAHEADER()

&& Cria Arquivo de trabalho
FS_CRIAARQ( "C" , .f. )

&& Monta Vetores
Processa( {|| FS_C090VETOR()} )

if Len(aMensagem) > 0
	aMensagem := {}
	Return(.f.)
Endif


nOpcE := 2
nOpc  := 2

cTitulo       :=STR0001+ STR0004 + Dtoc(mv_par01)+ STR0005 + Dtoc(mv_par02) //### //" - "###" a "

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 000, 000 , .T. , .T. } )//cabecalho

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPos  := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cTitulo OF oMainWnd PIXEL

oFolder := TFolder():New( ;
	aPos[1,1]+002,;
	aPos[1,2],;
	{ STR0006 , STR0007 , STR0008 , STR0009 },;
	{},;
	oDlg,,,,.T.,.F., aPos[1,4], aPos[1,3]-aPos[1,1]-007, ) // Dados Produtivo / Cartao Diario / Conta Corrente / Pecas Requisitadas

oMsGetVAI := MsMGet():New("VAI", nReg, nOpc, , , ,aCpoEnchoice,{005,002,aPos[1,3]-35,aPos[1,4]-005},,,,,,oFolder:aDialogs[1])
oMsGetVAI:oBox:Align := CONTROL_ALIGN_ALLCLIENT


/*
BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarta Diario do Produtivoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC
*/

oPanF2Top := tPanel():Create( oFolder:aDialogs[2],01,01,,,.F.,,,,100, 15 )
oPanF2Top:Align := CONTROL_ALIGN_TOP
oPanF2Top:ReadClientCoors()

@ 003, 005 CHECKBOX oRSrv   VAR lRSrv   PROMPT STR0010 ; // //"Tempo Parado"
	OF oPanF2Top ;
	ON CLICK ( FS_CRIAARQ( "F" , lRSrv ) , FS_CRMSGETDB() ) ;
	SIZE 50,10 PIXEL

// Imprime conta corrente
nColuna := ( oPanF2Top:nClientWidth / 2 )
DEFINE SBUTTON FROM 001,nColuna-055 TYPE 6 ACTION FS_IMPCRR() ENABLE OF oPanF2Top

// Cria Arquivo de trabalho
FS_CRIAARQ( "F" , .f. )

// Lista movimento de hora do produtivo
oLbaSrv := MSGetDB():New(015, 001, aPos[1,3]-60 , aPos[1,4]-005, 2,"AllwaysTrue()","AllwaysTrue()",,.t.,,,.t.,,"TMP",,,,oFolder:aDialogs[2])
oLbaSrv:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oPanF2Bot := tPanel():Create( oFolder:aDialogs[2],01,01,,,.F.,,,,100, 23 )
oPanF2Bot:Align := CONTROL_ALIGN_BOTTOM
oPanF2Bot:ReadClientCoors()

nTam := ( ( oPanF2Bot:nClientWidth / 2 ) / 7 ) //varaivel que armazena o resutlado da divisao da tela.
nColuna := 0

@ 002 , ( nColuna   * nTam ) + 5 SAY STR0011    OF  oPanF2Bot PIXEL COLOR CLR_BLUE   //"Padrao"
@ 010 , ( nColuna++ * nTam ) + 5 MSGET oTPadrao VAR nTPadrao PICTURE "@R 999:99"    SIZE 25,08 OF oPanF2Bot PIXEL COLOR CLR_BLACK WHEN .f.

@ 002 , ( nColuna   * nTam ) + 5 SAY STR0012    OF  oPanF2Bot PIXEL COLOR CLR_BLUE   //"Trabalhado"
@ 010 , ( nColuna++ * nTam ) + 5 MSGET oTTrab   VAR nTTrab     PICTURE "@R 999:99"  SIZE 25,08 OF oPanF2Bot PIXEL COLOR CLR_BLACK WHEN .f.

@ 002 , ( nColuna   * nTam ) + 5 SAY STR0013    OF  oPanF2Bot PIXEL COLOR CLR_BLUE   //"Cobrado"
@ 010 , ( nColuna++ * nTam ) + 5 MSGET oTCob    VAR nTCob       PICTURE "@R 999:99" SIZE 25,08 OF oPanF2Bot PIXEL COLOR CLR_BLACK WHEN .f.

@ 002 , ( nColuna   * nTam ) + 5 SAY STR0014    OF  oPanF2Bot PIXEL COLOR CLR_BLUE   //"Extra"
@ 010 , ( nColuna++ * nTam ) + 5 MSGET oTExtra  VAR nTExtra   PICTURE "@R 999:99"   SIZE 25,08 OF oPanF2Bot PIXEL COLOR CLR_BLACK WHEN .f.

@ 002 , ( nColuna   * nTam ) + 5 SAY STR0015    OF  oPanF2Bot PIXEL COLOR CLR_BLUE   //"Ausente"
@ 010 , ( nColuna++ * nTam ) + 5 MSGET oTAus    VAR nTAus       PICTURE "@R 999:99" SIZE 25,08 OF oPanF2Bot PIXEL COLOR CLR_BLACK WHEN .f.

@ 002 , ( nColuna   * nTam ) + 5 SAY STR0016    OF  oPanF2Bot PIXEL COLOR CLR_BLUE   //"Vendido"
@ 010 , ( nColuna++ * nTam ) + 5 MSGET oTVend   VAR nTVend     PICTURE "@R 999:99"  SIZE 25,08 OF oPanF2Bot PIXEL COLOR CLR_BLACK WHEN .f.

@ 002 , ( nColuna   * nTam ) + 5 SAY STR0017    OF  oPanF2Bot PIXEL COLOR CLR_BLUE   //"Parado"
@ 010 , ( nColuna++ * nTam ) + 5 MSGET oTParado VAR nTParado  PICTURE "@R 999:99"   SIZE 25,08 OF oPanF2Bot PIXEL COLOR CLR_BLACK WHEN .f.

/*
BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConta Corrente do Produtivoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC
*/

@ 002,.1 LISTBOX oLbaConta FIELDS HEADER;
	(STR0018),;  // //"Data"
	(STR0019),;  // //"Disp"
	(STR0011),;  // //"Padrao"
	(STR0020),;  // //"Parada"
	(STR0021),;  // //"Trab"
	(STR0014),;  // //"Extra"
	(STR0022),;  // //"Aus"
	(STR0023),;  // //"Vend"
	(STR0024),;  // //"Cobr"
	(STR0025),;  // //"Vlr Vendido"
	(STR0026);  // //"Qtd Pecas"
	COLSIZES 30,20,20,20,20,20,20,20,20,30,30;
	SIZE aPos[1,4]-005,aPos[1,3]-aPos[1,1]-048 ;
	OF oFolder:aDialogs[3] PIXEL
oLbaConta:Align := CONTROL_ALIGN_ALLCLIENT

oLbaConta:SetArray(aConta)
	oLbaConta:bLine := { || { Transform(aConta[oLbaConta:nAt,1],"@D") ,;
	Transform(aConta[oLbaConta:nAt,2],"@R 99:99") ,;
	Transform(aConta[oLbaConta:nAt,3],"@R 99:99") ,;
	Transform(aConta[oLbaConta:nAt,4],"@R 99:99") ,;
	Transform(aConta[oLbaConta:nAt,5],"@R 99:99") ,;
	Transform(aConta[oLbaConta:nAt,6],"@R 99:99") ,;
	Transform(aConta[oLbaConta:nAt,7],"@R 99:99") ,;
	Transform(aConta[oLbaConta:nAt,8],"@R 99:99") ,;
	Transform(aConta[oLbaConta:nAt,9],"@R 99:99") ,;
	Transform(aConta[oLbaConta:nAt,10],"@E 999,999,999.99") ,;
	Transform(aConta[oLbaConta:nAt,11],"@E 999,999,999") } }

oPanF3Bot := tPanel():Create( oFolder:aDialogs[3],01,01,,,.F.,,,,100, 23 )
oPanF3Bot:Align := CONTROL_ALIGN_BOTTOM
oPanF3Bot:ReadClientCoors()
nTam := ( ( oPanF3Bot:nClientWidth / 2 ) / 9 ) //varaivel que armazena o resutlado da divisao da tela.

nColuna := 0

@ 002 , ( nColuna   * nTam ) + 5 SAY STR0027   OF oPanF3Bot PIXEL COLOR CLR_BLUE // //"Disponivel"
@ 010 , ( nColuna++ * nTam ) + 5 MSGET oTCHorDis  VAR nTCHorDis     PICTURE "@R 999:99" SIZE 42 , 08 OF oPanF3Bot PIXEL COLOR CLR_BLACK When .f.

@ 002 , ( nColuna   * nTam ) + 5 SAY STR0020  OF oPanF3Bot PIXEL COLOR CLR_BLUE // //"Parada"
@ 010 , ( nColuna++ * nTam ) + 5 MSGET oTCHorPar  VAR nTCHorPar     PICTURE "@R 999:99" SIZE 42 , 08 OF oPanF3Bot PIXEL COLOR CLR_BLACK When .f.

@ 002 , ( nColuna   * nTam ) + 5 SAY STR0021   OF oPanF3Bot PIXEL COLOR CLR_BLUE // //"Trab"
@ 010 , ( nColuna++ * nTam ) + 5 MSGET oTCHorTra  VAR nTCHorTra     PICTURE "@R 999:99" SIZE 42 , 08 OF oPanF3Bot PIXEL COLOR CLR_BLACK When .f.

@ 002 , ( nColuna   * nTam ) + 5 SAY STR0014 OF oPanF3Bot PIXEL COLOR CLR_BLUE // //"Extra"
@ 010 , ( nColuna++ * nTam ) + 5 MSGET oTCHorExt  VAR nTCHorExt     PICTURE "@R 999:99" SIZE 42 , 08 OF oPanF3Bot PIXEL COLOR CLR_BLACK When .f.

@ 002 , ( nColuna   * nTam ) + 5 SAY STR0015   OF oPanF3Bot PIXEL COLOR CLR_BLUE // //"Ausente"
@ 010 , ( nColuna++ * nTam ) + 5 MSGET oTCHorAus  VAR nTCHorAus     PICTURE "@R 999:99" SIZE 42 , 08 OF oPanF3Bot PIXEL COLOR CLR_BLACK When .f.

@ 002 , ( nColuna   * nTam ) + 5 SAY STR0028  OF oPanF3Bot PIXEL COLOR CLR_BLUE // //"Vendida"
@ 010 , ( nColuna++ * nTam ) + 5 MSGET oTCHorVen  VAR nTCHorVen     PICTURE "@R 999:99" SIZE 42 , 08 OF oPanF3Bot PIXEL COLOR CLR_BLACK When .f.

@ 002 , ( nColuna   * nTam ) + 5 SAY STR0029 OF oPanF3Bot PIXEL COLOR CLR_BLUE    // //"Cobrada"
@ 010 , ( nColuna++ * nTam ) + 5 MSGET oTCHorCob VAR nTCHorCob      PICTURE "@R 999:99" SIZE 42 , 08 OF oPanF3Bot PIXEL COLOR CLR_BLACK When .f.

@ 002 , ( nColuna   * nTam ) + 5 SAY STR0025 OF oPanF3Bot PIXEL COLOR CLR_BLUE // //"Vlr Vendido"
@ 010 , ( nColuna++ * nTam ) + 5 MSGET oTCValVen VAR nTCValVen      PICTURE "@E 99,999,999.99" SIZE 42 , 08 OF oPanF3Bot PIXEL COLOR CLR_BLACK When .f. HASBUTTON

@ 002 , ( nColuna   * nTam ) + 5 SAY STR0026 OF oPanF3Bot PIXEL COLOR CLR_BLUE // //"Qtd Pecas"
@ 010 , ( nColuna++ * nTam ) + 5 MSGET oTCQtdPec VAR nTCQtdPec      PICTURE "@E 999,999" SIZE 42 , 08 OF oPanF3Bot PIXEL COLOR CLR_BLACK When .f.


/*
BEGINDOC
//ฺฤฤฤฤฤฟ
//ณPecasณ
//ภฤฤฤฤฤู
ENDDOC
*/

@ 002,.1 LISTBOX oLbaPecas FIELDS HEADER;
	(STR0030),;  // //"Nro OS"
	(STR0031),;  // //"Dt Req"
	(STR0032),;  // //"Hora Req"
	(STR0033),;  // //"Req/Dev"
	(STR0034),;  // //"Tt"
	(STR0035),;  // //"Grupo"
	(STR0036),; // //"Codigo"
	(STR0037),; // //"Descricao"
	(STR0038),; // //"Quantidade"
	(STR0039); // //"Valor"
	COLSIZES 30,27,20,25,16,17,70,60,30,30;
	SIZE aPos[1,4]-005,aPos[1,3]-aPos[1,1]-040;
	OF oFolder:aDialogs[4] PIXEL

oLbaPecas:Align := CONTROL_ALIGN_ALLCLIENT
oLbaPecas:SetArray(aPecas)
oLbaPecas:bLine := { || {aPecas[oLbaPecas:nAt,6] ,;
	aPecas[oLbaPecas:nAt,7] ,;
	Transform(aPecas[oLbaPecas:nAt,10],"@E 99:99") ,;
	iif(aPecas[oLbaPecas:nAt,8]=="1",STR0040,STR0041) ,; //### //"Req"###"Dev"
	aPecas[oLbaPecas:nAt,9] ,;
	aPecas[oLbaPecas:nAt,1] ,;
	aPecas[oLbaPecas:nAt,2] ,;
	aPecas[oLbaPecas:nAt,3] ,;
	Transform(aPecas[oLbaPecas:nAt,4],"@E 999,999,999") ,;
	Transform(aPecas[oLbaPecas:nAt,5],"@E 99,999,999.99") }}

oPanF4Bot := tPanel():Create( oFolder:aDialogs[4],01,01,,,.F.,,,,100, 23 )
oPanF4Bot:Align := CONTROL_ALIGN_BOTTOM
oPanF4Bot:ReadClientCoors()
nTam := ( ( oPanF4Bot:nClientWidth / 2 ) / 9 ) //varaivel que armazena o resutlado da divisao da tela.

nColuna := 0

@ 002 , 005 SAY STR0042 OF oPanF4Bot PIXEL COLOR CLR_BLUE // //"Total Pecas"
@ 010 , 005 MSGET oTPecas VAR nTPecas PICTURE "@E 99,999,999.99" SIZE 50,08 OF oPanF4Bot PIXEL COLOR CLR_BLACK When .f. HASBUTTON

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||(nOpca := 1,oDlg:End()) } , { || nOpca := 0,oDlg:End()}))

&& Apaga arquivo de trabalho
FS_CRIAARQ( "A" )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIOC090  บAutor  ณFabio               บ Data ณ  06/20/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta vetores do ListBox                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_C090VETOR()
Local aCodSer := {}, aTempPar := {}, aTempTra := {}, aJustVet := {}, nSHorFin := 0, nBarra := 0, dDatRef := ctod("  /  /  "), aSrvVO4 := {}
Local cSQLVO3 := "SQLVO3"
Local cSQLVO4 := "SQLVO4"
Local cWhere  := ""
Local i       := 0
Local cQuery  := ""
Local niSrv   := 0
Local cIndVO2, cChave, cCond
Local niApont := 0

&& Seta barra de progresso
// TotalReg
cQuery := "SELECT COUNT(*) TOTALREG "
cQuery += "FROM " + RetSqlName('VO2') + " VO2 "
cQuery += "WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "' AND VO2.VO2_DATREQ BETWEEN '" + DToS(mv_par01) + "' AND '" + DToS(mv_par02) + "' AND VO2.D_E_L_E_T_ = ' ' "
nBarra += FM_SQL(cQuery)

// TotalRec
cQuery := "SELECT COUNT(*) TOTALREC "
cQuery += "FROM " + RetSqlName('VO4') + " VO4 "
cQuery += "WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND VO4.VO4_DATINI BETWEEN '" + DToS(mv_par01) + "' AND '" + DToS(mv_par02) + "' AND VO4.D_E_L_E_T_ = ' '"
nBarra += FM_SQL(cQuery)

&& Tempo Parado
aTempPar := FG_TEMPTRA(VAI->VAI_CODTEC, mv_par01, 0, mv_par02, 2359, "A", .f., "D")
nBarra   += Len(aTempPar)
ProcRegua(nBarra)

&& Pecas
cQuery := "SELECT VO3_GRUITE, VO3_CODITE, B1_DESC, VO3_QTDREQ, VO3_VALPEC, VO1_NUMOSV, VO2_DATREQ, VO2_DEVOLU, VO3_TIPTEM, VO2_HORREQ "

cQuery += "FROM "
cQuery += RetSqlName("SB1") + " SB1, "
cQuery += RetSqlName("VO1") + " VO1, "
cQuery += RetSqlName("VO2") + " VO2, "
cQuery += RetSqlName("VO3") + " VO3  "

cQuery += "WHERE "

cQuery += "VO2_NUMOSV = VO1_NUMOSV AND "
cQuery += "VO2_NOSNUM = VO3_NOSNUM AND "
cQuery += "VO2_DATREQ BETWEEN '" + DToS(mv_par01) + "' AND '" + DToS(mv_par02) + "' AND "
cQuery += "B1_GRUPO   = VO3_GRUITE AND "
cQuery += "B1_CODITE  = VO3_CODITE AND "
cQuery += "VO3_PROREQ = '" + VAI->VAI_CODTEC + "' AND "

cQuery += "B1_FILIAL  = '" + xFilial("SB1") + "' AND "
cQuery += "VO1_FILIAL = '" + xFilial("VO1") + "' AND "
cQuery += "VO2_FILIAL = '" + xFilial("VO2") + "' AND "
cQuery += "VO3_FILIAL = '" + xFilial("VO3") + "' AND "

cQuery += "SB1.D_E_L_E_T_ = ' ' AND "
cQuery += "VO1.D_E_L_E_T_ = ' ' AND "
cQuery += "VO2.D_E_L_E_T_ = ' ' AND "
cQuery += "VO3.D_E_L_E_T_ = ' '     "
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLVO3, .F., .T.)

While !(cSQLVO3)->(Eof())
	Aadd(aPecas, { (cSQLVO3)->VO3_GRUITE,;
		(cSQLVO3)->VO3_CODITE,           ;
		(cSQLVO3)->B1_DESC,              ;
		(cSQLVO3)->VO3_QTDREQ,           ;
		(cSQLVO3)->VO3_VALPEC,           ;
		(cSQLVO3)->VO1_NUMOSV,           ;
		(cSQLVO3)->VO2_DATREQ,           ;
		(cSQLVO3)->VO2_DEVOLU,           ;
		(cSQLVO3)->VO3_TIPTEM,           ;
		(cSQLVO3)->VO2_HORREQ })

	nTPecas := nTPecas +  (aPecas[Len(aPecas), 4] * aPecas[Len(aPecas), 5])

	IncProc((STR0043 + " " + Dtoc(mv_par01) + STR0005 + Dtoc(mv_par02))) //### //"Montando Periodo"###" a "

	(cSQLVO3)->(dbSkip())
EndDo

(cSQLVO3)->(dbCloseArea())

DbSelectArea("VO2")

&& Servicos
cQuery := "SELECT DISTINCT VO4.VO4_NUMOSV, VV1.VV1_CODMAR, VV1.VV1_CHASSI "
cQuery += "FROM " + RetSqlName("VO4") + " VO4 "
cQuery += "INNER JOIN " + RetSqlName("VO1") + " VO1 ON VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_NUMOSV = VO4.VO4_NUMOSV AND VO1.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN " + RetSqlName("VV1") + " VV1 ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1.VV1_CHAINT = VO1.VO1_CHAINT AND VV1.D_E_L_E_T_ = ' ' "
cQuery += "WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND VO4.VO4_DATINI BETWEEN '" + Dtos(MV_PAR01) + "' AND '" + Dtos(MV_PAR02) + "' "
cQuery += "  AND VO4.VO4_CODPRO = '" + VAI->VAI_CODTEC + "' AND VO4.D_E_L_E_T_ = ' ' "
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLVO4, .F., .T.)

While !(cSQLVO4)->(Eof())
	aSrvVO4 := FMX_CALSER((cSQLVO4)->(VO4_NUMOSV),;
		,                                         ;
		,                                         ;
		,                                         ;
		.t.,                                      ;
		.t.,                                      ;
		.t.,                                      ;
		.t.,                                      ;
		.t.,                                      ;
		.t.,                                      ;
		,                                         ;
		" VO4.VO4_DATINI BETWEEN '" + Dtos(MV_PAR01) + "' AND '" + Dtos(MV_PAR02) + "' AND VO4.VO4_CODPRO = '" + VAI->VAI_CODTEC + "' ") // Matriz TOTAL de Servi็os/Apontamentos da OS

	dbSelectArea("VO6")
	dbSetOrder(2)

	For niSrv := 1 to len(aSrvVO4)
		VO6->(MsSeek(xFilial("VO6") + FG_MARSRV((cSQLVO4)->(VV1_CODMAR), aSrvVO4[niSrv, SRVC_CODSER]) + aSrvVO4[niSrv, SRVC_CODSER]))

		For niApont := 1 to Len(aSrvVO4[niSrv, SRVC_APONT])
			If aSrvVO4[niSrv, SRVC_APONT, niApont, SRVC_APONT_HOREXT] == "E"
				nTExtra += aSrvVO4[niSrv, SRVC_APONT, niApont, SRVC_APONT_TEMTRA]
			Else
				nTTrab += aSrvVO4[niSrv, SRVC_APONT, niApont, SRVC_APONT_TEMTRA]
			EndIf

			nTCob  += aSrvVO4[niSrv, SRVC_APONT, niApont, SRVC_APONT_TEMCOB]
			nTVend += aSrvVO4[niSrv, SRVC_APONT, niApont, SRVC_APONT_TEMVEN]

			FS_CRIAARQ("G",, { aSrvVO4[niSrv, SRVC_CODSER],                                                                                                   ;
				VO6->VO6_DESABR,                                                                                                                              ;
				aSrvVO4[niSrv, SRVC_TIPSER],                                                                                                                  ;
				(cSQLVO4)->(VO4_NUMOSV),                                                                                                                      ;
				If(!Empty(aSrvVO4[niSrv, SRVC_DATCAN]), "C", If(!Empty(aSrvVO4[niSrv, SRVC_DATFEC]), "F", If(!Empty(aSrvVO4[niSrv, SRVC_DATLIB]), "D", "A"))),;
				aSrvVO4[niSrv, SRVC_TEMPAD],                                                                                                                  ;
				aSrvVO4[niSrv, SRVC_APONT, niApont, SRVC_APONT_TEMTRA],                                                                                       ;
				aSrvVO4[niSrv, SRVC_APONT, niApont, SRVC_APONT_TEMCOB],                                                                                       ;
				aSrvVO4[niSrv, SRVC_APONT, niApont, SRVC_APONT_TEMVEN],                                                                                       ;
				0,                                                                                                                                            ;
				aSrvVO4[niSrv, SRVC_APONT, niApont, SRVC_APONT_DATINI],                                                                                       ;
				aSrvVO4[niSrv, SRVC_APONT, niApont, SRVC_APONT_HORINI],                                                                                       ;
				aSrvVO4[niSrv, SRVC_APONT, niApont, SRVC_APONT_DATFIN],                                                                                       ;
				aSrvVO4[niSrv, SRVC_APONT, niApont, SRVC_APONT_HOTFIN],                                                                                       ;
				"O",                                                                                                                                          ;
				aSrvVO4[niSrv, SRVC_TIPTEM],                                                                                                                  ;
				(cSQLVO4)->(VV1_CHASSI) }, .t.)
		Next

		nTPadrao += aSrvVO4[niSrv, SRVC_TEMPAD]

		If aSrvVO4[niSrv, SRVC_INCMOB] $ "1/3/4"
			If Empty(aSrvVO4[niSrv, SRVC_TEMPAD])
				FS_CRIAARQ("G",, {,,,,,,,,, (aSrvVO4[niSrv, SRVC_TEMTRA] * aSrvVO4[niSrv, SRVC_VALHOR]),,,,,,,}, .f.)
			Else
				FS_CRIAARQ("G",, {,,,,,,,,, ((aSrvVO4[niSrv, SRVC_TEMPAD] / 100) * aSrvVO4[niSrv, SRVC_VALHOR]),,,,,,,}, .f.)
			EndIf
		EndIf
	Next

	(cSQLVO4)->(dbSkip())
EndDo

(cSQLVO4)->(dbCloseArea())

DbSelectArea("VO2")

// Calculo Tempo Ausente
cQuery := "SELECT VO4.VO4_NUMOSV, VO4.VO4_TIPAUS, VO4.VO4_TEMAUS, VO4.VO4_DATINI, VO4.VO4_HORINI, "
cQuery += "       VO4.VO4_DATFIN, VO4.VO4_HORFIN, VO4.VO4_TIPTEM, X5_DESCRI "
cQuery += "FROM " + RetSqlName("VO4") + " VO4 "
cQuery += "INNER JOIN " + RetSqlName("VO1") + " VO1 ON VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_NUMOSV = VO4.VO4_NUMOSV AND VO1.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN " + RetSqlName("VV1") + " VV1 ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1.VV1_CHAINT = VO1.VO1_CHAINT AND VV1.D_E_L_E_T_ = ' ' "
cQuery += "LEFT JOIN " + RetSqlName("SX5") + " SX5 ON SX5.X5_FILIAL = '" + xFilial("SX5") + "' AND SX5.X5_TABELA = 'TA' "
cQuery += "  AND SX5.X5_CHAVE = VO4.VO4_TIPAUS AND SX5.D_E_L_E_T_ = ' ' "
cQuery += "WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND VO4.VO4_DATINI BETWEEN '" + Dtos(MV_PAR01) + "' AND '" + Dtos(MV_PAR02) + "' "
cQuery += "  AND VO4.VO4_CODPRO = '" + VAI->VAI_CODTEC + "' AND VO4.VO4_TIPAUS <> ' ' AND VO4.D_E_L_E_T_ = ' ' "
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLVO4, .F., .T.)

While !(cSQLVO4)->(Eof())
	FS_CRIAARQ("G",, { "",            ;
		(cSQLVO4)->(X5_DESCRI),       ;
		"",                           ;
		"",                           ;
		"",                           ;
		(cSQLVO4)->(VO4_TEMAUS),      ;
		0,                            ;
		0,                            ;
		0,                            ;
		0,                            ;
		SToD((cSQLVO4)->(VO4_DATINI)),;
		(cSQLVO4)->(VO4_HORINI),      ;
		SToD((cSQLVO4)->(VO4_DATFIN)),;
		(cSQLVO4)->(VO4_HORFIN),      ;
		(cSQLVO4)->(VO4_TIPAUS),      ;
		(cSQLVO4)->(VO4_TIPTEM),      ;
		(cSQLVO4)->(VV1_CHASSI) }, .t.)

	nTAus := nTAus + TTP->TTP_TEMPAD

	(cSQLVO4)->(dbSkip())
EndDo

(cSQLVO4)->(dbCloseArea())

DbSelectArea("VO2")

/*
While !Eof() .And. VO4->VO4_FILIAL == xFilial("VO4") .And. VO4->VO4_CODPRO == VAI->VAI_CODTEC ;
	.And. VO4->VO4_DATINI >= MV_PAR01 .And. VO4->VO4_DATINI <= MV_PAR02

	DbSelectArea("VO2")
	DbSetOrder(2)
	DbSeek(xFilial("VO2") + VO4->VO4_NOSNUM )

	DbSelectArea("VO1")
	DbSetOrder(1)
	DbSeek(xFilial("VO1") + VO2->VO2_NUMOSV )

	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek(xFilial("VV1") + VO1->VO1_CHAINT )

	DbSelectArea("VO6")
	DbSetOrder(2)
	DbSeek(xFilial("VO6")+FG_MARSRV(VV1->VV1_CODMAR,VO4->VO4_CODSER ) + VO4->VO4_CODSER )

	DbSelectArea("VOK")
	DbSetOrder(1)
	DbSeek(xFilial("VOK")+VO4->VO4_TIPSER)

	DBSelectArea("VV1")

	aTempTra   := FG_TEMPTRA(VAI->VAI_CODTEC,VO4->VO4_DATINI,VO4->VO4_HORINI, VO4->VO4_DATFIN , VO4->VO4_HORFIN ,"A",.f.,"O/E/A")

	For nSHorFin := 1 to Len( aTempTra )

		If aScan( aCodSer , VO1->VO1_NUMOSV + VO4->VO4_CODSER + VO4->VO4_TIPTEM ) == 0
			nTPadrao := nTPadrao + VO4->VO4_TEMPAD
		EndIf

		If Empty(VO4->VO4_TIPAUS)

			FS_CRIAARQ( "G" , , { VO4->VO4_CODSER, VO6->VO6_DESABR ,VO4->VO4_TIPSER, VO1->VO1_NUMOSV , If(!Empty(VO4->VO4_DATCAN),"C",If(!Empty(VO4->VO4_DATFEC),"F",If(!Empty(VO4->VO4_DATDIS),"D","A"))) , VO4->VO4_TEMPAD, VO4->VO4_TEMTRA, VO4->VO4_TEMCOB, VO4->VO4_TEMVEN, 0, VO4->VO4_DATINI, VO4->VO4_HORINI, VO4->VO4_DATFIN, VO4->VO4_HORFIN , "O" , VO4->VO4_TIPTEM , VV1->VV1_CHASSI } , .t. )

		Else

			FS_CRIAARQ( "G" , , { "", Posicione("SX5",1,xFilial("SX5")+"TA"+VO4->VO4_TIPAUS,"X5_DESCRI") ,"", "","", VO4->VO4_TEMAUS, 0, 0, 0, 0, VO4->VO4_DATINI, VO4->VO4_HORINI, VO4->VO4_DATFIN, VO4->VO4_HORFIN , VO4->VO4_TIPAUS , VO4->VO4_TIPTEM , VV1->VV1_CHASSI } , .t. )

			nTAus     := nTAus    +  TTP->TTP_TEMPAD

		EndIf

		If aScan(aCodSer,VO1->VO1_NUMOSV+VO4->VO4_CODSER+VO4->VO4_TIPTEM) == 0

			aAdd(aCodSer,VO1->VO1_NUMOSV+VO4->VO4_CODSER+VO4->VO4_TIPTEM)

			*** Olhar Observacoes do cabecalho ********************************************

			If VOK->VOK_INCMOB $ "1/3/4"

				If Empty( VO4->VO4_TEMTRA )

					FS_CRIAARQ( "G" , , {,,,,,,,,, ( aTempTra[nSHorFin,6] * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR) ) ,,,,,,,} , .f. )

				Else

					FS_CRIAARQ( "G" , , {,,,,,,,,, ((VO4->VO4_TEMTRA/100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR) ) ,,,,,,,} , .f. )

				EndIf

			EndIf

			*******************************************************************************

		EndIf

		&& Hora Extra ou Trabalhada
		If VO4->VO4_HOREXT == "E"
			nTExtra += TTP->TTP_TEMTRA
		Else
			nTTrab += TTP->TTP_TEMTRA
		EndIf

		nTCob  += TTP->TTP_TEMCOB
		nTVend += TTP->TTP_TEMVEN

	Next

	IncProc(  (STR0043+" "+Dtoc(mv_par01)+STR0005+Dtoc(mv_par02) ) ) //### //"Montando Periodo"###" a "

	DbSelectArea("VO4")
	DbSkip()

EndDo
*/

&& Tempo Parado
For niSrv := 1 to Len(aTempPar)

	If aTempPar[niSrv,5] $ "D" .And. TTP->( !DbSeek( Dtos( aTempPar[niSrv,1] ) + Str( aTempPar[niSrv,2] , 4 ) ) )

		FS_CRIAARQ( "G" , , { "", STR0044+ STR0010 +STR0045 , "", "","", 0, aTempPar[niSrv,6] , 0, 0, 0,aTempPar[niSrv,1] , aTempPar[niSrv,2], aTempPar[niSrv,3], aTempPar[niSrv,4] , "P" , "" , "" } , .t. ) //###### //"< "###"Tempo Parado"###" >"
		nTParado  := nTParado + TTP->TTP_TEMTRA

		IncProc(  (STR0043+" "+Dtoc(mv_par01)+STR0005+Dtoc(mv_par02) ) ) //### //"Montando Periodo"###" a "

	EndIf

Next

if Len(aMensagem) > 0
	cMensagem := STR0066+CHR(13) + CHR(10)+CHR(13) + CHR(10) // Foram encontradas ordens de servi็os onde o tempo padrใo, tempo trabalhado, tempo cobrado ou tempo vendido estใo com valores acima do pr้-determinado(tamanho 5). Verifique as seguintes ordens de servi็os:
	cMensagem += STR0067+CHR(13) + CHR(10)                   // OS                  Cod.Serv.
	For i := 1 to Len(aMensagem)
		cMensagem += Padr(aMensagem[i,1],15)+"  "+Padr(aMensagem[i,2],30)+CHR(13) + CHR(10)
	Next
	MsgStop(cMensagem)
	DbSelectArea("TTP")
	DbCloseArea()
	DbSelectArea("TMP")
	DbCloseArea()
	Return(.f.)
Endif

If Len(aPecas) == 0
	//Aadd(aPecas,{ "", "", "", 0, 0 ,"",Ctod("  /  /  "),"","",0})
	Aadd(aPecas,{ "", "", "", 0, 0 ,"",Space(8),"","",0})
EndIf

//asort(aPecas,,,{|x,y| Dtos(x[7])+x[1]+x[2] < Dtos(y[7])+y[1]+y[2] })
asort(aPecas,,,{|x,y| x[7]+x[1]+x[2] < y[7]+y[1]+y[2] })

&& Conta Corrente do Produtivo

For dDatRef := MV_PAR01 to MV_PAR02

	IncProc(  (Dtoc(dDatRef)) ) //### //"Montando Periodo"###" a "

	aAdd(aConta,{dDatRef,;
	FS_CALRMS(VAI->VAI_CODTEC,dDatRef,"0"),;
	FG_CALTEM(VAI->VAI_CODTEC,dDatRef,"1"),;
	FS_CALRMS(VAI->VAI_CODTEC,dDatRef,"0")-FG_CALTEM(VAI->VAI_CODTEC,dDatRef,"2"),;
	FG_CALTEM(VAI->VAI_CODTEC,dDatRef,"2"),;
	FG_CALTEM(VAI->VAI_CODTEC,dDatRef,"3"),;
	FG_CALTEM(VAI->VAI_CODTEC,dDatRef,"4"),;
	FG_CALTEM(VAI->VAI_CODTEC,dDatRef,"5"),;
	FG_CALTEM(VAI->VAI_CODTEC,dDatRef,"6"),;
	FG_CALTEM(VAI->VAI_CODTEC,dDatRef,"7"),;
	FG_CALTEM(VAI->VAI_CODTEC,dDatRef,"8") })

	nTCHorDis += aConta[Len(aConta),2]
	nTCHorPar += aConta[Len(aConta),4]
	nTCHorTra += aConta[Len(aConta),5]
	nTCHorExt += aConta[Len(aConta),6]
	nTCHorAus += aConta[Len(aConta),7]
	nTCHorVen += aConta[Len(aConta),8]
	nTCHorCob += aConta[Len(aConta),9]
	nTCValVen += aConta[Len(aConta),10]
	nTCQtdPec += aConta[Len(aConta),11]

Next

If Len(aConta) == 0

	Aadd(aConta,{Ctod("  /  /  "),0,0,0,0,0,0,0,0,0,0 })

EndIf

asort(aConta,,,{|x,y| x[1] > y[1] })

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CRIAARQบAutor  ณFabio               บ Data ณ  03/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria arquivo de trabalho                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CRIAARQ( cOperacao , lTotal , aGrava , lIncluir )

Local nFCount := 0 , _i := 0

If cOperacao == "C"
	aVetCampos := {}
	&& Cria Arquivo de Trabalho
	aadd(aVetCampos,{ "TTP_CODSER" , "C" , 15 , 0 })  && Codigo do Servico
	aadd(aVetCampos,{ "TTP_DESSER" , "C" , 18 , 0 })  && Descricao
	aadd(aVetCampos,{ "TTP_TIPSER" , "C" , 3  , 0 })  && Tipo de Servico
	aadd(aVetCampos,{ "TTP_NUMOSV" , "C" , 8  , 0 })  && Numero da Ordem de Servico
	aadd(aVetCampos,{ "TTP_STATUS" , "C" , 1  , 0 })  && Status da Ordem de Servico
	aadd(aVetCampos,{ "TTP_TEMPAD" , "N" , 5  , 0 })  && Tempo padrao
	aadd(aVetCampos,{ "TTP_TEMTRA" , "N" , 5  , 0 })  && Tempo Trabalhado
	aadd(aVetCampos,{ "TTP_TEMCOB" , "N" , 5  , 0 })  && tempo Cobrado
	aadd(aVetCampos,{ "TTP_TEMVEN" , "N" , 5  , 0 })  && tempo Vendido
	aadd(aVetCampos,{ "TTP_VALHOR" , "N" , 12 , 2 })  && Valor da hora
	aadd(aVetCampos,{ "TTP_DATINI" , "D" , 8  , 0 })  && data inicial
	aadd(aVetCampos,{ "TTP_HORINI" , "N" , 5  , 0 })  && Hora inicial
	aadd(aVetCampos,{ "TTP_DATFIN" , "D" , 8  , 0 })  && data final
	aadd(aVetCampos,{ "TTP_HORFIN" , "N" , 5  , 0 })  && Hora final
	aadd(aVetCampos,{ "TTP_TIPHOR" , "C" , 1  , 0 })  && Tipo da hora
	aadd(aVetCampos,{ "TTP_TIPTEM" , "C" , 4  , 0 })  && Tipo de tempo
	aadd(aVetCampos,{ "TTP_CHASSI" , "C" , 17 , 0 })  && Numero da Ordem de Servico
	aadd(aVetCampos,{ "TTP_FLAG"   , "L" , 1  , 0 })  && Tipo de tempo

	// TMP
	oObjTempTable := OFDMSTempTable():New()
	oObjTempTable:cAlias := "TMP"
	oObjTempTable:aVetCampos := aVetCampos
	oObjTempTable:AddIndex(cArqTMP1, {"TTP_DATINI","TTP_HORINI"} )
	oObjTempTable:AddIndex(cArqTMP2, {"TTP_NUMOSV"} )
	oObjTempTable:CreateTable(.f.)
	TMP->(DbSetOrder(2))

	// TTP
	o2ObjTempTable := OFDMSTempTable():New()
	o2ObjTempTable:cAlias := "TTP"
	o2ObjTempTable:aVetCampos := aVetCampos
	o2ObjTempTable:AddIndex(cArqIndex1, {"TTP_DATINI","TTP_HORINI"} )
	If GETVERSAO(.F.) < "12"
		o2ObjTempTable:AddIndex(cArqIndex2, {"TTP_DATINI","TTP_HORINI"}, "TTP_TIPHOR # 'P'")
	EndIf
	o2ObjTempTable:CreateTable()

EndIf

If cOperacao $ "F/C"

	DbSelectArea("TTP")
	DbSetOrder(1)

	DbSelectArea("TMP")
	If !TcSqlExec("DELETE FROM "+RetSqlName('TMP')) < 0
		ALERT(TCSQLError())
	EndIf

	DbSelectArea("TTP")

	If GETVERSAO(.F.) < "12"
		If lTotal
			DbSetOrder(1)
		Else
			DbSetOrder(2)
		EndIf
	Else
		DbSetOrder(1)
	EndIf

	DbGoTop()
	Do While !Eof()

		If GETVERSAO(.F.) >= "12" // Substituir filtro que existia no IndRegua das versoes anteriores a 12
			If !lTotal
				If TTP->TTP_TIPHOR == 'P'
					DbSelectArea("TTP")
					DbSkip()
					Loop
				EndIf
			EndIf
		EndIf

		DbSelectArea("TMP")
		RecLock("TMP", .T. )
		For nFCount := 1 to FCount()

			&( FieldName(nFCount) ) := TTP->( FieldGet(nFCount) )

		Next
		MsUnLock()

		DbSelectArea("TTP")
		DbSkip()

	EndDo

EndIf

If cOperacao == "G"

	lMensagem := .f.
	if aGrava[1] <> NIL
		if Len(alltrim(str(aGrava[9]))) > aVetCampos[9,3]
			lMensagem := .t.
		Endif
		if Len(alltrim(str(aGrava[8]))) > aVetCampos[8,3]
			lMensagem := .t.
		Endif
		if Len(alltrim(str(aGrava[7]))) > aVetCampos[7,3]
			lMensagem := .t.
		Endif
		if Len(alltrim(str(aGrava[6]))) > aVetCampos[6,3]
			lMensagem := .t.
		Endif
	Endif
	if lMensagem
		AADD(aMensagem,{aGrava[4],aGrava[1]} )
		lMensagem := .f.
	Elseif Len(aMensagem) == 0
		DbSelectArea("TTP")
		RecLock("TTP",lIncluir)
		For nFCount := 1 to ( FCount() - 1 )

			If aGrava[nFCount] # NIL

				&( FieldName(nFCount) ) := aGrava[ nFCount ]

			EndIf

		Next
		TTP->TTP_FLAG 	:= .F.
		MsUnLock()
	Endif
EndIf

If cOperacao == "A"

	DbSelectArea("TTP")
	o2ObjTempTable:CloseTable()

	DbSelectArea("TMP")
	oObjTempTable:CloseTable()

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CRIAHEAบAutor  ณFabio               บ Data ณ  03/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria aHeader                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CRIAHEADER()

AADD(aHeader,{ TRIM(STR0030) , "TTP_NUMOSV", "@!" 		 ,	8 , 0 , "" , "" , "C" , "TTP" , "V" } ) // //"Nro OS"
AADD(aHeader,{ TRIM(STR0046) , "TTP_STATUS", "@!" 		 ,	1 , 0 , "" , "" , "C" , "TTP" , "V" } ) // //"Status"
AADD(aHeader,{ TRIM(STR0062) , "TTP_TIPTEM", "@!" 		 ,	4 , 0 , "" , "" , "C" , "TTP" , "V" } ) // TTpo
AADD(aHeader,{ TRIM(STR0047) , "TTP_CODSER", "" 		 ,	15, 0 , "" , "" , "C" , "TTP" , "V" } ) // //"Cod Servico"
AADD(aHeader,{ TRIM(STR0037) , "TTP_DESSER", "" 		 ,	18, 0 , "" , "" , "C" , "TTP" , "V" } ) // //"Descricao"
AADD(aHeader,{ TRIM(STR0048) , "TTP_TIPSER", "@!" 		 ,	3 , 0 , "" , "" , "C" , "TTP" , "V" } ) // //"Tp Srv"
AADD(aHeader,{ TRIM(STR0011) , "TTP_TEMPAD", "@R 999:99" ,	5 , 0 , "" , "" , "N" , "TTP" , "V" } ) // //"Padrao"
AADD(aHeader,{ TRIM(STR0021) , "TTP_TEMTRA", "@R 999:99" ,	5 , 0 , "" , "" , "N" , "TTP" , "V" } ) // //"Trab"
AADD(aHeader,{ TRIM(STR0024) , "TTP_TEMCOB", "@R 999:99" ,	5 , 0 , "" , "" , "N" , "TTP" , "V" } ) // //"Cobr"
AADD(aHeader,{ TRIM(STR0023) , "TTP_TEMVEN", "@R 999:99" ,	5 , 0 , "" , "" , "N" , "TTP" , "V" } ) // //"Vend"
AADD(aHeader,{ TRIM(STR0049) , "TTP_DATINI", "@D" 	   	 ,	8 , 0 , "" , "" , "D" , "TTP" , "V" } ) // //"Dt Inicial"
AADD(aHeader,{ TRIM(STR0050) , "TTP_HORINI", "@R 999:99" ,	5 , 0 , "" , "" , "N" , "TTP" , "V" } ) // //"Hr Inicial"
AADD(aHeader,{ TRIM(STR0051) , "TTP_DATFIN", "@D"        ,	8 , 0 , "" , "" , "D" , "TTP" , "V" } ) // //"Dt Final"
AADD(aHeader,{ TRIM(STR0052) , "TTP_HORFIN", "@R 999:99" ,	5 , 0 , "" , "" , "N" , "TTP" , "V" } ) // //"Hr Final"
AADD(aHeader,{ TRIM(STR0053) , "TTP_CHASSI", "@!" 		 ,	17, 0 , "" , "" , "C" , "TTP" , "V" } ) // //"Chassi"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CRIMSGEบAutor  ณFabio               บ Data ณ  03/09/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria aheader                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CRMSGETDB()

If oLbaSrv # NIL
	DeleteObject( oLbaSrv )
EndIf

&& Lista movimento de hora do produtivo
oLbaSrv := MSGetDB():New(015, 001, aPos[1,3]-60 , aPos[1,4]-005, 2,"AllwaysTrue()","AllwaysTrue()",,.t.,,,.t.,,"TMP",,,,oFolder:aDialogs[2])
oLbaSrv:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oLbaSrv:oBrowse:SetFocus()
oLbaSrv:Refresh()
oLbaSrv:oBrowse:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_IMPCRR บAutor  ณFabio               บ Data ณ  12/05/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime conta corrente                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_IMPCRR()

Local nRecTMP:=TMP->(Recno())
Local cQuebra:="" , cOsvIni:="" , cOsvFin:="" , cStatus:="", cDescSer := ""
Local aTotal:={}, nTotGeral:=0 , nColTot:=0
Local nColHeader := 0
Local nColTol := 0

Local aArea := {}

cAlias   := Alias()
nLin 	  	:= 0
aPag		:= 1
nIte 		:= 1
aReturn 	:= { STR0054, 1,STR0055, 2, 2, 1, "",1 } //### //"Zebrado"###"Administracao"
Limite 	:= 132           // 80/132/220
aOrdem  	:= {STR0056,STR0057}           // Ordem do Relatorio //### //"Data Inicial+Hora Inicial"###"Ordem de Servico"
cTitulo	:= STR0058 // //"Conta Corrente do Produtivo"
cTamanho	:= "M"
cNomProg	:= "OFIOC090"
cNomeRel	:= "OFIOC090"
nLastKey	:= 0
cDesc1   := ""
cDesc2   := ""
cDesc3   := ""
cPerg    := "OFC090"
lserver  := .f.
nColHeader := 0

cNomeRel := SetPrint("TMP",cNomeRel,cPerg ,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,aOrdem,,cTamanho)

If nLastKey == 27
	Return
Endif

PERGUNTE("OFC090",.F.)

cOsvIni:=MV_PAR01
cOsvFin:=MV_PAR02
cStatus:=Substr(" ADFC",MV_PAR03,1)// Primeira posi็ใo equivale ao parametro MV_PAR03 = 'Todos'

PERGUNTE("OC090",.F.)  && Restaura parametros da primeira pergunte.

SetDefault(aReturn,cAlias)

Aadd(aTotal,{"TTP_TEMPAD" , {0,0,{}} , {0,0,{}} })
Aadd(aTotal,{"TTP_TEMTRA" , {0,0,{}} , {0,0,{}} })
Aadd(aTotal,{"TTP_TEMCOB" , {0,0,{}} , {0,0,{}} })
Aadd(aTotal,{"TTP_TEMVEN" , {0,0,{}} , {0,0,{}} })

aArea := sGetArea(aArea , "TMP")

DbSelectArea("TMP")
DbSetOrder(aReturn[8])
DbGoTop()
cQuebra := TTP_NUMOSV

Do While !Eof()

	If ( Empty(cOsvIni) .Or. TTP_NUMOSV >= cOsvIni ) .And. ( Empty(cOsvFin) .Or. TTP_NUMOSV <= cOsvFin ) .And. ( Empty(cStatus) .Or. TTP_STATUS == cStatus )

		@ FS_CABR090() , 00 PSay ""

		For nColHeader:=1 to Len(aHeader)

			If (nTotGeral:=Ascan(aTotal,{|x| x[1]==aHeader[nColHeader,2] })) # 0
				For nColTol:=2 to Len(aTotal[nTotGeral])

					If (aTotal[nTotGeral,1] $ "TTP_TEMPAD")

						If Ascan(aTotal[nTotGeral,nColTol,3],{|x| x[1]== TTP_NUMOSV+TTP_CODSER+TTP_TIPSER }) # 0

							Loop

						EndIf

						Aadd(aTotal[nTotGeral,nColTol,3],{ TTP_NUMOSV+TTP_CODSER+TTP_TIPSER })

					EndIf

					aTotal[nTotGeral,nColTol,1] += &(aTotal[nTotGeral,1])
					aTotal[nTotGeral,nColTol,2] := pCol()

				Next
			EndIf

			@ pRow() , pCol() PSay If(aHeader[nColHeader,2] $ "TTP_DATINI/TTP_DATFIN",;
			Day2Str(&(aHeader[nColHeader,2]))+"/"+Month2Str(&(aHeader[nColHeader,2]))+"/"+Right(Year2Str(&(aHeader[nColHeader,2])),2),;
			Transform(&(aHeader[nColHeader,2]), aHeader[nColHeader,3] ))+" "

		Next

		cQuebra := TTP_NUMOSV
		cDescSer:= TTP_DESSER
		DbSkip()

		If cQuebra # TTP_NUMOSV .Or. Eof()

			FS_TOTLINHA(aTotal,2,cQuebra,cDescSer = STR0044+ STR0010 +STR0045) // <  / Tempo Parado /   >

		EndIf

	Else

		DbSkip()

	EndIf

EndDo

FS_TOTLINHA(aTotal,3)

Set Printer to
Set Device  to Screen

If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf

MS_Flush()

sRestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CABR140บAutor  ณFabio               บ Data ณ  06/13/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCabecalho                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CABR090()

Local nColHeader:=1
Private cTitulo , cabec1 , cabec2 , nomeprog , tamanho , nCaracter
Private cbTxt,cbCont,cString,Li,m_Pag,wnRel

cbTxt    := Space(10)
cbCont   := 0
cString  := "TRA"
Li       := 80
m_Pag    := 1
wnRel    := "OFIOC090"

cTitulo:= STR0059 // //"Cartao Diario do Produtivo"
cabec1 := M->VAI_CODTEC+" "+M->VAI_NOMTEC+Space(5)+Dtoc(MV_PAR01)+STR0060+Dtoc(MV_PAR02) // //"  -  "
cabec2 := ""

For nColHeader:=1 to Len(aHeader)
	cabec2 += Substr( aHeader[nColHeader,1] , 1 , aHeader[nColHeader,4] )+Space((aHeader[nColHeader,4]-Len(Substr( aHeader[nColHeader,1] , 1 , aHeader[nColHeader,4] )))+1+If(STR0061$aHeader[nColHeader,3],1,0)) // //":"
Next

nomeprog	:="OFIOC090"
tamanho	:="M"
nCaracter:=15

If nLin == 0 .Or. nLin >= 63

	nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter)

EndIf

nLin += 1

Return( nLin )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TOTLINHA บAutor   ณFabio               บ Data ณ  10/10/00   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMostra total da linha                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TOTLINHA(aTotal,nTotal,cNroOs,lTempPar)
Local nTotGeral := 0
Default cNroOs := ""
Default lTempPar := .f.

@ FS_CABR090() , 00 PSay ""
For nTotGeral:=1 to Len(aTotal)
	@ pRow() , aTotal[nTotGeral,nTotal,2] PSay Replicate("-",Len(Transform(aTotal[nTotGeral,nTotal,1], aHeader[ Ascan(aHeader,{|x| x[2]==aTotal[nTotGeral,1] }) ,3] )))
Next

@ FS_CABR090() , 00 PSay ""

If nTotal = 2
	@ pRow(), 001 Psay  If(lTempPar,STR0064,STR0063+cNroOs) // TOTAL TEMPO PARADO / TOTAL OS 
	nLin += 1
ElseIf nTotal = 3
	@ pRow(), 001 Psay STR0065 // TOTAL GERAL
EndIf

For nTotGeral:=1 to Len(aTotal)
	If !(nTotal = 2 .and. aTotal[nTotGeral,nTotal,2] = 0)
		@ pRow() , aTotal[nTotGeral,nTotal,2] PSay Transform(aTotal[nTotGeral,nTotal,1], aHeader[ Ascan(aHeader,{|x| x[2]==aTotal[nTotGeral,1] }) ,3] )
	EndIf
	aTotal[nTotGeral,nTotal,1] := 0
	aTotal[nTotGeral,nTotal,2] := 0
	aTotal[nTotGeral,nTotal,3] := {}
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CALRMS   บAutor   ณFabio               บ Data ณ  10/10/00   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula horas disponiveis                                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_CALRMS(cCodPro, dDatRef, cAssunto, dDatFin, cCodFor, cTipTot, cTipAgr, cTipTem, cTipPas)
Local nRet     := 0
Local aRet     := {}
Local aRetV    := {}
Local nTpoDis  := 0
Local nValPar  := 0
Local aHorario := {}
Local aVerPad  := {}
Local aVetTra  := {}
Local aArea    := {}
Local ix1      := 0

Local cSQLVAI := "SQLVAI"
Local cQuery  := ""

Local ix1_   := 0
Local cVar1_ := ""
Local cVar2_ := ""

For ix1_ := 1 to 30
	cVar1_ := "MV_PAR" + strzero(ix1_, 2)
	If &cVar1_ == Nil
		Exit
	EndIf

	cVar2_  := "MVB_PAR" + strzero(ix1_, 2)
	&cVar2_ := &cVar1_
Next

DbSelectArea("VAI")
aArea := GetArea()

Do Case
	Case cAssunto == "0" // Horas Disponiveis
		cQuery := "SELECT VOE.VOE_DATESC, VOH.VOH_INIPER, VOH.VOH_INICF1, VOH.VOH_FINCF1, VOH.VOH_INIREF, "
		cQuery += "       VOH.VOH_FINREF, VOH.VOH_INICF2, VOH.VOH_FINCF2, VOH_FINPER "
		cQuery += "FROM " + RetSqlName("VAI") + " VAI "
		cQuery += "INNER JOIN " + RetSqlName("VOE") + " VOE ON VOE.VOE_FILIAL = '" + xFilial("VOE") + "' AND VOE.VOE_CODPRO = VAI.VAI_CODTEC "
		cQuery += "  AND VOE.VOE_DATESC <= '" + DToS(dDatRef) + "' AND VOE.D_E_L_E_T_ = ' ' "
		cQuery += "INNER JOIN " + RetSqlName("VOH") + " VOH ON VOH.VOH_FILIAL = '" + xFilial("VOH") + "' AND VOH.VOH_CODPER = VOE.VOE_CODPER AND VOH.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE VAI.VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI.VAI_CODTEC = '" + cCodPro + "' AND VAI.VAI_FUNPRO = '1' "
		cQuery += "  AND (VAI.VAI_DATDEM IS NULL OR VAI.VAI_DATDEM = ' ' OR VAI.VAI_DATDEM > '" + DToS(dDatRef) + "') AND VAI.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY VOE.VOE_DATESC DESC "
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLVAI, .F., .T.)

		If !(cSQLVAI)->(Eof())
			aHorario := {}
			nTpoDis := 0

			aAdd(aHorario, (cSQLVAI)->(VOH_INIPER))
			aAdd(aHorario, (cSQLVAI)->(VOH_INICF1))
			aAdd(aHorario, (cSQLVAI)->(VOH_FINCF1))
			aAdd(aHorario, (cSQLVAI)->(VOH_INIREF))
			aAdd(aHorario, (cSQLVAI)->(VOH_FINREF))
			aAdd(aHorario, (cSQLVAI)->(VOH_INICF2))
			aAdd(aHorario, (cSQLVAI)->(VOH_FINCF2))
			aAdd(aHorario, (cSQLVAI)->(VOH_FINPER))

			nValPar := 0

			For ix1 := 1 to 8
				If aHorario[ix1] == 0
					If Str(ix1, 1) $ "2/4/6/8"
						nTpoDis += aHorario[ix1] - nValPar
					Else
						nValPar := aHorario[ix1]
					EndIf

					Loop
				EndIf

				If ix1 != 1
					If aHorario[ix1 - 1] > aHorario[ix1]
						aHorario[ix1] += 2400
					EndIf
				EndIf

				aHorario[ix1] := val(left(strzero(aHorario[ix1], 4), 2) + right(strzero(val(right(strzero(aHorario[ix1], 4), 2)) / 0.6, 4), 2))

				If Str(ix1, 1) $ "2/4/6/8"
					nTpoDis += aHorario[ix1] - nValPar
				Else
					nValPar := aHorario[ix1]
				EndIf
			Next

			dbSelectArea("VO4")
			dbSetOrder(2)
			Iif(VO4->(MsSeek(xFilial("VO4") + cCodPro + (cSQLVAI)->(VOE_DATESC), .t.)), .t., dbSkip(-1))

			If SToD((cSQLVAI)->(VOE_DATESC)) >= VO4->VO4_DATINI .And. SToD((cSQLVAI)->(VOE_DATESC)) <= VO4->VO4_DATFIN
				If VO4->VO4_TIPAUS <> "  "
					nTpoAus := nTpoDis
					nTpoDis := nTpoAus - nTpoDis
				EndIf
			EndIf


			nRet += nTpoDis
		EndIf

		(cSQLVAI)->(dbCloseArea())

		DbSelectArea("VAI")
EndCase

RestArea(aArea)
Return nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef     บAutor   ณFabio               บ Data ณ  10/10/00   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMenu						                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},;   && Pesquisar // //"Pesquisar"
{ STR0002 ,"OC090"   , 0 , 2}}    && Visualizar // //"Visualizar"
Return aRotina
