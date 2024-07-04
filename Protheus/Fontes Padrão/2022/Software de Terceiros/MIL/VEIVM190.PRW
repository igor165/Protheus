#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "VEIVM190.CH"
#INCLUDE "TOPCONN.CH"

Static cDMSPrefOri := GetNewPar("MV_PREFVEI","VEI")
Static cMVMIL0006  := GetNewPar("MV_MIL0006","")

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ VEIVM190 ∫ Autor ≥ Andre Luis Almeida ∫ Data ≥  14/08/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Pedidos de Maquinas / Bonus por Chassi                     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Veiculos                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function VEIVM190()
Local aObjects  := {} , aPos := {} , aInfo := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cBotPED   := repl("0",20)
Local ni        := 0
//
Local cQuery     := ""
Local cQAlSQL    := "ALIASSQL"
Local lVQ0_ITETRA := ( VQ0->(ColumnPos("VQ0_ITETRA")) > 0 )
Local lVQ0_STATUS := ( VQ0->(ColumnPos("VQ0_STATUS")) > 0 )
Local lVQ0_SEGMOD := ( VQ0->(ColumnPos("VQ0_SEGMOD")) > 0 )
Local lPEVM190COR := ExistBlock("VM190COR")
//
Private lBotAtu := .t.
Private nMaxDias:= GetNewPar("MV_MIL0035",0) // Qtde de meses para retroagir que ser· possÌvel modificar os bÙnus em atendimentos j· faturados.
//
Private cStaPed := " "
Private cNumPed := space(TamSX3("VQ0_NUMPED")[1])
Private cFilPed := xFilial("SD2")
Private dDatIni := ctod("")
Private dDatFin := cTod("")
Private cFilAte := space(TamSX3("VQ0_FILATE")[1])
Private cNumAte := space(TamSX3("VQ0_NUMATE")[1])
Private cNumNFI := space(TamSX3("VQ1_NUMNFI")[1])
Private cSerNFI := space(FGX_MILSNF("VQ1", 6, "VQ1_SERNFI"))

Private cCodCli := space(TamSX3("VV9_CODCLI")[1])
Private cLojCli := space(TamSX3("VV9_LOJA")[1])
Private cChassi := space(TamSX3("VV1_CHASSI")[1])
Private cCodMar := space(TamSX3("VV1_CODMAR")[1])
Private cModVei := space(TamSX3("VV1_MODVEI")[1])
Private cSegMod := space(TamSX3("VV1_SEGMOD")[1])
Private dDtIFDD := cTod("")
Private dDtFFDD := cTod("")
Private dDtIEnt := cTod("")
Private dDtFEnt := cTod("")
Private dDtIVen := cTod("")
Private dDtFVen := cTod("")
Private cFatDir := ""
Private cNFGera := ""

Private nPDcCon := 0
Private nPDcTri := 0
Private nPDcCdc := 0
Private nPDcTat := 0
Private nPBonus := 0
Private nPImpos := 0
Private nVlrIni := 0
Private cCadastro := ""
Private aCposUser := {}
Private aCposFil  := {}
//
Private aPedid  := {} // Vetor com os Pedidos
Private aBonus  := {} // Vetor com os Bonus referente ao Chassi selecionado no "aPedid"
//
Private oNada   := LoadBitmap( GetResources() , "NADA" )		// Nenhuma figura
Private oLBNO   := LoadBitmap( GetResources() , "LBNO" )		// Sem TIK
Private oLBTIK  := LoadBitmap( GetResources() , "LBTIK" )		// Com TIK
Private oLBAten := LoadBitmap( GetResources() , "PMSEDT4" )		// Bonus selecionado no Atendimento
//
Private oS1     := LoadBitmap( GetResources() , "BR_AMARELO" )	// 1=Gravado
Private oS2     := LoadBitmap( GetResources() , "BR_VERDE" )	// 2=A faturar
Private oS3     := LoadBitmap( GetResources() , "BR_AZUL" )		// 3=NF gerada
Private oS4     := LoadBitmap( GetResources() , "BR_VERMELHO" )	// 4=Cancelado
//
Private aCoresVQ0   := {}
Private aCores2Col  := {}
//
Private aNewBot := {}

Private _VV2CODMAR_Filtro := "" // Variaveis usadas na consulta padrao
Private _VV2GRUMOD_Filtro := "" // Variaveis usadas na consulta padrao
Private _VV2MODVEI_Filtro := "" // Variaveis usadas na consulta padrao

//
If GetNewPar("MV_MIL0014","0") == "0" // Utiliza Central de Pedido? (0=N„o;1=Sim)
	MsgStop(STR0068,STR0050) // Rotina desabilitada! ( parametro MV_MIL0014 ) / Atencao
	Return()
EndIf
//
aRotina := {{ " " ," " , 0, 1},;	// Pesquisar
			{ " " ," " , 0, 2},;	// Visualizar
			{ " " ," " , 0, 3},;	// Incluir
			{ " " ," " , 0, 4},;	// Alterar
			{ " " ," " , 0, 5} }	// Excluir

If !Empty(FMX_LEVXNU(11,"VEIVM200"))
	aNewBot := {{"S4WB014B",{|| VEIVM200() },STR0066}} // Transmissao/Recepcao de NFs
EndIf

// Ponto de entrada para inclusao de botoes no acoes relacionadas
If ExistBlock("VM190BOT") 
	aNewBot := ExecBlock("VM190BOT",.f.,.f.,{aNewBot})
EndIf

If lVQ0_STATUS
	// Ponto de Entrada utilizado para manipular as cores do Status do Pedido ( VQ0_STATUS )
	If ExistBlock("VM190STA") 
		aCoresVQ0 := ExecBlock("VM190STA",.f.,.f.)
	Else // Cores Padrao - VQ0_STATUS
		aAdd(aCoresVQ0,{ "1" , LoadBitmap( GetResources() , "BR_VERDE"    ) , "BR_VERDE"    }) // Confirmado
		aAdd(aCoresVQ0,{ "2" , LoadBitmap( GetResources() , "BR_AZUL"     ) , "BR_AZUL"     }) // Faturado
		aAdd(aCoresVQ0,{ "3" , LoadBitmap( GetResources() , "BR_VERMELHO" ) , "BR_VERMELHO" }) // Cancelado
	EndIf
EndIf
aAdd(aCoresVQ0,{ " " , LoadBitmap( GetResources() , "BR_BRANCO"   ) , "BR_BRANCO"   }) // Status n„o definido

// Ponto de Entrada para adicionar novos campos da VQ0
If ExistBlock("VM190CPO")
	aCposUser := ExecBlock("VM190CPO", .f., .f.)

	If Len(aCposUser) > 0
		For ni := 1 to Len(aCposUser)
			Private &("x" + aCposUser[ni]) := ""
		Next
	EndIf
EndIf
//
// Atualiza o CHASSI, caso houve atualizaÁ„o no VV1
cQuery := "SELECT VQ0.R_E_C_N_O_ AS RECVQ0 , VV1.VV1_CHASSI "
cQuery += "FROM "+RetSQLName("VQ0")+" VQ0 "
cQuery += "LEFT JOIN "+RetSQLName("VV1")+" VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VQ0.VQ0_CHAINT AND VV1.VV1_CHASSI<>' ' AND VV1.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VQ0.VQ0_FILIAL='"+xFilial("VQ0")+"'"
cQuery += "  AND VQ0.VQ0_CHASSI=' '"
cQuery += "  AND VQ0.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	DbSelectArea("VQ0")
	DbGoto(( cQAlSQL )->( RECVQ0 ))
	RecLock("VQ0",.f.)
	VQ0->VQ0_CHASSI := ( cQAlSQL )->( VV1_CHASSI )
	MsUnLock()
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
DbSelectArea("VQ0")

// Atualiza o VQ0_ITETRA no Pedido, caso esteja em branco
If lVQ0_ITETRA
	cQuery := "SELECT VQ0.R_E_C_N_O_ AS RECVQ0 , VVA.VVA_ITETRA "
	cQuery += "FROM "+RetSQLName("VQ0")+" VQ0 "
	cQuery += "LEFT JOIN "+RetSQLName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VQ0.VQ0_FILATE AND VVA.VVA_NUMTRA=VQ0.VQ0_NUMATE AND VVA.VVA_CHAINT=VQ0.VQ0_CHAINT AND VVA.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VQ0.VQ0_FILIAL='"+xFilial("VQ0")+"'"
	cQuery += "  AND VQ0.VQ0_ITETRA=' '"
	cQuery += "  AND VQ0.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	While !( cQAlSQL )->( Eof() )
		DbSelectArea("VQ0")
		DbGoto(( cQAlSQL )->( RECVQ0 ))
		RecLock("VQ0",.f.)
		VQ0->VQ0_ITETRA := ( cQAlSQL )->( VVA_ITETRA )
		MsUnLock()
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("VQ0")
EndIf
//
If VAI->(ColumnPos("VAI_BOTPED")) > 0
	cBotPED := left(FGX_USERVL(xFilial("VAI"),__cUserID,"VAI_BOTPED","?")+repl("0",20),20)
EndIf
//
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0 , 50 , .T. , .T. } ) // ListBox Pedidos/Maquinas
AAdd( aObjects, { 0 ,106 , .T. , .F. } ) // ListBox Bonus por Chassi
aPos := MsObjSize( aInfo, aObjects )
//
FS_LEVANTA(0,.f.)
//
DEFINE MSDIALOG oVEIVM190 TITLE STR0001 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Pedidos de Maquinas
oVEIVM190:lEscClose := .F.
//
oTScroll1 := TScrollBox():New( oVEIVM190 , aPos[1,1]+008 , aPos[1,2] , aPos[1,3] - aPos[1,1] - 012 , 111 , .t. , , .t. )
//
VVM1900011_MontaFiltrosPedidos()
//
@ aPos[1,1]+000,aPos[1,2]+000 TO aPos[1,3],aPos[1,4] LABEL STR0009 OF oVEIVM190 PIXEL // Pedidos
oLbPedid := TWBrowse():New(aPos[1,1]+030,aPos[1,2]+114,aPos[1,4]-120,aPos[1,3]-aPos[1,1]-34,,,,oVEIVM190,,,,{ || FS_LEVANTA(1,.t.) },{ || IIf(substr(cBotPED,2,1)=="1",FS_VQ0(4,oLbPedid:nAt,STR0022),MsgInfo(STR0108,STR0050)) },,,,,,,.F.,,.T.,,.F.,,,)
If lVQ0_STATUS
	oLbPedid:addColumn( TCColumn():New( ""  , { || aCoresVQ0[ascan(aCoresVQ0,{|x| x[1] == aPedid[oLbPedid:nAt,32] }),2] } ,,,,"LEFT" , 08,.T.,.F.,,,,.F.,) ) // Cor 1
EndIf
If lPEVM190COR
	oLbPedid:addColumn( TCColumn():New( ""  , { || VVM1900021_Cor2Coluna( aPedid , oLbPedid:nAt ) }         ,,,,"LEFT" , 08,.T.,.F.,,,,.F.,) ) // Cor 2
