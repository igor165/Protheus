#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJXDESC.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบClasse    ณDesconto  บAutor  ณMauro Sano          บ Data ณ  17/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse gerada paar fazer os calculos de desconto do modulo  บฑฑ
ฑฑบ          ณSIGALOJA.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Class Desconto	
	Method New() Constructor
	Method DescontoValor( nValor, nQtd, nVlrDesconto )
	Method DescontoPercentual( nValor, nQtd, nPrctDesconto )   
	Method ValidaValor( nPctDesc, nVlUnit, nQtd )                
	Method ValidaPercent( nVlDesc, nVlUnit, nQtd )  
	Method TotalValor( nTotal, nVlrTotDesc, nPercent )
	Method TotalPercent( nTotal, nVlrDesc )        
	Method CalcValDes( nValunit, nPercent, nQtd ) 
	Method CalcPerDes( nVlUnit, nValDesc, nQtd )      
EndClass	

Function LojxDesc()
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณNew       บAutor  ณMauro Sano          บ Data ณ  17/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInstancia o objeto Desconto                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method New() Class Desconto    
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณDescontoVaบAutor  ณMauro Sano          บ Data ณ  17/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz o calculo do desconto informando o valor do             บฑฑ
ฑฑบ          ณdesconto                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                    บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method DescontoValor( nValor, nQtd, nVlrDesconto ) Class Desconto   
Local nVlrItem := 0										// Valor retornado do item com desconto
Local cMvArreFat := SuperGetMV( "MV_ARREFAT",,"N" )	// Verifica parametro de arredondamento

If cMvArreFat == "S"
	nVlrItem := Round( ( ( ( nValor * nQtd ) - nVlrDesconto ) / nQtd ), nDecimais ) 
Else                                                                            
	nVlrItem := NoRound( ( ( ( nValor * nQtd ) - nVlrDesconto ) / nQtd ), nDecimais ) 
EndIf	
		

Return nVlrItem                                                    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณDescontoPeบAutor  ณMauro Sano          บ Data ณ  17/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz o calculo do desconto informando o percenteual  do      บฑฑ
ฑฑบ          ณdesconto                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method DescontoPercentual( nValor, nQtd, nPrctDesconto ) Class Desconto
Local nVlrItem := 0										// Valor retornado do item com desconto   
Local cMvArreFat := SuperGetMV( "MV_ARREFAT",,"N" )	// Verifica parametro de arredondamento

If cMvArreFat == "S"
	nVlrItem := Round( ( ( nValor * nQtd ) * ( (100 - nPrctDesconto) / 100 ) ) / nQtd, nDecimais )
Else
	nVlrItem := NoRound( ( ( nValor * nQtd ) * ( (100 - nPrctDesconto) / 100 ) ) / nQtd, nDecimais )		
EndIf	

Return( nVlrItem )         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณValidaValoบAutor  ณMauro Sano          บ Data ณ  21/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSe na tela foi digitado o percentual do desconto, calcula o บฑฑ
ฑฑบ          ณvalor.                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ValidaValor( nPctDesc, nVlUnit, nQtd ) Class Desconto    
Local nVlDesc := 0										// Retorna o valor do desconto   
Local cMvArreFat := SuperGetMV( "MV_ARREFAT",,"N" )	// Verifica se arredonda ou trunca
Local nDesconto := 0									// Auxiliar para calculo do desconto		

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalculo o valor do desconto pelo total da venda.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cMvArreFat == "S" 
	nVlDesc := Round( ( nPctDesc * (nVlunit / 100 ) ) * nQtd, nDecimais )
Else
	nVlDesc := NoRound( ( nPctDesc * (nVlunit / 100) ) * nQtd, nDecimais )		
EndIf	 
  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifico qual e' o desconto do item individualmente.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nDesconto := nVlUnit - ::DescontoPercentual( nVlUnit, nQtd, nPctDesc )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValor do desconto aferido deve ser igual ao ao valor doณ
