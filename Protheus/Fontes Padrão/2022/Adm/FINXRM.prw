#INCLUDE "PROTHEUS.CH"
#INCLUDE "ACADEF.CH"  
#include "TopConn.ch"
#include "RwMake.ch"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FINXRM.CH"
  

/*
{Protheus.doc} FINTA01(cMarca,cValExt,cStatus))
	Atualização da situação bancario do título                                
		
	@param  cMarca		Produto da Integração
	@param  cValExt		Título a ser atualizado. Valor Externo
	@param	cStatus  	Tipo de Operação a ser utilizada no titulo (1 - Envio para carteira TIN / 0 - Envio para carteira Simples)
	@param	cBanExt		InternalId do banco externo
	@param	cNumBco		Número do título no banco

	@retorno aRet		Array contendo o resultado da execucao e a mensagem Xml de retorno.
				aRet[1]	(boolean) Indica o resultado da execução da função
				aRet[2]	(caracter) Mensagem Xml para envio                             
	
	@author	Wesley Alves Pereira
	@version	P12
	@since	17/10/2018
*/

Function FINTA01(cMarca,cValExt,cStatus,cBanExt,cNumBco)

Local aValInt		:= {}
Local cFilTit       := ""
Local cPreInt       := ""
Local cNumInt       := ""
Local cParInt       := ""
Local cTipInt       := ""
Local aBanInt       := {}
Local cFilBco       := ""
Local cBanInt       := ""
Local cAgeInt       := ""
Local cConInt       := ""
Local lRet			:= .T.
Local aRetorno		:= {}
Local cCartei		:= SuperGetMV("MV_RMTINCA",,"0")

cCartei := Alltrim(cCartei)

If cCartei == "0"
	lRet:= .F.
	AADD(aRetorno,STR0001) //"Parâmetro da carteira de cobrança para recebimento da integração RM não informado"
Else
	DBSelectArea("FRV")
	DBSetOrder(1)
	If !DBSeek(xFilial("FRV")+cCartei)
		lRet:= .F.
		AADD(aRetorno,STR0002) //"Carteira de cobrança para recebimento da integração RM não cadastrada. Entidade (FRV) "
	ElseIf FRV->FRV_BANCO <> '1' .OR. FRV->FRV_DESCON <> '2'
		lRet:= .F.
		AADD(aRetorno,STR0003) //"Carteira selecionada deve possuir banco e não permitir cobrança descontada. Entidade (FRV) "
	EndIf	
Endif

aValint := F55GetInt(cValExt,cMarca,"SE1")

If aValint[1]
	cFilTit       := PadR(aValInt[2][2],TamSX3("E1_FILIAL")[1])
	cPreInt       := PadR(aValInt[2][3],TamSX3("E1_PREFIXO")[1])
	cNumInt       := PadR(aValInt[2][4],TamSX3("E1_NUM")[1])
	cParInt       := PadR(aValInt[2][5],TamSX3("E1_PARCELA")[1])
	cTipInt       := PadR(aValInt[2][6],TamSX3("E1_TIPO")[1])
Else
	lRet:= .F.
	AADD(aRetorno,STR0012 + cValExt )//"Não foi localizado o de/para para o título"
Endif

If cStatus <> "0"
	
	aBanInt:= M70GetInt(cBanExt, cMarca)
	If aBanInt[1]
		cFilBco       := PadR(aBanInt[2][2],TamSX3("A6_FILIAL")[1])
		cBanInt       := PadR(aBanInt[2][3],TamSX3("A6_COD")[1])
		cAgeInt       := PadR(aBanInt[2][4],TamSX3("A6_AGENCIA")[1])
		cConInt       := PadR(aBanInt[2][5],TamSX3("A6_NUMCON")[1])
	Else
		lRet:= .F.
		AADD(aRetorno,STR0014)	//"Não foi localizado o de/para para o banco "
	Endif

	If lRet
		DBSelectArea("SA6")
		DBSetOrder(1) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON 
		If !DBSeek(cFilBco+cBanInt+cAgeInt+cConInt)
			lRet:= .F.
			AADD(aRetorno,STR0005)	//"Tentativa de atualização com erro. Banco/Agencia/Conta não existe!"
		EndIf
	EndIf

EndIf

