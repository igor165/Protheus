#include "PLSA515.CH"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "COLORS.CH"
#IFDEF TOP
       #include "TOPCONN.CH"
#ENDIF       

#Define C_ALIAS 		1 //X3_ALIAS
#Define C_CAMPO 		2 //X3_CAMPO
#Define C_TIPO 			3 //X3_TIPO
#Define C_TAMANHO 		4 //X3_TAMANHO
#Define C_SUB 			5 //lSub
#Define C_TITLE 		6 //X3Title()
#Define C_PICTURE 		7 //X3_PICTURE
#Define C_CAB 			8 //lCab
#Define C_CBOX 			9 //CBOX

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA515 ³ Autor ³ Paulo Carnelossi	  ³ Data ³ 09/02/04   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Operadora x Valor Padrao de Co-Participacao    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA515()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina :=	MenuDef()

PRIVATE cCadastro 	:= Fundesc()

BWK->(mBrowse(06,01,350,256,"BWK",,,20))

SET KEY VK_F12 TO

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PL515AMov ³ Autor ³ Paulo Carnelossi      ³ Data ³ 09/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modulo de Manutencao OperadoraxValor Padrao Co-Participacao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PL515AMov(cAlias,nReg,nOpc)                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL515Mov(cAlias,nReg,nOpc)
Local I__f := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LOCAL aPosObj   := {}
LOCAL aObjects  := {}
LOCAL aSize     := {}
LOCAL aInfo     := {}

Local nOpca := 0
Local oDlg, ni

Local oFont
Local lLock := .F.


Local oEncBWK
Local oFolder

Local nOpcx        := nOpc
Local oDlgFolder

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Operadora x Valor para coo-participacao                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aCabBWW := {}
Local aDadBWW := {}
Local aTrbBWW := {}

PRIVATE aHeader      := {}
PRIVATE aCols        := {}
PRIVATE oBrwBWW

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Operadora x Valor para coo-participacao                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BWW" TO aCabBWW For .T.   

If nOpcx == K_Incluir
   Store COLS Blank "BWW" TO aDadBWW FROM aCabBWW
Else
   BWW->(DbSetOrder(1))
   If ! BWW->(DbSeek(xFilial("BWW")+BWK->BWK_CODINT+BWK->BWK_ANO+BWK->BWK_MES))
       Store COLS Blank "BWW" TO aDadBWW FROM aCabBWW
   Else
       Store COLS "BWW" TO aDadBWW FROM aCabBWW VETTRAB aTrbBWW ;
       While BWW->(BWW_FILIAL+BWW_CODINT+BWW_ANO+BWW_MES) == xFilial("BWW")+BWK->BWK_CODINT+BWK->BWK_ANO+BWK->BWK_MES
   Endif
   If Len(aDadBWW) == 0
      Store COLS Blank "BWW" TO aDadBWW FROM aCabBWW
   EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T. )

DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ENCHOICE (BWK)                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpcx == K_Incluir
   Copy "BWK" TO Memory Blank
Else
   Copy "BWK" TO Memory 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MSMGET -> Operadora/Produto                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAlias:="BWK"
nReg:=BWK->(RecNo())
oEncBWK := MSMGet():New(cAlias,nReg,nOpcx,,,,,aPosObj[1],,,,,,oDlgFolder,,,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Browse para Itens do cad. Oper. x Vlr Padrao Co-Participacao        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBWW := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil,oDlgFolder,nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBWW,aDadBWW,.F.,"BWW",nOpcx,"Operadora x Valor Padrao de Co-Participacao",nil,nil,nil,aTrbBWW,'PlsVldBWW',,)
oBrwBWW:bGotFocus := {||If(!Obrigatorio(oEncBWK:aGets, oEncBWK:aTela),oEncBWK:SetFocus(),.T.)}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder,{|| If( P515TudoOk(nOpcx) ,(PlsEndBrw(),nOpca := 1,oDlgFolder:End()),.F.)},{|| PlsEndBrw(), nOpca :=2 , oDlgFolder:End() },K_MsgDel)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata atualizacao dos dados...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK
  
   If nOpcx <> K_Visualizar 
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Operadora+Produto                                                   ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      
      BWK->(DbGoTo(nReg))
      PLUPTENC("BWK",nOpc)
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Comissao da Operadora/Produto                                       ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      aChave := {}
      aadd(aChave,{"BWW_CODINT"	,M->BWK_CODINT})
      aadd(aChave,{"BWW_ANO"	,M->BWK_ANO})
      aadd(aChave,{"BWW_MES"	,M->BWK_MES})
      oBrwBWW:Grava(aChave)

   Endif   

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ P515TudoOk ³ Autor ³ Marco Paulo         ³ Data ³ 03.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a checagem dos campos e pastas obrigatorias            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ P515Tudook(nOpc)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc - Opcao do aRotina                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function P515TudoOk(nOpc)
Local lRet := .T.

