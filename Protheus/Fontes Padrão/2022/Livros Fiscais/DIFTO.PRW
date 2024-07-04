#include "protheus.ch"

Static cIE      := AllTrim(SM0->M0_INSC)
Static cCodMun  := Iif(Len(Alltrim(SM0->M0_CODMUN)) < 7,UfCodIBGE(SM0->M0_ESTENT)+SM0->M0_CODMUN, SM0->M0_CODMUN)
Static lSimpNac := GetNewPar("MV_SIMPLES","") == "S"
Static aNClass  := {}


Function DIFTOGera(Periodo, GerarSegG, aWizard)

Local lMovEnt := DIFTOENT(Periodo, GerarSegG, aWizard[3])
Local lMovSai := DIFTOSAI(Periodo, GerarSegG, aWizard[4])

If !lMovEnt .And. !lMovSai
	// Segmento C - Entradas de Mercadorias ou Servicos no Estabelecimento do Contribuinte		
	RecLock("SegmentoC", .T.)
	SegmentoC->IE			:= cIE
	SegmentoC->Periodo	:= Periodo 
	SegmentoC->TpEntrada := "00"
	SegmentoC->DomiFiscal:= "A"
	SegmentoC->CodMuni   := cCodMun
	SegmentoC->ValContab	:= 0
	SegmentoC->ValBC		:= 0
	SegmentoC->ValIsenNT	:= 0		
	SegmentoC->ValSubst  := 0
	SegmentoC->(MsUnlock())
	// Segmento E - Saidas de Mercadorias ou Servicos do Est. do Contribuinte
	RecLock("SegmentoE", .T.)
	SegmentoE->IE        := cIe
	SegmentoE->Periodo   := Periodo
	SegmentoE->TpSaida   := "00"
	SegmentoE->DomiFiscal:= "A"
	SegmentoE->CodMuni   := cCodMun
	SegmentoE->ValContab	:= 0
	SegmentoE->ValBC		:= 0
	SegmentoE->ValIsenNT	:= 0
	SegmentoE->ValSubst	:= 0
	SegmentoE->(MsUnlock())	
Endif
		
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DIFTOENT บ Autor ณ Joใo Victor        บ Data ณ  27/12/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera os segmentos referentes as movimentacoes de entrada   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Function DIFTOENT(Periodo, GerarSegG, aWizard)

Local cAliasEnt	:= "SF3"	
Local cTipoEnt	:= ""
Local lComMov		:= .F.

Default GerarSegG := .F.

#IFDEF TOP
If (TcSrvType() <> "AS/400")

	cAliasEnt := GetNextAlias()
	
	BeginSql Alias cAliasEnt                                     
		Select
			SF3.F3_CFO         	CFOP,
			SF3.F3_ESTADO      	UF,		
			SF3.F3_TIPO         	Tipo,
			SA2.A2_COD_MUN     	Municipio,
			SA1.A1_COD_MUN     	Muncliente,  
			SUM(SF3.F3_VALCONT) ValorContabil,
			SUM(SF3.F3_BASEICM) BaseCalculo,
			SUM(SF3.F3_ISENICM) Isentas,
			SUM(SF3.F3_ICMSRET) Substituicao,
			SUM(SF3.F3_OUTRICM) Outros    
			FROM %table:SF3% SF3
			LEFT JOIN %table:SA2% SA2 ON SA2.A2_FILIAL     = %xFilial:SA2% 		                      
				AND SF3.F3_CLIEFOR = SA2.A2_COD
				AND SF3.F3_LOJA    = SA2.A2_LOJA
				AND SA2.%NotDel% 
			LEFT JOIN %table:SA1% SA1 ON SA1.A1_FILIAL = %xFilial:SA1%			                      
			    AND SF3.F3_CLIEFOR = SA1.A1_COD
			    AND SF3.F3_LOJA = SA1.A1_LOJA
			    AND SA1.%NotDel%                        
			WHERE
				SF3.F3_FILIAL = %xFilial:SF3% AND
				SF3.%NotDel% AND
				SF3.F3_ENTRADA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND
				SF3.F3_DTCANC = ' ' AND
				SF3.F3_CFO < '5' AND
				SF3.F3_TIPO <> 'S'
			GROUP BY
				SF3.F3_CFO, SF3.F3_ESTADO, SF3.F3_TIPO, SA2.A2_COD_MUN,SA1.A1_COD_MUN  				
	EndSql
EndIf
#ENDIF

lComMov := !(cAliasEnt)->(EOF()) //Verifica se tem movimento

