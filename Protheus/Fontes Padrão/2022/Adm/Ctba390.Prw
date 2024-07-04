#Include "Protheus.CH"
#Include "Colors.ch"
#INCLUDE "CTBA390.ch"

#DEFINE MAXPASSO 6
#DEFINE _DEBITO_  1
#DEFINE _CREDITO_ 2

Static l390SLCDX := NIL
Static l390SLSQL := NIL
Static l390Grv 	 := NIL
Static cTmSequen := NIL
Static lFWCodFil := NIL
													 // (será utilizado para limitar a quantidade de linhas do orçamento)
Static _lCpoEnt05 //Entidade 05
Static _lCpoEnt06 //Entidade 06
Static _lCpoEnt07 //Entidade 07
Static _lCpoEnt08 //Entidade 08
Static _lCpoEnt09 //Entidade 09
Static _cAlias05
Static _cAlias06
Static _cAlias07
Static _cAlias08
Static _cAlias09
Static _cCpoChv05
Static _cCpoChv06
Static _cCpoChv07
Static _cCpoChv08
Static _cCpoChv09

Static nQtdEntid //Quantidade de entidades contabeis

Static lCtbIsCube := FindFunction("CtbIsCube")

Static _oCTBA3901 
Static _oCTBA3902
Static nPosValor := 4	//Valor (aColsP)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CTBA390  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 01.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de manutencao do cadastro de orcamentos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA390()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Revisoes  ³ Simone Mie Sato - Adicionadas querys para TopConnect       ³±±
±±³Revisoes  ³ Marcos S. Lobo - Normalização Cabecalho x Itens            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±        
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba390()
Local lCt390AFil:= ExistBlock("Ct390AFil")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a	 ser efetuada                        ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private aRotina := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0009   // Cadastro de Orcamentos

Private aIndexes

aIndexes := CTBEntGtIn()

Pergunte("CTB390", .F.)

SetKey(VK_F12,{|a,b|Pergunte("CTB390",.T.)})

dbSelectArea("CV2")
cFiltro := ""
If ExistBlock("CTB390FIL")								/// PONTO DE ENTRADA PARA A FILTRAGEM DO BROWSE
	cFiltro := ExecBlock("CTB390FIL", .F., .F.)
	If !Empty(cFiltro)									/// SE A EXPRESSÃO RETORNADA NÃO ESTIVER VAZIA
		Set Filter To &(cFiltro)						/// ACIONA A EXPRESSÃO DE FILTRO NO CV2
	Endif
Endif

If !lCt390AFil

Ctb390IniVar() //Inicializa variaveis logicas das entidades adicionais
LoadVar390()	//variaveis estaticas, fora as adicionais(pois tem uma funcao com tratamentos especificos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse(6,1,22,75,"CV2",,,,,, CtbLegenda("CV2")/*,cFilIni,cFilFim*/)

dbSelectArea("CV2")
Set Filter To
Else
	ExecBlock("CT390AFIL",.F.,.F.)
Endif

SET KEY VK_F12 to

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Ctb390Cad³ Autor ³ Wagner Mobile Costa   ³ Data ³ 01.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de manutencao do cadastro de orcamentos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Ctb390Cad(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba390                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb390Cad(cAlias,nReg,nOpcx,lAutomato,aAuto)

Local oDlg, nOpcA := 0, aSize := MsAdvSize(,.F.,400), aObjects := {}, aInfo, aPosObj
Local bSx3 		:= { |cCampo| (	SX3->(DbSetOrder(2)), SX3->(DbSeek(cCampo)),SX3->(DbSetOrder(1)), X3Titulo()) }

Local aVarTela	:= { 	{ "CV1_ORCMTO", .T. }, { "CV1_DESCRI", .T. },;
						{ "CV1_STATUS", .T. }, { "CV1_REVISA", .T. },;
						{ "CV1_CALEND", .T. }, { "CV1_MOEDA" , .T. } }, nVarTela

Local aSituacao		:= CTBCBOX("CV1_STATUS")
Local cArqTmp
Local aStru			:= {}
Local aAltera 		:= {}
Local cPictVal 		:= PesqPict("CV1","CV1_VALOR"), cSeqAnt, nCpo, nCont //Local cPictVal 	:= X3Picture("CV1_VALOR"), cSeqAnt, nCpo, nCont
Local lRevisao		:= nOpcX == 6
Local lCopia 		:= nOpcX == 7
Local lIncSeq
Local nSequencia
Local cRevisa
Local aMemos 		:= {}
Local cTitulo     := " "
Local nPswAprPos	:= 119 // Altera Orçamento Aprovado
Local lAprvMnt 		:= .T.
Local lAltValor		:= .F.
Local nSeqColsP 	:= 1
Local nDifCols		:= 1
Local lIsAprov		:= .F.
Local cCV1APROVA 	:= ""
Local nLenVal	 	:= nSEQUEN := 0
Local cCV2Filial 	:= xFilial("CV2")
Local lX3Aprova	 	:= .F.
Local lCtb390Psw	:= IIf(ExistBlock("CTB390PSW"),.T.,.F.)
Local lRetPsw		:= .T.
Local i
Local nRevisao         
Local lAtuSal		:= .T.
Local cDbsExt		:= GetDBExtension()                                        
Local lSair
Local lSeqMaior		:= .F.
Local lRet			:= .T.
Local nX 			:= 0
Local aCT390BTE 	:= {}
Local oSize
Local nLin 		:= 0
Local nCol 		:= 0
Local lForcSaldo := .F.
Local nT		:= 0

PRIVATE aButton 	:= {}

// define o tamanho da static das linhas da sequencia
cTmSequen := PadL(GetNewPar( "MV_CV1SEQ" , '9999' ),TamSx3("CV1_SEQUEN")[1],"0") // tamanho do campo do cv1_sequen (será utilizado para limitar a quantidade de linhas do orçamento)

If GetMV("MV_ORCAPRV") == "S"									//// SE APROVACAO ESTIVER HABILITADA
	If !Empty(CV2->CV2_APROVA) .and. nOpcX == 4					//// SE O ORCAMENTO ESTIVER APROVADO E FOR ALTERACAO
		If !ChkPsw(nPswAprPos)									//// CHECA ACESSO DO USUÁRIO (ALTERA ORCAMENTO APROVADO)
			Return
		Endif                                                                    
		lAprvMnt := alltrim(CV2->CV2_APROVA) == alltrim(cUserName)
		If !lAprvMnt												//// SE NAO FOR O PROPRIO APROVADOR
			Return													//// BLOQUEIA A ALTERACAO
		Endif	
	Else
		lAprvMnt := .T.
	Endif   

	lX3Aprova	:= .T.
Else																	//// SE NÃO ESTIVER HABILITADA
	lAprvMnt 	:= .T.													//// QUALQUER USUÁRIO PODE FAZER MANUTENÇÃO
Endif

Private lExecChg := .F.									//// AO INICIALIZAR O OBJETO oGet NÃO DEVE EXECUTAR O bChange (muda p/ .T. NO ACTIVATE DIALOG oGet já vai estar montado)
Private lContinua := .F.

aAreaBrw := GetArea()
nIndCV2  := CV2->(IndexOrd())
nRecCV2  := CV2->(Recno())

DEFAULT cAlias	:= "CV1"
DEFAULT nReg	:= CV2->(Recno())
DEFAULT lAutomato := .F.

dbSelectArea("CV1")

Private oOrcado, oVlrOrc, nOrc, oTotOrc, nTotOrc

If lX3Aprova
	M->CV1_APROVA := ""
Else
	M->CV1_APROVA := cUserName
Endif

If 	(CV2->CV2_STATUS == "3" )
	//// ALTERACAO ou Exclusao e encontrou a revisao
	If 	 nOpcX = 4 .Or. (lRevisao .And. CV1->(MsSeek(CV2->(CV2_FILIAL+CV2_ORCMTO+CV2_CALEND+CV2_MOEDA+Soma1(CV2->CV2_REVISA)))))
		If !lAutomato
			Apmsginfo(STR0007, STR0008) //"Orcamento ja revisado nao podendo ser alterado !"###"Atencao"
		EndIf
		CV2->(DbGoto(nReg))
		Return .F.
	Endif

	CV2->(DbGoto(nReg))
Endif

If lRevisao .and. !Empty(CV2->CV2_APROVA)			//// SE FOR REVISAO E ESTIVER APROVADO (GUARDA O APROVADOR) PARA A NOVA REVISAO
	lIsAprov	:= .T.
	cCV1APROVA	:= CV2->CV2_APROVA
Endif

//Verifica se o usuario tem permissao para Revisar orcamentos aprovados
If nOpcx == 6
	If !ChkPsw(120)
		Return .F.
	EndIf
EndIf

//Se existe o ponto de entrada CTB390PSW
If lCtb390Psw
	lRetPsw	:= ExecBlock("CTB390PSW",.F.,.F.,{nOpcX,cUserName})	
	If !lRetPsw	//Se o ponto de entrada retornar falso
		Return .F.		
	Endif
EndIf

cTitulo := " "       
If lX3Aprova
	If nOpcX # 3 .And. !Empty(CV1->CV1_APROVA)
		cTitulo := STR0009 + STR0021 + AllTrim(CV1->CV1_APROVA) //" - Aprovado por "
	Endif
Endif

If lRevisao .Or. lCopia
	nOpcX := 3
	M->CV1_STATUS := CV2->CV2_STATUS
Endif

For nVarTela := 1 To Len(aVarTela)
	If nOpcX == 3 .And. !lRevisao .And. !lCopia // Inclusao
		_SetOwnerPrvt(aVarTela[nVarTela][1], CriaVar(aVarTela[nVarTela][1]))
	Else
		If aVarTela[nVarTela][1] == "CV1_STATUS" .and. CV2->CV2_STATUS $ '23' .and. lCopia 	/// SE O ORCAMENTO JA FOI REVISADO E FOR COPIA
			_SetOwnerPrvt(aVarTela[nVarTela][1], "1")		/// DEIXA A COPIA COM STATUS DE ABERTO
		Else
			_SetOwnerPrvt(aVarTela[nVarTela][1], &("CV1->" + aVarTela[nVarTela][1]))
		Endif
	Endif
Next

Private aVTelaAux := aClone(aVarTela)

DbClearFil()

// Variaveis para controle da manutencao
INCLUI 		:= nOpcX = 3
ALTERA 		:= nOpcX = 4
EXCLUI 		:= nOpcX = 5

nTotOrc 	:= 0.00
nOrc 		:= 0.00
aHeader		:= {}		// GetDb

Private aColsP	:= { { { "  ", Ctod(""), Ctod(""), 0.00, "1", 0, 0 } } }	// ListBox
aItColsP	:= { "  ", Ctod(""), Ctod(""), 0.00, "1", 0, 0 }

// retorna a estrutura do temporario a ser usado pela rotina
aStru := A390GetStru( cAlias,@aHeader,@aMemos,@aAltera )

If Select("TMP") > 0
	TMP->(DbCloseArea())
Endif

If _oCTBA3901 <> Nil
	_oCTBA3901:Delete()
	_oCTBA3901 := Nil
Endif

_oCTBA3901 := FWTemporaryTable():New( "TMP" )  
_oCTBA3901:SetFields(aStru) 
_oCTBA3901:AddIndex("1", {aStru[1][1],aStru[2][1]})

//------------------
//Criação da tabela temporaria
//------------------
_oCTBA3901:Create()  

// Alimenta os dados do temporario deacordo com o cabeçalho informado
// NOTA: se houver a necessidade de forçar o posicionamento do cv2, avaliar a possibilidade de salvar o registo em um objeto de memoria
if !lAutomato
Processa({|lEnd| lContinua := A390GetDado( CV2->( Recno() ),aHeader,aMemos,nOpcX, lRevisao, lCopia, lIsAprov, cCv1Aprova, lX3APROVA )})
Else
lContinua := A390GetDado( CV2->( Recno() ),aHeader,aMemos,nOpcX, lRevisao, lCopia, lIsAprov, cCv1Aprova, lX3APROVA )
endif
If ! lContinua
	Return
EndIf

If !lAutomato
// carrega os dados na tela
	aAdd( aObjects, { 230 - (If(mv_par03 == 2, 30, 0)), 230 - (If(mv_par03 == 2, 30, 0)), .T., .T. } )
	aAdd( aObjects, { 500, 500, .T., .T. } )

	If mv_par03 = 1
		AAdd( aObjects, { 200, 200, .T., .T. } )
	Endif

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	DEFINE FONT oFnt	NAME "Arial" Size 10,15

	lSair := .F.


	DO WHILE !lSair

		DEFINE MSDIALOG oDlg TITLE If( Empty(cTitulo),cCadastro,cTitulo ) From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL //"Cadastro de Orcamentos"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula dimensões                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSize := FwDefSize():New(.T.,,,oDlg)
		oSize:AddObject( "CABECALHO",  100,25, .T., .T. ) // Totalmente dimensionavel
		oSize:AddObject( "GETDADOS" ,  100, 50, .T., .T. ) // Totalmente dimensionavel 
		oSize:AddObject( "RODAPE" ,  100, 25, .T., .T. ) // Totalmente dimensionavel 
		
		oSize:lProp 	:= .T. // Proporcional             
		oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

		oSize:Process() 	   // Dispara os calculos   
		
		nLin := oSize:GetDimension("CABECALHO","LININI")
		nCol := oSize:GetDimension("CABECALHO","COLINI")

		@ nLin+5,nCol+5 TO  nLin+60, nCol+450 OF oDlg PIXEL LABEL STR0010 //"Capa do Orcamento"
		
		@ nLin+15, nCol+10	 	SAY Eval(bSx3, "CV1_ORCMTO")	Of oDlg PIXEL COLOR CLR_HBLUE
		@ nLin+15, nCol+60 		MSGET M->CV1_ORCMTO				Of oDlg PIXEL Picture PesqPict("CV1","CV1_ORCMTO");
		When nOpcX == 3 .And. ! lRevisao Valid CheckSx3("CV1_ORCMTO", M->CV1_ORCMTO,nOpcx,lCopia)
		
		@ nLin+15, nCol+150 	SAY Eval(bSx3, "CV1_DESCRI")	Of oDlg PIXEL COLOR CLR_HBLUE
		@ nLin+15, nCol+180 	MSGET M->CV1_DESCRI		Of oDlg PIXEL Picture "@!";
		When (nOpcX <> 5  .And. nOpcX <> 2) Valid Texto() SIZE 160,10
		
		@ nLin+15, nCol+360 	SAY Eval(bSx3, "CV1_CALEND")		Of oDlg PIXEL COLOR CLR_HBLUE
		@ nLin+15, nCol+390 	MSGET oCV1Calend VAR M->CV1_CALEND OF oDlg F3 "CTG" Valid CheckSx3("CV1_CALEND", M->CV1_CALEND,nOpcx,lCopia) .And. Ctb390CarCal(1, oPeriodo,.T.,lCopia) Picture PesqPict("CV1","CV1_CALEND") PIXEL
		oCV1Calend:lReadOnly := !INCLUI .or. lRevisao
		
		@ nLin+43,nCol+10 	SAY Eval(bSx3, "CV1_MOEDA")		Of oDlg PIXEL COLOR CLR_HBLUE
		@ nLin+40,nCol+60 	MSGET oCV1Moeda VAR M->CV1_MOEDA Of oDlg PIXEL F3 "CTO"	Valid CheckSx3("CV1_MOEDA", M->CV1_MOEDA,nOpcx,lCopia) .And. Ctb390CarCal(1, oPeriodo) Picture PesqPict("CV1","CV1_MOEDA")
		oCV1Moeda:lReadOnly := !INCLUI .or. lRevisao
		
		@ nLin+43,nCol+190 	SAY Eval(bSx3, "CV1_REVISA")	Of oDlg PIXEL COLOR CLR_HBLUE
		@ nLin+40,nCol+220 	MSGET M->CV1_REVISA				Of oDlg PIXEL Picture "!!!";
		When .F. Valid CheckSx3("CV1_REVISA", M->CV1_REVISA,nOpcx,lCopia)
		
		@ nLin+43,nCol+310 	SAY Eval(bSx3, "CV1_STATUS")	Of oDlg PIXEL
		@ nLin+40,nCol+350 	MSCOMBOBOX oCombo VAR M->CV1_STATUS ITEMS aSituacao When .F. SIZE 45,10 OF oDlg PIXEL
		//oCombo:lReadOnly := .T.
		
		oGet := MSGetDb():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4] - 150,If(nOpcX = 3, 4, nOpcX),;
		"CTB390lOk",, "+CV1_SEQUEN",nOpcX<>5,aAltera,,.T.,,"TMP",,,,,.T.,, "AllWaysTrue")
		
		@ aPosObj[2,1],aPosObj[2,4] - 145 	LISTBOX oPeriodo VAR cPeriodo Fields HEADER Left(Eval(bSx3, "CV1_PERIOD"),3),Eval(bSx3, "CV1_DTINI"),Eval(bSx3, "CV1_DTFIM"),Eval(bSx3, "CV1_VALOR") SIZES 12,30,28,20 SIZE 145,aPosObj[2,3] - aPosObj[2,1] NOSCROLL PIXEL
		//oPeriodo:lReadOnly:= (nOpcx == 2 .or. nOpcx == 5)
		oPeriodo:lReadOnly:= (nOpcx == 5)
		oPeriodo:SetArray(aColsP[Val(TMP->CV1_SEQUEN)])
		oPeriodo:bLine := { ||{ aColsP[Val(TMP->CV1_SEQUEN)][oPeriodo:nAt,1],aColsP[Val(TMP->CV1_SEQUEN)][oPeriodo:nAt,2],aColsP[Val(TMP->CV1_SEQUEN)][oPeriodo:nAt,3],Trans(aColsP[Val(TMP->CV1_SEQUEN)][oPeriodo:nAt,4], cPictVal) } }
		
		oPeriodo:bLostFocus:=  {|| oGet:oBrowse:SetFocus() }
		
		oPeriodo:bLDblClick := {|| Iif(val(TMP->CV1_SEQUEN)>Len(aColsP),Ctb390CarCal(VAL(TMP->CV1_SEQUEN), oPeriodo),), Ctb390Edt(@oPeriodo,aColsP,cPictVal),oPeriodo:GoRight(),;
		oPeriodo:GoLeft(),CTB390DspOrc(oOrcado,oVlrOrc,@nOrc,oTotOrc,@nTotOrc)}
		
		oGet:oBrowse:bChange := {|| ct390OnChg(oPeriodo, oOrcado, oVlrOrc, @nOrc,oTotOrc,@nTotOrc,cPictVal,lExecChg )}
		
		If mv_par03 = 1
			nLin := oSize:GetDimension("RODAPE","LININI")
			nCol := oSize:GetDimension("RODAPE","COLINI")
			@ nLin,nCol TO oSize:GetDimension("RODAPE","LINFIN"), oSize:GetDimension("RODAPE","COLFIN") OF oDlg PIXEL
			
			@ nLin+015,	nCol+10 SAY STR0012 OF oDlg PIXEL //"Total Orcamento"
			@ nLin+015,	nCol+110	SAY oTotOrc VAR nTotOrc;
			PICTURE cPictVal OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE
			
			@ nLin+015, 	nCol + 250	SAY oOrcado Var STR0011 SIZE 180,14 OF oDlg PIXEL //"Orcado"
			@ nLin+015, 	nCol + 450	SAY oVlrOrc Var STR0026 SIZE 160,14 OF oDlg PIXEL COLOR CLR_HBLUE //"Valor"
		Endif
		
		If mv_par03 = 1 //.And. (nTotOrc > 0 .Or. !INCLUI)
			dbSelectArea("TMP")
			TMP->(dbGoTop())
			CTB390DspOrc(oOrcado,oVlrOrc,@nOrc,oTotOrc,@nTotOrc)
		Endif
		
		If INCLUI .Or. ALTERA
			SetKey( VK_F4 , { || (Ctb390Cop(aColsP[Val(TMP->CV1_SEQUEN)], oPeriodo:nAt), CTB390DspOrc(oOrcado,oVlrOrc,@nOrc,oTotOrc,@nTotOrc)) } )
			SetKey( VK_F5 , { || Ctb390xN(Val(TMP->CV1_SEQUEN),aColsP) 	 })
			aButton := { { "DBG06", {|| Ctb390Cop(aColsP[Val(TMP->CV1_SEQUEN)], oPeriodo:nAt) }, STR0022, STR0045 },; //"Replica Valor - <F4>" "Replica"
			{ "form" , {|| Ctb390xN(Val(TMP->CV1_SEQUEN),aColsP)} , STR0038+" - <F5>",STR0046 } } //"Multiplica por" "Multiplica"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de Entrada para adicao de botoes na tela                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF ExistBlock("CT390BTE")
				aCT390BTE := ExecBlock( "CT390BTE" ,.F.,.F. , aButton )
				
				IF ValType(aCT390BTE) == "A" .AND. Len(aCT390BTE) > 0
					FOR nX := 1 to Len( aCT390BTE )
						aAdd( aButton, aCT390BTE[nX] )
					NEXT
				ENDIF
			ENDIF
		Endif                                             
		
		ACTIVATE MSDIALOG oDlg ON INIT ( lExecChg := .t., EnchoiceBar(oDlg,;
		{|| If( If( lCopia, If( !CheckSx3("CV1_REVISA",M->CV1_REVISA,nOpcx), (lSair:=.F.,.F.), (lSair:=.T.,.T.) ),;        
							(lSair:=.T.,.T.)) .And.;
				oGet:TudoOk() .And. Ctb390Ok(aVarTela),;
				(nOpcA:=1,oDlg:End()), nOpcA := 0)}, {||( lSair:=.T.,oDlg:End())},, aButton))
		
		SetKey( VK_F4 , Nil)
		SetKey( VK_F5 , Nil)
		
		If !lSair
			lSair := ( nOpcA==0 )
		Endif

	ENDDO
Else
	If !lCopia .And. !lRevisao 
	 RegToMemory("CV1",.T.,.T.)
	EndIf
		nOpcA := 1
		TMP->(DbGoTop())
	    RecLock("TMP",.F.)
		For nT := 1 to Len(aAuto)
			If CV1->( FieldPos(aAuto[nT,1]) ) > 0
				If Type("M->"+aAuto[nT,1]) != "U"
					M->&(aAuto[nT,1])   := aAuto[nT,2]
					TMP->&(aAuto[nT,1]) := aAuto[nT,2]
				EndIf		
			EndIf
		Next nT
		MsUnlock()
	   
	Ctb390CarCal(Val(TMP->CV1_SEQUEN),nil,.T.,lCopia,.T.) //Carrega calendario

	If aRetAuto[1]
		Ctb390Cop(aColsP[Val(TMP->CV1_SEQUEN)], 1 )	//Replica Valor
	EndIf
	If aRetAuto[2]
		Ctb390xN(Val(TMP->CV1_SEQUEN),aColsP)					//Multiplica por
	EndIf

	if !Ctb390Ok(aVarTela)
		Return .F.
	EndIf
EndIf


If nOpcA <> 1 .or. nOpcx == 2		/// SE NÃO CONFIRMOU A TELA OU FOR VISUALIZACAO
	TMP->(DbCloseArea())
	If _oCTBA3901 <> Nil
		_oCTBA3901:Delete()
		_oCTBA3901 := Nil
	Endif

	RetIndex("CV1")  

	//CTB390Fil()
	CV2->(dbSetOrder(nIndCV2))
	CV2->(dbGoTo(nRecCV2))
	RestArea(aAreaBrw)

	//MsSeek(xFilial()+M->(CV1_ORCMTO+CV1_CALEND+CV1_MOEDA+CV1_REVISA))

	Return(.T.)					//// RETORNA A POSICAO DO CV1 E FINALIZA
Endif

/// PROCESSO PARA A GRAVACAO DO CABECALHO DO ORCAMENTO (CV2)
nCV2Pos := CV2->(Recno())
BEGIN TRANSACTION
If nOpcx == 3
	RecLock("CV2",.T.)		/// SE FOR INCLUSAO, COPIA OU REVISAO
	Field->CV2_FILIAL	:= cCV2Filial
	Field->CV2_ORCMTO	:= M->CV1_ORCMTO
	Field->CV2_CALEND	:= M->CV1_CALEND
	Field->CV2_MOEDA	:= M->CV1_MOEDA
	Field->CV2_REVISA	:= M->CV1_REVISA
	Field->CV2_STATUS	:= M->CV1_STATUS
	CV2->(MsUnlock())
Endif

RecLock("CV2",.F.)
Field->CV2_CALEND	:= M->CV1_CALEND
Field->CV2_MOEDA	:= M->CV1_MOEDA
Field->CV2_REVISA	:= M->CV1_REVISA
Field->CV2_DESCRI	:= M->CV1_DESCRI
If lRevisao .and. lIsAprov
	If lX3Aprova
		Field->CV2_APROVA := cCV1APROVA
	Else
		Field->CV2_APROVA := cUserName
	Endif
Else
	Field->CV2_APROVA   := M->CV1_APROVA
Endif
CV2->(MsUnlock())

END TRANSACTION

FkCommit()			//// EFETIVA A TRANSAÇÃO NO BANCO PARA CONTROLE DE INTEGRIDADE

cRevisa := M->CV1_REVISA

If mv_par01 == 1
	lAtuSal	:= .T.
Else
	lAtuSal	:= .F.
EndIf

If lAtuSal .And. INCLUI .And. !lX3Aprova
	M->CV1_STATUS := "2"
Endif

lForcSaldo := M->CV1_STATUS == "2"

DbSelectArea("TMP")
DbGoTop()
nSequencia := 1

While !Eof()
	
	lIncSeq := .F.
	nLenVal := Len(aColsP[Val(TMP->CV1_SEQUEN)])
	nSEQUEN := Val(TMP->CV1_SEQUEN)
	For nCont := 1 To nLenVal
		DbSelectArea("CV1")

		If lRevisao .And. Len(aColsP[nSEQUEN][nCont]) > 6
			DbGoTo(aColsP[nSEQUEN][nCont][7])
		Else
			DbGoTo(aColsP[nSEQUEN][nCont][6])
		Endif

		If TMP->CV1_FLAG .And. aColsP[nSEQUEN][nCont][6] == 0 .And. CV1->CV1_STATUS <> "2"
			Loop
		Endif
		
		BEGIN TRANSACTION
		
		If nOpcX <> 5 .And. !TMP->CV1_FLAG //.And. ! lRevisao
			TMP->CV1_VALOR := aColsP[nSEQUEN][nCont][4]
		Endif
		
		TMP->CV1_MOEDA	:= M->CV1_MOEDA
		TMP->CV1_DTFIM	:= aColsP[nSEQUEN][nCont][3]
		
		If ALTERA .And. CV1->CV1_VALOR 	<> TMP->CV1_VALOR
			lAltValor	:= .T.
		EndIf
		
		If (lRevisao .Or. (nOpcX = 5 .Or. TMP->CV1_FLAG)) .And. CV1->CV1_STATUS == "2"				// Exclusao - Saldo atualizado ou revisado
			Ctb390SlOn(nOpcx,CV1->CV1_VALOR,aColsP[nSEQUEN][nCont][4],lRevisao,lAltValor)
		ElseIf lRevisao .And. nOpcX == 3 .And. lForcSaldo .And. Empty( CV1->CV1_STATUS )
			Ctb390SlOn(nOpcx,CV1->CV1_VALOR,aColsP[nSEQUEN][nCont][4],lRevisao,lAltValor)
		ElseIf ALTERA .And. ;
			(	CV1->CV1_VALOR 	<> TMP->CV1_VALOR	.Or.;
			TMP->CV1_CT1INI	<> CV1->CV1_CT1INI .Or.;
			TMP->CV1_CT1FIM	<> CV1->CV1_CT1FIM .Or.;
			TMP->CV1_CTTINI	<> CV1->CV1_CTTINI .Or.;
			TMP->CV1_CTTFIM	<> CV1->CV1_CTTFIM .Or.;
			TMP->CV1_CTDINI	<> CV1->CV1_CTDINI .Or.;
			TMP->CV1_CTDFIM	<> CV1->CV1_CTDFIM .Or.;
			TMP->CV1_CTHINI	<> CV1->CV1_CTHINI .Or.;
			TMP->CV1_CTHFIM	<> CV1->CV1_CTHFIM .Or.;
			If(_lCpoEnt05,TMP->CV1_E05INI <> CV1->CV1_E05INI,.F.) .Or.;
			If(_lCpoEnt05,TMP->CV1_E05FIM <> CV1->CV1_E05FIM,.F.) .Or.;
			If(_lCpoEnt06,TMP->CV1_E06INI <> CV1->CV1_E06INI,.F.) .Or.;
			If(_lCpoEnt06,TMP->CV1_E06FIM <> CV1->CV1_E06FIM,.F.) .Or.;
			If(_lCpoEnt07,TMP->CV1_E07INI <> CV1->CV1_E07INI,.F.) .Or.;
			If(_lCpoEnt07,TMP->CV1_E07FIM <> CV1->CV1_E07FIM,.F.) .Or.;
			If(_lCpoEnt08,TMP->CV1_E08INI <> CV1->CV1_E08INI,.F.) .Or.;
			If(_lCpoEnt08,TMP->CV1_E08FIM <> CV1->CV1_E08FIM,.F.) .Or.;
			If(_lCpoEnt09,TMP->CV1_E09INI <> CV1->CV1_E09INI,.F.) .Or.;
			If(_lCpoEnt09,TMP->CV1_E09FIM <> CV1->CV1_E09FIM,.F.) .Or.;
			lAltValor) .and. M->CV1_STATUS == "2"   /// USADO M->CV1 NO CASO DE INCLUSÃO DE LINHA NA ALTERACAO (TMP->CV1 ESTARÁ VAZIO)
			Ctb390SlOn(nOpcx,CV1->CV1_VALOR,aColsP[nSEQUEN][nCont][4],lRevisao,lAltValor)
		Endif
		
		RecLock("CV1", aColsP[nSEQUEN][nCont][6] == 0)
		If nOpcX == 5 .Or. TMP->CV1_FLAG
			If nCont = 1
				For i := 1 to Len(aMemos)
					cVar := aMemos[i][2]
					cVar1:= aMemos[i][1]
					&("M->" + cVar) := &("TMP->" + cVar)
					&("M->" + cVar1) := &("TMP->" + cVar1)
					MSMM(&cVar1,TamSx3(aMemos[i][2])[1],,&cVar,2,,,cAlias,cVar1)
				Next i
			Endif
			
			DbDelete()
			
		Else
			CV1_FILIAL := xFilial("CV1")
			For nVarTela := 1 To Len(aVarTela)
				&("CV1->" + aVarTela[nVarTela][1]) := &("M->" + aVarTela[nVarTela][1])
			Next
			
			If nCont == 1
				For i := 1 to Len(aMemos)
					cVar := aMemos[i][2]
					cVar1:= aMemos[i][1]
					&("M->" + cVar) := &("TMP->" + cVar)
					&("M->" + cVar1) := &("TMP->" + cVar1)
					MSMM(&cVar1,TamSx3(aMemos[i][2])[1],,&cVar,1,,,cAlias,StrTran(cVar1, "TMP->", ""))
				Next i
			Endif
			
			For nCpo := 1 To Len(aHeader)
				If (aHeader[nCpo][08] <> "M" .And. aHeader[nCpo][10] <> "V" )
					Replace &(aHeader[nCpo][2]) With &("TMP->" + aHeader[nCpo][2])
				EndIf
			Next
			
			CV1->CV1_PERIOD	:= aColsP[nSEQUEN][nCont][1]
			CV1->CV1_DTINI	:= aColsP[nSEQUEN][nCont][2]
			CV1->CV1_DTFIM	:= aColsP[nSEQUEN][nCont][3]
			
			CV1->CV1_VALOR	:= aColsP[nSEQUEN][nCont][4]
			CV1->CV1_SEQUEN := StrZero(nSequencia, LEN(CV1->CV1_SEQUEN))
			lIncSeq := .T.			
				
			If lX3Aprova
				If lRevisao .and. lIsAprov
					CV1->CV1_APROVA := cCV1APROVA
				Endif
			Else
				CV1->CV1_APROVA := cUserName
			Endif
		Endif
		
		MsUnLock()
		
		cQuery := "SELECT R_E_C_N_O_ " 
		cQuery += " FROM " + RetSqlName("CV1") + " CV1 "
		cQuery += " WHERE CV1.CV1_FILIAL = '"  + xFilial("CV1")+ "' "
		cQuery += "   AND CV1.CV1_ORCMTO = '"  + M->CV1_ORCMTO + "' "
		cQuery += "   AND CV1.CV1_CALEND = '"  + M->CV1_CALEND + "' "
		cQuery += "   AND CV1.CV1_MOEDA  = '"  + M->CV1_MOEDA  + "' "
		cQuery += "   AND CV1.CV1_REVISA = '"  + cRevisa		  + "' "
		cQuery += "   AND CV1.CV1_SEQUEN > '" + cTmSequen	  + "' "
		cQuery += "   AND D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'tmpDel',.T.,.F.)

		TcSetField( "tmpDel","R_E_C_N_O_","N",15,0)

		DbSelectArea( "tmpDel" )
		WHILE tmpDel->( !Eof() )
				
				DbSelectArea( "CV1" )
				DbGoto( tmpDel->R_E_C_N_O_ )
				Reclock( "CV1" , .F. )
				DbDelete()
				MsUnLock()
				
				tmpDel->( DbSkip() )
		ENDDO
			
		DbSelectArea( "tmpDel" )
		DbCloseArea()
		
		END TRANSACTION
		
		FkCommit()			//// EFETIVA A TRANSAÇÃO NO BANCO PARA CONTROLE DE INTEGRIDADE
		
		// Inclusao
		If M->CV1_STATUS == "2" .And. (	nOpcX = 3 .And. aColsP[nSEQUEN][nCont][4]<> 0 .And. !lRevisao)
			Ctb390SlOn(nOpcx,TMP->CV1_VALOR,aColsP[nSEQUEN][nCont][4],lRevisao,lAltValor)			
		Endif
	Next
	
	If lIncSeq
		nSequencia ++
	Endif
	
	DbSelectArea("TMP")
	DbSkip()
