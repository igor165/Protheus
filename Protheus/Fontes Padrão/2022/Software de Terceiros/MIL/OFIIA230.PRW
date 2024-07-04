// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 12     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "TOPCONN.CH"
#Include "OFIIA230.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIIA230 ³ Autor ³  Renata               ³ Data ³ 20/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Importacao do Espelho do Pedido Programado pelo DSM        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Integracao Montadora                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIA230(aParamet)

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0004)   //"Exportacao dos Dados do Pedido //"Importacao dos Dados do Pedido gerado pelo (DSM)"
Private cCodMar  && Variavel criada para nao ter conflito com a segunta pergunte

// no WORKFLOW agendar:     M_OFIA230("090400348711001")

// no Cadastro de Integracoes (Registro/Assuntos), no campo MACRO chamar:
//                          OFIIA230({"SC 50209040034870411001"})
//							onde,
//							SC     - Marca
//							502    - Assunto (Importacao - Espelho Pedido DSM)
//							09     - Empresa
//							04     - Filial
//							003487 - Fornecedor
//							04     - Loja
//							09     - Via de Transporte (1=Sim;2=Nao)
//							04     - Pagto em 48 horas (1=Sim;2=Nao)
//							001    - Cond de Pagto


If ValType(aParamet) == "A"
	cCodMar := subs(aParamet[1],01,3)
	cAssunt := subs(aParamet[1],04,3)
	cEmpAtu := subs(aParamet[1],07,2)
	cFilAtu := subs(aParamet[1],09,2)
	cFornec := subs(aParamet[1],11,6)
	cLojFor := subs(aParamet[1],17,2)
	cViaTra := subs(aParamet[1],19,1)
	cPgt48h := subs(aParamet[1],20,1)
	cCondPg := subs(aParamet[1],21,3)
	cTransp := Space(6)
Endif

dbSelectArea("VID")
DbSetOrder(1)
dbSeek( xFilial("VID") + cCodMar )
cCodPed := VID->VID_CODPED
dDatPro := VID->VID_DATPRO
cTipPed := ""
If VID->(FieldPos("VID_TIPPED")) > 0
	cTipPed := VID->VID_TIPPED
EndIf
if left(cCodPed,1) = "8" 
   cTipPed :="07"
endif

If Empty(cCodPed)
	If !lAuto
		MsgStop(STR0010)     //"Nao existe pedidos a Importar"
	Endif
	Return
Endif

aHelpPor := {"Número do pedido ja existe!"  }
aHelpEng := aHelpSpa :=	aHelpPor
PutHelp("POFIIA230PEDEX",aHelpPor,aHelpEng,aHelpSpa,.t.)

dbSelectArea("VEI")
dbSetOrder(2)
If dbSeek( xFilial("VEI") + cCodMar + VID->VID_CODPED ) .and. GetNewPar("MV_PEDANO","")!="S"
	If  !lAuto
		help(" ",1,"OFIIA230PEDEX")  //  numero do pedido ja existe
	Endif
	return
endif

if dbSeek( xFilial("VEI") + cCodMar + strzero(val(cCodPed),10)+"/"+Right(STR(Year(dDatPro)),2)) .and. GetNewPar("MV_PEDANO","")=="S"
	If  !lAuto
		help(" ",1,"OFIIA230PEDEX")  //  numero do pedido ja existe
	Endif
	return
endif

If  !lAuto
	Processa( {|| FS_INTVID()} )
Else
	FS_INTVID()
Endif

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_INTVID ³ Autor ³Renata                 ³ Data ³ 20/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao dos dados do arquivo VID p/ o arquivo SC7         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_INTVID()

&& Variaveis utilizadas na Funcao
Local lNIteSB1 := .f. ,   lNPrcRep := .f.
Local aNIteSB1 := {}  ,   aNPrcRep := {}
Local iGr := 0, i := 0
Local cItemSC7 := Repl( "0", Len(SC7->C7_ITEM) )
Local aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)

Private lMsHelpAuto := .t. , lMsErroAuto := .f., cNumPed230 := ""
Private cEmpFil := ALLTRIM(aSM0[1])+ALLTRIM(aSM0[2])
Private aCab := {} , aItem := {}

// Carrega Grupos Originais
aGruOri := {VE4->VE4_GRUITE}
DbSelectArea("SBM")
DbGoTop()
While !eof() .and. SBM->BM_FILIAL == xFilial("SBM")
	If SBM->BM_PROORI == "1" // Produto Original da Marca
		If  !aScan(aGruOri,SBM->BM_GRUPO) > 0
			aadd(aGruOri,SBM->BM_GRUPO)
		Endif
	Endif
	DbSkip()
Enddo

Begin Transaction

