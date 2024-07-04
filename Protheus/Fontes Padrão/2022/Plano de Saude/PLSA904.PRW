
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA904 ³ Autor ³ Angelo Sperandio     ³ Data ³ 17.04.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Regras de comissao por vendedor                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
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

Function PLSA904()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina 	:= MenuDef()
PRIVATE cAlias    := "BXJ"
PRIVATE cCadastro := PLSRetTit(cAlias)
PRIVATE cCodInt
Private cCodEmp
PRIVATE aNumBXJ   := {}

_cFil := "BXJ_TIPO = '1'"
BXJ->(DbSetFilter({||&_cFil},_cFil))
BXJ->(DbSetOrder(1))
BXJ->(dbGoTop())

BXJ->(mBrowse(06,01,22,75,"BXJ",,,20))
BXJ->(DbClearFilter())

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PL904MOV ³ Autor ³ Angelo Sperandio      ³ Data ³ 17.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Regras de comissao por vendedor                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PL903MOV(cAlias,nReg,nOpc)                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PL904MOV(cAlias,nReg,nOpc)
Local I__f := 0
Local aCamposEnc := {}
Local nRegSX3 := SX3->(Recno())
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local aDifSize:= {,,,,35,3,,}//array com dimenções para correção de telas na versão 12
Private nOpcA := 0                                                           
Private nOpcx := nOpc
Private aButtons  := {}
Private aTELA[0][0]
Private aGETS[0]
Private oEncCla
Private oBrwPro
Private aHeader  := {}
Private aCols    := {}
Private aVetTrab := {}
Private oDlg

nOpc := aRotina[nOpc,4]

If nOpc == K_Alterar .and. !Empty(BXJ->BXJ_VLDFIM)
   MsgStop(" Nao e' possivel alterar pois vigencia ja foi finalizada.")
   Return
EndIf

If nOpc == K_Excluir .and. !Empty(BXJ->BXJ_VLDFIM)
   MsgStop(" Nao e' possivel excluir pois vigencia ja foi finalizada.")
   Return
EndIf

SX3->(DbSetOrder(1))
SX3->(DbSeek("BXJ"))
While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == "BXJ"
   If PLSCHKNIV(.t.)
      aadd(aCamposEnc,SX3->X3_CAMPO)
   EndIf   
   SX3->(DbSkip())
EndDo

If  nOpc == K_Incluir
    Copy "BXJ" To Memory Blank
Else
    Copy "BXJ" TO MEMORY                                           
EndIf

Store Header "BXK" TO aHeader For ! SX3->X3_CAMPO $ "BXK_SEQBXJ"

If  nOpcx == K_Incluir
	Store COLS Blank "BXK" TO aCols FROM aHeader
Else
    BXK->(DbSetOrder(1))
    If  BXK->(DbSeek(xFilial("BXK")+BXJ->BXJ_SEQ))
        Store COLS "BXK" TO aCols FROM aHeader VETTRAB aVetTrab While xFilial("BXK")+BXK->BXK_SEQBXJ == BXJ->(BXJ_FILIAL+BXJ_SEQ)
    Else
        Store COLS Blank "BXK" TO aCols FROM aHeader
    Endif   
EndIf        

aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1, 1, .T., .T., .F. } )
AAdd( aObjects, { 1, 1, .T., .T., .F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel

oEncCla := MSMGET():New("BXJ",BXJ->(Recno()),nOpcx,,,,aCamposEnc,aPosObj[1],,,,,,oDlg,,,.F.)

if Val(GetVersao(.F.)) >= 12 //Valida versão 12
	oBrwPro := TPLSBrw():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][4],aPosObj[2][3],nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aHeader   ,aCols ,.F.      ,"BXK" ,nOpc,"Itens",nil,nil,nil,aVetTrab,,,,,,,,,,,,,aDifSize)
Else
	oBrwPro := TPLSBrw():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][4],aPosObj[2][3],nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aHeader   ,aCols ,.F.      ,"BXK" ,nOpc,"Itens",nil,nil,nil,aVetTrab)
