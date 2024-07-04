#include "protheus.ch"
#include "report.ch"
#include "OGR710.ch"

/*/{Protheus.doc} OGR710
//Função inicial do relatório
@author marina.muller
@since 25/09/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OGR710()
 	Local aAreaAtu 	   := GetArea() 
	Local oReport	   := Nil
	Private cPergunta  := "OGR7100001"
	    
	If FindFunction("TRepInUse") .And. TRepInUse()
		Pergunte(cPergunta, .F.)
		
		oReport:= ReportDef()
		oReport:PrintDialog()
	EndIf
	
	RestArea( aAreaAtu )
Return( Nil )

/*/{Protheus.doc} ReportDef
//Função define configuração do relatório
@author marina.muller
@since 25/09/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ReportDef()
	Local oReport		:= Nil
	Local cTitulo       := "" 
	
	// se tipo relatório for analítico
	If MV_PAR10 = 1
		cTitulo := /*"Operacional de Pedidos"*/ STR0001 + " - " + /*" Analítico"*/ STR0002
	Else
	// se tipo relatório for sintético
		cTitulo := /*"Operacional de Pedidos"*/ STR0001 + " - " + /*" Sintético"*/ STR0003
	EndIf
	
	oReport := TReport():New("OGR710", @cTitulo, cPergunta, {| oReport | PrintReport( oReport ) }, @cTitulo, .T.)

	oReport:oPage:SetPageNumber(1)
	oReport:lBold 		   := .F.
	oReport:lUnderLine     := .F.
	oReport:lHeaderVisible := .T.
	oReport:lFooterVisible := .T.
	oReport:lParamPage     := .F.
	
Return (oReport)

/*/{Protheus.doc} PrintReport
//Função impressão do relatório
@author marina.muller
@since 25/09/2018
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, descricao
@type function
/*/
Static Function PrintReport(oReport)
	Local aAreaAtu	:= GetArea()
	Local cWhere    := " 1 = 1 "
	  
	If oReport:Cancel()
		Return( Nil )
	EndIf

	// se tipo relatório for analítico
	If MV_PAR10 = 1
		oReport:SetPortrait()
		oReport:SetTitle(/*"Operacional de Pedidos"*/ STR0001 + " - " + /*" Analítico"*/ STR0002)
		OGR710RELA(oReport)
	Else
	// se tipo relatório for sintético
		oReport:SetLandscape()
		oReport:SetTitle(/*"Operacional de Pedidos"*/ STR0001 + " - " + /*" Sintético"*/ STR0003)
		OGR710RELS(oReport)
	EndIf
	
	If !Empty(MV_PAR01) //safra
	   cWhere += " AND NJR.NJR_CODSAF = '" + MV_PAR01 + "'"
	EndIf   

	If !Empty(MV_PAR02) //contrato de
	   cWhere += " AND N9A.N9A_CODCTR >= '" + MV_PAR02 + "'"
	EndIf   

	If !Empty(MV_PAR03) //contrato até
	   cWhere += " AND N9A.N9A_CODCTR <= '" + MV_PAR03 + "'"
	EndIf   

	If !Empty(MV_PAR04) //entidade de
	   cWhere  += " AND N9A.N9A_CODENT >= '" + MV_PAR04 + "'"
	EndIf   

	If !Empty(MV_PAR05) //loja de
	   cWhere  += " AND N9A.N9A_LOJENT >= '" + MV_PAR05 + "'"
	EndIf   

	If !Empty(MV_PAR06) //entidade até
	   cWhere  += " AND N9A.N9A_CODENT <= '" + MV_PAR06 + "'"
	EndIf   

	If !Empty(MV_PAR07) //loja até
	   cWhere  += " AND N9A.N9A_LOJENT <= '" + MV_PAR07 + "'"
	EndIf   

	If !Empty(MV_PAR08) //regras fiscais de
	   cWhere += " AND N9A.N9A_SEQPRI >= '" + MV_PAR08 + "'"
	EndIf   

	If !Empty(MV_PAR09) //regras fiscais até
	   cWhere += " AND N9A.N9A_SEQPRI <= '" + MV_PAR09 + "'"
	EndIf   
	
	cWhere := "%"+cWhere+"%"
	
	// se tipo relatório for analítico
	If MV_PAR10 = 1
		OGR710ANAL(cWhere, oReport)
	Else
	// se tipo relatório for sintético
		OGR710SINT(cWhere, oReport)
	EndIf

	RestArea(aAreaAtu)		
Return .T.

