#INCLUDE "plsm040.ch"
#include "TcBrowse.ch"
#include "MSObject.ch"
#include "plsmger.ch"
#include "colors.ch"

CLASS TPLSBESP

      DATA oBrowse
      DATA nQtdLin
      DATA aCpoObri
      DATA aCols
      DATA aHeader
      DATA cTitBrw
      DATA aSemaf    
      DATA cFunIni
      DATA cAlias      
      DATA nOpc
      DATA cTitulo
           
      METHOD New(nRow,nCol,nWidth,nHeigth,bLine,oWnd,bChange,bLDblClick,bRClick,oFont,cMsg,lUpdate,bWhen,lDesign,bValid,aHeader,aCols,lSemafaro,cAlias,nOpc,cTitulo,aExpSem,cFunIni,lMark,cFunMark) CONSTRUCTOR
      METHOD EditRecord(cAlias,nOpc,cTitulo,nLinha,aCols,aHeader) CONSTRUCTOR
      METHOD AddLine() CONSTRUCTOR
      METHOD Linha() CONSTRUCTOR
      METHOD Atualiza() CONSTRUCTOR
      METHOD ColDel() CONSTRUCTOR
      METHOD DelLinha() CONSTRUCTOR
      METHOD NotDel() CONSTRUCTOR
      METHOD RetCol(cColuna) CONSTRUCTOR
      METHOD PLBLOCK(aCols,aHeader,nLinha,aExpSem) CONSTRUCTOR
      METHOD LinhaOK() CONSTRUCTOR
      METHOD TudoOK() CONSTRUCTOR
      METHOD SEMOK() CONSTRUCTOR
      METHOD Coluna(cNameCol) CONSTRUCTOR
      METHOD AddBlank() CONSTRUCTOR
      METHOD PLRETPOS(cCampo) CONSTRUCTOR
      METHOD FieldGet(cCampo,nLine)								CONSTRUCTOR

ENDCLASS

METHOD New(nRow,nCol,nWidth,nHeigth,bLine,oWnd,bChange,bLDblClick,bRClick,oFont,cMsg,lUpdate,bWhen,lDesign,bValid,aHeader,aCols,lSemafaro,cAlias,nOpc,cTitulo,aExpSem,cFunIni,lMark,cFunMark) CLASS TPLSBESP
LOCAL cExp
LOCAL nInd
LOCAL nTamanho
LOCAL cType
LOCAL nSize
LOCAL cTitle
LOCAL cPict
LOCAL oColCor            

LOCAL nCont
PUBLIC n := 1

If Type("aCols") <> "A"
   PUBLIC aCols := aClone(aCols)
Endif   

If Type("aHeader")<> "A"
   PUBLIC aHeader := aClone(aHeader)
Endif   

DEFAULT cTitulo    := ""
DEFAULT cAlias     := Alias()
DEFAULT lSemafaro  := .F.
DEFAULT bLine      := nil
DEFAULT bChange    := nil
DEFAULT bRClick    := nil
DEFAULT oFont      := AdvFont
DEFAULT cMsg       := nil
DEFAULT bWhen      := nil
DEFAULT bValid     := nil
DEFAULT lMark      := .F.

If ! lMark
   DEFAULT bLDblClick := { || ::EditRecord(cAlias, If( ::oBrowse:nAt>::nQtdLin .And. nOpc <> K_Incluir,K_Incluir,nOpc) ,cTitulo,::oBrowse:nAt,::aCols,::aHeader) }
Else
   DEFAULT bLDblClick := { ||  ::aCols[::Linha(),::ColDel()] := !(::aCols[::Linha(),::ColDel()]),  IF(ValType(cFunMark)=="C",&cFunMark,nil)   }
Endif

DEFAULT cFunIni    := "AllWaysTrue()"

::aCols   := aClone(aCols)
::aHeader := aClone(aHeader)
::cAlias  := cAlias
::nOpc    := nOpc
::cTitulo := cTitulo

