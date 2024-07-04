#include "rwmake.ch"
#include "UBAR006.ch"

Static oArqTemp  := Nil
Static oArqTot   := Nil

/*/{Protheus.doc} UBAR006
// Relatório de Romaneios de Entrada
@author maicol.lange
@since 15/09/2015
@version 1
/*/
Function UBAR006()
	Local oReport
	Private aColsSX3	:= {}
	Private cAliasTRB   := ""
	Private cAliasTot   := ""

	

	oReport:= ReportDef()
	oReport:PrintDialog()

    AGRDLTPTB(oArqTemp)
	AGRDLTPTB(oArqTot)

Return

Static Function ReportDef()
	Local cTitle := OemToAnsi(STR0001) //Relação Romaneios de Entrada
	Local oReport
	Local oSection1
	Local oSection2
	Local cPic      := "@E 99,999,999,999.99"

    CriaTemp()
	(cAliasTRB)->(dbSetOrder(1))

	//-- Criacao do componente de impressao
	oReport := TReport():New('UBAR006',cTitle,'UBAC001',{|oReport| CarregaTemp(oReport)},STR0001) //'Relação de Romaneios de Entrada'

	oReport:lParamPage := .F.
	Pergunte(oReport:uParam,.F.)

	//-- Criacao da secao utilizada pelo relatorio
	oSection1 := TRSection():New(oReport,STR0001,{cAliasTRB,"DXM"},/*aOrdem*/) //'Relatorio Giro do Produto'

	TRCell():New(oSection1,"DXM_PLACA",  cAliasTRB ,STR0011) //Placa
	TRCell():New(oSection1,"NJ0_NOME",	 cAliasTRB ,STR0005) //Entidade
	TRCell():New(oSection1,"DXM_LJPRO",	 cAliasTRB ,STR0023) //Loja
	TRCell():New(oSection1,"DXM_FAZ",    cAliasTRB ,STR0006) //Fazenda
	TRCell():New(oSection1,"DXM_CODIGO", cAliasTRB ,STR0012) //Romaneio
	TRCell():New(oSection1,"DXL_CODIGO", cAliasTRB ,STR0013) //Fardão
	TRCell():New(oSection1,"DXL_PRENSA", cAliasTRB ,STR0014) //Prensa
	TRCell():New(oSection1,"DXM_NOTA",   cAliasTRB ,STR0015) //Nota Fiscal
	TRCell():New(oSection1,"DXM_DTEMIS", cAliasTRB ,STR0016) //Data
	TRCell():New(oSection1,"DXL_TALHAO", cAliasTRB ,STR0007) //Talhao
	TRCell():New(oSection1,"DXM_PSBRUT", cAliasTRB ,STR0018) //Peso Bruto
	TRCell():New(oSection1,"DXM_PSTARA", cAliasTRB ,STR0019) //Peso Tara
	TRCell():New(oSection1,"DXM_PSLONA", cAliasTRB ,STR0020) //Desconto
	TRCell():New(oSection1,"DX0_PSLIQU", cAliasTRB ,STR0009) //Peso Liquido

	oSection1:Cell("DXM_PLACA"):SetPicture("@!") //O dado ja vem com a picture do banco. Ao reaplicar, duplica o hifen

	oSection2 := TRSection():New(oReport,STR0017,{cAliasTot,"DXM"},/*aOrdem*/) //Total por Produtor
	TRCell():New(oSection2,"NJ0_NOME",	 cAliasTot,STR0005) //Entidade
	TRCell():New(oSection2,"DXM_LJPRO",	cAliasTot ,STR0023) //Loja
	TRCell():New(oSection2,"DXM_FAZ",   cAliasTot,STR0006) //Fazenda
	TRCell():New(oSection2,"TOTCARGA",  cAliasTot,STR0008) //Fardões
	TRCell():New(oSection2,"TOTPSLIQU", cAliasTot,STR0009) //Peso Liquido
	TRCell():New(oSection2,"MEDIA",     cAliasTot,STR0010) //Media
	TRCell():New(oSection2,"NN3_HECTAR",cAliasTot,STR0021) //Tamanho Total da Área
	TRCell():New(oSection2,"MEDCOLHARR",cAliasTot,STR0022) //Média Colheita Arroba

	oSection2:Cell("TOTPSLIQU"):SetPicture(cPic)
	oSection2:Cell("MEDIA"):SetPicture(cPic)
	oSection2:Cell("MEDCOLHARR"):SetPicture(cPic)

