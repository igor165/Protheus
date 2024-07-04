#INCLUDE "PLSA300.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "COLORS.CH"
#include "TCBROWSE.CH"
#include "JPEG.CH"
                                                                                                                
#define K_Agenda  	1
#define K_Editar  	2
#define K_Cancel  	3
#define K_Remarca 	4
#define K_Marcar  	5
#define K_Encaixe 	6
#define K_Sair     7

Static aInd := {}
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA300 ³ Autor ³ Geraldo Felix Junior  ³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Agenda Medica - Versao 8.11                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA300(cMatric, cNomUsr, cMatAnt, cTelUsr ,cAterna)
Local aArea		 := GetArea()	// Salva a area atual
PRIVATE lMultLoc  := .F.
PRIVATE inclui	  := .F.
PRIVATE Altera	  := .T.
PRIVATE lForcaUsr := .F.
PRIVATE lForcaPro := .F.
PRIVATE lForcado  := .F.
PRIVATE aAutFor   := {}
PRIVATE lMove	    := .F.
PRIVATE aRotina   := MenuDef()
PRIVATE lBBD_TIPPAC := BBD->(FieldPos("BBD_TIPPAC")) > 0
PRIVATE lBBD_ATERNA := BBD->(FieldPos("BBD_ATERNA")) > 0
PRIVATE lBBO_ATERNA := BBO->(FieldPos("BBO_ATERNA")) > 0
PRIVATE lBBD_DATCAN := BBD->(FieldPos("BBD_DATCAN")) > 0
DEFAULT cAterna   := "0"
/**/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a criacao do registro para o usuario/operador logado...         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectarea("BBO")
BB0->(dbSetorder(01))
If ! BBO->(MsSeek(xFilial("BBO")+StrZero(Val(RetCodUsr()),6)))
   BBO->(RecLock("BBO",.T.))
   BBO->BBO_FILIAL := xFilial("BBO")
   BBO->BBO_CODUSR := StrZero(Val(RetCodUsr()),6)
   BBO->BBO_CODESP := "001"   
   BBO->BBO_CODINT := PLSINTPAD()                             
   BBO->BBO_DATA   := Date()
   BBO->(MsUnLock())
Else
   BBO->(RecLock("BBO",.F.))
   BBO->BBO_DATA := Date()
   
   If Empty(BBO->BBO_CODESP)
      BBO->BBO_CODESP := "001"
   Endif                     
   
	BBO->BBO_CODPAC 	:= CriaVar("BBO_CODPAC")
	BBO->BBO_NOME	    := CriaVar("BBO_NOME")
	BBO->BBO_TELEFO		:= CriaVar("BBO_TELEFO")
	BBO->BBO_MATANT		:= CriaVar("BBO_MATANT")
	BBO->BBO_NOMEMP		:= CriaVar("BBO_NOMEMP")
	BBO->BBO_USRFRC 	:= ''

	If lBBO_ATERNA//BBO->( FieldPos("BBO_ATERNA") ) > 0
	   BBO->BBO_ATERNA := "0"
	EndIf
		   
   If Empty(BBO->BBO_CODINT)
      BBO->BBO_CODINT := PLSINTPAD()
   Endif   
   BBO->(MsUnLock())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao existir, cria com dados default e caso existe copia para a memoria³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BBO->(RegToMemory("BBO",.F.))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa rotina que prepara ambiente para rodar a agenda medica...        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PLSA300Pre(M->BBO_CODINT,M->BBO_DATA,;
                                    M->BBO_CODESP,;
                                    M->BBO_DESMUN,M->BBO_ESTADO,;
                                    M->BBO_BAIRRO,M->BBO_CODPRO,;
                                    M->BBO_CODLOC,M->BBO_CODCRE, cMatric, cNomUsr, cMatAnt, cTelUsr ,cAterna)//,;M->BBO_SUBESP)
DbSelectArea("SA1")
RestArea(aArea)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA300PRE ³ Autor ³Geraldo Felix Junior³ Data ³ 20.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ A partir da rotina que recebe os parametros chama as      ³±±
±±³          ³ subs-rotinas necessarias para a montagem da agenda        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Geraldo JR. ³        |      | Versao 8.11                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSA300Pre(cCodInt,dData,cCodEsp,;
                    cDesMun,cEstado,cBairro,;
                    cCodPro,cLocal,cCodCre,cMatric,;
                    cNomUsr, cMatAnt, cTelUsr,cAterna)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis locais...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cInd      := CriaTrab(nil,.F.)
LOCAL aRetorno  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o dia...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cAno		:= Alltrim(Str(Year( dData)))
LOCAL cDia		:= Alltrim(Str(Dow(  dData)))
LOCAL cMes		:= StrZero(Month(dData),2)
LOCAL cDiaMes	:= StrZero(Day(  dData),2) 
DEFAULT cAterna := "0"

PRIVATE cCadastro := STR0001 //"Agenda Medica"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa rotina que monta area de trabalho e variaveis para utilizacao... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRetorno := PLSA300Trb(cCodInt,dData,cCodEsp,;
                        cDesMun,cEstado,cBairro,;
                        cCodPro,cLocal,cCodCre,;
                        cInd,cCadastro)
If ! aRetorno[1]
   Return
Endif                             

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a tela com resultado...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PLSA300Src(aRetorno[2],aRetorno[3],aRetorno[4],dData,cCodEsp,;
		   cCodCre,cCodInt, cDia, cMes, cAno, cDiaMes, cMatric,;
		   cNomUsr, cMatAnt, cTelUsr,cAterna)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza as configuracoes do usuario atual...                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BBO->(PLUPTENC("BBO",K_Alterar))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA300TRB ³ Autor ³Geraldo Felix Junior³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta areas de trabalho e variaveis para ser usado pela   ³±±
±±³          ³ rotina generica de visualizacao da agenda disponivel      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSA300Trb(cCodInt,dData,cCodEsp,;
                    cDesMun,cEstado,cBairro,;
                    cCodPro,cLocal,cCodCre,;
                    cInd,cCadastro)
                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cSQL     	
LOCAL cBB7Name 	:= BB7->(RetSQLName("BB7"))
LOCAL cBAUName 	:= BAU->(RetSQLName("BAU"))
LOCAL cBA0Name 	:= BA0->(RetSQLName("BA0"))
LOCAL cBB8Name 	:= BB8->(RetSQLName("BB8"))
LOCAL cBAQName 	:= BAQ->(RetSQLName("BAQ"))
LOCAL cBAXName 	:= BAX->(RetSQLName("BAX"))
LOCAL cBBIName 	:= BBI->(RetSQLName("BBI"))
LOCAL lCodPro  	:= !Empty(cCodPro)                                           
LOCAL aColunas 	:= {}
LOCAL cDbTipo  	:= AllTrim(TCGetDB())
LOCAL lEof	   	:= .F.   
LOCAL nCnt 		:= 1
LOCAL cAno		:= Alltrim(Str(Year( dData)))
LOCAL cDia		:= Alltrim(Str(Dow(  dData)))
LOCAL cMes		:= StrZero(Month(dData),2)
LOCAL cDiaMes	:= StrZero(Day(  dData),2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define query...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos do BB7 - Tabela principal...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BB7_FILIAL, BB7_CODIGO, BB7_HORENT, BB7_HORSAI, BB7_EXCINI, BB7_EXCFIN, BB7_CODESP,BB7_INTERV,"
cSQL += "BB7_CODINT, BB7_CODLOC, BB7_ANO, BB7_MES, BB7_DIA, BB7_DIAMES, BB7_PLTINI, BB7_PLTFIN, BB7_OBSDIA,"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Relaciona nome do prestador/medico...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BAU_FILIAL, BAU_CODIGO, BAU_LEGEND, BAU_NOME, "+cBAUName+".R_E_C_N_O_ AS REGBAU, "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Relaciona Operadora  ...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BA0_FILIAL, BA0_CODIDE, BA0_CODINT, BA0_NOMINT, "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Relaciona localidade...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BB8_FILIAL, BB8_CODINT, BB8_CODLOC, BB8_LOCAL, BB8_DESLOC, BB8_TMPCON, "
cSQL += "BB8_END, BB8_NR_END, BB8_MUN, BB8_BAIRRO, BB8_TEL, "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Relaciona especialidade...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BAQ_FILIAL, BAQ_CODESP, BAQ_DESCRI, "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Relaciona especialidade do credenciado...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BAX_DATINC, BAX_DATBLO "
cSQL += "FROM "
cSQL += cBB7Name+", "
cSQL += cBAUName+", "
cSQL += cBA0Name+", "
cSQL += cBB8Name+", "
cSQL += cBAQName+", "

If lCodPro
   cSQL += cBAXName+", "
   cSQL += cBBIName+" WHERE "
Else
   cSQL += cBAXName+" WHERE "   
Endif   

cSQL += cBB7Name+".D_E_L_E_T_ = ' ' AND BB7_FILIAL = '"+xFilial("BB7")+"' AND "
cSQL += cBAUName+".D_E_L_E_T_ = ' ' AND BAU_FILIAL = '"+xFilial("BAU")+"' AND "
cSQL += cBA0Name+".D_E_L_E_T_ = ' ' AND BA0_FILIAL = '"+xFilial("BA0")+"' AND "
cSQL += cBB8Name+".D_E_L_E_T_ = ' ' AND BB8_FILIAL = '"+xFilial("BB8")+"' AND "
cSQL += cBAQName+".D_E_L_E_T_ = ' ' AND BAQ_FILIAL = '"+xFilial("BAQ")+"' AND "
cSQL += cBAXName+".D_E_L_E_T_ = ' ' AND BAX_FILIAL = '"+xFilial("BAX")+"' AND "
If lCodPro
   cSQL += cBBIName+".D_E_L_E_T_ = ' ' AND BBI_FILIAL = '"+xFilial("BBI")+"' AND "
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Where relacao BB7 X Credenciado (BAU)...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BAU_CODIGO = BB7_CODIGO AND "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Where relacao BB7 X Operadora   (BA0)...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BA0_CODIDE+BA0_CODINT = BB7_CODINT AND "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Where relacao BB7 X Local Atend. (BB8)...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BB8_CODIGO = BB7_CODIGO AND "
cSQL += "BB8_CODINT = BB7_CODINT AND "
cSQL += "BB8_CODLOC = BB7_CODLOC AND "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Where relacao BB7 X Especialidade (BAQ)...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BAQ_CODESP = BB7_CODESP AND "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Where relacao BB7 X Especialidade do credenciado (BAX)...                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BAX_CODIGO = BAU_CODIGO AND "
cSQL += "BAX_CODESP = BB7_CODESP AND "
cSQL += "BAX_DATINC <= '"+dtos(dData)+"'AND "
If cDbTipo == "ORACLE"
	cSQL += "BAX_DATBLO = '        ' AND "                          
Else
	cSQL += "BAX_DATBLO = '' AND "                          
Endif
cSQL += "BAX_CODINT = BB7_CODINT AND "
cSQL += "BAX_CODLOC = BB7_CODLOC AND "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta where do arquivo principal BB7...                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BB7_CODINT = '"+cCodInt+"' AND "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata dia pedido...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BB7_DIA    = '"+cDia+"' AND "
cSQL += "BB7_MES    = '"+cMes+"' AND "
cSQL += "BB7_ANO    = '"+cAno+"' AND "
cSQL += "BB7_DIAMES = '"+cDiaMes+"' AND "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata localidade...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty(cLocal)
   cSQL += "BB8_LOCAL = '"+AllTrim(cLocal)+"' AND "
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata municipio....                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty(cDesMun)
   cSQL += "BB8_MUN = '"+AllTrim(cDesMun)+"' AND "
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata bairro...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty(cBairro)
   cSQL += "BB8_BAIRRO = '"+AllTrim(cBairro)+"' AND "
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata estado...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty(cEstado)
   cSQL += "BB8_EST = '"+AllTrim(cEstado)+"' AND "
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata codigo do credenciado...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty(cCodCre)
   cSQL += "BB7_CODIGO = '"+AllTrim(cCodCre)+"' AND "
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata somente credenciados que possuem o produto informado...            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCodPro
   cSQL += "BBI_CODIGO = BB7_CODIGO AND "
   cSQL += "BBI_CODPRO = '"+cCodPro+"' AND "
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata somente codigo da especialidade informada...                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty(cCodEsp)
   cSQL += "BB7_CODESP = '"+cCodEsp+"' AND "
Endif                                 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza construcao da query...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := Subs(cSQL,1,Len(cSQL)-4)
cSQL += "ORDER BY "+PlsSQLOrd(BB7->(IndexKey()))
PLSQuery(cSQL,"Trba300")

aInd := {}                 
Trba300->( dbEval({|| Aadd(aInd, {	BB7_FILIAL,;	// 01
									BB7_CODIGO,;	// 02
									BB7_HORENT,;	// 03
									BB7_HORSAI,;	// 04
									BB7_EXCINI,;	// 05
									BB7_EXCFIN,;	// 06
									BB7_CODESP,;	// 07
									BB7_INTERV,;	// 08
									BB7_CODINT,;	// 09
									BB7_CODLOC,;	// 10
									BB7_ANO,;		// 11
									BB7_MES,;		// 12
									BB7_DIA,;		// 13
									BB7_DIAMES,;	// 14
									BB7_PLTINI,;	// 15
									BB7_PLTFIN,;	// 16
									BB7_OBSDIA,;	// 17
									BAU_FILIAL,;	// 18
									BAU_CODIGO,;	// 19
									BAU_LEGEND,;	// 20
									BAU_NOME,;		// 21
									REGBAU,;		// 22
									BA0_FILIAL,;	// 23
									BA0_CODIDE,;	// 24
									BA0_CODINT,;	// 25
									BA0_NOMINT,;	// 26
									BB8_FILIAL,;	// 27
									BB8_CODINT,;	// 28
									BB8_CODLOC,;	// 29
									BB8_LOCAL,;		// 30
									BB8_DESLOC,;	// 31
									BB8_TMPCON,;	// 32
									BB8_END,;		// 33
									BB8_NR_END,;	// 34
									BB8_MUN,;		// 35
									BB8_BAIRRO,;	// 36
									BB8_TEL,;		// 37
									BAQ_FILIAL,;	// 38
									BAQ_CODESP,;	// 39
									BAQ_DESCRI,;	// 40
									BAX_DATINC,;	// 41
									BAX_DATBLO})}))	// 42
								
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta todas as localidades existentes...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCnt := 1 To Len(aInd)
	If ( Ascan(aColunas, {|x|	x[1] == aInd[nCnt][30] .and.;
		 						x[2] == aInd[nCnt][31] .and.;
								x[3] == aInd[nCnt][33] .and.;
								x[4] == aInd[nCnt][34] .and.;
								x[5] == aInd[nCnt][35] .and.;
								x[6] == aInd[nCnt][36] .and.;
								x[7] == aInd[nCnt][37] }) ) == 0
	
		aadd(aColunas,{	aInd[nCnt][30],;
						aInd[nCnt][31],;
						aInd[nCnt][33],;
						aInd[nCnt][34],;
						aInd[nCnt][35],;
						aInd[nCnt][36],;
						aInd[nCnt][37]})
	Endif
Next

DbSelectArea("BA1")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao exista pelo menos uma coluna eu incluo uma na mao...            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aColunas) == 0
	aadd(aColunas,{"","","","","","",""})
	lEof := .T.	
Elseif Len(aColunas) > 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa tratamento de multiplos locais de atendimento.                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lMultLoc := .T.
Endif                
Trba300->( dbCloseArea() )

Return({.T.,aColunas,cCadastro,cInd, lEof})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA300SRC ³ Autor ³Geraldo Felix Junior³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta a tela de acordo com os parametros informados       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSA300Src(aColunas,cCadastro,cInd,dData,cCodEsp,cCodCre,cCodInt,cDia, cMes, cAno, cDiaMes,cMatric, cNomUsr, cMatAnt, cTelUsr,cAterna)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis de tela...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cHorSel   := ""                     
LOCAL cDesEsp	:= ""
LOCAL cMedico	:= ""
LOCAL nDsPer    := GetNewPar("MV_PLDSCAG",30)//Dias para agendamento de consultas mesma especial
LOCAL cCodPro	:= GetNewPar("MV_PLSCDCO","0110101012")//Codigo padrao da consulta Agenda Medica
LOCAL nTime     := GetNewPar("MV_PLSTAGE",60)//Tempo para agendar uma consulta
LOCAL aDados    := {}
LOCAL aOcupacao := {}
LOCAL aItems    := {}
LOCAL aMedRec   := {}    
LOCAL aMedHor   := {}
LOCAL aRet		:= {}
LOCAL aCampos	:= {}
LOCAL aFields	:= {}
LOCAL aButtons	:= {}
LOCAL aListaUsr := { {"","","",0,.T.,"","",""} }

LOCAL oBrowse
LOCAL oDlgPes
LOCAL oCol        
LOCAL oBot01
LOCAL oBot02
LOCAL oBot04
LOCAL oSay
LOCAL oSayHor
LOCAL oGrupo
LOCAL oListLoc       
LOCAL oListMed
LOCAL oFont01 
LOCAL oGrpHo
LOCAL oGrpMe
LOCAL oListaUsr
LOCAL oTimerBrw
LOCAL oCorLiv   := CLR_BLACK
LOCAL oCorOcu   := CLR_HRED 
LOCAL lMens		:= .F.
LOCAL bPesquisa := { || a := PLSA300Pes(), If(a[3],(BBD->(DbGoTo(a[4])), ;
                         M->BBO_DATA   := BBD->BBD_DATA, ;
                         M->BBO_DIASEM := CriaVar("BBO_DIASEM"),;
                         M->BBO_CODLOC := BBD->BBD_LOCAL,;
                         M->BBO_LOCAL  := CriaVar("BBO_LOCAL"),;
                         M->BBO_CODESP := BBD->BBD_CODESP,;      
                         M->BBO_DESESP := Posicione("BAQ",1,xFILIAL("BAQ")+BBD->BBD_CODINT+M->BBO_CODESP,"BAQ_DESCRI"),;
                         M->BBO_CODCRE := BBD->BBD_CODIGO,;
                         M->BBO_NOMCRE := Posicione("BAU",1,xFilial("BAU")+M->BBO_CODCRE,"BAU_NOME"),;
                         M->BBO_CODINT := BBD->BBD_CODINT,;
                         oHorarios:nAt := 1,;
                         Eval(bVetAge),;
						 oEnc:oBox:Refresh(),;
                         Eval(bFiltro),;
                         nPos := AsCan(aHorAge,{|x| StrTran(x[2],":","") = StrTran(a[2],":","")}),;
                         cHorSel := a[2],;
                         Iif(nPos > 0, oHorarios:nAt := nPos, NIL),;
                         oHorarios:Refresh(), oHorarios:SetFocus() ),oHorarios:SetFocus()) }        

LOCAL bClick    := { || Pls300DisableKeys(),;           
						lRet := PLSA300Sel(oBrowse,oListMed,aColunas,aDados,aOcupacao,;	
                        					 dData,cCodEsp,cDesEsp,cCodInt,cInd,aMedRec,cPictPad,oDlgPes,;
					                         aItems,nOpcao,nDsPer,oListLoc:nAt, aMedHor,, aHorage, oHorarios,;
					                         bVetAge, cCodPro,oListLoc:aArray[oListLoc:nAt][1]), ;  
					                         oHorarios:SetFocus(),;
	                     Pls300EnableKeys(oListLoc, oEnc, bFiltro, nDsPes, dData, aListaUsr,;
                                          nOpcao, oDlgPes, bClick, oHorarios, bVetAge, oBrowse,cCodEsp,oListaUsr,nDsPer) }
                                    
LOCAL bMontVet  := { || PLSA300VET(aColunas,cInd,aDados,aOcupacao,aMedHor,M->BBO_DATA,M->BBO_CODINT,oListLoc,cDia,cDiaMes,cMes,cAno,oListMed) }
LOCAL bVetAge	:= { || cCodEsp :=M->BBO_CODESP,PLSA300Age(aColunas,cCodInt,{},dData,oListLoc,cCodEsp,cDia,cDiaMes,cMes,cAno)}
LOCAL bMonObj   := { || MsBrGetDbase():New( 045, 204, 045, 205,,,, oDlgPes,,,,,,,,,,,, .F.,, .T.,, .F., ) }
LOCAL bBrwCol   := { || x:=''}
LOCAL bChange   := { || x:= ''}
LOCAL cPictPad  := "@R !!:!!"
LOCAL nCor		:= 1
Local aSize 	:= MsAdvSize()
Local aObjects 	:= {}       
Local aObjects2	:= {}
Local aObjects3	:= {}
Local aObjects4	:= {}
Local aObjects5	:= {}
Local aObjects6	:= {}
Local aInfo 	:= {}
Local aInfo2 	:= {}
Local aInfo3 	:= {} 
Local aInfo4 	:= {}
Local aInfo5 	:= {}
Local aInfo6 	:= {}
Local aPosObj 	
Local aPosObj2	
Local oPanel
Local oPainelEchoice
Local nHRes		:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor  
Local nVRes  	:=	oMainWnd:nClientHeight //Resolucao vertial do monitor
LOCAL nLinI     := 8
LOCAL nColI     := 5
LOCAL nLinF     := -8
LOCAL nColF     := -5
LOCAL lR5     	:= GetRpoRelease("R5") //Indica se o release e 11.5
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCombo	  	:= ""
PRIVATE cComboEsp   := ""
PRIVATE nDsPes    	:= GetNewPar("MV_PLDSPES",60)//Dias na pesquisa da proxima data de agenda medica 
PRIVATE n         	:= 1

PRIVATE aTela     	:= {}
PRIVATE aGets     	:= {}
PRIVATE aCols     	:= {}
PRIVATE aHeader   	:= {}
PRIVATE aVetMar   	:= {}
PRIVATE aHorAge	  	:= {}
PRIVATE aCombo 		:= {}
PRIVATE aMedDis		:= {}

