#INCLUDE "finc022.ch"
#include "PROTHEUS.CH"
#include "MSGRAPHI.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "FWBROWSE.CH"

#DEFINE PERIODOS 		 1
#DEFINE LBASE			 5
#DEFINE LSALDO			 6	

STATIC lIntTOP := GetMv("MV_INTPMS") == 'S' .AND. !Empty(GetMv("MV_RMCOLIG")) //Variavel utilizada na integração RM X TOP
Static _oFINC0243
Static _oFINC0244
Static _oFINC0245
Static _oFINC0246
Static _oFINC0247
Static _oFINC0248

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FINC024	³ Autor ³ Claudio D. de Souza   ³ Data ³ 07/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fluxo de Caixa por Natureza							  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FINC024()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Financeiro 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINC024(lGravada, cCodFlx, cCodFlxCmp)
Local aParam		:= {}
Local aPeriodos   := {}
Local aPeriodos2  := {}
Local aSelFil     	:= {}
Local aConf		:= {}
Local cNatEntDe	:= PAD(" ", Len(SE1->E1_NATUREZ)) // Space(Len(SE1->E1_NATUREZ))
Local cNatEntAte	:= PAD("ZZ", Len(SE1->E1_NATUREZ)) // Space(Len(SE1->E1_NATUREZ))
Local aTipos 	 	:= {STR0001, STR0002, STR0003} //"Dias"###"Semanas"###"Meses###Anos"
Local dDataIni		:= FirstDay(dDataBase)
Local dDataFin		:= LastDay(dDataBase)
Local cAliasFIY     := GetNextAlias()
Local cAliasTRB     := GetNextAlias()
Local cAliasTRB2    := ""
Local lRet			:= .T.
Local cFilOld		:= cFilAnt
Local nX			:= 0
Local lProcessa     := .F.
Local nCount		:= 0
Local nLoop			:= 1
Local aPerguntas	:= {}
Local cTamMoed		:= TamSX3("FIV_MOEDA")[1]
Local cMoePam		:= Space(cTamMoed)
Local nParCont		:= 0
Local aBancos 		:= {}
Local cModoFilial	:= ""
Local cModoUnNeg	:= ""
Local aCCustos		:= {}
Local cNatIni		:= ""
Local lPAR10Num 	:= .T.
Local lPAR13Num 	:= .T.

Private aVisao := {}		 
Private lfluxSint := .T. 

Default lGravada	:= .F.
Default cCodFlx		:= FIX->FIX_CODIGO

Private cNota		:= ""
Private oMemo
Private cNota2  := ""    
Private aFluxAna := {}
Private cFilDe   := cFilAnt
Private cFilAte  := cFilAnt

If GetRpoRelease() >= "12.1.033" .and. FindFunction("MsgExpRot")
	MsgExpRot("FINC024",;
				STR0125,; //"Dashboard financeiro FATA900" 
				"https://tdn.totvs.com/pages/releaseview.action?pageId=584158935", "20220820" ) 
	if Date() >= CTOD("20/08/2022")
		MsgAlert(STR0126, STR0127) //"Rotina descontinuada" # "Alerta"
		Return
	Endif			
EndIf

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

//-----------------------------------------------------------
// Executa duas vezes, caso haja comparação de fluxos
//-----------------------------------------------------------
If cCodFlxCmp # Nil
	nLoop := 2     
Endif
//-----------------------------------------------------------
// Perguntas da rotina
//-----------------------------------------------------------
AAdd(aPerguntas,{ 1, STR0004, cNatEntDe  ,"@!",'.T.',"SED",".T.",60, .F.})	//1 - "DaNatureza"
AAdd(aPerguntas,{ 1, STR0005, cNatEntAte,"@!",'.T.',"SED",".T.",60,.F.})	//2 - "Até Natureza"
AAdd(aPerguntas,{ 1, STR0006, dDataIni,"", "VldPerFlx()","",".T.",50,.T.})	//3 - "Data inicial"
AAdd(aPerguntas,{ 1, STR0007, dDataFin,"", "VldPerFlx()","",".T.",50,.T.})	//4 - "Data final"
AAdd(aPerguntas,{ 3, STR0008, 2, aTipos, 100,, .T. })						//5 - "Mostra periodos em"
AAdd(aPerguntas,{ 5, STR0009, .T., 100,, .T. })								//6 - "Considera pedidos de venda"
AAdd(aPerguntas,{ 5, STR0010, .T., 100,, .T. })								//7 - "Considera pedidos de compra"
AAdd(aPerguntas,{ 5, STR0011, .T., 100,, .T. })								//8 - "Considera aplicações/empréstimos"
AAdd(aPerguntas,{ 5, STR0012, .T., 100,, .T. })								//9 - "Considera saldos bancários"
AAdd(aPerguntas,{ 2, STR0013, 1, {STR0014, STR0015, STR0016}, 100,"mv_par09", .T. }) //10 - "Tipos de saldo"###"1-Normais"###"2-Conciliados"###"3-Não conciliados"
AAdd(aPerguntas,{ 1, STR0059, cMoePam, 		"@!",'ExistCpo("CTO")',"CTO",".T.",cTamMoed,.T.}) //11 - "Moeda"
//-----------------------------------------------------------
// Se Houver Gestão Corporativa e o compartilhamento for "Exclusivo", existirá o filtro para considerar filiais
//-----------------------------------------------------------
AAdd(aPerguntas,{ 3, STR0017, 2, {STR0018, STR0019}, 100,, .T., "FWModeAccess('FIV') == 'E'" }) //12 - "Considera Filiais?"

//Naturezas Analíticas e Sintéticas
AAdd(aPerguntas,{ 2, STR0099 ,2, {STR0097,STR0098}, 100,, .T., "SED->(FieldPos('ED_PAI')) > 0" }) //13 - Exibe Nat. Simtéticas? 1-Sim/2-Não
aAdd(aPerguntas,{ 2, STR0115, 2 ,{STR0097,STR0098}, 100,/*Validacao*/, .T.}) //14 - Seleciona CC? 1-Sim/2-Não
aAdd(aPerguntas,{ 1, STR0116," " ,"",".T.","",".T.",20,.F.}) //15 - Do risco
aAdd(aPerguntas,{ 1, STR0117," ","",".T.","",".T.",20,.F.})//16 - Até risco  
If lGravada .Or. ParamBox( aPerguntas,STR0020,aParam,,,,,,,FunName(),.T.,.T.) //"Considera filiais"###"Sim"###"Não"###"Parâmetros do Fluxo de Caixa - Financeiro"
	//-----------------------------------------------------------
	// Garantindo que os valores do parambox estarão nas devidas variáveis MV_PARXX
	//-----------------------------------------------------------
	For nParCont := 1 To Len(aParam)
		&("MV_PAR"+CVALTOCHAR(nParCont)) := aParam[nParCont]
	Next nParCont
	
	//Seleciona os centros de custos.
	If If(Type("MV_PAR14")=="N", MV_PAR14,Val(Left(MV_PAR14,1))) == 1
		cNatIni  := MV_PAR01	 
		aCCustos := F024Mark(.T.)
		MV_PAR01 := cNatIni
	EndIf	
	//-----------------------------------------------------------
	// Caso o compartilhamento de tabelas não seja Exclusivo, inibe a seleção de filiais na Consulta do Fluxo de Caixa
	//-----------------------------------------------------------
	If Len(aParam) < 12
		MV_PAR12 := 2
	EndIf
	
	//Ajusta os parâmetros de data, caso estejam invertidas
	If MV_PAR03 > MV_PAR04
		MV_PAR04 := MV_PAR03 	
	EndIf
	
	//-----------------------------------------------------------
	// Caso o compartilhamento de tabelas não seja Exclusivo, inibe a seleção de filiais na Consulta do Fluxo de Caixa
	//-----------------------------------------------------------
	If lGravada .Or. VldPerFlx()
		lPAR10Num := Type("MV_PAR10")=="N"
		lPAR13Num := Type("MV_PAR13")=="N"
		For nCount := 1 To nLoop
			//-----------------------------------------------------------
			// Se for uma consulta gravada
			//-----------------------------------------------------------
			If lGravada
				CarregaParam(If(nCount==1,cCodFlx, cCodFlxCmp))					
			Else
				//-----------------------------------------------------------
				// Ajusta parametro 09 (Tipos de saldos), pois a ParamBox hora retorna Caracter, hora retorna numerico,
				// por ser um parametro tipo Combo
				//-----------------------------------------------------------
				MV_PAR10 := Iif(lPAR10Num, MV_PAR10,Val(Left(MV_PAR10,1)))
				
				//Ajusta o paramentro 13
				MV_PAR13 := Iif(lPAR13Num, MV_PAR13,Val(Left(MV_PAR13,1)))
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
				aSelFil := {FWGETCODFILIAL}
			Endif			
			If lRet
				If lGravada .Or. Len(aSelFil) > 0
					If !lGravada .And. (Len(aSelFil) > 0 .OR. MV_PAR06 .OR. MV_PAR07)
						//-------------------------------------------
						// Define estrutura arquivo temporario
						//-------------------------------------------
						DbSelectArea("FIV")
						If(_oFINC0248 <> NIL)
							_oFINC0248:Delete()
							_oFINC0248 := NIL
						EndIf

						_oFINC0248 := FwTemporaryTable():New(cAliasFIY)
						_oFINC0248:SetFields(FIV->(DbStruct()))
						_oFINC0248:AddIndex("1",{"FIV_FILIAL","FIV_NATUR","FIV_MOEDA","FIV_TPSALD"})
						_oFINC0248:Create()
					EndIf
					//-------------------------------------------
					// Processa o fluxo de caixa por filial selecionada.
					//-------------------------------------------
					For nX := 1 To Len(aSelFil)
						FC24CriaTMP()
						//-------------------------------------------
						// Troca a filial corrente para a filial de processamento
						//-------------------------------------------
						cFilAnt := aSelFil[nX]
						//-------------------------------------------
						// Processa os pedidos de compra
						//-------------------------------------------
						If !lGravada .And. MV_PAR07
							If nX == 1 .Or. FWModeAccess("SC7") == "E"
								Processa( { |lEnd| Fc022Compr(MV_PAR05,MV_PAR03,MV_PAR04,cAliasFIY,cAliasTRB,aPeriodos,/*cAliasAna*/ ,aCCustos) }, STR0022 ) //"Processando pedidos de compra"
							EndIf
						EndIf
						//-------------------------------------------
						// Processa os pedidos de venda
						//-------------------------------------------
						If !lGravada .And. MV_PAR06
							If nX == 1 .Or. FWModeAccess("SC5") == "E"
								Processa( { |lEnd| Fc022Venda(MV_PAR05, MV_PAR03, MV_PAR04, cAliasFIY,cAliasTRB,aPeriodos,/*cAliasAna*/, aCCustos, MV_PAR15,MV_PAR16) }, STR0023 ) //"Processando pedidos de venda"
							EndIf
						EndIf
						//-------------------------------------------
						// Processa aplicações e emprestimos
						//-------------------------------------------
						If !lGravada .And. MV_PAR08
							If nX == 1 .Or. FWModeAccess("SEH") == "E"
								Processa( { |lEnd| Fc022AplRes(MV_PAR05, MV_PAR03, MV_PAR04, cAliasFIY, cAliasTRB,aPeriodos) }, STR0024 ) //"Processando Aplicações/Empréstimos"
							EndIf
						EndIf
						//-------------------------------------------
						// Processa Saldos Iniciais
						//-------------------------------------------
						If MV_PAR09
							If nX == 1 .Or. FWModeAccess("SEH") == "E"
								Processa( { |lEnd| SaldosInicias(MV_PAR05,MV_PAR03-1,Str(MV_PAR10,1),IIf(nCount==1,cAliasTRB,cAliasTRB2),IIf(nCount==1,aPeriodos,aPeriodos2),aBancos) }, STR0025 ) //"Calculando saldos iniciais"
							EndIf
						Endif
						If nX == 1 .Or. FWModeAccess("FIY") == "E"
							Processa( {|lEnd| FlCxNatProc(lEnd,MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,cAliasFIY,lGravada,IIf(nCount==1,cCodFlx,cCodFlxCmp),MV_PAR11,IIf(nCount==1,cAliasTRB,cAliasTRB2),IIf(nCount==1,aPeriodos,aPeriodos2),.F., aCCustos) }, STR0026 ) //"Lendo saldos das naturezas"
						EndIf
					Next nX
				Endif
			Endif
		
			//Registra os dados de cada configuração de sintéticas de cada consulta
			aAdd(aConf,{Iif(nCount = 1,cAliasTRB,cAliasTRB2),MV_PAR13})
		Next nCount
		//-----------------------------------------------------------
		// Exibe o fluxo de caixa
		//-----------------------------------------------------------		
		TotalFluxo(cAliasTRB,aPeriodos)	
		If nLoop == 2
			TotalFluxo(cAliasTRB2,aPeriodos2)		
		EndIf
		
		For nCount := 1 to nLoop
			//MV_PAR13 
			If aConf[nCount][2] = 1 //Naturezas Sintéticas = 1 - Sim
				Processa( {|| F024TotNat(aConf[nCount][1])}, STR0100 ) //Totalizando Sintéticas	
			EndIf
		Next nCount
		MostraFluxo(MV_PAR03, MV_PAR04, cAliasFIY, lGravada,nLoop == 2,aParam,aPerguntas,cAliasTRB,aPeriodos,cAliasTRB2,aPeriodos2)
	Endif
