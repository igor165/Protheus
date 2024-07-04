#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSA700.CH"                     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA700  ³ Autor ³ Eduardo de Souza      ³ Data ³ 16/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Geracao de novos Contratos de Prestacao de Servicos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA700()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                  ATUALIZACOES - VIDE SOURCE SAFE                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA700()

Local oDlg
Local nOpcA    := 0
Local cPerg    := "TMC700"
Local aSize    := {}
Local aInfo    := {}
Local aObjects := {}
Local aPosObjH := {}
Local aAlter   := {}
Local aButtons := {}
Local nPos			:= 0
Local nI			:= 0
Local nJ			:= 0

Private oGet

Private dDataNvContr := dDataBase
Private cReaAut		 := ""
Private cTipoFrete	 := ""
Private cCodNegDe	 := ""
Private cCodNegAte	 := ""
Private cServDe		 := ""
Private cServAte	 := ""
Private cClienteDe   := ""
Private cLojaDe		 := ""
Private cClienteAte  := ""
Private cLojaAte	 := ""

Private lMsErroAuto := .F.
Private aHeader     := {}
Private aCols       := {}
Private aRotina     := { {"","",0,1}, {"","",0,2}, {"","",0,3},{"","",0,4},{"","",0,5},{"","",0,6} }

Private nPosTipT     := 0
Private nPosTabF     := 0
Private nPosContrs   := 0
Private nPosTabAnt   := 0
Private nPosTipAnt   := 0
Private nPosTbAltAnt := 0
Private nPosTpAltAnt := 0
Private nPosFlag     := 0
Private nPosCodNeg   := 0

Inclui := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                              ³
//³ mv_par01	// Data Novo Contrato                                  ³
//³ mv_par02	// Contrato (1=Com Reajuste \ 2=Sem Reajuste \ 3=Ambos)³
//³ mv_par03	// Tipo Frete ( 1=CIF \ 2=FOB \ 3=CIF\FOB )            ³
//³ mv_par04	// Servico De                                          ³
//³ mv_par05	// Servico Ate                                         ³
//³ mv_par06	// Cliente De                                          ³
//³ mv_par07	// Loja De                                             ³
//³ mv_par08	// Cliente Ate                                         ³
//³ mv_par09	// Loja Ate                                            ³
//³ mv_par10	// Preco do Cliente (Modifica / Mantem)                ³
//³ mv_par11	// Tabela Frete De                                     ³
//³ mv_par12	// Tipo Tabela Frete De                                ³
//³ mv_par13	// Tabela Frete Ate                                    ³
//³ mv_par14	// Tipo Tabela Frete Ate                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                              ³
//³ mv_par01	// Data Novo Contrato                                  ³
//³ mv_par02	// Contrato (1=Com Reajuste \ 2=Sem Reajuste \ 3=Ambos)³
//³ mv_par03	// Tipo Frete ( 1=CIF \ 2=FOB \ 3=CIF\FOB )            ³
//³ mv_par04	// Cod Negociacao De                                   ³
//³ mv_par05	// Cod Negociacao Ate                                  ³
//³ mv_par06	// Servico De                                          ³
//³ mv_par07	// Servico Ate                                         ³
//³ mv_par08	// Cliente De                                          ³
//³ mv_par09	// Loja De                                             ³
//³ mv_par10	// Cliente Ate                                         ³
//³ mv_par11	// Loja Ate                                            ³
//³ mv_par12	// Preco do Cliente (Modifica / Mantem)                ³
//³ mv_par13	// Tabela Frete De                                     ³
//³ mv_par14	// Tipo Tabela Frete De                                ³
//³ mv_par15	// Tabela Frete Ate                                    ³
//³ mv_par16	// Tipo Tabela Frete Ate                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa as variaveis do pergunte                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Pergunte(cPerg,.T.)
	Return .F.
EndIf

dDataNvContr := mv_par01
cReaAut      := AllTrim(Str(mv_par02,1))
cTipoFrete   := AllTrim(Str(mv_par03,1))
cCodNegDe    := mv_par04
cCodNegAte   := mv_par05
cServDe      := mv_par06
cServAte     := mv_par07
cClienteDe   := mv_par08
cLojaDe      := mv_par09
cClienteAte  := mv_par10
cLojaAte     := mv_par11

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Header da GetDados                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader     := A700Header()
nPosCodNeg  := Ascan(aHeader, { |X| Upper(Alltrim(X[2])) = "DDA_CODNEG" })
nPosTipT    := Ascan(aHeader, { |X| Upper(Alltrim(X[2])) = "DDA_TIPTAB" })
nPosTabF    := Ascan(aHeader, { |X| Upper(Alltrim(X[2])) = "DDA_TABFRE" })
nPosTipAlt  := Ascan(aHeader, { |X| Upper(Alltrim(X[2])) = "DDA_TIPALT" })
nPosTabAlt  := Ascan(aHeader, { |X| Upper(Alltrim(X[2])) = "DDA_TABALT" })
nPosContrs  := Len(aHeader) + 2 //-- Posicao dos Contratos
nPosTabAnt  := Len(aHeader) + 3 //-- Posicao da Tabela Anterior
nPosTipAnt  := Len(aHeader) + 4 //-- Posicao do Tipo da Tabela Anterior
nPosTbAltAnt:= Len(aHeader) + 5 //-- Posicao da Tabela Alternativa Anterior
nPosTpAltAnt:= Len(aHeader) + 6 //-- Posicao do Tipo da Tabela Alternativa Anterior
nPosFlag    := Len(aHeader) + 7 //-- Posicao do Flag de Alteracao 
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Acols da GetDados                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgRun(STR0015,STR0016, {|| aCols:= A700Acols() } ) // "Verificando contratos..." ### "Aguarde..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao existem dados para geracao do Contrato.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCols) == 0
	Help( "", 1, "RECNO" ) //"Nao existem registros no arquivo em pauta"
	Return .F.
EndIf