If Len(::aCols) == 0 .Or. Len(::aHeader) == 0
   Help(" ",1,"MLIBDADOS")
   Return
Endif

If ValType(::aCols[1,Len(::aHeader)+1]) <> "L"
   Help(" ",1,"MLIBDADDL")
   Return
Endif   

If lSemafaro .And. Len(aExpSem) == 0
   Help(" ",1,"MLIBSEMAF")
   Return
Endif   

::aCpoObri := {}
SX3->(DbSetOrder(2))
For nInd := 1 To Len(::aHeader)
    If SX3->(MsSeek(AllTrim(::aHeader[nInd,2]))) 
       If SX3->X3_CONTEXT <> "V" 
          If (OemToAnsi(SX3->X3_RESERV) = OemToAnsi(Chr(129)+Chr(128)) .And. OemToAnsi(SX3->X3_USADO) = OemToAnsi(Replicate(Chr(128),6)+Chr(134))) .Or. OemToAnsi(SX3->X3_OBRIGAT) = OemToAnsi(Chr(128))
             aadd(::aCpoObri,AllTrim(::aHeader[nInd,2]))
          Endif
       Endif   
    Endif      
Next    

::cFunIni := cFunIni

::oBrowse := MsBrGetDbase():New(nRow,nCol,nWidth,nHeigth,bLine,nil,nil,oWnd,nil,nil,nil,bChange,bLDblClick, bRClick, oFont,nil,nil,nil,cMsg,lUpdate,nil,.T.,bWhen,lDesign,bValid)

::oBrowse:SetArray(::aCols)

::nQtdLin := If(nOpc==K_Incluir,0,Len(::aCols))

::cTitBrw := cTitulo
::aSemaf  := aExpSem                   

If ! lMark
   If nOpc == K_Incluir .Or. nOpc == K_Alterar
      ::oBrowse:bAdd := { || If(::LinhaOK(),::AddLine(),.F.) }
   Endif   
Endif   

If     lSemafaro
       ADD COLUMN TO ::oBrowse BITMAP DATA IF(::PLBlock(::aCols,::aHeader,::Linha(),aExpSem),LoadBitmap( GetResources(), "DISABLE" ),LoadBitmap( GetResources(), "ENABLE" )) TITLE "" WIDTH 015 NOHILITE
       ::oBrowse:BSUPERDEL := { || .T. }
       ::oBrowse:BDELOK    := { || .T. }
ElseIf lMark
       ADD COLUMN TO ::oBrowse BITMAP DATA IF(::aCols[::Linha(),Len(::aHeader)+1],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) TITLE "" WIDTH 015 NOHILITE
       ::oBrowse:BSUPERDEL := { || .T. }
       ::oBrowse:BDELOK    := { || .T. }
Else
       ::oBrowse:bDelete   := { || ::aCols[::Linha(),Len(::aHeader)+1] := !::aCols[::Linha(),Len(::aHeader)+1], ::Atualiza() }
       ADD COLUMN TO ::oBrowse BITMAP DATA IF(::aCols[::Linha(),Len(::aHeader)+1],LoadBitmap( GetResources(), "DISABLE" ),LoadBitmap( GetResources(), "ENABLE" )) TITLE "" WIDTH 015 NOHILITE
       ::oBrowse:BSUPERDEL := { || .T. }
       ::oBrowse:BDELOK    := { || .T. }
Endif

