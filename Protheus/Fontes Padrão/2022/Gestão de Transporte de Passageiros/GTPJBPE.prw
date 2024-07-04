#include 'protheus.ch'
#include 'parmtype.ch'
#include 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "GTPJBPE.CH"

Static aFilRef	:= {}
Static aIcmPad	:= {}
Static aSM0		:=  FwLoadSM0()

Function GTPJBPE(ljob, cTpStatus, cDtini, cDtFim, cAgencia)
Local cAliasJob	 	:= GetNextAlias()
Local cAliasCan	 	:= GetNextAlias()
Local cAliasTro  	:= GetNextAlias()
Local aLog		 	:= ''
Local aItensNF	 	:= {}
Local cProdTar		:= GTPGetRules('PRODTAR')
Local cProdTax		:= GTPGetRules('PRODTAX')
Local cProdPED		:= GTPGetRules('PRODPED')
Local cProSGFACU	:= GTPGetRules('PROSGFACU')
Local cProUtTot		:= GTPGetRules('PROUTTOT')
Local cStaPro       := ''
Local cChvNF		:= ''
Local cBilhete		:= ''
Local lRetExc		:= ''
Local aRegSD2		:= {}
Local aRegSE1		:= {}
Local aRegSE2		:= {}
Local cEstOri		:= ''
Local cEstCal		:= ''
Local cEstDev		:= ''
Local cAgeCan		:= ''
Local cRet			:= STR0001 //'Rotina finalizada com sucesso!!!'
Local cFilOri		:= cFilAnt
Local cTpBil		:= ''
Local dDtVend		:= dDatabase
Local cMunOr		:= ''
Local cMunDe		:= '' 
Local dDtdigit		:= dDataBase
Local cTpLinha		:= ""
Local cMsgErro      := ""
Local cQuery		:= ""
Local cDtIniGNF		:= GTPGetRules("GERNFDTINI", ,'' )	//Data de corte inicial
Local cDtFinGNF		:= GTPGetRules("GERNFDTFIM", ,'' )	//Data de corte Final
Local aAgenGNF		:= GTPGetRules("GERNFAGENC",.T.,,{}) 				//Lista de Agencias para geração da nota
Local cMsgErrLog 	:= ""
Local cSerie		:= ""
Local cNumBil		:= ""
Local aCampos       := {"GZR_UF","GZR_FILREF","GZR_CLIENT","GZR_LOJA"}

Default ljob			:= .F.
Default cTpStatus		:= '0'
Default cAgencia		:= ""

If GTPxVldDic('GZR', aCampos, .T., .T.)
	LoadFilRef()
Endif

If !Empty(cDtIni) .And. !Empty(cDtFim)
	cQuery	+= " AND GIC_DTVEND BETWEEN '" + cDtini + "' AND '" + cDtFim + "' "
ElseIf !Empty(cDtIniGNF) .And. !Empty(cDtFinGNF)
	cQuery	+= " AND GIC_DTVEND BETWEEN '" + cDtIniGNF + "' AND '" + cDtFinGNF + "' "
Endif

If !Empty(cAgencia)

	cQuery += " AND GIC_AGENCI = '" + cAgencia + "' "

ElseIf Len(aAgenGNF) > 0
	If Len(aAgenGNF) == 1
		cQuery	+= " and GIC_AGENCI = '"+aAgenGNF[1]+"' "
	Else
		cQuery	+= " and GIC_AGENCI in ("
		aEval(aAgenGNF,{|x| cQuery+="'"+x+"'," })
		cQuery	:= SubStr(cQuery,1,len(cQuery)-1)
		cQuery	+= ") "
	Endif
Endif

cQuery := "%"+cQuery+"%"

BeginSql Alias cAliasJob

	SELECT GIC.GIC_TIPO,
	       GIC.GIC_DTVEND,
	       GIC.GIC_CHVBPE,
	       GIC.GIC_LINHA,
	       GIC.GIC_TAR,
	       GIC.GIC_TAX,
	       GIC.GIC_PED,
	       GIC.GIC_SGFACU,
	       GIC.GIC_OUTTOT,
	       GIC.GIC_CODIGO,
	       GIC.GIC_BILREF,
	       GIC.GIC_AGENCI,
	       GIC.GIC_STATUS,
	       GIC.R_E_C_N_O_ AS RECGIC,
	       GI6.GI6_FILRES,
	       GI1ORI.GI1_UF AS UFORI,
	       GI1ORI.GI1_CDMUNI AS CDMUNIORI,
	       GI1DES.GI1_UF AS UFDES,
	       GI1DES.GI1_CDMUNI AS CDMUNIDES,
	       CASE WHEN (GIC.GIC_STATUS IN ('V','I')
	                 AND GIC_VALTOT > 0) THEN 1
	           WHEN (GIC.GIC_STATUS IN ('C','D')) THEN 2
	           WHEN (GIC.GIC_STATUS IN ('V')
	                 AND GIC.GIC_VALTOT = 0) THEN 3
	           ELSE 4
	       END ORDEMREG
	FROM %Table:GIC% GIC
	INNER JOIN %Table:GI6% GI6 ON GI6.GI6_FILIAL = %xFilial:GI6%
	AND GI6.GI6_CODIGO = GIC.GIC_AGENCI
	AND GI6.%NotDel%
	INNER JOIN %Table:GI1% GI1ORI ON GI1ORI.GI1_FILIAL = %xFilial:GI1%
	AND GI1ORI.GI1_COD = GIC.GIC_LOCORI
	AND GI1ORI.%NotDel%
	INNER JOIN %Table:GI1% GI1DES ON GI1DES.GI1_FILIAL = %xFilial:GI1%
	AND GI1DES.GI1_COD = GIC.GIC_LOCDES
	AND GI1DES.%NotDel%
	WHERE GIC_FILIAL = %xFilial:GIC%
	  %Exp:cQuery%	
	  AND GIC_STAPRO = '0'
	  AND GIC.GIC_CHVBPE <> ''
	  AND GIC.GIC_CHVSUB = ''
	  AND GIC_STATUS IN ('V','C','D')
	  AND GIC.%NotDel%
	ORDER BY ORDEMREG, GI6.GI6_FILRES, GIC.GIC_CODIGO
				
EndSql

GI2->(DbSetOrder(1))
GQC->(DbSetOrder(1))
GZW->(DbSetOrder(1))
G9O->(DbSetOrder(2)) 

If AliasInDic("H60")
	H60->(DbSetOrder(1))
Endif

(cAliasJob)->(dbGoTop())