If lRet
	DBSelectArea("SE1")
	DBSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If DBSeek(cFilTit+cPreInt+cNumInt+cParInt+cTipInt)
		If FOrigTitRM("SE1")
			If Reclock("SE1",.F.)
				If cStatus == "0"
					E1_SITUACA 	:= "0"
					E1_MOVIMENT := ""
					E1_PORTADO  := ""
					E1_AGEDEP   := ""
					E1_CONTA    := ""
					E1_NUMBCO   := ""
				ElseIf cStatus == "1"
					E1_SITUACA 	:= cCartei
					E1_MOVIMENT := dDatabase
					E1_PORTADO  := cBanInt
					E1_AGEDEP   := cAgeInt
					E1_CONTA    := cConInt
					E1_NUMBCO   := cNumBco
				Else
					lRet:= .F.
					AADD(aRetorno,STR0006)	//"Erro na tentativa de atualização. Status do título inválido "
				EndIf 
				
				MsUnlock()
			EndIf
				lRet:= .F.
				AADD(aRetorno,STR0008) //"Erro na tentativa de atualização. Verifique se o título está em uso"
		Else
			lRet:= .F.
		    AADD(aRetorno,STR0015) //"Atualização disponível para títulos origem RM TIN na versão EAI 2!"
		EndIf
	Else
		lRet:= .F.
		AADD(aRetorno,STR0004) //"Tentativa de atualização com erro. Título não existe!" 
	EndIf
EndIf

Return {lRet,aRetorno}
/*
Realiza o bloqueio dos titulos a receber
cujo a origem seja do Totvs Incorporação

TypeLog == .F. Apresenta no console, do Application Server a mensagem.
TypeLog == .T. Apresenta na tela do usuário a mensagem.
*/
Function FINTP01(TypeLog , cAliasSe1)
Local lResult :=.F.
Local strTinP := STR0009 + CRLF + CRLF + STR0010 + CRLF + CRLF //" Não é possível prosseguir com a operação para títulos gerados pela integração TIN X PROTHEUS." " A operação deve ser realizada no sistema de origem Totvs Incorporação."

Default cAliasSe1:= "SE1"
// versão do Eai igual a 2
// Será bloqueado interação 
// com titulo de origem Protheus

strTinP += STR0012 + (cAliasSe1)->E1_PREFIXO + " - " + (cAliasSe1)->E1_NUM  + " - " + (cAliasSe1)->E1_PARCELA  + " - " + (cAliasSe1)->E1_TIPO //"Título: "

If !ALLTRIM(FUNNAME()) == "F070LST" .AND. !FwIsInCallStack("FINI055")
	If FOrigTitRM(cAliasSe1)
	  lResult:=.T.     
	  If(TypeLog)
	  	Help( ,,STR0011,,strTinP, 1, 0 ) //"Titulo Integrado!"
	  Endif        
	Endif
EndIf 

Return lResult

/*
Retonar verdadeiro quando a origem for do Totvs Incorporação
cAliasSe1 = Alias selecionado
*/
Function FOrigTitRM(cAliasSe1)
Local lResult :=.F.
Default cAliasSe1:= "SE1"
	
	lResult := (Alltrim((cAliasSe1)->E1_ORIGEM) == "FINI055")  .AND. (SuperGetMV("MV_RMTINVE",,1) == 2)

Return lResult

/*
Retorna filtro para titulos cujo a sua origem foi integração
dessa forma as operação para titulos de origem do Totvs Incorporação
serão bloqueados.
*/
Function FINTP02()
Local cFiltro := ""
If !ALLTRIM(FUNNAME()) == "F070LST"  .AND. (SuperGetMV("MV_RMTINVE",,1) == 2)
    cFiltro:= " AND E1_ORIGEM <> 'FINI055' "	          	
EndIf 
Return cFiltro

/*
Valida se o parâmetro foi configurado para aintegração TIN
@retorno 
	[1]	(boolean) Indica o resultado da execução da função
	[2]	(caracter) Conteúdo do paâmetro
*/

Function RMTINCA ()
Local cCartei	:= SuperGetMV("MV_RMTINCA",,"0")
Local lRet		:= .T.
cCartei := Alltrim(cCartei)

If cCartei == "0"
	Help( ,,,"FINXRMRMTINCA1",STR0001, 1, 0 ) //"Parâmetro da carteira de cobrança para recebimento da integração RM não informado"
	lRet := .F.
Else 
	DBSelectArea("FRV")
	DBSetOrder(1)
	If !DBSeek(xFilial("FRV")+cCartei)
		Help( ,,,"FINXRMRMTINCA2",STR0002, 1, 0 )  //"Carteira de cobrança para recebimento da integração RM não cadastrada. Entidade (FRV) "
		lRet := .F.
	ElseIf FRV->FRV_BANCO <> '1' .OR. FRV->FRV_DESCON <> '2'
		Help( ,,,"FINXRMRMTINCA3",STR0003, 1, 0 )  //"Carteira selecionada deve possuir banco e não permitir cobrança descontada. Entidade (FRV) "
		lRet := .F.
	EndIf	
