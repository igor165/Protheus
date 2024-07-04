#INCLUDE "PROTHEUS.CH"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ LJSwedaTER บAutor  ณ Vendas Clientes    บ Data ณ  MAR/09     บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   

CLASS  LJSwedaTER  FROM LJSweda9000 
	//ฺฤฤฤฤฤฤฤฤฤฟ
	//ณAtributosณ
	//ภฤฤฤฤฤฤฤฤฤู

	//ฺฤฤฤฤฤฤฤฤฤฟ
	//ณMetodos  ณ
	//ภฤฤฤฤฤฤฤฤฤู 
	METHOD New()
	METHOD IFAbrCNFis( cCondicao, cValor, cTotalizador, cTexto, nParcelas )//retorna caracter	   
	METHOD IFSupr(nTipo,cValor,cForma,cTotal,nModo)//reorna caracter
	METHOD IFRecbNFis(cTotalizador, cValor, cForma)	
	METHOD IFPegCupom(cCancelamento)	
ENDCLASS
//-------------------------------------------------------------
METHOD New() CLASS LJSwedaTER    
Return

//----------------------------------------------------------------------------    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณIFAbrCNFisบAutor  ณVendas Clientes     บData  ณ  MAR/09 	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAbre um comprovante Vinculado ou nao fiscal Vinculado       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA / FRONTLOJA, interfaces de venda  - Autocom.dll    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

METHOD IFAbrCNFis( cCondicao,cValor,cTotalizador,cTexto,nParcelas) CLASS LJSwedaTER
Local cRet := ""
Local cNumAnt := ""
Local nI := 0
Local aFormas := {}
Local cFormas := ""
Local cPos := ""
Local cPosTot := ""
Local nPos := 0
Local nTamanho := 0
Local cRetorno := ""
Local nVz := 0
Local lContinua := .T.
Local cTotFormaPagto := ""
Local cTotRecIni := ""
Local cDescTot   := ""     
Local cRecebTot   := ""
  

Conout("SWEDA Termica ST120 NIX  - METHOD IFAbrCNFis - Inicio - "+ Time() )

If AllTrim(cTotalizador)= "" 
    cTotalizador := "SIGALOJA"
Endif

If Val(cCondicao) <= 0   


Endif
cTotRecIni := GetPvProfString("Recarga Celular", "Totalizador", "", GetClientDir()+"SIGALOJA.INI")  
cRecebTot  := GetPvProfString("Receb. Contas", "Totalizador", "", GetClientDir()+"SIGALOJA.INI")  
nVz := 1
While nVz <= 5 .AND. lContinua
    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
    //ณPegando o numero do ultimo cupom ณ
    //ณimpresso							ณ
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู           
	cNumAnt := ::EnviaComando( Chr(27)+".271}")// Metodo da classe SWEDA 	
	If SubStr( ::TrataRetorno(1,cNumAnt),1,1 ) = "0"// Metodo da classe SWEDA 
	   cNumAnt := SubStr(cNumAnt,14,4)
	   lContinua := .F.
	Else
	   nVz++
	Endif

	If nVz > 5 .AND. lContinua
		Return 1
	Endif

End     
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta vetor com formas existentesณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู          
cRet  := ::FormasPgto   
While (At("|", cRet) > 0) 
   nPos := At("|", cRet)
   cFormas := SubStr(cRet, 1, nPos-1)
   AAdd(aFormas,cFormas)
   cRet := SubStr(cRet, nPos+1, Len(cRet))
End
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerificando qual o codigo da 	ณ
//ณcondicao de pagamento utilizado	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู          
cPos := "0"   
VarInfo("aFormas",aformas)
For nI := 1 to Len(aFormas) 
   If Upper(AllTrim(aFormas[nI])) = Upper(AllTrim(cCondicao)) 
     cPos := AllTrim(Str(nI))
   Endif  
Next nI  
If Len(cPos) < 2 
  cPos := "0" + cPos
Endif  
cTotFormaPagto := cPos  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAbrindo cupom nao fiscal 		ณ
//ณvinculado "00"					ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู           

