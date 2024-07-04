#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "GTPJ002.CH"

Function GTPJTEF(aParam)
Local lJob			:= Iif(Select("SX6")==0,.T.,.F.)  //Rotina automatica (schedule)
Local cEmpJob		:= ""
Local cFilJob		:= ""
Local lUsaColab 	:= .F.
Local cFilOk 		:= ""
Local cDataIni		:= ""
Local cDataFim		:= ""
Local cAgeIni		:= ""
Local cAgeFim		:= ""

cEmpJob := aParam[Len(aParam)-3]
cFilJob := aParam[Len(aParam)-2]

If lJob
	RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA cEmpJob FILIAL cFilJob MODULO "FAT"
EndIf   

cFilOk := cfilant

If !Empty(StoD(aParam[1])) .And. !Empty(StoD(aParam[2]))
	cDataIni := aParam[1]
	cDataFim := aParam[2]
	cAgeIni  := aParam[3]
	cAgeFim  := aParam[4]

Endif

GTPP002(ljob, cDataIni, cDataFim, cAgeIni, cAgeFim)

cFilAnt	:= cFilOk

Return()

Function GTPJ002(aParam)
Local lJob			:= Iif(Select("SX6")==0,.T.,.F.)  //Rotina automatica (schedule)
Local lUsaColab 	:= .F.
Local cFilOk 		:= ""
//---Inicio Ambiente

If lJob // Schedule
	RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] MODULO "FAT"
EndIf   

cFilOk := cfilant

GTPP002(ljob)

cFilAnt	:= cFilOk

Return()

Function GTPP002(ljob, cDataIni, cDataFim, cAgeIni, cAgeFim)
Local cAliasJob	 	    := GetNextAlias()
Local aTit	 		    := {}
Local aRet			    := {}
Local cRet 			    := ''
Local cCliSBan		    := '999' // cliente sem bandeira
Local cDescAdm		    := ''
Local cTipo			    := ""
Local cHistTit          := ""
Local nParc			    := 0 
Local cFpagto		    := ""
Local cNatureza		    := ""
Local CARTAO_CREDITO    := GTPGetRules('TPCARDCRED', .F., Nil, "CC")
Local CARTAO_DEBITO	    := GTPGetRules('TPCARDDEBI', .F., Nil, "CD")
Local CARTAO_PARCELADO	:= GTPGetRules('TPCARDPARC', .F., Nil, "CP")
Local cQuery 			:= ''

Default ljob	 := .F.
Default cDataIni := ''
Default cDataFim := ''
Default cAgeIni  := ''
Default cAgeFim  := '' 

If !Empty(cDataIni) .And. !Empty(cDataFim)
	cQuery += " AND GIC.GIC_DTVEND BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
Endif

If !Empty(cAgeIni) .And. !Empty(cAgeFim)
	cQuery += " AND GIC.GIC_AGENCI BETWEEN '" + cAgeIni + "' AND '" + cAgeFim + "' "
Endif

cQuery := "%"+cQuery+"%"

BeginSQL Alias cAliasJob

	SELECT 
		GZP.GZP_FILIAL FILGZP, 
		GZP.GZP_CODIGO CODIGO,
		GZP.GZP_CODBIL CODBIL,
		GZP.GZP_ITEM   ITEM,
		GI6.GI6_FILRES FILRES, 
		GZP.GZP_FPAGTO FPAGTO, 
		GZP.GZP_QNTPAR PARCTIT, 
		GIC.GIC_CODIGO GICCOD,
		GIC.GIC_DTVEND DTTIT, 
		GIC.GIC_STATUS STATUS,
		GIC.GIC_BILREF BILREF,
		GZP.GZP_TPAGTO TPTIT, 
		GZP.GZP_AUT AUT, 
		GZP.GZP_NSU NSU, 
		GZP.GZP_ESTAB ESTAB, 
		SUM(GZP.GZP_VALOR) VLTIT
	FROM %Table:GZP% GZP
		INNER JOIN %Table:GIC% GIC ON
			GIC.GIC_FILIAL = GZP.GZP_FILIAL
			AND GIC.GIC_CODIGO = GZP.GZP_CODIGO
			AND GIC.GIC_BILHET = GZP.GZP_CODBIL 
			%Exp:cQuery%
			AND GIC.GIC_NUMFCH <> ''
			AND GIC.%NotDel%
		INNER JOIN %Table:GI6% GI6 ON
			GI6.GI6_FILIAL = GIC.GIC_FILIAL
			AND GI6.GI6_CODIGO = GIC.GIC_AGENCI
			AND GI6.%NotDel%
	WHERE  	
		GZP_STAPRO IN ('','0')
		AND GZP_FPAGTO <> ' '
		AND GZP.%NotDel%
	GROUP BY 
		GZP.GZP_FILIAL, 
		GZP.GZP_CODIGO,
		GZP.GZP_CODBIL,
		GZP.GZP_ITEM,
		GI6.GI6_FILRES, 
		GZP.GZP_FPAGTO, 
		GZP.GZP_QNTPAR, 
		GIC.GIC_CODIGO,
		GIC.GIC_DTVEND, 
		GIC.GIC_STATUS,
		GIC.GIC_BILREF,
		GZP.GZP_TPAGTO, 
		GZP.GZP_AUT, 
		GZP.GZP_NSU, 
		GZP.GZP_ESTAB 
	ORDER BY GI6.GI6_FILRES, GIC.GIC_CODIGO
				
EndSQL

SAE->(DbSetOrder(1))
G58->(DbSetOrder(2))
SA1->(DbSetOrder(1))
SED->(DbSetOrder(1))

(cAliasJob)->(dbGoTop())

While (cAliasJob)->(!Eof())

	If !Empty((cAliasJob)->FILRES)
		cfilant := (cAliasJob)->FILRES
	Endif

	If (cAliasJOB)->STATUS $ 'E|V'

		aTit := {}

		If SAE->(DbSeek(xFilial("SAE") + (cAliasJob)->FPAGTO ))
			G58->(DBSETORDER(1))
			If G58->(DbSeek(xFilial("G58") + SAE->AE_COD))	.AND. !Empty(G58->G58_CLIENT) .AND.	!Empty(G58->G58_LOJA)		
				SA1->(DbSeek(xFilial("SA1") + G58->G58_CLIENT+G58->G58_LOJA ))
				SED->(DbSeek(xFilial("SED") + G58->G58_NATURE))
				cDescAdm	:= Posicione('SAE',1,xFilial('SAE') + G58->G58_CODADM, 'AE_DESC')
				cNatureza	:= G58->G58_NATURE
			Else
				SA1->(DbSeek(xFilial("SA1") + cCliSBan ))
				SED->(DbSeek(xFilial("SED") + SA1->A1_NATUREZ ))
				cDescAdm	:= Posicione('SAE',1,xFilial('SAE') + (cAliasJob)->FPAGTO, 'AE_DESC')	
				cNatureza	:= SA1->A1_NATUREZ
			Endif
			
			nParc	:= (cAliasJob)->PARCTIT
			
			If AllTrim((cAliasJob)->TPTIT) == "DE"
				cTipo	:= CARTAO_DEBITO
			ElseIf nParc > 1
				cTipo	:= CARTAO_PARCELADO
			Else
				cTipo	:= CARTAO_CREDITO
			Endif
			
			cHistTit := (cAliasJob)->(FILGZP + CODIGO + CODBIL)
			
			aAdd(aTit,nParc)
			aAdd(aTit,(cAliasJob)->VLTIT)
			aAdd(aTit,STOD((cAliasJob)->DTTIT))
			aAdd(aTit, cNatureza)
			aAdd(aTit,SA1->A1_COD)
			aAdd(aTit,SA1->A1_LOJA)
			aAdd(aTit,cTipo)
			aAdd(aTit,(cAliasJob)->CODBIL)
			aAdd(aTit,(cAliasJob)->AUT)
			aAdd(aTit,(cAliasJob)->NSU)
			aAdd(aTit,(cAliasJob)->ESTAB)
			aAdd(aTit,alltrim(cDescAdm))
			aAdd(aTit,alltrim(cHistTit))
			aAdd(aTit,(cAliasJob)->FILGZP)
			aAdd(aTit,(cAliasJob)->CODIGO)
			aAdd(aTit,(cAliasJob)->ITEM)

			aRet := GerTit(aTit)
			cRet := aRet[2]

			cFpagto := (cAliasJob)->FPAGTO

			dbSelectArea('GZP')
			GZP->(dbSetOrder(1))
			
			If GZP->(dbSeek((cAliasJob)->FILGZP+(cAliasJob)->CODIGO+(cAliasJob)->CODBIL+(cAliasJob)->ITEM))
			
				Reclock("GZP", .F.)

					If aRet[1]
						GZP->GZP_STAPRO := '1'
						GZP->GZP_TITTEF := cRet
					Else
						GZP->GZP_STAPRO := '2'

					 	If GZP->(FieldPos('GZP_MOTERR')) > 0
							GZP->GZP_MOTERR := cRet
						Endif

					Endif

				GZP->(MsUnlock())

			Endif

		Endif

	ElseIf (cAliasJOB)->STATUS $ 'C|D'

		CANFORSUB((cAliasJob)->FILGZP, (cAliasJob)->CODIGO, (cAliasJob)->CODBIL, (cAliasJob)->ITEM, (cAliasJob)->BILREF)
		
	Endif

	(cAliasJob)->(DbSkip())
