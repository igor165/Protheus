#Include "PROTHEUS.CH"
#Include "FWCOMMAND.CH"
#Include "OFIOC526.CH"

#DEFINE MVC_STRUCT_ID        01 // Id do Field
#DEFINE MVC_STRUCT_ORDEM     02 // Ordem
#DEFINE MVC_STRUCT_TITULO    03 // Titulo do campo
#DEFINE MVC_STRUCT_DESCRICAO 04 // Descricao do campo
#DEFINE MVC_STRUCT_TIPO      05 // Tipo do campo
#DEFINE MVC_STRUCT_TAM       06 // Tamanho do campo
#DEFINE MVC_STRUCT_DEC       07 // Decimal do campo
#DEFINE MVC_STRUCT_CBOX      08 // Array	Lista de valores permitido do campo	{}		
#DEFINE MVC_STRUCT_OBRIGAT   09 // Indica se o campo tem preenchimento obrigatório
#DEFINE MVC_STRUCT_VIRTUAL   10 // Indica se o campo é virtual
#DEFINE MVC_STRUCT_PICTURE   11 // Picture
#DEFINE MVC_STRUCT_F3        12 // Consulta F3
#DEFINE MVC_STRUCT_ALTER     13 // Indica se o campo é alteravel
#DEFINE MVC_STRUCT_PASTA     14 // Pasta do campo
#DEFINE MVC_STRUCT_AGRP      15 // Agrupamento do campo

/*/{Protheus.doc} OFIOC526

Consulta os Orçamentos / Ordens de Serviços com reserva de peças 

@author rubens.takahashi
@since 10/06/2020
@version 1.0
@param lNoMBrowse, logical, Indica se o mBrowse será exibido
@type function

/*/
Function OFIOC526(lNoMBrowse)

Local cBkpFilial := cFilAnt
Local aArea := sGetArea(,"SB1")
Local bBlock

Default lNoMBrowse := .f.

Private cCadastro := STR0001
Private aRotina := MenuDef()

dbSelectArea("SB1")
If lNoMBrowse
	If ( nOpc <> 0 ) .And. !Deleted()
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
	EndIf
Else
	SetKey(VK_F12,{ || Pergunte( "OFIOC526" , .T. ,,,,.f.)})
	mBrowse( 6, 1,22,75,"SB1")
	SetKey( VK_F12, Nil )
EndIf
//

sRestArea(aArea)
cFilAnt := cBkpFilial
Return


Function OC526Visual(cAlias,nReg,nOpc)

Local aCpoRegistro := {}
Local cPictQtd := PesqPict("SB2","B2_QATU")

Private oSizePrinc
Private oSizeFiltro

Private oDlg526
Private obC526EncFiltro
Private obC526ResBAL
Private obC526ROFI
Private obC526ROS

Private a526FldFiltro

Static oC526Peca := MIL_PecaDao():New()
oC526Peca:SetGrupo(SB1->B1_GRUPO)
oC526Peca:SetCodigo(SB1->B1_CODITE)

// Calcula Coordenadas dos objetos
OC526CalcSize()

DEFINE MSDIALOG oDlg526 TITLE STR0001 OF oMainWnd PIXEL;
	FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4]

aCampos := { ;
		{ "B1_GRUPO"   , "" , .t. },;
		{ "B1_CODITE"  , "" , .t. },;
		{ "B1_DESC"    , "" , .t. },;
		{ "C526PARFIL" , "" , .f. }}

aCpoRegistro := {}
OC520AddField(aCampos, @a526FldFiltro, "OC526Field" )
aEval(a526FldFiltro,{ |x| &("M->" + x[2]) := OC526AtVal(x) , AADD( aCpoRegistro , x[2] ) })

obC526EncFiltro := MsmGet():New(,,2 /* Visualizar */,;
	/*aCRA*/,/*cLetras*/,/*cTexto*/,aClone(aCpoRegistro),;
	oSizeFiltro:GetObjectArea("FILTRO"), ;
	aClone(aCpoRegistro), 3 /*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlg526 , .t. /*lF3*/, .t. /* lMemoria */ , .t. /*lColumn*/,;
	/*caTela*/, .t. /*lNoFolder*/, .F. /*lProperty*/,;
	aClone(a526FldFiltro), /* aFolder */ , .f. /* lCreate */ , .t. /*lNoMDIStretch*/,/*cTela*/)
	
