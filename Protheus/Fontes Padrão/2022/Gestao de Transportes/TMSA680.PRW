#INCLUDE "TMSA680.CH"
#include "Protheus.ch"
#INCLUDE "DBTREE.CH"

Static lTMA010His := ExistBlock("TMA010HIS")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA680  ³ Autor ³ Marcelo Iuspa         ³ Data ³ 24.02.03   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclusao de Ajustes                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSA680()

Local aPosObj    := {} 
Local aObjects   := {}           
Local aCombo     := {STR0001,STR0002} //"Sim"###"Nao"
Local aCombo2    := {STR0014,STR0015} //'Ultima'###'Todas'

Local cCliente   := CriaVar("A1_COD",.F.)
Local cLoja      := CriaVar("A1_LOJA",.F.)
Local cTabela    := CriaVar("DVC_TABFRE",.F.)
Local cTipo      := CriaVar("DVC_TIPTAB",.F.)
Local cCdrOri    := CriaVar("DVC_CDRORI",.F.)
Local cCdrDes    := CriaVar("DVC_CDRDES",.F.)
Local cServico   := CriaVar("DVC_SERVIC",.F.)
Local cProduto   := CriaVar("B1_COD",.F.)
Local cCodNeg    := ""
Local cCombo     := ""
Local cCombo2    := ""
Local nCombo     := 0
Local nCombo2    := 0
Local nOpca	 	  := 0
Local lTMALogGrv := ExistBlock("TMALOGGRV")
Local oDlgExc
Local oCombo
Local oCombo2
Local oSize

Private cNomCli   := CriaVar("A1_NOME",.F.)
Private aHeader   := {}
Private aCols	   := {} 
Private aOriDes   := {}
Private lChgField := .F.
Private lBuildTree:= .F.

PutHelp("PTMSA68001",{"Erro na exclusão"},{"Error deleting "},{"Error en el borrado"},.F.)

// Variavel utilizada para nao realizar a Validacao do campo DVD_CODCLI (X3_WHEN) feita
// no Ajuste da Tabela de Frete
// NAO RETIRAR !!!
Private nOpcao  := 3

Inclui  := .T.

aRotina := {	{ STR0003, "AxPesqui", 0, 1 },; //"Pesquisar"
					{ STR0004, "AxVisual", 0, 2 },; //"Visualizar"
					{ STR0005, "AxInclui", 0, 3 },; //"Incluir"
					{ STR0006, "AxAltera", 0, 4 },; //"Alterar"
					{ STR0007, "AxExclui", 0, 5 }} //"Excluir"

cCodNeg := CriaVar("DDB_CODNEG",.F.)

oSize := FwDefSize():New( .T. )

oSize:lLateral     := .F.  // Calculo vertical

oSize:AddObject( "Enchoice", 100, 10, .T., .T. ) // Adiciona Enchoice

oSize:AddObject( "Tree", 100, 90, .T., .T. ) // Adiciona Tree

// Dispara o calculo
oSize:Process()