While (cAliasJob)->(!Eof())

	GIC->(dbGoto((cAliasJob)->RECGIC))
	
	cMsgErro := ""
	
	If !Empty((cAliasJob)->GI6_FILRES) .AND. cfilAnt <> (cAliasJob)->GI6_FILRES
		cfilAnt := (cAliasJob)->GI6_FILRES
	Endif
	
	cTpBil  	:= (cAliasJob)->GIC_TIPO
	cEstOri 	:= (cAliasJob)->UFORI
	cMunOr 		:= (cAliasJob)->CDMUNIORI
	cEstCal 	:= (cAliasJob)->UFDES
	cMunDe 		:= (cAliasJob)->CDMUNIDES
	dDtVend 	:= STOD((cAliasJob)->GIC_DTVEND)
	cCnpjEmi	:= Substr((cAliasJob)->GIC_CHVBPE,7,14)
	
	cTpLinha := Posicione('GI2',4,xFilial('GI2')+GIC->GIC_LINHA+'2','GI2_TIPLIN') //BUSCA O TIPO DE LINHA PARA VERIFICAR A EXCEÇÃO
	
	If G9O->(DbSeek(xFilial("G9O")+ GIC->GIC_ORIGEM + cTpBil + GIC->GIC_STATUS + cTpLinha)) //Procura primeiramente a chave exata (com o tipo de linha)
		cProdTar	:= G9O->G9O_PRDTAR
		cProdTax	:= G9O->G9O_PRDTAX
		cProdPED	:= G9O->G9O_PRDPED
		cProSGFACU	:= G9O->G9O_PRDSEG
		cProUtTot	:= G9O->G9O_PRDOUT

		If AliasInDic("H60") .And. H60->(dbSeek(xFilial("H60")+G9O->G9O_CODIGO+cEstOri))
			cProdTar	:= H60->H60_PRDTAR
			cProdTax	:= H60->H60_PRDTAX
			cProdPED	:= H60->H60_PRDPED
			cProSGFACU	:= H60->H60_PRDSEG
			cProUtTot	:= H60->H60_PRDOUT
		Endif		

	Elseif G9O->(DbSeek(xFilial("G9O")+ GIC->GIC_ORIGEM + cTpBil + GIC->GIC_STATUS+ Space(TamSx3('G9O_GQCCOD')[1]) ))//Caso não encontrar, procura a chave sem o tipo de linha
		cProdTar	:= G9O->G9O_PRDTAR
		cProdTax	:= G9O->G9O_PRDTAX
		cProdPED	:= G9O->G9O_PRDPED
		cProSGFACU	:= G9O->G9O_PRDSEG
		cProUtTot	:= G9O->G9O_PRDOUT

		If AliasInDic("H60") .And. H60->(dbSeek(xFilial("H60")+G9O->G9O_CODIGO+cEstOri))
			cProdTar	:= H60->H60_PRDTAR
			cProdTax	:= H60->H60_PRDTAX
			cProdPED	:= H60->H60_PRDPED
			cProSGFACU	:= H60->H60_PRDSEG
			cProUtTot	:= H60->H60_PRDOUT
		Endif	
			
	Endif

	If (cAliasJob)->ORDEMREG == 1
		aItensNF	 := {}
		
		If GI2->(DbSeek(xFilial("GI2")+ (cAliasJob)->GIC_LINHA))
			If GQC->(DbSeek(xFilial("GQC")+ GI2->GI2_TIPLIN))
				If GZW->(DbSeek(xFilial("GZW")+ GI2->GI2_TIPLIN + cEstOri))
					If !Empty(GZW->GZW_PROTAR)
						cProdTar  := GZW->GZW_PROTAR
					Endif
				Endif
			Endif
		Endif
				
		If (cAliasJob)->GIC_TAR > 0
			aAdd(aItensNF,{cProdTar,(cAliasJob)->GIC_TAR})
		Endif
		If (cAliasJob)->GIC_TAX > 0
			aAdd(aItensNF,{cProdTax,(cAliasJob)->GIC_TAX})
		Endif
		If (cAliasJob)->GIC_PED > 0
			aAdd(aItensNF,{cProdPED,(cAliasJob)->GIC_PED})
		Endif
		If (cAliasJob)->GIC_SGFACU > 0
			aAdd(aItensNF,{cProSGFACU,(cAliasJob)->GIC_SGFACU})
		Endif
		If (cAliasJob)->GIC_OUTTOT > 0
			aAdd(aItensNF,{cProUtTot,(cAliasJob)->GIC_OUTTOT})
		Endif
		
		If !(VldBilhete(aItensNF))
	
			(cAliasJob)->(dbSkip())
			Loop
	
		Endif
		
		cSerie	:=  AllTrim(Str(Val(Substr(GIC->GIC_CHVBPE,23,3))))
		cNumBil	:=  AllTrim(Str(Val(Substr(GIC->GIC_CHVBPE,26,9))))
	 
		cChvNF := ''
		cChvNF := GerDocNf((cAliasJob)->GIC_AGENCI, aItensNF, cEstOri, cEstCal, cEstDev, aLog, cTpBil, dDtVend, cMunOr, cMunDe, cSerie, cNumBil)	
		
		SF2->(DbSetOrder(1))
		
		If SF2->(DbSeek(xFilial("SF2")+cChvNF)) //nota foi gerado com sucesso
			GrvNfGIC(cChvNF, (cAliasJob)->GIC_CODIGO, cTpBil, 'V', cProdTar, '1')
		Endif
		
	ElseIf (cAliasJob)->ORDEMREG == 2
		
		cBilhete	:= (cAliasJob)->GIC_BILREF	
		cAgeCan		:= (cAliasJob)->GIC_AGENCI	
		
		BeginSQL Alias cAliasCan			
			
			SELECT GIC_NOTA,GIC_SERINF,GIC_CLIENT,GIC_LOJA, GI6_FILRES
			FROM %Table:GIC% GIC
			INNER JOIN %Table:GI6% GI6 ON
				GI6.GI6_FILIAL = GIC.GIC_FILIAL
				AND GI6.GI6_CODIGO = GIC.GIC_AGENCI
				AND GI6.%NotDel% 
			WHERE GIC_FILIAL = %xFilial:GIC%
			AND GIC_CODIGO = %Exp:cBilhete%
			AND ( GIC_STATUS = 'V' )
			AND GIC_STAPRO = '1'
			AND GIC.%NotDel%			
				
		EndSQL
		
		If (cAliasCan)->(!Eof())
		
			If (cAliasCan)->GI6_FILRES <> cFilAnt
			
				cFilAnt := (cAliasCan)->GI6_FILRES
			
			Endif
		
		cChvNF := AllTrim((cAliasCan)->GIC_NOTA + (cAliasCan)->GIC_SERINF + (cAliasCan)->GIC_CLIENT + (cAliasCan)->GIC_LOJA )
		SF2->(DbSetOrder(1))
		If !Empty((cAliasCan)->GIC_NOTA) .AND. SF2->(DbSeek(xFilial("SF2")+ cChvNF))
		//Quando cancelamento, cancela a nota fiscal de saida do bilhete
			If (cAliasJob)->GIC_STATUS == 'C'
				// Exclui a nota
				dDtdigit 	:= IIf(!Empty(SF2->F2_DTDIGIT),SF2->F2_DTDIGIT,SF2->F2_EMISSAO)
				IF dDtDigit >= MVUlmes()
					lRetExc := MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
					If lRetExc
						SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,.F.,.T.,.F.))
						GrvNfGIC(cChvNF, (cAliasJob)->GIC_CODIGO, cTpBil, 'C', cProdTar, '1')
					Endif
						
				EndIf
				Else //Quando Devolução, cria uma nota fiscal de entrada para o bilhete devolvido
					//EXECAUTO DA MATA103 NF ENTRADA DE DEVOLUÇÃO
					cChvNF := ''
					cChvNF := GrvNfDev(cAliasJob, @cMsgErro)	
				
					cStaPro := IIF(Valtype(cChvNF) == 'L' .And. cChvNF == .F., '2', '1')
					cChvNF  := IIF(Valtype(cChvNF) <> 'C', '', cChvNF)
						
					If cStaPro == '1'
						// grava o status e nota na GIC
						GrvNfGIC(cChvNF, (cAliasJob)->GIC_CODIGO, cTpBil, 'D', cProdTar, cStaPro)
					Else
						GrvErro((cAliasJob)->GIC_CODIGO, '2', cMsgErro)
					EndIf
				EndIf
			EndIf
		Endif
		If Select(cAliasCan) > 0
			(cAliasCan)->(dbCloseArea())
		Endif
	ElseIf	(cAliasJob)->ORDEMREG == 3
		
		cMsgErrLog := STR0015 // "Passagem sem valor fiscal"
		GrvErro((cAliasJob)->GIC_CODIGO, '3', cMsgErrLog)
		
	ElseIf (cAliasJob)->ORDEMREG == 4  
		cBilhete	:= (cAliasJob)->GIC_BILREF	
		cAgeCan		:= (cAliasJob)->GIC_AGENCI	
		
		If Empty(cBilhete)
			cMsgErrLog := STR0016 // "Bilhete de Transferência sem bilhete de referência."
			GrvErro((cAliasJob)->GIC_CODIGO, '2', cMsgErrLog)
		Else
			BeginSQL Alias cAliasTro			
				
				SELECT GIC_NOTA,GIC_SERINF,GIC_CLIENT,GIC_LOJA
				FROM %Table:GIC% GIC
				WHERE GIC_FILIAL = %xFilial:GIC%
				AND GIC_BILREF = %Exp:cBilhete%
				AND ( GIC_STATUS = 'C' OR GIC_STATUS = 'D' )
				AND GIC_STAPRO = '1'
				AND %NotDel%			
						
			EndSQL
			If (cAliasTro)->(!Eof())
				aItensNF	 := {}
				If (cAliasJob)->GIC_TAR > 0
					aAdd(aItensNF,{cProdTar,(cAliasJob)->GIC_TAR})
				Endif
				If (cAliasJob)->GIC_TAX > 0
					aAdd(aItensNF,{cProdTax,(cAliasJob)->GIC_TAX})
				Endif
				If (cAliasJob)->GIC_PED > 0
					aAdd(aItensNF,{cProdPED,(cAliasJob)->GIC_PED})
				Endif
				If (cAliasJob)->GIC_SGFACU > 0
					aAdd(aItensNF,{cProSGFACU,(cAliasJob)->GIC_SGFACU})
				Endif
				If (cAliasJob)->GIC_OUTTOT > 0
					aAdd(aItensNF,{cProUtTot,(cAliasJob)->GIC_OUTTOT})
				Endif
				
				cChvNF  := ''
				cChvNF  := GerDocNf((cAliasJob)->GIC_AGENCI, aItensNF, cEstOri, cEstCal, cEstDev, aLog, cTpBil, dDtVend, cMunOr, cMunDe)	
				cStaPro := IIF(Valtype(cChvNF) == 'L' .And. cChvNF == .F., '2', '1')
				cChvNF  := IIF(Valtype(cChvNF) <> 'C', '', cChvNF)
	
				// grava o status e nota na GIC
				GrvNfGIC(cChvNF, (cAliasJob)->GIC_CODIGO, cTpBil, 'V', cProdTar, cStaPro)
			EndIf
		EndIf		
		If Select(cAliasTro) > 0
			(cAliasTro)->(dbCloseArea())
		Endif
		
	Endif		
	
	(cAliasJob)->(DbSkip())
