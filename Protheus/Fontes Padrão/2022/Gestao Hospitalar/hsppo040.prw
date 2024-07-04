#INCLUDE "PROTHEUS.CH"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFun┤┘o    ЁHSPPO040  Ё Autor Ё Darcio Sporl          Ё Data Ё 15/04/2009 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁMonta array para Painel de Gestao Tipo 4 Padrao 1: O objetivo Ё╠╠
╠╠Ё          Ёdeste painel e demonstrar a Taxa de Ocupacao Hospitalar.      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁHSPPO040()                                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё SIGAMDI                                                      Ё╠╠
╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function HSPPO040()

Local aArea		:= GetArea()
Local aAreaGCY	:= GCY->(GetArea())
Local aAreaGAV	:= GAV->(GetArea())
Local cAliasGCY	:= "GCY"
Local cAliasGAV	:= "GAV"
Local aRet		:= {} 
Local cMes		:= StrZero(Month(dDataBase),2)		//Mes atual
Local cMesA		:= Iif(cMes == "01", "12", StrZero(Val(cMes) - 1,2))
Local cAno		:= Substr(DTOC(dDataBase),7,2)		//Ano atual
Local cAnoA		:= Iif(cMesA == "12", StrZero(Val(cAno) - 1,2), cAno)
Local dDataIniM	:= CTOD("01/"+cMes+"/"+cAno)									//Primeiro dia do mes atual
Local dDataFimM	:= CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)		//Ultimo dia do mes atual
Local dDataAntI := CTOD("01/"+cMesA+"/"+cAnoA)									//Primeiro dia do mes anterior
Local dDataAntF := CTOD(StrZero(F_ULTDIA(dDataAntI),2)+"/"+cMesA+"/"+cAnoA)	//Ultimo dia do mes anterior
Local nIntern	:= 0
Local nInternA	:= 0
Local nIntTot	:= 0
Local nLeitEx	:= 0
Local nLeitExA	:= 0
Local cDtSai	:= '        '
//Local cEstati	:= '1'
//Local cStatus	:= '0/1/2/3'
Local aMeses	:= {}

aAdd(aMeses, "JAN")  //"JANEIRO"
aAdd(aMeses, "FEV")  //"FEVEREIRO"
aAdd(aMeses, "MAR")  //"MARгO"
aAdd(aMeses, "ABR")  //"ABRIL"
aAdd(aMeses, "MAI")  //"MAIO"
aAdd(aMeses, "JUN")  //"JUNHO"
aAdd(aMeses, "JUL")  //"JULHO"
aAdd(aMeses, "AGO")  //"AGOSTO"
aAdd(aMeses, "SET")  //"SETEMBRO"
aAdd(aMeses, "OUT")  //"OUTUBRO"
aAdd(aMeses, "NOV")  //"NOVEMBRO"
aAdd(aMeses, "DEZ")  //"DEZEMBRO"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                        Ё
//Ё               I N T E R N A D O S  M E S  A T U A L                    Ё
//Ё                                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁQuantidade de pacientes internados                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cAliasGCY := GetNextAlias()

BeginSql alias cAliasGCY
 SELECT GB1.GB1_DATAE DTINI,GB1.GB1_DATAS DTFIM, 1 SAIDAS
 FROM %table:GB1% GB1 
 WHERE GB1.GB1_FILIAL = %xFilial:GB1% AND GB1.%NotDel%
   AND GB1.GB1_DATAE BETWEEN %Exp:DTOS(dDataIniM)% AND %Exp:DTOS(dDataFimM)%
   AND GB1.GB1_DATAS BETWEEN %Exp:DTOS(dDataIniM)% AND %Exp:DTOS(dDataFimM)%
 UNION
 SELECT %Exp:dDataIniM% DTINI, GB1.GB1_DATAS DTFIM, 1 SAIDAS
 FROM %table:GB1% GB1 
 WHERE GB1.GB1_FILIAL = %xFilial:GB1% AND GB1.%NotDel%
   AND GB1.GB1_DATAE < %Exp:DTOS(dDataIniM)%
   AND GB1.GB1_DATAS BETWEEN %Exp:DTOS(dDataIniM)% AND %Exp:DTOS(dDataFimM)%
 UNION
 SELECT GB1.GB1_DATAE DTINI,%Exp:DTOS(dDataBase)% DTFIM, 0 SAIDAS
 FROM %table:GB1% GB1 
 WHERE GB1.GB1_FILIAL = %xFilial:GB1% AND GB1.%NotDel%
   AND GB1.GB1_DATAE BETWEEN %Exp:DTOS(dDataIniM)% AND %Exp:DTOS(dDataFimM)%
   AND GB1.GB1_DATAS = %Exp:cDtSai% 
 UNION
 SELECT %Exp:dDataIniM% DTINI,%Exp:DTOS(dDataBase)% DTFIM, 0 SAIDAS
 FROM %table:GB1% GB1 
 WHERE GB1.GB1_FILIAL = %xFilial:GB1% AND GB1.%NotDel%
   AND GB1.GB1_DATAE < %Exp:DTOS(dDataIniM)%
   AND GB1.GB1_DATAS = %Exp:cDtSai%    
