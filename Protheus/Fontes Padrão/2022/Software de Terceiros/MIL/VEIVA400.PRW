// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 06     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "protheus.ch"
#INCLUDE "VEIVA400.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VEIVA400 ³ Autor ³  RAFAEL GONCALVES     ³ Data ³ 28/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ REGRAS PARA RESERVA DE VEICULO                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function VEIVA400()

PRIVATE aCampos := {}
PRIVATE aRotina := MenuDef()
Private aNewBot := {}
aadd(aNewBot,{"EDIT",{ || VA400LT() },STR0014})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemToAnsi(STR0001) //Regras para reserva de Veiculo


DbSelectArea("VZM")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VZM")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VA400V   ºAutor  ³RAFAEL GONCALVES    ³ Data ³ 28/01/10    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualizar                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA400V(cAlias,nReg,nOpc)

CAMPO400()
AxVisual(cAlias,nReg,nOpc,aCampos)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VA400I    ºAutor  ³RAFAEL GONCALVES    º Data ³ 28/01/10    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Incluir                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA400I(cAlias,nReg,nOpc)

CAMPO400()
AxInclui(cAlias, nReg, nOpc, aCampos,,,"FS_VA400VL()",,,aNewBot)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VA400VLºAutor  ³RAFAEL GONCALVES    º Data ³ 28/01/10    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³valida se ja existe registro cadastrado                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VA400VL()
Local cCodMar := M->VZM_CODMAR//space(len(VZM->VZM_CODMAR))
Local cGruMod := M->VZM_GRUMOD//space(len(VZM->VZM_GRUMOD))
Local cModVei := M->VZM_MODVEI//space(len(VZM->VZM_MODVEI))

/*
If Empty(cCodMar) .and. Empty(cGruMod) .and. Empty(cModVei)
Return .f.
ElseIf !Empty(cCodMar)
*/
DbSelectArea("VZM")
DbSetOrder(1)
if DbSeek(xFilial("VZM")+cCodMar+cGruMod+cModVei)
	MsgInfo(STR0002,STR0003)//Ja existe este registro ### atencao
	Return .f.
EndIf

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VA400A    ºAutor  ³RAFAEL GONCALVES    º Data ³  28/01/10   ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Alterar                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA400A(cAlias,nReg,nOpc)

CAMPO400()
AxAltera(cAlias,nReg,nOpc,aCampos,,,,,,,aNewBot)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VA400E    ºAutor  ³RAFAEL GONCALVES    º Data ³  28/01/10   ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Excluir                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA400E(cAlias,nReg,nOpc)

AxDeleta(cAlias,nReg,nOpc)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CAMPO400  ºAutor  ³RAFAEL GONCALVES    º Data ³  28/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta campos                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CAMPO400()

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VZM")
aCampos := {}

do While !eof() .and. x3_arquivo == "VZM"
	
	If X3USO(x3_usado).and.cNivel>=x3_nivel
		aadd(aCampos,x3_campo)
	EndIf
	
	dbskip()
Enddo

DbSelectArea("VZM")

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef   ºAutor  ³RAFAEL GONCALVES    º Data ³  28/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Menu			                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { { STR0004 ,"AxPesqui", 0 , 1},;  //Pesquisar
{ STR0005 ,"VA400V", 0 , 2},;  //Visualizar
{ STR0006 ,"VA400I", 0 , 3},;  //Incluir
{ STR0007 ,"VA400A", 0 , 4},;  //Alterar
{ STR0008 ,"VA400E", 0 , 5}}   //Excluir
Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CAMPO400  ºAutor  ³RAFAEL GONCALVES    º Data ³  28/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta se existe tarefa para o veiculo                   º±±
±±º          ³ realizando ou nao a reaserva do veiculo                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ 1-Numero atendimento                                       º±±
±±ºParametros³ 2-Momento da chamada                                       º±±
±±º          ³ 3-Informa se valida a data e hora informada(pelo usuario)  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA400REGRA(cNumId,cChama,lValDtHr)

