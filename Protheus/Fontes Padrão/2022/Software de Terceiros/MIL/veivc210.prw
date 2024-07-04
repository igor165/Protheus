// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 26     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch" 
#include "VEIVC210.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006794_2"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVC210 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 11/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gerenciamento Depto. de Veiculos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VEIVC210(cPAREmp,aPAREmp)
Local ni        := 0
Local lDClik    := .f.
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cMesAtu   := right(left(dtos(dDataBase),6),2)+"/"+left(dtos(dDataBase),4)
/////////  PROVISORIO  //////////
Local cQuery    := ""
Local cSQLAlias := "VV0DATAPR"
/////////////////////////////////
Local nCont     := 0
Local cBkpFilAnt:= cFilAnt
Local cFilVV0   := ""
Private aFilAtu   := FWArrFilAtu()
Private aSM0    := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Private  lCodMar := VVA->(FieldPos("VVA_CODMAR")) > 0 
/////////////////////////////////
Private lMarcar := .f.
Private cVAIEstVei := "2" // 0=Novos / 1=Usados / 2=Ambos
Private aTotGru := {} // Grupo Total ( Novos + Usados )
Private aNovGru := {} // Grupo Novos
Private aUsaGru := {} // Grupo Usados
Private aLevVeic:= {} // Vetor dos Veiculos

Private aBkpVei := {} // Vetor dos Veiculos
Private aVeiculo := {} // Vetor dos Veiculos
Private aLevVei := {} // Vetor dos Veiculos
Private aFilVei := {} // Vetor dos Veiculos
Private aLevAten:= {} // Vetor dos Atendimentos
Private aAnaCpa := {} // Analitico Compra
Private aAnaPed := {} // Analitico Pedido
Private aAnaTra := {} // Analitico Transito
Private aAnaEst := {} // Analitico Estoque
Private aAnaADM := {} // Analitico Atendimento Dia/Mes
Private aAnaAAn := {} // Analitico Atendimento Meses Anteriores
Private nLin    := 0
Private nLinFil := 0
Private aAnaFtM := {} // Analitico Atendimento Faturados no Mes ( Mes + Vendas Mes )
Private aEmpFil := {}
Private aVetEmp := {}
Private aEmpr   := {} // Empresas Consolidadas
Private cEmpr   := "" // Nome da Empresa
Private lVV1_DTFATT := ( VV1->(FieldPos("VV1_DTFATT")) > 0 )
Private cStatApr := "'L'"
Default cPAREmp := ""
Default aPAREmp := aEmpr
DEFINE FONT oTitTela NAME "Arial" SIZE 11,13 BOLD
//
If ExistBlock("VC210STA")
	cStatApr := ExecBlock("VC210STA",.f.,.f.,) // Status dos Atendimentos a serem considerados como Atendimentos Aprovados - Default 'L'
EndIf
//
If len(aSM0) > 0
	cFilVV0 := "("
	For nCont := 1 to Len(aSM0)
		cFilAnt := aSM0[nCont]
		cFilVV0 += "'"+xFilial("VV0")+"',"
		aAdd( aEmpFil , { cFilAnt , FWFilialName() })
	Next
	cFilVV0 := left(cFilVV0,len(cFilVV0)-1)+")"
	cFilAnt := cBkpFilAnt
EndIf
/////////  PROVISORIO - PREENCHER DATA DE APROVACAO QUANDO O ATENDIMENTO JA ESTA FINALIZADO E AINDA NAO TEM A DATA DE APROVACAO //////////
DbSelectArea("VV0")
cQuery := "SELECT VV0.R_E_C_N_O_ AS RECVV0 FROM "+RetSqlName("VV0")+" VV0 "
cQuery += "INNER JOIN "+RetSqlName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VV0.VV0_FILIAL IN "+cFilVV0+" AND VV0.VV0_DATAPR=' ' AND VV0.VV0_DATMOV<>' ' AND VV9.VV9_STATUS IN ('F','T') AND VV0.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F., .T. )
Do While !( cSQLAlias )->( Eof() )
	If (cSQLAlias)->( RECVV0 ) > 0
		VV0->( DbGoTo( (cSQLAlias)->( RECVV0 ) ) )
	    RecLock("VV0",.f.)
	    	VV0->VV0_DATAPR := VV0->VV0_DATMOV
	    MsUnLock()
    EndIf
   	( cSQLAlias )->( DbSkip() )
EndDo
( cSQLAlias )->( dbCloseArea() )
/////////  PROVISORIO - PREENCHER DT.MOVIMENTO QUANDO O ATENDIMENTO JA ESTA APROVADO E A DT.APROVACAO E' MAIOR QUE A DT.MOVIMENTO //////////
DbSelectArea("VV0")
cQuery := "SELECT VV0.R_E_C_N_O_ AS RECVV0 FROM "+RetSqlName("VV0")+" VV0 "
cQuery += "INNER JOIN "+RetSqlName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VV0.VV0_FILIAL IN "+cFilVV0+" AND VV0.VV0_DATAPR<>' ' AND VV0.VV0_DATMOV < VV0.VV0_DATAPR AND VV9.VV9_STATUS='L' AND VV0.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F., .T. )
Do While !( cSQLAlias )->( Eof() )
	If (cSQLAlias)->( RECVV0 ) > 0
		VV0->( DbGoTo( (cSQLAlias)->( RECVV0 ) ) )
	    RecLock("VV0",.f.)
	    	VV0->VV0_DATMOV := VV0->VV0_DATAPR
	    MsUnLock()
    EndIf
   	( cSQLAlias )->( DbSkip() )
EndDo
( cSQLAlias )->( dbCloseArea() )
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
If VAI->(FieldPos("VAI_ESTVEI")) <> 0
	If !Empty(VAI->VAI_ESTVEI)
		cVAIEstVei := VAI->VAI_ESTVEI // 0=Novos / 1=Usados / 2=Ambos
	EndIf
EndIf
aEmpr := aPAREmp
If !Empty(cPAREmp)
	cEmpr := " - "+STR0005+": " // Consolidado:
	aEmpr := FS_FILIAIS() // Levantamento das Filiais
	If len(aEmpr) == 0
		MsgAlert(STR0003,STR0002) // Nao existem dados para esta Consulta ! / Atencao
		Return
	EndIf
Else
	aAdd(aEmpr,{ cFilAnt , aFilAtu[SM0_FILIAL] })
EndIf
If len(aEmpr) == 1 .and. (aEmpr[1,2]==aFilAtu[SM0_FILIAL])
	cEmpr := " - "+Alltrim(FWFilialName())+" ( "+aFilAtu[SM0_FILIAL]+" )"
EndIf
aInfo := { aSizeHalf[ 1 ] , aSizeHalf[ 2 ] , aSizeHalf[ 3 ] , aSizeHalf[ 4 ] , 3 , 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,  10 , .T. , .F. } ) // Filtro no topo
If cVAIEstVei == "0" .or. cVAIEstVei == "2" // Novos ou Todos
	aAdd( aObjects, { 0 ,  30 , .T. , .T. } ) // ListBox Grupo Novos
EndIf
If cVAIEstVei == "1" .or. cVAIEstVei == "2" // Usados ou Todos
	aAdd( aObjects, { 0 ,  30 , .T. , .T. } ) // ListBox Grupo Usados
EndIf
aPos := MsObjSize( aInfo, aObjects )
Processa( {|| FS_FILTGRU(0) } )
DEFINE MSDIALOG oGerDptVei FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
	oGerDptVei:lEscClose := .F.
	@ aPos[1,1],aPos[1,2] SAY STR0001 SIZE 500,10 OF oGerDptVei PIXEL COLOR CLR_RED FONT oTitTela // Gerenciamento Depto. de Veiculos
	ni := 1
	If cVAIEstVei == "0" .or. cVAIEstVei == "2" // Novos ou Todos
		ni++
		@ aPos[ni,1],aPos[ni,2] LISTBOX oLbNovGru FIELDS HEADER STR0015+" ( "+STR0007+" )" ,; // Grupo Modelo ( Novos )
														STR0016 ,; // Compra
														STR0017 ,; // Pedido
														STR0018 ,; // Transito
														STR0019 ,; // Estoque
														STR0020 ,; // Total
														STR0059 ,; // Vd.Fut.Apr.
														STR0040 ,; // Dia
														STR0041 ,; // Mes
														right(space(15)+STR0022,15)+" "+right(space(15)+STR0023+" "+STR0041,15) ,; // Pendentes / Vendas Mes
														STR0048 ; // Faturados no Mes
														COLSIZES aPos[2,4]-460,35,35,35,35,35,35,35,35,90,35 SIZE aPos[2,4]-2,aPos[2,3]-15 OF oGerDptVei ON DBLCLICK Processa( {|| FS_LEVANTA("N",oLbNovGru:nAt,oLbNovGru:nColPos) } ) PIXEL
		oLbNovGru:SetArray(aNovGru)
		oLbNovGru:bLine := { || { aNovGru[oLbNovGru:nAt,02] ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,03],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,04],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,05],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,06],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,07],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,17],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,08]+aNovGru[oLbNovGru:nAt,09],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,10]+aNovGru[oLbNovGru:nAt,11],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,12],"@EZ 9,999,999"))+FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,13],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,16],"@EZ 9,999,999")) }}
    EndIf
	If cVAIEstVei == "1" .or. cVAIEstVei == "2" // Usados ou Todos
        ni++
		@ aPos[ni,1],aPos[ni,2] LISTBOX oLbUsaGru FIELDS HEADER STR0015+" ( "+STR0008+" )" ,; // Grupo Modelo ( Usados )
														STR0016 ,; // Compra
														STR0017 ,; // Pedido
														STR0018 ,; // Transito
														STR0019 ,; // Estoque
														STR0020 ,; // Total
														STR0060 ,; // Av.Usad.Apr.
														STR0040 ,; // Dia
														STR0041 ,; // Mes
														right(space(15)+STR0022,15)+" "+right(space(15)+STR0023+" "+STR0041,15) ,; // Pendentes / Vendas Mes
														STR0048 ; // Faturados no Mes
														COLSIZES aPos[2,4]-460,35,35,35,35,35,35,35,35,90,35 SIZE aPos[2,4]-2,aPos[2,3]-15 OF oGerDptVei ON DBLCLICK Processa( {|| FS_LEVANTA("U",oLbUsaGru:nAt,oLbUsaGru:nColPos) } ) PIXEL
		oLbUsaGru:SetArray(aUsaGru)
		oLbUsaGru:bLine := { || { aUsaGru[oLbUsaGru:nAt,02] ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,03],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,04],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,05],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,06],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,07],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,17],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,08]+aUsaGru[oLbUsaGru:nAt,09],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,10]+aUsaGru[oLbUsaGru:nAt,11],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,12],"@EZ 9,999,999"))+FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,13],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,16],"@EZ 9,999,999")) }}
	EndIf
	If cVAIEstVei == "2"
		@ aPos[1,1],aPos[1,4]-205 BUTTON oTotGru  PROMPT UPPER(STR0007+" + "+STR0008) OF oGerDptVei SIZE 55,10 PIXEL ACTION (FS_TOTGRU()) // Total
	EndIf
	@ aPos[1,1],aPos[1,4]-145 BUTTON oAtualiz PROMPT UPPER(STR0021) OF oGerDptVei SIZE 45,10 PIXEL ACTION Processa( {|| FS_FILTGRU(1) } ) // Atualizar  (lDClik:=.t.,oGerDptVei:End())
	@ aPos[1,1],aPos[1,4]-095 BUTTON oEmpr    PROMPT UPPER(STR0009) OF oGerDptVei SIZE 45,10 PIXEL ACTION (lDClik:=.t.,oGerDptVei:End()) // Filiais
	@ aPos[1,1],aPos[1,4]-045 BUTTON oGrpSair PROMPT STR0010 OF oGerDptVei SIZE 45,10 PIXEL ACTION oGerDptVei:End() // SAIR
ACTIVATE MSDIALOG oGerDptVei
If lDClik
	VEIVC210(cEmpr,aEmpr)
EndIf
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FILTGRU ³ Autor ³  Andre Luis Almeida ³ Data ³ 11/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra Grupo do Modelo                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_FILTGRU(nTp)
Local cEstVei  := ""
Local aAux     := {}
Local ni       := 0
Local nj       := 0
Local lOk      := .f.
Local cQuery   := ""
Local cQAlias  := "SQLs"   // SQLs
Local cQAlAux  := "SQLAux" // SQL Auxiliar
Local nEmpr    := 0
Local dDatIni  := (dDataBase-day(dDataBase)+1)
Local cGruVei  := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Local nTamVV9  := TamSx3("VV9_NUMATE")[1]
Local nPos     := 0
Local nCol     := 0
Local nADia    := 0 // Aprovadas Dia
Local nVDia    := 0 // Aprovadas x Vendas Dia
Local nAMes    := 0 // Aprovadas Mes
Local nVMes    := 0 // Aprovadas x Vendas Mes
Local cLbCor   := ""
Local aQUltMov := {}
Local cBkpFilAnt := cFilAnt
Local nCont    := 0
Local cFilAux  := ""
Local lTIPMOV  := ( VVF->(FieldPos("VVF_TIPMOV")) > 0 ) // Tipo de Movimento ( Normal / Agregacao / Desagregacao )

aAnaCpa := {} // Analitico Compra
aAnaPed := {} // Analitico Pedido
aAnaTra := {} // Analitico Transito
aAnaEst := {} // Analitico Estoque
aAnaADM := {} // Analitico Atendimento Dia/Mes
aAnaAAn := {} // Analitico Atendimento Meses Anteriores
aAnaFtM := {} // Analitico Atendimento Faturados no Mes ( Mes + Vendas Mes )
aTotGru := {}
aNovGru := {}
aUsaGru := {}
aAdd(aNovGru,{"0",UPPER(STR0020+" ( "+STR0007+" )"),0,0,0,0,0,0,0,0,0,0,0,"","",0,0}) // TOTAL ( NOVOS )
aAdd(aUsaGru,{"0",UPPER(STR0020+" ( "+STR0008+" )"),0,0,0,0,0,0,0,0,0,0,0,"","",0,0}) // TOTAL ( USADOS )

VV1->(DbSetOrder(1))
ProcRegua((len(aEmpr)*len(aSM0))+5)

IncProc(STR0014) // Levantando...