Endif
cFilAnt := cFilOld
//-----------------------------------------------------------
// Apaga o arquivo temporario
//-----------------------------------------------------------
If !Empty(cAliasFIY)
	FWCLOSETEMP(cAliasTRB)		
EndIf
If !Empty(cAliasTRB)
	FWCLOSETEMP(cAliasTRB)
EndIf
If !Empty(cAliasTRB2)
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
Static Function VldPerFlx
Local lRet := .T.

//Valida se as datas estao coerentes

If MV_PAR03 > MV_PAR04
	lRet := .F.
	Alert(STR0107)
EndIf

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

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FlCxNatPro³ Autor ³ Claudio D. de Souza   ³ Data ³ 12/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processamento do Fluxo de Caixa por Natureza				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FlCxNatProc                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINC022  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FlCxNatProc(lEnd,cNatIni,cNatFin,dDtIni,dDtFin,nTipo,cAliasFIY,lGravada,cCodCons,cMoedPar,cAliasTRB,aPeriodos,lMvBco, aCCustos)
Local aArea			:= GetArea()
Local lAbat			:= .F.
Local dDtAux
Local cCarteira     	:= ""
Local cNatureza     	:= STR0057
Local cSequencia    	:= ""
Local cPeriodo      	:= ""
Local cPrefCpo			:= ""
Local nX				:= 0
Local cAliasTmp		:= ''
Default lMvBco 		:= .F.
Default aCCustos		:= {}
DEFAULT cMoedPar 		:= '01'

//-----------------------------------------------------------
// Verifica o tamanho do campo natureza e ajusta se necessário
//-----------------------------------------------------------
cNatIni := PADR(cNatIni,Len(SED->ED_CODIGO)," ")
cNatFin := PADR(cNatFin,Len(SED->ED_CODIGO)," ")

cQuery:= "% %"


//-----------------------------------------------------------
// Seleciona os registros a serem processados
//-----------------------------------------------------------
FC24FilCust(aCCustos)  // A movimentação é feita online filtrada por centro de custo.	
cAliasTmp :=  _oFINC0245:oStruct:cAlias
cPrefCpo := "TMP"
//

If cPrefCpo == "FIV" .AND. FIV->FIV_ABATI > 0
	lAbat := .T.
EndIf

//-----------------------------------------------------------
// Coloca os dados do Fluxo em todas as colunas
//-----------------------------------------------------------
dbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())
While (cAliasTmp)->(!Eof())
	//-----------------------------------------------------------
	// Cria registro no arquivo temporario, para posterior gravacao
	//-----------------------------------------------------------
	If !Empty(cAliasFIY) .And. Select(cAliasFIY) > 0
		RecLock(cAliasFIY,.T.)
		For nX := 1 To (cAliasTmp)->(FCount())
			If (cAliasFIY)->(FieldPos((cAliasTmp)->(FieldName(nX)))) > 0
				(cAliasFIY)->(FieldPut((cAliasFIY)->(FieldPos((cAliasTmp)->(FieldName(nX)))),(cAliasTmp)->(FieldGet(nX))))
			EndIf
		Next nX
	EndIf     
	
	//-----------------------------------------------------------
	// Atualiza o arquivo temporario do fluxo de caixa
	//-----------------------------------------------------------
	dDtAux := STOD((cAliasTmp)->&(cPrefCpo+"_DATA"))
	cPeriodo   := Periodo(nTipo,dDtAux, dDtIni, dDtFin)
	If !Empty((cAliasTmp)->(TMP_DESC))
		cNatureza  := (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_NATUR")))+" - "+(cAliasTmp)->(TMP_DESC)	
	EndIf	
	cCarteira  := (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_CARTEI")))
	If Empty(cCarteira)
		Help(" ",1,"CARTNTBRCO",,STR0095+ cNatureza + CRLF + CRLF + STR0096,1,0) //"Existem saldos sem a informação da carteira para a natureza " + Alltrim(&(cPrefCpo+"_NATUR")) //"Acesse o cadastro de Naturezas, informe sua condição e execute o Reprocessamento dos saldos."                                                                                                                                                                                                                                                                                                                                                                                                                      
		Exit
	EndIf
	cSequencia := IIf(cCarteira=="R","001","002")

	DbSelectArea(cAliasTRB)
	DbSetOrder(1)
	If !MsSeek(cSequencia+cCarteira+cNatureza)
		RecLock(cAliasTRB,.T.)
	Else
		RecLock(cAliasTRB)
	EndIf
	(cAliasTRB)->CART := cCarteira
	(cAliasTRB)->SEQ  := cSequencia
	(cAliasTRB)->NAT  := cNatureza	
	
	//Armazena os codigos da natureza e da superior
	(cAliasTRB)->NATPAI := (cAliasTmp)->(TMP_PAI)

	nX := aScan(aPeriodos,cPeriodo)

	If nX <> 0           
			
		Do Case
			Case (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_TPSALD"))) == "1" // Saldo Orcado
				(cAliasTRB)->(FieldPut(FieldPos("ORC"+StrZero(nX,3)) ,FieldGet(FieldPos("ORC"+StrZero(nX,3)))+(cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_VALOR")))))
			Case (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_TPSALD"))) == "2" // Saldo Previsto
				(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),FieldGet(FieldPos("PREV"+StrZero(nX,3)))+(cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_VALOR")))+Iif(lAbat,(cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_ABATI"))),0)))
			Case (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_TPSALD"))) == "3" // Saldo Realizado
				(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),FieldGet(FieldPos("REAL"+StrZero(nX,3)))+(cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_VALOR")))))
			
			//Linha Base | Liinha Saldo -> Integração RM x TOP
			Case (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_TPSALD"))) == "B" // Projeto - Linha Base
				(cAliasTRB)->(FieldPut(FieldPos("LNBASE"+StrZero(nX,3)) ,FieldGet(FieldPos("LNBASE"+StrZero(nX,3)))+(cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_VALOR")))))
			Case (cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_TPSALD"))) == "S" // Projeto - Saldo
				(cAliasTRB)->(FieldPut(FieldPos("LNSALDO"+StrZero(nX,3)) ,FieldGet(FieldPos("LNSALDO"+StrZero(nX,3)))+(cAliasTmp)->(FieldGet(FieldPos(cPrefCpo+"_VALOR")))))	
			//
		EndCase
				
	EndIf      
		
	MsUnLock((cAliasTRB))
	dbSelectArea(cAliasTMP)
	(cAliasTMP)->(DbSkip())
EndDo
                
dbSelectArea(cAliasTMP)
DbCloseArea()
If(_oFINC0245 <> NIL)

	_oFINC0245:Delete()
	_oFINC0245 := NIL

EndIf

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
Local dDtAux	:= dDtIni
Local cPeriodo	:= ""
Local aStruct   := {}
//-----------------------------------------------------------
// Define a estrutura inicial do arquivo temporario de exibição do fluxo
//-----------------------------------------------------------
aadd(aStruct,{"SEQ","C",03,0})
aadd(aStruct,{"CART","C",01,0})
aadd(aStruct,{"NAT","C",Len(SED->ED_CODIGO)+Len(SED->ED_DESCRIC)+10,0})
aadd(aStruct,{"NATPAI","C",Len(SED->ED_CODIGO),0})

//-----------------------------------------------------------
// Calcula o numero de periodos. Maximo 999
//-----------------------------------------------------------
While dDtAux <= dDtFinal
	cPeriodo := Periodo(nTipo, dDtAux, dDtIni, dDtFinal)
	If Ascan( aPeriodos, cPeriodo ) == 0
		aadd(aPeriodos,cPeriodo)

		aadd(aStruct,{"ORC" +StrZero(Len(aPeriodos),3),"N",17,2})
		aadd(aStruct,{"PREV"+StrZero(Len(aPeriodos),3),"N",17,2})
		aadd(aStruct,{"REAL"+StrZero(Len(aPeriodos),3),"N",17,2})
		If lIntTOP
			aAdd(aStruct,{"LNBASE" + StrZero(Len(aPeriodos),3) ,"N",17,2})
			aAdd(aStruct,{"LNSALDO"+ StrZero(Len(aPeriodos),3) ,"N",17,2})
		EndIf	  		
	EndIf        
	
	dDtAux ++
EndDo

aadd(aStruct,{"ORCTOT" ,"N",17,2})
aadd(aStruct,{"PREVTOT","N",17,2})
aadd(aStruct,{"REALTOT","N",17,2})

//-----------------------------------------------------------
// Cria o arquivo de trabalho
//-----------------------------------------------------------
If(_oFINC0246 <> NIL)

	_oFINC0246:Delete()
	_oFINC0246 := NIL

EndIf

_oFINC0246 := FwTemporaryTable():New(cAliasTRB)
_oFINC0246:SetFields(aStruct)
_oFINC0246:AddIndex("1",{"SEQ","CART","NAT"})
_oFINC0246:AddIndex("2",{"ORCTOT","PREVTOT"})
_oFINC0246:AddIndex("3",{"NATPAI"})
_oFINC0246:Create()

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

Do Case
	Case nTipo == 1 // Dias
		cPeriodo := Left(DTOC(dDtAux),5)
	Case nTipo == 2 // Semanas
		cPeriodo := Semana(dDtAux, dDtIni, dDtFin)
	Case nTipo == 3 // Meses
		cPeriodo := MesExtenso(Month(dDtAux)) + "/" + StrZero(Year(dDtAux),4)
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
Static Function MostraFluxo(dDtIni, dDtFin, cAliasFIY, lGravada,lComp, aParam, aPerguntas,cAliasTRB,aPeriodos,cAliasTRB2,aPeriodos2,cAliasAna,cCodFlx,cCodFlxCmp)
Local aSize
Local aObjects := {}
Local aInfo
Local aPosObj
Local oDlg
Local aHeader  := {STR0031} //"Natureza"
Local aHeader2 := {STR0031} //"Natureza"
Local nCont := 3 
Local nX
Local cCodigo, cHora := Left(Time(),5)
Local aButton := {}
Local oTela
Local cIdBrowse
Local cIdRodape
Local oPanel1
Local oPanel2
Local oColumn

DEFAULT lComp := .F.
Default cCodFlx := ''
Default cCodFlxCmp := ''
//-----------------------------------------------------------
// Define os botoes da barra de ferramentas
//-----------------------------------------------------------
If lIntTOP
	nCont := 5
EndIf	
If lGravada
	aButton := { { "RELATORIO", { || Fc022Rel(aPeriodos,aHeader,cAliasTRB,aPeriodos2,aHeader2,cAliasTRB2,lComp)  }, STR0032,STR0033 }} //"Imprime a consulta atual"###"Relatório"
Else
	aButton := { { "SALVAR", { || Fc022Grava(cAliasFIY,@cCodigo, dDataBase, cHora, aParam, aPerguntas)  }, STR0034,STR0035 },; //"Salva o fluxo para consulta posterior"###"Salvar"
	{ "RELATORIO", { || Fc022Rel(aPeriodos,aHeader,cAliasTRB,aPeriodos2,aHeader2,cAliasTRB2,.F.)  }, STR0032,STR0033 }} //"Imprime a consulta atual"###"Relatório"
EndIf
                  
//-----------------------------------------------------------
// Preenche o Header do Browse
//-----------------------------------------------------------
For nX := 1 To Len(aPeriodos)

	aAdd(aHeader,STR0036+" "+aPeriodos[nX]) //"Orçado"
	aAdd(aHeader,STR0037+" "+aPeriodos[nX]) //"Previsto"
	aAdd(aHeader,STR0038+" "+aPeriodos[nX]) //"Realizado"
	If lIntTOP
		aAdd(aHeader,STR0122 + " " + aPeriodos[nX])	//Projeto – Linha Base
		aAdd(aHeader,STR0123	+ " " + aPeriodos[nX])	//Projeto - Saldo	
	EndIf
	
Next nX	
If lComp
	For nX := 1 To Len(aPeriodos2)
		aadd(aHeader2,STR0036+" "+aPeriodos2[nX]) //"Orçado"
		aadd(aHeader2,STR0037+" "+aPeriodos2[nX]) //"Previsto"
		aadd(aHeader2,STR0038+" "+aPeriodos2[nX]) //"Realizado"
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
	
	DEFINE FWBROWSE oFluxo DATA TABLE ALIAS cAliasTRB NO SEEK NO CONFIG OF oPanel1
	ADD COLUMN oColumn DATA {|| Iif((cAliasTRB)->CART <> "Z",MascNat(SubStr((cAliasTRB)->NAT,1,TamSX3("ED_CODIGO")[1]))+" "+SubStr((cAliasTRB)->NAT,At("-",(cAliasTRB)->NAT)),(cAliasTRB)->NAT)} TITLE aHeader[1] SIZE 30 ALIGN 1 HEADERCLICK { || }  OF oFluxo
	For nX := 1 To Len(aPeriodos)
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->ORC'+StrZero(nX,3)+',"@e 999,999,999,999.99") }') TITLE aHeader[((nX-1)*3)+2] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->PREV'+StrZero(nX,3)+',"@e 999,999,999,999.99") }') TITLE aHeader[((nX-1)*3)+3] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->REAL'+StrZero(nX,3)+',"@e 999,999,999,999.99") }') TITLE aHeader[((nX-1)*3)+4] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo
	Next nX
	ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->ORCTOT ,"@e 999,999,999,999.99") }') TITLE STR0036+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Orçado"
	ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->PREVTOT,"@e 999,999,999,999.99") }') TITLE STR0037+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Previsto"
	ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->REALTOT,"@e 999,999,999,999.99") }') TITLE STR0038+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Realizado"

	DEFINE FWBROWSE oFluxo2 DATA TABLE ALIAS cAliasTRB2 NO SEEK NO CONFIG OF oPanel2
	ADD COLUMN oColumn DATA {|| Iif((cAliasTRB2)->CART <> "Z",MascNat(SubStr((cAliasTRB2)->NAT,1,TamSX3("ED_CODIGO")[1]))+" "+SubStr((cAliasTRB2)->NAT,At("-",(cAliasTRB2)->NAT)),(cAliasTRB2)->NAT) } TITLE aHeader2[1] SIZE 30 ALIGN 1 HEADERCLICK { || }  OF oFluxo2
	For nX := 1 To Len(aPeriodos2)
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->ORC'+StrZero(nX,3)+',"@e 999,999,999,999.99") }') TITLE aHeader2[((nX-1)*3)+2] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->PREV'+StrZero(nX,3)+',"@e 999,999,999,999.99") }') TITLE aHeader2[((nX-1)*3)+3] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->REAL'+StrZero(nX,3)+',"@e 999,999,999,999.99") }') TITLE aHeader2[((nX-1)*3)+4] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2
	Next nX
	ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->ORCTOT ,"@e 999,999,999,999.99") }') TITLE STR0036+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2 //"Total"###"Orçado"
	ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->PREVTOT,"@e 999,999,999,999.99") }') TITLE STR0037+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2 //"Total"###"Previsto"
	ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB2)->REALTOT,"@e 999,999,999,999.99") }') TITLE STR0038+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo2 //"Total"###"Realizado"	
		