End

If Select(cAliasJob) > 0
	(cAliasJob)->(dbCloseArea())
Endif

If Len(aFilRef) > 0
	GTPDestroy(aFilRef)
Endif

If Len(aSM0) > 0
	GTPDestroy(aSM0)
Endif

If Len(aIcmPad) > 0
	GTPDestroy(aIcmPad)
Endif

If !lJob
	Aviso(STR0002, cRet, {STR0003}, 2)// //"Job Doc Saida bilhetes" //'OK'
	cFilAnt		:= cFilOri
Endif
	
return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GerDocNf()

Gera SF2 e SD2 do bilhete.
 
@sample	GerDocNf()
 
@return	
 
@author	SIGAGTP | Fernando Amorim(Cafu)
@since		15/12/2017
@version	P12
/*/
Static Function GerDocNf(cAgenci, aItensNF, cEstOri, cEstCal, cEstDev, aLog, cTpBil, dDtVend, cMunOr, cMunDe, cSerie, cNumBil)
	Local aCabs      	:= {}
	Local aItens     	:= {}
	Local aStruSF2   	:= {}
	Local aStruSD2   	:= {}
	Local aDocOri		:= {}
	Local cNumero		:= ''
	Local cItem 		:= "00"
	Local nX        	:= 1
	Local nJ 			:= 0
	Local cCond			:= '001'
	Local nF2FILIAL		:= 0
	Local nF2TIPO		:= 0
	Local nF2DOC		:= 0
	Local nF2SERIE		:= 0
	Local nF2EMISSAO	:= 0
	Local nF2CLIENTE	:= 0
	Local nF2LOJA		:= 0
	Local nF2ESPECIE	:= 0
	Local nF2COND		:= 0
	Local nF2DTDIGIT	:= 0
	Local nF2EST		:= 0
	Local nF2VALMERC	:= 0
	Local nF2TIPOCLI	:= 0
	Local nF2MOEDA		:= 0
	Local nD2FILIAL  	:= 0
	Local nD2DOC     	:= 0
	Local nD2SERIE   	:= 0
	Local nD2CLIENTE 	:= 0
	Local nD2LOJA    	:= 0
	Local nD2EMISSAO 	:= 0
	Local nD2TIPO    	:= 0
	Local nD2ITEM    	:= 0
	Local nD2CF      	:= 0
	Local nD2COD     	:= 0
	Local nD2UM      	:= 0
	Local nD2QUANT   	:= 0
	Local nD2PRCVEN  	:= 0
	Local nD2TOTAL   	:= 0
	Local nD2LOCAL   	:= 0
	Local nD2TES     	:= 0
	Local nD2BASEIPI 	:= 0
	Local nD2ALIQIPI 	:= 0
	Local nD2VALIPI  	:= 0
	Local nD2BASEICM 	:= 0
	Local nD2ALIQICM 	:= 0
	Local nD2VALICM  	:= 0
	Local nD2TP			:= 0
	Local nD2CODISS  	:= 0
	Local nD2ESTOQUE 	:= 0
	Local nD2CONTA		:= 0
	Local nD2SITTRIB	:= 0
	Local nD2ESPECIE	:= 0	
	Local cTextoSF2   	:= ""
	Local bFiscalSF2  	:= { || .T. }
	Local cEspecie		:= 'BPE' 
	Local cTipoCli		:= ''
	Local cSitTrib		:= ''
	DEFAULT aLog		:= {}

	//Estrutura do dicionario utilizado pela rotina automatica
	aStruSF2    :=  SF2->(dbStruct())

	//Montagem da capa do documento fiscal
	nF2FILIAL   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_FILIAL"})
	nF2TIPO     := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_TIPO"})
	nF2DOC      := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_DOC"})
	nF2SERIE    := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_SERIE"})
	nF2EMISSAO  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_EMISSAO"})
	nF2CLIENTE  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_CLIENTE"})
	nF2LOJA     := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_LOJA"})
	nF2ESPECIE  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_ESPECIE"})
	nF2COND     := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_COND"})
	nF2DTDIGIT  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_DTDIGIT"})
	nF2EST      := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_EST"})
	nF2VALMERC  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_VALMERC"})
	nF2TIPOCLI	:= Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_TIPOCLI"})
	nF2MOEDA	:= Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_MOEDA"})
	nF2UFORIG	:= Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_UFORIG"})
	nF2UFDEST	:= Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_UFDEST"})
	nF2CMUNOR  	:= Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_CMUNOR"})
	nF2CMUNDE  	:= Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_CMUNDE"})

	For nX := 1 To Len(aStruSF2)
		If aStruSF2[nX][2] $ "C/M"
			Aadd(aCabs,"")
		ElseIf aStruSF2[nX][2] == "N"
			Aadd(aCabs,0)
		ElseIf aStruSF2[nX][2] == "D"
			Aadd(aCabs,CtoD("  /  /  "))
		ElseIf aStruSF2[nX][2] == "L"
			Aadd(aCabs,.F.)
		EndIf
	Next

	aCabs[nF2FILIAL]    	:=  xFilial("SF2")
	aCabs[nF2TIPO]      	:= "N"
	aCabs[nF2DOC]       	:= cNumero
	aCabs[nF2SERIE]     	:= cSerie
	aCabs[nF2EMISSAO]   	:= dDtVend
	aCabs[nF2CLIENTE]   	:= SA1->A1_COD
	aCabs[nF2LOJA]      	:= SA1->A1_LOJA
	aCabs[nF2ESPECIE]   	:= cEspecie
	aCabs[nF2COND]      	:= cCond
	aCabs[nF2DTDIGIT]   	:= dDtVend
	aCabs[nF2EST]      		:= cEstCal
	aCabs[nF2TIPOCLI]	   	:= SA1->A1_TIPO
	aCabs[nF2MOEDA]			:= CriaVar( 'F2_MOEDA' )
	If nF2UFORIG > 0 
		aCabs[nF2UFORIG]     	:= cEstOri
	EndIf
	If nF2UFDEST > 0 
		aCabs[nF2UFDEST]      	:= cEstCal
	EndIf
	If nF2CMUNOR > 0
		aCabs[nF2CMUNOR]     	:= cMunOr
	EndIf
	If nF2CMUNDE > 0 
		aCabs[nF2CMUNDE]      	:= cMunDe
	EndIf
	
	cEstDev					:= SA1->A1_EST
	cTipoCli				:= SA1->A1_TIPO
	
	//Estrutura do dicionario utilizado pela rotina automatica
	aStruSD2    :=  SD2->(dbStruct())

	//Montagem dos itens do documento fiscal
	nD2FILIAL   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_FILIAL"})
	nD2DOC      := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_DOC"	})
	nD2SERIE    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_SERIE"	})
	nD2CLIENTE  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CLIENTE"})
	nD2LOJA     := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_LOJA"	})
	nD2EMISSAO  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_EMISSAO"})
	nD2TIPO     := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TIPO"	})
	nD2ITEM     := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ITEM"	})
	nD2CF       := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CF"		})
	nD2COD      := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_COD"	})
	nD2UM       := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_UM"		})
	nD2QUANT    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_QUANT"	})
	nD2PRUNIT	:= Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_PRUNIT"	})
	nD2PRCVEN   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_PRCVEN"	})
	nD2TOTAL    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TOTAL"	})
	nD2LOCAL    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_LOCAL"	})
	nD2TES      := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TES"	})
	nD2BASEIPI  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_BASEIPI"})
	nD2ALIQIPI  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_IPI"	})
	nD2VALIPI   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_VALIPI"	})
	nD2BASEICM  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_BASEICM"})
	nD2ALIQICM  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_PICM"	})
	nD2VALICM   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_VALICM"	})
	nD2TP		:= Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TP"		})
	nD2CODISS   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CODISS"	})
	nD2ESTOQUE  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ESTOQUE"})
	nD2EST  	:= Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_EST"	})
	nD2CONTA  	:= Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CONTA"	})
	nD2SITTRIB	 := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_SITTRIB"	})
	nD2ESPECIE	 := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ESPECIE"})
	
	
	SF4->( dbSetOrder(1) )
	SB1->( dbSetOrder(1) )
	SBZ->( dbSetOrder(1) )

	For nX := 1 to len( aItensNF )
		aCabs[nF2VALMERC]   += aItensNF[nX][2]

		aAdd(aItens, {})
		AADD(aDocOri,0)

		nPos := Len(aItens)

		For nJ := 1 To Len(aStruSD2)
			If  aStruSD2[nJ][2]$"C/M"
				aAdd(aItens[nPos],"")
			ElseIf aStruSD2[nJ][2]=="D"
				aAdd(aItens[nPos],CToD(""))
			ElseIf aStruSD2[nJ][2]=="N"
				aAdd(aItens[nPos],0)
			ElseIf aStruSD2[nJ][2]=="L"
				aAdd(aItens[nPos],.T.)
			EndIf
		Next

		aItens[Len(aItens),nD2FILIAL]  	:=  xFilial("SF2")
		cItem := Soma1( cItem )
		aItens[Len(aItens),nD2ITEM]    	:=  cItem
		aItens[Len(aItens),nD2DOC]     	:=  cNumero
		aItens[Len(aItens),nD2SERIE]   	:=  cSerie
		aItens[Len(aItens),nD2CLIENTE]	:=  SA1->A1_COD
		aItens[Len(aItens),nD2LOJA]    	:=  SA1->A1_LOJA
		aItens[Len(aItens),nD2EMISSAO] 	:=  dDtVend
		aItens[Len(aItens),nD2TIPO]    	:=  "N"
		aItens[Len(aItens),nD2UM]     	:=  "UN"
		aItens[Len(aItens),nD2QUANT]  	:=  1
		aItens[Len(aItens),nD2PRUNIT] 	:=  aItensNF[nX][2]
		aItens[Len(aItens),nD2PRCVEN] 	:=  aItensNF[nX][2]
		aItens[Len(aItens),nD2TOTAL]  	:=  aItensNF[nX][2]
		aItens[Len(aItens),nD2EST]		:= 	cEstCal
		aItens[Len(aItens),nD2ESPECIE]	:= cEspecie		
		
		SB1->(dbSeek(xFilial("SB1") + aItensNF[nX][1]))
		SF4->(dbSeek(xFilial("SF4") + SB1->B1_TS))

		aItens[Len(aItens),nD2LOCAL]  	:= SB1->B1_LOCPAD
		aItens[Len(aItens),nD2COD]     	:= SB1->B1_COD
		aItens[Len(aItens),nD2TP]     	:= SB1->B1_TIPO
		aItens[Len(aItens),nD2CONTA]   	:= SB1->B1_CONTA

		If !Empty( SB1->B1_CODISS )
			aItens[Len(aItens),ND2CODISS]	:= SB1->B1_CODISS
		ElseIf SBZ->( dbSeek( xFilial("SBZ") + aItensNF[nX][1] ) ) .And. !Empty( SBZ->BZ_CODISS )
			aItens[Len(aItens),ND2CODISS]	:= SBZ->BZ_CODISS
		EndIf

		DbSelectArea( "SB0" )
		SB0->(DbSetOrder(1))
		SB0->(DbSeek(xFilial("SB0")+SB1->B1_COD))
		
		//Executa funções padrões do LOJA para retornar a situação tributária a ser gravada na SD2
		Lj7Strib(@cSitTrib ) 
		Lj7AjustSt(@cSitTrib)

		aItens[Len(aItens),nD2TES]    	:= SF4->F4_CODIGO
		aItens[Len(aItens),nD2CF]		:= SF4->F4_CF
		aItens[Len(aItens),nD2ESTOQUE]	:= SF4->F4_ESTOQUE
		
		aItens[Len(aItens),nD2SITTRIB]	:= cSitTrib

	Next

	cTextoSF2  += 'MaFisAlt( "NF_UFORIGEM", cEstOri, , , , , , .F./*lRecal*/ ),'
	cTextoSF2  += 'MaFisAlt( "NF_UFDEST", cEstCal, , , , , , .F./*lRecal*/ ),'
	cTextoSF2  += 'MaFisAlt( "NF_PNF_UF", cEstDev, , , , , , .F./*lRecal*/),'
	cTextoSF2  += 'MaFisAlt( "NF_ESPECIE", cEspecie, , , , , , .F./*lRecal*/ ),'
	cTextoSF2  += 'MaFisAlt( "NF_PNF_TPCLIFOR", cTipoCli )'

		
	bFiscalSF2 := &( '{||' + cTextoSF2 + '}' )


	cNumero := MaNfs2Nfs(	"",; 		//Serie do Documento de Origem
	"",; 		//Numero do Documento de Origem
	"",; 		//Cliente/Fornecedor do documento do origem
	"",; 		//Loja do Documento de origem
	cSerie,; 	//Serie do Documento a ser gerado
	,;			//Mostra Lct.Contabil (OPC)
	,;			//Aglutina Lct.Contabil (OPC)
	,;			//Contabiliza On-Line (OPC)
	,;			//Contabiliza Custo On-Line (OPC)
	,;			//Reajuste de preco na nota fiscal (OPC)
	,;			//Tipo de Acrescimo Financeiro (OPC)
	,;			//Tipo de Arredondamento (OPC)
	,;			//Atualiza Amarracao Cliente x Produto (OPC)
	.T.,;			//Cupom Fiscal (OPC)
	,;			//CodeBlock de Selecao do SD2 (OPC)
	,;			//CodeBlock a ser executado para o SD2 (OPC)
	,;			//CodeBlock a ser executado para o SF2 (OPC)
	,;			//CodeBlock a ser executado no final da transacao (OPC)
	aDocOri,;	//Array com os Recnos do SF2 (OPC)
	aItens,;	//Array com os itens do SD2 (OPC)
	aCabs,;	//Array com os dados do SF2 (OPC)
	,;		//Calculo Fiscal - Desabilita o calculo fiscal pois as informacoes ja foram passadas nos campos do SD2 e SF2 (OPC)
	bFiscalSF2,;			//code block para tratamento do fiscal - SF2 (OPC)
	,;			//code block para tratamento do fiscal - SD2 (OPC)
	,;			//code block para tratamento do fiscal - SE1 (OPC)
	cNumBil )			//Numero do documento fiscal (OPC)
	
	