For nI := 1 To Len(aHeader)
	If (nPos := Ascan(aHeader, { |X| Upper(Alltrim(X[2])) = "AAM_CODCLI" })) > 0 .OR.; 
		(nPos := Ascan(aHeader, { |X| Upper(Alltrim(X[2])) = "AAM_LOJA" })) > 0 .OR.; 
		(nPos := Ascan(aHeader, { |X| Upper(Alltrim(X[2])) = "A1_NOME" })) > 0
		aDel(aHeader, nPos)
		aSize(aHeader, Len(aHeader) - 1)
		For nJ := 1 To Len(aCols)
			aDel(aCols[nJ], nPos)
			aSize(aCols[nJ], Len(aCols[nJ]) - 1)
		Next
		nI--
	EndIf
Next

nPosCodNeg  := Ascan(aHeader, { |X| Upper(Alltrim(X[2])) = "DDA_CODNEG" })
nPosTipT    := Ascan(aHeader, { |X| Upper(Alltrim(X[2])) = "DDA_TIPTAB" })
nPosTabF    := Ascan(aHeader, { |X| Upper(Alltrim(X[2])) = "DDA_TABFRE" })
nPosTipAlt  := Ascan(aHeader, { |X| Upper(Alltrim(X[2])) = "DDA_TIPALT" })
nPosTabAlt  := Ascan(aHeader, { |X| Upper(Alltrim(X[2])) = "DDA_TABALT" })
nPosContrs  := Len(aHeader) + 2 //-- Posicao dos Contratos
nPosTabAnt  := Len(aHeader) + 3 //-- Posicao da Tabela Anterior
nPosTipAnt  := Len(aHeader) + 4 //-- Posicao do Tipo da Tabela Anterior
nPosTbAltAnt:= Len(aHeader) + 5 //-- Posicao da Tabela Alternativa Anterior
nPosTpAltAnt:= Len(aHeader) + 6 //-- Posicao do Tipo da Tabela Alternativa Anterior
nPosFlag    := Len(aHeader) + 7 //-- Posicao do Flag de Alteracao 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dimensoes da Tela					                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
aSize := MsAdvSize( .T. )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
AAdd(aObjects,{100,100,.T.,.T.})
aPosObjH := MsObjSize( aInfo, aObjects, .T. )
            
aButtons   := {{'PESQUISA', {|| GdSeek(oGet,STR0030, , , .T.)}, STR0030}} //"Pesquisar"

DEFINE MSDIALOG oDlg FROM aSize[7],0 TO aSize[6],aSize[5] TITLE STR0001 PIXEL //"Geracao de Novos Contratos de prestacao de servicos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos que podem ser alterados.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aAlter,"DDA_TABFRE")
Aadd(aAlter,"DDA_TIPTAB")
Aadd(aAlter,"DDA_TABALT")
Aadd(aAlter,"DDA_TIPALT")

oGet := MSGetDados():New(aPosObjH[ 1, 1 ], aPosObjH[ 1, 2 ],aPosObjH[ 1, 3 ], aPosObjH[ 1, 4 ],6,"AlwaysTrue","AlwaysTrue",,.F.,aAlter,,.F.,,,,,,oDlg)
oGet :oBrowse:Refresh(.T.)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, { || nOpcA:=1,oDlg:End() }, { || oDlg:End() },, aButtons ) 
           
If nOpcA == 1
	
	//-- Gera Contrato
	Processa({|lEnd| A700Proc(@lEnd)},,,.T.)	

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apresenta o Log na Tela.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMSErroAuto
	MostraErro()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A700Proc ³ Autor ³ Eduardo de Souza      ³ Data ³ 17/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza Tabela de Frete nos contratos selecionados.    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A700Proc()                                             	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA700 											                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A700Proc(lEnd)

Local nX         := 0
Local nY         := 0
Local aContrServ := {}
Local aMantemPrc := {}
Local lMostraSel := .T.
Local aSeqTabNov := {}
Local lRet       := .T.
Local lContinua  := .T.
Local lTM700PRC  := ExistBlock("TM700PRC")
Local a700VisErr := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena Contratos e Servicos da Acols					      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aContrServ := A700CtrSrv()

ProcRegua(Len(aContrServ))
For nX := 1 To Len(aContrServ)

	IncProc()

	DbSelectArea("AAM")
	DbSetOrder(1)
	If MsSeek(xFilial("AAM")+aContrServ[nX,1])
			
		//-- Nao permite gerar Contrato, se ja existir contrato para a data do novo contrato
		If AAM->AAM_INIVIG <> dDataNvContr
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Trava pelo Cliente³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !MultLock("DVC",{"INC_AJU"+AAM->AAM_CODCLI+AAM->AAM_LOJA},1)
				AutoGRLog(STR0006 + " " + AAM->AAM_CONTRT + " " + STR0007) //"O Contrato" ### "nao foi gerado, devido a data do novo contrato ser igual ao data do contrato atual."
				Loop
			EndIf

			//-- Selecao dos clientes que devera manter o preco
			If lMostraSel .And. mv_par12 == 1
				If lTM700PRC
					aMantemPrc := ExecBlock("TM700PRC",.F.,.F.)
					If ValType(aMantemPrc) != "A"
						aMantemPrc := {}
					EndIf
				EndIf
				If Len(aMantemPrc) == 0
					lContinua := TmsA700Mrk(aContrServ,aMantemPrc)
				EndIf
				lMostraSel := .F.
			EndIf

			If lContinua
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Copia Ajuste da Tabela de Frete / Tabela Alternativa       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				For nY := 1 To Len(aContrServ[nX,2])				
				   //-- Copia Tabela de Frete 
					lRet := A700Ajuste(aContrServ[nX,2,nY,2],aContrServ[nX,2,nY,3],AAM->AAM_CODCLI,AAM->AAM_LOJA,aMantemPrc,aContrServ[nX,2,nY,4],aContrServ[nX,2,nY,5],aContrServ[nX,2,nY,1],a700VisErr,aContrServ[nX,2,nY,10])
					//-- Copia Tabela Alternativa
					If lRet
						lRet := A700Ajuste(aContrServ[nX,2,nY,6],aContrServ[nX,2,nY,7],AAM->AAM_CODCLI,AAM->AAM_LOJA,aMantemPrc,aContrServ[nX,2,nY,8],aContrServ[nX,2,nY,9],aContrServ[nX,2,nY,1],a700VisErr,aContrServ[nX,2,nY,10])					
					EndIf
					//-- Erro na tentativa de copiar os ajustes.
					If !lRet
						Exit
					EndIf
				Next nY
	      	      
				If lRet			
					Begin Transaction
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Gera Novos Contratos       				      				   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						A700GerCtr(nX,AAM->AAM_CONTRT,aContrServ)
				
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Grava o Fim da vigencia o Atualiza para tempo Determinado. ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RecLock("AAM",.F.)
				
						If AAM->AAM_INIVIG >= dDataNvContr
							AAM->AAM_INIVIG := dDataNvContr - 1
						EndIf
				
						AAM->AAM_FIMVIG := dDataNvContr - 1
						AAM->AAM_TPCONT := "2"
						MsUnLock()
				
					End Transaction
				EndIf
			Else
				lRet := .F.
			    Exit
			EndIf
		Else
			AutoGRLog(STR0006 + " " + AAM->AAM_CONTRT + " " + STR0007) //"O Contrato" ### "nao foi gerado, devido a data do novo contrato ser igual ao data do contrato atual."
		EndIf
	EndIf

	//-- Erro na tentativa de copiar os ajustes.
	If !lRet
		Exit
	EndIf

