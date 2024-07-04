#include "PROTHEUS.CH"
#include "REPORT.CH"
#include "FINR871.CH"

Static cTitulo		:= STR0001 //"Aglutinação de Títulos - INSS"
Static cPerg		:= "FINR870A"
Static cAliasQry	:= GetNextAlias()

/*{Protheus.doc}FINR871
Relatório dos processos de Aglutinação - INSS.
@author Kaique Schiller
@since 22/06/2015
@version P12
*/
Function FINR871()

Local oReport

If TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()  // Imprime o Relatório
Else
	Help(" ",1,"FIN870INC",,STR0002,1,0) //"Este relatório só está disponível a partir da Release 4."
EndIf

Return

/*{Protheus.doc}ReportDef
@author Kaique Schiller
@since 22/06/2015
@version P12
*/
Static Function ReportDef()

Local oReport  	:= Nil
Local oFWM 	   	:= Nil
Local oFK7		:= Nil
Local cDesc		:= ""

cDesc += STR0012	//"Este programa tem como objetivo imprimir a  "
cDesc += STR0013	//"Aglutinação de Títulos - INSS"

DEFINE REPORT oReport NAME "FINA870" TITLE cTitulo PARAMETER cPerg ACTION {|oReport|RepFWM(oReport)} DESCRIPTION cDesc
DEFINE SECTION oFWM 			OF oReport TITLE STR0003 TABLES "FWM" //"Processo de Aglutinação"
DEFINE CELL NAME "FWM_PROCES"  	OF oFWM ALIAS "FWM"
DEFINE CELL NAME "FWM_SUBPRO"	OF oFWM ALIAS "FWM"
DEFINE CELL NAME "PREFIXO" 		OF oFWM BLOCK {|| FIN870SEK((cAliasQry)->FK7_CHAVE,"1")} 	SIZE TamSX3("E2_NUM")[1]		TITLE STR0004 		//"Prefixo"
DEFINE CELL NAME "NUMAGL" 		OF oFWM BLOCK {|| FIN870SEK((cAliasQry)->FK7_CHAVE,"2")} 	SIZE TamSX3("E2_NUM")[1]		TITLE STR0005		//"Num. Título"
DEFINE CELL NAME "CNPJAGL" 		OF oFWM BLOCK {|| FIN870SEK((cAliasQry)->FK7_CHAVE,"3")} 	SIZE TamSX3("A2_CGC")[1]		TITLE STR0006		//"CNPJ/CPF"
DEFINE CELL NAME "CODRET" 		OF oFWM BLOCK {|| FIN870SEK((cAliasQry)->FK7_CHAVE,"4")} 	SIZE TamSX3("E2_RETINS")[1]		TITLE STR0007		//"Cod. Ret."
DEFINE CELL NAME "VALINSS" 		OF oFWM BLOCK {|| FIN870SEK((cAliasQry)->FK7_CHAVE,"5")} 	SIZE TamSX3("E2_VALOR")[1]		TITLE STR0008	PICTURE X3Picture("E2_VALOR") //"Val. INSS"
DEFINE CELL NAME "VENCINS" 		OF oFWM BLOCK {|| FIN870SEK((cAliasQry)->FK7_CHAVE,"7")} 	SIZE TamSX3("E2_VENCREA")[1]	TITLE STR0011		//"Vencimento"