cFilSB1 := ""
cFilVV1 := ""
cFilVV2 := ""
cFilVVR := ""
cFilSD1 := ""
cFilVVF := ""
cFilVV9 := ""
cFilVAZ := ""
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	cFilAux := xFilial("SB1")
	cFilSB1 += IIf(!("'"+cFilAux+"'")$cFilSB1,"'"+cFilAux+"',","") // SB1 - inserir Filial caso a mesma nao esteja na variavel de controle
	cFilAux := xFilial("VV1")
	cFilVV1 += IIf(!("'"+cFilAux+"'")$cFilVV1,"'"+cFilAux+"',","") // VV1 - inserir Filial caso a mesma nao esteja na variavel de controle
	cFilAux := xFilial("VV2")
	cFilVV2 += IIf(!("'"+cFilAux+"'")$cFilVV2,"'"+cFilAux+"',","") // VV2 - inserir Filial caso a mesma nao esteja na variavel de controle
	cFilAux := xFilial("VVR")
	cFilVVR += IIf(!("'"+cFilAux+"'")$cFilVVR,"'"+cFilAux+"',","") // VVR - inserir Filial caso a mesma nao esteja na variavel de controle
	cFilAux := xFilial("SD1")
	cFilSD1 += IIf(!("'"+cFilAux+"'")$cFilSD1,"'"+cFilAux+"',","") // SD1 - inserir Filial caso a mesma nao esteja na variavel de controle
	cFilAux := xFilial("VVF")
	cFilVVF += IIf(!("'"+cFilAux+"'")$cFilVVF,"'"+cFilAux+"',","") // VVF - inserir Filial caso a mesma nao esteja na variavel de controle
	cFilAux := xFilial("VV9")
	cFilVV9 += IIf(!("'"+cFilAux+"'")$cFilVV9,"'"+cFilAux+"',","") // VV9 - inserir Filial caso a mesma nao esteja na variavel de controle
	cFilAux := xFilial("VAZ")
	cFilVAZ += IIf(!("'"+cFilAux+"'")$cFilVAZ,"'"+cFilAux+"',","") // VAZ - inserir Filial caso a mesma nao esteja na variavel de controle
Next
cFilSB1 := left(cFilSB1,len(cFilSB1)-1)
cFilVV1 := left(cFilVV1,len(cFilVV1)-1)
cFilVV2 := left(cFilVV2,len(cFilVV2)-1)
cFilVVR := left(cFilVVR,len(cFilVVR)-1)
cFilSD1 := left(cFilSD1,len(cFilSD1)-1)
cFilVVF := left(cFilVVF,len(cFilVVF)-1)
cFilVV9 := left(cFilVV9,len(cFilVV9)-1)
cFilVAZ := left(cFilVAZ,len(cFilVAZ)-1)
cFilAnt := cBkpFilAnt

////////////////////////////////////////////////////////////////
// COMPRA // CONSOLIDADO (TODAS FILIAIS)                      //
////////////////////////////////////////////////////////////////
nCol   := 3
cQuery := "SELECT VV1.VV1_CHAINT , VV1.VV1_CODMAR , VV1.VV1_TIPVEI , VV2.VV2_GRUMOD , VVR.VVR_DESCRI , SD1.R_E_C_N_O_ SD1RECNO , SD1.D1_FORNECE , SD1.D1_LOJA , SD1.D1_DOC , SD1.D1_SERIE FROM "+RetSqlName("SD1")+" SD1 "
cQuery += "LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL IN ("+cFilSB1+") AND SB1.B1_COD=SD1.D1_COD AND SB1.D_E_L_E_T_=' ' "
cQuery += "LEFT JOIN "+RetSqlName("VV1")+" VV1 ON VV1.VV1_FILIAL IN ("+cFilVV1+") AND VV1.VV1_CHAINT=SB1.B1_CODITE AND VV1.D_E_L_E_T_=' ' "
cQuery += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON VV2.VV2_FILIAL IN ("+cFilVV2+") AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' "
cQuery += "LEFT JOIN "+RetSqlName("VVR")+" VVR ON VVR.VVR_FILIAL IN ("+cFilVVR+") AND VVR.VVR_CODMAR=VV1.VV1_CODMAR AND VVR.VVR_GRUMOD=VV2.VV2_GRUMOD AND VVR.D_E_L_E_T_=' ' "
cQuery += "WHERE SD1.D1_FILIAL IN ("+cFilSD1+") AND SD1.D1_DTDIGIT>='"+dtos(dDatIni)+"' AND SD1.D1_DTDIGIT<='"+dtos(dDataBase)+"' AND SD1.D1_GRUPO='"+cGruVei+"' AND SD1.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
Do While !( cQAlias )->( Eof() )
	nPos := FS_NPOSAADD(( cQAlias )->( VV1_TIPVEI ),( cQAlias )->( VV1_CODMAR ),( cQAlias )->( VVR_DESCRI ),( cQAlias )->( VV2_GRUMOD ))
	cQuery := "SELECT VVG.VVG_ESTVEI FROM "+RetSqlName("VVF")+" VVF "
	cQuery += "INNER JOIN "+RetSqlName("VVG")+" VVG ON VVG.VVG_FILIAL=VVF.VVF_FILIAL AND VVG.VVG_TRACPA=VVF.VVF_TRACPA AND VVG.VVG_CHAINT='"+( cQAlias )->( VV1_CHAINT )+"' AND VVG.D_E_L_E_T_=' ' "
	cQuery += "WHERE VVF.VVF_FILIAL IN ("+cFilVVF+") AND VVF.VVF_NUMNFI='"+( cQAlias )->( D1_DOC )+"' AND VVF.VVF_SERNFI='"+( cQAlias )->( D1_SERIE )+"' AND VVF.VVF_CODFOR='"+( cQAlias )->( D1_FORNECE )+"' AND VVF.VVF_LOJA='"+( cQAlias )->( D1_LOJA )+"' AND VVF.VVF_OPEMOV='0' AND VVF.D_E_L_E_T_=' '"
	If lTIPMOV
		cQuery += " AND VVF.VVF_TIPMOV IN (' ','0')"
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
	If !( cQAlAux )->( Eof() )
		cEstVei := ( cQAlAux )->( VVG_ESTVEI )
		If Empty(cEstVei)
			cEstVei := "0"
		EndIf
		If cEstVei == "0" // Novos
			aNovGru[1,nCol]++
			aNovGru[nPos,nCol]++
		Else // Usados
			aUsaGru[1,nCol]++
			aUsaGru[nPos,nCol]++
		EndIf
		// Analitico por Compra //
		aAdd(aAnaCpa,{aNovGru[nPos,1],aNovGru[nPos,14],aNovGru[nPos,15],cEstVei,( cQAlias )->( SD1RECNO ),"SD1"})
	EndIf
	( cQAlAux )->( dbCloseArea() )
   	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )

IncProc(STR0014) // Levantando...

////////////////////////////////////////////////////////////////
// PEDIDOS NOVOS / USADOS // CONSOLIDADO (TODAS FILIAIS)      //
////////////////////////////////////////////////////////////////
nCol   := 4
cQuery := "SELECT VV1.R_E_C_N_O_ AS VV1RECNO , VV1.VV1_CODMAR , VV2.VV2_GRUMOD , VVR.VVR_DESCRI , VV1.VV1_ESTVEI , VV1.VV1_TIPVEI "
cQuery += " FROM "+RetSqlName("VV1")+" VV1 "
cQuery += "INNER JOIN "+RetSqlName("VV2")+" VV2"
cQuery += 		" ON VV2.VV2_FILIAL IN ("+cFilVV2+") "
cQuery += 		"AND VV2.VV2_CODMAR = VV1.VV1_CODMAR "
cQuery += 		"AND VV2.VV2_MODVEI = VV1.VV1_MODVEI "
cQuery += 		"AND VV2.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN "+RetSqlName("VVR")+" VVR "
cQuery += 		" ON VVR.VVR_FILIAL='"+xFilial("VVR")+"' "
cQuery += 		"AND VVR.VVR_CODMAR = VV2.VV2_CODMAR "
cQuery += 		"AND VVR.VVR_GRUMOD = VV2.VV2_GRUMOD "
cQuery += 		"AND VVR.D_E_L_E_T_ = ' ' "
cQuery += "WHERE VV1.VV1_FILIAL IN ("+cFilVV1+") "
If cVAIEstVei <> "2" // Diferente de Ambos
	cQuery += 	"AND VV1.VV1_ESTVEI = '"+cVAIEstVei+"' " // 0-Novos ou 1-Usados
EndIf
cQuery += 		"AND VV1.VV1_SITVEI = '8' " // 8-Pedido
cQuery += 		"AND VV1.D_E_L_E_T_ = ' ' " 
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
Do While !( cQAlias )->( Eof() )
	If ( cQAlias )->( VV1_ESTVEI ) == "0" // NOVOS
		nPos := FS_NPOSAADD("1",( cQAlias )->( VV1_CODMAR ),( cQAlias )->( VVR_DESCRI ),( cQAlias )->( VV2_GRUMOD ))
		// Novos
		aNovGru[1,nCol]++
		aNovGru[1,7]++
		aNovGru[nPos,nCol]++
		aNovGru[nPos,7]++
		// Analitico por Pedido Novos //
		aAdd(aAnaPed,{aNovGru[nPos,1],aNovGru[nPos,14],aNovGru[nPos,15],"0",( cQAlias )->( VV1RECNO )})
	ElseIf ( cQAlias )->( VV1_ESTVEI ) == "1" // USADOS
		nPos := FS_NPOSAADD(( cQAlias )->( VV1_TIPVEI ),( cQAlias )->( VV1_CODMAR ),( cQAlias )->( VVR_DESCRI ),( cQAlias )->( VV2_GRUMOD ))
		// Usados
		aUsaGru[1,nCol]++
		aUsaGru[1,7]++
		aUsaGru[nPos,nCol]++
		aUsaGru[nPos,7]++
		// Analitico por Pedido Usados //
		aAdd(aAnaPed,{aUsaGru[nPos,1],aUsaGru[nPos,14],aUsaGru[nPos,15],"1",( cQAlias )->( VV1RECNO )})
	EndIf
   	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )

If cVAIEstVei == "0" .or. cVAIEstVei == "2" // Novos / Ambos

	////////////////////////////////////////////////////////////////////////
	// VENDA FUTURA APROVADA NOVOS / TOTAL // CONSOLIDADO (TODAS FILIAIS) //
	////////////////////////////////////////////////////////////////////////
	nCol   := 17
	cQuery := "SELECT VV0.R_E_C_N_O_ VV0RECNO , VV0.VV0_FILIAL ,"
	If lCodMar
		cQuery += "VVA.VVA_CODMAR CODMAR , VVA.VVA_MODVEI MODVEI"
	Else
		cQuery += "VV0.VV0_CODMAR CODMAR , VV0.VV0_MODVEI MODVEI"
	Endif	
	cQuery +=  " FROM "+RetSqlName("VV9")+" VV9 "
	cQuery += "INNER JOIN "+RetSqlName("VV0")+" VV0 ON VV0.VV0_FILIAL=VV9.VV9_FILIAL AND VV0.VV0_NUMTRA=VV9.VV9_NUMATE AND VV0.VV0_TIPFAT IN ('0','1') AND VV0.VV0_VDAFUT='1' AND VV0.D_E_L_E_T_=' ' "
	cQuery += "INNER JOIN "+RetSqlName("VVA")+" VVA ON VVA.VVA_FILIAL=VV9.VV9_FILIAL AND VVA.VVA_NUMTRA=VV9.VV9_NUMATE AND VVA.D_E_L_E_T_=' ' "
	cQuery += "WHERE VV9.VV9_FILIAL IN ("+cFilVV9+") AND VV9.VV9_STATUS='L' AND VV9.D_E_L_E_T_=' '" 
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	Do While !( cQAlias )->( Eof() )
		cQuery := "SELECT VV2.VV2_GRUMOD , VVR.VVR_DESCRI FROM "+RetSqlName("VV2")+" VV2 "
		cQuery += "INNER JOIN "+RetSqlName("VVR")+" VVR ON VVR.VVR_FILIAL='"+xFilial("VVR")+"' AND VVR.VVR_CODMAR=VV2.VV2_CODMAR AND VVR.VVR_GRUMOD=VV2.VV2_GRUMOD AND VVR.D_E_L_E_T_=' ' "
		cQuery += "WHERE VV2.VV2_FILIAL IN ("+cFilVV2+") AND VV2.VV2_CODMAR='"+( cQAlias )->( CODMAR )+"' AND VV2.VV2_MODVEI='"+( cQAlias )->( MODVEI )+"' AND VV2.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
		If !( cQAlAux )->( Eof() )
			nPos := FS_NPOSAADD("1",( cQAlias )->( CODMAR ),( cQAlAux )->( VVR_DESCRI ),( cQAlAux )->( VV2_GRUMOD ))
			// Novos
			aNovGru[1,nCol]++
			aNovGru[nPos,nCol]++
		EndIf
		( cQAlAux )->( dbCloseArea() )		
	   	( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
EndIf
IncProc(STR0014) // Levantando...

If cVAIEstVei == "1" .or. cVAIEstVei == "2" // Usados / Ambos

	//////////////////////////////////////////////////////////////////////
	// AVALIACAO APROVADA USADOS / TOTAL // CONSOLIDADO (TODAS FILIAIS) //
	//////////////////////////////////////////////////////////////////////
	nCol   := 17
	cQuery := "SELECT TEMP.* , VAZ2.R_E_C_N_O_ VAZRECNO FROM ( SELECT VAZ_CHASSI , VAZ_FILIAL , VS9_NUMIDE , MAX(VAZ_REVISA) VAZ_REVISA FROM "+RetSqlName("VAZ")+" VAZ "
	cQuery += "INNER JOIN "+RetSqlName("VS9")+" VS9 ON ( VS9.VS9_FILIAL=VAZ.VAZ_FILIAL AND VS9.VS9_REFPAG=VAZ.VAZ_CODIGO AND VS9.D_E_L_E_T_=' ' ) "
	cQuery += "INNER JOIN "+RetSqlName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VS9.VS9_FILIAL AND VV9.VV9_NUMATE=VS9.VS9_NUMIDE AND VV9.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VAZ.VAZ_FILIAL IN ("+cFilVAZ+") AND VAZ.VAZ_APROVA IN ('1','2') AND VAZ.D_E_L_E_T_=' ' AND VV9.VV9_STATUS='L' "
	cQuery += "GROUP BY VAZ_CHASSI , VAZ_FILIAL , VS9_NUMIDE ) TEMP JOIN "+RetSqlName("VAZ")+" VAZ2 ON VAZ2.VAZ_FILIAL IN ("+cFilVAZ+") AND VAZ2.VAZ_CHASSI=TEMP.VAZ_CHASSI AND VAZ2.VAZ_REVISA=TEMP.VAZ_REVISA"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	Do While !( cQAlias )->( Eof() )
		cQuery := "SELECT VV1.VV1_CODMAR , VV1.VV1_TIPVEI , VV2.VV2_GRUMOD , VVR.VVR_DESCRI FROM "+RetSqlName("VV1")+" VV1 "
		cQuery += "INNER JOIN "+RetSqlName("VV2")+" VV2 ON VV2.VV2_FILIAL IN ("+cFilVV2+") AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' "
		cQuery += "INNER JOIN "+RetSqlName("VVR")+" VVR ON VVR.VVR_FILIAL IN ("+cFilVVR+") AND VVR.VVR_CODMAR=VV1.VV1_CODMAR AND VVR.VVR_GRUMOD=VV2.VV2_GRUMOD AND VVR.D_E_L_E_T_=' ' "
		cQuery += "WHERE VV1.VV1_FILIAL IN ("+cFilVV1+") AND VV1.VV1_CHASSI='"+( cQAlias )->( VAZ_CHASSI )+"' AND VV1.VV1_SITVEI NOT IN ('0','2','3') AND VV1.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
		nPos := 0
		If !( cQAlAux )->( Eof() )
			nPos := FS_NPOSAADD(( cQAlAux )->( VV1_TIPVEI ),( cQAlAux )->( VV1_CODMAR ),( cQAlAux )->( VVR_DESCRI ),( cQAlAux )->( VV2_GRUMOD ))
		EndIf
		( cQAlAux )->( dbCloseArea() )
		If nPos > 0
			// Usados
			aUsaGru[1,nCol]++
			aUsaGru[nPos,nCol]++
		EndIf
	   	( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
EndIf
IncProc(STR0014) // Levantando...

////////////////////////////////////////////////////////////////
// TRANSITO / ESTOQUE / TOTAL // CONSOLIDADO (TODAS FILIAIS)  //
////////////////////////////////////////////////////////////////
cQuery := "SELECT DISTINCT VV1.R_E_C_N_O_ VV1RECNO , VV1.VV1_CHASSI , VV1.VV1_CHAINT , VV1.VV1_TIPVEI , VV1.VV1_ESTVEI , VV1.VV1_SITVEI , VV1.VV1_TRACPA , VV1.VV1_CODMAR , VV2.VV2_GRUMOD , VVR.VVR_DESCRI "
If lVV1_DTFATT // Dias de Transito
	cQuery += ", VV1.VV1_DTFATT "
EndIf
cQuery += "FROM "+RetSqlName("VV1")+" VV1 "
cQuery += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON VV2.VV2_FILIAL IN ("+cFilVV2+") AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' "
cQuery += "LEFT JOIN "+RetSqlName("VVR")+" VVR ON VVR.VVR_FILIAL IN ("+cFilVVR+") AND VVR.VVR_CODMAR=VV1.VV1_CODMAR AND VVR.VVR_GRUMOD=VV2.VV2_GRUMOD AND VVR.D_E_L_E_T_=' ' "
cQuery += "WHERE VV1.VV1_FILIAL IN ("+cFilVV1+") AND VV1.VV1_SITVEI IN ('0','2','3') AND VV1.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
Do While !( cQAlias )->( Eof() )
	nCol := 0
	If ( cQAlias )->( VV1_SITVEI ) == "2" // Transito
		nCol := 5
	ElseIf ( cQAlias )->( VV1_SITVEI ) == "3" // Remessa
		aQUltMov := FM_VEIUMOV( ( cQAlias )->( VV1_CHASSI ) )
		If len(aQUltMov) > 0
			If aQUltMov[1] == "S" // SAIDA
				If aQUltMov[4] <> "7" // Remessa
					nCol := 6
				EndIf
			EndIf
		EndIf
	ElseIf !Empty(( cQAlias )->( VV1_TRACPA )) // Estoque
		nCol := 6
	EndIf
	If nCol > 0
		nPos   := FS_NPOSAADD(( cQAlias )->( VV1_TIPVEI ),( cQAlias )->( VV1_CODMAR ),( cQAlias )->( VVR_DESCRI ),( cQAlias )->( VV2_GRUMOD ))
		lOk    := .f.
		cQuery := "SELECT VVA.VVA_CHAINT FROM "+RetSqlName("VV9")+" VV9 "
		cQuery += "INNER JOIN "+RetSqlName("VV0")+" VV0 ON VV0.VV0_FILIAL=VV9.VV9_FILIAL AND VV0.VV0_NUMTRA=VV9.VV9_NUMATE AND VV0.VV0_TIPFAT IN ('0','1') AND VV0.D_E_L_E_T_=' ' "
		cQuery += "INNER JOIN "+RetSqlName("VVA")+" VVA ON VVA.VVA_FILIAL=VV9.VV9_FILIAL AND VVA.VVA_NUMTRA=VV9.VV9_NUMATE AND VVA.D_E_L_E_T_=' ' "
		cQuery += "WHERE VV9.VV9_FILIAL IN ("+cFilVV9+") AND VV9.VV9_STATUS='L' AND VV9.D_E_L_E_T_=' ' AND VVA.VVA_CHAINT='"+( cQAlias )->( VV1_CHAINT )+"'" 
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
		If ( cQAlAux )->( Eof() ) .or. Empty(( cQAlAux )->( VVA_CHAINT ))
			lOk := .t.
		EndIf
		( cQAlAux )->( dbCloseArea() )
		If lOk
			cEstVei := ( cQAlias )->( VV1_ESTVEI )
			If Empty(cEstVei)
				cEstVei := "0"
			EndIf
			If cEstVei == "0" // Novos
				aNovGru[1,nCol]++
				aNovGru[1,7]++
				aNovGru[nPos,nCol]++
				aNovGru[nPos,7]++					
			Else // Usados
				aUsaGru[1,nCol]++
				aUsaGru[1,7]++
				aUsaGru[nPos,nCol]++
				aUsaGru[nPos,7]++
			EndIf
 			If nCol == 5 // Analitico por Transito // 
				aAdd(aAnaTra,{aNovGru[nPos,1],aNovGru[nPos,14],aNovGru[nPos,15],cEstVei,( cQAlias )->( VV1RECNO )})
				If lVV1_DTFATT // Dias de Transito
					If !Empty(( cQAlias )->( VV1_DTFATT )) .and. stod(( cQAlias )->( VV1_DTFATT )) >= dDatIni
						// Analitico por Compra - Inserir os Veiculos em Transito //
						nCol := 3
						If cEstVei == "0" // Novos
							aNovGru[1,nCol]++
							aNovGru[nPos,nCol]++
						Else // Usados
							aUsaGru[1,nCol]++
							aUsaGru[nPos,nCol]++
						EndIf
						aAdd(aAnaCpa,{aNovGru[nPos,1],aNovGru[nPos,14],aNovGru[nPos,15],cEstVei,( cQAlias )->( VV1RECNO ),"VV1"})
					EndIf
				EndIf
        	Else // Analitico por Estoque // 
				aAdd(aAnaEst,{aNovGru[nPos,1],aNovGru[nPos,14],aNovGru[nPos,15],cEstVei,( cQAlias )->( VV1RECNO )})
			EndIf
		EndIf
	EndIf
   	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
IncProc(STR0014) // Levantando...
//FilAnt := cBkpFilAnt

cFilVV9 := ""
cFilVV2 := ""
cFilVVR := ""
cFilVV1 := ""
For nCont := 1 to Len(aEmpr)
	IncProc(STR0014) // Levantando...
	cFilAnt := aEmpr[nCont,1]
	cFilAux := xFilial("VV9")
	cFilVV9 += IIf(!("'"+cFilAux+"'")$cFilVV9,"'"+cFilAux+"',","") // VV9 - inserir Filial caso a mesma nao esteja na variavel de controle
	cFilAux := xFilial("VV2")
	cFilVV2 += IIf(!("'"+cFilAux+"'")$cFilVV2,"'"+cFilAux+"',","") // VV2 - inserir Filial caso a mesma nao esteja na variavel de controle
	cFilAux := xFilial("VVR")
	cFilVVR += IIf(!("'"+cFilAux+"'")$cFilVVR,"'"+cFilAux+"',","") // VVR - inserir Filial caso a mesma nao esteja na variavel de controle
	cFilAux := xFilial("VV1")
	cFilVV1 += IIf(!("'"+cFilAux+"'")$cFilVV1,"'"+cFilAux+"',","") // VV1 - inserir Filial caso a mesma nao esteja na variavel de controle
Next
cFilVV9 := left(cFilVV9,len(cFilVV9)-1)
cFilVV2 := left(cFilVV2,len(cFilVV2)-1)
cFilVVR := left(cFilVVR,len(cFilVVR)-1)
cFilVV1 := left(cFilVV1,len(cFilVV1)-1)
cFilAnt := cBkpFilAnt

////////////////////////////////////////////////////////////////
// PROPOSTAS APROVADAS NO DIA E MES / VENDAS NO DIA E MES     //
////////////////////////////////////////////////////////////////
cQuery := "SELECT DISTINCT VV9.R_E_C_N_O_ VV9RECNO , VV9.VV9_FILIAL , VV9.VV9_STATUS , VV0.VV0_TIPFAT , VV0.VV0_DATMOV , VV0.VV0_DATAPR , VVA.VVA_CHAINT ,"
If lCodMar
	cQuery += "VVA.VVA_CODMAR CODMAR , VVA.VVA_MODVEI MODVEI"
Else
	cQuery += "VV0.VV0_CODMAR CODMAR , VV0.VV0_MODVEI MODVEI"
Endif	
cQuery +=  " FROM "+RetSqlName("VV9")+" VV9 "
cQuery += "INNER JOIN "+RetSqlName("VV0")+" VV0 ON VV0.VV0_FILIAL=VV9.VV9_FILIAL AND VV0.VV0_NUMTRA=VV9.VV9_NUMATE AND VV0.VV0_TIPFAT IN ('0','1') AND VV0.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSqlName("VVA")+" VVA ON VVA.VVA_FILIAL=VV9.VV9_FILIAL AND VVA.VVA_NUMTRA=VV9.VV9_NUMATE AND VVA.D_E_L_E_T_=' ' "
cQuery += "WHERE VV9.VV9_FILIAL IN ("+cFilVV9+") AND VV9.VV9_STATUS IN ('F','T',"+cStatApr+") AND VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDataBase)+"' AND VV0.VV0_DATAPR>='"+dtos(dDatIni)+"' AND VV0.VV0_DATAPR<='"+dtos(dDataBase)+"' AND VV9.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
Do While !( cQAlias )->( Eof() )
	nADia := 0 // Aprovadas Dia
	nVDia := 0 // Aprovadas x Vendas Dia
	nAMes := 0 // Aprovadas Mes
	nVMes := 0 // Aprovadas x Vendas Mes
	cLbCor := ""
	If dDataBase == stod(( cQAlias )->( VV0_DATAPR ))
		nADia  := 1
		nAMes  := 1
		cLbCor := "Verm"
	Else // If month(dDataBase) == month(stod(( cQAlias )->( VV0_DATAPR )))
		nAMes  := 1
		cLbCor := "Verm"
	EndIf
	If ( cQAlias )->( VV9_STATUS ) $ "F/T" // Atendimentos Finalizados (Vendas)
		If dDataBase == stod(( cQAlias )->( VV0_DATMOV )) .and. nADia == 1 // Aprovadas x Vendas Dia
			nADia  := 0
			nAMes  := 0
			nVDia  := 1
			nVMes  := 1
			cLbCor := "Verd"
		Else // If month(dDataBase) == month(stod(( cQAlias )->( VV0_DATMOV )))
			If nAMes == 1 // Aprovadas x Vendas Mes
				nAMes  := 0
				nVMes  := 1
				cLbCor := "Verd"
			EndIf
		EndIf
	EndIf
	If !Empty(( cQAlias )->( VVA_CHAINT ))
		cQuery := "SELECT VV1.VV1_TIPVEI , VV2.VV2_GRUMOD , VVR.VVR_DESCRI FROM "+RetSqlName("VV1")+" VV1 "
		cQuery += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON VV2.VV2_FILIAL IN ("+cFilVV2+") AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' "
		cQuery += "LEFT JOIN "+RetSqlName("VVR")+" VVR ON VVR.VVR_FILIAL IN ("+cFilVVR+") AND VVR.VVR_CODMAR=VV1.VV1_CODMAR AND VVR.VVR_GRUMOD=VV2.VV2_GRUMOD AND VVR.D_E_L_E_T_=' ' "
		cQuery += "WHERE VV1.VV1_FILIAL IN ("+cFilVV1+") AND VV1.VV1_CHAINT='"+( cQAlias )->( VVA_CHAINT )+"' AND VV1.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
		If !( cQAlAux )->( Eof() )
			nPos := FS_NPOSAADD(( cQAlAux )->( VV1_TIPVEI ),( cQAlias )->( CODMAR ),( cQAlAux )->( VVR_DESCRI ),( cQAlAux )->( VV2_GRUMOD ))
		EndIf
		( cQAlAux )->( dbCloseArea() )
	Else
		cQuery := "SELECT VV2.VV2_GRUMOD , VVR.VVR_DESCRI FROM "+RetSqlName("VV2")+" VV2 "
		cQuery += "LEFT JOIN "+RetSqlName("VVR")+" VVR ON VVR.VVR_FILIAL IN ("+cFilVVR+") AND VVR.VVR_CODMAR=VV2.VV2_CODMAR AND VVR.VVR_GRUMOD=VV2.VV2_GRUMOD AND VVR.D_E_L_E_T_=' ' "
		cQuery += "WHERE VV2.VV2_FILIAL IN ("+cFilVV2+") AND VV2.VV2_CODMAR='"+( cQAlias )->( CODMAR )+"' AND VV2.VV2_MODVEI='"+( cQAlias )->( MODVEI )+"' AND VV2.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
		If !( cQAlAux )->( Eof() )
			nPos := FS_NPOSAADD("1",( cQAlias )->( CODMAR ),( cQAlAux )->( VVR_DESCRI ),( cQAlAux )->( VV2_GRUMOD ))
		EndIf
		( cQAlAux )->( dbCloseArea() )
	EndIf
	If nPos > 0
		If ( cQAlias )->( VV0_TIPFAT ) == "0" // Novos
			aNovGru[1,08] += nADia // Aprovadas Dia
			aNovGru[1,09] += nVDia // Aprovadas x Vendas Dia
			aNovGru[1,10] += nAMes // Aprovadas Mes
			aNovGru[1,11] += nVMes // Aprovadas x Vendas Mes
			aNovGru[nPos,08] += nADia // Aprovadas Dia
			aNovGru[nPos,09] += nVDia // Aprovadas x Vendas Dia
			aNovGru[nPos,10] += nAMes // Aprovadas Mes
			aNovGru[nPos,11] += nVMes // Aprovadas x Vendas Mes
			If nVMes > 0
				aNovGru[1,16] += nVMes // Faturadados no Mes
				aNovGru[nPos,16] += nVMes // Faturadados no Mes
			EndIf
		Else // ( cQAlias )->( VV0_TIPFAT ) == "1" // Usados
			aUsaGru[1,08] += nADia // Aprovadas Dia
			aUsaGru[1,09] += nVDia // Aprovadas x Vendas Dia
			aUsaGru[1,10] += nAMes // Aprovadas Mes
			aUsaGru[1,11] += nVMes // Aprovadas x Vendas Mes
			aUsaGru[nPos,08] += nADia // Aprovadas Dia
			aUsaGru[nPos,09] += nVDia // Aprovadas x Vendas Dia
			aUsaGru[nPos,10] += nAMes // Aprovadas Mes
			aUsaGru[nPos,11] += nVMes // Aprovadas x Vendas Mes
			If nVMes > 0
				aUsaGru[1,16] += nVMes // Faturadados no Mes
				aUsaGru[nPos,16] += nVMes // Faturadados no Mes
			EndIf
		EndIf
		// Analitico por Atendimento no Dia / Mes //
		aAdd(aAnaADM,{aNovGru[nPos,1],aNovGru[nPos,14],aNovGru[nPos,15],( cQAlias )->( VV0_TIPFAT ),( cQAlias )->( VV9RECNO ),strzero(nADia,1)+strzero(nVDia,1),( cQAlias )->( VV9_FILIAL ),cLbCor})
		If nVMes > 0
			// Faturadados no Mes //
			aAdd(aAnaFtM,{aNovGru[nPos,1],aNovGru[nPos,14],aNovGru[nPos,15],( cQAlias )->( VV0_TIPFAT ),( cQAlias )->( VV9RECNO ),( cQAlias )->( VV9_STATUS ),( cQAlias )->( VV9_FILIAL ),cLbCor})
		EndIf
	EndIf
   	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PROPOSTAS APROVADAS NOS MESES ANTERIORES E CONTINUAM APROVADAS  /  VENDAS NO MES ATUAL x PROPOSTAS APROVADAS NOS MESES ANTERIORES //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
cQuery := "SELECT VV9.R_E_C_N_O_ VV9RECNO , VV9.VV9_FILIAL , VV9.VV9_STATUS , VV0.VV0_TIPFAT , VV0.VV0_DATMOV , VV0.VV0_DATAPR , VVA.VVA_CHAINT ,"
If lCodMar
	cQuery += "VVA.VVA_CODMAR CODMAR , VVA.VVA_MODVEI MODVEI"
Else
	cQuery += "VV0.VV0_CODMAR CODMAR , VV0.VV0_MODVEI MODVEI"
Endif	
cQuery += " FROM "+RetSqlName("VV9")+" VV9 "
cQuery += "INNER JOIN "+RetSqlName("VV0")+" VV0 ON VV0.VV0_FILIAL=VV9.VV9_FILIAL AND VV0.VV0_NUMTRA=VV9.VV9_NUMATE AND VV0.VV0_TIPFAT IN ('0','1') AND VV0.D_E_L_E_T_=' ' "
cQuery += "INNER JOIN "+RetSqlName("VVA")+" VVA ON VVA.VVA_FILIAL=VV9.VV9_FILIAL AND VVA.VVA_NUMTRA=VV9.VV9_NUMATE AND VVA.D_E_L_E_T_=' ' "
cQuery += "WHERE VV9.VV9_FILIAL IN ("+cFilVV9+") AND VV9.VV9_STATUS IN ('F','T',"+cStatApr+") AND VV0.VV0_DATAPR<>' ' AND VV0.VV0_DATAPR<='"+dtos((dDataBase-day(dDataBase)))+"' AND VV9.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
Do While !( cQAlias )->( Eof() )
	If !Empty(( cQAlias )->( VVA_CHAINT ))
		cQuery := "SELECT VV1.VV1_TIPVEI , VV2.VV2_GRUMOD , VVR.VVR_DESCRI FROM "+RetSqlName("VV1")+" VV1 "
		cQuery += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON VV2.VV2_FILIAL IN ("+cFilVV2+") AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' "
		cQuery += "LEFT JOIN "+RetSqlName("VVR")+" VVR ON VVR.VVR_FILIAL IN ("+cFilVVR+") AND VVR.VVR_CODMAR=VV1.VV1_CODMAR AND VVR.VVR_GRUMOD=VV2.VV2_GRUMOD AND VVR.D_E_L_E_T_=' ' "
		cQuery += "WHERE VV1.VV1_FILIAL IN ("+cFilVV1+") AND VV1.VV1_CHAINT='"+( cQAlias )->( VVA_CHAINT )+"' AND VV1.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
		If !( cQAlAux )->( Eof() )
			nPos := FS_NPOSAADD(( cQAlAux )->( VV1_TIPVEI ),( cQAlias )->( CODMAR ),( cQAlAux )->( VVR_DESCRI ),( cQAlAux )->( VV2_GRUMOD ))
		EndIf
		( cQAlAux )->( dbCloseArea() )
	Else
		cQuery := "SELECT VV2.VV2_GRUMOD , VVR.VVR_DESCRI FROM "+RetSqlName("VV2")+" VV2 "
		cQuery += "LEFT JOIN "+RetSqlName("VVR")+" VVR ON VVR.VVR_FILIAL IN ("+cFilVVR+") AND VVR.VVR_CODMAR=VV2.VV2_CODMAR AND VVR.VVR_GRUMOD=VV2.VV2_GRUMOD AND VVR.D_E_L_E_T_=' ' "
		cQuery += "WHERE VV2.VV2_FILIAL IN ("+cFilVV2+") AND VV2.VV2_CODMAR='"+( cQAlias )->( CODMAR )+"' AND VV2.VV2_MODVEI='"+( cQAlias )->( MODVEI )+"' AND VV2.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
		If !( cQAlAux )->( Eof() )
			nPos := FS_NPOSAADD("1",( cQAlias )->( CODMAR ),( cQAlAux )->( VVR_DESCRI ),( cQAlAux )->( VV2_GRUMOD ))
		EndIf
		( cQAlAux )->( dbCloseArea() )
	EndIf
	If nPos > 0
		cLbCor := ""
		If ( cQAlias )->( VV9_STATUS ) $ "F/T" // Finalizadas
			If ( cQAlias )->( VV0_DATMOV ) >= dtos(dDatIni)
				cLbCor := "Verd"
				If ( cQAlias )->( VV0_TIPFAT ) == "0" // Novos
					aNovGru[1,13]++ // Vendas do Mes Atual com Aprovacao nos Meses Anteriores
					aNovGru[nPos,13]++ // Vendas do Mes Atual com Aprovacao nos Meses Anteriores
					// Faturadados no Mes //
					aNovGru[1,16]++ // Vendas do Mes Atual com Aprovacao nos Meses Anteriores
					aNovGru[nPos,16]++ // Vendas do Mes Atual com Aprovacao nos Meses Anteriores
				Else // ( cQAlias )->( VV0_TIPFAT ) == "1" // Usados
					aUsaGru[1,13]++ // Vendas do Mes Atual com Aprovacao nos Meses Anteriores
					aUsaGru[nPos,13]++ // Vendas do Mes Atual com Aprovacao nos Meses Anteriores
					// Faturadados no Mes //
					aUsaGru[1,16]++ // Vendas do Mes Atual com Aprovacao nos Meses Anteriores
					aUsaGru[nPos,16]++ // Vendas do Mes Atual com Aprovacao nos Meses Anteriores
				EndIf
			EndIf
		ElseIf ( cQAlias )->( VV9_STATUS ) $ cStatApr // L - Aprovadas
			cLbCor := "Verm"
			If ( cQAlias )->( VV0_TIPFAT ) == "0" // Novos
				aNovGru[1,12]++ // Aprovadas Meses Anteriores
				aNovGru[nPos,12]++ // Aprovadas Meses Anteriores
			Else // ( cQAlias )->( VV0_TIPFAT ) == "1" // Usados
				aUsaGru[1,12]++ // Aprovadas Meses Anteriores
				aUsaGru[nPos,12]++ // Aprovadas Meses Anteriores
			EndIf
		EndIf
		If !Empty(cLbCor)
			// Analitico por Atendimento -> Meses Anteriores //
			aAdd(aAnaAAn,{aNovGru[nPos,1],aNovGru[nPos,14],aNovGru[nPos,15],( cQAlias )->( VV0_TIPFAT ),( cQAlias )->( VV9RECNO ),( cQAlias )->( VV9_STATUS ),( cQAlias )->( VV9_FILIAL ),cLbCor})
			If cLbCor == "Verd"
				// Faturadados no Mes //
				aAdd(aAnaFtM,{aNovGru[nPos,1],aNovGru[nPos,14],aNovGru[nPos,15],( cQAlias )->( VV0_TIPFAT ),( cQAlias )->( VV9RECNO ),( cQAlias )->( VV9_STATUS ),( cQAlias )->( VV9_FILIAL ),cLbCor})
			EndIf				
		EndIf
	EndIf
   	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )

IncProc(STR0014) // Levantando...

If cVAIEstVei == "2" // Ambos
	// Montar Vetor TOTAL //
	For ni := 1 to len(aNovGru)
		aAdd(aTotGru,{aNovGru[ni,1],aNovGru[ni,2],0,0,0,0,0,0,0,0,0,0,0,aNovGru[ni,14],aNovGru[ni,15],0,0})
		If ni == 1
			aTotGru[ni,2] := UPPER(STR0020+" ( "+STR0007+" + "+STR0008+" )")
		EndIf
		For nj := 3 to 13
			aTotGru[ni,nj] := ( aNovGru[ni,nj] + aUsaGru[ni,nj] )
		Next
		aTotGru[ni,16] := ( aNovGru[ni,16] + aUsaGru[ni,16] )
	Next
	aAux := {}
	For ni := 1 to len(aTotGru)
		nPos := 0
		For nj := 3 to 13
			If aTotGru[ni,nj] > 0
			   nPos := 1
			   Exit
			EndIf
		Next
		If nPos == 0
			If aTotGru[ni,16] > 0
			   nPos := 1
			EndIf
		EndIf
		If nPos > 0
			aAdd(aAux,aClone(aTotGru[ni]))
		EndIf
	Next
	aTotGru := aClone(aAux)
	aSort(aTotGru,1,,{|x,y| x[1]+x[2] < y[1]+y[2] }) // Ordenar Vetor Grupo do Modelo - Total
EndIf
If cVAIEstVei == "0" .or. cVAIEstVei == "2" // Novos / Ambos
	aAux := {}
	For ni := 1 to len(aNovGru)
		nPos := 0
		For nj := 3 to 13
			If aNovGru[ni,nj] > 0
			   nPos := 1
			   Exit
			EndIf
		Next
		If nPos == 0
			If aNovGru[ni,16] > 0
			   nPos := 1
			EndIf
		EndIf
		If nPos > 0
			aAdd(aAux,aClone(aNovGru[ni]))
		EndIf
	Next
	aNovGru := aClone(aAux)
	If len(aNovGru) == 0
		aAdd(aNovGru,{"0",UPPER(STR0020+" ( "+STR0007+" )"),0,0,0,0,0,0,0,0,0,0,0,"","",0,0}) // TOTAL ( NOVOS )
	EndIf	
	aSort(aNovGru,1,,{|x,y| x[1]+x[2] < y[1]+y[2] }) // Ordenar Vetor Grupo do Modelo - Novos
EndIf
If cVAIEstVei == "1" .or. cVAIEstVei == "2" // Usados / Ambos
	aAux := {}
	For ni := 1 to len(aUsaGru)
		nPos := 0
		For nj := 3 to 13
			If aUsaGru[ni,nj] > 0
			   nPos := 1
			   Exit
			EndIf
		Next
		If nPos == 0
			If aUsaGru[ni,16] > 0
			   nPos := 1
			EndIf
		EndIf
		If nPos > 0
			aAdd(aAux,aClone(aUsaGru[ni]))
		EndIf
	Next
	aUsaGru := aClone(aAux)
	If len(aUsaGru) == 0
		aAdd(aUsaGru,{"0",UPPER(STR0020+" ( "+STR0008+" )"),0,0,0,0,0,0,0,0,0,0,0,"","",0,0}) // TOTAL ( USADOS )
	EndIf
	aSort(aUsaGru,1,,{|x,y| x[1]+x[2] < y[1]+y[2] }) // Ordenar Vetor Grupo do Modelo - Usados
EndIf
If nTp > 0
	If cVAIEstVei == "0" .or. cVAIEstVei == "2" // Novos ou Todos
		oLbNovGru:nAt := 1
		oLbNovGru:SetArray(aNovGru)
		oLbNovGru:bLine := { || { aNovGru[oLbNovGru:nAt,02] ,;
    	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,03],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,04],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,05],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,06],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,07],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,17],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,08]+aNovGru[oLbNovGru:nAt,09],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,10]+aNovGru[oLbNovGru:nAt,11],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,12],"@EZ 9,999,999"))+FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,13],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aNovGru[oLbNovGru:nAt,16],"@EZ 9,999,999")) }}
	EndIf
	If cVAIEstVei == "1" .or. cVAIEstVei == "2" // Usados ou Todos
		oLbUsaGru:nAt := 1
		oLbUsaGru:SetArray(aUsaGru)
		oLbUsaGru:bLine := { || { aUsaGru[oLbUsaGru:nAt,02] ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,03],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,04],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,05],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,06],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,07],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,17],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,08]+aUsaGru[oLbUsaGru:nAt,09],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,10]+aUsaGru[oLbUsaGru:nAt,11],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,12],"@EZ 9,999,999"))+FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,13],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aUsaGru[oLbUsaGru:nAt,16],"@EZ 9,999,999")) }}
	EndIf