For nInd := 1 To Len(::aHeader)
    cTitle   := ::aHeader[nInd,01]
    cPict    := AllTrim(::aHeader[nInd,3])
    cType    := ValType(::aCols[1,nInd])
    If     cType == "D"
           nSize    := 035
    ElseIf cType == "N"
           nSize    := 035
    ElseiF cType == "C"     
           nSize    := Len(::aCols[1,nInd])*3.5
           If nSize < 030
              nSize := 030
           Endif   
    Endif   
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Monta colunas...                                                    ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If     nInd == 1
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 1 TITLE cTitle SIZE nSize PICTURE cPict
    ElseIf nInd == 2
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 2 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 3
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 3 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 4
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 4 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 5
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 5 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 6
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 6 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 7
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 7 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 8
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 8 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 9
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 9 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 10
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 10 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 11
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 11 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 12
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 12 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 13
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 13 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 14
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 14 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 15
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 15 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 16 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 16 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 17 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 17 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 18 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 18 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 19 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 19 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 20 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 20 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 21 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 21 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 22 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 22 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 23 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 23 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 24 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 24 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 25 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 25 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 26 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 26 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 27 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 27 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 28 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 28 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 29 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 29 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 30 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 30 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 31 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 31 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 32 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 32 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 33 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 33 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 34 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 34 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 35 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 35 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 36 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 36 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 37 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 37 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 38 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 38 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 39 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 39 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 40
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 40 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 41
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 41 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 42
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 42 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 43
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 43 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 44
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 44 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 45
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 45 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 46
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 46 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 47
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 47 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 48
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 48 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 49
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 49 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 50
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 50 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 51
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 51 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 52
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 52 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 53
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 53 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 54
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 54 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 55
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 55 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 56
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 56 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 57
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 57 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 58
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 58 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 59 
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 59 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 60
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 60 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 61
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 61 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 62
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 62 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 63                                  
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 63 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 64
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 64 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 65
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 65 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 66
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 66 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 67
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 67 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 68
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 68 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 69
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 69 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 70
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 70 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 71
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 71 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 72
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 72 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 73                                  
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 73 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 74
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 74 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 75
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 75 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 76
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 76 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 77
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 77 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 78
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 78 TITLE cTitle SIZE nSize PICTURE cPict    
    ElseIf nInd == 79
           ADD COLUMN TO ::oBrowse DATA ARRAY ELEMENT 79 TITLE cTitle SIZE nSize PICTURE cPict    
    Else
           //MsgStop("Passou colunas. PLSBESP")
           nInd := Len(::aHeader)+1
    Endif    
Next                                                         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata campos virtuais...                            .               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF "BF5" $ cFOPENED
   PlInitCols(::aCols,::aHeader,nil,nOpc)
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apos montar todas as linhas posiciono da 1a. linha...               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
::oBrowse:nAt := 1
::oBrowse:Refresh()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do Metodo New...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return Self
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ EditRecord ³ Autor ³ Tulio Cesar         ³ Data ³ 05.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Method de TPLSBESP                                          ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
METHOD EditRecord(cAlias,nOpc,cTitulo,nLinha,aCols,aHeader) CLASS TPLSBESP
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ LOCAL...                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL lReturn := .F.
LOCAL aOldArea := GetArea()
LOCAL nInd     := 0 
LOCAL nOpca
LOCAL nOpcao   := nOpc
LOCAL nPosicao
LOCAL cCampo
LOCAL lFlag
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PRIVATE...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oEncPLS
PRIVATE aGets[0]
PRIVATE aTela[0][0]
PRIVATE oDlg        
PRIVATE aRotina 	:= { {	STR0001 , '' , 0 ,K_Pesquisar  },; //"Pesquisar"
                        { 	STR0002, '' , 0 ,K_Visualizar },; //"Visualizar"
         				{ 	STR0003 	, '' , 0 ,K_Incluir    },; //"Incluir"
						{ 	STR0004	, '' , 0 ,K_Alterar    },; //"Alterar"
						{ 	STR0005	, '' , 0 ,K_Excluir    }} //"Excluir"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Titulo da Enchoice...                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo += " - "+aRotina[nOpc,1]
lRefresh := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cTitulo FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona area browseada....                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera dados para a memoria...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := {}

