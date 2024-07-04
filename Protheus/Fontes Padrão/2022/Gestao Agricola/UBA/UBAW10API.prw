#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"
 
WSRESTFUL UBAW10API DESCRIPTION ('Endpoint de fardos listados para carregamento') FORMAT "application/json,text/html" 
	WSDATA SourceBranch AS CHARACTER
	WSDATA Scheduling	AS CHARACTER
	
	WSDATA Page       	AS INTEGER 		OPTIONAL
	WSDATA PageSize    	AS INTEGER		OPTIONAL
	
	WSMETHOD GET packingList;
	DESCRIPTION ("Retorna fardinhos vinculados ao agendamento.");
	PATH "v1/packingList" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj   

 	WSMETHOD POST loadBale;
	DESCRIPTION ("Grava os fardinhos associados no carregamento.");
	PATH "/v1/loadBale" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj

END WSRESTFUL

WSMETHOD GET packingList WSRECEIVE Page,PageSize,SourceBranch,Scheduling WSREST UBAW10API
	Local lRet			AS LOGICAL
	Local nCount     	AS NUMERIC
	Local nLastRec		AS NUMERIC
	Local nMaxRec		AS NUMERIC
	Local aRetFard     	AS ARRAY
	Local aRetCabe 		AS ARRAY
	Local aRetBloc 		AS ARRAY
	Local aQryParam		AS ARRAY
	Local oPage      	AS OBJECT
	
	Local oResponse	:= JsonObject():New()
	Local cSeqBloco	:= ""
	Local cSeqFardo	:= ""	
	Local nBlocos	:= 0
	Local nFardos	:= 0
	Local cCodFil	:= ::SourceBranch //FILIAL
	
	::SetContentType("application/json")	
	
	aQryParam := {}  	
	lRet 	  := .T. 
	aRetFard  := {}
	aRetCabe  := {}
	aRetBloc  := {}
	nCount    := 0	
	aAdd(aQryParam,::SourceBranch)
	aAdd(aQryParam,::Scheduling)
	
	if !EMPTY(cCodFil) .AND. AGRLOGAAPI(cCodFil)
	
		if !(EMPTY(::Page))
			oPage:=FwPageCtrl():New(::PageSize,::Page)
		EndIf
		
		aRetFard := LoadFardos(aQryParam)
		aRetCabe := LoadDetail(aQryParam)
		aRetBloc := LoadBlocos(aQryParam,aRetFard)
		
		oResponse["content"] := {}
		Aadd(oResponse["content"], JsonObject():New())
		oResponse["content"][1]["Items"] := {}
		Aadd(oResponse["content"][1]["Items"], JsonObject():New())
		
		//--Cabeçalho (Informaçoes do romaneio)
		oResponse["content"][1]["Items"][1]["SOURCEBRANCH"]			:= aRetCabe[1] 
		oResponse["content"][1]["Items"][1]["PACKNUMBER"]			:= aRetCabe[2] 
		oResponse["content"][1]["Items"][1]["SHIPPINGINSTRUCTION"]	:= aRetCabe[3] 
		oResponse["content"][1]["Items"][1]["CARPLATE"]				:= aRetCabe[4] 
		oResponse["content"][1]["Items"][1]["VEHICLECAPACITY"]		:= aRetCabe[5] 
		oResponse["content"][1]["Items"][1]["WEIGHTLIMIT"]			:= aRetCabe[6] 	 
		
		//--Blocos
		oResponse["content"][1]["Items"][1]["Blocks"] := {}
		For nBlocos := 1 To Len(aRetBloc)
			cSeqBloco := "0"+cValtoChar(nBlocos)		
		
			Aadd(oResponse["content"][1]["Items"][1]["Blocks"], JsonObject():New())
			oResponse["content"][1]["Items"][1]["Blocks"][nBlocos]["ID"] 			:= cSeqBloco
			oResponse["content"][1]["Items"][1]["Blocks"][nBlocos]["BLOCK"]  		:= aRetBloc[nBlocos][1]
			oResponse["content"][1]["Items"][1]["Blocks"][nBlocos]["WAREHOUSE"]		:= aRetBloc[nBlocos][2]
			oResponse["content"][1]["Items"][1]["Blocks"][nBlocos]["BALESQUANTITY"]	:= aRetBloc[nBlocos][4]
			oResponse["content"][1]["Items"][1]["Blocks"][nBlocos]["GROSSWEIGHT"]	:= aRetBloc[nBlocos][3]
					
									
			//--Fardinhos do bloco
			oResponse["content"][1]["Items"][1]["Blocks"][nBlocos]["Bales"] := {}				
			For nFardos := 1 To Len(aRetFard)
				nCount++
				If !(oPage:CanAddLine())
					nMaxRec := nCount
					LOOP
				EndIf		
				
				cSeqFardo := "0"+cValtoChar(nFardos)
		
				Aadd(oResponse["content"][1]["Items"][1]["Blocks"][nBlocos]["Bales"], JsonObject():New())
				aTail(oResponse["content"][1]["Items"][1]["Blocks"][nBlocos]["Bales"])["ID"]		  := cSeqFardo
				aTail(oResponse["content"][1]["Items"][1]["Blocks"][nBlocos]["Bales"])["TAGBALES"]	  := aRetFard[nFardos][12]
				aTail(oResponse["content"][1]["Items"][1]["Blocks"][nBlocos]["Bales"])["CROP"]	  	  := AllTrim(aRetFard[nFardos][4])
				aTail(oResponse["content"][1]["Items"][1]["Blocks"][nBlocos]["Bales"])["BLOCK"]		  := aRetFard[nFardos][5]
				aTail(oResponse["content"][1]["Items"][1]["Blocks"][nBlocos]["Bales"])["WAREHOUSE"]   := aRetFard[nFardos][11]
				aTail(oResponse["content"][1]["Items"][1]["Blocks"][nBlocos]["Bales"])["GROSSWEIGHT"] := aRetFard[nFardos][8]	
				
				nLastRec := nCount
	
			Next nFardos		
		Next nItens
		
		oResponse["content"][1]["Items"][1]["LastRecno"]  := nLastRec
		oResponse["content"][1]["Items"][1]["MaxRecno"]   := nMaxRec
		oResponse["content"][1]["Items"][1]["BALESQUANTITY"] := nMaxRec
		
		::SetResponse(EncodeUTF8(FWJsonSerialize(oResponse, .F., .F., .T.)))
	else
		//Colocar mensagem de erro aqui!
		SetRestFault(400,EncodeUtf8( "Filial inválida." ))
		lRet := .F.
	endIf
	
Return lRet

/****************************************************************************************
/****************************************************************************************
***** ESTA FUNÇÃO LOADFARDOS É CÓPIA DO AGRX500F COM ALTERAÇÃO PARA FUNCIONAR PELA  ***** 
***** INTEGRAÇÃO REST QUALQUER ALTERAÇÃO FEITA NO AGRX500F DEVE SER FEITA AQUI      *****  
***** TAMBÉM PARA QUE AS FUNCIONALIDADES NÃO SEJAM DIVERGENTES.                     *****
*****************************************************************************************
****************************************************************************************/
/*/{Protheus.doc} LoadFardos
// Responsável por buscar os fardinhos que podem ser vinculados ao romaneio. 
@author brunosilva
@since 24/07/2018
@version 1.0
@return aColsLoad, array, fardos disponíveis para vínculo com o romaneio.
@param aQryParam, array, descricao
@type function
/*/
Static Function LoadFardos(aQryParam)
	Local aArea	   		:= GetArea()
	Local oModel		:= FwLoadModel("AGRA500")
	Local oMldNJJ 		:= NIL
	Local oMldN9D 		:= NIL
	Local oMldN9E 		:= NIL
	Local nX	
	Local aFardN9D  	:= {}
	Local cFilPack 		:= aQryParam[1]
	Local cNumberPack 	:= aQryParam[2]
	Local aColsLoad		:= {}	

	//Posicionando no registro certo para depois ler os outros modelos
	DbSelectArea("NJJ")
	NJJ->(DbSetOrder(1))
	if NJJ->(DbSeek(PadR(cFilPack,TamSX3("NJJ_FILIAL")[1]) + cNumberPack)) 

		oModel:Activate()	

		oMldNJJ 	:= oModel:GetModel( "AGRA500_NJJ" )
		oMldN9D 	:= oModel:GetModel( "AGRA500_N9D" )
		oMldN9E 	:= oModel:GetModel( "AGRA500_N9E" )

		For nX := 1 to oMldN9D:Length()
			oMldN9D:GoLine(nX)
			If .Not. oMldN9D:IsDeleted() .And. .Not. Empty(oMldN9D:GetValue("N9D_SAFRA"))
				aAdd(aFardN9D, {oMldN9D:GetValue("N9D_FILIAL"), oMldN9D:GetValue("N9D_SAFRA"), oMldN9D:GetValue("N9D_FARDO")})
			EndIf
		Next nX

		aColsLoad := LDFardAut(aColsLoad, aFardN9D,oMldNJJ,oMldN9D,oMldN9E,aQryParam)
		aColsLoad := LDFardBlAut(aColsLoad, aFardN9D,oMldNJJ,oMldN9D,oMldN9E,aQryParam)
		If Empty(aColsLoad) //NÃO TEM FARDOS NEM BLOCOS NA AUTORIZAÇÃO
			aColsLoad := LDFardIE(aColsLoad, aFardN9D, .T.,oMldNJJ,oMldN9D,oMldN9E,aQryParam) //"Não foram selecionados fardos na Autorização. Procurando Fardos da Instrução de Embarque..."
			aColsLoad := LDFardBlIE(aColsLoad, aFardN9D, .T.,oMldNJJ,oMldN9D,oMldN9E,aQryParam) //"Não foram selecionados fardos de Blocos na Autorização. Procurando fardos de Blocos da Instrução de Embarque..."
			//__lVldAut := .F.
		Else
			//__lVldAut := .T.
		EndIf


		If .Not. Empty(aColsLoad)
			aColsLoad := ASort( aColsLoad, , , { | x, y | x[2]+x[3]+x[4]+x[5]+x[6]+x[7] < y[2]+y[3]+y[4]+y[5]+y[6]+y[7]})
		EndIf

	endIf

	RestArea(aArea)
