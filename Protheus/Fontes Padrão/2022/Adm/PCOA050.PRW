#INCLUDE "PCOA050.ch"
#INCLUDE "PROTHEUS.CH"

#define X_ROTINA	Upper( AllTrim( FunName() ) )
                                   
Static aCamposCubo	   
Static nQtdEntid 
Static _TamCT0Id  := NIL 

Static _aSx3Obgt  := NIL
Static _cEmpProc  := NIL                                                                           

Static _nPosID_	  := NIL
Static _nPosCta	  := NIL
Static _nPosCc	  := NIL 
Static _nPosItctb := NIL
Static _nPosClVlr := NIL
Static _nPosUnOrc := NIL
Static _cGrFilPro := NIL
Static _aDataBlq  := NIL
Static  _oHash    := NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOA050  ³ AUTOR ³ Guilherme C. Leal     ³ DATA ³ 26.11.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa para manutencao lancamentos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOA050                                                      ³±±
±±³_DESCRI_  ³ Programa para manutencao de lancamentos.                     ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada com a sua chamada normal    ³±±
±±³          ³ partir do Menu ou a partir de uma funcao pulando assim o     ³±±
±±³          ³ browse principal e executando a chamada direta da rotina     ³±±
±±³          ³ selecionada.                                                 ³±±
±±³          ³ Exemplo: PCOA050(2) - Executa a chamada da funcao de visua-  ³±±
±±³          ³                        zacao da rotina.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpN1 : Chamada direta sem passar pela mBrowse               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA050(nCallOpcx,lAuto,aCposVs,aRecnos,lProc, lLockBlq, lAtuSld)
Local lRet      := .T.
Local xOldInt
Local lOldAuto
Local lPcoA0506 := ExistBlock( "PCOA0506" )
Local cFilBrw	:= nil          

Private aCposVisual	:= aCposVs
Private cCadastro	:= STR0001 //"Manutençaão de Lançamentos"
Private aRotina 	:= MenuDef()

Default lAuto := .F.
Default lProc := .F.
Default lLockBlq := .F.
Default lAtuSld	:= .T.
If !lAtuSld .And. ( Alltrim(Upper(FunName())) $'PCOAREVPRC|PCORVFIN1|PCORVFIN2' )  //REVISAO DE PLANILHA POR PROCEDURES
	Return(.T.)//Qdo chamado de revisao da planilha nao atualiza saldo e status ja esta 1 entao retorna .T.
EndIf

lLockBlq := A050ChkBlq(lLockBlq)

If lAuto
	If Type('__cInternet') != 'U'
		xOldInt := __cInternet
	EndIf
	If Type('lMsHelpAuto') != 'U'
		lOldAuto := lMsHelpAuto
	EndIf
	lMsHelpAuto := .T.
	If !lProc
		__cInternet := 'AUTOMATICO'
	Endif	
EndIf
          
If  !lAuto .And. X_ROTINA == "PCOA050"
	Set Key VK_F12 To A050Perg()
   Pergunte("PCO050",.F.)
EndIf

dbSelectArea("AKD")
dbSetOrder(1)
If nCallOpcx <> Nil
	lRet := A050DLG("AKD",AKD->(RecNo()),nCallOpcx,lAuto,aRecnos,lProc,lLockBlq,,lAtuSld)
Else

	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para Filtrar o Browse      ³
	//P_E³ browse da tela de lançamentos                         ³
	//P_E³ Parametros : Nenhum                                   ³
	//P_E³ Retorno    : String com Filtro a ser executado.       ³
	//P_E³              Ex. :  User Function PCOA0506            ³
	//P_E³                     Return ( "AKD_PROCES<>'000051'" ) ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPcoA0506 
		cFilBrw := ExecBlock("PCOA0506",.F.,.F.)
	EndIf

	mBrowse(6,1,22,75,"AKD",,,,,,PCOA050Leg(),,,,,,,, cFilBrw )

EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A050DLG   ºAutor  ³Guilherme C. Leal   º Data ³  11/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- º±±
±±º          ³ zacao                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A050DLG(cAlias,nRecnoAKD,nCallOpcx,lAuto,aRecnos,lProc,lLockBlq,lEditLin,lAtuSld)
Local oDlg
Local lCancel  := .F.
Local aButtons	:= {{"UPDWARNING",{|| A050View(oGdAKD:aHeader,oGdAKD:aCols,oGdAKD:oBrowse:nAt ) },STR0013,STR0014}}//"Rastrear Origem do Lancamento"###"Origem"
Local aUsButtons := {}
Local oEnchAKD

Local aHeadAKD
Local aColsAKD
Local nLenAKD   := 0 // Numero de campos em uso no AKD
Local nLinAKD   := 0 // Linha atual do acols
Local aRecAKD   := {} // Recnos dos registros
Local nGetD
Local cLote
Local aCposEnch
Local aUsField
Local aAreaAKD := AKD->(GetArea()) // Salva Area do AKD
Local aEnchAuto  // Array com as informacoes dos campos da enchoice qdo for automatico
Local xOldInt
Local lOldAuto
Local nPosIDRef
Local nPosVal
Local nPosVal2
Local nPosVal3
Local nPosVal4
Local nPosVal5
Local nPosIdent
Local nPosUM
Local lOk := .F.
Local nX 
Local aId_AKD, nPos_Id, nRegAux
Local lPcoA0506 := ExistBlock( "PCOA0506" )
Local nLoop := 0 
Local cQuery	:= ""
Local cQry506	:= ""
Local cAliasAkd
Local oSize
Local oPanelAll
Local aTam := {}
Local cUltLote
Local cQryAKD := ''
Local cAliasQry := ''
Local cNomeCpo := ""
Local cContexto := ""

If ValType(lAuto) != "L" 
	lAuto := .F.
EndIf

Private INCLUI  := (nCallOpcx = 3)
Private oGdAKD
PRIVATE aTELA[0][0],aGETS[0]

Default lEditLin := .F.
Default lAtuSld	:= .T.

If lAuto
	If Type('__cInternet') != 'U'
		xOldInt := __cInternet
	EndIf
	If Type('lMsHelpAuto') != 'U'
		lOldAuto := lMsHelpAuto
	EndIf
	lMsHelpAuto := .T.
	If !lProc
		__cInternet := 'AUTOMATICO'
	Endif	
ElseIf GetNewPar("MV_PCOVISL","1") == "1" .And. !lEditLin
	aRecnos	:=	Nil
EndIf

If  !lAuto .And. X_ROTINA == "PCOA050"
	Pergunte("PCO050",.F.)
Endif

// Se nao for rotina automatica e for chamada alteracao do lancamento pelo menu
If  !lAuto .And. X_ROTINA == "PCOA050"
	// Se for selecionada alteracao por linha chama novamente a edicao do lancamento para a linha do lote posicionada na mBrowse.
	If mv_par01 == 2 .And. nRecnoAKD > 0 .And. nCallOpcx == 4 .And. !lEditLin
		DbSelectArea(cAlias)
		DbGoto(nRecnoAKD)
		If EOF() .Or. BOF()
			HELP("  ",1,"PCOREGINV",,AllTrim(Str(nRecnoAKD)),1,0)
			Return .F.
		EndIf
		If nCallOpcx == 4 .And. AKD->AKD_STATUS == "2"
			HELP("  ",1,"PCOREGINV",,STR0027+AllTrim(AKD->AKD_LOTE+"/"+AKD->AKD_ID),1,0)  //"Movimento com lote invalido não pode ser alterado por linha. Lote/Linha: "
			Return .F.
		EndIf
		Return A050DLG( "AKD", nRecnoAKD, 4, .F., { nRecnoAKD }, , , .T. ) 
	EndIf	
EndIf

If lAuto .And. !(nCallOpcx = 4 .Or. nCallOpcx = 6)
	Return .F.
EndIf

If nCallOpcx != 3 .And. ValType(nRecnoAKD) == "N" .And. nRecnoAKD > 0
	DbSelectArea(cAlias)
	DbGoto(nRecnoAKD)
	If EOF() .Or. BOF()
		HELP("  ",1,"PCOREGINV",,AllTrim(Str(nRecnoAKD)),1,0)
		Return .F.
	EndIf
	aAreaAKD := AKD->(GetArea()) // Salva Area do AKD por causa do Recno e do Indice
EndIf

If nCallOpcx == 6 .And. AKD->AKD_STATUS == "3"
	HELP("  ",1,"PCOESTOR",,STR0024,1,0) // "Este lançamento já foi estornado e não poderá ser estornado novamente"
	Return .F.
EndIf

If nCallOpcx == 4 .And. AKD->AKD_STATUS == "3"
	HELP("  ",1,"PCOALTER",,STR0025,1,0) // "Este lançamento já foi estornado e não poderá ser alterado."
	Return .F.
EndIf

If nCallOpcx == 4
	If aRecnos != NIL .And. ! Empty(aRecnos)
		nRegAux := AKD->(Recno())
		aId_AKD := {}
		For nX := 1 TO Len(aRecnos)
			dbSelectArea("AKD")
			dbGoto(aRecnos[nX])
			If (nPos_Id	:=	ASCAN(aId_AKD, {|x| x[1] == AKD->AKD_ID}))==0
				aAdd(aId_AKD, {AKD->AKD_ID,{aRecnos[nX]}})
			Else
				AAdd(aId_AKD[nPos_Id][2],aRecnos[nX])
			EndIf		
		Next
		dbGoto(nRegAux)
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PCOA0502" )
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para inclusao de botoes de usuarios         ³
	//P_E³ na tela de configuracao dos lancamentos                                ³
	//P_E³ Parametros : Nenhum                                                    ³
	//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
	//P_E³  Ex. :  User Function PCOA0502                                         ³
	//P_E³         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If ValType( aUsButtons := ExecBlock( "PCOA0502", .F., .F. ) ) == "A"
		//aButtons := {}
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

