#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM930.CH"

Static __oSt1
Static __oSt2
Static __cEmpAux1
Static __cEmpAux2
Static lMarkAll 	:= .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM930  ³ Autor ³ Leandro Drumond            ³ Data   ³11/03/2020³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cálculo de Múltiplos Vinculos.		                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM930()		                   	                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³   Data ³  Issue    ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³           ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Function GPEM930(aAuto)
Local aArea			:= GetArea()
Local aCoors 		:= FWGetDialogSize(oMainWnd)
Local aColsMuv		:= {}
Local aColsSRA		:= {}
LOcal aSeek			:= {}
Local aOrdem 		:= {STR0024,{||"UP"},"C","@BMP",0,1,0,.F.,{||.T.},.T.,{|| Gp930Up() },,,,.F.} //"Ordem"
Local cMarca
Local oDlg			                                 
Local oFWLayer
Local oPanelUp
Local oPanelDown
Local lTemSeqMV		:= SRC->(ColumnPos( 'RC_SEQMV' )) > 0 .and. SRD->(ColumnPos( 'RD_SEQMV' )) > 0 .and. SRR->(ColumnPos( 'RR_SEQMV' )) > 0

DEFAULT aAuto			:= {}

Private oMBrowseUp
Private oMBrowseDown
Private oTmpTable
Private oTmpSRA
Private aRotina
Private cAliasBrw 		:= "TABMULTV"
Private cAliasSRA 		:= "TABSRA"
Private lRotAuto 		:= !Empty(aAuto)

cMarca := GetMark()

If !lTemSeqMV
	Help( " ", 1, "Atenção",, "Não foram encontrados os campos de sequência MULTV na base de dados. Execute o UPDDISTR", 1, 0 )
	Return
EndIf																														

If !fCriaTmp(cMarca,,aAuto)
	Help( ,, STR0004,, STR0005, 1, 0) //"Não existem funcionários com mais de um vínculo neste ambiente" ### "Atenção"
	Return Nil
EndIf

If !lRotAuto

	fMntCols(@aColsMuv, @aColsSRA, @aSeek)

	DEFINE MSDIALOG oDlg TITLE STR0001 FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL //Múltiplos Vínculos

		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDlg,.F.,.T.)
		
		//-- Browse SRA (CPF)
		oFWLayer:AddLine("UP",35,.F.) 
		oFWLayer:AddCollumn("ALLSRA", 100, .T., 'UP' )     
		oPanelUp := oFWLayer:GetColPanel("ALLSRA", 'UP' )
				
		oMBrowseUp := FWMBrowse():New() 
		oMBrowseUp:SetOwner( oPanelUp )  
		oMBrowseUp:SetDescription(STR0002)	//"Funcionários com Múltiplos Vínculos"
		oMBrowseUp:SetAlias(cAliasBrw)

		oMBrowseUp:AddLegend( "TAB_LEG == '3'", "GREEN", STR0007 ) //Todos os vínculos foram calculados
		oMBrowseUp:AddLegend( "TAB_LEG == '2'", "YELLOW" , STR0008 ) //Mais de um vínculo foi calculado
		oMBrowseUp:AddLegend( "TAB_LEG == '1'", "BLUE" , STR0009 ) //Apenas um vínculo foi calculado
		oMBrowseUp:AddLegend( "TAB_LEG == '0'", "PINK" , STR0010 ) //Nenhum vínculo foi calculado

		oMBrowseUp:AddMarkColumn({|| IIF( ( cAliasBrw )->MARK == cMarca, "LBOK", "LBNO") },{|| Gp930Mark( cAliasBrw, cMarca ) },{|| Gp930MarkAll( cAliasBrw, cMarca ) , oMBrowseUp:Refresh() })
		oMBrowseUp:SetColumns( aColsMuv )
		oMBrowseUp:SetTemporary( .T. )
		oMBrowseUp:SetMenuDef( '' )  
		oMBrowseUp:SetCacheView(.F.) 
		oMBrowseUp:SetProfileID( '1' ) 
		oMBrowseUp:DisableDetails()
		oMBrowseUp:SetSeek(.T., aSeek)

		oMBrowseUp:AddButton( STR0011, {|| Gp930Processa(cMarca) }, 0, 4, 0) //"Calcular"

		oMBrowseUp:Activate()

		//Browse SRA (Matrículas)
		oFWLayer:AddLine("DOWN", 65, .F. ) 
		oFWLayer:AddCollumn("MUVSRA", 100, .T., 'DOWN' )
		oPanelDown := oFWLayer:GetColPanel("MUVSRA", 'DOWN')

		oMBrowseDown := FWMBrowse():New() 
		oMBrowseDown:SetOwner( oPanelDown )
		oMBrowseDown:SetDescription(STR0003)  //"Vínculos por filial"
		oMBrowseDown:SetMenuDef( '' ) 
		oMBrowseDown:SetAlias(cAliasSRA)

		GpLegend(@oMBrowseDown,.T.)
		
		oMBrowseDown:AddColumn(aOrdem)
		
		oMBrowseDown:SetColumns( aColsSRA ) 
		oMBrowseDown:SetTemporary( .T. )
		oMBrowseDown:SetCacheView (.F.)   
		oMBrowseDown:SetProfileID( '2' ) 			 		  
		oMBrowseDown:ForceQuitButton()   
		oMBrowseDown:DisableSeek()	
		oMBrowseDown:DisableDetails()

		oMBrowseDown:AddButton( STR0012, {|| If(Gp930Ord(),(fCriaTmp(cMarca,.T.),oMBrowseDown:UpdateBrowse()), Nil)}, 0, 4, 0) //"Ordenar"
		oMBrowseDown:AddButton( STR0026, {|| Gp930Rec() }, 0, 4, 0) //"Recibo Pagamento"
		
		oMBrowseDown:Activate()

		oRelation := FWBrwRelation():New()
		oRelation:AddRelation(oMBrowseUp,oMBrowseDown, {{"RA_CIC","TAB_CPF"}})
		oRelation:Activate() 
		
	ACTIVATE MSDIALOG oDlg
Else 
	Gp930Processa(cMarca)
EndIf 

oTmpTable:Delete()  
oTmpTable := Nil

oTmpSRA:Delete()  
oTmpSRA := Nil

lMarkAll 	:= .T.

RestArea(aArea)	 

Return .T.

/*/{Protheus.doc} Gp930Up
Reposicionada o registro uma linha acima
@author Leandro.Drumond
@since 11/03/2020
@version P12
/*/
Static Function Gp930Up()