Return(aColsLoad)


Static Function LDFardAut(aColsLoad, aFardN9D,oMldNJJ,oMldN9D,oMldN9E,aQryParam)
	Local aArea	    := GetArea()
	Local cAliasQry := ""
	Local cQry 		:= ""
	Local nCont	    := 0
	Local nX	
	Local lAdiciona := .T.
	Local cNumberPack 	:= aQryParam[2]

	cAliasQry := GetNextAlias()

	cQry := " SELECT DXI.DXI_FILIAL,DXI.DXI_PSBRUT,DXI.DXI_PSLIQU,DXI.DXI_PESCHE,DXI.DXI_PESSAI,DXI.DXI_PESCER,DXI.DXI_LOCAL,DXI.DXI_ETIQ,"
	cQry +=        "N9D.N9D_FILIAL,N9D.N9D_CODINE,N9D.N9D_ITEMAC,N9D.N9D_SAFRA,N9D.N9D_BLOCO,"
	cQry +=        "N9D.N9D_FARDO,N9D.N9D_CODFAR,N9D.N9D_PESFIM,N9D.N9D_FILORG,N9D.N9D_CODCTR,"
	cQry +=        "N9D.N9D_ITEETG,N9D.N9D_ITEREF,N9D.N9D_PESINI,NJM.NJM_DOCSER,NJM.NJM_DOCNUM "
	cQry += 	"FROM " + RetSqlName("N9D") + " N9D "

	cQry += 	"LEFT OUTER JOIN "+ RetSqlName("NJM") +" NJM "	
	cQry += 		"ON (NJM.D_E_L_E_T_=' ' "
	cQry += 		"AND NJM.NJM_FILIAL='" + FwXfilial("NJM") + "' "
	cQry += 		"AND NJM.NJM_CODROM='" + cNumberPack + "' " //Romaneio
	cQry += 		"AND NJM.NJM_CODINE=N9D.N9D_CODINE "
	cQry += 		"AND NJM.NJM_CODCTR=N9D.N9D_CODCTR "
	cQry += 		"AND NJM.NJM_ITEM=N9D.N9D_ITEETG "
	cQry += 		"AND NJM.NJM_SEQPRI=N9D.N9D_ITEREF) "

	cQry += 	"INNER JOIN "+ RetSqlName("DXI") +" DXI "
	cQry += 		"ON (DXI.D_E_L_E_T_ = ' ' "
	cQry += 		"AND DXI_FILIAL=N9D_FILIAL "
	cQry += 		"AND DXI_SAFRA=N9D_SAFRA "
	cQry += 		"AND DXI_ETIQ=N9D_FARDO "  
	cQry += 		"AND DXI_CODINE=N9D_CODINE "
	cQry += 		"AND DXI_STATUS='90') " //instruido
	cQry += 			"WHERE N9D.D_E_L_E_T_ = ' '"
	cQry += 			" AND N9D.N9D_FILIAL='" + FwXfilial("N9D") + "' "
	cQry +=             " AND N9D.N9D_SAFRA='" + oMldNJJ:GetValue( "NJJ_CODSAF" ) + "'" //Safra
	cQry +=             " AND N9D.N9D_CODINE='" + oMldN9E:GetValue( "N9E_CODINE" ) + "'" //Instrucao de embarque
	cQry +=             " AND N9D.N9D_ITEETG='" + oMldN9E:GetValue( "N9E_ITEM" ) + "'" //Id Entrega
	cQry +=             " AND N9D.N9D_CODCTR='" + oMldN9E:GetValue( "N9E_CODCTR" ) + "'" //Contrato
	cQry +=             " AND N9D.N9D_ITEREF='" + oMldN9E:GetValue( "N9E_SEQPRI" ) + "'" //Regra
	cQry +=             " AND N9D.N9D_TIPMOV='10' " //Autorizacao de Carregamento
	cQry +=             " AND N9D.N9D_STATUS='2' " //1=Previsto;2=Ativo;3=Inativo
	cQry += "     AND N9D.N9D_FARDO NOT IN "
	cQry += 			"(SELECT N9D2.N9D_FARDO FROM "+ RetSqlName("N9D") +" N9D2"
	cQry += 					" INNER JOIN " + RetSqlName("NJJ") + " NJJ"
	cQry +=		 				" ON (NJJ.D_E_L_E_T_ = ' '"
	cQry += 					" AND NJJ.NJJ_FILIAL='" + FwXfilial("NJJ") + "'"
	cQry += 					" AND N9D2.N9D_FILIAL='" + FwXfilial("N9D") + "'"
	cQry += 					" AND NJJ.NJJ_CODROM = N9D2.N9D_CODROM)"
	cQry += 						" WHERE N9D2.D_E_L_E_T_=' '"
	cQry += 				 			" AND N9D.N9D_SAFRA=N9D2.N9D_SAFRA"
	cQry += 							" AND N9D2.N9D_TIPMOV='07' "
	cQry += 							" AND (N9D2.N9D_STATUS='1' OR N9D2.N9D_STATUS='2')"
	
	If oMldNJJ:GetValue( "NJJ_TIPO" )= '4'
		cQry += 						" AND NJJ.NJJ_TIPO = '4') "
	ElseIf oMldNJJ:GetValue( "NJJ_TIPO" )= '2'
		cQry += 						" AND NJJ.NJJ_TIPO = '2') "
	Else
		cQry += 						")"
	EndIF

	cQry += "ORDER BY N9D.N9D_CODINE,N9D.N9D_BLOCO,N9D.N9D_FARDO"

	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof()) 
		lAdiciona := .T.

		For nX := 1 To len(aFardN9D)
			If aFardN9D[nX][1] == (cAliasQry)->N9D_FILIAL  .And. ;
			aFardN9D[nX][2] == (cAliasQry)->N9D_SAFRA .And. ;
			aFardN9D[nX][3] == (cAliasQry)->N9D_FARDO
				lAdiciona := .F.
				exit
			EndIf
		Next nX

		If lAdiciona
			nCont++
			aAdd( aColsLoad, { "2",(cAliasQry)->DXI_FILIAL, (cAliasQry)->N9D_CODINE, (cAliasQry)->N9D_SAFRA ,;
			(cAliasQry)->N9D_BLOCO , (cAliasQry)->N9D_FARDO , (cAliasQry)->N9D_CODFAR,;
			(cAliasQry)->DXI_PSBRUT, (cAliasQry)->DXI_PSLIQU, (cAliasQry)->DXI_PESSAI,;
			(cAliasQry)->DXI_LOCAL, (cAliasQry)->DXI_ETIQ})								
		EndIf
		(cAliasQry)->(DbSkip())
	End

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return(aColsLoad)