DEFINE MSDIALOG oDlgExc TITLE STR0008 From oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] Of oMainWnd PIXEL //"Exclusao de Ajustes"

	@ oSize:GetDimension("Enchoice","LININI"),oSize:GetDimension("Enchoice","COLINI") to oSize:GetDimension("Enchoice","LININI")+67,oSize:GetDimension("Enchoice","COLEND") OF oDlgExc PIXEL

	@ oSize:GetDimension("Enchoice","LININI")+5,oSize:GetDimension("Enchoice","COLINI")+008 SAY RetTitle("DVD_CODCLI") SIZE 50,7 OF oDlgExc PIXEL
	@ oSize:GetDimension("Enchoice","LININI")+5,oSize:GetDimension("Enchoice","COLINI")+039 MsGet cCliente PICTURE "@!" F3 "SA1" Valid TMSA680ChgField() .And. TMSA670Cli(cCliente,cLoja) SIZE 32,7 OF oDlgExc PIXEL	
	@ oSize:GetDimension("Enchoice","LININI")+5,oSize:GetDimension("Enchoice","COLINI")+077 SAY RetTitle("DVD_LOJCLI") SIZE 20,7 OF oDlgExc PIXEL
	@ oSize:GetDimension("Enchoice","LININI")+5,oSize:GetDimension("Enchoice","COLINI")+110 MsGet cLoja PICTURE "@!" Valid TMSA680ChgField() .And. TMSA670Cli(cCliente,cLoja) SIZE 20,7 OF oDlgExc PIXEL	
	@ oSize:GetDimension("Enchoice","LININI")+5,oSize:GetDimension("Enchoice","COLINI")+138 MsGet cNomCli  When .F. SIZE 105,7 OF oDlgExc PIXEL	
	
	@ oSize:GetDimension("Enchoice","LININI")+17,oSize:GetDimension("Enchoice","COLINI")+008 SAY RetTitle("DVC_TABFRE") SIZE 20,7 OF oDlgExc PIXEL
	@ oSize:GetDimension("Enchoice","LININI")+17,oSize:GetDimension("Enchoice","COLINI")+039 MsGet cTabela VALID TMSA680ChgField() .And. (Vazio(cTabela) .Or. ExistCpo("DVC",cTabela+AllTrim(cTipo),1)) PICTURE "@!" F3 "DTL" SIZE 32,7 OF oDlgExc PIXEL	
	@ oSize:GetDimension("Enchoice","LININI")+17,oSize:GetDimension("Enchoice","COLINI")+077 SAY RetTitle("DVD_TIPTAB") SIZE 30,7 OF oDlgExc PIXEL
	@ oSize:GetDimension("Enchoice","LININI")+17,oSize:GetDimension("Enchoice","COLINI")+110 MsGet cTipo  VALID TMSA680ChgField() .And. (Vazio(cTipo) .Or. ExistCpo("DVC",cTabela+cTipo,1)) PICTURE "@!" SIZE 20,7 OF oDlgExc PIXEL			
	@ oSize:GetDimension("Enchoice","LININI")+17,oSize:GetDimension("Enchoice","COLINI")+138 MsGet Tabela("M5", cTipo, .F.) When .F. SIZE 105,7 OF oDlgExc PIXEL	
	
	@ oSize:GetDimension("Enchoice","LININI")+29,oSize:GetDimension("Enchoice","COLINI")+008 SAY RetTitle("DVC_REGORI") SIZE 50,7 OF oDlgExc PIXEL
	@ oSize:GetDimension("Enchoice","LININI")+29,oSize:GetDimension("Enchoice","COLINI")+039 MsGet cCdrOri VALID TMSA680ChgField() .And. Vazio(cCdrOri) .Or. ExistCpo("DUY",cCdrOri) PICTURE "@!" F3 "DUY" SIZE 32,7 OF oDlgExc PIXEL			
	@ oSize:GetDimension("Enchoice","LININI")+29,oSize:GetDimension("Enchoice","COLINI")+077 MsGet Posicione("DUY",1,xFilial("DUY")+cCdrOri,"DUY_DESCRI") When .F. SIZE 090,7 OF oDlgExc PIXEL			
	@ oSize:GetDimension("Enchoice","LININI")+29,oSize:GetDimension("Enchoice","COLINI")+175 SAY RetTitle("DVC_REGDES") SIZE 50,7 OF oDlgExc PIXEL
	@ oSize:GetDimension("Enchoice","LININI")+29,oSize:GetDimension("Enchoice","COLINI")+208 MsGet cCdrDes VALID TMSA680ChgField() .And. Vazio(cCdrDes) .Or. ExistCpo("DUY",cCdrDes) PICTURE "@!" F3 "DUY" SIZE 32,7 OF oDlgExc PIXEL			
	@ oSize:GetDimension("Enchoice","LININI")+29,oSize:GetDimension("Enchoice","COLINI")+242 MsGet Posicione("DUY",1,xFilial("DUY")+cCdrDes,"DUY_DESCRI")  When .F. SIZE 090,7 OF oDlgExc PIXEL			
	
	@ oSize:GetDimension("Enchoice","LININI")+41,oSize:GetDimension("Enchoice","COLINI")+008 SAY RetTitle("DVC_SERVIC") SIZE 50,7 OF oDlgExc PIXEL
	@ oSize:GetDimension("Enchoice","LININI")+41,oSize:GetDimension("Enchoice","COLINI")+039 MsGet cServico VALID TMSA680ChgField() .And. Vazio(cServico) .Or. ExistCpo("DC5",cServico) PICTURE "@!" F3 "DC5" SIZE 32,7 OF oDlgExc PIXEL			
	@ oSize:GetDimension("Enchoice","LININI")+41,oSize:GetDimension("Enchoice","COLINI")+077 MsGet Tabela("L4", cServico, .F.) When .F. SIZE 090,7 OF oDlgExc PIXEL									
	@ oSize:GetDimension("Enchoice","LININI")+41,oSize:GetDimension("Enchoice","COLINI")+175 SAY RetTitle("DVC_CODPRO") SIZE 50,7 OF oDlgExc PIXEL
	@ oSize:GetDimension("Enchoice","LININI")+41,oSize:GetDimension("Enchoice","COLINI")+208 MsGet cProduto VALID TMSA680ChgField() .And. Vazio(cProduto) .Or. ExistCpo("SB1",cProduto)PICTURE "@!" F3 "SB1" SIZE 55,7 OF oDlgExc PIXEL			
	@ oSize:GetDimension("Enchoice","LININI")+41,oSize:GetDimension("Enchoice","COLINI")+268 MsGet Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")  When .F. SIZE 090,7 OF oDlgExc PIXEL							

	@ 54,366 SAY RetTitle("DVC_CODNEG") SIZE 50,7 OF oDlgExc PIXEL
	@ 54,400 MsGet cCodNeg VALID TMSA680ChgField() .And. (Vazio(cCodNeg) .Or. ExistCpo("DDB",cCodNeg)) PICTURE "@!" F3 "DDB" SIZE 20,7 OF oDlgExc PIXEL			
	@ 54,428 MsGet Posicione("DDB",1,xFilial("DDB") + cCodNeg,"DDB_DESCRI")  When .F. SIZE 090,7 OF oDlgExc PIXEL							
	
	@ oSize:GetDimension("Enchoice","LININI")+53,oSize:GetDimension("Enchoice","COLINI")+008 SAY STR0009 SIZE 50,7 OF oDlgExc PIXEL //"Variantes"
	@ oSize:GetDimension("Enchoice","LININI")+53,oSize:GetDimension("Enchoice","COLINI")+039 MSCOMBOBOX oCombo VAR cCombo ITEMS aCombo Valid TMSA680ChgField() SIZE 32 ,7 OF oDlgExc PIXEL	
	Eval(oCombo:bChange := {|| nCombo := oCombo:nAt})

	@ oSize:GetDimension("Enchoice","LININI")+53,oSize:GetDimension("Enchoice","COLINI")+175 SAY STR0016 SIZE 50,7 OF oDlgExc PIXEL // 'Sequência' 
	@ oSize:GetDimension("Enchoice","LININI")+53,oSize:GetDimension("Enchoice","COLINI")+208 MSCOMBOBOX oCombo2 VAR cCombo2 ITEMS aCombo2 Valid TMSA680ChgField() SIZE 32 ,7 OF oDlgExc PIXEL	
	Eval(oCombo2:bChange := {|| nCombo2 := oCombo2:nAt})

	DEFINE SBUTTON oBtn  FROM oSize:GetDimension("Enchoice","LININI")+53, oSize:GetDimension("Enchoice","COLINI")+100  TYPE 15 ACTION ( TMSA680Tree(cCliente,cLoja,cTabela,cTipo,cCdrOri,cCdrDes,cServico,cProduto,nCombo, .T., nCombo2, cCodNeg) ) ENABLE OF oDlgExc PIXEL

	oTree:= dbTree():New(oSize:GetDimension("Enchoice","LININI")+70,oSize:GetDimension("Tree","COLINI"),oSize:GetDimension("Tree","LINEND"),oSize:GetDimension("Tree","COLEND"),oDlgExc,,,.T.)