/*/{Protheus.doc} OGR710RELA
//Layout do relatório analítico
@author marina.muller
@since 25/09/2018
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, descricao
@type function
/*/
Static Function OGR710RELA(oReport)
	Local oSection1		:= Nil
	Local oSection2		:= Nil
	Local oSection3		:= Nil
	Local oSection4		:= Nil
	Local oSection5		:= Nil

	//Seção 1 - Cabeçalho
	oSection1 := TRSection():New( oReport, "", {"N9A"} ) 
	oSection1:lLineStyle := .T. 
	TRCell():New( oSection1, "PRODUTO",         ,/*"Produto"*/ STR0004,      "@!", 45, .T., /*Block*/, , , "LEFT", .T.)
	TRCell():New( oSection1, "UNIDADE",         ,/*"Unidade"*/ STR0005,      "@!", 45, .T., /*Block*/, , , "LEFT", .T.)
	TRCell():New( oSection1, "CLIENTE",         ,/*"Cliente"*/ STR0006,      "@!", 45, .T., /*Block*/, , , "LEFT", .T.)
	TRCell():New( oSection1, "N9A_SEQPRI", "N9A",/*"Regra Fiscal"*/ STR0007, "@!", 45, .T., /*Block*/, , , "LEFT", .T.)
	
	//Seção 2 - Listagem faturamento
	oSection2 := TRSection():New( oReport, "", {"NJM"})
	oSection2:lLineStyle := .F.
	oSection2:lAutoSize  := .T.
	TRCell():New( oSection2, "NJM_DOCNUM", "NJM", /*"NF"*/ STR0008)
	TRCell():New( oSection2, "NJM_DTRANS", "NJM", /*"Data NF"*/ STR0010) 
	TRCell():New( oSection2, "NJM_QTDFIS", "NJM", /*"Peso"*/ STR0012,              PesqPict('NJM',"NJM_QTDFIS"))
	TRCell():New( oSection2, "NJM_TIPO" ,  "NJM", /*"Transação"*/ STR0013,         "@!", 15, .T.,{|| getTipo(NJM_TIPO)}, , , "LEFT", .T. )
	TRCell():New( oSection2, "NJM_VLRTOT", "NJM", /*"Valor NF"*/ STR0014,          PesqPict('NJM',"NJM_VLRTOT"))
	TRCell():New( oSection2, "VLAPLIC",         , /*"Valor Aplicado"*/ STR0015,    PesqPict('NJM',"NJM_VLRTOT"))
	TRCell():New( oSection2, "TOTIMPOST",       , /*"Total de Impostos"*/ STR0016, PesqPict('NJM',"NJM_VLRTOT"))

	//Seção 3 - Listagem remessa
	oSection3 := TRSection():New( oReport, "", {"NJM"})
	oSection3:lLineStyle := .F.
	oSection3:lAutoSize  := .T.
	TRCell():New( oSection3, "NJM_DOCNUM", "NJM", /*"NF"*/ STR0008)
	TRCell():New( oSection3, "NJM_DTRANS", "NJM", /*"Data NF"*/ STR0010) 
	TRCell():New( oSection3, "NJM_QTDFIS", "NJM", /*"Peso"*/ STR0012,              PesqPict('NJM',"NJM_QTDFIS"))
	TRCell():New( oSection3, "NJM_TIPO",   "NJM", /*"Transação"*/ STR0013,         "@!", 15, .T.,{|| getTipo(NJM_TIPO)}, , , "LEFT", .T. )
	TRCell():New( oSection3, "NJM_VLRTOT", "NJM", /*"Valor NF"*/ STR0014,          PesqPict('NJM',"NJM_VLRTOT"))
	TRCell():New( oSection3, "VLAPLIC",         , /*"Valor Aplicado"*/ STR0015,    PesqPict('NJM',"NJM_VLRTOT"))
	TRCell():New( oSection3, "TOTIMPOST",       , /*"Total de Impostos"*/ STR0016, PesqPict('NJM',"NJM_VLRTOT"))

	//Seção 4 - Listagem devolução
	oSection4 := TRSection():New( oReport, "", {"NJM"}) 
	oSection4:lLineStyle := .F.
	oSection4:lAutoSize  := .T.
	TRCell():New( oSection4, "NJM_DOCNUM", "NJM", /*"NF"*/ STR0008)
	TRCell():New( oSection4, "NJM_DTRANS", "NJM", /*"Data NF"*/ STR0010) 
	TRCell():New( oSection4, "NJM_QTDFIS", "NJM", /*"Peso"*/ STR0012,              PesqPict('NJM',"NJM_QTDFIS"))
	TRCell():New( oSection4, "NJM_TIPO",   "NJM", /*"Transação"*/ STR0013,         "@!", 15, .T.,{|| getTipo(NJM_TIPO)}, , , "LEFT", .T. )
	TRCell():New( oSection4, "NJM_VLRTOT", "NJM", /*"Valor NF"*/ STR0014,          PesqPict('NJM',"NJM_VLRTOT"))
	TRCell():New( oSection4, "VLAPLIC",         , /*"Valor Aplicado"*/ STR0015,    PesqPict('NJM',"NJM_VLRTOT"))
	TRCell():New( oSection4, "TOTIMPOST",       , /*"Total de Impostos"*/ STR0016, PesqPict('NJM',"NJM_VLRTOT"))

	//Seção 5 - Totalização por quebra
	oSection5 := TRSection():New(oReport, "", {"NJM"})
	oBreak1 := TRBreak():New( oSection5, "", /*"Total Faturamento"*/ STR0017, .F. )
	TRFunction():New(oSection2:aCell[3], Nil, "SUM", oBreak1, /*"Peso Total"*/,   , , .F., .F., )	
	TRFunction():New(oSection2:aCell[5], Nil, "SUM", oBreak1, /*"Vl NF Total"*/,  , , .F., .F., )
	TRFunction():New(oSection2:aCell[6], Nil, "SUM", oBreak1, /*"Vl Aplicado"*/,  , , .F., .F., )
	TRFunction():New(oSection2:aCell[7], Nil, "SUM", oBreak1, /*"Tot Impostos"*/, , , .F., .F., )

	oBreak2 := TRBreak():New( oSection5, "", /*"Total Remessa"*/ STR0018, .F. )
	TRFunction():New(oSection3:aCell[3], Nil, "SUM", oBreak2, /*"Peso Total"*/,   , , .F., .F., )	
	TRFunction():New(oSection3:aCell[5], Nil, "SUM", oBreak2, /*"Vl NF Total"*/,  , , .F., .F., )
	TRFunction():New(oSection3:aCell[6], Nil, "SUM", oBreak2, /*"Vl Aplicado"*/,  , , .F., .F., )
	TRFunction():New(oSection3:aCell[7], Nil, "SUM", oBreak2, /*"Tot Impostos"*/, , , .F., .F., )

	oBreak3 := TRBreak():New( oSection5, "", /*"Total Devolução"*/ STR0019, .F. )
	TRFunction():New(oSection4:aCell[3], Nil, "SUM", oBreak3, /*"Peso Total"*/,   , , .F., .F., )	
	TRFunction():New(oSection4:aCell[5], Nil, "SUM", oBreak3, /*"Vl NF Total"*/,  , , .F., .F., )
	TRFunction():New(oSection4:aCell[6], Nil, "SUM", oBreak3, /*"Vl Aplicado"*/,  , , .F., .F., )
	TRFunction():New(oSection4:aCell[7], Nil, "SUM", oBreak3, /*"Tot Impostos"*/, , , .F., .F., )

