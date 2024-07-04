#INCLUDE "Average.CH"

Function EasyRateio()
Return Nil

/*
Programa   : EasyRateio.PRW
Objetivo   : Facilitar rateio de valores com ajuste de arredondamento
Retorno    : Nil
Autor      : Alessandro Alves Ferreira - AAF
Data/Hora  : 05/04/2013
Revisao    : 
*/
Class EasyRateio
   
   Data nValorARatear
   Data nValorTotal
   Data nQtdItens
   Data nDecimais
   
   Data nContador
   Data nVlAcum
   Data nVlRAcum
   
   Method New()
   Method GetItemRateio(nValorItem)

End Class

/*
Funcao      : EasyRateio():New().
Objetivos   : Instanciar objeto da classe EasyRateio
Sintaxe     : 
Parametros  : nValorARatear - Valor total a ser rateado (Ex.: Valor total do Frete)
              nValorTotal   - Valor total do critério utilizado para rateio (Ex.: Peso total do processo)
              nQtdItens     - Quantidade de itens no processo.
              nDecimais     - Quantidade de casas decimais para arredondamento.
Retorno     : Objeto instanciado
Autor       : Alessandro Alves Ferreira
Data/Hora   : 05/04/2013
*/
Method New(nValorARatear,nValorTotal,nQtdItens,nDecimais) Class EasyRateio
   Self:nValorARatear := nValorARatear
   Self:nValorTotal   := nValorTotal
   Self:nQtdItens     := nQtdItens
   Self:nDecimais     := nDecimais

   Self:nContador := 0
   Self:nVlAcum   := 0
   Self:nVlRAcum   := 0
Return Self

/*
Funcao      : EasyRateio():GetItemRateio().
Objetivos   : Retornar valor rateado e ajustado de rateio para o item.
Sintaxe     : 
Parametros  : nValorItem - Valor do criterio de rateio no item (Ex.: Peso do item)
Retorno     : 
Autor       : Alessandro Alves Ferreira
Data/Hora   : 05/04/2013
*/
Method GetItemRateio(nValorItem) Class EasyRateio
Local nVlRateio
Local nDiff

If nValorItem <> 0
   nVlRateio := Self:nValorARatear*nValorItem/Self:nValorTotal
   Self:nContador++

   If Self:nContador == Self:nQtdItens
      Self:nVlAcum := Self:nValorARatear
   Else
      Self:nVlAcum += nVlRateio
   EndIf

   Self:nVlRAcum += Round(nVlRateio,Self:nDecimais)

   If NoRound(Abs(Self:nVlAcum - Self:nVlRAcum),Self:nDecimais) > 0
      nDiff := NoRound(Self:nVlAcum - Self:nVlRAcum,Self:nDecimais)
         
      nVlRateio     += nDiff
      //Self:nVlAcum  += nDiff
      Self:nVlRAcum += nDiff
   EndIf
Else
   nVlRateio := nValorItem
EndIf 

Return Round(nVlRateio,Self:nDecimais)