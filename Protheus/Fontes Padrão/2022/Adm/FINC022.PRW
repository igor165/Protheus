#INCLUDE "finc022.ch"
#include "PROTHEUS.CH"
#include "MSGRAPHI.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "FWBROWSE.CH"

#DEFINE PERIODOS			1
#DEFINE DADOSNATUREZA	2
#DEFINE SOMAENTRADAS		1
#DEFINE SOMASAIDAS		2
#DEFINE IMPOSTOS			3

Static lFWCodFil	:= .T.
Static _oFINC0221
Static _oFINC0222
Static _oFINC0223
Static __nTamOrdV	:= 0
Static __cPicVal	:= "@e 999,999,999,999,999.99"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FINC022	³ Autor ³ Claudio D. de Souza   ³ Data ³ 07/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fluxo de Caixa por Natureza							  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FINC022()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Financeiro 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Finc022(lGravada, cCodFlx, cCodFlxCmp)

Local aParam		:= {}
Local aPeriodos		:= {}
Local aPeriodos2	:= {}
Local aSelFil		:= {}
Local aConf			:= {}
Local cNatEntDe		:= PAD(" ", Len(SE1->E1_NATUREZ)) // Space(Len(SE1->E1_NATUREZ))
Local cNatEntAte	:= PAD("ZZ", Len(SE1->E1_NATUREZ)) // Space(Len(SE1->E1_NATUREZ))
Local aTipos		:= {STR0001, STR0002, STR0003, STR0106} //"Dias"###"Semanas"###"Meses###Anos"
Local dDataIni		:= FirstDay(dDataBase)
Local dDataFin		:= LastDay(dDataBase)
Local cVisao	 	:= CriaVar("FJ1_CODIGO",.F.)
Local cAliasFIY		:= ""
Local cAliasTRB		:= ""
Local cAliasTRB2	:= ""
Local lRet			:= .T.
Local cFilOld		:= cFilAnt
Local nX			:= 0
Local lProcessa		:= .F.
Local nCount		:= 0
Local nLoop			:= 1
Local aPerguntas	:= {}
Local cTamMoed		:= TamSX3("FIV_MOEDA")[1]
Local cMoePam		:= Space(cTamMoed)
Local nParCont		:= 0
Local lConsFil		:= .F.
Local nBancos		:= 0
Local nCaixas		:= 0
Local aBancos		:= {}
Local lLimCred		:= .T.
Local cModoFilial	:= ""
Local cModoUnNeg	:= ""
Local lCompSE8SA6 := FWModeAccess("SE8", 1) == "C" .And. FWModeAccess("SA6", 1) == "C"

Private aVisao		:= {}
Private lfluxSint	:= .T.

Default lGravada	:= .F.
Default cCodFlx		:= FIX->FIX_CODIGO

Private cNota		:= ""
Private oMemo
Private cNota2		:= ""
Private aFluxAna	:= {}
Private cFilDe		:= cFilAnt
Private cFilAte		:= cFilAnt

//-----------------------------------------------------------
//* Validação do compartilhamento das tabelas do fluxo de caixa por natureza financeira.
//* Compartilhamento de tabelas deve ser o mesmo para as seguintes tabelas:
//
//* - FIV - Movimentos Diários Fluxo de Caixa por Natureza Financeira
//* - FIW - Movimentos Mensais Fluxo de Caixa por Natureza Financeira
//* - FIX - Cabeçalho Histórico Fluxo de Caixa por Natureza Financeira
//* - FIY - Itens Histórico Fluxo de Caixa por Natureza Financeira
//*
// Todas as tabelas do fluxo de caixa e a de naturezas financeiras com o compartilhamento "EXCLUSIVO"
//-----------------------------------------------------------*/

If GetRpoRelease() >= "12.1.033" .and. FindFunction("MsgExpRot")
	MsgExpRot("FINC022",;
				STR0125,; //"Dashboard financeiro FATA900" 
				"https://tdn.totvs.com/pages/releaseview.action?pageId=584158935", "20220820" ) 
	if Date() >= CTOD("20/08/2022")
		MsgAlert(STR0126, STR0127) //"Rotina descontinuada" # "Alerta"
		Return
	Endif			
EndIf

cModoFilial := FWModeAccess("FIV",2)
cModoUnNeg	:= FWModeAccess("FIV",3)

If  FWModeAccess("FIW",2) == cModoFilial .AND. 	FWModeAccess("FIX",2) == cModoFilial .AND. FWModeAccess("FIY",2) == cModoFilial .AND.; 
	FWModeAccess("FIW",3) == cModoUnNeg  .AND. FWModeAccess("FIX",3) == cModoUnNeg  .AND. FWModeAccess("FIY",3) == cModoUnNeg
	lProcessa := .T.
Else
	//-----------------------------------------------------------
	// Se o Compartilhamento não atende a forma correta, não permite execução
	//-----------------------------------------------------------
	lProcessa := .F.
EndIf

//-----------------------------------------------------------
// Se o Compartilhamento não atende a forma correta, não permite execução
//-----------------------------------------------------------
If !lProcessa
	Help(" ",1,"CONSLDFC",,STR0060,1,0)
	Return()
EndIf

__nTamOrdV := TamSX3("FJ2_ORDEM")[1]

	//-----------------------------------------------------------
	// Executa duas vezes, caso haja comparação de fluxos
	//-----------------------------------------------------------
	If cCodFlxCmp # Nil
		nLoop := 2
	Endif

	If !lGravada
		aPerguntas := {	{ 2, STR0074 , 1, { STR0075, STR0076 }, 100,, .T. }} //"Considera Fluxo?"###"Sintético"###"Analitico" // 23/11/2011 totvs}
		ParamBox( aPerguntas,STR0020,aParam,,,,,,,"FluxoFINC022",.T.,.T.) // Escolha o fluxo de caixa se Sintetico ou Analitico
		If Len(aParam) > 0
			
			//--------------------------------------
			// Ajuste do retorno da função ParamBox
			//--------------------------------------
			AjRetParam(aParam,aPerguntas)
			
			IIf(aParam[1] == 1, lfluxSint := .T., lfluxSint := .F.)
			
			aParam		:= {}
			MV_PAR01	:= "" 
		Else
			Return Nil
		Endif
	Endif

	//--------------------------------------------------------------------------------------
	// Perguntas da rotina 
	// Atencao! Nas perguntas do tipo combo, nao utilize o sinal de = nas opcoes. O retorno  
	// do parambox é diferente e a rotina AjRetParam nao funcionara corretamente.
	//---------------------------------------------------------------------------------------
	If lFluxSint //Fluxo sintetico

			aPerguntas :=	{	{ 1, STR0004, cNatEntDe,"@!",'.T.',"SED",".T.",60, .F.						},; //01 - "Da Natureza"
								{ 1, STR0005, cNatEntAte,"@!",'.T.',"SED",".T.",60,.F.						},; //02 - "Até Natureza"
								{ 1, STR0006, dDataIni,"", "VldPerFlx()","",".T.",50,.T.					},; //03 - "Data inicial"
								{ 1, STR0007, dDataFin,"", "VldPerFlx()","",".T.",50,.T.					},; //04 - "Data final"
								{ 3, STR0008, 2, aTipos, 100,, .T.											},; //05 - "Mostra periodos em"
								{ 5, STR0009, .T., 100,, .T.												},; //06 - "Considera pedidos de venda"
								{ 5, STR0010, .T., 100,, .T.												},; //07 - "Considera pedidos de compra"
								{ 5, STR0011, .T., 100,, .T.												},; //08 - "Considera aplicações/empréstimos"  
								{ 5, STR0012, .T., 100,, .T.												},; //09 - "Considera saldos bancários"
								{ 2, STR0013, 1, {STR0014, STR0015, STR0016}, 100,"MV_PAR09", .T.			},; //10 - "Tipos de saldo"###"1-Normais"###"2-Conciliados"###"3-Não conciliados"
								{ 1, STR0059, cMoePam,"@!",'ExistCpo("CTO")',"CTO",".T.",cTamMoed,.T.		},; //11 - "Moeda"
								{ 3, STR0017, 2,{STR0018,STR0019},100,,.T.,FWModeAccess("FIV")=="E"			},; //12 - "Considera Filiais"
								{ 2, STR0099, 2,{STR0097,STR0098},100,,.T.	},; //13 - Exibe Nat. Sintéticas? 1-Sim/2-Não	
								{ 2, STR0068, 1,{STR0111,STR0112,STR0113,STR0114},100,,.T.					},; //14 - "Comparativo" 1-Nenhum;2-Orcado x Previsto;3-Orcado x Realizado;4-Previsto x Realizado
								{ 5, STR0066, .T., 100,, .T.												},; //15 - "Apenas movimentações bancárias"
								{ 1, STR0072, cVisao ,"@!",'.T.',"FJ1",".T.",60,.F.							},; //16 - "Visao Gerencial"
								{ 5, STR0124, .T., 100,, .T.												}}	//17 - "Exibe Agrupadora apenas

	Else //Fluxo analitico

			aPerguntas :=	{	{ 1, STR0004, cNatEntDe ,"@!",'.T.',"SED",".T.",60, .F.						},; //01 - "Da Natureza"
								{ 1, STR0005, cNatEntAte,"@!",'.T.',"SED",".T.",60,.F.						},; //02 - "Até Natureza"
								{ 1, STR0006, dDataIni,"", "VldPerFlx()","",".T.",50,.T.					},; //03 - "Data inicial"
								{ 1, STR0007, dDataFin,"", "VldPerFlx()","",".T.",50,.T.					},; //04 - "Data final"
								{ 3, STR0008, 2, aTipos, 100,, .T.											},; //05 - "Mostra periodos em"
								{ 5, STR0009, .T., 100,, .T.												},; //06 - "Considera pedidos de venda"
								{ 5, STR0010, .T., 100,, .T.												},; //07 - "Considera pedidos de compra"
								{ 5, STR0011, .T., 100,, .T.												},; //08 - "Considera aplicações/empréstimos"  
								{ 5, STR0012, .T., 100,, .T.												},; //09 - "Considera saldos bancários"
								{ 2, STR0013, 1, {STR0014, STR0015, STR0016}, 100,"MV_PAR09", .T.			},; //10 - "Tipos de saldo"###"1-Normais"###"2-Conciliados"###"3-Não conciliados"
								{ 1, STR0059, cMoePam, "@!",'ExistCpo("CTO")',"CTO",".T.",cTamMoed,.T.		},; //11 - "Moeda"
								{ 3, STR0017, 2,{STR0018, STR0019}, 100,, .T.,FWModeAccess("FIV")=="E"		},; //12 - Seleciona Filial
								{ 2, STR0099, 2,{STR0097,STR0098},100,,.T.	},; //13 - Exibe Nat. Simtéticas? 1-Sim/2-Não	
								{ 2, STR0068, 1,{STR0111, STR0112,STR0113,STR0114},100,,.T.					},; //14 - "Comparativo"
								{ 5, STR0066, .T., 100,, .T.												},; //15 - "Apenas movimentações bancárias"
								{ 5, STR0077, .T., 100,, .T.												},; //16 - "Considera Comissão de Venda"
								{ 5, STR0078, .T., 100,, .T.												},; //17 - "Considera Títulos a Receber"
								{ 5, STR0079, .T., 100,, .T.												},; //18 - "Considera Titulos a Pagar"  
								{ 7, STR0080, "FJV" , "", ".T.", ".F."										},; //19 - "Filtro para Fluxo Analitico"
								{ 9, STR0082, 200, 20, .T.													}}  //20 - O uso do filtro acima (Filtro para Fluxo Analítico) anula as opções acima selecionadas de (Checkbox).

	Endif 

	If lGravada .Or.;
		ParamBox( aPerguntas,STR0020,aParam,{|| VldData()},,,,,,Iif(!lFluxSint,"FINC022ANALITICO",FunName()),.T.,.T.) //"Considera filiais"###"Sim"###"Não"###"Parâmetros do Fluxo de Caixa - Financeiro"

		//-------------------------------------
		// Ajusta o retorno da função ParamBox
		//-------------------------------------
		AjRetParam(aParam,aPerguntas)

		//-----------------------------------------------------------
		// Se for uma consulta gravada
		//-----------------------------------------------------------
		If lGravada
			CarregaParam(If(nLoop==1,cCodFlx, cCodFlxCmp),@aParam)
		EndIf

		If Len(aParam) == 20 //Fluxo Analitico
			lFluxSint := .F.
		EndIf

		//------------------------------------------------------------------------------
		// Garantindo que os valores do parambox estarão nas devidas variáveis MV_PARXX
		//------------------------------------------------------------------------------
		For nParCont := 1 To Len(aParam)
			&("MV_PAR"+CVALTOCHAR(nParCont)) := aParam[nParCont]
		Next nParCont

		If !lFluxSint  // Para mostrar Fluxo Analitico  
			MonFlxAn( cFilOld, lGravada, nLoop, cCodFlx, cCodFlxCmp, aParam, aPerguntas  )
			Return Nil
		Endif

		//-----------------------------------------------------------
		// Caso o compartilhamento de tabelas não seja Exclusivo, inibe a seleção de filiais na Consulta do Fluxo de Caixa
		//-----------------------------------------------------------
		If lGravada .Or. (VldPerFlx() .And. VldData())
			For nCount := 1 To nLoop
				//-----------------------------------------------------------
				// Se for uma consulta gravada
				//-----------------------------------------------------------
				If lGravada
					CarregaParam(If(nCount==1,cCodFlx, cCodFlxCmp))
					CarregaNota(nCount,If(nCount==1,cCodFlx, cCodFlxCmp))
				EndIf
				//-----------------------------------------------------------
				// Calcula o numero de periodos do fluxo de caixa
				//-----------------------------------------------------------
				If nCount == 1
					MontaPeriodo(MV_PAR03, MV_PAR04, MV_PAR05,@cAliasTRB,@aPeriodos)
				Else
					MontaPeriodo(MV_PAR03, MV_PAR04, MV_PAR05,@cAliasTRB2,@aPeriodos2)
				EndIf

				If !lGravada .And. IIf(ValType(MV_PAR12) == "N",MV_PAR12 == 1,.F.)  // Considera filiais
					aSelFil := AdmGetFil()
					lConsFil := .T.
					If Empty(aSelFil)
						lRet := .F.
					Else
						If lRet
							If EMPTY(XFILIAL("FIV",aSelFil[1]))
								aSelFil := {XFILIAL("FIV",aSelFil[1])}
							EndIf
						EndIf
					EndIf
				Else
					aSelFil := {cFilAnt}
				Endif
				// Seleciona os Bancos
				If lRet .And. IIf(ValType(MV_PAR09) == "L",MV_PAR09,.F.)
					aBancos := Bancos( lConsFil, 1, @nBancos, @nCaixas,aSelFil,Str(MV_PAR10,1),.F.,aBancos,@lLimCred)
				EndIf
				If lRet
					If lGravada .Or. Len(aSelFil) > 0
						If !lGravada .And. (Len(aSelFil) > 0 .OR. MV_PAR06 .OR. MV_PAR07)
							//-------------------------------------------
							// Define estrutura da tabela temporária
							//------------------------------------------						
							If _oFINC0221 <> Nil
								_oFINC0221:Delete()
								_oFINC0221 := Nil
							Endif
							
							cAliasFIY := GetNextAlias()
							
							_oFINC0221 := FWTemporaryTable():New( cAliasFIY )  
							_oFINC0221:SetFields(FIV->(DbStruct())) 	
							_oFINC0221:AddIndex("1", {"FIV_FILIAL","FIV_NATUR","FIV_MOEDA","FIV_TPSALD","FIV_CARTEI","FIV_DATA"}) 
							
							//------------------
							//Criação da tabela temporaria
							//------------------
							_oFINC0221:Create()	

						EndIf
						//-------------------------------------------
						// Processa o fluxo de caixa por filial selecionada.
						//-------------------------------------------
						For nX := 1 To Len(aSelFil)
							//-------------------------------------------
							// Troca a filial corrente para a filial de processamento
							//-------------------------------------------
							cFilAnt := aSelFil[nX]
							//-------------------------------------------
							// Processa os pedidos de compra
							//-------------------------------------------
							If !lGravada .And. MV_PAR07 .And. MV_PAR14 <> 3
								If nX == 1 .Or. FWModeAccess("SC7") == "E"
									Processa( { |lEnd| Fc022Compr(MV_PAR05,MV_PAR03,MV_PAR04,cAliasFIY,cAliasTRB,aPeriodos,,aSelFil) }, STR0022 ) //"Processando pedidos de compra"
								EndIf
							Else
								If MV_PAR07
									If nX == 1 .Or. FWModeAccess("SC7") == "E"
										If nCount == 1
											Processa( { |lEnd| Fc022Compr(MV_PAR05,MV_PAR03,MV_PAR04,cAliasFIY,cAliasTRB,aPeriodos,,aSelFil) }, STR0022 ) //"Processando pedidos de compra comparação"
										Else
											Processa( { |lEnd| Fc022Compr(MV_PAR05,MV_PAR03,MV_PAR04,cAliasFIY,cAliasTRB2,aPeriodos2,,aSelFil) }, STR0022 ) //"Processando pedidos de compra comparação"
										EndIf															
									EndIf
								EndIf
							Endif	
							//-------------------------------------------
							// Processa os pedidos de venda
							//-------------------------------------------
							If !lGravada .And. MV_PAR06 .And. MV_PAR14 <> 3
								If nX == 1 .Or. FWModeAccess("SC5") == "E"
									Processa( { |lEnd| Fc022Venda(MV_PAR05, MV_PAR03, MV_PAR04, cAliasFIY,cAliasTRB,aPeriodos,,aSelFil) }, STR0023 ) //"Processando pedidos de venda"
								EndIf
							Else
								If MV_PAR06
									If nX == 1 .Or. FWModeAccess("SC5") == "E"
										If nCount == 1
											Processa( { |lEnd| Fc022Venda(MV_PAR05,MV_PAR03,MV_PAR04,cAliasFIY,cAliasTRB,aPeriodos,,aSelFil) }, STR0023 ) //"Processando pedidos de venda comparação "
										Else
											Processa( { |lEnd| Fc022Venda(MV_PAR05,MV_PAR03,MV_PAR04,cAliasFIY,cAliasTRB2,aPeriodos2,,aSelFil) }, STR0023 ) //"Processando pedidos de venda comparação"
										EndIf															
									EndIf
								EndIf
							Endif
							//-------------------------------------------
							// Processa aplicações e emprestimos
							//-------------------------------------------
							If !lGravada .And. MV_PAR08 .And. MV_PAR14 <> 3
								If nX == 1 .Or. FWModeAccess("SEH") == "E"
									Processa( { |lEnd| Fc022AplRes( MV_PAR05, MV_PAR03, MV_PAR04, cAliasFIY, cAliasTRB, aPeriodos) }, STR0024 ) //"Processando Aplicações/Empréstimos"
								EndIf
							EndIf

							If (FunName() == "FINC023")
								mv_par10 := 0	//Tipos de Saldo
								mv_par09 := .T.	//Considera Saldos Bancarios
							EndIf

							If nX == 1 .Or. FWModeAccess("FIY") == "E"
								Processa( {|lEnd| FlCxNatProc(lEnd,MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,@cAliasFIY,lGravada,IIf(nCount==1,cCodFlx,cCodFlxCmp),MV_PAR11,IIf(nCount==1,cAliasTRB,cAliasTRB2),IIf(nCount==1,aPeriodos,aPeriodos2)) }, STR0026 ) //"Lendo saldos das naturezas"
							EndIf
						Next nX
						// Processa Saldos Iniciais
						If MV_PAR09 .And. Len(aBancos) > 0 
							Processa( { |lEnd| SaldosInicias( MV_PAR05, MV_PAR03-1, Str(MV_PAR10,1),IIf(nCount==1,cAliasTRB,cAliasTRB2),IIf(nCount==1,aPeriodos,aPeriodos2),aBancos,MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04, aSelFil) }, STR0025 ) //"Calculando saldos iniciais"
						Endif
						
					Endif
				Endif

				//Registra os dados de cada configuração de sintéticas de cada consulta
				AAdd( aConf, { If( nCount = 1, cAliasTRB, cAliasTRB2 ), MV_PAR13 } )
			Next nCount
			//-----------------------------------------------------------
			// Exibe o fluxo de caixa
			//-----------------------------------------------------------
			If lGravada
				CarregaParam(cCodFlx)
			EndIf

			TotalFluxo( cAliasTRB, aPeriodos,aBancos )

			If nLoop == 2
				If lGravada
					CarregaParam(cCodFlxCmp)
				EndIf
				TotalFluxo(cAliasTRB2,aPeriodos2,aBancos)
			EndIf

			For nCount := 1 to nLoop
				//MV_PAR13
				If aConf[nCount][2] = 1 //Naturezas Sintéticas = 1 - Sim
					Processa( {|| F022TotNat(aConf[nCount][1])}, STR0100 ) //Totalizando Sintéticas
				EndIf
			Next nCount

			MostraFluxo(MV_PAR03, MV_PAR04, cAliasFIY, lGravada,nLoop == 2,aParam,aPerguntas,cAliasTRB,aPeriodos,cAliasTRB2,aPeriodos2,,cCodFlx,cCodFlxCmp,MV_PAR05)
		Endif
	Endif
	cFilAnt := cFilOld
	//-----------------------------------------------------------
	// Apaga o arquivo temporario
	//-----------------------------------------------------------
	If cAliasFIY <> Nil .And. !Empty(cAliasFIY)
		If Select(cAliasFIY) > 0
			(cAliasFIY)->(DbCloseArea())
		EndIf
		//Deleta tabela temporária no banco de dados
		If 	_oFINC0221 <> Nil
			_oFINC0221:Delete()
			_oFINC0221 := Nil
		EndIf
	EndIf
	If cAliasTRB <> Nil .And. !Empty(cAliasTRB)
		If Select(cAliasTRB) > 0
			(cAliasTRB)->(DbCloseArea())
		EndIf
		MSErase(cAliasTRB+GetDbExtension())
		MSErase(cAliasTRB+OrdBagExt())
	EndIf
	If cAliasTRB2 <> Nil .And. !Empty(cAliasTRB2)
		If Select(cAliasTRB2) > 0
			(cAliasTRB2)->(DbCloseArea())
		EndIf
		MSErase(cAliasTRB2+GetDbExtension())
		MSErase(cAliasTRB2+OrdBagExt())
	EndIf
	dbSelectArea("SA1")

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³VldPerFlx ³ Autor ³ Claudio D. de Souza   ³ Data ³ 12/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida periodo do fluxo de caixa por natureza              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ VldPerFlx                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldPerFlx
Local lRet := .T.

If lRet
	//-----------------------------------------------------------
	// MV_PAR05 = Mostra periodo em (1=Semanas,2=Meses)
	//-----------------------------------------------------------
	If MV_PAR05 == 1
		//-----------------------------------------------------------
		// MV_PAR03 = Data inicial do periodo
		// MV_PAR04 = Data final do periodo
		//-----------------------------------------------------------
		If (MV_PAR04-MV_PAR03) > 31
			lRet := .F.
			Alert(STR0101) //"O período máximo para consulta é de um mes, quando deseja visualizar em dias"
		Endif

	ElseIf MV_PAR05 == 2
		//-----------------------------------------------------------
		// MV_PAR03 = Data inicial do periodo
		// MV_PAR04 = Data final do periodo
		//-----------------------------------------------------------
		If (MV_PAR04-MV_PAR03) > (365/2)
			lRet := .F.
			Alert(STR0102)	//"O período máximo para consulta é de seis meses, quando deseja visualizar em semanas"
		Endif
		
	ElseIf MV_PAR05 == 3
		//-----------------------------------------------------------
		// MV_PAR03 = Data inicial do periodo
		// MV_PAR04 = Data final do periodo
		//-----------------------------------------------------------
		If (MV_PAR04-MV_PAR03) > 365
			lRet := .F.
			Alert(STR0103) //"O período máximo para consulta é de um ano, quando deseja visualizar em meses"
		Endif
		
	Endif
EndIf

If lRet .And. mv_par05 == 4
	If (mv_par04-mv_par03) > (365*3)
		lRet := .F.
		Alert(STR0104)	//"Período máximo para consulta é de três anos."
	Endif
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FlCxNatPro³ Autor ³ Claudio D. de Souza   ³ Data ³ 12/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processamento do Fluxo de Caixa por Natureza               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FlCxNatProc                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINC022                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FlCxNatProc(lEnd,cNatIni,cNatFin,dDtIni,dDtFin,nTipo,cAliasFIY,lGravada,cCodCons,cMoedPar,cAliasTRB,aPeriodos)
Local aArea			:= GetArea()
Local cAliasTmp		:= GetNextAlias()
Local lAbat			:= .F.
Local nPosTpSald	:= 0
Local nI			:= 0
Local nA			:= 0
Local nPosCpo		:= 0
Local cCarteira		:= ""
Local cNatureza		:= ""
Local cSequencia	:= ""
Local cPeriodo		:= ""
Local cPrefCpo		:= ""
Local nX			:= 0
Local nPos			:= 0
Local aLinha	 	:= {}
Local nLen 			:= Len(aPeriodos)
Local aVisaoFim		:= {}
Local nPosFim	 	:= 0
Local nPosInicio	:= 0
Local nContX		:= 0
local nSinal		:= 1
Local lRet			:= .T.
Local lVisaoGer		:= lfluxSint .AND. !Empty(mv_par16)
Local lCompVis		:= FWModeAccess("FJ1") == "C" .AND. FWModeAccess("FJ2") == "C" .AND. FWModeAccess("FJ3") == "C"
Local lMontaVis		:= .T.
Local lValidNat		:= .F.
Local nPosTotal2	:= 0
Local cEspacos		:= ""

DEFAULT cMoedPar 	:= '01'

If MV_PAR14 == 4 //Previsto X Realizado	
	nPosInicio := (cAliasTRB)->( FieldPos( "PREV001" ) ) - 1
Else
	nPosInicio := (cAliasTRB)->( FieldPos( "ORC001" ) ) - 1
EndIf

//-----------------------------------------------------------
// Verifica o tamanho do campo natureza e ajusta se necessário
//-----------------------------------------------------------
cNatIni := PADR(cNatIni,Len(SED->ED_CODIGO)," ")
cNatFin := PADR(cNatFin,Len(SED->ED_CODIGO)," ")

