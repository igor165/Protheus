#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PVendedor³ Autor ³ Fabio Garbin          ³ Data ³ 23/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho do Vendedor.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Vieira    ³13.09.02³Geracao das bases para versao em Advpl           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PVendedor()

Local aVendedor   := {} // Contem os dados do arquivo de VENDEDORES
Local cFileVend   :="HA3" + cEmpAnt + "0" //(PSALIAS)->P_EMPFI
Local cFileMeta   :="HMT" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI 
Local cFileEmp    :="HEMP"
Local nTotReg     := 0
Local aMetas      := {}
Local aEmp        := {}
Local nRecnoSM0   := SM0->(Recno())
Local i := 0
Local cQuery	:= ""
Local cVendedor := PALMUSER->P_CODVEND
Local cAliasHCT := "HCTDATA"
Local cMetaPer  := GetMv("MV_SFAMTTP",,"1")  //1-Mensal; 2-Semanal; 3-Diario
Local cMetaView:= GetMV("MV_SFAMTVI",, "1") // Grupo(1), Produto(2) ou Ambos(3)
Local lTop      := .T.
Local nAnoAtu   := Year(dDatabase)
Local nMesAtu   := Month(dDatabase)
Local nDayAtu   := Day(dDatabase)
Local cAno      := ""
Local cMes      := ""
Local cDay      := ""
Local nDayIni   := 0
Local cDataIni  := DtoS(dDatabase)
Local cDataFim  := DtoS(dDatabase)

Private cQtdReal  := 0, cVlrReal  := 0

aadd(aEmp,{"EMP_COD"     , "C",  2, 0}) // Codigo da Empresa
aadd(aEmp,{"EMP_FILIAL"  , "C",  2, 0}) // Codigo da Filial
aadd(aEmp,{"EMP_NOME"    , "C", 15, 0}) // Nome
aadd(aEmp,{"EMP_NOMCOM"  , "C", 40, 0}) // Nome Comercial
aadd(aEmp,{"EMP_ENDCOB"  , "C", 30, 0}) // Endereco de Cobranca
aadd(aEmp,{"EMP_BAICOB"  , "C", 20, 0}) // Bairro de Cobranca
aadd(aEmp,{"EMP_CIDCOB"  , "C", 20, 0}) // Cidade de Cobranca
aadd(aEmp,{"EMP_ESTCOB"  , "C",  2, 0}) // Estado de Cobranca
aadd(aEmp,{"EMP_CEPCOB"  , "C",  8, 0}) // CEP de Cobranca
aadd(aEmp,{"EMP_CGC"     , "C", 14, 0}) // CGC da Empresa
aadd(aEmp,{"EMP_INSC"    , "C", 14, 0}) // Inscricao
aadd(aEmp,{"EMP_TEL"     , "C", 14, 0}) // Telefone da Empresa

// Preenche o array com os campos a serem enviados
aadd(aVendedor,{"A3_COD"     , "C",  6, 0}) // Codigo do Vendedor
aadd(aVendedor,{"A3_NREDUZ"  , "C", 15, 0}) // Nome Reduzido do Vendedor
aadd(aVendedor,{"A3_COMIS"   , "N",  5, 2}) // Comissao do Vendedor
aadd(aVendedor,{"A3_SALDO"   , "N", 15, 2}) // Saldo do Vendedor
aadd(aVendedor,{"A3_SENHA"   , "C",  6, 0}) // Senha do Vendedor no Palm Pilot
aadd(aVendedor,{"A3_MSGVEN"  , "C", 60, 0}) // Mensagem da empresa para o vendedor
aadd(aVendedor,{"A3_MSGEMP"  , "C", 60, 0}) // Mensagem do vendedor para a empresa
aadd(aVendedor,{"A3_MSGDIA"  , "C", 60, 0}) // Pensamento do Dia
//aadd(aVendedor,{"A3_FLAG"    , "N",  1, 0}) // Sempre zero
aadd(aVendedor,{"A3_PEDINI"	 , "C",  6, 0}) // Pedido Inicio
aadd(aVendedor,{"A3_PEDFIM"  , "C",  6, 0}) // Pedido Final
aadd(aVendedor,{"A3_CLIINI"  , "C",  6, 0}) // Cliente Inicio
aadd(aVendedor,{"A3_CLIFIM"  , "C",  6, 0}) // Cliente Final
aadd(aVendedor,{"A3_PROXPED" , "C",  6, 0}) // Proximo Pedido
aadd(aVendedor,{"A3_PROXCLI" , "C",  6, 0}) // Proximo Cliente

PAcertaSx3(@aVendedor)

//aadd(aMetas,{"MT_DATA"  , "D", 08, 00})
aadd(aMetas,{"MT_DATA"  , "C", 08, 00})
aadd(aMetas,{"MT_GRUPO" , "C", 06, 00})
aadd(aMetas,{"MT_PROD"  , "C", 15, 00})
aadd(aMetas,{"MT_QTD"   , "N", 10, 02})
aadd(aMetas,{"MT_QTDR"  , "N", 10, 02})
aadd(aMetas,{"MT_VALOR" , "N", 12, 02})
aadd(aMetas,{"MT_VALORR", "N", 12, 02})

ConOut("PALMJOB: Criando arquivo de Vendedor (HA3"+cEmpAnt+"0"+") para " + Trim(PALMUSER->P_USER) + " - " + Time())

PalmCreate(aVendedor,cFileVend ,"HA3")
PalmCreate(aMetas   ,cFileMeta ,"HMT")
PalmCreate(aEmp     ,cFileEmp  ,"HEMP")

dbSelectArea("SA3")
dbSeek(xFilial("SA3")+PALMUSER->P_CODVEND)

If PALMUSER->P_DELDATA = "T"
	RecLock("SA3")
	SA3->A3_PROXPED := StrZero(Val(SA3->A3_PROXPED) + 25,6)
	SA3->(MsUnlock())
EndIf

While !Eof() .and. SA3->A3_FILIAL == xFilial("SA3").And. SA3->A3_COD == cVendedor
	dbSelectArea("HA3")
	RecLock("HA3",.T.)
	For i:=1 to Len(aVendedor)
		If aVendedor[i,1]="A3_SALDO"
			Replace &("HA3->"+aVendedor[i,1]) With 0
		ElseIf aVendedor[i,1]="A3_MSGVEN"
			Replace &("HA3->"+aVendedor[i,1]) With SA3->A3_MENS1
		ElseIf aVendedor[i,1]="A3_MSGEMP"
			Replace &("HA3->"+aVendedor[i,1]) With SA3->A3_MENS2
		Else
		    SX3->( dbSetorder(2) )
		    If SX3->( dbSeek( aVendedor[i,1] ) ) 
 		       Replace &("HA3->"+aVendedor[i,1]) With &("SA3->" + aVendedor[i,1])
 		    //Else 
 		    //    ConOut( "Alerta! Crie o campo " + aVendedor[i,1]+" "+aVendedor[i,2]+"("+ StrZero(aVendedor[i,3],2)+ ") pelo configurador..." )
 		    Endif  
			
		EndIf
	Next
	nTotReg++
	HA3->(MsUnlock())
	dbSelectArea("SA3")
	SA3->( dbSkip() )
EndDo    

dbSelectArea("SM0")
dbSetOrder(1)
If dbSeek(PALMSERV->P_EMPFI)
	RecLock("HEMP", .T.)
	HEMP->EMP_COD     := SM0->M0_CODIGO
	HEMP->EMP_FILIAL  := SM0->M0_CODFIL
	HEMP->EMP_NOME    := SM0->M0_NOME
	HEMP->EMP_NOMCOM  := SM0->M0_NOMECOM
	HEMP->EMP_ENDCOB  := SM0->M0_ENDCOB
	HEMP->EMP_BAICOB  := SM0->M0_BAIRCOB
	HEMP->EMP_CIDCOB  := SM0->M0_CIDCOB
	HEMP->EMP_ESTCOB  := SM0->M0_ESTCOB
	HEMP->EMP_CEPCOB  := SM0->M0_CEPCOB
	HEMP->EMP_CGC     := SM0->M0_CGC
	HEMP->EMP_INSC    := SM0->M0_INSC
	HEMP->EMP_TEL     := SM0->M0_TEL
	HEMP->(MsUnlock())
EndIf

// Definicao do Periodo
If cMetaPer = "1"   /// Mensal
	cMes      := StrZero(nMesAtu,2)
	cAno      := Str(nAnoAtu,4,0)
	cDataIni  := cAno + cMes + "01"
	cDataFim  := cAno + cMes + "31"
ElseIf cMetaPer = "2"  // Semanal
	nDayIni := nDayAtu - (Dow(dDataBase)-1)
	If nDayIni <= 0
		nDayIni := 31 - nDayIni
		nMesAtu := If(nMes1-- = 0, 12, nMes1--)
	EndIf
	cDay     := StrZero(nDayIni,2)
	cMes     := StrZero(nMesAtu,2)
	cAno     := Str(nAnoAtu,4,0)
	cDataIni := cAno + cMes + cDay
	cDataFim := DtoS(StoD(cDataIni) + 7)
ElseIf cMetaPer = "3" /// Diaria
	cDataIni := DtoS(dDatabase)
	cDataFim := cDataIni
EndIf

// Grava as metas       

dbSelectArea("SCT")
dbSetOrder(1)
dbSeek(xFilial("SCT"))
While SCT->( !eof() ) .And. SCT->CT_FILIAL == xFilial("SCT")
	cQtdReal := 0
	cVlrReal := 0


	If SCT->CT_VEND != cVendedor .Or. DtoS(SCT->CT_DATA) < cDataIni .Or. DtoS(SCT->CT_DATA) > cDataFim
		dbSelectArea("SCT")
		SCT->( dbSkip() )
		Loop
	EndIf
	
	#IFDEF TOP 
		lTop := .T.
		cQuery := "SELECT SD2.D2_GRUPO, SD2.D2_COD,  SUM(SD2.D2_QUANT) QTD, SUM(SD2.D2_TOTAL) TOTAL "
		cQuery += "FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SF2") + " SF2 "
		cQuery += "WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND "
		cQuery += "SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND "
		cQuery += "SF2.F2_DOC = SD2.D2_DOC AND "
		cQuery += "SF2.F2_VEND1 = '" + cVendedor + "' AND "

		// Periodo das Metas
		cQuery += "SF2.F2_EMISSAO >= '" + cDataIni + "' AND SF2.F2_EMISSAO <= '" + cDataFim + "' AND "

		If cMetaView = "1"  // Grupo
			cQuery += "SD2.D2_GRUPO = '" + SCT->CT_GRUPO + "' AND "
		ElseIf cMetaView = "2"  // Produto
			cQuery += "SD2.D2_COD = '" + SCT->CT_PRODUTO + "' AND "
		EndIf

        /*
		If !Empty(SCT->CT_PRODUTO)
			cQuery += "SD2.D2_COD = '" + SCT->CT_PRODUTO + "' AND "
		ElseIf !Empty(SCT->CT_GRUPO)
			cQuery += "SD2.D2_GRUPO = '" + SCT->CT_GRUPO + "' AND "
		EndIf
        */    

		//cQuery += "SD2.D2_COD = '" + AllTrim(SCT->CT_PRODUTO) + "' AND "
		cQuery += "SD2.D_E_L_E_T_ <> '*' AND SF2.D_E_L_E_T_ <> '*' "
		cQuery += "GROUP BY D2_GRUPO, D2_COD "
		cQuery += "ORDER BY D2_GRUPO, D2_COD"

		cQuery := ChangeQuery(cQuery)			

		Memowrite("HHMeta.txt", cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasHCT,.T.,.T.)

		If cMetaView = "1"  // Grupo
			While !(cAliasHCT)->(Eof())
				SB1->(dbSeek(xFilial("SB1") + (cAliasHCT)->D2_COD))
				cQtdReal += (cAliasHCT)->QTD * If(SB1->(FieldPos("B1_PBRUTO")) <> 0, SB1->B1_PBRUTO, 1)
				cVlrReal += (cAliasHCT)->TOTAL				
				(cAliasHCT)->(dbSkip())
			EndDo			
		ElseIf cMetaView = "2"  // Produto
			cQtdReal := (cAliasHCT)->QTD
			cVlrReal := (cAliasHCT)->TOTAL
		EndIf

		(cAliasHCT)->(dbCloseArea())			
	#ENDIF
  
	// Tratamento de Unidades de Medida nos valores obtidos do SD2/SF2
	If ((ExistBlock("PLMHMT01")))
		ExecBlock("PLMHMT01",.F.,.F.)
	EndIf

	RecLock("HMT", .T.)       
	HMT->MT_DATA     := cDataIni
	HMT->MT_GRUPO    := SCT->CT_GRUPO
	HMT->MT_PROD     := SCT->CT_PRODUTO
	HMT->MT_QTD      := SCT->CT_QUANT
	HMT->MT_VALOR    := SCT->CT_VALOR
	HMT->MT_QTDR     := cQtdReal
	HMT->MT_VALORR   := cVlrReal
	HMT->(MsUnlock())

	dbSelectArea("SCT")
	SCT->( dbSkip() )
Enddo

HA3->(dbCloseArea()) 
HMT->(dbCloseArea()) 
HEMP->(dbCloseArea()) 
Return

//retorna alias usados pelo servico
User Function PVenTab( )
Return {"SA3","SCT", "SD2", "SF2"}

//retorna nome fisico do arquivo espelho
User Function PVenArq( )          
Local cFileVend :="HA3" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileMeta :="HMT" + Left(PALMSERV->P_EMPFI,2) + "0"
Return { cFileVend,cFileMeta, "HEMP"  }

//retorna indice usado pelo arquivo espelho
User Function PVenInd( )
Return {"A3_COD","MT_DATA+MT_GRUPO+MT_PROD", "EMP_COD+EMP_FILIAL"}



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PRota    ³ Autor ³ Fabio Garbin          ³ Data ³ 23/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho das Rotas.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Vieira    ³13.09.02³Geracao das bases para versao Eadvpl             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PRota()
Local aRoteiro   := {} // Contem os dados do arquivo do Roteiro de Visitas
Local aRota      := {} //Contem os dados do arquivo de Rotas

Local dDataAnt   := Date()

Local nVisAtu    := 0


Local cFileRotas := "HRT"  + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI 
Local cFileRoteiro:="HD7"  + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI 
Local cRota      := ""
Local cVendedor  := PALMUSER->P_CODVEND

// Preenche o array com os campos a serem enviados tabela Rotas
aadd(aRota,{"RT_PERCUR", "C",  6, 0}) // Codigo do Percurso
aadd(aRota,{"RT_ROTA"  , "C",  6, 0}) // Codigo da Rota (Palm)
aadd(aRota,{"RT_DESCR" , "C", 14, 0}) // Descricao da Rota

// Preenche o array com os campos a serem enviados tabela Roteiro

aadd(aRoteiro,{"AD7_PERCUR" , "C", 06, 0}) // Codigo do Percurso
aadd(aRoteiro,{"AD7_ROTA"   , "C", 06, 0}) // Codigo da Rota
aadd(aRoteiro,{"AD7_DESPER" , "C", 40, 0}) // Descricao do Percurso
aadd(aRoteiro,{"AD7_ORDEM"  , "C", 06, 0}) // Codigo da Visita
aadd(aRoteiro,{"AD7_CLI"    , "C", 06, 0}) // Codigo do cliente
aadd(aRoteiro,{"AD7_LOJA"   , "C", 02, 0}) // Loja do cliente
aadd(aRoteiro,{"AD7_DATA"   , "D", 08, 0}) // Data 
aadd(aRoteiro,{"AD7_FLGVIS" , "C", 01, 0}) // Flag de Atendimento
aadd(aRoteiro,{"AD7_OCO"    , "C", 06, 0}) // Ocorrencia
aadd(aRoteiro,{"AD7_DT"     , "D", 08, 0}) // Data da Ocorrencia 
PAcertaSx3(@aRoteiro)

ConOut("PALMJOB: Criando arquivo de Rota ("+cFileRotas+")para " + Trim(PALMUSER->P_USER) + " - " + Time())

// Cria arquivos no Diretorio NEW
PalmCreate(aRota,cFileRotas,"HRT")
PalmCreate(aRoteiro,cFileRoteiro,"HD7")

// Grava Arquivos Temporarios
dDataAnt := AD7->AD7_DATA
nRotaAtu := 1
nVisAtu  := 1
dbSelectArea("AD7")
dbSetOrder(1)
dbSeek(xFilial("AD7")+cVendedor)
While !AD7->(Eof()) .and. AD7->AD7_FILIAL= xFilial("AD7") .and. AD7->AD7_VEND = cVendedor
	If AD7->AD7_DATA <> dDataAnt
		cRota := StrZero(nRotaAtu, 6)
       	dbSelectArea("HRT")
        RecLock("HRT",.T.)
		HRT->RT_PERCUR := cRota
		HRT->RT_ROTA   := cRota
		HRT->RT_DESCR  := Dtoc(dDataAnt)
        HRT->(MsUnlock())
   	    nRotaAtu += 1
   	    nVisAtu  := 1
		dDataAnt := AD7->AD7_DATA
	EndIf
	
	dbSelectArea("SA1")
	dbSeek(xFilial("SA1")+AD7->AD7_CODCLI+AD7->AD7_LOJA)
    dbSelectArea("HD7")
	// Grava Roteiro
	RecLock("HD7",.T.)
	HD7->AD7_ROTA    := StrZero(nRotaAtu,6)
	HD7->AD7_PERCUR  := StrZero(nRotaAtu,6)
	HD7->AD7_DESPER  := ""
	HD7->AD7_ORDEM   := StrZero(nVisAtu,4)
	HD7->AD7_CLI     := AD7->AD7_CODCLI 
	HD7->AD7_LOJA    := AD7->AD7_LOJA
	HD7->AD7_DATA    := AD7->AD7_DATA
	HD7->AD7_FLGVIS  := ""
	HD7->AD7_OCO     := Space(6)
	HD7->AD7_DT      := CtoD("  /  /  ")

	nVisAtu += 1
    HD7->(MsUnlock())

	dbSelectArea("AD7")
	dbSkip()
	If Eof() .Or. AD7->AD7_FILIAL <> xFilial("AD7") .Or. AD7->AD7_VEND <> cVendedor
		cRota := StrZero(nRotaAtu, 6)
		dbSelectArea("HRT")
		RecLock("HRT",.T.)
		HRT->RT_PERCUR:= cRota
		HRT->RT_ROTA  := cRota
		HRT->RT_DESCR := Dtoc(dDataAnt)
		HRT->(MsUnlock())
		nRotaAtu += 1
		nVisAtu  := 1
		dDataAnt := AD7->AD7_DATA
	EndIf
EndDo


HRT->(dbCloseArea())
HD7->(dbCloseArea())

Return

//retorna alias usados pelo servico
User Function PRotTab( )
Return {"AD7","SA1"}

//retorna nome fisico do arquivo espelho
User Function PRotArq( )
Local cFileRotas  :="HRT"  + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI 
Local cFileRoteiro:="HD7"  + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI 
Return {cFileRotas,cFileRoteiro}

//retorna indice usado pelo arquivo espelho
User Function PRotInd( )
//Return {"RT_ROTA","AD7_ROTA+AD7_ORDEM"}
Return {"RT_PERCUR+RT_ROTA","AD7_PERCUR+AD7_ROTA+AD7_ORDEM"}


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PCliente ³ Autor ³ Fabio Garbin          ³ Data ³ 23/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho das Clientes.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Vieira    ³13.09.02³ Geracao de bases da versao Eadvpl               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PCliente()

Local aCliente   := {} // Contem os dados do arquivo de CLIENTES
Local aContato   := {} // Contem os dados do arquivo de CONTATOS
Local aFinanceiro:= {} // Contem os dados do arquivo de FINANCEIRO
Local aConsumo   := {} // Contem os dados do arquivo de CONSUMO
Local aCons      := {}
Local aInv       := {}
Local aTend      := {}
Local i          := 0
Local nCndFix    := 1
Local lOkSA1     := .T. // Retorno do Ponto de Entrada - PLMCLI01
Local lOkSE1     := .T. // Retorno do Ponto de Entrada - PLMFIN01
Local nConProd   := GetMV("MV_PLMPRC",,1)
Local cGeraCons  := GetMV("MV_HHCONS",,"T")
Local cFileCli:="HA1" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  
Local cFileCon:="HU5" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  
Local cFileFin:="HE1" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  
Local cFileCns:="HCN" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  
Local cFileAtm:="HAT" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  
Local cFileInv:="HIN" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  

#IFDEF TOP
	Local cVendedor  := PALMUSER->P_CODVEND
	Local nX
#ELSE                    
    Local nQtdSE1    := 0  // Quantidade Maxima de Duplicatas e 20
    Local cFiltro    := ""
    Local cFiltroSE1 := ""
#ENDIF

Private cAliasSA1  := "SA1"
Private cAliasSE1  := "SE1"
Private cAliasSB1  := "SB1"

ConOut("PALMJOB: Criando arquivo de Clientes para " + Trim(PALMUSER->P_USER) + " - " + Time())

// Preenche o array com os campos do cliente a serem enviados
aadd(aCliente,{"A1_COD"					, "C", 06, 0}) // Codigo do Cliente (Pocket)
aadd(aCliente,{"A1_LOJA"				, "C", 02, 0}) // Loja do Cliente
aadd(aCliente,{"A1_CGC"					, "C", 14, 0}) // CGC/CPF do cliente
aadd(aCliente,{"A1_NOME"				, "C", 40, 0}) // Nome do cliente
aadd(aCliente,{"A1_NREDUZ"				, "C", 20, 0}) // Nome Reduzido do cliente
aadd(aCliente,{"A1_TIPO"				, "C", 01, 0}) // Tipo do cliente
aadd(aCliente,{"A1_END"			   		, "C", 40, 0}) // Endereco do cliente
aadd(aCliente,{"A1_MUN"					, "C", 15, 0}) // Municipio do cliente
aadd(aCliente,{"A1_EST"					, "C", 02, 0}) // Estado do cliente
aadd(aCliente,{"A1_BAIRRO"				, "C", 30, 0}) // Bairro do cliente
aadd(aCliente,{"A1_CEP"					, "C", 08, 0}) // Cod Enderecamento Postal
aadd(aCliente,{"A1_TEL"					, "C", 15, 0}) // Telefone do cliente
aadd(aCliente,{"A1_FAX"					, "C", 15, 0}) // Numero do FAX do cliente
aadd(aCliente,{"A1_INSCR"				, "C", 18, 0}) // Inscricao Estadual
aadd(aCliente,{"A1_INSCRM"				, "C", 18, 0}) // Inscricao Municipal
aadd(aCliente,{"A1_VEND"				, "C", 06, 0}) // Codigo do Vendedor
aadd(aCliente,{"A1_REGIAO"				, "C", 03, 0}) // Regiao do Cliente
aadd(aCliente,{"A1_TRANSP"				, "C", 06, 0}) // Transportadora do Cliente
aadd(aCliente,{"A1_TPFRET"				, "C", 01, 0}) // Frete padrao do Cliente
//aadd(aCliente,{"A1_REGIAO"				, "C", 03, 0}) // Regiao do Cliente
aadd(aCliente,{"A1_COND"				, "C", 03, 0}) // Condicao de Pagamento
aadd(aCliente,{"A1_RISCO"				, "C", 01, 0}) // Grau de Risco do cliente
aadd(aCliente,{"A1_LC"					, "N", 14, 2}) // Limite de Cred.do cliente
aadd(aCliente,{"A1_VENCLC"				, "D", 08, 0}) // Vencimento do Lim. Credit
aadd(aCliente,{"A1_MCOMPRA"				, "N", 17, 2}) // Maior Compra do cliente
aadd(aCliente,{"A1_METR"				, "N", 15, 2}) // M‚d.de atrasos do cliente
aadd(aCliente,{"A1_MSALDO"				, "N", 17, 2}) // Maior Saldo do cliente
aadd(aCliente,{"A1_NROCOM"				, "N", 04, 0}) // Nro de compras do cliente
aadd(aCliente,{"A1_PRICOM"				, "D", 08, 0}) // Data 1a Compra do cliente
aadd(aCliente,{"A1_ULTCOM"				, "D", 08, 0}) // Data da ultima Compra
aadd(aCliente,{"A1_ULTVIS"				, "D", 08, 0}) // Data da ultima Visita
aadd(aCliente,{"A1_NROPAG"				, "N", 04, 0}) // Nro de Pagtos do cliente
aadd(aCliente,{"A1_SALDUP"				, "N", 17, 2}) // Saldo Duplic. do cliente
aadd(aCliente,{"A1_SALPEDL"				, "N", 17, 2}) // LibSaldo Pedidos Liberados
aadd(aCliente,{"A1_ATR"					, "N", 17, 2}) // Valor dos Atrasos
aadd(aCliente,{"A1_VACUM"				, "N", 17, 2}) // Valor Acum. Vendas no Ano
aadd(aCliente,{"A1_SALPED"				, "N", 17, 2}) // Saldo de Pedidos
aadd(aCliente,{"A1_TITPROT"				, "N", 03, 0}) // Titulos Protestados
aadd(aCliente,{"A1_DTULTIT"				, "D", 08, 0}) // Data do Ult. Titulos Dev.
aadd(aCliente,{"A1_CHQDEVO"				, "N", 03, 0}) // Numero de Cheques Devolv.
aadd(aCliente,{"A1_DTULCHQ"				, "D", 08, 0}) // Dt.de Devol. Ult. Cheque
aadd(aCliente,{"A1_MATR"				, "N", 04, 0}) // Maior atraso do cliente
aadd(aCliente,{"A1_MAIDUPL"				, "N", 17, 2}) // Valor da maior Duplicata
aadd(aCliente,{"A1_TABELA"				, "C", 03, 0}) // Tabela de preco padrao do cliente
aadd(aCliente,{"A1_PAGATR"				, "N", 17, 2}) // Pag. feitos com atraso
aadd(aCliente,{"A1_RG"					, "C", 15, 0}) // Cedula de Identidade
aadd(aCliente,{"A1_DTNASC"				, "D", 08, 0}) // Data de Nascimento
aadd(aCliente,{"A1_EMAIL"				, "C", 30, 0}) // E-Mail
aadd(aCliente,{"A1_STATUS"				, "C", 01, 0}) // STATUS, N=Novo A=Alterado P=Procesado
aadd(aCliente,{"A1_FLGVIS"              , "C", 1,0 })  // Flag de Visita
aadd(aCliente,{"A1_OCO"                 , "C", 6,0 })  // 
aadd(aCliente,{"A1_CNDFIX"				, "N", 01, 0}) // Indica se o vendedor poderá alterar a Condicao de Pagamento 0 = Nao Muda 1 = Muda (Palm)
aadd(aCliente,{"A1_FORPAG"              , "C", 6,0 })  // Forma de pagamento padrao do cliente
aadd(aCliente,{"A1_GRPVEN"              , "C", 6,0 })  // Grupo de clientes vendas ( Bops 82671 )

// Acrescentado para o Pronta Entrega
aadd(aCliente,{"A1_GRPTRIB"              , "C", 3,0 })  // Grupo de tributacao 
aadd(aCliente,{"A1_NATUREZ"              , "C",10,0 })  // Natureza 
aadd(aCliente,{"A1_SUFRAMA"              , "C",12,0 })  // Inscrucao da Suframa 
aadd(aCliente,{"A1_CALCSUF"              , "C", 1,0 })  // Se calcula ou nao Suframa 

PAcertaSx3(@aCliente)

aadd(aContato,{"U5_CLIENTE"     		, "C", 06, 0}) // Codigo do Cliente (Pocket)
aadd(aContato,{"U5_LOJA"       	        , "C", 02, 0}) // Loja do Cliente
aadd(aContato,{"U5_CODCON"      		, "C", 06, 0}) // Codigo do Contato
aadd(aContato,{"U5_CONTAT"       		, "C", 30, 0}) // Nome do Contato
aadd(aContato,{"U5_CPF"         	    , "C", 15, 0}) // CPF
aadd(aContato,{"U5_FUNCAO"       		, "C", 06, 0}) // Codigo do Cargo
aadd(aContato,{"U5_FONE"         		, "C", 15, 0}) // Telefone
aadd(aContato,{"U5_CELULAR"             , "C", 15,0}) //  Telefone Celular 
aadd(aContato,{"U5_EMAIL"               ,"C",  30,0}) //  E-mail 
aadd(aContato,{"U5_DTNASC"         		, "D", 08, 0}) // Data de Nascimento
aadd(aContato,{"U5_RG"         	        , "C", 15, 0}) // RG
aadd(aContato,{"U5_STATUS"    	        , "C", 01, 0}) // STATUS, N=Novo A=Alterado P=Procesado

