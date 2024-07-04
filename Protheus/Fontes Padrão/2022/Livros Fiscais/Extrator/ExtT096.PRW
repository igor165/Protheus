#Include "Protheus.ch"
#Include "TOPCONN.ch"

#DEFINE	FP_A1_VINCULO	1
#DEFINE	FP_A1_TRIBFAV	2
#DEFINE	FP_A2_VINCULO	3
#DEFINE	FP_A2_TRIBFAV	4	

static	aX3Cache	:=	T096X3Cache()

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtT096


@author Luccas Curcio
@since 08/09/2015
@version  

/*/
//-------------------------------------------------------------------
function ExtT096( cPessoaVinc , dDataAte )

local	aFicha29A	:=	{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 }
local	aFicha29B	:=	{ 0,0,0,0,0,0,0,0,0,0,0 }
local	aAreaSA1	:=	SA1->( getArea() )

local	lExpVinc	:=	.f.
local	lExpResid	:=	.f.
local  lGeraA		:= .f.
local  lGeraB		:= .f.
local	cStrST1		:=	''

//Exportacoes
SAI->( dbSetOrder( 2 ) )

SAI->( dbGoTop() )

SA1->( dbSetOrder( 1 ) )                      	

while !( SAI->( eof() ) )
	
	if SA1->( msSeek( xFilial( 'SA1' ) + SAI->( CLIENTE + LOJA ) ) ) .and. SA1->A1_PAIS <> "EX"
	
		lExpVinc  := aX3Cache[ FP_A1_VINCULO ] .and. !( empty( SA1->A1_VINCULO ) )
		lExpResid := aX3Cache[ FP_A1_TRIBFAV ] .and. SA1->A1_TRIBFAV == '1'
       
       //Verifica se nao eh servico
		if empty( SAI->CODISS )
			
			if lExpVinc
				aFicha29A[1] += SAI->TOTAL
			//else	
			//	aFicha29B[1] += SAI->TOTAL
			endif
				
			if lExpResid
				aFicha29A[2] += SAI->TOTAL
			endif
				
			if !lExpVinc .And. !lExpResid
				aFicha29B[1] += SAI->TOTAL
			endif				
			
		else
			
			if lExpVinc
				aFicha29A[4] += SAI->TOTAL
			//else
				//aFicha29B[2] += SAI->TOTAL
			endif
		
			if lExpResid
				aFicha29A[5] += SAI->TOTAL
			endif
		
			if !lExpVinc .And. !lExpResid 
				aFicha29B[2] += SAI->TOTAL
			endif				
			
		endif
    endif
	
	SAI->(DbSkip())

enddo			

//Importacoes
ENT->( dbGoTop() )

ENT->( dbSetOrder( 2 ) )

SA2->( dbSetOrder( 1 ) )  

While !ENT->( eof() )
	
	if SA2->( msSeek( xFilial( 'SA2' ) + ENT->( FORNEC + LOJA ) ) )
	
	    lImpVinc  := aX3Cache[ FP_A2_VINCULO ] .and. !( empty( SA2->A2_VINCULO ) )
  	    lImpResid := aX3Cache[ FP_A2_TRIBFAV ] .and. SA2->A2_TRIBFAV == '1'
    
       if Empty( ENT->CODISS )
	
			if lImpVinc
				aFicha29A[ 15 ] += ENT->TOTAL
		//	else
			//	aFicha29B[ 5 ] += ENT->TOTAL
			endif

			if lImpResid
				aFicha29A[ 16 ] += ENT->TOTAL
			endif

			if !lImpVinc .And. !lImpResid
				//aFicha29A[ 17 ] += ENT->TOTAL
				aFicha29B[ 5 ] += ENT->TOTAL
			endif				
		
		else
			if lImpVinc
				aFicha29A[ 18 ] += ENT->TOTAL
			//else
			//	aFicha29B[ 6 ] += ENT->TOTAL
			endif
	
			if lImpResid
				aFicha29A[ 19 ] += ENT->TOTAL
			endif
	
			if !lImpVinc .And. !lImpResid
				//aFicha29A[ 20 ] += ENT->TOTAL
				aFicha29B[ 6 ] += ENT->TOTAL
			endif				
	
		 endif
	
	endif
	
	ENT->(DbSkip())

enddo

T096GerAB(aFicha29A, aFicha29B, @lGeraA, @lGeraB ) 


//Se encontrou dados no Transfer Price 
if lGeraA .or. lGeraB
	
	If lGeraA .And. Alltrim(cPessoaVinc) == '1' //Possui operacoes com Pessoa vinculada
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Exportacoes de Bens para Pessoas Vinculadas - Codigo 3 conforme tabela dinamica da ECF
		if aFicha29A[ 1 ] > 0
			cStrST1	:=	'|T096|X291|' + dToS( dDataAte ) + '|' + '3' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 1 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Exportacoes de Bens para Pessoas Residentes em Paises com Tributacao Favorecida - Codigo 4 conforme tabela dinamica da ECF  
		if aFicha29A[2] > 0
			cStrST1	:=	'|T096|X291|' + dToS( dDataAte ) + '|' + '4' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 2 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Demais Exportacoes de Bens - Codigo 5 conforme tabela dinamica da ECF  
		if aFicha29A[ 3 ] > 0
			cStrST1	:=	'|T096|X291|' + dToS( dDataAte ) + '|' + '5' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 3 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Exportações de Serviços para Pessoas Vinculadas - Codigo 7 conforme tabela dinamica da ECF  
		if aFicha29A[ 4 ] > 0
			cStrST1	:=	'|T096|X291|' + dToS( dDataAte ) + '|' + '7' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 4 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Exportações de Serviços para Pessoas Residentes em Países com Tributação Favorecida - Codigo 8 conforme tabela dinamica da ECF  
		if aFicha29A[ 5 ] > 0
			cStrST1	:=	'|T096|X291|' + dToS( dDataAte ) + '|' + '8' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 5 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Demais Exportações de Serviços - Codigo 9 conforme tabela dinamica da ECF  
		if aFicha29A[ 6 ] > 0
			cStrST1	:=	'|T096|X291|' + dToS( dDataAte ) + '|' + '9' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 6 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		/*
		// -----------------------------------------------------------------------------------------------------------------------------
		//Exportações de Direitos para Pessoas Vinculadas - Codigo 11 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '11' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 7 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Exportações de Direitos para Pessoas Residentes em Países com Tributação Favorecida - Codigo 12 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '12' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 8 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Demais Exportações de Direitos - Codigo 13 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '13' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 9 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Operações Não Registradas no Banco Central - Pessoas Vinculadas - Codigo 15 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '15' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 10 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Operações Não Registradas no Banco Central - Pessoas Residentes em Países com Tributação Favorecida - Pessoas Vinculadas - Codigo 16 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '16' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 11 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Operações Registradas no Banco Central - Pessoas Vinculadas - Codigo 17 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '17' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 12 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Operações Registradas no Banco Central - Pessoas Residentes em Países com Tributação Favorecida - Codigo 18 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '18' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 13 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Demais Receitas Auferidas - Codigo 19 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '19' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 14 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		*/
		// -----------------------------------------------------------------------------------------------------------------------------
		//Importações de Bens de Pessoas Vinculadas - Codigo 22 conforme tabela dinamica da ECF  
		if aFicha29A[ 15 ] > 0
			cStrST1	:=	'|T096|X291|' + dToS( dDataAte ) + '|' + '22' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 15 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Importações de Bens de Pessoas Residentes em Países com Tributação Favorecida - Codigo 23 conforme tabela dinamica da ECF  
		if aFicha29A[ 16 ] > 0
			cStrST1	:=	'|T096|X291|' + dToS( dDataAte ) + '|' + '23' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 16 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Demais Importações de Bens - Codigo 24 conforme tabela dinamica da ECF  
		if aFicha29A[ 17 ] > 0
			cStrST1	:=	'|T096|X291|' + dToS( dDataAte ) + '|' + '24' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 17 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Importações de Serviços de Pessoas Vinculadas - Codigo 26 conforme tabela dinamica da ECF  
		if aFicha29A[ 18 ] > 0
			cStrST1	:=	'|T096|X291|' + dToS( dDataAte ) + '|' + '26' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 18 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Importações de Serviços de Pessoas Residentes em Países com Tributação Favorecida - Codigo 27 conforme tabela dinamica da ECF  
		if aFicha29A[ 19 ] > 0
			cStrST1	:=	'|T096|X291|' + dToS( dDataAte ) + '|' + '27' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 19 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Demais Importações de Serviços - Codigo 28 conforme tabela dinamica da ECF  
		if aFicha29A[ 20 ] > 0
			cStrST1	:=	'|T096|X291|' + dToS( dDataAte ) + '|' + '28' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 20 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		/*
		// -----------------------------------------------------------------------------------------------------------------------------
		//Importações de Direitos de Pessoas Vinculadas - Codigo 30 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '30' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 21 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Importações de Direitos de Pessoas Residentes em Países com Tributação Favorecida - Codigo 31 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '31' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 22 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Demais Importações de Direitos - Codigo 32 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '32' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 23 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Operações Não Registradas no Banco Central - Pessoas Vinculadas - Codigo 34 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '34' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 24 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Operações Não Registradas no Banco Central - Pessoas Residentes em Países com Tributação Favorecida - Codigo 35 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '35' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 25 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Operações Registradas no Banco Central - Pessoas Vinculadas - Codigo 36 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '36' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 26 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Operações Registradas no Banco Central - Pessoas Residentes em Países com Tributação Favorecida - Codigo 37 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '37' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 27 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Demais Encargos Incorridos - Codigo 38 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '38' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 28 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Comissões e Corretagens Incorridas na Importação de Mercadorias - Codigo 40 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '40' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 29 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Seguros Incorridos na Importação de Mercadorias - Codigo 41 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '41' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 30 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Royalties Incorridos na Importação de Mercadorias - Codigo 42 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X291|' + periodo + '|' + '42' + '|' + a975Fill( A975Num2Chr( aFicha29A[ 31 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		*/
		   
	EndIF
	If lGeraB//Possui operacoes com Pessoa nao vinculada
	
		// -----------------------------------------------------------------------------------------------------------------------------
		//Total de Exportações de Bens - Codigo 2 conforme tabela dinamica da ECF  
		if aFicha29B[ 1 ] > 0
			cStrST1	:=	'|T096|X292|' + dToS( dDataAte ) + '|' + '2' + '|' + a975Fill( A975Num2Chr( aFicha29B[ 1 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Total de Exportações de Serviços - Codigo 3 conforme tabela dinamica da ECF  
		if aFicha29B[ 2 ] > 0
			cStrST1	:=	'|T096|X292|' + dToS( dDataAte ) + '|' + '3' + '|' + a975Fill( A975Num2Chr( aFicha29B[ 2 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
		/*
		// -----------------------------------------------------------------------------------------------------------------------------
		//Total de Exportações de Direitos - Codigo 4 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X292|' + periodo + '|' + '4' + '|' + a975Fill( A975Num2Chr( aFicha29B[ 3 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Total de Receitas Auferidas de Operações Financeiras - Codigo 5 conforme tabela dinamica da ECF  
		cStrST1	:=	'|T096|X292|' + periodo + '|' + '5' + '|' + a975Fill( A975Num2Chr( aFicha29B[ 4 ] , 14 , 2 ) , 14 ) + '|'
		ECFParseDIPJ( cStrST1 )
		// -----------------------------------------------------------------------------------------------------------------------------
		*/
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Total de Importações de Bens - Codigo 7 conforme tabela dinamica da ECF  
		if aFicha29B[ 5 ] > 0
			cStrST1	:=	'|T096|X292|' + dToS( dDataAte ) + '|' + '7' + '|' + a975Fill( A975Num2Chr( aFicha29B[ 5 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
  		// -----------------------------------------------------------------------------------------------------------------------------
		//Total de Importações de Serviços - Codigo 8 conforme tabela dinamica da ECF  
		if aFicha29B[ 6 ] > 0
			cStrST1	:=	'|T096|X292|' + dToS( dDataAte ) + '|' + '8' + '|' + a975Fill( A975Num2Chr( aFicha29B[ 6 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		/*
		// -----------------------------------------------------------------------------------------------------------------------------
		//Total de Importações de Direitos - Codigo 9 conforme tabela dinamica da ECF  
		if aFicha29B[ 7 ] > 0
			cStrST1	:=	'|T096|X292|' + periodo + '|' + '9' + '|' + a975Fill( A975Num2Chr( aFicha29B[ 7 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Total de Encargos Incorridos de Operações Financeiras - Codigo 10 conforme tabela dinamica da ECF  
		if aFicha29B[ 8 ] > 0
			cStrST1	:=	'|T096|X292|' + periodo + '|' + '10' + '|' + a975Fill( A975Num2Chr( aFicha29B[ 8 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Comissões e Corretagens Incorridas na Importação de Mercadorias - Codigo 12 conforme tabela dinamica da ECF  
		if aFicha29B[ 9 ] > 0
			cStrST1	:=	'|T096|X292|' + periodo + '|' + '12' + '|' + a975Fill( A975Num2Chr( aFicha29B[ 9 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Seguros Incorridos na Importação de Mercadorias - Codigo 13 conforme tabela dinamica da ECF  
		if aFicha29B[ 10 ] > 0
			cStrST1	:=	'|T096|X292|' + periodo + '|' + '13' + '|' + a975Fill( A975Num2Chr( aFicha29B[ 10 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		
		// -----------------------------------------------------------------------------------------------------------------------------
		//Royalties Incorridos na Importação de Mercadorias - Codigo 14 conforme tabela dinamica da ECF  
		if aFicha29B[ 11 ] > 0
			cStrST1	:=	'|T096|X292|' + periodo + '|' + '14' + '|' + a975Fill( A975Num2Chr( aFicha29B[ 11 ] , 14 , 2 ) , 14 ) + '|'
			ECFParseDIPJ( cStrST1 )
		endif
		// -----------------------------------------------------------------------------------------------------------------------------
		*/
	endif

endif

restArea( aAreaSA1 )

return

//-------------------------------------------------------------------
/*/{Protheus.doc} T096X3Cache

@Return

@author Luccas Curcio
@since 08/09/2015
@version  

/*/
//-------------------------------------------------------------------
static function T096X3Cache()

local	aCache	:=	{}

aAdd( aCache , SA1->( fieldPos( 'A1_VINCULO' ) ) > 0 )
aAdd( aCache , SA1->( fieldPos( 'A1_TRIBFAV' ) ) > 0 )
aAdd( aCache , SA1->( fieldPos( 'A2_VINCULO' ) ) > 0 )
aAdd( aCache , SA1->( fieldPos( 'A2_TRIBFAV' ) ) > 0 )

return aCache

//-------------------------------------------------------------------
/*/{Protheus.doc} T096GerAB
Função para verificação da necessidade de
geração das fichas 029A e 029B
@Return

@author Henrique Pereira
@since 17/08/2016
@version  

/*/
//-------------------------------------------------------------------

Static Function T096GerAB(aFicha29A, aFicha29B, lGeraA, lGeraB ) 
local x291 := 0
local x292 := 0

for x291 := 1 to len(aFicha29A)
	If aFicha29A[x291] > 0 
		lGeraA := .T.
		Exit 
	EndIf
next

for x292 := 1 to len(aFicha29B)
	If aFicha29B[x292] > 0 
		lGeraB := .T.
		Exit
	EndIf
next

return