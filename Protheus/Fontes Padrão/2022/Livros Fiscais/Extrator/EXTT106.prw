#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtT106
Função responsável pela geração do registro T106 do Layout TAF 
Informações Provenientes da DIPJ

@Param cArqMerc   - Nome do Arquivo de Trabalho com as informações necessárias para geração
		dDataAte   - Data final do período de processamento
		lVndaPjExt - PJ Efetuou Vendas a Comercial Exportadora ( .F. - Nao, .T. Sim )

@author Rodrigo Aguilar
@since 05/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
function ExtT106( cArqMerc, dDataAte, lVndaPjExp )

local cRegistro := ''
local cCGC      := ''
local cSepar    := '|'

local nPos := 0
local nx := 0

local aRegT106 := {}

//Somente processo este registro quando o cliente realizou vendas ao exterior
if lVndaPjExp

	dbSelectArea(cArqMerc)
	(cArqMerc)->( dbSetOrder( 2 ) )
	
	//Somente considero operações de saída
	if (cArqMerc)->( MsSeek( 'S' ) )
	
		while (cArqMerc)->( !Eof() ) .and. (cArqMerc)->TIPO == 'S'  
			
			//Guardo o código do CNPJ da comercial exportadora adquirente
			cCGC := Alltrim( (cArqMerc)->CGC )
			
			//Somente gera o registro para os CFOP´s abaixo
		   	if Alltrim( (cArqMerc)->CFO ) $ '5501/5502/6501/6502' 
		   		
		   		//Realizo a quebra do registro por NCM + CGC da Comercial exportadora
		   		nPos := aScan( aRegT106, { |x| x[4] == Alltrim( (cArqMerc)->NBM ).and. x[3] == Alltrim( cCGC ) } )		   		 
				if nPos == 0
					aadd( aRegT106,{ 'T106',;  
										dToS( dDataAte ),;
										Alltrim( cCGC ),;  													
										Alltrim( (cArqMerc)->NBM ),; 
										(cArqMerc)->VALOR } )   
				else
					aRegT106[nPos,5] += (cArqMerc)->VALOR
					
				endif
		   	endif		   	
			(cArqMerc)->( dbskip() )
				
		endDo
		
		for nx := 1 to len( aRegT106 )
			
			cCGC := aRegT106[ nx, 03 ]
			cCGC := StrTran( cCGC , '.', '' )
			cCGC := StrTran( cCGC , '/', '' )
			cCGC := StrTran( cCGC , '-', '' )
			
			cRegistro   := cSepar
			cRegistro   += aRegT106[ nx, 01 ] + cSepar													//REGISTRO	
			cRegistro   += aRegT106[ nx, 02 ] + cSepar													//PERIODO
			cRegistro   += Alltrim( cCGC ) + cSepar														//CNPJ_EXP
			cRegistro   += Alltrim( StrTran( aRegT106[ nx, 04 ], '.', '' ) ) + cSepar					//COD_NCM
			cRegistro   += Val2Str( aRegT106[ nx, 05 ], 19, 2 ) + cSepar								//VL_VENDA

			//Função para realizar a gravação na tabela TAFST1
			ECFParseDIPJ( cRegistro )
				   
		next
		
	endif
endif

return ( nil )