While !(cAliasEnt)->(EOF())
	
	cTipoEnt := TipoEntSai((cAliasEnt)->CFOP, "E", aWizard) 
		
	// Segmento C - Entradas de Mercadorias ou Servicos no Estabelecimento do Contribuinte		
	SegmentoC(cAliasEnt, Periodo, cTipoEnt)
	
	If cTipoEnt == "11"
		// Segmento K - Outras Entradas / Saidas
		SegmentoK("E", Periodo, (cAliasEnt)->CFOP, (cAliasEnt)->ValorContabil, (cAliasEnt)->BaseCalculo, (cAliasEnt)->Outros, (cAliasEnt)->Substituicao)
	EndIf	
		
	// Segmento D - Entradas de Mercadorias ou Servicos Detalhadas por UF.
	SegmentoD(cAliasEnt, Periodo, Cod_Estado((cAliasEnt)->UF), cTipoEnt, (cAliasEnt)->CFOP)
	
	If GerarSegG .And. cTipoEnt $ "01/02/03/07/08/09/10"
		// Segmento G - Entradas ou Saํdas de mercadorias / servicos detalhado por municipio
		SegmentoG(Periodo, (cAliasEnt)->UF, IIf((cAliasEnt)->Tipo =="D",(cAliasEnt)->Muncliente,(cAliasEnt)->Municipio), "E", (cAliasEnt)->ValorContabil)
	EndIf
	
	(cAliasEnt)->(dbSkip())	
EndDo 

// Segmento H - Relacao de Mercadorias adquiridas de outros municipios com Isencao do ICMS.
// Segmento I - Relacao de Mercadorias adquiridas de outros municipios com Isencao do ICMS det. por IE.
SegmentoHI(Periodo)

SegmentoC->(dbGoTop())
SegmentoD->(dbGoTop())
SegmentoG->(dbGoTop())
SegmentoH->(dbGoTop())
SegmentoI->(dbGoTop())
SegmentoK->(dbGoTop())

Return lComMov

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DIFTOSAI บ Autor ณ Joใo Victor        บ Data ณ  27/12/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera os segmentos referentes as movimentacoes de saida     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Function DIFTOSAI(Periodo, GerarSegG, aWizard)

Local cAliasSai	:= "SF3"
Local cTipoSai	:= ""
Local lComMov		:= .F.

Default GerarSegG := .F.

#IFDEF TOP
If (TcSrvType() <> "AS/400")

	cAliasSai := GetNextAlias()

	BeginSql Alias cAliasSai                                     
		Select
			SF3.F3_CFO         	CFOP,
			SF3.F3_ESTADO      	UF,
			SF3.F3_TIPO         Tipo,
			SA2.A2_COD_MUN     	Municipio,
			SA1.A1_COD_MUN     	Muncliente,  
			SUM(SF3.F3_VALCONT) ValorContabil,
			SUM(SF3.F3_BASEICM) BaseCalculo,
			SUM(SF3.F3_ISENICM) Isentas,
			SUM(SF3.F3_ICMSRET) Substituicao,
			SUM(SF3.F3_OUTRICM) Outros,    
			SUM(SF3.F3_ICMSDIF) Diferimento
			FROM %table:SF3% SF3
			LEFT JOIN %table:SA1% SA1 ON SA1.A1_FILIAL = %xFilial:SA1%
			                      AND SF3.F3_CLIEFOR = SA1.A1_COD
			                      AND SF3.F3_LOJA = SA1.A1_LOJA
			                      AND SA1.%NotDel%  
			LEFT JOIN %table:SA2% SA2 ON SA2.A2_FILIAL = %xFilial:SA2%
			                      AND SF3.F3_CLIEFOR = SA2.A2_COD
			                      AND SF3.F3_LOJA = SA2.A2_LOJA
			                      AND SA2.%NotDel%   
			WHERE
				SF3.F3_FILIAL = %xFilial:SF3% AND
				SF3.%NotDel% AND
				SF3.F3_ENTRADA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND
				SF3.F3_DTCANC = ' ' AND
				SF3.F3_CFO > '4' AND
				SF3.F3_TIPO <> 'S'
			GROUP BY
				SF3.F3_CFO, SF3.F3_ESTADO, SF3.F3_TIPO, SA2.A2_COD_MUN,SA1.A1_COD_MUN  		
	EndSql
EndIf
#ENDIF

lComMov := !(cAliasSai)->(EOF()) //Verifica se tem movimento

While !(cAliasSai)->(EOF())
		
	cTipoSai := TipoEntSai((cAliasSai)->CFOP, "S", aWizard)
	
	// Segmento E - Saidas de Mercadorias ou Servicos do Est. do Contribuinte
	SegmentoE(cAliasSai, Periodo, cTipoSai, (cAliasSai)->CFOP)	
		
	If cTipoSai == "10"
		// Segmento K - Outras Entradas / Saidas
		SegmentoK("S", Periodo, (cAliasSai)->CFOP, (cAliasSai)->ValorContabil, (cAliasSai)->BaseCalculo, (cAliasSai)->Outros, (cAliasSai)->Substituicao)
	EndIf
	
	// Segmento F - Saidas de Mercadorias ou Servicos detalhado por UF.
	SegmentoF(cAliasSai, Periodo, Cod_Estado((cAliasSai)->UF), (cAliasSai)->CFOP)
	
	If GerarSegG .And. cTipoSai $ "01/02/03/04/05/06/07/08/09"
		// Segmento G - Entradas ou Saํdas de mercadorias / servicos detalhado por municipio
		SegmentoG(Periodo, (cAliasSai)->UF, IIf((cAliasSai)->Tipo =="D",(cAliasSai)->Municipio,(cAliasSai)->Muncliente), "S", (cAliasSai)->ValorContabil)
	EndIf

	(cAliasSai)->(dbSkip())