EndIf
oLbPedid:addColumn( TCColumn():new( RetTitle("VQ0_FILPED") , { || aPedid[oLbPedid:nAt,19] }                                ,,,,"LEFT" , 40,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( RetTitle("VQ0_NUMPED") , { || aPedid[oLbPedid:nAt,01] }                                ,,,,"LEFT" , 40,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( STR0010 , { || Transform(stod(aPedid[oLbPedid:nAt,02]),"@D") }          ,,,,"LEFT" , 38,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( RetTitle("VQ0_CHASSI") , { || aPedid[oLbPedid:nAt,03] }                                ,,,,"LEFT" , 70,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( RetTitle("VQ0_CODMAR") , { || aPedid[oLbPedid:nAt,04] }                                ,,,,"LEFT" , 20,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( RetTitle("VQ0_MODVEI") , { || aPedid[oLbPedid:nAt,05] }                                ,,,,"LEFT" , 60,.F.,.F.,,,,.F.,) )
If lVQ0_SEGMOD
	oLbPedid:addColumn( TCColumn():new( RetTitle("VV1_SEGMOD") , { || aPedid[oLbPedid:nAt,33] }                            ,,,,"LEFT" , 40,.F.,.F.,,,,.F.,) )
EndIf
oLbPedid:addColumn( TCColumn():new( RetTitle("VQ0_CORVEI") , { || aPedid[oLbPedid:nAt,06] }                                ,,,,"LEFT" , 45,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( STR0015 , { || Transform(stod(aPedid[oLbPedid:nAt,11]),"@D") }          ,,,,"LEFT" , 38,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( RetTitle("VQ0_DATPRE") , { || Transform(stod(aPedid[oLbPedid:nAt,24]),"@D") }          ,,,,"LEFT" , 38,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( STR0016 , { || Transform(stod(aPedid[oLbPedid:nAt,12]),"@D") }          ,,,,"LEFT" , 38,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( RetTitle("VV1_FILENT") , { || aPedid[oLbPedid:nAt,22] }                                ,,,,"LEFT" , 40,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( STR0017 , { || aPedid[oLbPedid:nAt,13] }                                ,,,,"LEFT" , 40,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( RetTitle("VQ0_NUMATE") , { || aPedid[oLbPedid:nAt,14] }                                ,,,,"LEFT" , 40,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( STR0120 , { || aPedid[oLbPedid:nAt,25] }                                ,,,,"LEFT" , 20,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( RetTitle("C5_CLIENTE") , { || aPedid[oLbPedid:nAt,20] }                                ,,,,"LEFT" ,100,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( STR0034 , { || aPedid[oLbPedid:nAt,18] }                                ,,,,"LEFT" ,100,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( RetTitle("VQ0_FATDIR") , { || IIf(aPedid[oLbPedid:nAt,07]=="0",STR0084,STR0085) }      ,,,,"LEFT" , 50,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( RetTitle("VQ0_VALCUS") , { || Transform(aPedid[oLbPedid:nAt,08],"@E 999,999,999.99") } ,,,,"RIGHT", 50,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( RetTitle("VQ0_VALINI") , { || Transform(aPedid[oLbPedid:nAt,09],"@E 999,999,999.99") } ,,,,"RIGHT", 50,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( RetTitle("VQ0_DATFDD") , { || Transform(stod(aPedid[oLbPedid:nAt,15]),"@D") }          ,,,,"LEFT" , 38,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( RetTitle("VQ0_DESNEG") , { || Transform(aPedid[oLbPedid:nAt,10],"@E 999.99") }         ,,,,"RIGHT", 30,.F.,.F.,,,,.F.,) )
oLbPedid:addColumn( TCColumn():new( RetTitle("VQ0_CONFIG") , { || aPedid[oLbPedid:nAt,16] }                                ,,,,"LEFT" ,200,.F.,.F.,,,,.F.,) )
oLbPedid:nAT := 1
oLbPedid:SetArray(aPedid)
//
@ aPos[1,1]+011,117+000 BUTTON oIncPed PROMPT STR0021 OF oVEIVM190 SIZE 33,12 PIXEL ACTION IIf(FS_VQ0(3,oLbPedid:nAt,STR0021),FS_LEVANTA(0,.t.),.t.)	WHEN ( substr(cBotPED,01,1) == "1" )	// Incluir
@ aPos[1,1]+011,117+036 BUTTON oAltPed PROMPT STR0022 OF oVEIVM190 SIZE 33,12 PIXEL ACTION FS_VQ0(4,oLbPedid:nAt,STR0022)								WHEN ( substr(cBotPED,02,1) == "1" .and. !Empty(aPedid[oLbPedid:nAt,01]) )	// Alterar
@ aPos[1,1]+011,117+072 BUTTON oExcPed PROMPT STR0023 OF oVEIVM190 SIZE 33,12 PIXEL ACTION FS_VQ0(5,oLbPedid:nAt,STR0023)								WHEN ( substr(cBotPED,03,1) == "1" .and. !Empty(aPedid[oLbPedid:nAt,01]) )	// Excluir
If lVQ0_STATUS
	@ aPos[1,1]+011,117+108 BUTTON oLegPed PROMPT STR0042 OF oVEIVM190 SIZE 33,12 PIXEL ACTION VVM1900031_LegendaPedidos() // Legenda
EndIf

@ aPos[1,1]+007,117+146 BUTTON oRelCha PROMPT STR0109 OF oVEIVM190 SIZE 70,09 PIXEL ACTION IIf(FS_RELCHA(oLbPedid:nAt),(FS_LEVANTA(0,.t.),FS_LEVANTA(1,.t.)),.t.) WHEN ( substr(cBotPED,11,1) == "1" .and. !Empty(aPedid[oLbPedid:nAt,01]) .and.  Empty(aPedid[oLbPedid:nAt,03]) ) // Relaciona Chassi
@ aPos[1,1]+018,117+146 BUTTON oDesCha PROMPT STR0129 OF oVEIVM190 SIZE 70,09 PIXEL ACTION IIf(FS_RELCHA(oLbPedid:nAt),(FS_LEVANTA(0,.t.),FS_LEVANTA(1,.t.)),.t.) WHEN ( substr(cBotPED,14,1) == "1" .and. !Empty(aPedid[oLbPedid:nAt,01]) .and. !Empty(aPedid[oLbPedid:nAt,30]) ) // Desfazer Relac. Chassi

@ aPos[1,1]+007,117+218 BUTTON oExeCfg PROMPT STR0105 OF oVEIVM190 SIZE 70,09 PIXEL ACTION FS_GERCFG()															// ConfiguraÁ„o
@ aPos[1,1]+018,117+218 BUTTON oBtnBlq PROMPT STR0128 OF oVEIVM190 SIZE 70,09 PIXEL ACTION VEIVM060(aPedid[oLbPedid:nAt,26])  WHEN ( substr(cBotPED,13,1) == "1" .and. !Empty(aPedid[oLbPedid:nAt,26]) ) // Bloqueio(VEIVM060)

@ aPos[1,1]+007,117+290 BUTTON oVisAte PROMPT STR0115 OF oVEIVM190 SIZE 70,09 PIXEL ACTION FS_ATENDTO(aPedid[oLbPedid:nAt,13],aPedid[oLbPedid:nAt,14]) WHEN ( !Empty(aPedid[oLbPedid:nAt,14]) )	// Visualiza Atendimento
@ aPos[1,1]+018,117+290 BUTTON oObsVV1 PROMPT STR0126 OF oVEIVM190 SIZE 70,09 PIXEL ACTION FS_OBSVV1(aPedid[oLbPedid:nAt,26]) WHEN ( substr(cBotPED,12,1) == "1" .and. !Empty(aPedid[oLbPedid:nAt,26]) ) // Obs.M·q./Equip.

@ aPos[1,1]+007,aPos[1,4]-064 BUTTON oGerBon PROMPT STR0040 OF oVEIVM190 SIZE 60,09 PIXEL ACTION ( FS_GERARNF() , FS_LEVANTA(1,.t.) ) WHEN ( substr(cBotPED,04,1) == "1" ) // Gerar NF Bonus
@ aPos[1,1]+018,aPos[1,4]-064 BUTTON oBcoCon PROMPT STR0132 OF oVEIVM190 SIZE 60,09 PIXEL ACTION VM190BCO(aPedid[oLbPedid:nAt,17]) WHEN (aPedid[oLbPedid:nAt,17] > 0)

@ aPos[2,1]+008,aPos[2,2]+030 SAY UPPER(STR0024) SIZE 80,8 OF oVEIVM190 PIXEL COLOR CLR_HBLUE // % Default
@ aPos[2,1]+019,aPos[2,2]+005 SAY (RetTitle("VQ1_DESCON")+":") SIZE 55,8 OF oVEIVM190 PIXEL COLOR CLR_BLUE // Desc.Concessao
@ aPos[2,1]+018,aPos[2,2]+051 MSGET oPDcCon VAR nPDcCon PICTURE "@E 999.99" VALID ( nPDcCon >= 0 .and. nPDcCon <= 100 ) SIZE 25,08 OF oVEIVM190 PIXEL HASBUTTON COLOR CLR_BLACK WHEN ( substr(cBotPED,10,1) == "1" )
@ aPos[2,1]+031,aPos[2,2]+005 SAY (RetTitle("VQ1_DESTRI")+":") SIZE 55,8 OF oVEIVM190 PIXEL COLOR CLR_BLUE // Desc.Tributacao
@ aPos[2,1]+030,aPos[2,2]+051 MSGET oPDcTri VAR nPDcTri PICTURE "@E 999.99" VALID ( nPDcTri >= 0 .and. nPDcTri <= 100 ) SIZE 25,08 OF oVEIVM190 PIXEL HASBUTTON COLOR CLR_BLACK WHEN ( substr(cBotPED,10,1) == "1" )
@ aPos[2,1]+043,aPos[2,2]+005 SAY (RetTitle("VQ1_DESCON")+":") SIZE 55,8 OF oVEIVM190 PIXEL COLOR CLR_BLUE // Desc.Condicao
@ aPos[2,1]+042,aPos[2,2]+051 MSGET oPDcCdc VAR nPDcCdc PICTURE "@E 999.99" VALID ( nPDcCdc >= 0 .and. nPDcCdc <= 100 ) SIZE 25,08 OF oVEIVM190 PIXEL HASBUTTON COLOR CLR_BLACK WHEN ( substr(cBotPED,10,1) == "1" )
@ aPos[2,1]+055,aPos[2,2]+005 SAY (RetTitle("VQ1_DESTAT")+":") SIZE 55,8 OF oVEIVM190 PIXEL COLOR CLR_BLUE // Desc.Tatico
@ aPos[2,1]+054,aPos[2,2]+051 MSGET oPDcTat VAR nPDcTat PICTURE "@E 999.99" VALID ( nPDcTat >= 0 .and. nPDcTat <= 100 ) SIZE 25,08 OF oVEIVM190 PIXEL HASBUTTON COLOR CLR_BLACK WHEN ( substr(cBotPED,10,1) == "1" )
@ aPos[2,1]+067,aPos[2,2]+005 SAY (STR0029+":") SIZE 55,8 OF oVEIVM190 PIXEL COLOR CLR_BLUE // Bonus
@ aPos[2,1]+066,aPos[2,2]+051 MSGET oPBonus VAR nPBonus PICTURE "@E 999.99" VALID ( nPBonus >= 0 .and. nPBonus <= 100 ) SIZE 25,08 OF oVEIVM190 PIXEL HASBUTTON COLOR CLR_BLACK WHEN ( substr(cBotPED,10,1) == "1" )
@ aPos[2,1]+079,aPos[2,2]+005 SAY (RetTitle("VQ1_PERIMP")+":") SIZE 55,8 OF oVEIVM190 PIXEL COLOR CLR_BLUE // Prev.Impostos
@ aPos[2,1]+078,aPos[2,2]+051 MSGET oPImpos VAR nPImpos PICTURE "@E 999.99" VALID ( nPImpos >= 0 .and. nPImpos <= 100 ) SIZE 25,08 OF oVEIVM190 PIXEL HASBUTTON COLOR CLR_BLACK WHEN ( substr(cBotPED,10,1) == "1" )
@ aPos[2,1]+092,aPos[2,2]+015 BUTTON oLevBon PROMPT STR0030 OF oVEIVM190 SIZE 60,09 PIXEL ACTION FS_LEVANTA(2,.t.) WHEN ( substr(cBotPED,10,1)=="1" .and. aPedid[oLbPedid:nAt,17]>0 ) // Levantar Bonus
//
@ aPos[2,1]+000,aPos[2,2]+000 TO aPos[2,3],aPos[2,4] LABEL STR0029 OF oVEIVM190 PIXEL // Bonus
oLbBonus := TWBrowse():New(aPos[2,1]+008,aPos[2,2]+090,aPos[2,4]-162,aPos[2,3]-aPos[2,1]-12,,,,oVEIVM190,,,,,{ || IIf(substr(cBotPED,06,1)=="1",FS_DBLCLICK(oLbBonus:nAt,oLbBonus:nColPos),MsgInfo(STR0108,STR0050)) },,,,,,,.F.,,.T.,,.F.,,,)
oLbBonus:addColumn( TCColumn():New( "", { || IIf(aBonus[oLbBonus:nAt,15],oLBTIK,oLBNO)                               } ,,,,"LEFT" , 08,.T.,.F.,,,,.F.,) ) // Cor 1
oLbBonus:addColumn( TCColumn():New( "", { || IIf(aBonus[oLbBonus:nAt,19],oLBAten,oNada)                              } ,,,,"LEFT" , 08,.T.,.F.,,,,.F.,) ) // Cor 2
oLbBonus:addColumn( TCColumn():New( "", { || &(aBonus[oLbBonus:nAt,01])                                              } ,,,,"LEFT" , 08,.T.,.F.,,,,.F.,) ) // Cor 3
oLbBonus:addColumn( TCColumn():new( STR0029 , { || aBonus[oLbBonus:nAt,02] }                                           ,,,,"LEFT" , 35,.F.,.F.,,,,.F.,) )
oLbBonus:addColumn( TCColumn():new( STR0118 , { || aBonus[oLbBonus:nAt,20] }                                           ,,,,"LEFT" , 40,.F.,.F.,,,,.F.,) )
oLbBonus:addColumn( TCColumn():new( STR0097 , { || aBonus[oLbBonus:nAt,18] }                                           ,,,,"LEFT" , TamSX3('VZQ_DESCRI')[1]+10,.F.,.F.,,,,.F.,) )
oLbBonus:addColumn( TCColumn():new( RetTitle("VQ0_VALINI") , { || Transform(aBonus[oLbBonus:nAt,03],"@E 999,999,999.99") }            ,,,,"RIGHT", 45,.F.,.F.,,,,.F.,) )
oLbBonus:addColumn( TCColumn():new( left(RetTitle("VQ1_DESCON"),9) , { || Transform(aBonus[oLbBonus:nAt,04],"@E 999.99")+" %" }       ,,,,"RIGHT", 35,.F.,.F.,,,,.F.,) )
oLbBonus:addColumn( TCColumn():new( left(RetTitle("VQ1_DESTRI"),9) , { || Transform(aBonus[oLbBonus:nAt,05],"@E 999.99")+" %" }       ,,,,"RIGHT", 35,.F.,.F.,,,,.F.,) )
oLbBonus:addColumn( TCColumn():new( left(RetTitle("VQ1_DESCON"),9) , { || Transform(aBonus[oLbBonus:nAt,06],"@E 999.99")+" %" }       ,,,,"RIGHT", 35,.F.,.F.,,,,.F.,) )
oLbBonus:addColumn( TCColumn():new( left(RetTitle("VQ1_DESTAT"),9) , { || Transform(aBonus[oLbBonus:nAt,07],"@E 999.99")+" %" }       ,,,,"RIGHT", 35,.F.,.F.,,,,.F.,) )
oLbBonus:addColumn( TCColumn():new( RetTitle("VQ1_VLRBAS") , { || Transform(aBonus[oLbBonus:nAt,08],"@E 999,999,999.99") }            ,,,,"RIGHT", 45,.F.,.F.,,,,.F.,) )
oLbBonus:addColumn( TCColumn():new( "% "+STR0029 , { || Transform(aBonus[oLbBonus:nAt,09],"@E 999.99")+" %" }          ,,,,"RIGHT", 35,.F.,.F.,,,,.F.,) )
oLbBonus:addColumn( TCColumn():new( STR0033 , { || Transform(aBonus[oLbBonus:nAt,10],"@E 999,999,999.99") }            ,,,,"RIGHT", 45,.F.,.F.,,,,.F.,) )
oLbBonus:addColumn( TCColumn():new( RetTitle("VQ1_PERIMP") , { || Transform(aBonus[oLbBonus:nAt,16],"@E 999.99")+" %" }               ,,,,"RIGHT", 35,.F.,.F.,,,,.F.,) )
oLbBonus:addColumn( TCColumn():new( RetTitle("VQ1_VLRLIQ") , { || Transform(aBonus[oLbBonus:nAt,17],"@E 999,999,999.99") }            ,,,,"RIGHT", 45,.F.,.F.,,,,.F.,) )
oLbBonus:addColumn( TCColumn():new( STR0034 , { || IIf(!Empty(aBonus[oLbBonus:nAt,11]),aBonus[oLbBonus:nAt,11]+"-"+aBonus[oLbBonus:nAt,12],"")} ,,,,"LEFT" , 55,.F.,.F.,,,,.F.,) )
oLbBonus:addColumn( TCColumn():new( STR0035 , { || aBonus[oLbBonus:nAt,13] }                                           ,,,,"LEFT" , 35,.F.,.F.,,,,.F.,) )
oLbBonus:nAT := 1
oLbBonus:SetArray(aBonus)
//
@ aPos[2,1]+008,aPos[2,4]-65 BUTTON oIncBon PROMPT STR0036 OF oVEIVM190 SIZE 60,09 PIXEL ACTION FS_VQ1(3,0,STR0036)					WHEN ( substr(cBotPED,05,1) == "1" ) // Incluir Bonus
@ aPos[2,1]+020,aPos[2,4]-65 BUTTON oAltBon PROMPT STR0037 OF oVEIVM190 SIZE 60,09 PIXEL ACTION FS_VQ1(4,oLbBonus:nAt,STR0037)		WHEN ( substr(cBotPED,06,1) == "1" ) // Alterar Bonus
@ aPos[2,1]+032,aPos[2,4]-65 BUTTON oExcBon PROMPT STR0038 OF oVEIVM190 SIZE 60,09 PIXEL ACTION FS_VQ1(5,oLbBonus:nAt,STR0038)		WHEN ( substr(cBotPED,07,1) == "1" ) // Excluir Bonus
@ aPos[2,1]+044,aPos[2,4]-65 BUTTON oLibBon PROMPT STR0039 OF oVEIVM190 SIZE 60,09 PIXEL ACTION FS_GRAVAR(2,0,"")					WHEN ( substr(cBotPED,08,1) == "1" ) // Libera p/ Gerar NF
@ aPos[2,1]+056,aPos[2,4]-65 BUTTON oCanBon PROMPT STR0041 OF oVEIVM190 SIZE 60,09 PIXEL ACTION ( FS_GRAVAR(4,oLbBonus:nAt,"") , FS_LEVANTA(1,.t.) ) WHEN ( substr(cBotPED,09,1) == "1" ) // Cancelar
@ aPos[2,1]+068,aPos[2,4]-65 BUTTON oBotAtu PROMPT STR0100 OF oVEIVM190 SIZE 60,09 PIXEL ACTION ( FS_ATUATE(1,oLbPedid:nAt,nMaxDias) , FS_LEVANTA(1,.t.) ) WHEN ( lBotAtu ) // Atualiza Atendimento
@ aPos[2,1]+092,aPos[2,4]-65 BUTTON oLegBon PROMPT (STR0042+" "+STR0029) OF oVEIVM190 SIZE 60,09 PIXEL ACTION FS_LEGVM190()			// Legenda
//
ACTIVATE MSDIALOG oVEIVM190 ON INIT EnchoiceBar(oVEIVM190,{|| oVEIVM190:End() , .f. },{|| oVEIVM190:End() },,aNewBot)

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥FS_LEVANTA≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 15/08/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Levanta registros                                           ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_LEVANTA(nTp,lRefresh)
Local lOk        := .t.
Local lNF        := .f.
Local lDel       := .f.
Local ni         := 0
Local nPerDCc    := 0
Local nPerDTr    := 0
Local nPerDCd    := 0
Local nPerDTa    := 0
Local nVlrBas    := 0
Local nPerBon    := 0
Local nVlrBon    := 0
Local nPerImp    := 0
Local nVlrLiq    := 0
Local nVlrDef    := 0
Local cQuery     := ""
Local cQAlSQL    := "ALIASSQL"
Local cQAlAux    := "SQLAUX"
Local cFilSF2    := xFilial("SF2")
Local cFilSE1    := xFilial("SE1")
Local cFilSA1    := xFilial("SA1")
Local cFilVQ1    := xFilial("VQ1")
Local cFilVZQ    := xFilial("VZQ")
Local cFilVR3    := xFilial("VR3")
Local cFilVVA    := ""
Local cFilVQ2    := ""
Local cNamSF2    := RetSQLName("SF2")
Local cNamSE1    := RetSQLName("SE1")
Local cNamVVA    := RetSQLName("VVA")
Local cNamVV9    := RetSQLName("VV9")
Local cNamVV0    := RetSQLName("VV0")
Local cNamSA1    := RetSQLName("SA1")
Local cNamVZQ    := RetSQLName("VZQ")
Local cNamVQ1    := RetSQLName("VQ1")
Local cNamVQ2    := RetSQLName("VQ2")
Local cNamVR3    := RetSQLName("VR3")
Local cTitPag    := ""
Local nSE1Sal    := 0
Local nSE1Tot    := 0
Local aBonVei    := {}
Local aBonAux    := {}
Local cProxSeq   := ""
Local cFAte      := ""
Local cNAte      := ""
Local cIAte      := ""
Local cCliNom    := ""
Local cNroNFs    := ""
Local lFatDir    := .f.
Local cVQ0Chassi := ""
Local nRecVVA    := 0
Local aFilAtu    := FWArrFilAtu()
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt := cFilAnt
Local aBonDel    := {}
Local lSelAten   := .f.
Local aExiste    := DMS_SqlHelper():New()
Local lVZS_FILATE := ( VZS->(ColumnPos("VZS_FILATE")) > 0 )
Local lVZS_ITETRA := ( VZS->(ColumnPos("VZS_ITETRA")) > 0 )
Local lVQ0_ITETRA := ( VQ0->(ColumnPos("VQ0_ITETRA")) > 0 )
Local lVQ0_BASCFD := ( VQ0->(ColumnPos("VQ0_BASCFD")) > 0 )
Local lVQ0_FLUXO  := ( VQ0->(ColumnPos("VQ0_FLUXO" )) > 0 )
Local lVQ0_DATORS := ( VQ0->(ColumnPos("VQ0_DATORS")) > 0 )
Local lVQ0_FILREL := ( VQ0->(ColumnPos("VQ0_FILREL")) > 0 )
Local lVQ0_EVENTO := ( VQ0->(ColumnPos("VQ0_EVENTO")) > 0 )
Local lVQ0_STATUS := ( VQ0->(ColumnPos("VQ0_STATUS")) > 0 )
Local lVQ0_SEGMOD := ( VQ0->(ColumnPos("VQ0_SEGMOD")) > 0 )
Local lVQ1_EVENTO := ( VQ1->(FieldPos("VQ1_EVENTO")) > 0 )
Local aRetVZQ     := {}
Local lPEVM190BAS := ExistBlock("VM190BAS") // Ponto de entrada para alteraÁ„o do Valor Base
//
If nTp == 0 // Levanta VQ0
	//
	aPedid := {}
	//
	If lRefresh // Somente entra para levantar os dados apos click no filtrar da Tela.
		//
		For ni := 1 to Len(aSM0)
			cFilAnt := aSM0[ni]
			cFilVVA += "'"+xFilial("VVA")+"',"
			cFilVQ2 += "'"+xFilial("VQ2")+"',"
		Next
		cFilVVA := left(cFilVVA,len(cFilVVA)-1)
		cFilVQ2 := left(cFilVQ2,len(cFilVQ2)-1)
		cFilAnt := cBkpFilAnt
		//
		cQuery := "SELECT VQ0.VQ0_CHAINT , VQ0.R_E_C_N_O_ RECVQ0 ,"
		cQuery += "       VQ0.VQ0_FILATE , VQ0.VQ0_NUMATE ,"
		If lVQ0_ITETRA
			cQuery += "   VQ0.VQ0_ITETRA ,"
		EndIf
		cQuery += "       VV0.VV0_NUMNFI , VV0.VV0_SERNFI ,"
		cQuery += "       VV1.VV1_SITVEI , VV1.VV1_FILENT "
		cQuery += "FROM "+RetSQLName("VQ0")+" VQ0 "
		cQuery += "LEFT JOIN "+RetSQLName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=VQ0.VQ0_FILATE AND VV0.VV0_NUMTRA=VQ0.VQ0_NUMATE AND VV0.D_E_L_E_T_=' ' ) "
		cQuery += "LEFT JOIN "+RetSQLName("VV1")+" VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VQ0.VQ0_CHAINT AND VV1.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VQ0.VQ0_FILIAL='"+xFilial("VQ0")+"' AND "
		If !Empty(cNumPed)
			cQuery += "VQ0.VQ0_NUMPED='"+cNumPed+"' AND "
		EndIf
		If !Empty(cFilPed)
			cQuery += "VQ0.VQ0_FILPED='"+cFilPed+"' AND "
		EndIf
		If !Empty(cChassi)
			cQuery += "VQ0.VQ0_CHASSI='"+Alltrim(cChassi)+"' AND "
		EndIf
		If !Empty(cCodMar)
			cQuery += "VQ0.VQ0_CODMAR='"+cCodMar+"' AND "
		EndIf
		If !Empty(cModVei)
			cQuery += "VQ0.VQ0_MODVEI='"+cModVei+"' AND "
		EndIf
		If lVQ0_SEGMOD .and. !Empty(cSegMod)
			cQuery += "VQ0.VQ0_SEGMOD='"+cSegMod+"' AND "
		EndIf
		If !Empty(dDatIni)
			cQuery += "VQ0.VQ0_DATPED>='"+dtos(dDatIni)+"' AND "
		EndIf
		If !Empty(dDatFin)
			cQuery += "VQ0.VQ0_DATPED<='"+dtos(dDatFin)+"' AND "
		EndIf
		If !Empty(dDtIFDD)
			cQuery += "VQ0.VQ0_DATFDD>='"+dtos(dDtIFDD)+"' AND "
		EndIf
		If !Empty(dDtFFDD)
			cQuery += "VQ0.VQ0_DATFDD<='"+dtos(dDtFFDD)+"' AND "
		EndIf
		If !Empty(dDtIEnt)
			cQuery += "VQ0.VQ0_DATENT>='"+dtos(dDtIEnt)+"' AND "
		EndIf
		If !Empty(dDtFEnt)
			cQuery += "VQ0.VQ0_DATENT<='"+dtos(dDtFEnt)+"' AND "
		EndIf
		If !Empty(dDtIVen)
			cQuery += "VQ0.VQ0_DATVEN>='"+dtos(dDtIVen)+"' AND "
		EndIf
		If !Empty(dDtFVen)
			cQuery += "VQ0.VQ0_DATVEN<='"+dtos(dDtFVen)+"' AND "
		EndIf
		If !Empty(cFatDir) // Filtrar Faturamento Direto - combo invertido ( 0=Sim / 1=Nao )
			cQuery += "VQ0.VQ0_FATDIR='"+cFatDir+"' AND "
		EndIf
		If lVQ0_STATUS .and. !Empty(cStaPed)
			cQuery += "VQ0.VQ0_STATUS='"+cStaPed+"' AND "
		EndIf

		// Filtro pelos campos customiz·veis (PE VM190CPO)
		If Len(aCposFil) > 0
			For ni := 1 to Len(aCposFil)
				If !Empty(&("x" + aCposFil[ni][1]))
					If aCposFil[ni][2] == "C"
						cQuery += "VQ0." + aCposFil[ni][1] + " = '" + Alltrim(&("x" + aCposFil[ni][1])) + "' AND "
					ElseIf aCposFil[ni][2] == "D"
						cQuery += "VQ0." + aCposFil[ni][1] + " = '" + DtoS(&("x" + aCposFil[ni][1])) + "' AND "
					ElseIf aCposFil[ni][2] == "N"
						cQuery += "VQ0." + aCposFil[ni][1] + " = " + Str(&("x" + aCposFil[ni][1])) + " AND "
					EndIf
				EndIf
			Next
		EndIf

		cQuery += "VQ0.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			//
			cFAte := ( cQAlSQL )->( VQ0_FILATE )
			cNAte := ( cQAlSQL )->( VQ0_NUMATE )
			cIAte := ""
			If lVQ0_ITETRA
				cIAte := ( cQAlSQL )->( VQ0_ITETRA )
			EndIf
			If Empty(cFAte+cNAte)
				nRecVVA := 0
				If !Empty(cNumAte)
					cQuery  := "SELECT VVA.R_E_C_N_O_ FROM "+cNamVVA+" VVA "
					cQuery  += "JOIN "+cNamVV9+" VV9 ON ( VV9.VV9_FILIAL=VVA.VVA_FILIAL AND VV9.VV9_NUMATE=VVA.VVA_NUMTRA AND VV9.VV9_STATUS<>'C' AND VV9.D_E_L_E_T_=' ' ) "
					cQuery  += "WHERE VVA.VVA_FILIAL IN ("+cFilVVA+") AND VVA.VVA_NUMTRA='"+cNumAte+"' AND VVA.VVA_CHAINT='"+( cQAlSQL )->( VQ0_CHAINT )+"' AND VVA.D_E_L_E_T_=' ' "
					cQuery  += "ORDER BY VVA.R_E_C_N_O_ DESC"
					nRecVVA := FM_SQL(cQuery)
				EndIf
				If nRecVVA == 0
					cQuery  := "SELECT VVA.R_E_C_N_O_ FROM "+cNamVVA+" VVA "
					cQuery  += "JOIN "+cNamVV9+" VV9 ON ( VV9.VV9_FILIAL=VVA.VVA_FILIAL AND VV9.VV9_NUMATE=VVA.VVA_NUMTRA AND VV9.VV9_STATUS<>'C' AND VV9.D_E_L_E_T_=' ' ) "
					cQuery  += "WHERE VVA.VVA_FILIAL IN ("+cFilVVA+") AND VVA.VVA_CHAINT='"+( cQAlSQL )->( VQ0_CHAINT )+"' AND VVA.D_E_L_E_T_=' ' "
					cQuery  += "ORDER BY VVA.R_E_C_N_O_ DESC"
					nRecVVA := FM_SQL(cQuery)
				EndIf
				If nRecVVA > 0
					DbSelectArea("VVA")
					DbGoTo(nRecVVA)
					cFAte := VVA->VVA_FILIAL
					cNAte := VVA->VVA_NUMTRA
					cIAte := VVA->VVA_ITETRA
				EndIf
			EndIf
			If !Empty(cFilAte) .and. cFAte <> cFilAte
				( cQAlSQL )->( DbSkip() )
				Loop
			EndIf
			If !Empty(cNumAte) .and. cNAte <> cNumAte
				( cQAlSQL )->( DbSkip() )
				Loop
			EndIf
			cCliNom := ""
			cNroNFs := IIf(!Empty(( cQAlSQL )->( VV0_NUMNFI )),Alltrim(( cQAlSQL )->( VV0_NUMNFI ))+"-"+Alltrim( FGX_UFSNF(( cQAlSQL )->( VV0_SERNFI ))),"")
			If !Empty(cFAte+cNAte)
				lFatDir := .f.
				cQuery := "SELECT VV9.VV9_CODCLI , VV9.VV9_LOJA , VV9.VV9_NOMVIS , SA1.A1_NOME , VV0.VV0_TIPFAT "
				cQuery += "FROM "+cNamVV9+" VV9 "
				cQuery += "JOIN "+cNamVV0+" VV0 ON ( VV0.VV0_FILIAL=VV9.VV9_FILIAL AND VV0.VV0_NUMTRA=VV9.VV9_NUMATE AND VV0.D_E_L_E_T_=' ' ) "
				cQuery += "LEFT JOIN "+cNamSA1+" SA1 ON ( SA1.A1_FILIAL='"+cFilSA1+"' AND SA1.A1_COD=VV9.VV9_CODCLI AND SA1.A1_LOJA=VV9.VV9_LOJA AND SA1.D_E_L_E_T_=' ' ) "
				cQuery += "WHERE VV9.VV9_FILIAL = '"+cFAte+"'"
				cQuery += "  AND VV9.VV9_NUMATE = '"+cNAte+"'"
				cQuery += "  AND VV9.D_E_L_E_T_ = ' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
				If !( cQAlAux )->( Eof() )
					cCliNom := ( cQAlAux )->( VV9_CODCLI ) +"-"+ ( cQAlAux )->( VV9_LOJA ) +" "+ left(IIf(!Empty(( cQAlAux )->( VV9_CODCLI )),( cQAlAux )->( A1_NOME ),( cQAlAux )->( VV9_NOMVIS )),27)
					lFatDir := ( ( cQAlAux )->( VV0_TIPFAT ) == "2" ) // Faturamento Direto
				EndIf
				( cQAlAux )->( DbCloseArea() )
				If !Empty(cCodCli)
					If substr(cCliNom,1,len(cCodCli)) <> cCodCli
						( cQAlSQL )->( DbSkip() )
						Loop
					EndIf
				EndIf
				If !Empty(cLojCli)
					If substr(cCliNom,len(cCodCli)+2,len(cLojCli)) <> cLojCli
						( cQAlSQL )->( DbSkip() )
						Loop
					EndIf
				EndIf
				If lFatDir // Quando Faturamento Direto, mostrar NFs de comissao
					cNroNFs := ""
					cQuery  := "SELECT VQ2_NUMNFI , VQ2_SERNFI"
					cQuery  += "  FROM "+cNamVQ2
					cQuery  += " WHERE VQ2_FILIAL IN ("+cFilVQ2+")"
					cQuery  += "   AND VQ2_FILATE = '"+cFAte+"'"
					cQuery  += "   AND VQ2_NUMATE = '"+cNAte+"'"
					cQuery  += "   AND VQ2_NUMNFI <> ' '"
					cQuery  += "   AND D_E_L_E_T_ = ' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
					While !( cQAlAux )->( Eof() )
						cNroNFs += Alltrim(( cQAlAux )->( VQ2_NUMNFI ))+"-"+FGX_UFSNF(( cQAlAux )->( VQ2_SERNFI )) + " / "
						( cQAlAux )->( DbSkip() )
					EndDo
					( cQAlAux )->( DbCloseArea() )
					If !Empty(cNroNFs)
						cNroNFs := left(cNroNFs,len(cNroNFs)-3)
					EndIf
				EndIf
			Else
				If !Empty(cCodCli+cLojCli)
					( cQAlSQL )->( DbSkip() )
					Loop
				EndIf
			EndIf
			If !Empty(cNFGera) // Verificar se esta concluido ( NF Gerada )
				If ( cNFGera <> "0" .and. !Empty(cNroNFs) ) .or. ( cNFGera == "0" .and. Empty(cNroNFs) )
					( cQAlSQL )->( DbSkip() )
					Loop
				EndIf
			EndIf
			If !Empty(Alltrim(cNumNFI)+Alltrim(cSerNFI)) // Filtrou a NF/Serie
				If !( Alltrim(cNumNFI)+"-"+Alltrim(cSerNFI) $ cNroNFs )
					( cQAlSQL )->( DbSkip() )
					Loop
				EndIf
			EndIf
			DbSelectArea("VQ0")
			DbGoto(( cQAlSQL )->( RECVQ0 )) // Foi necessario posicionar no VQ0 devido ao campo MEMO
			//
			aAdd(aPedid,{	VQ0->VQ0_NUMPED ,;
							dtos(VQ0->VQ0_DATPED) ,;
							VQ0->VQ0_CHASSI ,;
							VQ0->VQ0_CODMAR ,;
							VQ0->VQ0_MODVEI ,;
							VQ0->VQ0_CORVEI ,;
							VQ0->VQ0_FATDIR ,;
							VQ0->VQ0_VALCUS ,;
							VQ0->VQ0_VALINI ,;
							VQ0->VQ0_DESNEG ,;
							dtos(VQ0->VQ0_DATVEN) ,;
							dtos(VQ0->VQ0_DATENT) ,;
							cFAte ,;
							cNAte ,;
							dtos(VQ0->VQ0_DATFDD) ,;
							VQ0->VQ0_CONFIG ,;
							( cQAlSQL )->( RECVQ0 ) ,;
							cNroNFs ,;
							VQ0->VQ0_FILPED ,;
							cCliNom ,;
							VQ0->VQ0_OBSMEM ,;
							IIf(( cQAlSQL )->( VV1_SITVEI )=="0",( cQAlSQL )->( VV1_FILENT ),"") ,;
							IIf(lVQ0_BASCFD,VQ0->VQ0_BASCFD,0) ,;
							dtos(VQ0->VQ0_DATPRE) ,;
							cIAte ,;
							VQ0->VQ0_CHAINT ,;
							IIf(lVQ0_FLUXO.and.!Empty(VQ0->VQ0_FLUXO),VQ0->VQ0_FLUXO,"N") ,;
							IIf(lVQ0_FLUXO ,dtos(VQ0->VQ0_DATFLU),"") ,;
							IIf(lVQ0_DATORS,dtos(VQ0->VQ0_DATORS),"") ,;
							IIf(lVQ0_FILREL,VQ0->VQ0_FILREL,"") ,;
							IIf(lVQ0_EVENTO,VQ0->VQ0_EVENTO,"") ,;
							IIf(lVQ0_STATUS,VQ0->VQ0_STATUS," ") ,;
							IIf(lVQ0_SEGMOD,VQ0->VQ0_SEGMOD," ") })
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		//
	EndIf
	//
	DbSelectArea("VQ0")
	//
	If len(aPedid) <= 0
		FS_ADD_PED("aPedid")
	EndIf
	//
	If lRefresh
		oLbPedid:nAt := 1
		oLbPedid:SetArray(aPedid)
		oLbPedid:Refresh()
	EndIf
	//
Else
	//
	If nTp == 1 // Levanta VQ1
		//
		aBonus  := {}
		nVlrIni := 0
		//
		If aPedid[oLbPedid:nAt,17] > 0

			DbSelectArea("VQ0")
			DbGoTo(aPedid[oLbPedid:nAt,17])
			
			If !Empty(aPedid[oLbPedid:nAt,25])
				cIteTra := aPedid[oLbPedid:nAt,25]
			Else
				cQuery := "SELECT VVA.VVA_ITETRA FROM "+RetSqlName("VVA")+" "
				cQuery += "VVA WHERE VVA.VVA_FILIAL='"+aPedid[oLbPedid:nAt,13]+"' AND "
				cQuery += "VVA.VVA_NUMTRA='"+aPedid[oLbPedid:nAt,14]+"' "
				cQuery += "AND VVA.VVA_CHASSI='"+Alltrim(aPedid[oLbPedid:nAt,3])+"' AND VVA.D_E_L_E_T_=' '""
				cIteTra := FM_SQL(cQuery)
			EndIf
			
			cQuery := "SELECT VQ1_STATUS , VQ1_CODBON , VQ1_VLRINI , VQ1_DESCON , VQ1_DESTRI , "
			cQuery += "VQ1_DESCDC , VQ1_DESTAT , VQ1_VLRBAS , VQ1_PERVLR , VQ1_VLRTOT , "
			cQuery += "VQ1_NUMNFI , VQ1_SERNFI , VQ1_PERIMP , VQ1_VLRLIQ , R_E_C_N_O_ RECVQ1 "
			cQuery += "FROM "+cNamVQ1+" "
			cQuery += "WHERE VQ1_FILIAL='"+cFilVQ1+"' AND VQ1_CODIGO='"+VQ0->VQ0_CODIGO+"' AND D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
			If !( cQAlSQL )->( Eof() )
				While !( cQAlSQL )->( Eof() )
					cTitPag := ""
					If !Empty(( cQAlSQL )->( VQ1_NUMNFI )) .and. ( cQAlSQL )->( VQ1_STATUS ) <> "4"
						cQuery := "SELECT SUM(SE1.E1_SALDO) FROM "+cNamSF2+" SF2 "
						cQuery += "JOIN	"+cNamSE1+" SE1 ON ( SE1.E1_FILIAL='"+cFilSE1+"' AND SE1.E1_PREFIXO=SF2.F2_PREFIXO AND SE1.E1_NUM=SF2.F2_DOC AND SE1.D_E_L_E_T_=' ' ) "
						cQuery += "WHERE SF2.F2_FILIAL='"+cFilSF2+"' AND SF2.F2_DOC='"+( cQAlSQL )->( VQ1_NUMNFI )+"' AND SF2.F2_SERIE='"+( cQAlSQL )->( VQ1_SERNFI )+"' AND SF2.D_E_L_E_T_=' '"
						nSE1Sal := FM_SQL(cQuery)
						If nSE1Sal == 0
							cTitPag := STR0047 // Total
						Else
							cQuery := "SELECT SUM(SE1.E1_VALOR) FROM "+cNamSF2+" SF2 "
							cQuery += "JOIN	"+cNamSE1+" SE1 ON ( SE1.E1_FILIAL='"+cFilSE1+"' AND SE1.E1_PREFIXO=SF2.F2_PREFIXO AND SE1.E1_NUM=SF2.F2_DOC AND SE1.D_E_L_E_T_=' ' ) "
							cQuery += "WHERE SF2.F2_FILIAL='"+cFilSF2+"' AND SF2.F2_DOC='"+( cQAlSQL )->( VQ1_NUMNFI )+"' AND SF2.F2_SERIE='"+( cQAlSQL )->( VQ1_SERNFI )+"' AND SF2.D_E_L_E_T_=' '"
							nSE1Tot := FM_SQL(cQuery)
							If nSE1Sal <> nSE1Tot
								cTitPag := STR0048 // Parcial
							EndIf
						EndIf
					EndIf
					if VQ0->VQ0_VALINI > 0
						nValIni := VQ0->VQ0_VALINI
					Else
						nValIni := ( cQAlSQL )->( VQ1_VLRINI )
					Endif
					//
					lSelAten := VM190EVZS(lVZS_FILATE,lVZS_ITETRA,( cQAlSQL )->( VQ1_CODBON ),cIteTra) // Verifica se existe registro no VZS - Bonus esta selecionado no Atendimento
					//
					aRetVZQ := VM190RVZQ(cNamVZQ,cFilVZQ,( cQAlSQL )->( VQ1_CODBON ))
					//
					aAdd(aBonus,{ 	"oS"+( cQAlSQL )->( VQ1_STATUS ) ,;
									( cQAlSQL )->( VQ1_CODBON ) ,;
									nValIni ,;
									( cQAlSQL )->( VQ1_DESCON ) ,;
									( cQAlSQL )->( VQ1_DESTRI ) ,;
									( cQAlSQL )->( VQ1_DESCDC ) ,;
									( cQAlSQL )->( VQ1_DESTAT ) ,;
									( cQAlSQL )->( VQ1_VLRBAS ) ,;
									( cQAlSQL )->( VQ1_PERVLR ) ,;
									( cQAlSQL )->( VQ1_VLRTOT ) ,;
									( cQAlSQL )->( VQ1_NUMNFI ) ,;
									( cQAlSQL )->( VQ1_SERNFI ) ,;
									cTitPag ,;
									( cQAlSQL )->( RECVQ1 ) ,;
									.f. ,;
									( cQAlSQL )->( VQ1_PERIMP ) ,;
									( cQAlSQL )->( VQ1_VLRLIQ ) ,;
									aRetVZQ[1],;
									lSelAten ,;
									aRetVZQ[2] })
					nVlrIni := ( cQAlSQL )->( VQ1_VLRINI )
					( cQAlSQL )->( DbSkip() )
				EndDo
			Else
				nVlrIni := FS_VLRVEI(oLbPedid:nAt)
			EndIf
			( cQAlSQL )->( DbCloseArea() )
			DbSelectArea("VQ1")
		EndIf
		//
		lBotAtu := FS_ATUATE(0,oLbPedid:nAt,nMaxDias)
		oBotAtu:Refresh()
		oBotAtu:SetFocus()
		oLbPedid:SetFocus()
		//
		//
	ElseIf nTp == 2 // Levanta Bonus do Veiculo em questao
		//
		DbSelectArea("VQ0")
		DbGoto(aPedid[oLbPedid:nAt,17])
		
		If !Empty(aPedid[oLbPedid:nAt,25])
			cIteTra := aPedid[oLbPedid:nAt,25]
		Else
			cQuery := "SELECT VVA.VVA_ITETRA FROM "+RetSqlName("VVA")+" "
			cQuery += "VVA WHERE VVA.VVA_FILIAL='"+aPedid[oLbPedid:nAt,13]+"' AND "
			cQuery += "VVA.VVA_NUMTRA='"+aPedid[oLbPedid:nAt,14]+"' "
			cQuery += "AND VVA.VVA_CHAINT='"+aPedid[oLbPedid:nAt,26]+"' AND VVA.D_E_L_E_T_=' '""
			cIteTra := FM_SQL(cQuery)
		EndIf

		For ni := 1 to len(aBonus) // Verificar se ja existe NF para o Bonus.
			If aBonus[ni,14] > 0 
				iF !Empty(aBonus[ni,11]) .and. ( aBonus[ni,1] == "oS3" )
					lNF := .t.
				Endif
				lOk := .f.
				nOpcAviso := Aviso(STR0050,; // "AtenÁ„o"
				STR0138 + CHR(13)+CHR(10) + CHR(13)+CHR(10) + ; // "J· existem BÙnus cadastrados para este Pedido! AÁıes PossÌveis:"
				"  ["+STR0134+"]   - " + STR0136 + CHR(13)+CHR(10) + CHR(13)+CHR(10)+;  // "Apagar" / "Levantar os BÙnus e apagar os j· existentes que ainda n„o Geraram NF ou que n„o foram Cancelados."
				"["+STR0135+"] - " + STR0137,; // "Apagar" / "Levantar os BÙnus e n„o apagar os j· existentes."
				{STR0134,; // "Apagar"
				STR0135,; // "N„o Apagar"
				 STR0041},2) // "Cancelar"
				If nOpcAviso == 1 // Levantar BÙnus e APAGAR os BÙnus existentes
					lOk  := .t.
					lDel := .t.
				ElseIf nOpcAviso == 2 // Levantar BÙnus e N¬O APAGAR os BÙnus existentes
					lOk  := .t.
					lDel := .f.
				Else // Cancelar a operaÁ„o
					Return
				Endif
				Exit
			EndIf
		Next
		If lOk
			If lDel // Deletar todos os bonus ja gravados, serao levantados os bonus novamente
				DbSelectArea("VQ1")
				For ni := 1 to len(aBonus) // Apaga bonus que nao gerou NF e nem foi cancelado
					If aBonus[ni,14] > 0 .and. aBonus[ni,1] <> "oS3" .and. aBonus[ni,1] <> "oS4"
						DbGoTo(aBonus[ni,14])
						RecLock("VQ1",.F.,.T.)
						dbDelete()
						MsUnLock()

						VEM1900098_VerificaPEVQ1(2)

					EndIf
				Next
				nVlrIni := FS_VLRVEI(oLbPedid:nAt)
				//
				aBonAux := aClone(aBonus)
				aBonus  := {}
				//
				For ni := 1 to len(aBonAux)
					If aBonAux[ni,14] > 0 .and. ( aBonAux[ni,1] == "oS3" .or. aBonAux[ni,1] == "oS4" )
						aAdd(aBonus,aClone(aBonAux[ni])) // Bonus com NF gerada ou Bonus Cancelado devem permanecer no ListBox
					EndIf
				Next
				//
			Endif
			//
			VV1->(DbSetOrder(1))
			VV1->(DbSeek(xFilial("VV1")+VQ0->VQ0_CHAINT))
			VV2->(DbSetOrder(1))
			VV2->(DbSeek(xFilial("VV2")+VQ0->VQ0_CODMAR+VQ0->VQ0_MODVEI+IIf(lVQ0_SEGMOD,VQ0->VQ0_SEGMOD,"")))
			//
			aBonVei := FS_VM190BON()
			//
			If len(aBonus) > 0 // Tem NF's geradas
				For ni := 1 to len(aBonVei) // Retirar linha que ja existe NF gerada
					If ascan(aBonus,{|x| x[2] == aBonVei[ni,1] }) > 0
						aAdd(aBonDel,ni)
					EndIf
				Next
				If aBonus[1,14] == 0 .and. aBonus[1,1] == "oNada" // Nao existe o Bonus gravado na base
					aBonus := {} // Limpar Vetor
				EndIf
			Endif
			aSort(aBonDel,,,{|x,y| x > y}) // Ordenacao em ordem decrescente dos registro deletados do vetor
			For ni := 1 to len(aBonDel) // Deleta Bonus
				aDel(aBonVei,aBonDel[ni])
				aSize(aBonVei,Len(aBonVei)-1)
			Next
			//
			If len(aBonVei) > 0
				//
				If VQ0->VQ0_VALINI > 0
					nVlrIni := VQ0->VQ0_VALINI
				EndIf
				//
				nVlrDef := nVlrIni // Valor Defult da variavel nVlrIni
				//
				For ni := 1 to len(aBonVei)
					//
					nVlrIni := nVlrDef // Volta conteudo padrao da variavel nVlrIni
					//
					If aExiste:ExistTable(RetSqlName("VR3"))
					
						cQuery := "SELECT * FROM "+RetSqlName("VR3")+" VR3 "
						cQuery += "WHERE VR3.VR3_FILIAL = '"+xFilial("VR3")+"' AND VR3.VR3_CODMAR = '"+VQ0->VQ0_CODMAR+"' AND "
						cQuery += "VR3.VR3_MODVEI = '"+VQ0->VQ0_MODVEI+"' AND VR3.D_E_L_E_T_ = ' '"
						TcQuery cQuery New Alias "TMPVR3"
						If !TMPVR3->(Eof())
							nPerDCc := TMPVR3->(VR3_DESCON)
							nPerDCd := TMPVR3->(VR3_DESCDC)
							nPerDTr := TMPVR3->(VR3_DESTRI)
							nPerDTa := TMPVR3->(VR3_DESTAT)
							nPerImp := TMPVR3->(VR3_PERIMP)
							nPerBon := TMPVR3->(VR3_PERBON)
						Else
							nPerDCc := nPDcCon
							nPerDCd := nPDcCdc
							nPerDTr := nPDcTri
							nPerDTa := nPDcTat
							nPerImp := nPImpos
							nPerBon := nPBonus
						EndIf
						TMPVR3->(DbCloseArea())
					Else
						nPerDCc := nPDcCon
						nPerDCd := nPDcCdc
						nPerDTr := nPDcTri
						nPerDTa := nPDcTat
						nPerImp := nPImpos
						nPerBon := nPBonus
					EndIf

					nVlrBas := nVlrIni
					// Ponto de entrada para alteraÁ„o do Valor Base
					If lPEVM190BAS
						nVlrBas := ExecBlock("VM190BAS",.f.,.f.,{nVlrBas})
					EndIf
					nVlrBas := ( nVlrBas - ( ( nPerDCc * nVlrBas ) / 100 ) )
					nVlrBas := ( nVlrBas - ( ( nPerDCd * nVlrBas ) / 100 ) )
					//
					If aBonVei[ni,3] > 0 // Valor Fixo do Bonus
						nVlrBon := aBonVei[ni,3]
						nVlrLiq := aBonVei[ni,3]
						nVlrIni := aBonVei[ni,3]
						nPerBon := 100
						nPerDCc := 0
						nPerDCd := 0
						nPerDTr := 0
						nPerDTa := 0
						nPerImp := 0
					Else // Calcular o Valor do Bonus pelo Percentual
						If aBonVei[ni,2] > 0
							nPerBon := aBonVei[ni,2]
						EndIf
						nVlrBon := round(( ( nVlrBas * nPerBon ) / 100 ),2)
						nVlrLiq := round( nVlrBon - ( ( nVlrBon * nPerImp ) / 100 ),2)
					EndIf
					//					
					lSelAten := VM190EVZS(lVZS_FILATE,lVZS_ITETRA,aBonVei[ni,1],cIteTra) // Verifica se existe registro no VZS - Bonus esta selecionado no Atendimento
					//
					aRetVZQ := VM190RVZQ(cNamVZQ,cFilVZQ,aBonVei[ni,1])
					//
					aAdd(aBonus,{ 	"oS1" ,;
									aBonVei[ni,1] ,;
									nVlrIni ,;
									nPerDCc ,;
									nPerDTr ,;
									nPerDCd ,;
									nPerDTa ,;
									nVlrBas ,;
									nPerBon ,;
									nVlrBon ,;
									"" ,;
									"" ,;
									"" ,;
									0 ,;
									.f. ,;
									nPerImp ,;
									nVlrLiq ,;
									aRetVZQ[1] ,;
									lSelAten ,;
									aRetVZQ[2] })
					//
					cProxSeq := FM_SQL("SELECT MAX(VQ1_SEQUEN) FROM "+cNamVQ1+" WHERE VQ1_FILIAL='"+cFilVQ1+"' AND VQ1_CODIGO='"+VQ0->VQ0_CODIGO+"'")
					If Empty(cProxSeq)
						cProxSeq := "000"
					EndIf
					cProxSeq := Soma1(cProxSeq)
					//
					DbSelectArea("VQ1")
					RecLock("VQ1",.t.)
					VQ1->VQ1_FILIAL := cFilVQ1
					VQ1->VQ1_CODIGO := VQ0->VQ0_CODIGO
					VQ1->VQ1_SEQUEN := cProxSeq
					VQ1->VQ1_STATUS := "1"
					VQ1->VQ1_CODBON := aBonVei[ni,1]
					VQ1->VQ1_VLRINI := nVlrIni
					VQ1->VQ1_DESCON := nPerDCc
					VQ1->VQ1_DESTRI := nPerDTr
					VQ1->VQ1_DESCDC := nPerDCd
					VQ1->VQ1_DESTAT := nPerDTa
					VQ1->VQ1_VLRBAS := nVlrBas
					VQ1->VQ1_PERVLR := nPerBon
					VQ1->VQ1_VLRTOT := nVlrBon
					VQ1->VQ1_PERIMP := nPerImp
					VQ1->VQ1_VLRLIQ := nVlrLiq
					If lVQ1_EVENTO
						VQ1->VQ1_EVENTO := aRetVZQ[3]
					EndIf
					MsUnLock()
					aBonus[len(aBonus),14] := VQ1->(RecNo())

					VEM1900098_VerificaPEVQ1(3)

				Next
			EndIf
		EndIf
		//
	EndIf
	//
	If len(aBonus) <= 0
		FS_ADD_BON("aBonus","oNada")
	EndIf
	//
	If lRefresh
		oLbBonus:nAt := 1
		oLbBonus:SetArray(aBonus)
		oLbBonus:Refresh()
	EndIf
	//
EndIf
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥FS_DBLCLICK≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 06/08/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Duplo Clik no ListBox ( seleciona e altera valores )        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_DBLCLICK(nLinVet,nColVet)
If aBonus[nLinVet,14] > 0
	If right(aBonus[nLinVet,1],1) $ "12" // Alterar Valores
		If nColVet <= 1 // Tik
			aBonus[nLinVet,15] := !aBonus[nLinVet,15]
		ElseIf right(aBonus[nLinVet,1],1) == "1" // Gravado
			FS_VQ1(4,nLinVet,STR0022) // Alterar
		EndIf
	ElseIf !Empty(aBonus[nLinVet,11])
		DbSelectArea("SF2")
		DbSetOrder(1)
		If DbSeek(xFilial("SF2")+aBonus[nLinVet,11]+aBonus[nLinVet,12])
			cAlias := "SF2"
			nReg   := SF2->(Recno())
			nOpc   := 2
			Mc090Visual(cAlias,nReg,nOpc)
		EndIf
		DbSelectArea("VQ0")
	EndIf
EndIf
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ FS_VQ0   ≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 15/08/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Manutencao no Pedido VQ0                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_VQ0(nOpcVQ0,nLinVQ0,cTitVQ0)
Local oIHelp       := DMS_InterfaceHelper():New()
Local aObjects     := {}
//
Local cGruVei      := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local aArquivos    := {}
Local lOkParam     := .f.
Local ni           := 0
Local aCposObr     := {}
Local lAlt         := .t.
Local lExc         := .t.
Local lCpoObr      := .f.
Local lIncAlt      := .f.
Local lChassi      := .t.
Local lVQ0_BASCFD  := ( VQ0->(ColumnPos("VQ0_BASCFD")) > 0 )
Local lVQ0_FLUXO   := ( VQ0->(ColumnPos("VQ0_FLUXO"))  > 0 )
Local lVQ0_DATORS  := ( VQ0->(ColumnPos("VQ0_DATORS")) > 0 )
Local lVQ0_FILREL  := ( VQ0->(ColumnPos("VQ0_FILREL")) > 0 ) // Filial Entrada Relacionada - controle interno para possibilitar desfazer o relacionamento do Chassi
Local lVQ0_EVENTO  := ( VQ0->(ColumnPos("VQ0_EVENTO")) > 0 )
Local lVQ0_STATUS  := ( VQ0->(ColumnPos("VQ0_STATUS")) > 0 )
Local lVQ0_SEGMOD  := ( VQ0->(ColumnPos("VQ0_SEGMOD")) > 0 )
Local aX3Dados     := {}
Local lX3When      := .t.
Local lPodeExcluir := .t.
Local nCntFor      := 0
Local nRecVQ0      := 0
Local nPosVet      := 0
Local aHeadVet     := {}
Local aCposRep     := {}
Local aVetor       := {}
Private aAux       := {}
Private cFilCodMar := "   "
Private oArHelper  := Dms_ArrayHelper():New()
Private oSqlHelper := Dms_SqlHelper():New()
Private cFiltroVX5 := "051" // Filtro tabela VX5 - 051 - Eventos

_VV2CODMAR_Filtro = ""  // Codigo da Marca
_VV2GRUMOD_Filtro = ""  // Grupo do Modelo
_VV2MODVEI_Filtro = ""  // Modelo de VeÌculo

FS_ADD_PED("aAux")

Inclui := .f.
Altera := .f.
Exclui := .f.

If nOpcVQ0 == 3 // Incluir
	aAux[1,19] := xFilial("VV9")
	aAux[1,22] := space(TamSX3("VV1_FILENT")[1])
	If !Empty(aPedid[nLinVQ0,2]) .and. ExistBlock("VM190REP") // Se existir o PE, retorna os campos a serem replicados no "Incluir Replicando" do VQ0
		nOpcAviso := Aviso(STR0142,;
					STR0143+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0144,;
					{STR0145,STR0146,STR0041},2) // Novo / Replicando / Cancelar
		If nOpcAviso == 1 // Novo
			// Ok - Inclusao normal (padr„o)
		ElseIf nOpcAviso == 2 // Incluir com campos pre digitados
			// Layout do vetor aPedid/aAux
			aHeadVet := { 	"VQ0_NUMPED" ,; // 01
							"VQ0_DATPED" ,; // 02
							"x" ,; // 03
							"VQ0_CODMAR" ,; // 04
							"VQ0_MODVEI" ,; // 05
							"VQ0_CORVEI" ,; // 06
							"VQ0_FATDIR" ,; // 07
							"VQ0_VALCUS" ,; // 08
							"VQ0_VALINI" ,; // 09
							"VQ0_DESNEG" ,; // 10
							"VQ0_DATVEN" ,; // 11
							"VQ0_DATENT" ,; // 12
							"x" ,; // 13
							"x" ,; // 14
							"VQ0_DATFDD" ,; // 15
							"VQ0_CONFIG" ,; // 16
							"x" ,; // 17
							"x" ,; // 18
							"VQ0_FILPED" ,; // 19
							"x" ,; // 20
							"x" ,; // 21
							"VV1_FILENT" ,; // 22
							"VQ0_BASCFD" ,; // 23
							"VQ0_DATPRE" ,; // 24
							"x" ,; // 25
							"x" ,; // 26
							"VQ0_FLUXO"  ,; // 27
							"VQ0_DATFLU" ,; // 28
							"VQ0_DATORS" ,; // 29
							"VQ0_FILREL" ,; // 30
							"VQ0_EVENTO" ,; // 31
							"x" ,; // 32
							"VQ0_SEGMOD" } // 33
			//
			DbSelectArea("VQ0")
			DbGoto(aPedid[nLinVQ0,17]) // necess·rio posionar no Pedido posiconado na grid para replicar campos customizados
			//
			aCposRep := ExecBlock("VM190REP",.f.,.f.)
			For nCntFor := 1 to len(aCposRep)
				nPosVet := aScan(aHeadVet,aCposRep[nCntFor])
				If nPosVet > 0
					aAux[1,nPosVet] := aPedid[nLinVQ0,nPosVet] // insere os dados replicados para aparecer na tela
				EndIf
			Next
			//
		Else // Cancelar a operaÁ„o
			Return .f.
		Endif
	Endif
	Inclui := .t.
	nLinVQ0 := 0
ElseIf nOpcVQ0 == 4 .or. nOpcVQ0 == 5
	DbSelectArea("VQ0")
	If Empty(aPedid[nLinVQ0,1]) // Caso esteja vazio o listbox
		Return .f.
	EndIf
	DbGoto(aPedid[nLinVQ0,17])
	If !Empty(VQ0->VQ0_CHASSI)
		lChassi := .f.
	EndIf
	If nOpcVQ0 == 5
		aVetor := FGX_VEIMOVS( VV1->VV1_CHASSI , "E" , "0" )
		If Len(aVetor)> 0			
			MsgStop(STR0148,STR0050)//"Veiculo ja possui movimentaÁ„o de Entrada. Impossivel continuar. / Atencao")
			Return .f.			
		Else
			Exclui := .t.
		EndIf	

		For ni := 1 to len(aBonus)
			If !Empty(aBonus[ni,11]) .and. ( aBonus[ni,1] == "oS3" )
				lExc := .f.
				Exit
			EndIf
		Next
		If !lExc
			MsgStop(STR0052,STR0050) // NF referente ao bonus ja esta gerada. Sera necessario cancelar a NF antes! / Atencao
			Return .f.
		EndIf
	Else
		Altera := .t.
	EndIf
	For ni := 1 to len(aAux[1])
		aAux[1,ni] := aPedid[nLinVQ0,ni]
	Next
	cFilCodMar := aAux[1,04]
	
	_VV2CODMAR_Filtro = aAux[1,04]  // Codigo da Marca
	_VV2MODVEI_Filtro = aAux[1,05]  // Modelo de VeÌculo

	For ni := 1 to len(aBonus)
		If !Empty(aBonus[ni,11])
			lAlt := .f.
			Exit
		EndIf
	Next
	DbSelectArea("VV1")
	DbSetOrder(1)
	If DbSeek(xFilial("VV1")+VQ0->VQ0_CHAINT)
		aAux[1,22] := VV1->VV1_FILENT
	EndIf
EndIf

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { "QUADRO_1" , 100 , 100 , .T. , .T. } ) // 100%
//
oSizePri := oIHelp:CreateDefSize(.t., aObjects )
oSizePri:Process()
//
oIHelp:SetDefSize(oSizePri)
oVEIMV190VQ0 := oIHelp:CreateDialog(STR0001+" - "+cTitVQ0)
oIHelp:SetDialog(oVEIMV190VQ0) // ACTIVATE
oIHelp:SetOwnerPvt("VEIVM190")
oIHelp:nOpc := 4
oVEIMV190VQ0:lEscClose := .F.
//
oIHelp:Clean()
oIHelp:SetDefSize(oSizePri, "QUADRO_1")
oPainel_1 := oIHelp:CreateMGroup({{"TEXTO",""}})
oIHelp:setDialog(oPainel_1)
//
// Adicionando os campos que ser„o verificados
// Nome, posiÁ„o do array aAux (relaÁ„o), usado, when
aAdd(aX3Dados, { "VQ0_DATPED", 02, .T., .T. })
If lVQ0_STATUS
	aAdd(aX3Dados, { "VQ0_STATUS", 32, .T., .T. })
EndIf
aAdd(aX3Dados, { "VQ0_CODMAR", 04, .T., .T. })
aAdd(aX3Dados, { "VQ0_MODVEI", 05, .T., .T. })
If lVQ0_SEGMOD
	aAdd(aX3Dados, { "VQ0_SEGMOD", 33, .T., .T. })
EndIf
aAdd(aX3Dados, { "VQ0_CORVEI", 06, .T., .T. })
aAdd(aX3Dados, { "VQ0_FATDIR", 07, .T., .T. })
aAdd(aX3Dados, { "VQ0_FILPED", 19, .T., .T. })
aAdd(aX3Dados, { "VV1_FILENT", 22, .T., .T. })
If lVQ0_EVENTO
	aAdd(aX3Dados, { "VQ0_EVENTO", 31, .T., .T. })
EndIf
aAdd(aX3Dados, { "VQ0_VALCUS", 08, .T., .T. })
aAdd(aX3Dados, { "VQ0_VALINI", 09, .T., .T. })
aAdd(aX3Dados, { "VQ0_DESNEG", 10, .T., .T. })
aAdd(aX3Dados, { "VQ0_DATVEN", 11, .T., .T. })
aAdd(aX3Dados, { "VQ0_DATENT", 12, .T., .T. })
aAdd(aX3Dados, { "VQ0_DATFDD", 15, .T., .T. })
If lVQ0_DATORS
	aAdd(aX3Dados, { "VQ0_DATORS", 29, .T., .T. })
EndIf
aAdd(aX3Dados, { "VQ0_CONFIG", 16, .T., .T. })
If lVQ0_BASCFD
	aAdd(aX3Dados, { "VQ0_BASCFD", 23, .T., .T. })
EndIf
aAdd(aX3Dados, { "VQ0_DATPRE", 24, .T., .T. })
If lVQ0_FLUXO
	aAdd(aX3Dados, { "VQ0_FLUXO", 27, .T., .T. })
	aAdd(aX3Dados, { "VQ0_DATFLU", 28, .T., .T. })
EndIf
aAdd(aX3Dados, { "VQ0_OBSMEM", 21, .T., .T. })

// Retorna Dados do SX3 da tabela VQ0
VEM1900016_PreencheSX3VQ0(aX3Dados, aAux, nOpcVQ0)

// Vari·vel ir· controlar a sequÍncia idÍntico ao array aX3Dados
ni := 1

lIncAlt := IIf(nOpcVQ0 <> 2 .and. nOpcVQ0 <> 5, .t., .f.) // Inclusao ou Alteracao

// VQ0_NUMPED
lCpoObr := lIncAlt
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "C"                                           },;
	{'X3_TAMANHO' , TamSX3("VQ0_NUMPED")[1]                       },;
	{'X3_CAMPO'   , 'MV_PAR01'                                    },;
	{'X3_TITULO'  , RetTitle("VQ0_NUMPED")                        },; // Nro Pedido
	{'X3_PICTURE' , "@!"                                          },;
	{'X3_RELACAO' , aAux[1,01]                                    },;
	{'X3_OBRIGAT' , lCpoObr                                       },;
	{'X3_WHEN'    , IIf(nOpcVQ0 <> 3 .or. !lAlt, ".F.", ".T.")    } ;
})
If lCpoObr
	aAdd(aCposObr,{"M->MV_PAR01",RetTitle("VQ0_NUMPED")})
EndIf

// VQ0_DATPED
lCpoObr := lIncAlt
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "D"                                                                                },;
	{'X3_TAMANHO' , 8                                                                                  },;
	{'X3_CAMPO'   , 'MV_PAR02'                                                                         },;
	{'X3_TITULO'  , RetTitle("VQ0_DATPED")                                                             },; // Data Pedido
	{'X3_PICTURE' , "@D"                                                                               },;
	{'X3_RELACAO' , stod(aAux[1,02])                                                                   },;
	{'X3_OBRIGAT' , lCpoObr                                                                            },;
	{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .or. !lAlt .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
})
If lCpoObr
	aAdd(aCposObr,{"M->MV_PAR02",RetTitle("VQ0_DATPED")})
EndIf
ni++

// VQ0_STATUS
If lVQ0_STATUS
	M->MV_PAR32 := aAux[1,32]
	If aX3Dados[ni,3] // Campo usado
		SX3->(DbSetOrder(2))
		SX3->(DbSeek("VQ0_STATUS"))
		lCpoObr := ( lIncAlt .and. x3obrigat("VQ0_STATUS") )
		oIHelp:AddMGetTipo({;
			{'X3_TIPO'    , "C"                                                                     },;
			{'X3_TAMANHO' , 1                                                                       },;
			{'X3_CAMPO'   , 'MV_PAR32'                                                              },;
			{'X3_TITULO'  , RetTitle("VQ0_STATUS")                                                  },; // Status Pedid
			{'X3_PICTURE' , "@!"                                                                    },;
			{'X3_RELACAO' , aAux[1,32]                                                              },;
			{'X3_CBOX'    , SX3->X3_CBOX                                                            },;
			{'X3_OBRIGAT' , lCpoObr                                                                 },;
			{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
		})
		If lCpoObr
			aAdd(aCposObr,{"M->MV_PAR32",RetTitle("VQ0_STATUS")})
		EndIf
	EndIf
	ni++
EndIf

// VQ0_CHASSI
lCpoObr := x3obrigat("VQ0_CHASSI")
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "C"                                                                          },;
	{'X3_TAMANHO' , TamSX3("VQ0_CHASSI")[1]                                                      },;
	{'X3_CAMPO'   , 'MV_PAR03'                                                                   },;
	{'X3_TITULO'  , RetTitle("VQ0_CHASSI")                                                       },; // Chassi
	{'X3_VALID'   , "Empty(M->MV_PAR03) .or. VM190CHASSI(" + strzero(nOpcVQ0,1) + ",M->MV_PAR03)"},;
	{'X3_PICTURE' , "@!"                                                                         },;
	{'X3_RELACAO' , aAux[1,03]                                                                   },;
	{'X3_OBRIGAT' , lCpoObr                                                                      },;
	{'X3_WHEN'    , IIf(!lChassi .or. nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .or. !lAlt, ".F.", ".T.")   } ;
})
If lCpoObr
	aAdd(aCposObr,{"M->MV_PAR03",RetTitle("VQ0_CHASSI")})
EndIf

// VQ0_CODMAR
lCpoObr := lIncAlt
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "C"                                                                                             },;
	{'X3_TAMANHO' , TamSX3("VQ0_CODMAR")[1]                                                                         },;
	{'X3_CAMPO'   , 'MV_PAR04'                                                                                      },;
	{'X3_TITULO'  , RetTitle("VQ0_CODMAR")                                                                          },; // Marca
	{'X3_VALID'   , "VEM1900089_ValidaCodMar()" 									             				    },;
	{'X3_F3'      , "VE1"                                                                                           },;
	{'X3_PICTURE' , "@!"                                                                                            },;
	{'X3_RELACAO' , aAux[1,04]                                                                                      },;
	{'X3_OBRIGAT' , lCpoObr                                                                                         },;
	{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .or. !lAlt .Or. !(aX3Dados[ni,4]), ".F.", ".T.")             } ;
})
If lCpoObr
	aAdd(aCposObr,{"M->MV_PAR04",RetTitle("VQ0_CODMAR")})
EndIf
ni++

// VQ0_MODVEI
lCpoObr := lIncAlt
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "C"                                                                                },;
	{'X3_TAMANHO' , TamSX3("VQ0_MODVEI")[1]                                                            },;
	{'X3_CAMPO'   , 'MV_PAR05'                                                                         },;
	{'X3_TITULO'  , RetTitle("VQ0_MODVEI")                                                             },; // Modelo
	{'X3_VALID'   , "VEM1900079_ValidaModVei()"							                			   },;
	{'X3_F3'      , "VV2SE3"                                                                           },;
	{'X3_PICTURE' , "@!"                                                                               },;
	{'X3_RELACAO' , aAux[1,05]                                                                         },;
	{'X3_OBRIGAT' , lCpoObr                                                                            },;
	{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .or. !lAlt .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
})
If lCpoObr
	aAdd(aCposObr,{"M->MV_PAR05",RetTitle("VQ0_MODVEI")})
EndIf
ni++

IF lVQ0_SEGMOD
	// VQ0_SEGMOD
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , "C"                                                                                },;
		{'X3_TAMANHO' , TamSX3("VQ0_SEGMOD")[1]                                                            },;
		{'X3_CAMPO'   , 'MV_PAR33'                                                                         },;
		{'X3_TITULO'  , RetTitle("VQ0_SEGMOD")                                                             },; // Segmento do Modelo
		{'X3_VALID'   , "VEM1900069_ValidaSegMod()"                   									   },;
		{'X3_F3'      , "VV2SE4"                                                                           },;
		{'X3_PICTURE' , "@!"                                                                               },;
		{'X3_RELACAO' , aAux[1,33]                                                                         },;
		{'X3_OBRIGAT' , .f.                                                                                },;
		{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .or. !lAlt .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
	})
	ni++
EndIf

// VQ0_CORVEI
lCpoObr := lIncAlt
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "C"                                                                                },;
	{'X3_TAMANHO' , TamSX3("VQ0_CORVEI")[1]                                                            },;
	{'X3_CAMPO'   , 'MV_PAR06'                                                                         },;
	{'X3_TITULO'  , RetTitle("VQ0_CORVEI")                                                             },; // Cor
	{'X3_VALID'   , "Empty(M->MV_PAR06) .or. FG_Seek('VVC', 'M->MV_PAR04 + M->MV_PAR06', 1)"           },;
	{'X3_F3'      , "VVC"                                                                              },;
	{'X3_PICTURE' , "@!"                                                                               },;
	{'X3_RELACAO' , aAux[1,06]                                                                         },;
	{'X3_OBRIGAT' , lCpoObr                                                                            },;
	{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .or. !lAlt .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
})
If lCpoObr
	aAdd(aCposObr,{"M->MV_PAR06",RetTitle("VQ0_CORVEI")})
