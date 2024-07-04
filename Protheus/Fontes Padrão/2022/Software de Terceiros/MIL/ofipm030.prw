// ษออออออออหออออออออป
// บ Versao บ 17     บ
// ศออออออออสออออออออผ

#INCLUDE "Protheus.ch"
#INCLUDE "OFIPM030.ch"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  19/10/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007042_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma ณ OFIPM030 บ Autor ณ Ricardo Farinelli / Andre Luis Almeida บ Data ณ 12/18/00 บฑฑ
ฑฑฬอออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricaoณ Efetua a substituicao de titulos automatica para os clientes que compram    บฑฑ
ฑฑบ         ณ periodicamente. ( antigo FINA045 )                                          บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIPM030()
Local cPadrao      := "503" // Codigo de lancamento padrao
Private nHdlLock   := 0
Private cAlias 	   := ""
Private cAliasTRB  := ""
Private cChaveTRB  := ""
Private dDtEmissao := dDatabase
Private oMark	   := 0
Private nIndSA1    := 0 // guarda a ordem do novo indice criado no filtro do criatrab
Private cPerg      := "OPM030"
Private dMV_PAR01  := dDataBase
Private cMV_PAR02  := ""
Private nMV_PAR03  := 1

//////////////////// PERGUNTE - OPM030 ////////////////////
//  01  Dt.Limite Movto  D  8                            //
//  02  TpTitulo Provis  C  20                           //
//  03  Tipo de Prefixo  N  1  Combo: Todos/BAL/OFI/VEI  //
///////////////////////////////////////////////////////////
// Restringe o uso do programa ao Financeiro, Sigaloja e Especiais
If !(AmIIn(6,11,12,14,41,97))		// somente os modulos Financeiro, Veiculos, Loja, Oficina, Pecas e Esp
	Return
Endif
lPadrao:=VerPadrao(cPadrao)
// A ocorrencia 23 (ACS), verifica se o usuario poder ou nao efetuar substituicao de titulos provisorios.
IF !ChkPsw( 23 )
	Return
EndIf
// Verifica se data do movimento nao  menor que data limite de movimentacao no financeiro
If !DtMovFin()
	Return
Endif
If !ChkField()
	Return
Endif
If !pergunte(cPerg,.T.) // antigo FINA45
	Return
Endif
dMV_PAR01 := MV_PAR01
cMV_PAR02 := MV_PAR02
nMV_PAR03 := MV_PAR03
//
dDtEmissao := dMV_PAR01
If F045TRB(@cAliasTRB,@cChaveTRB) // Cria a Tabela Base de Trabalho do SA1 + campo A1_OK para a Markbrowse
	If F045SMF(@nHdlLock) // Sinaliza a execucao de susbstituicao de titulos (fina040)
		F045SEL() // Mostra a Markbrowse para escolha dos clientes a substituir titulos
	Endif