EndDo

SegmentoE->(dbGoTop())
SegmentoF->(dbGoTop())
SegmentoK->(dbGoTop())
SegmentoG->(dbGoTop())

Return lComMov

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SegmentoC บ Autor ณ Joใo Victor       บ Data ณ  27/12/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Alimenta o arquivo de trabalho do Segmento C:              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Entradas de Mercadorias ou Servicos no Estabelecimento do  บฑฑ
ฑฑบ          ณ Contribuinte.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Static Function SegmentoC(cAliasEnt, Periodo, TpEnt)
		
If !SegmentoC->(dbSeek(cIE+Periodo+TpEnt, .F.))
	RecLock("SegmentoC", .T.)	
		
	SegmentoC->IE		  := cIE
	SegmentoC->Periodo	  := Periodo 
	SegmentoC->TpEntrada  := TpEnt
	SegmentoC->DomiFiscal := "A"
	SegmentoC->CodMuni    := cCodMun
Else
	RecLock("SegmentoC", .F.)
EndIf

SegmentoC->ValContab += (cAliasEnt)->ValorContabil
SegmentoC->ValBC     += Iif(!lSimpNac, (cAliasEnt)->BaseCalculo, 0)
SegmentoC->ValIsenNT += Iif(!lSimpNac .Or. lSimpNac .And. TpEnt == "07", (cAliasEnt)->Isentas + (cAliasEnt)->Outros, 0)		
SegmentoC->ValSubst  += (cAliasEnt)->Substituicao

SegmentoC->(MsUnlock())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SegmentoD บ Autor ณ Joใo Victor       บ Data ณ  27/12/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Alimenta o arquivo de trabalho do Segmento D:              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Entradas de Mercadorias ou Servicos Detalhadas por UF.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Static Function SegmentoD(cAliasEnt, Periodo, CodEstado, TpEnt, CFOP)

Local cPetrEnerg := "251/252/253/254/255/256/257"
Local cCFOPRed  := AllTrim(SubStr(CFOP, 2, 3))
	
If !SegmentoD->(dbSeek(cIE+Periodo+CodEstado, .F.))
	RecLock("SegmentoD", .T.)
	
	SegmentoD->IE 		  := cIE
	SegmentoD->Periodo 	  := Periodo
	SegmentoD->UF 		  := CodEstado
	SegmentoD->DomiFiscal := "A"
	SegmentoD->CodMuni    := cCodMun
Else
	RecLock("SegmentoD", .F.)
EndIf

SegmentoD->ValContab  += (cAliasEnt)->ValorContabil
SegmentoD->ValBC      += Iif(!lSimpNac, (cAliasEnt)->BaseCalculo, 0)
SegmentoD->ValIsenNT  += Iif((!lSimpNac) .Or. (lSimpNac .And. TpEnt == "07"), (cAliasEnt)->Isentas + (cAliasEnt)->Outros, 0)

If cCFOPRed $ cPetrEnerg		
	SegmentoD->ValEnergia += (cAliasEnt)->Substituicao
Else
	SegmentoD->ValOutros  += (cAliasEnt)->Substituicao
EndIf

SegmentoD->ValSubst += (cAliasEnt)->Substituicao

SegmentoD->(MsUnlock())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SegmentoE บ Autor ณ Joใo Victor       บ Data ณ  27/12/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Alimenta o arquivo de trabalho do Segmento E:              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Saidas de Mercadorias ou Servicos do Est. do Contribuinte. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Static Function SegmentoE(cAliasSai, Periodo, TpSai, CFOP)	

If !SegmentoE->(dbSeek(cIE+Periodo+TpSai, .F.))
	RecLock("SegmentoE", .T.)
	
	SegmentoE->IE         := cIe
	SegmentoE->Periodo    := Periodo
	SegmentoE->TpSaida    := TpSai
	SegmentoE->DomiFiscal := "A"
	SegmentoE->CodMuni    := cCodMun
Else
	RecLock("SegmentoE", .F.)
EndIf

SegmentoE->ValContab += (cAliasSai)->ValorContabil
SegmentoE->ValBC     += Iif(!lSimpNac, (cAliasSai)->BaseCalculo, 0)
SegmentoE->ValIsenNT += Iif(!lSimpNac, (cAliasSai)->Isentas + (cAliasSai)->Outros, 0)
SegmentoE->ValSubst  += (cAliasSai)->Substituicao

SegmentoE->(MsUnlock())	

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SegmentoF บ Autor ณ Joใo Victor       บ Data ณ  27/12/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Alimenta o arquivo de trabalho do Segmento F:              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Saidas de Mercadorias ou Servicos detalhado por UF.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Static Function SegmentoF(cAliasSai, Periodo,CodEstado, CFOP)

Local lContrib  := !AllTrim(SubStr(CFOP, 2, 3)) $ "107/108/258/307/357"  

If !SegmentoF->(dbSeek(cIE+Periodo+CodEstado, .F.))
	RecLock("SegmentoF", .T.)
	
	SegmentoF->IE         := cIE
	SegmentoF->Periodo    := Periodo
	SegmentoF->UF         := CodEstado
	SegmentoF->DomiFiscal := "A"
	SegmentoF->CodMuni    := cCodMun