//ณdesconto por item x Qtd, caso seja diferente vale o    ณ
//ณitem x qtd.                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cPaisLoc <> "ARG" .AND. cPaisLoc <> "MEX"
	If (nVlUnit - nDesconto) * nQtd <> nVlDesc
		nVlDesc := nDesconto * nQtd
	EndIf	
EndIf

Return( nVlDesc )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณValidaPercบAutor  ณMauro Sano          บ Data ณ  21/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSe na tela foi digitado o valor do desconto, calcula o      บฑฑ
ฑฑบ          ณpercentual.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ValidaPercent( nVlrDesc, nVlUnit, nQtd ) Class Desconto
Local nVlDesc := 0										// Retorna o valor do desconto          
Local cMvArreFat := SuperGetMV( "MV_ARREFAT",,"N" )	// Verifica se arredonda ou trunca
Local nDesconto := 0	   								// Auxiliar para calculo do desconto		

If cMvArreFat == "S"
	nVlDesc := Round( nVlDesc * 100 /nVlunit, nDecimais )
Else
	nVlDesc := NoRound( nVlDesc * 100 /nVlunit, nDecimais )		
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifico qual e' o desconto do item individualmente.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nDesconto := nVlUnit - ::DescontoValor( nVlUnit, nQtd, nVlDesc )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValor do desconto aferido deve ser igual ao ao valor doณ
//ณdesconto por item x Qtd, caso seja diferente vale o    ณ
//ณitem x qtd.                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (nVlUnit - nDesconto) * nQtd <> nVlDesc
	nVlDesc := nDesconto * nQtd
EndIf	

Return nVlDesc     
       
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณTotalValorบAutor  ณMauro Sano          บ Data ณ  21/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula o desconto no total do cupom, caso o usuario informeบฑฑ
ฑฑบ          ณo percentual.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                    บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method TotalValor( nTotal, nVlrTotDesc, nPercent ) Class Desconto
Local nVlDesc	 := 0																// Retorna o valor do desconto
Local cMvArreFat := SuperGetMV( "MV_ARREFAT",,"N" )									// Verifica parametro de arredondamento
Local lMvAjstDes := SuperGetMV( "MV_LJAJDES",,.F. )									// Verifica parametro ajuste de desconto no total da venda
Local nVlrICMSol := Lj7IcmsSol()													// Valor do ICMS Solidario 
Local nVlrIcmDed := LjVDItDedIcm(.T.)												// Valor de ICMS Desonerado / Deduzido considerando o campo F4_AGREG da TES

If lMvAjstDes
	nVlDesc := AjtDsc( nTotal + nVlrIcmDed + nVlrTotDesc - nVlrICMSol, nil, nPercent, 1 )
Else
	If cMvArreFat == "S"
		nVlDesc := Round( ( nTotal + nVlrTotDesc - nVlrICMSol) * nPercent / 100, nDecimais )
	Else
		nVlDesc := NoRound( ( nTotal + nVlrTotDesc - nVlrICMSol) * nPercent / 100, nDecimais )		
	Endif	
EndIf

Return nVlDesc
  
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณTotalPerceบAutor  ณMauro Sano          บ Data ณ  21/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula o percentual do desconto no total do cupom, caso o  บฑฑ
ฑฑบ          ณusuario informe o valor.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                    บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/    
Method TotalPercent( nTotal, nVlrTotDesc, nVlrDesc ) Class Desconto
Local nVlDesc		:= 0	   																	// Retorna o valor do desconto
Local cMvArreFat	:= SuperGetMV( "MV_ARREFAT",,"N" )											// Verifica parametro de arredondamento
Local lMvAjstDes	:= SuperGetMV( "MV_LJAJDES",,.F. )											// Verifica parametro ajuste de desconto
Local nVlrICMSol	:= Lj7ICMSSol()																// Valor do ICMS Solidario 
Local nVlrIcmDed 	:= LjVDItDedIcm(.T.)														// Valor de ICMS Desonerado / Deduzido considerando o campo F4_AGREG da TES