EndSql

While !(cAliasGCY)->(EOF())	
	nIntern += STOD((cAliasGCY)->DTFIM) - STOD((cAliasGCY)->DTINI)
	(cAliasGCY)->(DbSkip())
End

(cAliasGCY)->(DbCloseArea())

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                        Ё
//Ё               I N T E R N A D O S  M E S  A N T E R I O R              Ё
//Ё                                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁQuantidade de pacientes internados                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cAliasGCY := GetNextAlias()

BeginSql alias cAliasGCY
 SELECT GB1.GB1_DATAE DTINI,GB1.GB1_DATAS DTFIM, 1 SAIDAS
 FROM %table:GB1% GB1 
 WHERE GB1.GB1_FILIAL = %xFilial:GB1% AND GB1.%NotDel%
   AND GB1.GB1_DATAE BETWEEN %Exp:DTOS(dDataAntI)% AND %Exp:DTOS(dDataAntF)%
   AND GB1.GB1_DATAS BETWEEN %Exp:DTOS(dDataAntI)% AND %Exp:DTOS(dDataAntF)%
 UNION
 SELECT %Exp:dDataAntI% DTINI, GB1.GB1_DATAS DTFIM, 1 SAIDAS
 FROM %table:GB1% GB1 
 WHERE GB1.GB1_FILIAL = %xFilial:GB1% AND GB1.%NotDel%
   AND GB1.GB1_DATAE < %Exp:DTOS(dDataAntI)%
   AND GB1.GB1_DATAS BETWEEN %Exp:DTOS(dDataAntI)% AND %Exp:DTOS(dDataAntF)%
 UNION
 SELECT GB1.GB1_DATAE DTINI,%Exp:dDataAntF% DTFIM, 0 SAIDAS
 FROM %table:GB1% GB1 
 WHERE GB1.GB1_FILIAL = %xFilial:GB1% AND GB1.%NotDel%
   AND GB1.GB1_DATAE BETWEEN %Exp:DTOS(dDataAntI)% AND %Exp:DTOS(dDataAntF)%
   AND GB1.GB1_DATAS > %Exp:DTOS(dDataAntF)%
 UNION
 SELECT %Exp:dDataAntI% DTINI,%Exp:dDataAntF% DTFIM, 0 SAIDAS
 FROM %table:GB1% GB1 
 WHERE GB1.GB1_FILIAL = %xFilial:GB1% AND GB1.%NotDel%
   AND GB1.GB1_DATAE < %Exp:DTOS(dDataAntI)%
   AND (GB1.GB1_DATAS > %Exp:DTOS(dDataAntF)% OR GB1.GB1_DATAS =  %Exp:cDtSai% )
EndSql

While !(cAliasGCY)->(EOF())	
	nInternA += STOD((cAliasGCY)->DTFIM) - STOD((cAliasGCY)->DTINI)
	(cAliasGCY)->(DbSkip())
End

(cAliasGCY)->(DbCloseArea())

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                        Ё
//Ё        L E I T O S  E X I S T E N T E S  M E S  A T U A L              Ё
//Ё                                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁQuantidade de leitos existentes                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
/*
cAliasGAV := GetNextAlias()

BeginSql alias cAliasGAV
 SELECT count(GAV.GAV_REGGER) LEITOSEX
 FROM %table:GAV% GAV 
 WHERE GAV.GAV_FILIAL = %xFilial:GAV% AND GAV.%NotDel%
   AND GAV.GAV_DATATE BETWEEN %Exp:DTOS(dDataIniM)% AND %Exp:DTOS(dDataFimM)%
   AND GAV.GAV_ESTATI = %Exp:cEstati% AND GAV_STATUS LIKE %Exp:cStatus%
EndSql
*/
//nLeitEx := (cAliasGAV)->LEITOSEX
nLeitEx := FS_QTDLEI(DTOS(dDataIniM))
(cAliasGAV)->(DbCloseArea())

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                                                                        Ё
//Ё        L E I T O S  E X I S T E N T E S  M E S  A N T E R I O R        Ё
//Ё                                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁQuantidade de leitos existentes                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
/*
cAliasGAV := GetNextAlias()

BeginSql alias cAliasGAV
 SELECT count(GAV.GAV_REGGER) LEITOSEX
 FROM %table:GAV% GAV 
 WHERE GAV.GAV_FILIAL = %xFilial:GAV% AND GAV.%NotDel%
   AND GAV.GAV_DATATE BETWEEN %Exp:DTOS(dDataIniM)% AND %Exp:DTOS(dDataFimM)%
   AND GAV.GAV_ESTATI = %Exp:cEstati% AND GAV_STATUS LIKE %Exp:cStatus%
EndSql
*/
//nLeitExA := (cAliasGAV)->LEITOSEX
nLeitExA := FS_QTDLEI(DTOS(dDataAntI))
(cAliasGAV)->(DbCloseArea())

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFormula CQG 2002 (Pacientes-dia / Leitos-dia * 100)                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

