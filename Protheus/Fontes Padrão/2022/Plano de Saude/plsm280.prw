/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������Ŀ���
���Classe    � PLSM280    �Autores� Tulio Cesar-Microsiga VITORIA  � Data � 16.07.01 ����
���          �            �       � Eduardo Motta-Microsiga MATRIZ �      �          ����
������������������������������������������������������������������������������������Ĵ���
���Descricao � Classe desenvolvida com o objetivo de se utilizar varias GETDADOS     ����
���          � no mesmo dialog, permanecendo a sintaxe e o modo de se utilizar       ����
���          � semelhante.                                                           ����
���          � **********************************************************************����
���          � ESTA CLASSE ESTA OBSOLETA, POREM NAO PODERA SER REMOVIA DO PROJETO.   ����
���          � Existem personalizacoes realizadas em clientes que dependem desta     ����
���          � classe. Foi verificado que eh inviavel migrar estas personalizacoes   ����
���          � para a nova classe, chamada TPLSBRW.                                  ����
�������������������������������������������������������������������������������������ٱ��
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������


um exemplo de uso desta classe podera ser encontrado no fonte PLSA030.PRW

*/

#include "TcBrowse.ch"
#include "MSObject.ch"
#include "plsmger.ch"
#include "colors.ch"

CLASS TPLSCLBRW
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
   DATA aVetTrab
   DATA lAddLine
   DATA blAddLine
   DATA cVldLIne
   DATA cVldDel
   DATA bGotFocus
   DATA bLostFocus
   DATA bConfEnc
   DATA bCancEnc
   DATA bAntEdt

   METHOD New(nRow,nCol,nWidth,nHeigth,bLine,oWnd,bChange,bLDblClick,bRClick,oFont,cMsg,lUpdate,bWhen,lDesign,bValid,aHeaderBrw,aColsBrw,lSemafaro,cAlias,nOpc,cTitulo,aExpSem,cFunIni,bAdd,aVetTrab,cVldLine,cVldDel,lDelLine) CONSTRUCTOR
   METHOD EditRecord(cAlias,nOpc,cTitulo,nLinha,aColsEd,aHeaderEd,lAdd) CONSTRUCTOR
   METHOD AddLine() CONSTRUCTOR
   METHOD Linha() CONSTRUCTOR
   METHOD Atualiza() CONSTRUCTOR
   METHOD ColDel() CONSTRUCTOR
   METHOD NotDel() CONSTRUCTOR
   METHOD RetCol(cColuna) CONSTRUCTOR
   METHOD PLBlock(aColsEd,aHeaderEd,nLinha,aExpSem) CONSTRUCTOR
   METHOD LinhaOK() CONSTRUCTOR
   METHOD TudoOK() CONSTRUCTOR
   METHOD SEMOK() CONSTRUCTOR
   METHOD Coluna(cNameCol) CONSTRUCTOR
   METHOD PLRETPOS(cCampo) CONSTRUCTOR
   METHOD Grava(aChave) CONSTRUCTOR
                   
ENDCLASS

METHOD New(nRow,nCol,nWidth,nHeigth,bLine,oWnd,bChange,bLDblClick,bRClick,oFont,cMsg,lUpdate,bWhen,lDesign,bValid,aHeaderBrw,aColsBrw,lSemafaro,cAlias,nOpc,cTitulo,aExpSem,cFunIni,bAdd,aVetTrab,cVldLine,cVldDel,lDelLine) CLASS TPLSCLBRW
LOCAL cExp
LOCAL nInd
LOCAL nTamanho
LOCAL cType
LOCAL nSize
LOCAL cTitle
LOCAL cPict
LOCAL oColCor
Local oBrowse
Local aColsSave := {}
Local aHeadSave := {}
Local nOpcGD    := nOpc
PRIVATE aRotina :=      { { "",'AxPesqui' , 0 ,K_Pesquisar },; // Pesquisar
                           { "",'AxPesqui' , 0 ,K_Visualizar},;
       			    	   { "",'AxInclui' , 0 ,K_Incluir   },;
            			   { "",'AxAltera' , 0 ,K_Alterar   },;
                           { "",'AxDeleta' , 0 ,K_Excluir   }}

If Type("N") # "N"
   PUBLIC  n := 1
EndIf   

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
DEFAULT aExpSem    := {}
DEFAULT cVldLine   := "AllWaysTrue()"
DEFAULT cVldDel    := "AllWaysTrue()"

