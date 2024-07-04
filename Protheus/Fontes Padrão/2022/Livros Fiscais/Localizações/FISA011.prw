#Include "Protheus.ch"
#Include "FISA011.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FISA011  ºAutor  ³Denis F. Tofoli     º Data ³ 25/08/2009   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Apuração de impostos (Selo / Consumo / Empreitadas)         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaFis - Localizacao Angola                                º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±³Programador ³ Data     ³ BOPS     ³ Motivo da Alteracao                º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±³Alf. Medrano³02/01/17  ³SERINN001-537³creación de tablas temporales se º±±
±±³            ³          ³          ³asigna FWTemporaryTable en funcion  º±±
±±³            ³          ³          ³ApuraImp                            º±±
±±³Alf. Medrano³17/01/17  ³SERINN001-537³Merge Main vs 12.1.15            º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISA011
	Local cxCadastro := STR0001 //"Apuração de impostos"
	Local aSays      := {}
	Local aButtons   := {}
	Local nxOpc      := 0
	Local lPerg      := .F.
	Local i,j            
	Private cPerg      := "FISA011"

	aAdd(aSays,STR0002) //"Esta rotina tem a finalidade de efetuar a apuração dos impostos calculados pelo sistema:"
	aAdd(aSays,STR0003) //"Imposto de Selo, Imposto de Consumo e Imposto de Empreitadas (Lei 07/97)"
	aAdd(aSays,STR0004) //""
	aAdd(aSays," ")
	aAdd(aSays,STR0005) //"Após a apuração, será possivel imprimir as informações geradas, nos formatos sintético"
	aAdd(aSays,STR0006) //"e analitico"

	aAdd(aButtons,{5,.T.,{ || lPerg := Pergunte(cPerg,.T.) }})
	aAdd(aButtons,{1,.T.,{ || nxOpc := 1,FechaBatch()      }})
	aAdd(aButtons,{2,.T.,{ || nxOpc := 0,FechaBatch()      }})
	FormBatch(cxCadastro,aSays,aButtons)

	If nxOpc == 1
		If !lPerg
			lPerg := Pergunte(cPerg,.T.)
		Endif

		If lPerg
			ApuraImp()
		Endif
	Endif
Return nil

