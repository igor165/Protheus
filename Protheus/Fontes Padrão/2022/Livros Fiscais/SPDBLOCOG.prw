#Include "SpedFiscal.ch"
#Include "Protheus.ch"
#Include "FWCommand.ch"
#Include "SpedXdef.ch"

// Chamada das funcoes de cache do dicionario na inicializacao do SPEDXFUN.
Static aSPDSX2 := SpedLoadX2()
Static aSPDSX3 := SpedLoadX3()
Static aSPDSX6 := SpedLoadX6()
Static aExistBloc := SPDFRetPEs()
Static aSPDFil	:= fGetSpdFil()

Static cBarraUnix := IIf(IsSrvUnix(),"/","\")

Static lJob := IsBlind()

/*/{Protheus.doc} BlocoG

Função responsável pelo processamento das inFormações de movimentação CIAP, sendo
utilizada tanto para geração do Bloco G do Sped Fiscal quanto o registro T050
do extrator fiscal 

Registros Gerados:           
	Registro G110 ( Sped ) / T050   ( Extrator ) - ICMS Ativo Permanente - CIAP
	Registro G125 ( Sped ) / T050AA ( Extrator ) - Movimentação de Bem ou Componente do Ativo Imobilizado                                       
	Registro G126 ( Sped ) / T050AB ( Extrator ) - Outros Créditos do CIAP
	Registro G130 ( Sped ) / T050AC ( Extrator ) - IdentIficação do Documento de Entrada do Bem/Ativo
	Registro G140 ( Sped ) / T050AD ( Extrator ) - IdentIficação do Item do Documento de Entrada do Bem/Ativo              

@Param: 
cAlias      -> Alias do TRB                                           
lTop        -> Flag para identIficar ambiente TOP                     
aWizard     -> InFormacoes do assistente da rotina                    
aReg0200    -> Estrutura do registro de produtos                      
aReg0190    -> Estrutura do registro de unidades de medida            
aReg0220    -> Estrutura do registro 0220                             
aReg0150    -> Array cadastral com as inFormacoes do participante     
cFilDe      -> Filial inicial para processament multIfilial            
cFilAte     -> Filial final para processament multIfilial              
aLisFil     -> Listas das filiais validas para processament multIfilial
bWhileSM0   -> Condicao padrao para o while do SM0                   
lEnd        -> Flag de cancelamento de execucao                           
nCtdFil     -> Quantidade de registros da tabela SM0 que serao processados                                           
nCountTot   -> Total de registros a serem processados no periodo     
nRegsProc   -> Registros jah processados antes da chamada desta funca
oProcess    -> Objeto da nova barra de progressao                     
lExtratTAF  -> Indica se a chamada foi via extrator fiscal	 
aRegT050    -> Array para geração do registro T050 do extrator fiscal
aRegT050AA  -> Array para geração do registro T050AA do extrator fiscal
aRegT050AB  -> Array para geração do registro T050AB do extrator fiscal
aRegT050AC  -> Array para geração do registro T050AC do extrator fiscal
aRegT050AD  -> Array para geração do registro T050AD do extrator fiscal		 
aRegT008    -> Array para geração do registro T008 que somente é gerado quando existe movimentação do CIAP
aRegT008Aux -> Array auxiliar para geração dos registros referentes ao 0305 do Sped Fiscal no extrator

@Author Gustavo G. Rueda
@since  17/03/2011
@version 1.0

@Altered By:
Rodrigo Aguilar ( 09/12/2016 ): Implementando a geração dos registros da familia T050
do extrator fiscal do Protheus

@Return Nil, nulo, não tem retorno
/*/
Function BlocoG(cAlias,lTop,aWizard,aReg0200,aReg0190,aReg0220,aReg0150,cFilDe,cFilAte,aLisFil,bWhileSM0,;
				lEnd,nCtdFil,nCountTot,nRegsProc,oProcess,lExtratTAF,aRegT050,aRegT050AA,aRegT050AB,;
				aRegT050AC,aRegT050AD,aRegT008,aRegT008Aux)

Local aCoef := {}
Local aRegG125 := {}
Local aRegG126 := {}
Local aRegG130 := {}
Local aRegG140 := {}
Local aReg0300 := {}
Local aReg0305 := {}
Local aReg0500 := {}
Local aReg0600 := {}
Local aInfRegs := {}
Local aAreaSM0 := {}
Local aAreaSF9 := {}
Local aInfRegCom := {}
Local aRegG125Co := {}
Local aRegG125St := {}
Local aRegG125Fr := {}
Local aRegG125Cm := {}
Local aParFil := { '', '' }
Local aCmpsSF9 := {"","","","","","","","","",0,"","","","","",0,"",0,"",0,"",0,"",0,"","","","","",""}  

Local cCodCiap := ''
Local cTimeDocs := ''
Local cAliasAux := ''
Local cDataComp := ''
Local cChave1 := ''
Local cChave2 := ''
Local cChave3 := ''
Local cChave4 := ''
Local cTpMovBem := '  '
Local cAliasSFA := 'SFA'
Local cAliasSF9 := 'SF9'
Local cNew := 'HMNew()'
Local lFTDESPICM := aSPDSX3[FP_FT_DESPICM]
Local lF9SIMPNAC := aSPDSX3[FP_F9_SIMPNAC]
Local cMVCIAPDAC := aSPDSX6[MV_CIAPDAC]
Local cDespAcICM := cMVCIAPDAC
Local cSf9Item := aSPDSX6[MV_F9ITEM] 
Local cSf9Prod := aSPDSX6[MV_F9PROD] 
Local cSf9Esp := aSPDSX6[MV_F9ESP]
Local cF9ChvNfe := aSPDSX6[MV_F9CHVNF]
Local cDaCiap := AllTrim(aSPDSX6[MV_DACIAP]) //Utilizado para calc. ICMS no CIAP. Se S= Considera valor de dIf. aliquota se N= Nao considera dIf. aliquota 
Local cMVEstado := aSPDSX6[MV_ESTADO]
Local cMVF9GENCC := aSPDSX6[MV_F9GENCC]
Local cMVF9GENCT := aSPDSX6[MV_F9GENCT]
Local cF9VLLEG := aSPDSX6[MV_F9VLLEG]
Local cSF9FRT := aSPDSX6[MV_F9FRT]
Local cSF9ICMST := aSPDSX6[MV_F9ICMST]
Local cSF9DIf := aSPDSX6[MV_F9DIF]
Local cSf9CC := aSPDSX6[MV_F9CC]
Local cSf9PL := aSPDSX6[MV_F9PL]
Local cMVF9CTBCC := aSPDSX6[MV_F9CTBCC]
Local cMVF9FUNC := aSPDSX6[MV_F9FUNC]
Local cMVSF9PDes := aSPDSX6[MV_SF9PDES]
Local cMVSF9Qtd := aSPDSX6[MV_SF9QTD]
Local lPRatDieAp	:=	aSPDSX6[MV_PRORDIE]

Local dDataDe := ''
Local dDataAte := ''
Local cPerG126 := ''
Local dDataBem := CToD("  /  /  ")
Local dLei102 := aSPDSX6[MV_DATCIAP]


Local lGeraBA := .F.
Local lGeraSI := .F.
Local lAchouSA2 := .F.
Local lAchouSB1 := .F.
Local lSomaBem := .F.
Local lAchouSN3 := .F.
Local lProdG126 := .F.
Local lCalcImp := .F.
Local lSimpNac	:= .F.
Local lCtbInUse := CtbInUse()
Local lMVAprComp := aSPDSX6[MV_APRCOMP]
Local lMVBemEnt := aSPDSX6[MV_ESTADO] $ aSPDSX6[MV_BEMENT]
Local lSpedG126 := aExistBloc[15]
Local lMvSomaBem := aSPDSX6[MV_SOMABEM]
Local lSTCIAP := aSPDSX6[MV_STCIAP]
Local lMVF9CDATF := aSPDSX6[MV_F9CDATF]			//Parametro utilizado para alterar o codigo do bem gerado no arquivo para utilizar o codigo do SN1
Local lRndCiap := aSPDSX6[MV_RNDCIAP]			// Parametro para arredondamento da apropriacao
Local lF9SKPNF := aSPDSX6[MV_F9SKPNF]

Local nI := 0
Local nX := 0
Local nA := 0
Local nX126 := 0
Local nPos := 0
Local nPosComp := 0
Local nPosG125 := 0
Local nTotD1FT := 0
Local nQtdPSFA := 0
Local nLimParc := 0
Local nPosG130 := 0
Local nC04G110 := 0
Local nC05G110 := 0
Local nC10G110 := 0
Local nFilial := 0
Local nEmpProc := 0
Local nFator := 0
Local nTotSai := 0
Local nTotTrib := 0
Local nSv1Progress := 0
Local nSv2Progress := 0
Local nGera125IM := 0
Local nVlrBxPSFA := 0
Local nVLLEG := 0
Local nTo := 1
Local nQtdSF9 := 1
Local nDocsXTime := 1
Local nRecnoSD1 := 0
Local nRecnoSB1 := 0
Local nRecnoSFT := 0
Local nRecnoSA2 := 0
Local nRecnoSN1 := 0
Local nRecnoSN3 := 0
Local nRecnoSF9 := 0
Local nPLC102 := aSPDSX6[MV_LC102]
Local nX3codBem := TamSx3("F9_CODIGO")[1]
Local lAchouSF4 := .F.
Local lFrtSF8	:= .F.

Private lBuild := GetBuild() >= "7.00.131227A"

Private oHMG125 := Nil
Private oHMG125Co := Nil
Private oHMG125St := Nil
Private oHMG125Fr := Nil
Private oHMG125Cm := Nil

Private lConcFil := .F.	// Variavel private para sobrepor a mesma variavel no sped.

//Private aG25130140	:= {} //Trecho base para reaproveitamento de gravação sem utilizar o SPEDREGs e sim aproveitar a regra que o processamento dos registros ja fez ou seja ir mapeando conforme o fonte é executado, quais registros e seus filho/netos serao impressos.

Default aRegT050 := {}
Default aRegT050AA := {}
Default aRegT050AB := {}
Default aRegT050AC := {}
Default aRegT050AD := {}  
Default aRegT008 := {}
Default aRegT008Aux := {}
Default lExtratTAF := .F.

// Apenas o Sped considera o conteúdo do parâmetro para concatenar a filial. 
If !lExtratTAF
	lConcFil := aSPDSX6[MV_COFLSPD]
EndIf

// Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
If lBuild
	oHMG125 := &cNew
	oHMG125Co := &cNew	
	oHMG125St := &cNew
	oHMG125Fr := &cNew	
	oHMG125Cm := &cNew	 
EndIf 

// Tratamento para quando a chamada seja via extrator fiscal
If !lExtratTAF
	dDataDe := SToD(aWizard[1][1])
	dDataAte := STod(aWizard[1][2])		
Else
	dDataDe := aWizard[1][3]
	dDataAte := aWizard[1][4]		
EndIf

// verIfica existencia de dados para periodo apurado
If aSPDSX2[AI_F0W]
	cPerG126 		:= cvaltochar(strzero(month(dDataDe),2)) + cvaltochar(year(dDataAte ))
	DbSelectArea("F0W")
	F0W->(DbSetOrder(3))
	If F0W->(MsSeek(xFilial("F0W")+cPerG126))
		lProdG126  :=  .T.
	Else
		lProdG126  :=  .F.
	EndIf	
	F0W->(dbCloseArea())
EndIf

aAreaSM0 := SM0->(GetArea())

// Montando array com os campos opcionais para geracao do arquivo caso nao tenha integracao com o documento fiscal
If SF9->(FieldPos(cSf9Esp))>0
	aCmpsSF9[1] :=	cSf9Esp
EndIf 

If SF9->(FieldPos(cF9ChvNfe))>0
	aCmpsSF9[3] :=	cF9ChvNfe
EndIf    

If SF9->(FieldPos(cSf9Item))>0
	aCmpsSF9[5] :=	cSf9Item
EndIf   

If SF9->(FieldPos(cSf9Prod))>0
	aCmpsSF9[7] :=	cSf9Prod
EndIf   

If SF9->(FieldPos(cMVF9FUNC))>0
	aCmpsSF9[9] :=	cMVF9FUNC
EndIf  

If SF9->(FieldPos(cSf9CC))>0
	aCmpsSF9[11] :=	cSf9CC
EndIf 

If SF9->(FieldPos(cSf9PL))>0
	aCmpsSF9[13] :=	cSf9PL
EndIf

aCmpsSF9[15] :=	"F9_VIDUTIL"

If SF9->(FieldPos(cSF9FRT))>0
	aCmpsSF9[17] :=	cSF9FRT
EndIf

If SF9->(FieldPos(cSF9ICMST))>0
	aCmpsSF9[19] :=	cSF9ICMST
EndIf

If SF9->(FieldPos(cSF9DIf))>0
	aCmpsSF9[21] :=	cSF9DIf
EndIf 

If SF9->(FieldPos(cF9VLLEG))>0
	aCmpsSF9[23] :=	cF9VLLEG
EndIf 

If SF9->(FieldPos(cMVSF9PDes))>0
	aCmpsSF9[25] :=  cMVSF9PDes
EndIf

aCmpsSF9[27] := "F9_CODIGO" 
	
If SF9->(FieldPos(cMVSF9Qtd))>0
	aCmpsSF9[29] := cMVSF9Qtd
EndIf

/*
	No caso de o objeto oProcess existir, signIfica que a nova barra  
	de processamento (CLASSE Fiscal) estah em uso pela rotina,       
	portanto deve ser efetuado os controles para demonstrar o        
	resultado do processamento.                                      

	Já que estah rotina efetua o processamento multi-filiais, preciso
	corrigir a posicao da regua, pois no while principal da SFT      
	deixou a barra no final, pois processou todas as filiais.        
*/
If Type( "oProcess" ) == "O"
	oProcess:Set1Progress( nCtdFil )
EndIf	

// Processamento de multIfiliais
DbSelectArea ("SM0")
SM0->(DbGoTop ())
SM0->(MsSeek ( cEmpAnt + cFilDe, .T.) )	//Pego a filial mais proxima 
	
/*
	Quando a opcao de seleciona filiais estiver configurada como sim, serah    
	considerado as filiais selecionadas no browse. Caso contrario, valera o
	que estiver configurado na pergunta 'Filial DE/ATE'
*/
Do While Eval(bWhileSM0)
	/*
		Quando a chamada For via extrator não realizo o tratamento de filiais, pois sempre será processada
		apenas para a filial corrente do sistema (cFilAnt)
	*/
	cFilAnt	:= 	FWGETCODFILIAL
	aParFil  := { DToS( dDataDe ), DToS( dDataAte ) }

	If Len( aLisFil ) > 0 .And. cFilAnt <= cFilAte

		nFilial := Ascan( aLisFil,{ |x| x[2] == cFilAnt } )

		If nFilial == 0 .Or. !( aLisFil[ nFilial,1 ] )  //Filial não marcada, vai para proxima
			SM0->(dbSkip()) 
			Loop
		EndIf
	Else
		If (!lExtratTAF .And. "1" $ aWizard[1][12]) .Or. (lExtratTAF .And. "1" $ aWizard[1][5])  //Somente faz skip se a opção de selecionar filiais estiver como Sim.
			SM0->( dbSkip())
			Loop
		EndIf		
	EndIf  
	
	nEmpProc += 1

	/*
		No caso de o objeto oProcess existir, signIfica que a nova barra  
		de processamento (CLASSE Fiscal) estah em uso pela rotina,       
		portanto deve ser efetuado os controles para demonstrar o        
		resultado do processamento.                                      
		Definicao o primeiro incremento da regua                          
	*/
	If Type( "oProcess" ) == "O"
		oProcess:Inc1Progress( STR0023 + cEmpAnt + "/" + cFilAnt, StrZero( nEmpProc, 3 ) + "/" + StrZero( nCtdFil, 3) )	//"Processando empresa :"
		oProcess:Inc2Progress( "Processando movimentos de CIAP...", StrZero( nRegsProc, 6 ) + "/" + StrZero( nCountTot, 6 ) )

		// Controle do cancelamento da rotina
		If oProcess:Cancel()
			Exit
		EndIf 
		
	Else

		// Controle do cancelamento da rotina
		If Interrupcao( @lEnd )
			Exit
		EndIf
	EndIf
	/*
		Filtro na tabela SFA com JOIN na tabela SF9 caso seja TOP  
		Alterado conForme chamado: TQDD21
	*/
	If nCountTot > 0 .And. SPEDFFiltro( 1, "SF92", @cAliasSF9, aParFil ) .And. "1" $ aWizard[1][24]
	
		/*
			Para ambiente TOP, crio uma copia da tabela SFA para ler algumas
			inFormacoes de outros registros Fora do periodo. Para TOP, as  
			inFormacoes jah estao no SELECT                                
		*/
		If !lTop
			If Select("__SFA")<>0
				__SF9->(DbCloseArea ())
			EndIf
			ChkFile ("SFA", .F., "__SFA")
			
			SPEDFFiltro(1,"SFA5",@cAliasSFA,aParFil)
			//EXECUTO PARA BUSCA DAS INForMAÇÕES DA SFA
		Else
			//adiciono o mesmo nome, para não trocar os alias abaixo
			cAliasSFA := cAliasSF9
		EndIf
			
		// Processando a tabela SFA jah filtrada
		While (cAliasSF9)->( !Eof() )

			nRegsProc += 1
			
			/*
				No caso de o objeto oProcess existir, signIfica que a nova barra  
				de processamento (CLASSE Fiscal) estah em uso pela rotina,       
				portanto deve ser efetuado os controles para demonstrar o        
				resultado do processamento.                                      

				Efetuando o incremento da segunda regua com as inFormacoes        
				atualizadas e atualizando os detalhes do processamento           
			*/
			If Type("oProcess") == "O"

				oProcess:Inc2Progress( "Processando movimentos de CIAP...", StrZero( nRegsProc, 6 ) + "/" + StrZero( nCountTot, 6 ) )

				// Condicao implementada para controlar os numeros apresentadas na tela de processamento da rotina, os detalhes
				If cTimeDocs <> Time() .And. !lExtratTAF
					oProcess:SetDetProgress(STR0026,nCountTot,;					//"Total de registros do periodo solicitado"
							STR0027,nDocsXTime,;								//"Total de registros processados por segundo"
							STR0028,nCountTot-nRegsProc,;      				    //"Total de registros pendentes para processamento"
							STR0029,Round((nCountTot-nRegsProc)/nDocsXTime,0))	//"Tempo estimado para termino do processamento (Seg.)"
				
					cTimeDocs	:=	Time()
					nDocsXTime	:=	1
				Else                 
					nDocsXTime	+=	1
				EndIf

				// Controle do cancelamento da rotina
				If oProcess:Cancel()
					Exit
				EndIf
			Else
				IncProc("Processando movimentos de CIAP...")
				
				// Controle do cancelamento da rotina
				If Interrupcao(@lEnd)
					Exit
				EndIf  
				
			EndIf


			If !lTop
				//SE NAO DEU ENTRADA DENTRO DO PERIODO NAO TRAZ O ITEM, PORÉM CASO HAJA UTILIZAÇÃO MANTEM O PROCESSAMENTO
				If ((cAliasSF9)->F9_DTENTNE < dDataDe .Or. (cAliasSF9)->F9_DTENTNE > dDataAte) 
					If !SPEDSeek(cAliasSFA,,xFilial("SFA")+(cAliasSF9)->F9_CODIGO)
						(cAliasSF9)->(DBSKIP())				
						loop
					EndIf	
				EndIf 	
			EndIf

			If lTop	       
				nRecnoSF9 := (cAliasSF9)->SF9RECNO
				nRecnoSFT := (cAliasSF9)->SFTRECNO
				nRecnoSD1 := (cAliasSF9)->SD1RECNO
				nRecnoSA2 := (cAliasSF9)->SA2RECNO
				nRecnoSB1 := (cAliasSF9)->SB1RECNO
				nRecnoSN1 := (cAliasSF9)->SN1RECNO
				nRecnoSN3 := (cAliasSF9)->SN3RECNO
				nRecnoSFA := (cAliasSF9)->SFARECNO
			Else
				//POSICIONO CASO TENHA SFA
				SPEDSeek(cAliasSFA,,xFilial("SFA")+(cAliasSF9)->F9_CODIGO)	
			EndIf
			//POSICIONO PARA NÃO SE PERDER NA SF9 PARA DBF JÁ UTILIZA SF9 NO WHILE
			If lTop
				SPEDSeek("SF9",,xFilial("SF9")+(cAliasSF9)->F9_CODIGO,nRecnoSF9)
			EndIf
			
									
			nQtdPSFA := 0
			nQtdSF9	 := 1
			cCodCiap := SF9->F9_CODIGO+Iif(lConcFil,xFilial("SF9"),"")
			nFator := (cAliasSFA)->FA_FATOR 
			nLimParc := nPLC102
			lGeraBA := .F.
			lGeraSI := .F.
			nTo := 1
			lAchouSD1 := .F.
			lAchouSFT := .F.
			lAchouSA2 := .F.
			lAchouSB1 := .F.
			lAchouSN3 := .F.
			aInfRegs := {}
			nVLLEG := 0
			cDespAcICM := cMVCIAPDAC
			nVlrBxPSFA := 0
			nTotSai := (cAliasSFA)->FA_TOTSAI
			nTotTrib := (cAliasSFA)->FA_TOTTRIB
	
			// Se NAO For TOP tenho que posicioar a tabela SF9
			If !lTop
				nQtdSF9 := SpedBGQf9( SF9->F9_DOCNFE,SF9->F9_DTENTNE,SF9->F9_SERNFE,SF9->F9_ForNECE,SF9->F9_LOJAFor,SF9->F9_ITEMNFE )
			Else                       			
				cAliasAux := "SF9"
				nQtdSF9 := 0				
				aParFil := {}
				
				Aadd(aParFil,DToS( SF9->F9_DTENTNE))
				Aadd(aParFil,SF9->F9_DOCNFE)
				Aadd(aParFil,SF9->F9_SERNFE)
				Aadd(aParFil,SF9->F9_ForNECE)
				Aadd(aParFil,SF9->F9_LOJAFor)
				Aadd(aParFil,SF9->F9_ITEMNFE)
				Aadd(aParFil,SF9->F9_ROTINA)
				Aadd(aParFil,SF9->F9_CODIGO)				

				If SPEDFFiltro( 1, "SF9", @cAliasAux, aParFil )
					nQtdSF9 := (cAliasAux)->QTDSF9
					SPEDFFiltro( 2, , cAliasAux )
				EndIf       
				
			EndIf

        	// Se For baixa pela rotina do ativo fixo, se For baixa total, ter quantidade de parcelas, não ter saldo
        	If (cAliasSFA)->FA_ROTINA == "ATFA030" .And. (cAliasSFA)->FA_BAIXAPR == "0" .And. (cAliasSFA)->FA_TIPO == "2";
        		.And. SF9->F9_QTDPARC > 0 .And. SF9->F9_SLDPARC == 0 
        		
        		(cAliasSFA)->(DBSKIP())
        		Loop
        	EndIf

			// Condicao utilizada para avaliar o parametro utilizado para nao considerar o documento mesmo que exista na base
			// Será considerado o valor dos campos incluidos no SF9 para as respectivas colunas do SPED Fiscal              
			If lF9SKPNF
				lAchouSFT := .F.
				nRecnoSFT := Nil
				nRecnoSD1 := Nil
				nRecnoSB1 := Nil
				nRecnoSN1 := Nil
				nRecnoSN3 := Nil
			
			Else
	
				If SF9->F9_ROTINA$"ATFA251"
					lAchouSFT := .F.
				Else
					// Posicionando o SFT para utilizar algumas inFormacoes do documento
					lAchouSFT := SPEDSeek("SFT",,xFilial("SFT")+"E"+SF9->(F9_SERNFE+F9_DOCNFE+F9_FORNECE+F9_LOJAFOR+F9_ITEMNFE),nRecnoSFT)
				EndIf
			EndIf
				
			// Posicionando a SA2 para utilizar algumas inFormacoes do documento 
			lAchouSA2 := SPEDSeek( "SA2",, xFilial( "SA2" ) + SF9->( F9_ForNECE + F9_LOJAFor ), nRecnoSA2 )
	
			// Tratamento para verIficar se a despesa acessoria compoe a base 
			// de calculo do ICMS, pois o registro exige a inFormacao separada
			If lAchouSFT             
			
				// Posicionando o SD1 para utilizar algumas inFormacoes do documento 
				lAchouSD1 := SPEDSeek("SD1",1,xFilial("SD1")+SFT->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM),nRecnoSD1)
				lAchouSF4 := SPEDSeek( "SF4", 1, xFilial( "SF4" ) + SD1->D1_TES )
			
				If lFTDESPICM .And. !Empty( SFT->FT_DESPICM )
					cDespAcICM := SFT->FT_DESPICM
				Else 
					If lAchouSD1
						If lAchouSF4
							cDespAcICM := SF4->F4_DESPICM
						EndIf
					EndIf
				EndIf
			EndIf
	
			/*
				VerIfico existencia da integracao com o ATF, pois utilizo algumas inFormacoes para gerar os   
				registros posteriores. Neste momento, caso exista esta integracao, tambem tem-se a opcao de  
				alterar o codigo do bem a ser gerado nos registros para utilizar o codigo gerado no ATF.
			*/
			If ( lAchouSN3 := !lF9SKPNF .And. SPEDSeek( "SN1", 4, xFilial( "SN1" ) + SF9->F9_CODIGO, nRecnoSN1 ) .And.;
				SPEDSeek( "SN3", 1, xFilial( "SN3" ) + SN1->N1_CBASE + SN1->N1_ITEM, nRecnoSN3 ) )

				If AllTrim( SN3->N3_CCONTAB ) == "" .Or. AllTrim( SN3->N3_CUSTBEM ) == ""
					lAchouSN3 := .F.
				EndIf
				
				// Parametro utilizado para alterar o codigo do bem gerado no arquivo para utilizar o codigo do SN1
				If lMVF9CDATF
					cCodCiap :=	SN1->N1_CBASE + SN1->N1_ITEM
				EndIf
			EndIf
	
			// Paegando os valores dos campos customizados, se encontrar o documento fiscal, utilizarah dos respectivos documentos
			For nI := 1 To Len( aCmpsSF9 ) Step 2
				If !Empty( aCmpsSF9[nI] )
					aCmpsSF9[ nI + 1 ] := SF9->( & ( aCmpsSF9[ nI ] ) )
				EndIf
			Next nI
			
			// Se nao encontrar a NF, utilizarah o produto amarrado ao SF9
			If !lAchouSFT         
			
				// Posicionando a SA2 para utilizar algumas inFormacoes do documento 
				If !Empty( aCmpsSF9[ 8 ] )
					lAchouSB1 := SPEDSeek( "SB1" , , xFilial( "SB1" ) + aCmpsSF9[8] ) 
				EndIf 
			Else
				// Posicionando a SA2 para utilizar algumas inFormacoes do documento 
				lAchouSB1 := SPEDSeek( "SB1", , xFilial( "SB1" ) + SFT->FT_PRODUTO, nRecnoSB1 )
			EndIf
						
			// Calculo a quantidade de parcelas do sistema conForme Lei Complementar 102
			If !SF9->F9_DTENTNE >= dLei102
				nLimParc  	:= 	60
			EndIf
			
			//Tratamento para que o valor a ser deduzido nas parcelas nao seja considerado pelo parametro MV_LC102. 			³
			//Por exemplo no caso de parcelas reduzidas (Decreto 1980 de 21.12.2007), o usuario ira alterar o cadastro do	³
			//bem e indicara no campo F9_QTDPARC o valor fixo de parcelas a ser consideradas. Por exemplo, se o numero de	³
			//parcelas For 42 ao inves de 48, apenas ira calcular a quantidade fixa menos o saldo, pois se considerar o 	³
			//valor contido no MV_LC102, as inFormacoes no SPEDFiscal ficarao divergentes.								
			If SF9->F9_PARCRED == "1"
				nLimParc :=	SF9->F9_QTDPARC
			EndIf

			//Se o ativo possuir este campo preenchido, faco o calculo por ele, pois
			//pode ser que a origem foi outro sistema e houve uma migracao para   
			//o Protheus, ficando uma parte no sistema legado e outr no ERP        
			If SF9->F9_QTDPARC > 0
				
				nQtdPSFA :=	SF9->( ( F9_QTDPARC - F9_SLDPARC ) + ( nLimParc - F9_QTDPARC ) )
				
				//Tratamento para quando não For inFormado o valor o valor apropriado no sistema legado.      
				//Este valor eh utilizado para compor o total de credito CIAP.                                
                                                                                            
				//Ex: Ao incluir o CIAP, o F9_VALICMS eh 300, o QTDPARC eh 30 e o SLDPARC eh 30,              
				//     portanto o credito CIAP para as 30 parcelas restante eh +/- 10, porem NAO se tem       
				//     o valor total do CIAP, o que se refere as 18 parcelas jah apropriadas no outro sistema.
				//     Este campo a ser inFormado no parametro MV_F9VLLEG deve representar o restante,        
				//     que neste caso eh 180, dando um total de credito de 480 em 48 parcelas.                
				If Empty( aCmpsSF9[ 24 ] )
					nVLLEG	:=	SF9->( ( F9_VALICMS / F9_QTDPARC ) * ( nLimParc - F9_QTDPARC ) )
					nVLLEG	:=  If( lRndCiap, Round( nVLLEG, 2 ), NoRound( nVLLEG, 2 ) )					
					
				Else
					nVLLEG	:=	aCmpsSF9[ 24 ]                                       
					
				EndIf
			
				//Tratamento para considerar a quantidade de parcelas correta quando estah sendo gerado um SPED Fiscal  
				//retroativo. Como o campo SLDPARC vai conter somente a quantidade de parcelas restante, preciso somar
				//a quantidade de parcelas que realmente NAO CABEM no periodo, como se ainda estivesse pendente. Ex:  
				//F9_QTDPARC=48, F9_SLDPARC=18, nQtdPSFA = 30,  QTDAPRPOST = 4, entao o total seria 34 e nao 30 como  
				//inForma no nQtdPSFA, pois 4 se referem aos meses posteriores ao processamento do SPED               
				If lTop
				
					cAliasAux	:=	"SFA"
					aParFil		:=	{}
					
					aAdd( aParFil,(cAliasSFA)->FA_CODIGO)
					aAdd( aParFil,DToS(dDataAte))				

					If SPEDFFiltro(1,"SFA3",@cAliasAux,aParFil)
						nQtdPSFA -=	(cAliasAux)->QTDAPRPOST
						SPEDFFiltro(2,,cAliasAux)
					EndIf
				Else
					
					//Tratamento para ambiente DBF/ADS para retornar a quantidade de
					//parcelas já apropriadas                                     
					__SFA->(MsSeek(xFilial("SFA") + (cAliasSFA)->FA_CODIGO))
					While !__SFA->(Eof()) .And. __SFA->FA_CODIGO == (cAliasSFA)->FA_CODIGO
						
						If  __SFA->FA_DATA > dDataAte
							nQtdPSFA	-=	1
						EndIf
						
						//Condicao implementada para se obter o valor das baixas parciais do periodo para      
						//abater no valor total do CIAP (campo 05-VL_IMOB_ICMS_OP do registro G125).         
						//Apesar do layout nao prever baixa parcial, estamos implementando o tratamento        
						//desta Forma para enviar o valor correto de apropriacao e nao acusar erro no        
						//validador quando efetuar as multipiocacoes. Nossa consultoria esta providenciando  
						//uma consulta Formal para termos a posicao final do Fisco para o tratamento correto.
						If __SFA->FA_TIPO=="2	" .And. __SFA->FA_BAIXAPR=="1"
							nVlrBxPSFA	+=	__SFA->FA_VALOR
						EndIf
						
						__SFA->(dbSkip())
					End
				EndIf
			Else
				//Tratamento para armazenar a quantidade de parcelas de um bem ate a data de final
				//de periodo de processamento do spedfiscal                                     
				If !lTop
				
					//Tratamento para ambiente DBF/ADS para retornar a quantidade de
					//parcelas jah apropriadas                                     
					__SFA->( MsSeek( xFilial( "SFA" ) + (cAliasSFA)->FA_CODIGO ) )
					
					While !__SFA->(Eof()) .And. __SFA->FA_CODIGO==(cAliasSFA)->FA_CODIGO .And. __SFA->FA_DATA<=dDataAte
						
						nQtdPSFA	+=	1

						//Condicao implementada para se obter o valor das baixas parciais do periodo para      
						//abater no valor total do CIAP (campo 05-VL_IMOB_ICMS_OP do registro G125).         
						//Apesar do layout nao prever baixa parcial, estamos implementando o tratamento        
						//desta Forma para enviar o valor correto de apropriacao e nao acusar erro no        
						//validador quando efetuar as multipiocacoes. Nossa consultoria esta providenciando 
						//uma consulta Formal para termos a posicao final do Fisco para o tratamento correto
						If __SFA->FA_TIPO=="2	" .And. __SFA->FA_BAIXAPR=="1"
							nVlrBxPSFA	+=	__SFA->FA_VALOR
						EndIf
						
						__SFA->(dbSkip())
					End
				Else
					cAliasAux	:=	"SFA"
					aParFil		:=	{}
					aAdd(aParFil,(cAliasSF9)->F9_CODIGO)
					aAdd(aParFil,DToS(dDataAte))				

					If SPEDFFiltro(1,"SFA2",@cAliasAux,aParFil)
						nQtdPSFA	:=	(cAliasAux)->QTDAPR
						SPEDFFiltro(2,,cAliasAux)
					EndIf
				EndIf
			EndIf
			
			//Condicao implementada para se obter o valor das baixas parciais do periodo para      
			//abater no valor total do CIAP (campo 05-VL_IMOB_ICMS_OP do registro G125).         
			//Apesar do layout nao prever baixa parcial, estamos implementando o tratamento        
			//desta Forma para enviar o valor correto de apropriacao e nao acusar erro no        
			//validador quando efetuar as multipiocacoes. Nossa consultoria esta providenciando  
			//uma consulta Formal para termos a posicao final do Fisco para o tratamento correto.
			If lTop
				cAliasAux	:=	"SFA"
				aParFil		:=	{}
				
				aAdd( aParFil,(cAliasSFA)->FA_CODIGO )
				aAdd( aParFil,DToS( dDataAte ) )

				If SPEDFFiltro(1,"SFA4",@cAliasAux,aParFil)
					nVlrBxPSFA	:=	(cAliasAux)->VLRBAIXA
					SPEDFFiltro(2,,cAliasAux)
				EndIf
			EndIf
	
			//REGISTRO G125 - MOVIMENTACAO DE BEM OU COMPONENTE DO ATIVO IMOBILIZADO                                                                                                         |
			//A gravacao do array aRegG125 deverah ser efetua da no final do processamento, pois esta 
			//funcao somente o alimenta                                                             
			nX := 1
			While nX <= nTo		 
			
				If (!lMVAprComp .And.(SF9 -> (F9_VALICMS==0) .And. SF9 -> (F9_SLDPARC==0) .And. SF9 -> (F9_CODBAIX == 'BFINAL')));
            			.Or. (SF9 -> (F9_VALICMS==0) .And. SF9 -> (F9_SLDPARC==0) .And. SF9 -> (F9_CODBAIX == 'BFINAL'))	
					Exit	
				EndIf    

				If lMvSomaBem				
					If SF9->F9_TIPO == "03"
																		
						cDataComp 	:= IIf(!Empty(SF9->F9_DTEMINE),Mes(SF9->F9_DTEMINE),"")+ AllTrim(Str(Year(SF9->F9_DTEMINE)))				
						aAreaSF9	:=	SF9->(GetArea())
								
						If SF9->(MsSeek(xFilial("SF9")+SF9->F9_CODBAIX))		
										
							If cDataComp == IIf(!Empty(SF9->F9_DTEMINE),Mes(SF9->F9_DTEMINE),"") + AllTrim(Str(Year(SF9->F9_DTEMINE)))									
								lSomaBem := .T. 										
							EndIf										
						EndIf											
						RestArea(aAreaSF9)									
					EndIf
				EndIf
				

				dDataBem	:=	CToD("  /  /  ")						//03-DT_MOV  
				cTpMovBem	:=	"  "  									//04-TIPO_MOV	
	
				// IM - Entrada do bem no periodo
				If SF9->(F9_DTENTNE>=dDataDe .And. F9_DTENTNE<=dDataAte .And. F9_TIPO <> "03" ) ;
					.And. !lGeraSI	.And. ( (lMVBemEnt .And. (Empty((cAliasSFA)->FA_CODIGO) .Or. !((cAliasSFA)->(FA_TIPO=="2" .And. FA_MOTIVO$"/1/2/3/4/5")) )) ;
					.Or.( !lMVBemEnt .And. !((cAliasSFA)->(FA_TIPO=="2" .And. FA_MOTIVO$"/1/2/3/4/5")))  )
					
					dDataBem	:=	SF9->F9_DTENTNE						//03-DT_MOV  
					cTpMovBem	:=	"IM"				  				//04-TIPO_MOV
				
					//Depois que gerou, retorno o status para .F.
					//lGeraSI	:=	.T.		//VERIfICAR TRATAMENTO, POIS PARA O SPED FISCAL, NO MES QUE ENTRA O BEM NAO TEM APROPRIACAO E NO MES DE BAIXA SIM, TRATAMENTO CONTRARIO DO SISTEMA
	
				// SI - Apropriacao
				ElseIf ( (!lMVBemEnt .And. !lGeraBA .And. (cAliasSFA)->FA_TIPO=="1" .And. SF9->F9_DTENTNE<dDataDe);
				.Or.  (lMVBemEnt .And. !lGeraBA .And. (cAliasSFA)->FA_TIPO=="1") ) .Or. lGeraSI
					
					dDataBem	:=	dDataDe				 			//03-DT_MOV  
					cTpMovBem	:=	"SI"				   				//04-TIPO_MOV
			
					//Quando se tratar de baixa por vencimento de periodo de apropriacao,
					//devo gerar tambem um BA                                           
					If nQtdPSFA == nLimParc
						lGeraBA	:=	.T.
					EndIf
					
					//Depois que gerou, retorno o status para .F.
					lGeraSI	:=	.F.
	
				//PE - Baixa por perecimento/extravio/deterioracao
				ElseIf (cAliasSFA)->(FA_TIPO=="2" .And. FA_MOTIVO=="1") 
				
					dDataBem	:=	(cAliasSFA)->FA_DATA	 			//03-DT_MOV  
					cTpMovBem	:=	"PE"				   				//04-TIPO_MOV
	
					//Layout determina que para uma baixa por venda/transferencia/perecimento
					//devo tambem gerar um SI                                               
					lGeraSI	:=	.T.
					
				//AT - Baixa por alienacao ou transferencia
				ElseIf (cAliasSFA)->(FA_TIPO=="2" .And. FA_MOTIVO$"/3/")

					dDataBem	:=	(cAliasSFA)->FA_DATA				//03-DT_MOV  
					cTpMovBem	:=	"AT"					 			//04-TIPO_MOV
					
					//Layout determina que para uma baixa por venda/transferencia/perecimento
					//devo tambem gerar um SI                                               
					lGeraSI	:=	.T.
					
				// OT - Baixa por outras saidas do imobilizado 
				ElseIf (cAliasSFA)->(FA_TIPO=="2" .And. FA_MOTIVO$"/2/4/5/")

					dDataBem	:=	(cAliasSFA)->FA_DATA	 	 		//03-DT_MOV  
					cTpMovBem	:=	"OT"					 	 		//04-TIPO_MOV
	
					//Layout determina que para uma baixa por venda/transferencia/perecimento
					//devo tambem gerar um SI                                               
					lGeraSI	:=	.T.
	
				// BA - Baixa por fim de apropriacao
				ElseIf lGeraBA

					dDataBem	:=	(cAliasSFA)->FA_DATA  		 		//03-DT_MOV  
					cTpMovBem	:=	"BA"				  	   			//04-TIPO_MOV
					
					//Depois que gerou, retorno o status para .F.
					lGeraBA	:=	.F.
	
				EndIf 

				If SPEDValC()
					// IA = Imobilização em Andamento - Componente.
					If SF9->F9_TIPO == "03"
						If SF9->F9_DTENTNE >= dDataDe .And. SF9->F9_DTENTNE <= dDataAte
							cTpMovBem	:= "IA" //Imobilização em Andamento - Componente;
							dDataBem	:= SF9->F9_DTENTNE
						ElseIf (SF9->F9_DTENTNE < dDataDe .Or. SF9->F9_DTENTNE > dDataAte) .And. (cAliasSFA)->FA_MOTIVO == "2"
							cTpMovBem	:= "SI" //Saldo inicial de bens imobilizados;
							dDataBem	:= dDataDe
						ElseIf (SF9->F9_DTENTNE < dDataDe .Or. SF9->F9_DTENTNE > dDataAte) .And. !lMVAprComp
							cTpMovBem	:= "IA" //Imobilização em Andamento - Componente;
							dDataBem	:= SF9->F9_DTENTNE
						EndIf
					EndIf
					// CI = Conclusão de Imobilização em Andamento - Bem Resultante.
					If SF9->F9_TIPO == "01"
						If	SF9->F9_CODBAIX = "BFINAL" .And. SF9->F9_VALICMS > 0 .And.;
							SF9->F9_DTENTNE >= dDataDe .And. SF9->F9_DTENTNE <= dDataAte
							cTpMovBem	:= "CI" //Conclusão de Imobilização em Andamento – Bem Resultante;
							dDataBem	:= (cAliasSFA)->FA_DATA
						ElseIf !lMVAprComp .And. SF9->F9_CODBAIX = "BFINAL" .And. SF9->F9_VALICMS > 0 .And.;
							(SF9->F9_DTENTNE < dDataDe .Or. SF9->F9_DTENTNE > dDataAte)
							cTpMovBem	:= "SI" //SI = Saldo inicial de bens imobilizados;
							dDataBem	:= dDataDe
						EndIf
					EndIf
				EndIf

				// Tratamento para evitar duplicidade no registro
												
				// Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
				If lBuild
					cChave1:= cCodCiap+cTpMovBem
					nPos := FindHash(oHMG125, cChave1)
				Else
					nPos := aScan( aRegG125,{ |aX| aX[2] == cCodCiap .And. aX[4] == cTpMovBem } )
				EndIf
				
				If nPos == 0
					//Na Inclusao do Movimento tipo SI verIfica se existe um outro registro do mesmo bem 
					//no mesmo periodo do tipo IM, se exister apaga o tipo IM do array.

				    // Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
					If lBuild
						cChave2:= cCodCiap+"IM"+MES(dDataBem)
						nGera125IM	:= FindHash(oHMG125, cChave2)
					Else
						nGera125IM := aScan(aRegG125,{|aX| aX[2]==cCodCiap .And. aX[4]=="IM" .And. MES(aX[3]) == MES(dDataBem)})
					EndIf 
				    
					If cTpMovBem == "SI" .And. nGera125IM > 0
						Loop
					EndIf 
									
					aAdd( aRegG125, {} )
					nPos :=	Len (aRegG125)	
					aAdd ( aRegG125[nPos], "G125") 				 			//01-REG
					aAdd ( aRegG125[nPos], cCodCiap)				  		//02-COD_IND_BEM
					aAdd ( aRegG125[nPos], dDataBem) 				 		//03-DT_MOV 
					aAdd ( aRegG125[nPos], cTpMovBem)				  		//04-TIPO_MOV
					aAdd ( aRegG125[nPos], 0)	 							//05-VL_IMOB_ICMS_OP
					aAdd ( aRegG125[nPos], 0) 								//06-VL_IMOB_ICMS_ST
					aAdd ( aRegG125[nPos], 0) 								//07-VL_IMOB_ICMS_FRT
					aAdd ( aRegG125[nPos], 0) 								//08-VL_IMOB_ICMS_DIf		
					aAdd ( aRegG125[nPos], 0)								//09-NUM_PARC
					aAdd ( aRegG125[nPos], 0) 								//10-VL_PARC_PASS
					
					If lBuild
						AddHash(oHMG125,cChave1,nPos)
						AddHash(oHMG125,cChave2,nGera125IM)
					EndIf
						
					//Segundo o manual, para os motivos "BA/AT/PE/OT" os campos nao
					//devem ser inFormados                                        
					If aRegG125[ nPos,4 ] $ "SI/IM/IA/MC/CI"
						//Condicao implementada para se obter o valor das baixas parciais do periodo para      
						//abater no valor total do CIAP (campo 05-VL_IMOB_ICMS_OP do registro G125).         
						//Apesar do layout nao prever baixa parcial, estamos implementando o tratamento        
						//desta Forma para enviar o valor correto de apropriacao e nao acusar erro no        
						//validador quando efetuar as multipiocacoes. Nossa consultoria esta providenciando  
						//uma consulta Formal para termos a posicao final do Fisco para o tratamento correto.
						//Observacao:                                                                          
						//A opcao de zerar os valores dos campos 6, 7 e 8 foi conForme orientacao de nossa   
						//consultoria ateh obtermos a resposta Formal do fisco.                              
						If nVlrBxPSFA>0							
							aRegG125[nPos,5]	:=	SF9->F9_VALICMS-nVlrBxPSFA									//05-VL_IMOB_ICMS_OP													
							
						Else                 
						
							//criado Fora do If pq pode ser usado no Else em outro hash - PerFormance
							cChave3	:= SF9->F9_CODBAIX 
							cChave4	:= SF9->F9_CODIGO 

							If lF9SIMPNAC .and. !Empty(SF9->F9_SIMPNAC)
								If 	SF9->F9_SIMPNAC == "1"
									lSimpNac := .T.
								Else
									lSimpNac := .F.
								Endif
							Else
								lSimpNac := SA2->A2_SIMPNAC == '1'
							Endif							
							//Validação para quando o fornecedor for Simples Nacional de SC fazer os cálculos normalmente como se fosee regime normal
							If lSimpNac .And. SA2->A2_EST == 'SC' .And. ALLTRIM(SF9->F9_CFOENT) == '1551'
								lSimpNac := .F.
							EndIf

							//³ICMS  da operacao propria calculado no documento fiscal
							If lAchouSD1 .Or. lAchouSFT    
							
								If lAchouSD1   
									//Somo o VALICM+ICMSCOM para ficar igual como se tivesse pegando do SF9, para depois fazer o tratamento de subtracao abaixo de uma unica Forma
									If SD1->(D1_VALFRE*D1_PICM/100) > 0 //  Verifico se tem Frete para remover do ICMS Proprio, caso este ja venha com Frete 
										nTotD1FT	:=	IIf( lSimpNac .And. SF9->F9_VALICMS == SD1->D1_ICMSCOM ,0,SD1->D1_VALICM-(SD1->(D1_VALFRE*D1_PICM/100))) //05-VL_IMOB_ICMS_OP
									Else
					                    //nTotD1FT	:=	IIf( lSimpNac .And. IIF( lAchouSF4 .and. SF4->F4_BENSATF == '1' ,(SF9->F9_VALICMS*SD1->D1_QUANT),SF9->F9_VALICMS) == SD1->D1_ICMSCOM ,0,IIF(IIF(lAchouSF4 .and. SF4->F4_BENSATF == '1'  ,(SF9->F9_VALICMS*SD1->D1_QUANT),SF9->F9_VALICMS) == SD1->D1_ICMSCOM,0,SD1->D1_VALICM)) //05-VL_IMOB_ICMS_OP
										
										If SF9->F9_VALICMS == SF9->F9_VALFRET .And. SF9->F9_VALFRET == SD1->D1_VALICM // Para os casos antigos onde o CTE gerava uma linha separada na SF9, verifico se este são iguais por que nesse caso so terei frete ma SF9 gerada.				
											nTotD1FT	:=	IIf( lSimpNac .And. SF9->F9_VALICMS == SD1->D1_ICMSCOM ,0,SD1->D1_VALICM) //05-VL_IMOB_ICMS_OP
										Else
											nTotD1FT	:=	IIf( lSimpNac .And. IIF( lAchouSF4 .and. SF4->F4_BENSATF == '1' ,(SF9->F9_VALICMS*SD1->D1_QUANT),SF9->F9_VALICMS) == SD1->D1_ICMSCOM ,0,IIF(IIF(lAchouSF4 .and. SF4->F4_BENSATF == '1'  ,(iif(SF9->F9_TIPO =='03',SD1->D1_VALICM,SF9->F9_VALICMS)*SD1->D1_QUANT),IIF(SF9->F9_TIPO =='03',SD1->D1_VALICM,SF9->F9_VALICMS)) == SD1->D1_ICMSCOM,0,SD1->D1_VALICM)) //05-VL_IMOB_ICMS_OP	
										EndIf
									Endif
									//Somo o VALICM+ICMRET para ficar igual como se tivesse pegando do SF9, para depois fazer o tratamento de subtracao abaixo de uma unica Forma
									//O Campo 5 G125 precisa ser somente o valor do ICMS 
								Else 
								
									//Somo o VALICM+ICMSCOM para ficar igual como se tivesse pegando do SF9, para depois fazer o tratamento de subtracao abaixo de uma unica Forma
									nTotD1FT	:=	IIf( lSimpNac .And. SF9->F9_VALICMS == SD1->D1_ICMSCOM ,0,SFT->FT_VALICM)//05-VL_IMOB_ICMS_OP

									//Somo o VALICM+ICMRET para ficar igual como se tivesse pegando do SF9, para depois fazer o tratamento de subtracao abaixo de uma unica Forma                                                                       
									nTotD1FT	+=	IIf(lSTCIAP == "S", SFT->FT_ICMSRET, 0) //05-VL_IMOB_ICMS_OP
									//O Campo 5 G125 precisa ser somente o valor do ICMS 
						
								EndIf	

								If lSomaBem .And. SF9->F9_TIPO == "03"	

									//Fazer um aScan no aRegG125, pois se ja gerou o bem principal, aglutino a inFormacao deste componente									
									
									// Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
									If lBuild
										nPosG125	:= FindHash(oHMG125, cChave3)
									Else
										nPosG125 := aScan( aRegG125, {|aX| aX[2]==SF9->F9_CODBAIX})
									EndIf								
									
									If nPosG125 > 0                                                 	
										aRegG125[nPosG125,5]+= nTotD1FT/nQtdSF9						//05-VL_IMOB_ICMS_OP					
									Else															
										// Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
										If lBuild
											nPosComp	:= FindHash(oHMG125Co, cChave3)
										Else
											nPosComp := aScan(aRegG125Co, {|aX| aX[2]==SF9->F9_CODBAIX})
										EndIf		
																																						
										If nPosComp > 0
											//olhar se ja nao tem inFormacao gravada																		
											aRegG125Co[nPosComp,1] += nTotD1FT/nQtdSF9		   			//05-VL_IMOB_ICMS_OP																					
											
										Else										
											aAdd(aRegG125Co,{})
											nPosComp	:=	Len (aRegG125Co)	
											aAdd (aRegG125Co[nPosComp], nTotD1FT/nQtdSF9) 				//01 - Valor do ICMS
											aAdd (aRegG125Co[nPosComp], SF9->F9_CODBAIX) 				//02 - Codigo do bem principal	
											
											//PerFormance
											If lBuild
												AddHash(oHMG125Co,cChave3,nPosComp)
											EndIf							
										EndIf 
										If lBuild
											AddHash(oHMG125,cChave3,nPosG125)
										EndIf							
									EndIf
								EndIf 
																				
								If SF9->F9_TIPO == "01"		 
																						
									If lMVSomaBem
										
										// Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
										If lBuild
											nPosComp	:= FindHash(oHMG125Co, cChave4)
										Else
											nPosComp := aScan(aRegG125Co, {|aX| aX[2]== SF9->F9_CODIGO})
										EndIf																	
										
										If nPosComp > 0										
											aRegG125[nPos,5]	:=	nTotD1FT + aRegG125Co[nPosComp,1]	//05-VL_IMOB_ICMS_OP	
											aRegG125Co[nPosComp,1] := 0							
										Else
											
												// - Alteração para buscar da Sf9 quando temos desmenbramento e é gravado com controle de sobra ou arrendaamento se buscar direto da Nota o G125 fica diferente do gravado na Sf9.
												// Nos teste com frete e desmenbramento , foi preciso retirar  o frete do F9_VALICMP.
												If lAchouSD1
													If SF9->F9_VALICMS == SF9->F9_VALFRET .And. SF9->F9_VALFRET == SD1->D1_VALICM // Para os casos antigos onde o CTE gerava uma linha separada na SF9, verifico se este são iguais por que nesse caso so terei frete .
														aRegG125[nPos,5]	:=	nTotD1FT/nQtdSF9					//05-VL_IMOB_ICMS_OP
													Else
														If SF9->F9_VALICMS == (SF9->F9_VALICMP+SF9->F9_VALICCO+SF9->F9_VALICST)
															aRegG125[nPos,5]	:=  IIF(lachouSf4 .and. SF4->F4_BENSATF == '1' ,((SF9->F9_VALICMP-SF9->F9_VALFRET)*SD1->D1_QUANT), nTotD1FT)/nQtdSF9					//05-VL_IMOB_ICMS_OP
														Else
															aRegG125[nPos,5]	:=	IIF(lachouSf4 .and. SF4->F4_BENSATF == '1' ,(SF9->F9_VALICMP*SD1->D1_QUANT),nTotD1FT)/nQtdSF9					//05-VL_IMOB_ICMS_OP
														EndIf
													Endif
													If SD1->D1_VALFRE > 0 .AND. SF9->F9_ROTINA <> "MATA905"
														If (SF9->F9_VALICMS == SF9->(F9_VALICMP+F9_VALICCO+F9_VALICST) .Or.;
														   SF9->F9_VALICMS == SF9->(F9_VALICMP+F9_VALICCO+F9_VALICST+F9_VALFRET)) .And. ; // Aqui verifico tb se tenho o Frete no F9_VALICMP e retiro o frete, cao contrario o aRegG125[nPos,5] ja esta com o ICMS sem frete.
															((aRegG125[nPos,5] + SF9->F9_VALFRET) <>  SF9->F9_VALICMP)
															aRegG125[nPos,5] -=	SF9->F9_VALFRET					//05-VL_IMOB_ICMS_OP
														Endif
													EndIf
												Endif

											//PerFormance
											If lBuild
												AddHash(oHMG125Co,cChave4,nPosComp)
											EndIf
										EndIf																					   													
									Else
										aRegG125[nPos,5]	:=	nTotD1FT/nQtdSF9						//05-VL_IMOB_ICMS_OP
									EndIf																
								Else                           
									//somo o VALICM+ICMSCOM para ficar igual como se tivesse pegando do SF9, para depois fazer o tratamento de subtracao abaixo de uma unica Forma
									aRegG125[nPos,5]	:=	nTotD1FT/nQtdSF9 //05-VL_IMOB_ICMS_OP								
								EndIf
						
								//No caso de desmembramento do ativo, o valor da nota eh dividido entre
								//e gerado varios SF9                                                 
							Else						
								
								If lSomaBem .And. SF9->F9_TIPO == "03"																			
									//Fazer um aScan no aRegG125, pois se ja gerou o bem principal, aglutino a inFormacao deste componente

									//	Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
									If lBuild
										nPosG125	:= FindHash(oHMG125, cChave3)
									Else
										nPosG125 := aScan( aRegG125, {|aX| aX[2] == SF9->F9_CODBAIX } )
									EndIf															
									
									If nPosG125 > 0
										aRegG125[nPosG125,5]	+= Iif( lSimpNac .And. SF9->F9_VALICMS == SD1->D1_ICMSCOM, 0, SF9->F9_VALICMS+nVLLEG)						//05-VL_IMOB_ICMS_OP							
										
									Else										
										// Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
										If lBuild
											nPosComp	:= FindHash(oHMG125Co, cChave3)
										Else
											nPosComp := aScan(aRegG125Co, {|aX| aX[2]==SF9->F9_CODBAIX})
										EndIf		
									
										If nPosComp > 0
											//olhar se ja nao tem inFormacao gravada																		
											aRegG125Co[nPosComp,1] += Iif( lSimpNac .And. SF9->F9_VALICMS == SD1->D1_ICMSCOM,0,IIF(SF9->F9_VALICMS <> 0 ,SF9->F9_VALICMS+nVLLEG-(SF9->F9_VALICCO+SF9->F9_VALFRET+SF9->F9_VALFRET+SF9->F9_VALICST),SF9->F9_VALICMP-IIF(SF9->F9_VALFRET> 0 .And. !(SF9->F9_ROTINA == "MATA905")  ,SF9->F9_VALFRET,0)))		   			//05-VL_IMOB_ICMS_OP																					
											
										Else
											aAdd(aRegG125Co,{})
											nPosComp	:=	Len (aRegG125Co)	

											If SF9->F9_ROTINA == 'MATA905'
												aAdd (aRegG125Co[nPosComp], IIF(SF9->F9_VALICMS <> 0 ,SF9->F9_VALICMS+nVLLEG-(SF9->F9_VALICCO+SF9->F9_VALFRET+SF9->F9_VALICST),SF9->F9_VALICMP)) 				//01 - Valor do ICMS
												aAdd (aRegG125Co[nPosComp], SF9->F9_CODBAIX)
											Else
												aAdd (aRegG125Co[nPosComp], IIF(SF9->F9_VALICMS <> 0 ,SF9->F9_VALICMS+nVLLEG-(SF9->F9_VALICCO+SF9->F9_VALFRET+SF9->F9_VALFRET+SF9->F9_VALICST),SF9->F9_VALICMP-IIF(SF9->F9_VALFRET> 0 ,SF9->F9_VALFRET,0))) 				//01 - Valor do ICMS
												aAdd (aRegG125Co[nPosComp], SF9->F9_CODBAIX) 				 		//02 - Codigo do bem principal		
											EndIf
											//PerFormance
											If lBuild
												AddHash(oHMG125Co,cChave3,nPosComp)
											EndIf												
										EndIf 
										If lBuild
											AddHash(oHMG125,cChave3,nPosG125)
										EndIf
									EndIf 									
								EndIf	 

								If SF9->F9_TIPO == "01"																	

									If lMVSomaBem
									
										// Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
										If lBuild
											nPosComp	:= FindHash(oHMG125Co, cChave4)
										Else
											nPosComp := aScan(aRegG125Co, {|aX| aX[2]== SF9->F9_CODIGO})	
										EndIf																		
										
										If nPosComp > 0	
											IF SF9->F9_ROTINA == 'ATFA251'	// Tratamento ajustado por que o Ativo esta atualizando os campos F9_VALICMP sem o valor do frete, portando nao retiro o frete novamente.								
												aRegG125[nPos,5]	:=	Iif( lSimpNac ,0,Iif(aRegG125Co[nPosComp,1] == 0 .Or. SF9->F9_VALICMS >= aRegG125Co[nPosComp,1] ,IIF(SF9->F9_VALICMS == (SF9->F9_VALFRET+SF9->F9_VALICMP+SF9->F9_VALICCO+SF9->F9_VALICST),SF9->F9_VALICMS + nVLLEG - (SF9->F9_VALFRET + SF9->F9_VALICCO + SF9->F9_VALFRET  +SF9->F9_VALICST),SF9->F9_VALICMP + nVLLEG),aRegG125Co[nPosComp,1]))		//05-VL_IMOB_ICMS_OP 
												aRegG125Co[nPosComp,1] := 0
											ElseIf SF9->F9_ROTINA == 'MATA905'
												aRegG125[nPos,5]	:=	Iif( lSimpNac ,0, aRegG125Co[nPosComp,1] )		//05-VL_IMOB_ICMS_OP 
												aRegG125Co[nPosComp,1] := 0
											ElseIf SF9->F9_ROTINA == 'ATFA040'
												aRegG125[nPos,5] := Iif( lSimpNac ,0,Iif(SF9->F9_VALICMS == SF9->F9_VALICCO, 0,SF9->F9_VALICMS) + nVLLEG) //05-VL_IMOB_ICMS_OP 
											Else												   
												aRegG125[nPos,5]	:=	Iif( lSimpNac ,0,Iif(aRegG125Co[nPosComp,1] == 0 .Or. SF9->F9_VALICMS >= aRegG125Co[nPosComp,1] ,IIF(SF9->F9_VALICMS == (SF9->F9_VALFRET+SF9->F9_VALICMP+SF9->F9_VALICCO+SF9->F9_VALICST),SF9->F9_VALICMS + nVLLEG - (SF9->F9_VALFRET + SF9->F9_VALICCO + SF9->F9_VALFRET  +SF9->F9_VALICST),SF9->F9_VALICMP-IIF(SF9->F9_VALFRET  >0 ,SF9->F9_VALFRET ,0) + nVLLEG),aRegG125Co[nPosComp,1]))		//05-VL_IMOB_ICMS_OP    
												aRegG125Co[nPosComp,1] := 0	
											Endif
										Else
											// Retiro o valor do Frete, por que o campo 5 tenho somente que ter o valor do ICMS Proprio.
											If SF9->F9_ROTINA == 'MATA905'
												If SF9->F9_VALICMP == 0	
													aRegG125[nPos,5] := Iif( lSimpNac ,0,(SF9->F9_VALICMS - SF9->F9_VALFRET-SF9->F9_VALICCO- SF9->F9_VALICST)+nVLLEG)	// Quando busco do F9_VALICMS preciso retirar nao somente o frete 
												Else
													aRegG125[nPos,5] := Iif( lSimpNac ,0,(SF9->F9_VALICMP)+nVLLEG)	
												EndIf	
											ElseIf SF9->F9_VALICMP == 0
												aRegG125[nPos,5] := Iif( lSimpNac ,0,Iif(SF9->F9_VALICMS == SF9->F9_VALICCO, 0,SF9->F9_VALICMS) + nVLLEG) //05-VL_IMOB_ICMS_OP // esta alteração  SF9->F9_VALICMS == SF9->F9_VALICCO foi feito devido a cliente do simples nacional que deixuu de ser simples issue DSERFIS1-21400
											Elseif SF9->F9_VALICMS == (SF9->F9_VALFRET+SF9->F9_VALICMP+SF9->F9_VALICCO+SF9->F9_VALICST)
												//verifico se há frete (CTE) na SF8...
												lFrtSF8 := SPEDSeek("SF8", 2, aSPDFil[PFIL_SF8]+SF9->F9_DOCNFE+SF9->F9_SERNFE+SF9->F9_FORNECE+SF9->F9_LOJAFOR)
												IF SF9->F9_VALICMS == SF9->F9_VALICMP ;// Para atender os casos onde o SF9_VALICMP nao tiver o frete
													.Or. SF9->F9_VALICMP == (SF9->F9_VALICMS-SF9->F9_VALICCO-SF9->F9_VALICST-SF9->F9_VALFRET) .And. !lFrtSF8 //...havendo, não realizo um novo desconto do frete no ICMS Próprio (DSERFIS1-29126)  
													aRegG125[nPos,5] := Iif( lSimpNac ,0,(SF9->F9_VALICMP-SF9->F9_VALFRET)+nVLLEG)						//05-VL_IMOB_ICMS_OP
												Else
													aRegG125[nPos,5] := Iif( lSimpNac ,0,(SF9->F9_VALICMP)+nVLLEG)						//05-VL_IMOB_ICMS_OP												
												Endif
											Else
												aRegG125[nPos,5] := Iif( lSimpNac ,0,SF9->F9_VALICMP- IIf(Empty(aCmpsSF9[17]),SF9->F9_VALFRET,aCmpsSF9[18])+ nVLLEG) //05-VL_IMOB_ICMS_OP
											Endif
											If lBuild
												AddHash(oHMG125Co,cChave4,nPosComp)
											EndIf
										EndIf																					   			
									Else
										aRegG125[nPos,5]	:=	Iif( lSimpNac .And. SF9->F9_VALICMS == SD1->D1_ICMSCOM,0,SF9->F9_VALICMS+nVLLEG- (SF9->F9_VALICCO+SF9->F9_VALFRET+SF9->F9_VALFRET+SF9->F9_VALICST))									//05-VL_IMOB_ICMS_OP
									EndIf
								Else
									If SF9->F9_VALICMS <> 0
										If SF9->F9_ROTINA == 'MATA905'	
											aRegG125[nPos,5]	:= 	SF9->F9_VALICMP
										Else
											aRegG125[nPos,5]	:=  Iif( lSimpNac .And. SF9->F9_VALICMS == SD1->D1_ICMSCOM,0,SF9->F9_VALICMS+nVLLEG- (SF9->F9_VALICCO+SF9->F9_VALFRET+SF9->F9_VALICST+SF9->F9_VALFRET))										//05-VL_IMOB_ICMS_OP
										EndIf										
									Endif
									//  Se o item componente for incluso direto pelo MATA905 e o valor de 05-VL_IMOB_ICMS_OP for = 0 
									If aRegG125[ nPos,4 ] == "IA" .And. aRegG125[nPos,5] = 0
										If SF9->F9_ROTINA == 'MATA905'	
											aRegG125[nPos,5]	:= 	SF9->F9_VALICMP	
										Else      
											aRegG125[nPos,5] := SF9->F9_BXICMS - SF9->F9_VALFRET - IIF( (SF9->F9_VALICCO+SF9->F9_VALFRET+SF9->F9_VALICST) > 0 , (SF9->F9_VALICCO+SF9->F9_VALFRET+SF9->F9_VALICST),0) 
										Endif
									Endif	
								EndIf											
							EndIf	
			
							//Tratamento para quando obter o valor atraves do documento fiscal, onde o valor estah cheio
							If lAchouSD1 .Or. lAchouSFT                                                                 
							
								//ICMS ST calculado no documento fiscal                  
								If lAchouSD1
									nTotD1FT	:=	IIf(lSTCIAP == "S", SD1->D1_ICMSRET, 0)	//06-VL_IMOB_ICMS_ST
									
								Else
									nTotD1FT	:=	IIf(lSTCIAP == "S", SFT->FT_ICMSRET, 0)	//06-VL_IMOB_ICMS_ST
									
								EndIf
						
								If lSomaBem .And. SF9->F9_TIPO == "03"
								
									If lMvSomaBem

										//Fazer um aScan no aRegG125, pois se ja gerou o bem principal, aglutino a inFormacao deste componente

										// Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
										If lBuild
											nPosG125	:= FindHash(oHMG125, cChave3)
										Else
											nPosG125 := aScan( aRegG125, {|aX| aX[2]==SF9->F9_CODBAIX})
										EndIf										
										
										If nPosG125 > 0											
											aRegG125[nPosG125,6] +=	nTotD1FT / nQtdSF9			 		//06-VL_IMOB_ICMS_ST																						
										Else										
											If lBuild
												nPosComp	:= FindHash(oHMG125St, cChave3)
											Else
												nPosComp := aScan(aRegG125St, {|aX| aX[2]==SF9->F9_CODBAIX})
											EndIf	
												
											If nPosComp > 0
												//olhar se ja nao tem inFormacao gravada																		
												aRegG125St[nPosComp,1] += nTotD1FT/nQtdSF9				//06-VL_IMOB_ICMS_ST																					
											Else										
												aAdd(aRegG125St,{})
												nPosComp	:=	Len (aRegG125St)	
												aAdd (aRegG125St[nPosComp], nTotD1FT/nQtdSF9	) 		//01 - Valor do ICMS ST
												aAdd (aRegG125St[nPosComp], SF9->F9_CODBAIX) 			//02 - Codigo do bem principal										
												
												//PerFormance
												If lBuild
													AddHash(oHMG125St,cChave3,nPosComp)
												EndIf
											EndIf 
											//PerFormance
											If lBuild
												AddHash(oHMG125,cChave3,nPosG125)
											EndIf
										EndIf		
																																																						
									EndIf
								EndIf
								
								If SF9->F9_TIPO == "01"
								
									If lMVSomaBem
										// Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
										If lBuild
											nPosComp	:= FindHash(oHMG125St, cChave4)
										Else
											nPosComp 	:= aScan(aRegG125St, {|aX| aX[2]== SF9->F9_CODIGO})	
										EndIf	
									
										If nPosComp > 0										
											aRegG125[nPos,6]	+=	IIf(lSTCIAP=="S",aRegG125St[nPosComp,1],0)		//06-VL_IMOB_ICMS_ST	
											aRegG125St[nPosComp,1] := 0							
											
										Else
											aRegG125[nPos,6]	:=	nTotD1FT / nQtdSF9			//06-VL_IMOB_ICMS_ST
											
											//PerFormance
											If lBuild
												AddHash(oHMG125St,cChave4,nPosComp)
											EndIf
											
										EndIf																					   			
									Else
										aRegG125[nPos,6]	:=	nTotD1FT / nQtdSF9				//06-VL_IMOB_ICMS_ST
										
									EndIf								
								Else
									aRegG125[nPos,6]	:=	nTotD1FT / nQtdSF9					//06-VL_IMOB_ICMS_ST
									
								EndIf							
							
							Else
								
								If lSomaBem .And. SF9->F9_TIPO == "03"
								
									If lMvSomaBem	   
										//Fazer um aScan no aRegG125, pois se ja gerou o bem principal, aglutino a inFormacao deste componente									
										
										// Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
										If lBuild
											nPosG125	:= FindHash(oHMG125, cChave3)
										Else
											nPosG125 := aScan(aRegG125, {|aX| aX[2]==SF9->F9_CODBAIX})	
										EndIf	
										
										If nPosG125 > 0
											aCmpsSF9[20] := Iif(!Empty(aCmpsSF9[19]) .And. aCmpsSF9[20] > 0, aCmpsSF9[20], SF9->F9_VALICST)											
											aRegG125[nPosG125,6]	+=	IIf(lSTCIAP=="S",aCmpsSF9[20],0)				 	//06-VL_IMOB_ICMS_ST																						
										Else										
											
											// Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
											If lBuild
												nPosComp	:= FindHash(oHMG125St, cChave3)
											Else
												nPosComp := aScan(aRegG125St, {|aX| aX[2]==SF9->F9_CODBAIX})		
											EndIf	
									
											If nPosComp > 0
												aCmpsSF9[20] := Iif(!Empty(aCmpsSF9[19]) .And. aCmpsSF9[20] > 0, aCmpsSF9[20], SF9->F9_VALICST)
												//olhar se ja nao tem inFormacao gravada																		
												aRegG125St[nPosComp,1] += aCmpsSF9[20]				 	//06-VL_IMOB_ICMS_ST																					
											Else										
												aAdd(aRegG125St,{})
												nPosComp	:=	Len (aRegG125St)	
												aAdd (aRegG125St[nPosComp], Iif(!Empty(aCmpsSF9[19]) .And. aCmpsSF9[20] > 0, aCmpsSF9[20], SF9->F9_VALICST)	) 			//01 - Valor do ICMS ST
												aAdd (aRegG125St[nPosComp], SF9->F9_CODBAIX) 			//02 - Codigo do bem principal										
												
												//PerFormance
												If lBuild
													AddHash(oHMG125St,cChave3,nPosComp)
												EndIf
												
											EndIf
											//PerFormance
											If lBuild
												AddHash(oHMG125,cChave3,nPosG125)
											EndIf 
										EndIf		
																																																						
									EndIf
								EndIf
								
								If SF9->F9_TIPO == "01"
								
									If lMVSomaBem     
									
										// Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
										If lBuild
											nPosComp	:= FindHash(oHMG125St, cChave4)
										Else
											nPosComp := aScan(aRegG125St, {|aX| aX[2]== SF9->F9_CODIGO})		
										EndIf	
																											
										If nPosComp > 0										
											aRegG125[nPos,6]	+=	IIf(lSTCIAP=="S",Iif(aRegG125St[nPosComp,1] == 0 .Or. SF9->F9_VALICST >= aRegG125St[nPosComp,1],SF9->F9_VALICST,aRegG125St[nPosComp,1]),0)		//06-VL_IMOB_ICMS_ST	
											aRegG125St[nPosComp,1] := 0							
											
										Else
											aCmpsSF9[20] := Iif(!Empty(aCmpsSF9[19]) .And. aCmpsSF9[20] > 0, aCmpsSF9[20], SF9->F9_VALICST) 
											aRegG125[nPos,6]	:=	IIf(lSTCIAP=="S",aCmpsSF9[20],0)				//06-VL_IMOB_ICMS_ST
											//PerFormance
											If lBuild
												AddHash(oHMG125St,cChave4,nPosComp)
											EndIf 
																						
										EndIf																					   			
									Else
										aCmpsSF9[20] := Iif(!Empty(aCmpsSF9[19]) .And. aCmpsSF9[20] > 0, aCmpsSF9[20], SF9->F9_VALICST)
										aRegG125[nPos,6]	:=	IIf(lSTCIAP=="S",aCmpsSF9[20],0)					//06-VL_IMOB_ICMS_ST
									EndIf								
								Else
									aCmpsSF9[20] := Iif(!Empty(aCmpsSF9[19]) .And. aCmpsSF9[20] > 0, aCmpsSF9[20], SF9->F9_VALICST)
									aRegG125[nPos,6]	:=	IIf(lSTCIAP=="S",aCmpsSF9[20],0)						//06-VL_IMOB_ICMS_ST
								EndIf

							EndIf
			
							//ICMS sobre o frete calculado no documento fiscal

							//Tratamento para verIficar se o frete estah compondo a  
							//base de calculo do ICMS para poder separar neste      
							//registro.                                             				
							If cDespAcICM $ "S/1/5"
							
								//Tratamento para quando obter o valor atraves do documento fiscal, onde o valor estah cheio
								If lAchouSD1 .Or. lAchouSFT
								
									If lAchouSD1
										nTotD1FT	:=	Iif(SD1->D1_TIPO == "C" .AND. SF9->F9_VALFRET == 0,SD1->(D1_VALFRE*D1_PICM/100),SF9->F9_VALFRET)	//07-VL_IMOB_ICMS_FRT
									Else
										nTotD1FT	:=	Iif(SFT->FT_TIPO == "C" .AND. SF9->F9_VALFRET == 0,SFT->(FT_FRETE*FT_ALIQICM/100),SF9->F9_VALFRET)	//07-VL_IMOB_ICMS_FRT
									EndIf
							
									If lSomaBem .And. SF9->F9_TIPO == "03"									
										If lMvSomaBem			   

											//Fazer um aScan no aRegG125, pois se ja gerou o bem principal, aglutino a inFormacao deste componente

											// Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
											If lBuild
												nPosG125	:= FindHash(oHMG125, cChave3)
											Else
												nPosG125 := aScan(aRegG125, {|aX| aX[2]==SF9->F9_CODBAIX})				
											EndIf
											
											If nPosG125 > 0											
												aRegG125[nPosG125,7]	+= nTotD1FT		 			//07-VL_IMOB_ICMS_FRT																						
												
											Else										
												
												If lBuild
													nPosComp	:= FindHash(oHMG125Fr, cChave3)
												Else
													nPosComp := aScan(aRegG125Fr, {|aX| aX[2]==SF9->F9_CODBAIX})			
												EndIf																														
												
												If nPosComp > 0
													//olhar se ja nao tem inFormacao gravada																		
													aRegG125Fr[nPosComp,1] += nTotD1FT				 	//07-VL_IMOB_ICMS_FRT								
																										
												Else										
													aAdd(aRegG125Fr,{})
													nPosComp	:=	Len (aRegG125Fr)	
													aAdd (aRegG125Fr[nPosComp], nTotD1FT	) 			//01 - Valor do ICMS ST
													aAdd (aRegG125Fr[nPosComp], SF9->F9_CODBAIX) 				//02 - Codigo do bem principal										
													
													//PerFormance
													If lBuild
														AddHash(oHMG125Fr,cChave3,nPosComp)
													EndIf 
												EndIf 
												If lBuild
													AddHash(oHMG125,cChave3,nPosG125)
												EndIf 
											EndIf																																																									
										EndIf
									EndIf
									
									If SF9->F9_TIPO == "01"
									
										If lMVSomaBem 
										
											// Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
											If lBuild
												nPosComp	:= FindHash(oHMG125Fr, cChave4)
											Else
												nPosComp := aScan(aRegG125Fr, {|aX| aX[2]== SF9->F9_CODIGO})			
											EndIf        
																		
											If nPosComp > 0										
												aRegG125[nPos,7]	+=	aRegG125Fr[nPosComp,1]		//07-VL_IMOB_ICMS_FRT	
												aRegG125St[nPosComp,1] := 0							
												
											Else
												aRegG125[nPos,7]	:=	 nTotD1FT 		//07-VL_IMOB_ICMS_FRT

												//PerFormance
												If lBuild
													AddHash(oHMG125Fr,cChave4,nPosComp)
												EndIf 										
												
											EndIf																					   			
										Else
											aRegG125[nPos,7]	:=	nTotD1FT			//07-VL_IMOB_ICMS_FRT
																					
										EndIf								
									Else
										aRegG125[nPos,7]	:=	nTotD1FT 					//07-VL_IMOB_ICMS_FRT
										
									EndIf								
									
								Else

									If lSomaBem .And. SF9->F9_TIPO == "03"
									
										If lMvSomaBem			 
										
											//Fazer um aScan no aRegG125, pois se ja gerou o bem principal, aglutino a inFormacao deste componente

											// Se build superior a "7.00.131227A" faz a busca no HashMap para ganho de perFormance.
											If lBuild
												nPosG125	:= FindHash(oHMG125, cChave3)
											Else
												nPosG125 := aScan(aRegG125, {|aX| aX[2]==SF9->F9_CODBAIX})				
											EndIf								
											
											If nPosG125 > 0											
												aCmpsSF9[18] := Iif(!Empty(aCmpsSF9[17]) .And. aCmpsSF9[18] > 0, aCmpsSF9[18], SF9->F9_VALFRET)
												aRegG125[nPosG125,7]	+=	aCmpsSF9[18]				 		//07-VL_IMOB_ICMS_FRT	
												
												//Retiro o valor do frete do ICMS proprio do campo 05. Pois quando lancado manualmente   ³
												//ou por nota o valor jah estah embutido no F9_VALICMS                                 
												//aRegG125[nPosG125,5]	-= aCmpsSF9[18]							//07-VL_IMOB_ICMS_FRT						
											Else										
												
												If lBuild
													nPosComp	:= FindHash(oHMG125Fr, cChave3)
												Else
													nPosComp 	:= aScan(aRegG125Fr, {|aX| aX[2]==SF9->F9_CODBAIX})	
												EndIf	
																													
												If nPosComp > 0
												    aCmpsSF9[18] := Iif(!Empty(aCmpsSF9[17]) .And. aCmpsSF9[18] > 0, aCmpsSF9[18], SF9->F9_VALFRET) 
													//olhar se ja nao tem inFormacao gravada																		
													aRegG125Fr[nPosComp,1] += aCmpsSF9[18]				 		//07-VL_IMOB_ICMS_FRT																				
												Else										
													aAdd(aRegG125Fr,{})
													nPosComp	:=	Len (aRegG125Fr)	
													aAdd (aRegG125Fr[nPosComp], Iif(!Empty(aCmpsSF9[17]) .And. aCmpsSF9[18] > 0, aCmpsSF9[18], SF9->F9_VALFRET)) 				//01 - Valor do Frete
													aAdd (aRegG125Fr[nPosComp], SF9->F9_CODBAIX) 				//02 - Codigo do bem principal	
													
													If lBuild
														AddHash(oHMG125Fr,cChave3,nPosComp)
													EndIf
																						
												EndIf 
												If lBuild
													AddHash(oHMG125,cChave3,nPosG125)
												EndIf
											EndIf		
																																																							
										EndIf
									EndIf
									
									If SF9->F9_TIPO == "01"									
										If lMVSomaBem
										
											If lBuild
												nPosComp	:= FindHash(oHMG125Fr, cChave4)
											Else
												nPosComp 	:= aScan(aRegG125Fr, {|aX| aX[2]== SF9->F9_CODIGO})		
											EndIf
																			
											If nPosComp > 0										
												aRegG125[nPos,7]	+=	Iif(aRegG125Fr[nPosComp,1] == 0 .Or. SF9->F9_VALFRETE >= aRegG125Fr[nPosComp,1],SF9->F9_VALFRETE,aRegG125Fr[nPosComp,1])		//07-VL_IMOB_ICMS_FRT	
												aRegG125Fr[nPosComp,1] := 0							
											Else
												If SF9->F9_VALICMS == SF9->F9_VALFRET // Tratamento para quando uso MV_F9SKPNF = T onde busco do campos da SF9 direto e a SF9 é referente a uma CTE não levo o valor de frete no campo 7 do g125
											    	IF SF9->F9_ROTINA ="MATA103"
														aCmpsSF9[18]	:= 0 // Quando temos somente Sf9 de CTE gerada no passdo onde o CTE era um ATIVO se estou utilizando mv_F9SKPNF = T nao carrego o campo de frete no campo 7
													ElseIf SF9->F9_ROTINA ="MATA905" // Issue DSERFIS1-26880 , nesse caso posso ter um inclusao manual onde o F9_VALICMP == 0 e o F9_VALICMS pode ser igual ao F9_VALFRET
														aCmpsSF9[18] := Iif(!Empty(aCmpsSF9[17]) .And. aCmpsSF9[18] > 0, aCmpsSF9[18], SF9->F9_VALFRET)
													EndIf
												Else	
													aCmpsSF9[18] := Iif(!Empty(aCmpsSF9[17]) .And. aCmpsSF9[18] > 0, aCmpsSF9[18], SF9->F9_VALFRET) 
												Endif

												aRegG125[nPos,7]	:=	aCmpsSF9[18]				//07-VL_IMOB_ICMS_FRT
												
												If lBuild
													AddHash(oHMG125Fr,cChave4,nPosComp)	
												EndIf
																						
											EndIf																					   			
										Else
										    aCmpsSF9[18] := Iif(!Empty(aCmpsSF9[17]) .And.aCmpsSF9[18] > 0, aCmpsSF9[18], SF9->F9_VALFRET) 
											aRegG125[nPos,7]	:=	aCmpsSF9[18]					//07-VL_IMOB_ICMS_FRT
										EndIf								
									Else
									    aCmpsSF9[18] := Iif(!Empty(aCmpsSF9[17]) .And. aCmpsSF9[18] > 0, aCmpsSF9[18], SF9->F9_VALFRET) 
										aRegG125[nPos,7]	:=	aCmpsSF9[18]						//07-VL_IMOB_ICMS_FRT
									EndIf								
								EndIf
							EndIf
		
							//Tratamento para quando obter o valor atraves do documento fiscal, onde o valor estah cheio
							If lAchouSD1 .Or. lAchouSFT                                                                 
							
								//ICMS Complementar calculado no documento fiscal        
								If lAchouSD1
									nTotD1FT	:=	IIf(cDaCiap=="S",SD1->D1_ICMSCOM,0)//08-VL_IMOB_ICMS_DIf
									//nTotD1FT	:=	SD1->D1_ICMSCOM //08-VL_IMOB_ICMS_DIf
								Else
									nTotD1FT	:=	IIf(cDaCiap=="S",SFT->FT_ICMSCOM,0)//08-VL_IMOB_ICMS_DIf
									//nTotD1FT	:=	SD1->D1_ICMSCOM //08-VL_IMOB_ICMS_DIf
								EndIf
						
								If lSomaBem .And. SF9->F9_TIPO == "03"									
									
									If lMvSomaBem										
										
										//Fazer um aScan no aRegG125, pois se ja gerou o bem principal, aglutino a inFormacao deste componente									
										If lBuild
											nPosG125	:= FindHash(oHMG125, cChave3)
										Else
											nPosG125 := aScan(aRegG125, {|aX| aX[2]==SF9->F9_CODBAIX})			
										EndIf
															
										If nPosG125 > 0											
											aRegG125[nPosG125,8]	+=	nTotD1FT/nQtdSF9				 	//08-VL_IMOB_ICMS_DIf																						
											
										Else										
																						
											If lBuild
												nPosComp	:= FindHash(oHMG125Cm, cChave3)
											Else
												nPosComp := aScan(aRegG125Cm, {|aX| aX[2]==SF9->F9_CODBAIX})			
											EndIf
																																									
											If nPosComp > 0
												//olhar se ja nao tem inFormacao gravada																		
												aRegG125Cm[nPosComp,1] += nTotD1FT/nQtdSF9		 			//08-VL_IMOB_ICMS_DIf																					
												
											Else										
												aAdd(aRegG125Cm,{})
												nPosComp	:=	Len (aRegG125Cm)	
												aAdd (aRegG125Cm[nPosComp], nTotD1FT/nQtdSF9)			//01 - Valor do ICMS ST
												aAdd (aRegG125Cm[nPosComp], SF9->F9_CODBAIX) 				//02 - Codigo do bem principal	
												
												If lBuild
													AddHash(oHMG125Cm,cChave3,nPosComp)
												EndIf								
											EndIf 
											If lBuild
												AddHash(oHMG125,cChave3,nPosG125)
											EndIf
										EndIf																																																									
									EndIf
								EndIf
								
								If SF9->F9_TIPO == "01"
								
									If lMVSomaBem
									
										If lBuild
											nPosComp	:= FindHash(oHMG125Cm, cChave4)
										Else
											nPosComp 	:= aScan(aRegG125Cm, {|aX| aX[2]== SF9->F9_CODIGO})				
										EndIf
																		
										If nPosComp > 0										
											aRegG125[nPos,8]	+=	aRegG125Cm[nPosComp,1]		//08-VL_IMOB_ICMS_DIf	
											//aRegG125St[nPosComp,1] := 0							
										Else//Incluido controde para quando for desmembramento buscar do F9_VALICCO, por que no FISXCIAP fiz a gravação com controle de 
										    //arredondamento e sobras e se busca direto da nota os valores não irao bater. pois la nao tem controle de sobra .
											aRegG125[nPos,8]	:=	IIf(cDaCiap=="S", IIF(lachouSf4 .and. SF4->F4_BENSATF == '1' ,(SF9->F9_VALICCO*SD1->D1_QUANT),nTotD1FT)/nQtdSF9, 0)			//08-VL_IMOB_ICMS_DIf
											If lBuild
												AddHash(oHMG125Cm,cChave4,nPosComp)
											EndIf										
										EndIf																					   			
									Else
										aRegG125[nPos,8]	:=	nTotD1FT/nQtdSF9				//08-VL_IMOB_ICMS_DIf
									EndIf								
								Else
									aRegG125[nPos,8]	:=	nTotD1FT/nQtdSF9					//08-VL_IMOB_ICMS_DIf
								EndIf								

							Else
																				
								If lSomaBem .And. SF9->F9_TIPO == "03"	 
															
									If lMvSomaBem										
										
										//Fazer um aScan no aRegG125, pois se ja gerou o bem principal, aglutino a inFormacao deste componente									
										If lBuild
											nPosG125	:= FindHash(oHMG125, cChave3)
										Else
											nPosG125 := aScan(aRegG125, {|aX| aX[2]==SF9->F9_CODBAIX})				
										EndIf								
										
										If nPosG125 > 0											
											aCmpsSF9[22] := Iif(!Empty(aCmpsSF9[21]) .And. aCmpsSF9[22] > 0, aCmpsSF9[22], SF9->F9_VALICCO)
											aRegG125[nPosG125,8]	+=	IIf(cDaCiap=="S",aCmpsSF9[22],0) //08-VL_IMOB_ICMS_DIf											
											lCalcImp := .T.					
										Else										
											
											If lBuild
												nPosComp	:= FindHash(oHMG125Cm, cChave3)
											Else
												nPosComp 	:= aScan(aRegG125Cm, {|aX| aX[2]==SF9->F9_CODBAIX})					
											EndIf	
																																								
											If nPosComp > 0  
											
												//olhar se ja nao tem inFormacao gravada																		
												aRegG125Cm[nPosComp,1] += IIf(cDaCiap=="S",aCmpsSF9[22],0)	//08-VL_IMOB_ICMS_DIf																				
											Else										
												aAdd(aRegG125Cm,{})
												nPosComp	:=	Len (aRegG125Cm)	
												aAdd (aRegG125Cm[nPosComp], IIf(cDaCiap=="S",aCmpsSF9[22],0)) //01 - Valor do ICMS Complementar
												aAdd (aRegG125Cm[nPosComp], SF9->F9_CODBAIX) 				 //02 - Codigo do bem principal	 
												
												If lBuild
													AddHash(oHMG125Cm,cChave3,nPosComp)
												EndIf	  
																					
											EndIf 
											If lBuild
												AddHash(oHMG125,cChave3,nPosG125)
											EndIf	 
										EndIf																																																								
									EndIf
								EndIf
								
								If SF9->F9_TIPO == "01"									
									If lMVSomaBem
									
										If lBuild
											nPosComp	:= FindHash(oHMG125Cm, cChave4)
										Else
											nPosComp 	:= aScan(aRegG125Cm, {|aX| aX[2]== SF9->F9_CODIGO})						
										EndIf	
																	
										If nPosComp > 0										
											aRegG125[nPos,8]	+=	Iif(aRegG125Cm[nPosComp,1] == 0 .Or. SF9->F9_VALICCO >= aRegG125Cm[nPosComp,1],SF9->F9_VALICCO,aRegG125Cm[nPosComp,1])		//08-VL_IMOB_ICMS_DIf
											//aRegG125[nPos,5]	-=	aRegG125Cm[nPosComp,1]		//05-VL_IMOB_ICMS_OP																								
											aRegG125Cm[nPosComp,1] := 0							
											
										Else
											aCmpsSF9[22] := Iif(!Empty(aCmpsSF9[21]) .And. aCmpsSF9[22] > 0, aCmpsSF9[22], SF9->F9_VALICCO)
											aRegG125[nPos,8]	:=	IIf(cDaCiap=="S",aCmpsSF9[22],0)									//08-VL_IMOB_ICMS_DIf
											//aRegG125[nPos,5]	-=	IIf(cDaCiap=="S",aCmpsSF9[22],0)				//05-VL_IMOB_ICMS_OP		
											
											If lBuild
												AddHash(oHMG125Cm,cChave4,nPosComp)
											EndIf										
										EndIf
									Else
										aCmpsSF9[22] := Iif(!Empty(aCmpsSF9[21]) .And. aCmpsSF9[22] > 0, aCmpsSF9[22], SF9->F9_VALICCO)
										aRegG125[nPos,8]	:=	IIf(cDaCiap=="S",aCmpsSF9[22],0)									//08-VL_IMOB_ICMS_DIf
										//aRegG125[nPos,5]	-=	IIf(cDaCiap=="S",aCmpsSF9[22],0)									//05-VL_IMOB_ICMS_OP										
										
									EndIf								
								Else
									If !lCalcImp       
										aCmpsSF9[22] := Iif(!Empty(aCmpsSF9[21]) .And. aCmpsSF9[22] > 0, aCmpsSF9[22], SF9->F9_VALICCO)
										aRegG125[nPos,8]	:=	IIf(cDaCiap=="S",aCmpsSF9[22],0)									//08-VL_IMOB_ICMS_DIf
										//aRegG125[nPos,5]	-=	IIf(cDaCiap=="S",aCmpsSF9[22],0)									//05-VL_IMOB_ICMS_OP 
									Endif																
								EndIf								
							EndIf							
						EndIf
	                
	                	lSomaBem := .F.
	                    
						//Quando manda gerar um novo SI mudando o nTo para dois, nao devo pegar os valores, devo enviar ZERADO
						//Tratamento atende o item4 dos requisitos do registro G125 do SPED Fiscal, Campos 05, 06, 07 e 08    
						If nTo==1  
							//Quando entrada ou consumo de componente de um bem que está sendo construído no estabelecimento do 
							//contribuinte deverá ser inFormado com o tipo de movimentação "IA", no período de ocorrência do fato. 
							//Os campos NUM_PARC e VL_PARC_PASS não podem ser inFormados (*Guia Prático EFD - Versão 2.0.9)         
							If !lMVAprComp .And. cTpMovBem == "IA"
								//SE O PARAMETRO ESTIVER FALSO NÃO GEREI SFA E CONSEQUENTEMENTE DEVO GERAR OS VALORES IGUAIS A 0
								//APENAS SE For COMPONENTE
								If SF9->F9_TIPO == "03"
									nQtdPSFA  := 0  
									nLimParc  := 0											
								EndIf										
							EndIf	
									
							aRegG125[nPos,9]	:= AllTrim(Str(nQtdPSFA))					//09-NUM_PARC		
							//Valor passivel de apropriacao eh o valor bruto dividido pela quantidade   
							//de parcelas prevista em legislação, sem a aplicacao do percentual correto
							aRegG125[nPos,10] := aRegG125[nPos,5]+aRegG125[nPos,6]+aRegG125[nPos,7]+aRegG125[nPos,8]
							aRegG125[nPos,10] := IIf(nQtdPSFA > 0,aRegG125[nPos,10]/nLimParc,0)		//10-VL_PARC_PASS  
							aRegG125[nPos,10] := If(lRndCiap,Round(aRegG125[nPos,10],2),NoRound(aRegG125[nPos,10],2))
							nMeses := nLimParc - SF9->F9_SLDPARC
							If lPRatDieAp .And. ((Month( dDataAte )==Month( SF9->F9_DTENTNE ) .And. Year( dDataAte )==Year( SF9->F9_DTENTNE )) .Or. nMeses==nLimParc-1) ///Parametro ProRatDei Primeira ou ultima Aporpriaçao e Rateada
								If nMeses==nLimParc-1
									nValor	:=	( aRegG125[nPos,10]/Day( LastDay( dDataAte ) ) )*( Day( SF9->F9_DTENTNE )-1 )
									aRegG125[nPos,10] := If(lRndCiap,Round(nValor,2),NoRound(nValor,2))
								Else//Quando for a primeira apropriacao do ativo
									nValor	:=	(aRegG125[nPos,10]/Day( LastDay( dDataAte ) ))*Iif( dDataAte-SF9->F9_DTENTNE==0,1,dDataAte-SF9->F9_DTENTNE )
									aRegG125[nPos,10] := If(lRndCiap,Round(nValor,2),NoRound(nValor,2))
								EndIf
							ElseIf lPRatDieAp .And. SF9->F9_BXICMS <> 0 .And. SF9->F9_MOTIVO <> " " // Quando houver a baixa vou recuperar o valor calculo no MATA906 que faz o calculo correto e grava certo na SFA.  
								nValor := (cAliasSFA)->FA_VALOR
								aRegG125[nPos,10] := If(lRndCiap,Round(nValor,2),NoRound(nValor,2))
							EndIF
						EndIf
		
						//Somatorio de todas as parcelas de ICMS passivel de apropriacao para   
						//compor o campo 05 do registro G110 - SOM_PARC                        
						nC05G110	+=	aRegG125[nPos,10]						
					EndIf                                                                   	
		
					//Tratamento para gerar mais de um registro G125 para o mesmo SFA
					If lGeraBA .Or. lGeraSI
						nTo	:=	2
					EndIf
					
					If lExtratTAF
						aadd( aRegT050AA, aRegG125[nPos] )
					EndIf

					//Alimento Array Global dos registros G125|G126|G130|G140//Desta forma ja alinhando o array de gravação da forma como deve ser impresso no arquivo TXT FINAL
					//aadd( aG25130140, aRegG125[nPos] ) //Trecho base para reaproveitamento de gravação sem utilizar o SPEDREGs e sim aproveitar a regra que o processamento dos registros ja fez ou seja ir mapeando conforme o fonte é executado, quais registros e seus filho/netos serao impressos.

					//Funcao que monta e retorna as inFormacoes dos documentos fiscais para geracao dos       
					//registros G130 e G140                                                                 
					aInfRegs := SPDG130140(lTop,cAliasSFA,aRegG125[nPos,4],lAchouSFT,lAchouSA2,aCmpsSF9,@aReg0150,cAlias,aWizard,lAchouSB1,@aReg0200,@aReg0190,@aReg0220,nRecnoSFT,lF9SKPNF,aExistBloc,,lExtratTAF,lConcFil,nVLLEG,cDaCiap,nQtdSF9,lSTCIAP)                                                                                                                                                        

					If aRegG125[Len(aRegG125),4]=="SI" //.And. aInfRegs[1][10]<>"BFINAL"
						nC04G110	+=	aRegG125[Len(aRegG125),5]+aRegG125[Len(aRegG125),6]+aRegG125[Len(aRegG125),7]+aRegG125[Len(aRegG125),8]
					EndIf

					If Len(aInfRegs[1])>0
						If len(aInfRegs[1])>=10
							//Somatorio de todos os SIs do periodo para compor o campo 04 do registro
							//G110 - SALDO_IN_ICMS                                                  

	                        If aInfRegs[1][10]=="BFINAL"
	                            aInfRegCom :=   SpedCompAtf(SubStr(aInfRegs[1][10],1,TamSX3("F9_CODIGO")[01]),dDataDe,dDataAte,@aReg0150,cAlias,aWizard,aExistBloc,@aRegG125,@nC04G110,cDaCiap,nQtdSF9,lSTCIAP)  //mauro
	                            If Len(aInfRegCom[1]) > 0
	                                aInfRegs := aClone(aInfRegCom)
	                            EndIf
	                        EndIf
	                    EndIf
	                    For nA:=1 to Len(aInfRegs)
                            If lSpedG126 .Or. lProdG126
								If lSpedG126
									aRegG126 	:= 	Execblock("SPEDG126", .F., .F.,{nPos,cAliasSFA,aRegG126,aRegG125[nPos,2]})
								ElseIf lProdG126
									/*REGISTRO G126: OUTROS CRÉDITOS CIAP*/
									aRegG126 := RegG126(nPos,aRegG126,aRegG125[nPos,2],dDataDe,dDataAte,nX3codBem,cPerG126)
								EndIf
							EndIf
							
							If len(aInfRegs[nA]) > 0

								//VL_ICMS_OP_APLICADO - Valor do ICMS da Operação Própria na entrada do item, proporcional à quantidade aplicada no bem ou componente
								//Issue DSERFIS1-29122, Tratamento para quando as tabelas do cliente estão com valores errados (Desmembramento com round, feito em fontes antigos)
								if cVersao >= "014" .and. aInfRegs[nA][14] < aRegG125[nPos,5] .and. len(aInfRegs) == 1
									aInfRegs[nA][14] := aRegG125[nPos,5]
								endif
								
	                            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	                            //|REGISTRO G130 - IDENTIfICACAO DO DOCUMENTO                                              |
	                            //|A gravacao do array aRegG130 deverah ser efetua da no final do processamento, pois esta |
	                            //|  funcao somente o alimenta                                                             |
	                            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                           		 nPosG130    :=  RegG130(nPos,@aRegG130,aInfRegs[nA],lExtratTAF, aRegT050AC )
	                            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	                            //|REGISTRO G140 - IDENTIfICACAO DO ITEM DO DOCUMENTO                                      |
	                            //|A gravacao do array aRegG140 deverah ser efetua da no final do processamento, pois esta |
	                            //|  funcao somente o alimenta                                                             |
	                            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                            RegG140(nPosG130,@aRegG140,aInfRegs[nA],lExtratTAF, aRegT050AD)
	                            If !lExtratTAF
	                                If aScan(aReg0200, {|aX| aX[2] == aInfRegs[nA][9]}) == 0
	                                    lAchouSB1 := SPEDSeek("SB1",,xFilial("SB1")+aInfRegs[nA][9])
	                                    SFRG0200(cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, ,aInfRegs[nA][9], @aReg0220,,,,,,,,,,,,,,,,,,,aWizard)
	                                EndIf
	                            EndIf
							EndIf
                        Next
						// Adicionando o For depois para que nao duplique o campo 10 do G110
						If Len(aRegG126)>0
									For nX126	:= 1 to Len(aRegG126)
										If aRegG126[nX126,1] == nPos //Somente considera registro filgo G126 do mesmo pai G125.
											nC10G110 	+= 	aRegG126[nX126,10]
										EndIf
									Next nX126
						EndIf
                    EndIf

					//Funcao que retorna inFormacoes da classIficacao do ativo, utilizado para montar os      
					//registros 0300, 0305, 0500 e 0600                                                     
					aClasCIAP := SpedBGCIAP(lAchouSB1,lAchouSN3,lAchouSD1,cMVF9CTBCC,aCmpsSF9,lCtbInUse,cMVF9GENCC,cMVF9GENCT,lF9SKPNF,lConcFil,lExtratTAF)
					If Len( aClasCIAP ) > 0                                                                             
						//REGISTRO 0300 - CADASTRO DE BENS OU COMPONENTES DO ATIVO IMOBILIZADO                    
						//REGISTRO 0305 - INForMACAO SOBRE A UTILIZACAO DO BEM                                    
						//Funcao independente, gera a estrutura e efetua a gravacao no TRB                        
						R03000305(cAlias,aClasCIAP,nLimParc,cCodCiap,aCmpsSF9,@aReg0300,@aReg0305,cAliasSFA)
						//REGISTRO 0500 - PLANO DE CONTAS CONTABEIS                                                                                                                                       
						//Funcao independente, gera a estrutura e efetua a gravacao no TRB                        
						Reg0500(cAlias,aClasCIAP,lCtbInUse,@aReg0500,lExtratTAF)
						//REGISTRO 0600 - CENTRO DE CUSTO                                                         
						//Funcao independente, gera a estrutura e efetua a gravacao no TRB                        
						Reg0600(cAlias,aClasCIAP,lCtbInUse,@aReg0600,lExtratTAF)

					EndIf
				EndIf
				
				nX++
			End
			//No caso de o objeto oProcess existir, signIfica que a nova barra  
			//de processamento (CLASSE Fiscal) estah em uso pela rotina,       
			//portanto deve ser efetuado os controles para demonstrar o        
			//resultado do processamento.                                      
			//Tratamento para o cancelamento de execucao da rotina              
			If Type( "oProcess" ) == "O"          
				//Controle do cancelamento da rotina
				If oProcess:Cancel()
					Exit
				EndIf
				
			Else                                      
				//Controle do cancelamento da rotina
				If Interrupcao( @lEnd )
					Exit
				EndIf
			EndIf
			(cAliasSF9)->( dbSkip() )
		End
	    
		//³Fecho query ou indregua criada³
		SPEDFFiltro(2,,cAliasSFA)
		SPEDFFiltro(2,,cAliasSF9)
		//³Fecho copia criada³
		If !lTop
			__SFA->(DbCloseArea ())
		EndIf
	EndIf

	SM0->(dbSkip())
