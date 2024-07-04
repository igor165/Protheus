#include "protheus.ch"
#include "report.ch"
#include "agrar630.ch"

/*/{Protheus.doc} AGRAR630
//Relatório de Romaneio de Classificação
@author bruna.rocio
@since 22/07/2015
@version undefined
@type function
/*/
Function AGRAR630( )
 	Local aAreaAtu 	:= GetArea() 
	Local oReport	:= Nil
	
	     
	    
	If FindFunction("TRepInUse") .And. TRepInUse()
		Pergunte("AGRAR630",.F.)
		oReport:= ReportDef()
		oReport:PrintDialog()		
	EndIf
	
	RestArea( aAreaAtu )
Return( Nil )


/*/{Protheus.doc} ReportDef
//Função de definição de seções e layout do relatório
@author bruna.rocio
@since 22/07/2015
@version undefined
@type function
/*/
Static Function ReportDef()
	Local oReport		:= Nil
	Local oSection1		:= Nil
	Local oSection2		:= Nil
		
	//Chamada Relatório
	oReport := TReport():New("AGRAR630", STR0001, , {| oReport | PrintReport( oReport ) }, STR0002)
		
	oReport:oPage:SetPageNumber(1)
	oReport:lBold 		   := .F.
	oReport:lUnderLine     := .F.
	oReport:lHeaderVisible := .T.
	oReport:lFooterVisible := .T.
	oReport:lParamPage     := .F.
	
	//Seção 1 - Relatório
	oSection1 := TRSection():New( oReport, STR0001, { "DXJ" } ) //Romaneio de Classificação
	oSection1:lLineStyle := .t. 
	
	//Linha 1
	TRCell():New( oSection1, "DXJ_SAFRA", "DXJ", /*Title*/, /*Mask*/, 48, .t., /*Block*/, , , "LEFT" )
	TRCell():New( oSection1, "CODIGO"	,  , STR0005/*"Código"*/, "@!", 50, .T., {|| getCodigo(DXJ_CODIGO, DXJ_TIPO) }, , , "LEFT" )
	TRCell():New( oSection1, "DXJ_DATA" , "DXJ", /*Title*/, /*Mask*/, , .t., /*Block*/, , , "LEFT", .T. ) 
	
	//Linha 2 
	TRCell():New( oSection1, "PRODUTOR",  , STR0006/*"Produtor"*/, "@!", 45 , .F., {|| getProdutor(DXJ_PRDTOR, DXJ_LJPRO) }, , , "LEFT" )
	TRCell():New( oSection1, "FAZENDA" ,  , STR0007/*"Fazenda"*/, "@!", 50 , .T., {|| getFazenda(DXJ_FAZ) }, , , "LEFT", .T. ) 
		
	//Linha 3
	TRCell():New( oSection1, "VARIEDADE" ,  , STR0008/*"Variedade"*/, "@!", 44, .T., {|| getVaried(DXJ_CODVAR)}, , , "LEFT"  ) 
	TRCell():New( oSection1, "DXJ_FRDINI", "DXJ", STR0009/*"Fardo Inicial"*/, , 15, .T., , , , "LEFT" )
	TRCell():New( oSection1, "DXJ_FRDFIM", "DXJ", STR0010/*"Fardo Final"*/)
	
	//Seção 2 - Relatório
	oSection2 := TRSection():New( oReport, STR0003, { "DXK" } ) //"Itens do Romaneio de Classificação"
	oSection2:lAutoSize := .T.
	TRCell():New( oSection2, "DXK_ETIQ"	 , "DXK")
	TRCell():New( oSection2, "PRENSA"	 , " ", STR0011/*"Prensa"*/, PesqPict('DXI',"DXI_PRENSA"), 06, .f.)
	TRCell():New( oSection2, "DXK_CLAVIS", "DXK") 
	TRCell():New( oSection2, "DXK_PSLIQU", "DXK")
				
	oBreak1 := TRBreak():New( oSection2, "", STR0012/*"Total"*/, .f. )//"Total -->"
	TRFunction():New(oSection2:aCell[1], Nil, "COUNT", oBreak1, STR0013/*"Total de fardos"*/, , , .F., .F., )	
	TRFunction():New(oSection2:aCell[4], Nil, "SUM"  , oBreak1, STR0014/*"Peso total"*/     , , , .F., .F., )
Return (oReport)