EndIf
ni++

// VQ0_FATDIR
M->MV_PAR07 := aAux[1,07]
If aX3Dados[ni,3] // Campo usado
	lCpoObr := ( lIncAlt .and. x3obrigat("VQ0_FATDIR") )
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , "C"                                                                     },;
		{'X3_TAMANHO' , 1                                                                       },;
		{'X3_CAMPO'   , 'MV_PAR07'                                                              },;
		{'X3_TITULO'  , RetTitle("VQ0_FATDIR")                                                  },; // Fat.Direto
		{'X3_VALID'   , 'Pertence("01")'                                                        },;
		{'X3_PICTURE' , "@!"                                                                    },;
		{'X3_RELACAO' , aAux[1,07]                                                              },;
		{'X3_CBOX'    , "0=" + STR0084 + ";1=" + STR0085                                        },;
		{'X3_OBRIGAT' , lCpoObr                                                                 },;
		{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
	})
	If lCpoObr
		aAdd(aCposObr,{"M->MV_PAR07",RetTitle("VQ0_FATDIR")})
	EndIf	
EndIf
ni++

// VQ0_FILPED
lCpoObr := ( lIncAlt .and. x3obrigat("VQ0_FILPED") )
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "C"                                                                     },;
	{'X3_TAMANHO' , TamSX3("VQ0_FILPED")[1]                                                 },;
	{'X3_CAMPO'   , 'MV_PAR19'                                                              },;
	{'X3_TITULO'  , RetTitle("VQ0_FILPED")                                                  },; // Filial Pedid
	{'X3_F3'      , "SM0_01"                                                                },;
	{'X3_VALID'   , "VEM1900026_ValidaFilial(M->MV_PAR19)"                                  },;
	{'X3_PICTURE' , "@!"                                                                    },;
	{'X3_RELACAO' , aAux[1,19]                                                              },;
	{'X3_OBRIGAT' , lCpoObr                                                                 },;
	{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
})
If lCpoObr
	aAdd(aCposObr,{"M->MV_PAR19",RetTitle("VQ0_FILPED")})
