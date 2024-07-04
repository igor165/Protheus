#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXREGIAO.CH"

REGISTER EXTRACTOR HJB

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRegiao
Visualiza as informações por Região Geográfica do país.

@author  BI TEAM
@since   23/07/2010
/*/
//-------------------------------------------------------------------
Class BIXRegiao from BIXEntity
	Data oKey 
	Data cCountryCode
	
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
	Method ExistIBGE( )
	Method GetCountryCode( )
	Method GetMacroRegion( )
	Method GetDescCountry( )
	Method LoadCountries( )
	Method CostumerRegions(  )
	Method IBGERegions( )
	Method SX5Regions( )
	Method GetGeoRegion( )
	Method Key( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor.

@author  Helio Leal
@since   08/11/2016
/*/
//-------------------------------------------------------------------
Method New() class BIXRegiao
	::oKey 			:= Nil
	::cCountryCode 	:= Nil

	_Super:New( DIMENSION, "HJB", STR0002 , "SX5" ) // "Região Geográfica"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   04/11/2016
/*/
//------------------------------------------------------------------- 
Method Model() class BIXRegiao 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJB_REGIAO" )
	oModel:SetBK( { "HJB_REGIAO" } )

	If ( ::ExistIBGE() )
		oModel:AddUnifier( { "CC2_EST", "CC2_CODMUN"}, STR0002  ) //"Região Geográfica"
	Else
		oModel:AddUnifier( { "HJB_ESTADO", "HJB_CIDADE"}, STR0002  ) //"Região Geográfica"
	EndIf

	oModel:AddField( "HJB_REGIAO" , "C", 32, 0 )
	oModel:AddField( "HJB_REGGEO" , "C", 40, 0 )
	oModel:AddField( "HJB_ESTADO" , "C", 04, 0 )
	oModel:AddField( "HJB_CIDADE" , "C", 60, 0 )
	oModel:AddField( "HJB_PAIS"   , "C", 60, 0 )
	oModel:AddField( "HJB_MACDES" , "C", 40, 0 )
	oModel:AddField( "HJB_MACREG" , "C", 10, 0 )
	oModel:AddField( "HJB_NOMEUF" , "C", 25, 0 ) 
	
	oModel:FreeField() 
Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} Run
Extração dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extração. 
@param cTo, caracter, Data final de extração.
@param dToday, data, Data de inicio do processo de extração.  
@param oOutput, objeto, Objeto para gravação dos dados.
@param oRecord, objeto, Objeto para extração dos dados.
@param oKey, objeto, Objeto para geração da surrogate key.

@author  BI TEAM
@since   26/07/2010
/*/
//-------------------------------------------------------------------
method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXRegiao
	Local aArea 		:= GetArea()
	Local aPaisesSYA	:= ::LoadCountries()
	Local aMacroReg		:= BIXLoadMRInfo()
	Local aPaises		:= GetCountryList()
	Local nPos 			:= Ascan( aPaises, {|x| x[1] == cPaisLoc} )
	Local cPais 		:= Upper( aPaises[nPos][2] )
	Local nI			:= 0
	Local cRegiao		:= ""
	Local cCodPais		:= ""
	Local cCodMacro		:= ""
	Local cDescMacro	:= ""
	Local aNewReg		:= {}
	Local cEstAux		:= ""
	Local cPaisAux		:= ""
	Local cFlowSX5 		:= ""
	Local cFlowCC2 		:= ""
	Local cFlowSA1 		:= ""
	Local cCodPLoc		:= ::GetCountryCode( )
	Local lCliReg		:= BIXParInfo( "BIX_CLIREG", "L", .F. )
	Local aContent := {}
	Local nX := 0

	SYA->( DbSetOrder(1) )

	//-------------------------------------------------------------------
	// Retorna o código da país cadastrado na SYA
	//-------------------------------------------------------------------
	cCodPais := ::GetDescCountry( cPais, aPaisesSYA )
	
	//-------------------------------------------------------------------
	// Retorna as informações da macro região.
	//-------------------------------------------------------------------
	::GetMacroRegion( cCodPais, aMacroReg, @cCodMacro, @cDescMacro )

	cFlowSX5 := ::SX5Regions()
	
	While ! ( cFlowSX5 )->( Eof() )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		cRegiao := ::GetGeoRegion( AllTrim( (cFlowSX5)->X5_CHAVE ) )

		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		If ( ::ExistIBGE() )
			oRecord:SetValue( "CC2_EST" , (cFlowSX5)->X5_CHAVE )
			oRecord:SetValue( "CC2_CODMUN", "" )
			oRecord:SetValue( "HJB_REGIAO",  oKey:GetKey( { (cFlowSX5)->X5_CHAVE, "" } ) )
		Else
			oRecord:SetValue( "X5_TABELA"	, (cFlowSX5)->X5_TABELA )
			oRecord:SetValue( "X5_CHAVE"	, (cFlowSX5)->X5_CHAVE )
			oRecord:SetValue( "HJB_REGIAO",  oKey:GetKey( { (cFlowSX5)->X5_TABELA, (cFlowSX5)->X5_CHAVE } ) )
		EndIf

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJB_REGGEO", cRegiao ) // ????
		oRecord:SetValue( "HJB_MACREG", cCodMacro )
		oRecord:SetValue( "HJB_MACDES", cDescMacro )
		oRecord:SetValue( "HJB_CIDADE", "_" ) //LK_EMPTY
		oRecord:SetValue( "HJB_ESTADO", (cFlowSX5)->X5_CHAVE ) 
		oRecord:SetValue( "HJB_PAIS", 	cPais )
		oRecord:SetValue( "HJB_NOMEUF", (cFlowSX5)->X5_DESCRI  ) //???X5Descri()
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

		// Armazena as informações da Tabela de Municípios do IBGE, caso ela exista
		If ( ::ExistIBGE() )
			cFlowCC2 := ::IBGERegions( (cFlowSX5)->X5_CHAVE )

			While ! (cFlowCC2)->( Eof() )  
				//-------------------------------------------------------------------
				// Inicializa o registro. 
				//-------------------------------------------------------------------   	
				oRecord:Init()

				cRegiao := ::GetGeoRegion( AllTrim( (cFlowSX5)->X5_CHAVE ) )

				//-------------------------------------------------------------------
				// Alimenta os campos para customização e consolidação. 
				//-------------------------------------------------------------------	
				oRecord:SetValue( "CC2_EST" , (cFlowCC2)->CC2_EST )
				oRecord:SetValue( "CC2_CODMUN", (cFlowCC2)->CC2_CODMUN )

				//-------------------------------------------------------------------
				// Alimenta os campos de negócio. 
				//-------------------------------------------------------------------
				oRecord:SetValue( "HJB_REGIAO",  oKey:GetKey( { (cFlowCC2)->CC2_EST, (cFlowCC2)->CC2_CODMUN } ) )			
				oRecord:SetValue( "HJB_REGGEO", cRegiao ) 
				oRecord:SetValue( "HJB_MACREG", cCodMacro )
				oRecord:SetValue( "HJB_MACDES", cDescMacro )
				oRecord:SetValue( "HJB_CIDADE", (cFlowCC2)->CC2_MUN  )
				oRecord:SetValue( "HJB_ESTADO", (cFlowCC2)->CC2_EST )
				oRecord:SetValue( "HJB_PAIS", 	cPais )
				oRecord:SetValue( "HJB_NOMEUF", (cFlowSX5)->X5_DESCRI ) 
				
				//-------------------------------------------------------------------
				// Envia o registro para o pool de gravação da Fluig Smart Data. 
				//-------------------------------------------------------------------		
				oOutput:Send( oRecord ) 

				(cFlowCC2)->( dbSkip() )
			End
			
			(cFlowCC2)->(DbCloseArea())
		EndIf

		(cFlowSX5)->( DbSkip() )
	EndDo
	(cFlowSX5)->(DbCloseArea())


	For nI := 1 to len(aPaisesSYA)
		If FWNoAccent( AllTrim( cPais ) ) != FWNoAccent( AllTrim( aPaisesSYA[nI][2] ) )
			cCodMacro := ""
			cDescMacro := ""

			//-------------------------------------------------------------------
			// Retorna as informações da macro região.
			//-------------------------------------------------------------------
			::GetMacroRegion( aPaisesSYA[nI][1], aMacroReg, @cCodMacro, @cDescMacro )

			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//-------------------------------------------------------------------   	
			oRecord:Init()

			//-------------------------------------------------------------------
			// Alimenta os campos para customização e consolidação. 
			//-------------------------------------------------------------------	
			If ( ::ExistIBGE() )
				oRecord:SetValue( "CC2_EST" , "" )
				oRecord:SetValue( "CC2_CODMUN", aPaisesSYA[nI][1] )
				oRecord:SetValue( "HJB_REGIAO",  oKey:GetKey( { "", aPaisesSYA[nI][1] } ) )
			Else
				oRecord:SetValue( "X5_CHAVE", aPaisesSYA[nI][1] )
				oRecord:SetValue( "HJB_REGIAO",  oKey:GetKey( { aPaisesSYA[nI][1] } ) )
			EndIf

			//-------------------------------------------------------------------
			// Alimenta os campos de negócio. 
			//-------------------------------------------------------------------			
			oRecord:SetValue( "HJB_REGGEO", STR0001 ) 
			oRecord:SetValue( "HJB_MACREG", cCodMacro )
			oRecord:SetValue( "HJB_MACDES", cDescMacro )
			oRecord:SetValue( "HJB_CIDADE", "_" ) 
			oRecord:SetValue( "HJB_ESTADO", aPaisesSYA[nI][1] )
			oRecord:SetValue( "HJB_PAIS", 	aPaisesSYA[nI][2] )
			oRecord:SetValue( "HJB_NOMEUF", 'EX' )

			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação da Fluig Smart Data. 
			//-------------------------------------------------------------------		
			oOutput:Send( oRecord ) 
		EndIf
	Next


	If lCliReg
		cFlowSA1 := ::CostumerRegions()
		
		//-------------------------------------------------------------------
		// Percorre o cadastro de cliente para armazenar os estados de outros países
		//-------------------------------------------------------------------		
		While (cFlowSA1)->( !EOF() ) 
			cEstAux	:= ""
			cPaisAux	:= ""

			//-------------------------------------------------------------------
			// Valida os registros que não sejam do país da instalação e estado igual a 'EX'
			//-------------------------------------------------------------------
			If (cCodPLoc !=  Upper(Alltrim((cFlowSA1)->A1_PAIS)) .And. Upper(Alltrim((cFlowSA1)->A1_EST)) != 'EX')
				//-------------------------------------------------------------------
				// Pesquisa no array de controle para verificar se o registro já foi inserido
				//-------------------------------------------------------------------
				If Ascan(aNewReg, {|x| x[1] == Upper(Alltrim((cFlowSA1)->A1_PAIS)) .And. x[2] == Upper(Alltrim((cFlowSA1)->A1_EST))} ) == 0
					//-------------------------------------------------------------------
					// Recupera a descrição do país correspondente
					//-------------------------------------------------------------------
					If SYA->( MSSeek(xFilial("SYA")+Upper(Alltrim((cFlowSA1)->A1_PAIS))) )
						cPaisAux := SYA->YA_DESCR
					EndIf
					
					//-------------------------------------------------------------------
					// Recupera a descrição do estado correspondente		
					//-------------------------------------------------------------------
					If SX5->( MSSeek(xFilial("SX5")+'12'+Upper(Alltrim((cFlowSA1)->A1_EST))) )
						cEstAux := X5Descri()
					EndIf
					
					//-------------------------------------------------------------------
					// Se o registro for válido
					//-------------------------------------------------------------------
					If !Empty(cEstAux) .And. !Empty(cPaisAux)
						//-------------------------------------------------------------------
						// Controla os itens inseridos para não haver duplicidade.		
						//-------------------------------------------------------------------
						Aadd(aNewReg, { Upper(Alltrim((cFlowSA1)->A1_PAIS)),Upper(Alltrim((cFlowSA1)->A1_EST)) } ) 
	
						//-------------------------------------------------------------------
						// Adiciona o registro na dimensão
						//-------------------------------------------------------------------
						//-------------------------------------------------------------------
						// Inicializa o registro. 
						//-------------------------------------------------------------------   	
						oRecord:Init()

						//-------------------------------------------------------------------
						// Alimenta os campos para customização e consolidação. 
						//-------------------------------------------------------------------	
						oRecord:SetValue( "CC2_EST" , (cFlowSA1)->A1_EST )
						oRecord:SetValue( "CC2_CODMUN", (cFlowSA1)->A1_PAIS )

						//-------------------------------------------------------------------
						// Alimenta os campos de negócio. 
						//-------------------------------------------------------------------
						oRecord:SetValue( "HJB_REGIAO",  oKey:GetKey( { (cFlowSA1)->A1_EST, (cFlowSA1)->A1_PAIS } ) )				
						oRecord:SetValue( "HJB_REGGEO", STR0001 ) //'Exterior'
						oRecord:SetValue( "HJB_CIDADE", "_" ) 
						oRecord:SetValue( "HJB_ESTADO", Upper(Alltrim((cFlowSA1)->A1_EST)))
						oRecord:SetValue( "HJB_PAIS", 	cPaisAux )
						oRecord:SetValue( "HJB_NOMEUF", cEstAux )

						//-------------------------------------------------------------------
						// Envia o registro para o pool de gravação da Fluig Smart Data. 
						//-------------------------------------------------------------------		
						oOutput:Send( oRecord ) 
					EndIf
				Endif
			EndIf
			(cFlowSA1)->( dbSkip() )
		End

		(cFlowSA1)->(DbCloseArea())
		SYA->(DbCloseArea())
	EndIf
	oOutput:Release()

	restArea(aArea)
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SX5Regions
Retorna as informações da Tabela de Municípios do SX5.

