#INCLUDE "BADEFINITION.CH"
#INCLUDE "BADATABASE.CH"

Static __aShared := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} BAProcessTable
Define a estrutura da table de Processos (Queries) e realiza a criação.

@author Helio Leal  
@since 29/08/2017
/*/
//-------------------------------------------------------------------
Function BAProcessTable()
	Local oQuery := Nil
	Local aTable := {}
	Local nTable := 1

	//-------------------------------------------------------------------
	// Cria a tabela de processos. 
	//-------------------------------------------------------------------  
	oQuery := TBITable():New( "I01", "I01" ) 

	//-------------------------------------------------------------------
	// Campos da tabela. 
	//-------------------------------------------------------------------  
	oQuery:AddField( TBIField():New( "I01_ENTITY"   , "C", 30, 0)) // Nome da entidade
	oQuery:AddField( TBIField():New( "I01_TYPE"     , "C", 01, 0)) // Tipo da entidade, D=Dimensão, F=Fato
	oQuery:AddField( TBIField():New( "I01_ORIGIN"   , "C", 03, 0)) // Tabela de Origem do Protheus 
	oQuery:AddField( TBIField():New( "I01_ISTCIA"   , "C", 02, 0)) // Instância
	oQuery:AddField( TBIField():New( "I01_EMPRES"   , "C", 12, 0)) // Empresa
	oQuery:AddField( TBIField():New( "I01_FILIAL"   , "C", 08, 0)) // Filial
	oQuery:AddField( TBIField():New( "I01_QUERY"    , "M", 10, 0)) // Query
	oQuery:AddField( TBIField():New( "I01_CRYPT"    , "C", 30, 0)) // Tipo de Criptografia
	oQuery:AddField( TBIField():New( "I01_FILANT"   , "C", 08, 0)) // Filial de instalação
	oQuery:AddField( TBIField():New( "I01_TPEXTR"   , "C", 01, 0)) // Tipo da Extração: P=Período e M=Mensal
	
	//-------------------------------------------------------------------
	// Índices da tabela. 
	//-------------------------------------------------------------------  
	oQuery:addIndex( TBIIndex():New( "I011", {"I01_ENTITY", "I01_EMPRES", "I01_ISTCIA"}, .T.) )
	oQuery:addIndex( TBIIndex():New( "I012", {"I01_ENTITY", "I01_EMPRES", "I01_ISTCIA", "I01_FILIAL" }, .T.) )
	oQuery:addIndex( TBIIndex():New( "I013", {"I01_ENTITY", "I01_EMPRES", "I01_ISTCIA", "I01_FILANT" }, .T.) )

	aAdd( aTable, oQuery )

	//-------------------------------------------------------------------
	// Abre a tabela. 
	//------------------------------------------------------------------- 
	For nTable := 1 To Len( aTable )
		If !( aTable[nTable]:lIsOpen() )
			aTable[nTable]:ChkStruct(.T.)
			aTable[nTable]:lOpen()
		EndIf
	Next nTable

	aSize(aTable, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAppTable
Define a estrutura da tabela de Apps e realiza a criação.

@author Andréia Lima  
@since 01/03/2018
/*/
//-------------------------------------------------------------------
Function BAAppTable()
	Local oQuery := Nil
	Local aTable := {}
	Local nTable := 1

	//-------------------------------------------------------------------
	// Cria a tabela de apps. 
	//-------------------------------------------------------------------  
	oQuery := TBITable():New( "I02", "I02" ) 

	oQuery:AddField( TBIField():New( "I02_APP", "C", 30, 0)) // Nome do App
	oQuery:addIndex( TBIIndex():New( "I021", {"I02_APP"}, .T.) )

	aAdd( aTable, oQuery )

	//-------------------------------------------------------------------
	// Abre a tabela.
	//------------------------------------------------------------------- 
	For nTable := 1 To Len( aTable )
		If !( aTable[nTable]:lIsOpen() )
			aTable[nTable]:ChkStruct(.T.)
			aTable[nTable]:lOpen()
		EndIf
	Next nTable

	aSize(aTable, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAppEntTable
Define a estrutura da tabela de Apps X Entidades e realiza a criação.

@author Andréia Lima  
@since 01/03/2018
/*/
//-------------------------------------------------------------------
Function BAAppEntTable()
	Local oQuery := Nil
	Local aTable := {}
	Local nTable := 1

	//-------------------------------------------------------------------
	// Cria a tabela de apps x entidades. 
	//-------------------------------------------------------------------  
	oQuery := TBITable():New( "I03", "I03" ) 

	oQuery:AddField( TBIField():New( "I03_APP", "C", 30, 0)) // Nome do App
	oQuery:AddField( TBIField():New( "I03_ENTITY", "C", 30, 0)) // Nome da entidade
	oQuery:addIndex( TBIIndex():New( "I031", {"I03_APP", "I03_ENTITY"}, .T.) )	

	aAdd( aTable, oQuery )

	//-------------------------------------------------------------------
	// Abre a tabela.
	//------------------------------------------------------------------- 
	For nTable := 1 To Len( aTable )
		If !( aTable[nTable]:lIsOpen() )
			aTable[nTable]:ChkStruct(.T.)
			aTable[nTable]:lOpen()
		EndIf
	Next nTable

	aSize(aTable, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BARecordEntity
Salva a query de uma entidade na base de dados ERP (na tabela I01).

@param oEntity, object, objeto do tipo dimensão ou fato.
@param cCompany, String, Empresa injetada.

@Return lSuccess, True para quando a execução do método não houve erros, caso contrário False.

@author  Helio Leal
@since   04/09/2017
/*/
//-------------------------------------------------------------------
Function BARecordEntity( oEntity, cCompany )
	Local cQuery    := ""	
	Local cOrigin   := ""
	Local cShared   := ""
	Local cInstance := BAInstance()
	Local lEntity   := .F.
	Local nStatus	:= 0 
	
	Default oEntity    := Nil 
	Default cCompany   := ""

	cOrigin := oEntity:GetOrigin( )
	cShared := BAGetShare ( cOrigin )
	cQuery  := oEntity:GetQuery( cCompany )
	nStatus := oEntity:GetStatus( )

	If nStatus == 0
	
		//-----------------------------------------------------------------------------------------------------------------
		// Não permitir a gravação duplicada das entidades onde a tabela de origem seja compartilhada entre as empresas. 
		//-----------------------------------------------------------------------------------------------------------------
		If ( Ascan( __aShared, { |x| x[1] == oEntity:GetEntity( ) .And. x[2] == cShared } )) == 0
			
			//-------------------------------------------------------------------
			// Identifica se é para incluir ou atualizar a entidade.
			//-------------------------------------------------------------------	
			lEntity := I01->( DBSeek( ( Padr( AllTrim( oEntity:GetEntity( ) ), 30 ) ) + ( Padr( AllTrim( cCompany  ), 12 ) ) + cInstance ) )
	
			If( RecLock( "I01", ! lEntity  ) )
				I01->I01_ENTITY := oEntity:GetEntity( )
				I01->I01_TYPE   := oEntity:GetType( )
				I01->I01_ORIGIN := oEntity:GetOrigin( )
				I01->I01_ISTCIA := cInstance
				I01->I01_EMPRES := cCompany
				I01->I01_QUERY  := cQuery
				I01->I01_CRYPT  := CRYPT_TYPE
				I01->I01_TPEXTR := oEntity:GetTpExtr( )
				

				I01->( MsUnlock() )
			EndIf
			
			aAdd(__aShared, { oEntity:GetEntity( ), cShared } )
			Conout( STR0001 + " " + oEntity:GetEntity( ) ) // "BADataBase: Gravando a consulta"			
		EndIf
	Else
		ConOut(I18n( STR0004 , {STR0005, oEntity:GetEntity( ), STR0006} ) ) // "BADataBase #1 #2 #3 ##Entidade ##não foi gravada na tabela de processos.
	EndIf

Return nStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} BASaveApp
Salva o App na base de dados ERP.