EndIf
// deleta os arquivos temporarios
If nHdlLock > 0
	Fclose(nHdlLock)
	Ferase("FINA040.LCK")
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF045SMF   บAutor  ณRicardo Farinelli   บ Data ณ  12/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVide codigo do FINA040.                                     บฑฑ
ฑฑบ          ณNao permite a execucao de substituicao por mais de um usua- บฑฑ
ฑฑบ          ณrio ao mesmo tempo.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSubstituicao de Titulos Automatica                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F045SMF(nHdlLock)
If ( nHdlLock := MSFCREATE("FINA040.LCK") ) < 0
	MsgAlert(STR0003+chr(13)+chr(10)+;	  //"A Funcao de substituicao de titulos esta sendo utilizada por"
	STR0004+chr(13)+chr(10)+;	 //"outro usuario. Por questoes de integridade de dados, nao"
	STR0005+chr(13)+chr(10)+;	 //" permitida a utilizao desta rotina por mais de um usu rio"
	STR0006,STR0007)	 //"simultaneamente. Tente novamente mais tarde."###"Substituir"
	Return .F.
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Grava no sem foro informa”es sobre quem est  utilizando a Rotina  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
FWrite(nHdlLock,STR0008+substr(cUsuario,7,15)+chr(13)+chr(10)+; //"Operador: "
STR0009+cEmpAnt+chr(13)+chr(10)+; //"Empresa.: "
STR0010+cFilAnt+chr(13)+chr(10)) //"Filial..: "
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF045SEL   บAutor  ณRicardo Farinelli   บ Data ณ  12/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela com a markbrowse para escolha dos clientes a se- บฑฑ
ฑฑบ          ณrem processados.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Substituicao de titulos automatica                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F045SEL()
Local nOpca   := 0
Local aCampos := {}
Local lInverte:=.F.
Private cMarca:= GetMark()
AADD(aCampos,{"A1_OK","","  ",""})
AADD(aCampos,{"A1_COD","","Codigo","@!"})
AADD(aCampos,{"A1_LOJA","",STR0011,"@!"}) //"Loja"
AADD(aCampos,{"A1_NOME","",STR0012,"@!"}) //"Nome Cliente"
AADD(aCampos,{"A1_COND","",STR0013,"@!"}) //"Condi็ใo de Pagamento"
DEFINE MSDIALOG oDlg TITLE STR0014 FROM 9,0 To 28,80 OF oMainWnd   //"Selecione os clientes para gera็ใo dos tํtulos definitivos"
SA1TRB->(Dbgotop())
oMark:=MsSelect():New("SA1TRB","A1_OK",,aCampos,,cMarca,{02,1,123,316})
oMark:oBrowse:lhasMark := .t.
oMark:oBrowse:lCanAllmark := .t.
oMark:oBrowse:bAllMark := {|| Fina045Inverte(cMarca,@oMark)}
DEFINE SBUTTON FROM 126,246.3 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 126,274.4 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED
If nOpca == 1
	Processa({|lEnd| OPM030GRV()},,STR0015) //"Gerando Titulos Efetivos"
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF045TRB   บAutor  ณRicardo Farinelli   บ Data ณ  12/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria arq.   temporario de forma a separar apenas os clientesบฑฑ
ฑฑบ          ณque atendem o periodo desejado e que possuam tituls proviso-บฑฑ
ฑฑบ          ณrios a serem gerados titulos efetivos,p/markbrowse          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSubstitucao de Titulos Automatica                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F045TRB(cAliasTRB,cChaveTRB)
Local cQuery  := ""
Local cQAlSQL := "ALIASSQL"
Local cDiaFer := Str(Day(cTod("01/03/"+Str(Year(dMV_PAR01),4))-1),2) //Ultimo dia de Fevereiro
Local cFor    := ""
Local lTemReg := .f.
Local aCampos := {}
AADD(aCampos,{"A1_OK","C",2,0})
AADD(aCampos,{"A1_COD","C",6,0})
AADD(aCampos,{"A1_LOJA","C",2,0})
AADD(aCampos,{"A1_NOME","C",30,0})
AADD(aCampos,{"A1_COND","C",3,0})
If Str(Day(dMV_PAR01),2)$"10/20"
	cFor := " SA1.A1_TIPPER='10' "
Elseif (Strzero(Month(dMV_PAR01),2)$"01/03/05/07/08/10/12" .and. Str(Day(dMV_PAR01),2)=="31") .or.;
	(Strzero(Month(dMV_PAR01),2)$"04/06/09/11" .and. Str(Day(dMV_PAR01),2)=="30") .or.;
	(Month(dMV_PAR01)==2 .and. Str(Day(dMV_PAR01),2)$cDiaFer)
	cFor := " SA1.A1_TIPPER IN ('10','15','30') "
Elseif Str(Day(dMV_PAR01),2)=="15"
	cFor := " SA1.A1_TIPPER='15' "
Elseif Str(Day(dMV_PAR01),2)=="30"
	cFor := " SA1.A1_TIPPER IN ('10','15') "