@author  Marcia Junko
@since   14/11/2013
/*/
//-------------------------------------------------------------------
Method SX5Regions() Class BIXRegiao
	Local cFlow	:= ""  
	Local cTemp := GetNextAlias()

	cFlow += " SELECT" 
	cFlow += " 		X5_TABELA,"
	cFlow += " 		X5_CHAVE, "
	cFlow += BIXSX5Title() 
	cFlow += " 	FROM " + RetSQLName("SX5") + "  
	cFlow += " 	WHERE " 
	cFlow += "		X5_FILIAL = '" + xFilial("SX5") + "'"           
	cFlow += "		AND X5_TABELA  = '12'"           
	cFlow += "		AND D_E_L_E_T_ = ' '"   	 

	//-------------------------------------------------------------------
	// Transforma o DML.
	//-------------------------------------------------------------------  	
	cFlow := ChangeQuery( cFlow )  

	//-------------------------------------------------------------------
	// Monta o alias temporário com o resultado do DML. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,cFlow ), cTemp, .T., .F. ) 
Return cTemp 

//-------------------------------------------------------------------
/*/{Protheus.doc} IBGERegions
Retorna as informações da Tabela de Municípios do IBGE.

@param cUF,	String,	Estado a ser colocado no filtro

@author  Marcia Junko
@since   14/11/2013
/*/
//-------------------------------------------------------------------
Method IBGERegions( cUF ) Class BIXRegiao
	Local cFlow	:= ""  
	Local cTemp := GetNextAlias()

	cFlow += " SELECT" 
	cFlow += " 		CC2_EST,"
	cFlow += " 		CC2_CODMUN,"
	cFlow += " 		CC2_MUN"
	cFlow += " 	FROM " + RetSQLName("CC2") + "  
	cFlow += " 	WHERE " 
	cFlow += "		CC2_FILIAL = '" + xFilial("CC2") + "'"           
	cFlow += "		AND CC2_EST  = '" + cUF + "' "           
	cFlow += "		AND D_E_L_E_T_ = ' '"   	 

	//-------------------------------------------------------------------
	// Transforma o DML.
	//-------------------------------------------------------------------  	
	cFlow := ChangeQuery( cFlow )  

	//-------------------------------------------------------------------
	// Monta o alias temporário com o resultado do DML. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,cFlow ), cTemp, .T., .F. ) 
Return cTemp 

//-------------------------------------------------------------------
/*/{Protheus.doc} CostumerRegions
Percorre o cadastro de cliente para armazenar os estados de outros países