If MV_PAR15 //Considera Apenas Movimentos Bancarios 
	cQuery:= "% AND SED.ED_MOVBCO = '1' %"
Else
	cQuery:= "% %"
Endif

//-----------------------------------------------------------
// Seleciona os registros a serem processados
//-----------------------------------------------------------
If lGravada
	cPrefCpo := "FIY"
	BeginSql Alias cAliasTmp
		COLUMN FIY_DATA AS DATE

		SELECT *
		FROM %Table:SED% SED,
			%Table:FIY% FIY
		WHERE
			SED.ED_FILIAL = %xFilial:SED% AND
			SED.%NotDel% AND
			FIY.FIY_FILIAL = %xFilial:FIY% AND
			FIY.FIY_NATUR = SED.ED_CODIGO AND 
			FIY.FIY_CODIGO = %Exp:cCodCons% AND
			FIY.%NotDel%
			%exp:cQuery %
		ORDER BY FIY_DATA, FIY_NATUR
	EndSql
Else
	cPrefCpo := "FIV"
	BeginSql Alias cAliasTmp
		COLUMN FIV_DATA AS DATE

		SELECT *
		FROM %Table:SED% SED,
			%Table:FIV% FIV
		WHERE
			SED.ED_FILIAL = %xFilial:SED% AND
			SED.%NotDel% AND
			FIV.FIV_FILIAL = %xFilial:FIV% AND
			FIV.FIV_NATUR = SED.ED_CODIGO AND 
			FIV.FIV_NATUR >= %Exp:cNatIni% AND
			FIV.FIV_NATUR <= %Exp:cNatFin% AND
			FIV.FIV_DATA >= %Exp:dDtIni% AND
			FIV.FIV_DATA <= %Exp:dDtFin% AND
			FIV.FIV_MOEDA = %Exp:cMoedPar% AND
			FIV.%NotDel%
			%exp:cQuery%
		ORDER BY FIV_DATA, FIV_NATUR
	EndSql
EndIf

cAliasAux := cAliasTmp // No processamento de uma filial apenas, utiliza o resultado da Query para gravacao posterior
If Len(aVisao) > 0 .and. lCompVis
	lMontaVis := .F.
EndIf

If lfluxSint .and. (cAliasTmp)->(!Eof()) .and. lMontaVis
	If !Empty(MV_PAR16) .And. ValType(MV_PAR16) = "C" //Visao Gerencial - FSW

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Query para buscar a visão gerencial escolhida no parametro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		cQueryVis := " SELECT "
		For ni := 1 to len(aPeriodos)
			cQueryVis += " 0 as FJ3_COL1"+StrZero(ni,3)+", "
			cQueryVis += " 0 as FJ3_COL2"+StrZero(ni,3)+", "
			cQueryVis += " 0 as FJ3_COL3"+StrZero(ni,3)+", "
			cQueryVis += " 0 as FJ3_COL4"+StrZero(ni,3)+", "
		Next ni
		cQueryVis += " FJ3.* ,"
		cQueryVis += " FJ2.FJ2_DESCCG "		
		cQueryVis += " FROM " + RetSqlName("FJ3") + " FJ3"
		cQueryVis += " LEFT JOIN " + RetSqlName("FJ2") + " FJ2"
		cQueryVis += " ON FJ3.FJ3_CODPLA = FJ2.FJ2_CODIGO"
		cQueryVis += " AND FJ3.FJ3_ORDEM = FJ2.FJ2_ORDEM"
		cQueryVis += " WHERE FJ3.FJ3_CODPLA = '" + MV_PAR16 + "' "
		cQueryVis += " AND FJ2.D_E_L_E_T_ = ' ' "  
		cQueryVis += " AND FJ3.D_E_L_E_T_ = ' ' "  
		cQueryVis += " AND FJ3.FJ3_FILIAL = '" + xFilial("FJ3") + "' "
		cQueryVis += " ORDER BY FJ3.FJ3_CODPLA, FJ3.FJ3_ORDEM "

		cQueryVis := ChangeQuery(cQueryVis)

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryVis), 'VISAO', .T., .T.)  
		//--------------------------------------------------
		//Cria array com os campos da query
		//--------------------------------------------------
		While VISAO->(!Eof())
			For nX := 1 To VISAO->(fCount())     
				cCampo := VISAO->(FieldName(nX))
				nPosCpo := VISAO->(FieldPos(cCampo))
				If nPosCpo > 0
					if MV_PAR17 .and. UPPER(ALLTRIM(cCampo)) = "FJ3_DESCCG"
						AADD(aLinha,VISAO->FJ2_DESCCG)
					Else
						AADD(aLinha,VISAO->(FieldGet(nX)))
					EndIf
				Endif
			Next
			Aadd(aVisao, aLinha)
			aLinha:={}
			VISAO->(Dbskip())
		Enddo  
		VISAO->(dbCloseArea())
	Endif                                                                                      
EndIf

If cPrefCpo == "FIV"
	lAbat := .T.
EndIf
lRet := .F.
//-----------------------------------------------------------
// Coloca os dados do Fluxo em todas as colunas
//-----------------------------------------------------------
dbSelectArea(cAliasTmp)
While (cAliasTmp)->(!Eof())
	//-----------------------------------------------------------
	// Cria registro no arquivo temporario, para posterior gravacao
	//-----------------------------------------------------------
	If !Empty(cAliasFIY) .And. Select(cAliasFIY) > 0
		RecLock(cAliasFIY,.T.)
		For nX := 1 To (cAliasTmp)->(FCount())
			If (cAliasFIY)->(FieldPos((cAliasTmp)->(FieldName(nX)))) > 0
				(cAliasFIY)->( FieldPut( (cAliasFIY)->( FieldPos( (cAliasTmp)->( FieldName(nX) ) ) ), (cAliasTmp)->(FieldGet(nX))) )
			EndIf
		Next nX
	EndIf     

	//-----------------------------------------------------------
	// Descarta registros conforme os parametros
	//-----------------------------------------------------------
	If MV_PAR14 <> 1//Nenhum
		If (cAliasTmp)->&(cPrefCpo+"_TPSALD") == "1" // Saldo Orcado
			nPosTpSald := 1
			If MV_PAR14 == 4
				dbSelectArea(cAliasTMP)
				DbSkip()
				Loop
			Endif                                                                            
		ElseIf (cAliasTmp)->&(cPrefCpo+"_TPSALD") == "2" // Saldo Previsto       
			nPosTpSald := 2
			If MV_PAR14 == 3
				dbSelectArea(cAliasTMP)
				DbSkip()
				Loop
			Endif
		ElseIf (cAliasTmp)->&(cPrefCpo+"_TPSALD") == "3" // Saldo Realizado
			nPosTpSald := 3  
			If MV_PAR14 == 2
				dbSelectArea(cAliasTMP)
				DbSkip()
				Loop
			Endif
		Endif	  
	EndIf
			
	//-----------------------------------------------------------
	// Atualiza o arquivo temporario do fluxo de caixa
	//-----------------------------------------------------------
	cPeriodo   := Periodo(nTipo, (cAliasTmp)->&(cPrefCpo+"_DATA"), dDtIni, dDtFin)
	cNatureza  := (cAliasTmp)->( FieldGet( FieldPos(cPrefCpo+"_NATUR") ) ) + " - " + (cAliasTmp)->( FieldGet( FieldPos("ED_DESCRIC") ) )
	cCarteira  := (cAliasTmp)->( FieldGet( FieldPos(cPrefCpo+"_CARTEI") ) )
	If Empty(cCarteira)
		Help(" ",1,"CARTNTBRCO",,STR0095+ cNatureza + CRLF + CRLF + STR0096,1,0) //"Existem saldos sem a informação da carteira para a natureza " + Alltrim(&(cPrefCpo+"_NATUR")) //"Acesse o cadastro de Naturezas, informe sua condição e execute o Reprocessamento dos saldos."                                                                                                                                                                                                                                                                                                                                                                                                                      
		Exit
	EndIf
	If lVisaoGer
		cSequencia := "VIS"
	Else
		cSequencia := IIf(cCarteira=="R","001","002")
	EndIf
	
	DbSelectArea(cAliasTRB)
	DbSetOrder(1)
	If !MsSeek(cSequencia+cCarteira+cNatureza)
		RecLock(cAliasTRB,.T.)
	Else
		RecLock(cAliasTRB)
	EndIf
	(cAliasTRB)->CART		:= cCarteira
	(cAliasTRB)->SEQ		:= cSequencia
	(cAliasTRB)->NAT		:= cNatureza
	(cAliasTRB)->NATPAI		:= (cAliasTmp)->ED_PAI //Armazena os codigos da natureza e da superior
	(cAliasTRB)->CODNAT		:= AllTrim( (cAliasTmp)->( FieldGet( FieldPos(cPrefCpo+"_NATUR") ) ) )
	
	nX := aScan(aPeriodos,cPeriodo)
	
	If nX <> 0

		Do Case
			Case (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_TPSALD"))) == "1" // Saldo Orcado
				(cAliasTRB)->( FieldPut( FieldPos( "ORC"+StrZero(nX,3) ), FieldGet( FieldPos("ORC"+StrZero(nX,3) ) ) + (cAliasTmp)->( FieldGet( FieldPos( cPrefCpo+"_VALOR" ) ) ) ))
			Case (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_TPSALD"))) == "2" // Saldo Previsto
				(cAliasTRB)->( FieldPut( FieldPos("PREV"+StrZero(nX,3) ), FieldGet( FieldPos( "PREV"+StrZero(nX,3) ) ) + (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_VALOR"))) + If(lAbat,(cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_ABATI"))),0)))
			Case (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_TPSALD"))) == "3" // Saldo Realizado
				(cAliasTRB)->(FieldPut( FieldPos("REAL"+StrZero(nX,3)), FieldGet(FieldPos("REAL"+StrZero(nX,3))) + (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_VALOR"))) ))
		EndCase

		If MV_PAR14 == 2 //Orcado X Previsto
			(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),FieldGet(FieldPos("PREV"+StrZero(nX,3)))-FieldGet(FieldPos("ORC"+StrZero(nX,3)))))
		ElseIf MV_PAR14 == 3//Orcado X Realizado
			(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),FieldGet(FieldPos("REAL"+StrZero(nX,3)))-FieldGet(FieldPos("ORC"+StrZero(nX,3)))))
		ElseIf MV_PAR14 == 4//Previsto X Realizado
			(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),FieldGet(FieldPos("PREV"+StrZero(nX,3)))-FieldGet(FieldPos("REAL"+StrZero(nX,3)))))
		EndIf
				
	EndIf      
	lRet:= .t.
	MsUnLock()
	dbSelectArea(cAliasTMP)
	DbSkip()
EndDo


If lfluxSint .and. lRet
	//----------------------
	//VISAO GERENCIAL  FSW
	//----------------------  
	If !Empty(MV_PAR16)  
		//verifica se existe entidade com Total Visao TOTVIS = 1
		nPosTotGer := aScan(aVisao,{|x| x[(nLen*4)+17] == "1"})

		For nX:= 1 to Len(aVisao)
			
			if MV_PAR17
				if nX <> 1
					while avisao[nx - nContX][(nLen*4) + 3] == avisao[nx - 1 - nContX][(nLen*4) + 3]
						nContX++
					enddo
				endif
			endif

			cSuperior	:= aVisao[nX][(nLen*4)+5] // Conta Superior
			cIdenti		:= aVisao[nX][(nLen*4)+11] // Somar ou Subtrair (IDENT)
			nCont		:= Len(aVisao)
			//-----------------------------------------------------------------------	    
			//Procurar nas superiores e somar ou subtrair
			//-----------------------------------------------------------------------	    
			If !Empty(cSuperior)
				If !Empty(aVisao[nX][(nLen*4)+14]) .And. !Empty(aVisao[nX][(nLen*4)+15])  // SEDINI - SEDFIM
					//-----------------------------------------------------------------------	    
					//Somar ou Subtrair conforme campo FJ3_IDENTI
					//-----------------------------------------------------------------------	    
					dbSelectArea(cAliasTRB)
					dbSetOrder(1)
					dbGoTop()
									
					While !eof()
					  
						If (cAliasTRB)->CART  == "R" //Entrada
							If (cIdenti == '1')
								nSinal := 1
							Else
								nSinal := -1
							EndIf
						Else
							If (cIdenti == '1')
								nSinal := -1
							Else
								nSinal := 1
							EndIf
						EndIf

						If(cAliasTRB)->CART  == "R" //Validação para que os registros do contas a receber não duplicam ao aglutinar nas contas sinteticas que possuem superiores
							lValidNat := AllTrim( SubStr( (cAliasTRB)->NAT, 1, Len(SED->ED_CODIGO) ) ) == Alltrim( aVisao[nX][ ( nLen * 4 ) + 14 ] )
						Else
							lValidNat := AllTrim( SubStr( (cAliasTRB)->NAT, 1, Len(SED->ED_CODIGO) ) ) >= Alltrim( aVisao[nX][ ( nLen * 4 ) + 14 ] ) .And. AllTrim( SubStr( (cAliasTRB)->NAT, 1, Len(SED->ED_CODIGO) ) ) <= Alltrim( aVisao[nX][ ( nLen * 4 ) + 15 ] )
						EndIf

						If lValidNat
							For nA := 1 To (nLen * 4)
								aVisao[nX][nA] += ( (cAliasTRB)->( FieldGet( nA + nPosInicio ) ) * nSinal )//aFluxo[DADOSNATUREZA,nY,nA+1]
								If MV_PAR17  .and. nContX > 0// novo parametro
									aVisao[nX - nContX][nA] += ((cAliasTRB)->(FieldGet(nA+nPosInicio)) * nSinal)//aFluxo[DADOSNATUREZA,nY,nA+1]
								EndIf
								//Verifico se a conta analitica possui uma outra conta sintética com a opção de total geral habilitado.
								If !Empty(aVisao[nX][(nLen*4)+5]) 
									If nPosTotal := aScan(aVisao,{|x| x[(nLen*4)+4] == aVisao[nX][(nLen*4)+5]})
										// sintetica, sempre totaliza com as filhas
										If aVisao[nPosTotal][(nLen*4)+10] =="1" 
											aVisao[nPosTotal][nA] += ((cAliasTRB)->( FieldGet(nA+nPosInicio) )* nSinal) * IIf(aVisao[nX][(nLen*4)+20] == '2',-1,1) 
											// Verifico se existe uma conta totalizadora geral da conta sintética atualizada acima
											nPosTotal2 := nPosTotal
											While nPosTotal > 0 .and. !Empty(aVisao[nPosTotal2][(nLen*4)+5]) 
												If nPosTotal2 := aScan(aVisao,{|x| x[(nLen*4)+4] == aVisao[nPosTotal][(nLen*4)+5]})
													aVisao[nPosTotal2][nA] += ((cAliasTRB)->( FieldGet(nA+nPosInicio) )* nSinal) * IIf(aVisao[nX][(nLen*4)+20] == '2',-1,1)
												Endif
												nPosTotal := nPosTotal2
												nPosTotal -= 1 	
											Enddo	
										Endif
									Endif
								Endif
								If nPosTotGer > 0
									aVisao[nPosTotGer][nA] += ((cAliasTRB)->( FieldGet(nA+nPosInicio) )* nSinal) * IIf(aVisao[nX][(nLen*4)+20] == '2',-1,1)
								EndIf	

							Next nA 

							nPos := aScan( aVisao, { |x| x[ ( nLen * 4 ) + 4 ] == aVisao[nX][ ( nLen * 4 ) + 5 ] } ) //superior

						Endif
						 
						dbSelectArea(cAliasTRB)
						dbSetOrder(1)
						dbSkip()
					EndDo
				Endif
			Endif
						   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inverte o saldo se assim a entidade estiver configurada ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If 	aVisao[nX][(nLen*4)+20] == '2' .And. aVisao[nX][(nLen*4)+11] != '5'  //Não for linha sem valor (FATSLD/IDENT)
				For nA := 1 to (nLen*4)
					aVisao[nX][nA] := (aVisao[nX][nA] * -1)
				Next nA
			EndIf  
			
			if MV_PAR17 //parametro novo
				nContX := 0
			endif

		Next nX   
		// Zera Sintetica configurada com "Sem Valor"
		For nX:= 1 to Len(aVisao)
			If aVisao[nX][(nLen*4)+10] =="1" .and. (AllTrim(aVisao[nX][(nLen*4)+11]) == "6" .or. (AllTrim(aVisao[nX][(nLen*4)+11]) == "5" .and. Alltrim(aVisao[nX][(nLen*4)+6]) != "-"))// sintenticas Sem Valor
				For nA := 1 To (nLen * 4)
					aVisao[nX][nA] := 0
				Next nA	
			EndIf
		Next nX			       
		//------------------------------------------------------------------
		//Calculo das formulas digitadas pelo usuario           
		//------------------------------------------------------------------
		CalcForVS(aVisao,cAliasTRB,aPeriodos)                                                  
		
		dbSelectArea(cAliasTRB)
		dbSetOrder(1)
		dbGoTop()
						
		While !eof()
			If (cAliasTRB)->CART != "Z"
				RecLock(cAliasTRB,.f.)
				(cAliasTRB)->( dbDelete() )                  
				MsUnLock()
			EndIf
			dbSkip()					
		EndDo 
	
		dbSelectArea(cAliasTRB)
		dbSetOrder(1)
	
		aVisaoFim := {}

		For nx := 1 to len(aVisao)
			
				nPosFim := aScan(aVisaoFim,{|x| x[(nLen*4)+6] == aVisao[nx][(nLen*4)+6] .And. x[(nLen*4)+10] == '2'})     
				If nPosFim > 0
					For nA := 1 to (nLen*4)   
						If Alltrim(aVisao[nX][Len(aPeriodos)*4+18]) != '2'
							if !(MV_PAR17 .and. nX > 1 .and. avisao[nx][(nLen*4) + 3] == avisao[nx - 1][(nLen*4) + 3]) //parametro novo)
								aVisaoFim[nPosFim][nA] += aVisao[nx][na]
							EndIf								
						EndIf	
					Next nA
				Else
					If Alltrim(aVisao[nX][Len(aPeriodos)*4+18]) != '2' // FJ2_VISENT
						if !(MV_PAR17 .and. nX > 1 .and. avisao[nx][(nLen*4) + 3] == avisao[nx - 1][(nLen*4) + 3]) //parametro novo)
							aAdd(aVisaoFim,aVisao[nx])
						endif
					EndIf
				EndIf

			
		Next nx
		
		For nx := 1 to len(aVisaoFim)
			
				
				RecLock(cAliasTRB,.T.)
					(cAliasTRB)->ORDVIS	:= aVisaoFim[nx][(nLen*4)+3]
					(cAliasTRB)->SEQ	:= "VIS"
					(cAliasTRB)->NATPAI	:= AllTrim(aVisaoFim[nx][(nLen*4)+5]) //FJ3_CTASUP
					(cAliasTRB)->IDENT	:= AllTrim(aVisaoFim[nx][(nLen*4)+11]) //FJ3_IDENT
					(cAliasTRB)->TOTVIS	:= AllTrim(aVisaoFim[nx][(nLen*4)+17]) //FJ3_TOTVIS
					If Empty((cAliasTRB)->NATPAI)
						(cAliasTRB)->CART	:= "T" // Linha de totalizador deverá ser ignorada no calculo de totais
					Else
						If aVisaoFim[nx][(nLen*4)+8] == "1"
							(cAliasTRB)->CART	:= "P"
						ElseIf aVisaoFim[nx][(nLen*4)+8] == "2"
							(cAliasTRB)->CART	:= "R"
						EndIf
					EndIf
					If Alltrim(aVisaoFim[nX][(nLen*4)+6]) != "-"  //traco
						cEspacos := Replicate(" ", aVisaoFim[nx][(nLen*4)+9])//COLUNA
						(cAliasTRB)->NAT	:= AllTrim(aVisaoFim[nx][(nLen*4)+4])+"-"+cEspacos+aVisaoFim[nx][(nLen*4)+6] //cNatureza	FJ3_CONTAG+FJ3_DESCCG
						For nA := 1 to (nLen * 4)
							If MV_PAR14 == 4		// Considera campo de Comparativo
								(cAliasTRB)->( FieldPut( nA+7, aVisaoFim[nX][nA] ) )
							Else
								(cAliasTRB)->(FieldPut(nA+6,aVisaoFim[nX][nA]))
							EndIf
						Next nA	
					Else
						(cAliasTRB)->NAT	:= Replicate("-",Len((cAliasTRB)->NAT)) //cNatureza	FJ3_CONTAG+FJ3_DESCCG
						
					EndIf		
					
				(cAliasTRB)->( MsUnLock() )
				
			
		Next nx 
	
	Endif         
EndIf