Next nX

If Len(a700VisErr) > 0
	TmsMsgErr( a700VisErr )
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A700Header ³ Autor ³ Eduardo de Souza    ³ Data ³ 16/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega Header para GetDados                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A700Header()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA700                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A700Header()

Local aDadosCpo := {}
Local aCampos   := {}
Local nCont     := 0

AAdd(aCampos, { "AAM_CODCLI", "" } )
AAdd(aCampos, { "AAM_LOJA"  , "" } )
AAdd(aCampos, { "A1_NOME"   , "" } )
AAdd(aCampos, { "DDA_CODNEG", "" })
AAdd(aCampos, { "DDB_DESCRI", "" })
AAdd(aCampos, { "DDA_ITEM"  , "" })
AAdd(aCampos, { "DDA_SERVIC", "" })
AAdd(aCampos, { "DDA_DESSER", "" })
AAdd(aCampos, { "DDA_TABFRE", "TMSA700Vld(1)" })
AAdd(aCampos, { "DDA_TIPTAB", "TMSA700Vld(2)" })
AAdd(aCampos, { "DDA_TABALT", "TMSA700Vld(3)" })
AAdd(aCampos, { "DDA_TIPALT", "TMSA700Vld(4)" })

For nCont := 1 to Len(aCampos)
	aDadosCpo := TamSX3(aCampos[nCont][1])
	AAdd(aHeader, {AllTrim(GetSX3Cache(aCampos[nCont][1],"X3_TITULO")), aCampos[nCont][1], X3Picture(aCampos[nCont][1]), aDadosCpo[1], aDadosCpo[2], IIf(Empty(aCampos[nCont][2]), GetSX3Cache(aCampos[nCont][1],"X3_VALID"),aCampos[nCont][2]), ;
		GetSX3Cache(aCampos[nCont][1],"X3_USADO"), aDadosCpo[3], GetSX3Cache(aCampos[nCont][1],"X3_ARQUIVO"), GetSX3Cache(aCampos[nCont][1],"X3_CONTEXT") })
Next nCont

Return aHeader

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A700Acols  ³ Autor ³ Eduardo de Souza    ³ Data ³ 16/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega Acols conforme parametros.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A700Acols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA700                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A700Acols()

Local aArea		:= GetArea()
Local cContrato := ""
Local cAliasQry := GetNextAlias()
Local cQuery    := ""
Local cIndTmp   := ""
Local nIndex    := 0
Local nX        := 0
Local nPos      := 0
Local nPosServ  := Ascan(aHeader, { |X| Upper(Alltrim(X[2])) = "DDA_SERVIC" })
Local nPosItem  := Ascan(aHeader, { |X| Upper(Alltrim(X[2])) = "DDA_ITEM" })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura do array aCols                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// 01 Item                  
// 02 Servico                  
// 03 Descricao do Servico                 
// 04 Tabela de Frete     
// 05 Tipo da Tabela
// 06 Deletado
// 07 Array contendo os Contratos da mesma Tabela e Tipo
// 08 Tabela Anterior
// 09 Tipo Tabela Anterior
// 10 Flag de Alteracao da Tabela

cQuery := " SELECT "
cQuery += "DDA_NCONTR, DDA_CODNEG, DDA_ITEM, DDA_SERVIC, X5_DESCRI, DDA_TABFRE, DDA_TIPTAB, DDA_TABALT, DDA_TIPALT, "
cQuery += "DDB_DESCRI, "
cQuery += " AAM_CODCLI, AAM_LOJA, A1_NOME "
cQuery += " FROM "
cQuery += RetSqlName('AAM') + " AAM, "
cQuery += RetSqlName('DDA') + " DDA, "
cQuery += RetSqlName('DDB') + " DDB, "
cQuery += RetSqlName('SA1') + " SA1, "
cQuery += RetSqlName('SX5') + " SX5  "		
cQuery += " WHERE AAM_FILIAL = '" + xFilial("AAM") + "'"
cQuery += " AND AAM_CODCLI BETWEEN '" + cClienteDe + "' AND '" + cClienteAte + "' "
cQuery += " AND AAM_LOJA   BETWEEN '" + cLojaDe    + "' AND '" + cLojaAte    + "' "
cQuery += " AND ( AAM.AAM_FIMVIG = ' ' "
cQuery += "  OR ( AAM.AAM_INIVIG <= '" + DtoS(dDataBase) + "' AND AAM.AAM_FIMVIG >= '" + DtoS(dDataBase) + "' ) ) "
If cTipoFrete <> "4" //-- Tipo de Frete
	cQuery += "	AND AAM_TIPFRE = '" + cTipoFrete + "' "
EndIf
If cReaAut <> "3" //-- Reajuste
	cQuery += " AND AAM_REAAUT = '" + cReaAut + "' "