ACTIVATE MSDIALOG oDlgExc ON INIT EnchoiceBar(oDlgExc,{|| nOpcA := 1, If(TMSA680Ok(cCliente,cLoja,cTabela,cTipo),oDlgExc:End(),nOpcA := 0)},{||oDlgExc:End()})			
	
If ( nOpcA == 1 ) 
	Processa({ || TMSA680Excl(cCliente,cLoja,cTabela,cTipo,cCdrOri,cCdrDes,cServico,cProduto,nCombo,nCombo2,cCodNeg) })
	If lTMALogGrv
		//-- Ponto de entrada comum entre todas as rotinas que manipulam tabela de frete e ajustes.
		//-- O ponto tem o objetivo de possibilitar a criacao de um LOG informando o  usuario  e  a
		//-- operação que foi realizada em uma tabela de frete ou ajuste de cliente.
		ExecBlock("TMALOGGRV",.F.,.F.,{ "DVC", "5",cUserName, 0 })
	EndIf				
EndIf

MsUnlockAll()
	
dbSelectArea("DVC")
dbSetOrder(1)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA680Excl  ³ Autor ³Marcelo Iuspa           ³ Data ³ 24/02/2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a delecao                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA680Excl(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,ExpC7,ExpC8,ExpC9 ³±±
±±³          ³            ExpCA,ExpCB)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo do Cliente                                         ³±±
±±³          ³ExpC2 - Loja do Cliente                                           ³±±
±±³          ³ExpC3 - Tabela                                                    ³±±
±±³          ³ExpC4 - Tipo da Tabela                                            ³±±
±±³          ³ExpC5 - Regiao de Origem                                          ³±± 
±±³          ³ExpC6 - Regiao de Destino                                         ³±±
±±³          ³ExpC7 - Codigo do Servico                                         ³±±
±±³          ³ExpC8 - Codigo do Produto                                         ³±±
±±³          ³ExpC9 - Combo Variantes                                           ³±±
±±³          ³ExpCA - Combo Sequencia                                           ³±±
±±³          ³ExpCB - Codigo da Negociacao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA680                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function TMSA680Excl(cCliente,cLoja,cTabela,cTipo,cCdrOri,cCdrDes,cServico,cProduto,nCombo,nCombo2,cCodNeg)

Local lGravou    := .T.
Local cQuery     := ""
Local cSqlOri    :=""
Local cSqlDes    := ""
Local cAliasNew  := ""
Local aOrigem    := {}
Local aDestino   := {}
Local lContHis   := GetMv("MV_CONTHIS",.F.,.T.) //-- Controla Historico da Tabela de Frete
Local _nCount    := 0
Local lAux       := .T.

Default cCodNeg := ""

//-- O Objetivo deste Ponto de Entrada, e' validar se sera' permitido Alterar/Excluir (independente
//-- do conteudo do parametro MV_CONTHIS).
If lTMA010His
	lAux := ExecBlock("TMA010HIS",.F.,.F.,{5,cTabela,cTipo}) 
	If ValType(lAux) <> "L"
		lAux :=.T.
	EndIf   
	lContHis := lAux