Return PadR(cNumero,TamSx3('F2_DOC')[1])+PadR(cSerie,TamSx3('F2_Serie')[1])+SA1->A1_COD+SA1->A1_LOJA


//------------------------------------------------------------------------------
/*/{Protheus.doc} GRVNFGIC

Função que realiza update na tabela GIC com o numero da nf gerada

@sample 	GRVNFGIC

@param		Nenhum

@return   	Nenhum

@author	Fernando Amorim(Cafu)
@since		18/12/2017
@version	P12.1.7
/*/
//------------------------------------------------------------------------------
Static Function GrvNfGIC(cChvNF, cCodGIC, cTpBil, cTp, cProdTar, cStaPro)
Local lRet  	:= .F.
Local aAreaAT	:= GetArea()
Local aAreaD2	:= SD2->(GetArea())
Local aAreaF2	:= SF2->(GetArea())
Local cEspecie	:= 'BPE' 

GIC->(DbSetOrder(1))
If GIC->(DbSeek(xFilial("GIC")+ cCodGIC))

	If cTp == 'V'
		
			Reclock("GIC", .F.)
				GIC->GIC_FILNF	:= IIF(cStaPro == '1', SF2->F2_FILIAL , '') 
				GIC->GIC_NOTA	:= IIF(cStaPro == '1', SF2->F2_DOC    , '')
				GIC->GIC_SERINF	:= IIF(cStaPro == '1', SF2->F2_SERIE  , '')	
				GIC->GIC_CLIENT	:= IIF(cStaPro == '1', SF2->F2_CLIENTE, '')
				GIC->GIC_LOJA	:= IIF(cStaPro == '1', SF2->F2_LOJA   , '')
				GIC->GIC_VLBICM	:= IIF(cStaPro == '1', SF2->F2_BASEICM, 0)
				GIC->GIC_VLICMS	:= IIF(cStaPro == '1', SF2->F2_VALICM , 0)
				GIC->GIC_VLPIS	:= IIF(cStaPro == '1', SF2->F2_VALIMP6, 0)
				GIC->GIC_VLCOF	:= IIF(cStaPro == '1', SF2->F2_VALIMP5, 0)
				GIC->GIC_STAPRO	:= cStaPro
			GIC->(MsUnlock())
			
			Reclock("SF2",.F.)	
				SF2->F2_ESPECIE := cEspecie
				SF2->F2_EMISSAO	:= GIC->GIC_DTVEND
				SF2->F2_CHVNFE	:= GIC->GIC_CHVBPE
				
				SD2->(DbSetOrder(3))
				SB1->(DbSetOrder(1))
				If SD2->(DbSeek(xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) ))
					While !SD2->( EOF() ) .AND. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)
						SB1->( dbSeek( xFilial("SB1") + SD2->D2_COD ) )
						SD2->(RecLock("SD2", .F.))
						SD2->D2_EMISSAO	:= GIC->GIC_DTVEND
						SD2->D2_ESPECIE	:= cEspecie
						
						If SD2->D2_CONTA <> SB1->B1_CONTA
							SD2->D2_CONTA := SB1->B1_CONTA
						Endif
						
						SD2->(MSUNLOCK())
						
						SD2->(DbSkip())
					End
				Endif
					
				SF3->(DbSetOrder(4))
				If SF3->(DbSeek(xFilial("SFT") + SF2->(F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE)))
					While !SF3->( EOF() ) .AND. SF3->(F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE) == xFilial("SF3") + SF2->(F2_CLIENTE + F2_LOJA +  F2_DOC + F2_SERIE )
						SF3->(RecLock("SF3", .F.))
						SF3->F3_ESPECIE := cEspecie
						SF3->F3_EMISSAO	:= GIC->GIC_DTVEND
						SF3->F3_ENTRADA	:= GIC->GIC_DTVEND
						SF3->F3_CHVNFE	:= GIC->GIC_CHVBPE
						
						SF3->(MSUNLOCK())
						SF3->(DbSkip())
					End
				Endif
					
				SFT->(DbSetOrder(1))
				If SFT->(DbSeek(xFilial("SFT") + "S" + SF2->(F2_SERIE + F2_DOC + F2_CLIENTE + F2_LOJA) ))
					While !SFT->( EOF() ) .AND. SFT->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA) == xFilial("SFT") + "S" + SF2->(F2_SERIE + F2_DOC + F2_CLIENTE + F2_LOJA)
						SB1->( dbSeek( xFilial("SB1") + SFT->FT_PRODUTO ) )
						SFT->(RecLock("SFT", .F.))
						SFT->FT_ESPECIE := cEspecie
						SFT->FT_EMISSAO	:= GIC->GIC_DTVEND
						SFT->FT_ENTRADA	:= GIC->GIC_DTVEND
						SFT->FT_CHVNFE	:= GIC->GIC_CHVBPE

						If SFT->FT_CONTA <> SB1->B1_CONTA
							SFT->FT_CONTA := SB1->B1_CONTA
						Endif
						
						SFT->(MSUNLOCK())
						SFT->(DbSkip())
					End
				Endif
				
			SF2->(MsUnlock())	
					
	ElseIf cTp == 'C'
		
		SF2->(DbSetOrder(1))
		If !SF2->(DbSeek(xFilial("SF2") + cChvNF))
			Reclock("GIC", .F.)
				GIC->GIC_STAPRO	:= cStaPro
			GIC->(MsUnlock())
		Endif
		
	ElseIf cTp == "D"
		SF1->(DbSetOrder(1))
		If SF1->(DbSeek(xFilial("SF1")+ cChvNF))			
			Reclock("GIC", .F.)
				GIC->GIC_FILNF	:= SF1->F1_FILIAL
				GIC->GIC_NOTA	:= SF1->F1_DOC
				GIC->GIC_SERINF	:= SF1->F1_SERIE
				GIC->GIC_CLIENT	:= SF1->F1_FORNECE
				GIC->GIC_LOJA	:= SF1->F1_LOJA
				GIC->GIC_VLBICM	:= SF1->F1_BASEICM
				GIC->GIC_VLICMS	:= SF1->F1_VALICM
				GIC->GIC_VLPIS	:= SF1->F1_VALIMP6
				GIC->GIC_VLCOF	:= SF1->F1_VALIMP5
				GIC->GIC_STAPRO	:= cStaPro

				Reclock("SF1",.F.)	
					SF1->F1_EMISSAO		:= GIC->GIC_DTVEND
						
					SD1->(DbSetOrder(1))//D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
					If SD1->(DbSeek(xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA) ))
						While !SD1->( EOF() ) .AND. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)
							SD1->(RecLock("SD1", .F.))
								SD1->D1_EMISSAO	:= GIC->GIC_DTVEND
							SD1->(MSUNLOCK())
								
							If SD1->D1_COD == cProdTar 
								GIC->GIC_ALICMS := SD1->D1_PICM
							Endif
								
							SD1->(DbSkip())
						End
					Endif
						
					SF3->(DbSetOrder(4))
					If SF3->(DbSeek(xFilial("SFT") + SF1->(F1_FORNECE+F1_LOJA+F1_DOC+F1_SERIE)))
						While !SF3->( EOF() ) .AND. SF3->(F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE) == xFilial("SF3") + SF1->(F1_FORNECE+F1_LOJA+F1_DOC+F1_SERIE)
							SF3->(RecLock("SF3", .F.))
								SF3->F3_ESPECIE := cEspecie
								SF3->F3_EMISSAO	:= GIC->GIC_DTVEND
								SF3->F3_ENTRADA	:= GIC->GIC_DTVEND
							SF3->(MSUNLOCK())
							SF3->(DbSkip())
						End
					Endif
						
					SFT->(DbSetOrder(1))
					If SFT->(DbSeek(xFilial("SFT") + "E" + SF1->(F1_SERIE + F1_DOC + F1_FORNECE + F1_LOJA) ))
						While !SFT->( EOF() ) .AND. SFT->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA) == xFilial("SFT") + "E" + SF1->(F1_SERIE + F1_DOC + F1_FORNECE + F1_LOJA)
							SFT->(RecLock("SFT", .F.))
								SFT->FT_ESPECIE := cEspecie
								SFT->FT_EMISSAO	:= GIC->GIC_DTVEND
								SFT->FT_ENTRADA	:= GIC->GIC_DTVEND
							SFT->(MSUNLOCK())
							SFT->(DbSkip())
						End
					Endif
				SF1->(MsUnlock())	
			GIC->(MsUnlock())
		Else
			GrvErro(cCodGIC, '2', STR0004) // 'Erro na geração da nota de entrada'
		Endif
	Endif
