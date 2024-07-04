#include "protheus.ch"
#include "Finlpgl.ch"
#include "msgraphi.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FinLOnl01³ Autor ³ Marcel Borges Ferreira³ Data ³ 07/02/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cotação de Moedas - Tipo 5                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FinLOnl01  										   	  	            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±             
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[1] = Bloco de codigo para execusao de duplo clique³±±
±±³          ³ aRetPanel[2] = Array contendo cabecalho                     ³±±
±±³			 | aRetPanel[3] = Array contendo valores da lista              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FinLOnl01()

	Local aArea 	 := GetArea()
	Local aCabec 	 := {STR0001,STR0002} //"Moeda","Cotação"
	Local aValores  := {}
	Local aRetPanel := {}
	Local nX
	
	DbSelectArea("SM2")
	SM2->(dBSeek(dDataBase))

	aValores := Array((MoedFin()-1),2)
	
	For nX := 2 to MoedFin()
		aValores[(nX-1)][1] := GetMV("MV_SIMB"+str(nX,1))
		aValores[(nX-1)][2] := Transform(&("SM2->M2_MOEDA"+str(nX,1)),PesqPict("SM2","M2_MOEDA"+str(nX,1)))
	Next nX

	aRetPanel := {NIL,aCabec,aValores}

	RestArea(aArea)		         
		         
Return aRetPanel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FinLOnl02³ Autor ³ Marcel Borges Ferreira³ Data ³ 07/02/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Titulos a receber atrasados - Tipo 1                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FinLOnl02  										   	  	            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[n][1] = Texto da coluna                           ³±±
±±³          ³ aRetPanel[n][2] = Valor a ser exibido                       ³±±
±±³			 | aRetPanel[n][3] = Cor do valor no formato RGB               ³±±
±±³          | aRetPanel[n][4] = Bloco de codigo p/ executar no click      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                          
Function FinLOnl02()

	Local aArea     	:= GetArea()
	Local cSE1a 		:= GetNextAlias()
	Local cSE1b 		:= GetNextAlias()	
	Local aRetPanel 	:= {}
	Local nSaldo 		:= 0

	BeginSql Alias cSE1a
		SELECT COUNT(*) ATRASADOS
		FROM %table:SE1% SE1
		WHERE E1_FILIAL = %Exp:xFilial("SE1")% 
		   AND E1_SALDO > 0 
		   AND E1_VENCREA < %Exp:Dtos(dDataBase)%
		   AND E1_TIPO <> "RA "			   
		   AND SE1.%NotDel%
	EndSql

	Aadd( aRetPanel, {STR0003,str((cSE1a)->ATRASADOS),CLR_RED,NIL})//Titulos a receber em atraso

	(cSE1a)->(dbCloseArea())
	dbSelectArea("SE1")

	BeginSql Alias cSE1b
		SELECT E1_SALDO, E1_SDACRES, E1_SDDECRE, E1_MOEDA, E1_TIPO 
		FROM %table:SE1% SE1
		WHERE E1_FILIAL = %Exp:xFilial("SE1")% 
		   AND E1_SALDO > 0 
		   AND E1_VENCREA < %Exp:Dtos(dDataBase)%
		   AND E1_TIPO <> "RA "		   		   
		   AND SE1.%NotDel%
		ORDER BY E1_TIPO
	EndSql	

	While !(cSE1b)->(Eof())		
		If (cSE1b)->E1_TIPO $ MV_CRNEG
			nSaldo -= xMoeda((cSE1b)->(E1_SALDO+E1_SDACRES-E1_SDDECRE),(cSE1b)->E1_MOEDA,1)		
		Else
			nSaldo += xMoeda((cSE1b)->(E1_SALDO+E1_SDACRES-E1_SDDECRE),(cSE1b)->E1_MOEDA,1)		
		Endif	
		(cSE1b)->(dbSkip())
	End

	Aadd( aRetPanel, {STR0007+GetMV("MV_SIMB1"),Transform(nSaldo,PesqPict("SE1","E1_SALDO")),CLR_RED,NIL})//Valores em

	(cSE1b)->(dbCloseArea())
	
	RestArea(aArea)

Return aRetPanel
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FinLOnl03³ Autor ³ Marcel Borges Ferreira³ Data ³ 07/02/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Maiores devedores - Tipo 2 - padrao 3                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FinLOnl03  										   	  	            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[1]       = Tipo do grafico                        ³±±
±±³          ³ aRetPanel[2]       = Bloco de codigo                        ³±±
±±³			 | aRetPanel[3][1][1] = Legenda                                ³±±
±±³          | aRetPanel[4][1]    =                                        ³±±
±±³          | aRetPanel[5][1][n] = Valores                                ³±±
±±³          | aRetPanel[6]       = Titulo                                 ³±±
±±³          | aRetPanel[7]       = sub titulo                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                          
Function FinLOnl03()

	Local aArea        := GetArea() 
	Local aRetPanel
	Local aEixoX       := {}
	Local aValores     := {}
	Local aEixoXAux	   := {}	    
    Local aValorXAux   := {}
	Local cAliasSA1    := GetNextAlias()
	Local cNome		    := ""	
	Local nDecs 	    := MsDecimais(1)
	Local nSaldo       := 0
	Local nCount       := 1  
	Local nI := 0

	Pergunte("FINPGL05",.F.)

	BeginSql Alias cAliasSA1
		SELECT A1_FILIAL, A1_COD, A1_NREDUZ, E1_SALDO, E1_SDACRES, E1_SDDECRE, E1_MOEDA, E1_TIPO
		FROM %table:SA1% SA1
		JOIN %table:SE1% SE1
		ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA
		WHERE A1_FILIAL = %Exp:xFilial("SA1")%
		   AND E1_SALDO > 0
		   AND E1_VENCREA < %Exp:Dtos(dDataBase)%
		   AND SE1.%NotDel%
		ORDER BY A1_FILIAL, A1_COD, A1_LOJA
	EndSql
	
	(cAliasSA1)->(dbGoTop()) 
	nI := 1
	If !(cAliasSA1)->(EOF()) 		
		Do While !(cAliasSA1)->(EOF()) //.and. nCount <= mv_par01
			cCliente := (cAliasSA1)->A1_COD
			cNome := (cAliasSA1)->A1_NREDUZ
			Do While (cAliasSA1)->A1_COD == cCliente    
				If !((cAliasSA1)->E1_TIPO $ MVRECANT+"/"+MVABATIM+"/"+MV_CRNEG)
					nSaldo += xMoeda((cAliasSA1)->(E1_SALDO+E1_SDACRES-E1_SDDECRE),(cAliasSA1)->E1_MOEDA,1,,nDecs+1)
				Else	
					nSaldo -= xMoeda((cAliasSA1)->(E1_SALDO+E1_SDACRES-E1_SDDECRE),(cAliasSA1)->E1_MOEDA,1,,nDecs+1)				
        		EndIf
				(cAliasSA1)->(dbSkip())
			End
			If nSaldo > 0
				Aadd( aEixoX, {cNome,nI} )
				Aadd( aValores, {nSaldo, nI})
				nI++
			EndIf
			nSaldo := 0
			nCount ++
		End
	Else
		Aadd( aEixoX, {STR0004, nI} )
		Aadd( aValores, {100, nI})
	End
	(cAliasSA1)->(dbCloseArea())
    
    If Len(aValores) > 0
    	aValores := Asort(aValores,,,{|x,y| x[1]>y[1]})       
	    aEixoXAux := {}	    
	    aValorXAux := {}	    
		If mv_par01 > Len(aValores)
			mv_par01 := Len(aValores)
		Endif
	    For nI := 1	to mv_par01
	    	aAdd(aEixoXAux,aEixoX[aValores[nI][2]][1])	
	    	aAdd(aValorXAux,aValores[nI][1])    	    	
	    Next    	    
	    aEixoX 	 := aEixoXAux
	    aValores :=	aValorXAux    	    
    Endif    
    
	aRetPanel := {GRP_PIE,;
		{},;
		{aEixoX},;
		{""},;
		{aValores},;
		STR0038,STR0037+GetMV("MV_SIMB"+str(1,1))} //"Maiores devedores" "Valores em "

	RestArea(aArea)

