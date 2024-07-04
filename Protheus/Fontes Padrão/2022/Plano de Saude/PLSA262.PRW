#INCLUDE "plsa262.ch"
#include "PROTHEUS.CH"

#include "PLSMGER.CH"
#define  K_DefExc  4
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA262 ³ Autor ³ Tulio Cesar          ³ Data ³ 24.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exportacao ou impressao de identificacao de usuarios       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA262
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta matriz com as opcoes do browse...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsBlV      := GetNewPar("MV_PLBLQVE",.F.)
PRIVATE aRotina   := MenuDef()							
PRIVATE cDesCar   := Posicione("BA0",1,xFilial("BA0")+PLSINTPAD(),"AllTrim(If(Empty(BA0_NOMCAR), 'Cartão de Identificação', BA0_NOMCAR))") //'Carteira'
PRIVATE cCadastro := STR0010+AllTrim(cDesCar) //"Exportacao/Emissao de "

PRIVATE	aCores 	:= 	{ { "BDE->BDE_STACAR='1'", 'BR_VERDE'    },;
                      { "BDE->BDE_STACAR='2'", 'BR_VERMELHO' } }

PRIVATE aCdCores  := { 	{ 'BR_VERDE'    ,STR0011     },; //'Em aberto' 
	 					{ 'BR_VERMELHO' ,STR0012     }} //'Encerrado

If lUsBlV

	AADD(aCores,   { "BDE->BDE_STACAR='3'", 'BR_AZUL'     })
	AADD(aCores,   { "BDE->BDE_STACAR='4'", 'BR_AMARELO'  })	
	AADD(aCdCores, { 'BR_AZUL'            ,STR0041        })
	AADD(aCdCores, { 'BR_AMARELO'         ,STR0040        })

EndIf
						
If ExistBlock("PLBDEBTADD")
        aBtAdd := ExecBlock("PLBDEBTADD",.F.,.F.,{aRotina})
        If ValType(aBtAdd) == "A"
                AEval(aBtAdd,{|x| AAdd(aRotina,x)})
        EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Starta mBrowse...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BDE->(DBSetOrder(1))
BDE->(mBrowse(06,01,22,75,'BDE',,,,,,aCores,,,,, .T. ))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA262EXP ³ Autor ³ Tulio Cesar       ³ Data ³ 25.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exportacao/Impressao de identificacao de usuario           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA262EXP(cAlias,nReg,nOpc)
Local I__f := 0

Local oDlg
Local oEnc
Local aRet   
Local nOpca
Local bOK
Local bCancel
Local _nH
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre semaforo...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_nH := PLSAbreSem("PLSA262.SMF",.F.)
If  _nH == 0
    msgalert(STR0013) //"Rotina em uso por outro usuario. Tente novamente."
    Return()
Endif    

TCREFRESH(RetSqlName("BDE"))

BEGIN TRANSACTION    

bOK     := {|| nOpca := 1, aRet := PLSA262Ext(oEnc:aGets,oEnc:aTela,M->BDE_CODINT,M->BDE_CODIGO,oDlg),If(aRet[1].and.aRet[2,1]>0,oDlg:End(),.f.) }
bCancel := {|| nOpca := 0, oDlg:End() }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1, 1, .T., .T., .F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Copy cAlias To Memory Blank
oEnc := BDE->(MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,{}) Center

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui movimento...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca = K_OK .and. aRet[1]
	M->BDE_QTD    := aRet[2,1]
	M->BDE_STACAR := "1"
	
	if M->BDE_TIPGER <> '2'
		BDE->(PLUPTENC("BDE",K_Incluir))
	endIf	
Endif

END TRANSACTION    

TCREFRESH(RetSqlName("BDE"))

If ExistBlock("PLS262GR") .And. nOpca == K_OK .And. aRet[1]
   ExecBlock("PLS262GR",.F.,.F.)
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha semaforo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PLSFechaSem(_nH,"PLSA262.SMF")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA262EXT ³ Autor ³ Tulio Cesar       ³ Data ³ 25.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Trata rotina externa                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLSA262Ext(aGets,aTela,cCodInt,cCodigo,oDlg)

Local cExpRdm
Local aRet := {.T.,{}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa campos obrigatorios...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Obrigatorio(aGets,aTela)
    aRet := {.F.,{}}
	Return(aRet)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Solicita confirmacao                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cMsg := chr(13) + STR0015 //"Voce deseja confirmar o processamento para os parametros informados ?"

If  M->BDE_MUDVAL == "1"
    cMsg += chr(13) 
    cMsg += chr(13) 
    cMsg += STR0016 + chr(13)  //"obs: a data de validade dos usuarios selecionados sera alterada"
    If !Empty(M->BDE_DATVAL)
       cMsg += STR0017 + dtoc(M->BDE_DATVAL) //"          para "
    EndIf   
Endif     

If  Aviso(STR0018,cMsg, { STR0019,STR0020 },2) <> 1 //"Confirmacao"###"&Sim"###"&Nao"
    aRet := {.F.,{}}
	Return(aRet)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na Operadora...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA0->(DbSetOrder(1))
If BA0->(MsSeek(xFilial("BA0")+cCodInt))
	If Empty(BA0->BA0_EXPIDE)
		cExpRdm := AllTrim(GetMV("MV_PLSEXPI"))
	Else
		cExpRdm := AllTrim(BA0->BA0_EXPIDE)
	Endif
	If ExistBlock(cExpRdm)
		aRet := ExecBlock(cExpRdm,.F.,.F.,{cCodigo,M->BDE_MOTIVO,cCodInt,oDlg})
	Else
		aRet := Plsa264({cCodigo,M->BDE_MOTIVO,cCodInt,oDlg,NIL,NIL,NIL,NIL,NIL,NIL,.T.,(M->BDE_TIPGER=='2')})
	EndIf   
	
	If ValType(aRet) <> "A"
		aRet := {.T.,{0},{},{}}
	Endif
	
Else
    aRet := {.F.,{},{},{}}
Endif

If  aRet[2,1] == 0
	msgStop(STR0021) //"Nenhum usuario encontrado para os parametros informados"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA262VIS ³ Autor ³ Eduardo Motta     ³ Data ³ 15.04.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualizacao                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA262VIS(cAlias,nReg,nOpc)
Local I__f := 0

Local aRet
Local oDlg
Local oEnc
Local oGetBED
Local nOpca    	:= 0
Local aHeader  	:= {}
Local aCols    	:= {}
Local aVetTrab 	:= {}
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}