End		
//Restauro a area do SM0
RestArea(aAreaSM0)       

cFilAnt := FWGETCODFILIAL
	
//No caso de o objeto oProcess existir, signIfica que a nova barra  
//de processamento (CLASSE Fiscal) estah em uso pela rotina,       
//portanto deve ser efetuado os controles para demonstrar o        
//resultado do processamento.                                      

//Tratamento para o cancelamento de execucao da rotina              
If Type( "oProcess" ) == "O" .And. !lExtratTAF
	nSv1Progress	:=	oProcess:Ret1Progress()
	nSv2Progress	:=	oProcess:Ret2Progress()
	//Controle do cancelamento da rotina
	If oProcess:Cancel()
		Return
	EndIf               
Else                
	//Controle do cancelamento da rotina
	If Interrupcao(@lEnd)
		Return
	EndIf
	
EndIf

//Se NAO houve movimento de ativo no periodo ou For processamento do extrator, nao preciso nem passar pelos registros
If Len( aRegG125 ) > 0  
	If !lExtratTAF
		//GRAVACAO DO REGISTRO 0300 - CADASTRO DE BENS OU COMPONENTES DO ATIVO IMOBILIZADO        
		//REGISTRO 0305 - INForMACAO SOBRE A UTILIZACAO DO BEM                                    
		GrRegDep(cAlias,aReg0300,aReg0305)
	Else
		aRegT008    := aReg0300
		aRegT008Aux := aReg0305
	EndIf
	//REGISTRO G110 - ICMS ATIVO PERMANENTE - CIAP                                            
	//                                                                                        
	//Funcao independente, gera a estrutura e efetua a gravacao no TRB                        
	RegG110( cAlias, nFator, nTotTrib, nTotSai, nC04G110, nC05G110, nC10G110, aWizard, lRndCiap, lExtratTAF, @aRegT050 )
	//GRAVACAO DO REGISTRO G125 - MOVIMENTACAO DE BEM OU COMPONENTE DO ATIVO IMOBILIZADO      
	//GRAVACAO DO REGISTRO G130 - IDENTIfICACAO DO DOCUMENTO                                  
	//GRAVACAO DO REGISTRO G140 - IDENTIfICACAO DO ITEM DO DOCUMENTO                          
	If lSpedG126 .Or. lProdG126
		If Len(aRegG126) > 0
			If  !lExtratTAF			
				SPEDRegs(cAlias,{aRegG125,aRegG126,{aRegG130, 1},aRegG140},"G125/G126/G130/G140") //Mudanca de ordem

				If lBuild

					FreeObj(oHMG125Co)
					oHMG125Co := NIL
					
					FreeObj(oHMG125St)
					oHMG125St := NIL
					
					FreeObj(oHMG125Fr)
					oHMG125Fr := NIL
					
					FreeObj(oHMG125Cm)
					oHMG125Cm := NIL
					
				EndIf    
				
			Else
				aRegT050AB := aRegG126			
			EndIf
		Else
			SPEDRegs(cAlias,{aRegG125,aRegG130,aRegG140},"G125/G130/G140")     
		EndIf
    Else
    	If !lExtratTAF
	    	SPEDRegs(cAlias,{aRegG125,aRegG130,aRegG140},"G125/G130/G140") 
	    EndIf
	    
    EndIf
	
	//Trecho base para reaproveitamento de gravação sem utilizar o SPEDREGs e sim aproveitar a regra que o processamento dos registros ja fez ou seja ir mapeando em array Globalconforme o fonte é executado, quais registros e seus filho/netos serao impressos.
	/*
	If !lExtratTAF					
		
		//For nI := 1 To Len(aG25130140)

		//	GrvRegTrS(cAlias,nI,{aG25130140[nI]})

		//Next nI
		
		If lBuild

			FreeObj(oHMG125Co)
			oHMG125Co := NIL
			
			FreeObj(oHMG125St)
			oHMG125St := NIL
			
			FreeObj(oHMG125Fr)
			oHMG125Fr := NIL
			
			FreeObj(oHMG125Cm)
			oHMG125Cm := NIL
			
		EndIf    
		
	Else
		aRegT050AB := aRegG126			
	EndIf
	*/