Static Function ApuraImp()
	Local   aTipImp    := {STR0007,STR0008,STR0009} //"Imposto de selo"###"Imposto de consumo"###"Imposto de empreitadas"
	Local   aMvForDias := {"MV_JURSEL" ,"MV_JURCON" ,"MV_JUREMP" } // Formula para calcular dias de atraso
	Local   aMvTxJur   := {"MV_TXJUSEL","MV_TXJUCON","MV_TXJUEMP"} // Taxa de Juros por atraso
	Local   aMvForMult := {"MV_MULSEL" ,"MV_MULCON" ,"MV_MULEMP" } // Formula para calculo da multa
	Local   aMvTxMul   := {"MV_TXMUSEL","MV_TXMUCON","MV_TXMUEMP"} // Taxa de Multa por atraso
	Local   cNomTmpImp := ""
	Local   cNomTmpDoc := ""
	Local   aEstru     := {}
	Local   aExtArq    := {"SE","CO","EM"}
	Local   nGetDOpc   := 2
	Local   lExclTit   := .T.
	Private cImpDesc   := aTipImp[mv_par01]
	Private cAliasTmp  := ""
	Private cAliasDoc  := ""
	Private aHeaderImp := {}
	Private aColsImp   := {}
	Private aHeaderDoc := {}
	Private aColsDoc   := {}
	Private aAlter     := {"TXJUR","VLJUR","MULTA","VLMULT","CUSTAS","VLCUST"}
	Private nTotImp    := 0
	Private nTotJur    := 0
	Private nTotMul    := 0
	Private nTotCus    := 0
	Private nTotGer    := 0
	Private dDataLim   := mv_par04
	Private nVlImp     := 0
	Private cMvForDias := GetNewPar(aMvForDias[mv_par01],"iif(dDataLim < dDataBase,(dDataBase-dDataLim),0)")
	Private nMvTxJur   := GetNewPar(aMvTxJur[mv_par01],0.1)
	Private cMvForMult := GetNewPar(aMvForMult[mv_par01],"iif(dDataLim < dDataBase,nVlImp*nMvTxMul/100,0)")
	Private nMvTxMul   := GetNewPar(aMvTxMul[mv_par01],0)
	Private cNomTxt    := "A"+GravaData(mv_par02,.F.,1)+GravaData(mv_par03,.F.,1)+cEmpAnt+cFilAnt+"."+aExtArq[mv_par01]
	Private aTitulos   := {}
	private 	oTmpTable
	private 	oTmpTableC
	aadd(aEstru,{"BASEIMP","N",18,2})
	aadd(aEstru,{"ALIQ"   ,"N",06,2})
	aadd(aEstru,{"VALIMP" ,"N",18,2})
	aadd(aEstru,{"ATRASO" ,"N",06,0})
	aadd(aEstru,{"TXJUR"  ,"N",06,2})
	aadd(aEstru,{"VLJUR"  ,"N",18,2})
	aadd(aEstru,{"MULTA"  ,"C",40,0})
	aadd(aEstru,{"VLMULT" ,"N",18,2})
	aadd(aEstru,{"CUSTAS" ,"C",40,0})
	aadd(aEstru,{"VLCUST" ,"N",18,2})
	aadd(aEstru,{"VLTOT"  ,"N",18,2})

	cAliasImp := GetNextAlias()
	oTmpTable := FWTemporaryTable():New(cAliasImp)
	oTmpTable:SetFields( aEstru ) 
	//crea indice
	oTmpTable:AddIndex('T1ORD', {'ALIQ'})
	//Creacion de la tabla
	oTmpTable:Create()

	//               Descrição  Campo     Picture                     T  D Valid               Tipo
	aAdd(aHeaderImp,{STR0011,"BASEIMP","@e 999,999,999,999,999.99",18,2,""              ,"","N","",""}) //"Valor Tributavel"   
	aAdd(aHeaderImp,{STR0012,"ALIQ"   ,"@e 999.99"                ,06,2,""              ,"","N","",""}) //"Taxa Imposto"       
	aAdd(aHeaderImp,{STR0013,"VALIMP" ,"@e 999,999,999,999,999.99",18,2,""              ,"","N","",""}) //"Imposto a pagar"    
	aAdd(aHeaderImp,{STR0014,"ATRASO" ,"@e 999999"                ,06,0,""              ,"","N","",""}) //"Dias Atraso"        
	aAdd(aHeaderImp,{STR0015,"TXJUR"  ,"@e 999.99"                ,06,2,""              ,"","N","",""}) //"Taxa Juros"         
	aAdd(aHeaderImp,{STR0016,"VLJUR"  ,"@e 999,999,999,999,999.99",18,2,""              ,"","N","",""}) //"Juros a Pagar"      
	aAdd(aHeaderImp,{STR0017,"MULTA"  ,"@S15"                     ,40,0,""              ,"","C","",""}) //"Multa"              
	aAdd(aHeaderImp,{STR0018,"VLMULT" ,"@e 999,999,999,999,999.99",18,2,""              ,"","N","",""}) //"Multa a pagar"      
	aAdd(aHeaderImp,{STR0019,"CUSTAS" ,"@S15"                     ,40,0,""              ,"","C","",""}) //"Custas"             
	aAdd(aHeaderImp,{STR0020,"VLCUST" ,"@e 999,999,999,999,999.99",18,2,""              ,"","N","",""}) //"Custas a pagar"     
	aAdd(aHeaderImp,{STR0021,"VLTOT"  ,"@e 999,999,999,999,999.99",18,2,""              ,"","N","",""}) //"Valor Total a pagar"

	aEstru := {}
	aadd(aEstru,{"FATURA" ,"C",20,0})
	aadd(aEstru,{"SERIE"  ,"C",05,0})
	aadd(aEstru,{"CODCLI" ,"C",10,0})
	aadd(aEstru,{"LOJA"   ,"C",05,0})
	aadd(aEstru,{"CLIENTE","C",50,0})
	aadd(aEstru,{"VLRUS"  ,"N",18,2})
	aadd(aEstru,{"VLRKZ"  ,"N",18,2})
	aadd(aEstru,{"IMPUS"  ,"N",18,2})
	aadd(aEstru,{"IMPKZ"  ,"N",18,2})
	aadd(aEstru,{"ESPECIE","C",05,0})
	aadd(aEstru,{"PGTUS"  ,"N",18,2})
	aadd(aEstru,{"PGTKZ"  ,"N",18,2})
	aadd(aEstru,{"IPGTUS" ,"N",18,2})
	aadd(aEstru,{"IPGTKZ" ,"N",18,2})

	cAliasDoc := GetNextAlias()
	oTmpTableC := FWTemporaryTable():New(cAliasDoc)
	oTmpTableC:SetFields( aEstru ) 
	//crea indice
	oTmpTableC:AddIndex('T1ORD', {'FATURA'})
	//Creacion de la tabla
	oTmpTableC:Create()

	//               Descrição  Campo     Picture                     T  D Valid               Tipo
	aAdd(aHeaderDoc,{STR0022,"FATURA" ,"@!"                       ,20,0,""              ,"","C","",""}) //"Fatura"
	//Bruno Cremaschi - Projeto chave única.
	aAdd(aHeaderDoc,{STR0023,"SERIE"  ,"!!!"                      ,05,0,""              ,"","C","",""}) //"Serie"
	aAdd(aHeaderDoc,{STR0046,"ESPECIE","@!"                       ,05,0,""              ,"","C","",""}) //"Especie"
	aAdd(aHeaderDoc,{STR0024,"CLIENTE","@!"                       ,50,0,""              ,"","C","",""}) //"Cliente / Fornecedor"
	aAdd(aHeaderDoc,{STR0025,"VLRUS"  ,"@e 999,999,999,999,999.99",18,2,""              ,"","N","",""}) //"Valor NF US$"
	aAdd(aHeaderDoc,{STR0026,"VLRKZ"  ,"@e 999,999,999,999,999.99",18,2,""              ,"","N","",""}) //"Valor NF Kz"
	aAdd(aHeaderDoc,{STR0027,"IMPUS"  ,"@e 999,999,999,999,999.99",18,2,""              ,"","N","",""}) //"Imp NF US$"
	aAdd(aHeaderDoc,{STR0028,"IMPKZ"  ,"@e 999,999,999,999,999.99",18,2,""              ,"","N","",""}) //"Imp NF Kz"
	aAdd(aHeaderDoc,{STR0047,"PGTUS"  ,"@e 999,999,999,999,999.99",18,2,""              ,"","N","",""}) //"Valor Tit US$"
	aAdd(aHeaderDoc,{STR0048,"PGTKZ"  ,"@e 999,999,999,999,999.99",18,2,""              ,"","N","",""}) //"Valor Tit Kz"
	aAdd(aHeaderDoc,{STR0049,"IPGTUS" ,"@e 999,999,999,999,999.99",18,2,""              ,"","N","",""}) //"Imp Tit US$"
	aAdd(aHeaderDoc,{STR0050,"IPGTKZ" ,"@e 999,999,999,999,999.99",18,2,""              ,"","N","",""}) //"Imp Tit Kz"


	If File(cNomTxt)
		If ApMsgYesNo(STR0043) //"Este periodo ja foi apurado. Deseja refazer?"
			MsgRun(STR0044,,{|| lExclTit := ExTit() }) //"Cancelando apuração anterior..."
			If !lExclTit
				ApMsgStop(STR0045,STR0001) //"Houve um problema ao cancelar a apuração anterior."

				dbSelectArea(cAliasImp)
				dbCloseArea()
				dbSelectArea(cAliasDoc)
				dbCloseArea()
				
				If oTmpTable <> Nil  
					oTmpTable:Delete()  
					oTmpTable := Nil
				Endif 
				
				If oTmpTableC <> Nil  
					oTmpTableC:Delete()  
					oTmpTableC := Nil
				Endif 
				
				Return nil
			Endif
		Else
			nGetDOpc := 0
			MsgRun(STR0040,,{|| ApTxt() }) //"Carregando apuração anterior..."
		Endif
	Endif

	// Carrega dados dos impostos
	If nGetDOpc > 0
		Do Case
			Case mv_par01 = 1
				MsgRun(STR0041,,{|| ApSel() }) //"Carregando dados de apuração..."
			Case mv_par01 = 2
				MsgRun(STR0041,,{|| ApCon() }) //"Carregando dados de apuração..."
			Case mv_par01 = 3
				MsgRun(STR0041,,{|| ApEmp() }) //"Carregando dados de apuração..."
		EndCase
	Endif

	aColsLoad()
	
	If len(aColsImp) <= 0 .OR. Len(aColsDoc) <= 0
		ApMsgInfo(STR0042,STR0001) //"Não existem informações a serem exibidas."
	Else
		Define MsDialog oDlgApur Title STR0001 From 000,000 TO 600,800 Pixel //"Apuração de impostos"
			@ 002,002 Folder oFolder ;
				Items STR0029,STR0030 ; //"DLI","Documentos"
				Size 390,270 Pixel Of oDlgApur

			// Folder DLI
			@ 005,005 Group oGrpImps To 175,385 Label STR0001 Of oFolder:aDialogs[1] Pixel //"Apuração de Impostos"
				@ 015,010 Say STR0031 Pixel Of oGrpImps //"Imposto apurado:"
				@ 014,060 Get aTipImp[mv_par01] When .F. Size 70,07 Of oGrpImps Pixel
				oGetDadosImp := MsNewGetDados():New(030,010, 170,380,nGetDOpc,"AllwaysTrue()","AllWaysTrue()",,aAlter,,Len(aColsImp),"AFI011ApTot()",,"AllWaysTrue()",oGrpImps,aHeaderImp,aColsImp)


			@ 180,005 Group oGrpTotal To 250,385 Label STR0032 Of oFolder:aDialogs[1] Pixel //"Total Geral do Imposto Apurado"
				@ 190,010 Say STR0033 Pixel Of oGrpTotal //"Imposto a Pagar:"
				@ 189,060 Get oTotImp Var nTotImp Picture "@e 999,999,999,999,999.99" When .F. Size 80,07 Of oGrpTotal Pixel

				@ 201,010 Say STR0034 Pixel Of oGrpTotal //"Juros a pagar:"
				@ 200,060 Get oTotJur Var nTotJur Picture "@e 999,999,999,999,999.99" When .F. Size 80,07 Of oGrpTotal Pixel

				@ 212,010 Say STR0035 Pixel Of oGrpTotal //"Multa a Pagar:"
				@ 211,060 Get oTotMul Var nTotMul Picture "@e 999,999,999,999,999.99" When .F. Size 80,07 Of oGrpTotal Pixel

				@ 223,010 Say STR0036 Pixel Of oGrpTotal //"Custas:"
				@ 222,060 Get oTotCus Var nTotCus Picture "@e 999,999,999,999,999.99" When .F. Size 80,07 Of oGrpTotal Pixel

				@ 234,010 Say STR0021 Pixel Of oGrpTotal //"Valor Total a Pagar:"
				@ 233,060 Get oTotGer Var nTotGer Picture "@e 999,999,999,999,999.99" When .F. Size 80,07 Of oGrpTotal Pixel


			// Folder Documentos
			@ 005,005 Group oGrpDocs To 250,385 Label STR0037 Of oFolder:aDialogs[2] Pixel //"Documentos que compõem a Apuração"
				@ 015,010 Say STR0031 Pixel Of oGrpDocs //"Imposto apurado:"
				@ 014,060 Get aTipImp[mv_par01] When .F. Size 70,07 Of oGrpDocs Pixel

				oGetDadosDoc := MsNewGetDados():New(030,010, 245,380,0,"AllwaysTrue()","AllWaysTrue()",,,,Len(aColsImp),"AllWaysTrue()",,"AllWaysTrue()",oGrpDocs,aHeaderDoc,aColsDoc)

			oBtn01 := SButton():New(280,300,6, {|| Imprimir()             },,.T.)
			oBtn02 := SButton():New(280,330,1, {|| Apura(),oDlgApur:End() },,nGetDOpc=2)
			oBtn03 := SButton():New(280,360,2, {|| oDlgApur:End()         },,.T.)
		Activate MsDialog oDlgApur Centered
	Endif

	dbSelectArea(cAliasImp)
	dbCloseArea()

	dbSelectArea(cAliasDoc)
	dbCloseArea()
	
	If oTmpTable <> Nil  
		oTmpTable:Delete()  
		oTmpTable := Nil
	Endif 
	
	If oTmpTableC <> Nil  
		oTmpTableC:Delete()  
		oTmpTableC := Nil
	Endif 
