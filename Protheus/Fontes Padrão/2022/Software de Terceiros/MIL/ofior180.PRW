// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 14     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#INCLUDE "ofior180.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOR180 ³ Autor ³ Thiago                ³ Data ³ 05/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Notificacao de Atd. da Oficina (Nato VW)      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR180

Local cAlias := "VO1"
Local cQuery := ""

Private nLin := 1
Private aPag := 1
Private lVOOEnvNat := VOO->(FieldPos("VOO_ENVNAT")) <> 0
Private lVOOVosKT  := VOO->(FieldPos("VOO_VOSKT")) <> 0

Private lA1CELULAR := SA1->(FieldPos("A1_CELULAR")) <> 0
Private lA1RESQUE  := SA1->(FieldPos("A1_RESQUE")) <> 0
Private lA1NUMERO  := SA1->(FieldPos("A1_NUMERO")) <> 0

//Variaveis padrao de relatorio
Private cDesc1   := STR0001 //"Relatorio de Notificacao de Atendimento da Oficina - NATO - Volkswagen"
Private cCabec1  := STR0001 //"Relatorio de Notificacao de Atendimento da Oficina - NATO - Volkswagen"
Private cDesc2   := ""
Private cDesc3   := ""
Private cCabec2  := ""
Private aReturn  := { STR0002, 1,STR0003, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private cTamanho := "G"           // P/M/G
Private Limite   := 220           // 80/132/220
Private cTitulo  := STR0004 //"Notificacao Atendimento da Oficina - N.A.T.O"
Private cNomProg := "OFIOR180"
Private cNomeRel := "OFIOR180"
Private nLastKey := 0
Private nCaracter:= 15
Private aVei     := {{"",""}}
Private cPerg    := "OFR180"
Private lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
//Carla - 18/05/2009 - variaveis criadas devido as alteracoes no layout NATO
Private cMcvwt   := " "
Private cRvvwt   := " "
Private cVolks   := space(3)//variavel que grava 'Sim' para veiculo Volkstotal e 'Nao' caso contrario
Private cImpVCli := space(8)//variavel que grava 'mecanica' para serv. por conta do cliente do veiculo volkstotal
Private cImpVGar := space(8)//grava 'mecanica'ou 'revisao' para serv. garantia do veiculo volkstotal

ValidPerg()

//Variaveis da Pergunte
//mv_par01 = data inicial
//mv_par02 = data final
//mv_par03 = T Tempo p/ Cliente
//mv_par04 = T Tempo p/ Garantia
//mv_par05 = T Tempo p/ Interno
//mv_par06 = T Tempo p/ Seguro
//mv_par07 = Tipo de Veiculo
//mv_par08 = Gera Arquivo
//mv_par09 = Marca

PERGUNTE("OFR180",.F.)

cNomeRel := SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,,cTamanho)

if nlastkey == 27
	return
Endif
PERGUNTE(cPerg,.F.)

SetDefault(aReturn,cAlias)

if mv_par08 == 1
	
	// Deleta todos os registro do arquivo de trabalho. VI8
	If TCCanOpen(RetSqlName("VI8"))
		
		cQuery := "DELETE FROM " + RetSqlName( "VI8" ) + " "
		cQuery += "WHERE VI8_FILIAL = '"+xFilial("VI8")+"'"
		TCSqlExec(cQuery)
		
	EndIf
	
endif

RptStatus({|lEnd| ImpOSInt(@lEnd,cNomeRel,cAlias)},cTitulo)

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpOSInt  ºAutor  ³ Thiago             º Data ³  05/01/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpOSInt(lEnd,wNRel,cAlias)

Local lImpOsv := .f.
Local lSkip   := .t.
Local aOsv    := {}
Local aImp    := {}
Local aMostra := {} // Renato
Local i       := 0
Local xi      := 0
Local cPreFab := ""
Local nPosVE4 := ""
Local aSM0     := {}          

// Levanta todas Marcas do VE4
VE4->(Dbgotop())
VE4->(dbseek(xFilial("VE4")))
nPosVE4 := VE4->(Recno())
while VE4->(!Eof()) .and. xFilial("VE4") = VE4->VE4_FILIAL
	cPreFab += VE4->VE4_PREFAB+"/"
	VE4->(DbSkip())
Enddo
VE4->(DbGoTo(nPosVE4))

set print to &cNomeRel
set print on
set device to print

cRev  := ""
cFun  := ""
cPin  := ""
cMec  := ""
cRev1 := ""
cFun1 := ""
cPin1 := ""
cMec1 := ""
lCodCon  := .T.

Private cCabec2  := "Periodo: " + Dtoc(Mv_Par01) + " a " + Dtoc(Mv_Par02)
Private cTipTpo := mv_par03+"/"+mv_par04+"/"+mv_par05+"/"+mv_par06
Private cbTxt    := Space(10)
Private cbCont   := 0
Private cString  := "VSC"
Private Li       := 80
Private m_Pag    := 1
Private cQAlVSC  := "SQLVSC"
Private cQAlVOO  := "SQLVOO"
Private cQAlVV1  := "SQLVV1"
Private cQAlVV8  := "SQLVV8"
Private cQAlVOI  := "SQLVOI"
Private cQAlVOK  := "SQLVOK"
Private cQAlVVK  := "SQLVVK"
Private cQAlVO1  := "SQLVO1"
Private cQAlVV2  := "SQLVV2"
Private cQAlSA1  := "SQLSA1"

nLin := Cabec(cTitulo,cCabec1,cCabec2,cNomProg, cTamanho,nCaracter)+1

cQuery := "SELECT VSC.VSC_FILIAL, VSC.VSC_NUMNFI, VSC.VSC_TIPTEM, VSC.VSC_NUMOSV, VSC.VSC_TIPSER, VSC.VSC_DEPGAR, VSC.VSC_DATVEN "
cQuery += "FROM " + RetSqlName( "VSC" ) + " VSC "
cQuery += "WHERE VSC.VSC_FILIAL = '"+xFilial("VSC")+"' AND VSC.D_E_L_E_T_=' ' AND "
cQuery += "VSC.VSC_DATVEN>='"+dtos(MV_PAR01)+"' AND VSC.VSC_DATVEN<='"+dtos(MV_PAR02)+"'"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVSC , .F., .T. )

( cQAlVSC )->( DbGoTop() )

