
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "COLORS.CH"
#include "TOPCONN.CH"

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA421 � Autor � Paulo Carnelossi     � Data � 08/09/2003 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Cadastro de Metas de Vendas                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � AP                                                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLSA421()

PRIVATE M->BWR_CODINT := ""   // nao tirar esta declaracao pois usa na consulta padrao
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Declaracao de variaveis...                                          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
PRIVATE aRotina :=	MenuDef()

PRIVATE cCadastro 	:= "Metas de Vendas"
PRIVATE nTpMeta, nTpQtVl, cAnoRef, cMesRef, cCodPro, cCodInt

Pergunte("PLS421",.T.)
nTpMeta	:= mv_par01
nTpQtVl	:= mv_par02
cCodInt	:= mv_par03
cCodPro	:= mv_par04
cAnoRef	:= mv_par05
cMesRef	:= mv_par06
											
BCY->(mBrowse(06,01,350,256,"BCY",,,20,,,,'PLSA421Top()','PLSA421Bot()'))

Return Nil

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    砅LS421Mov � Autor � Paulo Carnelossi      � Data � 08/09/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Modulo de Manutencao do Cadastro de Metas de Vendas        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅LS421Mov(cAlias,nReg,nOpc)                                 潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLS421Mov(cAlias,nReg,nOpc)
Local I__f := 0
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define variaveis...                                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Local nOpca := 0
Local oDlg, ni

Local oFont
Local lLock := .F.


Local oEncBCY
Local oFolder

Local nOpcx        := nOpc
Local oDlgFolder

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define dialogo...                                                   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� ENCHOICE (BCY)                                                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

If nOpcx == K_Incluir
   Copy "BCY" TO Memory Blank
	M->BCY_TPMETA := Str(nTpMeta, 1)	
	M->BCY_TPQTVL := Str(nTpQtVl, 1)
	M->BCY_CODINT := cCodInt
	M->BCY_CODPRO := cCodPro
	M->BCY_ANOREF := cAnoRef
	M->BCY_MESREF := cMesRef
	
	If nTpMeta == 1
		M->BCY_EQUIPE := "999"
		M->BCY_CODVEN := "999999"
	ElseIf nTpMeta == 2
		M->BCY_CODVEN := "999999"
	ElseIf nTpMeta == 3
		M->BCY_EQUIPE := "999"
	EndIf
	
Else

   Copy "BCY" TO Memory 
   If nOpc == K_Alterar .Or. nOpc == K_Excluir
      If ! BCY->(RecLock("BCY",.F.))
         Return
      Else
         lLock := .T.
      Endif   
   Endif
Endif

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� MSMGET -> Operadora/Produto                                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

cAlias:="BCY"
nReg:=BCY->(RecNo())
oEncBCY := MSMGet():New(cAlias,nReg,nOpcx,,,,,{015,005,150,350},,,,,,oDlgFolder,,,.F.)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Ativa o dialogo...                                                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder,{|| If( P421TudoOk(nOpcx, oEncBCY) ,(PlsEndBrw(),nOpca := 1,oDlgFolder:End()),.F.)},{|| PlsEndBrw(), nOpca :=2 , oDlgFolder:End() },K_MsgDel)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Trata atualizacao dos dados...                                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If nOpca == K_OK
  
   If nOpcx <> K_Visualizar 
      //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
      //� Operadora+Produto                                                   �
      //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
      PLUPTENC("BCY",nOpc,!lLock)

   Endif   

Endif

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Fim da Rotina Principal...                                          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

Return

// Funcao para o top do filtro da mbrowse
Function PLSA421Top()
Return (xFilial("BCY")+Str(nTpMeta,1))