If (cTotRecIni <> cTotalizador) .AND. cTotalizador <> cRecebTot
    cRet := ::EnviaComando( Chr(27)+".1900"+cNumAnt+cPos+Space(20)+StrZero(nParcelas,2)+"}")// Metodo da classe SWEDA 
    cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA	    
	If SubStr(cRet,1,2) <> ".+"
		cNumAnt := AllTrim(StrZero(Val(cNumAnt)-1, 4 ) ) 
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAbrindo cupom nao fiscal 		ณ
		//ณvinculado "00"					ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cRet := ::EnviaComando( Chr(27)+".1900"+cNumAnt+cPos+Space(20)+StrZero(nParcelas,2)+"}")// Metodo da classe SWEDA 
		cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA			
	EndIf
Else
	cRetorno := '1'   	
EndIf 
If SubStr(cRetorno,1,1) = "1" // Impressao do Cupom nao fiscal nao vinculado
	cRet    := " -"
	cValor  := FormataTexto(AllTrim(cValor),12,2,2)
	cRet    := "789ABCD"
	cFormas := ""
    For nI := 1 to 7
		cPos     := ::EnviaComando( Chr(27)+".29"+SubStr(cRet,nI,1)+"}")// Metodo da classe SWEDA
		nTamanho := Len(cPos)
		cFormas  := cFormas+SubStr(cPos,8,nTamanho)
	Next nI
	
	cFormas := SubStr(cFormas,31,Len(cFormas))
	aFormas := {}
	While AllTrim(cFormas) <> ""
		AAdd(aFormas, SubStr(cFormas,1,15))
		cFormas := SubStr(cFormas,16,Len(cFormas))
	End  
	If Val(cTotalizador) > 0//== "C"
		bTotalizadorIsNum := .T.
	Else
		bTotalizadorIsNum := .F.
	EndIf
	cPos       := "0"
	cPosTot    := "0"
	
	For nI := 1 to Len(aFormas)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInicializando o TOTALIZADOR para que sPos nao pegue uma legenda de outro Titulo.ณ
		//ณPois a legenda somente podera ser do mesmo titulo.                              ณ
		//ณEx.                                                                             ณ
		//ณ01 &GAVETA                -> Titulos                                            ณ
		//ณ02    + Recebimento       -> Legendas                                           ณ
		//ณ03    - Sangria           -> Legendas                                           ณ
		//ณ04 &Sigaloja              -> Titulos                                            ณ
		//ณ05    + Entrada Diversas  -> Legendas                                           ณ
		//ณ06    - Saidas diversas   -> Legendas                                           ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If bTotalizadorIsNum
			cPos  := cTotalizador
			If SubStr(aFormas[nI],1,1)="&"
				cPosTot:= FormataTexto(Str(nI),2,0,2)
			EndIf
			If FormataTexto(AllTrim(Str(nI)),2,0,2) = AllTrim(cPos)
				Exit
			Else
				cPos := "0"	
			EndIf
		Else 
	    	If SubStr(aFormas[nI],1,1)="&"
				cPosTot:= FormataTexto(Str(nI),2,0,2)			
			ElseIf AllTrim(Upper(SubStr(aFormas[nI],2,15))) == AllTrim(Upper(cTotalizador))
				cPos := FormataTexto(Str(nI),2,0,2)
				Exit			
			EndIf				
		EndIf

	Next nI
    
     
	If cPos == "0"
		Alert("Totalizador " + cTotalizador + " nใo encontrado na Impressora Fiscal")
		cRet := "1"	
	Else
	   	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAbre o cupom nใo vinculado		ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		 
		cDescTot  := SubStr(Alltrim(UPPER(cTotalizador)),1,7)
		If cDescTot == "RECARGA"  
		    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		    //ณTRATAMENTO PARA A RECARGA 	    ณ
		    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		    
		   	cPosTot := aScan(aFormas,{|X|X == cDescTot} )	   				
		Elseif cTotalizador == cRecebTot  		    
		    cPosTot := cTotalizador    	
		EndIf		
		If Len(AllTrim(cPos)) < 2
			cPos := "0" + AllTrim(cPos)
		EndIf
		If Len(AllTrim(cPosTot)) < 2
			cPosTot := "0" + AllTrim(cPosTot)
		EndIf
		oAutocom:cBuffer := Space(128) 
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	    //ณAbertura do Comprovante nao Fiscal ณ
	    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
		cRet := ::EnvCmdEspera( Chr(27) +".19" + AllTrim(cPosTot) + "      }" )  	
		If cRet = "0"
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณFaz o recebimento nao fiscal		ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	        //ณ Soma dos Valores    ณ
	        //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	 
	       	oAutocom:cBuffer := Space(128)  	
			cRet := ::EnvCmdEspera( Chr(27) +".07" + AllTrim(cPos) + cValor + "}", 3 ) 		
			If cRet = "0"
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณFaz o recebimento nao fiscal		ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				oAutocom:cBuffer := Space(128)  			
				cRet := ::EnvCmdEspera( Chr(27) +".10" + cTotFormaPagto + cValor+"}", 3 )  							
				If cRet = "0"
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณFecha o cupom indicando que 		ณ
					//ณhavera' um vinculado				ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					oAutocom:cBuffer := Space(128) 					
					cRet := ::EnvCmdEspera( Chr(27) +".12N}", 3 )
					If cRet = "0"
						oAutocom:cBuffer := Space(128)						
						cRet := ::EnvCmdEspera( Chr(27) +".271}", 10 )
						If cRet = "0"
							cNumAnt := SubStr( ::cBuffer, 14, 4 )
							oAutocom:cBuffer := Space(128)						
							cRet := ::EnvCmdEspera( Chr(27) +".1900"+cNumAnt+cTotFormaPagto+Space(20)+"01}", 10 ) 
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf	
	oAutocom:cBuffer := cRet
	nRet := Val(::TrataRetorno( 1, oAutocom:cBuffer ))
