#Include "Protheus.ch"

#DEFINE	FP_A2_VINCULO	1
#DEFINE	FP_A2_TRIBFAV	2

static	aX3Cache	:=	T097X3Cache()

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtT098

@author Luccas Curcio
@since 08/09/2015
@version  

/*/
//-------------------------------------------------------------------
function ExtT098( cTpImp , cMetodo , dDataAte, aTotalProd, aTotal )

local aAreaSB1	 :=	SB1->( getArea() )
local aAreaSA2	 :=	SA2->( getArea() )
local aAreaSAH	 :=	SAH->( getArea() )
local aFicha32	 :=	{}
local aFicha33	 :=	{}
local aUnidades  := {}
local cUmECF	 :=	''
local cUm		 :=	''
local cProduto	 :=	''
local cOrdem     := '000000000'
local nPosF33	 :=	0
local nReg		 :=	0
local nPrcPrtEnt := 0
Local nPosProdE  := 0
Local nPosTotE   := 0
local lMVEASY    := SuperGetMV("MV_EASY") == "S"

ENT->( dbGoTop () )
ENT->( dbSetOrder( 2 ) )

SAI->( dbSetOrder( 1 ) )

SB1->( dbSetOrder( 1 ) )

SAH->( dbSetOrder( 1 ) )

SA2->( dbSetOrder( 1 ) )

while !( ENT->( eof() ) )
	if !( allTrim( ENT->PRODUTO ) == alltrim( cProduto ) )
		cProduto :=	ENT->PRODUTO
		nPosProdE  := 0
		nPosTotE   := 0
		nPrcPrtEnt := 0
		nTotOper   := 0

		//Caso encontre novo produto, envio os dados do produto anterior para a TAFST1
		if nReg > 0
			cOrdem := Soma1( cOrdem )
			T098ExpST1( aFicha32[ nReg ] , aFicha33 , dDataAte, cOrdem, cUmECF, @aUnidades )
			cUmECF := ''
			nReg   := 0
		endif

		//Limpo registro filho
		aFicha33 :=	{}
		aAdd( aFicha32 , { , ,0, ,0, , , ,0,0,0,0,0,0, , , } )
		nReg :=	len( aFicha32 )
		aFicha32[ nReg , 1 ] :=	cTpImp 
							
		//Descricao gera apenas quando Tipo de Importacao 01 - Bens ; 02 - Servicos ; 03 - Bens                          
		if cTpImp $ '01|02|03' .and. SB1->( msSeek( xFilial( 'SB1' ) + cProduto ) ) 
			aFicha32[ nReg , 2 ] :=	allTrim( SB1->B1_DESC )
	    else
			aFicha32[ nReg , 2 ] :=	''
		endif

		//Total da Operacao gera apenas quando Tipo de Importacao 01 - Bens ; 02 - Servicos ; 03 - Bens ; 05 - Nao especificadas
		nPosProdE := aScan( aTotalProd , { |x| x[ 1 ] == allTrim( ENT->PRODUTO ) .and. x[ 2 ] == 'E' } )
		
		if !( cTpImp $ '04' ) .and. nPosProdE > 0 .and. aTotalProd[ nPosProdE , 3 ] > 0
			nTotOper := aTotalProd[ nPosProdE , 5 ]
		else
			nTotOper :=	0
		endif
		
		aFicha32[ nReg , 3 ] := nTotOper
		
		//Codigo NCM gera apenas quando Tipo de Importacao 01 - Bens
		if cTpImp $ '01'
			aFicha32[ nReg , 4 ] :=	a975Fill( A975Digit( SB1->B1_POSIPI ) , 8 )
		else
			aFicha32[ nReg , 4 ] :=	''
		endif
		
		//Quantidade gera apenas quando Tipo de Importacao 01 - Bens
		if cTpImp $ '01' .and. nPosProdE > 0
			aFicha32[ nReg , 5 ] :=	aTotalProd[ nPosProdE , 3 ]
		endif
		
		//Unidade de Medida gera apenas quando Tipo de Exportaca 01 - Bens
		if cTpImp $ '01' .and. SAH->( msSeek( xFilial( 'SAH' ) + SB1->B1_UM ) ) 
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
			aFicha32[ nReg , 6 ] :=	cUm
		else
			aFicha32[ nReg , 6 ] :=	''
		endif
		
		//Metodo
		if cTpImp $ '01|02|03'
			aFicha32[ nReg , 8 ] :=	cMetodo
		else
			aFicha32[ nReg , 8 ] :=	''
		endif
		
		//Preco Parametro ; Praticado ; Valor do Ajuste
		if len( aTotal ) > 0
			nPosTotE := aScan( aTotal , { |x| allTrim( x[ 1 ] ) == allTrim( cProduto ) .and. x[ 13 ] == 'S' } )
		endif
		
		if nPosTotE > 0
			//Preco Parametro
			aFicha32[ nReg , 9 ] :=	aTotal[ nPosTotE , 25 ]

			//Preco Praticado
			if cTpImp $ '01|02|03' .and. nPosProdE > 0
				if !lMVEASY
					nPrcPrtEnt := ( ENT->TOTALD1 - ENT->ADICAO )
					aFicha32[ nReg , 10 ] := nPrcPrtEnt / aTotalProd[ nPosProdE , 3 ]
				else
					nPrcPrtEnt := ENT->PRECOUNIT
					aFicha32[ nReg , 10 ] := nPrcPrtEnt
				endif
			endif
			
			//Valor do Ajuste
			if cTpImp $ '01|02|03'
				aFicha32[ nReg , 11 ] := aTotal[ nPosTotE , 27 ]
			endif
		endif
		
		//Codigo CNC
		aFicha32[ nReg , 15 ] := ''
		
		//Moeda
		aFicha32[ nReg , 16 ] := ''
	else	
		//Preco Praticado
		if cTpImp $ '01|02|03' .and. nPosProdE > 0
			if !lMVEASY
				nPrcPrtEnt += ( ENT->TOTALD1 - ENT->ADICAO )
				aFicha32[ nReg , 10 ] := nPrcPrtEnt / aTotalProd[ nPosProdE , 3 ]
			else
				nPrcPrtEnt += ENT->PRECOUNIT
				aFicha32[ nReg , 10 ] := nPrcPrtEnt
			endif
		endif
	endif


	//Verifico se o cliente ja foi incluido no array aFicha33 e algutino valores	
	if ( nPosF33 :=	aScan( aFicha33 , { |x| allTrim( x[ 1 ] ) == allTrim( ENT->DESCFOR ) } ) ) == 0
		
		aAdd( aFicha33 , { , ,0, , } )
		nPosF33	:=	len( aFicha33 )
		
		//Nome da Pessoa (Juridica/Fisica)
		aFicha33[ nPosF33 , 1 ]	:=	ENT->DESCFOR
		
		//Pais				
		aFicha33[ nPosF33 , 2 ]	:=	SA1->A1_PAIS                 
		
		//Valor da Operacao
		aFicha33[ nPosF33 , 3 ]	:=	( ENT->PRECOUNIT * ENT->QUANTIDADE )
		
		if aX3Cache[ FP_A2_VINCULO ] .and. aX3Cache[ FP_A2_TRIBFAV ]
			if !( empty( SA2->A2_VINCULO ) )
				aFicha33[ nPosF33 , 4 ]	:=	'01'
			elseif SA2->A2_TRIBFAV == '1'
				aFicha33[ nPosF33 , 4 ]	:=	'03'
			else
				aFicha33[ nPosF33 , 4 ]	:=	'02'
			endif
		endif
	else
		aFicha33[ nPosF33 , 3 ]	+= ( ENT->PRECOUNIT * ENT->QUANTIDADE )
	endif
		
	ENT->(DbSkip())  
enddo

//Tratamento para gravar o ultimo registro da base de dados
if nReg > 0
	cOrdem := Soma1( cOrdem )
	T098ExpST1( aFicha32[ nReg ] , aFicha33 , dDataAte, cOrdem, cUmECF, @aUnidades )
endif

restArea( aAreaSB1 )
restArea( aAreaSA2 )
restArea( aAreaSAH )

return

//-------------------------------------------------------------------
/*/{Protheus.doc} T098X3Cache