Return .T.

/*/{Protheus.doc} OGR710ANAL
//Função montagem do relatório analítico
@author marina.muller
@since 25/09/2018
@version 1.0
@return ${return}, ${return_description}
@param cWhere, characters, descricao
@param oReport, object, descricao
@type function
/*/
Static Function OGR710ANAL(cWhere, oReport) 
	Local oS1		:= oReport:Section(1)
	Local oS2		:= oReport:Section(2)
	Local oS3		:= oReport:Section(3)
	Local oS4		:= oReport:Section(4)
	Local oS5		:= oReport:Section(5)
	Local lPulaLin  := .F.
	Local cImpNfEnt := 0
	Local cImpNfSai := 0
	
	oS1:BeginQuery()
	oS1:Init()
	BeginSql Alias "QryN9A"
	   SELECT DISTINCT N9A.N9A_FILORG, N9A.N9A_SEQPRI, N9A.N9A_CODENT, N9A.N9A_LOJENT, NJM.NJM_CODPRO 
		 FROM %Table:N9A% N9A
	    INNER JOIN %Table:NJR% NJR
		   ON NJR.NJR_FILIAL = N9A.N9A_FILIAL
		  AND NJR.NJR_CODCTR = N9A.N9A_CODCTR
		INNER JOIN %Table:NJM% NJM       
   		   ON NJM.NJM_FILIAL = N9A.N9A_FILORG      
		  AND NJM.NJM_CODCTR = N9A.N9A_CODCTR   
		  AND NJM.NJM_CODENT = N9A.N9A_CODENT
		  AND NJM.NJM_LOJENT = N9A.N9A_LOJENT  
		  AND NJM.NJM_SEQPRI = N9A.N9A_SEQPRI
		WHERE N9A.%NotDel% 
		  AND NJR.%NotDel%
		  AND NJM.%NotDel%
		  AND NJM.NJM_DOCNUM <> ' '
		  AND NJM.NJM_TIPO IN ('2','4','6','8')
		  AND %exp:cWhere%
		ORDER BY NJM.NJM_CODPRO, N9A.N9A_CODENT, N9A.N9A_LOJENT, N9A.N9A_SEQPRI   
	EndSql
	oS1:EndQuery()
	
	If .Not. QryN9A->(Eof())
	
		QryN9A->(dbGoTop())
		
		While .Not. QryN9A->(Eof())
			oS1:Init()
			
			//atribui valor cabeçalho
			oS1:aCell[1]:SetValue(getProduto(QryN9A->NJM_CODPRO))
			oS1:aCell[2]:SetValue(getUnidade(QryN9A->N9A_FILORG))
			oS1:aCell[3]:SetValue(getCliente(QryN9A->N9A_CODENT, QryN9A->N9A_LOJENT))
			
			//imprime cabeçalho
			oS1:PrintLine()
			
			//-------------------------------//
			// INICIO - LISTAGEM FATURAMENTO // 	
			//-------------------------------//
			
			oS2:BeginQuery()
			oS2:Init()
			BeginSql Alias "QryNJMFAT"
			  SELECT NJM.*, SF2.*
				FROM %Table:NJM% NJM
				INNER JOIN %Table:SF2% SF2
				   ON SF2.F2_FILIAL = NJM.NJM_FILIAL
				  AND SF2.F2_DOC    = NJM.NJM_DOCNUM
				  AND SF2.F2_SERIE  = NJM.NJM_DOCSER
				  AND NJM.%NotDel%
				  AND SF2.%NotDel%
			   WHERE NJM.NJM_FILIAL = %exp:QryN9A->N9A_FILORG%	
				 AND NJM.NJM_CODENT = %exp:QryN9A->N9A_CODENT%
				 AND NJM.NJM_LOJENT = %exp:QryN9A->N9A_LOJENT%
				 AND NJM.NJM_CODPRO = %exp:QryN9A->NJM_CODPRO%
				 AND NJM.NJM_SEQPRI = %exp:QryN9A->N9A_SEQPRI%
				 AND NJM.NJM_DOCNUM <> ' '
				 AND NJM.NJM_TIPO IN ('4', '6', '8') //(S) SAIDA POR VENDA //(S) DEVOLUCAO DE DEPOSITO //(S) DEVOLUCAO DE COMPRA
			EndSQL
			oS2:EndQuery()
			
			If .Not. QryNJMFAT->(Eof())
				QryNJMFAT->(dbGoTop())
				
				
				oReport:SkipLine(2)
				oS2:Init()
				oReport:PrintText(/*"FATURAMENTO"*/ STR0035)
				
				While .Not. QryNJMFAT->(Eof())	
					cImpNfSai := QryNJMFAT->F2_VALICM  +; //Vlr.ICMS    
					             QryNJMFAT->F2_VALIPI  +; //Vlr.IPI     
					             QryNJMFAT->F2_ICMSRET +; //ICMS Retido 
					             QryNJMFAT->F2_VALISS  +; //Valor ISS   
					             QryNJMFAT->F2_VALIMP1 +; //Valor Imp. 1
					             QryNJMFAT->F2_VALIMP2 +; //Valor Imp. 2
					             QryNJMFAT->F2_VALIMP3 +; //Valor Imp. 3
					             QryNJMFAT->F2_VALIMP4 +; //Valor Imp. 4
					             QryNJMFAT->F2_VALIMP5 +; //Valor Imp. 5
					             QryNJMFAT->F2_VALIMP6 +; //Valor Imp. 6
					             QryNJMFAT->F2_VALCSLL +; //Valor CSLL  
					             QryNJMFAT->F2_VALCOFI +; //Valor COFINS
					             QryNJMFAT->F2_VALPIS  +; //Valor PIS   
					             QryNJMFAT->F2_VALIRRF +; //Valor IRRF  
					             QryNJMFAT->F2_ICMSDIF +; //Icms. Dif.  
					             QryNJMFAT->F2_VALPS3  +; //Vl. Pis ST  
					             QryNJMFAT->F2_VALCF3     //Vl. COF ST  
					
					//atribui valor coluna total impostos
					oS2:aCell[7]:SetValue(cImpNfSai)
					
					//valor aplicado
					oS2:aCell[6]:SetValue(0)
					             
					//imprime listagem faturamento
					oS2:PrintLine()
					
					QryNJMFAT->( dbSkip() )
					
					cImpNfSai := 0
				EndDo
				QryNJMFAT->( dbCloseArea() )
				
				oS2:Finish()
				
				lPulaLin := .T.
			EndIf	

			//-------------------------------//
			// FINAL - LISTAGEM FATURAMENTO  // 	
			//-------------------------------//
			
			//---------------------------//
			// INICIO - LISTAGEM REMESSA // 	
			//---------------------------//
			
			oS3:BeginQuery()
			oS3:Init()
			BeginSql Alias "QryNJMREM"
			  SELECT NJM.*, SF2.*
				FROM %Table:NJM% NJM
				INNER JOIN %Table:SF2% SF2
				   ON SF2.F2_FILIAL = NJM.NJM_FILIAL
				  AND SF2.F2_DOC    = NJM.NJM_DOCNUM
				  AND SF2.F2_SERIE  = NJM.NJM_DOCSER
				  AND NJM.%NotDel%
				  AND SF2.%NotDel%
			   WHERE NJM.NJM_FILIAL = %exp:QryN9A->N9A_FILORG%	
				 AND NJM.NJM_CODENT = %exp:QryN9A->N9A_CODENT%
				 AND NJM.NJM_LOJENT = %exp:QryN9A->N9A_LOJENT%
				 AND NJM.NJM_CODPRO = %exp:QryN9A->NJM_CODPRO%
				 AND NJM.NJM_SEQPRI = %exp:QryN9A->N9A_SEQPRI%
				 AND NJM.NJM_DOCNUM <> ' '
				 AND NJM.NJM_TIPO   =  '2' //(S) REMESSA PARA DEPOSITO
			EndSQL
			oS3:EndQuery()
			
			If .Not. QryNJMREM->(Eof())
				QryNJMREM->(dbGoTop())

				If lPulaLin
				   oReport:SkipLine(2)
				   lPulaLin := .F.
				EndIf  
				
				oS3:Init()
				oReport:PrintText(/*"REMESSA"*/ STR0036)
				
				While .Not. QryNJMREM->(Eof())
					cImpNfSai := QryNJMREM->F2_VALICM  +; //Vlr.ICMS    
					             QryNJMREM->F2_VALIPI  +; //Vlr.IPI     
					             QryNJMREM->F2_ICMSRET +; //ICMS Retido 
					             QryNJMREM->F2_VALISS  +; //Valor ISS   
					             QryNJMREM->F2_VALIMP1 +; //Valor Imp. 1
					             QryNJMREM->F2_VALIMP2 +; //Valor Imp. 2
					             QryNJMREM->F2_VALIMP3 +; //Valor Imp. 3
					             QryNJMREM->F2_VALIMP4 +; //Valor Imp. 4
					             QryNJMREM->F2_VALIMP5 +; //Valor Imp. 5
					             QryNJMREM->F2_VALIMP6 +; //Valor Imp. 6
					             QryNJMREM->F2_VALCSLL +; //Valor CSLL  
					             QryNJMREM->F2_VALCOFI +; //Valor COFINS
					             QryNJMREM->F2_VALPIS  +; //Valor PIS   
					             QryNJMREM->F2_VALIRRF +; //Valor IRRF  
					             QryNJMREM->F2_ICMSDIF +; //Icms. Dif.  
					             QryNJMREM->F2_VALPS3  +; //Vl. Pis ST  
					             QryNJMREM->F2_VALCF3     //Vl. COF ST  
					
					//atribui valor coluna total impostos
					oS3:aCell[7]:SetValue(cImpNfSai)
					
					//valor aplicado
					oS3:aCell[6]:SetValue(0)

					//imprime listagem remessa
					oS3:PrintLine()
					
					QryNJMREM->( dbSkip() )
					
					cImpNfSai := 0
				EndDo
				QryNJMREM->( dbCloseArea() )
				
				oS3:Finish()
				
				lPulaLin := .T.
			EndIf	

			//---------------------------//
			// FINAL - LISTAGEM REMESSA  // 	
			//---------------------------//

			//-----------------------------//
			// INICIO - LISTAGEM DEVOLUÇÃO // 	
			//-----------------------------//
			
			oS4:BeginQuery()
			oS4:Init()
			BeginSql Alias "QryNJMDEV"
			  SELECT NJM.*, SF1.*
				FROM %Table:NJM% NJM
				INNER JOIN %Table:SF1% SF1
				   ON SF1.F1_FILIAL = NJM.NJM_FILIAL
				  AND SF1.F1_DOC    = NJM.NJM_DOCNUM
				  AND SF1.F1_SERIE  = NJM.NJM_DOCSER
				  AND NJM.%NotDel%
				  AND SF1.%NotDel%
			   WHERE NJM.NJM_FILIAL = %exp:QryN9A->N9A_FILORG%	
				 AND NJM.NJM_CODENT = %exp:QryN9A->N9A_CODENT%
				 AND NJM.NJM_LOJENT = %exp:QryN9A->N9A_LOJENT%
				 AND NJM.NJM_CODPRO = %exp:QryN9A->NJM_CODPRO%
				 AND NJM.NJM_SEQPRI = %exp:QryN9A->N9A_SEQPRI%
				 AND NJM.NJM_DOCNUM <> ' '
				 AND NJM.NJM_TIPO   IN ('7', '9') //(E) DEVOLUCAO DE REMESSA //(E) DEVOLUCAO DE VENDA
			EndSQL
			oS4:EndQuery()
			
			If .Not. QryNJMDEV->(Eof())
				QryNJMDEV->(dbGoTop())

				If lPulaLin
				   oReport:SkipLine(2)
				   lPulaLin := .F.
				EndIf  
				
				oS4:Init()
				oReport:PrintText(/*"DEVOLUÇÃO"*/ STR0037)
				
				While .Not. QryNJMDEV->(Eof())
					cImpNfEnt := QryNJMDEV->F1_VALICM  +; //Vlr.ICMS    
					             QryNJMDEV->F1_VALIPI  +; //Vlr.IPI     
					             QryNJMDEV->F1_ICMSRET +; //ICMS Retido 
					             QryNJMDEV->F1_ISS     +; //Valor ISS   
					             QryNJMDEV->F1_VALIMP1 +; //Valor Imp. 1
					             QryNJMDEV->F1_VALIMP2 +; //Valor Imp. 2
					             QryNJMDEV->F1_VALIMP3 +; //Valor Imp. 3
					             QryNJMDEV->F1_VALIMP4 +; //Valor Imp. 4
					             QryNJMDEV->F1_VALIMP5 +; //Valor Imp. 5
					             QryNJMDEV->F1_VALIMP6 +; //Valor Imp. 6
					             QryNJMDEV->F1_VALCSLL +; //Valor CSLL
					             QryNJMDEV->F1_ICMS    +; //ICMS             
					             QryNJMDEV->F1_VALCOFI +; //Valor COFINS
					             QryNJMDEV->F1_VALPIS  +; //Valor PIS   
					             QryNJMDEV->F1_VALPS3  +; //Vl. Pis ST  
					             QryNJMDEV->F1_VALCF3     //Vl. COF ST  
					
					//atribui valor coluna total impostos
					oS4:aCell[7]:SetValue(cImpNfEnt)
					
					//valor aplicado
					oS4:aCell[6]:SetValue(0)

					//imprime listagem devolução
					oS4:PrintLine()
					
					QryNJMDEV->( dbSkip() )
					
					cImpNfEnt := 0
				EndDo
				QryNJMDEV->( dbCloseArea() )
				
				oS4:Finish()
			EndIf	

			//-----------------------------//
			// FINAL - LISTAGEM DEVOLUÇÃO  // 	
			//-----------------------------//

			//imprime totalizadores por quebra
			oS5:Init()
			oS5:PrintLine()
			oS5:Finish()

			oS1:Finish()
			
			QryN9A->(dbSkip())
			
			If .Not. QryN9A->(Eof())
				oReport:EndPage()
			EndIf
		EndDo
		QryN9A->( dbCloseArea() )
	EndIf