PRIVATE lRefresh  	:= .F.
PRIVATE lMarcar   	:= .T.
PRIVATE lFocoBrw	:= .F.
PRIVATE lEncaixe	:= .F.
PRIVATE lByPass		:= .T.
PRIVATE nOpcao 		:= 0
PRIVATE oSinal
PRIVATE oEnc
PRIVATE oSay1
PRIVATE oSay2
PRIVATE oSay3
PRIVATE oSay4
PRIVATE oSay5
PRIVATE oSayMed
PRIVATE bFiltro		:= { || cCodInt	:= M->BBO_CODINT,;
							dData 	:= M->BBO_DATA,;
							PLSA300Ajc(cCodInt,dData,M->BBO_CODESP,M->BBO_DESMUN,M->BBO_ESTADO,M->BBO_BAIRRO,;
			         					M->BBO_CODPRO,M->BBO_CODLOC,M->BBO_CODCRE,cInd,cCadastro,aColunas,;
			                         	aDados,aOcupacao,oBrowse,oDlgPes,bChange,bClick,;
            			             	oCorOcu,oCorLiv,aMedHor,bBrwCol,bMontVet,oListMed,;
			                         	aItems, oListLoc, bVetAge, oHorarios, @cMedico)}                         
                         
PRIVATE bSeekBB7	:= { |cCodInt,cCodLoc,cCodEsp,cDia, cMes, cAno, cDiaMes| BB7->(DbSetOrder(4)), BB7->(MsSeek(xFilial("BB7")+;
                         	cCodInt+cAno+cMes+cCodLoc+cCodEsp+Space(03)+cDiaMes)) }                           
PRIVATE bAtuFil   	:= {|a,b| If(Eval(bFiltro),.T.,.T.) }
PRIVATE oBmpBol
DEFAULT cAterna     := "0"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define fonte para mensagem...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ              
DEFINE FONT oFont01 NAME "Arial" SIZE 0,-12 BOLD
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca a descricao da especialidade...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDesEsp  := Posicione("BAQ",1,xFilial("BAQ")+cCodInt+cCodEsp,"BAQ_DESCRI") 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campos dos parametros...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCampos, "BBO_DATA")
Aadd(aCampos, "BBO_DIASEM")
Aadd(aCampos, "BBO_CODESP")
Aadd(aCampos, "BBO_DESESP")
Aadd(aCampos, "BBO_CODLOC")
Aadd(aCampos, "BBO_LOCAL")
Aadd(aCampos, "BBO_CODCRE")
Aadd(aCampos, "BBO_NOMCRE")
Aadd(aCampos, "BBO_CODINT")
Aadd(aCampos, "BBO_DESINT")         
Aadd(aCampos, "BBO_USRFRC")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Lado esquerdo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
aObjects := {}

AAdd( aObjects, { nVRes*0.30, 050, .F. , .F.} ) //box1
AAdd( aObjects, { nVRes*0.30, 030, .F. , .F.} ) //espaco para botoes 
AAdd( aObjects, { nVRes*0.30, 040, .F. , .F.} ) //box2
AAdd( aObjects, { nVRes*0.30, 040, .F. , .T.} ) //box1


				//LI    //CI      //LF     //CF
aInfo 	 := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
aPosObj1 := MsObjSize( aInfo, aObjects,.F.,.F. )

   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ lado direito
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
aObjects2 := {}
AAdd( aObjects2, { nVRes, 025, .t., .f.} ) //box rda
AAdd( aObjects2, { nVRes, 100, .t., .t.} ) //box data

				//LI    	  //CI     //LF      //CF
aInfo  	 := { aPosObj1[1][4],aSize[2],aSize[3],aSize[4], 3, 3 }
aPosObj2 := MsObjSize( aInfo, aObjects2, .f., .f. )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo da pesquisa...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgPes TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] of oMainWnd Pixel  

@ aPosObj1[1][1],aPosObj1[1][2] GROUP oGrpLoc TO aPosObj1[1][3]+25, aPosObj1[1][4] PIXEL OF oDlgPes LABEL STR0002  COLOR CLR_HBLUE, CLR_HRED //"Locais de Atendimento - < CTRL + A >"

nColI := 3 
nLinF := -10
nColF := iIf(lR5,-15,-25)

oListLoc := TcBrowse():New( aPosObj1[1][1]+8, aPosObj1[1][2]+2, aPosObj1[1][4]-8, aPosObj1[1][3]-24,,,, oDlgPes,,,,,,,,,,,, .F.,, .T.,, .F., )

nColI := 5 
nLinF := -15  
nColF := -5

	oListLoc:AddColumn(TcColumn():New(STR0003,nil,; //"Local"
	nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))
	oListLoc:ACOLUMNS[1]:BDATA     := { || aColunas[oListLoc:nAt,1] }
	oListLoc:AddColumn(TcColumn():New(STR0004,nil,; //"Descricao"
	nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))
	oListLoc:ACOLUMNS[2]:BDATA     := { || aColunas[oListLoc:nAt,2] }
	oListLoc:AddColumn(TcColumn():New(STR0005,nil,; //"Telefone"
	nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))
	oListLoc:ACOLUMNS[3]:BDATA     := { || Alltrim(aColunas[oListLoc:nAt,7])}
	oListLoc:AddColumn(TcColumn():New(STR0006,nil,; //"Endereco"
	nil,nil,nil,nil,100,.F.,.F.,nil,nil,nil,.F.,nil))
	oListLoc:ACOLUMNS[4]:BDATA     := { || Alltrim(aColunas[oListLoc:nAt,3])+", "+Alltrim(aColunas[oListLoc:nAt,4]) }
	oListLoc:AddColumn(TcColumn():New(STR0007,nil,; //"Municipio"
	nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	oListLoc:ACOLUMNS[5]:BDATA     := { || Alltrim(aColunas[oListLoc:nAt,5])}
	oListLoc:AddColumn(TcColumn():New(STR0008,nil,; //"Bairro"
	nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))
	oListLoc:ACOLUMNS[6]:BDATA     := { || Alltrim(aColunas[oListLoc:nAt,6])}
	
	oListLoc:BLDBLCLICK := {|| Eval(bMontVet),Eval(bAtuFil),oHorarios:SetFocus()}
	
	oListLoc:SetArray(aColunas)

//Grupo para os botoes <<,<,>,>>
@ aPosObj1[2,1]+25,aPosObj1[2,2] GROUP oGrupo TO aPosObj1[2,3]+15,aPosObj1[2,4] PIXEL OF oDlgPes LABEL "" COLOR CLR_HBLUE, CLR_HRED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o combobox com a lista de medicos                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPosObj2[1,1], aPosObj2[1,2] GROUP oGrupo TO aPosObj2[1,3], aPosObj2[1,4] PIXEL OF oDlgPes LABEL STR0052 COLOR CLR_HBLUE, CLR_HRED //" RDA Seleccionada - < CTRL + B >           Ver Mensagem - < CTRL + M >"

If Len(aCombo) > 0
	cCombo 		:= aCombo[1,1]+" - "+aCombo[1,2]
	cCobboEsp   := aCombo[1,4]
	lMens 		:= Iif(!Empty(aCombo[1,5]),.T.,.F.)	
Endif                 

nLinI := 10
@ aPosObj2[1,1]+nLinI, aPosObj2[1,2]+nColI Say oSayMed Prompt cCombo Size 300, 10 PIXEL OF oDlgPes FONT oFont01 COLOR CLR_HRED
                                                                
@ aPosObj2[2,1], aPosObj2[2,2] GROUP oGrupo TO aPosObj2[2,3], aPosObj2[2,4] PIXEL OF oDlgPes LABEL STR0009+dtoc(M->BBO_DATA)+" " COLOR CLR_HBLUE, CLR_HRED //" Data do Dia - "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta horarios do medico selecionado...                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPosObj2[2,1]+nLinI, aPosObj2[2,2]+nColI Say oSay Prompt "< CTRL + C >" Size 100, 10 PIXEL OF oDlgPes COLOR CLR_HBLUE

nLinI := 8
nColI := 3 
nLinF := -200//1366/1024=200
nColF := -45//768/1024=45

oHorarios := TcBrowse():New( aPosObj2[2,1]+nLinI, aPosObj2[2,2]+nColI, aPosObj2[2,4]+nLinF, aPosObj2[2,3]+nColF,,,, oDlgPes,,,,,,,,,,,, .F.,, .T.,, .F., )

nColI := 5 
nLinF := -8
nColF := -5

//ADD COLUMN TO oHorarios BITMAP DATA "BR_BRANCO" { || Iif(Len(aHorAge)>0,PLSA315Cor(aHorAge,oHorarios),"BR_BRANCO") } TITLE "" WIDTH 015 NOHILITE

oHorarios:AddColumn(TcColumn():New(" ",{ || Iif(Len(aHorAge)>0,PLSA315Cor(aHorAge,oHorarios),"BR_BRANCO") },;
         nil,nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))

oHorarios:AddColumn(TcColumn():New(STR0010,nil,; //"Hora"
         nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))     
         oHorarios:ACOLUMNS[2]:BDATA     := { || Iif((Len(aHorAge) >= oHorarios:nAt),aHorAge[oHorarios:nAt,2], '') }         
         
oHorarios:AddColumn(TcColumn():New(STR0011,nil,; //"Paciente"
         nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil))     
        oHorarios:ACOLUMNS[3]:BDATA     := { || Iif((Len(aHorAge) >= oHorarios:nAt),aHorAge[oHorarios:nAt,4],'') } 
        
oHorarios:AddColumn(TcColumn():New(STR0005,nil,; //"Telefone"
         nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))     
         oHorarios:ACOLUMNS[4]:BDATA     := { || Iif((Len(aHorAge) >= oHorarios:nAt),aHorAge[oHorarios:nAt,5],'') }

oHorarios:AddColumn(TcColumn():New(STR0012,nil,; //"Empresa"
         nil,nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))     
         oHorarios:ACOLUMNS[5]:BDATA     := { || Iif((Len(aHorAge) >= oHorarios:nAt),aHorAge[oHorarios:nAt,14],'') }
                  
oHorarios:BLDBLCLICK   	:= {|| nOpcao := K_Agenda,Eval(bClick,oListLoc:nAt) }

oHorarios:bGotFocus		:= {|| lFocoBrw := .T.}
oHorarios:SetArray(aHorAge)         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta credenciados disponiveis...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aItems,{"","","",0,0,"",""})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botoes... ativa botoes apenas para se ter tecla de atalho... eles nao serao visiveis em tela!  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aButtons, {"PESQUISA"    	, bPesquisa ,STR0013, STR0014} ) //"Pesquisar - <ALT + P>"###"Pesquisar"
@ 001,001 BUTTON STR0015 SIZE 000,00 ACTION Eval(bPesquisa) PIXEL //"&Pesquisar"

Aadd(aButtons, {"BMPINCLUIR"   		,{ || nOpcao := K_Agenda, Eval(bClick,oListLoc:nAt), nOpcao := K_Agenda },STR0016,STR0017 } ) //"Agendar - <ALT + A>"###"Agendar"
@ 000,000 BUTTON STR0018   SIZE 000,00 ACTION { || nOpcao := K_Agenda, Eval(bClick,oListLoc:nAt), nOpcao := K_Agenda }  //"&Agendar"

Aadd(aButtons, {"BPMSDOCA"    ,{ || nOpcao := K_Editar, Eval(bClick,oListLoc:nAt), nOpcao := K_Agenda }, STR0019,STR0020 } ) //"Editar - <ALT + E>"###"Editar"
@ 000,000 BUTTON STR0021    SIZE 000,00 ACTION { || nOpcao := K_Editar, Eval(bClick,oListLoc:nAt), nOpcao := K_Agenda }  //"&Editar"

Aadd(aButtons, {"PMSRRFSH"    	,{ || nOpcao := K_Remarca,Eval(bClick,oListLoc:nAt), nOpcao := K_Agenda,lEncaixe:=.F. },STR0022, STR0023} ) //"Remarcar - <ALT + R>"###"Remarcar"
@ 000,000 BUTTON STR0024  SIZE 000,00 ACTION { || nOpcao := K_Remarca,Eval(bClick,oListLoc:nAt), nOpcao := K_Agenda,lEncaixe:=.F. }  //"&Remarcar"

Aadd(aButtons, {"CHECKED"    	,{ || nOpcao := K_Marcar , lFocoBrw := .F.,Eval(bClick,oListLoc:nAt), nOpcao := K_Agenda, lEncaixe:=.F. }, STR0025,STR0026} ) //"Marcar - <ALT + M>"###"Marcar"
@ 000,000 BUTTON STR0027    SIZE 000,00 ACTION { || nOpcao := K_Marcar , lFocoBrw := .F.,Eval(bClick,oListLoc:nAt), nOpcao := K_Agenda, lEncaixe:=.F. }  //"&Marcar"
                       
Aadd(aButtons, {"ESTOMOVI"    	,{ || nOpcao := K_Sair, Eval(bClick,oListLoc:nAt), nOpcao := K_Agenda },STR0028,STR0029} ) //"Estorna Remarcacao - <ALT + C>"###"Estornar"
@ 000,000 BUTTON STR0030  SIZE 000,00 ACTION { || nOpcao := K_Sair, Eval(bClick,oListLoc:nAt), nOpcao := K_Agenda }  //"Estorna Remar&cacao"

Aadd(aButtons, {"EXCLUIR"    	,{ || nOpcao := K_Cancel, Eval(bClick,oListLoc:nAt), nOpcao := K_Agenda },STR0031, STR0032} ) //"Desmarcar - <ALT + D>"###"Desmarcar"
@ 000,000 BUTTON STR0033  SIZE 000,00 ACTION { || nOpcao := K_Cancel, Eval(bClick,oListLoc:nAt), nOpcao := K_Agenda }  //"&Desmarcar"

Aadd(aButtons, {"BMPPARAM"    	,{||lEncaixe := .T.,nOpcao:=K_Agenda,Eval(bClick),lEncaixe:=.F. },STR0034,STR0035} ) //"Encaixe - < F12 > "###"Encaixe"
             
Aadd(aButtons, {"RELATORIO"    	, {||PL300VISCAR(cCodEsp,dData,aListaUsr,oListaUsr, nOpcao, oDlgPes, nDsPer,BBO->BBO_CODPAC,lBBO_ATERNA)},STR0036,STR0037} ) //"Carencias - <ALT + N>"###"Carencia"
@ 000,000 BUTTON STR0038 SIZE 000,00 ACTION Eval({||PL300VISCAR(cCodEsp,dData,aListaUsr,oListaUsr, nOpcao, oDlgPes, nDsPer,BBO->BBO_CODPAC,lBBO_ATERNA)})  //"Care&ncias"
                                                                                                                                      
Aadd(aButtons, {"S4WB004N"    	,{|| A300CLSUSR() },STR0039,STR0040} ) //"Limpa usuario selecionado - < F10 > "###"Usuario"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta filtros...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPosObj1[3,1]+15, aPosObj1[3,2] GROUP oGrupo TO aPosObj1[3,3]+140, aPosObj1[3,4] PIXEL OF oDlgPes LABEL STR0041  COLOR CLR_HBLUE, CLR_HRED //" Parametros de Selecao "

nLinI := 8
nColI := 1 
nLinF := -8
nColF := iIf(lR5,-156,-135)

oPainelEchoice := TPanel():New(aPosObj1[3,1]+25,aPosObj1[3,2]+2,,oDlgPes,,,,,,aPosObj1[3,4]-8,aPosObj1[3,3]-007)//ok    

nColI := 5 
nLinF := -135
nColF := -8

oEnc  := MsMGet():New("BBO" ,0 ,K_Incluir,,,,,{aPosObj1[3,1]+10,aPosObj1[3,2]+4 , aPosObj1[3,4]-6,aPosObj1[3,3]-125 },aCampos,,,,,oPainelEchoice,,,.T.,)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define timer da bolinha da mensagem do medico...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 032,378 BITMAP oBmpBol RESNAME "BR_VERMELHO" OF oDlgPes SIZE 20,20 NOBORDER WHEN .F. PIXEL
oSinal := TTimer():New( 1 ,{|| (nCor := Iif(nCor==1,2,1), Iif(nCor==1,oBmpBol:CRESNAME := "BR_VERMELHO",oBmpBol:CRESNAME := "BR_AMARELO"), oBmpBol:Refresh())},oDlgPes)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define timer para dar refresh no browse da agenda...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTimerBrw 	:= TTimer():New( nTime*1000 ,bFiltro,oDlgPes)	

If !lMens           
	oSinal:LACTIVE 			:= .F.
	oBmpBol:LVISIBLECONTROL := .F.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no primeiro dia valido  no prazo de 5 dias					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PLSA300Dat("1",oEnc,bFiltro,5,M->BBO_DATA,.T.)

@ aPosObj1[4,1]+140, aPosObj1[4,2] GROUP oGrupo TO aPosObj1[4,3], aPosObj1[4,4] PIXEL OF oDlgPes LABEL STR0042  COLOR CLR_HBLUE, CLR_HRED        //" Paciente selecionado - < F11 >"

If !Empty(cMatric)
	Reclock("BBO",.F.)
		If lBBO_ATERNA//BBO->( FieldPos("BBO_ATERNA") ) > 0
			BBO->BBO_ATERNA := cAterna
		EndIf	
		BBO->BBO_CODPAC 	:= cMatric
		BBO->BBO_NOME	    := cNomUsr
		BBO->BBO_TELEFO		:= cTelUsr
		BBO->BBO_MATANT		:= cMatAnt
	BBO->( msUnlock() )
Endif

nLinI := 150
@ aPosObj1[4,1]+nLinI, aPosObj1[4,2]+nColI Say oSay Prompt STR0011 Size 100, 10 PIXEL OF oDlgPes COLOR CLR_HBLUE //"Paciente"
nColI +=30
@ aPosObj1[4,1]+nLinI, aPosObj1[4,2]+nColI Say oSay1 Prompt BBO->BBO_CODPAC 	PICTURE "@R !.!!!.!!!!.!!!!!!-!!-!" Size 100, 10 PIXEL OF oDlgPes

If lBBO_ATERNA//BBO->( FieldPos("BBO_ATERNA") ) > 0
	nColI +=70
	@ aPosObj1[4,1]+nLinI, aPosObj1[4,2]+nColI Say oSay Prompt STR0043	Size 100, 10 PIXEL OF oDlgPes COLOR CLR_HBLUE //"Recem-Nasc."
	nColI +=40
	@ aPosObj1[4,1]+nLinI, aPosObj1[4,2]+nColI Say oSay5 Prompt AllTrim(X3COMBO("BBO_ATERNA",BBO->BBO_ATERNA))	Size 100, 10 PIXEL OF oDlgPes
EndIf
nLinI +=15
nColI := 5 
@ aPosObj1[4,1]+nLinI, aPosObj1[4,2]+nColI Say oSay Prompt STR0044				Size 100, 10 PIXEL OF oDlgPes COLOR CLR_HBLUE //"Nm. Paciente"
nColI += 35 
@ aPosObj1[4,1]+nLinI, aPosObj1[4,2]+nColI Say oSay2 Prompt BBO->BBO_NOME 	  	Size 100, 10 PIXEL OF oDlgPes

nLinI +=15
nColI := 5 
@ aPosObj1[4,1]+nLinI, aPosObj1[4,2]+nColI Say oSay Prompt STR0045				Size 100, 10 PIXEL OF oDlgPes COLOR CLR_HBLUE //"Matr Antiga "
nColI += 35 
@ aPosObj1[4,1]+nLinI, aPosObj1[4,2]+nColI Say oSay3 Prompt BBO->BBO_MATANT 	Size 100, 10 PIXEL OF oDlgPes

nColI +=70
@ aPosObj1[4,1]+nLinI, aPosObj1[4,2]+nColI Say oSay Prompt STR0005				Size 100, 10 PIXEL OF oDlgPes COLOR CLR_HBLUE //"Telefone"
nColI +=30
@ aPosObj1[4,1]+nLinI, aPosObj1[4,2]+nColI Say oSay4 Prompt BBO->BBO_TELEFO 	Size 100, 10 PIXEL OF oDlgPes

nLinI :=8
nColI :=5
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desabilita teclas...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pls300DisableKeys()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define das teclas de atalhos da marcacao de consultas...                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F4 ,((oListLoc:Refresh()),lByPass := .T.,{||PLSA300Dat("2",oEnc,bFiltro,nDsPes,M->BBO_DATA),lByPass:=.F.}))// Agenda anterior
SetKey(VK_F5 ,((oListLoc:Refresh()),lByPass := .T.,{||PLSA300Dat("1",oEnc,bFiltro,nDsPes,M->BBO_DATA),lByPass:=.F.}))// Promxima Agenda
SetKey(VK_F6 ,{||oEnc:AENTRYCTRLS[1]:SetFocus()})  										// Troca a data
SetKey(VK_F7 ,{||oEnc:AENTRYCTRLS[3]:SetFocus()})  										// Troca a especialidade
SetKey(VK_F8 ,{||oEnc:AENTRYCTRLS[5]:SetFocus()})											// Troca o medico
SetKey(VK_F9 ,{||oEnc:AENTRYCTRLS[7]:SetFocus()})											// Troca o local de atendimento
SetKey(VK_F10 ,{|| A300CLSUSR() })															// Limpa usuario selecionado.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identificacao de usuario...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F11,{||Pls300DisableKeys(),;     
				 PLSA300CALL(cCodEsp,dData,1,aListaUsr,oListaUsr,nOpcao,oDlgPes,nDsPer,oListLoc:aArray[oListLoc:nAt][1],aHorAge,oHorarios,.T.),;
                 Pls300EnableKeys(oListLoc, oEnc, bFiltro, nDsPes, dData, aListaUsr,nOpcao, oDlgPes, bClick,;
                 oHorarios, bVetAge, oBrowse,cCodEsp,oListaUsr,nDsPer)}) 					// Identificacao do paciente.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Encaixe...                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F12 ,{||lEncaixe := .T.,nOpcao:=K_Agenda,Eval(bClick),lEncaixe:=.F. }) 			// Encaixe
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Foca no browse de locais de atendimento...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				  
SetKey(1  ,{||oListLoc:SetFocus()})  							  							// Foca os locais de atendimento.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama o browse com os medicos disponiveis...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(2  ,{||If(lMarcar,(Pls300DisableKays(),PLS300MEDBRW(oHorarios,oBrowse,bVetAge),;
                 Pls300EnableKeys(oListLoc, oEnc, bFiltro, nDsPes,dData, aListaUsr,nOpcao, ;
                 oDlgPes, bClick, oHorarios, bVetAge, oBrowse,cCodEsp,oListaUsr,nDsPer)),;
                 Aviso(STR0023,STR0046,{STR0047})) }) // Invoca o browse de medicos //"Remarcar"###"Nao e possivel trocar de medico na remarcacao."###"&Voltar"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Foca no browse de horarios...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