Local cIndice := (cAliasSRA)->INDICE 
Local cCPF    := (cAliasSRA)->RA_CIC
Local nIndice := 0

If cIndice <> "01"
	nIndice := Val(cIndice)
	nIndice--
		RecLock(cAliasSRA,.F.)
			(cAliasSRA)->INDICE		:= "XX"
		MsUnLock()	
	If (cAliasSRA)->(DbSeek(cCPF + StrZero(nIndice,2)))
		RecLock(cAliasSRA,.F.)
			(cAliasSRA)->INDICE		:= cIndice
		MsUnLock()
	EndIf
	If (cAliasSRA)->(DbSeek(cCPF + "XX"))
		RecLock(cAliasSRA,.F.)
			(cAliasSRA)->INDICE		:= StrZero(nIndice,2)
		MsUnLock()	
	EndIf
	oMBrowseDown:Refresh()
EndIf

Return .T.

/*/{Protheus.doc} fCriaTmp
Cria tabela temporaria para uso no FWMarkBrowse 
@author Leandro.Drumond
@since 11/03/2020
@version P12
/*/
Static Function fCriaTmp(cMarca, lUpdate, aAuto)
Local aColsMuv	 := {}
Local aColsSRA   := {}
Local aPeriodos	 := {}
Local aPerAtual	 := {}
Local aAutonomos := {}
Local cQuery	 := ''
Local cAliasAux	 := 'QSRA'
Local cAliasMOV	 := GetNextAlias()
Local cFilRCH	 := ""
Local cMarcAux	 := ""
Local cLegAux	 := ""
Local cIndice	 := ""
Local cVar   	 := ""
Local cCpf		 := ""
Local cFiltAtu	 := GetSrvProfString("GPM930MULTVORD", "")
Local cOrder	 := ""
Local nPos		 := 0
Local nX 		 := 0
Local nQtdCalc	 := 0
Local nQtdSRC	 := 0
Local lRet		 := .F.
Local lCpo		 := .T.

DEFAULT lUpdate  := .F.
DEFAULT aAuto	 := {}

If Select(cAliasBrw) > 0
	DbSelectArea(cAliasBrw)
	DbCloseArea()
EndIf

If Select(cAliasSRA) > 0
	DbSelectArea(cAliasSRA)
	DbCloseArea()
EndIf

aAdd( aColsMuv, { "TAB_NOME"	,"C",TAMSX3("RA_NOME")[1],TAMSX3("RA_NOME")[2]})
aAdd( aColsMuv, { "TAB_CPF"		,"C",TAMSX3("RA_CIC")[1],TAMSX3("RA_CIC")[2]})
aAdd( aColsMuv, { "TAB_NASC"	,"D",8,0})
aAdd( aColsMuv, { "TAB_VINC"	,"N",4,0})
aAdd( aColsMuv, { "MARK"		,"C",2,0})
aAdd( aColsMuv, { "TAB_LEG"		,"C",1,0})

aAdd( aColsSRA, { "RA_FILIAL"	,"C",TAMSX3("RA_FILIAL")[1],TAMSX3("RA_FILIAL")[2]})
aAdd( aColsSRA, { "RA_MAT"		,"C",TAMSX3("RA_MAT")[1],TAMSX3("RA_MAT")[2]})
aAdd( aColsSRA, { "RA_PROCES"	,"C",TAMSX3("RA_PROCES")[1],TAMSX3("RA_PROCES")[2]})
aAdd( aColsSRA, { "RA_CATFUNC"	,"C",TAMSX3("RA_CATFUNC")[1],TAMSX3("RA_CATFUNC")[2]})
aAdd( aColsSRA, { "RA_ADMISSA"	,"D",8,0})
aAdd( aColsSRA, { "RA_DEMISSA"	,"D",8,0})
aAdd( aColsSRA, { "RA_CC"		,"C",TAMSX3("RA_CC")[1],TAMSX3("RA_CC")[2]})
aAdd( aColsSRA, { "RA_DESCCC"	,"C",TAMSX3("RA_DESCCC")[1],TAMSX3("RA_DESCCC")[2]})
aAdd( aColsSRA, { "RA_CODFUNC"	,"C",TAMSX3("RA_CODFUNC")[1],TAMSX3("RA_CODFUNC")[2]})
aAdd( aColsSRA, { "RA_DESCFUN"	,"C",TAMSX3("RA_DESCFUN")[1],TAMSX3("RA_DESCFUN")[2]})
aAdd( aColsSRA, { "RA_SITFOLH"	,"C",TAMSX3("RA_SITFOLH")[1],TAMSX3("RA_SITFOLH")[2]})
aAdd( aColsSRA, { "RA_TIPOPGT"	,"C",TAMSX3("RA_TIPOPGT")[1],TAMSX3("RA_TIPOPGT")[2]})
aAdd( aColsSRA, { "RA_RESCRAI"	,"C",TAMSX3("RA_RESCRAI")[1],TAMSX3("RA_RESCRAI")[2]})
aAdd( aColsSRA, { "RA_CIC"		,"C",TAMSX3("RA_CIC")[1],TAMSX3("RA_CIC")[2]})
aAdd( aColsSRA, { "INDICE"		,"C",2,0})

oTmpTable := FWTemporaryTable():New(cAliasBrw)
oTmpTable:SetFields( aColsMuv )
oTmpTable:AddIndex( "IND1", { "TAB_NOME", "TAB_CPF" } )
oTmpTable:AddIndex( "IND2", { "TAB_CPF" } )
oTmpTable:Create() 

oTmpSRA := FWTemporaryTable():New(cAliasSRA)
oTmpSRA:SetFields( aColsSRA )
oTmpSRA:AddIndex( "IND", { "RA_CIC", "INDICE" } )
oTmpSRA:Create()

cQuery := "SELECT COUNT(*) AS CNT, RA_CIC "
cQuery += 		" FROM " + RetSqlName("SRA")
cQuery +=		" WHERE RA_CIC <> ' ' AND RA_DEMISSA = ' ' AND"

If !Empty(aAuto)
	For nX := 1 to Len(aAuto)
		cCpf += "'" + aAuto[nX] + "'" + If(nX < Len(aAuto), ",","")
	Next nX
	cQuery += " RA_CIC IN (" + cCpf + ") AND"
EndIf 

cQuery += 		" D_E_L_E_T_ = ' '"
cQuery +=		" GROUP BY RA_CIC"
cQuery +=		" HAVING COUNT(*) > 1 "

cQuery := ChangeQuery( cQuery )

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAux)

DbSelectArea(cAliasAux)