oSize := FwDefSize():New(.T.,,,)
oSize:AddObject( "CABECALHO",  100, 20, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS" ,  100, 80, .T., .T. ) // Totalmente dimensionavel 
oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
oSize:Process() 	   // Dispara os calculos 

If !lAuto
	DEFINE MSDIALOG oDlg TITLE STR0009 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL //"Manutenção de Lançamentos"
EndIf

aCposEnch := {"AKD_LOTE","AKD_STATUS","NOUSER"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para adicionar campos no cabecalho                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PCOA0503" )
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para adicionar campos no cabecalho          ³
	//P_E³ Parametros : Nenhum                                                    ³
	//P_E³ Retorno    : Array contendo as os campos a serem adicionados           ³
	//P_E³               Ex. :  User Function PCOA0503                            ³
	//P_E³                      Return {"AKD_FIELD1","AKD_FIELD2"}                ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType( aUsField := ExecBlock( "PCOA0503", .F., .F. ) ) == "A"
		AEval( aUsField, { |x| AAdd( aCposEnch, x ) } )
	EndIf
EndIf

// Carrega dados do AKD para memoria
RegToMemory("AKD",INCLUI)
cUltLote := M->AKD_LOTE 

//Verifica Ultimo lote
If  !lAuto .And. X_ROTINA == "PCOA050" .And. INCLUI
	cAliasQry := GetNextAlias()
	cQryAKD := "SELECT MAX(AKD_LOTE) LOTE "
	cQryAKD += "  FROM " + RetSqlName( 'AKD' ) + " AKD "
	cQryAKD += " WHERE AKD.AKD_FILIAL = '" + xFilial( 'AKD' ) + "'"
	cQryAKD += "   AND D_E_L_E_T_ = ' '"
	
	cQryAKD := ChangeQuery(cQryAKD)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryAKD),cAliasQry,.T.,.F.)
	
	cUltLote := Soma1((cAliasQry)->LOTE)
	M->AKD_LOTE := cUltLote

	(cAliasQry)->(dbCloseArea())

EndIf

//Reserva lote
If ! lAuto .And. INCLUI
	cUltLote := M->AKD_LOTE
	While !MayIUseCode("AKD"+xFilial('AKD')+cUltLote )
		PcoSleep()
		cUltLote := Soma1(cUltLote)
	EndDo 

	M->AKD_LOTE := cUltLote

Endif

If !lAuto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enchoice com os dados dos Lancamentos                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTam:= {oSize:GetDimension("CABECALHO","LININI") ,oSize:GetDimension("CABECALHO","COLINI"),;
			oSize:GetDimension("CABECALHO","LINEND"),oSize:GetDimension("CABECALHO","COLEND")}
	oEnchAKD := MSMGet():New('AKD',,nCallOpcx,,,,aCposEnch,aTam,,,,,,,,,,,,,,,)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader do AKD                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeadAKD := GetaHeader("AKD",,aCposEnch,@aEnchAuto,aCposVisual, .T. /*lWalk_Thru*/)
Else
	aHeadAKD := GetaHeader("AKD",,aCposEnch,@aEnchAuto,aCposVisual, .F. /*lWalk_Thru*/)
EndIf

nLenAKD  := Len(aHeadAKD) + 1

nPosVal   	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL1"})
nPosVal2  	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL2"})
nPosVal3  	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL3"})
nPosVal4  	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL4"})
nPosVal5  	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL5"})
nPosIDRef 	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_IDREF"})
nPosIdent 	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_IDENT"})
nPosUM    	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_UM"})

nPos_ALI_WT := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_ALI_WT"})
nPos_REC_WT := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_REC_WT"})

If nPosIDRef > 0
	aHeadAKD[nPosIDRef][4] := 0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols do AKD                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aColsAKD := {}
If nCallOpcx != 3 

	If aRecnos == NIL
	
		If lPcoA0506
          
			cQueryAKD	:= "SELECT R_E_C_N_O_ AS RECNO FROM "  + RetSqlName( "AKD" ) + " WHERE D_E_L_E_T_='' AND AKD_FILIAL='" + xFilial("AKD") + "' AND AKD_LOTE='" + AKD->AKD_LOTE + "' "
			
			cQry506		+= ExecBlock("PCOA0506",.F.,.F.)
			
			If !Empty(cQry506)
				cQueryAKD	+= " AND " + PcoParseFil(cQry506, "AKD")
			EndIf		

			cAliasAkd := "TMPAKD"
			cLote := AKD->AKD_FILIAL + AKD->AKD_LOTE

			cQueryAKD := ChangeQuery( cQueryAKD )
			
			dbUseArea( .t., "TOPCONN", Tcgenqry( , , cQueryAKD ), cAliasAkd , .F., .T. )
		
		Else
		
			DbSelectArea("AKD")
			DbSetOrder(1)
			DbSeek(xFilial()+AKD->AKD_LOTE)
			cAliasAkd := "AKD"
			cLote := AKD->AKD_FILIAL + AKD->AKD_LOTE
			
		EndIf
		
		While (cAliasAkd)->(!Eof()) .And. (cAliasAkd)->(AKD_FILIAL + AKD_LOTE)  == cLote
			
			If lPcoA0506
				DbSelectArea("AKD")
				DbGoto((cAliasAkd)->(RECNO))
			Endif
			
			If (nCallOpcx != 2 .And. nCallOpcx != 5 .And. AKD->AKD_STATUS == "3")
				(cAliasAkd)->(dbSkip())
				Loop	
			EndIf
			
			AAdd(aColsAKD,Array( nLenAKD ))
			nLinAKD++
			// Varre o aHeader para preencher o acols
			For nX := 1 TO ( nLenAKD - 1 )
				cNomeCpo := Upper(AllTrim(aHeadAKD[nX][2]))
				cContexto := aHeadAKD[nX][10]			
				If ! ( cNomeCpo$"AKD_ALI_WT|AKD_REC_WT" )
					If cContexto == "V"  //se for campo virtual 
						aColsAKD[nLinAKD][nX] := CriaVar(cNomeCpo)
					Else
						aColsAKD[nLinAKD][nX] := AKD->( FieldGet(FieldPos(cNomeCpo)) ) 
					EndIf
				EndIf
			Next //nX

			If nPosVal > 0
				aColsAKD[nLinAKD][nPosVal] := PCOPlanCel(AKD->AKD_VALOR1,AKD->AKD_CLASSE)
			EndIf
		
			If nPosVal2 > 0
				aColsAKD[nLinAKD][nPosVal2] := PCOPlanCel(AKD->AKD_VALOR2,AKD->AKD_CLASSE)
			EndIf
			
			If nPosVal3 > 0
				aColsAKD[nLinAKD][nPosVal3] := PCOPlanCel(AKD->AKD_VALOR3,AKD->AKD_CLASSE)
			EndIf
		
			If nPosVal4 > 0
				aColsAKD[nLinAKD][nPosVal4] := PCOPlanCel(AKD->AKD_VALOR4,AKD->AKD_CLASSE)
			EndIf
		
			If nPosVal5 > 0
				aColsAKD[nLinAKD][nPosVal5] := PCOPlanCel(AKD->AKD_VALOR5,AKD->AKD_CLASSE)
			EndIf
			
			If nPosIdent > 0 .And. !Empty(AKD->AKD_IDREF)
				aAuxArea := GetArea()
				AK6->(dbSetOrder(1))
				AK6->(MsSeek(xFilial()+AKD->AKD_CLASSE))
				If !Empty(AK6->AK6_VISUAL)
					dbSelectArea(Substr(AKD->AKD_IDREF,1,3))
					dbSetOrder(Val(Substr(AKD->AKD_IDREF,4,2)))
					MsSeek(Substr(AKD->AKD_IDREF,6,Len(AKD->AKD_IDREF)))
					aColsAKD[nLinAKD][nPosIdent] := &(AK6->AK6_VISUAL)
				EndIf
				RestArea(aAuxArea)
			EndIf
			If nPosUM > 0
				AK6->(dbSetOrder(1))
				AK6->(MsSeek(xFilial()+AKD->AKD_CLASSE))
				aAuxArea := GetArea()
				If !Empty(AK6->AK6_UM)
					If !Empty(AKD->AKD_IDREF)
						dbSelectArea(Substr(AKD->AKD_IDREF,1,3))
						dbSetOrder(Val(Substr(AKD->AKD_IDREF,4,2)))
						MsSeek(Substr(AKD->AKD_IDREF,6,Len(AKD->AKD_IDREF)))
					EndIf
					aColsAKD[nLinAKD][nPosUM] := &(AK6->AK6_UM)
				EndIf
				RestArea(aAuxArea)
			EndIf
			
			If nPos_ALI_WT > 0
				aColsAKD[nLinAKD][nPos_ALI_WT] := "AKD"
			EndIf
	
			If nPos_REC_WT > 0
				aColsAKD[nLinAKD][nPos_REC_WT] := AKD->(Recno())
			EndIf
		
			// Deleted
			aColsAKD[nLinAKD][nLenAKD] := .F.
			// Adiciona o Recno no aRec
			AAdd( aRecAKD, AKD->( Recno() ) )
			
			(cAliasAkd)->(DbSkip())
			
		EndDo
		
		If lPcoA0506
			DbSelectArea(cAliasAkd)
			DbCloseArea()
			DbSelectArea(cAlias)
		EndIf
	
	Else
	
		For nLoop := 1 to Len( aRecnos ) 	
		
			AKD->( dbGoto( aRecnos[ nLoop ] ) )
			
			If (nCallOpcx == 2 .Or. nCallOpcx == 5 .Or. AKD->AKD_STATUS <> "3")
	
				AAdd(aColsAKD,Array( nLenAKD ))
				nLinAKD++
				// Varre o aHeader para preencher o acols
				For nX := 1 TO ( nLenAKD - 1 )
					cNomeCpo := Upper(AllTrim(aHeadAKD[nX][2]))
					cContexto := aHeadAKD[nX][10]			
					If ! ( cNomeCpo$"AKD_ALI_WT|AKD_REC_WT" )
						If cContexto == "V"  //se for campo virtual 
							aColsAKD[nLinAKD][nX] := CriaVar(cNomeCpo)
						Else
							aColsAKD[nLinAKD][nX] := AKD->( FieldGet(FieldPos(cNomeCpo)) ) 
						EndIf
					EndIf
				Next //nX

				If nPosVal > 0
					aColsAKD[nLinAKD][nPosVal] := PCOPlanCel(AKD->AKD_VALOR1,AKD->AKD_CLASSE)
				EndIf
			
				If nPosVal2 > 0
					aColsAKD[nLinAKD][nPosVal2] := PCOPlanCel(AKD->AKD_VALOR2,AKD->AKD_CLASSE)
				EndIf
				
				If nPosVal3 > 0
					aColsAKD[nLinAKD][nPosVal3] := PCOPlanCel(AKD->AKD_VALOR3,AKD->AKD_CLASSE)
				EndIf
			
				If nPosVal4 > 0
					aColsAKD[nLinAKD][nPosVal4] := PCOPlanCel(AKD->AKD_VALOR4,AKD->AKD_CLASSE)
				EndIf
			
				If nPosVal5 > 0
					aColsAKD[nLinAKD][nPosVal5] := PCOPlanCel(AKD->AKD_VALOR5,AKD->AKD_CLASSE)
				EndIf
				
				If nPosIdent > 0 .And. !Empty(AKD->AKD_IDREF)
					aAuxArea := GetArea()
					AK6->(dbSetOrder(1))
					AK6->(MsSeek(xFilial()+AKD->AKD_CLASSE))
					If !Empty(AK6->AK6_VISUAL)
						dbSelectArea(Substr(AKD->AKD_IDREF,1,3))
						dbSetOrder(Val(Substr(AKD->AKD_IDREF,4,2)))
						MsSeek(Substr(AKD->AKD_IDREF,6,Len(AKD->AKD_IDREF)))
						aColsAKD[nLinAKD][nPosIdent] := &(AK6->AK6_VISUAL)
					EndIf
					RestArea(aAuxArea)
				EndIf
				If nPosUM > 0
					AK6->(dbSetOrder(1))
					AK6->(MsSeek(xFilial()+AKD->AKD_CLASSE))
					aAuxArea := GetArea()
					If !Empty(AK6->AK6_UM)
						If !Empty(AKD->AKD_IDREF)
							dbSelectArea(Substr(AKD->AKD_IDREF,1,3))
							dbSetOrder(Val(Substr(AKD->AKD_IDREF,4,2)))
							MsSeek(Substr(AKD->AKD_IDREF,6,Len(AKD->AKD_IDREF)))
						EndIf
						aColsAKD[nLinAKD][nPosUM] := &(AK6->AK6_UM)
					EndIf
					RestArea(aAuxArea)
				EndIf
			
				// Deleted
				aColsAKD[nLinAKD][nLenAKD] := .F.
				// Adiciona o Recno no aRec
				AAdd( aRecAKD, AKD->( Recno() ) )
		
			Endif		
			
		Next nLoop 

	EndIf

