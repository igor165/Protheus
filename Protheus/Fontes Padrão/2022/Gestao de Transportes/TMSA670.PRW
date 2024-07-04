#INCLUDE "TMSA670.ch"
#include "Protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA670  ³ Autor ³ Henry Fila            ³ Data ³ 21.12.02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Copia de Ajustes                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA670()

Local oDlgRep
Local oCombo
Local nCombo
Local aGet       := {}
Local aPosObj    := {} 
Local aObjects   := {}                        
Local aSize      := MsAdvSize( .F. )             
Local aCombo     := {STR0001,STR0002} //"Sim"###"Nao"
Local cTabela    := CriaVar("DVC_TABFRE",.F.)
Local cTipo      := CriaVar("DVC_TIPTAB",.F.)
Local cCdrOri    := CriaVar("DVC_CDRORI",.F.)
Local cCdrDes    := CriaVar("DVC_CDRDES",.F.)
Local cServico   := CriaVar("DVC_SERVIC",.F.)
Local cProduto   := CriaVar("B1_COD",.F.)
Local cCodNeg    := ""
Local cCombo     := ""
Local nOpca	 	  := 0
Local lTMALogGrv := ExistBlock("TMALOGGRV")
Local nACols
Local oSize		:= FwDefSize():New( .T. )
Local nLININI		:= 0
Local nCOLINI		:= 0
Local nLINEND		:= 0
Local nCOLEND		:= 0
Local aYesFields	:= {}
Local nX			:= 0	

Private cNomCli  := CriaVar("A1_NOME",.F.)
Private aHeader  := {}
Private aCols	  := {} 
Private _cCliente:= CriaVar("A1_COD",.F.)
Private _cLoja   := CriaVar("A1_LOJA",.F.)

// Variavel utilizada para nao realizar a Validacao do campo DVD_CODCLI (X3_WHEN) feita
// no Ajuste da Tabela de Frete
// NAO RETIRAR !!!
Private nOpcao  := 3


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria a Trava com o Nome 'AJUMAN'. Se algum usuario estiver incluindo Ajuste de   ³
//³ Cliente, a rotina de 'Reajuste da Tabela de Clientes' nao podera ser executada   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                      

LockByName("AJUMAN",.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a rotina de 'Reajuste da Tabela de Clientes' estiver sendo executada, nao sera³
//³ permitida a inclusao Manual de Ajuste de Clientes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
If !MultLock("DVC",{"GERAJU"},1) 
	Help(" ",1,"TMSA67001") //"A copia de Ajuste nao podera ser efetuada, pois existe outro usuario reajustando os precos"
	UnLockByName("AJUMAN",.T.,.F.) // Libera Lock		
   Return( .F. )		
EndIf

Inclui := .T.

aRotina		:= {	{ STR0003, "AxPesqui", 0, 1 },;	//"Pesquisar"
						{ STR0004, "AxVisual", 0, 2 },; 	//"Visualizar"
						{ STR0005, "AxInclui", 0, 3 },; 	//"Incluir"
						{ STR0006, "AxAltera", 0, 4 },; 	//"Alterar"
						{ STR0007, "AxExclui", 0, 5 }} 	//"Excluir"

AAdd( aYesFields, "DVC_CODCLI" )
AAdd( aYesFields, "DVC_LOJCLI" )
AAdd( aYesFields, "DVC_NOMCLI" )

FillGetDados(3,"DVC",,,,, , aYesFields,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,.T.)

cValid := "Tms670cop(  ReadVar()  )"

For nX := 1 to Len(aHeader)	
	aHeader[nX][6] := cValid
Next		

cCodNeg := CriaVar("DDB_CODNEG",.F.)

oSize:lLateral     := .F.  // Calculo vertical

// adiciona Enchoice
oSize:AddObject( "ENCHOICE", 100, 10, .T., .T. ) // Adiciona Enchoice

// adiciona grid
oSize:AddObject( "GRID",100, 200, .T., .T. ) // Adiciona Grid

// Dispara o calculo
oSize:Process()

nLININI		:= oSize:GetDimension("ENCHOICE","LININI") + 2
nCOLINI		:= oSize:GetDimension("ENCHOICE","COLINI") + 2
nLINEND		:= oSize:GetDimension("ENCHOICE","LINEND")
nCOLEND		:= oSize:GetDimension("ENCHOICE","COLEND")

DEFINE MSDIALOG oDlgRep TITLE STR0008 From oSize:aWindSize[1],oSize:aWindSize[2] TO ;
											oSize:aWindSize[3],oSize:aWindSize[4] Of oMainWnd PIXEL //"Copia de Ajustes"

	@ nLININI - 2,nCOLINI - 2 to nLININI + 60,nCOLEND OF oDlgRep PIXEL

	@ nLININI,nCOLINI SAY STR0009 SIZE 50,7 OF oDlgRep PIXEL	 //"Cliente"
	@ nLININI,nCOLINI + 039 MsGet _cCliente PICTURE "@!" F3 "SA1" Valid Tmsa670Cli(_cCliente,_cLoja) SIZE 32,7 OF oDlgRep PIXEL	
	@ nLININI,nCOLINI + 077 SAY STR0010 SIZE 20,7 OF oDlgRep PIXEL	 //"Loja"
	@ nLININI,nCOLINI + 090 MsGet _cLoja PICTURE "@!" Valid Tmsa670Cli(_cCliente,_cLoja) SIZE 20,7 OF oDlgRep PIXEL	
	@ nLININI,nCOLINI + 118 MsGet cNomCli  When .F. SIZE 105,7 OF oDlgRep PIXEL	
	
	@ nLININI + 12,nCOLINI SAY STR0011 SIZE 20,7 OF oDlgRep PIXEL	 //"Tabela"
	@ nLININI + 12,nCOLINI + 039 MsGet cTabela VALID Vazio(cTabela) .Or. ExistCpo("DVC",cTabela+AllTrim(cTipo),1) PICTURE "@!" F3 "DTL" SIZE 32,7 OF oDlgRep PIXEL	
	@ nLININI + 12,nCOLINI + 077 SAY STR0012 SIZE 30,7 OF oDlgRep PIXEL	 //"Tipo"
	@ nLININI + 12,nCOLINI + 090 MsGet cTipo  VALID ExistCpo("DVC",cTabela+cTipo,1) PICTURE "@!" SIZE 20,7 OF oDlgRep PIXEL			
	@ nLININI + 12,nCOLINI + 118 MsGet Tabela("M5", cTipo, .F.) When .F. SIZE 105,7 OF oDlgRep PIXEL	
	
	@ nLININI + 24,nCOLINI SAY STR0013 SIZE 50,7 OF oDlgRep PIXEL	 //"Reg. Origem"
	@ nLININI + 24,nCOLINI + 039 MsGet cCdrOri VALID Vazio(cCdrOri) .Or. ExistCpo("DUY",cCdrOri) PICTURE "@!" F3 "DUY" SIZE 32,7 OF oDlgRep PIXEL			
	@ nLININI + 24,nCOLINI + 077 MsGet Posicione("DUY",1,xFilial("DUY")+cCdrOri,"DUY_DESCRI") When .F. SIZE 090,7 OF oDlgRep PIXEL			
	@ nLININI + 24,nCOLINI + 175 SAY STR0014 SIZE 50,7 OF oDlgRep PIXEL	 //"Reg. Destino"
	@ nLININI + 24,nCOLINI + 208 MsGet cCdrDes VALID Vazio(cCdrDes) .Or. ExistCpo("DUY",cCdrDes) PICTURE "@!" F3 "DUY" SIZE 32,7 OF oDlgRep PIXEL			
	@ nLININI + 24,nCOLINI + 242 MsGet Posicione("DUY",1,xFilial("DUY")+cCdrDes,"DUY_DESCRI")  When .F. SIZE 090,7 OF oDlgRep PIXEL			
	
	@ nLININI + 36,nCOLINI SAY STR0015 SIZE 50,7 OF oDlgRep PIXEL	 //"Servico"
	@ nLININI + 36,nCOLINI + 039 MsGet cServico VALID Vazio(cServico) .Or. ExistCpo("DC5",cServico) PICTURE "@!" F3 "DC5" SIZE 32,7 OF oDlgRep PIXEL			
	@ nLININI + 36,nCOLINI + 077 MsGet Tabela("L4", cServico, .F.) When .F. SIZE 090,7 OF oDlgRep PIXEL									
	@ nLININI + 36,nCOLINI + 175 SAY STR0016 SIZE 50,7 OF oDlgRep PIXEL	 //"Produto"
	@ nLININI + 36,nCOLINI + 208 MsGet cProduto VALID Vazio(cProduto) .Or. ExistCpo("SB1",cProduto)PICTURE "@!" F3 "SB1" SIZE 55,7 OF oDlgRep PIXEL			
	@ nLININI + 36,nCOLINI + 268 MsGet Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")  When .F. SIZE 090,7 OF oDlgRep PIXEL							
	
	@ 54,366 SAY RetTitle("DVC_CODNEG") SIZE 50,7 OF oDlgRep PIXEL
	@ 54,400 MsGet cCodNeg VALID Vazio(cCodNeg) .Or. ExistCpo("DDB",cCodNeg) PICTURE "@!" F3 "DDB" SIZE 20,7 OF oDlgRep PIXEL
	@ 54,428 MsGet Posicione("DDB",1,xFilial("DDB") + cCodNeg,"DDB_DESCRI")  When .F. SIZE 090,7 OF oDlgRep PIXEL
	
	@ nLININI + 48,nCOLINI SAY STR0017 SIZE 50,7 OF oDlgRep PIXEL	 //"Variantes"
	@ nLININI + 48,nCOLINI + 039 MSCOMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 32 ,7 OF oDlgRep PIXEL	
	Eval(oCombo:bChange := {|| nCombo := oCombo:nAt})

	oGetD := MsGetDados():New(oSize:GetDimension("ENCHOICE","LININI") + 70 , oSize:GetDimension("GRID","COLINI"), oSize:GetDimension("GRID","LINEND" ), oSize:GetDimension("GRID","COLEND"),3,"Tmsa670LOk()","AllWaysTrue()",,.T.,,,,9999)
	
ACTIVATE MSDIALOG oDlgRep ON INIT EnchoiceBar(oDlgRep,{|| nOpcA := 1, If(oGetd:TudoOk() .And. Tmsa670Ok(_cCliente,_cLoja,cTabela,cTipo),oDlgRep:End(),nOpcA := 0)},{||oDlgRep:End()})			
	
If ( nOpcA == 1 ) 
	lGravou := Processa({ || Tmsa670Rep(_cCliente,_cLoja,cTabela,cTipo,cCdrOri,cCdrDes,cServico,cProduto,nCombo,cCodNeg) })
	If ( lGravou )
		EvalTrigger()
		If ( __lSx8 )
			ConfirmSx8()
		EndIf
		If lTMALogGrv
			//-- Ponto de entrada comum entre todas as rotinas que manipulam tabela de frete e ajustes.
			//-- O ponto tem o objetivo de possibilitar a criacao de um LOG informando o  usuario  e  a
			//-- operação que foi realizada em uma tabela de frete ou ajuste de cliente.
			ExecBlock("TMALOGGRV",.F.,.F.,{ "DVC", "3",cUsername, 0 })
		EndIf				
	EndIf
EndIf                
If ( __lSx8 )
	RollBackSx8()
EndIf

MsUnlockAll()
	
dbSelectArea("DVC")
dbSetOrder(1)
UnLockByName("AJUMAN",.T.,.F.) // Libera Lock			

For nAcols := 1 To Len(aCols)
	If !aCols[nAcols,Len(aHeader) + 1]	
		UnLockByName("TMSA670" + cTabela + cTipo + aCols[nAcols,1] + aCols[nAcols,2] ,.T.,.F.) // Libera Lock
	EndIf
Next nAcols
Return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA670Rep³ Autor ³ Henry Fila            ³ Data ³ 26.12.02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Replica dos ajustes                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA670Rep())                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Cod. Cliente                                         ³±±
±±³          ³ ExpC2 - Loja Cliente                                         ³±±
±±³          ³ ExpC3 - Tabela                                               ³±±
±±³          ³ ExpC4 - Tipo da Tabela                                       ³±±
±±³          ³ ExpC5 - Regiao Origem                                        ³±±
±±³          ³ ExpC6 - Regiao Destino                                       ³±±
±±³          ³ ExpC7 - Servico                                              ³±±
±±³          ³ ExpC8 - Produto                                              ³±±
±±³          ³ ExpC9 - Variantes ? Sim / Nao                                ³±±
±±³          ³ ExpCA - Codigo Negociacao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA670                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Tmsa670Rep(_cCliente,_cLoja,cTabela,cTipo,cCdrOri,cCdrDes,cServico,cProduto,nCombo,cCodNeg)

