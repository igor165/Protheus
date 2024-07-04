#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXRMP.CH"

#DEFINE MR_F3_FILIAL	01
#DEFINE MR_F3_ESPECIE	02
#DEFINE MR_F3_SERIE		03
#DEFINE MR_F3_NFISCAL 	04    
#DEFINE MR_F3_DOCOR		05    
#DEFINE MR_F3_ENTRADA	06    
#DEFINE MR_F3_EMISSAO	07    
#DEFINE MR_F3_TIPO		08    
#DEFINE MR_F3_CFO		09
#DEFINE MR_F3_ESTADO	10    
#DEFINE MR_F3_CLIEFOR	11    
#DEFINE MR_F3_LOJA		12    
#DEFINE MR_F3_IDENTFT	13    
#DEFINE MR_F3_PDV		14
#DEFINE MR_F3_VALOBSE	15    
#DEFINE MR_F3_NUMINI	16    
#DEFINE MR_F3_NUMFIM	17
#DEFINE MR_F3_CODISS	18    
#DEFINE MR_F3_ECF		19         
#DEFINE MR_F3_ALIQICM	20    
#DEFINE MR_F3_BASEICM	21
#DEFINE MR_F3_VALCONT	22
#DEFINE MR_F3_VALICM	23    
#DEFINE MR_F3_OBSERV	24
#DEFINE MR_F3_ISENICM	25
#DEFINE MR_F3_OUTRICM	26
#DEFINE MR_F3_ICMSRET	27
#DEFINE MR_F3_REPROC	28
#DEFINE MR_F3_DTCANC	29    
#DEFINE MR_NUMNOTA		30    
#DEFINE MR_FILCORR		31    
#DEFINE MR_F3_BASERET	32    

Static oTblTmp	:= NIL 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMaxRVerFunบAutor  ณMicrosiga           บ Data ณ 09/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica chamada de origem dos Relatorios                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe 	 ณ MaxRVerFunc(ExpC1)										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณExpC1 - Chamada origem                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL1 - Se executa as funcoes genericas                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       |MATR930, FISXAPUR                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function MaxRVerFunc(cChamOrig)

Local lRet := .F.					// Retorno da funcao

Default cChamOrig := ""				// Chamada origem

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica qual eh a chamada origemณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cChamOrig $ "MATR930|MATRISS|MATR908|MATR914|MATR921|MATR990|F3_MATRAPR|IP_MATRAPR"
	lRet := .T.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMaXRMapResบAutor  ณMicrosiga           บ Data ณ 09/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAlimenta array com as informacoes do Mapa Resumo.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe 	 ณ MaXRMapRes(ExpD1,ExpD1)									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณExpD1 - Data Inicio para busca                              บฑฑ
ฑฑบ          ณExpD2 - Data Final para busca                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpA1 - Array com as informacoes do Mapa Resumo             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       |MATR930,MATRISS,MATR908,MATR914,MATR920,MATR990,MATRAPR     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function MaXRMapRes(dDataIni,dDataFim, aMapaResumo)

Local nPos 			:= 0									// Retorna a posicao do mapa resumo no aScan
Local nX			:= 0									// Contador do For, para verificar todas as bases de calculo de ICMS
Local cPdvAnt 		:= ""									// Pdv Antigo
Local dDataAnt 		:= Space(8)								// Espaco
Local nValImp		:= 0									// Imposto
Local nDifImp		:= 0									// Diferenca Imposto
Local nPosPDV 		:= 0									// PDV
Local nValBase      := 0                           			// Valor base do imposto 
Local nValorImp     := 0                           			// Valor do imposto
Local lZerado 		:= .T.									// Zerado
Local lSepAliqISS	:= .F.									// Verifica se no relatorio as aliquotas de ISS serใo mostradas separadas uma por uma
Local cCampo		:= ""									// Campo
Local nGTFinal      := 0                                    // Grande Total (GT) Final 
Local cNumRedZ      := Space(TamSx3('FI_NUMREDZ')[1])       // Numero da Reducao Z

Default dDataIni	:= CTOD("  /  /  ")						// Data Inicial para filtrar SFI
Default dDataFim	:= CTOD("  /  /  ")						// Data Final para filtrar SFI
Default aMapaResumo	:= {}									// Array com as informacoes, caso gere mapa resumo, para gravar no SFI

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o arquivo SFI esta em uso                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Select("SFI") == 0
	ChkFile("SFI")
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcessa os dados do SFI                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SFI")
ProcRegua(Reccount())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAqui faz o processamento para os clientes que sao obrigados a ณ
//ณemitir o Mapa Resumo                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณaMapaResumo                   ณ
//ณ[01] - Data                   ณ
//ณ[02] - Aliquota               ณ
//ณ[03] - Tributo (TSFNI)        ณ
//ณ[04] - Valor Base             ณ
//ณ[05] - Valor Imposto          ณ
//ณ[06] - Numero do Mapa Resumo  ณ
//ณ[07] - Num. do ECF (PDV)      ณ
//ณ[08] - Num. do Cupom Inicial  ณ
//ณ[09] - Num. do Cupom Final    ณ
//ณ[10] - Valor Desconto         ณ
//ณ[11] - Observacao             ณ
//ณ[12] - Base do ISS            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