SetKey(3  ,{||oHorarios:SetFocus()})  														// Foca a agenda do medico selecionado
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra mansagem do medico na data atual...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(13 ,{||PLSA300MSG()})
nLinI := 31
@ aPosObj1[1,3]+nLinI, aPosObj1[1,2]+nColI BUTTON oBot01 PROMPT " << " 	SIZE 20,15  ACTION ((oListLoc:Refresh()),lMove := .T.,lByPass:=.T.,PLSA300Dat("2",oEnc,bFiltro,nDsPes,M->BBO_DATA),lByPass:=.F.) PIXEL  OF oDlgPes
oBot01:cTOOLTIP := STR0048 //"Agenda Anterior"

nColI+=20
@ aPosObj1[1,3]+nLinI, aPosObj1[1,2]+nColI BUTTON oBot02 PROMPT " < " 		SIZE 20,15  ACTION (lMove := .T.,lByPass:=.F.,PLSA300Dat("3",oEnc,bFiltro,nDsPes,M->BBO_DATA)) PIXEL  OF oDlgPes
oBot02:cTOOLTIP := STR0049 //"Diminuir Data"

nColI+=20
@ aPosObj1[1,3]+nLinI, aPosObj1[1,2]+nColI BUTTON oBot04 PROMPT " > " 		SIZE 20,15  ACTION (lMove := .T.,lByPass:=.F.,PLSA300Dat("4",oEnc,bFiltro,nDsPes,M->BBO_DATA)) PIXEL  OF oDlgPes
oBot04:cTOOLTIP := STR0050 //"Aumentar Data"

nColI+=20
@ aPosObj1[1,3]+nLinI, aPosObj1[1,2]+nColI BUTTON oBot03 PROMPT " >> " 	SIZE 20,15  ACTION ((oListLoc:Refresh()),lMove := .T.,lByPass	:=.T.,PLSA300Dat("1",oEnc,bFiltro,nDsPes,M->BBO_DATA),lByPass:=.F.) PIXEL  OF oDlgPes
oBot03:cTOOLTIP := STR0051 //"Proxima Agenda"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgPes ON INIT (Iif(ValType(oSinal)<>"U",oSinal:Activate(),nCor:=1),;
								   oTimerBrw:Activate(),;
                                   Eval( {|| EnchoiceBar(oDlgPes,{|| dbSelectarea("BBD"), oDlgPes:End()},{|| dbSelectarea("BBD"), oDlgPes:End()},.F.,aButtons)}) ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lebera teclas de atalhos...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET KEY VK_F2 TO
SET KEY VK_F4 TO
SET KEY VK_F5 TO
SET KEY VK_F6 TO
SET KEY VK_F7 TO
SET KEY VK_F8 TO
SET KEY VK_F9 TO
SET KEY VK_F10 TO
SET KEY VK_F11 TO
SET KEY VK_F12 TO              
SET KEY 1  TO              
SET KEY 2  TO              
SET KEY 3  TO              
SET KEY 4  TO              
SET KEY 13 TO              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return               
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA300AJC ³ Autor ³Geraldo Felix Junior³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ajusta o browse de acordo com os novos parametros...      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSA300Ajc(	cCodInt,dData,cCodEsp,cDesMun,cEstado,cBairro,cCodPro,cCodLoc,cCodCre,cInd,;
							cCadastro,aColunas,aDados,aOcupacao,oBrowse,oDlgPes,bChange,bClick,;
	                        oCorOcu,oCorLiv,aMedHor,bBrwCol,bMontVet,oListMed,aItems,oListLoc,;
	                        bVetAge,oHorarios,cMedico)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declara as variaveis...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                        
Local nCnt
LOCAL nI
LOCAL aRetorno 	:= {}
LOCAL aComboAux := {}
LOCAL lRet 		:= .F.         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
If !lMarcar .and. !lMove
	Return(.F.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ criar arquivo de trabalho baseado nos parametros BBO...                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
lMove := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ criar arquivo de trabalho baseado nos parametros BBO...                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
aRetorno := PLSA300Trb(cCodInt,dData,cCodEsp,cDesMun,cEstado,cBairro,cCodPro,cCodLoc,cCodCre,cInd,cCadastro) 
If ! aRetorno[1]
   Return(lRet)
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o array com os locais de atendimento resultantes...                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColunas := aClone(aRetorno[2])                             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa o codblock responsavel pelos arrays com os horarios dos medicos  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bMontVet)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa o array dos medicos disponiveis, de  acordo com os parametros...       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
If Len(aCombo) > 0                         
	lRet := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Para checar todos os medicos											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To Len(aCombo)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pega o medico															 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Alltrim(cCombo) == STR0053 .Or. Empty(cCombo) //"Nao ha medicos disponiveis"
			cCombo 					:= aCombo[nI,1]+" - "+aCombo[nI,2]
			cComboEsp				:= aCombo[nI,4]
			oSinal:LACTIVE 			:= Iif(!Empty(aCombo[nI,5]),.T.,.F.)	
			oBmpBol:LVISIBLECONTROL := Iif(!Empty(aCombo[nI,5]),.T.,.F.)	
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa o codblock responsavel pela agenda especifica do medico selecionado horarios...|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
		Eval(bVetAge)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso seja precionado o botao "PROXIMA VAGA" tem que ignorar os dias com agenda cheia.|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
		If lByPass 
			lRet := .F.
			For nCnt := 1 To Len(aHorAge)
				If Empty(aHorAge[nCnt][4])
					lRet := .T.
					Exit
				Endif
			Next
		Endif   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Limpa combo para pegar o proximo medico												 |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
		If !lRet
			cCombo := ''
		Else
		    Exit	
		EndIf
    Next      
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retira medicos que nao tem horario disponivel										 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
	If lRet .And. lByPass                       
	   If Len(aMedDis) > 0
		   For nI := 1 To Len(aCombo)
			   nPos := Ascan(aMedDis,{|x| x[1] == aCombo[nI,1] } )
		       If nPos > 0 .Or. Left(cCombo,Len(BAU->BAU_CODIGO)) == aCombo[nI,1]
       			  AaDd(aComboAux, {aCombo[nI,1],aCombo[nI,2],aCombo[nI,3],aCombo[nI,4],aCombo[nI,5]} )	
			   EndIf	   
		   Next
	   Else
		   nPos := Ascan(aCombo,{|x| x[1] == Left(cCombo,Len(BAU->BAU_CODIGO)) } )
	       If nPos > 0 
      		  AaDd(aComboAux, {aCombo[nPos,1],aCombo[nPos,2],aCombo[nPos,3],aCombo[nPos,4],aCombo[nPos,5]} )	
		   EndIf	   
	   EndIf   
  	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Atualiza matriz combo																|
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
	   aCombo := aClone(aComboAux)
	EndIf   
Else
	cCombo 					:= STR0053   //"Nao ha medicos disponiveis"
	cComboEsp 				:= ''
	oSinal:LACTIVE 			:= .F.
	oBmpBol:LVISIBLECONTROL := .F.
	lRet 					:= .F.
	aHorAge 				:= {}
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o browse dos locais de atendimento, utilizando o array acolunas...  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
oListLoc:SetArray(aColunas)    
oListLoc:Refresh()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta o browse da agenda especifica do medico selecionado...                    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oHorarios:SetArray(aHorAge)
oHorarios:Refresh()
oHorarios:SetFocus()

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA300VET ³ Autor ³Geraldo Felix Junior³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta os arrays necessarios para a montagem do dialogo... ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSA300VET(aColunas,cInd,aDados,aOcupacao,aMedHor,dData,cCodInt,oListLoc,cDia,cDiaMes,cMes,cAno,oListMed)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis de tela...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aAux      := {}
LOCAL aPosHor   := {}                                 
LOCAL aColsAux  := {}
LOCAL aHorCol   := {}
LOCAL aAuxMeds	:= {}
LOCAL cSQL

LOCAL nAux		:= 0
LOCAL nCol		:= 0
LOCAL nInd		:= 0                   
LOCAL nCnt 		:= 0

LOCAL lVaga
LOCAL lHorCan
LOCAL bSeek		:= {|| ( BBD->(MsSeek(xFilial("BBD")+aInd[nCnt][02]+cCodInt+aInd[nCnt][29]+dtos(dData)+aAux[nAux]+Space(02))) .And. BBD->BBD_ENCAIX == "0" .And. BBD->BBD_PRTATD == "0" .and. Empty(BBD->BBD_CODCAN))}
PRIVATE cPictPad  := "@R !!:!!"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefine o array dos horarios medicos...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aMedHor := {}                         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa integridade do dado...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ              
If Len(aColunas) <= 1 .Or. (Len(aColunas) < oListLoc:nAt)
	oListLoc:nAt := 1
Endif	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefine o array aCombo...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCombo:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para cada localidade vou buscar os horarios disponiveis...               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
BBD->(DbSetOrder(1))     
For nCnt := 1 To Len(aInd)
	// Apenas as colunas do local de atendimento selecionado.
	If aInd[nCnt][30] <> aColunas[oListLoc:nAt,1]
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta os horarios dos medicos...                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAux := PLSA300HR(aInd[nCnt][03],aInd[nCnt][04],Iif(!Empty(aInd[nCnt][08]),aInd[nCnt][08],aInd[nCnt][32]),aInd[nCnt][05],aInd[nCnt][06])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o array com os medicoss disponiveis                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	If Len(aAux) > 0
		BAQ->( dbSetorder(01) )
		BAQ->( MsSeek(xFilial("BAQ")+aInd[nCnt][09]+aInd[nCnt][07]) )
		If Ascan(aCombo,{|x| x[1]+x[4] == aInd[nCnt][02]+aInd[nCnt][07]}) == 0
			aadd(aCombo,{aInd[nCnt][02],Alltrim(aInd[nCnt][21]),aInd[nCnt][40],aInd[nCnt][07],aInd[nCnt][17]})	
		Endif
	Endif	
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona area usuarios													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("BA1")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a variavel do medico...                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nPos := Ascan(aCombo,{|x| x[1] == Left(cCombo,Len(BAU->BAU_CODIGO)) }) ) <> 0
	cCombo 		:= aCombo[nPos,1]+" - "+aCombo[nPos,2]
	cComboEsp   := aCombo[nPos,4]
	If ValType(oSinal) == "O"
		oSinal:LACTIVE 			:= Iif(!Empty(aCombo[1,5]),.T.,.F.)	
	Endif
	If ValType(oBmpBol) == "O"
		oBmpBol:LVISIBLECONTROL := Iif(!Empty(aCombo[1,5]),.T.,.F.)	
	Endif	
Else                      
	If Len(aCombo) > 0
		cCombo := aCombo[1,1]+" - "+aCombo[1,2]
		cComboEsp   := aCombo[1,4]
		If ValType(oSinal) == "O"
			oSinal:LACTIVE 			:= Iif(!Empty(aCombo[1,5]),.T.,.F.)	
		Endif
		If ValType(oBmpBol) == "O"
			oBmpBol:LVISIBLECONTROL := Iif(!Empty(aCombo[1,5]),.T.,.F.)	
		Endif
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(aDados,aOcupacao,aMedHor)               

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA300SEL ³ Autor ³Geraldo Felix Junior³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Abre a tela da agenda de um determinado medico em um hora.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSA300Sel(oBrowse,oListMed,aColunas,aDados,aOcupacao,dData,;
                           cCodEsp,cDesEsp,cCodInt,cInd,aMedRec,cPictPad,;
                           oDlgPes,aItems,nOpcao,nDsPer, nCol, aMedHor, cNada,;
                           aHorAge, oHorarios, bVetAge, cCodPro, cCodLoc) 
LOCAL lFlag
LOCAL oFont01 
LOCAL oDlgMar
LOCAL oSay
LOCAL oEnc               
LOCAL oListaUsr
LOCAL oListaUs1
LOCAL oComboMed
LOCAL oFontVd

LOCAL lRet       := .F.
LOCAL nPosHour	 := 0
LOCAL nH		 := 0
LOCAL nLin       := 0
LOCAL nRecBBD	 := 0
LOCAL nInd		 := 0
LOCAL nTamDlgPad := 0
LOCAL nAux       := 0
LOCAL nOpca      := 0               
LOCAL nAtCombo	 := 1    
LOCAL nOpcEnc	 := 0
LOCAL nNewCampos := 1
LOCAL cFile		 := ''
LOCAL cNil       := ''
LOCAL cTimeFin	 := ''
LOCAL cTitulo	 := ''
LOCAL cFoto      := ''
LOCAL cTimeIni	 := Time()
LOCAL cConSem 	 := "ATEND"                                                
LOCAL cLocal     := { || aColunas[nCol,1]+" - "+aColunas[nCol,2] }
LOCAL cHorario   := { || StrTran(aHorAge[oHorarios:nAt,2],":","") }
LOCAL aButtons   := {}
LOCAL aCampos    := {}   
LOCAL aDadBBD    := {}
LOCAL aDadBHY    := {}         
LOCAL aComboMed	 := {}
LOCAL aComboAux	 := {}
LOCAL aListaUsr  := { {"","","",0,.T.,"","",""} }
LOCAL aListaUs1  := { {"","","",0,.T.} }
LOCAL aOldTela   := aTela
LOCAL aOldGets   := aGets
LOCAL aDadUsr 	 := {} 
LOCAL bRecBAU    := { || aHorAge[oHorarios:nAt,11] }
LOCAL bCodLoc    := { || aHorAge[oHorarios:nAt,12] }
LOCAL bOK        := { || Iif(A300VLDSEL(@nOpca, @lEncaixe, @aGets, @aTela, @nOpcao, @aHorAge, @dData, @cCodEsp,;
									 @nDsPer, oEnc, @lMarcar, @oDlgRes, @cCodLoc) .And. IIf(ExistBlock("PL300ENC") .And. lEncaixe,ExecBlock("PL300ENC",.F.,.F.,{BAU->BAU_CODIGO}),.T.), oDlgRes:End(), NIL)}
		                     
LOCAL bCanc      := { || nOpca := 3,oDlgRes:End() }
LOCAL bOKMar     := { || nOpca := 1,If((Obrigatorio(aGets,aTela)),(PLS300MAR(dData,cCombo,oHorarios) .And. oDlgMar:End()),(nOpca:=3,.F.))}
LOCAL bCancMar   := { || nOpca := 3,oDlgMar:End() }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis PRIVATES...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oDlgRes
PRIVATE nTamDlgBrw := 538 
PRIVATE aTela    := {}
PRIVATE aGets    := {}
DEFAULT nOpcao   := K_Agenda
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O nOpcao esta se perdendo.. 										     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcao == 0  
   nOpcao  := K_Agenda                      
EndIf  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a variavel de especialidade...                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCodEsp := cComboEsp

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata agenda em branco...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aHorAge) == 0
	oHorarios:SetFocus()
	Return(lRet)
Else
	cLocal     := Eval(cLocal)
 	cHorario   := Eval(cHorario)
Endif
nRecBBD	 := aHorAge[oHorarios:nAt,06]
nLin     := oHorarios:nAt     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa integridade do dado...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Valtype(Eval(bRecBAU)) # "N"
	Aviso(STR0054,STR0055,{STR0047}) //"Erro."###"Tipo de dados incompativel"###"&Voltar"
	oHorarios:Setfocus()
	Return(lRet)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no registro do credenciado selecionado...                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If nOpcao == K_Marcar .or. nOpcao == K_Sair
	If Len(aVetMar) == 0
		Return(lRet)
	Endif
	BAU->( dbSetorder(01) )
	BAU->( MsSeek(xFilial("BAU")+Left(aVetMar[1,8], Len(BAU->BAU_CODIGO))) )
Else
	BAU->( dbSetorder(01) )
	BAU->( MsSeek(xFilial("BAU")+Left(cCombo, Len(BAU->BAU_CODIGO))) )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata se outra estacao realizou um bloqueio das agendas...               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !PL300VLBLQ(cCodInt, BAU->BAU_CODIGO, cCodEsp, Substr(cLocal, 1, Len(BBD->BBD_LOCAL)), dData, cHorario)
	Eval(bVetAge)
	oHorarios:Setarray(aHorAge)
	oHorarios:Refresh()
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Clicou em marcar ou estornar a remarcacao sem ter clicaco em remarcar...                     |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
If nOpcao == K_Marcar .or. nOpcao == K_Sair
	If Len(aVetMar) == 0
		oHorarios:SetFocus()
		Return(lRet)		
	Endif                            
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso seja o "marcar" da remarcacao e seja clicado enter no browse, forca a troca da operacao |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
If !lMarcar .and. lFocoBrw .and. nOpcao # K_Sair
	If Len(aVetMar) == 0
	Else
		MsgInfo(STR0056) //"Para confirmar a remarcacao, posicione no horario livre desejado em seguida clique no botao MARCAR ou precione ALT+M"
	Endif
	Return(lRet)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata horarios bloqueados...                                                                 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                  
If (nOpcao == K_Agenda .or. nOpcao == K_Marcar) .and. !aHorAge[oHorarios:nAt,13]
	Aviso(STR0057,STR0058,{STR0047}) //"Bloqueio!"###"Este horario foi bloqueado pelo operador!"###"&Voltar"
	oHorarios:SetFocus()
	Return(lRet)
Endif	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para tratar remarcacao de encaixe...                                                         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄtÄÙ                         
If nOpcao == K_Marcar
	If Len(aVetMar) == 0
		Return(lRet)
	Else
		If aVetMar[1,12] == "1"  //Encaixe
		   lEncaixe := .T.
		Endif
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata horarios de encaixe																	 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                  
If aHorAge[oHorarios:nAt,9] == '1' .And. !lEncaixe .and. nOpcao <> K_Cancel .and. nOpcao <> K_Editar
	MsgStop('Nao e possivel reutilizar um Horario de Encaixe')
	Return(lRet)
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcao... 								                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpcao == K_Agenda .or. nOpcao == K_Marcar) .and. cHorario < StrTran(Left(Time(),5),":","") .and.;
    M->BBO_DATA == Date() .and. !lEncaixe
	Aviso(STR0059,STR0060,{STR0047}) //"Horario invalido!"###"A hora da agenda selecionada e menor que a hora atual na mesma data."###"&Voltar"
	oHorarios:SetFocus()
	Return(lRet)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define fonte para mensagem...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ              
DEFINE FONT oFont01 NAME "Arial" SIZE 0,-16 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vaga ocupada aborta...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpcao == K_Agenda .Or. nOpcao == K_Marcar) .And.;
	!Empty(aHorAge[oHorarios:nAt,4]) .And.; //Tiver passiente
	Empty(aHorAge[oHorarios:nAt,10]) .And.; //Nao tiver cancelado
	!lEncaixe								 //Nao for um encaixe
	Aviso(STR0061,STR0062,{STR0047}) //"Horario nao disponivel!"###"Ja existe uma agenda marcada neste horario, selecione um horario livre."###"&Voltar"
	oHorarios:SetFocus()
	Return(lRet)
Endif      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Teste de ocupacao...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nOpcao == K_Editar .Or. nOpcao == K_Cancel .Or. nOpcao == K_Remarca ) .And. aHorAge[oHorarios:nAt,6] == 0 .and. !lEncaixe
	MsgInfo(STR0063) //"Este horario nao esta ocupado portando nao podera ser editado ou cancelado"
	oHorarios:SetFocus()
	Return(lRet)
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta titulo do dialogo de acordo com a opcao...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nOpcao == K_Agenda
	cTitulo := STR0064 //"Agenda Medica - Dados do Paciente"
ElseIf nOpcao == K_Editar
	cTitulo := STR0065 //"Agenda Medica - Editar Dados do Paciente"
ElseIf nOpcao == K_Cancel
	cTitulo := STR0066 //"Agenda Medica - Cancelar Agenda"
ElseIf nOpcao == K_Remarca
	cTitulo := STR0067 //"Agenda Medica - Remarcar Agenda"
Elseif nOpcao == K_Sair
	cTitulo := STR0068 //"Agenda Medica - Restaurar Agenda"
Endif       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao estiver selecionado no listmed sugere o primeiro...               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcao == K_Agenda
	lFlag := .F.
	For nInd := 1 To Len(aItems)
		If Empty(aItems[nInd,2])
			lFlag := .T.
			If ValType(Eval(bRecBAU)) == "C"
				MsgAlert(STR0069) //"Ocorreu um erro inesperado no sistema, por favor tente novamente. Se o problema continuar acione o Suporte Tecnico."
				Return(.F.)
			Endif
			Aadd( aComboMed,aItems[nInd,1]+"    ["+Alltrim(Str(Eval(bRecBAU)))+"]" )
			Aadd( aComboAux,aItems[nInd,7] )
		Endif
	Next
	
	If !lFlag
		Aadd( aComboMed,aItems[1,1]+"    ["+Alltrim(Str(Eval(bRecBAU)))+"]" )
		Aadd( aComboAux,aItems[1,7] )
	Endif
Endif                         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se ja houve atendimento nao pode cancelar...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcao == K_Cancel .Or. nOpcao == K_Editar .Or. nOpcao == K_Remarca
	If aHorAge[oHorarios:nAt,7] <> "1" .And. aHorAge[oHorarios:nAt,7] <> "8"
		MsgInfo(STR0070) //"Esta agenda ja foi editada pela Recepcao medica."
		oHorarios:SetFocus()
		Return(lRet)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Eu testo se ja existe...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpcao == K_Agenda .or. nOpcao == K_Marcar) .and. !lEncaixe
   BBD->(DbSetOrder(1))
   If BBD->(MsSeek(xFilial("BBD")+BAU->BAU_CODIGO+cCodInt+Eval(bCodLoc)+dtos(dData)+TransForm(cHorario,cPictPad)+Space(02))) .and. Empty(BBD->BBD_CODCAN)
      MsgInfo(STR0071) //"Horario Reservado por outro(a) operador(a)"
      oHorarios:SetFocus()
      Return(lRet)
   Endif   
Else
   BBD->( DbGoTo(nRecBBD) )
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle de transacao...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRecBBD > 0
   cFile := "F"+cConSem+AllTrim( Str(nRecBBD) )+".SMF"
Else 
   cFile := "F"+cConSem+aHorAge[oHorarios:nAt,1]+aHorAge[oHorarios:nAt,12]+cHorario+".SMF"