Else                    
	    
	DEFINE FWBROWSE oFluxo DATA TABLE ALIAS cAliasTRB NO SEEK NO CONFIG OF oDlg
	ADD COLUMN oColumn DATA {|| Iif((cAliasTRB)->CART <> "Z",MascNat(SubStr((cAliasTRB)->NAT,1,TamSX3("ED_CODIGO")[1]))+" "+SubStr((cAliasTRB)->NAT,At("-",(cAliasTRB)->NAT)),(cAliasTRB)->NAT) } TITLE aHeader[1] SIZE 30 ALIGN 1 HEADERCLICK { || }  OF oFluxo
	For nX := 1 To Len(aPeriodos)
		//Colunas de integração RM x TOP
		If lIntTOP
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->LNBASE' +StrZero(nX,3)+',"@e 999,999,999,999.99") }') TITLE aHeader[((nX-1)* nCont)+ LBASE ] SIZE 5 ALIGN 2 HEADERCLICK { || }  OF oFluxo
			ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->LNSALDO'+StrZero(nX,3)+',"@e 999,999,999,999.99") }') TITLE aHeader[((nX-1)* nCont)+ LSALDO] SIZE 5 ALIGN 2 HEADERCLICK { || }  OF oFluxo
		EndIf
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->ORC'+StrZero(nX,3)+',"@e 999,999,999,999.99") }') TITLE aHeader[((nX-1)* nCont)+2] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->PREV'+StrZero(nX,3)+',"@e 999,999,999,999.99") }') TITLE aHeader[((nX-1)* nCont)+3] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo
		ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->REAL'+StrZero(nX,3)+',"@e 999,999,999,999.99") }') TITLE aHeader[((nX-1)* nCont)+4] SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo
	Next nX
	ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->ORCTOT ,"@e 999,999,999,999.99") }') TITLE STR0036+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Orçado"
	ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->PREVTOT,"@e 999,999,999,999.99") }') TITLE STR0037+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Previsto"
	ADD COLUMN oColumn DATA &('{|| TransForm((cAliasTRB)->REALTOT,"@e 999,999,999,999.99") }') TITLE STR0038+" "+STR0030 SIZE 15 ALIGN 2 HEADERCLICK { || }  OF oFluxo //"Total"###"Realizado"
	
EndIf

oFluxo:SetBlkBackColor( { || IIf((cAliasTRB)->CART == "Z" , CLR_GREEN, Nil ) } )
oFluxo:SetBlkColor( { || IIf((cAliasTRB)->CART == "Z" , CLR_WHITE, Nil ) } )

//-----------------------------------------------------------
// Cria o Grid do 2o. Fluxo
//-----------------------------------------------------------
If lComp
	oFluxo2:SetBlkBackColor( { || IIf((cAliasTRB2)->CART == "Z" , CLR_GREEN, Nil ) } )
	oFluxo2:SetBlkColor( { || IIf((cAliasTRB2)->CART == "Z" , CLR_WHITE, Nil ) } )
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
Static Function SaldosInicias(nTipo,dData,cTipoSaldo,cAliasTRB,aPeriodos,aBancos)
Local aArea       := GetArea()
Local cAliasSE8   := GetNextAlias()
Local nSaldoTotal := 0
Local nX          := 0
Local nTrbSaldo   := 0
Local nMoedaBco   := 0
Local cCodIn	  := "%%"

BeginSql Alias cAliasSE8
	COLUMN E8_DTSALAT AS DATE

	SELECT SA6.*,E8_FILIAL,E8_DTSALAT,E8_BANCO,E8_AGENCIA,E8_CONTA,E8_SALATUA,E8_SALRECO,E8_SALATUA
	FROM %Table:SA6% SA6,
		%Table:SE8% SE8
	WHERE
		SA6.A6_FILIAL = %xFilial:SA6% AND
		%Exp:cCodIn%
		SA6.A6_FLUXCAI IN('S',' ') AND 
		SA6.%NotDel% AND
		SE8.E8_FILIAL = %xFilial:SE8% AND
		SE8.E8_BANCO = SA6.A6_COD AND 
		SE8.E8_AGENCIA = SA6.A6_AGENCIA AND
		SE8.E8_CONTA = SA6.A6_NUMCON AND
		SE8.%NotDel% AND
		SE8.E8_DTSALAT = ( SELECT MAX(TMP.E8_DTSALAT)
							FROM %Table:SE8% TMP
							WHERE 
								TMP.E8_FILIAL = %xFilial:SE8% AND
								TMP.E8_BANCO = SA6.A6_COD AND 
								TMP.E8_AGENCIA = SA6.A6_AGENCIA AND
								TMP.E8_CONTA = SA6.A6_NUMCON AND
								TMP.E8_DTSALAT <= %Exp:dData% AND
								TMP.%NotDel% )
        ORDER BY E8_FILIAL,E8_BANCO,E8_AGENCIA,E8_CONTA,E8_DTSALAT
EndSql
DbSelectArea(cAliasSE8)
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
DbSelectArea(cAliasSE8)
dbCloseArea()
DbSelectArea("SE8")
//-----------------------------------------------------------
// Atualiza o arquivo temporario do fluxo de caixa
//-----------------------------------------------------------
RecLock(cAliasTRB,.T.)
(cAliasTRB)->SEQ := "000"
(cAliasTRB)->CART:= "Z"
(cAliasTRB)->NAT := STR0021 //"Saldos iniciais"
//For nX := 1 To Len(aPeriodos)
FieldPut(FieldPos("PREV"+StrZero(1,3)),nSaldoTotal)	
//Next nX
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
Local oReport
Local aParam := {}