DbSelectArea("SFI")
DbSeek(xFilial("SFI")+Dtos(dDataIni),.T.)
While !SFI->(Eof()) .AND. SFI->FI_FILIAL == xFilial("SFI") .AND. SFI->FI_DTMOVTO <= dDataFim
	nGTFinal := SFI->FI_GTFINAL
	cNumRedZ := SFI->FI_NUMREDZ
	If SFI->FI_VALCON > 0 .OR. SFI->FI_ISS > 0
		lZerado := .T.  
		lSepAliqISS	:= .F.		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica os campos de Impostos ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nX:=1 to 9999
			cCampo := "FI_BAS"+Alltrim(Str(nX))
			If ColumnPos( cCampo ) > 0
				If FieldGet( ColumnPos( cCampo ) ) > 0
					lZerado := .F.
	
					nPos := aScan( aMapaResumo, {|x| Dtos(x[1]) + Alltrim(Str(x[2])) + x[7] == Dtos(SFI->FI_DTMOVTO) + AllTrim(Str(nX)) + SFI->FI_PDV })
	
					If nPos > 0	
						aMapaResumo[nPos][4] += FieldGet( ColumnPos(cCampo) )
						aMapaResumo[nPos][5] := NoRound( aMapaResumo[nPos][4] * aMapaResumo[nPos][2]/100, 2 )
					Else	
					    nValBase   := NoRound( FieldGet(ColumnPos(cCampo)), 2 )
					    nValorImp  := NoRound( FieldGet(ColumnPos(cCampo)) * Val(MaXRPerAliq(nX)) / 100, 2 )
						aAdd( aMapaResumo, {SFI->FI_DTMOVTO	, nX			, "T"            	, ;
					                    	nValBase        , nValorImp		, SFI->FI_NUMERO	, ;
					                    	SFI->FI_PDV		, SFI->FI_NUMINI, SFI->FI_NUMFIM	, ;
					                    	SFI->FI_DESC    , "GT= "+Alltrim(STR(nGTFinal))+" CRZ= "+cNumRedZ	,;
					                    	0				} )
					EndIf
				EndIf
			EndIf
		Next nX
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Trata lancamento na aliq. 0,01 (Garantido Integral ECF - Mato Grosso) ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cCampo := "FI_BAS001"
		If ColumnPos(cCampo) > 0
			
			//ฺฤฤฤฤฤฤฤฤฟ
			//ณAliquotaณ
			//ภฤฤฤฤฤฤฤฤู
			nX := 0.01	
			If FieldGet( ColumnPos( cCampo ) ) > 0
				lZerado := .F.
	
				nPos := aScan( aMapaResumo, {|x| Dtos(x[1]) + Str(x[2],5,2) + x[7] == Dtos(SFI->FI_DTMOVTO) + Str(nX,5,2) + SFI->FI_PDV })
	
				If nPos > 0	
					aMapaResumo[nPos][4] += FieldGet( ColumnPos(cCampo) )
					aMapaResumo[nPos][5] := NoRound(aMapaResumo[nPos][4]*aMapaResumo[nPos][2]/100,2)
				Else				
					nValBase	:= 	NoRound( FieldGet(ColumnPos(cCampo)), 2 )
					nValorImp	:=	NoRound( FieldGet(ColumnPos(cCampo)) * Val(MaXRPerAliq(nX))/100, 2 )		
					
					aAdd( aMapaResumo, {SFI->FI_DTMOVTO	, nX			, "T"			, nValBase			,;
										nValorImp		, SFI->FI_NUMERO, SFI->FI_PDV	, SFI->FI_NUMINI	,;
										SFI->FI_NUMFIM	, SFI->FI_DESC	, "GT= "+Alltrim(STR(nGTFinal))+" CRZ= "+cNumRedZ	, ;
										0		} )
				EndIf
			EndIf
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica os campos de subst.Tribut., Isentos e Nao Trib.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If SFI->FI_SUBTRIB > 0
			lZerado := .F.
	
			nPos := aScan( aMapaResumo, {|x| Dtos(x[1]) + x[3] + x[7] == Dtos(SFI->FI_DTMOVTO) + "F" + SFI->FI_PDV })
	
			If nPos > 0	
				aMapaResumo[nPos][4] += SFI->FI_SUBTRIB	
			Else	
				aAdd( aMapaResumo, {SFI->FI_DTMOVTO   		, 0          	, "F"            	, ;
				                    SFI->FI_SUBTRIB       	, 0          	, SFI->FI_NUMERO 	, ;
				                    SFI->FI_PDV				,SFI->FI_NUMINI	, SFI->FI_NUMFIM 	, ;
				                    SFI->FI_DESC          	,"GT= "+Alltrim(STR(nGTFinal))+" CRZ= "+cNumRedZ	, ;
				                    0		} )
			EndIf
		Endif
		
		If SFI->FI_ISENTO > 0
			lZerado := .F.
	
			nPos := aScan( aMapaResumo, {|x| Dtos(x[1]) + x[3] + x[7] == Dtos(SFI->FI_DTMOVTO) + "I" + SFI->FI_PDV })
	
			If nPos > 0
	
				aMapaResumo[nPos][4] += SFI->FI_ISENTO
	
			Else
	
				aAdd( aMapaResumo, {SFI->FI_DTMOVTO      	, 0           	, "I"          		, ;
				                    SFI->FI_ISENTO        	, 0            	, SFI->FI_NUMERO	, ;
				                    SFI->FI_PDV				,SFI->FI_NUMINI	, SFI->FI_NUMFIM	, ;
				                    SFI->FI_DESC          	,"GT= "+Alltrim(STR(nGTFinal))+" CRZ= "+cNumRedZ	, ;
				                    0		} )
			Endif
		Endif
		
		If SFI->FI_NTRIB > 0
			lZerado := .F.
	
			nPos := aScan( aMapaResumo, {|x| Dtos(x[1]) + x[3] + x[7] == Dtos(SFI->FI_DTMOVTO) + "N" + SFI->FI_PDV })
	
			If nPos > 0
	
				aMapaResumo[nPos][4] += SFI->FI_NTRIB
	
			Else						
	
				aAdd( aMapaResumo, {SFI->FI_DTMOVTO        	, 0       		, "N"          		, ;
				                    SFI->FI_NTRIB         	, 0            	, SFI->FI_NUMERO	, ;
				                    SFI->FI_PDV				,SFI->FI_NUMINI	, SFI->FI_NUMFIM	, ;
				                    SFI->FI_DESC         	,"GT= "+Alltrim(STR(nGTFinal))+" CRZ= "+cNumRedZ	, ;
				                    0		} )
			Endif
		Endif
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณTratamento de outros recebimentosณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If SFI->FI_OUTROSR > 0
			lZerado := .F.
	
			nPos := aScan( aMapaResumo, {|x| Dtos(x[1])+x[3]+x[7] == Dtos(SFI->FI_DTMOVTO)+"O"+SFI->FI_PDV })
	
			If nPos > 0
	
				aMapaResumo[nPos][4] += SFI->FI_OUTROSR
	
			Else							
	
				aAdd( aMapaResumo, {SFI->FI_DTMOVTO        	,  0           	, "O"        		, ;
				                    SFI->FI_OUTROSR      	, 0            	, SFI->FI_NUMERO	, ;
				                    SFI->FI_PDV				,SFI->FI_NUMINI	, SFI->FI_NUMFIM	, ;
				                    SFI->FI_DESC       		,"GT= "+Alltrim(STR(nGTFinal))+" CRZ= "+cNumRedZ	, ;
				                    0		} )
			Endif
		Endif
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณTratamento para o campo de ISS   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	  	For nX := 1 to SFI->(FCount())
			cCampo := AllTrim(FieldName(nX))
			If Subs(cCampo,1,6) $ "FI_BIS" // O nome do campo ้: 'FI_BIS' + valor da aliquota. Ex.: Aliq de 5% = 'FI_BIS0500'
				If ColumnPos( cCampo ) > 0
					If FieldGet( ColumnPos( cCampo ) ) > 0
						lZerado 	:= .F.
						lSepAliqISS	:= .T.
	
						nPos := aScan( aMapaResumo, ;
							{|x| Dtos(x[1])+AllTrim( Str(x[2]) )+x[7] == Dtos(SFI->FI_DTMOVTO)+ Str( (Val(Subs(cCampo,7,Len(cCampo)))/100) ) + SFI->FI_PDV })
		
						If nPos > 0	        	
							aMapaResumo[nPos][12]	+= FieldGet( ColumnPos(cCampo) )
						Else
	
						    nValBase   := FieldGet( ColumnPos(cCampo) )
						    
							aAdd( aMapaResumo, {SFI->FI_DTMOVTO	, Val(Subs(cCampo,7,Len(cCampo)))/100	, "S"            	, ;
							                   	0 				, 0				  						, SFI->FI_NUMERO	, ;
							                   	SFI->FI_PDV		, SFI->FI_NUMINI						, SFI->FI_NUMFIM	, ;
							                   	SFI->FI_DESC   	, STR0001 								, nValBase			} )
						Endif
					EndIf	
				Endif
			Endif
		Next nX

		If SFI->FI_ISS > 0	.AND.	!lSepAliqISS  // Caso existam alํquotas de ISS e nใo estejam separadas sใo adicionadas no array
			lZerado := .F.
	
			nPos := aScan( aMapaResumo, {|x| Dtos(x[1])+x[3]+x[7] == Dtos(SFI->FI_DTMOVTO)+"S"+SFI->FI_PDV })
	
			If nPos > 0
	
				aMapaResumo[nPos][12] += SFI->FI_ISS
	
			Else
				// Registro do Mapa Resumo
				aAdd( aMapaResumo, {SFI->FI_DTMOVTO     	, SuperGetMV("MV_ALIQISS")		, "S"        		, ;
				                    0                     	, 0                          	, SFI->FI_NUMERO	, ;
				                    SFI->FI_PDV				,SFI->FI_NUMINI              	, SFI->FI_NUMFIM	, ;
				                    SFI->FI_DESC          	, STR0001						, SFI->FI_ISS    	} )
			Endif
		Endif
		
		If lZerado		
			aAdd( aMapaResumo, {SFI->FI_DTMOVTO		, 0    			, "T"				, ;
			                     0              	, 0        		, SFI->FI_NUMERO	, ;
			                     SFI->FI_PDV		,SFI->FI_NUMINI	, SFI->FI_NUMFIM	, ;
			                     SFI->FI_DESC     	,"GT= "+Alltrim(STR(nGTFinal))+" CRZ= "+cNumRedZ	, ;
			                     0			} )
		Endif
	EndIf
		
	SFI->(DbSkip())
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Removo os outros descontos para que nao duplique. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*For nX:= 1 to Len(aMapaResumo)
	If nX > 1
		aMapaResumo[nX][10] := 0
	EndIf
