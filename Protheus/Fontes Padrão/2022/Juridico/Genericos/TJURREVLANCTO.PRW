#INCLUDE "PROTHEUS.CH"
#INCLUDE "TJURREVLANCTO.CH"
#INCLUDE "FWMVCDEF.CH"
#DEFINE ID           1 // Id do Celula
/******************************************
//Estrutura dos arrays de lançamentos:  
**/

#DEFINE LN_CONTRATO  1 // Linha do Contrato.
#DEFINE LN_CASO      2 // Linha do Caso.
#DEFINE LN_LANC      3 // Linha do Lancamento.

#DEFINE NPOSCLI      4 // Cliente.
#DEFINE NPOSLOJA     5 // Loja.
#DEFINE NPOSCASO     6 // Caso.
#DEFINE NPOSCODLAN   7 // Cód Lançamento.
#DEFINE NPOSDTLAN    8 // Data Lançamento.
#DEFINE NPOSPART     9 // Participante do lançamento.
#DEFINE NPOSTPLAN    10 // Tipo de [atividade / despesa / serviço ]..
#DEFINE NPOSDESCR    11 // Descrição.
#DEFINE NPOSUTMOE    12 // [UTL / Moeda].
#DEFINE NPOSUTVLR    13 // [UTR / Valor]
#DEFINE NPOSWO       14 // WO.
#DEFINE NPOSDE       15 // D.E.
#DEFINE NPOSCOBRA    16 // Cobrar.
#DEFINE NPOSREVIS    17 // Revisado.
#DEFINE NPOSRETIR    18 // Retirar.
#DEFINE NPOSTRANS    19 // Transferir 
#DEFINE NPOSTSVLH    20 // Valor Hora do timeSheet
#DEFINE NPOSTSVL1    21 // Valor Total do TimeSheet
#DEFINE NPOSCPART2   22 // Código do Participante Revisado

#DEFINE DRAW	20

/******************************************
//Estrutura do array de resumo de TS selecionados
**/
//#DEFINE NPOSREVISA	 1	// Permite revisar

#DEFINE NPOSFILRES 1	// 1 - Filtrar
#DEFINE NPOSRETRES 2	// 2 - Retirar
#DEFINE NPOSWORES  3	// 3 - WO
#DEFINE NPOSPARRES 4	// 4 - Cod Participante
#DEFINE NPOSNOMRES 5	// 5 - Nome Participante
#DEFINE NPOSUTTOT  6	// 6 - Uts	- Total
#DEFINE NPOSUTCPRS 7	// 7 - Uts - CPart
#DEFINE NPOSUTSPRS 8	// 8 - Uts - SPart
#DEFINE NPOSVLHRS  9	// 9 - Valor hora
#DEFINE NPOSVLTRES 10	// 10 - Valor Total
#DEFINE NPOSCONTTS 11	// 8- Count
/******************************************
//Estrutura do array de resumo de Despesas e tabelados    selecionados
// Iguais: NPOSFILRES /  NPOSRETRES / NPOSWORES
**/
#DEFINE NPOSTPLRES 4	// 4 - Tipo de lançamento ( Despesas / Tabelados )
#DEFINE NPOSUTMOER 6	// 6 - Moeda ( Despesas / Tabelados )
#DEFINE NPOSVLDRES 7	// 7 - Valor ( Despesas / Tabelados )
#DEFINE NPOSCONTDP 8	// 8 - Count

/******************************************
Estrutura do array de controle do resumo
**/
#DEFINE NPOSFILRT 1	// 1 - Filtrar
#DEFINE NPOSRETRT 2	// 2 - Retirar
#DEFINE NPOSWORT  3	// 3 - WO
#DEFINE NPOSCLIRT 4 // Cliente
#DEFINE NPOSLOJRT 5 // Loja
#DEFINE NPOSCASRT 6 // Caso
//Agrupamento TS
#DEFINE NPOSPARRT 7 // Participante
#DEFINE NPOSVLHRT 8 // VlH
//Atrupamento DESP / TAB
#DEFINE NPOSTPLRT 7 // Tip Desp / Serv
#DEFINE NPOSMOERT 8 // Moeda


/******************************************
//Estrutura do array de Casos - controle das flags
// Iguais: 
**/
#DEFINE NPOSCASCLI 1 // Cliente
#DEFINE NPOSCASLOJ 2 // Loja
#DEFINE NPOSCASCOD 3 // Caso
#DEFINE NPOSCASWO  4 // WO
#DEFINE NPOSCASCOB 5 // Cobrar
#DEFINE NPOSCASREV 6 // Revisado
#DEFINE NPOSCASRET 7 // Retirar
#DEFINE NPOSCASTRA 8 // Transferir 
Static _lFwPDCanUse := FindFunction("FwPDCanUse")

Function __TJURREVLANCTO() // Function Dummy
ApMsgInfo( "TJRATEIOAD -> Utilizar Classe ao inves da funcao" )
Return NIL

Class TJURREVLANCTO
	
	Data	oMainPanel
	Data	aHorizPnl
	Data	aLines
	Data	aTitle
	Data	aCompTit
	Data	nRows
	Data	nTitleSz
	Data	lTitle
	
	Data	oPNav
				
	Data	oButTop
	Data	oButPUp
	Data	oButPDn
	Data	oButBot
	
	Data	cTipo
	Data	aSelItems
	Data	aItems
	Data	aComps
	Data	lTemLanc
	
	Data	nPrimeiro
	Data	nUltimo
	
	Data	oGridResumo
	Data	aResumo
	Data	aDadosRes
	Data	aSelRes
	Data	aListCas
	
	Data	cClien
	Data	cLoja
	Data	cCaso
	Data 	aAreas
	Data	lResumo
	
	Data	oGrpOrdem
	Data	nOrdemLanc
	Data	oGrpPeriod
	Data	oPerIni
	Data	oPerFim
	Data	dPerIni
	Data	dPerFim
	
	Data 	oGrpAcoes
	Data	oGrpFiltro

	Data 	lCkWO
	Data 	lCkRet
	Data 	lCkCob
	Data 	lCkRev
	Data 	lCkTran

	Data 	oCkWO
	Data 	oCkRet
	Data 	oCkCob
	Data 	oCkRev
	Data 	oCkTran
	Data	ParentView
	Data	lEnable
	Data	oModel
	Data	oView
	Data	nTipoApon
	Data	cCpoLanc
	Data	cCpoRev
	Data	cCpoRes
	
	Data	oBotT  
	Data	oBotN
	Data	opnlGroup

	Method New( cTipo, oParent, oView )
	Method AddLinesLanctos (  cTpLancto, lResumo )
	Method AddLinesResumo( aHeader )
	Method AddNavBar ( oParent )

	Method LoadLines()
	Method DrawLines( nLnPanel,  cCod )
	Method SetValue (cTipo, cCodLanc, cCampo, cValorNew, cValorOld)

	Method Primeiro ( )
	Method Ultimo ( )
	Method Proximo ( )
	Method Anterior ( )
	Method ResetObjts()
	Method ClearLines()
	
	Method SetArrayLanc(aLanc) 
	Method setArrayRes()
	Method SelectLancs(cClien, cLoja, cCaso, cComp, xValorOld, xValorNew)
	
	Method SetCheck( cCod , oCheck )
	Method ExecCheck(cCodLanc , nColLanc, lForce)
	Method AjustaFoco()
	Method MarcaChecks()
	Method MontaGrid(oBrowse, aBrowse )

	Method Resumo(cTipo)
	Method HeaderCampo(cCampo) 
	Method SetResTS() 
	Method SetResDP()
	Method SetResTB()
	Method setListaCasos(aListaCas)  
	Method ClearArea()
	
	Method RefreshResumo( )
	Method EditCel (aArray, oBrowse, cForce)
	Method setUpdated() 
	
	
	Method Refresh()
	Method SelectTSPart(cClien, cLoja, cCaso, cPart, cVlH)
	Method SelectDPTipo(cClien, cLoja, cCaso, cTpDesp, cMoeda) 
	
	Method CriaAcoes ()  
	Method OrderLanc(nCampo)
	Method SetDtIni(dData)
	Method SetDtFim(dData)
	
	Method LimpaRef()
	Method Disable()
	Method Enable()
	Method GoToLine()
	Method UpdateRevisado()
	Method UpdateValores()
	Method GetMdlLancto()
	
	Method Filtra()
	Method FiltraTudo(ntemp)

EndClass

Method New(cTipo, oParent, oView) Class TJURREVLANCTO
	self:lEnable    := .F.
	self:nOrdemLanc := 1
	self:aAreas     := {}
	self:lResumo    := .F.
	self:oMainPanel := TJurPanel():New( 00, 00, 00, 00, oParent, "", .F., .T., CONTROL_ALIGN_ALLCLIENT )
	Self:aTitle     := {}
	self:aLines     := {}
	self:nRows      := 4 
	self:nTitleSz   := 7
	self:lTitle     := .T.
	self:aComps     := {}
	self:nPrimeiro  := 1
	self:nUltimo    := self:nRows
	self:aItems     := {}
	self:aSelItems  := {}
	self:cTipo      := cTipo
	Self:ParentView := oView

	Self:lCkWO		 := .F.
	Self:lCkRet		 := .F.
	Self:lCkCob		 := .F.
	Self:lCkRev		 := .F.
	Self:lCkTran	 := .F.
	self:lTemLanc	 := .F.
	self:AddNavBar(oParent)
	self:aResumo   := {}
	self:aSelRes 	:= {}
	self:aDadosRes	:= {}
	self:aListCas  := {}

	self:dPerIni	:= date()
	self:dPerFim	:= date()
	self:oModel   := FwModelActive()
	self:oView    := FwViewActive()
	
	self:nTipoApon	:= SuperGetMV( 'MV_JURTS2',, 1 )
	Do Case
		Case self:nTipoApon == 1
			self:cCpoLanc	:= "NUE_UTL"
			self:cCpoRev	:= "NUE_UTR"
			self:cCpoRes	:= "NX2_UTR"
		Case self:nTipoApon == 2
			self:cCpoLanc	:= "NUE_TEMPOL"
			self:cCpoRev	:= "NUE_TEMPOR"
			self:cCpoRes	:= "NX2_TEMPOR"
		Case self:nTipoApon == 3
			self:cCpoLanc	:= "NUE_HORAL"
			self:cCpoRev	:= "NUE_HORAR"
			self:cCpoRes	:= "NX2_HORAR"
	EndCase

Return self

Method AddLinesLanctos (cTpLancto, lResumo) Class TJURREVLANCTO
Local nLoop := 0
Local uTemp := cTpLancto
Local nLine	:= 0
Local nPercRes := If( lResumo, 40, 0 )
Self:aTitle		:= {STR0001,STR0002,STR0003} // "Lançamento","Descrição","Valores / Controles"

	for nLoop := 0 to self:nRows
	
		&( uTemp ) := self:oMainPanel:AddHorizontalPanel( if( nLoop == 0 .AND. self:lTitle , self:nTitleSz, ( (100-self:nTitleSz-nPercRes) / (self:nRows)) ) )
		&( uTemp + "1" ) := self:oMainPanel:AddVerticalPanel( 22, &( uTemp ), if( nLoop == 0.AND. self:lTitle, CLR_GRAY, CLR_WHITE ) )
		&( uTemp + "2" ) := self:oMainPanel:AddVerticalPanel( 45, &( uTemp ), if( nLoop == 0.AND. self:lTitle, CLR_GRAY, CLR_WHITE ) )
		&( uTemp + "3" ) := self:oMainPanel:AddVerticalPanel( 38, &( uTemp ), if( nLoop == 0.AND. self:lTitle, CLR_GRAY, CLR_WHITE ) )
		
		aadd(self:aLines, { &( uTemp + "1" ), &( uTemp + "2" ), &( uTemp + "3" )  }  )

		nLine := len(self:aLines)


		If nLoop == 0 .AND. self:lTitle

			&( uTemp +"T1" ) := tSay():New( 03, 02, { || self:aTitle[1] }, self:oMainPanel:GetPanel( self:aLines[nLine][1] ), , , , , , .T., CLR_WHITE, , 100, 15 )
			&( uTemp +"T2" ) := tSay():New( 03, 02, { || self:aTitle[2] }, self:oMainPanel:GetPanel( self:aLines[nLine][2] ), , , , , , .T., CLR_WHITE, , 100, 15 )
			&( uTemp +"T3" ) := tSay():New( 03, 02, { || self:aTitle[3] }, self:oMainPanel:GetPanel( self:aLines[nLine][3] ), , , , , , .T., CLR_WHITE, , 100, 15 )	

		EndIf
		self:aCompTit :=  { &( uTemp + "1" ), &( uTemp + "2" ), &( uTemp + "3" )  }
		
		aadd(self:aAreas, {"1", nLoop, &( uTemp ) })
	next nLoop  
	
	If lResumo 
		&( uTemp +"R" ) := self:oMainPanel:AddHorizontalPanel( nPercRes )  
		&( uTemp + "RL" ) := self:oMainPanel:AddVerticalPanel( 67, &( uTemp +"R" ), CLR_WHITE )
		&( uTemp + "RR" ) := self:oMainPanel:AddVerticalPanel( 38, &( uTemp +"R" ), CLR_WHITE )

		self:aResumo :=  { &( uTemp + "RL" ), &( uTemp + "RR" )  }
		aadd(self:aAreas, {"2", 1, &( uTemp +"R" ) } )
	EndIf
		
Return nil

Method AddLinesResumo( aHeader )  Class TJURREVLANCTO

	self:lResumo := .T.

	// Cria Browse
	self:oGridResumo := MsNewGetDados():New(000,000,000,000,GD_UPDATE+GD_INSERT, "AllwaysTrue()", "AllwaysTrue()" , , , , 999,,,,self:oMainPanel:GetPanel( self:aResumo[1] ),aHeader,{})
	self:oGridResumo:aCols	:= self:aSelRes

	self:oGridResumo:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT // CONTROL_ALIGN_ALLCLIENT
	self:oGridResumo:lInsert := .F.
	self:oGridResumo:lDelete := .F.

	self:oGridResumo:oBrowse:bLDblClick     := {|| ( self:EditCel(self:aSelRes, self:oGridResumo:oBrowse, "" ) , self:AjustaFoco(), self:oGridResumo:oBrowse:Refresh() ) }
	self:oGridResumo:oBrowse:bCustomEditCol := {|| ( self:EditCel(self:aSelRes, self:oGridResumo:oBrowse, "" ) , self:AjustaFoco() ) }

	//self:oGridResumo:oBrowse:bFieldOk := {|| Self:vldGrid() }

	self:oGridResumo:oBrowse:Refresh()

Return nil

