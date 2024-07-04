#INCLUDE "PROTHEUS.CH"

// O protheus necessita ter ao menos uma função pública para que o fonte seja exibido na inspeção de fontes do RPO.
Function LOJA1143() ; Return


//-------------------------------------------------------------------
/*/{Protheus.doc} LJCInitialLoadFilesProgress

Classe que representa o progresso do carregar da carga
  
@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Class LJCInitialLoadFilesProgress From FWSerialize
	Data aFiles
	Data nActualFile
	Data oDownloadProgress
	
	Method New()
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New()

Construtor
  
@param aFiles Lista de arquivos que fazem parte da carga

@return Self

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method New( aFiles ) Class LJCInitialLoadFilesProgress
	
	If ValType( aFiles ) != "U"
		Default aFiles := {}
		Self:aFiles				:= aFiles		
		Self:nActualFile		:= 0
	EndIf
Return                              