Static Function LDFardBlAut(aColsLoad, aFardN9D,oMldNJJ,oMldN9D,oMldN9E,aQryParam)
	Local aArea	    := GetArea()
	Local cAliasQry := ""
	Local cQry 		:= ""
	Local nCont	    := 0
	Local nX	
	Local lAdiciona := .T.

	cAliasQry := GetNextAlias()

	cQry := " SELECT DXI.DXI_FILIAL,DXI.DXI_CODIGO,DXI.DXI_BLOCO,DXI.DXI_PSBRUT,DXI.DXI_PSLIQU,DXI.DXI_ETIQ,"
	cQry +=        "DXI.DXI_SAFRA,DXI.DXI_ETIQ,DXI.DXI_PESSAI,DXI.DXI_PSESTO,DXI.DXI_PESCHE, DXI.DXI_LOCAL,"
	cQry +=        "DXI.DXI_CODINE,N8O.N8O_CODCTR,N8O.N8O_IDENTR,N8O.N8O_IDREGR,NJM.NJM_DOCSER,NJM.NJM_DOCNUM "
	cQry += 	"FROM " + RetSqlName("DXI") + " DXI "
	cQry += 	"INNER JOIN  " + RetSqlName("DXD") + " DXD  "
	cQry += 		" ON (DXD.D_E_L_E_T_ =' '"
	cQry += 		" AND DXD.DXD_FILIAL='" + FwXfilial("DXD") + "'" 
	cQry += 		" AND DXD.DXD_SAFRA='" + oMldNJJ:GetValue( "NJJ_CODSAF" ) + "' "
	cQry += 		" AND DXD.DXD_CODIGO=DXI.DXI_BLOCO) "
	cQry += 	"INNER JOIN " + RetSqlName("N83") + " N83 "
	cQry += 		" ON (N83.D_E_L_E_T_= ' '"
	cQry += 		" AND N83.N83_FILIAL='" + FwXfilial("N83") + "'" 
	cQry += 		" AND N83.N83_SAFRA=DXD.DXD_SAFRA"
	cQry += 		" AND N83.N83_BLOCO=DXD.DXD_CODIGO)"
	cQry += 	"INNER JOIN " + RetSqlName("N8P") + " N8P  "
	cQry += 		" ON (N8P.D_E_L_E_T_=' '"
	cQry += 		" AND N8P.N8P_FILIAL= '" + FwXfilial("N8P") + "'" 
	cQry += 		" AND N8P.N8P_SAFRA=DXD.DXD_SAFRA"
	cQry += 		" AND N8P.N8P_BLOCO=DXD.DXD_CODIGO) "

	cQry += 	"LEFT OUTER JOIN "+ RetSqlName("NJM") +" NJM "	
	cQry += 		"ON (NJM.D_E_L_E_T_=' ' "
	cQry += 		"AND NJM.NJM_FILIAL='" + FwXfilial("NJM") + "' " 
	cQry += 		"AND NJM.NJM_CODROM='" + oMldNJJ:GetValue( "NJJ_CODROM" ) + "') " //Romaneio		

	cQry += 	"INNER JOIN " + RetSqlName("N8O") + " N8O"
	cQry += 		" ON (N8O.D_E_L_E_T_ = ' '"
	cQry += 		" AND N8O.N8O_FILIAL='" + FwXfilial("N8O") + "'" 
	cQry += 		" AND N8O.N8O_CODAUT='" + oMldN9E:GetValue( "N9E_CODAUT" ) + "'" 
	cQry += 		" AND N8O.N8O_ITEM='" + oMldN9E:GetValue( "N9E_ITEMAC" ) + "')" 
	cQry += 			" WHERE DXI.D_E_L_E_T_=' '"
	cQry += 		      " AND DXI.DXI_FILIAL='" + FwXfilial("DXI") + "'"
	cQry += 			  " AND DXI.DXI_SAFRA=N83.N83_SAFRA"
	cQry += 			  " AND DXI.DXI_BLOCO=N83.N83_BLOCO"
	cQry += 			  " AND DXI.DXI_STATUS IN ('30','70','80') " //70(take-up) e 80(global Futura) , 30 provisorio ate implementar status fardo no take-up

	cQry += 			  " AND N8O.N8O_CODINE='" + oMldN9E:GetValue( "N9E_CODINE" ) + "'"
	cQry += 			  " AND N8P.N8P_QTDAUT > 0"
	cQry += 			  " AND DXI.DXI_ETIQ NOT IN "
	cQry += 			  		" (SELECT N9D2.N9D_FARDO "
	cQry += 			  		" FROM " + RetSqlName("N9D") + " N9D2 "
	cQry += 			 		" WHERE N9D2.D_E_L_E_T_= ' '"
	cQry += 			  		" AND N9D2.N9D_FILIAL='" + FwXfilial("N9D") + "'"
	cQry += 			  		" AND DXI.DXI_SAFRA= N9D2.N9D_SAFRA"
	cQry += 			  		" AND N9D2.N9D_TIPMOV= '07'"
	cQry += 			  		" AND N9D2.N9D_STATUS= '1')"

	cQry += 			  " AND DXI.DXI_BLOCO NOT IN" 
	cQry += 			  		" (SELECT N9D3.N9D_BLOCO "
	cQry += 			  		" FROM " + RetSqlName("N9D") + " N9D3 "
	cQry += 			  		" WHERE N9D3.D_E_L_E_T_= ' '"
	cQry += 			  		" AND N9D3.N9D_FILIAL = '" + FwXfilial("N9D") + "'"
	cQry += 			  		" AND DXI.DXI_SAFRA=N9D3.N9D_SAFRA"
	cQry += 			  		" AND N9D3.N9D_TIPMOV='10'"
	cQry += 			  		" AND N9D3.N9D_STATUS='2')"

	cQry += "ORDER BY N8O.N8O_CODINE,DXI.DXI_BLOCO,DXI.DXI_ETIQ "

	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof()) 
		lAdiciona := .T.

		For nX := 1 To len(aFardN9D)
			If aFardN9D[nX][1] == (cAliasQry)->DXI_FILIAL .And. ;
			aFardN9D[nX][2] == (cAliasQry)->DXI_SAFRA .And. ;
			aFardN9D[nX][3] == (cAliasQry)->DXI_ETIQ
				lAdiciona := .F.
				exit
			EndIf
		Next nX

		If lAdiciona
			nCont++
			aAdd( aColsLoad, { "2",(cAliasQry)->DXI_FILIAL , (cAliasQry)->N9D_CODINE, (cAliasQry)->N9D_SAFRA ,;
			(cAliasQry)->N9D_BLOCO , (cAliasQry)->N9D_FARDO , (cAliasQry)->N9D_CODFAR,;
			(cAliasQry)->DXI_PSBRUT, (cAliasQry)->DXI_PSLIQU, (cAliasQry)->DXI_PESSAI,;
			(cAliasQry)->DXI_LOCAL , (cAliasQry)->DXI_ETIQ})								
		EndIf
		(cAliasQry)->(DbSkip())
	End

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return(aColsLoad)


Static Function LDFardIE(aColsLoad, aFardN9D, lAutorizacao,oMldNJJ,oMldN9D,oMldN9E,aQryParam)
	Local aArea	    := GetArea()
	Local cAliasQry := ""
	Local cQry 		:= ""
	Local nCont	    := 0
	Local nX	
	Local lNotIn	:= .F.
	Local aCodines	:= {}
	Local lAdiciona := .T.

	If .Not. lAutorizacao
		For nX := 1 to oMldN9E:Length()
			oMldN9E:GoLine(nX)
			If .Not. oMldN9E:IsDeleted()
				If .Not. Empty(oMldN9E:GetValue("N9E_CODINE"))
					aAdd( aCodines, oMldN9E:GetValue("N9E_CODINE"))
				EndIf
			EndIf
		Next nX
	EndIf

	cAliasQry := GetNextAlias()
	lNotIn	:= .F.

	cQry := " SELECT DXI.DXI_FILIAL,DXI.DXI_PSBRUT,DXI.DXI_PSLIQU,DXI.DXI_PESCHE,DXI.DXI_PESSAI,DXI.DXI_PESCER,DXI.DXI_LOCAL,DXI.DXI_ETIQ,"
	cQry +=         "N9D.N9D_FILIAL,N9D.N9D_CODINE,N9D.N9D_ITEMAC,N9D.N9D_SAFRA,N9D.N9D_BLOCO,"
	cQry +=         "N9D.N9D_FARDO,N9D.N9D_CODFAR,N9D.N9D_PESFIM,N9D.N9D_FILORG,N9D.N9D_CODCTR,"
	cQry +=         "N9D.N9D_ITEETG,N9D.N9D_ITEREF,N9D.N9D_PESINI,NJM.NJM_DOCSER,NJM.NJM_DOCNUM "
	cQry += 	"FROM " + RetSqlName("N9D") + " N9D "

	cQry += 	"LEFT OUTER JOIN "+ RetSqlName("NJM") +" NJM "
	cQry += 		"ON (NJM.D_E_L_E_T_=' ' "
	cQry += 		"AND NJM.NJM_FILIAL='" + FwXfilial("NJM") + "' "
	cQry += 		"AND NJM.NJM_CODROM='" + oMldNJJ:GetValue( "NJJ_CODROM" ) + "') " //Romaneio		
	cQry += 		"AND NJM.NJM_CODCTR=N9D.N9D_CODCTR AND NJM.NJM_ITEM=N9D.N9D_ITEETG AND NJM.NJM_SEQPRI=N9D.N9D_ITEREF "

	cQry += 	"INNER JOIN "+ RetSqlName("DXI") +" DXI "
	cQry += 		"ON (DXI.D_E_L_E_T_=' ' " 
	cQry += 		"AND DXI_FILIAL=N9D_FILIAL "
	cQry += 		"AND DXI_SAFRA=N9D_SAFRA "
	cQry += 		"AND DXI_ETIQ=N9D_FARDO "  
	cQry += 		"AND DXI_CODINE=N9D_CODINE "
	cQry += 		"AND DXI_STATUS='90') "
	cQry += 			"WHERE N9D.D_E_L_E_T_=' '"
	cQry += 			" AND N9D.N9D_FILIAL='" + FwXfilial("N9D") + "' "
	cQry += 			" AND N9D.N9D_CODINE='" + oMldN9E:GetValue( "N9E_CODINE" ) + "'" //Instrucao de Embarque
	cQry += 			" AND N9D.N9D_ITEETG='" + oMldN9E:GetValue( "N9E_ITEM" ) + "'" //Id Entrega
	cQry += 			" AND N9D.N9D_CODCTR='" + oMldN9E:GetValue( "N9E_CODCTR" ) + "'" //Contrato
	cQry += 			" AND N9D.N9D_ITEREF='" + oMldN9E:GetValue( "N9E_SEQPRI" ) + "'" //Regra
	cQry += 			" AND N9D.N9D_TIPMOV='04'" //Autorizacao de Carregamento
	cQry += 			" AND N9D.N9D_STATUS='2'" //1=Previsto;2=Ativo;3=Inativo

	//Se ja esta em outro romaneio, nao exibe
	cQry += 	" AND N9D.N9D_FARDO NOT IN "
	cQry += 			"(SELECT N9D2.N9D_FARDO FROM "+ RetSqlName("N9D") +" N9D2"
	cQry += 					" INNER JOIN " + RetSqlName("NJJ") + " NJJ"
	cQry +=		 				" ON (NJJ.D_E_L_E_T_ = ' '"
	cQry += 					" AND NJJ.NJJ_FILIAL='" + FwXfilial("NJJ") + "'"
	cQry += 					" AND N9D2.N9D_FILIAL='" + FwXfilial("N9D") + "'"
	cQry += 					" AND NJJ.NJJ_CODROM = N9D2.N9D_CODROM)"
	cQry += 						" WHERE N9D2.D_E_L_E_T_=' '"
	cQry += 				 			" AND N9D.N9D_SAFRA=N9D2.N9D_SAFRA"
	cQry += 							" AND (N9D2.N9D_TIPMOV='07' OR N9D2.N9D_TIPMOV='11')"
	cQry += 							" AND (N9D2.N9D_STATUS='1' OR N9D2.N9D_STATUS='2')"
	cQry += 							" AND NJM_SUBTIP NOT IN ('43','49') "
	
	If oMldNJJ:GetValue( "NJJ_TIPO" )= '4'
		cQry += 						" AND NJJ.NJJ_TIPO = '4') "
	ElseIf oMldNJJ:GetValue( "NJJ_TIPO" )= '2'
		cQry += 						" AND NJJ.NJJ_TIPO = '2') "
	Else
		cQry += 						")"
	EndIF

	//Nao posso mostrar os fardos da IE se esta IE teve algum fardo que ja foi autorizado
	cQry += 			" AND N9D.N9D_CODINE NOT IN "
	cQry += 					"(SELECT N9D3.N9D_CODINE FROM "+ RetSqlName("N9D") +" N9D3 WHERE "
	cQry += 						   " N9D3.N9D_SAFRA=N9D.N9D_SAFRA " //Safra
	cQry += 							" AND N9D3.N9D_CODINE='" + oMldN9E:GetValue( "N9E_CODINE" ) + "'" //Instrucao de Embarque
	cQry += 							" AND N9D3.N9D_ITEETG='" + oMldN9E:GetValue( "N9E_ITEM" ) + "'" //Id Entrega
	cQry += 							" AND N9D3.N9D_CODCTR='" + oMldN9E:GetValue( "N9E_CODCTR" ) + "'" //Contrato
	cQry += 							" AND N9D3.N9D_ITEREF='" + oMldN9E:GetValue( "N9E_SEQPRI" ) + "' " //Regra
	cQry += 							" AND N9D3.N9D_TIPMOV='10'" //Instrucao de embarque
	cQry += 							" AND N9D3.N9D_STATUS='2'" //1=Previsto;2=Ativo;3=Inativo
	cQry += 							" AND N9D3.D_E_L_E_T_=' ') "

	cQry += "ORDER BY N9D.N9D_CODINE,N9D.N9D_BLOCO,N9D.N9D_FARDO"

	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof()) 

		lAdiciona := .T.

		For nX := 1 To len(aFardN9D)
			If aFardN9D[nX][1] == (cAliasQry)->N9D_FILIAL .And. ;
			aFardN9D[nX][2] == (cAliasQry)->N9D_SAFRA .And. ;
			aFardN9D[nX][3] == (cAliasQry)->N9D_FARDO
				lAdiciona := .F.
				exit
			EndIf
		Next nX

		If lAdiciona
			_lInstEmb := .T.
			nCont++
			aAdd( aColsLoad, { "2",(cAliasQry)->DXI_FILIAL , (cAliasQry)->N9D_CODINE, (cAliasQry)->N9D_SAFRA ,;
			(cAliasQry)->N9D_BLOCO , (cAliasQry)->N9D_FARDO , (cAliasQry)->N9D_CODFAR,;
			(cAliasQry)->DXI_PSBRUT, (cAliasQry)->DXI_PSLIQU, (cAliasQry)->DXI_PESSAI,;
			(cAliasQry)->DXI_LOCAL , (cAliasQry)->DXI_ETIQ})
		EndIf						

		(cAliasQry)->(DbSkip())
	End
	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return(aColsLoad)