dbSelectArea(cAliasTMP)
DbCloseArea()
RestArea(aArea)

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³MontaPeriodo³ Autor ³ Claudio D. de Souza   ³ Data ³ 12/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o cabecalho com os periodos do fluxo de caixa          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ MontaPeriodo(dDtIni, dDtFin, nTipo)	  				        ³±±
±±³          ³ dDtIni -> Data inicial do periodo da consulta                ³±±
±±³          ³ dDtFin -> Data final do periodo da consulta                  ³±±
±±³          ³ nTipo  -> Tipo da consulta (1=Dias, 2=Meses, 3=Semanas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  												  	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaPeriodo(dDtIni,dDtFinal,nTipo,cAliasTRB,aPeriodos)
Local dDtAux		:= dDtIni
Local cPeriodo	:= ""
Local aStruct		:= {}
Local nTamNat		:= Len(SED->ED_CODIGO)+Len(SED->ED_DESCRIC)+10
Local nTamNatPai	:= Len(SED->ED_CODIGO)
Local lVisaoGer := lfluxSint .AND. !Empty(mv_par16)

If lVisaoGer 
	nTamNat	:= Max(TamSX3("FJ3_CONTAG")[1]+TamSX3("FJ3_DESCCG")[1],nTamNat)
	nTamNatPai	:= Max(TamSX3("FJ3_CTASUP")[1],nTamNatPai)
	AAdd( aStruct, {"ORDVIS","C",__nTamOrdV,0} )
EndIf

//-----------------------------------------------------------
// Define a estrutura inicial do arquivo temporario de exibição do fluxo
//-----------------------------------------------------------
aadd(aStruct,{"SEQ"		,"C", 03			,0}) 
aadd(aStruct,{"CART"	,"C", 01			,0})
aadd(aStruct,{"NAT"		,"C", nTamNat		,0})
aadd(aStruct,{"NATPAI"	,"C", nTamNatPai	,0})
aadd(aStruct,{"CODNAT"	,"C", nTamNatPai	,0})

//-----------------------------------------------------------
// Calcula o numero de periodos. Maximo 999
//-----------------------------------------------------------
While dDtAux <= dDtFinal
	cPeriodo := Periodo(nTipo, dDtAux, dDtIni, dDtFinal)

	If Ascan(aPeriodos, cPeriodo ) == 0
		aadd(aPeriodos, cPeriodo)

		aadd(aStruct,{"ORC" +StrZero(Len(aPeriodos),3),"N",17,2})
		aadd(aStruct,{"PREV"+StrZero(Len(aPeriodos),3),"N",17,2})
		aadd(aStruct,{"REAL"+StrZero(Len(aPeriodos),3),"N",17,2})
		aadd(aStruct,{"COMP"+StrZero(Len(aPeriodos),3),"N",17,2})

	EndIf        

	dDtAux ++
EndDo

aadd( aStruct, { "ORCTOT" , "N", 17, 2 } )
aadd( aStruct, { "PREVTOT", "N", 17, 2 } )
aadd( aStruct, { "REALTOT", "N", 17, 2 } )
aadd( aStruct, { "COMPTOT", "N", 17, 2 } )
aadd( aStruct, {"IDENT"	  , "C", 01, 0 } )
aadd( aStruct, {"TOTVIS"  , "C", 01, 0 } )
//-----------------------------------------------------------
// Cria o arquivo de trabalho
//-----------------------------------------------------------
cAliasTRB := FWOPENTEMP( cAliasTRB, aStruct )

If lVisaoGer
	IndRegua(cAliasTRB,cAliasTRB,"ORDVIS+SEQ+CART+NAT")
Else
	IndRegua(cAliasTRB,cAliasTRB,"SEQ+CART+NAT")
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Periodo     ³ Autor ³ Claudio D. de Souza   ³ Data ³ 19/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Converte uma data em uma string o tipo da consulta           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Periodo(nTipo, dDtAux, dDtFin)                               ³±±
±±³          ³ nTipo  -> Tipo da consulta (1=Dias, 2=Meses, 3=Semanas       ³±±
±±³          ³ dDtAux -> Data para conversao                                ³±±
±±³          ³ dDtFin -> Data final do periodo da consulta                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  												  				    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Periodo(nTipo, dDtAux, dDtIni, dDtFin)
Local cPeriodo := ""

Default nTipo  := 0
Default dDtAux := dDataBase
Default dDtIni := dDataBase
Default dDtFin := dDataBase

Do Case
	Case nTipo == 1 // Dias
		cPeriodo := Left(DTOC(dDtAux),5)
	Case nTipo == 2 // Semanas
		cPeriodo := Semana(dDtAux, dDtIni, dDtFin)
	Case nTipo == 3 // Meses
		cPeriodo := MesExtenso(Month(dDtAux)) + "/" + StrZero(Year(dDtAux),4)
	Case nTipo == 4 // Anos - FSW
		cPeriodo := StrZero(Year(dDtAux),4)
EndCase

Return cPeriodo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³MostraFluxo ³ Autor ³ Claudio D. de Souza   ³ Data ³ 19/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a consulta ao Fluxo de Caixa por natureza              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ MostraFluxo(dDtIni, dDtFin)                                  ³±±
±±³          ³ aFluxo    -> Array contendo o cabecalho e os dados a exibir  ³±±
±±³          ³ dDtIni    -> Data inicial do periodo da consulta             ³±±
±±³          ³ dDtFin    -> Data final do periodo da consulta               ³±±
±±³          ³ cAliasFIY -> Alias do arquivo gerado no processamento        ³±±
±±³          ³              Sera utilizado na persistencia de dados         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  												  	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MostraFluxo(dDtIni, dDtFin, cAliasFIY, lGravada,lComp, aParam, aPerguntas,cAliasTRB,aPeriodos,cAliasTRB2,aPeriodos2,cAliasAna,cCodFlx,cCodFlxCmp,nTipo)
Local aSize
Local aObjects		:= {}
Local aInfo
Local aPosObj
Local oDlg
Local aHeader		:= {STR0031} //"Natureza"
Local aHeader2		:= {STR0031} //"Natureza"
Local nX			:= 0
Local cCodigo, cHora := Left(Time(),5)
Local aButton		:= {}
Local oTela
Local cIdBrowse
Local cIdRodape
Local oPanel1
Local oPanel2
Local oColumn
Local aUsButtons	:= {}

DEFAULT lComp		:= .F.
Default cCodFlx		:= ''
Default cCodFlxCmp 	:= ''
Default nTipo		:= 3
//-----------------------------------------------------------
// Define os botoes da barra de ferramentas
//-----------------------------------------------------------
If lGravada
	aButton	:= {	{ "RELATORIO", { || Fc022Rel(aPeriodos,aHeader,cAliasTRB,aPeriodos2,aHeader2,cAliasTRB2,lComp)  }, STR0032,STR0033 }} //"Imprime a consulta atual"###"Relatório"
Else
	aButton	:= {	{ "SALVAR"		,{ || Fc022Grava(cAliasFIY,@cCodigo, dDataBase, cHora, aParam, aPerguntas)		},STR0034,STR0035	},;	//"Salva o fluxo para consulta posterior"###"Salvar"	
						{ "RELATORIO", { || Fc022Rel(aPeriodos,aHeader,cAliasTRB,aPeriodos2,aHeader2,cAliasTRB2,lComp)	},STR0032,STR0033	},;	//"Imprime a consulta atual"###"Relatório"
						{ "GRAFICO"	,{ || Fc022ExibeGraf(cAliasTRB, aHeader, aPeriodos, nTipo)							},STR0109,STR0110	}}	//"Exibe Grafico com dados atuais", "Gráfico"
EndIf

If ExistBlock( "FC022BUT" )
	If ValType( aUsButtons := ExecBlock( "FC022BUT", .F., .F.,{aHeader, cAliasTRB} ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButton, x ) } )
	EndIf
EndIf

//-----------------------------------------------------------
// Preenche o Header do Browse
//-----------------------------------------------------------
For nX := 1 To Len(aPeriodos)

	If lGravada
		CarregaParam(cCodFlx)
	EndIf

	If MV_PAR14 == 1 //Nenhum
		aadd(aHeader,STR0036+" "+aPeriodos[nX]) //"Orçado"
		aadd(aHeader,STR0037+" "+aPeriodos[nX]) //"Previsto"
		aadd(aHeader,STR0038+" "+aPeriodos[nX]) //"Realizado"
	ElseIf MV_PAR14 == 2 //Orcado X Previsto
		aadd(aHeader,STR0036+" "+aPeriodos[nX]) //"Orçado"
		aadd(aHeader,STR0037+" "+aPeriodos[nX]) //"Previsto"
		aadd(aHeader,STR0068+" "+aPeriodos[nX]) //"Comparativo"
	ElseIf MV_PAR14 == 3//Orcado X Realizado
		aadd(aHeader,STR0036+" "+aPeriodos[nX]) //"Orçado"
		aadd(aHeader,STR0038+" "+aPeriodos[nX]) //"Realizado" 
		aadd(aHeader,STR0068+" "+aPeriodos[nX]) //"Comparativo"
	ElseIf MV_PAR14 == 4//Previsto X Realizado
		aadd(aHeader,STR0037+" "+aPeriodos[nX]) //"Previsto"
		aadd(aHeader,STR0038+" "+aPeriodos[nX]) //"Realizado"
		aadd(aHeader,STR0068+" "+aPeriodos[nX]) //"Comparativo"
	EndIf
	
Next nX	

If lComp

	If lGravada
		CarregaParam(cCodFlxCmp)
	EndIf

	For nX := 1 To Len(aPeriodos2)

		If MV_PAR14 == 1 //Nenhum
			aadd(aHeader2,STR0036+" "+aPeriodos2[nX]) //"Orçado"
			aadd(aHeader2,STR0037+" "+aPeriodos2[nX]) //"Previsto"
			aadd(aHeader2,STR0038+" "+aPeriodos2[nX]) //"Realizado"
		ElseIf MV_PAR14 == 2 //Orcado X Previsto
			aadd(aHeader2,STR0036+" "+aPeriodos2[nX]) //"Orçado"
			aadd(aHeader2,STR0037+" "+aPeriodos2[nX]) //"Previsto"
			aadd(aHeader2,STR0068+" "+aPeriodos2[nX]) //"Comparativo"				
		ElseIf MV_PAR14 == 3//Orcado X Realizado
			aadd(aHeader2,STR0036+" "+aPeriodos2[nX]) //"Orçado"
			aadd(aHeader2,STR0038+" "+aPeriodos2[nX]) //"Realizado"
			aadd(aHeader2,STR0068+" "+aPeriodos2[nX]) //"Comparativo"				
		ElseIf MV_PAR14 == 4//Previsto X Realizado
			aadd(aHeader2,STR0037+" "+aPeriodos2[nX]) //"Previsto"
			aadd(aHeader2,STR0038+" "+aPeriodos2[nX]) //"Realizado"
			aadd(aHeader2,STR0068+" "+aPeriodos2[nX]) //"Comparativo"
		EndIf

	Next nX	
Endif
//-----------------------------------------------------------
// Montagem da tela de exibicao
//-----------------------------------------------------------
aSize := MsAdvSize()
aadd( aObjects, {  30,  70, .T., .T.} )
aadd( aObjects, {  20, 180, .T., .T., .T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
aPosObj := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oDlg TITLE STR0039 + Dtoc(dDtIni) + STR0040 + Dtoc(dDtFin)  FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL OF oMainWnd //"Fluxo de Caixa" //"Fluxo de Caixa" //" em " //"Fluxo de Caixa por natureza periodo de "###" a "
oDlg:lMaximized := .T.
//-----------------------------------------------------------
// Se for uma comparacao, o aFluxo2 sera um Array, cria 2 paineis para exibir os dois fluxos
//-----------------------------------------------------------
If lComp
	oTela     := FWFormContainer():New( oDlg )
	cIdBrowse := oTela:CreateHorizontalBox( 46 )
	cIdRodape := oTela:CreateHorizontalBox( 46 )
	oTela:Activate( oDlg, .F. )
	
	oPanel1  := oTela:GeTPanel( cIdBrowse )
	oPanel2  := oTela:GeTPanel( cIdRodape )

	If lGravada
		CarregaParam(cCodFlx)
	EndIf

	dbSelectArea(cAliasTRB)
	DbSetOrder(1)

	DEFINE FWBROWSE oFluxo DATA TABLE ALIAS cAliasTRB NO SEEK NO CONFIG OF oPanel1
	ADD COLUMN oColumn DATA {|| Iif((cAliasTRB)->CART <> "Z",MascNat(SubStr((cAliasTRB)->NAT,1,TamSX3("ED_CODIGO")[1]))+" "+SubStr((cAliasTRB)->NAT,At("-",(cAliasTRB)->NAT)),(cAliasTRB)->NAT)} TITLE aHeader[1] SIZE 30 ALIGN 1 HEADERCLICK { || }  OF oFluxo
	For nX := 1 To Len(aPeriodos)
		If MV_PAR14 == 1 //Nenhum
			If MV_PAR05 == 3
				ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->ORC'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+2] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK {|| IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB), ) }  OF oFluxo
			EndIf
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->PREV'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+3] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK {|| IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB), ) } OF oFluxo
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->REAL'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+4] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK {|| IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB), ) } OF oFluxo
		ElseIf MV_PAR14 == 2 //Orcado X Previsto
			If MV_PAR05 == 3
				ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->ORC'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+2] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK {|| IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB), ) } OF oFluxo
			EndIf
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->PREV'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+3] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK {|| IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB), ) } OF oFluxo
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->COMP'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+4] SIZE 15 ALIGN 2 HEADERCLICK { || } OF oFluxo		
		ElseIf MV_PAR14 == 3//Orcado X Realizado			
			If MV_PAR05 == 3
				ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->ORC'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+2] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK {|| IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB), ) } OF oFluxo
			EndIf
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->REAL'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+3] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK {|| IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB), ) }  OF oFluxo
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->COMP'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+4] SIZE 15 ALIGN 2 HEADERCLICK { || } OF oFluxo
		ElseIf MV_PAR14 == 4//Previsto X Realizado			
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->PREV'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+2] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK {|| IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB), ) }  OF oFluxo
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->REAL'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+3] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK {|| IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB), ) } OF oFluxo
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->COMP'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+4] SIZE 15 ALIGN 2 HEADERCLICK { || } OF oFluxo
		EndIf
					
	Next nX
	If MV_PAR14 == 1 //Nenhum		
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->ORCTOT ,__cPicVal) }') TITLE STR0036+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Orçado"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->PREVTOT,__cPicVal) }') TITLE STR0037+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Previsto"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->REALTOT,__cPicVal) }') TITLE STR0038+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Realizado"
	ElseIf MV_PAR14 == 2 //Orcado X Previsto	
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->ORCTOT ,__cPicVal) }') TITLE STR0036+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Orçado"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->PREVTOT,__cPicVal) }') TITLE STR0037+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Previsto"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->COMPTOT,__cPicVal) }') TITLE STR0068+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Comparativo"		
	ElseIf MV_PAR14 == 3//Orcado X Realizado
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->ORCTOT ,__cPicVal) }') TITLE STR0036+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Orçado"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->REALTOT,__cPicVal) }') TITLE STR0038+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Realizado"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->COMPTOT,__cPicVal) }') TITLE STR0068+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Comparativo"		
	ElseIf MV_PAR14 == 4//Previsto X Realizado	
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->PREVTOT,__cPicVal) }') TITLE STR0037+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Previsto"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->REALTOT,__cPicVal) }') TITLE STR0038+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Realizado"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->COMPTOT,__cPicVal) }') TITLE STR0068+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Comparativo"		
	EndIf		
		
	DbSelectArea(cAliasTRB2)
	DbSetOrder(1)
	DEFINE FWBROWSE oFluxo2 DATA TABLE ALIAS cAliasTRB2 NO SEEK NO CONFIG OF oPanel2
	ADD COLUMN oColumn DATA {|| Iif((cAliasTRB2)->CART <> "Z",MascNat(SubStr((cAliasTRB2)->NAT,1,TamSX3("ED_CODIGO")[1]))+" "+SubStr((cAliasTRB2)->NAT,At("-",(cAliasTRB2)->NAT)),(cAliasTRB2)->NAT) } TITLE aHeader2[1] SIZE 30 ALIGN 1 HEADERCLICK { || }  OF oFluxo2

	For nX := 1 To Len(aPeriodos2)

		If MV_PAR14 == 1 //Nenhum
			If MV_PAR05 == 3
				ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->ORC'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader2[((nX-1)*3)+2] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2
			EndIf
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->PREV'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader2[((nX-1)*3)+3] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->REAL'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader2[((nX-1)*3)+4] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2
		ElseIf MV_PAR14 == 2 //Orcado X Previsto
			If MV_PAR05 == 3
				ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->ORC'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader2[((nX-1)*3)+2] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2
			EndIf
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->PREV'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader2[((nX-1)*3)+3] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->COMP'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader2[((nX-1)*3)+4] SIZE 15 ALIGN 2 HEADERCLICK { || } OF oFluxo2		
		ElseIf MV_PAR14 == 3//Orcado X Realizado				
			If MV_PAR05 == 3
				ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->ORC'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader2[((nX-1)*3)+2] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2
			EndIf
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->REAL'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader2[((nX-1)*3)+3] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->COMP'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader2[((nX-1)*3)+4] SIZE 15 ALIGN 2 HEADERCLICK { || } OF oFluxo2		
		ElseIf MV_PAR14 == 4//Previsto X Realizad
			If MV_PAR05 == 3
				ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->ORC'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader2[((nX-1)*3)+2] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2			
			EndIf
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->REAL'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader2[((nX-1)*3)+3] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->COMP'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader2[((nX-1)*3)+4] SIZE 15 ALIGN 2 HEADERCLICK { || } OF oFluxo2		
		EndIf
	Next nX
	
	If MV_PAR14 == 1 //Nenhum                                                                                                   d
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->ORCTOT ,__cPicVal) }') TITLE STR0036+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2 //"Total"###"Orçado"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->PREVTOT,__cPicVal) }') TITLE STR0037+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2 //"Total"###"Previsto"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->REALTOT,__cPicVal) }') TITLE STR0038+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2 //"Total"###"Realizado"
	ElseIf MV_PAR14 == 2 //Orcado X Previsto
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->ORCTOT ,__cPicVal) }') TITLE STR0036+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2 //"Total"###"Orçado"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->PREVTOT,__cPicVal) }') TITLE STR0037+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2 //"Total"###"Previsto"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->COMPTOT,__cPicVal) }') TITLE STR0068+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2 //"Total"###"Comparativo"
	ElseIf MV_PAR14 == 3//Orcado X Realizado
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->ORCTOT ,__cPicVal) }') TITLE STR0036+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2 //"Total"###"Orçado"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->REALTOT,__cPicVal) }') TITLE STR0038+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2 //"Total"###"Realizado"				
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->COMPTOT,__cPicVal) }') TITLE STR0068+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2 //"Total"###"Comparativo"		
	ElseIf MV_PAR14 == 4//Previsto X Realizado
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->PREVTOT,__cPicVal) }') TITLE STR0037+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2 //"Total"###"Previsto"		
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->REALTOT,__cPicVal) }') TITLE STR0038+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2 //"Total"###"Realizado"							
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->COMPTOT,__cPicVal) }') TITLE STR0068+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2 //"Total"###"Comparativo"
	EndIf

Else                    

	DEFINE FWBROWSE oFluxo DATA TABLE ALIAS cAliasTRB NO SEEK NO CONFIG OF oDlg
	ADD COLUMN oColumn DATA {|| Iif((cAliasTRB)->CART <> "Z" .AND. (cAliasTRB)->SEQ <> "VIS",MascNat(SubStr((cAliasTRB)->NAT,1,TamSX3("ED_CODIGO")[1]))+" "+SubStr((cAliasTRB)->NAT,At("-",(cAliasTRB)->NAT)),(cAliasTRB)->NAT) } TITLE aHeader[1] SIZE 30 ALIGN 1 HEADERCLICK { || }  OF oFluxo
	For nX := 1 To Len(aPeriodos)
		If MV_PAR14 == 1 //Nenhum
			If MV_PAR05 == 3
				ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->ORC'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+2] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK { || IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB),   ) } OF oFluxo
			EndIf
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->PREV'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+3] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK { || IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB),   ) } OF oFluxo
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->REAL'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+4] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK { || IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB),   ) } OF oFluxo
		ElseIf MV_PAR14 == 2 //Orcado X Previsto
			If MV_PAR05 == 3
				ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->ORC'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+2] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK { || IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB),   ) } OF oFluxo
			EndIf
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->PREV'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+3] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK { || IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB),   ) } OF oFluxo
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->COMP'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+4] SIZE 15 ALIGN 2 HEADERCLICK { || } OF oFluxo
		ElseIf MV_PAR14 == 3//Orcado X Realizado
			If MV_PAR05 == 3
				ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->ORC'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+2] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK { || IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB),   ) } OF oFluxo
			EndIf
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->REAL'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+3] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK { || IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB),   ) } OF oFluxo
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->COMP'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+4] SIZE 15 ALIGN 2 HEADERCLICK { || } OF oFluxo				
		ElseIf MV_PAR14 == 4//Previsto X Realizado
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->PREV'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+2] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK { || IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB),   ) } OF oFluxo
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->REAL'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+3] SIZE 15 ALIGN 2 HEADERCLICK { || } DOUBLECLICK { || IIF(!lFluxSint, MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB),   ) } OF oFluxo
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->COMP'+StrZero(nX,3)+',__cPicVal) }') TITLE aHeader[((nX-1)*3)+4] SIZE 15 ALIGN 2 HEADERCLICK { || } OF oFluxo
		EndIf

	Next nX

	If MV_PAR14 == 1 //Nenhum		
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->ORCTOT ,__cPicVal) }') TITLE STR0036+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Orçado"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->PREVTOT,__cPicVal) }') TITLE STR0037+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Previsto"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->REALTOT,__cPicVal) }') TITLE STR0038+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Realizado"
	ElseIf MV_PAR14 == 2 //Orcado X Previsto		
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->ORCTOT ,__cPicVal) }') TITLE STR0036+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Orçado"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->PREVTOT,__cPicVal) }') TITLE STR0037+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Previsto"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->COMPTOT,__cPicVal) }') TITLE STR0068+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Comparativo"
	ElseIf MV_PAR14 == 3//Orcado X Realizado		
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->ORCTOT ,__cPicVal) }') TITLE STR0036+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Orçado"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->REALTOT,__cPicVal) }') TITLE STR0038+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Realizado"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->COMPTOT,__cPicVal) }') TITLE STR0068+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Comparativo"			
	ElseIf MV_PAR14 == 4//Previsto X Realizado		
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->PREVTOT,__cPicVal) }') TITLE STR0037+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Previsto"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->REALTOT,__cPicVal) }') TITLE STR0038+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Realizado"
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->COMPTOT,__cPicVal) }') TITLE STR0068+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Comparativo"
	EndIf
EndIf

oFluxo:SetBlkBackColor( { || IIf((cAliasTRB)->CART == "Z" , CLR_GREEN, IIf((cAliasTRB)->IDENT $ "36", CLR_BLACK, Nil ) ) } )
oFluxo:SetBlkColor( { || IIf((cAliasTRB)->CART == "Z" , CLR_WHITE, IIf((cAliasTRB)->IDENT $ "36", CLR_WHITE, Nil ) ) } )

//-----------------------------------------------------------
// Cria o Grid do 2o. Fluxo
//-----------------------------------------------------------
If lComp
	oFluxo2:SetBlkBackColor( { || IIf((cAliasTRB2)->CART == "Z" , CLR_GREEN, IIf((cAliasTRB)->IDENT $ "36" , CLR_BLACK, Nil ) ) } )
	oFluxo2:SetBlkColor( { || IIf((cAliasTRB2)->CART == "Z" , CLR_WHITE, IIf((cAliasTRB)->IDENT $ "36", CLR_WHITE, Nil ) ) } )
Endif

//PE apos totalizacao do Fluxo
If ExistBlock("FC022FLUXO")
	ExecBlock("FC022FLUXO",.F.,.F.,{aHeader,cAliasTRB,aPeriodos})
Endif

oFluxo:DisableReport()
ACTIVATE FWBROWSE oFluxo
If lComp
	oFluxo2:DisableReport()
	ACTIVATE FWBROWSE oFluxo2
EndIf
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()},,aButton)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Semana       ³ Autor ³ Claudio D. de Souza   ³ Data ³ 19/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o inicio e o fim de uma semana, baseado em uma data   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Semana(dData, dDtIni, dDtFin)                                 ³±±
±±³          ³ dData  -> Data a ser considerada                              ³±±
±±³          ³ dDtFin -> Data inicial do periodo (data minima)               ³±±
±±³          ³ dDtFin -> Data final do periodo (data maxima)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  												  	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Semana(dData, dDtIni, dDtFin)
Local cSemana
Local nSemana
Local nInicio
Local nFim

nDias := Day(dData) + (Dow(Firstday(dData)-1))
nSemana := NoRound( nDias / 7, 0) + Iif( (nDias % 7) > 0 , 1,0)

nInicio := Dow(dData)
nFim := (7-Dow(dData))

cSemana := Left(Dtoc(Max(dDtIni,dData-nInicio+1)),5) + STR0040 + Left(Dtoc(Min(dDtFin,dData+nFim)),5) //" a "

Return cSemana // "Semana " + Alltrim(Str(nSemana) + " - " + cSemana)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³SaldosInicias³ Autor ³ Claudio D. de Souza   ³ Data ³ 19/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o saldo incial do Fluxo                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ SaldosInicias(nTipo, aFluxo, dData)                           ³±±
±±³          ³ nTipo  -> Tipo da consulta (1=Dias, 2=Meses, 3=Semanas        ³±±
±±³          ³ aFluxo -> Array contendo os periodos do fluxo                 ³±±
±±³          ³ dData  -> Data do saldo                                       ³±±
±±³          ³ cTipoSaldo -> Tipo de saldo a ser considerado                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  												  	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SaldosInicias(nTipo as numeric ,dData as DATE,cTipoSaldo as character,cAliasTRB as character,aPeriodos as ARRAY ,aBancos as ARRAY ,;
							cNatIni as character,cNatFin as character,dDtIni as DATE,dDtFin as DATE, aSelFil as character)
Local aArea       	as ARRAY 
Local cAliasSE8   	as character 
Local nSaldoTotal 	as numeric 
Local nX          	as numeric
Local nTrbSaldo   	as numeric
Local nMoedaBco   	as numeric
Local cCodIn	  	as character 
Local cAgeIn	  	as character 
Local cConIn	  	as character 
Local cAlFIV		as character 
Local cORFIV   		as character 

Local nTotOrc		as numeric
Local nSalOrc		as numeric
Local lVisaoGer 	as logical
Local cOrdemVis 	as character
Local dDtOldfin		as DATE
Local cWhere		as Character
Local cFilSA6		as Character
Local cFilFiv		as Character
Local nTamFSA6		as numeric	
Local nTamFSE8		as numeric
Local nTamFil		as numeric

Default cNatIni		:= ""
Default cNatFin		:= ""
Default dDtIni		:= dData
Default dDtFin		:= dData
Default aSelFil 	:= {cFilAnt}

aArea		:= GetArea()
cAliasSE8	:= GetNextAlias()
nSaldoTotal := 0
nX 			:= 0
nTrbSaldo   := 0
nMoedaBco   := 0
cCodIn	  	:= "" 
cAgeIn	  	:= ""
cConIn	  	:= "" 
cAlFIV		:= GetNextAlias()
cORFIV   	:= GetNextAlias()
nTotOrc		:= 0
nSalOrc		:= 0
lVisaoGer 	:= lfluxSint .AND. !Empty(mv_par16)
cOrdemVis 	:= ""
cWhere		:= ""
If !Empty(xFilial("SA6")) 
	cFilSA6		:= "%SA6.A6_FILIAL " + FinSelFil( aSelFil, "SA6", .F., .F.) + " %"
Else
	cFilSA6		:= "%SA6.A6_FILIAL = '" + xFilial("SA6") + "' %"
EndIf 

If !Empty(xFilial("FIV")) 
	cFilFiv		:= "%FIV.FIV_FILIAL " + FinSelFil( aSelFil, "FIV", .F., .F.) + " %"
Else
	cFilFiv		:= "%FIV.FIV_FILIAL = '" + xFilial("FIV") + "' %"
EndIf

nTamFSA6 := Len(Alltrim(xFilial("SA6")))
nTamFSE8 := Len(Alltrim(xFilial("SE8")))

If nTamFSE8 > nTamFSA6
	nTamFil	:= nTamFSA6
Else
	nTamFil	:= nTamFSE8
EndIf

If nTamFil > 0
	cWhere := "%SUBSTRING(SA6.A6_FILIAL,1," + Str(nTamFil) + ") =  SUBSTRING(SE8.E8_FILIAL,1," + Str(nTamFil) + ") AND %"  
Else 
	If nTamFSE8 == 0
		cWhere := "%SE8.E8_FILIAL = '" + xFilial("SE8") + "' AND %" 	 
	Else
		cWhere := "%SE8.E8_FILIAL " + FinSelFil( aSelFil, "SE8", .F., .F.) + " AND %"
	EndIf 	
Endif

For nX:=1 to Len(aBancos)
	If nx == 1
		cCodIn += aBancos[nx][2]+"',"
		cAgeIn += aBancos[nx][3]+"',"
		cConIn += aBancos[nx][4]+"',"
	Else
		cCodIn += "'"+aBancos[nx][2]+"'," 	
		cAgeIn += "'"+aBancos[nx][3]+"',"
		cConIn += "'"+aBancos[nx][4]+"'," 	
	EndIf
Next

cCodIn  := "%SA6.A6_COD     IN ('"+SubStr(cCodIn,1,Len(cCodIn)-2)+"') %"
cAgeIn := "%SA6.A6_AGENCIA IN ('"+SubStr(cAgeIn,1,Len(cAgeIn)-2)+"') %"
cConIn := "%SA6.A6_NUMCON  IN ('"+SubStr(cConIn,1,Len(cConIn)-2)+"') %"

BeginSql Alias cAliasSE8
	COLUMN E8_DTSALAT AS DATE

	SELECT SA6.A6_MOEDA,E8_FILIAL,E8_DTSALAT,E8_BANCO,E8_AGENCIA,E8_CONTA,E8_SALATUA,E8_SALRECO,E8_SALATUA
	FROM %Table:SA6% SA6,
		%Table:SE8% SE8
	WHERE
		%Exp:cFilSA6% AND

		%Exp:cCodIn% AND
		%Exp:cAgeIn% AND
		%Exp:cConIn% AND
		SA6.A6_FLUXCAI IN('S',' ') AND 
		SA6.%NotDel% AND
		%Exp:cWhere%
		SE8.E8_BANCO = SA6.A6_COD AND 
		SE8.E8_AGENCIA = SA6.A6_AGENCIA AND
		SE8.E8_CONTA = SA6.A6_NUMCON AND
		SE8.%NotDel% AND
		SE8.E8_DTSALAT = ( SELECT MAX(TMP.E8_DTSALAT)
							FROM %Table:SE8% TMP
							WHERE 
								TMP.E8_FILIAL = SE8.E8_FILIAL AND
								TMP.E8_BANCO = SA6.A6_COD AND 
								TMP.E8_AGENCIA = SA6.A6_AGENCIA AND
								TMP.E8_CONTA = SA6.A6_NUMCON AND
								TMP.E8_DTSALAT <= %Exp:dData% AND
								TMP.%NotDel% )
		ORDER BY E8_FILIAL,E8_BANCO,E8_AGENCIA,E8_CONTA,E8_DTSALAT
EndSql

DbSelectArea(cAliasSE8)
(cAliasSE8)->(DbGoTop())

While !(cAliasSE8)->(Eof())
	nMoedaBco  := IIf( cPaisLoc="BRA",1,Max((cAliasSE8)->A6_MOEDA,1))	
	If Left(cTipoSaldo,1)=="1" // Somente saldo normal
		nTrbSaldo := xMoeda((cAliasSE8)->E8_SALATUA,nMoedaBco,1)
	ElseIf Left(cTipoSaldo,1)=="2" // Somente os conciliados
		nTrbSaldo := xMoeda((cAliasSE8)->E8_SALRECO,nMoedaBco,1)
	Elseif Left(cTipoSaldo,1)=="3" // Nao conciliados
		nTrbSaldo := xMoeda((cAliasSE8)->E8_SALATUA-(cAliasSE8)->E8_SALRECO,nMoedaBco,1)
	Endif
	nSaldoTotal += nTrbSaldo
	DbSelectArea(cAliasSE8)
	dbSkip()
EndDo
(cAliasSE8)->(dbCloseArea())


//Para conseguir o saldo orçados é necessário posicionar a data para o final do mês
dDtOldfin	:= dDtFin
dDtFin	:= lastday(dDtFin)

BeginSql Alias cORFIV
	COLUMN FIV_DATA AS DATE

	SELECT *
	FROM %Table:FIV% FIV
	WHERE
		%Exp:cFilFiv% AND
		FIV.FIV_NATUR >= %Exp:cNatIni% AND
		FIV.FIV_NATUR <= %Exp:cNatFin% AND
		FIV.FIV_DATA <= %Exp:dDtFin% AND
		FIV.FIV_TPSALD = '1' AND
		FIV.%NotDel%
	ORDER BY FIV_DATA, FIV_NATUR
EndSql

DbSelectArea(cORFIV)
(cORFIV)->( dbGotop() )

While !(cORFIV)->(Eof())
	nSalOrc	:= 0
	nMoedaBco  := IIf( cPaisLoc="BRA",1,Max((cORFIV)->FIV_MOEDA,1))	
	nSalOrc := xMoeda((cORFIV)->FIV_VALOR,nMoedaBco,1)
	nTotOrc		+= nSalOrc
	(cORFIV)->(dbSkip())
EndDo
(cORFIV)->(dbCloseArea())

DbSelectArea("FIV")	
DbSelectArea("SE8")
//-----------------------------------------------------------
// Atualiza o arquivo temporario do fluxo de caixa
//-----------------------------------------------------------
cOrdemVis := Iif( lVisaoGer, Space( __nTamOrdV ), "" )
dbSelectArea(cAliasTRB)
If DbSeek(cOrdemVis+"000"+"Z"+STR0021)
	RecLock(cAliasTRB,.F.)
	(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(1,3)), FieldGet(FieldPos("PREV"+StrZero(1,3))) + nSaldoTotal))
	(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(1,3)), FieldGet(FieldPos("REAL"+StrZero(1,3))) + nSaldoTotal))
	(cAliasTRB)->(FieldPut(FieldPos("ORC"+StrZero(1,3)), FieldGet(FieldPos("ORC"+StrZero(1,3))) + nTotORC))