Next nX*/
//pode dar erro, ao vir varias impressoras fiscais
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFaz a checagem do arredondamento dos impostos.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SFI->(DbSetOrder(1))

nX := 1

nPosPDV := 7

While nX<= Len(aMapaResumo)

	cPdvAnt 	:= aMapaResumo[nX][nPosPDV]

	dDataAnt 	:= aMapaResumo[nX][1]
	nValImp 	:= 0
	nDifImp 	:= 0
	While dDataAnt == aMapaResumo[nX][1] .AND. cPdvAnt == aMapaResumo[nX][nPosPDV]
		nValImp += aMapaResumo[nX][5]
		nX ++
		If nX > Len(aMapaResumo)
			Exit
		Endif
	End

	If SFI->(DbSeek(xFilial("SFI")+DTOS(dDataAnt)+cPdvAnt))
		nDifImp := nValImp - SFI->FI_IMPDEBT
		If nDifImp <> 0
			If ( nPos := ASCAN(aMapaResumo,{|x| DTOS(x[1])+x[nPosPDV]+x[3] == DTOS(dDataAnt)+cPdvAnt+"T" }) ) > 0
				aMapaResumo[nPos][5] -= nDifImp
			Endif
		Endif
	Endif

End

Return aMapaResumo

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMaXRAgrupFบAutor  ณMicrosiga           บ Data ณ 09/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera array com os agrupamentos necessarios a serem         บฑฑ
ฑฑบ          ณ apresentados no arquivo temporario                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe 	 ณ MaXRAgrupF3(ExpC1,ExpA2,ExpC3)							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณExpC1 - Filial de processo		                          บฑฑ
ฑฑบ          ณExpA2 - Informacoes do Mapa Resumo		                  บฑฑ
ฑฑบ          ณExpC3 - Chama Origem		                              	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpA1 - Informacoes a serem apresentadas  		          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       |MATR930,MATRISS,MATR908,MATR914,MATR920,MATR990,MATRAPR     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function MaXRAgrupF3(cFilProc,aMapaResumo,cChamOrig,nLegArt,lMTR930)

Local aGravaMapRes	:= {}									// Grava mapa resumo
Local nLinF3		:= 0									// Linha do SF3
Local cCliPad		:= SuperGetMV("MV_CLIPAD")				// Cliente padrao
Local cLojPad		:= SuperGetMV("MV_LOJAPAD")				// Loja padrao
Local nX			:= 0									// Contador de for
Local nY			:= 0									// Contador de for
Local cEstado 		:= SuperGetMV("MV_ESTADO")				// Estado
Local nTamSx31		:= TamSx3("F3_ALIQICM")[1]				// Tamanho de campo
Local nTamSx32		:= TamSx3("F3_ALIQICM")[2]				// Tamanho de campo
Local lRndVlIss 	:= SuperGetMV("MV_RNDISS",,.F.)			// Arredondamento do ISS
Local cF3Pdv		:= ""									
Local cMapaPdv		:= ""
Local bBloco        := {|| NIL }                            // Bloco de codigo executado quando tenta mudar a forma de pagamento para Lay-Away
Local nICMSRet		:= 0									// Valor de ICMS retido
Local nBasSRet		:= 0									// Base de Reducao
Local aAreaSF3	 	:= {}									// Salva a area do SF3
Local aCfop 		:= {} 							        // Usado para buscar Cfop padrao na fun็ใo LjBuscaCFo
Local cCFO          := ""
Local cSelect		:= ''
Local cWhere		:= ''
Local cAliasSF3	    := ''
Local lTop          := .F.
Local lNumPdv       := ( AllTrim( Upper( FunName() ) ) $ "MATR990|MATRISS|MATR914" ) // Considera sempre na chave de busca o n๚mero do pdv para estes livros 