EndIf

//No caso de o objeto oProcess existir, signIfica que a nova barra  
//de processamento (CLASSE Fiscal) estah em uso pela rotina,       
//portanto deve ser efetuado os controles para demonstrar o        
//resultado do processamento.                                      
//Tratamento para retornar a posicao da barra salva anteriormente   
If Type( "oProcess" ) == "O"
	oProcess:Set1Progress(nCtdFil,nSv1Progress)
	oProcess:Set2Progress(nCountTot,nSv2Progress)
EndIf

Return

/*/{Protheus.doc} RegG110

G110 - ICMS ATIVO PERMANENTE - CIAP
Funcao utilizada para montar a estrutura do registro G110 do CIAP

@Param: 
cAlias     -> Alias do TRB                                           
nFator     -> Coeficiente gravado no SFA                             
nTotTrib   -> Total das saidas tributadas gravadas no SFA            
nTotSai    -> Tota de todas as saidas gravadas no SFA                
nC04G110   -> Somatorio dos valores de apropriacao calculado no G125 
nC05G110   -> Somatorio dos valores passiveis de apropriacao calculado no G125
nC10G110   -> Somatorio dos valores passiveis de apropriacao calculado no G126
aWizard    -> InFormacoes do assistente da rotina                    
lRndCiap   -> Conteudo do parametro MV_RNDCIAP que determina o arredondamento conForme 
				configurado na rotina de estorno Aqui precisar ter o mesmo tratamento para o 
				valor ficar igual
lExtratTAF -> Indica se o processamento é pelo extrator do TAF       
aRegT050   -> Array de retorno para o extrator fiscal                

@Author Gustavo G. Rueda
@since  17/03/2011
@version 1.0

@Return nPos

/*/
Static Function RegG110( cAlias,nFator,nTotTrib,nTotSai,nC04G110,nC05G110,nC10G110,aWizard,lRndCiap,;
                        lExtratTAF,aRegT050 )
                        