If	!lPergunta .Or.;
	ParamBox( {	{ 3, STR0046, 2, { STR0047, STR0048}, 100,, .T. } },; //"Escolha qual fluxo imprimir"###"Fluxo 1"###"Fluxo 2"
	STR0049,aParam,,,,,,,ProcName(),.T.,.T.) //"Impressão do Fluxo de Caixa"
	
	If !lPergunta .Or. MV_PAR01 == 1
		oReport := ReportDef(aPeriodos,cAliasTRB,aHeader)
	Else
		oReport := ReportDef(aPeriodos2,cAliasTRB2,aHeader2)
	Endif
	oReport:PrintDialog()
Endif

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
Static Function ReportDef(aPeriodos,cAliasTRB,aHeader)
Local oReport
Local oSection
Local nX  := 0

oReport := TReport():New("FINC022",STR0050 + " - " + DtoC(MV_PAR03) + STR0040 + DtoC(MV_PAR04) ,"",{|oReport| Fc022Imp(oReport,cAliasTRB,aPeriodos)}, STR0051) //"Fluxo de Caixa por Natureza"###"Imprime relatório da consulta Fluxo de Caixapor Natureza"
oReport:SetLandscape(.T.)

//-------------------------------------------------------------------------------//
// Parcelas
DEFINE SECTION oSection OF oReport TITLE STR0052 TOTAL IN COLUMN           //"Movimentos"
DEFINE CELL NAME STR0031 OF oSection SIZE 50 TITLE STR0031 //"Natureza"###"Natureza"

oSection:Cell(STR0031):SetBlock( { || Iif((cAliasTRB)->CART <> "Z",MascNat(SubStr((cAliasTRB)->NAT,1,TamSX3("ED_CODIGO")[1]))+" "+SubStr((cAliasTRB)->NAT,At("-",(cAliasTRB)->NAT)),(cAliasTRB)->NAT) } ) //"Natureza"

For nX := 1 To Len(aPeriodos)
	DEFINE CELL NAME "CEL"+Alltrim(Str((nX*3)-2)) OF oSection SIZE 20 TITLE aHeader[(nX*3)-1]			
	oSection:Cell("CEL"+Alltrim(Str((nX*3)-2))):SetBlock( &('{|| TransForm((cAliasTRB)->ORC'+StrZero(nX,3)+',"@e 999,999,999,999.99") }') )
	DEFINE CELL NAME "CEL"+Alltrim(Str((nX*3)-1)) OF oSection SIZE 20 TITLE aHeader[(nX*3)]			
	oSection:Cell("CEL"+Alltrim(Str((nX*3)-1))):SetBlock( &('{|| TransForm((cAliasTRB)->PREV'+StrZero(nX,3)+',"@e 999,999,999,999.99") }') )
	DEFINE CELL NAME "CEL"+Alltrim(Str((nX*3))) OF oSection SIZE 20 TITLE aHeader[(nX*3)+1]			
	oSection:Cell("CEL"+Alltrim(Str((nX*3)))):SetBlock( &('{|| TransForm((cAliasTRB)->REAL'+StrZero(nX,3)+',"@e 999,999,999,999.99") }') )
Next

DEFINE CELL NAME "CELTOT1" OF oSection SIZE 20 TITLE STR0036+" "+STR0030 //"Total"###"Orçado"
oSection:Cell("CELTOT1"):SetBlock( &('{|| TransForm((cAliasTRB)->ORCTOT,"@e 999,999,999,999.99") }') )
DEFINE CELL NAME "CELTOT2" OF oSection SIZE 20 TITLE STR0037+" "+STR0030 //"Total"###"Previste"
oSection:Cell("CELTOT2"):SetBlock( &('{|| TransForm((cAliasTRB)->PREVTOT,"@e 999,999,999,999.99") }') )
DEFINE CELL NAME "CELTOT3" OF oSection SIZE 20 TITLE STR0038+" "+STR0030 //"Total"###"Realizado"
oSection:Cell("CELTOT3"):SetBlock( &('{|| TransForm((cAliasTRB)->REALTOT,"@e 999,999,999,999.99") }') )
	
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

oReport:SetMeter((cAliasTRB)->(LastRec()))
            
oSection:Init()

dbSelectArea(cAliasTRB)
(cAliasTRB)->( dbGotop() )

nx := 0

While (cAliasTRB)->( !Eof() )
	If oReport:Cancel()
		Exit
	EndIf

	oReport:IncMeter()
	oSection:PrintLine()	
	dbSelectArea(cAliasTRB)
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
Local lRet := .F.
                                                                                       
cHora := StrTran(cHora, ":", "")

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
±±³ Uso		 ³ FINC022  												     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc022Inc(cAliasFIY, cCodigo, dData, cHora, aParam, aPerguntas)
Local nX
Local cCampo
Local nPosCpoFiy
Local cParametros := ""
Local lRet := .T.
Local PulaLinha := CHR(13)+CHR(10)

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

// GRava os parametros
MSMM(FIX->FIX_CODPAR,,,cParametros,1,,,"FIX","FIX_CODPAR")
MsUnlock()
FkCommit()

(cAliasFIY)->(DbGotop())
While (cAliasFIY)->(!Eof())
	If FIY->(MsSeek(xFilial("FIY")+cCodigo+(cAliasFIY)->(FIV_NATUR+FIV_MOEDA+FIV_TPSALD+FIV_CARTEI+DTOS(FIV_DATA))))
		RecLock("FIY",.F.)
		FIY->FIY_VALOR += (cAliasFIY)->FIV_VALOR
	Else
		RecLock("FIY",.T.)
		For nX := 1 To (cAliasFIY)->(fCount())
			cCampo := StrTran((cAliasFIY)->(FieldName(nX)), "FIV", "FIY")
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
Local nFinLin		:= 0
Local nAjuste		:= 0 

Default aParam := {}

FIX->(MsSeek(xFilial("FIX")+cCodFlx))
cParametros := MSMM( FIX->FIX_CODPAR,,,,3)
nLinhas := MlCount(cParametros)

For nX := 1 to nLinhas
	cLinha := Alltrim(MemoLine(cParametros,,nX))
			    
	nAt := At("=", cLinha)
	If nAt > 0
		cMvPar := SubStr(cLinha, nAt-9, 8)
		If At(" - ", cLinha) > 0
			xCont := SubStr(cLinha, nAt+1,3)
		Else
			xCont := SubStr(cLinha, nAt+1)
		Endif
		
		Do Case
			Case UPPER(cMvPar) $ "MV_PAR03|MV_PAR04"
				xCont := Ctod(xCont)
			Case UPPER(cMvPar) $ "MV_PAR05|MV_PAR10|MV_PAR13"
				xCont := Val(xCont)
			Case UPPER(cMvPar) $ "MV_PAR06|MV_PAR07|MV_PAR08|MV_PAR09"
				xCont := &(xCont)
		EndCase
		SetPrvt(cMvPar)
		&(cMvPar) := xCont
	EndIf

	//Ajuste para comparação de consultas gravadas sem Analítica X Sintética
	If nLinhas < 13
		SetPrvt(MV_PAR13)
		MV_PAR13 := 2 //Padrão 2-Não			
	EndIf
		
Next

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
±±³ Uso		 ³ FINC022  												  				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc022Compr(nTipo,dDtIni,dDtFin,cAliasFIY,cAliasTRB,aPeriodos,cAliasAna,aCCustos)
Local aArea       := GetArea()
Local nX          := 0
Local nY          := 0
Local cOldMvPAr03 := MV_PAR03
Local cPeriodo    := ""
Local cDescNat    := ""

//-----------------------------------------------------------
// Variaveis utilizadas pela rotina Fc020Compra()
//-----------------------------------------------------------
PRIVATE aCompras  := {}
PRIVATE adCompras := {}

Default aCCustos := {}
MV_PAR03 := 1 // Variavel private usada na rotina Fc020Compr, que tem seu conteudo diferente da rotina atual
Fc020Compra(,,.F.,1,,cFilAnt, cFilAnt,/*cPedidos*/,/*lConsDtBase*/,aCCustos)
MV_PAR03 := cOldMvPAr03
//-----------------------------------------------------------
// Prepara os dados do fluxo de compras para exibição
//-----------------------------------------------------------
For nY := 1 To Len(aCompras)

	If aCompras[nY,1] <= dDtFin 
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
		//-----------------------------------------------------------
		// Atualiza o arquivo do fluxo
		//-----------------------------------------------------------		
		DbSelectArea(cAliasTRB)
		DbSetOrder(1)
		If !MsSeek("002"+"P"+cDescNat)
			RecLock(cAliasTRB,.T.)
		Else
			RecLock(cAliasTRB)
		EndIf
		(cAliasTRB)->CART := "P"
		(cAliasTRB)->SEQ  := "002"
		(cAliasTRB)->NAT  := If(Empty(cDescNat), STR0057, cDescNat)
		
		nX := aScan(aPeriodos,cPeriodo)
		If aCompras[nY,1] < dDtIni
			nX := 1
		EndIf				

		If nX <> 0
			If !lfluxSint  //Fluxo analitico, adiciona natureza no array aFluxAna                                                  
				If cAliasAna == "Zero"
					If Select(cAliasAna) <= 0
						CriaAna(@cAliasAna)
					EndIf
				EndIf
				If Select(cAliasAna) > 0
					DbSelectArea(cAliasAna)
					RecLock(cAliasAna,.T.)
					(cAliasAna)->ANA_NAT 	:= cDescNat
					(cAliasAna)->ANA_NPOS 	:= StrZero(((nX*3)-3+1)+2,3)
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
		FC24SldNat(/*cQuery*/, "SC7", "P", /*cSinal*/,/*nVlAbat*/, aCompras[nY,2],aCompras[nY,3],aCompras[nY,1])			
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
Static Function Fc022Venda(nTipo,dDtIni,dDtFin,cAliasFIY,cAliasTRB,aPeriodos,cAliasAna, aCCustos, cRiscoDe, cRiscoAte)
Local cOldMvPAr03 := MV_PAR03
Local cPeriodo    := ""
Local cDescNat    := ""
Local nX          := 0
Local nY          := 0

//-----------------------------------------------------------
// Variaveis utilizadas pela rotina Fc020Venda()
//-----------------------------------------------------------
PRIVATE aVendas  := {}
PRIVATE adVendas := {}
Default aCCustos := {}
Default cRiscoDe := ''
Default cRiscoAte:= ''
cOldMvPAr03 := MV_PAR03
MV_PAR03 := 1 // Variavel private usada na rotina Fc020Venda, que tem seu conteudo diferente da rotina atual
Fc020Venda(,,,.F.,1,,cFilAnt, cFilAnt,aCCustos, cRiscoDe, cRiscoAte)
MV_PAR03 := cOldMvPAr03
//-----------------------------------------------------------
// Prepara os dados do fluxo de venda para exibição
//-----------------------------------------------------------
SED->(DbSetOrder(1))
For nY := 1 To Len(aVendas)
	If aVendas[nY,1] <= dDtFin
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
		//-----------------------------------------------------------
		// Atualiza o arquivo do fluxo
		//-----------------------------------------------------------		
		DbSelectArea(cAliasTRB)
		DbSetOrder(1)
		If !MsSeek("001"+"R"+cDescNat)
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
			If !lfluxSint  //Fluxo analitico, adiciona natureza no array aFluxAna                                                  
				If cAliasAna == "Zero"
					If Select(cAliasAna) <= 0
						CriaAna(@cAliasAna)
					EndIf
				EndIf
				If Select(cAliasAna) > 0
					DbSelectArea(cAliasAna)
					RecLock(cAliasAna,.T.)
					(cAliasAna)->ANA_NAT 	:= Alltrim(aVendas[nY,3])+" - " + If(Empty(cDescNat), STR0057, cDescNat)
					(cAliasAna)->ANA_NPOS 	:= StrZero(((nX*3)-3+1)+2,3)
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
		FC24SldNat(/*cQuery*/, "SC6", "R", /*cSinal*/,/*nVlAbat*/, aVendas[nY,2],aVendas[nY,3],aVendas[nY,1])
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
Local cCodNatEmp
Local cCodNatApl
Local nMoeda := 1
Local nPosPeriodo
Local cPeriodo
Local cAplCotas := GetMv("MV_APLCAL4")
Local aCalc := {}