If lMvAjstDes
	nVlDesc := AjtDsc( nTotal + nVlrIcmDed + nVlrTotDesc - nVlrICMSol, nVlrDesc, nil, 2 )
Else
	If cMvArreFat == "S"
		nVlDesc := Round( nVlrDesc * 100/ ( nTotal + nVlrTotDesc ), nDecimais )
 	Else
		nVlDesc := NoRound( nVlrDesc * 100/ ( nTotal + nVlrTotDesc ), nDecimais )									
	EndIf
EndIf

Return nVlDesc

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณCalcValDesบAutor  ณVendas CRM          บ Data ณ  16/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula o Valor do desconto do item                         บฑฑ
ฑฑบ          ณ							                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                    บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method CalcValDes(nVlUnit, nPercent, nQtd ) Class Desconto  
Local nValDesc   	:= 0
Local nValitem   	:= 0  // Valor do item multiplicado pela quantidade 
Local nValUniD   	:= 0  // Valor do Item com o desconto aplicado  
Local cMvArreFat	:= SuperGetMV( "MV_ARREFAT",,"N" )	// Verifica parametro de arredondamento 
Local nDec       	:= 0 
Local nDecimal   	:= If(cPaisLoc=="BRA", 2, MsDecimais(nMoedaCor) ) //Para o Brasil usa 2 casas decimais devido a MatxFis (funcao MaItArred) trabalhar com 2 casas tambem
Local nVlrUnit		:= 0 

nDec :=  LjxDecimal( "SLR","LR_VRUNIT",".", 2)

If nDec <= 0
	nDec := TamSx3("LR_VRUNIT")[2] 
EndIf

If cMvArreFat == "S"
	nValUniD := Round( nVlUnit * ( 1 - ( nPercent /100 ) ) , nDec)
	nValitem := Round( nValUniD * nQtd  , nDec )
	nValDesc := Round ( (nVlUnit * nQtd)  - nValitem  , nDecimal )
	nVlrUnit := Round ( nVlUnit * ( 1 - ( nPercent /100 ) ) , nDec )

	If !(Isblind() .AND. nVlrUnit == 0)
		nVlUnit   := nVlrUnit
	EndIf	
Else
	nValUniD := NoRound( nVlUnit * ( 1 - ( nPercent /100 ) ) , nDec )
	nValitem := NoRound( nValUniD * nQtd  , nDec )
	nValDesc := NoRound ( (nVlUnit * nQtd)  - nValitem  , nDecimal )
	nVlrUnit := NoRound( nVlUnit * ( 1 - ( nPercent /100 ) ) , nDec )

	If !(Isblind() .AND. nVlrUnit == 0)
		nVlUnit   := nVlrUnit
	EndIf	
EndIf	
Return nValDesc     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณCalcPerDesบAutor  ณVendas CRM          บ Data ณ  16/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula o Percentual do desconto do item                    บฑฑ
ฑฑบ          ณ							                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                    บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method CalcPerDes(nVlUnit, nValDesc, nQtd ) Class Desconto
Local nPercent 		:= 0   
Local cMvArreFat 	:= SuperGetMV( "MV_ARREFAT",,"N" )	// Verifica parametro de arredondamento 
Local nDec       	:= TamSx3("LR_VRUNIT")[2]
Local nVlItem    	:= 0
Local nDecimal   	:= If(cPaisLoc=="BRA", 2, MsDecimais(nMoedaCor) ) //Para o Brasil usa 2 casas decimais devido a MatxFis (funcao MaItArred) trabalhar com 2 casas tambem
Local lMvAjstDes	:= SuperGetMV("MV_LJAJDES", Nil, .F.)	//Verifica se o parametro de ajuste de desconto esta ativo
Local nVlrUnit		:= 0

nDec := LjxDecimal( "SLR","LR_VRUNIT",".", 2)
If nDec <= 0
	nDec := TamSx3("LR_VRUNIT")[2] 