PAcertaSx3(@aContato)

aadd(aFinanceiro,{"E1_CLIENTE"		   	, "C",  06, 0}) // Cliente
aadd(aFinanceiro,{"E1_LOJA"		        , "C",  02, 0}) // Loja
aadd(aFinanceiro,{"E1_TIPO"		        , "C",  03, 0}) // Tipo
aadd(aFinanceiro,{"E1_EMISSAO"		   	, "D",  08, 0}) // Emissao
aadd(aFinanceiro,{"E1_VENCTO"		   	, "D",  08, 0}) // Vencimento
aadd(aFinanceiro,{"E1_SALDO"		   	, "N",  10, 2}) // Valor
aadd(aFinanceiro,{"E1_NUM"		        , "C",  06, 0}) // Num Titulo
aadd(aFinanceiro,{"E1_PARCELA"	        , "C",  01, 0}) // Parcela

   // Acrescentado para o Pronta Entrega
   aadd(aFinanceiro,{"E1_STATUS"	    , "C",  01, 0}) // STATUS se o Titulo foi lancado pelo Palm

PAcertaSx3(@aFinanceiro)
                           
aadd(aConsumo,{"F2_CLIENTE"		    	, "C",  06, 0}) // Codigo do Cliente (Pocket)
aadd(aConsumo,{"F2_LOJA"		        , "C",  02, 0}) // Loja do Cliente (Pocket)
aadd(aConsumo,{"F2_GRUPO"               , "C",  04, 0})  // Grupo 
aadd(aConsumo,{"F2_PROD"		        , "C",  15, 0}) //  Codigo do Produto
aadd(aConsumo,{"F2_ANOANT"	    	    , "N",  14, 2}) // Consumo do Mes no Ano Anterior
aadd(aConsumo,{"F2_MESANT"		    	, "N",  14, 2}) // Consumo Mes Anterior
aadd(aConsumo,{"F2_MESATU"		    	, "N",  14, 2}) // Consumo Mes Atual
aadd(aConsumo,{"F2_ULTQTD"		    	, "N",  14, 2}) // Quantidade da Ultima Compra
aadd(aConsumo,{"F2_DTULT"		    	, "D",   8, 0}) // Data da Ultima Compra
aadd(aConsumo,{"F2_VLULT"		    	, "N",  14, 2}) // Valor da Ultima Compra

//Inventario do Cliente
aadd(aInv,{"IN_CLI"   , "C", 06, 00})
aadd(aInv,{"IN_LOJA"  , "C", 02, 00})
aadd(aInv,{"IN_GRUPO" , "C", 04, 00})
aadd(aInv,{"IN_PROD"  , "C", 15, 00})
aadd(aInv,{"IN_DATA"  , "D", 08, 02})
aadd(aInv,{"IN_QTD"   , "N", 10, 02})
aadd(aInv,{"IN_PRECO" , "N", 12, 02})

// Atendimento
aadd(aTend,{"AT_COD"   ,"C",6, 0})
aadd(aTend,{"AT_DATA"  ,"C",8,0})
aadd(aTend,{"AT_CLI"   ,"C",6,0})
aadd(aTend,{"AT_LOJA"  ,"C",2,0})
aadd(aTend,{"AT_FLGVIS","C",1,0})
aadd(aTend,{"AT_STATUS","C",1,0})
aadd(aTend,{"AT_NUMPED","C",6,0})
aadd(aTend,{"AT_VALPED","N",17,2})
aadd(aTend,{"AT_QTDIT" ,"N",3,0})
aadd(aTend,{"AT_OCO"   ,"C",6,0})

PalmCreate(aCliente   ,cFileCLi,"HA1" ) 
PalmCreate(aContato   ,cFileCon,"HU5" )
PalmCreate(aFinanceiro,cFileFin,"HE1" )

PalmCreate(aConsumo   ,cFileCns,"HCN" )

PalmCreate(aInv       ,cFileInv,"HIN" )
PalmCreate(aTend      ,cFileAtm,"HAT" )

dbSelectArea("SA1")
dbSetOrder(1)

#IFDEF TOP
	lQuery := .T.

	aStruSA1  := SA1->(dbStruct())
	aStruSE1  := SE1->(dbStruct())
	cAliasSA1 := "CLIENTE"
	cAliasSE1 := "FINANC"
	
	// Query para o Arquivo de Cliente
	cQuerySA1 := "SELECT * "
	cQuerySA1 += "FROM "+RetSqlName("SA1")+" SA1 "

	If ((ExistBlock("PLMCLI02")))
		// Ponto de Entrada para incluir tabelas na query
		cQuerySA1 += ExecBlock("PLMCLI02",.F.,.F.)
	EndIf	
	
	cQuerySA1 += "WHERE SA1.A1_FILIAL='" + xFilial("SA1") + "' AND "
	cQuerySA1 += "SA1.A1_VEND = '" + cVendedor + "' AND "
	cQuerySA1 += "SA1.D_E_L_E_T_ = ' ' "

	If ((ExistBlock("PLMCLI01")))
		// Ponto de Entrada para incluir condicoes na query
		cQuerySA1 += ExecBlock("PLMCLI01",.F.,.F.)
	EndIf
	cQuerySA1 += "ORDER BY " + SqlOrder(SA1->(IndexKey()))
	
	cQuerySA1 := ChangeQuery(cQuerySA1)

	Memowrite("HHCliente.txt", cQuerySA1)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySA1),cAliasSA1,.T.,.T.)

	// Seleciona TODOS os Titulos de TODOS os Clientes 
    dbSelectArea("SE1")
    dbSetOrder(2)    
	cQuerySE1 := "SELECT E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_TIPO, E1_EMISSAO, E1_VENCTO, E1_SALDO, E1_NUM, E1_PARCELA, 'P' E1_STATUS"
	cQuerySE1 += "FROM " + RetSqlName("SE1") + " SE1," + RetSqlName("SA1") + " SA1 "
	cQuerySE1 += "WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND " 
	cQuerySE1 += "SA1.A1_VEND = '" + cVendedor + "' AND "
	cQuerySE1 += "SE1.E1_CLIENTE = SA1.A1_COD AND "
	cQuerySE1 += "SE1.E1_LOJA = SA1.A1_LOJA AND "
	cQuerySE1 += "SE1.E1_SALDO > 0 AND "
	cQuerySE1 += "SE1.D_E_L_E_T_ = ' ' "
	// Ponto de Entrada deve retornar complemento da Query
	If ((ExistBlock("PLMFIN01")))
		cQuerySE1 += ExecBlock("PLMFIN01",.F.,.F.)
	EndIf

	cQuerySE1 += "ORDER BY " + SqlOrder(SE1->(IndexKey()))

	cQuerySE1 := ChangeQuery(cQuerySE1)
	
	Memowrite("HHDupli.txt", cQuerySE1)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySE1),cAliasSE1,.T.,.T.)

	For nX := 1 To Len(aStruSA1)
		If aStruSA1[nX][2]<>"C" .And. (cAliasSA1)->(FieldPos(aStruSA1[nX][1])>0)
			TcSetField(cAliasSA1,aStruSA1[nX][1],aStruSA1[nX][2],aStruSA1[nX][3],aStruSA1[nX][4])
	    EndIf
	Next nX

	For nX := 1 To Len(aStruSE1)
		If aStruSE1[nX][2]<>"C" .And. (cAliasSE1)->(FieldPos(aStruSE1[nX][1])>0)
			TcSetField(cAliasSE1,aStruSE1[nX][1],aStruSE1[nX][2],aStruSE1[nX][3],aStruSE1[nX][4])
	    EndIf
	Next nX
    
	// Grava o arquivo HE1 (Titulos Abertos) de Todos os Clientes do Vendedor
	dbSelectArea("HE1")
	Append From (cAliasSE1)	
/*
	dbSelectArea(cAliasSE1)
	dbGoTop()
	nQtdSE1 := 0
	cCliSE1 := (cAliasSE1)->E1_CLIENTE
	cLojSE1 := (cAliasSE1)->E1_LOJA
    While !(cAliasSE1)->(Eof())

		If (cAliasSE1)->E1_CLIENTE = cCliSE1 .And. (cAliasSE1)->E1_LOJA = cLojSE1
			// Limita o Numero Maximo de Titulo por Cliente no Palm. Maximo = 20
    		If nQtdSE1 >= 20
    			(cAliasSE1)->(dbSkip())
    			Loop
	    	EndIf
 		Else
			cCliSE1 := (cAliasSE1)->E1_CLIENTE
			cLojSE1 := (cAliasSE1)->E1_LOJA
			nQtdSE1 := 0			
		EndIf 		

		dbSelectArea("HE1")
		RecLock("HE1",.T.)
    	For i := 1 To Len(aFinanceiro)
    		Replace &(aFinanceiro[i,1]) With &((cAliasSE1) + "->" + aFinanceiro[i,1])
    	Next
    	HE1->(MsUnlock())
    	dbSelectArea(cAliasSE1)
    	dbSkip()
		nQtdSE1 += 1
   	EndDo
*/
	aCons := {}
	// Calcula os Consumos
	If cGeraCons = "T"
		U_PCliConsumo(@aCons,,)
	
		// Grava o Arquivo de Consumo
		For i := 1 To Len(aCons)
			dbSelectArea("HCN")
			RecLock("HCN",.T.)
			HCN->F2_CLIENTE:= aCons[i,2]
			HCN->F2_LOJA   := aCons[i,3]
			HCN->F2_GRUPO  := aCons[i,4]
			HCN->F2_PROD   := aCons[i,5]
			HCN->F2_ANOANT := aCons[i,6]
			HCN->F2_MESANT := aCons[i,7]
			HCN->F2_MESATU := aCons[i,8]		
			HCN->(MsUnlock())
		Next
	EndIf
	

#ELSE  // Quando Nao TOP utiliza-se Filtro
	dbSelectArea(cAliasSA1)
	cFiltro := "A1_VEND = '"+PALMUSER->P_CODVEND+"'"
	// Ponto de Entrada deve retornar complemento do Filtro
	If ((ExistBlock("PLMCLI01")))
		cFiltro += ExecBlock("PLMCLI01",.F.,.F.)
	EndIf
	Set Filter to &cFiltro
	dbSeek(xFilial("SA1"))	
#ENDIF

While !(cAliasSA1)->(Eof()) .And. (cAliasSA1)->A1_FILIAL == xFilial("SA1")

	// *** Grava Arquivo de Cliente
	RecLock("HA1",.T.)			
	For i:=1 to Len(aCliente)
		dbSelectArea("HA1")
    	If aCliente[i,1] = "A1_CONPROD"
   			Replace &("HA1->"+aCliente[i,1]) With nConProd
		ElseIf aCliente[i,1] = "A1_CNDFIX"
			If (cAliasSA1)->(FieldPos("A1_CNDFIX")) <> 0
				nCndFix := If((cAliasSA1)->A1_CNDFIX=="1",0,1)
		  	EndIf
			Replace &("HA1->"+aCliente[i,1]) With nCndFix
		ElseIf aCliente[i,1] = "A1_FORPAG"
			If (cAliasSA1)->(FieldPos("A1_FORPAG")) <> 0
				Replace &("HA1->"+aCliente[i,1]) With (cAliasSA1)->A1_FORPAG
		  	EndIf
		ElseIf aCliente[i,1] = "A1_STATUS"
     		Replace &("HA1->"+aCliente[i,1]) With "P"
		ElseIf aCliente[i,1] = "A1_FLGVIS"
     		Replace &("HA1->"+aCliente[i,1]) With ""
		ElseIf aCliente[i,1] = "A1_OCO"
     		Replace &("HA1->"+aCliente[i,1]) With ""   		
    	Else
			Replace &("HA1->"+aCliente[i,1]) With &((cAliasSA1) + "->" + aCliente[i,1])
		EndIf
	Next
	HA1->(MsUnlock())
	cCliLoj := (cAliasSA1)->A1_COD + (cAliasSA1)->A1_LOJA
	//  *** Grava Arquivo de Contatos Utilizando AC8/SU5 ***
	dbSelectArea("AC8")
	dbSetOrder(2)
	//dbSeek(xFilial("AC8")+xFilial("SA1")+"SA1"+cCliLoj)      
	dbSeek(xFilial("AC8")+"SA1"+xFilial("SA1")+cCliLoj)      
	While xFilial("AC8") = AC8->AC8_FILIAL .And. xFilial("SA1") = AC8->AC8_FILENT .And. AC8->AC8_CODENT = cCliLoj
		dbSelectArea("SU5")
		dbSetOrder(1)
		If !dbSeek(xFilial("SU5")+AC8->AC8_CODCON)
			dbSelectArea("AC8")
			dbSkip()
			Loop
		EndIf
		If SU5->U5_ATIVO == "1" 
 			dbSelectArea("HU5")
 			RecLock("HU5",.T.)
   			For i:=1 to Len(aContato)		
				If aContato[i,1] = "U5_RG"
					Replace &("HU5->"+aContato[i,1]) With ""
                ElseIf aContato[i,1] = "U5_CLIENTE" 					
                    Replace &(aContato[i,1]) With SUBSTR(AC8->AC8_CODENT,1,6)
                ElseIf aContato[i,1] = "U5_LOJA" 					
                    Replace &(aContato[i,1]) With SUBSTR(AC8->AC8_CODENT,7,2)
				ElseIf aContato[i,1] = "U5_CODCON"
                    Replace &(aContato[i,1]) With SU5->U5_CODCONT
				ElseIf aContato[i,1] = "U5_DTNASC" 
					Replace &("HU5->"+aContato[i,1]) With CtoD("  /  /  ")
				ElseIf aContato[i,1] = "U5_TIME"
					Replace &("HU5->"+aContato[i,1]) With ""
				ElseIf aContato[i,1] = "U5_REVISTA"
					Replace &("HU5->"+aContato[i,1]) With ""
				ElseIf aContato[i,1] = "U5_ESP"
					Replace &("HU5->"+aContato[i,1]) With ""
				ElseIf aContato[i,1] = "U5_STATUS"
					Replace &("HU5->"+aContato[i,1]) With "P"
				ElseIf aContato[i,1] = "U5_CLILOJ"
     				Replace &("HU5->"+aContato[i,1]) With cCliLoj
				Else
		   	    	Replace &("HU5->"+aContato[i,1]) With &("SU5->"+aContato[i,1])
				EndIf
			Next
			HU5->(MsUnlock())
		EndIf
		dbSelectArea("AC8")
		dbSkip()
	EndDo

	// Grava Titulos em Aberto
	#IFNDEF TOP
		dbSelectArea(cAliasSE1)
		dbSetOrder(2) 
		cFiltroSE1 := "E1_CLIENTE = '" + SA1->A1_COD + "' .And. E1_LOJA = '" + SA1->A1_LOJA + "' .And. E1_SALDO > 0"
		If ((ExistBlock("PLMFIN01")))
			cFiltroSE1 += ExecBlock("PLMFIN01",.F.,.F.)
		EndIf
		Set Filter To &cFiltroSE1

		dbGoTop()
		nQtdSE1 := 0
	    While !(cAliasSE1)->(Eof())
	
	   		//If nQtdSE1 >= 20
			//	Exit
	    	//EndIf
	
			dbSelectArea("HE1")
			RecLock("HE1",.T.)
	    	For i := 1 To Len(aFinanceiro)
	    		If aFinanceiro[i,1] = "E1_CLILOJ"
		    		Replace &("HE1->"+aFinanceiro[i,1]) With (cAliasSE1)->E1_CLIENTE + (cAliasSE1)->E1_LOJA
				Else
					Replace &("HE1->"+aFinanceiro[i,1]) With &((cAliasSE1) + "->" + aFinanceiro[i,1])
				EndIf
	    	Next
	    	HE1->(MsUnlock())
	    	dbSelectArea(cAliasSE1)
	    	dbSkip()
			nQtdSE1 += 1
	   	EndDo
		aCons := {}
		
			// Calcula os Consumos
			U_PCliConsumo(@aCons, (cAliasSA1)->A1_COD, (cAliasSA1)->A1_LOJA)
			
			// Grava o Arquivo de Consumo
			For i := 1 To Len(aCons)
				dbSelectArea("HCN")
				RecLock("HCN",.T.)
				HCN->F2_CLIENTE  := (cAliasSA1)->A1_COD
				HCN->F2_LOJA     := (cAliasSA1)->A1_LOJA
				HCN->F2_GRUPO    := (cAliasSB1)->B1_GRUPO
				HCN->F2_PROD     := aCons[i,1]
				HCN->F2_ANOANT   := aCons[i,2]
				HCN->F2_MESANT   := aCons[i,3]
				HCN->F2_MESATU   := aCons[i,4]
				HCN->F2_ULTQTD   := aCons[i,5]
				HCN->F2_DTULT    := aCons[i,6]
				HCN->F2_VLULT    := aCons[i,7]
				HCN->(MsUnlock())
			Next
	    

	#ENDIF
	dbSelectArea(cAliasSA1)
	dbSkip()
EndDo
	
If lQuery
	(cAliasSA1)->(dbCloseArea())
	(cAliasSE1)->(dbCloseArea())
EndIf

HA1->(dbCloseArea())
HU5->(dbCloseArea())
HE1->(dbCloseArea())

HCN->(dbCloseArea()) 

HIN->(dbCloseArea()) 
HAT->(dbCloseArea()) 

Return

//retorna alias usados pelo servico
User Function PCliTab( )
Return {"SA1","SU5","SUM","SE1","SF2","SD2","SB1","SA7","AC8"}

//retorna nome fisico do arquivo espelho
User Function PCliArq( )
Local cFileCli:="HA1" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFileCon:="HU5" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFileFin:="HE1" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFileCns:="HCN" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFileInv:="HIN" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFileAtm:="HAT" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  

Return {cFileCli,cFileCon,cFileFin,cFileCns,cFileInv,cFileAtm}

//retorna indice usado pelo arquivo espelho
User Function PCliInd( )
Return {"A1_COD+A1_LOJA","U5_CLIENTE+U5_LOJA+U5_CODCON","E1_CLIENTE+E1_LOJA+E1_NUM+E1_PARCELA+E1_TIPO","F2_CLIENTE+F2_LOJA+F2_GRUPO+F2_PROD","IN_GRUPO+IN_PROD+IN_CLI+IN_LOJA","AT_DATA+AT_FLGVIS+AT_NUMPED"}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PCliConsumo³ Autor ³ Fabio Garbin        ³ Data ³ 21/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Calcula o consumo do Mes no ano anterior, do mes anterior  ³±±
±±³          | no ano corrente e do mes atual, para cada cliente          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PCliente                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCliConsumo(aCons, cCodCli, cCodLoja)

Local dData    := dDatabase
Local cMes     := StrZero(Month(dData),2,0)
Local cMesAnt  := If(Val(cMes)=1, "12", StrZero(Val(cMes) - 1,2,0))
Local cAno     := Str(Year(dData),4,0)
Local cAnoAnt  := Str(Val(cAno) - 1,4,0)
Local cGrpProd := "" 
Local nPos     := 0
Local lQuery   := .F.

#IFDEF TOP
    Local cVendedor:= PALMUSER->P_CODVEND
	Local cQueryAtu:= ""
	//Local cQueryAnt:= ""
	//Local cQueryAno:= ""
	//Local cQueryUlt:= ""
	Local cGetDb   := ""
#ELSE
    Local nInt     := 0

#ENDIF

#IFDEF TOP
	cGetDb   := Upper(TcGetDb())
	lQuery := .T.
    
	aStruSD2 := SD2->(dbStruct())
	
	cAliasATU := "CONS"

	//Verifica se o Indice existe
	If !TcCanOpen(RetSqlName("SD2"), "HHSD2")
		TcSqlExec("CREATE INDEX HHSD2 ON " +  RetSqlName("SD2") + "(D2_FILIAL, D2_CLIENTE, D2_LOJA, D2_EMISSAO, R_E_C_N_O_)")
	EndIf		
	
	If "MSSQL" $ cGetDb
		cQueryAtu := "SELECT SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, Substring(SD2.D2_EMISSAO, 1, 6) EMISSAO, SUM(SD2.D2_QUANT) QTD "
		cQueryAtu += "FROM " + RetSqlName("SD2") + " SD2 (INDEX=HHSD2), " + RetSqlName("SA1") + " SA1 "
		cQueryAtu += "WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
		cQueryAtu += "SA1.A1_VEND = '" + cVendedor + "' AND "
		cQueryAtu += "SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA AND "
		cQueryAtu += "(SD2.D2_EMISSAO BETWEEN '"  + cAno    + cMes    + "01' AND '" + cAno    + cMes    + "31' OR "
		cQueryAtu += "SD2.D2_EMISSAO BETWEEN '"   + cAno    + cMesAnt + "01' AND '" + cAno    + cMesAnt + "31' OR "
		cQueryAtu += "SD2.D2_EMISSAO BETWEEN '"   + cAnoAnt + cMes    + "01' AND '" + cAnoAnt + cMes    + "31') AND "
		cQueryAtu += "SD2.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' "
		cQueryAtu += "GROUP BY SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, Substring(SD2.D2_EMISSAO, 1, 6) "
		cQueryAtu += "ORDER BY SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, Substring(SD2.D2_EMISSAO, 1, 6)"
	ElseIf "ORACLE" $ cGetDb
		cQueryAtu := "SELECT SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, Substr(SD2.D2_EMISSAO, 1, 6) EMISSAO, SUM(SD2.D2_QUANT) QTD "
		cQueryAtu += "FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SA1") + " SA1 "
		cQueryAtu += "WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
		cQueryAtu += "SA1.A1_VEND = '" + cVendedor + "' AND "
		cQueryAtu += "SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA AND "
		cQueryAtu += "(SD2.D2_EMISSAO BETWEEN '"  + cAno    + cMes    + "01' AND '" + cAno    + cMes    + "31' OR "
		cQueryAtu += "SD2.D2_EMISSAO BETWEEN '"   + cAno    + cMesAnt + "01' AND '" + cAno    + cMesAnt + "31' OR "
		cQueryAtu += "SD2.D2_EMISSAO BETWEEN '"   + cAnoAnt + cMes    + "01' AND '" + cAnoAnt + cMes    + "31') AND "
		cQueryAtu += "SD2.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' "
		cQueryAtu += "GROUP BY SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, Substr(SD2.D2_EMISSAO, 1, 6) "
		cQueryAtu += "ORDER BY SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, Substr(SD2.D2_EMISSAO, 1, 6)"	
	Else	
		cQueryAtu := "SELECT SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, SD2.D2_EMISSAO EMISSAO, SUM(SD2.D2_QUANT) QTD "
		cQueryAtu += "FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SA1") + " SA1 "
		cQueryAtu += "WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
		cQueryAtu += "SA1.A1_VEND = '" + cVendedor + "' AND "
		cQueryAtu += "SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA AND "
		cQueryAtu += "(SD2.D2_EMISSAO BETWEEN '"  + cAno    + cMes    + "01' AND '" + cAno    + cMes    + "31' OR "
		cQueryAtu += "SD2.D2_EMISSAO BETWEEN '"   + cAno    + cMesAnt + "01' AND '" + cAno    + cMesAnt + "31' OR "
		cQueryAtu += "SD2.D2_EMISSAO BETWEEN '"   + cAnoAnt + cMes    + "01' AND '" + cAnoAnt + cMes    + "31') AND "
		cQueryAtu += "SD2.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' "
		cQueryAtu += "GROUP BY SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, SD2.D2_EMISSAO "
		cQueryAtu += "ORDER BY SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, SD2.D2_EMISSAO"
	EndIf

	// Consumo do Mes Atual	
	cQueryAtu := ChangeQuery(cQueryAtu)

	Memowrite("HHConsumo.txt", cQueryAtu)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryAtu),cAliasAtu,.T.,.T.)

	// Atualiza o Array aCons com os Dados do Consumo do Mes Corrente
	dbSelectArea(cAliasATU)
	While !(cAliasAtu)->(Eof())
        SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + (cAliasATU)->D2_COD))
		cGrpProd := SB1->B1_GRUPO + SB1->B1_COD
		cCliLoj  := (cAliasATU)->D2_CLIENTE + (cAliasATU)->D2_LOJA
		cKey     := cCliLoj + cGrpProd
		If (cAno + cMes) $ (cAliasATU)->EMISSAO //(cAliasATU)->D2_EMISSAO
			nPosData := 8
		ElseIf (cAno + cMesAnt) $ (cAliasATU)->EMISSAO //(cAliasATU)->D2_EMISSAO
			nPosData := 7
		ElseIf (cAnoAnt + cMes) $ (cAliasATU)->EMISSAO //(cAliasATU)->D2_EMISSAO
			nPosData := 6
		EndIf
		nPos := aScan(aCons, { |x| x[1] == cKey })		
		If nPos = 0
			If nPosData = 6
				aadd(aCons,{cKey, (cAliasATU)->D2_CLIENTE, (cAliasATU)->D2_LOJA, SB1->B1_GRUPO, (cAliasATU)->D2_COD, (cAliasATU)->QTD, 0, 0})
			ElseIf nPosData = 7
				aadd(aCons,{cKey, (cAliasATU)->D2_CLIENTE, (cAliasATU)->D2_LOJA, SB1->B1_GRUPO, (cAliasATU)->D2_COD, 0, (cAliasATU)->QTD, 0})
			ElseIf nPosData = 8
				aadd(aCons,{cKey, (cAliasATU)->D2_CLIENTE, (cAliasATU)->D2_LOJA, SB1->B1_GRUPO, (cAliasATU)->D2_COD, 0, 0, (cAliasATU)->QTD})
			EndIf
		Else			
			aCons[nPos, nPosData] += (cAliasATU)->QTD
		EndIf
		dbSelectArea(cAliasATU)
		dbSkip()
	EndDo

#ELSE
	dbSelectArea("SF2")
	dbSetOrder(2)
	dbSeek(xFilial("SF2") + cCodCli + cCodLoja)
	While !Eof() .And. SF2->F2_CLIENTE = cCodCli .And. SF2->F2_LOJA = cCodLoja
		If DtoS(SF2->F2_EMISSAO) >= cAnoAnt + cMesAnt + "01" .And.;  // Mes do Ano Anterior
		   DtoS(SF2->F2_EMISSAO) <= cAnoAnt + cMesAnt + "31"
		   nInt := 2
		EndIf
		If DtoS(SF2->F2_EMISSAO) >= cAno + cMesAnt + "01" .And.;  // Mes Anterior
		   DtoS(SF2->F2_EMISSAO) <= cAno + cMesAnt + "31"
		   nInt := 3
		EndIf
		If DtoS(SF2->F2_EMISSAO) >= cAno + cMes + "01" .And.;  // Mes Atual
		   DtoS(SF2->F2_EMISSAO) <= DtoS(dData)
		   nInt := 4
		EndIf
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)
		While !SD2->(Eof()) .And. SD2->D2_DOC == SF2->F2_DOC .And. nInt <> 0
	        SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + SD2->D2_COD))
			cCliLoj  := cCodCli + cCodLoja
			cGrpProd := SB1->B1_GRUPO + SB1->B1_COD
			nPos := aScan(aCons, { |x| x[1] == cGrpProd })
			If nPos = 0
				aadd(aCons,{cGrpProd, 0, 0, 0, SD2->D2_QUANT, SD2->D2_EMISSAO, SD2->D2_TOTAL, cCliLoj})
				nPos := aScan(aCons, { |x| x[1] == cGrpProd })
			EndIf
			aCons[nPos,nInt] += SD2->D2_QUANT
			// Verifica a Ultima Compra deste Produto
			If SD2->D2_EMISSAO > aCons[nPos,6]
				aCons[nPos,5] := SD2->D2_QUANT
				aCons[nPos,6] := SD2->D2_EMISSAO
				aCons[nPos,7] := SD2->D2_TOTAL
			EndIf
			dbSelectArea("SD2")	
			dbSkip()
		EndDo
		nInt := 0
		dbSelectArea("SF2")	
		dbSkip()
	EndDo

#ENDIF

If lQuery
	(cAliasATU)->(dbCloseArea())
//	(cAliasANT)->(dbCloseArea())	
//	(cAliasANO)->(dbCloseArea())	
EndIf
Return aCons

