#Include "Protheus.ch"

#DEFINE	FP_A1_VINCULO	1
#DEFINE	FP_A1_TRIBFAV	2

static	aX3Cache	:=	T097X3Cache()

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtT097

@Return

@author Luccas Curcio
@since 08/09/2015
@version  

/*/
//-------------------------------------------------------------------
function ExtT097( cPessoaVinc , cTpExp , cMetodo , dDataAte, aTotalProd, aTotal )

local	aAreaSB1	:=	SB1->( getArea() )
local	aAreaSA1	:=	SA1->( getArea() )
local	aAreaSAH	:=	SAH->( getArea() )
local	aFicha30	:=	{}
local	aFicha31	:=	{}
local  aUnidades  := {}

local	cUmECF		:=	''
local	cUm			:=	''
local	cStrST1		:=	''
local	cProduto	:=	''
local  cOrdem     := '000000000'

local	nPosF31		:=	0
local	nReg		:=	0

if '1' $ cPessoaVinc  
	
	SAI->( dbGoTop() )
	SAI->( dbSetOrder( 2 ) )  
	
	ENT->( dbSetOrder( 1 ) ) 
	
	SB1->( dbSetOrder( 1 ) )                      	
	
	SA1->( dbSetOrder( 1 ) ) 			
	
	SAH->( dbSetOrder( 1 ) )
	
	while !SAI->( eof() )   
		
		if SA1->( msSeek( xFilial( 'SA1' ) + SAI->( CLIENTE + LOJA ) ) ) .And. SA1->A1_EST <> 'EX'
			SAI->( dbSkip() )  
			loop
		endif
		
		if empty(cProduto) .or. allTrim( SAI->PRODUTO ) == allTrim( cProduto )
		
			//Caso encontre novo produto, envio os dados do produto anterior para a TAFST1
			if nReg > 0
				T097ExpST1( aFicha30[ nReg ] , aFicha31 , dDataAte, cOrdem, cUmECF, @aUnidades )
				
				cUmECF := ''
				nReg   := 0
			endif
			
			//Limpo registro filho
			aFicha31	:=	{}
			
			aAdd( aFicha30 , { , , , , , , , ,0,0,0, , , , , , } )
			nReg	:=	len( aFicha30 )
			
			cProduto	:=	SAI->PRODUTO            			
			
			aFicha30[ nReg , 1 ]	:=	cTpExp
			
			nPosProd	:=	aScan( aTotalProd , { |x| x[ 1 ] == allTrim( cProduto ) .and. x[ 2 ] == 'S' } )
				
			//Descricao gera apenas quando Tipo de Exportaca 01 - Bens ; 02 - Servicos ; 03 - Bens                          
			if cTpExp $ '01|02|03' .and. SB1->( msSeek( xFilial( 'SB1' ) + cProduto ) ) 
				aFicha30[ nReg , 2 ]	:=	allTrim( SB1->B1_DESC )
		    else
				aFicha30[ nReg , 2 ]	:=	''
			endif
			
			//Total da Operacao gera apenas quando Tipo de Exportaca 01 - Bens ; 02 - Servicos ; 03 - Bens ; 05 - Nao especificadas
			if !( cTpExp $ '04' ) .and. nPosProd > 0 .and. aTotalProd[ nPosProd , 3 ] > 0
				aFicha30[ nReg , 3 ]	:=	aTotalProd[ nPosProd , 5 ]
			else
				aFicha30[ nReg , 3 ]	:=	0
			endif
			
			//Codigo NCM gera apenas quando Tipo de Exportaca 01 - Bens
			if cTpExp $ '01'
				aFicha30[ nReg , 4 ]	:=	a975Fill( A975Digit( SB1->B1_POSIPI ) , 8 )
			else
				aFicha30[ nReg , 4 ]	:=	''
			endif
			
			//Quantidade gera apenas quando Tipo de Exportaca 01 - Bens
			if cTpExp $ '01' .and. nPosProd > 0
				If Empty(aFicha30[ nReg , 5 ])
					aFicha30[ nReg , 5 ]	:=	aTotalProd[ nPosProd , 3 ]
				Else
					aFicha30[ nReg , 5 ]	+=	aTotalProd[ nPosProd , 3 ]				
				EndIf	
			else
				aFicha30[ nReg , 5 ]	:=	0
			endif
			
			//Unidade de Medida gera apenas quando Tipo de Exportaca 01 - Bens
			if cTpExp $ '01' .and. SAH->( msSeek( xFilial( 'SAH' ) + SB1->B1_UM ) ) 
			  	cUn := SAH->AH_UMRES  			    	
			  	do case             
				  	 
					case allTrim( cUn ) == upper("Quilograma Liquido")
						cUmECF := '13'
						cUm := 'QL'
					case allTrim( cUn ) == upper("Unidade")
						cUmECF := '15'
						cUm := 'UN'
		      		case allTrim( cUn ) == upper("Mil Unidades")
						cUmECF := '09'
						cUm := 'MU'
					case allTrim( cUn ) == upper("Par")
						cUmECF := '10'
						cUm := 'PAR'
		    		case allTrim( cUn ) == upper("Metro")
						cUmECF := '06'
						cUm := 'MTR'
		      		case allTrim( cUn ) == upper("Metro Quadrado")
						cUmECF := '08'
						cUm := 'MET2'
					case allTrim( cUn ) == upper("Metro Cubico")
						cUmECF := '07'
						cUm := 'MET3'
					case allTrim( cUn ) == upper("Litro")
						cUmECF := '04'
						cUm := 'LTR'
					case allTrim( cUn ) == upper("Megawatt Hora")
						cUmECF := '05'
						cUm := 'MGWH'
					case allTrim( cUn ) == upper("Quilate")
						cUmECF := '11'
						cUm := 'QL'
					case allTrim( cUn ) == upper("Duzia")
						cUmECF := '02'
						cUm := 'DZ'
					case allTrim( cUn ) == upper("Tonelada Metrica Liquida")
						cUmECF := '14'
						cUm := 'TML'
					case allTrim( cUn ) == upper("Grama")	
						cUmECF := '03'
						cUm := 'GR'
					case allTrim( cUn ) == upper("Bilhao de Unidade Internacioanal")
						cUmECF := '01'
						cUm := 'BUI'
					case allTrim( cUn ) == upper("Quilograma Bruto")
						cUmECF := '12'
						cUm		:= 'QB'
						
				endcase   			    	   
				aFicha30[ nReg , 6 ]	:=	cUmECF
			else
				aFicha30[ nReg , 6 ]	:=	''
			endif
			
			//Operacao Sujeita a Arbitramento
			if cTpExp $ '01|02|03'
				aFicha30[ nReg , 7 ]	:=	'1'	//1 - Sim
			else
				aFicha30[ nReg , 7 ]	:=	'2' //2 - Nao
			endif
			
			//Metodo
			if cTpExp $ '01|02|03'
				aFicha30[ nReg , 8 ]	:=	cMetodo
			else
				aFicha30[ nReg , 8 ]	:=	''
			endif
			
			//Preco Parametro ; Praticado ; Valor do Ajuste
			if len( aTotal ) > 0
				nPosProd	:=	aScan( aTotal , { |x| allTrim( x[ 1 ] ) == allTrim( cProduto ) .and. x[ 13 ] == 'S' } )
			endif
			
			if nPosProd > 0
				
				//Preco Parametro
				aFicha30[ nReg , 9 ]	:=	aTotal[ nPosProd , 25 ]
				
				//Preco Praticado
				if cTpExp $ '01|02|03'
					aFicha30[ nReg , 10 ]	:=	aTotal[ nPosProd , 4 ]
				endif
				
				//Valor do Ajuste
				if cTpExp $ '01|02|03'
					aFicha30[ nReg , 11 ]	:=	aTotal[ nPosProd , 27 ]
				endif
				
			else
				aFicha30[ nReg , 9 ]	:=	0
				aFicha30[ nReg , 10 ]	:=	0
				aFicha30[ nReg , 11 ]	:=	0
			endif
			
			//Juros
			aFicha30[ nReg , 12 ]	:=	0
			
			//Taxa de Juros Minima
			aFicha30[ nReg , 13 ]	:=	0
			
			//Taxa de Juros Maxima
			aFicha30[ nReg , 14 ]	:=	0
			
			//Codigo CNC
			aFicha30[ nReg , 15 ]	:=	''
			
			//Moeda
			aFicha30[ nReg , 16 ]	:=	''
		
		endif
				
		//Verifico se o cliente ja foi incluido no array aFicha31 e algutino valores	
		if ( nPosF31	:=	aScan( aFicha31 , { |x| allTrim( x[ 1 ] ) == allTrim( SAI->DESCCLI ) } ) ) == 0
			
			aAdd( aFicha31 , { , , , , } )
			nPosF31	:=	len( aFicha31 )
			
			//Nome da Pessoa (Juridica/Fisica)
			aFicha31[ nPosF31 , 1 ]	:=	SAI->DESCCLI
			
			//Pais				
			aFicha31[ nPosF31 , 2 ]	:=	SA1->A1_PAIS                 
			
			//Valor da Operacao
			aFicha31[ nPosF31 , 3 ]	:=	SAI->TOTAL
			
			if aX3Cache[ FP_A1_VINCULO ] .and. aX3Cache[ FP_A1_TRIBFAV ]
				if !( empty( SA1->A1_VINCULO ) )
					aFicha31[ nPosF31 , 4 ]	:=	'01'
				elseif SA1->A1_TRIBFAV == '1'
					aFicha31[ nPosF31 , 4 ]	:=	'03'
				else
					aFicha31[ nPosF31 , 4 ]	:=	'02'
				endif
			endif
			
		else
			//Valor da Operacao
			aFicha31[ nPosF31 , 3 ]	+=	SAI->TOTAL
		endif
		
		SAI->( dbSkip() )
		
 	enddo

	//Tratamento para gravar o ultimo registro da base de dados
	if nReg > 0
		cOrdem := Soma1( cOrdem )
		T097ExpST1( aFicha30[ nReg ] , aFicha31 , dDataAte, cOrdem, cUmECF, @aUnidades )
	endif

endif

restArea( aAreaSB1 )
restArea( aAreaSA1 )
restArea( aAreaSAH )

return

//-------------------------------------------------------------------
/*/{Protheus.doc} T097X3Cache