While ( cQAlVSC )->( !Eof() )
	
	if empty( ( cQAlVSC )->VSC_NUMNFI )
		DbSelectArea( cQAlVSC )
		DbSkip()
		Loop
	endif
	
	
	if !( cQAlVSC )->VSC_TIPTEM $ cTiptpo
		DbSelectArea( cQAlVSC )
		DbSkip()
		Loop
	endif
	
	If Select(cQAlVOO) > 0
		( cQAlVOO )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT VOO.VOO_NUMOSV, VOO.VOO_NUMNFI "
	If lVOOEnvNat
		cQuery += ",VOO.VOO_ENVNAT "
	Endif
	If lVOOVosKT
		cQuery += ", VOO.VOO_VOSKT "
	Endif
	cQuery += "FROM " + RetSqlName( "VOO" ) + " VOO "
	cQuery += "WHERE VOO.VOO_FILIAL = '"+xFilial("VOO")+"' AND VOO.D_E_L_E_T_=' ' AND "
	cQuery += "VOO.VOO_NUMOSV='"+( cQAlVSC )->VSC_NUMOSV+"' AND VOO.VOO_TIPTEM='"+( cQAlVSC )->VSC_TIPTEM+"'"
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVOO , .F., .T. )
	if lVOOEnvNat .and. ( cQAlVOO )->VOO_ENVNAT = "N"
		DbSelectArea( cQAlVSC )
		DbSkip()
		Loop
	endif
	
	If Select(cQAlVO1) > 0
		( cQAlVO1 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT VO1.VO1_CHAINT, VO1.VO1_DATABE, VO1.VO1_KILOME, VO1.VO1_HORTRI  "
	cQuery += "FROM " + RetSqlName( "VO1" ) + " VO1 "
	cQuery += "WHERE VO1.VO1_FILIAL = '"+xFilial("VO1")+"' AND VO1.D_E_L_E_T_=' ' AND "
	cQuery += "VO1.VO1_NUMOSV='"+( cQAlVOO )->VOO_NUMOSV+"'"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVO1 , .F., .T. )
	
	If Select(cQAlVV1) > 0
		( cQAlVV1 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT VV1.VV1_CODMAR, VV1.VV1_CODCON, VV1.VV1_PROATU, VV1.VV1_LJPATU, VV1.VV1_CHAINT, VV1.VV1_MODVEI, VV1.VV1_CHASSI, VV1.VV1_FABMOD "
	cQuery += "FROM " + RetSqlName( "VV1" ) + " VV1 "
	cQuery += "WHERE VV1.VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1.D_E_L_E_T_=' ' AND "
	cQuery += "VV1.VV1_CHAINT='"+( cQAlVO1 )->VO1_CHAINT+"'"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1 , .F., .T. )
	
	If Select(cQAlVV2) > 0
		( cQAlVV2 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT VV2.VV2_TIPVEI "
	cQuery += "FROM " + RetSqlName( "VV2" ) + " VV2 "
	cQuery += "WHERE VV2.VV2_FILIAL = '"+xFilial("VV2")+"' AND VV2.D_E_L_E_T_=' ' AND "
	cQuery += "VV2.VV2_CODMAR='"+( cQAlVV1 )->VV1_CODMAR+"' AND VV2.VV2_MODVEI='"+( cQAlVV1 )->VV1_MODVEI+"'"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV2 , .F., .T. )
	
	If Select(cQAlVOI) > 0
		( cQAlVOI )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT VOI.VOI_SITTPO "
	cQuery += "FROM " + RetSqlName( "VOI" ) + " VOI "
	cQuery += "WHERE VOI.VOI_FILIAL = '"+xFilial("VOI")+"' AND VOI.D_E_L_E_T_=' ' AND "
	cQuery += "VOI.VOI_TIPTEM='"+( cQAlVSC )->VSC_TIPTEM+"'"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVOI , .F., .T. )
	
	If Select(cQAlVV8) > 0
		( cQAlVV8 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT VV8.VV8_TIPVEI "
	cQuery += "FROM " + RetSqlName( "VV8" ) + " VV8 "
	cQuery += "WHERE VV8.VV8_FILIAL = '"+xFilial("VV8")+"' AND VV8.D_E_L_E_T_=' ' AND "
	cQuery += "VV8.VV8_TIPVEI='"+( cQAlVV2 )->VV2_TIPVEI+"'"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV8 , .F., .T. )
	
	If Select(cQAlSA1) > 0
		( cQAlSA1 )->( DbCloseArea() )
	EndIf
	cQuery := "SELECT SA1.A1_COD, SA1.A1_TEL, SA1.A1_DDD, SA1.A1_CGC, SA1.A1_NOME, SA1.A1_END, SA1.A1_BAIRRO, SA1.A1_MUN, SA1.A1_EST, SA1.A1_CEP, SA1.A1_EMAIL "
	If lA1RESQUE
		cQuery += " , SA1.A1_RESQUE "
	EndIf
	If lA1CELULAR
		cQuery += " , SA1.A1_CELULAR "
	EndIf
	If lA1NUMERO
		cQuery += " , SA1.A1_NUMERO "
	EndIf
	cQuery += "FROM " + RetSqlName( "SA1" ) + " SA1 "
	cQuery += "WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_=' ' AND "
	cQuery += "SA1.A1_COD='"+( cQAlVV1 )->VV1_PROATU+"' AND SA1.A1_LOJA='"+( cQAlVV1 )->VV1_LJPATU+"'"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSA1 , .F., .T. )
	
	if !Empty(mv_par09)
		if !alltrim( ( cQAlVV1 )->VV1_CODMAR ) $ alltrim(UPPER(MV_PAR09))
			DbSelectArea( cQAlVSC )
			DbSkip()
			Loop
		endif
	endif
	
	if Empty( ( cQAlVV1 )->VV1_CODCON ) .and. ( cQAlVV1 )->VV1_CODMAR $ cPreFab
		nPos := Ascan(aVei,{|x| x[1] == ( cQAlVV1 )->VV1_CHAINT})
		if nPos == 0
			if Len(aVei) == 1 .and. Empty(aVei[1,1])
				aVei := {}
			Endif
			aadd(aVei,{ ( cQAlVV1 )->VV1_CHAINT, ( cQAlVV1 )->VV1_MODVEI})
		Endif
		lcodcon := .F.
	endif
	
	if !Empty(mv_par07)
		if !(alltrim( ( cQAlVV8 )->VV8_TIPVEI ) $ ALLTRIM(UPPER(MV_PAR07)))
			DbSelectArea( cQAlVSC )
			DbSkip()
			Loop
		Endif
	Endif
	
	if aScan(aOsv, ( cQAlVSC )->VSC_NUMOSV+ ( cQAlVSC )->VSC_TIPTEM+ ( cQAlVSC )->VSC_TIPSER) > 0
		DbSelectArea( cQAlVSC )
		DbSkip()
		Loop
	EndIf
	
	aadd(aOsv, ( cQAlVSC )->VSC_NUMOSV+ ( cQAlVSC )->VSC_TIPTEM+ ( cQAlVSC )->VSC_TIPSER)
	
	If !( ( cQAlVOI )->VOI_SITTPO $ "2/4")  //SE FOR PUBLICO E INTERNO
		
		If Select(cQAlVOK) > 0
			( cQAlVOK )->( DbCloseArea() )
		EndIf
		cQuery := "SELECT VOK.VOK_AGRTIP, VOK.VOK_INCMOB "
		cQuery += "FROM " + RetSqlName( "VOK" ) + " VOK "
		cQuery += "WHERE VOK.VOK_FILIAL = '"+xFilial("VOK")+"' AND VOK.D_E_L_E_T_=' ' AND "
		cQuery += "VOK.VOK_TIPSER='"+( cQAlVSC )->VSC_TIPSER+"'"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVOK , .F., .T. )
		
		if ( cQAlVSC )->VSC_DEPGAR == "M"
			cMcvwt := "S"
			cImpVCli := STR0023  //"Mecanica"
			cImpVGar := space(8)
		endif
		
		If( ( cQAlVOK )->VOK_AGRTIP $ "7/D")
			
			if !alltrim( ( cQAlVOK )->VOK_INCMOB ) $ "4#5" //RETORNO DE SERV, KM SOCORRO
				cRev  := "S"
				cFun  := " "
				cPin  := " "
				cMec  := " "
				cRev1 := " "
				cFun1 := " "
				cPin1 := " "
				cMec1 := " "
			else
				DbSelectArea( cQAlVSC )
				DbSkip()
				Loop
			Endif
			
		ElseIf( ( cQAlVOK )->VOK_AGRTIP == "2") //FUNILARIA
			
			if !alltrim( ( cQAlVOK )->VOK_INCMOB) $ "4#5" //RETORNO DE SERV, KM SOCORRO
				cRev  := " "
				cFun  := "S"
				cPin  := " "
				cMec  := " "
				cRev1 := " "
				cFun1 := " "
				cPin1 := " "
				cMec1 := " "
			else
				DbSelectArea( cQAlVSC )
				DbSkip()
				Loop
			Endif
			
		ElseIf( ( cQAlVOK )->VOK_AGRTIP == "3") //PINTURA
			
			if !alltrim( ( cQAlVOK )->VOK_INCMOB) $ "4#5" //RETORNO DE SERV, KM SOCORRO
				cRev  := " "
				cFun  := " "
				cPin  := "S"
				cMec  := " "
				cRev1 := " "
				cFun1 := " "
				cPin1 := " "
				cMec1 := " "
			else
				DbSelectArea( cQAlVSC )
				DbSkip()
				Loop
			Endif
			
		Else   //MECANICA
			
			if !alltrim( ( cQAlVOK )->VOK_INCMOB) $ "4#5" // RETORNO DE SERV, KM SOCORRO
				cRev  := " "
				cFun  := " "
				cPin  := " "
				cMec  := "S"
				cRev1 := " "
				cFun1 := " "
				cPin1 := " "
				cMec1 := " "
			else
				DbSelectArea( cQAlVSC )
				DbSkip()
				Loop
			Endif
		EndIf
		
	Else //SE FOR GARANTIA/REVISAO
		
		If Select(cQAlVOK) > 0
			( cQAlVOK )->( DbCloseArea() )
		EndIf
		cQuery := "SELECT VOK.VOK_AGRTIP, VOK.VOK_INCMOB "
		cQuery += "FROM " + RetSqlName( "VOK" ) + " VOK "
		cQuery += "WHERE VOK.VOK_FILIAL = '"+xFilial("VOK")+"' AND VOK.D_E_L_E_T_=' ' AND "
		cQuery += "VOK.VOK_TIPSER='"+( cQAlVSC )->VSC_TIPSER+"'"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVOK , .F., .T. )
		
		If ( ( cQAlVOK )->VOK_AGRTIP $ "7/D")  //REVISAO e Rev Gratuita
			
			if ( cQAlVSC )->VSC_DEPGAR == "R" //18-05-2009 ::Carla Catiane - Alteracoes layout NATO
				cRvvwt := "S"
				cImpVGar := STR0016+space(1) //"Revisao"+space(1)
				cImpVCli := space(8)
				cMcvwt := ""
			elseif ( cQAlVSC )->VSC_DEPGAR == "M"
				cMcvwt := "S"
				cImpVGar := STR0023   //"Mecanica"
				cImpVCli := space(8)
				cRvvwt := ""
			endif
			
			if !alltrim( ( cQAlVOK )->VOK_INCMOB) $ "4#5" //RETORNO DE SERV, KM SOCORRO
				cRev1 := "S"
				cFun1 := " "
				cPin1 := " "
				cMec1 := " "
				cRev  := " "
				cFun  := " "
				cPin  := " "
				cMec  := " "
			else
				DbSelectArea( cQAlVSC )
				DbSkip()
				Loop
			Endif
		ElseIf( ( cQAlVOK )->VOK_AGRTIP == "2") //FUNILARIA
			
			if !alltrim( ( cQAlVOK )->VOK_INCMOB) $ "4#5" // RETORNO DE SERV, KM SOCORRO
				cRev1 := " "
				cFun1 := "S"
				cPin1 := " "
				cMec1 := " "
				cRev  := " "
				cFun  := " "
				cPin  := " "
				cMec  := " "
			else
				DbSelectArea( cQAlVSC )
				DbSkip()
				Loop
			Endif
		ElseIf ( ( cQAlVOK )->VOK_AGRTIP == "3") //PINTURA
			
			if !alltrim(( cQAlVOK )->VOK_INCMOB) $ "4#5" //RETORNO DE SERV, KM SOCORRO
				cRev1 := " "
				cFun1 := " "
				cPin1 := "S"
				cMec1 := " "
				cRev  := " "
				cFun  := " "
				cPin  := " "
				cMec  := " "
			else
				DbSelectArea( cQAlVSC )
				DbSkip()
				Loop
			Endif
		Else  //MECANICA
			
			if !alltrim(( cQAlVOK )->VOK_INCMOB) $ "4#5" // RETORNO DE SERV, KM SOCORRO
				cRev1 := " "
				cFun1 := " "
				cPin1 := " "
				cMec1 := "S"
				cRev  := " "
				cFun  := " "
				cPin  := " "
				cMec  := " "
			else
				DbSelectArea( cQAlVSC )
				DbSkip()
				Loop
			Endif
		EndIf
	EndIf
	
	If ( cQAlVOO )->(FieldPos("VOO_VOSKT")) # 0
		
		If ( cQAlVOO )->VOO_VOSKT == "S"
			cVolks := STR0049    //"Sim"
		ElseIf ( cQAlVOO )->VOO_VOSKT == "N"
			cVolks := STR0050    //"Nao"
			cImpVCli := space(8)
		EndIf
		
	EndIf
	
	npos :=  aScan(aImp,{|x| x[1]+x[2] = ( cQAlVSC )->VSC_NUMOSV+ ( cQAlVSC )->VSC_TIPTEM})
	if npos = 0
		
		// Verifica se o veiculo tem mais de uma OS com a mesma data e quilometragem,
		// caso tenha, serao listadas no final do relatorio as OS adicionais a primeira, ja que somente e contada uma passagem.
		//		If Ascan (aImp,{|x| x[3]+Str(x[19], 8) = ( cQAlVO1 )->VO1_CHAINT + Str( ( cQAlVO1 )->VO1_KILOME, 8) } ) == 0
		
		aadd(aImp,{( cQAlVSC )->VSC_NUMOSV,( cQAlVSC )->VSC_TIPTEM,( cQAlVO1 )->VO1_CHAINT,( cQAlSA1 )->A1_COD,cRev,cFun,cPin,cMec,cRev1,cFun1,cPin1,cMec1,Stod( ( cQAlVSC )->VSC_DATVEN ),cImpVCli,cImpVGar,cVolks,Stod(( cQAlVO1 )->VO1_DATABE),( cQAlVV1 )->VV1_CHASSI, ( cQAlVO1 )->VO1_KILOME })//CARLA
		
		//	   	EndIf
		
	else
		if !empty(cRev)
			aImp[npos,5]  := cRev
		endif
		if !empty(cFun)
			aImp[npos,6]  := cFun
		endif
		if !empty(cPin)
			aImp[npos,7]  := cPin
		endif
		if !empty(cMec)
			aImp[npos,8]  := cMec
		endif
		if !empty(cRev1)
			aImp[npos,9]  := cRev1
		endif
		if !empty(cFun1)
			aImp[npos,10] := cFun1
		endif
		if !empty(cPin1)
			aImp[npos,11] := cPin1
		endif
		if !empty(cMec1)
			aImp[npos,12] := cMec1
		endif
		if !empty(cImpVCli)
			aImp[npos,14] := cImpVCli
		endif
		if !empty(cImpVGar)
			aImp[npos,15] := cImpVGar
		endif
		if !empty(cVolks)
			aImp[npos,16] := cVolks
		endif
	endif
	
	if mv_par08 == 1 .and. lcodcon = .T.
		
		If Select(cQAlVVK) > 0
			( cQAlVVK )->( DbCloseArea() )
		EndIf
		cQuery := "SELECT VVK.VVK_REGIAO "
		cQuery += "FROM " + RetSqlName( "VVK" ) + " VVK "
		cQuery += "WHERE VVK.VVK_FILIAL = '"+xFilial("VVK")+"' AND VVK.D_E_L_E_T_=' ' AND "
		cQuery += "VVK.VVK_CODMAR='"+( cQAlVV1 )->VV1_CODMAR+"' AND VVK.VVK_CODCON='"+VE4->VE4_CODCON+"'"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVVK , .F., .T. )
		
		If Select(cQAlVOO) > 0
			( cQAlVOO )->( DbCloseArea() )
		EndIf
		
		cQuery := "SELECT VOO.VOO_NUMOSV, VOO.VOO_NUMNFI "
		If lVOOEnvNat
			cQuery += ", VOO.VOO_ENVNAT "
		Endif
		If lVOOVosKT
			cQuery += ", VOO.VOO_VOSKT "
		Endif
		cQuery += "FROM " + RetSqlName( "VOO" ) + " VOO "
		cQuery += "WHERE VOO.VOO_FILIAL = '"+xFilial("VOO")+"' AND VOO.D_E_L_E_T_=' ' AND "
		cQuery += "VOO.VOO_NUMOSV='"+( cQAlVSC )->VSC_NUMOSV+"' AND VOO.VOO_TIPTEM='"+( cQAlVSC )->VSC_TIPTEM+"'"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVOO , .F., .T. )
		
		If Select(cQAlVOI) > 0
			( cQAlVOI )->( DbCloseArea() )
		EndIf
		cQuery := "SELECT VOI.VOI_SITTPO "
		cQuery += "FROM " + RetSqlName( "VOI" ) + " VOI "
		cQuery += "WHERE VOI.VOI_FILIAL = '"+xFilial("VOI")+"' AND VOI.D_E_L_E_T_=' ' AND "
		cQuery += "VOI.VOI_TIPTEM='"+( cQAlVSC )->VSC_TIPTEM+"'"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVOI , .F., .T. )
		
		If Select(cQAlVO1) > 0
			( cQAlVO1 )->( DbCloseArea() )
		EndIf
		cQuery := "SELECT VO1.VO1_CHAINT, VO1.VO1_DATABE, VO1.VO1_KILOME, VO1.VO1_HORTRI "
		cQuery += "FROM " + RetSqlName( "VO1" ) + " VO1 "
		cQuery += "WHERE VO1.VO1_FILIAL = '"+xFilial("VO1")+"' AND VO1.D_E_L_E_T_=' ' AND "
		cQuery += "VO1.VO1_NUMOSV='"+( cQAlVSC )->VSC_NUMOSV+"'"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVO1 , .F., .T. )
		
		If Select(cQAlVV2) > 0
			( cQAlVV2 )->( DbCloseArea() )
		EndIf
		cQuery := "SELECT VV2.VV2_TIPVEI "
		cQuery += "FROM " + RetSqlName( "VV2" ) + " VV2 "
		cQuery += "WHERE VV2.VV2_FILIAL = '"+xFilial("VV2")+"' AND VV2.D_E_L_E_T_=' ' AND "
		cQuery += "VV2.VV2_CODMAR='"+( cQAlVV1 )->VV1_CODMAR+"' AND VV2.VV2_MODVEI='"+( cQAlVV1 )->VV1_MODVEI+"'"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV2 , .F., .T. )
		
		c_tel     := ""
		c_cel     := ""
		if AT("-",( cQAlSA1 )->A1_TEL) # 0
			c_Tel := Left(STUFF(( cQAlSA1 )->A1_TEL,AT("-",( cQAlSA1 )->A1_TEL),1,""),8)
		elseif AT(".",( cQAlSA1 )->A1_TEL) # 0
			c_Tel := Left(STUFF(( cQAlSA1 )->A1_TEL,AT(".",( cQAlSA1 )->A1_TEL),1,""),8)
		elseif AT(" ",left(( cQAlSA1 )->A1_TEL,9)) # 0
			ntotfor := len(Alltrim(( cQAlSA1 )->A1_TEL))
			cA1Tel  := Alltrim(( cQAlSA1 )->A1_TEL)
			c_Tel   := cA1Tel
			for i = 1 to ntotfor
				if AT(" ",left(cA1Tel,9)) # 0
					c_Tel  := STUFF(cA1Tel,AT(" ",cA1Tel),1,"")
					cA1Tel := c_Tel
				Endif
			Next
		else
			c_Tel := ( cQAlSA1 )->A1_TEL
		endif
		
		cDDDF := alltrim(( cQAlSA1 )->A1_DDD)
		cFone := left(c_tel,8)
		
		If lA1CELULAR
			if AT("-",( cQAlSA1 )->A1_CELULAR) # 0
				c_Tel := Left(STUFF(( cQAlSA1 )->A1_CELULAR,AT("-",( cQAlSA1 )->A1_CELULAR),1,""),8)
			elseif AT(".",( cQAlSA1 )->A1_CELULAR) # 0
				c_Tel := Left(STUFF(( cQAlSA1 )->A1_CELULAR,AT(".",( cQAlSA1 )->A1_CELULAR),1,""),8)
			elseif AT(" ",left(( cQAlSA1 )->A1_CELULAR,9)) # 0
				ntotfor := len(Alltrim(( cQAlSA1 )->A1_CELULAR))
				cA1Tel  := Alltrim(( cQAlSA1 )->A1_CELULAR)
				c_Tel   := cA1Tel
				for i = 1 to ntotfor
					if AT(" ",left(cA1Tel,9)) # 0
						c_Tel  := STUFF(cA1Tel,AT(" ",cA1Tel),1,"")
						cA1Tel := c_Tel
					Endif
				Next
			else
				c_Tel := ( cQAlSA1 )->A1_CELULAR
			endif
			
			cDDDC  := alltrim(( cQAlSA1 )->A1_DDD)
			cCelu  := left(c_tel,8)
			
		Else
			cCelu := "0"
		EndIf
		
		
		aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
		cBkpFil := SM0->(Recno())
		dbSelectArea("SM0")
		dbSetOrder(1)
		dbSeek(aSM0[1]+aSM0[2])
		
		DbSelectArea("VI8")
		lAchou:=dbSeek(xFilial("VI8")+( cQAlVV1 )->VV1_CODMAR+( cQAlSA1 )->A1_CGC+( cQAlVV1 )->VV1_CHASSI+right(str(( cQAlVO1 )->VO1_KILOME,8),7))
		if lAchou
			if ( cQAlVOI )->VOI_SITTPO # "2" .and. !empty(VI8->VI8_OSVCLI) .and. ( cQAlVSC )->VSC_NUMOSV <> VI8->VI8_OSVCLI
				RecLock("VI8",lAchou)
			elseif ( cQAlVOI )->VOI_SITTPO # "2" .and. empty(VI8->VI8_OSVCLI) .and. !empty(VI8->VI8_OSVGAR)
				RecLock("VI8",lAchou)			
			elseif ( cQAlVOI )->VOI_SITTPO # "2" .and. empty(VI8->VI8_OSVCLI)
				RecLock("VI8",!lAchou)
			elseif ( cQAlVOI )->VOI_SITTPO = "2" .and. !empty(VI8->VI8_OSVGAR) .and. ( cQAlVSC )->VSC_NUMOSV <> VI8->VI8_OSVGAR
				RecLock("VI8",lAchou)
			elseif ( cQAlVOI )->VOI_SITTPO = "2" .and. empty(VI8->VI8_OSVGAR) .and. !empty(VI8->VI8_OSVCLI)
				RecLock("VI8",lAchou)
			elseif ( cQAlVOI )->VOI_SITTPO = "2" .and. empty(VI8->VI8_OSVGAR)
				RecLock("VI8",!lAchou)
			else
				RecLock("VI8",!lAchou)
			endif
		else
			RecLock("VI8",!lAchou)
		endif
		VI8->VI8_FILIAL := xFilial("VI8")
		VI8->VI8_CODMAR := ( cQAlVV1 )->VV1_CODMAR
		VI8->VI8_TIPREG := "NAT"
		VI8->VI8_DNCONS := VE4->VE4_CODCON
		VI8->VI8_REGIAO := val(( cQAlVVK )->VVK_REGIAO)
		VI8->VI8_CGCEMP := aSM0[18]
		VI8->VI8_NOMEMP := aSM0[7]
		VI8->VI8_CIDEMP := SM0->M0_CIDENT
		VI8->VI8_ESTEMP := SM0->M0_ESTENT
		VI8->VI8_DTANAT := Stod( ( cQAlVSC )->VSC_DATVEN )
		VI8->VI8_DNORIG := ( cQAlVV1 )->VV1_CODCON
		VI8->VI8_SOFTHO := 6
		VI8->VI8_NOMCLI := ( cQAlSA1 )->A1_NOME
		VI8->VI8_INDPES := if(left(( cQAlSA1 )->A1_CGC,2) == "  ", " ",if(len(trim(( cQAlSA1 )->A1_CGC))<14,"F","J"))
		VI8->VI8_CGCCLI := ( cQAlSA1 )->A1_CGC
		VI8->VI8_ENDCLI := ( cQAlSA1 )->A1_END
		VI8->VI8_NUMERO := Iif( lA1NUMERO , ( cQAlSA1 )->A1_NUMERO , " ")
		VI8->VI8_COMPLE := " "
		VI8->VI8_BAICLI := ( cQAlSA1 )->A1_BAIRRO
		VI8->VI8_CIDCLI := ( cQAlSA1 )->A1_MUN
		VI8->VI8_ESTCLI := ( cQAlSA1 )->A1_EST
		VI8->VI8_CEPCLI := val(( cQAlSA1 )->A1_CEP)
		VI8->VI8_DDDFON := cDDDF
		VI8->VI8_CELULA := cCelu	// N 10  Piloto
		VI8->VI8_EMAIL  := ( cQAlSA1 )->A1_EMAIL
		VI8->VI8_CHASSI := ( cQAlVV1 )->VV1_CHASSI
		VI8->VI8_MODELO := left(( cQAlVV1 )->VV1_MODVEI,6) //Left(VVX->VVX_SEGMOD,3) + VVX->VVX_INCMOD // VV1->VV1_MODVEI // Piloto
		VI8->VI8_ANOVEI := val(substr(( cQAlVV1 )->VV1_FABMOD,1,4))

      if ( cQAlVO1 )->VO1_HORTRI > 0
   		VI8->VI8_KILOME := if(( cQAlVO1 )->VO1_HORTRI<=9999999,( cQAlVO1 )->VO1_HORTRI,val(right(str(( cQAlVO1 )->VO1_HORTRI,8),7)))
      else
   		VI8->VI8_KILOME := if(( cQAlVO1 )->VO1_KILOME<=9999999,( cQAlVO1 )->VO1_KILOME,val(right(str(( cQAlVO1 )->VO1_KILOME,8),7)))
      endif

		VI8->VI8_OSVCLI := if(( cQAlVOI )->VOI_SITTPO#"2",( cQAlVSC )->VSC_NUMOSV,VI8->VI8_OSVCLI)
		VI8->VI8_REVCLI := if(!empty(cRev),cRev,VI8->VI8_REVCLI)
		VI8->VI8_FUNCLI := if(!empty(cFun),cFun,VI8->VI8_FUNCLI)
		VI8->VI8_MECCLI := if(!empty(cMec),cMec,VI8->VI8_MECCLI)
		VI8->VI8_PINCLI := if(!empty(cPin),cPin,VI8->VI8_PINCLI)
		VI8->VI8_OSVGAR := if(( cQAlVOI )->VOI_SITTPO="2",( cQAlVSC )->VSC_NUMOSV,VI8->VI8_OSVGAR)
		VI8->VI8_REVGAR := if(!empty(cRev1),cREv1,VI8->VI8_REVGAR)
		VI8->VI8_FUNGAR := if(!empty(cFun1),cFun1,VI8->VI8_FUNGAR)
		VI8->VI8_MECGAR := if(!empty(cMec1),cMec1,VI8->VI8_MECGAR)
		VI8->VI8_PINGAR := if(!empty(cPin1),cPin1,VI8->VI8_PINGAR)
		VI8->VI8_REPONS := Iif( lA1RESQUE , ( cQAlSA1 )->A1_RESQUE , "" )
		If VI8->(FieldPos("VI8_DOC")) <> 0
			VI8->VI8_DOC    := ( cQAlVOO )->VOO_NUMNFI
		Endif
		
		If (AllTrim(( cQAlVV2 )->VV2_TIPVEI) $ AllTrim(Upper(MV_PAR10)))//Onibus
			if VI8->(FieldPos("VI8_TPVEI")) # 0
				VI8->VI8_TPVEI  := "O"
			endIf
		ElseIf (AllTrim(( cQAlVV2 )->VV2_TIPVEI) $ AllTrim(Upper(MV_PAR11)))//Caminhao
			if VI8->(FieldPos("VI8_TPVEI")) # 0
				VI8->VI8_TPVEI  := "C"
			endIf
		EndIf
		
		If ( cQAlVOO )->(FieldPos("VOO_VOSKT")) # 0 .And. (( cQAlVOO )->VOO_VOSKT == "S")
			VI8->VI8_OSVWT  := ( cQAlVOO )->VOO_NUMOSV
			VI8->VI8_RVVWT  := cRvvwt
			VI8->VI8_MCVWT  := cMcvwt
		EndIf
		
		If VI8->(FieldPos("VI8_TELFON")) <> 0
			VI8->VI8_TELFON := cFone
		Endif
		
		If VI8->(FieldPos("VI8_DDDCEL")) <> 0
			VI8->VI8_DDDCEL := cDDDC
		Endif
		
		MsUnlock()
		
		SM0->(DbGoto(cBkpFil))
		
		If Len(aImp) # 0 .And. Ascan (aImp,{|x| x[1] = ( cQAlVSC )->VSC_NUMOSV} ) == 0 ;
			.And. Ascan (aMostra,{|x| x[1] = ( cQAlVSC )->VSC_NUMOSV} ) == 0
			
			aadd( aMostra ,{ ( cQAlVSC )->VSC_NUMOSV,( cQAlVSC )->VSC_TIPTEM,( cQAlVV1 )->VV1_CHAINT,( cQAlVV1 )->VV1_CHASSI,Transform(( cQAlVO1 )->VO1_KILOME,"@E 99,999,999"),Stod(( cQAlVO1 )->VO1_DATABE),Stod( ( cQAlVSC )->VSC_DATVEN ) })
			
		Endif
		
	Endif
	
	If nLin >= 55
		nLin := 1
		nLin := Cabec(cTitulo,cCabec1,cCabec2,cNomProg, cTamanho,nCaracter)+1
	EndIf
	
	DbSelectArea( cQAlVSC )
	DbSkip()
	
Enddo

If Select(cQAlVSC) > 0
	( cQAlVSC )->( DbCloseArea() )
EndIf
If Select(cQAlVOO) > 0
	( cQAlVOO )->( DbCloseArea() )
EndIf
If Select(cQAlVV1) > 0
	( cQAlVV1 )->( DbCloseArea() )
EndIf
If Select(cQAlVV8) > 0
	( cQAlVV8 )->( DbCloseArea() )
EndIf
If Select(cQAlVOI) > 0
	( cQAlVOI )->( DbCloseArea() )
EndIf
If Select(cQAlVOK) > 0
	( cQAlVOK )->( DbCloseArea() )
EndIf
If Select(cQAlVVK) > 0
	( cQAlVVK )->( DbCloseArea() )
EndIf
If Select(cQAlVO1) > 0
	( cQAlVO1 )->( DbCloseArea() )
EndIf
If Select(cQAlVV2) > 0
	( cQAlVV2 )->( DbCloseArea() )
EndIf
If Select(cQAlSA1) > 0
	( cQAlSA1 )->( DbCloseArea() )
EndIf

DbSelectarea("VOO")
DbSetOrder(1)
DbSelectArea("SA1")
DbSetOrder(1)
DbSelectArea("VV1")
DbSetOrder(1)
DbSelectArea("VO1")
DbSetOrder(1)
DbSelectArea("VV2")
DbSetOrder(1)
DbSelectArea("VOI")
DbSetOrder(1)
DbSelectArea("VV8")
DbSetOrder(1)
DbSelectArea("VI8")
DBSetOrder(1)
DbSelectArea("VVK")
DBSetOrder(1)

asort(aImp,,,{|x,y| x[1] < y[1]})
for xi = 1 to len(aImp)
	
	VOO->(DbSeek(xFilial("VOO")+VSC->VSC_NUMOSV+VSC->VSC_TIPTEM))
	
	if lVOOEnvNat .and. VOO->VOO_ENVNAT == "N"
		DbSelectArea("VSC")
		DbSkip()
		Loop
	endif
	
	VOO->(MsSeek(xFilial("VOO")+aImp[xi,1]+aImp[xi,2]))
	VO1->(DbSeek(xFilial("VO1")+aImp[xi,1]))
	VOI->(MsSeek(xfilial("VOI")+aImp[xi,2]))
	VV1->(DbSeek(xFilial("VV1")+aImp[xi,3]))
	SA1->(MsSeek(xFilial("SA1")+VV1->VV1_PROATU))
	VVK->(MsSeek(xFilial("VVK")+VV1->VV1_CODMAR+VE4->VE4_CODCON))
	VV2->(MsSeek(xfilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	VV8->(MsSeek(xFilial("VV8")+VV2->VV2_TIPVEI))
	
	If nLin >= 60
		nLin := 1
		nLin := Cabec(cTitulo,cCabec1,cCabec2,cNomProg, cTamanho,nCaracter)+1
	EndIf
	
	@ nLin, 001 pSay STR0005   //"--Nro OS CodCli Lj CGC/CNPJ--------- ----------------------- Dados do Cliente ---------------------------+---------------- Dados do Veiculo ---------------+-------------------- Tipo de Servico ------------------------+"
	nLin++
	VAM->( DbSeek( xFilial("VAM") + SA1->A1_MUN + SA1->A1_EST ) )
	@ nLin, 001 pSay  aImp[xi,1]+" "+SA1->A1_COD+" "+SA1->A1_LOJA+" "+SA1->A1_CGC+" "+space(4)+STR0006+" "+Substr(SA1->A1_NOME,1,30)+" "+space(5)+STR0007+" "+left(VAM->VAM_DDD +" "+Alltrim(SA1->A1_TEL)+space(16),16)+"| "+STR0008+" "+substr(VV1->VV1_CHASSI,1,21)+" "+STR0009+" "+VV1->VV1_CHAINT+space(3)+" | "+STR0010+" | "+STR0011+space(19)+"  | "
	nLin++
	
	If lA1NUMERO
		@ nLin, 001 pSay space(9)+STR0029+Transform(VO1->VO1_DATABE,"@D")+space(7)+STR0030+" "+Substr(SA1->A1_END, 1,25)+STR0031+" "+Substr(SA1->A1_NUMERO, 1,5)+" "+STR0032+" "+left(SA1->A1_BAIRRO+space(5),16)+"| "+STR0014+" "+substr(VV2->VV2_MODVEI, 1,6)+" "+substr(VV2->VV2_DESMOD, 1,14)+" "+STR0015+" "+VV1->VV1_FABMOD+" | ("+aImp[xi,5]+")"+STR0016+"  ("+aImp[xi,6]+")"+STR0017+"  | ("+aImp[xi,9]+")"+STR0018+" "+ "("+aImp[xi,10]+")"+STR0017+"|  "
	Else
		@ nLin, 001 pSay space(9)+STR0029+Transform(VO1->VO1_DATABE,"@D")+space(7)+STR0030+" "+Substr(SA1->A1_END, 1,25)+STR0031+"       "+STR0032+" "+left(SA1->A1_BAIRRO+space(5),16)+"| "+STR0014+" "+substr(VV2->VV2_MODVEI, 1,6)+" "+substr(VV2->VV2_DESMOD, 1,14)+" "+STR0015+" "+VV1->VV1_FABMOD+" | ("+aImp[xi,5]+")"+STR0016+"  ("+aImp[xi,6]+")"+STR0017+"  | ("+aImp[xi,9]+")"+STR0018+" "+ "("+aImp[xi,10]+")"+STR0017+"|  "
	Endif
	nLin++
	@ nLin, 001 pSay space(9)+STR0033+Transform(aImp[xi,13],"@D")+space(7)+Substr(STR0019+" "+SA1->A1_MUN,1,23)+" "+STR0020+" "+SA1->A1_EST+space(14)+STR0034+" "+SA1->A1_CEP+space(8)+"| "+STR0035+" "+transform(VO1->VO1_KILOME, "@E 9,999,999")+if(VO1->VO1_HORTRI>0," / "+transform(VO1->VO1_HORTRI,"@E 9,999,999")+space(1),space(13))+STR0036+VV1->VV1_CODCON+space(2)+" | ("+aImp[xi,8]+")"+STR0023+" "+"("+aImp[xi,7]+")"+STR0024+space(3)+" | ("+aImp[xi,12]+")"+STR0023+space(9)+"("+aImp[xi,11]+")"+STR0024+space(1)+" | "
	nLin++
	
	@ nLin, 001 pSay space(38)+STR0037+" "+Iif(lA1RESQUE , left(SA1->A1_RESQUE,30) , Space(30))+space(6)+STR0038+IiF(lVOOEnvNat,VOO->VOO_ENVNAT," ") +space(15)+"| "+STR0039+" "+VOO->VOO_NUMNFI+space(13)+STR0040+" "+aImp[xi,16]+space(3)+"| "+STR0040+" "+aImp[xi,14]+space(6)+"| "+STR0040+" "+ aImp[xi,15] + space(12)+"|"
	nlin+=2
	
next


@ nLin, 001 pSay REPL("-",218)+"+"

if lcodcon = .F.
	MsgInfo(STR0041)   //"O arquivo para exportar nao foi gerado. Existem veiculos sem o codigo da concessionaria. Favor verificar e acertar o cadastro do veiculo "
endif
if Len(aVei) > 0 .and. !Empty(aVei[1,1])
	nOpca := 1
	
	DEFINE MSDIALOG oDlg1 FROM 000,000 TO 010,030 TITLE STR0042 OF oMainWnd     //"Veiculos sem codigo da concessionaria"
	
	@ 003,003 LISTBOX oLbx1 FIELDS HEADER  OemToAnsi(STR0009),OemToAnsi(STR0043) COLSIZES 15,100 SIZE 110,72 OF oDlg1 PIXEL
	oLbx1:SetArray(aVei)
	oLbx1:bLine := { || {  aVei[oLbx1:nAt,1],;
	aVei[oLbx1:nAt,2]}}
	
	ACTIVATE MSDIALOG oDlg1 CENTER //ON INIT EnchoiceBar(oDlg1, {|| if(FS_CHABAIXA(),(oDlg1:End(),nOpca := 1),.f.) } , {|| oDlg1:End(),nOpca := 2})
	if nOpca == 2
		Return   //Exit
	Endif
Endif

nLin := 60

cCabec1  := STR0044    //"Ordens de Servico com Chassi e Kilometragem Repetidos nao Enviados - NATO - Volkswagen"

For i := 1 to Len(aMostra)
	If nLin >= 60
		nLin := 1
		nLin := Cabec(cTitulo,cCabec1,cCabec2,cNomProg, cTamanho,nCaracter)+1
	EndIf
	
	@ nLin++,0 pSay STR0045 + aMostra[i,1]            //"O.S.           : "
	@ nLin++,0 pSay STR0046 + aMostra[i,4]            //"Chassi         : "
	@ nLin++,0 pSay STR0047 + Dtoc(aMostra[i,6])      //"Dt Abertura    : "
	@ nLin++,0 pSay STR0048 + Dtoc(aMostra[i,7])      //"Dt Venda       : "
	nLin += 2
	
Next

Eject

Set Printer to
Set device to Screen

MS_FLUSH()

If aReturn[5] == 1
	OurSpool(cNomeRel)
EndIf

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_TPO_OFIOR180()³ Autor ³RenataG.Ferrante Marteli ³01/04/04³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³Atual. o MV_PAR03/04/05/06 c/ Tipo Tpo Cli/Ga/Int/Seg.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ OFIOR180 - PERGUNTE OFR180                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TPO_OFIOR180()

Local cTpoCS := ""
Local cTpoGA := ""
Local cTpoIN := ""

DBSelectArea("VOI")
DbSetOrder(1)
DbSeek( xFilial("VOI") )
While !Eof() .and. VOI->VOI_FILIAL == xFilial("VOI")
	if VOI->VOI_SITTPO = "1"
		cTpoCS += VOI->VOI_TIPTEM+"/"
	elseif VOI->VOI_SITTPO = "2"
		cTpoGA += VOI->VOI_TIPTEM+"/"
	elseif VOI->VOI_SITTPO = "3"
		cTpoIN += VOI->VOI_TIPTEM+"/"
	endif
	DBSelectArea("VOI")
	DbSkip()
EndDo

MV_PAR03 := cTpoCS
MV_PAR04 := cTpoGA
MV_PAR05 := cTpoIN
MV_PAR06 := cTpoCS

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³ Microsiga          º Data ³  21/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao de pergunte para o relatorio                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidPerg()

Local i:=0, j:=0

_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))
aRegs:={}
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01",,,,,,,,,,"!Empty(mv_par01) .and. FS_TPO_OFIOR180()",,,,,,,,,,,,,,,,,,,,,,,,,,,})   //"Data inicial"
aAdd(aRegs,{cPerg,"02",,,,,,,,,,"!Empty(mv_par02)"                        ,,,,,,,,,,,,,,,,,,,,,,,,,,,})   //"Data Final"
aAdd(aRegs,{cPerg,"03",,,,,,90,,,,""                                        ,,,,,,,,,,,,,,,,,,,,,,,,,,,})   //"Tempo /p Cliente"
aAdd(aRegs,{cPerg,"04",,,,,,90,,,,""                                        ,,,,,,,,,,,,,,,,,,,,,,,,,,,})   //"Tempo /p Garantia"
aAdd(aRegs,{cPerg,"05",,,,,,90,,,,""                                        ,,,,,,,,,,,,,,,,,,,,,,,,,,,})   //"Tempo /p Interno"
aAdd(aRegs,{cPerg,"06",,,,,,90,,,,""                                        ,,,,,,,,,,,,,,,,,,,,,,,,,,,})   //"Tempo /p Seguro"
aAdd(aRegs,{cPerg,"07",,,,,,,,,,""                                        ,,,,,,,,,,,,,,,,,,,,,,,,,,,})   //"Tipo de veiculo"
aAdd(aRegs,{cPerg,"08",,,,,,,,,,""                                        ,,STR0049,,,,,STR0050,,,,,,,,,,,,,,,,,,,,})   //"Gera Arquivo"
aAdd(aRegs,{cPerg,"09",STR0051,,,"MV_CH9","C",30,,,"G",""               ,"mv_par09",,,,,,,,,,,,,,,,,,,,,,,,,,})   //"Marca"
aAdd(aRegs,{cPerg,"10",STR0052,STR0052,STR0052,"MV_CHA","C",80,,,"G",,"mv_par10",,,,,,,,,,,,,,,,,,,,,,,,,,"S"})	// "Tipo Veículo de Onibus"
aAdd(aRegs,{cPerg,"11",STR0053,STR0052,STR0052,"MV_CHB","C",80,,,"G",,"mv_par11",,,,,,,,,,,,,,,,,,,,,,,,,,"S"})	// "Tipo Veículo de Caminhão"

For i:=1 to Len(aRegs)
	
	DbSeek(cPerg+aRegs[i,2])
	
	RecLock("SX1", !Found() )
	For j:=1 to Len(aRegs[i])
		If aRegs[i,j] # NIL
			FieldPut(j,aRegs[i,j])
		EndIf
	Next
	MsUnlock()
	dbCommit()
	
Next
dbSelectArea(_sAlias)

Return