Default aMapaResumo := {}
Default cFilProc	:= xFilial("SF3")
Default nLegArt		:= 0
Default lMTR930   := .F.

#IFDEF TOP
	If TcSrvType() <> "AS/400"
		lTop 	:= .T.
	Endif
#ENDIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Para estes artigos deve detalhar por PDV a PDV , porisso acresentara esta chave no Ascan ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nLegArt == 2 .OR. nLegArt == 3 .Or. lNumPdv
	cF3Pdv	:= " + x[14][2]"
	cMapaPdv:= " + aMapaResumo[nX][7]"
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFaz a gravacao do Livro Fiscal com base na array aMapaResumo           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aMapaResumo) > 0
	If ExistFunc("LJBUSCACFO")
		aCFOP := LjBuscaCFo() // Busca CFOPs Padrใo/Parametrizados
	EndIf	

	For nX :=1 to Len(aMapaResumo)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Definicao das variaveis para o seek no SF3              ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPara o Piaui, a Serie tem que ser do PDVณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If LjAnalisaLeg(18)[1]
			cSerie := aMapaResumo[nX][7]
		Else
			cSerie 	:= Padr( "ECF" ,TamSx3("F3_SERIE")[1] )
		EndIf

		cCFO := ""
        If Ascan(aCFOP,{|x|x[1] == aMapaResumo[nX][3] } ) > 0  
			cCFO 	:= Padr( aCFOP[Ascan(aCFOP,{|x|x[1] == aMapaResumo[nX][3]})][2] , TamSx3("F3_CFO")[1] )
        EndIf
        
        // caso nใo esteja cadastrado no Parametro trata como padrใo antigo
        If AllTrim(cCFO) == ""
     		cCFO 	:= Padr( IIf(aMapaResumo[nX][3] == "F","5405","5102"), TamSx3("F3_CFO")[1] )			
		EndIf

		If aMapaResumo[nX][3] $ "NIF"
			nAliq 	:= 0
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe for servicoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ElseIf aMapaResumo[nX][3] == "S"		
			nAliq 	:= Val(MaXRPerAliq(aMapaResumo[nX][2]))
		Else
			nAliq 	:= Val(MaXRPerAliq(aMapaResumo[nX][2]))
		Endif
		cAliq 	:= Str( nAliq ,TamSx3("F3_ALIQICM")[1],TamSx3("F3_ALIQICM")[2])   
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Faz a checagem para gravacao e nao duplicar linhas com a mesma  ณ
		//ณ aliquota. Neste caso os lancamentos F (Subst.Tribut.), N (nao   ณ
		//ณ incidencia de ICMS) e nX (Isento) deverao sair no mesmo registroณ
		//ณ do SF3                                                          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se jah existe registro no SF3 com a mesma data e PDVณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		
		bBloco := &(" {|x|	x[1][2]  + 	Dtos(x[6][2]) 			+ x[4][2]			+ 	x[3][2]	 "+cF3Pdv+;
						"==	cFilProc + 	Dtos(aMapaResumo[nX][1])+aMapaResumo[nX][6]	     		+	cSerie	     "+cMapaPdv+"	}" )

		If ( Ascan(aGravaMapRes, bBloco ) ) > 0
			lAchouF3 := .T.
		Else
			lAchouF3	:= .F.		
		EndIf
		                                                                     	
		bBloco := &("{|x|	 x[1][2]	+ 	Dtos(x[6][2])			+ 	x[4][2]				+ 	x[3][2]							+"+;
							"x[11][2]	+ 	x[12][2] 				+ 	x[9][2]				+ 	Str(x[20][2],nTamSx31,nTamSx32)	 "+;
							cF3Pdv 		+ 	"  ==	"+;
							"cFilProc 	+ 	Dtos(aMapaResumo[nX][1])+ 	aMapaResumo[nX][6]	       + 	cSerie	+"+;
							"cCliPad	+	cLojPad					+	cCFO				+	cAliq	 "+cMapaPdv+"	}")
		
		If ( nSeekF3 := Ascan(aGravaMapRes, bBloco ) ) > 0
			nLinF3 := nSeekF3

		Else

			nLinF3 := Len(aGravaMapRes) + 1       // Considera sempre a ultima posicao 

			nSeq := 0

			Aadd(aGravaMapRes,(MaXRCposMP()))

			aGravaMapRes[nLinF3][MR_F3_FILIAL][2] 	:= 	xFilial("SF3")
			aGravaMapRes[nLinF3][MR_F3_ESPECIE][2]	:=	"CF"

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe for o estado de Piaui, grava ECFณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If LjAnalisaLeg(18)[1]
				aGravaMapRes[nLinF3][MR_F3_ESPECIE][2]	:=	"ECF"
			Endif

			aGravaMapRes[nLinF3][MR_F3_SERIE][2]		:=	cSerie
			aGravaMapRes[nLinF3][MR_F3_NFISCAL][2]	:=	aMapaResumo[nX][6]
			aGravaMapRes[nLinF3][MR_F3_DOCOR][2] 		:= 	aMapaResumo[nX][6]
			aGravaMapRes[nLinF3][MR_F3_ENTRADA][2]	:= 	aMapaResumo[nX][1]
			aGravaMapRes[nLinF3][MR_F3_EMISSAO][2]	:= 	aMapaResumo[nX][1]
			aGravaMapRes[nLinF3][MR_F3_TIPO][2]		:= 	"L"
			aGravaMapRes[nLinF3][MR_F3_CFO][2]		:= 	cCFO
			aGravaMapRes[nLinF3][MR_F3_ESTADO][2]		:= 	cEstado
			aGravaMapRes[nLinF3][MR_F3_CLIEFOR][2]	:= 	cCliPad
			aGravaMapRes[nLinF3][MR_F3_LOJA][2]		:= 	cLojPad

			++nSeq

			If SF3->(ColumnPos("F3_IDENTFT")) > 0
				aGravaMapRes[nLinF3][MR_F3_IDENTFT][2] := StrZero(nSeq, 6)
			EndIf
			
			aGravaMapRes[nLinF3][MR_F3_PDV][2] := aMapaResumo[nX][7]
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe nao existir F3 com a mesma da e NF, grava o descontoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !lAchouF3
				aGravaMapRes[nLinF3][MR_F3_VALOBSE][2] := aMapaResumo[nX][10]
			Endif                                                         

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGravacao dos campos F3_NUMINI e F3_NUMFIM, cupom inicial e finalณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If SF3->(ColumnPos("F3_NUMINI")) > 0
				aGravaMapRes[nLinF3][MR_F3_NUMINI][2] := aMapaResumo[nX][8]
			Endif

			If SF3->(ColumnPos("F3_NUMFIM")) > 0
				aGravaMapRes[nLinF3][MR_F3_NUMFIM][2] := aMapaResumo[nX][9]
			Endif							

			If !Empty( aMapaResumo[nX][12] )
				aGravaMapRes[nLinF3][MR_F3_TIPO][2] 	:= "S"
				aGravaMapRes[nLinF3][MR_F3_CODISS][2]	:= SuperGetMV("MV_LJCISS",,"08915")
				aGravaMapRes[nLinF3][MR_F3_ALIQICM][2]	:= aMapaResumo[nX][2]
				aGravaMapRes[nLinF3][MR_F3_BASEICM][2] 	:= aGravaMapRes[nLinF3][MR_F3_BASEICM][2] + aMapaResumo[nX][12]
				aGravaMapRes[nLinF3][MR_F3_VALCONT][2] 	:= aGravaMapRes[nLinF3][MR_F3_VALCONT][2] + aMapaResumo[nX][12]
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSe arredonda o valor do ISSณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If lRndVlIss
					aGravaMapRes[nLinF3][MR_F3_VALICM][2] 	:= Round(aMapaResumo[nX][12] * aMapaResumo[nX][2]/100,2)
				Else
					aGravaMapRes[nLinF3][MR_F3_VALICM][2] 	:= NoRound(aMapaResumo[nX][12] * aMapaResumo[nX][2]/100,2)
				Endif

				If Empty(aGravaMapRes[nLinF3][MR_F3_OBSERV][2]) .AND. (nLegArt == 2 .OR. nLegArt == 3)
				   	aGravaMapRes[nLinF3][MR_F3_OBSERV][2] := aMapaResumo[nX][11]
				Endif   

			Endif
		Endif

		aGravaMapRes[nLinF3][MR_F3_VALCONT][2] := aGravaMapRes[nLinF3][MR_F3_VALCONT][2] + aMapaResumo[nX][4]

		If aMapaResumo[nX][3] $ "NI"

			aGravaMapRes[nLinF3][MR_F3_ISENICM][2] :=  aGravaMapRes[nLinF3][MR_F3_ISENICM][2] + aMapaResumo[nX][4]

		ElseIf aMapaResumo[nX][3] == "F"                // No caso de substituicao
			
			aAreaSF3 := SF3->(GetArea())
			nICMSRet := 0
			nBasSRet := 0    
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ No caso de substituicao precisa buscar os dados no SF3 referente ao dia ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						
			//Para ambientes com banco de dados relacional, serแ executada query para obter o valor
			If lTop
				cSelect:= '%SUM (SF3.F3_ICMSRET) AS F3_ICMSRET, SUM(SF3.F3_BASERET) AS F3_BASERET%'
				
				cWhere := "%"
				cWhere += "SF3.F3_FILIAL= '"+ xFilial('SF3')+ "' AND "
				cWhere += "SF3.F3_ENTRADA= '" + %Exp:DTOS(aMapaResumo[nX][1])% + "' AND "
				If lMTR930
					cWhere += "(SUBSTRING(SF3.F3_CFO,1,1)>='5' OR SF3.F3_FORMUL='S') AND "  
					cWhere += "SF3.F3_TIPO<>'S' AND "  
					cWhere += "NOT (SF3.F3_DTCANC<>'') AND "  
					cWhere += "SF3.F3_CODRSEF <> '102' AND " 
				Else					
					cWhere += "SF3.F3_ESPECIE<> 'NF' AND "					
				EndIf
				cWhere += "SF3.F3_ICMSRET > 0 AND "		
				cWhere += "%"						
				
				cAliasSF3	:= GETNEXTALIAS()
							
				BeginSql Alias cAliasSF3
	    			COLUMN F3_ENTRADA AS DATE
					SELECT
					%Exp:cSelect%
			
					FROM
					%Table:SF3% SF3
					WHERE
					%Exp:cWhere%
					SF3.%NotDel%
					
				EndSql
				
				DbSelectArea (cAliasSF3)
				(cAliasSF3)->(DbGoTop ())
				Do While !(cAliasSF3)->(Eof ())
					nICMSRet 	+= (cAliasSF3)->F3_ICMSRET
					nBasSRet	+= (cAliasSF3)->F3_BASERET				
						
					(cAliasSF3)->(DbSkip ())
				EndDo
				DbSelectArea (cAliasSF3)
				(cAliasSF3)->(DbCloseArea())
			Else			
		
				SF3->(dbSetOrder(1))    // F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM,5,2)
				SF3->(DbSeek(xFilial("SF3")+Dtos(aMapaResumo[nX][1]), .T.))
				While !SF3->(Eof()) .AND. SF3->F3_ENTRADA == aMapaResumo[nX][1]
					If Alltrim(SF3->F3_ESPECIE) <> "NF" .AND. SF3->F3_ICMSRET > 0
						nICMSRet += SF3->F3_ICMSRET
						nBasSRet += SF3->F3_BASERET
					EndIf	
					SF3->(DbSkip())
				End    
				RestArea(aAreaSF3)
			EndIF
							
	
			If SuperGetMV( "MV_LJSTMR", .F., .F. )

				aGravaMapRes[nLinF3][MR_F3_OUTRICM][2] := aGravaMapRes[nLinF3][MR_F3_OUTRICM][2] + aMapaResumo[nX][4]

			Else
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAnalisa se for a legislacao de Piaui e quando for Substituicao Tributariaณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If LjAnalisaLeg(18)[1]

					aGravaMapRes[nLinF3][MR_F3_ICMSRET][2] :=   0
					aGravaMapRes[nLinF3][MR_F3_OUTRICM][2] :=  aMapaResumo[nX][4]

				Else
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณAlimenta a base de ICMS e o ICMS reduzido que eh Valor Contab - Base Icmsณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					aGravaMapRes[nLinF3][MR_F3_BASEICM][2] 	:= aGravaMapRes[nLinF3][MR_F3_BASEICM][2] + Iif( aMapaResumo[nX][2] > 0, aMapaResumo[nX][4]-nICMSRet, 0 )					
					aGravaMapRes[nLinF3][MR_F3_BASERET][2]	:= aGravaMapRes[nLinF3][MR_F3_BASERET][2] + nBasSRet
					aGravaMapRes[nLinF3][MR_F3_VALICM][2] 	:= aGravaMapRes[nLinF3][MR_F3_VALICM][2]  + aMapaResumo[nX][5]
					aGravaMapRes[nLinF3][MR_F3_ICMSRET][2] 	:= aGravaMapRes[nLinF3][MR_F3_ICMSRET][2] + nICMSRet

				Endif
			Endif
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณOutros recebimentosณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ElseIf aMapaResumo[nX][3] == "O" 
			aGravaMapRes[nLinF3][MR_F3_OUTRICM][2] := aGravaMapRes[nLinF3][MR_F3_OUTRICM][2] + aMapaResumo[nX][4]
		Else
			aGravaMapRes[nLinF3][MR_F3_ALIQICM][2] := Val(MaXRPerAliq(aMapaResumo[nX][2]))
			aGravaMapRes[nLinF3][MR_F3_BASEICM][2] := aGravaMapRes[nLinF3][MR_F3_BASEICM][2] + aMapaResumo[nX][4]
			aGravaMapRes[nLinF3][MR_F3_VALICM][2] :=  aGravaMapRes[nLinF3][MR_F3_VALICM][2] + aMapaResumo[nX][5]
		Endif
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava o F3_ECF como tipo 1, que ้ tipo ECFณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If SF3->( ColumnPos ( "F3_ECF" ) ) > 0
			aGravaMapRes[nLinF3][MR_F3_ECF][2] := "1"
		Endif

		aGravaMapRes[nLinF3][MR_NUMNOTA][2]	:= StrZero(Val(aGravaMapRes[nLinF3][MR_F3_NFISCAL][2]),6)
		aGravaMapRes[nLinF3][MR_FILCORR][2]	:= cFilAnt
		
		// Preenche a coluna Observacoes  
		If Empty(aGravaMapRes[nLinF3][MR_F3_OBSERV][2])  .AND. (nLegArt == 2 .OR. nLegArt == 3)
			aGravaMapRes[nLinF3][MR_F3_OBSERV][2] := aMapaResumo[nX][11]
		EndIf  

	Next nX