EndIf
If cMvArreFat == "S" 
	nVlrDes  := Round ( nValDesc / nQtd ,nDecimal )
	
	If	lMvAjstDes
		nVlrUnit := Round ( nVlUnit - (nValDesc / nQtd) ,nDec )
	Else
		nVlrUnit := Round ( nVlUnit - nVlrDes ,nDec )
	EndIf
	
	nVlItem  := Round ( nVlrUnit * nQtd ,nDecimal ) 
	nPercent := Round ( ( 1 - (nVlrUnit / nVlUnit ) ) * 100 ,nDecimal )
	If !(Isblind() .AND. nVlrUnit == 0)
		nVlUnit  := nVlrUnit
	EndIf
Else
	nVlrDes  := NoRound ( nValDesc / nQtd ,nDecimal )
	
	If	lMvAjstDes
		nVlrUnit := NoRound ( nVlUnit - (nValDesc / nQtd) ,nDec )
	Else
		nVlrUnit := NoRound ( nVlUnit - nVlrDes ,nDec )
	EndIf  
	
	nVlItem  := NoRound ( nVlrUnit * nQtd ,nDecimal ) 
	nPercent := NoRound ( ( 1 - (nVlrUnit / nVlUnit ) ) * 100 ,nDecimal )
	If !(Isblind() .AND. nVlrUnit == 0)
		nVlUnit  := nVlrUnit
	EndIf	
EndIf

Return nPercent

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLjxDecimal บAutor  ณ Vendas Clientes    บ Data ณ  20/08/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a quantidade de casas decimais da Picture  		   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณPARAM01 - Alias do campo 									   บฑฑ
ฑฑณ          ณPARAM02 - Campo para busca da Picure						   บฑฑ
ฑฑณ          ณPARAM03 - Caracter para Busca								   บฑฑ
ฑฑณ          ณPARAM04 - Indica se busca o primeiro ou o ultimo caracter	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja \ FrontLoja	                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function LjxDecimal( cAlias,cCampo,cDelimit,nTipo)
Local nRet     := 0
Local cString  := ""

Default cAlias   := ""
Default cCampo   := ""
Default cDelimit := ""   

If !Empty(cAlias) .AND.!Empty(cCampo) .AND. !Empty(cDelimit) 

	cString := PesqPict(cAlias,cCampo)
	If nTipo == 1
		nRet := Len(cString) -  At(cDelimit,cString ) // pega a primeira posicao do caracter 	
	Else
		nRet := Len(cString) -  Rat(cDelimit,cString ) // pega a ultima posicao do caracter 	
	EndIf	