EndIf
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_NPOSAADD | Autor ³  Andre Luis Almeida ³ Data ³ 16/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ nPos e aAdd no Vetor de Grupos                             |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_NPOSAADD(cTipVei,cCodMar,cDesGru,cCodGru)
Local nPos := 0
If cTipVei $ "2/3" // 2-Taxi / 3-Frotista
	nPos := aScan(aNovGru,{|x| x[1] == cTipVei })
	If nPos <= 0
		aAdd(aNovGru,{cTipVei,Alltrim(X3CBOXDESC("VV1_TIPVEI",cTipVei)),0,0,0,0,0,0,0,0,0,0,0,"","",0,0}) // GRUPO DO MODELO NOVOS
		aAdd(aUsaGru,{cTipVei,Alltrim(X3CBOXDESC("VV1_TIPVEI",cTipVei)),0,0,0,0,0,0,0,0,0,0,0,"","",0,0}) // GRUPO DO MODELO USADOS
		nPos := len(aNovGru)
	EndIf
Else // 1-Veiculo Normal
	nPos := aScan(aNovGru,{|x| x[1]+x[2] == "1"+cCodMar+" "+cDesGru })
	If nPos <= 0
		aAdd(aNovGru,{"1",cCodMar+" "+cDesGru,0,0,0,0,0,0,0,0,0,0,0,cCodMar,cCodGru,0,0}) // GRUPO DO MODELO NOVOS
		aAdd(aUsaGru,{"1",cCodMar+" "+cDesGru,0,0,0,0,0,0,0,0,0,0,0,cCodMar,cCodGru,0,0}) // GRUPO DO MODELO USADOS
		nPos := len(aNovGru)
	EndIf