EndIf   

If !Empty(cCdrOri)
	TmsNivInf(cCdrOri,@aOrigem,,.T.)    
EndIf
If !Empty(cCdrOri)
	Aadd(aOrigem,{cCdrOri})		//adiciona a regiao digitada
Endif
If nCombo == 1 .And. !Empty(cCdrDes)
	TmsNivInf(cCdrDes,@aDestino,,.T.)    
EndIf
If !Empty(cCdrDes)
	Aadd(aDestino,{cCdrDes})			
Endif	
If !Empty(cCdrOri)
	For _nCount := 1 To Len(aOrigem)
	   cSqlOri += "'" + aOrigem [_nCount][1] + "',"
	Next
	cSqlOri := Substr(cSqlOri,1,Len(cSqlOri) - 1)
EndIf
If !Empty(cCdrDes)
	For _nCount := 1 To Len(aDestino)
	   cSqlDes += "'" + aDestino [_nCount][1] + "',"
	Next
	cSqlDes := Substr(cSqlDes,1,Len(cSqlDes) - 1)
EndIf

cAliasNew := GetNextAlias() 
cQuery := " SELECT DVC_CDRORI,DVC_CDRDES,DVC_CODPRO,DVC_SERVIC "
If nCombo2 == 1
	cQuery += ", MAX(DVC_SEQTAB) DVC_SEQTAB "
Else
	cQuery += ", DVC_SEQTAB "
EndIf
cQuery += " FROM " + RetSqlName( "DVC" )  + " DVC "
cQuery += " WHERE "
cQuery += " DVC.DVC_FILIAL = '" + xFilial( "DVC" ) + "'"
cQuery += "   AND DVC.DVC_TABFRE = '" + cTabela + "'"
cQuery += "   AND DVC.DVC_TIPTAB = '" + cTipo + "'"
cQuery += "   AND DVC.DVC_CODCLI = '" + cCliente + "'"
cQuery += "   AND DVC.DVC_LOJCLI = '" + cLoja+ "'"
If !Empty(cSqlOri)
	cQuery += "   AND DVC.DVC_CDRORI IN (" + cSqlOri + ")"
EndIf
If !Empty(cSqlDes)
	cQuery += "   AND DVC.DVC_CDRDES IN (" + cSqlDes + ")"
EndIf
If !Empty(cProduto)
	cQuery += " AND DVC.DVC_CODPRO = '"  + cProduto + "'"
EndIf
If !Empty(cServico)
	cQuery += "  AND DVC.DVC_SERVIC = '" + cServico + "'"
EndIf
If !Empty(cCodNeg)
	cQuery += "  AND DVC.DVC_CODNEG = '" + cCodNeg + "'"
EndIf
cQuery += "   AND D_E_L_E_T_ = ' '"

//-- Se Controlar Historico de Tabela, nao pode excluir Tabelas que ja' foram
//-- utilizadas por CTRC's 
If lContHis 
	cQuery += "    AND NOT EXISTS ( "
	cQuery += " SELECT DT8_TABFRE, DT8_TIPTAB, DT8_CDRORI, DT8_CDRDES, DT8_SEQTAB FROM "
	cQuery += "  "+RetSqlName('DT8') + " DT8 "
	cQuery += "  WHERE DT8.DT8_FILIAL  = '"+xFilial("DT8")+"'"
	cQuery += "    AND DT8.DT8_TABFRE  = DVC.DVC_TABFRE 
	cQuery += "    AND DT8.DT8_TIPTAB  = DVC.DVC_TIPTAB 
	cQuery += "    AND DT8.DT8_CDRORI  = DVC.DVC_CDRORI 
	cQuery += "    AND DT8.DT8_CDRDES  = DVC.DVC_CDRDES		
	cQuery += "    AND DT8.DT8_SEQTAB  = DVC.DVC_SEQTAB		
	cQuery += "    AND DT8.D_E_L_E_T_  = ' ' )"				   								
EndIf
	
If nCombo2 == 1
	cQuery += " GROUP BY DVC_CDRORI,DVC_CDRDES,DVC_CODPRO,DVC_SERVIC "
Else
	cQuery += " GROUP BY DVC_CDRORI,DVC_CDRDES,DVC_CODPRO,DVC_SERVIC,DVC_SEQTAB "
