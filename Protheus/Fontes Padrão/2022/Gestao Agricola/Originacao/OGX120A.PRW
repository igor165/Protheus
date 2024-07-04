#INCLUDE "OGX120.ch"
#Include 'Protheus.ch'

/**{Protheus.doc} OGX120
Validação na Baixa de Títulos a pagar
Gerar titulos de comissao para a corretora
@param: 	Nil
@author: 	José Leite de Barros Neto
@since: 	15/07/2013
@Uso: 		SIGAFIN - Financeiro
**/
//Programa Original: ARMXPE16.PRW
Function OGX120A()
/*
Local aArea			:= GetArea()
Local cPrefixo		:= AllTrim(SE5->( E5_PREFIXO ))
Local cNumero		:= SE5->( E5_NUMERO )
Local cFornece		:= SE5->( E5_CLIFOR )
Local cLjForn		:= SE5->( E5_LOJA )
Local cCodCtr		:= ""
Local cNaturez		:= SE5->( E5_NATUREZ )
Local cParcela		:= ""
Local cHist			:= ""
Local nPerComis		:= 0
Local nTotal		:= SE5->( E5_VALOR ) 
Local nTotalBx		:= 0
Local nQtdSacas		:= 0
Local nVlrComis		:= 0
Local aFina050		:= {}

Private lMsErroAuto	:= .F.

If cPrefixo == "OP"
	
	BeginSql Alias "QryT1"
		
		Select *
		From %Table:SE2% SE2 
		Where
			SE2.E2_FILIAL  = %xFilial:SE2%  And
			SE2.E2_FATPREF = %Exp:cPrefixo%  And
			SE2.E2_FATURA  = %Exp:cNumero% And
			SE2.%notDel%
	EndSql
	
	cCodCtr	:= QryT1->( E2_CTROG )
	
	QryT1->( dbCloseArea() )
	
	BeginSql Alias "NNF"
		
		Select *
		From %Table:NNF% NNF 
		Where
			NNF.NNF_FILIAL  = %xFilial:NNF%  And
			NNF.NNF_CODCTR  = %Exp:cCodCtr%  And
			NNF.%notDel%
	EndSql
	
	While .Not. NNF->( Eof() )

		If NNF->( NNF_PCBCOM ) > 0 //Valor em % 
		
			nPerComis 	:= NNF->( NNF_PCBCOM ) / 100
			nTotalBx	:= (nTotal * nPerComis)
		
		ElseIf NNF->( NNF_VLBCOM ) > 0  // Valor em R$ por SC.
			
			BeginSql Alias "QryTE3"
				SELECT * 
					FROM %Table:SD1% SD1 
					WHERE SD1.D1_CTROG = %Exp:cCodCtr% And
						SD1.%notDel%	
			EndSql		
			
			While .Not. QryTE3->( Eof() )
				
				nVlrPerTit := (nTotal / SE2->E2_VALOR) * 100
				nQtdSacas  := AGRX001(QryTE3->(D1_UM), "SC", QryTE3->( D1_QUANT )) 
				nVlrComis  := ( NNF->( NNF_VLBCOM)  * nQtdSacas ) / 100
				
				nTotalBx += Round(nVlrComis * (nVlrPerTit/100),2)
				
				QryTE3->( DbSkip() )	
			EndDo
			
			QryTE3->( dbCloseArea() )
			
		Else
			nTotalBx := 0	
		EndIf
		
		If nTotalBx > 0
		
			BeginSql Alias "QryTE2"
				Select
					Max( E2_PARCELA ) As UltPar
					From
						%Table:SE2% SE2 
					Where
						SE2.E2_FILIAL 	= %xFilial:SE2% And
						SE2.E2_PREFIXO 	= 'CM' And
						SE2.E2_NUM		= %Exp:cCodCtr% And
						SE2.%notDel%
			EndSql
		
			cParcela := Soma1( QryTE2->( UltPar ) )
			
			QryTE2->( dbCloseArea() )
				
			cHist	 := STR0001+AllTrim( NNF->( NNF_NMCORA ) ) //"Comissao para Corretora "
			
			aFina050 := {}
			aAdd( aFina050, { "E2_PREFIXO" , "CM"					, Nil } )
			aAdd( aFina050, { "E2_NUM"     , cCodCtr				, Nil } )
			aAdd( aFina050, { "E2_PARCELA" , cParcela				, Nil } )
			aAdd( aFina050, { "E2_TIPO"    , "DP"					, Nil } )
			aAdd( aFina050, { "E2_NATUREZ" , cNaturez				, Nil } )
			aAdd( aFina050, { "E2_FORNECE" , cFornece				, Nil } )
			aAdd( aFina050, { "E2_LOJA"    , cLjForn				, Nil } )
			aAdd( aFina050, { "E2_EMISSAO" , dDataBase				, Nil } )
			aAdd( aFina050, { "E2_VENCTO"  , dDatabase				, Nil } )
			aAdd( aFina050, { "E2_VALOR"   , nTotalBx				, Nil } )
			aAdd( aFina050, { "E2_MOEDA"   , 1						, Nil } )
			aAdd( aFina050, { "E2_VLCRUZ"  , nTotalBx				, Nil } )
			aAdd( aFina050, { "E2_HIST"    , cHist					, Nil } )
			
			MsExecAuto( { |x,y| Fina050( x, y ) }, aFina050, 3 ) 
			
			If lMsErroAuto
				MostraErro()
				Exit
			EndIf
		
		EndIf
		
		NNF->( DbSkip() )	
	EndDo
	NNF->( dbCloseArea() )
EndIf

RestArea(aArea)*/
Return ( Nil )