Method EditCel( aBrowse, oBrowse, cForce )  Class TJURREVLANCTO
Local lRet			:= .F.
Local lAchou		:= .F.
Local cPicture 		:= ""
Local nI 			:= 0
Local xValueold		:= aBrowse[oBrowse:nAt][oBrowse:nColPos]
Local xValueNew		:= aBrowse[oBrowse:nAt][oBrowse:nColPos]
Local nVlHOld		:= aBrowse[oBrowse:nAt][NPOSVLHRS]
Local oModelNX0		:= self:oModel:GetModel("NX0MASTER")
Local oModelNX8		:= self:oModel:GetModel("NX8DETAIL")
Local oModelNX1		:= self:oModel:GetModel("NX1DETAIL")
Local oModelNX2		:= self:oModel:GetModel("NX2DETAIL")
Local nLinNX1		:= 0
Local nLinNX8		:= 0
Local nLinNX2		:= 0
Local nPos			:= 0
Local nPos2
Local nPos3			:= 0
Local nVlrconv		:= 0

	IF Self:lEnable
	
		If 	self:cTipo == "TS" .AND. !(;
			oBrowse:nColPos == NPOSFILRES .OR. ;
			oBrowse:nColPos == NPOSRETRES .OR. ;
			oBrowse:nColPos == NPOSWORES  .OR. ;
			oBrowse:nColPos == NPOSUTSPRS .OR. ;
			oBrowse:nColPos == NPOSVLTRES .OR. ;
			oBrowse:nColPos == NPOSVLHRS )
			Return .F.
		EndIf
	
		If 	self:cTipo == "DP" .OR. self:cTipo == "TB"
			If	!(	oBrowse:nColPos == NPOSFILRES .OR. ;
					oBrowse:nColPos == NPOSRETRES .OR. ;
					oBrowse:nColPos == NPOSWORES  ;
				)
				Return .F.
			EndIf
		EndIf
	Else
		If !( oBrowse:nColPos == NPOSFILRES )
			 Return .F.
		EndIf
	EndIF
	
	If valtype(aBrowse[oBrowse:nAt][oBrowse:nColPos]) == "L" .OR. oBrowse:nColPos == NPOSFILRES .OR. oBrowse:nColPos == NPOSRETRES .OR. oBrowse:nColPos == NPOSWORES
		IF Empty(cForce)
			aBrowse[oBrowse:nAt][oBrowse:nColPos] := If(aBrowse[oBrowse:nAt][oBrowse:nColPos] == "LBNO", "LBOK", "LBNO")
		Else
			aBrowse[oBrowse:nAt][oBrowse:nColPos] := IIF(cForce == "S", "LBOK", "LBNO")
		EndIf
		
		If oBrowse:nColPos == NPOSFILRES // //Se for a coluna de filtro
			If 	aBrowse[oBrowse:nAt][oBrowse:nColPos]  == "LBOK"
				Self:Filtra(aBrowse, oBrowse, .T.) //lExibe
			Else
				Self:Filtra(aBrowse, oBrowse, .F.)//lExibe
			EndIf			

			self:Primeiro()

		EndIf

		If oBrowse:nColPos == NPOSRETRES .OR. ; 	//Se for a coluna de Retirar
			 oBrowse:nColPos == NPOSWORES			//Se for a coluna de WO

      // Marca todos os lançamentos
			nPos2	:= aScan( self:aListCas, {|x| x[NPOSCASCLI] == self:cClien .AND.  x[NPOSCASLOJ] == self:cLoja .AND. x[NPOSCASCOD] == self:cCaso } )	

			If oBrowse:nColPos == NPOSRETRES
				nCpoMark := NPOSRETIR
				If !(aBrowse[oBrowse:nAt][oBrowse:nColPos] == "LBOK" )
					Self:lCkRet	:= .F.
					self:aListCas[nPos2][NPOSCASRET] := .F.
					self:oCkRet:lcheckjur	:= Self:lCkRet
				EndIF
			Else
				nCpoMark := NPOSWO
				If !(aBrowse[oBrowse:nAt][oBrowse:nColPos] == "LBOK" )
					Self:lCkWO	:= .F.
					self:aListCas[nPos2][NPOSCASWO]	:= .F.
					self:oCkWO:lcheckjur	:= Self:lCkWO
				EndIF
			EndIf

			For nI := 1 to Len( self:aItems )
				Do Case
					Case self:cTipo == "TS"
						If 	self:aItems[nI][NPOSCLI] 	== self:cClien .AND. ;
							self:aItems[nI][NPOSLOJA] 	== self:cloja .AND. ;
							self:aItems[nI][NPOSCASO] 	== self:cCaso .AND. ;
							self:aItems[nI][NPOSPART] 	== aBrowse[oBrowse:nAt][NPOSPARRES] .AND. ;
							self:aItems[nI][NPOSTSVLH] 	== aBrowse[oBrowse:nAt][NPOSVLHRS ]

							self:aItems[nI][nCpoMark]	:= (aBrowse[oBrowse:nAt][oBrowse:nColPos] == "LBOK")
							nPos := aScan( self:aSelItems , { |ax| ax[ NPOSCODLAN ] == self:aItems[nI][ NPOSCODLAN ] }  )
							If nPos > 0
								self:aSelItems[nPos][nCpoMark] := (aBrowse[oBrowse:nAt][oBrowse:nColPos] == "LBOK")
							EndIf
						EndIf
					Case self:cTipo == "DP"
						If self:aItems[nI][NPOSCLI] 	== self:cClien .AND. ;
							self:aItems[nI][NPOSLOJA] 	== self:cloja .AND. ;
							self:aItems[nI][NPOSCASO] 	== self:cCaso .AND. ;
							self:aItems[nI][NPOSTPLAN] 	== aBrowse[oBrowse:nAt][ NPOSTPLRES ] .AND. ;
							self:aItems[nI][NPOSUTMOE] 	== aBrowse[oBrowse:nAt][ NPOSUTMOER ]

							self:aItems[nI][nCpoMark]	:= (aBrowse[oBrowse:nAt][oBrowse:nColPos] == "LBOK")
							nPos := aScan( self:aSelItems , { |ax| ax[ NPOSCODLAN ] == self:aItems[nI][ NPOSCODLAN ] }  )
							If nPos > 0
								self:aSelItems[nPos][nCpoMark] := (aBrowse[oBrowse:nAt][oBrowse:nColPos] == "LBOK")
							EndIf
						EndIf
					Case  self:cTipo == "TB"					
						If 	self:aItems[nI][NPOSCLI] 	== self:cClien .AND. ;
							self:aItems[nI][NPOSLOJA] 	== self:cloja .AND. ;
							self:aItems[nI][NPOSCASO] 	== self:cCaso .AND. ;
							self:aItems[nI][NPOSTPLAN] 	== aBrowse[oBrowse:nAt][ NPOSTPLRES ] .AND. ;
							self:aItems[nI][NPOSUTMOE] 	== aBrowse[oBrowse:nAt][ NPOSUTMOER ]

							self:aItems[nI][nCpoMark]	:= (aBrowse[oBrowse:nAt][oBrowse:nColPos] == "LBOK")
							nPos := aScan( self:aSelItems , { |ax| ax[ NPOSCODLAN ] == self:aItems[nI][ NPOSCODLAN ] }  )
							If nPos > 0
								self:aSelItems[nPos][nCpoMark] := (aBrowse[oBrowse:nAt][oBrowse:nColPos] == "LBOK")
							EndIf
						EndIf
				EndCase

			Next nI

			self:Primeiro()

		EndIf

		If oBrowse:nColPos == NPOSWORES // //Se for a coluna de WO


		EndIf
        If self:cTipo == "TS"
			nPos3 := aScan	( self:aDadosRes,	{ |x|	x[NPOSCLIRT]	== self:cClien .AND.;
														x[NPOSLOJRT]	== self:cloja .AND.;
														x[NPOSCASRT]	== self:cCaso .AND.;
														x[NPOSPARRT]	== aBrowse[oBrowse:nAt][NPOSPARRES] .AND.;
														x[NPOSVLHRT]	== aBrowse[oBrowse:nAt][NPOSVLHRS ] ;
												};
							)
							
		Else
				nPos3 := aScan	( self:aDadosRes,	{ |x|	x[NPOSCLIRT]	== self:cClien .AND.;
															x[NPOSLOJRT]	== self:cloja .AND.;
															x[NPOSCASRT]	== self:cCaso .AND.;
															x[NPOSTPLRT]	== aBrowse[oBrowse:nAt][ NPOSTPLRES ] .AND.;
															x[NPOSMOERT]	== aBrowse[oBrowse:nAt][ NPOSUTMOER ] ;
													};
								)		
		EndIf
		
		If nPos3 > 0 
			self:aDadosRes[nPos3][NPOSFILRT] := aBrowse[oBrowse:nAt][NPOSFILRES]
			self:aDadosRes[nPos3][NPOSRETRT] := aBrowse[oBrowse:nAt][NPOSRETRES]
			self:aDadosRes[nPos3][NPOSWORT]  := aBrowse[oBrowse:nAt][NPOSWORES]
		EndIF

	Else
		If valtype(aBrowse[oBrowse:nAt,oBrowse:nColPos]) == "N"
			//lEditCell(aBrowse,oBrowse,self:oGridResumo:AHEADER[oBrowse:nColPos][3],oBrowse:nColPos) 
			lEditCol(oBrowse:nColPos,,,self:oGridResumo:oBrowse,self:oGridResumo)
		Else
			self:oGridResumo:EditCell()
		EndIf
	EndIf
	
	If self:cTipo == "TS" .AND. JurIN(oBrowse:nColPos, {NPOSUTSPRS, NPOSVLHRS, NPOSVLTRES, NPOSRETRES, NPOSWORES} )

		xValueNew := aBrowse[oBrowse:nAt][oBrowse:nColPos]
		Do Case
			Case oBrowse:nColPos == NPOSFILRES // Flag de Filtro 
			
			Case JurIN(oBrowse:nColPos, {NPOSRETRES, NPOSWORES} ) // Retirar e WO
				cCampo := "NX2_TKRET"
				xValueNew := aBrowse[oBrowse:nAt][oBrowse:nColPos] == "LBOK"
			Case oBrowse:nColPos == NPOSPARRES // Sigla Part /  NPOSNOMRES - Nome Participante
				//Não muda
			Case oBrowse:nColPos == NPOSUTSPRS // UT Rev
				cCampo := self:cCpoRes
			Case oBrowse:nColPos == NPOSVLHRS // Valor H
				cCampo 	:= "NX2_VALORH"
				nVlHOld	:= xValueOld
			Case oBrowse:nColPos == NPOSVLTRES // Valor TS
				cCampo := "NX2_VALOR1"
		EndCase

		nPosNX8 := oModelNX8:nLine
		nPosNX1 := oModelNX1:nLine
		nPosNX2 := oModelNX2:nLine
		
		For nLinNX8 := 1 to oModelNX8:Length()
			oModelNX8:GoLine(nLinNX8)
			For nLinNX1 := 1 to oModelNX1:Length()
				oModelNX1:GoLine(nLinNX1)
				For nLinNX2 := 1 to oModelNX2:Length()
					oModelNX2:GoLine(nLinNX2)
					
					nVlrconv := JA201FConv(oModelNX2:GetValue("NX2_CMOPRE" ), oModelNX2:GetValue("NX2_CMOTBH" ), oModelNX2:GetValue("NX2_VALORH"), "2", oModelNX0:GetValue("NX0_DTEMI"), ,oModelNX0:GetValue("NX0_COD"))[1]
		            
					If 	self:cClien	==	oModelNX2:GetValue("NX2_CCLIEN" ) .AND.;
						self:cloja	==	oModelNX2:GetValue("NX2_CLOJA" ) .AND.;
						self:cCaso	==	oModelNX2:GetValue("NX2_CCASO" ) .AND.;
						aBrowse[oBrowse:nAt][NPOSPARRES] == oModelNX2:GetValue("NX2_SIGLA" ) .AND.;
						nVlHOld == nVlrconv
						//xValueold == oModelNX2:GetValue("NX2_VALORH")
						//aBrowse[oBrowse:nAt][NPOSVLHRS] == oModelNX2:GetValue("NX2_VALORH")
						lAchou := .T.
						lRet   := JurSetValue( oModelNX2, cCampo, ,xValueNew, .T. )
						If JurIN(oBrowse:nColPos, {NPOSRETRES, NPOSWORES} ) // Retirar e WO
							aBrowse[oBrowse:nAt][oBrowse:nColPos] := IIF(oModelNX2:GetValue(cCampo), "LBOK", "LBNO")
						Else
							aBrowse[oBrowse:nAt][oBrowse:nColPos] := oModelNX2:GetValue(cCampo)
						EndIf
						aBrowse[oBrowse:nAt][NPOSVLTRES]      := oModelNX2:GetValue( "NX2_VALOR1" )
					EndIf
		
					If lAchou
						Exit
					EndIf
				Next nLinNX2
			Next nLinNX1
			If lAchou
				Exit
			EndIf
		Next nLinNX8		
	
			
		oModelNX8:GoLine(nPosNX8)
		oModelNX1:GoLine(nPosNX1)
		oModelNX2:GoLine(nPosNX2)
		
		If !lAchou
			self:setUpdated()
		EndIf
	EndIf
  
	If JurIN(self:cTipo, {"DP", "TB"}) .AND. JurIN(oBrowse:nColPos, {NPOSRETRES, NPOSWORES} )
		
		nPosNX8 := oModelNX8:GetLine()
		nPosNX1 := oModelNX1:GetLine()		

		For nLinNX8 := 1 to oModelNX8:Length()
			oModelNX8:GoLine(nLinNX8)
			For nLinNX1 := 1 to oModelNX1:Length()
				oModelNX1:GoLine(nLinNX1)
				
				If 	self:cClien	==	oModelNX1:GetValue("NX1_CCLIEN" ) .AND.;
					self:cloja	==	oModelNX1:GetValue("NX1_CLOJA" ) .AND.;
					self:cCaso	==	oModelNX1:GetValue("NX1_CCASO" )
												
					self:setUpdated()
					
				EndIf

			Next nLinNX1
			If lAchou
				Exit
			EndIf
		Next nLinNX8	
		
		oModelNX8:GoLine(nPosNX8)
		oModelNX1:GoLine(nPosNX1)
	EndIf

	//MsgRun(STR0025, ,{|| self:ParentView:Refresh(), self:Refresh() }) // "Aguarde..."
	Do Case
		Case self:cTipo == "TS"
			Self:ParentView:Refresh("NUEDETAIL")
		Case self:cTipo == "DP"
			Self:ParentView:Refresh("NVYDETAIL")
		Case self:cTipo == "TB"
			Self:ParentView:Refresh("NV4DETAIL")
	EndCase
	self:Refresh()
	//self:RefreshResumo()

Return lRet
//Marca o registro corrente como alterado, para ser possível confirmar a tela.
Method setUpdated()   Class TJURREVLANCTO
Local oModelLanc

	Do Case
		Case self:cTipo == "TS"
			oModelLanc := self:oModel:GetModel("NUEDETAIL")
			If !JMdlNewLine(oModelLanc)
				JurLoadValue(oModelLanc,"NUE_TKRET",,oModelLanc:GetValue("NUE_TKRET"))
			EndIf
		Case self:cTipo == "DP"
			oModelLanc := self:oModel:GetModel("NVYDETAIL")
			If !JMdlNewLine(oModelLanc)
				JurLoadValue(oModelLanc,"NVY_TKRET",,oModelLanc:GetValue("NVY_TKRET")) // Isto serve para deixar o modelo em estado de alteração!
			EndIf
		Case self:cTipo == "TB"
			oModelLanc := self:oModel:GetModel("NV4DETAIL")
			If !JMdlNewLine(oModelLanc)
				JurLoadValue(oModelLanc,"NV4_TKRET",,oModelLanc:GetValue("NV4_TKRET")) // Isto serve para deixar o modelo em estado de alteração!
			EndIf
	EndCase

Return nil

Method Resumo(cTipo)  Class TJURREVLANCTO
Local aHeader	:= {}

	Do Case
		Case cTipo == "TS"
			aHeader	:= {}
			aADD( aHeader,  { STR0004, 'lFiltrar', "@BMP", 1, 0, "AllwaysTrue()" ,".T." ,"L", "", "", "", "", ".F." } ) //"TJREVLANED(n, '"+ STR0004 +"' ) "	} ) // "Filtrar"
			aADD( aHeader,  { STR0017, 'lRetirar', "@BMP", 1, 0, "AllwaysTrue()" ,".T.", "L", "", "", "", "", ".F." } ) //"TJREVLANED(n, '"+ STR0017 +"' ) "	} ) // "Retirar"
			aADD( aHeader,  { STR0014, 'lWO'     , "@BMP", 1, 0, "AllwaysTrue()" ,".T.", "L", "", "", "", "", ".F." } ) //"TJREVLANED(n, '"+ STR0014 +"' ) "	} ) // "WO"
			aADD( aHeader,  self:HeaderCampo("NX2_SIGLA" ) )	// "Cód Part"
			aADD( aHeader,  self:HeaderCampo("NX2_DPART" ) )	// "Nome"

			If self:nTipoApon == 3
		 		aADD( aHeader,  { STR0026, 'nUtTotal'  , "9999:99", 7, 0, "AllwaysTrue()" ,"", "C", "", "", "", "" } )//, "TJREVLANED(n, '"+ STR0006 +"', " + IIF( self:lEnable, '.T.', '.F.' ) + " ) " } )  // "Ut Total"	
				aADD( aHeader,  { STR0027, "nUTComPart", "9999:99", 7, 0, "AllwaysTrue()" ,"", "C", "", "", "", "" } )//, "TJREVLANED(n, '"+ STR0006 +"', " + IIF( self:lEnable, '.T.', '.F.' ) + " ) " } )  // "UT Com Part"
			ElseIf self:nTipoApon == 2
		 		aADD( aHeader,  { STR0026, 'nUtTotal'  , "@E 99,999,999,999.99", 14, 2, "AllwaysTrue()" ,"", "N", "", "", "", "" } )//, "TJREVLANED(n, '"+ STR0006 +"', " + IIF( self:lEnable, '.T.', '.F.' ) + " ) " } )  // "Ut Total"	
				aADD( aHeader,  { STR0027, "nUTComPart", "@E 99,999,999,999.99", 14, 2, "AllwaysTrue()" ,"", "N", "", "", "", "" } )//, "TJREVLANED(n, '"+ STR0006 +"', " + IIF( self:lEnable, '.T.', '.F.' ) + " ) " } )  // "UT Com Part"			
			Else
		 		aADD( aHeader,  { STR0005, 'nUtTotal'  , "@E 99,999,999,999.99", 14, 2, "AllwaysTrue()" ,"", "N", "", "", "", "" } )//, "TJREVLANED(n, '"+ STR0006 +"', " + IIF( self:lEnable, '.T.', '.F.' ) + " ) " } )  // "Ut Total"	
				aADD( aHeader,  { STR0006, "nUTComPart", "@E 99,999,999,999.99", 14, 2, "AllwaysTrue()" ,"", "N", "", "", "", "" } )//, "TJREVLANED(n, '"+ STR0006 +"', " + IIF( self:lEnable, '.T.', '.F.' ) + " ) " } )  // "UT Com Part"
			EndIF

			aADD( aHeader,  self:HeaderCampo(self:cCpoRes) 	)   // "UT Sem Part"
				
			aADD( aHeader,  self:HeaderCampo("NX2_VALORH") 	)	// "Valor H"
			aADD( aHeader,  self:HeaderCampo("NX2_VALOR1") 	)	// "Valor TS"
			aADD( aHeader,  { STR0008, "nNumlanctos", "999,999,999", 9, 0, "AllwaysTrue()" ,".T.", "N", "", "", "", "", ".F."} )//, "TJREVLANED(n, '"+ STR0008 +"' ) "	}  ) // Num lanctos

			self:SetResTS()
			self:AddLinesResumo( aHeader )
			self:CriaAcoes ()

		Case cTipo == "DP"
			aHeader	:= {}
			aADD( aHeader,  { STR0004, 'lFiltrar', "@BMP", 1, 0, "AllwaysTrue()", ".T.", "L", "", "", "", "", ".F." } ) //"TJREVLANED(n, '"+ STR0004 +"' ) "	} ) // "Filtrar"
			aADD( aHeader,  { STR0017, 'lRetirar', "@BMP", 1, 0, "AllwaysTrue()", ".T.", "L", "", "", "", "", ".F." } ) //"TJREVLANED(n, '"+ STR0017 +"' ) "	} ) // "Retirar"
			aADD( aHeader,  { STR0014, 'lWO'     , "@BMP", 1, 0, "AllwaysTrue()" ,".T.", "L", "", "", "", "", ".F." } ) //"TJREVLANED(n, '"+ STR0014 +"' ) "	} ) // "WO"
			aADD( aHeader,  self:HeaderCampo("NVY_CTPDSP" ) )	// "Cód Part"
			aADD( aHeader,  self:HeaderCampo("NVY_DTPDSP" ) )	// "Nome"
			aADD( aHeader,  self:HeaderCampo("NVY_DMOEDA" ) )	// "Valor H"
			aADD( aHeader,  self:HeaderCampo("NVY_VALOR"  ) )	// "Valor TS"
			aADD( aHeader,  { STR0008, "nNumlanctos", "999,999,999", 9, 0, "AllwaysTrue()" ,".T.", "N", "", "", "", "", ".F."	} )  // Num lanctos

			self:SetResDP()
			self:AddLinesResumo( aHeader )
			self:CriaAcoes ()

		Case cTipo == "TB"
			aHeader	:= {}
			aADD( aHeader,  { STR0004, 'lFiltrar', "@BMP", 1, 0, "AllwaysTrue()" ,".T.", "L", "", "", "", "", ".F." } ) //"TJREVLANED(n, '"+ STR0004 +"' ) "	} ) // "Filtrar"
			aADD( aHeader,  { STR0017, 'lRetirar', "@BMP", 1, 0, "AllwaysTrue()" ,".T.", "L", "", "", "", "", ".F." } ) //"TJREVLANED(n, '"+ STR0017 +"' ) "	} ) // "Retirar"
			aADD( aHeader,  { STR0014, 'lWO'     , "@BMP", 1, 0, "AllwaysTrue()" ,".T.", "L", "", "", "", "", ".F." } ) //"TJREVLANED(n, '"+ STR0014 +"' ) "	} ) // "WO"
			aADD( aHeader,  self:HeaderCampo("NV4_CTPSRV" ) )	// "Cód Part"
			aADD( aHeader,  self:HeaderCampo("NV4_DTPSRV" ) )	// "Nome"
			aADD( aHeader,  self:HeaderCampo("NV4_DMOEH") )	// "Valor H"
			aADD( aHeader,  self:HeaderCampo("NV4_VLHFAT") )	// "Valor TS"
			aADD( aHeader,  { STR0008, "nNumlanctos", "999,999,999", 9, 0, "AllwaysTrue()" ,".T.", "N", "", "", "", "", ".F."	} )  // Num lanctos

			self:SetResTB()
			self:AddLinesResumo( aHeader )
			self:CriaAcoes ()

		OtherWise
			Alert(STR0009) //"Opção não disponível"

	EndCase
	
   