Private n 		:= 1


If Len( aHeader ) == 0
	Store HEADER "BED" TO aHeader For .T.
Endif	


If nOpc == K_Incluir
	Store COLS Blank "BED" TO aCols FROM aHeader
Else
	aCols:= MntAcols(cAlias,nOpc,aHeader,aCols,aVetTrab)
EndIf                             

Copy cAlias To Memory Blank
/*
Store Header "BED" to aHeader For .T.

DbSelectArea("BED")
DbSetOrder(4)

If MsSeek(xFilial("BED")+BDE->BDE_CODIGO)
	Store COLS "BED" TO aCols FROM aHeader VETTRAB aVetTrab While xFilial("BED") == BED->BED_FILIAL .and. BDE->BDE_CODIGO == BED->BED_CDIDEN
Else
	Store COLS Blank "BED" TO aCols FROM aHeader
EndIf
*/
aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1,  1, .T., .T., .F. } )
AAdd( aObjects, { 1, 70, .T., .F., .F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel

oEnc := BDE->(MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.))
oGetBED := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil  ,oDlg,nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BED",nOpc,STR0022,nil,nil,nil,aVetTrab,,,) //"Lotes"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},.F.,{}) Center

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA262ENC ³ Autor ³ Eduardo Motta     ³ Data ³ 15.04.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Encerramento do lote                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA262ENC(cAlias,nReg,nOpc)
Local I__f := 0

Local oDlg
Local oEnc
Local aRet
Local oGetBED
Local nOpca    	:= 0
Local aHeader  	:= {}
Local aCols    	:= {}
Local aVetTrab 	:= {}
Local aPosObj   := {}
Local aObjects  := {}  
Local aSize     := {}
Local aInfo     := {}
Local lBlqVEnc   := GetNewPar("MV_PLBLQVE",.F.) 
Local lContCp    := BED->( FieldPos("BED_CTRBLO") ) > 0 .And. BED->( FieldPos("BED_STAANB") ) > 0
Local cSQLBED	 := ""
Local aInfBl     := {} 
Local dBlqDat    := dDataBase
Local cBloMot    := GetNewPar("MV_PLMOTBA","51")
Local cBlqObs    := GetNewPar("MV_PLOBSBQ","")
Local cTipoB     := "1"
Local nI          := 0
Local cBDELot    := ""
Local aLotBlq    := {} 
Local aLotBDE    := {}
Local cBDECdI    := ""
Local lRet       := .F.
Local aAreaBde 	 := BDE->(GetArea())
Local lPosBed    := .T.
Local cQuery    

Private n 		:= 1

If lBlqVEnc .And. !lContCp  
	MsgStop(STR0042) //"Parâmetro MV_PLBLQVE Ativo, porém o Dicionário de dados está desatualizado.!!!"
	Return 
EndIf

SX5->(DbSetOrder(1))

If lBlqVEnc

	If cBloMot >= "50"

		lRet := SX5->(DbSeek(xFilial("SX5")+"BG"+cBloMot))
		
		If !lRet
			msginfo(STR0043)  //"Código de Bloqueio não existe na Tabela BG."
			Return     		
		EndIf
	Else
		msginfo(STR0044)  //"Escolha um codigo referente a bloqueio."
		Return     
	EndIf	
EndIf

aCols:= MntAcols(cAlias,nOpc,aHeader,aCols,aVetTrab)

Copy cAlias To Memory Blank

aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1,  1, .T., .T., .F. } )
AAdd( aObjects, { 1, 70, .T., .F., .F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel

oEnc := BDE->(MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.))
oGetBED := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil  ,oDlg,nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BED",nOpc,STR0022,nil,nil,nil,aVetTrab,,,) //"Lotes"

M->BDE_CODIGO := BDE->BDE_CODIGO
M->BDE_MOTIVO := BDE->BDE_MOTIVO
M->BDE_TIPGRU := BDE->BDE_TIPGRU
M->BDE_UNILOC := BDE->BDE_UNILOC
M->BDE_EMPDE  := BDE->BDE_EMPDE
M->BDE_EMPATE := BDE->BDE_EMPATE
M->BDE_CONDE  := BDE->BDE_CONDE
M->BDE_CONATE := BDE->BDE_CONATE
M->BDE_SUBDE  := BDE->BDE_SUBDE
M->BDE_SUBATE := BDE->BDE_SUBATE
M->BDE_MATDE  := BDE->BDE_MATDE 
M->BDE_MATATE := BDE->BDE_MATATE 
M->BDE_TIPGER := BDE->BDE_TIPGER
M->BDE_DATA1  := BDE->BDE_DATA1
M->BDE_DATA2  := BDE->BDE_DATA2
M->BDE_DIRGRV := BDE->BDE_DIRGRV
M->BDE_MUDVAL := BDE->BDE_MUDVAL
M->BDE_DATVAL := BDE->BDE_DATVAL
M->BDE_QTD    := BDE->BDE_QTD 
M->BDE_STACAR := BDE->BDE_STACAR
M->BDE_EMPRES := BDE->BDE_EMPRES
M->BDE_DATENT := BDE->BDE_DATENT
If BED->( FieldPos("BED_GRPDE") ) > 0 .AND. BED->( FieldPos("BED_GRPATE") ) > 0
	M->BDE_GRPDE  := BDE->BDE_GRPDE 
	M->BDE_GRPATE := BDE->BDE_GRPATE
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca := 1,oDlg:End()},{||nOpca := 0,oDlg:End()},.F.,{}) Center