Endif

Return {lRet,cCartei} 

/*/
{Protheus.doc} ValidarBXTIN
(Consistir os valores de baixa entre RM e Protheus)
@type  Function
@author william.Prado
@since 22/05/2019
@version 1.0
@param xAutoCab, Array , Informações de baixa
@return , Boolean, True  -> Não existe inconsistencia,       False -> divergencia dos valores entre RM e Protheus	
/*/
Function ValidarBXTIN(xAutoCab)
  	Local lRet        	:= .T.
	Local lPagParcial 	:= NIL
	Local nSaldoVA    	:= 0  // Saldo Valor Acessório
	Local nSaldoTit   	:= 0  // Saldo titulo 
 	Local nTaxMoed    	:= 1
  	Local nValRecibo  	:= 0
	Local nPosPagbxa  	:= 0
	Local nPosValRec  	:= 0
	Local nJur			:= 0
	Local nDesc	    	:= 0
	Local nMult      	:= 0
	Local nAcre	    	:= 0
	Local nDecre	    := 0
	Local nT     	    := 0
	Local nMoedBco    	:= Iif( Type("nMoedaBco") == "U", 1, nMoedaBco )
	Local dDtBaixa    	:= Iif( Type("dBaixa") == "U", dDataBase, dBaixa )
	Local nAbatTin		:= 0	// Abatimentos titulo
	
	nT := aScan(xAutoCab,{|x| x[1] == 'AUTMOTBX'})
    If nT > 0 .AND. AllTrim(xAutoCab[nT,2]) == 'TIN' // Não validar valores abaixo para cancelamento de contrato
		lRet := .T.
	ElseIf ( nPosPagbxa := aScan(xAutoCab,{|x| x[1] == 'PAGPARCIAL'})) > 0  .and. (nPosValRec := aScan(xAutoCab,{|x| x[1] == 'AUTVALREC'})) > 0

		If (nT := ascan(aAutoCab,{|x| x[1]='AUTJUROS'}) ) > 0
			nJur := Round(NoRound(aAutoCab[nT,2]),2)
		EndIf

		If (nT := ascan(aAutoCab,{|x| x[1]='AUTDESCONT'}) ) > 0
			nDesc := Round(NoRound(aAutoCab[nT,2]),2)
		EndIf

		If (nT := ascan(aAutoCab,{|x| x[1]='AUTMULTA'}) ) > 0
			nMult := Round(NoRound(aAutoCab[nT,2]),2)
		EndIf

		If (nT := ascan(aAutoCab,{|x| x[1]='AUTACRESC'}) ) > 0
			nAcre := Round(NoRound(aAutoCab[nT,2]),2)
		EndIf

		If (nT := ascan(aAutoCab,{|x| x[1]='AUTDECRESC'}) ) > 0
			nDecre := Round(NoRound(aAutoCab[nT,2]),2)
		EndIf

		lPagParcial := xAutoCab[nPosPagbxa][2] // Baixa do tipo parcial ou total
		nValRecibo  := xAutoCab[nPosValRec][2] // Valor total de baixa        
		nValRecibo  := nValRecibo - ( nJur + nMult + nAcre - nDecre - nDesc)

		If ( SE1->E1_SDACRES - SE1->E1_SDDECRE  <> 0)
			lRet := .F.
			HELP(,,,"FINXRMACDC", STR0019, 1, 0) // "Títulos gerados pela integração TIN X PROTHEUS não podem ter acréscimo e decréscimo"
		Else
			nSaldoVA := FValAcess( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_NATUREZ,/*lBaixados*/, , "R", dDtBaixa,/*aValAces*/, SE1->E1_MOEDA, nMoedBco, nTaxMoed )

			nAbatTin  := SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",dDtBaixa)

			nSaldoTit := (SE1->E1_SALDO + nSaldoVA - nAbatTin)  		
				
			If (!lPagParcial .AND. nSaldoTit != nValRecibo ) 			
				lRet := .F.						
				cMsgErro = "*** " + STR0020 + " *** "+ Chr(13) + Chr(10) + Chr(13) + Chr(10)	// "Tentativa de baixa do RM para o Protheus com valores diferentes!"
				cMsgErro +=  " *** " + STR0021 + " ***"    +   Chr(13) + Chr(10) 				// "Valores do título no Protheus"
				cMsgErro += STR0022 + "............: " + 	TRANSFORM(SE1->E1_SALDO  , "@E 999,999,999.99")    +   Chr(13) + Chr(10)	// "Saldo Título"
				cMsgErro += STR0023 + "...: " + 			TRANSFORM(nSaldoVA       , "@E 999,999,999.99")    +   Chr(13) + Chr(10) // "Saldo Valor Acessório"
				cMsgErro += STR0024 + ": " + 				TRANSFORM(nSaldoTit      , "@E 999,999,999.99")    +   Chr(13) + Chr(10) // "Total do Título Protheus"
				cMsgErro +=  " *** " + STR0025 + "***"  +   Chr(13) + Chr(10) // "Valor de baixa título RM"
                cMsgErro += STR0026 + ": " + TRANSFORM(( nJur + nMult + nAcre - nDecre - nDesc) ,"@E 999,999,999.99") +   Chr(13) + Chr(10) // "Encargos = (Juros + Multa + Acrescimo - Decrescimo - Desconto)"
				cMsgErro += STR0027 + ": " + TRANSFORM(xAutoCab[nPosValRec][2] ,"@E 999,999,999.99")  +  Chr(13) + Chr(10) // "Valor total de baixa =(Valor Baixa + Encargos )"
				cMsgErro += STR0028 + ": " + TRANSFORM(nValRecibo ,"@E 999,999,999.99")       +   Chr(13) + Chr(10) +  Chr(13) + Chr(10) // "Valor Recebido       =(Valor baixa - Encargos )"
				cMsgErro += STR0029 + ": " + TRANSFORM(nSaldoTit - nValRecibo ,"@E 999,999,999.99")       +   Chr(13) + Chr(10) // "Valor da diferença   =(Total do Título Protheus - Valor Recebido)"
                HELP(,,, "FINXRMVALDIF", cMsgErro, 1, 0)

			ElseIf (lPagParcial .AND. nValRecibo >= nSaldoTit )
				lRet := .F.
				cMsgErro = "*** " + STR0030 + " *** "+ Chr(13) + Chr(10) + Chr(13) + Chr(10)	// "Tentativa de baixa parcial com valor superior ao saldo!"
				cMsgErro +=  " *** " + STR0021 + "***"    +   Chr(13) + Chr(10)					
				cMsgErro += STR0022 + "............: " + 	TRANSFORM(SE1->E1_SALDO  , "@E 999,999,999.99")    +   Chr(13) + Chr(10)	// "Saldo Título"
				cMsgErro += STR0023 + "...: " + 			TRANSFORM(nSaldoVA       , "@E 999,999,999.99")    +   Chr(13) + Chr(10) // "Saldo Valor Acessório"
				cMsgErro += STR0024 + ": " + 				TRANSFORM(nSaldoTit      , "@E 999,999,999.99")    +   Chr(13) + Chr(10) // "Total do Título Protheus"
				cMsgErro +=  " *** " + STR0025 + "***"  +   Chr(13) + Chr(10) // "Valor de baixa título RM"
                cMsgErro += STR0026 + ": " + TRANSFORM(( nJur + nMult + nAcre - nDecre - nDesc) ,"@E 999,999,999.99") +   Chr(13) + Chr(10) // "Encargos = (Juros + Multa + Acrescimo - Decrescimo - Desconto)"
				cMsgErro += STR0027 + ": " + TRANSFORM(xAutoCab[nPosValRec][2] ,"@E 999,999,999.99")  +  Chr(13) + Chr(10) // "Valor total de baixa =(Valor Baixa + Encargos )"
				cMsgErro += STR0028 + ": " + TRANSFORM(nValRecibo ,"@E 999,999,999.99")       +   Chr(13) + Chr(10) +  Chr(13) + Chr(10) // "Valor Recebido       =(Valor baixa - Encargos )"
				cMsgErro += STR0029 + ": " + TRANSFORM(nSaldoTit - nValRecibo ,"@E 999,999,999.99")       +   Chr(13) + Chr(10) // "Valor da diferença   =(Total do Título Protheus - Valor Recebido)"				
				HELP(,,, "FINXRMVALSUP", cMsgErro, 1, 0) 
			EndIf		
		EndIf	
	Else
		HELP(,,,"FINXRMTAG", STR0018, 1, 0) // "A tag 'PAGPARCIAL' ou 'AUTVALREC' não foi informada."
		lRet := .F.
	EndIf

Return lRet