Return .T.

/*/{Protheus.doc} OGR710RELS
//Layout do relatório sintético
@author marina.muller
@since 25/09/2018
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, descricao
@type function
/*/
Static Function OGR710RELS(oReport)
	Local oSection1		:= Nil
	Local oSection2		:= Nil
	Local oSection3		:= Nil
	
	//Seção 1 - Cabeçalho
	oSection1 := TRSection():New( oReport, "", {"N9A"} ) 
	oSection1:lLineStyle := .T. 
	TRCell():New( oSection1, "PRODUTO", ,/*"Produto"*/ STR0004, "@!", 45, .T., /*Block*/, , , "LEFT", .T.)
	TRCell():New( oSection1, "UNIDADE", ,/*"Unidade"*/ STR0005, "@!", 45, .T., /*Block*/, , , "LEFT", .T.)

	//Seção 2 - Listagem dados
	oSection2 := TRSection():New( oReport, "", {"NJM", "N9A"})
	oSection2:lLineStyle := .F.
	oSection2:lAutoSize  := .T.
	TRCell():New( oSection2, "N9A_SEQPRI",      , /*"Regra Fiscal"*/ STR0007,        PesqPict('N9A',"N9A_SEQPRI"))
	TRCell():New( oSection2, "N9A_QUANT",  "N9A", /*"Peso Total"*/ STR0020,       	 PesqPict('N9A',"N9A_QUANT"))
	TRCell():New( oSection2, "NJM_QTDFIS", "NJM", /*"Peso Faturado"*/ STR0021,    	 PesqPict('NJM',"NJM_QTDFIS"))
	TRCell():New( oSection2, "BONI",            , /*"Bonificação"*/ STR0022,      	 PesqPict('NJM',"NJM_VLRTOT"))
	TRCell():New( oSection2, "DEVO",            , /*"Devolução"*/ STR0023,        	 PesqPict('NJM',"NJM_VLRTOT"))
	TRCell():New( oSection2, "N9A_SDOINS", "N9A", /*"Saldo à Embarcar"*/ STR0024,    PesqPict('N9A',"N9A_SDOINS"))
	TRCell():New( oSection2, "NJM_VLRUNI", "NJM", /*"Preço Unitário"*/ STR0025,      PesqPict('NJM',"NJM_VLRUNI"))
	TRCell():New( oSection2, "NJM_UM1PRO", "NJM", /*"UDM"*/ STR0026,                 PesqPict('NJM',"NJM_UM1PRO"))
	TRCell():New( oSection2, "N9A_VLTFPR", "N9A", /*"Vl Total"*/ STR0027,            PesqPict('N9A',"N9A_VLTFPR"))
	TRCell():New( oSection2, "NJM_VLRTOT", "NJM", /*"Vl Faturado"*/ STR0028,         PesqPict('NJM',"NJM_VLRTOT"))
	TRCell():New( oSection2, "DIFVLRTOT",       , /*"Dif Vl Tot e Fat"*/ STR0029,    PesqPict('NJM',"NJM_VLRTOT"))
	TRCell():New( oSection2, "VLRPG",           , /*"Vl Pago"*/ STR0030,             PesqPict('NJM',"NJM_VLRTOT"))
	TRCell():New( oSection2, "VLRREC",          , /*"Vl a Receber"*/ STR0031,        PesqPict('NJM',"NJM_VLRTOT"))
	TRCell():New( oSection2, "DIFFAPA",         , /*"Dif Vl Fat e Pago"*/ STR0032,   PesqPict('NJM',"NJM_VLRTOT"))
	TRCell():New( oSection2, "DIFREPA",         , /*"Dif Vl a Rec e Pago"*/ STR0033, PesqPict('NJM',"NJM_VLRTOT"))

	//Seção 3 - Totalização por quebra
	oSection3 := TRSection():New(oReport, "", {"NJM"}) 
	oBreak1 := TRBreak():New( oSection3, "", /*"Total Unidade"*/ STR0034, .F. )
	TRFunction():New(oSection2:aCell[2],  Nil, "SUM", oBreak1, /*"Peso Total"*/,          , , .F., .F., )	
	TRFunction():New(oSection2:aCell[3],  Nil, "SUM", oBreak1, /*"Peso Faturado"*/,       , , .F., .F., )
	TRFunction():New(oSection2:aCell[4],  Nil, "SUM", oBreak1, /*"Bonificação"*/,         , , .F., .F., )
	TRFunction():New(oSection2:aCell[5],  Nil, "SUM", oBreak1, /*"Devolução"*/,           , , .F., .F., )
	TRFunction():New(oSection2:aCell[6],  Nil, "SUM", oBreak1, /*"Saldo à Embarcar"*/ ,   , , .F., .F., )
	TRFunction():New(oSection2:aCell[9],  Nil, "SUM", oBreak1, /*"Vl Total"*/,            , , .F., .F., )
	TRFunction():New(oSection2:aCell[10], Nil, "SUM", oBreak1, /*"Vl Faturado"*/,         , , .F., .F., )
	TRFunction():New(oSection2:aCell[11], Nil, "SUM", oBreak1, /*"Dif Vl Tot e Fat"*/,    , , .F., .F., )
	TRFunction():New(oSection2:aCell[12], Nil, "SUM", oBreak1, /*"Vl Pago"*/,             , , .F., .F., )
	TRFunction():New(oSection2:aCell[13], Nil, "SUM", oBreak1, /*"Vl a Receber"*/,        , , .F., .F., )
	TRFunction():New(oSection2:aCell[14], Nil, "SUM", oBreak1, /*"Dif Vl Fat e Pago"*/ ,  , , .F., .F., )
	TRFunction():New(oSection2:aCell[15], Nil, "SUM", oBreak1, /*"Dif Vl a Rec e Pago"*/, , , .F., .F., )
	