//	self:oGridResumo:bLinhaOk := {||.T.}
	If self:aSelRes[1][len(self:aSelRes[1])-1] == 0 //qtd de lançamentos
		self:oGridResumo:oBrowse:lReadOnly := .T. 
		self:oGridResumo:Disable()
	Else
		self:oGridResumo:oBrowse:lReadOnly := .F. 
		self:oGridResumo:Enable()
	EndIF

Return Nil

Method HeaderCampo(cCampo, cTipo, lEdita, cPict) Class TJURREVLANCTO 
Local aHeadCampo := {}
Local aInfCampo := {}

	If !Empty(cCampo)

		aInfCampo	:= AVSX3(cCampo)
		
		aAdd(aHeadCampo,  aInfCampo[5]  ) 		//	 1- Título
		aAdd(aHeadCampo,  cCampo		) 		//	 2- Campo
		aAdd(aHeadCampo,  If(aInfCampo[2] == "C" .AND. Empty(aInfCampo[6]), "@!" , aInfCampo[6])  )		//	 3- Picture
		aAdd(aHeadCampo,  aInfCampo[3]  ) 		// 	 4- Tamanho
		aAdd(aHeadCampo,  aInfCampo[4]  ) 		//	 5- Decimal
		aAdd(aHeadCampo,  "AllwaysTrue()")		//	 6- Validação
		aAdd(aHeadCampo,  ""			) 		//	 7- Usado
		aAdd(aHeadCampo,  aInfCampo[2]  ) 		//	 8- Tipo
		aAdd(aHeadCampo,  ""			) 		//	 9- F3
		aAdd(aHeadCampo,  ""			) 		//	10- Contexto ( Real ou Virtual )
		aAdd(aHeadCampo,  ""			)		//	11- Opções
		aAdd(aHeadCampo,  ""			)		//	12-	Inicializador Padrão
		//aAdd(aHeadCampo,  "TJREVLANED(n, '"+ cCampo  +"' ) "	)		//	13-	Modo de Edição
		
EndIf

Return aHeadCampo

Method SetResTS(lCria) Class TJURREVLANCTO 
Local nI 		:= 0
Local nPos		:= 0
Local nPos2		:= 0
Local nUtTot	:= 0
Local nUtCPart	:= 0
Local nUtSPart	:= 0
Local nPartCli	:= "2"

Default lCria	:= .F.
	
	self:aSelRes	:={}

	If !Empty(self:aItems)
		
		For nI := 1 to Len(self:aItems)
		
			IF	(self:aItems[nI][NPOSCLI] 	== self:cClien) .AND.;
				(self:aItems[nI][NPOSLOJA]	== self:cLoja) .AND.;
				(self:aItems[nI][NPOSCASO] 	== self:cCaso)
		
				nPartCli := Posicione( "NRC", 1, xFilial("NRC") +  Alltrim(self:aItems[ nI ][NPOSTPLAN]) ,  "NRC_PART" )
				nUt		:= self:aItems[ nI ][NPOSUTVLR]
				If nPartCli == "1"
					nUtSPart	:= 0
					nUtCPart	:= nUt
				Else
				    nUtSPart	:= nUt
				    nUtCPart	:= 0
				EndIf
			
				//Campos de Agrupamento (TS: participante e valor hora)
				nPos := aScan	( self:aSelRes,	{ |x| 	x[NPOSPARRES]	== self:aItems[ nI ] [ NPOSPART  ] .AND.;
															x[NPOSVLHRS]	== self:aItems[ nI ] [ NPOSTSVLH ] ;
													};
								)

				nPos2 := aScan	( self:aDadosRes,	{ |x|	x[NPOSCLIRT]	== self:aItems[ nI ] [ NPOSCLI ] .AND.;
															x[NPOSLOJRT]	== self:aItems[ nI ] [ NPOSLOJA ] .AND.;
															x[NPOSCASRT]	== self:aItems[ nI ] [ NPOSCASO ] .AND.;
															x[NPOSPARRT]	== self:aItems[ nI ] [ NPOSPART  ] .AND.;
															x[NPOSVLHRT]	== self:aItems[ nI ] [ NPOSTSVLH ] ;
													};
								)
				If nPos > 0 
					IF self:nTipoApon == 3 // tratar a soma de hh:mm + hh:mm
						self:aSelRes[nPos][NPOSUTTOT] 	:= JA202SomaH(self:aSelRes[nPos][NPOSUTTOT], nUt ) 
						self:aSelRes[nPos][NPOSUTCPRS]	:= JA202SomaH(self:aSelRes[nPos][NPOSUTCPRS], nUtCPart)
						self:aSelRes[nPos][NPOSUTSPRS]	:= JA202SomaH(self:aSelRes[nPos][NPOSUTSPRS], nUtSPart)
					Else
						self:aSelRes[nPos][NPOSUTTOT]		:= self:aSelRes[nPos][NPOSUTTOT] + nUt
						self:aSelRes[nPos][NPOSUTCPRS]	:= self:aSelRes[nPos][NPOSUTCPRS]  + nUtCPart			
						self:aSelRes[nPos][NPOSUTSPRS]	:= self:aSelRes[nPos][NPOSUTSPRS]  + nUtSPart								
					EndIf
					self:aSelRes[nPos][NPOSVLHRS]		:= self:aItems[ nI ][NPOSTSVLH]
					self:aSelRes[nPos][NPOSVLTRES]	:= self:aSelRes[nPos][NPOSVLTRES] + self:aItems[ nI ][ NPOSTSVL1 ]
					self:aSelRes[nPos][NPOSCONTTS]	:= self:aSelRes[nPos][NPOSCONTTS] + 1
				Else                                                                                             	

					IF self:nTipoApon == 3 // tratar a soma de hh:mm + hh:mm
						nUt			:= JA202SomaH(nUt, 0) 
						nUtCPart	:= JA202SomaH(nUtCPart, 0)
						nUtSPart	:= JA202SomaH(nUtSPart, 0)
					EndIf
					
					aAdd	(self:aSelRes, 	{		If(nPos2 > 0, self:aDadosRes[nPos2][NPOSFILRT], "LBOK" ) /*1 Filtrar*/,;
													If(nPos2 > 0, self:aDadosRes[nPos2][NPOSRETRT], "LBNO" ) /*2 Retirar*/,;
													If(nPos2 > 0, self:aDadosRes[nPos2][NPOSWORT], "LBNO" )  /*3 WO*/,;
													self:aItems[ nI ][NPOSPART], /*4 cPart*/;
													Alltrim(Posicione("RD0", 9, xFilial("RD0") + Alltrim(self:aItems[ nI ][NPOSPART]), "RD0_NOME" )), /*5 nome*/;
													nUt , /* ut tot*/;
													nUtCPart, /*ut com part*/;
													nUtSPart, /*ut sem part*/;
													self:aItems[ nI ][NPOSTSVLH], /*Vl H*/;
													self:aItems[ nI ][NPOSTSVL1], /*Vl TS*/;
													1  /*count */,;
													.F. /* Indica ao MsNewGetDados se está deletado */ ;
												};
							)
				EndIf
			EndIf
		Next nI 
		aSort( self:aSelRes,,, { |aX,aY|  aX[NPOSPARRES] + str( aX[NPOSVLHRS] ) <  aY[NPOSPARRES] + str( aY[NPOSVLHRS] )  } )
	EndIf 
	
	If Empty(self:aSelRes)
		aAdd	(self:aSelRes, 	{		"LBNO" /*1 Filtrar*/,;
										"LBNO" /*2 Retirar*/,;
										"LBNO" /*3 WO*/,;
										"", /*4 cPart*/;
										"", /*5 nome*/;
										0, /* ut tot*/;
										0, /*ut com part*/;
										0, /*ut sem part*/;
										0, /*Vl H*/;
										0, /*Vl TS*/;
										0  /*count */,;
										.F. /* Indica ao MsNewGetDados se está deletado */ ;
									};
				)
	EndIF
	
Return nil


Method SetResDP() Class TJURREVLANCTO 
Local nI := 0
Local nPos	:= 0
Local nPos2	:= 0

	self:aSelRes	:={}

 	/* Estrutura do array Resumo de DP
	1 - Filtrar
	2 - Retirar
	3 - WO
	4 - Cod Tipo Desp
	5 - Descrição Tipo Desp
	6 - Moeda
	7 - Valor Total
	8 - Count

	
	*/

	If !Empty(self:aItems)
		For nI := 1 to Len(self:aItems)
		
			IF	(self:aItems[nI][NPOSCLI] 	== self:cClien) .AND.;
				(self:aItems[nI][NPOSLOJA]	== self:cLoja) .AND.;
				(self:aItems[nI][NPOSCASO] 	== self:cCaso)
		
		
				//Campos de Agrupamento (DP: Tipo Desp e Moeda)
				nPos := aScan	( self:aSelRes,	{ |x| 	x[NPOSTPLRES] == self:aItems[ nI ] [ NPOSTPLAN  ] .AND.;
															x[NPOSUTMOER] == self:aItems[ nI ] [ NPOSUTMOE  ] ;
													};
								)
	
				nPos2 := aScan	( self:aDadosRes,	{ |x|	x[NPOSCLIRT]	== self:aItems[ nI ] [ NPOSCLI ] .AND.;
															x[NPOSLOJRT]	== self:aItems[ nI ] [ NPOSLOJA ] .AND.;
															x[NPOSCASRT]	== self:aItems[ nI ] [ NPOSCASO ] .AND.;
															x[NPOSTPLRT]	== self:aItems[ nI ] [ NPOSTPLAN  ] .AND.;
															x[NPOSMOERT]	== self:aItems[ nI ] [ NPOSUTMOE ] ;
													};
								)
	
				If nPos > 0 
					self:aSelRes[nPos][NPOSVLDRES] := self:aSelRes[nPos][NPOSVLDRES] + self:aItems[ nI ][ NPOSUTVLR ]
					self:aSelRes[nPos][NPOSCONTDP] := self:aSelRes[nPos][NPOSCONTDP] + 1
				Else                                                                                             	
					aAdd	(self:aSelRes, 	{		self:aDadosRes[nPos2][NPOSFILRT] /*1 Filtrar*/,;
													self:aDadosRes[nPos2][NPOSRETRT]/*2 Retirar*/,;
													self:aDadosRes[nPos2][NPOSWORT] /*3 WO*/,;
													self:aItems[ nI ][NPOSTPLAN], ;
													Alltrim(Posicione("NRH", 1, xFilial("NRH") + self:aItems[ nI ][NPOSTPLAN], "NRH_DESC" )),;
													self:aItems[ nI ][NPOSUTMOE] , ;
													self:aItems[ nI ][NPOSUTVLR], ;
													1  ,;
													.F. /* Indica ao MsNewGetDados se está deletado */ ;
												};
							)
				EndIf
			EndIf
		Next nI
		aSort( self:aSelRes,,, { |aX,aY|  aX[NPOSTPLRES] + aX[NPOSUTMOER] <  aY[NPOSTPLRES] + aY[NPOSUTMOER]   } )
	EndIf 
	
	
	If Empty(self:aSelRes)
		aAdd	(self:aSelRes, 	{	"LBNO" /*1 Filtrar*/,;
										"LBNO" /*2 Retirar*/,;
										"LBNO" /*3 WO*/,;
										"", /*4 TpLan*/;
										"", /*5 Descrição*/;
										"", /* Moeda*/;
										0, /*Valor*/;
										0  /*count */,;
										.F. /* Indica ao MsNewGetDados se está deletado */ ;
									};
				)
	EndIF	
	
Return nil
 
Method setListaCasos(aListaCas) Class TJURREVLANCTO 
	self:aListCas	:= aListaCas
Return nil

Method SetResTB() Class TJURREVLANCTO 
Local nI := 0
Local nPos	:= 0
Local nPos2	:= 0
Local nPos3	:= 0

	self:aSelRes	:={}

 	/* Estrutura do array Resumo de TB
	1 - Filtrar
	2 - Retirar
	3 - WO
	4 - Cod Tipo Desp
	5 - Descrição Tipo Desp
	6 - Moeda
	7 - Valor Total
	8 - Count

	
	*/

	If !Empty(self:aItems)
		For nI := 1 to Len(self:aItems)
		
			IF	(self:aItems[nI][NPOSCLI] 	== self:cClien) .AND.;
				(self:aItems[nI][NPOSLOJA]	== self:cLoja) .AND.;
				(self:aItems[nI][NPOSCASO] 	== self:cCaso)
		
			//Campos de Agrupamento (TB: Tipo Desp e Moeda)
				nPos := aScan	( self:aSelRes,	{ |x| 	x[NPOSTPLRES] == self:aItems[ nI ] [ NPOSTPLAN  ] .AND.;
															x[NPOSUTMOER] == self:aItems[ nI ] [ NPOSUTMOE  ] ;
													};
								)

				nPos2 := aScan	( self:aDadosRes,	{ |x|	x[NPOSCLIRT]	== self:aItems[ nI ] [ NPOSCLI ] .AND.;
															x[NPOSLOJRT]	== self:aItems[ nI ] [ NPOSLOJA ] .AND.;
															x[NPOSCASRT]	== self:aItems[ nI ] [ NPOSCASO ] .AND.;
															x[NPOSTPLRT]	== self:aItems[ nI ] [ NPOSTPLAN  ] .AND.;
															x[NPOSMOERT]	== self:aItems[ nI ] [ NPOSUTMOE ] ;
													};
								)

				If nPos > 0 
					self:aSelRes[nPos][NPOSVLDRES] := self:aSelRes[nPos][NPOSVLDRES] + self:aItems[ nI ][ NPOSUTVLR ]
					self:aSelRes[nPos][NPOSCONTDP] := self:aSelRes[nPos][NPOSCONTDP] + 1
				Else                                                                                             	
					aAdd	(self:aSelRes, 	{		self:aDadosRes[nPos2][NPOSFILRT] /*1 Filtrar*/,;
													self:aDadosRes[nPos2][NPOSRETRT] /*2 Retirar*/,;
													self:aDadosRes[nPos2][NPOSWORT]  /*3 WO*/,;
													self:aItems[ nI ][NPOSTPLAN], ;
													Alltrim(Posicione("NRD", 1, xFilial("NRD") + self:aItems[ nI ][NPOSTPLAN], "NRD_DESCH" )),;
													self:aItems[ nI ][NPOSUTMOE] , ;
													self:aItems[ nI ][NPOSUTVLR], ;
													1  ,;
													.F. /* Indica ao MsNewGetDados se está deletado */ ;
												};
							)
				EndIf
			EndIF
		Next nI
		aSort( self:aSelRes,,, { |aX,aY|  aX[NPOSTPLRES] + aX[NPOSUTMOER] <  aY[NPOSTPLRES] + aY[NPOSUTMOER]   } )
	EndIf 
	
	If Empty(self:aSelRes)
		aAdd	(self:aSelRes, 	{	"LBNO" /*1 Filtrar*/,;
										"LBNO" /*2 Retirar*/,;
										"LBNO" /*3 WO*/,;
										"", /*4 TpLan*/;
										"", /*5 Descrição*/;
										"", /* Moeda*/;
										0, /*Valor*/;
										0  /*count */,;
										.F. /* Indica ao MsNewGetDados se está deletado */ ;
									};
				)
	EndIF
	
Return nil

Method RefreshResumo( ) Class TJURREVLANCTO  
Local nPos2	:= aScan( self:aListCas, {|x| x[NPOSCASCLI] == self:cClien .AND.  x[NPOSCASLOJ] == self:cLoja .AND. x[NPOSCASCOD] == self:cCaso } )

	Do Case
		Case self:cTipo == "TS"
			self:SetResTS()
		Case  self:cTipo == "DP"
			self:SetResDP()
		Case  self:cTipo == "TB"
			self:SetResTB()
	EndCase
 	
	Self:lCkWO		:= IF( nPos2 > 0, self:aListCas[nPos2][NPOSCASWO] , .F. )
	Self:lCkRet		:= IF( nPos2 > 0, self:aListCas[nPos2][NPOSCASRET], .F. )
	Self:lCkTran	:= IF( nPos2 > 0, self:aListCas[nPos2][NPOSCASTRA], .F. )
	Self:lCkCob		:= IF( nPos2 > 0, self:aListCas[nPos2][NPOSCASCOB], .F. )
	Self:lCkRev		:= IF( nPos2 > 0, self:aListCas[nPos2][NPOSCASREV], .F. ) 	

	self:oCkWO:lcheckjur	:= Self:lCkWO
	self:oCkRet:lcheckjur	:= Self:lCkRet
	self:oCkTran:lcheckjur	:= Self:lCkTran 
	self:oCkCob:lcheckjur	:= Self:lCkCob 
	self:oCkRev:lcheckjur	:= Self:lCkRev

	self:oCkWO:Refresh()
	self:oCkRet:Refresh()
	self:oCkTran:Refresh()
	self:oCkCob:Refresh()
	self:oCkRev:Refresh()
     
    // Seta vetor para a browse                            
