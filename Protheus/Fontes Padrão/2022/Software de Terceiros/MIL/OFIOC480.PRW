// …ÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕª
// ∫ Versao ∫ 6      ∫
// »ÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕº

#Include "PROTHEUS.CH"
#Include "OFIOC480.CH"
  
/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007756_1"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ OFIOC480 ∫ Autor ≥ Andre Luis Almeida ∫ Data ≥  01/11/11   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Consulta Movimentacoes das Ferramentas                     ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFIOC480()
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private cCodProGet := space(VDP->(TamSX3("VDP_CODPRO")[1]))
Private cCodFerGet := space(VO9->(TamSX3("VO9_CODFER")[1]))
Private cCodPro := space(VDP->(TamSX3("VDP_CODPRO")[1]))
Private cGruFer := space(VO9->(TamSX3("VO9_GRUFER")[1]))
Private cCodFer := space(VO9->(TamSX3("VO9_CODFER")[1]))
Private dDatIni := ctod("")
Private dDatFin := dDataBase
Private cTipMov := ""
Private aTipMov := X3CBOXAVET("VDP_TIPMOV","1")
Private aFilFer := {}
Private aUltFer := {}
Private aNewBot := { { "IMPRESSAO" , { || FS_IMPRIMIR() } , STR0013 } } // Imprimir Saldo Atual
Private cDatHor := ""

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox 1
aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox 2

aPos := MsObjSize( aInfo, aObjects )

Processa( {|| FS_FILTRAR(0) } )

aAdd(aFilFer,{ctod(""),"","",0,"","",0})

DEFINE MSDIALOG oOC480Fer FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0001 OF oMainWnd PIXEL // Movimentacoes das Ferramentas

@ aPos[1,1]+000, aPos[1,2] TO aPos[1,3],aPos[1,4]-2 LABEL (STR0012) OF oOC480Fer PIXEL // Saldo Atual
@ aPos[1,1]+030, aPos[1,2] LISTBOX oLbUltF ;
	FIELDS ;
	HEADER	STR0003,; // Produtivo
					STR0005,; // Grupo
					STR0004,; // Ferramenta
					STR0011,; // Qtde
					STR0016 ; // Saldo Atual
	COLSIZES 110,110,170,40;
	SIZE aPos[1,4]-5, aPos[1,3] - aPos[1,1] - 31;
	OF oOC480Fer PIXEL
oLbUltF:SetArray(aUltFer)
oLbUltF:bLine := { || { ;
	Alltrim(aUltFer[oLbUltF:nAt,01])+" - "+aUltFer[oLbUltF:nAt,02] ,; // Produtivo
	Alltrim(aUltFer[oLbUltF:nAt,03])+" - "+aUltFer[oLbUltF:nAt,04] ,; // Grupo
	Alltrim(aUltFer[oLbUltF:nAt,05])+" - "+aUltFer[oLbUltF:nAt,06] ,; // Ferramenta
	FG_AlinVlrs(Transform(aUltFer[oLbUltF:nAt,07],"@E 99999")),;
	FG_AlinVlrs(Transform(aUltFer[oLbUltF:nAt,08],"@E 99999")) }}


@ aPos[1,1]+010,aPos[1,2]+003 SAY STR0003 SIZE 60,8 OF oOC480Fer PIXEL COLOR CLR_BLUE // Produtivo
@ aPos[1,1]+018,aPos[1,2]+003 MSGET oTxtProdutivo  VAR cCodProGet PICTURE "@!" SIZE 25,08 F3 "VAI1" VALID ( Empty(cCodPro) .or. FG_Seek("VAI","cCodPro",1,.f.) ) OF oOC480Fer PIXEL COLOR CLR_BLUE HASBUTTON

@ aPos[1,1]+010,aPos[1,2]+053 SAY STR0004 SIZE 60,8 OF oOC480Fer PIXEL COLOR CLR_BLUE // Ferramenta
@ aPos[1,1]+018,aPos[1,2]+053 MSGET oTxtFerramenta VAR cCodFerGet PICTURE "@!" SIZE 70,08 F3 "VO9" VALID ( Empty(cCodFer) .or. FG_Seek("VO9","cCodFer",1,.f.,"cGruFer","VO9_GRUFER") ) OF oOC480Fer PIXEL COLOR CLR_BLUE HASBUTTON