If nOpca == 1
	
	If BDE->BDE_STACAR <> "1"
		MsgStop(STR0023) //"Somente lotes em aberto podem ser encerrados."
		Return
	EndIf

	// Query para verificar se tem algum lote aguardando pagamento do titulo
	cQuery := "SELECT BED_FATUR FROM "+RetSqlName("BED")+ " BED "
    cQuery += "WHERE BED_FILIAL = '"+xFilial("BED")+"' AND "
    cQuery += "BED_CDIDEN = '"+BDE->BDE_CODIGO+"' AND "
	cQuery += "BED_FATUR = '2' AND " // Aguardando Pagamento
    cQuery += "BED.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TrbBED",.F.,.T.)

	If !TrbBED->(Eof())
		MsgStop(STR0045) //"Não é possivel encerrar o lote enquanto tiver titulos aguardando o pagamento"
		TrbBED->(DbCloseArea())
		Return
	Endif

	TrbBED->(DbCloseArea())

	BEGIN TRANSACTION    

	BDE->(RecLock("BDE",.F.))
	BDE->BDE_STACAR := "2"
	BDE->BDE_EMPRES := M->BDE_EMPRES
	BDE->BDE_DATENT := M->BDE_DATENT
	
	BDE->(MsUnlock())
	
	BA1->(dbsetOrder(2))
	BED->(DbSetOrder(4))
	BED->(MsSeek(xFilial("BED")+BDE->BDE_CODIGO))

	While xFilial("BED") == BED->BED_FILIAL .and. BDE->BDE_CODIGO == BED->BED_CDIDEN
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza status de cada cartao do lote                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BED->(RecLock("BED",.F.))
		BED->BED_STACAR := "2"
		BED->(MsUnlock())
		If lBlqVEnc .And. lContCp 	
			AADD(aLotBlq,{BED->BED_FILIAL+BED->BED_CODINT+BED->BED_CODEMP+BED->BED_MATRIC+BED->BED_TIPREG+BED->BED_DIGITO,BED->BED_CDIDEN,BED->BED_CTRBLO})

		EndIf	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza status de emissao de cartao no usuario                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If BA1->(msSeek(xFilial("BA1")+BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG+BED_DIGITO))) .and. ;
			BA1->BA1_EMICAR == "2"
			If BA1->(RecLock("BA1",.F.))
				BA1->BA1_EMICAR := "3" // gerado
				BA1->(msUnLock())
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza status de cada cartao do lote                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acessa proximo cartao do lote                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BED->(DbSkip())
	EndDo

    If lBlqVEnc	.And. lContCp .And. PLSALIASEX("B1D")

		cBDELot := BDE->BDE_CODIGO
		cBDECdI := BDE->BDE_CODINT
						
		If !Empty(cBloMot) .And. !Empty(cTipoB) .And. Len(aLotBlq) >= 1
	
		    B1D->(DbSetOrder(1))
	
	        For nI:=1   To Len(aLotBlq)
	
				BED->(DbGoTop()) 		
	
				While ! BED->(Eof())
					If aLotBlq[nI,1] == BED->BED_FILIAL + BED->BED_CODINT + BED->BED_CODEMP + BED->BED_MATRIC + BED->BED_TIPREG + BED->BED_DIGITO .And.;
					cBDELot > BED->BED_CDIDEN .And. BED->BED_BLOIDE <> "1"  
					
						RecLock("BED", .F.)
									    
						BED->(RecLock("BED",.F.))  
						BED->BED_STACAR := "3"		// Via Bloqueada
						BED->BED_CTRBLO := cBDELot
						BED->(MsUnlock())						

				        If lPosBed 
								
			    			AADD(aLotBDE,{BED->BED_FILIAL, BED->BED_CODINT,BED->BED_CDIDEN,BED->BED_CTRBLO})
						    
		    			Else
		    				If(Ascan(aLotBDE,{|x| x[1]+ x[2]+ x[3] == BED->BED_FILIAL+BED->BED_CODINT+BED->BED_CDIDEN}))=0  			
				    			AADD(aLotBDE,{BED->BED_FILIAL, BED->BED_CODINT,BED->BED_CDIDEN,BED->BED_CTRBLO})
						    			
							EndIf			    					
		    			EndIf	
						lPosBed := .F.
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Crio historico do (des)bloqueio das Vias                            ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										
						BlqIdent("1",dDataBase,cBloMot,cBlqObs)
								
					EndIf		
			    BED->(DbSkip())
				EndDo		
			Next nI 
			If Len(aLotBDE)>=1 
			
				PLAJCABDE(aLotBDE,"1") //atualizo cabecalho dos lotes bloqueados
				
			EndIf 				
		EndIf	
	EndIf
	
	END TRANSACTION    
	