User Function xPProduto(lGeneric,cGDir)
Local aProduto    := {} // Contem os dados do arquivo de PRODUTOS
Local aGrupo      := {}
Local aGrps       := {} // Grupos que serao enviados para o Palm
Local aTabPrc     := {}
Local aPrcC       := {} // CABEC DA TABELA
Local aDa0        := {}
Local aEstoque := {}
Local i           := 0
Local nPos        := 0
Local nSaldo      := 0  // Estoque do Produto em todos os Almoxarifados
Local cNumProd    := ""
Local cNumCli     := ""
Local lOkPrd      := .T. // Retorno do Ponto de Entrada
Local lQuery      := .F.
Local nConProd    := GetMv("MV_PLMPRC",,1)
Local cTipProd    := GetMv("MV_PLMTPPR",,"PA")
Local cEst        := ""
Local nPrdPeso := 0
Local cValEst     := GetMv("MV_PLVLEST",,"T")   // T = valor do Estoque, F = Posicao
Local cLocalEst   := GetMv("MV_PLLCEST",,"T")   // T = Todos os Almoxarifados, P = Local Padrao
Local cGeraTab    := GetMv("MV_PLPRECO",,"T") // T = Indica a geracao de tabela de preco padrao F = Desativa a geracao de tabela de preco padrao
Local cTabCli    := GetMv("MV_SFTABCLI",,"T") // T = Indica a geracao de tabela de preco cliente  F = Desativa a geracao de tabela de preco cliente
Local cFileProd   := "HB1" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI
Local cFileGrp    := "HBM" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI
Local cFileTabC   := "HTC" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI
Local cFileTabP   := "HPR" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI
Local cFileEst   := "HB2" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI
Local nX := 1
Local nDa0 := 1
DEFAULT lGeneric := .T.

Private cAliasSB1   := "SB1"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

ConOut("PALMJOB: Criando base generica de Produtos .......... ")

// Preenche o array com os campos a serem enviados
aadd(aProduto,{"B1_GRUPO"            	, "C", 04, 0}) // Grupo de Produto
aadd(aProduto,{"B1_COD"              	, "C", 15, 0}) // Codigo do produto (Pocket)
aadd(aProduto,{"B1_DESC"               	, "C", 30, 0}) // Descricao do produto
aadd(aProduto,{"B1_UM" 	            	, "C", 02, 0}) // Unidade de medida
aadd(aProduto,{"B1_PICM" 	            , "N", 05, 2}) // Aliquota de ICMS
aadd(aProduto,{"B1_IPI" 	            , "N", 05, 2}) // Aliquota de IPI
aadd(aProduto,{"B1_ALIQISS"            	, "N", 05, 2}) // Aliquota de ISS
aadd(aProduto,{"B1_QE"					, "N", 09, 0}) // Quantidade por embalagem
aadd(aProduto,{"B1_PE"					, "N", 05, 0}) // Prazo de entrega
aadd(aProduto,{"B1_COMIS"				, "N", 05, 2}) // Percentual de comissao
aadd(aProduto,{"B1_CODBAR"             	, "C", 15, 0}) // Codigo de barra
aadd(aProduto,{"B1_LOCPAD"              , "C", 02, 0}) // Local Padrao do produto
aadd(aProduto,{"B1_EST"                 , "C", 40, 0}) // Estoque do Produto na geracao 
aadd(aProduto,{"B1_TS"                  , "C" ,03, 0 }) // Tipo de saida padrao
aadd(aProduto,{"B1_PRV1"                , "N" ,15, 2 }) // Preco base do produto
aadd(aProduto,{"B1_DESCMAX"             , "N" ,06, 2 }) // Desconto Maximo para o produto (especifico)
aadd(aProduto,{"B1_SEGUM"               , "C" ,02,0 }) // Segunda Unidade de Medida
aadd(aProduto,{"B1_PBRUTO"              , "N" ,11,4 }) // Peso Bruto do Produto (especifico)
aadd(aProduto,{"B1_TIPCONV"             , "C" ,1,0 }) // Tipo de Conversao
aadd(aProduto,{"B1_CONV"                , "N" ,7,2 }) // Fator de conversao

// Acrescentado para o Pronta Entrega
aadd(aProduto,{"B1_GRTRIB"            	, "C", 03, 0}) // Grupo de Tributacao
aadd(aProduto,{"B1_VLR_ICM"            	, "N", 14, 2}) // Icms de Pauta
aadd(aProduto,{"B1_VLR_IPI"            	, "N", 14, 2}) // IPI de Pauta

// Arquivo de Grupos
aadd(aGrupo,{"BM_GRUPO"       , "C", Len(SBM->BM_GRUPO),0})
aadd(aGrupo,{"BM_DESC"        , "C", Len(SBM->BM_DESC),0}) 

PAcertaSx3(@aGrupo)
                               
// Cabec da Tabela preco
aadd(aPrcC,{"TC_TAB"    , "C", 03, 0})
aadd(aPrcC,{"TC_DESCRI" , "C", 30, 0})
aadd(aPrcC,{"TC_COND"   , "C", 03, 0})

aadd(aTabPrc,{"PR_GRUPO"      , "C", 4, 0})  // Grupo 
aadd(aTabPrc,{"PR_PROD"       , "C",15, 0})  // Codigo do Produto 
aadd(aTabPrc,{"PR_TAB"        , "C", 3, 0})  // Codigo da Tabela 
aadd(aTabPrc,{"PR_UNI"        , "N", 15,2})  // Preco Unitario
aadd(aTabPrc,{"PR_DESMAX"    , "N", 6,2})  // Desconto Maximo
aadd(aTabPrc,{"PR_QTDLOT"     , "N", 9,2})  // Faixa para o preco 

aadd(aEstoque,{"HB2_COD"    , "C", 15,0})  // Codigo do Produto
aadd(aEstoque,{"HB2_LOCAL"    , "C", 02,0})  // Almoxarifado
aadd(aEstoque,{"HB2_DATA"    , "D", 08,0})  // Data
aadd(aEstoque,{"HB2_QTD"    , "N", 12,2})  // Data

//If PalmLock(PALMUSER->P_SERIE) = "0"
ConOut("PALMJOB: Criando arquivo de Produtos para " + Trim(PALMUSER->P_USER) + " - " + Time())
PalmCreate(aProduto,cFileProd,"HB1",lGeneric,cGDir) 
PalmCreate(aGrupo  ,cFileGrp ,"HBM",lGeneric,cGDir)
PalmCreate(aTabPrc ,cFileTabP,"HPR",lGeneric,cGDir)
PalmCreate(aPrcC   ,cFileTabC,"HTC",lGeneric,cGDir)
PalmCreate(aEstoque   ,cFileEst,"HB2",lGeneric,cGDir)

#IFDEF TOP
	lQuery := .T.

	aStruSB1  := SB1->(dbStruct())
	cAliasSB1 := "PROD"
	
    // Monta a Lista de Tipos de Produto para a Query
	cLista   := "'"
	cTipProd := AllTrim(cTipProd) + ","
	nPos     := At(",", cTipProd)
	While nPos > 0
		cLista   += Substr(cTipProd, 1, nPos - 1) + "','"
		cTipProd := Substr(cTipProd, nPos + 1, Len(cTipProd))
		nPos := At(",", cTipProd)
	End
    cLista := Subs(cLista, 1, Len(cLista)-2)
    
	// Query para o Arquivo de Produtos
	cQuerySB1 := "SELECT * "
	cQuerySB1 += "FROM "+RetSqlName("SB1")+" SB1 "
	cQuerySB1 += "WHERE SB1.B1_FILIAL='" + xFilial("SB1") + "' AND "
	cQuerySB1 += "SB1.B1_TIPO IN (" + cLista + ") AND "
	cQuerySB1 += "SB1.D_E_L_E_T_ = ' ' "

	// Ponto de Entrada deve retornar um complemento para a Query
	If ((ExistBlock("PLMPRD01")))
		cQuerySB1 += ExecBlock("PLMPRD01",.F.,.F.)
	EndIf

	cQuerySB1 += "ORDER BY " + SqlOrder(SB1->(IndexKey()))
	
	cQuerySB1 := ChangeQuery(cQuerySB1)

	Memowrite("HHProd.txt", cQuerySB1)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySB1),cAliasSB1,.T.,.T.)

	For nX := 1 To Len(aStruSB1)
		If aStruSB1[nX][2]<>"C" .And. (cAliasSB1)->(FieldPos(aStruSB1[nX][1])>0)
			TcSetField(cAliasSB1,aStruSB1[nX][1],aStruSB1[nX][2],aStruSB1[nX][3],aStruSB1[nX][4])
	    EndIf
	Next nX

	// Grupo
	cAliasGrp := "HHGRP"

	cQuery := "SELECT DISTINCT SBM.BM_GRUPO, SBM.BM_DESC "
	cQuery += "FROM " + RetSqlName("SB1") + " SB1 , " + RetSqlName("SBM") + " SBM "
	cQuery += "WHERE SB1.B1_FILIAL='" + xFilial("SB1") + "' AND "
	cQuery += "SBM.BM_FILIAL='" + xFilial("SBM") + "' AND "		
	cQuery += "SB1.B1_GRUPO = SBM.BM_GRUPO AND "
	cQuery += "SB1.B1_TIPO IN (" + cLista + ") AND "
	cQuery += "SB1.D_E_L_E_T_ = ' ' AND SBM.D_E_L_E_T_ = ' ' "
	
	If ((ExistBlock("PLMPRD01")))
		cQuery += ExecBlock("PLMPRD01",.F.,.F.)
	EndIf
	
	cQuery += "ORDER BY SBM.BM_GRUPO"

	Memowrite("HHGrupo.txt", cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasGrp,.T.,.T.)
	                      
	aStru  := (cAliasGrp)->(dbStruct())
	
	For nX := 1 To Len(aStru)
		If aStru[nX,2]<>"C" .And. (cAliasGrp)->(FieldPos(aStru[nX,1])>0)
			TcSetField(cAliasGrp,aStru[nX,1],aStru[nX,2],aStru[nX,3],aStru[nX,4])
	    EndIf
	Next nX

	dbSelectArea("HBM")
	Append From (cAliasGrp)	
	(cAliasGrp)->(dbCloseArea())
#ELSE
	// Grava Arquivo Temporario
	dbSelectArea(cAliasSB1)
	cFiltro := "B1_TIPO $ '" + cTipProd + "'"
	// Ponto de Entrada deve retornar um complemento para o Filtro
	If ((ExistBlock("PLMPRD01")))
		cFiltro += ExecBlock("PLMPRD01",.F.,.F.)
	EndIf

	Set Filter to &cFiltro
	dbSeek(xFilial("SB1"))
#ENDIF

While !(cAliasSB1)->(Eof()) .And. (cAliasSB1)->B1_FILIAL == xFilial("SB1")
	// Ponto de Entrada PLMPRD02 - Indica se um Produto sera exportado, retorno deve ser .T. ou .F.
	If ((ExistBlock("PLMPRD02")))
		lOkPrd := ExecBlock("PLMPRD02",.F.,.F.)
		If !lOkPrd
			dbSelectArea(cAliasSB1)
		    dbSkip()
		    Loop
		 EndIf
	EndIf
	
	dbSelectArea("HB1")	
	RecLock("HB1",.T.)
 	For i:=1 to Len(aProduto)
		If aProduto[i,1] = "B1_EST"
			nSaldo := 0  // Zera Saldo do Estoque
			dbSelectArea("SB2")
			dbSetOrder(1)			
			// Verifica se o Saldo sera do Local Padrao ou de Todos os os Locais
			If cLocalEst = "T"
				dbSeek(xFilial("SB2")+(cAliasSB1)->B1_COD)
				While !SB2->(Eof()) .And. xFilial("SB2") =  SB2->B2_Filial .And. SB2->B2_COD = (cAliasSB1)->B1_COD
					nSaldo += SaldoSB2()
					dbSkip()
				EndDo
			Else
				dbSeek(xFilial("SB2")+(cAliasSB1)->B1_COD+RetFldProd((cAliasSB1)->B1_COD,"B1_LOCPAD",(cAliasSB1)))
				nSaldo := SaldoSB2()
			EndIf			
			// Verifica se grava o Valor do estoque
			/*
			If cValEst = "T"
				cEst := AllTrim(Str(nSaldo,14,2) + " em " + DtoC(dDatabase))
			Else
				If nSaldo > 0
					cEst := "Disponivel"
				Else
					cEst := "Sem Estoque"
				EndIf
			EndIf
			*/
			RecLock("HB2", .T.)
			HB2->HB2_COD :=  (cAliasSB1)->B1_COD
			HB2->HB2_LOCAL := If(cLocalEst = "T", "",  RetFldProd((cAliasSB1)->B1_COD,"B1_LOCPAD",(cAliasSB1)))
			HB2->HB2_DATA := Date()
			HB2->HB2_QTD := nSaldo
			HB2->(MsUnlock())
			//Replace &("HB1->" + aProduto[i,1]) With cEst
			dbSelectArea((cAliasSB1))
		ElseIf aProduto[i,1] = "B1_DESCMAX"			
		    If SB1->(FieldPos("B1_DESCMAX")) <> 0  // Verifica se existe o campo no SB1
			    Replace &("HB1->" + aProduto[i,1]) With &((cAliasSB1) + "->" + aProduto[i,1])
			Else
				Replace &("HB1->" + aProduto[i,1]) With 100
			EndIf    
		ElseIf aProduto[i,1] = "B1_PBRUTO"			
			If SB1->(FieldPos("B1_PBRUTO")) <> 0  // Verifica se existe o campo no SB1
		    	nPrdPeso := &((cAliasSB1) + "->" + aProduto[i,1])   
			ElseIf SB1->(FieldPos("B1_PESO")) <> 0
				nPrdPeso := &((cAliasSB1) + "->B1_PESO")
			Else
				nPrdPeso := 0
			EndIf	
			Replace &("HB1->" + aProduto[i,1]) With nPrdPeso	
		Else
			If aProduto[i,1] = "B1_LOCPAD"
				Replace &("HB1->" + aProduto[i,1]) With RetFldProd((cAliasSB1)->B1_COD,"B1_LOCPAD",(cAliasSB1))
			ElseIf aProduto[i,1] = "B1_QE"
				Replace &("HB1->" + aProduto[i,1]) With RetFldProd((cAliasSB1)->B1_COD,"B1_QE",(cAliasSB1))
			ElseIf aProduto[i,1] = "B1_PE"
				Replace &("HB1->" + aProduto[i,1]) With RetFldProd((cAliasSB1)->B1_COD,"B1_PE",(cAliasSB1))
			ElseIf aProduto[i,1] = "B1_TS"
				Replace &("HB1->" + aProduto[i,1]) With RetFldProd((cAliasSB1)->B1_COD,"B1_TS",(cAliasSB1))
			Else
				Replace &("HB1->" + aProduto[i,1]) With &((cAliasSB1) + "->" + aProduto[i,1])
			Endif	
		EndIf
	Next
	HB1->(MsUnlock())

    nPos := aScan(aGrps,{|x| x[1]==(cAliasSB1)->B1_GRUPO})
	If nPos = 0
		aAdd(aGrps,{(cAliasSB1)->B1_GRUPO})
	EndIf

 	#IFNDEF TOP
		// Gera Precos do Produto
		If  cGeraTab = "T"
			U_PTabPrc(cAliasSB1, @aDa0)
		Else
			If cTabCli = "T"
				U_PTabCli(cAliasSB1, @aDa0)
			EndIf
		EndIf
	#ENDIF
	    
	dbSelectArea(cAliasSB1)
    (cAliasSB1)->(dbSkip())
EndDo                

#IFNDEF TOP
	dbSelectArea("SBM")
	dbSetOrder(1)
	If SBM->(RecCount()) = 0
		RecLock("HBM",.T.)	
		HBM->BM_GRUPO := "0000"
		HBM->BM_DESC  := "Generico"
		HBM->(MsUnlock())
	EndIf
	SBM->( dbSeek(xFilial()) )
	While SBM->(!Eof()) .And. xFilial() == SBM->BM_FILIAL

	    nPos := aScan(aGrps,{|x| x[1]==SBM->BM_GRUPO})
		If nPos > 0
			dbSelectArea("HBM")
			RecLock("HBM",.T.)	
			For i:=1 To Len(aGrupo)
				Replace &("HBM->"+aGrupo[i,1]) With &("SBM->"+aGrupo[i,1])
			Next
			HBM->(MsUnLock())
		EndIf
		dbSelectArea("SBM")
		SBM->(dbSkip())
	EndDo
	
	// Grava cabecalhos da tabela de Preco
	For nDa0:=1 to Len(aDa0)
	    RecLock("HTC", .T.)
	   	HTC->TC_TAB    := aDa0[nDa0,1]
	    HTC->TC_DESCRI := aDa0[nDa0,2]
	    HTC->TC_COND   := aDa0[nDa0,3]
	    HTC->(MsUnlock())		
	Next
	dbSelectArea("SB1")	
	Set Filter to 
#ELSE
	// Gera Tabela de Preco (TOP)
	If  cGeraTab = "T"
		U_PTabPrc(cAliasSB1, @aDa0)
	Else
			If cTabCli = "T"
				U_PTabCli(cAliasSB1, @aDa0)
			EndIf		
	EndIf
#ENDIF


HB1->(dbCloseArea()) 
HB2->(dbCloseArea())
HBM->(dbCloseArea())
HTC->(dbCloseArea())
HPR->(dbCloseArea())

If lQuery
	(cAliasSB1)->(dbCloseArea())
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PProdCli  º Autor ³Fabio Garbin        º Data ³  28/02/2000 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Geracao o arquivo relacao Produto x Cliente                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cConProd  = Forma de Taramento dos Precos (1=Somente Prod; º±±
±±º          ³ 2=Somente Prod x Cliente; 3=Combinado                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PProduto                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PProdCli(nConProd)

Local aProdCli   := {}
Local aProdClia  := {}
Local aPrecos    := {}
Local cFiltro    := ""
Local i := 1
// Preenche o array com precos de venda
aadd(aPrecos, {0})
aadd(aPrecos, {0})
aadd(aPrecos, {0})
aadd(aPrecos, {0})
aadd(aPrecos, {0})
aadd(aPrecos, {0})
aadd(aPrecos, {0})
aadd(aPrecos, {0})
aadd(aPrecos, {0})
aadd(aPrecos, {0})
aadd(aPrecos, {0})
aadd(aPrecos, {0})

aadd(aProdCli,{"A7_CLIPROD"                	, "C", 25, 0}) // Cod Cliente + Grupo Produto + Cod Produto
aadd(aProdCli,{"A7_CLIENTE"                	, "C", 06, 0}) // Codigo do Cliente  ????
aadd(aProdCli,{"A7_PRODUTO"                	, "C", 15, 0}) // Codigo do Produto  ????
aadd(aProdCli,{"A7_CODCLI"                	, "C", 15, 0}) // Codigo do do Produto no Cliente ????
aadd(aProdCli,{"A7_DESCCLI"                	, "C", 30, 0}) // Descricao
aadd(aProdCli,{"B1_GRUPO"                		, "C", 04, 0}) // Grupo do Produto ????
aadd(aProdCli,{"A7_PRECO01"                	, "N", 16, 2}) // Preco 01
aadd(aProdCli,{"A7_PRECO02"                	, "N", 16, 2}) // Preco 02
aadd(aProdCli,{"A7_PRECO03"                	, "N", 16, 2}) // Preco 03
aadd(aProdCli,{"A7_PRECO04"                	, "N", 16, 2}) // Preco 04
aadd(aProdCli,{"A7_PRECO05"                	, "N", 16, 2}) // Preco 05
aadd(aProdCli,{"A7_PRECO06"                	, "N", 16, 2}) // Preco 06
aadd(aProdCli,{"A7_PRECO07"                	, "N", 16, 2}) // Preco 07
aadd(aProdCli,{"A7_PRECO08"                	, "N", 16, 2}) // Preco 08
aadd(aProdCli,{"A7_PRECO09"                	, "N", 16, 2}) // Preco 09
aadd(aProdCli,{"A7_PRECO10"                	, "N", 16, 2}) // Preco 10
aadd(aProdCli,{"A7_PRECO11"                	, "N", 16, 2}) // Preco 11
aadd(aProdCli,{"A7_PRECO12"                	, "N", 16, 2}) // Preco 12

PAcertaSx3(@aProdCli)

aadd(aProdClia,{"A7_CLIDESC"               	, "C", 36, 0}) // Cod Cliente + Desc Produto
aadd(aProdClia,{"A7_PRODUTO"               	, "C", 15, 0}) // Preco 01 ????
aadd(aProdClia,{"A7_CLIENTE"                , "C", 06, 0}) // Codigo do Cliente
aadd(aProdClia,{"A7_CODCLI"                	, "C", 15, 0}) // Codigo do do Produto no Cliente
aadd(aProdClia,{"B1_GRUPO"                	, "C", 04, 0}) // Grupo do Produto ????
aadd(aProdClia,{"A7_PRECO01"               	, "N", 16, 2}) // Preco 01
aadd(aProdClia,{"A7_PRECO02"               	, "N", 16, 2}) // Preco 02
aadd(aProdClia,{"A7_PRECO03"               	, "N", 16, 2}) // Preco 03
aadd(aProdClia,{"A7_PRECO04"               	, "N", 16, 2}) // Preco 04
aadd(aProdClia,{"A7_PRECO05"               	, "N", 16, 2}) // Preco 05
aadd(aProdClia,{"A7_PRECO06"               	, "N", 16, 2}) // Preco 06
aadd(aProdClia,{"A7_PRECO07"               	, "N", 16, 2}) // Preco 07
aadd(aProdClia,{"A7_PRECO08"               	, "N", 16, 2}) // Preco 08
aadd(aProdClia,{"A7_PRECO09"               	, "N", 16, 2}) // Preco 09
aadd(aProdClia,{"A7_PRECO10"               	, "N", 16, 2}) // Preco 10
aadd(aProdClia,{"A7_PRECO11"               	, "N", 16, 2}) // Preco 11
aadd(aProdClia,{"A7_PRECO12"               	, "N", 16, 2}) // Preco 12

PAcertaSx3(@aProdClia)

// Cria Arquivo Temporario
PalmCreate(aProdCli,"ProdCli","PCL") 
PalmCreate(aProdClia,"ProdClia","PCA")

dbSelectArea("SA1")
cFiltro := "A1_VEND = '"+PALMUSER->P_CODVEND+"'"
Set Filter to &cFiltro
dbSeek(xFilial("SA1"))
dbSelectArea("SA7")
dbGoTop()
While !Eof() .And. SA7->A7_FILIAL = xFilial() .And. nConProd <> 1
	cNumCli := SA7->A7_CLIENTE
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega array com preco do produto.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    aPrecos[1]  := SA7->A7_PRECO01
	aPrecos[2]  := SA7->A7_PRECO02
	aPrecos[3]  := SA7->A7_PRECO03
	aPrecos[4]  := SA7->A7_PRECO04
	aPrecos[5]  := SA7->A7_PRECO05
   	aPrecos[6]  := SA7->A7_PRECO06
   	aPrecos[7]  := SA7->A7_PRECO07
   	aPrecos[8]  := SA7->A7_PRECO08
   	aPrecos[9]  := SA7->A7_PRECO09
   	aPrecos[10] := SA7->A7_PRECO10
   	aPrecos[11] := SA7->A7_PRECO11
   	aPrecos[12] := SA7->A7_PRECO12

   	aSort(aPrecos) // Ordena Precos
	j := 11
    While aPrecos[12] == 0 .and. j <> 0
		aPrecos[12] := aPrecos[j]
		j := j - 1
	EndDo
    If aPrecos[1] == aPrecos[2] .and. aPrecos[2] == aPrecos[3] .and. aPrecos[3] == aPrecos[4] .and. aPrecos[4] == aPrecos[5] .and. aPrecos[5] == aPrecos[6] .and. aPrecos[6] == aPrecos[7];
       .and. aPrecos[7] == aPrecos[8] .and. aPrecos[8] == aPrecos[9] .and. aPrecos[9] == aPrecos[10] .and. aPrecos[10] == aPrecos[11] .and. aPrecos[11] == aPrecos[12]
		For i := 2 to 12
		    aPrecos[i] := 0
		Next
	EndIf
	dbSelectArea("SA1")
	If dbSeek(xFilial("SA1"+cNumCli))
		dbSelectArea("PCL")
 		RecLock("PCL",.T.)
		For i := 1 To Len(aProdCli)	
			If aProdCli[i,1] = "A7_CLIPROD"
				SB1->(dbSeek(xFilial("SB1")+SA7->A7_PRODUTO))
				Replace &(aProdCli[i,1]) With SA7->A7_CLIENTE + SB1->B1_GRUPO + SA7->A7_PRODUTO
			ElseIf aProdCli[i,1] = "A7_DESCCLI"
				Replace &(aProdCli[i,1]) With SA7->A7_DESCCLI
			ElseIf aProdCli[i,1] = "B1_GRUPO"
				Replace &(aProdCli[i,1]) With SB1->B1_GRUPO
			Else
				Replace &(aProdCli[i,1]) With If(i>6,aPrecos[Val(Right(aProdCli[i,1],2))],&("SA7->" + aProdCli[i,1]))
			EndIf
		Next
		PCL->(MsUnlock())

		//Produto x Cliente (Alfa)
		dbSelectArea("PCA")
 		RecLock("PCA",.T.)
		For i := 1 To Len(aProdClia)	
			If aProdClia[i,1] = "A7_CLIDESC"
				SB1->(dbSeek(xFilial("SB1")+SA7->A7_PRODUTO))
				Replace &(aProdClia[i,1]) With SA7->A7_CLIENTE + SB1->B1_GRUPO + SA7->A7_DESCCLI

			ElseIf aProdClia[i,1] = "B1_GRUPO"
				SB1->(dbSeek(xFilial("SB1")+SA7->A7_PRODUTO))
				Replace &(aProdClia[i,1]) With SB1->B1_GRUPO
			Else
				Replace &(aProdClia[i,1]) With If(i>5,aPrecos[Val(Right(aProdClia[i,1],2))],&("SA7->" + aProdClia[i,1]))
			EndIf
		Next
		PCA->(MsUnlock())
	EndIf
	dbSelectArea("SA7")
	dbSkip()
EndDo
PCL->(dbCloseArea())
PCA->(dbCloseArea())
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PTabPrc  º Autor ³ Fabio Garbin       º Data ³  10/04/2001 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Geracao o arquivo de tabelas de precos                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PProduto                                                   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ M.Vieira   ³11.11.01³ Substituicao de macros pela funcao FieldPut()   ³±±
±±|            |        | FieldGet() para ficar mais rapida gravacao      ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PTabPrc(cSB1Alias, aDa0)
Local cQuery   := ""
Local cTipProd := GetMv("MV_PLMTPPR",,"PA")
Local cColunas := 0
//Local nDa0     := 0
Local cGetDb   := ""
Local cDA0Alias:= ""
Local cTabAlias:= ""
Local cLista   := ""
//Local nPosAnt  := 0
Local nX := 1
#IFDEF TOP    
	cGetDb    := Upper(TcGetDb())
	cTabAlias := "HHTABPRC"

	// Monta a Lista para a Query
	/*
	cLista  := "'"
	nPosAnt := 1
	For i := 1 To Len(cTipProd)
		If Subs(cTipProd,i,1) = ","	 .Or. i = Len(cTipProd)
			cLista  += Subs(cTipProd,nPosAnt,2) + If( i<Len(cTipProd),"','","'")
			nPosAnt := i + 1
		EndIf
	Next
	*/
	
	cLista   := "'"
	cTipProd := AllTrim(cTipProd) + ","
	nPos     := At(",", cTipProd)
	While nPos > 0
		cLista   += Substr(cTipProd, 1, nPos - 1) + "','"
		cTipProd := Substr(cTipProd, nPos + 1, Len(cTipProd))
		nPos := At(",", cTipProd)
	End
    cLista := Subs(cLista, 1, Len(cLista)-2)

   	//If "MSSQL" $ cGetDb
	cColunas := "SB1.B1_GRUPO PR_GRUPO, DA1.DA1_CODPRO PR_PROD, DA1.DA1_CODTAB PR_TAB, DA1.DA1_PRCVEN PR_UNI "
	If DA1->(FieldPos("DA1_DESMAX")) != 0
		cColunas += ", DA1.DA1_DESMAX PR_DESMAX "
	EndIf	
	//ElseIf "ORACLE" $ cGetDb
	//	cColunas := "SB1.B1_GRUPO PR_GRUPO, RTRIM(DA1.DA1_CODPRO) PR_PROD, DA1.DA1_CODTAB PR_TAB, DA1.DA1_PRCVEN PR_UNI "
	//Else
	//	cColunas := "SB1.B1_GRUPO PR_GRUPO, DA1.DA1_CODPRO PR_PROD, DA1.DA1_CODTAB PR_TAB, DA1.DA1_PRCVEN PR_UNI "
	//EndIf

	cQuery := "SELECT " + cColunas
	cQuery += "FROM " + RetSqlName("DA0") + " DA0, " + RetSqlName("DA1") + " DA1, " + RetSqlName("SB1") + " SB1 "
	cQuery += "WHERE DA1_CODPRO = SB1.B1_COD "
	cQuery += "AND DA0.DA0_CODTAB = DA1.DA1_CODTAB "
	cQuery += "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_TIPO IN(" + cLista + ") "
	cQuery += "AND DA0.DA0_FILIAL = '" + xFilial("DA0") + "' "	
	cQuery += "AND (DA0.DA0_DATATE = '' OR DA0.DA0_DATATE > '" + DtoS(dDataBase) + "') "
	cQuery += "AND DA0.DA0_ATIVO = '1' "
	cQuery += "AND DA1.DA1_FILIAL = '" + xFilial("DA1") + "' "
	cQuery += "AND DA1.DA1_ATIVO = '1' "
	cQuery += "AND DA0.D_E_L_E_T_ <> '*' " 
	cQuery += "AND DA1.D_E_L_E_T_ <> '*' "
	cQuery += "AND SB1.D_E_L_E_T_ <> '*' "
           
	// Ponto de Entrada (retorna um complemento para a Query)
	If ((ExistBlock("PLMPRD01")))
		cQuery += ExecBlock("PLMPRD01",.F.,.F.)
	EndIf
	cQuery := ChangeQuery(cQuery)

	Memowrite("HHTabPrc.txt", cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabAlias,.T.,.T.)

	aStru  := (cTabAlias)->(dbStruct())
	
	For nX := 1 To Len(aStru)
		If aStru[nX,2]<>"C" .And. (cTabAlias)->(FieldPos(aStru[nX,1])>0)
			TcSetField(cTabAlias,aStru[nX,1],aStru[nX,2],aStru[nX,3],aStru[nX,4])
	    EndIf
	Next nX

	dbSelectArea("HPR")
	Append From (cTabAlias)
	(cTabAlias)->(DbCloseArea())

	// Cabecao da Tabela de Preco  
	cDA0Alias := "HHTABC"
	cQueryDA0 := "SELECT DA0.DA0_CODTAB TC_TAB, DA0.DA0_DESCRI TC_DESCRI, DA0.DA0_CONDPG TC_COND "
	cQueryDA0 += "FROM " +  RetSqlName("DA0") + " DA0 "
	cQueryDA0 += "WHERE DA0.DA0_FILIAL = '" + xFilial("DA0") + "' "	
	cQueryDA0 += "AND (DA0.DA0_DATATE = '' OR DA0.DA0_DATATE > '" + DtoS(dDataBase) + "') "
	cQueryDA0 += "AND DA0.DA0_ATIVO = '1' "
	cQueryDA0 += "AND DA0.D_E_L_E_T_ <> '*' "	
	
	cQueryDA0 := ChangeQuery(cQueryDA0)
	
	// Ponto de Entrada (retorna um complemento para a Query)
	If ((ExistBlock("PLMTAB01")))
		cQueryDA0 += ExecBlock("PLMTAB01",.F.,.F.)
	EndIf
	cQuery := ChangeQuery(cQuery)
	
	Memowrite("HHTab.txt", cQueryDA0)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryDA0),cDA0Alias, .T., .T.)

	dbSelectArea("HTC")
	Append From (cDA0Alias)
	(cDA0Alias)->(DbCloseArea())
	