EndIf
cQuery += " AND AAM.D_E_L_E_T_ = ' ' "
cQuery += " AND DDA_FILIAL = '" + xFilial("DDA") + "'"
cQuery += " AND DDA_NCONTR = AAM_CONTRT "
cQuery += " AND DDA_CODNEG BETWEEN '" + cCodNegDe + "' AND '" + cCodNegAte + "' "
cQuery += " AND DDA_SERVIC BETWEEN '" + cServDe + "' AND '" + cServAte + "' "
cQuery += " AND DDA_TABFRE BETWEEN '" + mv_par13 + "' AND '" + mv_par15 + "' "
cQuery += " AND DDA_TIPTAB BETWEEN '" + mv_par14 + "' AND '" + mv_par16 + "' "					   
cQuery += " AND DDA.D_E_L_E_T_ = ' ' "
cQuery += " AND DDB_FILIAL = '" + xFilial("DDB") + "'"
cQuery += " AND DDB_CODNEG = DDA_CODNEG "
cQuery += " AND DDB.D_E_L_E_T_ = ' ' "
cQuery += " AND A1_FILIAL = '" + xFilial("SA1") + "'"
cQuery += " AND A1_COD    = AAM_CODCLI "
cQuery += " AND A1_LOJA   = AAM_LOJA "
cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " AND X5_FILIAL = '" + xFilial("SX5") + "' "
cQuery += " AND X5_TABELA = 'L4' "
cQuery += " AND X5_CHAVE = DDA_SERVIC "
cQuery += " AND SX5.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Acols de acordo com os parametros.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Eof()		
	If 	( ( nPos := Ascan( aCols, {|x| x[nPosCodNeg] + x[nPosServ] + x[nPosTabF] + x[nPosTipT] + x[nPosTabAlt] + x[nPosTipAlt]  == (cAliasQry)->DDA_CODNEG + (cAliasQry)->DDA_SERVIC + (cAliasQry)->DDA_TABFRE + (cAliasQry)->DDA_TIPTAB + (cAliasQry)->DDA_TABALT + (cAliasQry)->DDA_TIPALT} ) ) == 0 ) 
		
		Aadd(aCols,Array(Len(aHeader)+7))
		aCols[Len(aCols),nPosContrs]:= {}
						            
		For nX := 1 to Len(aHeader)
			If aHeader[nX,10] <> "V" .And. aHeader[nX,08] <> "M"
				aCols[Len(aCols),nX] := FieldGet(FieldPos(aHeader[nX,2]))
			Else
				If aHeader[nX,08] <> "M"
					If AllTrim(aHeader[nX,2]) == "DDA_DESSER"
						aCols[Len(aCols),nX] := (cAliasQry)->(X5_DESCRI)
					Else
						aCols[Len(aCols),nX] := CriaVar(aHeader[nX,2],.T.)
					EndIf
				Else
					aCols[Len(aCols),nX] := FieldGet(FieldPos(aHeader[nX,2]))
				EndIf
			EndIf
			aCols[Len(aCols),Len(aHeader)+1] := .F.
		Next nX
		Aadd(aCols[Len(aCols),nPosContrs],(cAliasQry)->DDA_NCONTR)
		aCols[Len(aCols),nPosTabAnt]   := (cAliasQry)->DDA_TABFRE
		aCols[Len(aCols),nPosTipAnt]   := (cAliasQry)->DDA_TIPTAB
		aCols[Len(aCols),nPosTbAltAnt] := (cAliasQry)->DDA_TABALT
		aCols[Len(aCols),nPosTpAltAnt] := (cAliasQry)->DDA_TIPALT
		aCols[Len(aCols),nPosFlag  ]   := .F.
				
	Else
		Aadd(aCols[nPos,nPosContrs],(cAliasQry)->DDA_NCONTR)
	EndIf
	(cAliasQry)->(DbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ordena Acols por Servico.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCols) > 0
	aCols  := aSort( aCols,,, { | x , y | x[1] + x[2] + x[nPosCodNeg] + x[nPosItem] < y[1] + y[2] + y[nPosCodNeg] + y[nPosItem] } )
EndIf

If Select(cAliasQry) > 0
	DbSelectArea(cAliasQry)
	DbCloseArea()
EndIf

RestArea(aArea)

Return aCols

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A700GerCtr³ Autor ³ Eduardo de Souza      ³ Data ³ 17/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Novos Contratos de Serviços                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A700GerCtr()                             	    			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA700  												              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A700GerCtr(nPosAtu,cContrato,aContrServ)


Local aAreaAAM    := AAM->(GetArea())
Local aAreaDT9    := {}
Local aAreaDDA    := {}
Local aCampos     := {} 
Local nPos01      := 0
Local cNewContrat := GetSX8Num( "AAM", "AAM_CONTRT" )  //Armazena o Nr do Novo Contrato

Local bWhile      := {|| .T.}
Local bSeek       := {|| .T.}
Local cServic     := ""

Local cNegAnt     := ""
Local cQuery      := ""
Local cAliasDT9   := ""
Local aCamposDDC  := {}