EndIf        

Restarea(aAreaBDE)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA262NUM ³ Autor ³ Tulio Cesar       ³ Data ³ 25.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna proximo numero                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA262NUM(cCodInt)

Local cNum := ""
Local nTam := Len(BDE->BDE_CODIGO)

BDE->(DbSetOrder(1))
BDE->(MsSeek(xFilial("BDE")+cCodInt+Replicate("9",nTam),.T.))

BDE->(DbSkip(-1))

If BDE->(BDE_FILIAL+BDE_CODINT) == xFilial("BDE")+cCodInt
	cNum := StrZero(Val(BDE->BDE_CODIGO)+1,nTam)
Else
	cNum := StrZero(1,nTam)
Endif

Return(cNum)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA262EXC ³ Autor ³ Tulio Cesar       ³ Data ³ 25.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui identificacao de usuario                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA262EXC(cAlias,nReg,nOpc)
Local I__f 		:= 0

Local oDlg
Local oEnc
Local cSQL		:= ""
Local cCodInt	:= ""
Local cCodEmp	:= ""
Local cMatric	:= ""
Local cTipReg	:= ""
Local cDigito	:= ""
Local nRegBED   := 0
Local nOrdBED   := 0
Local nOrdBBT   := 0
Local nOrdSE1   := 0
Local nOpca     := 0
Local nUltVia   := 0
Local lDeleta   := .T.
Local aVetor    := {}
Local cArea     := Alias()
Local cQuebra   := Chr(13)
Local cOperad   := BDE->BDE_CODINT
Local cCodigo   := BDE->BDE_CODIGO
Local bOK       := { || (Iif(ExistBlock("PLSA262EXC"),If(ExecBlock("PLSA262EXC",.F.,.F.,{cOperad,cCodigo}),(nOpca := 1, oDlg:End()),.F.),(nOpca := 1, oDlg:End())))}
Local bCancel   := { || oDlg:End() }
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local aRetBED   := {}
LOCAL aCriticas := {}

SE1->(DbSetOrder(1))

If BDE->BDE_STACAR == "2"
	MsgStop(STR0024) //"Lote já encerrado e não poderá ser excluído!"
	Return
EndIf
If BDE->BDE_STACAR $ "3,4"
	MsgStop(STR0039) //"Lote com Bloqueio Total ou Parcial, não poderá ser excluído!"
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1, 1, .T., .T., .F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Copy cAlias To Memory