cNatResgEp := PadR(cNatResgEp,TamSX3("EH_NATUREZ")[1])
cNatResgAp := PadR(cNatResgAp,TamSX3("EH_NATUREZ")[1])

cCodNatEmp := cNatResgEp
cCodNatApl := cNatResgAp	

SED->(DbSetOrder(1))
SED->(MsSeek(xFilial("SED") + cCodNatEmp )) // Posiciona no SED para obter a descricao da natureza
cNatResgEp := cCodNatEmp + " - " + SED->ED_DESCRIC

SED->(MsSeek(xFilial("SED") + cCodNatApl )) // Posiciona no SED para obter a descricao da natureza
cNatResgAp := cCodNatApl + " - " + SED->ED_DESCRIC

While dDtAux <= dDtFin
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe Emprestimo a ser resgatado no dia ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SEH")
	dbSetOrder(2)
	dbSeek(xFilial("SEH")+"A",.T.)
	nRecSeh := Recno()
	While ( !Eof() .And. SEH->EH_FILIAL == xFilial("SEH") .And. SEH->EH_STATUS == "A" )
		If SEH->EH_APLEMP == "EMP" .And. dDtAux >= SEH->EH_DATA
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
				nEmprestimo := xMoeda(nA181VlDeb,1,nMoeda,dDtAux)
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
		If SEH->EH_APLEMP == "APL"  .And. dDtAux >= SEH->EH_DATA
	  		If (Empty(SEH->EH_DATARES) .And. dDtAux == SEH->EH_DATA) .Or.;
	  			(SEH->EH_DATARES == dDtAux)
				nAplicacao := xMoeda(SEH->EH_SALDO,1,nMoeda,dDtAux)
			Else
				nAplicacao := 0
			EndIf
			DbSelectArea("SE9")
			DbSetOrder(1)
			DbSeek(xFilial("SE9")+SEH->EH_CONTRAT+SEH->EH_BCOCONT+SEH->EH_AGECONT)
			DbSelectArea("SEH")
			If (Empty(SEH->EH_DATARES) .And. dDtAux == dDtIni) .Or. (SEH->EH_DATARES == dDtAux)
				aCalc := {}
				If !SEH->EH_TIPO $ cAplCotas
					aCalc :=	Fa171Calc(dDtAux)
				Else
					DbSelectArea("SE0")
					If MsSeek(xFilial("SE0")+SE9->(E9_BANCO+E9_AGENCIA+E9_CONTA+E9_NUMERO))
						aCalc	:=	Fa171Calc(dDtAux,SEH->EH_SLDCOTA,,,,SEH->EH_VLRCOTA,SE0->E0_VALOR,(SEH->EH_SLDCOTA * SE0->E0_VALOR))
					Endif	
				EndIf
				
				If !Empty(aCalc)
					nAplicacao += xMoeda((aCalc[5]-aCalc[2]-aCalc[3]-aCalc[4]),1,nMoeda,dDtAux)
				Endif
				
			EndIf
			If nAplicacao > 0
				//-----------------------------------------------------------
				// Atualiza o arquivo do fluxo
				//-----------------------------------------------------------		
				cPeriodo := Periodo(nTipo, dDtAux, dDtIni, dDtFin)
				DbSelectArea(cAliasTRB)
				DbSetOrder(1)
				If !MsSeek("002"+"R"+cNatResgAp)
					RecLock(cAliasTRB,.T.)
				Else
					RecLock(cAliasTRB)
				EndIf
				(cAliasTRB)->CART := "R"
				(cAliasTRB)->SEQ  := "002"
				(cAliasTRB)->NAT  := cNatResgAp
				
				nX := aScan(aPeriodos,cPeriodo)
				If nX == 0
					nX := 1
				EndIf		
				If nX <> 0
					(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),FieldGet(FieldPos("PREV"+StrZero(nX,3)))+nAplicacao))
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

//-----------------------------------------------------------------------
/*/{Protheus.doc} Fc022IncTrb

Função que incrementa o arq. temporario da FIV (saldos diarios)

@Author	Totvs
/*/
//------------------------------------------------------------------------
Static Function Fc022IncTrb(cCodNat, dData, nValor, cCarteira, cAliasFIY)	

	// Cria registro no arquivo temporario, para posterior gravacao, pois quando se processa por filiais deve-se ter o resultado da query 
	// para cada filial
	If !Empty(cAliasFIY)
		RecLock(cAliasFIY,.T.)
		(cAliasFIY)->FIV_FILIAL	:= xFilial("FIV")
		(cAliasFIY)->FIV_NATUR	:= cCodNat
		(cAliasFIY)->FIV_DATA	:= dData
		(cAliasFIY)->FIV_MOEDA	:= "01"
		(cAliasFIY)->FIV_VALOR	:= nValor
		(cAliasFIY)->FIV_TPSALD	:= "2"
		(cAliasFIY)->FIV_CARTEI	:= cCarteira
	Endif

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} TotalFluxo

Realiza a montagem e atualizacao dos totalizadores

