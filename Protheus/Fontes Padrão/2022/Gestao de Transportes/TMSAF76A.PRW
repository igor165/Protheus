#include "protheus.ch"
#include "TMSAF76A.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAF76FIL ³ Autor ³ Valdemar Roberto    ³ Data ³ 05/11/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtra agendamentos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF76A                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSF76AFIL(aAliasFil,lRefazObj,lLimpa,lMontaFil,lPriVez,AAliasNom)
Local lExecQry := .T.
Local nLinAtu  := 1
Local nCntFor1 := 0

DEFAULT aAliasFil	:= {}
DEFAULT lRefazObj	:= .F.
DEFAULT lLimpa   	:= .T.
DEFAULT lMontaFil	:= .T.
DEFAULT lPriVez  	:= .F.
DEFAULT aAliasNom	:= ''
CursorWait()

// Desliga teclas de atalho do painel
aEval(aSetKeyF76,{|x| SetKey( x[1] , {|| } ) } )

// Mapa do vetor aVetExp
// 01 - Alias
// 02 - Filtro do alias para usuario
// 03 - Filtro do alias para ADVPL ou banco de dados
// 04 - Alias virtual

aVetExp := TMSF76AMon(aAliasFil,.T.,Aclone(aVetExp),lMontaFil,Aclone(aAliasNom),@lExecQry)

//-- Recupera teclas de atalho do painel
aEval(aSetKeyF76,{|x| SetKey( x[1] , x[2] ) } )

If lExecQry
	//-- Retira as marcas do filtro anterior
	If lLimpa
		TMSF76Lim(cNumThread)
	EndIf
	aFilBkp := Aclone(aVetExp)
	aBrowseDF1 := TMSF76Qry(1,"''","''",lPriVez,.F.)
EndIf

If lRefazObj
	Tmsaf76Rfs(oMarkAge,aBrowseDF1[1],aBrowseDF1[3])
	
	TMSF76Age(.T.,.F.,.F.,,)
EndIf

CursorArrow()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76AMon ³ Autor ³ Valdemar Roberto     ³ Data ³ 07/01/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta filtro de varias tabelas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76AMon                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 - Vetor com os alias                                ³±±
±±³          ³ lExp01 - Indica se o retorno sera em instrucao de banco    ³±±
±±³          ³ aExp02 - Vetor com o filtro anterior                       ³±±
±±³          ³ lExp02 - Indica se exibe a tela                            ³±±
±±³          ³ aExp03 - Vetor com os nomes dos alias                      ³±±
±±³          ³ lExp03 - Variavel para retorno que indica se foi acionado  ³±±
±±³          ³          o botao cancelar da tela                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TMSF76AMon(aAlias,lExpTOP,aVetEnt,lExbScr,aAliasNom,lExecQry)
Local aRet      := {}
Local aAreas    := {SX2->(GetArea()),GetArea()}
Local aButtons  := {}
Local nOpca     := 0
Local nCntFor1  := 0
Local nLinEnt   := 0
Local nLinDes   := 0
Local cExpUsu   := ""
Local cExpFil   := ""
Local cDescri   := ""
Local bOldF3    := SetKey(VK_F3)
Local oDlgFil
Local oLbxTab

Private cCadastro  := STR0001//"Filtros"
Private aColsTab   := {}

DEFAULT aAlias    := {}
DEFAULT lExpTOP   := .T.
DEFAULT aVetEnt   := {}
DEFAULT lExbScr   := .T.
DEFAULT aAliasNom := {}
DEFAULT lExecQry  := .T.

