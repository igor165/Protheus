#INCLUDE "PROTHEUS.CH"                  
#INCLUDE "APWEBSRV.CH"            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³GetRecVer ºAutor  ³Danilo Calil        º Data ³ 05/06/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³WS para executar as operacoes de recebimento	  			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSSTRUCT WSAnalise
	WSDATA Marcado 	AS Boolean
	WSDATA Contrato	AS String
	WSDATA Prefixo 	AS String
	WSDATA Titulo  	AS String
	WSDATA Parcela  AS String
	WSDATA Filial   AS String
	WSDATA VlrAcr 	AS Float
	WSDATA Cliente  AS String
	WSDATA Loja  	AS String
	WSDATA Vencto  	AS Date
ENDWSSTRUCT

WSSTRUCT WSNewArray
	WSDATA VerArray AS ARRAY OF WSAnalise
ENDWSSTRUCT

WSSTRUCT WSRetAnalise
	WSDATA Verdade 	AS Boolean
	WSDATA Contrato	AS String         
ENDWSSTRUCT
	
WSSERVICE AnalisaRec DESCRIPTION  "Serviço de identificação de parcelas" 
	WSDATA aAnaliseRet		AS ARRAY OF WSRetAnalise
	WSDATA aAnalise	   		AS WSNewArray

	WSMETHOD GetRecVer DESCRIPTION "Método que consulta a condicao de pagamento"
ENDWSSERVICE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³GetRecVer ºAutor  ³Danilo Calil        º Data ³ 05/06/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³WS para executar as operacoes de recebimento	  			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Interfaces de Venda                                         º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Progr.   ³ Data     BOPS   Descricao								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Danilo Cal³04/07/06³102617³Realiza busca no SE1 antes de validar aVerOk³±±
±±³Danilo Cal³04/07/06³103046³Retirada busca no SE1                       ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSMETHOD GetRecVer WSRECEIVE aAnalise WSSEND aAnaliseRet WSSERVICE AnalisaRec
 
Local aRet		:= {}					//Retorno da funcao
Local aVerOk	:= {}					//Contratos a serem verificados
Local nX		:= 0					//Contador de Loop

For nX := 1 to Len( ::aAnalise:VerArray )
	AAdd( aVerOk, Array( 10 ))
	aVerOk[nX][1] := ::aAnalise:VerArray[nX]:Marcado
	aVerOk[nX][2] := ::aAnalise:VerArray[nX]:Contrato
	aVerOk[nX][3] := ::aAnalise:VerArray[nX]:Prefixo
	aVerOk[nX][4] := ::aAnalise:VerArray[nX]:Titulo
	aVerOk[nX][5] := ::aAnalise:VerArray[nX]:Parcela
	aVerOk[nX][6] := ::aAnalise:VerArray[nX]:Filial
	aVerOk[nX][7] := ::aAnalise:VerArray[nX]:VlrAcr
	aVerOk[nX][8] := ::aAnalise:VerArray[nX]:Cliente
	aVerOk[nX][9] := ::aAnalise:VerArray[nX]:Loja
	aVerOk[nX][10]:= ::aAnalise:VerArray[nX]:Vencto
Next nX	

aRet := WSLJRVERIF( aVerOk )

If Len(aRet) > 0                                     
	For nX := 1 To Len(aRet)    
		AAdd( ::aAnaliseRet, WSClassNew("WSRetAnalise") )	
		::aAnaliseRet[nX]:Verdade 	:= aRet[nX][1]
		::aAnaliseRet[nX]:Contrato	:= aRet[nX][2]
	Next nX
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRVerif  ºAutor  ³Danilo Calil        º Data ³  24/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que marca os titulos que podem entrar no conceito   º±±
±±º          ³ do cliente Dadalto. Marca a primeira posicao do aTitulos c/º±±
±±º          ³ .T.                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpA1 - Array com os titulos                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpA1 - Array com os titulos alterados                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FRONT LOJA - RECEBIMENTOS                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function WsLJRVerif( aVerOk  )

Local aArea 		:= GetArea()							//GetArea
Local aAreaSX2 		:= SX2->(GetArea())					//Area do SE1
Local aAreaSF2 		:= SF2->(GetArea())					//Area do SE4
Local aAreaSE4 		:= SE4->(GetArea())					//Area do SE4
Local cF2FormPg		:= ""									//Forma de pagamento
Local nX			:= 0									//Contador de For
Local cAliasF2		:= "SF2"								//Alias SF2
Local cFilialSF2	:= ""									//Filial do SF2
Local lAchou 		:= .F.									//Controle de Loop do While
Local cMvFiliais	:= SuperGetMV("MV_FILACRS",,"01")   	//Filiais que trabalham com o conceito de acrescimo.
Local lUsaAcrsSp    := 	.F.									//Verifica usa conceito de acrescimo separado
Local lR5           := GetRpoRelease("R5")    				//Indica se o release e 11.5

If (lR5 .AND. SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")
	lUsaAcrsSp := .T.
Endif
For nX := 1 To Len(aVerOk)
	If aVerOk[nX][6] $ cMvFiliais .OR. lUsaAcrsSp
		DbSelectArea("SX2")
		DbSetOrder(1)
		MsSeek(cAliasF2)
		
		If FWModeAccess(FWX2Chave(),3) == "E"
			cFilialSF2 := aVerOk[nX][6] 
		Else
			cFilialSF2 := xFilial(cAliasF2)     
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se eh o primeiro titulo e se trabalha com o³
		//³conceito de acrescimo.                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aVerOk[nX][7] > 0
		   	DbSelectArea("SF2")
			DbSetOrder(2) //F2_CLIENTE + F2_LOJA + F2_DOC + F2_SERIE
			If MsSeek(	cFilialSF2 + aVerOk[nX][8] + aVerOk[nX][9] + aVerOk[nX][4] + ;
						aVerOk[nX][3])
			    While !EOF() .AND. cFilialSF2 + aVerOk[nX][8] + aVerOk[nX][9] + aVerOk[nX][4] ==;
					SF2->F2_FILIAL + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_DOC .AND. !lAchou
					If SF2->F2_PREFIXO == aVerOk[nX][3]
						lAchou := .T.
					EndIf
				End
				If lAchou
					cF2FormPg := SF2->F2_COND
					DbSelectArea("SE4")
					DbSetOrder(1)//E4_FILIAL + E4_CODIGO					
					If MsSeek( xFilial("SE4") + cF2FormPg) //E4_FILIAL + E4_CODIGO
						If ((dDataBase + SE4->E4_LIMACRS) <= aVerOk[nX][10]) .AND. SE4->E4_LIMACRS > 0              
							aVerOk[nX][1] := .T.
						EndIf
					EndIf
		   		EndIf
		   	EndIf
		EndIf
	EndIf
Next nX
	
RestArea(aAreaSX2)
RestArea(aAreaSF2)
RestArea(aAreaSE4)
RestArea(aArea)

Return (aVerOk)
