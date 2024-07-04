#INCLUDE "PLSA094.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA094A ³ Autor ³ Tulio Cesar           ³ Data ³ 24.11.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Chama o programa de Autorizacao de SADT/Consulta           ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA094A()

// TISS 2.2 - Requisitos minimos é a existencia da tabela BRI e a existencia da função PLSRETLDP
If ! ( PLSALIASEX("BRI") .And. FindFunction("PLSRETLDP") ) 
   Final("Necessário atualizar pacote da TISS 2.2 para se utilizar esta funcionalidade.")
Endif

PLSA090("1")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA094B ³ Autor ³ Tulio Cesar           ³ Data ³ 24.11.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Chama o programa de Liberacao                              ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA094B()

//TISS 2.2 - Requisitos minimos é a existencia da tabela BRI e a existencia da função PLSRETLDP
If ! ( PLSALIASEX("BRI") .And. FindFunction("PLSRETLDP") ) 
   Final("Necessário atualizar pacote da TISS 2.2 para se utilizar esta funcionalidade.")
Endif

PLSA090("2")


Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA094C ³ Autor ³ Tulio Cesar           ³ Data ³ 24.11.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Chama o programa odontologico                              ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA094C()
//TISS 2.2 - Requisitos minimos é a existencia da tabela BRI e a existencia da função PLSRETLDP
If ! ( PLSALIASEX("BRI") .And. FindFunction("PLSRETLDP") ) 
   Final("Necessário atualizar pacote da TISS 2.2 para se utilizar esta funcionalidade.")
Endif

PLS090O("1")

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA094D ³ Autor ³ Tulio Cesar           ³ Data ³ 24.11.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Chama o programa Liberacao odontologico                    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA094D()

//TISS 2.2 - Requisitos minimos é a existencia da tabela BRI e a existencia da função PLSRETLDP
If ! ( PLSALIASEX("BRI") .And. FindFunction("PLSRETLDP") ) 
   Final("Necessário atualizar pacote da TISS 2.2 para se utilizar esta funcionalidade.")
Endif


PLS090O("2")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLVLQTDEX

Valida se a quantidade executada é maior que o saldo na inclusão
do procedimento na guia de SADT no remote.

@author Thiago Guilherme
@since 08/11/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLVLQTDEX() 

LOCAL lRet := .T.

If !EMPTY(M->BE1_NUMLIB)

	BE2->(dbSetOrder(6))
	
	If BE2->(MsSeek(xFilial("BE2") + M->BE1_NUMLIB + M->BE2_CODPAD + M->BE2_CODPRO))
		If M->BE2_QTDPRO > BE2->BE2_SALDO
		
			MsgInfo(STR0002 + ALLTRIM(STR(BE2->BE2_SALDO)), STR0003) //"Quantidade disponível para execução: "##"Atenção"
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSGUIPRI
Verifica se a guia principal inserida é do beneficiário ou não.

@author  Victor Alves dos Santos
@since   16/03/2021
@version Protheus 12
/*/
//------------------------------------------------------------------- 

Function PLSGUIPRI(lAutoma)
Local cSql 		:= ""
Local nQtdReg   := 0
Local lRet		:= .f.
Local cMatric	:= M->BE1_USUARI
Local cGuiPri	:= M->BE1_GUIPRI
Default lAutoma := .f.

	If Empty(cGuiPri)
		lRet := .T.
		return lRet
	EndIf

//Query que verifica se há alguma guia vinculada ao beneficiário
    cSql := " SELECT COUNT(*) CONT FROM " + RetSQLName("BEA") + " BEA "
    cSql += " LEFT JOIN " + RetSqlName("BE4") + " BE4"
    cSql += " ON BE4_FILIAL = '"  + xFilial("BE4")+ "' "
    cSql += " AND BEA_OPEMOV = BE4_CODOPE"
	cSql += " AND BEA_ANOAUT = BE4_ANOINT"
	cSql += " AND BEA_MESAUT = BE4_MESINT"
	cSql += " AND BEA_NUMAUT = BE4_NUMINT"
	cSql += " AND BE4.D_E_L_E_T_ = ' ' "
	cSql += " WHERE BEA_FILIAL = '" + xFilial("BEA")+ "' "
	cSql += " AND (BEA_OPEUSR||BEA_CODEMP||BEA_MATRIC||BEA_TIPREG||BEA_DIGITO) = '"+ cMatric + "' "
	cSql += " AND (BEA_OPEMOV||BEA_ANOAUT||BEA_MESAUT||BEA_NUMAUT) = '"+ cGuiPri +"' "
	cSql += " AND BEA_DATPRO <> ' ' "
	cSql += " AND BEA_CANCEL <> '1' "
	cSql += " AND BEA_STATUS <> '3' "
	
	BE4->(DbSetOrder(2))
	If BE4->(MsSeek(xFilial("BE4")+cGuiPri))
		cSql += " AND BE4_DATPRO <> ' ' "
		cSql += " AND BE4_DTALTA = ' ' "
	EndIf

	cSql += " AND BEA.D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)

    nQtdReg := MPSysExecScalar(cSql, "CONT")

    If nQtdReg > 0
        lRet := .T.
    Else
        lRet := .F.
		If !lAutoma
        	Alert("Guia não pertence ao beneficiário ou não está ativa. Favor informar uma guia válida !")
		EndIf
    EndIf

Return lRet