Static Function LDFardBlIE(aColsLoad, aFardN9D, lAutorizacao,oMldNJJ,oMldN9D,oMldN9E,aQryParam)
	Local aArea	    := GetArea()
	Local cAliasQry := ""
	Local cQry 		:= ""
	Local nCont	    := 0
	Local nX	
	Local aCodines	:= {}
	Local lAdiciona := .T.	

	If .Not. lAutorizacao
		For nX := 1 to oMldN9E:Length()
			oMldN9E:GoLine(nX)
			If .Not. oMldN9E:IsDeleted()
				If .Not. Empty(oMldN9E:GetValue("N9E_CODINE"))
					aAdd( aCodines, oMldN9E:GetValue("N9E_CODINE"))
				EndIf
			EndIf
		Next nX
	EndIf
	cAliasQry := GetNextAlias()

	cQry := " SELECT DXI.DXI_FILIAL,DXI.DXI_CODIGO,DXI.DXI_BLOCO,DXI.DXI_PSBRUT,DXI.DXI_PSLIQU,DXI.DXI_ETIQ,"
	cQry +=        "DXI.DXI_SAFRA,DXI.DXI_ETIQ,DXI.DXI_PESSAI,DXI.DXI_PSESTO,DXI.DXI_PESCHE,DXI.DXI_LOCAL,"
	cQry +=        "DXI.DXI_CODINE,N83.N83_CODCTR,N83.N83_ITEM,N83.N83_ITEREF,NJM.NJM_DOCSER,NJM.NJM_DOCNUM "
	cQry += 	"FROM " + RetSqlName("DXI") + " DXI "

	cQry += 	" INNER JOIN " + RetSqlName("DXD") + " DXD "
	cQry += 		" ON (DXD.D_E_L_E_T_ = ' '"
	cQry += 	" AND DXD.DXD_FILIAL='" + FwXfilial("DXD") + "'" 
	cQry += 	" AND DXD.DXD_SAFRA=DXI.DXI_SAFRA"
	cQry += 	" AND DXD.DXD_CODIGO=DXI.DXI_BLOCO) "

	cQry += 	"INNER JOIN  " + RetSqlName("N83") + " N83 "
	cQry += 		" ON (N83.D_E_L_E_T_=' '"
	cQry += 		" AND N83.N83_FILIAL='" + FwXfilial("N83") + "' " 
	cQry += 		" AND N83.N83_SAFRA=DXD.DXD_SAFRA"
	cQry += 		" AND N83.N83_BLOCO=DXD.DXD_CODIGO"
	cQry += 		" AND N83.N83_FILORG=DXI.DXI_FILIAL)"

	cQry += 	" INNER JOIN " + RetSqlName("DXP") + " DXP ON (DXP.D_E_L_E_T_ = '' " 
	cQry += 		" AND DXP_FILIAL='" + FwXfilial("DXP") + "' "
	cQry += 		" AND DXP_CODCTP=N83_CODCTR"
	cQry += 		" AND DXP_ITECAD=N83_ITEM"
	cQry += 		" AND DXP_CODIGO=DXI_CODRES)"

	cQry += 	"LEFT OUTER JOIN "+ RetSqlName("NJM") +" NJM "	
	cQry += 		"ON (NJM.D_E_L_E_T_=' ' "
	cQry += 		"AND NJM.NJM_FILIAL='" + FwXfilial("NJM") + "' "
	cQry += 		"AND NJM.NJM_CODROM='" + oMldNJJ:GetValue( "NJJ_CODROM" ) + "') " //Romaneio	
	cQry += 		"AND NJM.NJM_CODCTR=N83.N83_CODCTR AND NJM.NJM_ITEM = N83.N83_ITEM AND NJM.NJM_SEQPRI = N83.N83_ITEREF "	

	cQry += 			" WHERE DXI.D_E_L_E_T_ = ' '"
	cQry += 			  " AND DXI.DXI_FILIAL= '" + FwXfilial("DXI") + "'" 
	cQry += 			  " AND DXI.DXI_SAFRA=N83.N83_SAFRA"
	cQry += 			  " AND DXI.DXI_BLOCO=N83.N83_BLOCO"
	cQry += 			  " AND DXI.DXI_STATUS IN ('30','70','80') " //70(take-up) e 80(global Futura) , 30 provisorio ate implementar status fardo no take-up
	cQry += 			  " AND N83.N83_CODINE='" + oMldN9E:GetValue( "N9E_CODINE" ) + "' "	
	cQry += 			  " AND N83.N83_ITEM='" + oMldN9E:GetValue( "N9E_ITEM" ) + "' "
	cQry += 			  " AND N83.N83_FRDMAR = '2'"
	cQry += 			  " AND DXI.DXI_CODINE = ''"
	cQry += 			  " AND DXI.DXI_ETIQ NOT IN "
	cQry += 					" (SELECT N9D2.N9D_FARDO "
	cQry += 						" FROM " + RetSqlName("N9D") + " N9D2 " 
	cQry += 						" WHERE N9D2.D_E_L_E_T_ = ' '"
	cQry += 						   " AND DXI.DXI_SAFRA=N9D2.N9D_SAFRA"
	cQry += 						   " AND N9D2.N9D_TIPMOV='07'"
	cQry += 						   " AND N9D2.N9D_STATUS='1') "

	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof()) 

		lAdiciona := .T.

		For nX := 1 To len(aFardN9D)
			If aFardN9D[nX][1] == (cAliasQry)->DXI_FILIAL .And. ;
			aFardN9D[nX][2] == (cAliasQry)->DXI_SAFRA .And. ;
			aFardN9D[nX][3] == (cAliasQry)->DXI_ETIQ
				lAdiciona := .F.
				exit
			EndIf
		Next nX

		If lAdiciona
			nCont++
			aAdd( aColsLoad, { "2",(cAliasQry)->DXI_FILIAL , (cAliasQry)->N9D_CODINE, (cAliasQry)->N9D_SAFRA ,;
			(cAliasQry)->N9D_BLOCO , (cAliasQry)->N9D_FARDO , (cAliasQry)->N9D_CODFAR,;
			(cAliasQry)->DXI_PSBRUT, (cAliasQry)->DXI_PSLIQU, (cAliasQry)->DXI_PESSAI,;
			(cAliasQry)->DXI_LOCAL , (cAliasQry)->DXI_ETIQ})							
		EndIf
		(cAliasQry)->(DbSkip())
	End

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return(aColsLoad)