EndDo

Begin Transaction
DO CASE
	CASE nOpcX = 5								//// SE FOR EXCLUSAO
		CV2->(dbGoTo(nCV2Pos))
		If CV2->(Recno()) == nCV2Pos
			RecLock("CV2",.F.)
			dbDelete()
			CV2->(MsUnlock())
		Endif
	CASE lRevisao								//// SE FOR REVISAO MARCA O FLAG DE REVISADO (CV1 E CV2)
		DbSelectArea("CV1")
		For nRevisao  := 1 To Len(aColsP)
			For nCont := 1 To Len(aColsP[nRevisao])
				If Len(aColsP[nRevisao][nCont]) > 6 .And. aColsP[nRevisao][nCont][7] > 0
					DbGoto(aColsP[nRevisao][nCont][7])
					RecLock("CV1", .F.)
					Replace CV1_STATUS With "3"
					MsUnLock()
				Endif
			Next
		Next
		
		CV2->(dbSetOrder(1))
		CV2->(dbGoTo(nCV2Pos))
		If CV2->(Recno()) == nCV2Pos
			RecLock("CV2",.F.)
			Field->CV2_STATUS := "3"
			CV2->(MsUnlock())
		Endif
	CASE lAtuSal .And. INCLUI .And. !lX3Aprova
			RecLock("CV2",.F.)
			Field->CV2_STATUS := "2"
			CV2->(MsUnlock())			
ENDCASE
END TRANSACTION

//Caso haja algum registro com os valore debito e credito zerados nos arquivos de saldos, deletar o
//registro fisicamente.
 
Ctb390Apag("CQ8",.T.,M->CV1_MOEDA,xFilial("CQ8"))
Ctb390Apag("CQ9",.T.,M->CV1_MOEDA,xFilial("CQ9"))

Ctb390Apag("CQ6",.T.,M->CV1_MOEDA,xFilial("CQ6"))
Ctb390Apag("CQ7",.T.,M->CV1_MOEDA,xFilial("CQ7"))

Ctb390Apag("CQ4",.T.,M->CV1_MOEDA,xFilial("CQ4"))
Ctb390Apag("CQ5",.T.,M->CV1_MOEDA,xFilial("CQ5"))
	    
Ctb390Apag("CQ2",.T.,M->CV1_MOEDA,xFilial("CQ2"))
Ctb390Apag("CQ3",.T.,M->CV1_MOEDA,xFilial("CQ3"))

Ctb390Apag("CQ0",.T.,M->CV1_MOEDA,xFilial("CQ0"))
Ctb390Apag("CQ1",.T.,M->CV1_MOEDA,xFilial("CQ1"))

If l390Grv 								/// PE APOS A GRAVACAO DO ORCAMENTO
	ExecBlock("CTB390GRV", .F., .F.,{nOpcX,M->CV1_ORCMTO,M->CV1_CALEND,M->CV1_MOEDA,M->CV1_REVISA})
Endif
TMP->(DbCloseArea())

If _oCTBA3901 <> Nil
	_oCTBA3901:Delete()
	_oCTBA3901 := Nil
Endif

RetIndex("CV1")
//CTB390Fil()
//MsSeek(xFilial()+M->(CV1_ORCMTO+CV1_CALEND+CV1_MOEDA+CV1_REVISA))
CV2->(dbSetOrder(nIndCV2))
CV2->(dbGoTo(nRecCV2))
RestArea(aAreaBrw)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTB390Edt³ Autor ³ Wagner Mobile Costa   ³ Data ³ 02/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida confirmacao da tela de  cadastro de orcamentos	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB390Edt(oListBox,aColsP)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oListBox = Objeto list-box em edicao                       ³±±
±±³          ³ aColsP    = Array aColsP com dados apresentado             ³±±
±±³          ³ cPictVal = Mascara para edicao de campo de valor           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTB390Edt(oListBox,aColsP,cPictVal,lAutomato)

Local nClick := 0, aEdit := Aclone(aColsP)

nClick := oListBox:nAtCol(4)

If nClick <> 1
	
	CTG->(DbSeek(xFilial() + M->CV1_CALEND))
	While CTG->CTG_CALEND = M->CV1_CALEND .And. ! CTG->(Eof())
		If 	CTG->CTG_STATUS <> "1" .And.;
			aColsP[Val(TMP->CV1_SEQUEN)][oListBox:nAt][1] = CTG->CTG_PERIOD
			Help(" ",1,"CTGDTCOMP")
			Return
		Endif
		CTG->(DbSkip())
	EndDo
	
	lEditCell(aEdit[Val(TMP->CV1_SEQUEN)],oListBox,cPictVal,4)
	aColsP := aClone(aEdit)
	aColsP[Val(TMP->CV1_SEQUEN)] := aEdit[Val(TMP->CV1_SEQUEN)]
	oListBox:Refresh()
	oListBox:SetFocus()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTB390Cop³ Autor ³ Wagner Mobile Costa   ³ Data ³ 28/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida confirmacao da tela de  cadastro de orcamentos	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB390Cop(aColsP,nPos)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aColsP    = Array aColsP com dados apresentado             ³±±
±±³          ³ nPos      = Linha atual no list de digitacao de valores    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Ctb390Cop(aColsP,nPos)

Local nOrc

For nOrc := nPos + 1 To Len(aColsP)
	aColsP[nOrc][4] := aColsP[nPos][4]
Next

CTB390DspOrc(oOrcado,oVlrOrc,@nOrc,oTotOrc,@nTotOrc)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTB390Ok ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 02/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida confirmacao da tela de  cadastro de orcamentos	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB390Ok(aVarTela)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Botao de confirmacao                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aVarTela = Variaveis apresentadas em tela                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB390Ok(aVarTela)

Local nVarTela
Local nRecTmp 	:= TMP->(Recno())
Local cMemCV1 	:= M->(CV1_ORCMTO+CV1_CALEND+CV1_MOEDA+CV1_REVISA)
Local nCountLin	:= 0

If INCLUI .OR. (ALTERA .AND. cMemCV1 <> CV2->(CV2_ORCMTO+CV2_CALEND+CV2_MOEDA+CV2_REVISA))
	nOrdCV1 := CV1->(IndexOrd())
	nRecCV1 := CV1->(Recno())
	CV1->(dbSetOrder(1))
	If CV1->(dbSeek(xFilial("CV1")+cMemCV1))
		CV1->(dbSetOrder(nOrdCV1))
		CV1->(dbGoTo(nRecCV1))
		Return .F.
	Endif
Endif

If ExistBlock("CTB390TOK") .And. ! ExecBlock("CTB390TOK", .F., .F.)
	Return .F.
Endif

If INCLUI
	If ! ExistChav("CV1", 	M->CV1_ORCMTO+M->CV1_CALEND+;
		M->CV1_MOEDA+M->CV1_REVISA)
		Return .F.
	Endif
Endif

For nVarTela := 1 To Len(aVarTela)
	If aVarTela[nVarTela][2] .And. Empty(&("M->" + aVarTela[nVarTela][1]))
		HELP("   ",1,"OBRIGAT",,STR0013+aVarTela[nVarTela][1]+SPACE(40),3,0) //"Campo : "
		Return .F.
	Endif
Next

TMP->(DbGoTop())
While ! TMP->(Eof())
	If TMP->CV1_FLAG
		TMP->(DbSkip())
		Loop
	Endif

	// Contador de linhas disponiveis no orçamento
	nCountLin++
		
	If (!Empty(TMP->CV1_CT1INI) .And. Empty(TMP->CV1_CT1FIM))	.Or.;
		(Empty(TMP->CV1_CT1INI) .And. !Empty(TMP->CV1_CT1FIM))
		Help(" ",1,"C160NOCTA")
		Return .F.
	EndIf
	
	If (!Empty(TMP->CV1_CTTINI) .And. Empty(TMP->CV1_CTTFIM)) 	.Or.;
		(Empty(TMP->CV1_CTTINI) .And. !Empty(TMP->CV1_CTTFIM))
		Help(" ",1,"C160NOCC")
		Return .F.
	EndIf
	
	If (!Empty(TMP->CV1_CTDINI) .And. Empty(TMP->CV1_CTDFIM)) 	.Or.;
		(Empty(TMP->CV1_CTDINI) .And. !Empty(TMP->CV1_CTDFIM))
		Help(" ",1,"C160NOITEM")
		Return .F.
	EndIf
	
	If (!Empty(TMP->CV1_CTHINI) .And. Empty(TMP->CV1_CTHFIM))	.Or.;
		(Empty(TMP->CV1_CTHINI) .And. !Empty(TMP->CV1_CTHFIM))
		Help(" ",1,"C160NOCLVL")
		Return .F.
	EndIf

	If _lCpoEnt05
		If (!Empty(TMP->CV1_E05INI) .And. Empty(TMP->CV1_E05FIM))	.Or.;
			(Empty(TMP->CV1_E05INI) .And. !Empty(TMP->CV1_E05FIM))
			Help(" ",1,"C160NOEC05")
			Return .F.
		EndIf		
	EndIf
         
	If _lCpoEnt06
		If (!Empty(TMP->CV1_E06INI) .And. Empty(TMP->CV1_E06FIM))	.Or.;
			(Empty(TMP->CV1_E06INI) .And. !Empty(TMP->CV1_E06FIM))
			Help(" ",1,"C160NOEC06")
			Return .F.
		EndIf		
	EndIf

	If _lCpoEnt07
		If (!Empty(TMP->CV1_E07INI) .And. Empty(TMP->CV1_E07FIM))	.Or.;
			(Empty(TMP->CV1_E07INI) .And. !Empty(TMP->CV1_E07FIM))
			Help(" ",1,"C160NOEC07")
			Return .F.
		EndIf		
	EndIf

	If _lCpoEnt08
		If (!Empty(TMP->CV1_E08INI) .And. Empty(TMP->CV1_E08FIM))	.Or.;
			(Empty(TMP->CV1_E08INI) .And. !Empty(TMP->CV1_E08FIM))
			Help(" ",1,"C160NOEC08")
			Return .F.
		EndIf		
	EndIf

	If _lCpoEnt09
		If (!Empty(TMP->CV1_E09INI) .And. Empty(TMP->CV1_E09FIM))	.Or.;
			(Empty(TMP->CV1_E09INI) .And. !Empty(TMP->CV1_E09FIM))
			Help(" ",1,"C160NOEC09")
			Return .F.
		EndIf		
	EndIf

	If 	Empty(TMP->CV1_CT1INI) .And. Empty(TMP->CV1_CT1FIM) .And.;
		Empty(TMP->CV1_CTTINI) .And. Empty(TMP->CV1_CTTFIM) .And.;
		Empty(TMP->CV1_CTDINI) .And. Empty(TMP->CV1_CTDFIM) .And.;
		Empty(TMP->CV1_CTHINI) .And. Empty(TMP->CV1_CTHFIM) .And.;
		If(_lCpoEnt05,Empty(TMP->CV1_E05INI) .And. Empty(TMP->CV1_E05FIM),.T.) .And.;
		If(_lCpoEnt06,Empty(TMP->CV1_E06INI) .And. Empty(TMP->CV1_E06FIM),.T.) .And.;
		If(_lCpoEnt07,Empty(TMP->CV1_E07INI) .And. Empty(TMP->CV1_E07FIM),.T.) .And.;
		If(_lCpoEnt08,Empty(TMP->CV1_E08INI) .And. Empty(TMP->CV1_E08FIM),.T.) .And.;
		If(_lCpoEnt09,Empty(TMP->CV1_E09INI) .And. Empty(TMP->CV1_E09FIM),.T.)
		
		Apmsginfo(STR0014, STR0008) //"Indique a entidade a ser orcada !"###"Atencao"
		Return .F.
	Endif
	
	TMP->(DbSkip())
EndDo

TMP->(DbGoto(nRecTmp))

If nCountLin <= 0
	Apmsginfo(STR0014, STR0008) //"Indique a entidade a ser orcada !"###"Atencao"
	Return .F.
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTB390LOk³ Autor ³ Wagner Mobile Costa   ³ Data ³ 03/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Avalia a linha da GetDb                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB390LOk(aVarTela)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Valida Linha da GetDb                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB390LOk
Local lOk := .T.

If 	Empty(TMP->CV1_CT1INI) .And. Empty(TMP->CV1_CT1FIM) .And.;
	Empty(TMP->CV1_CTTINI) .And. Empty(TMP->CV1_CTTFIM) .And.;
	Empty(TMP->CV1_CTDINI) .And. Empty(TMP->CV1_CTDFIM) .And.;
	Empty(TMP->CV1_CTHINI) .And. Empty(TMP->CV1_CTHFIM) .And.;
	If(_lCpoEnt05,Empty(TMP->CV1_E05INI) .And. Empty(TMP->CV1_E05FIM),.T.) .And.;
	If(_lCpoEnt06,Empty(TMP->CV1_E06INI) .And. Empty(TMP->CV1_E06FIM),.T.) .And.;
	If(_lCpoEnt07,Empty(TMP->CV1_E07INI) .And. Empty(TMP->CV1_E07FIM),.T.) .And.;
	If(_lCpoEnt08,Empty(TMP->CV1_E08INI) .And. Empty(TMP->CV1_E08FIM),.T.) .And.;
	If(_lCpoEnt09,Empty(TMP->CV1_E09INI) .And. Empty(TMP->CV1_E09FIM),.T.) .And.;
	! TMP->CV1_FLAG

	Apmsginfo(STR0014, STR0008) //"Indique a entidade a ser orcada !"###"Atencao"

	lOk := .F.
Endif

// validação para o tamanho maximo da sequencia do orçamento
IF lOk .And. ! TMP->CV1_FLAG
	If ( TMP->CV1_SEQUEN > cTmSequen )
		Apmsginfo( STR0047 + Alltrim( cTmSequen ) + ".", STR0008) //"O numero maximo de sequencia permitido é de xxxxx !"###"Atencao"
		lOk := .F.
	Endif
ENDIF

If lOk
	lOk := CTB390Ok(aVTelaAux)
EndIf

If lOk .And. ExistBlock("CTB390LOK") .And. ! ExecBlock("CTB390LOK", .F., .F.)
	lOk := .F.
Endif

Return lOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTB390PES³ Autor ³ Claudio D. de Souza   ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa com filtro                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB390PES()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA390                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb390Pes

AxPesqui()
//Ctb390Fil()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTB390CarCal³ Autor ³ Wagner Mobile Costa ³ Data ³ 03/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega definicoes do calendario atual                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB390CarCal(nLinGetDb,oPeriodo)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA390                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nLinGetDb = Identifica a linha atual do GetDb              ³±±
±±³          ³ oPeriodo  = ListBox que contem os periodos digitados       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb390CarCal(nLinGetDb, oPeriodo, lTodas, lCopia, lAutomato)

Local aArea := GetArea(), nCont := 1
Local aColsPOld	 := {}
Local cPictVal 	:= ""
Local nP
Local nC

DEFAULT lTodas := .F.
DEFAULT lCopia := .F.
DEFAULT lAutomato := .F.
DEFAULT oPeriodo := Nil
If nLinGetDb == 0 .or. ValType(nLinGetDb) <> "N"
	Return .T.
Endif

If Empty(M->CV1_CALEND) .Or. Empty(M->CV1_MOEDA)
	Return .T.
Endif

CTE->(DbSetOrder(1))
If ! CTE->(DbSeek(xFilial() + M->CV1_MOEDA + M->CV1_CALEND))
	Help("  ",1,"CTGNOCAD")
	Return .F.
Endif

If lAutomato
	aColsP[1][1][nPosValor] := TMP->CV1_VALOR
EndIf

dbSelectArea("CTG")
dbSeek(xFilial()+M->CV1_CALEND)

If lTodas .and. lCopia
	aColsPold := aClone(aColsP)
	aColsP := {}
EndIf
While !Eof() .And. xFilial() == CTG->CTG_FILIAL .And.;
	CTG->CTG_CALEND == M->CV1_CALEND
	
	If Len(aColsP) < nLinGetDb
		AADD(aColsP, {})
	Endif
	
	If Len(aColsP[nLinGetDb]) < nCont
		AADD(aColsP[nLinGetDb], Array(6) )
		aColsP[nLinGetDb][nCont][1]	:= CTG->CTG_PERIOD
		aColsP[nLinGetDb][nCont][2]	:= CTG->CTG_DTINI
		aColsP[nLinGetDb][nCont][3]	:= CTG->CTG_DTFIM
		aColsP[nLinGetDb][nCont][4]	:= 0.00
		aColsP[nLinGetDb][nCont][6]	:= 0
	ElseIf Empty(aColsP[nLinGetDb][nCont][1]) .Or. INCLUI
		aColsP[nLinGetDb][nCont][1]	:= CTG->CTG_PERIOD
		aColsP[nLinGetDb][nCont][2]	:= CTG->CTG_DTINI
		aColsP[nLinGetDb][nCont][3]	:= CTG->CTG_DTFIM
	Endif
	
	nCont++
	dbSkip()
	
EndDo

dbSelectArea("TMP")
ASize(aColsP[nLinGetDb], nCont - 1)
If lTodas .and. lCopia
	For nC:= 1 to Len(aColsPOld)
		If nC <> 1
			aAdd(aColsP,aClone(aColsP[1]))
			nCont++
		EndIf
		If Len(aColsPOld) < nC
			Exit
		EndIf			
		For nP := 1 to Len(aColsP[nC])
			If Len(aColsPOld[nC]) < nP
				Exit
			EndIf			
			aColsP[nC][nP][4] := aColsPOld[nC][nP][4]
			aColsP[nC][nP][5] := 0
			aColsP[nC][nP][6] := 0
		Next
	Next
	If !lAutomato
		oPeriodo:SetArray(aColsP[Val(TMP->CV1_SEQUEN)])
		cPictVal := PesqPict("CV1","CV1_VALOR")
		oPeriodo:bLine := { ||{ aColsP[Val(TMP->CV1_SEQUEN)][oPeriodo:nAt,1],aColsP[Val(TMP->CV1_SEQUEN)][oPeriodo:nAt,2],aColsP[Val(TMP->CV1_SEQUEN)][oPeriodo:nAt,3],Trans(aColsP[Val(TMP->CV1_SEQUEN)][oPeriodo:nAt,4], cPictVal) } }
	endif
EndIf

If !lAutomato
	oPeriodo:Refresh()
EndIf

RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTB390POrc ³ Autor ³ Wagner Mobile Costa ³ Data ³ 08/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Avalia se permite a entrada do campo de acordo com o tipo  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB390PerOrc()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA390                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb390POrc

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTB390Vld  ³ Autor ³ Wagner Mobile Costa ³ Data ³ 10/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida as entidades contabeis digitadas                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB390Vld()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA390                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cVariavel = Nome da variavel para identificar validacao    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb390Vld(cVariavel)

Local lRet 		:= .T.
Local cNomeCpo	:= ReadVar()
Local cEntidade := Subs(cNomeCpo, 8, 3)
Local lGatilha	:= mv_par02 = 1 .And. cVariavel = Nil .And. Right(cNomeCpo, 3) = "INI"
Local lAlterou  := .F.
Local cAliasEnt	:= cEntidade
Local nIndEnt	:= 1

If cEntidade $ "E05|E06|E07|E08|E09"
	dbSelectArea("CT0")
	dbSetOrder(1)
	dbSeek(xFilial("CT0"))
	Do While !CT0->(Eof()) .And. CT0->CT0_FILIAL==xFilial("CT0")
		If CT0->CT0_ID=="05"
			cAliasEnt := CT0->CT0_ALIAS
			nIndEnt := aIndexes[5][1]
		EndIf
		If CT0->CT0_ID=="06"
			cAliasEnt := CT0->CT0_ALIAS
			nIndEnt := aIndexes[6][1]
		EndIf
		If CT0->CT0_ID=="07"
			cAliasEnt := CT0->CT0_ALIAS
			nIndEnt := aIndexes[7][1]
		EndIf
		If CT0->CT0_ID=="08"
			cAliasEnt := CT0->CT0_ALIAS
			nIndEnt := aIndexes[8][1]
		EndIf
		If CT0->CT0_ID=="09"
			cAliasEnt := CT0->CT0_ALIAS
			nIndEnt := aIndexes[9][1]
		EndIf
		CT0->(dbSkip())
	EndDo
EndIf

If cVariavel = Nil
	cVariavel := &(cNomeCpo)
Endif

dbSelectArea(cAliasEnt)
dbSetOrder(nIndEnt)

If Empty(cVariavel)
	Return .T.
Endif

If cEntidade = "CT1"
	lRet := Ctb105Cta(cVariavel)
	If &("TMP->" + StrTran(cNomeCpo, "M->", "")) <> cVariavel
		lAlterou := .T.
	Endif
	If lRet
		ConvConta(@cVariavel)
		&("TMP->" + StrTran(cNomeCpo, "M->", "")) := cVariavel
	Endif
ElseIf cEntidade = "CTT"
	lRet := Ctb105Cc(cVariavel)
	If &("TMP->" + StrTran(cNomeCpo, "M->", "")) <> cVariavel
		lAlterou := .T.
	Endif
	If lRet
		ConvCusto(@cVariavel)
		&("TMP->" + StrTran(cNomeCpo, "M->", "")) := cVariavel
	Endif
ElseIf cEntidade = "CTD"
	lRet := Ctb105Item(cVariavel)
	If &("TMP->" + StrTran(cNomeCpo, "M->", "")) <> cVariavel
		lAlterou := .T.
	Endif
	If lRet
		ConvItem(@cVariavel)
		&("TMP->" + StrTran(cNomeCpo, "M->", "")) := cVariavel
	Endif
ElseIf cEntidade = "CTH"
	lRet := Ctb105ClVl(cVariavel)
	If &("TMP->" + StrTran(cNomeCpo, "M->", "")) <> cVariavel
		lAlterou := .T.
	Endif
	If lRet      
		ConvClvl(@cVariavel)
		&("TMP->" + StrTran(cNomeCpo, "M->", "")) := cVariavel
	Endif
ElseIf cEntidade $ "E05|E06|E07|E08|E09"
	lRet := CTB105EntC(,cVariavel,,Right(cEntidade,2))
	If &("TMP->" + StrTran(cNomeCpo, "M->", "")) <> cVariavel
		lAlterou := .T.
	Endif
	If lRet      
		&("TMP->" + StrTran(cNomeCpo, "M->", "")) := cVariavel
	Endif
Endif

If 	lRet .And. lGatilha .And. lAlterou // Se Alterou o conteudo
	&("TMP->" + StrTran(StrTran(cNomeCpo, "M->", ""), "INI", "FIM")) := cVariavel
Endif

If mv_par03 = 1 .And. lRet
	Ctb390CarCal(VAL(TMP->CV1_SEQUEN), oPeriodo)
	CTB390DspOrc(oOrcado,oVlrOrc,@nOrc,oTotOrc,@nTotOrc)
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTB390DspOrc³ Autor ³ Wagner Mobile Costa ³ Data ³ 05/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para atualizar a entidade atual da GetDb            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB390DspOrc(oOrcado,oVlrOrc,nOrc,oTotOrc,nTotOrc)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA390                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oOrcado   = Objeto com a descricao do tipo de orcamento    ³±±
±±³          ³ oVlrOrc   = Objeto com o valor do orcamento da linha       ³±±
±±³          ³ nOrc      = Variavel com o valor da linha atual orcamento  ³±±
±±³          ³ oTotOrc   = Objeto com o total do orcamento          	  ³±±
±±³          ³ nTotOrc   = Variavel com o valor total do orcamento  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB390DspOrc(oOrcado,oVlrOrc,nOrc,oTotOrc,nTotOrc,nSeqColsP)

Local cTitulo 		:= cF3 := "", lMostra, nCont, nCols, nRecno := TMP->(Recno())
Local cCpoDsc
Local nEntidades	:= Ct390CtEnt(, @cF3, @lMostra, @cTitulo, @cCpoDsc)
Local nTtOrc		:= 0

If mv_par03 # 1
	Return .T.
EndIf

If ValType(nSeqColsP) <> "N"
	nSeqColsP := Val(TMP->CV1_SEQUEN)
EndIf

TMP->CV1_ENTIDA := nEntidades

If nOrc # Nil .And. nSeqColsP <= Len(aColsP) .And. nSeqColsP > 0
	nOrc := 0
	For nCont := 1 To Len(aColsP[nSeqColsP])
		nOrc += aColsP[nSeqColsP][nCont][4] * TMP->CV1_ENTIDA
	Next
Endif

If oOrcado <> Nil
	If cF3 $ "CT1,CTT,CTD,CTH"
		If M->CV1_MOEDA > "01" .And. Empty(&(cF3 + "->" + cF3 + "_DESC" + M->CV1_MOEDA))
			oOrcado:cCaption := &(cF3 + "->" + cF3 + "_DESC01")
		Else
			oOrcado:cCaption := &(cF3 + "->" + cF3 + "_DESC" + M->CV1_MOEDA)
		Endif
	ElseIf cF3 == "CV0"
		oOrcado:cCaption := &(cF3 + "->" + cF3 + "_DESC")
	Else
		oOrcado:cCaption := &(cF3 + "->" + cCpoDsc)
	EndIf					
	
	oOrcado:cCaption := STR0016 + AllTrim(cTitulo) + " "+ /*"Orcado "*/If(lMostra, AllTrim(oOrcado:cCaption) + " ", "")
	oVlrOrc:cCaption := AllTrim(Trans(nOrc, Tm(0, 21, 2)))
	oOrcado:Refresh()
	oVlrOrc:Refresh()
Endif

If nTotOrc <> Nil
	nTtOrc := 0
	TMP->(DbGoTop())
	While TMP->(!Eof())
		If TMP->CV1_FLAG
			TMP->(dbSkip())
			Loop
		Endif
		
		If ( ! Empty( TMP->CV1_SEQUEN ) .And. TMP->CV1_SEQUEN <> Nil .And. TMP->CV1_SEQUEN <= cTmSequen  )
		
			nSeqColsP := Val(TMP->CV1_SEQUEN)

			IF ( nSeqColsP > 0 .And. nSeqColsP <> nil .And. Len(aColsP) >= nSeqColsP)

				For nCont := 1 To Len(aColsP[nSeqColsP])
					nTtOrc += aColsP[nSeqColsP][nCont][4] * TMP->CV1_ENTIDA
				Next

			Endif
		Endif

		TMP->(dbSkip())
	EndDo
	TMP->(DbGoTo(nRecno))
	
	If nTtOrc <> 0
		nTotOrc := nTtOrc

		If oTotOrc <> Nil
			oTotOrc:Refresh()
		Endif
	Endif
	
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CT390CtEnt ³ Autor ³ Wagner Mobile Costa ³ Data ³ 05/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina que conta o numero de entidades                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CT390CtEnt(cF3,cTitulo)                      			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA390                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cF3       = Tabela do valor final do orcamento             ³±±
±±³          ³ lMostra   = Indica se apresenta descricao da entidade      ³±±
±±³          ³ cTitulo   = Titulo da entidade orcada                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CT390CtEnt(cAlias, cF3, lMostra, cTitulo, cCpoDsc)