Local aOrigem  := {}
Local aDestino := {}
Local lGravou := .F.
Local cSqlOri := ''
Local cSqlDes := ''
Local nX := 0
Local nACols
Local nLenaHea := Len(aHeader)
Local n1Cnt    := 0 
Local n2Cnt    := 0
Local aSqlOri  := {}
Local aSQLDes  := {}
Local nQuebra  := 800
Private aSeqTab:= {}
Default cCodNeg := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria a Trava com o Nome 'TMSA670'. Rotina fica exclusiva !!!                 ³
//³ Se algum usuario estiver gerando Copia de Ajustes, esta rotina nao podera    ³
//³ ser executada                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                      

For nAcols := 1 To Len(aCols)
	If !aCols[nACols,nLenaHea + 1]	
		If !LockByName("TMSA670" + cTabela + cTipo + aCols[nAcols,1] + aCols[nAcols,3] ,.T.,.F.)
			//-- Se Ja estiver reservado retorna .F. pois nao pode executar a Rotina	
			Help(" ",1,"TMSA67002") //"Esta rotina nao podera ser executada, pois existe outro usuario executando a Copia de Ajustes para um dos clientes de destino"
		   Return( .F. )		
		EndIf
	EndIf
Next nAcols

If Empty(cCdrOri) .And. Empty(cCdrDes) //Caso a copia seja para todas as regioes e destinos por query para aumentar a perfomance
	lGravou := TmsA670Exp( _cCliente,_cLoja,cTabela, cTipo, cProduto,cServico,,,cCodNeg)
	Return(lGravou)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega na memoria os campos da tabela original          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua((Len(aCols) * 9) + 2)

If nCombo == 1 .And. !Empty(cCdrOri)
	TmsNivInf(cCdrOri,@aOrigem,,.T.)    

	Aadd(aOrigem,{cCdrOri})		

ElseIf Empty(cCdrOri)
	Tmsa670Ori(cTabela,cTipo,@aOrigem,_cCliente,_cLoja)
Else
	Aadd(aOrigem,{cCdrOri})		
Endif

IncProc()
If nCombo == 1 .And. !Empty(cCdrDes)
	TmsNivInf(cCdrDes,@aDestino,,.T.)    
	Aadd(aDestino,{cCdrDes})			
ElseIf Empty(cCdrDes)	                
	Tmsa670Des(cTabela,cTipo,@aDestino,_cCliente,_cLoja)	
Else
	Aadd(aDestino,{cCdrDes})			
Endif	

IncProc()