Endif

aGravaMapRes := MaxRAjusMapRes(aGravaMapRes,cChamOrig)


Return aGravaMapRes

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMaXRPerAliบAutor  ณMicrosiga           บ Data ณ 09/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera o percentual de Aliquota em String                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe 	 ณ MaXRPerAliq(ExpN1)										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณExpN1 - Aliquota				                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpC1 - Aliquota				                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       |MATXRMP                                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MaXRPerAliq(nAliq)

Local cAliq   := ""   			// Percentual para retorno

Default nAliq := 0				// Valor da aliquota

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso seja fracionaria com 3 digitosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nAliq >= 100 .AND. nAliq <= 999

	cAliq := AllTrim(Str( nAliq ))
	cAliq := SubStr( cAliq,1,1 )+ "." + SubStr( cAliq,2 )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso seja fracionaria com 4 digitosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf nAliq >= 1000 .AND. nAliq <= 9999 

	cAliq := AllTrim(Str( nAliq ))
	cAliq := SubStr( cAliq,1,2 )+ "." + SubStr( cAliq,3 )

Else

	cAliq := AllTrim(Str( nAliq ))

EndIf

Return cAliq

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMaFisCpoMPบAutor  ณMicrosiga           บ Data ณ 09/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Campos a serem apresentados para Mapa Resumo         	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe 	 ณ MaXRCposMP()												  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ Nenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpA1 - Campos a serem gravados no SF3					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATXRMP                                                    บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MaXRCposMP()