@ aPos[1,1]+018,aPos[1,4]-060 MSGET oDatHor VAR cDatHor SIZE 55,08 OF oOC480Fer PIXEL COLOR CLR_BLUE WHEN .F.
@ aPos[1,1]+018,aPos[1,4]-110 BUTTON oRefrLBox PROMPT STR0015 OF oOC480Fer SIZE 45,10 PIXEL ACTION Processa( {|| FS_FILTRAR(1) } ) // Atualizar

@ aPos[2,1]+000,aPos[2,2] TO aPos[2,3]-33,aPos[2,4]-2 LABEL STR0002 OF oOC480Fer PIXEL // Filtra Movimentacoes

@ aPos[2,1]+009,aPos[2,2]+005 SAY STR0006 SIZE 60,8 OF oOC480Fer PIXEL COLOR CLR_BLUE // Periodo
@ aPos[2,1]+017,aPos[2,2]+005 MSGET oDatIni VAR dDatIni PICTURE "@D" SIZE 45,08 OF oOC480Fer PIXEL COLOR CLR_BLUE HASBUTTON
@ aPos[2,1]+017,aPos[2,2]+054 SAY STR0007 SIZE 5,8 OF oOC480Fer PIXEL COLOR CLR_BLUE // a
@ aPos[2,1]+017,aPos[2,2]+062 MSGET oDatFin VAR dDatFin PICTURE "@D" SIZE 45,08 OF oOC480Fer PIXEL COLOR CLR_BLUE HASBUTTON

@ aPos[2,1]+009,aPos[2,2]+110 SAY STR0003 SIZE 60,8 OF oOC480Fer PIXEL COLOR CLR_BLUE // Produtivo
@ aPos[2,1]+017,aPos[2,2]+110 MSGET oCodPro VAR cCodPro PICTURE "@!" SIZE 25,08 F3 "VAI1" VALID ( Empty(cCodPro) .or. FG_Seek("VAI","cCodPro",1,.f.) ) OF oOC480Fer PIXEL COLOR CLR_BLUE HASBUTTON

@ aPos[2,1]+009,aPos[2,2]+150 SAY STR0008 SIZE 60,8 OF oOC480Fer PIXEL COLOR CLR_BLUE // Tipo Movimentacao
@ aPos[2,1]+017,aPos[2,2]+150 MSCOMBOBOX oTipMov VAR cTipMov SIZE 50,08 ITEMS aTipMov OF oOC480Fer PIXEL COLOR CLR_BLUE

@ aPos[2,1]+009,aPos[2,2]+207 SAY STR0004 SIZE 60,8 OF oOC480Fer PIXEL COLOR CLR_BLUE // Ferramenta
@ aPos[2,1]+017,aPos[2,2]+207 MSGET oCodFer VAR cCodFer PICTURE "@!" SIZE 70,08 F3 "VO9" VALID ( Empty(cCodFer) .or. FG_Seek("VO9","cCodFer",1,.f.,"cGruFer","VO9_GRUFER") ) OF oOC480Fer PIXEL COLOR CLR_BLUE HASBUTTON

@ aPos[2,1]+009,aPos[2,2]+282 SAY STR0005 SIZE 60,8 OF oOC480Fer PIXEL COLOR CLR_BLUE // Grupo
@ aPos[2,1]+017,aPos[2,2]+282 MSGET oGruFer VAR cGruFer PICTURE "@!" SIZE 70,08 F3 "VOA" VALID ( Empty(cGruFer) .or. FG_Seek("VOA","cGruFer",1,.f.) ) OF oOC480Fer PIXEL COLOR CLR_BLUE HASBUTTON WHEN (Empty(cCodFer))