Return nil

Static Function aColsLoad
	dbSelectArea(cAliasImp)
	dbGoTop()
	Do While !Eof()
		aAdd(aColsImp,{BASEIMP,ALIQ,VALIMP,ATRASO,TXJUR,VLJUR,MULTA,VLMULT,CUSTAS,VLCUST,VLTOT,.F.})
		nTotImp += VALIMP
		nTotJur += VLJUR
		nTotMul += VLMULT
		nTotCus += VLCUST
		nTotGer += VLTOT
		dbSkip()
	Enddo

	dbSelectArea(cAliasDoc)
	dbGoTop()
	Do While !Eof()
		aAdd(aColsDoc,{FATURA,SERIE,ESPECIE,CLIENTE,VLRUS,VLRKZ,IMPUS,IMPKZ,PGTUS,PGTKZ,IPGTUS,IPGTKZ,.F.})
		dbSkip()
	Enddo
Return nil

Static Function ApSel
	Local cAliasBx  := GetNextAlias()
	Local cAliasSql := ""
	Local cQuery    := ""

	FinBaixas(1,"R",mv_par02,mv_par03,cAliasBx)

	dbSelectArea(cAliasBx)
	Do While !eof()

		cQuery := "SELECT F3_NFISCAL"
		cQuery += " ,     F3_SERIE"
		cQuery += " ,     F3_CLIEFOR"
		cQuery += " ,     F3_LOJA"
		cQuery += " ,     A1_NOME"
		cQuery += " ,     F3_VALCONT"
		cQuery += " ,     F3_BASIMP1"
		cQuery += " ,     F3_ALQIMP1"
		cQuery += " ,     F3_VALIMP1"
		cQuery += " ,     F3_ESPECIE"
		cQuery += " ,     "+AllTrim(Str((cAliasBx)->E5_VALOR))+" AS E5_VALOR"
		cQuery += " ,     ("+AllTrim(Str((cAliasBx)->E5_VALOR))+"/F3_VALCONT)*F3_VALIMP1 AS E1_VALIMP1"

		cQuery += " FROM "+RetSqlName("SE1")+" SE1"

		cQuery += " JOIN "+RetSqlName("SF3")+" SF3"
		cQuery += " ON SF3.D_E_L_E_T_ = ' '"
		cQuery += " AND   F3_FILIAL = E1_FILIAL"
		cQuery += " AND   F3_NFISCAL = E1_NUM"
		cQuery += " AND   F3_SERIE = E1_SERIE"
		cQuery += " AND   F3_DTCANC = '"+Space(8)+"'"
		cQuery += " AND   F3_VALIMP1 > 0"
		cQuery += " AND   F3_TIPOMOV = 'V'"

		cQuery += " JOIN "+RetSqlName("SA1")+" SA1"
		cQuery += " ON   SA1.D_E_L_E_T_ = ' '"
		cQuery += " AND  A1_FILIAL = '"+xFilial("SA1")+"'"
		cQuery += " AND  A1_COD = F3_CLIEFOR"
		cQuery += " AND  A1_LOJA = F3_LOJA"

		cQuery += " WHERE SE1.D_E_L_E_T_ = ' '"
		cQuery += " AND   E1_FILIAL = '"+xFilial("SE1")+"'"
		cQuery += " AND   E1_PREFIXO = '"+(cAliasBx)->E5_PREFIXO+"'"
		cQuery += " AND   E1_NUM = '"+(cAliasBx)->E5_NUMERO+"'"
		cQuery += " AND   E1_PARCELA = '"+(cAliasBx)->E5_PARCELA+"'"
		cQuery += " AND   E1_TIPO = '"+(cAliasBx)->E5_TIPO+"'"

		cAliasSql := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAliasSql, .T., .T.)
		dbSelectArea(cAliasSql)
		TcSetField(cAliasSql,"F3_ALQIMP1","N",06,2)
		TcSetField(cAliasSql,"F3_BASIMP1","N",14,2)
		TcSetField(cAliasSql,"F3_VALIMP1","N",14,2)
		TcSetField(cAliasSql,"F3_VALCONT","N",14,2)
		TcSetField(cAliasSql,"E1_VALOR"  ,"N",14,2)
		TcSetField(cAliasSql,"E1_VALIMP1","N",14,2)

		If !eof()
			GravaDoc({F3_NFISCAL,F3_SERIE,F3_CLIEFOR + " - " + F3_LOJA + " - " + A1_NOME,xMoeda(F3_VALCONT,1,2,dDataBase),F3_VALCONT,xMoeda(F3_VALIMP1,1,2,dDataBase),F3_VALIMP1,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,xMoeda(E5_VALOR,1,2,dDataBase),E5_VALOR,xMoeda(E1_VALIMP1,1,2,dDataBase),E1_VALIMP1})
			GravaImp({iif(F3_ESPECIE="NCC",E5_VALOR*-1,E5_VALOR),F3_ALQIMP1,iif(F3_ESPECIE="NCC",E1_VALIMP1*-1,E1_VALIMP1)})
		Endif

		dbSelectArea(cAliasSql)
		dbCloseArea()

		dbSelectArea(cAliasBx)
		dbSkip()
	Enddo

	FinBaixas(2,,,,cAliasBx)