@author  Marcia Junko
@since   14/11/2013
/*/
//-------------------------------------------------------------------
Method CostumerRegions() Class BIXRegiao
	Local cFlow	:= ""  
	Local cTemp := GetNextAlias()

	cFlow += " SELECT" 
	cFlow += " 		A1_PAIS,"
	cFlow += " 		A1_EST"
	cFlow += " 	FROM " + RetSQLName("SA1")
	cFlow += " 	WHERE "
	cFlow += "		A1_FILIAL = '" + xFilial("SA1") + "'"           
	cFlow += "		AND A1_EST <> ' ' "
	cFlow += "		AND A1_PAIS <> ' ' "
	cFlow += "		AND D_E_L_E_T_ = ' '"

	//-------------------------------------------------------------------
	// Transforma o DML.
	//-------------------------------------------------------------------  	
	cFlow := ChangeQuery( cFlow )  

	//-------------------------------------------------------------------
	// Monta o alias temporário com o resultado do DML. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,cFlow ), cTemp, .T., .F. ) 
Return cTemp 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetGeoRegion
Função que retorna a região geográfica conforme o país que está sendo utilizado.

@param cEstado,	String,	Estado para definição da região geográfica.

@return String contendo a descrição da região geográfica

@author  Marcia Junko
@since   14/11/2013
/*/
//-------------------------------------------------------------------
Method GetGeoRegion( cEstado ) Class BIXRegiao
	Local cRegion := ""

	If cPaisLoc == "BRA" //Brasil
		Do Case
			Case cEstado $ "DF/GO/MS/MT"
				cRegion := 'CENTRO-OESTE'
			Case cEstado $ "AL/BA/CE/MA/PB/PE/PI/RN/SE"
		       cRegion := 'NORDESTE'
			Case cEstado $ "AC/AM/AP/PA/RO/RR/TO"
				cRegion := 'NORTE'
			Case cEstado $ "ES/MG/SP/RJ"
				cRegion := 'SUDESTE'
			Case cEstado $ "PR/RS/SC"
				cRegion := 'SUL'
			Otherwise
				cRegion := 'INDEFINIDO' 
		EndCase
	ElseIf cPaisLoc == "ARG" //Argentina
		Do Case
			Case cEstado $ "ME/SJ/SL"
				cRegion := 'CUYO'
			Case cEstado $ "CF/DF"
		       cRegion := 'METROPOLITANA'
			Case cEstado $ "BA"
				cRegion := 'BUENOS AIRES'
			Case cEstado $ "CH/CR/FO/MI"
				cRegion := 'NORDESTE'
			Case cEstado $ "CA/JU/LR/AS/SE/TU"
				cRegion := 'NOROESTE'
			Case cEstado $ "CO/ER/LP/SF"
				cRegion := 'PAMPEANA'
			Case cEstado $ "CB/NE/RN/SC/TF"
				cRegion := 'PATAGÔNICA'
			Otherwise
				cRegion := 'INDEFINIDO' 
		EndCase
	ElseIf cPaisLoc == "CHI" //Chile
		Do Case
			Case cEstado $ "01/02/15"
				cRegion := 'NORTE GRANDE'
			Case cEstado $ "03/04"
		       cRegion := 'NORTE CHICO'
			Case cEstado $ "05/06/07/08/13/RM"
				cRegion := 'CENTRAL'
			Case cEstado $ "09/10/14"
				cRegion := 'SUR'
			Case cEstado $ "11/12"
				cRegion := 'AUSTRAL'
			Otherwise
				cRegion := 'INDEFINIDO' 
		EndCase
	ElseIf cPaisLoc == "COL" //Colômbia
		Do Case
			Case cEstado $ "91/18/94/95/86/97"
				cRegion := 'AMAZÔNIA'
			Case cEstado $ "05/11/15/17/25/41/54/63/66/68/73"
		       cRegion := 'ANDINA'
			Case cEstado $ "08/13/20/23/47/70/44"
				cRegion := 'CARIBE'
			Case cEstado $ "27/76/52/19"
				cRegion := 'PACÍFICO'
			Case cEstado $ "50/81/99/85"
				cRegion := 'ORINOQUIA'
			Case cEstado $ "88"
				cRegion := 'INSULAR'
			Otherwise
				cRegion := 'INDEFINIDO' 
		EndCase
	ElseIf cPaisLoc == "MEX" //México
		Do Case
			Case cEstado $ "COAH/NL/TAMP"
				cRegion := 'NORESTE'
			Case cEstado $ "BC/BCS/SON/SIN/CHIH/DGO"
		       cRegion := 'NOROESTE'
			Case cEstado $ "NAY/JAL/COL/MICH"
				cRegion := 'OCCIDENTE'
			Case cEstado $ "PUE/VER/TLAX/HGO"
				cRegion := 'ORIENTE'
			Case cEstado $ "AGS/GTO/QRO/SLP/ZAC"
				cRegion := 'CENTRONORTE'
			Case cEstado $ "MOR/MEX/DF"
				cRegion := 'CENTROSUR'
			Case cEstado $ "TAB/CAMP/QROO/YUC"
				cRegion := 'SURESTE'
			Case cEstado $ "GRO/OAX/CHIS"
				cRegion := 'SUROESTE'
			Otherwise
				cRegion := 'INDEFINIDO' 
		EndCase
	EndIf