Return aRetPanel	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FinLOnl04³ Autor ³ Marcel Borges Ferreira³ Data ³ 16/02/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Maiores Credores - Tipo 1                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FinLOnl04  										   	  	            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[1]       = Tipo do grafico                        ³±±
±±³          ³ aRetPanel[2]       = Bloco de codigo                        ³±±
±±³			 | aRetPanel[3][1][1] = Legenda                                ³±±
±±³          | aRetPanel[4][1]    =                                        ³±±
±±³          | aRetPanel[5][1][n] = Valores                                ³±±
±±³          | aRetPanel[6]       = Titulo                                 ³±±
±±³          | aRetPanel[7]       = sub titulo                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                          
Function FinLOnl04()

	Local aArea        := GetArea()
	Local aEixoX       := {}
	Local aValores     := {}   
	Local aEixoXAux    := {}
	Local aValorXAux   := {}
	Local aRetPanel          	
	Local cAliasSA2    := GetNextAlias()	
	Local cNome		    := ""	
	Local nDecs 	    := MsDecimais(1)
	Local nSaldo       := 0
	Local nCount 	    := 1
	Local nI := 0
	                  
	Pergunte("FINPGL06",.F.)
	
	BeginSql Alias cAliasSA2
		SELECT A2_FILIAL, A2_COD, A2_LOJA, A2_NREDUZ, E2_SALDO, E2_SDACRES, E2_SDDECRE, E2_MOEDA, E2_TIPO, E2_LOJA
		FROM %table:SA2% SA2
		JOIN %table:SE2% SE2
		ON A2_COD = E2_FORNECE 
		   AND A2_LOJA = E2_LOJA 
		WHERE A2_FILIAL = %Exp:xFilial("SA2")%
		   AND E2_SALDO > 0
		   AND E2_VENCREA < %Exp:Dtos(dDataBase)%
		   AND SE2.%NotDel%
		   AND SA2.%NotDel%
		ORDER BY A2_FILIAL, A2_COD, A2_LOJA
	EndSql
	
	(cAliasSA2)->(dbGoTop())
	nI := 1
	If !(cAliasSA2)->(EOF())	
		Do While !(cAliasSA2)->(EOF()) .and. nCount <= mv_par01
			cCliente := (cAliasSA2)->A2_COD+(cAliasSA2)->A2_LOJA
			cNome := (cAliasSA2)->A2_NREDUZ
			Do While (cAliasSA2)->A2_COD+(cAliasSA2)->A2_LOJA == cCliente
				If ! ( (cAliasSA2)->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM )			
					nSaldo += xMoeda((cAliasSA2)->(E2_SALDO+E2_SDACRES-E2_SDDECRE),(cAliasSA2)->E2_MOEDA,1,,nDecs+1)
				Else
					nSaldo -= xMoeda((cAliasSA2)->(E2_SALDO+E2_SDACRES-E2_SDDECRE),(cAliasSA2)->E2_MOEDA,1,,nDecs+1)				
				EndIf
				(cAliasSA2)->(dbSkip())
			End
			If nSaldo > 0
				Aadd( aEixoX, {cNome,nI} )
				Aadd( aValores, {nSaldo,nI})			
				nI++
			EndIf
			nSaldo := 0
			nCount ++
		End
	Else
		Aadd( aEixoX, {STR0004,nI})
		Aadd( aValores, {100,nI})	
	End
	(cAliasSA2)->(dbCloseArea())
		
    If Len(aValores) > 0
    	aValores := Asort(aValores,,,{|x,y| x[1]>y[1]})       
	    aEixoXAux := {}	    
	    aValorXAux := {}	    
		If mv_par01 > Len(aValores)
			mv_par01 := Len(aValores)
		Endif
	    For nI := 1	to mv_par01
	    	aAdd(aEixoXAux,aEixoX[aValores[nI][2]][1])	
	    	aAdd(aValorXAux,aValores[nI][1])    	    	
	    Next    	    
	    aEixoX 	 := aEixoXAux
	    aValores :=	aValorXAux    	    
    Endif    
    	
	aRetPanel := {GRP_PIE,;
		{},;
		{aEixoX},;
		{""},;
		{aValores},;
		STR0039,STR0037+GetMV("MV_SIMB"+str(1,1))} //"Maiores credores" "Valores em "
	
	RestArea(aArea)

