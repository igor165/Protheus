#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTPRECURSO.CH" 

REGISTER EXTRACTOR HOP

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTpRecurso
Visualiza as informações peço código e descrição do tipo de recurso 
contratado para a prestação de recurso. Tipo de Recurso caracteriza a 
origem do serviço prestado para atendimento do contrato. 
Exemplo: Recursos Humanos, Locação de Equipamento, Material de Implantação.

@author  Valdiney V GOMES
@since   27/03/2014
/*/
//-------------------------------------------------------------------
Class BIXTpRecurso from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass
          
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@author  Valdiney V GOMES
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXTpRecurso
	_Super:New( DIMENSION, "HOP", STR0004 ) //"Tipo de Recurso da Prestação de Serviço"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.
@author  Marcia Junko
@since   14/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTpRecurso
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HOP_TIPREC" )
	oModel:SetBK( { "HOP_CODIGO" } )

	oModel:AddField( "HOP_TIPREC", "C", 32, 0 )
	oModel:AddField( "HOP_CODIGO", "C", 10, 0 )
	oModel:AddField( "HOP_DESC"  , "C", 30, 0 )
	
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

@author  Marcia Junko
@since   14/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTpRecurso
	Local aRecurso 		:= {}
	Local nRecurso		:= 1	
	
	aAdd( aRecurso, { "01", STR0001 } ) //"Recursos Humanos"	 
	aAdd( aRecurso, { "02", STR0002 } ) //"Locação de Equipamentos"	
	aAdd( aRecurso, { "03", STR0003 } ) //"Material de Implantação"			    
	
	For nRecurso := 1 To Len( aRecurso )
 		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HOP_TIPREC", oKey:GetKey( { aRecurso[nRecurso][1] },,.F.) )		
		oRecord:SetValue( "HOP_CODIGO", aRecurso[nRecurso][1] )
		oRecord:SetValue( "HOP_DESC"  , aRecurso[nRecurso][2] )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nTipo 		

 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil	