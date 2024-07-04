#INCLUDE "PROTHEUS.CH"

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA1142() ; Return


//-------------------------------------------------------------------
/*/{Protheus.doc} LJCInitialLoadConfiguration

Classe que representa as configura��o da carga. 
  
@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Class LJCInitialLoadConfiguration
	Method New()
	Method GetILTempPath()
	Method SetILTempPath()
	Method GetILPersistPath()
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New()

Construtor
  
@return Self

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method New() Class LJCInitialLoadConfiguration
Return                                       
            

//-------------------------------------------------------------------
/*/{Protheus.doc} SetILTempPath()

Configura o caminho tempor�rio da carga.      
  
@param cPath Caminho tempor�rio. 

@return Nenhum

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method SetILTempPath( cPath ) Class LJCInitialLoadConfiguration	
	PutMV( "MV_LJILTPA", cPath )
Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} GetILTempPath()

Pega o caminho tempor�rio da carga. 
  
@return cRet Caminho tempor�rio.

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method GetILTempPath() Class LJCInitialLoadConfiguration	
Return GetMV( "MV_LJILTPA",,"" )


//-------------------------------------------------------------------
/*/{Protheus.doc} GetILPersistPath()

Pega o caminho de destino da carga. 

@return cRet Caminho de destino da carga.

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method GetILPersistPath() Class LJCInitialLoadConfiguration
Return GetPvProfString(GetEnvServer(),"StartPath","",GetAdv97())   