End

If Select(cAliasJob) > 0
	(cAliasJob)->(dbCloseArea())
Endif

If !lJob
	Aviso(STR0003, STR0004, {'OK'}, 2)//"Job Títulos Tef "##"Gerado com sucesso"
Endif
	
return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GerTit()

Gera SE1 do bilhete pago com cartão.
 
@sample	GerTit()
 
@return	
 
@author	SIGAGTP | Fernando Amorim(Cafu)
@since		06/01/2018
@version	P12
/*/
Static Function GerTit( aTit)
Local lRet		:= .T. 
Local cRet		:= ''
Local aArray 	:= {}	
Local cTipo 	:= aTit[7]
Local cParcela	:= ''
Local cNum		:= ''
Local nI 		:= 0
Local c1DUP     := SuperGetMv("MV_1DUP")
Local cPath     := GetSrvProfString("Rootpath","")
Local cFile    	:= ""
Local cChvSe1	:= ''
Local cVencto	:= ""
Local cVencReal	:= ""
Local cChaveGZP := ''
Local lGTTITTEF := ExistBlock('GTTITTEF')

Private lMsErroAuto	:= .F.

SE1->(DbSetOrder(1))

For nI := 1 to aTit[1]

	cParcela  := PadR(GTPParcela( nI, c1DUP ), TamSx3('E1_PARCELA')[1])
	cNum 	  := GtpTitNum('SE1', "TEF", cParcela, cTipo)
	cVencto	  := If(aTit[7] ='CD', DaySum(aTit[3],1), MonthSum(aTit[3],nI))
	cVencReal := DataValida(If(aTit[7] ='CD', DaySum(aTit[3],1), MonthSum(aTit[3], nI)))
	cChvSe1	  := xFilial("SE1")+PadR("TEF",TamSx3('E1_PREFIXO')[1]) + cNum + cParcela + PadR(aTit[7] ,TamSx3('E1_TIPO')[1])
	
	If !SE1->(DbSeek(cChvSe1)) 
		// gera titulo no contas a receber
		aArray 	:= {}
		aAdd( aArray,	{ "E1_FILIAL"	, xFilial("SE1") 	, NIL } )
		aAdd( aArray,	{ "E1_PREFIXO"	, "TEF" 			, NIL } )
		aAdd( aArray,	{ "E1_NUM" 		, cNum				, NIL } )
		aAdd( aArray,	{ "E1_TIPO" 	, aTit[7]  			, NIL } )
		aAdd( aArray,	{ "E1_NATUREZ"	, aTit[4] 			, NIL } )
		aAdd( aArray,	{ "E1_CLIENTE" 	, aTit[5]			, NIL } )
		aAdd( aArray,	{ "E1_LOJA"		, aTit[6]			, NIL } )
		aAdd( aArray,	{ "E1_PARCELA" 	, cParcela			, NIL } )
		aAdd( aArray,	{ "E1_EMISSAO"	, aTit[3]			, NIL } )
		aAdd( aArray,	{ "E1_VENCTO"	, cVencto			, NIL } )
		aAdd( aArray,	{ "E1_VENCREA"	, cVencReal			, NIL } )
		aAdd( aArray,	{ "E1_VALOR" 	, (aTit[2]/aTit[1])	, NIL } )
		aAdd( aArray,	{ "E1_HIST"		, aTit[13]			, NIL } )
		aAdd( aArray,	{ "E1_ORIGEM"	, 'GTPJ002' 		, NIL } )
		aAdd( aArray,	{ "E1_NSUTEF"	, aTit[10] 			, NIL } )
		aAdd( aArray,	{ "E1_CARTAUT"	, aTit[9] 			, NIL } )

        If lGTTITTEF
            cChaveGZP := aTit[14]+aTit[15]+aTit[8]+aTit[16]
            aArray := ExecBlock("GTTITTEF",.F.,.F., {aArray, cChaveGZP})
        Endif
								
		lMsErroAuto	:= .F.
		MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 3) // 3-Inclusao,4-Alteração,5-Exclusão
		
		If lMsErroAuto
			lRet := .F.
			cRet += MostraErro(cPath,cFile)
		Else
			lRet := .T.
			cRet := cChvSe1 //STR0006 + SE1->E1_NUM //'Título gerado, numero: '
		Endif
	Else
		lRet := .T.
		cRet := cChvSe1 //STR0006 + SE1->E1_NUM //'Título gerado, numero: '
	Endif

Next nI

Return {lRet,cRet}
	
	
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPParcela()

Devolve a proxima parcela do titulo.
 
@sample	GTPParcela()
 
@return	
 
@author	SIGAGTP | Fernando Amorim(Cafu)
@since		06/01/2018
@version	P12
/*/
*/
Function GTPParcela( uParcela, cTipo )
Local cResult  := ""                    		// Retorno da função
Local iParcela                                  // Numero da parcela
Local nTam 	   := TamSx3( "E1_PARCELA" )[ 1 ]  // Tamanho do campo no SX3
Local cParcela := Space(nTam)                  // Tamanho da variável
Local lSeqParFat := SuperGetMv( "MV_LJPARFA", ,.F.) // verifica se as parcela seguirão sequência do faturamento.
Local nI := 0 //Sequencia