//    self:oGridResumo:SetArray(self:aSelRes) 
	self:oGridResumo:aCols := self:aSelRes
    
    
    self:oGridResumo:lInsert := .F.
    self:oGridResumo:lDelete := .F.
   
//	self:oGridResumo:bLinhaOk := {||.T.}
	If self:aSelRes[1][len(self:aSelRes[1])-1] == 0 //qtd de lançamentos
		self:oGridResumo:oBrowse:lReadOnly := .T. 
		self:oGridResumo:Disable()
	Else
		self:oGridResumo:oBrowse:lReadOnly := .F. 
		self:oGridResumo:Enable()
	EndIF  
    
    // Monta a linha a ser exibina no Browse
//    self:oGridResumo:bLine := {||  self:MontaGrid(self:oGridResumo, self:aSelRes )  }
    self:oGridResumo:oBrowse:Refresh()
Return Nil

Method MontaGrid(oBrowse, aBrowse) Class TJURREVLANCTO   
Local aLine := {}
Local nI := 0
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )

	If !Empty(aBrowse)
		for nI := 1 to len(aBrowse[1])
			Do Case
				Case valtype(aBrowse[oBrowse:nAt,nI]) == "N"
					aadd( aLine, transform( aBrowse[oBrowse:nAt,nI], "@E 99,999,999,999.99" ) )
				Case valtype(aBrowse[oBrowse:nAt,nI]) == "L"
					aadd( aLine, If(aBrowse[oBrowse:nAt,nI],oOk,oNo ) )	
				OtherWise
					aadd( aLine, aBrowse[oBrowse:nAt,nI]  ) 
			EndCase
		Next nI
	EndIf

Return aLine

Method AddNavBar(oParent) Class TJURREVLANCTO

	//Verifica se o objeto ja foi criado                             
	if valtype( self:oPNav ) == "O"
		self:oPNav:Free()
	endif
	                                              
	//Painel esquerdo de Navegacao dos LANCAMENTOS
	self:oPNav		:= tPanel():New( 00, 00, "", oParent, , , , , ,15, 00, .T., .T. )
	self:oPNav:Align := CONTROL_ALIGN_RIGHT
				
		self:oButTop := TBtnBmp2():New( 015, 05, 22, 25, "VCTOP",		, , , { | | self:Primeiro() }, self:oPNav, STR0010, , .T. )
		self:oButPUp := TBtnBmp2():New( 055, 05, 22, 25, "VCPGUP",		, , , { | | self:Anterior() }, self:oPNav, STR0011, , .T. )
		self:oButPDn := TBtnBmp2():New( 095, 05, 22, 25, "VCPGDOWN",		, , , { | | self:Proximo()  }, self:oPNav, STR0012,  , .T. )
		self:oButBot := TBtnBmp2():New( 135, 05, 22, 25, "VCBOTTOM", 	, , , { | | self:Ultimo()   }, self:oPNav, STR0013,   , .T. )

Return nil

Method Primeiro(lLoad) Class TJURREVLANCTO
Default lLoad := .F.
                      
	If !Empty (self:aSelItems)
		
		self:OrderLanc(self:nOrdemLanc)
	
		//If self:nPrimeiro > 1 .OR. lLoad
		self:nPrimeiro := 1
		If len( self:aSelItems ) > self:nRows
			self:nUltimo := self:nRows
		Else
			self:nUltimo := len( self:aSelItems )
		EndIf

		//EndIf
		self:ClearLines()
   	self:LoadLines()
   	self:Refresh()
		//self:RefreshResumo()
	Else
		self:ClearLines()
	EndIf
	
Return nil

Method Ultimo(lLoad) Class TJURREVLANCTO
	
    If !Empty(self:aSelItems)
		//If self:nUltimo < len( self:aSelItems ) .OR. lLoad
		self:nUltimo := len( self:aSelItems )

		If len( self:aSelItems ) > self:nRows
			self:nPrimeiro := self:nUltimo - self:nRows + 1
		Else
			self:nPrimeiro := 1
		EndIf
		//EndIf
		self:ClearLines()
   	self:LoadLines()
   	self:Refresh()
//	   	self:RefreshResumo()
	Else
		self:ClearLines()
	EndIf
Return nil

Method Proximo() Class TJURREVLANCTO

	If !Empty(self:aSelItems)
		If self:nUltimo < len(self:aSelItems)
			self:nPrimeiro	:= self:nPrimeiro + 1
			self:nUltimo	:= self:nUltimo + 1
		EndIf
		self:ClearLines()
   	self:LoadLines()
   	self:Refresh()
//	   	self:RefreshResumo()
	Else
		self:ClearLines()
	EndIf

Return nil

Method Anterior() Class TJURREVLANCTO

	If !Empty(self:aSelItems)
		If self:nPrimeiro > 1
			self:nPrimeiro	:= self:nPrimeiro - 1
			self:nUltimo	:= self:nUltimo - 1
		Else
			self:nPrimeiro := 1
		EndIf
		self:ClearLines()
   	self:LoadLines()
   	self:Refresh()
//	   	self:RefreshResumo()
	Else
		self:ClearLines()
	EndIf
Return nil

Method ResetObjts() Class TJURREVLANCTO
Local lRet := .T.
Local nI	 := 0
Local nJ 	 := 0

	For nI := 1 to len( self:aComps )
		For nJ := 1 to len( self:aComps[nI] )
				If ValType(self:aComps[ni][nJ]) == "O"
					If self:aComps[ni][nJ]:ClassName() == "TJURPNLCAMPO"
						self:aComps[ni][nJ]:Destroy()
						self:aComps[ni][nJ] := Nil
					Else
						FreeObj( self:aComps[ni][nJ] )
					EndIf
				EndIf
		Next nJ
	Next nI

	self:aComps := {}

Return lRet

Method ClearLines() Class TJURREVLANCTO
Local nI := 0

	If Self:ResetObjts()

		For nI := 2 to len(self:aLines)
			self:oMainPanel:GetPanel( self:aLines[ni][1] ):FreeChildren()
			self:oMainPanel:GetPanel( self:aLines[ni][2] ):FreeChildren()
			self:oMainPanel:GetPanel( self:aLines[ni][3] ):FreeChildren()
		Next nI

//		If self:lResumo 
//			self:oMainPanel:GetPanel( self:aResumo[1] ):FreeChildren()
//			self:oMainPanel:GetPanel( self:aResumo[2] ):FreeChildren()
//		EndIf

	EndIf

Return nil

Method ClearArea() Class TJURREVLANCTO
Local nI	:= 0
	for ni:= 1 to len(self:aAreas)
		self:oMainPanel:GetPanel( self:aAreas[ni][3] ):FreeChildren()
	Next ni
Return nil

Method LoadLines() Class TJURREVLANCTO
Local nLine  := 0
Local lCampo := .T.

	If !Empty(self:aSelItems)
		If len(self:aSelItems) < self:nUltimo
			self:nUltimo := len(self:aSelItems)
		EndIf

		Do Case
			Case self:cTipo == "TS"
				lCampo:= JVldCampo("NUE_COBRAR")
			Case self:cTipo == "DP"
				lCampo:= JVldCampo("NVY_COBRAR")
			Case self:cTipo == "TB"
				lCampo:= JVldCampo("NV4_COBRAR")
		EndCase
		
		Self:ResetObjts() // Serve para resetar os objetos em tela
		For nLine := 0 to (self:nUltimo  - self:nPrimeiro )
			                // + 2 para pular a linha do título
			self:DrawLines( nLine + 2, self:aSelItems[self:nPrimeiro + nLine][NPOSCODLAN], nLine <= 3, lCampo )
		Next
		
	EndIf

Return nil

Method DrawLines( nLnPanel, cCod, lDraw, lCampo ) Class TJURREVLANCTO
Local npos	:= 0
Local LWOT01                                                  
Local lDET01
Local lCOT01
Local lRVT01
Local lRET01
Local lTRT01
Local lCheck := .F.
Local nLine	:= 0
Local oModelNX0 := self:oModel:GetModel("NX0MASTER")
Local aCposLGPD     := {}
Local aNoAccLGPD    := {}
Local aDisabLGPD    := {}

Default lDraw := .T.

	nPos := aScan( self:aSelItems , { |ax| ax[NPOSCODLAN] == cCod }  )

	If nPos > 0 
	
    aadd( self:aComps, { "", ;
                         "", ;
                         "", ;
                         "", ;
                         "", ;
                         "", ;
                         "", ;
                         "", ;
                         "", ;
                         "", ;
                         "", ;
                         "", ;
                         "", ;
                         "", ;
                         "", ;
                         "", ;
                         "", ;
                         "", ;
                         "", ;
                         lDraw, ;
                         "" ;
                       } ;
				)

		nLine := len(self:aComps)

		self:aComps[nLine][LN_CONTRATO] := Self:aSelItems[nPos][LN_CONTRATO]
		self:aComps[nLine][LN_CASO]     := Self:aSelItems[nPos][LN_CASO]
		self:aComps[nLine][LN_LANC]     := Self:aSelItems[nPos][LN_LANC]

		self:aComps[nLine][NPOSCODLAN]  := cCod // Cod Lancamento

		self:aComps[nLine][NPOSCLI]  := Self:aSelItems[nPos][NPOSCLI]
		self:aComps[nLine][NPOSLOJA] := Self:aSelItems[nPos][NPOSLOJA]
		self:aComps[nLine][NPOSCASO] := Self:aSelItems[nPos][NPOSCASO]

		If _lFwPDCanUse .And. FwPDCanUse(.T.)
			aCposLGPD := {"NUE_DESC","NVY_DESCRI","NV4_DESCRI"}

			aDisabLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
			AEval(aDisabLGPD, {|x| AAdd( aNoAccLGPD, x:CFIELD)})

		EndIf		

		If lDraw .And. self:cTipo == "TS"

			// CODIGO DO TIMESHEET - 1

			// DATA DO TIMESHEET - 2
			self:aComps[nLine][NPOSDTLAN] := TJurPnlCampo():New(00,04,044,020,self:oMainPanel:GetPanel(self:aLines[nLnPanel][1]),"","NUE_DATATS")
			self:aComps[nLine][NPOSDTLAN]:SetChange( {|| self:SetValue(self:aComps[nLine], "NUE_DATATS", self:aComps[nLine][NPOSDTLAN]:Valor, self:aSelItems[nPos][NPOSDTLAN], NPOSDTLAN ), .T.} )
			self:aComps[nLine][NPOSDTLAN]:SetGotFocus( {|| Self:GoToLine(self:aComps[nLine])} )
			self:aComps[nLine][NPOSDTLAN]:SetValue(self:aSelItems[nPos][NPOSDTLAN])
			self:aComps[nLine][NPOSDTLAN]:SetHelp("Cód. TS: "+self:aComps[nLine][NPOSCODLAN])

			// PARTICIPANTE - 3
			self:aComps[nLine][NPOSPART] := TJurPnlCampo():New(00,55,034,020,self:oMainPanel:GetPanel(self:aLines[nLnPanel][1]),"","NUE_SIGLA2")
			self:aComps[nLine][NPOSPART]:SetChange( {|| self:SetValue(self:aComps[nLine], "NUE_SIGLA2", self:aComps[nLine][ NPOSPART ]:Valor, self:aSelItems[nPos][ NPOSPART ], NPOSPART ), .T.} )
			self:aComps[nLine][NPOSPART]:SetGotFocus( {|| Self:GoToLine(self:aComps[nLine])} )
			self:aComps[nLine][NPOSPART]:SetLostFocus( {|| Self:UpdateValores(nLine,"NPOSPART") } )
			self:aComps[nLine][NPOSPART]:SetValue(self:aSelItems[nPos][NPOSPART])
			self:aComps[nLine][NPOSPART]:SetHelp("Cód. TS: "+self:aComps[nLine][NPOSCODLAN])

			// ATIVIDADE - 4
			self:aComps[nLine][NPOSTPLAN] := TJurPnlCampo():New(00,94,034,020,self:oMainPanel:GetPanel(self:aLines[nLnPanel][1]),"","NUE_CATIVI")
			self:aComps[nLine][NPOSTPLAN]:SetChange( {|| self:SetValue(self:aComps[nLine], "NUE_CATIVI", self:aComps[nLine][NPOSTPLAN]:Valor, self:aSelItems[nPos][ NPOSTPLAN ], NPOSPART ), .T.} )
			self:aComps[nLine][NPOSTPLAN]:SetGotFocus( {|| Self:GoToLine(self:aComps[nLine])} )
			self:aComps[nLine][NPOSTPLAN]:SetValue(self:aSelItems[nPos][ NPOSTPLAN ])
			self:aComps[nLine][NPOSTPLAN]:SetHelp("Cód. TS: "+self:aComps[nLine][NPOSCODLAN])

			//NARRATIVA - 5   { | |  }
			self:aComps[nLine][NPOSDESCR] := TJurPnlCampo():Initialize(0,0,0,0,self:oMainPanel:GetPanel(self:aLines[nLnPanel][2]),"","NUE_DESC",,,,,,,,,,,aScan(aNoAccLGPD,"NUE_DESC") > 0)
			self:aComps[nLine][NPOSDESCR]:SetAlign(CONTROL_ALIGN_ALLCLIENT)
			self:aComps[nLine][NPOSDESCR]:SetChange( {|| self:SetValue(self:aComps[nLine], "NUE_DESC", self:aComps[nLine][NPOSDESCR]:Valor, self:aSelItems[nPos][NPOSDESCR], NPOSDESCR ), .T.} )
			self:aComps[nLine][NPOSDESCR]:SetGotFocus( {|| Self:GoToLine(self:aComps[nLine])} )
			self:aComps[nLine][NPOSDESCR]:SetLabelVisible(.F.)
			self:aComps[nLine][NPOSDESCR]:SetValue(self:aSelItems[nPos][NPOSDESCR])
			self:aComps[nLine][NPOSDESCR]:SetHelp("Cód. TS: "+self:aComps[nLine][NPOSCODLAN])
			self:aComps[nLine][NPOSDESCR]:Activate()

			// UT LANCADA - REAL - 6
			self:aComps[nLine][NPOSUTMOE] := TJurPnlCampo():New(00,04,32,020,self:oMainPanel:GetPanel(self:aLines[nLnPanel][3]),"",self:cCpoLanc)   //cCpoLanc : "NUE_UTL" / "NUE_TEMPOL" / "NUE_HORAL"
			//Ajusta a picture diferente do X3
			//self:aComps[nLine][NPOSUTMOE]:oCampo:Picture := "@E 999,999.99"
			self:aComps[nLine][NPOSUTMOE]:SetChange( {|| self:SetValue(self:aComps[nLine], self:cCpoLanc, self:aComps[nLine][NPOSUTMOE]:Valor, self:aSelItems[nPos][ NPOSUTMOE ], NPOSUTMOE ), .T.} )
			self:aComps[nLine][NPOSUTMOE]:SetGotFocus( {|| Self:GoToLine(self:aComps[nLine])} )
			self:aComps[nLine][NPOSUTMOE]:SetLostFocus( {|| Self:UpdateRevisado(nLine) } )
			self:aComps[nLine][NPOSUTMOE]:SetValue(self:aSelItems[nPos][NPOSUTMOE])
			self:aComps[nLine][NPOSUTMOE]:Enable(self:aSelItems[nPos][NPOSUTMOE])

			// UT REVISADA - 7
			self:aComps[nLine][NPOSUTVLR] := TJurPnlCampo():New(00,42,32,020,self:oMainPanel:GetPanel(self:aLines[nLnPanel][3]),"",self:cCpoRev)    //cCpoRev: "NUE_UTR" / "NUE_TEMPOR" / "NUE_HORAR"
			//Ajusta a picture diferente do X3