/*/{Protheus.doc} LoadDetail
// Função responsável por buscar as informações que formam o cabelho da requisição
@author brunosilva
@since 24/07/2018
@version 1.0
@return aColsDetail, array, detalhes da requisição
@param aQryParam, array, Array com os parâmetros
@type function
/*/
Static Function LoadDetail(aQryParam)
	Local cFilPack 		:= aQryParam[1]
	Local cNumberPack 	:= aQryParam[2]	
	Local aColsDetail	:= {}
	Local aArea			:= GetArea()
	Local cPlaca		:= ""
	Local cCodIne		:= ""
	Local nCapac		:= 0
	Local nLimMax		:= 0
	Local nTotFar		:= 0	

	cPlaca 	:= POSICIONE("NJJ",1,PadR(cFilPack,TamSX3("NJJ_FILIAL")[1])+cNumberPack,"NJJ_PLACA")
	cCodIne := POSICIONE("N9E",4,PadR(cFilPack,TamSX3("N9E_FILIAL")[1])+cNumberPack,"N9E_CODINE")
	nCapac  := POSICIONE("DA3",3,FWxFilial('DA3')+cPlaca,"DA3_CAPACM")	
	nLimMax := POSICIONE("N7Q",1,FWxFilial('N7Q')+cCodIne,"N7Q_LIMMAX")
	nTotFar := POSICIONE("N7Q",1,FWxFilial('N7Q')+cCodIne,"N7Q_TOTFAR")

	aAdd(aColsDetail,cFilPack)
	aAdd(aColsDetail,cNumberPack)
	aAdd(aColsDetail,cCodIne)
	aAdd(aColsDetail,cPlaca)
	aAdd(aColsDetail,nCapac)
	aAdd(aColsDetail,nLimMax)
	aAdd(aColsDetail,nTotFar)	

	RestArea(aArea)
Return (aColsDetail)


/*/{Protheus.doc} LoadBlocos
// Responsável por buscar os dados dos blocos existentes que contêm os fardinhos disponíveis para vínculo.
@author brunosilva
@since 24/07/2018
@version 1.0
@return aColsBlc, array, dados dos blocos.
@param aQryParam, array, descricao
@param aColsLoad, array, array de fardinhos.
@type function
/*/
Static Function LoadBlocos(aQryParam,aColsLoad)
	Local aColsBlc		:= {}
	Local cAuxBlc		:= ""
	Local cAuxLocal		:= ""
	Local nX 			:= 2
	Local nQtdFar		:= 0
	Local nAuxPeso		:= 0

	//peso bruto eu tenho na N7Q

	if !(EMPTY(aColsLoad))
		//PEGO O BLOCO DO PRIMEIRO REGISTRO
		cAuxBlc		:= aColsLoad[1][5]	//BLOCO
		nAuxPeso	:= aColsLoad[1][8]	//PESO BRUTO  
		cAuxLocal   := aColsLoad[1][11]	//LOCAL
		nQtdFar++

		aAdd(aColsBlc,{cAuxBlc,cAuxLocal,nAuxPeso,nQtdFar})

		For nX := 2 to Len(aColsLoad)
			if(aColsLoad[nX][5]) != aColsBlc[Len(aColsBlc)][1]
				cAuxBlc		:= aColsLoad[nX][5]	 //BLOCO		aAdd(aAuxBlc,aColsLoad[nX][5])   //BLOCO
				nAuxPeso	:= aColsLoad[nX][8]	 //PESO BRUTO   aAdd(aAuxPeso,aColsLoad[nX][8])  //PESO BRUTO 
				cAuxLocal   := aColsLoad[nX][11] //LOCAL	    aAdd(aAuxPeso,aColsLoad[nX][11]) //LOCAL	

				nQtdFar := 1 //Primeiro fardinho do bloco

				aAdd(aColsBlc,{cAuxBlc,cAuxLocal,nAuxPeso,nQtdFar})
			else
				//soma peso bruto fardinho que pertence ao bloco
				aColsBlc[Len(aColsBlc)][3] += aColsLoad[nX][8]
				aColsBlc[Len(aColsBlc)][4] += 1 //Mais um fardinho
			endIf
		next nX
	endIf

Return (aColsBlc)


WSMETHOD POST loadBale WSREST UBAW10API
	Local oResponse 	:= JsonObject():New()
    Local oRequest  	:= Nil
     
    Local cContent		:= ""
 	 	
	Local lPost			:= .F.
	
 	//--Variaveis de controle Json
 	Local cFilRom := ""
 	Local cCodRom := ""
 	Local cCodIne := ""
 	Local cSafra  := ""
 	Local cBloco  := ""
 	Local cEtiqu  := ""
 	Local cCodOpe  := "" //Codigo da Operação (1-Inclusão,2-Exclusão)
 	
 	//--Variavies de controle para comit 	
 	Local aCodRom  := {} // armazena todos romaneios que foram afetados pelo processo 	
 	Local nLinha   := 0 	 	 	
    Local aSincs   := {}
    Local nPosSinc := 0
    Local cCodUn   := ""
    Local cSeqFrd  := ""
    Local aErros   := {} 
    Local cCodErro := ""
    Local cErro	   := ""
    Local lErro	   := .F.
 	
	::SetContentType("application/json")
	cContent := ::GetContent()
	FWJsonDeserialize(cContent,@oRequest)
	
	BEGIN Transaction
	
		For nLinha := 1 TO Len (oRequest["Item"])
							
			cFilRom := PadR(oRequest["Item"][nLinha]["BRANCH"]		 		 ,TamSX3("NJJ_FILIAL")[1])	//--Filial
			cCodRom := PadR(oRequest["Item"][nLinha]["CODE"]	 		     ,TamSX3("NJJ_CODROM")[1])	//--Romaneio
			cCodIne := PadR(oRequest["Item"][nLinha]["SHIPPINGINSTRUCTION"]  ,TamSX3("N9D_CODINE")[1])	//--Instrução de Embarque
			cSafra  := PadR(oRequest["Item"][nLinha]["CROP"] 				 ,TamSX3("NJJ_CODSAF")[1])	//--Safra
			cBloco  := PadR(oRequest["Item"][nLinha]["PACK"] 				 ,TamSX3("DXD_CODIGO")[1])	//--Bloco			
			cEtiqu  := PadR(oRequest["Item"][nLinha]["BALETAG"]			 	 ,TamSX3("DXI_ETIQ")[1] )	//--Etiqueta/Fardos
			cCodOpe := IIf(oRequest["Item"][nLinha]["OPERATION"] == NIL ,1, oRequest["Item"][nLinha]["OPERATION"])  // Operação
			
			// Só realiza a inclusão da sincronização quando modificar o Romaneio + IE
			nPosSinc := AScan(aSincs, {|x| AllTrim(x[1]) == AllTrim(cFilRom+cCodRom+cCodIne)})
			
			If nPosSinc == 0
				cCodUn := cFilRom + ";" + cCodRom + ";" + cCodIne
			
				// Inclusão da sincronização
				oChvSinc := UBIncSinc("7","5","1",cCodUn,,,,,,,,)
				cSeqFrd  := ""
												
				cFilSinc  := oChvSinc[1]
				cDataSinc := oChvSinc[2]
				cHoraSinc := oChvSinc[3]
				cSeqSinc  := oChvSinc[4]
											
				lErro  := .F.
				aErros := {}
				
				DbSelectArea("NJJ")
				NJJ->(DbSetOrder(1)) //NJJ_FILIAL+NJJ_CODROM
				If NJJ->(DbSeek(cFilRom+cCodRom))				
				
					If !NJJ->NJJ_STATUS $ "0|1"
				
						cCodErro := "00002"
						cErro 	 := "Status do romaneio não permite realizar esta operação."
						lErro	 := .T.
						
						Aadd(aErros, {cCodErro, cErro})
						
						// Inclusão do erro de sincronização na tabela NC4
						UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro,"5",cFilRom,cFilRom+cCodRom)											
					EndIf 
				Else					
					cCodErro := "00001"
					cErro 	 := "Não foi encontrado romaneio."
					lErro	 := .T.
					
					Aadd(aErros, {cCodErro, cErro})
					
					// Inclusão do erro de sincronização na tabela NC4
					UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro,"5",cFilRom, cFilRom+cCodRom)													
				EndIf
			
				DbSelectArea("N7Q")
				N7Q->(DbSetOrder(1)) //N7Q_FILIAL+N7Q_CODINE
				If !N7Q->(DbSeek(FWxFilial("N7Q")+cCodIne))
					cCodErro := "00003"
					cErro 	 := "Não foi encontrado instrução de embarque."
					lErro	 := .T.
					
					Aadd(aErros, {cCodErro, cErro})
					
					// Inclusão do erro de sincronização na tabela NC4
					UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro,"6",FWxFilial("N7Q"),FWxFilial("N7Q")+cCodIne)									
				EndIf
				
				Aadd(aSincs, {cFilRom+cCodRom+cCodIne, oChvSinc, lErro})
			Else				
				oChvSinc := aSincs[nPosSinc][2]
				lErro	 := aSincs[nPosSinc][3]
			EndIf
			
			cFilSinc  := oChvSinc[1]
			cDataSinc := oChvSinc[2]
			cHoraSinc := oChvSinc[3]
			cSeqSinc  := oChvSinc[4]   
			
			// Inclusão dos fardos na sincronização
			UBIncFrd(cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, @cSeqFrd, cSafra, cEtiqu, cBloco, cCodOpe)
			
			If !lErro					
				// Realiza o vinculo / desvinculo dos fardos no romaneio		
				UBW10CARG(cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, cFilRom, cCodRom, cCodIne, cSafra, cEtiqu, cBloco, cCodOpe, @aCodRom, @aErros)
			EndIf
			
			If Len(aErros) > 0
				UBAltStSin(cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, "2")
			EndIf
						
		Next nLinha		
		
		If Len(aErros) == 0
			// Realiza as alterações no romaneio de acordo com os fardos vinculados / desvinculados
			UBW10ALTR(aCodRom)
		EndIf
				
	END Transaction
	
	If Len(aErros) > 0
		lPost := .F.
		
		cErro := "Ocorreu erro de negócio no carregamento."
		
		SetRestFault(400, EncodeUTF8(cErro))
	Else
		lPost := .T.
					
		oResponse["content"] := JsonObject():New()	
    	oResponse["content"]["Message"]	:= "Carregamento realizado com sucesso."
		
		cRetorno := EncodeUTF8(FWJsonSerialize(oResponse, .F., .F., .T.))    	
	    
	    ::SetResponse(cRetorno)
	EndIf	

	N9D->(DbCloseArea())
	DXI->(DbCloseArea())
	NJJ->(DbCloseArea())