EndIf   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tenta criar o arquivo													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nH := FCreate(cFile)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Checa se o arquivo ja foi criado Cancelamento							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nH == -1 
   Aviso(STR0072,STR0073,{STR0047}) //"Ocupado"###"Horario sendo utilizado por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
   Return
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dialogo...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nopcao == K_Cancel 
   nAux := 031
Else
   nAux := 029
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa se existe usuario selecionado...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
If nOpcao == K_Agenda 
	If Empty(BBO->BBO_CODPAC)
		If Aviso(STR0040,STR0074,{STR0075,STR0047}) == 1 //"Usuario"###"Nao existe usuario selecionado!"###"&Selecionar"###"&Voltar"
			If !PLSA300CALL(cCodEsp,dData,1,aListaUsr,oListaUsr,nOpcao,oDlgPes,nDsPer,aColunas[nCol,1],aHorAge,oHorarios,.F.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Controle de transacao...                                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FCLOSE(nH)
				FErase(cFile)   
				oHorarios:SetFocus()
				Return(.F.)
			Endif
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Controle de transacao...                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FCLOSE(nH)
			FErase(cFile)
			oHorarios:SetFocus()
			Return(.F.)
		Endif
	Endif
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define font utilizada na validacao do usuario...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFontVd NAME "Arial" SIZE 0,-14 BOLD

If nOpcao <> K_Remarca
	
	DEFINE MSDIALOG oDlgRes TITLE cTitulo FROM 002,005 TO nAux, 060 OF oDlgPes
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta informacoes do horario/medico selecionado...                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 014,001 GROUP oGrpLoc TO 061, 215 PIXEL OF oDlgRes LABEL STR0076  COLOR CLR_HBLUE, CLR_HRED //"Detalhes"
	
	@ 022,005 Say oSay Prompt STR0077 Size 150,008 PIXEL OF oDlgRes COLOR CLR_HBLUE //"DATA"
	@ 021,030 Say oSay Prompt dtoc(dData) Size 150,008 PIXEL OF oDlgRes FONT oFontVd COLOR CLR_HRED
	
	@ 022,095 Say oSay Prompt STR0078 Size 150,008 PIXEL OF oDlgRes COLOR CLR_HBLUE //"HORARIO"
	If lEncaixe
		@ 021,130 Say oSay Prompt STR0035 Size 150,008 PIXEL OF oDlgRes FONT oFontVd COLOR CLR_HRED //"Encaixe"
	Else
		@ 021,130 Say oSay Prompt TransForm(cHorario,cPictPad) Size 150,008 PIXEL OF oDlgRes FONT oFontVd COLOR CLR_HRED
	Endif
	
	@ 037,005 Say oSay Prompt STR0079 Size 150,008 PIXEL OF oDlgRes COLOR CLR_HBLUE //"LOCAL "
	@ 036,030 Say oSay Prompt cLocal Size 200,008 PIXEL OF oDlgRes FONT oFontVd COLOR CLR_HRED
	
	@ 050,005 Say oSay Prompt STR0080 Size 100,008 PIXEL OF oDlgRes COLOR CLR_HBLUE //"MEDICO"
	
	If nOpcao == K_Marcar .or. nOpcao == K_Sair
		If Len(aVetMar) <> 0
			@ 050,030 Say oSay Prompt aVetMar[1,8] Size 200,008 PIXEL OF oDlgRes FONT oFontVd COLOR CLR_HRED
		Endif
	Else
		@ 050,030 Say oSay Prompt cCombo Size 200,008 PIXEL OF oDlgRes FONT oFontVd COLOR CLR_HRED
	Endif
	
ENDIF

If nOpcao == K_Remarca
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta dialogo remarcacao...                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgMar TITLE cTitulo FROM 002,005 TO nAux, 060 OF oDlgPes
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta informacoes do horario/medico selecionado...                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 015,001 GROUP oGrpLoc TO 061, 215 PIXEL OF  oDlgMar LABEL STR0076  COLOR CLR_HBLUE, CLR_HRED //"Detalhes"
	
	@ 022,005 Say oSay Prompt STR0077 Size 150,008 PIXEL OF oDlgRes COLOR CLR_HBLUE //"DATA"
	@ 021,030 Say oSay Prompt dtoc(dData) Size 150,008 PIXEL OF oDlgRes FONT oFontVd COLOR CLR_HRED
	                                                                  
	@ 022,095 Say oSay Prompt STR0078 Size 150,008 PIXEL OF oDlgRes COLOR CLR_HBLUE     //"HORARIO"
	@ 021,130 Say oSay Prompt TransForm(cHorario,cPictPad) Size 150,008 PIXEL OF oDlgRes FONT oFontVd COLOR CLR_HRED
         
	@ 037,005 Say oSay Prompt STR0079 Size 150,008 PIXEL OF oDlgRes COLOR CLR_HBLUE //"LOCAL "
	@ 036,030 Say oSay Prompt cLocal Size 200,008 PIXEL OF oDlgRes FONT oFontVd COLOR CLR_HRED

	@ 050,005 Say oSay Prompt STR0080 Size 100,008 PIXEL OF oDlgMar COLOR CLR_HBLUE //"MEDICO"
	@ 050,030 Say oSay Prompt cCombo Size 200,008 PIXEL OF oDlgRes FONT oFontVd COLOR CLR_HRED
	
ENDIF
                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega variaveis de memoria...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BBD->(RegToMemory("BBD",.F.))
                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dados da enchoice...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aCampos,"BBD_CODPAC")
aadd(aCampos,"BBD_NOME")
aadd(aCampos,"BBD_TELEFO")
aadd(aCampos,"BBD_TIPO")
aadd(aCampos,"BBD_HORA")
aadd(aCampos,"BBD_MATANT")
aadd(aCampos,"BBD_CODSOL")
aadd(aCampos,"BBD_NOMSOL")
aadd(aCampos,"BBD_OBSERV")
If lBBD_ATERNA//BBD->( FieldPos("BBD_ATERNA") ) > 0
   aadd(aCampos,"BBD_ATERNA")
EndIf	
//If BBD->( FieldPos("BBD_TIPPAC") ) > 0
If lBBD_TIPPAC
   aadd(aCampos,"BBD_TIPPAC")
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui novos campos na enchoice atraves do ponto de entrada PLCAMMAR     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
If ExistBlock("PLCAMMARC")
   aNewCampos := ExecBlock("PLCAMMARC",.F.,.F.)     
   If ValType(aNewCampos) == 'A'
      For nNewCampos :=1 To Len(aNewCampos)    
         aadd(aCampos,aNewCampos[nNewCampos])
      Next
   EndIf   
Endif	

If nOpcao == K_Agenda
	M->BBD_CODPAC 	:= Iif(!Empty(BBO->BBO_CODPAC),BBO->BBO_CODPAC,Space(Len(BBD->BBD_CODPAC)))
	M->BBD_NOME   	:= Iif(!Empty(BBO->BBO_NOME  ),BBO->BBO_NOME  ,Space(Len(BBD->BBD_NOME  )))
	M->BBD_TELEFO 	:= Iif(!Empty(BBO->BBO_TELEFO),BBO->BBO_TELEFO,Space(Len(BBD->BBD_TELEFO)))
	lForcado		:= Iif(!Empty(BBO->BBO_USRFRC),.T.,.F.)       
	
	If lBBD_ATERNA .And. lBBO_ATERNA//BBD->( FieldPos("BBD_ATERNA") ) > 0 .And. BBO->( FieldPos("BBO_ATERNA") ) > 0
		M->BBD_ATERNA := Iif( !Empty(BBO->BBO_ATERNA) ,BBO->BBO_ATERNA,"0" )
	EndIf	                        
	
	If lEncaixe
		M->BBD_TIPO := "4"
	Else
		M->BBD_TIPO := "1"
	Endif
	M->BBD_MATANT 	:= Iif(!Empty(BBO->BBO_MATANT),BBO->BBO_MATANT,Space(Len(BBD->BBD_MATANT)))
	M->BBD_CODSOL 	:= CriaVar("BBD_CODSOL")    
	M->BBD_NOMSOL	:= CriaVar("BBD_NOMSOL")    
	M->BBD_HORA		:= Space(Len(BBD->BBD_HORA))
	M->BBD_OBSERV	:= CriaVar("BBD_OBSERV")
    If lBBD_TIPPAC//BBD->( FieldPos("BBD_TIPPAC") ) > 0 
		M->BBD_TIPPAC   := getNewPar("MV_PLSTPAA","9")//Define o tipo de paciente que sera gravado na guia de internacao.
	EndIf    
Else
	If nOpcao == K_Marcar .or. nOpcao == K_Sair
		M->BBD_CODPAC 	:= aVetMar[1,01]
		M->BBD_NOME   	:= aVetMar[1,02]
		M->BBD_TELEFO 	:= aVetMar[1,03]
		M->BBD_TIPO   	:= aVetMar[1,04]
		M->BBD_MATANT 	:= aVetMar[1,05]    
		M->BBD_CODSOL 	:= aVetMar[1,06]
		M->BBD_NOMSOL	:= aVetMar[1,10]
		M->BBD_OBSERV	:= aVetMar[1,13]
		If lBBD_ATERNA//BBD->( FieldPos("BBD_ATERNA") ) > 0
		   M->BBD_ATERNA := aVetMar[1,14]
		EndIf
		
		If nOpcao == K_Marcar                          
			If !lEncaixe
				M->BBD_HORA		:= aHorAge[oHorarios:nAt,2]
			Else
				M->BBD_HORA		:= Criavar("BBD_HORA")
			Endif
		Else        
			M->BBD_HORA		:= aVetMar[1,7]   // Opcao Sair... restaura hoario original
			dData			:= aVetMar[1,9]
			cHorario		:= StrTran(aVetMar[1,7],":","")
		Endif
	Else
		M->BBD_CODPAC 	:= BBD->BBD_CODPAC
		M->BBD_NOME   	:= BBD->BBD_NOME
		M->BBD_TELEFO 	:= BBD->BBD_TELEFO		
		M->BBD_TIPO   	:= BBD->BBD_TIPO
		M->BBD_MATANT 	:= BBD->BBD_MATANT
		M->BBD_HORA		:= BBD->BBD_HORA
		M->BBD_CODSOL 	:= BBD->BBD_CODSOL
		M->BBD_NOMSOL	:= CriaVar("BBD_NOMSOL")
		M->BBD_OBSERV	:= BBD->BBD_OBSERV
		If lBBD_ATERNA//BBD->( FieldPos("BBD_ATERNA") ) > 0 
		   M->BBD_ATERNA := BBD->BBD_ATERNA
		EndIf	
		If lBBD_TIPPAC//BBD->( FieldPos("BBD_TIPPAC") ) > 0            
	   		M->BBD_TIPPAC	:= BBD->BBD_TIPPAC
		EndIf
	Endif
Endif                     

If nOpcao == K_Remarca
	M->BBD_CODPAC 	:= BBD->BBD_CODPAC
	M->BBD_NOME   	:= BBD->BBD_NOME
	M->BBD_TELEFO 	:= BBD->BBD_TELEFO
	M->BBD_TIPO   	:= BBD->BBD_TIPO
	M->BBD_MATANT 	:= BBD->BBD_MATANT
	M->BBD_HORA		:= BBD->BBD_HORA
	M->BBD_CODSOL 	:= BBD->BBD_CODSOL
	M->BBD_NOMSOL	:= CriaVar("BBD_NOMSOL")
	M->BBD_OBESERV	:= BBD->BBD_OBSERV
	If lBBD_ATERNA//BBD->( FieldPos("BBD_ATERNA") ) > 0 
	   M->BBD_ATERNA := BBD->BBD_ATERNA
	EndIf	
Endif

If nOpcao == K_Cancel
	aadd(aCampos,"BBD_CODCAN")
	aadd(aCampos,"BBD_DESCAN")
	If lBBD_DATCAN//BBD->( FieldPos("BBD_DATCAN") ) > 0
		aadd(aCampos,"BBD_DATCAN")
		M->BBD_DATCAN := CriaVar("BBD_DATCAN")		
	Endif
	M->BBD_CODCAN := CriaVar("BBD_CODCAN")
	M->BBD_DESCAN := CriaVar("BBD_CODCAN")
Endif                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ foto...                                                        			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPrefFot := ""
@ 070, 162 JPEG oFoto FILENAME cPrefFot+M->BBD_CODPAC+".JPG" OF oDlgRes SIZE 050, 042 NOBORDER WHEN .F. PIXEL     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta enchoice...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If     nOpcao == K_Agenda  .Or.  nOpcao == K_Marcar .or. nOpcao == K_Sair
       nOpcEnc := K_Incluir
ElseIf nOpcao == K_Editar
       nOpcEnc := K_Alterar
ElseIf nOpcao == K_Cancel
       nOpcEnc := K_Alterar
ElseIf nOpcao == K_Remarca
       nOpcEnc := K_Alterar
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no registro do credenciado selecionado...                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If nOpcao == K_Marcar .or. nOpcao == K_Sair
	If Len(aVetMar) == 0
		Return(lRet)
	Endif                                          
	BAU->( dbSetorder(01) )
	BAU->( MsSeek(xFilial("BAU")+Left(aVetMar[1,8], Len(BAU->BAU_CODIGO))) )