//-- Quebra regiao origem / destino.
For nX := 1 To Len(aOrigem)
   cSqlOri += "'" + aOrigem [nX][1] + "',"
	If Mod(nX,nQuebra) == 0
	   cSqlOri := Substr(cSqlOri,1,Len(cSqlOri) - 1)
	   Aadd( aSQLOri, cSqlOri )
	   cSqlOri := ''
	EndIf
Next
If Mod(nX,nQuebra) <> 0
	cSqlOri := Substr(cSqlOri,1,Len(cSqlOri) - 1)
   Aadd( aSQLOri, cSqlOri )
EndIf

For nX := 1 To Len(aDestino)
   cSqlDes += "'" + aDestino [nX][1] + "',"
	If Mod(nX,nQuebra) == 0
		cSqlDes := Substr(cSqlDes,1,Len(cSqlDes) - 1)
		Aadd( aSQLDes, cSqlDes )
	   cSqlDes := ''
	EndIf
Next
If Mod(nX,nQuebra) <> 0
	cSqlDes := Substr(cSqlDes,1,Len(cSqlDes) - 1)
	Aadd( aSQLDes, cSqlDes )
EndIf

For n1Cnt := 1 To Len(aSQLOri)
	For n2Cnt := 1 To Len(aSQLDes)
		lGravou := TmsA670Exp( _cCliente,_cLoja,cTabela, cTipo, cProduto,cServico, aSqlOri[n1Cnt], aSqlDes[n2Cnt], cCodNeg )
	Next n2Cnt
Next n1Cnt

Return(lGravou)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA670Cli³ Autor ³ Henry Fila            ³ Data ³ 26.12.02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do cliente na tela                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA670Cli()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Cod. Cliente                                         ³±±
±±³          ³ ExpC2 - Loja Cliente                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA670                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tmsa670Cli(_cCliente,_cLoja)

Local lRet     := .T.

If !Empty(_cCliente) .And. !Empty(_cLoja)
	SA1->(dbSetOrder(1))    
	If SA1->(!MsSeek(xFilial("SA1")+_cCliente+_cLoja))
		lRet := .F.
		Help(" ",1,"REGNOIS") //"Nao existe registro relacionado a este codigo"
	ElseIf ExistFunc('FWPDCanUse') .And. FWPDCanUse()
		If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"A1_NOME"} )) > 0		
			cNomCli := SA1->A1_NOME
		Else				
			cNomCli := Replicate('*',TamSX3('A1_NOME')[1])
		EndIf	
	Else	
		cNomCli := SA1->A1_NOME	
	EndIf

Endif		

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA670LOk³ Autor ³ Henry Fila            ³ Data ³ 26.12.02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da linha da tela                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA670LOk()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA670                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tmsa670LOk()

Local lRet    := .T.
Local cCodCli := GdFieldGet('DVC_CODCLI', n)
Local cLojCli := GdFieldGet('DVC_LOJCLI', n)
Local	cCliGen := GetMV("MV_CLIGEN")

//-- Verifica o preenchimento dos campos obrigatorios
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))

	If Empty(cCodCli) .Or. Empty(cLojCli)
		Help(" ",1,"OBRIGAT") //Um ou alguns campos obrigatorios nao foram preenchidos. xxxxxxxxxxxxxxxxxx -> xxxxxxxxxx Pasta
		Return ( .F. )
	Endif	
	
	//-- Valida o Cliente Informado
	SA1->(DbSetOrder(1))
	If !SA1->( MsSeek( xFilial('SA1') + cCodCli + cLojCli ) )			    	
		Help(" ",1,"REGNOIS") //"Nao existe registro relacionado a este codigo"
		Return ( .F. )
	EndIf
   
   //-- Valida se o Cliente Informado e' o Cliente Generico
	If cCodCli+cLojCli == cCliGen
		Help("",1,"TMSXFUNB01") // Codigo Invalido ... O Codigo Informado e' de Cliente Generico (MV_CLIGEN) 
      Return ( .F. )
   EndIf
         
   //-- Verifica a existencia de Linhas Duplicadas 
	If lRet   
		lRet := GDCheckKey( { 'DVC_CODCLI', 'DVC_LOJCLI'}, 4 )	
	Endif				
	
Endif	

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA670Ok ³ Autor ³ Henry Fila            ³ Data ³ 26.12.02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do final da tela                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA670Ok()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Codigo do cliente                                    ³±±
±±³          ³ ExpC2 : Loja                                                 ³±±
±±³          ³ ExpC3 : Tabela                                               ³±±
±±³          ³ ExpC4 : Tipo da Tabela                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA670                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Tmsa670Ok(_cCliente,_cLoja,cTabela,cTipo)

Local lRet := .T.

If Empty(_cCliente) .Or. Empty(_cLoja) .Or. Empty(cTabela) .Or. Empty(cTipo)
	lRet := .F.
	Help(" ",1,"OBRIGAT") //Um ou alguns campos obrigatorios nao foram preenchidos. xxxxxxxxxxxxxxxxxx -> xxxxxxxxxx Pasta
Endif	

If lRet
	If Len(aCols) == 1 .And. Empty(aCols[1][1])
		lRet := .F.
		Help(" ",1,"OBRIGAT") //Um ou alguns campos obrigatorios nao foram preenchidos. xxxxxxxxxxxxxxxxxx -> xxxxxxxxxx Pasta
	Endif
Endif	

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA670Ori³ Autor ³ Henry Fila            ³ Data ³ 26.12.02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Traz todas as origens da tabela                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA670Ori()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Tabela                                               ³±±
±±³          ³ ExpC2 : Tipo                                                 ³±±
±±³          ³ ExpA3 : Origem (Referencia)                                  ³±±
±±³          ³ ExpC3 : Codigo do Cliente                                    ³±±
±±³          ³ ExpC4 : Loja do Cliente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array contendo as Regioes de Origem                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA670                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa670Ori(cTabela,cTipo,aOrigem,_cCliente,_cLoja)

Local aArea     := GetArea()
Local aAreaDVC  := DVC->(GetArea())

Local cQuery    := ""
Local cAliasQry := "DVC"
Local cAliasDVC := "DVC"
Local cArqTrb   := ""
Local cFilDVC   := ""

Local lQuery    := .F.

cAliasQry := GetNextAlias() 
cAliasDVC := cAliasQry
cQuery += "SELECT DVC_CDRORI FROM " + RetSqlName( "DVC" ) + " "
cQuery += "WHERE "
cQuery += "DVC_FILIAL='" + xFilial( "DVC" ) + "' AND "
cQuery += "DVC_TABFRE='" + cTabela  + "' AND "			
cQuery += "DVC_TIPTAB='" + cTipo    + "' AND "				
cQuery += "DVC_CODCLI='" + _cCliente + "' AND "
cQuery += "DVC_LOJCLI='" + _cLoja    + "' AND "
cQuery += "D_E_L_E_T_<>'*'"     
cQuery += " GROUP BY DVC_CDRORI "	
//-- ChangeQuery()
//-- 1o Parametro : Query 
//-- 2o Parametro : Se .F., nao insere FOR READ ONLY no final das querys para AS/400 e/ou DB2			            				                        
cQuery  := ChangeQuery(cQuery, .F.)

dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. ) 

While (cAliasDVC)->(!Eof())
	If Ascan(aOrigem,{|x| x[1] ==(cAliasDVC)->DVC_CDRORI}) == 0
		Aadd(aOrigem,{(cAliasDVC)->DVC_CDRORI})	
	Endif		
	(cAliasDVC)->(dbSkip())	
Enddo

dbSelectArea(cAliasDVC)
dbCloseArea()

Return(aOrigem)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA670Des³ Autor ³ Henry Fila            ³ Data ³ 26.12.02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Traz todas as destinos da tabela                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA670Des()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Tabela                                               ³±±
±±³          ³ ExpC2 : Tipo                                                 ³±±
±±³          ³ ExpA3 : Destino(Referencia)                                  ³±±
±±³          ³ ExpC3 : Codigo do cliente                                    ³±±
±±³          ³ ExpC4 : Loja                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array contendo as Regioes de Destino                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA670                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TmsA670Des(cTabela,cTipo,aDestino,_cCliente,_cLoja)

