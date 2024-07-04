#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"

Function LOJA2505 ; Return  // "dummy" function - Internal Use

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    |LjClXMLTag       บAutor  ณVendas Clientes     บ Data ณ  29/02/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse de Listas de Tags          								 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LjClXMLTag  
   	
	Data cNomeTag                                                           //Codigo da Tag
    Data cNomePai                                                          //Numero do Indice no SX3    
  	Data nSequencia                                                        //Bloco de posicionamento da tabela  
    Data cTabela                                                              //Tabela resultado de uma Query SQL?
    Data bCondicao                                                              //Tabela resultado de uma Query SQL?
    Data nMinimo                                                              //Tabela resultado de uma Query SQL?
    Data cMaximo                                                              //Tabela resultado de uma Query SQL?
    Data bConteudo                                                              //Tabela resultado de uma Query SQL?
    Data cTipo																	//Tipo de Dados
    Data nTamanho																//Tamanho do tipo
    Data cMascara																//Mascara do tipo
    

	Method New()  
	Method Destruct() 
	Method Formatar() 
EndClass  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |New              บAutor  ณVendas Clientes      บ Data ณ  29/02/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que Instancia a tag                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ  
ฑฑบParametrosณ ExpC1 = Nome da tag                                      	      บฑฑ
ฑฑบ          ณ ExpN2 = Sequencia da tag                                        	  บฑฑ 
ฑฑบ          ณ ExpC3 = Sequencia da tag                                        	  บฑฑ 
ฑฑบ          ณ ExpC4 = Alias da Tabela                                       	  บฑฑ 
ฑฑบ          ณ ExpB5 = Condicao para geracao da tag                            	  บฑฑ 
ฑฑบ          ณ ExpN6 = Minimo de repeticoes                                 	  บฑฑ 
ฑฑบ          ณ ExpC7 = Maxino de repeticoes  (Exemplo "1", "2", "N"            	  บฑฑ 
ฑฑบ          ณ ExpB8 = Bloco de execu็ใo do conteudo                         	  บฑฑ 
ฑฑบ          ณ ExpC9 = Tipo de retorno do conteudo                           	  บฑฑ
ฑฑบ          ณ ExpN10 = Tamanho do conteudo                                 	  บฑฑ
ฑฑบ          ณ ExpC11 = Mascara do conteudo                                 	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja/SigaFRT                                             		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method New(cNome, 		cNomePai, 	nSequencia,	cTabela,;
           bCondicao, 	nMinimo,	cMaximo, 	bConteudo,;
           cTipo,		nTamanho,	cMascara)  Class LjClXMLTag       
 	
 	
 	Default cNomePai := ""
    Default nSequencia := 0
    Default cTabela := ""
    Default bCondicao := { || .T. }
    Default nMinimo := 0
    Default cMaximo  := "0"
    Default bConteudo := nil   
    Default nTamanho := 0  
    Default cTipo := ""


	Self:cNomeTag  	:=  cNome                                                        //Codigo da Tag
    Self:cNomePai 	:=  cNomePai                                                        //Numero do Indice no SX3    
  	Self:nSequencia :=  nSequencia                                                     //Bloco de posicionamento da tabela  
    Self:cTabela    :=  cTabela                                                        //Tabela resultado de uma Query SQL?
    Self:bCondicao  :=  bCondicao                                                          //Tabela resultado de uma Query SQL?
    Self:nMinimo    :=  nMinimo                                                        //Tabela resultado de uma Query SQL?
    Self:cMaximo    :=  cMaximo                                                        //Tabela resultado de uma Query SQL?
    Self:bConteudo  :=  bConteudo                                                          //Tabela resultado de uma Query SQL?
    Self:cTipo		:= 	cTipo															//Tipo de Dados
    Self:nTamanho	:=  nTamanho															//Tamanho do tipo
    Self:cMascara	:=  cMascara															//Mascara do tipo

Return Self


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |Destruct         บAutor  ณVendas Clientes     บ Data ณ  29/02/12    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que apaga o objeto                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ  
ฑฑบUso       ณSigaLoja/SigaFRT                                             		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method Destruct()  Class LjClXMLTag

Return Nil 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |Formatar         บAutor  ณVendas Clientes      บ Data ณ  29/02/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo que retira os caracteres especiais     	       		      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ  
ฑฑบParametrosณ ExpU1 = Conteudo do Campo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ  
ฑฑบUso       ณSigaLoja/SigaFRT                                             		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Formatar(xConteudo) Class LjClXMLTag

	Local cCaracs := "<>"   //Caracteres que devem ser retirados
	Local nC := 0           //Variavel contadora
	Local cString           //Conteudo de retorno da fun็ใo
	Local cTipo := Self:cTipo //tipo do conteudo
	
	Default cString := ""
	
	If Empty(cTipo)
		cTipo := ValType(xConteudo)
	EndIf
	
	Do Case
	Case cTipo == "N" .AND. xConteudo <> nil
		If !Empty(Self:cMascara)
			cString := Ltrim(Transform(xConteudo, Self:cMascara))
		Else
			cString := LTrim(Str(xConteudo, IIF(Self:nTamanho > 0, Self:nTamanho, nil)))
		EndIf
	Case  cTipo == "D" .AND. !Empty(xConteudo)
		If !Empty(Self:cMascara)  //dd/mm/aa, dd/mm/aaaa, aa/mm/dd, dd-mm-aaaa - "DD/MM/AAAA"    
	       cString := StrTran(Self:cMascara, "DD", StrZero(Day(xConteudo), 2)) 
	       cString := StrTran(cString, "MM", StrZero(Month(xConteudo),2))
	       cString := StrTran(cString, "AAAA", StrZero(Year(xConteudo), 4))
	       cString := StrTran(cString, "AA", Right(StrZero(Year(xConteudo),4 ),2))
		Else 
			cString := FWTimeStamp( 3, xConteudo, "00:00:00"  )
		EndIf
	Case  cTipo == "L"
		cString := IIF(xConteudo, "TRUE", "FALSE")
	Otherwise
		cString := xConteudo  
		
		If !Empty(cString)
			For nC := 1 to Len(cCaracs)
				cString := StrTran(cString, SubStr(cCaracs, nC, 1))
			Next nC
			If Self:nTamanho > 0
				cString := Left(cString,Self:nTamanho) 
			EndIf         
			
			cString := RTrim(cString)
		Else
			cString := ""
		EndIf	
	EndCase  
	
Return cString 