Return cRegion

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCountries
Função que carrega a relação de países cadastrados na SYA

@return Vetor com a relação de países cadastrados na SYA

@author  Marcia Junko
@since   14/11/2013

/*/
//-------------------------------------------------------------------
Method LoadCountries() Class BIXRegiao
	Local cQuery	:= ""
	Local cRetAlias := GetNextAlias()
	Local aPaises	:= {}

	cQuery := " SELECT "
	cQuery += "			YA_CODGI, "
	cQuery += "			YA_DESCR "
	cQuery += " FROM " + RetSqlName("SYA")
	cQuery += "	WHERE "
	cQuery += "			YA_FILIAL = '" + xFilial("SYA") + "' AND "
	cQuery += " 		D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY YA_DESCR "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cRetAlias, .T., .F.)

	While (cRetAlias)->(!Eof())
		AAdd(aPaises, {(cRetAlias)->YA_CODGI, (cRetAlias)->YA_DESCR })

		(cRetAlias)->(DbSkip())
	End

	(cRetAlias)->(DBCloseArea())
Return aPaises

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDescCountry
Função que pesquisa o código do país cadastrado na tabela SYA atraves da sua descrição.

@param cPais		, String, Descrição do país a ser pesquisado.
@param aPaisList	, Array	, Vetor contendo os países cadastrados na SYA
@return  cCodPais	, String, Código do país

@author  Helio Leal
@since   22/02/2017

/*/
//-------------------------------------------------------------------
Method GetDescCountry( cPais, aPaisList ) Class BIXRegiao
	Local aArea 	:= getArea()
	Local cCodPais	:= ""
	Local nPos		:= 0

	nPos := Ascan(aPaisList, {|x| Alltrim(x[2]) == FWNoAccent( Upper( AllTrim( cPais ))) })

	If nPos == 0
		Return ""
	EndIf

	cCodPais := aPaisList[nPos][1]