EndIf
cQuery := ChangeQuery( cQuery )   
	
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. ) 
	      
  Begin Transaction
  (cAliasNew)-> ( dbGoTop() )	
	While (cAliasNew)-> ( !Eof() )
		If lGravou
			lGravou := TmsA680Exp( 'DVC', cCliente,cLoja,cTabela, cTipo, (cAliasNew)->DVC_CODPRO,(cAliasNew)->DVC_SERVIC,(cAliasNew)->DVC_SEQTAB,(cAliasNew)->DVC_CDRORI,(cAliasNew)->DVC_CDRDES,cCodNeg )
			lGravou := TmsA680Exp( 'DVD', cCliente,cLoja,cTabela, cTipo, (cAliasNew)->DVC_CODPRO,(cAliasNew)->DVC_SERVIC,(cAliasNew)->DVC_SEQTAB,(cAliasNew)->DVC_CDRORI,(cAliasNew)->DVC_CDRDES,cCodNeg )
			lGravou := TmsA680Exp( 'DVO', cCliente,cLoja,cTabela, cTipo, (cAliasNew)->DVC_CODPRO,(cAliasNew)->DVC_SERVIC,(cAliasNew)->DVC_SEQTAB,(cAliasNew)->DVC_CDRORI,(cAliasNew)->DVC_CDRDES,cCodNeg )
			lGravou := TmsA680Exp( 'DWZ', cCliente,cLoja,cTabela, cTipo, (cAliasNew)->DVC_CODPRO,(cAliasNew)->DVC_SERVIC,(cAliasNew)->DVC_SEQTAB,(cAliasNew)->DVC_CDRORI,(cAliasNew)->DVC_CDRDES,cCodNeg )
			lGravou := TmsA680Exp( 'DW2', cCliente,cLoja,cTabela, cTipo, (cAliasNew)->DVC_CODPRO,(cAliasNew)->DVC_SERVIC,(cAliasNew)->DVC_SEQTAB,(cAliasNew)->DVC_CDRORI,(cAliasNew)->DVC_CDRDES,cCodNeg )
			lGravou := TmsA680Exp( 'DY2', cCliente,cLoja,cTabela, cTipo, (cAliasNew)->DVC_CODPRO,(cAliasNew)->DVC_SERVIC,(cAliasNew)->DVC_SEQTAB,(cAliasNew)->DVC_CDRORI,(cAliasNew)->DVC_CDRDES,cCodNeg )
			If AliasInDic("DJT")
				lGravou := TmsA680Exp( 'DJT', cCliente,cLoja,cTabela, cTipo, (cAliasNew)->DVC_CODPRO,(cAliasNew)->DVC_SERVIC,(cAliasNew)->DVC_SEQTAB,(cAliasNew)->DVC_CDRORI,(cAliasNew)->DVC_CDRDES,cCodNeg )
			EndIf
		EndIf
		(cAliasNew)-> ( DbSkip() )
	EndDo
	cQuery  := ""
End Transaction

(cAliasNew)->( DbCloseArea() )

Return(lGravou)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA680ChgField³ Autor ³Marcelo Iuspa         ³ Data ³ 24/02/2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao para TODOS os campos e determina se foi editado         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA680ChgField                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA680                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function TMSA680ChgField()

lChgField := .T.

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA680Tree³ Autor ³ Marcelo Iuspa        ³ Data ³ 24.02.03   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Replica dos ajustes                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA680Tree()                                                ³±±
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
±±³          ³ ExpCA - Codigo da Negociacao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA680                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TMSA680Tree(cCliente,cLoja,cTabela,cTipo,cCdrOri,cCdrDes,cServico,cProduto,nCombo, lUpdTree, nCombo2, cCodNeg)

Local aOrigem   := {}
Local aDestino  := {}
Local nX        := 0
Local nY        := 0 
Local cQuery    := ''
Local cNomCli   := ''
Local cTexto    := ''
Local cSeqTab   := ''
Local cAliasQry := ''
Local cAliasNew := ''

DEFAULT nCombo2 := 1
DEFAULT cCodNeg := ""

aOriDes    := {}
lBuildTree := .T.
lChgField  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega na memoria os campos da tabela original          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("DVC")
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega na memoria os campos da tabela original          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nCombo == 1 .And. !Empty(cCdrOri)
	TmsNivInf(cCdrOri,@aOrigem,,.T.)    
	If Len(aOrigem) == 0
		Aadd(aOrigem,{cCdrOri})		
	EndIf		
ElseIf Empty(cCdrOri)
	Tmsa670Ori(cTabela,cTipo,@aOrigem,cCliente,cLoja)
Else
	Aadd(aOrigem,{cCdrOri})		
Endif
	
If nCombo == 1 .And. !Empty(cCdrDes)
	TmsNivInf(cCdrDes,@aDestino,,.T.)    
	If Len(aDestino) == 0
		Aadd(aDestino,{cCdrDes})			
	EndIf		
ElseIf Empty(cCdrDes)	                
	Tmsa670Des(cTabela,cTipo,@aDestino,cCliente,cLoja)	
Else
	Aadd(aDestino,{cCdrDes})			
Endif	

cAliasQry := GetNextAlias() 

cQuery := " SELECT DVC_FILIAL , DVC_CODCLI , DVC_LOJCLI , DVC_CDRORI , DVC_CDRDES , DVC_TABFRE , DVC_TIPTAB, DVC_SERVIC, DVC_CODPRO, "
If nCombo2 = 1
	cQuery += " MAX(DVC_SEQTAB) DVC_SEQTAB, MAX(R_E_C_N_O_) R_E_C_N_O_  "
Else
	cQuery += " DVC_SEQTAB, R_E_C_N_O_  "