#ELSE
	dbSelectArea("DA1")
	dbSetOrder(2)
	If dbSeek(xFilial("DA1")+(cSB1Alias)->B1_COD)
		While !DA1->(Eof()) .And. DA1->DA1_CODPRO = (cSB1Alias)->B1_COD
			If DA1->DA1_ATIVO != "1"
				DA1->(dbSkip())
				Loop
			EndIf
			dbSelectArea("DA0")
			dbSetOrder(1)
			If dbSeek(xFilial("DA0")+DA1->DA1_CODTAB)
				If DA0->DA0_ATIVO != "1" .Or. (!Empty(DA0->DA0_DATATE) .And. DA0->DA0_DATATE < dDatabase)
					DA1->(dbSkip())
					Loop
				EndIf
			EndIf
			
			nDa0 := aScan( aDa0, {|x| x[1]==DA0->DA0_CODTAB} ) 
	        If nDa0 == 0
				Aadd( aDA0, { DA0->DA0_CODTAB, DA0->DA0_DESCRI, DA0->DA0_CONDPG  } )
			EndIf
			
			RecLock("HPR", .T.)
			HPR->PR_GRUPO := (cSB1Alias)->B1_GRUPO
			HPR->PR_PROD  := AllTrim(DA1->DA1_CODPRO)
			HPR->PR_TAB   := DA1->DA1_CODTAB
			HPR->PR_UNI   := DA1->DA1_PRCVEN
			HPR->PR_QTDLOT := DA1->DA1_QTDLOT
			If DA1->(FieldPos("DA1_DESMAX")) != 0
				HPR->PR_DESMAX  := DA1->DA1_DESMAX
			EndIf
			HPR->(MsUnlock())		
			dbSelectArea("DA1")
			dbSkip()
		EndDo
	EndIf
#ENDIF
Return

//retorna alias usados pelo servico
User Function PPrdTab( )
Return {"SA1","SA7","SB1","SB5","SBM","DA0","DA1","SB2"}

//retorna nome fisico do arquivo espelho
User Function PPrdArq( )
Local cFilePrd :="HB1" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFileGrp :="HBM" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFileTabP:="HPR" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI    
Local cFileTabC:="HTC" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI    
Local cFileEst :="HB2" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI    
Return {cFilePrd,cFileGrp,cFileTabP,cFileTabC,cFileEst}

//retorna indice usado pelo arquivo espelho
User Function PPrdInd( )
Return {"B1_COD","BM_GRUPO","PR_PROD+PR_TAB","TC_TAB", "HB2_COD+HB2_LOCAL"}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCondicao º Autor ³Fabio Garbin        º Data ³  30/11/2000 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Geracao o arquivo de condicoes de pagamento/TES/Tipo de    º±±
±±º          ³ Movimentacao.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integracao Palm                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PCondicao()
Local aCondicao   := {} // Contem os dados do arquivo de CONDI€åES DE PAGAMENTO
Local aTes        := {} // Contem os dados do arquivo de TES
Local aTab        := {} // Contem os dados do arquivo de TABELA DO USUARIO
Local cTabela     := ""
Local lOkCnd      := .T. // Retorno do Ponto de Entrada - PLMCND01
Local lOkTes      := .T. // Retorno do Ponto de Entrada - PLMTES01
Local i           := 0
Local cFileCnd    := "HE4" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  
Local cFileTes    := "HF4" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  
Local cFileTpg    := "HTP" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  

// Preenche o array com os campos a serem enviados    
aadd(aCondicao,{"E4_COD"				, "C",  3, 0}) // Codigo da Condicao
aadd(aCondicao,{"E4_DESCRI" 			, "C", 15, 0}) // Descricao da Cond. Pagto

   aadd(aCondicao,{"E4_TIPO"    			, "C",  1, 0}) // TIPO DA CONDICAO
   aadd(aCondicao,{"E4_COND" 			    , "C", 40, 0}) // DIAS PARA PAGAMENTO 

aadd(aCondicao,{"CD_INTEL"  			, "N",  1, 0}) // Condicao Inteligente ? (0=Nao, 1=Sim)
aadd(aCondicao,{"CD_TAB" 			    , "C",  3, 0}) // Codigo do Preco para esta condicao
aadd(aCondicao,{"CD_STTAB"  			, "N",  1, 0}) // Utiliza Cod Preco ? (0=Nao, 1=Sim)
aadd(aCondicao,{"CD_DTENT" 			    , "N",  3, 0}) // Dias para a Entrega
aadd(aCondicao,{"CD_STDTENT" 			, "N",  1, 0}) // Utiliza Dt Entrega ? (0=Nao, 1=Sim)
aadd(aCondicao,{"CD_TIPPG" 			    , "C",  2, 0}) // Tipo de Pagamento para esta condicao
aadd(aCondicao,{"CD_STTIPPG" 			, "N",  1, 0}) // Utiliza Tipo Pagamento ? (0=Nao, 1=Sim)
aadd(aCondicao,{"CD_TES" 			    , "C",  3, 0}) // TES para esta condicao
aadd(aCondicao,{"CD_STTES" 			    , "N",  1, 0}) // Utiliza TES ? (0=Nao, 1=Sim)
aadd(aCondicao,{"CD_DESC" 			    , "N",  5, 2}) // Desconto para esta condicao
aadd(aCondicao,{"CD_STDESC"			    , "N",  1, 0}) // Utiliza Desconto ? (0=Nao, 1=Sim)

PAcertaSx3(@aCondicao)

// Preenche o array com os campos a serem enviados TES
aadd(aTes,{"F4_CODIGO"					, "C",  3, 0}) // Codigo do TES
aadd(aTes,{"F4_TEXTO"					, "C", 20, 0}) // Texto do TES

   // Acrescentado para o Pronta Entrega
   aadd(aTes,{"F4_IPI"					, "C", 1, 0}) // 
   aadd(aTes,{"F4_ICM"					, "C", 1, 0}) // 
   aadd(aTes,{"F4_CREDIPI" 	     		, "C", 1, 0}) // 
   aadd(aTes,{"F4_CREDICM" 		    	, "C", 1, 0}) // 
   aadd(aTes,{"F4_DUPLIC"				, "C", 1, 0}) // 
   aadd(aTes,{"F4_ESTOQUE"				, "C", 1, 0}) // 
   aadd(aTes,{"F4_CF"   				, "C", 5, 0}) // 
   aadd(aTes,{"F4_ISS"				    , "C", 1, 0}) // 
   aadd(aTes,{"F4_LFICM"				, "C", 1, 0}) // 
   aadd(aTes,{"F4_STDESC"				, "C", 1, 0}) // 
   aadd(aTes,{"F4_BSICMST"				, "N", 5, 2}) // 
   aadd(aTes,{"F4_BASEISS"				, "N", 5, 2}) // 
   aadd(aTes,{"F4_BASEICM"				, "N", 5, 2}) // 
   aadd(aTes,{"F4_SITTRIB"				, "C", 2, 0}) // 
   aadd(aTes,{"F4_DESPIPI"				, "C", 1, 0}) //    
   aadd(aTes,{"F4_IPIFRET"				, "C", 2, 0}) //    
   aadd(aTes,{"F4_TPIPI"  				, "C", 1, 0}) //    
   aadd(aTes,{"F4_BASEIPI"   			, "N", 5, 2}) //       

PAcertaSx3(@aTes)

// Preenche o array com os campos a serem enviados TABELA DO USUARIO
aadd(aTab,{"X5_CHAVE"					, "C",  6, 0}) // Chave da vtabela
aadd(aTab,{"X5_DESCRI"					, "C", 55, 0}) // Descricao da tabela

ConOut("PALMJOB: Criando arquivo de Condicao para " + Trim(PALMUSER->P_USER))

PalmCreate(aCondicao,cFileCnd,"HE4")  // Arquivo de Condicao de Pagamento
PalmCreate(aTes     ,cFileTes,"HF4")  // Arquivo de TES
PalmCreate(aTab     ,cFileTpg,"HTP")  // Arquivo de Formas de Pagamento (SX5)

_CondAlias := POpenCond()

// Grava Arquivo Temporario de Condi‡oes
dbSelectArea("SE4")
dbSetOrder(1)
//dbGoTop()
SE4->(dbSeek(xFilial("SE4")))
While !Eof() .and. SE4->E4_FILIAL == xFilial("SE4")

	// Ponto de Entrada PLMCND01 - Indica se um Condicao sera exportado, retorno deve ser .T. ou .F.
	If ((ExistBlock("PLMCND01")))
		lOkCnd := ExecBlock("PLMCND01",.F.,.F.)
		If !lOkCnd
			dbSelectArea("SE4")
		    dbSkip()
		    Loop
		 EndIf
	EndIf

	RecLock("HE4",.T.)
	HE4->E4_COD    := SE4->E4_CODIGO
	HE4->E4_DESCRI := SE4->E4_DESCRI
    HE4->E4_TIPO   := SE4->E4_TIPO
    HE4->E4_COND   := SE4->E4_COND

	If PALMCOND->(dbSeek(SE4->E4_CODIGO))
		HE4->CD_INTEL   := 1
		HE4->CD_TAB     := PALMCOND->P_CODPR
		HE4->CD_STTAB   := Val( If(PALMCOND->P_STCODPR="2","0",PALMCOND->P_STCODPR))
		HE4->CD_DTENT   := PALMCOND->P_DTENT
		HE4->CD_STDTENT := Val(If(PALMCOND->P_STDTENT="2","0",PALMCOND->P_STDTENT))
		HE4->CD_TIPPG   := PALMCOND->P_TIPPG
		HE4->CD_STTIPPG := Val(If(PALMCOND->P_STIPPG="2","0",PALMCOND->P_STIPPG))
		HE4->CD_TES     := PALMCOND->P_TES
		HE4->CD_STTES   := Val(If(PALMCOND->P_STTES="2","0",PALMCOND->P_STTES))
		HE4->CD_DESC    := PALMCOND->P_DESC
		HE4->CD_STDESC  := Val(If(PALMCOND->P_STDESC="2","0",PALMCOND->P_STDESC))
	EndIf
   	HE4->(MsUnlock())
   	DbSelectArea("SE4")
    dbSkip()
EndDo

// Grava arquivo Temporario de TES
dbSelectArea("SF4")
dbSetOrder(1)
dbSeek(xFilial()+"501",.T.) // Apenas TES de Saida
While !Eof() .and. SF4->F4_FILIAL == xFilial("SF4") .and. SF4->F4_TIPO="S"

	// Ponto de Entrada PLMCND01 - Indica se um Condicao sera exportado, retorno deve ser .T. ou .F.
	If ((ExistBlock("PLMTES01")))
		lOkTes := ExecBlock("PLMTES01",.F.,.F.)
		If !lOkTes
			dbSelectArea("SF4")
		    dbSkip()
		    Loop
		 EndIf
	EndIf
	
	dbSelectArea("HF4")
	RecLock("HF4",.T.)
	For i:=1 to Len(aTes)
   		Replace &("HF4->"+aTes[i,1]) With &("SF4->" + aTes[i,1])
	Next
   	HF4->(MsUnlock())
    DbSelectArea("SF4")
   	dbSkip()
EndDo

cTabela := "24"  // Tabela Formas de Pagamento
dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial("SX5") + cTabela)
While !Eof() .And. SX5->X5_FILIAL = xFilial() .And. SX5->X5_TABELA = cTabela
   	dbSelectArea("HTP")
   	RecLock("HTP",.T.)
    For i := 1 To Len(aTab)    
   		Replace &("HTP->"+aTab[i,1]) With &("SX5->"+aTab[i,1])
	Next
	HTP->(MsUnlock())
	dbSelectArea("SX5")
	dbSkip()
EndDo

// Fecha as WorkAreas 
HE4->(dbCloseArea())
HF4->(dbCloseArea())
HTP->(dbCloseArea())

PALMCOND->(dbCloseArea()) 

Return

//retorna alias usados pelo servico
User Function PCndTab( )
Return {"SE4","SF4"}

//retorna nome fisico do arquivo espelho
User Function PCndArq( )
Local cFileCnd    := "HE4" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFileTes    := "HF4" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFileTpg    := "HTP" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Return {cFileCnd,cFileTes,cFileTpg}

//retorna indice usado pelo arquivo espelho
User Function PCndInd( )
Return {"E4_COD","F4_CODIGO","X5_CHAVE","AC5_EVENTO"}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PPedido   º Autor ³Fabio Garbin        º Data ³  30/11/2000 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Geracao o arquivo de pedidos                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integracao Palm                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PPedido()
Local aPedidoC    := {} // Contem os dados do arquivo de PEDIDOS (cabe‡alho)
Local aPedidoI    := {} // Contem os dados do arquivo de PEDIDOS (itens)
Local aStatus     := {}
Local aNpos       := {}
Local aInd        := {}
Local cCodCli     := ""
Local cCodPed     := ""
Local j           := 1
Local cVendedor   := PALMUSER->P_CODVEND
Local aQtdPed     := {}
Local nQtdPed     := GetMv("MV_QTPEDPM",,1)  // Quantidade de Pedidos a serem enviados para o Palm
Local nValPed     := 0
Local nValFat     := 0
Local cTesBonif	  := GetMv("MV_BONUSTS",,"502") // TES dos itens de bonificacao
Local lOms        := If(GetMv("MV_HHOMS",,"N")= "S", .T. , .F.)
Local cStatus     := ""
Local cAliasPed   := ""
Local cQuery      := ""
Local cFilePedC   := "HC5" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  
Local cFilePedI   := "HC6" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  
Local cFileNpos   := "HD5" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  
Local cFileInd    := "IND" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  
Local cGetDb      := ""
Local cFiltro     := ""
Local cPercur     := ""
Local cAlias      := ""
Local nX          := 1
Local i           := 1

If Len(cTesBonif) > 3
	cTesBonif := Substr(cTesBonif,2,3)
Endif                                 

// Preenche o array com os campos a serem enviados (cabe‡alho)
aadd(aPedidoC,{"C5_COTAC"	    	, "C",  6, 0}) // Numero do Pedido no Handheld
aadd(aPedidoC,{"C5_CLI"	            , "C",  6, 0}) // Codigo do Cliente + Loja
aadd(aPedidoC,{"C5_LOJA"			, "C",  2, 0}) // Loja do Cliente
aadd(aPedidoC,{"C5_TRANSP"			, "C",  6, 0}) // Codigo da Transportadora
aadd(aPedidoC,{"C5_TIPO"   			, "C",  1, 0}) // Tipo de Pedido
aadd(aPedidoC,{"C5_COND"			, "C",  3, 0}) // Condicao de Pagamento
aadd(aPedidoC,{"C5_VEND1"  			, "C",  6, 0}) // Codigo do Vendedor 1
aadd(aPedidoC,{"C5_MENNOTA"			, "C", 255,0}) // Mensagem para Nota Fiscal
aadd(aPedidoC,{"C5_EMISS"			, "D",  8, 0}) // Data da Emissao
aadd(aPedidoC,{"C5_TAB" 			, "C",  3, 0}) // Codigo da Tabela de Preco
aadd(aPedidoC,{"C5_STATUS"          , "C",  3, 0}) // Status do pedido
aadd(aPedidoC,{"C5_TIPOCLI"			, "C",  1, 0}) // Tipo do Cliente
aadd(aPedidoC,{"C5_ASSINA"          , "C",  5, 0}) // Assinatura do pedido, sempre 0
//aadd(aPedidoC,{"C5_TPPAG"           , "C",  6, 0}) // Tipo de pagamento, tabela do cliente
aadd(aPedidoC,{"C5_TPFRETE"         , "C", 1, 0}) // Tipo de Frete (CIF ou FOB)
aadd(aPedidoC,{"C5_NOTA"            , "C", 10, 0}) // Numero da Nota Fiscal
aadd(aPedidoC,{"C5_SERIE"           , "C",  3, 0}) // Serie da Nota Fiscal
aadd(aPedidoC,{"C5_NUM"             , "C",  6, 0}) // Numero do pedido no AP5
aadd(aPedidoC,{"C5_DUPLI"           , "C",  6, 0}) // Numero da Duplicata
aadd(aPedidoC,{"C5_VALOR"           , "N", 15, 2}) // Valor Total do Pedido
aadd(aPedidoC,{"C5_FAT"             , "N", 15, 2}) // valor Faturado do Pedido
aadd(aPedidoC,{"C5_DTPED"           , "D",  8, 0}) // Data do faturamento ou Data do Bloqueio
aadd(aPedidoC,{"C5_QTDITE"          , "N",  3, 0}) // Quantidade de itens do pedido
aadd(aPedidoC,{"C5_DESCONT"         , "N", 15, 2}) // Valor da Indenizacao
aadd(aPedidoC,{"C5_FORMAPG"         , "C", 06, 0}) // Forma de Pagamento

// Customizacao Condicao Negociada  - 01/02/2005 
aadd(aPedidoC,{"C5_PARC1"         	, "N", 12, 2}) // Valor da Parcela 1 
aadd(aPedidoC,{"C5_DATA1"         	, "D",  8, 0}) // Data da Parcela 1
aadd(aPedidoC,{"C5_PARC2"         	, "N", 12, 2}) // Valor da Parcela 2
aadd(aPedidoC,{"C5_DATA2"         	, "D",  8, 0}) // Data da parcela 2
aadd(aPedidoC,{"C5_PARC3"         	, "N", 12, 2}) // Valor da Parcela 3
aadd(aPedidoC,{"C5_DATA3"         	, "D",  8, 0}) // Data da parcela 3
aadd(aPedidoC,{"C5_PARC4"         	, "N", 12, 2}) // Valor da Parce 4
aadd(aPedidoC,{"C5_DATA4"         	, "D",  8, 0}) // Data da Parcela 4


PAcertaSx3(@aPedidoC)

// Preenche o array com os campos a serem enviados (itens)
aadd(aPedidoI,{"C6_COTAC"		    , "C",  6, 0}) // Numero do Pedido no Handheld
aadd(aPedidoI,{"C6_NUM" 		    , "C",  6, 0}) // Numero do Pedido na Retaguarda
aadd(aPedidoI,{"C6_ITEM"   			, "C",  3, 0}) // Numero do Item no Pedido
aadd(aPedidoI,{"C6_PROD"			, "C", 15, 0}) // Codigo do Produto
aadd(aPedidoI,{"C6_GRUPO"           , "C", 06, 0}) // Grupo do produto
aadd(aPedidoI,{"C6_QTDVEN" 			, "N",  6, 2}) // Quantidade Vendida
aadd(aPedidoI,{"C6_PRCVEN" 			, "N", 15, 2}) // Preco Unitario Liquido
aadd(aPedidoI,{"C6_VALOR"  			, "N", 15, 2}) // Valor Total do Item
aadd(aPedidoI,{"C6_QTDLIB" 			, "N",  9, 2}) // Quantidade Liberada
aadd(aPedidoI,{"C6_ENTREG" 			, "D",  8, 0}) // Data da Entrega
aadd(aPedidoI,{"C6_UM"     			, "C",  2, 0}) // Unidade de Medida Primar.
aadd(aPedidoI,{"C6_TES"    			, "C",  3, 0}) // Tipo de Saida do Item
aadd(aPedidoI,{"C6_LOCAL"  			, "C",  2, 0}) // Almoxarifado
aadd(aPedidoI,{"C6_QTDENT" 			, "N",  9, 2}) // Quantidade Entregue
aadd(aPedidoI,{"C6_DESC"    		, "N", 15, 2}) // Desconto
aadd(aPedidoI,{"C6_ICMS"            , "N", 15, 2}) // Icms
aadd(aPedidoI,{"C6_IPI"             , "N", 15, 2}) // Ipi
aadd(aPedidoI,{"C6_TABELA" 			, "C",  3, 0}) // Codigo da Tabela de Preco
aadd(aPedidoI,{"C6_STATUS" 			, "C",  3, 0}) // Status do Item
aadd(aPedidoI,{"C6_BONIF" 			, "N",  1, 0}) // Controle de item bonificado 

PAcertaSx3(@aPedidoI)

// Mantem o tamanho do camo Item para 3 posicoes
nPos := aScan(aPedidoI,{|x| x[1] = "C6_ITEM"})
aPedidoI[nPos,3] := 3

// Preenche o array com os campos do arquivo de Nao Positivacao
aadd(aNpos,{"AD5_ROTER"  , "C", 10, 0}) // Posicao do Roteiro
aadd(aNpos,{"AD5_CODNPO" , "C", 06, 0}) // Codigo da Nao Positivacao
aadd(aNpos,{"AD5_DTHR"   , "C", 17, 0}) // Data da Nao Positivacao
aadd(aNpos,{"AD5_CODCLI" , "C", 06, 0}) // Codigo do Cliente
aadd(aNpos,{"AD5_LOJA"   , "C", 02, 0}) // Loja do Cliente

PAcertaSx3(@aNPos)

// Preenche o array com os campos do arquivo de Indenizacao
aadd(aInd,{"IND_NUM"			        , "C", 06, 0}) // Numero da Indenizacao
aadd(aInd,{"IND_PEDIDO"			        , "C", 06, 0}) // Numero do Pedido
aadd(aInd,{"IND_VALOR"			        , "N", 10, 2}) // Valor da Indenizacao
aadd(aInd,{"IND_MOTIVO"			        , "C", 03, 0}) // Motivo da Indenizacao
aadd(aInd,{"IND_DATA"			        , "D", 08, 0}) // Data da Indenizacao

ConOut("PALMJOB: Criando arquivo de Pedidos para " + Trim(PALMUSER->P_USER))
PalmCreate(aPedidoC,cFilePedC,"HC5")     // Arquivo de Pedido (Cabecalho)
PalmCreate(aPedidoI,cFilePEdI,"HC6")     // Arquivo de Pedido (Itens)
PalmCreate(aNpos,cFileNpos,"HD5")   // Arquivo de Nao Positivacao
PalmCreate(aInd,cFileInd,"IND")   // Arquivo de Nao Positivacao

// Identifica Ultimos Pedidos do Cliente
If !lOms
	cFiltro := "SA1->A1_FILIAL == '" + xFilial() + "' .AND. SA1->A1_VEND = '" + cVendedor + "'"
	cAlias = "SA1"
Else
	dbSelectArea("DA5")
	dbSetOrder(2)
	If dbSeek(xFilial("DA5") + cVendedor)
		cPercur := DA5->DA5_COD
		cFiltro := "DA7->DA7_FILIAL == '" + xFilial() + "' .AND. DA7->DA7_PERCUR = '" + cPercur + "'"
	EndIf
	cAlias = "DA7"