DDC->(DbSetOrder(2))
DbSelectArea("DDA")
DbSetOrder(1)
bSeek := {|| DDA->(MsSeek(xFilial("DDA")+cContrato))}
bWhile   := {|| DDA->(!Eof()) .And. DDA->DDA_FILIAL + DDA->DDA_NCONTR == xFilial("DDA") + cContrato}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Copia Itens do Contrato						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Eval(bSeek)
	While Eval(bWhile)

		aCampos:= {}
		Aadd(aCampos,{"DDA_NCONTR",cNewContrat})

		If  (nPos01:= Ascan(aContrServ[nPosAtu,2], { |x| x[1]+x[10] == DDA->DDA_SERVIC+DDA->DDA_CODNEG } )) > 0
		   
			Aadd( aCampos, { "DDA_TABFRE",  aContrServ[nPosAtu,2,nPos01,2] } )
			Aadd( aCampos, { "DDA_TIPTAB",  aContrServ[nPosAtu,2,nPos01,3] } )
			Aadd( aCampos, { "DDA_T1ABALT", aContrServ[nPosAtu,2,nPos01,6] } ) 
			Aadd( aCampos, { "DDA_TIPALT",  aContrServ[nPosAtu,2,nPos01,7] } )			
		EndIf
      
      	//-- Copia Negociacoes do Cliente
		If DDA->(DDA_NCONTR + DDA_CODNEG) != cNegAnt

			If DDC->(DbSeek(xFilial("DDC") + DDA->(DDA_NCONTR + DDA_CODNEG)))
				aAreaDDC := DDC->(GetArea())
		
				aCamposDDC:= {}
				Aadd(aCamposDDC,{"DDC_NCONTR",cNewContrat})
				Aadd(aCamposDDC,{"DDC_INIVIG",dDataNvContr})
				Aadd(aCamposDDC,{"DDC_FIMVIG",Ctod('')})
					     
				//DDC->(TmsCopyReg({{"DDC_NCONTR",cNewContrat}}))
				DDC->(TmsCopyReg(aCamposDDC))
			
				RestArea( aAreaDDC )

				//-- Encerra Negociacao Anterior
				RecLock("DDC",.F.)
			
				If DDC->DDC_INIVIG >= dDataNvContr
					DDC->DDC_INIVIG := dDataNvContr - 1
				EndIf
		
				DDC->DDC_FIMVIG := dDataNvContr - 1
				DDC->DDC_TPCONT := "2"
				DDC->(MsUnLock())

			EndIf
								
			cNegAnt := DDA->(DDA_NCONTR + DDA_CODNEG)
		EndIf

		//-- Copia Itens das Negociacoes do Cliente
		aAreaDDA := DDA->(GetArea())     
	
		DDA->(TmsCopyReg(aCampos))
	
		RestArea( aAreaDDA )

		cServic := DDA->DDA_SERVIC
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Copia Configuracao de componentes por contrato ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCampos := {}
		Aadd( aCampos, { "DT9_NCONTR", cNewContrat } )

		cAliasDT9 := GetNextAlias()
		cQuery := " SELECT DT9.R_E_C_N_O_ REGISTRO "
		cQuery += "   FROM " + RetSqlName("DT9") + " DT9 "
		cQuery += "  WHERE DT9_FILIAL = '" + xFilial("DT9") + "'"
		cQuery += "    AND DT9_NCONTR = '" + cContrato + "' "
		cQuery += "    AND DT9_CODNEG = '" + DDA->DDA_CODNEG + "' "
		cQuery += "    AND DT9_SERVIC = '" + cServic + "' "
		cQuery += "    AND DT9.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDT9,.F.,.T.)
		While (cAliasDT9)->(!Eof())
			DT9->(DbGoTo((cAliasDT9)->REGISTRO))
		
			aAreaDT9 := DT9->(GetArea())
			
			DT9->(TmsCopyReg(aCampos))
			
			RestArea( aAreaDT9 )
		
			(cAliasDT9)->(DbSkip())
		EndDo

		(cAliasDT9)->(DbCloseArea())

		DbSelectArea("DDA")
		
		DbSkip()
	EndDo
EndIf		

aCampos := {}
Aadd( aCampos, { "AAM_CONTRT", cNewContrat  } )
Aadd( aCampos, { "AAM_TPCONT", "1"          } )
Aadd( aCampos, { "AAM_INIVIG", dDataNvContr } )

AAM->(TmsCopyReg(aCampos))
ConfirmSx8()

RestArea( aAreaAAm )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A700Ajuste³ Autor ³ Eduardo de Souza      ³ Data ³ 17/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Copia ajustes da tabela de frete anterior p/a tabela atual ³±±
±±³          ³ ( CodeBase )                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A700Ajuste()                             				        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1- Codigo da Tabela de Frete / Tabela Alternativa       ³±±
±±³          ³ExpC2- Tipo da Tabela de Frete / Tabela Alternativa         ³±±
±±³          ³ExpC3- Codigo do Cliente                                    ³±± 
±±³          ³ExpC4- Loja do Cliente                                      ³±±
±±³          ³ExpC5- Vetor contendo os clientes que deve manter o preco   ³±± 
±±³          ³ExpC6- Cod. Tab. de Frete / Tab. Alternativa Anterior       ³±± 
±±³          ³ExpC7- Tipo Tab. de Frete / Tab. Alternativa Anterior       ³±±
±±³          ³ExpC8- Servico                                              ³±±
±±³          ³ExpC9- Array                                                ³±±
±±³          ³ExpC10- Negociação                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA700  												              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A700Ajuste(cTabFre,cTipTab,cCodCli,cCodLoj,aMantemPrc,cTabAnt,cTipAnt,cServic,a700VisErr,cCodNeg)

Local lMantemPrc  := .F.
Local lRet        := .T.
Local aAreaAAM    := AAM->(GetArea())
             
//-- Esta validacao e' feita pois o usuario pode, por exemplo, alterar SOMENTE o codigo da Tabela Alternativa .. 
//-- Neste caso, seria desnecessario executar a funcao TMSA750Grv() para a Tabela de Frete ...
If cTabFre + cTipTab == cTabAnt + cTipAnt
	Return .T.
EndIf

If mv_par12 == 1 // Modifica Preco
	If Ascan(aMantemPrc, { |x| x[1] + x[2] == cCodCli + cCodLoj }) <> 0
		lMantemPrc := .T.
	EndIf
Else
	lMantemPrc := .T.
EndIf

cTabAnt := "'"+cTabAnt+"'"
cTipAnt := "'"+cTipAnt+"'"   

lRet := TMSA750Grv(cTabAnt,cTipAnt,,,,,cCodCli,cCodLoj,cCodCli,cCodLoj,,,3, mv_par03,{cServic, Space(Len(DVC->DVC_SERVIC))},cTabFre,cTipTab, lMantemPrc, a700VisErr,cCodNeg,cCodNeg )

RestArea( aAreaAAM )

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A700CtrSrv³ Autor ³ Eduardo de Souza      ³ Data ³ 22/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Armazena Contratos e Servicos da Acols                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A700CtrSrv()                             				        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA700  												              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A700CtrSrv()

Local nY         := 0
Local nX         := 0
Local aContrServ := {}
Local nPosServ   := Ascan(aHeader, { |X| Upper(Alltrim(X[2])) = "DDA_SERVIC" })
Local aContrSav  := {}
Local lTMA700CLI := ExistBlock('TMA700CLI')

