#INCLUDE "PROTHEUS.CH" 

/*/
|| IMPORTANTE: Toda alteração efetuada neste fonte DEVE OBRIGATORIAMENTE ser feita também no fonte SCRCGift.PRW
/*/

/*/{Protheus.doc} LJSCRGIF
Verifica a existencia do RDMake padrão SCRCGift compilado no RPO, caso não exista envia para a LJRUNSCRPS para realizar a impressão
@type  Function
@author JMM
@since1 23/12/2020
@version 12.1.27
@return 
/*/
Function LJSCRGIF()
Local cRet := ""

If ExistBlock("SCRCGift")
	cRet := ExecBlock("SCRCGift" ,.F.,.F., )
Else
    cRet := LJRUNSCRGIF()
EndIf

return cRet

/*/{Protheus.doc} LJRUNSCRGIF
Monta o texto a ser impresso no comprovante (nao fiscal) da venda de Recarga de Cartao Presente (Gift Card).
@type   Function
@author Vendas Clientes
@since  17/03/2014
@return sTexto, String, Texto a ser impresso
/*/
Static Function LJRUNSCRGIF()
Local nOrcam
Local sTexto                      
Local nCheques
Local nCartao
Local nConveni
Local nVales
Local nFinanc
Local nCredito		:= 0
Local nOutros
Local cQuant 		:= ""
Local cVrUnit		:= ""
Local cDesconto		:= ""
Local cVlrItem		:= ""

sTexto:= 'Codigo         Descricao'+Chr(13)+Chr(10)
sTexto:= sTexto+ 'Qtd             VlrUnit                 VlrTot'+Chr(13)+Chr(10)
sTexto:= sTexto+'-----------------------------------------------'+Chr(13)+Chr(10)
dbSelectArea("SL1")                                                                  
dbSetOrder(1)  
nOrcam		:= SL1->L1_NUM
nDinheir	:= SL1->L1_DINHEIR
nCheques	:= SL1->L1_CHEQUES
nCartao 	:= SL1->L1_CARTAO
nConveni	:= SL1->L1_CONVENI
nVales  	:= SL1->L1_VALES  	
nFinanc		:= SL1->L1_FINANC
nCredito	:= SL1->L1_CREDITO
nOutros		:= SL1->L1_OUTROS
           
dbSelectArea("SL2")
dbSetOrder(1)  
dbSeek(xFilial("SL2") + nOrcam)
	
While !SL2->(Eof()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == cFilAnt + nOrcam
	cQuant 		:= StrZero(SL2->L2_QUANT, 8, 3)
	cVrUnit		:= Str(( (SL2->L2_QUANT * SL2->L2_PRCTAB) ) / SL2->L2_QUANT, 15, 2)
	cDesconto	:= Str(SL2->L2_VALDESC, TamSx3("L2_VALDESC")[1], TamSx3("L2_VALDESC")[2])
	cVlrItem	:= Str(Val(cVrUnit) * SL2->L2_QUANT, 15, 2)

	sTexto		:= sTexto + SL2->L2_PRODUTO + SL2->L2_DESCRI + Chr(13) + Chr(10)
	sTexto		:= sTexto + cQuant + '  ' + cVrUnit + '      ' + cVlrItem + Chr(13) + Chr(10)
	If SL2->L2_VALDESC > 0 
		sTexto	:= sTexto + 'Desconto no Item:              ' + Str(SL2->L2_VALDESC, 15, 2) + Chr(13) + Chr(10)
	EndIf
	SL2->(DbSkip())
Enddo                      

If SL1->L1_DESCONTO > 0
	sTexto	:= sTexto + 'Desconto no Total:             ' + Str(SL1->L1_DESCONTO, 15, 2) + Chr(13) + Chr(10)
EndIf                                                                              
If SL1->L1_JUROS > 0
	sTexto	:= sTexto + 'Acrescimo no Total:            ' + Transform(SL1->L1_JUROS, "@R 99.99%") + Chr(13) + Chr(10)
EndIf

sTexto	:= sTexto + '-----------------------------------------------' + Chr(13) + Chr(10)
sTexto	:= sTexto + 'TOTAL                         ' + Str(SL1->L1_VLRLIQ, 15, 2) + Chr(13) + Chr(10)

If nDinheir > 0 
	sTexto := sTexto + 'DINHEIRO' + '                       ' + Str(nDinheir, 15, 2) + Chr(13) + Chr(10)
EndIf
If nCheques > 0 
	sTexto := sTexto + 'CHEQUE' + '                         ' + Str(nCheques, 15, 2) + Chr(13) + Chr(10)
EndIf
If nCartao > 0 
	sTexto := sTexto + 'CARTAO' + '                          ' + Str(nCartao, 15, 2) + Chr(13) + Chr(10)
EndIf
If nConveni > 0 
	sTexto := sTexto + 'CONVENIO' + '                        ' + Str(nConveni, 15, 2) + Chr(13) + Chr(10)
EndIf
If nVales > 0 
	sTexto := sTexto + 'VALES' + '                           ' + Str(nVales, 15, 2) + Chr(13) + Chr(10)
EndIf
If nFinanc > 0 
	sTexto := sTexto + 'FINANCIADO' + '                      ' + Str(nFinanc, 15, 2) + Chr(13) + Chr(10)
EndIf  
If nCredito > 0
	sTexto := sTexto + 'CREDITO ' + '                       ' + Str(nCredito, 15, 2) + Chr(13) + Chr(10)
EndIf			
			
sTexto := sTexto + '-----------------------------------------------' + Chr(13) + Chr(10)

Return sTexto