//			self:aComps[nLine][NPOSUTVLR]:oCampo:Picture := "@E 999,999.99"
			self:aComps[nLine][NPOSUTVLR]:SetChange( {|| self:SetValue(self:aComps[nLine], self:cCpoRev, self:aComps[nLine][NPOSUTVLR]:valor, self:aSelItems[nPos][ NPOSUTVLR ], NPOSUTVLR ), .T.} )
			self:aComps[nLine][NPOSUTVLR]:SetGotFocus( {|| Self:GoToLine(self:aComps[nLine])} )
			self:aComps[nLine][NPOSUTVLR]:SetLostFocus( {|| Self:UpdateValores(nLine,"NPOSUTVLR") } )
			self:aComps[nLine][NPOSUTVLR]:SetValue(self:aSelItems[nPos][NPOSUTVLR])
		
			//Controles - WO - 8 
			self:aComps[nLine][NPOSWO] := TJurCheckBox():New( 	01, 132, STR0014, { || self:aSelItems[nPos][ NPOSWO ] },									;
											self:oMainPanel:GetPanel( self:aLines[nLnPanel][3] ),;
											100, 10, ,{ || self:MarcaChecks(self:aComps[nLine], cCod, NPOSWO ) } , , , , , , .T., , , )
			self:aComps[nLine][NPOSWO]:lcheckjur := self:aSelItems[nPos][ NPOSWO ]
			self:aComps[nLine][NPOSWO]:bGotFocus := {|| Self:GoToLine(self:aComps[nLine])}

				//Controles - DE - 9
			self:aComps[nLine][NPOSDE] := TJurCheckBox():New( 	10, 132, STR0015, { || self:aSelItems[nPos][ NPOSDE ] },									;
											self:oMainPanel:GetPanel( self:aLines[nLnPanel][3] ),;
											100, 10, ,{ || self:MarcaChecks(self:aComps[nLine], cCod, NPOSDE  ) } , , , , , , .T., , , )
		  self:aComps[nLine][NPOSDE]:lcheckjur := self:aSelItems[nPos][ NPOSDE ]
		  self:aComps[nLine][NPOSDE]:bGotFocus := {|| Self:GoToLine(self:aComps[nLine])}
		   		
			//Controles - Revisado - 10
			self:aComps[nLine][NPOSREVIS] := TJurCheckBox():New( 	01, 152, STR0016, { || self:aSelItems[nPos][ NPOSREVIS ] } ,;
											self:oMainPanel:GetPanel( self:aLines[nLnPanel][3] ),;
											100, 10, ,{ || self:MarcaChecks(self:aComps[nLine], cCod, NPOSREVIS  ) } , , , , , , .T., , , )
			self:aComps[nLine][NPOSREVIS]:lcheckjur := self:aSelItems[nPos][ NPOSREVIS ]
			self:aComps[nLine][NPOSREVIS]:bGotFocus := {|| Self:GoToLine(self:aComps[nLine])}
		   		
			//Controles - Cobrar - 16
			self:aComps[nLine][NPOSCOBRA] := TJurCheckBox():New( 	28, 132, STR0019, { || self:aSelItems[nPos][ NPOSCOBRA ] },								;
											self:oMainPanel:GetPanel( self:aLines[nLnPanel][3] ),;                         
											100, 10, , { || self:MarcaChecks(self:aComps[nLine], cCod, NPOSCOBRA  ) } , , , , , , .T., , , )
			self:aComps[nLine][NPOSCOBRA]:lcheckjur := self:aSelItems[nPos][ NPOSCOBRA ]
			self:aComps[nLine][NPOSCOBRA]:bGotFocus := {|| Self:GoToLine(self:aComps[nLine])}
			self:aComps[nLine][NPOSCOBRA]:lVisible := lCampo
			
			//Controles - "Retirar"/"Acumular" - 11
			self:aComps[nLine][NPOSRETIR] := TJurCheckBox():New( 	10, 152, STR0017, { || self:aSelItems[nPos][ NPOSRETIR ] },								;
											self:oMainPanel:GetPanel( self:aLines[nLnPanel][3] ),;
											100, 10, ,{ || self:MarcaChecks(self:aComps[nLine], cCod, NPOSRETIR  ) } , , , , , , .T., , , )
			self:aComps[nLine][NPOSRETIR]:lcheckjur := self:aSelItems[nPos][ NPOSRETIR ]
			self:aComps[nLine][NPOSRETIR]:bGotFocus := {|| Self:GoToLine(self:aComps[nLine])}
		   
			//Controles - "Transferir" - 12
			self:aComps[nLine][NPOSTRANS] := TJurCheckBox():New( 	19, 132, STR0018, { || self:aSelItems[nPos][ NPOSTRANS ] },							;
											self:oMainPanel:GetPanel( self:aLines[nLnPanel][3] ),;
											100, 10, ,{ || self:MarcaChecks(self:aComps[nLine], cCod, NPOSTRANS  ) } , , , , , , .T., , , )
			self:aComps[nLine][NPOSTRANS]:lcheckjur := self:aSelItems[nPos][ NPOSTRANS ]
			self:aComps[nLine][NPOSTRANS]:bGotFocus := {|| Self:GoToLine(self:aComps[nLine])}
		   
		 	// TS VALOR1 - 21
			self:aComps[nLine][NPOSTSVL1] := TJurPnlCampo():New(00,80,52,020,self:oMainPanel:GetPanel(self:aLines[nLnPanel][3]),"","NUE_VALOR1")    //Valor do Time Sheet na moeda da pré-fatura
			//Ajusta a picture diferente do X3
			self:aComps[nLine][NPOSTSVL1]:oCampo:Picture := "@E 99,999,999.99"
			self:aComps[nLine][NPOSTSVL1]:SetChange( {|| self:SetValue(self:aComps[nLine], "NUE_VALOR1", self:aComps[nLine][NPOSTSVL1]:valor, self:aSelItems[nPos][ NPOSTSVL1 ], NPOSTSVL1 ), .T.} )
			self:aComps[nLine][NPOSTSVL1]:SetGotFocus( {|| Self:GoToLine(self:aComps[nLine])} )
			self:aComps[nLine][NPOSTSVL1]:SetLostFocus( {|| Self:UpdateValores(nLine,"NPOSTSVL1") } )
			self:aComps[nLine][NPOSTSVL1]:SetValue(self:aSelItems[nPos][NPOSTSVL1])
		   
		EndIf

		If lDraw .And. self:cTipo == "DP" 
			// CODIGO DA DESPESA - 1

			// DATA DA DESPESA - 2 
			self:aComps[nLine][NPOSDTLAN] := TJurPnlCampo():New(00,04,044,020,self:oMainPanel:GetPanel(self:aLines[nLnPanel][1]),"","NVY_DATA")
			self:aComps[nLine][NPOSDTLAN]:SetChange( {|| self:SetValue(self:aComps[nLine], "NVY_DATA", self:aComps[nLine][NPOSDTLAN]:valor , self:aSelItems[nPos][ NPOSDTLAN ], NPOSDTLAN ), .T.} )
			self:aComps[nLine][NPOSDTLAN]:SetGotFocus( {|| Self:GoToLine(self:aComps[nLine])} )
			self:aComps[nLine][NPOSDTLAN]:SetValue(self:aSelItems[nPos][NPOSDTLAN])
			self:aComps[nLine][NPOSDTLAN]:SetHelp("Cód. Despesa: "+self:aComps[nLine][NPOSCODLAN])

			// SOLICITANTE - 3
			self:aComps[nLine][NPOSPART] := TJurPnlCampo():New(00,55,034,020,self:oMainPanel:GetPanel(self:aLines[nLnPanel][1]),"","NVY_SIGLA")
			self:aComps[nLine][NPOSPART]:SetChange( {|| self:SetValue(self:aComps[nLine], "NVY_SIGLA", self:aComps[nLine][NPOSPART]:valor, self:aSelItems[nPos][ NPOSPART ], NPOSPART ), .T.} )
			self:aComps[nLine][NPOSPART]:SetGotFocus( {|| Self:GoToLine(self:aComps[nLine])} )
			self:aComps[nLine][NPOSPART]:SetValue(self:aSelItems[nPos][NPOSPART])
			self:aComps[nLine][NPOSPART]:SetHelp("Cód. Despesa: "+self:aComps[nLine][NPOSCODLAN])
			
			// TIPO DE DESPESA  - 4
			self:aComps[nLine][NPOSTPLAN] := TJurPnlCampo():New(00,94,034,020,self:oMainPanel:GetPanel(self:aLines[nLnPanel][1]),"","NVY_CTPDSP")
			self:aComps[nLine][NPOSTPLAN]:SetChange( {|| self:SetValue(self:aComps[nLine], "NVY_CTPDSP", self:aComps[nLine][NPOSTPLAN]:valor, self:aSelItems[nPos][ NPOSTPLAN ], NPOSTPLAN ), .T.} )
			self:aComps[nLine][NPOSTPLAN]:SetGotFocus( {|| Self:GoToLine(self:aComps[nLine])} )
			self:aComps[nLine][NPOSTPLAN]:SetValue(self:aSelItems[nPos][NPOSTPLAN])
			self:aComps[nLine][NPOSTPLAN]:SetHelp("Cód. Despesa: "+self:aComps[nLine][NPOSCODLAN])

			//DESCRIÇÃO - 5
			self:aComps[nLine][NPOSDESCR] := TJurPnlCampo():Initialize(0,0,0,0,self:oMainPanel:GetPanel(self:aLines[nLnPanel][2]),"","NVY_DESCRI",,,,,,,,,,,aScan(aNoAccLGPD,"NVY_DESCRI") > 0)
			self:aComps[nLine][NPOSDESCR]:SetAlign(CONTROL_ALIGN_ALLCLIENT)
			self:aComps[nLine][NPOSDESCR]:SetChange( {|| self:SetValue(self:aComps[nLine], "NVY_DESCRI", self:aComps[nLine][NPOSDESCR]:Valor, self:aSelItems[nPos][NPOSDESCR], NPOSDESCR ), .T.} )
			self:aComps[nLine][NPOSDESCR]:SetGotFocus( {|| Self:GoToLine(self:aComps[nLine])} )
			//self:aComps[nLine][NPOSDESCR]:SetLostFocus( {|| } )
			self:aComps[nLine][NPOSDESCR]:SetLabelVisible(.F.)
			self:aComps[nLine][NPOSDESCR]:SetValue(self:aSelItems[nPos][NPOSDESCR])
			self:aComps[nLine][NPOSDESCR]:SetHelp("Cód. Despesa: "+self:aComps[nLine][NPOSCODLAN])
			self:aComps[nLine][NPOSDESCR]:Activate()

			// MOEDA - 6
			self:aComps[nLine][NPOSUTMOE] := TJurPnlCampo():New(00,05,034,020,self:oMainPanel:GetPanel(self:aLines[nLnPanel][3]),"","NVY_DMOEDA")
			self:aComps[nLine][NPOSUTMOE]:Enable(.F.)
			self:aComps[nLine][NPOSUTMOE]:SetValue(self:aSelItems[nPos][NPOSUTMOE])

			// VALOR DA DESPESA - 7  
			self:aComps[nLine][NPOSUTVLR] := TJurPnlCampo():New(00,42,45,020,self:oMainPanel:GetPanel(self:aLines[nLnPanel][3]),"","NVY_VALOR")
			//Ajusta a picture diferente do X3
			self:aComps[nLine][NPOSUTVLR]:oCampo:Picture := "@E 99,999,999,999.99"
			self:aComps[nLine][NPOSUTVLR]:Enable(.F.)
			self:aComps[nLine][NPOSUTVLR]:SetValue(self:aSelItems[nPos][NPOSUTVLR])
			
			//Controles - WO - 8	
			self:aComps[nLine][NPOSWO] := TJurCheckBox():New( 	01, 100, STR0014, { || self:aSelItems[nPos][ NPOSWO ] },									;
											self:oMainPanel:GetPanel( self:aLines[nLnPanel][3] ),;
											100, 10, ,  { || self:MarcaChecks(self:aComps[nLine], cCod, NPOSWO  ) }, , , , , , .T., , , )
			self:aComps[nLine][NPOSWO]:lcheckjur := self:aSelItems[nPos][ NPOSWO ]
			self:aComps[nLine][NPOSWO]:bGotFocus := {|| Self:GoToLine(self:aComps[nLine])}
            
            // Não tem D.E. - 9  self:aSelItems[nPos][9]

			//Controles - Cobrar - 10
			self:aComps[nLine][NPOSCOBRA] := TJurCheckBox():New( 	10, 100, STR0019, { || self:aSelItems[nPos][ NPOSCOBRA ] },								;
											self:oMainPanel:GetPanel( self:aLines[nLnPanel][3] ),;                         
											100, 10, , { || self:MarcaChecks(self:aComps[nLine], cCod, NPOSCOBRA  ) } , , , , , , .T., , , )
			self:aComps[nLine][NPOSCOBRA]:lcheckjur := self:aSelItems[nPos][ NPOSCOBRA ]
			self:aComps[nLine][NPOSCOBRA]:bGotFocus := {|| Self:GoToLine(self:aComps[nLine])}
			self:aComps[nLine][NPOSCOBRA]:lVisible := lCampo
			
			//Controles - "Retirar" - 11
			self:aComps[nLine][NPOSRETIR] := TJurCheckBox():New( 	01, 133, STR0017, { || self:aSelItems[nPos][ NPOSRETIR ] },								;
											self:oMainPanel:GetPanel( self:aLines[nLnPanel][3] ),;
											100, 10, , { || self:MarcaChecks(self:aComps[nLine], cCod, NPOSRETIR  ) } , , , , , , .T., , , )
			self:aComps[nLine][NPOSRETIR]:lcheckjur :=  self:aSelItems[nPos][ NPOSRETIR ]
			self:aComps[nLine][NPOSRETIR]:bGotFocus := {|| Self:GoToLine(self:aComps[nLine])}

			//Controles - "Transferir"  - 12
			self:aComps[nLine][NPOSTRANS] := TJurCheckBox():New( 	10, 133, STR0018, { || self:aSelItems[nPos][ NPOSTRANS ] },							;
											self:oMainPanel:GetPanel( self:aLines[nLnPanel][3] ),;
											100, 10, , { || self:MarcaChecks(self:aComps[nLine], cCod, NPOSTRANS  ) } , , , , , , .T., , , )
			self:aComps[nLine][NPOSTRANS]:lcheckjur := self:aSelItems[nPos][ NPOSTRANS ]
			self:aComps[nLine][NPOSTRANS]:bGotFocus := {|| Self:GoToLine(self:aComps[nLine])}

		EndIf
		
		If lDraw .And. self:cTipo == "TB"

			// CODIGO DO SERVICO - 1

			// DATA DO SERVIÇO - 2
			self:aComps[nLine][NPOSDTLAN] := TJurPnlCampo():New(00,04,044,020,self:oMainPanel:GetPanel(self:aLines[nLnPanel][1]),"","NV4_DTLANC")
			self:aComps[nLine][NPOSDTLAN]:SetChange( {|| self:SetValue(self:aComps[nLine], "NV4_DTLANC", self:aComps[nLine][NPOSDTLAN]:valor , self:aSelItems[nPos][ NPOSDTLAN ], NPOSDTLAN ), .T.} )
			self:aComps[nLine][NPOSDTLAN]:SetGotFocus( {|| Self:GoToLine(self:aComps[nLine])} )
			self:aComps[nLine][NPOSDTLAN]:SetValue(self:aSelItems[nPos][NPOSDTLAN])
			self:aComps[nLine][NPOSDTLAN]:SetHelp("Cód. Tabelado: "+self:aComps[nLine][NPOSCODLAN])
			
			// PARTICIPANTE - 3
			self:aComps[nLine][NPOSPART] := TJurPnlCampo():New(00,55,034,020,self:oMainPanel:GetPanel(self:aLines[nLnPanel][1]),"","NV4_SIGLA")
			self:aComps[nLine][NPOSPART]:SetChange( {|| self:SetValue(self:aComps[nLine], "NV4_SIGLA", self:aComps[nLine][NPOSPART]:valor ,self:aSelItems[nPos][ NPOSPART ], NPOSPART), .T.} )
			self:aComps[nLine][NPOSPART]:SetGotFocus( {|| Self:GoToLine(self:aComps[nLine])} )
			self:aComps[nLine][NPOSPART]:SetValue(self:aSelItems[nPos][NPOSPART])
			self:aComps[nLine][NPOSPART]:SetHelp("Cód. Tabelado: "+self:aComps[nLine][NPOSCODLAN])
			
			// TIPO DE SERVIÇO  - 4
			self:aComps[nLine][NPOSTPLAN] := TJurPnlCampo():New(00,94,034,020,self:oMainPanel:GetPanel(self:aLines[nLnPanel][1]),"","NV4_CTPSRV")
			self:aComps[nLine][NPOSTPLAN]:SetChange( {|| self:SetValue(self:aComps[nLine], "NV4_CTPSRV", self:aComps[nLine][NPOSTPLAN]:valor , self:aSelItems[nPos][ NPOSTPLAN ], NPOSTPLAN), .T.} )
			self:aComps[nLine][NPOSTPLAN]:SetGotFocus( {|| Self:GoToLine(self:aComps[nLine])} )
			self:aComps[nLine][NPOSTPLAN]:SetValue(self:aSelItems[nPos][NPOSTPLAN])
			self:aComps[nLine][NPOSTPLAN]:SetHelp("Cód. Tabelado: "+self:aComps[nLine][NPOSCODLAN])
			
			//DESCRIÇÃO - 5
			self:aComps[nLine][NPOSDESCR] := TJurPnlCampo():Initialize(0,0,0,0,self:oMainPanel:GetPanel(self:aLines[nLnPanel][2]),"","NV4_DESCRI",,,,,,,,,,,aScan(aNoAccLGPD,"NV4_DESCRI") > 0)
			self:aComps[nLine][NPOSDESCR]:SetAlign(CONTROL_ALIGN_ALLCLIENT)
			self:aComps[nLine][NPOSDESCR]:SetChange( {|| self:SetValue(self:aComps[nLine], "NV4_DESCRI", self:aComps[nLine][NPOSDESCR]:Valor, self:aSelItems[nPos][NPOSDESCR], NPOSDESCR ), .T.} )
			self:aComps[nLine][NPOSDESCR]:SetGotFocus( {|| Self:GoToLine(self:aComps[nLine])} )
			//self:aComps[nLine][NPOSDESCR]:SetLostFocus( {|| } )
			self:aComps[nLine][NPOSDESCR]:SetLabelVisible(.F.)
			self:aComps[nLine][NPOSDESCR]:SetValue(self:aSelItems[nPos][NPOSDESCR])
			self:aComps[nLine][NPOSDESCR]:SetHelp("Cód. Tabelado: "+self:aComps[nLine][NPOSCODLAN])
			self:aComps[nLine][NPOSDESCR]:Activate()

			// MOEDA - 6
			self:aComps[nLine][NPOSUTMOE] := TJurPnlCampo():New(00,05,034,020,self:oMainPanel:GetPanel(self:aLines[nLnPanel][3]),"","NV4_DMOEH")
			self:aComps[nLine][NPOSUTMOE]:Enable(.F.)
			self:aComps[nLine][NPOSUTMOE]:SetValue(self:aSelItems[nPos][NPOSUTMOE])
			
			// VALOR DO SERVIÇO - 7
			self:aComps[nLine][NPOSUTVLR] := TJurPnlCampo():New(00,42,45,020,self:oMainPanel:GetPanel(self:aLines[nLnPanel][3]),"","NV4_VLHFAT")
			//Ajusta a picture diferente do X3
			self:aComps[nLine][NPOSUTVLR]:oCampo:Picture := "@E 99,999,999.99"
			self:aComps[nLine][NPOSUTVLR]:SetChange( {|| self:SetValue(self:aComps[nLine], "NV4_VLHFAT", self:aComps[nLine][NPOSUTVLR]:valor, self:aSelItems[nPos][ NPOSUTVLR ], NPOSUTVLR ), .T.} )
			self:aComps[nLine][NPOSUTVLR]:SetGotFocus( {|| Self:GoToLine(self:aComps[nLine])} )
			self:aComps[nLine][NPOSUTVLR]:SetValue(self:aSelItems[nPos][NPOSUTVLR])
			self:aComps[nLine][NPOSUTVLR]:SetHelp("Cód. Tabelado: "+self:aComps[nLine][NPOSCODLAN])
			//self:aComps[nLine][NPOSUTVLR]:Activate()
			//self:aComps[nLine][NPOSUTVLR]:Enable(.T.)

			//Controles - WO - 8	
			self:aComps[nLine][NPOSWO] := TJurCheckBox():New( 	01, 100, STR0014, { || self:aSelItems[nPos][ NPOSWO ] },									;
											self:oMainPanel:GetPanel( self:aLines[nLnPanel][3] ),;
											100, 10, ,  { || self:MarcaChecks(self:aComps[nLine], cCod, NPOSWO  ) }, , , , , , .T., , , )
			self:aComps[nLine][NPOSWO]:lcheckjur := self:aSelItems[nPos][ NPOSWO ]
			self:aComps[nLine][NPOSWO]:bGotFocus := {|| Self:GoToLine(self:aComps[nLine])}
            // Não tem D.E. - 9  self:aSelItems[nPos][9]

			//Controles - Cobrar - 10
			self:aComps[nLine][NPOSCOBRA] := TJurCheckBox():New( 	10, 100, STR0019, { || self:aSelItems[nPos][ NPOSCOBRA ] },								;
											self:oMainPanel:GetPanel( self:aLines[nLnPanel][3] ),;                         
											100, 10, , { || self:MarcaChecks(self:aComps[nLine], cCod, NPOSCOBRA  ) } , , , , , , .T., , , )
			self:aComps[nLine][NPOSCOBRA]:lcheckjur := self:aSelItems[nPos][ NPOSCOBRA ]
			self:aComps[nLine][NPOSCOBRA]:bGotFocus := {|| Self:GoToLine(self:aComps[nLine])}
			self:aComps[nLine][NPOSCOBRA]:lVisible := lCampo

			//Controles - "Retirar" - 11
			self:aComps[nLine][NPOSRETIR] := TJurCheckBox():New( 	01, 133, STR0017, { || self:aSelItems[nPos][ NPOSRETIR ] },								;
											self:oMainPanel:GetPanel( self:aLines[nLnPanel][3] ),;
											100, 10, , { || self:MarcaChecks(self:aComps[nLine], cCod, NPOSRETIR  ) } , , , , , , .T., , , )
			self:aComps[nLine][NPOSRETIR]:lcheckjur := self:aSelItems[nPos][ NPOSRETIR ]
			self:aComps[nLine][NPOSRETIR]:bGotFocus := {|| Self:GoToLine(self:aComps[nLine])}

			//Controles - "Transferir"  - 12
			self:aComps[nLine][NPOSTRANS] := TJurCheckBox():New( 	10, 133, STR0018, { || self:aSelItems[nPos][ NPOSTRANS ] },							;
											self:oMainPanel:GetPanel( self:aLines[nLnPanel][3] ),;
											100, 10, , { || self:MarcaChecks(self:aComps[nLine], cCod, NPOSTRANS  ) } , , , , , , .T., , , )
			self:aComps[nLine][NPOSTRANS]:lcheckjur := self:aSelItems[nPos][ NPOSTRANS ]
			self:aComps[nLine][NPOSTRANS]:bGotFocus := {|| Self:GoToLine(self:aComps[nLine])}

		EndIf
		
	EndIf
	