Local aArea     := GetArea()
Local aAreaDVC  := DVC->(GetArea())

Local cQuery    := ""
Local cAliasQry := "DVC"
Local cAliasDVC := "DVC"
Local cArqTrb   := ""
Local cFilDVC   := ""
Local lQuery    := .F.

cAliasQry := GetNextAlias() 
cAliasDVC := cAliasQry
cQuery += "SELECT DVC_CDRDES FROM " + RetSqlName( "DVC" ) + " "
cQuery += "WHERE "
cQuery += "DVC_FILIAL = '" + xFilial( "DVC" ) + "' AND "
cQuery += "DVC_TABFRE = '" + cTabela  + "' AND "			
cQuery += "DVC_TIPTAB = '" + cTipo    + "' AND "
cQuery += "DVC_CODCLI = '" + _cCliente + "' AND "
cQuery += "DVC_LOJCLI = '" + _cLoja    + "' AND "
cQuery += "D_E_L_E_T_  = ' '"     
cQuery += " GROUP BY DVC_CDRDES "
//-- ChangeQuery()
//-- 1o Parametro : Query 
//-- 2o Parametro : Se .F., nao insere FOR READ ONLY no final das querys para AS/400 e/ou DB2			            				                        
cQuery  := ChangeQuery(cQuery, .F.)
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. ) 
	
While (cAliasDVC)->(!Eof())

	If Ascan(aDestino, {|x| x[1] ==(cAliasDVC)->DVC_CDRDES}) == 0
		Aadd(aDestino,{(cAliasDVC)->DVC_CDRDES})	
	Endif		
	
	(cAliasDVC)->(dbSkip())	
Enddo

dbSelectArea(cAliasDVC)
dbCloseArea()

Return(aDestino)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa670Exp ³ Autor ³Wellington A Santos ³ Data ³26/02/2004  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Copia via query ajustes de um cliente para outro            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSa010STab()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Alias                                               ³±±
±±³          ³ExpC2 - Cliente Origem                                      ³±±
±±³          ³ExpC3 - Loja Origem                                         ³±±
±±³          ³ExpC4 - Tabela Origem                                       ³±±
±±³          ³ExpC5 - Tipo da tabela Origem                               ³±± 
±±³          ³ExpC6 - Produto Origem                                      ³±±
±±³          ³ExpC7 - Servico Origem                                      ³±±
±±³          ³ExpC8 - Cliente Destino                                     ³±±
±±³          ³ExpC9 - Loja do Cliente Destino                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA670                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function Tmsa670Exp( cCliOri,cLojOri,cTabOri, cTipOri, cProdOri,cSerOri,cSqlOri,cSqlDes,cCodNeg)

Local aEstruExp  := {},aAlias := {"DVC","DVD","DVO","DW2","DY2","DWZ"}
Local cQuery     := ""
Local n,nLenaHea := Len(aHeader)
Local lRet       := .F.
Local cAliasDVC,cAliasDVD,cAliasDVO,cAliasDW2
Local cAliasNew  := GetNextAlias() ,nAlias := 0,nAcols
Local cGroup     := ""
Local aFil       := { xFilial("DVC"), xFilial("DVD"), xFilial("DVO") , xFilial("DW2") , xFilial("DY2") , xFilial("DWZ") }
Local lTM670GDVC := ExistBlock('TM670GDVC')
Local lTM670GDVD := ExistBlock('TM670GDVD')
Local lTM670GDVO := ExistBlock('TM670GDVO')
Local lTM670GDW2 := ExistBlock('TM670GDW2')
Local lTM670GDY2 := ExistBlock('TM670GDY2')
Local lTM670GDWZ := ExistBlock('TM670GDWZ')
Local aMults     := {}
Local lLock      := .F.

Default cSqlOri  := ''
Default cSqlDes  := ''

cQuery := " SELECT "
cQuery += " COUNT(*) COUNT " 
cQuery += "  FROM " + RetSqlName( aAlias[1] )
cQuery += " WHERE " + aAlias[1] + "_FILIAL = '" + aFil[1] + "'"
cQuery += "   AND " + aAlias[1] + "_TABFRE = '" + cTabOri + "'"
cQuery += "   AND " + aAlias[1] + "_TIPTAB = '" + cTipOri + "'"
If !Empty(cSerOri)
	cQuery += "   AND " + aAlias[1] + "_SERVIC = '" + cSerOri + "'"
EndIf
If !Empty(cCodNeg)
	cQuery += "   AND " + aAlias[1] + "_CODNEG = '" + cCodNeg + "'"
EndIf
cQuery += "   AND " + aAlias[1] + "_CODCLI = '" + cCliOri + "'"
cQuery += "   AND " + aAlias[1] + "_LOJCLI = '" + cLojOri + "'"
If !Empty( cProdOri )
	cQuery += " AND " + aAlias[1] + "_CODPRO = '"  + cProdOri + "'"
EndIf
If !Empty( cSqlOri )
	cQuery += " AND "  + aAlias[1] +"_CDRORI IN (" + cSqlOri + ") "
EndIf
If !Empty( cSqlDes )
	cQuery += " AND "  + aAlias[1] +"_CDRDES IN (" + cSqlDes + ") "
EndIf

cQuery += "   AND D_E_L_E_T_ = ' '"
//-- ChangeQuery()
//-- 1o Parametro : Query 
//-- 2o Parametro : Se .F., nao insere FOR READ ONLY no final das querys para AS/400 e/ou DB2			            				                        
cQuery  := ChangeQuery(cQuery, .F.)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNew, .F., .T.)