@ aPos[2,1]+013,aPos[2,4]-070 BUTTON oFiltrar PROMPT STR0009 OF oOC480Fer SIZE 60,10 PIXEL ACTION Processa( {|| FS_FILTRAR(2) } ) // Filtrar

@ aPos[2,1]+030,aPos[2,2]+000 LISTBOX oLbFilt FIELDS;
	HEADER 	STR0010,; // Data
					STR0003,; // Produtivo
					STR0008,; // Tipo Movimentacao
					STR0011,; // Qtde
					STR0005,; // Grupo
					STR0004 ; // Ferramenta
	COLSIZES 30,110,50,40,110,170;
	SIZE aPos[2,4]-5,aPos[2,3]-aPos[2,1]-33;
	OF oOC480Fer PIXEL ON DBLCLICK OFC480VDP(aFilFer[oLbFilt:nAt,07])

oLbFilt:SetArray(aFilFer)
oLbFilt:bLine := { || { Transform(aFilFer[oLbFilt:nAt,01],"@D") ,;
						aFilFer[oLbFilt:nAt,02] ,;
						aFilFer[oLbFilt:nAt,03] ,;
						FG_AlinVlrs(Transform(aFilFer[oLbFilt:nAt,04],"@E 99999")) ,;
						aFilFer[oLbFilt:nAt,05] ,;
						aFilFer[oLbFilt:nAt,06] }}