Return nil

Method SetValue(oCampo, cCampo, cValorNew, cValorOld, nColLanc) Class TJURREVLANCTO
Local lRet       := .T.
Local oModelLanc := nil
local cIdModel    := ""
Local aSaveLines
Local oModelNX8
Local oModelNX1
Local lForce := .F.
Local oStrucXXX
local bWhen  := {|| }
Local bNoUpd     := {|| }

	oModelNX8  := Self:oModel:GetModel("NX8DETAIL")
	oModelNX1  := Self:oModel:GetModel("NX1DETAIL")

	Do Case
		Case self:cTipo == "TS"
			cIdModel := "NUEDETAIL"
		Case self:cTipo == "DP"
			cIdModel := "NVYDETAIL"
		Case self:cTipo == "TB"
			cIdModel := "NV4DETAIL"
		OtherWise
			lRet := .F.
	EndCase

	If lRet
		oModelLanc := self:oModel:GetModel(cIdModel)
		If oModelNX8:GoLine(oCampo[LN_CONTRATO]) == oCampo[LN_CONTRATO] .And. ;
		   oModelNX1:GoLine(oCampo[LN_CASO])     == oCampo[LN_CASO]     .And. ;
		   oModelLanc:GoLine(oCampo[LN_LANC])    == oCampo[LN_LANC]

			If !(cValorNew == oModelLanc:GetValue(cCampo))

				If oModelLanc:ClassName() == 'FWFORMGRID'
					oStrucXXX := oModelLanc:GetStruct()
					lForce := oStrucXXX:HasField(cCampo) .AND. (oStrucXXX:GetProperty(cCampo, MODEL_FIELD_NOUPD) .Or. (oStrucXXX:GetProperty(cCampo, MODEL_FIELD_WHEN) <> Nil) )
				EndIf

				If lForce
					bWhen := oStrucXXX:GetProperty(cCampo, MODEL_FIELD_WHEN)
					bNoUpd := oStrucXXX:GetProperty(cCampo, MODEL_FIELD_NOUPD)
					oStrucXXX:SetProperty( cCampo, MODEL_FIELD_NOUPD, .F. )
					oStrucXXX:SetProperty( cCampo, MODEL_FIELD_WHEN, {|| .T.} )
				EndIf

				If lRet := JurSetValue(oModelLanc, cCampo, , cValorNew, .T.)
				
					nPos 		:= aScan ( self:aItems, 	{|x| x[NPOSCODLAN] == oCampo[7]  } )
					nPosLanc 	:= aScan ( self:aSelItems, 	{|x| x[NPOSCODLAN] == oCampo[7]  } )

					If nPos > 0
						self:aItems[nPos][nColLanc]			:= cValorNew
					EndIf						
					If nPosLanc > 0
						self:aSelItems[nPosLanc][nColLanc]	:= cValorNew
					EndIF
			
					Self:ParentView:Refresh(cIdModel)
				Else
					JurMsgErro()
				EndIf
				
				If lForce
					oStrucXXX:SetProperty( cCampo, MODEL_FIELD_NOUPD, bNoUpd )
					oStrucXXX:SetProperty( cCampo, MODEL_FIELD_WHEN, bWhen )
				EndIF

			EndIf
		EndIf
	EndIf

Return lRet

Method MarcaChecks(oCampo, cCodLanc , nColLanc, lForce) Class TJURREVLANCTO
Local lRet     := .T.

Default oCampo := IIF(!Empty(self:aComps), self:aComps[1], Nil)
Default lForce := Nil

	If self:lTemLanc

			MsgRun(STR0025, ,{|| lRet := self:SetCheck(cCodLanc , nColLanc, lForce) }) // "Aguarde..."
	
		If lRet

			Do Case
				Case self:cTipo == "TS"
					Self:ParentView:Refresh("NUEDETAIL")
				Case self:cTipo == "DP"
					Self:ParentView:Refresh("NVYDETAIL")
				Case self:cTipo == "TB"
					Self:ParentView:Refresh("NV4DETAIL")
			EndCase
			self:Refresh()
			self:RefreshResumo()

		EndIf

		IF !Empty(self:aComps) .And. !Empty(oCampo[NPOSDESCR])
			oCampo[NPOSDESCR]:SetFocus()
		EndIF
	EndIf
	
Return lRet

Method SetCheck(cCodLanc , nColLanc, lForce) Class TJURREVLANCTO
Local lRet 			 := .T.
Local lAchou		 := .F.
Local nPos	     := 0
Local nPosLanc   := 0
Local nLinCampo  := 0
Local nPosRes    := 0
Local oCheck     := Nil
//Local aSaveLines := FWSaveRows(self:oModel)
Local oModelNX8  := self:oModel:GetModel("NX8DETAIL")
Local oModelNX1  := self:oModel:GetModel("NX1DETAIL")
Local oModelLanc := Self:GetMdlLancto()
Local nLine      := 0
Local nLinNX1    := 0
Local nLinNX8    := 0
Local nLinResumo := 0
Local nPosCpoRes := 0  
Local ni         := 0
Local lCheck     := .F.
Local nPos2      := aScan( self:aListCas, {|x| x[NPOSCASCLI] == self:cClien .AND.  x[NPOSCASLOJ] == self:cLoja .AND. x[NPOSCASCOD] == self:cCaso } )

Default lForce   := Nil

	//Alert("Teste")
	If nColLanc == NPOSWO
//		self:oCkWO:Refresh()
		lCheck 	:= self:oCkWO:lcheckjur
		nPosCpoRes	:= NPOSWORES
		self:aListCas[nPos2][NPOSCASWO]	:= lCheck
	EndIf
	If nColLanc == NPOSRETIR
//		self:oCkRet:Refresh()
		lCheck 	:= self:oCkRet:lcheckjur
		nPosCpoRes	:= NPOSRETRES
		self:aListCas[nPos2][NPOSCASRET]	:= lCheck
	EndIf
	If nColLanc == NPOSTRANS
//		self:oCkTran:Refresh()
		lCheck 	:= self:oCkTran:lcheckjur
		nPosCpoRes	:= 0
		self:aListCas[nPos2][NPOSCASTRA]	:= lCheck
	EndIf
	If nColLanc == NPOSCOBRA
//		self:oCkCob:Refresh()
		lCheck 	:= self:oCkCob:lcheckjur
		nPosCpoRes	:= 0
		self:aListCas[nPos2][NPOSCASCOB]	:= lCheck
	EndIf
	If nColLanc == NPOSREVIS
//		self:oCkRev:Refresh()
		lCheck 	:= self:oCkRev:lcheckjur
		nPosCpoRes	:= 0
		self:aListCas[nPos2][NPOSCASREV]	:= lCheck
	EndIf

	If cCodLanc == "0"

		If nPosCpoRes > 0 
			//Ajusta os resumos - WO e Retirar (isso ajustará automaticamente os lançamentos)
			nLinResumo := self:oGridResumo:oBrowse:nAt
			For ni := 1 to len(self:aSelRes)
				self:oGridResumo:oBrowse:nAt := ni
					
				self:oGridResumo:oBrowse:nAt	:= ni
				self:oGridResumo:oBrowse:nColPos	:= nPosCpoRes

				self:EditCel (self:aSelRes, self:oGridResumo:oBrowse, IIf(lCheck, "S", "N"))
			
			Next ni
			
			self:oGridResumo:oBrowse:nAt := nLinResumo
			self:oGridResumo:aCols := self:aSelRes
			self:oGridResumo:oBrowse:bLDblClick   := {|| (self:EditCel(self:aSelRes, self:oGridResumo:oBrowse,"" ) , self:AjustaFoco() ) } 
		Else
			//Ajusta diretamento nos lançamentos - Transferir / Cobrar / Revisado
			For ni := 1 to len(self:aItems)
				If lRet                                     .And. ;
				   self:aItems[nI][NPOSCLI]  == self:cClien .AND. ;
				   self:aItems[nI][NPOSLOJA] == self:cloja  .AND. ;
				   self:aItems[nI][NPOSCASO] == self:cCaso

					self:GoToLine(self:aItems[ni])
					lRet := self:SetCheck( self:aItems[ni][NPOSCODLAN] , nColLanc, lCheck )

				EndIf

			Next ni

			If lRet
				lRet := JurLoadValue(oModelNX1, "NX1_TSREV", , IIF(lCheck, "1", "2") )
			EndIf

		EndIf
	Else

		nPos 		:= aScan ( self:aItems, 	{|x| x[NPOSCODLAN] == cCodLanc  } )
		nPosLanc 	:= aScan ( self:aSelItems, 	{|x| x[NPOSCODLAN] == cCodLanc  } )
		nLinCampo 	:= aScan ( self:aComps, 	{|x| x[NPOSCODLAN] == cCodLanc  } )

		If self:cTipo == "TS"
			nPosRes	:= aScan( self:aSelRes, { |x| x[NPOSPARRES] 	== self:aItems[ nPos ] [ NPOSPART  ] .AND.;
													x[NPOSVLHRS]	== self:aItems[ nPos ] [ NPOSTSVLH ] ;
												};
							)
		Else  // Tabelado e despesas são iguais.
			nPosRes := aScan( self:aSelRes, { |x| x[NPOSTPLRES] == self:aItems[ nPos ] [ NPOSTPLAN  ] .AND.;
													x[NPOSUTMOER] == self:aItems[ nPos ] [ NPOSUTMOE  ] ;
												};
							)
		EndIf

		If lRet

			If ValType(lForce) == "U"
				self:aItems[nPos][nColLanc]	:= !self:aItems[nPos][nColLanc]
			Else
				self:aItems[nPos][nColLanc] := lForce
			EndIf

			If nColLanc == NPOSCOBRA .OR.; // 16
				 nColLanc == NPOSREVIS // 17
	
				Do Case
					Case self:cTipo == "TS"
						cCpoCod		:= "NUE_COD"
						If nColLanc == NPOSCOBRA
							cCampo		:= "NUE_COBRAR"
						Else	
							cCampo		:= "NUE_REVISA"
						EndIf
					Case self:cTipo == "DP"
						cCpoCod		:= "NVY_COD"
						cCampo		:= "NVY_COBRAR"
					Case self:cTipo == "TB"
						cCpoCod		:= "NV4_COD"
						cCampo		:= "NV4_COBRAR"
					OtherWise
						lRet := .F.
				EndCase
			
				If oModelLanc:GetValue(cCpocod) == cCodLanc // Ao chegar aqui já deve estar no registro correto, isto é apenas uma garantia!
					If Empty(lForce)
						cValorNew := If(self:aItems[nPos][nColLanc], "1", "2")
					Else
						cValorNew := If(lForce, "1", "2")
					EndIf
					lRet      := JurSetValue(oModelLanc, cCampo,,cValorNew, .F.)
					lAchou    := .T.
				Else
					lRet := .F.
				EndIf
		
				self:aItems[nPos][nColLanc]	:= oModelLanc:GetValue(cCampo) == "1"
	
			Else

				Do Case
					Case self:cTipo == "TS"
						cCampo := "NUE_TKRET"
					Case self:cTipo == "DP"
						cCampo := "NVY_TKRET"
					Case self:cTipo == "TB"
						cCampo := "NV4_TKRET"
					OtherWise
						lRet := .F.
				EndCase
		
				If lRet
					JurLoadValue(oModelLanc,cCampo,,self:aItems[nPos][nColLanc]) // Isto serve para deixar o modelo em estado de alteração!
				EndIf

				If (nColLanc == NPOSWO .OR. nColLanc == NPOSRETIR ) .AND. nPosRes > 0 .AND. !self:aItems[nPos][nColLanc]
					self:aSelRes[nPosRes][nPosCpoRes] := 	.F.
				EndIf
				
				If (nColLanc == NPOSDE )
					self:aComps[nLinCampo][NPOSUTMOE]:Enable(self:aComps[nLinCampo][nColLanc]:lcheckjur)
				EndIf
	       
			EndIf
	        
			If nLinCampo > 0
				self:aComps[nLinCampo][nColLanc]:lcheckjur	:= self:aItems[nPos][nColLanc]
			EndIf
			If nPosLanc > 0
				self:aSelItems[nPosLanc][nColLanc] 	:= self:aItems[nPos][nColLanc]
			EndIf

		EndIf

	EndIf

Return lRet          

Method AjustaFoco() Class TJURREVLANCTO

	//If !Empty(self:aComps)
	
		 //self:aComps[1][NPOSDTLAN]:oCampo:SetFocus()
		 self:oPerIni:SetFocus()
		 self:oGridResumo:oBrowse:SetFocus() 
	
	//EndIf

Return nil

Method SetArrayLanc(aLanc) Class TJURREVLANCTO
Local nI 	:= 0
Local nPos  := 0

	If !Empty(self:aItems) .AND. Len(aLanc) == Len(self:aItems)

		For nI := 1 to Len(aLanc)

			nPos := aScan( self:aItems, { |x|, x[NPOSCODLAN] == aLanc[nI][NPOSCODLAN] } )
			If nPos > 0
                

				self:aItems[nPos][LN_CONTRATO  ]   := aLanc[nI][LN_CONTRATO  ]   //  4 - Cliente 
				self:aItems[nPos][LN_CASO      ]   := aLanc[nI][LN_CASO      ]   //  4 - Cliente 
				self:aItems[nPos][LN_LANC      ]   := aLanc[nI][LN_LANC      ]   //  4 - Cliente 

				self:aItems[nPos][NPOSCLI]   := aLanc[nI][NPOSCLI]   //  4 - Cliente 
				self:aItems[nPos][NPOSLOJA]  := aLanc[nI][NPOSLOJA]  //  5 - Loja
				self:aItems[nPos][NPOSCASO]  := aLanc[nI][NPOSCASO]  //  6 - Caso

				self:aItems[nPos][NPOSDTLAN] := aLanc[nI][NPOSDTLAN] //  8 - Data
				self:aItems[nPos][NPOSPART]  := aLanc[nI][NPOSPART]  //  9 - Participante do lançamento
				self:aItems[nPos][NPOSTPLAN] := aLanc[nI][NPOSTPLAN] //  10 - Tipo
				self:aItems[nPos][NPOSDESCR] := aLanc[nI][NPOSDESCR] //  11 - Descrição

				self:aItems[nPos][NPOSUTMOE] := aLanc[nI][NPOSUTMOE] // 12 - Moeda
				self:aItems[nPos][NPOSUTVLR] := aLanc[nI][NPOSUTVLR] // 13 - Valor
				self:aItems[nPos][NPOSCOBRA] := aLanc[nI][NPOSCOBRA] // 16 - Cobrar
				self:aItems[nPos][NPOSREVIS] := aLanc[nI][NPOSREVIS] // 17 - Revisado
				self:aItems[nPos][NPOSTRANS] := aLanc[nI][NPOSTRANS] // 19 - Transfere

				self:aItems[nPos][NPOSTSVLH] := aLanc[nI][NPOSTSVLH] // 20 - Valor Hora do timeSheet
				self:aItems[nPos][NPOSTSVL1] := aLanc[nI][NPOSTSVL1] // 21 - Valor Total do TimeSheet
				self:aItems[nPos][NPOSCPART2]:= aLanc[nI][NPOSCPART2] // 22 - Código do Participante Revisado  // By JPP - 08/11/2013 - 13H38 - Adequando este trecho ao novo campo criado.
			Else
				aAdd(self:aItems, aLanc[nI] )
			End
		Next nI
		
		self:aSelItems := self:aItems
		
	Else
		If !Empty(aLanc)
			self:aItems 	:= aLanc
			self:lTemLanc	:= .T.
		Else
			self:aItems    := {}
			self:aSelItems := {}
			self:lTemLanc  := .F.
		EndIf
	EndIf
	
	self:setArrayRes()
    