oEnc := BDE->(MsMGet():New(cAlias,nReg,K_Visualizar,,,,,aPosObj[1],,,,,,oDlg,,,.F.))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,{}) Center

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define tratamento de acordo com a opcao...                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK

	cSQL := " SELECT R_E_C_N_O_ REG FROM " + RetSQLName("BED")
	cSQL += " WHERE BED_FILIAL = '" + xFilial("BED") + "' AND "
	cSQL += "       BED_CODINT = '" + cOperad + "' AND "
	cSQL += "       BED_CDIDEN = '" + cCodigo + "' AND "
	cSQL += "       D_E_L_E_T_ <> '*' "

	PLSQuery(cSQL,"TrbA262")
	
	While ! TrbA262->(Eof())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona BED...   							                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BED->(DbGoTo(TrbA262->(REG)))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se foi faturada...                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE1->(MsSeek(xFilial("SE1")+BED->(BED_PREFIX + BED_NUMTIT + BED_PARCEL + BED_TIPTIT)))
			
			If BED->BED_FATUR == "1"
	        	Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0025})//"Não é possível excluir este lançamento pois ele já foi faturado!"###"Usuário: "
				lDeleta := .F.
			Else
				If SE1->E1_SALDO = 0
		        	Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0027})//"Não é possível excluir este lançamento pois ele já foi pago!"###"Usuário: "
					lDeleta := .F.
				Endif
			Endif
			
		EndIf		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se eh o ultimo lote emitido para este usuario...           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodInt := BED->BED_CODINT
		cCodEmp := BED->BED_CODEMP
		cMatric := BED->BED_MATRIC
		cTipReg := BED->BED_TIPREG
		cDigito := BED->BED_DIGITO

		nUltVia := PL261UVC(cCodInt, cCodEmp, cMatric, cTipReg)[1]
		
		If nUltVia >= 0
			If nUltVia <> BED->BED_VIACAR
	        	Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0028})//"Somente a última via do cartão do usuário pode ser excluída!"###"Usuário: "
				lDeleta := .F.
			Endif
		Else
        	Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0029})//"Última via do cartão do usuário não encontrada. Verifique!"
			lDeleta := .F.
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a via do cartao esta bloqueada...           			³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If BED->( FieldPos("BED_CODBLO") ) = 0 .AND. BED->( FieldPos("BED_BLOIDE") ) = 0
        	Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0030})//"Dicionario de dados desatualizado!!!"
			lDeleta := .F.
		Else
			IF BED->BED_BLOIDE == "1"
	        	Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0031})//"Via do Cartão não pode ser excluida pois está bloqueada!"
				lDeleta := .F.
			Endif
		Endif
		
		TrbA262->(DbSkip())
	EndDo
	
	TrbA262->(DbGoTop())
		
	If lDeleta 
		
		BEGIN TRANSACTION    
		
		While ! TrbA262->(Eof())
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona BED...   							                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BED->(DbGoTo(TrbA262->(REG)))
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Alimenta variaveis...                                        		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodInt := BED->BED_CODINT
			cCodEmp := BED->BED_CODEMP
			cMatric := BED->BED_MATRIC
			cTipReg := BED->BED_TIPREG
			cDigito := BED->BED_DIGITO
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza dados no usuario...                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If BED->BED_FATUR <> "2"
				BA1->(DbSetOrder(2))
				If BA1->(MsSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+cTipReg))
				
					BA1->(RecLock("BA1",.F.))
					
					If BA1->BA1_VIACAR > 1 .And. AllTrim(FunName()) == AllTrim(BED->BED_ORIGEM)
						
						aRetBED := PL261UVC(cCodInt, cCodEmp, cMatric, cTipReg, , )
						
						If aRetBED[1] >= 0
						
							BA1->BA1_VIACAR := aRetBED[1] - 1
							BA1->BA1_CDIDEN := aRetBED[4]
							BA1->BA1_DTVLCR := aRetBED[3]
							GrvVldCarUsr(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),aRetBED[3])
						
						Else
				        	Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0032})//"Não foi encontrada a Via anterior do Cartão. Verifique!"###"Usuário: "
						Endif
						
					Else
						If	AllTrim(FunName()) == AllTrim(BED->BED_ORIGEM)
							BA1->BA1_VIACAR := 0							
							BA1->BA1_CDIDEN := ""
							If BDE->BDE_MUDVAL == "1"
								BA1->BA1_DTVLCR := RetBA3Val()
							EndIf
							GrvVldCarUsr(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_DTVLCR)
						EndIf	
					Endif
					
					BA1->(MsUnLock())
					
				Endif
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza Financeiro... 		                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nOrdBBT := BBT->(IndexOrd())
			BBT->(DbSetOrder(7))

			If BBT->(MsSeek(xFilial("BBT")+BED->(BED_PREFIX + BED_NUMTIT + BED_PARCEL + BED_TIPTIT)))
			
				BBT->(RecLock("BBT",.F.))
				BBT->(DbDelete())
				BBT->(MsUnLock())
			
			Endif
			
			BBT->(DbSetOrder(nOrdBBT))
		
			nOrdSE1 := SE1->(IndexOrd())
			SE1->(DbSetOrder(1))

			If SE1->(MsSeek(xFilial("SE1")+BED->(BED_PREFIX + BED_NUMTIT + BED_PARCEL + BED_TIPTIT)))
			
				nOldMod := nModulo
				nModulo := 6
		
				aVetor  := {	{"E1_PREFIXO" ,SE1->E1_PREFIXO ,Nil},;
								{"E1_NUM"	  ,SE1->E1_NUM     ,Nil},;
								{"E1_PARCELA" ,SE1->E1_PARCELA ,Nil},;
								{"E1_TIPO"	  ,SE1->E1_TIPO    ,Nil},;
								{"E1_NATUREZ" ,SE1->E1_NATUREZ ,Nil} }
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exclui registro em SE1...	                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MSExecAuto({|x,y| Fina040(x,y)},aVetor,5)
					
				nModulo := nOldMod
				
			Endif		

			SE1->(DbSetOrder(nOrdSE1))
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza BED...														³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If AllTrim(FunName()) == AllTrim(BED->BED_ORIGEM)
				BED->(RecLock("BED",.F.))
				BED->(DbDelete())
				BED->(MsUnLock())
			Else
				BED->(RecLock("BED",.F.))
				BED->BED_CDIDEN := "AVULSA"
				BED->(MsUnLock())
				
				Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0038})//"Via de cartão do usuário emitida pela rotina de Lançamentos Avulsos, o registro não será excluído."
			Endif
			
			TrbA262->(DbSkip())
		EndDo	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui BDE... 						                        		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
			BDE->(PLUPTENC("BDE",K_Excluir))
		
		END TRANSACTION    
		
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha Temporario... 						                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TrbA262->(DbCloseArea())

Endif

If ! Empty(cArea)
	DbSelectArea(cArea)
Endif
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apresenta as critinas no final...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCriticas) > 0
	Aviso("Críticas","Houveram críticas no processamento!",{"Visualizar"})
	
	PLSCRIGEN(aCriticas,{ 	{"Matricula","@!", 70},; //"Matrícula" 
 							{"Critica","@!", 170 }},"Criticas")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA262Prn ³ Autor ³Wagner Mobile Costa³ Data ³ 28.08.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Emite as carteiras do lote selecionado                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA262PT()
Return Plsa262Prn()

Function PLSA262Prn(cCodLote)
Local aRet	  	:= {}
Local cExpRdm 	:= ""
Local cCodInt 	:= ""
Local cCodEmp 	:= ""
Local cMatric 	:= ""
Local cTipReg 	:= ""
Local nI      	:= 0
Local aRecno  	:= {}
Local lNew 	  	:= .F.
local lImpressao:= .f.
Local cOperad 	:= PlsIntPad()
Local nUltVia 	:= 0
Local lImprim 	:= .T.
Local lAgrupa 	:= .T.
Local cQuebra 	:= Chr(13)
Local nTipPes 	:= 1   // 1=todas   2=fisica   3=juridica
Local lErro   	:= .F.
Local lReturn   := .F.
Local lReemissao:= .F.