Else
	RecLock("SegmentoF", .F.)
EndIf

SegmentoF->ValContab  += Iif(lContrib, (cAliasSai)->ValorContabil, 0) 
SegmentoF->ValContbNC += Iif(!lContrib, (cAliasSai)->ValorContabil, 0)
SegmentoF->ValBC      += Iif(!lSimpNac .And. lContrib, (cAliasSai)->BaseCalculo, 0)
SegmentoF->ValBCNaoCt += Iif(!lSimpNac .And. !lContrib, (cAliasSai)->BaseCalculo, 0)
SegmentoF->ValIsenNT  += Iif(!lSimpNac, (cAliasSai)->Isentas + (cAliasSai)->Outros, 0)
SegmentoF->ValSubst   += (cAliasSai)->Substituicao
SegmentoF->ICMSST     += (cAliasSai)->Substituicao

SegmentoF->(MsUnlock())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SegmentoG บ Autor ณ Joใo Victor       บ Data ณ  27/12/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Alimenta o arquivo de trabalho do Segmento G:              บฑฑ  
ฑฑบ          ณ																    บฑฑ
ฑฑบ          ณ Entradas ou Saํdas de mercadorias / servicos               บฑฑ
ฑฑบ          ณ detalhado por municipio.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Static Function SegmentoG(Periodo, UF, MunOrigem, TpMov, Valor)

Local cMunOrigem := IIf(UF == "TO", Iif(Len(AllTrim(MunOrigem))<=5,UfCodIbge(UF)+MunOrigem, MunOrigem), "9999999")

If !SegmentoG->(dbSeek(cIE+Periodo+cMunOrigem, .F.))
	RecLock("SegmentoG", .T.)
	
	SegmentoG->IE         := cIe
	SegmentoG->Periodo    := Periodo 
	SegmentoG->CodMuniOri := cMunOrigem 
	SegmentoG->DomiFiscal := "A"
	SegmentoG->CodMuni    := cCodMun
Else
	RecLock("SegmentoG", .F.)
EndIf

If TpMov == "S"
	SegmentoG->ValSai += Valor
ElseIf TpMov == "E"
	SegmentoG->ValEnt += Valor
EndIf

SegmentoG->(MsUnlock())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SegmentoHI บ Autor ณ Joใo Victor      บ Data ณ  27/12/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Alimenta os arquivos de trabalho dos Segmentos H e I:      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณSegmento H - Relacao de Mercadorias adquiridas de outros    บฑฑ
ฑฑบ          ณmunicipios com ISen็ใo deoICMS.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณSegmento I - Relacao de Mercadorias adquiridas de outros    บฑฑ
ฑฑบ          ณmunicipios com isen็ใo do ICMS detalhado por IE.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Static Function SegmentoHI(Periodo)

Local cAliasHI   := "SF3"
Local cMunOrigem := ""
Local cIEOrigem  := ""

#IFDEF TOP
If (TcSrvType() <> "AS/400")

	cAliasHI := GetNextAlias()

	BeginSql Alias cAliasHI      
	Select
		SA2.A2_INSCR      Inscricao,
		SF3.F3_ESTADO     Estado,
		SA2.A2_COD_MUN    Municipio,
		SF3.F3_NFISCAL    Nota,  
		SF3.F3_VALCONT    ValorContabil,
		SF3.F3_ISENICM    Isento
		FROM %table:SF3% SF3
		INNER JOIN %table:SA2% SA2 ON SA2.A2_FILIAL = %xFilial:SA2%							         
	                               AND SF3.F3_CLIEFOR = SA2.A2_COD
								         AND SF3.F3_LOJA = SA2.A2_LOJA
								         AND SA2.%NotDel%							       
		WHERE
			 SF3.F3_FILIAL = %xFilial:SF3% AND							         
			 SF3.F3_ENTRADA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND
			 SF3.%NotDel%       AND
			 SA2.A2_INSCR <> ' ' AND
			 SA2.A2_INSCR NOT LIKE '%ISENTO%' AND
			 SF3.F3_DTCANC = ' ' AND 
			 SF3.F3_CFO < '5'   AND
			 SF3.F3_TIPO NOT IN ('S','D') AND
			 SF3.F3_ESTADO = 'TO'  AND
			 SF3.F3_ISENICM > 0	
		ORDER BY
			SA2.A2_INSCR,SF3.F3_ESTADO,SA2.A2_COD_MUN
	EndSql
EndIf
#ENDIF