@author Luccas Curcio
@since 08/09/2015
@version  

/*/
//-------------------------------------------------------------------
static function T098X3Cache()

local	aCache	:=	{}

aAdd( aCache , SA1->( fieldPos( 'A2_VINCULO' ) ) > 0 )
aAdd( aCache , SA1->( fieldPos( 'A2_TRIBFAV' ) ) > 0 )

return aCache

//-------------------------------------------------------------------
/*/{Protheus.doc} T098ExpST1

@author Luccas Curcio
@since 08/09/2015
@version  

/*/
//-------------------------------------------------------------------
static function T098ExpST1( aFicha32 , aFicha33 , dDataAte, cOrdem, cUmECF, aUnidades )

local  cStrST1    := ''
local  cStrUn     := ''
local	nCntT098AA	:=	0

//Exportacao dos dados para a tabela TAFST1
cStrST1	:=	'|T098'															 	//T098
cStrST1	+=	'|' + dToS( dDataAte )											 	//Periodo
cStrST1	+=	'|' + cOrdem 														 	//Num_ordem
cStrST1	+=	'|' + Alltrim( aFicha32[ 1 ] )									 	//Tipo de Exportacao
cStrST1	+=	'|' + AllTrim( aFicha32[ 2 ] )									 	//Descricao
cStrST1	+=	'|' + Val2Str( aFicha32[ 3 ] , 19 , 2 ) 						 	//Total da Operacao
cStrST1	+=	'|' + Alltrim( A975Digit( aFicha32[ 4 ] ) )					 	//NCM
cStrST1	+=	'|' + Val2Str( aFicha32[ 5 ] , 19 , 2 ) 						 	//Quantidade

//Integro os dados da unidade de medida utilizada
if !empty( aFicha32[ 6 ] ) .and. ( aScan( aUnidades, { |x| x == Alltrim( SAH->AH_UNIMED ) }) <= 0 )
	if SAH->( msSeek( xFilial( 'SAH' ) + aFicha32[ 6 ] ) )
		cStrUn  := '|T005'
		cStrUn  += '|' + Alltrim( SAH->AH_UNIMED )
		cStrUn  += '|' + Alltrim( SAH->AH_DESCPO )
		cStrUn  += '|' + Alltrim( cUmECF ) + '|'
		
		ECFParseDIPJ( cStrUn, cOrdem )
		
		aadd( aUnidades, Alltrim( SAH->AH_UNIMED ) )
	endif
endif

cStrST1	+=	'|' + cValToChar( aFicha32[ 6 ] )								 	//Unidade de Medida
cStrST1	+=	'|' + Alltrim( Str( val( aFicha32[ 8 ] ) )  )					 	//M	etodo
cStrST1	+=	'|' + Val2Str( aFicha32[ 9 ] , 19 , 2 ) 						 	//Preco Parametro
cStrST1	+=	'|' + Val2Str( aFicha32[ 10 ], 19, 2 )								//Preco Praticado
cStrST1	+=	'|' + Val2Str( aFicha32[ 11 ] , 19 , 2 )							//Valor do Ajuste
cStrST1	+=	'|' + Val2Str( aFicha32[ 12 ] , 7 , 4 ) 							//Taxa de Juros
cStrST1	+=	'|' + Val2Str( aFicha32[ 13 ] , 7 , 4 ) 							//Taxa de Juros Minima
cStrST1	+=	'|' + Val2Str( aFicha32[ 14 ] , 7 , 4 ) 							//Taxa de Juros Maxima
cStrST1	+=	'|' + Alltrim( aFicha32[ 15 ] )										//CNC
cStrST1	+=	'|' + Alltrim( aFicha32[ 16 ] ) + '|'								//Moeda

aSort( aFicha33 , , , { |x,y| x[ 3 ] > y[ 3 ] } )

for nCntT098AA := 1 to len( aFicha33 )

	cStrST1	+=	CRLF
	cStrST1	+=	'|T098AA'															//T098AA
	cStrST1	+=	'|' + AllTrim( aFicha33[ nCntT098AA , 1 ] )					//Nome
	cStrST1	+=	'|' + AllTrim( aFicha33[ nCntT098AA , 2 ] )					//Pais
	cStrST1	+=	'|' + Val2Str( aFicha33[ nCntT098AA , 3 ] , 19 , 2 )			//Valor da Operacao
	cStrST1	+=	'|' + Alltrim( aFicha33[ nCntT098AA , 4 ] ) + '|'			//Condicao da pessoa envolvida	
	
	if nCntT098AA == 30
		exit
	endif
	
next

ECFParseDIPJ( cStrST1, cOrdem )

return
