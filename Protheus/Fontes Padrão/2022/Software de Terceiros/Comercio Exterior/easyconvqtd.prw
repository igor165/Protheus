#INCLUDE "AVGERAL.CH"
#INCLUDE "MSOBJECT.CH"
#DEFINE ENTER CHR(13) + CHR(10)


/*
Funcao      : EasyConvQt(cProd,aQtdDe,cUnidPara,lShowMsg,oRefObj)
Parametros  : cProd    - Código do Produto.
              aQtdDe   - {{unidade_DE 1, quantidade_DE 1}...}
              cUniPara - Unidade que se deseja achar a conversão.
              lShowMsg - Exibe as mensagens de Erro.
              oRefObj  - Objeto de Referencia
Retorno     : nQtdPara
Objetivos   : Verificar se existe conversão de unidades, priorizando o campo EE8...
Autor       : Olliver A. Pedroso
Data/Hora   : 07/01/2011
*/
                                         
/*aUniMedida  = {{unidade_DE 1, quantidade_DE 1},;
                 {unidade_DE 2, quantidade_DE 2},;
                 .
                 .
                 {unidade_n   , quantidade_n}}
                                                          
                 cUnidPara = Unidade que se deseja chegar    */
Function EasyConvQt(cProd,aQtdDe,cUnidPara,lShowMsg,oRefObj)
oRefObj := EasyConvQt():New(cProd,aQtdDe,cUnidPara,lShowMsg,@oRefObj)
Return oRefObj:nQtdPara

Class EasyConvQt From AvObject
    
   Data cProd
   Data aQtdDe 
   Data cUnidPara
   Data lShowMsg
   Data nQtdPara    //Quantidade Final convertida
                         
   Method New(cProd,aQtdDe,cUnidPara,lShowMsg,oRefObj) Constructor
   Method Converte()
   
EndClass


Method New(cProd,aQtdDe,cUnidPara,lShowMsg,oRefObj) Class EasyConvQt
    
   If ValType(oRefObj) == "O" .AND. oRefObj:ClassName() = "EasyConvQt"
      //Self := oRefObj
      AvOClone(oRefObj,,Self)
   Else
      _Super:New()
      Self:SetClassName("EasyConvQt")
   EndIf
   
   Self:cProd      := cProd
   Self:aQtdDe     := aQtdDe
   Self:cUnidPara  := cUnidPara 
   Self:lShowMsg   := lShowMsg
   Self:nQtdPara   := -1
   
   Self:Converte()
   
   If Self:lShowMsg
      Self:ShowErrors(.T.)
   EndIf
   
Return Self                     

Method Converte() Class EasyConvQt
Local nQtParaAux := 0 
Local x        := 0
Local aSimilar := {{"G" ,"KG",0.001   },;
                   {"G" ,"TL",0.000001},;
                   {"KG","TL",0.001   },;
                   {"TL","KG",1000    },;
                   {"TL","G" ,1000000 },;
                   {"KG","G" ,1000    }}
Local nPos
Begin Sequence

   For x:=1 To Len(Self:aQtdDe)
      If AllTrim(Self:aQtdDe[x,1]) == AllTrim(Self:cUnidPara)
         Self:nQtdPara := Self:aQtdDe[x,2]
         Break
      EndIf
   Next x

   For x := 1 To Len(Self:aQtdDe)
      If (nPos := aScan(aSimilar,{|z| z[1] == Alltrim(Self:aQtdDe[x,1]) .And. z[2] == Alltrim(Self:cUnidPara)})) > 0                  
         Self:nQtdPara := Self:aQtdDe[x,2] * aSimilar[nPos][3]        
         Break
      EndIf
   Next x

   For x:=1 To Len(Self:aQtdDe)

      //nQtParaAux := AVTransUnid(Self:aQtdDe[x,1],Self:cUnidPara,Self:cProd,Self:aQtdDe[x,2],.F.) //.T.)  // GFP - 23/05/2013 - Alterado flag para .F. para conversão correta.
      //RMD - 13/06/18 - Não pode enviar falso no quinto parâmetro, pois senão a função AvTransUnid retorna o mesmo valor enviado caso não encontre a conversão, fazendo com que o tratamento de erro abaixo não funcione.
      nQtParaAux := AVTransUnid(Self:aQtdDe[x,1],Self:cUnidPara,Self:cProd,Self:aQtdDe[x,2],.T.)
      If ValType(nQtParaAux) != "U"
         Self:nQtdPara :=  nQtParaAux
         EXIT
      Else
         Self:Warning("Não existe conversão de " + AllTrim(Self:aQtdDe[x,1]) + " para " + Alltrim(Self:cUnidPara) + "." )
      EndIF
   Next x
   
End Sequence

Return nil