@Author	Totvs
/*/
//------------------------------------------------------------------------
Static Function TotalFluxo(cAliasTRB,aPeriodos)
Local aArea    := GetArea()
Local aTotPer  := {}
Local nTotPrev := 0
Local nTotReal := 0
Local nTotOrc  := 0
Local nTotComp := 0
Local nX       := 0
Local lDecstPrv := SuperGetMv("MV_FLXPRVD",.T.,.F.) //117021	

//-----------------------------------------------------------
// Cria o Array de Totais por Carteira x Periodo
//-----------------------------------------------------------
aadd(aTotPer,Array(Len(aPeriodos))) //
aadd(aTotPer,Array(Len(aPeriodos)))
aadd(aTotPer,Array(Len(aPeriodos)))
aadd(aTotPer,Array(Len(aPeriodos)))
For nX := 1 To Len(aPeriodos)     
	If lIntTOP
		aTotPer[1][nX] := {0,0,0,0,0}
		aTotPer[2][nX] := {0,0,0,0,0}
		aTotPer[3][nX] := {0,0,0,0,0}
		aTotPer[4][nX] := {0,0,0,0,0}	
	Else
		aTotPer[1][nX] := {0,0,0}
		aTotPer[2][nX] := {0,0,0}
		aTotPer[3][nX] := {0,0,0}
		aTotPer[4][nX] := {0,0,0}
	EndIf
Next nX
//-----------------------------------------------------------
// Totaliza as colunas
//-----------------------------------------------------------
dbSelectArea(cAliasTRB)
dbGotop()
          
While !Eof()
	nTotPrev := 0
	nTotReal := 0
	nTotOrc  := 0	

	For nX := 1 To Len(aPeriodos)
		nTotOrc  += (cAliasTRB)->(FieldGet(FieldPos("ORC"+StrZero(nX,3))))	
		nTotPrev += (cAliasTRB)->(FieldGet(FieldPos("PREV"+StrZero(nX,3))))
		nTotReal += (cAliasTRB)->(FieldGet(FieldPos("REAL"+StrZero(nX,3))))
		If (cAliasTRB)->SEQ == "001"
			aTotPer[1][nX][1] += (cAliasTRB)->(FieldGet(FieldPos("ORC" +StrZero(nX,3))))
			aTotPer[1][nX][2] += (cAliasTRB)->(FieldGet(FieldPos("PREV"+StrZero(nX,3))))
			aTotPer[1][nX][3] += (cAliasTRB)->(FieldGet(FieldPos("REAL"+StrZero(nX,3))))
			If lIntTOP
				aTotPer[1][nX][4] += (cAliasTRB)->(FieldGet(FieldPos("LNBASE" +StrZero(nX,3))))
				aTotPer[1][nX][5] += (cAliasTRB)->(FieldGet(FieldPos("LNSALDO"+StrZero(nX,3))))
			EndIf
		ElseIf (cAliasTRB)->SEQ == "002"
			aTotPer[2][nX][1] += (cAliasTRB)->(FieldGet(FieldPos("ORC" +StrZero(nX,3))))
			aTotPer[2][nX][2] += (cAliasTRB)->(FieldGet(FieldPos("PREV"+StrZero(nX,3))))
			aTotPer[2][nX][3] += (cAliasTRB)->(FieldGet(FieldPos("REAL"+StrZero(nX,3))))
			If lIntTOP
				aTotPer[2][nX][4] += (cAliasTRB)->(FieldGet(FieldPos("LNBASE" +StrZero(nX,3))))
				aTotPer[2][nX][5] += (cAliasTRB)->(FieldGet(FieldPos("LNSALDO"+StrZero(nX,3))))
			EndIf
		ElseIf (cAliasTRB)->SEQ == "000"
			aTotPer[3][nX][1] += (cAliasTRB)->(FieldGet(FieldPos("ORC" +StrZero(nX,3))))
			aTotPer[3][nX][2] += (cAliasTRB)->(FieldGet(FieldPos("PREV"+StrZero(nX,3))))
			aTotPer[3][nX][3] += (cAliasTRB)->(FieldGet(FieldPos("REAL"+StrZero(nX,3))))
			If lIntTOP
				aTotPer[3][nX][4] += (cAliasTRB)->(FieldGet(FieldPos("LNBASE" +StrZero(nX,3))))
				aTotPer[3][nX][5] += (cAliasTRB)->(FieldGet(FieldPos("LNSALDO"+StrZero(nX,3))))
			EndIf				
		EndIf
	Next nX
	If lDecstPrv //117021
		nTotPrev -= IIf(nTotPrev < 0 .AND. nTotReal < 0, nTotReal,;                   //117021 //117824
					IIf(nTotPrev >= nTotReal, nTotReal,;                               //117824
					IIf(nTotPrev > 0 .AND. nTotReal > nTotPrev, nTotPrev,nTotReal)))   //117824
	EndIf	    //117021
	RecLock(cAliasTRB)
	(cAliasTRB)->(FieldPut(FieldPos("ORCTOT"),nTotOrc))
	(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),nTotPrev))
	(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),nTotReal))
	dbSelectArea(cAliasTRB)
	dbSkip()
EndDo
	
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
(cAliasTRB)->NAT  := STR0041+STR0042 	//"Totais de "###"Entradas"

For nX := 1 To Len(aTotPer[1])

	nTotOrc  += aTotPer[1][nX][1]
	nTotReal += aTotPer[1][nX][3]	
	
	If lDecstPrv 
		nTotPrev+= IIf(aTotPer[1][nX][2] > 0, aTotPer[1][nX][2]-aTotPer[1][nX][3],aTotPer[1][nX][2])
	Else
		nTotPrev += aTotPer[1][nX][2]
	Endif 
	
	(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[1][nX][1]))
	(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[1][nX][2]))
	(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[1][nX][3]))
	
	If lIntTOP
		(cAliasTRB)->(FieldPut(FieldPos("LNBASE" +StrZero(nX,3)),aTotPer[1][nX][4])) //Projeto - Linha Base
		(cAliasTRB)->(FieldPut(FieldPos("LNSALDO"+StrZero(nX,3)),aTotPer[1][nX][5]))	//Projeto - Saldo			
	EndIf

	(cAliasTRB)->(FieldPut(FieldPos("ORCTOT"),nTotOrc))
	(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),nTotPrev))
	(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),nTotReal))

Next nX

MsUnLock()
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

	(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[2][nX][1]))
	(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[2][nX][2]))
	(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[2][nX][3]))
	
	If lIntTOP
		(cAliasTRB)->(FieldPut(FieldPos("LNBASE" +StrZero(nX,3)),aTotPer[2][nX][4])) //Projeto - Linha Base
		(cAliasTRB)->(FieldPut(FieldPos("LNSALDO"+StrZero(nX,3)),aTotPer[2][nX][5]))	//Projeto - Saldo			
	EndIf

	(cAliasTRB)->(FieldPut(FieldPos("ORCTOT"),nTotOrc))
	(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),nTotPrev))
	(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),nTotReal))

Next nX

MsUnLock()
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

	(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[1][nX][1]-aTotPer[2][nX][1]))
	(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[1][nX][2]-aTotPer[2][nX][2]))
	(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[1][nX][3]-aTotPer[2][nX][3]))
	
	If lIntTOP
		(cAliasTRB)->(FieldPut(FieldPos("LNBASE" +StrZero(nX,3)),aTotPer[1][nX][4] - aTotPer[2][nX][4] )) //Projeto - Linha Base
		(cAliasTRB)->(FieldPut(FieldPos("LNSALDO"+StrZero(nX,3)),aTotPer[1][nX][5] - aTotPer[2][nX][5] ))	//Projeto - Saldo			
	EndIf

	(cAliasTRB)->(FieldPut(FieldPos("ORCTOT"),nTotOrc))
	(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),nTotPrev))
	(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),nTotReal))
	
Next nX
	
MsUnLock()

//-----------------------------------------------------------    
// Saldo Final e Inicial
//-----------------------------------------------------------
nTotPrev := 0
nTotReal := 0
nTotOrc  := 0	
nTotComp := 0	
RecLock(cAliasTRB,.T.)
(cAliasTRB)->SEQ  := "999"
(cAliasTRB)->CART := "Z"
(cAliasTRB)->NAT  := STR0045 //"Saldo Final"

For nX := 1 To Len(aPeriodos)

	If nx == 1
		aTotPer[4][nX][1] += aTotPer[3][nX][1]+aTotPer[1][nX][1]-aTotPer[2][nX][1]
		aTotPer[4][nX][2] += aTotPer[3][nX][2]+aTotPer[1][nX][2]-aTotPer[2][nX][2]
		aTotPer[4][nX][3] += aTotPer[3][nX][3]+aTotPer[1][nX][3]-aTotPer[2][nX][3]
		If lIntTOP
			aTotPer[4][nX][4] += aTotPer[3][nX][4]+aTotPer[1][nX][4]-aTotPer[2][nX][4]	
			aTotPer[4][nX][5] += aTotPer[3][nX][5]+aTotPer[1][nX][5]-aTotPer[2][nX][5]			
		EndIf
	Else
		aTotPer[3][nX][1] := aTotPer[4][nX-1][1]
		aTotPer[3][nX][2] := aTotPer[4][nX-1][2]
		aTotPer[3][nX][3] := aTotPer[4][nX-1][3]
		aTotPer[4][nX][1] += aTotPer[3][nX][1]+aTotPer[1][nX][1]-aTotPer[2][nX][1]
		aTotPer[4][nX][2] += aTotPer[3][nX][2]+aTotPer[1][nX][2]-aTotPer[2][nX][2]
		aTotPer[4][nX][3] += aTotPer[3][nX][3]+aTotPer[1][nX][3]-aTotPer[2][nX][3]
		If lIntTOP
			aTotPer[3][nX][4] := aTotPer[4][nX-1][4]
			aTotPer[3][nX][5] := aTotPer[4][nX-1][5]
			aTotPer[4][nX][4] += aTotPer[3][nX][4]+aTotPer[1][nX][4]-aTotPer[2][nX][4]
			aTotPer[4][nX][5] += aTotPer[3][nX][5]+aTotPer[1][nX][5]-aTotPer[2][nX][5]		
		EndIf
		
	EndIf	

Next nX

For nX := 1 To Len(aPeriodos)

	(cAliasTRB)->(FieldPut(FieldPos("ORC" +StrZero(nX,3)),aTotPer[4][nX][1]))
	(cAliasTRB)->(FieldPut(FieldPos("PREV"+StrZero(nX,3)),aTotPer[4][nX][2]))
	(cAliasTRB)->(FieldPut(FieldPos("REAL"+StrZero(nX,3)),aTotPer[4][nX][3]))
	If lIntTOP
		(cAliasTRB)->(FieldPut(FieldPos("LNBASE" +StrZero(nX,3)),aTotPer[4][nX][4]))
		(cAliasTRB)->(FieldPut(FieldPos("LNSALDO"+StrZero(nX,3)),aTotPer[4][nX][5]))
	EndIf
Next nX

(cAliasTRB)->(FieldPut(FieldPos("ORCTOT" ),aTotPer[4][Len(aPeriodos)][1]))
(cAliasTRB)->(FieldPut(FieldPos("PREVTOT"),aTotPer[4][Len(aPeriodos)][2]))
(cAliasTRB)->(FieldPut(FieldPos("REALTOT"),aTotPer[4][Len(aPeriodos)][3]))

MsUnLock()

//-----------------------------------------------------------
// Saldo Inicial
//-----------------------------------------------------------

dbSelectArea(cAliasTRB)
If DbSeek("000"+"Z"+STR0021)
	RecLock(cAliasTRB)
Else
	RecLock(cAliasTRB,.t.)
		(cAliasTRB)->SEQ := "000"
		(cAliasTRB)->CART:= "Z"
		(cAliasTRB)->NAT := STR0021 //"Saldos iniciais"
EndIf

For nX := 1 To Len(aTotPer[3])
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
		
		If(lIntTOP)
		
			(cAliasTRB)->(FieldPut(FieldPos("LNBASE" +StrZero(nX,3)),aTotPer[4][nX-1][4]))
			(cAliasTRB)->(FieldPut(FieldPos("LNSALDO"+StrZero(nX,3)),aTotPer[4][nX-1][5]))
			
		EndIf
	EndIf	
Next nX

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
  
Function FC024CalcFor(aVisao, cAliasTRB,aPeriodos)
Local cSuperior := ""
Local nCont  	:= 0
Local nFator 	:= 0
Local nX	 	:= 0
Local nA 		:= 0
Local nLen   	:= Len(aPeriodos)  

For nX:= 1 to Len(aVisao)
	
	cSuperior := aVisao[nX][(nLen*3)+5] // Conta Superior
	nCont     := Len(aVisao)
		    
	//Procurar nas superiores e somar ou subtrair
	If(!Empty(cSuperior))   
                     
		//Ralizar calculo com a formula digitada pelo usuario
		If (Left(aVisao[nX][(nLen*3)+16], 7) == "ROTINA=") //FORMULA
			nFator := &(Subs(aVisao[nX][(nLen*3)+16], 8)) 
		   
			For nA := 1 to (nLen*3)   
		   		aVisao[nX][nA] *= nFator
		   	Next nA
			
		ElseIf Left(aVisao[nX][(nLen*3)+16], 6) == "FATOR="
			nFator := &(Subs(aVisao[nX][(nLen*3)+16], 7))
					
			For nA := 1 to (nLen*3)   
		   		aVisao[nX][nA] *= nFator
		   	Next nA
											
		Elseif Left(aVisao[nX][(nLen*3)+16],6 ) == "SALDO="		
			nFator := &(Subs(aVisao[nX][(nLen*3)+16], 7))
			
			For nA := 1 to (nLen*3)   
		   		aVisao[nX][nA] := nFator
		   	Next nA
											
	    EndIf	 		
	
	Endif
Next

Return 

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

If(_oFINC0243 <> NIL)

	_oFINC0243:Delete()
	_oFINC0243 := NIL

EndIf

_oFINC0243 := FwTemporaryTable():New(cAliasAna)
_oFINC0243:SetFields(aStruct)
_oFINC0243:AddIndex("1",{"ANA_NAT","ANA_NPOS"})
_oFINC0243:Create()

Return Nil

/*/{Protheus.doc} F024TotNat

Totaliza as naturezas analíticas nas sintéticas

@author    Marcos Berto
@version   11.80
@since     15/03/13

@param cAliasTRB - Tabela Temporaria