While !(cAliasHI)->(EOF())
	
	cMunOrigem := UfCodIBGE((cAliasHI)->Estado)+(cAliasHI)->Municipio  
	cIEORigem  := PadL(AllTrim((cAliasHI)->Inscricao), 9)
	
	If !SegmentoH->(dbSeek(cIE+Periodo+cIEOrigem+cCodMun+cMunOrigem))
		RecLock("SegmentoH", .T.)
		
		SegmentoH->IE         := cIE
		SegmentoH->Periodo    := Periodo
		SegmentoH->IEFornec   := cIEOrigem
		SegmentoH->DomiFiscal := "A"
		SegmentoH->CodMuni    := cCodMun		
		SegmentoH->MuniOrig   := cMunOrigem
		
		SegmentoH->(MsUnlock())
	EndIf
	
	If !SegmentoI->(dbSeek(cIE+Periodo+cIEOrigem+(cAliasHI)->Nota))
		RecLock("SegmentoI", .T.)
		
		SegmentoI->IE         := cIe
		SegmentoI->Periodo    := Periodo
		SegmentoI->IEFornec   := cIEOrigem 
		SegmentoI->DomiFiscal := "A"
		SegmentoI->CodMuni    := cCodMun
		SegmentoI->NumNota    := (cAliasHI)->Nota
	Else
		RecLock("SegmentoI", .F.)
	EndIf
	
	SegmentoI->ValNota += (cAliasHI)->ValorContabil
	SegmentoI->(MsUnlock())
	
(cAliasHI)->(dbSkip())

EndDo			

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SegmentoK บ Autor ณ Joใo Victor       บ Data ณ  27/12/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Alimenta o arquivo de trabalho do Segmento K:              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Outras Entradas / Saidas                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Static Function SegmentoK(TpMov, Periodo, CFOP, ValCont, ValBC, ValOutras, ValSubst)

If !SegmentoK->(dbSeek(cIe+Periodo+CFOP, .F.))
	RecLock("SegmentoK", .T.)
	
	SegmentoK->IE       := cIE
	SegmentoK->Periodo   := Periodo
	SegmentoK->TpMov     := TpMov	
	SegmentoK->CFOP      := CFOP 
	SegmentoK->DomiFiscal := "A"
	SegmentoK->CodMuni    := cCodMun
Else
	RecLock("SegmentoK", .F.)
EndIf
	
	SegmentoK->ValContab += ValCont
	SegmentoK->ValBC     += Iif(!lSimpNac, ValBC, 0)
	SegmentoK->ValIsenNT += Iif(!lSimpNac, ValOutras, 0)		
	SegmentoK->ValSubst  += ValSubst	
	
	SegmentoK->(MsUnlock())
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DIFTO  บ Autor ณ Isabel Alvarenga     บ Data ณ  22/03/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cria as tabelas temporแrias que serใo utilizadas para o    บฑฑ
ฑฑบ            processamento do arquivo magn้tico                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gerar arquivo magn้tico DIF para o estado de Tocantins.    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/           
Function CriaTabelas()

Local   aSegC	:= {}
Local   aSegD	:= {}
Local   aSegE	:= {}
Local   aSegF	:= {}
Local   aSegG	:= {}
Local   aSegH	:= {}
Local   aSegI	:= {}
Local   aSegK := {}

Local   aAlias		:= {}

Aadd(aSegC,{"IE"         ,"C",009,0})
Aadd(aSegC,{"Periodo"    ,"C",004,0})
Aadd(aSegC,{"TpEntrada"  ,"C",002,0})
Aadd(aSegC,{"DomiFiscal" ,"C",001,0})
Aadd(aSegC,{"CodMuni"    ,"C",007,0})
Aadd(aSegC,{"ValContab"  ,"N",014,2})
Aadd(aSegC,{"ValBC"      ,"N",014,2})
Aadd(aSegC,{"ValIsenNT"  ,"N",014,2})
Aadd(aSegC,{"ValSubst"   ,"N",014,2})

cSegmentoC	:=	CriaTrab(aSegC)
dbUseArea(.T.,__LocalDriver,cSegmentoC,"SegmentoC")
IndRegua("SegmentoC",cSegmentoC,"IE+Periodo+TpEntrada")
Aadd(aAlias,{cSegmentoC,"SegmentoC"})

Aadd(aSegD,{"IE"          ,"C",009,0})
Aadd(aSegD,{"Periodo"     ,"C",004,0})
Aadd(aSegD,{"UF"          ,"C",002,0})
Aadd(aSegD,{"DomiFiscal"  ,"C",001,0})
Aadd(aSegD,{"CodMuni"     ,"C",007,0})
Aadd(aSegD,{"ValContab"   ,"N",014,2})
Aadd(aSegD,{"ValBC"       ,"N",014,2})
Aadd(aSegD,{"ValIsenNT"   ,"N",014,2})
Aadd(aSegD,{"ValEnergia"  ,"N",014,2}) // Energia + Petroleo
Aadd(aSegD,{"ValOutros"	  ,"N",014,2}) // Outros Produtos
Aadd(aSegD,{"ValSubst"	  ,"N",014,2})

cSegmentoD	:=	CriaTrab(aSegD)
dbUseArea(.T.,__LocalDriver,cSegmentoD,"SegmentoD")
IndRegua("SegmentoD",cSegmentoD,"IE+Periodo+UF")
Aadd(aAlias,{cSegmentoD,"SegmentoD"})