Return cCodPais

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMacroRegion
Método para retornar as informações da macro região, caso tenha sido definida.

@param cCountry			, String, Código do país utilizado na macro região.
@param aMacroRegion		, array	, Vetor com as macro regiões cadastradas na HQF.
@param cMacroCode		, String, Código da macro região
@param cMacroDescription, String, Descrição da macro região

@author  Helio Leal
@since   22/02/2017
/*/
//-------------------------------------------------------------------
Method GetMacroRegion( cCountry, aMacroRegion, cMacroCode, cMacroDescription ) Class BIXRegiao
	Local aArea		:= GetArea()
	Local nCountry	:= 0

	Default cMacroCode			:= ""
	Default cMacroDescription	:= ""

	If !( Empty( aMacroRegion ) )
		nCountry := Ascan( aMacroRegion, {|x| Alltrim( cCountry ) $ x[3]})

		If nCountry > 0
			cMacroCode := aMacroRegion[nCountry][1]
			cMacroDescription := aMacroRegion[nCountry][2]
		EndIf
	EndIf

	RestArea( aArea )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCountryCode
Método que pesquisa o código do país de instalação na relação de países cadastrados na SYA

@return Codigo do país de instalação do Protheus.

@author  Helio Leal
@since   22/02/2017
/*/
//-------------------------------------------------------------------
Method GetCountryCode() Class BIXRegiao
	Local aCountries 	:= GetCountryList() //lista de países para instalação do Protheus.
	Local nCountry	 	:= 0 //Posição do país no array.
	Local cCountry 	 	:= "" //Descrição do país.
	Local aArea			:= {}
	
	If (::cCountryCode == Nil)
		aArea := GetArea()

		DbSelectArea("SYA")
		DbSetOrder(2) //YA_FILIAL+YA_DESCR
	
		If (nCountry := Ascan( aCountries, {|x| x[1] == cPaisLoc} ) ) > 0 
			cCountry := Upper( FWNoAccent( aCountries[nCountry][2] ) )
		
			If SYA->( MSSeek( xFilial("SYA") + cCountry ) )
				::cCountryCode := SYA->YA_CODGI
			EndIf
		EndIf
		
		RestArea( aArea )
	EndIf