/*/
Function F024TotNat(cAliasTRB)

Local aAreaTRB	:= {}
Local aSequencia	:= {}
Local aStruct		:= {}
Local cSeq			:= ""
Local cCart		:= ""
Local cNatureza	:= ""
Local cQuery		:= ""
Local cAliasAux 	:= GetNextAlias()
Local cAliasQry 	:= GetNextAlias()
Local nX			:= 0
Local nPosSeq		:= 0

aAreaTRB := (cAliasTRB)->(GetArea())

//Criar uma cópia do arquivo temporário para reprocessamento
dbSelectArea(cAliasTRB)
aStruct := (cAliasTRB)->(dbStruct())

If(_oFINC0247 <> NIL)

		_oFINC0247:Delete()
		_oFINC0247 := NIL

EndIf

_oFINC0247 := FwTemporaryTable():New(cAliasAux)
_oFINC0247:SetFields(aStruct)
_oFINC0247:AddIndex("1",{"NATPAI"})
_oFINC0247:Create()


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
			DbSetOrder(1)
			If !(cAliasTRB)->(dbSeek(aSequencia[nX][2]+aSequencia[nX][1]+(cAliasQry)->ED_CODIGO))
				RecLock(cAliasTRB,.T.)
				(cAliasTRB)->CART 		:= aSequencia[nX][1]
				(cAliasTRB)->SEQ  		:= aSequencia[nX][2]
				(cAliasTRB)->NAT  		:= (cAliasQry)->ED_CODIGO + " - " + (cAliasQry)->ED_DESCRIC	
				(cAliasTRB)->NATPAI 	:= (cAliasQry)->ED_PAI
				(cAliasTRB)->(MsUnlock())	
			EndIf
				
		Next nX
	Else
		//Sintéticas de nível 1 - N
		dbSelectArea(cAliasTRB) 
		DbSetOrder(3)
		If (cAliasTRB)->(dbSeek( (cAliasQry)->ED_CODIGO) )
			While !(cAliasTRB)->( Eof()) .And. (cAliasTRB)->NATPAI == (cAliasQry)->ED_CODIGO
				aAdd(aSequencia,{ (cAliasTRB)->CART, (cAliasTRB)->SEQ })
				(cAliasTRB)->(dbSkip())
			EndDo
		EndIf

		dbSelectArea(cAliasTRB)	
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

/*/{Protheus.doc}F024Mark
Faz a montagem da MarkBrowse de seleção dos centro de custos.
@author William Matos Gundim Junior
@since  25/02/2014
@version 12
/*/
Function F024Mark(lDest)
Local aArea		:= GetArea()
Local cQuery 		:= ""
Local aStruct		:= {}
Local nX 			:= 1
Local cArqTrab		:= GetNextAlias()
Local aCustos		:= {}
Local aColumns		:= {}
Local bOk 			:= {||If(F024Grava(cArqTrab,aCustos,aRet),(oMrkBrowse:Deactivate(), oDlg:End()), Nil)}
Local aPerg	 	:= {{5,STR0118,,150,,.F.}}//Considera registro com centro de custo não inf.
Local bPergunte	:= {||ParamBox( aPerg,STR0020,aRet)}
Local oDlg			:= Nil
Local aSize		:= {}
Local cAliasCC	:= GetNextAlias()
Local aRet			:= {}
Private oMrkBrowse:= FWMarkBrowse():New()

//Filtra centro de custos da CTT e cria campo virtual
cQuery += "SELECT CTT_CUSTO, CTT_DESC01, CTT_CLASSE, '  ' CTT_OK FROM " + RetSqlName("CTT") + " CTT "
cQuery += "WHERE CTT_FILIAL = '" + xFilial("CTT") + "'"
cQuery += "AND D_E_L_E_T_ = ' ' " 
cQuery += " ORDER BY "+ SqlOrder(CTT->(IndexKey()))
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCC,.T.,.T.)	

//Cria estrutura e tabela tmp com os campos necessarios da CTT
Aadd(aStruct, {"CTT_OK","C",1,0})
Aadd(aStruct, {"CTT_CUSTO","C",TamSx3("CTT_CUSTO")[1],0})
Aadd(aStruct, {"CTT_DESC01","C",TamSx3("CTT_DESC01")[1],0})
Aadd(aStruct, {"CTT_CLASSE","C",20,0})

If(_oFINC0244 <> NIL)

	_oFINC0244:Delete()
	_oFINC0244 := NIL

EndIf

_oFINC0244 := FwTemporaryTable():New(cArqTrab)
_oFINC0244:SetFields(aStruct)
_oFINC0244:AddIndex("IN1",{"CTT_CUSTO","CTT_DESC01"})
_oFINC0244:Create()


//Preenche Tabela TMP com as informações filtradas
While !(cAliasCC)->(Eof())
	RecLock(cArqTrab,.T.)
	(cArqTrab)->CTT_CUSTO := (cAliasCC)->CTT_CUSTO
	(cArqTrab)->CTT_DESC01:= (cAliasCC)->CTT_DESC01
	(cArqTrab)->CTT_CLASSE:= X3COMBO("CTT_CLASSE",(cAliasCC)->CTT_CLASSE)
	MsUnlock()
	(cAliasCC)->(dbSkip())
End

//----------------MarkBrowse----------------------------------------------------
For nX := 1 To Len(aStruct)
	If	aStruct[nX][1] $ "CTT_CUSTO|CTT_DESC01|CTT_CLASSE"
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nX][1])) 
		aColumns[Len(aColumns)]:SetSize(aStruct[nX][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])
		aColumns[Len(aColumns)]:SetPicture(PesqPict("CTT",aStruct[nX][1])) 
	EndIf 	
Next nX 

If !(cArqTrab)->(Eof())
	aSize := MsAdvSize(,.F.,400)
	DEFINE MSDIALOG oDlg TITLE STR0119 From 300,0 to 800,800 OF oMainWnd PIXEL //Centro de Custos
	oMrkBrowse:= FWMarkBrowse():New()
	oMrkBrowse:SetFieldMark("CTT_OK")
	oMrkBrowse:SetOwner(oDlg)
	oMrkBrowse:SetAlias(cArqTrab)
	oMrkBrowse:AddButton(STR0120, bOk,,,, .F., 7 ) //Confirmar
	oMrkBrowse:AddButton(STR0121,bPergunte,,,, .F., 7 ) //Parâmetros 
	oMrkBrowse:bMark := {||F0244bMark(oMrkBrowse,cArqTrab)}
	oMrkBrowse:SetDescription("")
	oMrkBrowse:SetColumns(aColumns)
	oMrkBrowse:SetTemporary()
	oMrkBrowse:Activate()
	ACTIVATE MSDIALOg oDlg CENTERED
EndIf

//-------------------------------------------------------------------------------
If Len(aCustos) > 0
	RestArea(aArea)
	If(_oFINC0244 <> NIL)

		_oFINC0244:Delete()
		_oFINC0244 := NIL

	EndIf
	(cAliasCC)->(dbCloseArea())

EndIf	
	
Return aCustos

/*/{Protheus.doc}F024Grava
Grava em um array todos os centro de custos selecionados.
@author William Matos Gundim Junior
@since  25/02/2014
@version 12
/*/
Function F024Grava(cArqTrab, aCustos, aRet)
Local lRet := .T.
Local nRecNo := 0

dbSelectArea(cArqTrab)
nRecno := (cArqTrab)->(RecNo())
(cArqTrab)->(DbGoTop())
While !(cArqTrab)->(Eof())
	If !Empty((cArqTrab)->CTT_OK)
		aAdd(aCustos, (cArqTrab)->CTT_CUSTO)
	EndIf
	(cArqTrab)->(DbSkip())
End

If Len(aRet) > 0 //Array de retorno do pergunte para considerar centro de custo não informado. 
	If (aRet[1], aAdd(aCustos, ' '),Nil)
EndIf

lRet := If (Len(aCustos) > 0, .T., .F.) 
(cArqTrab)->(DbGoTo(nRecno))

Return lRet

/*{Protheus.doc}F0244bMark

Faz gravação no campo OK com a marcação.

@author Rogério Sá
@since  17/01/2019
@version 12
*/
Function F0244bMark(oMrkBrowse,cArqTrab)
	
	Local cMarca := oMrkBrowse:Mark()

	dbSelectArea(cArqTrab)
	(cArqTrab)->(DbGoTop())
	While !(cArqTrab)->(Eof())
		RecLock(cArqTrab, .F.)
		If (cArqTrab)->CTT_OK <> cMarca
			(cArqTrab)->CTT_OK := ' '
		Else
			(cArqTrab)->CTT_OK := cMarca
		EndIf
		MsUnlock()
		(cArqTrab)->(DbSkip())	
	End

	oMrkBrowse:oBrowse:Refresh(.T.)

Return .T.

/*/{Protheus.doc}FC24FilCust
Faz gravação no cmapo CTT_OK com a marcação.
@author William Matos Gundim Junior
@since  25/02/2014
@version 12
/*/
Function FC24FilCust(aCCustos)
Local cCustos 		:= ''
Local nX			:= 0
Local oSelf 		:= NIL 
Local nInc			:= 0
Local aPerguntes	:= {} 
Default aCCustos 	:= {}

For nX := 1 To Len(aCCustos)
	cCustos += "'" + aCCustos[nX] + "',"
Next nX

cCustos := Substr(cCustos, 1, Len(cCustos) - 1)

aAdd(aPerguntes,cCustos) //1 - Se filtra por centro de custo | 2 - Códigos dos centro de custos.
aAdd(aPerguntes,MV_PAR03) //Vencimento de 
aAdd(aPerguntes,MV_PAR04) //Vencimento ate
aAdd(aPerguntes,MV_PAR01) //Natureza de
aAdd(aPerguntes,MV_PAR02) //Natureza ate
aAdd(aPerguntes,MV_PAR15) //Do risco
aAdd(aPerguntes,MV_PAR16) //Até risco

//Calculo dos saldos Previstos - Receber (SE1 exceto Multinatureza)			
F800SPSE1(oSelf ,nInc,aPerguntes)
//Calculo dos saldos Realizados - Movimentos bancarios manuais
F800SRMOV(oSelf ,nInc,aPerguntes)
//Calculo dos saldos Previstos - Multinaturezas Receber Emissao
F800SPSEV(oSelf ,nInc,aPerguntes)
//Calculo dos saldos Realizados - Multinaturezas Receber Baixas
F800SRSEV(oSelf ,nInc,aPerguntes)
//SEZ - Filtra centro de custo rateado Emissão.
F800SPSEZ(aPerguntes)
//SEZ - Filtra centro de custo rateado Baixa.
F800SRSEZ(aPerguntes)
//---------Totais de Saida-----------------//

//Calculo dos saldos Realizados / Aplicacao / Emprestimo
F800SRSE5(oSelf ,nInc,aPerguntes)
//Calculo dos saldos Previstos - Comissoes	
F800SPSE3(oSelf ,nInc,aPerguntes)
//SE7 - Orcamentos por Naturezas	
F800SOSE7(oSelf ,nInc,aPerguntes)
//Calculo dos saldos Previstos - Pagar (SE2 exceto Multinatureza)			
F800SPSE2(oSelf ,nInc,aPerguntes)
//Filtra FJ0 - Integração TOP x RM
If lIntTOP
	FC24FilTOP(aPerguntes)
EndIf
//----------------------------------------//

Return 

/*/{Protheus.doc}FC24SldNat
Faz gravação no alias temporario para exibição dos movimentos
@author William Matos Gundim Junior
@since  06/03/2014
@version 12
/*/
Function FC24SldNat(cAliasQry, cNomeTab, cCarteira, cSinal,nVlAbat, nValor, cCodNat, dData)
Local aArea		:= GetArea()
Local cTpSaldo 	:= ''
Local cMoeda		:= '01'
Local cPrefix		:= SubStr(cNomeTab,2,Len(cNomeTab))
Local cNatComis	:= STRTRAN(GetNewPar("MV_NATCOM",""),'"',"")
Local lControle	:= cNomeTab $ 'SC7|SC6' //Essas tabelas não precisam de posicionamento, sempre gravam registros novos.
Local cNatureza	:= ''
Local dDataIni		:= Date()
Local cAliasTmp	:= ''
Local lRecOrc	:= .F.	// Indica se o orcamento sera gravado (validando o periodo)
Default cCodNat	:= ''
Default dData		:= Date()
Default cCarteira := ''
Default nVlAbat	:= 0
Default cSinal 	:= ''
Default nValor		:= 0

cAliasTmp := _oFINC0245:oStruct:cAlias //Nome do arquivo temporario