EndIf	
ni++

// VV1_FILENT
lCpoObr := ( nOpcVQ0 == 3 .or. ( nOpcVQ0 == 4 .and. x3obrigat("VV1_FILENT") ) )
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "C"                                                    },;
	{'X3_TAMANHO' , TamSX3("VV1_FILENT")[1]                                },;
	{'X3_CAMPO'   , 'MV_PAR22'                                             },;
	{'X3_TITULO'  , RetTitle("VV1_FILENT")                                 },; // Filial Entr.
	{'X3_F3'      , "SM0_01"                                               },;
	{'X3_VALID'   , "NAOVAZIO() .And. VEM1900026_ValidaFilial(M->MV_PAR22)"},;
	{'X3_PICTURE' , "@!"                                                   },;
	{'X3_RELACAO' , aAux[1,22]                                             },;
	{'X3_OBRIGAT' , lCpoObr                                                },;
	{'X3_WHEN'    , IIf(nOpcVQ0 <> 3 .Or. !(aX3Dados[ni,4]), ".F.", ".T.") } ;
})
If lCpoObr
	aAdd(aCposObr,{"M->MV_PAR22",RetTitle("VV1_FILENT")})
EndIf
ni++

// VQ0_EVENTO
If lVQ0_EVENTO
	M->MV_PAR31 := aAux[1,31]
	If aX3Dados[ni,3] // Campo usado
		lCpoObr := ( lIncAlt .and. x3obrigat("VQ0_EVENTO") )
		oIHelp:AddMGetTipo({;
			{'X3_TIPO'    , "C"                                                                     },;
			{'X3_TAMANHO' , TamSX3("VQ0_EVENTO")[1]                                                 },;
			{'X3_CAMPO'   , 'MV_PAR31'                                                              },;
			{'X3_TITULO'  , RetTitle("VQ0_EVENTO")                                                  },; // Evento
			{'X3_VALID'   , 'vazio() .or. OFIOA560VL("051", M->MV_PAR31)'                           },;
			{'X3_F3'      , "VX5AUX"                                                                },;
			{'X3_PICTURE' , "@!"                                                                    },;
			{'X3_RELACAO' , aAux[1,31]                                                              },;
			{'X3_OBRIGAT' , lCpoObr                                                                 },;
			{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
		})
		If lCpoObr
			aAdd(aCposObr,{"M->MV_PAR31",RetTitle("VQ0_EVENTO")})
		EndIf
	EndIf
	ni++
EndIf

// VQ0_VALCUS
M->MV_PAR08 := aAux[1,08]
If aX3Dados[ni,3] // Campo usado
	lCpoObr := ( lIncAlt .and. x3obrigat("VQ0_VALCUS") )
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , "N"                                                                     },;
		{'X3_TAMANHO' , 12                                                                      },;
		{'X3_DECIMAL' , 2                                                                       },;
		{'X3_CAMPO'   , 'MV_PAR08'                                                              },;
		{'X3_TITULO'  , RetTitle("VQ0_VALCUS")                                                  },; // Vlr.Custo
		{'X3_PICTURE' , "@E 999,999,999.99"                                                     },;
		{'X3_RELACAO' , aAux[1,08]                                                              },;
		{'X3_OBRIGAT' , lCpoObr                                                                 },;
		{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
	})
	If lCpoObr
		aAdd(aCposObr,{"M->MV_PAR08",RetTitle("VQ0_VALCUS")})
	EndIf
EndIf
ni++

// VQ0_VALINI
M->MV_PAR09 := aAux[1,09]
If aX3Dados[ni,3] // Campo usado
	lCpoObr := ( lIncAlt .and. x3obrigat("VQ0_VALINI") )
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , "N"                                                                     },;
		{'X3_TAMANHO' , 12                                                                      },;
		{'X3_DECIMAL' , 2                                                                       },;
		{'X3_CAMPO'   , 'MV_PAR09'                                                              },;
		{'X3_TITULO'  , RetTitle("VQ0_VALINI")                                                  },; // Vlr.Inicial
		{'X3_PICTURE' , "@E 999,999,999.99"                                                     },;
		{'X3_RELACAO' , aAux[1,09]                                                              },;
		{'X3_OBRIGAT' , lCpoObr                                                                 },;
		{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
	})
	If lCpoObr
		aAdd(aCposObr,{"M->MV_PAR09",RetTitle("VQ0_VALINI")})
	EndIf
EndIf
ni++

// VQ0_DESNEG
M->MV_PAR10 := aAux[1,10]
If aX3Dados[ni,3] // Campo usado
	lCpoObr := ( lIncAlt .and. x3obrigat("VQ0_DESNEG") )
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , "N"                                                                     },;
		{'X3_TAMANHO' , 6                                                                       },;
		{'X3_DECIMAL' , 2                                                                       },;
		{'X3_CAMPO'   , 'MV_PAR10'                                                              },;
		{'X3_TITULO'  , RetTitle("VQ0_DESNEG")                                                  },; // % Desc.Negoc
		{'X3_PICTURE' , "@E 999.99"                                                             },;
		{'X3_RELACAO' , aAux[1,10]                                                              },;
		{'X3_OBRIGAT' , lCpoObr                                                                 },;
		{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
	})
	If lCpoObr
		aAdd(aCposObr,{"M->MV_PAR10",RetTitle("VQ0_DESNEG")})
	EndIf
EndIf
ni++

// VQ0_DATVEN
M->MV_PAR11 := stod(aAux[1,11])
If aX3Dados[ni,3] // Campo usado
	lCpoObr := ( lIncAlt .and. x3obrigat("VQ0_DATVEN") )
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , "D"                                                                     },;
		{'X3_TAMANHO' , 8                                                                       },;
		{'X3_CAMPO'   , 'MV_PAR11'                                                              },;
		{'X3_TITULO'  , RetTitle("VQ0_DATVEN")                                                  },; // Vendido em
		{'X3_PICTURE' , "@D"                                                                    },;
		{'X3_RELACAO' , stod(aAux[1,11])                                                        },;
		{'X3_OBRIGAT' , lCpoObr                                                                 },;
		{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
	})
	If lCpoObr
		aAdd(aCposObr,{"M->MV_PAR11",RetTitle("VQ0_DATVEN")})
	EndIf
EndIf
ni++

// VQ0_DATENT
M->MV_PAR12 := stod(aAux[1,12])
If aX3Dados[ni,3] // Campo usado
	lCpoObr := ( lIncAlt .and. x3obrigat("VQ0_DATENT") )
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , "D"                                                                     },;
		{'X3_TAMANHO' , 8                                                                       },;
		{'X3_CAMPO'   , 'MV_PAR12'                                                              },;
		{'X3_TITULO'  , RetTitle("VQ0_DATENT")                                                  },; // Entregue em
		{'X3_PICTURE' , "@D"                                                                    },;
		{'X3_RELACAO' , stod(aAux[1,12])                                                        },;
		{'X3_OBRIGAT' , lCpoObr                                                                 },;
		{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
	})
	If lCpoObr
		aAdd(aCposObr,{"M->MV_PAR12",RetTitle("VQ0_DATENT")})
	EndIf
EndIf
ni++

// VQ0_DATFDD
M->MV_PAR15 := stod(aAux[1,15])
If aX3Dados[ni,3] // Campo usado
	lCpoObr := ( lIncAlt .and. x3obrigat("VQ0_DATFDD") )
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , "D"                                                                     },;
		{'X3_TAMANHO' , 8                                                                       },;
		{'X3_CAMPO'   , 'MV_PAR15'                                                              },;
		{'X3_TITULO'  , RetTitle("VQ0_DATFDD")                                                  },; // Data FDD
		{'X3_PICTURE' , "@D"                                                                    },;
		{'X3_RELACAO' , stod(aAux[1,15])                                                        },;
		{'X3_OBRIGAT' , lCpoObr                                                                 },;
		{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
	})
	If lCpoObr
		aAdd(aCposObr,{"M->MV_PAR15",RetTitle("VQ0_DATFDD")})
	EndIf
EndIf
ni++

// VQ0_DATORS
If lVQ0_DATORS
	M->MV_PAR29 := stod(aAux[1,29])
	If aX3Dados[ni,3] // Campo usado
		lCpoObr := ( lIncAlt .and. x3obrigat("VQ0_DATORS") )
		oIHelp:AddMGetTipo({;
			{'X3_TIPO'    , "D"                                                                     },;
			{'X3_TAMANHO' , 8                                                                       },;
			{'X3_CAMPO'   , 'MV_PAR29'                                                              },;
			{'X3_TITULO'  , RetTitle("VQ0_DATORS")                                                  },; // Data ORSD
			{'X3_PICTURE' , "@D"                                                                    },;
			{'X3_RELACAO' , stod(aAux[1,29])                                                        },;
			{'X3_OBRIGAT' , lCpoObr                                                                 },;
			{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
		})
		If lCpoObr
			aAdd(aCposObr,{"M->MV_PAR29",RetTitle("VQ0_DATORS")})
		EndIf
	EndIf
	ni++
EndIf

// VQ0_CONFIG
M->MV_PAR16 := aAux[1,16]
If aX3Dados[ni,3] // Campo usado
	lCpoObr := ( lIncAlt .and. x3obrigat("VQ0_CONFIG") )
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , "C"                                                                     },;
		{'X3_TAMANHO' , TamSX3("VQ0_CONFIG")[1]                                                 },;
		{'X3_CAMPO'   , 'MV_PAR16'                                                              },;
		{'X3_TITULO'  , RetTitle("VQ0_CONFIG")                                                  },; // Config.Basic
		{'X3_PICTURE' , "@!"                                                                    },;
		{'X3_RELACAO' , aAux[1,16]                                                              },;
		{'X3_OBRIGAT' , lCpoObr                                                                 },;
		{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
	})
	If lCpoObr
		aAdd(aCposObr,{"M->MV_PAR16",RetTitle("VQ0_CONFIG")})
	EndIf
EndIf
ni++

// VQ0_BASCFD
If lVQ0_BASCFD
	M->MV_PAR23 := aAux[1,23]
	If aX3Dados[ni,3] // Campo usado
		lCpoObr := ( lIncAlt .and. x3obrigat("VQ0_BASCFD") )
		oIHelp:AddMGetTipo({;
			{'X3_TIPO'    , "N"                                                                     },;
			{'X3_TAMANHO' , 12                                                                      },;
			{'X3_DECIMAL' , 2                                                                       },;
			{'X3_CAMPO'   , 'MV_PAR23'                                                              },;
			{'X3_TITULO'  , RetTitle("VQ0_BASCFD")                                                  },; // Base Com. FD
			{'X3_PICTURE' , "@E 999,999,999.99"                                                     },;
			{'X3_RELACAO' , aAux[1,23]                                                              },;
			{'X3_OBRIGAT' , lCpoObr                                                                 },;
			{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
		})
		If lCpoObr
			aAdd(aCposObr,{"M->MV_PAR23",RetTitle("VQ0_BASCFD")})
		EndIf
	EndIf
	ni++
EndIf

// VQ0_DATPRE
M->MV_PAR24 := stod(aAux[1,24])
If aX3Dados[ni,3] // Campo usado
	lCpoObr := ( lIncAlt .and. x3obrigat("VQ0_DATPRE") )
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , "D"                                                                     },;
		{'X3_TAMANHO' , 8                                                                       },;
		{'X3_CAMPO'   , 'MV_PAR24'                                                              },;
		{'X3_TITULO'  , RetTitle("VQ0_DATPRE")                                                  },; // Dt.Previsao
		{'X3_PICTURE' , "@D"                                                                    },;
		{'X3_RELACAO' , stod(aAux[1,24])                                                        },;
		{'X3_OBRIGAT' , lCpoObr                                                                 },;
		{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
	})
	If lCpoObr
		aAdd(aCposObr,{"M->MV_PAR24",RetTitle("VQ0_DATPRE")})
	EndIf
EndIf
ni++

// VQ0_FLUXO / VQ0_DATFLU
If lVQ0_FLUXO
	// VQ0_FLUXO
	M->MV_PAR27 := aAux[1,27]
	If aX3Dados[ni,3] // Campo usado
		lCpoObr := ( lIncAlt .and. x3obrigat("VQ0_FLUXO") )
		SX3->(DbSetOrder(2))
		SX3->(DbSeek("VQ0_FLUXO"))
		oIHelp:AddMGetTipo({;
			{'X3_TIPO'    , "C"                                                                     },;
			{'X3_TAMANHO' , 1                                                                       },;
			{'X3_CAMPO'   , 'MV_PAR27'                                                              },;
			{'X3_TITULO'  , RetTitle("VQ0_FLUXO")                                                   },; // Fluxo Caixa
			{'X3_PICTURE' , "@!"                                                                    },;
			{'X3_RELACAO' , aAux[1,27]                                                              },;
			{'X3_CBOX'    , SX3->X3_CBOX                                                            },;
			{'X3_OBRIGAT' , lCpoObr                                                                 },;
			{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
		})
		If lCpoObr
			aAdd(aCposObr,{"M->MV_PAR27",RetTitle("VQ0_FLUXO")})
		EndIf
	EndIf
	ni++

	// VQ0_DATFLU
	M->MV_PAR28 := stod(aAux[1,28])
	If aX3Dados[ni,3] // Campo usado
		lCpoObr := ( lIncAlt .and. x3obrigat("VQ0_DATFLU") )
		SX3->(DbSetOrder(1))
		oIHelp:AddMGetTipo({;
			{'X3_TIPO'    , "D"                                                                     },;
			{'X3_TAMANHO' , 8                                                                       },;
			{'X3_CAMPO'   , 'MV_PAR28'                                                              },;
			{'X3_TITULO'  , RetTitle("VQ0_DATFLU")                                                  },; // Dt.Fluxo Cxa
			{'X3_PICTURE' , "@D"                                                                    },;
			{'X3_RELACAO' , stod(aAux[1,28])                                                        },;
			{'X3_OBRIGAT' , lCpoObr                                                                 },;
			{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5, ".F.", ".T.")                       } ;
		})
		If lCpoObr
			aAdd(aCposObr,{"M->MV_PAR28",RetTitle("VQ0_DATFLU")})
		EndIf
	EndIf
	ni++
EndIf

// VQ0_FILATE
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "C"                    },;
	{'X3_TAMANHO' , TamSX3("VQ0_FILATE")[1]},;
	{'X3_CAMPO'   , 'MV_PAR13'             },;
	{'X3_TITULO'  , STR0017                },; // Filial Atend.
	{'X3_PICTURE' , "@!"                   },;
	{'X3_RELACAO' , aAux[1,13]             },;
	{'X3_WHEN'    , ".F."                  } ;
})

// VQ0_NUMATE
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "C"                    },;
	{'X3_TAMANHO' , TamSX3("VQ0_NUMATE")[1]},;
	{'X3_CAMPO'   , 'MV_PAR14'             },;
	{'X3_TITULO'  , RetTitle("VQ0_NUMATE") },; // Nro do Atend
	{'X3_PICTURE' , "@!"                   },;
	{'X3_RELACAO' , aAux[1,14]             },;
	{'X3_WHEN'    , ".F."                  } ;
})

// VQ0_OBSMEM
M->MV_PAR21 := aAux[1,21]
If aX3Dados[ni,3] // Campo usado
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , "M"                                                                     },;
		{'X3_TAMANHO' , 47                                                                      },;
		{'X3_CAMPO'   , 'MV_PAR21'                                                              },;
		{'X3_TITULO'  , RetTitle("VQ0_OBSMEM")                                                  },; // Obs.Pedido
		{'X3_RELACAO' , aAux[1,21]                                                              },;
		{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(aX3Dados[ni,4]), ".F.", ".T.")} ;
	})
EndIf
ni++

// Campos customiz·veis
If Len(aCposUser) > 0
	For ni := 1 to len(aCposUser)
		SX3->(DbSetOrder(2))
		If !Empty(aCposUser[ni]) .and. SX3->(DbSeek(aCposUser[ni]))
			lX3When := .t.
			If !Empty(SX3->X3_WHEN)
				lX3When := &(SX3->X3_WHEN)
			EndIf
			lCpoObr := ( lIncAlt .and. x3obrigat(aCposUser[ni]) )
			oIHelp:AddMGetTipo({;
				{'X3_TIPO'    , SX3->X3_TIPO                                                     },;
				{'X3_TAMANHO' , SX3->X3_TAMANHO                                                  },;
				{'X3_DECIMAL' , SX3->X3_DECIMAL                                                  },;
				{'X3_CAMPO'   , SX3->X3_CAMPO                                                    },;
				{'X3_TITULO'  , SX3->X3_TITULO                                                   },;
				{'X3_PICTURE' , SX3->X3_PICTURE                                                  },;
				{'X3_VALID'   , SX3->X3_VALID                                                    },;
				{'X3_F3'      , SX3->X3_F3                                                       },;
				{'X3_RELACAO' , SX3->X3_RELACAO                                                  },;
				{'X3_CBOX'    , SX3->X3_CBOX                                                     },;
				{'X3_OBRIGAT' , lCpoObr                                                          },;
				{'X3_WHEN'    , IIf(nOpcVQ0 == 2 .or. nOpcVQ0 >= 5 .Or. !(lX3When), ".F.", ".T.")} ;
			})
			If lCpoObr
				aAdd(aCposObr,{"M->"+aCposUser[ni],RetTitle(aCposUser[ni])})
			EndIf
			If nOpcVQ0 <> 3
				If SX3->X3_CONTEXT <> "V" // Somente campos REAIS
					&("M->"+aCposUser[ni]) := &("VQ0->"+aCposUser[ni])
				ElseIf !Empty(SX3->X3_RELACAO)
					&("M->"+aCposUser[ni]) := &(SX3->X3_RELACAO)
				EndIf
			Else
				If SX3->X3_CONTEXT <> "V" // Somente campos REAIS
					If len(aCposRep) > 0 // Campos a Replicar
						nPosVet := aScan(aCposRep,aCposUser[ni])
						If nPosVet > 0
							&("M->"+aCposUser[ni]) := &("VQ0->"+aCposUser[ni]) // insere os dados replicados para aparecer na tela ( CAMPOS CUSTOMIZADOS )
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			aCposUser[ni] := "" // CAMPO NAO EXISTE NA BASE - NAO GRAVAR
		EndIf
	Next
	SX3->(DbSetOrder(1))
EndIf
//
oEnchParam1 := oIHelp:CreateMSMGet(.f., { { "ALINHAMENTO" , CONTROL_ALIGN_ALLCLIENT } } )
//
ACTIVATE MSDIALOG oVEIMV190VQ0 ON INIT EnchoiceBar(oVEIMV190VQ0,{|| IIf(VM190TOK(nOpcVQ0,lVQ0_FLUXO,aCposObr),(lOkParam:=.t.,oVEIMV190VQ0:End()),.t.) },{|| oVEIMV190VQ0:End() } )