EndIf

RestArea(aAreaAT)	
RestArea(aAreaD2)
RestArea(aAreaF2)

Return lRet

/*/{Protheus.doc} GrvNfDev
Função responsavel para gravação da Nota Fiscal de Entrada de tipo Devolução
@type function
@author jacomo.fernandes
@since 19/09/2018
@version 1.0
@param cAliasJob, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GrvNfDev(cAliasJob, cMsgErro, lAut)
Local aCab		:= {}
Local aItens	:= {}
Local aItem		:= {}
Local cChvRet	:= ""	
Local cEspecie  :=  "BPE"
Local nX        := 0	
Local cSerie	:= GTPGetRules('GERNFSERDV') 
Local cNota 	:= "" //NxtSX5Nota( cSerie ) //SEQUENCIAL DA NOTA FISCAL

Default lAut := .F.
Private lAutoErrNoFile := .T.
Private lMsErroAuto	:= .F.
	
//Variaveis do Cabecalho da Nota
aAdd(aCab,{"F1_TIPO"     	,'D'      						,NIL})
aAdd(aCab,{"F1_FORMUL"    	,"S"  							,NIL})
aAdd(aCab,{"F1_DOC"   	 	,cNota  						,NIL})
aAdd(aCab,{"F1_SERIE"    	,cSerie   						,NIL})
aAdd(aCab,{"F1_EMISSAO"    	,iif(!lAut, StoD((cAliasJob)->GIC_DTVEND), StoD(''))	,NIL})
aAdd(aCab,{"F1_FORNECE"    	,SF2->F2_CLIENTE				,NIL})
aAdd(aCab,{"F1_LOJA"       	,SF2->F2_LOJA					,NIL})
aAdd(aCab,{"F1_ESPECIE"    	,cEspecie						,NIL})

DbSelectArea('SD2')
SD2->(DbSetOrder(3)) // D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, R_E_C_N_O_, D_E_L_E_T_

SA1->(dbSetOrder(1))

If SA1->( dbSeek( xFilial( "SA1" ) + SF2->F2_CLIENTE + SF2->F2_LOJA ) )

	If !(RegistroOk('SA1'))
		// Static msg 
		cMsgErro := STR0005 + SF2->F2_CLIENTE + "/" + SF2->F2_LOJA + STR0006  // "Cliente ", "inativo" 
		Return .F.

	Endif
	
EndIf

If SD2->(DbSeek( SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) ))
	While SD2->(!EOF()) .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
		
		aItem := {}
		aAdd(aItem,{"D1_ITEM"  		,StrZero(Val(SD2->D2_ITEM),TamSx3('D1_ITEM')[1])			,NIL})
		aAdd(aItem,{"D1_COD"   		,AllTrim(SD2->D2_COD)										,NIL})
		aAdd(aItem,{"D1_UM"   		,SD2->D2_UM													,NIL})
		aAdd(aItem,{"D1_QUANT"   	,SD2->D2_QUANT 												,NIL})
		aAdd(aItem,{"D1_VUNIT"  	,SD2->D2_PRCVEN												,NIL})
		aAdd(aItem,{"D1_TOTAL"  	,SD2->D2_TOTAL												,NIL})
		aAdd(aItem,{"D1_TES"  		,Posicione('SF4',1,xFilial('SF4')+SD2->D2_TES,'F4_TESDV')	,NIL})
		aAdd(aItem,{"D1_FORNECE" 	,SF2->F2_CLIENTE											,NIL})
		aAdd(aItem,{"D1_LOJA"  		,SF2->F2_LOJA												,NIL})
		aAdd(aItem,{"D1_LOCAL"  	,SD2->D2_LOCAL												,NIL})
		aAdd(aItem,{"D1_EMISSAO"	,iif(!lAut, StoD((cAliasJob)->GIC_DTVEND), StoD(''))		,NIL})
		aAdd(aItem,{"D1_DTDIGIT" 	,iif(!lAut, StoD((cAliasJob)->GIC_DTVEND), StoD(''))		,NIL})
		aAdd(aItem,{"D1_GRUPO"   	,SD2->D2_GRUPO												,NIL})
		aAdd(aItem,{"D1_TIPO"  		,"D"														,NIL})
		aAdd(aItem,{"D1_NFORI"		,SF2->F2_DOC												,NIL})
		aAdd(aItem,{"D1_SERIORI"	,SF2->F2_SERIE    											,NIL})
		aAdd(aItem,{"D1_ITEMORI"	,SD2->D2_ITEM	    										,NIL})
					
		AAdd( aItens, aItem )
			
		SD2->(DbSkip())
	End
EndIf

lMsErroAuto := .F.
MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItens,3)

If !lMsErroAuto
	cChvRet	:= PadR(SF1->F1_DOC,TamSx3('F1_DOC')[1])+PadR(cSerie,TamSx3('F1_SERIE')[1])+SA1->A1_COD+SA1->A1_LOJA
Else
	cMsgErro := STR0007  + CHR(13)+CHR(10) // "Falha ao gerar NF de Devolução... "
	aLog := GetAutoGRLog()
	For nX := 1 To Len(aLog)
		cMsgErro += aLog[nX]+CHR(13)+CHR(10)			
	Next nX
	Return .F.	
EndIf

Return cChvRet

/*/{Protheus.doc} GrvErro
Função para gravaçao do erro na tabela GIC
@type function
@author Flavio Martins	
@since 19/04/2019
@version 1.0
@param
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GrvErro(cCodGIC, cStatus, cMsgErrLog)
Local aAreaGIC	:= GIC->(GetArea())

	GIC->(DbSetOrder(1))

	If GIC->(DbSeek(xFilial("GIC")+ cCodGIC))

		Reclock("GIC", .F.)
		
		GIC->GIC_STAPRO	:= cStatus
		GIC->GIC_MOTIVO	:= cMsgErrLog
		GIC->GIC_DTERRO	:= dDataBase
		
		GIC->(MsUnlock())
		
	Endif

	RestArea(aAreaGIC)