EndIf

cQuery += " FROM " + RetSqlName( "DVC" ) + " DVC "
cQuery += "WHERE "
cQuery += "DVC_FILIAL = '" + xFilial( "DVC" ) + "' AND "
If !Empty(cTabela)
	cQuery += "DVC_TABFRE = '" + cTabela  + "' AND "			
EndIf
If !Empty(cTipo)
	cQuery += "DVC_TIPTAB = '" + cTipo    + "' AND "
EndIf
If !Empty(cCdrOri)
	cQuery += "DVC_CDRORI = '" + cCdrOri  + "' AND "
EndIf
If !Empty(cCdrDes)
	cQuery += "DVC_CDRDES = '" + cCdrDes  + "' AND "
EndIf
If ! Empty(cServico)
	cQuery += "DVC_SERVIC = '" + cServico + "' AND "
Endif
	
If ! Empty(cProduto)
	cQuery += " DVC_CODPRO = '" + cProduto + "' AND "
Endif

If ! Empty(cCodNeg)
	cQuery += " DVC_CODNEG = '" + cCodNeg + "' AND "
Endif

cQuery += "DVC_CODCLI = '" + cCliente + "' AND "
cQuery += "DVC_LOJCLI = '" + cLoja    + "' AND "
cQuery += "DVC.D_E_L_E_T_ = ' '"     
cQuery += " GROUP BY DVC_FILIAL , DVC_CODCLI , DVC_LOJCLI , DVC_CDRORI , DVC_CDRDES , DVC_TABFRE , DVC_TIPTAB , DVC_SERVIC, DVC_CODPRO

If nCombo2 = 2
	cQuery += ", DVC_SEQTAB, R_E_C_N_O_"   
EndIf

cQuery := ChangeQuery( cQuery )   

dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. ) 
cQuery := ""

(cAliasQry)->( dbGoTop() )

DT6->(dbSetOrder(3))

If (! nCombo == 1) .Or. (Len(aOrigem) + Len(aDestino) == 0)
	Do While (cAliasQry)->( ! Eof() )
		If ( (!Empty(cCdrOri) .And. cCdrOri == (cAliasQry)->DVC_CDRORI) .Or. Empty(cCdrOri) ) .And.;	
			( (!Empty(cCdrDes) .And. cCdrDes == (cAliasQry)->DVC_CDRDES) .Or. Empty(cCdrDes) )	   
			TMSAOriDes(cAliasQry)
		EndIf	
		(cAliasQry)-> ( dbSkip() )
	Enddo		
Else
	For nX := 1 to Len(aOrigem)
		For nY := 1 to Len(aDestino)

			cAliasNew := GetNextAlias() 
			If nCombo2 = 1
				cQuery := "SELECT MAX(DVC_SEQTAB) DVC_SEQTAB FROM " + RetSqlName( "DVC" )
			Else
				cQuery := "SELECT DVC_SEQTAB FROM " + RetSqlName( "DVC" )
			EndIf 
			cQuery += " WHERE "
			cQuery += "DVC_FILIAL = '" + xFilial( "DVC" ) + "' AND "
			cQuery += "DVC_CODCLI = '" + cCliente + "' AND "
			cQuery += "DVC_LOJCLI = '" + cLoja    + "' AND "
      		cQuery += "DVC_CDRORI = '" + aOrigem [nX][1] + "' AND "
      		cQuery += "DVC_CDRDES = '" + aDestino[nY][1] + "' AND "
			If !Empty(cTabela)
				cQuery += "DVC_TABFRE='" + cTabela  + "' AND "			
			EndIf
			If !Empty(cTipo)
				cQuery += "DVC_TIPTAB='" + cTipo    + "' AND "
			EndIf
			If ! Empty(cServico)
				cQuery += "DVC_SERVIC = '" + cServico + "' AND "
			Endif
			
			If ! Empty(cProduto)
				cQuery += " DVC_CODPRO = '" + cProduto + "' AND "
			Endif
	
			If ! Empty(cCodNeg)
				cQuery += " DVC_CODNEG = '" + cCodNeg + "' AND "
			Endif
	
			cQuery += "D_E_L_E_T_ = ' '"     
			cQuery := ChangeQuery( cQuery )   

			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. ) 
	
			cSeqTab := Iif ( (cAliasNew)->( !Eof() ) ,  (cAliasNew)->DVC_SEQTAB , "01" )
			(cAliasNew)->( DbCloseArea() )
			cQuery  := ""
			If nCombo2 = 1
				While !(cAliasQry)->(Eof()) 
						If xFilial("DVC") + cCliente+cLoja+aOrigem[nX][1]+aDestino[nY][1]+cTabela+cTipo+cSeqTab == ;
							(cAliasQry)->(DVC_FILIAL+DVC_CODCLI+DVC_LOJCLI+DVC_CDRORI+DVC_CDRDES+DVC_TABFRE+DVC_TIPTAB+DVC_SEQTAB)
							TMSAOriDes(cAliasQry)
						EndIf
					(cAliasQry)->(dbSkip())
				EndDo
			Else
				While !(cAliasQry)->(Eof()) .And. xFilial("DVC") + cCliente+cLoja+aOrigem[nX][1]+aDestino[nY][1]+cTabela+cTipo == ;
						(cAliasQry)->(DVC_FILIAL+DVC_CODCLI+DVC_LOJCLI+DVC_CDRORI+DVC_CDRDES+DVC_TABFRE+DVC_TIPTAB)
					TMSAOriDes(cAliasQry, nCombo2)
					(cAliasQry)->(dbSkip())
				EndDo
			EndIf				
		Next
	Next			