Else
	BAU->( dbSetorder(01) )
	BAU->( MsSeek(xFilial("BAU")+Left(cCombo, Len(BAU->BAU_CODIGO))) )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enc																		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnc  := BBD->(MSMGet():New("BBD",5,nOpcEnc,,,,aCampos,{064,003,If(nOpcao==K_Cancel,214,203),215},aCampos,,,,,oDlgRes,,,.T.))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ No caso da agenda vou alterar o valid do campo BBD_NOME...               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nInd := 1 To Len(oEnc:AENTRYCTRLS)

	If nOpcao # K_Remarca
		If oEnc:AENTRYCTRLS[nInd]:cReadVar == "M->BBD_NOME"
			oEnc:AENTRYCTRLS[nInd]:BLOSTFOCUS := { || lRet := PLSA300APq(M->BBD_NOME,oDlgRes,nTamDlgBrw,aListaUsr,oListaUsr), IF(lRet,PLS300LISUSR(cCodEsp,dData,nTamDlgBrw,aListaUsr,oListaUsr, nOpcao,oEnc, oDlgRes, nDsPer,M->BBD_NOME),Nil) } //IF(lRet,oListaUsr:SetFocus(),Nil) }
		Endif
    Else
		If oEnc:AENTRYCTRLS[nInd]:cReadVar == "M->BBD_NOME"
			oEnc:AENTRYCTRLS[nInd]:BLOSTFOCUS := { || lRet := PLSA300APq(M->BBD_NOME,oDlgMar,nTamDlgBrw,aListaUsr,oListaUsr), IF(lRet,oListaUsr:SetFocus(),nil) }
		Endif
	Endif

	If oEnc:AENTRYCTRLS[nInd]:cReadVar == "M->BBD_HORA"
		If lEncaixe
			oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .T. }
			oEnc:AENTRYCTRLS[nInd]:BVALID := { || PLSA300ENC(M->BBD_HORA,aHorAge,oHorarios,nOpcao) }
		Else		
			oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
		Endif
		nPosHour := nInd
	Endif	
		                
	If oEnc:AENTRYCTRLS[nInd]:cReadVar == "M->BBD_TIPO"
		If lEncaixe .and. nOpcao <> K_Marcar
			oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
		Else
			oEnc:AENTRYCTRLS[nInd]:BLOSTFOCUS := { || Iif((M->BBD_TIPO # "4" .and. nOpcao # K_Marcar),(oEnc:AENTRYCTRLS[nPosHour]:BWHEN := { || .F. }),(oEnc:AENTRYCTRLS[nPosHour]:BWHEN := { || .T. },oEnc:AENTRYCTRLS[nPosHour]:BVALID := { || PLSA300ENC(M->BBD_HORA,aHorAge,oHorarios,nOpcao) })) }
		Endif
	Endif
	
	If oEnc:AENTRYCTRLS[nInd]:cReadVar $ "M->BBD_NOME,M->BBD_CODPAC"
		If !Empty(BBO->BBO_CODPAC) .AND. !Empty(BBO->BBO_NOME)
			oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
		Endif
	Endif 
	
	//na tela de callcenter eu tenho que poder alterar o campo de recem nascido
	//pois o usuario ja bem preenchido 
    If lBBD_ATERNA .and. Funname() <> 'TMKA271' 
		If oEnc:AENTRYCTRLS[nInd]:cReadVar $ "M->BBD_ATERNA"
	   	   oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
		EndIf   
    EndIf
    
	If nOpcao == K_Cancel
       If lBBD_ATERNA//BBD->( FieldPos("BBD_ATERNA") ) > 0
		  If oEnc:AENTRYCTRLS[nInd]:cReadVar $ "M->BBD_NOME,M->BBD_CODPAC,M->BBD_TELEFO,M->BBD_TIPO,M->BBD_MATANT,M->BBD_CODSOL,M->BBD_ATERNA"
		     oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
	   	  Endif
		Else 
		  If oEnc:AENTRYCTRLS[nInd]:cReadVar $ "M->BBD_NOME,M->BBD_CODPAC,M->BBD_TELEFO,M->BBD_TIPO,M->BBD_MATANT,M->BBD_CODSOL,M->BBD_TIPPAC"
		     oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
	   	  Endif
		EndIf	
	Endif
	
	If nOpcao == K_Remarca
       If lBBD_ATERNA//BBD->( FieldPos("BBD_ATERNA") ) > 0
		  If oEnc:AENTRYCTRLS[nInd]:cReadVar $ "M->BBD_NOME,M->BBD_CODPAC,M->BBD_TELEFO,M->BBD_TIPO,M->BBD_MATANT,M->BBD_CODSOL,M->BBD_ATERNA"
		     oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
		  EndIf   
	   Else
		  If oEnc:AENTRYCTRLS[nInd]:cReadVar $ "M->BBD_NOME,M->BBD_CODPAC,M->BBD_TELEFO,M->BBD_TIPO,M->BBD_MATANT,M->BBD_CODSOL,M->BBD_TIPPAC"
		     oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
		  EndIf   		     
	   Endif
	Endif
	
	If nOpcao == K_Editar
       If lBBD_ATERNA//BBD->( FieldPos("BBD_ATERNA") ) > 0
		  If oEnc:AENTRYCTRLS[nInd]:cReadVar $ "M->BBD_NOME,M->BBD_CODPAC,M->BBD_TIPO,M->BBD_MATANT,M->BBD_ATERNA"
		     oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
		  Endif
	   Else
		  If oEnc:AENTRYCTRLS[nInd]:cReadVar $ "M->BBD_NOME,M->BBD_CODPAC,M->BBD_TIPO,M->BBD_MATANT"
		     oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
		  Endif
	   EndIf	  
	Endif
Next    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ No caso da agenda vou remarcacao...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcao == K_Remarca
	@ 205,040 Say oSay Prompt "F12 - Ver a Familia" Size 100,008 ;
	PIXEL OF oDlgMar FONT oFont01 COLOR CLR_HBLUE
ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcao == K_Remarca
   ACTIVATE MSDIALOG oDlgMar ON INIT Eval( { || nTamDlgPad := oDlgMar:nBottom, EnChoiceBar(oDlgMar,bokMar,bCancMar,.F.,aButtons) } ) 
ELSE
   ACTIVATE MSDIALOG oDlgRes ON INIT Eval( { || nTamDlgPad := oDlgRes:nBottom, EnChoiceBar(oDlgRes,bOK,bCanc,.F.,aButtons) } ) 
EndIf   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ inicia transacao na base se confirmado operacao..                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reposiciona no registro do credenciado selecionado...                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcao == K_Marcar .or. nOpcao == K_Sair
		BAU->( dbSetorder(01) )
		BAU->( MsSeek(xFilial("BAU")+Left(aVetMar[1,8], Len(BAU->BAU_CODIGO))) )
	Else
		BAU->( dbSetorder(01) )
		BAU->( MsSeek(xFilial("BAU")+Left(cCombo, Len(BAU->BAU_CODIGO))) )
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta campos e seus conteudos...                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begin Transaction

	If nOpcao == K_Agenda .Or. nOpcao == K_Marcar 
	    If nRecBBD > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona																			 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			BBD->( DbGoto(nRecBBD) )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a agenda e para um horario que foi cancelado e deleta o cancelamento	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			If !Empty( BBD->BBD_CODCAN )
				BHY->( DbSetOrder(1) ) //BHY_FILIAL + BHY_CODIGO + BHY_CODINT + BHY_CODLOC + DTOS(BHY_DATA) + BHY_HORA
				If BHY->( MsSeek( xFilial("BHY")+BBD->(BBD_CODIGO+BBD_CODINT+BBD_CODLOC+DtoS(BBD_DATA)+BBD_HORA) ) ) 
				   BHY->( Reclock("BHY",.F.) )
				   	 BHY->( DbDelete() )  
				   BHY->( msUnlock() ) 
		        EndIf            
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Deleta o agendamento																 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		    	BBD->( Reclock("BBD",.F.) )
					BBD->( DbDelete() )  
				BBD->( msUnlock() ) 
	        EndIf
	    EndIf
		BA1->(DbSetOrder(2))
		BA1->(MsSeek(xFilial("BA1")+AllTrim(M->BBD_CODPAC)))
		
		aadd(aDadBBD,{"BBD_CODEMP",BA1->BA1_CODEMP})
		aadd(aDadBBD,{"BBD_CONEMP",BA1->BA1_CONEMP})
		aadd(aDadBBD,{"BBD_VERCON",BA1->BA1_VERCON})
		aadd(aDadBBD,{"BBD_SUBCON",BA1->BA1_SUBCON})
		aadd(aDadBBD,{"BBD_VERSUB",BA1->BA1_VERSUB})
		aadd(aDadBBD,{"BBD_HORCAN",""} )
		aadd(aDadBBD,{"BBD_CODCAN",""} )
		If lBBD_DATCAN//BBD->( FieldPos("BBD_DATCAN") ) > 0					
		   aadd(aDadBBD,{"BBD_DATCAN",Ctod('')} )
		Endif                                        		
		aadd(aDadBBD,{"BBD_CODIGO",BAU->BAU_CODIGO})
		aadd(aDadBBD,{"BBD_CODINT",cCodInt})
		aadd(aDadBBD,{"BBD_DATA"  ,dData})
		aadd(aDadBBD,{"BBD_TIPO"  ,M->BBD_TIPO})	
		If ( M->BBD_TIPO # "4" ) .And. ! lEncaixe
			aadd(aDadBBD,{"BBD_STATUS","1"})
			If Type("M->BBD_HORA") == "C" .And. ! Empty(M->BBD_HORA)
   			   aadd(aDadBBD,{"BBD_HORA"  ,M->BBD_HORA})
			Else
			   aadd(aDadBBD,{"BBD_HORA"  ,TransForm(cHorario,cPictPad)})
			Endif
			aadd(aDadBBD,{"BBD_ENCAIX","0"})
		Else
			aadd(aDadBBD,{"BBD_STATUS","1"})
			aadd(aDadBBD,{"BBD_ENCAIX","1"})
			aadd(aDadBBD,{"BBD_HORA"  ,M->BBD_HORA})
		Endif		
		aadd(aDadBBD,{"BBD_PRTATD","0"})
		aadd(aDadBBD,{"BBD_CODESP",cComboEsp})
		aadd(aDadBBD,{"BBD_CODLOC",Eval(bCodLoc)})
		aadd(aDadBBD,{"BBD_LOCAL",Subs(cLocal,1,3)})
		aadd(aDadBBD,{"BBD_SIGLA",BAU->BAU_SIGLCR})
		aadd(aDadBBD,{"BBD_NUMREG",BAU->BAU_CONREG})
		aadd(aDadBBD,{"BBD_ESTCR",BAU->BAU_ESTCR})
		aadd(aDadBBD,{"BBD_CODPRF",BAU->BAU_CODBB0})
		aadd(aDadBBD,{"BBD_CODPAC",M->BBD_CODPAC})
		aadd(aDadBBD,{"BBD_NOME",M->BBD_NOME})
		aadd(aDadBBD,{"BBD_TELEFO",M->BBD_TELEFO})
		aadd(aDadBBD,{"BBD_USUOPE",PLRETOPE()})
		aadd(aDadBBD,{"BBD_MATANT",M->BBD_MATANT})
		aadd(aDadBBD,{"BBD_MATVID",BA1->BA1_MATVID})
		aadd(aDadBBD,{"BBD_CODSOL",M->BBD_CODSOL})
		aadd(aDadBBD,{"BBD_INIATE",cTimeIni})		
		aadd(aDadBBD,{"BBD_FIMATE",Time()})
		aadd(aDadBBD,{"BBD_DATDIG",Date()})
		aadd(aDadBBD,{"BBD_OBSERV",M->BBD_OBSERV})
		If lBBD_ATERNA//BBD->( FieldPos("BBD_ATERNA") ) > 0
		   aadd(aDadBBD,{"BBD_ATERNA",M->BBD_ATERNA})
		EndIf	
		If lBBD_TIPPAC//BBD->( FieldPos("BBD_TIPPAC") ) > 0
		   aadd(aDadBBD,{"BBD_TIPPAC",M->BBD_TIPPAC})
		EndIf	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso tenha sido uma autorizacao forcada, gravo o usuario...              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		If lForcaPro
			aadd(aDadBBD,{"BBD_USRFRC",aAutFor[Len(aAutFor),09]})       
			aadd(aDadBBD,{"BBD_OBSFRC",aAutFor[Len(aAutFor),12]})
		Else
			aadd(aDadBBD,{"BBD_OBSFRC",' '})
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava procedimento utilizado...                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If BBD->( FieldPos("BBD_CODPAD") ) > 0 .and. BBD->( FieldPos("BBD_CODPRO") ) > 0
			aadd(aDadBBD,{"BBD_CODPAD",Left(cCodPro,2)})
			aadd(aDadBBD,{"BBD_CODPRO",Substr(cCodPro,3,16)})
        Endif
       	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava campos retornados pelo Ponto de Entrada PLCAMMARC                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ              
		If ExistBlock("PLCAMMARC")
           If ValType(aNewCampos) == 'A'
               For nNewCampos :=1 To Len(aNewCampos)    
                  aadd(aDadBBD,{aNewCampos[nNewCampos],M->&(aNewCampos[nNewCampos])})
               Next
           EndIf   
        Endif	
        
		PLSAtuAge(aDadBBD)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Zera array de remarcacao...                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		aVetMar := {}
		
		lRet := .T.
	Elseif nOpcao == K_Sair
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona																			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		BBD->( DbGoto(aVetMar[1,11]) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a agenda e para um horario que foi cancelado e deleta o cancelamento	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		If !Empty( BBD->BBD_CODCAN )
			BHY->( DbSetOrder(1) ) //BHY_FILIAL + BHY_CODIGO + BHY_CODINT + BHY_CODLOC + DTOS(BHY_DATA) + BHY_HORA
			If BHY->( MsSeek( xFilial("BHY")+BBD->(BBD_CODIGO+BBD_CODINT+BBD_CODLOC+DtoS(BBD_DATA)+BBD_HORA) ) ) 
			   BHY->( Reclock("BHY",.F.) )
			   	 BHY->( DbDelete() )  
			   BHY->( msUnlock() ) 
	        EndIf
        EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Altera o Horario																	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		BBD->( Reclock("BBD",.F.) )
			If M->BBD_TIPO # "4" .And. ! lEncaixe
				BBD->BBD_STATUS	:= '1'
				BBD->BBD_ENCAIX	:= '0'
				BBD->BBD_HORA	:= TransForm(cHorario,cPictPad)
			Else
				BBD->BBD_STATUS	:= '1'
				BBD->BBD_ENCAIX	:= '1' 
				BBD->BBD_HORA 	:= M->BBD_HORA
			Endif		
			BBD->BBD_HORCAN := ''
			BBD->BBD_CODCAN	:= ''
			If lBBD_DATCAN//BBD->( FieldPos("BBD_DATCAN") ) > 0					
			   BBD->BBD_DATCAN := Ctod('')
			Endif               
			If lBBD_ATERNA//BBD->( FieldPos("BBD_ATERNA") ) > 0
			   BBD->BBD_ATERNA := "0"
			EndIf	
		BBD->( msUnlock()) 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Zera array de remarcacao...                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		aVetMar := {}
				
		lRet := .T.
	Else
		If nOpcao == K_Editar
			BBD->(RecLock("BBD",.F.))
				BBD->BBD_CODPAC := M->BBD_CODPAC
				BBD->BBD_NOME   := M->BBD_NOME
				BBD->BBD_TELEFO := M->BBD_TELEFO
				BBD->BBD_TIPO   := M->BBD_TIPO
				BBD->BBD_MATANT := M->BBD_MATANT
				BBD->BBD_CODSOL := M->BBD_CODSOL
				BBD->BBD_OBSERV := M->BBD_OBSERV
				If lBBD_ATERNA//BBD->( FieldPos("BBD_ATERNA") ) > 0
				   BBD->BBD_ATERNA := M->BBD_ATERNA
				EndIf	
			    If lBBD_TIPPAC//BBD->( FieldPos("BBD_TIPPAC") ) > 0
					BBD->BBD_TIPPAC := M->BBD_TIPPAC
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		        //³ Grava campos retornados pelo Ponto de Entrada PLCAMMARC                  ³
		        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ              
		        If ExistBlock("PLCAMMARC")
                   If ValType(aNewCampos) == 'A'
                      For nNewCampos :=1 To Len(aNewCampos)    
                         BBD->&(aNewCampos[nNewCampos]) := M->&(aNewCampos[nNewCampos])
                      Next
                   EndIf   
                Endif	
			BBD->(MsUnLock())
		Else
			If nOpcao <> K_Remarca .and. nOpcao <> K_Sair .Or. nOpcao == K_Marcar
				aadd(aDadBHY,{"BHY_CODIGO",BBD->BBD_CODIGO})
				aadd(aDadBHY,{"BHY_CODINT",BBD->BBD_CODINT})
				aadd(aDadBHY,{"BHY_DATA"  ,BBD->BBD_DATA})
				aadd(aDadBHY,{"BHY_HORA"  ,BBD->BBD_HORA})
				aadd(aDadBHY,{"BHY_TIPO"  ,BBD->BBD_TIPO})
				aadd(aDadBHY,{"BHY_ENCAIX",BBD->BBD_ENCAIX})
				aadd(aDadBHY,{"BHY_PRTATD",BBD->BBD_PRTATD})
				aadd(aDadBHY,{"BHY_CODESP",BBD->BBD_CODESP})
				aadd(aDadBHY,{"BHY_CODLOC",BBD->BBD_CODLOC})
				aadd(aDadBHY,{"BHY_LOCAL",BBD->BBD_LOCAL})
				aadd(aDadBHY,{"BHY_SIGLA",BBD->BBD_SIGLA})
				aadd(aDadBHY,{"BHY_NUMREG",BBD->BBD_ESTCR})
				aadd(aDadBHY,{"BHY_ESTCR",BBD->BBD_ESTCR})
				aadd(aDadBHY,{"BHY_CODPRF",BBD->BBD_CODPRF})
				aadd(aDadBHY,{"BHY_CODPAC",BBD->BBD_CODPAC})
				aadd(aDadBHY,{"BHY_NOME",BBD->BBD_NOME})
				aadd(aDadBHY,{"BHY_USUOPE",BBD->BBD_USUOPE})
				aadd(aDadBHY,{"BHY_CODCAN",M->BBD_CODCAN})
				aadd(aDadBHY,{"BHY_CODSOL",M->BBD_CODSOL})
				PLSCanAge(aDadBHY)
				
				BBD->(RecLock("BBD",.F.))
				If nOpcao <> K_Cancel
					BBD->BBD_STATUS := '7'
				Else
					BBD->BBD_STATUS := '7'
					BBD->BBD_CODCAN	:= M->BBD_CODCAN
				    BBD->BBD_HORCAN	:= Left(Time(),5)
					If lBBD_DATCAN//BBD->( FieldPos("BBD_DATCAN") ) > 0					
						BBD->BBD_DATCAN := M->BBD_DATCAN
					Endif
					If BBD->( FieldPos("BBD_USUCAN") ) > 0
						BBD->BBD_USUCAN := PLRETOPE()	
					Endif					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	             	//³ Grava campos retornados pelo Ponto de Entrada PLCAMMARC                  ³
		            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ              
		            If ExistBlock("PLCAMMARC")
                       If ValType(aNewCampos) == 'A'
                          For nNewCampos :=1 To Len(aNewCampos)    
                             BBD->&(aNewCampos[nNewCampos]) := M->&(aNewCampos[nNewCampos])
                          Next
                       EndIf   
                    Endif						
				Endif
				BBD->(MsUnLock())
			Endif
		Endif
		lRet := .T.		
	Endif
	End Transaction

	If ExistBlock("PLS300AGF")
		ExecBlock("PLS300AGF",.F.,.F., {nOpcao} )
	Endif	

	Eval(bVetAge)
	oHorarios:Setarray(aHorAge)
	oHorarios:Refresh()
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quanto a permanencia do usuario selecionado...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If nOpcao == K_Agenda
	If Aviso(STR0081,STR0082,{STR0083,STR0084}) == 1 //"Usuario selecionado..."###"Deseja manter o usuario selecionado?"###"&Não"###"&Sim"
		A300CLSUSR()
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle de transacao...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FCLOSE(nH)   
Ferase(cFile)                                                                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura dados...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := aOldTela
aGets := aOldGets               
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve o foco...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oHorarios:SetFocus()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A300VLDSELºAutor  ³Geraldo Felix Juniorº Data ³  06/13/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a confirmacao da agenda medica...                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A300VLDSEL(nOpca, lEncaixe, aGets, aTela, nOpcao, aHorAge, dData, cCodEsp,;
							nDsPer, oEnc, lMarcar, oDlgRes, cCodLoc)
LOCAL aRet := {}

// Conteudo inicial da variavel de controle eh 3, que significa negado.            
nOpca:=3
If !Obrigatorio(aGets,aTela)
	Return(.F.)
Endif
	
If lEncaixe .And. Empty(M->BBD_HORA)
	MsgInfo(STR0085) //"A hora e obrigatorio para encaixes."
	Return(.F.)
Endif

If (lEncaixe .And. (M->BBD_HORA < Left(Time(),5) .And. M->BBO_DATA==Date())) .Or. M->BBD_HORA>"23:59"
	MsgStop(STR0086) //"Hora invalida. Informe um horario valido!"
	Return(.F.)
Endif	
                   
If nOpcao==K_Agenda  
	If !lEncaixe
		lRet := A300VldAge(dData) //Chama validacao da agenda
		If !lRet
			Return(.F.)
		EndIf
	EndIf

	If M->BBD_TIPO <> '2'
		If !VerifBrw(aHorAge,3,7,M->BBD_CODPAC,STR0087) //"Paciente ja agendado nesta data"
			Return(.F.)
		Endif

		aRet := PLSA300CAR(M->BBD_CODPAC,Iif(lBBD_ATERNA/*BBD->( FieldPos("BBD_ATERNA") )>0*/,M->BBD_ATERNA,"0"),,cCodLoc,cCodEsp)
		lRet := Iif( ValType(aRet[1]) == 'L', aRet[1], .F.)
		If !lRet
			// Se criticar por periodicidade, o encaixe pode ser marcado como revisao.
			If (Len(aRet[2]) > 0 .and. aRet[2][1][1] == '018')
				If lEncaixe
				   cMSG := "Deseja marcar o encaixe como REVISÃO?"
				Else
   				   cMSG := "Deseja marcar a agenda como REVISÃO?"
				Endif   
				If Aviso("Revisão",cMSG, {"Sim","Não"}) == 2
					Return(.F.)
				Else
					M->BBD_TIPO := '2'
				Endif
			Else
				Return(.F.)
			Endif
		Endif
		
		If M->BBD_TIPO <> '2'
			If !PLSA300TPe(M->BBD_CODPAC,dData,cCodEsp,nDsPer,oEnc:oBox)
				Return(.F.)
			Endif
		Endif
	Else
		aRet := PLSA300CAR(M->BBD_CODPAC,Iif(lBBD_ATERNA/*BBD->( FieldPos("BBD_ATERNA") )>0*/,M->BBD_ATERNA,"0"),,cCodLoc,cCodEsp,.F.)
		lRet := Iif( ValType(aRet[1]) == 'L', aRet[1], .F.)
        
		// Se for autorizado, ou se a critica for diferente da periodicidade, nao permite agendar retorno.
		If lRet .or. (!lRet .and. Len(aRet[2]) > 0 .and. aRet[2][1][1] <> '018')
			BR8->( dbSetorder(01) )
			If BR8->( MsSeek(xFilial("BR8")+BBD->BBD_CODPAD+BBD->BBD_CODPRO) )
				cDesPro := Alltrim(BR8->BR8_DESCRI)
			Endif
	
			nOpcao := Aviso(STR0088, STR0092,; //"Revisão"###"Não será possível marcar o retorno porque não existe consulta realizada no período mínimo."
						{STR0093}) //"Retornar"
                                                         
			Return(.F.)
		Endif		
	Endif
Endif 		

If nOpcao == K_Marcar
	lRet := A300VldAge(dData)		//Chama validacao da agenda se for marcacao
	If !lRet
		Return(.F.)
	EndIf
EndIf

// Conteudo inicial da variavel...
nOpca := 1
lMarcar := .T.

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA300   ºAutor  ³Microsiga           º Data ³  04/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLSA300DAT(cTipo,oEnc,bFiltro,nDsPes,dData, lStart)
LOCAL dAux       
LOCAL nInd
LOCAL dOldData
LOCAL lRet := .F.                          
DEFAULT lStart := .F.
                                  
If lStart
	If Eval(bFiltro)
		M->BBO_DIASEM := PLSDIASEM(dData)
		oEnc:oBox:Refresh()
		lRefresh := .T.
		Return(.T.)
	Endif
Endif
    	    
If Empty(dData)
   dData := Date()
   dOldData := dData
   dAux     := dData 
Else
   dAux := dData
   dOldData := dData
   dAux := IF((cTipo=="1" .or. cTipo=="4"),(dAux+1),(dAux-1))
Endif   

For nInd := 1 To nDsPes   
	lMove := .T.
    If dtos(dAux) < dtos(Date())
       Exit
    Endif                                                

    M->BBO_DATA	:= dAux
    lRet		:= Eval(bFiltro)
    
    If lRet 
       M->BBO_DIASEM := PLSDIASEM(dAux)
       oEnc:oBox:Refresh()
       lRefresh := .T.       
       Exit
    Endif  
                          
    If cTipo > "2"
    	Exit
    Endif
    
    dAux := IF((cTipo=="1" .or. cTipo=="4"),(dAux+1),(dAux-1))
Next

If ! lRet .and. cTipo < "3"
   M->BBO_DATA   := dOldData
   Aviso(STR0094,STR0095,{"Ok"}) //"Indisponivel"###"Nao existe agenda disponivel para o filtro informado."
Else
    If dtos(dAux) >= dtos(Date())
	   M->BBO_DIASEM := PLSDIASEM(dAux)
	EndIf   
   oEnc:oBox:Refresh()
   lRefresh := .T.
Endif    

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA300PQ  ³ Autor ³Geraldo Felix Junior³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa a agenda na base de dados...                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA300Pq(cNomPac,aBrowPac,aVetPad,oBrowPac)
LOCAL cSQL  
LOCAL cNmMed
LOCAL dDt
LOCAL cNReduz	:= ''
LOCAL cNomTit	:= ''
LOCAL cNomSol	:= ''
LOCAL cDesLocal	:= ''
LOCAL cDesEsp	:= ''
LOCAL aArea		:= GetArea()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa resultado...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aBrowPac := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua busca...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := " SELECT BBD_CODINT, BBD_FILIAL, BBD_CODPAC, BBD_NOME, BBD_HORA, BBD_DATA, BBD_CODIGO, BBD_CODESP, BBD_CODSOL, " 
cSQL += " BBD_LOCAL, BBD_CODLOC, BBD_USUOPE, R_E_C_N_O_ AS REGBBD FROM "+RetSQLName("BBD")
cSQL += " WHERE BBD_FILIAL = '"+xFilial("BBD")+"' "
cSQL += "   AND BBD_CODCAN = '' "
cSql += "   AND BBD_TIPOPA = '' "
cSQL += "   AND BBD_NOME LIKE '%"+AllTrim(cNomPac)+"%' "  
cSQL += "   AND BBD_DATA   >= '"+dtos(dDataBase)+"' "
cSQL += "   AND D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY BBD_FILIAL,BBD_NOME,BBD_DATA,BBD_HORA "
                                        
PLSQuery(cSQL,"TrbPes")
TrbPes->(DbGoTop())

While ! TrbPes->(Eof())

	dDt    := TrbPes->BBD_DATA
	dDt    := dtoc(dDt) + " ("+PLSDIASEM(dDt)+")"
	
	BAU->( dbSetorder(01) )
	BAU->( MsSeek(xFilial("BAU")+TrbPes->BBD_CODIGO) )
	If !Empty(BAU->BAU_LEGEND)
		cNmMed := AllTrim(X3COMBO("BAU_LEGEND",BAU->BAU_LEGEND))+". "
	Else
		cNmMed := ''
	Endif
	cNmMed += AllTrim(BAU->BAU_NOME)
                                   
	cDesLocal 	:= Posicione("BD1",1, xFilial("BD1")+TrbPes->BBD_CODINT+TrbPes->BBD_LOCAL, "BD1_DESLOC" )
	cDesEsp		:= Posicione("BAQ",1, xFilial("BAQ")+TrbPes->BBD_CODINT+TrbPes->BBD_CODESP, "BAQ_DESCRI" )
		
	cNReduz:= Posicione("BA1",2,xFilial("BA1")+TrbPes->BBD_CODPAC,"BA1_NREDUZ")
	If Empty(cNReduz)
	   BA3->( DbSetOrder(01) )
   	   BA3->( MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)) )
	   cNReduz := Posicione("BG9",1,xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_TIPOUS),"BG9_NREDUZ")
	EndIf
	cNomTit:= Posicione("BA1",2,xFilial("BA1")+Substr(TrbPes->BBD_CODPAC,1, 14)+GetNewPar("MV_PLCDTGP","01"),"BA1_NOMUSR")//Codigo do Grau de Parentesco do Titular
	cNomSol:= Iif(TrbPes->BBD_CODSOL == '999999','PACIENTE',TrbPes->BBD_CODSOL+'-'+;
			  Posicione("BAU",1,xFilial("BAU")+TrbPes->BBD_CODSOL,"BAU_NOME"))
		
	TrbPes->(aadd(aBrowPac,{BBD_NOME,;	
							 dDt,;
							 BBD_HORA,;
							 cNmMed,;
							 cDesEsp,;
							 cDesLocal,;
							 REGBBD,;
							 BBD->BBD_MATANT,;
							 REGBBD,;
							 cNReduz,;
							 cNomTit,;
							 TrbPes->BBD_CODPAC,;
							 TrbPes->BBD_USUOPE,;
							 cNomSol}))
	TrbPes->(DbSkip())
Enddo
      
TrbPes->(DbCloseArea())
RestArea(aArea)
DbSelectArea("BA1")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa resultado da pesquisa...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aBrowPac) == 0
   aBrowPac := aClone(aVetPad)
Endif       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza browse...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowPac:SetArray(aBrowPac)
oBrowPac:Refresh()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)
                                
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA300MAR ³ Autor ³Geraldo Felix Junior³ Data ³ 18.09.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a funcao de remarcacao de consulta.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLS300MAR(dData, cMedico, oHorarios)

LOCAL lRet := .T.
LOCAL cMotBlo := GetNewPar("MV_PLSREMR",'01')//Codigo do motivo de bloqueio utilizado na remarcacao de consultas

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta matriz com dados da origem para o caso de estorno...            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ           
lMarcar := .F.
aVetMar := {}
aadd(aVetMar,{M->BBD_CODPAC,;
			  M->BBD_NOME,;
			  M->BBD_TELEFO,;
			  M->BBD_TIPO,;
			  M->BBD_MATANT, ;
			  M->BBD_CODSOL, ;
			  M->BBD_HORA, ;
			  cMedico, ;
			  dData,;
			  M->BBD_NOMSOL,;
			  oHorarios:aArray[oHorarios:nAt,6],;
			  oHorarios:aArray[oHorarios:nAt,9],;
			  M->BBD_OBSERV,;
			  Iif(lBBD_ATERNA/*BBD->( FieldPos("BBD_ATERNA") ) > 0*/,M->BBD_ATERNA,"0") })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fixa dados do paciente no filtro da rotina...                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BBO->(RecLock("BBO",.F.))
	BBO->BBO_CODPAC	:= M->BBD_CODPAC
	BBO->BBO_NOME	:= M->BBD_NOME                        
	BBO->BBO_MATANT	:= M->BBD_MATANT
	BBO->BBO_TELEFO	:= M->BBD_TELEFO                                       
	If lBBD_ATERNA .And. lBBO_ATERNA //BBD->( FieldPos("BBD_ATERNA") ) > 0 .And. BBO->( FieldPos("BBO_ATERNA") ) > 0
	   BBO->BBO_ATERNA := M->BBD_ATERNA
	EndIf   
	BBO->BBO_USRFRC := BBD->BBD_USRFRC
	BBO->BBO_CODCRE := BAU->BAU_CODIGO
	M->BBO_CODCRE	:= BAU->BAU_CODIGO
	M->BBO_NOMCRE	:= BAU->BAU_NOME	