EndIf
dbSelectArea(cAlias)
Set Filter to &cFiltro
dbGoTop()
While !(cAlias)->(Eof()) .And. nQtdPed > 0
	If !lOms
		cCodCli  := SA1->A1_COD
		cCodLoja := SA1->A1_LOJA
	Else
		cCodCli  := DA7->DA7_CLIENT
		cCodLoja := DA7->DA7_LOJA
	EndIf

	#IFDEF TOP
		cGetDb   := Upper(TcGetDb())

		cAliasPed := "HHSC5"	

		If "MSSQL" $ cGetDb
			cQuery := "SELECT TOP " + Str(nQtdPed,2,0) + " SC5.C5_NUM "
		Else
			cQuery := "SELECT SC5.C5_NUM "
	    EndIf

		cQuery += "FROM " + RetSqlName("SC5") + " SC5 WHERE "

		cQuery += "SC5.C5_FILIAL ='" + xFilial("SC5") + "' AND "
		cQuery += "SC5.C5_CLIENTE ='" + cCodCli +  "' AND "
		cQuery += "SC5.C5_LOJACLI ='" + cCodLoja + "' AND "
		cQuery += "SC5.D_E_L_E_T_ = ' ' "
		
		If "MSSQL" $ cGetDb
			cQuery += "ORDER BY SC5.C5_CLIENTE + SC5.C5_LOJACLI + SC5.C5_EMISSAO " 
			cQuery += " + STR(R_E_C_N_O_) DESC"
		ElseIf "ORACLE" $ cGetDb
			cQuery += "ORDER BY SC5.C5_CLIENTE || SC5.C5_LOJACLI || SC5.C5_EMISSAO " 
			cQuery += " || TO_CHAR(R_E_C_N_O_) DESC"
		ElseIf "DB2" $ cGetDb
			cQuery += "ORDER BY SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_EMISSAO DESC" 
		Else
			cQuery += "DESC"
		EndIf

		Memowrite("HHPed.txt", cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasPed,.T.,.T.)

		aStru  := (cAliasPed)->(dbStruct())
		
		For nX := 1 To Len(aStru)
			If aStru[nX,2]<>"C" .And. (cAliasPed)->(FieldPos(aStru[nX,1])>0)
				TcSetField(cAliasPed,aStru[nX,1],aStru[nX,2],aStru[nX,3],aStru[nX,4])
		    EndIf
		Next nX

		ni := 1
		dbSelectArea(cAliasPed)
		dbGoTop()
		While !(cAliasPed)->(Eof()) .And. ni <= nQtdPed
			aadd(aQtdPed,(cAliasPed)->C5_NUM)	 
			(cAliasPed)->(dbSkip())
			ni += 1
		EndDo
		(cAliasPed)->(dbCloseArea())
	#ELSE
		// Busca os Ultimos pedidos do cliente
		dbSelectArea("SC5")
		dbSetOrder(3) // Filial + Cliente + Num
	    If dbSeek(xFilial("SC5") + cCodCli)
			// Necessario para buscar pedidos de outras lojas, pois o indice nao contem o campo LOJA
			While !SC5->(Eof()) .And. SC5->C5_LOJACLI <> cCodLoja .and. SC5->C5_VEND1 <> cVendedor 
				SC5->(dbSkip())
			EndDo
			// Separa todos os ultimos pedidos do cliente
			While !SC5->(Eof()) .And. SC5->C5_FILIAL == xFilial("SC5") .And. SC5->C5_CLIENTE = cCodCli
				If SC5->C5_VEND1 != cVendedor
					SC5->(dbSkip())
					Loop
				EndIf
				If SC5->C5_LOJACLI = cCodLoja
					If Len(aQtdPed) >= nQtdPed
						aDel(aQtdPed,1)
						aSize(aQtdPed,Len(aQtdPed)-1)
					EndIf		
					aadd(aQtdPed,SC5->C5_NUM)
				EndIf
				SC5->(dbSkip())
			EndDo
	    EndIf
	#ENDIF

	// Grava os Ultimos Pedidos    
	dbSelectArea("SC5")
	dbGoTop()
	While !SC5->(Eof()) .And. j <= Len(aQtdPed)
		dbSelectArea("SC5")
		dbSetOrder(1)	
	//	If (Empty(SC5->C5_LIBEROK) .And. Empty(SC5->C5_NOTA)) .Or. nPos > 0
		If dbSeek(xFilial("SC5") + aQtdPed[j])
	        dbSelectArea("HC5")
	   	    RecLock("HC5",.T.)
	   		For i:=1 to Len(aPedidoc)
	            If aPedidoc[i,1]="C5_COTAC"
	            	Replace &("HC5->" + aPedidoC[i,1]) With If(!Empty(SC5->C5_COTACAO),SC5->C5_COTACAO,SC5->C5_NUM)
	            ElseIf aPedidoc[i,1]="C5_CLI"
					Replace &("HC5->" + aPedidoC[i,1]) With SC5->C5_CLIENTE
				ElseIf aPedidoc[i,1]="C5_LOJA"
					Replace &("HC5->" + aPedidoC[i,1]) With SC5->C5_LOJACLI
				ElseIf aPedidoc[i,1]="C5_COND"
					Replace &("HC5->" + aPedidoC[i,1]) With SC5->C5_CONDPAG
	            ElseIf aPedidoc[i,1]="C5_STATUS"
					dbSelectArea("SC6")
				    dbSetOrder(1)
				    dbSeek(xFilial("SC6")+SC5->C5_NUM)
				    While !SC6->(Eof()) .AND. SC6->C6_NUM = SC5->C5_NUM
						If SC6->C6_QTDENT = SC6->C6_QTDVEN
							nPos := aScan(aStatus,{|x| x[1] = "E"})
							If(nPos = 0, aadd(aStatus, {"E", 1}), aStatus[nPos,2] += 1)
			           	ElseIf SC6->C6_QTDENT != 0 .And. SC6->C6_QTDENT < SC6->C6_QTDVEN
							nPos := aScan(aStatus,{|x| x[1] = "PE"})
							If(nPos = 0, aadd(aStatus, {"PE", 1}), aStatus[nPos,2] += 1)
						Else
						   	dbSelectArea("SC9")
						   	dbSetOrder(1)
						   	If dbSeek(xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM)
								If Empty(C9_BLCRED) .And. Empty(C9_BLEST) //Item Liberado
									nPos := aScan(aStatus,{|x| x[1] = "L"})
									If(nPos = 0, aadd(aStatus, {"L", 1}), aStatus[nPos,2] += 1)					
								ElseIf(!Empty(C9_BLCRED) .And. C9_BLCRED != "10") .And. (!Empty(C9_BLEST) .And. C9_BLEST != "10") //Bloqueado por Estoque e Credito
									nPos := aScan(aStatus,{|x| x[1] = "B"})
									If(nPos = 0, aadd(aStatus, {"B", 1}), aStatus[nPos,2] += 1)
								ElseIf !Empty(C9_BLCRED) .And. C9_BLCRED != "10"  //Bloqueado por Credito
									nPos := aScan(aStatus,{|x| x[1] = "BC"})
									If(nPos = 0, aadd(aStatus, {"BC", 1}), aStatus[nPos,2] += 1)
								ElseIf !Empty(C9_BLEST) .And. C9_BLEST != "10"    //Bloqueado por Estoque
									nPos := aScan(aStatus,{|x| x[1] = "BE"})
									If(nPos = 0, aadd(aStatus, {"BE", 1}), aStatus[nPos,2] += 1)
								EndIf
							Else
					   			If SC6->C6_BLQ = "R"
									nPos := aScan(aStatus,{|x| x[1] = "R"})
									If(nPos = 0, aadd(aStatus, {"R", 1}), aStatus[nPos,2] += 1)
					   			Else
									nPos := aScan(aStatus,{|x| x[1] = "A"})
									If(nPos = 0, aadd(aStatus, {"A", 1}), aStatus[nPos,2] += 1)
					   			EndIf
						   	Endif
				   		EndIf                     
					   	dbSelectArea("SC6")
			   			dbSkip()
		   			EndDo
	 				// Ordena Array de Status pela quantidade
	            	aStatus := aSort(aStatus,,,{|x, y| x[2] > y[2]})          	
	            	         	
	            	If Len(aStatus) > 0
	            		If Len(aStatus) = 1
	            			cStatus := aStatus[1,1]
						Else
							If Left(aStatus[1,1],1) != "P"
								cStatus := "P" + aStatus[1,1]
							Else
								cStatus := aStatus[1,1]
							EndIf
						EndIf            	
					EndIf
	            	Replace &("HC5->" + aPedidoC[i,1]) With cStatus
	            	aStatus := {}
	            	cStatus := ""
				ElseIf aPedidoC[i,1]="C5_EMISS"
					Replace &("HC5->" + aPedidoC[i,1]) With SC5->C5_EMISSAO
				ElseIf aPedidoC[i,1]="C5_TAB"
					Replace &("HC5->" + aPedidoC[i,1]) With SC5->C5_TABELA
	       	    ElseIf aPedidoC[i,1]="C5_ASSINA"
		       	    Replace &("HC5->" + aPedidoC[i,1]) With ""
	            ElseIf aPedidoC[i,1]="C5_TIPOPAG"
	   	            Replace &("HC5->" + aPedidoC[i,1]) With Space(6)
				ElseIf aPedidoC[i,1]="C5_DTPED"
	   	            If !Empty(SC5->C5_NOTA)
	   	            	dbSelectArea("SF2")
	   	            	dbSetOrder(1)
	   	            	dbSeek(xFilial("SF2")+SC5->C5_NOTA)
					    Replace &("HC5->" + aPedidoC[i,1]) With SF2->F2_EMISSAO
					EndIf
				ElseIf aPedidoC[i,1]="C5_DUPLI"
					If !Empty(SC5->C5_NOTA)
	   	            	dbSelectArea("SF2")
	   	            	dbSetOrder(1)
	   	            	dbSeek(xFilial("SF2")+SC5->C5_NOTA)
					    Replace &("HC5->" + aPedidoC[i,1]) With SF2->F2_DUPL
					EndIf								
				ElseIf aPedidoC[i,1]="C5_VALOR"
					nValPed := 0
					dbSelectArea("SC6")
					dbSetOrder(1)
					dbSeek(xFilial("SC6")+SC5->C5_NUM)
					While !Eof() .And. xFilial() = xFilial("SC6") .And. SC6->C6_NUM = SC5->C5_NUM
						nValPed += SC6->C6_VALOR
						SC6->(dbSkip())
					EndDo
					Replace &("HC5->" + aPedidoC[i,1]) With nValPed
				ElseIf aPedidoC[i,1]="C5_FAT"
					nValFat := 0
					dbSelectArea("SD2")
					dbSetOrder(8)
					dbSeek(xFilial("SD2")+SC5->C5_NUM)
					While !Eof() .And. xFilial() = xFilial("SD2") .And. SD2->D2_PEDIDO = SC5->C5_NUM
						nValFat += SD2->D2_TOTAL
						SD2->(dbSkip())
					EndDo
					Replace &("HC5->" + aPedidoC[i,1]) With nValFat
				ElseIf aPedidoC[i,1]="C5_QTDITE"
					Replace &("HC5->" + aPedidoC[i,1]) With 0
	            ElseIf aPedidoC[i,1]="C5_PARC1"
	   	            Replace &("HC5->" + aPedidoC[i,1]) With SC5->C5_PARC1
	            ElseIf aPedidoC[i,1]="C5_DATA1"
	   	            Replace &("HC5->" + aPedidoC[i,1]) With SC5->C5_DATA1
	            ElseIf aPedidoC[i,1]="C5_PARC2"
	   	            Replace &("HC5->" + aPedidoC[i,1]) With SC5->C5_PARC2
	            ElseIf aPedidoC[i,1]="C5_DATA2"
	   	            Replace &("HC5->" + aPedidoC[i,1]) With SC5->C5_DATA2
	            ElseIf aPedidoC[i,1]="C5_PARC3"
	   	            Replace &("HC5->" + aPedidoC[i,1]) With SC5->C5_PARC2
	            ElseIf aPedidoC[i,1]="C5_DATA3"
	   	            Replace &("HC5->" + aPedidoC[i,1]) With SC5->C5_DATA3
	            ElseIf aPedidoC[i,1]="C5_PARC4"
	   	            Replace &("HC5->" + aPedidoC[i,1]) With SC5->C5_PARC4
	            ElseIf aPedidoC[i,1]="C5_DATA4"
	   	            Replace &("HC5->" + aPedidoC[i,1]) With SC5->C5_DATA4
				ElseIf aPedidoC[i,1]="C5_FORMAPG"
					If SC5->(FieldPos("C5_FORMAPG")) <> 0
						Replace &("HC5->" + aPedidoC[i,1]) With &("SC5->"+aPedidoC[i,1])
				  	EndIf		
	       	    Else
	           	    Replace &("HC5->" + aPedidoC[i,1]) With &("SC5->"+aPedidoC[i,1])
	            EndIf
	   	    Next
	       	HC5->(MsUnlock())
	
	   		// Busca os Itens do pedido
		   	cCodPed := SC5->C5_NUM
	    	dbSelectArea("SC6")
			dbSetOrder(1)
		    dbSeek(xFilial("SC6") + cCodPed , .T.)
			While !Eof() .and. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == cCodPed
	           	dbSelectArea("HC6")
	            RecLock("HC6",.T.)
	   	        For i:=1 to Len(aPedidoI)
	       	        If aPedidoI[i,1]="C6_PROD"
						Replace &("HC6->"+aPedidoI[i,1]) With SC6->C6_PRODUTO
	       	        ElseIf aPedidoI[i,1]="C6_BONIF"
	        	        If cTesBonif == SC6->C6_TES
		        	        Replace &("HC6->"+aPedidoI[i,1]) With 1	        	        	
	        	        Else
		        	        Replace &("HC6->"+aPedidoI[i,1]) With 0
		 				Endif
	       	        ElseIf aPedidoI[i,1]="C6_DESC"
	        	        Replace &("HC6->"+aPedidoI[i,1]) With SC6->C6_DESCONT
	       	        ElseIf aPedidoI[i,1]="C6_PRCVEN"
	        	        Replace &("HC6->"+aPedidoI[i,1]) With If(SC6->C6_PRUNIT > 0, SC6->C6_PRUNIT, SC6->C6_PRCVEN)
					ElseIf aPedidoI[i,1]="C6_ICMS"
		                Replace &("HC6->"+aPedidoI[i,1]) With 0
		            ElseIf aPedidoI[i,1]="C6_IPI"
	    	            Replace &("HC6->"+aPedidoI[i,1]) With SC6->C6_IPIDEV
					ElseIf aPedidoI[i,1]="C6_GRUPO"
						dbSelectArea("SB1")
						dbSetOrder(1)
						If dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)
							dbSelectArea("HC6")
							Replace &("HC6->"+aPedidoI[i,1]) With SB1->B1_GRUPO
						EndIf
						dbSelectArea("SC6")
	                ElseIf aPedidoI[i,1]="C6_TABELA"
						dbSelectArea("SC5")
						dbSetOrder(1)
						If dbSeek(xFilial("SC5")+cCodPed)
							dbSelectArea("HC6")
							Replace &("HC6->"+aPedidoI[i,1]) With SC5->C5_TABELA
						EndIf
						dbSelectArea("SC6")	
	                ElseIf aPedidoI[i,1]="C6_COTAC"
						Replace &("HC6->"+aPedidoI[i,1]) With If(!Empty(SC5->C5_COTACAO),SC5->C5_COTACAO,SC5->C5_NUM)
		            ElseIf aPedidoI[i,1]="C6_STATUS"  // Verifica o Status do Item
		 			    If SC6->C6_QTDENT = 0
						   	dbSelectArea("SC9")
						   	dbSetOrder(1)
						   	If dbSeek(xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM, .F.)
								If Empty(C9_BLCRED) .And. Empty(C9_BLEST) //Liberado
									cStatus := "L"
					   		    ElseIf (!Empty(C9_BLCRED) .And. C9_BLCRED <> "10") .And. (!Empty(C9_BLEST) .And. C9_BLEST <> "10") //Bloqueado por Estoque e Credito
							   		cStatus := "B"
						   		ElseIf !Empty(C9_BLCRED) .And. C9_BLCRED <> "10"  //Bloqueado por Credito
						   			cStatus := "BC"
						   		ElseIf !Empty(C9_BLEST) .And. C9_BLEST <> "10" //Bloqueado por Estoque
						   			cStatus := "BE"
					   			EndIf
					   		Else
					   			If SC6->C6_BLQ = "R"
					   				cStatus := "R"
					   			Else
					   				cStatus := "A"
					   			EndIf
					   		EndIf		            	
			           	ElseIf SC6->C6_QTDENT < SC6->C6_QTDVEN
			           		cStatus := "PE"
			           	ElseIf SC6->C6_QTDENT = SC6->C6_QTDVEN
				           	cStatus := "E"
			           	EndIf
	    	        	Replace &("HC6->" + aPedidoI[i,1]) With cStatus
	                Else
	   	            	Replace &("HC6->"+aPedidoI[i,1]) With &("SC6->"+aPedidoI[i,1])
					EndIf
	           	Next
				HC6->(MsUnlock())
	   	     	dbSelectArea("SC6")
	       	 	dbSkip()
		    EndDo
			j := j + 1
		EndIf
	EndDo
	aQtdPed := {}
	j := 1
	(cAlias)->(dbSkip())
EndDo
dbSelectArea(cAlias)
SET FILTER TO

HC5->(dbCloseArea())
HC6->(dbCloseArea())
HD5->(dbCloseArea())
IND->(dbCloseArea())
Return

//retorna alias usados pelo servico
User Function PPedTab( )
Return {"SA1","SC5","SC6","SC9","SB1","SF2","AD5","DA5","DA7"}

//retorna nome fisico do arquivo espelho
User Function PPedArq( )
Local cFilePedC   := "HC5" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFilePedI   := "HC6" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI
Local cFileNpos   := "HD5" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFileInd    := "IND" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Return {cFilePedC,cFilePedI,cFileNpos, cFileInd}

//retorna indice usado pelo arquivo espelho
User Function PPedInd( )
Return {"C5_NUM","C6_NUM+C6_ITEM","AD5_CODCLI+AD5_LOJA+AD5_DTHR", "IND_NUM"}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PTransp  ³ Autor ³ Cleber Martinez       ³ Data ³ 22/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho de Transportadoras                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PTransp()
 
Local aTransp   := {} // Contem os dados do arquivo de TRANSPORTADORAS (SA4)
Local cTransp   :="HA4" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI 
 
cVendedor := PALMUSER->P_CODVEND
 
// Preenche o array com os campos a serem enviados
aadd(aTransp,{"A4_COD"     , "C",  6, 0}) // Codigo da Transp.
aadd(aTransp,{"A4_NOME"    , "C", 40, 0}) // Nome da Transp.
aadd(aTransp,{"A4_FILIAL"  , "C",  2, 0}) // Filial do Sistema
 
//If PalmLock(PALMUSER->P_SERIE) = "0"
ConOut("PALMJOB: Criando arquivo de Transport./Descr. tabelas para " + Trim(PALMUSER->P_USER) + " - " + Time())
//PalmCreate(<estrutura>,<arquivo>,<alias>)
PalmCreate(aTransp,cTransp,"TRA")
                
//Transportadoras
dbSelectArea("SA4")
dbSeek(xFilial("SA4"))
While !SA4->(Eof()) .and. SA4->A4_FILIAL == xFilial("SA4")
	dbSelectArea("TRA")
	RecLock("TRA",.T.)
	TRA->A4_FILIAL := SA4->A4_FILIAL
	TRA->A4_COD    := SA4->A4_COD
	TRA->A4_NOME   := SA4->A4_NOME
	TRA->(MsUnlock())
	dbSelectArea("SA4")
	dbSkip()
EndDo    
 
TRA->(dbCloseArea())
Return
 
//retorna alias usado pelo servico
User Function PTraTab( )
Return {"SA4"}
 
//retorna nome fisico do arquivo espelho
User Function PTraArq( )
Local cFileTransp := "HA4" + Left(PALMSERV->P_EMPFI,2) + "0"
Return {cFileTransp}
 
//retorna indice usado pelo arquivo espelho
User Function PTraInd( )
cKeyTransp := "A4_COD"
Return {cKeyTransp}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PPedGrade³ Autor ³ Fabio Garbin          ³ Data ³ 30/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivos para Utilizacao na Grade de Pedido                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Funcao especifica 
User Function PPedGrade()

Local aLinha    := {}	// Estrutura utilizadas como linhas de Grade
Local aColuna   := {}  // Estrutura utilizadas como colunas de Grade
Local aProdPai  := {}
Local aProdPaia := {}
Local aTabela   := {}  // Array das tabelas utilizadas nas linhas e colunas da grade
Local cMascGrd  := GetMv("MV_MASCGRD")

Local nTamLin   := Val(Subs(cMascGrd,4,2))
Local nTamCol   := Val(Subs(cMascGrd,8,2))
Local i         := 0

//Estrutura do Arquivo Linha
aadd(aLinha,{"TABLIN", "C", 04, 0})
aadd(aLinha,{"CHAVE" , "C", 06, 0})
aadd(aLinha,{"DESC"  , "C", 55, 0})

//Estrutura do Arquivo Coluna
aadd(aColuna,{"TABCOL", "C", 04, 0})
aadd(aColuna,{"CHAVE" , "C", 06, 0})
aadd(aColuna,{"DESC"  , "C", 55, 0})

//Estrutura do Arquivo Produto Pai
aadd(aProdPai,{"GRPCOD", "C", 15, 0})
aadd(aProdPai,{"DESC"  , "C", 60, 0})
aadd(aProdPai,{"LINHA" , "C", 02, 0})
aadd(aProdPai,{"COLUNA", "C", 02, 0})

//Estrutura do Arquivo Produto Pai (Alfa)
aadd(aProdPaia,{"GRPDESC" , "C", 65, 0})
aadd(aProdPaia,{"GRPCOD"  , "C", 15, 0})

ConOut("PALMJOB: Criando arquivo de Pedidos com Grade para " + Trim(PALMUSER->P_USER))
PalmCreate(aLinha   , "Linha"   , "LIN")
PalmCreate(aColuna  , "Coluna"  , "COL")
PalmCreate(aProdPai , "Prodpai" , "PRP")
PalmCreate(aProdPaia, "Prodpaia", "PPA")
    
dbSelectArea("SB4")
dbSetOrder(1)
dbSeek(xFilial())
While !Eof() .And. xFilial() = xFilial("SB4")
   	dbSelectArea("PRP")
   	// Grava Produto Pai
   	RecLock("PRP",.T.)
   	PRP->GRPCOD := If(Empty(SB4->B4_GRUPO),"0000",SB4->B4_GRUPO) + SB4->B4_COD
   	PRP->DESC   := SB4->B4_DESC
   	PRP->LINHA  := SB4->B4_LINHA
   	PRP->COLUNA := SB4->B4_COLUNA
   	PRP->(MsUnlock())
   	
   	// Grava Produto Pai (Alfa)
   	RecLock("PPA",.T.)
   	PPA->GRPDESC := If(Empty(SB4->B4_GRUPO),"0000",SB4->B4_GRUPO) + SB4->B4_DESC
   	PPA->GRPCOD  := If(Empty(SB4->B4_GRUPO),"0000",SB4->B4_GRUPO) + SB4->B4_COD
   	PPA->(MsUnlock())
       
	nPos := aScan(aTabela, SB4->B4_LINHA)
	If nPos = 0
		aadd(aTabela, {SB4->B4_LINHA , "L"})
	EndIf
	nPos := aScan(aTabela, SB4->B4_COLUNA)
	If nPos = 0
		aadd(aTabela, {SB4->B4_COLUNA, "C"})
	EndIf
	
	dbSelectArea("SB4")
	dbSkip()

EndDo 

// Grava as Tabelas	de Linha e Coluna
For i := 1 To Len(aTabela)
   	dbSelectArea("SX5")
   	dbSetOrder(1)
   	If dbSeek(xFilial()+aTabela[i,1])
   		j := 1
   		While !Eof() .And. SX5->X5_TABELA = aTabela[i,1]   	
    		If aTabela[i,2] = "L"
	    		dbSelectArea("LIN")
    			RecLock("LIN",.T.)
   				LIN->TABLIN := SX5->X5_TABELA + StrZero(j,2)
   				LIN->CHAVE  := PadR(SX5->X5_CHAVE, nTamLin)
    			LIN->DESC   := SX5->X5_DESCRI
	    		LIN->(MsUnlock())
	    	Else
   		   		dbSelectArea("COL")
	    		RecLock("COL",.T.)
   				COL->TABCOL := SX5->X5_TABELA + StrZero(j,2)
	    		COL->CHAVE  := PadR(SX5->X5_CHAVE, nTamCol)
   				COL->DESC   := SX5->X5_DESCRI
	    		COL->(MsUnlock())
   			EndIf
   			dbSelectArea("SX5")
   			dbSkip()
   			j := j + 1
   		EndDo
   	EndIf
Next   
LIN->(dbCloseArea())
COL->(dbCloseArea())
PRP->(dbCloseArea())
PPA->(dbCloseArea())    

Return

//retorna alias usados pelo servico
User Function PPgrTab( )
Return {"SB4"}

//retorna nome fisico do arquivo espelho
User Function PPgrArq( )
Return {"Linha","Coluna","ProdPai","ProdPaia"}