EndIf
		
// Verifica se não foi criada nenhuma linha para o aCols
If Len(aColsAKD) = 0
	AAdd(aColsAKD,Array( nLenAKD ))
	nLinAKD++
	// Varre o aHeader para preencher o acols
	For nX := 1 TO ( nLenAKD - 1 )
		cNomeCpo := Upper(AllTrim(aHeadAKD[nX][2]))
		If  cNomeCpo == "AKD_ID"
			aColsAKD[nLinAKD][nX] := StrZero(1,Len(AKD->AKD_ID))
		Else
			If ! ( cNomeCpo$"AKD_ALI_WT|AKD_REC_WT" )
				aColsAKD[nLinAKD][nX] := CriaVar(cNomeCpo)
			EndIf
		EndIf
	Next //nX

	If nPos_ALI_WT > 0
		aColsAKD[nLinAKD][nPos_ALI_WT] := "AKD"
	EndIf
	If nPos_REC_WT > 0
		aColsAKD[nLinAKD][nPos_REC_WT] := 0
	EndIf
	// Deleted
	aColsAKD[nLinAKD][nLenAKD] := .F.
EndIf

If !lAuto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ GetDados com os Lancamentos                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nCallOpcx = 3 .Or. nCallOpcx = 4
		nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
	Else
		nGetD := 0
	EndIf
	
	oGdAKD:= MsNewGetDados():New(oSize:GetDimension("GETDADOS","LININI") ,oSize:GetDimension("GETDADOS","COLINI"),;
						oSize:GetDimension("GETDADOS","LINEND"),oSize:GetDimension("GETDADOS","COLEND"),;
						nGetd,"AKDLinOK","AKDLinOk","+AKD_ID",,,9999,,,,,aHeadAKD,aColsAKD)
	oGdAKD:AddAction("AKD_IDENT",{||PCOIdentF3("AKD")})
	oGdAKD:AddAction("AKD_VAL1",{||PCOEditCell(oGdAKD)})
	oGdAKD:AddAction("AKD_VAL2",{||PCOEditCell(oGdAKD)})
	oGdAKD:AddAction("AKD_VAL3",{||PCOEditCell(oGdAKD)})
	oGdAKD:AddAction("AKD_VAL4",{||PCOEditCell(oGdAKD)})
	oGdAKD:AddAction("AKD_VAL5",{||PCOEditCell(oGdAKD)})
	oGdAKD:CARGO := AClone(aRecAKD)
	
	aButtons := aClone(AddToExcel(aButtons,{ 	{"ENCHOICE",,oEnchAKD:aGets,oEnchAKD:aTela},;
												{"GETDADOS",,oGdAKD:aHeader,oGdAKD:aCols} } ))

	If nCallOpcx != 3
		AKD->(RestArea(aAreaAKD)) // Retorna Area para que os dados da enchoice aparecam corretos
		oEnchAKD:Refresh()
	EndIf
	// Quando nao for MDI chama centralizada.
	If SetMDIChild()
		ACTIVATE MSDIALOG oDlg ON INIT (oGdAKD:oBrowse:Refresh(),EnchoiceBar(oDlg,;
			{|| If( oGdAKD:TudoOk(),;
			Processa({|| lOk := A050Ok(nCallOpcx,oGdAKD:Cargo,aEnchAuto,oGdAKD:aCols,oGdAKD:aHeader,.T.,lLockBlq, aId_AKD,lAtuSld)},'Gravando lancamentos...'),lOk := .F.),;
			If(lOk, oDlg:End(),NIL) },{|| lCancel := .T., oDlg:End() },,aButtons))
	Else
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oGdAKD:oBrowse:Refresh(),EnchoiceBar(oDlg, ;
			{|| If( oGdAKD:TudoOk(),;
			Processa( {|| lOk := A050Ok(nCallOpcx,oGdAKD:Cargo,aEnchAuto,oGdAKD:aCols,oGdAKD:aHeader,.T.,lLockBlq, aId_AKD,lAtuSld)},'Gravando lancamentos...'),lOk := .F.),;
			If(lOk,oDlg:End(),NIL)},{|| lCancel := .T., oDlg:End() },,aButtons) )
	EndIf
Else              
	lCancel := !A050Ok(nCallOpcx,aRecAKD,aEnchAuto,aColsAKD,aHeadAKD,lProc,lLockBlq, aId_AKD,lAtuSld)
EndIf

If __lSX8 .And. lCancel
	RollBackSX8()
EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt
aColsAKD 	:= ASIZE(aColsAKD,0)

RestArea(aAreaAKD)

If ! lAuto .And. INCLUI
	FreeUsedCode()
EndIf

Return !lCancel
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A050Ok   ºAutor  ³Guilherme C. Leal   º Data ³  11/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao do botao OK da enchoice bar, valida e faz o         º±±
±±º          ³ tratamento adequado das informacoes.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A050Ok(nCallOpcx,aRecAKD,aEnchAuto,aColsAKD,aHeadAKD,lProc,lLockBlq,aId_AKD,lAtuSld)
Local nI
Local nX
Local aValor
Local aAreaAKD	:= AKD->(GetArea())
Local nPosTp	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_TIPO"})
Local nPosVal	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL1"})
Local nPosVal2  := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL2"})
Local nPosVal3  := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL3"})
Local nPosVal4  := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL4"})
Local nPosVal5  := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL5"})
Local nPosItem  := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_ID"})
Local cUserAKD := __cUserId
Local lRegravou	:=	.F.
Local lRet := .T.
Local lPco50GRV := ExistBlock("PCO50GRV")
Local cNomeCpo := ""
Local cContexto := ""
Local nLenAKD   := Len(aHeadAKD) // Numero de campos em uso no AKD
Local nY
Local cIn := ""
Local cUpdate := ""

DEFAULT lProc	:=	.F.
If nCallOpcx = 1 .Or. nCallOpcx = 2 // Pesquisar e Visualizar
	Return .T.
EndIf

If INCLUI
	If !ExistChav('AKD',M->AKD_LOTE)
		Return .F.	
	Endif
Endif

If !A050Vld(nCallOpcx,aRecAKD,aEnchAuto,aColsAKD,aHeadAKD)
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacao ou acao programada por usuario         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PCOA0504" )
	If !ExecBlock("PCOA0504",.f.,.f.,{nCallOpcx,aEnchAuto,aColsAKD,aHeadAKD})
		Return .F.
	EndIf	
