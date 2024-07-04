#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FISR080.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR080
Relatório de Conferência de Impostos Federais Retidos no Faturamento

@author  Fabio V Santana
@version P12
@since   16/06/2015
/*/
//-------------------------------------------------------------------
Function FISR080()

Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

Private aPisCof   := {}
Private cAliasQry := GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao criada para trocar o grupo de perguntas - FISR080 por FISR08A ³  
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lVerpesssen
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros    ³
	//³ mv_par01     // Seleciona tipo	      	³  
	//³ mv_par02     // Mes Proces  PIS/COFINS  ³  
	//³ mv_par03     // Ano Proces  PIS/COFINS	³  
	//³ mv_par04     // Data de  IR/CSLL/INSS	³  
	//³ mv_par05     // Data Ate IR/CSLL/INSS	³  
	//³ mv_par06     // Seleciona Filiais    	³  
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte( "FISR08A", .F. )
	ReportDef()            
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Criacao dos componentes de impressao

@author  Fabio V Santana
@version P12
@since   01/06/2015
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport   := Nil
Local oSection1 := Nil
Local cTitle    := STR0001 // "Relatório de Conferência de Impostos Federais Retidos no Faturamento

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("FISR080",cTitle,"FISR08A", {|oReport| ReportPrint(oReport)},STR0002 ) //"Conferência das informações dos títulos de PIS COFINS que compõem o Bloco F600 do SPED Contribuições e Ficha 57 DIPJ"
oReport:SetLandscape()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection1 := TRSection():New(oReport,STR0001,{"SE1","TRB","SA1","SE5"}) //Relatório de Conferência de Impostos Federais Retidos no Faturamento

oSection1:SetHeaderPage()
oSection1:SetNoFilter("SE1")
oSection1:SetNoFilter("SA1")
oSection1:SetNoFilter("SE5")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao das Secoes do Relatorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
//ÚÄÄÄÄ¿
//³F600³
//ÀÄÄÄÄÙ		
TRCell():New(oSection1,"FILIAL"    	 ,NIL,STR0022,PesqPict("SE5","E5_FILIAL") 	,TamSX3("E5_NATUREZ")[1],/*lPixel*/,,/*cAligne*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/	)	// [01] Filial              
TRCell():New(oSection1,"NOME_FILIAL" ,NIL,STR0023,/*Picture*/    	                ,40                     ,/*lPixel*/,,/*cAligne*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/	)	// [01] Nome da Filial      
TRCell():New(oSection1,"NATUREZA"	 ,"aPISCof",STR0003,PesqPict("SE5","E5_NATUREZA")	,TamSX3("E5_NATUREZ")[1],/*lPixel*/,,/*cAligne*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/	)	// [01] Natureza da Retenção
TRCell():New(oSection1,"DT_RETENCAO" ,"aPISCof",STR0004,								,12						,/*lPixel*/,,/*cAligne*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/)	// [02] Data da Retenção
TRCell():New(oSection1,"BASE_CALCULO","aPISCof",STR0005,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,/*lPixel*/,,/*cAligne*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/	)	// [03] Base de Cálculo da Retenção
TRCell():New(oSection1,"VALOR_TOTAL" ,"aPISCof",STR0006,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,/*lPixel*/,,/*cAligne*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/	)	// [04] Valor Total Retido na Fonte
TRCell():New(oSection1,"COD_RECEITA" ,"aPISCof",STR0007,/*Picture*/						,4						,/*lPixel*/,,/*cAligne*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/	)	// [05] Código da Receita
TRCell():New(oSection1,"IND_NATUREZA","aPISCof",STR0008,/*Picture*/						,1						,/*lPixel*/,,/*cAligne*/,/*lLineBreak*/,"RIGHT"	)// [06] Indicador da Natureza da Receita
TRCell():New(oSection1,"CNPJ"		 ,"aPISCof",STR0009,PesqPict("SA1","A1_CGC")		,TamSX3("A1_CGC")[1]+15	,/*lPixel*/,,/*cAligne*/,/*lLineBreak*/,"CENTER")// [07] CNPJ
TRCell():New(oSection1,"PIS_RETIDO"	 ,"aPISCof",STR0010,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,/*lPixel*/,,/*cAligne*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/	)	// [08] PIS Retido
TRCell():New(oSection1,"COF_RETIDO"	 ,"aPISCof",STR0011,PesqPict("SE5","E5_VALOR")		,TamSX3("E5_VALOR")[1]	,/*lPixel*/,,/*cAligne*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/	)	// [09] COFINS Retido
TRCell():New(oSection1,"INDIC_DECL"	 ,"aPISCof",STR0012,								,1						,/*lPixel*/,,/*cAligne*/,/*lLineBreak*/,"RIGHT"/*cHeaderAlign*/)	// [10] Indicador de Pessoa Jurídica Declarante
	