BBO->(MSUnlock())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza dados na tela...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSay1:Refresh()
oSay2:Refresh()
oSay3:Refresh()
oSay4:Refresh()
If lBBO_ATERNA//BBO->( FieldPos("BBO_ATERNA") ) > 0
   oSay5:Refresh()
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cancela consulta original...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	          
BBD->(RecLock("BBD",.F.))
	BBD->BBD_STATUS := '7'                          
	BBD->BBD_CODCAN := cMotBlo
	BBD->BBD_HORCAN := Left(Time(),5)
	If lBBD_DATCAN//BBD->( FieldPos("BBD_DATCAN") ) > 0
		BBD->BBD_DATCAN := Date()
	Endif
BBD->(MSUnlock())

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA300FAMºAutor  ³Geraldo Felix Juniorº Data ³  09/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostrar a familia do usuario posicionado.                  º±±
±±ºUso       ³ Marcacao de consultas.                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA300FAM(cChave)
LOCAL cSql
LOCAL oSyFam
LOCAL oGrpFam
LOCAL oSyEmp
LOCAL oGrpEmp
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usuarios...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oBrwusr
LOCAL aCabUsr  	:= {}
LOCAL aDadUsr  	:= {}
LOCAL aTrbUsr  	:= {}

LOCAL cMatFam   := ''
LOCAL cNomTit   := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a aHeader dos usuarios da familia                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BA1" TO aCabUsr FOR SX3->(X3_CAMPO $ "BA1_MATUSU" .or.;
										 X3_CAMPO $ "BA1_NOMUSR"  .or.;
										 X3_CAMPO $ "BA1_DESUSU" .or.;
										 X3_CAMPO $ "BA1_TELEFO" .or.;
										 X3_CAMPO $ "BA1_DESGRA" )      
										 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona usuario...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ										 										 
cChave  := StrTran(StrTran(cChave,'.',''),'-','')
cCodInt := Substr(cChave, atCodOpe[1], atCodOpe[2])
cCodEmp := Substr(cChave, atCodEmp[1], atCodEmp[2])
cMatric := Substr(cChave, atMatric[1], atMatric[2])

BA1->(DbSetOrder(2))
If ! BA1->(MsSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric))
	MsgAlert(STR0096+cChave) //"Usuario nao encontrado:"
	Return()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta matricula da familia do usuario...                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMatFam := BA1->( BA1_CODINT + BA1_CODEMP + BA1_MATRIC )
                                                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona familia...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA3->( dbSetorder(01) )
If ! BA3->( MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)) )
	MsgAlert( STR0097+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) ) //"Familia nao encontrada:"
	Return()
Endif	      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fixa o nome do titular da familia...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomTit := BA1->BA1_NOMUSR
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados com os usuarios da familia                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store COLS "BA1" TO aDadUsr FROM aCabUsr VETTRAB aTrbUsr While xFilial("BA1")+cMatFam == BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
	
DEFINE MSDIALOG oDlgFam TITLE Alltrim(cNomTit) FROM 019.5,001 TO 37, 100 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Usuarios                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 033,002 GROUP oGrpFam TO 050, 390 PIXEL OF oDlgFam LABEL STR0098 COLOR CLR_HBLUE, CLR_HRED //" Familia de "
@ 040,008 Say oSyFam Prompt Alltrim(cNomTit) Size 150,008 PIXEL OF oDlgFam COLOR CLR_HBLUE

oBrwUsr            := TPLSBrw():New(055,002,390,125,nil  ,oDlgFam,nil    , nil ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabUsr ,aDadUsr ,.T.      ,"BA1" ,K_Visualizar,STR0099,{{"BA1_MOTBLO","<>","''"}},nil,nil,aTrbuSR) //"Usuarios"

ACTIVATE MSDIALOG oDlgFam ON INIT Eval({||EnChoiceBar(oDlgFam,{||oDlgFam:End()},{||oDlgFam:End()},.F.)} )

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA300LISUSR     ³Geraldo Felix Juniorº Data ³  29/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Novo conceito na listagem de pacientes.                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS300LISUSR(cCodEsp,dData,nTamDlgBrw,aListaUsr,oListaUsr,;
                             nOpcao,oEnc,oDlgRes,nDsPer,cNome,lDireto) //,cCodSubEsp)
                             
LOCAL bOk := { || If(PLSA300TPe(aListaUsr[oListaUsr:nAt,2],dData,cCodEsp,nDsPer,;
oEnc:oBox, lDireto),(cChave := aListaUsr[oListaUsr:nAt,2], cChave := StrTran(cChave,".",""),;
 cChave := StrTran(cChave,"-",""), M->BBO_NOME := IF(Empty(aListaUsr[oListaUsr:nAt,1]),;
 M->BBO_NOME,aListaUsr[oListaUsr:nAt,1])    , ;
 M->BBO_NOMEMP := Iif(Empty(aListaUsr[oListaUsr:nAt,1]),M->BBO_NOMEMP,Alltrim(aListaUsr[oListaUsr:nAt,8])),;
 M->BBO_CODPAC := IF(Empty(cChave),M->BBO_CODPAC,cChave) , ;
 M->BBO_TELEFO := aListaUsr[oListaUsr:nAt,3], M->BBO_MATANT := IF(Empty(aListaUsr[oListaUsr:nAt,6]),;
 M->BBO_MATANT,aListaUsr[oListaUsr:nAt,6]),     ;
 lRefresh := .T., oDlgRes:Refresh(), oEnc:oBox:SetFocus(),oDlgUsu:End()),oDlgUsu:End()) }
 
 LOCAL aButtons := {}
                     
 DEFAULT lDireto  := .F.
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tecla de Atalho para visualizar a Familia do usuario posicionado.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cNome)
	Return()
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define botao...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aButtons, {"BMPGROUP"   ,{|| PLSA300FAM(aListaUsr[oListaUsr:nAt,2],,aListaUsr[oListaUsr:nAt,1],aListaUsr[oListaUsr:nAt,8],cCodEsp,dData,nTamDlgBrw,aListaUsr,oListaUsr,nOpcao,oEnc,oDlgRes,nDsPer) },STR0100,STR0101} ) //"Visualizar Familia - <CTRL + A>"###"Familia"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o CTRL+A...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_LBUTTON,{||PLSA300FAM(aListaUsr[oListaUsr:nAt,2],,aListaUsr[oListaUsr:nAt,1],aListaUsr[oListaUsr:nAt,8],cCodEsp,dData,nTamDlgBrw,aListaUsr,oListaUsr,nOpcao,oEnc,oDlgRes,nDsPer)})
                           
DEFINE MSDIALOG oDlgUsu TITLE STR0099 FROM 018,005 TO 28, 100 OF oDlgRes //"Usuarios"

oListaUsr := TcBrowse():New( If(nOpcao==K_Cancel,180,013), 002, 372, 062,,,, oDlgUsu,,,,,,,,,,,, .F.,, .T.,, .F., )
oListaUsr:SetArray(aListaUsr)

//ADD COLUMN TO oListaUsr BITMAP DATA IF(!Empty(aListaUsr[olistaUsr:nAt,5]),LoadBitmap( GetResources(), "ENABLE" ),LoadBitmap( GetResources(), "DISABLE" )) TITLE "" WIDTH 015 NOHILITE

oListaUsr:AddColumn(TcColumn():New(" ",iif(!Empty(aListaUsr[olistaUsr:nAt,5]),{||LoadBitmap( GetResources(), "ENABLE" )},{||LoadBitmap( GetResources(), "DISABLE" )}),;
         nil,nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))

oListaUsr:AddColumn(TcColumn():New(STR0102,nil,; //"Nome"
nil,nil,nil,nil,075,.F.,.F.,nil,nil,nil,.F.,nil))
oListaUsr:ACOLUMNS[2]:BDATA     := { || aListaUsr[oListaUsr:nAt,1] }

oListaUsr:AddColumn(TcColumn():New(STR0103,nil,; //"Matricula"
nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))
oListaUsr:ACOLUMNS[3]:BDATA     := { || aListaUsr[oListaUsr:nAt,2] }

oListaUsr:AddColumn(TcColumn():New(STR0104,nil,; //"Matricula Antiga"
nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))
oListaUsr:ACOLUMNS[4]:BDATA     := { || aListaUsr[oListaUsr:nAt,6] }

oListaUsr:AddColumn(TcColumn():New(STR0012,nil,; //"Empresa"
nil,nil,nil,nil,140,.F.,.F.,nil,nil,nil,.F.,nil))
oListaUsr:ACOLUMNS[5]:BDATA     := { || aListaUsr[oListaUsr:nAt,8] }

oListaUsr:AddColumn(TcColumn():New(STR0105,nil,; //"Nome da Mae"
nil,nil,nil,nil,075,.F.,.F.,nil,nil,nil,.F.,nil))
oListaUsr:ACOLUMNS[6]:BDATA     := { || aListaUsr[oListaUsr:nAt,7] }

oListaUsr:AddColumn(TcColumn():New(STR0005,nil,; //"Telefone"
nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))
oListaUsr:ACOLUMNS[7]:BDATA     := { || aListaUsr[oListaUsr:nAt,3] }

oListaUsr:BLDBLCLICK := bOk

ACTIVATE MSDIALOG oDlgUsu ON INIT Eval({||EnChoiceBar(oDlgUsu,{||Eval(bOk),oDlgUsu:End()},{||oDlgUsu:End()},.F.)} )
                                                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefine o CTRL+A...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET KEY VK_LBUTTON TO

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA300Age ³ Autor ³ Geraldo Felix Jr.  ³ Data ³ 09.05.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de apoio para criar as matrizes da agenda.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSA300Age(aColunas,cCodOpe,aBrwHor,dDtRec, oListLoc, cCodEsp) 
Local nCnt
LOCAL cSQL
LOCAL aAux          
LOCAL cNReduz
LOCAL lAux := .F.
LOCAL nSala := 1
LOCAL nAux      
LOCAL nHorAbert := 0                       
LOCAL nRecBBDCan:= 0                       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis para utilizacao nas querys...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cBB7Name  := BB7->(RetSQLName("BB7"))
LOCAL cBB8Name  := BB8->(RetSQLName("BB8"))
LOCAL cBAUName  := BAU->(RetSQLName("BAU"))
LOCAL cBAQName  := BAQ->(RetSQLName("BAQ"))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o dia...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cMes		:= StrZero(Month(dDtRec),2)   
LOCAL cDiaMes	:= StrZero(Day(dDtRec),2)
LOCAL cDia		:= Alltrim(Str(Dow(dDtRec)))
LOCAL cAno		:= Alltrim(Str(Year(dDtRec)))
LOCAL cHoraEnt  := ""
LOCAL cHoraSai  := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montar variaveis para utilizacao nas querys...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados da agenda...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BB7_CODIGO, BB7_DIA, BB7_CODESP, BB7_CODINT, BB7_HORENT, BB7_CODLOC, BB7_HORSAI, BB7_EXCINI, BB7_EXCFIN, BB7_PLTINI, BB7_PLTFIN, BB7_INTERV, "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do local de atendimento...                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BB8_CODIGO, BB8_CODLOC, BB8_LOCAL, BB8_CODINT, BB8_TMPCON, "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do medico...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BAU_CODIGO, BAU_NOME, BAU_LEGEND, "+cBAUName+".R_E_C_N_O_ AS REGBAU, "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados da especialidade...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BAQ_CODESP, BAQ_DESCRI "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta From...                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "FROM "+cBB7Name+", "+cBAUName+", "+cBB8Name+", "+cBAQName+" "

cSQL += "WHERE "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta wheres padroes para os arquivos envolvidos...                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BB7_FILIAL = '"+xFilial("BB7")+"' AND "
cSQL += "BAU_FILIAL = '"+xFilial("BAU")+"' AND "
cSQL += "BB8_FILIAL = '"+xFilial("BB8")+"' AND "
cSQL += "BAQ_FILIAL = '"+xFilial("BAQ")+"' AND "

cSQL += cBB7Name+".D_E_L_E_T_ = '' AND "
cSQL += cBAUName+".D_E_L_E_T_ = '' AND "
cSQL += cBB8Name+".D_E_L_E_T_ = '' AND "
cSQL += cBAQName+".D_E_L_E_T_ = '' AND "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Relaciona o BB7 com os arquivos envolvidos na query...                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BB7_CODIGO = BAU_CODIGO AND "
cSQL += "BB7_CODINT = BB8_CODINT AND "
cSQL += "BB7_CODIGO = BB8_CODIGO AND "
cSQL += "BB7_CODLOC = BB8_CODLOC AND "
cSQL += "BAQ_CODESP = BB7_CODESP AND "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o filtro no arquivos de agendas...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "BB7_DIA    = '"+cDia+"' AND "
cSQL += "BB7_MES    = '"+cMes+"' AND "
cSQL += "BB7_ANO    = '"+cAno+"' AND "
cSQL += "BB7_DIAMES = '"+cDiaMes+"' AND "
cSQL += "BB7_CODINT = '"+cCodOpe+"' AND "
cSQL += "BB7_CODESP = '"+cCodEsp+"' AND "                             
cSQL += "BB8_LOCAL  = '"+aColunas[oListLoc:nAt,1]+"' "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Order by ...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL += "ORDER BY BAU_FILIAL,BAU_NOME"

PLSQuery(cSQL,"Trb300")

Trb300->(DbGoTop())

aBrwHor 	:= {}
aMedDis		:= {}

If TRB300->(Eof())

	aadd(aBrwHor,{'',;
	'',;
	"",;
	"",;
	"",;
	0,;
	"",;
	"",;
	"",;
	"",;
	0 ,;
	'',;
	.T.,;
	"",;
	"0"})
	
Else
	//cHoraEnt := Trb300->BB7_HORENT
	//cHoraSai := Trb300->BB7_HORSAI
	While ! TRB300->(Eof())
		
	    cHoraEnt := Trb300->BB7_HORENT
	    cHoraSai := Trb300->BB7_HORSAI

		aAux := TRB300->(PLSA300HR(BB7_HORENT,BB7_HORSAI,Iif(!Empty(BB7_INTERV),BB7_INTERV,BB8_TMPCON),BB7_EXCINI,BB7_EXCFIN))
		
		If Alltrim(TRB300->BB7_CODIGO) == Left(cCombo,Len(BAU->BAU_CODIGO))
			For nAux := 1 To Len(aAux)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Para controle de horario cancelado										 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nRecBBDCan := 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Matriz principal de horarios											 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( Ascan(aBrwHor,{|a| a[1]+a[2] = TRB300->(BB7_CODIGO)+aAux[nAux] }) == 0 )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Checa se tem horario usado												 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If BBD->(MsSeek(xFilial("BBD")+TRB300->BB7_CODIGO+cCodOpe+TRB300->BB8_CODLOC+dtos(dDtRec)+aAux[nAux]+Space(02)))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Enquanto for o mesmo horario											 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						While !BBD->( Eof() ) .And. BBD->(BBD_CODIGO+BBD_CODINT+BBD_CODLOC+DTOS(BBD_DATA)+BBD_HORA) == TRB300->BB7_CODIGO+cCodOpe+TRB300->BB8_CODLOC+dtos(dDtRec)+aAux[nAux]
							If BBD->BBD_PRTATD == "0" .AND. BBD->BBD_ENCAIX == "0" 
					   			If BBD->BBD_STATUS $ '7,8'
					   				lAux := .F.
					   				BBD->( dbSkip() )
					   				Loop
					   			Else
					   				lAux := .T.
					   			Endif
							Else
								lAux := .F.
							Endif              
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Tem que ser diferente de cancelado pq o horarios pode ter sido utilizado ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lAux .And. BBD->BBD_STATUS <> '7' 
							   Exit         
							EndIf
							BBD->( dbSkip() )
						EndDo     

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Monta matriz															 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lAux
							cNReduz:= Posicione("BA1",2,xFilial("BA1")+BBD->BBD_CODPAC,"BA1_NREDUZ")
							If Empty(cNReduz)
							   BA3->( DbSetOrder(01) )
						   	   BA3->( MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)) )
							   cNReduz := Posicione("BG9",1,xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_TIPOUS),"BG9_NREDUZ")
							EndIf
							aadd(aBrwHor,{	TRB300->(BB7_CODIGO),;
											aAux[nAux],;
											BBD->BBD_CODPAC,;
											BBD->BBD_NOME,;
											BBD->BBD_TELEFO,;
											BBD->(Recno()),;
											BBD->BBD_STATUS,;
											AllTrim(X3COMBO("BAU_LEGEND",TRB300->BAU_LEGEND))+". "+AllTrim(TRB300->BAU_NOME),;
											BBD->BBD_ENCAIX,;
											BBD->BBD_CODCAN,;
											TRB300->REGBAU,;
											TRB300->BB7_CODLOC,;
											.T.,;
											cNReduz,;
											Iif(lBBD_ATERNA/*BBD->(FieldPos("BBD_ATERNA") ) > 0*/,BBD->BBD_ATERNA,"0") })
						Else
							aadd(aBrwHor,{	TRB300->(BB7_CODIGO),;
											aAux[nAux],;
											"",;
											"",;
											"",;
											0,;
											"",;
											"",;
											"",;
											"",;
											0 ,;
											TRB300->BB7_CODLOC,;
											.T.,;
											"",;
											"0"})
						Endif
					Else
		  				aadd(aBrwHor,{	TRB300->(BB7_CODIGO),;
										aAux[nAux],;
										"",;
										"",;
										"",;
										0,;
										"",;
										"",;
										"",;
										"",;
										0 ,;
										TRB300->BB7_CODLOC,;
										.T.,;
										"",;
										"0"})
					Endif
				Endif
			Next
		Else
			For nAux := 1 To Len(aAux)
				If BBD->(MsSeek(xFilial("BBD")+TRB300->BB7_CODIGO+cCodOpe+TRB300->BB8_CODLOC+dtos(dDtRec)+aAux[nAux]+Space(02)))
					While !BBD->( Eof() ) .And. BBD->(BBD_CODIGO+BBD_CODINT+BBD_CODLOC+DTOS(BBD_DATA)+BBD_HORA) == TRB300->BB7_CODIGO+cCodOpe+TRB300->BB8_CODLOC+dtos(dDtRec)+aAux[nAux]
						If BBD->BBD_PRTATD == "0" .And. BBD->BBD_ENCAIX == "0" 
							If BBD->BBD_STATUS $ '7,8' 
								lAux := .T.
							Else
								lAux := .F.
							Endif
						Else
							lAux := .F.
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Tem que ser diferente de cancelado pq o horarios pode ter sido utilizado ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lAux .And. BBD->BBD_STATUS <> '7' 
						   Exit
                        EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Proximo registro														 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						BBD->( dbSkip() )
					EndDo	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se o horario esta livre													 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lAux
					   Exit
                    EndIf
				Else
					lAux := .T.						
					Exit
				EndIf	        
			Next
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se achou horario livre													 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lAux             
			   AaDd( aMedDis, { TRB300->(BB7_CODIGO) } )
			EndIf
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Proximo registro														 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TRB300->(DbSkip())
	Enddo
Endif

TRB300->(DbCloseArea())
DbSelectArea("BBD")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os horarios de encaixe...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BBD_CODIGO,BBD_HORA,BBD_CODPAC,BBD_NOME,BBD_TELEFO,R_E_C_N_O_,BBD_STATUS,BBD_ENCAIX,BBD_CODCAN,BBD_CODLOC, "
cSQL += Iif(lBBD_ATERNA/*BBD->(FieldPos("BBD_ATERNA") ) > 0*/,"BBD_ATERNA",'"0" BBD_ATERNA')
cSQL += " FROM "+BBD->(RetSQLName("BBD"))
cSQL += " WHERE BBD_FILIAL	= '"+xFilial("BBD")+"' "
cSQL += "   AND BBD_LOCAL	= '"+aColunas[oListLoc:nAt,1]+"' "
cSQL += "   AND BBD_DATA 	= '"+dtos(dDtRec)+"' "
cSQL += "   AND BBD_CODINT	= '"+cCodOpe+"' "
//cSQL += "   AND BBD_NUMATE	= '"+Space(Len(BBD->BBD_NUMATE))+"' "
cSQL += "   AND BBD_ENCAIX	= '1' "
cSQL += "   AND BBD_CODIGO  = '"+Left(cCombo,LEN(BBD->BBD_CODIGO))+"' "
If lBBD_DATCAN//BBD->( FieldPos("BBD_DATCAN") ) > 0
	cSql += " AND ( BBD_STATUS <> '7' OR (BBD_STATUS = '7' AND BBD_DATCAN = '"+dTos(M->BBO_DATA)+"') ) "
Else
	cSql += " AND BBD_STATUS <> '7' "
Endif
cSQL += "   AND D_E_L_E_T_	= ' ' "
cSQL += "ORDER BY BBD_FILIAL"

PLSQuery(cSQL,"Trb300")

Trb300->(DbGoTop())
While ! Trb300->(Eof())
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Posiciona no credenciado...                                              ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     BAU->(DbSetOrder(1))
     BAU->(MsSeek(xFilial("BAU")+Trb300->(BBD_CODIGO)))
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Para cada encaixe adiciona no vetor...                                   ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     aadd(aBrwHor,{Trb300->(BBD_CODIGO),;     
                      Trb300->BBD_HORA,;
                      Trb300->BBD_CODPAC,;
                      Trb300->BBD_NOME,;
                      Trb300->BBD_TELEFO,;
                      Trb300->R_E_C_N_O_,;
                      Trb300->BBD_STATUS,;
                      AllTrim(X3COMBO("BAU_LEGEND",BAU->BAU_LEGEND))+". "+AllTrim(BAU->BAU_NOME),;
                      Trb300->BBD_ENCAIX,;
                      Trb300->BBD_CODCAN,;
                      Trb300->R_E_C_N_O_,;
					  Trb300->BBD_CODLOC,;
					  .T.,;
					  "",;
					  Trb300->BBD_ATERNA })
	Trb300->(DbSkip())
