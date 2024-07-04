#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtT118
Função responsável pela geração do registro T118 do Layout TAF 
Informações Provenientes da DIPJ

@Param 	dDataAte   - Data final do período de processamento
		cAlterCap  - Alteracao de capital ? ( 0 - Não Preenchido, 1 - Sim, 2 - Não )
		cEscBcCsll - Opcao escrit. no ativo, da base de calculo negativa da CSLL ( 0 - Não preenchido, 1 - Não, 2 - Sim )

@author Rodrigo Aguilar
@since 05/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
function ExtT118( dDataAte, cAlterCap, cEscBcCsll )

local cRegistro := ''
local cSepar    := '|'

cRegistro   := cSepar
cRegistro   += 'T118' + cSepar						//REGISTRO
cRegistro   += dToS( dDataAte ) + cSepar  		//PERIODO
cRegistro   += '0' + cSepar 						//VL_AQ_MAQ
cRegistro   += '0' + cSepar   						//VL_DOA_CRIANCA
cRegistro   += '0' + cSepar  						//VL_DOA_IDOSO
cRegistro   += '0' + cSepar 						//VL_AQ_IMOBILIZADO
cRegistro   += '0' + cSepar 						//VL_BX_IMOBILIZADO
cRegistro   += '0' + cSepar 						//VL_INC_INI
cRegistro   += '0' + cSepar 						//VL_INC_FIN
cRegistro   += '0' + cSepar 						//VL_CSLL_DEPREC_INI
cRegistro   += '0' + cSepar							//VL_DIF_IC_VC 
cRegistro   += '0' + cSepar  						//VL_OC_SEM_IOF
cRegistro   += '0' + cSepar							//VL_FOLHA_ALIQ_RED
cRegistro   += '0' + cSepar							//VL_ALIQ_RED  
cRegistro   += Alltrim( cAlterCap  )  + cSepar   //IND_ALTER_CAPITAL
cRegistro   += Alltrim( cEscBcCsll )  + cSepar	//IND_BCN_CSLL

//Função para realizar a gravação na tabela TAFST1
ECFParseDIPJ( cRegistro )

return ( nil )