Return aRetPanel	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FinLOnl05³ Autor ³ Marcel Borges Ferreira³ Data ³ 21/02/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tit. a receber a vencer nos proximos dias - Tipo 2          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FinLOnl05  										   	  	            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[1] = Tipo do grafico                              ³±±
±±³          ³ aRetPanel[2] = Bloco de codigo                              ³±±
±±³			 | aRetPanel[3] = Eixo X                                       ³±±
±±³          | aRetPanel[4] = Legenda                                      ³±±
±±³          | aRetPanel[5] = Eixo Y                                       ³±±
±±³          | aRetPanel[6] = Titulo                                       ³±±
±±³          | aRetPanel[7] = sub titulo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FinLOnl05
	Local aArea      := GetArea()
	Local aLegenda   := {}
	Local aEixoX     := {}
	Local aEixoY     := {}
	Local aRetPanel  	
	Local cAliasSE1a := GetNextAlias()
	Local cAliasSE1b := GetNextAlias()	
	Local nSaldo 	  := 0
	Local nX         := 5
	Local dUltData	  := dDataBase	
	Local dDtLimite
	
	Pergunte("FINPGL07",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Variaveis utilizadas para parametros												³
//³  mv_par01		 // dias   																³
//³  mv_par02		 // Intervalo    													   ³
//³  mv_par03		 // Valor minimo													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	For nX := mv_par02 to mv_par01 step mv_par02
	
		dDtLimite := FaSomaData(mv_par02,dUltData)-1    	     
	
		BeginSql Alias cAliasSE1a
			SELECT COUNT(*) AVENCER
			FROM %table:SE1% SE1
			WHERE E1_FILIAL = %Exp:xFilial("SE1")% 
			   AND E1_SALDO > 0 
			   AND E1_SALDO >= %Exp:mv_par03% 			   			   
			   AND E1_VENCREA >= %Exp:dTos(dUltData)% AND E1_VENCREA <= %Exp:Dtos(dDtLimite)%
			   AND E1_TIPO <> "RA "
			   AND SE1.%NotDel%
		EndSql

		BeginSql Alias cAliasSE1b
			SELECT E1_MOEDA, SUM(E1_SALDO+E1_SDACRES-E1_SDDECRE) SALDO
			FROM %table:SE1% SE1
			WHERE E1_FILIAL = %Exp:xFilial("SE1")% 
			   AND E1_SALDO > 0 			
			   AND E1_SALDO >= %Exp:mv_par03% 			   
			   AND E1_VENCREA >= %Exp:dTos(dUltData)% AND E1_VENCREA <= %Exp:Dtos(dDtLimite)%
			   AND E1_TIPO <> "RA "
			   AND SE1.%NotDel%
			GROUP BY E1_MOEDA
		EndSql
                        	
		While !(cAliasSE1b)->(Eof())
			nSaldo += xMoeda((cAliasSE1b)->SALDO,(cAliasSE1b)->E1_MOEDA,1)
			(cAliasSE1b)->(dbSkip())
		End
		
		If !Empty((cAliasSE1a)->AVENCER)		
			Aadd( aEixoX,STR0037+GetMV("MV_SIMB"+str(1,1)))
			Aadd( aLegenda, STR(nX,3)+STR0005)
			Aadd( aEixoY,{nSaldo}) 
		EndIf

		(cAliasSE1a)->(dbCloseArea())
		(cAliasSE1b)->(dbCloseArea())		
		nSaldo := 0
		dUltData := FaSomaData(mv_par02,dUltData)
		
	Next Nx	
	
	If Empty(aEixoX)		
		aRetPanel := {GRP_BAR,;
			{},;
			{"0","0"},;
			{"0"},;
			{{0},{0}},;
			" "," "}
	Else
		aRetPanel := {GRP_BAR,;
			,;
			aEixoX,;
			aLegenda,;
			aEixoY,;
			,}
	EndIf	

	RestArea(aArea)     
	
Return aRetPanel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FinLOnl06³ Autor ³ Marcel Borges Ferreira³ Data ³ 23/02/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tit. a pagar a vencer nos proximos dias - Tipo 2            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FinLOnl06  										   	  	            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[n][1]    = Item da selecao                        ³±±
±±³          ³ aRetPanel[n][2][1] = Texto da coluna                        ³±±
±±³			 | aRetPanel[n][2][2] = Valor a ser exibido                    ³±±
±±³          | aRetPanel[n][2][3] = Cor do valor no formato RGB            ³±±
±±³          | aRetPanel[n][2][4] = Bloco de codigo p/ executar no click   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FinLOnl06
	Local aArea      := GetArea()
	Local	aEixoX     := {}
	Local	aEixoY     := {}	
	Local	aLegenda   := {}
	Local aRetPanel	
	Local cAliasSE2a := GetNextAlias()
	Local cAliasSE2b := GetNextAlias()	
	Local nSaldo 	  := 0
	Local nX 
	Local dUltData   := dDataBase
	Local dDtLimite

	Pergunte("FINPGL08",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Variaveis utilizadas para parametros												³
//³  mv_par01		 // dias   																³
//³  mv_par02		 // Intervalo    													   ³
//³  mv_par03		 // Valor minimo													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	For nX := mv_par02 to mv_par01 step mv_par02
		
		dDtLimite := FaSomaData(mv_par02,dUltData)-1    
	
		BeginSql Alias cAliasSE2a
			SELECT COUNT(*) AVENCER
			FROM %table:SE2% SE2
			WHERE E2_FILIAL = %Exp:xFilial("SE2")% 
			   AND E2_SALDO > 0 
			   AND E2_SALDO >= %Exp:mv_par03%	  		   			   
			   AND E2_VENCREA >= %Exp:dTos(dUltData)% AND E2_VENCREA <= %Exp:Dtos(dDtLimite)%
			   AND E2_TIPO <> "PA "
			   AND SE2.%NotDel%
		EndSql

		BeginSql Alias cAliasSE2b
			SELECT E2_MOEDA, SUM(E2_SALDO+E2_SDACRES-E2_SDDECRE) SALDO
			FROM %table:SE2% SE2
			WHERE E2_FILIAL = %Exp:xFilial("SE2")% 
			   AND E2_SALDO > 0 
			   AND E2_SALDO >= %Exp:mv_par03%			   
			   AND E2_VENCREA >= %Exp:dTos(dUltData)% AND E2_VENCREA <= %Exp:Dtos(dDtLimite)%			   
			   AND E2_TIPO <> "PA "
			   AND SE2.%NotDel%
			GROUP BY E2_MOEDA
		EndSql

		While !(cAliasSE2b)->(Eof())
			nSaldo += xMoeda((cAliasSE2b)->SALDO,(cAliasSE2b)->E2_MOEDA,1)
			(cAliasSE2b)->(dbSkip())
		End
		
		If !Empty((cAliasSE2a)->AVENCER)		
			Aadd(aEixoX,STR0037+GetMV("MV_SIMB"+str(1,1)))
			Aadd( aLegenda, STR(nX,3)+STR0005)
			Aadd( aEixoY,{nSaldo}) 
		EndIf
		
		(cAliasSE2a)->(dbCloseArea())
		(cAliasSE2b)->(dbCloseArea())		
		nSaldo := 0
		dUltData := FaSomaData(mv_par02,dUltData)
	Next Nx	
	
	If Empty(aEixoX)		
		aRetPanel := {GRP_BAR,;
			{},;
			{"0","0"},;
			{"0"},;
			{{0},{0}},;
			" "," "}
	Else	
		aRetPanel := {GRP_BAR,;
			,;
			aEixoX,;
			aLegenda,;
			aEixoY,;
			,}	
	EndIf

	RestArea(aArea)     
	
Return aRetPanel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FinLOnl07³ Autor ³ Marcel Borges Ferreira³ Data ³ 06/02/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Maiores Fornecedores - Tipo 5                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FinLOnl07  										   	  	            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[1] = Bloco de codigo para execusao de duplo clique³±±
±±³          ³ aRetPanel[2] = Array contendo cabecalho                     ³±±
±±³			 | aRetPanel[3] = Array contendo valores da lista              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FinLOnl07()
	Local aArea 		:= GetArea()
	Local aRetPanel
	Local aEixoX      := {}
	Local cAliasSA2 	:= GetNextAlias()
//	Local aCabec 		:= {STR0008,STR0009,STR0010,STR0011} //"Fornecedor" "Maior compra" "Total de compras" "Ultima compra"
	Local aValores    := {}
	Local nDecs 	 	:= MsDecimais(1)
	Local nSaldo 		:= 0
	Local nCount 		:= 1
//	Local cMCompra
	Local cNome
	Local cFornece         
	Local aEixoXAux := {} 
	Local aValorXAux := {}   
	Local nI := 0
			
	Pergunte("FINPGL01",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Variaveis utilizadas para parametros												³
//³  mv_par01		 // dias   																³
//³  mv_par02		 // Fornecedores 													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	BeginSql Alias cAliasSA2
		COLUMN A2_ULTCOM AS DATE
		SELECT A2_COD, A2_NREDUZ,A2_MNOTA,A2_ULTCOM,A2_LOJA,E2_VALOR,E2_EMISSAO,E2_SALDO,E2_SDACRES,E2_SDDECRE,E2_MOEDA,E2_LOJA,E2_TIPO
		FROM %table:SA2% SA2
		JOIN %table:SE2% SE2
		ON A2_COD=E2_FORNECE 
			AND A2_LOJA=E2_LOJA
		WHERE A2_FILIAL = %Exp:xFilial("SA2")%
			AND E2_FILIAL = %Exp:xFilial("SE2")%
				AND E2_EMISSAO BETWEEN %Exp:Dtos(dDataBase-mv_par01)% AND %exp:DtoS(dDataBase)% 
			AND SA2.%NotDel%
			AND SE2.%NotDel%
		ORDER BY A2_FILIAL, A2_COD, A2_LOJA
	EndSql

	(cAliasSA2)->(dbGoTop())
    nI := 1
	If !(cAliasSA2)->(EOF())
		Do While !(cAliasSA2)->(EOF()) //.and. nCount <= mv_par02
			cFornece := (cAliasSA2)->A2_COD+(cAliasSA2)->A2_LOJA
			cNome := (cAliasSA2)->A2_NREDUZ
			Do While (cAliasSA2)->A2_COD+(cAliasSA2)->A2_LOJA == cFornece      
				If !((cAliasSA2)->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM)			
					nSaldo += xMoeda((cAliasSA2)->(E2_VALOR),(cAliasSA2)->E2_MOEDA,1,,nDecs+1)
				EndIf
				(cAliasSA2)->(dbSkip())
			End
			If nSaldo > 0  
				aAdd( aEixoX, {cNome,nI})
				aAdd( aValores,{nSaldo,nI})
				nI++
			EndIf
			nSaldo := 0
			nCount ++
		End
	Else
		Aadd( aEixoX, {STR0004,nI})
		Aadd( aValores, {100,nI})	
	EndIf

	(cAliasSA2)->(dbCloseArea())	
	
	If Len(aValores)>0
		aValores := aSort(aValores,,,{|x,y| x[1]>y[1]})
		aEixoXAux := {} 
		aValorXAux := {}

		If mv_par02>Len(aValores)
			mv_par02 := Len(aValores)
		EndIf

		For nI :=1 to mv_par02
		   aAdd(aEixoXAux,aEixoX[aValores[nI][2]][1]) 
		   aAdd(aValorXAux,aValores[nI][1])		   
		Next
		
		aEixoX 	 := aEixoXAux 
		aValores := aValorXAux
	Endif	

	aRetPanel := {GRP_PIE,;
		{},;
		{aEixoX},;
		{""},;
		{aValores},;
		STR0040,STR0037+GetMV("MV_SIMB"+str(1,1))} //"Maiores frnecedores" "Valores em "

	RestArea(aArea)
	
Return aRetPanel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FinLOnl08³ Autor ³ Marcel Borges Ferreira³ Data ³ 06/02/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Maiores clientes - Tipo 5                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FinLOnl08  										   	  	            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[1] = Bloco de codigo para execusao de duplo clique³±±
±±³          ³ aRetPanel[2] = Array contendo cabecalho                     ³±±
±±³			 | aRetPanel[3] = Array contendo valores da lista              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FinLOnl08()

	Local aArea 		:= GetArea()
	Local cAliasSA1 	:= GetNextAlias()
//	Local aCabec 		:= {STR0012,STR0009,STR0010,STR0011} //"Cliente" "Maior compra" "Total de compras" "Ultima compra"
	Local aValores    := {}
	Local aEixoX		:= {}
	Local aRetPanel
	Local nDecs 	 	:= MsDecimais(1)
	Local nSaldo 		:= 0
	Local nCount 		:= 1
//	Local cMCompra
	Local cNome
	Local cCliente    
	Local aEixoXAux := {} 
	Local aValorXAux := {}   
	Local nI := 0
			
	Pergunte("FINPGL02",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Variaveis utilizadas para parametros												³
//³  mv_par01		 // dias   																³
//³  mv_par02		 // Clientes     													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	BeginSql Alias cAliasSA1
		COLUMN A1_ULTCOM AS DATE
		SELECT A1_COD, A1_NREDUZ,A1_MCOMPRA,A1_ULTCOM,E1_VALOR,E1_EMISSAO,E1_SALDO,E1_SDACRES,E1_SDDECRE,E1_MOEDA,E1_TIPO
		FROM %table:SA1% SA1
		JOIN %table:SE1% SE1
		ON A1_COD=E1_CLIENTE
			AND A1_LOJA=E1_LOJA
		WHERE A1_FILIAL = %Exp:xFilial("SA1")%
			AND E1_FILIAL = %Exp:xFilial("SE1")%
			AND E1_EMISSAO BETWEEN %Exp:Dtos(dDatabase-mv_par01)% AND %Exp:Dtos(dDatabase)%
			AND SA1.%NotDel%
			AND SE1.%NotDel%
		ORDER BY A1_FILIAL, A1_COD, A1_LOJA
	EndSql

	(cAliasSA1)->(dbGoTop())
	nI := 1
	If !(cAliasSA1)->(EOF())
		Do While !(cAliasSA1)->(EOF()) //.and. nCount <= mv_par02
			cCliente := (cAliasSA1)->A1_COD
			cNome := (cAliasSA1)->A1_NREDUZ
			Do While (cAliasSA1)->A1_COD == cCliente  
				If !((cAliasSA1)->E1_TIPO $ MVRECANT+"/"+MVABATIM+"/"+MV_CRNEG)
					nSaldo += xMoeda((cAliasSA1)->(E1_VALOR),(cAliasSA1)->E1_MOEDA,1,,nDecs+1)
				EndIf
				(cAliasSA1)->(dbSkip())
			End         
			If nSaldo > 0    
				Aadd( aEixoX, {cNome,nI})
				Aadd( aValores,{nSaldo,nI})
				nI++				
			EndIf
			nSaldo := 0
			nCount ++
		End
	Else
		Aadd(aEixoX, {STR0004,nI})
		Aadd(aValores, {100,nI})			
	EndIf

	(cAliasSA1)->(dbCloseArea())
	
	If Len(aValores) > 0
		aValores := aSort(aValores,,,{|x,y| x[1]>y[1]})
		aEixoXAux := {} 
		aValorXAux := {}

		If mv_par02>Len(aValores)
			mv_par02 := Len(aValores)
		EndIf

		For nI := 1 to mv_par02
		   aAdd(aEixoXAux,aEixoX[aValores[nI][2]][1]) 
		   aAdd(aValorXAux,aValores[nI][1])		   
		Next
		
		aEixoX 	 := aEixoXAux 
		aValores := aValorXAux
	Endif		
	
	aRetPanel := {GRP_PIE,;
		{},;
		{aEixoX},;
		{""},;
		{aValores},;
		STR0041,STR0037+GetMV("MV_SIMB"+str(1,1))} //"Maiores frnecedores" "Valores em "

	RestArea(aArea)

Return aRetPanel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FinLOnl09³ Autor ³ Marcel Borges Ferreira³ Data ³ 08/03/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Saldos Bancarios - Tipo 5                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FinLOnl09  										   	  	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[1]    = Tipo de Gráfico                           ³±±
±±³          ³ aRetPanel[2][1] = Título do grafico                         ³±±
±±³			 | aRetPanel[2][2] = Bloco p/ executar no click do grafico     ³±±
±±³          | aRetPanel[2][3] = Array contendo atributos                  ³±±
±±³          | aRetPanel[2][4] = Array contendo valores dos atributos      ³±±
±±³          | aRetPanel[3][1] = Titulo da tabela                          ³±±
±±³          | aRetPanel[3][2] = Bloco p/ executar no click da tabela      ³±±
±±³          | aRetPanel[4][1][1] = Título tabela                          ³±±
±±³          | aRetPanel[4][1][2] = Array contendo cabecalho               ³±±
±±³          | aRetPanel[4][1][3] = Array contendo os valores da lista     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FinLOnl09()

    
	Local aArea 	 := GetArea()
	Local cAliasSA6 := GetNextAlias()
	Local aGrafico		:= {{STR0042,STR0043,STR0044},{0,0,0}}//"Ativos"##"Inativos"##"Todos"
	Local aCabec 	 := {STR0013,STR0014,STR0015,STR0016,STR0017} //"Moeda","Cotação"
	Local aValores  := {{STR0042,aCabec,{}},{STR0043,aCabec,{}},{STR0044,aCabec,{}}} //"Ativos"##"Inativos"##"Todos"
	Local aRetPanel := {}
	Local cTipoDB	:= Alltrim(Upper(TCGetDB()))
	                           
    If ("ORACLE" $ cTipoDB .or. "DB2" $ cTipoDB .or. "INFORMIX" $ cTipoDB)
		BeginSql Alias cAliasSA6
			SELECT SA6.A6_NOME, SA6.A6_AGENCIA, SA6.A6_NUMCON, SE8.E8_SALATUA, SA6.A6_LIMCRED, SA6.A6_BLOCKED
			   FROM %table:SA6% SA6
		   	JOIN %table:SE8% SE8
		   	ON SA6.A6_COD = SE8.E8_BANCO AND SA6.A6_AGENCIA = SE8.E8_AGENCIA AND SA6.A6_NUMCON = SE8.E8_CONTA
		   	WHERE SA6.A6_FILIAL = %Exp:xFilial("SA6")%
		   		AND SE8.E8_FILIAL = %Exp:xFilial("SE8")%
			    AND SE8.E8_DTSALAT = (SELECT MAX(SE8A.E8_DTSALAT)
		                               FROM %table:SE8% SE8A
		                                  WHERE SE8A.E8_FILIAL = %Exp:xFilial("SE8")%
		                                  AND SA6.A6_COD = SE8A.E8_BANCO
		                                  AND SA6.A6_AGENCIA = SE8A.E8_AGENCIA 
		 	  		                      AND SA6.A6_NUMCON = SE8A.E8_CONTA 
		                        	      AND SE8A.%NotDel% )
		   	   AND SA6.%NotDel%
		   	   AND SE8.%NotDel%
			   ORDER BY A6_FILIAL,A6_COD,A6_AGENCIA,A6_NUMCON
		EndSql
   Else
		//********************************************************
		// Melhoria de performance somente foi testada para SQL  *
		// Abrir outra FNC para tratamento em todos os bancos    *
		//********************************************************
		BeginSql Alias cAliasSA6
			SELECT DISTINCT	SA6.A6_NOME,SA6.A6_AGENCIA,SA6.A6_NUMCON, 
				(SELECT E8_SALATUA
					FROM %table:SE8% SE8A
					WHERE 
						SE8A.E8_FILIAL = %Exp:xFilial("SE8")% AND 
						SA6.A6_COD = SE8A.E8_BANCO AND 
						SA6.A6_AGENCIA = SE8A.E8_AGENCIA AND 
						SA6.A6_NUMCON = SE8A.E8_CONTA AND 
						SE8A.E8_DTSALAT=MAX(SE8.E8_DTSALAT) AND 
						SE8A.%NotDel%) E8_SALATUA,
				SA6.A6_LIMCRED, SA6.A6_BLOCKED, A6_COD		
			FROM %table:SA6% SA6	JOIN %table:SE8% SE8
				ON SA6.A6_COD = SE8.E8_BANCO AND SA6.A6_AGENCIA = SE8.E8_AGENCIA AND SA6.A6_NUMCON = SE8.E8_CONTA AND 
				SA6.A6_FILIAL = %Exp:xFilial("SA6")% AND SE8.E8_FILIAL = %Exp:xFilial("SE8")%
			WHERE  
				SA6.%NotDel%	AND SE8.%NotDel%
			GROUP BY SA6.A6_NOME, SA6.A6_AGENCIA, SA6.A6_NUMCON, SA6.A6_LIMCRED, SA6.A6_BLOCKED, A6_COD
			ORDER BY A6_COD, A6_AGENCIA, A6_NUMCON
		EndSql
   EndIf

	Do While !(cAliasSA6)->(EOF())
		//******************
		// Todos os bancos *
		//******************
		Aadd( aValores[3,3], {A6_NOME,A6_AGENCIA,A6_NUMCON,GetMV("MV_SIMB1")+Transform(E8_SALATUA,PesqPict("SA6","A6_SALATU")),GetMV("MV_SIMB1")+Transform(A6_LIMCRED,PesqPict("SE8","E8_SALATUA")),E8_SALATUA} )
		aGrafico[2,3] += E8_SALATUA
		If A6_BLOCKED<>"1"
			//************************
			// Bancos nao bloqueados *
			//************************
			Aadd( aValores[1,3], {A6_NOME,A6_AGENCIA,A6_NUMCON,GetMV("MV_SIMB1")+Transform(E8_SALATUA,PesqPict("SA6","A6_SALATU")),GetMV("MV_SIMB1")+Transform(A6_LIMCRED,PesqPict("SE8","E8_SALATUA")),E8_SALATUA} )
			aGrafico[2,1] += E8_SALATUA
		Else
			//********************
			// Bancos bloqueados *
			//********************
			Aadd( aValores[2,3], {A6_NOME,A6_AGENCIA,A6_NUMCON,GetMV("MV_SIMB1")+Transform(E8_SALATUA,PesqPict("SA6","A6_SALATU")),GetMV("MV_SIMB1")+Transform(A6_LIMCRED,PesqPict("SE8","E8_SALATUA")),E8_SALATUA} )
			aGrafico[2,2] += E8_SALATUA
		Endif
		(cAliasSA6)->(dbSkip())
	End
	
	If Len(aValores[1,3])==0
		Aadd( aValores[1,3], {'','','',GetMV("MV_SIMB1")+Transform(0,PesqPict("SA6","A6_SALATU")),GetMV("MV_SIMB1")+Transform(0,PesqPict("SE8","E8_SALATUA")),0} )			
	EndIf
	
	If Len(aValores[2,3])==0
		Aadd( aValores[2,3], {'','','',GetMV("MV_SIMB1")+Transform(0,PesqPict("SA6","A6_SALATU")),GetMV("MV_SIMB1")+Transform(0,PesqPict("SE8","E8_SALATUA")),0} )			
	EndIf
	
	If Len(aValores[3,3])==0
		Aadd( aValores[3,3], {'','','',GetMV("MV_SIMB1")+Transform(0,PesqPict("SA6","A6_SALATU")),GetMV("MV_SIMB1")+Transform(0,PesqPict("SE8","E8_SALATUA")),0} )			
	EndIf
		
	aadd(aRetPanel,GRP_BAR)
	aadd(aRetPanel,{STR0035,,aGrafico[1],aGrafico[2]})
	aadd(aRetPanel,{"",,aValores}) 
	
	(cAliasSA6)->(dbCloseArea())
	
	RestArea(aArea)		         
		         
Return aRetPanel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FinLOnl10³ Autor ³ Marcel Borges Ferreira³ Data ³ 13/03/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aging a Pagar - Tipo 5                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FinLOnl10  										   	  	            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[1] = Bloco de codigo para execusao de duplo clique³±±
±±³          ³ aRetPanel[2] = Array contendo cabecalho                     ³±±
±±³			 | aRetPanel[3] = Array contendo valores da lista              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FinLOnl10()

	Local aArea		  := GetArea()
	Local cAliasSE2a := GetNextAlias()
	Local cAliasSE2b := GetNextAlias()
	Local aCabec 	  := {STR0018}
	Local aValores   := {}
	Local aRetPanel
	Local nSaldo 	  := 0
	Local nVencidos  := 0
  	Local nDecs 	  := MsDecimais(1)	
  	Local nDias 	  := 0
  	Local lWhile 	  := .F.
  	Local dInicial
  	Local dFinal

	Pergunte("FINPGL03",.F.)
   
	dInicial := dDataBase - mv_par01
	dFinal   := dDataBase + mv_par02

	//Titulos Vencidos
	BeginSql Alias cAliasSE2a
	SELECT E2_SALDO, E2_SDACRES, E2_SDDECRE, E2_MOEDA FROM %table:SE2% SE2
	WHERE E2_FILIAL = %Exp:xFilial("SE2")%
		AND E2_SALDO > 0
		AND E2_EMISSAO BETWEEN %Exp:Dtos(dInicial)% AND %Exp:Dtos(dFinal)%
		AND E2_VENCREA < %Exp:dTos(dDataBase)%
		AND E2_TIPO <> "PA "
		AND SE2.%NotDel%
	EndSql	
	
	Do While !(cAliasSE2a)->(Eof())
		nVencidos += xMoeda((cAliasSE2a)->(E2_SALDO+E2_SDACRES-E2_SDDECRE),(cAliasSE2a)->E2_MOEDA,1,,nDecs+1)
		(cAliasSE2a)->(dbSkip())
	End
	                  
	Aadd( aValores, {GetMV("MV_SIMB1")+" "+LTrim(Transform(nVencidos,PesqPict("SE2","E2_SALDO")))})
                  
	//Titulos a vencer
	
	BeginSql Alias cAliasSE2b
	COLUMN E2_VENCREA AS DATE
	SELECT E2_VENCREA, E2_SALDO, E2_SDACRES, E2_SDDECRE, E2_MOEDA 
	FROM %table:SE2% SE2
	WHERE E2_FILIAL = %Exp:xFilial("SE2")%
		AND E2_SALDO > 0		
		AND E2_VENCREA >= %Exp:dTos(dDataBase)% AND E2_VENCREA <= %Exp:dTos(dFinal)%		
		AND SE2.%NotDel%
	ORDER BY E2_FILIAL,E2_VENCREA
	EndSql		       
    
        
	dInicial := dDataBase	
	nDias   := mv_par03
	
	Do While !(cAliasSE2b)->(Eof())
		Do While !(cAliasSE2b)->(Eof()) .AND. (cAliasSE2b)->E2_VENCREA < FaSomaData(ndias,dInicial)
			nSaldo += xMoeda((cAliasSE2b)->(E2_SALDO+E2_SDACRES-E2_SDDECRE),(cAliasSE2b)->E2_MOEDA,1,,nDecs+1)
			(cAliasSE2b)->(dbSkip())
			lWhile := .T.
		End
		If lWhile
			aadd(aCabec, STR0019+LTrim(str(nDias))+STR0005)
			Aadd(aValores[1], GetMV("MV_SIMB1")+" "+LTrim(Transform(nSaldo,PesqPict("SE2","E2_SALDO"))) )
		Endif		
		nSaldo := 0
		lWhile := .F.
		ndias += mv_par03
	End           
	
	aRetPanel := {NIL,aCabec,aValores}  
	
	(cAliasSE2a)->(dbCloseArea())
	(cAliasSE2b)->(dbCloseArea())                                        
	
	RestArea(aArea)
	         
Return aRetPanel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FinLOnl11³ Autor ³ Marcel Borges Ferreira³ Data ³ 16/03/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aging a Receber - Tipo 5                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FinLOnl11  										   	  	            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[1] = Bloco de codigo para execusao de duplo clique³±±
±±³          ³ aRetPanel[2] = Array contendo cabecalho                     ³±±
±±³			 | aRetPanel[3] = Array contendo valores da lista              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FinLOnl11()

	Local aArea		  := GetArea()
	Local cAliasSE1a := GetNextAlias()
	Local cAliasSE1b := GetNextAlias()
	Local aCabec 	  := {STR0018}
	Local aValores   := {}
	Local aRetPanel  := {}
	Local nSaldo 	  := 0
	Local nVencidos  := 0
  	Local nDecs 	  := MsDecimais(1)	
  	Local nDias 	  := 0
  	Local lWhile 	  := .F.
  	Local dInicial
  	Local dFinal 
  	    
	Pergunte("FINPGL04",.F.)

	dInicial := dDataBase - mv_par01
	dFinal   := dDataBase + mv_par02
	
	//Titulos Vencidos
	BeginSql Alias cAliasSE1a
	SELECT E1_SALDO, E1_SDACRES, E1_SDDECRE, E1_MOEDA, E1_TIPO FROM %table:SE1% SE1
	WHERE E1_FILIAL = %Exp:xFilial("SE1")%
		AND E1_SALDO > 0
		AND E1_EMIS1 BETWEEN %Exp:Dtos(dInicial)% AND %Exp:Dtos(dFinal)%
		AND E1_VENCREA < %Exp:dTos(dDataBase)%
		AND E1_TIPO <> "RA "
		AND SE1.%NotDel%		
	EndSql	
	
	Do While !(cAliasSE1a)->(Eof())
		If (cAliasSE1a)->E1_TIPO $ MV_CRNEG
	   		nVencidos -= xMoeda((cAliasSE1a)->(E1_SALDO+E1_SDACRES-E1_SDDECRE),(cAliasSE1a)->E1_MOEDA,1,,nDecs+1)
			(cAliasSE1a)->(dbSkip())			
		Else
		nVencidos += xMoeda((cAliasSE1a)->(E1_SALDO+E1_SDACRES-E1_SDDECRE),(cAliasSE1a)->E1_MOEDA,1,,nDecs+1)
		(cAliasSE1a)->(dbSkip())
		EndIf
	End
	                  
	Aadd( aValores, {GetMV("MV_SIMB1")+" "+LTrim(Transform(nVencidos,PesqPict("SE1","E1_SALDO")))})
                  
	//Titulos a vencer
	BeginSql Alias cAliasSE1b
	COLUMN E1_VENCREA AS DATE
	SELECT E1_VENCREA, E1_SALDO, E1_SDACRES, E1_SDDECRE, E1_MOEDA , E1_TIPO  
	FROM %table:SE1% SE1
	WHERE E1_FILIAL = %Exp:xFilial("SE1")%
		AND E1_SALDO > 0		
		AND E1_EMIS1 BETWEEN %Exp:Dtos(dInicial)% AND %Exp:Dtos(dFinal)%
		AND E1_VENCREA >= %Exp:dTos(dInicial)%
		AND E1_TIPO <> "RA "
		AND SE1.%NotDel%
	ORDER BY E1_FILIAL,E1_VENCREA
	EndSql		       
	
	dInicial := dDataBase
	nDias   := mv_par03
	
	Do While !(cAliasSE1b)->(Eof())
		Do While !(cAliasSE1b)->(Eof()) .AND. (cAliasSE1b)->E1_VENCREA <  FaSomaData(ndias,dInicial)
			If (cAliasSE1b)->E1_TIPO $ MV_CRNEG
				nSaldo -= xMoeda((cAliasSE1b)->(E1_SALDO+E1_SDACRES-E1_SDDECRE),(cAliasSE1b)->E1_MOEDA,1,,nDecs+1)
				(cAliasSE1b)->(dbSkip())
				lWhile := .T.
			Else
				nSaldo += xMoeda((cAliasSE1b)->(E1_SALDO+E1_SDACRES-E1_SDDECRE),(cAliasSE1b)->E1_MOEDA,1,,nDecs+1)
				(cAliasSE1b)->(dbSkip())
				lWhile := .T.
			EndIf	
		End
		If lWhile
			aadd(aCabec, STR0019+LTrim(str(nDias))+STR0005)
			Aadd(aValores[1], GetMV("MV_SIMB1")+" "+LTrim(Transform(nSaldo,PesqPict("SE1","E1_SALDO"))) )
		Endif		
		nSaldo := 0
		lWhile := .F.
		ndias += mv_par03
	End 
	
	(cAliasSE1a)->(dbCloseArea())
	(cAliasSE1b)->(dbCloseArea())          
	
	aRetPanel := {NIL,aCabec,aValores}
	
	RestArea(aArea)
	         
Return aRetPanel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FinLOnl12³ Autor ³ Marcel Borges Ferreira³ Data ³ 20/03/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valores de aplicações e emprestimos - Tipo 2                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FinLOnl12  										   	  	            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[n][1]    = Item da selecao                        ³±±
±±³          ³ aRetPanel[n][2][1] = Texto da coluna                        ³±±
±±³			 | aRetPanel[n][2][2] = Valor a ser exibido                    ³±±
±±³          | aRetPanel[n][2][3] = Cor do valor no formato RGB            ³±±
±±³          | aRetPanel[n][2][4] = Bloco de codigo p/ executar no click   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FinLOnl12
	Local aArea      	:= GetArea()
	Local cAliasSEH  	:= GetNextAlias()
	Local aRetPanel  	:= {}
	Local aAplic 		:= {}
	Local	nSaldoApl   := 0
	Local	nRendBruto 	:= 0
	Local	nTaxaIof  	:= 0
	Local	nTaxaIrf  	:= 0
	Local	nRendLiquid := 0
	Local nTaxaOutros	:=	0
	Local cAplCotas   := GetMv("MV_APLCAL4")
	Local	nEmprestimo := 0
	Local	nTxNominal 	:= 0
	Local	nTxContra 	:= 0
	Local	nJuros 		:= 0
	Local	nPagamento 	:= 0

	PRIVATE dA181DtApr := dDatabase	

	BeginSql Alias cAliasSEH
	SELECT SEH.R_E_C_N_O_ SEHRECNO, EH_APLEMP
	FROM %table:SEH% SEH
	WHERE
		SEH.EH_FILIAL = %xfilial:SEH%
		AND SEH.%notDel%
	EndSql	

	Do While !(cAliasSEH)->(EOF())

		//Aplicacoes
		If (cAliasSEH)->EH_APLEMP = 'APL' 
			SEH->(MsGoto((cAliasSEH)->SEHRECNO))

			aCalculo := Fp12Calc(cAplCotas,@aAplic)

			nSaldoApl += SEH->EH_SALDO
			nRendBruto += aCalculo[5]
			nTaxaIof += aCalculo[3]
			nTaxaIrf += aCalculo[2]
			nTaxaOutros += aCalculo[4]
			nRendLiquid += (aCalculo[1]-(aCalculo[2]+aCalculo[3]+aCalculo[4]))
		
		//Emprestimos
		ElseIf (cAliasSEH)->EH_APLEMP = 'EMP'
			SEH->(MsGoto((cAliasSEH)->SEHRECNO))		
			
			nA181VlMoed:= RecMoeda(dA181DtApr,SEH->EH_MOEDA)
			nA181SPCP2	:= 0
			nA181SPLP2	:= 0
			nA181SPCP1	:= 0
			nA181SPLP1	:= 0
			nA181SJUR2	:= 0
			nA181SJUR1	:= 0
			nA181SVCLP	:= 0
			nA181SVCCP	:= 0
			nA181SVCJR	:= 0
			nA181VPLP1 	:= 0
			nA181VPCP1 	:= 0
			nA181VJUR1 	:= 0
			nA181VVCLP 	:= 0
			nA181VVCCP 	:= 0
			nA181VVCJR 	:= 0
			nA181VPLP2 	:= 0
			nA181VlDeb	:= 0
			
			aCalculo	  := Fa171Calc(dDataBase,SEH->EH_SALDO,.F.)
			
			nA181SPCP2 := Round(SEH->EH_SALDO * SEH->EH_PERCPLP/100 , TamSX3("EH_SALDO")[2])
			nA181SPLP2 := SEH->EH_SALDO - nA181SPCP2
			nA181SPLP1 := SEH->EH_VLCRUZ
			nA181SPCP1 := Round(SEH->EH_VLCRUZ * SEH->EH_PERCPLP/100,TamSX3("EH_SALDO")[2])
			nA181SPLP1 := SEH->EH_VLCRUZ - nA181SPCP1
			nA181SJUR2 := aCalculo[1,2]
			nA181SJUR1 := aCalculo[2,2]
			nA181SVCLP := aCalculo[2,3]
			nA181SVCCP := aCalculo[2,4]
			nA181SVCJR := aCalculo[2,5]
			nA181VlIRF := 0
			nA181VLDES := 0
			nA181VLGAP := 0
			nA181STOT1 := nA181SPLP1+nA181SPCP1+nA181SJUR1+nA181SVCLP+nA181SVCCP+nA181SVCJR
			nA181STOT2 := nA181SPLP2+nA181SPCP2+nA181SJUR2
			nA181VPLP1 := nA181SPLP1
			nA181VPCP1 := nA181SPCP1
			nA181VPLP2 := nA181SPLP2
			nA181VPCP2 := nA181SPCP2
			nA181VJUR1 := nA181SJUR1
			nA181VJUR2 := nA181SJUR2
			nA181VVCLP := nA181SVCLP
			nA181VVCCP := nA181SVCCP
			nA181VVCJR := nA181SVCJR
			nA181VTOT1 := nA181STOT1
			nA181VTOT2 := nA181STOT2				
			
			Fa181Valor(,"DA181DTAPR")

			nEmprestimo += xMoeda(SEH->EH_SALDO,SEH->EH_MOEDA,1)
			nTxNominal 	+= SEH->EH_TAXA
			nTxContra 	+= SEH->EH_TARIFA
			nJuros 		+= xMoeda(nA181SJUR2 ,SEH->EH_MOEDA,1)
			nPagamento 	+= xMoeda(nA181VlDeb,1,1,dDataBase)
			
			
		EndIf	
		(cAliasSEH)->(dbSkip())
	End
	
	Aadd( aRetPanel,{STR0020,; 
				{	{ STR0016,Transform(nSaldoApl,PesqPict("SEH","EH_SALDO")),,},;
				   { STR0021,Transform(nRendBruto,PesqPict("SEH","EH_SALDO")),,},;
				   { STR0022,Transform(nTaxaIof,PesqPict("SEH","EH_SALDO")),,},;
					{ STR0023,Transform(nTaxaIrf,PesqPict("SEH","EH_SALDO")),,},;
					{ STR0024,Transform(nTaxaOutros,PesqPict("SEH","EH_SALDO")),,},;					
					{ STR0025,Transform(nRendLiquid,PesqPict("SEH","EH_SALDO")),CLR_RED,NIL}}})
					
	Aadd( aRetPanel,{STR0026,; 
				{	{ STR0027,Transform(nEmprestimo,PesqPict("SEH","EH_SALDO")),,},;
				   { STR0028,Transform(nTxNominal,PesqPict("SEH","EH_TAXA")),NIL,NIL},;
				   { STR0029,Transform(nTxContra,PesqPict("SEH","EH_TARIFA")),NIL,NIL},;
					{ STR0030,Transform(nJuros,PesqPict("SEH","EH_SALDO")),CLR_RED,NIL},;
					{ STR0031,Transform(nPagamento,PesqPict("SEH","EH_SALDO")),CLR_RED,NIL}}})

	(cAliasSEH)->(dbCloseArea())
	
	RestArea(aArea)     
	
Return aRetPanel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fp12Calc   ºAutor  ³Marcel B. Ferreira  º Data ³  20/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo dos valores a serem impressos                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FINLPGL                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fp12Calc(cAplCotas,aAplic,cAliasSeh)

	Local aRet := {0,0,0,0,0,0}
	Local nAscan
	If ! SEH->EH_TIPO $ cAplCotas
		aRet	:= Fa171Calc(dDataBase,SEH->EH_SALDO,.T.)
	Else
		aRet := {0,0,0,0,0,0}
		SE9->(DbSetOrder(1))	
		SE9->(MsSeek(xFilial()+SEH->EH_CONTRAT+SEH->EH_BCOCONT+SEH->EH_AGECONT))
		SE0->(MsSeek(xFilial("SE0")+SE9->(E9_BANCO+E9_AGENCIA+E9_CONTA+E9_NUMERO)))
		Aadd(aAplic,{	SEH->EH_CONTRAT,SEH->EH_BCOCONT,SEH->EH_AGECONT, SE0->E0_VALOR})
		nAscan := Ascan(aAplic, {|e|	e[1] == SEH->EH_CONTRAT .And.;
											   e[2] == SEH->EH_BCOCONT .And.;
											   e[3] == SEH->EH_AGECONT})
		If nAscan > 0
			aRet	:=	Fa171Calc(dDataBase,SEH->EH_SLDCOTA,,,,SEH->EH_VLRCOTA,aAplic[nAscan][4],(SEH->EH_SLDCOTA * aAplic[nAscan][4]))
		Endif	
	EndIf		
	
Return aRet                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FaSomaData ºAutor  ³Marcel B. Ferreira  º Data ³  20/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Soma 'nDias'a uma data				                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FINLPGL                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FaSomaData(nDias,dDataCalc)	

	Local nX := 1	  
	Local lTpMovDias := SuperGetMv("MV_TPDIASM",.T.,.F.) == .T. // o movimento sera efetuado por dias uteis ou dias corridos
		
	DEFAULT dDataCalc := dDataBase
	DEFAULT nDias := 1
	
	If lTpMovDias // dias uteis 
		While nX <= nDias +1
			If DataValida(dDataCalc,.T.) == dDataCalc				
				If nX <= nDias  
					dDataCalc += 1
				EndIf
				nX +=1
			Else
				dDataCalc += 1
			Endif
		EndDo		
	Else // dias corridos
		dDataCalc += nDias		
	Endif	
		
Return dDataCalc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FinLOnl13³ Autor ³ Marcel Borges Ferreira³ Data ³ 22/03/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valores a receber classificados por risco                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FinLOnl13  										   	  	            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRetPanel[1]    = Tipo de Gráfico                           ³±±
±±³          ³ aRetPanel[2][1] = Título do grafico                         ³±±
±±³			 | aRetPanel[2][2] = Bloco p/ executar no click do grafico     ³±±
±±³          | aRetPanel[2][3] = Array contendo atributos                  ³±±
±±³          | aRetPanel[2][4] = Array contendo valores dos atributos      ³±±
±±³          | aRetPanel[3][1] = Titulo da tabela                          ³±±
±±³          | aRetPanel[3][2] = Bloco p/ executar no click da tabela      ³±±
±±³          | aRetPanel[4][1][1] = Título tabela                          ³±±
±±³          | aRetPanel[4][1][2] = Array contendo cabecalho               ³±±
±±³          | aRetPanel[4][1][3] = Array contendo os valores da lista     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAFIN                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FinLonl13

	Local aArea      	:= GetArea()
	Local cAliasSE1	:= GetNextAlias()
	Local aRetPanel  	:= {}
	Local aTabela	  	:= {}
	Local aGrafico		:= {{},{}}
	Local nSaldo 	  	:= 0
	Local cRisco
	Local cCliente	  	:= ""
	Local cNReduz		:= ""
	Local nTit			:= 0
	Local nMatriz 		:= 0
	Local nX				:= 0
	Local nY				:= 0
	Local nTotTit	   := 0
	
	BeginSql Alias cAliasSE1
		SELECT COUNT(*) TIT, E1_MOEDA, SUM(E1_SALDO+E1_SDACRES-E1_SDDECRE) SALDO, A1_RISCO, A1_NREDUZ, A1_COD 
		FROM %table:SE1% SE1
		JOIN %table:SA1% SA1
		ON E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA
		WHERE E1_FILIAL = %Exp:xFilial("SE1")% 
		   AND E1_SALDO > 0
		   AND SE1.%NotDel%
		   AND E1_TIPO <> "RA "
		GROUP BY A1_RISCO, A1_NREDUZ, A1_COD, E1_MOEDA
	EndSql
	   
	While !(cAliasSE1)->(Eof())
	
		cCliente := (cAliasSE1)->A1_COD
		cNReduz := (cAliasSE1)->A1_NREDUZ	
		
		If !(cRisco == (cAliasSE1)->A1_RISCO)
			aadd(aTabela, {If((cAliasSE1)->A1_RISCO==" ",STR0032,(cAliasSE1)->A1_RISCO),{STR0033,STR0034,STR0035},{}})
			aadd(aGrafico[1],If((cAliasSE1)->A1_RISCO==" ",STR0032,(cAliasSE1)->A1_RISCO))
			cRisco := (cAliasSE1)->A1_RISCO
			nMatriz ++
		EndIf
		
		//Converte e soma titulos do cliente
		While (cAliasSE1)->A1_COD == cCliente
			nSaldo += xMoeda((cAliasSE1)->SALDO,(cAliasSE1)->E1_MOEDA,1)
			nTit	 += (cAliasSE1)->TIT
			(cAliasSE1)->(dbSkip())
		End 
		//Adiciona cliente na tabela
		Aadd(aTabela[nMatriz][3],{cNReduz,LTrim(str(nTit)),Transform(nSaldo,PesqPict("SE1","E1_SALDO")),nSaldo})

		nSaldo := 0
		nTit := 0
		
	End

	/*
	aTabela[x][1] := Risco do cliente
	aTabela[x][2] := Cabeçalho
	aTabela[x][3] := Valores
	aTabela[x][3][1] := Nome do Cliente
	aTabela[x][3][2] := Qtd. Titulos
	aTabela[x][3][3] := Saldo (saldo texto)
	aTabela[x][3][4] := Saldo (valor)
	*/
	
	For nX:=1 to Len(aTabela) step 1
		For nY:=1 to Len(aTabela[nX,3])
			//nTotTit += Val(aTabela[nX,3,nY,2]) 
			
			nTotTit += aTabela[nX,3,nY,4]
			
		Next
		aadd(aGrafico[2],nTotTit)
		nTotTit:=0                         
	Next
	
	aadd(aRetPanel,GRP_PIE)
	aadd(aRetPanel,{STR0036,,aGrafico[1],aGrafico[2]})
	aadd(aRetPanel,{"",,aTabela})
	
	(cAliasSE1)->(dbCloseArea())

	RestArea(aArea)     
					 		
Return aRetPanel