If ValType(uParcela) == "C"
   iParcela := Val( uParcela )
Else   
   iParcela := uParcela
EndIf
   
If cTipo == NIL 
	If !lSeqParFat
   		cTipo := SuperGETMV("MV_1DUP")=="1"  
	Else
		cTipo := "A"
	EndIf
EndIf

If  lSeqParFat .AND. (  "A" $ cTipo .OR. nTam == 1) //Se for sequenciamento do faturamento 
	//Verifica se tipo é alfa ou tamanho é um para chamar a função do faturamento
	   cResult := cTipo
	   
	   If iParcela > 1
	   		
	   		nI := 2  
	   		For nI := 2 to iParcela
	   			cResult :=	MaParcela(cResult)
	   		Next nI
	   EndIf
	   	
Else
	If cTipo == "A" 
		// A..Z
		cResult := Chr(iParcela+64)
	Else 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o tamanho do campo no SX3 for igual 1 , parcela vai de 1...9³
		//³A....Z   e a.....z                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		If nTam == 1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o tamanho do campo no SX3 for igual 1 , parcela vai de 1...9³
				//³A....Z   e a.....z                                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Do Case
				  Case iParcela >= 01 .AND. iParcela <= 09
				  	cResult := AllTrim( Str(iParcela) )
				  Case iParcela >= 10 .AND. iParcela <= 35
				    cResult :=  Chr( iParcela + 55 )
				  Case iParcela >= 36 .AND. iParcela <= 61
				    cResult :=  Chr( iParcela + 61 )
				  Otherwise
				    cResult := "*"
				EndCase
		Else 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Respeita o tamanho do campo para determinar a quantidade de parcelas ³
			//³Exemplo: E1_PARCELA = 2  parcelas de 1 .......99                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        
			//Esta regra se sequenciamento é igual a função MaParcela
	    	cParcela := StrZero(iParcela - 1, nTam)   
			cResult  := Soma1(cParcela, nTam)  
	
		EndIf	

	EndIf

EndIf

cResult := PadR(AllTrim(cResult),nTam)		// Deve-se ajustar o retorno de cParcela ao tamanho do E1_PARCELA
	
Return( cResult )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CANFORSUB()
 Cancela a Forma de pagamento do bilhete substituido
 @sample	CANFORSUB()
 @return	
 @author	SIGAGTP | Fernando Amorim(Cafu)
@since		10/01/2018
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function CANFORSUB(cFilGZP, cCodigo, cCodBil, cItem, cBilRef)
Local lRet			:= .T.
Local cAliasBil	 	:= GetNextAlias()
Local cAliasSE1	 	:= GetNextAlias()
Local cPath     	:= GetSrvProfString("Rootpath","")
Local cFile    		:= ""
Local cRet			:= " "
Local cFilTit		:= ""
Local cPrefixo		:= ""
Local cNumTit		:= ""
Local cTipo			:= ""
Local cTitTef		:= ""