DbSelectArea("SRA")
DbSetOrder(RetOrder("SRA","RA_CIC+RA_FILIAL+RA_MAT"))

While (cAliasAux)->(!Eof())
	SRA->(DbSeek((cAliasAux)->RA_CIC))
	
	lRet := .T.

	cFilRCH :=  xFilial("RCH", SRA->RA_FILIAL)

	If ( nPos := aScan(aPeriodos, {|x| x[1]+x[2] == cFilRCH + SRA->RA_PROCES } ) ) == 0
		aPerAtual := {}
		fGetPerAtual( @aPerAtual, cFilRCH, SRA->RA_PROCES, If(SRA->RA_CATFUNC $ "A*P", fGetCalcRot("9"), fGetCalcRot("1")) )
		If Len(aPerAtual) > 0
			aAdd(aPeriodos, {cFilRCH , SRA->RA_PROCES, aPerAtual[1,1]})
		Else
			aAdd(aPeriodos, {cFilRCH , SRA->RA_PROCES, " "})
		EndIf
		nPos := Len(aPeriodos)
	EndIf

	cMarcAux :=  "  "
	nQtdCalc := 0
	nQtdSRC	 := 0

	If !Empty(aAuto)
		If ( aScan(aAuto, { |x| x == (cAliasAux)->RA_CIC } ) ) > 0
			cMarcAux := cMarca
		EndIf
	Else 
		If !Empty(aPeriodos[nPos,3])
			If __oSt1 == Nil .or. ( __cEmpAux1 == Nil .or. __cEmpAux1 <> cEmpAnt )
			
				__cEmpAux1 := cEmpAnt
			
				__oSt1 := FWPreparedStatement():New()	 
		
				cQuery := " SELECT COUNT(*) AS CNT, 'SRC' AS TIPO, RC_MAT FROM " + RetSqlName('SRC') + " SRC"
				cQuery += " INNER JOIN " + RetSqlName('SRA') + " SRA"
				cQuery += " ON RC_FILIAL = RA_FILIAL AND RC_MAT = RA_MAT"
				cQuery += " WHERE RA_CIC = ? AND"
				cQuery += " ( RC_PERIODO = ? OR RC_DATA >= ? ) AND"
				cQuery += " SRC.D_E_L_E_T_ = ' ' AND"
				cQuery += " SRA.D_E_L_E_T_ = ' '"
				cQuery += " GROUP BY RC_MAT"
				cQuery += " UNION ALL "
				cQuery += " SELECT COUNT(*) AS CNT, 'SRD' AS TIPO, RD_MAT FROM " + RetSqlName('SRD') + " SRD"
				cQuery += " INNER JOIN " + RetSqlName('SRA') + " SRA"
				cQuery += " ON RD_FILIAL = RA_FILIAL AND RD_MAT = RA_MAT"
				cQuery += " WHERE RA_CIC = ? AND"
				cQuery += " ( RD_PERIODO = ? OR RD_DATPGT >= ? ) AND"
				cQuery += " SRD.D_E_L_E_T_ = ' ' AND"
				cQuery += " SRA.D_E_L_E_T_ = ' '"
				cQuery += " GROUP BY RD_MAT"
				cQuery := ChangeQuery(cQuery)
				
				__oSt1:SetQuery(cQuery)
			
			EndIf
			
			__oSt1:SetString(1,SRA->RA_CIC)
			__oSt1:SetString(2,aPeriodos[nPos,3])
			__oSt1:SetString(3,aPeriodos[nPos,3]+"01") //Cálculo pode ter sido realizado no período anterior mas a data de pagamento é no período atual, o que obriga recalculo do IR
			__oSt1:SetString(4,SRA->RA_CIC)
			__oSt1:SetString(5,aPeriodos[nPos,3])
			__oSt1:SetString(6,aPeriodos[nPos,3]+"01")
					
			cQuery := __oSt1:getFixQuery()
			
			If Select(cAliasMOV) > 0
				(cAliasMOV)->( dbclosearea())
			EndIf
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasMOV)

			While (cAliasMOV)->( !EoF() )
				If (cAliasMOV)->CNT > 0
					nQtdCalc++
					If (cAliasMOV)->TIPO == "SRC"
						nQtdSRC++
					EndIf
				EndIf
				(cAliasMOV)->( dbSkip() )
			EndDo
			If (cAliasAux)->CNT <> nQtdSRC //Se existir vínculo sem cálculo, considera que deve ser recalculado todos.
				cMarcAux := cMarca
			EndIf
		EndIf

		If nQtdCalc == 0 .or. nQtdSRC == 0
			cLegAux := "0" //Nenhum vínculo possui cálculo
		ElseIf (cAliasAux)->CNT == nQtdCalc .or. (cAliasAux)->CNT == nQtdSRC
			cLegAux := "3" //Todos os vínculos possuem cálculo
		ElseIf nQtdCalc == 1
			cLegAux := "1" //Apenas um vínculo possui cálculo
		Else
			cLegAux := "2" //Mais de um vínculo possui cálculo
		EndIf
	EndIf
	
	RecLock(cAliasBrw,.T.)
	(cAliasBrw)->TAB_NOME 	:= SRA->RA_NOME
	(cAliasBrw)->TAB_CPF 	:= SRA->RA_CIC
	(cAliasBrw)->TAB_NASC 	:= SRA->RA_NASC
	(cAliasBrw)->TAB_VINC	:= (cAliasAux)->CNT
	(cAliasBrw)->TAB_LEG	:= cLegAux
	(cAliasBrw)->MARK		:= cMarcAux

	(cAliasBrw)->(MsUnLock())

	cIndice 	:= "01"
	aAutonomos 	:= {}

	If !Empty(cFiltAtu)
		SRA->(DbCloseArea())
		If __oSt2 == Nil .or. ( __cEmpAux2 == Nil .or. __cEmpAux2 <> cEmpAnt ) .or. lUpdate
		
			__cEmpAux2 := cEmpAnt
		
			__oSt2 := FWPreparedStatement():New()

			cOrder := ""
			lCpo   := .T. //Valores ímpares representam o campo, pares representam a ordem
			// Posiçao dos campos {"","RA_FILIAL","RA_MAT","RA_PROCES","RA_CATFUNC","RA_CC","RA_CODFUNC"}
			For nX := 1 to Len(cFiltAtu)
				If lCpo ///Guarda a posição do campo
					cVar := SubStr(cFiltAtu,nX,1)
				EndIf

				If cVar <> "1"
					If lCpo
						If !Empty(cOrder)
							cOrder += ","
						EndIf
						Do Case
							Case cVar == "2"
								cOrder += " RA_FILIAL"
							Case cVar == "3"
								cOrder += " RA_MAT"
							Case cVar == "4"
								cOrder += " RA_PROCES"
							Case cVar == "5"
								cOrder += " RA_CATFUNC"
							Case cVar == "6"
								cOrder += " RA_CC"
							Case cVar == "7"
								cOrder += " RA_CODFUNC"
						EndCase
					Else
						If SubStr(cFiltAtu,nX,1) == "3"
							cOrder += " DESC"
						Else
							cOrder += " ASC"
						EndIf					
					EndIf
				EndIf
				lCpo := !lCpo
			Next nX
	
			cQuery := " SELECT RA_FILIAL, RA_MAT, RA_CIC, RA_TIPOPGT, RA_SITFOLH, RA_PROCES, RA_CATFUNC, RA_ADMISSA, RA_DEMISSA, RA_CC, RA_CODFUNC, RA_RESCRAI FROM " + RetSqlName('SRA')
			cQuery += " WHERE RA_CIC = ? AND"
			cQuery += " D_E_L_E_T_ = ' '"
			cQuery += " ORDER BY " + cOrder
			cQuery := ChangeQuery(cQuery)
			
			__oSt2:SetQuery(cQuery)
		
		EndIf
		
		__oSt2:SetString(1,(cAliasAux)->RA_CIC)
				
		cQuery := __oSt2:getFixQuery()
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SRA")

		TcSetField("SRA","RA_ADMISSA","D",8,0)
		TcSetField("SRA","RA_DEMISSA","D",8,0)
	EndIf

	While SRA->(!Eof() .and. RA_CIC == (cAliasAux)->RA_CIC )
		If !(SRA->RA_RESCRAI $ '30/31')

			If SRA->RA_CATFUNC $ "A*P" .and. Empty(cFiltAtu)//Guarda os autonomos no array para posterior gravação
				aAdd(aAutonomos, { SRA->RA_FILIAL 	,;	
								   SRA->RA_MAT		,;
								   SRA->RA_PROCES	,;
								   SRA->RA_CATFUNC	,;
								   SRA->RA_ADMISSA	,;
								   SRA->RA_DEMISSA	,;
								   SRA->RA_CC		,;
								   fDesc("CTT",SRA->RA_CC,"CTT_DESC01",,xFilial("CTT",SRA->RA_FILIAL))	,;
								   SRA->RA_CODFUNC	,;
								   fDesc("SRJ",SRA->RA_CODFUNC,"RJ_DESC",,xFilial("SRJ",SRA->RA_FILIAL))	,;
								   SRA->RA_CIC		,;
								   SRA->RA_SITFOLH	,;
								   SRA->RA_TIPOPGT	,;
								   SRA->RA_RESCRAI	;
				})

			Else

				RecLock(cAliasSRA,.T.)
				(cAliasSRA)->RA_FILIAL 	:= SRA->RA_FILIAL
				(cAliasSRA)->RA_MAT 	:= SRA->RA_MAT
				(cAliasSRA)->RA_PROCES 	:= SRA->RA_PROCES
				(cAliasSRA)->RA_CATFUNC	:= SRA->RA_CATFUNC
				(cAliasSRA)->RA_ADMISSA	:= SRA->RA_ADMISSA
				(cAliasSRA)->RA_DEMISSA	:= SRA->RA_DEMISSA
				(cAliasSRA)->RA_TIPOPGT := SRA->RA_TIPOPGT
				(cAliasSRA)->RA_SITFOLH := SRA->RA_SITFOLH
				(cAliasSRA)->RA_RESCRAI := SRA->RA_RESCRAI
				(cAliasSRA)->RA_CC		:= SRA->RA_CC
				(cAliasSRA)->RA_DESCCC	:= fDesc("CTT",SRA->RA_CC,"CTT_DESC01",,xFilial("CTT",SRA->RA_FILIAL))
				(cAliasSRA)->RA_CODFUNC	:= SRA->RA_CODFUNC
				(cAliasSRA)->RA_DESCFUN	:= fDesc("SRJ",SRA->RA_CODFUNC,"RJ_DESC",,xFilial("SRJ",SRA->RA_FILIAL))
				(cAliasSRA)->RA_CIC		:= SRA->RA_CIC
				(cAliasSRA)->INDICE		:= cIndice
				
				(cAliasSRA)->(MsUnLock())

				cIndice := Soma1(cIndice)
			EndIf
		EndIf
		SRA->(DbSkip())
	EndDo

	If !Empty(cFiltAtu) //Restaura SRA original
		SRA->(DbCloseArea())
		DbSelectArea("SRA")
		DbSetOrder(RetOrder("SRA","RA_CIC+RA_FILIAL+RA_MAT"))
	EndIf

	If Len(aAutonomos) > 0
		aSort( aAutonomos ,,, { |x,y| x[1] < y[1] } )
		
		For nX := 1 to Len(aAutonomos)
			RecLock(cAliasSRA,.T.)
			(cAliasSRA)->RA_FILIAL 	:= aAutonomos[nX,1]
			(cAliasSRA)->RA_MAT 	:= aAutonomos[nX,2]
			(cAliasSRA)->RA_PROCES 	:= aAutonomos[nX,3]
			(cAliasSRA)->RA_CATFUNC	:= aAutonomos[nX,4]
			(cAliasSRA)->RA_ADMISSA	:= aAutonomos[nX,5]
			(cAliasSRA)->RA_DEMISSA	:= aAutonomos[nX,6]
			(cAliasSRA)->RA_CC		:= aAutonomos[nX,7]
			(cAliasSRA)->RA_DESCCC	:= aAutonomos[nX,8]
			(cAliasSRA)->RA_CODFUNC	:= aAutonomos[nX,9]
			(cAliasSRA)->RA_DESCFUN	:= aAutonomos[nX,10]
			(cAliasSRA)->RA_CIC		:= aAutonomos[nX,11]
			(cAliasSRA)->RA_SITFOLH := aAutonomos[nX,12]
			(cAliasSRA)->RA_TIPOPGT := aAutonomos[nX,13]
			(cAliasSRA)->RA_RESCRAI := aAutonomos[nX,14]
			(cAliasSRA)->INDICE		:= cIndice
			
			(cAliasSRA)->(MsUnLock())

			cIndice := Soma1(cIndice)	
		Next nX
	EndIf

	(cAliasAux)->(DbSkip())