DbSelectArea("VE4")
DbSetOrder( 1 )
DbSeek( xFilial("VE4") + cCodMar )

DbSelectArea("VE6")
DbSetOrder( 1 )
DbSeek( xFilial("VE6") + "0" + Dtos( VID->VID_DATPRO ) )

cNumPed230  :=CriaVar("C7_NUM")

aAdd(aCab,{"C7_NUM"     ,cNumPed230         	    ,Nil}) // Numero do Pedido
aAdd(aCab,{"C7_EMISSAO" ,VID->VID_DATPRO   ,Nil}) // Data de Emissao
aAdd(aCab,{"C7_FORNECE" ,cFornec    	    ,Nil}) // Fornecedor
aAdd(aCab,{"C7_LOJA"    ,cLojFor    		,Nil}) // Loja do Fornecedor
aAdd(aCab,{"C7_CONTATO" ,"               " ,Nil}) // Contato
aAdd(aCab,{"C7_COND"    ,cCondPg    	    ,Nil}) // Condicao de pagamento
aAdd(aCab,{"C7_FILENT"  ,xFilial("VID")	    ,Nil}) // Filial Entrega

dbselectArea("VID")
If  !lAuto
	ProcRegua( reccount() )
Endif

do while !eof() .And. VID->VID_FILIAL == xFilial("VID") .And. VID->VID_CODMAR == cCodMar
	
	If Empty(VID->VID_CODITE)
		DbSkip()
		Loop
	Endif
	
	DbSelectArea("SB1")
	DbSetOrder( 7 )
	lAchou := .f.
	For iGr := 1 to Len(aGruOri)
		If DbSeek( xFilial("SB1") + aGruOri[iGr] + VID->VID_CODITE )
			lAchou := .t.
			exit
		Endif
	Next
	
	If !lAchou
		
		lNIteSB1 := .t.
		aadd(aNIteSB1,{VID->VID_CODITE + STR0012 + VID->VID_CODPED})
		
	Else
		
		DbSelectArea("SB5")
		DbSetOrder( 1 )
		DbSeek( xFilial("SB5") + SB1->B1_COD )
		
		If ( !Found() .Or. Empty( SB5->B5_PRV2 ) )
			
			lNPrcRep := .t.
			aadd(aNPrcRep,{ Substr(SB1->B1_CODITE,1,15) + " - "+SB1->B1_COD + STR0012 + VID->VID_CODPED })
			
		Endif
		
	endif
	
	cItemSC7 := SOMA1( cItemSC7 )
	
	aAdd(aItem,{{"C7_ITEM"   , cItemSC7         ,Nil} ,; // Numero do Item
				{"C7_PRODUTO",SB1->B1_COD       ,Nil} ,; // Codigo do Produto
				{"C7_UM"     ,SB1->B1_UM   	    ,Nil} ,; // Unid. Medida
				{"C7_QUANT"  ,VID->VID_QTDADE   ,Nil} ,; // Quantidade
				{"C7_PRECO"  ,SB5->B5_PRV2      ,Nil} ,; // Preco
				{"C7_DATPRF" ,dDataBAse  	    ,Nil} ,; // Data DE Entrega
				{"C7_TES"    ,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TE") ,Nil} ,; // TES
				{"C7_FLUXO"  ,"S"			    ,Nil} ,; // Fluxo de Caixa (S/N)
				{"C7_LOCAL"  ,VE4->VE4_ALMPAD   ,Nil} ,; // Almoxarifado
				{"C7_PENDEN" ,"N"               ,Nil}})  // Pendencia
	
	If ( ExistBlock("OFMT230A") )
		aItem:= ExecBlock("OFMT230A",.f.,.f.,{aItem})
	EndIf

	If  !lAuto
		IncProc(OemtoAnsi(STR0006))
	Endif
	
	dbselectArea("VID")
	dbskip()
EndDo

//If !Empty( GetNewPar("MV_MAQGPEC","") ) //Mandar mensagem por IP não funciona mais nas novas versões do Windows
	
	If lNIteSB1 .or. lNPrcRep
		
		If lNIteSB1 // Itens sem referencia no SB1
			cMsg := STR0011 + Chr(10)                  // "Os codigos de Peca a seguir nao existem no Arquivo de Produtos (SB1): "
			For i := 1 to Len(aNIteSB1)
				cMsg := cMsg + aNIteSB1[i,1] + Chr(10)
			Next
			/*
			if AT(",",GetNewPar("MV_MAQGPEC","")) == 0
				cSendMsg := "prj_client " + GetNewPar("MV_MAQGPEC","") + " " + '"' + cMsg + '"'
			else
				cSendMsg := "prj_client " + subs(GetNewPar("MV_MAQGPEC",""),1,at(",",GetNewPar("MV_MAQGPEC",""))-1) + " " + '"' + cMsg + '"'
			endif
			WinExec(cSendMsg)
			*/
		Endif

		If lNPrcRep // Itens sem preco de Reposicao
			cMsg := STR0005 + Chr(10)                   // "Os codigos de Peca a seguir estao sem Preco de Reposicao: "
			For i := 1 to Len(aNPrcRep)
				cMsg := cMsg + aNPrcRep[i,1] + Chr(10)
			Next
			/*
			if AT(",",GetNewPar("MV_MAQGPEC","")) == 0
				cSendMsg := "prj_client " + GetNewPar("MV_MAQGPEC","") + " " + '"' + cMsg + '"'
			else
				cSendMsg := "prj_client " + subs(GetNewPar("MV_MAQGPEC",""),1,at(",",GetNewPar("MV_MAQGPEC",""))-1) + " " + '"' + cMsg + '"'
			endif
			WinExec(cSendMsg)
			*/
		Endif
		
		fRename("\INT\IMP\DSM\"+cEmpFil+"\ENVDSM.SLV","\INT\IMP\DSM\"+cEmpFil+"\ENVDSM.IMP")
		
		if !lAuto
			MsgStop(cMsg)
		endif
		
		If ( ExistBlock("IA230MSG") )
			ExecBlock("IA230MSG",.f.,.f., { "\INT\IMP\DSM\"+cEmpFil+"\ENVDSM.IMP" , cMsg } )
		EndIf
		
		DisarmTransaction()
		Break
		
	Endif
	
//EndIf

If Len(aCab) # 0 .And. Len(aItem) # 0
	
	SB1->(DbSetOrder(1))
	
	MSExecAuto({|x,y| MATA120(1,x,y)},aCab,aItem)
	
EndIf

If lMSErroAuto
	
	DisarmTransaction()
	Break
	
EndIf

If __lSX8
	ConFirmSX8()
	cNumOsv := "" //VE6->VE6_NUMOSV
	cChaint := "" //VE6->VE6_CHAINT
	FS_VEIVID()
Else
	RollBackSx8()
Endif

End Transaction

If lMsErroAuto
	MostraErro()
EndIf

If !lNIteSB1 .and. !lNPrcRep .and. !lMsErroAuto
	FS_DELIA230()
	Delete file "\INT\IMP\DSM\"+cEmpFil+"\ENVDSM.SLV"
Endif

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_DELIA230 Autor ³Renata                 ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Apaga os dados do arquivo VID                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DELIA230()

Local cQuery := ""

// Deleta registro.
dbselectarea("VID")
If TCCanOpen(RetSqlName("VID"))
	
	cQuery := "DELETE FROM " + RetSqlName( "VID" ) + " "
	cQuery += "WHERE VID_FILIAL = '"+xFilial("VID")+"' And VID_CODMAR = '"+cCodMar+"'"
	TCSqlExec(cQuery)
	
EndIf

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VEIVID ³ Autor ³Renata                 ³ Data ³ 06/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava os dados no arquivo VEI                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VEIVID()
dbselectarea("VEI")
DbSetOrder( 2 )
if GetNewPar("MV_PEDANO","")=="S"
	DbSeek( xFilial("VEI") + cCodMar + strzero(val(cCodPed),10)+"/"+Right(STR(Year(dDatPro)),2) )
else
	if !(DbSeek( xFilial("VEI") + cCodMar + strzero(val(cCodPed),13) ))
		DbSeek( xFilial("VEI") + cCodMar + SPACE(13 - LEN(AllTrim(cCodPed)))+ AllTrim(cCodPed) )
	endif
endif
RecLock("VEI", !Found() )
VEI->VEI_FILIAL := xFilial("VEI")
VEI->VEI_CODMAR := cCodMar
VEI->VEI_NUM    := cNumPed230
VEI->VEI_PEDFAB := strzero(val(cCodPed),10)+"/"+Right(STR(Year(dDatPro)),2)
VEI->VEI_TIPPED := cTipPed
VEI->VEI_VIATRA := cViaTra
VEI->VEI_TRANSP := cTransp
VEI->VEI_NUMOSV := cNumosv
VEI->VEI_CHAINT := cChaint
VEI->VEI_PGT48H := cPgt48h
VEI->VEI_DATSC7 := dDatabase
VEI->VEI_HORSC7 := Val(Substr(Time(),1,2)+Substr(Time(),4,2))
MsUnLock()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³Renata                 ³ Data ³ 20/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria aRotina ( MENUDEF )                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { 	{ STR0001 ,"axPesqui", 0 , 1},;  // Pesquisar
					{ STR0002 ,"IA230V"  , 0 , 2},;  // Visualizar
					{ STR0003 ,"IA230I"  , 0 , 3}}   // Importar
Return aRotina
