#Include 'Protheus.ch'
#include "fwmvcdef.ch"
#include "fwbrowse.ch"
#include "AGRC010.CH"
/* 
+=================================================================================================+
| Função    : AGRC010                                                                             |
| Descrição : Consulta gerencial de Demanda X Disponibilidade                             |
| Autor     : Vitor Alexandre de Barba                                                                 |
| Data      : 01/10/2015                                                                          |
+=================================================================================================+                                                                           |  
*/
Function AGRC010()
	Local aCamTRB := {	{"ADA_FILIAL"},;
	{"ADA_NUMCTR"},;
	{"ADA_VEND1"},;
	{"A3_NOME" ,"C",TamSX3("A3_NOME")[1],TamSX3("A3_NOME")[2],"Vendedor",X3PICTURE('A3_NOME')},;
	{"ADA_CODCLI"},;
	{"ADA_LOJCLI"},;
	{"A1_NOME"},;
	{"A1_NREDUZ"},;
	{"A1_INSCR"},;
	{"ADA_TPFRET"},;
	{"A1_END"},;
	{"A1_EST"},;
	{"A1_MUN"},;
	{"A1_BAIRRO"},;
	{"A1_COMPLEM"},;
	{"A1_CEP"},;
	{"A1_TEL"},;
	{"A1_EMAIL"},;
	{"ADA_MOEDA"},;
	{"ADA_CODSAF"},;
	{"ADB_ITEM"},;
	{"ADB_CODPRO"},;
	{"ADB_DESPRO"},;
	{"ADB_UM"},;
	{"NP9_LOTE"},;
	{"ADB_CULTRA"},;
	{"NP3_DESCRI"},;
	{"ADB_CTVAR"},;
	{"NP4_DESCRI"},;
	{"ADB_PENE"},;
	{"ADB_CATEG"},; 
	{"ADB_QUANT"},;
	{"ADB_QTDENT"},;
	{"ADB_QTDEMP"},;
	{"DEMANDA"		,"N",TamSX3("ADB_QUANT")[1],TamSX3("ADB_QUANT")[2],"Demanda"	,X3PICTURE('ADB_QUANT')},;
	{"DISP"			,"N",TamSX3("ADB_QUANT")[1],TamSX3("ADB_QUANT")[2],"Disponivel"	,X3PICTURE('ADB_QUANT')},;
	{"SALDO" 		,"N",TamSX3("ADB_QUANT")[1],TamSX3("ADB_QUANT")[2],"Saldo"		,X3PICTURE('ADB_QUANT')}}

	Private cTRB3Al := " ",cAliTRBL,oBrw1,oBrw2

	vVetInd := {"A3_NOME","A1_NOME", "NP4_DESCRI","ADB_PENE","ADB_CODPRO+NP9_LOTE"}

	cPerg	   := AGRGRUPSX1("AGRC010")

	If !Pergunte(cPerg, .T.)
		Return
	EndIf            

	// Cria o arquivo temporário
	aRet := AGRCRIATRB(,aCamTRB,vVetInd,FunName(),.t.)

	If !aRet[1] // Problema na criação dos arquivos Temporário e indicou para mostrar na função
		Return
	EndIf  

	cNomeTRB := aRet[3] //Nome do arquivo temporário 
	cAliTRBL := aRet[4] //Nome do alias do arquivo temporario
	aArqTemp := aRet[5] //Matriz com a estrutura do arquivo temporario + label e picutre

	// Alimenta arquivo temporário
	Processa({|lEnd| AGRC010PRO(@lEnd)},STR0019,,.t.)

	ARGSETIFARQUI(cAliTRBL)
	AGRCONPAD(STR0020+"    "+STR0001+"  "+STR0002,cAliTRBL,cNomeTRB,aArqTemp,vVetInd,,,,,"AGRC010DUP()",,,,,"AGRC010F12()")

	AGRDELETRB(cAliTRBL,cNomeTRB)  
Return