For nInd := 1 To Len(aHeader)
    aadd(aCampos,AllTrim(aHeader[nInd,2]))
    M->&(aHeader[nInd,2]) := If(nOpc==2 .And. Empty(aCols[nLinha,nInd]),CriaVar(aHeader[nInd,2]),aCols[nLinha,nInd])
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se existir um campo do usuario que nao esteja no aHeader vou cria-lo³
//³ Teoricamente isto nao vai acontecer mais caso aconteca trato p/ nao ³
//³ ocasionar erro de execucao da variavel M->???? nao existe.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX3->(DbSetOrder(1))
If SX3->(MsSeek(cAlias))
   While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias
         If ::PLRETPOS(AllTrim(SX3->X3_CAMPO),.F.) == 0
            If SX3->X3_PROPRI == "U"
               M->&(SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
            Endif   
         Endif   
   SX3->(DbSkip())
   Enddo
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice...                                                   ³
//³ Caso todos os campos obrigatorios nao esteja preenchido exibo o     ³
//³ msmget como inclusao                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//
If nOpcao <> K_Visualizar
   lFlag := .F.
   For nInd := 1 To Len(::aCpoObri)
       cCampo   := AllTrim(::aCpoObri[nInd])
       nPosicao := ::PLRETPOS(cCampo)
       If ! Empty(aCols[::Linha(),nPosicao])
          lFlag := .T.
      Endif
   Next   

   If ! lFlag
      nOpcao := K_Incluir    
   Endif
Endif   

nOld := nOpcao
If nOpcao == K_Visualizar
   nOpcao := K_Alterar  
Endif
//correcao de nao conformidade na hora da visualizacao nOpc. Tulio 
oEncPLS := MSMGet():New(cAlias,Recno(),nOpcao,,,,aCampos,{014,001,197,355},aCampos,,,,,oDlg,,,.F.)

nOpcao := nOld
//fim correcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Remonta dados para os campos virtuais...                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nInd := 1 To Len(aHeader)
    If aHeader[nInd,10] == "V"
       M->&(aHeader[nInd,2]) := If(nOpc==2 .And. Empty(aCols[nLinha,nInd]),CriaVar(aHeader[nInd,2]),aCols[nLinha,nInd])
    Endif   
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,{|| nOpca := 1,If(Obrigatorio(aGets,aTela),oDlg:End(),(nOpca:=3,.F.))},{|| nOpca := 3,oDlg:End()})
If 	nOpca == K_OK
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Atualiza dados no TPLSBESP quando for inclusao ou alteracao...       ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If nOpcao == K_Incluir .Or. nOpcao == K_Alterar
       For nInd := 1 To Len(aHeader)
           aCols[nLinha,nInd] := M->&(aHeader[nInd,2])
       Next
       ::aCols   := aCols
    Endif   
    lReturn := .T.
Endif    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura area antiga...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aOldArea)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do metodo editrecord...                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lReturn)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ AddLine    ³ Autor ³ Tulio Cesar         ³ Data ³ 05.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Method de TPLSBESP                                          ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
METHOD AddLine() CLASS TPLSBESP
LOCAL nInd
LOCAL nLinhas := Len(::aCols)
LOCAL n       := nLinhas+1   
LOCAL lFlag   := .T.                 
LOCAL cFuncao := ::cFunIni
LOCAL lOK

If ::Linha() < nLinhas
   Return(.F.)
Endif   
  
If ! ::TudoOK()
   Return(.F.)
Endif   

aadd(::aCols,{})

For nInd :=  1 To Len(::aHeader)+1
    aadd(::aCols[n],nInd)
    If nInd <= Len(::aHeader)
       ::aCols[n,nInd] := CriaVar(::aHeader[nInd,2])
    Else
       ::aCols[n,nInd] := .F.
    Endif   
Next                  

&cFuncao

::Atualiza()
::oBrowse:GoBottom()

lOK := ::EditRecord(::cAlias, If( ::oBrowse:nAt>::nQtdLin .And. ::nOpc <> K_Incluir,K_Incluir,::nOpc) ,::cTitulo,::oBrowse:nAt,::aCols,::aHeader)

If ! lOK
   nInd := Len(::aCols)-1
   aSize(::aCols,nInd)
   ::Atualiza()
   ::oBrowse:GoBottom()