Return (lPost)

/*{Protheus.doc} 
Função para copiar o registro do movimento do fardo anterior

@sample   	UBW10CPFRD()
@param		cFilFrd - Filial do fardo
@param		cSafra  - Safra do fardo
@param		cEtiq   - Etiqueta do fardo
@return   	"DXI_ROMSAI" - Salvar no campo DXI_ROMSAI ; "DXI_ROMFLO" - Salvar no campo DXI_ROMFLO
@author   	francisco.nunes
@since    	09/01/2019
@version  	P12
*/
Static Function UBW10CPFRD(cFilFrd, cSafra, cEtiq)
	
	Local cAliasQry := GetNextAlias()
	Local aStruct	:= {}
	Local nItStr	:= 0
	Local cQry		:= ""
	Local dDataCpo	:= ""
	
	aStruct := N9D->(DbStruct()) // Obtém a estrutura
	
	cQry := " SELECT N9D.* "
	cQry += "   FROM " + RetSqlName("N9D") + " N9D "
	cQry += "  WHERE N9D.N9D_FILIAL = '" + cFilFrd + "' "   
	cQry += "    AND N9D.N9D_SAFRA  = '" + cSafra + "' "  
	cQry += "    AND N9D.N9D_FARDO  = '" + cEtiq + "' "
	cQry += "    AND N9D.D_E_L_E_T_ <> '*' "
	cQry += "    AND N9D_IDMOV IN (SELECT MAX(N9D2.N9D_IDMOV) "				
	cQry += "	                     FROM " + RetSqlName("N9D") + " N9D2 "
	cQry += "	                    WHERE N9D2.N9D_FILIAL = N9D.N9D_FILIAL "
	cQry += "	                      AND N9D2.N9D_SAFRA  = N9D.N9D_SAFRA "
	cQry += "		                  AND N9D2.N9D_FARDO  = N9D.N9D_FARDO AND N9D2.D_E_L_E_T_ <> '*') "	
	
	cQry := ChangeQuery(cQry)	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.F.,.T.)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	
	If (cAliasQry)->(!Eof())												
		For nItStr := 1 To Len(aStruct)
					
			If AllTrim(aStruct[nItStr][1]) == "N9D_IDMOV"	                    		
				N9D->N9D_IDMOV := Soma1((cAliasQry)->N9D_IDMOV)
			Else
				If .Not. Empty((cAliasQry)->&(AllTrim(aStruct[nItStr][1])))
					If TamSX3(aStruct[nItStr][1])[3] == 'D'
						dDataCpo := STOD((cAliasQry)->&(AllTrim(aStruct[nItStr][1])))
						
						&("N9D->"+aStruct[nItStr][1]) := dDataCpo
					Else
						&("N9D->"+aStruct[nItStr][1]) := (cAliasQry)->&(AllTrim(aStruct[nItStr][1]))
					EndIF
				EndIf
			EndIf
		Next nItStr
	EndIf	
																	 	
	(cAliasQry)->(DbCloseArea())

Return .T.

/*{Protheus.doc} 
Função para definir em qual campo na DXI será salvo o codigo do romaneio

@sample   	UBW10CPRM()
@param		cFilRom - Filial do Romaneio
@param		cCodRom - Codigo do Romaneio
@return   	"DXI_ROMSAI" - Salvar no campo DXI_ROMSAI ; "DXI_ROMFLO" - Salvar no campo DXI_ROMFLO
@author   	francisco.nunes
@since    	09/01/2019
@version  	P12
*/
Static Function UBW10CPRM(cFilRom, cCodRom)

	Local aAreaNJR 	:= NJR->(GetArea())	
	Local aAreaN9E 	:= N9E->(GetArea())	
	Local aAreaN7S 	:= N7S->(GetArea())
	Local aAreaN9A 	:= N9A->(GetArea())	
	Local cCampo	:= 'DXI_ROMFLO'	
	
	DbSelectArea("N9E")
	N9E->(DbSetOrder(1)) //N9E_FILIAL+N9E_CODROM+N9E_SEQUEN
	If N9E->(DbSeek(cFilRom+cCodRom))
						
		//IE x Entrega
		DbSelectArea("N7S") 
		N7S->(DbSetOrder(1)) //N7S_FILIAL+N7S_CODINE+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI
		If N7S->(DbSeek(N9E->N9E_FILIE+N9E->N9E_CODINE))		
						
			//Contratos
			DbSelectArea("NJR") 
			NJR->(DbSetOrder(1)) //NJR_FILIAL+NJR_CODCTR
			If NJR->(DbSeek(N7S->N7S_FILIAL+N7S->N7S_CODCTR)) 
				
				// Contrato de venda mercado interno
				If NJR->NJR_TIPO == '2' .AND. NJR->NJR_TIPMER == '1' 					
					
					DbSelectArea("N9A") 
					N9A->(DbSetOrder(1)) //N9A_FILIAL+N9A_CODCTR+N9A_ITEM+N9A_SEQPRI
					If N9A->(DbSeek(N7S->N7S_FILIAL + N7S->N7S_CODCTR + N7S->N7S_ITEM + N7S->N7S_SEQPRI))
						
						// Caso não seja venda futura ou triangular (Caso seja venda simples)
						If N9A->N9A_OPEFUT = '2' .AND. N9A->N9A_OPETRI = '2'
							cCampo := 'DXI_ROMSAI'
						EndIf					
					EndIf	
								    				
				EndIf
			EndIf
			
		EndIf
	EndIf

	RestArea(aAreaN9E)
	RestArea(aAreaN7S)
	RestArea(aAreaNJR)
	RestArea(aAreaN9A)
	
Return cCampo