If !("(" $ cVldLine)
   cVldLine := AllTrim(cVldLine)+"()"
EndIf
cVldLine := AllTrim(cVldLine)   
If !("(" $ cVldDel)
   cVldDel := AllTrim(cVldDel)+"()"
EndIf
cVldDel := AllTrim(cVldDel)

aHeader   := aClone(aHeaderBrw)
aCols     := aClone(aColsBrw)
n       := 1

DEFAULT bLDblClick   := { || ::EditRecord(cAlias, If( ::oBrowse:oBrowse:nAt>::nQtdLin .And. nOpc <> K_Incluir,K_Incluir,nOpc) ,cTitulo,::oBrowse:oBrowse:nAt,aCols,aHeader)}

DEFAULT cFunIni       := "AllWaysTrue()"
DEFAULT ::blAddLine  := { || .T. }
DEFAULT lDelLine     := IF(nOpc==K_Excluir .Or. nOpc==K_Visualizar,.F.,.T.)

::aCols    := aClone(aCols)
::aHeader  := aClone(aHeader)
::aVetTrab := aClone(aVetTrab)
::cAlias   := cAlias
::nOpc     := nOpc
::cTitulo  := cTitulo
::cVldLine := cVldLine
::cVldDel  := cVldDel
::bGotFocus  := {||.T.}
::bLostFocus := {||.T.}

If nOpc == K_Incluir .or. nOpc == K_Alterar
   ::lAddLine := .T.
Else
   ::lAddLine := .F.
   ::cVldDel  := "!AllWaysTrue()"
EndIf            

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
    If SX3->(DbSeek(AllTrim(::aHeader[nInd,2]))) 
       If SX3->X3_CONTEXT <> "V" 
          If X3Obrigat(SX3->X3_CAMPO) 
             aadd(::aCpoObri,AllTrim(::aHeader[nInd,2]))
          Endif
       Endif   
    Endif      
Next    
DbSelectarea(cAlias)
::oBrowse := MsGetDados():New(nRow,nCol,nHeigth,nWidth,5     ,/*cLinOk*/,/*cTudoOk*/,"",lDelLine,,/*nFreeze*/,,/*nLinhas*/,/*cFieldOk*/,,,,oWnd)

::oBrowse:oBrowse:bGotFocus  := {||aHeader:=::aHeader,aCols:=::aCols,n:=::Linha(),Eval(::bGotFocus,::oBrowse:oBrowse)}
::oBrowse:oBrowse:bLostFocus := {||::aHeader:=aClone(aHeader),::aCols:=aClone(aCols),Eval(::bLostFocus)}
::oBrowse:oBrowse:bLDblClick := bLDblClick
::oBrowse:oBrowse:bAdd       := {||::AddLine()}
::oBrowse:oBrowse:Default()
::oBrowse:nMax               := Len(::aCols)+5

//::oBrowse:oBrowse:bDelete    := { || .T. }

oBrowse:=::oBrowse

::nQtdLin := If(nOpc==K_Incluir,0,Len(::aCols))

::cTitBrw := cTitulo
::aSemaf  := aExpSem                   

Return Self
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � EditRecord � Autor � Tulio Cesar/Eduardo � Data � 05.04.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Method de TPLSBRW                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
METHOD EditRecord(cAlias,nOpc,cTitulo,nLinha,aColsEd,aHeaderEd) CLASS TPLSCLBRW
//���������������������������������������������������������������������Ŀ
//� LOCAL...                                                            �
//�����������������������������������������������������������������������
LOCAL lReturn := .F.
LOCAL aOldArea := GetArea()
LOCAL nInd     := 0 
LOCAL nOpca
LOCAL nOpcao   := nOpc
LOCAL nPosicao
LOCAL cCampo
LOCAL lFlag
//���������������������������������������������������������������������Ŀ
//� PRIVATE...                                                          �
//�����������������������������������������������������������������������
PRIVATE oEncPLS
PRIVATE aGets[0]
PRIVATE aTela[0][0]
PRIVATE oDlg        
PRIVATE aRotina 	:= { {	STRPL01 , '' , 0 ,K_Pesquisar  },;
                        { STRPL02 , '' , 0 ,K_Visualizar },;
         				{ 	STRPL03 	, '' , 0 ,K_Incluir    },;
						{ 	STRPL04	, '' , 0 ,K_Alterar    },;
						{ 	STRPL05	, '' , 0 ,K_Excluir    }}