Local aCoef  		:=	{}
Local dDataDe		:=	''
Local dDataAte	:=	''
Local aRegG110	:=	{}
Local cFator		:=	""

If !lExtratTAF
	dDataDe			:=	SToD(aWizard[1,1])
	dDataAte		:=	SToD(aWizard[1,2])		
Else
	dDataDe			:=	aWizard[1,3]
	dDataAte		:=	aWizard[1,4]		
EndIf
	
//Tem que processar a apropriacao nos seguintes casos: 
//1)Se nao tiver o fator;                             
//2)ou se os valores de saidas estiverem zerados porem
//o Fator tiver preenchido.                         
If nFator==0 .Or. (nTotTrib==0 .And. nTotSai==0 .And. nFator>0)

	//busca total de saídas, saídas tributadas e coeficiente. CoefApr esta no MATA906
	//caso nao tenha os valores do mesmo gravado na tabela                          
	If !lJob
		RptStatus ( {|| aCoef := CoefApr (dDataDe, dDataAte)}, "Aguarde...", "Obtendo o coeficiente de apropriação...")
	Else
		aCoef := CoefApr (dDataDe, dDataAte)
	EndIf
	
	If Len(aCoef)>0
		nTotTrib	:=	aCoef[1][2]
		nTotSai		:=	aCoef[1][3]
		nFator		:=	aCoef[1][4]	
	EndIf
