#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSP060.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSP060()
Este painel tem como objetivo exibir a somatoria do valor de faturamento 
por região de acordo com os parametros de Filial, Regiao e Periodo. 
@author Robson M
@since 07/10/2013
@version P12 
/*/
//------------------------------------------------------------------- 
Function TMSP060()

Local aInfo     := {}
Local aInfCal   := {}
Local nCnt      := 0
Local cMsg      := ""
Local cDescOri 	:= ""
Local cDescDes 	:= ""
Local cDescCal 	:= ""
Private aInfAux := {}
Private aInfOri := {}
Private aInfDes := {}

aInfAux := TMSGerQry(aInfOri,aInfDes,aInfCal)
 
cMsg := STR0001//"'"+"Este painel tem como objetivo exibir a somatoria do valor de faturamento por "+"'+chr(13)+chr(10)+"
cMsg += STR0002//"'"+"região de acordo com os parametros de Filial, Regiao e Periodo."+"'"

Aadd(aInfo, { STR0004 } ) //-- "Reg. Origem"
Aadd(aInfo[Len(aInfo)] , {} )
For nCnt := 1 To Len(aInfOri) 
	cDescOri:=POSICIONE("DUY", 1, aInfOri[nCnt,3] + aInfOri[nCnt,1], "DUY_DESCRI")
	Aadd(aInfo[Len(aInfo)][2] , { cDescOri , Transform(aInfOri[nCnt,2],"@E 99,999,999,999.99") , CLR_BLUE, "{ || MsgInfo("+cMsg+") }" } )
Next nCnt 

Aadd(aInfo, {  STR0005 } ) //-- "Reg. Destino"
Aadd(aInfo[Len(aInfo)] , {} )
For nCnt := 1 To Len(aInfDes)
	cDescDes:=POSICIONE("DUY", 1, aInfDes[nCnt,3] + aInfDes[nCnt,1], "DUY_DESCRI")
	Aadd(aInfo[Len(aInfo)][2] , { cDescDes , Transform(aInfdes[nCnt,2],"@E 99,999,999,999.99") , CLR_BLUE, "{ || MsgInfo("+cMsg+") }" } )
Next nCnt

Aadd(aInfo, {  STR0006 } ) //--"Reg. Calc"
Aadd(aInfo[Len(aInfo)] , {} )
For nCnt := 1 To Len(aInfCal)
	cDescCal:=POSICIONE("DUY", 1, aInfCal[nCnt,3] + aInfCal[nCnt,1], "DUY_DESCRI")
	Aadd(aInfo[Len(aInfo)][2] , { cDescCal , Transform(aInfCal[nCnt,2],"@E 99,999,999,999.99") , CLR_BLUE, "{ || MsgInfo("+cMsg+") }" } )
Next nCnt    
     
//-- Tratamento para tabela de Documentos de Transporte (DT6) sem dados.
If Len(aInfAux) == 0
	Aadd(aInfOri ,{STR0003,0,''}) //'Não há dados para exibir'
	Aadd(aInfDes ,{STR0003,0,''}) //'Não há dados para exibir'
	Aadd(aInfCal ,{STR0003,0,''}) //'Não há dados para exibir'
EndIf


Return aInfo

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSGerQry ³ Autor ³ Rodolfo K. Rosseto    ³ Data ³11.01.07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera a Query que sera exibida pelo Painel de Gestao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function TMSGerQry(aInfOri,aInfDes,aInfCal)

Local cAliasQry := GetNextAlias()
Local cPerg     := "TMSP060"
Local cFilDe    := ""
Local cFilAte   := ""
Local cRegDe	:= ""
Local cRegAte	:= ""
Local cDatDe	:= ""
Local cDatAte	:= ""

Pergunte(cPerg,.F.)

cFilDe := xFilial("DT6", MV_PAR01)
cFilAte:= xFilial("DT6", MV_PAR02)
cRegDe := MV_PAR03
cRegAte:= MV_PAR04
cDatDe := DTOS(MV_PAR05)
cDatAte:= DTOS(MV_PAR06)

MakeSqlExpr(cPerg)
    
//Query para buscar informacoes a partir do Codigo da Regiao Origem
BeginSql Alias cAliasQry
	
	SELECT  DT6_CDRORI,	SUM(DT6_VALFAT) DT6_VALFAT, DT6_FILIAL
	
	FROM %table:DT6% DT6

	WHERE 
		DT6_FILIAL 	BETWEEN %Exp:cFilDe%  AND %Exp:cFilAte%
		AND DT6_CDRORI  BETWEEN %Exp:cRegDe%  AND %Exp:cRegAte%
		AND DT6_DATEMI  BETWEEN %Exp:cDatDe%  AND %Exp:cDatAte%                                       
		AND DT6.%NotDel%	
	GROUP BY DT6_CDRORI, DT6_FILIAL

EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aInfOri ,{ (cAliasQry)->DT6_CDRORI,(cAliasQry)->DT6_VALFAT,(cAliasQry)->DT6_FILIAL } )
		(cAliasQry)->(DbSkip())
	EndDo
EndIf
(cAliasQry)->(DbCloseArea())

//Query para buscar informacoes a partir do Codigo da Regiao Destino
BeginSql Alias cAliasQry
	
	SELECT  DT6_CDRDES,	SUM(DT6_VALFAT) DT6_VALFAT, DT6_FILIAL
	
	FROM %table:DT6% DT6
	
	WHERE DT6_FILIAL    BETWEEN %Exp:cFilDe%  AND %Exp:cFilAte%
	AND DT6_CDRDES  BETWEEN %Exp:cRegDe%  AND %Exp:cRegAte%
	AND DT6_DATEMI  BETWEEN %Exp:cDatDe%  AND %Exp:cDatAte%
	AND DT6.%NotDel%
	
	GROUP BY   DT6_CDRDES, DT6_FILIAL
	
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aInfDes ,{ (cAliasQry)->DT6_CDRDES,(cAliasQry)->DT6_VALFAT,(cAliasQry)->DT6_FILIAL } )
		(cAliasQry)->(DbSkip())
	EndDo
EndIf
(cAliasQry)->(DbCloseArea())

//Query para buscar informacoes a partir do Codigo da Regiao de Calculo
BeginSql Alias cAliasQry
	
	SELECT  DT6_CDRCAL,	SUM(DT6_VALFAT) DT6_VALFAT , DT6_FILIAL
	
	FROM %table:DT6% DT6
	
	WHERE DT6_FILIAL    BETWEEN %Exp:cFilDe%  AND %Exp:cFilAte%
	AND DT6_CDRCAL  BETWEEN %Exp:cRegDe%  AND %Exp:cRegAte%
	AND DT6_DATEMI  BETWEEN %Exp:cDatDe%  AND %Exp:cDatAte%
	AND DT6.%NotDel%
	
	GROUP BY   DT6_CDRCAL, DT6_FILIAL
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aInfCal ,{ (cAliasQry)->DT6_CDRCAL,(cAliasQry)->DT6_VALFAT,(cAliasQry)->DT6_FILIAL } )
		(cAliasQry)->(DbSkip())
	EndDo
EndIf
(cAliasQry)->(DbCloseArea())

Return (aInfOri,aInfDes,aInfCal)   