ACTIVATE MSDIALOG oOC480Fer ON INIT EnchoiceBar(oOC480Fer,{ || oOC480Fer:End() }, { || oOC480Fer:End() },,aNewBot)

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_FILTRAR∫ Autor ≥ Andre Luis Almeida ∫ Data ≥  03/11/11   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Filtra/Levanta Movimentacoes das Ferramentas               ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_FILTRAR(nTp)
Local cQuery   := ""
Local cQAlSQL  := "SQLFERRAM"
Local lSaldoB2 := ( GetNewPar("MV_MIL0076","S") == "S" )
Local aParSQL  := {}
Local cFerr    := "INICIAL"
Local nSald    := 0
If nTp <= 1 // Levanta utilizacao ATUAL das Ferramentas / % de utilizacao
	aParSQL := OFIOC48002_SQLNAMES() // Monta vetor com os Nomes/xFilial das Tabelas utilizadas no SQL
	cDatHor := Transform(dDataBase,"@D")+" "+left(time(),5)+STR0014
	aUltFer := {}
	cQuery  := "SELECT * FROM ( "
	cQuery  += "   SELECT "
	cQuery  += "      TMP.VDP_CODPRO , TMP.VAI_NOMTEC , "
	cQuery  += "      TMP.VO9_GRUFER , TMP.VOA_DESGRU , "
	cQuery  += "      TMP.VD3_CODFER , TMP.VO9_DESFER , "
	cQuery  += "      SUM(TMP.QTDTOT) AS QTDTOT "
	cQuery  += "     FROM ("
	cQuery  += "         SELECT "
	cQuery  += "            VDP.VDP_CODPRO , VAI.VAI_NOMTEC , "
	cQuery  += "            VO9.VO9_GRUFER , VOA.VOA_DESGRU , "
	cQuery  += "            VD3.VD3_CODFER , VO9.VO9_DESFER , "
	cQuery  += "            CASE "
	cQuery  += "                 WHEN VDP.VDP_TIPMOV = '1' THEN SUM(VD3.VD3_QTDMOV) "
	cQuery  += "                                           ELSE SUM(VD3.VD3_QTDMOV) * -1 "
	cQuery  += "                 END QTDTOT "
	cQuery  += "           FROM "+aParSQL[5,1]+" VDP "
	cQuery  += "           JOIN "+aParSQL[4,1]+" VD3 ON ( VD3.VD3_FILIAL='"+aParSQL[4,2]+"' AND VD3.VD3_CODIGO=VDP.VDP_CODIGO AND VD3.D_E_L_E_T_=' ' ) "
	cQuery  += "           JOIN "+aParSQL[6,1]+" VAI ON ( VAI.VAI_FILIAL='"+aParSQL[6,2]+"' AND VAI.VAI_CODTEC=VDP.VDP_CODPRO AND VAI.D_E_L_E_T_=' ' ) "
	cQuery  += "           JOIN "+aParSQL[1,1]+" VO9 ON ( VO9.VO9_FILIAL='"+aParSQL[1,2]+"' AND VO9.VO9_CODFER=VD3.VD3_CODFER AND VO9.D_E_L_E_T_=' ' ) "
	cQuery  += "           JOIN "+aParSQL[7,1]+" VOA ON ( VOA.VOA_FILIAL='"+aParSQL[7,2]+"' AND VOA.VOA_GRUFER=VO9.VO9_GRUFER AND VOA.D_E_L_E_T_=' ' ) "
	cQuery  += "          WHERE VDP.VDP_FILIAL='"+aParSQL[5,2]+"' AND VDP.D_E_L_E_T_=' ' "
	If !Empty(cCodProGet)
		cQuery += "         AND VDP.VDP_CODPRO='"+cCodProGet+"' "
	EndIf
	If !Empty(cCodFerGet)
		cQuery += "         AND VD3.VD3_CODFER='"+cCodFerGet+"' "
	EndIf
	cQuery  += "          GROUP BY VDP.VDP_CODPRO , VAI.VAI_NOMTEC , "
	cQuery  += "                   VO9.VO9_GRUFER , VOA.VOA_DESGRU , "
	cQuery  += "                   VD3.VD3_CODFER , VO9.VO9_DESFER , "
	cQuery  += "                   VDP.VDP_TIPMOV "
	cQuery  += "        ) TMP "
	cQuery  += "    GROUP BY TMP.VDP_CODPRO , TMP.VAI_NOMTEC , "
	cQuery  += "             TMP.VO9_GRUFER , TMP.VOA_DESGRU , "
	cQuery  += "             TMP.VD3_CODFER , TMP.VO9_DESFER "
	cQuery  += ") TOT "
	cQuery  += "WHERE TOT.QTDTOT > 0 "
	cQuery  += "ORDER BY TOT.VO9_GRUFER , TOT.VD3_CODFER , TOT.VDP_CODPRO "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	While !( cQAlSQL )->( Eof() )
		If cFerr <> ( cQAlSQL )->( VO9_GRUFER )+( cQAlSQL )->( VD3_CODFER )
			cFerr := ( cQAlSQL )->( VO9_GRUFER )+( cQAlSQL )->( VD3_CODFER )
			nSald := OFIOC48001_SaldoFerr( ( cQAlSQL )->( VD3_CODFER ) , ( cQAlSQL )->( VO9_GRUFER ) , lSaldoB2 , aParSQL )
		EndIf
		aAdd(aUltFer,{	( cQAlSQL )->( VDP_CODPRO ),;
						( cQAlSQL )->( VAI_NOMTEC ),;
						( cQAlSQL )->( VO9_GRUFER ),;
						( cQAlSQL )->( VOA_DESGRU ),;
						( cQAlSQL )->( VD3_CODFER ),;
						( cQAlSQL )->( VO9_DESFER ),;
						( cQAlSQL )->( QTDTOT ),;
						nSald })
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("VDP")
	If len(aUltFer) <= 0
		aAdd(aUltFer,{"","","","","","",0,0})
	EndIf
	If nTp == 1
		oDatHor:Refresh()
		oLbUltF:nAt := 1
		oLbUltF:SetArray(aUltFer)
		oLbUltF:bLine := { || { Alltrim(aUltFer[oLbUltF:nAt,01])+" - "+aUltFer[oLbUltF:nAt,02] ,;
								Alltrim(aUltFer[oLbUltF:nAt,03])+" - "+aUltFer[oLbUltF:nAt,04] ,;
								Alltrim(aUltFer[oLbUltF:nAt,05])+" - "+aUltFer[oLbUltF:nAt,06] ,;
								FG_AlinVlrs(Transform(aUltFer[oLbUltF:nAt,07],"@E 99999")),;
								FG_AlinVlrs(Transform(aUltFer[oLbUltF:nAt,08],"@E 99999")) }}
	EndIf