Local cCodMca := M->VV0_CODMAR
Local cGrMod  := M->VV0_GRUMOD
Local cModVec := M->VV0_MODVEI
Local cAnoMod := M->VV0_FABMOD
Local cEstVei := VV1->VV1_ESTVEI
Local cQuery := ""
Local cQAlias:= "SQLVZM"
Local cTarefa  := ""
Local ni :=1
Local lRetTar  := .t.
Local lAchou   := .f.
Local cSAlias  := Alias()
Local nLimDia  := 0
Local cTexto   := ""
// Manoel - Usado na reserva do veiculo
//Local nPercRA  := 0
//Local nValorRA := 0

//Local cPrefOri  := GetNewPar("MV_PREFVEI","VEI")
//Local cNumTit := "V"+Right(VV9->VV9_NUMATE,TamSx3("E1_NUM")[1]-1)
// Manoel - Usado na reserva do veiculo

Default cChama   := ""
Default cNumId   := ""
Default lValDtHr := .f.

If cChama $ "1/2/3/4/5" .and. cNumId <> ""
	
	// Manoel - Usado na reserva do veiculo
	//	If VZM->(FieldPos("VZM_PERCRA")) > 0 .and. VZM->(FieldPos("VZM_VALORA")) > 0
	//   	cQuery := "SELECT VZM.VZM_REQTAR , VZM.VZM_LIMDIA  , VZM.VZM_PERCRA , VZM.VZM_VALORA FROM "+RetSqlName("VZM")+" VZM  WHERE "
	//   Else
	//   	cQuery := "SELECT VZM.VZM_REQTAR , VZM.VZM_LIMDIA FROM "+RetSqlName("VZM")+" VZM  WHERE "
	//   Endif
	// Manoel - Usado na reserva do veiculo
	
	cQuery := "SELECT VZM.VZM_REQTAR , VZM.VZM_LIMDIA FROM "+RetSqlName("VZM")+" VZM  WHERE "
	
	cQuery += "VZM.VZM_FILIAL='"+xFilial("VV0")+"' AND VZM.VZM_CHAMAD='"+cChama+"' AND "
	cQuery += "(VZM.VZM_CODMAR='"+SPACE(LEN(VV0->VV0_CODMAR))+"' OR VZM.VZM_CODMAR='"+cCodMca+"') AND "
	cQuery += "(VZM.VZM_GRUMOD='"+SPACE(LEN(VV0->VV0_GRUMOD))+"' OR VZM.VZM_GRUMOD='"+cGrMod +"') AND "
	cQuery += "(VZM.VZM_MODVEI='"+SPACE(LEN(VV0->VV0_MODVEI))+"' OR VZM.VZM_MODVEI='"+cModVec+"') AND "
	cQuery += "(VZM.VZM_FABMOD='"+SPACE(LEN(VZM->VZM_FABMOD))+"' OR VZM.VZM_FABMOD='"+cAnoMod+"') AND "
	cQuery += "(VZM.VZM_ESTVEI='"+SPACE(LEN(VZM->VZM_ESTVEI))+"' OR VZM.VZM_ESTVEI='"+cEstVei+"') AND "
	cQuery += "VZM.D_E_L_E_T_=' ' ORDER BY VZM.VZM_CODMAR desc ,VZM.VZM_GRUMOD desc , VZM.VZM_MODVEI desc"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	If !( cQAlias )->( Eof() )
		( cQAlias )->( DbGotop() )
		lAchou := .t.
		nLimDia := ( cQAlias )->( VZM_LIMDIA )
		if !Empty(( cQAlias )->( VZM_REQTAR ))
			For ni:=1 to 5
				if !Empty(Substr(( cQAlias )->( VZM_REQTAR ),(ni*7)-6,6))
					cTarefa := Substr(( cQAlias )->( VZM_REQTAR ),(ni*7)-6,6)
					DbSelectArea("VAY")
					DbSetOrder(3)
					IF DbSeek( xFilial("VAY") + cNumId + cTarefa)
						If !(VAY->VAY_STATUS $ "1/2")
							DbSelectArea("VAX")
							DbSetOrder(1)
							IF DbSeek( xFilial("VAX") + VAY->VAY_CODTAR)
								cTexto := cTexto + CHR(13)+CHR(10)+" - " +ALLTRIM(VAX->VAX_DESTAR)
								lRetTar := .f.
							EndIf
						EndIF
					Else
						DbSelectArea("VAX")
						DbSetOrder(1)
						IF DbSeek( xFilial("VAX") + cTarefa)
							cTexto := cTexto + CHR(13)+CHR(10)+" - " +ALLTRIM(VAX->VAX_DESTAR)
							lRetTar := .f.
						EndIf
					EndIF
				EndIF
				
			Next
		EndIf
	EndIf
	
	// Manoel - Usado na reserva do veiculo
	//	If VZM->(FieldPos("VZM_PERCRA")) > 0 .and. VZM->(FieldPos("VZM_VALORA")) > 0
	//		If !( nRecAnt >= nPercRA )
	//			MsgStop("Ainda nao foi baixado nenhum titulo referente ao SINAL! Impossivel Reservar o Veiculo!","Atencao")
	//			Return .f.
	//		EndIf
	//	ElseIf VZM->(FieldPos("VZM_VALORA")) > 0 .and. nValorRA > 0
	//		If !( nValor >= nValorRA )
	//			MsgStop("Ainda nao foi baixado nenhum titulo referente ao SINAL! Impossivel Reservar o Veiculo!","Atencao")
	//			Return .f.
	//		EndIf
	//	EndIf
	// Manoel - Usado na reserva do veiculo
	
	( cQAlias )->( dbCloseArea() )
	
	// Manoel - Usado na reserva do veiculo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificar se ja foi pago algum Sinal para possibilitar a Reserva ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//	If left(GetNewPar("MV_TITATEN","0"),1) == "0"
	//		cNumTit := VV0->VV0_NUMNFI
	//	EndIf
	//	cQuery  := "SELECT SE1.E1_VALOR-SE1.E1_SALDO FROM "+RetSQLName("SE1")+" SE1 WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND ( SE1.E1_NUM='"+cNumTit+"' "
	//	cQuery  += " ) AND SE1.E1_PREFORI='"+cPrefOri+"' AND ( SE1.E1_BAIXA <> ' ' OR SE1.E1_SALDO <> SE1.E1_VALOR ) AND SE1.D_E_L_E_T_=' '"
	//	nValor  := FM_SQL(cQuery)
	//	nRecAnt := ( nValor / VV0->VV0_VALMOV ) * 100 // Percentual de Recbto Antecipado para permitir Reservar Veiculo
	//	If VZM->(FieldPos("VZM_PERCRA")) > 0 .and. VZM->(FieldPos("VZM_VALORA")) > 0
	//		If !( nRecAnt >= nPercRA )
	//			MsgStop("Ainda nao foi baixado nenhum titulo referente ao SINAL! Impossivel Reservar o Veiculo!","Atencao")
	//			Return .f.
	//		EndIf
	//	ElseIf VZM->(FieldPos("VZM_VALORA")) > 0 .and. nValorRA > 0
	//		If !( nValor >= nValorRA )
	//			MsgStop("Ainda nao foi baixado nenhum titulo referente ao SINAL! Impossivel Reservar o Veiculo!","Atencao")
	//			Return .f.
	//		EndIf
	//	EndIf
	// Manoel - Usado na reserva do veiculo
	
	If lValDtHr // valida se a chamada e na validacao da data ou hora para ver se a informada nao e maior que a da regra se for maior informar o usuario.
		if nLimDia > 0
			If ReadVar() == "M->VV0_DATVAL" //data de validade da reserva.
				If M->VV0_DATVAL <= (dDataBase+nLimDia)
					DbSelectArea(cSAlias)
					Return(.t.)
				Else
					MsgInfo(STR0009 + CHR(13)+CHR(10)+STR0010,STR0003) // Data informada é superior a data limite informada na regra para reserva de veiculo ### A data da reserva sera alterada para o limite configurado. ### Atencao
					M->VV0_DATVAL := dDataBase+nLimDia
					DbSelectArea(cSAlias)
					Return(.t.)
				EndIF
			Elseif ReadVar() == "M->VV0_HORVAL"
				
				If Dtos(M->VV0_DATVAL)+M->VV0_HORVAL <= (Dtos(dDataBase+nLimDia)+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2))
					DbSelectArea(cSAlias)
					Return(.t.)
				Else
					MsgInfo(STR0011 + CHR(13)+CHR(10)+STR0012,STR0003)//Hora informada é superior a hora limite informada na regra para reserva de veiculo ### A hora da reserva sera alterada para o limite configurado. ### Atencao
					M->VV0_HORVAL := SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)
					DbSelectArea(cSAlias)
					Return(.t.)
				EndIf
			Endif
		Else
			DbSelectArea(cSAlias)
			Return(.f.)
		Endif
	EndIF
	
	
	If !lRetTar
		MsgInfo(STR0013+cTexto,STR0003)//Nao sera possivel realizar a reserva do veiculo pois existe(m) tarefa(s) pendente(s): ### Atencao
		DbSelectArea(cSAlias)
		If cChama =="5" // se for chamado pelo usuario ele retorna falso para nao permitir o usuario reservar
			Return(.f.)
		else //calcela a reserva.
			If M->VV0_RESERV $ "1/3"
				dbSelectarea("VV1")
				dbSetOrder(2)
				if dbSeek(xFilial("VV1")+M->VV0_CHASSI)
					RecLock("VV1",.f.)
					VV1->VV1_RESERV := ""
					VV1->VV1_DTHRES := ""
					VV1->VV1_DTHVAL := ""
					MsUnlock()
					M->VV0_RESERV := "0"
					M->VV0_DATVAL := ctod("")
					M->VV0_HORVAL := "     "
					VV0->(RecLock("VV0",.f.))
					VV0->VV0_RESERV := M->VV0_RESERV
					VV0->VV0_DATVAL := M->VV0_DATVAL
					VV0->VV0_HORVAL := M->VV0_HORVAL
					VV0->(MsUnlock())
					DbSelectArea(cSAlias)
					Return()
				EndIf
			Endif
		EndIf
	EndIf
	DbSelectArea(cSAlias)