//���������������������������������������������������������������������Ŀ
//� Trata propriedade bConfEnca                                         �
//�����������������������������������������������������������������������
If ValType(::bAntEdt) == "B"
   Eval(::bAntEdt)
Endif   
//���������������������������������������������������������������������Ŀ
//� Monta Titulo da Enchoice...                                         �
//�����������������������������������������������������������������������
cTitulo += " - "+aRotina[nOpc,1]
lRefresh := .T.
//���������������������������������������������������������������������Ŀ
//� Define Dialogo...                                                   �
//�����������������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE cTitulo FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()
//���������������������������������������������������������������������Ŀ
//� Seleciona area browseada....                                        �
//�����������������������������������������������������������������������
DbSelectArea(cAlias)
//���������������������������������������������������������������������Ŀ
//� Gera dados para a memoria...                                        �
//�����������������������������������������������������������������������
aCampos := {}      

n := ::Linha()

For nInd := 1 To Len(aHeaderEd)
    aadd(aCampos,AllTrim(aHeaderEd[nInd,2]))
     M->&(aHeaderEd[nInd,2]) := If(nOpc==2 .And. Empty(aColsEd[nLinha,nInd]),CriaVar(aHeaderEd[nInd,2]),aColsEd[nLinha,nInd])
Next

//���������������������������������������������������������������������Ŀ
//� Se existir um campo do usuario que nao esteja no aHeader vou cria-lo�
//� Teoricamente isto nao vai acontecer mais caso aconteca trato p/ nao �
//� ocasionar erro de execucao da variavel M->???? nao existe.          �
//�����������������������������������������������������������������������
SX3->(DbSetOrder(1))
If SX3->(DbSeek(cAlias))
   While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias
         If ::PLRETPOS(AllTrim(SX3->X3_CAMPO),.F.) == 0
//            If SX3->X3_PROPRI == "U"
               M->&(SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
//            Endif   
         Endif   
   SX3->(DbSkip())
   Enddo
Endif   
//���������������������������������������������������������������������Ŀ
//� Monta Enchoice...                                                   �
//� Caso todos os campos obrigatorios nao esteja preenchido exibo o     �
//� msmget como inclusao                                                �
//�����������������������������������������������������������������������
//
If nOpcao <> K_Visualizar
   lFlag := .F.
   For nInd := 1 To Len(::aCpoObri)
       cCampo   := AllTrim(::aCpoObri[nInd])
       nPosicao := ::PLRETPOS(cCampo)
       If ! Empty(aColsEd[::Linha(),nPosicao])
          lFlag := .T.
      Endif
   Next   

   If ! lFlag
      nOpcao := K_Incluir    
   Endif
Endif   

oEncPLS := MSMGet():New(cAlias,Recno(),(if(nOpcao==K_Visualizar,K_Alterar,nOpcao)),,,,aCampos,{014,001,197,355},If(nOpcao==K_Visualizar,{},aCampos),,,,,oDlg,,,.F.)

//fim correcao

//���������������������������������������������������������������������Ŀ
//� Remonta dados para os campos virtuais...                            �
//�����������������������������������������������������������������������
For nInd := 1 To Len(aHeaderEd)
    If aHeaderEd[nInd,10] == "V"
       M->&(aHeaderEd[nInd,2]) := If(nOpc==2 .And. Empty(aColsEd[nLinha,nInd]),CriaVar(aHeaderEd[nInd,2]),aColsEd[nLinha,nInd])
    Endif   
Next
//���������������������������������������������������������������������Ŀ
//� Ativa o Dialogo...                                                  �
//�����������������������������������������������������������������������
ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,{|| nOpca := 1,If((Obrigatorio(aGets,aTela) .and. &(::cVldLine) ),oDlg:End(),(nOpca:=3,.F.))},{|| nOpca := 3,oDlg:End()})
If 	nOpca == K_OK
    //���������������������������������������������������������������������Ŀ
    //� Atualiza dados no TPLSBRW quando for inclusao ou alteracao...       �
    //�����������������������������������������������������������������������
    If nOpcao == K_Incluir .Or. nOpcao == K_Alterar
       For nInd := 1 To Len(aHeaderEd)
           aColsEd[nLinha,nInd] := M->&(aHeaderEd[nInd,2])
       Next
       ::aCols   := aColsEd
       ::oBrowse:nMax := Len(::aCols)+5
    Endif   
    lReturn := .T.
    //���������������������������������������������������������������������Ŀ
    //� Trata propriedade bConfEnca                                         �
    //�����������������������������������������������������������������������
    If ValType(::bConfEnc) == "B"
       Eval(::bConfEnc)
    Endif   