Return nil

Static Function ApCon
	Local cAliasSql := ""
	Local cQuery    := ""

	cQuery := "SELECT F3_ALQIMP2"
	cQuery += " ,     SUM(F3_BASIMP2) AS F3_BASIMP2"
	cQuery += " ,     SUM(F3_VALIMP2) AS F3_VALIMP2"

	cQuery += " FROM (SELECT F3_ALQIMP2"
	cQuery += "       ,     SUM(F3_BASIMP2) AS F3_BASIMP2"
	cQuery += "       ,     SUM(F3_VALIMP2) AS F3_VALIMP2"
	cQuery += "       FROM "+RetSqlName("SF3")
	cQuery += "       WHERE D_E_L_E_T_ = ' '"
	cQuery += "       AND   F3_FILIAL = '"+xFilial("SF3")+"'"
	cQuery += "       AND   F3_EMISSAO BETWEEN '"+dtos(mv_par02)+"' AND '"+dtos(mv_par03)+"'"
	cQuery += "       AND   F3_DTCANC = '"+Space(8)+"'"
	cQuery += "       AND   F3_VALIMP2 > 0"
	cQuery += "       AND   F3_TIPOMOV = 'V'"
	cQuery += "       AND   F3_ESPECIE <> 'NCC'
	cQuery += "       GROUP BY F3_ALQIMP2"

	cQuery += "       UNION"

	cQuery += "       SELECT F3_ALQIMP2"
	cQuery += "       ,     SUM(F3_BASIMP2*-1) AS F3_BASIMP2"
	cQuery += "       ,     SUM(F3_VALIMP2*-1) AS F3_VALIMP2"
	cQuery += "       FROM "+RetSqlName("SF3")
	cQuery += "       WHERE D_E_L_E_T_ = ' '"
	cQuery += "       AND   F3_FILIAL = '"+xFilial("SF3")+"'"
	cQuery += "       AND   F3_EMISSAO BETWEEN '"+dtos(mv_par02)+"' AND '"+dtos(mv_par03)+"'"
	cQuery += "       AND   F3_DTCANC = '"+Space(8)+"'"
	cQuery += "       AND   F3_VALIMP2 > 0"
	cQuery += "       AND   F3_TIPOMOV = 'V'"
	cQuery += "       AND   F3_ESPECIE = 'NCC'"
	cQuery += "       GROUP BY F3_ALQIMP2) TABTMP"

	cQuery += " GROUP BY F3_ALQIMP2"
	cQuery += " ORDER BY F3_ALQIMP2"


	cAliasSql := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAliasSql, .T., .T.)
	dbSelectArea(cAliasSql)
	TcSetField(cAliasSql,"F3_ALQIMP2","N",06,2)
	TcSetField(cAliasSql,"F3_BASIMP2","N",14,2)
	TcSetField(cAliasSql,"F3_VALIMP2","N",14,2)

	dbGoTop()
	Do While !eof()
		GravaImp({F3_BASIMP2,F3_ALQIMP2,F3_VALIMP2})
		dbSkip()
	Enddo
	dbCloseArea()

	cQuery := "SELECT F3_NFISCAL"
	cQuery += " ,     F3_SERIE"
	cQuery += " ,     F3_CLIEFOR"
	cQuery += " ,     F3_LOJA"
	cQuery += " ,     A1_NOME"
	cQuery += " ,     F3_VALCONT"
	cQuery += " ,     F3_VALIMP2"
	cQuery += " ,     F3_ESPECIE"
	cQuery += " FROM "+RetSqlName("SF3")+" SF3"

	cQuery += " JOIN "+RetSqlName("SA1")+" SA1"
	cQuery += " ON   SA1.D_E_L_E_T_ = ' '"
	cQuery += " AND  A1_FILIAL = '"+xFilial("SA1")+"'"
	cQuery += " AND  A1_COD = F3_CLIEFOR"
	cQuery += " AND  A1_LOJA = F3_LOJA"

	cQuery += " WHERE SF3.D_E_L_E_T_ = ' '"
	cQuery += " AND   F3_FILIAL = '"+xFilial("SF3")+"'"
	cQuery += " AND   F3_EMISSAO BETWEEN '"+dtos(mv_par02)+"' AND '"+dtos(mv_par03)+"'"
	cQuery += " AND   F3_VALIMP2 > 0"

	cQuery += " AND   F3_FILIAL = '"+xFilial("SF3")+"'"
	cQuery += " AND   F3_EMISSAO BETWEEN '"+dtos(mv_par02)+"' AND '"+dtos(mv_par03)+"'"
	cQuery += " AND   F3_DTCANC = '"+Space(8)+"'"
	cQuery += " AND   F3_VALIMP2 > 0"
	cQuery += " AND   F3_TIPOMOV = 'V'"

	cQuery += " ORDER BY F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA"

	cAliasSql := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAliasSql, .T., .T.)
	dbSelectArea(cAliasSql)
	TcSetField(cAliasSql,"F3_VALCONT","N",14,2)
	TcSetField(cAliasSql,"F3_VALIMP2","N",14,2)

	dbGoTop()
	Do While !eof()
		GravaDoc({F3_NFISCAL,F3_SERIE,F3_CLIEFOR + " - " + F3_LOJA + " - " + A1_NOME,xMoeda(F3_VALCONT,1,2,dDataBase),F3_VALCONT,xMoeda(F3_VALIMP2,1,2,dDataBase),F3_VALIMP2,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,xMoeda(F3_VALCONT,1,2,dDataBase),F3_VALCONT,xMoeda(F3_VALIMP2,1,2,dDataBase),F3_VALIMP2})
		dbSkip()
	Enddo
	dbCloseArea()