Endif

ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,{|| nOpca := 1,If(Obrigatorio(aGets,aTela) .And. oBrwPro:TudoOK(),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) },{||oDlg:End()},.F.,aButtons) })

If  nOpca == K_OK .and. nOpc <> K_Visualizar
   	Begin Transaction     
      	PLUPTENC("BXJ",nOpc,.T.)      
 	    aChaveGen := {}
      	aadd(aChaveGen,{"BXK_SEQBXJ",M->BXJ_SEQ})
        oBrwPro:Grava(aChaveGen)      		
	End Transaction
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA904Vig ³ Autor ³Eduardo Motta      ³ Data ³ 20.05.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Finaliza uma vigencia                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA904Vig(cAlias,nReg,nOpc)
Local I__f := 0
Local dDataFim
Local lCopia
Local aCamposEnc := {}
Local nRegSX3 := SX3->(Recno())
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Private nOpcA := 0                                                           
Private aButtons  := {}
Private aTELA[0][0]
Private aGETS[0]
Private oEncCla
Private oBrwPro
Private aHeader  := {}
Private aCols    := {}
Private aVetTrab := {}
Private oDlg

If !Empty(BXJ->BXJ_VLDFIM)
   MsgStop(" Regra com vigencia ja finalizada")
   Return
EndIf
AjustaSx1()
If !Pergunte("PLS904")
   Return
EndIf   
dDataFim := MV_PAR01
lCopia   := (MV_PAR02==1)

nOpc := K_Visualizar

SX3->(DbSetOrder(1))
SX3->(DbSeek("BXJ"))
While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == "BXJ"
   If AllTrim(SX3->X3_CAMPO) $ "BXJ_CODEQU/BXJ_DESEQU"
      SX3->(DbSkip())
      Loop
   EndIf   
   If PLSCHKNIV(.t.)
      aadd(aCamposEnc,SX3->X3_CAMPO)
   EndIf   
   SX3->(DbSkip())
EndDo

If  nOpc == K_Incluir
    Copy "BXJ" To Memory Blank
Else
    Copy "BXJ" TO MEMORY                                           
EndIf

Store Header "BXK" TO aHeader For ! SX3->X3_CAMPO $ "BXK_SEQBXJ"

If  nOpc == K_Incluir
	Store COLS Blank "BXK" TO aCols FROM aHeader
Else
    BXK->(DbSetOrder(1))
    If  BXK->(DbSeek(xFilial("BXK")+BXJ->BXJ_SEQ))
        Store COLS "BXK" TO aCols FROM aHeader VETTRAB aVetTrab While xFilial("BXK")+BXK->BXK_SEQBXJ == BXJ->(BXJ_FILIAL+BXJ_SEQ)
    Else
        Store COLS Blank "BXK" TO aCols FROM aHeader
    Endif   
EndIf        

M->BXJ_VLDFIM := dDataFim

aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1, 1, .T., .T., .F. } )
AAdd( aObjects, { 1, 1, .T., .T., .F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro+" - Finaliza Vigencia" FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel

oEncCla := MSMGET():New("BXJ",BXJ->(Recno()),nOpc,,,,aCamposEnc,aPosObj[1],,,,,,oDlg,,,.F.)
               
oBrwPro := TPLSBrw():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][4],aPosObj[2][3],nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aHeader   ,aCols ,.F.      ,"BXK" ,nOpc,"Itens",nil,nil,nil,aVetTrab)

ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,{|| nOpca := 1,If(Obrigatorio(aGets,aTela) .And. oBrwPro:TudoOK(),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) },{||oDlg:End()},.F.,aButtons) })