Return nil

Method setArrayRes() Class TJURREVLANCTO
Local nI := 0

	For nI := 1 to Len(self:aItems)
	
		Do Case
			Case self:cTipo == "TS"

				//Campos de Agrupamento (TS: participante e valor hora)
				nPos := aScan	( self:aDadosRes,	{ |x|	x[NPOSCLIRT]	== self:aItems[ nI ] [ NPOSCLI ] .AND.;
															x[NPOSLOJRT]	== self:aItems[ nI ] [ NPOSLOJA ] .AND.;
															x[NPOSCASRT]	== self:aItems[ nI ] [ NPOSCASO ] .AND.;
															x[NPOSPARRT]	== self:aItems[ nI ] [ NPOSPART  ] .AND.;
															x[NPOSVLHRT]	== self:aItems[ nI ] [ NPOSTSVLH ] ;
													};
								)
	
				If nPos == 0 
					IF self:nTipoApon == 3 // tratar a soma de hh:mm + hh:mm
						nUt			:= JA202SomaH(nUt, 0) 
						nUtCPart	:= JA202SomaH(nUtCPart, 0)
						nUtSPart	:= JA202SomaH(nUtSPart, 0)
					EndIf
					
					aAdd	(self:aDadosRes, 	{	"LBOK" /*1 Filtrar*/,;
													"LBNO"/*2 Retirar*/,;
													"LBNO"/*3 WO*/,;
													self:aItems[nI][NPOSCLI],;
													self:aItems[nI][NPOSLOJA],;
													self:aItems[nI][NPOSCASO],;
													self:aItems[ nI ][NPOSPART], /*4 cPart*/;
													self:aItems[ nI ][NPOSTSVLH], /*Vl H*/;
												};
							)
				EndIf
							
			Case self:cTipo == "DP"

				
				//Campos de Agrupamento (DP: Tipo Desp e Moeda)
				nPos := aScan	( self:aDadosRes,	{ |x| 	x[NPOSCLIRT]	== self:aItems[ nI ] [ NPOSCLI ] .AND.;
															x[NPOSLOJRT]	== self:aItems[ nI ] [ NPOSLOJA ] .AND.;
															x[NPOSCASRT]	== self:aItems[ nI ] [ NPOSCASO ] .AND.;
															x[NPOSTPLRES] == self:aItems[ nI ] [ NPOSTPLAN  ] .AND.;
															x[NPOSUTMOER] == self:aItems[ nI ] [ NPOSUTMOE  ] ;
													};
								)
	
				If nPos == 0 
					aAdd	(self:aDadosRes, 	{		"LBOK" /*1 Filtrar*/,;
													"LBNO" /*2 Retirar*/,;
													"LBNO" /*3 WO*/,;
													self:aItems[nI][NPOSCLI],;
													self:aItems[nI][NPOSLOJA],;
													self:aItems[nI][NPOSCASO],;
													self:aItems[ nI ][NPOSTPLAN], ;
													self:aItems[ nI ][NPOSUTMOE] , ;
												};
							)
				EndIf

			Case  self:cTipo == "TB"

				nPos := aScan	( self:aDadosRes,	{ |x| 	x[NPOSCLIRT]	== self:aItems[ nI ] [ NPOSCLI ] .AND.;
															x[NPOSLOJRT]	== self:aItems[ nI ] [ NPOSLOJA ] .AND.;
															x[NPOSCASRT]	== self:aItems[ nI ] [ NPOSCASO ] .AND.;	
															x[NPOSTPLRES] == self:aItems[ nI ] [ NPOSTPLAN  ] .AND.;
															x[NPOSUTMOER] == self:aItems[ nI ] [ NPOSUTMOE  ] ;
													};
								)

				If nPos == 0 
					aAdd	(self:aDadosRes, 	{	"LBOK" /*1 Filtrar*/,;
													"LBNO" /*2 Retirar*/,;
													"LBNO" /*3 WO*/,;
													self:aItems[nI][NPOSCLI],;
													self:aItems[nI][NPOSLOJA],;
													self:aItems[nI][NPOSCASO],;
													self:aItems[ nI ][NPOSTPLAN], ;
													self:aItems[ nI ][NPOSUTMOE] , ;
												};
							)
				EndIf


		EndCase

	Next nI 

Return nil

Method SelectLancs(cClien, cLoja, cCaso, cComp, xValorOld, xValorNew  ) Class TJURREVLANCTO
Local nI 		:= 0
Local nPosItem 	:= 0
Default xValorOld := "0"
Default xValorNew := "1"

	If cComp == "oPerIni"
		self:dPerIni := xValorNew
	EndIf
	If cComp == "oPerFim"
		self:dPerFim := xValorNew
	EndIf

	If !(xValorOld == xValorNew)
		self:ClearLines()
		self:cClien	:= cClien
		self:cLoja	:= cLoja
		self:cCaso	:= cCaso
	
		If !Empty(self:aItems)
	
			If !Empty(self:aSelItems)
				For nI := 1 to Len(self:aSelItems)
					nPos := aScan( self:aItems, { |x|, x[NPOSCODLAN] == self:aSelItems[ nI ] [ NPOSCODLAN ]   } )
					If nPos > 0 
						self:aItems[ nPos ] := self:aSelItems[ nI ]
					EndIf
				Next nI
			EndIf                                                                
		
	//		self:aComps	:= {}
			self:aSelItems	:= {}
		
			For nI := 1 to Len(self:aItems)
				If self:aItems[ nI ][ NPOSCLI ] == cClien .AND. self:aItems[ nI ][NPOSLOJA] == cLoja .AND. self:aItems[ nI ][NPOSCASO] == cCaso
					If self:aItems[ni][ NPOSDTLAN ] >= self:dPerIni .AND. self:aItems[ni][ NPOSDTLAN ] <= self:dPerFim

						If self:cTipo == "TS"
							//Campos de Agrupamento (TS: participante e valor hora)
							nPos := aScan	( self:aDadosRes,	{ |x| 	x[NPOSCLIRT]	== self:aItems[ nI ] [ NPOSCLI ] .AND.;
													   					x[NPOSLOJRT]	== self:aItems[ nI ] [ NPOSLOJA ] .AND.;
													   					x[NPOSCASRT]	== self:aItems[ nI ] [ NPOSCASO ] .AND.;	
																		x[NPOSPARRT]	== self:aItems[ nI ] [ NPOSPART  ] .AND.;
																		x[NPOSVLHRT]	== self:aItems[ nI ] [ NPOSTSVLH ] ;
																};
											)
						Else
							//Campos de Agrupamento (DP: Tipo Desp e Moeda)
							nPos := aScan	( self:aDadosRes,	{ |x| 	x[NPOSCLIRT]	== self:aItems[ nI ] [ NPOSCLI ] .AND.;
																		x[NPOSLOJRT]	== self:aItems[ nI ] [ NPOSLOJA ] .AND.;
																		x[NPOSCASRT]	== self:aItems[ nI ] [ NPOSCASO ] .AND.;	
																		x[NPOSTPLRT] == self:aItems[ nI ] [ NPOSTPLAN  ] .AND.;
																		x[NPOSMOERT] == self:aItems[ nI ] [ NPOSUTMOE  ] ;
																};
											)						
						EndIf
						If nPos > 0
							If self:aDadosRes[nPos][NPOSFILRES] == "LBOK"
								aAdd( self:aSelItems, self:aItems[nI] )
							EndIF
						EndIf
						
					EndIf
			    EndIf
			Next nI
			/*
			If !Empty(self:aSelItems)
				self:Primeiro(.T.)
			EndIf
			*/
		EndIf
	EndIf

Return nil

Method SelectTSPart(cClien, cLoja, cCaso, cPart, cVlH) Class TJURREVLANCTO
Local nI 		:= 0
Local nPos		:= 0
	For nI := 1 to Len(self:aItems)
		If 	self:aItems[ nI ][ NPOSCLI ] == cClien .AND. ;
			self:aItems[ nI ][NPOSLOJA] == cLoja .AND. ;
			self:aItems[ nI ][NPOSCASO] == cCaso .AND. ;
			self:aItems[ nI ][NPOSPART] == cPart .AND. ;
			self:aItems[ nI ][NPOSTSVLH] == cVlH .AND. ;
			self:aItems[ ni ][NPOSDTLAN] >= self:dPerIni .AND. ;
			self:aItems[ ni ][NPOSDTLAN] <= self:dPerFim
			
			nPos := aScan( self:aSelItems , { |ax| ax[ NPOSCODLAN ] == self:aItems[nI][ NPOSCODLAN ] }  )
			If nPos == 0
				aAdd( self:aSelItems, self:aItems[nI] )
			EndIf
	    EndIf
	Next nI
Return nil

Method SelectDPTipo(cClien, cLoja, cCaso, cTpDesp, cMoeda) Class TJURREVLANCTO
Local nI 		:= 0
Local nPos		:= 0
	For nI := 1 to Len(self:aItems)
		If 	self:aItems[ nI ][ NPOSCLI ] == cClien .AND. ;
			self:aItems[ nI ][NPOSLOJA] == cLoja .AND. ;
			self:aItems[ nI ][NPOSCASO] == cCaso .AND. ;
			self:aItems[ nI ][NPOSTPLAN] == cTpDesp .AND. ;
			self:aItems[ nI ][NPOSUTMOE] == cMoeda .AND. ;
			self:aItems[ ni ][NPOSDTLAN] >= self:dPerIni .AND. ;
			self:aItems[ ni ][NPOSDTLAN] <= self:dPerFim
			
			nPos := aScan( self:aSelItems , { |ax| ax[ NPOSCODLAN ] == self:aItems[nI][ NPOSCODLAN ] }  )
			If nPos == 0
				aAdd( self:aSelItems, self:aItems[nI] )
			EndIf
	    EndIf
	Next nI
Return nil

Method Refresh() Class TJURREVLANCTO
Local nI := 0
Local nJ := 0
	For nI := 1 to len( self:aComps )
		For nJ := 1 to len( self:aComps[nI] )
				If ValType(self:aComps[ni][nJ]) == "O"
					self:aComps[ni][nJ]:Refresh()   
				EndIf
		Next nJ
	Next nI

	IF self:lEnable
		self:Enable()
	Else
		self:Disable()
	EndIf
	
Return nil

Method CriaAcoes ()  Class TJURREVLANCTO
Local aOrdena 	:= { }
Local nPos2	:= aScan( self:aListCas, {|x| x[NPOSCASCLI] == self:cClien .AND.  x[NPOSCASLOJ] == self:cLoja .AND. x[NPOSCASCOD] == self:cCaso } )

	// Filtro de Periodo - Quadro de agrupamento
	self:oGrpPeriod := TGroup():New( 003, 005, 032, 115, STR0024, self:oMainPanel:GetPanel( self:aResumo[2] ), , , .T. )  //Período
	self:opnlGroup	:= tPanel():New( 003+6, 005+3, "", self:oGrpPeriod, , , , , /*CLR_YELLOW*/ , 105, 022, .F., .F. )
	
	Self:lCkWO		:= IF( nPos2 > 0, self:aListCas[nPos2][NPOSCASWO] , .F. )
	Self:lCkRet		:= IF( nPos2 > 0, self:aListCas[nPos2][NPOSCASRET], .F. )
	Self:lCkTran	:= IF( nPos2 > 0, self:aListCas[nPos2][NPOSCASTRA], .F. )
	Self:lCkCob		:= IF( nPos2 > 0, self:aListCas[nPos2][NPOSCASCOB], .F. )
	Self:lCkRev		:= IF( nPos2 > 0, self:aListCas[nPos2][NPOSCASREV], .F. )


	// Filtro de Periodo - Campos
	//Data Inicial 
	
	self:oPerIni := TJurPnlCampo():New( 5, 5, 045, 012,;
									self:opnlGroup,;
									"", "",;
									{ ||  },;
									{ ||  },;
									self:dPerIni,;
									/*lVisivel*/, /*lEnable*/, )
	self:oPerIni:valor		:= self:dPerIni
	self:oPerIni:SetChange( {|| (self:SelectLancs(self:cClien, self:cLoja, self:cCaso, "oPerIni" , self:dPerIni , self:oPerIni:Valor ), self:primeiro() )} )

	self:oPerFim := TJurPnlCampo():New( 5,055, 045, 012,;
									self:opnlGroup,;
									"", "",;
									{ ||  },;
									{ ||  },;
									JSToFormat(self:dPerFim, "dd/mm/yyyy"),;
									/*lVisivel*/, /*lEnable*/, )
	self:oPerFim:valor		:= self:dPerFim
	self:oPerFim:SetChange( {|| (self:SelectLancs(self:cClien, self:cLoja, self:cCaso, "oPerFim" , self:dPerFim , self:oPerFim:Valor ), self:primeiro() )} )

	// Ordenacao - Quadro de agrupamento
	self:oGrpOrdem := TGroup():New( 003, 120, 032, 168, STR0020, self:oMainPanel:GetPanel( self:aResumo[2] ), , , .T. ) // "Ordenação"

	// Ordenacao - Radio Buttons de seleção
  	aOrdena := { STR0021, STR0022 } //"Data", "Profissional"
    oOrdena := TRadMenu():New ( 011, 125, aOrdena, , self:oGrpOrdem, , , , , , , , 100, 22 , , , , .T. )
	oOrdena:bSetGet := { | _x | if( Pcount()==0, self:nOrdemLanc, self:OrderLanc(_x)  ) }

	//Grupo de acoes rapidas
	self:oGrpAcoes	:= TGroup():New( 38, 05, 69, 115, STR0023, self:oMainPanel:GetPanel( self:aResumo[2] ), , , .T. )   // "Ações (Global no caso):"

	// Controles (TODOS) - Botões de aplicação
	self:oCkWO 				:= 	TJurCheckBox():New( 46, 010, STR0014,			{ | | Self:lCkWO  }, self:oGrpAcoes, 100, 10, , { || self:MarcaChecks(Nil, "0", NPOSWO    ) }, , , , , ,.T., STR0031 , , ) //"Aplica no caso, independente do filtro"
	self:oCkWO:lcheckjur	:= Self:lCkWO

	self:oCkRet				:= TJurCheckBox():New( 56, 010, STR0017,		{ | | Self:lCkRet }, self:oGrpAcoes, 100, 10, , { || self:MarcaChecks(Nil, "0", NPOSRETIR ) }, , , , , ,.T., STR0031 , , ) //"Aplica no caso, independente do filtro"
	self:oCkRet:lcheckjur	:= Self:lCkRet

	self:oCkTran			:= TJurCheckBox():New( 46, 045,	STR0018,	{ | | Self:lCkTran}, self:oGrpAcoes, 100, 10, , { || self:MarcaChecks(Nil, "0", NPOSTRANS ) }, , , , , ,.T., STR0031, , ) //"Aplica no caso, independente do filtro"
	self:oCkTran:lcheckjur	:= Self:lCkTran

	self:oCkCob				:= TJurCheckBox():New( 46, 080,	STR0019,		{ | | Self:lCkCob }, self:oGrpAcoes, 100, 10, , { || self:MarcaChecks(Nil, "0", NPOSCOBRA ) }, , , , , ,.T.,STR0031, , ) //"Aplica no caso, independente do filtro"
	self:oCkCob:lcheckjur	:= Self:lCkCob

	self:oCkRev 			:= TJurCheckBox():New( 56, 045, STR0016,		{ | | Self:lCkRev }, self:oGrpAcoes, 100, 10, , { || self:MarcaChecks(Nil, "0", NPOSREVIS ) }, , , , , ,.T., STR0031 , , ) //"Aplica no caso, independente do filtro"
	self:oCkRev:lcheckjur	:= Self:lCkRev

	Do Case
		Case self:cTipo == "TS"
			self:oCkCob:lVisible := JVldCampo("NUE_COBRAR")
			self:oCkRev:lVisible := .T.
		Case self:cTipo == "DP"
			self:oCkCob:lVisible := JVldCampo("NVY_COBRAR")
			self:oCkRev:lVisible := .F.	
		Case self:cTipo == "TB"
			self:oCkCob:lVisible := JVldCampo("NV4_COBRAR")
			self:oCkRev:lVisible := .F.	
	EndCase
	//Grupo Exibir: (Todos / Nenhum)
	self:oGrpFiltro := TGroup():New( 38, 120, 69, 168, STR0028, self:oMainPanel:GetPanel( self:aResumo[2] ), , , .T. ) // "Exibir"

	self:oBotT	:= TButton():New( 46, 125, STR0029, self:oGrpFiltro, { || self:FiltraTudo(1)   }, 38, 09, , , , .T., , STR0029 )	// "Atualizar"
	self:oBotN	:= TButton():New( 56, 125, STR0030, self:oGrpFiltro, { || self:FiltraTudo(2)   }, 38, 09, , , , .T., , STR0030 )	// "Atualizar"
	
Return nil

Method OrderLanc(nCampo)   Class TJURREVLANCTO
Local aOrdem := {}
Local nCpoOrdem := 0
Local cTpOrdena := SuperGetMV( 'MV_JORDPAR',, 2 ) //Define a ordenação dos lançamentos pelo Código do Participante (RD0_COD) - 1 ou pela Sigla (RD0_SIGLA) - 2.

If cTpOrdena $ "2"
	nCpoOrdem := NPOSPART
Else 
	nCpoOrdem := NPOSCPART2 
EndIf

	aOrdem	:= aClone( self:aSelItems )

	If nCampo == 1
		aSort( aOrdem,,, { |aX,aY|  dtos(aX[NPOSDTLAN]) + aX[nCpoOrdem]  <  dtos(aY[NPOSDTLAN] ) + aY[nCpoOrdem]  } )
	Else
		nCpoOrdem 	:= NPOSPART	//Participante
		aSort( aOrdem,,, { |aX,aY| aX[nCpoOrdem]+aX[NPOSCODLAN] < aY[nCpoOrdem] + aY[NPOSCODLAN] } )

	EndIf
	
	self:aSelItems	:= aOrdem

	If nCampo <> self:nOrdemLanc

		self:nOrdemLanc	:= nCampo

		self:primeiro(.T.)
	EndIf

Return aOrdem

Method SetDtIni(dData)  Class TJURREVLANCTO
	If !Empty(dData) .AND. valtype(dData) == "D"
		self:dPerIni	:= dData
	Else
		self:dPerIni	:= ctod("  /  /    ")
	EndIf