Else
	RecLock(cAliasTRB,.T.)
	(cAliasTRB)->SEQ := "000"
	(cAliasTRB)->CART:= "Z"
	(cAliasTRB)->NAT := STR0021 //"Saldos iniciais"
	FieldPut(FieldPos("PREV"+StrZero(1,3)),nSaldoTotal) // previsto e realizado devem ser iguais
	FieldPut(FieldPos("REAL"+StrZero(1,3)),nSaldoTotal)
	FieldPut(FieldPos("ORC"+StrZero(1,3)),nTotORC)
EndIf

dDtFin := dDtOldfin

MsUnLock()
RestArea(aArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Fc022Rel  ºAutor  ³Claudio Donizete    º Data ³  24/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o relatorio da consulta                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINC022                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc022Rel(aPeriodos,aHeader,cAliasTRB,aPeriodos2,aHeader2,cAliasTRB2,lPergunta)
Local aSaveArea := GetArea()
Local oReport
Local aParam := {}

If	!lPergunta .Or.;
	ParamBox( {	{ 3, STR0046, 2, { STR0047, STR0048}, 100,, .T. } },; //"Escolha qual fluxo imprimir"###"Fluxo 1"###"Fluxo 2"
	STR0049,aParam,,,,,,,ProcName(),.T.,.T.) //"Impressão do Fluxo de Caixa"
	
	If !lPergunta .Or. MV_PAR01 == 1
	   	//FSW - 05/05/2011 - Chamada para a nota explicativa 
		Fc022Nota() 
		oReport := ReportDef(aPeriodos,cAliasTRB,aHeader)
	Else
		//FSW - 05/05/2011 - Chamada para a nota explicativa
	    cNota := cNota2
	    Fc022Nota()                                                                                
		oReport := ReportDef(aPeriodos2,cAliasTRB2,aHeader2)
	Endif
	oReport:PrintDialog()
Endif

RestArea(aSaveArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ReportDef ºAutor  ³Claudio Donizete    º Data ³  24/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria as definicoes do relatorio                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINC022                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef(aPeriodos As Array, cAliasTRB As Character,aHeader As Array) As Object
Local oReport	As Object
Local oSection	As Object
Local nX		As Numeric

oReport		:= Nil
oSection	:= Nil
nX			:= 0

oReport := TReport():New("FINC022",STR0050 + " - " + DtoC(MV_PAR03) + STR0040 + DtoC(MV_PAR04) ,"",{|oReport| Fc022Imp(oReport,cAliasTRB,aPeriodos)}, STR0051) //"Fluxo de Caixa por Natureza"###"Imprime relatório da consulta Fluxo de Caixapor Natureza"
oReport:SetLandscape(.T.)

//-------------------------------------------------------------------------------//
// Parcelas
DEFINE SECTION oSection OF oReport TITLE STR0052 TOTAL IN COLUMN           //"Movimentos"
DEFINE CELL NAME STR0031 OF oSection SIZE 50 TITLE STR0031 //"Natureza"###"Natureza"

If lfluxSint .and. !Empty(mv_par16) //Visao Gerencial FSW
	oSection:Cell(STR0031):SetBlock( { || (cAliasTRB)->NAT } ) //Natureza sem o tratamento
Else
	oSection:Cell(STR0031):SetBlock( { || Iif((cAliasTRB)->CART <> "Z",MascNat(SubStr((cAliasTRB)->NAT,1,TamSX3("ED_CODIGO")[1]))+" "+SubStr((cAliasTRB)->NAT,At("-",(cAliasTRB)->NAT)),(cAliasTRB)->NAT) } ) //"Natureza"
Endif		

For nX := 1 To Len(aPeriodos)

	If MV_PAR14 == 1 //Nenhum
		DEFINE CELL NAME "CEL"+Alltrim(Str((nX*3)-2)) OF oSection SIZE 23 TITLE aHeader[(nX*3)]			
		oSection:Cell("CEL"+Alltrim(Str((nX*3)-2))):SetBlock( &('{|| TransForm((cAliasTRB)->PREV'+StrZero(nX,3)+',__cPicVal) }') )
		If MV_PAR05 == 3
			DEFINE CELL NAME "CEL"+Alltrim(Str((nX*3)-1)) OF oSection SIZE 23 TITLE aHeader[(nX*3)-1]			
			oSection:Cell("CEL"+Alltrim(Str((nX*3)-1))):SetBlock( &('{|| TransForm((cAliasTRB)->ORC'+StrZero(nX,3)+',__cPicVal) }') )
		EndIf
		DEFINE CELL NAME "CEL"+Alltrim(Str((nX*3))) OF oSection SIZE 23 TITLE aHeader[(nX*3)+1]			
		oSection:Cell("CEL"+Alltrim(Str((nX*3)))):SetBlock( &('{|| TransForm((cAliasTRB)->REAL'+StrZero(nX,3)+',__cPicVal) }') )
	ElseIf MV_PAR14 == 2 //Orcado X Previsto
		If MV_PAR05 == 3
			DEFINE CELL NAME "CEL"+Alltrim(Str((nX*3)-2)) OF oSection SIZE 23 TITLE aHeader[(nX*3)-1]			
			oSection:Cell("CEL"+Alltrim(Str((nX*3)-2))):SetBlock( &('{|| TransForm((cAliasTRB)->ORC'+StrZero(nX,3)+',__cPicVal) }') )
		EndIf
		DEFINE CELL NAME "CEL"+Alltrim(Str((nX*3)-1)) OF oSection SIZE 23 TITLE aHeader[(nX*3)]			
		oSection:Cell("CEL"+Alltrim(Str((nX*3)-1))):SetBlock( &('{|| TransForm((cAliasTRB)->PREV'+StrZero(nX,3)+',__cPicVal) }') )
		DEFINE CELL NAME "CEL"+Alltrim(Str((nX*3))) OF oSection SIZE 23 TITLE aHeader[(nX*3)+1]			
		oSection:Cell("CEL"+Alltrim(Str((nX*3)))):SetBlock( &('{|| TransForm((cAliasTRB)->COMP'+StrZero(nX,3)+',__cPicVal) }') )
	ElseIf MV_PAR14 == 3//Orcado X Realizado
		If MV_PAR05 == 3
			DEFINE CELL NAME "CEL"+Alltrim(Str((nX*3)-2)) OF oSection SIZE 23 TITLE aHeader[(nX*3)-1]			
			oSection:Cell("CEL"+Alltrim(Str((nX*3)-2))):SetBlock( &('{|| TransForm((cAliasTRB)->ORC'+StrZero(nX,3)+',__cPicVal) }') )
		EndIf
		DEFINE CELL NAME "CEL"+Alltrim(Str((nX*3)-1)) OF oSection SIZE 23 TITLE aHeader[(nX*3)]			
		oSection:Cell("CEL"+Alltrim(Str((nX*3)-1))):SetBlock( &('{|| TransForm((cAliasTRB)->REAL'+StrZero(nX,3)+',__cPicVal) }') )
		DEFINE CELL NAME "CEL"+Alltrim(Str((nX*3))) OF oSection SIZE 23 TITLE aHeader[(nX*3)+1]			
		oSection:Cell("CEL"+Alltrim(Str((nX*3)))):SetBlock( &('{|| TransForm((cAliasTRB)->COMP'+StrZero(nX,3)+',__cPicVal) }') )
	ElseIf MV_PAR14 == 4//Previsto X Realizado
		DEFINE CELL NAME "CEL"+Alltrim(Str((nX*3)-2)) OF oSection SIZE 23 TITLE aHeader[(nX*3)-1]		
		oSection:Cell("CEL"+Alltrim(Str((nX*3)-2))):SetBlock( &('{|| TransForm((cAliasTRB)->PREV'+StrZero(nX,3)+',__cPicVal) }') )
		DEFINE CELL NAME "CEL"+Alltrim(Str((nX*3)-1)) OF oSection SIZE 23 TITLE aHeader[(nX*3)]			
		oSection:Cell("CEL"+Alltrim(Str((nX*3)-1))):SetBlock( &('{|| TransForm((cAliasTRB)->REAL'+StrZero(nX,3)+',__cPicVal) }') )
		DEFINE CELL NAME "CEL"+Alltrim(Str((nX*3))) OF oSection SIZE 23 TITLE aHeader[(nX*3)+1]			
		oSection:Cell("CEL"+Alltrim(Str((nX*3)))):SetBlock( &('{|| TransForm((cAliasTRB)->COMP'+StrZero(nX,3)+',__cPicVal) }') )
	EndIf
Next

If MV_PAR14 == 1 //Nenhum	
	DEFINE CELL NAME "CELTOT1" OF oSection SIZE 23 TITLE STR0036+" "+STR0030 //"Total"###"Orçado"
	oSection:Cell("CELTOT1"):SetBlock( &('{|| TransForm((cAliasTRB)->ORCTOT,__cPicVal) }') )
	DEFINE CELL NAME "CELTOT2" OF oSection SIZE 23 TITLE STR0037+" "+STR0030 //"Total"###"Previste"
	oSection:Cell("CELTOT2"):SetBlock( &('{|| TransForm((cAliasTRB)->PREVTOT,__cPicVal) }') )
	DEFINE CELL NAME "CELTOT3" OF oSection SIZE 23 TITLE STR0038+" "+STR0030 //"Total"###"Realizado"
	oSection:Cell("CELTOT3"):SetBlock( &('{|| TransForm((cAliasTRB)->REALTOT,__cPicVal) }') )
ElseIf MV_PAR14 == 2 //Orcado X Previsto
	DEFINE CELL NAME "CELTOT1" OF oSection SIZE 23 TITLE STR0036+" "+STR0030 //"Total"###"Orçado"
	oSection:Cell("CELTOT1"):SetBlock( &('{|| TransForm((cAliasTRB)->ORCTOT,__cPicVal) }') )
	DEFINE CELL NAME "CELTOT2" OF oSection SIZE 23 TITLE STR0037+" "+STR0030 //"Total"###"Previste"
	oSection:Cell("CELTOT2"):SetBlock( &('{|| TransForm((cAliasTRB)->PREVTOT,__cPicVal) }') )
	DEFINE CELL NAME "CELTOT4" OF oSection SIZE 23 TITLE STR0068+" "+STR0030 //"Total"###"Comparativo"
	oSection:Cell("CELTOT4"):SetBlock( &('{|| TransForm((cAliasTRB)->COMPTOT,__cPicVal) }') )
ElseIf MV_PAR14 == 3//Orcado X Realizado
	DEFINE CELL NAME "CELTOT1" OF oSection SIZE 23 TITLE STR0036+" "+STR0030 //"Total"###"Orçado"
	oSection:Cell("CELTOT1"):SetBlock( &('{|| TransForm((cAliasTRB)->ORCTOT,__cPicVal) }') )
	DEFINE CELL NAME "CELTOT3" OF oSection SIZE 23 TITLE STR0038+" "+STR0030 //"Total"###"Realizado"
	oSection:Cell("CELTOT3"):SetBlock( &('{|| TransForm((cAliasTRB)->REALTOT,__cPicVal) }') )
	DEFINE CELL NAME "CELTOT4" OF oSection SIZE 23 TITLE STR0068+" "+STR0030 //"Total"###"Comparativo"
	oSection:Cell("CELTOT4"):SetBlock( &('{|| TransForm((cAliasTRB)->COMPTOT,__cPicVal) }') )
ElseIf MV_PAR14 == 4//Previsto X Realizado	
	DEFINE CELL NAME "CELTOT2" OF oSection SIZE 23 TITLE STR0037+" "+STR0030 //"Total"###"Previste"
	oSection:Cell("CELTOT2"):SetBlock( &('{|| TransForm((cAliasTRB)->PREVTOT,__cPicVal) }') )
	DEFINE CELL NAME "CELTOT3" OF oSection SIZE 23 TITLE STR0038+" "+STR0030 //"Total"###"Realizado"
	oSection:Cell("CELTOT3"):SetBlock( &('{|| TransForm((cAliasTRB)->REALTOT,__cPicVal) }') )
	DEFINE CELL NAME "CELTOT4" OF oSection SIZE 23 TITLE STR0068+" "+STR0030 //"Total"###"Comparativo"
	oSection:Cell("CELTOT4"):SetBlock( &('{|| TransForm((cAliasTRB)->COMPTOT,__cPicVal) }') )
EndIf

oSection:SetColSpace(0)
oSection:nLinesBefore := 2
oSection:SetLineBreak()

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Fc022Imp  ºAutor  ³Claudio Donizete    º Data ³  24/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicia a impressao do relatorio                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Goldfarb                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc022Imp(oReport,cAliasTRB,aPeriodos)
Local oSection	:= oReport:Section(1)//Empreendimento
Local nLinha 	:=1
Local nBranco	:=0
Local nX		:=0
Local lVisaoGer := lfluxSint .AND. !Empty(mv_par16)
Local cNatTmp := ""

oReport:SetMeter((cAliasTRB)->(LastRec()))

//FSW - 05/05/2011 - Impressao da nota explicativa na primeira pagina do relatorio
if !Empty(cNota)
	nlin := oReport:row()
	oReport:PrintText(STR0105, nlin, 100) //"Notas Explicativas:"
	oReport:IncRow()        
	nlin := oReport:row()

	While .T.
  		//Verifica se a linha lida e vazia
		If AllTrim(Memoline(cNota,,nLinha)) = ""
			nBranco := nBranco+1
		Else
			nBranco :=0
		EndIf
  		//Verifica apos 5 lonhas sair da impressao
		If nBranco == 5
			Exit
		Endif
  		//Impressao da linha no relatorio
		oReport:PrintText(Memoline(cNota,,nLinha), nlin,100)  
		oReport:IncRow()        
		nlin := oReport:row()   
		nLinha := nLinha + 1
	EndDo
	oReport:EndPage(.T.)
Endif	

oSection:Init()

dbSelectArea(cAliasTRB)
(cAliasTRB)->( dbGotop() )

While (cAliasTRB)->( !Eof() )

	If oReport:Cancel()
		Exit
	EndIf

	If (cAliasTRB)->CART == "Z"
		oReport:IncMeter()
		oSection:PrintLine()	
		dbSelectArea(cAliasTRB)
		(cAliasTRB)->( dbSkip() )
		Loop
	EndIf

	If lVisaoGer
		cNatTmp := AllTrim(SubStr((cAliasTRB)->NAT,AT('-',(cAliasTRB)->NAT)+1))
		For nX := 1 To Len(aVisao)
			If AllTrim(aVisao[nX][Len(aPeriodos)*4+6]) == cNatTmp
				oReport:IncMeter()
				If Alltrim(aVisao[nX][Len(aPeriodos)*4+18]) != '2' //VISENT
					oSection:PrintLine()
				EndIf
				Exit
			Endif		
		Next nX
	Else //Se não for visão gerencial
		oReport:IncMeter()
		oSection:PrintLine()
	Endif
	
	(cAliasTRB)->( dbSkip() )
EndDo

oSection:Finish()
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fc022Grava   ³ Autor ³ Claudio D. de Souza   ³ Data ³ 25/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a consulta atual para visualizacao futura               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fc022Grava(cAliasFIY, cCodigo, dData, cHora)                  ³±±
±±³          ³ cAliasFIY -> Alias do arquivo que contem os dados a gravar    ³±±
±±³          ³ cCodigo   -> Codigo da consulta  (por referencia)             ³±±
±±³          ³ dData     -> Data para gravacao                               ³±±
±±³          ³ cHora     -> Hora para gravacao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  												  				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc022Grava(cAliasFIY, cCodigo, dData, cHora, aParam, aPerguntas)
Local aSaveArea	:= GetArea()
Local lRet			:= .F.

cHora := StrTran(cHora, ":", "")

//FSW - 05/05/2011 - Chamada da funcao para geracao de notas especificas
Fc022Nota()

If cCodigo # Nil
	FIX->(DbSetOrder(1)) // FIX_FILIAL+FIX_CODIGO+DTOS(FIX_DATA)+FIX_HORA+FIX_CODUSR
	// Verifica se a consulta nao foi gravada
	If !FIX->(MsSeek(xFilial("FIX") + cCodigo+ DTOS(dData) + cHora + __cUserID))
		MsgRun( STR0053,, { || lRet := Fc022Inc(cAliasFIY, @cCodigo, dData, cHora, aParam, aPerguntas) }  ) //"Aguarde, gravando a consulta"
	Else
		Alert(STR0054 + Dtoc(dData) + STR0055 + Transform(cHora, "@R 99:99") )  //"Consulta já foi gravada! em "###" as "
	Endif
Else
	MsgRun( STR0053,, { || lRet := Fc022Inc(cAliasFIY, @cCodigo, dData, cHora, aParam, aPerguntas) } ) //"Aguarde, gravando a consulta"
Endif

If lRet
	Aviso("FINC022",STR0056,{"Ok"}) //"Gravação efetuada com sucesso..."
Endif

RestArea(aSaveArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fc022Inc     ³ Autor ³ Claudio D. de Souza   ³ Data ³ 25/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui registro na tabela FIX                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fc022Inc(cAliasFIY, cCodigo, dData, cHora)                    ³±±
±±³          ³ cAliasFIY -> Alias do arquivo que contem os dados a gravar    ³±±
±±³          ³ cCodigo   -> Codigo da consulta (por referencia)              ³±±
±±³          ³ dData     -> Data para gravacao                               ³±±
±±³          ³ cHora     -> Hora para gravacao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  												  				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc022Inc(cAliasFIY, cCodigo, dData, cHora, aParam, aPerguntas)
Local nX
Local cCampo
Local nPosCpoFiy
Local cParametros	:= ""
Local lRet			:= .T.
Local PulaLinha	:= CHR(13)+CHR(10)
Local cTabFlx		:= If(lfluxSint,'FIV','FJV')

// Atualiza o codigo no momento da inclusao do registro de persistencia
cCodigo := GetSx8Num("FIX", "FIX_CODIGO")
ConfirmSx8()

For nX := 1 To Len(aPerguntas)
	cParametros += aPerguntas[nX,2] + " (MV_PAR" + StrZero(nX,2) + ")="
	If ValType(&("MV_PAR"+StrZero(nX,2))) == "L"
		cParametros += If(&("MV_PAR"+StrZero(nX,2)),".T. - Marcado",".F. - Desmarcado")
	ElseIf ValType(&("MV_PAR"+StrZero(nX,2))) $ "CDN"
		cParametros += Transform(&("MV_PAR"+StrZero(nX,2)), "")
	Endif
	If aPerguntas[nX,1] == 2 .Or. aPerguntas[nX,1] == 3 // Listbox, Radio button
		cParametros += Space(3) + " - " + aPerguntas[nX,4,&("MV_PAR"+StrZero(nX,2))]
	Endif
	cParametros += " "+PulaLinha
Next

// Grava o cabecalho da persistencia
RecLock("FIX",.T.)
FIX->FIX_FILIAL	:= xFilial("FIX")
FIX->FIX_CODIGO	:= cCodigo
FIX->FIX_DATA		:= dData
FIX->FIX_HORA		:= StrTran(cHora, ":", "")
FIX->FIX_CODUSR	:= __cUserID

//FSW - 05/05/2011 - Gravacao da nota especifica
FIX->FIX_OBS1 := cNota

// GRava os parametros
MSMM(FIX->FIX_CODPAR,,,cParametros,1,,,"FIX","FIX_CODPAR")
MsUnlock()
FkCommit()

(cAliasFIY)->(DbGotop())
While (cAliasFIY)->(!Eof())
	If FIY->(MsSeek(xFilial("FIY")+cCodigo+(cAliasFIY)->(&(cTabFlx+'_NATUR')+&(cTabFlx+'_MOEDA')+&(cTabFlx+'_TPSALD')+&(cTabFlx+'_CARTEI')+DTOS(&(cTabFlx+'_DATA')))))
		RecLock("FIY",.F.)
		FIY->FIY_VALOR += (cAliasFIY)->&(cTabFlx+'_VALOR')
	Else
		RecLock("FIY",.T.)
		For nX := 1 To (cAliasFIY)->(fCount())
			cCampo := StrTran((cAliasFIY)->(FieldName(nX)), cTabFlx, "FIY")
			// Gravo os campos comuns entre FIX e FIY
			nPosCpoFiy := FIY->(FieldPos(cCampo))
			If nPosCpoFiy > 0
				FIY->(FieldPut(nPosCpoFiy,(cAliasFIY)->(FieldGet(nX))))
			Endif
		Next
		FIY->FIY_FILIAL := xFilial("FIY")
		FIY->FIY_CODIGO := cCodigo
	Endif
	MsUnlock()
	FkCommit()
	(cAliasFIY)->(DbSkip())
End

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CarregaParam ³ Autor ³ Claudio D. de Souza   ³ Data ³ 26/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega os parametros de uma consulta gravada anteriormente   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CarregaParam(cCodFlx)                                         ³±±
±±³          ³ cCodFlx -> Codigo da consulta                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  								  				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CarregaParam(cCodFlx,aParam)
Local cParametros	:= ""
Local nAt			:= 0
Local nX			:= 0
Local xCont
Local cMvPar		:= ""

Default aParam := {}

FIX->(MsSeek(xFilial("FIX")+cCodFlx))
cParametros := MSMM( FIX->FIX_CODPAR,,,,3)
nLinhas := MlCount(cParametros)

For nX := 1 to nLinhas
	cLinha	:= Alltrim(MemoLine(cParametros,,nX))
	nAt		:= At("=", cLinha)

	If nAt > 0
		cMvPar := SubStr(cLinha, nAt-9, 8)
		If At(" - ", cLinha) > 0
			xCont := SubStr(cLinha, nAt+1,3)
		Else
			xCont := SubStr(cLinha, nAt+1)
		Endif

		If nLinhas == 16 //Consulta Sintética 
			Do Case
				Case UPPER(cMvPar) $ "MV_PAR03|MV_PAR04"
					xCont := Ctod(xCont)
				Case UPPER(cMvPar) $ "MV_PAR05|MV_PAR10|MV_PAR12|MV_PAR13|MV_PAR14"
					xCont := Val(xCont)
				Case UPPER(cMvPar) $ "MV_PAR06|MV_PAR07|MV_PAR08|MV_PAR09|MV_PAR15"
					xCont := &(xCont)
			EndCase	
		Else //Consulta Analitica
			Do Case
				Case UPPER(cMvPar) $ "MV_PAR03|MV_PAR04"
					xCont := Ctod(xCont)
				Case UPPER(cMvPar) $ "MV_PAR05|MV_PAR10|MV_PAR12|MV_PAR13|MV_PAR14"
					xCont := Val(xCont)
				Case UPPER(cMvPar) $ "MV_PAR06|MV_PAR07|MV_PAR08|MV_PAR09|MV_PAR15|MV_PAR16|MV_PAR17|MV_PAR18"
					xCont := &(xCont)
			EndCase	
		EndIf
		SetPrvt(cMvPar)
		&(cMvPar) := xCont
		aAdd(aParam,xCont)    
	EndIf		

	//Ajuste para comparação de consultas gravadas sem Analítica X Sintética
	If nLinhas < 13
		SetPrvt(MV_PAR13)
		MV_PAR13 := 2 //Padrão 2-Não			
	EndIf

Next nX

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fc022Compr   ³ Autor ³ Claudio D. de Souza   ³ Data ³ 28/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa os pedidos de compras                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fc022Compr(nTipo, dDtIni, dDtFin, cAliasFIY, aFluxo)          ³±±
±±³          ³ nTipo     -> Tipo da consulta (1=Dias, 2=Meses, 3=Semanas     ³±±
±±³          ³ dDtIni    -> Data inicial do periodo da consulta              ³±±
±±³          ³ dDtFin    -> Data final do periodo da consulta                ³±±
±±³          ³ cAliasFIY -> Alias do arquivo temporário utilizado na persist.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc022Compr(nTipo,dDtIni,dDtFin,cAliasFIY,cAliasTRB,aPeriodos,cAliasAna,aSelFil)
Local aArea       := GetArea()
Local nX          := 0
Local nY          := 0
Local cOldMvPAr03 := MV_PAR03
Local cPeriodo    := ""
Local cDescNat    := ""
Local nPosPrev		:= 0
Local lVisaoGer := lfluxSint .AND. !Empty(mv_par16)
Local cOrdemVis := ""

//-----------------------------------------------------------
// Variaveis utilizadas pela rotina Fc020Compra()
//-----------------------------------------------------------
PRIVATE aCompras  := {}
PRIVATE adCompras := {}
MV_PAR03 := 1 // Variavel private usada na rotina Fc020Compr, que tem seu conteudo diferente da rotina atual
Fc020Compra(,,.F.,1,,cFilAnt, cFilAnt, , , ,  aSelFil)
MV_PAR03 := cOldMvPAr03

cOrdemVis := Iif( lVisaoGer, Space( __nTamOrdV ), "" )
//-----------------------------------------------------------
// Prepara os dados do fluxo de compras para exibição
//-----------------------------------------------------------
For nY := 1 To Len(aCompras)
	cDescNat	:= ""
	If (aCompras[nY,1] >= dDtIni .AND. aCompras[nY,1] <= dDtFin).And.;
		(aCompras[nY,3] >= MV_PAR01 .AND. aCompras[nY,3] <= MV_PAR02) 
		//-----------------------------------------------------------
		// Verifica se esta no periodo solicitado
		//-----------------------------------------------------------
		cPeriodo := Periodo(nTipo, aCompras[nY,1], dDtIni, dDtFin)	
		//-----------------------------------------------------------
		// Pega a descricao da natureza
		//-----------------------------------------------------------
		DbSelectArea("SED")
		DbSetOrder(1)		
		If MsSeek(xFilial("SED") + aCompras[nY,3])
			cDescNat := aCompras[nY,3] + " - " + SED->ED_DESCRIC
		EndIf
		
		nX := aScan(aPeriodos,cPeriodo)
		If aCompras[nY,1] < dDtIni
			nX := 1
		EndIf
		
		If aCompras[nY,1] < dDtIni			
			aAreaTRB	:= (cAliasTRB)->(GetArea())
			dbSelectArea(cAliasTRB)
			If DbSeek(cOrdemVis+"000"+"Z"+STR0021)
				RecLock(cAliasTRB,.F.)
				(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(1,3)), FieldGet(FieldPos("PREV"+StrZero(1,3))) - aCompras[nY,2]))	
			Else
				RecLock(cAliasTRB,.T.)
				(cAliasTRB)->SEQ := "000"
				(cAliasTRB)->CART:= "Z"
				(cAliasTRB)->NAT := STR0021 //"Saldos iniciais"
				(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(1,3)), FieldGet(FieldPos("PREV"+StrZero(1,3))) - aCompras[nY,2]))
			EndIf
			RestArea(aAreaTRB)
			MsUnLock()
		EndIf
				
		//-----------------------------------------------------------
		// Atualiza o arquivo do fluxo
		//-----------------------------------------------------------		
		DbSelectArea(cAliasTRB)
		DbSetOrder(1)
		If !MsSeek("002"+"P"+cDescNat)
			RecLock(cAliasTRB,.T.)
		ElseIf Empty(cDescNat)
			RecLock(cAliasTRB,.T.)
		Else
			RecLock(cAliasTRB)
		EndIf
		(cAliasTRB)->CART := "P"
		(cAliasTRB)->SEQ  := "002"
		(cAliasTRB)->NAT  := If(Empty(cDescNat), STR0057, cDescNat)
		
				
		If nX <> 0
			If aCompras[nY,1] >= dDtIni
				(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),FieldGet(FieldPos("PREV"+StrZero(nX,3)))+aCompras[nY,2]))	
			EndIf
			If MV_PAR14 <> 1
				(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),FieldGet(FieldPos("COMP"+StrZero(nX,3)))+aCompras[nY,2]))
			EndIf

		EndIf
		MsUnLock()

		If nX <> 0
			If !lfluxSint  //Fluxo analitico, adiciona natureza no array aFluxAna                                                  
				If cAliasAna == "Zero"
					If Select(cAliasAna) <= 0
						CriaAna(@cAliasAna)
					EndIf
				EndIf
				If Select(cAliasAna) > 0
				
					If MV_PAR14 == 1 .Or. MV_PAR14 == 2 //Sem comparacao | //Orçado x Previsto
						nPosPrev := 2
					ElseIf MV_PAR14 == 4 //Previsto x Realizado
						nPosPrev := 1
					EndIf
				
					DbSelectArea(cAliasAna)
					RecLock(cAliasAna,.T.)
					(cAliasAna)->ANA_NAT		:= If(Empty(cDescNat), STR0057, cDescNat)
					(cAliasAna)->ANA_NPOS	:= StrZero(((nX*3)-3+1)+nPosPrev,3)
					(cAliasAna)->ANA_MOEDA	:= "01"
					(cAliasAna)->ANA_CART	:= "P"
					(cAliasAna)->ANA_DATA	:= aCompras[nY,1]
					(cAliasAna)->ANA_VALOR	:= aCompras[nY,2]
					(cAliasAna)->ANA_TPMOV	:= 'SOMA'
					(cAliasAna)->ANA_ORIGEM	:= 'PC'
					MsUnLock()	
				EndIf
			Endif
		Endif
		//-----------------------------------------------------------		
		// Cria registro no arquivo temporario, para posterior gravacao
		//-----------------------------------------------------------
		Fc022IncTrb(aCompras[nY,3],aCompras[nY,1],aCompras[nY,2],"P",cAliasFIY) //aqui
	EndIf