If !Empty(aAlias)

	//-- Monta aCols
	For nCntFor1 := 1 To Len(aAlias)
		If (nLinEnt := Ascan(aVetEnt,{|x| x[4] == aAlias[nCntFor1,2]})) > 0
			cExpUsu := aVetEnt[nLinEnt,2]
			cExpFil := aVetEnt[nLinEnt,3]
		Else
			cExpUsu := ""
			cExpFil := ""
		EndIf

			If (nLinDes := Ascan(aAliasNom,{|x| x[1] == nCntFor1})) > 0
				cDescri := aAliasNom[nLinDes,2]
			Else
				cDescri := FwX2Nome(aAlias[nCntFor1,1]) //-- Descricao da Tabela pelo seu Alias
			EndIf
			Aadd(aColsTab,{aAlias[nCntFor1,1],;         //-- ID / Alias da Tabela
						   cDescri,;
						   cExpUsu,;
						   cExpFil,;
						   aAlias[nCntFor1,2]})

	Next nCntFor1

	If lExbScr
		AAdd(aButtons,{'RPMNEW',{|| TmsF76ALmp(),oLbxTab:Refresh()},STR0002,STR0003}) //"F3-Limpa Filtros"###"F3-Limpa Filtros"
		SetKey(VK_F3 ,{|| TmsF76ALmp(),oLbxTab:Refresh()})

		DEFINE MSDIALOG oDlgFil FROM 0,0 TO 400,1200 TITLE cCadastro PIXEL of oMainWnd
	
			@ 035,001 LISTBOX oLbxTab FIELDS HEADER STR0004,STR0005,STR0006 SIZE 600,185 OF oDlgFil PIXEL ON DblClick(TMSF76AExb(oLbxTab:nAt,lExpTOP),oLbxTab:Refresh()) //"Tabela"###"Descrição"###"Expressão"
			
			oLbxTab:SetArray(aColsTab)
			oLbxTab:bLine := {|| {aColsTab[oLbxTab:nAt,1],;
								  aColsTab[oLbxTab:nAt,2],;
								  aColsTab[oLbxTab:nAt,3]}}
	
		ACTIVATE MSDIALOG oDlgFil CENTERED ON INIT EnchoiceBar(oDlgFil,{|| (nOpca:= 1, oDlgFil:End()) }, {|| oDlgFil:End() },, aButtons )
	Else
		nOpca := 1
	EndIf
		
EndIf

If nOpca == 1
	For nCntFor1 := 1 To Len(aColsTab)
		If !lExbScr
			aColsTab[nCntFor1,3] := MontDescr(aColsTab[nCntFor1,1],aColsTab[nCntFor1,4],lExpTop)
		EndIf

		Aadd(aRet,{aColsTab[nCntFor1,1],;
				   aColsTab[nCntFor1,3],;
				   aColsTab[nCntFor1,4],;
				   aColsTab[nCntFor1,5]})
	Next nCntFor1
Else
	aRet := Aclone(aVetEnt)
	lExecQry := .F.
EndIf

SetKey(VK_F3,bOldF3)

AEval(aAreas,{|x,y| RestArea(x) })

Return Aclone(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76AExb ³ Autor ³ Valdemar Roberto     ³ Data ³ 07/01/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe filtro de cada tabela                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76AExb                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Linha do filtro                                   ³±±
±±³          ³ lExp01 - Indica se o retorno sera em instrucao de banco    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TMSF76AExb(nLinAtu,lExpTOP)
Local cAlias  := ""

DEFAULT nLinAtu := 0
DEFAULT lExpTOP := .T.

If !Empty(nLinAtu)
	cAlias := aColsTab[nLinAtu,1]
	aColsTab[nLinAtu,4] := BuildExpr(cAlias,,aColsTab[nLinAtu,4],lExpTOP,,)
	aColsTab[nLinAtu,3] := MontDescr(cAlias,aColsTab[nLinAtu,4],lExpTop)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsF76ALmp ³ Autor ³ Valdemar Roberto 	 Data ³ 08/01/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Limpa filtros das tabelas                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsF76ALmp                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TmsF76ALmp()
Local nCntFor1 := 0

For nCntFor1 := 1 To Len(aColsTab)
	aColsTab[nCntFor1,3] := ""
	aColsTab[nCntFor1,4] := ""
Next nCntFor1

Return