If lOkParam .and. nOpcVQ0 <> 2 // Ok tela e nOpc diferente de Visualizar
	If nOpcVQ0 == 3 .or. nOpcVQ0 == 4 // Incluir ou Alterar
		//
		M->MV_PAR03 := ltrim(M->MV_PAR03) // CHASSI - retirar espacos em branco do inicio da string
		//
		Begin Transaction
		//
		If nOpcVQ0 == 3 // Incluir
			If len(aPedid) == 1 .and. aPedid[1,17] == 0
				aPedid := {}
			EndIf
			//
			Inclui := .t.
			//
			DbSelectArea("VV1")
			RegToMemory( "VV1" , .t. , .f. , .t. )
			ConfirmSX8()
			DbSelectArea("VV1")
			RecLock("VV1",.t.)
			FG_GRAVAR("VV1")
			VV1->VV1_FILIAL := xFilial("VV1")
			VV1->VV1_CHASSI := M->MV_PAR03
			VV1->VV1_CODMAR := M->MV_PAR04
			VV1->VV1_MODVEI := M->MV_PAR05
			If lVQ0_SEGMOD
				VV1->VV1_SEGMOD := M->MV_PAR33
			EndIf
			VV1->VV1_CORVEI := M->MV_PAR06
			VV1->VV1_SITVEI := "8" // Pedido
			VV1->VV1_ESTVEI := "0" // Novo
			If ColumnPos('VV1_CFGBAS') > 0
				VV1->VV1_CFGBAS := M->MV_PAR16
			EndIf
			VV1->VV1_FILENT := M->MV_PAR22
			MsUnlock()			
			//
			If !Empty(VV1->VV1_CHASSI)
				VM190ALTVVA(VV1->VV1_CHAINT,VV1->VV1_CHASSI) // ALTERA TODOS VVA_CHASSI DO VEICULO
			EndIf
			//
			FS_ADD_PED("aPedid")
			//
			nLinVQ0 := len(aPedid)
			DbSelectArea("VQ0")
			RecLock("VQ0",.t.)
			VQ0->VQ0_FILIAL := xFilial("VQ0")
			VQ0->VQ0_CODIGO := GetSXENum("VQ0","VQ0_CODIGO")
			ConfirmSX8()
			If lVQ0_FILREL // Filial Entrada Relacionada - controle interno para possibilitar desfazer o relacionamento do Chassi
				VQ0->VQ0_FILREL := ""
			EndIf			
			MsUnLock()
			aPedid[nLinVQ0,17] := VQ0->(RecNo())
			DbSelectArea("VQ0")
		Else
			//
			Inclui := .f.
			//
			DbSelectArea("VQ0")
			M->VV1_CHAINT := VQ0->VQ0_CHAINT
			DbSelectArea("VV1")
			DbSetOrder(1)
			If DbSeek(xFilial("VV1")+M->VV1_CHAINT)
				RecLock("VV1",.f.)
				VV1->VV1_CHASSI := M->MV_PAR03
				VV1->VV1_CODMAR := M->MV_PAR04
				VV1->VV1_MODVEI := M->MV_PAR05
				If lVQ0_SEGMOD
					VV1->VV1_SEGMOD := M->MV_PAR33
				EndIf
				VV1->VV1_CORVEI := M->MV_PAR06
				If ColumnPos('VV1_CFGBAS') > 0
					VV1->VV1_CFGBAS := M->MV_PAR16
				EndIf
				MsUnLock()
				//
				If !Empty(VV1->VV1_CHASSI)
					VM190ALTVVA(VV1->VV1_CHAINT,VV1->VV1_CHASSI) // ALTERA TODOS VVA_CHASSI DO VEICULO
				EndIf
				//
			EndIf
			DbSelectArea("VQ0")
		EndIf
		
		If ExistBlock("VM190VV1") // PE inclusao/alteracao de informacoes na tabela VV1
			ExecBlock("VM190VV1",.f.,.f.,{nOpcVQ0,VV1->VV1_FILIAL,VV1->VV1_CHAINT})
		EndIf
		
		//
		RecLock("VQ0",.f.)
		VQ0->VQ0_NUMPED := M->MV_PAR01
		VQ0->VQ0_DATPED := M->MV_PAR02
		VQ0->VQ0_CHAINT := VV1->VV1_CHAINT
		VQ0->VQ0_CHASSI := M->MV_PAR03
		VQ0->VQ0_CODMAR := M->MV_PAR04
		VQ0->VQ0_MODVEI := M->MV_PAR05
		If lVQ0_SEGMOD
			VQ0->VQ0_SEGMOD := M->MV_PAR33
		EndIf
		VQ0->VQ0_CORVEI := M->MV_PAR06
		VQ0->VQ0_FATDIR := M->MV_PAR07 // 0=Sim / 1=Nao
		VQ0->VQ0_VALCUS := M->MV_PAR08
		VQ0->VQ0_VALINI := M->MV_PAR09
		VQ0->VQ0_DESNEG := M->MV_PAR10
		VQ0->VQ0_DATVEN := M->MV_PAR11
		VQ0->VQ0_DATENT := M->MV_PAR12
		VQ0->VQ0_DATFDD := M->MV_PAR15
		VQ0->VQ0_CONFIG := M->MV_PAR16
		VQ0->VQ0_FILPED := M->MV_PAR19
		VQ0->VQ0_DATPRE := M->MV_PAR24
		If lVQ0_BASCFD
			VQ0->VQ0_BASCFD := M->MV_PAR23
		EndIf
		VQ0->VQ0_OBSMEM := M->MV_PAR21
		If lVQ0_FLUXO
			VQ0->VQ0_FLUXO  := M->MV_PAR27
			VQ0->VQ0_DATFLU := M->MV_PAR28
		EndIf
		If lVQ0_DATORS
			VQ0->VQ0_DATORS := M->MV_PAR29 // Data ORSD
		EndIf
		If lVQ0_EVENTO
			VQ0->VQ0_EVENTO := M->MV_PAR31 // Evento
		EndIf
		If lVQ0_STATUS
			VQ0->VQ0_STATUS := M->MV_PAR32 // Status
		EndIf
		For ni := 1 to len(aCposUser)
			If !Empty(aCposUser[ni]) .And. GetSx3Cache(aCposUser[ni], "X3_PROPRI") == "U" .And. GetSx3Cache(aCposUser[ni], "X3_CONTEXT") == "R" // Campo customiz·vel real
				&("VQ0->" + aCposUser[ni]) := &("M->" + aCposUser[ni])
			EndIf
		Next
		MsUnLock()
		
		If ExistBlock("VM190GRV") // PE apos gravacao dos campos da VQ0 - utilizar M->MV_PAR...
			ExecBlock("VM190GRV",.f.,.f.)
		EndIf
		
		//
		End Transaction
		//
		For ni := 1 to 16
			aPedid[nLinVQ0,ni] := &("M->MV_PAR"+strzero(ni,2))
		Next
		aPedid[nLinVQ0,02] := dtos(M->MV_PAR02) // Data Pedido
		aPedid[nLinVQ0,11] := dtos(M->MV_PAR11) // Data Vendido
		aPedid[nLinVQ0,12] := dtos(M->MV_PAR12) // Data Entregue
		aPedid[nLinVQ0,15] := dtos(M->MV_PAR15) // Data FDD
		aPedid[nLinVQ0,19] := M->MV_PAR19 // Filial Pedido
		aPedid[nLinVQ0,22] := M->MV_PAR22 // Filial Veiculo
		aPedid[nLinVQ0,21] := M->MV_PAR21 // Observacao
		aPedid[nLinVQ0,23] := M->MV_PAR23 // Vlr.Base Comissao Faturamento Direto
		aPedid[nLinVQ0,24] := dtos(M->MV_PAR24) // Previsao Entrega
		aPedid[nLinVQ0,26] := VV1->VV1_CHAINT
		If lVQ0_FLUXO
			aPedid[nLinVQ0,27] := M->MV_PAR27 // Fluxo de Caixa
			aPedid[nLinVQ0,28] := dtos(M->MV_PAR28) // Data Fluxo de Caixa
		EndIf
		If lVQ0_DATORS
			aPedid[nLinVQ0,29] := dtos(M->MV_PAR29) // Data ORSD
		EndIf
		If lVQ0_EVENTO
			aPedid[nLinVQ0,31] := M->MV_PAR31 // Evento
		EndIf
		If lVQ0_STATUS
			aPedid[nLinVQ0,32] := left(M->MV_PAR32+" ",1) // Status
		EndIf
		If lVQ0_SEGMOD
			aPedid[nLinVQ0,33] := M->MV_PAR33
		EndIf
		//
		nVlrIni := FS_VLRVEI(nLinVQ0)
	ElseIf nOpcVQ0 == 5 // Excluir
		DbSelectArea("VQ0")
		If !Empty(VQ0->VQ0_NUMATE)
			MsgStop(STR0070+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0017+": "+VQ0->VQ0_FILATE+CHR(13)+CHR(10)+RetTitle("VQ0_NUMATE")+": "+VQ0->VQ0_NUMATE,STR0050) // O PEDIDO esta relacionado em um Atendimento. ImpossÌvel continuar! / Filial / Atendimento / Atencao
		Else
			aadd(aArquivos,{"VVG",2,VQ0->VQ0_CHAINT ,})
			aadd(aArquivos,{"VVA",3,VQ0->VQ0_CHAINT ,})
			aadd(aArquivos,{"VO1",4,VQ0->VQ0_CHAINT ,})

			If ExistBlock("VM190EXC")
				nRecVQ0      := VQ0->(RecNo())
				lPodeExcluir := ExecBlock("VM190EXC", .f., .f., { nRecVQ0 }) // Ponto de Entrada para validar se È possÌvel excluir

				VQ0->(DbGoto(nRecVQ0))
			EndIf

			If FG_DELETA(aArquivos) .and. lPodeExcluir
				//
				Begin Transaction
				//
				DbSelectArea("VV1")
				DbSetOrder(1)
				If DbSeek(xFilial("VV1")+VQ0->VQ0_CHAINT)
					RecLock("VV1",.F.,.T.)
					dbDelete()
					MsUnLock()
				EndIf
				DbSelectArea("SB1")
				DbSetOrder(7)
				If DbSeek(xFilial("SB1")+cGruVei+VQ0->VQ0_CHAINT)
					RecLock("SB1",.F.,.T.)
					DbDelete()
					MsUnLock()
				EndIf
				//
				DbSelectArea("VQ0")
				RecLock("VQ0",.F.,.T.)
				dbDelete()
				MsUnLock()
				//
				DbSelectArea("VQ1")
				For ni := 1 to len(aBonus)
					If aBonus[ni,14] > 0
						DbGoTo(aBonus[ni,14])
						RecLock("VQ1",.F.,.T.)
						dbDelete()
						MsUnLock()

						VEM1900098_VerificaPEVQ1(4)

					EndIf
				Next
				aAux := {}
				For ni := 1 to len(aPedid)
					If ni <> nLinVQ0
						aAdd(aAux,aClone(aPedid[ni]))
					EndIf
				Next
				aPedid := aClone(aAux)
				If len(aPedid) <= 0
					FS_ADD_PED("aPedid")
				EndIf
				If len(aPedid) < nLinVQ0
					nLinVQ0 := len(aPedid)
				EndIf
				//
				End Transaction
				//
				oLbPedid:nAt := nLinVQ0
				oLbPedid:SetArray(aPedid)
				oLbPedid:Refresh()
			EndIf
		EndIf
	EndIf
Else
	Return .f.
EndIf
Return .t.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ VM190TOK  ≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 05/06/17 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Tudo OK na Tela de Inclusao/Alteracao do Pedido (VQ0)       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function VM190TOK(nOpcVQ0,lVQ0_FLUXO,aCposObr)
Local lRet := .f.
Local ni   := 0
If nOpcVQ0 == 2 // Visualizar
	lRet := .t.
Else
	If VM190CHASSI(nOpcVQ0,ltrim(M->MV_PAR03))
		If lVQ0_FLUXO
			If M->MV_PAR27 == "S" .and. Empty(M->MV_PAR28) // Selecionou para Constar no Fluxo de Caixa e nao informou a Data
				MsgStop(STR0127,STR0050) // Data que devera constar no Fluxo de Caixa nao informada! / Atencao
			ElseIf M->MV_PAR27 == "N" .and. !Empty(M->MV_PAR28) // Selecionou para NAO Constar no Fluxo de Caixa e informou a Data
				MsgStop(STR0147,STR0050) // … necess·rio informar para constar no Fluxo de Caixa se for preenchida a Data do mesmo. / Atencao
			Else
				lRet := .t.
			EndIf
		Else
			lRet := .t.
		EndIf
	EndIf
	If lRet
		For ni := 1 to Len(aCposObr)
			If Empty(&(aCposObr[ni,1]))
				Help(" ",1,"OBRIGAT2",,aCposObr[ni,2],4,1)
				lRet := .f.
				Exit
			EndIf
		Next
	EndIf
EndIf
Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥VM190ALTVVA≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 28/04/15 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Altera Chassi dos VVAs                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function VM190ALTVVA(cChaInt,cChassi)
Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt:= cFilAnt
Local nCont     := 0
Local cFilVVA   := "("
Local lVV1Comp  := .t.
Local cFilVV1   := xFilial("VV1")
Local cQuery    := ""
Local cQAlSQL   := "SQLVVA"
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	If lVV1Comp .and. cFilVV1 <> xFilial("VV1") // Verifica se o VV1 nao eh compartilhado
		lVV1Comp := .f.
	EndIf
	cFilVVA += "'"+xFilial("VVA")+"',"
Next
cFilAnt := cBkpFilAnt
cFilVVA := left(cFilVVA,len(cFilVVA)-1)+")"
cQuery := "SELECT R_E_C_N_O_ RECVVA FROM "+RetSqlName("VVA")+" WHERE "
If lVV1Comp // VV1 Compartilhado
	cQuery += "VVA_FILIAL IN "+cFilVVA+" AND "
Else // VV1 Exclusivo
	cQuery += "VVA_FILIAL='"+xFilial("VVA")+"' AND "
EndIf
cQuery += "VVA_CHAINT='"+cChaInt+"' AND ( VVA_CHASSI=' ' "
If !Empty(cChassi)
	cQuery += "OR VVA_CHASSI<>'"+Alltrim(cChassi)+"' "
Else
	cQuery += "OR VVA_CHASSI<>'"+cChassi+"' "
EndIf
cQuery += ") AND D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	DbSelectArea("VVA")
	DbGoTo(( cQAlSQL )->( RECVVA ))
	RecLock("VVA",.f.)
	VVA->VVA_CHASSI := cChassi
	MsUnLock()
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
dbSelectArea("VQ0")
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥VM190CHASSI≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 26/12/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Validacao do Chassi                                         ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function VM190CHASSI(nOpcVQ0,cChassiPesq)
Local nAux := 0
Local lRet := .t.
If nOpcVQ0 == 3 .or. nOpcVQ0 == 4 // Incluir ou Alterar
	If !Empty(cChassiPesq)
		nAux := FM_SQL("SELECT R_E_C_N_O_ FROM "+RetSQLName("VV1")+" WHERE VV1_FILIAL='"+xFilial("VV1")+"' AND VV1_CHASSI='"+Alltrim(cChassiPesq)+"' AND "+IIf(nOpcVQ0==4,"VV1_CHAINT<>'"+VQ0->VQ0_CHAINT+"' AND ","")+"D_E_L_E_T_=' '")
		If nAux > 0
			MsgStop(STR0096,STR0050) // Veiculo ja cadastrado. Impossivel continuar! / Atencao
			lRet := .f.
		EndIf
	EndIf
EndIf
Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ FS_VQ1   ≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 19/08/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Manutencao no Bonus VQ1                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_VQ1(nOpcVQ1,nLinVQ1,cTitVQ1)
Local aRet      := {}
Local aParamBox := {}
Local ni        := 0
Local lVQ1_EVENTO := ( VQ1->(FieldPos("VQ1_EVENTO")) > 0 )
Local aRetVZQ   := {}
Private aAux    := {}
If aPedid[oLbPedid:nAt,17] == 0
	Return()
EndIf
DbSelectArea("VQ1")
//
FS_ADD_BON("aAux","oNada")
//
If nOpcVQ1 <> 3
	If !Empty(aBonus[nLinVQ1,11])
		MsgAlert(STR0052,STR0050) // NF referente ao bonus ja esta gerada. Sera necessario cancelar a NF antes! / Atencao
		Return()
	EndIf
	If aBonus[nLinVQ1,14] <= 0 // Caso esteja vazio o listbox
		MsgAlert(STR0054,STR0050) // Sera necessario incluir o Bonus antes. / Atencao
		Return()
	EndIf
	For ni := 1 to len(aAux[1])
		aAux[1,ni] := aBonus[nLinVQ1,ni]
	Next
Else
	aAux[1,03] := nVlrIni
EndIf
 
AADD(aParamBox,{1,     RetTitle("VQ1_CODBON"),aAux[1,02],"@!"               ,""            ,"",IIf(nOpcVQ1<>3,".F.",""),95,IIf(nOpcVQ1<5,.t.,.f.)}) // CÛdigo BÙnus
AADD(aParamBox,{1,     RetTitle("VQ0_VALINI"),aAux[1,03],"@E 999,999,999.99","VM190VLDP(2)","",IIf(nOpcVQ1>=5,".F.",""),70,IIf(nOpcVQ1<5,.t.,.f.)}) // Vlr.Inicial
AADD(aParamBox,{1,"% "+RetTitle("VQ1_DESCON"),aAux[1,04],"@E 9999.99"       ,"VM190VLDP(3)","",IIf(nOpcVQ1>=5,".F.",""),50,.f.}) // Desc Concess
AADD(aParamBox,{1,"% "+RetTitle("VQ1_DESTRI"),aAux[1,05],"@E 9999.99"       ,"VM190VLDP(4)","",IIf(nOpcVQ1>=5,".F.",""),50,.f.}) // Desc Tributa
AADD(aParamBox,{1,"% "+RetTitle("VQ1_DESCDC"),aAux[1,06],"@E 9999.99"       ,"VM190VLDP(5)","",IIf(nOpcVQ1>=5,".F.",""),50,.f.}) // Desc CondiÁ„
AADD(aParamBox,{1,"% "+RetTitle("VQ1_DESTAT"),aAux[1,07],"@E 9999.99"       ,"VM190VLDP(6)","",IIf(nOpcVQ1>=5,".F.",""),50,.f.}) // Desc T·tico
AADD(aParamBox,{1,     RetTitle("VQ1_VLRBAS"),aAux[1,08],"@E 999,999,999.99",""            ,"",".F."                   ,70,IIf(nOpcVQ1<5,.t.,.f.)}) // Vlr.Base
AADD(aParamBox,{1,"% "+STR0029               ,aAux[1,09],"@E 9999.99"       ,"VM190VLDP(8)","",IIf(nOpcVQ1>=5,".F.",""),50,IIf(nOpcVQ1<5,.t.,.f.)}) // Bonus
AADD(aParamBox,{1,STR0033                    ,aAux[1,10],"@E 999,999,999.99","VM190VLDP(9)","",IIf(nOpcVQ1>=5,".F.",""),70,IIf(nOpcVQ1<5,.t.,.f.)}) // Vlr.Bonus
AADD(aParamBox,{1,     RetTitle("VQ1_PERIMP"),aAux[1,16],"@E 9999.99"       ,"VM190VLDP(10)","",IIf(nOpcVQ1>=5,".F.",""),50,.f.}) // % Prev Impos
AADD(aParamBox,{1,     RetTitle("VQ1_VLRLIQ"),aAux[1,17],"@E 999,999,999.99","VM190VLDP(11)","",IIf(nOpcVQ1>=5,".F.",""),70,.f.}) // Vlr LÌq Prev
If ParamBox(aParamBox,cTitVQ1,@aRet,,,,,,,,.f.) // Incluir / Alterar / Excluir
	If nOpcVQ1 < 5 // 3 = Incluir / 4 = Alterar
		//
		Begin Transaction
		//
		DbSelectArea("VQ0")
		DbGoto(aPedid[oLbPedid:nAt,17])
		If nOpcVQ1 == 3 // Incluir
			If len(aBonus) == 1 .and. aBonus[1,14] == 0
				aBonus := {}
			EndIf
			//
			FS_ADD_BON("aBonus","oS1")
			//
			nLinVQ1 := len(aBonus)
			DbSelectArea("VQ1")
			RecLock("VQ1",.t.)
			VQ1->VQ1_FILIAL := xFilial("VQ1")
			VQ1->VQ1_CODIGO := VQ0->VQ0_CODIGO
			VQ1->VQ1_SEQUEN := strzero(val(FM_SQL("SELECT MAX(VQ1_SEQUEN) FROM "+RetSQLName("VQ1")+" WHERE VQ1_FILIAL='"+xFilial("VQ1")+"' AND VQ1_CODIGO='"+VQ0->VQ0_CODIGO+"' AND D_E_L_E_T_=' '"))+1,3)
			MsUnLock()
			aBonus[nLinVQ1,14] := VQ1->(RecNo())
			FS_GRAVAR(5,nLinVQ1,"1")
		EndIf
		//
		aRetVZQ := VM190RVZQ(RetSQLName("VZQ"),xFilial("VQ1"),aRet[01])
		//
		aBonus[nLinVQ1,18] := aRetVZQ[1]
		aBonus[nLinVQ1,20] := aRetVZQ[2]
		//
		DbSelectArea("VQ1")
		DbGoto(aBonus[nLinVQ1,14])
		RecLock("VQ1",.f.)
		VQ1->VQ1_CODBON := aBonus[nLinVQ1,02] := aRet[01]
		VQ1->VQ1_VLRINI := aBonus[nLinVQ1,03] := aRet[02]
		VQ1->VQ1_DESCON := aBonus[nLinVQ1,04] := aRet[03]
		VQ1->VQ1_DESTRI := aBonus[nLinVQ1,05] := aRet[04]
		VQ1->VQ1_DESCDC := aBonus[nLinVQ1,06] := aRet[05]
		VQ1->VQ1_DESTAT := aBonus[nLinVQ1,07] := aRet[06]
		VQ1->VQ1_VLRBAS := aBonus[nLinVQ1,08] := aRet[07]
		VQ1->VQ1_PERVLR := aBonus[nLinVQ1,09] := aRet[08]
		VQ1->VQ1_VLRTOT := aBonus[nLinVQ1,10] := aRet[09]
		VQ1->VQ1_PERIMP := aBonus[nLinVQ1,16] := aRet[10]
		VQ1->VQ1_VLRLIQ := aBonus[nLinVQ1,17] := aRet[11]
		If lVQ1_EVENTO
			VQ1->VQ1_EVENTO := aRetVZQ[3]
		EndIf
		MsUnLock()
		//
		End Transaction
		//
		VEM1900098_VerificaPEVQ1(5)
		//
	ElseIf nOpcVQ1 == 5 // Excluir
		DbSelectArea("VQ1")
		DbGoto(aBonus[nLinVQ1,14])
		RecLock("VQ1",.F.,.T.)
		dbDelete()
		MsUnLock()

		VEM1900098_VerificaPEVQ1(6)

		aAux := {}
		For ni := 1 to len(aBonus)
			If ni <> nLinVQ1
				aAdd(aAux,aClone(aBonus[ni]))
			EndIf
		Next
		aBonus := aClone(aAux)
		If len(aBonus) <= 0
			FS_ADD_BON("aBonus","oNada")
			nVlrIni := FS_VLRVEI(oLbPedid:nAt)
		EndIf
		If len(aBonus) < nLinVQ1
			nLinVQ1 := len(aBonus)
		EndIf
	EndIf
	oLbBonus:nAt := nLinVQ1
	oLbBonus:SetArray(aBonus)
	oLbBonus:Refresh()
EndIf
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ VM190VLDP ≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 19/08/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Validacao dos campos da Parambox                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function VM190VLDP(nTp)
Local nVlrAux := &("MV_PAR"+strzero(nTp,2))
If nVlrAux < 0 .or. ( ( nTp >= 3 .and. nTp <= 8 ) .and. nVlrAux > 100 ) .or. ( nTp == 10 .and. nVlrAux > 100 )
	Return(.f.)
EndIf
If nTp == 11
	MV_PAR10 := round( ( ( ( MV_PAR09 - MV_PAR11 ) / MV_PAR09 ) * 100 ) , 2 )
ElseIf nTp == 10
	MV_PAR11 := round( MV_PAR09 - ( ( MV_PAR09 * MV_PAR10 ) / 100 ) , 2 )
ElseIf nTp == 9
	MV_PAR08 := round( ( ( MV_PAR09 / MV_PAR07 ) * 100 ) , 2 )
	MV_PAR11 := round( MV_PAR09 - ( ( MV_PAR09 * MV_PAR10 ) / 100 ) , 2 )
ElseIf nTp < 9
	nVlrAux  := MV_PAR02
	nVlrAux  := ( nVlrAux - ( ( MV_PAR03 * MV_PAR02 ) / 100 ) )
	MV_PAR07 := ( nVlrAux - ( ( MV_PAR05 * MV_PAR02 ) / 100 ) )
	MV_PAR09 := round( ( ( MV_PAR07 * MV_PAR08 ) / 100 ) , 2 )
	MV_PAR11 := round( MV_PAR09 - ( ( MV_PAR09 * MV_PAR10 ) / 100 ) , 2 )
EndIf
Return(.t.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ FS_GRAVAR ≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 20/08/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Gravacoes / Cancelamentos / Geracao de NF                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_GRAVAR(nTp,nLinVet,cStatus)
Local cQuery    := ""
Local cQAlSQL   := "ALIASSQL"
Local cAliasVDT := "SQLVDT"
Local ni        := 0
Local lOk       := .f.
Local aVQ4RecNo := {}
Local nCntExc := 0

If aBonus[1,1] == "oNada"
	MsgAlert(STR0054,STR0050) // Sera necessario incluir o Bonus antes. / Atencao
	Return()
EndIf

Do Case
	
	Case nTp == 2 // Liberar para geracao de NF
		For ni := 1 to len(aBonus)
			If aBonus[ni,15]
				lOk := .t.
				Exit
			EndIf
		Next
		If !lOk
			MsgInfo(STR0053,STR0050) // Necessario selecionar os registros! / Atencao
		ElseIf MsgYesNo(STR0055,STR0050) // Deseja liberar para geracao de NF os registros selecionados? / Atencao
			//
			Begin Transaction
			//
			For ni := 1 to len(aBonus)
				If aBonus[ni,15]
					FS_GRAVAR(5,ni,"2")
				EndIf
			Next
			//
			End Transaction
			//
		EndIf
		
	Case nTp == 4 // Cancelamento
		If right(aBonus[nLinVet,01],1) $ "12" // Levantados / Gravados / Liberados para faturar
			If MsgYesNo(STR0064,STR0050) // Deseja Cancelar o bonus selecionado? / Atencao
				DbSelectArea("VQ1")
				DbGoTo(aBonus[nLinVet,14])
				aMotCancel := OFA210MOT("000014","8",VQ1->VQ1_FILIAL,VQ1->VQ1_CODIGO+VQ1->VQ1_SEQUEN,.T.) // Filtro da consulta do motivo
				If Len(aMotCancel) > 0
					FS_GRAVAR(5,nLinVet,"4")
					aBonus[nLinVet,15] := .f.
					dbSelectArea("VQ1")
					RecLock("VQ1",.f.)
					VQ1->VQ1_MOTIVO := aMotCancel[1]
					MsUnlock()
				Endif
			EndIf
		ElseIf right(aBonus[nLinVet,01],1) == "3" // NF gerada
			DbSelectArea("VQ1")
			DbGoTo(aBonus[nLinVet,14])
			cQuery := "SELECT VQ4.R_E_C_N_O_ RECVQ4 FROM "+RetSQLName("VQ4")+" VQ4 WHERE VQ4.VQ4_FILIAL='"+xFilial("VQ4")+"' AND "
			cQuery += "VQ4.VQ4_FILNFI='"+VQ1->VQ1_FILNFI+"' AND VQ4.VQ4_NUMNFI='"+VQ1->VQ1_NUMNFI+"' AND VQ4.VQ4_SERNFI='"+VQ1->VQ1_SERNFI+"' AND VQ4.D_E_L_E_T_=' ' "
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlSQL, .T., .T. )
			Do While !( cQAlSQL )->( Eof() )
			   aAdd(aVQ4RecNo,( cQAlSQL )->(RECVQ4)) // Levantar os VQ4 da NF a ser cancelada
				( cQAlSQL )->(dbSkip())
			Enddo
			( cQAlSQL )->( dbCloseArea() )
			DbSelectArea("VQ4")
			// Se a NF ja foi transmitida e nao tem os campos com os NOMES do XML ( nome atual / nome anterior ) nao deixa continuar
			If len(aVQ4RecNo) > 0 .and. VQ4->(ColumnPos("VQ4_NXMLAT")) <= 0
				MsgStop(STR0067,STR0050) // NF de Bonus ja esta transmitida! / Atencao
				Return()
			EndIf
			//
			DbSelectArea("VQ1")
			If MsgYesNo(IIf(len(aVQ4RecNo)>0,STR0067,"")+" "+STR0063+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0034+": "+aBonus[nLinVet,11]+"-"+aBonus[nLinVet,12],STR0050) // NF de Bonus ja esta transmitida! Deseja Cancelar a NF ? / Atencao
				aMotCancel := OFA210MOT("000014","8",VQ1->VQ1_FILIAL,VQ1->VQ1_CODIGO+VQ1->VQ1_SEQUEN,.T.) // Filtro da consulta do motivo
				If Len(aMotCancel) > 0
					If FMX_EXCNFS(aBonus[nLinVet,11],aBonus[nLinVet,12],.t.)
						cQuery := "SELECT R_E_C_N_O_ RECVQ1 "
						cQuery += "FROM "+RetSQLName("VQ1")+" "
						cQuery += "WHERE VQ1_FILIAL='"+xFilial("VQ1")+"' AND VQ1_NUMNFI='"+aBonus[nLinVet,11]+"' AND VQ1_SERNFI='"+aBonus[nLinVet,12]+"' AND D_E_L_E_T_=' '"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
						While !( cQAlSQL )->( Eof() )
							DbSelectArea("VQ1")
							DbGoTo(( cQAlSQL )->( RECVQ1 ))
							RecLock("VQ1",.f.)
							VQ1->VQ1_STATUS := "4" // Cancelada
							VQ1->VQ1_MOTIVO := aMotCancel[1]
							VQ1->VQ1_RETUID := ""
							MsUnLock()
							( cQAlSQL )->( DbSkip() )
						EndDo
						( cQAlSQL )->( DbCloseArea() )
						If len(aVQ4RecNo) > 0
							DbSelectArea("VQ4")
							For ni := 1 to len(aVQ4RecNo)
								DbSelectArea("VQ4")
								DbGoTo(aVQ4RecNo[ni])
								RecLock("VQ4",.F.,.T.)
								dbdelete() // Apagar VQ4 correspondente
								MsUnlock()
							Next
						EndIf
					EndIf
					dbSelectArea("VQ1")
				Endif
			EndIf
		ElseIf right(aBonus[nLinVet,01],1) == "4" // Cancelado
			If MsgYesNo(STR0065,STR0050) // Deseja recuperar o registro selecionado? / Atencao

				DbSelectArea("VQ1")
				DbGoTo(aBonus[nLinVet,14])
				cMotVQ1 := VQ1->VQ1_MOTIVO
				RecLock("VQ1",.f.)
				If !Empty(aBonus[nLinVet,11]+aBonus[nLinVet,12])
					VQ1->VQ1_FILNFI := ""
					VQ1->VQ1_NUMNFI := ""
					VQ1->VQ1_SERNFI := ""
					VQ1->VQ1_DATNFI := ctod("")
					VQ1->VQ1_OBSNFC := ""
				EndIf
				VQ1->VQ1_MOTIVO := ""
				MsUnLock()

				cQuery := "SELECT R_E_C_N_O_ AS RECVDT "
				cQuery += "  FROM "+RetSqlName( "VDT" )
				cQuery += " WHERE VDT_FILIAL='"+ xFilial("VDT")+ "'"
				cQuery += "   AND VDT_TIPASS = '000014'"
				cQuery += "   AND VDT_CODMOT = '"+cMotVQ1+"'"
				cQuery += "   AND D_E_L_E_T_ = ' '"
				cQuery += "   AND VDT_CODORI = "
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery+"'"+VQ1->VQ1_CODIGO+VQ1->VQ1_SEQUEN+"'"), cAliasVDT, .T., .T. ) //alex - consulta antes da alteracao da chave de pesquisa
				If ( cAliasVDT )->( Eof() )
					( cAliasVDT )->( DbCloseArea() )
					dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery+"'"+VQ1->VQ1_CODIGO+"'"), cAliasVDT, .T., .T. ) // Somente CODIGO, Sem Sequencia
				EndIf
				Do While !( cAliasVDT )->( Eof() )
					DbSelectArea("VDT")
					dbGoTo(( cAliasVDT )->(RECVDT))
					RecLock("VDT",.F.,.T.)
					dbdelete()
					MsUnlock()
					dbSelectArea(cAliasVDT)
					( cAliasVDT )->(dbSkip())
				Enddo
				( cAliasVDT )->( dbCloseArea() )
				DbSelectArea("VQ1")
				FS_GRAVAR(5,nLinVet,"1")
			EndIf
		EndIf
		
		VEM1900098_VerificaPEVQ1(7)	
		
	Case nTp == 5 // Grava Status
		aBonus[nLinVet,01] := "oS"+cStatus
		DbSelectArea("VQ1")
		DbGoTo(aBonus[nLinVet,14])
		RecLock("VQ1",.f.)
		VQ1->VQ1_STATUS := cStatus
		MsUnLock()
		