Return .T.

/*/{Protheus.doc} OGR710SINT
//Função montagem do relatório sintético
@author marina.muller
@since 25/09/2018
@version 1.0
@return ${return}, ${return_description}
@param cWhere, characters, descricao
@param oReport, object, descricao
@type function
/*/
Static Function OGR710SINT(cWhere, oReport)
	Local oS1		:= oReport:Section(1)
	Local oS2		:= oReport:Section(2)
	Local oS3		:= oReport:Section(3)
	Local cEntidade := ""
	Local cProduto  := ""
 
	oS1:BeginQuery()
	oS1:Init()
	BeginSql Alias "QryN9A"
	   SELECT N9A.N9A_FILORG, N9A.N9A_SEQPRI, NJM.NJM_CODPRO, 
	   		  N9A.N9A_CODENT, N9A.N9A_LOJENT, NJM.NJM_UM1PRO,
			  SUM(NJM_QTDFIS) AS PESOFAT, 
	          SUM(NJM_VLRUNI) AS PESOUNI,
	          SUM(NJM_VLRTOT) AS VLRFAT,
	          SUM(N9A.N9A_VLTFPR) AS VLRTOT,  
	          SUM(N9A.N9A_QUANT)  AS PESOTOT,
	          SUM(N9A.N9A_SDOINS) AS SLDEMB,
	          SUM(NN7.NN7_VLRAVI) AS VLPAGO,
	          SUM(NN7.NN7_VALOR)  AS VLRECB     	     	
		 FROM %Table:N9A% N9A
	    INNER JOIN %Table:NJR% NJR
		   ON NJR.NJR_FILIAL = N9A.N9A_FILIAL
		  AND NJR.NJR_CODCTR = N9A.N9A_CODCTR
		INNER JOIN %Table:NJM% NJM       
   		   ON NJM.NJM_FILIAL = N9A.N9A_FILORG      
		  AND NJM.NJM_CODCTR = N9A.N9A_CODCTR   
		  AND NJM.NJM_CODENT = N9A.N9A_CODENT
		  AND NJM.NJM_LOJENT = N9A.N9A_LOJENT  
	     LEFT OUTER JOIN %Table:NN7% NN7
		   ON NN7.NN7_FILORG = N9A.N9A_FILORG
		  AND NN7.NN7_CODCTR = N9A.N9A_CODCTR 
		  AND NN7.NN7_ITEM   = N9A.N9A_ITEM		  
		WHERE N9A.%NotDel% 
		  AND NJR.%NotDel%
		  AND NJM.%NotDel%
		  AND NN7.%NotDel%
		  AND NJM.NJM_DOCNUM <> ' '
		  AND NJM.NJM_TIPO IN ('2','4','6','8')
		  AND %exp:cWhere%
		GROUP BY N9A.N9A_FILORG, N9A.N9A_SEQPRI, NJM.NJM_CODPRO, N9A.N9A_CODENT, N9A.N9A_LOJENT, NJM.NJM_UM1PRO  
	    ORDER BY NJM.NJM_CODPRO, N9A.N9A_CODENT, N9A.N9A_LOJENT, N9A.N9A_SEQPRI      
	EndSql
	oS1:EndQuery()
	
	If .Not. QryN9A->(Eof())
		QryN9A->(dbGoTop())

	    cProduto  := QryN9A->NJM_CODPRO
	    cEntidade := ""

		//atribui valor cabeçalho
		oS1:Init()
		oS1:aCell[1]:SetValue(getProduto(QryN9A->NJM_CODPRO))
		oS1:aCell[2]:SetValue(getUnidade(QryN9A->N9A_FILORG))

		//imprime cabeçalho
		oS1:PrintLine()

		While .Not. QryN9A->(Eof())
			If QryN9A->NJM_CODPRO <> cProduto
			    cProduto  := QryN9A->NJM_CODPRO
			    cEntidade := ""
			    	
				//imprime totalizadores por quebra
				oS3:Init()
				oS3:PrintLine()
				oS3:Finish()
				
				oS1:Finish()
				
				oReport:EndPage()

				//atribui valor cabeçalho
				oS1:Init()
				oS1:aCell[1]:SetValue(getProduto(QryN9A->NJM_CODPRO))
				oS1:aCell[2]:SetValue(getUnidade(QryN9A->N9A_FILORG))
				
				//imprime cabeçalho
				oS1:PrintLine()
			EndIf
			
			If QryN9A->N9A_CODENT <> cEntidade
				cEntidade := QryN9A->N9A_CODENT
				
				oS2:Finish()
				oReport:SkipLine(3)
				oS2:Init()
				oReport:PrintText(STR0006 + ": " /*"Cliente: "*/ + getCliente(QryN9A->N9A_CODENT, QryN9A->N9A_LOJENT))
				oReport:SkipLine(1)
				oReport:PrintText("               " + "------------------------------- VOLUMES (Kg) -----------------------------  " + "-------------------------------- FATURAMENTO (R$)----------------------------------  " + "-----------------------------FINANCEIRO (R$) -------------------------",/*nRow*/,/*nCol*/,CLR_BLUE)
			EndIf
				
			oS2:aCell[1]:SetValue(QryN9A->N9A_SEQPRI)
			oS2:aCell[2]:SetValue(QryN9A->PESOTOT)
			oS2:aCell[3]:SetValue(QryN9A->PESOFAT)
			oS2:aCell[4]:SetValue(0)
			oS2:aCell[5]:SetValue(0)
			oS2:aCell[6]:SetValue(QryN9A->SLDEMB)
			oS2:aCell[7]:SetValue(QryN9A->PESOUNI)
			oS2:aCell[9]:SetValue(QryN9A->VLRTOT)
			oS2:aCell[10]:SetValue(QryN9A->VLRFAT)
			oS2:aCell[11]:SetValue(QryN9A->VLRTOT - QryN9A->VLRFAT)
			oS2:aCell[12]:SetValue(QryN9A->VLPAGO)
			oS2:aCell[13]:SetValue(QryN9A->VLRECB)
			oS2:aCell[14]:SetValue(QryN9A->VLRFAT-QryN9A->VLPAGO)
			oS2:aCell[15]:SetValue(QryN9A->VLRECB-QryN9A->VLPAGO)
			
			//imprime listagem volumes
			oS2:PrintLine()
					
			//oS2:Finish()

			QryN9A->(dbSkip())
		EndDo
		QryN9A->( dbCloseArea() )

		//imprime totalizadores por quebra
		oS3:Init()
		oS3:PrintLine()
		oS3:Finish()
		
		oS2:Finish()
		oS1:Finish()
	EndIf
	
