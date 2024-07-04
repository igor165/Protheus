#include "protheus.ch"
#include "report.ch"
#include "AGRAR750.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRAR750
Função de relatorio de Romaneio de saida
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------

Function AGRAR750()
	Local oReport

	If FindFunction("TRepInUse") .And. TRepInUse()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Interface de impressão                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:= ReportDef("REPORT")
		oReport:PrintDialog()	
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Função de definição do layout e formato do relatório

@return oReport	Objeto criado com o formato do relatório
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------

Static Function ReportDef()
	Local oReport	:= NIL
	Local oSection1	:= NIL
	Local oSection2	:= NIL
	Local oSection3	:= NIL
	Local oBreak1	:= NIL
	Local oFunc1	:= NIL
	Local oFunc2	:= NIL

	Static cAliasRel	:= ""


	DEFINE REPORT oReport NAME "AGRAR750" TITLE STR0001 PARAMETER "REPORT" ACTION {|oReport| PrintReport(oReport)}

	oReport:lParamPage = .F.  //Não imprime os parametros
	oReport:SetCustomText( {|| AG750MoCab(oReport, POSICIONE("ADA",1,xFilial("ADA")+&(cAliasRel+"->DXS_CODCTP"),"ADA_SAFRA")) } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³"Cabecalho Romaneio"                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE SECTION oSection1 OF oReport TITLE STR0001 TABLES "DXS" LINE STYLE

	DEFINE BORDER OF oSection1 EDGE_BOTTOM  WEIGHT 2 

	DEFINE CELL NAME "cEmpresa"    	OF oSection1 TITLE STR0002 SIZE 25 CELL BREAK //Empresa
	DEFINE CELL NAME "DXS_CODIGO" 	OF oSection1 SIZE 25 CELL BREAK
	DEFINE CELL NAME "A1_NOME"		OF oSection1 TITLE STR0003 AUTO SIZE BLOCK {|| POSICIONE("SA1",1,xFilial("SA1")+&(cAliasRel+"->DXS_CLIENT")+&(cAliasRel+"->DXS_LJCLI"),"A1_NOME") } 
	DEFINE CELL NAME "A1_END"		OF oSection1 AUTO SIZE BLOCK {|| POSICIONE("SA1",1,xFilial("SA1")+&(cAliasRel+"->DXS_CLIENT")+&(cAliasRel+"->DXS_LJCLI"),"A1_END") }  CELL BREAK
	DEFINE CELL NAME "DXS_PLACA"		OF oSection1 TITLE STR0004 SIZE 15
	DEFINE CELL NAME "DXS_DATA"		OF oSection1 TITLE STR0005 SIZE 10 CELL BREAK
	DEFINE CELL NAME "DXS_CODCTP"	OF oSection1 AUTO SIZE CELL BREAK
	DEFINE CELL NAME "DXS_NUMPED"	OF oSection1 AUTO SIZE CELL BREAK
	DEFINE CELL NAME "OBS" 			OF oSection1 BOLD SIZE 70 ALIGN LEFT BLOCK {|| STR0006 + &(cAliasRel+"->DXS_NUMNFS") + STR0007 + &(cAliasRel+"->DXS_SERNFS")} CELL BREAK //Este romaneio é parte integrante da nota fiscal 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³"Dados Gerais" 		                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE SECTION oSection2 OF oReport TITLE "Dados Gerais" TABLES "DXI"

	DEFINE CELL NAME "DXI_CODIGO1" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0009  SIZE 10    //Fardo
	DEFINE CELL NAME "DXI_CLACOM1"	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0010  SIZE 10    //Tipo
	DEFINE CELL NAME "DXI_PSLIQU1" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0011  SIZE 10    //Peso
	DEFINE CELL NAME "DXI_PRENSA1" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0012  SIZE 10    //Prensa

	DEFINE CELL NAME "DXI_CODIGO2" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0009  SIZE 10    //Fardo
	DEFINE CELL NAME "DXI_CLACOM2"	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0010  SIZE 10    //Tipo
	DEFINE CELL NAME "DXI_PSLIQU2" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0011  SIZE 10    //Peso
	DEFINE CELL NAME "DXI_PRENSA2" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0012  SIZE 10    //Prensa

	DEFINE CELL NAME "DXI_CODIGO3" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0009  SIZE 10    //Fardo
	DEFINE CELL NAME "DXI_CLACOM3"	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0010  SIZE 10    //Tipo
	DEFINE CELL NAME "DXI_PSLIQU3" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0011  SIZE 10    //Peso
	DEFINE CELL NAME "DXI_PRENSA3" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0012  SIZE 10    //Prensa

	DEFINE CELL NAME "DXI_CODIGO4" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0009  SIZE 10    //Fardo
	DEFINE CELL NAME "DXI_CLACOM4"	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0010  SIZE 10    //Tipo
	DEFINE CELL NAME "DXI_PSLIQU4" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0011  SIZE 10    //Peso
	DEFINE CELL NAME "DXI_PRENSA4" 	OF oSection2 HEADER ALIGN CENTER ALIGN CENTER PICTURE "" TITLE STR0012  SIZE 10    //Prensa

	// CELL  BORDER  
	DEFINE CELL BORDER OF oSection2 EDGE_ALL  

	// CELL HEADER BORDER  
	DEFINE CELL HEADER BORDER OF oSection2 EDGE_ALL 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³"Pesos" 				                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE SECTION oSection3 OF oReport TITLE "Pesos Romaneio" TABLES "DXI" 

	DEFINE BORDER OF oSection3 EDGE_BOTTOM WEIGHT 2

	DEFINE CELL NAME "DXI_BLOCO" 	OF oSection3 TITLE STR0021 ALIAS "DXI" SIZE 15 HEADER ALIGN CENTER ALIGN RIGHT CELL BREAK
	DEFINE CELL NAME "DXI_QTDFAR" 	OF oSection3 TITLE STR0022 ALIAS "DXI" SIZE 15 HEADER ALIGN CENTER ALIGN RIGHT CELL BREAK 
	DEFINE CELL NAME "DXI_CLACOM" 	OF oSection3 TITLE STR0010 ALIAS "DXI" SIZE 15 HEADER ALIGN CENTER ALIGN RIGHT CELL BREAK 
	DEFINE CELL NAME "DXI_TOTLIQU" 	OF oSection3 TITLE STR0014 ALIAS "DXI" SIZE 15 HEADER ALIGN CENTER ALIGN RIGHT CELL BREAK 



	DEFINE BREAK oBreak1 OF oSection3 WHEN {||  }  TITLE "Total"



	DEFINE FUNCTION oFunc1 FROM oSection3:Cell("DXI_QTDFAR") ;
	OF oSection3 FUNCTION SUM BREAK oBreak1 TITLE STR0015  NO END SECTION 		
	DEFINE FUNCTION oFunc2 FROM oSection3:Cell("DXI_TOTLIQU") ;
	OF oSection3 FUNCTION SUM BREAK oBreak1 TITLE STR0014  NO END SECTION 

	DEFINE SECTION oSection4 OF oReport TITLE STR0016 TABLES "DXM" LINE STYLE

	DEFINE CELL NAME "DXS_PSSUBT" 	OF oSection4 TITLE STR0017	 ALIAS "DXI" SIZE 19 ALIGN RIGHT CELL BREAK 
	DEFINE CELL NAME "DXS_PSLIQU"	OF oSection4 TITLE STR0020 	 ALIAS "DXI" SIZE 17 ALIGN RIGHT CELL BREAK  


Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Função para busca das informações que serão impressas no relatório

@param oReport	Objeto para manipulação das seções, atributos e dados do relatório.
@return void
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------
Static Function PrintReport(oReport)
	Local oCab		 :=oReport:Section(1)
	Local oDados	 :=oReport:Section(2)
	Local oFardos	 :=oReport:Section(3)
	Local oPesos	 :=oReport:Section(4)
	Local cNomeEmp   := AllTrim(FwFilialName(,cFilAnt,2))
	Local cAliasDXI  := ""
	Local cAliasBLC  := ""



	#IFDEF TOP
	/***********************************/
	/** Query do relatorio da secao 1 **/
	/***********************************/

	Begin Report Query oCab   

		cAliasRel:= GetNextAlias()

		BeginSql Alias cAliasRel
		SELECT *
		FROM %table:DXS% DXS,
		%table:DXT% DXT
		WHERE DXS.DXS_FILIAL = %xFilial:DXS%   AND
		DXT.DXT_FILIAL = %xFilial:DXT%  	   AND
		DXS.DXS_CODIGO = DXT.DXT_CODIGO        AND 
		DXS.DXS_CODIGO = %Exp:DXS->DXS_CODIGO% AND
		DXS.%notDel%                           AND
		DXT.%notDel%	 				
		EndSql 
	End Report Query oCab	


	/***********************************/
	/* Imprime dados do Cabecalho      */
	/***********************************/
	oCab:Init()
	oCab:Cell("cEmpresa"):SetValue( cNomeEmp )
	oCab:PrintLine()
	oCab:Finish()
	


	/**** Agrupamento por Bloco ****/
	cAliasBLC:= GetNextAlias()

	BeginSql Alias cAliasBLC
		SELECT DXI_BLOCO
		FROM %table:DXI% DXI
			WHERE DXI.DXI_FILIAL = %xFilial:DXI%     AND 
			DXI.DXI_ROMSAI   = %Exp:DXS->DXS_CODIGO% AND
			DXI.%notDel%
		GROUP BY DXI_BLOCO	
	EndSql
	
	dbSelectArea(cAliasBLC)
	(cAliasBLC)->( dbGoTop() )
	While .Not. Eof() 


		If !Empty((cAliasBLC)->DXI_BLOCO)
		
			/***********************************/
			/* Query do relatorio da secao 2   */
			/***********************************/
			cAliasDXI:= GetNextAlias()
	
	
			BeginSql Alias cAliasDXI
			SELECT *
			FROM %table:DXI% DXI
			WHERE DXI.DXI_FILIAL = %xFilial:DXI%               AND 
			DXI.DXI_BLOCO    = %Exp:(cAliasBLC)->DXI_BLOCO% AND
			DXI.DXI_ROMSAI   = %Exp:DXS->DXS_CODIGO% AND
			DXI.%notDel%
			ORDER BY DXI_SAFRA, DXI_CODIGO	
			EndSql
	
	
			/***************************/
			/* Imprime dados gerais	   */
			/***************************/
			oDados:Init()
	
			oReport:PrintText("")
			oReport:PrintText("BLOCO" + " : " + Transform((cAliasBLC)->DXI_BLOCO,"@!"),,10) 
			oReport:PrintText("")
			oReport:PrintText("")
	
			While (cAliasDXI)->(!Eof())
				oDados:Cell("DXI_CODIGO1"):SetValue( (cAliasDXI)->( DXI_CODIGO )  )
				oDados:Cell("DXI_CLACOM1"):SetValue(  AllTrim(Transform((cAliasDXI)->( DXI_CLACOM ), PesqPict("DXI", "DXI_CLACOM")))  )
				oDados:Cell("DXI_PSLIQU1"):SetValue( AllTrim(Transform((cAliasDXI)->( DXI_PSLIQU ), PesqPict("DXI", "DXI_PSLIQU")))  )
				oDados:Cell("DXI_PRENSA1"):SetValue( (cAliasDXI)->( DXI_PRENSA )  )
				(cAliasDXI)->( dbSkip() ) 
	
				If (cAliasDXI)->(!Eof())
					oDados:Cell("DXI_CODIGO2"):SetValue( (cAliasDXI)->( DXI_CODIGO )  )
					oDados:Cell("DXI_CLACOM2"):SetValue(  AllTrim(Transform((cAliasDXI)->( DXI_CLACOM ), PesqPict("DXI", "DXI_CLACOM")))  )
					oDados:Cell("DXI_PSLIQU2"):SetValue( AllTrim(Transform((cAliasDXI)->( DXI_PSLIQU ), PesqPict("DXI", "DXI_PSLIQU")))  )
					oDados:Cell("DXI_PRENSA2"):SetValue( (cAliasDXI)->( DXI_PRENSA )  )
					(cAliasDXI)->( dbSkip() )
				Else
					oDados:Cell("DXI_CODIGO2"):SetValue( "" )
					oDados:Cell("DXI_CLACOM2"):SetValue( "" )
					oDados:Cell("DXI_PSLIQU2"):SetValue( "" )
					oDados:Cell("DXI_PRENSA2"):SetValue( "" )	
				EndIf
	
				If (cAliasDXI)->(!Eof())
					oDados:Cell("DXI_CODIGO3"):SetValue( (cAliasDXI)->( DXI_CODIGO )  )
					oDados:Cell("DXI_CLACOM3"):SetValue(  AllTrim(Transform((cAliasDXI)->( DXI_CLACOM ), PesqPict("DXI", "DXI_CLACOM")))  )
					oDados:Cell("DXI_PSLIQU3"):SetValue( AllTrim(Transform((cAliasDXI)->( DXI_PSLIQU ), PesqPict("DXI", "DXI_PSLIQU")))  )
					oDados:Cell("DXI_PRENSA3"):SetValue( (cAliasDXI)->( DXI_PRENSA )  )		
					(cAliasDXI)->( dbSkip() ) 
				Else
					oDados:Cell("DXI_CODIGO3"):SetValue( "" )
					oDados:Cell("DXI_CLACOM3"):SetValue( "" )
					oDados:Cell("DXI_PSLIQU3"):SetValue( "" )
					oDados:Cell("DXI_PRENSA3"):SetValue( "" )	
				EndIf
	
				If (cAliasDXI)->(!Eof())
					oDados:Cell("DXI_CODIGO4"):SetValue( (cAliasDXI)->( DXI_CODIGO )  )
					oDados:Cell("DXI_CLACOM4"):SetValue(  AllTrim(Transform((cAliasDXI)->( DXI_CLACOM ), PesqPict("DXI", "DXI_CLACOM")))  )
					oDados:Cell("DXI_PSLIQU4"):SetValue( AllTrim(Transform((cAliasDXI)->( DXI_PSLIQU ), PesqPict("DXI", "DXI_PSLIQU")))  )
					oDados:Cell("DXI_PRENSA4"):SetValue( (cAliasDXI)->( DXI_PRENSA )  )
					(cAliasDXI)->( dbSkip() ) 
				Else
					oDados:Cell("DXI_CODIGO4"):SetValue( ""  )
					oDados:Cell("DXI_CLACOM4"):SetValue( ""  )
					oDados:Cell("DXI_PSLIQU4"):SetValue( "" )
					oDados:Cell("DXI_PRENSA4"):SetValue( "" )	
				EndIf
	
				oDados:PrintLine()
			EndDo
			oDados:Finish()
			(cAliasDXI)->(DBCloseArea())
		Endif
			
		dbSelectArea(cAliasBLC)
		(cAliasBLC)->( dbSkip() ) 
	EndDo
		/************************************/
		/* Query do relatorio dos Fardos    */
		/************************************/

	Begin Report Query oFardos   

		cAliasDXI:= GetNextAlias()

		BeginSql Alias cAliasDXI
		SELECT Count(DXI.DXI_ROMSAI)AS DXI_QTDFAR, SUM(DXI.DXI_PSLIQU) As DXI_TOTLIQU, 
			SUM(DXI.DXI_PSBRUT) As DXI_TOTBRU, DXI.DXI_CLACOM, DXI.DXI_BLOCO
		FROM %table:DXI% DXI
			WHERE DXI.DXI_FILIAL = %xFilial:DXI%      AND
			DXI.DXI_ROMSAI    = %Exp:DXS->DXS_CODIGO% AND
			DXI.%notDel%	
			GROUP BY DXI.DXI_ROMSAI, DXI.DXI_CLACOM, DXI.DXI_BLOCO				
		EndSql 

	End Report Query oFardos	

	/*****************************/
	/* Imprime dados de Pesos	 */
	/*****************************/
	oFardos:Init()
	oFardos:Print()
	oFardos:Finish()
	(cAliasDXI)->(DBCloseArea())
		
	
	/*********************************/
	/* Query do relatorio do Pesos	 */
	/*********************************/

	Begin Report Query oPesos   

		cAliasRel:= GetNextAlias()
		BeginSql Alias cAliasRel
		SELECT *
		FROM %table:DXS% DXS
		WHERE DXS.DXS_FILIAL = %xFilial:DXS% AND
		DXS.DXS_CODIGO = %Exp:DXS->DXS_CODIGO% AND
		DXS.%notDel%
		EndSql

	End Report Query oPesos	


	/*****************************/
	/* Imprime dados de Pesos	 */
	/*****************************/
	oPesos:Init()
	oPesos:Print()
	oPesos:Finish()


	#ENDIF

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AG750MoCab
Função para montar cabecalho do relatorio  

@param oReport Objeto para manipulação das seções, atributos e dados do relatório.
@return aCabec  Array com o cabecalho montado
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------

Function AG750MoCab(oReport, cSafra)
	Local aCabec 	:= {}
	Local cNmEmp  	:= ""   
	Local cNmFilial  	:= ""   
	Local cChar		:= CHR(160)  // caracter dummy para alinhamento do cabeçalho

	Default cSafra := ""

	If SM0->(Eof())
		SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
	Endif

	cNmEmp	:= AllTrim( SM0->M0_NOME )
	cNmFilial	:= AllTrim( SM0->M0_FILIAL )

	// Linha 1
	AADD(aCabec, "__LOGOEMP__") // Esquerda

	// Linha 2 
	AADD(aCabec, cChar) //Esquerda
	aCabec[2] += Space(9) // Meio
	aCabec[2] += Space(9) + RptFolha + TRANSFORM(oReport:Page(),'999999') // Direita

	// Linha 3
	AADD(aCabec, "SIGA /" + oReport:ReportName() + "/v." + cVersao) //Esquerda
	aCabec[3] += Space(9) + oReport:cRealTitle // Meio
	aCabec[3] += Space(9) + "Dt.Ref:" + Dtoc(dDataBase)   // Direita

	// Linha 4
	AADD(aCabec, RptHora + oReport:cTime) //Esquerda
	aCabec[4] += Space(9) // Meio
	aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

	// Linha 5
	AADD(aCabec, "Empresa:" + cNmEmp) //Esquerda
	aCabec[5] += Space(9) // Meio
	If !Empty(cSafra)
		aCabec[5] += Space(9)+ "Safra:"+cSafra   // Direita
	EndIf     

	// Linha 5
	AADD(aCabec, "Filial:" + cNmFilial) //Esquerda

Return aCabec