EndIF

//Realiza a reserva do veiculo automaticamento caso nao esteja informada.
If !cChama $ "5" .and. lAchou .and. !M->VV0_RESERV="1"
	M->VV0_RESERV := "1"
	If Empty(M->VV0_DATVAL)
		M->VV0_DATVAL := dDataBase+nLimDia
	EndIf
	If Empty(M->VV0_HORVAL)
		M->VV0_HORVAL := SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)
	EndIf
	
	VV0->(RecLock("VV0",.f.))
	VV0->VV0_RESERV := M->VV0_RESERV
	VV0->VV0_DATVAL := M->VV0_DATVAL
	VV0->VV0_HORVAL := M->VV0_HORVAL
	VV0->(MsUnlock())
	
EndIF

If cChama =="5" // se for chamado pelo usuario ele retorna true para permitir o usuario reservar
	DbSelectArea(cSAlias)
	Return(.t.)
EndIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VA400LT   ºAutor  ³RAFAEL GONCALVES    º Data ³ 28/01/10    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Lista todas tarefas                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA400LT()
Local ni := 0
Local cPesqTar := ""
Local cQuery := ""
Local cQAlVAX := "SQLVAX"
Local nPos := 0
Private aTaref := {}
Private cPreTar := IIf(Empty(M->VZM_REQTAR),space(len(M->VZM_REQTAR)),M->VZM_REQTAR)
Private oNo      := LoadBitmap( GetResources(), "LBNO" )
Private oTik     := LoadBitmap( GetResources(), "LBTIK" )
cQuery := "SELECT VAX.VAX_CODTAR , VAX.VAX_DESTAR FROM "+RetSqlName("VAX")+" VAX WHERE VAX.VAX_FILIAL='"+xFilial("VAX")+"' AND VAX.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAX , .F., .T. )