If  nOpca == K_OK
   BXJ->(RecLock("BXJ"))
   BXJ->BXJ_VLDFIM := dDataFim
   BXJ->(MsUnlock())
   BXJ->(DbCommit())
   If lCopia
      Plsa904Cop(cAlias,nReg,nOpc)
   EndIf   
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA904Cop ³ Autor ³Eduardo Motta      ³ Data ³ 20.05.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Copia uma regra                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA904Cop(cAlias,nReg,nOpc)
Local I__f := 0
Local nI
Local cSql
Local aCampos := {}
Local cVar
Local lAchou
Local aCamposEnc := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Private nOpcA := 0                                                           
Private aButtons  := {}
Private aTELA[0][0]
Private aGETS[0]
Private oEncCla
Private oBrwPro
Private aHeader  := {}
Private aCols    := {}
Private aVetTrab := {}
Private oDlg

Copy "BXJ" TO MEMORY                                           

SX3->(DbSetOrder(1))
SX3->(DbSeek("BXJ"))
While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == "BXJ"
   If AllTrim(SX3->X3_CAMPO) $ "BXJ_CODEQU/BXJ_DESEQU"
      SX3->(DbSkip())
      Loop
   EndIf   
   If PLSCHKNIV(.t.)
      aadd(aCamposEnc,SX3->X3_CAMPO)
   EndIf   
   SX3->(DbSkip())
EndDo

Store Header "BXK" TO aHeader For ! SX3->X3_CAMPO $ "BXK_SEQBXJ"

If  nOpc == K_Incluir
	Store COLS Blank "BXK" TO aCols FROM aHeader
Else
    BXK->(DbSetOrder(1))
    If  BXK->(DbSeek(xFilial("BXK")+BXJ->BXJ_SEQ))
        Store COLS "BXK" TO aCols FROM aHeader VETTRAB aVetTrab While xFilial("BXK")+BXK->BXK_SEQBXJ == BXJ->(BXJ_FILIAL+BXJ_SEQ)
    Else
        Store COLS Blank "BXK" TO aCols FROM aHeader
    Endif   
EndIf        

aCampos := BXJ->(DbStruct())

M->BXJ_SEQ := GetSx8Num("BXJ","BXJ_SEQ")

cSql := "SELECT * FROM "+RetSqlName("BXJ")+" WHERE "
For nI := 1 to Len(aCampos)
   If AllTrim(aCampos[nI,1]) $ "BXJ_FILIAL/BXJ_SEQ/BXJ_SEQBXL/BXJ_VLDINI/BXJ_VLDFIM"
      Loop
   EndIf
   cVar := "M->"+AllTrim(aCampos[nI,1])
   If ValType(cVar) == "N"
      Loop
   EndIf   
   If ValType(cVar) == "D"
      cVar := DtoS(cVar)
   EndIf   
   If ValType(cVar) # "C"
      Loop
   EndIf   
   cSql += aCampos[nI,1]+" = '"+&cVar+"' AND "
Next
cSql += "BXJ_FILIAL = '"+xFilial("BXJ")+"' AND D_E_L_E_T_ = ' '"

If Select("SQLBXJ") > 0
   SQLBXJ->(DbCloseArea())
EndIf
PLSQuery(cSQL,"SQLBXJ")
lAchou := .F.
While !SQLBXJ->(Eof())
   If Empty(SQLBXJ->BXJ_VLDFIM)
      lAchou := .t.
      Exit
   EndIf
   M->BXJ_VLDINI := SQLBXJ->BXJ_VLDFIM+1
   SQLBXJ->(DbSkip())
EndDo
SQLBXJ->(DbCloseArea())

If lAchou
   MsgStop(" Para se criar uma nova vigencia as vigencias dessa equipe devem estar todas encerradas.")
   Return
EndIf

nOpc := K_Incluir
M->BXJ_VLDFIM := CtoD("")

aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1, 1, .T., .T., .F. } )
AAdd( aObjects, { 1, 1, .T., .T., .F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro+" - Copia Regra de Comissao" FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel

oEncCla := MSMGET():New("BXJ",BXJ->(Recno()),K_Incluir,,,,aCamposEnc,aPosObj[1],,,,,,oDlg,,,.F.)
               
oBrwPro := TPLSBrw():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][4],aPosObj[2][3],nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aHeader   ,aCols ,.F.      ,"BXK" ,K_Incluir,"Itens",nil,nil,nil,aVetTrab)

ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,{|| nOpca := 1,If(Obrigatorio(aGets,aTela) .And. oBrwPro:TudoOK(),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) },{||oDlg:End()},.F.,aButtons) })

If  nOpca == K_OK
   	Begin Transaction     
      	PLUPTENC("BXJ",K_Incluir,.T.)      
 	    aChaveGen := {}
      	aadd(aChaveGen,{"BXK_SEQBXJ",M->BXJ_SEQ})
        oBrwPro:Grava(aChaveGen,.T.)
	End Transaction
Endif
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AjustaSX1 ³ Autor ³ Eduardo Motta         ³ Data ³ 20.05.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclusao de pergunta no SX1               		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PLS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION AjustaSx1()
Local aRegs	:=	{}

aadd(aRegs,{"PLS904","01","Data fim vigencia","","","mv_ch1","D", 8,0,0,"G","DtoS(BXJ->BXJ_VLDINI) <= DtoS(mv_par01)","mv_par01","","","","'01/06/04'","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLS904","02","Copiar","","","mv_ch2","C", 1,0,2,"C","","mv_par02","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PL904B","01","Do vendedor        ?","¨De Vendedor       ?","From Sales Repr.   ?","mv_ch1","C", 6,0,0,"G","","mv_par01","","","","000002","","","","","","","","","","","","","","","","","","","","","SA3",""})
aadd(aRegs,{"PL904B","02","Ate vendedor       ?","¨A  Vendedor       ?","To Sales Represent.?","mv_ch2","C", 6,0,0,"G","","mv_par02","","","","000001","","","","","","","","","","","","","","","","","","","","","SA3",""})
PlsVldPerg( aRegs )
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA904Prn ³ Autor ³Eduardo Motta      ³ Data ³ 20.05.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime as regras                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA904Prn(cAlias,nReg,nOpc)
Local cVendIni,cVendFin
Local cSql
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local cDesc1 := "Este programa tem como objetivo imprimir as Regras "
Local cDesc2 := "de Comissao dos Vendedores."
Local cDesc3 := ""
Local cString := "BXJ"
Local Tamanho := "M"
Local aCamposCab := {}
Local aCamposIte := {}
Local nTotIte
Local nLinAnt
Local nTotCab

PRIVATE cTitulo:= "R e g r a s   d e   C o m i s s a o"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
Private cPerg   := "PL904B"
Private nomeprog:= "PLSA904" 
Private nLastKey:=0
Private nTipo
Private nLin        := 80
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .t.
PRIVATE lFiltro     := .F.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE lAbortPrint := .F.
PRIVATE Inclui := .F. // NECESSARIO POIS EXISTEM CAMPOS COM INICIALIZADOR QUE VERIFICAM ESTA VARIAVEL

nTipo:=GetMv("MV_COMP")

AjustaSx1()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cabec1:= ""
cabec2:= ""
//        123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "PLA904"

Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)

If nLastKey == 27
   Return
End

SetDefault(aReturn,cString)

If nLastKey == 27
   Return ( NIL )
End

SX3->(DbSetOrder(1))
SX3->(DbSeek("BXJ"))
While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO=="BXJ"
   If AllTrim(SX3->X3_CAMPO) $ "BXJ_TIPO/BXJ_CODEQU/BXJ_DESEQU/BXJ_SEQBXL"
      SX3->(DbSkip())
      Loop
   EndIf   
   If PLSCHKNIV(.t.)
      If SX3->X3_CONTEXT # "V"
         aadd(aCamposCab,{.t.,SX3->X3_CAMPO,nil,X3TITULO(),SX3->X3_ARQUIVO+"->"+AllTrim(SX3->X3_CAMPO),nil})
      Else
         aadd(aCamposCab,{.t.,SX3->X3_CAMPO,nil,X3TITULO(),SX3->X3_RELACAO,nil})
      EndIf   
   EndIf   
   SX3->(DbSkip())