Local nEntida1 := nEntida2 := nEntida3 := nEntida4 :=  nEntidades := 1, aArea := {}
Local nEntida5 := nEntida6 := nEntida7 := nEntida8 := nEntida9 := 1 //variaveis utilizadas para as nvoas entidades contabeis
Local aAlias   := If(cTitulo = Nil, GetArea(),)
Local cTabela  := If(cF3 = Nil, "", cF3), aCadastro
Local cIdEntid := ""

DEFAULT cAlias := "TMP"

If ! Empty(cTabela)
	If cTabela = "CQ0"
		aCadastro := CT1->(GetArea())
	ElseIf cTabela = "CQ2"
		aCadastro := CTT->(GetArea())
	ElseIf cTabela = "CQ4"
		aCadastro := CTD->(GetArea())
	ElseIf cTabela = "CQ6"
		aCadastro := CTH->(GetArea())
	Endif
Endif

If _lCpoEnt09 .And. !Empty((cAlias)->CV1_E09INI)
	cPlanoEnt	:= ""
	cIdEntid	:= "09"
	
	dbSelectArea("CT0")
	dbSetOrder(1)
	dbSeek(xFilial("CT0")+cIdEntid)
	cF3 := CT0->CT0_ALIAS
	cCpoDsc := CT0->CT0_CPODSC
	If cF3 == "CV0"
		cPlanoEnt := CT0->CT0_ENTIDA
	Else
		cPlanoEnt := ""
	EndIf
	
	DbSelectArea(cF3)
	MsSeek(xFilial(cF3) + cPlanoEnt + (cAlias)->CV1_E09INI)
	lMostra := (cAlias)->CV1_E09INI = (cAlias)->CV1_E09FIM
	
	If ! lMostra .Or.;
		(_lCpoEnt08 .And. (cAlias)->CV1_E08INI # (cAlias)->CV1_E08FIM) .Or.;	
		(_lCpoEnt07 .And. (cAlias)->CV1_E07INI # (cAlias)->CV1_E07FIM) .Or.;	
		(_lCpoEnt06 .And. (cAlias)->CV1_E06INI # (cAlias)->CV1_E06FIM) .Or.;
		(_lCpoEnt05 .And. (cAlias)->CV1_E05INI # (cAlias)->CV1_E05FIM) .Or.;
		(cAlias)->CV1_CTHINI # (cAlias)->CV1_CTHFIM .Or.;
		(cAlias)->CV1_CTDINI # (cAlias)->CV1_CTDFIM .Or.;
		(cAlias)->CV1_CTTINI # (cAlias)->CV1_CTTFIM .Or.;
		(cAlias)->CV1_CT1INI # (cAlias)->CV1_CT1FIM
		If ! lMostra .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4,CQ6")
			aArea := GetArea()
			nEntida9 := 0
			CT390EntP(_cAlias09, (cAlias)->CV1_E09INI, (cAlias)->CV1_E09FIM, @nEntida9, cIdEntid)
			RestArea(aArea)
		Else
			nEntida9 := 1
		Endif

		If _lCpoEnt08 .And. ((cAlias)->CV1_E08INI # (cAlias)->CV1_E08FIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4,CQ6"))
			nEntida8 := 0
			CT390EntP(_cAlias08, (cAlias)->CV1_E08INI, (cAlias)->CV1_E08FIM, @nEntida8, "08")
		Else
			nEntida8 := 1
		Endif

		If _lCpoEnt07 .And. ((cAlias)->CV1_E07INI # (cAlias)->CV1_E07FIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4,CQ6"))
			nEntida7 := 0
			CT390EntP(_cAlias07, (cAlias)->CV1_E07INI, (cAlias)->CV1_E07FIM, @nEntida7, "07")
		Else
			nEntida7 := 1
		Endif		

		If _lCpoEnt06 .And. ((cAlias)->CV1_E06INI # (cAlias)->CV1_E06FIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4,CQ6"))
			nEntida6 := 0
			CT390EntP(_cAlias06, (cAlias)->CV1_E06INI, (cAlias)->CV1_E06FIM, @nEntida6, "06")
		Else
			nEntida6 := 1
		Endif		
		
		If _lCpoEnt05 .And. ((cAlias)->CV1_E05INI # (cAlias)->CV1_E05FIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4,CQ6"))
			nEntida5 := 0
			CT390EntP(_cAlias05, (cAlias)->CV1_E05INI, (cAlias)->CV1_E05FIM, @nEntida5, "05")
		Else
			nEntida5 := 1
		Endif		
				
		If (cAlias)->CV1_CTHINI # (cAlias)->CV1_CTHFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4")
			nEntida3 := 0
			CT390EntP("CTH", (cAlias)->CV1_CTHINI, (cAlias)->CV1_CTHFIM, @nEntida3)
		Else
			nEntida3 := 1
		Endif		
		
		If (cAlias)->CV1_CTDINI # (cAlias)->CV1_CTDFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2")
			nEntida2 := 0
			CT390EntP("CTD", (cAlias)->CV1_CTDINI, (cAlias)->CV1_CTDFIM, @nEntida2)
		Else
			nEntida2 := 1
		Endif
		
		If (cAlias)->CV1_CTTINI # (cAlias)->CV1_CTTFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0")
			nEntida1 := 0
			CT390EntP("CTT", (cAlias)->CV1_CTTINI, (cAlias)->CV1_CTTFIM, @nEntida1)
		Else
			nEntida1 := 1
		Endif
		
		If (cAlias)->CV1_CT1INI # (cAlias)->CV1_CT1FIM .And. Empty(cTabela)
			nEntidades := 0
			CT390EntP("CT1", (cAlias)->CV1_CT1INI, (cAlias)->CV1_CT1FIM, @nEntidades)
		Endif
		
		nEntidades *= nEntida1
		nEntidades *= nEntida2
		nEntidades *= nEntida3
		nEntidades *= nEntida5
		nEntidades *= nEntida6
		nEntidades *= nEntida7
		nEntidades *= nEntida8
		nEntidades *= nEntida9								
	Endif 
	
//********************************************************************************************************************************

ElseIf _lCpoEnt08 .And. !Empty((cAlias)->CV1_E08INI)
	cPlanoEnt	:= ""
	cIdEntid	:= "08"
	
	dbSelectArea("CT0")
	dbSetOrder(1)
	dbSeek(xFilial("CT0")+cIdEntid)
	cF3 := CT0->CT0_ALIAS
	cCpoDsc := CT0->CT0_CPODSC
	If cF3 == "CV0"
		cPlanoEnt := CT0->CT0_ENTIDA
	Else
		cPlanoEnt := ""
	EndIf
	
	DbSelectArea(cF3)
	MsSeek(xFilial(cF3) + cPlanoEnt + (cAlias)->CV1_E08INI)
	lMostra := (cAlias)->CV1_E08INI = (cAlias)->CV1_E08FIM
	
	If ! lMostra .Or.;
		(_lCpoEnt07 .And. (cAlias)->CV1_E07INI # (cAlias)->CV1_E07FIM) .Or.;	
		(_lCpoEnt06 .And. (cAlias)->CV1_E06INI # (cAlias)->CV1_E06FIM) .Or.;
		(_lCpoEnt05 .And. (cAlias)->CV1_E05INI # (cAlias)->CV1_E05FIM) .Or.;
		(cAlias)->CV1_CTHINI # (cAlias)->CV1_CTHFIM .Or.;
		(cAlias)->CV1_CTDINI # (cAlias)->CV1_CTDFIM .Or.;
		(cAlias)->CV1_CTTINI # (cAlias)->CV1_CTTFIM .Or.;
		(cAlias)->CV1_CT1INI # (cAlias)->CV1_CT1FIM
		If ! lMostra .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4,CQ6")
			aArea := GetArea()
			nEntida8 := 0
			CT390EntP(_cAlias08, (cAlias)->CV1_E08INI, (cAlias)->CV1_E08FIM, @nEntida8, cIdEntid)
			RestArea(aArea)
		Else
			nEntida8 := 1
		Endif

		If _lCpoEnt07 .And. ((cAlias)->CV1_E07INI # (cAlias)->CV1_E07FIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4,CQ6"))
			nEntida7 := 0
			CT390EntP(_cAlias07, (cAlias)->CV1_E07INI, (cAlias)->CV1_E07FIM, @nEntida7, "07")
		Else
			nEntida7 := 1
		Endif		

		If _lCpoEnt06 .And. ((cAlias)->CV1_E06INI # (cAlias)->CV1_E06FIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4,CQ6"))
			nEntida6 := 0
			CT390EntP(_cAlias06, (cAlias)->CV1_E06INI, (cAlias)->CV1_E06FIM, @nEntida6, "06")
		Else
			nEntida6 := 1
		Endif		
		
		If _lCpoEnt05 .And. ((cAlias)->CV1_E05INI # (cAlias)->CV1_E05FIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4,CQ6"))
			nEntida5 := 0
			CT390EntP(_cAlias05, (cAlias)->CV1_E05INI, (cAlias)->CV1_E05FIM, @nEntida5, "05")
		Else
			nEntida5 := 1
		Endif		
				
		If (cAlias)->CV1_CTHINI # (cAlias)->CV1_CTHFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4")
			nEntida3 := 0
			CT390EntP("CTH", (cAlias)->CV1_CTHINI, (cAlias)->CV1_CTHFIM, @nEntida3)
		Else
			nEntida3 := 1
		Endif		
		
		If (cAlias)->CV1_CTDINI # (cAlias)->CV1_CTDFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2")
			nEntida2 := 0
			CT390EntP("CTD", (cAlias)->CV1_CTDINI, (cAlias)->CV1_CTDFIM, @nEntida2)
		Else
			nEntida2 := 1
		Endif
		
		If (cAlias)->CV1_CTTINI # (cAlias)->CV1_CTTFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0")
			nEntida1 := 0
			CT390EntP("CTT", (cAlias)->CV1_CTTINI, (cAlias)->CV1_CTTFIM, @nEntida1)
		Else
			nEntida1 := 1
		Endif
		
		If (cAlias)->CV1_CT1INI # (cAlias)->CV1_CT1FIM .And. Empty(cTabela)
			nEntidades := 0
			CT390EntP("CT1", (cAlias)->CV1_CT1INI, (cAlias)->CV1_CT1FIM, @nEntidades)
		Endif
		
		nEntidades *= nEntida1
		nEntidades *= nEntida2
		nEntidades *= nEntida3
		nEntidades *= nEntida5
		nEntidades *= nEntida6
		nEntidades *= nEntida7
		nEntidades *= nEntida8
	Endif	
	
//********************************************************************************************************************************

ElseIf _lCpoEnt07 .And. !Empty((cAlias)->CV1_E07INI)
	cPlanoEnt	:= ""
	cIdEntid	:= "07"
	
	dbSelectArea("CT0")
	dbSetOrder(1)
	dbSeek(xFilial("CT0")+cIdEntid)
	cF3 := CT0->CT0_ALIAS
	cCpoDsc := CT0->CT0_CPODSC
	If cF3 == "CV0"
		cPlanoEnt := CT0->CT0_ENTIDA
	Else
		cPlanoEnt := ""
	EndIf
	
	DbSelectArea(cF3)
	MsSeek(xFilial(cF3) + cPlanoEnt + (cAlias)->CV1_E07INI)
	lMostra := (cAlias)->CV1_E07INI = (cAlias)->CV1_E07FIM
	
	If ! lMostra .Or.;
		(_lCpoEnt06 .And. (cAlias)->CV1_E06INI # (cAlias)->CV1_E06FIM) .Or.;
		(_lCpoEnt05 .And. (cAlias)->CV1_E05INI # (cAlias)->CV1_E05FIM) .Or.;
		(cAlias)->CV1_CTHINI # (cAlias)->CV1_CTHFIM .Or.;
		(cAlias)->CV1_CTDINI # (cAlias)->CV1_CTDFIM .Or.;
		(cAlias)->CV1_CTTINI # (cAlias)->CV1_CTTFIM .Or.;
		(cAlias)->CV1_CT1INI # (cAlias)->CV1_CT1FIM
		If ! lMostra .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4,CQ6")
			aArea := GetArea()
			nEntida7 := 0
			CT390EntP(_cAlias07, (cAlias)->CV1_E07INI, (cAlias)->CV1_E07FIM, @nEntida7, cIdEntid)
			RestArea(aArea)
		Else
			nEntida7 := 1
		Endif

		If _lCpoEnt06 .And. ((cAlias)->CV1_E06INI # (cAlias)->CV1_E06FIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4,CQ6"))
			nEntida6 := 0
			CT390EntP(_cAlias06, (cAlias)->CV1_E06INI, (cAlias)->CV1_E06FIM, @nEntida6, "06")
		Else
			nEntida6 := 1
		Endif		
		
		If _lCpoEnt05 .And. ((cAlias)->CV1_E05INI # (cAlias)->CV1_E05FIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4,CQ6"))
			nEntida5 := 0
			CT390EntP(_cAlias05, (cAlias)->CV1_E05INI, (cAlias)->CV1_E05FIM, @nEntida5, "05")
		Else
			nEntida5 := 1
		Endif		
				
		If (cAlias)->CV1_CTHINI # (cAlias)->CV1_CTHFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4")
			nEntida3 := 0
			CT390EntP("CTH", (cAlias)->CV1_CTHINI, (cAlias)->CV1_CTHFIM, @nEntida3)
		Else
			nEntida3 := 1
		Endif		
		
		If (cAlias)->CV1_CTDINI # (cAlias)->CV1_CTDFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2")
			nEntida2 := 0
			CT390EntP("CTD", (cAlias)->CV1_CTDINI, (cAlias)->CV1_CTDFIM, @nEntida2)
		Else
			nEntida2 := 1
		Endif
		
		If (cAlias)->CV1_CTTINI # (cAlias)->CV1_CTTFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0")
			nEntida1 := 0
			CT390EntP("CTT", (cAlias)->CV1_CTTINI, (cAlias)->CV1_CTTFIM, @nEntida1)
		Else
			nEntida1 := 1
		Endif
		
		If (cAlias)->CV1_CT1INI # (cAlias)->CV1_CT1FIM .And. Empty(cTabela)
			nEntidades := 0
			CT390EntP("CT1", (cAlias)->CV1_CT1INI, (cAlias)->CV1_CT1FIM, @nEntidades)
		Endif
		
		nEntidades *= nEntida1
		nEntidades *= nEntida2
		nEntidades *= nEntida3
		nEntidades *= nEntida5
		nEntidades *= nEntida6
		nEntidades *= nEntida7
	Endif
	
//********************************************************************************************************************************

ElseIf _lCpoEnt06 .And. !Empty((cAlias)->CV1_E06INI)
	cPlanoEnt	:= ""
	cIdEntid	:= "06"
	
	dbSelectArea("CT0")
	dbSetOrder(1)
	dbSeek(xFilial("CT0")+cIdEntid)
	cF3 := CT0->CT0_ALIAS
	cCpoDsc := CT0->CT0_CPODSC
	If cF3 == "CV0"
		cPlanoEnt := CT0->CT0_ENTIDA
	Else
		cPlanoEnt := ""
	EndIf
	
	DbSelectArea(cF3)
	MsSeek(xFilial(cF3) + cPlanoEnt + (cAlias)->CV1_E06INI)
	lMostra := (cAlias)->CV1_E06INI = (cAlias)->CV1_E06FIM
	
	If ! lMostra .Or.;
		(_lCpoEnt05 .And. (cAlias)->CV1_E05INI # (cAlias)->CV1_E05FIM) .Or.;
		(cAlias)->CV1_CTHINI # (cAlias)->CV1_CTHFIM .Or.;
		(cAlias)->CV1_CTDINI # (cAlias)->CV1_CTDFIM .Or.;
		(cAlias)->CV1_CTTINI # (cAlias)->CV1_CTTFIM .Or.;
		(cAlias)->CV1_CT1INI # (cAlias)->CV1_CT1FIM
		If ! lMostra .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4,CQ6")
			aArea := GetArea()
			nEntida6 := 0
			CT390EntP(_cAlias06, (cAlias)->CV1_E06INI, (cAlias)->CV1_E06FIM, @nEntida6, cIdEntid)
			RestArea(aArea)
		Else
			nEntida6 := 1
		Endif

		If _lCpoEnt05 .And. ((cAlias)->CV1_E05INI # (cAlias)->CV1_E05FIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4,CQ6"))
			nEntida5 := 0
			CT390EntP(_cAlias05, (cAlias)->CV1_E05INI, (cAlias)->CV1_E05FIM, @nEntida5, "05")
		Else
			nEntida5 := 1
		Endif		
				
		If (cAlias)->CV1_CTHINI # (cAlias)->CV1_CTHFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4")
			nEntida3 := 0
			CT390EntP("CTH", (cAlias)->CV1_CTHINI, (cAlias)->CV1_CTHFIM, @nEntida3)
		Else
			nEntida3 := 1
		Endif		
		
		If (cAlias)->CV1_CTDINI # (cAlias)->CV1_CTDFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2")
			nEntida2 := 0
			CT390EntP("CTD", (cAlias)->CV1_CTDINI, (cAlias)->CV1_CTDFIM, @nEntida2)
		Else
			nEntida2 := 1
		Endif
		
		If (cAlias)->CV1_CTTINI # (cAlias)->CV1_CTTFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0")
			nEntida1 := 0
			CT390EntP("CTT", (cAlias)->CV1_CTTINI, (cAlias)->CV1_CTTFIM, @nEntida1)
		Else
			nEntida1 := 1
		Endif
		
		If (cAlias)->CV1_CT1INI # (cAlias)->CV1_CT1FIM .And. Empty(cTabela)
			nEntidades := 0
			CT390EntP("CT1", (cAlias)->CV1_CT1INI, (cAlias)->CV1_CT1FIM, @nEntidades)
		Endif
		
		nEntidades *= nEntida1
		nEntidades *= nEntida2
		nEntidades *= nEntida3
		nEntidades *= nEntida5
		nEntidades *= nEntida6
	Endif
	
//********************************************************************************************************************************

ElseIf _lCpoEnt05 .And. !Empty((cAlias)->CV1_E05INI)
	cPlanoEnt	:= ""
	cIdEntid	:= "05"
	
	dbSelectArea("CT0")
	dbSetOrder(1)
	dbSeek(xFilial("CT0")+cIdEntid)
	cF3 := CT0->CT0_ALIAS
	cCpoDsc := CT0->CT0_CPODSC
	If cF3 == "CV0"
		cPlanoEnt := CT0->CT0_ENTIDA
	Else
		cPlanoEnt := ""
	EndIf
	
	DbSelectArea(cF3)
	MsSeek(xFilial(cF3) + cPlanoEnt + (cAlias)->CV1_E05INI)
	lMostra := (cAlias)->CV1_E05INI = (cAlias)->CV1_E05FIM
	
	If ! lMostra .Or.;
		(cAlias)->CV1_CTHINI # (cAlias)->CV1_CTHFIM .Or.;
		(cAlias)->CV1_CTDINI # (cAlias)->CV1_CTDFIM .Or.;
		(cAlias)->CV1_CTTINI # (cAlias)->CV1_CTTFIM .Or.;
		(cAlias)->CV1_CT1INI # (cAlias)->CV1_CT1FIM
		If ! lMostra .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4,CQ6")
			aArea := GetArea()
			nEntida5 := 0
			CT390EntP(_cAlias05, (cAlias)->CV1_E05INI, (cAlias)->CV1_E05FIM, @nEntida5, cIdEntid)
			RestArea(aArea)
		Else
			nEntida5 := 1
		Endif

		If (cAlias)->CV1_CTHINI # (cAlias)->CV1_CTHFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4")
			nEntida3 := 0
			CT390EntP("CTH", (cAlias)->CV1_CTHINI, (cAlias)->CV1_CTHFIM, @nEntida3)
		Else
			nEntida3 := 1
		Endif		
		
		If (cAlias)->CV1_CTDINI # (cAlias)->CV1_CTDFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2")
			nEntida2 := 0
			CT390EntP("CTD", (cAlias)->CV1_CTDINI, (cAlias)->CV1_CTDFIM, @nEntida2)
		Else
			nEntida2 := 1
		Endif
		
		If (cAlias)->CV1_CTTINI # (cAlias)->CV1_CTTFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0")
			nEntida1 := 0
			CT390EntP("CTT", (cAlias)->CV1_CTTINI, (cAlias)->CV1_CTTFIM, @nEntida1)
		Else
			nEntida1 := 1
		Endif
		
		If (cAlias)->CV1_CT1INI # (cAlias)->CV1_CT1FIM .And. Empty(cTabela)
			nEntidades := 0
			CT390EntP("CT1", (cAlias)->CV1_CT1INI, (cAlias)->CV1_CT1FIM, @nEntidades)
		Endif
		
		nEntidades *= nEntida1
		nEntidades *= nEntida2
		nEntidades *= nEntida3
		nEntidades *= nEntida5
	Endif
	
//*****************************************************************************************************************

ElseIf ! Empty((cAlias)->CV1_CTHINI)
	cF3	:= "CTH"
	DbSelectArea(cF3)
	MsSeek(xFilial(cF3) + (cAlias)->CV1_CTHINI)
	lMostra := (cAlias)->CV1_CTHINI = (cAlias)->CV1_CTHFIM
	
	If ! lMostra .Or. 	(cAlias)->CV1_CTDINI # (cAlias)->CV1_CTDFIM .Or.;
		(cAlias)->CV1_CTTINI # (cAlias)->CV1_CTTFIM .Or.;
		(cAlias)->CV1_CT1INI # (cAlias)->CV1_CT1FIM
		If ! lMostra .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2,CQ4")
			aArea := GetArea()
			nEntida3 := 0
			CT390EntP("CTH", (cAlias)->CV1_CTHINI, (cAlias)->CV1_CTHFIM, @nEntida3)
			RestArea(aArea)
		Else
			nEntida3 := 1
		Endif
		
		If (cAlias)->CV1_CTDINI # (cAlias)->CV1_CTDFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2")
			nEntida2 := 0
			CT390EntP("CTD", (cAlias)->CV1_CTDINI, (cAlias)->CV1_CTDFIM, @nEntida2)
		Else
			nEntida2 := 1
		Endif
		
		If (cAlias)->CV1_CTTINI # (cAlias)->CV1_CTTFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0")
			nEntida1 := 0
			CT390EntP("CTT", (cAlias)->CV1_CTTINI, (cAlias)->CV1_CTTFIM, @nEntida1)
		Else
			nEntida1 := 1
		Endif
		
		If (cAlias)->CV1_CT1INI # (cAlias)->CV1_CT1FIM .And. Empty(cTabela)
			nEntidades := 0
			CT390EntP("CT1", (cAlias)->CV1_CT1INI, (cAlias)->CV1_CT1FIM, @nEntidades)
		Endif
		
		nEntidades *= nEntida1
		nEntidades *= nEntida2
		nEntidades *= nEntida3
	Endif
ElseIf ! Empty((cAlias)->CV1_CTDINI)
	cF3		:= "CTD"
	DbSelectArea(cF3)
	MsSeek(xFilial(cF3) + (cAlias)->CV1_CTDINI)
	lMostra := (cAlias)->CV1_CTDINI = (cAlias)->CV1_CTDFIM
	
	If ! lMostra .Or. 	(cAlias)->CV1_CTTINI # (cAlias)->CV1_CTTFIM .Or.;
		(cAlias)->CV1_CT1INI # (cAlias)->CV1_CT1FIM
		If ! lMostra .And. (Empty(cTabela) .Or. cTabela $ "CQ0,CQ2")
			aArea := GetArea()
			nEntida1 := 0
			CT390EntP("CTD", (cAlias)->CV1_CTDINI, (cAlias)->CV1_CTDFIM, @nEntida1)
			RestArea(aArea)
		Else
			nEntida1 := 1
		Endif
		
		If (cAlias)->CV1_CTTINI # (cAlias)->CV1_CTTFIM .And. (Empty(cTabela) .Or. cTabela $ "CQ0")
			nEntida2 := 0
			CT390EntP("CTT", (cAlias)->CV1_CTTINI, (cAlias)->CV1_CTTFIM, @nEntida2)
		Else
			nEntida2 := 1
		Endif
		
		If (cAlias)->CV1_CT1INI # (cAlias)->CV1_CT1FIM .And. Empty(cTabela)
			nEntidades := 0
			CT390EntP("CT1", (cAlias)->CV1_CT1INI, (cAlias)->CV1_CT1FIM, @nEntidades)
		Endif
		
		nEntidades *= nEntida1
		nEntidades *= nEntida2
	Endif
ElseIf ! Empty((cAlias)->CV1_CTTINI)
	cF3		:= "CTT"
	DbSelectArea(cF3)
	MsSeek(xFilial(cF3) + (cAlias)->CV1_CTTINI)
	lMostra := (cAlias)->CV1_CTTINI = (cAlias)->CV1_CTTFIM
	If ! lMostra .Or. (cAlias)->CV1_CT1INI # (cAlias)->CV1_CT1FIM
		If ! lMostra .And. (Empty(cTabela) .Or. cTabela $ "CQ0")
			aArea := GetArea()
			nEntida1 := 0
			CT390EntP("CTT", (cAlias)->CV1_CTTINI, (cAlias)->CV1_CTTFIM, @nEntida1)
			RestArea(aArea)
		Else
			nEntida1 := 1
		Endif
		
		If (cAlias)->CV1_CT1INI # (cAlias)->CV1_CT1FIM .And. Empty(cTabela)
			nEntidades := 0
			CT390EntP("CT1", (cAlias)->CV1_CT1INI, (cAlias)->CV1_CT1FIM, @nEntidades)
		Endif
		
		nEntidades *= nEntida1
	Endif
Else
	cF3		:= "CT1"
	cTitulo := STR0015 //"Conta Contabil"
	DbSelectArea(cF3)
	MsSeek(xFilial(cF3) + (cAlias)->CV1_CT1INI)
	lMostra := (cAlias)->CV1_CT1INI = (cAlias)->CV1_CT1FIM
	If ! lMostra .And. Empty(cTabela)
		aArea := GetArea()
		nEntidades := 0
		CT390EntP("CT1", (cAlias)->CV1_CT1INI, (cAlias)->CV1_CT1FIM, @nEntidades)
		RestArea(aArea)
	Endif
Endif

If cF3 # Nil .And. Empty(cTitulo)
	cTitulo := CtbSayApro(cF3,cIdEntid)
Endif

If cTabela = "CQ0" .And. aCadastro # Nil
	CT1->(RestArea(aCadastro))
ElseIf cTabela = "CQ2" .And. aCadastro # Nil
	CTT->(RestArea(aCadastro))
ElseIf cTabela = "CQ4" .And. aCadastro # Nil
	CTD->(RestArea(aCadastro))
ElseIf cTabela = "CQ6" .And. aCadastro # Nil
	CTH->(RestArea(aCadastro))
Endif

If aAlias # Nil
	RestArea(aAlias)
Endif

Return nEntidades

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CT390EntP  ³ Autor ³ Wagner Mobile Costa ³ Data ³ 05/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina que conta o numero de entidades                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CT390EntP(cEntidade, cInicio, cFim, uRet)          		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA390                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cEntidade = Entidade para retorno das analiticas           ³±±
±±³          ³ cInicio   = Codigo inicial para retorno                    ³±±
±±³          ³ cFim      = Codigo final   para retorno                    ³±±
±±³          ³ uRet      = Array ou valor para retorno dos itens          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CT390EntP(cEntidade, cInicio, cFim, uRet, cIdEntid)
Local aArea := (cEntidade)->(GetArea())
Local cAlias
Local cCpoChv

If cEntidade = "CTH"
	CTH->(DbSetOrder(2))
	CTH->(DbSeek(xFilial() + "2" + cInicio, .T.))
	While 	CTH->CTH_CLVL <= cFim .And. CTH->CTH_CLASSE = "2" .And.;
		! CTH->(Eof())
		If ValType(uRet) = "A"
			Aadd(uRet, CTH->CTH_CLVL)
		Else
			uRet ++
		Endif
		CTH->(DbSkip())
	EndDo
ElseIf cEntidade = "CTD"
	CTD->(DbSetOrder(2))
	CTD->(DbSeek(xFilial() + "2" + cInicio, .T.))
	While 	CTD->CTD_ITEM <= cFim .And. CTD->CTD_CLASSE = "2" .And.;
		! CTD->(Eof())
		If ValType(uRet) = "A"
			Aadd(uRet, CTD->CTD_ITEM)
		Else
			uRet ++
		Endif
		CTD->(DbSkip())
	EndDo
ElseIf cEntidade = "CTT"
	CTT->(DbSetOrder(2))
	CTT->(DbSeek(xFilial() + "2" + cInicio, .T.))
	While 	CTT->CTT_CUSTO <= cFim .And. CTT->CTT_CLASSE = "2" .And.;
		! CTT->(Eof())
		If ValType(uRet) = "A"
			Aadd(uRet, CTT->CTT_CUSTO)
		Else
			uRet ++
		Endif
		CTT->(DbSkip())
	EndDo
ElseIf cEntidade = "CT1"
	CT1->(DbSetOrder(3))
	CT1->(DbSeek(xFilial() + "2" + cInicio, .T.))
	While 	CT1->CT1_CONTA <= cFim .And. CT1->CT1_CLASSE = "2" .And.;
		! CT1->(Eof())
		If ValType(uRet) = "A"
			Aadd(uRet, CT1->CT1_CONTA)
		Else
			uRet ++
		Endif
		CT1->(DbSkip())
	EndDo
ElseIf cEntidade = "CV0"
    dbSelectArea("CT0")
    dbSetOrder(1)
    dbSeek(xFilial("CT0")+cIdEntid)
    cPlanoEnt := CT0->CT0_ENTIDA

	dbSelectArea("CV0")	
	CV0->(dbSetOrder(1))
	CV0->(dbSeek(xFilial() + cPlanoEnt + cInicio, .T.))
	While CV0->CV0_CODIGO <= cFim .And. CV0->CV0_PLANO = cPlanoEnt .And.;
		! CV0->(Eof())
		If CV0->CV0_CLASSE = "2"
			If ValType(uRet) = "A"
				Aadd(uRet, CV0->CV0_CODIGO)
			Else
				uRet ++
			Endif
        EndIf
		CV0->(DbSkip())
	EndDo 
Else
    dbSelectArea("CT0")
    dbSetOrder(1)
    dbSeek(xFilial("CT0")+cIdEntid)
    cAlias := CT0->CT0_ALIAS
    cCpoChv := CT0->CT0_CPOCHV

	dbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(aIndexes[Val(CT0->CT0_ID)][1]))
	(cAlias)->(dbSeek(xFilial(cAlias) + cInicio, .T.))
	Do While &(cAlias+"->"+cCpoChv) <= cFim .And. !(cAlias)->(Eof())
		If ValType(uRet) = "A"
			Aadd(uRet, &(cAlias+"->"+cCpoChv))
		Else
			uRet ++
		Endif
		(cAlias)->(DbSkip())
	EndDo 
EndIf

If ValType(uRet) = "A" .And. Len(uRet) = 0
	uRet := { Space(Len(cInicio)) }
Endif

(cEntidade)->(RestArea(aArea))

Return uRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTB390Rep ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 11/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de reprocessamento dos saldos orcamentarios         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB390Rep()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Reprocessar os saldos gerados (Especifico   pois  deve   se³±±
±±³          ³ basear no CV1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilDe   = Filial de inicio para reprocessar (CTBA190)     ³±±
±±³          ³ cFilAte  = Filial final para reprocessar (CTBA190)     	  ³±±
±±³          ³ dDataIni = Filial de inicio para reprocessar (CTBA190)     ³±±
±±³          ³ dDataIni = Filial final para reprocessar (CTBA190)     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB390Rep(oObj,cFilDe,cFilAte,dDataIni,dDataFim,lMoedaEsp,cMoeda)

Local lFim := .F.

While !lFim			
	lFim := xCTB390Rep(oObj,cFilDe,cFilAte,dDataIni,dDataFim,lMoedaEsp,cMoeda)
	IF !lFim .and. !IsBlind()
		lFim := !MsgYesNo("Atenção!Os lançamentos foram modificados durante o reprocossamento. Deseja reprocessar novamente ?")
		If lFim .And. Type('TITULO') # "U" .and. Titulo <> Nil
			If !("Rascunho"$Titulo)
				Titulo := alltrim(TITULO)+" - Rascunho"
			EndIf
		EndIf		   
	Endif
End  
Return Nil

Static Function xCTB390Rep(oObj,cFilDe,cFilAte,dDataIni,dDataFim,lMoedaEsp,cMoeda)
Local aArea     	:= GetArea()
Local aCtbMoeda 	:= {}
Local nInicio		:= 0
Local nFinal		:= 0
Local nItem     	:= 0
Local nTotal    	:= 0
Local cFilBck   	:= cFilAnt
Local cFirst    	:= ""
Local cCursor   	:= "CV1"
Local lCusto		:= CtbMovSaldo("CTT")
Local lItem			:= CtbMovSaldo("CTD")
Local lCLVL			:= CtbMovSaldo("CTH")
Local bWhile    	:= {|| !Eof() }
Local lX3Aprova		:= .F.
Local cDELETE		:= " AND D_E_L_E_T_ = ' ' "
Local nQtdEnt		:= CtbQtdEntd()

Local lRet			:= .t.
Local lAtSldBase	:= Iif(SuperGetMV("MV_ATUSAL")== "S",.T.,.F.) 

Local lDelFisico	:=	GetNewPar('MV_CTB390D',.T.)
Local aField		:= {}
Local cOrderBy		:= ""	
Local cQuery		:= ""
Local cWhere		:= ""
Local cChave		:= ""
Local nCountReg		:= 0	
Local nMin			:= 0
Local nMax			:= 0

Local nX			:= 0	

Local aSM0 			:= AdmAbreSM0()
Local nContFil		:= 0

Local aArqs			:= {}
Local nArq			:= 0

If GetMV("MV_ORCAPRV") == "S"
	lX3Aprova := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da Regua                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMoedaEsp					// Moeda especifica
	aCtbMoeda := CtbMoeda(cMoeda)
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		Return
	EndIf
	nInicio := Val(cMoeda)
	nFinal	:= Val(cMoeda)
Else
	nInicio	:= 1
	nFinal	:= __nQuantas
EndIf

If !lAtSldBase
	For nx := nInicio to nFinal
		If GetCV7Date("0",StrZero(nx,2,0)) < dDataIni 
			dDataIni := GetCV7Date("0",StrZero(nx,2,0))+1
		EndIf
		PutCV7Date("0",StrZero(nx,2,0),dDataFim)
	Next nx
EndIf	
/*-*/
Aadd(aArqs,{"CQ0","CQ1"})
Aadd(aArqs,{"CQ2","CQ3"})
Aadd(aArqs,{"CQ4","CQ5"})
Aadd(aArqs,{"CQ6","CQ7"})

If lCusto .Or. lItem .Or. lCLVL
	Aadd(aArqs,{"CQ8","CQ9"})
Endif

/*-*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as filiais que devem ser processadas                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SM0")
dbSetOrder(1)
If Empty(cFilDe)
	MsSeek(cEmpAnt)
Else
	MsSeek(cEmpAnt+cFilDe)
EndIf
cFirst := IIf( Empty(cFilDe) , FWGETCODFILIAL, SM0->M0_CODFIL )

For nContFil := 1 to Len(aSM0)	
	If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt  
		Loop
	EndIf 	
	
	If Empty(FWFilial("CV1")) .And. aSM0[nContFil][SM0_CODFIL] <> cFirst
		dbSkip()
		Loop
	Endif	
		
	If oObj <> Nil
		oObj:SetRegua1(MAXPASSO)
		oObj:IncRegua1(STR0035+" - "+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL)//"Rep. de Orcamentos"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Altera a Filial do Sistema                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilAnt := aSM0[nContFil][SM0_CODFIL]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Zerar os dados a ser atualizado                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aArqs)
		If (!Empty(FWFilial(aArqs[nX,1])) .Or. cFilAnt == cFirst )
			CtbZeraOrc(aArqs[nX,1],lMoedaEsp,cMoeda,dDataIni,dDataFim,oObj)
		Endif
	Next
	If oObj <> Nil
		oObj:IncRegua1(STR0035+" - "+AllTrim(aSM0[nContFil][SM0_NOME])+"/"+aSM0[nContFil][SM0_NOMRED])//"Rep. de Orcamentos"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizar os saldos de orcamento                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 		
	cCursor := "cCursor"
		
	cQuery := "SELECT Count(*) MAXREG "
	cQuery += "FROM "+RetSqlName("CV1")+" CV1 "
	cQuery += "WHERE CV1.CV1_FILIAL = '"+xFilial("CV1")+"' AND "
	cQuery += "CV1.CV1_DTFIM BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND "
	cQuery += "CV1.CV1_STATUS = '2'  AND "
	cQuery += "CV1.CV1_VALOR <> 0  AND "
	If lMoedaEsp
		cQuery	+= 	"CV1.CV1_MOEDA ='"+cMoeda+"' AND "
	EndIf
	If lX3Aprova
		cQuery	+= 	"CV1.CV1_APROVA <> '' AND "
	Endif
	cQuery += "CV1.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
			
	If ( Select ( "cCursor" ) <> 0 )
		dbSelectArea ( "cCursor" )
		dbCloseArea ()
	Endif							
			
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor)
			
	nTotal := (cCursor)->MAXREG
	If oObj<>Nil
		oObj:SetRegua2(nTotal)
	EndIf
			
	dbSelectArea(cCursor)

	cQuery := "SELECT CV1_CT1INI, CV1_CT1FIM, CV1_CTTINI, CV1_CTTFIM, CV1_CTDINI, CV1_CTDFIM, CV1_CTHINI, CV1_CTHFIM, "
	For nX := 5 to nQtdEnt
		cQuery += "CV1_E"+StrZero(nX,2)+"INI, CV1_E"+StrZero(nX,2)+"FIM, "
	Next
	cQuery += "CV1_MOEDA, CV1_DTFIM, CV1_VALOR, CV1_STATUS "
	cQuery += "FROM "+RetSqlName("CV1")+" CV1 "
	cQuery += "WHERE CV1.CV1_FILIAL = '"+xFilial("CV1")+"' AND "
	cQuery += "CV1.CV1_DTFIM BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND "
	cQuery += "CV1.CV1_STATUS = '2'  AND "
	If lX3Aprova
		cQuery	+= 	"CV1.CV1_APROVA <> '' AND "
	Endif
	cQuery += "CV1.CV1_VALOR <> 0  AND "
	If lMoedaEsp
		cQuery	+= 	"CV1.CV1_MOEDA ='"+cMoeda+"' AND "
	EndIf
		
	cQuery += "CV1.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY "
	For nX := nQtdEnt to 5 step -1
		cQuery += "CV1_E"+StrZero(nX,2)+"INI, "
	Next
	cQuery += "CV1_CTHINI, CV1_CTDINI, CV1_CTTINI, CV1_CT1INI, CV1_MOEDA, CV1_DTFIM"
	cQuery := ChangeQuery(cQuery)

	If ( Select ( "cCursor" ) <> 0 )
		dbSelectArea ( "cCursor" )
		dbCloseArea ()
	Endif							
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor)
	
	aField := CV1->(dbStruct())
		
	For nX := 1 to Len(aField)
		If aField[nX,2] <> "C" .And. (cCursor)->(FieldPos(aField[nX,1]))<>0
			TcSetField(cCursor,aField[nX,1],aField[nX,2],aField[nX,3],aField[nX,4])
		EndIf
	Next nX
			
	If oObj <> Nil
		oObj:IncRegua1(STR0035+" - "+AllTrim(aSM0[nContFil][SM0_NOME])+"/"+aSM0[nContFil][SM0_NOMRED])//"Rep. de Orcamentos"
	EndIf
	nItem := 0

	dbSelectArea(cCursor)
	While Eval(bWhile)
			
		If (cCursor)->CV1_STATUS=='2' .And. (cCursor)->CV1_VALOR<>0
			Ctb390Atu(cCursor,"1")
		EndIf
		dbSelectArea(cCursor)
		dbSkip()
		nItem++
			
		If oObj <> Nil
			oObj:IncRegua2(STR0031+"("+AllTrim(Str(nItem,0))+"/"+AllTrim(Str(nTotal,0))+")") //"Atualizando saldos..."
		EndIf
	EndDo
			
	
	dbSelectArea (cCursor)
	dbCloseArea()
	dbSelectArea("CV1")
	
	If oObj <> Nil
		oObj:IncRegua1(STR0035+" - "+AllTrim(aSM0[nContFil][SM0_NOME])+"/"+aSM0[nContFil][SM0_NOMRED])//"Rep. de Orcamentos"
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga os registros de saldos que nao possuem saldo           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aArqs)
		If (!Empty(FWFilial(aArqs[nX,1])) .Or. cFilAnt == cFirst )
			For nArq := 1 To Len(aArqs[nX]) 
				cCursor:= "cCursor"
				cQuery := "SELECT R_E_C_N_O_ RECNO "
				cQuery += "FROM "+RetSqlName(aArqs[nX,nArq])+" "
				cWhere := "WHERE " + aArqs[nX,nArq] + "_FILIAL = '"+xFilial(aArqs[nX,nArq])+"' AND "
				cWhere += aArqs[nX,nArq] + "_DEBITO = 0 AND "
				cWhere += aArqs[nX,nArq] + "_CREDIT = 0 AND "
				If lMoedaEsp
					cWhere += aArqs[nX,nArq] + "_MOEDA ='"+cMoeda+"' AND "
				EndIf
				cWhere 	+= aArqs[nX,nArq] + "_TPSALD  = '0' "
				cDELETE	:= " AND D_E_L_E_T_ = ' ' "
				cOrderBy:= " ORDER BY RECNO "	
			
				cQuery := ChangeQuery(cQuery+cWhere+cDELETE+cOrderBy)
				
				If ( Select ( "cCursor" ) <> 0 )
					dbSelectArea ( "cCursor" )
					dbCloseArea ()
				Endif							
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor)
				
				If oObj<>Nil
					oObj:SetRegua2((Int((nMax-nMin)/1024)))
				EndIf
			
				dbSelectArea(aArqs[nX,nArq])
				
				cQuery := "DELETE FROM "
				cQuery += RetSqlName(aArqs[nX,nArq])+" "
				cQuery += cWhere
				                                                    
				While cCursor->(!Eof())
					nMin := (cCursor)->RECNO
					nCountReg := 0
					While cCursor->(!EOF()) .and. nCountReg <= 4096
						nMax := (cCursor)->RECNO
						nCountReg++
						cCursor->(DbSkip())
					End
					cChave := " AND R_E_C_N_O_>="+Str(nMin,10,0)+" AND R_E_C_N_O_<="+Str(nMax,10,0)+""
					TcSqlExec(cQuery+cChave)
					If oObj<>Nil
						oObj:IncRegua2(STR0036)//"Eliminando residuos..."
					EndIf
				EndDo
			Next
		Endif
	Next

	If oObj <> Nil
		oObj:IncRegua1(STR0035+" - "+AllTrim(aSM0[nContFil][SM0_NOME])+"/"+aSM0[nContFil][SM0_NOMRED])//"Rep. de Orcamentos"
	EndIf
	If oObj <> Nil
		oObj:SetRegua2(2)
	EndIf
	If oObj <> Nil
		oObj:IncRegua2(STR0031)//Atualizando Saldos
	EndIf
	
	//Se o arquivo CV1 for compartilhado
	If Empty(FWFilial("CV1"))
		cFilDe	:= FWFilial("CV1")
		cFilAte	:= FWFilial("CV1")
	EndIf
		
	If oObj <> Nil
		oObj:IncRegua2(STR0031)//"Atualizando Saldos
	EndIf
	
	If oObj <> Nil
		oObj:IncRegua1(STR0035+" - "+AllTrim(aSM0[nContFil][SM0_NOME])+"/"+aSM0[nContFil][SM0_NOMRED])//"Rep. de Orcamentos"
	EndIf

Next nContFil

cFilAnt := cFilBck

If !lAtSldBase
   lRet := .T.
	For nx := nInicio to nFinal
		If GetCV7Date("0",StrZero(nx,2,0)) < dDataFim
			lRet := .f.
		EndIf
	Next nx
EndIf	

If ( Select ( "cCursor" ) <> 0 )
	dbSelectArea ( "cCursor" )
	dbCloseArea ()
Endif	

RestArea(aArea)
	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbZeraOrc³ Autor ³ Simone M. Sato        ³ Data ³15.04.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Zera os arquivos de saldo a serem reprocessadosessados      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbZeraTod()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1= Alias do Arquivo                                    ³±±
±±³          ³ ExpL2= Define se eh moeda especifica                       ³±±
±±³          ³ ExpC3= Moeda                                               ³±±
±±³          ³ ExpD4= Data Inicial                                        ³±±
±±³          ³ ExpD5= Data Final                                          ³±±
±±³          ³ ExpO6= Objeto inicial                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CtbZeraOrc(cAlias,lMoedaEsp,cMoeda,dDataIni,dDataFim,oObj)
Local aSaveArea 	:= GetArea()
Local cOrderBy		:= ""
Local cChave    	:= ""
Local cWhere    	:= ""
Local cQuery		:= ""
Local CtbZeraOrc	:= ""	
Local nMax      	:= 0
Local nMin      	:= 0
Local nCountReg		:= 0
Local nPosArq		:= 0
Local nArq			:= 0
Local aArqs			:= {}
Local __lFKInUse    := FkInUse()
Local CtZeraCubo    := ""


Aadd(aArqs,{"CQ0","CQ1"})
Aadd(aArqs,{"CQ2","CQ3"})
Aadd(aArqs,{"CQ4","CQ5"})
Aadd(aArqs,{"CQ6","CQ7"})
Aadd(aArqs,{"CQ8","CQ9"})

nPosArq := Ascan(aArqs,{|arquivo| arquivo[1] == cAlias})

If nPosArq > 0
	For nArq := 1 To Len(aArqs[nPosArq]) 		
		CtbZeraOrc := "CtbZeraOrc"
		cQuery := "SELECT R_E_C_N_O_ RECNO "
		cQuery += "FROM "+RetSqlName(aArqs[nPosArq,nArq])+ " "
		cWhere := "WHERE " + aArqs[nPosArq,nArq] + "_FILIAL = '"+xFilial(aArqs[nPosArq,nArq])+"' AND "
		If lMoedaEsp
			cWhere += aArqs[nPosArq,nArq] + "_MOEDA = '"+cMoeda+"' AND "
		EndIf
		cWhere += aArqs[nPosArq,nArq] + "_TPSALD='0' AND "
		cWhere += aArqs[nPosArq,nArq] + "_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND "
		cWhere += "D_E_L_E_T_=' ' "
		cQuery += cWhere
		cOrderBy	:= " ORDER BY RECNO "
		cQuery		+= cOrderBy
		cQuery := ChangeQuery(cQuery)
		
		If ( Select ( "CtbZeraOrc" ) <> 0 )
			dbSelectArea ( "CtbZeraOrc" )
			dbCloseArea ()
		Endif
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),CtbZeraOrc)
		If oObj<>Nil
			oObj:SetRegua2((Int((nMax-nMin)/1024)))
		EndIf
	 	
		dbSelectArea(aArqs[nPosArq,nArq])
		
		cQuery := "UPDATE "
		cQuery += RetSqlName(aArqs[nPosArq,nArq])+" "
		cQuery += "SET "
		cQuery += aArqs[nPosArq,nArq] + "_DEBITO = 0,"
		cQuery += aArqs[nPosArq,nArq] + "_CREDIT = 0 "
		cQuery += cWhere                   
		
		While CtbZeraOrc->(!Eof())
			nMin := (CtbZeraOrc)->RECNO
			nCountReg := 0
			While CtbZeraOrc->(!EOF()) .and. nCountReg <= 4096
				nMax := (CtbZeraOrc)->RECNO
				nCountReg++
				CtbZeraOrc->(DbSkip())
			End
			cChave := " AND R_E_C_N_O_>="+Str(nMin,10,0)+" AND R_E_C_N_O_<="+Str(nMax,10,0)+""
			TcSqlExec(cQuery+cChave)
			If oObj<>Nil
				oObj:IncRegua2(STR0037+" - " + aArqs[nPosArq,nArq])//"Eliminando Saldos"
			EndIf
		End
	Next
Endif
/* -----------------------------------------------------------------------
	Zerar Saldos De cubos
   ----------------------------------------------------------------------- */
If lCtbIsCube .And. CtbIsCube()

	//Apagar todos os saldos diarios (CVX) entre data inicial e final 
	If ValType(oObj) == "O"
		oObj:IncRegua1(STR0037) 
	EndIf
	CtZeraCubo := "CtZeraCubo"
	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += "   FROM "+RetSqlName("CVX")
	cWhere := "  WHERE CVX_FILIAL = '"+ xFilial("CVX") +"'"
	cWhere += "    AND CVX_TPSALD = '0' "
	cWhere += "    AND CVX_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"'"
	If lMoedaEsp
		cWhere += " AND CVX_MOEDA = '"+cMoeda+"' "
	EndIf
	cWhere += "    AND D_E_L_E_T_ = ' ' "
	cQuery += cWhere
	cQuery +=" ORDER BY RECNO "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),CtZeraCubo)
	
	If __lFKInUse                 
		cQuery  := " UPDATE " + RetSqlName('CVX')
		cQuery  += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
	Else
		cQuery := " DELETE FROM " +RetSqlName("CVX")
	EndIf
	cQuery += cWhere
	
	While CtZeraCubo->(!Eof())
		nMin := (CtZeraCubo)->RECNO
		nCountReg := 0
		While CtZeraCubo->(!EOF()) .and. nCountReg <= 4096
			nMax := (CtZeraCubo)->RECNO
			nCountReg++
			CtZeraCubo->(DbSkip())
		End
		cChave := " AND R_E_C_N_O_>="+Str(nMin,10,0)+" AND R_E_C_N_O_<="+Str(nMax,10,0)+""
		TcSqlExec(cQuery+cChave)
		If oObj<>Nil
			oObj:IncRegua2(STR0037)//"Eliminando Saldos"
		EndIf
	End
	dbSelectArea ( "CtZeraCubo" )
	dbCloseArea()

	//Apagar todos os saldos mensais (CVY) entre data inicial e final
	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += "   FROM "+RetSqlName("CVY")
	cWhere := "  WHERE CVY_FILIAL = '"+ xFilial("CVY") +"'"
	cWhere += "    AND CVY_TPSALD = '0' "
	cWhere += "    AND CVY_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"'"
	If lMoedaEsp
		cWhere += " AND CVY_MOEDA = '"+cMoeda+"' "
	EndIf
	cWhere += "    AND D_E_L_E_T_ = ' ' "
	cQuery += cWhere
	cQuery +=" ORDER BY RECNO "

	cQuery := ChangeQuery(cQuery)
				
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),CtZeraCubo)
	
	If __lFKInUse                 
		cQuery  := " UPDATE " + RetSqlName('CVY')
		cQuery  += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
	Else
		cQuery := " DELETE FROM " +RetSqlName("CVY")
	EndIf
	cQuery += cWhere
	
	While CtZeraCubo->(!Eof())
		nMin := (CtZeraCubo)->RECNO
		nCountReg := 0
		While CtZeraCubo->(!EOF()) .and. nCountReg <= 4096
			nMax := (CtZeraCubo)->RECNO
			nCountReg++
			CtZeraCubo->(DbSkip())
		End
		cChave := " AND R_E_C_N_O_>="+Str(nMin,10,0)+" AND R_E_C_N_O_<="+Str(nMax,10,0)+""
		TcSqlExec(cQuery+cChave)
		If oObj<>Nil
			oObj:IncRegua2(STR0037)//"Eliminando Saldos"
		EndIf
	End
	dbSelectArea ( "CtZeraCubo" )
	dbCloseArea()				
EndIf                                      

If ( Select ( "CtbZeraOrc" ) <> 0 )
	dbSelectArea ( "CtbZeraOrc" )
	dbCloseArea ()
Endif	
RestArea(aSaveArea)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb390Aprv³ Autor ³ Wagner Mobile Costa   ³ Data ³ 28.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de aprovacao orcamentaria                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba390                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb390Aprv

Local aAreaCV2 := CV2->(GetArea())
Local aAreaCV1 := CV1->(GetArea())
Local cCV2Key  := CV2->(CV2_FILIAL+CV2_ORCMTO+CV2_CALEND+CV2_MOEDA+CV2_REVISA)
Local cAPROVA  := cUserName

If !Empty(CV2->CV2_APROVA)
	MsgInfo(STR0020 + AllTrim(CV1->CV1_APROVA), STR0008) //"Atencao" //"Orcamento ja aprovado pelo usuario "
	Return .T.
Endif

If CV2->CV2_STATUS == "3"
	MsgInfo(STR0007, STR0008) //"Orcamento ja revisado nao podendo ser alterado !"		//"Atencao"
	Return .T.
Endif

DbSelectArea("CV1")
DbSetOrder(1)
DbClearFil()
MsSeek(cCV2Key)

BEGIN TRANSACTION
While !Eof() .And. cCV2Key == CV1->(CV1_FILIAL+CV1_ORCMTO+CV1_CALEND+CV1_MOEDA+CV1_REVISA)
	RecLock("CV1", .F.)		/// EFETUA A GRAVACAO DO FLAG DE APROVACAO NO ARQUIVO DETALHE
	Replace CV1_APROVA With cAPROVA
	CV1->(MsUnLock())
	CV1->(DbSkip())
EndDo

RecLock("CV2", .F.)		/// EFETUA A GRAVACAO DO FLAG DE APROVACAO NO ARQUIVO HEADER
Replace CV2_APROVA With cAPROVA
CV2->(MsUnLock())

END TRANSACTION

If l390Grv					/// PE APOS A GRAVACAO DO ORCAMENTO
	ExecBlock("CTB390GRV", .F., .F.,{0,M->CV1_ORCMTO,M->CV1_CALEND,M->CV1_MOEDA,M->CV1_REVISA})
Endif

//Ctb390Fil()
RestArea(aAreaCV1)
RestArea(aAreaCV2)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CheckSX3 ³ Autor ³ Cristina M. Ogura	    ³ Data ³ 17/08/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz Validacao para campos do cabecalho dos PRGs Mod.2 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := CheckSX3(ExpC1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Campo do dicionario (SX3)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function CheckSX3(cCampo,cIniVar,nOpcx,lCopia)
Local cAlias := Alias(), nRec, nOrd, cValid
Local lRet	 := .T.
DEFAULT nOpcX := 3
DEFAULT lCopia := .F.

If nOpcX == 2 .or. nOpcX == 4 .or. nOpcX == 5 .Or. lCopia
	Return(.T.)
Endif

dbSelectArea("SX3")
nRec := Recno()
nOrd := IndexOrd()
dbSetOrder(2)
dbSeek(cCampo)
dbSetOrder(nOrd)
dbSelectArea(cAlias)

cValid := IIf(!Empty(SX3->X3_VALID),Alltrim(SX3->X3_VALID),"")
cValid += IIf(!Empty(SX3->X3_VALID).And.!Empty(SX3->X3_VLDUSER)," .And. ","")
cValid += IIf(!Empty(SX3->X3_VLDUSER),Alltrim(SX3->X3_VLDUSER),"")
cVar	 := "M->"+cCampo
If cIniVar == Nil
	&cVar  := &(ReadVar())
Else
	&cVar	 := cIniVar
EndIf

IF !Empty(cValid)
	lRet := &(cValid)
Else
	lRet := .t.
Endif
dbSelectArea("SX3")
dbGoto(nRec)
dbSelectArea(cAlias)

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb390Zera³ Autor ³ Simone Mie Sato       ³ Data ³ 03/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para zerar as tabelas de saldos.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB390Zera()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Zerar os valores das tabelas de saldos do tipo de saldo de ³±±
±±³          ³ orcamento.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilDe   = Filial de inicio para reprocessar (CTBA190)     ³±±
±±³          ³ cFilAte  = Filial final para reprocessar (CTBA190)     	  ³±±
±±³          ³ dDataIni = Filial de inicio para reprocessar (CTBA190)     ³±±
±±³          ³ dDataIni = Filial final para reprocessar (CTBA190)     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb390Zera(cFilDe,cFilAte,dDataIni,dDataFim,lMoedaEsp,cMoeda,lCusto,lItem,lClVl,oObj)
Local aSaveArea	:= GetArea()
Local cFilSal	:= ""

lCusto		:= CtbMovSaldo("CTT")
lItem		:= CtbMovSaldo("CTD")
lCLVL		:= CtbMovSaldo("CTH")

If Empty(FWFilial("CQ0"))
	cFilSal := Space(IIf( lFWCodFil, FWGETTAMFILIAL, 2 ))
Else
	cFilSal := cFilAnt
Endif
CtbZeraTod("CQ0",lMoedaEsp,cMoeda,"0",cFilSal,cFilSal,dDataIni,dDataFim,4,.T.,,oObj)

// Zera Saldos de Centro de Custo
If lCusto
	If Empty(FWFilial("CQ2"))
		cFilSal := Space(IIf( lFWCodFil, FWGETTAMFILIAL, 2 ))
	Else
		cFilSal := cFilAnt
	Endif
	CtbZeraTod("CQ2",lMoedaEsp,cMoeda,"0",cFilSal,cFilSal,dDataIni,dDataFim,3,.T.,,oObj)
EndIf

// Zera Saldos de Item Contabil
If lItem
	If Empty(FWFilial("CQ4"))
		cFilSal := Space(IIf( lFWCodFil, FWGETTAMFILIAL, 2 ))
	Else
		cFilSal := cFilAnt
	Endif
	CtbZeraTod("CQ4",lMoedaEsp,cMoeda,"0",cFilSal,cFilSal,dDataIni,dDataFim,3,.T.,,oObj)
EndIf

// Zera Saldos de Classe de Valor
If lCLVL
	If Empty(FWFilial("CQ6"))
		cFilSal := Space(IIf( lFWCodFil, FWGETTAMFILIAL, 2 ))
	Else
		cFilSal := cFilAnt
	Endif
	CtbZeraTod("CQ6",lMoedaEsp,cMoeda,"0",cFilSal,cFilSal,dDataIni,dDataFim,3,.T.,,oObj)
EndIf

// Zera Saldos por Entidade
If lCLVL .Or. lItem .Or. lCusto
	If Empty(FWFilial("CQ8"))
		cFilSal := Space(IIf( lFWCodFil, FWGETTAMFILIAL, 2 ))
	Else
		cFilSal := cFilAnt
	Endif
	CtbZeraTod("CQ8",lMoedaEsp,cMoeda,"0",cFilSal,cFilSal,dDataIni,dDataFim,3,.T.,,oObj)
EndIf


RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb390Qry ³ Autor ³ Simone Mie Sato       ³ Data ³ 03/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Montar query.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB390Qry()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Montar query.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilDe   = Filial de inicio para reprocessar (CTBA190)     ³±±
±±³          ³ cFilAte  = Filial final para reprocessar (CTBA190)     	  ³±±
±±³          ³ dDataIni = Filial de inicio para reprocessar (CTBA190)     ³±±
±±³          ³ dDataIni = Filial final para reprocessar (CTBA190)     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb390Qry(cFilSal,dDataIni,dDataFim,lMoedaEsp,cMoeda,lGeraSal)

Local lX3Aprova		:= .F.
Local lX3STATSL		:= .F.
Local cCondGrSal	:= ""
Local cCondMoeda	:= ""	 
Local cQuery		:= ""
Local cSelOrc		:= ""	
Local ni


If GetMV("MV_ORCAPRV") == "S"
	lX3Aprova := .T.
Endif

dbSelectArea("CV2")
lX3STATSL := .T.


DEFAULT lMoedaEsp	:= .F.
DEFAULT lGeraSal	:= .F. //Indica se eh rotina de Geracao de Saldos
DEFAULT cMoeda		:= ""
DEFAULT dDataIni	:= CTOD("  /  /  ")
DEFAULT dDataFim	:= CTOD("  /  /  ")

If lGeraSal	//Se for Rotina de geracao de saldos
	cCondGrSal	+= " CV1.CV1_ORCMTO >= '"+ mv_par01 + "' AND CV1.CV1_ORCMTO <= '" + mv_par02 + "' AND  "
	cCondGrSal  += " CV1.CV1_CALEND >= '"+ mv_par03 + "' AND CV1.CV1_CALEND <= '" + mv_par04 + "' AND  "
	cCondGrSal  += " CV1.CV1_MOEDA  >= '"+ mv_par05 + "' AND CV1.CV1_MOEDA  <= '" + mv_par06 + "' AND  "
	cCondGrSal	+= " CV1.CV1_REVISA >= '"+ mv_par07 + "' AND CV1.CV1_REVISA <= '" + mv_par08 + "' AND  "
	cCondGrSal	+=  "CV1.CV1_STATUS = '1'  AND "
Else			//Se for Reprocessamento
	If lMoedaEsp
		cCondMoeda	:= 	" CV1.CV1_MOEDA ='" + cMoeda+"' AND "
	Else
		cCondMoeda	:= ""
	EndIf
	cCondGrSal	:= "CV1.CV1_STATUS = '2'  AND "
	cCondGrSal  += "CV1.CV1_DTFIM BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND "
EndIf
		
cSelOrc := "cSelOrc"
		
cQuery := "SELECT CV1_CT1INI, CV1_CT1FIM, CV1_CTTINI, CV1_CTTFIM,"
cQuery += "CV1_CTDINI, CV1_CTDFIM, CV1_CTHINI, CV1_CTHFIM,"
If(_lCpoEnt05,cQuery += "CV1_E05INI, CV1_E05FIM,",Nil)
If(_lCpoEnt06,cQuery += "CV1_E06INI, CV1_E06FIM,",Nil)
If(_lCpoEnt07,cQuery += "CV1_E07INI, CV1_E07FIM,",Nil)
If(_lCpoEnt08,cQuery += "CV1_E08INI, CV1_E08FIM,",Nil)
If(_lCpoEnt09,cQuery += "CV1_E09INI, CV1_E09FIM,",Nil)	
cQuery += "CV1_MOEDA, CV1_DTFIM, CV1_VALOR"
			
If lX3STATSL
	cQuery += ", CV1_FILIAL, CV1_ORCMTO, CV1_CALEND, CV1_REVISA "			
EndIf
cQuery += " FROM "+RetSqlName("CV1")+" CV1 "
cQuery += " WHERE CV1.CV1_FILIAL = '"+cFilSal+"' AND "
cQuery += cCondMoeda
cQuery += cCondGrSal
If lX3Aprova
	cQuery += " CV1.CV1_APROVA <> '' AND "
Endif
cQuery += " CV1.CV1_VALOR <> 0  AND "
cQuery += " D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY "
cQuery += " CV1_CTHINI, CV1_CTDINI, CV1_CTTINI, CV1_CT1INI, CV1_MOEDA, CV1_DTFIM"
cQuery := ChangeQuery(cQuery)
	
If ( Select ( "cSelOrc" ) <> 0 )
	dbSelectArea ( "cSelOrc" )
	dbCloseArea ()
Endif
		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSelOrc,.T.,.F.)
		
aStru := CV1->(dbStruct())
		
For ni := 1 to Len(aStru)
	If aStru[ni,2] != 'C'
		If Subs(aStru[ni,1],1,9) == "CV1_VALOR"
			TCSetField(cSelOrc,aStru[ni,1],aStru[ni,2],aStru[ni,3],aStru[ni,4])
		ElseIf Subs(aStru[ni,1],1,9) == "CV1_DTFIM"
			TCSetField(cSelOrc, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		EndIf
	EndIF
Next ni
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb390Atu ³ Autor ³ Simone Mie Sato       ³ Data ³ 03/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza o arquivo de saldos.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb390Atu()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Montar query.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias   = Alias do arquivo a ser consultado               ³±±
±±³          ³ cOperacao= Operacao a ser executada.(1=Soma;2=Subtracao)   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb390Atu(cAlias,cOperacao,oObj,nValorAnt,nOpcX,lAltValor)

Local aSaveArea	:= GetArea()
Local lCT1			:= .F.
Local lCTT			:= .F.
Local lCTD			:= .F.
Local lCTH			:= .F.
Local lEntid05		:= .F.
Local lEntid06		:= .F.
Local lEntid07		:= .F.
Local lEntid08		:= .F.
Local lEntid09		:= .F.
Local nFatorCTH		:= 1
Local nFatorCTHA	:= 1	//Fator de multiplicacao anterior
Local nFatorCTT		:= 1
Local nFatorCTTA	:= 1	//Fator de multiplicacao anterior
Local nFatorCTD		:= 1
Local nFatorCTDA	:= 1	//Fator de multiplicacao anterior
Local nFatEnt05		:= 1
Local nFatEnt05A	:= 1	//Fator de multiplicacao anterior
Local nFatEnt06		:= 1
Local nFatEnt06A	:= 1	//Fator de multiplicacao anterior
Local nFatEnt07		:= 1
Local nFatEnt07A	:= 1	//Fator de multiplicacao anterior
Local nFatEnt08		:= 1
Local nFatEnt08A	:= 1	//Fator de multiplicacao anterior
Local nFatEnt09		:= 1
Local nFatEnt09A	:= 1	//Fator de multiplicacao anterior
Local aFatorEntd	:= {}

DEFAULT nOpcX		:= 3
DEFAULT lAltValor	:= .F.

Ctb390IniVar()

If _lCpoEnt09 .And. ((nOpcX == 3 .And. (!Empty((cAlias)->CV1_E09INI) .Or. !Empty((cAlias)->CV1_E09FIM))) .Or. ;
	(nOpcX == 4 .And. (!Empty((cAlias)->CV1_E09INI) .Or. !Empty((cAlias)->CV1_E09FIM) .Or. ;
	!Empty(CV1->CV1_E09INI) .Or. !Empty(CV1->CV1_E09FIM))) .Or. ;
	(nOpcX == 5 .And. (!Empty(CV1->CV1_E09INI) .Or. !Empty(CV1->CV1_E09FIM))))
	lEntid09		:= .T.
	
	//Fator de multiplicacao anterior
	nFatEnt09A	:= Ctb390Recn(_cAlias09,CV1->CV1_E09INI,CV1->CV1_E09FIM,_cCpoChv09,"09")
	
	//Fator de multiplicacao atual
	nFatEnt09	:= Ctb390Recn(_cAlias09,(cAlias)->CV1_E09INI,(cAlias)->CV1_E09FIM,_cCpoChv09,"09")
EndIf

If _lCpoEnt08 .And. ((nOpcX == 3 .And. (!Empty((cAlias)->CV1_E08INI) .Or. !Empty((cAlias)->CV1_E08FIM))) .Or. ;
	(nOpcX == 4 .And. (!Empty((cAlias)->CV1_E08INI) .Or. !Empty((cAlias)->CV1_E08FIM) .Or. ;
	!Empty(CV1->CV1_E08INI) .Or. !Empty(CV1->CV1_E08FIM))) .Or. ;
	(nOpcX == 5 .And. (!Empty(CV1->CV1_E08INI) .Or. !Empty(CV1->CV1_E08FIM))))
	lEntid08		:= .T.
	
	//Fator de multiplicacao anterior
	nFatEnt08A	:= Ctb390Recn(_cAlias08,CV1->CV1_E08INI,CV1->CV1_E08FIM,_cCpoChv08,"08")
	
	//Fator de multiplicacao atual
	nFatEnt08	:= Ctb390Recn(_cAlias08,(cAlias)->CV1_E08INI,(cAlias)->CV1_E08FIM,_cCpoChv08,"08")
EndIf

If _lCpoEnt07 .And. ((nOpcX == 3 .And. (!Empty((cAlias)->CV1_E07INI) .Or. !Empty((cAlias)->CV1_E07FIM))) .Or. ;
	(nOpcX == 4 .And. (!Empty((cAlias)->CV1_E07INI) .Or. !Empty((cAlias)->CV1_E07FIM) .Or. ;
	!Empty(CV1->CV1_E07INI) .Or. !Empty(CV1->CV1_E07FIM))) .Or. ;
	(nOpcX == 5 .And. (!Empty(CV1->CV1_E07INI) .Or. !Empty(CV1->CV1_E07FIM))))
	lEntid07		:= .T.
	
	//Fator de multiplicacao anterior
	nFatEnt07A	:= Ctb390Recn(_cAlias07,CV1->CV1_E07INI,CV1->CV1_E07FIM,_cCpoChv07,"07")
	
	//Fator de multiplicacao atual
	nFatEnt07	:= Ctb390Recn(_cAlias07,(cAlias)->CV1_E07INI,(cAlias)->CV1_E07FIM,_cCpoChv07,"07")
EndIf

If _lCpoEnt06 .And. ((nOpcX == 3 .And. (!Empty((cAlias)->CV1_E06INI) .Or. !Empty((cAlias)->CV1_E06FIM))) .Or. ;
	(nOpcX == 4 .And. (!Empty((cAlias)->CV1_E06INI) .Or. !Empty((cAlias)->CV1_E06FIM) .Or. ;
	!Empty(CV1->CV1_E06INI) .Or. !Empty(CV1->CV1_E06FIM))) .Or. ;
	(nOpcX == 5 .And. (!Empty(CV1->CV1_E06INI) .Or. !Empty(CV1->CV1_E06FIM))))
	lEntid06		:= .T.
	
	//Fator de multiplicacao anterior
	nFatEnt06A	:= Ctb390Recn(_cAlias06,CV1->CV1_E06INI,CV1->CV1_E06FIM,_cCpoChv06,"06")
	
	//Fator de multiplicacao atual
	nFatEnt06	:= Ctb390Recn(_cAlias06,(cAlias)->CV1_E06INI,(cAlias)->CV1_E06FIM,_cCpoChv06,"06")
EndIf

If _lCpoEnt05 .And. ((nOpcX == 3 .And. (!Empty((cAlias)->CV1_E05INI) .Or. !Empty((cAlias)->CV1_E05FIM))) .Or. ;
	(nOpcX == 4 .And. (!Empty((cAlias)->CV1_E05INI) .Or. !Empty((cAlias)->CV1_E05FIM) .Or. ;
	!Empty(CV1->CV1_E05INI) .Or. !Empty(CV1->CV1_E05FIM))) .Or. ;
	(nOpcX == 5 .And. (!Empty(CV1->CV1_E05INI) .Or. !Empty(CV1->CV1_E05FIM))))
	lEntid05		:= .T.
	
	//Fator de multiplicacao anterior
	nFatEnt05A	:= Ctb390Recn(_cAlias05,CV1->CV1_E05INI,CV1->CV1_E05FIM,_cCpoChv05,"05")
	
	//Fator de multiplicacao atual
	nFatEnt05	:= Ctb390Recn(_cAlias05,(cAlias)->CV1_E05INI,(cAlias)->CV1_E05FIM,_cCpoChv05,"05")
EndIf

If (nOpcX == 3 .And. (!Empty((cAlias)->CV1_CTHINI) .Or. !Empty((cAlias)->CV1_CTHFIM))) .Or. ;
	(nOpcX == 4 .And. (!Empty((cAlias)->CV1_CTHINI) .Or. !Empty((cAlias)->CV1_CTHFIM) .Or. ;
	!Empty(CV1->CV1_CTHINI) .Or. !Empty(CV1->CV1_CTHFIM))) .Or. ;
	(nOpcX == 5 .And. (!Empty(CV1->CV1_CTHINI) .Or. !Empty(CV1->CV1_CTHFIM)))
	lCTH		:= .T.
	
	//Fator de multiplicacao anterior
	nFatorCTHA	:= Ctb390Recn("CTH",CV1->CV1_CTHINI,CV1->CV1_CTHFIM,"CTH_CLVL")
	
	//Fator de multiplicacao atual
	nFatorCTH	:= Ctb390Recn("CTH",(cAlias)->CV1_CTHINI,(cAlias)->CV1_CTHFIM,"CTH_CLVL")
EndIf

If (nOpcX == 3 .And. (!Empty((cAlias)->CV1_CTDINI) .Or. !Empty((cAlias)->CV1_CTDFIM))) .Or. ;
	(nOpcX == 4 .And. (!Empty((cAlias)->CV1_CTDINI) .Or. !Empty((cAlias)->CV1_CTDFIM) .Or. ;
	!Empty(CV1->CV1_CTDINI) .Or. !Empty(CV1->CV1_CTDFIM))) .Or. ;
	(nOpcX == 5 .And. (!Empty(CV1->CV1_CTDINI) .Or. !Empty(CV1->CV1_CTDFIM)))
	lCTD		:= .T.
	//Fator de multiplicacao anterior
	nFatorCTDA	:= Ctb390Recn("CTD",CV1->CV1_CTDINI,CV1->CV1_CTDFIM,"CTD_ITEM")
	
	//Fator de multiplicacao atual
	nFatorCTD	:= Ctb390Recn("CTD",(cAlias)->CV1_CTDINI,(cAlias)->CV1_CTDFIM,"CTD_ITEM")
EndIf

If (nOpcX == 3 .And. (!Empty((cAlias)->CV1_CTTINI) .Or. !Empty((cAlias)->CV1_CTTFIM))) .Or. ;
	(nOpcX == 4 .And. (!Empty((cAlias)->CV1_CTTINI) .Or. !Empty((cAlias)->CV1_CTTFIM) .Or. ;
	!Empty(CV1->CV1_CTTINI) .Or. !Empty(CV1->CV1_CTTFIM))) .Or. ;
	(nOpcX == 5 .And. (!Empty(CV1->CV1_CTTINI) .Or. !Empty(CV1->CV1_CTTFIM)))
	lCTT		:= .T.
	//Fator de multiplicacao anterior
	nFatorCTTA	:= Ctb390Recn("CTT",CV1->CV1_CTTINI,CV1->CV1_CTTFIM,"CTT_CUSTO")
	
	//Fator de multiplicacao atual
	nFatorCTT	:= Ctb390Recn("CTT",(cAlias)->CV1_CTTINI,(cAlias)->CV1_CTTFIM,"CTT_CUSTO")
EndIf

If (nOpcX == 3 .And. (!Empty((cAlias)->CV1_CT1INI) .Or. !Empty((cAlias)->CV1_CT1FIM))) .Or. ;
	(nOpcX == 4 .And. (!Empty((cAlias)->CV1_CT1INI) .Or. !Empty((cAlias)->CV1_CT1FIM) .Or. ;
	!Empty(CV1->CV1_CT1INI) .Or. !Empty(CV1->CV1_CT1FIM))) .Or. ;
	(nOpcX == 5 .And. (!Empty(CV1->CV1_CT1INI) .Or. !Empty(CV1->CV1_CT1FIM)))
	lCT1		:= .T.
EndIf

aFatorEntd := {}
aAdd(aFatorEntd, { lCT1, 1, 1} )
aAdd(aFatorEntd, { lCTT,nFatorCTT,nFatorCTTA} )
aAdd(aFatorEntd, { lCTD,nFatorCTD,nFatorCTDA} )
aAdd(aFatorEntd, { lCTH,nFatorCTH,nFatorCTHA} )
aAdd(aFatorEntd, { lEntid05,nFatEnt05,nFatEnt05A} )
aAdd(aFatorEntd, { lEntid06,nFatEnt06,nFatEnt06A} )
aAdd(aFatorEntd, { lEntid07,nFatEnt07,nFatEnt07A} )
aAdd(aFatorEntd, { lEntid08,nFatEnt08,nFatEnt08A} )
aAdd(aFatorEntd, { lEntid09,nFatEnt09,nFatEnt09A} )

//Atualizar arquivo CVX CVY para as entidades adicionais
If lCT1 .Or. lCTT .Or. lCTD .Or. lCTH .Or. lEntid09 .Or. lEntid08 .Or. lEntid07 .Or. lEntid06 .Or. lEntid05
	If lCtbIsCube .And. CtbIsCube()
		Ct390Proc(cAlias,cOperacao,aFatorEntd,oObj,nValorAnt)
	EndIf
EndIf

//Atualizar arquivo CTI
If lCTH
	Ctb390CTI(cAlias,cOperacao,aFatorEntd,oObj,nValorAnt)	//Grava os valores no CTI com Reclock(".T.")
EndIf

//Atualizar arquivo CT4
If lCTD
	Ctb390CT4(cAlias,cOperacao,aFatorEntd,oObj,nValorAnt)	//Grava os valores no CT4 com Reclock(".T.")
EndIf

//Atualizar arquivo CT3
If lCTT
	Ctb390CT3(cAlias,cOperacao,aFatorEntd,oObj,nValorAnt)	//Grava os valores no CT3 com Reclock(".T.")
EndIf

//Atualizar arquivo CT7
If lCT1
	Ctb390CT7(cAlias,cOperacao,aFatorEntd,oObj,nValorAnt)	//Grava os valores no CT7 com Reclock(".T.")
EndIf

RestArea(aSaveArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb390Apag³ Autor ³ Simone Mie Sato       ³ Data ³ 03/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Deleta os registros que estiverem com debito/credito zerados³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb390Apag()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Montar query.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias   = Alias do arquivo a ser consultado               ³±±
±±³          ³ cOperacao= Operacao a ser executada.(1=Soma;2=Subtracao)   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb390Apag(cAlias,lMoedaesp,cMoeda,cFilSal,oObj)

Local aSaveArea	:= GetARea()
Local cCond		:= ""
Local cInicial	:= cAlias + "_"
Local c390Zera	:= ""

If !GetNewPar("MV_ATUSLON",.T.)			/// DESLIGA ATUALIZAÇÃO DE SALDO ON-LINE ORCAMENTO
	RestArea(aSaveArea)
	Return
EndIf

If lMoedaEsp //Se for Moeda Especifica
	cCond :="ARQ."+cInicial+ "MOEDA ='" + cMoeda +"' AND "
Else
	cCond := ""
Endif

c390Zera := "c390Zera"

cQuery := "SELECT R_E_C_N_O_ RECNO "
cQuery += "FROM "+RetSqlName(cAlias)+ " ARQ "
cQuery += "WHERE " +"ARQ."+cInicial+ "FILIAL = '"+cFilSal+"' AND "
cQuery += "(ARQ."+cInicial+"DEBITO = 0 AND ARQ."+cInicial+"CREDIT = 0) AND "
cQuery += cCond
cQuery += "ARQ."+cInicial+"TPSALD='0' AND  "
cQuery += "ARQ.D_E_L_E_T_ = ' '"        
cQuery += " ORDER BY RECNO "
cQuery := ChangeQuery(cQuery)

If ( Select ( "c390Zera" ) <> 0 )
	dbSelectArea ( "c390Zera" )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),c390Zera,.T.,.F.)

dbSelectArea(cAlias)

If lMoedaEsp //Se for Moeda Especifica
	cCond := " " + cInicial+ "MOEDA ='" + cMoeda +"' AND "
Else
	cCond := ""
Endif


cQuery := "DELETE FROM "
cQuery += RetSqlName(cAlias) + " "
cQuery += "WHERE " +cInicial+ "FILIAL = '"+cFilSal+"' AND "
cQuery += "( "+ cInicial+"DEBITO = 0 AND "+cInicial+"CREDIT = 0) AND "
cQuery += cCond
cQuery += " "+cInicial+"TPSALD='0' AND "

				
While c390Zera->(!Eof())
	
	nMin := (c390Zera)->RECNO
			
	nCountReg := 0
				
	While c390Zera->(!EOF()) .and. nCountReg <= 4096
					
		nMax := (c390Zera)->RECNO
		nCountReg++
		c390Zera->(DbSkip())

	End
				
	cChave := "R_E_C_N_O_>="+Str(nMin,10,0)+" AND R_E_C_N_O_<="+Str(nMax,10,0)+""
	TcSqlExec(cQuery+cChave)
					
	If ValType(oObj) == "O"
		oObj:IncRegua1(STR0029+ " - " + cAlias )//Zerando arquivos de Saldos...
	EndIf
		
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A tabela eh fechada para restaurar o buffer da aplicacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbCloseArea()
ChkFile(cAlias)		// Abrir como compartilhado para permitir acesso de outros usuarios

If ( Select ( "c390Zera" ) <> 0 )
	dbSelectArea ( "c390Zera" )
	dbCloseArea ()
Endif

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb390CTI ³ Autor ³ Simone Mie Sato       ³ Data ³ 03/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava os saldos do arquivo CTI.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb390CTI()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Montar query.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias   = Alias do arquivo a ser consultado               ³±±
±±³          ³ cOperacao= Operacao a ser executada.(1=Soma;2=Subtracao)   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb390CTI(cAlias,cOperacao,aFatorEntd,oObj,nValorAnt)

Local aSaveArea	:= GetArea()
Local cQuery    := ""
Local cQuery1	:= ""
Local cConta	:= ""
Local cCusto	:=	""
Local cItem		:= ""
Local cClVl		:= ""
Local lQuery    := .F.
Local cCtb390CTI:= ""
Local nContador	:= 0
Local cCt1Normal:= ""
Local aFatorAux := {}

DEFAULT nValorAnt	:= 0

If cOperacao == "1" 
	aFatorAux := CtbFatFin(aFatorEntd, .T.)
Else
	aFatorAux := CtbFatFin(aFatorEntd, .F.)	
EndIf	


If  ((cAlias)->CV1_CT1INI == (cAlias)->CV1_CT1FIM) .And. ((cAlias)->CV1_CTTINI == (cAlias)->CV1_CTTFIM) .And. ;
	((cAlias)->CV1_CTDINI == (cAlias)->CV1_CTDFIM) .And. ((cAlias)->CV1_CTHINI == (cAlias)->CV1_CTHFIM)
	
	If aFatorEntd[1,1] //lCT1
		If cOperacao == "1"
			cConta	:= (cAlias)->CV1_CT1INI
		ElseIf cOperacao == "2"
			cConta	:= CV1->CV1_CT1INI
		EndIf
	Else
		cConta	:= Space(Len(CT1->CT1_CONTA))
	EndIf
	
	If aFatorEntd[2,1] //lCTT
		If cOperacao == "1"
			cCusto	:= (cAlias)->CV1_CTTINI
		ElseIf cOperacao == "2"
			cCusto	:= CV1->CV1_CTTFIM
		EndIf
	Else
		cCusto	:= Space(Len(CTT->CTT_CUSTO))
	EndIf
	
	If aFatorEntd[3,1] //lCTD
		If cOperacao == "1"
			cItem	:= 	(cAlias)->CV1_CTDINI
		ElseIf cOperacao == "2"
			cItem	:= 	CV1->CV1_CTDINI
		EndIf
	Else
		cItem	:= Space(Len(CTD->CTD_ITEM))
	Endif
	
	If aFatorEntd[4,1] //lCTH
		If cOperacao == "1"
			cClVl	:= 	(cAlias)->CV1_CTHINI
		ElseIf cOperacao == "2"
			cClVl	:= 	CV1->CV1_CTHINI
		EndIf
	Else
		cClVl	:=  Space(Len(CTH->CTH_CLVL))
	EndIf
	
	If Empty(cClVl)
		RestArea(aSaveArea)
		Return
	EndIf
	
	dbSelectArea("CT1")
	dbSetOrder(1)
	If MsSeek(xFilial()+cConta)
		cCt1Normal	:= CT1->CT1_NORMAL
	EndIf
	
	If cCt1Normal = "1"
		If (cAlias)->CV1_VALOR < 0
			GRAVACQ("CTH",3,"",cConta,"",cCusto,"",cItem,"",cClVl,/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[4]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
		Else
			GRAVACQ("CTH",3,cConta,"",cCusto,"",cItem,"",cClVl,"",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[4]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
		Endif
	Else
		If (cAlias)->CV1_VALOR < 0
			GRAVACQ("CTH",3,cConta,"",cCusto,"",cItem,"",cClVl,"",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[4]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
		Else
			GRAVACQ("CTH",3,"",cConta,"",cCusto,"",cItem,"",cClVl,/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[4]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
		Endif
	Endif
Else
	cCtb390CTI	:= "cCtb390CTI"
	lQuery 		:= .T.
	If aFatorEntd[1,1] //lCT1
		cQuery += ",CT1_CONTA, CT1_NORMAL "
	EndIf
	If aFatorEntd[2,1] //lCTT
		cQuery += ",CTT_CUSTO "
	EndIf
	If aFatorEntd[3,1] //lCTD
		cQuery += ",CTD_ITEM "
	EndIf
	If aFatorEntd[4,1] //lCTH
		cQuery += ",CTH_CLVL "
	EndIf
	cQuery := "SELECT "+SubStr(cQuery,2)
	cQuery += "FROM "
	If aFatorEntd[1,1] //lCT1
		cQuery1 +="," + RetSqlName("CT1")+" CT1 "
	EndIf
	If aFatorEntd[2,1] //lCTT
		cQuery1 +="," + RetSqlName("CTT")+" CTT "
	EndIf
	If aFatorEntd[3,1] //lCTD
		cQuery1 +="," +RetSqlName("CTD")+" CTD "
	EndIf
	If aFatorEntd[4,1] //lCTH
		cQuery1 += ", "+RetSqlName("CTH")+" CTH "
	EndIf
	If nContador == 2
		cQuery1 += ", "+RetSqlName("CTI")+" CTI "
	EndIf
	cQuery	+= Substr(cQuery1,2)
	cQuery += "WHERE "
	If aFatorEntd[1,1] //lCT1
		cQuery += "CT1.CT1_FILIAL = '"+xFilial("CT1")+"' AND "
		cQuery += "CT1.CT1_CONTA >= '"+(cAlias)->CV1_CT1INI+"' AND "
		cQuery += "CT1.CT1_CONTA <= '"+(cAlias)->CV1_CT1FIM+"' AND "
		cQuery += "CT1.CT1_CLASSE = '2' AND "
		cQuery += "CT1.D_E_L_E_T_=' ' AND "
	EndIf
	If aFatorEntd[2,1] //lCTT
		cQuery += "CTT.CTT_FILIAL = '"+xFilial("CTT")+"' AND "
		cQuery += "CTT.CTT_CUSTO >= '"+(cAlias)->CV1_CTTINI+"' AND "
		cQuery += "CTT.CTT_CUSTO <= '"+(cAlias)->CV1_CTTFIM+"' AND "
		cQuery += "CTT.CTT_CLASSE = '2' AND "
		cQuery += "CTT.D_E_L_E_T_=' ' AND "
	EndIf
	If aFatorEntd[3,1] //lCTD
		cQuery += "CTD.CTD_FILIAL = '"+xFilial("CTD")+"' AND "
		cQuery += "CTD.CTD_ITEM >= '"+(cAlias)->CV1_CTDINI+"' AND "
		cQuery += "CTD.CTD_ITEM <= '"+(cAlias)->CV1_CTDFIM+"' AND "
		cQuery += "CTD.CTD_CLASSE = '2' AND "
		cQuery += "CTD.D_E_L_E_T_=' ' AND "
	EndIf
	If aFatorEntd[4,1] //lCTH
		cQuery += "CTH.CTH_FILIAL = '"+xFilial("CTH")+"' AND "
		cQuery += "CTH.CTH_CLVL >= '"+(cAlias)->CV1_CTHINI+"' AND "
		cQuery += "CTH.CTH_CLVL <= '"+(cAlias)->CV1_CTHFIM+"' AND "
		cQuery += "CTH.CTH_CLASSE = '2' AND "
		cQuery += "CTH.D_E_L_E_T_=' '"
	EndIf
	cQuery := ChangeQuery(cQuery)
	
	If ( Select ( "cCtb390CTI" ) <> 0 )
		dbSelectArea ( "cCtb390CTI" )
		dbCloseArea ()
	Endif
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCtb390CTI)
	If oObj <> Nil
		oObj:SetRegua2(MAXPASSO)
	Endif	
	dbSelectArea("cCtb390CTI")
	While !Eof()
		dbSelectArea("cCtb390CTI")
		If aFatorEntd[1,1] //lCT1
			cConta	:= cCtb390CTI->CT1_CONTA
		Else
			cConta	:= Space(Len(CT1->CT1_CONTA))
		EndIf
		
		If aFatorEntd[2,1] //lCTT
			cCusto	:= 	cCtb390CTI->CTT_CUSTO
		Else
			cCusto	:= Space(Len(CTT->CTT_CUSTO))
		EndIf
		
		If aFatorEntd[3,1] //lCTD
			cItem	:= 	cCtb390CTI->CTD_ITEM
		Else
			cItem	:= Space(Len(CTD->CTD_ITEM))
		Endif
				
		If aFatorEntd[4,1] //lCTH
			cClVl	:= 	cCtb390CTI->CTH_CLVL
		Else
			cClVl	:=  Space(Len(CTH->CTH_CLVL))
		EndIf		
		If cCtb390CTI->CT1_NORMAL = "1"
			If (cAlias)->CV1_VALOR < 0
				GRAVACQ("CTH",3,"",cConta,"",cCusto,"",cItem,"",cClVl,/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[4]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Else
				GRAVACQ("CTH",3,cConta,"",cCusto,"",cItem,"",cClVl,"",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[4]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Endif
		Else
			If (cAlias)->CV1_VALOR < 0
				GRAVACQ("CTH",3,cConta,"",cCusto,"",cItem,"",cClVl,"",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[4]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Else
				GRAVACQ("CTH",3,"",cConta,"",cCusto,"",cItem,"",cClVl,/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[4]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Endif
		Endif	
		dbSelectArea("cCtb390CTI")
		dbSkip()
		If oObj <> Nil
			oObj:IncRegua2(STR0030) //"Atualizando Saldos da tabela CTI..."
		Endif
	EndDo
EndIf
If ( Select ( "cCtb390CTI" ) <> 0 )
	dbSelectArea ( "cCtb390CTI" )
	dbCloseArea ()
EndIf
RestArea(aSaveArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb390CT4 ³ Autor ³ Simone Mie Sato       ³ Data ³ 03/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava os saldos do arquivo CT4.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb390CT4()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Montar query.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias   = Alias do arquivo a ser consultado               ³±±
±±³          ³ cOperacao= Operacao a ser executada.(1=Soma;2=Subtracao)   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb390CT4(cAlias,cOperacao,aFatorEntd,oObj,nValorAnt)

Local aSaveArea	:= GetArea()
Local cQuery    := ""
Local cQuery1	:= ""
Local cConta	:= ""
Local cCusto	:=	""
Local cItem		:= ""
Local cCtb390CT4:= ""
Local cCt1Normal:= ""
Local lQuery    := .F.
Local aFatorAux := {}

DEFAULT nValorAnt		:= 0

If cOperacao == "1" 
	aFatorAux := CtbFatFin(aFatorEntd, .T.)
Else
	aFatorAux := CtbFatFin(aFatorEntd, .F.)	
EndIf	

If  ((cAlias)->CV1_CT1INI == (cAlias)->CV1_CT1FIM) .And. ((cAlias)->CV1_CTTINI == (cAlias)->CV1_CTTFIM) .And. ;
	((cAlias)->CV1_CTDINI == (cAlias)->CV1_CTDFIM)
	
	If aFatorEntd[1,1] //lCT1
		If cOperacao == "1"
			cConta	:= (cAlias)->CV1_CT1INI
		ElseIf cOperacao == "2"
			cConta	:= CV1->CV1_CT1INI
		EndIf
	Else
		cConta	:= Space(Len(CT1->CT1_CONTA))
	EndIf
	
	If aFatorEntd[2,1] //lCTT
		If cOperacao == "1"
			cCusto	:= (cAlias)->CV1_CTTINI
		ElseIf cOperacao == "2"
			cCusto	:= CV1->CV1_CTTINI
		EndIf
	Else
		cCusto	:= Space(Len(CTT->CTT_CUSTO))
	EndIf
	
	If aFatorEntd[3,1] //lCTD
		If cOperacao == "1"
			cItem	:= 	(cAlias)->CV1_CTDINI
		ElseIf cOperacao == "2"
			cItem	:= CV1->CV1_CTDINI
		EndIf
	Else
		cItem	:= Space(Len(CTD->CTD_ITEM))
	Endif
	
	If Empty(cItem)
		RestArea(aSaveArea)
		Return
	EndIf
	
	dbSelectArea("CT1")
	dbSetOrder(1)
	If MsSeek(xFilial()+cConta)
		cCt1Normal	:= CT1->CT1_NORMAL
	EndIf
	If cCt1Normal = "1"
		If (cAlias)->CV1_VALOR < 0
			GRAVACQ("CTD",3,"",cConta,"",cCusto,"",cItem,"","",/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[3]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
		Else
			GRAVACQ("CTD",3,cConta,"",cCusto,"",cItem,"","","",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[3]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
		Endif
	Else
		If (cAlias)->CV1_VALOR < 0
			GRAVACQ("CTD",3,cConta,"",cCusto,"",cItem,"","","",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[3]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
		Else
			GRAVACQ("CTD",3,"",cConta,"",cCusto,"",cItem,"","",/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[3]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
		Endif
	Endif
Else	
	cCtb390CT4	:= "cCtb390CT4"
	lQuery 		:= .T.
	If aFatorEntd[1,1] //lCT1
		cQuery += ",CT1_CONTA, CT1_NORMAL "
	EndIf
	If  aFatorEntd[2,1] //lCTT
		cQuery += ",CTT_CUSTO "
	EndIf
	If aFatorEntd[3,1] //lCTD
		cQuery += ",CTD_ITEM "
	EndIf
	cQuery := "SELECT "+SubStr(cQuery,2)
	cQuery += "FROM "
	If aFatorEntd[1,1] //lCT1
		cQuery1 +="," + RetSqlName("CT1")+" CT1 "
	EndIf
	If aFatorEntd[2,1] //lCTT
		cQuery1 +="," + RetSqlName("CTT")+" CTT "
	EndIf
	If aFatorEntd[3,1] //lCTD
		cQuery1 +="," +RetSqlName("CTD")+" CTD "
	EndIf
	cQuery	+= Substr(cQuery1,2)
	cQuery += "WHERE "
	If aFatorEntd[1,1] //lCT1
		cQuery += "CT1.CT1_FILIAL = '"+xFilial("CT1")+"' AND "
		cQuery += "CT1.CT1_CONTA >= '"+(cAlias)->CV1_CT1INI+"' AND "
		cQuery += "CT1.CT1_CONTA <= '"+(cAlias)->CV1_CT1FIM+"' AND "
		cQuery += "CT1.CT1_CLASSE = '2' AND "
		cQuery += "CT1.D_E_L_E_T_=' ' AND "
	EndIf
	If aFatorEntd[2,1] //lCTT
		cQuery += "CTT.CTT_FILIAL = '"+xFilial("CTT")+"' AND "
		cQuery += "CTT.CTT_CUSTO >= '"+(cAlias)->CV1_CTTINI+"' AND "
		cQuery += "CTT.CTT_CUSTO <= '"+(cAlias)->CV1_CTTFIM+"' AND "
		cQuery += "CTT.CTT_CLASSE = '2' AND "
		cQuery += "CTT.D_E_L_E_T_=' ' AND "
	EndIf
	If aFatorEntd[3,1] //lCTD
		cQuery += "CTD.CTD_FILIAL = '"+xFilial("CTD")+"' AND "
		cQuery += "CTD.CTD_ITEM >= '"+(cAlias)->CV1_CTDINI+"' AND "
		cQuery += "CTD.CTD_ITEM <= '"+(cAlias)->CV1_CTDFIM+"' AND "
		cQuery += "CTD.CTD_CLASSE = '2' AND "
		cQuery += "CTD.D_E_L_E_T_=' '"
	EndIf
	cQuery := ChangeQuery(cQuery)
	
	If ( Select ( "cCtb390CT4" ) <> 0 )
		dbSelectArea ( "cCtb390CT4" )
		dbCloseArea ()
	Endif
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCtb390CT4)
	If oObj <> Nil
		oObj:SetRegua2(MAXPASSO)
	Endif
	dbSelectArea("cCtb390CT4")
	While !Eof()
		dbSelectArea("cCtb390CT4")
		If aFatorEntd[1,1] //lCT1
			cConta	:= cCtb390CT4->CT1_CONTA
		Else
			cConta	:= Space(Len(CT1->CT1_CONTA))
		EndIf
		
		If aFatorEntd[2,1] //lCTT
			cCusto	:= 	cCtb390CT4->CTT_CUSTO
		Else
			cCusto	:= Space(Len(CTT->CTT_CUSTO))
		EndIf
		
		If aFatorEntd[3,1] //lCTD
			cItem	:= 	cCtb390CT4->CTD_ITEM
		Else
			cItem	:= Space(Len(CTD->CTD_ITEM))
		Endif
		If cCtb390CT4->CT1_NORMAL == "1"
			If (cAlias)->CV1_VALOR < 0
				GRAVACQ("CTD",3,"",cConta,"",cCusto,"",cItem,"","",/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[3]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Else
				GRAVACQ("CTD",3,cConta,"",cCusto,"",cItem,"","","",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[3]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Endif
		Else
			If (cAlias)->CV1_VALOR < 0
				GRAVACQ("CTD",3,cConta,"",cCusto,"",cItem,"","","",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[3]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Else
				GRAVACQ("CTD",3,"",cConta,"",cCusto,"",cItem,"","",/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[3]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Endif
		Endif
		dbSelectArea("cCtb390CT4")
		dbSkip()
		If oObj <> Nil
			oObj:IncRegua2(STR0032) //"Atualizando Saldos da tabela CT4..."
		Endif
	EndDo
EndIf
If ( Select ( "cCtb390CT4" ) <> 0 )
	dbSelectArea ( "cCtb390CT4" )
	dbCloseArea ()
Endif
RestArea(aSaveArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb390CT3 ³ Autor ³ Simone Mie Sato       ³ Data ³ 03/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava os saldos do arquivo CT3.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb390CT3()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Montar query.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias   = Alias do arquivo a ser consultado               ³±±
±±³          ³ cOperacao= Operacao a ser executada.(1=Soma;2=Subtracao)   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb390CT3(cAlias,cOperacao,aFatorEntd,oObj,nValorAnt)

Local aSaveArea		:= GetArea()
Local cQuery    	:= ""
Local cQuery1		:= ""
Local cConta		:= ""                                 
Local cCusto		:=	""
Local cCt1Normal	:= ""
Local cCtb390CT3	:= ""
Local lQuery    	:= .F.
Local aFatorAux 	:= {} 

DEFAULT nValorAnt	:= 0

If cOperacao == "1" 
	aFatorAux := CtbFatFin(aFatorEntd, .T.)
Else
	aFatorAux := CtbFatFin(aFatorEntd, .F.)	
EndIf

If  ((cAlias)->CV1_CT1INI == (cAlias)->CV1_CT1FIM) .And. ((cAlias)->CV1_CTTINI == (cAlias)->CV1_CTTFIM)
	
	If aFatorEntd[1,1] //lCT1
		If cOperacao == "1"
			cConta	:= (cAlias)->CV1_CT1INI
		Elseif cOperacao == "2"
			cConta	:= CV1->CV1_CT1INI
		EndIf
	Else
		cConta	:= Space(Len(CT1->CT1_CONTA))
	EndIf
	
	If aFatorEntd[2,1] //lCTT
		If cOperacao == "1"
			cCusto	:= (cAlias)->CV1_CTTINI
		ElseIf cOperacao == "2"
			cCusto	:= CV1->CV1_CTTINI
		EndIf
	Else
		cCusto	:= Space(Len(CTT->CTT_CUSTO))
	EndIf
	
	If Empty(cCusto)
		RestArea(aSaveArea)
		Return
	EndIf
	
	dbSelectArea("CT1")
	dbSetOrder(1)
	If MsSeek(xFilial()+cConta)
		cCt1Normal	:= CT1->CT1_NORMAL
	EndIf
	If aFatorEntd[1,1] //lCT1 - Se tiver conta, verificar a natureza da conta.
		If cCt1Normal = "1"
			If (cAlias)->CV1_VALOR < 0
				GRAVACQ("CTT",3,"",cConta,"",cCusto,"","","","",/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[2]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Else
				GRAVACQ("CTT",3,cConta,"",cCusto,"","","","","",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[2]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Endif
		Else
			If (cAlias)->CV1_VALOR < 0
				GRAVACQ("CTT",3,cConta,"",cCusto,"","","","","",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[2]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Else
				GRAVACQ("CTT",3,"",cConta,"",cCusto,"","","","",/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[2]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Endif
		Endif
	Else  //Se nao tiver conta no orcamento, considerar como devedor
		If (cAlias)->CV1_VALOR < 0
			GRAVACQ("CTT",3,"",cConta,"",cCusto,"","","","",/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[2]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
		Else
			GRAVACQ("CTT",3,cConta,"",cCusto,"","","","","",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[2]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
		EndIf
	Endif
Else
	cCtb390CT3	:= "cCtb390CT3"
	lQuery 		:= .T.
	If aFatorEntd[1,1] //lCT1
		cQuery += ",CT1_CONTA, CT1_NORMAL "
	EndIf
	If  aFatorEntd[2,1] //lCTT
		cQuery += ",CTT_CUSTO "
	EndIf
	cQuery := "SELECT "+SubStr(cQuery,2)
	cQuery += "FROM "
	If aFatorEntd[1,1] //lCT1
		cQuery1 +="," + RetSqlName("CT1")+" CT1 "
	EndIf
	If aFatorEntd[2,1] //lCTT
		cQuery1 +="," + RetSqlName("CTT")+" CTT "
	EndIf
	cQuery	+= Substr(cQuery1,2)
	cQuery += "WHERE "
	If aFatorEntd[1,1] //lCT1
		cQuery += "CT1.CT1_FILIAL = '"+xFilial("CT1")+"' AND "
		cQuery += "CT1.CT1_CONTA >= '"+(cAlias)->CV1_CT1INI+"' AND "
		cQuery += "CT1.CT1_CONTA <= '"+(cAlias)->CV1_CT1FIM+"' AND "
		cQuery += "CT1.CT1_CLASSE = '2' AND "
		cQuery += "CT1.D_E_L_E_T_=' ' AND "
	EndIf
	If aFatorEntd[2,1] //lCTT
		cQuery += "CTT.CTT_FILIAL = '"+xFilial("CTT")+"' AND "
		cQuery += "CTT.CTT_CUSTO >= '"+(cAlias)->CV1_CTTINI+"' AND "
		cQuery += "CTT.CTT_CUSTO <= '"+(cAlias)->CV1_CTTFIM+"' AND "
		cQuery += "CTT.CTT_CLASSE = '2' AND "
		cQuery += "CTT.D_E_L_E_T_=' '"
	EndIf
	cQuery := ChangeQuery(cQuery)
	If ( Select ( "cCtb390CT3" ) <> 0 )
		dbSelectArea ( "cCtb390CT3" )
		dbCloseArea ()
	Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCtb390CT3)
	If oObj <> Nil
		oObj:SetRegua2(MAXPASSO)
	Endif
			
	dbSelectArea("cCtb390CT3")
	While !Eof()
		dbSelectArea("cCtb390CT3")
		If aFatorEntd[1,1] //lCT1
			cConta	:= cCtb390CT3->CT1_CONTA
		Else
			cConta	:= Space(Len(CT1->CT1_CONTA))
		EndIf
		If aFatorEntd[2,1] //lCTT
			cCusto	:= 	cCtb390CT3->CTT_CUSTO
		Else
			cCusto	:= Space(Len(CTT->CTT_CUSTO))
		EndIf
		If aFatorEntd[1,1] //lCT1 - Se tiver conta, verificar a natureza da conta.
			If cCtb390CT3->CT1_NORMAL = "1"
				If (cAlias)->CV1_VALOR < 0
					GRAVACQ("CTT",3,"",cConta,"",cCusto,"","","","",/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[2]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
				Else
					GRAVACQ("CTT",3,cConta,"",cCusto,"","","","","",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[2]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
				Endif
			Else
				If (cAlias)->CV1_VALOR < 0
					GRAVACQ("CTT",3,cConta,"",cCusto,"","","","","",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[2]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
				Else
					GRAVACQ("CTT",3,"",cConta,"",cCusto,"","","","",/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[2]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
				Endif
			Endif
		Else  //Se nao tiver conta no orcamento, considerar como devedor
			If (cAlias)->CV1_VALOR < 0
				GRAVACQ("CTT",3,"",cConta,"",cCusto,"","","","",/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[2]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Else
				GRAVACQ("CTT",3,cConta,"",cCusto,"","","","","",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[2]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			EndIf
		Endif
		dbSelectArea("cCtb390CT3")
		dbSkip()
		If oObj <> Nil
			oObj:IncRegua2(STR0033) //"Atualizando Saldos da tabela CT3..."
		Endif
	EndDo
EndIf
If ( Select ( "cCtb390CT3" ) <> 0 )
	dbSelectArea ( "cCtb390CT3" )
	dbCloseArea ()
Endif
RestArea(aSaveArea)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb390CT7 ³ Autor ³ Simone Mie Sato       ³ Data ³ 03/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava os saldos do arquivo CT7.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb390CT7()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Montar query.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias   = Alias do arquivo a ser consultado               ³±±
±±³          ³ cOperacao= Operacao a ser executada.(1=Soma;2=Subtracao)   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb390CT7(cAlias,cOperacao,aFatorEntd,oObj,nValorAnt)
Local aSaveArea	:= GetArea()
Local cQuery    := ""
Local cConta	:= ""
Local cCtb390CT7:= ""
Local cCt1Normal:= ""
Local aFatorAux := {}

DEFAULT nValorAnt	:= 0

If cOperacao == "1" 
	aFatorAux := CtbFatFin(aFatorEntd, .T.)
Else
	aFatorAux := CtbFatFin(aFatorEntd, .F.)	
EndIf

If  ((cAlias)->CV1_CT1INI == (cAlias)->CV1_CT1FIM)
	
	If aFatorEntd[1,1] //lCT1
		If cOperacao == "1"
			cConta	:= (cAlias)->CV1_CT1INI
		ElseIf cOperacao == "2"
			cConta	:= CV1->CV1_CT1INI
		Endif
	Else
		cConta	:= Space(Len(CT1->CT1_CONTA))
	EndIf
	
	If Empty(cConta)
		RestArea(aSaveArea)
		Return
	Endif
	
	dbSelectArea("CT1")
	dbSetOrder(1)
	If MsSeek(xFilial()+cConta)
		cCt1Normal	:= CT1->CT1_NORMAL
	EndIf
	If aFatorEntd[1,1] //lCT1 - Se tiver conta, verificar a natureza da conta.
		If cCt1Normal = "1"
			If (cAlias)->CV1_VALOR < 0
				GRAVACQ("CT1",3,"",cConta,"","","","","","",/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[1]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Else
				GRAVACQ("CT1",3,cConta,"","","","","","","",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[1]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Endif
		Else
			If (cAlias)->CV1_VALOR < 0
				GRAVACQ("CT1",3,cConta,"","","","","","","",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[1]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Else
				GRAVACQ("CT1",3,"",cConta,"","","","","","",/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[1]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Endif
		Endif
	Else  //Se nao tiver conta no orcamento, considerar como devedor
		If (cAlias)->CV1_VALOR < 0
			GRAVACQ("CT1",3,"",cConta,"","","","","","",/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[1]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
		Else
			GRAVACQ("CT1",3,cConta,"","","","","","","",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[1]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
		EndIf
	Endif
Else
	cCtb390CT7	:= "cCtb390CT7"
	cQuery += ",CT1_CONTA, CT1_NORMAL "
	cQuery := "SELECT "+SubStr(cQuery,2)
	cQuery += "FROM "
	If aFatorEntd[1,1] //lCT1
		cQuery += RetSqlName("CT1")+" CT1 "
	EndIf
	cQuery += "WHERE "
	If aFatorEntd[1,1] //lCT1
		cQuery += "CT1.CT1_FILIAL = '"+xFilial("CT1")+"' AND "
		cQuery += "CT1.CT1_CONTA >= '"+(cAlias)->CV1_CT1INI+"' AND "
		cQuery += "CT1.CT1_CONTA <= '"+(cAlias)->CV1_CT1FIM+"' AND "
		cQuery += "CT1.CT1_CLASSE = '2' AND "
		cQuery += "CT1.D_E_L_E_T_=' '"
	EndIf
	cQuery := ChangeQuery(cQuery)
	If ( Select ( "cCtb390CT7" ) <> 0 )
		dbSelectArea ( "cCtb390CT7" )
		dbCloseArea ()
	Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCtb390CT7)
	If oObj <> Nil
		oObj:SetRegua2(MAXPASSO)
	Endif
	dbSelectArea("cCtb390CT7")
	While !Eof()
		dbSelectArea("cCtb390CT7")
		If aFatorEntd[1,1] //lCT1
			cConta	:= cCtb390CT7->CT1_CONTA
		Else
			cConta	:= Space(Len(CT1->CT1_CONTA))
		EndIf
		If aFatorEntd[1,1] //lCT1 - Se tiver conta, verificar a natureza da conta.
			If cCtb390CT7->CT1_NORMAL = "1"
				If (cAlias)->CV1_VALOR < 0
					GRAVACQ("CT1",3,"",cConta,"","","","","","",/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[1]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
				Else
					GRAVACQ("CT1",3,cConta,"","","","","","","",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[1]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
				Endif
			Else
				If (cAlias)->CV1_VALOR < 0
					GRAVACQ("CT1",3,cConta,"","","","","","","",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[1]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
				Else
					GRAVACQ("CT1",3,"",cConta,"","","","","","",/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[1]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
				Endif
			Endif
		Else  //Se nao tiver conta no orcamento, considerar como devedor
			If (cAlias)->CV1_VALOR < 0
				GRAVACQ("CT1",3,"",cConta,"","","","","","",/*cIdent*/,"2",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,(Abs((cAlias)->CV1_VALOR)*aFatorAux[1]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			Else
				GRAVACQ("CT1",3,cConta,"","","","","","","",/*cIdent*/,"1",(cAlias)->CV1_DTFIM,(cAlias)->CV1_MOEDA,((cAlias)->CV1_VALOR*aFatorAux[1]),"0",.F.,.F.,.F.,,,If(cOperacao == "1","+","-"))
			EndIf
		Endif
		dbSelectArea("cCtb390CT7")
		dbSkip()
		If oObj <> Nil
			oObj:IncRegua2(STR0034) //"Atualizando Saldos da tabela CT7..."
		Endif
	EndDo
	If ( Select ( "cCtb390CT7" ) <> 0 )
		dbSelectArea ( "cCtb390CT7" )
		dbCloseArea ()
	Endif
EndIf

RestArea(aSaveArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CT390GrSld³ Autor ³ Simone Mie Sato       ³ Data ³ 15/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina para geracao de saldos atraves do menu da rotina.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CT390GrSld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geracao de saldos atraves da chamada do menu da rotina.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  														  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CT390GrSld()
                     
Local aSaveArea	:= GetArea()
Local lX3Aprova	:= .F.
Local lX3STATSL	:= .F.
Local cChave	:= ""
Local cFilSal	:= ""	    
Local cOrderBy	:= ""
Local cQuery	:= ""
Local cWhere	:= ""
Local cZeraOrc	:= ""
Local nMin		:= 0
Local nMax		:= 0
Local nCountReg	:= 0	
Local cKeyOrcAnt := ""

If GetMV("MV_ORCAPRV") == "S"
	lX3Aprova := .T.
Endif

If ISBLIND()
Ctb390IniVar()
EndIf

dbSelectArea("CV2")
lX3STATSL := .T.
 		
If !Pergunte("CTB391", .T.)			
	Pergunte("CTB390", .F.)
	Return .F.
Endif

DbClearFil()

DbSelectArea("CV1")
DbSetOrder(1)             

cFilSal := xFilial("CV1") 
//Monta query do CV1
Ctb390Qry(cFilSal,,,,,.T.)

dbSelectArea ( "cSelOrc" )

While !Eof()
	If lX3STATSL
		If cKeyOrcAnt <> cSelOrc->(CV1_FILIAL+CV1_ORCMTO+CV1_CALEND+CV1_MOEDA+CV1_REVISA)
			If CV2->(dbSeek(cSelOrc->(CV1_FILIAL+CV1_ORCMTO+CV1_CALEND+CV1_MOEDA+CV1_REVISA),.F.))
				RecLock("CV2",.F.)
				Field->CV2_STATSL := "1"
				CV2->(MsUnlock())
				cKeyOrcAnt := cSelOrc->(CV1_FILIAL+CV1_ORCMTO+CV1_CALEND+CV1_MOEDA+CV1_REVISA)
			EndIf
		EndIf
	EndIf
	//O segundo parametro eh passado com 1 => soma
	Ctb390Atu("cSelOrc","1")
	dbSelectArea("cSelOrc")
	dbSkip()
EndDo

If ( Select ( "cSelOrc" ) <> 0 )
	dbSelectArea ( "cSelOrc" )
	dbCloseArea ()
Endif
//Atualiza o flag do orcamento.
cZeraOrc := "cZeraOrc"

cWhere := "WHERE CV1_FILIAL = '"+cFilSal+"' AND "
cWhere += " CV1_ORCMTO >= '"+ mv_par01 + "' AND CV1_ORCMTO <= '" + mv_par02 + "' AND  "
cWhere += " CV1_CALEND >= '"+ mv_par03 + "' AND CV1_CALEND <= '" + mv_par04 + "' AND  "
cWhere += " CV1_MOEDA  >= '"+ mv_par05 + "' AND CV1_MOEDA  <= '" + mv_par06 + "' AND  "
cWhere += " CV1_REVISA >= '"+ mv_par07 + "' AND CV1_REVISA <= '" + mv_par08 + "' AND  "

If lX3Aprova
	cWhere += " CV1_APROVA <> '' AND "
Endif

cWhere += " CV1_STATUS = '1'  AND " //// ALTERADO PARA ATENDER A EXPRESSAO DE INDICE 1
cWhere += " D_E_L_E_T_ = ' ' "

cQuery := "SELECT R_E_C_N_O_ RECNO "
cQuery += "FROM "+RetSqlName("CV1")+"  "
cQuery += cWhere
cOrderBy	:= 	" ORDER BY RECNO "	
cQuery		+= cOrderBy
cQuery := ChangeQuery(cQuery)

If ( Select ( "cZeraOrc" ) <> 0 )
	dbSelectArea ( "cZeraOrc" )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cZeraOrc,.T.,.F.)		
              
//Atualiza o flag
cQuery := "UPDATE "
cQuery += RetSqlName("CV1")+" "
cQuery += "SET CV1_STATUS = '2'"
If !lX3Aprova
	cQuery += ",CV1_APROVA = '"+cUserName+"' "
Endif
cQuery += cWhere

While cZeraOrc->(!Eof())

	nMin := (cZeraOrc)->RECNO
	
	nCountReg := 0
		
	While cZeraOrc->(!EOF()) .and. nCountReg <= 4096
	
		nMax := (cZeraOrc)->RECNO
		nCountReg++
		cZeraOrc->(DbSkip())

	End
		
	cChave := " AND R_E_C_N_O_>="+Str(nMin,10,0)+" AND R_E_C_N_O_<="+Str(nMax,10,0)+""
	TcSqlExec(cQuery+cChave)
			
	
End		

dbCloseArea()
dbSelectArea("CV1")

//// TRATAMENTO PARA ATUALIZAÇÃO DO FLAG DE GERACAO DE SALDOS NO CV2
cQuery := "SELECT R_E_C_N_O_ RECNO "
cQuery += "FROM "+RetSqlName("CV2")+"  "

cWhereCV2 := " WHERE CV2_FILIAL = '"+cFilSal+"' AND "
cWhereCV2 += " CV2_ORCMTO BETWEEN '"+ mv_par01 + "' AND '" + mv_par02 + "' AND  "
cWhereCV2 += " CV2_CALEND BETWEEN '"+ mv_par03 + "' AND '" + mv_par04 + "' AND  "
cWhereCV2 += " CV2_MOEDA  BETWEEN '"+ mv_par05 + "' AND '" + mv_par06 + "' AND  "
cWhereCV2 += " CV2_REVISA BETWEEN '"+ mv_par07 + "' AND '" + mv_par08 + "' AND  "
If lX3Aprova
	cWhereCV2 += "  CV2_APROVA <> '' AND "
Endif
cWhereCV2 += "  CV2_STATUS = '1'  AND " //// ALTERADO PARA ATENDER A EXPRESSAO DE INDICE 1
cWhereCV2 += "  D_E_L_E_T_ = ' ' "
cQuery += cWhereCV2

cOrderBy	:= 	" ORDER BY RECNO "	
cQuery		+= cOrderBy
cQuery := ChangeQuery(cQuery)

If ( Select ( "cZeraOrc" ) <> 0 )
	dbSelectArea ( "cZeraOrc" )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cZeraOrc,.T.,.F.)


//Atualiza o flag no CV2
cQuery := " UPDATE "+RetSqlName("CV2")
cQuery += " SET CV2_STATUS = '2' "
If !lX3Aprova
	cQuery += ",CV2_APROVA = '"+cUserName+"' "
Endif
cQuery += cWhereCV2

While cZeraOrc->(!Eof())

	nMin := (cZeraOrc)->RECNO
	
	nCountReg := 0
		
	While cZeraOrc->(!Eof()) .and. nCountReg <= 4096
	
		nMax := (cZeraOrc)->RECNO
		nCountReg++
		cZeraOrc->(DbSkip())

	End
		
	cChave := " AND R_E_C_N_O_>="+Str(nMin,10,0)+" AND R_E_C_N_O_<="+Str(nMax,10,0)+""
	TcSqlExec(cQuery+cChave)
	
 			cZeraOrc->(DbSkip())

End

If l390SLSQL 						/// PE APOS A GERACAO DE SALDO E GRAVACAO DO STATUS NO ORCAMENTO
	ExecBlock("CT390SLSQL", .F., .F.,{cWhere})
Endif	

Pergunte("CTB390", .F.)

RestArea(aSaveArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTB390SlOn³ Autor ³ Simone Mie Sato       ³ Data ³ 16/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para atualizacao de saldos on-line.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB390SlOn()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Disponibilizar os valores orcados  para  os  balancetes  e ³±±
±±³          ³ demonstrativos contabeis                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcx =Indica qual a opcao.								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB390SlOn(nOpcX,nValorAnt,nValor,lRevisao,lAltValor)

Local aSaveArea	:= GetArea()

DEFAULT nValorAnt	:= 0
DEFAULT nValor		:= 0

If GetNewPar("MV_ATUSLON",.T.)			/// DESLIGA ATUALIZAÇÃO DE SALDO ON-LINE ORCAMENTO
	
	//Se for exclusao ou alteracao de lancamento contabil.
	If (nOpcX == 5 .Or.nOpcX == 4 .Or. (nOpcX == 3 .And. lRevisao)) .And. nValorAnt <> 0
		//If (nOpcX == 5 .Or.nOpcX == 4 .Or. (nOpcX == 3 .And. lRevisao)) .And. lAltValor
		//O segundo parametro eh passado com 2 => subtracao
		Ctb390Atu("CV1","2",,nValorAnt,nOpcX,lAltValor)
	EndIf
	
	//O segundo parametro eh passado com 1 => soma
	If (nOpcX = 3 .Or. (nOpcX == 4 .And. !TMP->CV1_FLAG)) .And. nValor <> 0
		Ctb390Atu("TMP","1",,,nOpcX,lAltValor)
	EndIf

EndIf

RestArea(aSaveArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb390Recn³ Autor ³ Simone Mie Sato       ³ Data ³ 22/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para saber o numero de entidades do intervalo.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB390Recn()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB390Recn(cArquivo, cEntidIni, cEntidFim, cCampo, cIdEntid)

Local aSaveArea	:= GetArea()
Local nTotReg	:= 0                  
Local cPlanoEnt := ""
Local cPrefix   := PrefixoCpo(cArquivo)
Local cQuery	:= ""

DEFAULT cIdEntid := ""

If cArquivo == "CV0"
	dbSelectArea("CT0")
	If dbSeek(xFilial("CT0")+cIdEntid)
		cPlanoEnt := CT0->CT0_ENTIDA
	EndIf
EndIf
 		
c390Recn:= "c390Recn"
cQuery	:= "SELECT COUNT(*) TOTAL "
cQuery	+= "FROM "+RetSqlName(cArquivo)+" "
cQuery  += "WHERE "+cPrefix+"_FILIAL = '"+xFilial(cArquivo)+"' AND "
 	    If cArquivo == "CV0"
 	    cQuery += cPrefix+"_PLANO = '"+cPlanoEnt+"' AND "
 		EndIf    
cQuery  += cCampo + " >= '" + cEntidIni + "' AND "
cQuery  += cCampo + " <= '" + cEntidFim + "' AND "
    If cArquivo $ "CT1|CTT|CTD|CTH|CV0"
	cQuery  += cPrefix+"_CLASSE = '2' AND "
EndIf
cQuery	+= " D_E_L_E_T_ =' '"
cQuery  := ChangeQuery(cQuery)

If ( Select ( "c390Recn" ) <> 0 )
	dbSelectArea ( "c390Recn" )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),c390Recn,.T.,.F.)

nTotReg	:= (c390Recn)->TOTAL
dbCloseArea()

If nTotReg == 0
	nTotReg	:= 1
EndIf

RestArea(aSaveArea)
Return(nTotReg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB390xN  ºAutor  ³Marcos S. Lobo      º Data ³  07/17/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Aplica Taxa/Valor/Formula sobre o valor do orcamento        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - Rotina de Orcamentos SIGACTB                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb390xN(nSeqORC,aColsP)

Local axNArea := GetArea()
Local nOrdTMP := TMP->(IndexOrd())
Local nRecTMP := TMP->(Recno())

Local nxNValor	:= 0
Local cxNTipo 	:= STR0039 //"1=Percentual;2=Multiplicação;3=Formula"
Local axNTIPO	:= {}//{ {"1","Percentual"},{"2","Multiplicação"},{"3","Formula"} }
Local cxNAPLIC	:= STR0040 //"1=Linha;2=Tudo"
Local axNAPLIC	:= {}//{ {"1,Linha"},{"2","Tudo"} }
Local nCont

Private oDlgxN,oValor,oCboTipo,oFormula,oCboAplic
Public cxNFML	:= GetNewPar("MV_CTB390F","VALOR*1.1")+SPACE(128)

aArray1	:= RetSx3Box(cxNTipo,,,1)
For nCont := 1 To Len(aArray1)
	AADD(axNTIPO,aArray1[nCont][1])
Next nCont

aArray1	:= RetSx3Box(cxNAPLIC,,,1)
For nCont := 1 To Len(aArray1)
	AADD(axNAPLIC,aArray1[nCont][1])
Next nCont

cxNTIPO		:= "1"
cxNAPLIC	:= "1"

DEFAULT aColsP		:= aColsP										/// ARRAY DE PERIODOS E VALORES
DEFAULT nSeqORC 	:= Val(TMP->CV1_SEQUEN)							/// POSICAO ATUAL NO ARRAY DE PERIODOS (SEQUENCIA DO ORÇAMENTO)

Public VALOR := 0
DEFINE MSDIALOG oDlgxN TITLE STR0038 From 0,0 to 115,450 of oMainWnd PIXEL//"Multiplica por - <F5>"
@ 008,005 	SAY STR0041 FONT Of oDlgxN PIXEL //"Fator"
@ 005,040 	MSGET oValor VAR nxNValor Of oDlgxN PIXEL Picture PesqPict("CV1","CV1_VALOR")
@ 020,005 	SAY STR0042 FONT Of oDlgxN PIXEL //"Usando"
@ 018,040 	MSCOMBOBOX oCboTipo VAR cxNTipo ITEMS axNTipo SIZE 45,10 OF oDlgxN PIXEL VALID If(cxNTipo$"123",.T.,.F.)
oCboTipo:bChange:= {|| xN390Fml(cxNTipo)}
@ 032,005 	SAY STR0043 FONT Of oDlgxN PIXEL //"Aplicar a"
@ 030,040 	MSCOMBOBOX oCboAplic VAR cxNAPLIC ITEMS axNAPLIC SIZE 45,10 OF oDlgxN PIXEL VALID If(cxNAPLIC$"12",.T.,.F.)
@ 044,005 	SAY STR0044 FONT Of oDlgxN PIXEL //"Formula:"
@ 042,040 	MSGET oFormula VAR cxNFML Of oDlgxN PIXEL Picture "@S" SIZE 180,10 F3 "SM4FML" VALID A370VerFor() .and. !Empty(cxNFML) .and. VALTYPE(&(cxNFML)) == "N"
oFormula:Disable()

oBtn1 				:= SBUTTON():Create(oDlgxN)
oBtn1:cName			:= "oBtn1"
oBtn1:cCaption		:= "&Ok"
//oBtn1:cMsg 			:= "O|"
oBtn1:nLeft 		:= 300
oBtn1:nTop 			:= 035
oBtn1:nWidth 		:= 52
oBtn1:nHeight 		:= 22
oBtn1:lShowHint  	:= .F.
oBtn1:lReadOnly		:= .F.
oBtn1:Align 		:= 0
oBtn1:lVisibleControl := .T.
oBtn1:nType 		:= 1
oBtn1:bAction 		:= {|| xn390Mult(nSeqOrc,aColsP,nxNValor,cxNTipo,cxNFML,cxNAPLIC) }

oBtn2 				:= SBUTTON():Create(oDlgxN)
oBtn2:cName			:= "oBtn2"
//oBtn2:cCaption		:= "X"
//oBtn2:cMsg 			:= "Cancelar"
oBtn2:nLeft 		:= 370
oBtn2:nTop 			:= 035
oBtn2:nWidth 		:= 52
oBtn2:nHeight 		:= 22
oBtn2:lShowHint  	:= .F.
oBtn2:lReadOnly		:= .F.
oBtn2:Align 		:= 0
oBtn2:lVisibleControl := .T.
oBtn2:nType 		:= 2
oBtn2:bAction 		:= {|| oDlgxN:End() }

ACTIVATE MSDIALOG oDlgxN CENTERED


TMP->(dbSetOrder(nOrdTMP))
TMP->(MsGoTo(nRecTMP))
RestArea(axNArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³xN390Fml  ºAutor  ³Marcos S. Lobo      º Data ³  07/18/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Refresh de objetos na tela de Multiplicacao do Orcamento    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - Rotina de Orcamentos SIGACTB                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function xN390Fml(cxNTipo)
If cxNTipo == "3"
	oValor:Disable()
	oFormula:Enable()
	oFormula:SetFocus()
	oDlgxN:Refresh()
Else
	oFormula:Disable()
	oValor:Enable()
	oDlgxN:Refresh()
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³xn390Mult ºAutor  ³Marcos S. Lobo      º Data ³  07/18/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetiva a multiplicacao configurada em tela no orcamento    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - Rotina de Orcamento SIGACTB                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function xn390Mult(nSeqOrc,aColsP,nxNValor,cxNTipo,cxNFML,cxNAPLIC)

Local ni
Local nLin		:= oPeriodo:nAt

If !cxNTipo$"123"
	MsgInfo(STR0042+" ?")
	oCboTipo:SetFocus()
	Return
Endif

If !cxNAPLIC$"12"
	MsgInfo(STR0043+" ?")
	oCboAPLIC:SetFocus()
	Return
Endif

If cxNTIPO <> "3"					//// SE NÃO FOR ATRAVÉS DE FORMULA
	If nxnValor == 0
		MsgInfo(STR0041+" ?")
		oValor:SetFocus()
		Return
	Endif
	If cxNAPLIC == "1"
		If cxNTIPO == "1"
			aColsP[nSEQORC][nLin][4] += aColsP[nSEQORC][nLin][4] * (nxnValor/100)
		Else
			aColsP[nSEQORC][nLin][4] := aColsP[nSEQORC][nLin][4] * nxnValor
		Endif
	Else
		dbSelectArea("TMP")
		TMP->(dbGoTop())
		nLINTMP := 1
		While !Eof()
			For nI := 1 to Len(aColsP[nLINTMP])
				If cxNTIPO == "1"
					aColsP[nLINTMP][nI][4] += aColsP[nLINTMP][nI][4] * (nxnValor/100)
				Else
					aColsP[nLINTMP][nI][4] := aColsP[nLINTMP][nI][4] * nxNValor
				Endif
			Next
			TMP->(dbSkip())
			nLINTMP++
		Enddo
	Endif
ElseIf cxNTIPO == "3" 					//// SE USAR O TIPO FORMULA
	If cxNAPLIC == "1"
		VALOR := aColsP[nSEQORC][nLin][4]
		aColsP[nSEQORC][nLin][4] := &(cxNFML)
	Else
		dbSelectArea("TMP")
		TMP->(dbGoTop())
		nLINTMP := 1
		While !Eof()
			For nI := 1 to Len(aColsP[nLINTMP])
				VALOR := aColsP[nLINTMP][nI][4]
				aColsP[nLINTMP][nI][4] := &(cxNFML)
			Next
			TMP->(dbSkip())
			nLINTMP++
		Enddo
	Endif
Endif

oDlgxN:End()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA390   ºAutor  ³Microsiga           º Data ³  09/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ct390OnChg(oPeriodo, oOrcado, oVlrOrc, nOrc, oTotOrc, nTotOrc, cPictVal, lExecChg)
Local nSeqOrc := 1

IF lExecChg
	If VAL(TMP->CV1_SEQUEN) > 0 .Or. TMP->CV1_SEQUEN <> nil
		nSeqOrc := VAL(TMP->CV1_SEQUEN)
	Endif	

	If TMP->CV1_SEQUEN > cTmSequen
		ApMsgAlert("Sequencia do orçamento maior do que o definido pelo parametro MV_CV1SEQ!","Aviso !")
	Endif
				
	Ctb390CarCal(nSeqOrc, oPeriodo) 
	CTB390DspOrc(oOrcado,oVlrOrc,@nOrc,oTotOrc,@nTotOrc)
	If Len(aColsP) >= nSeqOrc
		oPeriodo:SetArray(aColsP[nSeqOrc])
		oPeriodo:bLine := { ||{ aColsP[nSeqOrc][oPeriodo:nAt,1],aColsP[nSeqOrc][oPeriodo:nAt,2],aColsP[nSeqOrc][oPeriodo:nAt,3],Trans(aColsP[nSeqOrc][oPeriodo:nAt,4], cPictVal) } }
		oPeriodo:Refresh()
		lExecChg := .T.
	EndIf			
Endif
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Aj390Leg  ºAutor  ³Marcos S. Lobo      º Data ³  12/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para ajustar a legenda atualizando o campo CV2_STATSLº±±
±±º          ³que contem o flag de processmto. pela rotina de ger de saldoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Aj390Leg()

If !MsgYesNo("Prosseguir com a Atualização do Flag. Geração de Saldo ?","Atualização CV2_STATSL - Orçamento SIGACTB")
	Return
EndIf

Processa({|| ProcLeg390(.T.) },"Atualização Flag.Ger.Saldo - Orçamento")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ProcLeg390ºAutor  ³Marcos S. Lobo      º Data ³  12/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina chamada para atualizacao do campo CV2_STATSL         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - CTBA390 - Aj390Leg                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ProcLeg390(lRegua)

Local nLidos	:= 0
Local nGerados	:= 0
Local cKeyCV1	:= ""

DEFAULT lRegua	:= .F.

dbSelectArea("CV2")

If lRegua
	ProcRegua(RecCount())
EndIf

dbSelectArea("CV2")
dbGoTop()
While CV2->(!Eof())
	If lRegua
		IncProc()
	EndIf
	If CV2->CV2_STATUS <> "1"
		CV2->(dbSkip())
		Loop
	EndIf

	nLidos		:= 0
	nGerados	:= 0

	cKeyCV1 := CV2->(CV2_FILIAL+CV2_ORCMTO+CV2_CALEND+CV2_MOEDA+CV2_REVISA)
	dbSelectArea("CV1")
	dbSetOrder(1)
	If dbSeek(cKeyCV1,.F.)
		While CV1->(!Eof()) .and. CV1->(CV1_FILIAL+CV1_ORCMTO+CV1_CALEND+CV1_MOEDA+CV1_REVISA) == cKeyCV1
			nLidos++
			If CV1->CV1_STATUS == "2"
				nGerados++
			EndIf
			CV1->(dbSkip())
		EndDo	
		
		If nLidos <> nGerados .and. nGerados <> 0
			RecLock("CV2",.F.)
			Field->CV2_STATSL := "1"
			CV2->(MsUnlock())
		EndIf		
	EndIf

	dbSelectArea("CV2")
	dbSkip()
EndDo

MsgInfo("Atualização CV2_STATSL Ok !","Fim da Atualização")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A390GetStruºAutor  ³Renato F. Campos    º Data ³ 04/29/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ retorna a estrutura a ser utilizada pelo temporario da telaº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA390                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A390GetStru( cAlias,aHeader,aMemos,aAltera )
Local aStru 	:= {}
Local cCpoSyp

DEFAULT aHeader := {}
DEFAULT aMemos  := {}

// Defino aHeader
dbSelectArea( "Sx3" )
SX3->( DbSetOrder(1) )

Dbseek( cAlias )

// tratamento dos campos 
aMemos := {}
While !EOF() .And. x3_arquivo == cAlias

	IF X3Uso( x3_usado ) .AND. cNivel >= x3_nivel .And. ( Alltrim( X3_CAMPO ) <> "CV1_APROVA" )
		
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal, x3_valid,x3_usado, x3_tipo, "TMP", x3_context } )

		If Alltrim(x3_campo) <> "CV1_SEQUEN"
			Aadd(aAltera,Trim(X3_CAMPO))
		EndIf
	ENDIF

	Aadd(aStru,{ Trim(X3_CAMPO), X3_TIPO, X3_TAMANHO, X3_DECIMAL })

	If At("MSMM(", Upper(SX3->X3_RELACAO)) > 0
		cCpoSyp := Subs(SX3->X3_RELACAO, At("MSMM(", Upper(SX3->X3_RELACAO)) + 5)
		cCpoSyp := Left(cCpoSyp, At(")", cCpoSyp) - 1)
		cCpoSyp := StrTran(cCpoSyp, cAlias + "->", "")

		Aadd( aMemos, { cCpoSyp, SX3->X3_CAMPO })
	Endif

	dbSkip()
EndDO

// Crio e carrego o temporario
Aadd( aStru,{ "CV1_ENTIDA", "N", 05, 0 })
Aadd( aStru,{ "CV1_FLAG"  , "L", 01, 0 })

Return aStru

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A390GetDadoºAutor  ³Renato F. Campos    º Data ³ 04/29/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Alimenta os dados do temporario deacordo com o cabeçalho   º±±
±±º          ³ NOTA: se houver a necessidade de forçar o posicionamento   º±±
±±º          ³ do CV2, avaliar a possibilidade de salvar o registo em um  º±±
±±º          ³ objeto de memoria                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA390                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A390GetDado( nRecCv2, aHeader, aMemo, nOpcX, lRevisao, lCopia, lIsAprov, cCv1Aprova, lX3APROVA  )

Local aSaveArea := GetArea()
Local nCpo
Local nTotOrc 	:= 0
Local nCont	  	:= 1
Local cRevisa 	:= CV2->CV2_REVISA
Local lSeqMaior := .F.
Local nDifCols  := 0

Default lX3APROVA := .F.

// Se for um Novo registro e não for revisão e não for copia de registro
If nOpcX == 3 .And. !lRevisao .And. !lCopia

	DbSelectArea("TMP")
	DbAppend()

	ProcRegua( 1 )

	For nCpo := 1 To Len(aHeader)
		If ( aHeader[nCpo][08] <> "M" .And. aHeader[nCpo][10] <> "V" )
			Replace &(aHeader[nCpo][2]) With CriaVar(aHeader[nCpo][2], .T.)
		ElseIf aHeader[nCpo][08] = "M"
			Replace &(aHeader[nCpo][2]) With CriaVar(aHeader[nCpo][2])
		EndIf
	Next nCpo
	
	REPLACE TMP->CV1_SEQUEN	WITH STRZERO( 1, Len(CV1->CV1_SEQUEN) )

	M->CV1_REVISA	:= "001"
	nTotOrc := 0.00
Else
	// Alteração / exclusão / visualização / copia / revisão

	dbSelectArea( "CV1" )
	dbSetOrder(1)

	If ! MsSeek( CV2->(CV2_FILIAL+CV2_ORCMTO+CV2_CALEND+CV2_MOEDA+CV2_REVISA) )
		ApMsgAlert("Orçamento não encontrado no CV1 !","Inconsistência !")
		Return .F.
	Else
		M->CV1_ORCMTO	:= CV2->CV2_ORCMTO
		M->CV1_CALEND	:= CV2->CV2_CALEND
		M->CV1_MOEDA	:= CV2->CV2_MOEDA
		M->CV1_DESCRI   := CV2->CV2_DESCRI

		If lCopia
			M->CV1_STATUS	:= "1"
		Else
			M->CV1_STATUS	:= CV2->CV2_STATUS
		Endif

		If lRevisao .and. lIsAprov
			M->CV1_APROVA	:= cCV1APROVA
		Else
			If lCopia
				If lX3Aprova
					M->CV1_APROVA	:= ""
				Else
					M->CV1_APROVA	:= cUserName
				Endif
			Else
				M->CV1_APROVA	:= CV2->CV2_APROVA
			Endif
		Endif

		// busca a revisão do orçamento
		M->CV1_REVISA := A390GetRev( lRevisao, lCopia , cRevisa )

		// total do orçamento
		aColsP := {}
		lSeqMaior := .F.
         
		If ( Select ( "tmpEnt" ) <> 0 )
			dbSelectArea ( "tmpEnt" )
			dbCloseArea ()
		Endif
			
		If ( Select ( "tmpPer" ) <> 0 )
			dbSelectArea ( "tmpPer" )
			dbCloseArea ()
		Endif

		cQrySelec := "SELECT "
		cQryCpo := "" 
		For nCpo := 1 To Len( aHeader )
			IF ! Empty( cQryCpo )
				cQryCpo += ", "
			Endif

			If aHeader[nCpo][10] <> "V"
				cQryCpo += aHeader[nCpo][2]
			EndIf
		Next

		// Cria o temporario das entidades do orçamento
		cQrySelec += cQryCpo

		cQryFrom  := " FROM " + RetSqlName("CV1") + " CV1 "

		cQryWhere := " WHERE CV1.CV1_FILIAL = '"  + xFilial("CV1")+ "' "
		cQryWhere += "   AND CV1.CV1_ORCMTO = '"  + M->CV1_ORCMTO + "' "
		cQryWhere += "   AND CV1.CV1_CALEND = '"  + M->CV1_CALEND + "' "
		cQryWhere += "   AND CV1.CV1_MOEDA  = '"  + M->CV1_MOEDA  + "' "
		cQryWhere += "   AND CV1.CV1_REVISA = '"  + cRevisa		  + "' "
		cQryWhere += "   AND CV1.CV1_SEQUEN <= '" + cTmSequen	  + "' "
		cQryWhere += "   AND D_E_L_E_T_ = ' ' "


		cQryGroup := " GROUP BY " + cQryCpo
		cQryOrder := " ORDER BY CV1_SEQUEN"

		cQuery := ChangeQuery( cQrySelec + cQryFrom + cQryWhere + cQryGroup + cQryOrder )

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'tmpEnt',.T.,.F.)

		// Cria o temporario dos periodos do orçamento
		cQrySelec := "SELECT CV1_SEQUEN, CV1_CALEND,CV1_PERIOD, CV1_DTINI, CV1_DTFIM ,CV1_VALOR, R_E_C_N_O_ "

		cQuery := ChangeQuery( cQrySelec + cQryFrom + cQryWhere + cQryOrder )

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'tmpPer',.T.,.F.)

		TcSetField("tmpPer","CV1_DTINI","D",8,0)
		TcSetField("tmpPer","CV1_DTFIM","D",8,0)
		TcSetField("tmpPer","CV1_VALOR","N",12,2)

		// Cria o temporario dos periodos do orçamento
		cQrySelec := "SELECT MAX( CV1_SEQUEN ) MaxSequen "
		cQrySelec += cQryFrom
		cQrySelec += " WHERE CV1.CV1_FILIAL = '"  + xFilial("CV1")+ "' "
		cQrySelec += "   AND CV1.CV1_ORCMTO = '"  + M->CV1_ORCMTO + "' "
		cQrySelec += "   AND CV1.CV1_CALEND = '"  + M->CV1_CALEND + "' "
		cQrySelec += "   AND CV1.CV1_MOEDA  = '"  + M->CV1_MOEDA  + "' "
		cQrySelec += "   AND CV1.CV1_REVISA = '"  + cRevisa		  + "' "
		cQrySelec += "   AND D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery( cQrySelec )

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'tmpMax',.T.,.F.)

		// carrego os dados da array antes de passar os dados para o temporario das entidades
		DbSelectArea( 'tmpMax' )
		cSequen := tmpMax->MaxSequen
		DbCloseArea()

		cQrySelec := "SELECT SUM( CV1_VALOR ) TOTALORC, count( R_E_C_N_O_ ) RECCOUNT"
		cQuery := ChangeQuery( cQrySelec + cQryFrom + cQryWhere )

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'tmpTot',.T.,.F.)

		TcSetField( "tmpTot","TOTALORC","N",15,2)
		TcSetField( "tmpTot","RECCOUNT","N",15,0)

		// carrego os dados da array antes de passar os dados para o temporario das entidades
		DbSelectArea( 'tmpTot' )    
		nTotOrc   := TMPTOT->TOTALORC
		nReccount := TMPTOT->RECCOUNT
		DbCloseArea()

		If oTotOrc <> Nil
			oTotOrc:Refresh()
		Endif
	
		ProcRegua( nReccount + Val(cSequen) )

		// Limito o tamanho maximo da minha sequen deacordo com sx3 (9999)
		// Caso estoure, recomendar a utilização de um novo orçamento e/ou aumentar o tamanho do campo. 
		// Lembrando que o tamanho permitido já seria o suficiente para a utilização do orçamento pelo sistema ( 9999 )
		If ( cSequen > cTmSequen ) .Or. Val( cSequen ) == 0
			cSequen := cTmSequen
			lSeqMaior := .T.
		Endif

		// carrego a array com todas as sequencias diponiveis
		aColsP	:= {}
		FOR nCont := 1 TO Val( cSequen ) + 1
			AADD(aColsP, {} )
		Next

		cSequen := ""

		// cagerrando os dados dos periodos
		DbSelectArea( 'tmpPer' )
		DbGoTop()
		WHILE tmpPer->( !Eof() )
			IncProc( "Carregando periodos do orçamento" )

			If ( tmpPer->CV1_SEQUEN > cTmSequen ) .Or. Val( tmpPer->CV1_SEQUEN ) == 0
				EXIT
			Endif

			cSequen := tmpPer->CV1_SEQUEN
	
			AADD( aColsP[ Val(cSequen) ], {tmpPer->CV1_PERIOD,tmpPer->CV1_DTINI,tmpPer->CV1_DTFIM,tmpPer->CV1_VALOR,0,0,0 } )
                
			If lRevisao .Or. lCopia
				aColsP[Val(cSequen)][Len(aColsp[Val(cSequen)])][6]	:= 0

				If lRevisao
					aColsP[Val(cSequen)][Len(aColsp[Val(cSequen)])][7]	:= tmpPer->R_E_C_N_O_
				Endif
			Else
				aColsP[Val(cSequen)][Len(aColsp[Val(cSequen)])][6]	:= tmpPer->R_E_C_N_O_
			Endif
			
		    tmpPer->( DbSkip() )
		ENDDO

		// cagerrando os dados das entidades            
		DbSelectArea( 'tmpEnt' )
		DbGoTop()
		WHILE tmpEnt->( !Eof() )
			IncProc( "Carregando dados do orçamento" )

			If ( Val( tmpEnt->CV1_SEQUEN ) > Val( cTmSequen )) .Or. Val( tmpEnt->CV1_SEQUEN ) == 0
			    tmpEnt->( DbSkip() )

			    IF tmpEnt->( EOF() )
			    	EXIT
			    ELSE
			    	LOOP
			    Endif
			Endif

			dbSelectArea("TMP")
			Reclock( "TMP" , .T. )

			For nCpo := 1 To Len( aHeader )
				If (aHeader[nCpo][08] <> "M" .And. aHeader[nCpo][10] <> "V" )
					TMP->&(aHeader[nCpo][2]) := &( "tmpEnt->" + aHeader[nCpo][2] )

				ElseIf aHeader[nCpo][08] = "M"
					TMP->&(aHeader[nCpo][2]) := CriaVar( aHeader[nCpo][2] )
				EndIf
			Next

			// marco a quantidade de entidades para não efetuar o recalculo novamente
			TMP->CV1_ENTIDA := 1

			MsUnLock()
			
		    tmpEnt->( DbSkip() )
		ENDDO

		// fecho os temporarios utilizados para a carga dos orçamentos
		dbSelectArea( "tmpEnt" )
		dbCloseArea()

		dbSelectArea( "tmpPer" )
		dbCloseArea()

		If lSeqMaior
			ApMsgAlert("Orçamento com o número máximo de linhas estourado!" + chr(13) + "Não será possivel exibir todas as linhas do orçamento.","Inconsistência !")
		Endif

	EndIf

EndIf

dbSelectArea("TMP")
DbGoTop()

IF TMP->( Eof() )
	ApMsgAlert("Orçamento não possui linhas!" + chr(13) + "Não será possivel exibir o orçamento.","Inconsistência !")
	RETURN .F.
Endif

If Empty(M->CV1_STATUS)
	M->CV1_STATUS := "1"
Endif

If Empty(M->CV1_APROVA)
	M->CV1_APROVA := " "
Endif 

RestArea(aSaveArea)

RETURN .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA390   ºAutor  ³Microsiga           º Data ³  04/29/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A390GetRev( lRevisao, lCopia , cRevisa )
Local cNewRev

If lRevisao
	MsSeek(CV2->(CV2_FILIAL+CV2_ORCMTO+CV2_CALEND+CV2_MOEDA)+"ZZZ", .T.)
	DbSkip(-1)

	cNewRev := StrZero(Val(CV1->CV1_REVISA) + 1, 3)

	MsSeek(CV2->(CV2_FILIAL+CV2_ORCMTO+CV2_CALEND+CV2_MOEDA)+cRevisa)
ElseIf lCopia
	cNewRev := "001"
Else
	cNewRev := CV2->CV2_REVISA
Endif

Return cNewRev

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef   ºAutor  ³Microsiga           º Data ³  xx/xx/xx   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local nX 		:= 0
Local aCT390BUT := {}

PRIVATE aRotina :={ { STR0001	,"Ctb390Pes" , 0, 1, ,.F.},; //"Pesquisar"
{ STR0002	,"Ctb390Cad(,,2)"					 , 0, 2},; //"Visualizar"
{ STR0003	,"Ctb390Cad(,,3)"					 , 0, 3},; //"Incluir"
{ STR0004	,"Ctb390Cad(,,4)"					 , 0, 4},; //"Alterar"
{ STR0005	,"Ctb390Cad(,,5)"					 , 0, 5},; //"Excluir"
{ STR0018	,"Ctb390Cad(,,6)"					 , 0, 6},; //"Revisao"
{ STR0023	,"CtbLegenda"					 	, 0 ,5, ,.F.},; //"Legenda"
{ STR0024	,"Ctb390Cad(,,7)"					 , 0, 7},; //"Copiar"
{ STR0019	,"Processa( { || Ct390GrSld() })", 0, 4}}   //"Gera Saldo"

If GetMV("MV_ORCAPRV") == "S"
	aAdd(aRotina,{ STR0025	,"Processa( { || Ctb390Aprv() })", 0, 0}) 	 //"Aprovar"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para adicao de botoes no Browse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("CT390BUT")
	aCT390BUT := ExecBlock( "CT390BUT" ,.F.,.F. , aRotina )
	
	IF ValType(aCT390BUT) == "A" .AND. Len(aCT390BUT) > 0
		FOR nX := 1 to Len( aCT390BUT )
			aAdd( aRotina, aCT390BUT[nX] )
		NEXT
	ENDIF
ENDIF

Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AdmAbreSM0³ Autor ³ Orizio                ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array com as informacoes das filias das empresas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AdmAbreSM0()
Local aArea			:= SM0->( GetArea() )
Local aAux			:= {}
Local aRetSM0		:= {}
Local lFWLoadSM0	:= FindFunction( "FWLoadSM0" )
Local lFWCodFilSM0 	:= FindFunction( "FWCodFil" )

If lFWLoadSM0
	aRetSM0	:= FWLoadSM0()
Else
	DbSelectArea( "SM0" )
	SM0->( DbGoTop() )
	While SM0->( !Eof() )
		aAux := { 	SM0->M0_CODIGO,;
					IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
					"",;
					"",;
					"",;
					SM0->M0_NOME,;
					SM0->M0_FILIAL }

		aAdd( aRetSM0, aClone( aAux ) )
		SM0->( DbSkip() )
	End
EndIf

RestArea( aArea )
Return aRetSM0

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb100IniVar  ºAutor  ³Microsiga       º Data ³  06/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Analise da existência dos campos das novas entidades       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb390IniVar()

Local aSaveArea := GetArea()

DbSelectArea("CV1")

If _lCpoEnt05 == Nil
	_lCpoEnt05 := CV1->(FieldPos("CV1_E05INI")>0 .And. FieldPos("CV1_E05FIM")>0)
EndIf
     
If _lCpoEnt06 == Nil
	_lCpoEnt06 := CV1->(FieldPos("CV1_E06INI")>0 .And. FieldPos("CV1_E06FIM")>0)
EndIf

If _lCpoEnt07 == Nil
	_lCpoEnt07 := CV1->(FieldPos("CV1_E07INI")>0 .And. FieldPos("CV1_E07FIM")>0)
EndIf

If _lCpoEnt08 == Nil
	_lCpoEnt08 := CV1->(FieldPos("CV1_E08INI")>0 .And. FieldPos("CV1_E08FIM")>0)
EndIf

If _lCpoEnt09 == Nil
	_lCpoEnt09 := CV1->(FieldPos("CV1_E09INI")>0 .And. FieldPos("CV1_E09FIM")>0)
EndIf

dbSelectArea("CT0")
dbSetOrder(1)
dbSeek(xFilial("CT0"))

Do While !CT0->(Eof()) .And. CT0->CT0_FILIAL==xFilial("CT0")
	If CT0->CT0_ID=="05" .And. _lCpoEnt05
		_cAlias05 := CT0->CT0_ALIAS
		_cCpoChv05 := CT0->CT0_CPOCHV
	EndIf
     
	If CT0->CT0_ID=="06" .And. _lCpoEnt06
		_cAlias06 := CT0->CT0_ALIAS
		_cCpoChv06 := CT0->CT0_CPOCHV
	EndIf

	If CT0->CT0_ID=="07" .And. _lCpoEnt07
		_cAlias07 := CT0->CT0_ALIAS
		_cCpoChv07 := CT0->CT0_CPOCHV
	EndIf

	If CT0->CT0_ID=="08" .And. _lCpoEnt08
		_cAlias08 := CT0->CT0_ALIAS
		_cCpoChv08 := CT0->CT0_CPOCHV
	EndIf

	If CT0->CT0_ID=="09" .And. _lCpoEnt09
		_cAlias09 := CT0->CT0_ALIAS
		_cCpoChv09 := CT0->CT0_CPOCHV
	EndIf

	CT0->(dbSkip())
EndDo

RestArea(aSaveArea)                         

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ Ct390Proc³ Autor  ³ Simone Mie Sato         ³ Data 10.07.01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Inicia o processamento dos arquivos de consolidacao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct390Proc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ N„o h                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct390Proc(cAlias,cOperacao,aFatorEntd,oObj,nValorAnt)
Local cOper 		:= If(cOperacao == "1","+","-")
Local nX
Local cConta		:= ""
Local cCusto		:=	""
Local cItem			:= ""
Local cClVl			:= ""
Local cEntid05		:= ""
Local cEntid06		:= ""
Local cEntid07		:= ""
Local cEntid08		:= ""
Local cEntid09		:= ""
Local cCt1Normal	:= ""
Local cIdEntid
Local cNomeArqEnt
Local cArqInd1
Local cArqInd2

DEFAULT nValorAnt	:= 0

If nQtdEntid == Nil
	nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se nao ha range nas entidades inicial e final informadas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ((cAlias)->CV1_CT1INI == (cAlias)->CV1_CT1FIM) .And.;
 	((cAlias)->CV1_CTTINI == (cAlias)->CV1_CTTFIM) .And.;
	((cAlias)->CV1_CTDINI == (cAlias)->CV1_CTDFIM) .And.;
	((cAlias)->CV1_CTHINI == (cAlias)->CV1_CTHFIM) .And.;
	If(_lCpoEnt05,(cAlias)->CV1_E05INI == (cAlias)->CV1_E05FIM,.T.) .And.;
	If(_lCpoEnt06,(cAlias)->CV1_E06INI == (cAlias)->CV1_E06FIM,.T.) .And.;
	If(_lCpoEnt07,(cAlias)->CV1_E07INI == (cAlias)->CV1_E07FIM,.T.) .And.;
	If(_lCpoEnt08,(cAlias)->CV1_E08INI == (cAlias)->CV1_E08FIM,.T.) .And.;
	If(_lCpoEnt09,(cAlias)->CV1_E09INI == (cAlias)->CV1_E09FIM,.T.)
 
	If aFatorEntd[1,1] //lCT1
		If cOperacao == "1"
			cConta	:= (cAlias)->CV1_CT1INI
		ElseIf cOperacao == "2"
			cConta	:= CV1->CV1_CT1INI
		EndIf
	Else
		cConta	:= Space(Len(CT1->CT1_CONTA))
	EndIf
	
	If aFatorEntd[2,1] //lCTT
		If cOperacao == "1"
			cCusto	:= (cAlias)->CV1_CTTINI
		ElseIf cOperacao == "2"
			cCusto	:= CV1->CV1_CTTFIM
		EndIf
	Else
		cCusto	:= Space(Len(CTT->CTT_CUSTO))
	EndIf
	
	If aFatorEntd[3,1] //lCTD
		If cOperacao == "1"
			cItem	:= 	(cAlias)->CV1_CTDINI
		ElseIf cOperacao == "2"
			cItem	:= 	CV1->CV1_CTDINI
		EndIf
	Else
		cItem	:= Space(Len(CTD->CTD_ITEM))
	Endif
	
	If aFatorEntd[4,1] //lCTH
		If cOperacao == "1"
			cClVl	:= 	(cAlias)->CV1_CTHINI
		ElseIf cOperacao == "2"
			cClVl	:= 	CV1->CV1_CTHINI
		EndIf
	Else
		cClVl	:=  Space(Len(CTH->CTH_CLVL))
	EndIf
	
	If _lCpoEnt05
		If aFatorEntd[5,1] //Entidade 05
			If cOperacao == "1"
				cEntid05 := (cAlias)->CV1_E05INI
			ElseIf cOperacao == "2"
				cEntid05 :=	CV1->CV1_E05INI
			EndIf
		Else
			cEntid05 := Space(Len( &(_cAlias05+"->"+_cCpoChv05) ))
		EndIf
	Else
		cEntid05 := Space(Len(CV0->CV0_CODIGO))
	EndIf
	
	If _lCpoEnt06
		If aFatorEntd[6,1] //Entidade 06
			If cOperacao == "1"
				cEntid06 := (cAlias)->CV1_E06INI
			ElseIf cOperacao == "2"
				cEntid06 := CV1->CV1_E06INI
			EndIf
		Else
			cEntid06 := Space(Len( &(_cAlias06+"->"+_cCpoChv06) ))
		EndIf
	Else 
		cEntid06 := Space(Len(CV0->CV0_CODIGO))
	EndIf
		
	If _lCpoEnt07
		If aFatorEntd[7,1] //Entidade 07
			If cOperacao == "1"
				cEntid07 := (cAlias)->CV1_E07INI
			ElseIf cOperacao == "2"
				cEntid07 := CV1->CV1_E07INI
			EndIf
		Else
			cEntid07 := Space(Len( &(_cAlias07+"->"+_cCpoChv07) ))
		EndIf
	Else
		cEntid07 := Space(Len(CV0->CV0_CODIGO))
	EndIf
		
	If _lCpoEnt08
		If aFatorEntd[8,1] //Entidade 08
			If cOperacao == "1"
				cEntid08 := (cAlias)->CV1_E08INI
			ElseIf cOperacao == "2"
				cEntid08 := CV1->CV1_E08INI
			EndIf
		Else
			cEntid08 := Space(Len( &(_cAlias08+"->"+_cCpoChv08) ))
		EndIf
	Else
		cEntid08 := Space(Len(CV0->CV0_CODIGO))
	EndIf
	
	If _lCpoEnt09
		If aFatorEntd[9,1] //Entidade 09
			If cOperacao == "1"
				cEntid09 := (cAlias)->CV1_E09INI
			ElseIf cOperacao == "2"
				cEntid09 := CV1->CV1_E09INI
			EndIf
		Else
			cEntid09 := Space(Len( &(_cAlias09+"->"+_cCpoChv09) ))
		EndIf
	Else
		cEntid09 := Space(Len(CV0->CV0_CODIGO))
	EndIf
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Identifica se e uma transacao de Debito ou Credito³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CT1")
	dbSetOrder(1)
	If MsSeek(xFilial()+cConta)
		cCt1Normal	:= CT1->CT1_NORMAL
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Arquivo temporario para preenchimento das tabela CVX/CVY (todas entidades inclusive as novas)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Ctb_Cria_Temp(@cNomeArqEnt,@cArqInd1,@cArqInd2)     
	
	RecLock('TRB2',.T.)
	TRB2->CT2_MOEDLC	:= (cAlias)->CV1_MOEDA
	TRB2->CT2_DATA		:= (cAlias)->CV1_DTFIM
	TRB2->CT2_TPSALD	:= "0"
	If (cAlias)->CV1_VALOR < 0
		TRB2->CT2_VALOR		:= Abs((cAlias)->CV1_VALOR)		
	Else
		TRB2->CT2_VALOR		:= (cAlias)->CV1_VALOR
	EndIf
	
	If aFatorEntd[1,1] //lCT1 
		If cCt1Normal = "1" //Verifica a natureza da conta.
			TRB2->CT2_DC		:= If( (cAlias)->CV1_VALOR < 0, "2", cCt1Normal)		
		Else
			TRB2->CT2_DC		:= If( (cAlias)->CV1_VALOR < 0, "1", cCt1Normal)		
		Endif
	Else  //Se nao tiver conta no orcamento, considerar como devedor
		TRB2->CT2_DC		:= If( (cAlias)->CV1_VALOR < 0, "1", cCt1Normal)		
	EndIf
	
	If TRB2->CT2_DC == "1" //Verifica a natureza da conta
		TRB2->CT2_DEBITO	:= (cAlias)->CV1_CT1INI
		TRB2->CT2_CCD		:= (cAlias)->CV1_CTTINI
		TRB2->CT2_ITEMD		:= (cAlias)->CV1_CTDINI
		TRB2->CT2_CLVLDB	:= (cAlias)->CV1_CTHINI
		If (_lCpoEnt05,TRB2->CT2_EC05DB	:= (cAlias)->CV1_E05INI,Nil)
		If (_lCpoEnt06,TRB2->CT2_EC06DB	:= (cAlias)->CV1_E06INI,Nil)
		If (_lCpoEnt07,TRB2->CT2_EC07DB	:= (cAlias)->CV1_E07INI,Nil)
		If (_lCpoEnt08,TRB2->CT2_EC08DB	:= (cAlias)->CV1_E08INI,Nil)
		If (_lCpoEnt09,TRB2->CT2_EC09DB	:= (cAlias)->CV1_E09INI,Nil)
	Else
		TRB2->CT2_CREDIT	:= (cAlias)->CV1_CT1INI
		TRB2->CT2_CCC		:= (cAlias)->CV1_CTTINI
		TRB2->CT2_ITEMC		:= (cAlias)->CV1_CTDINI
		TRB2->CT2_CLVLCR	:= (cAlias)->CV1_CTHINI
		If (_lCpoEnt05,TRB2->CT2_EC05CR := (cAlias)->CV1_E05INI,Nil)
		If (_lCpoEnt06,TRB2->CT2_EC06CR := (cAlias)->CV1_E06INI,Nil)
		If (_lCpoEnt07,TRB2->CT2_EC07CR := (cAlias)->CV1_E07INI,Nil)
		If (_lCpoEnt08,TRB2->CT2_EC08CR := (cAlias)->CV1_E08INI,Nil)
		If (_lCpoEnt09,TRB2->CT2_EC09CR := (cAlias)->CV1_E09INI,Nil)
	EndIf
	MsUnlock()
	
	aFatorAux := CtbFatFin(aFatorEntd, .T.) 
	For nX := 1 TO nQtdEntid
	
		cIdEntid := StrZero(nX, 2)
	
		Ctb_Orct_Cubes(cIdEntid, "TRB2"/*cAliasMov*/,cOper/*cOperacao*/,aFatorAux[nX])
	
	Next
	
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega  os fatores de cada entidade³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFatorAux := CtbFatFin(aFatorEntd, .T.) 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Arquivo temporario para preenchimento das tabela CVX/CVY (todas entidades inclusive as novas)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Ctb_Cria_Temp(@cNomeArqEnt,@cArqInd1,@cArqInd2)     
	For nX := 1 TO nQtdEntid
		cIdEntid := StrZero(nX, 2)
		cQuery := CtbQryEntd(aFatorEntd, cIdEntid, cAlias)
		cQuery  := ChangeQuery(cQuery)
		
		If ( Select ( "TMPORC" ) <> 0 )
			dbSelectArea ( "TMPORC" )
			dbCloseArea ()
		Endif
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPORC",.T.,.F.)
        
		dbSelectArea("TMPORC")
		While TMPORC->(! Eof())
	
			RecLock('TRB2',.T.)
			TRB2->CT2_MOEDLC	:= (cAlias)->CV1_MOEDA
			TRB2->CT2_DATA		:= (cAlias)->CV1_DTFIM
			TRB2->CT2_TPSALD	:= "0"
			If (cAlias)->CV1_VALOR < 0
				TRB2->CT2_VALOR		:= Abs((cAlias)->CV1_VALOR)		
			Else
				TRB2->CT2_VALOR		:= (cAlias)->CV1_VALOR
		
		
			EndIf
			
			If aFatorEntd[1,1] //lCT1 
				If TMPORC->CT1_NORMAL = "1" //Verifica a natureza da conta.
					TRB2->CT2_DC		:= If( (cAlias)->CV1_VALOR < 0, "2", TMPORC->CT1_NORMAL)		
				Else
					TRB2->CT2_DC		:= If( (cAlias)->CV1_VALOR < 0, "1", TMPORC->CT1_NORMAL)		
				Endif
			Else  //Se nao tiver conta no orcamento, considerar como devedor
				TRB2->CT2_DC		:= If( (cAlias)->CV1_VALOR < 0, "1", TMPORC->CT1_NORMAL)		
			EndIf
			
			If TRB2->CT2_DC == "1" //Verifica a natureza da conta
				TRB2->CT2_DEBITO	:= TMPORC->CT1_CONTA
				TRB2->CT2_CCD		:= TMPORC->CTT_CUSTO
				TRB2->CT2_ITEMD		:= TMPORC->CTD_ITEM
				TRB2->CT2_CLVLDB	:= TMPORC->CTH_CLVL
				If (_lCpoEnt05,TRB2->CT2_EC05DB	:= TMPORC->CODENT05,Nil)
				If (_lCpoEnt06,TRB2->CT2_EC06DB	:= TMPORC->CODENT06,Nil)
				If (_lCpoEnt07,TRB2->CT2_EC07DB	:= TMPORC->CODENT07,Nil)
				If (_lCpoEnt08,TRB2->CT2_EC08DB	:= TMPORC->CODENT08,Nil)
				If (_lCpoEnt09,TRB2->CT2_EC09DB	:= TMPORC->CODENT09,Nil)
			Else
				TRB2->CT2_CREDIT	:= TMPORC->CT1_CONTA
				TRB2->CT2_CCC		:= TMPORC->CTT_CUSTO
				TRB2->CT2_ITEMC		:= TMPORC->CTD_ITEM
				TRB2->CT2_CLVLCR	:= TMPORC->CTH_CLVL
				If (_lCpoEnt05,TRB2->CT2_EC05CR	:= TMPORC->CODENT05,Nil)
				If (_lCpoEnt06,TRB2->CT2_EC06CR	:= TMPORC->CODENT06,Nil)
				If (_lCpoEnt07,TRB2->CT2_EC07CR	:= TMPORC->CODENT07,Nil)
				If (_lCpoEnt08,TRB2->CT2_EC08CR	:= TMPORC->CODENT08,Nil)
				If (_lCpoEnt09,TRB2->CT2_EC09CR	:= TMPORC->CODENT09,Nil)
			EndIf
			MsUnlock()

			Ctb_Orct_Cubes( cIdEntid, "TRB2"/*cAliasMov*/, cOper/*cOperacao*/, aFatorAux[nX] )
			
			TMPORC->( dbSkip() )

		EndDo
		
		dbSelectArea("TMPORC")
		dbCloseArea()

	Next

EndIf		
	
If Select("TRB2") > 0
	DbSelectArea("TRB2")
	TRB2->(DbCloseArea())
Endif	

If _oCTBA3902 <> Nil
	_oCTBA3902:Delete()
	_oCTBA3902 := Nil
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbFatFin ºAutor  ³Microsiga           º Data ³  06/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula o fator                                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbFatFin(aFatorEntd, lFtrAtual)
Local aFatorAux	:= Array(9) // 9-[x]Fator da Entidade Contabil
Local nFatorCV1 := 1
Local nX, nY	
Local aFator := {}

Default lFtrAtual := .T.

If nQtdEntid == Nil
	nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor 
EndIf

For nX := 1 To nQtdEntid-1
	If lFtrAtual
		aAdd(aFator, aFatorEntd[nX+1,2] ) 
	Else
		aAdd(aFator, aFatorEntd[nX+1,3] )
	EndIf
Next
aAdd(aFator, 1)
	
For nX := 1 To nQtdEntid //Laco baseado na quantidade de entidades configuradas no sistema 
	nFatorCV1 := 1
	If aFatorEntd[nX,1] //lCT1/lCTT/lCTD/lCTH/lEnt05/lEnt06/lEnt07/lEnt08/lEnt09 
		For nY := nX To Len(aFator)
			nFatorCV1 *= aFator[nY] 
		Next
		aFatorAux[nX] := nFatorCV1
	Else
		aFatorAux[nX] := 1 //Valor Default
	EndIf
Next

Return(aFatorAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb_Orct_Cubes ºAutor  ³Microsiga      º Data ³  10/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua o gravamento nas tabelas CVX/CVY                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb_Orct_Cubes(cCodeCube, cAliasMov,cOperacao,nFatorAux)

Local oCubo, oLstCT0, oLstReg, oLstStruct
Local cQuery := ""

Default nFatorAux := 1

cQuery += " SELECT R_E_C_N_O_ NUM_RECNO FROM "+RetSqlName("CT0")
cQuery += " WHERE "
cQuery += " CT0_FILIAL = '"+xFilial("CT0")+"' "
cQuery += " AND CT0_ID = '"+cCodeCube+"' "
cQuery += " AND D_E_L_E_T_ = ' ' " //OBRIGATORIO PARA NAO MOSTRAR OS DELETADOS
cQuery += " ORDER BY CT0_ID " 

oLstCT0 := Adm_List_Records():New()
oLstCT0:SetAlias("CT0")  //alias
oLstCT0:SetOrder(1)      //ordem do indice        
oLstCT0:SetQuery_Expression( cQuery )
oLstCT0:Fill_Records()   //preenche os registros

//Loop no arquivo CT0
If oLstCT0:CountRecords() == 1
	If nFatorAux <> 0 
   		//posiciona no registro
	    oLstCT0:SetPosition(1)
	    oLstCT0:SetRecord()
	
	    If CT0->CT0_CONTR == "1"   //somente para os que controlam saldo
	
			//cria uma lista com registro corrente
	        oLstReg := CtbLstReg()
	
	        //instancia o cubo
			oCubo := CtbManagerial_Cubes():New()  
	
	        //seta dados gerais no objeto cubo
			oCubo:Set_DataGeneral(oLstReg)
	
			//estrutura do cubo
			oLstStruct := CtbCubeStruct(oCubo:GetCode_Cube())
			oCubo:Set_Struct(oLstStruct)
	
			//monta as expressoes em advpl para os valores a debito e credito		
			oCubo:Set_ExpKeyBuild("P")  
	                                             
			//seta alias de movimento
			oCubo:Set_Alias_Movement( cAliasMov ) 
	
			//seta moeda
			oCubo:Set_Currency( (cAliasMov)->CT2_MOEDLC )  
	
			//seta tipo de saldo
			oCubo:Set_Type_Of_Balance( (cAliasMov)->CT2_TPSALD )
	
			//seta data da contabilizacao
			oCubo:Set_Ctb_Date( (cAliasMov)->CT2_DATA )
	
			If (cAliasMov)->CT2_DC == "1"   //Debito
	
	        	oCubo:Set_Movement_Type("D")
	
				//macro executa as expressoes de acordo a estrutura do cubo
	            oCubo:Set_BuildKey()  
	
				oCubo:Set_Write_Balance("D",cOperacao,(cAliasMov)->CT2_VALOR*nFatorAux)
	
			ElseIf  (cAliasMov)->CT2_DC == "2"  //Credito
	
				oCubo:Set_Movement_Type("C")
	
				//macro executa as expressoes de acordo a estrutura do cubo
				oCubo:Set_BuildKey()
	
	            oCubo:Set_Write_Balance("C",cOperacao,(cAliasMov)->CT2_VALOR*nFatorAux)
	
			EndIf     
	
		EndIf     
   
	EndIf
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbQryEntd ºAutor  ³Microsiga          º Data ³  11/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbQryEntd(aFatorEntd, cIdEntid, cAliasOrc)

Local oCubo, oLstReg
Local nY
Local cCampos := ""
Local cTabela := ""
Local cWhere  := ""
Local cQuery  := ""
Local cAliasAux
Local cAliasInt    			
Local cCpoAux 
Local cEntIni
Local cEntFim
Local cIdEntAux
Local aCpoAux := {"CT1_CONTA","CTT_CUSTO","CTD_ITEM","CTH_CLVL"}
                                                             
dbSelectArea("CT0") //alias
dbSetOrder(1)       //ordem do indice        

If dbSeek(xFilial("CT0")+cIdEntid)

	//cria uma lista com registro corrente
    oLstReg := CtbLstReg()

    //seta dados gerais no objeto cubo
	oCubo := Ctb_Exec_Cube():New(cIdEntid/*cCodeCube*/, "01"/*cCurrency*/, "0"/*cTypeBalance*/, 1/*nLevel*/, 1/*nQtValue*/)  
	
	For nY := 1 TO oCubo:oStructCube:nMaxNiveis
	
        cAliasAux := oCubo:oStructCube:aAlias[nY]
        cCpoAux := oCubo:oStructCube:aChave[nY]
        cIdEntAux := StrZero(nY, 2)
		cPrefix   := PrefixoCpo(cAliasAux)
		CtbRngOrc(cIdEntAux, cAliasAux, cAliasOrc, @cEntIni, @cEntFim)

		If cAliasAux=="CT1" .And. ! aFatorEntd[nY,1] 
	    	cCampos += " '1' CT1_NORMAL, "
    	EndIf
        
		If aFatorEntd[nY,1]
    		
    		If cAliasAux == "CV0"
    			cAliasInt := cAliasAux+StrZero(nY,2)
		    	cCampos += cAliasInt+"."+cCpoAux+" CODENT"+StrZero(nY,2)+", "
	    		cTabela += RetSqlName(cAliasAux)+" "+cAliasInt+ ", "
	    		cWhere += " AND "+cAliasInt+"."+cPrefix+"_FILIAL = '"+xFilial(cAliasAux)+"' "
    			cWhere += " AND "+cAliasInt+"."+"CV0_PLANO = '"+oCubo:oStructCube:aPlano[nY]+"' "
    			cWhere += " AND "+cAliasInt+"."+"CV0_CLASSE = '2' "
	    		cWhere += " AND "+cAliasInt+"."+cCpoAux+" BETWEEN '"+cEntIni+"' AND '"+cEntFim+"' "
    			cWhere += " AND "+cAliasInt+".D_E_L_E_T_ = ' ' "
    		Else
		    	If cAliasAux $ "CT1|CTT|CTD|CTH"
		    		cCampos += cCpoAux+ ", "
		    	Else
		    		cCampos += cCpoAux+" CODENT"+StrZero(nY,2)+", "
		    	EndIf	
	  			cCampos += If(cAliasAux=="CT1", " CT1_NORMAL , ", "")
	    		cTabela += RetSqlName(cAliasAux)+" "+cAliasAux+ ", "
        		cWhere += " AND "+cPrefix+"_FILIAL = '"+xFilial(cAliasAux)+"' "
	    		cWhere += " AND "+cPrefix+"_CLASSE = '2' "
				cWhere += " AND "+cCpoAux+" BETWEEN '"+cEntIni+"' AND '"+cEntFim+"' "
    			cWhere += " AND "+cAliasAux+".D_E_L_E_T_ = ' ' "
    		EndIf
		Else

			If nY > 4
			   	cCampos += "' ' CODENT"+StrZero(nY,2)+", "
			Else
				cCpoAux := aCpoAux[nY]
			   	cCampos += "' ' "+cCpoAux+", "
			EndIf
			
		EndIf
		
	Next

	For nY := oCubo:oStructCube:nMaxNiveis+1 TO nQtdEntid
		If nY > 4
		   	cCampos += "' ' CODENT"+StrZero(nY,2)+", "
		Else
			cCpoAux := aCpoAux[nY]
		   	cCampos += "' ' "+cCpoAux+", "
		EndIf	   	
	Next		
	
	cQuery := " SELECT "
	cQuery += Substr(cCampos, 1, Len(cCampos)-2)  //tirando a virgula do fim
	cQuery += " FROM "
	cQuery += Substr(cTabela, 1, Len(cTabela)-2)  //tirando a virgula do fim
	cQuery += " WHERE "
	cQuery += Substr(cWhere, 6)

EndIf

Return(cQuery)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbRngOrc ºAutor  ³Microsiga           º Data ³  11/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Preenche variaveis passadas por referencia com a entidade   º±±
±±º          ³inicial e final informadas no orcamento                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbRngOrc(cIdEntAux, cAliasAux, cAliasOrc, cEntIni, cEntFim)

If cAliasAux=="CT1"
	cEntIni := (cAliasOrc)->CV1_CT1INI
	cEntFim := (cAliasOrc)->CV1_CT1FIM
ElseIf cAliasAux=="CTT"
	cEntIni := (cAliasOrc)->CV1_CTTINI
	cEntFim := (cAliasOrc)->CV1_CTTFIM
ElseIf cAliasAux=="CTD"
	cEntIni := (cAliasOrc)->CV1_CTDINI
	cEntFim := (cAliasOrc)->CV1_CTDFIM
ElseIf cAliasAux=="CTH"
	cEntIni := (cAliasOrc)->CV1_CTHINI
	cEntFim := (cAliasOrc)->CV1_CTHFIM
Else
	cEntIni := (cAliasOrc)->&("CV1_E"+cIdEntAux+"INI")
	cEntFim := (cAliasOrc)->&("CV1_E"+cIdEntAux+"FIM")
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb_Cria_Temp ºAutor  ³Microsiga       º Data ³  06/14/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb_Cria_Temp(cNomeArqEnt,cArqInd1,cArqInd2)    
Local aCampos := {}
Local cCpoDebito
Local cCpoCredito
Local cCpoChDeb
Local cCpoChCre
Local nX
Local aCpoChDeb := {}
Local aCpoChCre := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Arquivo temporario para preenchimento das tabela CVX/CVY (todas entidades inclusive as novas)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
AADD(aCampos,{"CT2_MOEDLC"	, "C" , TamSx3('CT2_MOEDLC')[1] , 0							}) 
AADD(aCampos,{"CT2_DATA" 	, "D" , 8                       , 0							})
AADD(aCampos,{"CT2_TPSALD"	, "C" , TamSx3('CT2_TPSALD')[1] , 0							})  
AADD(aCampos,{"CT2_DC"		, "C" , TamSx3('CT2_DC')[1]     , 0							})  
AADD(aCampos,{"CT2_VALOR"	, "N" , TamSx3('CT2_VALOR')[1]  , TamSx3('CT2_VALOR')[2]	}) 
AADD(aCampos,{"CT2_DEBITO"	, "C" , TamSx3('CT2_DEBITO')[1] , TamSx3('CT2_DEBITO')[2]	})	  
AADD(aCampos,{"CT2_CREDIT"	, "C" , TamSx3('CT2_CREDIT')[1] , TamSx3('CT2_CREDIT')[2]	})  
AADD(aCampos,{"CT2_CCD"		, "C" , TamSx3('CT2_CCD')[1]    , TamSx3('CT2_CCD')[2]		})  
AADD(aCampos,{"CT2_CCC"		, "C" , TamSx3('CT2_CCC')[1]    , TamSx3('CT2_CCC')[2]		})  
AADD(aCampos,{"CT2_ITEMD"	, "C" , TamSx3('CT2_ITEMD')[1]  , TamSx3('CT2_ITEMD')[2]	}) 
AADD(aCampos,{"CT2_ITEMC"	, "C" , TamSx3('CT2_ITEMC')[1]  , TamSx3('CT2_ITEMC')[2]	}) 
AADD(aCampos,{"CT2_CLVLDB"	, "C" , TamSx3('CT2_CLVLDB')[1] , TamSx3('CT2_CLVLDB')[2]	}) 
AADD(aCampos,{"CT2_CLVLCR"	, "C" , TamSx3('CT2_CLVLCR')[1] , TamSx3('CT2_CLVLCR')[2]	}) 


//Arrays para montagem dos indices na TRB2
aCpoChDeb   := {"CT2_MOEDLC","CT2_DATA","CT2_TPSALD","CT2_DC","CT2_DEBITO","CT2_CCD","CT2_ITEMD","CT2_CLVLDB"}
aCpoChCre   := {"CT2_MOEDLC","CT2_DATA","CT2_TPSALD","CT2_DC","CT2_CREDIT","CT2_CCC","CT2_ITEMC","CT2_CLVLCR"}

For nX := 5 To nQtdEntid 
	cCpoDebito	:= "CT2_EC"+StrZero(nX,2)+"DB"
	cCpoCredito	:= "CT2_EC"+StrZero(nX,2)+"CR"
	AADD(aCampos,{cCpoDebito ,"C",TamSx3(cCpoDebito)[1],0})  
	AADD(aCampos,{cCpoCredito,"C",TamSx3(cCpoCredito)[1],0}) 	
	AADD(aCpoChDeb,cCpoDebito) 
	AADD(aCpoChCre,cCpoCredito) 	
Next nX

If _oCTBA3902 <> Nil
	_oCTBA3902:Delete()
	_oCTBA3902 := Nil
Endif

_oCTBA3902 := FWTemporaryTable():New( "TRB2" )  
_oCTBA3902:SetFields(aCampos) 
_oCTBA3902:AddIndex("1", aCpoChDeb) //³Indice Debito³
_oCTBA3902:AddIndex("2", aCpoChCre) //³Indice Credito³

//------------------
//Criação da tabela temporaria
//------------------
_oCTBA3902:Create() 

dbSelectArea("TRB2")    
dbSetOrder(1)

Return

//Carrega as variaveis estaticas
Function LoadVar390()

If cTmSequen == NIL
	cTmSequen := PadL(GetNewPar( "MV_CV1SEQ" , '9999' ),TamSx3("CV1_SEQUEN")[1],"0") // tamanho do campo do cv1_sequen
Endif

//Pontos de Entrada
Static l390SLCDX := ExistBlock("CT390SLCDX")
Static l390SLSQL := ExistBlock("CT390SLSQL")
Static l390Grv 	 := ExistBlock("CTB390GRV")
Static lFWCodFil := FindFunction("FWCodFil")

Return