EndIf
Return(nPos)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TOTGRU  ³ Autor ³  Andre Luis Almeida ³ Data ³ 11/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Total Grupo do Modelo ( NOVOS + USADOS )                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_TOTGRU()
Local cMesAtu   := right(left(dtos(dDataBase),6),2)+"/"+left(dtos(dDataBase),4)
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
aInfo := { aSizeHalf[ 1 ] , aSizeHalf[ 2 ] , aSizeHalf[ 3 ] , aSizeHalf[ 4 ] , 3 , 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,  10 , .T. , .F. } ) // Filtro no topo
aAdd( aObjects, { 0 ,  30 , .T. , .T. } ) // ListBox TOTAL
aPos := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oTotGru FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
	oTotGru:lEscClose := .F.
	@ aPos[1,1],aPos[1,2] SAY STR0001 SIZE 500,10 OF oTotGru PIXEL COLOR CLR_RED FONT oTitTela // Gerenciamento Depto. de Veiculos
	@ aPos[2,1],aPos[2,2] LISTBOX oLbTotGru FIELDS HEADER STR0015+" ( "+STR0007+" + "+STR0008+" )" ,; // Grupo Modelo ( Novos + Usados )
														STR0016 ,; // Compra
														STR0017 ,; // Pedido
														STR0018 ,; // Transito
														STR0019 ,; // Estoque
														STR0020 ,; // Total
														STR0040 ,; // Dia
														STR0041 ,; // Mes
														right(space(15)+STR0022,15)+" "+right(space(15)+STR0023+" "+STR0041,15) ,; // Pendentes / Vendas Mes
														STR0048 ; // Faturados no Mes
														COLSIZES aPos[2,4]-425,35,35,35,35,35,35,35,90,35 SIZE aPos[2,4]-2,aPos[2,3]-15 OF oTotGru ON DBLCLICK Processa( {|| FS_LEVANTA("T",oLbTotGru:nAt,oLbTotGru:nColPos+IIf(oLbTotGru:nColPos<=6,0,1)) } ) PIXEL
		oLbTotGru:SetArray(aTotGru)
		oLbTotGru:bLine := { || { aTotGru[oLbTotGru:nAt,02] ,;
     	                	FG_AlinVlrs(Transform(aTotGru[oLbTotGru:nAt,03],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aTotGru[oLbTotGru:nAt,04],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aTotGru[oLbTotGru:nAt,05],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aTotGru[oLbTotGru:nAt,06],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aTotGru[oLbTotGru:nAt,07],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aTotGru[oLbTotGru:nAt,08]+aTotGru[oLbTotGru:nAt,09],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aTotGru[oLbTotGru:nAt,10]+aTotGru[oLbTotGru:nAt,11],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aTotGru[oLbTotGru:nAt,12],"@EZ 9,999,999"))+FG_AlinVlrs(Transform(aTotGru[oLbTotGru:nAt,13],"@EZ 9,999,999")) ,;
     	                	FG_AlinVlrs(Transform(aTotGru[oLbTotGru:nAt,16],"@EZ 9,999,999")) }}

	@ aPos[1,1],aPos[1,4]-045 BUTTON oTotGruSair PROMPT STR0010 OF oTotGru SIZE 45,10 PIXEL ACTION oTotGru:End() // SAIR
ACTIVATE MSDIALOG oTotGru
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LEVANTA ³ Autor ³  Andre Luis Almeida ³ Data ³ 11/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Analitico por Veiculo ou Atendimento                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_LEVANTA(cNovUsa,nLinha,nColuna)
Local cMesAtu   := right(left(dtos(dDataBase),6),2)+"/"+left(dtos(dDataBase),4)
Local cGruVei   := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Local oLbVerm   := LoadBitmap( GetResources(), "BR_VERMELHO" )
Local oLbVerd   := LoadBitmap( GetResources(), "BR_VERDE" )
Local ni        := 0
Local nTam      := 0
Local cTitTela  := ""
Local _cAlVV0   := "SQLVV0"
Local cQuery    := "" 
Local cQueryVV1 := ""
Local aObjects  := {} , aInfo := {}, aPos := {}  
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
//
nLin    := 0
nLinFil := 0
//
aInfo := { aSizeHalf[ 1 ] , aSizeHalf[ 2 ] , aSizeHalf[ 3 ] , aSizeHalf[ 4 ] , 3 , 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 10 , .T. , .F. } ) // Filtro no topo
aAdd( aObjects, { 0 , 50 , .T. , .T. } ) // ListBox Veiculos/Atendimentos
aAdd( aObjects, { 0 , 50 , .T. , .T. } ) // Resumo estoque por veiculo
If nColuna >= 8 // Analitico por Atendimento
	aAdd( aObjects, { 0 , 06 , .T. , .F. } ) // Legenda Coluna 
EndIf
aPos := MsObjSize( aInfo, aObjects )
If cNovUsa == "N" // Novos
	cTitTela := aNovGru[nLinha,2]
ElseIf cNovUsa == "U" // Usados
	cTitTela := aUsaGru[nLinha,2]
ElseIf cNovUsa == "T" // Todos
	cTitTela := aTotGru[nLinha,2]