@param, cApp, String, Nome do App.

@author  Andréia Lima
@since   01/03/2018
/*/
//-------------------------------------------------------------------
Function BASaveApp( cApp )
	Local lApp := .F.
	
	Default cApp := ""

	If ! ( Empty( cApp ) )
	
		lApp := I02->( DBSeek( ( Padr( AllTrim( cApp ), 30 ) ) ) )
		If( RecLock( "I02", ! lApp  ) )
			I02->I02_APP := cApp

			I02->( MsUnlock() )
		EndIf
		
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BASaveAppEntity
Salva o App X Entidade na base de dados ERP.

@param, cApp, String, Nome do App.
@param, cEntity, String, Nome da entidade.

@author Andréia Lima
@since  01/03/2018
/*/
//-------------------------------------------------------------------
Function BASaveAppEntity( cApp, cEntity )
	Local lAppEntity   := .F.
	
	Default cApp := ""
	Default cEntity := ""	

	If ! ( Empty( cApp ) )
	
		lAppEntity := I03->( DBSeek( ( Padr( AllTrim( cApp ), 30 ) ) + ( Padr( AllTrim( cEntity  ), 30 ) ) ) )

		If( RecLock( "I03", ! lAppEntity  ) )
			I03->I03_APP    := cApp
			I03->I03_ENTITY := cEntity
			I03->( MsUnlock() )
		EndIf
		
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BAExistDimension
Verifica se a entidade já foi gravada por empresa.