EndIf

AKD->(DbSetOrder(1))
If lProc                    
	ProcRegua(Len(aColsAKD))
Endif	          

If nCallOpcx = 3 // Inclusao

	// Grava Lancamentos
	For nI := 1 To Len(aColsAKD)
		If lProc
			If nI == 1
				IncProc(STR0021)	// 'Atualizando saldos...'
			Else
			    IncProc()
			Endif
		Endif	
		If aColsAKD[nI][Len(aColsAKD[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("AKD",.T.)
		EndIf

		// Varre o aHeader e grava com base no acols
		For nX := 1 TO nLenAKD
			cNomeCpo := Upper(AllTrim(aHeadAKD[nX][2]))
			cContexto := aHeadAKD[nX][10]			
			If cContexto != "V"  //se for campo virtual 
				AKD->( FieldPut(FieldPos(cNomeCpo), aColsAKD[nI][nX]) )
			EndIf
		Next //nX

		// Grava Campos do Cabecalho
		For nX := 1 To Len(aEnchAuto)
			FieldPut(FieldPos(aEnchAuto[nX][2]),&( "M->" + aEnchAuto[nX][2] ))
		Next nX

		// Grava campos que nao estao disponiveis na tela
		Replace AKD_FILIAL With xFilial()
		//Replace AKD_PROCES With Replicate( "0", Len(AKD_PROCES) )
		Replace AKD_ITEM   With StrZero( nCallOpcx, Len(AKD_ITEM))
		Replace AKD_CHAVE  With "AKDAKD1" + &( IndexKey() )
		Replace AKD_USER   With cUserAKD
		Replace AKD_VALOR1  With PcoPlanVal(aColsAKD[nI][nPosVal],AKD->AKD_CLASSE)
		Replace AKD_VALOR2  With PcoPlanVal(aColsAKD[nI][nPosVal2],AKD->AKD_CLASSE)
		Replace AKD_VALOR3  With PcoPlanVal(aColsAKD[nI][nPosVal3],AKD->AKD_CLASSE)
		Replace AKD_VALOR4  With PcoPlanVal(aColsAKD[nI][nPosVal4],AKD->AKD_CLASSE)		
		Replace AKD_VALOR5  With PcoPlanVal(aColsAKD[nI][nPosVal5],AKD->AKD_CLASSE)
		
		AKD->AKD_FILORI	:= cFilAnt
		
		If lLockBlq
			DbCommit()
		Else
			MsUnlock()
		EndIf	
		
		dbSelectArea("AK5")
		dbSetOrder(1)
		If !Empty(AKD->AKD_CO) .And. dbSeek(xFilial()+AKD->AKD_CO)
			RecLock("AKD",.F.)
			AKD->AKD_COSUP := AK5->AK5_COSUP
			If lLockBlq
				DbCommit()
			Else
				MsUnlock()
			EndIf	
		EndIf
		
		If lAtuSld
			PcoAtuSld(If(AKD->AKD_TIPO=="1","C","D"),"AKD",{AKD->AKD_VALOR1,AKD->AKD_VALOR2,AKD->AKD_VALOR3,AKD->AKD_VALOR4,AKD->AKD_VALOR5},AKD->AKD_DATA)
		EndIf
		
		If lLockBlq
			DbCommit()
		Else
			RecLock('AKD',.F.)
    	Endif

		Replace AKD_STATUS With "1"

		If lLockBlq
			DbCommit()
		Else
			MsUnlock()
		EndIf	

		//ponto de entrada para gravacao AKD de campos de usuarios/complemento
		If lPco50GRV
			ExecBlock("PCO50GRV",.f.,.f.,{nCallOpcx})
		EndIf

	Next nI
	
ElseIf nCallOpcx = 4 // Alteracao

	// Grava Lancamentos
	For nI := 1 To Len(aColsAKD)
		If lProc     
			If nI == 1
				IncProc(STR0021)	// 'Atualizando saldos...'
			Else
			    IncProc()
			Endif
		Endif	
		lRegravou	:=	.F.
		If nI <= Len(aRecAKD) .And. aRecAKD[nI] > 0
			AKD->(DbGoto(aRecAKD[nI]))
			If aColsAKD[nI][Len(aColsAKD[nI])] .Or. AKD->AKD_STATUS == "2" .Or. PCOMudouCubo(nI,aColsAKD,aHeadAKD)
				If AKD->AKD_STATUS == "1" .And. lAtuSld
					PcoAtuSld(If(AKD->AKD_TIPO=="1","C","D"),"AKD",{-AKD->AKD_VALOR1,-AKD->AKD_VALOR2,-AKD->AKD_VALOR3,-AKD->AKD_VALOR4,-AKD->AKD_VALOR5},AKD->AKD_DATA)
				Endif
				lRegravou	:=	.T.
			EndIf
			Reclock("AKD",.F.)
		Else
			If aColsAKD[nI][Len(aColsAKD[nI])] // Verifica se a linha esta deletada
				Loop
			Else
				Reclock("AKD",.T.)
			EndIf
			lRegravou := .T.
		EndIf
	
		If aColsAKD[nI][Len(aColsAKD[nI])] // Verifica se a linha esta deletada
			AKD->(DbDelete())
		Else
            
			If aId_AKD != NIL
	            nPos_Id	:=	ASCAN(aId_AKD, {|x| x[1] == aColsAKD[nI, nPosItem]})
	
	            If nPos_Id == 0 .And. nPosItem > 0
	            	
	            	cId_Ant := aColsAKD[nI, nPosItem]   //salva o Id atual
	            	cId_AKD := A050Id_Next_AKD()  // Gerar novo Id
	               	aAdd(aId_AKD, {cId_AKD, { 0 }})  // agregar ao array para os proximos
	               	
	               	//substituir todos os itens pelo novo codigo do item(AKD_ID)
	               	aColsAKD[nI, nPosItem] := cId_AKD  //joga no acols novo Id
	            EndIf
            EndIf
			// Melhorar logica para melhoria de performance no futuro. Edson 15/01/05
//			aValor := {AKD->AKD_VALOR1,AKD->AKD_VALOR2,AKD->AKD_VALOR3,AKD->AKD_VALOR4,AKD->AKD_VALOR5}
//			cTipo  := AKD->AKD_TIPO

			// Varre o aHeader e grava com base no acols
			For nX := 1 TO nLenAKD
				cNomeCpo := Upper(AllTrim(aHeadAKD[nX][2]))
				cContexto := aHeadAKD[nX][10]			
				If cContexto != "V"  //se for campo virtual 
					AKD->( FieldPut(FieldPos(cNomeCpo), aColsAKD[nI][nX]) )
				EndIf
			Next //nX

			// Grava Campos do Cabecalho
			For nX := 1 To Len(aEnchAuto)
				FieldPut(FieldPos(aEnchAuto[nX][2]),&( "M->" + aEnchAuto[nX][2] ))
			Next nX
	
			// Grava campos que nao estao disponiveis na tela
			Replace AKD_FILIAL With xFilial()
			Replace AKD_USER   With cUserAKD
			Replace AKD_VALOR1  With PcoPlanVal(aColsAKD[nI][nPosVal],AKD->AKD_CLASSE)
			Replace AKD_VALOR2  With PcoPlanVal(aColsAKD[nI][nPosVal2],AKD->AKD_CLASSE)
			Replace AKD_VALOR3  With PcoPlanVal(aColsAKD[nI][nPosVal3],AKD->AKD_CLASSE)
			Replace AKD_VALOR4  With PcoPlanVal(aColsAKD[nI][nPosVal4],AKD->AKD_CLASSE)
			Replace AKD_VALOR5  With PcoPlanVal(aColsAKD[nI][nPosVal5],AKD->AKD_CLASSE)
			If 	!lRegravou
				Replace AKD_STATUS With "1"
			Endif
			AKD->AKD_FILORI	:= cFilAnt

			If Empty(AKD->AKD_PROCES) .And. Empty(AKD->AKD_CHAVE)//controle para nao afetar a integracao / Nao regrava AKD_CHAVE
				Replace AKD_CHAVE  With "AKDAKD1" + &( IndexKey() )
			EndIf
			
			If lLockBlq
				DbCommit()
			Else
				MsUnlock()
			EndIf	
			
			dbSelectArea("AK5")
			dbSetOrder(1)
			If !Empty(AKD->AKD_CO) .And. dbSeek(xFilial()+AKD->AKD_CO)
				RecLock("AKD",.F.)
				AKD->AKD_COSUP := AK5->AK5_COSUP
				If lLockBlq
					DbCommit()
				Else
					MsUnlock()
				EndIf	
			EndIf
			
			dbSelecTArea("AKD")
			
			If 	lRegravou 
				If lAtuSld
					PcoAtuSld(If(AKD->AKD_TIPO=="1","C","D"),"AKD",{AKD->AKD_VALOR1,AKD->AKD_VALOR2,AKD->AKD_VALOR3,AKD->AKD_VALOR4,AKD->AKD_VALOR5},AKD->AKD_DATA)
				EndIf
				
				If ! lLockBlq
					RecLock('AKD',.F.)
		    	Endif
		
				Replace AKD_STATUS With "1"
		
				If lLockBlq
					DbCommit()
				Else
					MsUnlock()
				EndIf	
			Endif		
		EndIf

		//ponto de entrada para gravacao AKD de campos de usuarios/complemento
		If lPco50GRV
			ExecBlock("PCO50GRV",.f.,.f.,{nCallOpcx})
		EndIf

	Next nI
	aCamposCubo	:=	Nil
ElseIf nCallOpcx = 5 // Exclusao
	// Exclui Lancamentos
	For nI := 1 To Len(aColsAKD)
		If lProc
			If nI == 1
				IncProc(STR0021)	// 'Atualizando saldos...'
			Else
			    IncProc()
			Endif
		Endif	
		If nI <= Len(aRecAKD) .And. aRecAKD[nI] > 0
			AKD->(DbGoto(aRecAKD[nI]))
			If AKD->AKD_STATUS=="1" .And. lAtuSld
				PcoAtuSld(If(AKD->AKD_TIPO=="1","C","D"),"AKD",{-AKD->AKD_VALOR1,-AKD->AKD_VALOR2,-AKD->AKD_VALOR3,-AKD->AKD_VALOR4,-AKD->AKD_VALOR5},AKD->AKD_DATA)
			EndIf
			/* Reclock("AKD",.F.)
			AKD->(DbDelete())
			MsUnLock() */
		EndIf		
		
	Next nI
	
	/*Realizar a exclusão de uma vez via TcSQLExec*/
		nY := 1
		For nI := 1 To Len(aRecAKD)
			If nI <= Len(aRecAKD) .And. aRecAKD[nI] > 0
				If nY = 1000 .or. nI = Len(aRecAKD)
					cIn += Str(aRecAKD[nI])
					cUpdate := "UPDATE "+RetSQLName("AKD")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE R_E_C_N_O_ IN ("+cIn+") "
					TCCommit(1) // inicializa transação
					TcSqlExec(cUpdate)
					TCCommit(2) //comit da transação
					TCCommit(4) // finaliza transação
					conout(cUpdate)
					cIn := ""
					nY := 1
				ElseIf nY < 1000 // número máximo de recnos que podem ser processados pelo oracle no IN 
					cIn += Str(aRecAKD[nI])+","
					nY ++
				EndIF
			EndIf
		Next nI	




ElseIf nCallOpcx = 6 // Estorno
	// Grava Lancamentos
	For nI := 1 To Len(aColsAKD)
		If lProc
			If nI == 1
				IncProc(STR0021)	// 'Atualizando saldos...'
			Else
			    IncProc()
			Endif
		Endif	
		AKD->(DbGoto(aRecAKD[nI]))
		If AKD->AKD_STATUS == '1' .And. lAtuSld
			PcoAtuSld(If(AKD->AKD_TIPO=="1","C","D"),"AKD",{-AKD->AKD_VALOR1,-AKD->AKD_VALOR2,-AKD->AKD_VALOR3,-AKD->AKD_VALOR4,-AKD->AKD_VALOR5},AKD->AKD_DATA)
		EndIf

		Reclock("AKD",.F.)
		Replace AKD_STATUS With "3"
		MsUnlock()

		//ponto de entrada para gravacao AKD de campos de usuarios/complemento
		If lPco50GRV
			ExecBlock("PCO50GRV",.f.,.f.,{nCallOpcx})
		EndIf

	Next nI
EndIf


AKD->(RestArea(aAreaAKD))

If __lSX8
	ConfirmSX8()
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A050Vld  ºAutor  ³Guilherme C. Leal   º Data ³  11/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de validacao dos campos.                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A050Vld(nCallOpcx,aRecAKD,aEnchAuto,aColsAKD,aHeadAKD)
Local nI
Local nPosTipo
If !(nCallOpcx = 3 .Or. nCallOpcx = 4 .Or. nCallOpcx = 6)
	Return .T.
EndIf

If nCallOpcx = 6
	nPosTipo := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_TIPO" })
	If nPosTipo > 0
		If ( AScan(aColsAKD,{|x| x[nPosTipo] == "3" }) > 0 )
			MsgInfo(STR0010) //"Este lote já contém lançamento(s) de estorno, porisso não pode ser estornado."
			Return .F.
		EndIf
	EndIf
EndIf

If ( AScan(aEnchAuto,{|x| If(Alltrim(x[2])$"AKD_ALI_WT|AKD_REC_WT", .F., x[17] .And. Empty( &( "M->" + x[2] ) ) ) } ) > 0 )
	HELP("  ",1,"OBRIGAT")
	Return .F.
EndIf

For nI := 1 To Len(aColsAKD)
	If ! aColsAKD[nI,Len(aHeadAKD)+1] //valida somente os que nao estao deletados
		//troca da funcao generica MaCheckCols por funcao static PcoMacheckCols para melhora de performance no pcoa050
		lRet := PcoMaCheckCols(aHeadAKD,aColsAKD,nI,,.T.) .and. PCO050BLQ(aHeadAKD,aColsAKD,nI)    	
		
		If !lRet
			Return .F.
		EndIf
	EndIf	
Next nI

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoxGD1LinOK³ Autor ³ Edson Maricate      ³ Data ³ 17-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da LinOK da Getdados                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AKDLinOK()
Local lRet			:= .T.
Local nPosOper		:= aScan(aHeader,{|x|AllTrim(x[2])=="AKD_OPER"})
Local nPosClasse	:= aScan(aHeader,{|x|AllTrim(x[2])=="AKD_CLASSE"})
Local nPosIDRef		:= aScan(aHeader,{|x|AllTrim(x[2])=="AKD_IDREF"})
Local nPosField

If !aCols[n][Len(aCols[n])]
	dbSelectArea("AK6")
	dbSetOrder(1)
	dbSeek(xFilial()+aCols[n][nPosClasse])
	
	If AK6->AK6_OBRIGA=="1" .And. Empty(aCols[n][nPosIDRef])
		HELP("  ",1,"PCONOCHAVE")
		lRet	:= .F.
	EndIf
	
	If lRet .And. AK6->AK6_OPER=="1" .And. Empty(aCols[n][nPosOper])
		HELP("  ",1,"PCONOOPER")
		lRet	:= .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica os campos obrigatorios do SX3.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		lRet := PcoMaCheckCols(aHeader,aCols,n)   //trocado a funcao generica MaCheckCols por funcao static para ganho de performance
	EndIf               
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa ponto de entrada para validacoes adicionais na linha da planilha editada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If ExistBlock("PCOA0505")
			//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//P_E³ Ponto de entrada utilizado para validacao da linha de digitacao do     ³
			//P_E³ movimento                                                              ³
			//P_E³ Parametros : Nenhum                                                    ³
			//P_E³ Retorno    : .F. - Deve bloquear a linha de digitacao                  ³
			//P_E³              .T. - Liberar a linha digitada                            ³
			//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRet := ExecBlock("PCOA0505",.F.,.F.)
		EndIf
	EndIf       
EndIf
	
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PcoPlanEdt³ Autor ³ Edson Maricate        ³ Data ³23.12.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria um Get para edicao da celula da planilha de itens      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PCOEditCell(oGd)
Local aDim
Local oDlg
Local oGet1
Local oBtn
Local cMacro := ''
Local cPict	:= ''
Local nRow   := oGD:oBrowse:nAt
Local oOwner := oGD:oBrowse:oWnd
Local cClasse	:= oGD:aCols[oGD:oBrowse:nAt][aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AKD_CLASSE"})]
Local nValor	:= PcoPlanVal(oGD:aCols[oGD:oBrowse:nAt][oGD:oBrowse:nColPos],cClasse)
Local bChange := { ||  nValor := &cMacro,.T. }
Local oRect := tRect():New(0,0,0,0)            // obtem as coordenadas da celula (lugar onde
Local cVlrFinal := ""
Local nVlrFinal := 0

If Empty(cClasse)
   Return(cVlrFinal)
EndIf   

oGD:oBrowse:GetCellRect(oGD:oBrowse:nColPos,,oRect)   // a janela de edicao deve ficar)

aDim  := {oRect:nTop,oRect:nLeft,oRect:nBottom,oRect:nRight}

DEFINE MSDIALOG oDlg OF oOwner  FROM 0, 0 TO 0, 0 STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL

PcoPlanCel(0,cClasse,,@cPict)
cMacro := "M->CELL"
&cMacro:= nValor

@ 0,0 MSGET oGet1 VAR &(cMacro) SIZE 0,0 OF oDlg FONT oOwner:oFont PICTURE cPict PIXEL HASBUTTON VALID Eval(bChange)
oGet1:Move(-2,-2, (aDim[ 4 ] - aDim[ 2 ]) + 4, aDim[ 3 ] - aDim[ 1 ] + 4 )

@ 0,0 BUTTON oBtn PROMPT "ze" SIZE 0,0 OF oDlg
oBtn:bGotFocus := {|| oDlg:nLastKey := VK_RETURN, oDlg:End(0)}

oGet1:cReadVar  := cMacro

ACTIVATE MSDIALOG oDlg ON INIT oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])

If !Positivo(nValor)
	nVlrFinal := Abs(nValor)
	cVlrFinal := PcoPlanCel(nVlrFinal,cClasse)
Else
	cVlrFinal := PcoPlanCel(nValor,cClasse)
EndIf

oGD:aCols[oGD:oBrowse:nAt][oGD:oBrowse:nColPos]	:= cVlrFinal
oGD:oBrowse:nAt := nRow
SetFocus(oGD:oBrowse:hWnd)
oGD:oBrowse:Refresh()

Return(cVlrFinal)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A170Legen ³ Autor ³ Marco Aurelio         ³ Data ³26/11/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta as perguntas que definem o conteudo da mBrowse.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A170Legen                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Acaa170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PCOA050Leg(cAlias)
Local aLegenda := 	{ 	{"BR_VERDE"   , STR0011 },; //"Lançamento Aprovado"
						{"BR_VERMELHO", STR0012 },; //"Lançamento Invalido"
						{"BR_PRETO", STR0017 } }//"Lancamento Estornado"
Local aRet := {}
aRet := {}
	
If cAlias == Nil
	Aadd(aRet, { 'AKD->AKD_STATUS == "1"', aLegenda[1][1] } )
	Aadd(aRet, { 'AKD->AKD_STATUS == "2"', aLegenda[2][1] } )
	Aadd(aRet, { 'AKD->AKD_STATUS == "3"', aLegenda[3][1] } )
Else
	BrwLegenda(cCadastro,STR0008, aLegenda) //"Legenda"
Endif

Return aRet


Function A050View(aHeader,aCols,n )

Local aArea			:= GetArea()
Local aAreaAKD		:= AKD->(GetArea())
Local nPosID		:= AScan(aHeader,{|x| Upper(AllTrim(x[2])) == "AKD_ID"})
Local cChave
Local aAcho			:= {}
Local aButtons		:= {}
Local aUsButtons	:= {}
Local lPCO50BUT := ExistBlock("PCO50BUT")
Local cFilOld   := ""

If AKD->AKD_STATUS == "3"
	HELP("  ",1,"PCOA050",,STR0026,1,0) //LanÃ§amento Estornado nÃ£o Ã© permitido rastrear origem
Return
EndIf
SaveInter()

Private aTela[0][0]
Private aGets[0]
If lPCO50BUT
	If ValType( aUsButtons := ExecBlock( "PCO50BUT", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
Endif

dbSelectArea("AKD")
dbSetOrder(1)
If dbSeek(xFilial()+M->AKD_LOTE+aCols[n][nPosID])
	If !Empty(AKD->AKD_CHAVE)
		dbSelectArea("AKB")
		dbSetOrder(1)
		MsSeek(xFilial()+AKD->AKD_PROCES+AKD->AKD_ITEM)
		If !Empty(AKB->AKB_ENTIDA)
			dbSelectArea(AKB->AKB_ENTIDA)
			dbSetOrder(AKB->AKB_INDICE)
			dbSeek(Substr(AKD->AKD_CHAVE,4))
			cFilOld := cFilAnt
			cFilAnt := Substr(AKD->AKD_CHAVE,4,Len(cFilAnt))			
			If !MaMakeView( AKB->AKB_ENTIDA )
				dbSelectArea("SX2")
				dbSetOrder(1)
				dbSeek(AKB->AKB_ENTIDA)
				cCadastro := AllTrim(X2NOME())+STR0018//" - Visualizar"
				dbSelectArea("SX3")
				dbSetOrder(1)
				dbSeek(AKB->AKB_ENTIDA)
				While !Eof() .And. AKB->AKB_ENTIDA==SX3->X3_ARQUIVO
					aAdd(aAcho,SX3->X3_CAMPO)
					dbSkip()
				End
				dbSelectArea(AKB->AKB_ENTIDA)			
				IF AKB->AKB_ENTIDA == 'CV4'
					aAdd(aButtons, {"UPDWARNING",{|| P050RAT(oGdAKD:aHeader,oGdAKD:aCols,oGdAKD:oBrowse:nAt)},STR0013,STR0014}) //"Rastrear Origem do Lancamento"
				EndIF	
				axVisual(AKB->AKB_ENTIDA,(AKB->AKB_ENTIDA)->(RecNo()),2,aAcho,,,,aButtons)
			EndIf
		EndIf
	EndIf
EndIf

cFilAnt := cFilOld

RestInter()
RestArea(aAreaAKD)
RestArea(aArea)
Return 

STATIC FUNCTION P050RAT(aHeader,aCols) 
Local aArea := getArea()

Local aAcho := {}

DBSELECTAREA('SE2')
DBSETORDER(16)
If DbSeek(xFilial('SE2')+xFilial('CV4')+DTOS(CV4->CV4_DTSEQ)+CV4->CV4_SEQUEN)
	MaMakeView( 'SE2' )
	dbSelectArea("SX2")
	dbSetOrder(1)
	dbSeek('SE2')
	cCadastro := AllTrim(X2NOME())+STR0018//" - Visualizar"
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek('E2_ARQRAT')
	While !Eof() .And. 'SE2'==SX3->X3_ARQUIVO
		aAdd(aAcho,SX3->X3_CAMPO)
		dbSkip()
	End
	dbSelectArea('SE2')
Endif

RestArea(aArea)

Return


Static Function PCOMudouCubo(nI,aColsAKD,aHeadAKD)
Local cChave	:=	""
Local nX	:=	0
Local lMudou	:=	.F.
Local nPosCol	:=	0
Local nPosClasse	:=	Ascan(aHeadAKD,{|x| Alltrim(x[2]) == 'AKD_CLASSE' })
Local nPosVal   	:=	0

If aCamposCubo	==	Nil      
	aCamposCubo	:=	{}
	DbSelectArea('AKW')	
	DbSetOrder(1)
	DbSeek(xFilial())                            
	While !Eof() .And. xFilial()==AKW_FILIAL
		cChave	:=	Alltrim(StrTran(AKW_CHAVER,"AKD->",""))+"+"
		While (nAt:= At("+",cChave)) > 0
			If Ascan(aCamposCubo,Substr(cChave,1,nAt-1)) == 0
				AAdd(aCamposCubo,Substr(cChave,1,nAt-1))
			Endif
			cChave	:= Substr(cChave,nAt+1)
		EndDo
		DbSkip()
	Enddo		
Endif                          
AAdd(aCamposCubo,"AKD_DATA")
AAdd(aCamposCubo,"AKD_TIPO")
For nX := 1 To Len(aCamposCubo)
	nPosCol	:=	Ascan(aHeadAKD,{|x| Alltrim(x[2]) == aCamposCubo[nX]})

	If nPosCol > 0 .And. aColsAKD[nI][nPosCol] <> AKD->(FieldGet(FieldPos(aCamposCubo[nX])))
		lMudou	:=	.T.
		Exit
	Endif	
Next		

//Verifica valores

nPosVal   	:=		Ascan(aHeadAKD,{|x| Alltrim(x[2]) == 'AKD_VAL1' })
If !lMudou .And. nPosVal > 0 .And. AKD->AKD_VALOR1 <> PcoPlanVal(aColsAKD[nI][nPosVal],aColsAKD[nI][nPosCol])
	lMudou	:=	.T.
Endif	
nPosVal   	:=		Ascan(aHeadAKD,{|x| Alltrim(x[2]) == 'AKD_VAL2' })
If !lMudou .And. nPosVal > 0 .And. AKD->AKD_VALOR2 <> PcoPlanVal(aColsAKD[nI][nPosVal],aColsAKD[nI][nPosCol])
	lMudou	:=	.T.
Endif	
nPosVal   	:=		Ascan(aHeadAKD,{|x| Alltrim(x[2]) == 'AKD_VAL3' })
If !lMudou .And. nPosVal > 0 .And. AKD->AKD_VALOR3 <> PcoPlanVal(aColsAKD[nI][nPosVal],aColsAKD[nI][nPosCol])
	lMudou	:=	.T.
Endif	
nPosVal   	:=		Ascan(aHeadAKD,{|x| Alltrim(x[2]) == 'AKD_VAL4' })
If !lMudou .And. nPosVal > 0 .And.  AKD->AKD_VALOR4 <> PcoPlanVal(aColsAKD[nI][nPosVal],aColsAKD[nI][nPosCol])
	lMudou	:=	.T.
Endif	
nPosVal   	:=		Ascan(aHeadAKD,{|x| Alltrim(x[2]) == 'AKD_VAL5' })
If !lMudou .And. nPosVal > 0 .And. AKD->AKD_VALOR5 <> PcoPlanVal(aColsAKD[nI][nPosVal],aColsAKD[nI][nPosCol])
	lMudou	:=	.T.
Endif	

Return lMudou
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A050VldCO º Autor ³ Gustavo Henrique  º Data ³  20/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida se a conta orcamentaria selecionada para o          º±±
±±º          ³ lancamento eh sintetica                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Codigo da conta orcamentaria                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ X3_VALID do campo AKD_CO                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A050VldCO(cCO)
Local lRet		:= .T.
Local aAreaAK5	:= AK5->(GetArea())

AK5->(dbSetOrder(1))
If AK5->(dbSeek(xFilial("AK5")+cCO))
	If AK5->AK5_MSBLQL=="1"
		lRet := .F.
		Aviso( STR0019,STR0034,{"Ok"}) //"Atenção"###"Conta orçamentária bloqueada."
	ElseIf AK5->AK5_TIPO<>"2"
		lRet := .F.
		Aviso( STR0019, STR0020,{"Ok"})//"Atenção"###"Informe uma conta orcamentária analítica."
	EndIf
Else	
	lRet := .F.
	Aviso( STR0019,STR0035,{"Ok"}) //"Atenção"###"Conta orçamentária não encontrada."	
EndIf
RestArea( aAreaAK5 )

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A050VldCO º Autor ³ Gustavo Henrique  º Data ³  20/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida se a conta orcamentaria selecionada para o          º±±
±±º          ³ lancamento eh sintetica                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Codigo da conta orcamentaria                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ X3_VALID do campo AKD_CO                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A050VldVar(cCodConf,cTipCod,cCodVar)
Local lRet		:= .T.
Local aAreaAMD	:= AMD->(GetArea())

DEFAULT cCodConf:= ""
DEFAULT cTipCod := ""
DEFAULT cCodVar := ""

AMD->(dbSetOrder(1))
If !AMD->(dbSeek(xFilial("AMD")+cCodConf+cTipCod+cCodVar))	
	lRet := .F.
	Aviso( STR0019,STR0038+CHR(13)+CHR(10)+STR0039+cCodConf+STR0037+cTipCod+STR0036+cCodVar,{"Ok"}) //"Atenção"### //" + Variação:" //" + Tipo:" //"Variação não encontrada com a chave: " //"Conf.Planej.: "
EndIf

RestArea( aAreaAMD )

Return lRet 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A050VldCO º Autor ³ Gustavo Henrique  º Data ³  20/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida se a conta orcamentaria selecionada para o          º±±
±±º          ³ lancamento eh sintetica                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Codigo da conta orcamentaria                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ X3_VALID do campo AKD_CO                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A050VldTip(cCodConf,cTipCod,cCpoVar)
Local lRet		:= .T.
Local aAreaAM1	:= AM1->(GetArea())
Local aAreaAMD	:= AMD->(GetArea())

DEFAULT cCodConf:= ""
DEFAULT cTipCod := ""
DEFAULT cCpoVar := ""

AM1->(dbSetOrder(2))
If AM1->(dbSeek(xFilial("AM1")+cCodConf+cTipCod))
	If !Empty(cCpoVar) .And. !Empty(&("M->"+cCpoVar))
		AMD->(dbSetOrder(1))
		If !AMD->(dbSeek(xFilial("AMD")+cCodConf+cTipCod+&(cCpoVar)))	
			&("M->"+cCpoVar) := Space(TamSX3(cCpoVar)[1])
			Aviso( STR0019,STR0040,{"Ok"}) //"Variação não encontrada para este tipo."
		EndIf	
	EndIf
Else	
	lRet := .F.
	Aviso( STR0019,STR0041,{"Ok"}) //"Atenção"### //"Tipo não encontrado no cadatro."
EndIf

RestArea(aAreaAMD)
RestArea(aAreaAM1)

Return lRet 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A050ChkBlqºAutor  ³Paulo Carnelossi    º Data ³  27/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Checkar se integridade com PCO esta ligada e se campo      º±±
±±º          ³ AKD_LCTBLQ existe na base de dados                         º±±
±±º          ³ ---- se nao existe retorna falso                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A050ChkBlq(lLockBlq)
lLockBlq := lLockBlq .And. ;
				SuperGetMV("MV_PCOINTE",.F.,"2")=="1"
Return(lLockBlq)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A050Id_Next_AKDºAutor  ³Paulo Carnelossi º Data ³ 31/03/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna Proximo AKD_ID para o lote em edicao                º±±
±±º          ³Utilizado quando usuario resolve colocar + 1 item na altera-º±±
±±º          ³cao do lancamento quando o parametro MV_PCOVISL esta com    º±±
±±º          ³conteudo "2" (somente edita lctos alterados/Pcodetlan()     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A050Id_Next_AKD()
Local aArea := GetArea()
Local aAreaAKD := AKD->(GetArea())
Local nItAKD := 0

dbSelectArea("AKD")
dbSetOrder(1)
If dbSeek(xFilial("AKD")+M->AKD_LOTE)
	While AKD->(!Eof().And.AKD_FILIAL+AKD_LOTE == ;
					xFilial("AKD")+M->AKD_LOTE)
		nItAKD := VAL(AKD->AKD_ID)
		AKD->(dbSkip())
	End
EndIf

nItAKD++
cItAKD := StrZero(nItAKD, Len(AKD->AKD_ID))

RestArea(aAreaAKD)
RestArea(aArea)

Return(cItAKD)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³17/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±     
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
Local aUsRotina := {}
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1, ,.F.},;    //"Pesquisar"
							{ STR0003, 	"A050DLG"  , 0 , 2},;    //"Visualizar"
							{ STR0004, 		"A050DLG"  , 0 , 3},;	  //"Incluir"
							{ STR0005, 		"A050DLG"  , 0 , 4},; //"Alterar"
							{ STR0006, 		"A050DLG"  , 0 , 5},; //"Excluir"
							{ STR0007, 		"A050DLG"  , 0 , 5},; //"Estornar"
							{ STR0008, 		"PCOA050Leg"  , 0 , 2, ,.F.}} //"Legenda"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona botoes do usuario no aRotina                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PCOA0501" )
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ³
		//P_E³ browse da tela de lançamentos                                          ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
		//P_E³               Ex. :  User Function PCOA0501                            ³
		//P_E³                      Return {{"Titulo", {|| U_Teste() } }}             ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( aUsRotina := ExecBlock( "PCOA0501", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FAtiva   º Autor ³ Gustavo Henrique   º Data ³  09/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para chamada do pergunte para selecao do tipo de    º±±
±±º          ³ edicao dos lancamentos.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA050 - Planejamento e Controle Orcamentario             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A050Perg( cPerg )
Pergunte( "PCO050", .T. )   
Return NIL






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOA050   ºAutor  ³ Leandro Sousa      º Data ³  09/13/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Validaçao das entidades contabeis Centro de Custo, Item   º±±
±±º          ³ e Classe de Valores quando estas estiverem bloqueadas      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA050 - Planejamento e Controle Orcamentario             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PCO050BLQ(aHeadAKD,aColsAKD,nI)
/*
Local _nPosID_	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_ID"})
Local _nPosCta	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_CO"})
Local _nPosCc	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_CC"}) 
Local _nPosItctb	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_ITCTB"})
Local _nPosClVlr	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_CLVLR"})
Local _nPosUnOrc	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_UNIORC"})
*/
Local lVld		:= .T.
Local lVldUsr := ExistBlock("PCOA0507")
Local aArea		:= GetArea()
Local nX		:= 0
Local cCpoBloq	:= ""
Local nPosEntAd	:= 0
Local cIdEntAd	:= ""
Local cChvPesq	:= ""
Local cPrefCpo	:= ""
Local lCCusto	:= .F.
Local lIContabil:= .F.
Local lCValor	:= .F.
Local lUOrcam	:= .F.
Local lCtaOrc := .F.
Local cMsgBlq 	:= ""

Local cQuery := ""
Local cAliasQry := ""
Local cBusca
Local aValue

If _nPosID_ == NIL
	_nPosID_	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_ID"})
EndIf

If _nPosCta == NIL
	_nPosCta	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_CO"}) 
EndIf

If _nPosCc == NIL
	_nPosCc	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_CC"}) 
EndIf

If _nPosItctb == NIL
	_nPosItctb	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_ITCTB"}) 
EndIf

If _nPosClVlr == NIL
	_nPosClVlr	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_CLVLR"}) 
EndIf

If _nPosUnOrc == NIL
	_nPosUnOrc	:= AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_UNIORC"}) 
EndIf

If _aDataBlq == NIL .OR. _cGrFilPro == NIL .OR. _cGrFilPro <> cEmpAnt+cFilAnt
	_aDataBlq := {}
	_cGrFilPro := cEmpAnt+cFilAnt
	
	If _nPosCc > 0
		cAliasQry := GetNextAlias() 
		cQuery := " SELECT CTT_CUSTO, R_E_C_N_O_ FROM " + RetSqlName("CTT")
		cQuery += " WHERE CTT_FILIAL = '"+xFilial("CTT")+"' AND "
		cQuery += "       CTT_BLOQ = '1' AND "
		cQuery += "       D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)
		While (cAliasQry)->( ! Eof() )
			aAdd( _aDataBlq, { "CTT"+(cAliasQry)->CTT_CUSTO, (cAliasQry)->R_E_C_N_O_ } )
			(cAliasQry)->( dbSkip() )
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf

	If _nPosItctb > 0
		cAliasQry := GetNextAlias() 
		cQuery := " SELECT CTD_ITEM, R_E_C_N_O_ FROM " + RetSqlName("CTD")
		cQuery += " WHERE CTD_FILIAL = '"+xFilial("CTD")+"' AND "
		cQuery += "       CTD_BLOQ = '1' AND "
		cQuery += "       D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)
		While (cAliasQry)->( ! Eof() )
			aAdd( _aDataBlq, { "CTD"+(cAliasQry)->CTD_ITEM, (cAliasQry)->R_E_C_N_O_ } )
			(cAliasQry)->( dbSkip() )
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf

	If _nPosClVlr > 0
		cAliasQry := GetNextAlias() 
		cQuery := " SELECT CTH_CLVL, R_E_C_N_O_ FROM " + RetSqlName("CTH")
		cQuery += " WHERE CTH_FILIAL = '"+xFilial("CTH")+"' AND "
		cQuery += "       CTH_BLOQ = '1' AND "
		cQuery += "       D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)
		While (cAliasQry)->( ! Eof() )
			aAdd( _aDataBlq, { "CTH"+(cAliasQry)->CTH_CLVL, (cAliasQry)->R_E_C_N_O_ } )
			(cAliasQry)->( dbSkip() )
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf

	If _nPosCta > 0
		cAliasQry := GetNextAlias() 
		cQuery := " SELECT AK5_CODIGO, R_E_C_N_O_ FROM " + RetSqlName("AK5")
		cQuery += " WHERE AK5_FILIAL = '"+xFilial("AK5")+"' AND "
		cQuery += "       AK5_MSBLQL = '1' AND "
		cQuery += "       D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)
		While (cAliasQry)->( ! Eof() )
			aAdd( _aDataBlq, { "AK5"+(cAliasQry)->AK5_CODIGO, (cAliasQry)->R_E_C_N_O_ } )
			(cAliasQry)->( dbSkip() )
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf

	If _nPosUnOrc > 0
		cAliasQry := GetNextAlias() 
		cQuery := " SELECT AMF_CODIGO, R_E_C_N_O_ FROM " + RetSqlName("AMF")
		cQuery += " WHERE AMF_FILIAL = '"+xFilial("AMF")+"' AND "
		cQuery += "       AMF_MSBLQL = '1' AND "
		cQuery += "       D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)
		While (cAliasQry)->( ! Eof() )
			aAdd( _aDataBlq, { "AMF"+(cAliasQry)->AMF_CODIGO, (cAliasQry)->R_E_C_N_O_ } )
			(cAliasQry)->( dbSkip() )
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf

	If Len(_aDataBlq) > 0
  		_oHash := AToHM(_aDataBlq)
	EndIf

EndIf

If Len(_aDataBlq) > 0 .And. _oHash <> NIL   //se len maior que zero entao existe objeto _oHash (tHashMap)
	If _nPosCc > 0
		cBusca := "CTT"+aColsAKD[nI][_nPoscc]
		aValue := NIL  
		lRet := HMGet(_oHash,cBusca,aValue)
		If lRet
			lVld := .F. 
			lCCusto := .T.
			CTT->( dbGoto( aValue[1,2] ) )
		EndIf
	EndIf

	If _nPosItctb > 0
		cBusca := "CTD"+aColsAKD[nI][_nPosItctb]
		aValue := NIL  
		lRet := HMGet(_oHash,cBusca,aValue)
		If lRet
			lVld := .F.
			lIContabil:= .T.
			CTD->( dbGoto( aValue[1,2] ) )
		EndIf
	EndIf

	If _nPosClVlr > 0
		cBusca := "CTH"+aColsAKD[nI][_nPosClVlr]
		aValue := NIL  
		lRet := HMGet(_oHash,cBusca,aValue)
		If lRet
			lVld := .F. 
			lCValor	:= .T.
			CTH->( dbGoto( aValue[1,2] ) )
		EndIf
	EndIf

	If _nPosCta > 0
		cBusca := "AK5"+aColsAKD[nI][_nPosCta]
		aValue := NIL  
		lRet := HMGet(_oHash,cBusca,aValue)
		If lRet
			lVld := .F. 
			lCtaOrc := .T.
			AK5->( dbGoto( aValue[1,2] ) )
		EndIf
	EndIf

	If _nPosUnOrc > 0
		cBusca := "AMF"+aColsAKD[nI][_nPosUnOrc]
		aValue := NIL  
		lRet := HMGet(_oHash,cBusca,aValue)
		If lRet
			lVld := .F.
			lUOrcam	:= .T.
			AMF->( dbGoto( aValue[1,2] ) )
		EndIf
	EndIf
EndIf

//-------------------------------------------------------
// Avalia o bloqueio das contas das entidades adicionais
//-------------------------------------------------------
If lVld

	If nQtdEntid == NIL 
		If cPaisLoc == "RUS" 
			nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor.
		Else
			nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
		EndIf
	EndIf

	For nX := 5 To nQtdEntid
		If _TamCT0Id == NIL 
			_TamCT0Id := TamSX3("CT0_ID")[1]
		EndIf

		cIdEntAd := StrZero(nX,_TamCT0Id)

		If CT0->(MsSeek(XFilial("CT0")+cIdEntAd))

			//--------------------------------
			// Identifica o campo de bloqueio
			//--------------------------------
			If CT0->CT0_ALIAS == "CV0"
				cCpoBloq := CT0->CT0_ALIAS + "_BLOQUE"
			Else
				cPrefCpo := If(Left(CT0->CT0_ALIAS,1) == "S", Right(CT0->CT0_ALIAS,2), CT0->CT0_ALIAS)
				cCpoBloq := cPrefCpo + "_MSBLQL"
			EndIf
			
			//--------------------------------
			// Identifica a chave de pesquisa
			//--------------------------------
			If CT0->CT0_ALIAS == "CV0"
				cChvPesq := "XFilial(CT0->CT0_ALIAS)+CT0->CT0_ENTIDA"
			Else
				cChvPesq := "XFilial(CT0->CT0_ALIAS)"
			EndIf

			nPosEntAd := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_ENT" + cIdEntAd})

			If nPosEntAd > 0 

				DbSelectArea(CT0->CT0_ALIAS)
				DbSetOrder(1)
				If MsSeek(&(cChvPesq)+aColsAKD[nI][nPosEntAd])

					If (CT0->CT0_ALIAS)->(FieldPos(cCpoBloq)) > 0 .And. &(CT0->CT0_ALIAS + "->" +cCpoBloq) == '1'
						lVld := .F.
						Exit
					EndIf

				EndIf
			EndIf

		EndIf

	Next nX

EndIf

If lVldUsr
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para validacao da linha de digitacao do     ³
	//P_E³ movimento                                                              ³
	//P_E³ Parametros : {lVld} // se ja bloqueou recebe .F. SE não bloqueou .T.   ³
	//P_E³ Retorno    : .F. - Deve bloquear a linha de digitacao                  ³
	//P_E³              .T. - Liberar a linha digitada                            ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lVld := ExecBlock("PCOA0507",.f.,.f.,{lVld})
EndIf

If !lVld
	// Grava códigos de bloqueio
	
	If lCCusto
		cMsgBlq += STR0029+CTT->CTT_CUSTO + CRLF // "Centro de Custo: "
	EndIf
	If lIContabil
		cMsgBlq += STR0030+CTD->CTD_ITEM + CRLF // "Item Contábil: "
	EndIf
	If lCValor
		cMsgBlq += STR0031+CTH->CTH_CLVL + CRLF // "Classe de Valor: "
	EndIf
	If lUOrcam
		cMsgBlq += STR0032+AMF->AMF_CODIGO + CRLF  // "Unidade Orçamentaria: "
	EndIf 
	If lCtaOrc
		cMsgBlq += STR0033+AK5->AK5_CODIGO + CRLF // "Conta Orçamentaria: "
	EndIf
	
	HELP("",1,"BLOQUEIO",,STR0028+CRLF+; // "As entidades abaixo estão com status de bloqueado."
	cMsgBlq+CRLF+STR0023+IIF(_nPosID_ > 0,CRLF+Upper(aHeadAKD[_nPosID_][1])+": "+aColsAKD[nI][_nPosID_],""),1,0) // Favor analisar e informar um registro que não esteja bloqueado.
EndIF

RestArea(aArea)

Return lVld                    

/*/{Protheus.doc} PcoMaCheckCols
Consiste os campos obrigatorios da linha da GetDados.

IMPORTANTE: Esta é uma static function para ganho de performance no PCOA050 - derivada da funcao generica MaCheckCols

Utiliza 2 variaveis static 
_aSx3Obgt -> array multidimensional para cada elemento do aHeaderChk tera uma linha correspondente onde:
			1a. Posicao - Variavel logico indicando se campo eh obrigatorio
			2a. Posicao - Variavel caracter contendo descricao do campo usando funcao padrao X3Descri()
			3a. Posicao - Variavel caracter contendo nome da tabela em uso usando funcao padrao X2Nome()
_cEmpProc -> Variavel caracter contendo cEmpAnt pois se mudar de Empresa deve carregar o array _aSx3Obgt novamente

@Param aHeaderChk, array, contem a estrutura dos campos a serem validados
@Param aColsChk, array, contem os dados a serem validados
@Param nCheck, numerico, A linha do aCols a ser validado
@Param aCpoSkip, array, Contem os campos do aHeader que não seja validado
@Param lValid, Logico, Se Verdadeiro valida as variaveis de memoria com nome dos campos no aHeader

@Return lRet - trata-se de uma nota de complemento

@author Edson Maricate
@since 09-02-2001
@version 1.0
/*/
Static Function PcoMaCheckCols(aHeaderChk,aColsChk,nCheck,aCpoSkip, lValid)
Local aArea		:= GetArea()
Local aAreaSX3
Local aAreaSX2
Local lRet		:= .T.
Local ny
Local _SaveVar	:= __ReadVar

Default aCpoSkip 	:= {}
Default lValid		:= .F.

If _aSx3Obgt == NIL .Or. _cEmpProc == NIL .Or. cEmpAnt <> _cEmpProc
	aAreaSX3	:= SX3->(GetArea())
	aAreaSX2	:= SX2->(GetArea())
	_aSx3Obgt := {}
	_cEmpProc := cEmpAnt
	For ny := 1 to Len(aHeaderChk)
		//posiciona no dicionario no campo x3 e na tabela x2
		SX3->(dbSetOrder(2))
		SX3->(MsSeek(aHeaderChk[ny,2]))
		SX2->(dbSetOrder(1))
		SX2->(MsSeek(SX3->X3_ARQUIVO))

		aAdd(_aSx3Obgt, { X3Obrigat(aHeaderChk[ny,2]), X3DESCRIC(), X2NOME() })
	Next
	RestArea(aAreaSX2)
	RestArea(aAreaSX3)
Endif

For ny := 1 to Len(aHeaderChk)

	If Alltrim(aHeaderChk[ny,2]) $ "AKD_ALI_WT|AKD_REC_WT"  //campos walktru nao precisam ser validados
		Loop
	EndIf

	If lValid
		__ReadVar := "M->"+aHeaderChk[nY,2]
		&(__ReadVar) := aColsChk[nCheck,nY]
	EndIf
	
	If aScan( aCpoSkip, { | ExpA1 | PadR(ExpA1,10) == PadR(aHeaderChk[ny,2],10) } ) > 0
		Loop
	EndIf

  	If _aSx3Obgt[ny,1] .And. !aColsChk[nCheck,Len(aColsChk[nCheck])] .And. Empty(aColsChk[nCheck,ny])
		HELP("  ",1,"OBRIGAT2",,_aSx3Obgt[ny,3]+CRLF+STR0015+_aSx3Obgt[ny,2]+CRLF+STR0016+Str(nCheck,3,0),3,1) //"Campo: "###"Linha: "
		lRet := .F.
		Exit
	EndIf 
	If lValid .And. !Empty(aColsChk[nCheck,ny]) .and. !Empty(aHeaderChk[ny,6]) .and. !&(aHeaderChk[ny,6])
		lRet := .F.
		Exit
	EndIf
Next nY

__ReadVar := _SaveVar

RestArea(aArea)
Return lRet