// Funcao para o bottom do filtro da mbrowse
Function PLSA421Bot()
Return (xFilial("BCY")+Str(nTpMeta,1))

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � P421TudoOk � Autor � Paulo Carnelossi    � Data � 08/09/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Faz a checagem dos campos e pastas obrigatorias            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � P421Tudook(nOpc)                                           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� nOpc - Opcao do aRotina                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function P421TudoOk(nOpc, oEncBCY)
Local lRet := .T.

BCY->(DbSetOrder(1))
BCY->(DbSeek(xFilial("BCY")+M->BCY_TPMETA+M->BCY_CODINT+M->BCY_CODPRO+M->BCY_EQUIPE+M->BCY_CODVEN+M->BCY_ANOREF+M->BCY_MESREF))

If nOpc == K_Incluir .and. !BCY->(Eof()) // SE FOR INCLUSAO VERIFICA SE O CODIGO JA ESTA GRAVADO NO ARQUIVO E NAO DEIXA CONTINUAR
   Help("",1,"JAGRAVADO")
   lRet := .F.
EndIf

If lRet .And. ! Obrigatorio(oEncBCY:aGets, oEncBCY:aTela)
	lRet := .F.
EndIf

If lRet .And. If(M->BCY_TPQTVL = "1", M->BCY_QUANT <= 0, M->BCY_VALOR <= 0)
   MsgStop("Quantidade ou valor dever� ser positivo, favor corrigir!")
	lRet := .F.
EndIf


Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砅LSA421IMP篈utor  砅aulo Carnelossi    � Data �  08/09/2003 罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矷mpressao do Cadastro de Metas de Vendas                    罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP                                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PLSA421IMP(cAlias,nReg,nOpc)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define Variaveis                                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Local wnrel
Local cDesc1 := "Este programa tem como objetivo imprimir o cadastro"
Local cDesc2 := "de metas de vendas"
Local cDesc3 := ""
Local cString := "BCY"
Local Tamanho := "G"

PRIVATE cTitulo:= "Cadastro de Metas de Vendas"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private cPerg   := "PLR421"
Private nomeprog:= "PLSA421" 
Private nLastKey:=0

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Definicao dos cabecalhos                                     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
//                 1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2  
//        1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
cabec1:= "Tp Meta         Operadora                           Plano                                             Equipe                        Vendedor                      Qtd/Vlr           Valor     Qtde"
cabec2:= ""

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Envia controle para a funcao SETPRINT                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
wnrel := "PLS421"

Pergunte(cPerg, .F.)

wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)

If nLastKey == 27
   Return
End

SetDefault(aReturn,cString)

If nLastKey == 27
   Return ( NIL )
End

RptStatus({|lEnd| ImpMetaVenda(@lEnd,wnRel,cString)},cTitulo)

dbSelectArea(cAlias)
dbGoto(nReg)

Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪哪履哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北� Fun噮o    � ImpMetaVenda� Autor � Paulo Carnelossi   � Data � 08/09/03 潮�
北媚哪哪哪哪哪拍哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北� Descri噮o � Impressao Cadastro de Metas de Vendas                      潮�
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北� Sintaxe   � ImpMetaVenda(lEnd,wnRel,cString)                             潮�
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北� Uso       �                                                            潮�
北媚哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
Static Function ImpMetaVenda(lEnd,wnRel,cString)
Local cbcont,cbtxt
Local tamanho:= "G"
Local nTipo 

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

nTipo:=GetMv("MV_COMP")

dbSelectArea("BCY")
SetRegua(RecCount())
dbGotop()
lTitulo := .T.

