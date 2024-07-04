#include "rwmake.ch"
#include "AGRAR650B.ch"

Static __oArqTemp  := Nil
Static __oArqTot   := Nil

/*/{Protheus.doc} AGRAR650B
//Relatório Romaneio de Amostra por Bloco  
@author marina.muller
@since 26/09/2017
@type function
/*/
Function AGRAR650B(cFilCons, cSafraCons, aBlocosOk, aParam)
	Local oReport
	
	Private _cAliasTRB   := ""
	Private _cAliasTot   := ""
	Private _aBlocos     := aBlocosOk
	Private _cFilCons    := cFilCons
	Private _cSafraCon   := cSafraCons

    //recebe o filtro passado pelo browse do AGRA650
    //Default aParam		 := {}

	If !DXD->(ColumnPos('DXD_PCTFOR'))
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		return()
	EndIf
    
	

	oReport:= ReportDef(aParam)
	oReport:PrintDialog()

    AGRDLTPTB(__oArqTemp)
	AGRDLTPTB(__oArqTot)

Return 


/*/{Protheus.doc} ReportDef
//Esta função faz montagem das colunas do relatório
@author marina.muller
@since 26/09/2017
@type function
/*/
Static Function ReportDef(aParam)	
	Local cTitle 	:= OemToAnsi(STR0012) //"Romaneio de Amostra por Bloco"
	Local oReport
	Local oSection1
	Local oSection2
	Local oSection3
	Local oSection4
	Local cPic      := "@E 99,999,999,999.99"
	Local cPerg 	:= "AGRAR650B"
	
	CriaTemp()
	
	(_cAliasTRB)->(dbSetOrder(1))
	
	//-- Criacao do componente de impressao
	oReport := TReport():New('AGRAR650B',cTitle,cPerg,{|oReport| AGRAR650BP(oReport, aParam)},STR0012) //'Relação de Romaneio de Amostra por Bloco'

	oReport:lParamPage := .F.
	Pergunte(cPerg,.F.)
		
	//-- Criacao da secao utilizada pelo relatorio
	oSection1 := TRSection():New(oReport,STR0001,{_cAliasTRB,"DXD"},/*aOrdem*/) //'Relação de Romaneio de Amostra por Bloco'

	//monta o cabecalho
	TRCell():New(oSection1,"DXD_SAFRA",  _cAliasTRB ,STR0001,,20) //Safra
	TRCell():New(oSection1,"DXD_CODIGO", _cAliasTRB ,STR0002,,20) //Bloco
	TRCell():New(oSection1,"DXD_CLACOM", _cAliasTRB ,STR0003,,20) //Class. Com.
	TRCell():New(oSection1,"DXD_CODREG", _cAliasTRB ,STR0004,,20) //Padrão (regra)
	TRCell():New(oSection1,"DXD_PCTFOR", _cAliasTRB ,STR0005,,20) //% Formação
	TRCell():New(oSection1,"DXD_FDINI",  _cAliasTRB ,STR0006,,20) //Fardo Inicial
	TRCell():New(oSection1,"DXD_FDFIN",  _cAliasTRB ,STR0007,,20) //Fardo Final
    
    //monta as etiquetas
	oSection2 := TRSection():New(oReport,"",{_cAliasTRB,"DXI"},/*aOrdem*/) //Etiquetas/Pesos 
	TRCell():New(oSection2,"DXI_ETIQ",	 _cAliasTRB, STR0017,,20) //Etiqueta
	TRCell():New(oSection2,"DXI_PSLIQU", _cAliasTRB, STR0013,,20) //Peso líquido
	TRCell():New(oSection2,"DXI_PSBRUT", _cAliasTRB, STR0014,,20) //Peso bruto
	TRCell():New(oSection2,"          ", _cAliasTRB, "     ",,20) //Vazio
	TRCell():New(oSection2,"DXI_ETIQ2",  _cAliasTRB, STR0017,,20) //Etiqueta
	TRCell():New(oSection2,"DXI_PSLI2",  _cAliasTRB, STR0013,,20) //Peso líquido
	TRCell():New(oSection2,"DXI_PSBR2",  _cAliasTRB, STR0014,,20) //Peso bruto
   
    //monta os totais
	oSection3 := TRSection():New(oReport,"",{_cAliasTot,"DXI"},/*aOrdem*/) //Total 
	TRCell():New(oSection3,"TOTFARDO",   _cAliasTot, STR0016,,20) //Total de Fardos
	TRCell():New(oSection3,"          ", _cAliasTot, "     ",,40) //Vazio
	TRCell():New(oSection3,"TOTPSLIQ",   _cAliasTot, STR0018,,20) //Total Peso Liquido
	TRCell():New(oSection3,"          ", _cAliasTot, "     ",,40) //Vazio
	TRCell():New(oSection3,"TOTPSBRT",   _cAliasTot, STR0019,,20) //Total Peso Bruto

    //monta o total resumido
	oSection4 := TRSection():New(oReport,"",{_cAliasTot,"DXI"},/*aOrdem*/) //Total 
	TRCell():New(oSection4,"TOTFDRES",   _cAliasTot, STR0016,,20) //Total de Fardos Resumido
	TRCell():New(oSection4,"          ", _cAliasTot, "     ",,120)//Vazio

	//seta mascara nestas colunas
	oSection2:Cell("DXI_PSLIQU"):SetPicture(cPic)
	oSection2:Cell("DXI_PSBRUT"):SetPicture(cPic)
	oSection2:Cell("DXI_PSLI2"):SetPicture(cPic)
	oSection2:Cell("DXI_PSBR2"):SetPicture(cPic)
	oSection3:Cell("TOTPSLIQ"):SetPicture(cPic)
	oSection3:Cell("TOTPSBRT"):SetPicture(cPic)