Next nY
RestArea(aArea)
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fc022Venda   ³ Autor ³ Claudio D. de Souza   ³ Data ³ 28/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa os pedidos de vendas                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fc022Venda(nTipo, dDtIni, dDtFin, cAliasFIY, aFluxo)          ³±±
±±³          ³ nTipo     -> Tipo da consulta (1=Dias, 2=Meses, 3=Semanas     ³±±
±±³          ³ dDtIni    -> Data inicial do periodo da consulta              ³±±
±±³          ³ dDtFin    -> Data final do periodo da consulta                ³±±
±±³          ³ cAliasFIY -> Alias do arquivo temporário utilizado na persist.³±±
±±³          ³ aFluxo    -> Array com o cabecalho e os dados do fluxo 	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  												  	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc022Venda(nTipo,dDtIni,dDtFin,cAliasFIY,cAliasTRB,aPeriodos,cAliasAna,aSelFil)
Local cOldMvPAr03:= MV_PAR03
Local cPeriodo		:= ""
Local cDescNat		:= ""
Local nX			:= 0
Local nY			:= 0
Local nPosPrev		:= 0
Local lVisaoGer := lfluxSint .AND. !Empty(mv_par16)
Local cOrdemVis := ""

//-----------------------------------------------------------
// Variaveis utilizadas pela rotina Fc020Venda()
//-----------------------------------------------------------
PRIVATE aVendas  := {}
PRIVATE adVendas := {}
cOldMvPAr03 := MV_PAR03
MV_PAR03 := 1 // Variavel private usada na rotina Fc020Venda, que tem seu conteudo diferente da rotina atual
Fc020Venda(,,,.F.,1,,cFilAnt, cFilAnt,,,,aSelFil)
MV_PAR03 := cOldMvPAr03

cOrdemVis := Iif( lVisaoGer, Space( __nTamOrdV ), "" )
//-----------------------------------------------------------
// Prepara os dados do fluxo de venda para exibição
//-----------------------------------------------------------
SED->(DbSetOrder(1))
For nY := 1 To Len(aVendas)
	cDescNat	:= ""
	If (aVendas[nY,1] >= dDtIni .AND. aVendas[nY,1] <= dDtFin).And.;
		(aVendas[nY,3] >= MV_PAR01 .AND. aVendas[nY,3] <= MV_PAR02)
		//-----------------------------------------------------------
		// Verifica se esta no periodo solicitado
		//-----------------------------------------------------------
		cPeriodo := Periodo(nTipo,aVendas[nY,1],dDtIni,dDtFin)
		//-----------------------------------------------------------
		// Pega a descricao da natureza
		//-----------------------------------------------------------
		If SED->(MsSeek(xFilial("SED") + aVendas[nY,3]))
			cDescNat    := Alltrim(aVendas[nY,3])+" - " + SED->ED_DESCRIC
		EndIf
		
		If aVendas[nY,1] < dDtIni			
			aAreaTRB	:= (cAliasTRB)->(GetArea())
			dbSelectArea(cAliasTRB)
			If DbSeek(cOrdemVis+"000"+"Z"+STR0021)
				RecLock(cAliasTRB,.F.)
				(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(1,3)), FieldGet(FieldPos("PREV"+StrZero(1,3))) + aVendas[nY,2]))	
			Else
				RecLock(cAliasTRB,.T.)
				(cAliasTRB)->SEQ := "000"
				(cAliasTRB)->CART:= "Z"
				(cAliasTRB)->NAT := STR0021 //"Saldos iniciais"
				(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(1,3)), FieldGet(FieldPos("PREV"+StrZero(1,3))) + aVendas[nY,2]))
			EndIf
			RestArea(aAreaTRB)
			MsUnLock()
		EndIf
					
		
		//-----------------------------------------------------------
		// Atualiza o arquivo do fluxo
		//-----------------------------------------------------------		
		DbSelectArea(cAliasTRB)
		DbSetOrder(1)
		If !MsSeek("001"+"R"+cDescNat)
			RecLock(cAliasTRB,.T.)
		ElseIf Empty(cDescNat)
			RecLock(cAliasTRB,.T.)
		Else
			RecLock(cAliasTRB)
		EndIf
		(cAliasTRB)->CART := "R"
		(cAliasTRB)->SEQ  := "001"
		(cAliasTRB)->NAT  := If(Empty(cDescNat), STR0057, cDescNat)
		
		nX := aScan(aPeriodos,cPeriodo)
		If aVendas[nY,1] < dDtIni
			nX := 1
		EndIf		
		If nX <> 0
			If aVendas[nY,1] >= dDtIni
				(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),FieldGet(FieldPos("PREV"+StrZero(nX,3)))+aVendas[nY,2]))
			EndIf

			If MV_PAR14 <> 1
				(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),FieldGet(FieldPos("COMP"+StrZero(nX,3)))+aVendas[nY,2]))
			EndIf

		EndIf
		MsUnLock()
		If nX <> 0
			If !lfluxSint  //Fluxo analitico, adiciona natureza no array aFluxAna                                                  
				If cAliasAna == "Zero"
					If Select(cAliasAna) <= 0
						CriaAna(@cAliasAna)
					EndIf
				EndIf
				If Select(cAliasAna) > 0

					If MV_PAR14 == 1 .Or. MV_PAR14 == 2 //Sem comparacao | //Orçado x Previsto
						nPosPrev := 2
					ElseIf MV_PAR14 == 4 //Previsto x Realizado
						nPosPrev := 1
					EndIf
				
					DbSelectArea(cAliasAna)
					RecLock(cAliasAna,.T.)
					(cAliasAna)->ANA_NAT 	:= If(Empty(cDescNat), STR0057, cDescNat)
					(cAliasAna)->ANA_NPOS 	:= StrZero(((nX*3)-3+1)+nPosPrev,3)
					(cAliasAna)->ANA_MOEDA	:= "01"
					(cAliasAna)->ANA_CART	:= "R"
					(cAliasAna)->ANA_DATA	:= aVendas[nY,1]
					(cAliasAna)->ANA_VALOR	:= aVendas[nY,2]
					(cAliasAna)->ANA_TPMOV	:= 'SOMA'
					(cAliasAna)->ANA_ORIGEM	:= 'PV'
					MsUnLock()	
				EndIf
			Endif
		Endif
		//-----------------------------------------------------------		
		// Cria registro no arquivo temporario, para posterior gravacao
		//-----------------------------------------------------------
		Fc022IncTrb(aVendas[nY,3],aVendas[nY,1],aVendas[nY,2],"R",cAliasFIY)
	Endif
Next
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fc022AplRes  ³ Autor ³ Claudio D. de Souza   ³ Data ³ 28/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa as aplicacoes e emprestimos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fc022AplRes(nTipo, dDtIni, dDtFin, cAliasFIY, aFluxo)         ³±±
±±³          ³ nTipo     -> Tipo da consulta (1=Dias, 2=Meses, 3=Semanas     ³±±
±±³          ³ dDtIni    -> Data inicial do periodo da consulta              ³±±
±±³          ³ dDtFin    -> Data final do periodo da consulta                ³±±
±±³          ³ cAliasFIY -> Alias do arquivo temporário utilizado na persist.³±±
±±³          ³ aFluxo    -> Array com o cabecalho e os dados do fluxo 	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  												  	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc022AplRes(nTipo, dDtIni, dDtFin, cAliasFIY, cAliasTRB,aPeriodos)
Local nRecSeh
Local dDtAux := dDtIni
Local cNatResgEp := &(GetMv("MV_NATEMP"))
Local cNatResgAp := &(GetMv("MV_NATAPLI"))
Local cCodNatEmp := ""
Local cCodNatApl := ""
Local nMoeda := 1
Local cPeriodo
Local cAplCotas := GetMv("MV_APLCAL4")
Local nBcoMoeda	:= nil	
Local aCalc     := {}

cNatResgEp := PadR(cNatResgEp,TamSX3("EH_NATUREZ")[1])
cNatResgAp := PadR(cNatResgAp,TamSX3("EH_NATUREZ")[1])

cCodNatEmp := cNatResgEp
cCodNatApl := cNatResgAp	

SED->(DbSetOrder(1))
If !Empty(cCodNatEmp) .And. SED->(MsSeek(xFilial("SED") + cCodNatEmp )) // Posiciona no SED para obter a descricao da natureza
	cNatResgEp  := cCodNatEmp + " - " + SED->ED_DESCRIC	
EndIf

If !Empty(cCodNatApl) .And. SED->(MsSeek(xFilial("SED") + cCodNatApl )) // Posiciona no SED para obter a descricao da natureza
	cNatResgAp := cCodNatApl + " - " + SED->ED_DESCRIC	
EndIf

While dDtAux <= dDtFin
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe Emprestimo a ser resgatado no dia ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SEH")
	dbSetOrder(2)
	dbSeek(xFilial("SEH")+"A",.T.)
	nRecSeh := Recno()
	While ( !Eof() .And. SEH->EH_FILIAL == xFilial("SEH") .And. SEH->EH_STATUS == "A" )

		nBcoMoeda := Posicione("SA6",1,XFILIAL("SA6")+SEH->(EH_BANCO+EH_AGENCIA+EH_CONTA),"A6_MOEDA") 
		nMoeda := If(Empty(nBcoMoeda),nMoeda,nBcoMoeda)

		If SEH->EH_APLEMP == "EMP" .And. SEH->EH_NATUREZ <> cCodNatEmp
			cCodNatEmp := SEH->EH_NATUREZ
			cNatResgEp := SEH->EH_NATUREZ + " - "+ Posicione("SED",1,xFilial("SED")+SEH->EH_NATUREZ,"ED_DESCRIC")
		ElseIf SEH->EH_APLEMP == "APL" .And. SEH->EH_NATUREZ <> cCodNatApl
			cCodNatApl := SEH->EH_NATUREZ
			cNatResgAp := SEH->EH_NATUREZ + " - "+ Posicione("SED",1,xFilial("SED")+SEH->EH_NATUREZ,"ED_DESCRIC")
		Endif 
			
		If mv_par15 .And. SED->ED_MOVBCO <> "1"
			SEH->(dbSkip())
			Loop
		EndIf
		
		If SEH->EH_APLEMP == "EMP" .And. dDtAux >= SEH->EH_DATA .AND. nMoeda == Val(MV_PAR11)
		
			If ( Empty(SEH->EH_DATARES) .And. dDtAux == SEH->EH_DATA) .Or.;
				( SEH->EH_DATARES == dDtAux )
				dA181DtApr := dDtAux
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
				nA181VlDeb  := 0

				aCalculo	  := Fa171Calc(DDATABASE,SEH->EH_SALDO,.F.)
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
				
				Fa181Valor(,"DA181DTAPR") // Atualiza as variaveis PRIVATES do calculo do emprestimo
				nEmprestimo := nA181VlDeb
				//-----------------------------------------------------------
				// Atualiza o arquivo do fluxo
				//-----------------------------------------------------------		
				cPeriodo := Periodo(nTipo, dDtAux, dDtIni, dDtFin)
				DbSelectArea(cAliasTRB)
				DbSetOrder(1)
				If !MsSeek("002"+"P"+cNatResgEp)
					RecLock(cAliasTRB,.T.)
				Else
					RecLock(cAliasTRB)
				EndIf
				(cAliasTRB)->CART := "P"
				(cAliasTRB)->SEQ  := "002"
				(cAliasTRB)->NAT  := cNatResgEp
				
				nX := aScan(aPeriodos,cPeriodo)
				If nX == 0
					nX := 1
				EndIf		
				If nX <> 0
					(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),FieldGet(FieldPos("PREV"+StrZero(nX,3)))+nEmprestimo))

					If MV_PAR14 <> 1
						(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),FieldGet(FieldPos("COMP"+StrZero(nX,3)))+nEmprestimo))
					EndIf
					
				EndIf
				MsUnLock()
				//-----------------------------------------------------------		
				// Cria registro no arquivo temporario, para posterior gravacao
				//-----------------------------------------------------------
				Fc022IncTrb(cCodNatEmp, dDtAux, nEmprestimo, "P", cAliasFIY)
			Endif
		EndIf
		dbSelectArea("SEH")
		dbSkip()
	EndDo                                                                                       
	DbGoTo(nRecSeh) // Para evitar outro SEEK
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe Aplicacoes a serem resgatadas no dia ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While ( !Eof() .And. SEH->EH_FILIAL == xFilial("SEH") .And. SEH->EH_STATUS == "A" )

		nBcoMoeda := Posicione("SA6",1,XFILIAL("SA6")+SEH->(EH_BANCO+EH_AGENCIA+EH_CONTA),"A6_MOEDA") 
		nMoeda := If(Empty(nBcoMoeda),nMoeda,nBcoMoeda)
		
		If SEH->EH_APLEMP == "EMP" .And. SEH->EH_NATUREZ <> cCodNatEmp
			cCodNatEmp := SEH->EH_NATUREZ
			cNatResgEp := SEH->EH_NATUREZ + " - "+ Posicione("SED",1,xFilial("SED")+SEH->EH_NATUREZ,"ED_DESCRIC")
		ElseIf SEH->EH_APLEMP == "APL" .And. SEH->EH_NATUREZ <> cCodNatApl
			cCodNatApl := SEH->EH_NATUREZ
			cNatResgAp := SEH->EH_NATUREZ + " - "+ Posicione("SED",1,xFilial("SED")+SEH->EH_NATUREZ,"ED_DESCRIC")
		Endif 
			
		If mv_par15 .And. SED->ED_MOVBCO <> "1"		
			SEH->(dbSkip())
			Loop
		EndIf 			
		
		If SEH->EH_APLEMP == "APL"  .And. dDtAux >= SEH->EH_DATA .AND. nMoeda == Val(MV_PAR11)
			If (Empty(SEH->EH_DATARES) .And. dDtAux == SEH->EH_DATA) .Or.;
				(SEH->EH_DATARES == dDtAux)
				nAplicacao := SEH->EH_SALDO
			Else
				nAplicacao := 0
			EndIf
			DbSelectArea("SE9")
			DbSetOrder(1)
			DbSeek(xFilial("SE9")+SEH->EH_CONTRAT+SEH->EH_BCOCONT+SEH->EH_AGECONT)
			DbSelectArea("SEH")
			If (Empty(SEH->EH_DATARES) .And. dDtAux == dDtIni) .Or.;
				(SEH->EH_DATARES == dDtAux)		
				If SEH->EH_TIPO $ cAplCotas
					aCalc :=	Fa171Calc(dDtAux)
				Else
					DbSelectArea("SE0")
					If MsSeek(xFilial("SE0")+SE9->(E9_BANCO+E9_AGENCIA+E9_CONTA+E9_NUMERO))
						aCalc	:=	Fa171Calc(dDtAux,SEH->EH_SLDCOTA,,,,SEH->EH_VLRCOTA,SE0->E0_VALOR,(SEH->EH_SLDCOTA * SE0->E0_VALOR))
					Endif	
				EndIf
				
				If Empty(aCalc)
					nAplicacao += 0
				Else
					nAplicacao += (aCalc[5]-aCalc[2]-aCalc[3]-aCalc[4])
				EndIf
			EndIf
			If nAplicacao > 0
				//-----------------------------------------------------------
				// Atualiza o arquivo do fluxo
				//-----------------------------------------------------------		
				cPeriodo := Periodo(nTipo, dDtAux, dDtIni, dDtFin)
				DbSelectArea(cAliasTRB)
				DbSetOrder(1)
				If !MsSeek("002"+"P"+cNatResgAp)
					RecLock(cAliasTRB,.T.)
				Else
					RecLock(cAliasTRB)
				EndIf
				(cAliasTRB)->CART := "P"
				(cAliasTRB)->SEQ  := "002"
				(cAliasTRB)->NAT  := cNatResgAp
				
				nX := aScan(aPeriodos,cPeriodo)
				If nX == 0
					nX := 1
				EndIf		
				If nX <> 0
					(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),FieldGet(FieldPos("PREV"+StrZero(nX,3)))+nAplicacao))

					If MV_PAR14 <> 1
						(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),FieldGet(FieldPos("COMP"+StrZero(nX,3)))+nAplicacao))
					EndIf

				EndIf
				MsUnLock()
				//-----------------------------------------------------------		
				// Cria registro no arquivo temporario, para posterior gravacao
				//-----------------------------------------------------------		
				Fc022IncTrb(cCodNatApl, dDtAux, nAplicacao, "R", cAliasFIY)
			Endif	
		Endif
		dbSelectArea("SEH")
		dbSkip()
	EndDo
	dDtAux ++
EndDo

Return Nil

Static Function Fc022IncTrb(cCodNat, dData, nValor, cCarteira, cAliasFIY)	

	// Cria registro no arquivo temporario, para posterior gravacao, pois quando se processa por filiais deve-se ter o resultado da query 
	// para cada filial
	If !Empty(cAliasFIY)
		RecLock(cAliasFIY,.T.)
		if (cAliasFIY)->(FieldPos("FIV_FILIAL"))> 0
			
			(cAliasFIY)->FIV_FILIAL	:= xFilial("FIV")
			(cAliasFIY)->FIV_NATUR	:= cCodNat
			(cAliasFIY)->FIV_DATA	:= dData
			(cAliasFIY)->FIV_MOEDA	:= "01"
			(cAliasFIY)->FIV_VALOR	:= nValor
			(cAliasFIY)->FIV_TPSALD	:= "2"
			(cAliasFIY)->FIV_CARTEI	:= cCarteira
			
		Elseif (cAliasFIY)->(FieldPos("FJV_FILIAL"))
			
			(cAliasFIY)->FJV_FILIAL	:= xFilial("FJV")
			(cAliasFIY)->FJV_NATUR	:= cCodNat
			(cAliasFIY)->FJV_DATA	:= dData
			(cAliasFIY)->FJV_MOEDA	:= "01"
			(cAliasFIY)->FJV_VALOR	:= nValor
			(cAliasFIY)->FJV_TPSALD	:= "2"
			(cAliasFIY)->FJV_CARTEI	:= cCarteira
			
		EndIf
			
	Endif

Return Nil


Static Function TotalFluxo(cAliasTRB,aPeriodos,aBancos)
Local aArea    := GetArea()
Local aTotPer  := {}
Local nTotPrev := 0
Local nTotReal := 0
Local nTotOrc  := 0
Local nTotComp := 0
Local nX       := 0
Local nSeq     := 0
Local lDecstPrv := SuperGetMv("MV_FLXPRVD",.T.,.F.) //117021	
Local lVisaoGer := lfluxSint .AND. !Empty(MV_PAR16) 
Local cOrdemVis := ""
Local cNatPis	:= AllTrim( SuperGetMV("MV_PISNAT",,"PIS") )
Local cNatSes	:= AllTrim( SuperGetMV("MV_SEST",,"SEST") )
Local cNatIss	:= AllTrim( SuperGetMV("MV_APURISS",,"ISS") )
Local cNatCof	:= AllTrim( SuperGetMV("MV_COFINS",,"COFINS") )
Local cNatCsl	:= AllTrim( SuperGetMV("MV_CSLL",,"CSLL") )
Local cNatIns	:= AllTrim( StrTran(SuperGetMV("MV_INSS",,"INSS"), '"', "") )
Local cNatIrf	:= AllTrim( StrTran(SuperGetMV("MV_IRF",,"IRF"), '"', "") )
	
Default aBancos := {}
//-----------------------------------------------------------
// Cria o Array de Totais por Carteira x Periodo
//-----------------------------------------------------------
aadd(aTotPer,Array(Len(aPeriodos)))
aadd(aTotPer,Array(Len(aPeriodos)))
aadd(aTotPer,Array(Len(aPeriodos)))
aadd(aTotPer,Array(Len(aPeriodos)))
For nX := 1 To Len(aPeriodos)     
	aTotPer[1][nX] := {0,0,0,0} //Entradas
	aTotPer[2][nX] := {0,0,0,0} //Saídas
	aTotPer[3][nX] := {0,0,0,0} //Saldo Inicial
	aTotPer[4][nX] := {0,0,0,0} //Saldo Final