Return ::cCountryCode

//-------------------------------------------------------------------
/*/{Protheus.doc} IsIBGE
Verifica se existe o Alias CC2 (Tabela de munícipios do IBGE )

@return boolean, Se existe ou não IBGE. 

@author  Helio Leal
@since   22/02/2017
/*/
//-------------------------------------------------------------------
Method ExistIBGE() class BIXRegiao
Return AliasInDic("CC2")

//-------------------------------------------------------------------
/*/{Protheus.doc} Key

@return String, Chave tratada 

@author  Helio Leal
@since   22/02/2017
/*/
//-------------------------------------------------------------------
Method Key( cState, cCity, cCountry ) Class BIXRegiao
	Local cKey	:= ""

	Default cState 	:= ""
	Default cCity := ""
	Default cCountry:= ""

	If (::oKey == Nil)
		::oKey := BIXKey():Build( Self )
	EndIf

	//----------------------------------------------------------
	// Passado o 6º parâmetro para identificar que a entidade
	// possui opção de consolidação.
	//----------------------------------------------------------
	If ( Empty( cCountry ) .Or. cCountry == ::GetCountryCode() ) 
		cKey:= ::oKey:GetKey( { cState, cCity }, , , , , .T. )
	Else
		cKey:= ::oKey:GetKey( { "", cCountry }, , , , , .T. )
	EndIf
Return cKey