BWK->(DbSetOrder(1))
BWK->(DbSeek(xFilial()+M->BWK_CODINT+M->BWK_ANO+M->BWK_MES))
If nOpc == K_Incluir .and. !BWK->(Eof()) // SE FOR INCLUSAO VERIFICA SE O CODIGO JA ESTA GRAVADO NO ARQUIVO E NAO DEIXA CONTINUAR
   Help("",1,"JAGRAVADO")
   Return .F.
EndIf

If ! (oBRWBWW:TudoOk())
  	lRet    := .F.
EndIf 

Return lRet
   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA515   ºAutor  ³Microsiga           º Data ³  06/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PL515Imp(cAlias,nReg,nOpc)
PLR515()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLR515     ºAutor  ³Paulo Carnelossi   º Data ³  09/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime relacao com cadastro de Operadoras x Valora para    º±±
±±º          ³Coo-Participacao                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLR515()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local cDesc1 := "Este programa tem como objetivo imprimir os cadastros"
Local cDesc2 := "de Operadoras x Valor Padrao de Co-Participacao."
Local cDesc3 := ""
Local cString := "BWW"
Local Tamanho := "G"

PRIVATE cTitulo:= "Cadastro de Operadoras x Valor Padrao de Co-Participacao"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private cPerg   := "PLR515"
Private nomeprog:= "PLR515" 
Private nLastKey:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "PLR515"

Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)

If nLastKey == 27
   Return
End

SetDefault(aReturn,cString)

If nLastKey == 27
   Return ( NIL )
End