Local aCposMapRes	:= {}					// Dados a serem gravados no Mapa Resumo

Aadd(aCposMapRes,{	"F3_FILIAL"	,	""		})	//[01]
Aadd(aCposMapRes,{	"F3_ESPECIE",	""		})	//[02]
Aadd(aCposMapRes,{	"F3_SERIE" 	,	""		})	//[03]
Aadd(aCposMapRes,{	"F3_NFISCAL", 	""		})	//[04]
Aadd(aCposMapRes,{	"F3_DOCOR"	, 	""		})	//[05]
Aadd(aCposMapRes,{	"F3_ENTRADA",	""		})	//[06]
Aadd(aCposMapRes,{	"F3_EMISSAO", 	""		})	//[07]
Aadd(aCposMapRes,{	"F3_TIPO"	,	""		})	//[08]
Aadd(aCposMapRes,{	"F3_CFO"	, 	""		})	//[09]
Aadd(aCposMapRes,{ 	"F3_ESTADO"	,   ""		})	//[10]                    
Aadd(aCposMapRes,{	"F3_CLIEFOR",	""		})	//[11]                    
Aadd(aCposMapRes,{	"F3_LOJA"	,	""		})	//[12]					
Aadd(aCposMapRes,{	"F3_IDENTFT",	""		})	//[13]
Aadd(aCposMapRes,{	"F3_PDV"	, 	""		})	//[14]
Aadd(aCposMapRes,{	"F3_VALOBSE",	0		})	//[15]
Aadd(aCposMapRes,{	"F3_NUMINI"	,	""		})	//[16]                       
Aadd(aCposMapRes,{	"F3_NUMFIM"	,	""		})	//[17]
Aadd(aCposMapRes,{	"F3_CODISS"	,	"" 		})	//[18]
Aadd(aCposMapRes,{	"F3_ECF"	,	""		})	//[19]
Aadd(aCposMapRes,{	"F3_ALIQICM",	0		})	//[20]
Aadd(aCposMapRes,{	"F3_BASEICM",	0		})	//[21]
Aadd(aCposMapRes,{	"F3_VALCONT", 	0		})	//[22]
Aadd(aCposMapRes,{	"F3_VALICM"	, 	0		})	//[23]
Aadd(aCposMapRes,{	"F3_OBSERV"	,	""		})	//[24]
Aadd(aCposMapRes,{	"F3_ISENICM",	0		})	//[25]
Aadd(aCposMapRes,{	"F3_OUTRICM",	0		})	//[26]
Aadd(aCposMapRes,{	"F3_ICMSRET",	0		})	//[27]
Aadd(aCposMapRes,{	"F3_REPROC"	,	""		})	//[28]
Aadd(aCposMapRes,{	"F3_DTCANC"	,  CtoD("")	})	//[29]
Aadd(aCposMapRes,{	"NUMNOTA"	,	""		})	//[30]
Aadd(aCposMapRes,{	"FILCORR"	,	""		})	//[31]
Aadd(aCposMapRes,{	"F3_BASERET",	0		})	//[32]