Return(oReport)



Static Function CriaTemp()
	Local aCamposIni := {}
	Local aIndices   := {}

	aCmpsTab := TamSX3("DXM_PLACA") //Placa
	AADD(aCamposIni,{"DXM_PLACA", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]}) //Nome Campo, Tipo, Tamanho, Decimal

	aCmpsTab := TamSX3("DXM_PRDTOR") //Produtor
	AADD(aCamposIni,{"DXM_PRDTOR", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("NJ0_NOME") //Entidade
	AADD(aCamposIni,{"NJ0_NOME", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXM_LJPRO") //Loja
	AADD(aCamposIni,{"DXM_LJPRO", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("NN2_NOME") //Fazenda
	AADD(aCamposIni,{"DXM_FAZ", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXM_CODIGO") //Romaneio
	AADD(aCamposIni,{"DXM_CODIGO",aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXL_CODIGO") //Fardão
	AADD(aCamposIni,{"DXL_CODIGO", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXL_PRENSA") //Prensa
	AADD(aCamposIni,{"DXL_PRENSA", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXM_NOTA") //Nota Fiscal
	AADD(aCamposIni,{"DXM_NOTA", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXM_DTEMIS") //Data
	AADD(aCamposIni,{"DXM_DTEMIS", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXL_TALHAO") //Talhão
	AADD(aCamposIni,{"DXL_TALHAO", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXM_PSBRUT") //Peso Bruto
	AADD(aCamposIni,{"DXM_PSBRUT", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXM_PSTARA") //Peso Tara
	AADD(aCamposIni,{"DXM_PSTARA", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXM_PSLONA") //Peso Lona
	AADD(aCamposIni,{"DXM_PSLONA", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DX0_PSLIQU") //Peso Liquido
	AADD(aCamposIni,{"DX0_PSLIQU", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	AADD(aCamposIni,{"TOTPSLIQU", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	AADD(aCamposIni,{"MEDIA", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	AADD(aCamposIni,{"MEDCOLHARR", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("NN3_HECTAR") //Tamanho Total da Área
	AADD(aCamposIni,{"NN3_HECTAR", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	AADD(aCamposIni,{"TOTCARGA",'N',6,0}) //Total Cargas
	AADD(aCamposIni,{"TOTAL",'C',1,0})

	//-- Cria Indice de Trabalho
    cAliasTRB := GetNextAlias()
    cAliasTot := GetNextAlias()  
    aAdd(aIndices, {"", "DXM_PRDTOR+DXM_LJPRO+DXM_FAZ+DXM_CODIGO"} )
    aAdd(aIndices, {"", "TOTAL"} )
    oArqTemp  := AGRCRTPTB(cAliasTRB, {aCamposIni, aIndices })
	oArqTot   := AGRCRTPTB(cAliasTot, {aCamposIni, aIndices })

Return


Static Function CarregaTemp(oReport)
	Local cAliasQry := GetNextAlias()
	Local nTotFard  := 0
	Local nTotPeLq  := 0
	Local nTotSai   := 0
	Local nTotSaiM  := 0
	Local nTotArea  := 0
	Local cQry      := ""
	Local cUN       := ""
    Local lFound    := .F.
    Local aFardao   := {}
    Local oHash
    Local cProdutor
    Local cLoja
    Local cFaz

    oHash := aToHM(aFardao)

	cUN := mv_par09

	cQry := " SELECT NJ0.NJ0_NOME, DXM.DXM_PLACA, DXM.DXM_PRDTOR, DXM.DXM_FAZ, DXM.DXM_CODIGO, DXM.DXM_NOTA, DXM.DXM_DTEMIS, DXL.DXL_CODIGO, DXL.DXL_PRENSA, " 
	cQry += " DXL.DXL_TALHAO, DX0.DX0_PSLIQU, DXM_PSBRUT, DXM_PSTARA, DXM_PSLONA, DXM_LJPRO, DX0_RATEIO, NN3.NN3_HECTAR "
	cQry += " ,NN3.NN3_FILIAL, NN3.NN3_SAFRA, NN3.NN3_FAZ, NN3.NN3_TALHAO"
	cQry += " FROM " +RetSqlName("DXM")+ " DXM "
	cQry += " JOIN " +RetSqlName("DXL")+ " DXL ON DXL.D_E_L_E_T_ = ' '"
	cQry += " AND DXL.DXL_FILIAL  = '"+FWxFilial("DXL")+"' "
	cQry += " AND DXL.DXL_CODROM = DXM.DXM_CODIGO "
	cQry += " AND DXL.DXL_SAFRA  =  DXM.DXM_SAFRA  "

	If !Empty(cUN)
		cQry += " AND DXL.DXL_CODUNB = '" + cUN + "' "
	EndIf

	cQry += " JOIN " +RetSqlName("DX0")+ " DX0 ON DX0.D_E_L_E_T_ = ' ' "
	cQry += " AND DX0.DX0_FILIAL =  '"+FWxFilial("DXM")+"' "
	cQry += " AND DX0_CODROM = DXM.DXM_CODIGO "
	cQry += " AND DX0.DX0_FARDAO = DXL.DXL_CODIGO "
	cQry += " JOIN " + RetSqlName("NJ0") +" NJ0 ON NJ0.D_E_L_E_T_ = ' ' AND NJ0_CODENT = DXM_PRDTOR AND NJ0_LOJENT = DXM_LJPRO "
	cQry += " LEFT JOIN " + RetSqlName("NN3")+ " NN3 ON NN3.D_E_L_E_T_ = ' ' "
	cQry += " AND NN3.NN3_FILIAL = '" + FwXFilial('NN3') + "' "
	cQry += " AND NN3.NN3_TALHAO = DXL.DXL_TALHAO "
	cQry += " AND NN3.NN3_SAFRA = DXL.DXL_SAFRA "
	cQry += " AND NN3.NN3_FAZ = DXL.DXL_FAZ "
	cQry += " WHERE DXM_FILIAL = '"+FWxFilial("DXM")+"' "
	cQry += " AND DXM.DXM_SAFRA = '"+mv_par01+"' "

	If !Empty(cUN)
		cQry += " AND DXM.DXM_CODUNB = '" +cUN +"' "
	Endif

	cQry += " AND DXM.DXM_DTEMIS BETWEEN '"+DTOS(mv_par02)+"' AND '"+DTOS(mv_par03)+"'"
	cQry += " AND DXM.D_E_L_E_T_ =  ' ' AND"

	If !Empty(mv_par04) //Placa do caminhao
		cQry +=	" DXM.DXM_PLACA = '"+mv_par04+"' AND"
	EndIf
	If !Empty(mv_par05)
		cQry +=	" DXM.DXM_PRDTOR = '"+mv_par05+"' AND" // Produtor
		If !Empty(mv_par06)
			cQry +=	" DXM.DXM_LJPRO = '"+mv_par06+"' AND" // Loja
		EndIf
	EndIf

	If !Empty(mv_par07) // Fazenda
		cQry +=	" DXM.DXM_FAZ = '"+mv_par07+"' AND" // Fazenda
	EndIf

	// Verificar para atribuir talhao e variedade e tipo de fardao na query
	If mv_par08 == 1
		cQry +=	" DXM.DXM_STATUS <> '3'"
	Else
		cQry +=	" DXM.DXM_STATUS = '3'"
	EndIf
	
	cQry +=	"   ORDER BY DXM.DXM_PRDTOR, DXM.DXM_LJPRO, DXM.DXM_FAZ   "
	

	cQry := ChangeQuery(cQry)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQry),cAliasQry,.F.,.T.)

	TcSetField(cAliasQry,"DXM_DTEMIS","D",8,0)

	While !(cAliasQry)->(Eof())

		cProdutor := (cAliasQry)->DXM_PRDTOR
		cLoja     := (cAliasQry)->DXM_LJPRO
		cNome		:= (cAliasQry)->NJ0_NOME
		cFaz      := (cAliasQry)->DXM_FAZ
		cFazDesc  := Posicione("NN2",3,FWxFilial("NN2")+(cAliasQry)->(DXM_PRDTOR+DXM_LJPRO+DXM_FAZ),"NN2_NOME")
		nTotFard  := 0
		nTotEntM  := 0
		nTotSai   := 0
		nTotSaiM  := 0

		//loop para gravar registro de cada romaneio
		While !(cAliasQry)->(Eof()) .And. cProdutor+cLoja+cFaz == (cAliasQry)->DXM_PRDTOR+(cAliasQry)->DXM_LJPRO+(cAliasQry)->DXM_FAZ

			RecLock(cAliasTRB,.T.)

			(cAliasTRB)->DXM_PLACA  	:= (cAliasQry)->DXM_PLACA
			(cAliasTRB)->DXM_PRDTOR 	:= (cAliasQry)->DXM_PRDTOR
			(cAliasTRB)->DXM_LJPRO 		:= (cAliasQry)->DXM_LJPRO
			(cAliasTRB)->NJ0_NOME 		:= (cAliasQry)->NJ0_NOME
			(cAliasTRB)->DXM_FAZ    	:= Posicione("NN2",3,FWxFilial("NN2")+(cAliasQry)->(DXM_PRDTOR+DXM_LJPRO+DXM_FAZ),"NN2_NOME")
			(cAliasTRB)->DXM_CODIGO 	:= (cAliasQry)->DXM_CODIGO
			(cAliasTRB)->DXM_NOTA   	:= (cAliasQry)->DXM_NOTA
			(cAliasTRB)->DXM_DTEMIS 	:= (cAliasQry)->DXM_DTEMIS
			(cAliasTRB)->DXL_CODIGO 	:= (cAliasQry)->DXL_CODIGO
			(cAliasTRB)->DXL_PRENSA 	:= (cAliasQry)->DXL_PRENSA
			(cAliasTRB)->DXL_TALHAO 	:= (cAliasQry)->DXL_TALHAO
			(cAliasTRB)->DXM_PSBRUT 	:= (((cAliasQry)->DXM_PSBRUT * (cAliasQry)->DX0_RATEIO) / 100)
			(cAliasTRB)->DXM_PSTARA		:= (((cAliasQry)->DXM_PSTARA * (cAliasQry)->DX0_RATEIO) / 100)
			(cAliasTRB)->DXM_PSLONA 	:= (((cAliasQry)->DXM_PSLONA * (cAliasQry)->DX0_RATEIO) / 100)
			(cAliasTRB)->DX0_PSLIQU 	:= Abs((cAliasQry)->DX0_PSLIQU)
			(cAliasTRB)->(MsUnlock())

			nTotFard += 1
			nTotPeLq += (cAliasQry)->DX0_PSLIQU

			//HashMap que mantem os Talhoes já somados (indice 1) 
            lFound := HMGet( oHash , (cAliasQry)->NN3_FILIAL + (cAliasQry)->NN3_SAFRA + (cAliasQry)->NN3_FAZ + (cAliasQry)->NN3_TALHAO,  )
            If !lFound
                HMAdd(oHash,{(cAliasQry)->NN3_FILIAL + (cAliasQry)->NN3_SAFRA + (cAliasQry)->NN3_FAZ + (cAliasQry)->NN3_TALHAO})
                nTotArea += (cAliasQry)->NN3_HECTAR
            EndIf
            

            (cAliasQry)->(DBSkip())

		Enddo

		//grava total do produtor
		DbSelectArea(cAliasTot)
		RecLock(cAliasTot,.T.)

		(cAliasTot)->DXM_PRDTOR := cProdutor
		(cAliasTot)->DXM_LJPRO 	:= cLoja
		(cAliasTot)->NJ0_NOME   := cNome
		(cAliasTot)->DXM_FAZ    := cFazDesc
		(cAliasTot)->TOTCARGA   := nTotFard
		(cAliasTot)->TOTPSLIQU  := nTotPeLq
		(cAliasTot)->MEDIA      := nTotPeLq / nTotFard
		(cAliasTot)->NN3_HECTAR := nTotArea
		(cAliasTot)->MEDCOLHARR := ((nTotPeLq / nTotArea) / 15)
		(cAliasTot)->TOTAL      := "1"
		(cAliasTot)->(MsUnlock())

		nTotFard := 0
		nTotPeLq := 0
		nTotArea := 0
		
		ReportPrint(oReport)
		fZapTRB( cAliasTRB )
		fZapTRB( cAliasTot )
		
		//o While acima ja monta a quebra por produtor, loja e fazenda. Se chegou ate aqui, ja montou o total em tela, entao forca quebra
		If cProdutor+cLoja+cFaz == (cAliasQry)->DXM_PRDTOR+(cAliasQry)->DXM_LJPRO+(cAliasQry)->DXM_FAZ
			(cAliasQry)->(DBSkip())
		EndIf
	Enddo

	(cAliasQry)->(dbCloseArea())
	(cAliasTRB)->(dbCloseArea())
	(cAliasTot)->(dbCloseArea())
Return

/*/{Protheus.doc} fZapTRB
//Deleta todos os dados de uma tabela temporária
@author bruna.rocio
@since 01/08/2016
@version 12.1.16
@param pcAliasTRB, , Alias da tabela temporária que deve ser limpa
@type function
/*/
Static Function fZapTRB( pcAliasTRB )
	Local aAreaAtu	 	:= GetArea()
	
	If Select( pcAliasTRB ) > 0
		DbSelectArea( pcAliasTRB )
		Zap
	Endif
	
	RestArea( aAreaAtu )
Return( NIL )


Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)


	// Transforma parametros Range em expressao SQL
	MakeSqlExpr(oReport:GetParam())

	oReport:SetMeter((cAliasTRB)->(RecCount()))

	dbSelectArea(cAliasTRB)

	oSection1:Cell("NJ0_NOME"):SetSize(20)
	oSection1:Cell("DXM_LJPRO"):SetSize(2)
	oSection1:Cell("DXM_FAZ"):SetSize(18)
	oSection2:Cell("DXM_FAZ"):SetSize(30)
	oSection2:Cell("MEDIA"):SetSize(13)

	(cAliasTRB)->(dbSetOrder(1))
	(cAliasTRB)->(dbGoTop())

	While !oReport:Cancel() .And. !(cAliasTRB)->(Eof()) .and. !Empty(DXM_CODIGO)
		If oReport:Cancel()
			Exit
		EndIf
		oReport:SkipLine()
		oSection1:Init()
		oReport:IncMeter()
		oSection1:Cell("DXM_PLACA"):Show()
		oSection1:Cell("NJ0_NOME"):Show()
		oSection1:Cell("DXM_LJPRO"):Show()
		oSection1:Cell("DXM_FAZ"):Show()
		oSection1:Cell("DXM_CODIGO"):Show()
		oSection1:Cell("DXL_CODIGO"):Show()
		oSection1:Cell("DXL_PRENSA"):Show()
		oSection1:Cell("DXM_NOTA"):Show()
		oSection1:Cell("DXM_DTEMIS"):Show()
		oSection1:Cell("DXL_TALHAO"):Show()
		oSection1:Cell("DXM_PSBRUT"):Show()
		oSection1:Cell("DXM_PSTARA"):Show()
		oSection1:Cell("DXM_PSLONA"):Show()
		oSection1:Cell("DX0_PSLIQU"):Show()
		oSection1:PrintLine()
		(cAliasTRB)->(dbSkip())
	EndDo
	oSection1:Finish()

	//Imprime total
	dbSelectArea(cAliasTot)
	(cAliasTot)->(dbSetOrder( 2 ) )
	(cAliasTot)->(MsSeek("1"))
	While !oReport:Cancel() .And. !(cAliasTot)->(Eof())

		oReport:SkipLine()
		oSection2:Init()
		oSection2:Cell("NJ0_NOME"):Show()
		oSection2:Cell("DXM_LJPRO"):Show()
		oSection2:Cell("DXM_FAZ"):Show()
		oSection2:Cell("TOTCARGA"):Show()
		oSection2:Cell("TOTPSLIQU"):Show()
		oSection2:Cell("NN3_HECTAR"):Show()
		oSection2:Cell("MEDCOLHARR"):Show()
		oSection2:PrintLine()
		(cAliasTot)->(dbSkip())
	EndDo
	oSection2:Finish()

Return NIL