@param, cEntity, String, Nome da entidade.
@param, cCompany, String, Código da empresa.

@author Andréia Lima
@since  01/03/2018
/*/
//-------------------------------------------------------------------
Function BAExistDimension( cEntity, cCompany )
	Local lExist    := .F.
	Local cInstance := BAInstance()
	
	Default cEntity    := ""
	Default cCompany   := ""	

	lExist := I01->( DBSeek( ( Padr( AllTrim( cEntity ), 30 ) ) + ( Padr( AllTrim( cCompany  ), 12 ) ) + cInstance ) )
	
Return lExist

//-------------------------------------------------------------------
/*/{Protheus.doc} BARecByFil - Record By Filial
Salva a query de uma entidade na base de dados ERP (I01) - Essa função salva quando tiver usando .

@param, oEntity, object, objeto do tipo dimensão ou fato.
@param, cCompany, String, Empresa injetada.
@param, cCodFilial, String, Filial injetada.

@Return lSuccess, boolean, True para quando a execução do método não houve erros, caso contrário False.

@author  Helio Leal
@since   07/05/2018
/*/
//-------------------------------------------------------------------
Function BARecByFil( oEntity, cCompany, cCodFilial )
	Local cQuery    := ""	
	Local cOrigin   := ""
	Local cShared   := ""
	Local cType     := ""
	Local cEntity   := ""
	Local cInstance := BAInstance()
	Local cTpExtr	:= ""
	Local lEntity   := .F.
	Local nStatus	:= 0
	
	Default oEntity    := Nil 
	Default cCompany   := ""
	Default cCodFilial := ""

	If ! ( oEntity == Nil )
		//------------------------------------------------------------------------
		// Recebe os atributos da entidade (Query, tipo, nome e tabela origem).
		//------------------------------------------------------------------------
		cQuery  := oEntity:GetQuery( cCompany )
		nStatus := oEntity:GetStatus( )	
		cType   := oEntity:GetType( )
		cEntity := oEntity:GetEntity( )
		cOrigin := oEntity:GetOrigin( )
		cShared := BAGetShare ( cOrigin )
		cTpExtr := oEntity:GetTpExtr( )
	
		If (  nStatus == 0 )  
			
			//--------------------------------------------------------------------------------------------------------
			// Condição 1 - Verifica se o __aShared já possui a entidade + X2_ARQUIVO (exemplo: Cliente + SA1010)
			// Condição 2 - Verifica se é dimensão e se a filial não é compartilhada.
			// Condição 3 - Quando for fato, sempre vai gravar na I01, independente se é compartilhada.
			//--------------------------------------------------------------------------------------------------------
			If ( ( Ascan( __aShared, { |x| x[1] == cEntity .And. x[2] == cShared } )) == 0 ) .Or.   ; 
			   ( cType == DIMENSION .And. ! Empty( cCodFilial ) ) .Or. ;
			   ( cType == FACT )
				
				//-------------------------------------------------------------------
				// Identifica se a entidade já foi gravada anteriormente.
				//-------------------------------------------------------------------						
				If cType == DIMENSION
					I01->( dbSetOrder( 2 ) ) 
					lEntity := I01->( DBSeek( ( Padr( AllTrim( cEntity ), 30 ) ) + ( Padr( AllTrim( cCompany  ), 12 ) ) + cInstance + ( Padr( AllTrim( cCodFilial ), 8 ) ) ) )
				Else
					I01->( dbSetOrder( 3 ) )
					lEntity := I01->( DBSeek( ( Padr( AllTrim( cEntity ), 30 ) ) + ( Padr( AllTrim( cCompany  ), 12 ) ) + cInstance + ( Padr( AllTrim( cFilAnt ), 8 ) ) ) )
				EndIf
				
				//-------------------------------------------------------------------
				// Identifica se é para inserir a entidade na base de dados.
				//-------------------------------------------------------------------
				If ! ( lEntity )					
					If( RecLock( "I01", .T.  ) )

						I01->I01_ENTITY := cEntity
						I01->I01_TYPE   := cType
						I01->I01_ORIGIN := cOrigin
						I01->I01_ISTCIA := cInstance
						I01->I01_EMPRES := cCompany
						I01->I01_FILIAL := cCodFilial
						I01->I01_QUERY  := cQuery
						I01->I01_CRYPT  := CRYPT_TYPE
						I01->I01_FILANT := cFilAnt
						I01->I01_TPEXTR := cTpExtr
			
						I01->( MsUnlock() )
					EndIf
					
					aAdd(__aShared, { cEntity, cShared } )
					Conout( STR0001 + " " + cEntity ) // "BADataBase: Gravando a consulta"
				EndIf
			EndIf
		Else
			ConOut(I18n( STR0004 , {STR0005, cEntity, STR0006} ) ) // "BADataBase #1 #2 #3 ##Entidade ##não foi gravada na tabela de processos.
		EndIf
	EndIf

Return nStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} BATruncate  
Limpa todos os dados da tabela de processos (I01). 

@author  Helio Leal
@since   09/05/2018
/*/
//------------------------------------------------------------------- 
Function BATruncate()
	Local cDDL := ""
	Local lOk  := .T.
	Local cDatabase  := Upper( TCGetDB() )
	
	//-------------------------------------------------------------------
	// Força a criação da tabela I01 antes de efetuar o Truncate
	//-------------------------------------------------------------------
	BAProcessTable()

	//-------------------------------------------------------------------
	// Monta a DDL.
	//-------------------------------------------------------------------
	Do Case
		Case ("DB2" $ cDataBase )
			cDDL := "DELETE FROM I01"
		Case ("POSTGRES" $ cDataBase )
			cDDL := "TRUNCATE I01"
		Otherwise
			cDDL := "TRUNCATE TABLE I01"
	EndCase
	
	//-------------------------------------------------------------------
	// Executa a DDL.
	//-------------------------------------------------------------------
	If ! ( TCSQLExec( cDDL ) == 0 )
		ConOut( "BATruncate: " + TCSQLError() )
		lOk := .F.
	EndIf
Return lOk