Aadd(aSegE,{"IE"          ,"C",009,0})
Aadd(aSegE,{"Periodo"     ,"C",004,0})
Aadd(aSegE,{"TpSaida"     ,"C",002,0})
Aadd(aSegE,{"DomiFiscal"  ,"C",001,0})
Aadd(aSegE,{"CodMuni"     ,"C",007,0})
Aadd(aSegE,{"ValContab"   ,"N",014,2})
Aadd(aSegE,{"ValBC"       ,"N",014,2})
Aadd(aSegE,{"ValIsenNT"   ,"N",014,2})
Aadd(aSegE,{"ValSubst"	  ,"N",014,2})

cSegmentoE	:=	CriaTrab(aSegE)
dbUseArea(.T.,__LocalDriver,cSegmentoE,"SegmentoE")
IndRegua("SegmentoE",cSegmentoE,"IE+Periodo+TpSaida")
Aadd(aAlias,{cSegmentoE,"SegmentoE"})

Aadd(aSegF,{"IE"         ,"C",009,0})
Aadd(aSegF,{"Periodo"    ,"C",004,0})
Aadd(aSegF,{"UF"         ,"C",002,0})
Aadd(aSegF,{"DomiFiscal" ,"C",001,0})
Aadd(aSegF,{"CodMuni"    ,"C",007,0})
Aadd(aSegF,{"ValContab"  ,"N",014,2})
Aadd(aSegF,{"ValContbNC" ,"N",014,2})
Aadd(aSegF,{"ValBC"      ,"N",014,2})
Aadd(aSegF,{"ValBCNaoCt" ,"N",014,2})
Aadd(aSegF,{"ValIsenNT"  ,"N",014,2})
Aadd(aSegF,{"ValSubst"	 ,"N",014,2})
Aadd(aSegF,{"ICMSST"  	 ,"N",014,2})

cSegmentoF	:=	CriaTrab(aSegF)
dbUseArea(.T.,__LocalDriver,cSegmentoF,"SegmentoF")
IndRegua("SegmentoF",cSegmentoF,"IE+Periodo+UF")
Aadd(aAlias,{cSegmentoF,"SegmentoF"})

Aadd(aSegG,{"IE"          ,"C",009,0})
Aadd(aSegG,{"Periodo"     ,"C",004,0})
Aadd(aSegG,{"CodMuniOri"  ,"C",007,0})
Aadd(aSegG,{"DomiFiscal"  ,"C",001,0})
Aadd(aSegG,{"CodMuni"     ,"C",007,0})
Aadd(aSegG,{"ValSai"      ,"N",014,2})
Aadd(aSegG,{"ValEnt"      ,"N",014,2})

cSegmentoG := CriaTrab(aSegG)
dbUseArea(.T.,__LocalDriver,cSegmentoG,"SegmentoG")
IndRegua("SegmentoG",cSegmentoG,"IE+Periodo+CodMuniOri")
Aadd(aAlias,{cSegmentoG,"SegmentoG"})

Aadd(aSegH,{"IE"         ,"C",009,0})
Aadd(aSegH,{"Periodo"    ,"C",004,0})
Aadd(aSegH,{"IEFornec"   ,"C",009,0})
Aadd(aSegH,{"DomiFiscal" ,"C",001,0})
Aadd(aSegH,{"CodMuni"    ,"C",007,0})
Aadd(aSegH,{"MuniOrig"	 ,"C",007,0})

cSegmentoH	:=	CriaTrab(aSegH)
dbUseArea(.T.,__LocalDriver,cSegmentoH,"SegmentoH")
IndRegua("SegmentoH",cSegmentoH,"IE+Periodo+IEFornec+CodMuni+MuniOrig")
Aadd(aAlias,{cSegmentoH,"SegmentoH"})

Aadd(aSegI,{"IE"         ,"C",009,0})
Aadd(aSegI,{"Periodo"    ,"C",004,0})
Aadd(aSegI,{"IEFornec"   ,"C",009,0})
Aadd(aSegI,{"DomiFiscal" ,"C",001,0})
Aadd(aSegI,{"CodMuni"    ,"C",007,0})
Aadd(aSegI,{"NumNota"	 ,"C",007,0})
Aadd(aSegI,{"ValNota"	 ,"N",014,2})

cSegmentoI	:=	CriaTrab(aSegI)
dbUseArea(.T.,__LocalDriver,cSegmentoI,"SegmentoI")
IndRegua("SegmentoI",cSegmentoI,"IE+Periodo+IEFornec+NumNota")
Aadd(aAlias,{cSegmentoI,"SegmentoI"})

Aadd(aSegK,{"IE"         ,"C",009,0})
Aadd(aSegK,{"Periodo"    ,"C",004,0})
Aadd(aSegK,{"TpMov"      ,"C",001,0})
Aadd(aSegK,{"CFOP"       ,"C",004,0})
Aadd(aSegK,{"DomiFiscal" ,"C",001,0})
Aadd(aSegK,{"CodMuni"    ,"C",007,0})
Aadd(aSegK,{"ValContab"  ,"N",014,2})
Aadd(aSegK,{"ValBC"      ,"N",014,2})
Aadd(aSegK,{"ValIsenNT"  ,"N",014,2})
Aadd(aSegK,{"ValSubst"	 ,"N",014,2})