/* 
+=================================================================================================+
| Função    : AGRC010PRO                                                                          |
| Descrição : Filtragem da base e alimentação do arquivo temporário                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/10/2014                                                                          |
+=================================================================================================+                                                                           |  
*/
static Function AGRC010PRO(lEnd)
	Local nQENT,nQEMP,nQVEND,nSaldo
	local cAliasQ 	:= GetNextAlias()
	local cAlias 	:= ""
	Local nRecCount :=0	


	cQry := " SELECT * "
	cQry += " FROM " +RetSqlName("ADA")+ " ADA "
	cQry += " INNER JOIN " +RetSqlName("SA1")+ " SA1 ON SA1.D_E_L_E_T_ <> '*'"
	cQry += " AND SA1.A1_COD = ADA.ADA_CODCLI"
	cQry += " AND SA1.A1_LOJA = ADA.ADA_LOJCLI"
	cQry += " INNER JOIN " +RetSqlName("ADB")+ " ADB ON ADB.D_E_L_E_T_ <> '*'"
	cQry += " AND ADA.ADA_FILIAL = ADB.ADB_FILIAL"
	cQry += " AND ADA.ADA_NUMCTR = ADB.ADB_NUMCTR"
	cQry += " INNER JOIN " +RetSqlName("NP3")+ " NP3 ON NP3.D_E_L_E_T_ <> '*'"
	cQry += " AND NP3.NP3_CODIGO = ADB.ADB_CULTRA"
	cQry += " INNER JOIN " +RetSqlName("NP4")+ " NP4 ON NP4.D_E_L_E_T_ <> '*'"
	cQry += " AND NP4.NP4_CODIGO = ADB.ADB_CTVAR"
	cQry += " INNER JOIN " +RetSqlName("SA3")+ " SA3 ON SA3.D_E_L_E_T_ <> '*'"
	cQry += " AND SA3.A3_COD = ADA.ADA_VEND1"
	cQry += " WHERE ADA.ADA_CODSAF  >= '"+MV_PAR01+"' AND ADA.ADA_CODSAF  <= '"+MV_PAR02+"' AND ADA.ADA_STATUS < 'D'"
	cQry += " AND ADB.ADB_CODPRO >= '"+MV_PAR03+"' AND ADB.ADB_CODPRO <= '"+MV_PAR04+"'"
	cQry += " AND ADB.ADB_CULTRA >= '"+MV_PAR05+"' AND ADB.ADB_CULTRA <= '"+MV_PAR06+"'"
	cQry += " AND ADB.ADB_CTVAR  >= '"+MV_PAR07+"' AND ADB.ADB_CTVAR  <= '"+MV_PAR08+"'" 
	cQry += " AND ADB.ADB_PENE   >= '"+MV_PAR09+"' AND ADB.ADB_PENE   <= '"+MV_PAR10+"'" 
	cQry += " AND ADB.ADB_CATEG  >= '"+MV_PAR11+"' AND ADB.ADB_CATEG  <= '"+MV_PAR12+"'"   
	cQry += " AND ADA.D_E_L_E_T_ <> '*'"
	cQry += " Order by ADA.ADA_TPFRET,SA1.A1_CEP,ADA.ADA_CODCLI,ADB.ADB_CODPRO,ADB.ADB_CULTRA,ADB.ADB_CTVAR,ADB.ADB_PENE,ADB.ADB_CATEG	
	cQry := ChangeQuery(cQry)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cAliasQ,.F.,.T.)


	Count To nRecCount //--<< Qtd. Regs. na Query >>--
	procregua(nreccount)


	aQtLoteExpe := {}

	ARGSETIFARQUI(cAliasQ)
	While !Eof()

		IF lEnd
			Exit
		EndIF

		Incproc("Aguarde Selecionando Registros...") 

		Store 0 To nQENT,nQEMP,nQVEND,nSaldo

		cAlias := GetNextAlias()

		cQry := " SELECT SUM(SC6.C6_QTDENT) QENT"
		cQry += " FROM " +RetSqlName("SC6")+" SC6 "
		cQry += " WHERE SC6.C6_FILIAL = '"+(cAliasQ)->ADA_FILIAL+"'"
		cQry += " AND SC6.C6_CONTRAT = '"+(cAliasQ)->ADA_NUMCTR+"' "
		cQry += " AND SC6.C6_ITEMCON = '"+(cAliasQ)->ADB_ITEM+"' "
		cQry += " AND SC6.C6_LOCAL <> ''"
		cQry += " AND SC6.D_E_L_E_T_ <> '*'  "
		cQry += " GROUP BY SC6.C6_CONTRAT  "
		cQry := ChangeQuery(cQry)

		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cAlias,.F.,.T.)
		(cAlias)->(dbGotop())
		While (cAlias)->(!Eof())
			nQENT += (cAlias)->QENT
			DbSelectArea(cAlias)
			DbSkip()
		End
		(cAlias)->(dbCloseArea())

		cAlias := GetNextAlias()

		cQry := " SELECT NP9.NP9_PROD,NP9.NP9_LOTE,NP9_STATUS"
		cQry += " FROM " +RetSqlName("NP9")+" NP9 "
		cQry += " WHERE NP9.NP9_FILIAL = '"+(cAliasQ)->ADA_FILIAL+"'"
		cQry += " AND NP9.NP9_PROD = '"+(cAliasQ)->ADB_CODPRO+"' "
		cQry += " AND NP9.NP9_CODSAF = '"+(cAliasQ)->ADA_CODSAF+"' "
		cQry +=   if (!Empty(AllTrim((cAliasQ)->ADB_CULTRA)), " AND NP9.NP9_CULTRA = '"+(cAliasQ)->ADB_CULTRA+"'","")
		cQry +=   if (!Empty(AllTrim((cAliasQ)->ADB_CATEG)), " AND NP9.NP9_CATEG = '"+(cAliasQ)->ADB_CATEG+"'","")
		cQry +=   if (!Empty(AllTrim((cAliasQ)->ADB_PENE)), " AND NP9.NP9_PENE = '"+(cAliasQ)->ADB_PENE+"'","")
		cQry +=   if (!Empty(AllTrim((cAliasQ)->ADB_CTVAR)), " AND NP9.NP9_CTVAR = '"+(cAliasQ)->ADB_CTVAR+"'","")
		cQry += " AND NP9.D_E_L_E_T_ <> '*'  "
		cQry += " Order by NP9.NP9_PROD"
		cQry := ChangeQuery(cQry)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cAlias,.F.,.T.)
		cLote := ''
		(cAlias)->(dbGotop())
		While (cAlias)->(!Eof())
			DbSelectArea("SB8")
			DbSetOrder(5)

			If DbSeek( (cAliasQ)->ADA_FILIAL+(cAlias)->NP9_PROD+(cAlias)->NP9_LOTE)
				IF ! (cAlias)->NP9_STATUS == '3'   // Se o Lote Esta Regeitado Eu não Considero
					cLote := (cAlias)->NP9_LOTE
				EndIf

				/*WHILE SB8->(!Eof()) .and. B8_FILIAL = (cAliasQ)->ADA_FILIAL .and. B8_PRODUTO = (cAlias)->NP9_PROD .and. B8_LOTECTL = (cAlias)->NP9_LOTE
				IF ! (cAlias)->NP9_STATUS == '3'   // Se o Lote Esta Regeitado Eu não Considero
				nSaldo += SB8Saldo(.F.,!Empty((cAlias)->NP9_LOTE),NIL,NIL,NIL,NIL,NIL,ddatabase) // TODO Adicionar EmpPrev
				EndIF
				(cAlias)->( DbSkip() )
				EndDO
				*/
			EndIf
			DbSelectArea(cAlias)
			DbSkip()
		End

		(cAlias)->(dbCloseArea())

		AGRGRAVA2T(cAliTRBL,cAliasQ)

		DbselectArea(cAliTRBL)    
		(cAliTRBL)->NP9_LOTE 	:= cLote
		(cAliTRBL)->ADB_QTDEMP 	:= Agr890QExp( (cAliTRBL)->ADA_NUMCTR , (cAliTRBL)->ADB_ITEM ) - nQENT
		(cAliTRBL)->ADB_QTDENT 	:= nQENT 
		////(cAliTRBL)->ENCERRADA	:= IIF( (cAliasQ)->ADA_STATUS == 'E', (cAliTRBL)->ADB_QUANT - (cAliTRBL)->ADB_QTDENT  ,0 )   //Qtd. - Qtd Entregue = qtidade encerrda (qt q nao sera entregue)
		(cAliTRBL)->DEMANDA    	:= (cAliTRBL)->ADB_QUANT - (cAliTRBL)->ADB_QTDENT - (cAliTRBL)->ADB_QTDEMP  
		//	(cAliTRBL)->DISP       	:= nSaldo 
		//	(cAliTRBL)->SALDO      	:= (cAliTRBL)->DISP - (cAliTRBL)->DEMANDA  
		Msunlock(cAliTRBL)
		AGRDBSELSKIP(cAliasQ)  
	End 
	ARGCLOSEAREA(cAliasQ)  
	ARGSETIFARQUI(cAliTRBL)

	//// ajustando o indice
	(cAliTRBL)->(DbSetOrder(3)) // Produto e Lote
	(cAliTRBL)->(DbGotop() )	//Posicionando 1o Registro

	cChave 		:= ""   //Ira Conter Lote e Produto
	nSaldoAtu	:=0     //Ira conter o Saldo Atual (q tem na b8) - as demandas (Cumulativo) 
	// Ex saldo prod 1 lote a = 10 , - demanda 5 do ctrato a, - demanda de 3 contrato b = 2
	While (cAliTRBL)->(!Eof())
		reclock(cAliTRBL,.f. )
		IF ! (cAliTRBL)->( ADB_CODPRO  + NP9_LOTE ) = cChave
			cChave 		:= 	(cAliTRBL)->( ADB_CODPRO + NP9_LOTE  )
			nSaldoAtu	:=	SB8Saldo(.F.,!Empty( (cAliTRBL)->NP9_LOTE ),NIL,NIL,NIL,NIL,NIL,ddatabase) // TODO Adicionar EmpPrev
		EndIF
		
		(cAliTRBL)->DISP       	:= nSaldoAtu
		nSaldoAtu -= (cAliTRBL)->DEMANDA 
		(cAliTRBL)->SALDO      	:= nSaldoAtu

		(cAliTRBL)->( msUnLock())
		(cAliTRBL)->( DbSkip() 	)
	EndDo