Return nil

Static Function ApEmp
	Local cAliasSql := ""
	Local cQuery    := ""

	cQuery := "SELECT F3_ALQIMP3"
	cQuery += " ,     SUM(FE_VALBASE) AS FE_VALBASE"
	cQuery += " ,     SUM(FE_RETENC) AS FE_RETENC"
	cQuery += " FROM "+RetSqlName("SFE")+" SFE"

	cQuery += " JOIN "+RetSqlName("SF3")+" SF3"
	cQuery += " ON   SF3.D_E_L_E_T_ = ' '"
	cQuery += " AND  F3_FILIAL = '"+xFilial("SF3")+"'"
	cQuery += " AND  F3_NFISCAL = FE_NFISCAL"
	cQuery += " AND  F3_SERIE = FE_SERIE"
	cQuery += " AND  F3_CLIEFOR = FE_FORNECE"
	cQuery += " AND  F3_LOJA = F3_LOJA"
	cQuery += " AND  F3_VALIMP3 > 0"
	cQuery += " AND  F3_DTCANC = '"+Space(8)+"'"

	cQuery += " WHERE SFE.D_E_L_E_T_ = ' '"
	cQuery += " AND   FE_FILIAL = '"+xFilial("SFE")+"'"
	cQuery += " AND   FE_EMISSAO BETWEEN '"+dtos(mv_par02)+"' AND '"+dtos(mv_par03)+"'"
	cQuery += " AND   FE_TIPO = '3'"
	cQuery += " GROUP BY F3_ALQIMP3"
	cQuery += " ORDER BY F3_ALQIMP3"
	cAliasSql := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAliasSql, .T., .T.)
	dbSelectArea(cAliasSql)
	TcSetField(cAliasSql,"F3_ALQIMP3","N",06,2)
	TcSetField(cAliasSql,"FE_VALBASE","N",14,2)
	TcSetField(cAliasSql,"FE_VALIMP" ,"N",14,2)

	dbGoTop()
	Do While !eof()
		GravaImp({FE_VALBASE,F3_ALQIMP3,FE_RETENC})
		dbSkip()
	Enddo
	dbCloseArea()
	
	cQuery := "SELECT FE_NFISCAL"
	cQuery += " ,     FE_SERIE"
	cQuery += " ,     FE_FORNECE"
	cQuery += " ,     FE_LOJA"
	cQuery += " ,     A2_NOME"
	cQuery += " ,     FE_VALBASE"
	cQuery += " ,     FE_RETENC"
	cQuery += " ,     F3_ESPECIE"
	cQuery += " ,     F3_VALCONT"
	cQuery += " ,     F3_VALIMP3"
	cQuery += " FROM "+RetSqlName("SFE")+" SFE"

	cQuery += " JOIN "+RetSqlName("SA2")+" SA2"
	cQuery += " ON   SA2.D_E_L_E_T_ = ' '"
	cQuery += " AND  A2_FILIAL = '"+xFilial("SA2")+"'"
	cQuery += " AND  A2_COD = FE_FORNECE"
	cQuery += " AND  A2_LOJA = FE_LOJA"

	cQuery += " JOIN "+RetSqlName("SF3")+" SF3"
	cQuery += " ON   SF3.D_E_L_E_T_ = ' '"
	cQuery += " AND  F3_FILIAL = '"+xFilial("SF3")+"'"
	cQuery += " AND  F3_NFISCAL = FE_NFISCAL"
	cQuery += " AND  F3_SERIE = FE_SERIE"
	cQuery += " AND  F3_CLIEFOR = FE_FORNECE"
	cQuery += " AND  F3_LOJA = F3_LOJA"
	cQuery += " AND  F3_VALIMP3 > 0"
	cQuery += " AND  F3_DTCANC = '"+Space(8)+"'"

	cQuery += " WHERE SFE.D_E_L_E_T_ = ' '"
	cQuery += " AND   FE_FILIAL = '"+xFilial("SFE")+"'"
	cQuery += " AND   FE_EMISSAO BETWEEN '"+dtos(mv_par02)+"' AND '"+dtos(mv_par03)+"'"
	cQuery += " AND   FE_TIPO = '3'"
	cQuery += " ORDER BY FE_NFISCAL,FE_SERIE,FE_FORNECE,FE_LOJA"

	cAliasSql := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAliasSql, .T., .T.)
	dbSelectArea(cAliasSql)
	TcSetField(cAliasSql,"F3_VALCONT","N",14,2)
	TcSetField(cAliasSql,"F3_VALIMP3","N",14,2)
	TcSetField(cAliasSql,"FE_VALBASE","N",14,2)
	TcSetField(cAliasSql,"FE_RETENC" ,"N",14,2)

	dbGoTop()
	Do While !eof()
		GravaDoc({FE_NFISCAL,FE_SERIE,FE_FORNECE + " - " + FE_LOJA + " - " + A2_NOME,xMoeda(F3_VALCONT,1,2,dDataBase),F3_VALCONT,xMoeda(F3_VALIMP3,1,2,dDataBase),F3_VALIMP3,FE_FORNECE,FE_LOJA,F3_ESPECIE,xMoeda(FE_VALBASE,1,2,dDataBase),FE_VALBASE,xMoeda(FE_RETENC,1,2,dDataBase),FE_RETENC})
		dbSkip()
	Enddo
	dbCloseArea()
Return nil