EndDo

(cAliasAux)->( dbCloseArea() )

(cAliasSRA)->(DbGoTop())
(cAliasBrw)->(DbGoTop())

Return lRet

/*/{Protheus.doc} fMntCols
Monta dados dos campos da tabela temporária
@author Leandro.Drumond
@since 11/03/2020
@version P12
/*/
Static Function fMntCols(aColsMuv, aColsSRA, aSeek)
Local aArea		:= GetArea()
Local aCampos  	:= {"RA_NOME","RA_CIC","RA_NASC"}
Local aDados	:= {{||(cAliasBrw)->TAB_NOME},{||(cAliasBrw)->TAB_CPF},{||(cAliasBrw)->TAB_NASC}}
Local nX		:= 0
Local nLinha	:= 0

For nX := 1 to Len(aCampos)
	nLinha++
	aAdd( aColsMuv, FWBrwColumn():New() )
	aColsMuv[ nLinha ]:SetData( aDados[nX])
	aColsMuv[ nLinha ]:SetTitle( GetSx3Cache(aCampos[nX],"X3_TITULO") )
	aColsMuv[ nLinha ]:SetType( GetSx3Cache(aCampos[nX],"X3_TIPO") )
	aColsMuv[ nLinha ]:SetPicture(GetSx3Cache(aCampos[nX],"X3_PICTURE"))
	aColsMuv[ nLinha ]:SetSize( GetSx3Cache(aCampos[nX],"X3_TAMANHO"))
	aColsMuv[ nLinha ]:SetDecimal( GetSx3Cache(aCampos[nX],"X3_DECIMAL") )