Else // nTp > 1 // Levanta Movimentacao das Ferramentas pelo Filtro
	aFilFer := {}
	cQuery  := "SELECT VDP.R_E_C_N_O_ AS RECVDP , VDP.VDP_DATMOV , VDP.VDP_CODPRO , VAI.VAI_NOMTEC , VO9.VO9_GRUFER , "
	cQuery  += "       VOA.VOA_DESGRU , VD3.VD3_CODFER , VO9.VO9_DESFER , VDP.VDP_TIPMOV , VD3.VD3_QTDMOV "
	cQuery  += "FROM "+RetSqlName("VDP")+" VDP "
	cQuery  += "JOIN "+RetSqlName("VD3")+" VD3 ON ( VD3.VD3_FILIAL='"+xFilial("VD3")+"' AND VD3.VD3_CODIGO=VDP.VDP_CODIGO AND VD3.D_E_L_E_T_=' ' ) "
	cQuery  += "JOIN "+RetSqlName("VAI")+" VAI ON ( VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODTEC=VDP.VDP_CODPRO AND VAI.D_E_L_E_T_=' ' ) "
	cQuery  += "JOIN "+RetSqlName("VO9")+" VO9 ON ( VO9.VO9_FILIAL='"+xFilial("VO9")+"' AND VO9.VO9_CODFER=VD3.VD3_CODFER AND VO9.D_E_L_E_T_=' ' ) "
	cQuery  += "JOIN "+RetSqlName("VOA")+" VOA ON ( VOA.VOA_FILIAL='"+xFilial("VOA")+"' AND VOA.VOA_GRUFER=VO9.VO9_GRUFER AND VOA.D_E_L_E_T_=' ' ) "
	cQuery  += "WHERE "
	cQuery  += "VDP.VDP_FILIAL='"+xFilial("VDP")+"' AND VDP.VDP_DATMOV>='"+dtos(dDatIni)+"' AND VDP.VDP_DATMOV<='"+dtos(dDatFin)+"' AND "
	If !Empty(cCodPro)
		cQuery += "VDP.VDP_CODPRO='"+cCodPro+"' AND "
	EndIf
	If !Empty(cTipMov)
		cQuery += "VDP.VDP_TIPMOV='"+cTipMov+"' AND "
	EndIf
	If !Empty(cCodFer)
		cQuery += "VD3.VD3_CODFER='"+cCodFer+"' AND "
	EndIf
	If !Empty(cGruFer)
		cQuery += "VO9.VO9_GRUFER='"+cGruFer+"' AND "
	EndIf
	cQuery  += "VDP.D_E_L_E_T_=' ' ORDER BY VDP.VDP_CODPRO , VO9.VO9_GRUFER , VD3.VD3_CODFER , VDP.R_E_C_N_O_ "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	While !( cQAlSQL )->( Eof() )
		aAdd(aFilFer,{	stod(( cQAlSQL )->( VDP_DATMOV )),;
						Alltrim(( cQAlSQL )->( VDP_CODPRO ))+" - "+( cQAlSQL )->( VAI_NOMTEC ),;
						X3CBOXDESC("VDP_TIPMOV",( cQAlSQL )->( VDP_TIPMOV )),;
						( cQAlSQL )->( VD3_QTDMOV ),;
						Alltrim(( cQAlSQL )->( VO9_GRUFER ))+" - "+( cQAlSQL )->( VOA_DESGRU ),;
						Alltrim(( cQAlSQL )->( VD3_CODFER ))+" - "+( cQAlSQL )->( VO9_DESFER ),;
						( cQAlSQL )->( RECVDP ) })
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("VDP")
	If len(aFilFer) <= 0
		aAdd(aFilFer,{ctod(""),"","",0,"","",0})
	EndIf
	oLbFilt:nAt := 1
	oLbFilt:SetArray(aFilFer)
	oLbFilt:bLine := { || { Transform(aFilFer[oLbFilt:nAt,01],"@D") ,;
						aFilFer[oLbFilt:nAt,02] ,;
						aFilFer[oLbFilt:nAt,03] ,;
						FG_AlinVlrs(Transform(aFilFer[oLbFilt:nAt,04],"@E 99999")) ,;
						aFilFer[oLbFilt:nAt,05] ,;
						aFilFer[oLbFilt:nAt,06] }}