If cCodLote == Nil
	If !Pergunte("PLS263")
		Return
	EndIf   
	
	cCodLote 	:= RTrim(MV_PAR01)
	lImpressao 	:= Str(MV_PAR02,1) == "2"
	lImprim  	:= If(MV_PAR03==1,.T.,.F.)
	nTipPes  	:= MV_PAR05   // 1=todas   2=fisica   3=juridica
EndIf   

BEGIN TRANSACTION    

If cCodLote <> "AVULSA"

	BDE->(DbSetOrder(1))
	If !BDE->(MsSeek(xFilial("BDE")+cOperad+cCodLote))
		MsgStop(STR0033) //"Lote não encontrado!"
		lReturn := .T.
	EndIf

Else
    
	lNew := .T.

	BED->(DbSetOrder(4))
	BED->(MsSeek(xFilial("BED")+PadR(cCodLote,12)))

	While !BED->(Eof()) .and. PadR(cCodLote,12) == BED->BED_CDIDEN
        BA3->(DbSetOrder(1))
	    BA3->(msSeek(xFilial("BA3")+BED->BED_CODINT+BED->BED_CODEMP+BED->BED_MATRIC))
	    lErro := .F.
		If nTipPes > 1
		   If nTipPes == 2 // somente pessoa fisica
		      If BA3->BA3_TIPOUS == "2"  // SE CONTRATO FOR DE PESSOA JURIDICA PULA
		         lErro := .T.
		      EndIf
		   ElseIf nTipPes == 3  // somente pessoa juridica
		      If BA3->BA3_TIPOUS == "1"  // SE CONTRATO FOR DE PESSOA FISICA PULA
		         lErro := .T.
		      EndIf
		   EndIf
		EndIf
		If !lErro
   		   aadd(aRecno,BED->(Recno()))
   		EndIf   
		BED->(DbSkip())
	EndDo

	if len(aRecno) == 0
		MsgInfo("Não foram encontrados lançamentos avulsos pendentes para realizar o processamento.")
		lReturn := .T.
	else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava lote													³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodLote := PLSA262NUM(cOperad)
		
		BDE->(DbSetOrder(1))
		
		BDE->(RecLock("BDE",.T.))
			BDE->BDE_FILIAL := xFilial("BDE")
			BDE->BDE_CODINT := cOperad
			BDE->BDE_CODIGO := cCodLote
			BDE->BDE_UNILOC := "1"
			BDE->BDE_TIPGRU := "3"
			BDE->BDE_STACAR := "1"
			BDE->BDE_TIPGER := Str(MV_PAR02,1)
		BDE->(MsUnlock())
		
		For nI := 1 to Len(aRecno)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona BED...											³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BED->(DbGoto(aRecno[nI]))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Alimenta variaveis...										³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodInt := BED->BED_CODINT
			cCodEmp := BED->BED_CODEMP
			cMatric := BED->BED_MATRIC
			cTipReg := BED->BED_TIPREG
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Compoe o Lote somente se for a Ultima Via do Usuario...		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nUltVia := PL261UVC(cCodInt, cCodEmp, cMatric, cTipReg, 1)[1]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Validacao													³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If BED->BED_VIACAR = nUltVia
				lAgrupa := .T.
			Else
				lAgrupa := .F.
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a Via esta bloqueada...                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If BED->( FieldPos("BED_CODBLO") ) = 0 .AND. BED->( FieldPos("BED_BLOIDE") ) = 0 
				MsgStop(STR0030) //"Dicionario de dados desatualizado!!!"
				lAgrupa := .F.
			Else
				If BED->BED_BLOIDE == "1"
					MsgStop(STR0034 + cQuebra + STR0026 + BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG)) //"Via do cartão não será emitida pois se encontra bloqueada!"###"Usuário: "
					lAgrupa := .F.
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Checa e cria o registro									    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lAgrupa
				BED->(RecLock("BED",.F.))
				BED->BED_CDIDEN := cCodLote
				BED->(MsUnlock())
			Endif
		Next
	endIf
EndIf   

If !lReturn
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona na Operadora...                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRet := {.F.,{0}}
	
	BA0->(DbSetOrder(1))
	
	If BA0->(MsSeek(xFilial("BA0")+BDE->BDE_CODINT))
	
		If Empty(BA0->BA0_EXPIDE)
			cExpRdm := AllTrim(GetMV("MV_PLSEXPI"))
		Else
			cExpRdm := AllTrim(BA0->BA0_EXPIDE)
		Endif
		
		If ExistBlock(cExpRdm)
			aRet := ExecBlock(cExpRdm,.F.,.F.,{BDE->BDE_CODIGO,BDE->BDE_MOTIVO,BDE->BDE_CODINT,NIL,5,.t.,lImprim,NIL,lNew,NIL,.T.,lImpressao})
		Else
			aRet := Plsa264({BDE->BDE_CODIGO,BDE->BDE_MOTIVO,BDE->BDE_CODINT,NIL,5,.t.,lImprim,NIL,lNew,NIL,.T.,lImpressao})
		EndIf   
	
		If ValType(aRet) <> "A" .or. Len(aRet) == 0
			aRet := {.T.,{0},{},{}}
		Endif
	
	Endif

	If IsIncallStack("PLSA262PT")
		lReemissao := .T.
	EndIf
	
	If aRet[1]
		If lNew
			BDE->(RecLock("BDE",.F.))
			BDE->BDE_QTD := aRet[2,1]
			BDE->(MsUnlock())
			MsgStop(STR0035 + cCodLote) //"Gerado lote "
		Endif
	Elseif !lReemissao	
		BDE->(RecLock("BDE",.F.))
		BDE->(DbDelete())
		BDE->(MsUnlock())
	EndIf