Next nX
//-----------------------------------------------------------
// Totaliza as colunas
//-----------------------------------------------------------
dbSelectArea(cAliasTRB)
(cAliasTRB)->( dbGotop() )

While (cAliasTRB)->( !Eof() )
	nTotPrev := 0
	nTotReal := 0
	nTotOrc  := 0
	nTotComp := 0

	For nX := 1 To Len(aPeriodos)
		If MV_PAR14 == 1 //Nenhum
			nTotOrc  += (cAliasTRB)->(FieldGet(FieldPos("ORC"+StrZero(nX,3))))	
			nTotPrev += (cAliasTRB)->(FieldGet(FieldPos("PREV"+StrZero(nX,3))))
			nTotReal += (cAliasTRB)->(FieldGet(FieldPos("REAL"+StrZero(nX,3))))
		ElseIf MV_PAR14 == 2 //Orcado X Previsto
			nTotOrc  += (cAliasTRB)->(FieldGet(FieldPos("ORC"+StrZero(nX,3))))	
			nTotPrev += (cAliasTRB)->(FieldGet(FieldPos("PREV"+StrZero(nX,3))))
		ElseIf MV_PAR14 == 3 //Orcado X Realizado		
			nTotOrc  += (cAliasTRB)->(FieldGet(FieldPos("ORC"+StrZero(nX,3))))	
			nTotReal += (cAliasTRB)->(FieldGet(FieldPos("REAL"+StrZero(nX,3))))
		ElseIf MV_PAR14 == 4 //Previsto X Realizado
			nTotPrev += (cAliasTRB)->(FieldGet(FieldPos("PREV"+StrZero(nX,3))))
			nTotReal += (cAliasTRB)->(FieldGet(FieldPos("REAL"+StrZero(nX,3))))
		EndIf
		
		If (cAliasTRB)->SEQ == "001"
			nSeq := 1
		ElseIf (cAliasTRB)->SEQ == "002"
			nSeq := 2
		ElseIf (cAliasTRB)->SEQ == "000"
			nSeq := 3
		ElseIf (cAliasTRB)->SEQ == "VIS"
			If (cAliasTRB)->CART == "R"
				nSeq := 1
			ElseIf (cAliasTRB)->CART == "P"
				nSeq := 2
			Else
				Loop
			Endif
		EndIf
			
		If MV_PAR14 == 1 //Nenhum
			aTotPer[nSeq][nX][1] += (cAliasTRB)->(FieldGet(FieldPos("ORC" +StrZero(nX,3))))
			aTotPer[nSeq][nX][2] += (cAliasTRB)->(FieldGet(FieldPos("PREV"+StrZero(nX,3))))
			aTotPer[nSeq][nX][3] += Iif( AllTrim( (cAliasTRB)->CODNAT ) $ ' "' + cNatPis + "|" + ;
				cNatSes + "|" + cNatIss + "|" + cNatCof + "|" + cNatCsl + "|" + cNatIns + "|" + cNatIrf + '" ';
				.And. (cAliasTRB)->CART == 'R', 0, (cAliasTRB)->(FieldGet(FieldPos("REAL"+StrZero(nX,3)))) )
		ElseIf MV_PAR14 == 2 //Orcado X Previsto
			aTotPer[nSeq][nX][1] += (cAliasTRB)->(FieldGet(FieldPos("ORC" +StrZero(nX,3))))
			aTotPer[nSeq][nX][2] += (cAliasTRB)->(FieldGet(FieldPos("PREV"+StrZero(nX,3))))
			aTotPer[nSeq][nX][4] += ((cAliasTRB)->(FieldGet(FieldPos("PREV"+StrZero(nX,3))))-(cAliasTRB)->(FieldGet(FieldPos("ORC"+StrZero(nX,3)))))
		ElseIf MV_PAR14 == 3 //Orcado X Realizado				
			aTotPer[nSeq][nX][1] += (cAliasTRB)->(FieldGet(FieldPos("ORC" +StrZero(nX,3))))
			aTotPer[nSeq][nX][3] += Iif( AllTrim( (cAliasTRB)->CODNAT ) $ ' "' + cNatPis + "|" + ;
				cNatSes + "|" + cNatIss + "|" + cNatCof + "|" + cNatCsl + "|" + cNatIns + "|" + cNatIrf + '" ';
				.And. (cAliasTRB)->CART == 'R', 0, (cAliasTRB)->(FieldGet(FieldPos("REAL"+StrZero(nX,3)))) )
			aTotPer[nSeq][nX][4] += (Iif( AllTrim( (cAliasTRB)->CODNAT ) $ ' "' + cNatPis + "|" + ;
				cNatSes + "|" + cNatIss + "|" + cNatCof + "|" + cNatCsl + "|" + cNatIns + "|" + cNatIrf + '" ';
				.And. (cAliasTRB)->CART == 'R', 0, (cAliasTRB)->(FieldGet(FieldPos("REAL"+StrZero(nX,3)))) )-(cAliasTRB)->(FieldGet(FieldPos("ORC"+StrZero(nX,3)))))
		ElseIf MV_PAR14 == 4 //Previsto X Realizado
			aTotPer[nSeq][nX][2] += (cAliasTRB)->(FieldGet(FieldPos("PREV"+StrZero(nX,3))))
			aTotPer[nSeq][nX][3] += Iif( AllTrim( (cAliasTRB)->CODNAT ) $ ' "' + cNatPis + "|" + ;
				cNatSes + "|" + cNatIss + "|" + cNatCof + "|" + cNatCsl + "|" + cNatIns + "|" + cNatIrf + '" ';
				.And. (cAliasTRB)->CART == 'R', 0, (cAliasTRB)->(FieldGet(FieldPos("REAL"+StrZero(nX,3)))) )
			aTotPer[nSeq][nX][4] += ((cAliasTRB)->(FieldGet(FieldPos("PREV"+StrZero(nX,3))))-Iif( AllTrim( (cAliasTRB)->CODNAT ) $ ' "' + cNatPis + "|" + ;
				cNatSes + "|" + cNatIss + "|" + cNatCof + "|" + cNatCsl + "|" + cNatIns + "|" + cNatIrf + '" ';
				.And. (cAliasTRB)->CART == 'R', 0, (cAliasTRB)->(FieldGet(FieldPos("REAL"+StrZero(nX,3)))) ) )
		EndIf

	Next nX
	
	If lDecstPrv //117021
		nTotPrev -= IIf(nTotPrev < 0 .AND. nTotReal < 0, nTotReal,;                    //117021 //117824
                   IIf(nTotPrev >= nTotReal, nTotReal,;                               //117824
                   IIf(nTotPrev > 0 .AND. nTotReal > nTotPrev, nTotPrev,nTotReal)))   //117824
	EndIf //117021

	If MV_PAR14 == 2 //Orcado X Previsto
		nTotComp += (nTotPrev-nTotOrc)
	ElseIf MV_PAR14 == 3//Orcado X Realizado
		nTotComp += (nTotReal-nTotOrc)
	ElseIf MV_PAR14 == 4//Previsto X Realizado
		nTotComp += (nTotPrev-nTotReal)
	EndIf			  
	
	RecLock(cAliasTRB)
	If MV_PAR14 == 1 //Nenhum
		(cAliasTRB)->(FieldPut(FieldPos("ORCTOT"),nTotOrc))
		(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),nTotPrev))
		(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),nTotReal))
	ElseIf MV_PAR14 == 2 //Orcado X Previsto
		(cAliasTRB)->(FieldPut(FieldPos("ORCTOT"),nTotOrc))
		(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),nTotPrev))
		(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"),nTotComp))
	ElseIf MV_PAR14 == 3 //Orcado X Realizado
		(cAliasTRB)->(FieldPut(FieldPos("ORCTOT"),nTotOrc))
		(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),nTotReal))
		(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"),nTotComp))
	ElseIf MV_PAR14 == 4 //Previsto X Realizado									
		(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),nTotPrev))
		(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),nTotReal))
		(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"),nTotComp))
	EndIf
						
	(cAliasTRB)->( dbSkip() )
EndDo

If !lVisaoGer
	//-----------------------------------------------------------
	// Totaliza das entradas
	//-----------------------------------------------------------
	nTotPrev := 0
	nTotReal := 0
	nTotOrc  := 0	
	nTotComp := 0	
	RecLock(cAliasTRB,.T.)
	(cAliasTRB)->SEQ  := "001"
	(cAliasTRB)->CART := "Z"
	(cAliasTRB)->NAT  := STR0041+STR0042 //"Totais de "###"Entradas"
	
	For nX := 1 To Len(aTotPer[1])
	
		nTotOrc  += aTotPer[1][nX][1]
		nTotReal += aTotPer[1][nX][3]
		
		If lDecstPrv 
			nTotPrev+= IIf(aTotPer[1][nX][2] > 0, aTotPer[1][nX][2]-aTotPer[1][nX][3],aTotPer[1][nX][2])
		Else
			nTotPrev += aTotPer[1][nX][2]
		Endif 
		nTotComp += aTotPer[1][nX][4]
		
		If MV_PAR14 == 1 //Nenhum
			(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[1][nX][1]))
			(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[1][nX][2]))
			(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[1][nX][3]))
		
			(cAliasTRB)->(FieldPut(FieldPos("ORCTOT"),nTotOrc))
			(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),nTotPrev))
			(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),nTotReal))
		ElseIf MV_PAR14 == 2 //Orcado X Previsto
			(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[1][nX][1]))
			(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[1][nX][2]))
			(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[1][nX][4]))
			
			(cAliasTRB)->(FieldPut(FieldPos("ORCTOT"),nTotOrc))
			(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),nTotPrev))
			(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"),nTotComp))			
		ElseIf MV_PAR14 == 3 //Orcado X Realizado
			(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[1][nX][1]))
			(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[1][nX][3]))
			(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[1][nX][4]))
			
			(cAliasTRB)->(FieldPut(FieldPos("ORCTOT"),nTotOrc))
			(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),nTotReal))
			(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"),nTotComp))			
		ElseIf MV_PAR14 == 4 //Previsto X Realizado
			(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[1][nX][2]))
			(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[1][nX][3]))
			(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[1][nX][4]))
	
			(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),nTotPrev))
			(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),nTotReal))
			(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"),nTotComp))						
		EndIf
	
	Next nX
	
	(cAliasTRB)->( MsUnLock() )
	
	//-----------------------------------------------------------
	// Totaliza das saídas
	//-----------------------------------------------------------
	nTotPrev := 0
	nTotReal := 0
	nTotOrc  := 0
	nTotComp := 0
	RecLock(cAliasTRB,.T.)
	(cAliasTRB)->SEQ  := "002"
	(cAliasTRB)->CART := "Z"
	(cAliasTRB)->NAT  := STR0041+STR0043 	//"Totais de "###"Saídas"
	
	For nX := 1 To Len(aTotPer[2])
	
		nTotOrc  += aTotPer[2][nX][1]
		nTotReal += aTotPer[2][nX][3]
	
		If lDecstPrv 
			nTotPrev+= IIf(aTotPer[2][nX][2] > 0, aTotPer[2][nX][2]-aTotPer[2][nX][3],aTotPer[2][nX][2])
		Else		
			nTotPrev += aTotPer[2][nX][2]
		Endif
		nTotComp += aTotPer[2][nX][4]
	
		If MV_PAR14 == 1 //Nenhum			
			(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[2][nX][1]))
			(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[2][nX][2]))
			(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[2][nX][3]))
			
			//Totais		
			(cAliasTRB)->(FieldPut(FieldPos("ORCTOT"),nTotOrc))
			(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),nTotPrev))
			(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),nTotReal))
		ElseIf MV_PAR14 == 2 //Orcado X Previsto		
			(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[2][nX][1]))
			(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[2][nX][2]))
			(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[2][nX][4]))	
	
			//Totais		
			(cAliasTRB)->(FieldPut(FieldPos("ORCTOT"),nTotOrc))
			(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),nTotPrev))
			(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"),nTotComp))
		ElseIf MV_PAR14 == 3 //Orcado X Realizado
			(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[2][nX][1]))
			(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[2][nX][3]))
			(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[2][nX][4]))
	
			//Totais		
			(cAliasTRB)->(FieldPut(FieldPos("ORCTOT"),nTotOrc))
			(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),nTotReal))
			(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"),nTotComp))
		ElseIf MV_PAR14 == 4//Previsto X Realizado
			(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[2][nX][2]))
			(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[2][nX][3]))
			(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[2][nX][4]))
	
			//Totais
			(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),nTotPrev))
			(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),nTotReal))
			(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"),nTotComp))
		EndIf
	Next nX
	
	(cAliasTRB)->( MsUnLock() )
	
	//-----------------------------------------------------------
	// Saldo operacional
	//-----------------------------------------------------------
	nTotPrev := 0
	nTotReal := 0
	nTotOrc  := 0	
	nTotComp := 0	
	RecLock(cAliasTRB,.T.)
	(cAliasTRB)->SEQ  := "900"
	(cAliasTRB)->CART := "Z"
	(cAliasTRB)->NAT  := STR0044 //"Saldo Operacional"
	
	For nX := 1 To Len(aPeriodos)
	
		nTotOrc  += aTotPer[1][nX][1]-aTotPer[2][nX][1]
		nTotPrev += aTotPer[1][nX][2]-aTotPer[2][nX][2]
		nTotReal += aTotPer[1][nX][3]-aTotPer[2][nX][3]
		nTotComp += aTotPer[1][nX][4]-aTotPer[2][nX][4]
		
		If MV_PAR14 == 1 //Nenhum
			(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[1][nX][1]-aTotPer[2][nX][1]))
			(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[1][nX][2]-aTotPer[2][nX][2]))
			(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[1][nX][3]-aTotPer[2][nX][3]))
	
			//Totais		
			(cAliasTRB)->(FieldPut(FieldPos("ORCTOT"),nTotOrc))
			(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),nTotPrev))
			(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),nTotReal))
		ElseIf MV_PAR14 == 2 //Orcado X Previsto
			(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[1][nX][1]-aTotPer[2][nX][1]))
			(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[1][nX][2]-aTotPer[2][nX][2]))
			(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[1][nX][4]-aTotPer[2][nX][4]))		
		
			//Totais		
			(cAliasTRB)->(FieldPut(FieldPos("ORCTOT"),nTotOrc))
			(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),nTotPrev))
			(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"),nTotComp))
		ElseIf MV_PAR14 == 3 //Orcado X Realizado
			(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[1][nX][1]-aTotPer[2][nX][1]))
			(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[1][nX][3]-aTotPer[2][nX][3]))
			(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[1][nX][4]-aTotPer[2][nX][4]))
	
			//Totais		
			(cAliasTRB)->(FieldPut(FieldPos("ORCTOT"),nTotOrc))
			(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),nTotReal))			
			(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"),nTotComp))
		ElseIf MV_PAR14 == 4 //Previsto X Realizado
			(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[1][nX][2]-aTotPer[2][nX][2]))
			(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[1][nX][3]-aTotPer[2][nX][3]))
			(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[1][nX][4]-aTotPer[2][nX][4]))
	
			//Totais		
			(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),nTotPrev))
			(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),nTotReal))
			(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"),nTotComp))
		EndIf
	
	Next nX
	
	(cAliasTRB)->( MsUnLock() )
Endif

//-----------------------------------------------------------    
// Saldo Final e Inicial
//-----------------------------------------------------------
nTotPrev := 0
nTotReal := 0
nTotOrc  := 0	
nTotComp := 0	
If !lVisaoGer
	RecLock(cAliasTRB,.T.)
	(cAliasTRB)->SEQ  := "999"
	(cAliasTRB)->CART := "Z"
	(cAliasTRB)->NAT  := STR0045 //"Saldo Final"
Endif

For nX := 1 To Len(aPeriodos)

	If nX == 1
		aTotPer[4][nX][1] += aTotPer[3][nX][1] + aTotPer[1][nX][1] - aTotPer[2][nX][1]
		aTotPer[4][nX][2] += aTotPer[3][nX][2] + aTotPer[1][nX][2] - aTotPer[2][nX][2]
		aTotPer[4][nX][3] += aTotPer[3][nX][3] + aTotPer[1][nX][3] - aTotPer[2][nX][3]
		aTotPer[4][nX][4] += aTotPer[3][nX][4] + aTotPer[1][nX][4] - aTotPer[2][nX][4]	   		
	Else
		If Len(aBancos) > 0 //Soma a linha de saldo inicial apenas se tiver algum banco selecionado
			aTotPer[3][nX][1] := aTotPer[4][nX-1][1]
			aTotPer[3][nX][2] := aTotPer[4][nX-1][2]
			aTotPer[3][nX][3] := aTotPer[4][nX-1][3]
			aTotPer[3][nX][4] := aTotPer[4][nX-1][4]
		EndIf
		aTotPer[4][nX][1] += aTotPer[3][nX][1] + aTotPer[1][nX][1] - aTotPer[2][nX][1]
		aTotPer[4][nX][2] += aTotPer[3][nX][2] + aTotPer[1][nX][2] - aTotPer[2][nX][2]
		aTotPer[4][nX][3] += aTotPer[3][nX][3] + aTotPer[1][nX][3] - aTotPer[2][nX][3]
		aTotPer[4][nX][4] += aTotPer[3][nX][4] + aTotPer[1][nX][4] - aTotPer[2][nX][4]
	EndIf
	
	If !lVisaoGer
		If MV_PAR14 == 1 //Nenhum
			(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[4][nX][1]))
			(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[4][nX][2]))
			(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[4][nX][3]))
		ElseIf MV_PAR14 == 2 //Orcado X Previsto
			(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[4][nX][1]))
			(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[4][nX][2]))
			(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[4][nX][4]))
		ElseIf MV_PAR14 == 3 //Orcado X Realizado
			(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[4][nX][1]))
			(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[4][nX][3]))
			(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[4][nX][4]))
		ElseIf MV_PAR14 == 4 //Previsto X Realizado
			(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[4][nX][2]))
			(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[4][nX][3]))
			(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[4][nX][4]))
		EndIf
	Endif
Next nX

If !lVisaoGer
	If MV_PAR14 == 1 //Nenhum
		(cAliasTRB)->(FieldPut(FieldPos("ORCTOT" ),aTotPer[4][Len(aPeriodos)][1]))
		(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),aTotPer[4][Len(aPeriodos)][2]))
		(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),aTotPer[4][Len(aPeriodos)][3]))
	ElseIf MV_PAR14 == 2 //Orcado X Previsto
		(cAliasTRB)->(FieldPut(FieldPos("ORCTOT" ),aTotPer[4][Len(aPeriodos)][1]))
		(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),aTotPer[4][Len(aPeriodos)][2]))
		(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"),aTotPer[4][Len(aPeriodos)][4]))
	ElseIf MV_PAR14 == 3 //Orcado X Realizado
		(cAliasTRB)->(FieldPut(FieldPos("ORCTOT" ),aTotPer[4][Len(aPeriodos)][1]))
		(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),aTotPer[4][Len(aPeriodos)][3]))
		(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"),aTotPer[4][Len(aPeriodos)][4]))
	ElseIf MV_PAR14 == 4 //Previsto X Realizado
		(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),aTotPer[4][Len(aPeriodos)][2]))
		(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),aTotPer[4][Len(aPeriodos)][3]))
		(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"),aTotPer[4][Len(aPeriodos)][4]))
	EndIf
	
	(cAliasTRB)->( MsUnLock() )
Endif

//-----------------------------------------------------------
// Saldo Inicial
//-----------------------------------------------------------
cOrdemVis := Iif( lVisaoGer, Space( __nTamOrdV ), "" )
If DbSeek(cOrdemVis+"000"+"Z"+STR0021)
	RecLock(cAliasTRB)
Else
	RecLock(cAliasTRB,.t.)
	(cAliasTRB)->SEQ := "000"
	(cAliasTRB)->CART:= "Z"
	(cAliasTRB)->NAT := STR0021 //"Saldos iniciais"
EndIf
If Len(aBancos) > 0 
	For nX := 1 To Len(aTotPer[3])
		If MV_PAR14 == 1 //Nenhum
			If nx==1
				(cAliasTRB)->(FieldPut(FieldPos("ORCTOT" +StrZero(nX,3)),aTotPer[3][nX][1]))
				(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"+StrZero(nX,3)),aTotPer[3][nX][2]))
				(cAliasTRB)->(FieldPut(FieldPos("REALTOT"+StrZero(nX,3)),aTotPer[3][nX][3]))
				(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[3][nX][1]))
				(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[3][nX][2]))
				(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[3][nX][3]))
			Else	
				(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[3][nX][1]))
				(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[3][nX][2]))
				(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[3][nX][3]))
			EndIf

		ElseIf MV_PAR14 == 2 //Orcado X Previsto
			If nx==1
				(cAliasTRB)->(FieldPut(FieldPos("ORCTOT" +StrZero(nX,3)),aTotPer[3][nX][1]))
				(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"+StrZero(nX,3)),aTotPer[3][nX][2]))
				(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"+StrZero(nX,3)),aTotPer[3][nX][4]))

				(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[3][nX][1]))
				(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[3][nX][2]))
				(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[3][nX][4]))
			Else
				(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[3][nX][1]))
				(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[3][nX][2]))
				(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[3][nX][4]))
			EndIf

		ElseIf MV_PAR14 == 3 //Orcado X Realizado

			If nx==1
				(cAliasTRB)->(FieldPut(FieldPos("ORCTOT" +StrZero(nX,3)),aTotPer[3][nX][1]))
				(cAliasTRB)->(FieldPut(FieldPos("REALTOT"+StrZero(nX,3)),aTotPer[3][nX][3]))
				(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"+StrZero(nX,3)),aTotPer[3][nX][4]))

				(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[3][nX][1]))
				(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[3][nX][3]))
				(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[3][nX][4]))
			Else
				(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[3][nX][1]))
				(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[3][nX][3]))
				(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[3][nX][4]))
			EndIf	
		ElseIf MV_PAR14 == 4 //Previsto X Realizado
			If nx==1
				(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"+StrZero(nX,3)),aTotPer[3][nX][2]))
				(cAliasTRB)->(FieldPut(FieldPos("COMPTOT"+StrZero(nX,3)),aTotPer[3][nX][4]))
				(cAliasTRB)->(FieldPut(FieldPos("REALTOT"+StrZero(nX,3)),aTotPer[3][nX][3]))

				(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[3][nX][2]))
				(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[3][nX][3]))
				(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[3][nX][4]))

			Else
				(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[3][nX][2]))
				(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[3][nX][3]))
				(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),aTotPer[3][nX][4]))
			EndIf            
		EndIf

	Next nX
EndIF	

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINR770   ºAutor  ³Microsiga           º Data ³  08/18/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula saldo com base na formula digitada                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CalcForVS (aVisao, cAliasTRB,aPeriodos)
Local cSuperior
Local cIdenti
Local nCont
Local nFator
Local nX, nA
Local nLen := Len(aPeriodos)  

For nX:= 1 to Len(aVisao)
	
	cSuperior := aVisao[nX][(nLen*4)+5] // Conta Superior
	cIdenti	  := aVisao[nX][(nLen*4)+11] // Somar ou Subtrair
	nCont     := Len(aVisao)

	//Procurar nas superiores e somar ou subtrair
	If(!Empty(cSuperior))   

		//Ralizar calculo com a formula digitada pelo usuario
		If (Left(aVisao[nX][(nLen*4)+16], 7) == "ROTINA=") //FORMULA
			nFator := &(Subs(aVisao[nX][(nLen*4)+16], 8)) 

			For nA := 1 to (nLen*4)   
		   		aVisao[nX][nA] *= nFator
			Next nA
			

		ElseIf Left(aVisao[nX][(nLen*4)+16], 6) == "FATOR="
			nFator := &(Subs(aVisao[nX][(nLen*4)+16], 7))

			For nA := 1 to (nLen*4)   
		   		aVisao[nX][nA] *= nFator
			Next nA

		Elseif Left(aVisao[nX][(nLen*4)+16],6 ) == "SALDO="		
			nFator := &(Subs(aVisao[nX][(nLen*4)+16], 7))
			
			For nA := 1 to (nLen*4)   
				aVisao[nX][nA] := nFator
			Next nA

		EndIf	 		

	Endif
Next

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fc022Nota    ³ Autor ³ FSW				   ³ Data ³ 04/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava as Notas Explicativas que serao impressas no relatorio  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fc022Nota() 													 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  												  	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc022Nota()

Local oDlg := Nil

DEFINE MSDIALOG oDlg TITLE "Nota Explicativa" FROM 0,0 TO 400,690 OF oDlg PIXEL

@ 06, 10 GET oMemo Var cNota MEMO Size 325,165 PIXEL OF oDlg
@ 180,260 BUTTON "&Ok"       SIZE 36,16 PIXEL ACTION oDlg:End()
@ 180,300 BUTTON "&Cancelar" SIZE 36,16 PIXEL ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTER

Return Nil            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CarregaNota  ³ Autor ³ FSW				   ³ Data ³ 05/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega a nota expecifica para impressao						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CarregaNota(cCount, cCodFlx)                                  ³±±
±±³          ³ cCount  -> Codigo do contador                                 ³±±
±±³          ³ cCodFlx -> Codigo da consulta                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  												     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CarregaNota(cCount,cCodFlx)

FIX->(MsSeek(xFilial("FIX")+cCodFlx))

IF cCount == 1
	cNota	:= FIX->FIX_OBS1
Else
	cNota2	:= FIX->FIX_OBS1
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³MostraFlAn³ Autor ³ Alessandro Afonso     ³ Data ³ 29/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra fluxo analitico por natureza.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ MostraFlAn                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  											 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MostraFlAn(dDtIni, dDtFin, cAliasAna, cAliasTRB )

Local aSize
Local aObjects		:= {}
Local aInfo
Local aHeader		:= {}
Local oDlg1
Local nOpca
Local nX			:= 0
Local aFluxo2		:= {} 
Local nPos			:= StrZero(oFluxo:ColPos(),3)