DEFINE SECTION oFK7 OF oFWM TITLE STR0014 TABLES "FK7","FWM" //"Titulo Aglutinado"
DEFINE CELL NAME "FORNECE"		OF oFK7 BLOCK {|| FIN870SEK((cAliasQry)->FK7_CHAVE,"6",(cAliasQry)->(FWM_FILIAL + FWM_FK7ORI),"1")}		SIZE TamSX3("A2_NOME")[1]	TITLE STR0009		//"Fornecedor"
DEFINE CELL NAME "PESSOA" 		OF oFK7 BLOCK {|| FIN870SEK((cAliasQry)->FK7_CHAVE,"6",(cAliasQry)->(FWM_FILIAL + FWM_FK7ORI),"2")}		SIZE 8						TITLE STR0010 		//"Tipo de Fornec."
DEFINE CELL NAME "CGCFOR" 		OF oFK7 BLOCK {|| FIN870SEK((cAliasQry)->FK7_CHAVE,"6",(cAliasQry)->(FWM_FILIAL + FWM_FK7ORI),"3")}		SIZE TamSX3("A2_CGC")[1]	TITLE STR0006		//"CNPJ/CPF"
DEFINE CELL NAME "TITORIG" 		OF oFK7 BLOCK {|| FIN870SEK((cAliasQry)->FK7_CHAVE,"6",(cAliasQry)->(FWM_FILIAL + FWM_FK7ORI),"4")}		SIZE TamSX3("E2_NUM")[1]	TITLE STR0005		//"Titulo"
DEFINE CELL NAME "CODRET"		OF oFK7 BLOCK {|| FIN870SEK((cAliasQry)->FK7_CHAVE,"6",(cAliasQry)->(FWM_FILIAL + FWM_FK7ORI),"5")}		SIZE TamSX3("E2_RETINS")[1]	TITLE STR0007		//"Cod. Ret."
DEFINE CELL NAME "VALTIT"		OF oFK7 BLOCK {|| FIN870SEK((cAliasQry)->FK7_CHAVE,"6",(cAliasQry)->(FWM_FILIAL + FWM_FK7ORI),"6")}		SIZE TamSX3("E2_VALOR")[1]	TITLE STR0008 	PICTURE X3Picture("E2_VALOR") //"Val. INSS"
DEFINE CELL NAME "VENCREA"		OF oFK7 BLOCK {|| FIN870SEK((cAliasQry)->FK7_CHAVE,"6",(cAliasQry)->(FWM_FILIAL + FWM_FK7ORI),"7")}		SIZE TamSX3("E2_VENCREA")[1] TITLE STR0011		//"Vencimento"
oFWM:SetAutoSize()
oFK7:SetAutoSize()

Return oReport

/*{Protheus.doc}ReportDef
@author Kaique Schiller
@since 22/06/2015
@version P12
*/
Static Function RepFWM(oReport)

Local oFWM 		:= oReport:Section(1)
Local oFK7 		:= oReport:Section(1):Section(1)
Local aSelFil	:= {}
Local cWhere	:= ""

Pergunte(cPerg, .F.)

If MV_PAR03 == 1
	aSelFil := AdmGetFil()
	If Empty(aSelFil)
		Return
	Else
		cWhere := " FWM.FWM_FILIAL " + GetRngFil(aSelFil, "FWM")
	Endif
Else
	cWhere := " FWM.FWM_FILIAL = '" + XFilial("FWM") + "' "
Endif
cWhere := "%" + cWhere + "%"

BEGIN REPORT QUERY oFWM

BeginSql alias cAliasQry

SELECT
	FWM_FILIAL,
	FWM_PROCES,
	FWM_SUBPRO,
	FWM_FK7ORI,
	FWM_FK7DES,
	FWM_STATUS,
	FWM_EMISS,
	FK7_FILIAL,
	FK7_IDDOC,
	FK7_CHAVE

FROM
	%table:FWM% FWM

INNER JOIN %table:FK7% FK7 ON
	FK7_FILIAL  = FWM_FILIAL AND
	FK7_IDDOC	= FWM_FK7DES AND
	FK7.%NotDel%

WHERE
	%Exp:cWhere% AND
	FWM_EMISS BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02% AND
	FWM_STATUS = '1' AND
	FWM.%NotDel%

ORDER BY FWM_FILIAL, FWM_PROCES, FWM_SUBPRO

EndSql

END REPORT QUERY oFWM

oFK7:SetParentQuery()
oFK7:SetParentFilter({|cParam| (cAliasQry)->(FWM_FILIAL + FWM_PROCES + FWM_SUBPRO) == cParam},{|| (cAliasQry)->(FWM_FILIAL + FWM_PROCES + FWM_SUBPRO)})

oFWM:Print()

Return

/*{Protheus.doc}FIN870SEK
@author Kaique Schiller
@since 22/06/2015
@version P12
*/
Static Function FIN870SEK(cChv,cCmp,cOrig,cCmm)