//retorna indice usado pelo arquivo espelho
User Function PPgrInd( )
Return {"TABLIN","TABCOL","GRPCOD","GRPDESC"}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PConfig  ³ Autor ³ Fabio Garbin          ³ Data ³ 01/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo de Configuracoes.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Vieira    ³24.09.02³ Conversao para gerar bases para versao Eadvpl   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/*/

User Function PConfig()

Local aCfg     := {} // Estrutura do arquivo de Configuracoes
Local aTab     := {} // 
Local aTiposcli := {}
Local cTitulo  := ""
Local cTipo    := ""
Local nTam     := 0
Local nDec     := 0
Local cMascGrd  := AllTrim(GetMv("MV_MASCGRD"))
Local cTamProd  := Subs(cMascGrd,1,At(",",cMascGrd)-1)
Local cTamLin   := Subs(cMascGrd,At(",",cMascGrd)+1,Rat(",",cMascGrd)-(At(",",cMascGrd)+1))
Local cTamCol   := Subs(cMascGrd,Rat(",",cMascGrd)+1)    
Local cFileCfg  := "HCF" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  
Local cFileHX5  := "HX5" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  
Local i := 1
Local ix := 1

Private aCfgData := {} // Contem os dados do arquivo de Configuracoes

aadd(aTiposcli,{"F=Cons.Final"})
aadd(aTiposcli,{"L=Produtor Rural"})
aadd(aTiposcli,{"R=Revendedor"})
aadd(aTiposcli,{"S=Solidario"})
aadd(aTiposcli,{"X=Exportacao"}) 

//Parametros para o SFA

aadd(aCfg,{"CF_PARAM"    , "C", 15, 0}) // Parametro 
aadd(aCfg,{"CF_VALOR"    , "C",255, 0}) // Conteudo

// Tabela HX5 
aadd(aTab,{"X5_TABELA","C",2,0})
aadd(aTab,{"X5_CHAVE","C",6,0})
aadd(aTab,{"X5_DESCRI","C",55,0})

ConOut("PALMJOB: Criando arquivo de Configuracoes para " + Trim(PALMUSER->P_USER))
PalmCreate(aCfg,cFileCfg,"HCF")     // Arquivo Configuracoes
PalmCreate(aTab,cFileHX5,"HX5")     // Arquivo Tabelas genericas 

// Parametros para Grade
//aadd(aCfgData,{"tamprod"       , cTamProd}) // Tamanho do Produto na Grade
//aadd(aCfgData,{"tamlinha"      , cTamLin}) // Tamanho do Linha na Grade
//aadd(aCfgData,{"tamcoluna"     , cTamCol}) // Tamanho do Coluna na Grade
aadd(aCfgData,{"CALCPROTHEUS"  , "T"}) // Usa calculo de Desconto basado no Protheus (T = Protheus, F = Nao Protheus)
aadd(aCfgData,{"DECPROTHEUS"   , GetMv("MV_PLMDEC",,"")}) // Usa calculo de Desconto basado no Protheus (T = Protheus, F = Nao Protheus)
//aadd(aCfgData,{"MV_PLCONSU"    , GetMv("MV_PLCONSU",,"1")}) // Permite visualizar consumo na consulta de produtos
//aadd(aCfgData,{"MV_PLPRECO"    , GetMv("MV_PLPRECO",,"T")}) // Tipo de preco

// Parametros novo SFA advpl
aadd(aCfgData,{"MV_BONUSTS" ,GetMv("MV_BONUSTS" ,,"502")})  // Parametro do Mod. Faturamento, o Tes do Item de Bonificacao
aadd(aCfgData,{"MV_PRODUPL" ,GetMv("MV_PRODUPL"  ,,"F")})   // Indica a possibilidade da repeticao de um produto em um pedido  (Protheus)
aadd(aCfgData,{"MV_SFAVIEW" ,GetMv("MV_SFAVIEW"  ,,"C")})   // View da Visita de Negocios (Cliente ou Roteiro)
aadd(aCfgData,{"MV_SFAPVIEW",GetMv("MV_SFAPVIEW" ,,"0")})   // ** Permissao de View da Visita de Negocios   
															// ** -> 0 ou se nao houver o Parametro - Cliente/Roteiro
														    // ** -> 1 - Roteiro
															// ** -> 2 - Cliente
aadd(aCfgData,{"MV_SFAMTES",GetMv("MV_SFAMTES" ,,"N")})   // Manipula o TES ? 
															// N= Nao (Utiliza o Tes do Cadastro de Produto) 
 															// S= Sim (Vendedor escolhe o TES na Operacao de Pedido) 
aadd(aCfgData,{"MV_SFAPLC"  ,GetMv("MV_SFAPLC" ,,"9999")})  // Preh - Limite de Credito. Utilizado para Clientes cadastrados no SFA.
aadd(aCfgData,{"MV_SFAPRIS"  ,GetMv("MV_SFAPRIS" ,,"B")})  // Pre - Risco do Clientes cadastrados no SFA.

aadd(aCfgData,{"MV_SFABLOQ" ,GetMv("MV_SFABLOQ" ,,"1")})    // Verificacao de Credito  do Protheus

aadd(aCfgData,{"MV_SFADEB" ,GetMv("MV_SFADEB" ,,"1")})    // Verificacao de Credito  do Protheus

aadd(aCfgData,{"MV_RISCOB" ,Str(GetMv("MV_RISCOB" ,,""),3,0)})   // Numero maximo de dias para atraso de uma duplicata para clientes Risco B
aadd(aCfgData,{"MV_RISCOC" ,Str(GetMv("MV_RISCOC" ,,""),3,0)})   // Numero maximo de dias para atraso de uma duplicata para clientes Risco C
aadd(aCfgData,{"MV_RISCOD" ,Str(GetMv("MV_RISCOD" ,,""),3,0)})   // Numero maximo de dias para atraso de uma duplicata para clientes Risco D

aadd(aCfgData,{"MV_SFAASS" ,GetMv("MV_SFAASS" ,,"F")})    // **Usar Assinatura Digital

aadd(aCfgData,{"MV_SFATPRO",GetMv("MV_SFATPRO",,"1")})    //--> Telas do Produto: 
	           											  //    1 - Avancado (Tela Padrao de Produto)
														  //    2 - Basico (Tela de Produto sem Grupo)
														  //    3 - Especifico (Ponto de Entrada)

aadd(aCfgData,{"MV_SFATPED",GetMv("MV_SFATPED",,"1")})    // --> Telas de Pedido:
														  //    1 - Tela Pedido V 1.0
														  //    2 - Tela Pedido V 2.0
														  //    3 - Tela Pedido Ponto de Entrada
aadd(aCfgData,{"MV_DTSYNC",GetMv("MV_DTSYNC",,"0")})      // --> Parametro Quantidade de Dias sem sincronismo
aadd(aCfgData,{"MV_SFAIND",GetMv("MV_SFAIND",,"F")})      // --> Indica se utiliza ou nao indenizacao
aadd(aCfgData,{"MV_BLOQPRC",GetMv("MV_BLOQPRC",,"S")})    // --> Indica se o preco podera ser alterado
aadd(aCfgData,{"MV_SFCONDI",GetMv("MV_SFCONDI",,"F")})    // --> Indica se as regras de negocio serao avalidas na inclusao
aadd(aCfgData,{"MV_SFAFPG",GetMv("MV_SFAFPG",,"F")})    // --> Indica se a Forma de Pagamento sera informada
aadd(aCfgData,{"MV_SFAFRE",GetMv("MV_SFAFRE",,"F")})    // --> Indica se o Tipo de Frete sera informado
aadd(aCfgData,{"MV_SFCADCL",GetMv("MV_SFCADCL",,"1")})   // --> Parametro para restricoes no cadastro de clientes (1=Completo; 2=Alteracao; 3= Apenas Consulta)
aadd(aCfgData,{"MV_SFPROPR",GetMv("MV_SFPROPR",,"")})    // --> Prefixo de Busca do Produto (<Prefixo>, <Vezes>, <Tamanho>)
aadd(aCfgData,{"MV_PRINTER",GetMv("MV_PRINTER",,"1")})   // --> Define qua a impressora utilizada (1=Sipix, 2=Monarch)
aadd(aCfgData,{"MV_SFPAGIN",GetMv("MV_SFPAGIN",,"50")})  // --> Define numero de itens na pagina cao do produto
aadd(aCfgData,{"MV_SFTPTIT",GetMv("MV_SFTPTIT",,"NCC")})    // --> Define os tipos de titulos desconsiderados na verificação de Débitos
aadd(aCfgData,{"MV_SFAPESO",GetMv("MV_SFAPESO",,"F")})   // --> Indica utilizacao de Peso do Pedido
aadd(aCfgData,{"MV_SFAQTDE",GetMv("MV_SFAQTDE",,"T")})   // --> Indica utilizacao de decimais no campo Qtde do P.V.
aadd(aCfgData,{"MV_SFACFG",GetMv("MV_SFACFG",,"1")})   // --> Indica a utilizacao da opcao Config
aadd(aCfgData,{"MV_SFADRT",GetMv("MV_SFADRT",,"1")})   // --> Indica se habilita  no menu, a opcao de reenvio de pedidos 
aadd(aCfgData,{"MV_SFATAB",GetMv("MV_SFATAB",,"F")})   // --> A tabela padrão do cliente não poderá ser alterada!","Tabela Fixa")
aadd(aCfgData,{"MV_SFAMTTP",GetMv("MV_SFAMTTP",,"3")})   // --> Indica tipo de meta utilizada, 1=Mensal, 2= Semanal 3 = Diaria
aadd(aCfgData,{"MV_NUMPARC",GetMv("MV_NUMPARC",,"0")})  // --> Numeros de parcela para condicao Negociada
aadd(aCfgData,{"MV_SFPRSB1",GetMv("MV_SFPRSB1",,"N")})  // --> Indica se o preco no cadastro de produto sera utilizado

// Se o sistema utilizado pelo vendedor for FDA - Fast Delivery Automation 
// Utiliza os Parametros abaixo 
   aadd(aCfgData,{ "MV_FDAESPC", GetMV("MV_FDAESP" ,, "NFE"    ) })  // --> Parametro especie para nota de entrada
   aadd(aCfgData,{ "MV_FDATDOC", GetMV("MV_FDATDOC",, "D"      ) })  // --> Parametro Tipo de Documento de entrada  
   aadd(aCfgData,{ "MV_FDACLIP", GetMV("MV_FDACLIP",, "000001" ) })  // --> Parametro CLiente Padrao usa SFA  
   aadd(aCfgData,{ "MV_FDALOJP", GetMV("MV_FDALOJP",, "01"     ) })  // --> Parametro Loja do cliente padrao  
   aadd(aCfgData,{ "MV_FDAFORM", GetMV("MV_FDAFORM",, "N"      ) })  // --> Parametro Se e formulario Proprio S/N                                                                        
   aadd(aCfgData,{ "MV_FDASERI", GetMV("MV_FDASERI",, "RUA"    ) })  // --> Parametro Serie da Nota de Entrada 
   aadd(aCfgData,{ "MV_FDATDEV", GetMV("MV_FDATDEV",, "009"    ) })  // --> Parametro Tes de Devolucao 
   aadd(aCfgData,{ "MV_ESTADO",  GetMV("MV_ESTADO",, "SP"     ) })  // --> Sigla do estado que esta sendo usado o sistema
   aadd(aCfgData,{ "MV_ICMPAD",  GetMV("MV_ICMPAD",, "18"    ) })   // --> Aliquota aplicadas nas operacoes 
   aadd(aCfgData,{ "MV_ICMPAUT", GetMV("MV_ICMPAUT" ,, "T"    ) })  // --> ICMS de Pauta 
   aadd(aCfgData,{ "MV_NORTE" ,  GetMV("MV_NORTE" ,, "SP"    ) })  // --> Estados pertencentes ao Norte/Nordeste
   aadd(aCfgData,{ "MV_ESTICM",  GetMV("MV_ESTICM",, "SP18"  ) })  // --> ALIQ. DE ICMS DE CADA ESTADO
   aadd(aCfgData,{ "MV_IPIBRUTO",GetMV("MV_IPIBRUTO",, "N"   ) })  // --> Tipo de calculo para valor de IPI

	// Tratamento de Parametros do Usuario
	If ((ExistBlock("PLMCFG01")))
		ExecBlock("PLMCFG01",.F.,.F.)
	EndIf


If ExisteSX6("MV_CPOLVR") .And. !Empty(GetMv("MV_CPOLVR"))
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek(GetMv("MV_CPOLVR"))
		cTitulo := SX3->X3_TITULO
		cTipo   := SX3->X3_TIPO
		nTam    := SX3->X3_TAMANHO
		nDec    := SX3->X3_DECIMAL
	EndIf
EndIf

// Numero de Casas Decimais para arredondamento
nPos := aScan(aCfgData,{|x| x[1] = "DECPROTHEUS"})
If Empty(aCfgData[nPos,2])
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek("C6_PRCVEN")
		aCfgData[nPos,2] := Str(SX3->X3_DECIMAL,2,0)
	Else
		aCfgData[nPos,2] := "2"
	EndIf
EndIf

// Grava Arquivo CONFIG	
For i := 1 To Len(aCfgData)
	dbSelectArea("HCF")
	RecLock("HCF",.T.)
	HCF->CF_PARAM := aCfgData[i,1]  
	//Verifica se campo logico 
	IF VALTYPE(aCfgData[i,2])=="L" 
	   aCfgData[i,2] := IF( aCfgData[i,2] , "T", "F" )             
	ENDIF   
	HCF->CF_VALOR  := IF( VALTYPE(aCfgData[i,2])=="N" ,STR(aCfgData[i,2]), aCfgData[i,2] )  
	HCF->(MsUnlock())
Next

//Grava os Cargos
dbSelectArea("SUM")
dbSetOrder(1)
dbGoTop()
dbSeek(xFilial("SUM"))
While !Eof() .And. SUM->UM_FILIAL == xFilial("SUM")
      RecLock("HX5",.T.)
	  HX5->X5_TABELA  := "UM"
	  HX5->X5_CHAVE   := SUM->UM_CARGO
 	  HX5->X5_DESCRI  := SUM->UM_DESC
	  HX5->(MsUnlock())
      dbSelectArea("SUM")
      dbSkip()
EndDo                    

cTabela := "12"  // Tabela Estados UF
dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial("SX5") + cTabela)
While !Eof() .And. SX5->X5_FILIAL = xFilial() .And. SX5->X5_TABELA = cTabela
   	dbSelectArea("HX5")
   	RecLock("HX5",.T.)       
    HX5->X5_TABELA  := "UF"
	HX5->X5_CHAVE   := SX5->X5_CHAVE
 	HX5->X5_DESCRI  := SX5->X5_DESCRI
	HX5->(MsUnlock())
	dbSelectArea("SX5")
	dbSkip()
EndDo

// Tabela de Motivos de Indenizacao
cTabela := "MT"
dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial("SX5") + cTabela)
While !Eof() .And. SX5->X5_FILIAL = xFilial() .And. SX5->X5_TABELA = cTabela
   	dbSelectArea("HX5")
   	RecLock("HX5",.T.)       
    HX5->X5_TABELA := SX5->X5_TABELA
	HX5->X5_CHAVE  := SX5->X5_CHAVE
 	HX5->X5_DESCRI := SX5->X5_DESCRI
	HX5->(MsUnlock())
	dbSelectArea("SX5")
	dbSkip()
EndDo

//Grava as Ocorrencias de nao visita
dbSelectArea("AC5")
dbSetOrder(1)
dbGoTop()
dbSeek(xFilial("AC5"))
While !Eof() .And. AC5->AC5_FILIAL == xFilial("AC5")
      RecLock("HX5",.T.)
	  HX5->X5_TABELA := "OC"
	  HX5->X5_CHAVE  := AC5->AC5_EVENTO
 	  HX5->X5_DESCRI := AC5->AC5_DESCRI
	  HX5->(MsUnlock())
      dbSelectArea("AC5")
      dbSkip()
EndDo                               

// Grava Tipos de Cliente
For ix := 1 To Len(aTiposCli)
      RecLock("HX5",.T.)
	  HX5->X5_TABELA  := "TC"
	  HX5->X5_CHAVE   := SUBS(aTiposCli[ix,1],1,1 )
 	  HX5->X5_DESCRI  := SUBS(aTiposCli[ix,1],3,14 )
	  HX5->(MsUnlock())
Next

HCF->(dbCloseArea())
HX5->(dbCloseArea()) 

Return

//retorna alias usados pelo servico
User Function PCfgTab( )
Return {}

//retorna nome fisico do arquivo espelho
User Function PCfgArq( )               
Local cFileCfg := "HCF" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFileHX5 := "HX5" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Return {cFileCfg, cFileHX5 }

//retorna indice usado pelo arquivo espelho
User Function PCfgInd( )
Return {"CF_PARAM","X5_TABELA+X5_CHAVE"}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PMensagem³ Autor ³ Marcelo Vieira        ³ Data ³ 07/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Enviar mensagem da retaguarda para vendedor                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PMensagem()
Local aMensagem  := {} // Contem os dados do arquivo de Mensagens
Local cMensagem  := ""
Local i          := 0
Local cVendedor  := PALMUSER->P_CODVEND
Local lEnviaMsg  := .F.
Local cAliasMsg  := GetMv("MV_TBLMSG",,"") 
Local cPrefixCpo := Subs(cAliasMsg,2,2)+"_"      
Local cFileMsg   := "HMV" + cEmpAnt + "0" 

AADD(aMensagem,{"HMV_COD"     , "C",   6, 0})
AADD(aMensagem,{"HMV_MSG"     , "C", 255, 0})
AADD(aMensagem,{"HMV_ORI"     , "C",   1, 0})
AADD(aMensagem,{"HMV_VEND"    , "C",   6, 0})
AADD(aMensagem,{"HMV_DATA"    , "D",   8, 0})
AADD(aMensagem,{"HMV_DTVIG"   , "D",   8, 0})
AADD(aMensagem,{"HMV_STATUS"  , "C",   1, 0})

PAcertaSx3(@aMensagem)

ConOut("PALMJOB: Criando arquivo de Mensagens para " + Trim(PALMUSER->P_USER))

PalmCreate(aMensagem, cFileMsg ,"HMV")

if !Empty( cAliasMsg )
	dbSelectArea( cAliasMsg )
	dbGotop()
Else
	HMV->(dbCloseArea())
	Return
EndIf

While (cAliasMsg)->(!Eof())
    If (cAliasMsg)->&(cPrefixCpo+"ORIMSG") != "1"
    	(cAliasMsg)->(dbSkip())
		Loop
    Endif
	
	If Empty( (cAliasMsg)->&(cPrefixCpo+"DATAVIG")) .And. Empty((cAliasMsg)->&(cPrefixCpo+"CODVEND"))
		// Se data e vendedor estiverem em branco enviar.
		lEnviaMsg := .T.
	ElseIf Empty((cAliasMsg)->&(cPrefixCpo+"DATAVIG")) .And. Alltrim((cAliasMsg)->&(cPrefixCpo+"CODVEND")) == Alltrim(cVendedor)
		// Se data em branco e vendedor igual a usuario enviar.
		lEnviaMsg := .T.
	ElseIf Empty((cAliasMsg)->&(cPrefixCpo+"CODVEND")) .And. (!Empty( (cAliasMsg)->&(cPrefixCpo+"DATAVIG") ) .And. (cAliasMsg)->&(cPrefixCpo+"DATAVIG") > dDataBase )
		// Se vigencia valida e vendedor vazio enviar.
	    lEnviaMsg := .T.   
	ElseIf !Empty( (cAliasMsg)->&(cPrefixCpo+"DATAVIG") ) .And. (cAliasMsg)->&(cPrefixCpo+"DATAVIG") > dDataBase ;
		.And. Alltrim((cAliasMsg)->&(cPrefixCpo+"CODVEND")) == Alltrim(cVendedor)
		//Se vigencia valida e vendedor igual a usuario enviar.
		lEnviaMsg := .T.
	Else
	    lEnviaMsg := .F.
	EndIf

	If lEnviaMsg 
		dbSelectArea("HMV")
		RecLock("HMV",.T.)
		HMV->HMV_COD    := (cAliasMsg)->&(cPrefixCpo+"CODMSG")
		HMV->HMV_MSG    := (cAliasMsg)->&(cPrefixCpo+"MENSAGE")
		HMV->HMV_ORI    := (cAliasMsg)->&(cPrefixCpo+"ORIMSG")
		HMV->HMV_VEND   := (cAliasMsg)->&(cPrefixCpo+"CODVEND")
		HMV->HMV_DATA   := (cAliasMsg)->&(cPrefixCpo+"DATAMSG")
		HMV->HMV_DTVIG  := (cAliasMsg)->&(cPrefixCpo+"DATAVIG")
		HMV->HMV_STATUS := "P"
		HMV->(MsUnlock())	
	Endif
	    
    dbSelectArea(cAliasMsg)
	dbSkip()
	
EndDo
HMV->(dbCloseArea())
Return

//retorna alias usados pelo servico
User Function PMsgTab( )
Local cAliasMsg := ""
cAliasMsg  := GetMv("MV_TBLMSG",,"")
Return {cAliasMsg}

//retorna nome fisico do arquivo espelho
User Function PMsgArq( )
Local cFileMsg  := "HMV" + Left(PALMSERV->P_EMPFI,2) + "0"  //+(PSALIAS)->P_EMPFI  
Return {cFileMsg}

//retorna indice usado pelo arquivo espelho
User Function PMsgInd( )
Return {"HMV_COD"}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ pcenVends³ Autor ³ Marcelo Vieira        ³ Data ³ 04/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Envia Tabelas Cenario de vendas                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³																		  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function PCenVends()
 
Local aRegDescC := {} // Contem os dados do arquivo de Regra de desconto (cabe‡alho) - ACO
Local aRegDescI := {} // Contem os dados do arquivo de Regra de desconto (itens)     - ACP

Local aRegBoniC := {} // Contem os dados do arquivo de Regra de desconto (cabe‡alho) - ACQ 
Local aRegBoniI := {} // Contem os dados do arquivo de Regra de desconto (itens)     - ACR

Local aRegNegoC := {} // Contem os dados do arquivo de Regra de desconto (cabe‡alho) - ACS
Local aRegNegoI := {} // Contem os dados do arquivo de Regra de desconto (itens)     - ACT

// Nomes fisicos para tabelas dos SFA 
Local cFileRBonC:="HCQ" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI 
Local cFileRBonI:="HCR" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI 
Local cFileRDesC:="HCO" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI 
Local cFileRDesI:="HCP" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI 
Local cFileRNegC:="HCS" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI 
Local cFileRNegI:="HCT" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI 
//Local cVendedor   := PALMUSER->P_CODVEND
Local i := 1
// Cabecallho da regra de desconto
aadd( aRegDescC,{"ACO_CODREG", "C" , 06, 0})
aadd( aRegDescC,{"ACO_DESCRI", "C" , 30, 0})
aadd( aRegDescC,{"ACO_CODCLI", "C" , 06, 0})
aadd( aRegDescC,{"ACO_LOJA"  , "C" , 02, 0})
aadd( aRegDescC,{"ACO_CODTAB", "C" , 03, 0})
aadd( aRegDescC,{"ACO_CONDPG", "C" , 03, 0})
aadd( aRegDescC,{"ACO_FORMPG", "C" , 02, 0})
aadd( aRegDescC,{"ACO_FAIXA" , "N" , 12, 2})
aadd( aRegDescC,{"ACO_MOEDA" , "N" , 02, 0})
aadd( aRegDescC,{"ACO_PERDES", "N" , 06, 2})
aadd( aRegDescC,{"ACO_CFAIXA", "C" , 20, 0})
aadd( aRegDescC,{"ACO_GRPVEN", "C" , 06, 0}) // Grupo de clientes vendas ( Bops 82671 )

PAcertaSx3(@aRegDescC)

// Itens da Regra de Desconto
aadd( aRegDescI,{"ACP_CODREG", "C", 06, 0})
aadd( aRegDescI,{"ACP_ITEM"  , "C", 03, 0})
aadd( aRegDescI,{"ACP_CODPRO", "C", 15, 0})
aadd( aRegDescI,{"ACP_GRUPO" , "C", 04, 0})
aadd( aRegDescI,{"ACP_PERDES", "N", 06, 2})
aadd( aRegDescI,{"ACP_FAIXA" , "N", 09, 2})
aadd( aRegDescI,{"ACP_CFAIXA", "C", 20, 0})                                       

PAcertaSx3(@aRegDescI)

// Cabecalho da Regra de Bonificacao
aadd( aRegBoniC,{"ACQ_CODREG" ,"C"  ,6 ,  0})                                       
aadd( aRegBoniC,{"ACQ_DESCRI" ,"C"  ,30,  0})                                       
aadd( aRegBoniC,{"ACQ_CODCLI" ,"C"  ,6 ,  0})                                       
aadd( aRegBoniC,{"ACQ_LOJA"   ,"C"  ,2 ,  0})                                       
aadd( aRegBoniC,{"ACQ_CODTAB" ,"C"  ,3 ,  0})                                       
aadd( aRegBoniC,{"ACQ_CONDPG" ,"C"  ,3 ,  0})                                       
aadd( aRegBoniC,{"ACQ_FORMPG" ,"C"  ,2 ,  0})                                       
aadd( aRegBoniC,{"ACQ_CODPRO" ,"C"  ,15,  0})                                       
aadd( aRegBoniC,{"ACQ_QUANT"  ,"N"  ,12,  2})                                       
aadd( aRegBoniC,{"ACQ_TPRGBN" ,"C"  ,1 ,  0})                                       

PAcertaSx3(@aRegBoniC)

// Itens da regra de Bonifica
aadd( aRegBoniI,{"ACR_CODREG" ,"C"  ,6 ,  0})
aadd( aRegBoniI,{"ACR_ITEM"   ,"C"  ,3 ,  0})
aadd( aRegBoniI,{"ACR_CODPRO" ,"C"  ,15,  0})
aadd( aRegBoniI,{"ACR_GRUPO"  ,"C"  ,4 ,  0})
aadd( aRegBoniI,{"ACR_LOTE"   ,"N"  ,9 ,  2})

PAcertaSx3(@aRegBoniI)

// Cabecalho da Regra de Negocios
aadd( aRegNegoC,{"ACS_CODREG","C"   ,6 , 0})
aadd( aRegNegoC,{"ACS_DESCRI","C"   ,30, 0})
aadd( aRegNegoC,{"ACS_CODCLI","C"   ,6 , 0})
aadd( aRegNegoC,{"ACS_LOJA"  ,"C"   ,2 , 0})

PAcertaSx3(@aRegNegoC)

// Itens da Regra de Negocios
aadd( aRegNegoI,{"ACT_CODREG" ,"C"   ,6 ,  0})
aadd( aRegNegoI,{"ACT_ITEM"   ,"C"   ,3 ,  0})
aadd( aRegNegoI,{"ACT_CODTAB" ,"C"   ,3 ,  0})
aadd( aRegNegoI,{"ACT_CONDPG" ,"C"   ,3 ,  0})
aadd( aRegNegoI,{"ACT_FORMPG" ,"C"   ,2 ,  0})
aadd( aRegNegoI,{"ACT_TPRGNG" ,"C"   ,1 ,  0})

PAcertaSx3(@aRegNegoI)

ConOut("PALMJOB: Criando arquivo de Cenarios de Vendas para " + Trim(PALMUSER->P_USER))
PalmCreate( aRegDescC, cFileRDesC, "HCO" )
PalmCreate( aRegDescI, cFileRDesI, "HCP" )
PalmCreate( aRegBoniC, cFileRBonC, "HCQ" )
PalmCreate( aRegBoniI, cFileRBonI, "HCR" )
PalmCreate( aRegNegoC, cFileRNegC, "HCS" )
PalmCreate( aRegNegoI, cFileRNegI, "HCT" )

dbSelectArea("ACO")
dbSetOrder(1)
dbSeek(xFilial("ACO"))
While ACO->(!Eof()) .And. ACO->ACO_FILIAL = xFilial("ACO")
	dbSelectArea("HCO")
	RecLock("HCO",.T.)
	For i:=1 to Len(aRegDescC)
		If ACO->(FieldPos(aRegDescC[i,1])) > 0
			HCO->( FieldPut( HCO->(FieldPos(aRegDescC[i,1])), ACO->(FieldGet(FieldPos(aRegDescC[i,1])))  )   )
		EndIf
	Next
	HCO->( MsUnlock() )
	  
	ACO->( dbSkip())
EndDo

dbSelectArea("ACP")
dbSetOrder(1)
dbSeek(xFilial("ACP"))
While ACP->(!Eof()) .And. ACP->ACP_FILIAL = xFilial("ACP")
	dbSelectArea("HCP")
	RecLock("HCP",.T.)
	For i:=1 to Len(aRegDescI)
  		If ACP->(FieldPos(aRegDescI[i,1])) > 0
			HCP->( FieldPut( HCP->(FieldPos(aRegDescI[i,1])), ACP->(FieldGet(FieldPos(aRegDescI[i,1])))  )   )
		EndIf
	Next
	HCP->( MsUnlock() )
	  
	ACP->( dbSkip())
EndDo    

// Gera Regra de Bonificacao 
dbSelectArea("ACQ")
dbSetOrder(1)
dbSeek(xFilial("ACQ"))
While ACQ->(!Eof()) .And. ACQ->ACQ_FILIAL = xFilial("ACQ")
	dbSelectArea("HCQ")
	RecLock("HCQ",.T.)
	For i:=1 to Len(aRegBoniC)
  		If ACQ->(FieldPos(aRegBoniC[i,1])) > 0
			HCQ->( FieldPut( HCQ->(FieldPos(aRegBoniC[i,1])), ACQ->(FieldGet(FieldPos(aRegBoniC[i,1])))  )   )
		EndIf
	Next
	HCQ->( MsUnlock() )
 
	ACQ->( dbSkip())
EndDo

// Gera Regra de Bonificacao Itens 
dbSelectArea("ACR")
dbSetOrder(1)
dbSeek(xFilial("ACR"))
While ACR->(!Eof()) .And. ACR->ACR_FILIAL = xFilial("ACR")
	dbSelectArea("HCR")
	RecLock("HCR",.T.)
	For i:=1 to Len(aRegBoniI)
  		If ACR->(FieldPos(aRegBoniI[i,1])) > 0
			HCR->( FieldPut( HCR->(FieldPos(aRegBoniI[i,1])), ACR->(FieldGet(FieldPos(aRegBoniI[i,1])))  )   )
		EndIf
	Next
	HCR->( MsUnlock() )
	  
	ACR->( dbSkip())
EndDo

// Gera Regra de Negocios
dbSelectArea("ACS") 
dbSetOrder(1)
dbSeek(xFilial("ACS"))
While ACS->(!Eof())  .And. ACS->ACS_FILIAL = xFilial("ACS")
	dbSelectArea("HCS")
	RecLock("HCS",.T.)
	For i:=1 to Len(aRegNegoC)
		If ACS->(FieldPos(aRegNegoC[i,1])) > 0
			HCS->( FieldPut( HCS->(FieldPos(aRegNegoC[i,1])), ACS->(FieldGet(FieldPos(aRegNegoC[i,1])))  )   )
		EndIf
	Next
	HCS->( MsUnlock() )
	  
	ACS->( dbSkip())
EndDo    

// Gera Itens da Regra de Negocio
dbSelectArea("ACT")
dbSetOrder(1)
dbSeek(xFilial("ACT"))
While ACT->(!Eof()) .And. ACT->ACT_FILIAL = xFilial("ACT")
	dbSelectArea("HCT")
	RecLock("HCT",.T.)
	For i:=1 to Len(aRegNegoI)
		If ACT->(FieldPos(aRegNegoI[i,1])) > 0
			HCT->( FieldPut( HCT->(FieldPos(aRegNegoI[i,1])), ACT->(FieldGet(FieldPos(aRegNegoI[i,1])))  )   )
		EndIf
	Next
	HCT->( MsUnlock() )
	  
	ACT->( dbSkip())
EndDo

HCO->(dbCloseArea())
HCP->(dbCloseArea())
HCQ->(dbCloseArea())
HCR->(dbCloseArea())
HCS->(dbCloseArea())
HCT->(dbCloseArea())

Return

//Retorna alias usados pelo servico
User Function PRegrTab
Return {"ACO","ACP","ACQ","ACR","ACS","ACT"}

//retorna nome fisico do arquivo espelho
User Function PRegrArq
Local cFileRDesC:="HCO" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI 
Local cFileRDesI:="HCP" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI
Local cFileRBonC:="HCQ" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI
Local cFileRBonI:="HCR" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI
Local cFileRNegC:="HCS" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI
Local cFileRNegI:="HCT" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI
Return {cFileRDesC,cFileRDesI,cFileRBonC,cFileRBonI,cFileRNegC,cFileRNegI}

//retorna indice usado pelo arquivo espelho
User Function PRegrInd
Local cIndRDesC:="ACO_CODREG"
Local cIndRDesI:="ACP_CODREG+ACP_ITEM"
Local cIndRBonC:="ACQ_CODREG"
Local cIndRBonI:="ACR_CODREG+ACR_ITEM"
Local cIndRNegC:="ACS_CODREG"
Local cIndENegI:="ACT_CODREG+ACT_ITEM"
Return {cIndRDesC,cIndRDesI,cIndRBonC,cIndRBonI,cIndRNegC,cIndENegI}


/// ***********************************************************************************************
/// ******************** SERVICOS EXCLUSIVOS PARA O MODULO SIGAOMS ********************************
/// ***********************************************************************************************
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PRotaOms ³ Autor ³ Fabio Garbin          ³ Data ³ 23/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho das Rotas.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm - Exclusivo para modulo SIGAOMS            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ M.Vieira   ³11.11.01³ Substituicao de macros pela funcao FieldPut()   ³±±
±±|            |        | FieldGet()                                      ³±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PRotaOms()  
Local aRoteiro   := {} // Contem os dados do arquivo do Roteiro de Visitas
Local aRota      := {} //Contem os dados do arquivo de Rotas
Local cPercurso  := ""
Local cVendedor  := PALMUSER->P_CODVEND
Local cFileRotas := "HRT"  + cEmpAnt + "0" 
Local cFileRoteiro:="HD7"  + cEmpAnt + "0" 

// Preenche o array com os campos a serem enviados tabela Rotas
aadd(aRota,{"RT_PERCUR", "C",  6, 0}) // Codigo do Percurso
aadd(aRota,{"RT_ROTA"  , "C",  6, 0}) // Codigo da Rota (Palm)
aadd(aRota,{"RT_DESCR" , "C", 14, 0}) // Descricao da Rota

// Preenche o array com os campos a serem enviados tabela Roteiro

aadd(aRoteiro,{"AD7_PERCUR" , "C", 06, 0}) // Codigo do Percurso
aadd(aRoteiro,{"AD7_ROTA"   , "C", 06, 0}) // Codigo da Rota
aadd(aRoteiro,{"AD7_DESPER" , "C", 40, 0}) // Descricao do Percurso
aadd(aRoteiro,{"AD7_ORDEM"  , "C", 06, 0}) // Codigo da Visita
aadd(aRoteiro,{"AD7_CLI"    , "C", 06, 0}) // Codigo do cliente
aadd(aRoteiro,{"AD7_LOJA"   , "C", 02, 0}) // Loja do cliente
aadd(aRoteiro,{"AD7_DATA"   , "D", 08, 0}) // Data 
aadd(aRoteiro,{"AD7_FLGVIS" , "C", 01, 0}) // Flag de Atendimento
aadd(aRoteiro,{"AD7_OCO"    , "C", 06, 0}) // Ocorrencia
aadd(aRoteiro,{"AD7_DT"     , "D", 08, 0}) // Data da Ocorrencia 

PAcertaSx3(@aRoteiro)

ConOut("PALMJOB: Criando arquivo de Rota(OMS) para " + Trim(PALMUSER->P_USER))

//PalmCreate(<estrutura>,<arquivo>,<alias>)
PalmCreate(aRota,cFileRotas,"HRT")
PalmCreate(aRoteiro,cFileRoteiro,"HD7")

// Grava Arquivos Temporarios
dbSelectArea("DA5")
dbSetOrder(2)
dbSeek(xFilial("DA5")+cVendedor, .t.)
While !DA5->(Eof()) .and. DA5->DA5_FILIAL= xFilial("DA5") .and. DA5->DA5_VENDED = cVendedor
	cPercurso := DA5->DA5_COD
	dbSelectArea("DA6")
	dbSetOrder(1)
	If dbSeek(xFilial("DA6")+cPercurso)
		While !DA6->(Eof()) .And. DA6->DA6_FILIAL = xFilial("DA6") .and. DA6->DA6_PERCUR = cPercurso
			cRota := DA6->DA6_ROTA
			dbSelectArea("DA7")
			dbSetOrder(1)
			If dbSeek(xFilial("DA7")+cPercurso+cRota)
				While !DA7->(Eof()) .and. DA7->DA7_FILIAL= xFilial("DA7") .And. DA7->DA7_ROTA = cRota .And. DA7->DA7_PERCUR = cPercurso
					dbSelectArea("SA1")
					dbSetOrder(1)
					dbSeek(xFilial("SA1")+DA7->DA7_CLIENT+DA7->DA7_LOJA)
					dbSelectArea("HD7")
					RecLock("HD7",.T.)
					HD7->AD7_ROTA    := DA7->DA7_ROTA
					HD7->AD7_PERCUR  := DA7->DA7_PERCUR
					HD7->AD7_DESPER  := DA6->DA6_REF
					HD7->AD7_ORDEM   := DA7->DA7_SEQUEN
					HD7->AD7_CLI     := DA7->DA7_CLIENTE
					HD7->AD7_LOJA    := DA7->DA7_LOJA
					HD7->AD7_DATA    := CtoD("")
					HD7->AD7_FLGVIS  := ""
					HD7->AD7_OCO     := Space(6)
					HD7->AD7_DT      := CTOD('')
					HD7->(MsUnlock())					                
					dbSelectArea("DA7")
					DA7->(dbSkip())
					
					If DA7->DA7_ROTA <> cRota //.Or. DA7->DA7_PERCUR <> cPercurso
						dbSelectArea("HRT")
						RecLock("HRT",.T.)
						HRT->RT_PERCUR:= cPercurso
						HRT->RT_ROTA  := cRota
						HRT->RT_DESCR := DA6->DA6_REF //DA5->DA5_DESC
						HRT->(MsUnlock())
					EndIf
				EndDo
			EndIf
			dbSelectArea("DA6")
			DA6->(dbSkip())
		EndDo
	EndIf
	dbSelectArea("DA5")
	dbSkip()
EndDo

HRT->(dbCloseArea())
HD7->(dbCloseArea())

Return

//retorna alias usados pelo servico
User Function PRotTabO( )
Return {"DA5","DA6","DA7","SA1"}

//retorna nome fisico do arquivo espelho
User Function PRotArqO( )
Local cFileRotas   :="HRT"  + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI 
Local cFileRoteiro :="HD7"  + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI 
Return {cFileRotas,cFileRoteiro}

//retorna indice usado pelo arquivo espelho
User Function PRotIndO( )
//Return {"RT_ROTA","AD7_ROTA+AD7_ORDEM"}
Return {"RT_PERCUR+RT_ROTA","AD7_PERCUR+AD7_ROTA+AD7_ORDEM"}
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PCliOms  ³ Autor ³ Fabio Garbin          ³ Data ³ 23/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho das Clientes.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm - Exclusivo para modulo SIGAOMS            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ M.Vieira   ³11.11.01³ Substituicao de macros pela funcao FieldPut()   ³±±
±±|            |        | FieldGet() para ficar mais rapida gravacao      ³±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCliOms()

Local aCliente   := {} // Contem os dados do arquivo de CLIENTES
Local aContato   := {} // Contem os dados do arquivo de CONTATOS
Local aCargo     := {} // Contem os dados do arquivo de CARGO
Local aFinanceiro:= {} // Contem os dados do arquivo de FINANCEIRO
Local aConsumo   := {} // Contem os dados do arquivo de CONSUMO
Local aCons      := {}
Local aInv       := {}
Local aTend      := {}
Local i          := 0
Local cFiltro    := ""
Local cVendedor  := PALMUSER->P_CODVEND
Local nConProd   := GetMV("MV_PLMPRC",,1)
Local cConsumoSN := GetMV("MV_PLMCNS",,"S")  // Novo *** indica se exporta ou nao Consumo 
Local nCndFix    := 1
Local nQtdSE1    := 0
Local lOkCli     := .T.
Local lOkFin     := .T.
// Variveis para execucao com SQL
#IFDEF TOP
	Local lQuery    := .F.
	Local cQuery    := ""
	Local cQuerySE1 := ""
	Local aStruDA5  := {}
	Local aStruSE1  := {}
	Local cAliasDA5 := "DA5"
	Local cAliasDA6 := "DA6"
	Local cAliasDA7 := "DA7"	          
	Local nX           
#ELSE
    Local cFiltroSE1 := ""	

#ENDIF

Local cFileCli:="HA1" + cEmpAnt + "0" 
Local cFileCon:="HU5" + cEmpAnt + "0" 
Local cFileFin:="HE1" + cEmpAnt + "0" 
Local cFileCns:="HCN" + cEmpAnt + "0" 
Local cFileAtm:="HAT" + cEmpAnt + "0" 
Local cFileInv:="HIN" + cEmpAnt + "0" 

Private cAliasSA1 := "SA1"
Private cAliasSE1 := "SE1"

ConOut("PALMJOB: Criando arquivo de Clientes(OMS) para " + Trim(PALMUSER->P_USER))

// Preenche o array com os campos do cliente a serem enviados
aadd(aCliente,{"A1_COD"					, "C", 06, 0}) // Codigo do Cliente (Pocket)
aadd(aCliente,{"A1_LOJA"				, "C", 02, 0}) // Loja do Cliente
aadd(aCliente,{"A1_CGC"					, "C", 14, 0}) // CGC/CPF do cliente
aadd(aCliente,{"A1_NOME"				, "C", 40, 0}) // Nome do cliente
aadd(aCliente,{"A1_NREDUZ"				, "C", 20, 0}) // Nome Reduzido do cliente
aadd(aCliente,{"A1_TIPO"				, "C", 01, 0}) // Tipo do cliente
aadd(aCliente,{"A1_END"			   		, "C", 40, 0}) // Endereco do cliente
aadd(aCliente,{"A1_MUN"					, "C", 15, 0}) // Municipio do cliente
aadd(aCliente,{"A1_EST"					, "C", 02, 0}) // Estado do cliente
aadd(aCliente,{"A1_BAIRRO"				, "C", 30, 0}) // Bairro do cliente
aadd(aCliente,{"A1_CEP"					, "C", 08, 0}) // Cod Enderecamento Postal
aadd(aCliente,{"A1_TEL"					, "C", 15, 0}) // Telefone do cliente
aadd(aCliente,{"A1_FAX"					, "C", 15, 0}) // Numero do FAX do cliente
aadd(aCliente,{"A1_INSCR"				, "C", 18, 0}) // Inscricao Estadual
aadd(aCliente,{"A1_INSCRM"				, "C", 18, 0}) // Inscricao Municipal
aadd(aCliente,{"A1_VEND"				, "C", 06, 0}) // Codigo do Vendedor
aadd(aCliente,{"A1_REGIAO"				, "C", 03, 0}) // Regiao do Cliente
aadd(aCliente,{"A1_TRANSP"				, "C", 06, 0}) // Transportadora do Cliente
aadd(aCliente,{"A1_TPFRET"				, "C", 01, 0}) // Frete padrao do Cliente
//aadd(aCliente,{"A1_REGIAO"				, "C", 03, 0}) // Regiao do Cliente
aadd(aCliente,{"A1_COND"				, "C", 03, 0}) // Condicao de Pagamento
aadd(aCliente,{"A1_RISCO"				, "C", 01, 0}) // Grau de Risco do cliente
aadd(aCliente,{"A1_LC"					, "N", 14, 2}) // Limite de Cred.do cliente
aadd(aCliente,{"A1_VENCLC"				, "D", 08, 0}) // Vencimento do Lim. Credit
aadd(aCliente,{"A1_MCOMPRA"				, "N", 17, 2}) // Maior Compra do cliente
aadd(aCliente,{"A1_METR"				, "N", 15, 2}) // M‚d.de atrasos do cliente
aadd(aCliente,{"A1_MSALDO"				, "N", 17, 2}) // Maior Saldo do cliente
aadd(aCliente,{"A1_NROCOM"				, "N", 04, 0}) // Nro de compras do cliente
aadd(aCliente,{"A1_PRICOM"				, "D", 08, 0}) // Data 1a Compra do cliente
aadd(aCliente,{"A1_ULTCOM"				, "D", 08, 0}) // Data da ultima Compra
aadd(aCliente,{"A1_ULTVIS"				, "D", 08, 0}) // Data da ultima Visita
aadd(aCliente,{"A1_NROPAG"				, "N", 04, 0}) // Nro de Pagtos do cliente
aadd(aCliente,{"A1_SALDUP"				, "N", 17, 2}) // Saldo Duplic. do cliente
aadd(aCliente,{"A1_SALPEDL"				, "N", 17, 2}) // LibSaldo Pedidos Liberados
aadd(aCliente,{"A1_ATR"					, "N", 17, 2}) // Valor dos Atrasos
aadd(aCliente,{"A1_VACUM"				, "N", 17, 2}) // Valor Acum. Vendas no Ano
aadd(aCliente,{"A1_SALPED"				, "N", 17, 2}) // Saldo de Pedidos
aadd(aCliente,{"A1_TITPROT"				, "N", 03, 0}) // Titulos Protestados
aadd(aCliente,{"A1_DTULTIT"				, "D", 08, 0}) // Data do Ult. Titulos Dev.
aadd(aCliente,{"A1_CHQDEVO"				, "N", 03, 0}) // Numero de Cheques Devolv.
aadd(aCliente,{"A1_DTULCHQ"				, "D", 08, 0}) // Dt.de Devol. Ult. Cheque
aadd(aCliente,{"A1_MATR"				, "N", 04, 0}) // Maior atraso do cliente
aadd(aCliente,{"A1_MAIDUPL"				, "N", 17, 2}) // Valor da maior Duplicata
aadd(aCliente,{"A1_TABELA"				, "C", 03, 0}) // Tabela de preco padrao do cliente
aadd(aCliente,{"A1_PAGATR"				, "N", 17, 2}) // Pag. feitos com atraso
aadd(aCliente,{"A1_RG"					, "C", 15, 0}) // Cedula de Identidade
aadd(aCliente,{"A1_DTNASC"				, "D", 08, 0}) // Data de Nascimento
aadd(aCliente,{"A1_EMAIL"				, "C", 30, 0}) // E-Mail
aadd(aCliente,{"A1_STATUS"				, "C", 01, 0}) // STATUS, N=Novo A=Alterado P=Procesado
aadd(aCliente,{"A1_FLGVIS"              , "C", 1,0 })  // Flag de Visita
aadd(aCliente,{"A1_OCO"                 , "C", 6,0 })  // 
aadd(aCliente,{"A1_CNDFIX"				, "N", 01, 0}) // Indica se o vendedor poderá alterar a Condicao de Pagamento 0 = Nao Muda 1 = Muda (Palm)
aadd(aCliente,{"A1_FORPAG"              , "C", 6,0 })  // Forma de pagamento padrao do cliente
aadd(aCliente,{"A1_GRPVEN"              , "C", 6,0 })  // Grupo de clientes vendas ( Bops 82671 )

   // Acrescentado para o Pronta Entrega
   aadd(aCliente,{"A1_GRPTRIB"              , "C", 3,0 })  // Grupo de tributacao 
   aadd(aCliente,{"A1_NATUREZ"              , "C", 3,0 })  // Forma de pagamento padrao do cliente 

PAcertaSx3(@aCliente)

aadd(aContato,{"U5_CLIENTE"     		, "C", 06, 0}) // Codigo do Cliente (Pocket)
aadd(aContato,{"U5_LOJA"       	        , "C", 02, 0}) // Loja do Cliente
aadd(aContato,{"U5_CODCON"      		, "C", 06, 0}) // Codigo do Contato
aadd(aContato,{"U5_CONTAT"       		, "C", 30, 0}) // Nome do Contato
aadd(aContato,{"U5_CPF"         	    , "C", 15, 0}) // CPF
aadd(aContato,{"U5_FUNCAO"       		, "C", 06, 0}) // Codigo do Cargo
aadd(aContato,{"U5_FONE"         		, "C", 15, 0}) // Telefone
aadd(aContato,{"U5_CELULAR"             , "C", 15,0}) //  Telefone Celular 
aadd(aContato,{"U5_EMAIL"               ,"C",  30,0}) //  E-mail 
aadd(aContato,{"U5_DTNASC"         		, "D", 08, 0}) // Data de Nascimento
aadd(aContato,{"U5_RG"         	        , "C", 15, 0}) // RG
aadd(aContato,{"U5_STATUS"    	        , "C", 01, 0}) // STATUS, N=Novo A=Alterado P=Procesado

PAcertaSx3(@aContato)

aadd(aFinanceiro,{"E1_CLIENTE"		   	, "C",  06, 0}) // Cliente (Pocket)
aadd(aFinanceiro,{"E1_LOJA"		        , "C",  02, 0}) // Loja
aadd(aFinanceiro,{"E1_NUM"		        , "C",  06, 0}) // Num Titulo
aadd(aFinanceiro,{"E1_PARCELA"	        , "C",  01, 0}) // Parcela
aadd(aFinanceiro,{"E1_TIPO"		        , "C",  03, 0}) // Tipo
aadd(aFinanceiro,{"E1_EMISSAO"		   	, "D",  08, 0}) // Emissao
aadd(aFinanceiro,{"E1_VENCTO"		   	, "D",  03, 0}) // Vencimento
aadd(aFinanceiro,{"E1_SALDO"		   	, "N",  10, 2}) // Valor

PAcertaSx3(@aFinanceiro)

aadd(aConsumo,{"F2_CLIENTE"		    	, "C",  06, 0}) // Codigo do Cliente (Pocket)
aadd(aConsumo,{"F2_LOJA"		        , "C",  02, 0}) // Loja do Cliente (Pocket)
AADD(aConsumo,{"F2_GRUPO"               , "C",  04, 0})  // Grupo 
aadd(aConsumo,{"F2_PROD"		        , "C",  15, 0}) //  Codigo do Produto
aadd(aConsumo,{"F2_ANOANT"	    	    , "N",  14, 2}) // Consumo do Mes no Ano Anterior
aadd(aConsumo,{"F2_MESANT"		    	, "N",  14, 2}) // Consumo Mes Anterior
aadd(aConsumo,{"F2_MESATU"		    	, "N",  14, 2}) // Consumo Mes Atual
aadd(aConsumo,{"F2_ULTQTD"		    	, "N",  14, 2}) // Quantidade da Ultima Compra
aadd(aConsumo,{"F2_DTULT"		    	, "D",   8, 0}) // Data da Ultima Compra
aadd(aConsumo,{"F2_VLULT"		    	, "N",  14, 2}) // Valor da Ultima Compra

//Inventario do Cliente
aadd(aInv,{"IN_CLI"   , "C", 06, 00})
aadd(aInv,{"IN_LOJA"  , "C", 02, 00})
aadd(aInv,{"IN_GRUPO" , "C", 04, 00})
aadd(aInv,{"IN_PROD"  , "C", 15, 00})
aadd(aInv,{"IN_DATA"  , "D", 08, 02})
aadd(aInv,{"IN_QTD"   , "N", 10, 02})
aadd(aInv,{"IN_PRECO" , "N", 12, 02})

// Atendimento
aadd(aTend,{"AT_COD"   ,"C",6, 0})
aadd(aTend,{"AT_DATA"  ,"C",8,0})
aadd(aTend,{"AT_CLI"   ,"C",6,0})
aadd(aTend,{"AT_LOJA"  ,"C",2,0})
aadd(aTend,{"AT_FLGVIS","C",1,0})
aadd(aTend,{"AT_STATUS","C",1,0})
aadd(aTend,{"AT_NUMPED","C",6,0})
aadd(aTend,{"AT_VALPED","N",17,2})
aadd(aTend,{"AT_QTDIT" ,"N",3,0})
aadd(aTend,{"AT_OCO"   ,"C",6,0})

PalmCreate(aCliente   ,cFileCLi,"HA1" ) 
PalmCreate(aContato   ,cFileCon,"HU5" )
PalmCreate(aFinanceiro,cFileFin,"HE1" )
PalmCreate(aConsumo   ,cFileCns,"HCN" )
PalmCreate(aInv       ,cFileInv,"HIN" )
PalmCreate(aTend      ,cFileAtm,"HAT" )

dbSelectArea("DA5")
dbSetOrder(2)
#IFDEF TOP

	lQuery    := .T.
	aStruDA5  := DA5->(dbStruct())
	aStruDA6  := DA6->(dbStruct())
	aStruDA7  := DA7->(dbStruct())	
	aStruSA1  := SA1->(dbStruct())	
	aStruSE1  := SE1->(dbStruct())	
    cAliasDA5 := "PCLIENTE"
	cAliasDA6 := "PCLIENTE"
	cAliasDA7 := "PCLIENTE"	
	cAliasSA1 := "PCLIENTE"	
	cAliasSE1 := "FINANC"	
	
    // Gera a Consulta conforme colunas do Vetor aClientes
    cColunas  := ""
    For i:=1 to Len(aCliente) - 5 // menos as cinco ultimas colunas A1_STATUS,A1_FLGVIS,A1_OCO,A1_CNDFIX,A1_FORPAG, A1_GRPVEN
	      cColunas+=aCliente[i,1] + if( i<Len(aCliente)-5,","," ")
    Next

	cQuery := "SELECT " + cColunas + ", DA5_FILIAL,DA5_VENDED,DA5_COD,DA6_FILIAL,DA6_PERCUR,DA6_ROTA,DA7_FILIAL,DA7_ROTA "
	cQuery += "FROM "+RetSqlName("DA5")+" DA5, "
	cQuery += RetSqlName("DA6")+" DA6, "
	cQuery += RetSqlName("DA7")+" DA7, "
	cQuery += RetSqlName("SA1")+" SA1 "	
	cQuery += "WHERE DA5.DA5_FILIAL='" + xFilial("DA5")+"' AND "
	cQuery += "DA5.DA5_VENDED = '"+cVendedor+"' AND "
	cQuery += "DA5.D_E_L_E_T_ = ' ' AND "
	cQuery += "DA6.DA6_FILIAL='" + xFilial("DA6")+"' AND " 
	cQuery += "DA5.DA5_COD = DA6.DA6_PERCUR AND "
	cQuery += "DA6.D_E_L_E_T_ = ' ' AND "
	cQuery += "DA7.DA7_FILIAL='" + xFilial("DA7")+"' AND "	
	cQuery += "DA6.DA6_PERCUR = DA7.DA7_PERCUR AND "
	cQuery += "DA6.DA6_ROTA = DA7.DA7_ROTA AND "
	cQuery += "DA7.D_E_L_E_T_ = ' ' AND "		
	cQuery += "SA1.A1_FILIAL='" + xFilial("SA1")+"' AND " 	
	cQuery += "DA7.DA7_CLIENT=SA1.A1_COD AND "
	cQuery += "DA7.DA7_LOJA=SA1.A1_LOJA AND "
	cQuery += "SA1.D_E_L_E_T_ = ' ' "	
	cQuery += "ORDER BY "+SqlOrder(DA5->(IndexKey()))
	

	cQuery := ChangeQuery(cQuery)
	
    Memowrit("pcliente.sql",cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA5,.T.,.T.)
	
	For nX := 1 To Len(aStruDA5)
		If aStruDA5[nX][2]<>"C" .And. FieldPos(aStruDA5[nX][1])>0
			TcSetField(cAliasDA5,aStruDA5[nX][1],aStruDA5[nX][2],aStruDA5[nX][3],aStruDA5[nX][4])
	    EndIf
	Next nX
	For nX := 1 To Len(aStruDA6)
		If aStruDA6[nX][2]<>"C" .And. FieldPos(aStruDA6[nX][1])>0
			TcSetField(cAliasDA6,aStruDA6[nX][1],aStruDA6[nX][2],aStruDA6[nX][3],aStruDA6[nX][4])
	    EndIf
	Next nX
	For nX := 1 To Len(aStruDA7)
		If aStruDA7[nX][2]<>"C" .And. FieldPos(aStruDA7[nX][1])>0
			TcSetField(cAliasDA7,aStruDA7[nX][1],aStruDA7[nX][2],aStruDA7[nX][3],aStruDA7[nX][4])
	    EndIf
	Next nX
	For nX := 1 To Len(aStruSA1)
		If aStruSA1[nX][2]<>"C" .And. FieldPos(aStruSA1[nX][1])>0
			TcSetField(cAliasSA1,aStruSA1[nX][1],aStruSA1[nX][2],aStruSA1[nX][3],aStruSA1[nX][4])
	    EndIf
	Next nX		

#ELSE
    cAliasDA5 := "DA5"
	cAliasDA6 := "DA6"
	cAliasDA7 := "DA7"	
	cAliasSA1 := "SA1"	
	cAliasSE1 := "SE1"	

	dbSeek(xFilial("DA5")+cVendedor, .t.)
#ENDIF
dbSelectArea(cAliasDA5)
While !Eof() .and. (cAliasDA5)->DA5_FILIAL= xFilial("DA5") .and. (cAliasDA5)->DA5_VENDED = cVendedor
	cPercurso := (cAliasDA5)->DA5_COD
	dbSelectArea("DA6")
	dbSetOrder(1)
	If !lQuery
		dbSeek(xFilial("DA6")+cPercurso)
	EndIf
	While !Eof() .and. (cAliasDA6)->DA6_FILIAL= xFilial("DA6") .and. (cAliasDA6)->DA6_PERCUR = cPercurso
		cRota := (cAliasDA6)->DA6_ROTA
		dbSelectArea("DA7")
		dbSetOrder(1)
		If !lQuery
			dbSeek(xFilial("DA6")+cPercurso+cRota)
		EndIf

		While !Eof() .and. (cAliasDA7)->DA7_FILIAL= xFilial("DA7") .and. (cAliasDA7)->DA7_ROTA = cRota
			dbSelectArea("SA1")
			dbSetOrder(1)
			If !lQuery
				dbSeek(xFilial("SA1")+(cAliasDA7)->DA7_CLIENT+(cAliasDA7)->DA7_LOJA)
			EndIf
			If ((ExistBlock("PLMCLI01")))
				lOkCli := ExecBlock("PLMCLI01",.F.,.F.)
				If !lOkCli
					dbSelectArea(cAliasSA1)
				    dbSkip()
				    Loop
				 EndIf
			EndIf
			RecLock("HA1",.T.)			
			For i:=1 to Len(aCliente)
				dbSelectArea("HA1")
		    	If aCliente[i,1] = "A1_COD"
					Replace &("HA1->"+aCliente[i,1]) With (cAliasSA1)->A1_COD + (cAliasSA1)->A1_LOJA
		    	ElseIf aCliente[i,1] = "A1_CONPROD"
		   			Replace &("HA1->"+aCliente[i,1]) With nConProd
		    	ElseIf aCliente[i,1] = "STATUSCLI"
		     		Replace &("HA1->"+aCliente[i,1]) With "P"
				ElseIf aCliente[i,1] = "A1_CNDFIX"
   					If (cAliasSA1)->(FieldPos("A1_CNDFIX")) <> 0
						nCndFix := If((cAliasSA1)->A1_CNDFIX=="1",0,1)
				  	EndIf
					FieldPut( HA1->(FieldPos(aCliente[i,1])), nCndFix )
				ElseIf aCliente[i,1] = "A1_FORPAG"
					If (cAliasSA1)->(FieldPos("A1_FORPAG")) <> 0
						Replace &("HA1->"+aCliente[i,1]) With (cAliasSA1)->A1_FORPAG
				  	EndIf					
				ElseIf aCliente[i,1] = "A1_STATUS"
					FieldPut( HA1->(FieldPos(aCliente[i,1])), "P" )     							
				ElseIf aCliente[i,1] = "A1_FLGVIS"
					FieldPut( HA1->(FieldPos(aCliente[i,1])), "" )     							
				ElseIf aCliente[i,1] = "A1_OCO"
					FieldPut( HA1->(FieldPos(aCliente[i,1])), "" )     							
				ElseIf aCliente[i,1] = "A1_CDPAG"
       				FieldPut( HA1->(FieldPos(aCliente[i,1])), (cAliasSA1)->A1_CODPAG )
			    Else
					FieldPut( HA1->(FieldPos(aCliente[i,1])), (cAliasSA1)->(FieldGet(FieldPos(aCliente[i,1]))) )
				EndIf
			Next
			HA1->(MsUnlock())
			//  *** Grava Arquivo de Contatos ***
			dbSelectArea("SU5")
			dbSetOrder(2) 
			dbSeek(xFilial("SU5")+(cAliasSA1)->A1_COD+(cAliasSA1)->A1_LOJA)				
			While !Eof() .And. SU5->U5_FILIAL == xFilial("SU5") .And. SU5->U5_CLIENTE == (cAliasSA1)->A1_COD .And. SU5->U5_LOJA == (cAliasSA1)->A1_LOJA
				If SU5->U5_ATIVO == "1" 
					dbSelectArea("HU5")
		 			RecLock("HU5",.T.)
		   			For i:=1 to Len(aContato)		
						If aContato[i,1] = "U5_RG"
							Replace &("HU5->"+aContato[i,1]) With ""
		                ElseIf aContato[i,1] = "U5_CLIENTE" 					
		                    Replace &(aContato[i,1]) With SU5->U5_CLIENTE
		                ElseIf aContato[i,1] = "U5_LOJA" 					
		                    Replace &(aContato[i,1]) With SU5->U5_LOJA
						ElseIf aContato[i,1] = "U5_CODCON"
		                    Replace &(aContato[i,1]) With SU5->U5_CODCONT
						ElseIf aContato[i,1] = "U5_DTNASC" 
							Replace &("HU5->"+aContato[i,1]) With CtoD("  /  /  ")
						ElseIf aContato[i,1] = "U5_TIME"
							Replace &("HU5->"+aContato[i,1]) With ""
						ElseIf aContato[i,1] = "U5_REVISTA"
							Replace &("HU5->"+aContato[i,1]) With ""
						ElseIf aContato[i,1] = "U5_ESP"
							Replace &("HU5->"+aContato[i,1]) With ""
						ElseIf aContato[i,1] = "U5_STATUS"
							Replace &("HU5->"+aContato[i,1]) With "P"
						Else
				   	    	Replace &("HU5->"+aContato[i,1]) With &("SU5->"+aContato[i,1])
						EndIf
					Next
					HU5->(MsUnlock())
				EndIf
				dbSelectArea("SU5")
				dbSkip()
			EndDo
			// Grava Titulos em Aberto
			#IFDEF TOP
				 
				// Query para o Arquivo de Titulos
				cQuerySE1 := "SELECT E1_CLIENTE,E1_LOJA,E1_TIPO,E1_EMISSAO,E1_VENCTO,E1_SALDO,E1_NUM,E1_PARCELA "
				cQuerySE1 += "FROM "+RetSqlName("SE1")+" SE1 "
				cQuerySE1 += "WHERE SE1.E1_FILIAL='" + xFilial("SE1") + "' AND "
				cQuerySE1 += "SE1.E1_CLIENTE ='" + (cAliasSA1)->(A1_COD) + "' AND "
				cQuerySE1 += "SE1.E1_LOJA ='" + (cAliasSA1)->(A1_LOJA) + "' AND "
				cQuerySE1 += "SE1.E1_SALDO > 0 AND "
				cQuerySE1 += "SE1.E1_VEND1 = '" + cVendedor + "' AND " 
				cQuerySE1 += "SE1.D_E_L_E_T_ = ' ' "
				cQuerySE1 += "ORDER BY " + SqlOrder(SE1->(IndexKey()))

				cQuerySE1 := ChangeQuery(cQuerySE1)
						
				Memowrit("Titulos.sql",cQuerySE1)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySE1),cAliasSE1,.T.,.T.)
		
				For nX := 1 To Len(aStruSE1)
					If aStruSE1[nX][2]<>"C" .And. (cAliasSE1)->(FieldPos(aStruSE1[nX][1])>0)
						TcSetField(cAliasSE1,aStruSE1[nX][1],aStruSE1[nX][2],aStruSE1[nX][3],aStruSE1[nX][4])
				    EndIf
				Next nX
				
			#ELSE
				dbSelectArea(cAliasSE1)
				dbSetOrder(2) 
				cFiltroSE1 := "E1_CLIENTE = '" + SA1->A1_COD + "' .And. E1_LOJA = '" + SA1->A1_LOJA + "' .And. E1_VEND1 = '" + cVendedor + "' .And. E1_SALDO > 0"
				Set Filter To &cFiltroSE1
			#ENDIF
				
			dbGoTop()
			nQtdSE1 := 0
			While !(cAliasSE1)->(Eof())
				// Ponto de Entrada PLMFIN01 - Indica se um Titulo sera exportado, retorno deve ser .T. ou .F.
				If ((ExistBlock("PLMFIN01")))
					lOkFin := ExecBlock("PLMFIN01",.F.,.F.)
					If !lOkFin
						dbSelectArea(cAliasSE1)
					    dbSkip()
				    	Loop
					EndIf
		    	EndIf
				
				dbSelectArea("HE1")
				RecLock("HE1",.T.)
		    	For i := 1 To Len(aFinanceiro)
		    		If aFinanceiro[i,1] = "E1_LOJA" 
			    		FieldPut( HE1->(FieldPos(aFinanceiro[i,1])), (cAliasSE1)->E1_LOJA )																					
			    	Elseif  aFinanceiro[i,1] = "E1_CLIENTE"	
			    	    FieldPut( HE1->(FieldPos(aFinanceiro[i,1])), (cAliasSE1)->E1_CLIENTE )																					
					Else
					 	FieldPut( HE1->(FieldPos(aFinanceiro[i,1])), (cAliasSE1)->(FieldGet(FieldPos(aFinanceiro[i,1]))) )	
					EndIf
		    	Next
		    	HE1->(MsUnlock())
		    	dbSelectArea(cAliasSE1)
		    	dbSkip()
				nQtdSE1 += 1
		   	EndDo
			If lQuery
				(cAliasSE1)->(dbCloseArea())
			Else
				Set Filter To
			EndIf
			// Gera Array de COnsumo
	        IF cConsumoSN=="S" 
				PCliCOMS((cAliasSA1)->A1_COD, (cAliasSA1)->A1_LOJA, @aCons)
 			Endif   
			
			// Grava Consumo
			For i := 1 To Len(aCons)
				dbSelectArea("HCN")
				RecLock("HCN",.T.)
				HCN->F2_CLIENTE := (cAliasSA1)->A1_COD 
				HCN->F2_LOJA	:= (cAliasSA1)->A1_LOJA
				HCN->F2_PROD   := aCons[i,1]
				HCN->F2_ANOANT := aCons[i,2]
				HCN->F2_MESANT := aCons[i,3]
				HCN->F2_MESATU := aCons[i,4]
				HCN->(MsUnlock())
			Next
			aCons := {}
			// EndIf  - fim do if a_dtcanc 
			dbSelectArea(cAliasDA7)
			dbSkip()
		EndDo

		If !lQuery
			dbSelectArea(cAliasDA6)
			dbSkip()
		EndIf
	EndDo

	If !lQuery
		dbSelectArea(cAliasDA5)
		dbSkip()
	EndIf
EndDo
If lQuery
	dbSelectArea(cAliasDA5)
	dbCloseArea()
	dbSelectArea("DA5")
EndIf

HA1->(dbCloseArea())
HU5->(dbCloseArea())
HE1->(dbCloseArea())
HCN->(dbCloseArea()) 
HIN->(dbCloseArea()) 
HAT->(dbCloseArea()) 

Return

//retorna alias usados pelo servico
User Function PCliTabO( )
Return {"SA1","SU5","SE1","SF2","SD2","SB1","DA5","DA6","DA7"}

//retorna nome fisico do arquivo espelho
User Function PCliArqO( )          
Local cFileCli:="HA1" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFileCon:="HU5" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFileFin:="HE1" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFileCns:="HCN" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFileInv:="HIN" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Local cFileAtm:="HAT" + Left(PALMSERV->P_EMPFI,2) + "0" //+(PSALIAS)->P_EMPFI  
Return {cFileCli,cFileCon,cFileFin,cFileCns,cFileInv,cFileAtm}

//retorna indice usado pelo arquivo espelho
User Function PCliIndO( )
Return {"A1_COD+A1_LOJA","U5_CLIENTE+U5_LOJA+U5_CODCON",;
        "E1_CLIENTE+E1_LOJA+E1_NUM+E1_PARCELA+E1_TIPO",;
        "F2_CLIENTE+F2_LOJA+F2_PROD","IN_PROD+IN_CLI+IN_LOJA",;
        "AT_DATA+AT_STATUS+AT_NUMPED"}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PCliCOms   ³ Autor ³ Fabio Garbin        ³ Data ³ 21/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Calcula o consumo do Mes no ano anterior, do mes anterior  ³±±
±±³          | no ano corrente e do mes atual, para cada cliente          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PCliente                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ M.Vieira   ³11.11.01³ Substituicao de macros pela funcao FieldPut()   ³±±
±±|            |        | FieldGet() para ficar mais rapida gravacao      ³±±
±±ÀÄÄÄ--ÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PCliCOms(cCodCli, cLoja, aCons)

Local dData    := dDatabase
Local cMes     := StrZero(Month(dData),2,0)
Local cMesAnt  := If(cMes="1", "12", StrZero(Val(cMes) - 1,2,0))
Local cAno     := Str(Year(dData),4,0)
Local cAnoAnt  := Str(Val(cAno) - 1,4,0)
Local cGrpProd := "" 
Local nPos     := 0
Local lQuery   := .F.

#IFNDEF TOP
 Local nInt     := 0
#ENDIF 


#IFDEF TOP
    Local nX
    
	lQuery := .T.
    
	aStruSD2 := SD2->(dbStruct())
	cAliasATU := "CONSATU"
	cAliasANT := "CONSANT"
	cAliasANO := "CONSANO"

	// Consumo do Mes Atual	
	cQueryAtu := "SELECT SD2.D2_COD, SUM(SD2.D2_QUANT) ATUAL" 
	cQueryAtu += "FROM " + RetSqlName("SD2") + " SD2 ," + RetSqlName("SF2") + " SF2 "
	cQueryAtu += "WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND "
	cQueryAtu += "SD2.D2_EMISSAO >= '"  + cAno + cMes + "01" + "' AND " 
    cQueryAtu += "SD2.D2_EMISSAO <= '" + cAno + cMes + "31" + "' AND "
    cQueryAtu += "SF2.F2_CLIENTE = '" + cCodCli + "' AND SF2.F2_LOJA = '" + cLoja + "' AND "
    cQueryAtu += "SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND "
 	cQueryAtu += "SD2.D_E_L_E_T_ <> '*' AND SF2.D_E_L_E_T_ <> '*' "
    cQueryAtu += "GROUP BY SD2.D2_COD"

	cQueryAtu := ChangeQuery(cQueryAtu)
	Memowrite("HHAtuOMS.txt", cQueryAtu)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryAtu),cAliasAtu,.T.,.T.)

	// Consumo do Mes Anterior
	cQueryAnt := "SELECT SD2.D2_COD, SUM(SD2.D2_QUANT) ANTERIOR" 
	cQueryAnt += "FROM " + RetSqlName("SD2") + " SD2 ," + RetSqlName("SF2") + " SF2 "
	cQueryAnt += "WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND "
	cQueryAnt += "SD2.D2_EMISSAO >= '"  + cAno + cMesAnt + "01" + "' AND " 
    cQueryAnt += "SD2.D2_EMISSAO <= '" + cAno + cMesAnt + "31" + "' AND "
    cQueryAnt += "SF2.F2_CLIENTE = '" + cCodCli + "' AND SF2.F2_LOJA = '" + cLoja + "' AND "
    cQueryAnt += "SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND "
 	cQueryAnt += "SD2.D_E_L_E_T_ <> '*' AND SF2.D_E_L_E_T_ <> '*' "
    cQueryAnt += "GROUP BY SD2.D2_COD"

	cQueryAnt := ChangeQuery(cQueryAnt)	
	Memowrite("HHAntOMS.txt", cQueryAnt)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryAnt),cAliasAnt,.T.,.T.)

	// Consumo do Mes Corrente Ano Anterior
	cQueryAno := "SELECT SD2.D2_COD, SUM(SD2.D2_QUANT) ANOANT" 
	cQueryAno += "FROM " + RetSqlName("SD2") + " SD2 ," + RetSqlName("SF2") + " SF2 "
	cQueryAno += "WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND "
	cQueryAno += "SD2.D2_EMISSAO >= '"  + cAnoAnt + cMes + "01" + "' AND " 
    cQueryAno += "SD2.D2_EMISSAO <= '" + cAnoAnt + cMes + "31" + "' AND "
    cQueryAno += "SF2.F2_CLIENTE = '" + cCodCli + "' AND SF2.F2_LOJA = '" + cLoja + "' AND "
    cQueryAno += "SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND "
 	cQueryAno += "SD2.D_E_L_E_T_ <> '*' AND SF2.D_E_L_E_T_ <> '*' " 
    cQueryAno += "GROUP BY SD2.D2_COD"

	cQueryAno := ChangeQuery(cQueryAno)	
	Memowrite("HHAnoOMS.txt", cQueryAno)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryAno),cAliasAno,.T.,.T.)
	For nX := 1 To Len(aStruSD2)
		If aStruSD2[nX][2]<>"C" .And. (cAliasATU)->(FieldPos(aStruSD2[nX][1])>0)
			TcSetField(cAliasATU,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
	    EndIf
		If aStruSD2[nX][2]<>"C" .And. (cAliasANT)->(FieldPos(aStruSD2[nX][1])>0)
			TcSetField(cAliasANT,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
	    EndIf
		If aStruSD2[nX][2]<>"C" .And. (cAliasANO)->(FieldPos(aStruSD2[nX][1])>0)
			TcSetField(cAliasANO,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
	    EndIf
	Next nX

	//Consumo mes atual    
	dbSelectArea(cAliasATU)
	While !(cAliasAtu)->(Eof())  
        SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + (cAliasATU)->D2_COD))
		cGrpProd := SB1->B1_GRUPO + SB1->B1_COD
		nPos := aScan(aCons, { |x| x[1] == cGrpProd })
		If nPos = 0
			aadd(aCons,{cGrpProd, 0, 0, (cAliasATU)->ATUAL})
			nPos := aScan(aCons, { |x| x[1] == cGrpProd })
		EndIf
		dbSelectArea(cAliasATU)
		dbSkip()
	EndDo

	//Consumo mes anterior
	dbSelectArea(cAliasANT)
	While !(cAliasANT)->(Eof())
        SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + (cAliasANT)->D2_COD))
		cGrpProd := SB1->B1_GRUPO + SB1->B1_COD
		nPos := aScan(aCons, { |x| x[1] == cGrpProd })
		If nPos = 0
			aadd(aCons,{cGrpProd, 0, (cAliasANT)->ANTERIOR, 0})
			nPos := aScan(aCons, { |x| x[1] == cGrpProd })
		Else
			aCons[nPos, 3] :=(cAliasANT)->ANTERIOR
		EndIf
		dbSelectArea(cAliasANT)
		dbSkip()
	EndDo

	//Consumo ano anterior
	dbSelectArea(cAliasANO)
	While !(cAliasANO)->(Eof())
        SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + (cAliasANO)->D2_COD))
		cGrpProd := SB1->B1_GRUPO + SB1->B1_COD
		nPos := aScan(aCons, { |x| x[1] == cGrpProd })
		If nPos = 0
			aadd(aCons,{cGrpProd, (cAliasANO)->ANOANT, 0, 0})
			nPos := aScan(aCons, { |x| x[1] == cGrpProd })
		Else
			aCons[nPos, 2] :=(cAliasANO)->ANOANT
		EndIf
		dbSelectArea(cAliasANO)
		dbSkip()
	EndDo

#ELSE
	dbSelectArea("SF2")
	dbSetOrder(2)
	dbSeek(xFilial("SF2") + cCodCli)
	While !Eof() .And. SF2->F2_CLIENTE = cCodCLi
		If SF2->F2_EMISSAO >= CtoD("01/" + cMesAnt + "/" + cAnoAnt) .And.;  // Mes do Ano Anterior
		   SF2->F2_EMISSAO <= CtoD("31/" + cMesAnt + "/" + cAnoAnt)
		   nInt := 2
		EndIf
		If SF2->F2_EMISSAO >= CtoD("01/" + cMesAnt + "/" + cAno) .And.;  // Mes Anterior
		   SF2->F2_EMISSAO <= CtoD("31/" + cMesAnt + "/" + cAno)
		   nInt := 3
		EndIf
		If SF2->F2_EMISSAO >= CtoD("01/" + cMes + "/" + cAno) .And.;  // Mes Atual
		   SF2->F2_EMISSAO <= dData
		   nInt := 4
		EndIf
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)
		While !Eof() .And. SD2->D2_DOC == SF2->F2_DOC .ANd. nInt <> 0
	        SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + SD2->D2_COD))
			cGrpProd := SB1->B1_GRUPO + SB1->B1_COD
			nPos := aScan(aCons, { |x| x[1] == cGrpProd })
			If nPos = 0
				aadd(aCons,{cGrpProd, 0, 0, 0})
				nPos := aScan(aCons, { |x| x[1] == cGrpProd })
			EndIf
			aCons[nPos,nInt] += SD2->D2_QUANT
			dbSelectArea("SD2")	
			dbSkip()
		EndDo
		nInt := 0
		dbSelectArea("SF2")	
		dbSkip()
	EndDo

#ENDIF

If lQuery
	(cAliasATU)->(dbCloseArea())
	(cAliasANT)->(dbCloseArea())	
	(cAliasANO)->(dbCloseArea())	
EndIf

Return aCons

// AQUI ROTINAS DE EXPORTACAO PARA O MERCHANDISING

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PPesquisa³ Autor ³ Fabio Garbin          ³ Data ³ 26/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo de Pesquisas.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PPesquisa()
LOCAL aPesqI:={}, aPesqII:={}, aPesqIII:={}, aPesqIV:={}, aPesqV:={}, aPesqVI:={}, aPesqVII := {}
LOCAL cPesqI:=   "HUO"+ cEmpAnt + "0"
LOCAL cPesqII:=  "HUW"+ cEmpAnt + "0"
LOCAL cPesqIII:= "HUZ"+ cEmpAnt + "0"
LOCAL cPesqIV:=  "HUP"+ cEmpAnt + "0"
LOCAL cPesqV:=   "HUC"+ cEmpAnt + "0"
LOCAL cPesqVI:=  "HUK"+ cEmpAnt + "0"     
Local cPesqVII := "HRP" + cEmpAnt + "0"     
LOCAL aScript:={}
LOCAL cFiltro := ""

AADD(aPesqI, { "UO_CODCAMP", "C", 6  , 0 } )
AADD(aPesqI, { "UO_DESC"   , "C", 40 , 0 } )
AADD(aPesqI, { "UO_OBJETIV", "C", 255, 0 } )
AADD(aPesqI, { "UO_PUBALVO", "C", 6  , 0 } )
AADD(aPesqI, { "UO_DTINI"  , "D", 8  , 0 } )
AADD(aPesqI, { "UO_DTFIM"  , "D", 8  , 0 } )
AADD(aPesqI, { "UO_META"   , "N", 9  , 0 } )
AADD(aPesqI, { "UO_EFE"    , "N", 6  , 0 } )
AADD(aPesqI, { "UO_EFEDIA" , "N", 6  , 0 } )
AADD(aPesqI, { "UO_DTULTPQ", "D", 8  , 0 } )

AADD(aPesqII, { "UW_CODEVE" , "C", 6 , 0 } )
AADD(aPesqII, { "UW_DESCEVE", "C", 30, 0 } )
AADD(aPesqII, { "UW_CODCAMP", "C", 6 , 0 } )
AADD(aPesqII, { "UW_CODSCRI", "C", 6 , 0 } )
AADD(aPesqII, { "UW_PRODUTO", "C", 15, 0 } )
AADD(aPesqII, { "UW_MIDIA"  , "C", 6 , 0 } )

AADD(aPesqIII, { "UZ_CODSCRI", "C", 6 , 0 } )
AADD(aPesqIII, { "UZ_DESC"   , "C", 40, 0 } )
AADD(aPesqIII, { "UZ_TEMPO"  , "C", 5 , 0 } )
AADD(aPesqIII, { "UZ_TIPO"   , "C", 1 , 0 } )
AADD(aPesqIII, { "UZ_FORMATO", "C", 1 , 0 } )
AADD(aPesqIII, { "UZ_ARMRESP", "C", 1 , 0 } )
AADD(aPesqIII, { "UZ_SCORMIN", "N", 6 , 0 } )
AADD(aPesqIII, { "UZ_SCORMAX", "N", 6 , 0 } )

AADD(aPesqIV, { "UP_CODSCRI", "C", 6  , 0 } )
AADD(aPesqIV, { "UP_CODPERG", "C", 7  , 0 } )
AADD(aPesqIV, { "UP_DESC"   , "C", 255, 0 } )
AADD(aPesqIV, { "UP_SCORE"  , "N", 6  , 0 } )
AADD(aPesqIV, { "UP_OBS"    , "C", 60 , 0 } )
AADD(aPesqIV, { "UP_CODOBS" , "C", 6  , 0 } )
AADD(aPesqIV, { "UP_IDTREE" , "C", 7  , 0 } )
AADD(aPesqIV, { "UP_TIPOOBJ", "C", 1  , 0 } )

AADD(aPesqV, { "UC_CODIGO" , "C", 6, 0 } )
AADD(aPesqV, { "UC_IDRESP" , "C", 6, 0 } )
AADD(aPesqV, { "UC_CODCAMP", "C", 6, 0 } )
AADD(aPesqV, { "UC_CLIENTE", "C", 6, 0 } )
AADD(aPesqV, { "UC_LOJA"   , "C", 2, 0 } )
AADD(aPesqV, { "UC_CODCONT", "C", 6, 0 } )
AADD(aPesqV, { "UC_DATA"   , "D", 8, 0 } )
AADD(aPesqV, { "UC_INICIO" , "C", 8, 0 } )
AADD(aPesqV, { "UC_FIM"    , "C", 8, 0 } )
AADD(aPesqV, { "UC_STATUS" , "C", 1, 0 } )

AADD(aPesqVI, { "UK_CODIGO" , "C", 6 , 0 } )
AADD(aPesqVI, { "UK_ITEM"   , "C", 3 , 0 } )
AADD(aPesqVI, { "UK_CODSCRI", "C", 6 , 0 } )
AADD(aPesqVI, { "UK_CODPERG", "C", 7 , 0 } )
AADD(aPesqVI, { "UK_CODRESP", "C", 7 , 0 } )
AADD(aPesqVI, { "UK_RESMEMO", "C", 90, 0 } )
AADD(aPesqVI, { "UK_SCORE"  , "N", 6 , 0 } )

AADD(aPesqVII, { "RP_IDRESP", "C", 6, 0 } )
AADD(aPesqVII, { "RP_CLIENTE", "C", 6, 0 } )
AADD(aPesqVII, { "RP_LOJA", "C", 2, 0 } )
AADD(aPesqVII, { "RP_CONTAT", "C", 6, 0 } )
AADD(aPesqVII, { "RP_CODSCRI", "C", 6, 0 } )
AADD(aPesqVII, { "RP_STATUS", "C", 1, 0 } )

ConOut("PALMJOB: Criando arquivo de Pesquisa. Tabelas para " + Trim(PALMUSER->P_USER) + " - " + Time())

PalmCreate(aPesqI  ,cPesqI  ,"PESKI")
PalmCreate(aPesqII ,cPesqII ,"PESKII")
PalmCreate(aPesqIII,cPesqIII,"PESKIII")
PalmCreate(aPesqIV ,cPesqIV ,"PESKIV")
PalmCreate(aPesqV  ,cPesqV  ,"PESKV")
PalmCreate(aPesqVI ,cPesqVI ,"PESKVI")
PalmCreate(aPesqVII ,cPesqVII ,"PESKVII")

dbSelectArea("SUO")
cFiltro := "UO_FILIAL='"+xFilial("SUO")+"'"//+"'+UO_PALM='1'" 
Set Filter to &cFiltro
Do While SUO->(!EOF())
   If SUO->UO_FILIAL == xFilial("SUO") .AND. SUO->UO_PALM == "1" 
      dbSelectArea("PESKI")
      RecLock("PESKI", .T.)
      PESKI->UO_CODCAMP := SUO->UO_CODCAMP
      PESKI->UO_DESC    := SUO->UO_DESC
      PESKI->UO_OBJETIV := SUO->UO_OBJETIV
      PESKI->UO_PUBALVO := SUO->UO_PUBALVO
      PESKI->UO_DTINI   := SUO->UO_DTINI
      PESKI->UO_DTFIM   := SUO->UO_DTFIM
      PESKI->UO_META    := SUO->UO_META
      PESKI->UO_EFE     := 0
      PESKI->UO_EFEDIA  := 0
      PESKI->(MsUnLock())
      dbSelectArea("SUW")
      dbSetOrder(1) //UW_FILIAL+UW_CODCAMP+UW_CODSCRI
      dbSeek(xFilial("SUW")+SUO->UO_CODCAMP)
      While SUW->(!EOF())
            If SUW->UW_FILIAL == xFilial("SUW") .AND. SUW->UW_CODCAMP == SUO->UO_CODCAMP
               If ASCAN(aScript, SUW->UW_CODSCRI) == 0
                  Aadd(aScript, SUW->UW_CODSCRI)
                  dbSelectArea("PESKII")
                  RecLock("PESKII", .T.)
                  PESKII->UW_CODEVE  := SUW->UW_CODEVE
                  PESKII->UW_DESCEVE := SUW->UW_DESCEVE
                  PESKII->UW_CODCAMP := SUW->UW_CODCAMP
                  PESKII->UW_CODSCRI := SUW->UW_CODSCRI
                  PESKII->UW_PRODUTO := SUW->UW_PRODUTO
                  PESKII->UW_MIDIA   := SUW->UW_MIDIA
                  PESKII->(MsUnLock())
                  dbSelectArea("SUZ")
                  dbSetOrder(1) //UZ_FILIAL+UZ_CODSCRI
                  dbSeek(xFilial("SUZ")+SUW->UW_CODSCRI)
                  While SUZ->(!EOF())
                        If SUZ->UZ_FILIAL == xFilial("SUZ") .AND. SUZ->UZ_CODSCRI == SUW->UW_CODSCRI
                           dbSelectArea("PESKIII")
                           RecLock("PESKIII", .T.)
                           PESKIII->UZ_CODSCRI := SUZ->UZ_CODSCRI
                           PESKIII->UZ_DESC    := SUZ->UZ_DESC
                           PESKIII->UZ_TEMPO   := SUZ->UZ_TEMPO
                           PESKIII->UZ_TIPO    := SUZ->UZ_TIPO
                           PESKIII->UZ_FORMATO := SUZ->UZ_FORMATO
                           PESKIII->UZ_ARMRESP := SUZ->UZ_ARMRESP
                           PESKIII->UZ_SCORMIN := SUZ->UZ_SCORMIN
                           PESKIII->UZ_SCORMAX := SUZ->UZ_SCORMAX
                           PESKIII->(MsUnLock())
                           dbSelectArea("SUP")
                           dbSetOrder(1) //UP_FILIAL+UP_CODCAMP+UP_IDTREE+UP_CARGO
                           dbSeek(xFilial("SUP")+SUZ->UZ_CODSCRI)
                           While SUP->(!EOF())
                                 If SUP->UP_FILIAL == xFilial("SUP") .AND. SUP->UP_CODCAMP == SUZ->UZ_CODSCRI
                                    dbSelectArea("PESKIV")
                                    RecLock("PESKIV", .T.)
                                    PESKIV->UP_CODSCRI := SUP->UP_CODCAMP
                                    PESKIV->UP_CODPERG := SUP->UP_CARGO
                                    PESKIV->UP_DESC    := SUP->UP_DESC
                                    PESKIV->UP_SCORE   := SUP->UP_SCORE
                          	        PESKIV->UP_OBS     := MSMM(SUP->UP_CODOBS,TamSX3("UP_OBS")[1])
                                    PESKIV->UP_CODOBS  := SUP->UP_CODOBS
                                    PESKIV->UP_IDTREE  := SUP->UP_IDTREE
                                    PESKIV->UP_TIPOOBJ := SUP->UP_TIPOOBJ
                                    PESKIV->(MsUnLock())
                                 EndIf
                                 SUP->(dbSkip())
                           EndDo
                        EndIf
                        SUZ->(dbSkip())
                  EndDo      
               EndIf
            EndIf   
           SUW->(dbSkip())
      EndDo          
   EndIf    
   SUO->(dbSkip())
EndDo

PESKI->(dbCloseArea())
PESKII->(dbCloseArea())
PESKIII->(dbCloseArea())
PESKIV->(dbCloseArea())
PESKV->(dbCloseArea())
PESKVI->(dbCloseArea())      
PESKVII->(dbCloseArea())      

Return NIL

//retorna alias usados pelo servico
User Function PPsqTab( )
Return {"SUO","SUW","SUZ","SUP","SUC","SUK"}

//retorna nome fisico do arquivo espelho
User Function PPsqArq( )
Local cFPesI   := "HUO" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFPesII  := "HUW" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFPesIII := "HUZ" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFPesIV  := "HUP" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFPesV   := "HUC" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFPesVI  := "HUK" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFPesVII  := "HRP" + Left(PALMSERV->P_EMPFI,2) + "0"
Return {cFPesI,cFPesII,cFPesIII,cFPesIV,cFPesV,cFPesVI,cFPesVII}

//retorna indice usado pelo arquivo espelho
User Function PPsqInd( )
cKPesI   := "UO_CODCAMP"
cKPesII  := "UW_CODCAMP+UW_CODSCRI"
cKPesIII := "UZ_CODSCRI"
cKPesIV  := "UP_CODSCRI+UP_CODPERG"
cKPesV   := "UC_CODIGO"
cKPesVI  := "UK_CODIGO+UK_ITEM"
cKPesVII := "RP_IDRESP"
Return {cKPesI,cKPesII,cKPesIII,cKPesIV,cKPesV,cKPesVI,cKPesVII}