// Adiciona no array aFluxo2, todas os valores que pertencem a natureza posicionada e coluna posicionada.
If Select(cAliasAna) > 0
	dbSelectArea(cAliasAna)
	DbSetOrder(1)

	If MsSeek(SubStr((cAliasTRB)->NAT,1,Len(FJV->FJV_NATUR))+nPos+(cAliasTRB)->CART)

		While !Eof() .And. SubStr((cAliasTRB)->NAT,1,Len(FJV->FJV_NATUR)) == (cAliasAna)->ANA_NAT  .And. nPos == (cAliasAna)->ANA_NPOS .And. (cAliasTRB)->CART == (cAliasAna)->ANA_CART

			Aadd(aFluxo2, {(cAliasTRB)->NAT,;
			(cAliasAna)->ANA_MOEDA,;
			(cAliasAna)->ANA_CART,;	
			(cAliasAna)->ANA_DATA,;	
			(cAliasAna)->ANA_VALOR,;
			(cAliasAna)->ANA_TPMOV,;
			(cAliasAna)->ANA_ORIGEM	})

		(cAliasAna)->(DBSkip())
		EndDo

	EndIf
EndIf	
// Se for selecionado linha de saldos ou totais sai da rotina.
If Len(aFluxo2)  == 0 
	Return Nil
ElseIf Len(aFluxo2)  == 0
	aAdd(aFluxo2, {"","","","","","",""} )
Endif
//Campos de cabecalho
aAdd(aHeader, STR0031 )  // Natureza
aAdd(aHeader, STR0059 )  // Moeda
aAdd(aHeader, STR0091 )  // Carteira
aAdd(aHeader, STR0092 )  // Data
aAdd(aHeader, STR0093 )  // Valor
aAdd(aHeader, STR0052 )  // Movimento
aAdd(aHeader, STR0094 )  // Origem Movimento

aButton := { { "Salvar", { || Fc022Leg()  }, STR0090,STR0090 }} //"Legenda"###"Legenda"					