While BCY->(! Eof())

      If BCY->BCY_CODINT != mv_par01 .Or. ;
      	BCY->BCY_MESREF != Left(mv_par02,2) .Or. ;
      	BCY->BCY_ANOREF != Right(mv_par02,4) .Or. ;
      	BCY->BCY_CODPRO <  mv_par03 .OR. ;
      	BCY->BCY_CODPRO >  mv_par04
      	BCY->(dbSkip())
      	Loop
      EndIf	
		
		IncRegua()

		IF li > 58
			cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		End
		
	   @ li, 000 PSay Padr(X3COMBO("BCY_TPMETA", BCY->BCY_TPMETA),15)
	   @ li, 016 PSay Padr(BCY->BCY_CODINT+"-"+Posicione("BA0",1,xFilial("BA0")+BCY->BCY_CODINT,"BA0_NOMINT"),29)
	   @ li, 052 PSay Padr(BCY->BCY_CODPRO+"-"+Posicione("BI3",1,xFilial("BI3")+BCY->(BCY_CODINT+BCY_CODPRO),"BI3_DESCRI"),49)
	   @ li, 102 PSay Padr(BCY->BCY_EQUIPE+"-"+Posicione("BWN",1,xFilial("BWN")+BCY->BCY_EQUIPE,"BWN_NOME"),29)
	   @ li, 132 PSay Padr(BCY->BCY_CODVEN+"-"+Posicione("SA3",1,xFilial("SA3")+BCY->BCY_CODVEN,"A3_NOME"),29)
	   @ li, 162 PSay Padr(X3COMBO("BCY_TPQTVL", BCY->BCY_TPQTVL),10)
	   @ li, 180 PSay BCY->BCY_VALOR
	   @ li, 190 PSay BCY->BCY_QUANT

		li++
		
   	
   	BCY->(dbSkip())

End

IF li != 80
	roda(cbcont,cbtxt,tamanho)
End
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Recupera a Integridade dos dados                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
dbSelectArea("BCY")

Set Device To Screen

If aReturn[5] = 1
   Set Printer To
	dbCommitAll()
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return


//---------------------------------------------------------------------------------//
Function A421_F3BI3()   // funcao para setar varmem para sxb
M->BWR_CODINT := M->BCY_CODINT
Return(! Empty(M->BCY_CODINT))
//---------------------------------------------------------------------------------//
Function A421_Rel()    // funcao para setar varmem para sxb
M->BWR_CODINT := mv_par01
Return(! Empty(mv_par01))
//---------------------------------------------------------------------------------//
Function A421_PergI()    // funcao para setar varmem para sxb
M->BWR_CODINT := mv_par03
Return(! Empty(mv_par03))
//---------------------------------------------------------------------------------//

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Darcio R. Sporl       � Data �04/01/2007潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Utilizacao de menu Funcional                               潮�
北�          �                                                            潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矨rray com opcoes da rotina.                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砅arametros do array a Rotina:                               潮�
北�          �1. Nome a aparecer no cabecalho                             潮�
北�          �2. Nome da Rotina associada                                 潮�
北�          �3. Reservado                                                潮�
北�          �4. Tipo de Transa噭o a ser efetuada:                        潮�
北�          �		1 - Pesquisa e Posiciona em um Banco de Dados           潮�
北�          �    2 - Simplesmente Mostra os Campos                       潮�
北�          �    3 - Inclui registros no Bancos de Dados                 潮�
北�          �    4 - Altera o registro corrente                          潮�
北�          �    5 - Remove o registro corrente do Banco de Dados        潮�
北�          �5. Nivel de acesso                                          潮�
北�          �6. Habilita Menu Funcional                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function MenuDef()
Private aRotina := {	{ STRPL01		,'AxPesqui'		, 0 , K_Pesquisar 	, 0, .F.},;
                   		{ STRPL02	,'PLS421Mov'	, 0 , K_Visualizar	, 0, Nil},;
                   		{ STRPL03			,'PLS421Mov'	, 0 , K_Incluir   	, 0, Nil},;
                   		{ STRPL04			,'PLS421Mov'	, 0 , K_Alterar   	, 0, Nil},;
                     	{ STRPL05			,'PLS421Mov'	, 0 , K_Excluir   	, 0, Nil},;
                     	{ "imprimir"		,'PLSA421IMP'	, 0 , K_Alterar 		, 0, Nil} }
Return(aRotina)