EndIf
aLevVeic:= {} // Vetor dos Veiculos
aLevAten:= {} // Vetor dos Atendimentos
If nColuna > 1

	If nColuna <= 6 // Analitico por Veiculo

		If nColuna == 2 // Compra

			For ni := 1 to len(aAnaCpa)
				lOk := .f.
				If aAnaCpa[ni,6] == "SD1"
					If cNovUsa == "N" .and. aAnaCpa[ni,4] == "0" // Novos
						If aNovGru[nLinha,1]=="0" .or. ( aNovGru[nLinha,1]==aAnaCpa[ni,1] .and. ( aNovGru[nLinha,14]+aNovGru[nLinha,15]==aAnaCpa[ni,2]+aAnaCpa[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If cNovUsa == "U" .and. aAnaCpa[ni,4] == "1" // Usados
						If aUsaGru[nLinha,1]=="0" .or. ( aUsaGru[nLinha,1]==aAnaCpa[ni,1] .and. ( aUsaGru[nLinha,14]+aUsaGru[nLinha,15]==aAnaCpa[ni,2]+aAnaCpa[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If cNovUsa == "T" // Todos ( Novos + Usados )
						If aTotGru[nLinha,1]=="0" .or. ( aTotGru[nLinha,1]==aAnaCpa[ni,1] .and. ( aTotGru[nLinha,14]+aTotGru[nLinha,15]==aAnaCpa[ni,2]+aAnaCpa[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If lOk
						cQuery := "SELECT VV1.VV1_CHAINT , VV1.VV1_FILENT , VV1.VV1_CODMAR , VV2.VV2_DESMOD , VV1.VV1_CORVEI , VV1.VV1_OPCFAB , VV1.VV1_FABMOD , VV1.VV1_MODVEI , VV1.VV1_SEGMOD , VV1.VV1_COMVEI , VV1.VV1_DTHVAL , VV1.VV1_RESERV , VV1.VV1_SITVEI , VV1.VV1_CHASSI , VV1.VV1_PLAVEI , VVC.VVC_DESCRI "
						If lVV1_DTFATT // Dias de Transito
							cQuery += ", VV1.VV1_DTFATT "
						EndIf
						cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
						cQuery += "LEFT JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SD1.D1_COD AND SB1.D_E_L_E_T_=' ' ) "
						cQuery += "LEFT JOIN "+RetSqlName("VV1")+" VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=SB1.B1_CODITE AND VV1.D_E_L_E_T_=' ') "
						cQuery += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV1.VV1_CODMAR=VV2.VV2_CODMAR AND VV1.VV1_MODVEI=VV2.VV2_MODVEI  AND VV2.D_E_L_E_T_=' ' ) "
						cQuery += "LEFT JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
						FS_VETVV1(cQuery+"WHERE SD1.R_E_C_N_O_="+Alltrim(str(aAnaCpa[ni,5])),STR0016+" ("+IIf(aAnaCpa[ni,4]=="0",STR0007,STR0008)+" )") // Compra ( Novos / Usados )
					EndIf
				Else // VV1 - Transito
					If cNovUsa == "N" .and. aAnaCpa[ni,4] <> "1" // Novos
						If aNovGru[nLinha,1]=="0" .or. ( aNovGru[nLinha,1]==aAnaCpa[ni,1] .and. ( aNovGru[nLinha,14]+aNovGru[nLinha,15]==aAnaCpa[ni,2]+aAnaCpa[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If cNovUsa == "U" .and. aAnaCpa[ni,4] == "1" // Usados
						If aUsaGru[nLinha,1]=="0" .or. ( aUsaGru[nLinha,1]==aAnaCpa[ni,1] .and. ( aUsaGru[nLinha,14]+aUsaGru[nLinha,15]==aAnaCpa[ni,2]+aAnaCpa[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If cNovUsa == "T" // Todos ( Novos + Usados )
						If aTotGru[nLinha,1]=="0" .or. ( aTotGru[nLinha,1]==aAnaCpa[ni,1] .and. ( aTotGru[nLinha,14]+aTotGru[nLinha,15]==aAnaCpa[ni,2]+aAnaCpa[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If lOk
						cQuery := "SELECT VV1.VV1_CHAINT , VV1.VV1_FILENT , VV1.VV1_CODMAR , VV2.VV2_DESMOD , VV1.VV1_CORVEI , VV1.VV1_OPCFAB , VV1.VV1_FABMOD , VV1.VV1_MODVEI , VV1.VV1_SEGMOD , VV1.VV1_COMVEI , VV1.VV1_DTHVAL , VV1.VV1_RESERV , VV1.VV1_SITVEI , VV1.VV1_CHASSI , VV1.VV1_PLAVEI , VVC.VVC_DESCRI "
						If lVV1_DTFATT // Dias de Transito
							cQuery += ", VV1.VV1_DTFATT "
						EndIf
						cQuery += "FROM "+RetSqlName("VV1")+" VV1 "
						cQuery += "LEFT JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE=VV1.VV1_CHAINT AND SB1.D_E_L_E_T_=' ' ) "
						cQuery += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' ) "
						cQuery += "LEFT JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
						FS_VETVV1(cQuery+"WHERE VV1.R_E_C_N_O_="+Alltrim(str(aAnaCpa[ni,5])),STR0018+" ( "+IIf(aAnaCpa[ni,4]=="0",STR0007,STR0008)+" )") // Transito ( Novos / Usados )
				    EndIf
				EndIf
			Next

	    ElseIf nColuna >= 3 .and. nColuna <= 6 // Pedido / Transito / Estoque / Total

		    If nColuna == 3 .or. nColuna == 6 // Pedido ou Total
				For ni := 1 to len(aAnaPed)
					lOk := .f.
					If cNovUsa == "N" .and. aAnaPed[ni,4] == "0" // Novos
						If aNovGru[nLinha,1]=="0" .or. ( aNovGru[nLinha,1]==aAnaPed[ni,1] .and. ( aNovGru[nLinha,14]+aNovGru[nLinha,15]==aAnaPed[ni,2]+aAnaPed[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If cNovUsa == "U" .and. aAnaPed[ni,4] == "1" // Usados
						If aUsaGru[nLinha,1]=="0" .or. ( aUsaGru[nLinha,1]==aAnaPed[ni,1] .and. ( aUsaGru[nLinha,14]+aUsaGru[nLinha,15]==aAnaPed[ni,2]+aAnaPed[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If cNovUsa == "T" // Todos ( Novos + Usados )
						If aTotGru[nLinha,1]=="0" .or. ( aTotGru[nLinha,1]==aAnaPed[ni,1] .and. ( aTotGru[nLinha,14]+aTotGru[nLinha,15]==aAnaPed[ni,2]+aAnaPed[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If lOk
						cQuery := "SELECT VV1.VV1_CHAINT , VV1.VV1_FILENT , VV1.VV1_CODMAR , VV2.VV2_DESMOD , VV1.VV1_CORVEI , VV1.VV1_OPCFAB , VV1.VV1_FABMOD , VV1.VV1_MODVEI , VV1.VV1_SEGMOD , VV1.VV1_COMVEI , VV1.VV1_DTHVAL , VV1.VV1_RESERV , VV1.VV1_SITVEI , VV1.VV1_CHASSI , VV1.VV1_PLAVEI , VVC.VVC_DESCRI "
						If lVV1_DTFATT // Dias de Transito
							cQuery += ", VV1.VV1_DTFATT "
						EndIf
						cQuery += "FROM "+RetSqlName("VV1")+" VV1 "
						cQuery += "LEFT JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE=VV1.VV1_CHAINT AND SB1.D_E_L_E_T_=' ' ) "
						cQuery += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' ) "
						cQuery += "LEFT JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
						cQuery += "WHERE VV1.R_E_C_N_O_="+Alltrim(str(aAnaPed[ni,5]))
						If cNovUsa == "N" .or. cNovUsa == "T" // Novos ou Todos
							If aAnaPed[ni,4] == "0" // Novos
								FS_VETVV1(cQuery,STR0017+" ( "+STR0007+" )") // Pedido ( Novos )
                            EndIf
	                    EndIf
						If cNovUsa == "U" .or. cNovUsa == "T" // Usados ou Todos
							If aAnaPed[ni,4] == "1" // Usados
								FS_VETVV1(cQuery,STR0017+" ( "+STR0008+" )") // Pedido ( Usados )
							EndIf
						EndIf
					EndIf
				Next	    
		    EndIf

			cQueryVV1 := "SELECT VV1.VV1_CHAINT , VV1.VV1_FILENT , VV1.VV1_CODMAR , VV2.VV2_DESMOD , VV1.VV1_CORVEI , VV1.VV1_OPCFAB , VV1.VV1_FABMOD , VV1.VV1_MODVEI , VV1.VV1_SEGMOD , VV1.VV1_COMVEI , VV1.VV1_DTHVAL , VV1.VV1_RESERV , VV1.VV1_SITVEI , VV1.VV1_CHASSI , VV1.VV1_PLAVEI , VVC.VVC_DESCRI "
			If lVV1_DTFATT // Dias de Transito
				cQueryVV1 += ", VV1.VV1_DTFATT "
			EndIf
			cQueryVV1 += "FROM "+RetSqlName("VV1")+" VV1 "
			cQueryVV1 += "LEFT JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE=VV1.VV1_CHAINT AND SB1.D_E_L_E_T_=' ' ) "
			cQueryVV1 += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' ) "
			cQueryVV1 += "LEFT JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "

		    If nColuna == 4 .or. nColuna == 6 // Transito ou Total
				For ni := 1 to len(aAnaTra)
					lOk := .f.
					If cNovUsa == "N" .and. aAnaTra[ni,4] <> "1" // Novos
						If aNovGru[nLinha,1]=="0" .or. ( aNovGru[nLinha,1]==aAnaTra[ni,1] .and. ( aNovGru[nLinha,14]+aNovGru[nLinha,15]==aAnaTra[ni,2]+aAnaTra[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If cNovUsa == "U" .and. aAnaTra[ni,4] == "1" // Usados
						If aUsaGru[nLinha,1]=="0" .or. ( aUsaGru[nLinha,1]==aAnaTra[ni,1] .and. ( aUsaGru[nLinha,14]+aUsaGru[nLinha,15]==aAnaTra[ni,2]+aAnaTra[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If cNovUsa == "T" // Todos ( Novos + Usados )
						If aTotGru[nLinha,1]=="0" .or. ( aTotGru[nLinha,1]==aAnaTra[ni,1] .and. ( aTotGru[nLinha,14]+aTotGru[nLinha,15]==aAnaTra[ni,2]+aAnaTra[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If lOk
						FS_VETVV1(cQueryVV1+"WHERE VV1.R_E_C_N_O_="+Alltrim(str(aAnaTra[ni,5])),STR0018+" ( "+IIf(aAnaTra[ni,4]=="0",STR0007,STR0008)+" )") // Transito ( Novos / Usados )
					EndIf
				Next
		    EndIf

		    If nColuna == 5 .or. nColuna == 6 // Estoque ou Total
				For ni := 1 to len(aAnaEst)
					lOk := .f.
					If cNovUsa == "N" .and. aAnaEst[ni,4] == "0" // Novos
						If aNovGru[nLinha,1]=="0" .or. ( aNovGru[nLinha,1]==aAnaEst[ni,1] .and. ( aNovGru[nLinha,14]+aNovGru[nLinha,15]==aAnaEst[ni,2]+aAnaEst[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If cNovUsa == "U" .and. aAnaEst[ni,4] == "1" // Usados
						If aUsaGru[nLinha,1]=="0" .or. ( aUsaGru[nLinha,1]==aAnaEst[ni,1] .and. ( aUsaGru[nLinha,14]+aUsaGru[nLinha,15]==aAnaEst[ni,2]+aAnaEst[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If cNovUsa == "T" // Todos ( Novos + Usados )
						If aTotGru[nLinha,1]=="0" .or. ( aTotGru[nLinha,1]==aAnaEst[ni,1] .and. ( aTotGru[nLinha,14]+aTotGru[nLinha,15]==aAnaEst[ni,2]+aAnaEst[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If lOk
						FS_VETVV1(cQueryVV1+"WHERE VV1.R_E_C_N_O_="+Alltrim(str(aAnaEst[ni,5])),STR0019+" ( "+IIf(aAnaEst[ni,4]=="0",STR0007,STR0008)+" )") // Estoque ( Novos / Usados )
					EndIf
				Next
			EndIf

		EndIf

		If len(aLevVeic) > 0
			aSort(aLevVeic,1,,{|x,y| x[12]+x[1]+strzero(999999999-x[7],10) < y[12]+y[1]+strzero(999999999-y[7],10) }) // Ordenar Vetor de Veiculos
		Else
			Return()
		EndIf
		FS_RESUMO()
		FS_RESFIL()
		aVeiculo := aClone(aLevVeic)
		DEFINE MSDIALOG oLevVeic FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
			oLevVeic:lEscClose := .F.
			@ aPos[1,1],aPos[1,2] SAY STR0052 SIZE 500,10 OF oLevVeic PIXEL COLOR CLR_RED FONT oTitTela 
		
			@ aPos[2,1],aPos[2,2] LISTBOX oLbVei FIELDS HEADER STR0053,STR0054 COLSIZES 230,60 SIZE (aPos[2,4]/2)-2,aPos[2,3]-15 OF oLevVeic ON CHANGE FS_RESMOD(aLevVei[oLbVei:nAt,01]) PIXEL
			oLbVei:SetArray(aLevVei)
			oLbVei:bLine := { || { aLevVei[oLbVei:nAt,01] , FG_AlinVlrs(Transform(aLevVei[oLbVei:nAt,02],"99999")) }}

			@ aPos[2,1],((aPos[2,4]/2)*1)+3 LISTBOX oFilVei FIELDS HEADER STR0057,STR0054 COLSIZES 230,60 SIZE (aPos[2,4]/2)-2,aPos[2,3]-15 OF oLevVeic PIXEL // Resumo por Filial
			oFilVei:SetArray(aFilVei)
			oFilVei:bLine := { || { aFilVei[oFilVei:nAt,01] , FG_AlinVlrs(Transform(aFilVei[oFilVei:nAt,02],"99999")) }}

			@ aPos[3,1],aPos[3,2] SAY oTitTela VAR Alltrim(cTitTela)+" ( "+Alltrim(str(len(aLevVeic))+" "+STR0024+" )") SIZE 500,10 OF oLevVeic PIXEL COLOR CLR_RED FONT oTitTela // Veiculos
 			If lVV1_DTFATT // Dias de Transito
				@ aPos[3,1]+10,aPos[3,2] LISTBOX oLbVeic FIELDS HEADER STR0058 ,; // Filial
																STR0024 ,; // Veiculos
																STR0025 ,; // Cor
																STR0026 ,; // Opcionais
 																STR0027 ,; // Fab/Mod
																STR0028 ,; // Combustivel
																STR0029 ,; // Situacao
																STR0030 ,; // Dias
																STR0055 ,; // Fatur
																STR0031 ,; // Valor
																STR0032 ,; // Chassi
																STR0033 ; // Placa
																COLSIZES 40,aPos[3,3]-600,50,55,30,50,90,25,25,45,70,30 SIZE aPos[3,4]-2,aPos[3,3]-aPos[3,1]-10 OF oLevVeic ON DBLCLICK IIf((!Empty(aLevVeic[oLbVeic:nAt,09]).and.Left(aLevVeic[oLbVeic:nAt,06],len(STR0017))<>STR0017),VEIVC140(aLevVeic[oLbVeic:nAt,09], iif(LEN(aLevVeic[oLbVeic:nAt]) >=12, aLevVeic[oLbVeic:nAt,13], '') ),.t.) PIXEL 
				oLbVeic:SetArray(aLevVeic)
				oLbVeic:bLine := { || { aLevVeic[oLbVeic:nAt,12] ,; 
										aLevVeic[oLbVeic:nAt,01] ,; 
										aLevVeic[oLbVeic:nAt,02] ,;
										aLevVeic[oLbVeic:nAt,03] ,;
										aLevVeic[oLbVeic:nAt,04] ,;
										aLevVeic[oLbVeic:nAt,05] ,;
										aLevVeic[oLbVeic:nAt,06] ,;
										FG_AlinVlrs(Transform(aLevVeic[oLbVeic:nAt,07],"@E 999,999")) ,;
										FG_AlinVlrs(Transform(aLevVeic[oLbVeic:nAt,11],"@E 999,999")) ,;
										FG_AlinVlrs(Transform(aLevVeic[oLbVeic:nAt,08],"@E 999,999,999.99")) ,;
										aLevVeic[oLbVeic:nAt,09] ,;
										aLevVeic[oLbVeic:nAt,10] }}
			Else
				@ aPos[3,1]+10,aPos[3,2] LISTBOX oLbVeic FIELDS HEADER STR0058 ,; // Filial
																STR0024 ,; // Veiculos
																STR0025 ,; // Cor
																STR0026 ,; // Opcionais
																STR0027 ,; // Fab/Mod
																STR0028 ,; // Combustivel
																STR0029 ,; // Situacao
																STR0030 ,; // Dias
																STR0031 ,; // Valor
																STR0032 ,; // Chassi
																STR0033 ; // Placa
																COLSIZES 40,aPos[3,3]-580,50,55,30,50,90,25,45,70,30 SIZE aPos[3,4]-2,aPos[3,3]-aPos[3,1]-10 OF oLevVeic ON DBLCLICK IIf((!Empty(aLevVeic[oLbVeic:nAt,09]).and.Left(aLevVeic[oLbVeic:nAt,06],len(STR0017))<>STR0017),VEIVC140(aLevVeic[oLbVeic:nAt,09], iif(LEN(aLevVeic[oLbVeic:nAt]) >=12, aLevVeic[oLbVeic:nAt,13], '')),.t.) PIXEL
				oLbVeic:SetArray(aLevVeic)
				oLbVeic:bLine := { || { aLevVeic[oLbVeic:nAt,12] ,; 
										aLevVeic[oLbVeic:nAt,01] ,; 
										aLevVeic[oLbVeic:nAt,02] ,;
										aLevVeic[oLbVeic:nAt,03] ,;
										aLevVeic[oLbVeic:nAt,04] ,;
										aLevVeic[oLbVeic:nAt,05] ,;
										aLevVeic[oLbVeic:nAt,06] ,;
										FG_AlinVlrs(Transform(aLevVeic[oLbVeic:nAt,07],"@E 999,999")) ,;
										FG_AlinVlrs(Transform(aLevVeic[oLbVeic:nAt,08],"@E 999,999,999.99")) ,;
										aLevVeic[oLbVeic:nAt,09] ,;
										aLevVeic[oLbVeic:nAt,10] }}
			EndIf 

			@ aPos[1,1],aPos[1,4]-100 BUTTON oVeiSimul PROMPT STR0047 OF oLevVeic SIZE 45,10 PIXEL ACTION FS_SIMULAC(aLevVeic[oLbVeic:nAt,09]) WHEN !Empty(aLevVeic[oLbVeic:nAt,09]) // Simulacao
			@ aPos[1,1],aPos[1,4]-045 BUTTON oVeicSair PROMPT STR0010 OF oLevVeic SIZE 45,10 PIXEL ACTION oLevVeic:End() // SAIR
		ACTIVATE MSDIALOG oLevVeic

    Else // Analitico por Atendimento
        
		cQueryVV9 := "SELECT DISTINCT VV9.VV9_CODCLI , VV9.VV9_LOJA , VV9.VV9_STATUS , VV9.VV9_FILIAL , VV9.VV9_NUMATE , VV9.VV9_DATVIS , VV9.VV9_NOMVIS , VV0.VV0_CODVEN , VV0.VV0_VALTOT , VV0.VV0_VALTRO , VVA.VVA_CHAINT ,"
		If lCodMar
			cQueryVV9 += "VVA.VVA_CODMAR CODMAR , "
		Else
			cQueryVV9 += "VV0.VV0_CODMAR CODMAR , "
		Endif	
		cQueryVV9 += "VV2.VV2_DESMOD , VV0.VV0_CORVEI , VV1.VV1_FABMOD , VV1.VV1_COMVEI , VV1.VV1_CHASSI , VV1.VV1_PLAVEI , VVC.VVC_DESCRI FROM "+RetSqlName("VV9")+" VV9 "
		cQueryVV9 += "INNER JOIN "+RetSqlName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=VV9.VV9_FILIAL AND VV0.VV0_NUMTRA=VV9.VV9_NUMATE AND VV0.D_E_L_E_T_=' ') "
		cQueryVV9 += "INNER JOIN "+RetSqlName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VV9.VV9_FILIAL AND VVA.VVA_NUMTRA=VV9.VV9_NUMATE AND VVA.D_E_L_E_T_=' ') "
		cQueryVV9 += "LEFT JOIN "+RetSqlName("VV1")+" VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VVA.VVA_CHAINT AND VV1.D_E_L_E_T_=' ' ) "
		cQueryVV9 += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND "
		If lCodMar
			cQueryVV9 += "VV2.VV2_CODMAR=VVA.VVA_CODMAR AND VV2.VV2_MODVEI=VVA.VVA_MODVEI "
		Else	
			cQueryVV9 += "VV2.VV2_CODMAR=VV0.VV0_CODMAR AND VV2.VV2_MODVEI=VV0.VV0_MODVEI "               
		Endif	
		cQueryVV9 += "AND VV2.D_E_L_E_T_=' ' ) "
		cQueryVV9 += "LEFT JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND "
		If lCodMar
			cQueryVV9 += "VVC.VVC_CODMAR=VVA.VVA_CODMAR AND VVC.VVC_CORVEI=VVA.VVA_CORVEI "
	    Else
			cQueryVV9 += "VVC.VVC_CODMAR=VV0.VV0_CODMAR AND VVC.VVC_CORVEI=VV0.VV0_CORVEI "
		Endif
		cQueryVV9 += "AND VVC.D_E_L_E_T_=' ' ) "

    	If nColuna == 8 .or. nColuna == 9 // Dia / Mes Atual

			For ni := 1 to len(aAnaADM)
				If ( nColuna == 8 .and. "1" $ aAnaADM[ni,6] ) .or. nColuna == 9 // Dia / Mes
					lOk := .f.
					If cNovUsa == "N" .and. aAnaADM[ni,4] == "0" // Novos
						If aNovGru[nLinha,1]=="0" .or. ( aNovGru[nLinha,1]==aAnaADM[ni,1] .and. ( aNovGru[nLinha,14]+aNovGru[nLinha,15]==aAnaADM[ni,2]+aAnaADM[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If cNovUsa == "U" .and. aAnaADM[ni,4] == "1" // Usados
						If aUsaGru[nLinha,1]=="0" .or. ( aUsaGru[nLinha,1]==aAnaADM[ni,1] .and. ( aUsaGru[nLinha,14]+aUsaGru[nLinha,15]==aAnaADM[ni,2]+aAnaADM[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If cNovUsa == "T" // Todos ( Novos + Usados )
						If aTotGru[nLinha,1]=="0" .or. ( aTotGru[nLinha,1]==aAnaADM[ni,1] .and. ( aTotGru[nLinha,14]+aTotGru[nLinha,15]==aAnaADM[ni,2]+aAnaADM[ni,3] ) )
							lOk := .t.
						EndIf
					EndIf
					If lOk
						FS_VETVV9(cQueryVV9+"WHERE VV9.R_E_C_N_O_="+Alltrim(str(aAnaADM[ni,5])),IIf(aAnaADM[ni,4]=="0",STR0007,STR0008),aAnaADM[ni,7],aAnaADM[ni,8]) // Novos / Usados
					EndIf
				EndIf
			Next

    	ElseIf nColuna == 10 // Meses Anteriores

			For ni := 1 to len(aAnaAAn)
				lOk := .f.
				If cNovUsa == "N" .and. aAnaAAn[ni,4] == "0" // Novos
					If aNovGru[nLinha,1]=="0" .or. ( aNovGru[nLinha,1]==aAnaAAn[ni,1] .and. ( aNovGru[nLinha,14]+aNovGru[nLinha,15]==aAnaAAn[ni,2]+aAnaAAn[ni,3] ) )
						lOk := .t.
					EndIf
				EndIf
				If cNovUsa == "U" .and. aAnaAAn[ni,4] == "1" // Usados
					If aUsaGru[nLinha,1]=="0" .or. ( aUsaGru[nLinha,1]==aAnaAAn[ni,1] .and. ( aUsaGru[nLinha,14]+aUsaGru[nLinha,15]==aAnaAAn[ni,2]+aAnaAAn[ni,3] ) )
						lOk := .t.
					EndIf
				EndIf
				If cNovUsa == "T" // Todos ( Novos + Usados )
					If aTotGru[nLinha,1]=="0" .or. ( aTotGru[nLinha,1]==aAnaAAn[ni,1] .and. ( aTotGru[nLinha,14]+aTotGru[nLinha,15]==aAnaAAn[ni,2]+aAnaAAn[ni,3] ) )
						lOk := .t.
					EndIf
				EndIf
				If lOk
					FS_VETVV9(cQueryVV9+"WHERE VV9.R_E_C_N_O_="+Alltrim(str(aAnaAAn[ni,5])),IIf(aAnaAAn[ni,4]=="0",STR0007,STR0008),aAnaAAn[ni,7],aAnaAAn[ni,8]) // Novos / Usados
				EndIf
			Next

		ElseIf nColuna == 11 // Faturados no Mes

			For ni := 1 to len(aAnaFtM)
				lOk := .f.
				If cNovUsa == "N" .and. aAnaFtM[ni,4] == "0" // Novos
					If aNovGru[nLinha,1]=="0" .or. ( aNovGru[nLinha,1]==aAnaFtM[ni,1] .and. ( aNovGru[nLinha,14]+aNovGru[nLinha,15]==aAnaFtM[ni,2]+aAnaFtM[ni,3] ) )
						lOk := .t.
					EndIf
				EndIf
				If cNovUsa == "U" .and. aAnaFtM[ni,4] == "1" // Usados
					If aUsaGru[nLinha,1]=="0" .or. ( aUsaGru[nLinha,1]==aAnaFtM[ni,1] .and. ( aUsaGru[nLinha,14]+aUsaGru[nLinha,15]==aAnaFtM[ni,2]+aAnaFtM[ni,3] ) )
						lOk := .t.
					EndIf
				EndIf
				If cNovUsa == "T" // Todos ( Novos + Usados )
					If aTotGru[nLinha,1]=="0" .or. ( aTotGru[nLinha,1]==aAnaFtM[ni,1] .and. ( aTotGru[nLinha,14]+aTotGru[nLinha,15]==aAnaFtM[ni,2]+aAnaFtM[ni,3] ) )
						lOk := .t.
					EndIf
				EndIf
				If lOk
					FS_VETVV9(cQueryVV9+"WHERE VV9.R_E_C_N_O_="+Alltrim(str(aAnaFtM[ni,5])),IIf(aAnaFtM[ni,4]=="0",STR0007,STR0008),aAnaFtM[ni,7],aAnaFtM[ni,8]) // Novos / Usados
				EndIf
			Next

		EndIf

		If len(aLevAten) > 0
			aSort(aLevAten,1,,{|x,y| x[4]+x[2] < y[4]+y[2] }) // Ordenar Vetor de Atendimentos
		Else
			Return()
		EndIf
		DEFINE MSDIALOG oLevAten FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
			oLevAten:lEscClose := .F.
			@ aPos[1,1],aPos[1,2] SAY Alltrim(cTitTela)+" ( "+Alltrim(str(len(aLevAten))+" "+STR0034+" )") SIZE 500,10 OF oLevAten PIXEL COLOR CLR_RED FONT oTitTela // Atendimentos
			@ aPos[2,1],aPos[2,2] LISTBOX oLbAten FIELDS HEADER "" ,;
																STR0012 ,; // Filial
																STR0034 ,; // Atendimentos
																STR0035 ,; // Data
																STR0031 ,; // Valor
																STR0039 ,; // Vendedor
																STR0036 ,; // Cliente																
																STR0024 ,; // Veiculos
																STR0025 ,; // Cor
																STR0027 ,; // Fab/Mod
																STR0028 ,; // Combustivel
																STR0032 ,; // Chassi
																STR0033 ; // Placa
																COLSIZES 10,90,110,25,50,100,130,130,45,30,40,65,35 SIZE aPos[3,4]-2,aPos[3,3]-20 OF oLevAten ON DBLCLICK FS_VERATEND(aLevAten[oLbAten:nAt,02],aLevAten[oLbAten:nAt,04]) PIXEL

				oLbAten:SetArray(aLevAten)
				oLbAten:bLine := { || { IIf(aLevAten[oLbAten:nAt,01]=="Verm",oLbVerm,oLbVerd) ,;
										aLevAten[oLbAten:nAt,02]+" - "+aLevAten[oLbAten:nAt,03] ,;
										aLevAten[oLbAten:nAt,04]+" "+aLevAten[oLbAten:nAt,05] ,;
										aLevAten[oLbAten:nAt,06] ,;
										FG_AlinVlrs(Transform(aLevAten[oLbAten:nAt,07],"@E 999,999,999.99")) ,;
										aLevAten[oLbAten:nAt,08] ,;
										aLevAten[oLbAten:nAt,09] ,;
										aLevAten[oLbAten:nAt,10] ,;
										aLevAten[oLbAten:nAt,11] ,;
										aLevAten[oLbAten:nAt,12] ,;
										aLevAten[oLbAten:nAt,13] ,;
										aLevAten[oLbAten:nAt,14] ,;
										aLevAten[oLbAten:nAt,15] }}

			nTam := ( aPos[3,4] / 2 )
            If nColuna <> 11 // Faturados no Mes
				@ aPos[3,3],aPos[3,2]+(nTam*0) BITMAP oxLbVerm RESOURCE "BR_VERMELHO" OF oLevAten NOBORDER SIZE 10,10 when .f. PIXEL
				@ aPos[3,3],aPos[3,2]+(nTam*1) BITMAP oxLbVerd RESOURCE "BR_VERDE" OF oLevAten NOBORDER SIZE 10,10 when .f. PIXEL
			Else
				@ aPos[3,3],aPos[3,2]+(nTam*0) BITMAP oxLbVerd RESOURCE "BR_VERDE" OF oLevAten NOBORDER SIZE 10,10 when .f. PIXEL
			EndIf
			If nColuna == 8  // Dia 
				@ aPos[3,3],aPos[3,2]+(nTam*0)+9 SAY (STR0038+" "+STR0040+" ( "+Transform(dDataBase,"@D")+" )") SIZE 180,10 OF oLevAten PIXEL COLOR CLR_BLACK // Aprovados Dia
				@ aPos[3,3],aPos[3,2]+(nTam*1)+9 SAY (STR0042+" ( "+Transform(dDataBase,"@D")+" )") SIZE 180,10 OF oLevAten PIXEL COLOR CLR_BLACK // Aprovados e Vendidos no Dia
			ElseIf nColuna == 9 // Mes Atual
				@ aPos[3,3],aPos[3,2]+(nTam*0)+9 SAY (STR0038+" "+STR0041+" ( "+cMesAtu+" )") SIZE 180,10 OF oLevAten PIXEL COLOR CLR_BLACK // Aprovados Mes
				@ aPos[3,3],aPos[3,2]+(nTam*1)+9 SAY (STR0043+" ( "+cMesAtu+" )") SIZE 180,10 OF oLevAten PIXEL COLOR CLR_BLACK // Aprovados e Vendidos no Mes
            ElseIf nColuna == 10 // Meses Anteriores
				@ aPos[3,3],aPos[3,2]+(nTam*0)+9 SAY STR0044 SIZE 250,10 OF oLevAten PIXEL COLOR CLR_BLACK // Aprovados nos Meses anteriores e continuam Pendentes
				@ aPos[3,3],aPos[3,2]+(nTam*1)+9 SAY STR0045 SIZE 250,10 OF oLevAten PIXEL COLOR CLR_BLACK // Aprovados nos Meses anteriores e Vendidos no Mes atual
            ElseIf nColuna == 11 // Atendimentos 'Faturados no Mes', independentemente da sua data de aprovacao
				@ aPos[3,3],aPos[3,2]+(nTam*0)+9 SAY STR0049 SIZE 350,10 OF oLevAten PIXEL COLOR CLR_BLACK // Atendimentos 'Faturados no Mes', independentemente da sua data de aprovacao
            EndIf
			If FindFunction("VEIXC008")
				@ aPos[1,1],aPos[1,4]-095 BUTTON oFOLLOWUP PROMPT STR0046 OF oLevAten SIZE 45,10 PIXEL ACTION VEIXC008(aLevAten[oLbAten:nAt,16],aLevAten[oLbAten:nAt,04]) // FOLLOW-UP
			EndIf
			@ aPos[1,1],aPos[1,4]-045 BUTTON oAtenSair PROMPT STR0010 OF oLevAten SIZE 45,10 PIXEL ACTION oLevAten:End() // SAIR
		ACTIVATE MSDIALOG oLevAten

	EndIf
EndIf
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_SIMULAC ³ Autor ³  Andre Luis Almeida ³ Data ³ 19/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada da Funcao de Simulacao ( FGX_VEISIM -> VEIXFUNA )  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_SIMULAC(cChassi)
If !Empty(cChassi)
	DbSelectArea("VV1")
	DbSetOrder(2)
	If DbSeek(xFilial("VV1")+cChassi)
		FGX_VEISIM(VV1->VV1_CHAINT)
	EndIf
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  FS_VETVV1 ³ Autor ³  Andre Luis Almeida ³ Data ³ 22/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Adiciona no Vetor de Veiculos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_VETVV1(cQuery,cSituac)
Local _cAlVV1  := "SQLVV1"
Local lReserv  := .f.
Local nDiasEst := 0
Local nDiasFat := 0
Local aQUltMov := {}
Local aRet     := {}
Local aSM0     := {}
Local cNomSM0  := ""
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), _cAlVV1 , .F., .T. )
If !( _cAlVV1 )->( Eof() )
	lReserv := .f.
	If ( _cAlVV1 )->( VV1_RESERV ) $ "1/3" // Reservado
		If !Empty(( _cAlVV1 )->( VV1_DTHVAL ))
			lReserv := .t.
			dDatRes := ctod(subs(( _cAlVV1 )->( VV1_DTHVAL ),1,8))
			if dDataBase > dDatRes
				lReserv := .f.
			Elseif dDataBase == dDatRes
				cHorTmp := subs(( _cAlVV1 )->( VV1_DTHVAL ),10,2)+":"+subs(( _cAlVV1 )->( VV1_DTHVAL ),12,2)
				if Substr(Time(),1,5) > cHorTmp
					lReserv := .f.
				Endif
			Endif
			If lReserv
				cSituac += " "+STR0037 // Reservado
			EndIf
		EndIf
	EndIf
	aRet := VM060VEIBLO(( _cAlVV1 )->( VV1_CHAINT ),"B") // Verifica se o Veiculo esta Bloqueado, retorna registro do Bloqueio.
    If len(aRet) > 0
		cSituac += " "+STR0050 // Bloqueado
	EndIf
	If ( _cAlVV1 )->( VV1_SITVEI ) == "3"
		If left(cSituac,len(STR0019)) == STR0019 // Estoque 
			cSituac := STR0051+substr(cSituac,len(STR0019)+1) // Remessa
		EndIf
	EndIf
	nValorVda := FGX_VLRSUGV( ( _cAlVV1 )->( VV1_CHAINT ) , , , , , .t. )
	nDiasEst := 0
	If ( _cAlVV1 )->( VV1_SITVEI ) <> "2" // Transito
		aQUltMov := FM_VEIUMOV( ( _cAlVV1 )->( VV1_CHASSI ) , "E" , "0" )
		If len(aQUltMov) > 0
			nDiasEst := (dDataBase-aQUltMov[5])
		EndIf
	EndIf
	nDiasFat := 0
	If lVV1_DTFATT // Dias de Transito
		If !Empty(( _cAlVV1 )->( VV1_DTFATT ))
			nDiasFat := ( dDataBase - stod(( _cAlVV1 )->( VV1_DTFATT )) )
		EndIf
	EndIf
	cNomSM0 := ""
	If !Empty(( _cAlVV1 )->( VV1_FILENT ))
		aSM0 := FWArrFilAtu(cEmpAnt,( _cAlVV1 )->( VV1_FILENT ))
		If len(aSM0) > 0
			cNomSM0 := aSM0[7]
		EndIf
	EndIf
	aAdd(aLevVeic, { ( _cAlVV1 )->( VV1_CODMAR ) + ( _cAlVV1 )->( VV2_DESMOD ) , left(( _cAlVV1 )->( VVC_DESCRI ),12) , left(( _cAlVV1 )->( VV1_OPCFAB ),80) , Transform(( _cAlVV1 )->( VV1_FABMOD ),VV1->(x3Picture("VV1_FABMOD"))) , Alltrim(X3CBOXDESC("VV1_COMVEI",( _cAlVV1 )->( VV1_COMVEI ))) , cSituac , nDiasEst , nValorVda , ( _cAlVV1 )->( VV1_CHASSI ) , Transform(( _cAlVV1 )->( VV1_PLAVEI ),VV1->(x3Picture("VV1_PLAVEI"))) , nDiasFat , ( _cAlVV1 )->( VV1_FILENT )+" - "+cNomSM0,  ( _cAlVV1 )->(VV1_CHAINT) } )
EndIf
( _cAlVV1 )->( DbCloseArea() )
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  FS_VETVV9 ³ Autor ³  Andre Luis Almeida ³ Data ³ 22/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Adiciona no Vetor de Atendimentos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_VETVV9(cQuery,cSituac,cCdFilial,cLbCor)
Local nTam    := 0
Local cNomCli := ""
Local cNomVen := ""
Local cFilAtu := ""
Local _cAlVV9 := "SQLVV9"
Local nVlrVda := 0
Local lVeic   := .f.
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), _cAlVV9 , .F., .T. )
If !( _cAlVV9 )->( Eof() )
	cFilAtu := ""
	nTam := aScan(aEmpFil,{|x| x[1] == cCdFilial })
	If nTam > 0
		cFilAtu := left(aEmpFil[nTam,2]+space(20),20)
	EndIf
	nVlrVda := ( ( _cAlVV9 )->( VV0_VALTOT ) - ( _cAlVV9 )->( VV0_VALTRO ) ) // Vlr.Venda
	cNomVen := ( _cAlVV9 )->( VV0_CODVEN )+" "+left(FM_SQL("SELECT SA3.A3_NOME FROM "+RetSqlName("SA3")+" SA3 WHERE SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD='"+( _cAlVV9 )->( VV0_CODVEN )+"' AND SA3.D_E_L_E_T_=' '"),20)
	cNomCli := ""
	If !Empty( ( _cAlVV9 )->( VV9_CODCLI) + ( _cAlVV9 )->( VV9_LOJA ) )
		// Posiciona no SA1 para mostrar A1_NOME
		cNomCli := ( _cAlVV9 )->( VV9_CODCLI )+"-"+( _cAlVV9 )->( VV9_LOJA )+" "+left(FM_SQL("SELECT SA1.A1_NOME FROM "+RetSqlName("SA1")+" SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD='"+( _cAlVV9 )->( VV9_CODCLI )+"' AND SA1.A1_LOJA='"+( _cAlVV9 )->( VV9_LOJA )+"' AND SA1.D_E_L_E_T_=' '"),35)
	Else
		cNomCli := left(( _cAlVV9 )->( VV9_NOMVIS ),35)
	EndIf
	If !Empty(( _cAlVV9 )->( VVA_CHAINT ))
		lVeic := .t.
	EndIf
	cSituac += " - "+X3CBOXDESC("VV9_STATUS",( _cAlVV9 )->( VV9_STATUS ))
	Aadd(aLevAten,{ cLbCor , cCdFilial , cFilAtu , ( _cAlVV9 )->( VV9_NUMATE ) , cSituac , Transform(stod(( _cAlVV9 )->( VV9_DATVIS )),"@D") , nVlrVda , cNomVen , cNomCli , ( _cAlVV9 )->( CODMAR ) + ( _cAlVV9 )->( VV2_DESMOD ) , left(( _cAlVV9 )->( VVC_DESCRI ),12) , IIf(lVeic,Transform(( _cAlVV9 )->( VV1_FABMOD ),VV1->(x3Picture("VV1_FABMOD"))),"") , IIf(lVeic,Alltrim(X3CBOXDESC("VV1_COMVEI",( _cAlVV9 )->( VV1_COMVEI ))),"") , IIf(lVeic,( _cAlVV9 )->( VV1_CHASSI ),"") , IIf(lVeic,Transform(( _cAlVV9 )->( VV1_PLAVEI ),VV1->(x3Picture("VV1_PLAVEI"))),"") , ( _cAlVV9 )->( VV9_FILIAL ) })
EndIf
( _cAlVV9 )->( DbCloseArea() )
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERATEND | Autor ³  Andre Luis Almeida ³ Data ³ 22/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza Atendimento no VEIVM011                          |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_VERATEND(cEmpFil,cAtend)
Local cFilSALVA:= cFilAnt
Private Inclui  := .f. // Variavel INTERNA utilizada no VEIVM011
Private Altera  := .f. // Variavel INTERNA utilizada no VEIVM011
Private lEmiNfi := .t. // Variavel INTERNA utilizada no VEIVM011
Private lNegPag := .t. // Variavel INTERNA utilizada no VEIVM011
Private lLibVei := .f. // Variavel INTERNA utilizada no VEIVM011
Private lAutFat := .f. // Variavel INTERNA utilizada no VEIVM011
Private _lVerBotoes := .f. // Variavel INTERNA utilizada no VEIVM011
Private bFiltraBrw := {|| Nil}
Private aCampos := {}
Private cCadastro := STR0034 // Atendimentos
Private aNewBot := {}
Private aRotina := {{"","PesqV011", 0, 1},;
	  			{"","ATEND011", 0, 2},;
				{"","ATEND011", 0, 3},;
				{"","ATEND011", 0, 4},;
				{"","ATEND011", 0, 5}}
DbSelectArea("VV9")
DbSetOrder(1)
cFilAnt := cEmpFil
If DbSeek( xFilial("VV9") + cAtend )
	If !FM_PILHA("VEIXX002") .and. !FM_PILHA("VEIXX030")
		VEIXX002(NIL,NIL,NIL,2,)
	EndIf
EndIf
cFilAnt := cFilSALVA
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILIAIS³ Autor ³  Andre Luis Almeida   ³ Data ³ 11/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Filiais                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILIAIS()
Local aVetAux    := {}
Local ni         := {}
Local cBkpFilAnt := cFilAnt
Local nCont      := 0
Local aFilAtu    := {}
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aFilAtu := FWArrFilAtu()
	ni := aScan(aEmpr,{|x| x[1] == cFilAnt })
	aAdd( aVetEmp, { (ni>0) , cFilAnt , aFilAtu[SM0_FILIAL] , FWFilialName() })
Next
cFilAnt := cBkpFilAnt
If Len(aVetEmp) > 1
	DEFINE MSDIALOG oDlgEmp FROM 05,01 TO 250,400 TITLE STR0009 PIXEL // Filiais
	@ 001,001 LISTBOX oLbEmp FIELDS HEADER  (""),STR0012,STR0013 COLSIZES 10,15,50 SIZE 165,120 OF oDlgEmp ON DBLCLICK (aVetEmp[oLbEmp:nAt,1]:=!aVetEmp[oLbEmp:nAt,1]) PIXEL // Filial / Nome
	oLbEmp:SetArray(aVetEmp)
	oLbEmp:bLine := { || {  IIf(aVetEmp[oLbEmp:nAt,1],oOk,oNo) ,;
	aVetEmp[oLbEmp:nAt,3],;
	aVetEmp[oLbEmp:nAt,4] }}
	DEFINE SBUTTON FROM 001,170 TYPE 1  ACTION (oDlgEmp:End()) ENABLE OF oDlgEmp
	@ 002, 002 CHECKBOX oMacTod VAR lMarcar PROMPT "" OF oDlgEmp ON CLICK IIf( FS_TIK(lMarcar ) , .t. , ( lMarcar:=!lMarcar , oDlgEmp:Refresh() ) ) 	SIZE 70,08 PIXEL COLOR CLR_BLUE
	ACTIVATE MSDIALOG oDlgEmp CENTER
EndIf
If len(aVetEmp) == 1
	aVetEmp[1,1] := .t.
EndIf
For ni := 1 to len(aVetEmp)
	If aVetEmp[ni,1]
		aAdd( aVetAux, { aVetEmp[ni,2] , aVetEmp[ni,3] })
		cEmpr += Alltrim(aVetEmp[ni,2])+", "
	EndIf
Next
If len(aVetAux) > 1
	cEmpr := substr(cEmpr,1,len(cEmpr)-2)
EndIf
Return(aVetAux)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK     ³ Autor ³  Andre Luis Almeida ³ Data ³ 11/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ TIK no ListBox da Empresa/Filiais                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_TIK(lMarcar)
Local ni := 0
Default lMarcar := .f.
For ni := 1 to Len(aVetEmp)
	If lMarcar 
		aVetEmp[ni,1] := .t.
	Else
		aVetEmp[ni,1] := .f.
	EndIf
Next
oLbEmp:SetFocus()
oLbEmp:Refresh()
Return(.t.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_RESUMO³ Autor ³  Thiago             ³ Data ³ 22/11/13 ³  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Resumo do estoque por modelo.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_RESUMO()    
Local i := 0 
aLevVei := {}         
                          
cinicio := "0"        
if Len(aLevVei) == 0
	aAdd(aLevVei, { STR0056,Len(aLevVeic)} )  
Endif	

aSort(aLevVeic,1,,{|x,y| x[1]+strzero(999999999-x[7],10) < y[1]+strzero(999999999-y[7],10) }) // Ordenar Vetor de Veiculos

For i := 1 to Len(aLevVeic) 
	
  	if cInicio <> aLevVeic[i,1]   
		aAdd(aLevVei, { aLevVeic[i,1],1} )
	Else
		ni := aScan(aLevVei,{|x| x[1] == aLevVeic[i,1] })  
		aLevVei[ni,2] += 1
	Endif
	cInicio := aLevVeic[i,1]
Next
aSort(aLevVeic,1,,{|x,y| x[12]+x[1]+strzero(999999999-x[7],10) < y[12]+y[1]+strzero(999999999-y[7],10) }) // Ordenar Vetor de Veiculos
           

Return(.t.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_RESMOD³ Autor ³  Thiago             ³ Data ³ 22/11/13 ³  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Resumo do estoque por modelo.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_RESMOD(cVeiculo)    
Local i := 0 

nLin := 1
if nLinFil <> 0
	oFilVei:nAt := 1
Endif 

aBkpVei := {}  
aLevVeic := aClone(aVeiculo)           
For i := 1 to Len(aLevVeic) 
  	if cVeiculo == aLevVeic[i,1] .or. cVeiculo == STR0056
		aAdd(aBkpVei, { aLevVeic[i,1] , aLevVeic[i,2] , aLevVeic[i,3] , aLevVeic[i,4] ,aLevVeic[i,5] , aLevVeic[i,6] , aLevVeic[i,7] , aLevVeic[i,8] , aLevVeic[i,9] , aLevVeic[i,10] , aLevVeic[i,11] , aLevVeic[i,12] , aLevVeic[i, 13]} )
	Endif
Next
aLevVeic := aClone(aBkpVei)           

If lVV1_DTFATT // Dias de Transito
	oLbVeic:SetArray(aLevVeic)
	oLbVeic:SetArray(aLevVeic)
	oLbVeic:bLine := { || { aLevVeic[oLbVeic:nAt,12] ,; 
							aLevVeic[oLbVeic:nAt,01] ,; 
							aLevVeic[oLbVeic:nAt,02] ,;
							aLevVeic[oLbVeic:nAt,03] ,;
							aLevVeic[oLbVeic:nAt,04] ,;
							aLevVeic[oLbVeic:nAt,05] ,;
							aLevVeic[oLbVeic:nAt,06] ,;
							FG_AlinVlrs(Transform(aLevVeic[oLbVeic:nAt,07],"@E 999,999")) ,;
							FG_AlinVlrs(Transform(aLevVeic[oLbVeic:nAt,11],"@E 999,999")) ,;
							FG_AlinVlrs(Transform(aLevVeic[oLbVeic:nAt,08],"@E 999,999,999.99")) ,;
							aLevVeic[oLbVeic:nAt,09] ,;
							aLevVeic[oLbVeic:nAt,10] }}
Else
	oLbVeic:SetArray(aLevVeic)
	oLbVeic:bLine := { || { aLevVeic[oLbVeic:nAt,12] ,; 
							aLevVeic[oLbVeic:nAt,01] ,; 
							aLevVeic[oLbVeic:nAt,02] ,;
							aLevVeic[oLbVeic:nAt,03] ,;
							aLevVeic[oLbVeic:nAt,04] ,;
							aLevVeic[oLbVeic:nAt,05] ,;
							aLevVeic[oLbVeic:nAt,06] ,;
							FG_AlinVlrs(Transform(aLevVeic[oLbVeic:nAt,07],"@E 999,999")) ,;
							FG_AlinVlrs(Transform(aLevVeic[oLbVeic:nAt,08],"@E 999,999,999.99")) ,;
							aLevVeic[oLbVeic:nAt,09] ,;
							aLevVeic[oLbVeic:nAt,10] }}
Endif
FS_RESFIL()

oLbVeic:Refresh()
oLbVei:Refresh()
oFilVei:Refresh()
oTitTela:Refresh()
Return(.t.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_RESFIL ³ Autor ³  Thiago             ³ Data ³ 08/01/14 ³ ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Resumo do estoque por filial.	                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_RESFIL()    
Local i := 0 
aFilVei := {}         
                          
cinicio := "0"       
nLinFil := 1
if nLin == 0
	nA := 1
Else
	nA := oLbVei:nAt
Endif 
if Len(aFilVei) == 0   
	aAdd(aFilVei, { STR0056,aLevVei[nA,2],aLevVei[nA,1]} )  
Endif	

For i := 1 to Len(aLevVeic) 
	
  	if cInicio <> aLevVeic[i,12]   
		aAdd(aFilVei, { aLevVeic[i,12],1,aLevVei[nA,1]} )
	Else
		ni := aScan(aFilVei,{|x| x[1]+x[3] == aLevVeic[i,12]+aLevVei[nA,1] })  
		aFilVei[ni,2] += 1
	Endif
	cInicio := aLevVeic[i,12]
Next
if nLin <> 0
	oFilVei:SetArray(aFilVei)
	oFilVei:bLine := { || { aFilVei[oFilVei:nAt,01],;
							transform(aFilVei[oFilVei:nAt,02],"99999")}}
	oFilVei:Refresh()
Endif        
Return(.t.)