EndCase
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥FS_VM190BON≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 21/08/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Levanta Bonus do Veiculo / Marca / Modelo                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_VM190BON()
Local cQuery      := ""
Local cQAlSQL     := "SQLVZQVZT"
Local ni          := 0
Local cOpcSel     := ""
Local dDtRefV     := VQ0->VQ0_DATVEN
Local dDtRefC     := VQ0->VQ0_DATPED
Local aVetBon     := {}
Local nPerBon     := 0
Local nVlrBon     := 0
Local lVZQ_CHASSI := ( VZQ->(ColumnPos("VZQ_CHASSI")) > 0 )
Local lVZQ_BONPOR := ( VZQ->(ColumnPos("VZQ_BONPOR")) > 0 )
Local lVZQ_DINMVD := ( VZQ->(ColumnPos("VZQ_DINMVD")) > 0 ) .and. ( cMVMIL0006 == "JD" )
Local lVZQ_CDCAMP := ( VZQ->(ColumnPos("VZQ_CDCAMP")) > 0 )
Local lVZQ_EVENTO := ( VZQ->(ColumnPos("VZQ_EVENTO")) > 0 )
//
Local cUF         := ""
Local aUF         := {"AC","AL","AP","AM","BA","CE","DF","ES","GO","MA","MT","MS","MG","PA","PB","PR","PE","PI","RJ","RN","RS","RO","RR","SC","SP","SE","TO"}
Local aFilAtu     := {}
Local nRecSM0     := SM0->(RecNo())
Local cSlvFilAnt  := cFilAnt
//
If lVZQ_BONPOR // Bonus por ( 1= Geral(Normal) / 2=Por UF )
	cFilAnt := VV1->VV1_FILENT
	aFilAtu := FWArrFilAtu()
	If SM0_RECNO > 0 .and. aFilAtu[SM0_RECNO] > 0
		DbSelectArea("SM0")
		DbGoTo(aFilAtu[SM0_RECNO])
	EndIf
	cUF := IIf(!Empty(SM0->M0_ESTCOB),SM0->M0_ESTCOB,SM0->M0_ESTENT) // Pegar UF da Filial de Entrada do Veiculo ( VV1_FILENT )
	DbGoTo(nRecSM0)
	cFilAnt := cSlvFilAnt
	If !Empty(cUF) .and. aScan(aUF,cUF) <= 0
		MsgStop(STR0113+" "+VV1->VV1_FILENT,STR0050) // UF n„o encontrada da Filial / Atencao
		Return(aVetBon)
	EndIf
EndIf
//
If Empty(dDtRefV)
	dDtRefV := dDataBase
EndIf
If Empty(dDtRefC)
	dDtRefC := dDataBase
EndIf
cQuery := "SELECT VZQ.VZQ_CODBON , VZQ.VZQ_PERBON , VZQ.VZQ_VALBON , VZT.VZT_PERBON , VZT.VZT_VALBON , VZT.VZT_OPCION "
If lVZQ_BONPOR
	cQuery += ", VZQ.VZQ_BONPOR , VZQ.VZQ_VALBUF , VZQ.VZQ_PERBUF , VZT.VZT_VALBUF , VZT.VZT_PERBUF "
EndIf
If lVZQ_CDCAMP
	cQuery += ", VZQ.VZQ_CDCAMP "
EndIf
cQuery += "FROM "+RetSqlName("VZQ")+" VZQ "
cQuery += "INNER JOIN "+RetSqlName("VZT")+" VZT ON (VZT.VZT_FILIAL='"+xFilial("VZT")+"' AND VZT.VZT_CODBON=VZQ.VZQ_CODBON AND VZT.D_E_L_E_T_=' ') "
cQuery += "WHERE VZQ.VZQ_FILIAL='"+xFilial("VZQ")+	"' AND ("
cQuery += "(VZT.VZT_CODMAR='"+VV1->VV1_CODMAR+"' AND VZT.VZT_GRUMOD='"+VV2->VV2_GRUMOD+"' AND VZT.VZT_MODVEI='"+VV1->VV1_MODVEI+"' ) OR "
cQuery += "(VZT.VZT_CODMAR='"+VV1->VV1_CODMAR+"' AND VZT.VZT_GRUMOD='"+VV2->VV2_GRUMOD+"' AND VZT.VZT_MODVEI=' ' ) OR "
cQuery += "(VZT.VZT_CODMAR='"+VV1->VV1_CODMAR+"' AND VZT.VZT_GRUMOD=' ' AND VZT.VZT_MODVEI=' ' ) ) AND "
If !Empty(VV1->VV1_FABMOD)
	cQuery += "( VZT.VZT_FABMOD='"+VV1->VV1_FABMOD+"' OR VZT.VZT_FABMOD=' ') AND "
EndIf
cQuery += "VZQ.VZQ_COMVEN IN ('1',' ') AND " // Bonus de Venda
If lVZQ_CHASSI
	If !Empty(VV1->VV1_CHASSI) // Bonus por Chassi
		cQuery += "( VZQ.VZQ_CHASSI=' ' OR VZQ.VZQ_CHASSI='"+VV1->VV1_CHASSI+"' ) AND "
	Else
		cQuery += "VZQ.VZQ_CHASSI=' ' AND "
	EndIf
EndIf
cQuery += "( "
cQuery += "( VZQ.VZQ_DATVER='0' AND VZQ.VZQ_DATINI<='"+dtos(dDtRefV) +"' AND VZQ.VZQ_DATFIN>='"+dtos(dDtRefV) +"' ) OR " // Filtra Venda
cQuery += "( VZQ.VZQ_DATVER='1' AND VZQ.VZQ_DINCPA<='"+dtos(dDtRefC) +"' AND VZQ.VZQ_DFICPA>='"+dtos(dDtRefC) +"' ) OR " // Filtra Compra
cQuery += "( VZQ.VZQ_DATVER='2' AND VZQ.VZQ_DATINI<='"+dtos(dDtRefV) +"' AND VZQ.VZQ_DATFIN>='"+dtos(dDtRefV) +"' AND VZQ.VZQ_DINCPA<='"+dtos(dDtRefC) +"' AND VZQ.VZQ_DFICPA>='"+dtos(dDtRefC) +"' ) " // Filtra Venda e Compra
cQuery += ") "
If lVZQ_DINMVD
	cQuery += "AND ( VZQ.VZQ_DINMVD = '  ' OR '" + dtos(VQ0->VQ0_DATVEN) + "' BETWEEN VZQ.VZQ_DINMVD AND VZQ.VZQ_DFIMVD) "
	cQuery += "AND ( VZQ.VZQ_DINENT = '  ' OR '" + dtos(VQ0->VQ0_DATENT) + "' BETWEEN VZQ.VZQ_DINENT AND VZQ.VZQ_DFIENT) "
EndIf
If lVZQ_CDCAMP
	cQuery += "AND ( VZQ.VZQ_DINFDD = '  ' OR '" + dtos(VQ0->VQ0_DATFDD) + "' BETWEEN VZQ.VZQ_DINFDD AND VZQ.VZQ_DFIFDD) "
	cQuery += "AND ( VZQ.VZQ_DINORS = '  ' OR '" + dtos(VQ0->VQ0_DATORS) + "' BETWEEN VZQ.VZQ_DINORS AND VZQ.VZQ_DFIORS) "
EndIf
If lVZQ_EVENTO
	cQuery += "AND ( VZQ.VZQ_EVENTO='"+VQ0->VQ0_EVENTO+"' " // Evento igual
	If !Empty(VQ0->VQ0_EVENTO)
		cQuery += "OR VZQ.VZQ_EVENTO=' ' " // Evento em branco
	EndIf
	cQuery += ") "
EndIf
cQuery += "AND ( VZT.VZT_ESTVEI='0' OR VZT.VZT_ESTVEI=' ' ) AND VZQ.D_E_L_E_T_=' ' ORDER BY VZQ.VZQ_CODBON" // Veiculo Novo
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	If !Empty(VV1->VV1_OPCFAB)
		For ni := 1 to 5
			cOpcSel := ""
			If !Empty(Substr(( cQAlSQL )->( VZT_OPCION ),(ni*3+1)-3,3))
				cOpcSel := Substr(( cQAlSQL )->( VZT_OPCION ),(ni*3+1)-3,3)
				If !( cOpcSel $ VV1->VV1_OPCFAB )
					( cQAlSQL )->( DbSkip() )//desconsidera o veiculo
					Loop
				EndIf
			EndIf
		Next
	EndIf
	//verificar se o veiculo eh uma excessao do bonus se for nao adicionar no array.
	If !Empty(VV1->VV1_CHASSI)
		VZR->(DbSetOrder(1))
		If VZR->(DbSeek(xFilial("VZR") + ( cQAlSQL )->( VZQ_CODBON ) + VV1->VV1_CHASSI ))
			( cQAlSQL )->( DbSkip() )
			Loop
		EndIf
	EndIf
	If !lVZQ_BONPOR .or. ( cQAlSQL )->( VZQ_BONPOR ) <> "2" // Nao tem Bonus por UF ou se trata de Bonus Normal
		nPerBon := 0
		nVlrBon := ( cQAlSQL )->( VZT_VALBON ) // 1o. Valor VZT
		If nVlrBon == 0
			nPerBon := ( cQAlSQL )->( VZT_PERBON ) // 2o. % VZT
			If nPerBon == 0
				nVlrBon := ( cQAlSQL )->( VZQ_VALBON ) // 3o. Valor VZQ
				If nVlrBon == 0
					nPerBon := ( cQAlSQL )->( VZQ_PERBON ) // 4o. % VZQ
				EndIf
			EndIf
		EndIf
	Else // Bonus por UF
		nPerBon := 0
		nVlrBon := FS_BUSCAUF("1",cUF,( cQAlSQL )->( VZT_VALBUF )) // 1o. Valor VZT
		If nVlrBon == 0
			nPerBon := FS_BUSCAUF("2",cUF,( cQAlSQL )->( VZT_PERBUF )) // 2o. % VZT
			If nPerBon == 0
				nVlrBon := FS_BUSCAUF("1",cUF,( cQAlSQL )->( VZQ_VALBUF )) // 3o. Valor VZQ
				If nVlrBon == 0
					nPerBon := FS_BUSCAUF("2",cUF,( cQAlSQL )->( VZQ_PERBUF )) // 4o. % VZQ
				EndIf
			EndIf
		EndIf
	EndIf
	aAdd(aVetBon,{( cQAlSQL )->( VZQ_CODBON ),nPerBon,nVlrBon,IIf(lVZQ_CDCAMP,( cQAlSQL )->( VZQ_CDCAMP ),"")})
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( dbCloseArea() )
DbSelectArea("VZQ")
Return(aVetBon)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ FS_BUSCAUF≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 13/03/15 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Busca na String o Valor ou Percentual por UF                ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_BUSCAUF(cTp,cUF,cString)
Local nX   := ( AT(cUF,cString) + 2 )
Local nRet := 0
Local nDiv := 0
If nX > 2
	If cTp == "1" // Valor
		nDiv := 100
	ElseIf cTp == "2" // %
		nDiv := 10000
	EndIf
	nRet := (val(substr(cString,nX,7))/nDiv)
EndIf
Return(nRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ FS_VLRVEI ≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 03/09/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Levanta Valor do Veiculo                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_VLRVEI(nLinha)
VV1->(DbSetOrder(2))
If !Empty(aPedid[nLinha,3]) .and. VV1->(DbSeek(xFilial("VV1")+aPedid[nLinha,3]))
	VV1->(DbSetOrder(1))
	nVlrIni := FGX_VLRSUGV( VV1->VV1_CHAINT , VV1->VV1_CODMAR , VV1->VV1_MODVEI , VV1->VV1_SEGMOD , VV1->VV1_CORVEI , .t. )
Else
	VV1->(DbSetOrder(1))
	VV2->(DbSetOrder(1))
	VV2->(DbSeek(xFilial("VV2")+aPedid[nLinha,4]+aPedid[nLinha,5]))
	nVlrIni := FGX_VLRSUGV( "" , aPedid[nLinha,4] , aPedid[nLinha,5] , VV2->VV2_SEGMOD , aPedid[nLinha,6] , .t. )
EndIf
Return(nVlrIni)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ FS_GERARNF≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 19/09/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Gerar NF de Bonus                                           ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_GERARNF()
Local cQuery    := ""
Local cNamVQ1   := RetSQLName("VQ1")
Local cFilVQ1   := xFilial("VQ1")
Local cFilSF2   := xFilial("SF2")
Local cQAlSQL   := "ALIASSQL"
Local cNamVZQ   := RetSQLName("VZQ")
Local cFilVZQ   := xFilial("VZQ")
Local cNUMNFI   := ""
Local aBonusTot := {}
Local aReturTot := {}
Local ni        := 0
Local aVetCb    := {}
Local aVetIt    := {}
Local aNF       := {}
Local aRet      := {}
Local aParamBox := {}
Local cOBSNFC   := ""
Local lOk       := .f.
//
Local aTipCli   := X3CBOXAVET("A1_TIPO","0")
Local aIndPre   := X3CBOXAVET("VV0_INDPRE","0")
//
Local nSelBon   := 0 // Bonus selecionados
Local nSelRet   := 0 // Retornos selecionados
Local nSelDiv   := 0 // Divergencia dos selecionados
//
Local cRetAux   := "INICIAL"
Local cNFSAux   := ""
//
Local aBON      := {}
Local nCntFor   := 0
Local aObjects  := {} , aPos := {} , aInfo := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
//
Private	cObserv	:= "" // Observacao da NF
//
DbSelectArea("VQ0")
For ni := 1 to len(aPedid)
	If aPedid[ni,17] > 0
		DbGoTo(aPedid[ni,17])
		cNUMNFI := ""
		If !Empty(VQ0->VQ0_FILATE+VQ0->VQ0_NUMATE)
			DbSelectArea("VV0")
			DbSetOrder(1)
			If DbSeek(VQ0->VQ0_FILATE+VQ0->VQ0_NUMATE) .and. !Empty(VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
				cNUMNFI := VV0->VV0_NUMNFI+"-"+ FGX_UFSNF(VV0->VV0_SERNFI)
			EndIf
		EndIf
		cQuery := "SELECT VQ1_STATUS , VQ1_CODBON , VQ1_VLRINI , VQ1_DESCON , VQ1_DESTRI , "
		cQuery += "VQ1_DESCDC , VQ1_DESTAT , VQ1_VLRBAS , VQ1_PERVLR , VQ1_VLRTOT , "
		cQuery += "VQ1_NUMNFI , VQ1_SERNFI , R_E_C_N_O_ RECVQ1 "
		cQuery += "FROM "+cNamVQ1+" "
		cQuery += "WHERE VQ1_FILIAL='"+xFilial("VQ1")+"' AND VQ1_CODIGO='"+VQ0->VQ0_CODIGO+"' AND VQ1_NUMNFI=' ' AND VQ1_STATUS='2' AND D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			aAdd(aBonusTot,{ .f. ,;
							"oS"+( cQAlSQL )->( VQ1_STATUS ) ,;
							( cQAlSQL )->( VQ1_CODBON ) ,;
							( cQAlSQL )->( VQ1_VLRTOT ) ,;
							VQ0->VQ0_NUMPED ,;
							VQ0->VQ0_DATPED ,;
							VQ0->VQ0_CHASSI ,;
							VQ0->VQ0_CODMAR ,;
							VQ0->VQ0_MODVEI ,;
							VQ0->VQ0_CORVEI ,;
							VQ0->VQ0_FILATE ,;
							VQ0->VQ0_NUMATE ,;
							cNUMNFI ,;
							( cQAlSQL )->( RECVQ1 ) })
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		DbSelectArea("VQ0")
	EndIf
Next
If len(aBonusTot) <= 0
	MsgStop(STR0056,STR0050) // Para gerar NF, antes sera necessario incluir Bonus e/ou liberalo(s) os registros desejados! / Atencao
	Return()
EndIf
//
cQuery := "SELECT VQ4.VQ4_RETUID , VQ4.VQ4_VLRTOT , VQ4.VQ4_NUMNFI , VQ4.VQ4_SERNFI , VQ4.VQ4_CIACGC "
cQuery += "FROM "+RetSQLName("VQ4")+" VQ4 "
cQuery += "WHERE VQ4.VQ4_FILIAL='"+xFilial("VQ4")+"' AND VQ4.VQ4_TIPREG='2' AND VQ4.VQ4_TIPNFI='2' AND VQ4.D_E_L_E_T_=' ' ORDER BY VQ4.VQ4_RETUID , VQ4.VQ4_NUMNFI , VQ4.VQ4_SERNFI "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	If FM_SQL("SELECT R_E_C_N_O_ FROM "+cNamVQ1+" WHERE VQ1_FILIAL='"+cFilVQ1+"' AND VQ1_RETUID='"+( cQAlSQL )->( VQ4_RETUID )+"' AND D_E_L_E_T_=' '") <= 0
		If cRetAux <> ( cQAlSQL )->( VQ4_RETUID )
			cRetAux := ( cQAlSQL )->( VQ4_RETUID )
			aAdd(aReturTot,{ .f. , cRetAux , ( cQAlSQL )->( VQ4_VLRTOT ) , "" , ( cQAlSQL )->( VQ4_CIACGC ) })
		EndIf
		cNFSAux := Alltrim(( cQAlSQL )->( VQ4_NUMNFI ))+"-"+ FGX_UFSNF(( cQAlSQL )->( VQ4_SERNFI ))
		If ( cNFSAux <> "-" ) .and. !( cNFSAux $ aReturTot[len(aReturTot),4] )
			aReturTot[len(aReturTot),4] += IIf(!Empty(aReturTot[len(aReturTot),4]),", ","")+cNFSAux
		EndIf
	EndIf
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
If len(aReturTot) <= 0
	aAdd(aReturTot,{ .f. , "" , 0 , "" , "" })
EndIf
//
// TELA SELECIONAR BONUS LIBERADOS
For nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.9)
Next
//
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
AAdd( aObjects, { 0 , 50 , .T. , .T. } ) // ListBox Bonus
AAdd( aObjects, { 0 , 50 , .T. , .T. } ) // ListBox Retornos ( Liberacao de Bonus )
AAdd( aObjects, { 0 , 12 , .T. , .F. } ) // Totalizadores
aPos := MsObjSize( aInfo, aObjects )
//
DEFINE MSDIALOG oVM190BON TITLE STR0076 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Selecao de Bonus para Geracao de NF
//
@ aPos[1,1]+000,aPos[1,2]+000 LISTBOX oLbBONTOT FIELDS ;
							HEADER "","",RetTitle("VQ1_CODBON"),STR0062,STR0009,STR0010,RetTitle("VQ0_CHASSI"),RetTitle("VQ0_CODMAR"),RetTitle("VQ0_MODVEI"),RetTitle("VQ0_CORVEI"),STR0017,RetTitle("VQ0_NUMATE"),STR0034 ;
							COLSIZES 10,10,70,40,35,35,80,30,50,40,50,45,50 ;
							SIZE aPos[1,4],aPos[1,3]-aPos[1,1] OF oVM190BON PIXEL ;
							ON DBLCLICK VM190DBLBON(oLbBONTOT:nAt,@aBonusTot,@nSelBon,@nSelRet) 
oLbBONTOT:SetArray(aBonusTot)
oLbBONTOT:bLine := { || { 	IIf(aBonusTot[oLbBONTOT:nAt,01],oLBTIK,oLBNO) ,;
							&(aBonusTot[oLbBONTOT:nAt,02]) ,;
							aBonusTot[oLbBONTOT:nAt,03] +" - "+ FM_SQL("SELECT VZQ_DESCRI FROM "+cNamVZQ+" WHERE VZQ_FILIAL='"+cFilVZQ+"' AND VZQ_CODBON='"+aBonusTot[oLbBONTOT:nAt,03]+"' AND D_E_L_E_T_=' '") ,;
							FG_AlinVlrs(Transform(aBonusTot[oLbBONTOT:nAt,04],"@E 999,999,999.99")) ,;
							aBonusTot[oLbBONTOT:nAt,05] ,;
							Transform(aBonusTot[oLbBONTOT:nAt,06],"@D") ,;
							aBonusTot[oLbBONTOT:nAt,07] ,;
							aBonusTot[oLbBONTOT:nAt,08] ,;
							aBonusTot[oLbBONTOT:nAt,09] ,;
							aBonusTot[oLbBONTOT:nAt,10] ,;
							aBonusTot[oLbBONTOT:nAt,11] ,;
							aBonusTot[oLbBONTOT:nAt,12] ,;
							aBonusTot[oLbBONTOT:nAt,13] }}
//
@ aPos[2,1]+000,aPos[2,2]+000 LISTBOX oLbRETTOT FIELDS ;
							HEADER "",STR0089,STR0090,STR0091 ;
							COLSIZES 10,50,40,400 SIZE aPos[2,4],aPos[2,3]-aPos[2,1] OF oVM190BON PIXEL ;
							ON DBLCLICK VM190DBLRET(oLbRETTOT:nAt,@aReturTot,@nSelBon,@nSelRet,@nSelDiv) 
oLbRETTOT:SetArray(aReturTot)
oLbRETTOT:bLine := { || { 	IIf(aReturTot[oLbRETTOT:nAt,01],oLBTIK,oLBNO) ,;
							aReturTot[oLbRETTOT:nAt,02] ,;
							FG_AlinVlrs(Transform(aReturTot[oLbRETTOT:nAt,03],"@E 999,999,999.99")) ,;
							aReturTot[oLbRETTOT:nAt,04] }}