//ÚÄÄÄÄ¿
//³DIPJ³
//ÀÄÄÄÄÙ	
TRCell():New(oSection1,"TRB_FILIAL"	,"TRB"	,STR0022 ,PesqPict("SE1","E1_FILIAL") ,TamSX3("E1_FILIAL")[1]		,/*lPixel*/	)	//	FILIAL
TRCell():New(oSection1,"TRB_NOMEFL"	,"TRB"	,STR0023 ,/*Picture*/                 ,40                   		,/*lPixel*/	)	//	NOME DA FILIAL
TRCell():New(oSection1,"TRB_CLI" 	,"TRB"	,STR0013 ,PesqPict("SE1","E1_CLIENTE"),TamSX3("E1_CLIENTE")[1]		,/*lPixel*/	)	//	CLIENTE
TRCell():New(oSection1,"TRB_LOJA"	,"TRB"	,STR0014 ,PesqPict("SE1","E1_LOJA")   ,TamSX3("E1_LOJA")[1]		    ,/*lPixel*/	)	//	LOJA
TRCell():New(oSection1,"TRB_NOME"	,"TRB"	,STR0015 ,PesqPict("SE1","E1_NOMCLI") ,TamSX3("E1_NOMCLI")[1]+10	,/*lPixel*/	)	//	RAZÃO SOCIAL
TRCell():New(oSection1,"TRB_CNPJ"   ,"TRB"	,STR0009 ,PesqPict("SA1","A1_CGC")	  ,TamSX3("A1_CGC")[1]+15		,/*lPixel*/	)	//	CNPJ
TRCell():New(oSection1,"TRB_CODRET"	,"TRB"	,STR0016 ,/*Picture*/				  ,4							,/*lPixel*/	)	//	COD. RETENÇÃO
TRCell():New(oSection1,"TRB_VLRRET"	,"TRB"	,STR0017 ,PesqPict("SE1","E1_VALOR")  ,TamSX3("E1_VALOR")[1]		,/*lPixel*/	)	//	VALOR RETIDO
TRCell():New(oSection1,"TRB_VLRPGO"	,"TRB"	,STR0018 ,PesqPict("SE1","E1_VALOR")  ,TamSX3("E1_VALOR")[1]		,/*lPixel*/	)	//	VALOR RETIDO
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao dos Totalizadores ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
oSection1 :SetTotalInLine(.F.)
TRFunction():New(oSection1:Cell("BASE_CALCULO")	,NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 
TRFunction():New(oSection1:Cell("VALOR_TOTAL")	,NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 
TRFunction():New(oSection1:Cell("PIS_RETIDO") 	,NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 
TRFunction():New(oSection1:Cell("COF_RETIDO") 	,NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.)
TRFunction():New(oSection1:Cell("TRB_VLRPGO") 	,NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 
TRFunction():New(oSection1:Cell("TRB_VLRRET") 	,NIL,"SUM",,,/*cPicture*/,/*uFormula*/,.T.,.T.) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apresenta a tela de impressão ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Relatório de Conferência de Impostos Federais Retidos no Faturamento

@author  Fabio V Santana
@version P12
@since   01/06/2015
/*/
//-------------------------------------------------------------------
Static Function ReportPrint( oReport )

Local oSection1:= oReport:Section(1)
Local cMesRef  := MV_PAR02
Local cAnoRef  := MV_PAR03

Local aRet     := {}
Local aTrbs	   := CriaTrb()
Local cMV_INSS := AllTrim (GetNewPar ("MV_INSDIPJ",""))
Local cMV_CSDI := Alltrim (GetNewPar ("MV_CSLDIPJ",""))
Local cMv_IRDI := Alltrim (GetNewPar ("MV_IRDIPJ",""))
Local dDataDe  := MV_PAR04
Local dDataAte := MV_PAR05
Local cValTit  := 0
Local nIRRF	   := 0   
Local nCSLL    := 0   
Local nTotIr   := 0   
Local nINSS    := 0   
Local nPos	   := 0
Local nX       := 0
Local cFilBak   := cFilAnt
Local aFilsCalc := {}
Local nForFilial:= 0
Local lSelFil 	:= ValType(MV_PAR06) == "N"
Local aAreaSM0  := SM0->(GetArea())
Local lPccBxCr		:= FPccBxCr(.T.)

IF lSelFil .And. MV_PAR06 == 1
	aFilsCalc := MatFilCalc(.T.)
Else
	aFilsCalc := {{.T.,cFilAnt}}
EndIf

	For nForFilial := 1 To Len(aFilsCalc)

	If aFilsCalc[ nForFilial, 1 ]
		cFilAnt := aFilsCalc[ nForFilial, 2 ]
        SM0->( DbSetOrder(1) )
		SM0->( DbSeek( cEmpAnt + cFilAnt ) )

		If MV_PAR01 == 4 //PIS/COFINS
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Desabilito as celulas nao utilizadas neste layout ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DisableCell(oSection1,1)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³TRPosition() e necessario para que o usuario ao utilizar o relatorio possa acrescentar qualquer ³
			//³coluna das tabelas que compoem a secao.                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TRPosition():New(oSection1,"SE5",5,{|| xFilial("SE5") + SE5->(E5_LOTE + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + DtoS(E5_DATA)) })
			TRPosition():New(oSection1,"SA1",1,{|| xFilial("SA1") + SE5->(E5_CLIENTE + E5_LOJA)})
			TRPosition():New(oSection1,"SE1",1,{|| SE5->(E5_FILIAL + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO)})
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Utilizo a funcao FINSPDF600 (nMesRef,nAnoRef) para gerar os dados de conferencia de Pis/Cofins  ³
			//³Nesse caso so utilizamos o paramentro MV_PAR04 para gerar os dados, que sao mensais             ³
			//³Inicio do Fluxo para impressão de PIS/Cofins             											 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aPISCof 	:= FinSpdF600(Val(cMesRef),Val(cAnoRef))
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicio da Impressão ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oSection1:Init()
			
			For nX := 1 to Len(aPISCof)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Aguarde, Gerando Relatório ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IncProc(STR0019)
				
				If oReport:Cancel()
					Exit
				EndIf
				
				dbSelectArea("SE5")
				SE5->(dbGoto(aPISCof[nX][11]))
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³adiciono a natureza financeira ao ultimo elemento do array [09] ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aPISCof[nX],SE5->E5_NATUREZ)
		
						oSection1:Cell("FILIAL")		:SetBlock( {|| SM0->M0_CODFIL}   										) 	// Filial
						oSection1:Cell("NOME_FILIAL")	:SetBlock( {|| SM0->M0_FILIAL} 						   					) 	// Nome Filial
				oSection1:Cell("NATUREZA")		:SetBlock( {|| aPISCof[nX][13]} 										) 	// aPISCof[nX,13] Natureza da Retenção
				oSection1:Cell("DT_RETENCAO")	:SetBlock( {|| Stod(aPISCof[nX][02])}									)	// aPISCof[nX,02] Data da Retenção
				oSection1:Cell("BASE_CALCULO")	:SetBlock( {|| aPISCof[nX][03]} 										) 	// aPISCof[nX,03] Base de Cálculo da Retenção
				oSection1:Cell("VALOR_TOTAL")	:SetBlock( {|| aPISCof[nX][04]} 										) 	// aPISCof[nX,04] Valor Total Retido na Fonte
				oSection1:Cell("COD_RECEITA")	:SetBlock( {|| aPISCof[nX][12]} 										) 	// aPISCof[nX,12] Código da Receita
				oSection1:Cell("IND_NATUREZA")	:SetBlock( {|| aPISCof[nX][05]} 										)	// aPISCof[nX,05] Indicador da Natureza da Receita
				oSection1:Cell("CNPJ")			:SetBlock( {|| aPISCof[nX][06]} 										)	// aPISCof[nX,06] CNPJ
				oSection1:Cell("PIS_RETIDO")	:SetBlock( {|| aPISCof[nX][07]} 										) 	// aPISCof[nX,07] PIS Retido
				oSection1:Cell("COF_RETIDO")	:SetBlock( {|| aPISCof[nX][08]}											) 	// aPISCof[nX,08] COFINS Retido
				oSection1:Cell("INDIC_DECL")	:SetBlock( {|| IIf( aPISCof[nX][09] <> "0" , STR0020 , STR0021 ) }	)	// aPISCof[nX,09] Indicador de Pessoa Jurídica Declarante
				
				oReport:IncMeter()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Imprime Dados³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oSection1:PrintLine()
				
			Next nX
			
			oSection1:Finish()
		Else
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Desabilito as celulas nao utilizadas neste layout ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DisableCell(oSection1,2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³TRPosition() e necessario para que o usuario ao utilizar o relatorio possa acrescentar qualquer ³
			//³coluna das tabelas que compoem a secao.                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TRPosition():New(oSection1,"SA1",1,{|| xFilial("SA1") + TRB->TRB_CLI + TRB->TRB_LOJA})
			TRPosition():New(oSection1,"SE1",1,{|| TRB->TRB_FILIAL + TRB->TRB_PREFIX + TRB->TRB_NUM + TRB->TRB_PARCEL + TRB->TRB_TIPO })
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicia o Fluxo do Relatorio 																				 ³
			//³Utilizo a funcao GetQuery (dDataDe,dDataAte)                                                    ³
			//³Inicio do Fluxo para impressão de CSLL, IRRF, INSS                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cAliasQry := GetQuery(MV_PAR04,MV_PAR05)
			
			dbSelectArea( cAliasQry )
			(cAliasQry)->(DbGoTop())
			
			While  !(cAliasQry)->(Eof())
				
				nIRRF := 0
				nCSLL := 0
				nINSS := 0
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³IRRF /CSLL /INSS³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				SumAbatRec((cAliasQry)->E1_PREFIXO,(cAliasQry)->E1_NUM,(cAliasQry)->E1_PARCELA,(cAliasQry)->E1_MOEDA,"V",(cAliasQry)->E1_BAIXA,@nIRRF,@nCSLL,@nINSS,cAliasQry,lPccBxCr)		
			 	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Faco a validacao da opcao selecionada no MV_PAR01³
				//³1 = IRRF                                         ³
				//³2 = CSLL                                         ³
				//³3 = INSS                                         ³		
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				If (nIRRF > 0 .And. MV_PAR01 == 1) .Or. (nCSLL > 0 .And. MV_PAR01 == 2) .Or. (nINSS > 0 .And. MV_PAR01 == 3)
								
					aRet	:=	array(2)
		
					If MV_PAR01 == 1     //IR
						aRet[1]	:= {IIf(SE1->(FieldPos("E1_CDRETIR"))>0 .And. !Empty((cAliasQry)->E1_CDRETIR), (cAliasQry)->E1_CDRETIR, IIf(!Empty(cMV_IRDI), cMV_IRDI, "1708")),nIRRF}
					ElseIf MV_PAR01 == 2 //CSLL
						aRet[1]	:= {IIf(SE1->(FieldPos("E1_CDRETCS"))>0 .And. !Empty((cAliasQry)->E1_CDRETCS), (cAliasQry)->E1_CDRETCS, IIf(!Empty(cMV_CSDI), cMV_CSDI, "5952")),nCSLL}			
					Else 		 	     //INSS
						aRet[1]	:= {cMV_INSS,nINSS}			
					EndIf
					
					RecLock("TRB", .T.)
					TRB->TRB_CLI	:= (cAliasQry)->E1_CLIENTE
					TRB->TRB_LOJA	:= (cAliasQry)->E1_LOJA
					TRB->TRB_NOME	:= (cAliasQry)->A1_NOME
					TRB->TRB_CNPJ	:= (cAliasQry)->A1_CGC
					TRB->TRB_ANO	:=	StrZero(Year(MV_PAR05),4)
					TRB->TRB_CODRET	:=	aRet[1][1]
		
					TRB->TRB_VLRPGO += (cAliasQry)->E1_VLCRUZ
		          
					TRB->TRB_VLRRET += aRet[1][2]
					
					//Campos utilizados para posicionamento
					TRB->TRB_FILIAL	:= (cAliasQry)->E1_FILIAL
					TRB->TRB_PREFIX	:= (cAliasQry)->E1_PREFIXO
					TRB->TRB_NUM	:= (cAliasQry)->E1_NUM
					TRB->TRB_PARCEL	:= (cAliasQry)->E1_PARCELA
					TRB->TRB_TIPO	:= (cAliasQry)->E1_TIPO
					TRB->TRB_NOMEFL := SM0->M0_FILIAL
				Endif			
				( cAliasQry )->( dbSkip() )
			EndDo
			(cAliasQry)->( DbCloseArea() )
		EndIf
	EndIf
Next nForFilial
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio da Impressão ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1:Init()
	
	TRB->(DbGoTop ())

	While !(TRB->(Eof()))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aguarde, Gerando Relatório ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		IncProc(STR0019)
		
		If oReport:Cancel()
			Exit
		EndIf
		
		oReport:IncMeter()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime Dados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection1:PrintLine()

		TRB->(DbSkip ())
	EndDo	
	
	oSection1:Finish()
	


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Removo todos os temporarios criados pela funcao CriaTrb.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len (aTrbs)
	DbSelectArea (aTrbs[nX][1])
	(aTrbs[nX][1])->(DbCloseArea ())
	Ferase (aTrbs[nX][2]+GetDBExtension ())
	Ferase (aTrbs[nX][2]+OrdBagExt ())
Next (nX)

cFilAnt := cFilBak
RestArea(aAreaSM0)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DisableCell
Desabilita as celulas não utilizadas

@author  Fabio V Santana
@version P12
@since   01/06/2015
/*/
//-------------------------------------------------------------------
Static Function DisableCell(oSection1,nOpc)

If nOpc == 1
	oSection1:Cell("TRB_FILIAL"):Disable()
	oSection1:Cell("TRB_NOMEFL"):Disable()
	oSection1:Cell("TRB_CLI"):Disable()
	oSection1:Cell("TRB_LOJA"):Disable()
	oSection1:Cell("TRB_NOME"):Disable()
	oSection1:Cell("TRB_CNPJ"):Disable()
	oSection1:Cell("TRB_CODRET"):Disable()
	oSection1:Cell("TRB_VLRRET"):Disable()
	oSection1:Cell("TRB_VLRPGO"):Disable()
Else
	oSection1:Cell("FILIAL"):Disable()
	oSection1:Cell("NOME_FILIAL"):Disable()
	oSection1:Cell("NATUREZA"):Disable()
	oSection1:Cell("DT_RETENCAO"):Disable()
	oSection1:Cell("BASE_CALCULO"):Disable()
	oSection1:Cell("VALOR_TOTAL"):Disable()
	oSection1:Cell("COD_RECEITA"):Disable()
	oSection1:Cell("IND_NATUREZA"):Disable()
	oSection1:Cell("CNPJ"):Disable()
	oSection1:Cell("PIS_RETIDO"):Disable()
	oSection1:Cell("COF_RETIDO"):Disable()
	oSection1:Cell("INDIC_DECL"):Disable()
EndIf

Return (Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTrb
Cria arquivo de trabalho

@author  Fabio V Santana
@version P12
@since   01/06/2015
/*/
//-------------------------------------------------------------------
Static Function CriaTrb()
	Local	aRet		:=	{}
	Local	aTrb		:=	{}
	Local	cAliasTrb	:=	""
	//
	aTrb	:=	{}
	//
	aAdd (aTrb, {"TRB_CLI"   ,"C",TamSX3("A2_COD")[1] ,TamSX3("A2_COD")[2]})
	aAdd (aTrb, {"TRB_LOJA"  ,"C",TamSX3("A2_LOJA")[1],TamSX3("A2_LOJA")[2]})
	aAdd (aTrb, {"TRB_NOME"  ,"C",TamSX3("A1_NOME")[1],TamSX3("A1_NOME")[2]})
	aAdd (aTrb, {"TRB_CNPJ"  ,"C",TamSX3("A1_CGC")[1] ,TamSX3("A1_CGC")[2]})
	aAdd (aTrb, {"TRB_ANO"   ,"C",04,0})
	aAdd (aTrb, {"TRB_CODRET","C",04,0})
	aAdd (aTrb, {"TRB_VLRPGO","N",14,2})
	aAdd (aTrb, {"TRB_VLRRET","N",14,2})
	//		
	aAdd (aTrb, {"TRB_FILIAL","C",TamSX3("E1_FILIAL")[1] ,TamSX3("E1_FILIAL")[2]})
	aAdd (aTrb, {"TRB_NOMEFL","C",40,0})
	aAdd (aTrb, {"TRB_PREFIX","C",TamSX3("E1_PREFIXO")[1],TamSX3("E1_PREFIXO")[2]})	
	aAdd (aTrb, {"TRB_NUM"	 ,"C",TamSX3("E1_NUM")[1]	 ,TamSX3("E1_NUM")[2]})	
	aAdd (aTrb, {"TRB_PARCEL","C",TamSX3("E1_PARCELA")[1],TamSX3("E1_PARCELA")[2]})	
	aAdd (aTrb, {"TRB_TIPO"	 ,"C",TamSX3("E1_TIPO")[1]	 ,TamSX3("E1_TIPO")[2]})	
		
	//
	cAliasTrb	:=	CriaTrab (aTrb)
	DbUseArea (.T., __LocalDriver, cAliasTrb, "TRB")
	IndRegua ("TRB", cAliasTrb,"TRB_FILIAL+TRB_ANO+TRB_CLI+TRB_LOJA+TRB_CODRET")
	//
	aAdd (aRet, {"TRB", cAliasTrb})
Return (aRet)	

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQuery
Cria arquivo de trabalho

@author  Fabio V Santana
@version P12
@since   01/06/2015
/*/
//-------------------------------------------------------------------
Static Function GetQuery(dDataDe, dDataAte)

Local cWhere		:= ""
Local cCampos		:= ""
Local cFrom			:= "'
Local lFWCodFil 	:= FindFunction("FWCodFil")
Local lSe1MsFil		:= SE1->(FieldPos("E1_MSFIL")) > 0
Local lSe5MsFil		:= SE5->(FieldPos("E5_MSFIL")) > 0
Local lUnidNeg 		:= Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local cFilSe5		:= xFilial("SE5")
Local cFilSe1		:= xFilial("SE1")
Local cSE1Fil		:=  ""

If lUnidNeg
	cFilSe5	:= SM0->M0_CODFIL 
	cFilSe1 := SM0->M0_CODFIL 
Else
	cFilSe5	:= xFilial("SE5")
	cFilSe1 := xFilial("SE1")
Endif

If !Empty( Iif( lUnidNeg, FWFilial("SE1") , xFilial("SE1") ) )
	cSE1Fil 	:= "% SE1.E1_FILIAL = '"  + xFilial("SE1") + "'  %"
Else
	If lSe1MsFil		
		cSE1Fil 	:= "% SE1.E1_MSFIL = '" + Iif(lUnidNeg, cFilSe1, cFilAnt) + "'  %"		
	Else	
		cSE1Fil 	:= "% SE1.E1_FILORIG = '" + Iif(lUnidNeg, cFilSe1, cFilAnt) + "'  %"	
	Endif	
EndIf  

Default dDataDe 	 := dDataBase 
Default dDataAte	 := dDataBase

cWhere	:= "%SE1.E1_TIPO NOT IN('"	+  MVABATIM+ "," +MVIRABT+ "," +MVINABT+ "," +MVCSABT+ "," +MVCFABT+ "," +MVPIABT + "') AND "

If MV_PAR01 = 3 // INSS
	cWhere += "  SE1.E1_EMISSAO BETWEEN '" + DToS(MV_PAR04) + "' AND '" + DToS(MV_PAR05) +"'%"
	cFrom   := RetSqlName("SE1")+ " SE1, " +  RetSqlName("SA1")+ " SA1 "
	
Else
	cFrom   := RetSqlName("SE1")+ " SE1, " +  RetSqlName("SA1")+ " SA1, " + RetSqlName("SE5")+ " SE5 "
	cCampos:= ", SE5.E5_FILIAL, SE5.E5_NATUREZ, SE5.E5_PREFIXO,SE5.E5_NUMERO,SE5.E5_PARCELA,SE5.E5_TIPO, SE5.E5_CLIFOR, SE5.E5_LOJA, "
	cCampos+= "SE5.E5_RECPAG, SE5.E5_SITUACA,SE5.E5_TIPODOC, SE5.E5_DTDISPO"
	
	If !Empty( Iif( lUnidNeg, FWFilial("SE5") , xFilial("SE5") ) )
		cWhere 	+= "SE5.E5_FILIAL = '"  + xFilial("SE5") + "' AND "
	Else
		If lSe5MsFil
			cWhere 	+= "SE5.E5_MSFIL = '" + Iif(lUnidNeg, cFilSe5, cFilAnt) + "' AND "					
		Else	
			cWhere 	+= "SE5.E5_FILORIG = '" + Iif(lUnidNeg, cFilSe5, cFilAnt) + "' AND "	
		Endif	
	EndIf 
	
	cWhere += "SE5.E5_NATUREZ = SE1.E1_NATUREZ AND "
	cWhere += "SE5.E5_PREFIXO = SE1.E1_PREFIXO AND "
	cWhere += "SE5.E5_NUMERO  = SE1.E1_NUM AND "
	cWhere += "SE5.E5_PARCELA = SE1.E1_PARCELA AND "
	cWhere += "SE5.E5_TIPO    = SE1.E1_TIPO AND "
	cWhere += "SE5.E5_CLIFOR  = SE1.E1_CLIENTE AND "
	cWhere += "SE5.E5_LOJA    = SE1.E1_LOJA AND "
	cWhere += "SE5.E5_RECPAG  = 'R' AND "
	cWhere += "SE5.E5_SITUACA<> 'C' AND "
	cWhere += "SE5.E5_TIPODOC IN ('BA','VL','BL','V2') AND "
	cWhere += "SE5.E5_DTDISPO BETWEEN '" + DToS(MV_PAR04) + "' AND '" + DToS(MV_PAR05) +"' AND "
	cWhere += "SE5.D_E_L_E_T_ = ' ' "

EndIf

// Só considerar titulos que tenham sido baixados totalmente pois eh neste momento em que ocorre
// a compensacao dos tributos (Baixa dos títulos IR-, IN- e CS-).

If MV_PAR01 <> 3
	cWhere += " AND SE1.E1_SALDO = 0 %"
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Campos que serao adicionados a query somente se existirem na base³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SE1->(FieldPos("E1_CDRETIR"))>0                                          
	cCampos += ", SE1.E1_CDRETIR" 
Endif

If SE1->(FieldPos("E1_CDRETCS"))>0
	cCampos += ", SE1.E1_CDRETCS" 
EndIf
 
If Empty(cCampos)
	cCampos := "%%"
Else       
	cCampos := "% " + cCampos + " %"
Endif 

 
If Empty(cFrom)
	cFrom := "%%"
Else       
	cFrom := "% " + cFrom + " %"
Endif 

BEGINSQL ALIAS cAliasQry
	
	COLUMN E1_EMISSAO AS DATE
	COLUMN E1_BAIXA   AS DATE
	
	SELECT DISTINCT
		SE1.E1_FILIAL, 
		SE1.E1_PREFIXO, 
		SE1.E1_NUM, 
		SE1.E1_PARCELA, 
		SE1.E1_TIPO, 
		SE1.E1_NATUREZ, 
		SE1.E1_CLIENTE ,
		SE1.E1_LOJA, 
		SE1.E1_EMISSAO, 
		SE1.E1_VALOR, 
		SE1.E1_VLCRUZ, 
		SE1.E1_BAIXA, 
		SE1.E1_BASECSL,
		SE1.E1_CSLL,
		SE1.E1_BASEIRF, 
		SE1.E1_IRRF, 
		SE1.E1_BASEINS, 
		SE1.E1_INSS, 
		SE1.E1_MSFIL, 
		SE1.E1_MOEDA, 
		SE1.E1_CODISS, 
		SE1.E1_ISS,
		SA1.A1_NOME, 
		SA1.A1_CGC,
		SA1.A1_PESSOA 
		%Exp:cCampos%
			
	FROM %Exp:cFrom%
	
	WHERE
		
		%Exp:cSE1Fil%
		AND SE1.%NOTDEL%
		AND SA1.A1_FILIAL = %xFilial:SA1%
		AND SA1.A1_COD = SE1.E1_CLIENTE 
		AND SA1.A1_LOJA = SE1.E1_LOJA 
		AND SA1.A1_PESSOA = %Exp:'J'%
		AND SA1.%NotDel%

		AND %Exp:cWhere%                 
		
	ORDER BY SE1.E1_FILIAL,SE1.E1_CLIENTE,SE1.E1_LOJA,SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO	

ENDSQL 

Return (cAliasQry)


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SumAbatRec

Soma titulos de abatimento relacionado a um determinado titulo a receber.
IRRF e CSLL

@Author	Fabio V Santana
@since 22/06/2015
/*/
//-----------------------------------------------------------------------------------------------------
Static Function SumAbatRec(cPrefixo,cNumero,cParcela,nMoeda,cCpo,dData,nTotIrAbt,nTotCsAbt,nTotInAbt,cAlias,lPccBxCr) 

Local cCliLj     := ""
Local lTitpaiSE1 := (SE1->(FieldPos("E1_TITPAI")) > 0)
Local cTipo		 := ""    
Local nOrdTitPai :=0
Local bWhile 	 
Local cFilAbat := xFilial("SE1")

Default nTotIrAbt:= 0
Default nTotCsAbt:= 0
Default nTotInAbt:= 0
//Default nTxMoeda := 0

bWhile 	 := {|| !Eof() .And. E1_FILIAL == cFilAbat .And. E1_PREFIXO == cPrefixo .And. E1_NUM == cNumero .And. E1_PARCELA == cParcela }

//Proteção para casos da SE1 compartilhada e o cFilAbat foi informado nos parâmetros com a cFilAnt
cFilAbat := xFilial( "SE1" , cFilAbat )

dData :=IIF(dData==NIL,dDataBase,dData)
If Valtype(dData)=="C"
	dData := StoD(dData)
Endif

nMoeda:=IIF(nMoeda==NIL,1,nMoeda)
cCampo	:= IIF( cCpo == "V", "E1_VALOR" , "E1_SALDO" )

cCliLj := (cAlias)->(E1_CLIENTE+E1_LOJA)
cTipo  := (cAlias)->E1_TIPO          

If Select("__SE1") == 0
	ChkFile("SE1",.F.,"__SE1")
Else
	dbSelectArea("__SE1")
Endif             

dbSetOrder( 1 )
dbSeek( cFilAbat+cPrefixo+cNumero+cParcela )

If lTitpaiSE1 
	If FindFunction("OrdTitpai") .and. (nOrdTitPai:= OrdTitpai()) > 0
		DbSetOrder(nOrdTitPai)
		If	DbSeek(cFilAbat+cPrefixo+cNumero+cParcela+cTipo+cCliLj)   
			bWhile := {|| !Eof() .And. E1_FILIAL + ALLTRIM(E1_TITPAI) ==  cFilAbat+Alltrim(cPrefixo+cNumero+cParcela+cTipo+cCliLj) }
		Else
			DbSetOrder(1)
			DbSeek(cFilAbat+cPrefixo+cNumero+cParcela)
		Endif
	Endif
Endif

While Eval(bWhile)    

	If lTitpaiSE1
		If !Empty(E1_TITPAI) .and. (Alltrim(E1_TITPAI)!=Alltrim(cPrefixo+cNumero+cParcela+cTipo+cCliLj))
			DbSkip()
			Loop
		EndIf
	EndIf  

	If E1_CLIENTE+E1_LOJA == cCliLj        
		//IR
		If E1_TIPO $ MVIRABT .And. E1_TIPO $ MVABATIM
			nTotIrAbt +=xMoeda(&cCampo,E1_MOEDA, nMoeda,dData)  
		Endif
		//CSLL			
		If E1_TIPO $ MVCSABT .And. E1_TIPO $ MVABATIM
			nTotCsAbt +=xMoeda(&cCampo,E1_MOEDA, nMoeda,dData)  
		Else			
			If lPccBxCr .And. "CSL" $ E1_TIPO// Valor fixo na gravação do PCC na baixa (FGrvPccRec())
				nTotCsAbt +=xMoeda(&cCampo,E1_MOEDA, nMoeda,dData)  
			EndIF
		Endif
		//INSS
		If E1_TIPO $ MVINABT .And. E1_TIPO $ MVABATIM
			nTotInAbt +=xMoeda(&cCampo,E1_MOEDA, nMoeda,dData) 
		Endif
	
	Endif
	dbSkip()
Enddo

Return
