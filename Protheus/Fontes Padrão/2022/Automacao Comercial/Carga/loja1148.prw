#INCLUDE "PROTHEUS.CH"

// O protheus necessita ter ao menos uma função pública para que o fonte seja exibido na inspeção de fontes do RPO.
Function LOJA1148() ; Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} LJCInitialLoadMakerResult()

Classe que representa o resultado da geração de carga.  

@author Vendas CRM
@since 07/02/10
/*/
//-------------------------------------------------------------------------------- 
Class LJCInitialLoadMakerResult From FWSerialize
	Data aoGroups
	
	Method New()   
	Method AddGroup()
	Method AdjustFilter()
	Method Encrypt()
	Method Decrypt()
	
EndClass
   

//--------------------------------------------------------------------------------
/*/{Protheus.doc} New()

Construtor

@return Self

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method New() Class LJCInitialLoadMakerResult
	Self:aoGroups := {}
Return
   

//--------------------------------------------------------------------------------
/*/{Protheus.doc} AddGroup()

Adiciona uma tabela na lista das tabelas transferidas. 

@param oTable: Objeto do tipo LJCInitialLoadTable.
@return Nenhum

@author Vendas CRM
@since 28/06/2012
/*/
//-------------------------------------------------------------------------------- 
Method AddGroup( oGroup ) Class LJCInitialLoadMakerResult
	aAdd( Self:aoGroups, oGroup )
Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} AdjustFilter()

Metodo responsavel por realizar o ajuste da propriedade "Filter" incriptando ou descriptanto se necessario.

@param oResult, Objeto, Objeto que representa uma coleção de tabelas
@return Nenhum

@author Lucas Novais Silva (lnovais@)
@since 12/04/2021
/*/
//-------------------------------------------------------------------------------- 

Method AdjustFilter(oResult) Class LJCInitialLoadMakerResult
	Local nX      := 0 					// -- Variavel de controle
	Local nY      := 0 					// -- Variavel de controle 			
	Local oTabela := Nil 				// -- Objeto que reporesenta uma tabela
	Local cFilter := "" 				// -- Filtro extraido da coleção de tabelas
	Local cMarca  := "XYZ4546637633ZYX" // -- Marca que validará se é necessario a desencriptação de dado.

	If !Empty(oResult)

		For nX := 1 To Len(oResult:AOGROUPS)
			For nY := 1 tO Len(oResult:AOGROUPS[nX]:OTRANSFERTABLES:AOTABLES)
				
				oTabela := oResult:AOGROUPS[nX]:OTRANSFERTABLES:AOTABLES[nY]
				
				If AttIsMemberOf(oTabela, "cFilter")
					cFilter := oTabela:cFilter
					If !Empty(cFilter)
						If FwIsInCallStack("Encrypt")
							oTabela:cFilter := Encode64(cFilter) + cMarca
						Else	
							If cMarca $ cFilter // -- Verifico se preciso tratar o conteudo
								oTabela:cFilter := Decode64(StrTran(cFilter,cMarca,""))
							Endif 
						EndIf
					EndIf  
				EndIf
			Next
		Next
	EndIf
Return  

//--------------------------------------------------------------------------------
/*/{Protheus.doc} Encrypt()

Metodo de entrada para criptação de um dado

@param oResult, Objeto, Objeto que representa uma coleção de tabelas
@return Nenhum

@author Lucas Novais Silva (lnovais@)
@since 12/04/2021
/*/
//--------------------------------------------------------------------------------

Method Encrypt(oResult) Class LJCInitialLoadMakerResult
	Self:AdjustFilter(oResult)
Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} Decrypt()

Metodo de entrada para decriptação de um dado

@param oResult, Objeto, Objeto que representa uma coleção de tabelas
@return Nenhum

@author Lucas Novais Silva (lnovais@)
@since 12/04/2021
/*/
//--------------------------------------------------------------------------------

Method Decrypt(oResult) Class LJCInitialLoadMakerResult
	Self:AdjustFilter(oResult)
Return