/*/{Protheus.doc} PrintReport
//Função de impressão do relatório
@author bruna.rocio
@since 22/07/2015
@version undefined
@param oReport, object, descricao
@type function
/*/
Static Function PrintReport(oReport)
	Local aAreaAtu	:= GetArea()
	Local oS1			:= oReport:Section( 1 )
	Local oS2			:= oReport:Section( 2 )
	Local cUN        := ""  
	Local cWhere     := ""
	Local lRet       := .f.
	  
	If oReport:Cancel()
		Return( Nil )
	EndIf
	
	cUN := A655GETUNB( )  
	If IsBlind()
	  lRet := .t.
	EndIf
	
	If !Funname() = "AGRA630" .AND. lRet = .F.
	   
		cWhere += "  DXJ.DXJ_FILIAL >= '" + MV_PAR01 + "'"
		cWhere += " AND DXJ.DXJ_FILIAL <= '" + MV_PAR02 + "'"
		cWhere += " AND DXJ.DXJ_PRDTOR >= '" + MV_PAR03 + "'"
		cWhere += " AND DXJ.DXJ_PRDTOR <= '" + MV_PAR05 + "'"
		cWhere += " AND DXJ.DXJ_LJPRO  >= '" + MV_PAR04 + "'"
		cWhere += " AND DXJ.DXJ_LJPRO  <= '" + MV_PAR06 + "'"
		cWhere += " AND DXJ.DXJ_SAFRA  >= '" + MV_PAR07 + "'"
		cWhere += " AND DXJ.DXJ_SAFRA  <= '" + MV_PAR08 + "'"
		
		If !Empty(cUN)
			cWhere += " AND DXJ.DXJ_CODUNB = '" + cUN + "' "
		Endif
	Else
		
		cWhere += "  DXJ.DXJ_FILIAL = '" + FWxFilial('DXJ') + "'"
		cWhere += " AND DXJ.DXJ_CODIGO = '" + DXJ->DXJ_CODIGO + "'"
		cWhere += " AND DXJ.DXJ_TIPO   = '" + DXJ->DXJ_TIPO + "'"
		
		If !Empty(cUN)
			cWhere += " AND DXJ.DXJ_CODUNB = '" + cUN + "' "
		Endif 
	Endif
		
	cWhere := "%"+cWhere+"%"
	
	oS1:BeginQuery()
	oS1:Init()
	
	BeginSql Alias "QryDXJ"
		Select DXJ.*
		FROM %Table:DXJ% DXJ
		WHERE
			DXJ.%NotDel% AND
			%exp:cWhere%
	EndSql
	oS1:EndQuery()
	
	QryDXJ->(dbGoTop())
	
	oS1:Init()
	While .Not. QryDXJ->(Eof())
						
		oS1:PrintLine()
		
		oS2:BeginQuery()
		oS2:Init()
        
        If DXK->(ColumnPos('DXK_TIPO')) > 0 	
			BeginSql Alias "QryDXK"
				Select DXK.*
				FROM %Table:DXK% DXK
				WHERE DXK.%NotDel%
				  AND DXK.DXK_FILIAL = %exp:QryDXJ->DXJ_FILIAL%	
				  AND DXK.DXK_CODROM = %exp:QryDXJ->DXJ_CODIGO%
				  AND DXK.DXK_TIPO   = %exp:QryDXJ->DXJ_TIPO%	
			EndSQL
		Else
			BeginSql Alias "QryDXK"
				Select *
				FROM %Table:DXK% DXK
				WHERE DXK.%NotDel%
				  AND DXK.DXK_FILIAL = %exp:QryDXJ->DXJ_FILIAL%	
				  AND DXK.DXK_CODROM = %exp:QryDXJ->DXJ_CODIGO%
			EndSQL

		EndIf	
		oS2:EndQuery()
		
		QryDXK->(dbGoTop())
		
		oS2:Init()
		While .Not. QryDXK->(Eof())
					
			oS2:aCell[2]:SetValue( retPrensa(QryDXK->DXK_SAFRA, QryDXK->DXK_ETIQ) )	
										
			oS2:PrintLine()
			QryDXK->( dbSkip() )
		EndDo
		QryDXK->( dbCloseArea() )
		oS2:Finish()	
		
		QryDXJ->( dbSkip() )
	EndDo
	QryDXJ->( dbCloseArea() )
	oS1:Finish()	
	
	RestArea(aAreaAtu)		
Return .t.

/*/{Protheus.doc} getCodigo
//Formata informação de código junto ao tipo da mala
@author bruna.rocio
@since 11/04/2017
@version undefined
@param cCodigo, characters, descricao
@param cTipo, characters, descricao
@type function
/*/
Static Function getCodigo(cCodigo, cTipo)
	Local cRet := ""

	cRet := cCodigo + " - " + X3CBOXDESC("DXJ_TIPO", cTipo)
Return cRet


/*/{Protheus.doc} getProdutor
//Formata a informação de produtor com loja e nome
@author bruna.rocio
@since 11/04/2017
@version undefined
@param cProdutor, characters, descricao
@param cLoja, characters, descricao
@type function
/*/
Static Function getProdutor(cProdutor, cLoja)
	Local cRet := ""

	If !Empty(cProdutor)
		cRet := cProdutor + "/" + cLoja + " - " + Posicione("NJ0",1,FWxFilial("NJ0")+cProdutor+cLoja,"NJ0_NOME")
	Endif
	
Return cRet
 
/*/{Protheus.doc} getFazenda
//Formata a informação de fazenda junto com nome
@author bruna.rocio
@since 11/04/2017
@version undefined
@param cFazenda, characters, descricao
@type function
/*/
Static Function getFazenda(cFazenda)
	Local cRet := ""
	
	If !Empty(cFazenda)
		cRet := cFazenda + " - " + Posicione("NN2",2,FWxFilial("NN2")+cFazenda,"NN2_NOME")
	Endif
Return cRet

/*/{Protheus.doc} getVaried
@author bruna.rocio
@since 11/04/2017
@version undefined
@param cVariedade, characters, descricao
@type function
/*/
Static Function getVaried(cVariedade)
	Local cRet := ""

	If !Empty(cVariedade)
		cRet := Posicione("NNV",2,FWxFilial("NNV")+cVariedade,"NNV_DESCRI")
	Endif
Return cRet

/*/{Protheus.doc} retPrensa
@author bruna.rocio
@since 22/07/2015
@version undefined
@param cSafra, characters, descricao
@param cEtiq, characters, descricao
@type function
/*/
Static Function retPrensa(  cSafra, cEtiq  )
	Local cPrensa     := ""
	
	dbSelectArea('DXI')
	dbSetOrder(1)
	If MsSeek(FWxFilial('DXI') +  cSafra + cEtiq)
		
		cPrensa := DXI->DXI_PRENSA
	Endif	
Return ( cPrensa )
//commit teste