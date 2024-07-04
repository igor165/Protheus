#INCLUDE "TMSC040.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ TMSC040  บAutor  ณEduardo de Souza    บ Data ณ  12/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta Enderecamento                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TMS - Gestao de Transportes                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function TMSC040()

Local aHlpPor1    :=  {"Nใo existem dados para serem ","visualizados"}
Local aHlpIng1    :=  {"No data for be viewed "}
Local aHlpEsp1    :=  {"No existen datos para visualizar "}

//Ajuste de Novos Helps
PutHelp("PTMSC04001",aHlpPor1,aHlpIng1,aHlpEsp1,.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transao a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cCadastro := STR0001 //"Enderecamento"
Private aRotina	:= MenuDef()
					 			
DUH->(dbSetOrder(1))
mBrowse( 6,1,22,75,'DUH')

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMSC040Mnt บAutor  ณEduardo de Souza   บ Data ณ  12/05/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela "Consulta de Enderecamento"                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TMSC040                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function TMSC040Mnt(cAlias,nReg,nOpcx)

Local oDlg
Local oLbx1
Local cLbx1     := ''
Local aHEndere  := {}
Local aEndere   := {}
Local aSize     := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObjH  := {}
Local aButtons  := {}
Local nTotPeso  := 0
Local nTotQtVol := 0
Local nTotVal   := 0

MsgRun(STR0007,STR0008, {|| aEndere:= TMSC040End(@nTotPeso,@nTotQtVol,@nTotVal) } ) // "Verificando Enderecamento..." ### "Aguarde..."

If !Empty(aEndere)

	AAdd(aButtons,{'DEVOLNF', {|| TmsC040Dco(aEndere[oLbx1:nAt,1],aEndere[oLbx1:nAt,2],aEndere[oLbx1:nAt,3]) }, STR0006 , STR0012}) //"Documento"

	//-- Calcula as dimensoes dos objetos
	aSize := MsAdvSize( .T. )	
	AAdd(aObjects,{100,10,.T.,.T.,.T.}) //-- Horizontal superior
	AAdd(aObjects,{100,80,.T.,.T.,.T.}) //-- Horizontal central
	AAdd(aObjects,{100,10,.T.,.T.,.T.}) //-- Horizontal inferior
	aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObjH := MsObjSize(aInfo,aObjects,.T.,.F.)
	
	//-- Header do ListBox
	Aadd(aHEndere,Posicione('SX3',2,'DT6_FILDOC' ,'X3Titulo()'))
	Aadd(aHEndere,Posicione('SX3',2,'DT6_DOC'    ,'X3Titulo()'))
	Aadd(aHEndere,Posicione('SX3',2,'DT6_SERIE'  ,'X3Titulo()'))
	Aadd(aHEndere,Posicione('SX3',2,'DT6_PESO'   ,'X3Titulo()'))
	Aadd(aHEndere,Posicione('SX3',2,'DT6_QTDVOL' ,'X3Titulo()'))
	Aadd(aHEndere,Posicione('SX3',2,'DT6_VALMER' ,'X3Titulo()'))

	DEFINE MSDIALOG oDlg FROM aSize[7],00 TO aSize[6],aSize[5] TITLE cCadastro OF oMainWnd PIXEL

		@ aPosObjH[1,1]+06, 003 SAY STR0004 + "  : " COLOR CLR_HBLUE,CLR_WHITE Of oDlg PIXEL SIZE 56 ,9  //"Armazem" : "
		@ aPosObjH[1,1]+06, 040 SAY DUH->DUH_LOCAL Of oDlg PIXEL SIZE 50 ,9

		@ aPosObjH[1,1]+14 ,003 SAY STR0005 + " : " COLOR CLR_HBLUE,CLR_WHITE Of oDlg PIXEL SIZE 56 ,9 //"Endereco : "
		@ aPosObjH[1,1]+14 ,040 SAY DUH->DUH_LOCALI Of oDlg PIXEL SIZE 29 ,9

		@ aPosObjH[2,1], aPosObjH[2,2] LISTBOX oLbx1 VAR cLbx1 ;
											FIELDS HEADER   ;
												aHEndere[1], ;
												aHEndere[2], ;
												aHEndere[3], ;
												aHEndere[4], ;
												aHEndere[5], ;
												aHEndere[6] ;
											SIZE aPosObjH[2,3], aPosObjH[2,4] ;
											OF oDlg PIXEL ;
											ON DBLCLICK (TmsC040Dco(aEndere[oLbx1:nAt,1],aEndere[oLbx1:nAt,2],aEndere[oLbx1:nAt,3]))

		oLbx1:SetArray( aEndere )
		oLbx1:bLine := { || { 	aEndere[oLbx1:nAt,1], ;
								aEndere[oLbx1:nAt,2], ;
								aEndere[oLbx1:nAt,3], ;
								Transform(aEndere[oLbx1:nAt,4], PesqPict("DT6", "DT6_PESO"  )), ;
								Transform(aEndere[oLbx1:nAt,5], PesqPict("DT6", "DT6_QTDVOL")), ;
								Transform(aEndere[oLbx1:nAt,6], PesqPict("DT6", "DT6_VALMER")) }}	

		@ aPosObjH[3,1]+06, 003 SAY STR0009 + " : " COLOR CLR_HBLUE,CLR_WHITE Of oDlg PIXEL SIZE 56 ,9 //"Peso Total   : "
		@ aPosObjH[3,1]+06, 040 SAY AllTrim(Transform(nTotPeso, PesqPict("DT6", "DT6_PESO"))) Of oDlg PIXEL SIZE 50 ,9

		@ aPosObjH[3,1]+06 ,228 SAY STR0010 + " : " COLOR CLR_HBLUE,CLR_WHITE Of oDlg PIXEL SIZE 56 ,9  //"Qtd. Volume Total : "
		@ aPosObjH[3,1]+06 ,281 SAY AllTrim(Transform(nTotQtVol, PesqPict("DT6", "DT6_QTDVOL"))) Of oDlg PIXEL SIZE 29 ,9

		@ aPosObjH[3,1]+06 ,423 SAY STR0011 + " : " COLOR CLR_HBLUE,CLR_WHITE Of oDlg PIXEL SIZE 56 ,9  //"Valor Total  : "
		@ aPosObjH[3,1]+06 ,461 SAY AllTrim(Transform(nTotVal, PesqPict("DT6", "DT6_VALMER"))) Of oDlg PIXEL SIZE 29 ,9

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| oDlg:End() },{|| oDlg:End() },, aButtons )
Else
	Help(" ",1, "TMSC04001") //-- Nao existem dados para serem visualizados.
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMSC040End บAutor  ณEduardo de Souza   บ Data ณ  13/05/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Alimenta o Array de Enderecos                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ TMSC040End()                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TMSC040                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function TMSC040End(nTotPeso,nTotQtVol,nTotVal)