cSegmentoK	:=	CriaTrab(aSegK)
dbUseArea(.T.,__LocalDriver,cSegmentoK,"SegmentoK")
IndRegua("SegmentoK",cSegmentoK,"IE+Periodo+CFOP")
Aadd(aAlias,{cSegmentoK,"SegmentoK"})

Return aAlias

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DIFTO  บ Autor ณ Isabel Alvarenga     บ Data ณ  22/03/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica o estado e retorna o c๓digo predefnido no layout. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gerar arquivo magn้tico DIF para o estado de Tocantins.    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Cod_Estado(cCodUF)
If Len(AllTrim(cCodUF)) > 0
	Do Case
		Case (AllTrim(cCodUF) == "AC")
			Return("01")
		Case (AllTrim(cCodUF) == "AL")
			Return("02")
		Case (AllTrim(cCodUF) == "AP")
			Return("03")
		Case (AllTrim(cCodUF) == "AM")
			Return("04")
		Case (AllTrim(cCodUF) == "BA")
			Return("05")
		Case (AllTrim(cCodUF) == "CE")
			Return("06")
		Case (AllTrim(cCodUF) == "DF")
			Return("07")
		Case (AllTrim(cCodUF) == "ES")
			Return("08")
		Case (AllTrim(cCodUF) == "GO")
			Return("10")
		Case (AllTrim(cCodUF) == "MA")
			Return("12")
		Case (AllTrim(cCodUF) == "MT")
			Return("13")
		Case (AllTrim(cCodUF) == "MG")
			Return("14")
		Case (AllTrim(cCodUF) == "PA")
			Return("15")
		Case (AllTrim(cCodUF) == "PB")
			Return("16")
		Case (AllTrim(cCodUF) == "PR")
			Return("17")
		Case (AllTrim(cCodUF) == "PE")
			Return("18")
		Case (AllTrim(cCodUF) == "PI")
			Return("19")
		Case (AllTrim(cCodUF) == "RN")
			Return("20")
		Case (AllTrim(cCodUF) == "RS")
			Return("21")
		Case (AllTrim(cCodUF) == "RJ")
			Return("22")
		Case (AllTrim(cCodUF) == "RO")
			Return("23")
		Case (AllTrim(cCodUF) == "RR")
			Return("24")
		Case (AllTrim(cCodUF) == "SC")
			Return("25")
		Case (AllTrim(cCodUF) == "SP")
			Return("26")
		Case (AllTrim(cCodUF) == "SE")
			Return("27")
		Case (AllTrim(cCodUF) == "MS")
			Return("28")
		Case (AllTrim(cCodUF) == "TO")
			Return("29")
		Case (AllTrim(cCodUF) == "EX")
			Return("90")
		Otherwise
			Return("11")
	EndCase
EndIf

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ TipoEntSai บ Autor ณ Joใo Victor      บ Data ณ  27/12/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna o Tipo de Entrada ou Saida de acordo com o CFOP    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Static Function TipoEntSai(CFOP, TipoMov, aWizard)

Local cCFOP      := ""

Local cCompraVenda := "100/101/102/103/104/105/106/107/108/109/110/111/112/113/114/115/116/117/118/119/120/121/122/123/124/125/126/127/128/"
Local cTransf      := "150/151/152/153/154/155/156/"
Local cDevCancel   := "200/201/202/203/204/205/206/207/208/209/210/211/"
Local cTransp      := "350/351/352/353/354/355/356/357/358/359/360/"
Local cComunic     := "300/301/302/303/304/305/306/307/"
Local cEnergia     := "250/251/252/253/254/255/256/257/258/"
Local cDifAliq     := "550/551/552/553/554/555/556/557/"
Local cAtivPerm    := "550/551/552/553/554/555/" 
Local cUsoCons     := "556/557/"
Local cServico     := ""
Local cOutros      := "900/901/902/903/904/905/906/907/908/909/910/911/912/913/914/915/916/917/918/919/920/921/922/923/924/925/926/931/932/949/"

cCFOP := AllTrim(Substr(CFOP, 2, 3))

If TipoMov == "E"

	Do Case
		Case cCFOP $ cCompraVenda+aWizard[1] .And. !cCFOP $ OutrosCFOPWiz(1, aWizard) 
			Return("01")
		Case cCFOP $ cTransf+aWizard[2] .And. !cCFOP $ OutrosCFOPWiz(2, aWizard)
			Return("02")
		Case cCFOP $ cDevCancel+aWizard[3] .And. !cCFOP $ OutrosCFOPWiz(3, aWizard)
			Return("03")
		Case cCFOP $ cTransp+aWizard[4] .And. !cCFOP $ OutrosCFOPWiz(4, aWizard)
			Return("04")				
		Case cCFOP $ cComunic+aWizard[5] .And. !cCFOP $ OutrosCFOPWiz(5, aWizard)
			Return("05")	
		Case cCFOP $ cEnergia+aWizard[6] .And. !cCFOP $ OutrosCFOPWiz(6, aWizard)
			Return("06")	
		Case cCFOP $ cDifAliq+aWizard[7] .And. !cCFOP $ OutrosCFOPWiz(7, aWizard) .And. AllTrim(SubStr(CFOP, 1, 1)) == "2"
			Return("07")
		Case cCFOP $ cAtivPerm+aWizard[8] .And. !cCFOP $ OutrosCFOPWiz(8, aWizard)
			Return("08")
		Case cCFOP $ cUsoCons+aWizard[9] .And. !cCFOP $ OutrosCFOPWiz(9, aWizard)
			Return("09")
		Case cCFOP $ cServico+aWizard[10] .And. !cCFOP $ OutrosCFOPWiz(10, aWizard)
			Return("10")				
		Case cCFOP $ cOutros+aWizard[11] .And. !cCFOP $ OutrosCFOPWiz(11, aWizard)
			Return("11")
		Otherwise
			// Se o CFOP nใo se enquadrar em nenhum tipo, alimenta o array de CFOPs nใo classificados.
			aAdd(aNclass, CFOP)
			Return("00")		
	EndCase
	