EndIf
cFator		:=	AllTrim(TransForm(nFator,"@E 999999.99999999"))

//Arredondamento conForme configurado na rotina de estorno        
//Aqui precisa ter o mesmo tratamento para o valor ficar  igual.   

//Arredondo a soma das parcelas passíveis de apropriacao(nC05G110) 
//seguindo o mesmo critério do valor a ser apropriado(nVlIcmApro) 
//para que nao ocorram divergencias entre os dois campos.         

nC05G110   := If(lRndCiap,Round(nC05G110,2),NoRound(nC05G110,2)) 
nVlIcmApro :=	If(lRndCiap,Round(nFator*nC05G110,2),NoRound(nFator*nC05G110,2))

//Encontramos a mesma questão mencionada pelo cliente em outros blogs juntamente com a resposta do SEFAZ MG:               
//"FICHA CIAP: PERÍODO DE APURAÇÃO SEM SAÍDAS/PRESTAÇÕES - CASO PRÁTICO - REGISTRO G110 - 16/02/2011                       
//                                                                                                                         
//Dúvida do contribuinte:                                                                                                  
//"Temos um estabelecimento que em determinado mês teve o total de saídas igual zero. Porém, tem fichas do CIAP e          
//calculou o fator igual a zero. O PVA emite uma crítica inFormando que o valor total de saídas inFormado - G110 - tem   
//que ser maior do que zero. Assim, solicitamos inFormar que se eventualmente o total de saídas no mês For zero, não     
//devemos escriturar o CIAP, e no mês seguinte em que o total de saídas For maior que zero voltamos a escriturar?"       
//                                                                                                                         
//Resposta:                                                                                                                
//Trata-se de período de apuração sem saídas/prestações, cuja hipótese pode suscitar uma das interpretações                
//  abaixo por parte de cada UF:                                                                                           
//a) não se apropria a parcela de ICMS do período, perdendo o direito sobre ela;                                           
//b) a apropriação da parcela fica suspensa, voltando a apropriar quando ocorrer saídas/prestações (não se                 
//perde o direito, apenas o dIfere);                                                                                     
//c) considera-se o índice de participação igual a 1, apropriando 100% da parcela.                                         
//                                                                                                                         
//Atualmente, o entendimento do RN é pela opção referida na alínea "a".                                                    
//                                                                                                                         
//Entretanto, o PVA deve estar preparado para todos os entendimentos.                                                      
//                                                                                                                         
//Considerando que o PVA exige que o valor total das saídas (campo 7 do Registro G110) seja maior que                      
//  zero, deve-se proceder da seguinte Forma:                                                                              
//1) caso o entendimento da UF seja o das alíneas "a" ou "b", o contribuinte deverá inFormar o Bloco G                     
//  apenas com os registros de abertura, G001, sem inFormação; e de encerramento,G990;                                     
//2) se o entendimento da UF For o da alínea "c", o contribuinte deverá preencher os campos 6 e 7 do                       
//  Registro G110 com o valor 1.                                                                                           
//                                                                                                                         
//Fonte: SEFAZ/MG, produzido por Luiz Augusto Dutra da Silva, Representante do RN no GT48 -                                
//  SPED Fiscal, SET/RN."                                                                                                  
//                                                                                                                         
//fontes:
//http://www.robertodiasduarte.com.br/sped-efd-icmsipi-caso-pratico-registro-g110-periodo-de-apuracao-sem-saidasprestacoes/
//http://www.joseadriano.com.br/profiles/blogs/sped-efd-caso-pratico
//http://www.apicecontabilidade.com.br/contabilidade/noticias.php?id=175