Return

/* 
+================================================================================================+
| Função    : AGRC010F12                                                                         |
| Descrição : Nova filtragem da base e alimentação do arquivo temporário (VIA F12)               |
| Autor     : Inácio Luiz Kolling                                                                |
| Data      : 15/10/2014                                                                         |
+================================================================================================+                                                                           |  
*/
static Function AGRC010F12()
	If !Pergunte(cPerg, .T.)
		Return
	EndIf 
	DbSelectArea(cAliTRBL)

	oBrowsX:oFwFilter:CleanFilter(.T.)
	AGRC010PRO()
	ARGSETIFARQUI(cAliTRBL)
Return

/* 
+=================================================================================================+
| Função    : AGRC010DUP                                                                          |
| Descrição : Mostra os detalhes dos itens do contrato e da semente                               |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/10/2014                                                                          |
+=================================================================================================+                                                                           |  
*/
static Function AGRC010DUP()
	AGRA890INC((cAliTRBL)->ADA_NUMCTR)

	DbselectArea(cAliTRBL)    
	(cAliTRBL)->ADB_QTDEMP := Agr890QExp( (cAliTRBL)->ADA_NUMCTR , (cAliTRBL)->ADB_ITEM ) - (cAliTRBL)->ADB_QTDENT
	(cAliTRBL)->DEMANDA    := (cAliTRBL)->ADB_QUANT - ((cAliTRBL)->ADB_QTDENT + (cAliTRBL)->ADB_QTDEMP)  
	(cAliTRBL)->SALDO      := (cAliTRBL)->DISP - (cAliTRBL)->DEMANDA  
	Msunlock(cAliTRBL)
	ARGSETIFARQUI(cAliTRBL)

Return             