EndIf
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ OFC480VDP ≥ Autor ≥  Andre Luis Almeida  ≥ Data ≥ 21/09/17 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Visualiza a Movimentacao da Ferramenta                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFC480VDP(nRecVDP)
Private cAlmBFer  := GetNewPar("MV_MIL0020", '') // BLOQUEADO FERRAMENTAS     
Private aRotina := {{"","axPesqui"  , 0 , 1 },;	// Pesquisar
					{ "" ,"OA450"   , 0 , 2 }}	// Visualizar
If nRecVDP > 0 // RecNo VDP
	VISUALIZA := .T.
	INCLUI := .F.
	ALTERA := .F.
	DbSelectArea("VDP")
	DbGoTo(nRecVDP)
	OA450("VDP", nRecVDP, 2)
EndIf
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥FS_IMPRIMIR≥ Autor ≥  Andre Luis Almeida  ≥ Data ≥ 03/11/11 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Impressao do Saldo Atual (Movimentacoes das Ferramentas)   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_IMPRIMIR()
Local ni       := 0
Private cDesc1 := ""
Private cDesc2 := ""
Private cDesc3 := ""
Private tamanho:= "M"
Private limite := 132
Private cString:= "VV1"
Private titulo := STR0001 // Movimentacoes das Ferramentas
Private cabec1 := STR0012+": "+cDatHor // Saldo Atual
Private cabec2 := left(STR0003+space(39),39)+left(STR0005+space(39),39)+left(STR0004+space(49),49)+right(space(5)+STR0011,5) // Produtivo / Grupo / Ferramenta / Qtde
Private aReturn:= {"",1,"",1,2,1,"",1}
Private nomeprog:= "OFIOC480"
Private nLastKey:= 0
nomeprog := SetPrint(cString,nomeprog,nil,titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cString)
nLin  := 60
m_pag := 1
Set Printer to &nomeprog
Set Printer On
Set Device  to Printer
For ni := 1 to len(aUltFer)
	If nLin >= 58
		nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
	EndIf
	@ nLin++, 00 PSAY 	left(Alltrim(aUltFer[ni,01])+" - "+aUltFer[ni,02]+space(38),38)+" "+;
						left(Alltrim(aUltFer[ni,03])+" - "+aUltFer[ni,04]+space(38),38)+" "+;
						left(Alltrim(aUltFer[ni,05])+" - "+aUltFer[ni,06]+space(49),49)+;
						Transform(aUltFer[ni,07],"@E 99999")
Next
Set Printer to
Set Device to Screen
If aReturn[5] == 1
	OurSpool( nomeprog )