Else
    //���������������������������������������������������������������������Ŀ
    //� Trata propriedade bCancEnca                                         �
    //�����������������������������������������������������������������������
    If ValType(::bCancEnc) == "B"
       Eval(::bCancEnc)
    Endif   
Endif    
//���������������������������������������������������������������������Ŀ
//� Restaura area antiga...                                             �
//�����������������������������������������������������������������������
RestArea(aOldArea)
//���������������������������������������������������������������������Ŀ
//� Fim do metodo editrecord...                                         �
//�����������������������������������������������������������������������
Return(lReturn)
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � AddLine    � Autor � Tulio Cesar/Eduardo � Data � 05.04.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Method de TPLSBRW                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
METHOD AddLine() CLASS TPLSCLBRW
LOCAL nInd
LOCAL nLinhas := Len(aCols)
LOCAL lFlag   := .T.                 
LOCAL cFuncao := ::cFunIni
LOCAL lOK
LOCAL nI := 0
LOCAL aSvColAdd := {}
LOCAL aSvCols   := aClone(aCols)
Local nTotCol   := 0

If (!::lAddLine) .or. (::Linha() < nLinhas) .or. (!Eval(::blAddLine))
   Return(.F.)
Endif 
  
If ! ::TudoOK()
   Return(.F.)
Endif   

aadd(aCols,{})

For nInd :=  1 To Len(::aHeader)+1
    aadd(aCols[Len(aCols)],nInd)
    If nInd <= Len(::aHeader)
       aCols[Len(aCols),nInd] := CriaVar(::aHeader[nInd,2],.T.)
    Else
       aCols[Len(aCols),nInd] := .F.
    Endif   
Next                  

If ValType(cFuncao) <> "U"
   &cFuncao
Endif   

lOK := ::EditRecord(::cAlias, K_Incluir ,::cTitulo,Len(aCols),aCols,::aHeader)

If ! lOK
   nInd := Len(::aCols)-1
   aSize(::aCols,nInd)
Else
   aSvColAdd := {}
   nTotCol := Len(::aCols)
   For nI := 1 to Len(::aCols[nTotCol])
      aadd(aSvColAdd,::aCols[nTotCol,nI])
   Next
   aCols := aClone(aSvCols)
   ::oBrowse:AddLine()
   ::aCols := aCols
   For nI := 1 to Len(aCols[nTotcol])
      aCols[nTotCol,nI] := aSvColAdd[nI]
   Next
Endif

Return(lFlag)
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � Linha      � Autor � Tulio Cesar         � Data � 05.04.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Metodo de TPLSBRW                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
METHOD Linha() CLASS TPLSCLBRW
Return(::oBrowse:oBrowse:nAt)
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � Atualiza   � Autor � Tulio Cesar/Eduardo � Data � 05.04.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Metodo de TPLSBRW                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
METHOD Atualiza() CLASS TPLSCLBRW
::oBrowse:SetArray(::aCols)
//N := ::oBrowse:oBrowse:nAt
If ::oBrowse:oBrowse:nAt > Len(::aCols)
   ::oBrowse:oBrowse:nAt := 1
//   N := 1
EndIf
::oBrowse:Refresh()
::oBrowse:oBrowse:SetFocus()  // getdados

Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � ColDel     � Autor � Tulio Cesar         � Data � 05.04.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Metodo de TPLSBRW                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
METHOD ColDel() CLASS TPLSCLBRW
Return(Len(::aHeader)+1)

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � NotDel     � Autor � Tulio Cesar         � Data � 05.04.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Metodo de TPLSBRW                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
METHOD NotDel() CLASS TPLSCLBRW

lFlag := !::aCols[::oBrowse:oBrowse:nAt,Len(::aHeader)+1]