Return(oReport)


/*/{Protheus.doc} CriaTemp
//Esta função faz criação das temporarias
@author marina.muller
@since 26/09/2017
@type function
/*/
Static Function CriaTemp()
	Local aCamposIni := {}
	Local aIndices   := {}
	
	aCmpsTab := TamSX3("DXD_SAFRA") //Safra
	AADD(aCamposIni,{"DXD_SAFRA", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]}) //Nome Campo, Tipo, Tamanho, Decimal

	aCmpsTab := TamSX3("DXD_CODIGO") //Bloco
	AADD(aCamposIni,{"DXD_CODIGO", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXD_CLACOM") //Class. Com.
	AADD(aCamposIni,{"DXD_CLACOM", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXD_CODREG") //Padrão (regra)
	AADD(aCamposIni,{"DXD_CODREG", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXD_PCTFOR") //% Formação
	AADD(aCamposIni,{"DXD_PCTFOR",aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXD_FDINI") //Fardo inicial
	AADD(aCamposIni,{"DXD_FDINI", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXD_FDFIN") //Fardo final
	AADD(aCamposIni,{"DXD_FDFIN", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXI_ETIQ") //Etiqueta
	AADD(aCamposIni,{"DXI_ETIQ", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	AADD(aCamposIni,{"DXI_ETIQ2", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXI_PSLIQU") //Peso Líquido
	AADD(aCamposIni,{"DXI_PSLIQU", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	AADD(aCamposIni,{"DXI_PSLI2", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	aCmpsTab := TamSX3("DXI_PSBRUT") //Peso Bruto
	AADD(aCamposIni,{"DXI_PSBRUT", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	AADD(aCamposIni,{"DXI_PSBR2", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	
	AADD(aCamposIni,{"TOTFARDO",'N',6,0}) //Total de Fardos
	AADD(aCamposIni,{"TOTPSLIQ",'N',10,2}) //Total Peso Liquido
	AADD(aCamposIni,{"TOTPSBRT",'N',10,2}) //Total Peso Bruto
	AADD(aCamposIni,{"TOTAL",'C',1,0})
    AADD(aCamposIni,{"TOTFDRES",'N',6,0}) //Total de Fardos Resumido
    
	//-- Cria Indice de Trabalho
    _cAliasTRB := GetNextAlias()
    _cAliasTot := GetNextAlias()  
    aAdd(aIndices, {"", "DXD_SAFRA+DXD_CODIGO"} )
    aAdd(aIndices, {"", "TOTAL"} )
    __oArqTemp  := AGRCRTPTB(_cAliasTRB, {aCamposIni, aIndices })
	__oArqTot   := AGRCRTPTB(_cAliasTot, {aCamposIni, aIndices })

Return


/*/{Protheus.doc} AGRAR650BP
//Esta função faz geração e impressão do relatório
@author marina.muller
@since 26/09/2017
@param oReport, object, descricao
@type function
/*/
Function AGRAR650BP(oReport, aParam)
	Local cAliasQry  := GetNextAlias()
	Local nTotFard   := 0
	Local nTotPeLq   := 0
	Local nTotPeBr   := 0
	Local nX         := 0
	Local cQry       := ""
	Local cWhere     := ""
    Local lExibeEtiq := .T.
    Local oSection1  := oReport:Section(1)
    Local oSection2  := oReport:Section(2)
	Local oSection3  := oReport:Section(3)
	Local oSection4  := oReport:Section(4)
	
	//busca F12 para saber se lista ou não os fardos 1-Sim  e 2-Não
    Pergunte("AGRAR650B", .F.)
    
    If MV_PAR01 == 2 
    	lExibeEtiq  := .F.
    Endif

	//se o relatório não for chamado pelo AGRA650
	If Funname() != "AGRA650"    
		If Len(_aBlocos) > 0  
			cWhere += "AND ("
			For nX := 1 to Len(_aBlocos)
				cWhere +=	" DXD_CODIGO = '" + _aBlocos[nX][1] + "'" + IIF(nX < Len(_aBlocos)," OR ",")")
			Next nX
		EndIf	
	//se o relatório for chamado pelo AGRA650
	ElseIf Funname() = "AGRA650"
		//Se tiver filtro no browse utilizamos como filtro no relatório
		If !Empty(aParam)
			cWhere += "AND "
			For nX := 1 to Len(aParam)
				If !Empty(aParam[nX][3])
				   cWhere += aParam[nX][3] + IIF(nX < Len(aParam)," AND ","")
				Else
				   cWhere += aParam[nX][2] + IIF(nX < Len(aParam)," AND ","")
				EndIf   
			Next nX
		EndIf
	EndIf
	    
	cQry := " SELECT * "
	cQry += " FROM " +RetSqlName("DXD")+ " DXD "
	cQry += " WHERE DXD.D_E_L_E_T_ =  ' ' "
	
	If !Empty(cWhere) .And. Funname() = "UBAA070"
		cQry += "AND (DXD_FILIAL = '" + _cFilCons + "' AND DXD_SAFRA = '" + _cSafraCon + "') " + cWhere
	ElseIf !Empty(cWhere) .And. Funname() = "AGRA650"
		cQry += cWhere
	EndIf
	
	cQry += " ORDER BY DXD.DXD_SAFRA, DXD.DXD_CODIGO"

	cQry := ChangeQuery(cQry)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQry),cAliasQry,.F.,.T.)
	
	//se F12 for 1-Sim exibe as etiquetas e totalização
    If lExibeEtiq
		While !(cAliasQry)->(Eof())
	
	        //carrega dados do cabeçalho
	        RecLock(_cAliasTRB,.T.) 
		    (_cAliasTRB)->DXD_SAFRA  := (cAliasQry)->DXD_SAFRA
		    (_cAliasTRB)->DXD_CODIGO := (cAliasQry)->DXD_CODIGO
		    (_cAliasTRB)->DXD_CLACOM := (cAliasQry)->DXD_CLACOM
		    (_cAliasTRB)->DXD_CODREG := (cAliasQry)->DXD_CODREG
		    (_cAliasTRB)->DXD_PCTFOR := (cAliasQry)->DXD_PCTFOR
		    (_cAliasTRB)->DXD_FDINI  := (cAliasQry)->DXD_FDINI
		    (_cAliasTRB)->DXD_FDFIN  := (cAliasQry)->DXD_FDFIN
		    (_cAliasTRB)->(MsUnlock())
			
			//imprime o cabeçalho
			oReport:SkipLine()
			oSection1:Init()
			oReport:IncMeter()
			oSection1:Cell("DXD_SAFRA"):Show()
			oSection1:Cell("DXD_CODIGO"):Show()
			oSection1:Cell("DXD_CLACOM"):Show()
			oSection1:Cell("DXD_CODREG"):Show()
			//oSection1:Cell(""):Show()
			oSection1:Cell("DXD_FDINI"):Show()
			oSection1:Cell("DXD_FDFIN"):Show()
			oSection1:PrintLine()
			oSection1:Finish()
        
			BeginSql Alias "cAliasDXI"
				Select *
				FROM %Table:DXI% DXI
				WHERE DXI.%NotDel%
				  AND DXI.DXI_FILIAL = %exp:(cAliasQry)->DXD_FILIAL%
				  AND DXI.DXI_SAFRA  = %exp:(cAliasQry)->DXD_SAFRA%
				  AND DXI.DXI_BLOCO  = %exp:(cAliasQry)->DXD_CODIGO%
				  AND DXI.%NotDel%
				ORDER BY DXI_ETIQ
			EndSQL
	
			cAliasDXI->(dbGoTop())
		    
			While .Not. cAliasDXI->(Eof()) 
	
				RecLock(_cAliasTRB,.T.)
				//carrega primeira coluna das etiquetas
				(_cAliasTRB)->DXI_ETIQ  	:= cAliasDXI->DXI_ETIQ
				(_cAliasTRB)->DXI_PSLIQU := cAliasDXI->DXI_PSLIQU
				(_cAliasTRB)->DXI_PSBRUT := cAliasDXI->DXI_PSBRUT

	            nTotFard += 1
	            nTotPeLq += cAliasDXI->DXI_PSLIQU
	            nTotPeBr += cAliasDXI->DXI_PSBRUT
				cAliasDXI->(DBSkip())
				
				If .Not. cAliasDXI->(Eof())
					//carrega segunda coluna das etiquetas
					(_cAliasTRB)->DXI_ETIQ2 	:= cAliasDXI->DXI_ETIQ
					(_cAliasTRB)->DXI_PSLI2  := cAliasDXI->DXI_PSLIQU
					(_cAliasTRB)->DXI_PSBR2  := cAliasDXI->DXI_PSBRUT

		            nTotFard += 1
		            nTotPeLq += cAliasDXI->DXI_PSLIQU
		            nTotPeBr += cAliasDXI->DXI_PSBRUT
				End if	
				(_cAliasTRB)->(MsUnlock())
	            
				//imprime as etiquetas
				oSection2:Init()
				oReport:IncMeter()
				oSection2:SetCol(0)
				oSection2:Cell("DXI_ETIQ"):Show()
				oSection2:Cell("DXI_PSLIQU"):Show()
				oSection2:Cell("DXI_PSBRUT"):Show()
				oSection2:Cell("DXI_ETIQ2"):Show()
				oSection2:Cell("DXI_PSLI2"):Show()
				oSection2:Cell("DXI_PSBR2"):Show()
				oSection2:PrintLine()
			
				cAliasDXI->(DBSkip())
			Enddo
			
			oSection2:Finish()
			cAliasDXI->( dbCloseArea() )

			//carrega os totais
			RecLock(_cAliasTot,.T.)
	        (_cAliasTot)->TOTFARDO := nTotFard
	        (_cAliasTot)->TOTPSLIQ := nTotPeLq
	        (_cAliasTot)->TOTPSBRT := nTotPeBr
			(_cAliasTot)->(MsUnlock())
		
			//imprime os totais
			oReport:SkipLine()
			oSection3:Init()
			oSection3:Cell("TOTFARDO"):Show()
			oSection3:Cell("TOTPSLIQ"):Show()
			oSection3:Cell("TOTPSBRT"):Show()
			oSection3:PrintLine()
			oSection3:Finish()
			
			nTotFard := 0
			nTotPeLq := 0
			nTotPeBr := 0
		
			oReport:EndPage()
			
			(cAliasQry)->(DBSkip())
			
			If !(cAliasQry)->(Eof())
				oReport:StartPage()
			EndIf
		Enddo
    //se F12 for 2-Não exibe apenas os blocos
    Else
		While !(cAliasQry)->(Eof())
	
	        RecLock(_cAliasTRB,.T.) 
		    (_cAliasTRB)->DXD_SAFRA  := (cAliasQry)->DXD_SAFRA
		    (_cAliasTRB)->DXD_CODIGO := (cAliasQry)->DXD_CODIGO
		    (_cAliasTRB)->DXD_CLACOM := (cAliasQry)->DXD_CLACOM
		    (_cAliasTRB)->DXD_CODREG := (cAliasQry)->DXD_CODREG
		    (_cAliasTRB)->DXD_PCTFOR := (cAliasQry)->DXD_PCTFOR
		    (_cAliasTRB)->DXD_FDINI  := (cAliasQry)->DXD_FDINI
		    (_cAliasTRB)->DXD_FDFIN  := (cAliasQry)->DXD_FDFIN
		    (_cAliasTRB)->(MsUnlock())

            nTotFard += 1
			
			(cAliasQry)->(DBSkip())
		Enddo
		
		//carrega o total
		RecLock(_cAliasTot,.T.)
        (_cAliasTot)->TOTFDRES := nTotFard
		(_cAliasTot)->(MsUnlock())
		
		// imprime os dados do relatório
		oSection1:Print()
		
		//imprime o total
		oSection4:Print()
    EndIf
     
	(cAliasQry)->(dbCloseArea())
	
Return