EndIf
MS_Flush()
Return()


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    OFIOC48001_SaldoFerr Autor ≥ Vinicius Gati ≥ Data ≥ 24/05/17 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Verifica saldo da peÁa conforme configuraÁ„o se B2 ou N„o  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFIOC48001_SaldoFerr(cCod,cGrp,lSaldoB2,aParSQL)
	Local cQuery     := ""
	Local cQAlSQL    := "SLQAUX"
	Local nRecSB1    := 0
	Local nRecSB2    := 0
	Local nQtdMov    := 0
	Local nQtdTot    := 0
	Default lSaldoB2 := .t. // Controla Estoque no SB2
	Default aParSQL  := OFIOC48002_SQLNAMES() // Monta vetor com os Nomes/xFilial das Tabelas utilizadas no SQL
	if lSaldoB2
		cQuery  := "SELECT SB1.R_E_C_N_O_ AS RECSB1 , "
		cQuery  += "       SB2.R_E_C_N_O_ AS RECSB2 "
		cQuery  += "  FROM "+aParSQL[1,1]+" VO9 "
		cQuery  += "  JOIN "+aParSQL[2,1]+" SB1 ON ( SB1.B1_FILIAL='"+aParSQL[2,2]+"' AND SB1.B1_COD=VO9.VO9_CODPRO AND SB1.D_E_L_E_T_=' ' ) "
		cQuery  += "  JOIN "+aParSQL[3,1]+" SB2 ON ( SB2.B2_FILIAL='"+aParSQL[3,2]+"' AND SB2.B2_COD=SB1.B1_COD AND SB2.B2_LOCAL=SB1.B1_LOCPAD AND SB2.D_E_L_E_T_=' ' ) "
		cQuery  += " WHERE VO9.VO9_FILIAL='"+aParSQL[1,2]+"' AND VO9.VO9_CODFER='"+cCod+"' AND VO9.VO9_GRUFER='"+cGrp+"' AND VO9.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		If !( cQAlSQL )->( Eof() )
			nRecSB1 := ( cQAlSQL )->( RECSB1 )
			nRecSB2 := ( cQAlSQL )->( RECSB2 )
		EndIf
		( cQAlSQL )->( DbCloseArea() )
		If nRecSB1 > 0 .and. nRecSB2 > 0
			DbSelectArea('SB1')
			DbGoTo(nRecSB1)
			DbSelectArea('SB2')
			DbGoTo(nRecSB2)
			return SaldoSB2()
		endIf
	Else
		cQuery  := "SELECT SUM(TMP.QTDTOT) AS QTDTOT "
		cQuery  += "  FROM ( "
		cQuery  += "       SELECT CASE "
		cQuery  += "              WHEN VD3.VD3_TIPMOV = '1' THEN COALESCE( SUM(VD3.VD3_QTDMOV)      ,0 ) "
		cQuery  += "                                        ELSE COALESCE( SUM(VD3.VD3_QTDMOV) * -1 ,0 ) "
		cQuery  += "              END QTDTOT "
		cQuery  += "         FROM "+aParSQL[4,1]+" VD3 "
		cQuery  += "        WHERE VD3.VD3_FILIAL='"+aParSQL[4,2]+"' "
		cQuery  += "          AND VD3.VD3_CODFER='"+cCod+"' "
		cQuery  += "          AND VD3.D_E_L_E_T_=' ' "
		cQuery  += "        GROUP BY VD3.VD3_TIPMOV "
		cQuery  += ") TMP"
		nQtdMov := FM_SQL(cQuery)
		nQtdTot := FM_SQL("SELECT COALESCE( SUM(VO9.VO9_QTDFER),0 ) AS QTD FROM "+aParSQL[1,1]+" VO9 WHERE VO9.VO9_FILIAL='"+aParSQL[1,2]+"' AND VO9.VO9_CODFER='"+cCod+"' AND VO9.D_E_L_E_T_=' '")
		return nQtdTot - nQtdMov // Qtde Total da Ferramenta - Qtde em poder com os Produtivos
	EndIf
Return 0

/*/{Protheus.doc} OFIOC48002_SQLNAMES
Melhoria de PERFORMANCE - Vetor com os Nomes e xFilial das Tabelas
@author Andre Luis Almeida
@since 24/04/2018
@version 1.0
/*/
Static Function OFIOC48002_SQLNAMES()
Local aParSQL := {}
aAdd(aParSQL,{ RetSqlName("VO9") , xFilial("VO9") }) // linha 1 - VO9
aAdd(aParSQL,{ RetSqlName("SB1") , xFilial("SB1") }) // linha 2 - SB1
aAdd(aParSQL,{ RetSqlName("SB2") , xFilial("SB2") }) // linha 3 - SB2
aAdd(aParSQL,{ RetSqlName("VD3") , xFilial("VD3") }) // linha 4 - VD3
aAdd(aParSQL,{ RetSqlName("VDP") , xFilial("VDP") }) // linha 5 - VDP
aAdd(aParSQL,{ RetSqlName("VAI") , xFilial("VAI") }) // linha 6 - VAI
aAdd(aParSQL,{ RetSqlName("VOA") , xFilial("VOA") }) // linha 7 - VOA
Return aParSQL