Return nil
Method SetDtFim(dData)  Class TJURREVLANCTO
	If !Empty(dData) .AND. valtype(dData) == "D"
		self:dPerFim	:= date()
	Else
		self:dPerFim	:= ctod("  /  /    ")
	EndIf
Return nil


Method LimpaRef()  Class TJURREVLANCTO
	self:ParentView := nil
Return nil 


Function TJREVLANED(nlinha, cCampo) 
Local lRet		:= .F.

	If self:lEnable
	    If cCampo $ self:cCpoRes +" | NX2_VALOR1 |  " + "|" + STR0004  + "|" + STR0017  + "|" + STR0014
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	Else
	    If cCampo $ STR0004
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf

Return lRet

Method Disable()  Class TJURREVLANCTO
	Local nI := 0
	Local nJ := 0
	Local nPosAux := NPOSTSVL1 // By JPP - 01/11/2012 - Inclusão de tratamentos no Array aComps[], para saber se seu tipo é objeto ou não.

	self:lEnable	:= .F.
	If valtype(self:oGridResumo) == "O" 
		self:oGridResumo:Disable()
	EndIf
	
	For nI := 1 to len( self:aComps )
	
		self:aComps[nI][NPOSDTLAN]:Enable(.F.)
		self:aComps[nI][NPOSPART ]:Enable(.F.)
		self:aComps[nI][NPOSTPLAN]:Enable(.F.)
		self:aComps[nI][NPOSDESCR]:Enable(.F.)
		self:aComps[nI][NPOSUTMOE]:Enable(.F.)
		self:aComps[nI][NPOSUTVLR]:Enable(.F.)   
		//self:aComps[nI][NPOSTSVL1]:Enable(.F.)  // By JPP - 08/11/2013 - 16h09m - Este campo só existe para Time Sheet e já está definido no IF abaixo. 
		self:aComps[nI][NPOSWO   ]:bWhen := {|| .F. }
		self:aComps[nI][NPOSRETIR]:bWhen := {|| .F. }
		self:aComps[nI][NPOSTRANS]:bWhen := {|| .F. }
		
		If self:cTipo == "TS"
			self:aComps[nI][NPOSDE   ]:bWhen := {|| .F. }
			self:aComps[nI][NPOSREVIS]:bWhen := {|| .F. }
			self:aComps[nI][NPOSCOBRA]:bWhen := {|| .F. }
			self:aComps[nI][NPOSTSVL1]:Enable(.F.)
		Else
			self:aComps[nI][NPOSCOBRA]:bWhen := {|| .F. }
		EndIF

	Next nI
	
	Self:oCkWO:bWhen   := {|| .F. }
	Self:oCkRet:bWhen  := {|| .F. }
	Self:oCkTran:bWhen := {|| .F. }
	Self:oCkCob:bWhen  := {|| .F. }
	Self:oCkRev:bWhen  := {|| .F. }
	
	
Return nil

Method Enable()  Class TJURREVLANCTO
	Local nI 	:= 0
	Local nJ 	:= 0
	Local nPos	:= 0

	self:lEnable	:= .T.
	If valtype(self:oGridResumo) == "O"
		self:oGridResumo:Enable()
	EndIf
	
	For nI := 1 to len( self:aComps )

		If self:aComps[nI][DRAW]

			nPos := aScan( self:aSelItems , { |ax| ax[NPOSCODLAN] == self:aComps[nI][NPOSCODLAN] }  )

			If self:cTipo == "TS"
				self:aComps[nI][NPOSDTLAN]:Enable(.T.)
				self:aComps[nI][NPOSPART ]:Enable(.T.)
				self:aComps[nI][NPOSTPLAN]:Enable(.T.)
				self:aComps[nI][NPOSDESCR]:Enable(.T.)
				self:aComps[nI][NPOSUTMOE]:Enable(self:aSelItems[nPos][ NPOSDE ])
				self:aComps[nI][NPOSUTVLR]:Enable(.T.)
				self:aComps[nI][NPOSWO   ]:bWhen := {|| .T. }
				self:aComps[nI][NPOSDE   ]:bWhen := {|| .T. }
				self:aComps[nI][NPOSRETIR]:bWhen := {|| .T. }
				self:aComps[nI][NPOSTRANS]:bWhen := {|| .T. }
				self:aComps[nI][NPOSREVIS]:bWhen := {|| .T. }
				self:aComps[nI][NPOSCOBRA]:bWhen := {|| .T. }
				self:aComps[nI][NPOSTSVL1]:Enable(.T.)
			Else
				self:aComps[nI][NPOSDTLAN]:Enable(.F.)
				self:aComps[nI][NPOSPART ]:Enable(.F.)
				self:aComps[nI][NPOSTPLAN]:Enable(.F.)
				self:aComps[nI][NPOSDESCR]:Enable(.T.)
				self:aComps[nI][NPOSUTMOE]:Enable(.F.)
				If self:cTipo == "TB"
					self:aComps[nI][NPOSUTVLR]:Enable(.T.)
				Else
					self:aComps[nI][NPOSUTVLR]:Enable(.F.)
				EndIF
				self:aComps[nI][NPOSWO   ]:bWhen := {|| .T. }
				self:aComps[nI][NPOSRETIR]:bWhen := {|| .T. }
				self:aComps[nI][NPOSTRANS]:bWhen := {|| .T. }
				self:aComps[nI][NPOSCOBRA]:bWhen := {|| .T. }
			EndIF

		EndIF

	Next nI 

	Self:oCkWO:bWhen   := {|| .T. }
	Self:oCkRet:bWhen	 := {|| .T. }
	Self:oCkTran:bWhen := {|| .T. }
	Self:oCkCob:bWhen  := {|| .T. }
	Self:oCkRev:bWhen  := {|| .T. }
	
Return nil

Method GoToLine(oCampo) Class TJURREVLANCTO
Local lRet      := .T.
Local oModelNX8 := self:oModel:GetModel("NX8DETAIL")
Local oModelNX1 := self:oModel:GetModel("NX1DETAIL")
Local cIdModel

		Do Case
			Case self:cTipo == "TS"
				cIdModel := "NUEDETAIL"
			Case self:cTipo == "DP"
				cIdModel := "NVYDETAIL"
			Case self:cTipo == "TB"
				cIdModel := "NV4DETAIL"
			OtherWise
				lRet := .F.
		EndCase

	If lRet
    lRet := oModelNX8:GoLine(oCampo[LN_CONTRATO]) == oCampo[LN_CONTRATO] .And. ;
            oModelNX1:GoLine(oCampo[LN_CASO])     == oCampo[LN_CASO]     .And. ;
            self:oModel:GetModel(cIdModel):GoLine(oCampo[LN_LANC]) == oCampo[LN_LANC]
		Self:ParentView:Refresh(cIdModel)
	EndIf

Return lRet

Method UpdateRevisado(nLine) Class TJURREVLANCTO

	If self:aComps[nLine][NPOSUTMOE]:GetValueOld() == self:aComps[nLine][NPOSUTVLR]:GetValue()
		self:aComps[nLine][NPOSUTVLR]:valor := self:aComps[nLine][NPOSUTMOE]:GetValue()
		self:aComps[nLine][NPOSUTVLR]:Refresh()

//		nPos := aScan( self:atems , { |ax| ax[NPOSCODLAN] == cCod }  )

	EndIf

Return Nil

Method GetMdlLancto() Class TJURREVLANCTO
Local oModelLanc

	Do Case
		Case self:cTipo == "TS"
			oModelLanc	:= self:oModel:GetModel("NUEDETAIL")
		Case self:cTipo == "DP"
			oModelLanc	:= self:oModel:GetModel("NVYDETAIL")
		Case self:cTipo == "TB"
			oModelLanc	:= self:oModel:GetModel("NV4DETAIL")
		OtherWise
			oModelLanc	:= Nil
	EndCase

Return oModelLanc

Method FiltraTudo(ntemp) Class TJURREVLANCTO
Local lRet := .T.
Local ni		:= 0
Local aBrowse	:= self:aSelRes
Local oBrowse	:= self:oGridResumo:oBrowse
Local nLine		:= oBrowse:nAt

	If !Empty(self:aItems)
		IF ntemp == 1
			self:ClearLines()
			self:aSelItems	:= {}
		EndIf
		For ni := 1 to len(aBrowse)
			oBrowse:nAt := ni
			aBrowse[oBrowse:nAt][NPOSFILRES] := IIF(ntemp == 1, "LBOK", "LBNO")
			Self:Filtra(aBrowse, oBrowse, ntemp == 1)
			
		Next ni
		oBrowse:nAt := nLine
		
		For ni:= 1 to len(self:aDadosRes)

			If 	self:aDadosRes[ni][NPOSCLIRT] == self:cClien .AND. ;
				self:aDadosRes[ni][NPOSLOJRT] == self:cloja .AND. ;
				self:aDadosRes[ni][NPOSCASRT] == self:cCaso
		
				self:aDadosRes[ni][NPOSFILRT] := aBrowse[oBrowse:nAt][NPOSFILRES]
				self:aDadosRes[ni][NPOSRETRT] := aBrowse[oBrowse:nAt][NPOSRETRES]
				self:aDadosRes[ni][NPOSWORT]  := aBrowse[oBrowse:nAt][NPOSWORES]

			EndIF
		Next ni

		self:Primeiro()
		self:Refresh()
		oBrowse:Refresh()
	EndIf
	
Return lRet

Method Filtra(aBrowse, oBrowse, lExibe) Class TJURREVLANCTO
Local lRet := .T.

	If lExibe
		Do Case
			Case self:cTipo == "TS"
				self:SelectTSPart( self:cClien, self:cloja, self:cCaso,  aBrowse[oBrowse:nAt][NPOSPARRES], aBrowse[oBrowse:nAt][NPOSVLHRS] ) //Participante e Valor H
			Case self:cTipo == "DP"
				self:SelectDPTipo( self:cClien, self:cloja, self:cCaso,  aBrowse[oBrowse:nAt][NPOSTPLRES], aBrowse[oBrowse:nAt][NPOSUTMOER ] ) //Tipo desp e Moeda
			Case self:cTipo == "TB"
				self:SelectDPTipo( self:cClien, self:cloja, self:cCaso,  aBrowse[oBrowse:nAt][NPOSTPLRES], aBrowse[oBrowse:nAt][NPOSUTMOER ] ) //Tipo Serviço e Moeda
		EndCase
	Else
		Do Case
			Case self:cTipo == "TS"
				While (ascan( self:aSelItems, { |x|  x[NPOSPART] == aBrowse[oBrowse:nAt][NPOSPARRES] .AND. x[NPOSTSVLH] ==  aBrowse[oBrowse:nAt][NPOSVLHRS ] }  ) ) > 0 
					self:aSelItems := JaRemPos(self:aSelItems, ascan( self:aSelItems, { |x|  x[NPOSPART] == aBrowse[oBrowse:nAt][NPOSPARRES] .AND. x[NPOSTSVLH] ==  aBrowse[oBrowse:nAt][NPOSVLHRS ] }  ) )
				EndDo
			Case  self:cTipo == "DP"
				While (ascan( self:aSelItems, { |x|  x[NPOSTPLAN] == aBrowse[oBrowse:nAt][ NPOSTPLRES ] .AND. x[NPOSUTMOE] ==  aBrowse[oBrowse:nAt][ NPOSUTMOER ] }  ) ) > 0 
					self:aSelItems := JaRemPos(self:aSelItems, ascan( self:aSelItems, { |x|  x[NPOSTPLAN] == aBrowse[oBrowse:nAt][ NPOSTPLRES ] .AND. x[NPOSUTMOE] ==  aBrowse[oBrowse:nAt][ NPOSUTMOER ] }  ) )
				EndDo
			Case  self:cTipo == "TB"
				While (ascan( self:aSelItems, { |x|  x[NPOSTPLAN] == aBrowse[oBrowse:nAt][ NPOSTPLRES ] .AND. x[NPOSUTMOE] ==  aBrowse[oBrowse:nAt][ NPOSUTMOER ] }  ) ) > 0 
					self:aSelItems := JaRemPos(self:aSelItems, ascan( self:aSelItems, { |x|  x[NPOSTPLAN] == aBrowse[oBrowse:nAt][ NPOSTPLRES ] .AND. x[NPOSUTMOE] ==  aBrowse[oBrowse:nAt][ NPOSUTMOER ] }  ) )
				EndDo
		EndCase
	EndIf
Return lRet

Static function JA202SomaH(cHora1, cHora2)
Local cHora 	:= ""
Local nsomaHH	:= 0
Local nSomaMM 	:= 0
	If Empty(cHora1)
		cHora1 := "00:00"
	EndIf
	If Empty(cHora2)
		cHora2 := "00:00"
	EndIf	

	nsomaHH := val(substr( cHora1  , 0 						, at( ":",  cHora1 ) -1  ))	+ val( substr( cHora2  , 0						, at( ":",  cHora2 ) -1  ))
	nSomaMM := val(substr( cHora1  , at( ":", cHora1 ) + 1	, len ( cHora1 )   ))		+ val( substr( cHora2  , at( ":", cHora2 ) + 1	, len( cHora2  )   ) )
    
	nsomaHH += int(nSomaMM / 60)
	nsomaMM := nSomaMM % 60
	cHora := strzero(nsomaHH , 4) + ":" + strzero(nsomaMM , 2)

Return cHora

Method UpdateValores(nLine, cCampoCham) Class TJURREVLANCTO
Local lRet      := .T.
Local oModelNUE := self:oModel:GetModel("NUEDETAIL")
Local oModelNX8	:= self:oModel:GetModel("NX8DETAIL")
Local oModelNX1	:= self:oModel:GetModel("NX1DETAIL")
Local nLinNX1	:= 0
Local nLinNX8	:= 0
Local nLinNUE	:= 0
Local nPosNX8   := 0
Local nPosNX1   := 0
Local nPosNUE	:= 0
Local nNX8      := 0
Local nNX1      := 0
Local nNUE   	:= 0
Local lAchou    := .F.

nPosNX8 := oModelNX8:GetLine()
nPosNX1 := oModelNX1:GetLine()
nPosNUE := oModelNUE:GetLine()		

For nLinNX8 := 1 to oModelNX8:Length()
	oModelNX8:GoLine(nLinNX8)
	For nLinNX1 := 1 to oModelNX1:Length()
		oModelNX1:GoLine(nLinNX1)
		For nLinNUE := 1 to oModelNUE:Length()
			oModelNUE:GoLine(nLinNUE)
			If oModelNUE:GetValue("NUE_COD") == self:aComps[nLine][NPOSCODLAN]
				nNUE := oModelNUE:GetLine()
				nNX1 := oModelNX1:GetLine()
				nNX8 := oModelNX8:GetLine()				
				lAchou  := .T.
				Exit			
			EndIf
       	Next nLinNUE
       	If lAchou
			Exit
		EndIf
	Next nLinNX1
	If lAchou
		Exit
	EndIf
Next nLinNX8	

oModelNX8:GoLine(nNX8)
oModelNX1:GoLine(nNX1)		
oModelNUE:GoLine(nNUE)

If cCampoCham $ "NPOSUTVLR" .And. self:aComps[nLine][NPOSUTVLR]:IsChanged()
	self:aComps[nLine][NPOSTSVL1]:SetValue(oModelNUE:GetValue("NUE_VALOR1"))
EndIf                                       

If cCampoCham $ "NPOSTSVL1" .And. self:aComps[nLine][NPOSTSVL1]:IsChanged()
	self:aComps[nLine][NPOSUTVLR]:SetValue(oModelNUE:GetValue(self:cCpoRev)) 
EndIf

If cCampoCham $ "NPOSPART" .And. self:aComps[nLine][NPOSPART]:IsChanged()
	self:aComps[nLine][NPOSTSVL1]:SetValue(oModelNUE:GetValue("NUE_VALOR1")) 
EndIf

oModelNX8:GoLine(nPosNX8)
oModelNX1:GoLine(nPosNX1)
oModelNUE:GoLine(nPosNUE)

JURA144W(cCampoCham)

If !lRet
	Alert(STR0032) //"Não foi possível fazer a alteração."
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldCampo
Valida o campo e retorna .T. ou .F.

@author Rafael Telles de Macedo	
@since 04/05/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVldCampo(cCampo)
Local lRet:= .T.
Local nX
Local nY
Local nZ
Local nPos
Local CAMPOS_REMOVER:= 3
Local CAMPOS_TABELA := 1
Local aStructs   := {}
Local lJA202FLDS := ExistBlock('JA202FLDS')
Local aCampos    := {}
Local oStructNUE := FWFormStruct( 1, 'NUE' )  // Time Sheet
Local oStructNV4 := FWFormStruct( 1, 'NV4' )  // Tabelado
Local oStructNVY := FWFormStruct( 1, 'NVY' )  // Despesas

If lJA202FLDS

aCampos := ExecBlock('JA202FLDS',.F.,.F.)

	If ValType( aCampos ) == 'A'
	
		For nX := 1 To Len( aCampos )
			For nY := Len( aCampos[nX] ) + 1 To 4
				aAdd( aCampos[nX], {} )
			Next
	
			If     aCampos[nX][2] == NIL
				aCampos[nX][2]  := {}
			ElseIf aCampos[nX][3] == NIL
				aCampos[nX][3]  := {}
			ElseIf aCampos[nX][4] == NIL
				aCampos[nX][4]  := {}
			EndIf
		Next
	
		aStructs := { ;
			{ 'NUE', oStructNUE, 'NUEDETAIL' },;
			{ 'NV4', oStructNV4, 'NV4DETAIL' },;
			{ 'NVY', oStructNVY, 'NVYDETAIL' } }
	
			For nZ := 1 To Len( aStructs )
				
				If ( nPos := aScan( aCampos, { |aX| aX[CAMPOS_TABELA] == aStructs[nZ][1] } ) ) > 0
					
					//Remove Campos
					For nX := 1 To Len( aCampos[nPos][CAMPOS_REMOVER] )
						If aCampos[nPos][CAMPOS_REMOVER][nX] == cCampo
							lRet:= .F.
						EndIf
					Next
					
				EndIf
			Next
	
	Else
		aCampos := {}
	EndIf
EndIf

Return lRet