Return .T.

/*/{Protheus.doc} VldBilhete()
Função para validação do bilhete
@type function
@author Flavio Martins	
@since 12/08/2019
@version 1.0
@param
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldBilhete(aItensNF)
Local lRet 		:= .T.
Local cAliasGIC	:= GetNextAlias()
Local cStatus	:= GIC->GIC_STATUS
Local cBilRef	:= GIC->GIC_BILREF
Local cAgencia	:= GIC->GIC_AGENCI
Local cCnpjEmi	:= Substr(GIC->GIC_CHVBPE,7,14)
Local cNumBil	:= AllTrim(Str(Val(Substr(GIC->GIC_CHVBPE,26,9))))
Local cSerie	:= AllTrim(Str(Val(Substr(GIC->GIC_CHVBPE,23,3))))
Local cMsg		:= ""
Local cCliente	:= ""
Local cLoja		:= ""
Local cFilOri	:= cFilAnt
Local nX		:= 0
Local nP 		:= 0 
Local nIcmPad	:= 0

	nP :=  aScan(aSM0,{|x| x[1] == cEmpAnt .And. x[2] == cFilAnt})
	
	If aSM0[nP][18] <> cCnpjEmi

		If Len(aFilRef) > 0 .And. (nP := aScan(aFilRef,{|x| x[6] == cCnpjEmi})) > 0
			cFilAnt  := aFilRef[nP][3]
			cCliente := aFilRef[nP][4]
			cLoja	 := aFilRef[nP][5]
		Else
			cMsg := STR0018 + cCnpjEmi + STR0019 // "CNPJ: " " do emitente do BP-e não encontrado nas filiais"
			lRet := .F.
		Endif
		
	Endif

	If lRet

		nP := aScan(aIcmPad,{|x| x[1] == cFilAnt})

		If nP > 0 
			nIcmPad := aIcmPad[nP][2]
		Else
			nIcmPad	:= SuperGetMv("MV_ICMPAD",.F.,0, cFilAnt)	
			Aadd(aIcmPad, {cFilAnt, nIcmPad})
		Endif
		
		If nIcmPad == 0
			cMsg := STR0020 + cFilAnt // "Parâmetro MV_ICMPAD não cadastrado para a filial " 
			lRet := .F.
		Endif

	Endif
	
	If lRet 

		If Empty(cCliente)
			
			GI6->(DbSetOrder(1))
			GI6->(dbSeek(xFilial("GI6")+cAgencia))
			cCliente := GI6->GI6_CLIBIL
			cLoja	 := GI6->GI6_LJBIL

		Endif

		SA1->(dbSetOrder(1))
		
		If !SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))
			cMsg := STR0008  // "Cliente/Loja não existente na base"
			lRet := .F.
		ElseIf !(RegistroOk('SA1',.F.))	
			cMsg := STR0005 + cCliente + "/" + cLoja + STR0006  // "Cliente ", " inativo"
			lRet := .F.
		EndIf
		
		If lRet .And. cStatus $ 'C|D' .And. Empty(cBilRef)
			cMsg := STR0009 // "Devolução/Cancelamento sem bilhete de referência"
			lRet := .F.
		Endif

	Endif
	
	If lRet .And. cStatus $ 'C|D' .And. !(Empty(cBilRef))
	
		BeginSql Alias cAliasGIC
		
			SELECT GIC_STAPRO FROM %Table:GIC% GIC
			WHERE
			GIC.GIC_FILIAL = xFilial('GIC')
			AND GIC.GIC_CODIGO = %Exp:cBilRef%
			AND GIC.%NotDel%
			
		EndSql
		
		If (cAliasGIC)-(!Eof())
		
			If (cAliasGIC)->GIC_STAPRO == '0'
				cMsg := STR0010 // "Bilhete de referência não faturado"
				lRet := .F.
			ElseIf (cAliasGIC)->GIC_STAPRO == '2'
				cMsg := STR0011 // "Bilhete de referência com erro de faturamento"
				lRet := .F.
			Endif
		
		Else
			cMsg := STR0012 // "Bilhete de referência não encontrado"
			lRet := .F.
		Endif
		
	Endif
	
	If lRet
	
		SF4->( dbSetOrder(1))
		SB1->( dbSetOrder(1))
		
		For nX := 1 To Len(aItensNF)
		
			SB1->(dbSeek(xFilial("SB1") + aItensNF[nX][1]))
			
			If Empty(SB1->B1_TS) .Or. !(SF4->( dbSeek( xFilial("SF4") + SB1->B1_TS)))	
				cMsg := STR0013 // "Error: TES de Saida padrao não preenchido ou Tipo de saida "
				lRet := .F.
				Exit
			Endif

		Next
	
	Endif
	
	If lRet
	
		SF2->(DbSetOrder(1))

		If SF2->(DbSeek(xFilial("SF2")+ PadR(cNumBil,TamSx3('F2_DOC')[1])+PadR(cSerie,TamSx3('F2_Serie')[1])+SA1->A1_COD+SA1->A1_LOJA))
			If !(SF2->F2_ESPECIE == 'CTE')
				cMsg := STR0014 // "Nota já foi gerada para este bilhete"
				lRet := .F.
			EndIf
		EndIf
				
	Endif
	
	
	If !(lRet)
		cFilAnt	:= cFilOri
		GrvErro(GIC->GIC_CODIGO, '2', cMsg)
	Endif

	If Select(cAliasGIC) > 0
		(cAliasGIC)->(dbCloseArea())
	Endif
	
Return lRet

/*/{Protheus.doc} LoadFilRef()
Função carregar as filiais de referencia por UF
@type function
@author Flavio Martins	
@since 17/02/2020
@version 1.0
@param
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function LoadFilRef()
Local cAliasGZR	:= GetNextAlias()
Local nPos		:= 0

BeginSql Alias cAliasGZR

	SELECT  GZR_FILIAL,
			GZR_UF, 
			GZR_FILREF, 
			GZR_CLIENT, 
			GZR_LOJA
	FROM %Table:GZR% GZR
	WHERE
	GZR_FILIAL = %xFilial:GZR% 
	AND GZR.%NotDel%

EndSql

While (cAliasGZR)->(!Eof())

	nPos :=  aScan(aSM0,{|x| x[1] == cEmpAnt .And. x[2] == (cAliasGZR)->GZR_FILREF})

	Aadd(aFilRef, 	{;
						(cAliasGZR)->GZR_FILIAL,;
						(cAliasGZR)->GZR_UF,;
						(cAliasGZR)->GZR_FILREF,;
						(cAliasGZR)->GZR_CLIENT,;
						(cAliasGZR)->GZR_LOJA,;
						aSM0[nPos][18];
					};
		)

	(cAliasGZR)->(dbSkip())

End

If Select(cAliasGZR) > 0
	(cAliasGZR)->(dbCloseArea())
Endif

Return