While !( cQAlVAX )->( Eof() )
	aadd(aTaref,{ .f. , ( cQAlVAX )->( VAX_CODTAR ) , ( cQAlVAX )->( VAX_DESTAR ) })
	( cQAlVAX )->( DbSkip() )
EndDo
( cQAlVAX )->( dbCloseArea() )
DbSelectArea("VZM")

If Len(aTaref) < 1
	aAdd(aTaref,{ .f. , "" , "" })
Else
	if !Empty(M->VZM_REQTAR)
		For ni:=1 to 5
			if !Empty(Substr(M->VZM_REQTAR,(ni*7)-6,6))
				cPesqTar := Substr(M->VZM_REQTAR,(ni*7)-6,6)
				nPos := 0
				nPos := aScan(aTaref,{|x| x[2] == cPesqTar })
				if nPos > 0
					aTaref[nPos,1] := .t.
				EndIf
			EndIF
		Next
	EndIf
EndIF

DEFINE MSDIALOG oPreTar TITLE (STR0015) From 00,00 to 17,70 of oMainWnd
@ 02,180 BUTTON oOk  PROMPT OemToAnsi(STR0016) OF oPreTar SIZE 45,10 PIXEL ACTION (FS_TARTIK(),oPreTar:End())	// OK
@ 02,230 BUTTON oSair  PROMPT OemToAnsi(STR0017) OF oPreTar SIZE 45,10 PIXEL ACTION (oPreTar:End())	//sair

