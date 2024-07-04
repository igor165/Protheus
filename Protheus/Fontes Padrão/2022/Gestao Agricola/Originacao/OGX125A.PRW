#Include 'OGX125.ch'
#Include 'Protheus.ch'

/**{Protheus.doc} OGX125
Validação no Cancelamento da Baixa de Títulos a receber
Gerar titulos do tipo NDC de comissao para a corretora
@param: 	Nil
@author: 	José Leite de Barros Neto
@since: 	16/07/2013
@Uso: 		SIGAFIN - Financeiro
@Alterado Por: Marcelo R. Ferrari
Alterado em: 19/08/2014
@Uso: 		SIGAFIN - Financeiro - desabilitado para revisar todo processo
@Alterado Por: Vanilda Moggio
Alterado em: 13/04/2014
**/
//Programa Original:  ARMXPE19.PRW
Function OGX125A()
/*Local aArea			:= GetArea()
Local aFina040		:= {}
Local cPrefixo		:= AllTrim(SE5->( E5_PREFIXO ))
Local cNumero		:= SE5->( E5_NUMERO )
Local cCliente		:= SE5->( E5_CLIFOR )
Local cLjCli		:= SE5->( E5_LOJA )
Local cCodCtr		:= ""
Local cNaturez		:= SE5->( E5_NATUREZ )
Local cParcela		:= ""
Local cHist			:= ""
Local nPerComis		:= 0
Local nTotal		:= SE5->( E5_VALOR ) 
Local nTotalBx		:= 0
Local nQtdSacas		:= 0
Local nVlrComis		:= 0

Private lMsErroAuto	:= .F.

If cPrefixo == "OR"
	BeginSql Alias "QryT1"		
		Select *
		From %Table:SE1% SE1 
		Where
			SE1.E1_FILIAL  = %xFilial:SE1%  And
			SE1.E1_FATPREF = %Exp:cPrefixo%  And
			SE1.E1_FATURA  = %Exp:cNumero% And
			SE1.%notDel%
	EndSql
	
	cCodCtr	:= QryT1->( E1_CTROG )
	
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
			nTotal		:= (nTotal * nPerComis)
		
		ElseIf NNF->( NNF_VLBCOM ) > 0  // Valor em R$ por SC.
			
			BeginSql Alias "QryTE3"
				SELECT * 
					FROM %Table:SD2% SD2 
					WHERE SD2.D2_CTROG = %Exp:cCodCtr% And
						SD2.%notDel%	
			EndSql		
			
			While .Not. QryTE3->( Eof() )
				
				nVlrPerTit := (nTotal / SE2->E2_VALOR) * 100
				nQtdSacas  := AGRX001(QryTE3->(D2_UM), "SC", QryTE3->( D2_QUANT )) 
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
					Max( E1_PARCELA ) As UltPar
					From
						%Table:SE1% SE1 
					Where
						SE1.E1_FILIAL 	= %xFilial:SE1% And
						SE1.E1_PREFIXO 	= 'CM' And
						SE1.E1_NUM		= %Exp:cCodCtr% And
						SE1.%notDel%
			EndSql
		
			cParcela := Soma1( QryTE2->( UltPar ) )
			
			QryTE2->( dbCloseArea() )
				
			cHist	 := STR0001 + NNF->( NNF_NMCORA )  //"Comissao para Corretora "				
			
			aFina040 := {}
			aAdd( aFina040, { "E1_PREFIXO" , "CM"					, Nil } )
			aAdd( aFina040, { "E1_NUM"     , cCodCtr				, Nil } )
			aAdd( aFina040, { "E1_PARCELA" , cParcela				, Nil } )
			aAdd( aFina040, { "E1_TIPO"    , "NDC"					, Nil } )
			aAdd( aFina040, { "E1_NATUREZ" , cNaturez				, Nil } )
			aAdd( aFina040, { "E1_CLIENTE" , cCliente				, Nil } )
			aAdd( aFina040, { "E1_LOJA"    , cLjCli					, Nil } )
			aAdd( aFina040, { "E1_EMISSAO" , dDataBase				, Nil } )
			aAdd( aFina040, { "E1_VENCTO"  , dDatabase				, Nil } )
			aAdd( aFina040, { "E1_VALOR"   , nTotalBx				, Nil } )
			aAdd( aFina040, { "E1_MOEDA"   , 1						, Nil } )
			aAdd( aFina040, { "E1_VLCRUZ"  , nTotalBx				, Nil } )
			aAdd( aFina040, { "E1_HIST"    , cHist					, Nil } )
			
			MsExecAuto( { |x,y| Fina040( x, y ) }, aFina040, 3 )
			
			If lMsErroAuto
				MostraErro()
				Exit
			EndIf
		
		Endif
		
		NNF->( DbSkip() )	
	EndDo
	NNF->( dbCloseArea() )
EndIf
RestArea(aArea)*/

Return ( Nil )