Local aChave	:= {}
Local aAreaSE2	:= SE2->(GetArea())
Local aAreaSA2	:= SA2->(GetArea())
Local cSepara	:= "|"
Local cRet		:= ""
Local nVA		:= 0
Local cChaveSE2	:= ""
Default cChv	:= ""
Default cCmp	:= ""
Default cOrig	:= ""
Default cCmm	:= ""

aChave		:= STRTOKARR(cChv,cSepara)
cChaveSE2	:= aChave[1]+aChave[2]+aChave[3]+aChave[4]+aChave[5]+aChave[6]+Alltrim(aChave[7])

SE2->(DbSetOrder(1))  // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA.
If cCmp == "1"
	If SE2->(DbSeek(cChaveSE2, .F.))
		cRet := SE2->E2_PREFIXO
	Endif
Elseif cCmp == "2"
	If SE2->(DbSeek(cChaveSE2, .F.))
		cRet := SE2->E2_NUM
	Endif
Elseif cCmp == "3"
	If SE2->(DbSeek(cChaveSE2, .F.))
		If !Empty(SE2->E2_CNPJRET)
			If Len(Alltrim(SE2->E2_CNPJRET)) > 12
				cRet := Transform(SE2->E2_CNPJRET, "@R 99.999.999/9999-99")
			Else
				cRet := Transform(SE2->E2_CNPJRET, "@R 999.999.999-99")
			Endif
		Endif
	Endif
Elseif cCmp == "4"
	If SE2->(DbSeek(cChaveSE2, .F.))
		cRet := SE2->E2_RETINS
	Endif
Elseif cCmp == "5"
	If SE2->(DbSeek(cChaveSE2, .F.))
		cRet := SE2->E2_VALOR
	Endif
Elseif cCmp == "6"
	FK7->(DbSetOrder(1))  // FK7_FILIAL, FK7_IDDOC.
	If FK7->(DbSeek(cOrig, .F.))
		cChv		:= FK7->FK7_CHAVE
		aChave		:= STRTOKARR(cChv,cSepara)
		cChaveSE2	:= aChave[1]+aChave[2]+aChave[3]+aChave[4]+aChave[5]+aChave[6]+Alltrim(aChave[7])
		If SE2->(DbSeek(cChaveSE2, .F.))
			If cCmm == "6"
				//Valores Acessórios.
				nVa	:= FValAcess(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_NATUREZ, .T./*lBaixados*/,/*cCodVa*/,"P")	
				cRet := SE2->E2_VALOR + nVA

			Elseif cCmm == "7"
				//Vencimento do titulo de INSS
				cRet := SE2->E2_VENCREA

			Elseif SE2->(DbSeek(xFilial("SE2", SE2->E2_FILORIG) + Rtrim(SE2->E2_TITPAI), .F.))
				SA2->(DbSetOrder(1))  // A2_FILIAL, A2_COD, A2_LOJA.
				If SA2->(msSeek(xFilial("SA2",SE2->E2_FILORIG)+SE2->E2_FORNECE+SE2->E2_LOJA, .F.))
					If cCmm == "1"
						cRet := SA2->A2_NOME
					Elseif cCmm == "2"
						If SA2->A2_TIPO == "J"
							cRet := "Juridico"
						Elseif SA2->A2_TIPO == "F"
							cRet := "Fisico"
						Elseif SA2->A2_TIPO == "X"
							cRet := "Outros"
						Endif
					Elseif cCmm == "3"
						If !Empty(SA2->A2_CGC)
							If Len(Alltrim(SA2->A2_CGC)) > 12
								cRet := Transform(SA2->A2_CGC, "@R 99.999.999/9999-99")
							Else
								cRet := Transform(SA2->A2_CGC, "@R 999.999.999-99")
							Endif
						Endif
					Elseif cCmm == "4"
						cRet := SE2->E2_NUM
					Elseif cCmm == "5"
						cRet := SE2->E2_RETINS
					Endif
				Endif
			Endif
		Endif
	Endif
Elseif cCmp == "7"
	If SE2->(DbSeek(cChaveSE2, .F.))
		cRet := SE2->E2_VENCREA
	Endif
Endif

RestArea(aAreaSE2)
RestArea(aAreaSA2)

Return(cRet)