If !lControle
	dbSelectArea('SED')
	SED->(DbSetOrder(1))
	
	//-------Posiciona na cAliasTMP antes de iniciar a gravação-
	If cNomeTab $ 'SE1|SE2|SEZ|SEV'
		If cNomeTab $ 'SE1|SE2'
			If cCarteira = 'P'
				cTpSaldo := If((cAliasQry)->&(cPrefix + "_TIPO") $ MVPAGANT+"/"+MV_CPNEG,"3","2")
			Else
				cTpSaldo := If((cAliasQry)->&(cPrefix + "_TIPO") $ MVRECANT+"/"+MV_CRNEG,"3","2")
			EndIf
		Elseif cNomeTab $ 'SEV|SEZ'
			cTpSaldo := If((cAliasQry)->&(cPrefix + "_TIPO") $ MVPAGANT+"/"+MV_CPNEG,"3",IIF((cAliasQry)->IDENT=="1","2","3"))
		Endif
		If ValType((cAliasQry)->&(cPrefix + "_VENCREA")) == 'D'
			dDataIni	:= DTOS((cAliasQry)->&(cPrefix + "_VENCREA"))
		Else
			dDataIni	:= (cAliasQry)->&(cPrefix + "_VENCREA")
		EndIf
		cNatureza:= (cAliasQry)->&(cPrefix + "_NATUREZ")
	ElseIf cNomeTab $ 'SE3'
		cTpSaldo  := If(!Empty((cAliasQry)->E3_DATA),"3","2")
		dDataIni	   := DTOS((cAliasQry)->&(cPrefix + "_VENCTO"))
		cNatureza := cNatComis
	ElseIf cNomeTab $ 'SE5'
		cNatureza:= (cAliasQry)->&(cPrefix + "_NATUREZ")
		dDataIni	  := DTOS((cAliasQry)->&(cPrefix + "_DATA"	 ))
		cTpSaldo := "3"
	Else
		cTpSaldo := '1'
		dDataIni := DTOS(dData)
	EndIf
	
	//Natureza.
	If cNomeTab $ 'SE1|SE2|SEZ|SE5'
		cNatureza:= (cAliasQry)->&(cPrefix + "_NATUREZ")
	ElseIf cNomeTab $ 'SE3'
		cNatureza := cNatComis
	Else
		cNatureza := cCodNat
	EndIf
	
	//Posiciona.
	(cAliasTmp)->(DbSetOrder(1))
	If (cAliasTmp)->(MsSeek(cNatureza + cMoeda + cTpSaldo + cCarteira + dDataIni))
		RecLock((cAliasTmp), .F.)
	Else
		If cTpSaldo == "1" // Valida se o mes do orcamento esta no range escolhido (a query da FINA800 traz o ano todo)
			If dData >= MV_PAR03 .and. dData <= MV_PAR04
				RecLock((cAliasTmp), .T.)
				lRecOrc := .T.
			EndIf
		Else
			RecLock((cAliasTmp), .T.)
		EndIf
	EndIf
	
	 //Posiciona no alias de natureza para gravar informações TMP.	
	SED->(MsSeek(xFilial("SED") + cNatureza)) 
	//---------------------------------------------------------
EndIf	

Do Case
	Case cNomeTab $ 'SE1|SE2|SEZ|SE5|SEV' // 
			
		(cAliasTmp)->TMP_NATUR 	:= cNatureza
		(cAliasTmp)->TMP_MOEDA	:= cMoeda
		(cAliasTmp)->TMP_TPSALD  := cTpSaldo
		(cAliasTmp)->TMP_CARTEI  := cCarteira
		(cAliasTmp)->TMP_DESC	:= SED->ED_DESCRIC
		(cAliasTmp)->TMP_PAI		:= SED->ED_PAI
		(cAliasTmp)->TMP_DATA 	:= dDataIni
		If cSinal == "+"
			(cAliasTmp)->TMP_VALOR   += (cAliasQry)->NVALOR
			(cAliasTmp)->TMP_ABATI 	+= nVlAbat
		Else
			(cAliasTmp)->TMP_VALOR   -= (cAliasQry)->NVALOR
			(cAliasTmp)->TMP_ABATI 	-= nVlAbat
		EndIf
				
	Case cNomeTab == 'SE7' // Orcamentos por Natureza.
		If lRecOrc
			(cAliasTmp)->TMP_NATUR 	:= cCodNat
			(cAliasTmp)->TMP_MOEDA	:= cMoeda
			(cAliasTmp)->TMP_TPSALD  := '1'
			(cAliasTmp)->TMP_CARTEI  := If(SED->ED_COND=="D","P",SED->ED_COND)
			(cAliasTmp)->TMP_DESC	:= SED->ED_DESCRIC
			(cAliasTmp)->TMP_PAI		:= SED->ED_PAI
			(cAliasTmp)->TMP_DATA 	:= DTOS(dData)
			If cSinal == "+"
				(cAliasTmp)->TMP_VALOR   += nValor
				(cAliasTmp)->TMP_ABATI 	+= nVlAbat
			Else
				(cAliasTmp)->TMP_VALOR   -= nValor
				(cAliasTmp)->TMP_ABATI 	-= nVlAbat
			Endif
		EndIf
					
	Case cNomeTab == 'SE3' // Comissões de Venda.
							
		(cAliasTmp)->TMP_NATUR 	:= cNatComis
		(cAliasTmp)->TMP_MOEDA	:= cMoeda
		(cAliasTmp)->TMP_CARTEI  := cCarteira
		(cAliasTmp)->TMP_TPSALD  := cTpSaldo		
		(cAliasTmp)->TMP_DESC	:= SED->ED_DESCRIC
		(cAliasTmp)->TMP_PAI		:= SED->ED_PAI
		(cAliasTmp)->TMP_DATA 	:= DTOS((cAliasQry)->E3_VENCTO)
		(cAliasTmp)->TMP_VALOR   += (cAliasQry)->E3_COMIS
		(cAliasTmp)->TMP_ABATI 	+= nVlAbat
				
	OtherWise
	
		RecLock((cAliasTmp),.T.)
		//Posiciona no alias de natureza para gravar informações TMP.	
		If SED->(MsSeek(xFilial("SED") + cCodNat))
			(cAliasTmp)->TMP_NATUR 	:= cCodNat
			(cAliasTmp)->TMP_DESC	:= SED->ED_DESCRIC
			(cAliasTmp)->TMP_PAI		:= SED->ED_PAI
		EndIf 
		(cAliasTmp)->TMP_DATA	:= DTOS(dData)
		(cAliasTmp)->TMP_MOEDA	:= "01"
		(cAliasTmp)->TMP_VALOR	:= nValor
		(cAliasTmp)->TMP_TPSALD	:= "2"
		(cAliasTmp)->TMP_CARTEI	:= cCarteira	
	
	End Case	
	
MsUnlock()
RestArea(aArea)

Return

/*/{Protheus.doc}FC24CriaTMP
Cria tabela temporaria para armazenar os valores dos movimentos.
@author William Matos Gundim Junior
@since  06/03/2014
@version 12
/*/
Function FC24CriaTMP()
Local aStruct := {}
Local cIndTmp
Local cChave	:= ''
Private cAliasTMP := GetNextAlias()		

//--- Cria alias temporario baseado na FIV
aAdd(aStruct, {"TMP_NATUR"	,"C"	,TamSx3("FIV_NATUR")[1]	,0})
aAdd(aStruct, {"TMP_MOEDA"	,"C"	,TamSx3("FIV_MOEDA")[1]	,0})
aAdd(aStruct, {"TMP_TPSALD"	,"C"	,TamSx3("FIV_TPSALD")[1]	,0})
aAdd(aStruct, {"TMP_CARTEI"	,"C"	,TamSx3("FIV_CARTEI")[1]	,0})
aAdd(aStruct, {"TMP_DATA"	,"C"	,TamSx3("FIV_DATA")  [1]	,0})
aAdd(aStruct, {"TMP_DESC	"	,"C"	,TamSx3("ED_DESCRIC")[1],0})
aAdd(aStruct, {"TMP_PAI"		,"C"	,TamSx3("ED_PAI")	[1],0})	
aAdd(aStruct, {"TMP_ABATI"	,"N"	,17,2})
aAdd(aStruct, {"TMP_VALOR"	,"N"	,17,2})
//-----------------------------------------

If(_oFINC0245 <> NIL)

	_oFINC0245:Delete()
	_oFINC0245 := NIL

EndIf

_oFINC0245 := FwTemporaryTable():New(cAliasTmp)
_oFINC0245:SetFields(aStruct)
_oFINC0245:AddIndex("1",{"TMP_NATUR","TMP_MOEDA" , "TMP_TPSALD" , "TMP_CARTEI" , "TMP_DATA" })
_oFINC0245:Create()

Return 

/*/{Protheus.doc}IntegDef
Mensagem unica de integração com RM x TOP.
@param cXml	  Xml passado para a rotina
@param nType 	  Determina se e uma mensagem a ser enviada/recebida ( TRANS_SEND ou TRANS_RECEIVE)
@param cTypeMessage Tipo de mensagem ( EAI_MESSAGE_WHOIS, EAI_MESSAGE_RESPONSE, EAI_MESSAGE_BUSINESS)
@author William Matos Gundim Junior
@since  06/03/2014
@version 12
/*/
Static Function IntegDef( cXML, nType, cTypeMessage )
Local aRetorno := {}

aRetorno := FINI024( cXML, nType, cTypeMessage)

Return aRetorno

/*/{Protheus.doc}FC24FilTOP
Realiza filtro na tabela FJ0 - Integração TOP para exibição dos dados
@author William Matos Gundim Junior
@param  aPerguntes  Array com os parametros para o filtro.
@since  06/03/2014
@version 12
/*/
Function FC24FilTOP(aPerguntes)
Local cQuery := ''
Local cAliasFJ0 := GetNextAlias()
Local cAliasTmp := _oFINC0245:oStruct:cAlias //Nome do arquivo temporario

//aPerguntes[1] Centro de Custos
//aPerguntes[2] Vencimento de 
//aPerguntes[3] Vencimento ate
//aPerguntes[4] Natureza de
//aPerguntes[5] Natureza ate

cQuery := "SELECT FJ0_CLASSI, FJ0_DATA, FJ0_NATURE, SUM(FJ0_VALOR) VALOR, ED_DESCRIC, ED_PAI, ED_COND "
cQuery += "FROM " 	 + RetSQLTab('FJ0')
cQuery += "LEFT JOIN" + RetSQLTab('SED') + "ON ED_CODIGO = FJ0_NATURE " 
cQuery += "WHERE "
cQuery += "FJ0_FILIAL = '" + cFilAnt + "' AND " 
cQuery += "FJ0_DATA >='" + DTOS(aPerguntes[2])	+"' AND "
cQuery += "FJ0_DATA <='" + DTOS(aPerguntes[3])	+"' AND "
cQuery += "FJ0_NATURE >='" + aPerguntes[4] +"' AND "
cQuery += "FJ0_NATURE <='" + aPerguntes[5] +"' AND "
If (!Empty(aPerguntes[1]),cQuery += "FJ0_CCUSTO IN (" + aPerguntes[1] + ") AND ", Nil)
cQuery += "FJ0.D_E_L_E_T_ <> '*'"
cQuery += "GROUP BY FJ0_DATA, FJ0_CLASSI, FJ0_NATURE, FJ0_VALOR, ED_DESCRIC, ED_PAI, ED_COND"
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFJ0,.T.,.T.)
dbSelectArea(cAliasFJ0)
DbGotop()

While !(cAliasFJ0)->(Eof()) 
	
	RecLock((cAliasTmp), .T.)
	
	(cAliasTmp)->TMP_NATUR 	:= (cAliasFJ0)->FJ0_NATURE
	(cAliasTmp)->TMP_MOEDA	:= "01"
	If (cAliasFJ0)->FJ0_CLASSI == '1' // 1-Linha Base | 2-Saldo
		(cAliasTmp)->TMP_TPSALD  := "B"
	Else
		(cAliasTmp)->TMP_TPSALD  := "S"	
	EndIf
	If (cAliasFJ0)->ED_COND == "R" //Receita
		(cAliasTmp)->TMP_CARTEI  := "R"
	Else
		(cAliasTmp)->TMP_CARTEI  := "P"
	EndIf
	(cAliasTmp)->TMP_DESC	:= (cAliasFJ0)->ED_DESCRIC
	(cAliasTmp)->TMP_PAI		:= (cAliasFJ0)->ED_PAI
	(cAliasTmp)->TMP_DATA 	:=  (cAliasFJ0)->FJ0_DATA
	(cAliasTmp)->TMP_VALOR   := (cAliasFJ0)->VALOR
	MsUnlock()
	
	(cAliasFJ0)->(dbSkip())

End
(cAliasFJ0)->(DbCloseArea())

Return 