/*{Protheus.doc} 
Função para realizar o vinculo dos fardos no carregamento

@sample   	UBW10CARG()
@param 		cFilSinc, character, Filial da sincronização
@param 		cDataSinc, character, Data da sincronização
@param 		cHoraSinc, character, Hora da sincronização
@param 		cSeqSinc, character, Sequencia da sincronização
@param		cFilRom - Filial do Romaneio
@param		cCodRom - Codigo do Romaneio
@param		cCodIne - Codigo da Instrução de Embarque
@param		cSafra  - Safra do fardo a ser vinculado
@param		cEtiqu  - Etiqueta do fardo a ser vinculado
@param		cBloco  - Bloco do fardo a ser vinculado
@param		cCodOpe - Tipo de Operação (1=Vincular;2=Desvincular)
@param	 	aCodRom - Array com os romaneios alterados (Por referência)
@param	 	aErros - Array com erros encontrados (Por referência)
@author   	francisco.nunes
@since    	15/01/2019
@version  	P12
*/
Function UBW10CARG(cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, cFilRom, cCodRom, cCodIne, cSafra, cEtiqu, cBloco, cCodOpe, aCodRom, aErros)

	Local nMov	    := 0
 	Local cTipMov   := ""
 	Local aCodRom   := {} // armazena todos romaneios que foram afetados pelo processo
 	Local nPos      := 0
 	Local cFrdMar   := "" 
 	Local nQtdBlc   := 0
 	Local cAliasN9D := ""
 	Local cQueryN9D	:= ""
 	Local lAtualiz  := .F.
 	
	DbSelectArea("NJJ")
	NJJ->(DbSetOrder(1)) //NJJ_FILIAL+NJJ_CODROM
	If NJJ->(DbSeek(cFilRom+cCodRom))	
					
		DbSelectArea("DXI")
		DXI->(DbSetOrder(1)) //DXI_FILIAL+DXI_SAFRA+DXI_ETIQ
		If !DXI->(DbSeek(cFilRom+cSafra+cEtiqu))
			
			cCodErro := "00004"
			cErro 	 := "Não foi encontrado fardo."
			
			Aadd(aErros, {cCodErro, cErro})
			
			// Inclusão do erro de sincronização na tabela NC4
			UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro, "1", cFilRom, cFilRom+cSafra+cEtiqu)
			
			Return .F.
		EndIf
		
		DbSelectArea("DXD")
		DXD->(DbSetOrder(1)) //DXD_FILIAL+DXD_SAFRA+DXD_CODIGO
		If !DXD->(DbSeek(cFilRom+cSafra+cBloco))
			cCodErro := "00005"
			cErro 	 := "Não foi encontrado bloco."
			
			Aadd(aErros, {cCodErro, cErro})
			
			// Inclusão do erro de sincronização na tabela NC4
			UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro,"2",cFilRom, cFilRom+cSafra+cBloco)
			
			Return .F.			
		EndIf			
		
		cFrdMar := POSICIONE("N83",2,FwxFilial("N83")+cCodIne+cFilRom+cBloco,"N83_FRDMAR")				
		
		If cCodOpe == '1' .AND. cFrdMar == '2'
			
			nQtdBlc := POSICIONE("N83",2,FwxFilial("N83")+cCodIne+cFilRom+cBloco,"N83_QUANT")
			
			cAliasN9D := GetNextAlias()
			cQueryN9D := " SELECT COUNT(*) AS QTDFRD "
			cQueryN9D += "   FROM " + RetSqlName("N9D") + " N9D "
		    cQueryN9D += "  WHERE N9D.N9D_FILIAL = '" + cFilRom + "' "
			cQueryN9D += "	   AND N9D.N9D_SAFRA = '" + cSafra + "' "
			cQueryN9D += "	   AND N9D.N9D_BLOCO = '" + cBloco + "' "
		    cQueryN9D += "    AND N9D.N9D_FILORG = '" + FWxFilial("N7Q") + "' "
		    cQueryN9D += "    AND N9D.N9D_CODINE = '" + cCodIne + "' "
		    cQueryN9D += "    AND N9D.N9D_TIPMOV = '04' "
		    cQueryN9D += "    AND N9D.N9D_STATUS <> '3' "
		    cQueryN9D += "    AND N9D.D_E_L_E_T_ <> '*' "
		    
		    cQueryN9D := ChangeQuery(cQueryN9D)
		    MPSysOpenQuery(cQueryN9D, cAliasN9D)
		    
		    If (cAliasN9D)->(!Eof())
		    
		    	If (cAliasN9D)->QTDFRD > 0 .AND. ((cAliasN9D)->QTDFRD + 1 > nQtdBlc) 
		    	
		    		cChave := cCodIne + ";" + cFilRom + ";" + cSafra + ";" + cBloco
		    	
		    		cDesInE := POSICIONE("N7Q",1,FwxFilial("N7Q")+cCodIne,"N7Q_DESINE")
		    		
		    		cCodErro := "00006"
					cErro 	 := "O vinculo do fardo ultrapassará a quantidade definida no bloco " + cBloco
					cErro    += " para Instrução de Embarque " + cDesInE
					
					Aadd(aErros, {cCodErro, cErro})
					
					// Inclusão do erro de sincronização na tabela NC4
					UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro,,FwxFilial("N7Q"), cChave)
					
					Return .F.		    		
		    	EndIf		    	
		    EndIf
		    
		    (cAliasN9D)->(DbCloseArea())	
		EndIf		
		
		lAtualiz := .F.
		
		For nMov := 1 To 2
		
			If cFrdMar == '1'
				nMov := 2 // Não adiciona/exclui tipo '04' - Instrução de Embarque
			EndIf
			
			cTipMov := IIf(nMov == 1, "04", "07")
		
			DbSelectArea("N9D")
			N9D->(DbSetOrder(5)) //N9D_FILIAL+N9D_SAFRA+N9D_FARDO+N9D_TIPMOV+N9D_STATUS
			If .NOT. N9D->(DbSeek(cFilRom + cSafra + cEtiqu + cTipMov))
			
				 //Criação do(s) movimento(s)						 
				 If cCodOpe == '1' .AND. RecLock("N9D", .T.)
				 
				 	lAtualiz := .T.
				 	
				 	UBW10CPFRD(cFilRom, cSafra, cEtiqu)
				 	
				 	N9D->N9D_TIPMOV := cTipMov
				 	N9D->N9D_DATA 	:= dDatabase
				 	N9D->N9D_CODINE := cCodIne
				 	N9D->N9D_CODROM := cCodRom
				 							 	
				 	If cTipMov == "04"	
				 		N9D->N9D_FILORG := FWxFilial("N7Q")						 		
				 		N9D->N9D_STATUS := '2'						 		
				 	Else
				 		N9D->N9D_FILORG := cFilRom
				 		N9D->N9D_STATUS := '1'					 		
				 		N9D->N9D_LOCAL  := NJJ->NJJ_LOCAL
						N9D->N9D_ENTLOC := NJJ->NJJ_CODENT
						N9D->N9D_LOJLOC := NJJ->NJJ_LOJENT
				 	EndIf
				 	
				 	N9D->(MsUnLock())
				 							 						 
				 EndIf
			
			ElseIf cCodOpe == '2'
			
				//Exclusão do(s) movimento(s)
				If RecLock("N9D", .F.)
					
					lAtualiz := .T.
				
					N9D->(DbDelete())
					N9D->(MsUnLock())
				EndIf						 
		    EndIf																									
							
		Next nMov
		
		If lAtualiz		
		
			DbSelectArea("DXI")
			DXI->(DbSetOrder(1)) //DXI_FILIAL+DXI_SAFRA+DXI_ETIQ
			If DXI->(DbSeek(cFilRom+cSafra+cEtiqu))			
				
				// Atualiza o DXI_STATUS				
				If cCodOpe == '1'
					AGRXFNSF(1 , "RomaneioVin")
				Else
					AGRXFNSF(2 , "RomaneioVin")
				EndIf
				
				cCampoDXI := IIF(NJJ->NJJ_TIPO == "4", UBW10CPRM(cFilRom, cCodRom), "DXI_ROMFLO")
				
				// Atualiza os campos de IE e Romaneio
				If RecLock("DXI", .F.)
				
					If cFrdMar == '2' 
						DXI->DXI_CODINE  := IIF(cCodOpe == '1',cCodIne, '')
					EndIf
					
					&("DXI->"+cCampoDXI) := IIF(cCodOpe == '1',cCodRom, '')							
					DXI->(MsUnLock())
				EndIf					
																				
			EndIf					

			nPos := aScan(aCodRom, {|x| x ==  cFilRom + cCodRom})
			
			If nPos == 0
				aAdd(aCodRom, cFilRom + cCodRom)
			EndIf
		EndIf			
	EndIf
	
Return .T.	

/*{Protheus.doc} 
Função para realizar as alterações no(s) romaneio(s) de acordo com os fardos vinculados/desvinculados

@sample   	UBW10ALTR()
@param	 	aCodRom - Array com os romaneios alterados
@author   	francisco.nunes
@since    	15/01/2019
@version  	P12
*/
Function UBW10ALTR(aCodRom)
	
	Local nEmblg   := 0
	Local cLotFar  := ""
	Local nLinha   := 0
	Local nTotal   := 0
	Local nQtdAux  := 0
	Local nQtdFco  := 0
	Local nPerDiv  := 0
	Local nDecPeso := SuperGetMV("MV_OGDECPS",,0)

	//Refaz a regra de 	NJJ_PSLIQU e NJJ_PESO3 para cada romaneio afetado pelo processo
	DbselectArea("NJJ")
	NJJ->(DbSetOrder(1)) //NJJ_FILIAL+NJJ_CODROM
	For nLinha := 1 TO Len (aCodRom)
		nEmblg  := 0
		cLotFar := ""
		
		If DbSeek(aCodRom[nLinha])
			
			DbSelectArea("N9D")
			N9D->(DbSetOrder(6)) //N9D_FILORG+N9D_CODROM+N9D_TIPMOV 
			DbSeek(aCodRom[nLinha]+'07')
			While N9D->(!Eof()) .AND. N9D->N9D_FILORG+N9D->N9D_CODROM+N9D->N9D_TIPMOV == aCodRom[nLinha]+'07'
			
				nEmblg  += POSICIONE("DXI",1,N9D->N9D_FILIAL+N9D->N9D_SAFRA+N9D->N9D_FARDO,"DXI_PSTARA")
				cLotFar := POSICIONE("DXI",1,N9D->N9D_FILIAL+N9D->N9D_SAFRA+N9D->N9D_FARDO,"DXI_LOTE")
				
				N9D->(DbSkip())
			EndDo
			
			If RecLock("NJJ", .F.)
				NJJ->NJJ_PESEMB := nEmblg
				NJJ->(MsUnLock())
			EndIf
			
			//sera atualizado os valores liquido e peso3 do romaneio conforme a regra manual do AGRX500F
			If NJJ->NJJ_PSLIQU <> 0
				nTotal := NJJ->NJJ_PSSUBT - (NJJ->NJJ_PSDESC + NJJ->NJJ_PSEXTR + nEmblg)
				
				If RecLock("NJJ", .F.)
					NJJ->NJJ_PSLIQU := nTotal
					NJJ->NJJ_PESO3  := nTotal
					NJJ->(MsUnLock())
				EndIf
			EndIf
			
			DbSelectArea("NJM")
			NJM->(DbSetOrder(1)) //NJM_FILIAL+NJM_CODROM+NJM_ITEROM
			If NJM->(DbSeek(NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM))
				While NJM->(!Eof()) .AND. NJM->NJM_FILIAL+NJM->NJM_CODROM == NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM
									
					nQtdAux := Round((NJJ->NJJ_PESO3 * (NJM->NJM_PERDIV / 100)), nDecPeso)
					nQtdFco += nQtdAux
					nPerDiv += NJM->NJM_PERDIV
					
					If RecLock("NJM", .F.)
						NJM->NJM_QTDFCO  := nQtdAux
						NJM->NJM_LOTCTL  := cLotFar
						NJM->(MsUnLock())
					EndIf
					
					NJM->(DbSkip())
				EndDo
			EndIf
			
			If NJJ->NJJ_PSLIQU <> nQtdFco
				DbSelectArea("NJM")
				NJM->(DbSetOrder(1)) //NJM_FILIAL+NJM_CODROM+NJM_ITEROM
				If NJM->(DbSeek(NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM))
					If RecLock("NJM", .F.)
						NJM->NJM_QTDFCO := NJM->NJM_QTDFCO + NJJ->NJJ_PESO3 - nQtdFco
						NJM->(MsUnLock())
					EndIf
				EndIf
			EndIf
			
		EndIf
	Next nLinha
	