Endif
(cAliasQry)->( DbCloseArea())

DT6->(dbSetOrder(1))

If lUpdTree == Nil .Or. lUpdTree
	oTree:BeginUpdate()
	oTree:Reset()
	oTree:EndUpdate()
	oTree:BeginUpdate()

	If ExistFunc('FWPDCanUse') .And. FWPDCanUse()
		If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"A1_NOME"} )) > 0		
			cNomCli := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NOME")
		Else				
			cNomCli := Replicate('*',TamSX3('A1_NOME')[1])
		EndIf	
	Else	
		cNomCli := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NOME")
	EndIf

	cTexto  := PadR('Cliente : '+cCliente+'/'+cLoja + '-'+cNomCli, 150)
	
	oTree:AddItem( cTexto, Padr('0MA-MAINGR', 40), 'FOLDER5','FOLDER6',,,2) //'Tabela de Frete
	
	dbEndTree oTree
	
	oTree:EndUpdate()
	oTree:Refresh()
	
	DUY->(dbSetOrder(1))
	
	For nX := 1 to Len(aOriDes)
		dbSelectArea("DVC")
		dbGoto(aOriDes[nX, 7])
		TMA680Monta( oTree, aOriDes[nX, 6] )
	Next		
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSAOriDes     ³ Autor ³Marcelo Iuspa         ³ Data ³ 24/02/2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Adiciona/Atualiza Array com ultima sequencia tabela (DVC_SEQTAB)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSAOriDes                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum (Usa o array PRIVATE aOriDes)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA680                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function TMSAOriDes(cAliasQry, nCombo2)

Local nSeek := aScan(aOriDes, {|z| z[1] + z[2] + z[3] + z[4] == (cAliasQry)->(DVC_CDRORI + DVC_CDRDES + DVC_SERVIC + DVC_CODPRO) } )
Local lAtu  := .F.

Default nCombo2 := 0

If nCombo2 == 2
	nSeek := aScan(aOriDes, {|z| z[1] + z[2] + z[3] + z[4] + z[5] == (cAliasQry)->(DVC_CDRORI + DVC_CDRDES + DVC_SERVIC + DVC_CODPRO + DVC_SEQTAB) } )
EndIf             
If nSeek == 0
	Aadd(aOriDes, {(cAliasQry)->DVC_CDRORI ,(cAliasQry)->DVC_CDRDES ,(cAliasQry)->DVC_SERVIC ,(cAliasQry)->DVC_CODPRO ,(cAliasQry)->DVC_SEQTAB , .F., (cAliasQry)->R_E_C_N_O_ } )
	lAtu  := .T.
	nSeek := Len(aOriDes)
Endif
If (cAliasQry)->(DVC_SEQTAB )> aOriDes[nSeek, 5]
	aOriDes[nSeek, 5] := (cAliasQry)->(DVC_SEQTAB)
	lAtu              := .T.
	aOriDes[nSeek, 7] := RecNo()