Else
	aRet := {.F.,{0}}
EndIf

END TRANSACTION    

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA262LEG ³ Autor ³ Wagner Mobile Costa ³ Data ³ 28.08.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe a legenda...                                         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA262Leg()

Local lUsBlV   :=GetNewPar("MV_PLBLQVE",.F.)
Local aLegenda := { 	{ aCdCores[1,1],aCdCores[1,2] },;
                     { aCdCores[2,1],aCdCores[2,2] }}
                                         
If lUsBlV                    
    AADD(aLegenda, { aCdCores[3,1],aCdCores[3,2] })
    AADD(aLegenda, { aCdCores[4,1],aCdCores[4,2] })
EndIf
                     
BrwLegenda(cCadastro,STR0036 ,aLegenda) //"Status"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetDtVld  ºAutor  ³Thiago Machado Correaº Data ³  17/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna data de validade                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetDtVld(dDatBas)

LOCAL cAno 	  := ""
LOCAL cDia 	  := ""
LOCAL cMes 	  := ""
LOCAL nCnt    := 0
LOCAL nMeses  := 0
LOCAL dRet    := StoD("")

cAno := Substr(dtoS(dDatBas),1,4)
cMes := Substr(dtoS(dDatBas),5,2)
cDia := Substr(dtoS(dDatBas),7,2)

//Posiciona BA3 e BQC
BA3->(DbSetOrder(1))
BQC->(DbSetOrder(1))

BA3->(DbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
BQC->(DbSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))

//Alimenta Periodo de Renovacao
If BA3->BA3_TIPOUS == "2"
	nMeses := BQC->BQC_NPERRN
Else
	nMeses := GetMV("MV_PLSPRPF")
Endif

//Calcula data de validade
cMes := Val(cMes)
For nCnt := 1 To nMeses
	cMes += 1
	If cMes > 12
		cMes := 1
		cAno := StrZero((Year(dDataBase)+1),4)
	Endif
Next
cMes := StrZero(cMes,2)

//Alimenta campo
dRet := cTod(cDia+"/"+cMes+"/"+cAno)

If ExistBlock("PLS262DT") 
	dRet := ExecBlock("PLS262DT",.F.,.F.,{dRet})
Endif

Return dRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA262RPTºAutor  ³Geraldo Felix Juniorº Data ³  16/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime relatorio de conferencia...                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA262RPT()
// Chama relatorio com parametros ja estabelecidos...
PLSR038(	BDE->BDE_CODINT,;
			BDE->BDE_DATA1,;
			BDE->BDE_DATA2,;
			BDE->BDE_EMPDE,;
			BDE->BDE_EMPATE,;
			BDE->BDE_CONDE,;
			BDE->BDE_CONATE,;
			BDE->BDE_SUBDE,;
			BDE->BDE_SUBATE,;
			BDE->BDE_MATDE,;
			BDE->BDE_MATATE,;
			BDE->BDE_CODIGO,;
			1,;
			1)
		
Return()	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MntAcols  ºAutor  ³Otacilio A. Junior  º Data ³ 28/03/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta aCols para ser utilizado na Getdados                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MntAcols(cAlias,nOpc,aHeader,aCols,aVetTrab)

Local nCntFor,nX
Local aStruBED := BED->(DbStruct())


If Len( aHeader ) == 0
	Store HEADER "BED" TO aHeader For .T.
Endif	

If nOpc == K_Incluir
	Store COLS Blank "BED" TO aCols FROM aHeader
Else
	
	cQuery := ""
	    
    lQuery := .T.

    cAliasBED := "QRYBED"
    
    cQuery := "SELECT BED.* "
    cQuery += " FROM "
    cQuery += RetSqlName("BED")+ " BED "
    cQuery += " WHERE "
    cQuery += "BED_FILIAL = '"+xFilial("BED")+"' AND "
    cQuery += "BED_CDIDEN = '"+BDE->BDE_CODIGO+"' AND "
    cQuery += "BED.D_E_L_E_T_ = ' ' "
    
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasBED,.F.,.T.)

	For nCntFor := 1 To Len(aStruBED)
		If ( aStruBED[nCntFor,2]<>"C" )
			TcSetField(cAliasBED,aStruBED[nCntFor,1],aStruBED[nCntFor,2],aStruBED[nCntFor,3],aStruBED[nCntFor,4])
		EndIf
	Next nCntFor

	While !Eof()
	
		Aadd(aCols,Array(Len(aHeader)+1))

		BED->(MsGoto((cAliasBED)->R_E_C_N_O_))
	
		For nX := 1 To Len(aHeader)
			If ( aHeader[nX,10] !=  "V" )
				aCols[Len(aCols)][nX] := (cAliasBED)->(FieldGet(FieldPos(aHeader[nX,2])))
			Else
				aCols[Len(aCols)][nX] := CriaVar(aHeader[nX,2],.T.)
			EndIf
		Next nX
		aCols[Len(aCols)][Len(aHeader)+1] := .F.
		
		Aadd(aVetTrab, (cAliasBED)->R_E_C_N_O_ )				
		
		dbSelectArea(cAliasBED)
		dbSkip()				
	EndDo

	If Empty(aCols)
		BED->(MsGoto(0))
		Store COLS Blank "BED" TO aCols FROM aHeader
	EndIf

	(cAliasBED)->(dbCloseArea())
	dbSelectArea("BED")	