Return .T.	

/*{Protheus.doc} UBW10CERR
Verificar se os erros relacionados ao carregamento foram corrigidos
Caso sejam, será modificado o status do erro da sincronização para corrigido

@author francisco.nunes
@since 30/07/2018
@param: cFilNC4, character, Filial da sincronização
@param: cDatNC4, character, Data da sincronização
@param: cHoraNC4, character, Hora da sincronização
@param: cSeqNC4, character, Sequencia da sincronização
@param: cCodUn, character, Código único
@return: lErroSinc, boolean, .T. - Possui erro de sincronismo; .F. - Não possui erro de sincronismo
@type function
*/
Function UBW10CERR(cFilNC4, cDatNC4, cHoraNC4, cSeqNC4)
	
	Local lErroSinc := .F.
	Local cDatNC41  := ""
	Local cDatNC42  := ""
	Local aCmps		:= {}
	Local cFilIE    := ""
	Local cCodIne   := ""
	Local cFilRom   := ""
	Local cSafra    := ""
	Local cBloco    := ""
	Local cFrdMar	:= ""
	Local nQtdBlc	:= 0
	Local cQueryN9D	:= ""
	Local cAliasN9D := ""
	
	cDatNC41 := Year2Str(Year(cDatNC4)) + Month2Str(Month(cDatNC4)) + Day2Str(Day(cDatNC4))
	
	DbSelectArea("NC4")
	NC4->(DbSetOrder(1)) // NC4_FILIAL+NC4_DATA+NC4_HORA+NC4_SEQSIN
	If NC4->(DbSeek(cFilNC4+cDatNC41+cHoraNC4+cSeqNC4))
		While !NC4->(Eof()) 
		
			cDatNC42 := Year2Str(Year(NC4->NC4_DATA)) + Month2Str(Month(NC4->NC4_DATA)) + Day2Str(Day(NC4->NC4_DATA))
		
			If NC4->NC4_FILIAL+cDatNC42+NC4->NC4_HORA+NC4->NC4_SEQSIN != cFilNC4+cDatNC41+cHoraNC4+cSeqNC4
				NC4->(DbSkip())
				LOOP
			ElseIf NC4->NC4_STATUS != "1"
				NC4->(DbSkip())
				LOOP
			EndIf
		
			If Alltrim(NC4->NC4_CODERR) == "00001" // Não foi encontrado romaneio
			
				DbSelectArea("NJJ")
				NJJ->(DbSetOrder(1)) //NJJ_FILIAL+NJJ_CODROM
				If NJJ->(DbSeek(NC4->NC4_CODBAR))
				
					If RecLock("NC4", .F.)
						NC4->NC4_STATUS := "2"
						NC4->NC4_DATATU := dDatabase
						NC4->NC4_HORATU := Time()
						NC4->(MsUnlock())
					EndIf
				EndIf
				
			ElseIf Alltrim(NC4->NC4_CODERR) == "00002" // Status do romaneio não permite realizar esta operação
				
				DbSelectArea("NJJ")
				NJJ->(DbSetOrder(1)) //NJJ_FILIAL+NJJ_CODROM
				If NJJ->(DbSeek(NC4->NC4_CODBAR))
				
					If NJJ->NJJ_STATUS $ "0|1"				
						If RecLock("NC4", .F.)
							NC4->NC4_STATUS := "2"
							NC4->NC4_DATATU := dDatabase
							NC4->NC4_HORATU := Time()
							NC4->(MsUnlock())
						EndIf
					EndIf
				EndIf
				
			ElseIf Alltrim(NC4->NC4_CODERR) == "00003" // Não foi encontrado instrução de embarque
				
				DbSelectArea("N7Q")
				N7Q->(DbSetOrder(1)) //N7Q_FILIAL+N7Q_CODINE
				If N7Q->(DbSeek(NC4->NC4_CODBAR))
				
					If RecLock("NC4", .F.)
						NC4->NC4_STATUS := "2"
						NC4->NC4_DATATU := dDatabase
						NC4->NC4_HORATU := Time()
						NC4->(MsUnlock())
					EndIf				
				EndIf
				
			ElseIf Alltrim(NC4->NC4_CODERR) == "00004" // Não foi encontrado fardo
				
				DbSelectArea("DXI")
				DXI->(DbSetOrder(1)) //DXI_FILIAL+DXI_SAFRA+DXI_ETIQ
				If DXI->(DbSeek(NC4->NC4_CODBAR))
					
					If RecLock("NC4", .F.)
						NC4->NC4_STATUS := "2"
						NC4->NC4_DATATU := dDatabase
						NC4->NC4_HORATU := Time()
						NC4->(MsUnlock())
					EndIf
				EndIf
				
			ElseIf Alltrim(NC4->NC4_CODERR) == "00005" // Não foi encontrado bloco
			
				DbSelectArea("DXD")
				DXD->(DbSetOrder(1)) //DXD_FILIAL+DXD_SAFRA+DXD_CODIGO
				If DXD->(DbSeek(NC4->NC4_CODBAR))
					
					If RecLock("NC4", .F.)
						NC4->NC4_STATUS := "2"
						NC4->NC4_DATATU := dDatabase
						NC4->NC4_HORATU := Time()
						NC4->(MsUnlock())
					EndIf					
				EndIf
				
			ElseIf Alltrim(NC4->NC4_CODERR) == "00006" 
				// O vinculo do fardo ultrapassará a quantidade definida do bloco XXX para Instrução de Embarque XXX
				
				aCmps := StrTokArr(NC4->NC4_CODBAR,";")
				
				cFilIE  := PadR(NC4->NC4_FILENT, TamSX3("N7Q_FILIAL")[1])
				cCodIne := PadR(aCmps[1], TamSX3("N7Q_CODINE")[1])
				cFilRom := PadR(aCmps[2], TamSX3("NJJ_FILIAL")[1])
				cSafra  := PadR(aCmps[3], TamSX3("NJJ_CODSAF")[1])
				cBloco  := PadR(aCmps[4], TamSX3("DXD_CODIGO")[1])
				
				cFrdMar := POSICIONE("N83",2,cFilIE+cCodIne+cFilRom+cBloco,"N83_FRDMAR")				
				nQtdBlc := POSICIONE("N83",2,cFilIE+cCodIne+cFilRom+cBloco,"N83_QUANT")
				
				cAliasN9D := GetNextAlias()
				cQueryN9D := " SELECT COUNT(*) AS QTDFRD "
				cQueryN9D += "   FROM " + RetSqlName("N9D") + " N9D "
			    cQueryN9D += "  WHERE N9D.N9D_FILIAL = '" + cFilRom + "' "
				cQueryN9D += "	  AND N9D.N9D_SAFRA  = '" + cSafra + "' "
				cQueryN9D += "	  AND N9D.N9D_BLOCO  = '" + cBloco + "' "
			    cQueryN9D += "    AND N9D.N9D_FILORG = '" + cFilIE + "' "
			    cQueryN9D += "    AND N9D.N9D_CODINE = '" + cCodIne + "' "
			    cQueryN9D += "    AND N9D.N9D_TIPMOV = '04' "
			    cQueryN9D += "    AND N9D.N9D_STATUS <> '3' "
			    cQueryN9D += "    AND N9D.D_E_L_E_T_ <> '*' "
			    
			    cQueryN9D := ChangeQuery(cQueryN9D)
			    MPSysOpenQuery(cQueryN9D, cAliasN9D)
			    
			    If (cAliasN9D)->(Eof()) .Or. ((cAliasN9D)->(!Eof()) .AND. ((cAliasN9D)->QTDFRD = 0 .OR. ((cAliasN9D)->QTDFRD + 1 <= nQtdBlc))) 
		    
			    	If RecLock("NC4", .F.)
						NC4->NC4_STATUS := "2"
						NC4->NC4_DATATU := dDatabase
						NC4->NC4_HORATU := Time()
						NC4->(MsUnlock())
					EndIf
			    EndIf	
			    
			    (cAliasN9D)->(DbCloseArea())	
											
			EndIf
		
			If NC4->(NC4_STATUS) == "1"
				lErroSinc := .T.
			EndIf
										
			NC4->(DbSkip())
		EndDo
	EndIf
	
Return lErroSinc