aSize := MsAdvSize()
aadd( aObjects, {  30,  70, .T., .T.} )
aadd( aObjects, {  20, 180, .T., .T., .T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg1 TITLE STR0081 + Dtoc(dDtIni) + STR0040 + Dtoc(dDtFin)  FROM aSize[7],0 TO aSize[6] - 300,aSize[5]  PIXEL OF oMainWnd //"Fluxo de Caixa" //"Fluxo de Caixa" //" em " //"Fluxo de Caixa por natureza periodo de "###" a "

    oDlg1:lMaximized := .F.   

	DEFINE FWBROWSE oFluxAn DATA ARRAY ARRAY aFluxo2 LINE BEGIN 1 OF oDlg1 

	For nX := 1 To Len(aHeader)  
		cColuna := Alltrim(Str(nX))
		ADD COLUMN oColumn DATA &('{ || Transform('+If(nX==1,'SubStr(','')+'aFluxo2[oFluxAn:At(),' + cColuna + ']'+If(nX==1,',1)','')+','+If(nX==5,'"@e 999,999,999,999.99"','""')+') }') TITLE aHeader[nX] SIZE If(nX==1,25,15) ALIGN If(nX==1,1,2) HEADERCLICK { || } DOUBLECLICK { || } OF oFluxAn
	Next

	oFluxAn:DisableReport()

	ACTIVATE FWBROWSE oFluxAn

ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar( oDlg1, {|| nOpca := 1, oDlg1:End()}, {|| nOpca := 2, oDlg1:End()},, aButton)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³MonFlxAn     ³ Autor ³ Alessandro Afonso     ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega fluxo analitico                  					 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ cFilOld -> cFilAnt                                            ³±±
±±³          ³                                                               ³±±
±±³          ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  												     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MonFlxAn( cFilOld , lGravada, nLoop, cCodFlx, cCodFlxCmp, aParam, aPerguntas  )
Local nCount		:= 1
Local nX			:= 1
Local cAliasTrb
Local cAliasTrb2 
Local cAliasAna		:= "Zero"
Local lRet 			:= .T.
Local aPeriodos		:= {}
Local aPeriodos2	:= {}
Local aSelFil       := {}
Local cAliasFIY	
Local lConsFil		:= .F.
Local nBancos		:= 0
Local nCaixas		:= 0
Local aBancos		:= {}
Local lLimCred		:= .T.

If cCodFlxCmp # Nil
	nLoop := 2
EndIf

//-----------------------------------------------------------
// Caso o compartilhamento de tabelas não seja Exclusivo, inibe a seleção de filiais na Consulta do Fluxo de Caixa
//-----------------------------------------------------------
If lGravada .Or. (VldPerFlx() .AND. VldData())
	For nCount := 1 To nLoop
		//-----------------------------------------------------------
		// Se for uma consulta gravada
		//-----------------------------------------------------------
		If lGravada
			CarregaParam(If(nCount==1,cCodFlx, cCodFlxCmp))
			CarregaNota(nCount,If(nCount==1,cCodFlx, cCodFlxCmp)) 
		EndIf
		//-----------------------------------------------------------
		// Calcula o numero de periodos do fluxo de caixa
		//-----------------------------------------------------------
		If nCount == 1
			MontaPeriodo(MV_PAR03, MV_PAR04, MV_PAR05,@cAliasTRB,@aPeriodos)
		Else
			MontaPeriodo(MV_PAR03, MV_PAR04, MV_PAR05,@cAliasTRB2,@aPeriodos2)
		EndIf 

		If !lGravada .And. IIf(ValType(MV_PAR12) == "N",MV_PAR12 == 1,.F.)  // Considera filiais
			aSelFil := AdmGetFil()
			lConsFil := .T.
			If Empty(aSelFil)
				lRet := .F.
			EndIf
		Else
			aSelFil :=  {cFilAnt}
		EndIf
		// Seleciona os Bancos
		If lRet .And. IIf(ValType(MV_PAR09) == "L",MV_PAR09,.F.) //Considera Saldos Bancarios
			aBancos := Bancos( lConsFil, 1, @nBancos, @nCaixas,aSelFil,Str(MV_PAR10,1),.F.,aBancos,@lLimCred)
        EndIf
		If lRet
			If lGravada .Or. Len(aSelFil) > 0 
				If !lGravada .And. (Len(aSelFil) > 0 .Or. MV_PAR06 .Or. MV_PAR07)
					//-------------------------------------------
					// Define estrutura da tabela temporária
					//-------------------------------------------				
					If _oFINC0222 <> Nil
						_oFINC0222:Delete()
						_oFINC0222 := Nil
					Endif
					
					cAliasFIY := GetNextAlias()
					
					_oFINC0222 := FWTemporaryTable():New( cAliasFIY )  
					_oFINC0222:SetFields(FJV->(DbStruct())) 	
					_oFINC0222:AddIndex("1", {"FJV_FILIAL","FJV_NATUR","FJV_MOEDA","FJV_TPSALD","FJV_CARTEI","FJV_DATA"}) 
										
					//------------------
					//Criação da tabela temporaria
					//------------------
					_oFINC0222:Create()	
				EndIf	
				//-------------------------------------------
				// Processa o fluxo de caixa por filial selecionada.
				//-------------------------------------------
				For nX := 1 To Len(aSelFil)
					//-------------------------------------------
					// Troca a filial corrente para a filial de processamento
					//-------------------------------------------
					cFilAnt := aSelFil[nX]
					//-------------------------------------------
					// Processa os pedidos de compra
					//-------------------------------------------
					If !lGravada .And. MV_PAR07 .And. MV_PAR14 <> 3
						If nX == 1 .Or. FWModeAccess("SC7") == "E"
							Processa( { |lEnd| Fc022Compr(MV_PAR05,MV_PAR03,MV_PAR04,cAliasFIY,cAliasTRB,aPeriodos,@cAliasAna,aSelFil) }, STR0022 ) //"Processando pedidos de compra"
						EndIf
					EndIf
					//-------------------------------------------
					// Processa os pedidos de venda
					//-------------------------------------------
					If !lGravada .And. mv_par06 .And. MV_PAR14 <> 3
						If nX == 1 .Or. FWModeAccess("SC5") == "E"
							Processa( { |lEnd| Fc022Venda(MV_PAR05, MV_PAR03, MV_PAR04, cAliasFIY,cAliasTRB,aPeriodos,@cAliasAna,aSelFil) }, STR0023 ) //"Processando pedidos de venda"
						EndIf
					EndIf          
					//-------------------------------------------
					// Processa aplicações e emprestimos
					//-------------------------------------------
					If !lGravada .And. mv_par08 .And. MV_PAR14 <> 3
						If nX == 1 .Or. FWModeAccess("SEH") == "E"
							Processa( { |lEnd| Fc022AplRes(MV_PAR05, MV_PAR03, MV_PAR04, cAliasFIY,cAliasTRB,aPeriodos) }, STR0024 ) //"Processando Aplicações/Empréstimos"
						EndIf	
					EndIf

					If nX == 1 .Or. FWModeAccess("FIY") == "E"
						If nLoop == 2
							Processa( {|lEnd| FlCxNatAna(lEnd,MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, cAliasFIY, lGravada, If(nCount==1,cCodFlx, cCodFlxCmp), MV_PAR11,IIf(nCount==1,cAliasTRB,cAliasTRB2),IIf(nCount==1,aPeriodos,aPeriodos2),.T.,@cAliasAna) }, STR0026 ) //"Lendo saldos das naturezas"
						Else
							Processa( {|lEnd| FlCxNatAna(lEnd,MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,@cAliasFIY,lGravada,cCodFlx,MV_PAR11,cAliasTRB,aPeriodos,MV_PAR15,@cAliasAna),STR0026 } ) //"Lendo saldos das naturezas"
						EndIf	
					EndIf
				Next nx   
				// Processa Saldos Iniciais
				If MV_PAR09 .And. Len(aBancos) > 0 
					Processa( { |lEnd| SaldosInicias(MV_PAR05,MV_PAR03-1,Str(MV_PAR10,1),IIf(nCount==1,cAliasTRB,cAliasTRB2),IIf(nCount==1,aPeriodos,aPeriodos2),aBancos,MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, aSelFil) }, STR0025 ) //"Calculando saldos iniciais"
				EndIf	
			EndIf	
		EndIf	
	Next nCount
	
	//-----------------------------------------------------------
	// Exibe o fluxo de caixa
	//-----------------------------------------------------------		
	TotalFluxo(cAliasTRB,aPeriodos,aBancos)
	MostraFluxo(MV_PAR03, MV_PAR04, cAliasFIY, lGravada,nLoop == 2,aParam,aPerguntas,cAliasTRB,aPeriodos,cAliasTRB2,aPeriodos2,cAliasAna,,,MV_PAR05)
EndIf
cFilAnt := cFilOld
cFilAnt := cFilOld
//-----------------------------------------------------------
// Apaga o arquivo temporario
//-----------------------------------------------------------
If cAliasFIY <> Nil .And. !Empty(cAliasFIY)
	If Select(cAliasFIY) > 0
		(cAliasFIY)->(DbCloseArea())
	EndIf
	If _oFINC0222 <> Nil
		_oFINC0222:Delete()
		_oFINC0222 := Nil
	Endif
EndIf
If cAliasAna <> Nil .And. !Empty(cAliasAna)
	If Select(cAliasAna) > 0
		(cAliasAna)->(DbCloseArea())
	EndIf
	//Deleta tabela temporária no banco de dados
	If _oFINC0223 <> Nil
		_oFINC0223:Delete()
		_oFINC0223 := Nil
	Endif
EndIf
If cAliasTRB <> Nil .And. !Empty(cAliasTRB)
	If Select(cAliasTRB) > 0
		(cAliasTRB)->(DbCloseArea())
	EndIf
	MSErase(cAliasTRB+GetDbExtension())
	MSErase(cAliasTRB+OrdBagExt())
EndIf
dbSelectArea("SA1")
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FlCxNatAna³ Autor ³ Alessandro Afonso     ³ Data ³ 29/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processamento do Fluxo de Caixa por Natureza Analitico	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FlCxNatAna                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  											 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FlCxNatAna(lEnd,cNatIni,cNatFin,dDtIni,dDtFin,nTipo,cAliasFIY,lGravada,cCodCons,cMoedPar,cAliasTRB,aPeriodos,lMvBco,cAliasAna)
Local aArea         := GetArea()
Local cAliasTmp 	:= GetNextAlias()
Local nPosTpSald
Local cCarteira     := ""
Local cNatureza     := ""
Local cSequencia    := ""
Local cPeriodo      := ""
Local cPrefCpo		:= ""
Local nX			:= 0
Local cQuery  		:= "" //PadR(&(GetMv("MV_NATAPLI")),TamSX3("EH_NATUREZ")[1])
Local nColuna 		:= 0

Default lMvBco := .F.
DEFAULT cMoedPar := '01'
//-----------------------------------------------------------
// Verifica o tamanho do campo natureza e ajusta se necessário
//-----------------------------------------------------------
cNatIni := PADR(cNatIni,Len(SED->ED_CODIGO)," ")
cNatFin := PADR(cNatFin,Len(SED->ED_CODIGO)," ")

// Quando e informado filtro MV_PAR19 os parametros Considera Comissao de Venda, Titulos a Receber e Titulos a Pagar 
// Sao despresados, ficando valendo apenas o filtro montado.
cQuery := "% " 
If Empty(MV_PAR19) .and. !lGravada

	If !MV_PAR16 // Considera comissao de venda
		cQuery += " AND FJV.FJV_CLORIG <> 'COMV' "
	Endif
	
	If !MV_PAR17 // Considera Titulos a Receber
		cQuery += " AND FJV.FJV_CLORIG <> 'TITR' "
	Endif
	
	IF !MV_PAR18 // Considera titulos a pagar
		cQuery += " AND FJV.FJV_CLORIG <> 'TITP' "
	Endif
	
ElseIf !lGravada // Filtro para Fluxo analitico, tabela FJV

	cNewQuery := PcoParseFil( MV_PAR19, "FJV" )
	If !Empty(cNewQuery)
		cNewQuery := " AND " + cNewQuery
		cQuery    += cNewQuery
	Endif
    
Endif	

//FSW                
If lMvBco
	cQuery += " AND SED.ED_MOVBCO = '1' " 
Endif

cQuery += " %"

//Fluxo analitico nao esta sendo utilizada a funcao de salvar fluxo.
If lGravada
	cPrefCpo := "FIY"
	BeginSql Alias cAliasTmp
		COLUMN FIY_DATA AS DATE
		SELECT * FROM %table:FIY% FIY
		LEFT JOIN %table:SED% SED ON 
				ED_FILIAL = %xFilial:SED%
				AND ED_CODIGO = FIY_NATUR  
				AND SED.%notDel%
		WHERE FIY_FILIAL = %xFilial:FIY%
				AND FIY_CODIGO = %exp:cCodCons%
				AND FIY.%notDel%          
				%exp:cQuery %
		ORDER BY FIY_DATA, FIY_NATUR
	EndSql
Else
	cPrefCpo := "FJV"
	BeginSql Alias cAliasTmp
		COLUMN FJV_DATA AS DATE
		SELECT ED_DESCRIC, FJV_NATUR, FJV_MOEDA, FJV_TPSALD, FJV_CARTEI, FJV_DATA, FJV_TPMOV, FJV_CLORIG, SUM(FJV_VALOR) FJV_VALOR FROM %table:FJV% FJV
		JOIN %table:SED% SED ON 
					ED_FILIAL = %xFilial:SED%
				AND ED_CODIGO = FJV_NATUR  
				AND SED.%notDel%
		WHERE FJV_FILIAL = %xFilial:FJV%
				AND FJV_NATUR >= %exp:cNatIni%
				AND FJV_NATUR <= %exp:cNatFin%
				AND FJV_DATA >= %exp:DTOS(dDtIni)%
				AND FJV_DATA <= %exp:DTOS(dDtFin)%  
				AND FJV_MOEDA = %Exp:cMoedPar% 
				AND FJV.%notDel%
				%exp:cQuery%
		GROUP BY ED_DESCRIC, FJV_NATUR, FJV_MOEDA, FJV_TPSALD, FJV_CARTEI, FJV_DATA, FJV_TPMOV, FJV_CLORIG
		ORDER BY FJV_DATA, FJV_NATUR

	EndSql
Endif	

cAliasAux := cAliasTmp // No processamento de uma filial apenas, utiliza o resultado da Query para gravacao posterior

//-----------------------------------------------------------
// Coloca os dados do Fluxo em todas as colunas
//-----------------------------------------------------------
dbSelectArea(cAliasTmp)
While (cAliasTmp)->(!Eof())
	//-----------------------------------------------------------
	// Cria registro no arquivo temporario, para posterior gravacao
	//-----------------------------------------------------------
	If cAliasFIY <> Nil .And. Select(cAliasFIY) > 0
		RecLock(cAliasFIY,.T.)
		For nX := 1 To (cAliasTmp)->(fCount())
			If (cAliasFIY)->(FieldPos((cAliasTmp)->(FieldName(nX)))) > 0
				(cAliasFIY)->(FieldPut((cAliasFIY)->(FieldPos((cAliasTmp)->(FieldName(nX)))),(cAliasTmp)->(FieldGet(nX))))
			EndIf
		Next
	Endif	
	//-----------------------------------------------------------
	// Descarta registros conforme os parametros
	//-----------------------------------------------------------
	If (cAliasTmp)->&(cPrefCpo+"_TPSALD") == "1" // Saldo Orcado
		nPosTpSald := 1 
		If mv_par14 == 4  // FSW
			dbSelectArea(cAliasTMP)
			DbSkip()
			Loop
		Endif                                                                            
	ElseIf (cAliasTmp)->&(cPrefCpo+"_TPSALD") == "2" // Saldo Previsto       
		nPosTpSald := 2
		If mv_par14 == 3
			dbSelectArea(cAliasTMP)
			DbSkip()
			Loop
		Endif
	ElseIf (cAliasTmp)->&(cPrefCpo+"_TPSALD") == "3" // Saldo Realizado
		nPosTpSald := 3  
		If mv_par14 == 2
			dbSelectArea(cAliasTMP)
			DbSkip()
			Loop
		Endif
	Endif 
	
	//-----------------------------------------------------------
	// Atualiza o arquivo temporario do fluxo de caixa
	//-----------------------------------------------------------
	cPeriodo   	:= Periodo(nTipo, (cAliasTmp)->&(cPrefCpo+"_DATA"), dDtIni, dDtFin)
	cNatureza  	:= (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_NATUR")))+" - "+(cAliasTmp)->(FieldGet(FieldPos("ED_DESCRIC")))	
	cCarteira  	:= (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_CARTEI")))
	If Empty(cCarteira)
		Help(" ",1,"CARTNTBRCO",,STR0095+ cNatureza + CRLF + CRLF + STR0096,1,0) //"Existem saldos sem a informação da carteira para a natureza " + Alltrim(&(cPrefCpo+"_NATUR")) //"Acesse o cadastro de Naturezas, informe sua condição e execute o Reprocessamento dos saldos."                                                                                                                                                                                                                                                                                                                                                                                                                      
		Exit
	EndIf
	cSequencia := IIf(cCarteira=="R","001","002") //IIf((cAliasTRB)->CART=="R","001","002")

	DbSelectArea(cAliasTRB)
	DbSetOrder(1)
	If !MsSeek(cSequencia+cCarteira+cNatureza)
		RecLock(cAliasTRB,.T.)
	Else
		RecLock(cAliasTRB)
	EndIf
	(cAliasTRB)->CART 	:= cCarteira
	(cAliasTRB)->SEQ  	:= cSequencia
	(cAliasTRB)->NAT  	:= cNatureza
	(cAliasTRB)->CODNAT	:= (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_NATUR")))
	nX := aScan(aPeriodos,cPeriodo)
	If nX <> 0
		If (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_TPSALD"))) == "1" // Saldo Orcado
			(cAliasTRB)->(FieldPut(FieldPos("ORC"+StrZero(nX,3)) ,FieldGet(FieldPos("ORC"+StrZero(nX,3)))+(cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_VALOR")))))
		EndIf
		If (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_TPSALD"))) == "2" // Saldo Previsto
			(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),FieldGet(FieldPos("PREV"+StrZero(nX,3)))+(cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_VALOR")))))
		EndIf
		If (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_TPSALD"))) == "3" // Saldo Realizado
			(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),FieldGet(FieldPos("REAL"+StrZero(nX,3)))+(cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_VALOR")))))
		EndIf
		If MV_PAR14 <> 1
			If MV_PAR14 == 4 //Previsto x Realizado
				(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),FieldGet(FieldPos("PREV"+StrZero(nX,3)))-FieldGet(FieldPos("REAL"+StrZero(nX,3)))))
			EndIf			
			If MV_PAR14 == 2 //Orçado x Previsto
				(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),FieldGet(FieldPos("PREV"+StrZero(nX,3)))-FieldGet(FieldPos("ORC"+StrZero(nX,3)))))
			EndIf			
			If MV_PAR14 == 3 //Orçado x Realizado
				(cAliasTRB)->(FieldPut(FieldPos("COMP"+StrZero(nX,3)),FieldGet(FieldPos("REAL"+StrZero(nX,3)))-FieldGet(FieldPos("ORC"+StrZero(nX,3)))))
			EndIf			
		EndIf			

		If MV_PAR14 != 4 .and. nPosTpSald == 1 //Orcado
			nColuna := 1
        EndIf

		IF MV_PAR14 != 3 .and. nPosTpSald == 2 //Previsto
			If MV_PAR14 == 4 //Previsto x Realizado
				nColuna := 1
			Else
				nColuna := 2
			EndIf
        EndIf

		If MV_PAR14 != 2 .and. nPosTpSald == 3 //Realizado
			If MV_PAR14 == 3 .Or. MV_PAR14 == 4 
				nColuna := 2
			Else
				nColuna := 3
			EndIf
        EndIf

		FlxAnaAdd(cNatureza,((nX*3)-3+1) + nColuna, cPrefCpo,cAliasTmp,@cAliasAna ) // Add array de Fluxo analitico, dados da tabela FJV

	EndIf
	MsUnLock()
	dbSelectArea(cAliasTMP)
	DbSkip()
EndDo

dbSelectArea(cAliasTMP)
DbCloseArea()
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FlxAnaAdd ³ Autor ³ Alessandro Afonso     ³ Data ³ 29/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ adiciona no array de fluxo analitico.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FlxAnaAdd (                                                ³±±
±±³     	 ³ Natureza                                                   ³±±
±±³     	 ³ Posicao da coluna                                          ³±±
±±³     	 ³ Moeda                                                      ³±±
±±³     	 ³ Carteira                                                   ³±±
±±³     	 ³ Data                                                       ³±±
±±³     	 ³ Valor                                                      ³±±
±±³     	 ³ Tipo Movimentacao (Soma, Subtrai)                          ³±±
±±³     	 ³ Origem da Movimentacao ( APL, EMP, TITR, TITP,             ³±±
±±³     	 ³  MVBR, MVBP, PV, PC, CONV)                          		  ³±±         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  											 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FlxAnaAdd( cNatu, nPos, cPrefCpo, cAliasTmp, cAliasAna )

Local aArea := GetArea()

If cAliasAna == "Zero"
	If Select(cAliasAna) <= 0
		CriaAna(@cAliasAna)
	EndIf

EndIf

If Select(cAliasAna) > 0
	DbSelectArea(cAliasAna)
	RecLock(cAliasAna,.T.)
		(cAliasAna)->ANA_NAT 	:= cNatu
		(cAliasAna)->ANA_NPOS 	:= StrZero(nPos,3)
		(cAliasAna)->ANA_MOEDA	:= (cAliasTmp)->&(cPrefCpo+"_MOEDA")
		(cAliasAna)->ANA_CART	:= (cAliasTmp)->&(cPrefCpo+"_CARTEI")
		(cAliasAna)->ANA_DATA	:= (cAliasTmp)->&(cPrefCpo+"_DATA")
		(cAliasAna)->ANA_VALOR	:= (cAliasTmp)->&(cPrefCpo+"_VALOR")
		If (cAliasTmp)->(FieldPos(cPrefCpo+"_TPMOV")) > 0
			(cAliasAna)->ANA_TPMOV	:= Iif((cAliasTmp)->&(cPrefCpo+"_TPMOV")=='1','SOMA','SUBTRAI')
		EndIf
		If (cAliasTmp)->(FieldPos(cPrefCpo+"_CLORIG")) > 0
			(cAliasAna)->ANA_ORIGEM	:= (cAliasTmp)->&(cPrefCpo+"_CLORIG")
		EndIf
	MsUnLock()	
EndIf
	
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINC022   ºAutor  ³Andre Lago          º Data ³  05/23/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria tabela temporaria para fluxo analitico                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CriaAna(cAliasAna)

Local aStruct   := {}
//-----------------------------------------------------------
// Define a estrutura inicial do arquivo temporario de exibição do fluxo analitico
//-----------------------------------------------------------
aadd(aStruct,{"ANA_NAT","C",Len(FJV->FJV_NATUR),0})
aadd(aStruct,{"ANA_NPOS","C",3,0})
aadd(aStruct,{"ANA_MOEDA","C",Len(FJV->FJV_MOEDA),0})
aadd(aStruct,{"ANA_CART","C",01,0})
aadd(aStruct,{"ANA_DATA","D",08,0})
aadd(aStruct,{"ANA_VALOR","N",17,2})
aadd(aStruct,{"ANA_TPMOV","C",07,0})
aadd(aStruct,{"ANA_ORIGEM","C",Len(FJV->FJV_CLORIG),0})

//-----------------------------------------------------------
// Cria o arquivo de trabalho
//-----------------------------------------------------------
If _oFINC0223 <> Nil
	_oFINC0223:Delete()
	_oFINC0223 := Nil
Endif

cAliasAna := GetNextAlias()

_oFINC0223 := FWTemporaryTable():New( cAliasAna )  
_oFINC0223:SetFields(aStruct) 	
_oFINC0223:AddIndex("1", {"ANA_NAT","ANA_NPOS","ANA_CART"}) 
					
//------------------
//Criação da tabela temporaria
//------------------
_oFINC0223:Create()	

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fc022Leg  ³ Autor ³ Alessandro Afonso     ³ Data ³ 16/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Legenda para tela fluxo de caixa analitico.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  											 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc022Leg()
Local aLegenda := {}

Aadd(aLegenda, {"", STR0083 }) //"MVBR = Movimentacao Bancario Receber
Aadd(aLegenda, {"", STR0084 }) //"MVBP = Movimentacao Bancario Pagar
Aadd(aLegenda, {"", STR0085 }) //"TITR = Titulo a Receber 
Aadd(aLegenda, {"", STR0086 }) //"TITP = Titulos a Pagar 
Aadd(aLegenda, {"", STR0087 }) //"COMV = Comissão de venda
Aadd(aLegenda, {"", STR0088 }) //"APL  = Aplicação financeira 
Aadd(aLegenda, {"", STR0089 }) //"EMP  = Emprestimo financeiro 

	BrwLegenda(STR0050, STR0090, aLegenda) // "Fluxo de Caixa por Natureza"###"Legenda"

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Bancos    ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe os bancos para selecao dos saldos                    º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ lConsFil    -> Considera filiais                           º±±
±±º          ³ nMoeda      -> Codigo da moeda                             º±±
±±º          ³ nBancos     -> Saldo em bancos (por referencia)            º±±
±±º          ³ nCaixas     -> Saldo em caixas (por referencia)            º±±
±±º          ³ Retorno:                                                   º±±
±±º          ³ aRet[n] = .F.,Banco,Agencia,Conta,Nome,Saldo               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Bancos( lConsFil, nMoeda, nBancos, nCaixas, aSelFil, cTipoSaldo, lRecalcula, aBancos, lLimCred, nSldBco, lZeraSld )
Local oDlgBanc
Local oOk 			:= LoadBitmap( GetResources(), "LBOK" )
Local oNo 			:= LoadBitmap( GetResources(), "LBNO" )
Local cBancoCx 	:= GetMV("MV_CARTEIR")
Local oGet01, lInverter, oGet02
Local aRet, aVerBco
Local lBcoExcl 		:= !Empty(FwFilial("SA6"))
Local nI			:=	0

DEFAULT lLimCred := .T.
DEFAULT nSldBco  := 1
DEFAULT lZeraSld := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa array com os bancos existentes.						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			  
// Se ainda não passou pela rotina, inicializa a matriz de bancos, senao
// exibe a matriz carregada anteriormente, pois esta funcao eh chamada em dois
// momentos: Quando o usuario marca se deseja saldos bancarios e quando seleciona o tipo
// de saldo a ser considerado. Quando selecionado o tipo de saldo, nao se deve carregar os bancos
// novamente para nao perder a marcacao efetuada enteriormente pelo usuario, apenas recalcula o saldo pelo
// novo tipo.

If !lBcoExcl .And. nSldBco = 1
//	cFilDe := '  '
//	cfilAte := 'ZZ'
	lConsFil := .T.
Endif

aRet := GetBancos(lConsFil, nMoeda, aSelFil, cTipoSaldo, lRecalcula, aBancos, lZeraSld)
If Len(aRet) == 0                                                                
	IW_MSGBOX("Nao existem saldos bancarios","Atenção","STOP") //"Nao existem saldos bancarios"
Else
	ASort(aRet,,, { |x,y| x[2]+x[3]+x[4] < y[2]+y[3]+y[4] } ) // Ordena pelo codigo do banco
		
	DEFINE MSDIALOG oDlgBanc TITLE "Selecione os bancos" From 5,5 To 20,84 OF oMainWnd //"Selecione os bancos"
	@	 .8, .5 LISTBOX oBancos FIELDS HEADER "","Banco","Agencia","Conta","Nome","Saldo","Limite de Crédito" FIELDSIZES 14,25,31,31,60,40,40 SIZE 270, 100 OF oDlgBanc //"Banco"###"Agencia"###"Conta"###"Nome"###"Saldo"
	@   .6,  4 CHECKBOX oGet01 VAR lInverter PROMPT "Marcar todos" FONT oDlgBanc:oFont PIXEL OF oDlgBanc SIZE 50,9 ON CLICK (oGet01:cCaption := If( lInverter, "Desmarcar", "Marcar")+" todos", oGet01:Refresh(), aEval(aRet, {|e| e[1] := lInverter}), oBancos:Refresh()) //"Marcar todos"###"Desmarcar"###"Marcar"###" todos"
	@   .6, 115 CHECKBOX oGet02 VAR lLimCred PROMPT "Considera Limite de Crédito" FONT oDlgBanc:oFont PIXEL OF oDlgBanc SIZE 50,9 // "Considera Limite de Crédito"

	oBancos:SetArray(aRet)
	oBancos:bLine      := {|| {If(aRet[oBancos:nAt,1],oOk,oNo),;
									aRet[oBancos:nAt,2],;
									aRet[oBancos:nAt,3],;
									aRet[oBancos:nAt,4],;
									aRet[oBancos:nAt,5],;
									aRet[oBancos:nAt,6],;
									aRet[oBancos:nAt,8]}}

	oBancos:bLDblClick := {|| aRet[oBancos:nAt][1] := !aRet[oBancos:nAt][1], oBancos:DrawSelect()}
	DEFINE SBUTTON FROM 10, 280 TYPE 1 ACTION oDlgBanc:End() ENABLE OF oDlgBanc
	ACTIVATE MSDIALOG oDlgBanc

	aVerBco	:= {}	
	For nI =1 to Len(aRet)
		If aRet[nI,1] = .T.
			Aadd(aVerBco,aRet[nI])		
		Endif	
	Next 
	
	aRet	:=	aClone(aVerBco)	
	
	// Calcula o saldo em Bancos/Caixas
	aEval( aRet, { |e| If( e[1], If( Left(e[2],2)=="CX" .Or. Left(e[2],3) $ cBancoCx,;
										nCaixas +=	Fc022Val(e[6]),;
										nBancos +=	Fc022Val(e[6])),Nil)})
Endif
	
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GetBancos ºAutor  ³Claudio D. de Souza º Data ³  30/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obter os bancos do SA6                                     º±±
±±º          ³ Parametros:                                                º±±
±±º          ³ lConsFil    -> Considera filiais                           º±±
±±º          ³ nMoeda      -> Codigo da moeda                             º±±
±±º          ³ Retorno:                                                   º±±
±±º          ³ aRet[n] = .F.,Banco,Agencia,Conta,Nome,Saldo               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Finc021                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetBancos( lConsFil, nMoeda, aSelFil, cTipoSaldo, lRecalcula, aBancos, lZeraSld)
Local aRet     := {},;
		aArea    := GetArea(),;
		aAreaSa6 := Sa6->(GetArea()),;
		aAreaSe8 := Se8->(GetArea()),;
		cTrbBanco                   ,;
		cTrbAgencia                 ,;
		cTrbConta                   ,;
		cTrbNome                    ,;
		dTrbData                    ,;
		nTrbSaldo                   ,;
		lSldBco    := .F.           ,;
		cIndSE8  := ""					 ,;
		cSavFil  := cFilAnt			 ,;
		aAreaSm0 :=	SM0->(GetArea()),;
		nAscan

Local nMoedaBco 
Local nI
Local lGestao := Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa

If aBancos != Nil
	aRet := aClone(aBancos)
Endif 

//Zera o Saldo para o recálculo de Slado por Filial ou por Total
If lZeraSld
	For nI :=1 to Len(aBancos)
		aRet[nI][6] := 0
		aRet[nI][8] := 0			
	Next nI		
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui valores as variaveis ref a filiais                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lConsFil
	cFilDe  := cFilAnt
	cFilAte := cFilAnt
Endif

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilDe,.T.)

While !Eof() .and. M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil,  FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
	cFilAnt := IIf( lFWCodFil,  FWGETCODFILIAL, SM0->M0_CODFIL )

	DbSelectArea("SA6")
	If MsSeek( xFilial("SA6") )
		
		While SA6->(!Eof()) .And. A6_FILIAL == xFilial("SA6")
			If SA6->A6_FLUXCAI $ "S "
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica banco a banco a disponibilidade imediata				  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SE8")
				cTrbBanco  := SA6->A6_COD
				cTrbAgencia:= SA6->A6_AGENCIA
				cTrbConta  := SA6->A6_NUMCON
				cTrbNome   := SA6->A6_NREDUZ
				nMoedaBco  := If( cPaisLoc="BRA",1,Max(SA6->A6_MOEDA,1))
				lSldBco    := .F.
				nRecSE8 := SE8->(RECNO())
				If ! MsSeek(xFilial("SE8")+SA6->(A6_COD+A6_AGENCIA+A6_NUMCON+DTOS(dDataBase)),.T.)
					dbSkip(-1)
					dTrbData := SE8->E8_DTSALAT
					While !Bof() 										.And.;
							SA6->(A6_COD+A6_AGENCIA+A6_NUMCON) ==	;
							SE8->(E8_BANCO+E8_AGENCIA+E8_CONTA)	.And.;
							xFilial("SE8") == SE8->E8_FILIAL		.And.;
							SE8->E8_DTSALAT == dTrbData
						dbSkip( -1 )
						lSldBco := .T.
					End				
					If ( lSldBco )
						If SE8->(Bof())
							dbGoTo(nRecSE8)
						Else
							dbSkip()
						Endif
					EndIf
				EndIf
				While !Eof()										.And.;
						SA6->(A6_COD+A6_AGENCIA+A6_NUMCON) == ;
						SE8->(E8_BANCO+E8_AGENCIA+E8_CONTA)	.And.;
						xFilial("SE8") == SE8->E8_FILIAL		.And.;
						SE8->E8_DTSALAT <= dDataBase

					If Left(cTipoSaldo,1)=="1" // Somente saldo normal
						nTrbSaldo := xMoeda(SE8->E8_SALATUA,nMoedaBco,nMoeda)
					ElseIf Left(cTipoSaldo,1)=="2" // Somente os conciliados
						nTrbSaldo := xMoeda(SE8->E8_SALRECO,nMoedaBco,nMoeda)
					Elseif Left(cTipoSaldo,1)=="3" // Nao conciliados
						nTrbSaldo := xMoeda(SE8->E8_SALATUA-SE8->E8_SALRECO,nMoedaBco,nMoeda)
					Endif	
	
					// Pesquisa banco+agencia+conta, para nao exibir saldos duplicados.
					nAscan := Ascan(aRet, {|e| e[2]+e[3]+e[4] == cTrbBanco+cTrbAgencia+cTrbConta})
					If nAscan > 0
						aRet[nAscan][6] := If(	lRecalcula,;
														Transform(nTrbSaldo,PesqPict("SE8","E8_SALATUA")),;
														Transform(Fc022Val(aRet[nAscan][6])+ nTrbSaldo,PesqPict("SE8","E8_SALATUA")))
						aRet[nAscan][8] := If(	lRecalcula,Transform(xMoeda(SA6->A6_LIMCRED,nMoedaBco,nMoeda),PesqPict("SE8","E8_SALATUA")),;
														Transform(Fc022Val(aRet[nAscan][8])+ xMoeda(SA6->A6_LIMCRED,nMoedaBco,nMoeda),PesqPict("SE8","E8_SALATUA")))
					Else
						Aadd(aRet,{.F.,cTrbBanco,cTrbAgencia,cTrbConta,cTrbNome,Transform(nTrbSaldo,PesqPict("SE8","E8_SALATUA")),nMoeda,Transform(xMoeda(SA6->A6_LIMCRED,nMoedaBco,nMoeda),PesqPict("SE8","E8_SALATUA"))})
					Endif	
					DbSkip()
				EndDo
			Endif
			dbSelectArea("SA6")
			dbSkip()
		End                                                                 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nao continua processamento se bancos e saldos bancarios estiverem ³
		//³ com filial compartilhada para evitar saldos em duplicidade        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	Empty( IIf( lGestao, FWFilial("SA6"), xFilial("SA6") ) ) .And.;
			Empty( Iif( lGestao, FWFilial("SE8"), xFilial("SE8") ) )
			Exit
		Endif
	
	EndIf
	
	dbSelectArea("SM0")
	dbSkip()
EndDo

cFilAnt := cSavFil
SM0->(RestArea(aAreaSM0))

If ( !Empty(cIndSE8) )
	dbSelectArea("SE8")
	RetIndex("SE8")
	dbClearFilter()	
	Ferase(cIndSE8+OrdBagExt())
EndIf

Sa6->(RestArea(aAreaSa6))
Se8->(RestArea(aAreaSe8))
RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Fc022Val   ³ Autor ³ Leonardo Gentile     ³ Data ³ 02/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o valor do argumento passado considerando a picture ³±±
±±³          ³ no formato AMERICAN (9,999.99) ou DEFAULT (9.999,99)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ FINC021													   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/              
Static Function Fc022Val( cTexto)
Local nValor
Local cDec, cMil

cTexto 	:= AllTrim( cTexto)
cDec := Subs( cTexto, Len(cTexto)-2, 1)
cMil := If( cDec=".",",",".")

nValor := Val( StrTran( StrTran( cTexto, cMil, ""), cDec, ".") )

Return nValor

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F022TotNat

Totaliza as naturezas analíticas nas sintéticas

@author    Marcos Berto
@version   11.80
@since     15/03/13

@param cAliasTRB - Tabela Temporaria

/*/
//------------------------------------------------------------------------------------------
Function F022TotNat(cAliasTRB)

Local aAreaTRB		:= {}
Local aSequencia	:= {}
Local aStruct		:= {}
Local cSeq			:= ""
Local cCart			:= ""
Local cNatureza		:= ""
Local cQuery		:= ""
Local cAliasAux 	:= ""
Local cAliasQry 	:= GetNextAlias()
Local nX			:= 0
Local nPosSeq		:= 0
Local lVisaoGer 	:= lfluxSint .AND. !Empty(mv_par16)

aAreaTRB := (cAliasTRB)->(GetArea())

//Criar uma cópia do arquivo temporário para reprocessamento
dbSelectArea(cAliasTRB)
aStruct := (cAliasTRB)->(dbStruct())
cAliasAux := FWOPENTEMP(cAliasAux,aStruct)	
IndRegua(cAliasAux,cAliasAux,"NATPAI")

//Replica os dados da tabela temporária
(cAliasTRB)->(dbGoTop())	
While !(cAliasTRB)->(Eof())	
	If (cAliasTRB)->CART != "Z"
		RecLock(cAliasAux,.T.)
		For nX := 1 To Len(aStruct)
			(cAliasAux)->&(aStruct[nX][1]) := (cAliasTRB)->&(aStruct[nX][1])
		Next nX
		(cAliasAux)->(MsUnlock())
	EndIf
	(cAliasTRB)->(dbSkip())	
EndDo

//Busca todas as naturezas sintéticas
cQuery := "SELECT SED.ED_CODIGO,SED.ED_DESCRIC,SED.ED_PAI FROM "
cQuery +=		RetSqlName("SED") + " SED " 
cQuery +=		"WHERE "
cQuery +=		"SED.ED_FILIAL = '" +xFilial("SED")+ "' AND "
cQuery +=		"SED.ED_TIPO = '1' AND "	
cQuery +=		"SED.D_E_L_E_T_ = ''	"

cQuery +=	"ORDER BY ED_CODIGO DESC"	

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.F.,.T.)

dbSelectArea(cAliasTRB)
	
While !(cAliasQry)->(Eof())

	//verifica para quais sequencias deve haver uma mesma sintética
	dbSelectArea(cAliasAux)
	(cAliasAux)->(dbGoTop())
	If (cAliasAux)->(dbSeek((cAliasQry)->ED_CODIGO))
		While !(cAliasAux)->(Eof()) .And. (cAliasAux)->NATPAI == (cAliasQry)->ED_CODIGO
			nPosSeq := aScan(aSequencia,{|x| x[2] == (cAliasAux)->SEQ })	
			If nPosSeq == 0
				aAdd(aSequencia,{(cAliasAux)->CART,(cAliasAux)->SEQ})
			EndIf
			(cAliasAux)->(dbSkip())
		EndDo
	EndIf
	
	//Cria um registro para cada carteira + sequencia
	If Len(aSequencia) > 0
		
		//Sintéticas imediatamente superiores às analíticas
		
		For nX := 1 to Len(aSequencia)		
		
			dbSelectArea(cAliasTRB)
			If lVisaoGer
				IndRegua(cAliasTRB,cAliasTRB,"ORDVIS+SEQ+CART+NAT")
			Else
				IndRegua(cAliasTRB,cAliasTRB,"SEQ+CART+NAT")
			Endif
			
			If !(cAliasTRB)->(dbSeek(aSequencia[nX][2]+aSequencia[nX][1]+(cAliasQry)->ED_CODIGO))
				RecLock(cAliasTRB,.T.)
				(cAliasTRB)->CART 		:= aSequencia[nX][1]
				(cAliasTRB)->SEQ  		:= aSequencia[nX][2]
				(cAliasTRB)->NAT  		:= (cAliasQry)->ED_CODIGO + " - " + (cAliasQry)->ED_DESCRIC	
				(cAliasTRB)->NATPAI 		:= (cAliasQry)->ED_PAI
				(cAliasTRB)->(MsUnlock())	
			EndIf
				
		Next nX
	Else
		
		//Sintéticas de nível 1 - N
		
		dbSelectArea(cAliasTRB)
		IndRegua(cAliasTRB,cAliasTRB,"NATPAI")
		
		If (cAliasTRB)->(dbSeek((cAliasQry)->ED_CODIGO))
			While !(cAliasTRB)->(Eof()) .And. (cAliasTRB)->NATPAI == (cAliasQry)->ED_CODIGO
				aAdd(aSequencia,{(cAliasTRB)->CART,(cAliasTRB)->SEQ})
				(cAliasTRB)->(dbSkip())		
			EndDo
		EndIf

		dbSelectArea(cAliasTRB)
		If lVisaoGer
			IndRegua(cAliasTRB,cAliasTRB,"ORDVIS+SEQ+CART+NAT")
		Else
			IndRegua(cAliasTRB,cAliasTRB,"SEQ+CART+NAT")
		Endif
		
		For nX := 1 to Len(aSequencia)
			If !(cAliasTRB)->(dbSeek(aSequencia[nX][2]+aSequencia[nX][1]+(cAliasQry)->ED_CODIGO))
				RecLock(cAliasTRB,.T.)
				(cAliasTRB)->CART 		:= aSequencia[nX][1]
				(cAliasTRB)->SEQ  		:= aSequencia[nX][2]
				(cAliasTRB)->NAT  		:= (cAliasQry)->ED_CODIGO + " - " + (cAliasQry)->ED_DESCRIC	
				(cAliasTRB)->NATPAI 		:= (cAliasQry)->ED_PAI
				(cAliasTRB)->(MsUnlock())	
			EndIf
		Next nX
			
	EndIf
	
	aSequencia := {}
	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(dbCloseArea()) 
MsErase(cAliasQry)

(cAliasAux)->(dbGoTop())		
While !(cAliasAux)->(Eof())	

	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbGoTop())
		
	cCart 		:= 	(cAliasAux)->CART
	cSeq 		:= 	(cAliasAux)->SEQ
	cNatureza 	:= 	(cAliasAux)->NATPAI
		
	While cNatureza <> ""
		If (cAliasTRB)->(dbSeek(cSeq+cCart+cNatureza))
					
			RecLock(cAliasTRB,.F.)

			For nX := 1 To Len(aStruct)
				If "ORC" $ aStruct[nX][1] .Or. "PREV" $ aStruct[nX][1] .Or. "REAL" $ aStruct[nX][1]  
					(cAliasTRB)->&(aStruct[nX][1]) += (cAliasAux)->&(aStruct[nX][1])
				EndIf
			Next nX		 
			
			(cAliasTRB)->(MsUnlock())
			
			//Controle de atualização das superiores imediatas
			cNatureza := (cAliasTRB)->NATPAI
		Else
			cNatureza := ""	
		EndIf		
	EndDo						
	
	(cAliasAux)->(dbSkip())

EndDo

FWCLOSETEMP(cAliasAux)

(cAliasTRB)->(RestArea(aAreaTRB))

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} Fc022ExibeGraf
Monta e exibe o gráfico de fluxo de caixa por natureza

@author Pedro Alencar	
@since 12/02/2014
@version 12

@param cAliasTBR, Alias do arquivo temporário com os valores totais dos períodos
@param aDescricao, Vetor com as descrições do eixo x
@param aPeriodos, Vetor com os períodos do relatório
@param nTipo, Tipo do período a ser exibido (1 = Dias, 2 = Semanas, 3 = Meses)
@return Nil
/*/
//----------------------------------------------------------------------
Static Function Fc022ExibeGraf(cAliasTRB, aDescricao, aPeriodos, nTipo)
	Local aSaveArea	:= GetArea()
	Local oGrafDlg	:= Nil
	Local nA			:= 0
	Local aValores	:= {} // Dados com valores do grafico
	Local cSearch		:= CHR(13) + CHR(10)
	Local cSubstitui	:= " "
	Local nMaior		:= 0
	Local nMenor		:= 0
	Local nLen			:= Len(aPeriodos) 
	Local nTpGraf		:= 0
	Local aSizeAut	:= FWGetDialogSize(oMainWnd)
	Local oChart1		:= Nil
	Local aSerie1		:= {}
	Local aSerie2		:= {}
	Local aSerie3		:= {}
	Local cPeriodo	:= ""
	Local nCoordY		:= 0
	Local nCoordX		:= 0
	Local nWidth		:= 0
	Local nHeight		:= 0
	Local aTitCols	:= {}
	Local lVisaoGer	:= lfluxSint .AND. !Empty(mv_par16)
	Local nQtdCpos	:= 0
	
	nCoordY := aSizeAut[1]
	nCoordX := aSizeAut[2]
	nWidth  := aSizeAut[4]
	nHeight := aSizeAut[3]

	If Pergunte ("FC022GRAF", .T.)
		nTpGraf := MV_PAR01

		DEFINE DIALOG oGrafDlg TITLE OemToAnsi(STR0108) FROM nCoordX,nCoordY TO nHeight,nWidth PIXEL  //"Gráfico de Fluxo por Natureza"	

		oChart1 := FWChartFactory():New()
		//Retorna a instância do gráfico desejado (BARCHART(0) para barras,LINECHART(1) para linhas, PIECHART(2) para pizza, BARCOMPCHART(?) para comparação de barras)
		oChart1 := Iif(nTpGraf = 2, oChart1:GetInstance(BARCOMPCHART), oChart1:GetInstance(LINECHART))
		oChart1:Init(oGrafDlg, .T.)
		
		nQtdCpos := Iif( lVisaoGer, 6, 5 )
		
		dbSelectArea(cAliasTRB)
		(cAliasTRB)->( dbSetOrder(1) )
						
		//+------------------------------------------------+
		//|Posiciona no Final, pois sempre tenho que pegar |
		//|o Saldo Final da Consulta para gerar o Grafico  |
		//+------------------------------------------------+
		(cAliasTRB)->( dbGoBottom() )
		For nA := 1 to (nLen*4)
			If nMaior < (cAliasTRB)->(FieldGet(nA + nQtdCpos))
				nMaior := (cAliasTRB)->(FieldGet(nA + nQtdCpos))
			EndIf

			If nMenor > (cAliasTRB)->(FieldGet(nA + nQtdCpos))
				nMenor := (cAliasTRB)->(FieldGet(nA + nQtdCpos))
			EndIf

			AAdd (aValores,(cAliasTRB)->(FieldGet(nA + nQtdCpos)))
		Next nA

		For nA := 2 to Len(aDescricao) Step 3
	  		//Tira quebra de linha da legenda para correta exibicao.
			aDescricao[nA] := STRTRAN(aDescricao[nA],cSearch,cSubstitui)

	  		If nTipo == 2 //Se for por semanas, pega o texto "dd/mm a dd/mm" 
				cPeriodo := SubStr(aDescricao[nA], At(" ", aDescricao[nA])+1)	  		             
			Else
		  		//Pega o nome abreviado do mês e remove a parte de "orçado", "realizado" ou "previsto"
				cPeriodo := StrTran(SubStr(aDescricao[nA], rAt(" ", aDescricao[nA])+1,3), "/", "") ;
							+ SubStr(aDescricao[nA], rAt("/", aDescricao[nA]))
			Endif

			aAdd(aSerie1, {cPeriodo, aValores[nA-1]})
			aAdd(aSerie2, {cPeriodo, aValores[nA]})
			aAdd(aSerie3, {cPeriodo, aValores[nA+1]})
		Next nA

		//Avalia quais colunas serao apresentadas de acordo com a pergunta Comparativo (MV_PAR14)
		If MV_PAR14 == 1 //Nenhum
			aTitCols := {STR0036,STR0037,STR0038} //"Orçado"###"Previsto"###"Realizado"
		ElseIf MV_PAR14 == 2 //Orcado X Previsto
			aTitCols := {STR0036,STR0037,STR0068} //"Orçado"###"Previsto"###"Comparativo"
		ElseIf MV_PAR14 == 3 //Orcado X Realizado
			aTitCols := {STR0036,STR0038,STR0068} //"Orçado"###"Realizado"###"Comparativo"
		ElseIf MV_PAR14 == 4 //Previsto X Realizado
			aTitCols := {STR0037,STR0038,STR0068} //"Previsto"###"Realizado"###"Comparativo"
		EndIf

		oChart1:AddSerie(aTitCols[1], aSerie1)
		oChart1:AddSerie(aTitCols[2], aSerie2)
		oChart1:AddSerie(aTitCols[3], aSerie3)

		oChart1:setLegend(CONTROL_ALIGN_RIGHT)
		oChart1:SetMaxY(nMaior)
		oChart1:SetMinY(nMenor)

		oChart1:setColor("Random")  
		oChart1:Build()

		ACTIVATE DIALOG oGrafDlg CENTERED

	EndIf

	RestArea(aSaveArea)

Return Nil

//-------------------------------------------
// Funcao para ajuste do retorno da Parambox
// 
// Atencao! O retorn
//-------------------------------------------
Static Function AjRetParam(aRet,aParamBox)
Local nX := 0

If ValType(aRet) == "A" .And. Len(aRet) == Len(aParamBox)
    For nX := 1 To Len(aParamBox)
            If aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "C"
                aRet[nX] := aScan(aParamBox[nX][4],{|x| Alltrim(x) == aRet[nX]})
            Endif
    Next nX
EndIf

Return aRet

//----------------------------------------------------------------------
/*/{Protheus.doc} VldData()
Valida data digitada ao confirmar os parâmetros informados.

@author TOTVS S/A
@since 25/08/2014
@version 12

@return lRet Boolean
/*/
//----------------------------------------------------------------------
Static Function VldData()
Local lRet := .T.

//Valida se as datas estao coerentes
If MV_PAR03 > MV_PAR04
	lRet := .F.
	Alert(STR0107)
EndIf

Return lRet