Next nX

aAdd(aSeek, {GetSx3Cache("RA_CIC","X3_TITULO"),{{'','C',TamSX3('RA_CIC')[1],TamSX3('RA_CIC')[2],GetSx3Cache("RA_CIC","X3_TITULO"),GetSx3Cache("RA_CIC","X3_PICTURE"),"(cAliasBrw)->TAB_CPF"}},2, .T.})

nLinha++
aAdd( aColsMuv, FWBrwColumn():New() )
aColsMuv[ nLinha ]:SetData( &("{ || (cAliasBrw)->TAB_VINC }" ))
aColsMuv[ nLinha ]:SetTitle( STR0006 ) //"Qtd. Vínculos"
aColsMuv[ nLinha ]:SetType( "N" )
aColsMuv[ nLinha ]:SetPicture( "9999" )
aColsMuv[ nLinha ]:SetSize( 4 )
aColsMuv[ nLinha ]:SetDecimal( 0 )

nLinha 	:= 0
aCampos := {"RA_FILIAL","RA_MAT","RA_PROCES","RA_CATFUNC","RA_ADMISSA","RA_DEMISSA","RA_CC","RA_DESCCC","RA_CODFUNC","RA_DESCFUN","RA_SITFOLH"}
aDados	:= {{||(cAliasSRA)->RA_FILIAL},{||(cAliasSRA)->RA_MAT},{||(cAliasSRA)->RA_PROCES},{||(cAliasSRA)->RA_CATFUNC},{||(cAliasSRA)->RA_ADMISSA},{||(cAliasSRA)->RA_DEMISSA},{||(cAliasSRA)->RA_CC},{||(cAliasSRA)->RA_DESCCC},{||(cAliasSRA)->RA_CODFUNC},{||(cAliasSRA)->RA_DESCFUN},{||(cAliasSRA)->RA_SITFOLH}}

For nX := 1 to Len(aCampos)
	nLinha++
	aAdd( aColsSRA, FWBrwColumn():New() )
	aColsSRA[ nLinha ]:SetData( aDados[nX])
	aColsSRA[ nLinha ]:SetTitle( GetSx3Cache(aCampos[nX],"X3_TITULO") )
	aColsSRA[ nLinha ]:SetType( GetSx3Cache(aCampos[nX],"X3_TIPO") )
	aColsSRA[ nLinha ]:SetPicture(GetSx3Cache(aCampos[nX],"X3_PICTURE"))
	aColsSRA[ nLinha ]:SetSize( GetSx3Cache(aCampos[nX],"X3_TAMANHO"))
	aColsSRA[ nLinha ]:SetDecimal( GetSx3Cache(aCampos[nX],"X3_DECIMAL") )
Next nX

RestArea(aArea)

Return Nil

/*/{Protheus.doc} Gp930Mark
Marca/desmarca um registro do browse
@author Leandro.Drumond
@since 11/03/2020
@version P12
/*/
Static Function Gp930Mark( cAliasBrw, cMarca, lAllMark )

DEFAULT lAllMark := .F.

RecLock( cAliasBrw, .F. )

If Empty( ( cAliasBrw )->MARK ) .or. lAllMark
	( cAliasBrw )->MARK := cMarca
Else
	( cAliasBrw )->MARK := "  "
EndIf

( cAliasBrw )->( MsUnLock() )

Return .T.

/*/{Protheus.doc} Gp930MarkAll
Marca/desmarca todos os registros do browse
@author Leandro.Drumond
@since 11/03/2020
@version P12
/*/
Static Function Gp930MarkAll( cAliasBrw, cMarca )

Local aArea	:= ( cAliasBrw )->( GetArea() )	

( cAliasBrw )->( DbGoTop() )

While ( cAliasBrw )->( !Eof() )
	
	Gp930Mark( cAliasBrw, cMarca, lMarkAll )
	
	( cAliasBrw )->( DbSkip() )

Enddo

lMarkAll := .F.

RestArea( aArea )

Return .T.

/*/{Protheus.doc} Gp930Ord
Redefine a ordem de cálculo dos funcionários
@author Leandro.Drumond
@since 11/03/2020
@version P12
/*/
Static Function Gp930Ord()
Local lRet 			:= .F.
Local aCampos 		:= {"","RA_FILIAL","RA_MAT","RA_PROCES","RA_CATFUNC","RA_CC","RA_CODFUNC"}
Local aOrdem		:= {"",STR0013, STR0014} //"CRESCENTE" ### "DECRESCENTE"
Local cCboCpo1 		:= ""
Local cCboCpo2 		:= ""
Local cCboCpo3 		:= ""
Local cCboCpo4 		:= ""
Local cCboCpo5 		:= ""
Local cCboCpo6 		:= ""
Local cCboOrd1 		:= ""
Local cCboOrd2 		:= ""
Local cCboOrd3 		:= ""
Local cCboOrd4 		:= ""
Local cCboOrd5 		:= ""
Local cCboOrd6 		:= ""
Local cPos			:= "0"
Local nX 			:= 0
Local oSay
Local oTButton
Local oFont1
Local oFont2
Local oFont3
Local oDlgAux
Local oGroup
Local oGroup1
Local oSize