//-- Ordena por tabelas alteradas
aCols := aSort( aCols,,, { | x , y | x[nPosFlag] > y[nPosFlag]  } )

For nX := 1 To Len(aCols)

	//-- Sai do Loop quando encontrar a primeira tabela que nao foi alterada.
	If !aCols[nX,nPosFlag] 
		Exit
	EndIf

	For nY := 1 To Len(aCols[nX,nPosContrs])

		//-- Verifica se o contrato esta armazenado
		If (nPos01 := Ascan(aContrServ, { |X| X[1] == aCols[nX,nPosContrs,nY] })) == 0 .And. ;
			(aCols[nX,nPosTabF] + aCols[nX,nPosTipT] <> aCols[nX,nPosTabAnt] + aCols[nX,nPosTipAnt] .Or. ;
			 aCols[nX,nPosTabAlt] + aCols[nX,nPosTipAlt] <> aCols[nX,nPosTbAltAnt] + aCols[nX,nPosTpAltAnt]) 			
			Aadd(aContrServ,{ aCols[nX,nPosContrs,nY] , {} } )	
			nPos01 := Len(aContrServ)
		EndIf

		//-- Verifica se houve alteracao na tabela de frete / Tabela Alternativa 
		If aCols[nX,nPosTabF] + aCols[nX,nPosTipT] <> aCols[nX,nPosTabAnt] + aCols[nX,nPosTipAnt] .Or. ;
			aCols[nX,nPosTabAlt] + aCols[nX,nPosTipAlt] <> aCols[nX,nPosTbAltAnt] + aCols[nX,nPosTpAltAnt]		
			Aadd(aContrServ[nPos01,2], { aCols[nX,nPosServ], aCols[nX,nPosTabF], aCols[nX,nPosTipT], aCols[nX,nPosTabAnt], aCols[nX,nPosTipAnt],;
										  	  	  aCols[nX,nPosTabAlt],aCols[nX,nPosTipAlt],aCols[nX,nPosTbAltAnt],aCols[nX,nPosTpAltAnt],aCols[nX,nPosCodNeg] } )
		EndIf

	Next nY

Next nX

If lTMA700CLI
	aContrSav := aClone(aContrServ)
	aContrServ:= ExecBlock("TMA700CLI",.F.,.F.,{aContrServ})
	If ValType(aContrServ) <> 'A'
		aContrServ := aClone(aContrSav)
	EndIf
Endif	
		
Return aContrServ

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA700Mrk³ Autor ³ Eduardo de Souza      ³ Data ³ 26/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seleciona clientes que mantem preco                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA700Mrk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA700                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA700Mrk(aContrServ,aMantemPrc)

Local oDlgEsp
Local aAreaSA1	  := SA1->( GetArea() )
Local lInvert	  := .F.
Local aObjects	  := {}
Local aInfo		  := {}
Local aPosObj	  := {}
Local aSize		  := MsAdvSize()
Local nOpca	  	  := 0
Local oTempTable  := Nil
Local cMark      := GetMark()
Local aCampos    := {}
Local aButtons   := {}
Private cAliasTRB:= CriaTrab(Nil,.F.)
Private oMark

//-- Cria arquivo de trabalho, com os clientes filtrados atraves do parametro
MsgRun(STR0017,STR0016, {|| A700ArqTra(@oTempTable,aContrServ) } ) // "Gerando informacoes para selecao de clientes (Manter o preco)..." ### "Aguarde..."

//-- Define os campos para mostrar no MsSelect
Aadd(aCampos, {"TRB_OK"     , "  ", ""                 , ""   })
Aadd(aCampos, {"TRB_COD"    , ""  , STR0009 , "@!" }) // "Codigo"
Aadd(aCampos, {"TRB_LOJA"   , ""  , STR0010 , "@!" }) // "Loja"
Aadd(aCampos, {"TRB_NOME"   , ""  , STR0011 , "@!" }) // "Nome"
Aadd(aCampos, {"TRB_NREDUZ" , ""  , STR0012 , "@!" }) // "N Fantasia"
Aadd(aCampos, {"TRB_TIPO"   , ""  , STR0013 , "@!" }) // "Tipo"

dbSelectArea(cAliasTRB)
dbSetOrder(1)
dbGoTop()

//-- Controle de dimensoes de objetos
AAdd( aObjects, { 100, 100,.T.,.T. } )

aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
aPosObj:= MsObjSize( aInfo, aObjects,.T. )

Aadd(aButtons,	{STR0014, {|| TMSA700Psq() }, STR0014 })	// "Pesquisa"
AAdd(aButtons, {'RELATORIO', {|| TMSA700imp()}, STR0028} ) //"Imprimir"
DEFINE MSDIALOG oDlgEsp TITLE STR0008 FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL // "Selecao de Clientes para Manter o Preco"

oMark := MsSelect():New(cAliasTRB,'TRB_OK',,aCampos,@lInvert,@cMark,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]})
oMark:oBrowse:lHasMark		:= .T.
oMark:oBrowse:lCanAllMark 	:= .T.

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| nOpca := 1, oDlgEsp:End() },{|| oDlgEsp:End() },, aButtons )

If	nOpca == 1

	DbSelectArea(cAliasTRB)
	DbSetOrder(1)
	DbGotop()
	While (cAliasTRB)->(!Eof())
		If !Empty((cAliasTRB)->TRB_OK)
			Aadd(aMantemPrc,{ (cAliasTRb)->TRB_COD, (cAliasTRb)->TRB_LOJA } )
		EndIf
		(cAliasTRB)->(DbSkip())
	EndDo

EndIf

//-- Apaga os indices do arquivo de trabalho.
oTempTable:Delete()
RestArea( aAreaSa1 )

Return nOpca == 1

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A700ArqTra³ Autor ³ Eduardo de Souza      ³ Data ³ 26/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta Arquivo de Trabalho                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A700ArqTra()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA700                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A700ArqTra(oTempTable,aContrServ)

Local aStruct  := {}
Local aRetBox  := RetSx3Box( GetSX3Cache("A1_TIPO","X3_CBOX"),,, 1 )
Local aAreaAAM := AAM->(GetArea())
Local nX       := 0