Endif

Return(lFlag)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ Linha      ³ Autor ³ Tulio Cesar         ³ Data ³ 05.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Metodo de TPLSBESP                                          ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
METHOD Linha() CLASS TPLSBESP
Return(::oBrowse:nAt)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ Atualiza   ³ Autor ³ Tulio Cesar         ³ Data ³ 05.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Metodo de TPLSBESP                                          ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
METHOD Atualiza() CLASS TPLSBESP
::oBrowse:SetArray(::aCols)
::oBrowse:Refresh()
::oBrowse:SetFocus()
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ ColDel     ³ Autor ³ Tulio Cesar         ³ Data ³ 05.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Metodo de TPLSBESP                                          ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
METHOD ColDel() CLASS TPLSBESP
Return(Len(::aHeader)+1)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ DelLinha   ³ Autor ³ Tulio Cesar         ³ Data ³ 05.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Metodo de TPLSBESP                                          ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
METHOD DelLinha() CLASS TPLSBESP

::aCols[::oBrowse:nAt,Len(::aHeader)+1] := .T.
::Atualiza()

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ NotDel     ³ Autor ³ Tulio Cesar         ³ Data ³ 05.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Metodo de TPLSBESP                                          ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
METHOD NotDel() CLASS TPLSBESP

lFlag := !::aCols[::oBrowse:nAt,Len(::aHeader)+1]

Return(lFlag)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ RetCol     ³ Autor ³ Tulio Cesar         ³ Data ³ 05.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Metodo de TPLSBESP                                          ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
METHOD RetCol(cColuna) CLASS TPLSBESP
LOCAL nColuna := ::PLRETPOS(cColuna)
Return(nColuna)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLBLOCK    ³ Autor ³ Tulio Cesar         ³ Data ³ 05.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Metodo de TPLSBESP                                          ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
METHOD PLBlock(aCols,aHeader,nLinha,aExpSem) CLASS TPLSBESP
LOCAL cExp := ""                     
LOCAL nColuna
LOCAL lFlag
LOCAL bBlock   
LOCAL cValue  
LOCAL lConverte := .F.,nInd

For nInd := 1 To Len(aExpSem)
    nColuna := ::RetCol(::aHeader[::RetCol(aExpSem[nInd,1]),2])
    cExp    := cExp +  "aCols["+AllTrim(Str(nLinha))+","+AllTrim(Str(nColuna))+"] "+aExpSem[nInd,2]
    
    If len(aexpsem[nind]) <= 3
       cValue    := aExpSem[nInd,3]
       lConverte := .T.
    Else
       If aExpSem[nInd,4] <> "A" 
          cValue    := aExpSem[nInd,3]
          lConverte := .T.
       Else                                                      
          nColuna := ::RetCol(::aHeader[::RetCol(aExpSem[nInd,3]),2])
          cValue    := "aCols["+AllTrim(Str(nLinha))+","+AllTrim(Str(nColuna))+"] "
          lConverte := .F.
       Endif   
    Endif   
    
    If lConverte
       If     ValType(cValue) == "C"
          cExp += cValue
       ElseIf ValType(cValue) == "N"
          cExp += AllTrim(Str(cValue))
       ElseIf ValType(cValue) == "D"
          cExp += 'ctod("'+dtoc(cValue)+'")'
       Endif   
    Else
       cExp += cValue
    Endif   
    cExp    := cExp + " .And. "
Next                  

cExp := Subs(cExp,1,Len(cExp)-6)

bblock := &("{ || "+cExp+"}")

lFlag := !Eval(bBlock)

Return(lFlag)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ LinhaOK    ³ Autor ³ Tulio Cesar         ³ Data ³ 05.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Metodo de TPLSBESP                                          ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
METHOD LinhaOK() CLASS TPLSBESP
LOCAL nInd
LOCAL lFlag := .T.    

If ::aCols[::oBrowse:nAt,::ColDel()]
   Return(.T.)
Endif   