Return(lFlag)

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � RetCol     � Autor � Tulio Cesar         � Data � 05.04.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Metodo de TPLSBRW                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
METHOD RetCol(cColuna) CLASS TPLSCLBRW
LOCAL nColuna := ::PLRETPOS(cColuna)
Return(nColuna)

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLBLOCK    � Autor � Tulio Cesar         � Data � 05.04.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Metodo de TPLSBRW                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
METHOD PLBlock(aColsEd,aHeaderEd,nLinha,aExpSem) CLASS TPLSCLBRW
LOCAL cExp := ""                     
LOCAL nColuna
LOCAL lFlag
LOCAL bBlock   
LOCAL cValue  
LOCAL nInd

For nInd := 1 To Len(aExpSem)
    nColuna := ::RetCol(::aHeader[::RetCol(aExpSem[nInd,1]),2])
    cExp    := cExp +  "aCols["+AllTrim(Str(nLinha))+","+AllTrim(Str(nColuna))+"] "+aExpSem[nInd,2]
    cValue  := aExpSem[nInd,3]
    If     ValType(cValue) == "C"
       cExp += cValue
    ElseIf ValType(cValue) == "N"
       cExp += AllTrim(Str(cValue))
    ElseIf ValType(cValue) == "D"
       cExp += 'ctod("'+dtoc(cValue)+'")'
    Endif   
    cExp    := cExp + " .And. "
Next                  

cExp := Subs(cExp,1,Len(cExp)-6)

bblock := &("{ || "+cExp+"}")

lFlag := !Eval(bBlock)

Return(lFlag)

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � LinhaOK    � Autor � Tulio Cesar         � Data � 05.04.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Metodo de TPLSBRW                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
METHOD LinhaOK() CLASS TPLSCLBRW
LOCAL nInd
LOCAL lFlag := .T.    

If ::aCols[::oBrowse:oBrowse:nAt,::ColDel()]
   Return(.T.)
Endif   

For nInd := 1 To Len(::aHeader)
    If Ascan(::aCpoObri,{|a| a $ AllTrim(::aHeader[nInd,2]) }) > 0
       If Empty(::aCols[::oBrowse:oBrowse:nAt,nInd])
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � TudoOK     � Autor � Tulio Cesar         � Data � 05.04.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Metodo de TPLSBRW                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
METHOD TudoOK() CLASS TPLSCLBRW
LOCAL nInd
LOCAL lFlag := .T.
LOCAL nCont

For nCont := 1 To Len(::aCols)
    
    If ! ::aCols[::oBrowse:oBrowse:nAt,::ColDel()]
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
   MsgStop("Existem campos obrigatorios que nao foram informados."+Chr(13)+Chr(13)+" Verifique no Browse [ "+::cTitulo+" ]")
Endif   

Return(lFlag)
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � SEMOK      � Autor � Tulio Cesar         � Data � 05.04.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Metodo de TPLSBRW                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
METHOD SEMOK() CLASS TPLSCLBRW
LOCAL lReturn

lReturn := ::PLBlock(::aCols,::aHeader,::Linha(),::aSemaf)

Return(lReturn)
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � Coluna     � Autor � Tulio Cesar         � Data � 05.04.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Metodo de TPLSBRW                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
METHOD Coluna(cNameCol) CLASS TPLSCLBRW
LOCAL nCol

nCol := Ascan(::aHeader,{|a| AllTrim(a[2]) $ AllTrim(cNameCol)})
If nCol == 0
   MsgStop("Nao-conformidade Method Coluna(cNameCol) "+cCampo)
Endif   
Return(nCol)

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLRETPOS   � Autor � Tulio Cesar         � Data � 03.11.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Adiciona uma nova linha em branco...                       ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Method PLRETPOS(cCampo,lHelp) CLASS TPLSCLBRW
LOCAL nCol
DEFAULT lHelp := .T.

nCol := Ascan(::aHeader,{|a| AllTrim(a[2]) $ AllTrim(cCampo)})
If nCol == 0
   If lHelp
      MsgStop("Nao-conformidade Method PLRETPOS de PLSBRW campo "+cCampo)
   Endif   
Endif   
Return(nCol)


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � Grava      � Autor � Eduardo Motta       � Data � 22.05.01 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Grava no banco de dados                                    ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Method Grava(aChave) CLASS TPLSCLBRW
PLUPTCOLS(::cAlias,::aCols,::aHeader,::aVetTrab,::nOpc,aChave)
Return .T.

Function _TPLCLBRW() // nao retirar esta funcao
Return(.T.)