EndIf
Return nRet       

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ AjtDsc	 บAutor  ณ Vendas e CRM		  บ Data ณ  10/03/2011 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o valor e o percentual do desconto.		 		   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณPARAM01 - Total da Venda.									   บฑฑ
ฑฑณ          ณPARAM02 - Valor do Desconto.								   บฑฑ
ฑฑณ          ณPARAM03 - Percentual do Desconto.							   บฑฑ
ฑฑณ          ณPARAM04 - 1 = Calculo do Valor do Desconto.				   บฑฑ
ฑฑณ          ณ			2 = Calculo do Percentual do Desconto.		 	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA				                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function AjtDsc( nTotal, nVlrDesc, nPercent, nOpc )
Local nRet			:= 0 
Local nPos 			:= 0
Local nSomItens 	:= 0 
Local nPercProduto  := 0
Local nVlUnit       := 0 
Local nAcumVlRat 	:= 0 
Local nDecsAux 		:= nDecimais
Local nPosVlrItem 	:= aPosCpo[Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_VLRITEM"})][2]	// Posicao do valor do item
Local nPosVrUnit 	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VRUNIT"})][2]	// Posicao do Valor unitario do item
Local nPosQuant		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_QUANT"})][2]	// Posicao da Quantidade 
Local cMvArreFat	:= SuperGetMV( "MV_ARREFAT",,"N" )	// verifica parametro de arredondamento
Local nDecVrUnit	:= TamSX3("LR_VRUNIT")[2]			// quantidade de casas decimais do campo LR_VRUNIT
Local nDecPerDes	:= TamSX3("LQ_DESCNF")[2]

//----------------------------------------
//| Calcula valor total das mercadorias. |
//----------------------------------------
For nPos := 1 to Len(aCols)  
	If !aCols[nPos,Len(aCols[nPos])] 
		nSomItens += aCols[nPos][nPosVlrItem]		 
	EndIf
Next nPos
 
For nPos := 1 to Len(aCols) 
	If !aCols[nPos,Len(aCols[nPos])] 
		//---------------------------------------------------
		//| Verifica a proporcao ref. a cada item da venda. |
		//---------------------------------------------------
		nPercProduto	:= (aCols[nPos][nPosVlrItem] / nSomItens) * 100

		//-------------------------------------------
		//| Calcula desconto proporcional por item. |
		//-------------------------------------------
		If nOpc == 2
	   		nDescPro	:= Round(((nVlrDesc * nPercProduto) / 100),nDecsAux)
		Else
			nDescPro	:= Round((((nTotal*nPercent/100) * nPercProduto) / 100),nDecsAux)	
		EndIf

		//------------------------------------
		//| Calcula valor unitario por item. |
		//------------------------------------
		nVlUnit := (aCols[nPos][nPosVrUnit] * aCols[nPos][nPosQuant] - nDescPro) / aCols[nPos][nPosQuant]

		If cMvArreFat == "S"
			nVlUnit := Round(nVlUnit, nDecVrUnit)
		Else
			nVlUnit := NoRound(nVlUnit, nDecVrUnit)
		EndIf

		//----------------------------
		//| Acumula total dos Itens. |
		//----------------------------
		nAcumVlRat	+= Round((nVlUnit * aCols[nPos][nPosQuant]),nDecsAux)
	EndIf
Next nPos 

//-------------------------------
//|Calcula o valor do desconto. |
//-------------------------------
nRet := nTotal - nAcumVlRat

If nOpc == 2 
	//-----------------------------------
	//| Calcula percentual de desconto. |
	//-----------------------------------
	nRet := Round((nRet/nTotal)*100,nDecPerDes)
EndIf

Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ AjtDscIt	 บAutor  ณ Vendas e CRM	  บ Data ณ  21/02/2013	บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o valor de desconto do item				 		บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณPARAM01 - Valor do Desconto (L2_VALDESC)					บฑฑ
ฑฑณ          ณPARAM02 - Quantidade										บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออ	นฑฑ
ฑฑบRetorno	 ณ Valor de desconto do item ajustado						บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA				                                    บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function AjtDscIt(nValDesc, nQuant)

Local nRet			:= 0								// valor do desconto(VALDESC) a ser retornado
Local nValDescUn	:= 0								// valor do desconto aplicado sobre uma unidade
Local nVDescCalc	:= 0								// valor do desconto calculado manualmente
Local nDecVrUnit	:= TamSX3("LR_VRUNIT")[2]			// quantidade de casas decimais do campo LR_VRUNIT
Local nTamValDec	:= TamSX3("LR_VALDESC")[2]			// quantidade de casas decimais do campo LR_VALDESC
Local cMvArreFat	:= SuperGetMV( "MV_ARREFAT",,"N" )	// verifica parametro de arredondamento

Default nValDesc	:= 0
Default nQuant		:= 1

// Obtemos o valor do desconto unitario
nValDescUn := nValDesc / nQuant

// Verificamos se truncamos ou arredondamos o valor
If cMvArreFat == "S"
	nValDescUn := Round(nValDescUn, nDecVrUnit)
Else
	nValDescUn := NoRound(nValDescUn, nDecVrUnit)
EndIf

// Obtemos o valor do desconto calculado
nVDescCalc := Round( nValDescUn * nQuant, nTamValDec )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณComparamos se o valor do desconto calculado com o valor do desconto digitado, ณ
//ณpois podem haver diferencas, nesse caso ajustamos o valor do desconto         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nValDesc <> nVDescCalc
	nRet := nVDescCalc
Else
	nRet := nValDesc
EndIf

Return nRet

/*/{Protheus.doc} LjVlDsFull
Valida se o orcamento possui itens com 100% de desconto
Caso possua, Valida se pelo menos um item de cada tipo de entrega 
	  		possui percenual menor que 100% de desconto, pois a venda nใo pode ter total zerado.
@type  Function
@author joao.marcos
@since 19/08/2022
@version V12.1.2210
@param aItAuto, array, itens do orcamento
@param nPosPDesc, numerico, posicao do Percentual de desconto
@param nPosEntr, numerico, posicao do tipo de entrega
@return lRet, logico, retorna .F. caso o orcamento possua item com 100% de desconto 
					  mas nao esteja de acordo com as validacoes
/*/
Function LjVlDsFull(aCols, nPosPDesc, nPosEntr) 
Local lRet			:= .T.
Local nPerDesc		:= 0			// Percentual do desconto
Local nQtdItens 	:= Len(aCols)	// Quantidade de Itens
Local cTpEntrega	:= "2"			// Tipo da Entrega
Local aItDscFull	:= {}			// Itens com desconto de 100%
Local aTpEntrCVl	:= {.F.,.F.,.F.,.F.,.F.}	// Tipos de entrega com valor
Local aTpEntrVda	:= {}			// Tipos de entrega da venda
Local lTpEntrVZr	:= .F.			// Indica se existe algum tipo de entrega da venda com valor zerado
Local nX			:= 0

LjGrvLog( NIL, "Valida desconto 100% no item - Inicio.",)

For nX := 1 To nQtdItens

	cTpEntrega := aCols[nX][nPosEntr]

	If Empty(cTpEntrega)
		cTpEntrega := "2"
	EndIf

	AADD(aTpEntrVda,{cTpEntrega})

		nPerDesc := aCols[nX][nPosPDesc]

		If nPerDesc == 100
			AADD(aItDscFull,{nX,cTpEntrega})
		EndIf

	If nPerDesc < 100
		// Indica que possui algum item de valor para o determinado tipo de entrega
		LjStTpDscV(cTpEntrega, @aTpEntrCVl)		
	EndIf
Next

If Len(aItDscFull) > 0

	For nX := 1 To Len(aTpEntrVda)
		// Verifica se cada tipo de entrega da venda possui algum item com valor
		If !aTpEntrCVl[ Val(aTpEntrVda[nX][01]) ]
			lTpEntrVZr := .T.
		EndIf
	Next

	If lTpEntrVZr 
		Help( " ", 1, STR0001,, STR0002, 1, 0 ) // "Desconto total no item" ## "Para or็amento contendo item com 100% de desconto ้ necessแrio ter pelo menos um outro item com o mesmo tipo de entrega com valor maior que zero."
		LjGrvLog( NIL, "Valida desconto 100% no item - " + STR0002 ,) // Para or็amento contendo item com 100% de desconto ้ necessแrio ter pelo menos um outro item com o mesmo tipo de entrega com valor maior que zero."
		lRet := .F.
	EndIf
	
EndIf

LjGrvLog( NIL, "Valida desconto 100% no item - Fim.", lRet)

Return lRet

/*/{Protheus.doc} LjStTpDscV
Seta no array aTpEntrCVl se o tipo de Entrega possui item com valor
@type  Static Function
@author joao.marcos
@since 22/08/2022
@version V12.1.2210
@param cTpEntrega, caracter, tipo de entrega
@param aTpEntrCVl, array, tipo de entrega com valor
/*/
Static Function LjStTpDscV(cTpEntrega, aTpEntrCVl)

DEFAULT cTpEntrega := "2"

Do Case
	Case cTpEntrega == "1"
		aTpEntrCVl[01] := .T.
	Case cTpEntrega == "2"
		aTpEntrCVl[02] := .T.
	Case cTpEntrega == "3"
		aTpEntrCVl[03] := .T.
	Case cTpEntrega == "4"
		aTpEntrCVl[04] := .T.
	Case cTpEntrega == "5"
		aTpEntrCVl[05] := .T.
EndCase

Return