//
ni := ( aPos[3,4] / 14 )
@ aPos[3,1]+001,(ni*00)+004 SAY (STR0092+": ") OF oVM190BON PIXEL COLOR CLR_BLUE // Bonus selecionados
@ aPos[3,1]+000,(ni*02)+004 MSGET oSelBon VAR nSelBon PICTURE "@E 999,999,999.99" SIZE (ni*2),08 OF oVM190BON PIXEL HASBUTTON WHEN .f.
@ aPos[3,1]+001,(ni*05)+004 SAY (STR0093+": ") OF oVM190BON PIXEL COLOR CLR_BLUE // Retorno selecionado
@ aPos[3,1]+000,(ni*07)+004 MSGET oSelRet VAR nSelRet PICTURE "@E 999,999,999.99" SIZE (ni*2),08 OF oVM190BON PIXEL HASBUTTON WHEN .f.
@ aPos[3,1]+001,(ni*10)+004 SAY (STR0094+": ") OF oVM190BON PIXEL COLOR CLR_BLUE // Divergencia
@ aPos[3,1]+000,(ni*12)+004 MSGET oSelDiv VAR nSelDiv PICTURE "@E 999,999,999.99" SIZE (ni*2),08 OF oVM190BON PIXEL HASBUTTON WHEN .f.
//
ACTIVATE MSDIALOG oVM190BON CENTER ON INIT EnchoiceBar(oVM190BON,{|| IIf(FS_VALOK(nSelBon,nSelRet,nSelDiv),(lOk:=.t.,oVM190BON:End()),.t.) },{|| oVM190BON:End() } ,, {{"PMSCOLOR",{|| FS_LEGVM190() },(STR0042)}}) // Legenda
//
If lOk
	//
	aNF := {space(TamSX3("A1_COD")[1]),space(TamSX3("A1_LOJA")[1]),space(TamSX3("A3_COD")[1]),space(TamSX3("E4_CODIGO")[1]),space(TamSX3("B1_COD")[1]),space(TamSX3("E1_NATUREZ")[1]),space(TamSX3("E1_PORTADO")[1]),"",""}
	cQuery := "SELECT SF2.F2_CLIENTE , SF2.F2_LOJA , SF2.F2_VEND1 , SF2.F2_COND , SD2.D2_COD FROM "+RetSQLName("VQ1")+" VQ1 "
	cQuery += "JOIN "+RetSQLName("SF2")+" SF2 ON ( SF2.F2_FILIAL=VQ1.VQ1_FILNFI AND SF2.F2_DOC=VQ1.VQ1_NUMNFI AND SF2.F2_SERIE=VQ1.VQ1_SERNFI AND SF2.D_E_L_E_T_=' ' ) "
	cQuery += "JOIN "+RetSQLName("SD2")+" SD2 ON ( SD2.D2_FILIAL=VQ1.VQ1_FILNFI AND SD2.D2_DOC=VQ1.VQ1_NUMNFI AND SD2.D2_SERIE=VQ1.VQ1_SERNFI AND SD2.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VQ1.VQ1_FILIAL='"+cFilVQ1+"' AND VQ1.VQ1_NUMNFI<>' ' AND VQ1.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY VQ1.VQ1_CODIGO DESC"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	If !( cQAlSQL )->( Eof() )
		aNF[1] := ( cQAlSQL )->( F2_CLIENTE )
		aNF[2] := ( cQAlSQL )->( F2_LOJA )
		aNF[3] := ( cQAlSQL )->( F2_VEND1 )
		aNF[4] := ( cQAlSQL )->( F2_COND )
		aNF[5] := ( cQAlSQL )->( D2_COD )
	EndIf
	( cQAlSQL )->( DbCloseArea() )
	// CARREGAR CLIENTE / LOJA  -> CNPJ DO RETORNO
	For ni := 1 to len(aReturTot)
		If aReturTot[ni,1]
			cRetAux := aReturTot[ni,2] // Nro do ReturnID ( VQ4_RETUID / VQ1_RETUID )
			If !Empty(aReturTot[ni,5])
				SA1->(DbSetOrder(3))
				If SA1->(DbSeek(xFilial("SA1")+aReturTot[ni,5]))
					aNF[1] := SA1->A1_COD
					aNF[2] := SA1->A1_LOJA
				EndIf
				SA1->(DbSetOrder(1))
			EndIf
		EndIf
	Next
	//
	If !Empty(aNF[1])
		aNF[8] := FM_SQL("SELECT A1_TIPO FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+aNF[1]+"' AND A1_LOJA='"+aNF[2]+"' AND D_E_L_E_T_=' '")
	EndIf
	// 
	M->C5_ESTPRES := ""
	DbSelectArea("VQ1")
	AADD(aParamBox,{ 1,RetTitle("C5_CLIENTE"),aNF[1],"@!",'VM190CLI(1)'                                              ,"SA1","",45,.t.}) // Cliente
	AADD(aParamBox,{ 1,RetTitle("C5_LOJACLI"),aNF[2],"@!",'VM190CLI(2)'                                              ,""   ,"",25,.t.}) // Loja
	AADD(aParamBox,{ 1,RetTitle("C5_VEND1"),aNF[3],"@!",'Empty(MV_PAR03) .or. FG_Seek("SA3","MV_PAR03",1)'         ,"SA3","",45,.t.}) // Vendedor 1
	AADD(aParamBox,{ 1,RetTitle("C5_CONDPAG"),aNF[4],"@!",'Empty(MV_PAR04) .or. FG_Seek("SE4","MV_PAR04",1)'         ,"SE4","",35,.t.}) // Cond. Pagto
	AADD(aParamBox,{ 1,STR0061,aNF[5],"@!",'Empty(MV_PAR05) .or. FG_Seek("SB1","MV_PAR05",1)'         ,"SB1","",70,.t.}) // Servico - Produto
	AADD(aParamBox,{ 1,STR0062,nSelBon,"@E 999,999,999.99",""                                         ,"",".f.",70,.t.}) // Vlr
	AADD(aParamBox,{ 1,RetTitle("C5_NATUREZ"),aNF[6],"@!",'vazio().or.FG_Seek("SED","MV_PAR07",1,.f.)',"SED","",45,.f.}) // Natureza
	AADD(aParamBox,{ 1,RetTitle("C5_BANCO"),aNF[7],"@!",'',"","",30,.f.}) // Banco
	aAdd(aParamBox,{ 2,RetTitle("C5_TIPOCLI"),aNF[8],aTipCli,110,"",.f.}) // Tipo Cliente
	aAdd(aParamBox,{ 2,RetTitle("C5_INDPRES"),aNF[9],aIndPre,110,"",.f.}) // PresenÁa Com
	AADD(aParamBox,{ 1,RetTitle("C5_MENPAD"),space(TamSx3('C5_MENPAD')[1]),"@!","texto().Or.Vazio()","SM4","",  30,.F.}) // Mens.Padrao
	AADD(aParamBox,{ 1,RetTitle("C5_MENNOTA"),space(TamSx3('C5_MENNOTA')[1]),"@!",""                 ,   "","", 100,.F.}) // Mens.p/ Nota
	AADD(aParamBox,{11,STR0073,"","","",.f.}) // Observacao NF
	AADD(aParamBox,{ 1,RetTitle("C5_ESTPRES"),space(TamSx3('C5_ESTPRES')[1]),"@!","(M->C5_ESTPRES := MV_PAR14)","12","", 20,.F.}) // UF Prestacao
	AADD(aParamBox,{ 1,RetTitle("C5_MUNPRES"),space(TamSx3('C5_MUNPRES')[1]),"@!",'vazio().or.FG_SEEK("CC2","MV_PAR14+MV_PAR15",1,.F.,"MV_PAR16","CC2_MUN")',"CC2SC5","", 50,.F.}) // Mun.Prest.  
	AADD(aParamBox,{ 1,RetTitle("C5_DESCMUN"),"","@!","","",".f.", 100,.F.}) // Mun.Prest.
	If ParamBox(aParamBox,STR0040,@aRet,{ |x| FS_VLDGERNF() },,,,,,,.f.) // Gerar NF          
		aVetCb := {aRet[1],aRet[2],aRet[3],aRet[4],aRet[7],aRet[8], aRet[13], aRet[12] /*obs padrao*/, aRet[11] /*obs nota*/ }
		aAdd(aVetIt,{aRet[5],aRet[6]})
		cObserv := aRet[13]
		aNF := FMX_GERNFS(aVetCb,aVetIt,.t.,cDMSPrefOri,,aRet[9],aRet[10],aRet[14],aRet[15])
		If len(aNF) > 0 .and. !Empty(aNF[1])
			Begin Transaction
			DbSelectArea("VQ1")
			For ni := 1 to len(aBonusTot)
				If aBonusTot[ni,1]
					DbGoTo(aBonusTot[ni,14])
					RecLock("VQ1",.f.)
					VQ1->VQ1_FILNFI := cFilSF2
					VQ1->VQ1_NUMNFI := aNF[1]
					VQ1->VQ1_SERNFI := aNF[2]
					if ColumnPos("VQ1_SDOC") > 0
						VQ1->VQ1_SDOC := FGX_UFSNF(aNF[2])
					Endif
					VQ1->VQ1_DATNFI := dDataBase
					VQ1->VQ1_STATUS := "3" // NF Gerada
					VQ1->VQ1_OBSNFC := cOBSNFC
					VQ1->VQ1_RETUID := cRetAux
					MsUnLock()

					VEM1900098_VerificaPEVQ1(1)

					If Empty(cOBSNFC) .and. !Empty(aRet[13])
						MSMM(VQ1->VQ1_OBSNFC,TamSx3("VQ1_OBSNFM")[1],,aRet[13],1,,,"VQ1","VQ1_OBSNFC")
						cOBSNFC := VQ1->VQ1_OBSNFC
					EndIf
				EndIf
			Next
			End Transaction
		EndIf
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		dbSelectArea("SX6")
		MsRUnLock()
		//
		MsUnlockAll()
		//
	EndIf
EndIf
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥FS_VLDGERNF≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 20/01/17 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Validacao da Parambox para geraÁ„o de NF                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_VLDGERNF()
Local lRet := .t.
Local cMsg := STR0125+CHR(13)+CHR(10) // Necessario preencher o(s) campo(s) abaixo:
If Empty(MV_PAR15) .and. !Empty(MV_PAR14)
	lRet := .f.
	cMsg += CHR(13)+CHR(10)+RetTitle("C5_MUNPRES")
EndIf
If !lRet
	MsgStop(cMsg,STR0050) // Atencao
EndIf
Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ VM190CLI  ≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 01/04/15 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Validacao do Cliente                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function VM190CLI(nTp)
Local lRet := .t.
//
Local oCliente   := DMS_Cliente():New()
//
If nTp == 1 // Codigo Cliente
	If !Empty(MV_PAR01)
		If !(MV_PAR01 == SA1->A1_COD )
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek(xFilial("SA1")+MV_PAR01)
				If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
					lRet := .f.
				Else
					MV_PAR02 := SA1->A1_LOJA
					MV_PAR09 := SA1->A1_TIPO
				EndIf
			Else
				lRet := .f.
			EndIf
		Else
			If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
				lRet := .f.
			Else
				MV_PAR02 := SA1->A1_LOJA
				MV_PAR09 := SA1->A1_TIPO
			EndIf
		EndIf
	EndIf
ElseIf nTp == 2 // Codigo/Loja Cliente
	If !Empty(MV_PAR01+MV_PAR02)
		DbSelectArea("SA1")
		DbSetOrder(1)
		If DbSeek(xFilial("SA1")+MV_PAR01+MV_PAR02)
			If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
				lRet := .f.
			Else
				MV_PAR09 := SA1->A1_TIPO
			EndIf
		Else
			lRet := .f.
		EndIf
	EndIf
EndIf
Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ FS_VALOK  ≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 12/11/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Validacao do OK da Tela                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_VALOK(nSelBon,nSelRet,nSelDiv)
Local lRet := .t.
If nSelBon == 0 .or. nSelRet == 0 // Nao selecionou o Bonus
	MsgInfo(STR0053,STR0050) // Necessario selecionar os registros! / Atencao
	lRet := .f.
Else
	lRet := .f.
	If nSelDiv == 0 // Nao ha divergencia
		lRet := .t.
	Else // com divergencia entre Retorno e Bonus selecionados
		If MsgYesNo(STR0095,STR0050) // Ha divergencia entre o Retorno e os Bonus selecionados. NF sera gerada no valor total dos Bonus selecionados. Deseja continuar? / Atencao
			lRet := .t.
		EndIf
	EndIf
EndIf
Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ FS_ATUATE ≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 17/07/14 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Botao de Atualiza Atendimento ( 0 = When / 1 = Atualiza )   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_ATUATE(nTp,nLinha,nMaxDias)
Local lRet    := .f.
Local cQuery  := ""
Local cNamVV9 := RetSQLName("VV9")
Local cNamVVA := RetSQLName("VVA")
Local nRecVVA := 0
If !Empty(aPedid[nLinha,13]+aPedid[nLinha,14])
	If nTp == 0  // WHEN do botao [ Atualiza Atendimento ]
		If Empty(aPedid[nLinha,18])
			lRet := .t.
		Else
			VV0->(DbSetOrder(1))
			If VV0->(MsSeek(aPedid[nLinha,13]+aPedid[nLinha,14]))
				If VV0->VV0_TIPFAT <> "2"
					SF2->(DbSetOrder(1))
					If SF2->(MsSeek(VV0->VV0_FILIAL+VV0->VV0_NUMNFI+VV0->VV0_SERNFI))
						cDia := "01"
						cMes := Alltrim(str(val(substr(dtoc(dDataBase),4,2))-nMaxDias))
						if cMes == "01"
							cMes := "12"
						Endif
						cAno := substr(dtoc(dDataBase),7,4)
						dData := ctod(cDia+"/"+cMes+"/"+cAno)
						If SF2->F2_EMISSAO >= dData .and. SF2->F2_EMISSAO <= dDataBase
							lRet := .t.
						EndIf
					Else
						lRet := .t.
					EndIf
				Else
					lRet := .t.
				EndIf
			EndIf
		EndIf
	Else // Atualizacao do Atendimento ( execucao do botao )
		VV9->(DbSetOrder(1))
		If VV9->(DbSeek(aPedid[nLinha,13]+aPedid[nLinha,14]))
			If !Softlock("VV9")
				Return .f.
			EndIf
			VV0->(DbSetOrder(1))
			If VV0->(DbSeek(aPedid[nLinha,13]+aPedid[nLinha,14]))
				VQ0->(DbGoTo(aPedid[nLinha,17]))
				cQuery  := "SELECT VVA.R_E_C_N_O_ FROM "+cNamVVA+" VVA "
				cQuery  += "JOIN "+cNamVV9+" VV9 ON ( VV9.VV9_FILIAL=VVA.VVA_FILIAL AND VV9.VV9_NUMATE=VVA.VVA_NUMTRA AND VV9.VV9_STATUS<>'C' AND VV9.D_E_L_E_T_=' ' ) "
				cQuery  += "WHERE VVA.VVA_FILIAL='"+aPedid[nLinha,13]+"' AND VVA.VVA_NUMTRA='"+aPedid[nLinha,14]+"' AND VVA.VVA_CHAINT='"+VQ0->VQ0_CHAINT+"' AND VVA.D_E_L_E_T_=' '"
				nRecVVA := FM_SQL(cQuery)
				VVA->(DbGoTo(nRecVVA))
				VV2->(DbSetOrder(1))
				VV2->(DbSeek(xFilial("VV2")+VVA->VVA_CODMAR+VVA->VVA_MODVEI))
				VEIXX014(aPedid[nLinha,14],VVA->VVA_CODMAR,VV2->VV2_GRUMOD,VVA->VVA_MODVEI,4,.t.,"0",nRecVVA,.t.)
			EndIf
			MsUnlockAll()
		EndIf
	EndIf
EndIf
Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥FS_LEGVM190≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 20/08/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Legenda                                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_LEGVM190()
Local aLegenda := {	{"BR_AMARELO" , STR0043 },; // Gravados
{"BR_VERDE"   , STR0044 },; // Liberados para faturar
{"BR_AZUL"    , STR0045 },; // NF gerada
{"BR_VERMELHO", STR0046 },; // Cancelado
{'',"----------------------------------------------"},;
{"PMSEDT4"    , STR0102 }}  // Bonus selecionado no Atendimento

BrwLegenda(STR0042,STR0029,aLegenda) // Legenda / Bonus
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao ≥  FS_GERCFG ≥ Autor ≥ Andre Vinicius Gati    ≥ Data ≥ 26/11/14 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Escolhe cnofiguraÁ„o do veÌculo para pedido                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_GERCFG()
Local aCfgs      := {}
Local cCfgPacote := ""
nRecnoVQ0 :=  oLbPedid:aArray[oLbPedid:nAt][17] // RECVQ0
If nRecnoVQ0 > 0
	VQ0->(DbGoto(nRecnoVQ0))
	VV1->(DbSetOrder(1))
	VV1->(DbSeek( xFilial('VV1') + VQ0->VQ0_CHAINT ))
	If GetNewPar("MV_MIL0168","0") == "1" // Trabalha com Pacote de ConfiguraÁ„o ? 
		aAuxC := VEIA242( VV1->VV1_CODMAR , VV1->VV1_MODVEI , VV1->VV1_SEGMOD , VV1->VV1_CHAINT , ( GetNewPar("MV_MIL0167","1") == "1" ) ) // MV_MIL0167 - GravaÁ„o do Valor Sugerido: 1=Sim (default) / 0=N„o
		If len(aAuxC) > 0
			aCfgs := aAuxC[4]
			VA380GRVCFG( VV1->VV1_CHAINT, aCfgs, aAuxC[3] , aAuxC[1] )
		EndIf
	Else
		VV2->(DbSeek( xFilial('VV2') + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_SEGMOD ))
		aAuxC := VA380CONFIG(VV1->VV1_CHAINT, VV1->VV1_CODMAR,  VV2->VV2_GRUMOD, @aCfgs , VV1->VV1_MODVEI , VV1->VV1_SEGMOD )
		if aAuxC == nil
			return
		else
			aCfgs := aAuxC[1]
			VA380GRVCFG( VV1->VV1_CHAINT, aCfgs, aAuxC[2] )
		EndIf
	EndIf
Else
	MsgInfo(STR0106,STR0050) // Nenhum pedido selecionado, por favor selecione um pedido ou inclua um novo (Atenc„o)
EndIf
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ FS_RELCHA≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 05/02/15 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Relaciona Chassi / Desfazer relacionamento                  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_RELCHA(nLinVQ0)
Local cGruVei     := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local lRet        := .f.
Local cChaInt     := ""
Local cSQL        := ""
Local cQAlVV1     := "SQLVV1"
Local aVV1        := {}
Local aFilAtu     := FWArrFilAtu()
Local aSM0        := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt  := cFilAnt
Local nCont       := 0
Local cFilVVA     := "("
Local cFilVVG     := "("
Local lVV1Comp    := .t.
Local cFilVV1     := xFilial("VV1")
Local nRecNo      := 0
Local lVerVV1Mov  := ( GetNewPar("MV_MIL0061","N") $ "S/1" ) // Pedido deixar relacionamento com Veiculos que ja possuem Movimentacoes Entrada/Saida
Local cFilRel     := ""
Local cTpRelac    := "" // R-elaciona Chassi / D-esfazer Relacionamento de Chass
Local lVQ0_FILREL := ( VQ0->(ColumnPos("VQ0_FILREL")) > 0 ) // Filial Entrada Relacionada - controle interno para possibilitar desfazer o relacionamento do Chassi
Local lVQ0_SEGMOD := ( VQ0->(ColumnPos("VQ0_SEGMOD")) > 0 )
DbSelectArea("VQ0")
If Empty(aPedid[nLinVQ0,1]) // Caso esteja vazio o listbox
	Return(lRet)
EndIf
DbGoto(aPedid[nLinVQ0,17])
If Empty(VQ0->VQ0_CHASSI)
	cTpRelac := "R"  // Relaciona Chassi
Else
	If lVQ0_FILREL .and. !Empty(VQ0->VQ0_FILREL) // Filial Entrada Relacionada - controle interno para possibilitar desfazer o relacionamento do Chassi
		If MsgYesNo(STR0130,STR0050) // Deseja desfazer o relacionamento entre o CHASSI e este Pedido? / Atencao
			cTpRelac := "D" // Desfazer Relacionamento de Chassi
		EndIf
	Else
		MsgStop(STR0131,STR0050) // Impossivel desfazer relacionamento entre o CHASSI e este Pedido. / Atencao
	EndIf
EndIf
If !Empty(cTpRelac)
	For nCont := 1 to Len(aSM0)
		cFilAnt := aSM0[nCont]
		If lVV1Comp .and. cFilVV1 <> xFilial("VV1") // Verifica se o VV1 nao eh compartilhado
			lVV1Comp := .f.
		EndIf
		cFilVVA += "'"+xFilial("VVA")+"',"
		cFilVVG += "'"+xFilial("VVG")+"',"
	Next
	cFilAnt := cBkpFilAnt
	cFilVVA := left(cFilVVA,len(cFilVVA)-1)+")"
	cFilVVG := left(cFilVVG,len(cFilVVG)-1)+")"
	cChaInt := VQ0->VQ0_CHAINT
	//
	cSQL := "SELECT VVA.R_E_C_N_O_ FROM "+RetSqlName("VVA")+" VVA "
	cSQL += "JOIN "+RetSqlName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VVA.VVA_FILIAL AND VV9.VV9_NUMATE=VVA.VVA_NUMTRA AND VV9.VV9_STATUS<>'C' AND VV9.D_E_L_E_T_=' ' ) "
	cSQL += "WHERE "
	If lVV1Comp // VV1 Compartilhado
		cSQL += "VVA.VVA_FILIAL IN "+cFilVVA+" AND "
	Else // VV1 Exclusivo
		cSQL += "VVA.VVA_FILIAL='"+xFilial("VVA")+"' AND "
	EndIf
	cSQL += "VVA.VVA_CHAINT='"+VQ0->VQ0_CHAINT+"' AND VVA.D_E_L_E_T_=' '"
	nRecNo := FM_SQL(cSQL)
	If nRecNo > 0
		DbSelectArea("VVA")
		DbGoTo(nRecNo)
		MsgInfo(STR0110+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0017+": "+VVA->VVA_FILIAL+CHR(13)+CHR(10)+RetTitle("VQ0_NUMATE")+": "+VVA->VVA_NUMTRA,STR0050) // Ja existe Atendimento para esse Pedido! / Filial Atend. / Atendimento / Atencao
		Return(lRet)
	EndIf
	//
	If cTpRelac == "R" // Relaciona Chassi
		If !Empty(VQ0->VQ0_CHASSI)
			MsgInfo(STR0107,STR0050) // Chassi ja relacionado para esse Pedido! / Atencao
			Return(lRet)
		EndIf
		DbSelectArea("VV1")
		DbSetOrder(1)
		DbSeek(xFilial("VV1")+VQ0->VQ0_CHAINT)
		cSQL := "SELECT DISTINCT VV1.VV1_CHASSI , VV1.VV1_CHAINT , VV1.VV1_PLAVEI , VV1.VV1_FABMOD , VV1.VV1_CODFRO , VV1.VV1_SERMOT , VV1.VV1_SITVEI , "
		cSQL += "VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV2.VV2_DESMOD , VV1.VV1_CORVEI , VVC.VVC_DESCRI , VV1.VV1_PROATU , VV1.VV1_LJPATU , SA1.A1_NOME "
		cSQL += "FROM "+RetSqlName("VV1")+" VV1 "
		cSQL += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.VV2_SEGMOD=VV1.VV1_SEGMOD AND VV2.D_E_L_E_T_=' ' ) "
		cSQL += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VV1.VV1_PROATU AND SA1.A1_LOJA=VV1.VV1_LJPATU AND SA1.D_E_L_E_T_=' ' ) "
		cSQL += "LEFT JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
		cSQL += "LEFT JOIN "+RetSqlName("VQ0")+" VQ0 ON ( VQ0.VQ0_FILIAL='"+xFilial("VQ0")+"' AND VQ0.VQ0_CHAINT=VV1.VV1_CHAINT AND VQ0.D_E_L_E_T_=' ' ) "
		cSQL += "WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CODMAR='"+VV1->VV1_CODMAR+"' AND VV1.VV1_MODVEI='"+VV1->VV1_MODVEI+"' AND VV1.VV1_SEGMOD='"+VV1->VV1_SEGMOD+"' AND VV1.VV1_CORVEI='"+VV1->VV1_CORVEI+"' AND VV1.VV1_CHASSI<>' ' AND VQ0.VQ0_CHAINT IS NULL AND VV1.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cQAlVV1, .F., .T. )
		Do While !( cQAlVV1 )->( Eof())
			nRecNo := 0
			// Verificar Movimentacao de Entrada/Saida //
			If !lVerVV1Mov // Nao Mostra Veiculos com Movimentacoes
				If lVV1Comp // VV1 Compartilhado
					cSQL := "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("VVG")+" WHERE VVG_FILIAL IN "+cFilVVG+" AND VVG_CHAINT='"+( cQAlVV1 )->( VV1_CHAINT )+"' AND D_E_L_E_T_=' '"
					cSQL += " UNION ALL "
					cSQL += "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("VVA")+" WHERE VVA_FILIAL IN "+cFilVVA+" AND VVA_CHAINT='"+( cQAlVV1 )->( VV1_CHAINT )+"' AND D_E_L_E_T_=' '"
				Else // VV1 Exclusivo
					cSQL := "SELECT R_E_C_N_O_ FROM "+RetSqlName("VVG")+" WHERE VVG_FILIAL='"+xFilial("VVG")+"' AND VVG_CHAINT='"+( cQAlVV1 )->( VV1_CHAINT )+"' AND D_E_L_E_T_=' '"
					cSQL += " UNION ALL "
					cSQL += "SELECT R_E_C_N_O_ FROM "+RetSqlName("VVA")+" WHERE VVA_FILIAL='"+xFilial("VVA")+"' AND VVA_CHAINT='"+( cQAlVV1 )->( VV1_CHAINT )+"' AND D_E_L_E_T_=' '"
				EndIf
				nRecNo := FM_SQL(cSQL)
			EndIf
			If nRecNo <= 0
				Aadd(aVV1,{	( cQAlVV1 )->( VV1_CHAINT ),;
							( cQAlVV1 )->( VV1_PLAVEI ),;
							( cQAlVV1 )->( VV1_CHASSI ),;
							( cQAlVV1 )->( VV1_CODMAR )+" "+IIf(!Empty(( cQAlVV1 )->( VV2_DESMOD )),( cQAlVV1 )->( VV2_DESMOD ),( cQAlVV1 )->( VV1_MODVEI )),;
							left(IIf(!Empty(( cQAlVV1 )->( VVC_DESCRI )),( cQAlVV1 )->( VVC_DESCRI ),( cQAlVV1 )->( VV1_CORVEI )),12),;
							( cQAlVV1 )->( VV1_FABMOD ),;
							X3CBOXDESC("VV1_SITVEI",( cQAlVV1 )->( VV1_SITVEI )),;
							( cQAlVV1 )->( VV1_CODFRO ),;
							( cQAlVV1 )->( VV1_SERMOT ),;
							( cQAlVV1 )->( VV1_PROATU )+"-"+( cQAlVV1 )->( VV1_LJPATU )+" "+left(( cQAlVV1 )->( A1_NOME ),25)})
			EndIf
			( cQAlVV1 )->( DbSkip() )
		EndDo
		( cQAlVV1 )->( dbCloseArea() )
		If len(aVV1) > 0
			If FG_POSVV1(aVV1) // Selecionar o Veiculo
				DbSelectArea("VQ0")
				DbGoto(aPedid[nLinVQ0,17])
				If VQ0->VQ0_CHAINT <> VV1->VV1_CHAINT
					RecLock("VQ0",.F.)
					If lVQ0_FILREL
						cFilRel := FM_SQL("SELECT VV1_FILENT FROM "+RetSqlName("VV1")+" WHERE VV1_FILIAL='"+xFilial("VV1")+"' AND VV1_CHASSI='"+VQ0->VQ0_CHAINT+"' AND D_E_L_E_T_=' '")
						If Empty(cFilRel)
							cFilRel := xFilial("SD2")
						EndIf
						VQ0->VQ0_FILREL := cFilRel // Filial Entrada Relacionada - controle interno para possibilitar desfazer o relacionamento do Chassi
					EndIf
					VQ0->VQ0_CHAINT := VV1->VV1_CHAINT
					VQ0->VQ0_CHASSI := VV1->VV1_CHASSI
					MsUnLock()
					DbSelectArea("VV1")
					DbSetOrder(1)
					If DbSeek(xFilial("VV1")+cChaInt) .and. Empty(VV1->VV1_CHASSI)
						RecLock("VV1",.F.,.T.)
						DbDelete()
						MsUnLock()
						DbSelectArea("SB1")
						DbSetOrder(7)
						If DbSeek(xFilial("SB1")+cGruVei+cChaInt)
							RecLock("SB1",.F.,.T.)
							DbDelete()
							MsUnLock()
						EndIf
						DbSetOrder(1)
					EndIf
				Else
					RecLock("VQ0",.F.)
					VQ0->VQ0_CHASSI := VV1->VV1_CHASSI
					MsUnLock()
				EndIf
				MsgAlert(STR0112,STR0050) // Pedido alterado com sucesso! / Atencao
				lRet := .t.
			EndIf
		Else
			MsgInfo(STR0111,STR0050) // Nenhum Chassi pode ser relacionado para este Pedido! / Atencao
			Return(lRet)
		EndIf
	ElseIf cTpRelac == "D" // Desfazer Relacionamento de Chassi
		//
		Inclui := .t.
		//
		DbSelectArea("VV1")
		RegToMemory( "VV1" , .t. , .f. , .t. )
		ConfirmSX8()
		DbSelectArea("VV1")
		RecLock("VV1",.t.)
		FG_GRAVAR("VV1")
		VV1->VV1_FILIAL := xFilial("VV1")
		VV1->VV1_CHASSI := ""
		VV1->VV1_CODMAR := VQ0->VQ0_CODMAR
		VV1->VV1_MODVEI := VQ0->VQ0_MODVEI
		If lVQ0_SEGMOD
			VV1->VV1_SEGMOD := VQ0->VQ0_SEGMOD
		EndIf
		VV1->VV1_CORVEI := VQ0->VQ0_CORVEI
		VV1->VV1_SITVEI := "8" // Pedido
		VV1->VV1_ESTVEI := "0" // Novo
		VV1->VV1_FILENT := VQ0->VQ0_FILREL // Filial Entrada Relacionada - controle interno para possibilitar desfazer o relacionamento do Chassi
		MsUnlock()
		DbSelectArea("VQ0")
		RecLock("VQ0",.f.)
			VQ0->VQ0_CHASSI := ""
			VQ0->VQ0_CHAINT := VV1->VV1_CHAINT
			VQ0->VQ0_FILREL := "" // Filial Entrada Relacionada - controle interno para possibilitar desfazer o relacionamento do Chassi
		MsUnLock()
		//
		MsgAlert(STR0112,STR0050) // Pedido alterado com sucesso! / Atencao
		lRet := .t.
		//
	EndIf
EndIf
DbSelectArea("VQ0")
Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥FS_ATENDTO≥ Autor ≥ Thiago				    ≥ Data ≥ 10/03/15 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Visualizar Atendimento  		                              ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_ATENDTO(cFAtend,cNAtend)
Local cSlvFilAnt := cFilAnt
DbSelectArea("VV9")
DbSetOrder(1)
If DbSeek( cFAtend + left(cNAtend,TamSx3("VV9_NUMATE")[1]) )
	cFilAnt := cFAtend
	VEIXX002(NIL,NIL,NIL,2,)
	cFilAnt := cSlvFilAnt