nTotTrib	:=	IIf(nTotTrib==0 .And. nTotSai==0,1,nTotTrib)
nTotSai		:=	IIf(nTotSai==0,1,nTotSai)
cFator		:=	IIf (nFator > 0,cFator,AllTrim(TransForm((nTotTrib/nTotSai),"@E 999999.99999999")))

aAdd(aRegG110, {})
nPos	:=	Len (aRegG110)	
aAdd (aRegG110[nPos], "G110")												//01-REG
aAdd (aRegG110[nPos], dDataDe)												//02-DT_INI
aAdd (aRegG110[nPos], dDataAte)												//03-DT_FIN
aAdd (aRegG110[nPos], nC04G110)												//04-SALDO_IN_ICMS
aAdd (aRegG110[nPos], nC05G110) 											//05-SOM_PARC
aAdd (aRegG110[nPos], nTotTrib)  											//06-VL_TRIB_EXO
aAdd (aRegG110[nPos], nTotSai)		   										//07-VL_TOTAL	
aAdd (aRegG110[nPos], cFator)												//08-IND_PER_SAI
aAdd (aRegG110[nPos], nVlIcmApro) 											//09-ICMS_APROP
aAdd (aRegG110[nPos], nC10G110) 											//10-SOM_ICMS_OC
		