Private oCboCpo1
Private oCboCpo2
Private oCboCpo3
Private oCboCpo4
Private oCboCpo5
Private oCboCpo6
Private oCboOrd1
Private oCboOrd2
Private oCboOrd3
Private oCboOrd4
Private oCboOrd5
Private oCboOrd6
Private cFiltAtu	:= GetSrvProfString("GPM930MULTVORD", "")

If !Empty(cFiltAtu)
	For nX := 1 to Len(cFiltAtu) step 2
		cPos := Soma1(cPos)
		&("cCboCpo" + cPos) := aCampos[Val(SubStr(cFiltAtu,nX,1))]
		&("cCboOrd" + cPos) := aOrdem[Val(SubStr(cFiltAtu,nX+1,1))]
	Next nX
EndIf

oSize := FwDefSize():New(.F.)             
oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.7),(oSize:aWindSize[3]*0.6) , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } // Espaco ao lado dos objetos 0, entre eles 3		
oSize:lProp 	:= .T. // Proporcional             
oSize:Process() 	   // Dispara os calculos 

oFont1		:= TFont():New("Arial",,-18,,.F.,,,,,)
oFont2		:= TFont():New("Arial",,-15,,.F.,,,,,)
oFont2		:= TFont():New("Arial",,-12,,.F.,,,,,)