AAdd(aStruct, {"TRB_OK"     , "C", 2                      , 0 })
AAdd(aStruct, {"TRB_COD"    , "C", TamSX3("A1_COD")[1]    , 0 })
AAdd(aStruct, {"TRB_LOJA"   , "C", TamSX3("A1_LOJA")[1]   , 0 })
AAdd(aStruct, {"TRB_NOME"   , "C", TamSX3("A1_NOME")[1]   , 0 })
AAdd(aStruct, {"TRB_NREDUZ" , "C", TamSX3("A1_NREDUZ")[1] , 0 })
AAdd(aStruct, {"TRB_TIPO"   , "C", 20                      , 0 })

//-- Cria o arquivo de trabalho e seu primeiro indice.
oTempTable := FWTemporaryTable():New(cAliasTRB)
oTempTable:SetFields( aStruct )
oTempTable:AddIndex("01", {"TRB_COD","TRB_LOJA"} )
oTempTable:AddIndex("02", {"TRB_NOME"} )
oTempTable:Create()

AAM->(dbSetOrder(1))
SA1->(dbSetOrder(1))

For nX:= 1 To Len(aContrServ)
	If AAM->(MsSeek(xFilial("AAM")+aContrServ[nX,1]))
		If SA1->(MsSeek(xFilial("SA1")+AAM->AAM_CODCLI+AAM->AAM_LOJA))
			DbSelectArea(cAliasTRB)
			Reclock(cAliasTRB, .T.)
			(cAliasTRB)->TRB_OK     := Space(2)
			(cAliasTRB)->TRB_COD    := SA1->A1_COD
			(cAliasTRB)->TRB_LOJA   := SA1->A1_LOJA 
			(cAliasTRB)->TRB_NOME   := SA1->A1_NOME   
			(cAliasTRB)->TRB_NREDUZ := SA1->A1_NREDUZ			
			(cAliasTRB)->TRB_TIPO   := AllTrim(aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == SA1->A1_TIPO } ), 3 ])
			MsUnlock()
		EndIf
	EndIf
Next nX

RestArea( aAreaAAM )
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA700Psq ³ Autor ³ Eduardo de Souza   ³ Data ³  27/08/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Botao de Pesquisa                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA700Psq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA700                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA700Psq()

Local oCbx
Local oDlg
Local oPsqGet
Local aCbx		:= {}
Local cCampo	:= ""
Local cOrd      := ""
Local lSeek		:= .F.
Local nOrdem	:= 1

cCampo := AllTrim(GetSX3Cache("A1_COD","X3_TITULO")) + "+" + AllTrim(GetSX3Cache("A1_LOJA","X3_TITULO"))
Aadd( aCbx, cCampo )
cCampo := AllTrim(GetSX3Cache("A1_NOME","X3_TITULO"))
Aadd( aCbx, cCampo )

cCampo := Space( 40 )

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0014 // "Pesquisa"

	@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg ON CHANGE nOrdem := oCbx:nAt
	
	@ 22,05 MSGET oPsqGet VAR cCampo SIZE 206,10 PIXEL
	
	DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
	DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()
	
ACTIVATE MSDIALOG oDlg CENTERED

If	lSeek
	cCampo := AllTrim( cCampo )
	If nOrdem == 1
	   (cAliasTRB)->(dbSetOrder(1))
		(cAliasTRB)->(MsSeek(cCampo))		
	Else
	   (cAliasTRB)->(dbSetOrder(2))
		(cAliasTRB)->(MsSeek(cCampo))		
   EndIf		
EndIf

If	!(cAliasTRB)->(Eof())
	oMark:oBrowse:nAt:=(cAliasTRB)->(Recno())
	oMark:oBrowse:Refresh(.T.)
Else
	(cAliasTRB)->(DbGotop())
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TmsA700Vld ³ Autor ³ Eduardo de Souza   ³ Data ³  06/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida digitacao da Tabela e Tipo da Tabela                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA700Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA700                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA700Vld(nTipo)

Local lRet := .F.

Local cTabFre := ""
Local cTipTab := ""

If nTipo == 1        // Validacao dos campos DDA_TABFRE
	If !Empty(aCols[n,nPosTabAlt]) .And. M->DDA_TABFRE +aCols[n,nPosTipT] == aCols[n,nPosTabAlt]+aCols[n,nPosTipAlt]
      Help(" ",1,"AT250TFINV") // A Tabela de Frete Alternativa nao pode ser igual a Tabela de Frete ...
	   Return ( .F. )
   EndIf  
	cTabFre := M->DDA_TABFRE
	cTipTab := GdFieldGet("DDA_TIPTAB",n)
	lRet := ExistCpo("DTL",cTabFre) .And. TMSTbAtiva(cTabFre) .And. AlWaysTrue(aCols[n,nPosFlag]:= .T.)
	
ElseIf nTipo == 2    // Validacao dos campos DDA_TIPTAB
	If !Empty(aCols[n,nPosTabAlt]) .And. aCols[n,nPosTabF]+ M->DDA_TIPTAB == aCols[n,nPosTabAlt]+aCols[n,nPosTipAlt]
      Help(" ",1,"AT250TFINV") // A Tabela de Frete Alternativa nao pode ser igual a Tabela de Frete ...
	   Return ( .F. )
   EndIf  
	cTabFre := GdFieldGet("DDA_TABFRE",n)
	cTipTab := M->DDA_TIPTAB
	lRet := ExistCpo("DTL",cTabFre + cTipTab) .And. TMSTbAtiva(cTabFre,cTipTab) .And. AlWaysTrue(aCols[n,nPosFlag]:= .T.)
	