//Gravacao do registro G110
If !lExtratTAF
	GrvRegTrS(cAlias,,aRegG110) 		
Else
	aRegT050 := aRegG110
EndIf

Return


/*Funcao  RegG126 Autor ³Rafael Santos Oliveira  Data 15.07.2016
REGISTRO G126: OUTROS CRÉDITOS CIAP
*/
Static Function RegG126(nPosG125,aRegG126,cCodBem,dDataDe,dDataAte,nX3codBem,cPerG126)
Local nPos		:=	0
Local cBem		:= SubStr(cCodBem,1,nX3codBem)

DbSelectArea("F0W")
F0W->(DbSetOrder(2))
F0W->(DbGoTop ())
	
If F0W->(MsSeek(xFilial("F0W")+cBem+cPerG126))	
	Do While !F0W->(Eof ()) .And. F0W->F0W_CODIGO == cBem .And. F0W->F0W_PERIOD == cPerG126
		nPos := aScan(aRegG126,{|aX|aX[1]==nPosG125 .And. aX[3]==F0W->F0W_DTINI .And. aX[4]==F0W->F0W_DTFIM})
		If nPos == 0
			aAdd(aRegG126, {})
			nPos	:=	Len (aRegG126)
			aAdd (aRegG126[nPos], nPosG125)			//00 - Relacionamento com o registro PAI
			aAdd (aRegG126[nPos], "G126") 			//01-REG
			aAdd (aRegG126[nPos], F0W->F0W_DTINI)	//02-DT_INI
			aAdd (aRegG126[nPos], F0W->F0W_DTFIM)	//03-DT_FIM
			aAdd (aRegG126[nPos], AllTrim(Str(F0W->F0W_PARCEL)))	//04-NUM_PARC
			aAdd (aRegG126[nPos], F0W->F0W_VLPARC)	//05-VL_PARC_PASS
			aAdd (aRegG126[nPos], F0W->F0W_VLTRIB)	//06-VL_TRIB_OC
			aAdd (aRegG126[nPos], F0W->F0W_VTOTAL)	//07-VL_TOTAL
			aAdd (aRegG126[nPos], F0W->F0W_INDPAR)	//08-IND_PER_SAI
			aAdd (aRegG126[nPos], F0W->F0W_VLRAPR)	//09-VL_PARC_APROP

			//Trecho base para reaproveitamento de gravação sem utilizar o SPEDREGs e sim aproveitar a regra que o processamento dos registros ja fez ou seja ir mapeando conforme o fonte é executado, quais registros e seus filho/netos serao impressos.
			//aadd( aG25130140, aRegG126[nPos] ) //Alimento Array Global dos registros G125|G126|G130|G140
		EndIf
		
		F0W->(DbSkip ())
		
	EndDo
EndIf

dbSelectArea("F0W")
F0W->(dbCloseArea())

Return aRegG126

/*/{Protheus.doc} RegG130

Funcao utilizada para montar a estrutura do registro G130 do CIAP  
Esta funcao estah preparada tanto para utilizar inFormacoes do     
documento de entrada caso exista (prioridade 1), como para       
utilizar as inFormacoes atraves de parametros caso nao exista o  
documento original.                                              

@Param: 
nPosG125   -> Posicao de relacionamento com o registro PAI - C125    
aRegG130   -> Array que retorna a estrutura do registro C130         
aInfRegs   -> Array com as inFormacoes dos documentos jah processadas conForme o tipo de movimento CIAP  
lExtratTAF -> Indica se a chamada é via extrator fiscal               
aRegT050AC -> Array de retorno do extator fiscal                     

@Author Gustavo G. Rueda
@since  17/03/2011
@version 1.0

@Return nPos

/*/
Static Function RegG130( nPosG125,aRegG130,aInfRegs,lExtratTAF,aRegT050AC )

Local nPos    :=  0
Local cSerie  := aInfRegs[4]

