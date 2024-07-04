#INCLUDE "PROTHEUS.CH"
#INCLUDE "QUICKSEARCH.CH"
#INCLUDE "GPEQ630.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEQ630  ³ Autor ³ Leandro Drumond         ³ Data ³ 26.03.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Quick Search Recibo de Pagamento		                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FLUIG                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³Chamado|  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³       ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

QSSTRUCT GPEA630 DESCRIPTION STR0001 MODULE 7 //"Recibo de Pagamento"

QSMETHOD INIT QSSTRUCT GPEA630
	Local _cUserEmp := ""
	Local _cUserFil := ""
	Local _cUserMat := ""
	Local _cUserCPF	:= ""
	Local cExp1		:= ""
	Local cExp2		:= ""
	Local cMultVinc := ""
	
	//Obtem as informacoes do usuario
	//__cUserId := "000001" //--Utilizado para teste no POC
	
	RhGetFuncInfo(@_cUserEmp,@_cUserFil,@_cUserMat,,,@_cUserCPF,,.F.)

	QSTABLE "SRA" JOIN "SQB" ON "RA_DEPTO = QB_DEPTO AND " + FWJoinFilial( "SRA", "SQB" )
	QSTABLE "SRA" LEFT JOIN "SRJ" ON "RA_CODFUNC = RJ_FUNCAO AND " + FWJoinFilial( "SRA", "SRJ" )
	QSTABLE "SRA" JOIN "SRD" ON "RA_FILIAL = RD_FILIAL AND RA_MAT = RD_MAT"
	QSTABLE "SRD" JOIN "SRY" ON "RD_ROTEIR = RY_CALCULO AND "  + FWJoinFilial( "SRD", "SRY" )
	QSTABLE "SRD" JOIN "RCH" ON "RCH_PROCES = RD_PROCES AND RCH_PER = RD_PERIODO AND RCH_ROTEIR = RD_ROTEIR AND RCH_NUMPAG = RD_SEMANA AND "  + FWJoinFilial( "SRD", "RCH" )
	QSTABLE "SRD" JOIN "SRV" ON "RV_COD = RD_PD AND " + FWJoinFilial( "SRD", "SRV" )
	
	// campos do SX3 e indices do SIX
	QSPARENTFIELD "RA_MAT" INDEX ORDER 1

	//Monta expressao com subquery para obter total bruto e liquido.
 	cExp1 := "( SELECT SUM(RD_VALOR) FROM " + RetSqlName("SRD") + " SRDAUX INNER JOIN " + RetSqlName("SRV") + " SRVAUX ON " + StrTran(StrTran(FWJoinFilial( "SRD", "SRV" ),"SRD.","SRDAUX."),"SRV.","SRVAUX.") + " AND SRDAUX.RD_PD = SRVAUX.RV_COD AND " + StrTran(StrTran(FWJoinFilial( "SRD", "SRV" ),"SRD.","SRDAUX."),"SRV.","SRVAUX.") + " AND SRVAUX.D_E_L_E_T_=' ' WHERE SRDAUX.RD_FILIAL = SRA.RA_FILIAL AND SRDAUX.RD_MAT = RA_MAT AND SRDAUX.RD_PERIODO = RCH.RCH_PER AND SRDAUX.RD_ROTEIR = RCH.RCH_ROTEIR AND SRDAUX.RD_SEMANA = RCH.RCH_NUMPAG AND SRDAUX.RD_PROCES = RD_PROCES AND SRVAUX.RV_TIPOCOD = '1' )"
	cExp2 := "( " + cExp1 + " - ( SELECT SUM(RD_VALOR) FROM " + RetSqlName("SRD") + " SRDAUX INNER JOIN " + RetSqlName("SRV") + " SRVAUX ON " + StrTran(StrTran(FWJoinFilial( "SRD", "SRV" ),"SRD.","SRDAUX."),"SRV.","SRVAUX.") + " AND SRDAUX.RD_PD = SRVAUX.RV_COD AND  " + StrTran(StrTran(FWJoinFilial( "SRD", "SRV" ),"SRD.","SRDAUX."),"SRV.","SRVAUX.") + "  AND SRVAUX.D_E_L_E_T_=' ' WHERE SRDAUX.RD_FILIAL = SRA.RA_FILIAL AND SRDAUX.RD_MAT = RA_MAT AND SRDAUX.RD_PERIODO = RCH.RCH_PER AND SRDAUX.RD_ROTEIR = RCH.RCH_ROTEIR AND SRDAUX.RD_SEMANA = RCH.RCH_NUMPAG AND SRDAUX.RD_PROCES = RD_PROCES AND SRVAUX.RV_TIPOCOD = '2' ) )"
	
	//Remove essas tabelas do primary key , senão os campos delas aparecem no group by e interferem no resultado da query
	::RemovePrimaryKey({'SQB','SRJ','SRD','SRY','RCH','SRV'})
	
	// campos do SX3
	QSFIELD "MESANO"   EXPRESSION ("RCH_MES + '/' + RCH_ANO") LABEL PorEncode(STR0012) FIELDS "RCH_PER","RCH_MES","RCH_ANO","RCH_ROTEIR" GROUP BY  TYPE "C" SIZE 5 DECIMAL 0 PICTURE "@!" //Mês/Ano
	//QSFIELD "MESANO"   EXPRESSION ("RCH_MES + '/' + RCH_ANO") LABEL PorEncode(STR0012)  TYPE "C" SIZE 5 DECIMAL 0 PICTURE "@!" //Mês/Ano
	//QSFIELD "RA_NOME"
	//QSFIELD "RA_MAT"	   
	QSFIELD "SALLIQ"   EXPRESSION cExp2 LABEL PorEncode(STR0004) FIELDS "RA_FILIAL"  TYPE "C" SIZE 5 DECIMAL 2 PICTURE "@E 999,999,999.99" //Salario Liquido
	QSFIELD "SALBRUTO" EXPRESSION cExp1 LABEL PorEncode(STR0003) FIELDS "RA_FILIAL"  TYPE "C" SIZE 5 DECIMAL 2 PICTURE "@E 999,999,999.99" //Salario Bruto
	//QSFIELD "SALLIQ"   EXPRESSION cExp2 LABEL PorEncode(STR0004)   TYPE "C" SIZE 5 DECIMAL 2 PICTURE "@E 999,999,999.99" //Salario Liquido
	//QSFIELD "SALBRUTO" EXPRESSION cExp1 LABEL PorEncode(STR0003)  TYPE "C" SIZE 5 DECIMAL 2 PICTURE "@E 999,999,999.99" //Salario Bruto
	
	QSFIELD "RY_DESC" LABEL PorEncode(STR0002) //"Tipo de Pagto."
	QSFIELD "RCH_DTPAGO"
	//QSFIELD "RA_DEPTO"
	//QSFIELD "QB_DESCRIC" LABEL PorEncode(STR0005) //"Descrição Departamento"
	//QSFIELD "RJ_DESC" LABEL PorEncode(STR0006) //"Função"
	QSFIELD "RCH_NUMPAG"  

	// acoes do menudef, MVC ou qualquer rotina
	QSACTION MENUDEF "GPEA630" OPERATION 2 LABEL STR0007 //"Visualizar"
	
	cMultVinc:= "RA_CIC = '" + _cUserCpf + "'"

	//A query ja vem por default com ( RA_FILAL = "filial ativa" AND )	aqui definimos o complemento, como a busca sera por todos os vinculos
	//foi colocado RA_MAT = '' para invalidar a primeira parte da query e o restante é o que efetivamente fara o filtro
	//Desta forma o filtro dinamico (busca) funcionara corretamente por será colocado na frente do restante da query (RA_MAT = '000001' por exemplo)
	QSFILTER PorEncode(STR0008) WHERE "RA_MAT = '' OR (" + cMultVinc + " AND RY_TIPO IN ('1','9')) " //Folha (FOL*AUT)
	QSFILTER PorEncode(STR0009) WHERE "RA_MAT = '' OR (" + cMultVinc + " AND RY_TIPO = '2') " 		//Adiantamento (ADI)
	QSFILTER OemtoAnsi(STR0010) WHERE "RA_MAT = '' OR (" + cMultVinc + " AND RY_TIPO IN ('5','6')) " //13o. Salario (131*132)
	
Return