EndIf
If cDescTot == "RECARGA"                                   
	Conout("SWEDA Termica ST120 NIX - METHOD Comando da Gaveta - "+ Time() )   
    cComando := ::EnvCmdEspera( Chr(27) + ".21"+"}" ) //abre gaveta de Dinheiro 	
EndIf	
Conout("SWEDA Termica ST120 NIX - METHOD IFAbrCNFis - Termino - "+ Time() )
Return Val(cRet)

//----------------------------------------------------------------------------     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณIFSupr    บAutor  ณVendas Clientes     บData  ณ  MAR/09 	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSuprimento Variacao do tipo   	                          บฑฑ
ฑฑบ          ณTipo = 1 - Verifica se tem troco disponivel				  บฑฑ
ฑฑบ          ณTipo = 2 - Grava o valor informado no Suprimentos			  บฑฑ 
ฑฑบ          ณTipo = 3 - Sangra o valor informado						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA / FRONTLOJA, interfaces de venda  				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

METHOD IFSupr(nTipo,cValor,cForma,cTotal,nModo) CLASS LJSwedaTER

Local cRet 		:= ""
Local nI   		:= 0
Local aFormas 	:= {}
Local cFormas 	:= ""
Local cPos 		:= ""
Local nTamanho  := 0
Local cCondicao := ""
Local aPgto 	:= {}
Local cRetorno  := ""

Conout("SWEDA Termica ST120 NIX - METHOD IFSupr - Inicio - "+ Time() )
    					
cRet := " -"
cCondicao := cForma
cValor    := FormataTexto(cValor,12,2,2)
cRet      := "789ABCD"
cFormas   := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se tem troco disponivel	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTipo = 1 
	cRet    :="67"
    For nI  := 1 to 2 
	  //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	  //ณLendo os totais das modalidades  ณ
	  //ณde pagamento					  ณ
	  //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
      cPos     := ::EnviaComando( Chr(27)+".27"+SubStr(cRet,nI,1)+"}")// Metodo da classe SWEDA 
      nTamanho := (At("}",cPos)-1) - 7
      If nI = 2 
        cFormas  := cFormas+SubStr(cPos,8,48)
      Else
        cFormas  := AllTrim(SubStr(cPos,8,nTamanho))
      Endif
      
      While AllTrim(cFormas) <> "" 
        AAdd(aFormas, SubStr(cFormas,5,12))
        cFormas := SubStr(cFormas,17,Len(cFormas))        
      End
    Next nI  
    
    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
    //ณLe as condicoes de pagamento		ณ
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    cRet := ::IFLeConPag()//Metodo da classe SWEDA
    cRet := SubStr(cRet, 3, Len(cRet))
    aPgto := MontArray(cRet)
    
    For nI := 1 to Len(aPgto)
	  If Upper(AllTrim(aPgto[nI]))="DINHEIRO" 
        cPos:=Str(nI)
        Exit
      End
    Next nI
    
    If Val(aFormas[Val(sPos)]) >= Val(Valor)
      Return "8"
    Else
      Return "9" 
    Endif