nPos := aScan(aRegG130,{|aX|aX[1]==nPosG125 .And. aX[3]==aInfRegs[1] .And. aX[4]==aInfRegs[2] .And. aX[5]==aInfRegs[3] .And. aX[6]==cSerie .And. aX[7]==aInfRegs[5] .And. aX[8]==aInfRegs[6]})

If nPos == 0
    aAdd(aRegG130, {})
    nPos    :=  Len (aRegG130)  
    aAdd (aRegG130[nPos], nPosG125)                     //00 - Relacionamento com o registro PAI
    aAdd (aRegG130[nPos], "G130")                       //01-REG    
    aAdd (aRegG130[nPos], aInfRegs[1])                  //02-IND_EMIT
    aAdd (aRegG130[nPos], aInfRegs[2])                  //03-COD_PART
    aAdd (aRegG130[nPos], aInfRegs[3])                  //04-COD_MOD
    aAdd (aRegG130[nPos], aInfRegs[4])                  //05-SERIE  
    aAdd (aRegG130[nPos], aInfRegs[5])                  //06-NUM_DOC    
    aAdd (aRegG130[nPos], aInfRegs[6])                  //07-CHV_NFE_CTE    
    aAdd (aRegG130[nPos], aInfRegs[7])                  //08-DT_DOC 
	If cVersao >= "014"
		aAdd (aRegG130[nPos], aInfRegs[11])                 //09-NUM_DA
	EndIf
	
	//Trecho base para reaproveitamento de gravação sem utilizar o SPEDREGs e sim aproveitar a regra que o processamento dos registros ja fez ou seja ir mapeando conforme o fonte é executado, quais registros e seus filho/netos serao impressos.
	//aadd( aG25130140, aRegG130[nPos] ) //Alimento Array Global dos registros G125|G126|G130|G140
EndIf  

If lExtratTAF
    aadd( aRegT050AC, aRegG130[nPos] )
EndIf

Return nPos

/*/{Protheus.doc} RegG140

Funcao utilizada para montar a estrutura do registro G140 do CIAP  
Esta funcao estah preparada tanto para utilizar inFormacoes do     
documento de entrada caso exista (prioridade 1), como para       
utilizar as inFormacoes atraves de parametros caso nao exista o  
documento original.                                              

@Param: 
nPosG130   -> Posicao de relacionamento com o registro PAI - C130     
aRegG140   -> Array que retorna a estrutura do registro C140          
aInfRegs   -> Array com as inFormacoes dos documentos jah processadas conForme o tipo de movimento CIAP                       ³±± 
lExtratTAF -> Indica se a chamada é via extrator fiscal               
aRegT050AD -> Array de retorno do extator fiscal                     

@Author Gustavo G. Rueda
@since  17/03/2011
@version 1.0

@Return Nil, nulo, não tem retorno

/*/
Static Function RegG140( nPosG130,aRegG140,aInfRegs,lExtratTAF,aRegT050AD)	                                    

Local nPos	:=	0

nPos 	:= aScan(aRegG140,{|aX|aX[1]==nPosG130 .And. aX[3]==aInfRegs[8] .And. aX[4]==aInfRegs[9]})

If nPos==0
	aAdd(aRegG140, {})
	nPos	:=	Len (aRegG140)	
	aAdd (aRegG140[nPos], nPosG130)						//00 - Relacionamento com o registro C125
	aAdd (aRegG140[nPos], "G140") 	 		 			//01-REG	
	aAdd (aRegG140[nPos], aInfRegs[8])			 		//02-NUM_ITEM
	aAdd (aRegG140[nPos], aInfRegs[9]) 					//03-COD_ITEM
	If cVersao >= "014" 
		aAdd (aRegG140[nPos], aInfRegs[12]) 				//04-QTDE
		aAdd (aRegG140[nPos], aInfRegs[13]) 				//05-UNID
		aAdd (aRegG140[nPos], aInfRegs[14])                 //06-VL_ICMS_OP_APLICADO 
		aAdd (aRegG140[nPos], aInfRegs[15]) 				//07-VL_ICMS_ST_APLICADO
		aAdd (aRegG140[nPos], aInfRegs[16]) 				//08-VL_ICMS_FRT_APLICADO
		aAdd (aRegG140[nPos], aInfRegs[17]) 				//09-VL_ICMS_DIF_APLICADO
	EndIf

	//Trecho base para reaproveitamento de gravação sem utilizar o SPEDREGs e sim aproveitar a regra que o processamento dos registros ja fez ou seja ir mapeando conforme o fonte é executado, quais registros e seus filho/netos serao impressos.
	//aadd( aG25130140, aRegG140[nPos] ) //Alimento Array Global dos registros G125|G126|G130|G140

EndIf

If lExtratTAF
	aadd( aRegT050AD, aRegG140[nPos] )
EndIf

Return


/*/{Protheus.doc} R03000305

REGISTRO 0300 - CADASTRO DE BENS OU COMPONENTES DO ATIVO IMOBILIZADO                             
REGISTRO 0305 - INForMACAO SOBRE A UTILIZACAO DO BEM    
Geracao e gravacao dos Registros 0300 e 0305          

@Param: 
cAlias    -> Alias do TRB que recebera as inFormacoes          
aClasCIAP -> InFormacoes da classIficacao do ativo           
nLimParc  -> Numero de parcelas aprovadas por Lei para aprop.
cCodCiap  -> Codigo do ativo montado pela rotina             
aCmpsSF9  -> Campos customizados da tabela SF9               
aReg0300  -> Array para controle da duplicidade

@Author Gustavo G. Rueda
@since  18/03/2011
@version 1.0

@Return Nil, nulo, não tem retorno
/*/
Static Function R03000305(cAlias,aClasCIAP,nLimParc,cCodCiap,aCmpsSF9,aReg0300,aReg0305, cAliasSFA)

Local nPos		:=	0
Local nPos2		:=	0
Local nPosB		:=	0
Local nPos2B		:=	0
Local nVal		:= 	0
Local aAreaSF9	:=	SF9->(GetArea ())
Local cContCtb	:= RetCOD_CTA(cAliasSFA, "0300")

If !Empty(cContCtb)
	aClasCIAP[1] := cContCtb
EndIf

// Tratamento para evitar duplicidade de inFormacoes
If (nPos := aScan(aReg0300,{|aX| aX[2]==cCodCiap}))==0

	//REGISTRO 0300 - CADASTRO DE BENS OU COMPONENTES DO ATIVO IMOBILIZADO                    
	aAdd(aReg0300, {})
	nPos	:=	Len(aReg0300)	
	aAdd(aReg0300[nPos], "0300") 	  														//01-REG
	aAdd(aReg0300[nPos], cCodCiap) 															//02-COD_IND_BEM
	aAdd(aReg0300[nPos], IIf(SF9->F9_TIPO=="03","2","1"))									//03-IDENT_MERC
	aAdd(aReg0300[nPos], aCmpsSF9[26])														//04-DESCR_ITEM
	aAdd(aReg0300[nPos], IIf(!EMPTY(SF9->F9_CODBAIX) .And. SF9->F9_CODBAIX <> "BFINAL",SF9->F9_CODBAIX+xFilial("SF9")," "))	//05-COD_PRNC
	aAdd(aReg0300[nPos], aClasCIAP[1])														//06-COD_CTA
	aAdd(aReg0300[nPos], AllTrim(Str(nLimParc)))											//07-NR_PARC 

	//|REGISTRO 0305 - INForMACAO SOBRE A UTILIZACAO DO BEM               
	If aReg0300[nPos][3] == "1"
		aAdd(aReg0305, {})
		nPos2	:=	Len(aReg0305)	
		aAdd (aReg0305[nPos2], nPos)						 	  	//00-Relacionamento com o PAI
		aAdd (aReg0305[nPos2], "0305") 	  							//01-REG	
		aAdd (aReg0305[nPos2], aClasCIAP[2]) 						//02-COD_CCUS
		aAdd (aReg0305[nPos2], aClasCIAP[3])						//03-FUNC		
		aAdd (aReg0305[nPos2], AllTrim(Str(aCmpsSF9[16])))			//04-VIDA_UTIL
	EndIf
		
	//|REGISTRO 0300 - GERACAO DO REGISTRO DO BEM FINAL
	If !Empty(aReg0300[nPos][5]) .And. (nVal:=aScan(aReg0300,{|aX| aX[2]==aReg0300[nPos][5]}))==0
		dbSelectArea("SF9")
		dbSetOrder(1)
		If SF9->(msSeek(xFilial("SF9")+SF9->F9_CODBAIX))
			aAdd(aReg0300, {})
			nPosB	:=	Len(aReg0300)
			aAdd(aReg0300[nPosB], "0300") 	  								   			//01-REG
			aAdd(aReg0300[nPosB], aReg0300[nPos][5])		   				   			//02-COD_IND_BEM
			aAdd(aReg0300[nPosB], "1")										   			//03-IDENT_MERC
			aAdd(aReg0300[nPosB], SF9->F9_DESCRI)										//04-DESCR_ITEM
			aAdd(aReg0300[nPosB], " ")													//05-COD_PRNC
			aAdd(aReg0300[nPosB], aClasCIAP[1])											//06-COD_CTA
			aAdd(aReg0300[nPosB], IIf(EMPTY(SF9->F9_QTDPARC),AllTrim(Str(nLimParc)),;
										AllTrim(Str(SF9->F9_QTDPARC))))					//07-NR_PARC
										
			//|REGISTRO 0305 - GERACAO DO REGISTRO DO BEM FINAL      
			aAdd(aReg0305, {})
			nPos2B :=	Len(aReg0305)
			aAdd (aReg0305[nPos2B], nPosB)						 		//00-Relacionamento com o PAI
			aAdd (aReg0305[nPos2B], "0305") 	  						//01-REG	
			aAdd (aReg0305[nPos2B], aClasCIAP[2]) 						//02-COD_CCUS
			aAdd (aReg0305[nPos2B], IIF(Empty(aClasCIAP[3]),SF9->(FieldGet(FieldPos(aCmpsSF9[9]))) ,aClasCIAP[3]))						//03-FUNC		
			aAdd (aReg0305[nPos2B], AllTrim(Str(SF9->F9_VIDUTIL)))		//04-VIDA_UTIL
			
		EndIf
	EndIf
		
EndIf	          

RestArea(aAreaSF9)           

Return

/*/{Protheus.doc} Reg0500

REGISTRO 0500 - PLANO DE CONTAS CONTABEIS 
Geracao e gravacao dos Registros 0500

@Param: 
cAlias    -> Alias do TRB que recebera as inFormacoes
aClasCIAP -> InFormacoes da classIficacao do ativo
lCtbInUse -> Flag que determina se eh CTB ou SIGACON   
aReg0500  -> Array com a estrutura do registro 0500 

@Author Gustavo G. Rueda
@since  18/03/2011
@version 1.0

@Return Nil, nulo, não tem retorno
/*/
Static Function Reg0500( cAlias,aClasCIAP,lCtbInUse,aReg0500,lExtratTAF)
Local nPos		:=	0
Local cConta		:=	""

//Tratamento para CTB ou o antigo SIGACON
If lCtbInUse	
	cConta		:=	SubStr(aClasCIAP[1],1,TamSx3("CT1_CONTA")[1])

	//Tratamento para evitar duplicidade de inFormacao
	If CT1->(MsSeek(xFilial("CT1")+cConta)) .And.;  
		aScan(aReg0500,{|aX| aX[6]==aClasCIAP[1] .And. aX[2]==CT1->CT1_DTEXIS})==0

		aAdd(aReg0500, {})
		nPos	:=	Len (aReg0500)	
		aAdd (aReg0500[nPos], "0500") 								//01-REG
		aAdd (aReg0500[nPos], CT1->CT1_DTEXIS) 						//02-DT_ALT
				
		//Campo criado para atender o SPED Fiscal
		aAdd (aReg0500[nPos], CT1->CT1_NTSPED)						 //03-COD_NAT_CC
		aAdd (aReg0500[nPos], IIf(CT1->CT1_CLASSE=="1","S","A")) 	 //04-IND_CTA
		aAdd (aReg0500[nPos], AllTrim(Str(CtbNivCta(aClasCIAP[1])))) //05-NIVEL 
		aAdd (aReg0500[nPos], aClasCIAP[1])							 //06-COD_CTA
		aAdd (aReg0500[nPos], CT1->CT1_DESC01) 						 //07-NOME_CTA

	EndIf
Else
	cConta		:=	SubStr(aClasCIAP[1],1,TamSx3("I1_CODIGO")[1])
	
	If SI1->(MsSeek(xFilial("SI1")+cConta)) .And.;
		aScan(aReg0500,{|aX| aX[6]==aClasCIAP[1] .And. aX[2]==""})==0
		
		aAdd(aReg0500, {})
		nPos	:=	Len (aReg0500)	
		aAdd (aReg0500[nPos], "0500") 								//01-REG
		aAdd (aReg0500[nPos], "")			 						//02-DT_ALT
		aAdd (aReg0500[nPos], "")									//03-COD_NAT_CC
		aAdd (aReg0500[nPos], SI1->I1_CLASSE)					 	//04-IND_CTA
		aAdd (aReg0500[nPos], SI1->I1_NIVEL)		 				//05-NIVEL 
		aAdd (aReg0500[nPos], aClasCIAP[1]) 						//06-COD_CTA
		aAdd (aReg0500[nPos], SI1->I1_DESC) 						//07-NOME_CTA
	EndIf  
EndIf

If nPos>0 .And. !lExtratTAF
	GrvRegTrS(cAlias,,{aReg0500[nPos]})
EndIf

Return

/*/{Protheus.doc} Reg0600

REGISTRO 0600 - CENTRO DE CUSTOS 
Geracao e gravacao dos Registros 0600

@Param: 
cAlias -> Alias do TRB que recebera as inFormacoes 
aClasCIAP -> InFormacoes da classIficacao do ativo
lCtbInUse -> Flag que determina se eh CTB ou SIGACON   
aReg0600  -> Array com a estrutura do registro 0600 

@Author Gustavo G. Rueda
@since  18/03/2011
@version 1.0

@Return Nil, nulo, não tem retorno
/*/
Static Function Reg0600( cAlias,aClasCIAP,lCtbInUse,aReg0600,lExtratTAF)

Local nPos	:=	0
Local cCC		:=	""

//Tratamento para evitar duplicidade de inFormacao
If aScan(aReg0600,{|aX| aX[3]==aClasCIAP[2]})==0
	//Tratamento para CTB ou o antigo SIGACON
	If lCtbInUse
		cCC		:=	SubStr(aClasCIAP[2],1,TamSx3("CTT_CUSTO")[1])
		
		If CTT->(MsSeek(xFilial("CTT")+cCC))	
			aAdd(aReg0600, {})
			nPos	:=	Len (aReg0600)	
			aAdd (aReg0600[nPos], "0600")						//01-REG
			aAdd (aReg0600[nPos], CTT->CTT_DTEXIS)				//02-DT_ALT
			aAdd (aReg0600[nPos], aClasCIAP[2])					//03-COD_CCUS
			aAdd (aReg0600[nPos], CTT->CTT_DESC01) 				//04-CCUS
		EndIf
	Else
		cCC		:=	SubStr(aClasCIAP[2],1,TamSx3("I3_CUSTO")[1])
		
		If SI3->(MsSeek(xFilial("SI3")+cCC))	
			aAdd(aReg0600, {})
			nPos	:=	Len (aReg0600)	
			aAdd (aReg0600[nPos], "0600")						//01-REG
			aAdd (aReg0600[nPos], "")							//02-DT_ALT
			aAdd (aReg0600[nPos], aClasCIAP[2])					//03-COD_CCUS
			aAdd (aReg0600[nPos], SI3->I3_DESC) 				//04-CCUS
		EndIf	
	EndIf
	
	If nPos>0 .And. !lExtratTAF
		GrvRegTrS(cAlias,,{aReg0600[nPos]})
	EndIf
EndIf

Return

/*/{Protheus.doc} AddHash
	(Função para adicionar o hash)

	@type Static Function
	@author Simone Oliveira	
	@since 31/07/2017

	@param oHash, objeto, contém o hash
	@param cChave, caracter, contém a chave

	@return Nil, nulo, não tem retorno
	/*/
Static Function AddHash(oHash,cChave,nPos)

	Local cSet := "HMSet"

	Default oHash := NIL
	
	Default cChave := ""
	
	Default nPos := 0

	&cSet.(oHash,cChave,nPos)

Return Nil

/*/{Protheus.doc} FindHash
	(Função para encontrar o hash)

	@type Static Function
	@author Simone Oliveira	
	@since 31/07/2017

	@param oHash, objeto, contém o hash
	@param cChave, caracter, contém a chave

	@return nPosRet, numerico, posição contido no hash
	/*/
Static Function FindHash(oHash,cChave)

	Local nPosRet := 0

	Local cGet := "HMGet"

	Default oHash := Nil
	
	Default cChave := ""

	&cGet.(oHash,cChave,@nPosRet)

Return nPosRet