RptStatus({|lEnd| R515Imp(@lEnd,wnRel,cString)},cTitulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ R515Imp  ³ Autor ³ Paulo Carnelossi      ³ Data ³ 09/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Impressao Cadastro de OperxValor Padrao de co-participacao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ R515Imp(lEnd,wnRel,cString)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R515Imp(lEnd,wnRel,cString)
Local cbcont,cbtxt
Local tamanho:= "G"
Local nTipo 
Local cChave, cOperadora, cProduto,lTitulo, cAnoMes
Local bCond := {||BWW->BWW_ANO+BWW->BWW_MES >= mv_par02+mv_par03 .And. BWW->BWW_ANO+BWW->BWW_MES <= mv_par04+mv_par05}

Local aCpos, aAuxCab, nZ
Local aExcCpo := {}
Local aExcTam := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCpos  := Cpos_PLSR515()

aAuxCab := Linha_Cabec("BWW", aCpos, aExcTam)  
cabec1 := aAuxCab[1]
cabec2 := aAuxCab[2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

nTipo:=GetMv("MV_COMP")

dbSelectArea("BWW")
SetRegua(RecCount())
dbSeek(xFilial("BWW")+mv_par01)

While BWW->(! Eof() .And. BWW_FILIAL == xFilial("BWW") .And. BWW_CODINT == mv_par01)
	
	IncRegua()
	
	cAnoMes     := BWW_ANO+BWW_MES
	cChave 		:= xFilial("BWW")+BWW_CODINT+BWW_ANO+BWW_MES
	lTitulo 		:= .T.
	
	While  BWW->(! EOF() .And. BWW_FILIAL+BWW_CODINT+BWW_ANO+BWW_MES == cChave)
	
		If Eval(bCond)
			IF li > 58
				cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			End
			
			If lTitulo
	
				cOperadora  := BWW_CODINT+" - "+Padr(Posicione("BA0",1,xFilial("BA0")+BWW->BWW_CODINT,"BA0_NOMINT"),40)
				@ li,000 PSAY cOperadora
				li++
				@ li,000 PSAY PLRETMES(Val(Right(cAnoMes,2)))+"/"+Left(cAnoMes,4)
				li++
				lTitulo := .F.
				
	        EndIf
	         
			Impr_Linha("BWW", aCpos, 000)
		
    	EndIf
   	
   		BWW->(dbSkip())
		
	End
	
	li++
	
End

roda(cbcont,cbtxt,tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("BWW")

Set Device To Screen

If aReturn[5] = 1
   Set Printer To
	dbCommitAll()
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA515WHE³ Autor ³ Tulio Cesar          ³ Data ³ 14.01.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ When de diversos campo do siga...                           ³±±
±±³          ³ nao cabe no X3_WHEN ai coloca em uma funcao                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA515Whe(cTipo)
LOCAL lPode := .F.

If     cTipo == "01" //BWW_PERCOP
       lPode := ( M->BWW_VLRCOP == 0 )
ElseIf cTipo == "02" //BWW_VLRCOP
       lPode := ( M->BWW_PERCOP == 0 .And. M->BWW_VALUS == 0 )       
ElseIf cTipo == "03" //BWW_VALUS
       lPode := ( M->BWW_VLRCOP == 0 )       
Endif
                                        
Return(lPode)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Cpos_PLSR515 ºAutor  ³Paulo Carnelossi   º Data ³ 09/01/04  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta array com campos a serem impresso no                 º±±
±±ºDesc.     ³ relatorio Autor.Negadas POS                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Cpos_PLSR515()
Local aCpoImp := {}, aCampos := {}, nX
Local lTit := .F., aCpoTit := {}, aAlias := {"BWW"}
Local lSub := .F., aCpoSub := {}

aAdd(aCpoTit, "BWW_FILIAL")
aAdd(aCpoTit, "BWW_CODINT")
aAdd(aCpoTit, "BWW_ANO")
aAdd(aCpoTit, "BWW_MES")

dbSelectArea("SX3")
dbSetOrder(1)

For nX := 1 TO Len(aAlias)
    If dbSeek(aAlias[nX])
    	While SX3->(!Eof() .And. X3_ARQUIVO == aAlias[nX]) .and. X3_CONTEXT != 'V'
			aAdd(aCpoImp, Alltrim(SX3->X3_CAMPO))
            SX3->(dbSkip())
   		End
   EndIf
Next

dbSelectArea("SX3")
dbSetOrder(2)

For nX := 1 TO Len(aCpoImp)
	lTit := .F.
	lSub := .F.
    If dbSeek(aCpoImp[nX])
        lTit := ASCAN(aCpoTit, aCpoImp[nX]) > 0
        lSub := ASCAN(aCpoSub, aCpoImp[nX]) > 0
    	aAdd(aCampos, { X3_ARQUIVO, X3_CAMPO, X3_TIPO, X3_TAMANHO, lSub, X3_TITULO, X3_PICTURE, lTit, X3_CBOX })
    EndIf
Next

Return(aCampos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Linha_Cabec ºAutor  ³Paulo Carnelossi  º Data ³  09/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta Linha Cabec para Relatorio                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Linha_Cabec(cAlias, aCampos, aExcTam)
Local nX, aLinCabec, cLinCabec1 := "", cLinCabec2 := "", cTitle, aAuxText
Local nZ, aComboBox, nMaiorTam := 0

For nX := 1 TO Len(aCampos)

	If aCampos[nX][C_ALIAS] == cAlias .And. ! aCampos[nX][C_CAB]
        
        cTitle := AllTrim(aCampos[nX][C_TITLE])
        
		If aCampos[nX][C_TIPO] == "N"
		
       		If Len(cTitle) <= aCampos[nX][C_TAMANHO]
				cLinCabec1 += PadL(cTitle, aCampos[nX][C_TAMANHO])
				cLinCabec2 += Space(aCampos[nX][C_TAMANHO])
			Else
				aAuxText := R515QbTexto(cTitle, aCampos[nX][C_TAMANHO], Space(1))
				cLinCabec1 += PadL(aAuxText[1], aCampos[nX][C_TAMANHO])
				If Len(aAuxText) > 1
					cLinCabec2 += PadL(aAuxText[2], aCampos[nX][C_TAMANHO])
				EndIf	
			EndIf
			cLinCabec1 += Space(1)
			cLinCabec2 += Space(1)
			
       	Else

       		If  (nPosTam := ASCAN(aExcTam, {|aVal| aVal[1] == aCampos[nX][C_CAMPO]})) > 0
       			aCampos[nX][C_TAMANHO] := aExcTam[nPosTam][2]
       		EndIf
       		
       		If ! EMPTY(aCampos[nX][C_CBOX]) // COMBO BOX
       		    aComboBox := RetSX3Box(aCampos[nX][C_CBOX],,,1)
       		    nMaiorTam := aCampos[nX][C_TAMANHO]
       		    AEVAL(aComboBox, {|cValue, nZ|nMaiorTam := If(Len(aComboBox[nZ][1]) > nMaiorTam, Len(aComboBox[nZ][1]), nMaiorTam)} )
       			aCampos[nX][C_TAMANHO] := nMaiorTam
       	    EndIf
       	    
       		If Len(cTitle) <= aCampos[nX][C_TAMANHO]
				cLinCabec1 += PadR(cTitle, aCampos[nX][C_TAMANHO])
				cLinCabec2 += Space(aCampos[nX][C_TAMANHO])
			Else
				aAuxText := R515QbTexto(cTitle, aCampos[nX][C_TAMANHO], Space(1))
				cLinCabec1 += PadR(aAuxText[1], aCampos[nX][C_TAMANHO])
				If Len(aAuxText) > 1
					cLinCabec2 += PadR(aAuxText[2], aCampos[nX][C_TAMANHO])
				EndIf	
			EndIf
			cLinCabec1 += Space(1)
			cLinCabec2 += Space(1)

       	EndIf
       
	EndIf
	
Next

aLinCabec := { cLinCabec1, cLinCabec2 }

Return(aLinCabec)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Impr_Linha  ºAutor  ³Paulo Carnelossi  º Data ³  09/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime Linha de dados                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Impr_Linha(cAlias, aCampos, nCol, aChvImp, lQuebraLinha)
Local nX, xContCpo, aComboBox, nZ, cValue, cCombo, cCampo, nPosCpo
Local aLinSobra := {}, aAuxCont, aSobra := {}

DEFAULT aChvImp := {}
DEFAULT lQuebraLin := .F.

For nX := 1 TO Len(aCampos)
    
	If aCampos[nX][C_ALIAS] == cAlias .And. ! aCampos[nX][C_CAB]
        
        nPosCpo := (cAlias)->(FieldPos(aCampos[nX][C_CAMPO]))
        If nPosCpo > 0 
        	xContCpo := (cAlias)->(FieldGet(nPosCpo))
       	Else
        	cCampo   :=aCampos[nX][C_CAMPO]
        	xContCpo := &cCampo
        EndIf
        
		If aCampos[nX][C_TIPO] == "N"
		    If Empty(aChvImp) .OR. ASCAN(aChvImp, aCampos[nX][C_CAMPO]) == 0
				@ li, nCol PSay PadL(Transform(xContCpo, aCampos[nX][C_PICTURE]), aCampos[nX][C_TAMANHO])
			EndIf	
       	Else
       		If aCampos[nX][C_TIPO] == "D"
       			xContCpo := DTOC(xContCpo)
       		EndIf
       		
       		If ! EMPTY(aCampos[nX][C_CBOX]) // COMBO BOX
       		    aComboBox := RetSX3Box(aCampos[nX][C_CBOX],,,1)
       		    cCombo := NIL
       		    For nZ := 1 To Len(aComboBox)
	       		    If aComboBox[nZ][2] == xContCpo
	       		    	cCombo := aComboBox[nZ][1]
       		    	    Exit
       		    	EndIf
       		    Next	    
       		    xContCpo := If(cCombo == NIL, xContCpo, cCombo)
       	    EndIf
       		
       		If Empty(aChvImp) .OR. ASCAN(aChvImp, aCampos[nX][C_CAMPO]) == 0
				@ li, nCol PSay PadR(xContCpo, aCampos[nX][C_TAMANHO])
			EndIf
			
			If lQuebraLinha .And. aCampos[nX][C_TIPO] == "C" .And. Len(xContCpo) > aCampos[nX][C_TAMANHO]
				aAdd(aLinSobra, {li,nCol, xContCpo, aCampos[nX][C_TAMANHO]})
			EndIf

       	EndIf

		nCol += aCampos[nX][C_TAMANHO]+1  //1->separador
        
    EndIf
    
Next

li++

If lQuebraLinha
	aSobra := {}
	For nX := 1 TO Len(aLinSobra)
	    //O STRTRAN E USADO PARA EXTRAIR XCONTCPO O JA IMPRESSO
		xContCpo := AllTrim(StrTran(aLinSobra[nX][3], PadR(aLinSobra[nX][3], aLinSobra[nX][4]), ""))
		If Len(xContCpo) > 0
			aAuxCont := R515QbTexto( xContCpo, aLinSobra[nX][4], Space(1) )
			For nZ := 1 TO Len(aAuxCont)
				aAdd(aSobra, { aLinSobra[nX][1]+nZ, aLinSobra[nX][2], aAuxCont[nZ] })
			Next
		EndIf
	Next
EndIf

If Len(aSobra) > 0 
   //coloca em ordem de linha/coluna
   aSobra := ASORT(aSobra,,, { |x, y| x[1] < y[1] .And. x[2] < y[2] })

   For nX := 1 TO Len(aSobra)
		@ aSobra[nX][1], aSobra[nX][2] PSay aSobra[nX][3]
   Next
   li := aSobra[Len(aSobra)][1]
   li++
EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R515QbTexto ºAutor ³Paulo Carnelossi   º Data ³  02/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Quebra o Texto de acordo com tamnho e separador informado   º±±
±±º          ³devolvendo um array com a string quebrada                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R515QbTexto(cTexto, nTamanho, cSeparador)
Local aString := {}, nTamAux := nTamanho
Local nPos, nCtd, nTamOri := Len(cTexto), cAuxTexto

If Len(Trim(cTexto)) > 0

   If Len(Trim(cTexto)) <= nTamanho

      If Len(Trim(cTexto)) > 0
	      aAdd(aString, AllTrim(cTexto) )
      EndIf

   Else
	
		If (nPos := At(cSeparador, cTexto)) != 0
		   
			For nCtd := 1 TO nTamOri STEP nTamAux
		
				cAuxTexto := Subs(cTexto, nCtd, nTamanho)
			
			   If nCtd+nTamanho < nTamOri
				   While Len(Subs(cAuxTexto, Len(cAuxTexto), 1)) > 0 .And. ;
				   				Subs(cAuxTexto, Len(cAuxTexto), 1) <> cSeparador
				   
			   		cAuxTexto := Subs(cAuxTexto, 1, Len(cAuxTexto)-1)
			   		
			      End
			   EndIf
			      
		      If Len(cAuxTexto) > 0
			      cAuxTexto 	:= Subs(cTexto, nCtd, Len(cAuxTexto))
			      nTamAux 		:= Len(cAuxTexto)
		      Else
		      	cAuxTexto := Subs(cTexto, nCtd, nTamanho)
			      nTamAux 		:= nTamanho
		      EndIf
		
		      If Len(Trim(cAuxTexto)) > 0
			      aAdd(aString, Alltrim(cAuxTexto))
		      EndIf
		   Next
		
		Else
		
			For nCtd := 1 TO nTamOri STEP nTamanho
			   If Len(Subs(cTexto, nCtd, nTamanho)) > 0 
			      If Len(Trim(Subs(cTexto, nCtd, nTamanho))) > 0
						aAdd(aString, AllTrim(Subs(cTexto, nCtd, nTamanho)))
					EndIf	
				EndIf	
			Next
		
		EndIf
		
	EndIf
Else
	aAdd(aString, Space(nTamanho))	
EndIf

Return aString

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³05/01/2007³±±
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
Private aRotina := {	{ STRPL01	,'AxPesqui'	, 0 ,K_Pesquisar 	, 0, .F.},;
                   		{ STRPL02	,'PL515Mov'	, 0 ,K_Visualizar	, 0, Nil},;
             			{ STRPL03		,'PL515Mov'	, 0 ,K_Incluir   	, 0, Nil},;
	      	  			{ STRPL04		,'PL515Mov'	, 0 ,K_Alterar  	, 0, Nil},;
                     	{ STRPL05		,'PL515Mov'	, 0 ,K_Excluir  	, 0, Nil},;
						{ "impRimir"	,'PL515Imp'	, 0 ,K_Alterar 	 	, 0, Nil} }
Return(aRotina)      

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldBWW ºAutor  ³Microsiga           º Data ³  18/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funca de validacao das datas de vigencia, chamada no       º±±
±±º          ³ botao de OK da Rotina Cobertura / Co-Participacao.         º±±
±±º          ³ Tabela - BVF - Familia x Proced x Co-Part  				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PlsVldBWW()
Local lRet     := .T.
LOCAL aChave   := {}
Local aArea	   := GetArea()      

If BWW->( FieldPos("BWW_FINATE") ) > 0 
	aChave := {'01',M->BWW_TIPO+cValToChar(M->BWW_QTD)+M->BWW_CODTAB+M->BWW_FINATE,'BWW_TIPO+BWW_QTD+BWW_CODTAB+BWW_FINATE'}
Else
	aChave := {'01',M->BWW_TIPO+cValToChar(M->BWW_QTD)+M->BWW_CODTAB,'BWW_TIPO+BWW_QTD+BWW_CODTAB'}
Endif

If  BWW->( FieldPos("BWW_VIGINI") ) > 0 .And. BWW->( FieldPos("BWW_VIGFIN") ) > 0
	cDatDe   := "BWW_VIGINI"
	cDatAte  := "BWW_VIGFIN"

	If !Empty(M->BWW_VIGINI)
		lRet := PLSVLDVIG("BWW",0,oBrwBWW,cDatDe,cDatAte,aChave)
	EndIf
EndIf	

RestArea(aArea)

Return(lRet)   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSQTDBWW ºAutor  ³Microsiga           º Data ³  08/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a quantidade quando nao existe data de vigencia     º±±
±±º          ³ Informada e nao permite quantidade duplicada.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSQTDBWW()
Local lRet := .F. 
Local nX   := 0     
Local nPosIni := ""
Local nPosFin := ""
Local nQTD    := ""   
Local aArea	  := GetArea()  
Local nUsado  := Len(oBrwBWW:aHeader)

nQTD    := Ascan(oBrwBWW:aHeader,{|x| Alltrim(x[2])=="BWW_QTD"})  

If BWW->( FieldPos("BWW_VIGINI") ) > 0 .And. BWW->( FieldPos("BWW_VIGFIN") ) > 0
	nPosIni := Ascan(oBrwBWW:aHeader,{|x| Alltrim(x[2])=="BWW_VIGINI"})
	nPosFin := Ascan(oBrwBWW:aHeader,{|x| Alltrim(x[2])=="BWW_VIGFIN"})
	
	For nX := 1 To Len(oBrwBWW:aCols)
		If !oBrwBWW:aCols[nX][nUsado+1]
			If nX < n
				If M->BWW_VIGINI == CTOD(" / / ") .And. M->BWW_VIGFIN == CTOD(" / / ")
					If M->BWW_QTD == oBrwBWW:aCols[nX][nQTD] .And. Empty(oBrwBWW:aCols[nX][nPosIni]) .And. Empty(oBrwBWW:aCols[nX][nPosFin])
						PLSVLDCOL({"BWW_TIPO","BWW_QTD"})     
						Return lRet := .T.
					Endif
				Endif
			Endif
		Endif
	Next nX 
Else	
	PLSVLDCOL({"BWW_TIPO","BWW_QTD"})     
	Return lRet := .T.
EndIf

RestArea(aArea)

Return lRet                                                                                           