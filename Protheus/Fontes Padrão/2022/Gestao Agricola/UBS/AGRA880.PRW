#INCLUDE "AGRA880.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

//Pula Linha
#DEFINE CTRL Chr(13)+Chr(10)

/*-----------------------------------------------------------*\

	{Protheus.doc} AGRA880 
	Calculo do Indice de Recomendação do lote de sementes.
	
	@param: Nil
	@author: Cleber Maldonado
	@since: 19/02/2012
	@Uso: SIGAAGR           
	                                                              
\*-----------------------------------------------------------*/
/*
##############################################################################
# Função   : AGRA880()                                                    	#
# Descrição: Calculo do Indice de Recomendação do lote de sementes #REFEITO#	#
# Autor    : Ana Laura Olegini                                            	#
# Data     : 15/10/2014                                                    	#  
##############################################################################
*/
Function AGRA880()

	Local oReport		
	
	Private cPergunta	:= "AGRA880001"	
	           
	//If TRepInUse()
	
	If FindFunction("TRepInUse") .And. TRepInUse()
		
		Pergunte( cPergunta, .f. )
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:PrintDialog()
	
	EndIf

Return( Nil )                             

/*
##############################################################################
# Função   : ReportDef()                                                    	#
# Descrição: Funcao para geracao do relatório 								  	#
# Autor    : Ana Laura Olegini                                            	#
# Data     : 15/10/2014                                                    	#  
##############################################################################
*/
Static Function ReportDef()

	Local oReport
	Local oSection1
	Local aOrdem    := {}

	oReport := TReport():New( "AGRA880", STR0005 , cPergunta, {| oReport | PrintReport( oReport ) }, STR0006 ) //"Cálculo do Índice de Recomendação do Lote de Sementes"###"Este relatorio ira realizar o cálculo do índice de recomendação do lote de sementes."
	//oReport:SetLandScape()	//Define se o relatorio saira deitado
	oReport:HideParamPage()	//Desabilita a impressao da pagina de parametros
	oReport:SetTotalInLine( .F. )
	
	Aadd( aOrdem, STR0007 ) //"Safra"
	
	oSection1 := TRSection():New( oReport, STR0008, {"NP9"}, aOrdem ) //"Cálculo do Índice de Recomendação do Lote de Sementes"
	oSection1:SetTotalInLine(.F.)

	TRCell():New(oSection1,"NP9_CODSAF"	,"NP9",		,,TamSX3("NP9_CODSAF")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Safra"
	TRCell():New(oSection1,"NP9_LOTE" 		,"NP9",		,,TamSX3("NP9_LOTE")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Lote"
	TRCell():New(oSection1,"NP9_PROD" 		,"NP9",		,,TamSX3("NP9_PROD")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Produto"
	TRCell():New(oSection1,"NP9_UM" 		,"NP9",		,,TamSX3("NP9_UM")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"UM"
	TRCell():New(oSection1,"NP9_CULTRA"	,"NP9",		,,TamSX3("NP9_CULTRA")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Cultura"
	TRCell():New(oSection1,"NP9_CTVAR"		,"NP9",		,,TamSX3("NP9_CTVAR")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Cultivar"
	TRCell():New(oSection1,"NP9_CATEG" 	,"NP9",		,,TamSX3("NP9_CATEG")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Categoria"
	TRCell():New(oSection1,"NP9_PENE" 		,"NP9",		,,TamSX3("NP9_PENE")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/) //"Peneira"
	TRCell():New(oSection1,"NP9_STATUS"	,"NP9",		,,TamSX3("NP9_STATUS")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Status"
	TRCell():New(oSection1,"NP9_IR"			,"NP9",		,"@E 999.99",06				,/*lPixel*/,/*{|| code-block de impressao }*/) //"IR"

Return( oReport )

/*-----------------------------------------------------------*\
	
	{Protheus.doc} AGR880Pro
	Processamento do índice de recomendação
	
	@param: Nil
	@author: Cleber Maldonado
	@since: 19/02/2012
	@Uso: SIGAAGR

\*-----------------------------------------------------------*/
/*
##############################################################################
# Função   : AGR880Pro()                                                    	#
# Descrição: Processamento do índice de recomendação             #REFEITO#	#
# Autor    : Ana Laura Olegini                                            	#
# Data     : 15/10/2014                                                    	#  
##############################################################################
*/
//Static Function AGR880Pro()
Static Function PrintReport( oReport )
	 
	Local cAliasQry 	:= GetNextAlias() 
	Local cQry      	:= ""
	Local oS1		  	:= oReport:Section( 1 ) 
	
	Local lRet 		:= .T.	    
	
	
	cQry := " SELECT NPX.NPX_LOTE, NPX.NPX_CODPRO, AVG(NPX.NPX_RESNUM) AS MEDIA  "
 	cQry +=   " FROM "+RetSqlName("NPX")+ " NPX "
	
	cQry +=  " INNER JOIN "+RetSqlName("NP9")+ " NP9 ON NP9.NP9_FILIAL = '"+xFilial("NP9")+"' "
	cQry +=    " AND NP9.NP9_CODSAF = NPX.NPX_CODSAF "
	cQry +=    " AND NP9.NP9_PROD   = NPX.NPX_CODPRO "
	cQry +=    " AND NP9.NP9_LOTE   = NPX.NPX_LOTE "	
	cQry +=    " AND NP9.NP9_TIPLOT = 1 "
	cQry +=    " AND NP9.D_E_L_E_T_ = '' "
	
	cQry +=  " WHERE NPX.NPX_FILIAL = '"+xFilial("NPX")+"' "
	cQry +=    " AND NPX.NPX_CODSAF = '"+mv_par01+"' "
	cQry +=    " AND NPX.NPX_CODPRO = NP9.NP9_PROD "
	cQry +=    " AND NPX.NPX_IR     = 2 "
	cQry +=    " AND NPX.NPX_ATIVO  = 1 "
	cQry +=    " AND NPX.D_E_L_E_T_ = '' "
	
	cQry +=  " GROUP BY NPX.NPX_LOTE, NPX.NPX_CODPRO  "
		
	cQry := ChangeQuery(cQry)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQry),cAliasQry,.F.,.T.)
	 
		
	/* 
		Pega o índice de recomendação classifica e atribui status ao lote
		Grava o índice de recomandação no resultado laboratorial interno
	*/  

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	dbSelectArea("NP9")
	dbSetOrder(1)
	
	oS1:Init()
	
	
	While (cAliasQry)->(!EOF()) 
	
		cCodSafra 	:= MV_PAR01
		cProduto	:= (cAliasQry)->NPX_CODPRO
		cLote		:= (cAliasQry)->NPX_LOTE 
		
		DbSelectArea("NP9")
		NP9->( DbSetOrder(1) )
		If NP9->( DbSeek(xFilial("NP9")+cCodSafra+cProduto+cLote) ) //NP9_FILIAL+NP9_CODSAF+NP9_PROD+NP9_LOTE
			
			DbselectArea("NP0")
			NP0->( DbSetOrder(1) )	
			NP0->( DbSeek(xFilial("NP0")+NP9->NP9_CULTRA,.T. ) )  //NP0_FILIAL+NP0_CULTRA+NP0_CLASS 
		    
			While NP0->(!Eof()) .And. xFilial("NP0") = NP0->NP0_FILIAL .And. NP0->NP0_CULTRA = NP9->NP9_CULTRA 
			    
			    //Se MEDIA for MAIOR e/ou IGUAL IR INICO .E. Se MEDIA for MENOR e/ou IGUAL IR FIM  ###ENTRA 
			    If (cAliasQry)->MEDIA >= NP0->NP0_IRINI .And. (cAliasQry)->MEDIA <= NP0->NP0_IRFIM
					
					DbSelectArea("NP9")
					RecLock("NP9",.F.)	
						NP9->NP9_CLASS := NP0->NP0_CLASS
						NP9->NP9_IR 	:= (cAliasQry)->MEDIA
						
						If  NP0->NP0_REJCQ 		  
						     NP9->NP9_STATUS := "3"
						Else
							 NP9->NP9_STATUS := "2"
						EndIf								
					NP9->(MsUnLock())
			
					EXIT
				EndIf											
				
				NP0->(DBSKIP())						
			EndDo
			
			
			dbSelectArea("NP9")
			dbSetOrder(1)	
			If dbSeek(xFilial("NP9")+cCodSafra+cProduto+cLote)	//NP9_FILIAL+NP9_CODSAF+NP9_PROD+NP9_LOTE
				If NP9->NP9_IR = (cAliasQry)->MEDIA
					oS1:PrintLine()
				EndIf
			EndIf 		
			
		EndIf 
		(cAliasQry)->(DbSkip())
		
	EndDo

	If oReport:Cancel() 
		Return( Nil )
	EndIf

	oS1:Finish()

Return lRet