@ 015,002 LISTBOX oLbPreTar FIELDS HEADER OemToAnsi(""),;  //
OemToAnsi(""),;  	//
OemToAnsi(""),;  	//
COLSIZES 20,50,90,110 SIZE 274,110 OF oPreTar PIXEL ON DBLCLICK FS_TIKPAG(oLbPreTar:nAt)
oLbPreTar:SetArray(aTaref)
oLbPreTar:bLine := { || {IIf(aTaref[oLbPreTar:nAt,1],oTik,oNo),;
aTaref[oLbPreTar:nAt,2] ,;
aTaref[oLbPreTar:nAt,3] }}
ACTIVATE MSDIALOG oPreTar CENTER

M->VZM_REQTAR := cPreTar
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_TIKPAG ºAutor  ³RAFAEL GONCALVES    º Data ³ 28/01/10    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³³Realiza o Tik		                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIKPAG(nLinha)
Local ni := 1
Local nQtdOk := 0
If len(aTaref) >= 1 .or. !Empty(aTaref[1,1])
	For ni:=1 to len(aTaref)
		If aTaref[ni,1]
			nQtdOk := nQtdOk+1
		EndIF
	Next
	If aTaref[nLinha,1] .or. nQtdOk <5
		aTaref[nLinha,1] := !aTaref[nLinha,1]
	Else
		MsgInfo(STR0018,STR0003)// ### atencao
	EndIF
	
EndIf
Return()
//****************************//
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_TARTIK ºAutor  ³RAFAEL GONCALVES    º Data ³ 28/01/10    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³³Realiza a tarefas	                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TARTIK()
Local ni := 1
cPreTar := ""
For ni:=1 to len(aTaref)
	If aTaref[ni,1]
		cPreTar += aTaref[ni,2]+"/"
	EndIF
Next
cPretar := left(cPreTar+space(50),Len(VZM->VZM_REQTAR))
Return()