@author Luccas Curcio
@since 08/09/2015
@version  

/*/
//-------------------------------------------------------------------
function T097X3Cache()

local	aCache	:=	{}

aAdd( aCache , SA1->( fieldPos( 'A1_VINCULO' ) ) > 0 )
aAdd( aCache , SA1->( fieldPos( 'A1_TRIBFAV' ) ) > 0 )

return aCache

//-------------------------------------------------------------------
/*/{Protheus.doc} T097ExpST1

@author Luccas Curcio
@since 08/09/2015
@version  

/*/
//-------------------------------------------------------------------
static function T097ExpST1( aFicha30 , aFicha31 , dDataAte, cOrdem, cUmECF, aUnidades  )

local  cStrST1 := ''
local  cStrUn := ''
local	nCntT097AA	:=	0

//Exportacao dos dados para a tabela TAFST1
cStrST1	:=	'|T097'															//T097
cStrST1	+=	'|' + dToS( dDataAte )											//Periodo
cStrST1	+=	'|' + cOrdem														//Num_ordem
cStrST1	+=	'|' + alltrim( aFicha30[ 1 ] )							//Tipo de Exportacao
cStrST1	+=	'|' + allTrim( aFicha30[ 2 ] )									//Descricao
cStrST1	+=	'|' + Val2Str( aFicha30[ 3 ] , 19 , 2 )						//Total da Operacao
cStrST1	+=	'|' + alltrim (aFicha30[ 4 ] ) 									//NCM
cStrST1	+=	'|' + Val2Str( aFicha30[ 5 ] , 19 , 2 )						//Quantidade

//Integro os dados da unidade de medida utilizada
if !empty( aFicha30[ 6 ] ) .and. ( aScan( aUnidades, { |x| x == Alltrim( SAH->AH_UNIMED ) }) <= 0 )
	if SAH->( msSeek( xFilial( 'SAH' ) + aFicha30[ 6 ] ) )
		cStrUn  := '|T005'
		cStrUn  += '|' + Alltrim( SAH->AH_UNIMED )
		cStrUn  += '|' + Alltrim( SAH->AH_DESCPO )
		cStrUn  += '|' + Alltrim( cUmECF ) + '|'
		
		ECFParseDIPJ( cStrUn, cOrdem )
		
		aadd( aUnidades, Alltrim( SAH->AH_UNIMED ) )
	endif
endif

cStrST1	+=	'|' + cValToChar( aFicha30[ 6 ] ) 								//Unidade de Medida
cStrST1	+=	'|' + alltrim( aFicha30[ 7 ] )											//Operacao Sujeita a Arbitramento
cStrST1	+=	'|' + alltrim( aFicha30[ 8 ]  )							//Metodo
cStrST1	+=	'|' + Val2Str( aFicha30[ 9 ] , 19 , 2 ) 	//Preco Parametro
cStrST1	+=	'|' + Val2Str( aFicha30[ 10 ] , 19 , 2 )		//Preco Praticado
cStrST1	+=	'|' + Val2Str( aFicha30[ 11 ] , 19 , 2 ) 	//Valor do Ajuste
cStrST1	+=	'|' + Val2Str( aFicha30[ 12 ] , 7 , 4 )	//Taxa de Juros
cStrST1	+=	'|' + Val2Str( aFicha30[ 13 ] , 7 , 4 ) 	//Taxa de Juros Minima
cStrST1	+=	'|' + Val2Str( aFicha30[ 14 ] , 7 , 4 )	//Taxa de Juros Maxima
cStrST1	+=	'|' + alltrim( aFicha30[ 15 ] )							//CNC
cStrST1	+=	'|' + alltrim( aFicha30[ 16 ]  ) + '|'						//Moeda

aSort( aFicha31 , , , { |x,y| x[ 3 ] > y[ 3 ] } )

for nCntT097AA := 1 to len( aFicha31 )

	cStrST1	+=	CRLF
	cStrST1	+=	'|T097AA'	//T097AA
	cStrST1	+=	'|' + allTrim( aFicha31[ nCntT097AA , 1 ] )									//Nome
	cStrST1	+=	'|' + allTrim( aFicha31[ nCntT097AA , 2 ] )									//Pais
	cStrST1	+=	'|' + Val2Str( aFicha31[ nCntT097AA , 3 ] , 19 , 2 ) 	//Valor da Operacao
	cStrST1	+=	'|' + alltrim( aFicha31[ nCntT097AA , 4 ])  + '|'	//Condicao da pessoa envolvida	
	
	if nCntT097AA == 30
		exit
	endif
	
next

ECFParseDIPJ( cStrST1, cOrdem )

return