Endif
If Str(Dow(dMV_PAR01),1)$"23456"
	If Empty(cFor)
		cFor := " SA1.A1_TIPPER='"+Strzero(Dow(dMV_PAR01),2)+"' "
	Else
		cFor := " ("+cFor+" OR SA1.A1_TIPPER='"+Strzero(Dow(dMV_PAR01),2)+"' ) "
	Endif
Endif
If !Empty(cFor)
	cFor += " AND "
EndIf
cFor += " SA1.A1_COND<>' ' "
Dbselectarea("SA1")

oObjTempTable := OFDMSTempTable():New()
oObjTempTable:cAlias := "SA1TRB"
oObjTempTable:aVetCampos := aCampos
oObjTempTable:CreateTable(.f.)

cQuery := "SELECT SA1.A1_COD , SA1.A1_LOJA , SA1.A1_NOME , SA1.A1_COND FROM "+RetSqlName("SA1")+" SA1 "
cQuery += "WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND "+cFor+" AND SA1.D_E_L_E_T_=' ' AND "
cQuery += "EXISTS ( SELECT SE1.R_E_C_N_O_ FROM "+RetSQLName("SE1")+" SE1 WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND SE1.E1_CLIENTE=SA1.A1_COD AND SE1.E1_LOJA=SA1.A1_LOJA AND SE1.E1_EMISSAO<='"+dtos(dMV_PAR01)+"' AND SE1.D_E_L_E_T_=' ' ) "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
  	DbSelectArea("SA1TRB")
	RecLock("SA1TRB",.T.)
		SA1TRB->A1_COD  := ( cQAlSQL )->( A1_COD )
		SA1TRB->A1_LOJA := ( cQAlSQL )->( A1_LOJA )
		SA1TRB->A1_NOME := ( cQAlSQL )->( A1_NOME )
		SA1TRB->A1_COND := ( cQAlSQL )->( A1_COND )
	MsUnLock()
	lTemReg := .t. // Tem registros para selecionar
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )

dbSelectArea("SA1TRB")
oObjTempTable:CloseTable()

