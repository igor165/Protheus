#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtT107
Função responsável pela geração do registro T107 do Layout TAF 
Informações Provenientes da DIPJ

@Param cArqMerc   - Nome do Arquivo de Trabalho com as informações necessárias para geração
		dDataDe    - Data inicial do período de processamento
		dDataAte   - Data final do período de processamento
		lPjComExp  - PJ Comercial Exportadora ( .F. - Nao, .T. - Sim )

@author Rodrigo Aguilar
@since 05/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
function ExtT107( cArqMerc, dDateDe, dDataAte, lPjComExp )

local cRegistro := ''
local cSepar    := '|'

local nPos := 0
local nx   := 0
 
local cAliasSD2 := GetNextAlias()

local aRegT107S := {}
local aRegT107  := {}

local aRastro  := {}
local aAuxLote := {}
 
local cRecnoSD2 := 0

//Apenas realizo a execução quando PJ Comercial Exportadora igual a Sim                       
if lPjComExp
	
	//Executa a Query para buscar as informações a serem geradas pelo movimento	            	      				  		   	
	BeginSql Alias cAliasSD2    	
		
		SELECT 
			D2_EMISSAO, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_LOTECTL, D2_TOTAL, D2_COD , D2_DOC 
		FROM 
			%table:SD2% SD2,%table:SB1% SB1
		WHERE 
			SD2.D2_FILIAL=%xFilial:SD2% AND 
			SD2.D2_EMISSAO>=%Exp:DToS (dDateDe)% AND 
			SD2.D2_EMISSAO<=%Exp:DToS (dDataAte)% AND
			SD2.%NotDel% AND 
			SB1.B1_FILIAL = %xFilial:SB1% AND
	   		SB1.B1_COD = D2_COD AND
	   		SB1.%NotDel% 			               			
	EndSql 

	DbSelectArea(cAliasSD2)
	(cAliasSD2)->( DbGoTop() )	
	while (cAliasSD2)->( !Eof() )
		
		//Busco o Rastro da Nota Fiscal pela sua chave			
		aRastro:= RastroNFOr( (cAliasSD2)->D2_DOC, (cAliasSD2)->D2_SERIE, (cAliasSD2)->D2_CLIENTE, (cAliasSD2)->D2_LOJA )			
		
		//Zero o array auxiliar por documento fiscal
		aAuxLote :={}		
		for nx := 1 to len( aRastro )		
			
			nPos	:=	aScan( aAuxLote, { |x| x[ 1 ] == aRastro[ nx ][ 3 ] .and. x[ 2 ] == aRastro[ nx ][ 44 ] } )			
			if nPos > 0
				aAuxLote[ nPos, 3 ] += aRastro[ nx ][ 5 ]				
			else
				aAdd( aAuxLote,{ aRastro[nx][3], aRastro[nx][44], aRastro[nx][5] } )				
			endif			
			
		next 
				   		
		nPos := aScan( aAuxLote, { |x| x[1] == (cAliasSD2)->D2_COD .and. x[2] == (cAliasSD2)->D2_LOTECTL } )	   

		//seto indice de busca na SA2		 
		SA2->( dbSetOrder( 1 ) )	   
	   if len( aRastro ) > 0 .and. SA2->( MsSeek( xFilial( 'SA2' ) + aRastro[ 1, 8 ] + aRastro[ 1, 9 ] ) )
	   
			if alltrim( aRastro[ 1, 34 ] ) $ '7501' .and. alltrim( aRastro[ 1, 31 ] ) $ '1501/2501'
				 
				 aadd( aRegT107S, { 'T107',;    
				 					  dToS( dDataAte ),;
				   					  substr( SA2->A2_CGC, 01, 14 ),;
				   					  SB1->B1_POSIPI,;
				 					  aAuxLote[ nPos, 3 ],;
				 					  (cAliasSD2)->D2_TOTAL } )				 
			endif 			
		endif
					
		(cAliasSD2)->( dbskip() )
	enddo
	
	//Atraves do array aRegT107S alimento o array padrão aRegT107
	for nx := 1 to len( aRegT107S )
		
		nPos := aScan( aRegT107, { |x| x[ 3 ] == aRegT107S[ nx ][ 3 ] .And. x[ 4 ] == aRegT107S[ nx ][ 4 ] } )
		
		if nPos  > 0
			aRegT107[ npos, 05 ] += aRegT107s[ nx, 05 ]
			aRegT107[ npos, 06 ] += aRegT107s[ nx, 06 ]
		
		else
			aAdd( aRegT107, aRegT107S[ nx ] )
			
		endif
		
	next 
	
	for nx := 1 to len( aRegT107 )

			cRegistro   := cSepar
			cRegistro   += aRegT107[ nx, 01 ] + cSepar							//REGISTRO	
			cRegistro   += aRegT107[ nx, 02 ] + cSepar							//PERIODO
			cRegistro   += Alltrim( aRegT107[ nx, 03 ] ) + cSepar				//CNPJ
			cRegistro   += Alltrim( aRegT107[ nx, 04 ] ) + cSepar  				//COD_NCM
			cRegistro   += Val2Str( aRegT107[ nx, 05 ], 19, 2 ) + cSepar		//VL_COMPRA
			cRegistro   += Val2Str( aRegT107[ nx, 06 ], 19, 2 ) + cSepar		//VL_EXP

			//Função para realizar a gravação na tabela TAFST1
			ECFParseDIPJ( cRegistro )
			
	next nx
	
	//Fecho o Arquivo de Trabalho
	dbSelectArea(cAliasSD2)
	dbCloseArea()
	
endif

return ( nil )