Enddo
DbSelectArea("BBD")       


If Len(aBrwHor) > 0 
	cSQL := "SELECT * FROM "+RetSQLName("BBQ")+" WHERE "
	cSQL += "BBQ_FILIAL = '"+xFilial("BBQ")+"' AND "
	cSQL += "BBQ_CODINT = '"+cCodOpe+"' AND "
	cSQL += "BBQ_CODRDA = '"+Left(cCombo,LEN(BBD->BBD_CODIGO))+"' AND "
	cSQL += "BBQ_CODLOC = '"+aColunas[oListLoc:nAt,1]+"' AND "
	cSQL += "'"+dtos(dDtRec)+"' >= BBQ_DATDE AND '"+dtos(dDtRec)+"' <= BBQ_DATATE AND "
	cSQL += "D_E_L_E_T_ = ''"
	PLSQuery(cSQL,"TRBBBQ")
	
	If TRBBBQ->( Eof() )
		aHorAge := aClone(aBrwHor)
	Else
		aHorAge := {}
	Endif
	
	While !TRBBBQ->( Eof() )
		For nCnt := 1 To Len(aBrwHor)
			If aBrwHor[nCnt][2] >= TRBBBQ->BBQ_HORDE .and. aBrwHor[nCnt][2] <= TRBBBQ->BBQ_HORATE
				// Adiciona horario na matriz, pois existe paciente para ser remarcado.
				If !Empty(aBrwHor[nCnt][3])
					aBrwHor[nCnt][13] := .F.
					Aadd(aHorAge, aClone(aBrwHor[nCnt]))
				Endif
			Else
				Aadd(aHorAge, aClone(aBrwHor[nCnt]))
			Endif
		Next
		TRBBBQ->( dbSkip() )
	Enddo
	TRBBBQ->( dbCloseArea() )
Endif

If Len(aHorAge) == 0
	aadd(aBrwHor,{'',;
		'',;
		"",;
		"",;
		"",;
		0,;
		"",;
		"",;
		"",;
		"",;
		0 ,;
		'',;
		.T.,;
		"",;
		"0"})
Endif
	
Asort(aHorAge,,,{|x,y| x[2] < y[2]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha Area de Trabalho...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Trb300->(DbCloseArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³PLSA300CALLºAutor  ³Geraldo Felix Juniorº Data ³  13/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamada da tela de identificacao do usuario ao telefone.   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA300CALL(cCodEsp,dData,nLen,aListaUsr,oListaUsr, nOpcao, oDlgPes, nDsPer, cCodLoc) 

LOCAL aFields		:= {}
LOCAL oDlg
LOCAL oGrupo
LOCAL oUsr
LOCAL nOpca 	  	:= 2
LOCAL bOk			:= {|| Iif(Obrigatorio(aGets,aTela),(nopca := 1,oDlg:End()),NIL)}
LOCAL aButtons		:= {}

PRIVATE aTela     	:= {}
PRIVATE aGets     	:= {}
PRIVATE lRefresh  	:= .F.
                                                        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define botoes...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                           
aadd(aButtons,{"POSCLI"  ,{ || A300INTGER() },STR0106,STR0107}) //"Usuarios de Outros Intercambios"###"Intercamb"
aadd(aButtons,{"HISTORIC",{ || PLSHISTCON() },STR0108,STR0109}) //"Historico de Consultas"###"Historico"

If ExistBlock("PL300F11") 
	If ExistBlock('PL300DAD')
		aDadBt:=Execblock("PL300DAD",.F.,.F.)	
	    cPictBt:= aDadBt[1]
	    cDescBt:= aDadBt[2]
	    cTitBt := aDadBt[3]
	Else 
		cPictBt:= "S4WB007N"
		cDescBt:= "PL300F11"
	    cTitBt := "PL300F11"
	Endif
	aadd( aButtons,{cPictBt,{ || ExecBlock("PL300F11",.F.,.F.,{M->BBO_CODPAC,M->BBO_CODESP}) },cDescBt,cTitBt} )
Endif

@ 001,001 BUTTON STR0110 SIZE 000,00 ACTION Eval({||A300INTGER()}) PIXEL  //"&Intercambio"
//BBO->(RegToMemory("BBO",.F.,.T.,.T.))

Aadd(aFields, "BBO_NOME")
Aadd(aFields, "BBO_CODPAC")
Aadd(aFields, "BBO_TELEFO")
Aadd(aFields, "BBO_MATANT")    
Aadd(aFields, "BBO_NOMEMP")    
If lBBO_ATERNA//BBO->( FieldPos("BBO_ATERNA") ) > 0
   aadd(aFields,"BBO_ATERNA")
   M->BBO_ATERNA	:= "0"
EndIf	
M->BBO_NOME 	:= Space(Len(BBO->BBO_NOME))
M->BBO_CODPAC  	:= Space(Len(BBO->BBO_CODPAC))
M->BBO_TELEFO	:= Space(Len(BBO->BBO_TELEFO))
M->BBO_MATANT	:= Space(Len(BBO->BBO_MATANT))
M->BBO_NOMEMP	:= Space(Len(BBO->BBO_NOMEMP))

DEFINE MSDIALOG oDlg TITLE STR0111 FROM 005,005 TO 25, 093 OF oDlgPes //"Identificacao do usuario"
	    
@ 030,004 GROUP oGrupo TO 140, 345 PIXEL OF oDlg LABEL STR0112  COLOR CLR_HBLUE, CLR_HRED        //" Pesquisa de usuario "

oUsr  := MsMGet():New("BBO" ,0 ,K_Incluir,,,,aFields,{040,010,135,340},aFields,,,,,oDlg,,,.T.,)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval({||EnChoiceBar(oDlg,bOk,{||nOpca:=2,oDlg:End()}, .F.,aButtons)} )

If nOpca == 1
	Reclock("BBO",.F.)
		If lBBO_ATERNA//BBO->( FieldPos("BBO_ATERNA") ) > 0
			BBO->BBO_ATERNA := M->BBO_ATERNA
		EndIf	
		BBO->BBO_CODPAC 	:= M->BBO_CODPAC
		BBO->BBO_NOME	    := M->BBO_NOME
		BBO->BBO_TELEFO		:= M->BBO_TELEFO
		BBO->BBO_MATANT		:= M->BBO_MATANT
		BBO->BBO_NOMEMP		:= M->BBO_NOMEMP
		If lForcaPro
			BBO->BBO_USRFRC := aAutFor[Len(aAutFor),9]
		Endif		
	BBO->( msUnlock() )
Endif

oSay1:Refresh()
oSay2:Refresh()
oSay3:Refresh()
oSay4:Refresh()
If lBBO_ATERNA//BBO->( FieldPos("BBO_ATERNA") ) > 0
   oSay5:Refresh()
EndIf

Return(Iif(nOpca==1,.T.,.F.))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA300ENCºAutor  ³Geraldo Felix Juniorº Data ³  14/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao do encaixe.                                      º±±
±±ºUso       ³ Agenda medica.                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA300ENC(cHora, aHorAge, oHorarios,nOpcao)
LOCAL nPos := Ascan(aHorAge, {|x| x[2] == cHora})

If nOpcao == K_Marcar
	If nPos # 0 .and. !Empty(aHorAge[nPos][03])
		Aviso(STR0113,STR0114,{STR0047}) //"Horario nao disponive!"###"Este horario ja esta marcado. Informe um horario disponivel."###"&Voltar"
		Return(.F.)
	Endif		
Else
	If nPos # 0
		Aviso(STR0113,STR0115,{STR0047}) //"Horario nao disponive!"###"Informe um horario disponivel."###"&Voltar"
		Return(.F.)
	Endif
Endif	

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS300CAR  ³ Autor ³ Geraldo Felix Junior³ Data ³ 15.05.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Valida carencia...                                         ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ 16.05.02 ³ xxxx ³ Tulio Cesar ³ Versao 7.10                           ³±±±
±±³ 18.08.03 ³ xxxx ³Geraldo Felix³ Versao 8.11                           ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLS300Car(dDatPro,cCdTbPd,cCodPro, cMatric)
                    
LOCAL dAux               
LOCAL nDiasFT   
LOCAL aCriticas := {}
LOCAL lOK       := .T.
LOCAL nDias          
LOCAL nDiasCar	:= 0
LOCAL cUnCar	:= ""
LOCAL dDatCar	:= cTod("")

DEFAULT cCodPro	:= GetNewPar("MV_PLSCDCO","0110101012") //Codigo padrao da consulta Agenda Medica

cMatric := StrTran(cMatric,".","")
cMatric := StrTran(cMatric,"-","")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa se existe carencia a ser verificada...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA1->( dbSetorder(02) )
BA1->( MsSeek(xFilial("BA1")+cMatric) )
dDatCar := BA1->BA1_DATCAR
	
BR8->(DbSetOrder(1))
If BR8->(MsSeek(xFilial("BR8")+cCodPro))
	
	nDiasCar := BR8->BR8_CARENC
	cUnCar   := BR8->BR8_UNCAR
	cDesPro	 := BR8->BR8_DESCRI
	
	If     cUnCar $ "2,3,4" // Dias,Meses,Anos
		nDias := PLSCarDias(nDiasCar,cUnCar) // Calcula em dias
		dAux     := dDatCar+nDias
		
		If dtos(dDatPro) < dtos(dAux)
			nDiasFT := dAux - dDatPro
			lOK     := .F.
			
			aadd(aCriticas,{""   ,STR0116                                   ,AllTrim(str(nDiasCar))+" "+X3COMBO("BR8_UNCAR",cUnCar),"","",cCodPro}) //"Carencia do procedimento"
			aadd(aCriticas,{""   ,STR0117+dtoc(dDatPro),AllTrim(Str((nDias-nDiasFT)))+STR0118,"","",cCodPro}) //"Carencia cumprida ate a data do procedimento "###" Dias"
			aadd(aCriticas,{""   ,STR0119                  ,AllTrim(Str(nDiasFT)),"","",cCodPro}) //"Quantidade restante de dias ate a utilizacao"
			aadd(aCriticas,{""   ,STR0120                ,dtoc(dAux)+" ("+PLSDIASEM(dAux)+")","","",cCodPro}) //"Data em que podera ser realizado o procedimento"
			
		Endif
		
	Endif
Endif

If nDiasCar == 0
   Return(.T.)
Endif                           
     
If Len(aCriticas) <> 0
	PLS300CRI("1",{cCodPro,cDesPro},aCriticas)
	Return(.F.)
Endif

Return(.T.)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS300CRI  ³ Autor ³ Geraldo Felix Junior³ Data ³ 15.05.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Critica                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS300CRI(cTipo,aDados,aHisCri)
LOCAL oDlg
LOCAL aCri      := {}
LOCAL nOpca     := 0
LOCAL bOK       := {|| nOpca := 1,oDlg:End() }
LOCAL bCancel   := {|| nOpca := 0,oDlg:End() }
LOCAL oCritica                                  
LOCAL cCodPad
LOCAL cCodPro
LOCAL cDesPro
LOCAL cSequen
LOCAL cTitulo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dados para o caso de critica de movimentacao...                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If     cTipo == "1"
       cCodPad := aDados[1]
       cDesPro := aDados[2]
   
       cTitulo := STR0121+AllTrim(cCodPro)+" - "+AllTrim(cDesPro) //"Criticas do usuario "
ElseIf cTipo == "2"
       cTitulo := STR0122 //"Criticas Usuario"
ElseIf cTipo == "3"
       cTitulo := STR0123 //"Criticas Rede de Atendimento"
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cTitulo FROM 005,005 TO 024, 090

oCritica := TcBrowse():New( 022, 005, 320, 110,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
                                            
oCritica:AddColumn(TcColumn():New(STR0124,{ || aHisCri[oCritica:nAt,1] },; //"Codigo"
         "@C",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))     
oCritica:AddColumn(TcColumn():New(STR0004,{ || OemToAnsi(aHisCri[oCritica:nAt,2]) },; //"Descricao"
         "@C",nil,nil,nil,170,.F.,.F.,nil,nil,nil,.F.,nil))     
oCritica:AddColumn(TcColumn():New(STR0125,{ || OemToAnsi(aHisCri[oCritica:nAt,3]) },; //"Info"
         "@C",nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))     

oCritica:SetArray(aHisCri)         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa dialogo....                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT Eval( { || EnChoiceBar(oDlg,bOK,bCancel,.F.) } )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS300MEDBRWºAutor  ³Geraldo Felix JuniorºData³    27/05/03 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Lista as especialidades do medico se esta nao for especificaº±±
±±º          ³da...                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLS300MEDBRW(oHorarios,oBrowse,bVetAge)

LOCAL cSql 		:= ""
LOCAL aEspe 	:= {}
LOCAL cCodMed	:= ""
LOCAL oDlgMed
LOCAL nOpc		:= 0
LOCAL nAt		:= 0
LOCAL nBrwAt	:= 0
LOCAL bOk       := {|| Iif( Len(aCombo) > 0 , Eval({|| nBrwAt := oBrwMed:nAt, nOpc:=1,cCombo:=aCombo[oBrwMed:nAt,1]+" - "+aCombo[oBrwMed:nAt,2],cComboEsp:=aCombo[oBrwMed:nAt,4] , oDlgMed:End() }) ,oDlgMed:End() ) } 
LOCAL bCa		:= {|| nOpc:=0,oDlgMed:End()}
LOCAL oBrwMed

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgMed TITLE STR0126 FROM 06,000 TO 022, 100 //"Medicos disponiveis"

oBrwMed := TcBrowse():New( 032, 001, 390, 080,,,, oDlgMed,,,,,,,,,,,, .F.,, .T.,, .F., )
                                            
oBrwMed:AddColumn(TcColumn():New(STR0124			,{ || aCombo[oBrwMed:nAt,1] },"@C",nil,nil,nil,026,.F.,.F.,nil,nil,nil,.F.,nil)) //"Codigo"
oBrwMed:AddColumn(TcColumn():New(STR0080			,{ || OemToAnsi(aCombo[oBrwMed:nAt,2]) },"@C",nil,nil,nil,160,.F.,.F.,nil,nil,nil,.F.,nil)) //"Medico"
oBrwMed:AddColumn(TcColumn():New(STR0127	,{ || OemToAnsi(aCombo[oBrwMed:nAt,3]) },"@C",nil,nil,nil,160,.F.,.F.,nil,nil,nil,.F.,nil)) //"Especialidade"
oBrwMed:AddColumn(TcColumn():New(STR0128		,{ || OemToAnsi(aCombo[oBrwMed:nAt,4]) },"@C",nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil)) //"Cod. Esp."
oBrwMed:SetArray(aCombo)         
oBrwMed:BLDBLCLICK := bOk                                                    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa dialogo....                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgMed ON INIT Eval( { || EnChoiceBar(oDlgMed,bOK,bCa,.F.,{}) } )
                          
If nOpc == 1
	oSayMed:Refresh()
	Eval(bVetAge)
	oHorarios:Setarray(aHorAge)
	oHorarios:Refresh()
	oHorarios:SetFocus()
	oSinal:LACTIVE			:= Iif(!Empty(aCombo[nBrwAt,5]),.T.,.F.)
	oBmpBol:LVISIBLECONTROL := Iif(!Empty(aCombo[nBrwAt,5]),.T.,.F.)	
Endif

Return()                                                                       	
    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA300MSGºAutor  ³Geraldo Felix Juniorº Data ³  09-14-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ mostra a mensagem do dia do medico selecionado             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLSA300MSG()
If ( nPos := Ascan(aCombo,{|x| x[1] == Left(cCombo,Len(BAU->BAU_CODIGO))}) ) <> 0
	If !Empty(aCombo[nPos,5])
		MsgInfo(aCombo[nPos,5])
	Endif
Endif                      

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA300   ºAutor  ³Microsiga           º Data ³  09-17-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pls300EnableKeys(oListLoc, oEnc, bFiltro, nDsPes, dData, aListaUsr, nOpcao,; 
				oDlgPes, bClick, oHorarios, bVetAge, oBrowse, cCodEsp, oListaUsr, nDsPer)

SetKey(VK_F4 ,{||((oListLoc:Refresh()),PLSA300Dat("2",oEnc,bFiltro,nDsPes,M->BBO_DATA))})// Agenda anterior
SetKey(VK_F5 ,{||((oListLoc:Refresh()),PLSA300Dat("1",oEnc,bFiltro,nDsPes,M->BBO_DATA))})// Promxima Agenda
SetKey(VK_F6 ,{||oEnc:AENTRYCTRLS[1]:SetFocus()})  		// Troca a data
SetKey(VK_F7 ,{||oEnc:AENTRYCTRLS[3]:SetFocus()})  		// Troca a especialidade
SetKey(VK_F8 ,{||oEnc:AENTRYCTRLS[5]:SetFocus()})  		// Troca o medico
SetKey(VK_F9 ,{||oEnc:AENTRYCTRLS[7]:SetFocus()})			// Troca o local de atendimento
SetKey(VK_F10,{||A300CLSUSR()})  							// Limpa usuario selecionado...

SetKey(VK_F11,{||Pls300DisableKeys(),;
				 PLSA300CALL(cCodEsp,dData,1,aListaUsr,oListaUsr,nOpcao,oDlgPes,nDsPer,oListLoc:aArray[oListLoc:nAt][1],aHorAge,oHorarios,.T.),;
                 Pls300EnableKeys(oListLoc, oEnc, bFiltro, nDsPes, dData, aListaUsr,nOpcao, oDlgPes, bClick,;
                 oHorarios, bVetAge, oBrowse,cCodEsp,oListaUsr,nDsPer)}) 			// Identificacao do paciente.     
                 
SetKey(VK_F12,{||lEncaixe := .T.,nOpcao:=K_Agenda,Eval(bClick),lEncaixe:=.F. }) 	// Encaixe
SetKey(1  ,{||oListLoc:SetFocus()})  							  					// Foca os locais de atendimento.

SetKey(2  ,{||If(lMarcar,(Pls300DisableKays(),;
						   PLS300MEDBRW(oHorarios,oBrowse,bVetAge),;
			               Pls300EnableKeys(oListLoc, oEnc, bFiltro, nDsPes,dData, aListaUsr,nOpcao, ;
							                 oDlgPes, bClick, oHorarios, bVetAge, oBrowse,cCodEsp,;
							                 oListaUsr,nDsPer)),;
							                 Aviso(STR0023,STR0046,{"&Voltar"})) }) // Invoca o browse de medicos //"Remarcar"###"Nao e possivel trocar de medico na remarcacao."
SetKey(3  ,{||oHorarios:SetFocus()})  // Foca a agenda do medico selecionado
SetKey(13 ,{||PLSA300MSG()})

Return
			  	    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA300   ºAutor  ³Microsiga           º Data ³  09-17-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pls300DisableKeys()

SET KEY VK_F4 TO
SET KEY VK_F5 TO
SET KEY VK_F6 TO
SET KEY VK_F7 TO
SET KEY VK_F8 TO
SET KEY VK_F9 TO
SET KEY VK_F10 TO
SET KEY VK_F11 TO
SET KEY VK_F12 TO                  
SET KEY 1  TO
SET KEY 2  TO
SET KEY 3  TO
SET KEY 13 TO

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA300CARºAutor  ³Geraldo Felix Juniorº Data ³  11-08-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Analiza carencia... agora com o forca                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA300CAR(cMatric,cAterna,cComboMed,cCodLoc,cCodEsp,lShowCri)
LOCAL aDadUsr 	  := PLSDADUSR(cMatric,"1",.T.,dDatabase)
LOCAL aDadRDA 	  := {} 
LOCAL cCodPro 	  := GetNewPar("MV_PLSCDCO","0110101012") //Codigo padrao da consulta Agenda Medica
LOCAL cCodPad 	  := Left(cCodPro,2)
LOCAL cDesPro
LOCAL cNivel 
LOCAL aHisCri	  := {}
LOCAL lRetorno    := .T.
LOCAL lRet
LOCAL lForcou	  := .T.
LOCAL oMemo
LOCAL cMemo 	  := ""
LOCAL oDlg
LOCAL nOpca		  := 2               
LOCAL cCodRDA     := ""
LOCAL nOrdBB8       := BB8->(IndexOrd())
LOCAL nRecBB8       := BB8->(Recno())   
LOCAL dDatPro		:= IIf(GetNewPar("MV_PLSPEAG","0") == "1" .And. FunName()$'PLSA300,PLSA315,TMKA271' .and. type('M->BBO_DATA')<> 'U',M->BBO_DATA,dDataBase)

DEFAULT cCodLoc    := ""
DEFAULT cAterna	  := "0"              
DEFAULT cComboMed := GetNewPar("MV_PLSRDAG","999999")//Rede de Atendimento Generica Utilizada na rotina de liberacao
DEFAULT lShowCri  := .T.

If Type("cCombo") == "C"
   cCodRDA := Left(cCombo,Len(BAU->BAU_CODIGO))   
Else          
   cCodRDA := Left(cComboMed,Len(BAU->BAU_CODIGO))   
EndIf
                   
//Procura o correto local de atendimento a partir do BB8
BB8->(DbSetOrder(3))
BB8->(DbSeek(xFilial("BB8")+cCodRda+PLSIntPad()+cCodLoc))
cCodLoc := BB8->BB8_CODLOC

BB8->(DbSetOrder(nOrdBB8))
BB8->(DbGoTo(nRecBB8))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefine as variaveis...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCodPro 	:= Substr(cCodPro,3,8)
lForcaUsr	:= .F.
lForcaPro	:= .F.         
aAutFor 	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe o procedimento...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BR8_NIVEL, BR8_DESCRI, R_E_C_N_O_ AS REGBR8 FROM "+RetSQLName("BR8")+" WHERE "
cSQL += "BR8_FILIAL = '"+xFilial("BR8")+"' AND "
cSQL += "BR8_CODPAD = '"+cCodPad+"' AND "
cSQL += "BR8_CODPSA = '"+cCodPro+"' AND "
cSQL += "D_E_L_E_T_ = '' AND BR8_ANASIN = '1'"

PLSQuery(cSQL,"PLSA090AUT")

If PLSA090AUT->(Eof())
   lRet := .F.
Else
   BR8->(DbGoTo(PLSA090AUT->REGBR8))
   cDesPro := PLSA090AUT->BR8_DESCRI
   cNivel  := PLSA090AUT->BR8_NIVEL
   lRet   := .T.
Endif   
PLSA090AUT->(DbCloseArea())

BCT->(dbSetOrder(1))

If lShowCri .Or. !aDadUsr[1]
	aRet := PLSA090USR(cMatric,dDatabase,Time(),,.F.,.T.,.F.)
	lCritica := aRet[1]
	aCritica := aRet[2]                                       
Else 
	lCritica := .F.
	aCritica := {}                                       
Endif     
     
If Len(aCritica) > 0  
	If BCT->(MsSeek(xFilial("BCT")+PlsIntPad()+aCritica[1][1]))
		lRet := PLSMOVCRI("2",{},aCritica,BCT->BCT_PERFOR == "1") 
		If !lRet 	
			Return({lRet,aCritica})
		EndIf
		lCritica := lRet
		lShowCri := .F.
	Else	
		PLSMOVCRI("2",{},aCritica) 
		lCritica := .F.	
	EndIf
Endif

If lCritica
   aDadUsr := PLSGETUsr()
Endif
     
If !aDadUsr[1]
	Return({lCritica, aCritica})
Endif
                                   
If Type("cCombo") == "C"
   cCodRDA := Left(cCombo,Len(BAU->BAU_CODIGO))   
Else          
   cCodRDA := Left(cComboMed,Len(BAU->BAU_CODIGO))   
EndIf
	
aDadRDA := PLSDADRDA(BA1->BA1_CODINT,cCodRda,'1' ,dDatabase,cCodLoc,cCodEsp)

If !aDadRDA[1]  
	If BCT->(MsSeek(xFilial("BCT")+PlsIntPad()+aDadRDA[2][1][1]))
		lRet := PLSMOVCRI("2",{},aDadRDA[2],BCT->BCT_PERFOR == "1") 
		lCritica := lRet
		lShowCri := .F.
	Else	
		PLSMOVCRI("2",{},aDadRDA[2]) 
		lCritica := .F.	
	EndIf
Endif

If !aDadRDA[1]
	Return({aDadRDA[1], {}})
Endif
                                          
aRet := PLSAUTP(dDatPro,Time(),cCodPad,cCodPro,1,aDadUsr,0,aDadRDA,"1",.T.,'',,NIL,,,,,,,,,,,,,,,cAterna,,,,,,,,,,,;
        ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.F.)

lRet := aRet[1]

If !aRet[1]   	                                                      
	If BCT->(MsSeek(xFilial("BCT")+PlsIntPad()+aRet[2][1][1]))
		lRet := PLSMOVCRI("2",{},aRet[2],BCT->BCT_PERFOR == "1") 
		lCritica := lRet
		lShowCri := .F.
	Else	
		PLSMOVCRI("2",{},aRet[2]) 
		lCritica := .F.	
	EndIf
Endif

If !lRet .and. Len(aDadUsr) > 0 .and. Len(aDadRDA) > 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso nao seja autorizada analiso o campo que trata se e permitido forcar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta aHisCri...                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aHisCri := aClone(aRet[2])
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Parametro que permite ou nao a visualizacao das criticas...              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		If lShowCri
			aRet[1] := PLSMOVCRI("1",{cCodPad,cCodPro,cDesPro,"001"},aHisCri,BR8->BR8_PERFOR == "1")
			
			lRet := Iif( ValType(aRet[1]) == 'L', aRet[1], .F.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Forcou, abrir tela de digitacao de observacoes...                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If lRet
				nPos := Ascan(aAutFor,{|x| x[2]+x[3] == cCodPad+cCodPro})
				If nPos == 0
					aadd(aAutFor,{.T.,cCodPad,cCodPro,"","","","",0,BCS->(RetCodUsr()),Date(),Time()})
				Endif    			
				lForcaPro := .T.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Forcou, abrir tela de digitacao de observacoes...                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DEFINE MSDIALOG oDlg TITLE STR0129 FROM 005,005 TO 19, 045  //"Observacoes"
	    
					@ 016,003 GROUP oGrupo TO 104, 157 PIXEL OF oDlg LABEL STR0130  COLOR CLR_HBLUE, CLR_HRED        //" Observacoes "
					@ 024,006 GET oMemo  VAR cMemo MEMO SIZE 145,075 OF oDlg PIXEL

				ACTIVATE MSDIALOG oDlg ON INIT Eval({||EnChoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca:=2,oDlg:End()}, .F.)} )
				If nOpca == 1
					Aadd(aAutFor[Len(aAutFor)], cMemo)
				Else	
					Aadd(aAutFor[Len(aAutFor)], '')
				Endif			
			Else
				lForcaPro := .F.
			Endif
		Endif
	Endif
Endif

lRetorno :=  lRet
Return({lRetorno, aHisCri})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL300VISCARºAutor  ³Geraldo Felix Juniorº Data ³  13/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamada da tela de identificacao do usuario ao telefone.    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL300VISCAR(cCodEsp,dData,aListaUsr,oListaUsr, nOpcao, oDlgPes, nDsPer, cCodPac,lBBO_ATERNA)

LOCAL oUsr
LOCAL oDlgCar
LOCAL oGrupo

LOCAL nOpca 	  	:= 2
LOCAL bOk			:= {|| oDlgCar:End() }
LOCAL bCancel 		:= {|| oDlgCar:End() }
LOCAL bCarencia		:= {|| PLSVSCLACAR( Substr(Iif(!Empty(cCodPac),cCodPac,M->BBO_CODPAC),1,(Len(BBO->BBO_CODPAC)-1)) )}
LOCAL aButtons		:= {{"RELATORIO"    	, bCarencia ,STR0131,STR0132}} //"Carencias - <ALT + C>"###"Carencias"
LOCAL aFields		:= {}

PRIVATE aTela     	:= {}
PRIVATE aGets     	:= {}
PRIVATE lRefresh  	:= .F.
DEFAULT lBBO_ATERNA := BBO->( FieldPos("BBO_ATERNA") ) > 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso tenha um usuario selecionado...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cCodPac)
	Eval(bCarencia)
	Return()
ElseIf Type('M->BBO_CODPAC') == 'U' .and. funname() <> 'PLSA315'
	Return()
Endif	  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega variaveis de memoria											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BBO->(RegToMemory("BBO",.F.))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Manta array																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aFields, "BBO_NOME"  )
Aadd(aFields, "BBO_CODPAC")
Aadd(aFields, "BBO_MATANT")    
Aadd(aFields, "BBO_NOMEMP")    
If lBBO_ATERNA//BBO->( FieldPos("BBO_ATERNA") ) > 0
   aadd(aFields,"BBO_ATERNA")
   M->BBO_ATERNA	:= "0"
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta variavel memoria												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M->BBO_NOME 	:= Space(Len(BBO->BBO_NOME))  
M->BBO_CODPAC  	:= Space(Len(BBO->BBO_CODPAC))
M->BBO_MATANT	:= Space(Len(BBO->BBO_MATANT))
M->BBO_NOMEMP	:= Space(Len(BBO->BBO_NOMEMP))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ dlg																	 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgCar TITLE STR0132 FROM 005,005 TO 19, 068 OF oDlgPes //"Carencias"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ativa tecla de atalho...												 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 001,001 BUTTON STR0133 SIZE 000,00 ACTION Eval(bCarencia) PIXEL OF oDlgCar  //"&Carencias"

@ 016,003 GROUP oGrupo TO 102, 248 PIXEL OF oDlgCar LABEL STR0134  COLOR CLR_HBLUE, CLR_HRED        //" Informe o usuario "

oUsr  := MsMGet():New("BBO" ,0 ,K_Incluir,,,,aFields,{024,006,098,245},aFields,,,,,oDlgCar,,,.T.,)

ACTIVATE MSDIALOG oDlgCar ON INIT Eval({||EnChoiceBar(oDlgCar,bOk,bCancel, .F., aButtons)} ) CENTER
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A300INTGERºAutor  ³Geraldo Felix Juniorº Data ³  13/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclusao de usuarios de intercambio eventual...            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A300INTGER(lChkCon)
LOCAL aRetIntEve	:= PLSA235(.F.,"",.T.,NIL,NIL,NIL,NIL,NIL,NIL,lChkCon)
LOCAL aRet 			:= {}
LOCAL lRet 			:= .F.
LOCAL cMatric		:= ''
LOCAL _cCodEsp  	:= ''
LOCAL cNReduz                                  

If Type('M->BBO_CODESP') == "C"
   _cCodEsp := M->BBO_CODESP
Else 
   _cCodEsp := cCodEsp
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para usuarios que vem de uma marcacao de consulta						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aRetIntEve[1]
	cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
	
	aRet := PLSA090USR(cMatric,dDatabase,Time(),,.F.,.T.,.F.)
	lRet := PLSA300TPe(cMatric,dDatabase,_cCodEsp,GetNewPar("MV_PLDSCAG",30),oEnc:oBox)//Dias para agendamento de consultas mesma especial.
	
	If lRet
		cNReduz := Posicione("BA1",2,xFilial("BA1")+cMatric,"BA1_NREDUZ")
		If Empty(cNReduz)
		   BA3->( DbSetOrder(01) )
	   	   BA3->( MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)) )
		   cNReduz := Posicione("BG9",1,xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_TIPOUS),"BG9_NREDUZ")
		EndIf

		M->BBD_CODPAC := cMatric
		M->BBD_NOME   := BA1->BA1_NOMUSR
		M->BBD_TELEFO := BA1->BA1_TELEFO
		M->BBD_MATANT := BA1->BA1_MATANT

		M->BBO_CODPAC 	:= cMatric
		M->BBO_NOME 	:= BA1->BA1_NOMUSR
		M->BBO_NOMEMP 	:= cNReduz
		M->BBO_TELEFO 	:= BA1->BA1_TELEFO
		M->BBO_MATANT 	:= BA1->BA1_MATANT
	Endif
	
	lRefresh := .T.
