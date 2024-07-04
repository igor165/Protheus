#INCLUDE "PROTHEUS.CH"

// O protheus necessita ter ao menos uma função pública para que o fonte seja exibido na inspeção de fontes do RPO.
Function LOJA1142() ; Return


//-------------------------------------------------------------------
/*/{Protheus.doc} LJCInitialLoadConfiguration

Classe que representa as configuração da carga. 
  
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

Configura o caminho temporário da carga.      
  
@param cPath Caminho temporário. 

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

Pega o caminho temporário da carga. 
  
@return cRet Caminho temporário.

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