DEFINE MSDIALOG oDlgAux TITLE STR0015 From 0,0 TO (oSize:aWindSize[3]*0.6),(oSize:aWindSize[3]*1.7) OF oMainWnd PIXEL //"Definição da ordem de cálculo"

		
		@ oSize:GetDimension("CABECALHO","LININI")+3 , oSize:GetDimension("CABECALHO","COLINI")+3	GROUP oGroup TO  oSize:GetDimension("CABECALHO","LINEND") * 0.49471 ,oSize:GetDimension("CABECALHO","COLEND") * 0.5  LABEL OemToAnsi("Ordenação do cálculo") OF oDlgAux PIXEL	//"Filtro"
		oGroup:oFont:=oFont1
		
		oSay:= TSay():New( oSize:GetDimension("CABECALHO","LININI")+32,oSize:GetDimension("CABECALHO","COLINI")+10, { || "Campo" }, oDlgAux,,oFont2,,,,.T.,,, 100, 10 )

		oSay:= TSay():New( oSize:GetDimension("CABECALHO","LININI")+32,oSize:GetDimension("CABECALHO","COLINI")+100, { || "Ordem" }, oDlgAux,,oFont2,,,,.T.,,, 100, 10 )


		@ oSize:GetDimension("CABECALHO","LININI")+45,oSize:GetDimension("CABECALHO","COLINI")+10 MSCOMBOBOX oCboCpo1 VAR cCboCpo1 ITEMS aCampos SIZE 60,8 OF oDlgAux PIXEL

		@ oSize:GetDimension("CABECALHO","LININI")+45,oSize:GetDimension("CABECALHO","COLINI")+100 MSCOMBOBOX oCboOrd1 VAR cCboOrd1 ITEMS aOrdem SIZE 60,8 OF oDlgAux PIXEL

		@ oSize:GetDimension("CABECALHO","LININI")+60,oSize:GetDimension("CABECALHO","COLINI")+10 MSCOMBOBOX oCboCpo2 VAR cCboCpo2 ITEMS aCampos SIZE 60,8 OF oDlgAux PIXEL

		@ oSize:GetDimension("CABECALHO","LININI")+60,oSize:GetDimension("CABECALHO","COLINI")+100 MSCOMBOBOX oCboOrd2 VAR cCboOrd2 ITEMS aOrdem SIZE 60,8 OF oDlgAux PIXEL

		@ oSize:GetDimension("CABECALHO","LININI")+75,oSize:GetDimension("CABECALHO","COLINI")+10 MSCOMBOBOX oCboCpo3 VAR cCboCpo3 ITEMS aCampos SIZE 60,8 OF oDlgAux PIXEL

		@ oSize:GetDimension("CABECALHO","LININI")+75,oSize:GetDimension("CABECALHO","COLINI")+100 MSCOMBOBOX oCboOrd3 VAR cCboOrd3 ITEMS aOrdem SIZE 60,8 OF oDlgAux PIXEL

		@ oSize:GetDimension("CABECALHO","LININI")+90,oSize:GetDimension("CABECALHO","COLINI")+10 MSCOMBOBOX oCboCpo4 VAR cCboCpo4 ITEMS aCampos SIZE 60,8 OF oDlgAux PIXEL

		@ oSize:GetDimension("CABECALHO","LININI")+90,oSize:GetDimension("CABECALHO","COLINI")+100 MSCOMBOBOX oCboOrd4 VAR cCboOrd4 ITEMS aOrdem SIZE 60,8 OF oDlgAux PIXEL

		@ oSize:GetDimension("CABECALHO","LININI")+105,oSize:GetDimension("CABECALHO","COLINI")+10 MSCOMBOBOX oCboCpo5 VAR cCboCpo5 ITEMS aCampos SIZE 60,8 OF oDlgAux PIXEL

		@ oSize:GetDimension("CABECALHO","LININI")+105,oSize:GetDimension("CABECALHO","COLINI")+100 MSCOMBOBOX oCboOrd5 VAR cCboOrd5 ITEMS aOrdem SIZE 60,8 OF oDlgAux PIXEL

		@ oSize:GetDimension("CABECALHO","LININI")+120,oSize:GetDimension("CABECALHO","COLINI")+10 MSCOMBOBOX oCboCpo6 VAR cCboCpo6 ITEMS aCampos SIZE 60,8 OF oDlgAux PIXEL

		@ oSize:GetDimension("CABECALHO","LININI")+120,oSize:GetDimension("CABECALHO","COLINI")+100 MSCOMBOBOX oCboOrd6 VAR cCboOrd6 ITEMS aOrdem SIZE 60,8 OF oDlgAux PIXEL

		@ oSize:GetDimension("CABECALHO","LININI")+45 , oSize:GetDimension("CABECALHO","COLINI")+175	GROUP oGroup1 TO  oSize:GetDimension("CABECALHO","LININI") + 130 ,oSize:GetDimension("CABECALHO","COLEND") * 0.48  OF oDlgAux PIXEL

		oSay:= TSay():New( oSize:GetDimension("CABECALHO","LININI")+60,oSize:GetDimension("CABECALHO","COLINI")+180, { || STR0016 }, oDlgAux,,oFont3,,,,.T.,,, 300, 10 ) //" O cálculo padrão é feito separando os celetistas, independente da categoria e calculando por filial de forma "
		oSay:= TSay():New( oSize:GetDimension("CABECALHO","LININI")+70,oSize:GetDimension("CABECALHO","COLINI")+180, { || STR0017 }, oDlgAux,,oFont3,,,,.T.,,, 300, 10 ) //"crescente. Em seguida são calculados os autônomos e pró-labores, também ordenados por filial de forma crescente."
		oSay:= TSay():New( oSize:GetDimension("CABECALHO","LININI")+80,oSize:GetDimension("CABECALHO","COLINI")+180, { || STR0018 }, oDlgAux,,oFont3,,,,.T.,,, 300, 10 ) //" Caso queira alterar essa ordem, monte o filtro que deverá ser utilizado para ordenação alterando os combos ao lado."
		oSay:= TSay():New( oSize:GetDimension("CABECALHO","LININI")+90,oSize:GetDimension("CABECALHO","COLINI")+180, { || STR0019 }, oDlgAux,,oFont3,,,,.T.,,, 300, 10 ) //" A ordem definida será gravada e usada em futuros cálculos. Caso queira voltar a ordem padrão basta apagar o"
		oSay:= TSay():New( oSize:GetDimension("CABECALHO","LININI")+100,oSize:GetDimension("CABECALHO","COLINI")+180, { || STR0020 }, oDlgAux,,oFont3,,,,.T.,,, 300, 10 ) //"conteúdo dos combos e gravar."
		oSay:= TSay():New( oSize:GetDimension("CABECALHO","LININI")+110,oSize:GetDimension("CABECALHO","COLINI")+180, { || STR0021 }, oDlgAux,,oFont3,,,,.T.,,, 300, 10 ) //" Não é necessário o preenchimento de todos os combos, apenas os que forem necessários para definição da ordenação."

		oTButton := TButton():New( oSize:GetDimension("CABECALHO","LININI")+150, oSize:GetDimension("CABECALHO","COLINI")+190, STR0022 ,oDlgAux,{|| If(fVldOrd(@lRet),oDlgAux:End(), Nil)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   //"Confirmar"
		oTButton := TButton():New( oSize:GetDimension("CABECALHO","LININI")+150, oSize:GetDimension("CABECALHO","COLINI")+270, STR0023,oDlgAux,{|| lRet := .F., oDlgAux:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   //"Cancelar"

ACTIVATE MSDIALOG oDlgAux CENTERED

Return lRet

/*/{Protheus.doc} fVldOrd
Valida a ordem definida e grava no INI
@author Leandro.Drumond
@since 11/03/2020
@version P12
/*/
Static Function fVldOrd(lAtualiza)
Local cFiltro	:= ""
Local cPosNx	:= "1"
Local cPosNy	:= "0"
Local lRet 		:= .T.
Local nX 		:= 0
Local nY		:= 0

//Se ao menos um dos filtros foi definido, monta string
If oCboCpo1:nAt > 1 .or. oCboCpo2:nAt > 1 .or. oCboCpo3:nAt > 1 .or. oCboCpo4:nAt > 1 .or. oCboCpo5:nAt > 1 .or. oCboCpo6:nAt > 1
	For nX := 2 to 6
		cPosnX := Soma1(cPosNx)
		If &("oCboCpo" + cPosnX + ":nAt") > 1
			For nY := 1 to nX - 1
				cPosNy := Soma1(cPosNy)
				If &("oCboCpo" + cPosNx + ":nAt") == &("oCboCpo" + cPosNy + ":nAt")
					lRet := .F.
					MsgAlert(STR0025) //"O mesmo campo não deve ser informado mais que uma vez."
					Exit
				EndIf
			Next nY
			If !lRet
				Exit
			EndIf 
		EndIf
	Next nX
	If lRet
		cFiltro += cValToChar(oCboCpo1:nAt) + cValToChar(oCboOrd1:nAt)
		cFiltro += cValToChar(oCboCpo2:nAt) + cValToChar(oCboOrd2:nAt)
		cFiltro += cValToChar(oCboCpo3:nAt) + cValToChar(oCboOrd3:nAt)
		cFiltro += cValToChar(oCboCpo4:nAt) + cValToChar(oCboOrd4:nAt)
		cFiltro += cValToChar(oCboCpo5:nAt) + cValToChar(oCboOrd5:nAt)
		cFiltro += cValToChar(oCboCpo6:nAt) + cValToChar(oCboOrd6:nAt)
	EndIf
EndIf

If lRet .and. cFiltro <> cFiltAtu //Atualiza filtro no INI
	WriteSrvProfString("GPM930MULTVORD",cFiltro)
	lAtualiza := .T.
EndIf

Return lRet

/*/{Protheus.doc} Gp930Processa
Processa o cálculo de MULTV para os funcionários selecionados
@author Leandro.Drumond
@since 16/03/2020
@version P12
/*/
Static Function Gp930Processa(cMarca, lIncBar)
Local aArea		:= GetArea()
Local aAreaMULTV:= (cAliasBrw)->(GetArea())
Local aAreaSRA  := (cAliasSRA)->(GetArea())
Local aVinc		:= {}
Local aPerAtual := {}
Local aLogItens	:= {}
Local aLogTitle	:= {}
Local aLogAux	:= {}
Local aLogAux2	:= {}
Local cFilAux	:= cFilAnt
Local cTimeIni	:= Time()		// Informacoes da Regua
Local nX 		:= 0
Local nY        := 0
Local nTamBar1  := 0
Local lSemanal	:= .F.

DEFAULT lIncBar := .F.

SetMnemonicos(cFilAnt,NIL,.T.)

If !P_MULTV .And. !MsgNoYes( OemToAnsi( STR0032 + CRLF + STR0033 ), STR0005 )//"O cálculo de colaboradores com múltiplos vínculos empregatícios foi modificado. É necessário informar o conteúdo do mnemônico P_MULTV com .T. para adequação à Nota Orientativa 20/2019 do eSocial."##"Deseja iniciar o cálculo com o mnemônico desativado mesmo assim?"
	Return
EndIf

If !lIncBar .and. !IsBlind()
	Proc2BarGauge( { || Gp930Processa(cMarca, .T.) } , STR0001 , NIL , NIL , .F. , .T. , .T. , .T. )	// "Múltiplos Vínculos"
	Return
EndIf

DbSelectArea("SRC")
DbSetOrder(RetOrdem("SRC","RC_FILIAL+RC_MAT+RC_PERIODO+RC_ROTEIR+RC_SEMANA+RC_PD"))
DbSelectArea("SRD")
DbSelectArea("SRA")
DbSetOrder(1)

If !lRotAuto
	oMBrowseDown:SetFilterDefault()//Elimina filtro do browse
EndIf

(cAliasBrw)->(DbGoTop())

If lIncBar
	While (cAliasBrw)->(!Eof())
		If ( cAliasBrw )->MARK == cMarca
			nTamBar1++
		EndIf
		(cAliasBrw)->(DbSkip())
	EndDo
	If nTamBar1 > 0
		BarGauge1Set( nTamBar1 )
	EndIf
	(cAliasBrw)->(DbGoTop())
EndIf

While (cAliasBrw)->(!Eof())
	If ( cAliasBrw )->MARK == cMarca
		aVinc 		:= {}
		aPerAtual 	:= {}
		aPd 		:= {}

		If lIncBar
			IncPrcG1Time( STR0027 +  ( cAliasBrw )->TAB_CPF + " - " +  ( cAliasBrw )->TAB_NOME , nTamBar1 , cTimeIni , .T. , 1 , 1 , .T. ) //"Processando funcionário "
		EndIf

		If (cAliasSRA)->(DbSeek((cAliasBrw)->TAB_CPF))
			While (cAliasSRA)->(!Eof() .and. RA_CIC == (cAliasBrw)->TAB_CPF)
				aPerAtual := {}
				fGetPerAtual( @aPerAtual, xFilial("RCH", (cAliasSRA)->RA_FILIAL), (cAliasSRA)->RA_PROCES, If((cAliasSRA)->RA_CATFUNC $ "A*P", fGetCalcRot("9"), fGetCalcRot("1")) )
				If Len(aPerAtual) > 0
					aAdd(aVinc, { (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_PROCES, (cAliasSRA)->RA_CATFUNC, aPerAtual[1,1], aPerAtual[1,2], aPerAtual[1,11] ,{}, (cAliasSRA)->RA_TIPOPGT})
				EndIf
				//Verifica se existe vínculo semanalista
				lSemanal := If( (cAliasSRA)->RA_TIPOPGT == "S", .T., lSemanal )
				(cAliasSRA)->(DbSkip())
			EndDo
		EndIf
		If Len(aVinc) > 1
			If lIncBar
				BarGauge2Set( Len(aVinc) )
			EndIf
			//Zera sequencia de todos os vínculos para utilizar a ordem atual
			For nX := 1 to Len(aVinc)
				cChave := aVinc[nX,1] + aVinc[nX,2] + aVinc[nX,5] + If(aVinc[nX,4] $ "A*P", fGetCalcRot("9"), fGetCalcRot("1")) +  aVinc[nX,6]
				If SRC->(DbSeek( cChave ))
					While SRC->( !Eof() .and. RC_FILIAL+RC_MAT+RC_PERIODO+RC_ROTEIR+RC_SEMANA == cChave )
						RecLock("SRC",.F.)
						SRC->RC_SEQMV := ""
						MsUnLock()
						SRC->(DbSkip())
					EndDo
				EndIf
			Next nX
			For nX := 1 to Len(aVinc)
				SRA->(DbSeek(aVinc[nX,1] + aVinc[nX,2]))

				If lIncBar
					IncPrcG2Time( STR0027 + SRA->RA_FILIAL + " - " + SRA->RA_MAT , Len(aVinc) , cTimeIni , .T. , 1 , 1 , .T. ) //"Processando funcionário "
				EndIf

				If nX == 1
					aAdd(aLogAux, STR0027 + SRA->RA_NOME ) //"Processando funcionário "
				EndIf

				cProcesso := aVinc[nX,3]
				cRoteiro  := If(aVinc[nX,4] $ "A*P", fGetCalcRot("9"), fGetCalcRot("1"))
				cPeriodo  := aVinc[nX,5]
				cSemana   := aVinc[nX,6]
				cFilAnt	  := SRA->RA_FILIAL

				cFilter := ""					
				cFilter += " RA_FILIAL == '" + SRA->RA_FILIAL + "'"
				cFilter += " .and. RA_MAT == '" + SRA->RA_MAT + "'"			

				Gpem020(.T.,;			//Define Que a Chamada Esta Sendo Efetuada Atraves do WorkFlow
						cProcesso,;		//Define o processo que sera calculado
						cRoteiro,;		//Define o roteiro que sera calculado
						cFilter;		//Filtro executado na rotina
						)

				aLogAux2 := AClone( fGetaLogExt() )
				If Empty(aLogAux2)
					aAdd(aLogAux, Space(10) + aVinc[nX,1] + " - " + aVinc[nX,2] + STR0028) //": Calculado"
				Else
					aAdd(aLogAux, Space(10) + aVinc[nX,1] + " - " + aVinc[nX,2] + ":")
					For nY := 1 To Len(aLogAux2)
						aAdd(aLOgAux, Space(15) + aLogAux2[nY])
					Next nY
				EndIf

				fRstaLogExt()
				RstExecCalc() //Reseta variaveis staticas utilizadas no cálculo
				RstGpexIni()
			Next nX
			aAdd(aLogItens,aLogAux)
		EndIf
	EndIf 
	(cAliasBrw)->(DbSkip())
EndDo

cFilAnt := cFilAux

If !lRotAuto
	If !Empty(aLogItens)
		aAdd(aLogTitle, STR0029) //"Vínculos processados"
		MsAguarde( { || fMakeLog( aLogItens, aLogTitle , "GPEM930" , NIL , FunName() , STR0030 ) } ,  STR0030) //"Log de cálculo dos múltiplos vínculos"
	Else
		Alert(STR0031) //"Nenhum cálculo efetuado!"
	EndIf	

	RestArea(aAreaMULTV)
	RestArea(aAreaSRA)
	RestArea(aArea)

	oMBrowseDown:SetFilterDefault("RA_CIC == (cAliasBrw)->TAB_CPF")//REFAZ O FILTRO
	oMBrowseUp:Refresh()
	oMBrowseDown:Refresh()
EndIf

Return .T.

/*/{Protheus.doc} Gp930Rec
Abre o recibo de pagamento do funcionário
@author Leandro.Drumond
@since 19/03/2020
@version P12
/*/
Static Function Gp930Rec()
Local cFilAux := cFilAnt
	
DbSelectArea("SRA")
DbSetOrder(1)

SRA->(DbSeek((cAliasSRA)->(RA_FILIAL + RA_MAT)))

cFilAnt := SRA->RA_FILIAL

Gpea630(2,2) //Abre o recibo de pagamento

cFilAnt := cFilAux

SRA->(DbSetFilter({||.T.}, ".T.")) //Limpa filtro criado pela rotina do recibo de pagamento

Return Nil