Local cQuery    := ''
Local cAliasQry := ''
Local cFilDoc   := ''
Local cDocto    := ''
Local cSerie    := ''
Local aEndere   := {}

nTotPeso  := 0
nTotQtVol := 0
nTotVal	 := 0

cAliasQry := GetNextAlias()
cQuery := " SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, "
cQuery += "   SUM(DUH_QTDVOL) DUH_QTDVOL, "
cQuery += "   MIN(DT6_QTDVOL) DT6_QTDVOL, "
cQuery += "   MIN(DT6_PESO) DT6_PESO, "
cQuery += "   MIN(DT6_VALMER) DT6_VALMER "
cQuery += "   FROM " + RetSqlName("DUH") + " DUH "
cQuery += "   JOIN " + RetSqlName("DTC") + " DTC "
cQuery += "     ON  DUH.DUH_FILIAL = '" + xFilial("DUH")  + "' "
cQuery += "     AND DUH.DUH_LOCAL  = '" + DUH->DUH_LOCAL  + "' "
cQuery += "     AND DUH.DUH_LOCALI = '" + DUH->DUH_LOCALI + "' "
cQuery += "     AND DUH.D_E_L_E_T_ = ' ' "
cQuery += "     AND DTC.DTC_FILIAL = '" + xFilial("DTC") + "' "
cQuery += "     AND DTC.DTC_NUMNFC = DUH.DUH_NUMNFC "
cQuery += "     AND DTC.DTC_SERNFC = DUH.DUH_SERNFC "	
cQuery += "     AND DTC.DTC_CLIREM = DUH.DUH_CLIREM "
cQuery += "     AND DTC.DTC_LOJREM = DUH.DUH_LOJREM "
cQuery += "     AND DTC.D_E_L_E_T_ = ' ' "
cQuery += "     JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += "       ON  DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "       AND DT6.DT6_FILDOC = DTC.DTC_FILDOC "
cQuery += "       AND DT6.DT6_DOC    = DTC.DTC_DOC "
cQuery += "       AND DT6.DT6_SERIE  = DTC.DTC_SERIE "
cQuery += "       AND DT6.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY DT6_FILDOC, DT6_DOC, DT6_SERIE "
cQuery += " UNION"
cQuery += " SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, "
cQuery += "   SUM(DUH_QTDVOL) DUH_QTDVOL, "
cQuery += "   MIN(DT6_QTDVOL) DT6_QTDVOL, "
cQuery += "   MIN(DT6_PESO) DT6_PESO, "
cQuery += "   MIN(DT6_VALMER) DT6_VALMER "
cQuery += "   FROM " + RetSqlName("DUH") + " DUH "
cQuery += "   JOIN " + RetSqlName("DY4") + " DY4 "
cQuery += "     ON  DUH.DUH_FILIAL = '" + xFilial("DUH")  + "' "
cQuery += "     AND DUH.DUH_LOCAL  = '" + DUH->DUH_LOCAL  + "' "
cQuery += "     AND DUH.DUH_LOCALI = '" + DUH->DUH_LOCALI + "' "
cQuery += "     AND DUH.D_E_L_E_T_ = ' ' "
cQuery += "     AND DY4.DY4_FILIAL = '" + xFilial("DY4") + "' "
cQuery += "     AND DY4.DY4_NUMNFC = DUH.DUH_NUMNFC "
cQuery += "     AND DY4.DY4_SERNFC = DUH.DUH_SERNFC "	
cQuery += "     AND DY4.DY4_CLIREM = DUH.DUH_CLIREM "
cQuery += "     AND DY4.DY4_LOJREM = DUH.DUH_LOJREM "
cQuery += "     AND DY4.D_E_L_E_T_ = ' ' "
cQuery += "     JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += "       ON  DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "       AND DT6.DT6_FILDOC = DY4.DY4_FILDOC "
cQuery += "       AND DT6.DT6_DOC    = DY4.DY4_DOC "
cQuery += "       AND DT6.DT6_SERIE  = DY4.DY4_SERIE "
cQuery += "       AND DT6.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY DT6_FILDOC, DT6_DOC, DT6_SERIE "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())
		
	cFilDoc     := (cAliasQry)->DT6_FILDOC
	cDocto      := (cAliasQry)->DT6_DOC
	cSerie      := (cAliasQry)->DT6_SERIE
	nMediaPeso  := (cAliasQry)->DT6_PESO   / (cAliasQry)->DT6_QTDVOL
	nMediaValor := (cAliasQry)->DT6_VALMER / (cAliasQry)->DT6_QTDVOL
	nQtdVol     := (cAliasQry)->DUH_QTDVOL
	nPeso       := nMediaPeso  * nQtdVol
	nValMer     := nMediaValor * nQtdVol
	nTotPeso    += nPeso
	nTotQtVol	+= nQtdVol
	nTotVal		+= nValMer
		
	Aadd( aEndere, { cFilDoc, cDocto, cSerie, nPeso, nQtdVol, nValMer } )

	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->( dbCloseArea() )