Return aCposMapRes

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMaXRExecArบAutor  ณMicrosiga           บ Data ณ 09/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria arquivo temporario para gravaResumo		           	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe 	 ณ MaXRExecArq(ExpN1,ExpC2)									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpN1 - 1 - Cria o arquivo | 2 - Delete o arquivo		  บฑฑ
ฑฑบParametrosณ ExpC2 - Nome do arquivo temporario						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpC1 - Nome do arquivo temporario criad					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATRISS, MATR908, MATR914, MATR990, MATRAPR                บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function MaXRExecArq(nOpcaoR,cArqTempMP)
Local aCampos	:= {}	// Campos a serem gerados
Local cRetTab	:= ""
	
Default cArqTempMP	:= ""	//Nome do arquivo temporario

//ณ Cria Arquivo Temporario ณ
If nOpcaoR == 1

	SX3->(dbSetOrder(1))
	SX3->(dbSeek("SF3"))
	While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == "SF3"
		AADD(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		SX3->(dbSkip())
	End
	
	//ณ Campo auxiliar para corrigir numeracao nas lacunasณ
	AADD(aCampos,{"NUMNOTA","C",6,0})
	AADD(aCampos,{"FILCORR","C",2,0})
	
	//ณPara inserir os periodos sem movimentoณ
	AADD(aCampos,{"SEMMOV" ,"L",1,0})
	
	//ณCria o arquivo temporarioณ
	If Empty(AllTrim(cArqTempMP))
		cArqTempMP := GetNextAlias()
	EndIf
	
	oTblTmp := LjCrTmpTbl(cArqTempMP,aCampos)
	
//ณDeleta o arquivo temporario criadoณ
ElseIf nOpcaoR == 2	
	If MatxTblTmp() <> NIL
		cRetTab		:= oTblTmp:GetAlias()
		cArqTempMP	:= cRetTab
	    oTblTmp:Delete()
	    oTblTmp := NIL
	EndIf
EndIf

Return cArqTempMP

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMaXRAddArqบAutor  ณMicrosiga           บ Data ณ 09/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Adiciona registros no arquivo temporario criado      	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe 	 ณ MaXRAddArq(ExpN1,ExpC2,ExpC3,ExpA4,ExpA5)				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpN1 - 1-Inclui informacoes da Query | 2-Somente Mapa Res บฑฑ
ฑฑบ          ณ ExpC2 - Arquivo temporario Criado						  บฑฑ
ฑฑบ          ณ ExpC3 - Alias da Query do relatorio						  บฑฑ
ฑฑบ          ณ ExpA4 - Campos da Query									  บฑฑ
ฑฑบ          ณ ExpA5 - Informacoes do Mapa Resumo						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpC1 - Nome do arquivo temporario com os registros		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       |MATR930,MATRISS,MATR908,MATR914,MATR920,MATR990,MATRAPR     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function MaXRAddArq(	nOpcaoR		,	cArqTempMP	,	cAlias	,	aCposTemp	,;
						aGravaMapRes,	cChave	)

Local nX 			:= 	0			// Contador de For
Local nY			:=	0			// Contador de For
Local nZ			:=	0			// Contador de For
Local cVar			:= 	""			// Campo a ser gravado
Local cEspF3		:= "CF"			// Especie para Cupom Fiscal

Default cArqTempMP	:= 	""			// Nome do arquivo temporario
Default aCposTemp 	:= {}			// Campos a serem gravados no temporario
Default cChave		:= ""			// Chave de ordenacao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se os campos vieram da chamada, ou devera pegarณ
//ณo default do SX3                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aCposTemp) <= 0

	SX3->(dbSetOrder(1))
	SX3->(dbSeek("SF3"))
	While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "SF3" 
		AADD(aCposTemp,{AllTrim(SX3->X3_CAMPO)})
		SX3->(dbSkip())
	End
	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSendo opcao 1: Siginifica que no relatorio de origem, nao  ณ
//ณtem arquivo temporario criado. A criacao foi realizada pelaณ
//ณMATXRMP                                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpcaoR == 1

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe for o estado de Piauiณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If LjAnalisaLeg(18)[1]
		cEspF3	:=	"ECF"
	Endif

	While !(cAlias)->(Eof())
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDesconsidera registros de Cupom Fiscal, ja que essas informacoesณ
		//ณserao do Mapa Resumo                                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Alltrim((cAlias)->F3_ESPECIE) <> cEspF3
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณInicia gravacao no temporario referente aos camposณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DbSelectArea(cArqTempMP)
		    RecLock(cArqTempMP,.T.)
		
			For nX := 1 To Len(aCposTemp)
		        
				cVar := Alltrim(aCposTemp[nX][1])
		
				Replace &(cArqTempMP + "->" + cVar) With &(cAlias + "->" + cVar)
				
			Next nX
		
			MsUnLock()
	
		EndIf
		
		(cAlias)->(DbSkip())
		
	End

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSendo 1/2: Significa que ja tem arquivo temporario criado   ณ
//ณ(independente se foi gerado pelo relatorio ou pela MATXRMP).ณ
//ณInclui os registros do Mapa Resumo                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpcaoR == 1 .OR. nOpcaoR == 2

	For nX := 1 To Len(aGravaMapRes)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInicia gravacao no temporario de acordo com a ณ
		//ณaGravaMapRes                                  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea(cArqTempMP)
	    RecLock(cArqTempMP,.T.)
	
		For nY := 1 To Len(aGravaMapRes[nX])
	
			For nZ := 1 To Len(aCposTemp)
				If AllTrim(aGravaMapRes[nX][nY][1]) == Alltrim(aCposTemp[nZ][1])
					
					cVar := AllTrim(aGravaMapRes[nX][nY][1])
					
					Replace &cVar With aGravaMapRes[nX][nY][2]
			
				EndIf		
			Next nZ
	
	    Next nY
	
		MsUnLock()
	
	Next nX

EndIf

If !Empty(cChave)
	IndRegua(cArqTempMP,cArqTempMP,cChave) 
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiciona no primeiro registro do temporarioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbGoTop()

Return cArqTempMP

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMaxRAjusMaบAutor  ณMicrosiga           บ Data ณ 09/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAltera o aGravaMapRes com as particularidades de cada Rel.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe 	 ณ MaxRAjusMapRes(ExpA1,ExpC2)								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpA1 - Informacoes do Mapa Resumo                         บฑฑ
ฑฑบ          ณ ExpC2 - Relatorio origem que esta sendo chamado            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpA1 - Informacoes a serem apresentadas no Relatorio	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       |MATXRMP                                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MaxRAjusMapRes(aGravaMapRes,cChamOrig)

Local nX 			:= 0						// Contador de For
Local nY 			:= 0						// Contador de For
Local nTamMapRes 	:= Len(aGravaMapRes)		// Informacoes do Mapa Resumo
Local aCloMapRes	:= aClone(aGravaMapRes)		// Clone das informacoes do Mapa Resumo

Do Case

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExecuta funcao quando relatorio for o MATR930 ou MATR921ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case cChamOrig $ "MATR930|MATR921"

		If nTamMapRes > 0
			
			aGravaMapRes := {}

				For nX := 1 To nTamMapRes
					
					If !Empty(aCloMapRes[nX][MR_F3_CODISS][2])
				      
						For nY := 1 To Len(aCloMapRes[nX])
							If ValType(aCloMapRes[nX][nY][2]) == "N"
								aCloMapRes[nX][nY][2] := 0
							EndIf		
					    Next nY
						
						aCloMapRes[nX][MR_F3_CFO][2] := "999"
						aCloMapRes[nX][MR_F3_OBSERV][2]	 := STR0001 + " " + aCloMapRes[nX][MR_F3_OBSERV][2] //"NT.FISCAL DE SERVICO"
			
					EndIf

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVerifica se destaca servicoณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If mv_par13 == 1 
						Aadd(aGravaMapRes,aCloMapRes[nX])	
					Else
						If Empty(aCloMapRes[nX][MR_F3_CODISS][2])
							Aadd(aGravaMapRes,aCloMapRes[nX])	
						EndIf
					EndIf

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVerifica se destaca o desconto na impressใoณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If mv_par14 <> 1 
						aCloMapRes[nX][MR_F3_VALOBSE][2] := 0
					EndIf

				Next nX

		EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExecuta funcao quando relatorio for o MATRISS,MATR908 ou MATR990ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case cChamOrig $ "MATRISS|MATR908|MATR990"

		If nTamMapRes > 0
			
			aGravaMapRes := {}

				For nX := 1 To nTamMapRes
					
					If !Empty(aCloMapRes[nX][MR_F3_CODISS][2]) .AND. ( Alltrim(aCloMapRes[nX][MR_F3_TIPO][2]) == "L" .OR. ;
						Alltrim(aCloMapRes[nX][MR_F3_TIPO][2]) == "S" ) .AND. SubStr(aCloMapRes[nX][MR_F3_CFO][2],1,1) >= "5"
						
						Aadd(aGravaMapRes,aCloMapRes[nX])	
                    
                    EndIf
					
				Next nX
		EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExecuta funcao para o MATR914ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case cChamOrig $ "MATR914"

		If nTamMapRes > 0
			
			aGravaMapRes := {}

			For nX := 1 To nTamMapRes
				
				If !Empty(aCloMapRes[nX][MR_F3_CODISS][2]) .AND. Alltrim(aCloMapRes[nX][MR_F3_TIPO][2]) == "S"
					
					Aadd(aGravaMapRes,aCloMapRes[nX])	
                    
                    EndIf
				
			Next nX

		EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExecuta funcao para a MATRAPR quando for so para ICMณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case cChamOrig == "F3_MATRAPR"

		If nTamMapRes > 0
			
			aGravaMapRes := {}

			For nX := 1 To nTamMapRes
				
				If Empty(aCloMapRes[nX][MR_F3_DTCANC][2])
					
					Aadd(aGravaMapRes,aCloMapRes[nX])	
                    
                    EndIf
				
			Next nX

		EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExecuta funcao para a MATRAPR quando for so para IPIณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case cChamOrig == "IP_MATRAPR"

		If nTamMapRes > 0
			
			aGravaMapRes := {}

			For nX := 1 To nTamMapRes
				
				If Empty(aCloMapRes[nX][MR_F3_DTCANC][2]) .AND. Alltrim(aCloMapRes[nX][MR_F3_TIPO][2]) <> "S"
					
					Aadd(aGravaMapRes,aCloMapRes[nX])	
                    
                    EndIf
				
			Next nX

		EndIf
EndCase                                        

Return aGravaMapRes

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMaXRCposQrบAutor  ณMicrosiga           บ Data ณ 09/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica quais campos faram parte do Temporario.     	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe 	 ณ MaXRCposQry(ExpC1)										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 - String com os campos								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpA1 - Campos a serem gravados no SF3					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       |MATR930, FISXAPUR                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function MaXRCposQry(cQuery)

Local aCposTemp := {}		// Campos temporarios
Local nPos		:= 0		// Posicao de busca no Array

Default cQuery 	:= ""		// Campos a serem criados no temporario

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExclui possiveis "sujeiras" da stringณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery := Alltrim(StrTran( cQuery, "SELECT"					, "" ))
cQuery := Alltrim(StrTran( cQuery, "R_E_C_N_O_ SF3RECNO"	, "" ))
cQuery := Alltrim(StrTran( cQuery, "D_E_L_E_T_"				, "" ))
cQuery := Alltrim(StrTran( cQuery, "ORDER BY"				, "" ))
cQuery := Alltrim(StrTran( cQuery, "WHERE"					, "" ))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica conteudo da cQuery para somente retornar os camposณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While Len(cQuery) <> 0
	If (nPos:=At(",",cQuery)) <> 0
		If !Empty(Subs(cQuery, 1, nPos-1))
			aAdd(aCposTemp, { Alltrim(Subs(cQuery, 1, nPos-1) ) } )
		EndIf
		cQuery := Subs(cQuery, nPos+1 )
	Else
		If Left(cQuery,1)=='"'
			If !Empty(Subs(cQuery, 1, Len(cQuery)-0))
				aAdd(aCposTemp, { Alltrim(Subs(cQuery, 1, Len(cQuery)-0))} )
			EndIf
		Else
			If !Empty(cQuery)
				aAdd(aCposTemp, {Alltrim(cQuery)} )
			EndIf
		EndIf
		cQuery := ""
	EndIf
End

Return aCposTemp

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMatxRValPeบAutor  ณMicrosiga           บ Data ณ 09/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se pode utilizar a pergunta dos relatorios           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe 	 ณ MatrxRValPer()											  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ Nil                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpL1 - Autoriza											  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       |MATXRMP                                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function MatxRValPer(nPergRel)

Local lRet 		:= .T.										// Retorno da funcao
Local lFisLivro := (SuperGetMV("MV_LJLVFIS",,1) == 2)		// Utiliza novo conceito para geracao do SF3

If !lFisLivro .AND. nPergRel == 1
	//"Para utiliza็ใo da pergunta 'Imprime Mapa Resumo', necessแrio seguir o Boletim Tecnico 'LOJA - Escrituracao do livro fiscal de saida'."
	MsgAlert(STR0003)
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} MatxTblTmp
Para manter o objeto de tabela temporแria 

@author  Julio.Nery
@version P12.1.17
@since  07/11/2018
@return  Nil
/*/
//-------------------------------------------------------------------
Function MatxTblTmp()
Return oTblTmp