Endif	
If lAtu
	aOriDes[nSeek, 6] := DT6->(MsSeek(xFilial("DT6")+(cAliasQry)->(DVC_TABFRE+DVC_TIPTAB+DVC_SEQTAB+DVC_CDRORI+DVC_CDRDES+DVC_CODCLI+DVC_LOJCLI)))
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMA680Monta ³ Autor ³Marcelo Iuspa       ³ Data ³24.02.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o tree.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA680Monta(ExpO1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto Tree                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function TMA680Monta( oTree, lNoDel )

Local cCargo   := "01" + DVC->DVC_CDRORI 
Local cDesc    := ""
Local cFolder1 := If(lNoDel == Nil .Or. ! lNoDel, "FOLDER5", "FOLDER7")
Local cFolder2 := If(lNoDel == Nil .Or. ! lNoDel, "FOLDER6", "FOLDER8")

oTree:TreeSeek( Padr('0MA-MAINGR', 40) )

DUY->( DbSetOrder( 1 ) )
DUY->( MsSeek( xFilial('DUY') + DVC->DVC_CDRORI ) )

If ! oTree:TreeSeek(cCargo)
	DUY->( MsSeek( xFilial('DUY') + DVC->DVC_CDRORI ) )
	//-- Monta a descricao da pasta.
	cDesc:= Pad( DVC_CDRORI  + '-' + Capital( DUY->DUY_DESCRI ), 150 )
	oTree:AddItem( cDesc, cCargo,'FOLDER5','FOLDER6',,,2)
	oTree:TreeSeek( cCargo )
Endif

DUY->( MsSeek( xFilial('DUY') + DVC->DVC_CDRDES))

cCargo := "02" + DVC->DVC_CDRORI+DVC->DVC_CDRDES
cDesc  := AllTrim( DVC->DVC_CDRDES + '-' + Capital( DUY->DUY_DESCRI ))

If ! oTree:TreeSeek(cCargo)
	oTree:AddItem( Pad(cDesc, 150), cCargo,'FOLDER5','FOLDER6',,,2)
	oTree:TreeSeek( cCargo )
Endif	

If !Empty(DVC->DVC_CODPRO)
	cDesc += '  /  ' + STR0011 + AllTrim(Posicione("SB1",1,xFilial("SB1")+ DVC->DVC_CODPRO,"B1_DESC")) //'Produto : '
EndIf

If !Empty(DVC->DVC_SERVIC)
	cDesc += '  /  ' + STR0012 + AllTrim(Tabela("L4", DVC->DVC_SERVIC, .F.)) //'Servico : '
EndIf
		
If !Empty(DVC->DVC_CODNEG)
	cDesc += '  /  ' + STR0017 + AllTrim(Posicione("DDB",1,xFilial("DDB")+ DVC->DVC_CODNEG,"DDB_DESCRI")) //'Negociação : '
EndIf
		
cCargo := '02' + DVC->DVC_CDRORI

cCargo := "02" + DVC->DVC_CDRORI+DVC->DVC_CDRDES

cCargo += DVC_SEQTAB
cDesc  += '  /  ' + STR0013 + DVC->DVC_SEQTAB //'Sequencia : '

oTree:AddItem( Pad(cDesc, 150), cCargo,cFolder1,cFolder2,,,2)

oTree:EndUpdate()
oTree:TreeSeek( '0MA-MAINGR' )
oTree:Refresh()

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA680Ok ³ Autor ³ Marcelo Iuspa         ³ Data ³ 24.02.03   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do final da tela                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA680Ok()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Codigo do cliente                                    ³±±
±±³          ³ ExpC2 : Loja                                                 ³±±
±±³          ³ ExpC3 : Tabela                                               ³±±
±±³          ³ ExpC4 : Tipo da Tabela                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA680                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tmsa680Ok(cCliente,cLoja,cTabela,cTipo)

Local lRet := .T.

If Empty(cCliente) .Or. Empty(cLoja) .Or. Empty(cTabela) .Or. Empty(cTipo)
	Help(" ",1,"OBRIGAT") //Um ou alguns campos obrigatórios nao foram preenchidos.xxxxxxxxxxxxxxxxxx -> xxxxxxxxxx Pasta
	lRet := .F.	
Endif	

Return(lRet)                                    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa680Exp ³ Autor ³Wellington A Santos ³ Data ³08/03/2004  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exclui via query ajustes de um cliente                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TmsA680Exp()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Alias                                               ³±±
±±³          ³ExpC2 - Cliente Origem                                      ³±±
±±³          ³ExpC3 - Loja Origem                                         ³±±
±±³          ³ExpC4 - Tabela Origem                                       ³±±
±±³          ³ExpC5 - Tipo da tabela Origem                               ³±± 
±±³          ³ExpC6 - Produto Origem                                      ³±±
±±³          ³ExpC7 - Servico Origem                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA680                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA680Exp( cAlias, cCliOri,cLojOri,cTabOri, cTipOri, cProdOri,cSerOri,cSeqtab,cSqlOri,cSqlDes,cCodNeg)

Local cQuery
Local lRet   := .T.
Local cFilAlias := xFilial( cAlias )

DEFAULT cCodNeg := ""

cQuery := "UPDATE " + RetSqlName( cAlias ) + " SET D_E_L_E_T_ = '*' "
cQuery += " WHERE " + cAlias + "_FILIAL = '" + cFilAlias + "'"
cQuery += "   AND " + cAlias + "_TABFRE = '" + cTabOri + "'"
cQuery += "   AND " + cAlias + "_TIPTAB = '" + cTipOri + "'"
cQuery += "   AND " + cAlias + "_CODCLI = '" + cCliOri + "'"
cQuery += "   AND " + cAlias + "_LOJCLI = '" + cLojOri + "'"
cQuery += "   AND " + cAlias + "_CDRORI = '" + cSqlOri + "'"
cQuery += "   AND " + cAlias + "_CDRDES = '" + cSqlDes + "'"
cQuery += "   AND " + cAlias + "_SEQTAB = '" + cSeqTab + "'"
cQuery += "   AND " + cAlias + "_CODPRO = '" + cProdOri + "'"
cQuery += "   AND " + cAlias + "_SERVIC = '" + cSerOri + "'"

If !Empty(cCodNeg)
	cQuery += "   AND " + cAlias + "_CODNEG = '" + cCodNeg + "'"
EndIf

cQuery += "   AND D_E_L_E_T_ = ' '"
If TCSqlExec( cQuery ) <> 0
	Help(" ",1,"TMSA68001") //"Erro na exclusao"
	lRet := .F.
EndIf

Return lRet