EndIf
Return(.t.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ FS_OBSVV1≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 27/02/17 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Altera a Descricao e ObservaÁ„o do Veiculo VV1              ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_OBSVV1(cChaInt)
Local aRet      := {}
Local aParamBox := {}
If VV1->(ColumnPos("VV1_DESVEI")) > 0 .and. VV1->(ColumnPos("VV1_OBSVEI")) > 0
	VV1->(DbSetOrder(1))
	If VV1->(DbSeek(xFilial("VV1")+cChaInt))
		AADD(aParamBox,{ 1,RetTitle("VV1_DESVEI"),VV1->VV1_DESVEI,"@!","","","",100,.f.}) // Descricao
		AADD(aParamBox,{11,RetTitle("VV1_OBSVEI"),VV1->VV1_OBSVEI,"","",.f.}) // Observacao
		If ParamBox(aParamBox,STR0126,@aRet,,,,,,,,.f.,.f.) // Obs.M·q./Equip.
			DbSelectArea("VV1")
			RecLock("VV1",.f.)
				VV1->VV1_DESVEI := aRet[1] // Descricao
				VV1->VV1_OBSVEI := aRet[2] // Observacao
			MsUnLock()
		EndIf
	EndIf
EndIf
Return()

/*/{Protheus.doc} VM190BCO
	Chamada da funcao Banco de conhecimento

	@author Manoel Filho
	@since  17/08/2017
	@param 1o - Nro do Pedido
	@param 2o - Chassi do VeÌculo
	@return null
/*/
Function VM190BCO(nReg)
Local cAlias := "VQ0"

Default nReg := 0

DbSelectArea("VQ0")
If nReg > 0
	dbGoTo(nReg)
	nOpc := 4
	FGX_MSDOC(cAlias,nReg,nOpc)
Endif

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ VM190RVZQ≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 08/06/17 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Retorna Descricao e Codigo relacionado ao Bonus tabela VZQ  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function VM190RVZQ(_cNamVZQ,_cFilVZQ,_cCodBon)
Local aRetVZQ     := {"","",""}
Local cQuery      := ""
Local cQAlAux     := "SQLAUX"
Local lVZQ_CDCAMP := ( VZQ->(ColumnPos("VZQ_CDCAMP")) > 0 )
Local lVZQ_EVENTO := ( VZQ->(ColumnPos("VZQ_EVENTO")) > 0 )
//
If !Empty(_cCodBon)
	cQuery := "SELECT VZQ_DESCRI"
	If lVZQ_CDCAMP
		cQuery += " , VZQ_CDCAMP"
	EndIf
	If lVZQ_EVENTO
		cQuery += " , VZQ_EVENTO"
	EndIf
	cQuery += "  FROM "+_cNamVZQ
	cQuery += " WHERE VZQ_FILIAL='"+_cFilVZQ+"'"
	cQuery += "   AND VZQ_CODBON='"+_cCodBon+"'"
	cQuery += "   AND D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
	If !( cQAlAux )->( Eof() )
		aRetVZQ[1] := ( cQAlAux )->( VZQ_DESCRI )
		If lVZQ_CDCAMP
			aRetVZQ[2] := ( cQAlAux )->( VZQ_CDCAMP )
		EndIf
		If lVZQ_EVENTO
			aRetVZQ[3] := ( cQAlAux )->( VZQ_EVENTO )
		EndIf
	EndIf
	( cQAlAux )->( DbCloseArea() )
EndIf
//
Return aRetVZQ

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ VM190EVZS≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 08/06/17 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Verifica se existe relacionamento com o Atendimento/Item    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function VM190EVZS(lVZS_FILATE,lVZS_ITETRA,_cCodBon,_cIteTra)
Local cQuery := ""
cQuery := "SELECT R_E_C_N_O_ AS RECVZS"
cQuery += "  FROM "+RetSqlName("VZS")
cQuery += " WHERE VZS_FILIAL='"+xFilial("VZS")+"'"
cQuery += "   AND VZS_CODBON='"+_cCodBon+"'"
If lVZS_FILATE
	cQuery += " AND VZS_FILATE='"+aPedid[oLbPedid:nAt,13]+"'"
EndIf
cQuery += "   AND VZS_NUMATE='"+aPedid[oLbPedid:nAt,14]+"'"
If lVZS_ITETRA
	cQuery += " AND VZS_ITETRA='"+_cIteTra+"'"
EndIf
cQuery += "   AND D_E_L_E_T_ = ' ' "
Return ( FM_SQL(cQuery) > 0 ) // Existe registro no VZS - Bonus esta selecionado no Atendimento/Item

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥FS_ADD_PED≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 19/07/17 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Adiciona Linha em Branco no Vetor de Pedido                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_ADD_PED(cVet)
Local lVQ0_EVENTO := ( VQ0->(ColumnPos("VQ0_EVENTO")) > 0 )
aAdd(&(cVet),{ 	space(TamSX3("VQ0_NUMPED")[1]) ,;
				"" ,;
				space(TamSX3("VQ0_CHASSI")[1]) ,;
				space(TamSX3("VQ0_CODMAR")[1]) ,;
				space(TamSX3("VQ0_MODVEI")[1]) ,;
				space(TamSX3("VQ0_CORVEI")[1]) ,;
				"" ,;
				0 ,;
				0 ,;
				0 ,;
				"" ,;
				"" ,;
				space(TamSX3("VQ0_FILATE")[1]) ,;
				space(TamSX3("VQ0_NUMATE")[1]) ,;
				"" ,;
				space(TamSX3("VQ0_CONFIG")[1]) ,;
				0 ,;
				"" ,;
				space(TamSX3("VQ0_FILPED")[1]) ,;
				"" ,;
				space(TamSX3("VQ0_OBSMEM")[1]) ,;
				space(TamSX3("VV1_FILENT")[1]) ,;
				0 ,;
				"" ,;
				"" ,;
				"" ,;
				"N" ,;
				"" ,;
				"" ,;
				"" ,;
				space(IIf(lVQ0_EVENTO,TamSX3("VQ0_EVENTO")[1],10)) ,;
				" " ,;
				space(TamSX3("VV1_SEGMOD")[1]) })
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥FS_ADD_BON≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 19/07/17 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Adiciona Linha em Branco no Bonus                           ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_ADD_BON(cVet,cCor)
aAdd(&(cVet),{  cCor ,;
				space(TamSX3("VQ1_CODBON")[1]) ,;
				0 ,;
				0 ,;
				0 ,;
				0 ,;
				0 ,;
				0 ,;
				0 ,;
				0 ,;
				"" ,;
				"" ,;
				"" ,;
				0 ,;
				.f. ,;
				0 ,;
				0 ,;
				"" ,;
				.f. ,;
				"" })
Return

/*/{Protheus.doc} VM190DBLBON

Duplo clique no ListBox de Bonus na tela de Geracao de NF de Comissao

@author Andre Luis Almeida
@since  11/10/2017
@param  Linha no ListBox de Bonus possiveis , Vetor com os Bonus possiveis , Vlr.Bonus selecionados , Vlr.Retorno selecionado

/*/
Static Function VM190DBLBON(nLinha,aBonusTot,nSelBon,nSelRet)
Local cDescBonus := ""
Local cBotPED    := repl("0",20)
Local aRet       := {}
Local aParamBox  := {}
If VAI->(ColumnPos("VAI_BOTPED")) > 0
	cBotPED := left(FGX_USERVL(xFilial("VAI"),__cUserID,"VAI_BOTPED","?")+repl("0",20),20)
	If !aBonusTot[nLinha,1] .and. ( substr(cBotPED,06,1) == "1" )
		cDescBonus := aBonusTot[nLinha,03] +" - "
		cDescBonus += FM_SQL("SELECT VZQ_DESCRI FROM "+RetSQLName("VZQ")+" WHERE VZQ_FILIAL='"+xFilial("VZQ")+"' AND VZQ_CODBON='"+aBonusTot[nLinha,03]+"' AND D_E_L_E_T_=' '")
		AADD(aParamBox,{1,STR0029,cDescBonus,"@!","","",".F.",120,.f.}) // Bonus
		AADD(aParamBox,{1,STR0033,aBonusTot[nLinha,4],"@E 999,999,999.99","MV_PAR02>0","",".T.",70,.t.}) // Vlr.Bonus
		If ParamBox(aParamBox,STR0076,@aRet,,,,,,,,.f.)// Selecao de Bonus para Geracao de NF
			aBonusTot[nLinha,4] := aRet[2]
			DbSelectArea("VQ1")
			DbGoTo(aBonusTot[nLinha,14])
			RecLock("VQ1",.f.)
				VQ1->VQ1_VLRTOT := aRet[2] // Usuario alterou o Valor de Bonus na Tela seleÁ„o dos Bonus para GeraÁ„o de NF de Comiss„o
			MsUnLock()
		Else
			Return()
		EndIf
	EndIf
EndIf
aBonusTot[nLinha,1] := !aBonusTot[nLinha,1]
nSelBon := 0
aEval( aBonusTot , {|x| nSelBon += IIF( x[1] , x[4] , 0 ) } )
oSelBon:Refresh()
nSelDiv := ( nSelRet - nSelBon )
oSelDiv:Refresh()
Return()

/*/{Protheus.doc} VM190DBLRET

Duplo clique no ListBox de Retornos na tela de Geracao de NF de Comissao

@author Andre Luis Almeida
@since  11/10/2017
@param  Linha no ListBox de Retornos possiveis , Vetor com os Retornos possiveis , Vlr.Bonus selecionados , Vlr.Retorno selecionado , Vlr.Divergencia

/*/
Static Function VM190DBLRET(nLinha,aReturTot,nSelBon,nSelRet,nSelDiv)
aEval( aReturTot , {|x| x[1] := .f. } )
aReturTot[nLinha,1] := .t.
nSelRet := aReturTot[nLinha,3]
oSelRet:Refresh()
nSelDiv := ( nSelRet - nSelBon )
oSelDiv:Refresh()
oLbRETTOT:Refresh()
Return()

/*/{Protheus.doc} VVM1900011_MontaFiltrosPedidos

Monta Campos de Filtro na TELA

@author Andre Luis Almeida
@since  13/07/2018

/*/
Static Function VVM1900011_MontaFiltrosPedidos()
Local nLinObj     := 5
Local nLinPula    := 12
Local nCntFor     := 0
Local aSimNao     := {"","0="+STR0084,"1="+STR0085} // Sim / Nao
Local aStaPed     := {}
Local lVQ0_STATUS := ( VQ0->(ColumnPos("VQ0_STATUS")) > 0 )
Local lVQ0_SEGMOD := ( VQ0->(ColumnPos("VQ0_SEGMOD")) > 0 )
Local ni          := 0

Private cCombo    := {}
Private oFnt3     := TFont():New("Arial",, 14, .t.) // Fonte para funÁ„o FSX_POSCPO()
//
@ nLinObj,025 SAY UPPER(STR0002) SIZE 80,8 OF oTScroll1 PIXEL COLOR CLR_HBLUE // Filtrar Pedidos
nLinObj += nLinPula+5
@ nLinObj,005 SAY (RetTitle("VQ0_FILPED")+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Filial Pedido
@ nLinObj,040 MSGET oFilPed VAR cFilPed PICTURE "@!" F3 "SM0_01" SIZE 50,08 OF oTScroll1 PIXEL COLOR CLR_BLACK
nLinObj += nLinPula
@ nLinObj,005 SAY (RetTitle("VQ0_NUMPED")+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Nro Pedido
@ nLinObj,040 MSGET oNumPed VAR cNumPed PICTURE "@!" SIZE 50,08 OF oTScroll1 PIXEL COLOR CLR_BLACK
nLinObj += nLinPula
@ nLinObj,005 SAY (STR0005+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Periodo
@ nLinObj,030 SAY (STR0006) SIZE 15,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // de
@ nLinObj,040 MSGET oDatIni VAR dDatIni PICTURE "@D" SIZE 50,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
nLinObj += nLinPula
@ nLinObj,030 SAY (STR0007) SIZE 15,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // ate
@ nLinObj,040 MSGET oDatFin VAR dDatFin PICTURE "@D" SIZE 50,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
nLinObj += nLinPula
If lVQ0_STATUS
	aAdd(aStaPed,"")
	For nCntFor := 1 to len(aCoresVQ0)
		If aCoresVQ0[nCntFor,1] <> " "
			aAdd(aStaPed,aCoresVQ0[nCntFor,1]+"="+X3CBOXDESC("VQ0_STATUS",aCoresVQ0[nCntFor,1]))
		EndIf
	Next
	@ nLinObj,005 SAY (RetTitle("VQ0_STATUS")+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Status Pedid
	@ nLinObj,040 MSCOMBOBOX oStaPed VAR cStaPed SIZE 50,08 COLOR CLR_BLACK ITEMS aStaPed OF oTScroll1 PIXEL
	nLinObj += nLinPula
EndIf
@ nLinObj,005 SAY (STR0098+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Filial Atend.
@ nLinObj,040 MSGET oFilAte VAR cFilAte PICTURE "@!" F3 "SM0_01" SIZE 50,08 OF oTScroll1 PIXEL COLOR CLR_BLACK
nLinObj += nLinPula
@ nLinObj,005 SAY (RetTitle("VQ0_NUMATE")+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Atendimento
@ nLinObj,040 MSGET oNumAte VAR cNumAte PICTURE "@!" SIZE 50,08 OF oTScroll1 PIXEL COLOR CLR_BLACK
nLinObj += nLinPula
@ nLinObj,005 SAY (RetTitle("VQ1_NUMNFI")+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Nro. NF
@ nLinObj,025 MSGET oNumNFI VAR cNumNFI F3 "SF2" PICTURE "@!" SIZE 50,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
//nLinObj += nLinPula
@ nLinObj,075 MSGET oSerNFI VAR cSerNFI PICTURE "@!" SIZE 10,08 OF oTScroll1 PIXEL COLOR CLR_BLACK
nLinObj += nLinPula
@ nLinObj,005 SAY (RetTitle("C5_CLIENTE")+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Cliente
@ nLinObj,025 MSGET oCodCli VAR cCodCli F3 "SA1" PICTURE "@!" SIZE 50,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
//nLinObj += nLinPula
@ nLinObj,075 MSGET oLojCli VAR cLojCli PICTURE "@!" SIZE 10,08 OF oTScroll1 PIXEL COLOR CLR_BLACK
nLinObj += nLinPula
@ nLinObj,005 SAY (RetTitle("VQ0_CHASSI")+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Chassi
@ nLinObj,025 MSGET oChassi VAR cChassi F3 "VV1" PICTURE "@!" SIZE 65,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
nLinObj += nLinPula
@ nLinObj,005 SAY (RetTitle("VQ0_CODMAR")+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Marca
@ nLinObj,025 MSGET oCodMar VAR cCodMar F3 "VE1" PICTURE "@!" SIZE 35,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
nLinObj += nLinPula
@ nLinObj,005 SAY (RetTitle("VQ0_MODVEI")+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Modelo
@ nLinObj,025 MSGET oModVei VAR cModVei F3 "VV2" PICTURE "@!" SIZE 65,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
nLinObj += nLinPula
If lVQ0_SEGMOD
	@ nLinObj,005 SAY (RetTitle("VQ0_SEGMOD")+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Segmento do Modelo
	@ nLinObj,040 MSGET oModVei VAR cSegMod PICTURE "@!" SIZE 40,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
	nLinObj += nLinPula
EndIf
@ nLinObj,005 SAY (RetTitle("VQ0_DATFDD")+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Data FDD
@ nLinObj,030 SAY (STR0006) SIZE 15,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // de
@ nLinObj,040 MSGET oDtIFDD VAR dDtIFDD PICTURE "@D" SIZE 50,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
nLinObj += nLinPula
@ nLinObj,030 SAY (STR0007) SIZE 15,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // ate
@ nLinObj,040 MSGET oDtFFDD VAR dDtFFDD PICTURE "@D" SIZE 50,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
nLinObj += nLinPula
@ nLinObj,005 SAY (STR0016+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Entregue
@ nLinObj,030 SAY (STR0006) SIZE 15,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // de
@ nLinObj,040 MSGET oDtIEnt VAR dDtIEnt PICTURE "@D" SIZE 50,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
nLinObj += nLinPula
@ nLinObj,030 SAY (STR0007) SIZE 15,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // ate
@ nLinObj,040 MSGET oDtFEnt VAR dDtFEnt PICTURE "@D" SIZE 50,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
nLinObj += nLinPula
@ nLinObj,005 SAY (STR0015+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Vendido
@ nLinObj,030 SAY (STR0006) SIZE 15,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // de
@ nLinObj,040 MSGET oDtIVen VAR dDtIVen PICTURE "@D" SIZE 50,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
nLinObj += nLinPula
@ nLinObj,030 SAY (STR0007) SIZE 15,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // ate
@ nLinObj,040 MSGET oDtFVen VAR dDtFVen PICTURE "@D" SIZE 50,08 OF oTScroll1 PIXEL HASBUTTON COLOR CLR_BLACK
nLinObj += nLinPula
@ nLinObj,005 SAY (RetTitle("VQ0_FATDIR")+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // Fat.Direto
@ nLinObj,040 MSCOMBOBOX oFatDir VAR cFatDir SIZE 40,08 COLOR CLR_BLACK ITEMS aSimNao OF oTScroll1 PIXEL
nLinObj += nLinPula
@ nLinObj,005 SAY (STR0099+":") SIZE 55,8 OF oTScroll1 PIXEL COLOR CLR_BLUE // NF gerada
@ nLinObj,040 MSCOMBOBOX oNFgera VAR cNFGera SIZE 40,08 COLOR CLR_BLACK ITEMS aSimNao OF oTScroll1 PIXEL

// Campos customiz·veis (PE VM190CPO)
If Len(aCposUser) > 0
	For ni := 1 to Len(aCposUser)
		SX3->(DbSetOrder(2))

		If !Empty(aCposUser[ni]) .And. SX3->(DbSeek(aCposUser[ni]))
			If SX3->X3_CONTEXT <> "V" .And. SX3->X3_TIPO <> "M" // Somente campos Reais (n„o Memos)
				nLinObj += nLinPula
				cCombo  := {}

				&("x" + aCposUser[ni]) := CriaVar(aCposUser[ni])

				If SX3->X3_TIPO == "C" .And. !Empty(SX3->X3_CBOX)
					cCombo := X3CBOXAVET(SX3->X3_CAMPO, "1")

					&("x" + aCposUser[ni]) := ""
				EndIf

				FSX_POSCPO("x" + aCposUser[ni], "oSay" + Strzero(ni,2), nLinObj, 5, 28, Iif(Len(cCombo) > 0 .And. !Empty(cCombo[2]), "cCombo", ""), Left(RTrim(SX3->X3_TITULO), 10) + ":", SX3->X3_F3,, "oTScroll1", "oGet" + Strzero(ni,2), .t., .f., CLR_BLUE, SX3->X3_PICTURE, 55)
			EndIf

			aAdd(aCposFil, { aCposUser[ni], SX3->X3_TIPO }) // Adicionando ao array de verificaÁ„o para filtro (SELECT)
		EndIf
	Next

	SX3->(DbSetOrder(1))
EndIf
nLinObj += nLinPula+5

@ nLinObj,018 BUTTON oFiltro PROMPT STR0008 OF oTScroll1 SIZE 60,09 PIXEL ACTION (FS_LEVANTA(0,.t.),FS_LEVANTA(1,.t.)) // Filtrar
nLinObj += 5
@ nLinObj,001 SAY (".") SIZE 0,0 OF oTScroll1 PIXEL COLOR CLR_WHITE // . somente para ter uma margem inferior, apos o botao Filtrar
//
Return

/*/{Protheus.doc} VVM1900021_Cor2Coluna

Retorna a Cor da 2a.Coluna

@author Andre Luis Almeida
@since  13/07/2018

/*/
Static Function VVM1900021_Cor2Coluna( aVetPed , nLinVetPed )
Local cCor2Coluna := ExecBlock("VM190COR",.f.,.f.,{ aVetPed , nLinVetPed })
/*
Principais elementos do Vetor de Pedidos enviado como Parametro para
serem utilizados no Ponto de Entrada VM190COR:
	aVetPed[ nLinVetPed , 01 ] = Numero do Pedido ( caracter )
	aVetPed[ nLinVetPed , 02 ] = Data do Pedido ( string exemplo: 20180715 )
	aVetPed[ nLinVetPed , 03 ] = Chassi - VV1_CHASSI ( caracter )
	aVetPed[ nLinVetPed , 15 ] = Data FDD ( string exemplo: 20180715 )
	aVetPed[ nLinVetPed , 17 ] = RecNo do VQ0 ( numerico )
	aVetPed[ nLinVetPed , 19 ] = Filial do Pedido ( caracter )
	aVetPed[ nLinVetPed , 26 ] = ChaInt - VV1_CHAINT ( caracter )
	aVetPed[ nLinVetPed , 29 ] = Data ORSD ( string exemplo: 20180715 )
	aVetPed[ nLinVetPed , 32 ] = Status ( caracter )

Exemplos de Retorno ( nome cor ) do Ponto de Entrada VM190COR:
	cCor2Coluna := "BR_VERDE"
	cCor2Coluna := "BR_AZUL"
	cCor2Coluna := "BR_VERMELHO"
	cCor2Coluna := "BR_BRANCO"
*/
Return LoadBitmap( GetResources() , cCor2Coluna )

/*/{Protheus.doc} VVM1900031_LegendaPedidos

Legenda dos Pedidos - VQ0_STATUS

@author Andre Luis Almeida
@since  12/07/2018

/*/
Static Function VVM1900031_LegendaPedidos()
Local aLegenda := {}
Local nCntFor  := 0
For nCntFor := 1 to len(aCoresVQ0)
	aAdd(aLegenda,{ aCoresVQ0[nCntFor,3] , IIf(aCoresVQ0[nCntFor,1]<>" ",X3CBOXDESC("VQ0_STATUS",aCoresVQ0[nCntFor,1]),STR0139) }) // Status n„o definido
Next
If ExistBlock("VM190LEG")
	aLegenda := ExecBlock("VM190LEG",.f.,.f.,{ aLegenda })
EndIf
BrwLegenda(STR0042,STR0001,aLegenda) // Legenda / Pedidos de Maquinas
Return

/*/{Protheus.doc} VEM1900016_PreencheSX3VQ0
Preencher com os dados SX3 da tabela VQ0
@author Fernando Vitor Cavani
@since 25/09/2018
@version undefined
@param aX3Dados, array   , dados SX3
@param aAux    , array   , relaÁ„o SX3
@param nOpcVQ0 , numÈrico, opÁ„o menu
@type function
/*/
Function VEM1900016_PreencheSX3VQ0(aX3Dados, aAux, nOpcVQ0)
Local ni := 0

SX3->(DbSetOrder(2))

For ni := 1 To Len(aX3Dados)
	SX3->(DbSeek(aX3Dados[ni,1]))

	If nOpcVQ0 == 3 .And. !Empty(SX3->X3_RELACAO)
		aAux[1, aX3Dados[ni,2]] := Iif(SX3->X3_TIPO <> "D", &(SX3->X3_RELACAO), DtoS(&(SX3->X3_RELACAO)))
	EndIf

	If !X3USO(SX3->X3_USADO)
		aX3Dados[ni,3] := .F.
	EndIf

	If !Empty(SX3->X3_WHEN)
		aX3Dados[ni,4] := &(SX3->X3_WHEN)
	EndIf
Next
Return

/*/{Protheus.doc} VEM1900026_ValidaFilial
Validar Filial informada
@author Fernando Vitor Cavani
@since 28/03/2019
@version undefined
@param  cParFil, caracter, Filial informada
@return lRet   , lÛgico  , .t. ou .f.
@type function
/*/
Function VEM1900026_ValidaFilial(cParFil)
Local lRet := .t.

Default cParFil := ""

If !Empty(cParFil) .And. !FWFilExist(cEmpAnt, cParFil)
	MsgAlert(STR0141, STR0050) // Filial n„o encontrada, verifique! / AtenÁ„o

	lRet := .f.
EndIf
Return lRet

/*/{Protheus.doc} VEM1900069_ValidaSegMod
Validar Segmento informado
@author Vanessa Simei Mateus
@since 10/02/2021
@version undefined
@param  
@return lRet   , lÛgico  , .t. ou .f.
@type function
/*/
Function VEM1900069_ValidaSegMod()

Local lRet := .t.

If !Empty(M->MV_PAR33)
	If ! FG_Seek('VV2', 'M->MV_PAR04+M->MV_PAR05+M->MV_PAR33', 1)
		MsgAlert("Segmento n„o encontrado para a Marca/Modalidade informadas!", "AtenÁ„o") // Segmento n„o encontrado para a Marca/Modalidade informadas! / AtenÁ„o
		lRet := .f.
	Else
		_VV2CODMAR_Filtro := VV2->VV2_CODMAR
		_VV2GRUMOD_Filtro := VV2->VV2_GRUMOD
		_VV2MODVEI_Filtro := VV2->VV2_MODVEI
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} VEM1900079_ValidaModVei
Validar Modelo de veÌculo informado
@author Vanessa Simei Mateus
@since 10/02/2021
@version undefined
@param  
@return lRet   , lÛgico  , .t. ou .f.
@type function
/*/
Function VEM1900079_ValidaModVei()

Local lRet := .t.

_VV2GRUMOD_Filtro := ""
_VV2MODVEI_Filtro := ""

If !Empty(M->MV_PAR05)
	If ! FG_Seek('VV2', 'M->MV_PAR04+M->MV_PAR05+alltrim(M->MV_PAR33)', 1)
		MsgAlert("Modalidade n„o encontrada para Marca/Segmento informados!", "AtenÁ„o") // Modalidade n„o encontrada para Marca/Segmento informados! / AtenÁ„o
		lRet := .f.
	Else
		_VV2CODMAR_Filtro := VV2->VV2_CODMAR
		_VV2GRUMOD_Filtro := VV2->VV2_GRUMOD
		_VV2MODVEI_Filtro := VV2->VV2_MODVEI
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} VEM1900089_ValidaCodMar
Validar Marca informada
@author Vanessa Simei Mateus
@since 10/02/2021
@version undefined
@param  
@return lRet   , lÛgico  , .t. ou .f.
@type function
/*/
Function VEM1900089_ValidaCodMar()

Local lRet := .t.

_VV2CODMAR_Filtro := "" 
_VV2GRUMOD_Filtro := ""
_VV2MODVEI_Filtro := ""
cFilCodMar        := ""


If !Empty(M->MV_PAR04)

	cFilCodMar := M->MV_PAR04
	If ! ( FG_Seek('VE1', 'M->MV_PAR04',1) ) 
		MsgAlert("Marca n„o encontrada!", "AtenÁ„o") // Segmento n„o encontrado! / AtenÁ„o
		lRet := .f.
	Else
		_VV2CODMAR_Filtro := VE1->VE1_CODMAR
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} VEM1900098_VerificaPEVQ1

@author Matheus Teixeira
@since 05/08/2021
@version undefined
@param  
nTipo = 1 - Chamado ao gerar a Nota Fiscal, apÛs salvar as informaÁıes na tabela VQ1
nTipo = 2 - Chamado no levantamento dos bonus, apÛs a Exclus„o dos bonus existentes quando informado que deve ser excluido (msgYesNo)
nTipo = 3 - Chamado no levantamento dos bonus relacionados, enquanto Grava a tabela VQ1
nTipo = 4 - Chamado na exclus„o da VQ1 na ManutenÁ„o de Pedido, apÛs exclus„o
nTipo = 5 - Chamado na ManutenÁ„o do Bonus, ao Incluir
nTipo = 6 - Chamado na ManutenÁ„o do Bonus, apÛs a Exclus„o
nTipo = 7 - Chamado no Cancelamento do bonus
@return lRet   , lÛgico  , .t. ou .f.
@type function
/*/
Function VEM1900098_VerificaPEVQ1(nTipo)

	If ExistBlock("VM190VQ1") 
		 ExecBlock("VM190VQ1",.f.,.f.,{nTipo,VQ0->VQ0_FILIAL,VQ0->VQ0_NUMPED})
	EndIf

Return nil