Static Function GravaImp(aDadosImp)
	Local aArea := GetArea()

	dbSelectArea(cAliasImp)
	dbSetOrder(1)
	dbSeek(StrZero(aDadosImp[2],6,2))

	nVlImp := aDadosImp[3]
	If RecLock(cAliasImp,!Found())
		BASEIMP += aDadosImp[1]
		ALIQ    := aDadosImp[2]
		VALIMP  += nVlImp

		if Len(aDadosImp) >= 4
		    If aDadosImp[4] > 0
				ATRASO  := aDadosImp[4]
			EndIf			
		Else
			If !Empty(cMvForDias)  
			    If &cMvForDias > 0 
					ATRASO  := &cMvForDias
				EndIF			
			Endif
		Endif

		if Len(aDadosImp) >= 5
			TXJUR   := aDadosImp[5]
		Else
			TXJUR   := nMvTxJur
		Endif

		if Len(aDadosImp) >= 6
			VLJUR   := aDadosImp[6]
		Else
			VLJUR   := (nVlImp*nMvTxJur*ATRASO)/100
		Endif

		if Len(aDadosImp) >= 8
			VLMULT  := aDadosImp[8]
		Else
			If !Empty(cMvForMult)
				VLMULT  := &cMvForMult
			Endif
		Endif

		if Len(aDadosImp) >= 7
			MULTA   := aDadosImp[7]
		Else
			MULTA   := iif(VLMULT > 0,STR0038,"") //"Multa por atraso"
		Endif

		if Len(aDadosImp) >= 9
			CUSTAS  := aDadosImp[9]
		Endif

		if Len(aDadosImp) >= 10
			VLCUST  := aDadosImp[10]
		Endif

		VLTOT   := VALIMP+VLJUR+VLMULT+VLCUST
		MsUnLock()
	Endif

	RestArea(aArea)
Return nil

Static Function GravaDoc(aDadosDoc)
	Local aArea := GetArea()

	dbSelectArea(cAliasDoc)
	If RecLock(cAliasDoc,.T.)
		FATURA  := AllTrim(aDadosDoc[1])
		SERIE   := AllTrim(aDadosDoc[2])
		CLIENTE := AllTrim(aDadosDoc[3])
		VLRUS   := aDadosDoc[4]
		VLRKZ   := aDadosDoc[5]
		IMPUS   := aDadosDoc[6]
		IMPKZ   := aDadosDoc[7]
		CODCLI  := aDadosDoc[8]
		LOJA    := aDadosDoc[9]
		ESPECIE := aDadosDoc[10]
		PGTUS   := aDadosDoc[11]
		PGTKZ   := aDadosDoc[12]
		IPGTUS  := aDadosDoc[13]
		IPGTKZ  := aDadosDoc[14]
		MsUnLock()
	Endif

	RestArea(aArea)
Return nil

Function AFI011ApTot
	Local cEditVar := ReadVar()
	Local uValEdit := &(cEditVar)
	Local nCpGetD  := aScan(oGetDadosImp:aHeader , {|x| rTrim(x[2]) == AllTrim(Substr(cEditVar,4,10)) })
	Local nLnGetD  := oGetDadosImp:oBrowse:nAt
	Local k        := 0
	Local j        := 0

	oGetDadosImp:aCols[nLnGetD,nCpGetD] := uValEdit

	nTotImp := 0
	nTotJur := 0
	nTotMul := 0
	nTotCus := 0
	nTotGer := 0

	if "TXJUR" $ Upper(AllTrim(cEditVar))
		oGetDadosImp:aCols[nLnGetD,6] := (oGetDadosImp:aCols[nLnGetD,3]*oGetDadosImp:aCols[nLnGetD,4]*oGetDadosImp:aCols[nLnGetD,5])/100
	Endif

	// Total da linha
	For k = 1 to Len(oGetDadosImp:aCols)
		oGetDadosImp:aCols[k,11] := oGetDadosImp:aCols[k,3] + oGetDadosImp:aCols[k,6] + oGetDadosImp:aCols[k,8] + oGetDadosImp:aCols[k,10]
		nTotImp += oGetDadosImp:aCols[k,3]
		nTotJur += oGetDadosImp:aCols[k,6]
		nTotMul += oGetDadosImp:aCols[k,8]
		nTotCus += oGetDadosImp:aCols[k,10]
		nTotGer += oGetDadosImp:aCols[k,11]

		dbSelectArea(cAliasImp)
		dbGoTo(k)
		If RecLock(cAliasImp,.F.)
			For j=1 to Len(oGetDadosImp:aCols[k])-1
				FieldPut(j,oGetDadosImp:aCols[k,j])
			Next j
			MsUnLock()
		Endif
	Next k

	oTotImp:cCaption := Transform(nTotImp,"@e 999,999,999,999,999.99")
	oTotJur:cCaption := Transform(nTotJur,"@e 999,999,999,999,999.99")
	oTotMul:cCaption := Transform(nTotMul,"@e 999,999,999,999,999.99")
	oTotCus:cCaption := Transform(nTotCus,"@e 999,999,999,999,999.99")
	oTotGer:cCaption := Transform(nTotGer,"@e 999,999,999,999,999.99")
	
	oTotImp:Refresh()
	oTotJur:Refresh()
	oTotMul:Refresh()
	oTotCus:Refresh()
	oTotGer:Refresh()
Return .T.

Static Function Apura()
	if mv_par05 = 1
		MsgRun(STR0039,,{|| aTitulos := GrvTitLoc(nTotGer) }) //"Gerando titulo de apuração..."
	Endif

	if mv_par05 = 1 .and. Len(aTitulos) <= 0
		Return nil
	Endif

	CriarArq()
Return nil