If (cAliasNew)->( !Eof()  .And. COUNT > 0 )

	Aadd(aEstruExp, (aAlias[1])->( dbStruct() ) )    
	Aadd(aEstruExp, (aAlias[2])->( dbStruct() ) )    
	Aadd(aEstruExp, (aAlias[3])->( dbStruct() ) )
	Aadd(aEstruExp, (aAlias[4])->( dbStruct() ) )
	Aadd(aEstruExp, (aAlias[5])->( dbStruct() ) )
	Aadd(aEstruExp, (aAlias[6])->( dbStruct() ) )
	
	cQuery    := "SELECT DISTINCT "
	nAlias    := 1
	cAliasDVC := GetNextAlias()
	cGroup := aAlias[nAlias] + "_FILIAL," + aAlias[nAlias] + "_TABFRE, " + aAlias[nAlias] + "_TIPTAB," + aAlias[nAlias] + "_CODCLI," + aAlias[nAlias] + "_LOJCLI," + aAlias[nAlias] + "_CDRORI," + aAlias[nAlias] + "_CDRDES," + aAlias[nAlias] + "_CODPRO," + aAlias[nAlias] + "_CODNEG," + aAlias[nAlias] + "_SERVIC" 
	For n:=1 to Len( 	aEstruExp[nAlias]  )
		If !( aEstruExp[nalias][ n, 1 ] $ cGroup)
			cQuery += " Max(" + 	aEstruExp[nAlias][ n, 1 ] + ") " + aEstruExp[nAlias][ n, 1 ] + ", "
		Else
			cQuery += aEstruExp[nAlias][ n, 1 ] + ", "
		EndIf
	Next
	cQuery := Substr(cQuery,1,Len(cQuery) - 2)
	cQuery += "  FROM " + RetSqlName( aAlias[nAlias] )
	cQuery += " WHERE " + aAlias[nAlias] + "_FILIAL = '" + aFil[nAlias] + "'"
	cQuery += "   AND " + aAlias[nAlias] + "_TABFRE = '" + cTabOri + "'"
	cQuery += "   AND " + aAlias[nAlias] + "_TIPTAB = '" + cTipOri + "'"
	If !Empty(cSerOri)
		cQuery += "   AND " + aAlias[nAlias] + "_SERVIC = '" + cSerOri + "'"
	EndIf
	If !Empty(cCodNeg)
		cQuery += "   AND " + aAlias[nAlias] + "_CODNEG = '" + cCodNeg + "'"
	EndIf
	cQuery += "   AND " + aAlias[nAlias] + "_CODCLI = '" + cCliOri + "'"
	cQuery += "   AND " + aAlias[nAlias] + "_LOJCLI = '" + cLojOri + "'"
	If !Empty( cProdOri )
		cQuery += " AND " + aAlias[nAlias] + "_CODPRO = '"  + cProdOri + "'"
	EndIf
	If !Empty( cSqlOri )
		cQuery += " AND "  + aAlias[nAlias] +"_CDRORI IN (" + cSqlOri + ") "
	EndIf
	If !Empty( cSqlDes )
		cQuery += " AND "  + aAlias[nAlias] +"_CDRDES IN (" + cSqlDes + ") "
	EndIf
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += "  GROUP BY "  + cGroup
	//-- ChangeQuery()
	//-- 1o Parametro : Query 
	//-- 2o Parametro : Se .F., nao insere FOR READ ONLY no final das querys para AS/400 e/ou DB2			            				                        
	cQuery  := ChangeQuery(cQuery, .F.)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDVC, .F., .T.) 
	(cAliasDVC)->( DbGotop() )
	
	For nAcols := 1 To Len(aCols)
   	If !aCols[nACols,nLenaHea + 1] .And.;
		 	Ascan(aMults,"INC_AJU"+aCols[nAcols,1]+aCols[nAcols,2]) == 0
			AAdd(aMults,"INC_AJU"+aCols[nAcols,1]+aCols[nAcols,2])			
		EndIf
	Next nAcols 	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Trava pelo Cliente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lLock := MultLock("DVC",aMults,1)
	If lLock
   	                             
		For nAcols := 1 To Len(aCols)
			
			If !aCols[nACols,nLenaHea + 1]	 .And.;
				Ascan(aSeqTab,{|x| x[2]+x[3] == aCols[nAcols,1] + aCols[nAcols,2]}) == 0
				cQuery := "SELECT MAX(DVC_SEQTAB) SEQTAB FROM "
				cQuery += RetSqlName("DVC")
				cQuery += " WHERE DVC_FILIAL = '"+xFilial("DVC")+"'"
				cQuery += "   AND DVC_CODCLI = '"+aCols[nAcols,1]+"'"
				cQuery += "   AND DVC_LOJCLI = '"+aCols[nAcols,2]+"'"
				cQuery += "   AND DVC_TABFRE = '"+(cAliasDVC)->DVC_TABFRE +"'"
				cQuery += "   AND DVC_TIPTAB = '"+(cAliasDVC)->DVC_TIPTAB +"'"
				cQuery += "   AND D_E_L_E_T_ = ' '"
				//-- ChangeQuery()
				//-- 1o Parametro : Query
				//-- 2o Parametro : Se .F., nao insere FOR READ ONLY no final das querys para AS/400 e/ou DB2
				cQuery  := ChangeQuery(cQuery, .F.)
				cAliasSeq := GetNextAlias()
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSeq, .F., .T.)				
				If (cAliasSeq)->(Eof()) .Or. Empty((cAliasSeq)->SEQTAB)
					Aadd(aSeqTab, { StrZero(1,Len(DVC->DVC_SEQTAB)),aCols[nAcols,1], aCols[nAcols,2] } )
				Else
					Aadd(aSeqTab, { Soma1((cAliasSeq)->SEQTAB) , aCols[nAcols,1], aCols[nAcols,2] }  )
				EndIf
				(cAliasSeq)->(dbCloseArea())
			EndIf
		Next nAcols
		
		Begin Transaction
		Do While (cAliasDVC)->( !Eof() )
			
			nAlias := 2
			cAliasDVD := GetNextAlias()
			
			cGroup := aAlias[nAlias] + "_FILIAL," + aAlias[nAlias] + "_TABFRE, " + aAlias[nAlias] + "_TIPTAB," + aAlias[nAlias] + "_CODCLI," + aAlias[nAlias] + "_LOJCLI," + aAlias[nAlias] + "_CDRORI," + aAlias[nAlias] + "_CDRDES," + aAlias[nAlias] + "_CODPRO," + aAlias[nAlias] + "_CODNEG," + aAlias[nAlias] + "_SERVIC,"  + aAlias[nAlias] + "_CODPAS," + aAlias[nAlias] + "_ITEM"
			
			cQuery := "SELECT DISTINCT "
			For n:=1 to Len( 	aEstruExp[nAlias]  )
				If !( aEstruExp[nAlias][ n, 1 ] $ cGroup)
					cQuery += " Max(" + 	aEstruExp[nAlias][ n, 1 ] + ") " + aEstruExp[nAlias][ n, 1 ] + ", "
				Else
					cQuery += aEstruExp[nAlias][ n, 1 ] + ", "
				EndIf
			Next
			cQuery := Substr(cQuery,1,Len(cQuery) - 2)
			cQuery += "  FROM " + RetSqlName( aAlias[nAlias] )
			cQuery += " WHERE " + aAlias[nAlias] + "_FILIAL = '" + aFil[nAlias] + "'"
			cQuery += " AND " + aAlias[nAlias] + "_TABFRE = '" + (cAliasDVC)->DVC_TABFRE + "'"
			cQuery += " AND " + aAlias[nAlias] + "_TIPTAB = '" + (cAliasDVC)->DVC_TIPTAB + "'"
			cQuery += " AND " + aAlias[nAlias] + "_SEQTAB = '" + (cAliasDVC)->DVC_SEQTAB + "'"
			cQuery += " AND " + aAlias[nAlias] + "_SERVIC = '" + (cAliasDVC)->DVC_SERVIC + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CODNEG = '" + (cAliasDVC)->DVC_CODNEG + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CODCLI = '" + (cAliasDVC)->DVC_CODCLI + "'"
			cQuery += " AND " + aAlias[nAlias] + "_LOJCLI = '" + (cAliasDVC)->DVC_LOJCLI + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CODPRO = '" + (cAliasDVC)->DVC_CODPRO + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CDRORI = '" + (cAliasDVC)->DVC_CDRORI + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CDRDES = '" + (cAliasDVC)->DVC_CDRDES + "'"
			cQuery += " AND D_E_L_E_T_ = ' '"
			cQuery += " GROUP BY "  + cGroup
			//-- ChangeQuery()
			//-- 1o Parametro : Query
			//-- 2o Parametro : Se .F., nao insere FOR READ ONLY no final das querys para AS/400 e/ou DB2
			cQuery  := ChangeQuery(cQuery, .F.)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDVD, .F., .T.)
			
			nAlias := 3
			cAliasDVO := GetNextAlias()
			
			cGroup := aAlias[nAlias] + "_FILIAL," + aAlias[nAlias] + "_TABFRE, " + aAlias[nAlias] + "_TIPTAB," + aAlias[nAlias] + "_CODCLI," + aAlias[nAlias] + "_LOJCLI," + aAlias[nAlias] + "_CDRORI," + aAlias[nAlias] + "_CDRDES," + aAlias[nAlias] + "_CODPRO," + aAlias[nAlias] + "_SERVIC,"  + aAlias[nAlias] + "_CODPAS"
			cQuery := "SELECT DISTINCT "
			For n:=1 to Len( 	aEstruExp[nAlias]  )
				If !( aEstruExp[nAlias][ n, 1 ] $ cGroup)
					cQuery += " Max(" + 	aEstruExp[nAlias][ n, 1 ] + ") " + aEstruExp[nAlias][ n, 1 ] + ", "
				Else
					cQuery += aEstruExp[nAlias][ n, 1 ] + ", "
				EndIf
			Next
			cQuery := Substr(cQuery,1,Len(cQuery) - 2)
			cQuery += "  FROM " + RetSqlName( aAlias[nAlias] )
			cQuery += " WHERE " + aAlias[nAlias] + "_FILIAL = '" + aFil[nAlias] + "'"
			cQuery += " AND " + aAlias[nAlias] + "_TABFRE = '" + (cAliasDVC)->DVC_TABFRE + "'"
			cQuery += " AND " + aAlias[nAlias] + "_TIPTAB = '" + (cAliasDVC)->DVC_TIPTAB + "'"
			cQuery += " AND " + aAlias[nAlias] + "_SEQTAB = '" + (cAliasDVC)->DVC_SEQTAB + "'"
			cQuery += " AND " + aAlias[nAlias] + "_SERVIC = '" + (cAliasDVC)->DVC_SERVIC + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CODNEG = '" + (cAliasDVC)->DVC_CODNEG + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CODCLI = '" + (cAliasDVC)->DVC_CODCLI + "'"
			cQuery += " AND " + aAlias[nAlias] + "_LOJCLI = '" + (cAliasDVC)->DVC_LOJCLI + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CODPRO = '" + (cAliasDVC)->DVC_CODPRO + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CDRORI = '" + (cAliasDVC)->DVC_CDRORI + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CDRDES = '" + (cAliasDVC)->DVC_CDRDES + "'"
			cQuery += " AND D_E_L_E_T_ = ' '"
			cQuery += " GROUP BY "  + cGroup
			//-- ChangeQuery()
			//-- 1o Parametro : Query
			//-- 2o Parametro : Se .F., nao insere FOR READ ONLY no final das querys para AS/400 e/ou DB2
			cQuery  := ChangeQuery(cQuery, .F.)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDVO, .F., .T.)
			
			//-- Copia Sub-Faixas
			nAlias := 4
			cAliasDW2 := GetNextAlias()
			
			cGroup := aAlias[nAlias] + "_FILIAL," + aAlias[nAlias] + "_TABFRE, " + aAlias[nAlias] + "_TIPTAB," + aAlias[nAlias] + "_CODCLI," + aAlias[nAlias] + "_LOJCLI," + aAlias[nAlias] + "_CDRORI," + aAlias[nAlias] + "_CDRDES," + aAlias[nAlias] + "_CODPRO," + aAlias[nAlias] + "_CODNEG," + aAlias[nAlias] + "_SERVIC,"  + aAlias[nAlias] + "_CODPAS," + aAlias[nAlias] + "_ITEDVD," + aAlias[nAlias] + "_ITEM"
			
			cQuery := "SELECT DISTINCT "
			For n:=1 to Len( 	aEstruExp[nAlias]  )
				If !( aEstruExp[nAlias][ n, 1 ] $ cGroup)
					cQuery += " Max(" + 	aEstruExp[nAlias][ n, 1 ] + ") " + aEstruExp[nAlias][ n, 1 ] + ", "
				Else
					cQuery += aEstruExp[nAlias][ n, 1 ] + ", "
				EndIf
			Next
			cQuery := Substr(cQuery,1,Len(cQuery) - 2)
			cQuery += "  FROM " + RetSqlName( aAlias[nAlias] )
			cQuery += " WHERE " + aAlias[nAlias] + "_FILIAL = '" + aFil[nAlias] + "'"
			cQuery += " AND " + aAlias[nAlias] + "_TABFRE = '" + (cAliasDVC)->DVC_TABFRE + "'"
			cQuery += " AND " + aAlias[nAlias] + "_TIPTAB = '" + (cAliasDVC)->DVC_TIPTAB + "'"
			cQuery += " AND " + aAlias[nAlias] + "_SEQTAB = '" + (cAliasDVC)->DVC_SEQTAB + "'"
			cQuery += " AND " + aAlias[nAlias] + "_SERVIC = '" + (cAliasDVC)->DVC_SERVIC + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CODNEG = '" + (cAliasDVC)->DVC_CODNEG + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CODCLI = '" + (cAliasDVC)->DVC_CODCLI + "'"
			cQuery += " AND " + aAlias[nAlias] + "_LOJCLI = '" + (cAliasDVC)->DVC_LOJCLI + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CODPRO = '" + (cAliasDVC)->DVC_CODPRO + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CDRORI = '" + (cAliasDVC)->DVC_CDRORI + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CDRDES = '" + (cAliasDVC)->DVC_CDRDES + "'"
			cQuery += " AND D_E_L_E_T_ = ' '"
			cQuery += " GROUP BY "  + cGroup
			//-- ChangeQuery()
			//-- 1o Parametro : Query
			//-- 2o Parametro : Se .F., nao insere FOR READ ONLY no final das querys para AS/400 e/ou DB2
			cQuery  := ChangeQuery(cQuery, .F.)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDW2, .F., .T.)
			
			// Calculo de Excedente por Subfaixa
			// Copia Excedente por Sub-Faixas
			nAlias := 5
			cAliasDY2 := GetNextAlias()
			
			cGroup := aAlias[nAlias] + "_FILIAL," + aAlias[nAlias] + "_TABFRE, " + aAlias[nAlias] + "_TIPTAB," + aAlias[nAlias] + "_CODCLI," + aAlias[nAlias] + "_LOJCLI," + aAlias[nAlias] + "_CDRORI," + aAlias[nAlias] + "_CDRDES," + aAlias[nAlias] + "_CODPRO," + aAlias[nAlias] + "_CODNEG," + aAlias[nAlias] + "_SERVIC,"  + aAlias[nAlias] + "_CODPAS," + aAlias[nAlias] + "_ITEDVD," + aAlias[nAlias] + "_ITEM"
			
			cQuery := "SELECT DISTINCT "
			For n:=1 to Len( 	aEstruExp[nAlias]  )
				If !( aEstruExp[nAlias][ n, 1 ] $ cGroup)
					cQuery += " Max(" + 	aEstruExp[nAlias][ n, 1 ] + ") " + aEstruExp[nAlias][ n, 1 ] + ", "
				Else
					cQuery += aEstruExp[nAlias][ n, 1 ] + ", "
				EndIf
			Next
			cQuery := Substr(cQuery,1,Len(cQuery) - 2)
			cQuery += "  FROM " + RetSqlName( aAlias[nAlias] )
			cQuery += " WHERE " + aAlias[nAlias] + "_FILIAL = '" + aFil[nAlias] + "'"
			cQuery += " AND " + aAlias[nAlias] + "_TABFRE = '" + (cAliasDVC)->DVC_TABFRE + "'"
			cQuery += " AND " + aAlias[nAlias] + "_TIPTAB = '" + (cAliasDVC)->DVC_TIPTAB + "'"
			cQuery += " AND " + aAlias[nAlias] + "_SEQTAB = '" + (cAliasDVC)->DVC_SEQTAB + "'"
			cQuery += " AND " + aAlias[nAlias] + "_SERVIC = '" + (cAliasDVC)->DVC_SERVIC + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CODNEG = '" + (cAliasDVC)->DVC_CODNEG + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CODCLI = '" + (cAliasDVC)->DVC_CODCLI + "'"
			cQuery += " AND " + aAlias[nAlias] + "_LOJCLI = '" + (cAliasDVC)->DVC_LOJCLI + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CODPRO = '" + (cAliasDVC)->DVC_CODPRO + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CDRORI = '" + (cAliasDVC)->DVC_CDRORI + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CDRDES = '" + (cAliasDVC)->DVC_CDRDES + "'"
			cQuery += " AND D_E_L_E_T_ = ' '"
			cQuery += " GROUP BY "  + cGroup
			//-- ChangeQuery()
			//-- 1o Parametro : Query
			//-- 2o Parametro : Se .F., nao insere FOR READ ONLY no final das querys para AS/400 e/ou DB2
			cQuery  := ChangeQuery(cQuery, .F.)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDY2, .F., .T.)

			// Copia TDA
			nAlias := 6
			cAliasDWZ := GetNextAlias()
			
			cGroup := aAlias[nAlias] + "_FILIAL," + aAlias[nAlias] + "_TABFRE, " + aAlias[nAlias] + "_TIPTAB," + aAlias[nAlias] + "_CODCLI," + aAlias[nAlias] + "_LOJCLI," + aAlias[nAlias] + "_CDRORI," + aAlias[nAlias] + "_CDRDES," + aAlias[nAlias] + "_CODPRO," + aAlias[nAlias] + "_CODNEG," + aAlias[nAlias] + "_SERVIC,"  + aAlias[nAlias] + "_CODPAS"
			
			cQuery := "SELECT DISTINCT "
			For n:=1 to Len( 	aEstruExp[nAlias]  )
				If !( aEstruExp[nAlias][ n, 1 ] $ cGroup)
					cQuery += " Max(" + 	aEstruExp[nAlias][ n, 1 ] + ") " + aEstruExp[nAlias][ n, 1 ] + ", "
				Else
					cQuery += aEstruExp[nAlias][ n, 1 ] + ", "
				EndIf
			Next
			cQuery := Substr(cQuery,1,Len(cQuery) - 2)
			cQuery += "  FROM " + RetSqlName( aAlias[nAlias] )
			cQuery += " WHERE " + aAlias[nAlias] + "_FILIAL = '" + aFil[nAlias] + "'"
			cQuery += " AND " + aAlias[nAlias] + "_TABFRE = '" + (cAliasDVC)->DVC_TABFRE + "'"
			cQuery += " AND " + aAlias[nAlias] + "_TIPTAB = '" + (cAliasDVC)->DVC_TIPTAB + "'"
			cQuery += " AND " + aAlias[nAlias] + "_SEQTAB = '" + (cAliasDVC)->DVC_SEQTAB + "'"
			cQuery += " AND " + aAlias[nAlias] + "_SERVIC = '" + (cAliasDVC)->DVC_SERVIC + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CODNEG = '" + (cAliasDVC)->DVC_CODNEG + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CODCLI = '" + (cAliasDVC)->DVC_CODCLI + "'"
			cQuery += " AND " + aAlias[nAlias] + "_LOJCLI = '" + (cAliasDVC)->DVC_LOJCLI + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CODPRO = '" + (cAliasDVC)->DVC_CODPRO + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CDRORI = '" + (cAliasDVC)->DVC_CDRORI + "'"
			cQuery += " AND " + aAlias[nAlias] + "_CDRDES = '" + (cAliasDVC)->DVC_CDRDES + "'"
			cQuery += " AND D_E_L_E_T_ = ' '"
			cQuery += " GROUP BY "  + cGroup
			//-- ChangeQuery()
			//-- 1o Parametro : Query
			//-- 2o Parametro : Se .F., nao insere FOR READ ONLY no final das querys para AS/400 e/ou DB2
			cQuery  := ChangeQuery(cQuery, .F.)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDWZ, .F., .T.)
			
			For nAcols := 1 To Len(aCols)//insere para todos os clientes do acols
				If !aCols[nACols,nLenaHea + 1]
					(cAliasDVD)->( DbGotop() )
					(cAliasDVO)->( DbGotop() )
					While (cAliasDVD)->( !Eof() )
						RecLock('DVD',.T.)//gravar o dvd e dvc
						Replace DVD_FILIAL With (cAliasDVD)->DVD_FILIAL
						Replace DVD_TABFRE With (cAliasDVD)->DVD_TABFRE
						Replace DVD_TIPTAB With (cAliasDVD)->DVD_TIPTAB
						Replace DVD_SEQTAB With aSeqTab[nAcols,1]
						Replace DVD_CODCLI With aCols[nAcols,1]
						Replace DVD_LOJCLI With aCols[nAcols,2]
						Replace DVD_CDRORI With (cAliasDVD)->DVD_CDRORI
						Replace DVD_CDRDES With (cAliasDVD)->DVD_CDRDES
						Replace DVD_CODPRO With (cAliasDVD)->DVD_CODPRO
						Replace DVD_SERVIC With (cAliasDVD)->DVD_SERVIC
						Replace DVD_CODPAS With (cAliasDVD)->DVD_CODPAS
						Replace DVD_ITEM   With (cAliasDVD)->DVD_ITEM
						Replace DVD_VALATE With (cAliasDVD)->DVD_VALATE
						Replace DVD_FATPES With (cAliasDVD)->DVD_FATPES
						Replace DVD_INTERV With (cAliasDVD)->DVD_INTERV
						Replace DVD_PERAJU With (cAliasDVD)->DVD_PERAJU
						Replace DVD_RGDTAB With (cAliasDVD)->DVD_RGDTAB
						Replace DVD_PRDTAB With (cAliasDVD)->DVD_PRDTAB
						Replace DVD_RGOTAB With (cAliasDVD)->DVD_RGOTAB
						Replace DVD_CODNEG With (cAliasDVD)->DVD_CODNEG
						
                        DVD->( MsUnlock() )
						If lTM670GDVD
							ExecBlock('TM670GDVD',.F.,.F.)
						EndIf
						(cAliasDVD)->( DbSkip() )
					EndDo
					
					While (cAliasDVO)->( !Eof() )
						
						RecLock('DVO',.T.)//gravar o dvd e dvc
						Replace DVO_FILIAL With (cAliasDVO)->DVO_FILIAL
						Replace DVO_TABFRE With (cAliasDVO)->DVO_TABFRE
						Replace DVO_TIPTAB With (cAliasDVO)->DVO_TIPTAB
						Replace DVO_SEQTAB With aSeqTab[nAcols,1]
						Replace DVO_CODCLI With aCols[nAcols,1]
						Replace DVO_LOJCLI With aCols[nAcols,2]
						Replace DVO_CDRORI With (cAliasDVO)->DVO_CDRORI
						Replace DVO_CDRDES With (cAliasDVO)->DVO_CDRDES
						Replace DVO_CODPRO With (cAliasDVO)->DVO_CODPRO
						Replace DVO_SERVIC With (cAliasDVO)->DVO_SERVIC
						Replace DVO_CODPAS With (cAliasDVO)->DVO_CODPAS
						Replace DVO_EXCMIN With (cAliasDVO)->DVO_EXCMIN
						Replace DVO_PERMIN With (cAliasDVO)->DVO_PERMIN
						Replace DVO_INTERV With (cAliasDVO)->DVO_INTERV
						Replace DVO_PERAJU With (cAliasDVO)->DVO_PERAJU
						Replace DVO_CODNEG With (cAliasDVO)->DVO_CODNEG
						
                        DVO->( MsUnlock() )
						If lTM670GDVO
							ExecBlock('TM670GDVO',.F.,.F.)
						EndIf
						(cAliasDVO)->( DbSkip() )
					EndDo
					
					(cAliasDW2)->( DbGotop() )
					While (cAliasDW2)->( !Eof() )
						RecLock('DW2',.T.)//gravar o DW2
						Replace DW2_FILIAL With (cAliasDW2)->DW2_FILIAL
						Replace DW2_TABFRE With (cAliasDW2)->DW2_TABFRE
						Replace DW2_TIPTAB With (cAliasDW2)->DW2_TIPTAB
						Replace DW2_SEQTAB With aSeqTab[nAcols,1]
						Replace DW2_CODCLI With aCols[nAcols,1]
						Replace DW2_LOJCLI With aCols[nAcols,2]
						Replace DW2_CDRORI With (cAliasDW2)->DW2_CDRORI
						Replace DW2_CDRDES With (cAliasDW2)->DW2_CDRDES
						Replace DW2_CODPRO With (cAliasDW2)->DW2_CODPRO
						Replace DW2_SERVIC With (cAliasDW2)->DW2_SERVIC
						Replace DW2_CODPAS With (cAliasDW2)->DW2_CODPAS
						Replace DW2_ITEDVD With (cAliasDW2)->DW2_ITEDVD
						Replace DW2_ITEM   With (cAliasDW2)->DW2_ITEM
						Replace DW2_VALATE With (cAliasDW2)->DW2_VALATE
						Replace DW2_FATPES With (cAliasDW2)->DW2_FATPES
						Replace DW2_INTERV With (cAliasDW2)->DW2_INTERV
						Replace DW2_PERAJU With (cAliasDW2)->DW2_PERAJU
						Replace DW2_CODNEG With (cAliasDW2)->DW2_CODNEG
						
                        DW2->( MsUnlock() )
						If lTM670GDW2
							ExecBlock('TM670GDW2',.F.,.F.)
						EndIf
						(cAliasDW2)->( DbSkip() )
					EndDo

					// Calculo de Excedente por Subfaixa
					// Gravacao de Excedente por Sub-Faixas
					(cAliasDY2)->( DbGotop() )
					While (cAliasDY2)->( !Eof() )
						RecLock('DY2',.T.)//gravar o DY2
						Replace DY2_FILIAL With (cAliasDY2)->DY2_FILIAL
						Replace DY2_TABFRE With (cAliasDY2)->DY2_TABFRE
						Replace DY2_TIPTAB With (cAliasDY2)->DY2_TIPTAB
						Replace DY2_CDRORI With (cAliasDY2)->DY2_CDRORI
						Replace DY2_CDRDES With (cAliasDY2)->DY2_CDRDES
						Replace DY2_CODCLI With aCols[nAcols,1]
						Replace DY2_LOJCLI With aCols[nAcols,2]
						Replace DY2_SEQTAB With aSeqTab[nAcols,1]
						Replace DY2_CODPRO With (cAliasDY2)->DY2_CODPRO
						Replace DY2_SERVIC With (cAliasDY2)->DY2_SERVIC
						Replace DY2_CODPAS With (cAliasDY2)->DY2_CODPAS
						Replace DY2_ITEDVD With (cAliasDY2)->DY2_ITEDVD
						Replace DY2_ITEM   With (cAliasDY2)->DY2_ITEM
						Replace DY2_EXCMIN With (cAliasDY2)->DY2_EXCMIN
						Replace DY2_PERMIN With (cAliasDY2)->DY2_PERMIN
						Replace DY2_PERMAX With (cAliasDY2)->DY2_PERMAX
						Replace DY2_PERAJU With (cAliasDY2)->DY2_PERAJU
						Replace DY2_INTERV With (cAliasDY2)->DY2_INTERV
						Replace DY2_CODNEG With (cAliasDY2)->DY2_CODNEG
						
                        DY2->( MsUnlock() )
						If lTM670GDY2
							ExecBlock('TM670GDY2',.F.,.F.)
						EndIf
						(cAliasDY2)->( DbSkip() )
					EndDo

					// Gravacao de TDA
					(cAliasDWZ)->( DbGotop() )
					While (cAliasDWZ)->( !Eof() )
						RecLock('DWZ',.T.)//gravar o DWZ
						Replace DWZ_FILIAL With (cAliasDWZ)->DWZ_FILIAL
						Replace DWZ_TABFRE With (cAliasDWZ)->DWZ_TABFRE
						Replace DWZ_TIPTAB With (cAliasDWZ)->DWZ_TIPTAB
						Replace DWZ_SEQTAB With aSeqTab[nAcols,1]
						Replace DWZ_CODCLI With aCols[nAcols,1]
						Replace DWZ_LOJCLI With aCols[nAcols,2]
						Replace DWZ_CDRORI With (cAliasDWZ)->DWZ_CDRORI
						Replace DWZ_CDRDES With (cAliasDWZ)->DWZ_CDRDES
						Replace DWZ_CODPRO With (cAliasDWZ)->DWZ_CODPRO
						Replace DWZ_SERVIC With (cAliasDWZ)->DWZ_SERVIC
						Replace DWZ_CODPAS With (cAliasDWZ)->DWZ_CODPAS
						Replace DWZ_VLAJUS With (cAliasDWZ)->DWZ_VLAJUS
						Replace DWZ_CODNEG With (cAliasDWZ)->DWZ_CODNEG
						
                        DWZ->( MsUnlock() )
						If lTM670GDWZ
							ExecBlock('TM670GDWZ',.F.,.F.)
						EndIf
						(cAliasDWZ)->( DbSkip() )
					EndDo

					RecLock('DVC',.T.)
					Replace DVC_FILIAL With (cAliasDVC)->DVC_FILIAL
					Replace DVC_TABFRE With (cAliasDVC)->DVC_TABFRE
					Replace DVC_TIPTAB With (cAliasDVC)->DVC_TIPTAB
					Replace DVC_SEQTAB With aSeqTab[nAcols,1]
					Replace DVC_CODCLI With aCols[nAcols,1]
					Replace DVC_LOJCLI With aCols[nAcols,2]
					Replace DVC_CDRORI With (cAliasDVC)->DVC_CDRORI
					Replace DVC_CDRDES With (cAliasDVC)->DVC_CDRDES
					Replace DVC_CODPRO With (cAliasDVC)->DVC_CODPRO
					Replace DVC_SERVIC With (cAliasDVC)->DVC_SERVIC
					Replace DVC_CODNEG With (cAliasDVC)->DVC_CODNEG
					
                    DVC->( MsUnlock() )
					If lTM670GDVC
						ExecBlock('TM670GDVC',.F.,.F.)
					EndIf

				EndIf
			Next
			(cAliasDVC)->( DbSkip() )
			(cAliasDVD)->( DbCloseArea() )
			(cAliasDVO)->( DbCloseArea() )
			(cAliasDW2)->( DbCloseArea() )
			(cAliasDY2)->( DbCloseArea() )
		EndDo
		End Transaction
		(cAliasDVC)->( DbCloseArea() )
		
		lRet := .T.

   EndIf

	MsUnLockAll()		