ElseIf nTipo == 3    // Validacao dos campos DDA_TABALT
   //-- Nao permitir informar uma Nova Tabela alternativa, se o campo Tabela Alternativa estiver vazio, ou seja,
   //-- se o contrato nao tiver tabela alternativa informada para o servico
   If Empty(aCols[n,nPosTabAlt]) 
   	Return ( .F. )
   EndIf
	If !Empty(aCols[n,nPosTabF]) .And. aCols[n,nPosTabF]+aCols[n,nPosTipT] == M->DDA_TABALT +aCols[n,nPosTipAlt]
      Help(" ",1,"AT250TFINV") // A Tabela de Frete Alternativa nao pode ser igual a Tabela de Frete ...
	   Return ( .F. )
   EndIf  
	cTabFre := M->DDA_TABALT
	cTipTab := GdFieldGet("DDA_TIPALT",n)
	lRet := ExistCpo("DTL",cTabFre) .And. TMSTbAtiva(cTabFre) .And. AlWaysTrue(aCols[n,nPosFlag]:= .T.)	
	
ElseIf nTipo == 4    // Validacao dos campos DDA_TIPALT
   //-- Nao permitir informar o Tipo da Nova Tabela Alternativa, se o campo Tipo da Tabela Alternativa estiver vazio, ou seja,
   //-- se o contrato nao tiver tabela alternativa informada para o servico
   If Empty(aCols[n,nPosTipAlt])
   	Return ( .F. )
   EndIf
	If !Empty(aCols[n,nPosTabF]) .And. aCols[n,nPosTabF]+aCols[n,nPosTipT] == aCols[n,nPosTabAlt]+M->DDA_TIPALT
      Help(" ",1,"AT250TFINV") // A Tabela de Frete Alternativa nao pode ser igual a Tabela de Frete ...
	   Return ( .F. )
   EndIf  
	cTabFre := GdFieldGet("DDA_TABALT",n)
	cTipTab := M->DDA_TIPALT
	lRet := ExistCpo("DTL",cTabFre + cTipTab) .And. TMSTbAtiva(cTabFre,cTipTab) .And. AlWaysTrue(aCols[n,nPosFlag]:= .T.)	
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA700Imp³ Autor ³Wellington A Santos    ³ Data ³12.07.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao de clientes na tela de selelcao para manter preco³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA700                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa700imp()
// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Par„metros para a fun‡„o SetPrint () ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1    := ""
Local cDesc2    := ""
Local cDesc3    := ""
Local cTamanho
Local wnrel		 := "TMSB700"
Local cString	 := cAliasTRB
Local aOrd      := {STR0026,STR0027} //"Codigo/Loja"###"Nome"
// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Par„metros para a fun‡„o Cabec () ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cRelatorio := ""
Local cTitulo    := ""
Local aPergs     := {}

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Vari veis utilizadas para impressao do cabe‡alho e rodap‚ ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private Li     := 80
Private M_Pag  := 1
Private tamanho:="M"
Private cPerg  :="TMB700"
// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Vari veis utilizadas pela fun‡„o SetDefault () ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aReturn  := { STR0001, 1,STR0002, 1, 2, 1, "",1 } //"Zebrado"###"Administração"
Private nLastKey := 0

cDesc1     := STR0020
cDesc2     := ""
cDesc3     := ""
cRelatorio := "TMSA700" // Nome do relat¢rio em disco
cTitulo    := STR0019
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros			                           ³
//³ mv_par01       // Contrato (Marcados / Nao Marcados / Ambos)           ³
//³ mv_par02       // Ordem    (Codigo/Loja / Nome)                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte ( cPerg, .F. )

wnrel:=SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey != 27
	SetDefault ( aReturn, cString )
	RptStatus({|lEnd| Tma700Imp(@lEnd,wnRel,cString,cTitulo,Tamanho,cRelatorio)},cTitulo)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    |Tma700Imp ³ Autor ³Wellington A Santos    ³ Data ³31/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Impressao dos clientes da tela de selecao para manter preco³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³Tma700Imp(lEnd,wnRel,cString,cTitulo,cTamanho,cRelatorio)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Tma700Imp                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tma700Imp(lEnd,wnRel,cString,cTitulo,cTamanho,cRelatorio)

Local cCabec1    := ""
Local cCabec2    := ""
Local aAreaTRB   := (cAliasTRB)->( GetArea() )
Local nCol       := 0
Local nTotalCli  := 0

DbSetOrder(aReturn[8])
(cAliasTRB)->( DbGotop() )
SetRegua((cAliasTRB)->( RecCount() ))
cCabec1 := STR0021 + Space(Len(SA1->A1_COD) - Len(STR0021) + 2 ) + STR0025 + Space(Len(SA1->A1_LOJA) - Len(STR0022) + 4 );
+ STR0022 + Space(Len(SA1->A1_NOME) - Len(STR0022) + 2 );
+ STR0023 + Space(Len(SA1->A1_NREDUZ) - Len(STR0023) + 2) + STR0024 + Space(Len(SA1->A1_TIPO) - Len(STR0024) + 2 )
Do While (cAliasTRB)->( !Eof() )
	IncRegua()
	If MV_PAR01 == 1//marcados
		If Empty( (cAliasTRB)->TRB_OK )
			(cAliasTRB)->( DbSkip() )
			Loop
		EndIf
	ElseIf MV_PAR01 == 2//nao marcados
		If !Empty( (cAliasTRB)->TRB_OK )
			(cAliasTRB)->( DbSkip() )
			Loop
		EndIf
	EndIf
	nTotalCli++
	If li > 56
		cabec(cTitulo,cCabec1,cCabec2,cRelatorio,cTamanho,18)
	EndIf
	nCol := 0
	@li,nCol psay (cAliasTRB)->TRB_COD
	nCol += Len((cAliasTRB)->TRB_COD)    + 2
	@li,nCol psay (cAliasTRB)->TRB_LOJA
	nCol += Len((cAliasTRB)->TRB_LOJA)   + 4
	@li,nCol psay (cAliasTRB)->TRB_NOME
	nCol += Len((cAliasTRB)->TRB_NOME)   + 2
	@li,nCol psay (cAliasTRB)->TRB_NREDUZ
	nCol += Len((cAliasTRB)->TRB_NREDUZ) + 2
	@li,nCol psay (cAliasTRB)->TRB_TIPO
	li++
	(cAliasTRB)->( DbSkip() )	
EndDo

@li,000 psay STR0029 + Space(5) + Str(nTotalCli,2)
Set Device To Screen

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	Ourspool(wnrel)
Endif

MS_FLUSH()

RestArea(aAreaTRB)

Return .T.