Static Function CriarArq
	Local cCRLF   := Chr(13)+Chr(10)
	Local nHdl    := 0
	Local cLinha  := ""

	nHdl := fCreate(cNomTxt)
	If nHdl <= 0
		ApMsgStop("Ocorreu um erro ao criar o arquivo")
	Endif

	dbSelectArea(cAliasImp)
	dbGoTop()
	Do While !eof() .AND. nHdl > 0
		cLinha := "IMP"                                          + Space(5)
		cLinha += Transform(BASEIMP,"@e 999,999,999,999,999.99") + Space(5)
		cLinha += Transform(ALIQ,"@e 999.99")                    + Space(5)
		cLinha += Transform(VALIMP,"@e 999,999,999,999,999.99")  + Space(5)
		cLinha += Transform(ATRASO,"@e 999999")                  + Space(5)
		cLinha += Transform(TXJUR,"@e 999.99")                   + Space(5)
		cLinha += Transform(VLJUR,"@e 999,999,999,999,999.99")   + Space(5)
		cLinha += Padr(MULTA,40)                                 + Space(5)
		cLinha += Transform(VLMULT,"@e 999,999,999,999,999.99")  + Space(5)
		cLinha += Padr(CUSTAS,40)                                + Space(5)
		cLinha += Transform(VLCUST,"@e 999,999,999,999,999.99")  + Space(5)
		cLinha += Transform(VLTOT,"@e 999,999,999,999,999.99")   + Space(5)
		cLinha += cCRLF
		fWrite(nHdl,cLinha)

		dbSkip()
	Enddo

	dbSelectArea(cAliasDoc)
	dbGoTop()
	Do While !eof() .AND. nHdl > 0
		cLinha := "DOC"                                         + Space(5)
		cLinha += FATURA                                        + Space(5)
		cLinha += SERIE                                         + Space(5)
		cLinha += CODCLI                                        + Space(5)
		cLinha += LOJA                                          + Space(5)
		cLinha += Transform(VLRUS ,"@e 999,999,999,999,999.99") + Space(5)
		cLinha += Transform(VLRKZ ,"@e 999,999,999,999,999.99") + Space(5)
		cLinha += Transform(IMPUS ,"@e 999,999,999,999,999.99") + Space(5)
		cLinha += Transform(IMPKZ ,"@e 999,999,999,999,999.99") + Space(5)
		cLinha += ESPECIE                                       + Space(5)
		cLinha += Transform(PGTUS ,"@e 999,999,999,999,999.99") + Space(5)
		cLinha += Transform(PGTKZ ,"@e 999,999,999,999,999.99") + Space(5)
		cLinha += Transform(IPGTUS,"@e 999,999,999,999,999.99") + Space(5)
		cLinha += Transform(IPGTKZ,"@e 999,999,999,999,999.99") + Space(5)

		cLinha += cCRLF
		fWrite(nHdl,cLinha)

		dbSkip()
	Enddo

	if Len(aTitulos) > 0
		cLinha := "TIT"                                              + Space(5)
		cLinha += Padr(aTitulos[1],10)                               + Space(5)
		cLinha += Padr(aTitulos[2],20)                               + Space(5)
		cLinha += Padr(aTitulos[3],5)                                + Space(5)
		cLinha += Padr(aTitulos[4],5)                                + Space(5)
		cLinha += Padr(aTitulos[5],10)                               + Space(5)
		cLinha += Padr(aTitulos[6],5)                                + Space(5)
		cLinha += Transform(aTitulos[7],"@e 999,999,999,999,999.99") + Space(5)
		cLinha += Transform(aTitulos[8],"@e 999,999,999,999,999.99") + Space(5)
		cLinha += cCRLF
		fWrite(nHdl,cLinha)
	Endif

	If nHdl > 0
		fClose(nHdl)
	Endif
Return nil

Static Function ApTxt
	Local cBuffer := ""
	Local aGrava  := {}

	FT_FUSE(cNomTxt)
	FT_FGOTOP()
	While !FT_FEOF()
		cBuffer := FT_FREADLN()
		aGrava  := {}

		Do Case
			Case Substr(cBuffer,1,3) = "IMP"
				aAdd(aGrava,RemPict(Substr(cBuffer,009,22)))
				aAdd(aGrava,RemPict(Substr(cBuffer,036,06)))
				aAdd(aGrava,RemPict(Substr(cBuffer,047,22)))
				aAdd(aGrava,Val(Substr(cBuffer,074,06))    )
				aAdd(aGrava,RemPict(Substr(cBuffer,085,06)))
				aAdd(aGrava,RemPict(Substr(cBuffer,096,22)))
				aAdd(aGrava,Substr(cBuffer,123,40)         )
				aAdd(aGrava,RemPict(Substr(cBuffer,168,22)))
				aAdd(aGrava,Substr(cBuffer,195,40))
				aAdd(aGrava,RemPict(Substr(cBuffer,240,22)))

				GravaImp(aGrava)
			Case Substr(cBuffer,1,3) = "DOC"
				aAdd(aGrava,Substr(cBuffer,009,20))
				aAdd(aGrava,Substr(cBuffer,034,05))
				aAdd(aGrava,"") // Nome
				aAdd(aGrava,RemPict(Substr(cBuffer,069,22))) // Valor em dolar
				aAdd(aGrava,RemPict(Substr(cBuffer,096,22))) // Valor em kuanzas
				aAdd(aGrava,RemPict(Substr(cBuffer,123,22))) // Imposto em dolar
				aAdd(aGrava,RemPict(Substr(cBuffer,150,22))) // Imposto em dolar
				aAdd(aGrava,Substr(cBuffer,044,10)) // Código do cliente
				aAdd(aGrava,Substr(cBuffer,059,05)) // Loja do cliente
				aAdd(aGrava,Substr(cBuffer,177,05)) // Especie
				aAdd(aGrava,RemPict(Substr(cBuffer,187,22))) // Valor Tit US
				aAdd(aGrava,RemPict(Substr(cBuffer,214,22))) // Valor Tit Kz
				aAdd(aGrava,RemPict(Substr(cBuffer,241,22))) // Imposto Tit Us
				aAdd(aGrava,RemPict(Substr(cBuffer,268,22))) // Imposto Tit Kz

				if mv_par01 = 3 // Empreitadas
					aGrava[3] := Substr(cBuffer,044,TamSX3("A2_COD")[1])+" - "+Substr(cBuffer,059,TamSX3("A2_LOJA")[1])+" - "+Posicione("SA2",1,xFilial("SA2")+Substr(cBuffer,044,TamSX3("A2_COD")[1])+Substr(cBuffer,059,TamSX3("A2_LOJA")[1]),"SA2->A2_NOME")
				else
					aGrava[3] := Substr(cBuffer,044,TamSX3("A1_COD")[1])+" - "+Substr(cBuffer,059,TamSX3("A1_LOJA")[1])+" - "+Posicione("SA1",1,xFilial("SA1")+Substr(cBuffer,044,TamSX3("A1_COD")[1])+Substr(cBuffer,059,TamSX3("A1_LOJA")[1]),"SA1->A1_NOME")
				Endif

				GravaDoc(aGrava)
			Case Substr(cBuffer,1,3) = "TIT"
		EndCase
		
		FT_FSKIP()
	EndDo
	FT_FUSE()
Return nil

Static Function RemPict(cVar)
	cVar := StrTran(cVar,".","")
	cVar := StrTran(cVar,",",".")
Return Val(cVar)