Else
	cFormas :="DINHEIRO"
	If AllTrim(SubStr(cForma,3,Len(cForma))) <> "" 
		cFormas := AllTrim(SubStr(cForma,3,Len(cForma)))
	Endif
    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
    //ณGrava o valor informado no 		ณ
    //ณSuprimentos						ณ
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	  
	If (nTipo = 2) .AND. (AllTrim(cForma) = "") 
		cCondicao:="SUPRIMENTO"
	Endif  
    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
    //ณSangra o valor informado			ณ
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	  	  
	If (nTipo = 3) .AND. (AllTrim(cForma) = "")
		cCondicao:="SANGRIA"
	Endif
	If ( AllTrim(SubStr(cForma,1,2)) <> "") .AND. (AllTrim(SubStr(cTotal,1,2)) <> "")
		cPos := SubStr(cForma,1,2) + SubStr(cTotal,1,2)
	Else
		cCondicao := LOWER(cCondicao)
		cPos := GetPvProfString(cCondicao, "totalizador", "01", GetClientDir()+"SIGALOJA.INI")
		cPos := cPos + cPos		
	Endif   
	
	If (AllTrim(SubStr(cTotal,1,2)) = "") .AND. ((SubStr(cPos,1,2) = "00") .OR. (SubStr(cPos,3,2) = "00")) 
	    MsgStop("Nใo existe o Totalizador Nใo-Fiscal "+cCondicao+;
	      		'" dentro do Tํtulo Nใo-Fiscal "SIGALOJA".'+Chr(13)+'Adicione-o ap๓s uma Redu็ใo Z e antes de realizar uma venda.')
	    cRetorno := "1"
	Else
		cRet := ::EnviaComando( Chr(27)+".19" + SubStr(cPos,3,2)+ Space(26)+"00}")// Metodo da classe SWEDA 
		cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA
		Sleep(2000) 
		If SubStr(cRetorno,1,1) = "0" 
			cRet := ::EnviaComando( Chr(27)+".07" + SubStr(cPos,1,2)+cValor+"}")// Metodo da classe SWEDA 
		    cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA
		    If SubStr(cRetorno,1,1) = "0"
		      Sleep(500)
		      If nTipo = 2
				cValor   := AllTrim(Str(Val(cValor)))
		        ::IFPagto(cFormas+"|"+cValor,"N")
		        Sleep(500)
		      Endif
		    Endif
		    cRet := ::EnviaComando( Chr(27)+".12N}")// Metodo da classe SWEDA 
		    Sleep(2000) 
		    cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA
		Endif
	Endif
Endif

Conout("SWEDA Termica ST120 NIX - METHOD IFSupr - Termino - "+ Time() )

Return Val(cRetorno)   

//----------------------------------------------------------------------------   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณIFRecbNFisบAutor  ณVendas Clientes     บData  ณ  MAR/09 	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAbre um comprovante nao fiscal	                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA / FRONTLOJA, interfaces de venda  - Autocom.dll    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

METHOD IFRecbNFis(cTotalizador, cValor, cForma) CLASS LJSwedaTER
Local cRet     				//Retorno na impressora
Local cRetorno	:= ""	 	// Retorno da fun็ใo
Local cPos
Local nVz 		:= 0   	 	// Controle de laco