EndIf

(cAliasNew)->( DbCloseArea() )

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA670Cop³ Autor ³Wellington A SAntos    ³ Data ³ 15.03.04   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do cliente na tela                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA670Cop()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Campo pra validar                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA670                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tms670Cop(cCampo)

Local lRet     := .T.
Local cCodCli  := ""
Local cLojCli  := ""
Local lValid   := .T.

If cCampo == "M->DVC_CODCLI"
	cCodCli := M->DVC_CODCLI
	cLojCli := GdFieldGet("DVC_LOJCLI",n)
	If Empty(cLojCli)
		lValid := .F.
	EndIf
ElseIf cCampo == "M->DVC_LOJCLI"
	cCodCli := GdFieldGet("DVC_CODCLI",n)
	cLojCli := M->DVC_LOJCLI
	If Empty(cCodCli)
		lValid := .F.
	EndIf
ElseIf cCampo == "M->DVC_SERVIC"
	cCodCli := GdFieldGet("DVC_CODCLI",n)
	cLojCli := M->DVC_LOJCLI
	If Empty(cCodCli)
		lValid := .F.
	EndIf
EndIf

If	lValid .And. Empty( TMSContrat(cCodCli, cLojCli, dDatabase, , .T. ,"1" , .F. , ,,,,,,,,,,,,,,"") ) ;
	.And. Empty( TMSContrat(cCodCli, cLojCli, dDatabase, , .F. ,"2" , .F. , ,,,,,,,,,,,,,,"") )
	lRet := .F.
EndIf

Return(lRet)