Static Function ExTit
	Local   lRet        := .T.
	Local   cBuffer     := ""
	Local   aDadosSE2   := {}
	Private lMsErroAuto := .F.

	FT_FUSE(cNomTxt)
	FT_FGOTOP()
	Do While !FT_FEOF()
		cBuffer := FT_FREADLN()
		if Substr(cBuffer,1,3) = "TIT"
			aAdd(aDadosSE2,{"E2_FILIAL" ,xFilial("SE2"),nil})
			aAdd(aDadosSE2,{"E2_PREFIXO",Substr(cBuffer,09,TamSX3("E2_PREFIXO")[1]),nil})
			aAdd(aDadosSE2,{"E2_NUM"    ,Substr(cBuffer,24,TamSX3("E2_NUM")[1]),nil})
			aAdd(aDadosSE2,{"E2_PARCELA",Substr(cBuffer,49,TamSX3("E2_PARCELA")[1]),nil})
			aAdd(aDadosSE2,{"E2_TIPO"   ,Substr(cBuffer,59,TamSX3("E2_TIPO")[1]),nil})
			aAdd(aDadosSE2,{"E2_FORNECE",Substr(cBuffer,69,TamSX3("E2_FORNECE")[1]),nil})
			aAdd(aDadosSE2,{"E2_LOJA"   ,Substr(cBuffer,84,TamSX3("E2_LOJA")[1]),nil})

			MsExecAuto({|x,y,z| FINA050(x,y,z)},aDadosSE2,,5)
				If lMsErroAuto
       			MostraErro()
       			lRet := .F.
	  		Endif
   			Exit
		Endif
		FT_FSKIP()
	EndDo
	FT_FUSE()

	if lRet
		fErase(cNomTxt)
	Endif
Return lRet

Static Function Imprimir()
	Local oReport

	If TRepInUse()
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf
Return

Static Function ReportDef()
	Local oReports
	Local oSection1
	Local oSection2

	oReport := TReport():New("FISA011R",STR0001,"",{|oReport| PrintReport(oReport)},STR0001) //"Apuração de imposto"
	                 
	oReport:SetParam(cPerg)
	
	oSection1 := TRSection():New(oReport,STR0029,cAliasImp)//"DLI"
		
	TRCell():New(oSection1,"BASEIMP",cAliasImp,STR0011,"@e 999,999,999,999,999.99") //"Valor Tributavel"   
	TRCell():New(oSection1,"ALIQ"   ,cAliasImp,STR0012,"@e 999.99"                ) //"Taxa Imposto"       
	TRCell():New(oSection1,"VALIMP" ,cAliasImp,STR0013,"@e 999,999,999,999,999.99") //"Imposto a pagar"    
	TRCell():New(oSection1,"ATRASO" ,cAliasImp,STR0014,"999999"                   ) //"Dias Atraso"        
	TRCell():New(oSection1,"TXJUR"  ,cAliasImp,STR0015,"@e 999.99"                ) //"Taxa Juros"         
	TRCell():New(oSection1,"VLJUR"  ,cAliasImp,STR0016,"@e 999,999,999,999,999.99") //"Juros a Pagar"      
	TRCell():New(oSection1,"MULTA"  ,cAliasImp,STR0017,"@!"                       ) //"Multa"              
	TRCell():New(oSection1,"VLMULT" ,cAliasImp,STR0018,"@e 999,999,999,999,999.99") //"Multa a pagar"      
	TRCell():New(oSection1,"CUSTAS" ,cAliasImp,STR0019,"@!"                       ) //"Custas"             
	TRCell():New(oSection1,"VLCUST" ,cAliasImp,STR0020,"@e 999,999,999,999,999.99") //"Custas a pagar"     
	TRCell():New(oSection1,"VLTOT"  ,cAliasImp,STR0021,"@e 999,999,999,999,999.99") //"Valor Total a pagar"

	TRFunction():New(oSection1:Cell("VALIMP"),NIL,"SUM",NIL,NIL,NIL,NIL,.F.)
	TRFunction():New(oSection1:Cell("VLJUR") ,NIL,"SUM",NIL,NIL,NIL,NIL,.F.)
	TRFunction():New(oSection1:Cell("VLMULT"),NIL,"SUM",NIL,NIL,NIL,NIL,.F.)
	TRFunction():New(oSection1:Cell("VLCUST"),NIL,"SUM",NIL,NIL,NIL,NIL,.F.)
	TRFunction():New(oSection1:Cell("VLTOT") ,NIL,"SUM",NIL,NIL,NIL,NIL,.F.)


	oSection2 := TRSection():New(oReport,STR0030,cAliasDoc) //"Documentos"
	TRCell():New(oSection2,"FATURA" ,cAliasDoc,STR0022+Chr(10),"@!"               ,23) //"Fatura"
	//Bruno Cremaschi - Projeto chave única.
	TRCell():New(oSection2,"SERIE"  ,cAliasDoc,STR0023,"!!!"                       ,5 ) //"Serie"
	TRCell():New(oSection2,"ESPECIE",cAliasDoc,STR0046,"@!"                       ,10) //"Especie"
	TRCell():New(oSection2,"CLIENTE",cAliasDoc,STR0024,"@!"                       ,20) //"Cliente"
	TRCell():New(oSection2,"VLRUS"  ,cAliasDoc,STR0025,"@e 999,999,999,999,999.99") //"Valor US$"
	TRCell():New(oSection2,"VLRKZ"  ,cAliasDoc,STR0026,"@e 999,999,999,999,999.99") //"Valor Kz"
	TRCell():New(oSection2,"IMPUS"  ,cAliasDoc,STR0027,"@e 999,999,999,999,999.99") //"Imposto US$"
	TRCell():New(oSection2,"IMPKZ"  ,cAliasDoc,STR0028,"@e 999,999,999,999,999.99") //"Imposto Kz"
	TRCell():New(oSection2,"PGTUS"  ,cAliasDoc,STR0047,"@e 999,999,999,999,999.99") //"Valor US$"
	TRCell():New(oSection2,"PGTKZ"  ,cAliasDoc,STR0048,"@e 999,999,999,999,999.99") //"Valor Kz"
	TRCell():New(oSection2,"IPGTUS" ,cAliasDoc,STR0049,"@e 999,999,999,999,999.99") //"Imposto US$"
	TRCell():New(oSection2,"IPGTKZ" ,cAliasDoc,STR0050,"@e 999,999,999,999,999.99") //"Imposto Kz"


	TRFunction():New(oSection2:Cell("VLRUS"),NIL,"SUM")
	TRFunction():New(oSection2:Cell("VLRKZ"),NIL,"SUM")
	TRFunction():New(oSection2:Cell("IMPUS"),NIL,"SUM")
	TRFunction():New(oSection2:Cell("IMPKZ"),NIL,"SUM")
	TRFunction():New(oSection2:Cell("PGTUS") ,NIL,"SUM")
	TRFunction():New(oSection2:Cell("PGTKZ") ,NIL,"SUM")
	TRFunction():New(oSection2:Cell("IPGTUS"),NIL,"SUM")
	TRFunction():New(oSection2:Cell("IPGTKZ"),NIL,"SUM")
Return oReport

Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
    
	oSection1:Print()
	oSection2:Print()
Return

Function VldDtaLimit()
	Local lFlag := .T.

    If mv_par04 < mv_par02
    
    	Help("",1,"HELP",NIL,STR0051,1,0)
        lFlag := .F.
    EndIf    
    
Return(lFLag)