Private lMsErroAuto	:= .F.

BeginSql Alias cAliasBil

	SELECT GZP.GZP_TITTEF
	FROM %Table:GIC% GIC
	INNER JOIN %Table:GZP% GZP 
	ON GZP.GZP_FILIAL = GIC.GIC_FILIAL
	AND GZP.GZP_CODIGO = GIC.GIC_CODIGO
	AND GZP.GZP_CODBIL = GIC.GIC_BILHET
	AND GZP.GZP_ITEM = %Exp:cItem%  
	AND GZP.GZP_STAPRO = '1'
	AND GZP. %NotDel%
	WHERE GIC_FILIAL = %Exp:cFilGZP%
	AND GIC_CODIGO = %Exp:cBilRef%
	AND GIC.GIC_STATUS IN ('E','V')
	AND GIC.%NotDel%
	
EndSql

While (cAliasBil)->(!Eof())

	cTitTef  := (cAliasBil)->GZP_TITTEF

	cFilTit  := Substr(cTitTef, 1, FwSizeFilial())
	cTitTef  := Substr(cTitTef, FwSizeFilial()+1)
	cPrefixo := Substr(cTitTef, 1, TamSx3('E1_PREFIXO')[1]) 
	cTitTef  := Substr(cTitTef, TamSx3('E1_PREFIXO')[1]+1)
	cNumTit  := Substr(cTitTef, 1, TamSx3('E1_NUM')[1])
	cTitTef  := Substr(cTitTef, TamSx3('E1_NUM')[1]+TamSx3('E1_PARCELA')[1]+1)
	cTipo    := Substr(cTitTef, 1, TamSx3('E1_TIPO')[1])

	BeginSql Alias cAliasSE1

		SELECT E1_FILIAL,
			E1_PREFIXO,
			E1_TIPO,
			E1_NUM,
			E1_PARCELA,
			E1_VALOR,
			E1_SALDO
		FROM %Table:SE1%
		WHERE E1_FILIAL = %Exp:cFilTit%
		AND E1_PREFIXO  = %Exp:cPrefixo%
		AND E1_TIPO     = %Exp:cTipo%
		AND E1_NUM      = %Exp:cNumTit%
		AND %NotDel%
		ORDER BY E1_PARCELA

	EndSql

	While (cAliasSE1)->(!Eof())

		SE1->(dbSetOrder(1))

		If SE1->(dbSeek((cAliasSE1)->E1_FILIAL+(cAliasSE1)->E1_PREFIXO+(cAliasSE1)->E1_NUM+(cAliasSE1)->E1_PARCELA+(cAliasSE1)->E1_TIPO))
		   
			If SE1->E1_SALDO == SE1->E1_VALOR	 

				aTitSE1 := {}

				aTitSE1 := {{ "E1_PREFIXO"	, SE1->E1_PREFIXO	, Nil },; //Prefixo 
					{ "E1_NUM"		, SE1->E1_NUM  			    , Nil },; //Numero
					{ "E1_PARCELA"	, SE1->E1_PARCELA		    , Nil },; //Parcela
					{ "E1_TIPO"		, SE1->E1_TIPO			    , Nil },; //Tipo
					{ "E1_NATUREZ"	, SE1->E1_NATUREZ		    , Nil },; //Natureza
					{ "E1_CLIENTE"	, SE1->E1_CLIENTE		    , Nil },; //Cliente
					{ "E1_LOJA"		, SE1->E1_LOJA			    , Nil }} //Loja

				lMsErroAuto	:= .F.
				MsExecAuto( { |x,y| FINA040(x,y)} , aTitSE1, 5)  // Exclui o título
				
				If lMsErroAuto
					lRet := .F.
					cRet += MostraErro(cPath,cFile)
					Exit
				Else
					lRet := .T.
				EndIf

			Endif	

		Endif

		(cAliasSE1)->(dbSkip())
	End

	(cAliasBil)->(dbSkip())

End

(cAliasBil)->(dbCloseArea())
(cAliasSE1)->(dbCloseArea())

dbSelectArea('GZP')
GZP->(dbSetOrder(1))

If GZP->(dbSeek(cFilGZP+cCodigo+cCodBil+cItem))

	Reclock("GZP", .F.)

		If lRet
			GZP->GZP_STAPRO := '1'
		Else
			GZP->GZP_STAPRO := '2'
		Endif

	GZP->(MsUnlock())

Endif

Return