TButton():New( oSizeFiltro:GetDimension("BTN_ATUALIZA","LININI") + 2, oSizeFiltro:GetDimension("BTN_ATUALIZA","COLINI") + 2 ,;
	"Atualizar", oDlg526 , { || OC526Atu() }, 040, 010,,,.F.,.T.,.F.,,.F.,,,.F. )

// --------------------------------------- //
// Criacao do Listbox das Reservas BALCAO  //
// --------------------------------------- //
obC526ResBAL := TWBrowse():New( ;
	oSizePrinc:GetDimension("RESERVAS_BAL","LININI"),;
	oSizePrinc:GetDimension("RESERVAS_BAL","COLINI"),;
	oSizePrinc:GetDimension("RESERVAS_BAL","XSIZE"), ;
	oSizePrinc:GetDimension("RESERVAS_BAL","YSIZE") ,,,,oDlg526,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
//
obC526ResBAL:AddColumn( TCColumn():New( "Orçamento" , { || obC526ResBAL:aArray[obC526ResBAL:nAT,1] } ,,,,"LEFT"   ,050,.F.,.F.,,,,.F.,) ) // 
obC526ResBAL:AddColumn( TCColumn():New( "Data" , { || obC526ResBAL:aArray[obC526ResBAL:nAT,2] } ,,,,"LEFT"   ,035,.F.,.F.,,,,.F.,) ) // 
obC526ResBAL:AddColumn( TCColumn():New( "Hora" , { || obC526ResBAL:aArray[obC526ResBAL:nAT,3] } ,,,,"LEFT"   ,020,.F.,.F.,,,,.F.,) ) // 
obC526ResBAL:AddColumn( TCColumn():New( "Usuário", { || obC526ResBAL:aArray[obC526ResBAL:nAT,4] } ,,,,"LEFT"   ,35,.F.,.F.,,,,.F.,) ) // 
obC526ResBAL:AddColumn( TCColumn():New( "Nome", { || obC526ResBAL:aArray[obC526ResBAL:nAT,5] } ,,,,"LEFT"   ,70,.F.,.F.,,,,.F.,) ) // 
obC526ResBAL:AddColumn( TCColumn():New( "Total Reservado" , { || Transform(obC526ResBAL:aArray[obC526ResBAL:nAT,6], cPictQtd) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // 
//
obC526ResBAL:nAt := 1
obC526ResBAL:bLDblClick := { || OC526Reserv( "1" , obC526ResBAL:aArray[obC526ResBAL:nAT,1] ) }
obC526ResBAL:SetArray({})

// --------------------------------------- //
// Criacao do Listbox das Reservas OFICINA //
// --------------------------------------- //
obC526ROFI := TWBrowse():New( ;
	oSizePrinc:GetDimension("RESERVAS_OFI","LININI"),;
	oSizePrinc:GetDimension("RESERVAS_OFI","COLINI"),;
	oSizePrinc:GetDimension("RESERVAS_OFI","XSIZE"), ;
	oSizePrinc:GetDimension("RESERVAS_OFI","YSIZE") ,,,,oDlg526,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
//
obC526ROFI:AddColumn( TCColumn():New( "Ordem de Serviço" , { || obC526ROFI:aArray[obC526ROFI:nAT,1] } ,,,,"LEFT"   ,050,.F.,.F.,,,,.F.,) ) // 
obC526ROFI:AddColumn( TCColumn():New( "Data" , { || obC526ROFI:aArray[obC526ROFI:nAT,2] } ,,,,"LEFT"   ,035,.F.,.F.,,,,.F.,) ) // 
obC526ROFI:AddColumn( TCColumn():New( "Hora" , { || obC526ROFI:aArray[obC526ROFI:nAT,3] } ,,,,"LEFT"   ,020,.F.,.F.,,,,.F.,) ) // 
obC526ROFI:AddColumn( TCColumn():New( "Usuário", { || obC526ROFI:aArray[obC526ROFI:nAT,4] } ,,,,"LEFT"   ,35,.F.,.F.,,,,.F.,) ) // 
obC526ROFI:AddColumn( TCColumn():New( "Nome", { || obC526ROFI:aArray[obC526ROFI:nAT,5] } ,,,,"LEFT"   ,70,.F.,.F.,,,,.F.,) ) // 
obC526ROFI:AddColumn( TCColumn():New( "Total Reservado" , { || Transform(obC526ROFI:aArray[obC526ROFI:nAT,6], cPictQtd) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // 
//
obC526ROFI:nAt := 1
obC526ROFI:bLDblClick := { || OC526Reserv( "2" , obC526ROFI:aArray[obC526ROFI:nAT,1] ) }
obC526ROFI:SetArray({})


// ---------------------------------------------- //
// Criacao do Listbox das Reservas OS Requisitada //
// ---------------------------------------------- //
obC526ROS := TWBrowse():New( ;
	oSizePrinc:GetDimension("RESERVAS_OS","LININI"),;
	oSizePrinc:GetDimension("RESERVAS_OS","COLINI"),;
	oSizePrinc:GetDimension("RESERVAS_OS","XSIZE"), ;
	oSizePrinc:GetDimension("RESERVAS_OS","YSIZE") ,,,,oDlg526,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
//
obC526ROS:AddColumn( TCColumn():New( "Ordem de Serviço" , { || obC526ROS:aArray[obC526ROS:nAT,1] } ,,,,"LEFT"   ,050,.F.,.F.,,,,.F.,) ) // 
obC526ROS:AddColumn( TCColumn():New( "Data" , { || obC526ROS:aArray[obC526ROS:nAT,2] } ,,,,"LEFT"   ,035,.F.,.F.,,,,.F.,) ) // 
obC526ROS:AddColumn( TCColumn():New( "Hora" , { || obC526ROS:aArray[obC526ROS:nAT,3] } ,,,,"LEFT"   ,020,.F.,.F.,,,,.F.,) ) // 
obC526ROS:AddColumn( TCColumn():New( "Total Requisitado" , { || Transform(obC526ROS:aArray[obC526ROS:nAT,4], cPictQtd) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // 
//
obC526ROS:nAt := 1
obC526ROS:bLDblClick := { || OC526Reserv( "2" , obC526ROS:aArray[obC526ROS:nAT,1] ) }
obC526ROS:SetArray({})


// Atualiza Controles ...
OC526Atu()
//

ACTIVATE MSDIALOG oDlg526 ON INIT EnchoiceBar(oDlg526,{||oDlg526:End()},{||oDlg526:End()})

Return


Function OC526Field(cField)

Local aRetorno := Array(16)

aRetorno[MVC_STRUCT_ID       ] := cField
aRetorno[MVC_STRUCT_DEC      ] := 0
aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
aRetorno[MVC_STRUCT_VIRTUAL  ] := .T.
aRetorno[MVC_STRUCT_ALTER    ] := .F.

Do Case
Case cField == "C526PARFIL"
	aRetorno[MVC_STRUCT_TITULO   ] := "Filial"
	aRetorno[MVC_STRUCT_DESCRICAO] := "Filial"
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := FWSizeFilial()
	aRetorno[MVC_STRUCT_CBOX     ] := OC520RetFil()
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

EndCase

Return aRetorno


Static Function OC526AtVal(aAuxField)

Local xValue

Do Case
Case aAuxField[2] == "C526PARFIL"
	xValue := FWArrFilAtu()[SM0_CODFIL]
Case Left(aAuxField[2],3) == "B1_"
	xValue := &("SB1->" + AllTrim(aAuxField[2]))	
EndCase

If xValue <> NIL
	&("M->"+aAuxField[2]) := xValue
EndIf

Return xValue

Static Function OC526Atu()

Local cSQL
Local cAuxAlias := "TOC526"
Local aReserBAL := {}
Local aReserOFI := {}
Local aReserROS := {}            
Local oSqlHlp := DMS_SqlHelper():New()


If Empty(M->C526PARFIL)
	MsgAlert("Favor selecionar uma Filial!","Atenção")
	Return()
EndIf


AADD(aReserBAL, { "Total Geral" , "" , "" , "" , "" , 0 })
AADD(aReserOFI, { "Total Geral" , "" , "" , "" , "" , 0 })
AADD(aReserROS, { "Total Geral" , "" , "" , 0 })


// Ajusta a cFilAnt ...
cFilAnt := M->C526PARFIL

cSQL := OC526QRES(SB1->B1_CODITE, SB1->B1_GRUPO)

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAuxAlias , .F., .T. )
While !(cAuxAlias)->(Eof())
	If (cAuxAlias)->VE6_ORIREQ $ "13" // Balcao
		AADD(aReserBAL, { (cAuxAlias)->VE6_NUMORC,;
							StoD( Transform((cAuxAlias)->VE6_DATREG,"@D") ),;
							Transform((cAuxAlias)->VE6_HORREG,"@R 99:99") ,;
							(cAuxAlias)->VE6_CODUSU,;
							(cAuxAlias)->VAI_NOMTEC,;
							(cAuxAlias)->VE6_QTDITE })
		aReserBAL[1,6] += (cAuxAlias)->VE6_QTDITE
	Else // Oficina
		AADD(aReserOFI, { (cAuxAlias)->VE6_NUMOSV,;
							StoD( Transform((cAuxAlias)->VE6_DATREG,"@D") ),;
							Transform((cAuxAlias)->VE6_HORREG,"@R 99:99") ,;
							(cAuxAlias)->VE6_CODUSU,;
							(cAuxAlias)->VAI_NOMTEC,;
							(cAuxAlias)->VE6_QTDITE })
		aReserOFI[1,6] += (cAuxAlias)->VE6_QTDITE
	EndIf
	(cAuxAlias)->(dbSkip())
End

(cAuxAlias)->(dbCloseArea())

cSQL := "SELECT VO3.VO3_NUMOSV , VO1.VO1_DATABE , VO1.VO1_HORABE , VO3.VO3_GRUITE, VO3.VO3_CODITE, "
cSQL += " SUM(CASE VO2_DEVOLU WHEN '1' THEN VO3_QTDREQ ELSE VO3_QTDREQ * -1 END) VO3_QTDREQ "
cSQL += " FROM " + oSqlHlp:NoLock("VO3") + " "
cSQL += "  JOIN " + oSqlHlp:NoLock("VO2") + " ON VO2.VO2_FILIAL = '" + xFilial("VO2") + "' AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.VO3_NUMOSV = VO2.VO2_NUMOSV AND VO2.VO2_TIPREQ = 'P' AND VO2.D_E_L_E_T_ = ' '"
cSQL += "  JOIN " + oSqlHlp:NoLock("VO1") + " ON VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_NUMOSV = VO3.VO3_NUMOSV AND VO1.D_E_L_E_T_ = ' ' "
cSQL += "  JOIN " + oSqlHlp:NoLock("SF4") + " ON  SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO  = VO3.VO3_CODTES AND SF4.F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' "
cSQL += " WHERE VO3.VO3_FILIAL = '"+xFilial("VO3")+"'"
cSQL +=   " AND VO3.VO3_GRUITE = '" + SB1->B1_GRUPO  + "'"
cSQL +=   " AND VO3.VO3_CODITE = '" + SB1->B1_CODITE + "'"
cSQL +=   " AND VO3.VO3_DATFEC = '        '"
cSQL +=   " AND VO3.VO3_DATCAN = '        '"
cSQL +=   " AND VO3.D_E_L_E_T_ = ' ' "
cSQL += "GROUP BY VO3.VO3_NUMOSV , VO1.VO1_DATABE , VO1.VO1_HORABE, VO3.VO3_GRUITE, VO3.VO3_CODITE "
cSQL += "HAVING SUM(CASE VO2_DEVOLU WHEN '1' THEN VO3_QTDREQ ELSE VO3_QTDREQ * -1 END) > 0 " 

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAuxAlias , .F., .T. )

While !(cAuxAlias)->(Eof())
	
	nPos := aScan(aReserROS,{|x| x[1] == (cAuxAlias)->VO3_NUMOSV})
	If nPos = 0
		AADD(aReserROS, { (cAuxAlias)->VO3_NUMOSV,;
							StoD( Transform((cAuxAlias)->VO1_DATABE,"@D") ),;
							Transform((cAuxAlias)->VO1_HORABE,"@R 99:99") ,;
							(cAuxAlias)->VO3_QTDREQ })
	Else
		aReserROS[nPos,4] += (cAuxAlias)->VO3_QTDREQ
	EndIf
	
	aReserROS[1,4] += (cAuxAlias)->VO3_QTDREQ
			
	(cAuxAlias)->(dbSkip())
EndDo

(cAuxAlias)->(dbCloseArea())

dbSelectArea("VE6")

obC526ResBAL:nAt := 1
obC526ResBAL:SetArray(aReserBAL)
obC526ResBAL:Refresh()

obC526ROFI:nAt := 1
obC526ROFI:SetArray(aReserOFI)
obC526ROFI:Refresh()

obC526ROS:nAt := 1
obC526ROS:SetArray(aReserROS)
obC526ROS:Refresh()

Return

Static Function OC526Reserv( cTipo , cSeek )

Local aArea := sGetArea(,"SB1")

If cTipo == "1" // Balcao
	dbSelectArea("VS1")
	dbSetOrder(1)
	if dbSeek(xFilial("VS1")+cSeek)
		OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
	Else
		MsgInfo("Orçamento não encontrado.")
	Endif
Else // Oficina
	DbSelectArea("VO1")
	DbSetOrder(1)
	If DbSeek(xFilial("VO1")+cSeek)
		OC060("VO1",Recno(),2)
	Else
		MsgInfo("Ordem de Serviço não encontrada.")
	Endif
EndIf

sRestArea(aArea)

Return

Static Function OC526CalcSize()

oSizePrinc := FwDefSize():New(.t.)
oSizePrinc:aMargins := { 0 , 2 , 0 , 0 }
oSizePrinc:AddObject("SUP" , 100 , 070 , .T. , .F. )
oSizePrinc:AddObject("RESERVAS_BAL" , 100 , 100 , .T. , .T. )
oSizePrinc:AddObject("RESERVAS_OFI" , 100 , 080 , .T. , .T. )
oSizePrinc:AddObject("RESERVAS_OS" , 100 , 100 , .T. , .T. )
oSizePrinc:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
oSizePrinc:Process()	// Calcula Coordenadas

oSizeFiltro := FWDefSize():New(.f.)
oSizeFiltro:aWorkArea := oSizePrinc:GetNextCallArea("SUP")
oSizeFiltro:aMargins := { 2 , 2 , 2 , 2 }
oSizeFiltro:AddObject("FILTRO"      ,100,100,.t.,.t.)
oSizeFiltro:AddObject("BTN_ATUALIZA",045,100,.f.,.t.)
oSizeFiltro:lLateral := .t.	// Calcula em colunas
oSizeFiltro:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
oSizeFiltro:Process()

Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | MenuDef    | Autor | Takahashi             | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Definicao de Menu                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function MenuDef()

Local aRotina:= {;
	{ STR0002 , "PesqBrw"   , 0 , 1},; // Pesquisar
	{ STR0003 , "OC526Visual"  , 0 , 2} } // Visualizar
Return aRotina

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC526QRES  | Autor | Vinicius Gati         | Data | 18/05/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Retorna query para obtenção de peças reservadas              |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Autopeças/Oficina                                            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OC526QRES(cCodite, cGrupo)
	Local cSQL    := ""
	Local oSqlHlp := DMS_SqlHelper():New()

	cSQL += " SELECT DISTINCT VE6_ORIREQ , VE6_NUMORC , VE6_NUMOSV , VE6_DATREG , VE6_HORREG , "
	cSQL += "                 VE6_CODUSU , VAI_NOMTEC , VE6_QTDITE , R_E_C_N_O_ "
	cSQL += " FROM ( "
	cSQL += "   SELECT VE6.VE6_ORIREQ , VE6.VE6_NUMORC , VE6.VE6_NUMOSV , VE6.VE6_DATREG , "
	cSQL += "          VE6.VE6_HORREG , VE6.VE6_CODUSU , VAI.VAI_NOMTEC , VE6.VE6_QTDITE, VE6.R_E_C_N_O_ "
	cSQL += "   FROM " + oSqlHlp:NoLock("VE6") + " "
	cSQL += "      LEFT JOIN " + oSqlHlp:NoLock("VAI") + " ON (VAI.VAI_FILIAL = '" + xFilial("VAI") + "' "
	cSQL += "         AND VAI.VAI_CODUSR <> ' ' AND VAI.VAI_CODUSR = VE6.VE6_CODUSU AND VAI.D_E_L_E_T_=' ') "
	cSQL += "   WHERE VE6.VE6_FILIAL = '" + xFilial("VE6") + "' "
	cSQL +=     " AND VE6.VE6_INDREG = '3' "
	cSQL += "     AND VE6.VE6_GRUITE = '" + cGrupo + "' AND VE6.VE6_CODITE = '" + cCodite + "' "

	// CI : 003647
	// Se o VE6_ORIREQ = ‘1’ só pode listar se VE6_QTDITE > 0
	// Se o VE6_ORIREQ = ‘2’ só pode listar se VE6_QTDITE - VE6_QTDATE - VE6_QTDEST > 0
	//cSQL += "     AND CASE VE6_ORIREQ WHEN '1' THEN VE6_QTDITE WHEN '2' THEN VE6_QTDITE - VE6_QTDATE - VE6_QTDEST END > 0 "
	cSQL += "     AND VE6.VE6_ORIREQ in ('1','3') " // Reserva de Balcao
	cSQL += "     AND VE6.VE6_QTDITE > 0 "

	// ORCAMENTO COM CERTOS STATUS nao deve aparecer nos reservados
	// (essa regra significa que se for para o loja contabiliza a reserva, senao nao)
	cSQL += "     AND VE6_NUMORC IN ( "
	cSQL += "        SELECT VS1.VS1_NUMORC "
	cSQL += "        FROM " + oSqlHlp:NoLock('VS1') + " "
	cSQL += "        WHERE VS1.VS1_FILIAL = '" + xFilial('VS1') + "' "
	cSQL += "           AND VS1.VS1_NUMORC <> ' ' AND VS1.VS1_STATUS NOT IN (' ', 'C') "
	cSQL += "           AND (VS1.VS1_TIPORC <> 'P' OR (VS1.VS1_TIPORC = 'P' AND VS1.VS1_PEDSTA <> '2')) "
	cSQL += "           AND (CASE WHEN VS1_NUMNFI <> '' THEN VS1.VS1_STATUS ELSE 'L' END) <> 'X' "
	cSQL += "              AND VS1.D_E_L_E_T_ = ' ') "
	cSQL += "     AND VE6.D_E_L_E_T_ = ' ' "

	cSQL += "   UNION ALL "

	cSQL += "   SELECT VE6.VE6_ORIREQ , VE6.VE6_NUMORC , VE6.VE6_NUMOSV , VE6.VE6_DATREG , VE6.VE6_HORREG , "
	cSQL += "          VE6.VE6_CODUSU , VAI.VAI_NOMTEC , (VE6.VE6_QTDITE - VE6.VE6_QTDATE - VE6.VE6_QTDEST) VE6_QTDITE , VE6.R_E_C_N_O_ "
	cSQL += "   FROM " + oSqlHlp:NoLock("VE6") + " "
	cSQL += "      LEFT JOIN " + oSqlHlp:NoLock("VAI") + " ON (VAI.VAI_FILIAL = '" + xFilial("VAI") + "' "
	cSQL += "         AND VAI.VAI_CODUSR <> ' ' AND VAI.VAI_CODUSR = VE6.VE6_CODUSU AND VAI.D_E_L_E_T_ = ' ') "
	cSQL += "   WHERE VE6.VE6_FILIAL = '" + xFilial("VE6") + "'"
	cSQL += "     AND VE6.VE6_INDREG = '3' "
	cSQL += "     AND VE6.VE6_GRUITE = '" + cGrupo + "' AND VE6.VE6_CODITE = '" + cCodite + "'"

	// CI : 003647
	// Se o VE6_ORIREQ = ‘1’ só pode listar se VE6_QTDITE > 0
	// Se o VE6_ORIREQ = ‘2’ só pode listar se VE6_QTDITE - VE6_QTDATE - VE6_QTDEST > 0
	cSQL += "     AND VE6.VE6_ORIREQ = '2' " // Reserva de Oficina
	cSQL += "     AND (VE6.VE6_QTDITE - VE6.VE6_QTDATE - VE6.VE6_QTDEST) > 0 "

	cSQL += "   AND VE6.D_E_L_E_T_ = ' ' "
	cSQL += " ) VE6 "
Return cSQL