nIntTotA	:= Round((nInternA / nLeitExA) * 100,2)
nIntTot		:= Round((nIntern / nLeitEx) * 100,2)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁPreenche array do Painel de Gestao                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

aRet := { "",0,100, { { Str(nIntTotA) + "%",aMeses[Val(cMesA)], CLR_RED,Nil ,nIntTotA },{ Str(nIntTot) + "%",aMeses[Val(cMes)], CLR_BLUE,Nil ,nIntTot }  }  } 

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁRestaura areas                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
RestArea(aAreaGAV)
RestArea(aAreaGCY)
RestArea(aArea)


Return aRet

/*эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁFS_QTDLEI ╨       Ё MARCELO JOSE       ╨ Data Ё 20/09/2007  ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё CALCULA A QTDE DE LEITOS NO  MES/ANO                       ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё GESTAO HOSPITALAR.                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Static Function FS_QTDLEI(cData)
Local aArea		:= GetArea()
Local nRet      := 0
Local cDataIni  := Substr(DTOS(CTOD("01/" + Substr(cData, 5, 2) + "/" + Substr(cData, 1, 4))) ,1, 8) 
Local cDataFim  := DTOS(LastDay(stod(cDataIni)))
Local cSql		:= ""

If "ORACLE" $ Upper(TCGETDB()) 
	cSql := "SELECT SUM(CASE WHEN GAV.GAV_DTCRIA <= '" + cDataIni + "' THEN (TO_DATE('" + cDataFim + "','YYYYMMDD')- TO_DATE('" + cDataIni + "','YYYYMMDD')) ELSE (TO_DATE('" + cDataFim + "','YYYYMMDD')- TO_DATE(GAV.GAV_DTCRIA,'YYYYMMDD')) END) QTDMES " 
Else
	cSql := "SELECT SUM(CASE WHEN GAV.GAV_DTCRIA <= '" + cDataIni + "' THEN (DAY('" + cDataFim + "')- DAY('" + cDataIni + "')) ELSE (DAY('" + cDataFim + "')- DAY(GAV.GAV_DTCRIA)) END) QTDMES "   
EndIf
cSql +=	"FROM " + RetSqlName("GAV") + " GAV " + ;
		"WHERE GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' " + ;
		"  AND GAV.GAV_DTCRIA IS NOT NULL AND GAV_DTCRIA <= '" + cDataFim + "' AND GAV_ESTATI = '1'"
//		"  AND GAV.GAV_CODLOC = '" + cSet + "' "

cSql := ChangeQuery(cSql)

dbUseArea(.T., "TOPCONN", TcGenQry(,, cSql), "QTDLEI", .T., .T.)  
nRet := QTDLEI->QTDMES
dbCloseArea()           

If "ORACLE" $ Upper(TCGETDB()) 
	cSql :=	"SELECT SUM(TO_DATE(CASE WHEN GF8.GF8_DATFIN='"+SPACE(8)+"' THEN '" + cDataFim + "' ELSE (CASE WHEN GF8.GF8_DATFIN >= '" + cDataFim + "' THEN  '" + cDataFim + "' ELSE GF8.GF8_DATFIN END) END,'YYYYMMDD') - " + ; 
			" TO_DATE(CASE WHEN GF8.GF8_DATINI <= '" + cDataIni + "' THEN  '" + cDataIni + "' ELSE GF8.GF8_DATINI END,'YYYYMMDD')) QTDINT  " 
Else
	cSql :=	"SELECT SUM(DAY(CASE WHEN GF8.GF8_DATFIN=SPACE(8) THEN '" + cDataFim + "' ELSE (CASE WHEN GF8.GF8_DATFIN >= '" + cDataFim + "' THEN  '" + cDataFim + "' ELSE GF8.GF8_DATFIN END) END) - " + ; 
			" DAY(CASE WHEN GF8.GF8_DATINI <= '" + cDataIni + "' THEN  '" + cDataIni + "' ELSE GF8.GF8_DATINI END)) QTDINT  " 
EndIf 
cSql += "FROM " + RetSqlName("GF8") + " GF8 " + ;
        "JOIN " + RetSqlName("GAV") + " GAV ON GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV_CODLOC = GF8_CODLOC AND GAV_ESTATI = '1' " + ;
        "WHERE GF8_FILIAL = '" + xFilial("GF8") + "' AND GF8.D_E_L_E_T_ <> '*' " + ;
        "  AND GF8.GF8_DATINI >= '" + cDataIni + "' "
//        "  AND GF8.GF8_CODLOC = '" + cSet + "' "

cSql := ChangeQuery(cSql)

dbUseArea(.T., "TOPCONN", TcGenQry(,, cSql), "QTDLEI", .T., .T.)  

nRet := nRet - QTDLEI->QTDINT

dbCloseArea()           
RestArea(aArea)
Return(nRet)