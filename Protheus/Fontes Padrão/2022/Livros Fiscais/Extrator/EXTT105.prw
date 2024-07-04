#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtT105
Função responsável pela geração do registro T105 do Layout TAF 
Informações Provenientes da DIPJ

@Param cArqMerc   - Nome do Arquivo de Trabalho com as informações necessárias para geração
		dDataAte   - Data final do período de processamento

@author Rodrigo Aguilar
@since 05/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
function ExtT105( cArqMerc, dDataAte, dDataDe )

local cRegistro  := '' 
local cSepar     := '|'
Local cAlias     := GetNextAlias( ) 

local  nPos	     := 0
local  nx        := 0

local  aRegT105	 := {}
Local  nValDevol := 0

dbSelectArea( cArqMerc )
(cArqMerc)->( dbSetOrder( 2 ) )

//Busco somente as movimentações de Saída
if (cArqMerc)->( MsSeek( 'S' ) )

	while (cArqMerc)->( !Eof() ) .and. (cArqMerc)->TIPO == 'S'
	
		//Realizo a quebra do registro por CNAE
		nPos := aScan( aRegT105, {|x| x[5] == Alltrim( SM0->M0_CNAE ) } )
		if nPos == 0
		
       	aadd( aRegT105, { 'T105',;
       		   				dToS( dDataAte ),; 
                 				Alltrim( SM0->M0_CGC ),;
			   	   				(cArqMerc)->VALOR,;
								Alltrim( SM0->M0_CNAE ) } )
		else
			aRegT105[ nPos, 4 ] += (cArqMerc)->VALOR
			
		endif
		
		(cArqMerc)->( dbSkip() )
	enddo

	// De acordo com o manual ECF, deve ser subtraído as devoluções do total da receita de vendas ( campo VL_REC_ESTAB )
	BeginSql alias cAlias
		SELECT
			SUM( SD1.D1_TOTAL ) D1_TOTAL
			,SUM( SD1.D1_VALDESC ) D1_VALDESC
		FROM %TABLE:SD2% SD2
		INNER JOIN %TABLE:SD1% SD1
			ON SD2.D2_FILIAL = SD1.D1_FILIAL
			AND SD2.D2_DOC = SD1.D1_NFORI
			AND SD2.D2_SERIE = SD1.D1_SERIORI
			AND SD2.D2_ITEM = SD1.D1_ITEMORI
			AND SD1.%NOTDEL%
		INNER JOIN %TABLE:SF4% SF4 
			ON SF4.F4_FILIAL =  %XFILIAL:SF4%
			AND SF4.F4_CODIGO = SD2.D2_TES
			AND SF4.F4_ISS <> 'S'
			AND SF4.F4_NRLIVRO = ' '
			AND SF4.%NOTDEL%
		WHERE SD2.D2_FILIAL =  %XFILIAL:SD2%
			AND SD2.D2_EMISSAO >= %EXP:DTOS(dDataDe)%
			AND SD2.D2_EMISSAO <= %EXP:DTOS(dDataAte)%
			AND SD2.%NOTDEL%
	EndSql

	If !( cAlias )->( EOF( ) )

		nValDevol := ( cAlias )->D1_TOTAL - ( cAlias )->D1_VALDESC

	EndIf
	( cAlias )->( DBCloseArea( ) )

	nPos := aScan( aRegT105, {|x| x[5] == Alltrim( SM0->M0_CNAE ) } )
	aRegT105[ nPos, 4 ] := aRegT105[ nPos, 4 ] - nValDevol

	for nx := 1 to len( aRegT105 )	
		
		cRegistro  := cSepar
		cRegistro  += aRegT105[ nx, 01 ] + cSepar												// REG
		cRegistro  += aRegT105[ nx, 02 ] + cSepar												// PERIODO
		cRegistro  += aRegT105[ nx, 03 ] + cSepar   											// CNPJ_ESTAB
	 	cRegistro  += Val2Str( aRegT105[ nx,04], 19, 2 ) + cSepar							// VL_REC_ESTAB 
		cRegistro  += aRegT105[ nx, 05 ] + cSepar		   										// CNAE	

		//Função para realizar a gravação na tabela TAFST1
		ECFParseDIPJ( cRegistro )
				
	next
	
endif
			
return ( nil )