Return aEndere

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTmsC040Dco บAutor  ณEduardo de Souza   บ Data ณ  13/05/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Visualiza Documentos                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ TmsC040Dco(ExpC1,ExpC2,ExpC3)                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 - Filial do Documento                                บฑฑ
ฑฑบ          ณ ExpC2 - Documento                                          บฑฑ
ฑฑบ          ณ ExpC3 - Serie do Documento                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TMSC040                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function TmsC040Dco(cFilDoc, cDocto, cSerie)

Local aAreaAnt	:= GetArea()
Local aAreaDT6	:= DT6->(GetArea())

DbSelectArea('DT6')
DbSetOrder(1)
If DT6->(MsSeek(xFilial('DT6')+cFilDoc+cDocto+cSerie))
	TmsA500Mnt('DT6',Recno(),2)
EndIf

RestArea(aAreaDT6)
RestArea(aAreaAnt)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Marco Bianchi         ณ Data ณ01/09/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MenuDef()
     
Private aRotina	:= { 	{ STR0002,"AXPesqui"  , 0, 1,0,.F. },; //"Pesquisar"
					 			{ STR0003,"TMSC040Mnt", 0, 2,0,NIL } } //"Visualizar"


If ExistBlock("TMC040MNU")
	ExecBlock("TMC040MNU",.F.,.F.)
EndIf

Return(aRotina)
