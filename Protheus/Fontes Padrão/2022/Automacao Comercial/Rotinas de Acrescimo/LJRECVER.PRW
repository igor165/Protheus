#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LJRECVER.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJRECVER  ºAutor  ³Danilo Calil        º Data ³  24/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada que verifica se o E4_AGRACRS está habili- º±±
±±º          ³ tado, se o E4_LIMACRS tem informacao. Caso sim, modifica o º±±
±±º          ³ aTitulos somente o valor com o acrescimo.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpA1 - aTitulos de entrada pelo Paramixb  	              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpA1 - aTitulos alterado                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FRONT LOJA - RECEBIMENTOS                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function LJRECVER()

Local aTitulo		:= Paramixb[1]							//Array com os titulos a receber do cliente
Local cMv1Dup		:= SuperGetMV("MV_1DUP")				//Como esta as sequencias das duplicatas
Local cF2FormPg		:= ""									//Forma de pagamento
Local nX			:= 0									//Contador de For
Local nI			:= 0
Local cAliasF2		:= "SF2"								//Alias SF2
Local cFilialSF2	:= ""									//Filial do SF2
Local aContrato		:= {}									//Contratos
Local oSvc													//WebService
Local aRetContr		:= {}									//Retorno do WebService
Local lRet			:= .F.									//Retorno do WebService

//    aTitulo           aContrato
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³2-  Prefixo     ³³2-  Contrato    ³
//³3-  NumTitulo   ³³3-  Prefixo     ³
//³4-  Parcela     ³³4-  NumTitulo   ³
//³5-  Vencimento  ³³5-  Parcela     ³
//³6-  Valor       ³³6-  FilTit      ³
//³7-  VlrMulta    ³³7-  VlsAcres    ³
//³8-  VlrJuros    ³³8-  Cliente     ³
//³9-  VlrDesconto ³³9-  Loja        ³
//³10- VlrRecebido ³³10- Vencimento  ³
//³11- Tipo        ³ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//³12- Contrato    ³                    
//³13- Cliente     ³                    
//³14- Loja        ³                     
//³15- FilTit      ³                    
//³16- NumRecno    ³
//³17- VlrAcres    ³
//³18- Conceito    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Len(aTitulo) > 0
	For nX := 1 To Len(aTitulo)
		If cMv1Dup == aTitulo[nX][4] 
			Aadd(	aContrato,{	.F., 				aTitulo[nX][12],	aTitulo[nX][2],		aTitulo[nX][3],;
								aTitulo[nX][4],		aTitulo[nX][15],	aTitulo[nX][17],	aTitulo[nX][13],;
								aTitulo[nX][14],	aTitulo[nX][5]})
		EndIf
		aTitulo[nX][10]	:= aTitulo[nX][6] + aTitulo[nX][17]
	Next nX
EndIf

If Len(aContrato) > 0
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o metodo WSANALISAREC ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSvc := WSANALISAREC():New()
	iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autenticação do Web Service
	oSvc :_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/ANALISAREC.apw"	
	     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o array dentro do metodo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSvc:OWSAANALISE:OWSVERARRAY 					:= ANALISAREC_ARRAYOFWSANALISE():New()
	oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE 		:= Array( Len(aContrato) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Antes de chamar o metodo, atribui os valores ³
	//³as propriedades (passagem de parametros)     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	For nX := 1 To Len(aContrato)

		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX] := ANALISAREC_WSANALISE():New()
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:LMARCADO	:=	aContrato[nX][1]	
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CCONTRATO	:=	aContrato[nX][2]
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CPREFIXO	:=	aContrato[nX][3]
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CTITULO	:=	aContrato[nX][4]
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CPARCELA	:=	aContrato[nX][5]
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CFILIAL	:=	aContrato[nX][6]
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:NVLRACR	:=	aContrato[nX][7]
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CCLIENTE	:=	aContrato[nX][8]
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:CLOJA		:=	aContrato[nX][9]
		oSvc:OWSAANALISE:OWSVERARRAY:OWSWSANALISE[nX]:DVENCTO	:=	aContrato[nX][10]
	Next nX

	//"Aguarde...Verificando prazo..."
	LJMsgRun( STR0001,, { || lRet := oSvc:GETRECVER() } ) 
                                                                 
	If !lRet 
		cSvcError := GetWSCError()
		If Left(cSvcError,9) == "WSCERR048"					
			cSoapFCode  := Alltrim(Substr(GetWSCError(3),1,At(":",GetWSCError(3))-1))
			cSoapFDescr := Alltrim(Substr(GetWSCError(3),At(":",GetWSCError(3))+1,Len(GetWSCError(3))))
			Conout("Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
		Else
			//"Sem comunicação com o WebService!"+"Atencao"
			MsgStop(STR0002,STR0003)
		EndIf
	Else

		For nX := 1 to Len( oSvc:oWSGETRECVERRESULT:oWSWSRETANALISE )
			aAdd( aRetContr, { oSvc:oWSGETRECVERRESULT:oWSWSRETANALISE[nX]:LVERDADE, oSvc:oWSGETRECVERRESULT:oWSWSRETANALISE[nX]:CCONTRATO } )
		Next nX 
	Endif

	If Len(aRetContr) > 0
		For nX := 1 To Len(aRetContr)
			If aRetContr[nX][1]
				aEval( aTitulo,{|x| IIf(x[12] == aRetContr[nX][2],x[18] := .T.,"")})
			EndIf
		Next nX
	EndIf
EndIf	

Return(aTitulo)