EndDo

SX3->(DbSetOrder(1))
SX3->(DbSeek("BXK"))
While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO=="BXK"
   If AllTrim(SX3->X3_CAMPO) $ "BXK_SEQBXJ"
      SX3->(DbSkip())
      Loop
   EndIf   
   If PLSCHKNIV(.t.)
      aadd(aCamposIte,{.t.,SX3->X3_CAMPO,nil,nil,nil,nil})
   EndIf   
   SX3->(DbSkip())
EndDo

cVendIni := MV_PAR01
cVendFin := MV_PAR02

cSql := "SELECT * FROM "+RetSqlName("BXJ")+" WHERE "
cSql += "BXJ_FILIAL = '"+xFilial("BXJ")+"' AND BXJ_TIPO = '1' AND D_E_L_E_T_ = ' ' "
If !Empty(cVendIni)
   cSql+="AND BXJ_CODVEN >= '"+cVendIni+"' " 
EndIf
If !Empty(cVendFin)
   cSql+="AND BXJ_CODVEN <= '"+cVendFin+"' " 
EndIf
If Select("SQLBXJ") > 0
   SQLBXJ->(DbCloseArea())
EndIf
PLSQuery(cSQL,"SQLBXJ")
nTotCab := 100
While !SQLBXJ->(Eof())
   BXJ->(DbGoto(SQLBXJ->R_E_C_N_O_))
   nTotIte := 0
   BXK->(DbSetOrder(1))
   BXK->(DbSeek(xFilial("BXK")+BXJ->BXJ_SEQ))
   While BXK->(!Eof()) .and. xFilial('BXK')+BXJ->BXJ_SEQ==BXK->(BXK_FILIAL+BXK_SEQBXJ)
      nTotIte++
      BXK->(DbSkip())
   EndDo
   If nTotIte+nTotCab+nLin > 55
      nLin := cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
   EndIf   
   nLinAnt := nLin
   PlsRelCab(@nLin,,"BXJ","Regras de Comissao",aCamposCab)
   nTotCab := nLin-nLinAnt   
   nLin+=2
   PlsRelIte(@nLin,,"BXK",xFilial("BXK")+BXJ->BXJ_SEQ,"xFilial('BXK')+BXJ->BXJ_SEQ==BXK->(BXK_FILIAL+BXK_SEQBXJ)","AllwaysTrue()",,aCamposIte,1)
   nLin+=nTotIte+2
   SQLBXJ->(DbSkip())
EndDo

SQLBXJ->(DbCloseArea())

roda(0,Space(10),"M")
Set Device To Screen

If aReturn[5] = 1
   Set Printer To
	dbCommitAll()
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³08/01/2007³±±
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
Private aRotina := {	{ STRPL01	,'AxPesqui' 	, 0 ,K_Pesquisar 	, 0, .F.},;
						{ STRPL02 	,'pl904Mov' 	, 0 ,K_Visualizar	, 0, Nil},;
       			      	{ STRPL03 	,'pl904Mov' 	, 0 ,K_Incluir   	, 0, Nil},;
				      	{ STRPL04	 	,'pl904Mov' 	, 0 ,K_Alterar   	, 0, Nil},;
				      	{ "Vigencia"	,'plsa904Vig' 	, 0 ,K_Alterar   	, 0, Nil},;
				      	{ "Copiar"	 	,'plsa904Cop' 	, 0 ,K_Alterar   	, 0, Nil},;
                      	{ STRPL05	 	,'pl904Mov' 	, 0 ,K_Excluir   	, 0, Nil},;
                      	{ "Imprimir"	,'plsa904Prn' 	, 0 ,K_Visualizar	, 0, Nil} }
Return(aRotina)