EndIf
Return(aCols)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³02/01/2007³±±
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
Private aRotina := {	{ STR0001	,'AxPesqui'  , 0 , K_Pesquisar  , 0, .F.},; //"Pesquisar"
											{ STR0002	,'PLSA262VIS', 0 , K_Visualizar , 0, Nil},; //"Visualizar"
											{ STR0003	,'PLSA262EXP', 0 , K_Incluir    , 0, Nil},; //"E&xportar"
											{ STR0004	,'PLSA262EXC', 0 , K_DefExc     , 0, Nil},; //"&Excluir"
											{ STR0005	,'PLSA262ENC', 0 , K_Visualizar , 0, Nil},; //"E&ncerrar Lote"
											{ STR0006	,'PLSA262PT' , 0 , K_Incluir    , 0, Nil},; //"Reemitir"
											{ STR0007	,'PLSA262RPT', 0 , K_Incluir    , 0, Nil},; //"Rel.Con&f."
											{ STR0008	,"PLSA262LEG", 0 , K_Incluir    , 0, .F.} } //"Legenda"
Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ TOTVS                 ³ Data ³07/02/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta Status das vias Bloqueadas em Lotes anteriores      ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLAJCABDE(aLoBDE,cTpBlo) 
   
LOCAL    nJ        := 0
Local    lRet      := .F.
Default aLoBDE     := {}
Default cTpBlo     := "1"

For nj:= 1  to Len(aLoBDE)
 
	If BDE->(MsSeek(xFilial("BDE")+aLoBDE[nJ,2]+aLoBDE[nJ,3]))    
	
		lRet:= PLBLOPA(aLoBDE[nJ,2], aLoBDE[nJ,3],cTpBlo)
    
		BDE->(RecLock("BDE",.F.))
		If cTpBlo == "1" .And. !lRet
			BDE->BDE_STAANB := BDE->BDE_STACAR			
			BDE->BDE_STACAR := "3"	                    			
		ElseIf cTpBlo == "1" .And. lRet                   
			BDE->BDE_STAANB := BDE->BDE_STACAR			
			BDE->BDE_STACAR := "4"		                		
		ElseIf cTpBlo == "0" .And. lRet  
			If !Empty(BDE->BDE_STAANB)
				BDE->BDE_STAANB := BDE->BDE_STACAR
				BDE->BDE_STACAR := "4"		                    				
			Else	
				BDE->BDE_STACAR := "4"		                    				
				BDE->BDE_STAANB := ""	
            EndIf
		ElseIf cTpBlo == "0" .And. !lRet                   
			If !Empty(BDE->BDE_STAANB) 
				BDE->BDE_STACAR := BDE->BDE_STAANB		 							
				BDE->BDE_STAANB := "3"
			Else
				BDE->BDE_STAANB := "3"
				BDE->BDE_STACAR := "2"		 							
			EndIf	
		EndIf
		BDE->(MsUnlock())
	EndIf
Next nJ	
        
                                     
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ TOTVS                 ³ Data ³07/02/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta Status do Cabecalho do lote quando necessario       ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLBLOPA(cChkCIt,cChkCBl,cTipBlo) 

Local cSQLBLO     := ""
Local lRet        := .F.
Default cChkCIt   := ""
Default cChkCBl   := ""
Default cTipBlo   := ""

cSQLBLO := "SELECT COUNT(*) AS QTDEBLO"
cSQLBLO += " FROM " + RetSqlName("BED")
cSQLBLO += " WHERE BED_FILIAL = '" + xFilial("BED")  + "' "
cSQLBLO += "   AND BED_CODINT = '" +    cChkCIt      + "' "
	   
If cTipBlo == "1"                             //Caso seja um bloqueio, verifico se ha vias desbloqueadas para marcar o lote como bloqueado ou parcialmente bloq.
	cSQLBLO += "   AND BED_BLOIDE = '0' AND BED_CDIDEN = '" +    cChkCBl      + "' "
Else
	If AllTrim(FunName()) == "PLSA261"
		cSQLBLO += "   AND BED_BLOIDE = '1' AND BED_CDIDEN = '" +    cChkCBl      + "' "
	Else
		cSQLBLO += "   AND BED_BLOIDE = '1' AND BED_CTRBLO = '" +    cChkCBl      + "' "
	EndIf	
EndIf

cSQLBLO += " AND D_E_L_E_T_ = ' '"
	
cSQLBLO := ChangeQuery(cSQLBLO)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQLBLO),"BEDVBLO",.F.,.T.)

BEDVBLO->(DbGoTop()) 		
	   
If !BEDVBLO->( Eof() ) 

	If BEDVBLO->QTDEBLO >= 1 
		lRet:= .T.
	EndIf	

EndIf		
	
BEDVBLO->(DbCloseArea())
	

Return (lRet)	
	
Function Pl262DtBlo()
Return (Empty(BA1->BA1_DATBLO).OR.BA1->BA1_DATBLO>dDataBase)

/*/{Protheus.doc} RetBA3Val
Retorna BA3_VALID
@author Roberto Barbosa
@since 06/2019
/*/
Function RetBA3Val()
Local aAreaBA3	:= GetArea()

	BA3->(DbSetOrder(1))
	BA3->(msSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))

RestArea(aAreaBA3)

Return BA3->BA3_VALID