Conout("SWEDA Termica ST120 NIX - METHOD IFRecbNFis - Inicio - "+ Time() )
If UPPER(cForma) == "RECEB. CONTAS"      
	Return 0
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTem que escrever no SIGALOJA.INI o acumulador que vai ser utilizado para o recebimento. 	   ณ
//ณEx.:																						   ณ
//ณ                                                                                            ณ
//ณ[Recebimento Titulos]                                                                       ณ
//ณTotalizadores=RECEBIMENTO                                                                   ณ
//ณ                                                                                            ณ
//ณEsse totalizador deverแ estar abaixo do tํtulo &SIGALOJA.                                   ณ
//ณEx.:                                                                                        ณ
//ณ                                                                                            ณ
//ณ04 &SIGALOJA              -> Titulos                                                        ณ
//ณ05    + FUNDO DE CAIXA    -> Legendas                                                       ณ
//ณ06    + RECEBIMENTOS      -> Legendas                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
    //ณA forma de pagamento a ser 		ณ
    //ณutilizada nesse comprovante, 	ณ
    //ณsera' a apontada no parametro 	ณ
    //ณMV_NATRECEB						ณ
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  		

    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
    //ณInicializada a variavel 			ณ
    //ณnUltimoSeq						ณ
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  		
	::nUltimoSeq := 1 
    cValor   :=FormataTexto(AllTrim(cValor),12,2,2)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Faz um controle de 5 tentativas ณ
	//ณ para registrar o recebimento 	ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	While nVz <= 5 .AND. SubStr(cRetorno,1,1) <> "0"
	    cCondicao := LOWER(cForma)
	    cPos := GetPvProfString(cForma, "totalizador", "01", GetClientDir()+"SIGALOJA.INI")
	    cPos := cPos + cPos      
	    cRet := ::EnviaComando( Chr(27)+".19" + SubStr(cPos,3,2)+ "      " + Space(20) + "}")
	    cRetorno := ::TrataRetorno( 1,cRet )
	    if SubStr(cRetorno,1,1) = "0"
	       Sleep(2000) //2000
	       cRet := ::EnviaComando( Chr(27) + ".07" + SubStr(cPos,1,2) + cValor + "}")
	       cRetorno := ::TrataRetorno( 1,cRet )
	       Sleep(500)
	       cValor := AllTrim(cValor)
	
	       cRet:=::IFPagto(cForma+"|"+cValor,"N")
	
	       if SubStr(cRetorno,1,1) = "0" 
	          cRet := ::EnviaComando( Chr(27)+	".12}")
	          Sleep(2000)
	          cRetorno := ::TrataRetorno( 1,cRet )
	       Endif
	    Endif   
	    
	    nVz ++ 
	    Sleep(1000) 
	End
	    
Conout("SWEDA Termica ST120 NIX - METHOD IFRecbNFis - Termino - "+ Time() )
	    
Return (Val(cRetorno))

//-------------------------------------------------------------
METHOD IFPegCupom(cCancelamento) CLASS LJSwedaTER
Local nRet		:= 1
Local cRet
Local cComando   

Conout("SWEDA Termica ST120 NIX - METHOD IFPegCupom - Inicio - "+ Time() )   

If cCancelamento == "T"     
	cComando := Chr(27)+".28}"
	cRet := SubStr(::EnviaComando(cComando),11,8) 
	If cRet <> " VENDAS "
		oAutocom:cBuffer := "0000"   
		Return(0)
	EndIf
EndIf
    
cComando := Chr(27)+".27H}"
cRet := ::EnviaComando(cComando)
nRet := ::TrataRet(cRet)
If nRet == 1
	cComando := Chr(27)+".27H}"
	cRet := ::EnviaComando(cComando)
	nRet := ::TrataRet(cRet)
	If nRet == 1
		MsgStop("Erro ao Ler o Numero do Cupom no ECF.") 
		oAutocom:cBuffer := "0000"
	EndIf
EndIf 
If nRet == 0
	oAutocom:cBuffer := SubStr(cRet,73,6)+"  "
EndIf	                                                            	



Conout("SWEDA Termica ST120 NIX - METHOD IFPegCupom - Termino - "+ Time() )

Return(nRet)
	