For nInd := 1 To Len(::aHeader)
    If Ascan(::aCpoObri,{|a| a $ AllTrim(::aHeader[nInd,2]) }) > 0
       If Empty(::aCols[::oBrowse:nAt,nInd])
          //Help("",,"GETOBG",,Upper(::aHeader[nInd,1]),1,14) 
          // nao vou mostrar campo a campo...
          lFlag := .F.
       Endif                                                
    Endif   
Next                

If ! lFlag
   Help(" ",1,"OBRIGAT")
Endif   

Return(lFlag)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ TudoOK     ³ Autor ³ Tulio Cesar         ³ Data ³ 05.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Metodo de TPLSBESP                                          ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
METHOD TudoOK() CLASS TPLSBESP
LOCAL nInd
LOCAL lFlag := .T.
LOCAL nCont

For nCont := 1 To Len(::aCols)
    
    If ! ::aCols[::oBrowse:nAt,::ColDel()]
       For nInd := 1 To Len(::aHeader)
           If Ascan(::aCpoObri,{|a| a $ AllTrim(::aHeader[nInd,2]) }) > 0
              If Empty(::aCols[nCont,nInd])
                 //Help("",,"GETOBG",,Upper(::aHeader[nInd,1]),1,14) 
                 // nao vou mostrar campo a campo...
                 lFlag := .F.
              Endif                                                
           Endif   
       Next                
    Endif 
      
Next    

If ! lFlag
   Help(" ",1,"OBRIGAT")
Endif   

Return(lFlag)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ SEMOK      ³ Autor ³ Tulio Cesar         ³ Data ³ 05.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Metodo de TPLSBESP                                          ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
METHOD SEMOK() CLASS TPLSBESP
LOCAL lReturn

lReturn := ::PLBlock(::aCols,::aHeader,::Linha(),::aSemaf)

Return(lReturn)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ Coluna     ³ Autor ³ Tulio Cesar         ³ Data ³ 05.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Metodo de TPLSBESP                                          ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
METHOD Coluna(cNameCol) CLASS TPLSBESP
LOCAL nCol

nCol := Ascan(::aHeader,{|a| AllTrim(a[2]) $ AllTrim(cNameCol)})
If nCol == 0
   MsgStop(STR0006+cCampo) //"Nao-conformidade Method Coluna(cNameCol) "
Endif   
Return(nCol)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ AddBlank   ³ Autor ³ Tulio Cesar         ³ Data ³ 03.11.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Adiciona uma nova linha em branco...                       ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
METHOD AddBlank() CLASS TPLSBESP
Local nInd

aadd(::aCols,{})

nUltLin := Len(::aCols)

For nInd :=  1 To Len(::aHeader)+1
    aadd(::aCols[nUltLin],nInd)
    If nInd <= Len(::aHeader)
       ::aCols[nUltLin,nInd] := CriaVar(::aHeader[nInd,2])
    Else
       ::aCols[nUltLin,nInd] := .F.
    Endif   
Next  

::Atualiza()                

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLRETPOS   ³ Autor ³ Tulio Cesar         ³ Data ³ 03.11.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Adiciona uma nova linha em branco...                       ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method PLRETPOS(cCampo,lHelp) CLASS TPLSBESP
LOCAL nCol
DEFAULT lHelp := .T.

nCol := Ascan(::aHeader,{|a| AllTrim(a[2]) $ AllTrim(cCampo)})
If nCol == 0
   If lHelp
      MsgStop(STR0007+cCampo) //"Nao-conformidade Method PLRETPOS de PLSBESP campo "
   Endif   
Endif   
Return(nCol)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ FieldGet   ³ Autor ³ Tulio Cesar         ³ Data ³ 08.07.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna o conteudo do campo na linha determinada           ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method FieldGet(cCampo,nLine) CLASS TPLSBESP
Local uValor
DEFAULT nLine := ::Linha()
uValor := ::aCols[nLine,::PlRetPos(cCampo,.F.,::aHeader)]
Return uValor

////////////
Function PLSTeste3()
Return