DbSelectArea("SA1")
Return lTemReg

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOPM030GRV บAutor  ณRicardo Farinelli   บ Data ณ  12/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a gravacao dos novos titulos definitivos no contas a บฑฑ
ฑฑบ          ณreceber.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSubstituicao de Titulos Automatica                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OPM030GRV()
Local cTipTit := Left(Alltrim(GetNewPar("MV_TIPPER","TP"))+space(10),SE1->(TamSX3("E1_TIPO")[1])) // Tipo de Titulo Provisorio
Local aProvis  := {} // para gardar a chave dos titulos a serem deletados
Local nTotTit  := nTotTit1 := nTotTit2 := 0  // Somatoria dos titulos por cliente
Local cPedido  := cPedido1 := cPedido2 := "" // numero do titulo a ser gerado
Local cPrefix  := "" // prefixo do titulo a ser gerado
Local cPrefOri := "" // prefixo do titulo a ser gerado
Local cPortad  := "" // Portador do titulo a ser gerado
Local dEmissao := dMV_PAR01             // data de emissao (geracao) dos titulos
Local cNatureza:= GETMV("MV_NATPER")  // Codigo da natureza dos titulos a serem gerados
Local cCondpag := "" // codigo da condicao de pagamento padrao do cliente
Local aPgto    := {} // array dos vencimentos e valores das parcelas a serem geradas
Local aPgto1   := {} // array dos vencimentos e valores das parcelas a serem geradas
Local aPgto2   := {} // array dos vencimentos e valores das parcelas a serem geradas
Local cCli     := cLoja := "" // Codigo/Loja do cliente a gerar titulos
Local aFINA040 := {} // vetor a ser passado na gravacao dos titulos a receber
Local cParc		:= "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ" // sequencia de parcelas a serem geradas
Local nTotFat := nLin := 0
Local nx := 0
Local ni := 0
Local n  := 0
Local cPre := ""
For nx := 1 to 1 //2
	If nx == 1
		cTitulo := STR0015
		cString := "SE1"
	Else
		If len(aPgto)+len(aPgto2) > 0
			If !MsgYesNo(STR0019,STR0020)
				Exit
			EndIf
		Else
			Exit
		EndIf
	EndIf
	Do Case
		Case nMV_PAR03 == 2
			cPre := GetNewPar("MV_PREFBAL","BAL")
		Case nMV_PAR03 == 3
			cPre := GetNewPar("MV_PREFOFI","OFI")
		Case nMV_PAR03 == 4 
			cPre := GetNewPar("MV_PREFVEI","VEI")
	EndCase
	SA1TRB->(Dbgotop())
	ProcRegua(SA1TRB->(Reccount()))
	While !SA1TRB->(Eof())
		IncProc(STR0016+SA1TRB->A1_NOME)     //"Analisando Cliente: "
		If SA1TRB->A1_OK == cMarca   // se foi selecionado na markbrowse
			cCli     := SA1TRB->A1_COD
			cLoja    := SA1TRB->A1_LOJA
			cCondpag := SA1TRB->A1_COND
			aPgto    := {}
			aPortador:= {}
			Dbselectarea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+cCli+cLoja)
			//// Dividir titulos por PORTADOR - Andre Luis Almeida 05/05/03 ////
			Dbselectarea("SE1")
			DbSetOrder(2) // Cliente + Loja
			Dbseek(xFilial("SE1")+Alltrim(cCli+cLoja))
			While !SE1->(Eof()) .and. Alltrim(SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA)==Alltrim(xFilial("SE1")+cCli+cLoja)
				///////////////////////
				If Empty(cMV_PAR02)
					If !(SE1->E1_TIPO$cTipTit) // Seleciona apenas os Titulos Provisorios PADRAO ( "MV_TIPPER" )
						SE1->(Dbskip())
						Loop
					Endif
				Else
					If !(SE1->E1_TIPO $ cMV_PAR02 .and. SE1->E1_VALOR==SE1->E1_SALDO) // Tipo de Titulos escolhido pelo usuario
						SE1->(Dbskip())
						Loop
					EndIf
				Endif
				///////////////////////
				If SE1->E1_EMISSAO > dEmissao // pega somente os vencimentos ate a data da geracao dos titulos
					SE1->(Dbskip())
					Loop
				Endif
				If ( nMV_PAR03 # 1 ) .and. ( SE1->E1_PREFORI # cPre )
					SE1->(Dbskip())
					Loop
				Endif
				// adiciona todos os bancos dos titulos provisorios
				nPos := aScan(aPortador,{|x| x[1] == SE1->E1_PORTADO })
				If nPos == 0
					AADD(aPortador,{SE1->E1_PORTADO})
				EndIf
				SE1->(Dbskip())
			Enddo
			// Luis: variavel que armazena o mes do titulo para geracao de duas duplicatas qdo o mes for diferente.
			For ni:=1 to Len(aPortador)
				vMes01  := vMes02 := nTotTit := nTotTit1 := nTotTit2 := 0
				aPgto   := {}
				aPgto1  := {}
				aPgto2  := {}
				aFin040 := {}
				aProvis := {}
				cPedido := ""
				Dbselectarea("SE1")
				DbSetOrder(2) // Cliente + Loja
				Dbseek(xFilial("SE1")+Alltrim(cCli+cLoja))
				While !SE1->(Eof()) .and. Alltrim(SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA)==Alltrim(xFilial("SE1")+cCli+cLoja)
					///////////////////////
					If Empty(cMV_PAR02)
						If !(SE1->E1_TIPO$cTipTit) // Seleciona apenas os Titulos Provisorios PADRAO ( "MV_TIPPER" )
							SE1->(Dbskip())
							Loop
						Endif
					Else
						If !(SE1->E1_TIPO $ cMV_PAR02 .and. SE1->E1_VALOR==SE1->E1_SALDO) // Tipo de Titulos escolhido pelo usuario
							SE1->(Dbskip())
							Loop
						EndIf
					Endif
					///////////////////////
					If SE1->E1_PORTADO#aPortador[ni,1]
						SE1->(Dbskip())
						Loop
					EndIf
					If SE1->E1_EMISSAO > dEmissao // pega somente os vencimentos ate a data da geracao dos titulos
						SE1->(Dbskip())
						Loop
					Endif
					If ( nMV_PAR03 # 1 ) .and. ( SE1->E1_PREFORI # cPre )
						SE1->(Dbskip())
						Loop
					Endif
					nTotFat := 0
					// Luis : aqui eu armazeno as variaveis
					if(vMes01==0)
						vMes01 := Month(SE1->E1_EMISSAO)
					elseif Month(SE1->E1_EMISSAO) != vMes01
						cDatLib := strzero(Year(SE1->E1_EMISSAO),4)+STRZERO(Month(SE1->E1_EMISSAO),2)+"01"
						dtEmiss1:= stod(cDatLib) - 1
						vMes02  := Month(SE1->E1_EMISSAO)
					endif
					nPosVirg := AT(",",GETMV("MV_NATPER"))
					If nPosVirg > 0
						cNatureza := If(nPosVirg>0,Left(GETMV("MV_NATPER"),nPosVirg-1),GETMV("MV_NATPER"))
					Endif
					VOO->(DbSetOrder(4))
					If VOO->(DbSeek(xFilial("VOO")+SE1->E1_NUM+SE1->E1_PREFIXO))
						If VOO->VOO_TOTPEC == 0
							If nPosVirg > 0
								cNatureza := If(nPosVirg>0,Alltrim(Subs(GETMV("MV_NATPER"),nPosVirg+1)),GETMV("MV_NATPER"))   // Codigo da natureza dos titulos a serem gerados
							Endif
							If VOO->(FieldPos("VOO_NATSRV")) > 0
								If !Empty(VOO->VOO_NATSRV)
									cNatureza := VOO->VOO_NATSRV
								Endif
							Endif
						Else
							If VOO->(FieldPos("VOO_NATPEC")) > 0
								If !Empty(VOO->VOO_NATPEC)
									cNatureza := VOO->VOO_NATPEC
								Endif
							Endif
						Endif
					Endif					
					// adiciona a chave para delecao dos titulos provisorios
					AADD(aProvis,{{"E1_PREFIXO",E1_PREFIXO,nil},;
					{"E1_NUM",E1_NUM,nil},;
					{"E1_PARCELA",E1_PARCELA,nil},;
					{"E1_TIPO",E1_TIPO,nil}})
					cPrefix := E1_PREFIXO
					cPrefOri:= E1_PREFORI
					cPortad := E1_PORTADO
					If Empty(cPedido) // Adiciona o primeiro numero de pedido que encontrar para assumir como numero de titulo
						cPedido := SE1->E1_NUM
					Endif
					if month(E1_EMISSAO) == vMes01 .and. Empty(cPedido1) // Adiciona o primeiro numero de pedido que encontrar para assumir como numero de titulo
						cPedido1 := SE1->E1_NUM
					elseif month(E1_EMISSAO) == vMes02 .and. Empty(cPedido2)
						cPedido2 := SE1->E1_NUM
					endif
					if MONTH(E1_EMISSAO) == vMes01
						nTotTit1 += SE1->E1_SALDO
					else
						nTotTit2 += SE1->E1_SALDO
					endif
					nTotTit += SE1->E1_SALDO
					SE1->(Dbskip())
				Enddo
				If nTotTit > 0
					aPgto := Condicao(nTotTit,cCondpag,,dEmissao) // Total para o calculo, cod. cond.pgto,data base
					if  nTotTit2 != 0
						aPgto1 := Condicao(nTotTit1,cCondpag,,dEmissao) // Total para o calculo, cod. cond.pgto,data base
						aPgto2 := Condicao(nTotTit2,cCondpag,,dEmissao) // Total para o calculo, cod. cond.pgto,data base
					endif
					aFin040 := {}
					DbselectArea("SE1")
					DbSetOrder(1)
					DbselectArea("SA1")
					DbSetOrder(1)
					//////// 03/04/02 - Andre Luis Almeida ////////
					If len(aPgto) > 0
						nTotal := 0
						For n := 1 to Len(aPgto)
							nTotal += aPgto[n,2]
						Next
						If nTotal > nTotTit
							aPgto[Len(aPgto),2] -= 0.01
							If Type("aPgto2[1,2]") != "U"
								aPgto2[Len(aPgto2),2] -= 0.01
							endif
						ElseIf nTotal < nTotTit
							aPgto[1,2] += 0.01
							If Type("aPgto2[1,2]") != "U"
								aPgto2[1,2] += 0.01
							Endif
						EndIf
					EndIf
					cNumBor := ""
					dDtaBor := ctod("")
					Dbselectarea("SA6")
					DbSetOrder(1)
					Dbseek( xFilial("SA6") + cPortad )
					If SA6->A6_BORD # "1"
						cNumBor := "BCO" + cPortad
						dDtaBor := dDtEmissao
					EndIf

					Dbselectarea("SE1")
					DbSetOrder(2) // Cliente + Loja
					
					dbSelectArea("SA1")
					dbSetOrder(1)
					dbSeek(xFilial("SA1")+cCli+cLoja)
					if Len(aPgto2) != 0
						For n := 1 to Len(aPgto1)
							AADD(aFIN040,{ {"E1_PREFIXO",cPrefix,nil},;
							{"E1_NUM",cPedido1,nil},;
							{"E1_PREFORI",cPrefOri,nil},;
							{"E1_PARCELA",Substr(cParc,n,1),nil},;
							{"E1_TIPO","DP ",nil},; // cTipTit - Andre Luis Almeida
							{"E1_NATUREZ",cNatureza,nil},;
							{"E1_PORTADO",cPortad,nil},;
							{"E1_CLIENTE",cCli,nil},;
							{"E1_LOJA",cLoja,nil},;
							{"E1_EMISSAO",dtEmiss1,nil},;
							{"E1_FATPREF","PER",nil},;     // Andre Luis Almeida
							{"E1_NUMBOR",cNumBor,nil},;    // Andre Luis Almeida
							{"E1_DATABOR",dDtaBor,nil},;   // Andre Luis Almeida
							{"E1_VENCTO",aPgto1[n,1],nil},;
							{"E1_VENCREA",aPgto1[n,1],nil},;
							{"E1_VALOR",aPgto1[n,2],nil},; // })
							{"E1_ORIGEM","OFIPM030",nil},; // })
							{"E1_PERIOD","S",nil} })
							nTotFat += aPgto1[n,2]
						Next
						For n := 1 to Len(aPgto2)
							AADD(aFIN040,{ {"E1_PREFIXO",cPrefix,nil},;
							{"E1_NUM",cPedido2,nil},;
							{"E1_PREFORI",cPrefOri,nil},;
							{"E1_PARCELA",Substr(cParc,n,1),nil},;
							{"E1_TIPO","DP ",nil},; // cTipTit - Andre Luis Almeida
							{"E1_NATUREZ",cNatureza,nil},;
							{"E1_PORTADO",cPortad,nil},;
							{"E1_CLIENTE",cCli,nil},;
							{"E1_LOJA",cLoja,nil},;
							{"E1_EMISSAO",dDtEmissao,nil},;
							{"E1_FATPREF","PER",nil},;     // Andre Luis Almeida
							{"E1_NUMBOR",cNumBor,nil},;    // Andre Luis Almeida
							{"E1_DATABOR",dDtaBor,nil},;   // Andre Luis Almeida
							{"E1_VENCTO",aPgto2[n,1],nil},;
							{"E1_VENCREA",aPgto2[n,1],nil},;
							{"E1_VALOR",aPgto2[n,2],nil},; // })
							{"E1_ORIGEM","OFIPM030",nil},; // })
							{"E1_PERIOD","S",nil} })
							nTotFat += aPgto2[n,2]
						Next
					else
						For n := 1 to Len(aPgto)
							AADD(aFIN040,{ {"E1_PREFIXO",cPrefix,nil},;
							{"E1_NUM",cPedido,nil},;
							{"E1_PREFORI",cPrefOri,nil},;
							{"E1_PARCELA",Substr(cParc,n,1),nil},;
							{"E1_TIPO","DP ",nil},; // cTipTit - Andre Luis Almeida
							{"E1_NATUREZ",cNatureza,nil},;
							{"E1_PORTADO",cPortad,nil},;
							{"E1_CLIENTE",cCli,nil},;
							{"E1_LOJA",cLoja,nil},;
							{"E1_EMISSAO",dDtEmissao,nil},;
							{"E1_FATPREF","PER",nil},;     // Andre Luis Almeida
							{"E1_NUMBOR",cNumBor,nil},;    // Andre Luis Almeida
							{"E1_DATABOR",dDtaBor,nil},;   // Andre Luis Almeida
							{"E1_VENCTO",aPgto[n,1],nil},;
							{"E1_VENCREA",aPgto[n,1],nil},;
							{"E1_VALOR",aPgto[n,2],nil},; // })
							{"E1_ORIGEM","OFIPM030",nil},; // })
							{"E1_PERIOD","S",nil} })
							nTotFat += aPgto[n,2]
						Next
					endif
					
					lMsErroAuto := .F. // variavel interna da rotina automatica
					lMsHelpAuto := .F.
					BEGIN TRANSACTION
					pergunte("FIN040",.F.)
					For n := 1 to len(aFIN040)
						
						_nRecSA1 := SA1->(Recno())//salva posicao SA1
						
						MSExecAuto({|x,y| FINA040(x,y)},aFIN040[n],3)
						
						SA1->(Dbgoto(_nRecSA1))	//volta posicao SA1
						
						If LMsErroAuto
							MostraErro()
							Help(" ",1,"INCSUBPR",,cCli+"/"+cLoja,4,1) // Erro na Inclusao do Titulo do Contas a Receber
							DisarmTransaction()
							Break
						Endif
						DbSelectArea("SE1")
						RecLock("SE1",.f.)
						if Empty(SE1->E1_PREFIXO)
							SE1->E1_PREFIXO := cPrefix
						Endif
						if Len(Alltrim(SE1->E1_PARCELA)) == 1
							SE1->E1_PARCELA := strzero(val(SE1->E1_PARCELA),len(SE1->E1_PARCELA))
						Endif
						if len(aPgto2) == 0
							SE1->E1_EMIS1 := dDtEmissao  // Andre Luis Almeida
						elseif n <= len(aPgto1)
							SE1->E1_EMIS1 := dtEmiss1  // Luis Delorme
						else
							SE1->E1_EMIS1 := dDtEmissao  // Luis Delorme
						endif
						MsUnlock()
					Next
					
					// Restaura pergunte do OFIPM030
					Pergunte(cPerg,.F.)
					
					// Elimina os titulos provisorios do cliente em questao
					F045GRVSUB(@aProvis)
					
					// Grava no SF2 o titulo definitivo no F2_DUPL
					if Len(aPgto2) != 0
						F045GRVSF2(@aProvis,@cPedido1,@cPedido2)
					else
						F045GRVSF2(@aProvis,@cPedido,@cPedido)
					endif
					END TRANSACTION

				Endif
			Next
		Endif
		
		SA1TRB->(Dbskip())
	Enddo
	MsgInfo(STR0001,STR0020)
Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF045GRVSUBบAutor  ณRicardo Farinelli   บ Data ณ  12/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a eliminacao dos titulos provisorios gerados anteriorบฑฑ
ฑฑบ          ณmente, pois os mesmos ja foram substituidos                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSubstituicao de Titulos Automatica                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F045GRVSUB(aVetor)
Local n := 0
Local cTipTit := Left(Alltrim(GetNewPar("MV_TIPPER","TP"))+space(10),SE1->(TamSX3("E1_TIPO")[1])) // Tipo de Titulo Provisorio
NUMREG := SE1->(Recno())
For n := 1 to len(aVetor)
	dbSelectArea("SE1")
	dbSetOrder(1)
	if dbSeek(xFilial("SE1")+aVetor[n,1,2]+aVetor[n,2,2]+aVetor[n,3,2]+aVetor[n,4,2])
		While !Eof() .and. xFilial("SE1") == SE1->E1_FILIAL .and. aVetor[n,1,2]+aVetor[n,2,2]+aVetor[n,3,2]+aVetor[n,4,2] == SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
			if SE1->E1_TIPO == cTipTit
				dbSelectArea("SE1")
				RecLock("SE1",.F.,.T.)
				dbdelete()
				MsUnlock()
			Endif
			dbSelectArea("SE1")
			dbSkip()
		Enddo
	Endif
Next
Dbgoto(NUMREG)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF045GRVSF2บAutora ณRenata              บ Data ณ  11/01/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a gravacao do nro do titulo efetivo do periodico no  บฑฑ
ฑฑบ          ณcpo SF2->F2_DUPL das notas envolvidas                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSubstituicao de Titulos Automatica                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F045GRVSF2(aVetor,cPed,cPed2)
Local cPedAux := ""
Local xc := 0
mesemiss := 0
_walias:=alias()
_worder:=indexord()
_wrecno:=recno()
dbSelectArea("SF2")
_wordsf2:=indexord()
_wrecsf2:=recno()
for xc := 1 to len(aVetor)
	dbSelectArea("SF2")
	dbsetorder(1)
	dbgotop()
	if dbseek(xFilial("SF2")+aVetor[xc,2,2])
		if mesemiss == 0
			mesemiss := Month(SF2->F2_EMISSAO)
		endif
		if Month(SF2->F2_EMISSAO) == mesemiss
			cPedAux := cPed
		Else
			cPedAux := cPed2
		EndIf
		If FMX_VALFIN( SF2->F2_PREFIXO , cPedAux , SF2->F2_CLIENTE , SF2->F2_LOJA ) <> 0
			dbSelectArea("SF2")
			reclock("SF2",.F.)
			SF2->F2_DUPL := cPedAux
			MSUNLOCK()
		EndIf
	endif
next
DbselectArea("SF2")
dbSetOrder(_wordsf2)
dbgoto(_wrecsf2)
DbselectArea(_walias)
dbSetOrder(_worder)
dbgoto(_wrecno)
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFina045Inverte    ณRicardo Farinelli   บ Data ณ  01/04/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInverte e grava a marcacao na markBrowse                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Fina045                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fina045Inverte(cMarca,oMark)
Local nReg := SA1TRB->(Recno())
dbSelectArea("SA1TRB")
dbGoTop()
While !Eof()
	RecLock("SA1TRB")
	IF A1_OK == cMarca
		SA1TRB->A1_OK := "  "
	Else
		SA1TRB->A1_OK := cMarca
	Endif
	dbSkip()
Enddo
SA1TRB->(dbGoto(nReg))
oMark:oBrowse:Refresh(.t.)
Return Nil
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChkField  บAutor  ณRicardo Farinelli   บ Data ณ  01/09/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica a existencia do campo A1_TIPPER e dos parametros   บฑฑ
ฑฑบ          ณMV_TIPPER e MV_NATPER para compatibilizar versoes anterioresบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA045                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ChkField()
Local lRet := .T.
Dbselectarea("SX3")
Dbsetorder(2)
If !Dbseek("A1_TIPPER")
	MsgStop(STR0021+Chr(13)+Chr(10)+; //"Favor criar o campo A1_TIPPER do tipo Caracter, com tamanho de 2 em sua tabela de Clientes(SA1)."
	STR0022+Chr(13)+Chr(10)+; //"para que esta rotina possa ser executada."
	STR0023)  //"Para isso, vแ ao m๓dulo configurador e processa a inclusao do campo."
	lRet := .F.
Endif
Return lRet