ElseIf TipoMov == "S"

	Do Case
		Case cCFOP $ cCompraVenda+aWizard[1] .And. !cCFOP $ OutrosCFOPWiz(1, aWizard) 
			Return("01")
		Case cCFOP $ cTransf+aWizard[2] .And. !cCFOP $ OutrosCFOPWiz(2, aWizard) 
			Return("02")
		Case cCFOP $ cDevCancel+aWizard[3] .And. !cCFOP $ OutrosCFOPWiz(3, aWizard) 
			Return("03")
		Case cCFOP $ cEnergia+aWizard[4] .And. !cCFOP $ OutrosCFOPWiz(4, aWizard) 
			Return("04")				
		Case cCFOP $ cComunic+aWizard[5] .And. !cCFOP $ OutrosCFOPWiz(5, aWizard) 
			Return("05")	
		Case cCFOP $ cTransp+aWizard[6] .And. !cCFOP $ OutrosCFOPWiz(6, aWizard) 
			Return("06")	
		Case cCFOP $ cAtivPerm+aWizard[7] .And. !cCFOP $ OutrosCFOPWiz(7, aWizard) 
			Return("07")
		Case cCFOP $ cUsoCons+aWizard[8] .And. !cCFOP $ OutrosCFOPWiz(8, aWizard) 
			Return("08")
		Case cCFOP $ cServico+aWizard[9] .And. !cCFOP $ OutrosCFOPWiz(9, aWizard) 
			Return("09")
		Case cCFOP $ cOutros+aWizard[10] .And. !cCFOP $ OutrosCFOPWiz(10, aWizard) 
			Return("10")				
		Otherwise
			// Se o CFOP nใo se enquadrar em nenhum tipo, alimenta o array de CFOPs nใo classificados.
			aAdd(aNclass, CFOP)
			Return("00")		
	EndCase

EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OutrosCFOPWiz บ Autor ณ Joใo Victor   บ Data ณ  09/01/2014 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para retornar todos os CFOPs inseridos na Wizard,    บฑฑ
ฑฑบ          ณ exceto os da posicao nPosExc.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณO Objetivo ้ verificar se o mesmo CFOP nใo foi inserido     บฑฑ
ฑฑบ          ณ em mais de um campo da wizard.Caso isso aconteca, aquele   บฑฑ
ฑฑบ          ณ CFOP nใo serแ considerado em nenhum tipo de entrada/saida. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Static Function OutrosCFOPWiz(nPosExc, aWizard)

Local cRet := ""
Local nX   := 0

For nX := 1 to Len(aWizard)
	cRet += Iif(nX <> nPosExc, AllTrim(aWizard[nX]), "")
Next nX

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณ DIFTO  บ Autor ณ Isabel Alvarenga     บ Data ณ  25/03/2013   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo para fechar todas as tabelas temporแrias criadas      บฑฑ
ฑฑบ            durante a gera็ใo do arquivo magn้tico                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gerar arquivo magn้tico DIF para o estado de Tocantins.      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FechaTemporarios(aArquivo)

Local nX := 0

For nX := 1 to Len(aArquivo)
	If File(aArquivo[nX][1]+GetDBExtension())
		dbSelectArea(aArquivo[nX][2])
		(aArquivo[nX][2])->(dbCloseArea())
		Ferase(aArquivo[nX][1]+GetDBExtension())
		Ferase(aArquivo[nX][1]+OrdBagExt())
	Endif
Next nX

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DIFTOFim      บ Autor ณ Joใo Victor   บ Data ณ  09/01/2014 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณRotina de finaliza็ใo do arquivo magnetico.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ 
Function DIFTOFim(aTabelas)

Local nX := 0
Local cRet := ""
	
	//Fechando arquivos temporแrios
	FechaTemporarios(aTabelas)
	
	//Verifica se nใo hแ CFOPs que nใo foram classificados em nenhum tipo de E/S.
	If Len(aNClass) > 0
		For nX := 1 to Len(aNClass)			
			cRet += IIF(!aNClass[nX]$cRet, "- " + aNClass[nX] +Chr(13)+Chr(10), "")
		Next nX
		
		ApMsgAlert("Existe(m) CFOP(s) nใo classificado(s). Verifique: " +Chr(13)+Chr(10) + cRet, "Aten็ใo!")
	EndIf	
Return