Return .T.

/*/{Protheus.doc} getTipo
//Função busca descrição do tipo romaneio
@author marina.muller
@since 25/09/2018
@version 1.0
@return ${return}, ${return_description}
@param cTipo, characters, descricao
@type function
/*/
Static Function getTipo(cTipo)
	Local cRet := ""
	
	If !Empty(cTipo)
		cRet := Posicione("SX5",1,FWxFilial("SX5")+'K5'+cTipo,"X5_DESCRI")
	EndIf	
	
Return cRet

/*/{Protheus.doc} getProduto
//Função busca descção do produto
@author marina.muller
@since 25/09/2018
@version 1.0
@return ${return}, ${return_description}
@param cProduto, characters, descricao
@type function
/*/
Static Function getProduto(cProduto)
	Local cRet := ""
	
	If !Empty(cProduto)
		cRet := AllTrim(cProduto) + " - " + Posicione("SB1",1,FWxFilial("SB1")+cProduto,"B1_DESC")
	EndIf	
	
Return cRet

/*/{Protheus.doc} getCliente
//Função busca descrição do cliente
@author marina.muller
@since 25/09/2018
@version 1.0
@return ${return}, ${return_description}
@param cEntidade, characters, descricao
@param cLoja, characters, descricao
@type function
/*/
Static Function getCliente(cEntidade, cLoja)
	Local cRet     := ""
	Local cCliente := ""
	Local cLojCli    := ""
	
	If !Empty(cEntidade)
		cCliente := Posicione("NJ0",1,FWxFilial("NJ0")+cEntidade+cLoja,"NJ0_CODCLI")
		cLojCli  := Posicione("NJ0",1,FWxFilial("NJ0")+cEntidade+cLoja,"NJ0_LOJCLI")
		cRet     := cCliente + "/" + cLojCli + " - " + Posicione("SA1",1,FWxFilial("SA1")+cCliente+cLojCli,"A1_NOME")
	EndIf	
	
Return cRet

/*/{Protheus.doc} getUnidade
//Função busca descrição da filial do contrato
@author marina.muller
@since 25/09/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilCont, characters, descricao
@type function
/*/
Static Function getUnidade(cFilCont)
	Local cRet := ""
	
	If !Empty(cFilCont)
		cRet := AllTrim(cFilCont) + " - " + FWFilialName(,cFilCont,2)
	EndIf	
	
Return cRet