Else
   If Len(aRetIntEve) >= 2 .And. Len(aRetIntEve[2]) > 0
   		PLSMOVCRI("2",{},aRetIntEve[2])      
   Endif   
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSHISTCONºAutor  ³Alexander 			 º Data ³  31/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Historico de Consultas									  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSHISTCON()
LOCAL cSql  := ""
LOCAL aRet  := {}
LOCAL nCont := 0
LOCAL cNome
If !Empty(M->BBO_CODPAC)
	cSQL := " SELECT BBD_CODPAC,BBD_NOME,BBD_DATA,BBD_HORA,BBD_CODINT,BBD_CODESP,BBD_CODIGO,BBD_CODLOC,BBD_LOCAL,BBD_NSALA,BBD_HORCHE,BBD_HORENT,BBD_HORSAI "
	cSQL += "  FROM "+BBD->(RetSQLName("BBD"))
	cSQL += " WHERE BBD_FILIAL = '"+xFilial("BBD")				+"' "
	cSQL += "   AND BBD_CODINT = '"+SubStr(M->BBO_CODPAC,1,4)	+"' " 
	cSQL += "   AND BBD_CODPAC = '"+M->BBO_CODPAC				+"' "
	cSQL += "   AND BBD_STATUS = '4' "
	cSQL += "   AND D_E_L_E_T_ = ' ' "
	cSQL += " ORDER BY BBD_DATA DESC "
	PLSQuery(cSQL,"TrbHis")
	TrbHis->( DbGoTop() )                   
	cNome := Transform(TrbHis->BBD_CODPAC,"@R !!!!.!!!!.!!!!!!.!!-!")+' - '+TrbHis->BBD_NOME
	While ! TrbHis->(Eof()) .And. nCont <= 6
      nCont++                                               
	  AaDd(aRet,{	TrbHis->BBD_DATA,; //Data do Atendimento
	  				TrbHis->BBD_HORA,; //Hora do Atendimento
	  				Posicione("BAQ",1,xFilial("BAQ")+TrbHis->(BBD_CODINT+BBD_CODESP), "BAQ_DESCRI" ),; //Especialidade
	  				Posicione("BAU",1,xFilial("BAU")+TrbHis->(BBD_CODIGO), "BAU_NOME" ),; //Medico
	  				Posicione("BB8",1,xFilial("BB8")+TrbHis->(BBD_CODIGO+BBD_CODINT+BBD_CODLOC+BBD_LOCAL), "BB8_DESLOC" ),;//Local
					TrbHis->BBD_NSALA,; 	//Sala
					TrbHis->BBD_HORCHE,;	//Hora de Chegada
					TrbHis->BBD_HORENT,;	//Hora de Entrada
					TrbHis->BBD_HORSAI})	//Hora de Saida
	  TrbHis->( DbSkip() )
	EndDo                 
    If Len(aRet) > 0
       PLSCRIGEN(aRet,{	{STR0077			,"@C",050 }	,; //"Data"
       					{STR0010			,"@C",050 }	,; //"Hora"
       					{STR0127,"@C",100 } ,; //"Especialidade"
       					{STR0080		,"@C",100 } ,; //"Medico"
       					{STR0003		,"@C",100 } ,; //"Local"
       					{STR0135			,"@C",50 } ,; //"Sala"
       					{STR0136	,"@C",50 } ,; //"Hora Chegada"
       					{STR0137	,"@C",50 } ,; //"Hora Entrada"
       					{STR0138	,"@C",50 }},; //"Hora Saida"
       					STR0139+cNome) //"Historico de Consulta do paciente -> "
    EndIf	                          
TrbHis->(DbCloseArea())    
EndIf	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSMedEsp ºAutor  ³Alexander 			 º Data ³  17/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Checa Especiadlidade x Medico							  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSMedEsp(nTipo,cCampo1,cCampo2)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nInd                            
LOCAL nLin
LOCAL cSQL
LOCAL cTitulo   
LOCAL oDlg
LOCAL oBrw

LOCAL nOpca     := 0      
LOCAL cRet 		:= ""
LOCAL aBrw  	:= {}
LOCAL bOK       := { || nOpca := K_OK , nLin := oBrw:nAt , oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ coloca virgula no comeco (caso tenha inicializador padrao)               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 1
	If !Empty(cCampo1)
		cSQL := " SELECT BAQ_CODESP,BAQ_DESCRI,"+RetSQLName("BAQ")+".R_E_C_N_O_"
		cSQL += "   FROM "+RetSQLName("BAX")+", "+RetSQLName("BAQ")
		cSQL += "  WHERE BAX_FILIAL	= '"+xFilial("BAX")+"' " 
		cSQL += "    AND BAX_CODINT = '"+PlsIntPad()+"' "
		cSQL += "    AND BAX_CODIGO = '"+cCampo1+"' "
		cSQL += "    AND "+RetSQLName("BAX")+".D_E_L_E_T_ = ' ' "
		cSQL += "    AND BAQ_FILIAL	= '"+xFilial("BAQ")+"' "         
		cSQL += "    AND BAQ_CODESP = BAX_CODESP  "
		cSQL += "    AND "+RetSQLName("BAQ")+".D_E_L_E_T_ = ' ' "
		cSQL += " ORDER BY BAQ_DESCRI "
	Else
		cSQL := " SELECT BAQ_CODESP,BAQ_DESCRI,"+RetSQLName("BAQ")+".R_E_C_N_O_"
		cSQL += "   FROM "+RetSQLName("BAQ")
		cSQL += "  WHERE BAQ_FILIAL	= '"+xFilial("BAQ")+"' "         
		cSQL += "    AND "+RetSQLName("BAQ")+".D_E_L_E_T_ = ' ' "
		cSQL += " ORDER BY BAQ_DESCRI "
    EndIf
Else 
	If !Empty(cCampo1+cCampo2)
		cSQL := " SELECT DISTINCT BAU_CODIGO,BAU_NOME,BAU_ESTCR,BAU_CONREG,BAU_SIGLCR,"+RetSQLName("BAU")+".R_E_C_N_O_"
		cSQL += "   FROM "+RetSQLName("BAX")+", "+RetSQLName("BAU")
		cSQL += "  WHERE BAX_FILIAL	= '"+xFilial("BAX")+"' " 
		cSQL += "    AND BAX_CODINT = '"+plsIntPad()+"' "
		cSQL += "    AND BAX_CODESP = '"+cCampo2+"' "
		cSQL += "    AND "+RetSQLName("BAX")+".D_E_L_E_T_ = ' ' "
		cSQL += "    AND BAU_FILIAL	= '"+xFilial("BAU")+"' "         
		cSQL += "    AND BAU_CODIGO = BAX_CODIGO  "
		cSQL += "    AND "+RetSQLName("BAU")+".D_E_L_E_T_ = ' ' "
		cSQL += " ORDER BY BAU_NOME "
	Else
		cSQL := " SELECT BAU_CODIGO,BAU_NOME,BAU_ESTCR,BAU_CONREG,BAU_SIGLCR,R_E_C_N_O_"
		cSQL += "   FROM "+RetSQLName("BAU")
		cSQL += "  WHERE BAU_FILIAL	= '"+xFilial("BAU")+"' "         
		cSQL += "    AND BAU_TIPPE  = 'F' "
		cSQL += "    AND "+RetSQLName("BAU")+".D_E_L_E_T_ = ' ' "
		cSQL += " ORDER BY BAU_NOME "
    EndIf
EndIf	
PLSQuery(cSQL,"TrbBAG")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While ! TrbBAG->( Eof() ) 
	If nTipo == 1
	   cTitulo := STR0140 //"Especialidades"
	   aadd(aBrw,{ TrbBAG->BAQ_CODESP,TrbBAG->BAQ_DESCRI,"",TrbBAG->R_E_C_N_O_ } )
	Else 
	   cTitulo := STR0141 //"Rede de Atendimento"
	   aadd(aBrw,{ TrbBAG->BAU_CODIGO,TrbBAG->BAU_NOME,TrbBAG->BAU_ESTCR+"-"+TrbBAG->BAU_CONREG+"-"+TrbBAG->BAU_SIGLCR,TrbBAG->R_E_C_N_O_ } )
	EndIf    
TRBBAG->( DbSkip() )
Enddo                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha area de trabalho													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TrbBAG->( DbCloseArea() )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define tela																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cTitulo FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()

oBrw := TcBrowse():New( 018, 05, 343, 172,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrw:AddColumn(TcColumn():New(STR0124,					{ || OemToAnsi(aBrw[oBrw:nAt,1]) },"@!",nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))      //"Codigo"
oBrw:AddColumn(TcColumn():New(STR0004,				{ || OemToAnsi(aBrw[oBrw:nAt,2]) },"@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))      //"Descricao"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipo Prestador															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 2
   oBrw:AddColumn(TcColumn():New(STR0142, { || OemToAnsi(aBrw[oBrw:nAt,3]) },"@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))      //"UF+Registro+Conselho"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Set Array																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrw:SetArray(aBrw)         
oBrw:bLDblClick := bOk

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK
	If nTipo == 1
	   If !Empty( aBrw[nLin,4] )
	      BAQ->( DbGoTo( aBrw[nLin,4] ) )
	   Endif
	Else 
	   If !Empty( aBrw[nLin,4] )
	      BAU->( DbGoTo( aBrw[nLin,4] ) )
	   Endif
   EndIf    
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nOpca==K_OK)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A300CLSUSRºAutor  ³Geraldo Felix Juniorº Data ³  09/18/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Limpa o usuario selecionado para que um novo possa ser      º±±
±±º          ³selecionado.                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A300CLSUSR()

	If !BBO->( Eof() )
		BBO->( RecLock("BBO", .F.) )
		BBO->BBO_NREDUZ 	:= ''
		BBO->BBO_NOME		:= ''
		BBO->BBO_CODPAC		:= ''
		BBO->BBO_NOMEMP		:= ''
		If lBBO_ATERNA//BBO->( FieldPos("BBO_ATERNA") ) > 0
			BBO->BBO_ATERNA		:= ''
		Endif
		BBO->BBO_TELEFO		:= ''
		BBO->BBO_MATANT		:= ''
		
		BBO->( MsUnlock() )
		
		oSay1:Refresh()
		oSay2:Refresh()
		oSay3:Refresh()
		oSay4:Refresh()
		
		If lBBO_ATERNA//BBO->( FieldPos("BBO_ATERNA") ) > 0
			oSay5:Refresh()
		EndIf
	Endif

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³04/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Private aRotina := {	{ STRPL01 	, '' , 0 , K_Pesquisar  , 0, .F.},; //'Pesquisar'
						{ STRPL02 	, '' , 0 , K_Visualizar , 0, Nil},; //'Visualizar'
						{ STRPL03 	, '' , 0 , K_Incluir    , 0, Nil},; //'Incluir'
						{ STRPL04		, '' , 0 , K_Alterar    , 0, Nil}}  //'Alterar'
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A300VldAgeºAutor  ³Darcio R. Sporl     º Data ³  29/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada para validar, se o usuario ja possui agenda   º±±
±±º          ³no mesmo dia e horario ja agendado.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPLS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A300VldAge(dData)
Local cQry := ""
Local lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Esta query faz a validacao da agenda, onde eh verificado ³
//³se o paciente ja possui agenda para o mesmo dia e horario³
//³digitados.                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQry := "SELECT COUNT(*) REG "
cQry += "FROM " + RetSqlName("BBD") + " "
cQry += "WHERE BBD_FILIAL = '" + xFilial("BBD") + "' "
cQry += "  AND BBD_CODPAC = '" + M->BBD_CODPAC + "' "
cQry += "  AND BBD_DATA   = '" + DtoS(dData) + "' "
cQry += "  AND BBD_HORA   = '" + aHorAge[oHorarios:nAt,2] + "' "
cQry += "  AND BBD_DATCAN = '" + Space(TamSX3("BBD_DATCAN")[1]) + "' "
cQry += "  AND BBD_HORCAN = '" + Space(TamSX3("BBD_HORCAN")[1]) + "' "
cQry += "  AND D_E_L_E_T_ <> '*' "
		
cQry := ChangeQuery(cQry)
DbUseArea(.T., "TOPCONN", TcGenQry(,, cQry), "TMPBBD", .F., .F.)
		
If TMPBBD->REG > 0
	Aviso(STR0143,STR0144,{STR0145},1)	//"Atenção"###"Paciente já possui agendamento para este dia e horário."###"Ok"
	lRet := .F.
EndIf
TMPBBD->(DbCloseArea())

Return(lRet)
